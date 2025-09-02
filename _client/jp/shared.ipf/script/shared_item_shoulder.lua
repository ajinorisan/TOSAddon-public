-- shared_item_shoulder

shared_item_shoulder = {}
local item_shoulder_option_range = nil
local item_shoulder_option_group_index = nil  -- 옵션 그룹이 할당된 인덱스
local max_option_group_count = nil
local max_random_option_count = nil

local option_group = nil  -- 그룹1, 그룹2 ...
local option_group_number_by_option_name = nil
local option_range = nil  -- 
local random_option_group_name = nil

local special_option_linear_list = nil

local candidate_option_count = nil

local function make_item_shoulder_option_range()
    if item_shoulder_option_range ~= nil then
        return
    end
    
    max_option_group_count = {}    
    item_shoulder_option_range = {}
    max_random_option_count = {}
    option_group_number_by_option_name = {}
    item_shoulder_option_group_index = {}
    option_group = {}
    candidate_option_count = {}

    random_option_group_name = {}  -- 옵션이 속한 그룹을 가져옴
    random_option_group_name['CRTATK'] = 'UTIL_ARMOR'    -- 물리 치명타 공격력
    random_option_group_name['CRTMATK'] = 'UTIL_ARMOR'   -- 마법 치명타 공격력
    random_option_group_name['CRTHR'] = 'UTIL_ARMOR'  -- 치명타발생
    random_option_group_name['CRTDR'] = 'UTIL_ARMOR'  -- 치명타저항
    random_option_group_name['BLK'] = 'UTIL_ARMOR' -- 블럭
    random_option_group_name['ADD_DR'] = 'UTIL_ARMOR'  -- 회피
    random_option_group_name['SDR'] = 'UTIL_ARMOR'  -- 광역 방어 비율
    random_option_group_name['MHP'] = 'UTIL_ARMOR'  -- 최대 체력
    random_option_group_name['RHP'] = 'UTIL_ARMOR'  -- HP 회복력

    random_option_group_name['STR'] = 'STAT'
    random_option_group_name['DEX'] = 'STAT'
    random_option_group_name['CON'] = 'STAT'
    random_option_group_name['INT'] = 'STAT'
    random_option_group_name['MNA'] = 'STAT'

    -- local option_name_list = {} -- 특수 옵션 ClassName
    -- local cls_list, cnt = GetClassList('goddess_special_option')
    -- for i = 0, cnt - 1 do
    --     local cls = GetClassByIndexFromList(cls_list, i)
    --     local _name = TryGetProp(cls, 'ClassName', 'None')
    --     random_option_group_name[_name] = 'SPECIAL'    
        
    --     table.insert(option_name_list, _name)
    -- end

    local start = 480
    local end_level = 540

    while start <= end_level do
        max_option_group_count[start] = 2    -- 최대 2개의 옵션 그룹을 가질 수 있음
        max_random_option_count[start] = 4  -- 붙는 랜덤 옵션 개수는 4개
        option_group_number_by_option_name[start] = {}
        
        item_shoulder_option_group_index[start] = {}
        item_shoulder_option_group_index[start][1] = {1}
        item_shoulder_option_group_index[start][2] = {2,3,4}
        
        item_shoulder_option_range[start] = {}
    
        option_group[start] = {}
        option_group[start][1] = {}
        -- 옵션 그룹 1, 아이템 레벨, 그룹 넘버, 등급
        option_group[start][1]['LOW'] = { 'STR', 'DEX', 'CON', 'INT', 'MNA' }
        option_group[start][1]['HIGH'] = { 'STR', 'DEX', 'CON', 'INT', 'MNA' }
        
        item_shoulder_option_range[start][1] = {}
        item_shoulder_option_range[start][1]['LOW'] = {}
        item_shoulder_option_range[start][1]['HIGH'] = {}
    
        for k, option_name in pairs(option_group[start][1]['LOW']) do
            -- 아이템레벨, 그룹 넘버, 등급, 옵션이름
            if start == 480 then
                item_shoulder_option_range[start][1]['LOW'][option_name] = {60, 80}
                item_shoulder_option_range[start][1]['HIGH'][option_name] = {90, 120}
            elseif start == 510 then
                item_shoulder_option_range[start][1]['LOW'][option_name] = {108, 150}
                item_shoulder_option_range[start][1]['HIGH'][option_name] = {140, 180}
            elseif start == 540 then
                item_shoulder_option_range[start][1]['LOW'][option_name] = {150, 195} 
                item_shoulder_option_range[start][1]['HIGH'][option_name] = {195, 234} -- max 표기를 위해 필요함
            end
            option_group_number_by_option_name[start][option_name] = 1
        end
       
        -- 옵션 그룹 2
        option_group[start][2] = {}

        if start == 480 then
            option_group[start][2]['LOW'] = {'CRTATK', 'CRTMATK', 'CRTDR', 'CRTHR', 'BLK', 'ADD_DR', 'SDR', 'MHP', 'RHP'}
            option_group[start][2]['HIGH'] = {'CRTATK', 'CRTMATK', 'CRTDR', 'CRTHR', 'BLK', 'ADD_DR', 'SDR', 'MHP', 'RHP'}        
        elseif start >= 510 then
            option_group[start][2]['LOW'] = {'CRTATK', 'CRTMATK', 'CRTDR', 'CRTHR', 'BLK', 'ADD_DR', 'MHP', 'RHP'}
            option_group[start][2]['HIGH'] = {'CRTATK', 'CRTMATK', 'CRTDR', 'CRTHR', 'BLK', 'ADD_DR', 'MHP', 'RHP'}
        else
            option_group[start][2]['LOW'] = {'CRTATK', 'CRTMATK', 'CRTDR', 'CRTHR', 'BLK', 'ADD_DR', 'SDR', 'MHP', 'RHP'}
            option_group[start][2]['HIGH'] = {'CRTATK', 'CRTMATK', 'CRTDR', 'CRTHR', 'BLK', 'ADD_DR', 'SDR', 'MHP', 'RHP'}        
        end

        

        -- for i = 1, #option_name_list do -- 특수 옵션 추가
        --     local _name = option_name_list[i]
        --     table.insert(option_group[start][2]['HIGH'], _name)
        -- end
        
        item_shoulder_option_range[start][2] = {}
        item_shoulder_option_range[start][2]['LOW'] = {}
        item_shoulder_option_range[start][2]['HIGH'] = {}
            
        if start == 480 then
            item_shoulder_option_range[start][2]['LOW']['CRTATK'] = {2250, 3000}
            item_shoulder_option_range[start][2]['LOW']['CRTMATK'] = {2250, 3000}
            item_shoulder_option_range[start][2]['LOW']['CRTDR'] = {1125, 1500}
            item_shoulder_option_range[start][2]['LOW']['CRTHR'] = {450, 600}
            item_shoulder_option_range[start][2]['LOW']['BLK'] = {1125, 1500}
            item_shoulder_option_range[start][2]['LOW']['ADD_DR'] = {1125, 1500}
            item_shoulder_option_range[start][2]['LOW']['SDR'] = {3, 6}
            item_shoulder_option_range[start][2]['LOW']['MHP'] = {3750, 5000}
            item_shoulder_option_range[start][2]['LOW']['RHP'] = {1125, 1500}
            
            item_shoulder_option_range[start][2]['HIGH']['CRTATK'] = {3750, 5000}
            item_shoulder_option_range[start][2]['HIGH']['CRTMATK'] = {3750, 5000}
            item_shoulder_option_range[start][2]['HIGH']['CRTDR'] = {1875, 2500}
            item_shoulder_option_range[start][2]['HIGH']['CRTHR'] = {750, 1000}
            item_shoulder_option_range[start][2]['HIGH']['BLK'] = {1875, 2500}
            item_shoulder_option_range[start][2]['HIGH']['ADD_DR'] = {1875, 2500}
            item_shoulder_option_range[start][2]['HIGH']['SDR'] = {7, 10}
            item_shoulder_option_range[start][2]['HIGH']['MHP'] = {6000, 8000}
            item_shoulder_option_range[start][2]['HIGH']['RHP'] = {1875, 2500}
        elseif start == 510 then
            item_shoulder_option_range[start][2]['LOW']['CRTATK'] = {4500, 6250}
            item_shoulder_option_range[start][2]['LOW']['CRTMATK'] = {4500, 6250}
            item_shoulder_option_range[start][2]['LOW']['CRTDR'] = {2250, 3125}
            item_shoulder_option_range[start][2]['LOW']['CRTHR'] = {2250, 3125}
            item_shoulder_option_range[start][2]['LOW']['BLK'] = {2250, 3125}
            item_shoulder_option_range[start][2]['LOW']['ADD_DR'] = {2250, 3125}
            item_shoulder_option_range[start][2]['LOW']['MHP'] = {7200, 10000}
            item_shoulder_option_range[start][2]['LOW']['RHP'] = {2250, 3125}
            
            item_shoulder_option_range[start][2]['HIGH']['CRTATK'] = {5000, 7500}
            item_shoulder_option_range[start][2]['HIGH']['CRTMATK'] = {5000, 7500}
            item_shoulder_option_range[start][2]['HIGH']['CRTDR'] = {2500, 3750}
            item_shoulder_option_range[start][2]['HIGH']['CRTHR'] = {2500, 3750}
            item_shoulder_option_range[start][2]['HIGH']['BLK'] = {2500, 3750}
            item_shoulder_option_range[start][2]['HIGH']['ADD_DR'] = {2500, 3750}
            item_shoulder_option_range[start][2]['HIGH']['MHP'] = {8000, 12000}
            item_shoulder_option_range[start][2]['HIGH']['RHP'] = {2500, 3750}
        elseif start == 540 then
            item_shoulder_option_range[start][2]['LOW']['CRTATK'] = {6250, 8125}
            item_shoulder_option_range[start][2]['LOW']['CRTMATK'] = {6250, 8125}
            item_shoulder_option_range[start][2]['LOW']['CRTDR'] = {3125, 4063}
            item_shoulder_option_range[start][2]['LOW']['CRTHR'] = {3125, 4063}
            item_shoulder_option_range[start][2]['LOW']['BLK'] = {3125, 4063}
            item_shoulder_option_range[start][2]['LOW']['ADD_DR'] = {3125, 4063}
            item_shoulder_option_range[start][2]['LOW']['MHP'] = {10000, 13000}
            item_shoulder_option_range[start][2]['LOW']['RHP'] = {3125, 4063}
            
            item_shoulder_option_range[start][2]['HIGH']['CRTATK'] = {8125, 9750} 
            item_shoulder_option_range[start][2]['HIGH']['CRTMATK'] = {8125, 9750} 
            item_shoulder_option_range[start][2]['HIGH']['CRTDR'] = {4063, 4875}
            item_shoulder_option_range[start][2]['HIGH']['CRTHR'] = {4063, 4875}
            item_shoulder_option_range[start][2]['HIGH']['BLK'] = {4063, 4875}
            item_shoulder_option_range[start][2]['HIGH']['ADD_DR'] = {4063, 4875}
            item_shoulder_option_range[start][2]['HIGH']['MHP'] = {13000, 15600}
            item_shoulder_option_range[start][2]['HIGH']['RHP'] = {4063, 4875}
        end
    
        -- for i = 1, #option_name_list do
        --     local _name = option_name_list[i]
        --     item_shoulder_option_range[start][2]['HIGH'][_name] = get_special_option_factor_range(_name, start)
        -- end
        
        for k, option_name in pairs(option_group[start][2]['LOW']) do
            option_group_number_by_option_name[start][option_name] = 2
        end

        -- 옵션 재설정 후보 개수
        candidate_option_count[start] = {}
        if start == 480 then
            candidate_option_count[start]['LOW'] = 2
            candidate_option_count[start]['HIGH'] = 2
        elseif start >= 510 then
            candidate_option_count[start]['LOW'] = 2
            candidate_option_count[start]['HIGH'] = 0
        end

        start = start + 10
    end
