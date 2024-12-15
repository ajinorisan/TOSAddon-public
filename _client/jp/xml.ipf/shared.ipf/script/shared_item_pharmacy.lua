-- shared_item_pharmacy.lua

shared_item_pharmacy = {}
pharmacy_recipe_size_list = {19}
_max_pharmacy_reward_count = 4
_max_hurdle_count = 16
_max_hurdle_count_per_quadrant = 4

local _pharmacy_ui_parameter_list = nil
local function make_pharmacy_ui_parameter_list()
    if _pharmacy_ui_parameter_list ~= nil then
        return
    end

    _pharmacy_ui_parameter_list = {}
    
    _pharmacy_ui_parameter_list['grinder_cap_speed'] = 0.2
    _pharmacy_ui_parameter_list['grinder_handle_speed'] = 1
    _pharmacy_ui_parameter_list['extractor_valve_speed'] = 0.2
    _pharmacy_ui_parameter_list['extractor_fluid_speed'] = 3
end

make_pharmacy_ui_parameter_list()

local _pharmacy_neutralize_list = nil
local function make_pharmacy_neutralize_list()
    if _pharmacy_neutralize_list ~= nil then
        return
    end

    _pharmacy_neutralize_list = {}

    _pharmacy_neutralize_list['Grade1'] = {}
    table.insert(_pharmacy_neutralize_list['Grade1'], { Value = 1, Rate = 32 })
    table.insert(_pharmacy_neutralize_list['Grade1'], { Value = 2, Rate = 26 })
    table.insert(_pharmacy_neutralize_list['Grade1'], { Value = 3, Rate = 25 })
    table.insert(_pharmacy_neutralize_list['Grade1'], { Value = 4, Rate = 10 })
    table.insert(_pharmacy_neutralize_list['Grade1'], { Value = 5, Rate = 7 })

    _pharmacy_neutralize_list['Grade2'] = {}
    table.insert(_pharmacy_neutralize_list['Grade2'], { Value = 3, Rate = 20 })
    table.insert(_pharmacy_neutralize_list['Grade2'], { Value = 4, Rate = 33 })
    table.insert(_pharmacy_neutralize_list['Grade2'], { Value = 5, Rate = 28 })
    table.insert(_pharmacy_neutralize_list['Grade2'], { Value = 6, Rate = 15 })
    table.insert(_pharmacy_neutralize_list['Grade2'], { Value = 7, Rate = 4 })

    _pharmacy_neutralize_list['Grade3'] = {}
    table.insert(_pharmacy_neutralize_list['Grade3'], { Value = 7, Rate = 100 })
end

make_pharmacy_neutralize_list()

