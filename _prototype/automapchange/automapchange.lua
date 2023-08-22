-- v1.0.2 cameraの挙動修正
local addonName = "AUTOMAPCHANGE"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.0.2"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

g.settingsDirLoc = string.format("../addons/%s", addonNameLower)
g.settingsFileLoc = string.format("../addons/%s/settings.json", addonNameLower);

local acutil = require("acutil")

if not g.loaded then
    g.settings = {
        on = 1
    }
end

g.cmcnt = 0 -- 初回ログイン時にだけ動かないのを処理1以上になると通常に動くはず
g.mapID = nil

function AUTOMAPCHANGE_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame

    addon:RegisterMsg("DIALOG_CHANGE_SELECT", "AUTOMAPCHANGE_DIALOG_ON_MSG")
    addon:RegisterMsg('GAME_START_3SEC', 'AUTOMAPCHANGE_DIALOG_ON_MSG')
    addon:RegisterMsg('GAME_START_3SEC', 'AUTOMAPCHANGE_CAMERA_ZOOM')
    -- addon:RegisterMsg('GAME_START_3SEC', 'AUTOMAPCHANGE_LOADSETTINGS')
    acutil.slashCommand("/amc", AUTOMAPCHANGE_CMD)
    acutil.slashCommand("/automapchange", AUTOMAPCHANGE_CMD)
    -- CHAT_SYSTEM("automapchange loaded")

    AUTOMAPCHANGE_SAVESETTINGS()

    if g.mapID ~= session.GetMapID() then
        g.mapID = session.GetMapID()
        if g.cmcnt == 0 then
            g.cmcnt = g.cmcnt + 1
            -- CHAT_SYSTEM(g.cmcnt)
        end
        AUTOMAPCHANGE_CHANGE_MAP()
    end

    AUTOMAPCHANGE_LOADSETTINGS()

end

function AUTOMAPCHANGE_CAMERA_ZOOM()
    camera.CustomZoom(700)
end

function AUTOMAPCHANGE_SAVESETTINGS()
    acutil.saveJSON(g.settingsFileLoc, g.settings);
end

function AUTOMAPCHANGE_LOADSETTINGS()

    local t, err = acutil.loadJSON(g.settingsFileLoc);
    if err then
        -- 設定ファイル読み込み失敗時処理
        CHAT_SYSTEM(string.format("[%s] cannot load setting files", addonName))
    else
        -- 設定ファイル読み込み成功時処理
        g.settings = t;
    end
    g.loaded = true
end

function AUTOMAPCHANGE_CMD(command)

    if g.settings.on == 1 then
        g.settings.on = 0
        g.cmcnt = 3
        AUTOMAPCHANGE_SAVESETTINGS()
        CHAT_SYSTEM('AutoChangeMapOff')

    else

        g.settings.on = 1
        AUTOMAPCHANGE_SAVESETTINGS()
        CHAT_SYSTEM('AutoChangeMapOn')

    end
    return;
end

function AUTOMAPCHANGE_CHANGE_MAP()
    -- print("test")
    if g.settings.on == 1 and g.cmcnt == 1 then
        g.settings.on = 0
        AUTOMAPCHANGE_SAVESETTINGS()
        g.cmcnt = g.cmcnt + 1

    elseif g.settings.on == 0 and g.cmcnt == 2 then
        ui.Chat("/amc")

    end
end

function AUTOMAPCHANGE_DIALOG_ON_MSG(frame, msg, argStr, argNum)
    -- CHAT_SYSTEM(g.cmcnt)
    if g.settings.on == 1 then
        if string.find(argStr, "HighLvZoneEnterMsgCustom") ~= nil then
            -- ReserveScript("control.DialogOk()", 0.5)
            control.DialogSelect(1)
            -- AUTOMAPCHANGE_DIALOGSELECT()
        end
    else
        return
    end
end

function AUTOMAPCHANGE_DIALOGSELECT()

    control.DialogSelect(1)

end
