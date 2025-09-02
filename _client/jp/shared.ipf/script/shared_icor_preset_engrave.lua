-- shared_icor_preset_engrave.lua

-- 각인
function GET_MAX_ENGARVE_SLOT_COUNT(acc_obj)
    local base = 2 -- 기본 2개 제공

    -- 유료 아이템 사용중이면 +5개
    local is_expire = ENGRAVE_SLOT_EXTENSION_EXPIRED(acc_obj)
    if is_expire == false then
        base = base + 5
    end

    base = base + TryGetProp(acc_obj, 'ADDITIONAL_ENGRAVE_SLOT_TEAMBATTLE', 0)
    base = base + TryGetProp(acc_obj, 'ADDITIONAL_ENGRAVE_SLOT_ACHIEVELEVEL', 0)
    base = base + TryGetProp(acc_obj, 'ADDITIONAL_ENGRAVE_SLOT_ACHIEVE', 0)

    return base
end

-- return - 옵션개수
function GET_VAILD_RANDOM_OPTION_COUNT(item_obj)
    local count = 0
    local maxRandomOptionCnt = 6;
    for i = 1, maxRandomOptionCnt do
        local option = TryGetProp(item_obj, 'RandomOption_'..i, 'None')
        if option ~= 'None' then
            count = count + 1
        else
            break
        end
    end

    return count
end

-- 각인이 가능한 아이템인가?, 아이커인 경우, 방어구 랜덤 아이커만 가능
-- return,  가능여부, 기본성공확률
-- type : {0:각인 저장(아이커), 2:각인 저장(옛날)}
function IS_ENABLE_TO_ENGARVE(item_obj, type)    
    if item_goddess_growth.is_goddess_growth_item(item_obj) == true then
        return false, 0
    end
    
    if type == 2 then                
        if TryGetProp(item_obj, 'UseLv', 0) > 460 then
            return false, 0
        end
    end
    

    if shared_item_goddess_icor.get_goddess_icor_grade(item_obj) > 0 then        
        return true, 100
    end    

    if TryGetProp(item_obj, 'GroupName', 'None') == 'Icor' and TryGetProp(item_obj, 'InheritanceRandomItemName', 'None') ~= 'None' then
        local cls = GetClass('Item', TryGetProp(item_obj, 'InheritanceRandomItemName', 'None'))
        if cls == nil then
            return false, 0
        end

        local class_type = string.upper(TryGetProp(cls, 'DefaultEqpSlot', 'None'))
        local option_count = GET_VAILD_RANDOM_OPTION_COUNT(item_obj)
        if option_count < 1 then
            return false, 0
        end

        local lv = TryGetProp(cls, 'UseLv', 1)
        if lv < 430 then
            return false, 0
        end

        if class_type == 'SHIRT' or class_type == 'PANTS' or class_type == 'BOOTS' or class_type == 'GLOVES' then
            return true, 100
        end
    else
        local grade = TryGetProp(item_obj, 'ItemGrade', 1)
        local lv = TryGetProp(item_obj, 'UseLv', 1)        
        if grade >= 6 and lv >= 470 and TryGetProp(item_obj, 'GroupName', 'None') == 'Armor' then            
            return false, 0
        end

        local option_count = GET_VAILD_RANDOM_OPTION_COUNT(item_obj)
        if grade >= 6 and option_count >= 1 and lv == 460 then
            return true, 0
        end
    end

    return false, 0
end

-- 각인석인지 확인
function IS_ENGRAVE_MATERIAL_ITEM(item_obj, target_lv)
    local lv = TryGetProp(item_obj, 'NumberArg1', 0)
    if lv < target_lv then
        return false, 0
    end
    if TryGetProp(item_obj, 'StringArg', 'None') ~= 'Engrave' then
        return false, 0
    end
    
    local rate = TryGetProp(item_obj, 'NumberArg2', 0)
    if  rate < 1 then
        return false, 0
    end
    return true, rate
end

-- 각인저장 비용
-- return, coin_name, cost
function GET_COST_SAVE_ENGRAVE(item_obj)
    local lv = TryGetProp(item_obj, 'UseLv', 1)
    local coin = 'GabijaCertificate'    

    -- 시즌이 거듭되면 위에다가 레벨 체크 추가
    if lv <= 460 then
        coin = 'GabijaCertificate'
    end

    local cost = math.floor((lv / 10) * 3)    
    return coin, cost
end

