local addonName = "ANCIENT_AUTOSET"
local addonNameLower = string.lower(addonName)
local author = "norisan"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)

local acutil = require("acutil")

-- print("5")

-- フレームの位置と表示

function ANCIENT_AUTOSET_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame

    CHAT_SYSTEM(addonNameLower .. " loaded")
    -- addon:RegisterMsg("BANDI_CAM", "HIDE_CHATFRAME_ON_BANDI_CAM")
    -- acutil.setupHook(HIDE_CHATFRAME_ON_BANDI_CAM, "ON_BANDI_CAM")

end

