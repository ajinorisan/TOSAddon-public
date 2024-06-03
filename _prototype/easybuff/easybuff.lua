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

g.settings = {
    useHook = 1
}
g.buffIndex = 0;
g.foodIndex = 0;

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

    if not g.loaded then
        local t, err = acutil.loadJSON(g.settingsFileLoc, g.settings);
        if err then
            -- 設定ファイル読み込み失敗時処理
            -- CHAT_SYSTEM(string.format("[%s] cannot load setting files", addonName))
        else
            -- 設定ファイル読み込み成功時処理
            g.settings = t;
        end
        g.loaded = true
    end

    EASYBUFF_SAVESETTINGS();

    -- addon:RegisterMsg("GAME_START_3SEC", "EASYBUFF_FOOD_TABLE_FRAME_INIT")
    --[[g.SetupHook(EASYBUFF_TARGET_BUFF_AUTOSELL_LIST, "TARGET_BUFF_AUTOSELL_LIST")
    g.SetupHook(EASYBUFF_OPEN_FOOD_TABLE_UI, "OPEN_FOOD_TABLE_UI")
    g.SetupHook(EASYBUFF_ITEMBUFF_REPAIR_UI_COMMON, "ITEMBUFF_REPAIR_UI_COMMON")
    g.SetupHook(EASYBUFF_SQUIRE_BUFF_EQUIP_CTRL, "SQUIRE_BUFF_EQUIP_CTRL")]]

    acutil.setupHook(EASYBUFF_TARGET_BUFF_AUTOSELL_LIST, "TARGET_BUFF_AUTOSELL_LIST")
    acutil.setupHook(EASYBUFF_OPEN_FOOD_TABLE_UI, "OPEN_FOOD_TABLE_UI")
    acutil.setupHook(EASYBUFF_ITEMBUFF_REPAIR_UI_COMMON, "ITEMBUFF_REPAIR_UI_COMMON")
    acutil.setupHook(EASYBUFF_SQUIRE_BUFF_EQUIP_CTRL, "SQUIRE_BUFF_EQUIP_CTRL")

    acutil.slashCommand("/easybuff", EASYBUFF_CMD);
    acutil.slashCommand("/esbf", EASYBUFF_CMD);
end

function EASYBUFF_SAVESETTINGS()
    acutil.saveJSON(g.settingsFileLoc, g.settings);
end

function EASYBUFF_CMD(command)
    if g.settings.useHook == 1 then
        g.settings.useHook = 0
        EASYBUFF_SAVESETTINGS();
        CHAT_SYSTEM("Auto buff off")
    else
        g.settings.useHook = 1
        EASYBUFF_SAVESETTINGS();
        CHAT_SYSTEM("Auto buff on")
    end
    return;
end

-- メンテ処理

local enable_slot_list = {'RH', 'LH', 'RH_SUB', 'LH_SUB', 'SHIRT', 'PANTS', 'GLOVES', 'BOOTS'}

local function SQUIRE_BUFF_ENABLE_ITEM_CHECK(frame, inv_item, item_obj)
    local pc = GetMyPCObject()
    if inv_item == nil or item_obj == nil then
        return false
    end

    if IS_NO_EQUIPITEM(item_obj) == 1 then
        return false
    end

    if TryGetProp(item_obj, 'Dur', 0) <= 0 then
        -- ui.SysMsg(ClMsg("DurUnder0"))
        return false
    end

    local checkItem = _G["ITEMBUFF_CHECK_" .. frame:GetUserValue("SKILLNAME")]
    if 1 ~= checkItem(pc, item_obj) then
        -- ui.SysMsg(ClMsg("WrongDropItem"))
        return false
    end

    return true
end

