-- shared_skill_gem_random_option.lua
-- 스킬젬 랜덤 옵션 (검색용)

shared_skill_gem_random_option = {}
local skill_gem_list_with_ctrl_type = nil
local candidate_item_list = {}  -- 스킬젬 목록
local item_skill_gem_random_option_list = nil
local option_range = nil

local random_option_group_name = nil
local option_count_by_level = nil -- 레벨에 따른 최대 옵션 개수

function make_skill_gem_random_option()
    local level_list = {480, 540} -- 레벨별로 랜덤 옵션이 다르다.
    local level_option_count = {1, 1}

    skill_gem_list_with_ctrl_type = {} -- 어떤 스킬젬이 어떤 클래스 것 인지

    item_skill_gem_random_option_list = {}
    random_option_group_name = {}
    option_range = {}
    option_count_by_level = {}

    for i = 1, #level_list do
        local level = level_list[i]
        option_range[level] = {}
        option_count_by_level[level] = level_option_count[i]
    end

    random_option_group_name['AllRace_Atk'] = 'ATK'         -- 모든 종족 대상 공격력    
    random_option_group_name['Add_Damage_Atk'] = 'ATK'      -- 추가 대미지 
    random_option_group_name['AllMaterialType_Atk'] = 'ATK' -- 모든 방어구 재질 공격력
    random_option_group_name['ADD_CLOTH'] = 'ATK'   
    random_option_group_name['ADD_LEATHER'] = 'ATK'   
    random_option_group_name['ADD_IRON'] = 'ATK'   
    random_option_group_name['ADD_SMALLSIZE'] = 'ATK'   
    random_option_group_name['ADD_MIDDLESIZE'] = 'ATK'   
    random_option_group_name['ADD_LARGESIZE'] = 'ATK'   
    random_option_group_name['ADD_GHOST'] = 'ATK'   
    random_option_group_name['ADD_FORESTER'] = 'ATK'   
    random_option_group_name['ADD_WIDLING'] = 'ATK'   
    random_option_group_name['ADD_VELIAS'] = 'ATK'   
    random_option_group_name['ADD_PARAMUNE'] = 'ATK'   
    random_option_group_name['ADD_KLAIDA'] = 'ATK'   

    random_option_group_name['STR'] = 'STAT'
    random_option_group_name['DEX'] = 'STAT'
    random_option_group_name['CON'] = 'STAT'
    random_option_group_name['INT'] = 'STAT'
    random_option_group_name['MNA'] = 'STAT'

    random_option_group_name['CRTHR'] = 'UTIL_ARMOR'        -- 치명타 발생
    random_option_group_name['BLK_BREAK'] = 'UTIL_ARMOR'    -- 블록 관통
    random_option_group_name['BLK'] = 'UTIL_ARMOR'          -- 블록
    random_option_group_name['ADD_HR'] = 'UTIL_ARMOR'       -- 명중
    random_option_group_name['ADD_DR'] = 'UTIL_ARMOR'       -- 회피
    random_option_group_name['CRTDR'] = 'UTIL_ARMOR'        -- 치명타 저항
    
    random_option_group_name['ResAdd_Damage'] = 'DEF'       -- 추가 대미지 저항    
    random_option_group_name['Cloth_Def'] = 'DEF'
    random_option_group_name['Leather_Def'] = 'DEF'
    random_option_group_name['Iron_Def'] = 'DEF'
    random_option_group_name['MiddleSize_Def'] = 'DEF'

    local max = {}

    max = {321, 481} -- lv480, lv540
    local set_list = {'AllMaterialType_Atk', 'AllRace_Atk'}

    for k, v in pairs(set_list) do
        for i = 1, #max do
            local level = level_list[i]
            option_range[level][v] = max[i]
        end

        table.insert(item_skill_gem_random_option_list, v)
    end

    max = {377, 565}
    set_list = {'ADD_CLOTH', 'ADD_LEATHER', 'ADD_IRON', 'ADD_GHOST', 'ADD_SMALLSIZE', 'ADD_MIDDLESIZE', 'ADD_LARGESIZE', 
                    'ADD_FORESTER', 'ADD_WIDLING', 'ADD_VELIAS', 'ADD_PARAMUNE', 'ADD_KLAIDA'}
    for k, v in pairs(set_list) do
        for i = 1, #max do
            local level = level_list[i]
            option_range[level][v] = max[i]
        end
        table.insert(item_skill_gem_random_option_list, v)
    end

    max = {565, 847}
    set_list = {'Add_Damage_Atk'}
    for k, v in pairs(set_list) do
        for i = 1, #max do
            local level = level_list[i]
            option_range[level][v] = max[i]
        end
        table.insert(item_skill_gem_random_option_list, v)
    end

    max = {56, 84}
    set_list = {'STR', 'DEX', 'CON', 'INT', 'MNA'}
    for k, v in pairs(set_list) do
        for i = 1, #max do
            local level = level_list[i]
            option_range[level][v] = max[i]
        end
        table.insert(item_skill_gem_random_option_list, v)
    end

    max = {188, 282}
    set_list = {'CRTHR', 'BLK_BREAK', 'BLK', 'ADD_HR', 'ADD_DR', 'CRTDR'}
    for k, v in pairs(set_list) do
        for i = 1, #max do
            local level = level_list[i]
            option_range[level][v] = max[i]
        end
        table.insert(item_skill_gem_random_option_list, v)
    end

    max = {565, 847}
    set_list = {'ResAdd_Damage'}
    for k, v in pairs(set_list) do
        for i = 1, #max do
            local level = level_list[i]
            option_range[level][v] = max[i]
        end
        table.insert(item_skill_gem_random_option_list, v)
    end

    max = {377, 565}
    set_list = {'Cloth_Def', 'Leather_Def', 'Iron_Def', 'MiddleSize_Def'}
    for k, v in pairs(set_list) do
        for i = 1, #max do
            local level = level_list[i]
            option_range[level][v] = max[i]
        end
        table.insert(item_skill_gem_random_option_list, v)
    end
   
    local list, cnt = GetClassList('Item')
    for i = 0, cnt - 1 do
        local cls = GetClassByIndexFromList(list, i);
        if TryGetProp(cls, 'StringArg', 'None') == 'SkillGem' and TryGetProp(cls, 'StringArg2', 'None') =='None' then
            local class_name = TryGetProp(cls, 'ClassName', 'None')
            if class_name ~= 'None' then
                local skill_name = TryGetProp(cls, 'SkillName', 'None')
                if skill_name ~= 'None' then
                    local skl_cls = GetClass('Skill', skill_name)
                    if skl_cls ~= nil then
                        local job = TryGetProp(skl_cls, 'Job', 'None')
                        local _list, _cnt = GetClassListByProp('Job', 'JobName', job)
                        if _cnt > 0 then
                            local job_cls = _list[1]                
                            local ctrl_type = TryGetProp(job_cls, 'CtrlType', 'None')
                            skill_gem_list_with_ctrl_type[class_name] = ctrl_type
                            table.insert(candidate_item_list, class_name) -- 스킬젬 목록
                        end
                    end
                end
            end
        end
    end
