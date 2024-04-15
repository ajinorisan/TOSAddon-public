-- shared_bowmaster.lua

-- cpp
function SCR_GET_SKL_COOLDOWN_FocusFire(skill)
    local pc = GetSkillOwner(skill);
    local basicCoolDown = skill.BasicCoolDown;
    
    local active = GetExProp(pc, 'bowmaster_fast')        
    if active > 0 then
        basicCoolDown = 800
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
function SCR_GET_SKL_COOLDOWN_DodgeFire(skill)
    local pc = GetSkillOwner(skill);
    local basicCoolDown = skill.BasicCoolDown;
    
    local active = GetExProp(pc, 'bowmaster_fast')
    if active > 0 then
        basicCoolDown = 4000
    end

    local abilAddCoolDown = GetAbilityAddSpendValue(pc, skill.ClassName, "CoolDown");
    basicCoolDown = basicCoolDown + abilAddCoolDown;
    
    local coolDownClassify, zoneAddCoolDown = SCR_GET_SKILL_RESTRICT_ARG(pc, skill)
    basicCoolDown = SCR_COMMON_COOLDOWN_DECREASE(pc, skill, basicCoolDown)
    
    local ret = math.floor(basicCoolDown) / 1000
    ret = math.floor(ret) * 1000;
    if coolDownClassify == "Fix" then
        ret = zoneAddCoolDown;
    elseif coolDownClassify == "Add" then
        ret = zoneAddCoolDown + ret
    end
    
    return math.floor(ret);
end
-- cpp
function SCR_GET_SKL_COOLDOWN_SkyBow(skill)
    local pc = GetSkillOwner(skill);
    local basicCoolDown = skill.BasicCoolDown;
    
    local active = GetExProp(pc, 'bowmaster_fast')
    if active > 0 then
        basicCoolDown = 15000
    end

    local abilAddCoolDown = GetAbilityAddSpendValue(pc, skill.ClassName, "CoolDown");
    basicCoolDown = basicCoolDown + abilAddCoolDown;
    
    local coolDownClassify, zoneAddCoolDown = SCR_GET_SKILL_RESTRICT_ARG(pc, skill)
    basicCoolDown = SCR_COMMON_COOLDOWN_DECREASE(pc, skill, basicCoolDown)
    
    local ret = math.floor(basicCoolDown) / 1000
    ret = math.floor(ret) * 1000;
    if coolDownClassify == "Fix" then
        ret = zoneAddCoolDown;
    elseif coolDownClassify == "Add" then
        ret = zoneAddCoolDown + ret
    end
    
    return math.floor(ret);
end
-- cpp
function SCR_GET_SKL_COOLDOWN_ScatterShot(skill)
    local pc = GetSkillOwner(skill);
    local basicCoolDown = skill.BasicCoolDown;
    
    local active = GetExProp(pc, 'bowmaster_fast')
    if active > 0 then
        basicCoolDown = 5000
    end

    local abilAddCoolDown = GetAbilityAddSpendValue(pc, skill.ClassName, "CoolDown");
    basicCoolDown = basicCoolDown + abilAddCoolDown;
    
    local coolDownClassify, zoneAddCoolDown = SCR_GET_SKILL_RESTRICT_ARG(pc, skill)
    basicCoolDown = SCR_COMMON_COOLDOWN_DECREASE(pc, skill, basicCoolDown)
    
    local ret = math.floor(basicCoolDown) / 1000
    ret = math.floor(ret) * 1000;
    if coolDownClassify == "Fix" then
        ret = zoneAddCoolDown;
    elseif coolDownClassify == "Add" then
        ret = zoneAddCoolDown + ret
    end
    
    return math.floor(ret);
end
-- cpp
function SCR_GET_SKL_COOLDOWN_Hyunmoo(skill)
    local pc = GetSkillOwner(skill);
    local basicCoolDown = skill.BasicCoolDown;
    
    local active = GetExProp(pc, 'bowmaster_fast')
    if active > 0 then
        basicCoolDown = 5000
    end

    local abilAddCoolDown = GetAbilityAddSpendValue(pc, skill.ClassName, "CoolDown");
    basicCoolDown = basicCoolDown + abilAddCoolDown;
    
    local coolDownClassify, zoneAddCoolDown = SCR_GET_SKILL_RESTRICT_ARG(pc, skill)
    basicCoolDown = SCR_COMMON_COOLDOWN_DECREASE(pc, skill, basicCoolDown)
    
    local ret = math.floor(basicCoolDown) / 1000
    ret = math.floor(ret) * 1000;
    if coolDownClassify == "Fix" then
        ret = zoneAddCoolDown;
    elseif coolDownClassify == "Add" then
        ret = zoneAddCoolDown + ret
    end
    
    return math.floor(ret);
