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

    acutil.setupHook(DMETER_ON_USER_DAMAGE_LIST, "ON_USER_DAMAGE_LIST")
    addon:RegisterMsg('GAME_START_3SEC', 'DMETER_GET_PARTYINFO');
    if g.damagelist ~= nil then
        for key, value in pairs(g.damagelist) do
            print(key .. ":" .. value)
        end
    end
    if g.nameList ~= nil then
        for key, value in pairs(g.nameList) do
            print(key .. ":" .. value)
        end
    end
    for i = 1, #g.nameList do
        print(tostring(g.nameList[i]))
    end
end

function DMETER_GET_PARTYINFO()
    g.nameList = {}
    -- local LoginName = session.GetMySession():GetPCApc():GetName()
    -- table.insert(nameList, LoginName)
    local pcparty = session.party.GetPartyInfo();
    print(tostring(pcparty))
    if pcparty ~= nil then
        local list = session.party.GetPartyMemberList(PARTY_NORMAL);
        local count = list:Count()

        for i = 0, count - 1 do
            local eachpartymember = list:Element(i)
            local name = tostring(eachpartymember:GetName())
            table.insert(g.nameList, name)

        end
    else
        CHAT_SYSTEM("入ってない")
    end
end

function DMETER_ON_USER_DAMAGE_LIST(nameList, damageList)
    print(#damageList)
    g.damagelist = {}

    local totalDamage
    for i = 1, #nameList do

        damage_meter_info_total[nameList[i]] = damageList[i]
        totalDamage = SumForBigNumberInt64(damageList[i], totalDamage)

        -- g.damagelist[g.nameList[i]] = damageList[i]

    end
    for i = 1, #g.nameList do

        g.damagelist[g.nameList[i]] = damageList[i]
        print("Player: " .. tostring(g.nameList[i]) .. ", Damage: " .. tostring(damageList[i]))
    end
    local frame = ui.GetFrame("user_damage_meter")
    if frame:IsVisible() == 0 then
        frame:ShowWindow(1)
    end
    AUTO_CAST(frame)
    local damageRankGaugeBox = GET_CHILD_RECURSIVELY(frame, "damageRankGaugeBox")
    UPDATE_USER_DAMAGE_METER_GUAGE(frame, damageRankGaugeBox, totalDamage, nameList)
end

