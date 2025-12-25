--monskl_customscp.xml

--@Desc: 대상 지점(위치)에 이팩트 재생
function C_UNITY_EFFECT_POS(actor, obj, eftName, effect_scale, x, y, z, lifeTime, key, deg_angle_x, deg_angle_y, deg_angle_z, delaySec)
    ----------------------------------------------------
    -- default settings start --
    if key == nil then key = "None" end
    if lifeTime ==nil then lifeTime = 0 end
    if deg_angle_x ==nil then deg_angle_x = 0 end
    if deg_angle_y ==nil then deg_angle_y = 0 end
    if deg_angle_z ==nil then deg_angle_z = 0 end
    if delaySec ==nil then delaySec = 0 end
    -- default settings end --

    effect.PlayGroundUnityEffect(actor,eftName, effect_scale, x, y, z,lifeTime, key, deg_angle_x, deg_angle_y, deg_angle_z, delaySec)
end

--@Desc: 대상의 부위(노드)에 이팩트 붙이기
function C_UNITY_EFFECT_NODE(actor, obj, effect_name, effect_scale, lifeTime, deg_angle_x, deg_angle_y, deg_angle_z, node_name, monster_key, off_set)
    -- default settings start --
    if lifeTime ==nil then lifeTime = 0 end
    if deg_angle_x ==nil then deg_angle_x = 0 end
    if deg_angle_y ==nil then deg_angle_y = 0 end
    if deg_angle_z ==nil then deg_angle_z = 0 end
    if node_name ==nil then node_name = "None" end
    if monster_key ==nil then monster_key = "None" end
    if off_set == nil then off_set = 'None' end
    -- default settings end --

    effect.PlayUnityEffectNode(actor, effect_name, effect_scale,lifeTime, deg_angle_x, deg_angle_y, deg_angle_z, node_name, monster_key, off_set);
end

function C_UNITY_EFFECT_NODE_ABIL(actor, obj, effect_name, effect_scale, lifeTime, deg_angle_x, deg_angle_y, deg_angle_z, node_name, monster_key,abilName)
    -- default settings start --
    if lifeTime ==nil then lifeTime = 0 end
    if deg_angle_x ==nil then deg_angle_x = 0 end
    if deg_angle_y ==nil then deg_angle_y = 0 end
    if deg_angle_z ==nil then deg_angle_z = 0 end
    if node_name ==nil then node_name = "None" end
    if monster_key ==nil then monster_key = "None" end
    -- default settings end --
    if abilName ~= nil and type(abilName) == 'string' and abilName ~= 'None' then
		local abil = session.GetAbilityByName(abilName);
		if abil ~= nil then
			local abilObj = GetIES(abil:GetObject());
			if abilObj.ActiveState == 1 then
                if lifeTime == nil then
                    lifeTime = 0;    
                end
                effect.PlayUnityEffectNode(actor, effect_name, effect_scale,lifeTime, deg_angle_x, deg_angle_y, deg_angle_z, node_name, monster_key);
            end
        end
    end
end

--@Desc: 대상 모델에 대략적인 높이 위치에서 오프셋/회전값 만큼을 증감하여 이팩트 붙이기
--(param desc) start_height_offset : TOP/MID/BOT(default) 중 택 1
function C_UNITY_EFFECT_ATTACH(actor, obj, effect_name, effect_scale, deg_angle_x, deg_angle_y, deg_angle_z, start_height_offset, offset_x,offset_y,offset_z, duplicate)
    -- default settings start --
    if deg_angle_x ==nil then deg_angle_x = 0 end
    if deg_angle_y ==nil then deg_angle_y = 0 end
    if deg_angle_z ==nil then deg_angle_z = 0 end
    if start_height_offset ==nil then start_height_offset = "BOT" end
    if offset_x ==nil then offset_x = 0 end
    if offset_y ==nil then offset_y = 0 end
    if offset_z ==nil then offset_z = 0 end
    if duplicate ==nil or duplicate==0 then duplicate = false end
    if duplicate ==1 then duplicate = true end
    -- default settings end --
    effect.AttachUnityEffect(actor, effect_name, effect_scale, deg_angle_x, deg_angle_y, deg_angle_z, start_height_offset, offset_x,offset_y,offset_z, duplicate);