end

make_item_shoulder_option_range()

-- 아이템이 붙을 수 있는 옵션 그룹 수
shared_item_shoulder.get_max_option_group_count = function(item)
    local lv = TryGetProp(item, 'UseLv', 1)
    if max_option_group_count[lv] == nil then
        return 0
    end

    return max_option_group_count[lv]
end

-- 해당 옵션 그룹이 부여되어야 하는 random option index
shared_item_shoulder.get_random_option_group_index = function(item, group_num)
    local lv = TryGetProp(item, 'UseLv', 1)
    if item_shoulder_option_group_index[lv] == nil then
        return nil
    end

    if item_shoulder_option_group_index[lv][group_num] == nil then
        return nil
    end

    return item_shoulder_option_group_index[lv][group_num]
end

shared_item_shoulder.get_max_random_option_count = function(item)
    local lv = TryGetProp(item, 'UseLv', 1)
    return max_random_option_count[lv]
end

shared_item_shoulder.get_option_group_number = function(item, option_name)
    local lv = TryGetProp(item, 'UseLv', 1)
    if option_group_number_by_option_name[lv] == nil then
        return 1
    else
        if option_group_number_by_option_name[lv][option_name] == nil then
            return 1
        else
            return option_group_number_by_option_name[lv][option_name]
        end
    end
