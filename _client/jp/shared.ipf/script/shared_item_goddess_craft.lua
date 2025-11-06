-- shared_item_goddess_craft.lua, 가디스 장비 제작/계승 관련


local parameter_list = nil
function make_parameter_list()
	if parameter_list ~= nil then
		return
	end

	parameter_list = {}

	parameter_list[1] = {} -- 1 -> 120 으로 계승
	parameter_list[1]['Armor'] = 120 -- 계승 대상 아이템 UseLv
	parameter_list[1]['Weapon'] = 120 -- 계승 대상 아이템 UseLv

	parameter_list[120] = {} -- 120 -> 280 으로 계승
	parameter_list[120]['Armor'] = 280 -- 계승 대상 아이템 UseLv
	parameter_list[120]['Weapon'] = 280 -- 계승 대상 아이템 UseLv

	parameter_list[280] = {} -- 280 -> 480 으로 계승
	parameter_list[280]['Armor'] = 480 -- 계승 대상 아이템 UseLv
	parameter_list[280]['Weapon'] = 480 -- 계승 대상 아이템 UseLv

	parameter_list[440] = {} -- 440제부터 계승 가능하므로 440부터 시작
	parameter_list[440]['Armor'] = 460 -- 계승 대상 아이템 UseLv
	parameter_list[440]['Weapon'] = 460 -- 계승 대상 아이템 UseLv

	parameter_list[450] = {} -- 
	parameter_list[450]['Acc'] = 470 -- 계승 대상 아이템 UseLv

	parameter_list[460] = {} -- 
	parameter_list[460]['Weapon'] = 480 -- 계승 대상 아이템 UseLv	
	parameter_list[460]['Armor'] = 480 -- 계승 대상 아이템 UseLv	

	parameter_list[470] = {} -- 
	parameter_list[470]['Acc'] = 490 -- 이시다비 -> 바우드
	
	parameter_list[480] = {}
	parameter_list[480]['Weapon'] = 500
	parameter_list[480]['Armor'] = 500

	parameter_list[490] = {} -- 
	parameter_list[490]['Acc'] = 510 -- 바우드 -> 네빌티스

	parameter_list[500] = {} -- 500 -> 520 으로 계승
	parameter_list[500]['Weapon'] = 520
	parameter_list[500]['Armor'] = 520

	parameter_list[510] = {} 
	parameter_list[510]['Acc'] = 530 -- 네빌티스 -> 칼렌티스

	parameter_list[520] = {} -- 520 -> 540 으로 계승
	parameter_list[520]['Weapon'] = 540
	parameter_list[520]['Armor'] = 540

end
make_parameter_list()

function GET_INHERIT_TARGET_ITEM_LV(lv, item)
	local group_name = TryGetProp(item, 'GroupName', 'None')	
	if group_name == 'SubWeapon' then
		group_name = 'Weapon'
	end
	if group_name == 'Armor' then
		if TryGetProp(item, 'ClassType', 'None') == 'Ring' or TryGetProp(item, 'ClassType', 'None') == 'Neck' then
			group_name = 'Acc'
		end
	end

	if parameter_list[lv] == nil then
		return nil
	end
	
	if parameter_list[lv][group_name] == nil then
		return nil
	end
	
	return parameter_list[lv][group_name]
end

local item_goddess_inherit_target_list = nil

function setting_lv120_inherit_target_list(list_by_lv)
	list_by_lv[120]['Weapon'] = {
		'GROWTH_REINFORCE_TIER2_SWORD',
		'GROWTH_REINFORCE_TIER2_THSWORD',
		'GROWTH_REINFORCE_TIER2_STAFF',
		'GROWTH_REINFORCE_TIER2_THBOW',
		'GROWTH_REINFORCE_TIER2_BOW',
		'GROWTH_REINFORCE_TIER2_MACE',
		'GROWTH_REINFORCE_TIER2_THMACE',
		'GROWTH_REINFORCE_TIER2_SHIELD',
		'GROWTH_REINFORCE_TIER2_SPEAR',
		'GROWTH_REINFORCE_TIER2_THSPEAR',
		'GROWTH_REINFORCE_TIER2_DAGGER',
		'GROWTH_REINFORCE_TIER2_THSTAFF',
		'GROWTH_REINFORCE_TIER2_PISTOL',
		'GROWTH_REINFORCE_TIER2_RAPIER',
		'GROWTH_REINFORCE_TIER2_CANNON',
		'GROWTH_REINFORCE_TIER2_MUSKET',
		'GROWTH_REINFORCE_TIER2_TRINKET',
	}

	list_by_lv[120]['Armor'] = {
		'GROWTH_REINFORCE_TIER2_LEATHER_TOP',
		'GROWTH_REINFORCE_TIER2_LEATHER_LEG',
		'GROWTH_REINFORCE_TIER2_LEATHER_FOOT',
		'GROWTH_REINFORCE_TIER2_LEATHER_HAND',		
	}
end

function setting_lv280_inherit_target_list(list_by_lv)
	list_by_lv[280]['Weapon'] = {
		'GROWTH_REINFORCE_TIER3_SWORD',
		'GROWTH_REINFORCE_TIER3_THSWORD',
		'GROWTH_REINFORCE_TIER3_STAFF',
		'GROWTH_REINFORCE_TIER3_THBOW',
		'GROWTH_REINFORCE_TIER3_BOW',
		'GROWTH_REINFORCE_TIER3_MACE',
		'GROWTH_REINFORCE_TIER3_THMACE',
		'GROWTH_REINFORCE_TIER3_SHIELD',
		'GROWTH_REINFORCE_TIER3_SPEAR',
		'GROWTH_REINFORCE_TIER3_THSPEAR',
		'GROWTH_REINFORCE_TIER3_DAGGER',
		'GROWTH_REINFORCE_TIER3_THSTAFF',
		'GROWTH_REINFORCE_TIER3_PISTOL',
		'GROWTH_REINFORCE_TIER3_RAPIER',
		'GROWTH_REINFORCE_TIER3_CANNON',
		'GROWTH_REINFORCE_TIER3_MUSKET',
		'GROWTH_REINFORCE_TIER3_TRINKET',
	}

	list_by_lv[280]['Armor'] = {
		'GROWTH_REINFORCE_TIER3_LEATHER_TOP',
		'GROWTH_REINFORCE_TIER3_LEATHER_LEG',
		'GROWTH_REINFORCE_TIER3_LEATHER_FOOT',
		'GROWTH_REINFORCE_TIER3_LEATHER_HAND',		
	}