end
-- cpp
function SCR_GET_SKL_COOLDOWN_GodArrow(skill)
    local pc = GetSkillOwner(skill);
    local basicCoolDown = skill.BasicCoolDown;
    
    local active = GetExProp(pc, 'bowmaster_fast')
    if active > 0 then
        basicCoolDown = 5000
    end

    local abilAddCoolDown = GetAbilityAddSpendValue(pc, skill.ClassName, "CoolDown");
    basicCoolDown = basicCoolDown + abilAddCoolDown;
    
    local coolDownClassify, zoneAddCoolDown = SCR_GET_SKILL_RESTRICT_ARG(pc, skill)
    basicCoolDown = SCR_COMMON_COOLDOWN_DECREASE(pc, skill, basicCoolDown)
    
    local ret = math.floor(basicCoolDown) / 1000
    ret = math.floor(ret) * 1000;
    if coolDownClassify == "Fix" then
        ret = zoneAddCoolDown;
    elseif coolDownClassify == "Add" then
        ret = zoneAddCoolDown + ret
    end
    
    return math.floor(ret);
end
-- cpp (회득)
function SCR_GET_BowMaster_SkyBow_Ratio(skill)    
    local value = 0.4 * (skill.Level * 1.5)    
    return value
end
-- cpp (기절)
function SCR_GET_BowMaster_SkyBow_Ratio2(skill)
    local value = 1 * (skill.Level * 1.5)
    return value
end
-- cpp (지속시간)
function SCR_GET_BowMaster_SkyBow_CaptionTime(skill)
    local value = 3 + (0.4 * skill.Level)
    return value
end
-- cpp
function SCR_Get_SkillFactor_BowMaster_FocusFire(skill)
    local pc = GetSkillOwner(skill)
    local value = SCR_Get_SkillFactor_Reinforce_Ability(skill)

    if GetExProp(pc, 'BowMaster10') > 0 then
        value = value * 0.5
    end

    return math.floor(value)
end
-- cpp
function SCR_Get_SkillFactor_BowMaster_GodArrow(skill)
    local pc = GetSkillOwner(skill)
    local value = SCR_Get_SkillFactor_Reinforce_Ability(skill)

    if GetExProp(pc, 'BowMaster14') > 0 then
        value = value * 0.75
    end

    return math.floor(value)
end









function MONSKL_C_STOP_ANIM_BowMaster_SkyBow(actor)
    if actor == nil then
        return
    end
    actor:GetAnimation():ResetAnim();
    actor:GetAnimation():PlayFixAnim('SKL_VENDETTA_SHOT', 1, 0, 0, 0, 0, true, 0, false);
    actor:GetAnimation():StopFixAnim();
end

function BowMaster_ActorBlend(actor, obj, r, g, b, a)
    actor:GetEffect():ActorColorBlend(1, r/255, g/255, b/255, a/255, 0);
end


function C_PAD_EFFECT_FORCE_UNITY_EFFECT_BOWMASTER(actor, obj, pad_guid, eft_name, eft_scale, fix_height)
    if actor ~= nil then        
        effect.AddForceProjectileUnityEffect(actor, eft_name, eft_scale, fix_height, pad_guid);
    end
end

function CHECK_BowMaster_ChargeArrow_Buff_C(actor, skl, buffName, over)
    local myHandle = session.GetMyHandle();    
    local buff = info.GetBuffByName(myHandle, buffName);
    if nil ~= buff then
        if buff.over >= over then
            return 1
        end
    end

    return 0
end
function get_bowmaster_casting_time(skill)
    local self = GetSkillOwner(skill)        
    local value = 2.4
    if GetExProp(self, 'BowMaster14') == 1 then
        value = 1.2
    end    
    return value
end
function get_godarrow_casting_time(self, obj)
    local value = 2.4
    local abil = session.GetAbilityByName('BowMaster14');
    if abil ~= nil then
        local abilObj = GetIES(abil:GetObject());
        if abilObj.ActiveState == 1 then
            value = 1.2
        end
    else
        value = 2.4
    end                    
    return value
end
function get_remove_buff_tooltip_BowMaster_ScatterShot(level)
    local percent = 10 * tonumber(level)    
    if percent > 100 then
        percent = 100
    end

    local remove_count = 1

    -- buff_type, lv, count, percent, relation, boss_check
    local str = string.format('Buff/3/%d/%.2f/ENEMY/0', remove_count, percent)    
    return str
end

