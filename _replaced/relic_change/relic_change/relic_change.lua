-- v1.0.0 とりあえず公開
local addonName = "RELIC_CHANGE"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.0.0"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)

local acutil = require("acutil")
local os = require("os")

local base = {}

function g.SetupHook(func, baseFuncName)
    local addonUpper = string.upper(addonName)
    local replacementName = addonUpper .. "_BASE_" .. baseFuncName
    if (_G[replacementName] == nil) then
        _G[replacementName] = _G[baseFuncName];
        _G[baseFuncName] = func
    end
    base[baseFuncName] = _G[replacementName]
end

function RELIC_CHANGE_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame
    local pc = GetMyPCObject();
    local curMap = GetZoneName(pc)
    local mapCls = GetClass("Map", curMap)
    if mapCls.MapType == "City" then

        addon:RegisterMsg("GAME_START", "relic_change_frame_init")
        acutil.setupEvent(addon, "RELICMANAGER_SOCKET_UPDATE", "relic_change_RELICMANAGER_SOCKET_UPDATE");
        g.SetupHook(relic_change_RELICMANAGER_SOCKET_GEM_ADD, "RELICMANAGER_SOCKET_GEM_ADD")
    end

end

function relic_change_RELICMANAGER_SOCKET_GEM_ADD(frame, inv_item, item_obj)
    local relic_item, relic_obj = relic_change_RELICMANAGER_GET_EQUIP_RELIC()
    if relic_item == nil or relic_obj == nil then
        ui.SysMsg(ClMsg('NO_EQUIP_RELIC'))
        return
    end

    local group_name = TryGetProp(item_obj, 'GroupName', 'None')
    if group_name ~= 'Gem_Relic' then
        -- 성물 젬이 아닙니다
        ui.SysMsg(ClMsg('NOT_A_RELIC_GEM'))
        return
    end

    local gem_type_str = TryGetProp(item_obj, 'GemType', 'None')
    local gem_type_num = relic_gem_type[gem_type_str]
    if gem_type_num == nil then
        -- 존재하지 않는 성물 젬 타입
        return
    end

    local gem_class_id = relic_item:GetEquipGemID(gem_type_num)
    if gem_class_id ~= 0 then
        -- 이미 다른 젬이 장착되어 있습니다
        ui.SysMsg(ScpArgMsg('RELIC_GEM_EQUIPPED_ALREADY', 'TYPE', ClMsg(gem_type_str)))
        return
    end

    if inv_item.isLockState == true then
        ui.SysMsg(ClMsg('MaterialItemIsLock'))
        return
    end

    session.ResetItemList()
    session.AddItemID(relic_item:GetIESID(), 1)
    session.AddItemID(inv_item:GetIESID(), 1)

    local scp_arg_msg = 'REALLY_EQUIP_RELIC_GEM'
    local team_belong = TryGetProp(item_obj, 'TeamBelonging', 1)
    if team_belong == 0 then
        scp_arg_msg = 'REALLY_EQUIP_RELIC_GEM_IGNORE_BELONGING'
    end

    -- local gem_name = GET_RELIC_GEM_NAME_WITH_FONT(item_obj)
    -- local msg = ScpArgMsg(scp_arg_msg, 'NAME', gem_name)
    -- local yes_scp = '_RELICMANAGER_SOCKET_GEM_ADD()'

    local invItem_Obj = GetIES(inv_item:GetObject())
    local is_char_belonging = TryGetProp(invItem_Obj, "CharacterBelonging", 0)
    if tonumber(is_char_belonging) == 1 then
        frame:SetUserValue('SOCKET_GEM_BELONGING_' .. gem_type_num, is_char_belonging)
    else
        frame:SetUserValue('SOCKET_GEM_BELONGING_' .. gem_type_num, is_char_belonging)
    end
    _RELICMANAGER_SOCKET_GEM_ADD()
    -- local msgbox = ui.MsgBox(msg, yes_scp, 'None')
    -- SET_MODAL_MSGBOX(msgbox)
end

