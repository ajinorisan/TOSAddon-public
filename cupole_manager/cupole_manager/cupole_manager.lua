local addonName = "CUPOLE_MANAGER"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.0.0"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

local acutil = require("acutil")
local json = require('json')
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

-- JSONファイルのパスをフォーマット
g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)

function cupole_manager_load_settings()

    local settings, err = acutil.loadJSON(g.settingsFileLoc, g.settings)

    if err then
        -- 設定ファイル読み込み失敗時処理
        -- CHAT_SYSTEM(string.format("[%s] cannot load setting files", addonNameLower))
    end

    if not settings then

        settings = {}

    end
    g.settings = settings
    cupole_manager_save_settings()
end

function cupole_manager_save_settings()

    acutil.saveJSON(g.settingsFileLoc, g.settings);

end

function cupole_manager_personal_load_settings()

    local settings, err = acutil.loadJSON(g.settingsFileLoc)

    if err then
        -- 設定ファイル読み込み失敗時処理
        -- CHAT_SYSTEM(string.format("[%s] cannot load setting files", addonNameLower))
    end

    if not settings then

        settings = {}

    end
    g.personal = settings
    cupole_manager_personal_save_settings()
end

function cupole_manager_personal_save_settings()

    acutil.saveJSON(g.personalFileLoc, g.personal);

end

function CUPOLE_MANAGER_ON_INIT(addon, frame)
    g.addon = addon
    g.frame = frame
    g.settings = g.settings or {}

    local pc = GetMyPCObject();
    local curMap = GetZoneName(pc)
    local mapCls = GetClass("Map", curMap)

    if mapCls.MapType == "City" then
        cupole_manager_load_settings()
        addon:RegisterMsg('GAME_START', 'cupole_manager_SET_CUPOLE_SLOTS');
        local cid = info.GetCID(session.GetMyHandle())
        g.personalFileLoc = string.format('../addons/%s/%s.json', addonNameLower, cid)
        cupole_manager_personal_load_settings()
        acutil.setupEvent(addon, "CLOSE_CUPOLE_ITEM", "cupole_manager_CLOSE_CUPOLE_ITEM");

    end
end

function cupole_manager_CLOSE_CUPOLE_ITEM(frame, msg)
    local equip_cupole_list = GET_EQUIP_CUPOLE_LIST()

    for i = 1, 3 do
        local cupole_cls = GET_CUPOLE_BY_INDEX_IN_CLASSLIST(equip_cupole_list[i]);
        local CupoleClassName = TryGetProp(cupole_cls, "ClassName", "None");

        g.settings[tostring(i)] = {
            id = equip_cupole_list[i],
            name = CupoleClassName
        }
    end
    cupole_manager_save_settings()
end

function cupole_manager_SET_CUPOLE_SLOTS(frame)

    local frame = ui.GetFrame("cupole_item")
    local bg = GET_CHILD_RECURSIVELY_NAME(frame, "managerTab/manageBG/bg")
    local equip_cupole_list

    if g.settings then
        equip_cupole_list = {g.settings["1"].id, g.settings["2"].id, g.settings["3"].id}
    else
        return
    end

    if equip_cupole_list[1] == "-1" then

        return;
    end

    local SlotBG = GET_CHILD(bg, "SlotBG")
    local gb_slot = GET_CHILD(SlotBG, "gb_slot")

    local list_index = tonumber(equip_cupole_list[1])

    local cupole_slot_box = gb_slot:CreateOrGetControlSet('cupole_slot', "Main_Cupole_Slot_0", 0, 0);
    AUTO_CAST(cupole_slot_box)
    SET_SLOT_CUPOLE_INFO(cupole_slot_box, -1)
    cupole_slot_box:SetGravity(ui.CENTER_HORZ, ui.CENTER_VERT)

    local slot_gb = cupole_slot_box:GetChild("gb")

    slot_gb:SetEventScript(ui.LBUTTONUP, "CUPOLE_SLOT_SELECT_BTN")
    cupole_slot_box:SetUserValue("SlotIndex", 0);
    cupole_slot_box:SetUserValue("SEL_CUPOLE_INDEX", list_index)

    SUMMON_SELECT_LEFT_CUPOLE_SLOT(cupole_slot_box, list_index)

    for i = 1, 2 do

        list_index = tonumber(equip_cupole_list[i + 1])
        ReserveScript(
            string.format("cupole_manager_mini_SET_CUPOLE_SLOTS('%s',%d,%d)", gb_slot:GetName(), list_index, i), i)
    end

end

function cupole_manager_mini_SET_CUPOLE_SLOTS(gb_slot, list_index, i)

    local X = 97
    if i == 2 then
        X = 15
    end
    local frame = ui.GetFrame("cupole_item")
    local gb_slot = GET_CHILD_RECURSIVELY(frame, gb_slot)

    local mini_cupole_slot_box = gb_slot:CreateOrGetControlSet('cupole_mini_slot', "Main_Cupole_Slot_" .. i, X, 10)
    AUTO_CAST(mini_cupole_slot_box)
    SET_SLOT_CUPOLE_INFO(mini_cupole_slot_box, -1)
    mini_cupole_slot_box:SetGravity(ui.CENTER_HORZ, ui.CENTER_VERT)
    local gb = mini_cupole_slot_box:GetChild("gb")

    gb:SetEventScript(ui.LBUTTONUP, "CUPOLE_SLOT_SELECT_BTN")
    mini_cupole_slot_box:SetUserValue("SlotIndex", i);
    mini_cupole_slot_box:SetUserValue("SEL_CUPOLE_INDEX", list_index)

    SUMMON_SELECT_LEFT_CUPOLE_SLOT(mini_cupole_slot_box, list_index)
end

