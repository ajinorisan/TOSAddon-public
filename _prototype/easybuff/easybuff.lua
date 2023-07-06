-- v2.0.2 変数スコープの見直し、メンテの挙動見直し
local addonName = "EASYBUFF"
local addonNameLower = string.lower(addonName)
local author = "Kiicchan"
local version = "2.0.2"

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

local acutil = require("acutil");

function EASYBUFF_ON_INIT(addon, frame)
    CHAT_SYSTEM(addonNameLower .. " loaded")
    frame:ShowWindow(1);

    if not g.loaded then
        local t, err = acutil.loadJSON(g.settingsFileLoc, g.settings);
        if err then
            -- 設定ファイル読み込み失敗時処理
            CHAT_SYSTEM(string.format("[%s] cannot load setting files", addonName))
        else
            -- 設定ファイル読み込み成功時処理
            g.settings = t;
        end
        g.loaded = true
    end

    EASYBUFF_SAVESETTINGS();

    addon:RegisterMsg("GAME_START_3SEC", "EASYBUFF_BUFFSELLER_TARGET_INIT")
    acutil.setupHook(EASYBUFF_HOOK_CLICK, "TARGET_BUFF_AUTOSELL_LIST")
    acutil.setupHook(EASYBUFF_HOOK_CLICK_FOOD, "OPEN_FOOD_TABLE_UI")
    acutil.setupHook(EASYBUFF_HOOK_CLICK_REPAIR, "ITEMBUFF_REPAIR_UI_COMMON")
    acutil.setupHook(EASYBUFF_SQUIRE_BUFF_EQUIP_CTRL, "SQUIRE_BUFF_EQUIP_CTRL")
    -- acutil.setupHook(EASYBUFF_TEST, "SQUIRE_BUFF_EQUIP_SELECT_ALL")
    acutil.slashCommand("/easybuff", EASYBUFF_CMD);
    acutil.slashCommand("/esbf", EASYBUFF_CMD);
end

function EASYBUFF_BUFFSELLER_TARGET_INIT()

    local frame = ui.GetFrame("foodtable_ui")
    local btn = frame:CreateOrGetControl("button", "clearfood", 10, 50, 80, 30)
    btn:SetSkinName("test_red_button")
    btn:SetText("{ol}foodclear")
    btn:SetEventScript(ui.LBUTTONUP, "EASYBUFF_FOODCLEAR")

    local btn2 = frame:CreateOrGetControl("button", "myButton2", 140, 50, 80, 30)
    btn2:SetText("{ol}4foodonly")
    btn2:SetEventScript(ui.LBUTTONUP, "EASYBUFF_4FOODONLY")

    local btn3 = frame:CreateOrGetControl("button", "myButton3", 240, 50, 80, 30)
    btn3:SetText("{ol}5foodonly")
    btn3:SetEventScript(ui.LBUTTONUP, "EASYBUFF_5FOODONLY")

    local btn4 = frame:CreateOrGetControl("button", "myButton4", 340, 50, 80, 30)
    btn4:SetText("{ol}allfood")
    btn4:SetEventScript(ui.LBUTTONUP, "EASYBUFF_ALLFOOD")

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

-- local enable_slot_list = {"RH", "LH", "RH_SUB", "LH_SUB", "SHIRT", "PANTS", "GLOVES", "BOOTS"}

local enable_slot_list = {'RH', 'LH', 'RH_SUB', 'LH_SUB', 'SHIRT', 'PANTS', 'GLOVES', 'BOOTS'}

function EASYBUFF_SQUIRE_BUFF_EQUIP_CTRL(frame)

    local frame = ui.GetFrame("itembuffopen")

    local ctrlGbox = GET_CHILD_RECURSIVELY(frame, 'ctrlGbox')
    ctrlGbox:RemoveAllChild()

    local checkall = GET_CHILD_RECURSIVELY(frame, 'checkall')
    checkall:SetCheck(1)

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
                    time:ShowWindow(1)
                    local timestr = GET_CHILD_RECURSIVELY(ctrlset, 'timestr')
                    timestr:ShowWindow(1)

                    index = index + 1
                end
            end
        end
    end

    SQUIRE_BUFF_COST_UPDATE(frame)

end

