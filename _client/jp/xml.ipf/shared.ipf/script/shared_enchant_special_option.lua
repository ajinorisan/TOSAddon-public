-- shared_enchant_special_option.lua

-- EnchantItemRank="0" EnchantItemRankCount="0"

local index_list = {'A', 'B', 'C', 'D'}

function GET_ACC_RANK_VALUE(rank)
	if rank == 'A' then
		return 4
	elseif rank == 'B' then
		return 3
	elseif rank == 'C' then
		return 2
	else
		return 1
	end
end

shared_enchant_special_option = {}
local option_range_list = {}
-- local index_list = {'D', 'C', 'B', 'A'}
local option_range_by_grade = nil

local cadidate_option_list = nil  -- 라인별로 등장하는 옵션들의 리스트만 구성
-- [high] [line] [rank] : option_list
local cadidate_option_list_ratio = nil
local job_list = nil

local function shared_make_option_range_by_grade()
    if option_range_by_grade == nil then
        option_range_by_grade = {}
        option_range_by_grade['low'] = {}
        option_range_by_grade['high'] = {}

        -- 아이템의 랭크가 A 일때
        option_range_by_grade['low']['A'] = {}
        option_range_by_grade['low']['A'][1] = {} -- 첫번째 라인
        option_range_by_grade['low']['A'][2] = {} 
        option_range_by_grade['low']['A'][3] = {} 
        option_range_by_grade['low']['A'][1]['A'] = 0 -- A 랭크 아이템의 1번째 라인에 A 등급 옵션 수치가 붙을 확률
        option_range_by_grade['low']['A'][1]['B'] = 50 -- A 랭크 아이템의 1번째 라인에 B 등급 옵션 수치가 붙을 확률
        option_range_by_grade['low']['A'][1]['C'] = 50
        option_range_by_grade['low']['A'][1]['D'] = 0        
        option_range_by_grade['low']['A'][2]['A'] = 0
        option_range_by_grade['low']['A'][2]['B'] = 30   
        option_range_by_grade['low']['A'][2]['C'] = 70
        option_range_by_grade['low']['A'][2]['D'] = 0        
        option_range_by_grade['low']['A'][3]['A'] = 0 
        option_range_by_grade['low']['A'][3]['B'] = 15   
        option_range_by_grade['low']['A'][3]['C'] = 20
        option_range_by_grade['low']['A'][3]['D'] = 65

        option_range_by_grade['high']['A'] = {}
        option_range_by_grade['high']['A'][1] = {} -- 첫번째 라인
        option_range_by_grade['high']['A'][2] = {} 
        option_range_by_grade['high']['A'][3] = {}
        option_range_by_grade['high']['A'][1]['A'] = 100 -- A 랭크 아이템의 1번째 라인에 A 등급 옵션 수치가 붙을 확률
        option_range_by_grade['high']['A'][1]['B'] = 0 -- A 랭크 아이템의 1번째 라인에 B 등급 옵션 수치가 붙을 확률
        option_range_by_grade['high']['A'][1]['C'] = 0
        option_range_by_grade['high']['A'][1]['D'] = 0        
        option_range_by_grade['high']['A'][2]['A'] = 30
        option_range_by_grade['high']['A'][2]['B'] = 70   
        option_range_by_grade['high']['A'][2]['C'] = 0
        option_range_by_grade['high']['A'][2]['D'] = 0        
        option_range_by_grade['high']['A'][3]['A'] = 15 
        option_range_by_grade['high']['A'][3]['B'] = 85   
        option_range_by_grade['high']['A'][3]['C'] = 0
        option_range_by_grade['high']['A'][3]['D'] = 0

        option_range_by_grade['low']['B'] = {}       
        option_range_by_grade['low']['B'][1] = {}
        option_range_by_grade['low']['B'][2] = {}
        option_range_by_grade['low']['B'][3] = {}
        option_range_by_grade['low']['B'][1]['A'] = 0 
        option_range_by_grade['low']['B'][1]['B'] = 25 
        option_range_by_grade['low']['B'][1]['C'] = 75
        option_range_by_grade['low']['B'][1]['D'] = 0
        option_range_by_grade['low']['B'][2]['A'] = 0
        option_range_by_grade['low']['B'][2]['B'] = 10  
        option_range_by_grade['low']['B'][2]['C'] = 40
        option_range_by_grade['low']['B'][2]['D'] = 50
        option_range_by_grade['low']['B'][3]['A'] = 0 
        option_range_by_grade['low']['B'][3]['B'] = 7   
        option_range_by_grade['low']['B'][3]['C'] = 23
        option_range_by_grade['low']['B'][3]['D'] = 70

        option_range_by_grade['high']['B'] = {}       
        option_range_by_grade['high']['B'][1] = {}
        option_range_by_grade['high']['B'][2] = {}
        option_range_by_grade['high']['B'][3] = {}
        option_range_by_grade['high']['B'][1]['A'] = 0 
        option_range_by_grade['high']['B'][1]['B'] = 100 
        option_range_by_grade['high']['B'][1]['C'] = 0
        option_range_by_grade['high']['B'][1]['D'] = 0
        option_range_by_grade['high']['B'][2]['A'] = 0
        option_range_by_grade['high']['B'][2]['B'] = 30  
        option_range_by_grade['high']['B'][2]['C'] = 70
        option_range_by_grade['high']['B'][2]['D'] = 0
        option_range_by_grade['high']['B'][3]['A'] = 0 
        option_range_by_grade['high']['B'][3]['B'] = 15   
        option_range_by_grade['high']['B'][3]['C'] = 85
        option_range_by_grade['high']['B'][3]['D'] = 0

        option_range_by_grade['low']['C'] = {}
        option_range_by_grade['low']['C'][1] = {}
        option_range_by_grade['low']['C'][2] = {}
        option_range_by_grade['low']['C'][3] = {}
        option_range_by_grade['low']['C'][1]['A'] = 0 
        option_range_by_grade['low']['C'][1]['B'] = 0 
        option_range_by_grade['low']['C'][1]['C'] = 25
        option_range_by_grade['low']['C'][1]['D'] = 75
        option_range_by_grade['low']['C'][2]['A'] = 0
        option_range_by_grade['low']['C'][2]['B'] = 0  
        option_range_by_grade['low']['C'][2]['C'] = 10
        option_range_by_grade['low']['C'][2]['D'] = 90
        option_range_by_grade['low']['C'][3]['A'] = 0 
        option_range_by_grade['low']['C'][3]['B'] = 0   
        option_range_by_grade['low']['C'][3]['C'] = 7
        option_range_by_grade['low']['C'][3]['D'] = 93

        option_range_by_grade['high']['C'] = {}
        option_range_by_grade['high']['C'][1] = {}
        option_range_by_grade['high']['C'][2] = {}
        option_range_by_grade['high']['C'][3] = {}
        option_range_by_grade['high']['C'][1]['A'] = 0 
        option_range_by_grade['high']['C'][1]['B'] = 0 
        option_range_by_grade['high']['C'][1]['C'] = 100
        option_range_by_grade['high']['C'][1]['D'] = 0
        option_range_by_grade['high']['C'][2]['A'] = 0
        option_range_by_grade['high']['C'][2]['B'] = 0  
        option_range_by_grade['high']['C'][2]['C'] = 30
        option_range_by_grade['high']['C'][2]['D'] = 70
        option_range_by_grade['high']['C'][3]['A'] = 0 
        option_range_by_grade['high']['C'][3]['B'] = 0   
        option_range_by_grade['high']['C'][3]['C'] = 20
        option_range_by_grade['high']['C'][3]['D'] = 80        

        option_range_by_grade['low']['D'] = {}
        option_range_by_grade['low']['D'][1] = {}
        option_range_by_grade['low']['D'][2] = {}
        option_range_by_grade['low']['D'][3] = {}        
        option_range_by_grade['low']['D'][1]['A'] = 0 
        option_range_by_grade['low']['D'][1]['B'] = 0 
        option_range_by_grade['low']['D'][1]['C'] = 0
        option_range_by_grade['low']['D'][1]['D'] = 100
        option_range_by_grade['low']['D'][2]['A'] = 0
        option_range_by_grade['low']['D'][2]['B'] = 0  
        option_range_by_grade['low']['D'][2]['C'] = 0
        option_range_by_grade['low']['D'][2]['D'] = 100
        option_range_by_grade['low']['D'][3]['A'] = 0 
        option_range_by_grade['low']['D'][3]['B'] = 0   
        option_range_by_grade['low']['D'][3]['C'] = 0
        option_range_by_grade['low']['D'][3]['D'] = 100

        option_range_by_grade['high']['D'] = {}
        option_range_by_grade['high']['D'][1] = {}
        option_range_by_grade['high']['D'][2] = {}
        option_range_by_grade['high']['D'][3] = {}
        option_range_by_grade['high']['D'][1]['A'] = 0 
        option_range_by_grade['high']['D'][1]['B'] = 0 
        option_range_by_grade['high']['D'][1]['C'] = 50
        option_range_by_grade['high']['D'][1]['D'] = 50
        option_range_by_grade['high']['D'][2]['A'] = 0
        option_range_by_grade['high']['D'][2]['B'] = 0  
        option_range_by_grade['high']['D'][2]['C'] = 30
        option_range_by_grade['high']['D'][2]['D'] = 70
        option_range_by_grade['high']['D'][3]['A'] = 0 
        option_range_by_grade['high']['D'][3]['B'] = 0   
        option_range_by_grade['high']['D'][3]['C'] = 15
        option_range_by_grade['high']['D'][3]['D'] = 85
    end

    if cadidate_option_list == nil then
        local list_low, cnt_low = GetClassList('enchant_special_option_ratio_low')
        local list, cnt = GetClassList('enchant_special_option_ratio')

        cadidate_option_list = {}
        cadidate_option_list['low'] = {}
        cadidate_option_list['high'] = {}
        cadidate_option_list_ratio = {}
        cadidate_option_list_ratio['low'] = {}
        cadidate_option_list_ratio['high'] = {}

        for i = 1, 3 do
            cadidate_option_list['low'][i] = {}
            cadidate_option_list['high'][i] = {}
            cadidate_option_list_ratio['low'][i] = {}
            cadidate_option_list_ratio['high'][i] = {}

            for j = 1, #index_list do
                local rank = index_list[j]
                cadidate_option_list['low'][i][rank] = {}
                cadidate_option_list_ratio['low'][i][rank] = {}

                for k = 0, cnt_low - 1 do
                    local cls = GetClassByIndexFromList(list_low, k)
                    local option = TryGetProp(cls, 'ClassName', 'None')
                    local ratio = TryGetProp(cls, 'AppearRatio_' .. rank, 0)
                    local fix_line = TryGetProp(cls, 'FixLine', 0)
                    if fix_line > 0 then
                        if fix_line == i then
                            table.insert(cadidate_option_list['low'][i][rank], option)
                            table.insert(cadidate_option_list_ratio['low'][i][rank], tonumber(ratio))
                        end
                    else
                        table.insert(cadidate_option_list['low'][i][rank], option)
                        table.insert(cadidate_option_list_ratio['low'][i][rank], tonumber(ratio))
                    end
                end

                cadidate_option_list['high'][i][rank] = {}                
                cadidate_option_list_ratio['high'][i][rank] = {}

                for k = 0, cnt - 1 do
                    local cls = GetClassByIndexFromList(list, k)
                    local option = TryGetProp(cls, 'ClassName', 'None')
                    local ratio = TryGetProp(cls, 'AppearRatio_' .. rank, 0)
                    local fix_line = TryGetProp(cls, 'FixLine', 0)
                    if fix_line > 0 then
                        if fix_line == i then
                            table.insert(cadidate_option_list['high'][i][rank], option)
                            table.insert(cadidate_option_list_ratio['high'][i][rank], tonumber(ratio))
                        end
                    else
                        table.insert(cadidate_option_list['high'][i][rank], option)
                        table.insert(cadidate_option_list_ratio['high'][i][rank], tonumber(ratio))
                    end
                end               
            end
        end
    end

    if job_list == nil then
        job_list = {}

        local list, cnt = GetClassList('Job')
        for i = 0, cnt - 1 do
            local cls = GetClassByIndexFromList(list, i)
            if TryGetProp(cls, 'EnableJob', 'None') == 'YES' and TryGetProp(cls, 'Rank', 0) > 1 then
                local name = TryGetProp(cls, 'JobName', 'None')
                if name ~= 'None' then
                    table.insert(job_list, name)
                end
            end
        end
    end