function effect_focus_fire_arrow(actor, obj, eftName, scl, scl2, x, y, z, autoDetach, angle_x, angle_y, angle_z, life_time)    
    local handle = actor:GetHandleVal()        
    local scp = string.format('run_effect_focus_fire_arrow(%d, %.2f)', handle, y)
    for i = 0, 10, 3 do    
        ReserveScript(scp, i / 10, "run_effect_focus_fire_arrow_" .. tostring(handle))        
    end
end

function delay_reset_castanim(actor, obj)    
    local handle = actor:GetHandleVal()
    local scp = string.format('run_delay_reset_castanim(%d)', handle)
    ReserveScript(scp, 0.2, "run_delay_reset_castanim_" .. tostring(handle))        
end

function run_delay_reset_castanim(handle)    
    local actor = world.GetActor(handle);
    if actor ~= nil then
        actor:GetAnimation():ResetCastingAnim();
    end
end

function stop_effect_focus_fire_arrow(actor, obj)
    if actor == nil then
        return
    end
    local handle = actor:GetHandleVal()            
    RemoveReserveScript("run_effect_focus_fire_arrow_" .. tostring(handle)) 
end

function run_effect_focus_fire_arrow(handle, y)    
    local actor = world.GetActor(handle);
    local pos = actor:GetPos()
    effect.AddActorUnityEffect(actor, 'eff_fellow_fencer_stab_02#Dummy_R_HAND', 0.4, pos.x, y, pos.z, 90, 0, 0, 1);
    actor:GetEffect():AddAutoDetachEffect('eff_fellow_fencer_stab_02#Dummy_R_HAND');    
end 


function effect_god_arrow(actor, obj, eftName, scl, x, y, z, angle_x, angle_y, angle_z, life_time)        
    if actor == nil then
        return
    end
    local handle = actor:GetHandleVal()        
    local scp = string.format('run_effect_god_arrow(%d, %.2f, %.2f, %.2f, %.2f)', handle, x, y, z, scl)
    ReserveScript(scp, 0.8, "run_effect_god_arrow_" .. tostring(handle))
end

function stop_effect_god_arrow(actor, obj)
    if actor == nil then
        return
    end
    local handle = actor:GetHandleVal()            
    RemoveReserveScript("run_effect_god_arrow_" .. tostring(handle)) 
end

function run_effect_god_arrow(handle, x, y, z, scale)        
    local actor = world.GetActor(handle);
    local pos = actor:GetPos()    
    effect.AddActorUnityEffect(actor, 'eff_monster_velclipse_sealed_map_projectile_01#Dummy_R_HAND', scale, x, y, z, 90, 0, 0, 3);
    actor:GetEffect():AddAutoDetachEffect('eff_monster_velclipse_sealed_map_projectile_01#Dummy_R_HAND');    
end 

function effect_godarrow(actor, obj, eftName, scl, x, y, z, angle_x, angle_y, angle_z, life_time)        
    if actor == nil then
        return
    end
    effect.AddActorUnityEffect(actor, eftName, scl, x, y, z, angle_x, angle_y, angle_z, life_time);
    actor:GetEffect():AddAutoDetachEffect(eftName);    
end

function effect_spin_god_arrow(actor, obj, effect_name, scale, node, lifetime, angle_x, angle_y, angle_z)    
    if actor == nil then
        return
    end
    local handle = actor:GetHandleVal()
    local time = 2
    local max = time * 3
    for i = 1, max do
        local scp = string.format('run_effect_spin_god_arrow(%d, "%s", %.2f, "%s", %.2f, %.2f, %.2f, %.2f)', handle, effect_name, scale * ((max - i - 1)/max), node, lifetime, angle_x, angle_y, angle_z)
        ReserveScript(scp, time * ((i-1)/max), "run_effect_spin_god_arrow_" .. tostring(handle))        
    end
end

function stop_effect_spin_god_arrow(actor, obj)
    if actor == nil then
        return
    end
    local handle = actor:GetHandleVal()            
    RemoveReserveScript("run_effect_spin_god_arrow_" .. tostring(handle)) 
end

function run_effect_spin_god_arrow(handle, effect_name, scale, node, lifetime, angle_x, angle_y, angle_z)
    local actor = world.GetActor(handle);
    effect.PlayUnityEffectNode(actor, effect_name, scale, lifetime, angle_x, angle_y, angle_z, node, 'None', 'None');
end

function run_effect_godarrow_cast(actor, obj, effect_name, effect_scale, deg_angle_x, deg_angle_y, deg_angle_z, start_height_offset, offset_x,offset_y,offset_z, duplicate)    
    if actor == nil then
        return
    end
    local handle = actor:GetHandleVal()   
    local scp = string.format('run_effect_godarrow_cast2(%d, "%s", %.2f, %.2f, %.2f, %.2f, "%s", %.2f, %.2f, %.2f, %d)', handle, effect_name, effect_scale, deg_angle_x, deg_angle_y, deg_angle_z, start_height_offset, offset_x,offset_y,offset_z, duplicate)
    ReserveScript(scp, 0.7)        
