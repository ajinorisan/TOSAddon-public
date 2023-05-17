local addonName = "DMETER"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "0.0.1"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

local acutil = require("acutil")

function DMETER_ON_INIT(addon, frame)
    g.addon = addon
    g.frame = frame

    acutil.setupHook(DMETER_UPDATE_USER_DAMAGE_METER_GUAGE, "UPDATE_USER_DAMAGE_METER_GUAGE")
    acutil.setupHook(DMETER_USER_DAMAGE_METER_UI_OPEN, "USER_DAMAGE_METER_UI_OPEN")
    CHAT_SYSTEM(ddonNameLower .. " loaded")
    -- addon:RegisterMsg('GAME_START_3SEC', 'CONTINUERF_FRAME_INIT')

end

function DMETER_UPDATE_USER_DAMAGE_METER_GUAGE(frame, groupbox, totalDamage, nameList)
    CHAT_SYSTEM(totalDamage)

    local SET_HEIGHT = 17 -- 1人分の高さ

    local font = frame:GetUserConfig('GAUGE_FONT')

    for i = 1, #nameList do
        local name = nameList[i]
        local damage = damage_meter_info_total[name]
        local ctrlSet = groupbox:GetControlSet('gauge_with_two_text', 'GAUGE_' .. i)

        if ctrlSet == nil then
            ctrlSet = groupbox:CreateControlSet('gauge_with_two_text', 'GAUGE_' .. i, 0, (i - 1) * SET_HEIGHT)
            groupbox:Resize(groupbox:GetWidth(), groupbox:GetHeight() + SET_HEIGHT)
        end

        local point = MultForBigNumberInt64(damage, "100")
        if totalDamage ~= "0" then
            point = DivForBigNumberInt64(point, totalDamage)
            local skin = 'gauge_damage_meter_0' .. math.min(4, 4)
            damage = font .. STR_KILO_CHANGE(damage) .. 'K'
            DAMAGE_METER_GAUGE_SET(ctrlSet, font .. name, point, font .. damage, skin)
        end
    end
end

function DMETER_USER_DAMAGE_METER_UI_OPEN(frame, msg, strArg, numArg)
    CHAT_SYSTEM(msg)
    CHAT_SYSTEM(strArg)
    CHAT_SYSTEM(numArg)

    frame:ShowWindow(1)
end
