-- v1.0.0 レイド毎に憤怒ポーション切替
-- v1.0.1 加護ポーションも対応
-- v1.0.2 クイックスロットがセーブされてなくてレイドで元のポーションに戻る場合があるので、MAPに入った時に動かす様に修正
-- v1.0.3 レイド選んだ時と中でももう1回チェックのハイブリッドに。
-- v1.0.4 加護ポ持ってない時に切り替わらないバグ修正。
-- v1.0.5 メレジナ野獣になってたの悪魔に修正。
-- v1.0.6 コード見直し
-- v1.0.7 クイックスロットにアイコン入ってたら変わる様に設定。今回は失敗しないハズ。
local addonName = "quickslot_operate"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.0.7"

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
    Velnias = {689, 688, 690, 669, 635, 628, 696, 695, 697},
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

local down_potion_list = {
    Velnias = 640373,
    Klaida = 640375,
    Paramune = 640374,
    Widling = 640377,
    Forester = 640376
}

local zone_list = {"raid_Rosethemisterable", "raid_castle_ep14_2", "Raid_DreamyForest", "Raid_AbyssalObserver",
                   "raid_Jellyzele", "raId_castle_ep14", "raid_giltine_AutoGuild", "raid_dcapital_108",
                   "raid_kivotos_island"}

-- raid_Rosethemisterable roze
-- raid_castle_ep14_2 ファロプロゲ
-- Raid_DreamyForest　蝶々
-- Raid_AbyssalObserver　スロガ
-- raid_Jellyzele　クラゲ
-- raId_castle_ep14　デルムーア
-- raid_giltine_AutoGuild　ギルティネ
-- raid_dcapital_108　レジェンドギルティネ

function QUICKSLOT_OPERATE_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame

    acutil.setupEvent(addon, "SHOW_INDUNENTER_DIALOG", "quickslot_operate_SHOW_INDUNENTER_DIALOG");

    local currentZone = GetZoneName()

    for _, zone in ipairs(zone_list) do
        if zone == currentZone then
            ReserveScript("quickslot_operate_change_potion()", 6.0)
            break
        end

    end

end

function quickslot_operate_change_potion()

    local group_name = quickslot_operate_GetGroupName(tonumber(g.induntype))
    g.induntype = 0

    local potion_id = potion_list[group_name]
    local down_potion_id = down_potion_list[group_name]

    quickslot_operate_get_potion(potion_id, down_potion_id)
end

function quickslot_operate_SHOW_INDUNENTER_DIALOG()
    local frame = ui.GetFrame('indunenter')
    local induntype = tonumber(frame:GetUserValue("INDUN_TYPE")) -- Ensure it's a number

    local group_name = quickslot_operate_GetGroupName(induntype)

    local potion_id = potion_list[group_name]

    local down_potion_id = down_potion_list[group_name]

    if potion_id ~= nil or down_potion_id ~= nil then

        ReserveScript(string.format("quickslot_operate_get_potion(%d, %d)", potion_id, down_potion_id), 0.5)

    end
end

function quickslot_operate_GetGroupName(induntype)
    for group, indun_list in pairs(raid_list) do
        for _, indun_id in ipairs(indun_list) do
            if indun_id == induntype then
                -- print(indun_id .. ":" .. type(indun_id))
                g.induntype = indun_id
                return group
            end
        end
    end
    return
end

function quickslot_operate_get_potion(potion_id, down_potion_id)
    -- print(potion_id .. ":" .. down_potion_id)
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

            quickslot_operate_check_all_slots(potion_id, down_potion_id)
            session.ResetItemList()

            -- return
        end
        -- 
    end

end

function quickslot_operate_check_all_slots(potion_id, down_potion_id)

    local frame = ui.GetFrame("quickslotnexpbar")
    if not frame then
        return
    end

    --[[local potion_info = session.GetInvItemByType(potion_id);
    if potion_info ~= nil then

        local potion_item = GET_PC_ITEM_BY_GUID(potion_info:GetIESID())
        local potion_obj = GetIES(potion_item:GetObject())
    end

    local down_potion_info = session.GetInvItemByType(down_potion_id);
    if down_potion_info ~= nil then

        local down_potion_item = GET_PC_ITEM_BY_GUID(down_potion_info:GetIESID())
        local down_potion_obj = GetIES(down_potion_item:GetObject())
    end]]
    local slotCount = 40

    for i = 0, slotCount - 1 do
        local slot = tolua.cast(frame:GetChildRecursively("slot" .. i + 1), "ui::CSlot")
        -- AUTO_CAST(slot)
        local quickSlotInfo = quickslot.GetInfoByIndex(i);

        local icon = slot:GetIcon()
        if icon ~= nil then
            local iconinfo = icon:GetInfo()

            local classid = iconinfo.type

            for group, id in pairs(potion_list) do
                if id == classid then
                    local potion_iesid = iconinfo:GetIESID()
                    SET_QUICK_SLOT(frame, slot, quickSlotInfo.category, potion_id, _, 0, true, true)
                    icon:SetDumpArgNum(i);
                    break

                end
            end

            for group, id in pairs(down_potion_list) do
                if id == classid then
                    local down_potion_iesid = iconinfo:GetIESID()
                    SET_QUICK_SLOT(frame, slot, quickSlotInfo.category, down_potion_id, _, 0, true, true)
                    icon:SetDumpArgNum(i);
                    break

                end
            end

        end
    end

end