end

shared_make_option_range_by_grade()

shared_enchant_special_option.get_option_range_by_grade = function()
    if option_range_by_grade == nil then
        shared_make_option_range_by_grade()
    end

    return option_range_by_grade
end

shared_enchant_special_option.get_cadidate_option_list = function()
    if cadidate_option_list == nil then
        shared_make_option_range_by_grade()
    end

    return cadidate_option_list
end

shared_enchant_special_option.get_cadidate_option_list_ratio = function()
    if cadidate_option_list_ratio == nil then
        shared_make_option_range_by_grade()
    end

    return cadidate_option_list_ratio
end


shared_enchant_special_option.is_special_option = function(option)
    if string.find(option, 'ALLSKILL') ~= nil then
        return true
    end

    local cls = GetClass('enchant_special_option', option)
    if cls ~= nil then
        if TryGetProp(cls, 'Type', 'None') == 'special' then
            return true
        end
    end
    return false
end

function IS_SPECIAL_ENCHANT_OPTION(option)    
    return shared_enchant_special_option.is_special_option(option)
end

shared_enchant_special_option.get_item_rank = function(item)
    local rank = 'D'
    local value = TryGetProp(item, 'EnchantItemRank', 0)
    if value == 1 then
        rank = 'C'
    elseif value == 2 then
        rank = 'B'
    elseif value == 3 then
        rank = 'A'
    end

    return rank
