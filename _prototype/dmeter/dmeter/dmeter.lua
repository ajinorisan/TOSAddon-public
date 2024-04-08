local addonName = "DMETER"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "0.0.1"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

local acutil = require("acutil")

function g.SetupHook(func, baseFuncName)
    local addonUpper = string.upper(addonName)
    local replacementName = addonUpper .. "_BASE_" .. baseFuncName
    if (_G[replacementName] == nil) then
        _G[replacementName] = _G[baseFuncName];
        _G[baseFuncName] = func
    end
    base[baseFuncName] = _G[replacementName]
end

local damage_meter_info_total_dmeter = {}
local damage_meter_info_total = {}

function DMETER_ON_INIT(addon, frame)
    g.addon = addon
    g.frame = frame

    g.SetupHook(DMETER_ON_USER_DAMAGE_LIST, "ON_USER_DAMAGE_LIST")

end

function DMETER_ON_USER_DAMAGE_LIST(nameList, damageList)
    local totalDamage = 0
    for i = 1, #nameList do
        local damage = damageList[i]
        if damage ~= '0' then
            damage_meter_info_total[nameList[i]] = damage
            damage_meter_info_total_dmeter[nameList[i]] = damage
            totalDamage = SumForBigNumberInt64(damage, totalDamage)
            -- ここで必要に応じてdamageの値を出力する
            print("Player: " .. nameList[i] .. ", Damage: " .. damage)
        end
    end

    local frame = ui.GetFrame("user_damage_meter")
    if frame:IsVisible() == 0 then
        frame:ShowWindow(1)
    end
    AUTO_CAST(frame)
    local damageRankGaugeBox = GET_CHILD_RECURSIVELY(frame, "damageRankGaugeBox")
    UPDATE_USER_DAMAGE_METER_GUAGE(frame, damageRankGaugeBox, totalDamage, nameList)
end

