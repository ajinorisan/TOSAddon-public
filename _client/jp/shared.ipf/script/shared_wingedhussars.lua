-- shared_wingedhussars.lua



function client_WingedHussars_CircleWings(actor, obj, eff, sound)    
    local handle = session.GetTargetHandle()
    
    if handle == 0 or handle == nil then
        return
    end

    local han = actor:GetHandleVal()    
    local target = world.GetActor(handle);
    local pos = target:GetPos()
    effect.AddActorUnityEffect(target, eff, 0.45, pos.x, pos.y, pos.z, 0, 0, 0, 500);
    
    for i = 1, 8 do        
        if IMCRandom(1, 2) <= 1 then
            local func = string.format('play_sound_WingedHussars_CircleWings(%d, "%s")', han, sound)
            ReserveScript(func, 1.6 + (i * 0.1))
        end
    end
end

function play_sound_WingedHussars_CircleWings(handle, sound)    
    local actor = world.GetActor(handle);
    if actor ~= nil then
        actor:GetEffect():PlaySound(sound);    
    end
end

function client_WingedHussars_CircleWings_2(actor, obj, effect_name)
    local handle = actor:GetHandleVal()
    local func = string.format('play_effect_WingedHussars_CircleWings(%d, "%s")', handle, effect_name)    
    ReserveScript(func, 1.2)
end

function play_effect_WingedHussars_CircleWings(handle, effect_name)
    local actor = world.GetActor(handle);
    if actor ~= nil then
        local pos = actor:GetPos()
        effect.AddActorUnityEffect(actor, effect_name, 3, pos.x, pos.y + 10, pos.z, 0, 120.5, 0, 1.5);
        actor:GetEffect():AddAutoDetachEffect(eftName);
    end
end

function play_effect_WingedHussars_CircleWings2(handle, effect_name)
    local actor = world.GetActor(handle);
    if actor ~= nil then
        effect.DetachActorEffect(actor, effect_name, 0);
    end
end

function client_WingedHussars_RisingWings(actor, obj, goal_x, goal_y, goal_z, around_range, index, second_effect_name, second_effect_scale, second_effect_life_time)
    local pos_list = GET_AROUND_POS_CIRCLE(goal_x, goal_y, goal_z, around_range, 3)
    local scale_2 = 0.5

    C_EFFECT_POS(actor, obj, 'eff_monster_chapparition_skill04_launch_01', scale_2, pos_list[index][1], pos_list[index][2], pos_list[index][3], 1, 'None', 0, 0.25)
    local pos1 = actor:GetPos()
    local pos = actor:GetFrontPos(50)    
    local dir_degree = GET_DIRECTION_DEGREE(pos1.x, pos1.z, pos.x, pos.z)        
    local angle_x , angle_y, angle_z = 0, 0, 0

    if dir_degree >= -91 and dir_degree <= -89 then -- 1
        angle_x = 70
        angle_y = 0
        angle_z = 0
    elseif dir_degree >= -46 and dir_degree <= -44 then -- 2
        angle_x = 40
        angle_y = 70
        angle_z = 0
    elseif dir_degree >= -1 and dir_degree <= 1 then -- 3
        angle_x = 0
        angle_y = 0
        angle_z = 70
    elseif dir_degree >= -136 and dir_degree <= -134 then -- 4
        angle_x = 70
        angle_y = 0
        angle_z = 0        
    elseif dir_degree >= 44 and dir_degree <= 46 then -- 6
        angle_x = 0
        angle_y = 0
        angle_z = 70
    elseif dir_degree >= 179 and dir_degree <= 181 then -- 7
        angle_x = 70
        angle_y = 0
        angle_z = 0
    elseif dir_degree >= 134 and dir_degree <= 136 then -- 8
        angle_x = 40
        angle_y = -70
        angle_z = 0
    elseif dir_degree >= 89 and dir_degree <= 91 then -- 9
        angle_x = 0
        angle_y = 0
        angle_z = 70
    end
    
    effect.PlayGroundUnityEffect(actor, 'GroundImpact_HolySpear_Yellow_01', 0.2, pos_list[index][1], pos_list[index][2], pos_list[index][3], 0.5, "None", 
    angle_x, angle_y, angle_z, 0);
    C_EFFECT_POS(actor, obj, second_effect_name, second_effect_scale, goal_x, goal_y, goal_z, second_effect_life_time, 'None', 0, 0.25)
