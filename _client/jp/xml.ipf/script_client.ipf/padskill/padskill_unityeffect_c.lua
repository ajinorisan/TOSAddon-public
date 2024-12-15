-- padskill_unityeffect_c.lua
-- 장판 포스 이펙트
function C_PAD_EFFECT_FORCE_UNITY_EFFECT(actor, obj, pad_guid, eft_name, eft_scale, eft_rot, fix_height)
	-- unity effect rot angle
	local eft_rot_x, eft_rot_y, eft_rot_z;
	local eft_rot_list = StringSplit(eft_rot, '/');
	if #eft_rot_list >= 3 then
		eft_rot_x = tonumber(eft_rot_list[1]);
		eft_rot_y = tonumber(eft_rot_list[2]);
		eft_rot_z = tonumber(eft_rot_list[3]);
	end
	effect.PlayPadForceUnityEffect(actor, eft_name, eft_scale, eft_rot_x, eft_rot_y, eft_rot_z, fix_height, pad_guid);
end

-- 장판 포스 이펙트 : 지연 시간
function C_PAD_DELAY_UNITY_EFFECT_FORCE(actor, obj, pad_guid, eft_name, eft_scale, eft_rot, fix_height, delay)
	local owner = geClientPadSkill.GetPadOwner(pad_guid);
	if owner ~= nil then
		-- unity effect rot angle
		local eft_rot_x, eft_rot_y, eft_rot_z;
		local eft_rot_list = StringSplit(eft_rot, '/');
		if #eft_rot_list >= 3 then
			eft_rot_x = tonumber(eft_rot_list[1]);
			eft_rot_y = tonumber(eft_rot_list[2]);
			eft_rot_z = tonumber(eft_rot_list[3]);
		end
		effect.PlayPadDelayForceUnityEffect(owner, eft_name, eft_scale, eft_rot_x, eft_rot_y, eft_rot_z, fix_height, pad_guid, delay);
	end
end

--@Desc: 대상 지점(위치)에 이팩트 재생
function C_PAD_UNITY_EFFECT_POS(actor, obj,pad_guid, eftName, effect_scale, x, y, z, lifeTime, key, deg_angle_x, deg_angle_y, deg_angle_z, delaySec)
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