end

function setting_lv460_inherit_target_list(list_by_lv)
	list_by_lv[460]['Weapon'] = {
		'EP13_RAID_SWORD',
		'EP13_RAID_THSWORD',
		'EP13_RAID_STAFF',
		'EP13_RAID_THBOW',
		'EP13_RAID_BOW',
		'EP13_RAID_MACE',
		'EP13_RAID_THMACE',
		'EP13_RAID_SHIELD',
		'EP13_RAID_SPEAR',
		'EP13_RAID_THSPEAR',
		'EP13_RAID_DAGGER',
		'EP13_RAID_THSTAFF',
		'EP13_RAID_PISTOL',
		'EP13_RAID_RAPIER',
		'EP13_RAID_CANNON',
		'EP13_RAID_MUSKET',
		'EP13_RAID_TRINKET',
	}

	list_by_lv[460]['Armor'] = {
		'EP13_RAID_CLOTH_TOP',
		'EP13_RAID_CLOTH_LEG',
		'EP13_RAID_CLOTH_FOOT',
		'EP13_RAID_CLOTH_HAND',
		'EP13_RAID_LEATHER_TOP',
		'EP13_RAID_LEATHER_LEG',
		'EP13_RAID_LEATHER_FOOT',
		'EP13_RAID_LEATHER_HAND',
		'EP13_RAID_PLATE_TOP',
		'EP13_RAID_PLATE_LEG',
		'EP13_RAID_PLATE_FOOT',
		'EP13_RAID_PLATE_HAND',
	}
end

function setting_lv480_inherit_target_list(list_by_lv)
	list_by_lv[480]['Weapon'] = {
		'EP14_RAID_SWORD',
		'EP14_RAID_THSWORD',
		'EP14_RAID_STAFF',
		'EP14_RAID_THBOW',
		'EP14_RAID_BOW',
		'EP14_RAID_MACE',
		'EP14_RAID_THMACE',
		'EP14_RAID_SHIELD',
		'EP14_RAID_SPEAR',
		'EP14_RAID_THSPEAR',
		'EP14_RAID_DAGGER',
		'EP14_RAID_THSTAFF',
		'EP14_RAID_PISTOL',
		'EP14_RAID_RAPIER',
		'EP14_RAID_CANNON',
		'EP14_RAID_MUSKET',
		'EP14_RAID_TRINKET',
	}

	list_by_lv[480]['Armor'] = {
		'EP14_RAID_CLOTH_TOP',
		'EP14_RAID_CLOTH_LEG',
		'EP14_RAID_CLOTH_FOOT',
		'EP14_RAID_CLOTH_HAND',
		'EP14_RAID_LEATHER_TOP',
		'EP14_RAID_LEATHER_LEG',
		'EP14_RAID_LEATHER_FOOT',
		'EP14_RAID_LEATHER_HAND',
		'EP14_RAID_PLATE_TOP',
		'EP14_RAID_PLATE_LEG',
		'EP14_RAID_PLATE_FOOT',
		'EP14_RAID_PLATE_HAND',
	}
end

function setting_lv500_inherit_target_list(list_by_lv)
	list_by_lv[500]['Weapon'] = {
		'EP15_RAID_SWORD',
		'EP15_RAID_THSWORD',
		'EP15_RAID_STAFF',
		'EP15_RAID_THBOW',
		'EP15_RAID_BOW',
		'EP15_RAID_MACE',
		'EP15_RAID_THMACE',
		'EP15_RAID_SHIELD',
		'EP15_RAID_SPEAR',
		'EP15_RAID_THSPEAR',
		'EP15_RAID_DAGGER',
		'EP15_RAID_THSTAFF',
		'EP15_RAID_PISTOL',
		'EP15_RAID_RAPIER',
		'EP15_RAID_CANNON',
		'EP15_RAID_MUSKET',
		'EP15_RAID_TRINKET',
	}

	list_by_lv[500]['Armor'] = {
		'EP15_RAID_CLOTH_TOP',
		'EP15_RAID_CLOTH_LEG',
		'EP15_RAID_CLOTH_FOOT',
		'EP15_RAID_CLOTH_HAND',
		'EP15_RAID_LEATHER_TOP',
		'EP15_RAID_LEATHER_LEG',
		'EP15_RAID_LEATHER_FOOT',
		'EP15_RAID_LEATHER_HAND',
		'EP15_RAID_PLATE_TOP',
		'EP15_RAID_PLATE_LEG',
		'EP15_RAID_PLATE_FOOT',
		'EP15_RAID_PLATE_HAND',
	}

end