end

-- 아이템 생성시 옵션 최대, 최소
shared_item_shoulder.get_option_value_range = function(item, option_name)    
    if TryGetProp(item, 'GroupName', 'None') ~= 'SHOULDER' then        
        return 0, 0
    end
    
    local lv = TryGetProp(item, 'UseLv', 0)
    local grade = 'LOW'

    if string.find(TryGetProp(item, 'ClassName', 'None'), '_high') ~= nil then
        grade = 'HIGH'
    end    

    if option_group_number_by_option_name == nil or option_group_number_by_option_name[lv] == nil or option_group_number_by_option_name[lv][option_name] == nil then        
        return 0, 0
    end

    local group_number = option_group_number_by_option_name[lv][option_name]

    if item_shoulder_option_range == nil or item_shoulder_option_range[lv] == nil then        
        return 0, 0
    end

    if item_shoulder_option_range[lv][group_number] == nil or item_shoulder_option_range[lv][group_number][grade] == nil then        
        return 0, 0
    end

    if item_shoulder_option_range[lv][group_number][grade][option_name] == nil then
        return 0, 0
    end
    
    return item_shoulder_option_range[lv][group_number][grade][option_name][1], item_shoulder_option_range[lv][group_number][grade][option_name][2]
end

shared_item_shoulder.get_option_value_range_equip = function(item, option_name)
    local lv = TryGetProp(item, 'UseLv', 0)    
    if item_shoulder_option_range == nil or item_shoulder_option_range[lv] == nil then
        return 1, 1
    end

    if option_group_number_by_option_name == nil or option_group_number_by_option_name[lv] == nil or option_group_number_by_option_name[lv][option_name] == nil then
        return 1, 1
    end

    local grade = 'LOW'

    if string.find(TryGetProp(item, 'ClassName', 'None'), '_high') ~= nil then
        grade = 'HIGH'
    end   

    local group_number = option_group_number_by_option_name[lv][option_name]

    if item_shoulder_option_range == nil or item_shoulder_option_range[lv] == nil then
        return 1, 1
    end

    if item_shoulder_option_range[lv][group_number] == nil or item_shoulder_option_range[lv][group_number][grade] == nil then
        return 1, 1
    end

    if item_shoulder_option_range[lv][group_number][grade][option_name] == nil then
        return 1, 1
    end

    return item_shoulder_option_range[lv][group_number][grade][option_name][1], item_shoulder_option_range[lv][group_number][grade][option_name][2]
