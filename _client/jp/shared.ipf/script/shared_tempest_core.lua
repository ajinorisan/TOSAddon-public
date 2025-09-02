-- shared_tempest_core.lua

item_tempest_core = {}


item_tempest_core.get_max_option_count = function()
	return 4
end

item_tempest_core.get_remain_option_count = function(item)
	local max = item_tempest_core.get_max_option_count()

	for i = 1, max do
		local option_name = 'RandomOption_' .. i
		if TryGetProp(item, option_name, 'None') ~= 'None' then
			max = max - 1
		end
	end

	return max
end

-- 성공여부, 해방석 아이템 id, 재료 dic
item_tempest_core.get_valid_format_make_unsealing_material = function(str)
	local ret1, ret2, ret3 = false, nil, {}

	local token = StringSplit(str, '#')
	if #token ~= 2 then
		return ret1, ret2, ret3
	end

	local ret2 = tonumber(token[1])
	if ret2 == nil then
		return ret1, ret2, ret3
	end


	local token = StringSplit(token[2], ';')
	for i = 1, #token do
		local pair = StringSplit(token[i], '/')	
		if #pair ~= 2 then
			return ret1, ret2, ret3
		end

		local k, v = tonumber(pair[1]), tonumber(pair[2])
		if k == nil or v == nil then
			return ret1, ret2, ret3
		end

		ret3[k] = v
	end

	ret1 = true
	return ret1, ret2, ret3
end

item_tempest_core.get_total_point_from_material = function(str)
	local success, unsealing_item_id, material_dic = item_tempest_core.get_valid_format_make_unsealing_material(str)
	if success == false then
		return 0
	end
	
	local total_point = 0
	for k, v in pairs(material_dic) do
		local cls = GetClassByType('tempest_core_unsealing_material', k)
		if cls ~= nil then
			total_point = total_point + (TryGetProp(cls, 'Point', 0) * v)
		end
	end
	
	return total_point
end

-- 제련한 해방석과 개수, 잉여 point
item_tempest_core.get_unsealing_item = function(str)
	local item_name = 'None'
	local success, unsealing_item_id, material_dic = item_tempest_core.get_valid_format_make_unsealing_material(str)
	if success == false then
		return item_name, 0, 0
	end

	local cls = GetClassByType('tempest_core_unsealing_item_list', unsealing_item_id)
	if cls == nil then
		return item_name, 0, 0
	end
	
	local unsealing_item_point = TryGetProp(cls, 'MakePoint', 999999)
	
	local total_point = item_tempest_core.get_total_point_from_material(str)
	if total_point < unsealing_item_point then
		return item_name, 0, 0
	end

	item_name = TryGetProp(cls, 'ClassName', 'None')
	local count = math.floor(total_point / unsealing_item_point)
	local remain = math.fmod(total_point, unsealing_item_point)
	return item_name, count, remain, unsealing_item_point
end

item_tempest_core.is_able_to_decompose = function(item)
	local cls = GetClass('tempest_core_item_list', item.ClassName)
	if cls == nil then
		return false
	end	

	return true
end

item_tempest_core.get_decomposed_item = function(item)
	local item_point = 0
	local ret = 'None', 0
	local cls = GetClass('tempest_core_item_list', item.ClassName)
	if cls == nil then
		return ret
	end	
		
	local retunn_item = 'misc_unsealing_stone_540'
	local per_point = 100
	local point = TryGetProp(cls, 'RequirePoint', 0) -- 옵션당 필요 포인트
	
	if point == 0 then
		return ret
	end
	
	for i = 1, item_tempest_core.get_max_option_count() do
		local option_name = 'RandomOption_' .. i
		if TryGetProp(item, option_name, 'None') ~= 'None' then
			item_point = item_point + math.floor(point * 0.6)
		end
	end
	
	item_point = item_point + TryGetProp(cls, 'BaseReturnPoint', 0)	
	return retunn_item, math.floor(item_point / per_point)
end

-- target_item_idx#재료id/개수;재료id2/개수2
item_tempest_core.get_valid_format_unsealing_option = function(str)
	local ret1, ret2, ret3 = false, nil, {}

	local token = StringSplit(str, '#')
	if #token ~= 2 then
		return ret1, ret2, ret3
	end
	ret2 = token[1]
	-- tempest_core_unsealing_item_list
	local token = StringSplit(token[2], ';')
	for i = 1, #token do
		local pair = StringSplit(token[i], '/')	
		if #pair ~= 2 then
			return ret1, ret2, ret3
		end
		
		local k, v = tonumber(pair[1]), tonumber(pair[2])
		if k == nil or v == nil then
			return ret1, ret2, ret3
		end

		local cls = GetClassByType('tempest_core_unsealing_item_list', k)

		if cls == nil then
			return ret1, ret2, ret3
		end

		ret3[cls.ClassName] = v
	end

	ret1 = true
	return ret1, ret2, ret3
end

-- 재료들의 포인트 총량
item_tempest_core.get_unsealing_item_point = function(list)
	local total_point = 0
	for k, v in pairs(list) do
		local cls = GetClass('tempest_core_unsealing_item_list', k)
		if cls ~= nil then
			total_point = total_point + (TryGetProp(cls, 'OptionPoint', 0) * v)
		end
	end
	
	return total_point
end