-- 각인부여 비용
function GET_COST_APPLY_ENGRAVE(item_obj)
    local lv = TryGetProp(item_obj, 'UseLv', 1)
    local coin = 'GabijaCertificate'

    -- 시즌이 거듭되면 위에다가 레벨 체크 추가
    if lv <= 460 then
        coin = 'GabijaCertificate'
    end

    if lv == 480 then
        coin = 'VakarineCertificate'
    elseif lv == 500 then
        coin = 'RadaCertificate'
    elseif lv == 520 then
        coin = 'JurateCertificate'
    elseif lv == 540 then
        coin = 'AustejaCertificate'
    end

    local cost = math.floor((lv / 20) * 3)    
    return coin, cost
end

-- 각인석으로 변환 가능한 아이템인가?
-- return, 가능여부, 지급할 아이템, 개수
function IS_ENABLE_TO_EXCHANGE_ENGRAVE(item_obj)
    if TryGetProp(item_obj, 'LifeTime', 0) > 1 then
        return false, 'None', 0
    end
    
    if TryGetProp(item_obj, 'ExpireDateTime', 'None') ~= 'None' then
        return false, 'None', 0
    end

    local string = TryGetProp(item_obj, 'StringArg', 'None')

    if string == 'Extract_kit_Sliver' or string == 'Dirbtumas_kit_Sliver' or string == 'Tuto_Extract_kit_silver_Team' then
        return true, 'misc_Engrave_460_NoTrade', 1
    end

    if string == 'Extract_kit_Gold' or string == 'Tuto_Extract_kit_Gold_Team' then
        return true, 'misc_Engrave_460_NoTrade', 2
    end

    return false, 'None', 0
end

-- 인챈트 쥬얼로 변환 가능한 아이템인가?
-- return, 가능여부, 지급할 아이템, 개수
function IS_ENABLE_TO_EXCHANGE_ENCHANT(item_obj)
    if TryGetProp(item_obj, 'LifeTime', 0) > 1 then
        return false, 'None', 0
    end
    
    if TryGetProp(item_obj, 'ExpireDateTime', 'None') ~= 'None' then
        return false, 'None', 0
    end

    local string = TryGetProp(item_obj, 'StringArg', 'None')
    if string ~= 'EnchantJewell' then
        return false, 'None', 0
    end
       
    local lv = TryGetProp(item_obj, 'Level', 0)
    lv = math.max(lv, TryGetProp(item_obj, 'NumberArg1', 0))
    
    if lv < 460 then
        return false, 'None', 0
    end
    
    if TryGetProp(item_obj, 'ItemGrade', 1) ~= 5 then
        return false, 'None', 0
    end
    
    return true, 'misc_Enchant_460_NoTrade', 4
end

-- 강화 보조제로 변환 가능한 아이템인가?
-- return, 가능여부, 지급할 아이템, 개수
function IS_ENABLE_TO_EXCHANGE_REINFORCE_PERCENTUP(item_obj)
    if TryGetProp(item_obj, 'LifeTime', 0) > 1 then
        return false, 'None', 0
    end
    
    if TryGetProp(item_obj, 'ExpireDateTime', 'None') ~= 'None' then
        return false, 'None', 0
    end

    local string = TryGetProp(item_obj, 'StringArg', 'None')

    if string == 'SILVER' then
        return true, 'misc_reinforce_percentUp_460_NoTrade', 1
    end

    if string == 'gold_Moru' then
        return true, 'misc_reinforce_percentUp_460_NoTrade', 1
    end

    if string == 'unique_gold_Moru' then
        return true, 'misc_reinforce_percentUp_460_NoTrade', 2
    end

    return false, 'None', 0
end

-- 저장된 각인 정보의 옵션, 그룹, 값 리스트를 각각 리턴
function GET_ENGRAVED_OPTION_LIST(etc, index, spot)
    if etc == nil then
        return nil
    end

    local suffix = string.format('_%d_%s', tonumber(index), spot)

    local option_prop = TryGetProp(etc, 'RandomOptionPreset'.. suffix, 'None')
    local group_prop = TryGetProp(etc, 'RandomOptionGroupPreset'.. suffix, 'None')
    local value_prop = TryGetProp(etc, 'RandomOptionValuePreset'.. suffix, 'None')

    if option_prop == 'None' then
        return nil
    end

    local option_list = SCR_STRING_CUT(option_prop, '/')
    local group_list = SCR_STRING_CUT(group_prop, '/')
    local value_list = SCR_STRING_CUT(value_prop, '/')
  
    local is_goddess_option = TryGetProp(etc, 'IsGoddessIcorOption'.. suffix, 0)

    return option_list, group_list, value_list, is_goddess_option
end