function setting_lv520_inherit_target_list(list_by_lv)
	list_by_lv[520]['Weapon'] = {
		'EP16_RAID_SWORD',
		'EP16_RAID_THSWORD',
		'EP16_RAID_STAFF',
		'EP16_RAID_THBOW',
		'EP16_RAID_BOW',
		'EP16_RAID_MACE',
		'EP16_RAID_THMACE',
		'EP16_RAID_SHIELD',
		'EP16_RAID_SPEAR',
		'EP16_RAID_THSPEAR',
		'EP16_RAID_DAGGER',
		'EP16_RAID_THSTAFF',
		'EP16_RAID_PISTOL',
		'EP16_RAID_RAPIER',
		'EP16_RAID_CANNON',
		'EP16_RAID_MUSKET',
		'EP16_RAID_TRINKET',
	}

	list_by_lv[520]['Armor'] = {
		'EP16_RAID_CLOTH_TOP',
		'EP16_RAID_CLOTH_LEG',
		'EP16_RAID_CLOTH_FOOT',
		'EP16_RAID_CLOTH_HAND',
		'EP16_RAID_LEATHER_TOP',
		'EP16_RAID_LEATHER_LEG',
		'EP16_RAID_LEATHER_FOOT',
		'EP16_RAID_LEATHER_HAND',
		'EP16_RAID_PLATE_TOP',
		'EP16_RAID_PLATE_LEG',
		'EP16_RAID_PLATE_FOOT',
		'EP16_RAID_PLATE_HAND',
	}

end

function setting_lv540_inherit_target_list(list_by_lv)
	list_by_lv[540]['Weapon'] = {
		'EP17_RAID_SWORD',
		'EP17_RAID_THSWORD',
		'EP17_RAID_STAFF',
		'EP17_RAID_THBOW',
		'EP17_RAID_BOW',
		'EP17_RAID_MACE',
		'EP17_RAID_THMACE',
		'EP17_RAID_SHIELD',
		'EP17_RAID_SPEAR',
		'EP17_RAID_THSPEAR',
		'EP17_RAID_DAGGER',
		'EP17_RAID_THSTAFF',
		'EP17_RAID_PISTOL',
		'EP17_RAID_RAPIER',
		'EP17_RAID_CANNON',
		'EP17_RAID_MUSKET',
		'EP17_RAID_TRINKET',
	}

	list_by_lv[540]['Armor'] = {
		'EP17_RAID_CLOTH_TOP',
		'EP17_RAID_CLOTH_LEG',
		'EP17_RAID_CLOTH_FOOT',
		'EP17_RAID_CLOTH_HAND',
		'EP17_RAID_LEATHER_TOP',
		'EP17_RAID_LEATHER_LEG',
		'EP17_RAID_LEATHER_FOOT',
		'EP17_RAID_LEATHER_HAND',
		'EP17_RAID_PLATE_TOP',
		'EP17_RAID_PLATE_LEG',
		'EP17_RAID_PLATE_FOOT',
		'EP17_RAID_PLATE_HAND',
	}

end

function setting_lv470_acc_inherit_target_list(list_by_lv)
	list_by_lv[470]['Neck'] = {
		'EP13_NECK06_HIGH_001',
		'EP13_NECK06_HIGH_002',
		'EP13_NECK06_HIGH_003',
		'EP13_NECK06_HIGH_004',
		'EP13_NECK06_HIGH_005',
		'EP13_NECK06_HIGH_006',		
	}

	list_by_lv[470]['Ring'] = {
		'EP13_BRC06_HIGH_001',
		'EP13_BRC06_HIGH_002',
		'EP13_BRC06_HIGH_003',
		'EP13_BRC06_HIGH_004',
		'EP13_BRC06_HIGH_005',
		'EP13_BRC06_HIGH_006',		
	}
end

function setting_lv490_acc_inherit_target_list(list_by_lv)
	list_by_lv[490]['Neck'] = {
		'EP14_NECK_01',
		'EP14_NECK_02',
	}

	list_by_lv[490]['Ring'] = {
		'EP14_BRC_01',
		'EP14_BRC_02',	
	}
end

function setting_lv510_acc_inherit_target_list(list_by_lv)
	list_by_lv[510]['Neck'] = {
		'EP16_NECK_01',
		'EP16_NECK_02',
		'EP16_NECK_03',
		'EP16_NECK_04',
	}

	list_by_lv[510]['Ring'] = {
		'EP16_BRC_01',
		'EP16_BRC_02',	
		'EP16_BRC_03',	
		'EP16_BRC_04',	
	}
end

function setting_lv530_acc_inherit_target_list(list_by_lv)
	list_by_lv[530]['Neck'] = {
		'EP17_Kalentis_NECK_01',
		'EP17_Kalentis_NECK_02',
		'EP17_Kalentis_NECK_03',
		'EP17_Kalentis_NECK_04',
	}

	list_by_lv[530]['Ring'] = {
		'EP17_Kalentis_BRC_01',
		'EP17_Kalentis_BRC_02',	
		'EP17_Kalentis_BRC_03',	
		'EP17_Kalentis_BRC_04',	
	}
end


