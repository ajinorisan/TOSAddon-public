-- 아이템 룬 shared_item_earring


shared_item_earring = {}
local item_earring_option_range = nil
item_earring_base_option_list = {'STR', 'DEX', 'CON', 'INT', 'MNA'}
item_earring_max_stats_option_count = 3 -- 최대 3개

item_earring_base_ctrl_list = {'Warrior', 'Wizard', 'Archer', 'Cleric', 'Scout'}
local item_earring_max_special_option_count = nil 
item_earring_ctrl_tree = nil
item_earring_ctrl_tree_dup = nil

shared_item_earring.MAX_SLOT_CNT = 25;

local function make_item_earring_option_range()
    if item_earring_option_range ~= nil then
        return
    end
    
    item_earring_ctrl_tree = {}
    item_earring_ctrl_tree_dup = {}
    for _, ctrl in pairs(item_earring_base_ctrl_list) do
        item_earring_ctrl_tree[ctrl] = {}
        item_earring_ctrl_tree_dup[ctrl] = {}
    end

    local cls_list, cnt = GetClassList('Job')
    for i = 0, cnt - 1 do
        local cls = GetClassByIndexFromList(cls_list, i)
        if TryGetProp(cls, 'EnableJob', 'None') == 'YES' then
            local ctrl_type = TryGetProp(cls, 'CtrlType', 'None')
            if ctrl_type ~= 'None' and TryGetProp(cls, 'Rank', 0) > 1 then
                table.insert(item_earring_ctrl_tree[ctrl_type], TryGetProp(cls, 'ClassName', 'None'))

                table.insert(item_earring_ctrl_tree_dup[ctrl_type], {TryGetProp(cls, 'ClassName', 'None'), 1})
                table.insert(item_earring_ctrl_tree_dup[ctrl_type], {TryGetProp(cls, 'ClassName', 'None'), 2})
                table.insert(item_earring_ctrl_tree_dup[ctrl_type], {TryGetProp(cls, 'ClassName', 'None'), 3})
            end
        end
    end

    local base_lv = 470    
    item_earring_max_special_option_count = {}

    item_earring_option_range = {}
    item_earring_option_range['normal'] = {}
    item_earring_option_range['special'] = {}

    local start = 470    
    while start <= 500 do
        if item_earring_option_range['normal'][start] == nil then
            item_earring_option_range['normal'][start] = {}
            item_earring_option_range['special'][start] = {}
        end
        
        for k, option_name in pairs(item_earring_base_option_list) do
            item_earring_option_range['normal'][start][option_name] = {}
            local min_value = 50
            local max_value = 150
            if start == 470 then
                min_value = 50
                max_value = 150
            elseif start == 480 then
                min_value = 100
                max_value = 200
            end
            item_earring_option_range['normal'][start][option_name]['min'] = min_value
            item_earring_option_range['normal'][start][option_name]['max'] = max_value
        end

        -- 스킬 레벨
        local base_special_min_value = 1
        local base_special_max_value = 5
        if start == 470 then
            base_special_min_value = 1
            base_special_max_value = 5 
        elseif start == 480 then
            base_special_min_value = 1
            base_special_max_value = 5
        elseif start == 490 then
            base_special_min_value = 1
            base_special_max_value = 5
        elseif start > 490 then
            base_special_min_value = 1
            base_special_max_value = 5
        end

        item_earring_option_range['special'][start]['min'] = base_special_min_value
        item_earring_option_range['special'][start]['max'] = base_special_max_value
        
        item_earring_max_special_option_count[start] = 3  -- 붙을 수 있는 특수 옵션 개수

        start = start + 10        
    end
end

make_item_earring_option_range()

shared_item_earring.get_normal_option_value_range = function(lv, option_name)
    if item_earring_option_range['normal'][lv] == nil or item_earring_option_range['normal'][lv][option_name] == nil then
        return 1, 1
    end

    return item_earring_option_range['normal'][lv][option_name]['min'], item_earring_option_range['normal'][lv][option_name]['max']
end

-- 붙을 수 있는 특수 옵션 최대 개수
shared_item_earring.get_max_special_option_count = function(lv)
    if item_earring_max_special_option_count[lv] == nil then
        return 3
    else
        return item_earring_max_special_option_count[lv]
    end
end

shared_item_earring.get_special_option_value_range = function(lv)
    if item_earring_option_range['special'][lv] == nil then
        return 1, 1
    end

    return item_earring_option_range['special'][lv]['min'], item_earring_option_range['special'][lv]['max']
end

