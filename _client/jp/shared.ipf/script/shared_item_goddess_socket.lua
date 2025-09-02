-- shared_item_goddess_socket.lua, 가디스 장비 소켓 관련


local parameter_list = nil
local end_lv = 540
function make_parameter_list()
	if parameter_list ~= nil then
		return
	end

	parameter_list = {}

	parameter_list[460] = {} 
	parameter_list[460]['MAX_NORMAL_SOCKET_COUNT'] = 2 -- 색상 젬 소켓 최대 개수
	parameter_list[460]['MAX_AETHER_SOCKET_COUNT'] = 1 -- 에테르 젬 소켓 최대 개수

	parameter_list[470] = {} 
	parameter_list[470]['MAX_NORMAL_SOCKET_COUNT'] = 2 -- 색상 젬 소켓 최대 개수
	parameter_list[470]['MAX_AETHER_SOCKET_COUNT'] = 1 -- 에테르 젬 소켓 최대 개수	

	parameter_list[480] = {} 
	parameter_list[480]['MAX_NORMAL_SOCKET_COUNT'] = 2 -- 색상 젬 소켓 최대 개수
	parameter_list[480]['MAX_AETHER_SOCKET_COUNT'] = 1 -- 에테르 젬 소켓 최대 개수	

	parameter_list[500] = {} 
	parameter_list[500]['MAX_NORMAL_SOCKET_COUNT'] = 2 -- 색상 젬 소켓 최대 개수
	parameter_list[500]['MAX_AETHER_SOCKET_COUNT'] = 1 -- 에테르 젬 소켓 최대 개수	

	parameter_list[520] = {} 
	parameter_list[520]['MAX_NORMAL_SOCKET_COUNT'] = 2 -- 색상 젬 소켓 최대 개수
	parameter_list[520]['MAX_AETHER_SOCKET_COUNT'] = 1 -- 에테르 젬 소켓 최대 개수	

	parameter_list[540] = {} 
	parameter_list[540]['MAX_NORMAL_SOCKET_COUNT'] = 2 -- 색상 젬 소켓 최대 개수
	parameter_list[540]['MAX_AETHER_SOCKET_COUNT'] = 1 -- 에테르 젬 소켓 최대 개수	
end
make_parameter_list()

function GET_MAX_GODDESS_NORMAL_SOCKET_COUNT(lv)
	if parameter_list[lv] == nil then
		return 2
	end

	if parameter_list[lv]['MAX_NORMAL_SOCKET_COUNT'] == nil then
		return 2
	else
		return parameter_list[lv]['MAX_NORMAL_SOCKET_COUNT']
	end
end

function GET_AETHER_GEM_INDEX_RANGE(lv)
	if parameter_list[lv] == nil then
		return 2, 2
	end

	return parameter_list[lv]['MAX_NORMAL_SOCKET_COUNT'], parameter_list[lv]['MAX_NORMAL_SOCKET_COUNT'] + parameter_list[lv]['MAX_AETHER_SOCKET_COUNT'] - 1
end

function GET_MAX_GODDESS_AETHER_SOCKET_COUNT(lv)
	if parameter_list[lv] == nil then
		return 1
	end

	if parameter_list[lv]['MAX_AETHER_SOCKET_COUNT'] == nil then
		return 1
	else
		return parameter_list[lv]['MAX_AETHER_SOCKET_COUNT']
	end
end

function GET_EQUIP_GEM_TYPE(gem)
	if gem == nil then
		return nil
	end

	local group_name = TryGetProp(gem, 'GroupName', 'None')
	if group_name == 'Gem' then
		local str_arg = TryGetProp(gem, 'StringArg', 'None')
		if str_arg == 'SkillGem' then
			return 'skill'
		else
			return 'normal'
		end
	elseif group_name == 'Gem_High_Color' then
		return 'aether'
	end

	return nil
end

item_goddess_socket = {}

local item_goddess_normal_socket_material_list = nil

function setting_lv_normal_socket_material(mat_list_by_lv, lv)
	local season_coin = 'GabijaCertificate' -- 여신의 증표(가비야)

	if lv == 460 then
		season_coin = 'GabijaCertificate'
		mat_list_by_lv[lv][1][season_coin] = 450
		mat_list_by_lv[lv][2][season_coin] = 1050
	elseif lv == 480 then
		season_coin = 'VakarineCertificate'		
		mat_list_by_lv[lv][1][season_coin] = 675
		mat_list_by_lv[lv][2][season_coin] = 1575
	elseif lv == 500 then
		season_coin = 'RadaCertificate'
		mat_list_by_lv[lv][1][season_coin] = 675
		mat_list_by_lv[lv][2][season_coin] = 1575
	elseif lv == 520 then
		season_coin = 'JurateCertificate'
		mat_list_by_lv[lv][1][season_coin] = 675
		mat_list_by_lv[lv][2][season_coin] = 1575
	elseif lv == 540 then
		season_coin = 'AustejaCertificate'
		mat_list_by_lv[lv][1][season_coin] = 675
		mat_list_by_lv[lv][2][season_coin] = 1575
	end
