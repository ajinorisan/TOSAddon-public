-- user_damage_meter.lua

local damage_meter_info_total = {}

function USER_DAMAGE_METER_ON_INIT(addon, frame)
    addon:RegisterMsg("USER_DAMAGE_CLEAR", "ON_USER_DAMAGE_CLEAR");
end

function USER_DAMAGE_METER_UI_OPEN(frame,msg,strArg,numArg)
    frame:ShowWindow(1)
end

function ON_USER_DAMAGE_CLEAR()
    damage_meter_info_total = {}
end

function ON_USER_DAMAGE_LIST(nameList, damageList)
    local totalDamage
    for i = 1, #nameList do
        if damage ~= '0' then
            damage_meter_info_total[nameList[i]] = damageList[i]
            totalDamage = SumForBigNumberInt64(damageList[i],totalDamage)
        end        
    end
    local frame = ui.GetFrame("user_damage_meter")
    if frame:IsVisible() == 0 then
        frame:ShowWindow(1)
    end
    AUTO_CAST(frame)
    local damageRankGaugeBox = GET_CHILD_RECURSIVELY(frame,"damageRankGaugeBox")
    UPDATE_USER_DAMAGE_METER_GUAGE(frame,damageRankGaugeBox, totalDamage, nameList)
end


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