function relic_change_frame_init(frame, msg, argStr, argNum)
    local frame = ui.GetFrame(addonNameLower)
    frame:SetSkinName("None")
    frame:SetTitleBarSkin("None")
    frame:Resize(35, 35)
    frame:SetPos(750, 2)
    frame:SetLayerLevel(10);

    frame:ShowWindow(1)

    local slot = frame:CreateOrGetControl('slot', 'btn', 0, 0, 30, 30)
    AUTO_CAST(slot)
    slot:SetSkinName("None");
    slot:EnablePop(0)
    slot:EnableDrop(0)
    slot:EnableDrag(0)
    slot:SetEventScript(ui.LBUTTONUP, "relic_change_relicmanager_open");

    local itemCls = GetClassByType('Item', 845000)
    local iconImg = GET_ITEM_ICON_IMAGE(itemCls, 'Icon')
    local icon = CreateIcon(slot);
    AUTO_CAST(icon)
    icon:SetTextTooltip("[Relic Change]")
    icon:SetImage(iconImg)
end

function relic_change_RELICMANAGER_GET_EQUIP_RELIC()
    local relic_item = session.GetEquipItemBySpot(item.GetEquipSpotNum('RELIC'))
    local relic_obj = GetIES(relic_item:GetObject())
    if IS_NO_EQUIPITEM(relic_obj) == 1 then
        return
    end

    return relic_item, relic_obj
end

function relic_change_relicmanager_open(frame, ctrl, argStr, argNum)
    local invframe = ui.GetFrame("inventory")
    if invframe:IsVisible() == 0 then
        UI_TOGGLE_INVENTORY()
    end
    local frame = ui.GetFrame("relicmanager")
    frame:ShowWindow(1)
    ui.CloseFrame('rareoption')
    ui.CloseFrame('relic_gem_manager')

    local relic_item, relic_obj = relic_change_RELICMANAGER_GET_EQUIP_RELIC()

    if relic_item == nil or relic_obj == nil then
        ui.SysMsg(ClMsg('NO_EQUIP_RELIC'))
        ui.CloseFrame('relicmanager')
        return
    end

    INVENTORY_SET_CUSTOM_RBTNDOWN('RELICMANAGER_INV_RBTN')

    frame:SetUserValue('RELIC_GUID', relic_item:GetIESID())

    local relic_slot = GET_CHILD_RECURSIVELY(frame, 'relic_slot')
    SET_SLOT_ITEM(relic_slot, relic_item)

    frame:SetUserValue('last_tab_index', 2)
    relic_change_tab_change(frame)
end

function relic_change_tab_change(frame)
    -- local frame = ui.GetFrame("relicmanager")
    local tab = GET_CHILD_RECURSIVELY(frame, 'type_Tab')
    local index = 0
    if tab ~= nil then
        tab:SelectTab(2)
        index = tab:GetSelectItemIndex()
    end
    RELICMANAGER_SOCKET_UPDATE(frame)
end

function relic_change_RELICMANAGER_SOCKET_UPDATE(frame, msg)
    local frame = ui.GetFrame("relicmanager")
    for i = 0, 2 do
        local sub_ctrl = GET_CHILD_RECURSIVELY(frame, 'cset_' .. i)
        local do_remove = GET_CHILD_RECURSIVELY(sub_ctrl, 'do_remove', 'ui::CButton')
        do_remove:SetText("{ol}exchange")
        do_remove:SetTextTooltip("{ol}relicgem exchange")
        do_remove:SetEventScript(ui.LBUTTONUP, "relic_change_exchange")
        do_remove:SetEventScriptArgString(ui.LBUTTONUP, sub_ctrl:GetName());

    end
end

function relic_change_exchange(frame, ctrl, argStr, argNum)
    local frame = ui.GetFrame("relicmanager")
    local ctrlset = GET_CHILD_RECURSIVELY(frame, argStr)

    local gem_type = ctrlset:GetUserIValue('GEM_TYPE')
    print(tostring(gem_type))
    RELICMANAGER_SOCKET_GEM_REMOVE(gem_type)

    local invframe = ui.GetFrame("inventory")
    local invtab = GET_CHILD_RECURSIVELY(invframe, "inventype_Tab")
    invtab:SelectTab(6)

end