end

-- 옵션이 속한 그룹을 가져온다.(UTIL_ARMOR ...)
shared_item_shoulder.get_option_group_name = function(option_name)
    if random_option_group_name[option_name] == nil then
        return 'None'
    end
    return random_option_group_name[option_name]
end

-- 옵션 그룹 리스트를 반환
shared_item_shoulder.get_random_option_group = function(item, group_num)
    local lv = TryGetProp(item, 'UseLv', 0)
    local grade = 'LOW'
    if string.find(TryGetProp(item, 'ClassName', 'None'), '_high') ~= nil then
        grade = 'HIGH'
    end
    local list = shuffle2(option_group[lv][group_num][grade])
    return list
end

-- 해당 랜덤 옵션 인덱스의 그룹이 어디인지 가져온다.
shared_item_shoulder.get_option_group_num = function(item, index)
    local option_prop_name = 'RandomOption_' .. index
    local option_name = TryGetProp(item, option_prop_name, 'None')
    local lv = TryGetProp(item, 'UseLv', 1)
    local grade = 'LOW'
    if string.find(TryGetProp(item, 'ClassName', 'None'), '_high') ~= nil then
        grade = 'HIGH'
    end

    local _max_option_group_count = max_option_group_count[lv]

    for i = 1, _max_option_group_count do
        for k, v in pairs(option_group[lv][i][grade]) do
            if v == option_name then
                return i
            end
        end
    end
    
    return 0
