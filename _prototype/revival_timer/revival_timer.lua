local addonName = "REVIVAL_TIMER"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.0.0"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

g.settings_file_path = string.format('../addons/%s/settings.json', addonNameLower)

local folder_path = string.format("../addons/%s", addonNameLower)
os.execute('mkdir "' .. folder_path .. '"')

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

function revival_timer_save_settings()
    acutil.saveJSON(g.settings_file_path, g.settings)
end

function revival_timer_load_settings()
    local settings, err = acutil.loadJSON(g.settings_file_path, g.settings)

    if not settings then
        settings = {
            X = 400,
            Y = 300,
            set_second = 0,
            set_text = ""
        }
    end

    g.settings = settings
    revival_timer_save_settings()
end

function REVIVAL_TIMER_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame
    revival_timer_load_settings()
    addon:RegisterMsg("GAME_START", "revival_timer_frame_init")
    -- acutil.slashCommand('/timer', revival_timer_command)
end

function revival_timer_frame_init()

    local frame = ui.GetFrame("revival_timer")
    frame:SetSkinName('None')
    frame:Resize(60, 30)
    frame:SetTitleBarSkin("None")
    frame:EnableHittestFrame(1)
    frame:EnableHide(0)
    frame:SetPos(1570, 0)
    frame:ShowWindow(1)
    frame:RunUpdateScript("revival_timer_start", 0.01)

    local set_timer = frame:CreateOrGetControl('button', 'set_timer', 0, 0, 60, 30)
    AUTO_CAST(set_timer)
    set_timer:SetText("Timer")
    set_timer:SetEventScript(ui.LBUTTONUP, "revival_timer_setting")
    -- local close_button = frame:CreateOrGetControl("button", "close_button", 0, 0, 35, 35)
end

function revival_timer_setting(frame, ctrl, str, num)

    local frame = ui.CreateNewFrame("notice_on_pc", addonNameLower .. "setting", 0, 0, 0, 0)
    AUTO_CAST(frame)
    frame:SetPos(1570, 30)
    frame:ShowWindow(1)
    frame:SetSkinName("None")
    frame:SetSkinName("test_frame_midle_light")
    frame:Resize(200, 100)
    frame:SetLayerLevel(999)

    local info_text = frame:CreateOrGetControl('richtext', 'info_text', 5, 5, 50, 20)
    AUTO_CAST(info_text)
    info_text:SetText("{ol}Info : ")

    local info_edit = frame:CreateOrGetControl('edit', 'info_edit', 55, 5, 130, 20)
    AUTO_CAST(info_edit)
    info_edit:SetFontName("white_16_ol")
    info_edit:SetTextAlign("center", "center")
    info_edit:SetEventScript(ui.ENTERKEY, "indun_panel_autozoom_save")

end

function revival_timer_start(frame)
    local downKey = keyboard.GetDownKey();
    if downKey ~= nil then
        if downKey == "RALT" then
            print(tostring(downKey))
        end
    end
    return 1
end

function revival_timer_command(commands)

end