end

function C_UNITY_EFFECT_ATTACH_ABIL(actor, obj, effect_name, effect_scale, deg_angle_x, deg_angle_y, deg_angle_z, start_height_offset, offset_x,offset_y,offset_z, duplicate,abilName)
    -- default settings start --
    if deg_angle_x ==nil then deg_angle_x = 0 end
    if deg_angle_y ==nil then deg_angle_y = 0 end
    if deg_angle_z ==nil then deg_angle_z = 0 end
    if start_height_offset ==nil then start_height_offset = "BOT" end
    if offset_x ==nil then offset_x = 0 end
    if offset_y ==nil then offset_y = 0 end
    if offset_z ==nil then offset_z = 0 end
    if duplicate ==nil or duplicate==0 then duplicate = false end
    if duplicate ==1 then duplicate = true end
    -- default settings end --
    if abilName ~= nil and type(abilName) == 'string' and abilName ~= 'None' then
		local abil = session.GetAbilityByName(abilName);
		if abil ~= nil then
			local abilObj = GetIES(abil:GetObject());
			if abilObj.ActiveState == 1 then
                effect.AttachUnityEffect(actor, effect_name, effect_scale, deg_angle_x, deg_angle_y, deg_angle_z, start_height_offset, offset_x,offset_y,offset_z, duplicate);
            end
        end
    end
end

--@Desc: world 내 동일명의 타겟 이팩트 모두 제거
function C_UNITY_EFFECT_REMOVE_BY_NAME(actor,obj, eftName, blendtime)
    -- default settings start --
    if blendtime == nil then blendtime = 0 end
    -- default settings end -- 
    
    effect.RemoveGroundUnityEffect(eftName, blendtime);
end

--@Desc: actor에 지정된 이팩트가 key 값이 존재할 경우 key값으로 해당 이팩트 제거 
function C_UNITY_EFFECT_REMOVE_BY_KEY(actor,obj, key, blendtime)
    -- default settings start --
    if blendtime == nil then blendtime = 0 end
    -- default settings end -- 

    effect.RemoveGroundEffect(key, blendtime);
end

function C_UNITY_EFFECT_DETACH(actor,obj, eftName)
    effect.DetachUnityEffect(actor, eftName, false);
end


function C_PAD_GROUND_EFFECT(actor, obj, pad_guid, eft_name, eft_scale, fix_height)
    if fix_height == nil then
        fix_height = 0
    end
	
	effect.PlayPadForceUnityEffect(actor, eft_name, eft_scale, 0, 0, 0, fix_height, pad_guid);
end

function C_FORCE_UNITY_EFT(actor, obj, eft_name, eft_scale, shoot_sound, fin_eft_name, fin_eft_scale, finish_sound, angle_x, angle_y, angle_z, destroy, speed, easing, gravity, angle, hit_index, collrange, create_length, raidus_speed, is_last_force, use_hit_eft, link_tex_name, dist, offset_angle, height, delay_start, fix_ver_dir)
    local custom_target = 0
    if use_hit_eft == nil then use_hit_eft = 1 end
    if raidus_speed == nil then raidus_speed = 0.0 end
    if create_length == nil then create_length = 0.0 end
    if link_tex_name == nil then link_tex_name ="None" end
    if delay_start == nil then delay_start = 0 end
    if fix_ver_dir == nil then fix_ver_dir = 0 end

    local add_x, add_y, add_z = 0, 0, 0
    if dist ~= nil and offset_angle ~= nil and height ~= nil then
        if dist > 0 then
            offset_angle = DegToRad(offset_angle)
            add_x = math.cos(offset_angle) * dist
            add_y = height
            add_z = math.sin(offset_angle) * dist
        end
    end

    local ret = actor:GetForce():PlayForce_Tool_UnityEffect(eft_name, eft_scale, shoot_sound, fin_eft_name, fin_eft_scale, finish_sound, angle_x, angle_y, angle_z, destroy, speed, easing, gravity, angle, hit_index, collrange, create_length, raidus_speed, use_hit_eft, custom_target, link_tex_name, delay_start, add_x, add_y, add_z, fix_ver_dir)
    
    if is_last_force == 1 or is_last_force == nil then
        actor:EnableSkillCancel(1)
    end

    return ret
end