end

function client_WingedHussars_WindPulse(actor, obj, eftName, scl, x, y, z)
    local list = {30, 60, 90, 120, 150, 180, 210, 240}

    for i = 1, #list do
        local pos = actor:GetFrontPos(list[i])
        local delay = 100 * (i - 1)
        delay = delay / 1000
        
        effect.PlayGroundEffect(actor, eftName, scl, pos.x, pos.y, pos.z, 200, 'None', 0, delay)
        local scp = string.format('play_sound_WingedHussars_WindPulse()')
        ReserveScript(scp, delay)
    end
end

function play_sound_WingedHussars_WindPulse()    
    imcSound.PlaySoundEvent("skl_eff_acid_blood_hit")
end


-- dir_degree : actor가 바라보는 degree
function C_PLAY_EFFECT_INFINITY_SPEARS(actor, obj, x, y, z)
    local pos = actor:GetFrontPos(50)    
    local dir_degree = GET_DIRECTION_DEGREE(x, z, pos.x, pos.z)
        
    local eftName = 'None' 
    local scl = 1.3
    local lifeTime = 2
    local delay = 0
    local func
    
    func = string.format("C_PLAY_SOUND_3('%s', %d, %d, %d)", 'skl_eff_boom_l_1', x, y, z)
    ReserveScript(func, 0)

    delay = delay + 1.2
    local around_eff = 'eff_groundimpact_lightningbolt_blue_01'
    local radius = 100
    local angle_list = {}
    local interval_list = {30, 60, 90, 120, 150}
    local pos_list = {}
    for i = 1, #interval_list do
        local a, b, c = GET_AROUND_POS_BY_ANGLE(x, y, z, radius, dir_degree + interval_list[i])
        table.insert(pos_list, {a, b, c})
        a, b, c = GET_AROUND_POS_BY_ANGLE(x, y, z, radius, dir_degree - interval_list[i])
        table.insert(pos_list, {a, b, c})
    end

    delay = delay + 0.1 
    local x1, y1, z1 = GET_AROUND_POS_BY_ANGLE(x, y, z, radius, dir_degree)
    effect.PlayGroundUnityEffect(actor, around_eff, 1, x1, y1, z1, 1, "None", 0, 0, 0, delay);
    func = string.format("C_PLAY_SOUND_3('%s', %d, %d, %d)", 'skl_wiz_firepillar_shot', x, y, z)
    ReserveScript(func, delay)
        
    for i = 1, #pos_list, 2 do
        x1 = pos_list[i][1]
        y1 = pos_list[i][2]
        z1 = pos_list[i][3]
        delay = delay + 0.1

        effect.PlayGroundUnityEffect(actor, around_eff, 1, x1, y1, z1, 1, "None", 0, 0, 0, delay);

        x1 = pos_list[i+1][1]
        y1 = pos_list[i+1][2]
        z1 = pos_list[i+1][3]
        
        effect.PlayGroundUnityEffect(actor, around_eff, 1, x1, y1, z1, 1, "None", 0, 0, 0, delay);        
        func = string.format("C_PLAY_SOUND_3('%s', %d, %d, %d)", 'skl_wiz_firepillar_shot', x, y, z)
        ReserveScript(func, delay)
    end

    delay = delay + 0.1 
    x1, y1, z1 = GET_AROUND_POS_BY_ANGLE(x, y, z, radius, dir_degree + 180)
    effect.PlayGroundUnityEffect(actor, around_eff, 1, x1, y1, z1, 1, "None", 0, 0, 0, delay);
    func = string.format("C_PLAY_SOUND_3('%s', %d, %d, %d)", 'skl_wiz_firepillar_shot', x, y, z)
    ReserveScript(func, delay)

    for i = #pos_list, 1, -2 do
        x1 = pos_list[i][1]
        y1 = pos_list[i][2]
        z1 = pos_list[i][3]
        delay = delay + 0.1

        effect.PlayGroundUnityEffect(actor, around_eff, 1, x1, y1, z1, 1, "None", 0, 0, 0, delay);

        x1 = pos_list[i-1][1]
        y1 = pos_list[i-1][2]
        z1 = pos_list[i-1][3]
        
        effect.PlayGroundUnityEffect(actor, around_eff, 1, x1, y1, z1, 1, "None", 0, 0, 0, delay);
        func = string.format("C_PLAY_SOUND_3('%s', %d, %d, %d)", 'skl_wiz_firepillar_shot', x, y, z)
        ReserveScript(func, delay)
    end
    delay = delay + 0.1 
    x1, y1, z1 = GET_AROUND_POS_BY_ANGLE(x, y, z, radius, dir_degree)
    
    effect.PlayGroundUnityEffect(actor, around_eff, 0.5, x1, y1, z1, 1, "None", 0, 0, 0, delay);
    func = string.format("C_PLAY_SOUND_3('%s', %d, %d, %d)", 'skl_wiz_firepillar_shot', x, y, z)
    ReserveScript(func, delay)
    
    effect.PlayGroundUnityEffect(actor, 'GroundImpact_LightPillar_Blue_01', 1, x, y + 10, z, 1, "None", 0, 0, 0, delay - 0.85);    
    delay = delay + 0.4
    func = string.format("C_PLAY_SOUND_3('%s', %d, %d, %d)", 'skl_eff_boom_l_1', x, y, z)
    ReserveScript(func, delay)
    
    -- 원형 도넛    
    local pos_list_circle = GET_AROUND_POS_CIRCLE(x, y, z, 110, 14)
    for i = 1, #pos_list_circle do
        effect.PlayGroundUnityEffect(actor, 'GroundImpact_LavaCrack_Blue_01', 0.35, pos_list_circle[i][1], y, pos_list_circle[i][3], 2, "None", 0, 0, 0, delay);
    end

    func = string.format("C_PLAY_SOUND_3('%s', %d, %d, %d)", 'skl_eff_bodyfall_l_2', x, y, z)
    ReserveScript(func, delay)

    delay = delay + 0.1
    eftName = 'GroundImpact_SpearTrap_Blue_01'
    scl = 1.2
    lifeTime = 1
    effect.PlayGroundUnityEffect(actor, eftName, scl, x, y + 200, z, lifeTime, "None", 180, 0, 0, delay);
    func = string.format("C_PLAY_SOUND_3('%s', %d, %d, %d)", 'skl_eff_breastripper_scissors', x, y, z)
    ReserveScript(func, delay + 0.4)    
    ReserveScript(func, delay + 0.5)    
    ReserveScript(func, delay + 0.6)
    ReserveScript(func, delay + 0.7)
    
    delay = delay + 1
    local count = 20
    local count_2 = 5
    local time = 4000
    local tick = time / count / 1000 / count_2
    
    eftName = 'GroundImpact_HolySpear_Blue_01'    
    scl = 0.4
    lifeTime = 0
    local inverse = 25
    for i = 1, count do
        for j = 1, count_2 do
            x1, y1, z1 = GetRandomPosInRange(nil, x, y, z, 20, 100)
            delay = delay + tick              
            inverse = inverse * -1
            local deep = 0

            if IMCRandom(1, 100) <= 70 then                
                deep = 50
            end
            effect.PlayGroundUnityEffect(actor, eftName, scl, x1, y1 - deep, z1, lifeTime, "None", inverse + IMCRandom(0, 15), 0, 0, delay);                    
        end
    end

    for i = 4, 8, 0.15 do        
        local func = string.format("C_PLAY_SOUND_3('%s', %d, %d, %d)", 'skl_eff_wingedhussars_whoosh', x, y, z)        
        ReserveScript(func, i)
    end
