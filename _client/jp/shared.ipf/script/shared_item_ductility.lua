-- shared_item_ductility
-- Ductility_Count_NT="0" -- 수치 연성 카운트

shared_item_ductility = {}

shared_item_ductility.is_able_to_ductility = function(item, index)
    if TryGetProp(item, 'EnableDuctility', 'None') == 'NO' then
        return false, 'CantDuctilityEquipment'
    end

    if string.find(TryGetProp(item, 'ClassName', 'None'), '_high2') ~= nil then
        return false  -- 최상급은 안됨
    end

    if TryGetProp(item, 'GroupName', 'None') ~= 'SHOULDER' and TryGetProp(item, 'GroupName', 'None') ~= 'BELT' then
        return false, 'CantDuctilityEquipment'
    end
    
    if TryGetProp(item, 'CharacterBelonging', 0) == 0 and TryGetProp(item, 'TeamBelonging', 0) == 0 then
        return false, 'OnlyUseBelongingItem'
    end

    local ret = shared_item_ductility.is_valid_ductility_index(item, index)
    if ret == false then
        return false, 'NotValidRandomOptionIndex'
    end

    if TryGetProp(item, 'RandomOption_' .. index, 'None') == 'None' then
        return false, 'NotExistRandomOption'
    end

    local name = TryGetProp(item, 'RandomOption_' .. index)
    local value = TryGetProp(item, 'RandomOptionValue_' .. index)

    if name == 'SR' or name == 'SDR' then
        return false, 'ImpossibleDuctilityRandomOption'
    end

    local group_name = TryGetProp(item, 'GroupName', 'None')

    if group_name == 'SHOULDER' then
        local _, max = shared_item_shoulder.get_option_value_range(item, name)
        if value >= max then
            return false, 'CantDuctilityEquipment'
        end
    elseif group_name == 'BELT' then
        local _, max = shared_item_belt.get_option_value_range(item, name)
        if value >= max then
            return false, 'CantDuctilityEquipment'
        end
    end
    
    return true, 'None'
end

shared_item_ductility.is_able_to_ductility_option = function(item,index)
    local ret = shared_item_ductility.is_valid_ductility_index(item, index)
    if ret == false then
        return false, 'NotValidRandomOptionIndex'
    end

    if TryGetProp(item, 'RandomOption_' .. index, 'None') == 'None' then
        return false, 'NotExistRandomOption'
    end

    local name = TryGetProp(item, 'RandomOption_' .. index)
    local value = TryGetProp(item, 'RandomOptionValue_' .. index)

    if name == 'SR' or name == 'SDR' then
        return false, 'ImpossibleDuctilityRandomOption'
    end
    return true, 'None'
end

shared_item_ductility.is_able_to_ductility_without_index = function(item)    
    local group_name = TryGetProp(item, 'GroupName', 'None')

    if TryGetProp(item, 'EnableDuctility', 'None') == 'None' or TryGetProp(item, 'EnableDuctility', 'None') == 'NO' then
        return false, 'CantDuctilityEquipment'
    end

    if string.find(TryGetProp(item, 'ClassName', 'None'), '_high2') ~= nil then
        return false  -- 최상급은 안됨
    end

    if TryGetProp(item, 'GroupName', 'None') ~= 'SHOULDER' and TryGetProp(item, 'GroupName', 'None') ~= 'BELT' then
        return false, 'CantDuctilityEquipment'
    end
    
    if TryGetProp(item, 'CharacterBelonging', 0) == 0 and TryGetProp(item, 'TeamBelonging', 0) == 0 then
        return false, 'OnlyUseBelongingItem'
    end

    if group_name == 'SHOULDER' or group_name == 'BELT' then
        return true
    end    

    return false
end

shared_item_ductility.is_valid_ductility_index = function(item, index)
    local group_name = TryGetProp(item, 'GroupName', 'None')

    if group_name == 'SHOULDER' then
        local max = shared_item_shoulder.get_max_random_option_count(item)
        if index >= 1 and index <= max then
            return true
        end
    elseif group_name == 'BELT' then
        local max = shared_item_belt.get_max_random_option_count(item)
        if index >= 1 and index <= max then
            return true
        end
    end

    return false
end

-- 아이템 생성시 옵션 최대, 최소
shared_item_ductility.get_option_value_range = function(item, option_name)
    local group_name = TryGetProp(item, 'GroupName', 'None')
    if group_name == 'SHOULDER' then
        return shared_item_shoulder.get_option_value_range(item, option_name)
    elseif group_name == 'BELT' then
        return shared_item_belt.get_option_value_range(item, option_name)
    end

    return 0, 0
end