end

shared_enchant_special_option.is_hair_acc = function(item)
    local slot = TryGetProp(item, 'DefaultEqpSlot', 'None')
    if slot == 'HAT_L' or slot == 'HAT_T' or slot == 'HAT' then
        return true
    else
        return false
    end
end

shared_enchant_special_option.get_enchant_item_grade = function(item)
    local rank = 'None'
    local value = TryGetProp(item, 'StringArg', 'None')
    if value == 'enchantchip_high' then
        rank = 'high'
    elseif value == 'enchantchip_low' then
        rank = 'low'
    end

    return rank
end

shared_enchant_special_option.get_value_range = function(option, enchant_grade, rank, line)
    local rank_list = {}            
    local list = shared_enchant_special_option.get_cadidate_option_list()[enchant_grade][line][rank]
    local exist = false

    for i = 1, #list do
        if list[i] == option then
            exist = true
            break
        end
    end

    if exist == false then
        return {0, 0}
    end


    list = shared_enchant_special_option.get_option_range_by_grade()[enchant_grade][rank][line]
    for k, v in pairs(list) do
        if v > 0 then
            if rank_list[k] == nil then
                rank_list[k] = 1
            end
        end
    end
    
    local cls = nil
    local appear_cls = nil
    
    if string.find(option, 'ALLSKILL') ~= nil then        
        cls = GetClass('enchant_special_option', 'ALLSKILL')
        if enchant_grade == 'low' then
            appear_cls = GetClass('enchant_special_option_ratio_low', 'ALLSKILL')
        else
            appear_cls = GetClass('enchant_special_option_ratio', 'ALLSKILL')
        end
    else
        
        cls = GetClass('enchant_special_option', option)
        if enchant_grade == 'low' then
            appear_cls = GetClass('enchant_special_option_ratio_low', option)
        else
            appear_cls = GetClass('enchant_special_option_ratio', option)
        end
    end

    local token = StringSplit(TryGetProp(cls, 'Range_D', 'None'), '-')
    local min = token[1]
    
    local real_max = 0
    
    for num, _rank in pairs(index_list) do
        if TryGetProp(appear_cls, 'AppearRatio_' .. _rank, 0) > 0 and _rank == rank then
            for k, v in pairs(rank_list) do  
                token = StringSplit(TryGetProp(cls, 'Range_' .. k, 'None'), '-')        
                local max = tonumber(token[2])                
                if real_max < max then
                    real_max = max
                end    
            end
        end
    end
    
    if real_max == 0 then
        min = 0
    end
    
    return {min, real_max}
