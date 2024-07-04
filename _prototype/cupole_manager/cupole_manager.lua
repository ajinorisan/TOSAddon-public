local addonName = "CUPOLE_MANAGER"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "0.0.1"

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
        -- acutil.setupEvent(addon, "CLOSE_CUPOLE_ITEM", "cupole_manager_CLOSE_CUPOLE_ITEM");

        local cid = info.GetCID(session.GetMyHandle())
        g.personalFileLoc = string.format('../addons/%s/%s.json', addonNameLower, cid)
        cupole_manager_personal_load_settings()
        --[[addon:RegisterMsg('SET_CUPOLE_EXP_UP', 'cupole_manager_msg');
        addon:RegisterMsg('CUPOLE_EQUIP_COMPLELTE', 'cupole_manager_msg');
        addon:RegisterMsg('GACHA_CUPOLE_RESULT', 'cupole_manager_msg');
        addon:RegisterMsg('GACHA_CUPOLE_RESULT', 'cupole_manager_msg');
        addon:RegisterMsg('GACHA_CUPOLE_RESULT', 'cupole_manager_msg');

        addon:RegisterMsg('CUPOLE_ACTIVATE', 'cupole_manager_msg');
        addon:RegisterMsg('TAKE_CUPOLE_RANKUP_ITEM', 'cupole_manager_msg');]]

        -- SET_CUPOLE_SLOTS(frame) 開始時の呼び出し
        -- acutil.setupEvent(addon, "control.SummonPet", "AUTO_PET_SUMMON_RESERVE_COMPANIONLIST");
        -- addon:RegisterMsg("GAME_START_3SEC", "AUTO_PET_SUMMON_LOAD_SETTINGS")
        -- addon:RegisterMsg("GAME_START_3SEC", "AUTO_PET_SUMMON_PET_FRAME_INIT")
    end
end

function cupole_manager_CLOSE_CUPOLE_ITEM(frame, msg)
    local etc = GetMyEtcObject();
    local equipstr = TryGetProp(etc, 'Cupole_Equip', "0;0;0");
    local equip_list = StringSplit(equipstr, ';')
    local cupole_list, cnt = GetClassList("cupole_list");
    for k, v in pairs(equip_list) do
        if v == nil or v == "nil" then
            equip_list[k] = -1

        end
    end
    print(tostring(equip_list[1] .. ":" .. equip_list[2] .. ":" .. equip_list[3]))
    local LoginName = session.GetMySession():GetPCApc():GetName()

    local cupole_list, cnt = GetClassList("cupole_list");
    for i = 1, #equip_list do
        local index = tonumber(equip_list[i])
        local cls = GetClassByIndexFromList(cupole_list, index);
        local ClassName = TryGetProp(cls, "ClassName", "None")
        local ClassID = TryGetProp(cls, "ClassID", 0)
        if g.settings[tostring(i)] ~= nil then
            g.settings[tostring(i)] = {}
        end
        g.settings[tostring(i)] = {
            id = ClassID,
            name = ClassName
        }
        if g.personal[tostring(i)] ~= nil then
            g.personal[tostring(i)] = {}
        end
        g.personal[tostring(i)] = {
            id = ClassID,
            name = ClassName
        }

    end
    cupole_manager_save_settings()
    cupole_manager_personal_save_settings()

end

function cupole_manager_SET_CUPOLE_SLOTS()

    --[[local frame = ui.GetFrame("cupole_item")
    local bg = GET_CHILD_RECURSIVELY_NAME(frame, "managerTab/manageBG/bg")
    local equip_cupole_list

    if g.settings["1"] then

        equip_cupole_list = {g.settings["1"].id - 1, g.settings["2"].id - 1, g.settings["3"].id - 1}
    end
    local SlotBG = GET_CHILD(bg, "SlotBG")
    local gb_slot = GET_CHILD(SlotBG, "gb_slot")
    local cupole_slot_box = gb_slot:CreateOrGetControlSet('cupole_slot', "Main_Cupole_Slot_0", 0, 0);

    cupole_slot_box:SetGravity(ui.CENTER_HORZ, ui.CENTER_VERT)
    local slot_gb = cupole_slot_box:GetChild("gb")

    slot_gb:SetEventScript(ui.LBUTTONUP, "CUPOLE_SLOT_SELECT_BTN")
    cupole_slot_box:SetUserValue("SlotIndex", 0);
    cupole_slot_box:SetUserValue("SEL_CUPOLE_INDEX", -1)
    SET_SLOT_CUPOLE_INFO(cupole_slot_box, tonumber(equip_cupole_list[1]))

    local MiniCnt = 2;
    local ctrler = 1;
    local defx = 15;
    local X = 82;
    local Y = 10;
    local cnt = 1;
    for i = 1, MiniCnt do
        local mini_cupole_slot_box = gb_slot:CreateOrGetControlSet('cupole_mini_slot', "Main_Cupole_Slot_" .. i,
            X * ctrler * cnt + defx * ctrler, Y);
        mini_cupole_slot_box:SetGravity(ui.CENTER_HORZ, ui.CENTER_VERT)
        mini_cupole_slot_box:SetUserValue("SEL_CUPOLE_INDEX", -1)
        if i % 2 == 0 then
            cnt = cnt + 1;
        end
        ctrler = ctrler * -1;
        local gb = mini_cupole_slot_box:GetChild("gb")
        gb:SetEventScript(ui.LBUTTONUP, "CUPOLE_SLOT_SELECT_BTN")
        mini_cupole_slot_box:SetUserValue("SlotIndex", i);

        SET_SLOT_CUPOLE_INFO(mini_cupole_slot_box, tonumber(equip_cupole_list[i + 1]))

    end]]

end