shared_item_ductility.get_ductility_cost_table = function(item)
    local cost_list = {}
    local valid = false

    local lv = TryGetProp(item, 'UseLv', 0)
    local grade = 'LOW'
    if string.find(TryGetProp(item, 'ClassName', 'None'), '_high') ~= nil then
        grade = 'HIGH'
    end
    local group_name = TryGetProp(item, 'GroupName', 'None')
    local count = TryGetProp(item, 'Ductility_Count', 0) 
    
    local misc_base = 1
    local coin_base = 300
    local ore_base = 150
    if lv == 480 then
        if grade == 'LOW' then            
            local cost_count = misc_base * math.pow(1.05, count)
            cost_count = math.floor(cost_count)
            cost_count = math.min(cost_count, 20)
            cost_list['piece_penetration_belt'] = math.floor(cost_count)  -- 서버에서 NoTrade 우선 소모되도록 처리함

            cost_count = misc_base * math.pow(1.05, count)
            cost_count = math.floor(cost_count)
            cost_count = math.min(cost_count, 20)
            cost_list['piece_fierce_shoulder'] = math.floor(cost_count)

            cost_count = coin_base * math.pow(1.05, count)
            cost_count = math.floor(cost_count)
            cost_count = math.min(cost_count, 30000)
            cost_list['VakarineCertificate'] = math.floor(cost_count)

            cost_count = ore_base * math.pow(1.05, count)
            cost_count = math.floor(cost_count)
            cost_count = math.min(cost_count, 3000)
            cost_list['misc_ore22'] = math.floor(cost_count)
            valid = true
        else    
            local cost_count = misc_base * math.pow(1.05, count)
            cost_count = math.floor(cost_count)
            cost_count = math.min(cost_count, 20)
            cost_list['piece_penetration_belt'] = math.floor(cost_count) * 3

            cost_count = misc_base * math.pow(1.05, count)
            cost_count = math.floor(cost_count)
            cost_count = math.min(cost_count, 20)
            cost_list['piece_fierce_shoulder'] = math.floor(cost_count) * 3

            cost_count = coin_base * math.pow(1.05, count)
            cost_count = math.floor(cost_count)
            cost_count = math.min(cost_count, 30000)
            cost_list['VakarineCertificate'] = math.floor(cost_count) * 3

            cost_count = ore_base * math.pow(1.05, count)
            cost_count = math.floor(cost_count)
            cost_count = math.min(cost_count, 3000)
            cost_list['misc_ore22'] = math.floor(cost_count) * 3
            valid = true
        end
    elseif lv == 510 then
        local cost_count = misc_base * math.pow(1.05, count)
            cost_count = math.floor(cost_count)
            cost_count = math.min(cost_count, 20)
            cost_list['piece_EP16_penetration_belt'] = math.floor(cost_count) * 3

            cost_count = misc_base * math.pow(1.05, count)
            cost_count = math.floor(cost_count)
            cost_count = math.min(cost_count, 20)
            cost_list['piece_EP16_fierce_shoulder'] = math.floor(cost_count) * 3

            cost_count = coin_base * math.pow(1.05, count)
            cost_count = math.floor(cost_count)
            cost_count = math.min(cost_count, 30000)
            cost_list['JurateCertificate'] = math.floor(cost_count) * 3

            cost_count = ore_base * math.pow(1.05, count)
            cost_count = math.floor(cost_count)
            cost_count = math.min(cost_count, 3000)
            cost_list['misc_ore28'] = math.floor(cost_count) * 3
            valid = true
    elseif lv == 540 then
        local cost_count = misc_base * math.pow(1.05, count)
        if group_name == 'SHOULDER' then
            cost_count = misc_base * math.pow(1.01, count)
            cost_count = math.floor(cost_count)
            cost_count = math.min(cost_count, 20)            
            cost_list['piece_EP17_fierce_shoulder'] = math.floor(cost_count) * 1
        elseif group_name == 'BELT' then
            cost_count = misc_base * math.pow(1.01, count)
            cost_count = math.floor(cost_count)
            cost_count = math.min(cost_count, 20)
            cost_list['piece_EP17_penetration_belt'] = math.floor(cost_count) * 1
        end

        cost_count = coin_base * math.pow(1.01, count)
        cost_count = math.floor(cost_count)
        cost_count = math.min(cost_count, 30000)
        cost_list['AustejaCertificate'] = math.floor(cost_count) * 3

        cost_count = ore_base * math.pow(1.01, count)
        cost_count = math.floor(cost_count)
        cost_count = math.min(cost_count, 3000)
        cost_list['misc_ore29'] = math.floor(cost_count) * 1
        valid = true
    elseif lv == 560 then
        if grade == 'LOW' then            
            
        else

        end
    end

    return cost_list, valid
end

-- 연성을 수행하면 올라갈 수치를 반환한다.
shared_item_ductility.get_add_point = function(item, index)
    local name = TryGetProp(item, 'RandomOption_' .. index, 'None')
    if name == 'None' then
        return 0
    end

    local value = TryGetProp(item, 'RandomOptionValue_' .. index, 0)
    local _, max = shared_item_ductility.get_option_value_range(item, name)    
    local add = math.max(1, max * 0.01)
    local diff = max - value
    add = math.min(add, diff)
    add = math.floor(add)
    return add
end