function make_goddess_inherit_target_list()
	item_goddess_inherit_target_list = {}

	-- 초보자 계승 (수호자 시리즈)
	
	item_goddess_inherit_target_list[120] = {}
	item_goddess_inherit_target_list[280] = {}
	item_goddess_inherit_target_list[460] = {}
	item_goddess_inherit_target_list[470] = {}
	item_goddess_inherit_target_list[480] = {}
	item_goddess_inherit_target_list[490] = {}
	item_goddess_inherit_target_list[500] = {}
	item_goddess_inherit_target_list[510] = {}
	item_goddess_inherit_target_list[520] = {}
	item_goddess_inherit_target_list[530] = {}
	item_goddess_inherit_target_list[540] = {}

	local list_by_lv = {}

	list_by_lv[120] = {}	
	list_by_lv[280] = {}
	list_by_lv[460] = {}
	list_by_lv[470] = {}
	list_by_lv[480] = {}
	list_by_lv[490] = {}
	list_by_lv[500] = {}
	list_by_lv[510] = {}
	list_by_lv[520] = {}
	list_by_lv[530] = {}
	list_by_lv[540] = {}

	list_by_lv[120]['Weapon'] = {}
	list_by_lv[120]['Armor'] = {}
	setting_lv120_inherit_target_list(list_by_lv)

	list_by_lv[280]['Weapon'] = {}
	list_by_lv[280]['Armor'] = {}
	setting_lv280_inherit_target_list(list_by_lv)

	list_by_lv[460]['Weapon'] = {}
	list_by_lv[460]['Armor'] = {}
	setting_lv460_inherit_target_list(list_by_lv)
	
	list_by_lv[470]['Neck'] = {}
	list_by_lv[470]['Ring'] = {}
	setting_lv470_acc_inherit_target_list(list_by_lv)
	
	list_by_lv[480]['Weapon'] = {}
	list_by_lv[480]['Armor'] = {}
	setting_lv480_inherit_target_list(list_by_lv)
	
	list_by_lv[490]['Neck'] = {}
	list_by_lv[490]['Ring'] = {}
	setting_lv490_acc_inherit_target_list(list_by_lv)

	list_by_lv[500]['Weapon'] = {}
	list_by_lv[500]['Armor'] = {}	
	setting_lv500_inherit_target_list(list_by_lv)
	
	list_by_lv[520]['Weapon'] = {}
	list_by_lv[520]['Armor'] = {}	
	setting_lv520_inherit_target_list(list_by_lv)

	list_by_lv[510]['Neck'] = {}
	list_by_lv[510]['Ring'] = {}
	setting_lv510_acc_inherit_target_list(list_by_lv)

	list_by_lv[530]['Neck'] = {}
	list_by_lv[530]['Ring'] = {}
	setting_lv530_acc_inherit_target_list(list_by_lv)

	list_by_lv[540]['Weapon'] = {}
	list_by_lv[540]['Armor'] = {}	
	setting_lv540_inherit_target_list(list_by_lv)

	for lv, _ in pairs(item_goddess_inherit_target_list) do
		if list_by_lv[lv]['Weapon'] ~= nil then
			item_goddess_inherit_target_list[lv]['Weapon'] = list_by_lv[lv]['Weapon']
		end
		if list_by_lv[lv]['Armor'] ~= nil then
			item_goddess_inherit_target_list[lv]['Armor'] = list_by_lv[lv]['Armor']
		end
		if list_by_lv[lv]['Neck'] ~= nil then
			item_goddess_inherit_target_list[lv]['Neck'] = list_by_lv[lv]['Neck']
		end
		if list_by_lv[lv]['Ring'] ~= nil then
			item_goddess_inherit_target_list[lv]['Ring'] = list_by_lv[lv]['Ring']
		end
	end
end
make_goddess_inherit_target_list()

item_goddess_craft = {}

-- 기본 체크
item_goddess_craft.check_enable_inherit_item = function(item)
	-- 최소 레전드는 되어야 계승 가능
	local grade = TryGetProp(item, 'ItemGrade', 0)
	if grade < 5 then
		return false, 'NeedLegendGrade'
	end
	
	if item_goddess_growth.is_goddess_growth_item(item) == true then
		if TryGetProp(item, 'Reinforce_2', 0) < 20 then
			return false, 'Need20Reinforcement'
		else
			return true, 'None'
		end
	end

	-- 440제 부터 계승 가능
	local use_lv = TryGetProp(item, 'UseLv', 1)
	if use_lv < 440 then
		return false, 'Need440UseLv'
	end

	local class_type = TryGetProp(item, 'ClassType', 'None')
	local is_acc = false
	if class_type == 'Neck' or class_type == 'Ring' then
		is_acc = true
	end
	
	if is_acc == true then
		if use_lv <= 450 then
			local trans_value = TryGetProp(item, 'Transcend', 0)
			if trans_value < 8 and use_lv <= 460 then
				return false, 'Need8Transcend'
			end	
		else
			if grade < 6 then
				return false, 'NeedGoddessGrade'
			end
		end
	else
		-- 8초월 이상만 가능
		local trans_value = TryGetProp(item, 'Transcend', 0)
		if trans_value < 8 and use_lv < 460 then
			return false, 'Need8Transcend'
		end
	end

	-- 계승 대상 아이템 그룹이 존재하는가
	local target_lv = GET_INHERIT_TARGET_ITEM_LV(use_lv, item)	
	if target_lv == nil then		
		return false
	end
	
	if item_goddess_inherit_target_list[target_lv] == nil then				
		return false
	end
	
	-- 무기/방어구인지 체크
	local equip_group = TryGetProp(item, 'EquipGroup', 'None')	
	
	
	if is_acc == true then
		if TryGetProp(item, 'UseLv', 0) <= 450 then
			if TryGetProp(item, 'CharacterBelonging', 0) ~= 1 then
				return false, 'CanExecCuzCharacterBelonging'
			end
			if TryGetProp(item, 'StringArg', 'None') ~= 'Luciferi' then
				return false, 'NeedLuciferiType'
			end
		else
			if TryGetProp(item, 'ItemGrade', 0) < 6 then
				return false, 'NeedGoddessGrade'			
			end
			if grade == 6 and use_lv >= 460 then
				if TryGetProp(item, 'StringArg', 'None') == 'Goddess_Vasilisa' then
					return true, 'None'
				end

				if TryGetProp(item, 'Reinforce_2', 0) < 20 then				
					return false, 'Require20Reinforce'
				end
			end
		end
	else
		if equip_group ~= 'Weapon' and equip_group ~= 'THWeapon' and equip_group ~= 'SubWeapon' then
			local _type_list = { 'SHIRT', 'PANTS', 'GLOVES', 'BOOTS' }
			local equip_type = TryGetProp(item, 'EqpType', 'None')
			if table.find(_type_list, equip_type) == 0 then			
				return false
			end
		end

		if grade == 6 and use_lv >= 460 then
			if grade == 6 and use_lv >= 460 then
				if TryGetProp(item, 'StringArg', 'None') ~= 'Goddess_Vasilisa' and TryGetProp(item, 'Reinforce_2', 0) < 20 then			
						return false, 'Require20Reinforce'
				end
			end
		end
	end
	
	if grade == 6 then
		local normal_max_cnt = GET_MAX_GODDESS_NORMAL_SOCKET_COUNT(use_lv)			
		local full_normal_socket = false -- 일반 소켓 최대 개방 상태인가
		local enable_aether_socket = false -- 에테르 젬 소켓 개방 상태인가
		if IsServerSection() == 1 then
			for count = 1, normal_max_cnt do
				local gem_id = GetItemSocketInfo(item, count - 1)
				if gem_id ~= nil and tonumber(gem_id) ~= 0 then
					return false, 'RemoveGemFromSocketForInheritance'
				end
			end

			if equip_group == 'Weapon' or equip_group == 'THWeapon' or equip_group == 'SubWeapon' then
				local gem_id = GetItemSocketInfo(item, normal_max_cnt)
				if gem_id ~= nil and tonumber(gem_id) ~= 0 then
					return false, 'RemoveGemFromSocketForInheritance'
				end
			end
		else
			local inv_item = GET_INV_ITEM_BY_ITEM_OBJ(item)
			for count = 1, normal_max_cnt do
				local gem_id = inv_item:GetEquipGemID(count - 1)
				if tonumber(gem_id) ~= 0 then
					return false, 'RemoveGemFromSocketForInheritance'
				end
			end

			if equip_group == 'Weapon' or equip_group == 'THWeapon' or equip_group == 'SubWeapon' then
				local gem_id = inv_item:GetEquipGemID(normal_max_cnt)
				if tonumber(gem_id) ~= 0 then
					return false, 'RemoveGemFromSocketForInheritance'
				end
			end
		end
	end

	return true