-- 최대 맥스치 옵션 개수
shared_item_earring.get_max_special_option_count = function(lv)
    if lv == 470 then
        return 3
    end

    if lv == 480 then
        return 3
    end

    if lv == 490 then
        return 3
    end

    if lv > 490 then
        return 3
    end

    return 3
end

shared_item_earring.is_valid_unlock_item = function(scrollObj, itemObj)
    if TryGetProp(itemObj, 'CharacterBelonging', 0) == 0 then
		return false, 'OnlyUseBelongingItem'
	end

	if TryGetProp(itemObj, 'ItemLv', 0) ~= TryGetProp(scrollObj, 'NumberArg1', 999) then
		return false, 'NotValidItem'
	end

	if TryGetProp(scrollObj, 'StringArg', 'None') == 'None' then
		return false, 'NotValidItem'
	end

    if TryGetProp(scrollObj, 'StringArg', 'None') == 'unlock_earring_team_belonging' and TryGetProp(itemObj, 'ClassName', 'None') == 'EP13_GabijaEarring' then
        return true, 'None'
    end
    
    if TryGetProp(scrollObj, 'StringArg', 'None') == 'unlock_earring_team_belonging' and TryGetProp(itemObj, 'ClassName', 'None') == 'NoTrade_EP13_GabijaEarring' then
        return true, 'None'
    end
    
    if TryGetProp(scrollObj, 'StringArg', 'None') ~= TryGetProp(itemObj, 'ClassName', 'None') then
		return false, 'NotValidItem'
    end
    
    return true, 'None'
end

shared_item_earring.get_unlock_belonging_ticket_count = function(pc, item)
    if TryGetProp(item, 'ItemLv', 0) == 470 then
        return shared_item_earring.get_earring_grade(item)
    end
    return 15
end

shared_item_earring.get_earring_grade = function(item)
    local lv = TryGetProp(item, 'ItemLv', 0)
    local count = shared_item_earring.get_max_special_option_count(lv)
    local grade = 0
    for i = 1, count do
        grade = grade + TryGetProp(item, 'EarringSpecialOptionLevelValue_' .. i, 0)
    end

    return grade
end

shared_item_earring.get_fragmentation_count = function(item)
    if TryGetProp(item, 'GroupName', 'None') == 'Earring' then
        local lv = TryGetProp(item, 'ItemLv', 0)
        local count = shared_item_earring.get_max_special_option_count(lv)
        local grade = 0
        for i = 1, count do
            grade = grade + TryGetProp(item, 'EarringSpecialOptionLevelValue_' .. i, 0)
        end

        return grade
    elseif TryGetProp(item, 'GroupName', 'None') == 'BELT' or 
        TryGetProp(item, 'GroupName', 'None') == 'SHOULDER' or
        shared_item_goddess_icor.get_goddess_icor_grade(item) > 0 then
        return TryGetProp(item, 'NumberArg1', 1)
    elseif IS_RANDOM_OPTION_SKILL_GEM(item) then
        return 1
    end

    return 1
end

shared_item_earring.is_able_to_fragmetation = function(item)
    if IS_RANDOM_OPTION_SKILL_GEM(item) == true then
        return true
    end

    if TryGetProp(item, 'ClassName', 'None') == 'EP13_SampleGabijaEarring' then
        return false
    end

    if TryGetProp(item, 'UseLv', 0) < 470 then
        return false
    end
    
    if TryGetProp(item, 'GroupName', 'None') ~= 'Earring' and TryGetProp(item, 'GroupName', 'None') ~= 'BELT' and TryGetProp(item, 'GroupName', 'None') ~= 'SHOULDER'
        and shared_item_goddess_icor.get_goddess_icor_grade(item) == 0
    then
        return false
    end

    local clsName = TryGetProp(item, 'ClassName', 'None')
    if string.find(clsName, 'NoTrade_') ~= nil then
        return false
    end
    
    local ex_group = TryGetProp(item, 'ExchangeGroup', 'None')
    if ex_group ~= 'None' then
        return false
    end

    return true
end

-- 지급할 아이템
shared_item_earring.get_give_item_name = function(item)
    if TryGetProp(item, 'GroupName', 'None') == 'Earring' or 
        TryGetProp(item, 'GroupName', 'None') == 'BELT' or 
        TryGetProp(item, 'GroupName', 'None') == 'SHOULDER' or
        shared_item_goddess_icor.get_goddess_icor_grade(item) > 0 then
        return TryGetProp(item, 'StringArg', 'None')
    elseif IS_RANDOM_OPTION_SKILL_GEM(item) then
        local name = 'piece_random_skill_gem_'
        local lv = TryGetProp(item, 'RandomGemLevel', 0) -- 지급할 아이템 suffix 를 의미함
        name = name .. lv
        return name
    end

    return 'None'
end
