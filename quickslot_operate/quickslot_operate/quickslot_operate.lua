-- v1.0.0 レイド毎に憤怒ポーション切替
local addonName = "quickslot_operate"
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
local json = require("json")

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

local raid_list = {
    Paramune = {623, 667, 666, 665, 674, 673, 675, 680, 679, 681},
    Klaida = {686, 685, 687},
    Velnias = {689, 688, 690, 669, 635, 628},
    Forester = {672, 671, 670},
    Widling = {677, 676, 678}
}

local potion_list = {
    Velnias = 640504,
    Klaida = 640503,
    Paramune = 640502,
    Widling = 640501,
    Forester = 640500
}

function QUICKSLOT_OPERATE_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame

    acutil.setupEvent(addon, "SHOW_INDUNENTER_DIALOG", "test_norisan_SHOW_INDUNENTER_DIALOG");

end

function quickslot_operate_SHOW_INDUNENTER_DIALOG()
    local frame = ui.GetFrame('indunenter')
    local induntype = tonumber(frame:GetUserValue("INDUN_TYPE")) -- Ensure it's a number

    local group_name = quickslot_operate_GetGroupName(induntype)

    local potion_id = potion_list[group_name]
    if potion_id then

        quickslot_operate_get_potion(potion_id)

    end
end

function quickslot_operate_GetGroupName(induntype)
    for group, indun_list in pairs(raid_list) do
        for _, indun_id in ipairs(indun_list) do
            if indun_id == induntype then
                return group
            end
        end
    end
    return
end

function quickslot_operate_get_potion(potion_id)
    -- local iteminfo = session.GetInvItemByType(potion_id);

    local invItemList = session.GetInvItemList()
    local guidList = invItemList:GetGuidList();
    local cnt = guidList:Count();

    for i = 0, cnt - 1 do
        local guid = guidList:Get(i);
        local invItem = invItemList:GetItemByGuid(guid)
        local itemobj = GetIES(invItem:GetObject())
        local iesid = invItem:GetIESID()

        if tostring(itemobj.ClassID) == tostring(potion_id) then
            local frame = ui.GetFrame("inventory");
            local slot = GET_CHILD_RECURSIVELY(frame, "slot" .. i + 1, "ui::CSlot")

            quickslot_operate_check_all_slots(potion_id)
            session.ResetItemList()

            return
        end
        -- 
    end

end

function quickslot_operate_check_all_slots(potion_id)

    local potion_info = session.GetInvItemByType(potion_id);
    local potion_iesid = potion_info:GetIESID()
    local potion_item = GET_PC_ITEM_BY_GUID(potion_info:GetIESID())
    local potion_obj = GetIES(potion_item:GetObject())
    -- print(tostring(potion_obj.ClassName))

    local frame = ui.GetFrame("quickslotnexpbar")
    if not frame then
        return
    end

    local slotCount = 40

    for i = 0, slotCount - 1 do
        local slot = tolua.cast(frame:GetChildRecursively("slot" .. i + 1), "ui::CSlot")
        local quickSlotInfo = quickslot.GetInfoByIndex(i);
        if slot and slot:GetIcon() then
            local iconInfo = slot:GetIcon():GetInfo()
            local invItem = GET_PC_ITEM_BY_GUID(iconInfo:GetIESID())
            if invItem then
                local obj = GetIES(invItem:GetObject())
                local classid = obj.ClassID

                for group, id in pairs(potion_list) do
                    if id == classid then

                        SET_QUICK_SLOT(frame, slot, quickSlotInfo.category, potion_id, potion_iesid, 0, true, true)

                        return

                    end
                end
            end
        end
    end

end
