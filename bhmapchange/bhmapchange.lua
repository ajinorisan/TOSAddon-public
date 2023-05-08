local addonName = "BHMAPCHANGE"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "0.0.1"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

g.settingsDirLoc = string.format("../addons/%s", addonNameLower)
g.settingsFileLoc = string.format("%s/settings.json", g.settingsDirLoc)

local acutil = require("acutil")

local BHModeOn = false

function BHMAPCHANGE_ON_INIT(addon, frame)
    g.addon = addon
    g.frame = frame

    addon:RegisterMsg("DIALOG_CHANGE_SELECT", "BHMAPCHANGE_DIALOG_ON_MSG")
    addon:RegisterMsg("DIALOG_ADD_SELECT", "BHMAPCHANGE_DIALOGSELECT_ON_MSG")
    CHAT_SYSTEM("BHMAPCHANGE loaded")

    local bhframe = ui.GetFrame("bountyhunt")
    if bhframe:IsVisible() == 1 then
        BHModeOn = true
    else
        BHModeOn = false
    end
    if BHModeOn then
        camera.CustomZoom(700)
    end
end

function BHMAPCHANGE_DIALOG_ON_MSG(frame, msg, argStr, argNum)
    if BHModeOn then
        if string.find(argStr, "HighLvZoneEnterMsgCustom") ~= nil then
            ReserveScript(ui.CloseFrame("dialog"), 0.01)
        end
    end
end

function BHMAPCHANGE_DIALOGSELECT()
    control.DialogSelect(1)
    local x, y = mouse.GetX(), mouse.GetY()
    ReserveScript(string.format('mouse.SetPos(%d, %d)', x, y), 0.02)
end

function BHMAPCHANGE_DIALOGSELECT_ON_MSG(frame, msg, argStr, argNum)
    if argStr == '!@#$WS_ZACHA2F_01_TO_02_ANSWER_GO#@!' then
        BHMAPCHANGE_DIALOGSELECT()
    end
end