item_tempest_core.get_total_point_from_unsealing = function(str)
	local token = StringSplit(str, '#')
	if #token > 0 then
		local id = tonumber(token[1])
		if id == nil then
			return 0
		end

		local dic = {}
		local _token = StringSplit(token[2], ';')
		for i = 1, #_token do
			local pair = StringSplit(_token[i], '/')
			if #pair ~= 2 then
				return 0
			end
			
			local k, v = tonumber(pair[1]), tonumber(pair[2])
			if k == nil or v == nil then
				return 0
			end
			dic[k] = v
		end

		local total_point = 0
		for k, v in pairs(dic) do
			local cls = GetClassByType('tempest_core_unsealing_item_list', k)
			if cls ~= nil then
				total_point = total_point + (TryGetProp(cls, 'OptionPoint', 0) * v)
			end
		end
		return total_point
	end
	return 0
end

item_tempest_core.get_start_idx = function(item)
	local start_idx = 1
	for i = 1, item_tempest_core.get_max_option_count() do
		local option_name = 'RandomOption_' .. i
		if TryGetProp(item, option_name, 'None') ~= 'None' then
			start_idx = i + 1
		end
	end
	return start_idx
end

item_tempest_core.get_end_idx = function(item, mat_point)
	local cls = GetClass('tempest_core_item_list', item.ClassName) -- 코어 아이템
	if cls == nil then
		return 0 
	end

	local require_point = TryGetProp(cls, 'RequirePoint', 0) -- 옵션 1개당 필요한 포인트
	if require_point == 0 then
		return 0 
	end

	local start_idx = item_tempest_core.get_start_idx(item)
	local end_idx = start_idx
	local num = math.floor(mat_point / require_point)
	if num == 0 then
		return 0
	end

	end_idx = start_idx + num - 1
	return end_idx
end

-- 해방석 제조 재료 목록
item_tempest_core.get_unsealing_material_list = function(str)
	local ret = {}

	local list, cnt = GetClassList('tempest_core_unsealing_material')
	for i = 0, cnt - 1 do
		local cls = GetClassByIndexFromList(list, i)
		if cls ~= nil then
			local id = TryGetProp(cls, 'ClassID', 0)
			local name = TryGetProp(cls, 'ClassName', 'None')
			local point = TryGetProp(cls, 'Point', 0)
			table.insert(ret, {id, name, point})
		end
	end

	return ret
end

-- 해방석 목록
item_tempest_core.get_unsealing_item_list = function(str)
	local ret = {}

	local list, cnt = GetClassList('tempest_core_unsealing_item_list')
	for i = 0, cnt - 1 do
		local cls = GetClassByIndexFromList(list, i)
		if cls ~= nil then
			local id = TryGetProp(cls, 'ClassID', 0)
			local name = TryGetProp(cls, 'ClassName', 'None')
			local point = TryGetProp(cls, 'OptionPoint', 0)
			local MakePoint = TryGetProp(cls, 'MakePoint', 0)
			table.insert(ret, {id, name, point, MakePoint})
		end
	end

	return ret
end

item_tempest_core.get_unsealing_item_make_point = function(str)
	local list, cnt = GetClassList('tempest_core_unsealing_item_list')
	for i = 0, cnt - 1 do
		local cls = GetClassByIndexFromList(list, i)
		if cls ~= nil then
			local cls_name = TryGetProp(cls, "ClassName", "None")
			if cls_name == str then
				return TryGetProp(cls, "MakePoint", 0)
			end
		end
	end
	return 0
end

item_tempest_core.is_tempest_core_item = function(str)
	local list, cnt = GetClassList('tempest_core_item_list')
	for i = 0, cnt - 1 do
		local cls = GetClassByIndexFromList(list, i)
		if cls ~= nil then
			local cls_name = TryGetProp(cls, "ClassName", "None")
			if cls_name == str then
				return true
			end
		end
	end
	return false
end

item_tempest_core.get_tempest_core_require_point = function(str)
	local list, cnt = GetClassList('tempest_core_item_list')
	for i = 0, cnt - 1 do
		local cls = GetClassByIndexFromList(list, i)
		if cls ~= nil then
			local cls_name = TryGetProp(cls, "ClassName", "None")
			if cls_name == str then
				return TryGetProp(cls, "RequirePoint", 0)
			end
		end
	end
	return 0
end

item_tempest_core.get_tempest_core_unsealing_option_count = function(item_obj)
	local unsealing_count = 0
	if item_obj ~= nil then
		local prop_item = item_obj
		for i = 1, item_tempest_core.get_max_option_count() do
			local prop_group_name = "RandomOptionGroup_"..i
			local prop_name = "RandomOption_"..i
			local prop_value = "RandomOptionValue_"..i
			if prop_item[prop_name] ~= "None" and prop_item[prop_value] ~= 0 then
				unsealing_count = unsealing_count + 1
			end
		end
	end
	return unsealing_count
end

function GET_TEMPEST_CORE_540_OPTION_LIST()
	local ret = {'core_option_vibora', 'core_option_ausirine', 'core_option_gabija', 'core_option_jurate'}
	local ret1 = {{2, 3}, {2, 3}, {2, 3}, {2, 3}}
	return ret, ret1
end

function GET_HALCYON_CORE_540_OPTION_LIST()
	local ret = {'HEAL_PWR', 'DEF', 'MDEF', 'MHP'}
	local ret1 = {{4000, 4500}, {600000, 700000}, {600000, 700000}, {45000, 50000}}
	return ret, ret1
end
