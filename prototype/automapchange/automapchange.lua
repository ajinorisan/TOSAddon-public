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

local mcc = 0 -- 初回ログイン時にだけ動かないのを処理1以上になると通常に動くはず

function AUTOMAPCHANGE_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame

    addon:RegisterMsg("DIALOG_CHANGE_SELECT", "AUTOMAPCHANGE_DIALOG_ON_MSG")
    addon:RegisterMsg('GAME_START_3SEC', 'AUTOMAPCHANGE_DIALOG_ON_MSG')
    addon:RegisterMsg('GAME_START_3SEC', 'AUTOMAPCHANGE_LOADSETTINGS')
    addon:RegisterMsg('CHANGE_MAP', 'AUTOMAPCHANGE_CHANGE_MAP')
    acutil.slashCommand("/amc", AUTOMAPCHANGE_CMD)
    acutil.slashCommand("/automapchange", AUTOMAPCHANGE_CMD_FULL)
    CHAT_SYSTEM("automapchange loaded")
    camera.CustomZoom(700)

end

function AUTOMAPCHANGE_SAVESETTINGS()
    acutil.saveJSON(g.settingsFileLoc, g.settings);
end

function AUTOMAPCHANGE_LOADSETTINGS()
    CHAT_SYSTEM("test")
    -- 設定値がない場合の初期設定
    if g.settings == nil then
        g.settings = {
            onoff = 1
        }
        AUTOMAPCHANGE_SAVESETTINGS()
    end

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

    if g.settings.onoff == 1 then
        g.settings.onoff = 0
        AUTOMAPCHANGE_SAVESETTINGS()
        CHAT_SYSTEM('AutoChangeMapOff')

    else

        g.settings.onoff = 1
        AUTOMAPCHANGE_SAVESETTINGS()
        CHAT_SYSTEM('AutoChangeMapOn')

    end
    return;
end

function AUTOMAPCHANGE_CMD_FULL(command)

    if g.settings.onoff == 1 then
        g.settings.onoff = 0
        AUTOMAPCHANGE_SAVESETTINGS()
        -- CHAT_SYSTEM('AutoChangeMapOff')

    else

        g.settings.onoff = 1
        AUTOMAPCHANGE_SAVESETTINGS()
        -- CHAT_SYSTEM('AutoChangeMapOn')

    end
    return
end

function AUTOMAPCHANGE_CHANGE_MAP()
    if mcc == 0 then
        g.settings.onoff = 0
        AUTOMAPCHANGE_SAVESETTINGS()
    end

    mcc = mcc + 1
    if mcc == 1 then
        ui.Chat(string.format("/automapchange"))
        ui.Chat(string.format("/automapchange"))
    end

end

function AUTOMAPCHANGE_DIALOG_ON_MSG(frame, msg, argStr, argNum)

    if g.settings.onoff == 1 and mcc ~= 0 then
        if string.find(argStr, "HighLvZoneEnterMsgCustom") ~= nil then
            ReserveScript("control.DialogOk()", 0.5)

            AUTOMAPCHANGE_DIALOGSELECT()
        end
    else
        return
    end
end

function AUTOMAPCHANGE_DIALOGSELECT()

    control.DialogSelect(1)

end