end

function make_item_goddess_normal_socket_material_list()
	if item_goddess_normal_socket_material_list ~= nil then
		return
	end

	item_goddess_normal_socket_material_list = {}
	start = 460
	while start <= end_lv do
		item_goddess_normal_socket_material_list[start] = {}
		start = start + 10
	end	

	local classtype_list = {}
	table.insert(classtype_list, 'Sword')
	table.insert(classtype_list, 'THSword')
	table.insert(classtype_list, 'Staff')
	table.insert(classtype_list, 'THStaff')
	table.insert(classtype_list, 'Bow')
	table.insert(classtype_list, 'THBow')
	table.insert(classtype_list, 'Mace')
	table.insert(classtype_list, 'THMace')
	table.insert(classtype_list, 'Spear')
	table.insert(classtype_list, 'THSpear')	

	table.insert(classtype_list, 'Rapier')
	table.insert(classtype_list, 'Cannon')
	table.insert(classtype_list, 'Musket')
	table.insert(classtype_list, 'Dagger')
	table.insert(classtype_list, 'Pistol')
	table.insert(classtype_list, 'Shield')
	table.insert(classtype_list, 'Trinket')

	table.insert(classtype_list, 'Gloves')
	table.insert(classtype_list, 'Boots')
	table.insert(classtype_list, 'Pants')
	table.insert(classtype_list, 'Shirt')

	for lv, v1 in pairs(item_goddess_normal_socket_material_list) do
		for _, class_type in pairs(classtype_list) do
			item_goddess_normal_socket_material_list[lv][class_type] = {}
			for i = 1, GET_MAX_GODDESS_NORMAL_SOCKET_COUNT(lv) do
				item_goddess_normal_socket_material_list[lv][class_type][i] = {}
			end
		end
	end

	start = 460
	while start <= end_lv do
		local mat_list_by_lv = {}
		mat_list_by_lv[start] = {}
		for i = 1, GET_MAX_GODDESS_NORMAL_SOCKET_COUNT(start) do
			mat_list_by_lv[start][i] = {}
		end

		local func_name = 'setting_lv_normal_socket_material'
		local socket_func = _G[func_name]
		if socket_func ~= nil then			
			socket_func(mat_list_by_lv, start)
		
			for class_type, v in pairs(item_goddess_normal_socket_material_list[start]) do		
				for lv, dic in pairs(v) do			
					for i = 1, GET_MAX_GODDESS_NORMAL_SOCKET_COUNT(start) do
						item_goddess_normal_socket_material_list[start][class_type][i] = mat_list_by_lv[start][i]
					end
				end
			end
		end
		start = start + 10
	end
	
end

make_item_goddess_normal_socket_material_list()

item_goddess_socket.get_normal_socket_material_list = function(use_lv, class_type, index)
	if item_goddess_normal_socket_material_list[use_lv] == nil then
		return nil
	end

	if item_goddess_normal_socket_material_list[use_lv][class_type] == nil then
		return nil
	end

	return item_goddess_normal_socket_material_list[use_lv][class_type][index + 1]
end

-- 에테르 젬 소켓 개방용 아이템 체크
item_goddess_socket.is_aether_socket_material = function(item, target_item)
	if item == nil then
		return false
	end

	if item_goddess_growth.is_goddess_growth_item(target_item) == true then		
		return false
	end

	local lv = TryGetProp(target_item, 'UseLv', 1)

	local str_arg = TryGetProp(item, 'StringArg', 'None')
	local key_lv = TryGetProp(item, 'NumberArg1', 0)	
	if str_arg == 'Ether_Gem_Socket' and key_lv >= lv then
		return true
	end

	return false
end

-- 확장 가능한 일반 소켓 인덱스인가
item_goddess_socket.enable_normal_socket_add = function(item, index)
	if item == nil then
		return false
	end

	local lv = TryGetProp(item, 'UseLv', 0)
	if lv < 460 then
		return false
	end

	local grade = TryGetProp(item, 'ItemGrade', 0)
	if grade < 6 then
		return false
	end

	local normal_max_cnt = GET_MAX_GODDESS_NORMAL_SOCKET_COUNT(lv)
	if index >= normal_max_cnt then
		return false
	end

	if IsServerSection() == 1 then
		local normal_max_gem_id = GetItemSocketInfo(item, index)
		if normal_max_gem_id ~= nil then
			return false
		end
	else
		local inv_item = GET_INV_ITEM_BY_ITEM_OBJ(item)
		if inv_item:IsAvailableSocket(index) == true then
			return false
		end
	end

	return true
end