function EASYBUFF_SQUIRE_BUFF_EXCUTE()
    -- CHAT_SYSTEM("test")
    -- local enable_slot_list = {"RH", "LH", "RH_SUB", "LH_SUB", "SHIRT", "PANTS", "GLOVES", "BOOTS"}
    local frame = ui.GetFrame("itembuffopen")

    -- local checkall = GET_CHILD_RECURSIVELY(frame, "checkall")
    -- checkall:SetCheck(1)
    -- SQUIRE_BUFF_EQUIP_SELECT_ALL(frame, checkall)
    local handle = frame:GetUserValue("HANDLE")
    local skillName = frame:GetUserValue("SKILLNAME")

    session.ResetItemList()

    local cnt = 0
    for i = 1, #enable_slot_list do
        local slot_name = enable_slot_list[i]
        local ctrlset = GET_CHILD_RECURSIVELY(frame, "ITEMBUFF_CTRL_" .. slot_name)
        if ctrlset ~= nil then
            local checkbox = GET_CHILD(ctrlset, "checkbox")
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

    -- frame:ShowWindow(0)
    ui.SysMsg("{#FFFFFF}Equipment Maintenance in progress.")
    ui.SysMsg("{#FFFFFF}To cancel, use the Cancel button.")
    ui.SysMsg("{#FFFFFF}装備メンテナンス中 キャンセルは取消ボタンで!")

    session.autoSeller.BuyItems(handle, AUTO_SELL_SQUIRE_BUFF, session.GetItemIDList(), skillName)

    -- SQUIRE_BUFF_EQUIP_CTRL(frame)
    -- ReserveScript(string.format(EASYBUFF_SQUIRE_BUFF_EQUIP_SELECT_ALL()), 0.5)
    ReserveScript(string.format("SQUIRE_TARGET_UI_CLOSE()"), 5.5)
end

-- フード処理
function EASYBUFF_HOOK_CLICK_FOOD(groupName, sellType, handle, sellerCID, arg_num)
    OPEN_FOOD_TABLE_UI_OLD(groupName, sellType, handle, sellerCID, arg_num)

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

end

function EASYBUFF_4FOODONLY()
    local frame = ui.GetFrame("foodtable_ui")
    local handle = frame:GetUserIValue("HANDLE");
    local sellType = frame:GetUserIValue("SELLTYPE");

    if g.foodIndex < 4 then
        session.autoSeller.Buy(handle, g.foodIndex, 1, sellType);
        g.foodIndex = g.foodIndex + 1;
        ReserveScript(string.format("EASYBUFF_4FOODONLY()"), 0.5)
    else
        -- g.foodIndex = 0
        ReserveScript(string.format("EASYBUFF_END_FOOD()"), 0.3)
    end
end

function EASYBUFF_5FOODONLY()
    local frame = ui.GetFrame("foodtable_ui")
    local handle = frame:GetUserIValue("HANDLE");
    local sellType = frame:GetUserIValue("SELLTYPE");

    if g.foodIndex < 5 then
        session.autoSeller.Buy(handle, g.foodIndex, 1, sellType);
        g.foodIndex = g.foodIndex + 1;
        ReserveScript(string.format("EASYBUFF_5FOODONLY()"), 0.5)
    else
        ReserveScript(string.format("EASYBUFF_END_FOOD()"), 0.3)
    end
end

function EASYBUFF_ALLFOOD()
    local frame = ui.GetFrame("foodtable_ui")
    local handle = frame:GetUserIValue("HANDLE");
    local sellType = frame:GetUserIValue("SELLTYPE");

    if g.foodIndex <= 5 then
        session.autoSeller.Buy(handle, g.foodIndex, 1, sellType);
        g.foodIndex = g.foodIndex + 1;
        ReserveScript(string.format("EASYBUFF_ALLFOOD()"), 0.5)
    else
        ReserveScript(string.format("EASYBUFF_END_FOOD()"), 0.3)
    end
end

function EASYBUFF_END_FOOD()
    g.foodIndex = 0;
    ui.CloseFrame("foodtable_ui");
end

function EASYBUFF_FOODCLEAR()
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
end

-- バフ屋
function EASYBUFF_ONBUTTON()
    local frame = ui.GetFrame("buffseller_target");
    local handle = frame:GetUserIValue("HANDLE");
    local groupName = frame:GetUserValue("GROUPNAME");
    local sellType = frame:GetUserIValue("SELLTYPE");
    local cnt = session.autoSeller.GetCount(groupName);
    local itemInfo = session.autoSeller.GetByIndex(groupName, 0);
    if itemInfo == nil then
        CHAT_SYSTEM("No buff info")
        return;
    end
    g.buffIndex = 0;
    ReserveScript(string.format("EASYBUFF_BUY(%d, %d, %d)", handle, sellType, cnt), 0.5)
end

function EASYBUFF_BUY(handle, sellType, cnt)
    if g.buffIndex < cnt then
        session.autoSeller.Buy(handle, g.buffIndex, 1, sellType);
        g.buffIndex = g.buffIndex + 1;
        ReserveScript(string.format("EASYBUFF_BUY(%d, %d, %d)", handle, sellType, cnt), 0.5)
    else
        CHAT_SYSTEM("Buff completed");
        ReserveScript("EASYBUFF_END()", 0.3)
    end
