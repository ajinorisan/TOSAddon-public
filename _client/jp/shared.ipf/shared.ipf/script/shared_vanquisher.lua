-- shared_vanquisher.lua

function C_PAD_EFFECT_FORCE_UNITY_EFFECT_Vanquisher_FatalSwordDance(actor, obj, pad_guid, eft_name, eft_scale, fix_height, life_time)
    if actor ~= nil then        
        effect.AddForceProjectileUnityEffect(actor, eft_name, eft_scale, fix_height, pad_guid, life_time);
    end
end

function PLAY_ANIM_Vanquisher_VerticalSlash(actor, skill, spd, freezeAnim, buffName, buffAnimName)    
    local list = {'skl_vanquisher_verticalslash', 'skl_vanquisher_verticalslash2'}
    local ran = IMCRandom(1, 2)
    
    local animName = list[ran]
    local moveAnimName = 'None'    
    if ran == 2 then
        spd = 2.5
    end

    MONSKL_C_CASTING_ANIM(actor, skill, animName, moveAnimName, spd, freezeAnim, buffName, buffAnimName)

    local handle = actor:GetHandleVal()
    local scp = string.format('PLAY_ANIM_Vanquisher_VerticalSlash_effect(%d, %d)', handle, ran)
    local delay = 0.2

    if ran == 2 then        
        delay = delay + 0.1    
    end

    ReserveScript(scp, delay)
    local pos1 = actor:GetPos()
    effect.AddActorUnityEffect(actor, 'eff_cast_normal_red_01#Dummy_L_HAND', 0.8, pos1.x, pos1.y, pos1.z, 0, 0, 0, 1);
end

function PLAY_ANIM_Vanquisher_VerticalSlash_effect(handle, ran)
    local actor = world.GetActor(handle);
    if actor ~= nil then
        local pos1 = actor:GetPos()
        local pos = actor:GetFrontPos(35)    
        local dir_degree = GET_DIRECTION_DEGREE(pos1.x, pos1.z, pos.x, pos.z)        
        
        local effect_name = 'Stab_Dark_Orange_01'
        local effect_scale = 3
        local lifeTime = 0.1
        local deg_angle_x = 45 
        local deg_angle_y = 0 
        local deg_angle_z = 0 

        if dir_degree >= -92 and dir_degree <= -88 then -- 1
            deg_angle_x = 90 
        elseif dir_degree >= -46 and dir_degree <= -44 then -- 2
            deg_angle_x = 135 
        elseif dir_degree >= -1 and dir_degree <= 1 then -- 3
            deg_angle_x = 0 
        elseif dir_degree >= 44 and dir_degree <= 46 then -- 6
            deg_angle_x = 135 
        elseif dir_degree >= 89 and dir_degree <= 91 then -- 9
            deg_angle_x = 0 
        end

        if ran == 2 then
            if dir_degree >= 44 and dir_degree <= 46 then -- 6
                deg_angle_x = 135 
            elseif dir_degree >= 179 and dir_degree <= 181 then -- 7
                deg_angle_x = 90 
            end
        end
        
        local node_name = 'dummy_emitter'
        local monster_key = 'None'
        local off_set = 'None'

        effect.AddActorUnityEffect(actor, effect_name .. '#' .. node_name, effect_scale, pos.x, pos1.y + 20, pos.z, deg_angle_x, deg_angle_y, deg_angle_z, lifeTime);
    end
end

function PLAY_START_EFFECT_Vanquisher_VerticalSlash(actor)
    local pos = actor:GetPos()
    local scale = 0.9
    local height = 0
    effect.AddActorUnityEffect(actor, 'eff_fellow_rogue_sneakytrick_launch_01#dummy_emitter', scale, pos.x, pos.y + height, pos.z, 0, 0, 0, 1);
end

function PLAY_START_EFFECT_Vanquisher_EarthCrusher(actor)
    local pos = actor:GetPos()
    local scale = 0.9
    local height = 20
    effect.AddActorUnityEffect(actor, 'eff_monster_zawra_skill03_cast_01#dummy_emitter', scale, pos.x, pos.y + height, pos.z, 0, 0, 0, 0.5);
end

function PLAY_START_EFFECT_Vanquisher_WindSlasher(actor)
    local pos = actor:GetPos()
    local scale = 0.9
    local height = 0
    local life_time = 1
    effect.AddActorUnityEffect(actor, 'eff_cast_normal_purple_01#Dummy_L_HAND', scale, pos.x, pos.y + height, pos.z, 0, 0, 0, life_time);    
end
function PLAY_START_EFFECT_Vanquisher_FatalSwordDance(actor)
    local pos = actor:GetPos()
    local scale = 0.9
    local height = 5
    local life_time = 1
    effect.AddActorUnityEffect(actor, 'eff_goddessboss_berserkerzawra_skill02_cast_01#Dummy_emitter', scale, pos.x, pos.y + height, pos.z, 0, 0, 0, life_time);        
    effect.AddActorUnityEffect(actor, 'eff_monster_strongholder_skill02_cast_01#Dummy_L_Hand', scale, pos.x, pos.y + height, pos.z, 0, 0, 0, life_time);        
    life_time = 2
    scale = 1
    effect.PlayActorEffect(actor, 'BodyAura_Electric_Red_01', 'Dummy_emitter', life_time, scale);    
