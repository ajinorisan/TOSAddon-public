-- growth_by_reinforce.xml

item_goddess_growth = {}
local goddess_growth_option_list = nil

local function make_goddess_growth_option_list()
	if goddess_growth_option_list ~= nil then
		return
	end

	goddess_growth_option_list = {}
	goddess_growth_option_list['Growth_Goddess_Tier1'] = {}	
	goddess_growth_option_list['Growth_Goddess_Tier2'] = {}
	goddess_growth_option_list['Growth_Goddess_Tier3'] = {}

	for i = 1, 20 do		
		local value = 1
		value = math.max(value, math.floor(i / 2 * 1.5)) 

		goddess_growth_option_list['Growth_Goddess_Tier1'][i] = value
		goddess_growth_option_list['Growth_Goddess_Tier2'][i] = 15 + value
		goddess_growth_option_list['Growth_Goddess_Tier3'][i] = 30 + value		
	end
end

make_goddess_growth_option_list()

item_goddess_growth.is_goddess_growth_item = function(item)
	local str_arg = TryGetProp(item, 'StringArg', 'None')
	if str_arg == 'None' then
		return false
	end

	local arg_list = StringSplit(str_arg, '/')
	if #arg_list ~= 2 then
		return false
	end

	local basic_cls = GetClass(arg_list[1], arg_list[2])
	if basic_cls == nil then
		return false
	end

	return true
end

item_goddess_growth.get_material_list = function(item, class_type, goal_lv)	
	if item_goddess_growth.is_goddess_growth_item(item) == false then
		return nil
	end

	local str_arg = TryGetProp(item, 'StringArg', 'None')
	local arg_list = StringSplit(str_arg, '/')	
	local mat_cls = GetClass(arg_list[1], arg_list[2] .. '_' .. class_type)	
	if mat_cls == nil then
		return nil
	end

	local mat_list = nil
	local mat_name_str = TryGetProp(mat_cls, 'Material', 'None')	
	local mat_name_list = StringSplit(mat_name_str, '/')
	local mat_count_str = TryGetProp(mat_cls, 'Count_' .. goal_lv, 'None')	
	if mat_count_str == 'None' then
		return nil, TryGetProp(item, 'Reinforce_2', 0) == 20
	end
	local mat_count_list = StringSplit(mat_count_str, '/')
	for i = 1, #mat_name_list do
		local _mat_name = mat_name_list[i]
		if GetClass('Item', _mat_name) ~= nil then
			if tonumber(mat_count_list[i]) > 0 then
				if mat_list == nil then
					mat_list = {}
				end
				mat_list[_mat_name] = tonumber(mat_count_list[i])
			end
			
		end
	end
	
	return mat_list, TryGetProp(item, 'Reinforce_2', 0) == 20
end

item_goddess_growth.is_max_reinforce = function(item)
	if item_goddess_growth.is_goddess_growth_item(item) then		
		local class_type = TryGetProp(item, 'ClassType', 'None')
		local goal_lv = TryGetProp(item, 'Reinforce_2', 0) + 1

		local _, max = item_goddess_growth.get_material_list(item, class_type, goal_lv)
		return max
	else
		return false
	end
end

item_goddess_growth.get_option_list = function(item, value)
	make_goddess_growth_option_list()

	local option_list = {}
	if value > 20 then
		return option_list
	end

	if item_goddess_growth.is_goddess_growth_item(item) == false then
		return option_list
	else
		local str = TryGetProp(item, 'StringArg', 'None')
		local token = StringSplit(str, '/')
		if #token ~= 2 then
			return option_list
		end

		local key = token[2]
		local dic = goddess_growth_option_list[key]
		if dic == nil then
			return option_list
		end

		local point = goddess_growth_option_list[key][value]
		if point == nil then
			return option_list
		end

		option_list[1] = {}
		option_list[2] = {}
		option_list[3] = {}
		
		option_list[1]['RandomOptionGroup_1'] = 'STAT'
		option_list[1]['RandomOption_1'] = 'STR'
		option_list[1]['RandomOptionValue_1'] = point

		option_list[2]['RandomOptionGroup_2'] = 'STAT'
		option_list[2]['RandomOption_2'] = 'INT'
		option_list[2]['RandomOptionValue_2'] = point

		option_list[3]['RandomOptionGroup_3'] = 'STAT'
		option_list[3]['RandomOption_3'] = 'CON'
		option_list[3]['RandomOptionValue_3'] = point

		return option_list
	end
end