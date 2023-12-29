-- shared_skill_enchant


shared_skill_enchant = {}
local max_slot_count = 2

local skill_list = nil
local function make_skill_list()
    skill_list = {}
    
    local list, cnt = GetClassList('enchant_skill_list')
    for i = 0, cnt - 1 do
        local cls = GetClassByIndexFromList(list, i);
        local tier = TryGetProp(cls, 'Tier', 0)
        if tier > 0 then
            local start_lv = 480
            local term = 20
            local name = TryGetProp(cls, 'ClassName', 'None')
            local ratio = TryGetProp(cls, 'Ratio', 100)

            for start_lv = 480, 600, term do
                local min = TryGetProp(cls, 'min_' .. start_lv, 0)
                local max = TryGetProp(cls, 'max_' .. start_lv, 0)
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

shared_skill_enchant.get_skill_list = function(lv)
    return skill_list[lv]    
end

shared_skill_enchant.get_max_slot_count = function()
    return max_slot_count
end

-- 스킬 연성이 가능한 아이템인가
shared_skill_enchant.is_valid_item = function(item)
    local max_rein = GET_MAX_REINFORCE_POINT(TryGetProp(item, 'UseLv', 0))

    if TryGetProp(item, 'EnchantSkillSlotCount', 0) <1 then
        return false, 'NotValidItem'
    end

    if TryGetProp(item, 'Reinforce_2', 0) ~= max_rein then
        return false, 'RequireMaxReinforceItem'
    end

    return true, 'None'
end

shared_skill_enchant.is_valid_index = function(item, index)    
    local max_index = TryGetProp(item, 'EnchantSkillSlotCount', 0) 

    if index < 1 or index > max_index then
        return false
    end

    return true
end

shared_skill_enchant.get_cost = function(scroll, name)
    local token = StringSplit(TryGetProp(scroll, 'StringArg2', 'None'), '/')
    local name = "None"
    if #token>0 then 
        name = token[1]
    end
    local lv = TryGetProp(scroll, 'UseLv', 0)
    if lv < 480 then
        lv = 480
    end

    local tier = 3
    
    local cls = GetClass('enchant_skill_list', name)
    if cls == nil then
        return nil
    end

    tier = TryGetProp(cls, 'Tier', 0)
    
    if lv == 480 then
        local cost = {}
        if tier == 3 then
            cost['VakarineCertificate'] = 300000
            cost['Premium_item_transcendence_Stone'] = 100
            cost['misc_ore23'] = 30000 
        elseif tier == 2 then
            cost['VakarineCertificate'] = 500000
            cost['Premium_item_transcendence_Stone'] = 200
            cost['misc_ore23'] = 50000 
        else
            cost['VakarineCertificate'] = 900000
            cost['Premium_item_transcendence_Stone'] = 400
            cost['misc_ore23'] = 90000
        end
        return cost;
    end

    return nil
end

-- from skill_name & lv
shared_skill_enchant.get_item_name = function(name, lv)
    return 'common_skill_scroll_' .. name .. '_' .. lv
end

shared_skill_enchant.get_enchanted_skill = function(item,index)
    local skill_name   = TryGetProp(item,"EnchantSkillName_"..tostring(index),"None")
    local skill_lv     = TryGetProp(item,"EnchantSkillLevel_"..tostring(index),0)
    return skill_name,skill_lv
end

-- from goddess Equip
shared_skill_enchant.get_enchanted_scroll_name= function(item,index)
    local skill_name, skill_lv = shared_skill_enchant.get_enchanted_skill(item,index)
    if skill_name~="None" and skill_lv >0 then
        local format =  string.format("common_skill_scroll_%s_%s", skill_name, skill_lv)
        return format
    else
        return "None" 
    end
end

shared_skill_enchant.is_common_skill_scroll = function(item)
    local strArg = TryGetProp(item,"StringArg","None")
    if "common_skill_scroll" == strArg then
        return true
    else
        return false
    end
end