end

-- 누적된 천정 수치
shared_enchant_special_option.get_item_rank_up_count = function(item)
    local rank = shared_enchant_special_option.get_item_rank(item)
    local now = TryGetProp(item, 'EnchantItemRankCount', 0)
    local cls = GetClass('enchant_rank_up_ratio', 'Rankup_count')    
    local need = TryGetProp(cls, 'Rankup' .. rank, 0)
    return now, need
end


-- 옵션 선정
function GET_SELECT_ENCHANT_OPTION(enchant_grade, rank, line)
    local list = shared_enchant_special_option.get_cadidate_option_list()[enchant_grade][line][rank]
    local list_ratio = shared_enchant_special_option.get_cadidate_option_list_ratio()[enchant_grade][line][rank]
    local i = GIBBS_SAMPLING(list_ratio)
    local option = list[i]

    if option == 'ALLSKILL' then
        local ran = IMCRandom(1, #job_list)
        option = option .. '_' .. job_list[ran]
    end

    return option
end

function GET_SELECT_ENCHANT_VALUE(enchant_grade, rank, line, option)
    local list = shared_enchant_special_option.get_option_range_by_grade()[enchant_grade][rank][line]
    local ratio_list = {}
    for i = 1, #index_list do
        table.insert(ratio_list, list[index_list[i]])
    end
    
    local ret = GIBBS_SAMPLING(ratio_list)
    local option_rank = index_list[ret]
    
    if string.find(option, 'ALLSKILL') ~= nil then
        option = 'ALLSKILL'
    end

    local cls = GetClass('enchant_special_option', option)
    local range = TryGetProp(cls, 'Range_' .. option_rank)
    local token = StringSplit(range, '-')
    local min = tonumber(token[1])
    local max = tonumber(token[2])

    local value = IMCRandom(min, max)
    return value, option_rank
end

function GET_ITEM_GRADE(obj)
    local grade = TryGetProp(obj, 'ItemGrade', 'None')

    local group_name = TryGetProp(obj, 'GroupName', 'Name')
    if group_name == 'Ark' then
        for i = 1, MAX_OPTION_EXTRACT_COUNT do
            local name = TryGetProp(obj, 'RandomOption_' .. i, 'None')
            if name ~= 'None' then
                grade = 6
                break
            end
        end
    end

    if shared_enchant_special_option.is_hair_acc(obj) == true then
        local rank = shared_enchant_special_option.get_item_rank(obj)
        local value = GET_ACC_RANK_VALUE(rank)
        if value < 2 then
            grade = 0
        elseif value == 2 then
            grade = 4
        elseif value == 3 then
            grade = 5
        elseif value == 4 then
            grade = 6
        end
    end

    local rank = TryGetProp(obj, 'UpgradeRank', 0)
    if rank >= 10 then
        grade = rank
    end

    return grade
end