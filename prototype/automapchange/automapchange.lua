local addonName = "AUTOMAPCHANGE"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "0.0.1"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

g.settingsDirLoc = string.format("../addons/%s", addonNameLower)
g.settingsFileLoc = string.format("../addons/%s/settings.json", addonNameLower);

local acutil = require("acutil")

function AUTOMAPCHANGE_ON_INIT(addon, frame)
    g.addon = addon
    g.frame = frame
    
    --frame:ShowWindow(0);
  
    addon:RegisterMsg("DIALOG_CHANGE_SELECT", "AUTOMAPCHANGE_DIALOG_ON_MSG")
    addon:RegisterMsg('GAME_START', 'AUTOMAPCHANGE_LOADSETTINGS')
    acutil.slashCommand("/amc",AUTOMAPCHANGE_CMD)
    acutil.slashCommand("/automapchange",AUTOMAPCHANGE_CMD)
    CHAT_SYSTEM("automapchange loaded")
    camera.CustomZoom(700)
   
end

function AUTOMAPCHANGE_SAVESETTINGS()
	acutil.saveJSON(g.settingsFileLoc, g.settings);
end

function AUTOMAPCHANGE_LOADSETTINGS()
	
	if g.settings == nil then
	 g.settings = {onoff = true}
	 AUTOMAPCHANGE_SAVESETTINGS()
	end
	
    local t, err = acutil.loadJSON(g.settingsFileLoc, g.settings);
     if err then
      --設定ファイル読み込み失敗時処理
      CHAT_SYSTEM(string.format("[%s] cannot load setting files", addonName))
     else
      --設定ファイル読み込み成功時処理
      g.settings = t;
     end
    g.loaded = true
end


function AUTOMAPCHANGE_CMD(command)
    if g.settings.onoff == true then
        g.settings.onoff = false
        AUTOMAPCHANGE_SAVESETTINGS()
        CHAT_SYSTEM('AutoChangeMapOff')
    else
        g.settings.onoff = true
        AUTOMAPCHANGE_SAVESETTINGS()
       CHAT_SYSTEM('AutoChangeMapOn')
    end
    return;
end

function AUTOMAPCHANGE_DIALOG_ON_MSG(frame, msg, argStr, argNum)
--print(msg)
--print(argStr)
--print(argNum)
    if g.settings.onoff == true then
        if string.find(argStr, "HighLvZoneEnterMsgCustom") ~= nil then
             local dialog = ui.GetFrame("dialog")
            local x, y = dialog:GetX() + 50, dialog:GetY() + 200 -- ダイアログ内の任意の座標を指定
            ReserveScript(string.format('mouse.SetPos(%d, %d)', x, y), 0.5)
            AUTOMAPCHANGE_DIALOGSELECT()
            
        end
    end
end

function AUTOMAPCHANGE_DIALOGSELECT()
    control.DialogSelect(1)
    local x, y = mouse.GetX(), mouse.GetY()
     ReserveScript(string.format('mouse.SetPos(%d, %d)', x, y),0.5)
     end

--[[
function BHMAPCHANGE_DIALOGSELECT_ON_MSG(frame, msg, argStr, argNum)
    if argStr == '!@#$WS_ZACHA2F_01_TO_02_ANSWER_GO#@!' then
        BHMAPCHANGE_DIALOGSELECT()
    end
end
]]
