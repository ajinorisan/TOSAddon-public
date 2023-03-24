local addonName = "GTSYSMSG"
local addonNameLower = string.lower(addonName)
local author = "norisan"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

g.settingsDirLoc = string.format("../addons/%s", addonNameLower)
g.settingsFileLoc = string.format("%s/settings.json", g.settingsDirLoc)

local acutil = require("acutil")

function GTSYSMSG_ON_INIT(addon, frame)
    CHAT_SYSTEM("GTSYSMSG_ON_INIT")
    g.addon = addon
    g.frame = frame

    if not g.loaded then
        g.loaded = true
    end

    frame:ShowWindow(0)

    acutil.setupHook(GTSYSMSG_ON_MSG, "NOTICE_ON_MSG")
    addon:RegisterMsg('GAME_START_3SEC', 'GTSYSMSG_ON_MSG')
end

function GTSYSMSG_ON_MSG(frame, msg, argStr, argNum)
    GTSYSMSG_ALL(frame, msg, argStr, argNum)
end

function GTSYSMSG_CENTER_MSG(argStr)
    NICO_CHAT(string.format("{@st55_a}%s", argStr))
end

function GTSYSMSG_ALL(frame, msg, argStr, argNum)
    CHAT_SYSTEM(argStr)
    GTSYSMSG_CENTER_MSG(argStr)
end