end

function EASYBUFF_HOOK_CLICK(groupName, sellType, handle)
    TARGET_BUFF_AUTOSELL_LIST_OLD(groupName, sellType, handle)
    if g.settings.useHook ~= 1 then
        return;
    end

    local frame = ui.GetFrame("buffseller_target");
    if frame ~= nil then
        local sellType = frame:GetUserIValue("SELL_TYPE");
        if sellType == AUTO_SELL_BUFF and g.buffIndex == 0 then
            EASYBUFF_ONBUTTON()
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

function EASYBUFF_HOOK_CLICK_REPAIR(groupName, sellType, handle)
    ITEMBUFF_REPAIR_UI_COMMON_OLD(groupName, sellType, handle)
    if g.settings.useHook ~= 1 then
        return;
    end
    local frame = ui.GetFrame("itembuffrepair");
    if frame ~= nil then
        EASYBUFF_ONBUTTON_REPAIR()
    end
end

-- メンテ用

local function _GET_SOCKET_ADD_VALUE(item, invItem, i)
    if invItem:IsAvailableSocket(i) == false then
        return
    end

    local gem = invItem:GetEquipGemID(i)
    if gem == 0 then
        return
    end

    local gemExp = invItem:GetEquipGemExp(i)
    local roastingLv = invItem:GetEquipGemRoastingLv(i)
    local props = {}
    local gemclass = GetClassByType("Item", gem)
    local lv = GET_ITEM_LEVEL_EXP(gemclass, gemExp)
    local prop = geItemTable.GetProp(gem)
    local socketProp = prop:GetSocketPropertyByLevel(lv)
    local type = item.ClassID
    local benefitCnt = socketProp:GetPropCountByType(type)
    for i = 0, benefitCnt - 1 do
        local benefitProp = socketProp:GetPropAddByType(type, i)
        props[#props + 1] = {benefitProp:GetPropName(), benefitProp.value}
    end

    local penaltyCnt = socketProp:GetPropPenaltyCountByType(type)
    local penaltyLv = lv - roastingLv
    if 0 > penaltyLv then
        penaltyLv = 0
    end
    local socketPenaltyProp = prop:GetSocketPropertyByLevel(penaltyLv)
    for i = 0, penaltyCnt - 1 do
        local penaltyProp = socketPenaltyProp:GetPropPenaltyAddByType(type, i)
        local value = penaltyProp.value
        penaltyProp:GetPropName()
        props[#props + 1] = {penaltyProp:GetPropName(), penaltyProp.value}
    end
    return props
end

local function _GET_ITEM_SOCKET_ADD_VALUE(targetPropName, item)
    local invItem, where = GET_INV_ITEM_BY_ITEM_OBJ(item)
    if invItem == nil then
        return 0
    end

    local value = 0
    local sockets = {}
    if item.MaxSocket > 100 then
        item.MaxSocket = 0
    end
    for i = 0, item.MaxSocket - 1 do
        sockets[#sockets + 1] = _GET_SOCKET_ADD_VALUE(item, invItem, i)
    end

    for i = 1, #sockets do
        local props = sockets[i]
        for j = 1, #props do
            local prop = props[j]
            if prop[1] == targetPropName or ((prop[1] == "PATK") and (targetPropName == "ATK")) then
                value = value + prop[2]
            end
        end
    end
    return value
end

local function SQUIRE_BUFF_ENABLE_ITEM_CHECK(frame, inv_item, item_obj)
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

local function MAKE_SQUIRE_BUFF_CTRL_OPTION(frame, gbox, inv_item, item_obj)
    CHAT_SYSTEM("test3")
    local pc = GetMyPCObject()
    local checkFunc = _G["ITEMBUFF_NEEDITEM_" .. frame:GetUserValue("SKILLNAME")]
    local name, cnt = checkFunc(pc, item_obj)

    local skillLevel = frame:GetUserIValue("SKILLLEVEL")
    local valueFunc = _G["ITEMBUFF_VALUE_" .. frame:GetUserValue("SKILLNAME")]
    local value, validSec = valueFunc(pc, item_obj, skillLevel)

    local parentbox = gbox:GetParent()
    local time = GET_CHILD_RECURSIVELY(parentbox, 'time')
    time:ShowWindow(1)
    local timestr = GET_CHILD_RECURSIVELY(parentbox, "timestr")
    timestr:ShowWindow(1)
    timestr:SetTextByKey("txt", string.format("{img %s %d %d}", "squaier_buff", 25, 25) .. " " .. validSec / 3600 ..
        ClMsg("QuestReenterTimeH"))

    local nextObj = CloneIES(item_obj)
    nextObj.BuffValue = value
    local refreshScp = nextObj.RefreshScp
    if refreshScp ~= "None" then
        refreshScp = _G[refreshScp]
        refreshScp(nextObj)
    end

    local basicPropList = StringSplit(item_obj.BasicTooltipProp, ';')
    for i = 1, #basicPropList do
        local basicTooltipProp = basicPropList[i]
        local propertyCtrl = gbox:CreateOrGetControlSet('basic_property_set_narrow', 'BASIC_PROP_' .. i, 5, 0)

        -- 최대, 최소를 작성하고자 해당 항목의 속성을 가지고 옵니다.
        local mintextStr = GET_CHILD(propertyCtrl, "minPowerStr")
        local maxtextStr = GET_CHILD(propertyCtrl, "maxPowerStr")
        local maxtext = GET_CHILD(propertyCtrl, "maxPower")
        local mintext = GET_CHILD(propertyCtrl, "minPower")

        local prop1, prop2 = GET_ITEM_PROPERT_STR(item_obj, basicTooltipProp)
        if basicTooltipProp ~= "ATK" then
            local temp = prop1
            prop1 = prop2
            prop2 = temp
        end

        maxtextStr:SetTextByKey("txt", prop1)
        mintextStr:SetTextByKey("txt", prop2)

        if item_obj.GroupName == "Weapon" or item_obj.GroupName == "SubWeapon" then
            if basicTooltipProp == "ATK" then -- 최대, 최소 공격력
                local socketaddvalue = _GET_ITEM_SOCKET_ADD_VALUE(basicTooltipProp, item_obj)
                maxtext:SetTextByKey("txt", item_obj.MAXATK + socketaddvalue .. " > " .. nextObj.MAXATK + socketaddvalue)
                mintext:SetTextByKey("txt", item_obj.MINATK + socketaddvalue .. " > " .. nextObj.MINATK + socketaddvalue)
            elseif basicTooltipProp == "MATK" then -- 마법공격력
                local socketaddvalue = _GET_ITEM_SOCKET_ADD_VALUE(basicTooltipProp, item_obj)
                mintext:SetTextByKey("txt", item_obj.MATK - socketaddvalue .. " > " .. nextObj.MATK + socketaddvalue)
                maxtext:SetTextByKey("txt", "")
                propertyCtrl:Resize(propertyCtrl:GetWidth(), mintext:GetHeight())
            end
        else
            if basicTooltipProp == "DEF" then -- 방어
                local socketaddvalue = _GET_ITEM_SOCKET_ADD_VALUE(basicTooltipProp, item_obj)
                mintext:SetTextByKey("txt", item_obj.DEF - socketaddvalue .. " > " .. nextObj.DEF + socketaddvalue)
            elseif basicTooltipProp == "MDEF" then -- 악세사리
                local socketaddvalue = _GET_ITEM_SOCKET_ADD_VALUE(basicTooltipProp, item_obj)
                mintext:SetTextByKey("txt", item_obj.MDEF - socketaddvalue .. " > " .. nextObj.MDEF + socketaddvalue)
            elseif basicTooltipProp == "HR" then -- 명중
                mintext:SetTextByKey("txt", item_obj.HR .. " > " .. nextObj.HR)
            elseif basicTooltipProp == "DR" then -- 회피
                mintext:SetTextByKey("txt", item_obj.DR .. " > " .. nextObj.DR)
            elseif basicTooltipProp == "CRTMATK" then -- 마법관통
                mintext:SetTextByKey("txt", item_obj.CRTMATK .. " > " .. nextObj.CRTMATK)
            elseif basicTooltipProp == "ADD_FIRE" then -- 화염
                mintext:SetTextByKey("txt", item_obj.FIRE .. " > " .. nextObj.FIRE)
            elseif basicTooltipProp == "ADD_ICE" then -- 빙한
                mintext:SetTextByKey("txt", item_obj.ICE .. " > " .. nextObj.ICE)
            elseif basicTooltipProp == "ADD_LIGHTNING" then -- 전격
                mintext:SetTextByKey("txt", item_obj.LIGHTNING .. " > " .. nextObj.LIGHTNING)
            end

            maxtext:SetTextByKey("txt", "")
            propertyCtrl:Resize(propertyCtrl:GetWidth(), mintext:GetHeight())
        end
    end

    GBOX_AUTO_ALIGN(gbox, 5, 2, 0, true, false, true)
    DestroyIES(nextObj)
end

local function SQUIRE_BUFF_ENABLE_ITEM_CHECK(frame, inv_item, item_obj)
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
