-- v2.0.2 変数スコープの見直し、メンテの挙動見直し
-- v2.0.3 SetupHookの修正、メンテの挙動見直し
-- v2.0.4 全体的に見直し
local addonName = "EASYBUFF"
local addonNameLower = string.lower(addonName)
local author = "Kiicchan"
local version = "2.0.4"

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

    g.SetupHook(EASYBUFF_OPEN_FOOD_TABLE_UI, "OPEN_FOOD_TABLE_UI")
    g.SetupHook(EASYBUFF_ITEMBUFF_REPAIR_UI_COMMON, "ITEMBUFF_REPAIR_UI_COMMON")
    g.SetupHook(EASYBUFF_TARGET_BUFF_AUTOSELL_LIST, "TARGET_BUFF_AUTOSELL_LIST")
    acutil.setupEvent(addon, "SQUIRE_BUFF_EQUIP_CTRL", "EASYBUFF_SQUIRE_BUFF_EQUIP_CTRL");

    acutil.slashCommand("/easybuff", EASYBUFF_CMD);
    acutil.slashCommand("/esbf", EASYBUFF_CMD);

    -- acutil.setupHook(EASYBUFF_TARGET_BUFF_AUTOSELL_LIST, "TARGET_BUFF_AUTOSELL_LIST")
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

-- メンテ処理
function EASYBUFF_SQUIRE_BUFF_EQUIP_CTRL_DELAY()
    local frame = ui.GetFrame("itembuffopen")
    local checkall = GET_CHILD_RECURSIVELY(frame, 'checkall')
    AUTO_CAST(checkall)
    checkall:SetCheck(1)

    SQUIRE_BUFF_EQUIP_SELECT_ALL(frame, checkall)
    local ctrl = GET_CHILD_RECURSIVELY(frame, "btn_excute")

    SQUIRE_BUFF_EXCUTE(frame, ctrl)
    ui.SysMsg("{ol}Equipment buffs being automatically granted{nl}Use the Cancel button to cancel.")

end

function EASYBUFF_SQUIRE_BUFF_EQUIP_CTRL()

    if g.settings.useHook ~= 1 then

        return
    end
    ReserveScript("EASYBUFF_SQUIRE_BUFF_EQUIP_CTRL_DELAY()", 0.5)

end

-- フード処理
g.foodflag = false
g.foodindex = 0
function EASYBUFF_OPEN_FOOD_TABLE_UI(groupName, sellType, handle, sellerCID, arg_num)

    if g.settings.useHook ~= 1 then
        base["OPEN_FOOD_TABLE_UI"](groupName, sellType, handle, sellerCID, arg_num)
        -- OPEN_FOOD_TABLE_UI_OLD(groupName, sellType, handle, sellerCID, arg_num)
        return
    end
    local pc = GetMyPCObject()
    local obj = world.GetActor(handle);
    local actorPos = obj:GetPos();
    local x, y, z = GetPos(pc)

    local dis = math.sqrt((actorPos.x - x) ^ 2 + ((actorPos.z - z) ^ 2))
    if dis > 30 then
        ui.SysMsg(ClMsg('FarFromFoodTable'))
        return
    end

    local frame = ui.GetFrame("foodtable_ui");
    if groupName == 'None' then
        frame:ShowWindow(0);
        return;
    else
        frame:ShowWindow(1);
    end

    frame:SetUserValue('GroupName', groupName);
    frame:SetUserValue('SELLTYPE', sellType);
    frame:SetUserValue('HANDLE', handle);
    frame:SetUserValue('SHARED', arg_num);

    REGISTERR_LASTUIOPEN_POS(frame);

    local myTable = false;
    if session.GetMySession():GetCID() == sellerCID then
        myTable = true;
    end

    local gbox = frame:GetChild("gbox");
    local gbox_table = gbox:GetChild("gbox_table");
    gbox_table:RemoveAllChild();

    local cnt = session.autoSeller.GetCount(groupName);
    for i = 0, cnt - 1 do
        local info = session.autoSeller.GetByIndex(groupName, i);
        local ctrlSet = gbox_table:CreateControlSet('camp_food_item', "FOOD" .. i, 0, 0);
        ctrlSet:SetUserValue('INDEX', i)
        local cls = GetClassByType("FoodTable", info.classID);
        local abil = GetOtherAbility(GetMyPCObject(), cls.Ability);
        if myTable == true then
            abil = GetAbility(GetMyPCObject(), cls.Ability);
        end
        local abilLevel = TryGetProp(abil, 'Level', 0)
        SET_FOOD_TABLE_BASE_INFO(ctrlSet, cls, info.level, abilLevel);
        local itemcount = GET_CHILD(ctrlSet, "itemcount");
        itemcount:SetTextByKey("value", info.remainCount);
    end

    GBOX_AUTO_ALIGN(gbox_table, 15, 3, 10, true, false);

    local tabVisible = true

    local tab = gbox:GetChild("itembox");
    if nil == tab then
        return;
    end
    -- gbox_table
    tolua.cast(tab, 'ui::CTabControl');
    local index = tab:GetIndexByName("tab_normal")
    tab:SetTabVisible(index + 1, tabVisible);
    tab:SelectTab(index);
    tab:ShowWindow(1);

    local button_1 = GET_CHILD_RECURSIVELY(frame, "button_1")
    if frame:GetUserIValue("HANDLE") ~= session.GetMyHandle() then
        button_1:ShowWindow(0)
    else
        button_1:ShowWindow(1)
    end

    EASYBUFF_FOOD_TABLE_FRAME_INIT()

    if g.foodflag == false then
        local myHandle = session.GetMyHandle()
        local foodBuffs = {4021, 4022, 4023, 4024, 4087, 4136}
        for _, buffID in ipairs(foodBuffs) do
            local buff = info.GetBuff(myHandle, buffID)
            if buff ~= nil then
                local msg = "Do you clear food buffs?"
                local scp = string.format("EASYBUFF_FOODCLEAR()")
                ui.MsgBox(msg, scp, "None")

            end
        end
    end