end

function C_PLAY_EFFECT_EXPLOSION_SPEARS(actor, obj, x, y, z)
    local eftName = 'GroundImpact_LightPillar_Blue_01'
    local delay = 0
    local func
    
    func = string.format("C_PLAY_SOUND_3('%s', %d, %d, %d)", 'skl_eff_boom_l_1', x, y, z)
    ReserveScript(func, 0)
    delay = delay + 1.45
    effect.PlayGroundUnityEffect(actor, eftName, 0.75, x, y, z, 1, "None", 0, 0, 0, delay);
    ReserveScript(func, delay)
end

function C_PLAY_SOUND_3(name, x, y, z)    
    movie.PlaySoundPos(name, x, y, z)
end

-- done
function SCR_GET_WingedHussars_BattleSpirit_Ratio(skill)
    local value = TryGetProp(skill, 'SklFactor', 0) + (TryGetProp(skill, 'SklFactorByLevel', 0) * skill.Level)        
    local pc = GetSkillOwner(skill)
    local abil = GetAbility(pc, 'WingedHussars51')
    
    if abil ~= nil and 1 == TryGetProp(abil, "ActiveState", 0) then
        value = value * 0.025
    end
    
    return value
end
-- done
function SCR_GET_WingedHussars_BattleSpirit_Ratio2(skill)
    local value = skill.Level * 10
    local pc = GetSkillOwner(skill)
    local abil = GetAbility(pc, 'WingedHussars51')
    
    if value > 50 then
        value = 50
    end

    if abil ~= nil and 1 == TryGetProp(abil, "ActiveState", 0) then
        value = 0
    end
    
    return value