end


make_skill_gem_random_option()

shared_skill_gem_random_option.get_random_skill_gem = function()
    local ran = IMCRandom(1, #candidate_item_list)
    return candidate_item_list[ran]
end

-- 스킬 젬 ClassName으로 어떤 직업 것인지 가져온다.
shared_skill_gem_random_option.get_ctrl_type = function(skill_gem_class_name)
    return skill_gem_list_with_ctrl_type[skill_gem_class_name]
end

shared_skill_gem_random_option.get_option_count = function(level)
    local ret = option_count_by_level[level]
    if ret == nil then
        return 1
    else
        return ret
    end
end

shared_skill_gem_random_option.get_option_group_by_name = function(option_name)
    return random_option_group_name[option_name]
end

shared_skill_gem_random_option.get_max_option_value = function(level, option_name)
    local ret = option_range[level][option_name]
    if ret == nil then
        return 0
    else
        return ret
    end
end

shared_skill_gem_random_option.get_option_list = function()
    local list = item_skill_gem_random_option_list
    return list
end

shared_skill_gem_random_option.get_cadidate_list = function(ctrl_type)    
    local list = shuffle2(item_skill_gem_random_option_list)
    local list2 = {}
    ctrl_type = string.lower(ctrl_type)
    
    local remove_list = {}
    if ctrl_type == 'warrior' or ctrl_type == 'archer' or ctrl_type == 'scout' then  -- 물리 계열        
        remove_list['INT'] = 1
        remove_list['MNA'] = 1
    elseif ctrl_type == 'wizard' then
        remove_list['STR'] = 1
        remove_list['DEX'] = 1
    end
    
    for i = 1, #list do        
        if remove_list[list[i]] == nil then
            table.insert(list2, list[i])    
        end
    end

    return list2
end


shared_skill_gem_random_option.can_register_cabinet = function(item)
    for i = 1, 4 do
		local op = 'RandomOptionValue_' .. i
		local value = TryGetProp(invitem, op, 0)
		if value > 0 then
			return false
		end
	end

	return true
end

function IS_RANDOM_OPTION_SKILL_GEM(item)
    if TryGetProp(item, 'StringArg', 'None') ~= 'SkillGem' then
        return false
    end

    for i = 1, 4 do
        local option_prop_name = 'RandomOption_' .. i
        local option_prop_value = 'RandomOptionValue_' .. i
        if TryGetProp(item, option_prop_name, 'None') ~= 'None' and TryGetProp(item, option_prop_value, 0) > 0 then
            return true
        end
    end

    return false
end

function IS_CONVERTABLE_RANDOM_OPTION_SKILL_GEM(gem, scroll)
    if TryGetProp(gem, 'MarketCategory', 'None') ~= 'Gem_GemSkill' then
        return false
    end

    local gem_arg = TryGetProp(gem, 'StringArg2', 'None')
    local scroll_arg = TryGetProp(scroll, 'StringArg', 'None')
    if gem_arg == nil or gem_arg == 'None' then
        return false
    end

    if gem_arg ~= scroll_arg then
        return false
    end

    local job_cls = GetClassByStrProp('Job', 'JobName', gem_arg)
    if job_cls == nil then
        return false
    end

    for i = 1, 4 do
        local option_prop_name = 'RandomOption_' .. i
        local option_prop_value = 'RandomOptionValue_' .. i
        if TryGetProp(gem, option_prop_name, 'None') ~= 'None' and TryGetProp(gem, option_prop_value, 0) > 0 then
            return true
        end
    end

    return false
end

function GET_CONVERTABLE_SKILLGEM_LIST(gem)
    local gem_arg = TryGetProp(gem, 'StringArg2', 'None')
    if gem_arg == nil or gem_arg == 'None' then return end

    local job_cls = GetClassByStrProp('Job', 'JobName', gem_arg)
	if job_cls == nil then return end

	local available_list = {}
	for i = 1, 99 do
		local skltree_cls = GetClass('SkillTree', TryGetProp(job_cls, 'ClassName', 'None') .. '_' .. i)
		if skltree_cls == nil then
			break
		end

		local skl_name = TryGetProp(skltree_cls, 'SkillName', 'None')
		local available_cls = GetClass('Item', 'GEM_' .. skl_name)
		if available_cls == nil then
			available_cls = GetClass('Item', 'Gem_' .. skl_name)
		end
		if available_cls ~= nil then
			table.insert(available_list, TryGetProp(available_cls, 'ClassName', 'None'))
		end
    end
    
    return available_list
end