end

-- 레전드 아이템 체크
item_goddess_craft.check_enable_inherit_legend_item = function(item)
	-- 이벤트 장비는 바로 계승 가능
	local is_event_item = TryGetProp(item, 'EventItem', 0)	
	if is_event_item == 1 then		
		return true	
	end

	-- 이벤트 장비가 아니면 아이커가 없어야 함
	if IS_ENABLE_RELEASE_OPTION_2(item) == false then				
		return true
	end

	-- [EP12] 무기이면 고정 아이커 여부와 상관없이 계승 가능
	local eventType = TryGetProp(item, "EventType", "None")
	local equipGroup = TryGetProp(item, "EquipGroup", "None")	
	if SHARED_IS_EVENT_ITEM_CHECK(item, "EP12REWARD") == true then		
		if equipGroup == 'Weapon' or equipGroup == 'THWeapon' or equipGroup == 'SubWeapon' then
			return true
		end
	end
	
	return false
end

-- 계승 수치
item_goddess_craft.get_inherit_option_value = function(item)
	if item == nil then
		return nil
	end

	local grade = TryGetProp(item, 'ItemGrade', 0)
	local is_acc = false
	if TryGetProp(item, 'ClassType', 'None') == 'Neck' or TryGetProp(item, 'ClassType', 'None') == 'Ring' then
		is_acc = true
	end

	if is_acc == false and grade < 6 then
		local trans_value = TryGetProp(item, 'Transcend', 0)
		if trans_value < 10 then
			return nil
		end
	end

	local reinf_value = 0
	if is_acc == false and grade < 6 then
		reinf_value = TryGetProp(item, 'Reinforce_2', 0)
		reinf_value = math.floor(reinf_value * 2 / 3)
		if reinf_value > 14 then
			reinf_value = 14
		end
	else
		reinf_value = TryGetProp(item, 'Reinforce_2', 0)
		reinf_value = math.floor(reinf_value * 0.5)		
	end
	
	local enchant_name = TryGetProp(item, 'RandomOptionRare', 'None')
	local enchant_value = TryGetProp(item, 'RandomOptionRareValue', 0)	
	-- 이동속도/광공비 체크해서 해당 옵션이면 3일 경우에만 2로 계승, 그 외에는 제거
	if enchant_name == 'RareOption_MSPD' or enchant_name == 'RareOption_SR' then
		if enchant_value < 2 then
			enchant_name = 'None'
			enchant_value = 0
		elseif enchant_value == 2 then
			enchant_value = 1
		elseif enchant_value == 3 then
			enchant_value = 2
		end
	else
		enchant_value = math.floor(enchant_value * 2 / 3)
	end

	-- 460레벨 이상의 가디스, 방어구, 액세서리는 인챈트가 사라지기 때문에 계승 안됨
	if grade >= 6 and TryGetProp(item, 'UseLv', 0) >= 460 then
		enchant_name = 'None'
		enchant_value = 0		
	end

	if item_goddess_growth.is_goddess_growth_item(item) == true then
		reinf_value = 0
	end

	local enchant_upgrade_rank = TryGetProp(item, 'UpgradeRank', 0)
	enchant_upgrade_rank = math.floor(enchant_upgrade_rank * 0.5)

	return reinf_value, enchant_name, enchant_value, enchant_upgrade_rank
end