function EASYBUFF_SQUIRE_BUFF_EQUIP_CTRL(frame)

    if g.settings.useHook ~= 1 then
        -- base["SQUIRE_BUFF_EQUIP_CTRL"](frame)
        SQUIRE_BUFF_EQUIP_CTRL_OLD(frame)
        return
    end
    local checkall = GET_CHILD_RECURSIVELY(frame, 'checkall')
    checkall:SetCheck(1)

    local ctrlGbox = GET_CHILD_RECURSIVELY(frame, 'ctrlGbox')
    ctrlGbox:RemoveAllChild()

    local index = 0
    for i = 1, #enable_slot_list do
        local slot_name = enable_slot_list[i]
        local inv_item = session.GetEquipItemBySpot(item.GetEquipSpotNum(slot_name))
        if inv_item ~= nil then
            local item_obj = GetIES(inv_item:GetObject())
            if SQUIRE_BUFF_ENABLE_ITEM_CHECK(frame, inv_item, item_obj) == true then
                local ctrl_height = ui.GetControlSetAttribute('itembuff_ctrlset', 'height')
                local ctrlset = ctrlGbox:CreateOrGetControlSet('itembuff_ctrlset', 'ITEMBUFF_CTRL_' .. slot_name, 2,
                                                               ctrl_height * index)

                if ctrlset ~= nil then
                    local slot = GET_CHILD(ctrlset, 'slot')
                    SET_SLOT_ITEM(slot, inv_item)
                    slot:SetUserValue('ITEM_GUID', inv_item:GetIESID())
                    slot:SetUserValue('ITEM_SLOT', slot_name)

                    local item_name = GET_CHILD(ctrlset, 'item_name')
                    item_name:SetTextByKey('name', dic.getTranslatedStr(TryGetProp(item_obj, 'Name', 'NONE')))

                    local checkbox = GET_CHILD(ctrlset, 'checkbox')
                    checkbox:SetCheck(1)

                    local time = GET_CHILD_RECURSIVELY(ctrlset, 'time')
                    time:ShowWindow(0)
                    local timestr = GET_CHILD_RECURSIVELY(ctrlset, 'timestr')
                    timestr:ShowWindow(0)

                    index = index + 1
                end
            end
        end
    end

    SQUIRE_BUFF_COST_UPDATE(frame)
    local ctrl = GET_CHILD_RECURSIVELY(frame, "btn_excute")

    SQUIRE_BUFF_EXCUTE(frame, ctrl)
    -- EASYBUFF_SQUIRE_BUFF_EXCUTE(parent, ctrl)
end

