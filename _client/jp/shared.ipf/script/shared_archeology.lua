-- shared_archeology.lua

shared_archeology = {}
local _archeology_map_list = nil
local _archeology_reward_list = nil  -- { lv : list }
max_archeology_map_count = 3
max_archeology_point = 3
local _max_archeology_try_count = 70

local function make_archeology_map_list()
    if _archeology_map_list ~= nil then
        return
    end

    _archeology_map_list = {}
    _archeology_reward_list = {}


    local clsList, cnt = GetClassList('archeology_map_list');
    for i = 0, cnt - 1 do
        local cls = GetClassByIndexFromList(clsList, i);
        if cls ~= nil then
            local name = TryGetProp(cls, 'ClassName', 'None')
            if name ~= 'None' then
                table.insert(_archeology_map_list, name)         
            end
        end
    end

    clsList, cnt = GetClassList('archeology_reward_list');
    for i = 0, cnt - 1 do
        local cls = GetClassByIndexFromList(clsList, i);
        if cls ~= nil then
            local class_name = TryGetProp(cls, 'ClassName', 'None')
            if class_name ~= 'None' then
                local lv = TryGetProp(cls, 'Lv', 470)
                if _archeology_reward_list[lv] == nil then
                    _archeology_reward_list[lv] = {}
                end
                table.insert(_archeology_reward_list[lv], class_name)
            end
        end
    end
end

make_archeology_map_list()

shared_archeology.get_archeology_map_list = function()
    return _archeology_map_list
end
shared_archeology.get_max_archeology_try_count = function()
    return _max_archeology_try_count
end
-- 임무 비용
shared_archeology.get_cost = function(lv)
    if lv == 470 then
        return 'Vibora_misc_Lv2', 5
    end

    return nil
end
shared_archeology.get_reward_list = function(lv)
    return _archeology_reward_list[lv]
end