-- 가디스 480레벨(계승으로 생성되는 아이템) 이상 방어구(상의, 하의, 장갑, 신발)에 기본적으로 부여할 옵션의 수치(힘/민/지/체)
item_goddess_craft.get_basic_random_option_value = function(mat_item)
	local option_list = {}
	local option_value = {}
	local option_group = {}

	local grade = TryGetProp(mat_item, 'ItemGrade', 0)
	local lv = TryGetProp(mat_item, 'UseLv', 0)
	local group_name = TryGetProp(mat_item, 'GroupName', 'None')
	local is_acc = false
	local class_type = TryGetProp(mat_item, 'ClassType', 'None')
	if class_type == 'Neck' or class_type == 'Ring' then
		is_acc = true
	end
	
	table.insert(option_group, 'ATK')
	table.insert(option_group, 'STAT')
	table.insert(option_group, 'UTIL_ARMOR')
	table.insert(option_group, 'DEF')
	
	if is_acc == false then
		if group_name == 'Armor' and class_type ~= 'Shield' then
			if lv == 480 then -- 460에서 계승 하는 경우
				table.insert(option_list, 'AllRace_Atk')
				table.insert(option_value, 410)

				table.insert(option_list, 'CON')
				table.insert(option_value, 91)

				table.insert(option_list, 'CRTHR')
				table.insert(option_value, 302)

				table.insert(option_list, 'MiddleSize_Def')
				table.insert(option_value, 410)
			elseif lv == 500 then  -- 480에서 계승하는 경우
				table.insert(option_list, 'AllRace_Atk')
				table.insert(option_value, 492)

				table.insert(option_list, 'CON')
				table.insert(option_value, 109)

				table.insert(option_list, 'CRTHR')
				table.insert(option_value, 362)

				table.insert(option_list, 'MiddleSize_Def')
				table.insert(option_value, 492)
			elseif lv == 520 then  -- 500 에서 계승하는 경우
				table.insert(option_list, 'AllRace_Atk')
				table.insert(option_value, 565)

				table.insert(option_list, 'CON')
				table.insert(option_value, 125)

				table.insert(option_list, 'CRTHR')
				table.insert(option_value, 416)

				table.insert(option_list, 'MiddleSize_Def')
				table.insert(option_value, 565)
			elseif lv == 540 then  -- 520 에서 계승하는 경우
				table.insert(option_list, 'AllRace_Atk')
				table.insert(option_value, 649) -- 1.148374

				table.insert(option_list, 'CON')
				table.insert(option_value, 143) -- 1.146788991
				table.insert(option_list, 'CRTHR') 
				table.insert(option_value, 478) -- 1.149171271

				table.insert(option_list, 'MiddleSize_Def')
				table.insert(option_value, 649) -- 1.148373984
			end
		elseif group_name == 'Weapon' or group_name == 'SubWeapon' or class_type == 'Shield' then
			if lv == 480 then -- 460에서 계승 하는 경우
				table.insert(option_list, 'AllRace_Atk')
				table.insert(option_value, 769)

				table.insert(option_list, 'CON')
				table.insert(option_value, 170)

				table.insert(option_list, 'CRTHR')
				table.insert(option_value, 564)

				table.insert(option_list, 'MiddleSize_Def')
				table.insert(option_value, 769)
			elseif lv == 500 then -- 480에서 계승하는 경우
				table.insert(option_list, 'AllRace_Atk')
				table.insert(option_value, 874)

				table.insert(option_list, 'CON')
				table.insert(option_value, 204)

				table.insert(option_list, 'CRTHR')
				table.insert(option_value, 676)

				table.insert(option_list, 'MiddleSize_Def')
				table.insert(option_value, 922)
			elseif lv == 520 then -- 500 에서 계승하는 경우
				table.insert(option_list, 'AllRace_Atk')
				table.insert(option_value, 1005)

				table.insert(option_list, 'CON')
				table.insert(option_value, 234)

				table.insert(option_list, 'CRTHR')
				table.insert(option_value, 777)

				table.insert(option_list, 'MiddleSize_Def')
				table.insert(option_value, 1060)
			elseif lv == 540 then -- 520 에서 계승하는 경우
				table.insert(option_list, 'AllRace_Atk')
				table.insert(option_value, 1156)

				table.insert(option_list, 'CON')
				table.insert(option_value, 268)

				table.insert(option_list, 'CRTHR')
				table.insert(option_value, 893)

				table.insert(option_list, 'MiddleSize_Def')
				table.insert(option_value, 1219)
			end
		end		
	end

	return option_list, option_value, option_group
end

-- 계열 변경할 때, 기존 옵션으로 돌려준다.
item_goddess_craft.get_basic_random_option_value_for_exchange_group = function(mat_item)
	return item_goddess_craft.get_basic_random_option_value(mat_item)
end