--[[function EASYBUFF_SQUIRE_BUFF_EQUIP_CTRL(frame)
    base["SQUIRE_BUFF_EQUIP_CTRL"](frame)

    if g.settings.useHook ~= 1 then
        return
    end
    local handle = frame:GetUserIValue("HANDLE")
    local skillName = frame:GetUserValue("SKILLNAME")

    -- 그럼 이것은 판매자
    if handle == session.GetMyHandle() then
        if "Squire_Repair" == skillName then
            SQUIRE_REPAIR_CANCEL()
            return
        end
    end

    local gboxctrl = GET_CHILD_RECURSIVELY(frame, "repair")
    gboxctrl:ShowWindow(1)
    local gboxctrl = GET_CHILD_RECURSIVELY(frame, "log")
    gboxctrl:ShowWindow(0)
    --[[
    local myshop = false;
    if session.GetMySession():GetCID() == sellerCID then
        myshop = true;
    end

    if myshop then
        return;
    end
    ]]
-- <button name="btn_excute" parent="repair" rect="0 0 140 55" margin="-80 0 0 65" layout_gravity="center bottom" LBtnUpScp="SQUIRE_BUFF_EXCUTE" caption="{@st42}확 인" skin="test_red_button"/>

--[[local iboframe = ui.GetFrame("itembuffopen")
    local parent = GET_CHILD_RECURSIVELY(iboframe, "repair")
    -- local checkall = GET_CHILD_RECURSIVELY(iboframe, 'checkall')
    local ctrl = GET_CHILD_RECURSIVELY(iboframe, "btn_excute")
    -- checkall:SetCheck(1)
    EASYBUFF_SQUIRE_BUFF_EXCUTE(parent, ctrl)

end]]

--[[function EASYBUFF_OPERATION_CANCEL()

    local cancelframe = ui.CreateNewFrame("notice_on_pc", "cancelframe", 0, 0, 0, 0)
    AUTO_CAST(cancelframe)
    -- CHAT_SYSTEM("EASYBUFF_OPERATION_CANCEL")
    cancelframe:Resize(170, 70)
    local screenWidth = ui.GetClientInitialWidth()
    local offsetX = screenWidth / 2
    local screenHeight = ui.GetClientInitialHeight()
    local offsetY = screenHeight / 2
    cancelframe:SetOffset(offsetX, offsetY)

    local cancelbtn = cancelframe:CreateOrGetControl("button", "cancelbtn", 0, 0, 170, 70)
    AUTO_CAST(cancelbtn)
    cancelbtn:SetText("Operation Cancel")
    cancelbtn:SetSkinName("test_red_button")

    cancelbtn:SetEventScript(ui.LBUTTONUP, "EASYBUFF_SQUIRE_BUFF_CANCEL_CHECK")
    cancelframe:ShowWindow(1)
end

function EASYBUFF_SQUIRE_BUFF_CANCEL_CHECK(cancelframe)
    local frame = ui.GetFrame("itembuffopen")
    local handle = frame:GetUserIValue("HANDLE")
    local skillName = frame:GetUserValue("SKILLNAME")

    -- 그럼 이것은 판매자
    if handle == session.GetMyHandle() then
        if "Squire_Repair" == skillName then
            SQUIRE_REPAIR_CANCEL()
            return
        end
    end

    -- 유저
    session.autoSeller.BuyerClose(AUTO_SELL_SQUIRE_BUFF, handle)
    cancelframe:ShowWindow(0)
end

local enable_slot_list = {"RH", "LH", "RH_SUB", "LH_SUB", "SHIRT", "PANTS", "GLOVES", "BOOTS"}

function EASYBUFF_SQUIRE_BUFF_EXCUTE(parent, ctrl)
    local frame = ui.GetFrame("itembuffopen")
    local handle = frame:GetUserValue("HANDLE")
    local skillName = frame:GetUserValue("SKILLNAME")

    local checkall = GET_CHILD_RECURSIVELY(frame, 'checkall')
    checkall:SetCheck(1)
    session.ResetItemList()

    local cnt = 0
    for i = 1, #enable_slot_list do
        local slot_name = enable_slot_list[i]
        local ctrlset = GET_CHILD_RECURSIVELY(frame, 'ITEMBUFF_CTRL_' .. slot_name)
        if ctrlset ~= nil then
            local checkbox = GET_CHILD(ctrlset, 'checkbox')
            checkbox:SetCheck(1)
            if checkbox:IsChecked() == 1 then
                local inv_item = session.GetEquipItemBySpot(item.GetEquipSpotNum(slot_name))
                if inv_item ~= nil then
                    session.AddItemID(inv_item:GetIESID())
                    cnt = cnt + 1
                end
            end
        end
    end

    if cnt <= 0 then
        ui.MsgBox(ScpArgMsg("SelectBuffItemPlz"))
        return
    end
    EASYBUFF_OPERATION_CANCEL()
    -- frame:ShowWindow(0)
    ui.SysMsg("{#FFFFFF}{ol}Equipment Maintenance in progress." .. "{#FFFFFF}{ol}To cancel, use the Cancel button.")
    -- ui.SysMsg("{#FFFFFF}To cancel, use the Cancel button.")
    -- ui.SysMsg("{#FFFFFF}装備メンテナンス中 キャンセルは取消ボタンで!")
    session.autoSeller.BuyItems(handle, AUTO_SELL_SQUIRE_BUFF, session.GetItemIDList(), skillName)

    SQUIRE_TARGET_UI_CLOSE()
    ReserveScript("EASYBUFF_SQUIRE_TARGET_UI_CLOSE()", 5.5)
    return
end

function EASYBUFF_SQUIRE_TARGET_UI_CLOSE()
    local cancelframe = ui.GetFrame("cancelframe")

    cancelframe:ShowWindow(0)
end]]

-- フード処理

function EASYBUFF_OPEN_FOOD_TABLE_UI(groupName, sellType, handle, sellerCID, arg_num)

    if g.settings.useHook ~= 1 then
        -- base["OPEN_FOOD_TABLE_UI"](groupName, sellType, handle, sellerCID, arg_num)
        OPEN_FOOD_TABLE_UI_OLD(groupName, sellType, handle, sellerCID, arg_num)
        return
    end
    local pc = GetMyPCObject()
    local obj = world.GetActor(handle);
    local actorPos = obj:GetPos();
    local x, y, z = GetPos(pc)

    --[[local dis = math.sqrt((actorPos.x - x) ^ 2 + ((actorPos.z - z) ^ 2))
    if dis > 30 then
        ui.SysMsg(ClMsg('FarFromFoodTable'))
        return
    end]]

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

    local msg = "Do you clear food buffs?"
    local scp = string.format("EASYBUFF_FOODCLEAR()")
    ui.MsgBox(msg, scp, "None")

end

function EASYBUFF_FOODCLEAR()
    local myHandle = session.GetMyHandle()
    local foodBuffs = {4021, 4022, 4023, 4024, 4087, 4136}

    for _, buffID in ipairs(foodBuffs) do
        local buff = info.GetBuff(myHandle, buffID)
        if buff ~= nil then
            packet.ReqRemoveBuff(buffID)

        end
    end
    ui.SysMsg("{#FFFFFF}{ol}Food buff cleared.")

end

function EASYBUFF_FOOD_TABLE_FRAME_INIT()

    local frame = ui.GetFrame("foodtable_ui")

    local btn = frame:CreateOrGetControl("button", "btn", 160, 50, 80, 30)
    btn:SetText("{ol}4food")
    btn:SetEventScript(ui.LBUTTONUP, "EASYBUFF_FOOD")
    btn:SetEventScriptArgNumber(ui.LBUTTONUP, 4);

    local btn2 = frame:CreateOrGetControl("button", "btn2", 250, 50, 80, 30)
    btn2:SetText("{ol}5food")
    btn2:SetEventScript(ui.LBUTTONUP, "EASYBUFF_FOOD")
    btn2:SetEventScriptArgNumber(ui.LBUTTONUP, 5);

    local btn3 = frame:CreateOrGetControl("button", "btn3", 340, 50, 80, 30)
    btn3:SetText("{ol}allfood")
    btn3:SetEventScript(ui.LBUTTONUP, "EASYBUFF_FOOD")
    btn3:SetEventScriptArgNumber(ui.LBUTTONUP, 6);

end

local foodindex = 0

function EASYBUFF_FOOD(frame, ctrl, str, num)
    local frame = ui.GetFrame("foodtable_ui")
    local handle = frame:GetUserIValue("HANDLE")
    local sellType = frame:GetUserIValue("SELLTYPE")

    if foodindex < num then
        session.autoSeller.Buy(handle, foodindex, 1, sellType)
        foodindex = foodindex + 1
        ReserveScript(string.format("EASYBUFF_FOOD('%s','%s','%s',%d)", frame, ctrl, str, num), 0.6)
    else
        EASYBUFF_END_FOOD()
    end
end

function EASYBUFF_END_FOOD()
    foodindex = 0
    ui.CloseFrame("foodtable_ui")
end

--[[function EASYBUFF_OPEN_FOOD_TABLE_UI(groupName, sellType, handle, sellerCID, arg_num)
    base["OPEN_FOOD_TABLE_UI"](groupName, sellType, handle, sellerCID, arg_num)

    if g.settings.useHook ~= 1 then
        return;
    end

    local myTable = false;
    if session.GetMySession():GetCID() == sellerCID then
        myTable = true;
    end

    if myTable then
        return;
    end

end]]
--[[function EASYBUFF_4FOODONLY()
    local frame = ui.GetFrame("foodtable_ui")
    local handle = frame:GetUserIValue("HANDLE");
    local sellType = frame:GetUserIValue("SELLTYPE");

    if g.foodIndex < 4 then
        session.autoSeller.Buy(handle, g.foodIndex, 1, sellType);
        g.foodIndex = g.foodIndex + 1;
        ReserveScript(string.format("EASYBUFF_4FOODONLY()"), 0.6)
    else
        -- g.foodIndex = 0
        EASYBUFF_END_FOOD()
    end
end

function EASYBUFF_5FOODONLY()
    local frame = ui.GetFrame("foodtable_ui")
    local handle = frame:GetUserIValue("HANDLE");
    local sellType = frame:GetUserIValue("SELLTYPE");

    if g.foodIndex < 5 then
        session.autoSeller.Buy(handle, g.foodIndex, 1, sellType);
        g.foodIndex = g.foodIndex + 1;
        ReserveScript(string.format("EASYBUFF_5FOODONLY()"), 0.6)
    else
        EASYBUFF_END_FOOD()
    end
end

function EASYBUFF_ALLFOOD()
    local frame = ui.GetFrame("foodtable_ui")
    local handle = frame:GetUserIValue("HANDLE");
    local sellType = frame:GetUserIValue("SELLTYPE");

    if g.foodIndex <= 5 then
        session.autoSeller.Buy(handle, g.foodIndex, 1, sellType);
        g.foodIndex = g.foodIndex + 1;
        ReserveScript(string.format("EASYBUFF_ALLFOOD()"), 0.6)
    else
        EASYBUFF_END_FOOD()
    end
end]]

--[[function EASYBUFF_FOODCLEAR()
    local myhandle = session.GetMyHandle()
    local bufftable = {
        [4022] = true,
        [4023] = true,
        [4024] = true,
        [4021] = true,
        [4087] = true,
        [4136] = true
    }

    local shouldReserveScript = false
    for buffID, _ in pairs(bufftable) do
        local buff = info.GetBuff(myhandle, buffID)
        if buff ~= nil then

            packet.ReqRemoveBuff(buffID)
            shouldReserveScript = true
        end
    end

    if shouldReserveScript then
        ReserveScript(string.format("EASYBUFF_FOODCLEAR()"), 0.3)
    else
        ui.SysMsg("{#FFFFFF}food buffs have disappeared")
        return;
    end
end]]

-- バフ屋

--[[function EASYBUFF_ONBUTTON()
    local frame = ui.GetFrame("buffseller_target");
    local handle = frame:GetUserIValue("HANDLE");
    local groupName = frame:GetUserValue("GROUPNAME");
    local sellType = frame:GetUserIValue("SELLTYPE");
    local cnt = session.autoSeller.GetCount(groupName);
    if cnt == 0 then
        CHAT_SYSTEM("No buff info")
        return;
    end
    EASYBUFF_BUY(handle, sellType, cnt, 0)
end

function EASYBUFF_BUY(handle, sellType, cnt, index)
    if index < cnt then
        session.autoSeller.Buy(handle, index, 1, sellType);
        ReserveScript(string.format("EASYBUFF_BUY(%d, %d, %d, %d)", handle, sellType, cnt, index + 1), 0.6)
    else
        CHAT_SYSTEM("Buff completed");
        EASYBUFF_END()
    end
end

function EASYBUFF_TARGET_BUFF_AUTOSELL_LIST(groupName, sellType, handle)
    base["TARGET_BUFF_AUTOSELL_LIST"](groupName, sellType, handle)
    if g.settings.useHook ~= 1 then
        return;
    end

    local frame = ui.GetFrame("buffseller_target");
    if frame ~= nil then
        local sellType = frame:GetUserIValue("SELL_TYPE");
        if sellType == AUTO_SELL_BUFF then
            EASYBUFF_ONBUTTON()
        end
    end
end

function EASYBUFF_END()
    ui.CloseFrame("buffseller_target");
end]]
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
        -- CHAT_SYSTEM("Buff completed");
        EASYBUFF_END()
    end
end

function EASYBUFF_TARGET_BUFF_AUTOSELL_LIST(groupName, sellType, handle)
    -- base["TARGET_BUFF_AUTOSELL_LIST"](groupName, sellType, handle)
    TARGET_BUFF_AUTOSELL_LIST_OLD(groupName, sellType, handle)
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
function EASYBUFF_ONBUTTON_REPAIR()
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
    -- base["ITEMBUFF_REPAIR_UI_COMMON"](groupName, sellType, handle)
    ITEMBUFF_REPAIR_UI_COMMON_OLD(groupName, sellType, handle)

    if g.settings.useHook ~= 1 then
        return;
    end
    local frame = ui.GetFrame("itembuffrepair");
    if frame ~= nil then
        EASYBUFF_ONBUTTON_REPAIR()
    end
end

-- メンテ屋local function

