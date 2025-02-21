-- v2.0.2 変数スコープの見直し、メンテの挙動見直し
-- v2.0.3 SetupHookの修正、メンテの挙動見直し
-- v2.0.4 全体的に見直し
-- v2.0.5 食事の時バグってたの修正。
-- v2.0.6 修正したと思ったけど修正出来てなかったのを修正
-- v2.0.7 バフ屋も付与時確認追加。
local addonName = "EASYBUFF"
local addonNameLower = string.lower(addonName)
local author = "Kiicchan"
local version = "2.0.7"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName];

g.settingsFileLoc = string.format("../addons/%s/settings.json", addonNameLower);

local base = {}

local acutil = require("acutil");

function g.SetupHook(func, baseFuncName)
    local addonUpper = string.upper(addonName)
    local replacementName = addonUpper .. "_BASE_" .. baseFuncName
    if (_G[replacementName] == nil) then
        _G[replacementName] = _G[baseFuncName];
        _G[baseFuncName] = func
    end
    base[baseFuncName] = _G[replacementName]
end

function EASYBUFF_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame

    EASYBUFF_LOAD_SETTINGS()

    g.SetupHook(EASYBUFF_OPEN_FOOD_TABLE_UI_DELAY, "OPEN_FOOD_TABLE_UI")
    g.SetupHook(EASYBUFF_ITEMBUFF_REPAIR_UI_COMMON, "ITEMBUFF_REPAIR_UI_COMMON")
    -- g.SetupHook(EASYBUFF_TARGET_BUFF_AUTOSELL_LIST, "TARGET_BUFF_AUTOSELL_LIST")
    acutil.setupEvent(addon, "SQUIRE_BUFF_EQUIP_CTRL", "EASYBUFF_SQUIRE_BUFF_EQUIP_CTRL");
    acutil.setupEvent(addon, "SQUIRE_TARGET_UI_CLOSE", "EASYBUFF_SQUIRE_TARGET_UI_CLOSE");
    acutil.setupEvent(addon, "TARGET_BUFF_AUTOSELL_LIST", "EASYBUFF_TARGET_BUFF_AUTOSELL_LIST");

    acutil.slashCommand("/easybuff", EASYBUFF_CMD);
    acutil.slashCommand("/esbf", EASYBUFF_CMD);

    -- acutil.setupHook(EASYBUFF_OPEN_FOOD_TABLE_UI_DELAY, "OPEN_FOOD_TABLE_UI")
    -- acutil.setupHook(EASYBUFF_OPEN_FOOD_TABLE_UI, "OPEN_FOOD_TABLE_UI")
    -- acutil.setupHook(EASYBUFF_ITEMBUFF_REPAIR_UI_COMMON, "ITEMBUFF_REPAIR_UI_COMMON")

end

function EASYBUFF_LOAD_SETTINGS()

    local settings, err = acutil.loadJSON(g.settingsFileLoc, g.settings);
    if err then
        -- 設定ファイル読み込み失敗時処理
        -- CHAT_SYSTEM(string.format("[%s] cannot load setting files", addonName))
    end
    -- 設定ファイル読み込み成功時処理
    if not settings then
        settings = {
            useHook = 1
        }
    end

    g.settings = settings

    EASYBUFF_SAVE_SETTINGS()
end

function EASYBUFF_SAVE_SETTINGS()
    acutil.saveJSON(g.settingsFileLoc, g.settings);
end

function EASYBUFF_CMD(command)

    if g.settings.useHook == 1 then
        g.settings.useHook = 0
        EASYBUFF_SAVE_SETTINGS()
        ui.SysMsg("Auto buff off")
    else
        g.settings.useHook = 1
        EASYBUFF_SAVE_SETTINGS()
        ui.SysMsg("Auto buff on")
    end

end

