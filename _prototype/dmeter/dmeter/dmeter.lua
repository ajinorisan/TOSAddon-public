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
    acutil.setupHook(DMETER_ON_USER_DAMAGE_LIST, "ON_USER_DAMAGE_LIST")
    CHAT_SYSTEM(ddonNameLower .. " loaded")
    -- addon:RegisterMsg('GAME_START_3SEC', 'CONTINUERF_FRAME_INIT')

end

function DMETER_ON_USER_DAMAGE_LIST(nameList, damageList)
    ON_USER_DAMAGE_LIST_OLD(nameList, damageList)
end

function DMETER_UPDATE_USER_DAMAGE_METER_GUAGE(frame, groupbox, totalDamage, nameList)
    UPDATE_USER_DAMAGE_METER_GUAGE_OLD(frame, groupbox, totalDamage, nameList)
end

function GetPartyMemberFamilyNameList()
    local familyNameList = {}
    local partyInfo = session.party.GetPartyInfo()

    if partyInfo ~= nil then
        local memberCount = partyInfo:GetMemberCount()

        for i = 0, memberCount - 1 do
            local partyMemberInfo = partyInfo:GetMemberByIndex(i)
            local familyName = partyMemberInfo:GetFamilyName()
            table.insert(nameList, familyName)
        end
    end

    return nameList
end
-- function ON_USER_DAMAGE_LIST(nameList, damageList)
-- local totalDamage
-- for i = 1, #nameList do
-- if damage ~= '0' then
-- damage_meter_info_total[nameList[i]] = damageList[i]
-- totalDamage = SumForBigNumberInt64(damageList[i],totalDamage)
-- end        
-- end
-- local frame = ui.GetFrame("user_damage_meter")
-- if frame:IsVisible() == 0 then
-- frame:ShowWindow(1)
-- end
-- AUTO_CAST(frame)
-- local damageRankGaugeBox = GET_CHILD_RECURSIVELY(frame,"damageRankGaugeBox")
-- UPDATE_USER_DAMAGE_METER_GUAGE(frame,damageRankGaugeBox, totalDamage, nameList)
-- end

--[[
function UPDATE_USER_DAMAGE_METER_GUAGE(frame, groupbox, totalDamage, nameList)
    local font = frame:GetUserConfig('GAUGE_FONT');
    
    for i = 1, #nameList do
        local name = nameList[i]
        local damage = damage_meter_info_total[name]
        local ctrlSet = groupbox:GetControlSet('gauge_with_two_text', 'GAUGE_'..i)
        if ctrlSet == nil then
            ctrlSet = groupbox:CreateControlSet('gauge_with_two_text', 'GAUGE_'..i, 0, (i-1)*17);
            groupbox:Resize(groupbox:GetWidth(),groupbox:GetHeight()+17)
        end
        local point = MultForBigNumberInt64(damage,"100")
        if totalDamage ~= "0" then
            point = DivForBigNumberInt64(point, totalDamage)
            local skin = 'gauge_damage_meter_0'..math.min(i,4)
            damage = font..STR_KILO_CHANGE(damage)..'K'
            DAMAGE_METER_GAUGE_SET(ctrlSet,font..name,point,font..damage,skin);
        end
    end
end
]]
