local addonName = "CUPOLE_MANAGER"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "0.0.1"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

local acutil = require("acutil")

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

local folder_path = string.format("../addons/%s/", addonNameLower)
local result = os.execute("mkdir " .. folder_path)
if result == 0 then
    print("Folder created successfully.")
else
    print("Failed to create folder with error code: " .. result)
end

-- JSONファイルのパスをフォーマット
g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)
print("Settings file location: " .. g.settingsFileLoc)

function CUPOLE_MANAGER_ON_INIT(addon, frame)
    g.addon = addon
    g.frame = frame
    g.settings = g.settings or {}

    local pc = GetMyPCObject();
    local curMap = GetZoneName(pc)
    local mapCls = GetClass("Map", curMap)

    if mapCls.MapType == "City" then
        addon:RegisterMsg('SET_CUPOLE_EXP_UP', 'cupole_manager_msg');
        addon:RegisterMsg('CUPOLE_EQUIP_COMPLELTE', 'cupole_manager_msg');
        addon:RegisterMsg('GACHA_CUPOLE_RESULT', 'cupole_manager_msg');
        addon:RegisterMsg('GACHA_CUPOLE_RESULT', 'cupole_manager_msg');
        addon:RegisterMsg('GACHA_CUPOLE_RESULT', 'cupole_manager_msg');

        addon:RegisterMsg('CUPOLE_ACTIVATE', 'cupole_manager_msg');
        addon:RegisterMsg('TAKE_CUPOLE_RANKUP_ITEM', 'cupole_manager_msg');
        -- SET_CUPOLE_SLOTS(frame) 開始時の呼び出し
        -- acutil.setupEvent(addon, "control.SummonPet", "AUTO_PET_SUMMON_RESERVE_COMPANIONLIST");
        -- addon:RegisterMsg("GAME_START_3SEC", "AUTO_PET_SUMMON_LOAD_SETTINGS")
        -- addon:RegisterMsg("GAME_START_3SEC", "AUTO_PET_SUMMON_PET_FRAME_INIT")
    end
end

function cupole_manager_msg(frame, msg, argStr, argNum)
    print(tostring(msg))
end

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

