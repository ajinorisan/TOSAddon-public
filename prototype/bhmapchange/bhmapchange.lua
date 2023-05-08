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

local targetMap = {
    1001, --クラペダ
    1006, --オルシャ
    981, --フェディミアン
}

function BHMAPCHANGE_IS_TARGETMAP()
local mapID = session.GetMapID()
    for i = 1, #targetMap do
        if mapID == targetMap[i] then
            return true
        end
    end
    return false
end

function BHMAPCHANGE_ON_INIT(addon, frame)
    g.addon = addon
    g.frame = frame

    addon:RegisterMsg("DIALOG_CHANGE_SELECT", "BHMAPCHANGE_DIALOG_ON_MSG")
    if BHMAPCHANGE_IS_TARGETMAP() == true then
    addon:RegisterMsg("FPS_UPDATE", "BHMAPCHANGE_MODE")
    
    end
    CHAT_SYSTEM("BHMAPCHANGE loaded")

    if BHModeOn then
        --CHAT_SYSTEM("BHModeOn")
        camera.CustomZoom(700)
    end
end

function BHMAPCHANGE_DIALOG_ON_MSG(frame, msg, argStr, argNum)
    if BHModeOn then
        if string.find(argStr, "HighLvZoneEnterMsgCustom") ~= nil then
             local dialog = ui.GetFrame("dialog")
            local x, y = dialog:GetX() + 50, dialog:GetY() + 200 -- ダイアログ内の任意の座標を指定
            ReserveScript(string.format('mouse.SetPos(%d, %d)', x, y), 0.5)
            BHMAPCHANGE_DIALOGSELECT()
            
        end
    end
end

function BHMAPCHANGE_DIALOGSELECT()
    control.DialogSelect(1)
    local x, y = mouse.GetX(), mouse.GetY()
    string.format('mouse.SetPos(%d, %d)', x, y)
end

function BHMAPCHANGE_MODE()
local bhframe = ui.GetFrame("bountyhunt_milestone")
    if bhframe:IsVisible() == 1 then
        BHModeOn = true
        --CHAT_SYSTEM("BHModeOn")
    else
        BHModeOn = false
        --CHAT_SYSTEM("BHModeOff")
    end
end

--[[
function BHMAPCHANGE_DIALOGSELECT_ON_MSG(frame, msg, argStr, argNum)
    if argStr == '!@#$WS_ZACHA2F_01_TO_02_ANSWER_GO#@!' then
        BHMAPCHANGE_DIALOGSELECT()
    end
end
]]