end

function EASYBUFF_FOODCLEAR()
    local myHandle = session.GetMyHandle()
    local foodBuffs = {4021, 4022, 4023, 4024, 4087, 4136}

    for _, buffID in ipairs(foodBuffs) do
        local buff = info.GetBuff(myHandle, buffID)
        if buff ~= nil then
            packet.ReqRemoveBuff(buffID)
            ReserveScript("EASYBUFF_FOODCLEAR()", 0.3)
            return
        end
    end
    g.foodflag = true
    ui.SysMsg("{#FFFFFF}{ol}Food buff cleared.")

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
    local frame = ui.GetFrame("foodtable_ui")
    local handle = frame:GetUserIValue("HANDLE")
    local sellType = frame:GetUserIValue("SELLTYPE")

    if g.foodindex < num then
        session.autoSeller.Buy(handle, g.foodindex, 1, sellType)
        g.foodindex = g.foodindex + 1
        ReserveScript(string.format("EASYBUFF_FOOD('%s','%s','%s',%d)", frame, ctrl, str, num), 0.6)
    else
        EASYBUFF_END_FOOD()
    end
end

function EASYBUFF_END_FOOD()

    ui.CloseFrame("foodtable_ui")
    g.foodflag = false
    g.foodindex = 0
end

-- バフ屋
g.buffIndex = 0;
function EASYBUFF_ON_BUFF()
    local frame = ui.GetFrame("buffseller_target");
    local handle = frame:GetUserIValue("HANDLE");
    local groupName = frame:GetUserValue("GROUPNAME");
    local sellType = frame:GetUserIValue("SELLTYPE");
    local cnt = session.autoSeller.GetCount(groupName);
    local itemInfo = session.autoSeller.GetByIndex(groupName, 0);
    if itemInfo == nil then
        ui.SysMsg("No buff info")
        return;
    end
    g.buffIndex = 0;
    EASYBUFF_BUY(handle, sellType, cnt)
end

function EASYBUFF_BUY(handle, sellType, cnt)
    if g.buffIndex < cnt then
        session.autoSeller.Buy(handle, g.buffIndex, 1, sellType);
        g.buffIndex = g.buffIndex + 1;
        ReserveScript(string.format("EASYBUFF_BUY(%d, %d, %d)", handle, sellType, cnt), 0.6)
    else

        EASYBUFF_END()
    end
end

function EASYBUFF_TARGET_BUFF_AUTOSELL_LIST(groupName, sellType, handle)
    base["TARGET_BUFF_AUTOSELL_LIST"](groupName, sellType, handle)
    -- TARGET_BUFF_AUTOSELL_LIST_OLD(groupName, sellType, handle)
    if g.settings.useHook ~= 1 then
        return;
    end

    local frame = ui.GetFrame("buffseller_target");
    if frame ~= nil then
        local sellType = frame:GetUserIValue("SELL_TYPE");
        if sellType == AUTO_SELL_BUFF and g.buffIndex == 0 then
            EASYBUFF_ON_BUFF()
        end
    end
end

function EASYBUFF_END()
    g.buffIndex = 0;
    ui.CloseFrame("buffseller_target");
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