-- 저장된 각인 정보 딕셔너리 가져오기
function GET_ENGRAVED_OPTION_BY_INDEX_SPOT(etc, index, spot)
    if etc == nil then
        return nil
    end

    local option_list, group_list, value_list, is_goddess_option = GET_ENGRAVED_OPTION_LIST(etc, index, spot)     
    if option_list == nil then
        return nil
    end

    local option_dic = {}
    for i = 1, #option_list do
		local prop_name = 'RandomOption_' .. i
        local group_name = 'RandomOptionGroup_' .. i
        local prop_value = 'RandomOptionValue_' .. i
        
        option_dic[prop_name] = option_list[i]
        option_dic[group_name] = group_list[i]
        option_dic[prop_value] = tonumber(value_list[i])
    end

    option_dic['Size'] = #option_list
    option_dic['is_goddess_option'] = is_goddess_option

    return option_dic
end

-- 아이템의 랜덤 옵션 딕셔너리 반환
function GET_ITEM_RANDOMOPTION_DIC(item_obj)
    if item_obj == nil then
        return nil
    end

    local option_dic = {}
    option_dic['Size'] = 0    
    for i = 1, MAX_RANDOM_OPTION_COUNT do
        local prop_name = 'RandomOption_' .. i
        local group_name = 'RandomOptionGroup_' .. i
        local prop_value = 'RandomOptionValue_' .. i
        local prop = TryGetProp(item_obj, prop_name, 'None')        
        if prop ~= 'None' then
            local group = TryGetProp(item_obj, group_name, 'None')
            local value = TryGetProp(item_obj, prop_value, 0)
            
            option_dic[prop_name] = prop
            option_dic[group_name] = group
            option_dic[prop_value] = value
            option_dic['Size'] = option_dic['Size'] + 1            
        else            
            
        end
    end

    return option_dic
end

-- 아이템 딕셔너리와 저장된 각인 딕셔너리 비교: true 리턴 시 이미 동일한 랜덤옵션
function COMPARE_ITEM_OPTION_TO_ENGRAVED_OPTION(item_dic, engrave_dic)
    if item_dic == nil or engrave_dic == nil then
        return false
    end

    if item_dic.Size ~= engrave_dic.Size then
        return false
    end

    for i = 1, item_dic.Size do
        local name = item_dic['RandomOption_' .. i]
        local group = item_dic['RandomOptionGroup_' .. i]
        local value = item_dic['RandomOptionValue_' .. i]
        
        local search_flag = false
        for j = 1, engrave_dic.Size do
            local _name = engrave_dic['RandomOption_' .. j]
            local _group = engrave_dic['RandomOptionGroup_' .. j]
            local _value = engrave_dic['RandomOptionValue_' .. j]

            if _name == name and _group == group and _value == value then
                search_flag = true
                break
            end
        end

        if search_flag == false then
            return false
        end
    end

    return true
end

-- 각인 부여 가능한 아이템인가
function IS_ENABLE_TO_ENGRAVE_APPLY(item_obj, index, spot, etc)
    if item_obj == nil then return false, 'None' end

    if item_goddess_growth.is_goddess_growth_item(item_obj) == true then
        return false, 'IMPOSSIBLE_ITEM'
    end
    
    local suffix = string.format('IsGoddessIcorOption_%d_%s', tonumber(index), spot) 
    local is_goddess_icor_option = TryGetProp(etc, suffix, 0) -- 저장된 옵션이 가디스 아이커 옵션인가?    
    if TryGetProp(item_obj, 'ItemGrade', 0) ~= 6 then
        return false, 'OnlyGoddessGradeEquipment'
    end

    if is_goddess_icor_option >= 1 and TryGetProp(item_obj, 'EnableGoddessIcor', 0) == 0 then        
        return false, 'CantEngraveGoddessIcor'
    end

    return true
end

function IS_GODDESS_ICOR_SPOT(spot)
    if spot == 'SHIRT' or spot == 'PANTS' or spot == 'GLOVES' or spot == 'BOOTS' or spot == 'RH' or spot == 'RH_SUB' or spot == 'LH' or spot == 'LH_SUB' then
        return true
    else
        return false
    end
end

function ENABLE_ENGRAVE_EQUIP(item_obj)
    local group_name = TryGetProp(item_obj, 'GroupName', 'None')

    if TryGetProp(item_obj, 'ItemGrade' , 0) >= 6 and TryGetProp(item_obj, 'UseLv', 0) >= 460 then
		if group_name == 'Armor' or  string.find(group_name, 'Weapon') ~= nil then
			return true
		end
    end
    
    return false
end