end

shared_item_shoulder.is_valid_reroll_option = function(item, index, option_name, max)
    local class_name = TryGetProp(item, 'ClassName', 'None')
    local very_high = string.find(class_name, '_high2') ~= nil
    
    if very_high then
        local option_prop_name = 'RandomOption_' .. index
        local name = TryGetProp(item, option_prop_name, 'None')
        if option_name == name then            
            return false
        end
    end

    for i = 1, max do
        if i ~= index then
            local option_prop_name = 'RandomOption_' .. i
            local name = TryGetProp(item, option_prop_name, 'None')
            if option_name == name then
                return false
            end
        end
    end

    return true
end

shared_item_shoulder.is_able_to_reroll = function(item, index)    
    if TryGetProp(item, 'GroupName', 'None') ~= 'SHOULDER' then
        return false, 'CantRerollEquipment'
    end

    if TryGetProp(item, 'RandomOption_' .. index, 'None') == 'None' then
        return false, 'NotExistRandomOption'
    end

    local reroll_index = TryGetProp(item, 'RerollIndex', 0)
    if reroll_index ~= 0 and reroll_index ~= index then
        return false, 'DifferentRerollIndex'
    end

    if TryGetProp(item, 'RerollStr', 'None') ~= 'None' then
        return false, 'FirstSelectRerollOption'
    end

    return true, 'None'
end