-- 계승 가능 대상 목록
item_goddess_craft.get_inherit_target_item_list = function(item)	
	if item == nil then
		return nil
	end

	local use_lv = TryGetProp(item, 'UseLv', 1)
	local target_lv = GET_INHERIT_TARGET_ITEM_LV(use_lv, item)	
	if target_lv == nil then		
		return nil
	end

	if item_goddess_inherit_target_list[target_lv] == nil then			
		return nil
	end
	local group_name = TryGetProp(item, 'GroupName', 'None')


	if group_name == 'SubWeapon' then
		group_name = 'Weapon'
	end

	-- 방패 예외 처리
	local class_type = TryGetProp(item, 'ClassType', 'None')
	if class_type == 'Shield' then
		group_name = 'Weapon'
	end

	local is_acc = false
	if class_type == 'Neck' or class_type == 'Ring' then
		group_name = class_type
		is_acc = true
	end
	
	if item_goddess_inherit_target_list[target_lv][group_name] == nil then		
		return nil
	end	
	if is_acc == false then
		if item_goddess_growth.is_goddess_growth_item(item) == true then -- 수호자 시리즈면
			local dic = item_goddess_inherit_target_list[target_lv][group_name]
			local ret_list = {}

			if IS_ARMOR_TYPE(TryGetProp(item, 'EquipGroup', 'None')) == true then -- 방어구면 같은 종류만
				local save = 'None'
				
				for i = 1, #dic do
					local v = dic[i]
					local cls = GetClass('Item', v)
					if TryGetProp(cls, 'Material', 'None') == TryGetProp(item, 'Material', 'None') then -- 재질이 같음
						if TryGetProp(cls, 'EquipGroup', 'None') == TryGetProp(item, 'EquipGroup', 'None') then -- 부위가 같음
							save = v
						end
					else
						if TryGetProp(cls, 'EquipGroup', 'None') == TryGetProp(item, 'EquipGroup', 'None') then -- 부위가 같음
							table.insert(ret_list, v)
						end
					end
				end
				table.insert(ret_list, 1, save)
			elseif IS_WEAPON_TYPE(TryGetProp(item, 'ClassType', 'None')) == true then -- 무기면 착용가능한 것만
				local class_type = TryGetProp(item, 'ClassType', 'None')
				local save = 'None'
				for i = 1, #dic do
					local v = dic[i]			
					if class_type ~= TryGetProp(GetClass('Item', v), 'ClassType', 'None') then
						if IsServerSection() == 0 then
							local cls = GetClass('Item', v)
							if item_goddess_growth.is_goddess_growth_item(GetClass('Item', v)) == true then
								if CHECK_EQUIPABLE(cls.ClassID) == 'OK' then -- 착용 가능 무기인지 확인
									table.insert(ret_list, v)
								end
							else
								table.insert(ret_list, v)
							end							
						else
							table.insert(ret_list, v)
						end
					else
						save = v -- 현재무기와 같은 종류 무기 저장
					end
				end
				
				if IsServerSection() == 0 then
					table.sort(ret_list, function(a, b)
						local cls = GetClass('Item', a)
						local cls_2 = GetClass('Item', b)				
						if CHECK_EQUIPABLE(cls.ClassID) == 'OK' and CHECK_EQUIPABLE(cls_2.ClassID) ~= 'OK' then
							return true
						elseif CHECK_EQUIPABLE(cls.ClassID) == 'OK' and CHECK_EQUIPABLE(cls_2.ClassID) == 'OK' then
							return false
						elseif CHECK_EQUIPABLE(cls.ClassID) ~= 'OK' and CHECK_EQUIPABLE(cls_2.ClassID) == 'OK' then
							return false
						elseif CHECK_EQUIPABLE(cls.ClassID) ~= 'OK' and CHECK_EQUIPABLE(cls_2.ClassID) ~= 'OK' then
							return false
						end
						return false
					end)
				end

				table.insert(ret_list, 1, save)
				return ret_list
			else
				return dic
			end
			
			return ret_list
		else
			local dic = item_goddess_inherit_target_list[target_lv][group_name]
			local ret_dic = {}

			local check_prop = 'ClassType'
			local save = 'None'
			if IS_WEAPON_TYPE(TryGetProp(item, 'ClassType', 'None')) == true then
				check_prop = 'ClassType'
				local class_type = TryGetProp(item, check_prop, 'None')				
				for i = 1, #dic do
					local v = dic[i]			
					if class_type ~= TryGetProp(GetClass('Item', v), check_prop, 'None') then
						table.insert(ret_dic, v)					
					else
						save = v
					end
				end
			elseif IS_ARMOR_TYPE(TryGetProp(item, 'EquipGroup', 'None')) == true then
				for i = 1, #dic do
					local v = dic[i]
					local cls = GetClass('Item', v)
					if TryGetProp(cls, 'Material', 'None') == TryGetProp(item, 'Material', 'None') then -- 재질이 같음
						if TryGetProp(cls, 'EquipGroup', 'None') == TryGetProp(item, 'EquipGroup', 'None') then -- 부위가 같음
							save = v
						else
							table.insert(ret_dic, v)
						end
					else
						table.insert(ret_dic, v)
					end
				end
			end
			
			if IsServerSection() == 0 and IS_WEAPON_TYPE(TryGetProp(item, 'ClassType', 'None')) == true then
				table.sort(ret_dic, function(a, b)
					local cls = GetClass('Item', a)
					local cls_2 = GetClass('Item', b)				
					if CHECK_EQUIPABLE(cls.ClassID) == 'OK' and CHECK_EQUIPABLE(cls_2.ClassID) ~= 'OK' then
						return true
					elseif CHECK_EQUIPABLE(cls.ClassID) == 'OK' and CHECK_EQUIPABLE(cls_2.ClassID) == 'OK' then
						return false
					elseif CHECK_EQUIPABLE(cls.ClassID) ~= 'OK' and CHECK_EQUIPABLE(cls_2.ClassID) == 'OK' then
						return false
					elseif CHECK_EQUIPABLE(cls.ClassID) ~= 'OK' and CHECK_EQUIPABLE(cls_2.ClassID) ~= 'OK' then
						return false
					end
					return false
				end)
			end

			table.insert(ret_dic, 1, save)			
			return ret_dic
		end
	else
		if use_lv >= 470 then -- 이시다비 이후로는 모든 악세로 변경이 가능하다.
			-- 이시다비 -> 바우드 로 변경
			return item_goddess_inherit_target_list[target_lv][group_name];
		else
			-- 액세서리는 같은 종류로만 가능하다( 루시페리 -> 이시다비로 변경 )
			local name = TryGetProp(item, 'ClassName', 'None')
			if name == 'None' then
				return nil
			end

			local token = StringSplit(name, '_')
			local suffix = ''
			for i = 2, #token do
				if i ~= #token then
					suffix = suffix .. token[i] .. '_'
				else
					suffix = suffix .. token[i]
				end
			end

			local ret = {}
			for k, v in pairs(item_goddess_inherit_target_list[target_lv][group_name]) do			
				local token2 = StringSplit(v, '_')
				local suffix2= ''
				for i = 2, #token2 do
					if i ~= #token2 then
						suffix2 = suffix2 .. token2[i] .. '_'
					else
						suffix2 = suffix2 .. token2[i]
					end
				end
				
				if suffix == suffix2 then
					table.insert(ret, v)
				end
			end
			return ret
		end
	end
end

item_goddess_craft.is_able_to_convert = function(mat_item, targetGruop)		
	if targetGruop == nil then
		return false, 'IMPOSSIBLE_ITEM'
	end

	if IS_EXCHANGE_WEAPONTYPE(targetGruop, TryGetProp(mat_item, 'ClassName', 'None')) == false then
        return false, 'IMPOSSIBLE_ITEM'
	end

	if TryGetProp(mat_item, 'RadaOption', 'None') ~= 'None' then
		return false, 'IMPOSSIBLE_ITEM'
	end


	return true, 'None'
end

