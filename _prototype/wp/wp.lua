local addonName = "WP"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "0.0.1"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)

local acutil = require("acutil")

function WP_ON_INIT(addon, frame)
    g.addon = addon
    g.frame = frame
    CHAT_SYSTEM(addonNameLower .. " loaded")
    addon:RegisterMsg("BANDI_CAM", "BANDI_CAM_HIDECHAT");

end

function BANDI_CAM_HIDECHAT_JUDGE(frame, msg, argStr, argNum)
    CHAT_SYSTEM(msg)
    CHAT_SYSTEM(argStr)
    CHAT_SYSTEM(argNum)
    CHAT_SYSTEM("ctframe_hide")
    local ctframe = ui.GetFrame('chatframe')
    if ctframe:IsVisible() == 1 then
        ctframe:ShowWindow(0)
        ReserveScript("BANDI_CAM_HIDECHAT()", 60)
    end

end

function BANDI_CAM_HIDECHAT()
    local frame = ui.GetFrame('chatframe')
    ctframe:ShowWindow(1)
end