shared_item_shoulder.get_reroll_cost_table = function(item)
    local cost_list = {}
    local valid = false

    local lv = TryGetProp(item, 'UseLv', 0)
    local grade = 'LOW'
    if string.find(TryGetProp(item, 'ClassName', 'None'), '_high') ~= nil then
        grade = 'HIGH'
    end

    local count = TryGetProp(item, 'RerollCount', 0) 

    if lv == 480 then
        if grade == 'LOW' then            
            local cost_count = 1 + math.floor(count / 5)
            cost_list['misc_BlessedStone'] = math.floor(cost_count)

            cost_count = 300 * math.pow(1.04, count)
            cost_list['VakarineCertificate'] = math.floor(cost_count)

            cost_count = 175 * math.pow(1.04, count)
            cost_list['misc_ore22'] = math.floor(cost_count)
            valid = true
        else    
            local cost_count = 1 + math.floor(count / 3)
            cost_count = cost_count * 1.5
            cost_list['misc_BlessedStone'] = math.floor(cost_count)

            cost_count = 500 * math.pow(1.04, count)
            cost_count = cost_count * 1.3
            cost_list['VakarineCertificate'] = math.floor(cost_count)

            cost_count = 300 * math.pow(1.04, count)
            cost_count = cost_count * 1.5
            cost_list['misc_ore22'] = math.floor(cost_count)
            valid = true
        end
    elseif lv == 510 then
        local cost_count = 2 + math.floor(count / 3)
        cost_count = cost_count * 1.5
        cost_list['misc_BlessedStone_1'] = math.floor(cost_count)

        cost_count = 500 * math.pow(1.04, count)
        cost_count = cost_count * 1.3
        cost_list['JurateCertificate'] = math.floor(cost_count)

        cost_count = 400 * math.pow(1.04, count)
        cost_count = cost_count * 1.5
        cost_list['misc_ore28'] = math.floor(cost_count)
        valid = true
    elseif lv == 540 then
        local cost_count = 1 + math.floor(count / 3)
        cost_count = cost_count * 1.1
        cost_list['misc_BlessedStone_2'] = math.floor(cost_count)

        cost_count = 500 * math.pow(1.04, count)
        cost_count = cost_count * 1.3
        cost_list['AustejaCertificate'] = math.floor(cost_count)

        cost_count = 400 * math.pow(1.04, count)        
        cost_count = cost_count * 1.3
        cost_list['misc_ore29'] = math.floor(cost_count)
        valid = true
    end

    return cost_list, valid
end

shared_item_shoulder.get_candidate_count = function(item)
    if item == nil then
        return 0
    end

    local count = 0

    local lv = TryGetProp(item, 'UseLv', 0)
    local grade = 'LOW'
    if string.find(TryGetProp(item, 'ClassName', 'None'), '_high') ~= nil then
        grade = 'HIGH'
    end

    if candidate_option_count[lv] ~= nil then
        count = candidate_option_count[lv][grade]
    end

    return count
end

shared_item_shoulder.get_option_list_by_index = function(item, index)
    local group_num = shared_item_shoulder.get_option_group_num(item, index)
	if group_num == 0 then
		return
	end
    local lv = TryGetProp(item, 'UseLv', 0)
    local grade = 'LOW'
    if string.find(TryGetProp(item, 'ClassName', 'None'), '_high') ~= nil then
        grade = 'HIGH'
    end
    local list = option_group[lv][group_num][grade]
    return list
end

shared_item_shoulder.is_valid_unlock_item = function(scrollObj, itemObj)
    if TryGetProp(itemObj, 'CharacterBelonging', 0) == 0 then
		return false, 'OnlyUseBelongingItem'
	end

	if TryGetProp(itemObj, 'ItemLv', 0) ~= TryGetProp(scrollObj, 'NumberArg1', 999) then
		return false, 'NotValidItem'
	end

	if TryGetProp(scrollObj, 'StringArg', 'None') == 'None' then
		return false, 'NotValidItem'
	end

    if TryGetProp(scrollObj, 'StringArg', 'None') == 'unlock_shoulder_team_belonging' and string.find(TryGetProp(itemObj, 'ClassName', 'None'), 'fierce_shoulder') ~= nil then
        return true, 'None'
    end
    
	if TryGetProp(scrollObj, 'StringArg', 'None') ~= TryGetProp(itemObj, 'ClassName', 'None') then
		return false, 'NotValidItem'
    end
    
    return true, 'None'
end
