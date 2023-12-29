-- shared_skill_enchant


shared_common_skill_enchant = {}
local max_slot_count = 1
local max_rein = 21

local skill_list = nil
local function make_skill_list()
    skill_list = {}
    
    local list, cnt = GetClassList('enchant_skill_list')
    for i = 0, cnt - 1 do
        local cls = GetClassByIndexFromList(list, i);
        local tier = TryGetProp(cls, 'Tier', 0)
        if tier > 0 then
            local start_lv = 480
            local term = 10
            local name = TryGetProp(cls, 'ClassName', 'None')
            local ratio = TryGetProp(cls, 'Ratio', 100)

            for start_lv = 480, 500, term do
                local min = 1
                local max = TryGetProp(cls, 'MaxLevel', 0)
                if min > 0 and max > 0 then
                    if skill_list[start_lv] == nil then
                        skill_list[start_lv] = {}
                    end

                    if skill_list[start_lv][name] == nil then
                        skill_list[start_lv][name] = {}
                    end
                    
                    skill_list[start_lv][name] = {min, max}                    
                end
            end
        end
    end
end

make_skill_list()

shared_common_skill_enchant.get_skill_list = function(lv)
    return skill_list[lv]    
end

shared_common_skill_enchant.get_max_slot_count = function(lv)
    if lv == nil then
        lv = 480
    end

    if lv == 480 then
        return 1
    end

    return max_slot_count
end

-- 스킬 연성이 가능한 아이템인가
shared_common_skill_enchant.is_valid_item = function(item)
    local list = {'SHIRT', 'PANTS', 'BOOTS', 'GLOVES'}    
    local equip = TryGetProp(item, 'EquipGroup', 'None')
    
    local skill_index = TryGetProp(item, 'EnchantSkillSlotCount', 0)
    for i = 1, skill_index do
        local skill_name = TryGetProp(item, 'EnchantSkillName_' .. i, 'None')
        if skill_name ~= 'None' then
            return true, 'None'
        end
    end

    if table.find(list, equip) == 0 then
        return false, 'NotValidItem'
    end
    
    local grade = TryGetProp(item, 'ItemGrade', 0)    
    if grade < 6 then
        return false, 'NotValidItem'
    end

    local lv = TryGetProp(item, 'UseLv', 0)
    if lv < 480 then
        return false, 'NotValidItem'
    end
    
    if TryGetProp(item, 'EnchantSkillSlotCount', 0) < 1 then
        return false, 'NotValidItem'
    end
    
    if TryGetProp(item, 'Reinforce_2', 0) < max_rein then
        return false, 'RequireReinforceItem21'
    end

    return true, 'None'
end

shared_common_skill_enchant.is_valid_index = function(item, index)    
    local max_index = TryGetProp(item, 'EnchantSkillSlotCount', 0) 

    if index < 1 or index > max_index then
        return false
    end

    return true
end

shared_common_skill_enchant.get_cost = function(armor)
    local lv = TryGetProp(armor, 'UseLv', 0)

    if lv == 480 then
        local cost = {}
        cost['VakarineCertificate'] = 20000
        cost['common_skill_enchant_jewal_480'] = 1        
        return cost;
    elseif lv == 500 then
        local cost = {}
        cost['RadaCertificate'] = 20000
        cost['common_skill_enchant_jewal_480'] = 1        
        return cost;
    end

    return nil
end

-- from skill_name & lv

shared_common_skill_enchant.get_enchanted_skill = function(item,index)
    local skill_name   = TryGetProp(item,"EnchantSkillName_"..tostring(index),"None")
    local skill_lv     = TryGetProp(item,"EnchantSkillLevel_"..tostring(index),0)
    return skill_name,skill_lv
end

-- 스킬이름, 스킬레벨, 인덱스
shared_common_skill_enchant.get_canidate_skill = function(item)
    local str = TryGetProp(item,"CommonSkillStr","None")
    if str == "None" then return str end
    local str_table  = SCR_STRING_CUT(str,'/')
    if #str_table >= 2 then
        if #str_table == 2 then
            table.insert(str_table, '1')
        end
        return str_table[1],str_table[2], str_table[3]
    else
        return "None"
    end
end