shared_item_pharmacy.get_random_size = function()
    local ran = IMCRandom(1, #pharmacy_recipe_size_list) 
    return pharmacy_recipe_size_list[ran]   
end

-- 중점
shared_item_pharmacy.get_center_pos = function(size)
    local axis = IMCRandom(1, 2)    
    local x = math.floor(size * 0.5)
    local y = math.floor(size * 0.5)    
    local ran = IMCRandom(math.floor(size * 0.25), math.floor(size * 0.76))
    if axis == 1 then
        x = ran
    else
        y = ran
    end

    return x, y
end

-- 도전가능 횟수
shared_item_pharmacy.get_random_try_count = function(size)
    local min = math.floor(size * 1.2)
    local max = math.floor(size * 1.7)
    local ran = IMCRandom(min, max)
    return ran
end

shared_item_pharmacy.get_goal_pos = function(size, quadrant, is_hurdle)
    local min_x, min_y, max_x, max_y

    if is_hurdle == false then
        if quadrant == 1 then
            min_x = math.floor(size * 0.5) + 1
            max_x = size - 2
            min_y = 1
            max_y = math.floor(size * 0.5) - 1
        elseif quadrant == 2 then
            min_x = 1
            max_x = math.floor(size * 0.5) - 1
            min_y = 1
            max_y = math.floor(size * 0.5) - 1
        elseif quadrant == 3 then
            min_x = 1
            max_x = math.floor(size * 0.5) - 1
            min_y = math.floor(size * 0.5) + 1
            max_y = size - 2
        else
            min_x = math.floor(size * 0.5) + 1
            max_x = size - 2
            min_y = math.floor(size * 0.5) + 1
            max_y = size - 2
        end
    else
        if quadrant == 1 then
            min_x = math.floor(size * 0.5) + 1
            max_x = size - 1
            min_y = 0
            max_y = math.floor(size * 0.5) - 1
        elseif quadrant == 2 then
            min_x = 0
            max_x = math.floor(size * 0.5) - 1
            min_y = 0
            max_y = math.floor(size * 0.5) - 1
        elseif quadrant == 3 then
            min_x = 0
            max_x = math.floor(size * 0.5) - 1
            min_y = math.floor(size * 0.5) + 1
            max_y = size - 1
        else
            min_x = math.floor(size * 0.5) + 1
            max_x = size - 1
            min_y = math.floor(size * 0.5) + 1
            max_y = size - 1
        end
    end
    
    return IMCRandom(min_x, max_x), IMCRandom(min_y, max_y)
end

-- count 만큼 분면을 결정한다.
shared_item_pharmacy.get_goal_pos_list = function(size, count)
    count = math.min(_max_pharmacy_reward_count, count)
    local ret_list = {}
    local hurdle_list = {}

    local quadrant_list = {1, 2, 3, 4}
    quadrant_list = shuffle(quadrant_list)
    
    for i = 1, count do
        local x , y = shared_item_pharmacy.get_goal_pos(size, quadrant_list[i], false)
        table.insert(ret_list, {x, y})
        for j = 1, _max_hurdle_count_per_quadrant do
            local x1 , y1 = shared_item_pharmacy.get_goal_pos(size, quadrant_list[i], true)            
            if math.abs(x - x1) > 1 or y ~= y1 then
                table.insert(hurdle_list, {x1, y1})
            end
        end
    end

    return ret_list, hurdle_list
end


-- 조제법 감정 비용
shared_item_pharmacy.get_reveal_cost = function(item)
    if TryGetProp(item, 'StringArg', 'None') ~= 'pharmacy_recipe' then
        return 'None', 0
    end

    if TryGetProp(item, 'ClassName', 'None') == 'pharmacy_recipe_Tuto' then
        return 'GabijaCertificate', 0
    end

    if TryGetProp(item, 'NumberArg1', 0) == 470 then
        local check = 0
        -- local event_2112_6th_pt2_startTime = '2022-03-15 00:00:00'
        -- local event_2112_6th_pt2_endTime = '2022-03-29 00:00:00'
    
        -- if date_time.is_between_time(event_2112_6th_pt2_startTime, event_2112_6th_pt2_endTime) == true then
        --     check = 1
        -- end

        if check == 0 then
            return 'GabijaCertificate', 3000
        else
            return 'GabijaCertificate', 2100
        end
    end

    return 'None', 0
end

shared_item_pharmacy.enable_move_to = function(recipe_item, mat_item)
    if recipe_item == nil or mat_item == nil then		
		return false
    end

    if TryGetProp(recipe_item, 'TeamBelonging', 0) ~= 1 then
        return false
    end
    
    local isTuto = 0
    if TryGetProp(recipe_item, 'ClassName', 'pharmacy_recipe_Tuto') == 'pharmacy_recipe_Tuto' then
        isTuto = 1
    end

    local expire_time = 'None'
    if isTuto == 0 then
        expire_time = TryGetProp(recipe_item, 'ExpireTime', 'None')
        if expire_time == 'None' then
            return false
        end
    end
    
    local direction_type = TryGetProp(mat_item, 'StringArg2', 'None')
    local mat_cls = GetClass('pharmacy_material_type', direction_type)
    if mat_cls == nil then
        return false
    end
    
    local poison_point = TryGetProp(mat_cls, 'PoisonPoint', 5)
    local cur_count, max_count = shared_item_pharmacy.get_current_try_count(recipe_item)
    if cur_count < poison_point then
        return false
    end

    if TryGetProp(recipe_item, 'StringArg', 'None') ~= 'pharmacy_recipe' then
        return false
    end

    if isTuto == 1 then
        if TryGetProp(mat_item, 'StringArg', 'None') ~= 'pharmacy_material_tutorial' then
            return false
        end
    else
        if TryGetProp(mat_item, 'StringArg', 'None') ~= 'pharmacy_material' then
            return false
        end
    end
    
    if TryGetProp(recipe_item, 'NumberArg1', 0) ~= TryGetProp(mat_item, 'NumberArg1', 1) then
        return false
    end
    
    if isTuto == 0 then
        local now_time = date_time.get_lua_now_datetime_str()
        if IsServerSection() == 0 then
            local server_time = geTime.GetServerSystemTime()
            now_time = date_time.lua_datetime_to_str(date_time.get_lua_datetime(server_time.wYear, server_time.wMonth, server_time.wDay, server_time.wHour, server_time.wMinute, server_time.wSecond))
        end
        if date_time.is_later_than(now_time, expire_time) == true then
            return false
        end
    end

    return true
end

-- true, false  -- 이동 성공
-- index    -- 목표 도달시 인덱스
-- current_pos(string) -- 이동 후 좌표
shared_item_pharmacy.move_to = function(recipe, mat)
    local size = TryGetProp(recipe, 'RecipeSize', 0)
    local max = size - 1
    local min = 0
    
    local current = TryGetProp(recipe, 'CurrentPos', 'None')
    local current_token = StringSplit(current, ',')
    local current_x = tonumber(current_token[1])
    local current_y = tonumber(current_token[2])

    local direction_type = TryGetProp(mat, 'StringArg2', 'None')
    local cls = GetClass('pharmacy_material_type', direction_type)
    if cls == nil then
        return false, nil, nil
    end

    local add_x = tonumber(TryGetProp(cls, 'X_POS', 0))
    local add_y = tonumber(TryGetProp(cls, 'Y_POS', 0))

    local start_x = current_x
    local start_y = current_y
    current_x = current_x + add_x
    current_y = current_y + add_y    
    if current_x > max or current_x < min then
        return false, nil, nil
    end

    if current_y > max or current_y < min then
        return false, nil, nil
    end

    local passed = shared_item_pharmacy.is_passing_hurdle(start_x, start_y, current_x, current_y, recipe)
    if passed == true then
        return false, nil, nil
    end

    local str_current = tostring(current_x) .. ',' .. tostring(current_y)
    local index = shared_item_pharmacy.get_reward_index(recipe, str_current)
    return true, index, str_current    
end

-- 보상을 받을 수 있는 최소 인덱스
shared_item_pharmacy.get_reward_index = function(recipe, str_current)
    if str_current == nil then
        str_current = TryGetProp(recipe, 'CurrentPos', 'None')
    end
    
    for i = 1, _max_pharmacy_reward_count do
        local reward = TryGetProp(recipe, 'GoalReward_' .. i, 0)
        if reward == 0 then
            local goal = TryGetProp(recipe, 'GoalPos_' .. i, 'None')
            if goal ~= 'None' then
                if goal == str_current then
                    return i
                end
            end
        end
    end

    return nil
end

-- 장애물에 걸리면 true
shared_item_pharmacy.is_passing_hurdle = function(start_x, start_y, end_x, end_y, recipe)
    for i = 1, _max_hurdle_count do
        local name = 'HurdlePos_' .. i
        local pos = TryGetProp(recipe, name, 'None')
        if pos ~= 'None' then
            local token = StringSplit(pos, ',')
            local x = tonumber(token[1])
            local y = tonumber(token[2])
            local ret = shared_item_pharmacy.check_passing_hurdle(start_x, start_y, end_x, end_y, x, y)
            if ret == true then
                return true
            end
        end
    end
    
    return false
end

shared_item_pharmacy.check_passing_hurdle = function(init_x, init_y, move_x, move_y, x, y)
    local start_x, end_x, start_y, end_y
    start_x = init_x
    end_x = move_x
    if start_x > end_x then
        end_x, start_x = start_x, end_x
    end
    
    if y == init_y and start_x <= x and x <= end_x then
        return true
    end

    start_y = init_y
    end_y = move_y
    
    if start_y > end_y then
        start_y, end_y = end_y, start_y
    end
    
    end_x = move_x
    
    if end_x == x and start_y <= y and y <= end_y then
        return true
    end

    return false
end

shared_item_pharmacy.get_active_recipe_name = function(item)
    if item == nil then
        return 'None'
    end

    local lv = TryGetProp(item, 'NumberArg1', 0)
    if lv < 470 then
        return 'None'
    end

    return 'pharmacy_recipe_active_' .. lv
end

-- 중화제 사용 가능 횟수
shared_item_pharmacy.get_random_neutralize_count = function(size)
    local max = math.max(1, math.floor(size / 4))
    local min = math.max(1, max - 3)
    return IMCRandom(min, max)
end

-- 독성 수치(cur/max)
shared_item_pharmacy.get_current_try_count = function(recipe)
    local try_count_str = TryGetProp(recipe, 'TryCount', 'None')
    if try_count_str == 'None' then
        return 0, 0
    end

    local try_count = StringSplit(try_count_str, '/')
    if #try_count ~= 2 then
        return 0, 0
    end

    return tonumber(try_count[1]), tonumber(try_count[2])
end

-- 중화제 횟수(cur/max)
shared_item_pharmacy.get_current_neutralize_count = function(recipe)
    local neutralize_count_str = TryGetProp(recipe, 'NeutralizeCount', 'None')
    if neutralize_count_str == 'None' then
        return 0, 0
    end

    local neutralize_count = StringSplit(neutralize_count_str, '/')
    if #neutralize_count ~= 2 then
        return 0, 0
    end

    return tonumber(neutralize_count[1]), tonumber(neutralize_count[2])
end

shared_item_pharmacy.usable_neutralizer = function(recipe, mat)
    if recipe == nil or mat == nil then
        return false
    end

    local recipe_lv = TryGetProp(recipe, 'NumberArg1', 0)
    local mat_lv = TryGetProp(mat, 'NumberArg1', 0)
    if recipe_lv > mat_lv then
        return false
    end

    return true
end

shared_item_pharmacy.get_neutralize_rate_list = function(type)
    return _pharmacy_neutralize_list[type]
end

shared_item_pharmacy.get_random_neutralize_value = function(mat)
    if mat == nil then
        return 0
    end

    local str_arg = TryGetProp(mat, 'StringArg', 'None')
    if str_arg ~= 'pharmacy_counteractive' and str_arg ~= 'pharmacy_counteractive_tutorial'then
        return 0
    end

    local mat_type = TryGetProp(mat, 'StringArg2', 'None')
    if GetClass('pharmacy_material_type', mat_type) == nil then
        return 0
    end

    local list = shared_item_pharmacy.get_neutralize_rate_list(mat_type)
    if list == nil then
        return 0
    end

    local value_list = {}
    local rate_list = {}
    for i = 1, #list do
        value_list[i] = list[i].Value
        if i == 1 then
            rate_list[i] = list[i].Rate
        else
            rate_list[i] = rate_list[i - 1] + list[i].Rate
        end
    end

    local ratio = IMCRandom(1, 100)
    for i = 1, #rate_list do
        if ratio <= rate_list[i] then
            return value_list[i]
        end
    end

    return 0
end

shared_item_pharmacy.get_cap_speed = function()
    return _pharmacy_ui_parameter_list['grinder_cap_speed']
end

shared_item_pharmacy.get_handle_speed = function()
    return _pharmacy_ui_parameter_list['grinder_handle_speed']
end

shared_item_pharmacy.get_valve_speed = function()
    return _pharmacy_ui_parameter_list['extractor_valve_speed']
end

shared_item_pharmacy.get_fluid_speed = function()
    return _pharmacy_ui_parameter_list['extractor_fluid_speed']
end

shared_item_pharmacy.get_remain_goal_count = function(recipe)
    if recipe == nil then
        return -1, -1
    end

    local max = 0
    local enable = 0
    for i = 1, _max_pharmacy_reward_count do
        if TryGetProp(recipe, 'GoalPos_' .. i, 'None') ~= 'None' then
            max = max + 1

            if TryGetProp(recipe, 'GoalReward_' .. i, 0) ~= 1 then
                enable = enable + 1
            end
        end
    end

    return enable, max
end

function GET_PHARMACY_RECIPE_REMAIN_SEC(recipe)
    local serverTime = geTime.GetServerSystemTime()
    local now = string.format("%04d-%02d-%02d %02d:%02d:%02d", serverTime.wYear, serverTime.wMonth, serverTime.wDay, serverTime.wHour, serverTime.wMinute, serverTime.wSecond)
    local end_time = TryGetProp(recipe, 'ExpireTime', 'None')
    if end_time == 'None' then
        return 0
    end

    if date_time.is_later_than(now, end_time) == true then
        return 0
    else
        local diff = date_time.get_diff_sec(end_time, now)
        return diff
    end
end


shared_item_pharmacy.move_to_test = function(recipe, type)
    local size = TryGetProp(recipe, 'RecipeSize', 0)
    local max = size - 1
    local min = 0
    
    local current = TryGetProp(recipe, 'CurrentPos', 'None')    
    local current_token = StringSplit(current, ',')
    local current_x = tonumber(current_token[1])
    local current_y = tonumber(current_token[2])
    local direction_type = type
    local cls = GetClass('pharmacy_material_type', direction_type)
    if cls == nil then
        return false, nil, nil
    end

    local add_x = tonumber(TryGetProp(cls, 'X_POS', 0))
    local add_y = tonumber(TryGetProp(cls, 'Y_POS', 0))
    
    current_x = current_x + add_x
    current_y = current_y + add_y    
    if current_x > max or current_x < min then
        return false, nil, nil
    end

    if current_y > max or current_y < min then
        return false, nil, nil
    end

    local str_current = tostring(current_x) .. ',' .. tostring(current_y)

    for i = 1, _max_pharmacy_reward_count do
        local reward = TryGetProp(recipe, 'GoalReward_' .. i, 0)
        if reward == 0 then
            local goal = TryGetProp(recipe, 'GoalPos_' .. i, 'None')
            if goal ~= 'None' then
                if goal == str_current then
                    return true, i, str_current
                end
            end
        end
    end

    return true, nil, str_current    
end