-- 에테르 젬 소켓 개방 가능한 상태인가
item_goddess_socket.enable_aether_socket_add = function(item)
	if item == nil then
		return false
	end

	if item_goddess_growth.is_goddess_growth_item(item) == true then
		return false
	end

	-- 에테르 젬 소켓은 무기류만 허용
	local equip_group = TryGetProp(item, 'EquipGroup', 'None')
	if equip_group ~= 'Weapon' and equip_group ~= 'SubWeapon' and equip_group ~= 'THWeapon' then
		return false
	end

	local grade = TryGetProp(item, 'ItemGrade', 0)
	local lv = TryGetProp(item, 'UseLv', 0)
	if lv < 460 or grade < 6 then
		return false
	end

	local normal_max_cnt = GET_MAX_GODDESS_NORMAL_SOCKET_COUNT(lv)	
	local full_normal_socket = false -- 일반 소켓 최대 개방 상태인가
	local enable_aether_socket = false -- 에테르 젬 소켓 개방 상태인가
	if IsServerSection() == 1 then
		local normal_max_gem_id = GetItemSocketInfo(item, normal_max_cnt - 1)
		if normal_max_gem_id ~= nil then
			full_normal_socket = true
		end
		
		if normal_max_cnt == 0 then
			full_normal_socket = true
		end

		
		local aether_gem_id = GetItemSocketInfo(item, normal_max_cnt)
		if aether_gem_id ~= nil then
			enable_aether_socket = true
		end
	else
		local inv_item = GET_INV_ITEM_BY_ITEM_OBJ(item)
		if normal_max_cnt == 0 then
			full_normal_socket = true
		else
			full_normal_socket = inv_item:IsAvailableSocket(normal_max_cnt - 1)
		end
		
		enable_aether_socket = inv_item:IsAvailableSocket(normal_max_cnt)	
	end
	
	-- 일반 소켓 최대 개방 && 에테르 젬 아직 개방 안한 상태만 허용
	if full_normal_socket == false or enable_aether_socket == true then
		return false
	end

	return true
end

-- 장착 가능한 일반 젬인가
item_goddess_socket.check_equipable_normal_gem = function(item, gem, index)
	local use_lv = TryGetProp(item, 'UseLv', 0)
	-- 슬롯 인덱스 체크
    if index >= GET_MAX_GODDESS_NORMAL_SOCKET_COUNT(use_lv) then
        return false
	end

	if item_goddess_growth.is_goddess_growth_item(item) == true then
		return false, 'None'
	end	

	local gem_type = GET_EQUIP_GEM_TYPE(gem)
	if gem_type == nil or gem_type == 'aether' then
		return false, 'None'
	end

	local msg = 'None'

	-- 무기 - 컬러 젬, 방어구 - 스킬 젬
	local group_name = TryGetProp(item, 'GroupName', 'None')
	local equip_group = TryGetProp(item, 'EquipGroup', 'None')
	if (equip_group == 'Weapon' or equip_group == 'SubWeapon' or equip_group == 'THWeapon') and gem_type == 'normal' then
		return true
	end
	
	if (equip_group == 'Weapon' or equip_group == 'SubWeapon' or equip_group == 'THWeapon') and gem_type == 'skill' then
		msg = 'OnlyEquipColorGem'
	end


	if equip_group ~= 'SubWeapon' and group_name == 'Armor' and gem_type == 'skill' then
		return true
	end
	
	if equip_group ~= 'SubWeapon' and group_name == 'Armor' and gem_type == 'normal' then
		msg = 'OnlyEquipSkillGem'
	end

	return false, msg
end

-- 장착 가능한 에테르 젬인가
item_goddess_socket.check_equipable_aether_gem = function(item, gem, index)
	local use_lv = TryGetProp(item, 'UseLv', 0)
	-- 슬롯 인덱스 체크
	if index < GET_MAX_GODDESS_NORMAL_SOCKET_COUNT(use_lv) then		
        return false
	end

	local gem_type = GET_EQUIP_GEM_TYPE(gem)
	if gem_type == nil or gem_type ~= 'aether' then
		return false
	end

	-- 무기에만 장착 가능
	local equip_group = TryGetProp(item, 'EquipGroup', 'None')
	if equip_group ~= 'Weapon' and equip_group ~= 'SubWeapon' and equip_group ~= 'THWeapon' then
		return false
	end
	
	-- NumberArg1값으로 대상 장비 UseLv 값 체크
	local gem_num_arg = TryGetProp(gem, 'NumberArg1', 0)		
	
	if gem_num_arg > use_lv then		
		return false
	end		
	return true
end

-- 스킬 젬 추출 패널티 제거 케어 기간 입력
function IS_GEM_EXTRACT_CARE_DATE()
    local startTimeStr = "2022-04-14 09:00:00"
    local endTimeStr = "2022-04-28 08:59:59"
	
	return date_time.is_between_time(startTimeStr, endTimeStr)
end

function IS_GEM_EXTRACT_FREE_CHECK(pc)
	if GetExProp(pc, 'Gem_Extract_Free') == 1 then
		return true;
	end

	return IS_GEM_EXTRACT_CARE_DATE();
end