function EASYBUFF_LANG(str)

    local langcode = option.GetCurrentCountry()

    if langcode == "Japanese" then

        if str == "{#FFFFFF}{ol}Equipment maintenance automatic grant is in progress.{nl}Canceled when frame is closed." then
            str =
                "{#FFFFFF}{ol}装備メンテナンス自動付与中。{nl}フレームを閉じればキャンセルします。"
        end

        if str == "{#FFFFFF}{ol}Remove food buffs?" then
            str = "{#FFFFFF}{ol}フードバフ削除しますか？"
        end
        -- {#FFFFFF}{ol}Food buff removed.
        if str == "{#FFFFFF}{ol}Food buff removed." then
            str = "{#FFFFFF}{ol}フードバフを削除しました。"
        end
        -- "{#FFFFFF}{ol}Do you want to re-buff it?"
        if str == "{#FFFFFF}{ol}Do you want to re-buff it?" then
            str = "{#FFFFFF}{ol}バフをかけ直しますか？"
        end
    end
    return str

end

-- メンテ処理

function EASYBUFF_SQUIRE_TARGET_UI_CLOSE()
    packet.StopTimeAction(1)
    local frame = ui.GetFrame("itembuffopen")
    frame:ShowWindow(0)
    return 0
end

function EASYBUFF_SQUIRE_BUFF_EQUIP_CTRL_DELAY()
    local frame = ui.GetFrame("itembuffopen")
    local checkall = GET_CHILD_RECURSIVELY(frame, 'checkall')
    AUTO_CAST(checkall)
    checkall:SetCheck(1)

    SQUIRE_BUFF_EQUIP_SELECT_ALL(frame, checkall)
    local ctrl = GET_CHILD_RECURSIVELY(frame, "btn_excute")

    SQUIRE_BUFF_EXCUTE(frame, ctrl)
    ui.SysMsg(EASYBUFF_LANG(
                  "{#FFFFFF}{ol}Equipment maintenance automatic grant is in progress.{nl}Canceled when frame is closed."))
    frame:RunUpdateScript("EASYBUFF_SQUIRE_TARGET_UI_CLOSE", 5.5);
end

function EASYBUFF_SQUIRE_BUFF_EQUIP_CTRL()

    if g.settings.useHook ~= 1 then

        return
    end

    local frame = ui.GetFrame("itembuffopen")
    if session.GetMyHandle() == frame:GetUserIValue("HANDLE") then
        return
    end
    ReserveScript("EASYBUFF_SQUIRE_BUFF_EQUIP_CTRL_DELAY()", 0.5)
    return
end

-- フード処理
g.foodfull = false
g.foodindex = 0

function EASYBUFF_OPEN_FOOD_TABLE_UI_DELAY(groupName, sellType, handle, sellerCID, arg_num)

    if g.settings.useHook ~= 1 then
        base["OPEN_FOOD_TABLE_UI"](groupName, sellType, handle, sellerCID, arg_num)
        -- OPEN_FOOD_TABLE_UI_OLD(groupName, sellType, handle, sellerCID, arg_num)
        return
    end

    if not g.foodfull then
        local myHandle = session.GetMyHandle()
        local foodBuffs = {4021, 4022, 4023, 4024, 4087, 4136}
        for _, buffID in ipairs(foodBuffs) do
            local buff = info.GetBuff(myHandle, buffID)
            if buff ~= nil then
                local msg = EASYBUFF_LANG("{#FFFFFF}{ol}Remove food buffs?")
                local yesscp = string.format("EASYBUFF_FOODCLEAR('%s',%d,%d,'%s',%d)", groupName, sellType, handle,
                                             sellerCID, arg_num)
                local noscp = string.format("EASYBUFF_OPEN_FOOD_TABLE_UI('%s',%d,%d,'%s',%d)", groupName, sellType,
                                            handle, sellerCID, arg_num)
                ui.MsgBox(msg, yesscp, noscp)
                return

            end
        end

    end
    EASYBUFF_OPEN_FOOD_TABLE_UI(groupName, sellType, handle, sellerCID, arg_num)

end

function EASYBUFF_OPEN_FOOD_TABLE_UI(groupName, sellType, handle, sellerCID, arg_num)

    EASYBUFF_FOOD_TABLE_FRAME_INIT()
    base["OPEN_FOOD_TABLE_UI"](groupName, sellType, handle, sellerCID, arg_num)

end

function EASYBUFF_FOODCLEAR(groupName, sellType, handle, sellerCID, arg_num)
    local myHandle = session.GetMyHandle()
    local foodBuffs = {4021, 4022, 4023, 4024, 4087, 4136}

    for _, buffID in ipairs(foodBuffs) do
        local buff = info.GetBuff(myHandle, buffID)
        if buff ~= nil then
            packet.ReqRemoveBuff(buffID)
            ReserveScript(string.format("EASYBUFF_FOODCLEAR('%s',%d,%d,'%s',%d)", groupName, sellType, handle,
                                        sellerCID, arg_num), 0.3)
            return
        end
    end

    ui.SysMsg(EASYBUFF_LANG("{#FFFFFF}{ol}Food buff removed."))
    g.foodfull = true
    EASYBUFF_FOOD_TABLE_FRAME_INIT()
    base["OPEN_FOOD_TABLE_UI"](groupName, sellType, handle, sellerCID, arg_num)

end

function EASYBUFF_FOOD_TABLE_FRAME_INIT()

    local frame = ui.GetFrame("foodtable_ui")

    local btn = frame:CreateOrGetControl("button", "btn", 210, 50, 80, 30)
    btn:SetText("{ol}4food")
    btn:SetEventScript(ui.LBUTTONUP, "EASYBUFF_FOOD")
    btn:SetEventScriptArgNumber(ui.LBUTTONUP, 4);

    local btn2 = frame:CreateOrGetControl("button", "btn2", 295, 50, 80, 30)
    btn2:SetText("{ol}5food")
    btn2:SetEventScript(ui.LBUTTONUP, "EASYBUFF_FOOD")
    btn2:SetEventScriptArgNumber(ui.LBUTTONUP, 5);

    local btn3 = frame:CreateOrGetControl("button", "btn3", 380, 50, 80, 30)
    btn3:SetText("{ol}allfood")
    btn3:SetEventScript(ui.LBUTTONUP, "EASYBUFF_FOOD")
    btn3:SetEventScriptArgNumber(ui.LBUTTONUP, 6);

end

function EASYBUFF_FOOD(frame, ctrl, str, num)
    g.foodfull = true
    local frame = ui.GetFrame("foodtable_ui")
    local handle = frame:GetUserIValue("HANDLE")
    local sellType = frame:GetUserIValue("SELLTYPE")

    if g.foodindex < num then
        session.autoSeller.Buy(handle, g.foodindex, 1, sellType)
        g.foodindex = g.foodindex + 1
        ReserveScript(string.format("EASYBUFF_FOOD('%s','%s','%s',%d)", frame, ctrl, str, num), 0.6)
    else
        EASYBUFF_END_FOOD(frame)
    end
end

function EASYBUFF_END_FOOD(frame)
    frame:ShowWindow(0)

    g.foodfull = false
    g.foodindex = 0
end

-- バフ屋
local msgcount = 0
function EASYBUFF_TARGET_BUFF_AUTOSELL_LIST(frame, msg)
    local groupName, sellType, handle = acutil.getEventArgs(msg)

    if g.settings.useHook ~= 1 then
        return;
    end

    if sellType == 0 then

        local itemInfo = session.autoSeller.GetByIndex(groupName, 0);

        if itemInfo ~= nil then
            local boxmsg = EASYBUFF_LANG("{#FFFFFF}{ol}Do you want to re-buff it?")
            local cnt = session.autoSeller.GetCount(groupName);
            local buffcount = 0

            local myHandle = session.GetMyHandle()
            local Buffs = {358, 359, 360, 370}

            for _, buffID in ipairs(Buffs) do
                local buff = info.GetBuff(myHandle, buffID)
                if buff == nil and msgcount == 0 then
                    msgcount = 1
                    EASYBUFF_BUY(handle, sellType, cnt, buffcount)

                    return
                end
            end

            local yesscp = string.format("EASYBUFF_BUY(%d, %d, %d,%d)", handle, sellType, cnt, buffcount)
            local noscp = string.format("EASYBUFF_END()")

            if msgcount == 0 then
                msgcount = 1
                ui.MsgBox(boxmsg, yesscp, noscp)
            end

        else
            ui.SysMsg("No buff item")
            return;
        end
    else
        return
    end
end

function EASYBUFF_BUY(handle, sellType, cnt, buffcount)

    if buffcount < cnt then

        session.autoSeller.Buy(handle, buffcount, 1, sellType);
        buffcount = buffcount + 1;
        ReserveScript(string.format("EASYBUFF_BUY(%d, %d, %d,%d)", handle, sellType, cnt, buffcount), 0.6)
        return
    else
        EASYBUFF_END()
    end
end

function EASYBUFF_END()
    local frame = ui.GetFrame("buffseller_target");
    frame:ShowWindow(0)
    msgcount = 0
    return

end

-- Repair buff
function EASYBUFF_ON_REPAIR()
    session.ResetItemList();

    local frame = ui.GetFrame("itembuffrepair");
    local handle = frame:GetUserValue("HANDLE");
    local skillName = frame:GetUserValue("SKILLNAME");
    local slotSet = GET_CHILD_RECURSIVELY(frame, "slotlist", "ui::CSlotSet")
    local slotCount = slotSet:GetSlotCount();

    local cheapest = nil;
    local price = 0;
    for i = 0, slotCount - 1 do
        local slot = slotSet:GetSlotByIndex(i);
        if slot:GetIcon() ~= nil then
            local Icon = slot:GetIcon();
            local iconInfo = Icon:GetInfo();
            local invitem = GET_ITEM_BY_GUID(iconInfo:GetIESID());
            local itemobj = GetIES(invitem:GetObject());
            local needItem, needCount = ITEMBUFF_NEEDITEM_Squire_Repair(GetMyPCObject(), itemobj);

            if needCount < price or price == 0 then
                cheapest = slot;
                price = needCount;
            end
        end
    end
    if cheapest ~= nil then
        local Icon = cheapest:GetIcon();
        local iconInfo = Icon:GetInfo();
        session.AddItemID(iconInfo:GetIESID());
    end

    session.autoSeller.BuyItems(handle, AUTO_SELL_SQUIRE_BUFF, session.GetItemIDList(), skillName);
end

function EASYBUFF_ITEMBUFF_REPAIR_UI_COMMON(groupName, sellType, handle)
    base["ITEMBUFF_REPAIR_UI_COMMON"](groupName, sellType, handle)
    -- ITEMBUFF_REPAIR_UI_COMMON_OLD(groupName, sellType, handle)

    if g.settings.useHook ~= 1 then
        return;
    end
    local frame = ui.GetFrame("itembuffrepair");
    if frame ~= nil then
        EASYBUFF_ON_REPAIR()
    end
end