-- 바실리사 장비 귀속 해제
item_goddess_craft.is_able_to_unlock_vasilisa = function(scrollObj, itemObj)
	if TryGetProp(itemObj, 'CharacterBelonging', 0) == 0 then		
		return false, 'OnlyUseBelongingItem'
	end


	if TryGetProp(scrollObj, 'StringArg', 'None') ~= 'unlock_vasilisa_belonging' then
		return false, 'NotValidItem'
	end

	if TryGetProp(itemObj, 'StringArg', 'None') ~= 'Goddess_Vasilisa' then
		return false, 'NotValidItem'
	end
    
    return true, 'None'
end
-- 아크 스크롤 추출
item_goddess_craft.is_able_to_decompose_ark = function(scrollObj, itemObj)
	if IS_SEASON_SERVER() == 'YES' then
		return false, 'cant_use_in_season_server'
	end

	if TryGetProp(itemObj, 'CharacterBelonging', 0) == 0 then		
		return false, 'OnlyFromCabinetItemUsable'
	end

	if TryGetProp(scrollObj, 'StringArg', 'None') ~= 'ark_decomposition_scroll' then
		return false, 'NotValidItem'
	end

	if TryGetProp(itemObj, 'GroupName', 'None') ~= 'Ark' then
		return false, 'NotValidItem'
	end

	if TryGetProp(itemObj, 'ArkLevel', 0) ~= 10 then
		return false, 'NotValidItem'
	end
    
    return true, 'None'
end
-- 가디스 액세서리 귀속 해제
item_goddess_craft.is_able_to_unlock_acc = function(scrollObj, itemObj)
	if TryGetProp(itemObj, 'CharacterBelonging', 0) == 0 then		
		return false, 'OnlyUseBelongingItem'
	end


	if TryGetProp(scrollObj, 'StringArg', 'None') ~= 'unlock_acc_belonging' then
		return false, 'NotValidItem'
	end

	if TryGetProp(itemObj, 'ItemGrade', 0) ~= 6 then
		return false, 'NotValidItem'
	end

	local scroll_lv = TryGetProp(scrollObj, 'NumberArg1', 0)
	local item_lv = TryGetProp(itemObj, 'UseLv', 0)
	local class_type = TryGetProp(itemObj, 'ClassType', 'None')
	if class_type ~= 'Neck' and class_type ~= 'Ring' then
		return false , 'NotValidItem'
	end
	
	if scroll_lv < item_lv then
		return false, 'NotValidItem'
	end
    
    return true, 'None'
end

-- 변질자 귀속 해제
item_goddess_craft.is_able_to_unlock_transmutationspreader = function(scrollObj, itemObj)
	if TryGetProp(itemObj, 'CharacterBelonging', 0) == 0 then		
		return false, 'OnlyUseBelongingItem'
	end

	if TryGetProp(scrollObj, 'StringArg', 'None') ~= 'unlock_transmutationSpreader_belonging' then
		return false, 'NotValidItem'
	end

	local stringArg = TryGetProp(itemObj, 'StringArg', 'None')
	if stringArg ~= 'Goddess_Armor_Lv480' and stringArg ~= "Goddess_Weapon_Lv480" then
		return false, 'NotValidItem'
	end
    
    return true, 'None'
end


item_goddess_craft.is_able_to_unlock_scroll = function(scrollObj, itemObj)
	if TryGetProp(itemObj, 'CharacterBelonging', 0) == 0 then		
		return false, 'OnlyUseBelongingItem'
	end

	if TryGetProp(scrollObj, 'StringArg', 'None') ~= 'unlock_belonging_scroll' then
		return false, 'NotValidItem'
	end

	local armor = string.format('Goddess_Armor_Lv%d', TryGetProp(scrollObj, 'NumberArg1', 0))
	local weapon = string.format('Goddess_Weapon_Lv%d', TryGetProp(scrollObj, 'NumberArg1', 0))

	local stringArg = TryGetProp(itemObj, 'StringArg', 'None')
	local popoboostProp = TryGetProp(itemObj, 'popoboost', 'None')
	local UseLv = TryGetProp(itemObj, 'UseLv', 0)

	if TryGetProp(scrollObj, 'NumberArg1', 0) == 540 and TryGetProp(itemObj, 'ClassName', 'None') == 'EP17_RAID_LEATHER_FOOT' then
		return true, 'None'
	end

	if stringArg ~= armor and stringArg ~= weapon then
		return false, 'NotValidItem'
	end

	-- 포포부스트 아이템이고, 레벨이 510 이하일 때 (계승 전 아이템일 때)
	if popoboostProp > 0 and UseLv < 510 then
		return false, 'NotValidItem'
	end
    
    return true, 'None'
end

local shared_rada_option_range = nil

function GET_RADAOPTION_RANGE(option, equip_group)
	if shared_rada_option_range == nil then
		shared_rada_option_range = {}
		shared_rada_option_range['rada_allskillup'] = {}
		shared_rada_option_range['rada_allskillup']['SHIRT'] = {1, 3}

		shared_rada_option_range['rada_lostlife'] = {}
		shared_rada_option_range['rada_lostlife']['PANTS'] = {3, 6}

		shared_rada_option_range['rada_criup'] = {}
		shared_rada_option_range['rada_criup']['GLOVES'] = {5, 10}

		shared_rada_option_range['rada_speedup'] = {}
		shared_rada_option_range['rada_speedup']['BOOTS'] = {5, 10}

		shared_rada_option_range['rada_cooldown'] = {}
		shared_rada_option_range['rada_cooldown']['SHIRT'] = {1, 2}
		shared_rada_option_range['rada_cooldown']['PANTS'] = {2, 5}
		shared_rada_option_range['rada_cooldown']['GLOVES'] = {2, 5}
		shared_rada_option_range['rada_cooldown']['BOOTS'] = {2, 5}
	end

	local ret = shared_rada_option_range[option][equip_group]
	if ret == nil then
		return {0, 0}
	else
		return ret
	end
end