end

function run_effect_godarrow_cast2(handle, effect_name, effect_scale, deg_angle_x, deg_angle_y, deg_angle_z, start_height_offset, offset_x,offset_y,offset_z, duplicate)
    local actor = world.GetActor(handle)
    local dup = false
    if duplicate == 1 then
        dup = true
    end    
    effect.AttachUnityEffect(actor, effect_name, effect_scale, deg_angle_x, deg_angle_y, deg_angle_z, start_height_offset, offset_x,offset_y,offset_z, dup);
end

function effect_spin_god_arrow2(actor, obj, effect_name, scale, node, lifetime, angle_x, angle_y, angle_z)    
    if actor == nil then
        return
    end
    local handle = actor:GetHandleVal()
    local time = 2.5
    local max = 4
    local scl_list = {0.3, 0.5, 0.7, 1.1}
    local time_list = {0, 0.4, 0.8, 1.3}
    for i = 1, max do
        local scl = scale * (1 + i / max) * 1.5
        scl = scl_list[i]
        local scp = string.format('run_effect_spin_god_arrow2(%d, "%s", %.2f, "%s", %.2f, %.2f, %.2f, %.2f)', handle, effect_name, scl, node, lifetime, angle_x, angle_y, angle_z)
        ReserveScript(scp, time_list[i], "run_effect_spin_god_arrow2_" .. tostring(handle))        
    end
end

function stop_effect_spin_god_arrow2(actor, obj)
    if actor == nil then
        return
    end
    local handle = actor:GetHandleVal()            
    RemoveReserveScript("run_effect_spin_god_arrow2_" .. tostring(handle)) 
end

function run_effect_spin_god_arrow2(handle, effect_name, scale, node, lifetime, angle_x, angle_y, angle_z)
    local actor = world.GetActor(handle);
    effect.PlayUnityEffectNode(actor, effect_name, scale, lifetime, angle_x, angle_y, angle_z, node, 'None', 'BOT');
end

function play_motion_godarrow(actor, obj)
    if actor == nil then
        return
    end
    local handle = actor:GetHandleVal()    
    if handle == session.GetMyHandle() then
        local scp = string.format('run_play_motion_godarrow(%d)', handle)
        ReserveScript(scp, 0.8, "run_play_motion_godarrow_" .. tostring(handle))        
    end
end
function run_play_motion_godarrow(handle)
    local actor = world.GetActor(handle)    
    local time = 4
    local freq = 80
    local intensity = 3
    world.ShockWave(actor, 2, 999, intensity, time, freq, 0);
end
function stop_play_motion_godarrow(actor, obj)
    if actor == nil then
        return
    end
    local handle = actor:GetHandleVal()    
    if handle == session.GetMyHandle() then        
        RemoveReserveScript("run_play_motion_godarrow_" .. tostring(handle)) 
        world.StopShockWave()
    end
end


function play_sound_godarrow(actor, obj, name)    
    if actor == nil then
        return
    end
    local handle = actor:GetHandleVal()    
    if handle == session.GetMyHandle() then
        local scp = string.format('run_play_sound_godarrow(%d, "%s")', handle, name)    
        for i = 1, 4 do
            ReserveScript(scp, i, "run_play_sound_godarrow" .. tostring(handle))        
        end
    end
end
function run_play_sound_godarrow(handle, name)        
    local actor = world.GetActor(handle)    
    if actor ~= nil then
        actor:GetEffect():PlaySound(name)
    end
end
function stop_play_sound_godarrow(actor, obj)
    if actor == nil then
        return
    end
    local handle = actor:GetHandleVal()    
    RemoveReserveScript("run_play_sound_godarrow" .. tostring(handle))
end

function get_godarrow_quickcast_state(self, obj)
    local value = 1
    local abil = session.GetAbilityByName('BowMaster14');
    if abil ~= nil then
        local abilObj = GetIES(abil:GetObject());
        if abilObj.ActiveState == 1 then
            value = 0
        end
    else
        value = 1
    end                        
    return value
end


-- cpp
function SCR_Get_SpendSP_ByFast(skill)
    local value = SCR_Get_SpendSP_Magic(skill)    
    local pc = GetSkillOwner(skill);

    if pc == nil then
        return math.floor(value);
    end

    local v = GetExProp(pc, 'bowmaster_fast')
    if v > 0 then
        value = value * (1 + v)
    end
    
    return value
end