end
-- done
function SCR_Get_SkillFactor_WingedHussars_ExplosionSpears(skill)
    local value = SCR_Get_SkillFactor_Reinforce_Ability(skill)
    local pc = GetSkillOwner(skill)
        
    if GetExProp(pc, 'WingedHussars50') > 0 then
        value = value * 0.5 
    end
    
    return math.floor(value)
end


function CHECK_WingedHussars_BattleSpirit_Buff_C(actor, skl, buffName, over)
    local myHandle = session.GetMyHandle();
    local buff = info.GetBuffByName(myHandle, buffName);
    if nil ~= buff then
        if buff.over == over then
            return 1
        end
    end

    return 0
end

function CHECK_WingedHussars_CircleWings_C(actor, skl, buffName, over)
    local handle = session.GetTargetHandle()
    
    if handle == 0 or handle == nil then
        return 0
    end

    local target = world.GetActor(handle);
    if target ~= nil and target:GetObjType() == GT_MONSTER  then
        local monCls = GetClassByType("Monster", target:GetType());
        if monCls.MonRank == 'NPC' then
            return 0
        end
    end

    local skill = GetClassByType('Skill', skl.type)    
    local dis = info.GetDistance(handle)
    if dis > TryGetProp(skill, 'MaxR', 180) then
        return 0
    end

    local myHandle = session.GetMyHandle();
    local buff = info.GetBuffByName(myHandle, buffName);
    if nil ~= buff then
        if buff.over >= over then            
            return 1
        end
    end

    return 0
end

-- done
function SCR_Get_SkillFactor_Common_Infinity_Spears_520(skill)    
    local factor = TryGetProp(skill, 'SklFactor', 0)
    return math.floor(factor)
end


function C_PLAY_EFFECT_INFINITY_SPEARS_520(actor, obj, x, y, z)
    local eftName = 'None' 
    local scl = 1.3
    local lifeTime = 2
    local delay = 0
    local func = nil

    delay = delay + 0.1
    eftName = 'GroundImpact_SpearTrap_Blue_01' -- 하늘
    scl = 1.2
    lifeTime = 1
    effect.PlayGroundUnityEffect(actor, eftName, scl, x, y + 200, z, lifeTime, "None", 180, 0, 0, delay);
    func = string.format("C_PLAY_SOUND_3('%s', %d, %d, %d)", 'skl_eff_breastripper_scissors', x, y, z)
    ReserveScript(func, delay + 0.4)    
    ReserveScript(func, delay + 0.5)    
    ReserveScript(func, delay + 0.6)
    ReserveScript(func, delay + 0.7)
    
    delay = delay + 1
    local count = 20
    local count_2 = 5
    local time = 2500
    local sound_time = (time / 1000) + 1
    local tick = time / count / 1000 / count_2
    
    eftName = 'GroundImpact_HolySpear_Blue_01'    
    scl = 0.4
    lifeTime = 0
    local inverse = 25
    for i = 1, count do
        for j = 1, count_2 do
            x1, y1, z1 = GetRandomPosInRange(nil, x, y, z, 20, 100)
            delay = delay + tick              
            inverse = inverse * -1
            local deep = 0

            if IMCRandom(1, 100) <= 70 then                
                deep = 50
            end
            effect.PlayGroundUnityEffect(actor, eftName, scl, x1, y1 - deep, z1, lifeTime, "None", inverse + IMCRandom(0, 15), 0, 0, delay);
        end
    end

    for i = 1, sound_time, 0.15 do
        local func = string.format("C_PLAY_SOUND_3('%s', %d, %d, %d)", 'skl_eff_wingedhussars_whoosh', x, y, z)                
        ReserveScript(func, i)
    end
end
