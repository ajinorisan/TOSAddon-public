-- v1.0.7 SetupHookの競合修正。バウバス通知OFF
local addonName = "GTSYSMSG"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.0.7"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

g.settingsDirLoc = string.format("../addons/%s", addonNameLower)
g.settingsFileLoc = string.format("%s/settings.json", g.settingsDirLoc)

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

function GTSYSMSG_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame

    if not g.loaded then
        g.loaded = true
    end

    -- frame:ShowWindow(0)

    g.SetupHook(GTSYSMSG_NOTICE_ON_MSG, "NOTICE_ON_MSG")

    -- CHAT_SYSTEM("GTSYSMSG loaded")
end

function GTSYSMSG_NOTICE_ON_MSG(frame, msg, argStr, argNum)
    base["NOTICE_ON_MSG"](frame, msg, argStr, argNum)
    if argStr ~= "None" then
        CHAT_SYSTEM(argStr)
        if string.find(argStr, 'AppearPCMonster{name}') then
            NICO_CHAT(string.format("{@st55_a}%s", argStr))
            imcSound.PlaySoundEvent('sys_tp_box_4')
            imcSound.PlayMusicQueueLocal('colonywar_win')

        end

        if string.find(argStr, '{name}DisappearPCMonster') then
            NICO_CHAT(string.format("{@st55_a}%s", argStr))
            -- imcSound.PlaySoundEvent('sys_tp_box_3')
        end
        --[[
        if string.find(argStr, 'AppearFieldBoss_ep14_2_d_castle_3{name}') then
            GTSYSMSG_CENTER_MSG(argStr)
            -- imcSound.PlaySoundEvent('sys_tp_box_4')
            -- imcSound.PlayMusicQueueLocal('colonywar_win')
        end
        ]]
    end
end

function GTSYSMSG_CENTER_MSG(argStr)

end