end


function VoidSlash_toggle_Buff_ENTER(actor, obj, buff)    
end
function VoidSlash_toggle_Buff_LEAVE(actor, obj, buff)
    actor:GetAnimation():ResetCastingAnim();
end


function SKL_CHECK_BUFF_Vanquisher_VoidSlash_C(actor, skl, buffName)
    if IsServerSection() == 1 then
        return 1
    end

    local myHandle = session.GetMyHandle();
    local buff = info.GetBuffByName(myHandle, buffName);    
    if nil ~= buff then
        return 1;
    end

    return 0;
end

function CHECK_Vanquisher_Buff1_C(actor, skl, buffName, over)
    local myHandle = session.GetMyHandle();    
    local buff = info.GetBuffByName(myHandle, buffName);
    if nil ~= buff then
        if buff.over >= over then
            return 1
        end
    end

    return 0
end

function CHECK_Vanquisher_Buff1(self, skl, name, count)        
    local over =  GetBuffOver(self, name)    
    if over >= count then
        return 1
    end

    return 0
end

function CHECK_Vanquisher_toggle_C(actor, skl, buffName)
    local myHandle = session.GetMyHandle();    
    local buff = info.GetBuffByName(myHandle, buffName);
    if nil == buff then
        return 1
    end

    return 0
end

function CHECK_Vanquisher_toggle(self, skl, name)
    local buff = GetBuffByName(self, name)
    if buff == nil then
        return 1
    end

    return 0
end





-- cpp
function SCR_GET_Vanquisher_VoidSlash_Ratio(skill)    
    local count = 5
    local pc = GetSkillOwner(skill)
    count = GET_PVP_TARGET_COUNT(pc, count)
    return count
end
-- cpp
function SCR_GET_Vanquisher_TurnOver_Ratio(skill)    
    local count = 5
    local pc = GetSkillOwner(skill)
    count = GET_PVP_TARGET_COUNT(pc, count)
    return count
end
-- cpp
function SCR_GET_Vanquisher_EarthCrusher_Ratio(skill)    
    local count = 10
    local pc = GetSkillOwner(skill)
    count = GET_PVP_TARGET_COUNT(pc, count)
    return count
end
-- cpp
function SCR_GET_Vanquisher_WindSlasher_Ratio(skill)    
    local count = 10
    local pc = GetSkillOwner(skill)
    count = GET_PVP_TARGET_COUNT(pc, count)
    return count
end
-- cpp
function SCR_GET_Vanquisher_FatalSwordDance_Ratio(skill)    
    local count = 15
    local pc = GetSkillOwner(skill)
    count = GET_PVP_TARGET_COUNT(pc, count)
    return count
end
-- cpp
function SCR_GET_Vanquisher_VerticalSlash_Ratio(skill)
    local count = 1
    local pc = GetSkillOwner(skill)
    if GetExProp(pc, 'Vanquisher1_1') > 0 then
        count = 5
    end
    
    count = GET_PVP_TARGET_COUNT(pc, count)
    return count
end
-- cpp
function SCR_Get_SpendSP_VoidSlash(skill)
    local value = SCR_Get_SpendSP_Magic(skill)    
    local pc = GetSkillOwner(skill);

    if pc == nil then
        return math.floor(value);
    end

    local v = GetExProp(pc, 'Vanquisher3_1')
    if v > 0 then
        value = value * (1 + v)
    end
    
    return value
end
-- cpp
function SCR_GET_SKL_COOLDOWN_voidslash(skill)
    local pc = GetSkillOwner(skill);
    local basicCoolDown = skill.BasicCoolDown;
    
    local active = GetExProp(pc, 'Vanquisher6_1')    
    if active > 0 then
        basicCoolDown = basicCoolDown + 5000
    end

    local abilAddCoolDown = GetAbilityAddSpendValue(pc, skill.ClassName, "CoolDown");
    basicCoolDown = basicCoolDown + abilAddCoolDown;
    
    local coolDownClassify, zoneAddCoolDown = SCR_GET_SKILL_RESTRICT_ARG(pc, skill)
    basicCoolDown = SCR_COMMON_COOLDOWN_DECREASE(pc, skill, basicCoolDown)    
    
    local ret = math.floor(basicCoolDown) / 1000    
    ret = ret * 1000;
    if coolDownClassify == "Fix" then
        ret = zoneAddCoolDown;
    elseif coolDownClassify == "Add" then
        ret = zoneAddCoolDown + ret
    end

    return math.floor(ret);
end
-- cpp
function SCR_Get_SkillFactor_VerticalSlash(skill)
    local pc = GetSkillOwner(skill)
    local value = SCR_Get_SkillFactor_Reinforce_Ability(skill)

    if GetExProp(pc, 'Vanquisher1_1') > 0 then
        value = value * 0.5
    end

    return math.floor(value)
end