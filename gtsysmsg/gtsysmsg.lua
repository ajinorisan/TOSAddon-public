local addonName = "GTSYSMSG"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.0.6"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

g.settingsDirLoc = string.format("../addons/%s", addonNameLower)
g.settingsFileLoc = string.format("%s/settings.json", g.settingsDirLoc)

local acutil = require("acutil")

--local msg = "test" 
    --imcSound.PlaySoundEvent("sys_card_battle_percussion_timpani");
    --imcSound.PlaySoundEvent('sys_tp_box_4')
    --imcSound.PlayMusicQueueLocal('colonywar_win')    

function GTSYSMSG_ON_INIT(addon, frame)
    
    g.addon = addon
    g.frame = frame

    if not g.loaded then
        g.loaded = true
    end

    --frame:ShowWindow(0)

    acutil.setupHook(GTSYSMSG_ON_MSG, "NOTICE_ON_MSG")
    
    CHAT_SYSTEM("GTSYSMSG loaded")
end   

function GTSYSMSG_ON_MSG(frame, msg, argStr, argNum)
NOTICE_ON_MSG_OLD(frame, msg, argStr, argNum)
    if argStr ~= "None" then
        CHAT_SYSTEM(argStr)
        if string.find(argStr, 'AppearPCMonster{name}') then
            GTSYSMSG_CENTER_MSG(argStr)
            imcSound.PlaySoundEvent('sys_tp_box_4')
            imcSound.PlayMusicQueueLocal('colonywar_win')
        end

        if string.find(argStr, '{name}DisappearPCMonster') then
            GTSYSMSG_CENTER_MSG(argStr)
            --imcSound.PlaySoundEvent('sys_tp_box_3')
        end

        if string.find(argStr, 'AppearFieldBoss_ep14_2_d_castle_3{name}') then
            GTSYSMSG_CENTER_MSG(argStr)
             --imcSound.PlaySoundEvent('sys_tp_box_4')
            --imcSound.PlayMusicQueueLocal('colonywar_win')
        end
    end
end

function GTSYSMSG_CENTER_MSG(argStr)
    NICO_CHAT(string.format("{@st55_a}%s", argStr))
end

