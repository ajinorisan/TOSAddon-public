-- shared_item_goddess_icor

shared_item_goddess_icor = {}
local item_goddess_icor_range = nil

local random_option_group_name = nil
local max_option_count = 4
local option_list_by_group = nil  -- ATK, DEF, STAT, UTIL_ARMOR 에 속한 옵션 리스트들

function make_icor_option_range(item_goddess_icor_range, set_list, lv, type, max, low, high)
    if lv <= 520 then
    for k, v in pairs(set_list) do
        item_goddess_icor_range[lv][type][v] = {}
        item_goddess_icor_range[lv][type][v]['LOW'] = {math.floor(max * low), max}
        item_goddess_icor_range[lv][type][v]['HIGH'] = {math.floor(max), math.floor(max * high)}
        if lv >= 520 and type == 'Armor' then
            -- print(ClMsg(v), item_goddess_icor_range[lv][type][v]['LOW'][1], item_goddess_icor_range[lv][type][v]['LOW'][2])
        --     print(ClMsg(v), item_goddess_icor_range[lv][type][v]['HIGH'][1], item_goddess_icor_range[lv][type][v]['HIGH'][2])
    end
end
    else        
        for k, v in pairs(set_list) do            
            item_goddess_icor_range[lv][type][v] = {}
            item_goddess_icor_range[lv][type][v]['LOW'] = {math.floor((max * low) + 0.5), math.floor(max)}
            item_goddess_icor_range[lv][type][v]['HIGH'] = {math.floor((max * high) + 0.5), math.floor(max)}
            
            if type == 'Weapon' then
                -- print(k, v, lv, type, item_goddess_icor_range[lv][type][v]['LOW'][1], item_goddess_icor_range[lv][type][v]['LOW'][2], item_goddess_icor_range[lv][type][v]['HIGH'][1], item_goddess_icor_range[lv][type][v]['HIGH'][2])
                -- print(ClMsg(v), item_goddess_icor_range[lv][type][v]['LOW'][1], item_goddess_icor_range[lv][type][v]['LOW'][2])
                -- print(ClMsg(v), item_goddess_icor_range[lv][type][v]['HIGH'][1], item_goddess_icor_range[lv][type][v]['HIGH'][2])
            end
        end

    end
    end

function set_item_goddess_icor_range_480(item_goddess_icor_range)
    local max
    local min
    item_goddess_icor_range[480] = {}
    item_goddess_icor_range[480]['Armor'] = {}    

    -- ATK
    max = 963
    local set_list = {'AllMaterialType_Atk', 'AllRace_Atk'}
    make_icor_option_range(item_goddess_icor_range, set_list, 480, 'Armor', max, 0.8, 1.2)
    
    max = 1132
    set_list = {'ADD_CLOTH', 'ADD_LEATHER', 'ADD_IRON', 'ADD_SMALLSIZE', 'ADD_MIDDLESIZE', 'ADD_LARGESIZE', 'ADD_GHOST', 'ADD_FORESTER', 'ADD_WIDLING', 'ADD_VELIAS', 'ADD_PARAMUNE', 'ADD_KLAIDA'}
    make_icor_option_range(item_goddess_icor_range, set_list, 480, 'Armor', max, 0.8, 1.2)

    max = 1413
    set_list = {'Add_Damage_Atk'}
    make_icor_option_range(item_goddess_icor_range, set_list, 480, 'Armor', max, 0.8, 1.2)    
    -- end of ATK

    -- STAT
    max = 169
    set_list = {'STR', 'DEX', 'CON', 'INT', 'MNA'}
    make_icor_option_range(item_goddess_icor_range, set_list, 480, 'Armor', max, 0.8, 1.2)    
    -- end of STAT

    -- UTIL_ARMOR
    max = 565
    set_list = {'CRTHR', 'BLK_BREAK', 'BLK', 'ADD_HR', 'ADD_DR', 'CRTDR', 'RHP'}
    make_icor_option_range(item_goddess_icor_range, set_list, 480, 'Armor', max, 0.8, 1.2)    
    -- end of UTIL_ARMOR

    -- DEF
    max = 1413
    set_list = {'ResAdd_Damage'}
    make_icor_option_range(item_goddess_icor_range, set_list, 480, 'Armor', max, 0.8, 1.2)    

    max = 1132
    set_list = {'Cloth_Def', 'Leather_Def', 'Iron_Def', 'MiddleSize_Def'}
    make_icor_option_range(item_goddess_icor_range, set_list, 480, 'Armor', max, 0.8, 1.2)    
        
    local min = 80
    max = 100
    set_list = {'stun_res', 'high_fire_res', 'high_freezing_res', 'high_lighting_res', 'high_poison_res', 'high_laceration_res'}
    for k, v in pairs(set_list) do
        item_goddess_icor_range[480]['Armor'][v] = {}
        item_goddess_icor_range[480]['Armor'][v]['LOW'] = {min, max}
        item_goddess_icor_range[480]['Armor'][v]['HIGH'] = {math.floor(max), math.floor(max * 1.3)}
    end    

    min = 15000
    max = 20000
    set_list = {'portion_expansion'}
    for k, v in pairs(set_list) do
        item_goddess_icor_range[480]['Armor'][v] = {}
        item_goddess_icor_range[480]['Armor'][v]['LOW'] = {min, max}
        item_goddess_icor_range[480]['Armor'][v]['HIGH'] = {math.floor(max), math.floor(max * 1.5)}
    end    
    -- end of DEF

    item_goddess_icor_range[480]['Weapon'] = {}
    -- ATK
    max = 1201
    set_list = {'AllMaterialType_Atk', 'AllRace_Atk'}
    make_icor_option_range(item_goddess_icor_range, set_list, 480, 'Weapon', max, 0.8, 1.5)        
    
    max = 2121
    set_list = {'Add_Damage_Atk'}
    make_icor_option_range(item_goddess_icor_range, set_list, 480, 'Weapon', max, 0.8, 1.2)
    
    max = 2000
    set_list = {'perfection'}
    make_icor_option_range(item_goddess_icor_range, set_list, 480, 'Weapon', max, 0.8, 1.2)
    
    max = 10000
    set_list = {'revenge'}
    make_icor_option_range(item_goddess_icor_range, set_list, 480, 'Weapon', max, 0.8, 1.2)

    max = 1413    
    set_list = {'ADD_CLOTH', 'ADD_LEATHER', 'ADD_IRON', 'ADD_SMALLSIZE', 'ADD_MIDDLESIZE', 'ADD_LARGESIZE', 'ADD_GHOST', 'ADD_FORESTER', 'ADD_WIDLING', 'ADD_VELIAS', 'ADD_PARAMUNE', 'ADD_KLAIDA'}
    make_icor_option_range(item_goddess_icor_range, set_list, 480, 'Weapon', max, 0.8, 1.2)    
    -- end of ATK

    -- STAT
    max = 212
    set_list = {'STR', 'DEX', 'CON', 'INT', 'MNA'}
    make_icor_option_range(item_goddess_icor_range, set_list, 480, 'Weapon', max, 0.8, 1.2)    
    -- end of STAT

    -- UTIL_ARMOR
    max = 707
    set_list = {'CRTHR', 'BLK_BREAK', 'BLK', 'ADD_HR', 'ADD_DR', 'CRTDR', 'RHP'}
    make_icor_option_range(item_goddess_icor_range, set_list, 480, 'Weapon', max, 0.8, 1.2)    
    -- end of UTIL_ARMOR

    -- DEF
    max = 2121
    set_list = {'ResAdd_Damage'}
    make_icor_option_range(item_goddess_icor_range, set_list, 480, 'Weapon', max, 0.8, 1.2)

    max = 1413
    set_list = {'Cloth_Def', 'Leather_Def', 'Iron_Def', 'MiddleSize_Def'}
    make_icor_option_range(item_goddess_icor_range, set_list, 480, 'Weapon', max, 0.8, 1.2)    
    -- end of DEF
end

function set_item_goddess_icor_range_by_level(i, level, item_goddess_icor_range)
        item_goddess_icor_range[level] = {}
        item_goddess_icor_range[level]['Armor'] = {}    
    -- ATK    
    local max = 1251 -- 1.3배
    local min
        if i > 1 then
            max = math.floor(max * 1.3^(i-1))            
        end        
    
    local set_list = {'AllMaterialType_Atk', 'AllRace_Atk'}
    if level <= 520 then
        make_icor_option_range(item_goddess_icor_range, set_list, level, 'Armor', max, 0.8, 1.2)
    elseif level == 540 then
        max = 2536
        make_icor_option_range(item_goddess_icor_range, set_list, level, 'Armor', max, 0.55, 0.9)
    end
    
    
    max = 1471
        if i > 1 then
            max = math.floor(max * 1.3^(i-1))            
        end        
    set_list = {'ADD_CLOTH', 'ADD_LEATHER', 'ADD_IRON', 'ADD_SMALLSIZE', 'ADD_MIDDLESIZE', 'ADD_LARGESIZE', 'ADD_GHOST', 'ADD_FORESTER', 'ADD_WIDLING', 'ADD_VELIAS', 'ADD_PARAMUNE', 'ADD_KLAIDA', 
                'Cloth_Def', 'Leather_Def', 'Iron_Def', 'MiddleSize_Def'}
    if level <= 520 then
        make_icor_option_range(item_goddess_icor_range, set_list, level, 'Armor', max, 0.8, 1.2)
    elseif level == 540 then
        max = 2982
        make_icor_option_range(item_goddess_icor_range, set_list, level, 'Armor', max, 0.55, 0.9)
    end
    

    max = 1836
        if i > 1 then
            max = math.floor(max * 1.3^(i-1))            
        end        
    set_list = {'Add_Damage_Atk', 'ResAdd_Damage'}
    if level <= 520 then
        make_icor_option_range(item_goddess_icor_range, set_list, level, 'Armor', max, 0.8, 1.2)    
    elseif level == 540 then
        max = 3722
        make_icor_option_range(item_goddess_icor_range, set_list, level, 'Armor', max, 0.55, 0.9)
    end
    

    -- end of ATK

    -- STAT
    max = 219
        if i > 1 then
            max = math.floor(max * 1.3^(i-1))            
        end        
    set_list = {'STR', 'DEX', 'CON', 'INT', 'MNA'}
    if level <= 520 then
        make_icor_option_range(item_goddess_icor_range, set_list, level, 'Armor', max, 0.8, 1.2)    
    elseif level == 540 then
        max = 442
        make_icor_option_range(item_goddess_icor_range, set_list, level, 'Armor', max, 0.55, 0.9)
    end
    -- end of STAT

    -- UTIL_ARMOR
    max = 734  -- (4부위 3523)
        if i > 1 then
            max = math.floor(max * 1.3^(i-1))            
        end        
    set_list = {'CRTHR', 'BLK_BREAK', 'BLK', 'ADD_HR', 'ADD_DR', 'CRTDR', 'RHP'}
    if level <= 520 then
        make_icor_option_range(item_goddess_icor_range, set_list, level, 'Armor', max, 0.8, 1.2)    
    elseif level == 540 then
        max = 1487
        make_icor_option_range(item_goddess_icor_range, set_list, level, 'Armor', max, 0.55, 0.9)
    end
    -- end of UTIL_ARMOR

    -- DEF
        
        min = 130  -- 10레벨당 요구량 복리 33% 증가, function GET_MAX_REG_VALUE(lv)
    max = 170
        if i > 1 then
            min = math.floor(min * 1.77^(i-1))
            max = math.floor(max * 1.77^(i-1))
        end

    set_list = {'stun_res', 'high_fire_res', 'high_freezing_res', 'high_lighting_res', 'high_poison_res', 'high_laceration_res'}

    if level <= 520 then
    for k, v in pairs(set_list) do
            item_goddess_icor_range[level]['Armor'][v] = {}
            item_goddess_icor_range[level]['Armor'][v]['LOW'] = {min, max}
            item_goddess_icor_range[level]['Armor'][v]['HIGH'] = {math.floor(max), math.floor(max * 1.3)}
        if level == 520 then
            -- print(ClMsg(v), item_goddess_icor_range[level]['Armor'][v]['LOW'][1], item_goddess_icor_range[level]['Armor'][v]['LOW'][2])
            -- print(ClMsg(v), item_goddess_icor_range[level]['Armor'][v]['HIGH'][1], item_goddess_icor_range[level]['Armor'][v]['HIGH'][2])
        end
    end    
    elseif level == 540 then        
        make_icor_option_range(item_goddess_icor_range, set_list, level, 'Armor', max, 0.55, 0.9)
    end

    min = 20000
    max = 30000
        if i > 1 then
            min = math.floor(min * 1.33^(i-1))
            max = math.floor(max * 1.33^(i-1))
        end

    set_list = {'portion_expansion'}

    if level <= 520 then
    for k, v in pairs(set_list) do
            item_goddess_icor_range[level]['Armor'][v] = {}
            item_goddess_icor_range[level]['Armor'][v]['LOW'] = {min, max}
            item_goddess_icor_range[level]['Armor'][v]['HIGH'] = {math.floor(max), math.floor(max * 1.5)}
        if level == 520 then
            -- print(ClMsg(v), item_goddess_icor_range[level]['Armor'][v]['LOW'][1], item_goddess_icor_range[level]['Armor'][v]['LOW'][2])
            -- print(ClMsg(v), item_goddess_icor_range[level]['Armor'][v]['HIGH'][1], item_goddess_icor_range[level]['Armor'][v]['HIGH'][2])
        end
    end    
    elseif level == 540 then        
        max = 77805
        make_icor_option_range(item_goddess_icor_range, set_list, level, 'Armor', max, 0.55, 0.9)
    end
    -- end of DEF

        item_goddess_icor_range[level]['Weapon'] = {}
    -- ATK
    max = 1561
        local max_ratio = 1.5
        if i > 1 then
            max = math.floor(max * 1.3^(i-1))
            max_ratio = 1.2
        end        
    set_list = {'AllMaterialType_Atk', 'AllRace_Atk'}
    if level <= 520 then
        make_icor_option_range(item_goddess_icor_range, set_list, level, 'Weapon', max, 0.8, max_ratio)
    elseif level == 540 then
        max = 3164
        make_icor_option_range(item_goddess_icor_range, set_list, level, 'Weapon', max, 0.55, 0.9)
    end
    
    max = 2757
        if i > 1 then
            max = math.floor(max * 1.3^(i-1))
        end        
    set_list = {'Add_Damage_Atk', 'ResAdd_Damage'}
    if level <= 520 then
        make_icor_option_range(item_goddess_icor_range, set_list, level, 'Weapon', max, 0.8, max_ratio)
    elseif level == 540 then
        max = 5590
        make_icor_option_range(item_goddess_icor_range, set_list, level, 'Weapon', max, 0.55, 0.9)
    end
    
    max = 4000
        if i > 1 then
            max = math.floor(max * 1.5^(i-1))
        end        
    set_list = {'perfection'}
    if level <= 520 then
        make_icor_option_range(item_goddess_icor_range, set_list, level, 'Weapon', max, 0.8, 1.2)
    elseif level == 540 then
        max = 9360
        make_icor_option_range(item_goddess_icor_range, set_list, level, 'Weapon', max, 0.55, 0.9)
    end
    
    max = 30000
        if i > 1 then
            max = math.floor(max * 1.5^(i-1))
        end        
    set_list = {'revenge'}
    if level <= 520 then
        make_icor_option_range(item_goddess_icor_range, set_list, level, 'Weapon', max, 0.8, 1.2)
    elseif level == 540 then
        max = 60000
        make_icor_option_range(item_goddess_icor_range, set_list, level, 'Weapon', max, 0.55, 0.9)
    end

    max = 1836    
        if i > 1 then
            max = math.floor(max * 1.3^(i-1))
        end           
    set_list = {'ADD_CLOTH', 'ADD_LEATHER', 'ADD_IRON', 'ADD_SMALLSIZE', 'ADD_MIDDLESIZE', 'ADD_LARGESIZE', 'ADD_GHOST', 'ADD_FORESTER', 'ADD_WIDLING', 'ADD_VELIAS', 'ADD_PARAMUNE', 'ADD_KLAIDA',
            'Cloth_Def', 'Leather_Def', 'Iron_Def', 'MiddleSize_Def'}
    if level <= 520 then
        make_icor_option_range(item_goddess_icor_range, set_list, level, 'Weapon', max, 0.8, 1.2)    
    elseif level == 540 then
        max = 3722
        make_icor_option_range(item_goddess_icor_range, set_list, level, 'Weapon', max, 0.55, 0.9)
    end
    -- end of ATK

    -- STAT
    max = 275
        if i > 1 then
            max = math.floor(max * 1.3^(i-1))
        end        
    set_list = {'STR', 'DEX', 'CON', 'INT', 'MNA'}
    if level <= 520 then
        make_icor_option_range(item_goddess_icor_range, set_list, level, 'Weapon', max, 0.8, 1.2)    
    elseif level == 540 then
        max = 556
        make_icor_option_range(item_goddess_icor_range, set_list, level, 'Weapon', max, 0.55, 0.9)
    end
    -- end of STAT

    -- UTIL_ARMOR
    max = 919 -- 4부위(4400)
        if i > 1 then
            max = math.floor(max * 1.3^(i-1))
        end        
    set_list = {'CRTHR', 'BLK_BREAK', 'BLK', 'ADD_HR', 'ADD_DR', 'CRTDR', 'RHP'}
    if level <= 520 then
        make_icor_option_range(item_goddess_icor_range, set_list, level, 'Weapon', max, 0.8, 1.2)    
    elseif level == 540 then
        max = 1862
        make_icor_option_range(item_goddess_icor_range, set_list, level, 'Weapon', max, 0.55, 0.9)
    end
    -- end of UTIL_ARMOR
end

function make_item_goddess_icor_range()
    if item_goddess_icor_range ~= nil then
        return
    end

    -- local cls_list, cnt = GetClassList('goddess_special_option')

    item_goddess_icor_range = {}
    option_list_by_group = {}

    random_option_group_name = {}    
    
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
    random_option_group_name['RHP'] = 'UTIL_ARMOR'          -- HP 회복력
    
    random_option_group_name['ResAdd_Damage'] = 'DEF'       -- 추가 대미지 저항    
    random_option_group_name['Cloth_Def'] = 'DEF'
    random_option_group_name['Leather_Def'] = 'DEF'
    random_option_group_name['Iron_Def'] = 'DEF'
    random_option_group_name['MiddleSize_Def'] = 'DEF'

        
    local cls_list, cnt = GetClassList('goddess_atk_def_option')
    for i = 0, cnt - 1 do
        local cls = GetClassByIndexFromList(cls_list, i)
        local _name = TryGetProp(cls, 'ClassName', 'None')
        local type = TryGetProp(cls, 'Type', 'None')
        if type ~= 'None' then
            random_option_group_name[_name] = type
        end
    end
    
    option_list_by_group[480] = {}
    option_list_by_group[480]['Armor'] = {}
    option_list_by_group[480]['Armor']['ATK'] = {'AllRace_Atk', 'Add_Damage_Atk', 'AllMaterialType_Atk', 
    'ADD_CLOTH', 'ADD_LEATHER', 'ADD_IRON', 
    'ADD_SMALLSIZE', 'ADD_MIDDLESIZE', 'ADD_LARGESIZE', 'ADD_GHOST', 
    'ADD_FORESTER', 'ADD_WIDLING', 'ADD_VELIAS', 'ADD_PARAMUNE', 'ADD_KLAIDA'
    }

    option_list_by_group[480]['Armor']['STAT'] = {'STR', 'DEX', 'CON', 'INT', 'MNA'}
    option_list_by_group[480]['Armor']['UTIL_ARMOR'] = {'CRTHR', 'BLK_BREAK', 'BLK', 'ADD_HR', 'ADD_DR', 'CRTDR', 'RHP'}
    option_list_by_group[480]['Armor']['DEF'] = {'ResAdd_Damage', 'stun_res', 'high_fire_res', 'high_freezing_res', 'high_lighting_res', 'high_poison_res', 'high_laceration_res', 'portion_expansion', 
    'Cloth_Def', 'Leather_Def', 'Iron_Def', 'MiddleSize_Def'
    }

    option_list_by_group[480]['Weapon'] = {}
    option_list_by_group[480]['Weapon']['ATK'] = {'AllRace_Atk', 'Add_Damage_Atk', 'AllMaterialType_Atk', 'perfection', 'revenge',
    'ADD_CLOTH', 'ADD_LEATHER', 'ADD_IRON', 
    'ADD_SMALLSIZE', 'ADD_MIDDLESIZE', 'ADD_LARGESIZE', 'ADD_GHOST', 
    'ADD_FORESTER', 'ADD_WIDLING', 'ADD_VELIAS', 'ADD_PARAMUNE', 'ADD_KLAIDA'
    }
    option_list_by_group[480]['Weapon']['STAT'] = {'STR', 'DEX', 'CON', 'INT', 'MNA'}
    option_list_by_group[480]['Weapon']['UTIL_ARMOR'] = {'CRTHR', 'BLK_BREAK', 'BLK', 'ADD_HR', 'ADD_DR', 'CRTDR', 'RHP'}
    option_list_by_group[480]['Weapon']['DEF'] = {'ResAdd_Damage', 
    'Cloth_Def', 'Leather_Def', 'Iron_Def', 'MiddleSize_Def'
    }

    local level_list = {500, 520, 540}

    for i = 1, #level_list do
        local level = level_list[i]
        option_list_by_group[level] = {}
        option_list_by_group[level]['Armor'] = {}
        option_list_by_group[level]['Armor']['ATK'] = {'AllRace_Atk', 'Add_Damage_Atk', 'AllMaterialType_Atk', 
        'ADD_CLOTH', 'ADD_LEATHER', 'ADD_IRON', 
        'ADD_SMALLSIZE', 'ADD_MIDDLESIZE', 'ADD_LARGESIZE', 'ADD_GHOST', 
        'ADD_FORESTER', 'ADD_WIDLING', 'ADD_VELIAS', 'ADD_PARAMUNE', 'ADD_KLAIDA'
        }
    
        option_list_by_group[level]['Armor']['STAT'] = {'STR', 'DEX', 'CON', 'INT', 'MNA'}
        option_list_by_group[level]['Armor']['UTIL_ARMOR'] = {'CRTHR', 'BLK_BREAK', 'BLK', 'ADD_HR', 'ADD_DR', 'CRTDR', 'RHP'}
        option_list_by_group[level]['Armor']['DEF'] = {'ResAdd_Damage', 'stun_res', 'high_fire_res', 'high_freezing_res', 'high_lighting_res', 'high_poison_res', 'high_laceration_res', 'portion_expansion', 
        'Cloth_Def', 'Leather_Def', 'Iron_Def', 'MiddleSize_Def'
        }
    
        option_list_by_group[level]['Weapon'] = {}
        option_list_by_group[level]['Weapon']['ATK'] = {'AllRace_Atk', 'Add_Damage_Atk', 'AllMaterialType_Atk', 'perfection', 'revenge',
        'ADD_CLOTH', 'ADD_LEATHER', 'ADD_IRON', 
        'ADD_SMALLSIZE', 'ADD_MIDDLESIZE', 'ADD_LARGESIZE', 'ADD_GHOST', 
        'ADD_FORESTER', 'ADD_WIDLING', 'ADD_VELIAS', 'ADD_PARAMUNE', 'ADD_KLAIDA'
        }
        option_list_by_group[level]['Weapon']['STAT'] = {'STR', 'DEX', 'CON', 'INT', 'MNA'}
        option_list_by_group[level]['Weapon']['UTIL_ARMOR'] = {'CRTHR', 'BLK_BREAK', 'BLK', 'ADD_HR', 'ADD_DR', 'CRTDR', 'RHP'}
        option_list_by_group[level]['Weapon']['DEF'] = {'ResAdd_Damage', 
        'Cloth_Def', 'Leather_Def', 'Iron_Def', 'MiddleSize_Def'
        }    
    end
    
    -- for group, v in pairs(option_list_by_group[520]['Weapon']) do        
    --     for k1, v1 in pairs(v) do
    --         print(group, v1)
    --     end
    -- end

    local max
    set_item_goddess_icor_range_480(item_goddess_icor_range)

    ---------------------------------------------------- 500~ 레벨 시작  ----------------------------------------    
    for i = 1, #level_list do
        local level = level_list[i]
        set_item_goddess_icor_range_by_level(i, level, item_goddess_icor_range)        
    end

end

make_item_goddess_icor_range()

-- ATK, DEF, UTIL_ARMOR, STAT 등으로 해당 그룹에 속한 옵션들을 반환한다.
-- spot {Armor, Weapon}
shared_item_goddess_icor.get_option_list_by_group = function(level, spot, option_group)
    return option_list_by_group[level][spot][option_group]
end

-- 아이커에 옵션을 부여할 때, 상급/하급 구분해서 옵션다시 재 설정
shared_item_goddess_icor.get_option_value_range_icor = function(item, option_name, is_client)
    if is_client == nil then
        is_client = false
    end
    if shared_item_goddess_icor.get_goddess_icor_grade(item) == 0 then
        return 0, 0
    end
    
    local is_item = TryGetProp(item, 'GroupName', 'None') ~= 'Icor'
    local spot = TryGetProp(item, 'StringArg2', 'None')

    if is_item then
        local _spot = TryGetProp(item, 'GroupName', 'None')
        if _spot == 'Armor' then
            spot = 'Armor'
        elseif string.find(_spot, 'Weapon') ~= nil then
            spot = 'Weapon'
        end

        if TryGetProp(item, 'ClassType', 'None') == 'Shield' then
            spot = 'Weapon'
        end

        local icor_name = TryGetProp(item, 'GoddessIcorName', 'None')
        if icor_name ~= 'None' then
            if is_client == true then                
                local icor_name_cls = GetClass('Item', icor_name)
                local str3 = TryGetProp(icor_name_cls, 'StringArg3', 'None')
                if str3 ~= 'None' then        
                    local token = StringSplit(str3, '/')
                    if token[1] ~= 'Inheritance' then
                        item = GetClass('Item', icor_name)    
                    end
                else
                    item = GetClass('Item', icor_name)    
                end
            else
                item = GetClass('Item', icor_name)
            end
        end
    end

    if spot == 'None' then  -- Weapon, Armor
        return 0, 0
    end

    local lv = TryGetProp(item, 'UseLv', 0)
    local grade = 'LOW'
    if TryGetProp(item, 'NumberArg1', 0) > 10 then
        grade = 'HIGH'
    end
    if item_goddess_icor_range == nil or item_goddess_icor_range[lv] == nil then
        return 0, 0
    end

    if item_goddess_icor_range[lv][spot] == nil then
        return 0, 0
    end

    if item_goddess_icor_range[lv][spot][option_name] == nil then
        return 0, 0
    end

    if item_goddess_icor_range[lv][spot][option_name][grade] == nil then
        return 0, 0
    end

    return item_goddess_icor_range[lv][spot][option_name][grade][1], item_goddess_icor_range[lv][spot][option_name][grade][2]
end

shared_item_goddess_icor.get_option_group_name = function(option_name)
    if random_option_group_name[option_name] == nil then
        return 'None'
    end
    return random_option_group_name[option_name]
end

-- 최대로 붙을 수 있는 랜덤 옵션 수
shared_item_goddess_icor.get_max_option_count = function()
    return max_option_count
end

shared_item_goddess_icor.get_random_option_list = function(item, is_shuffle)
    if is_shuffle == nil then
        is_shuffle = true
    end
    local lv = TryGetProp(item, 'UseLv', 0)
    local spot = TryGetProp(item, 'StringArg2', 'None')

    local list = {}

    for k, v in pairs(option_list_by_group[lv][spot]) do        
        for k1, v1 in pairs(option_list_by_group[lv][spot][k]) do
            table.insert(list, v1)            
        end        
    end
    
    if is_shuffle == true then
        list = shuffle2(list)    
    end
    
    return list
end

shared_item_goddess_icor.is_able_to_reroll = function(item, index)
    if shared_item_goddess_icor.get_goddess_icor_grade(item) == 0 then
        return false, 'CantRerollEquipment'
    end

    local name = TryGetProp(item, 'RandomOption_' .. index, 'None')
    if GetClass('goddess_set_option', name) ~= nil then
        return false, 'CantRerollIndex'
    end

    if name == 'None' then
        return false, 'NotExistRandomOption'
    end

    local reroll_index = TryGetProp(iten, 'RerollIndex', 0)
    if reroll_index ~= 0 and reroll_index ~= index then
        return false, 'DifferentRerollIndex'
    end

    return true
end

shared_item_goddess_icor.get_cost = function(lv, count, grade, cost_list)
    if lv == 480 then
        if grade == 'LOW' then
            local cost_count = 1 + math.floor(count / 5)
            cost_list['misc_BlessedStone'] = math.floor(cost_count)

            cost_count = 300 * math.pow(1.04, count)
            cost_list['VakarineCertificate'] = math.floor(cost_count)

            cost_count = 100 * math.pow(1.04, count)
            cost_list['misc_ore22'] = math.floor(cost_count)

            cost_count = 25 * math.pow(1.04, count)
            cost_list['misc_ore23'] = math.floor(cost_count)
            
            return true
        else    
            local cost_count = 1 + math.floor(count / 3)
            cost_count = cost_count * 1.5
            cost_list['misc_BlessedStone'] = math.floor(cost_count)

            cost_count = 300 * math.pow(1.04, count)
            cost_count = cost_count * 1.3
            cost_list['VakarineCertificate'] = math.floor(cost_count)

            cost_count = 100 * math.pow(1.04, count)
            cost_count = cost_count * 1.5
            cost_list['misc_ore22'] = math.floor(cost_count) -- 뉴클

            cost_count = 25 * math.pow(1.04, count)
            cost_count = cost_count * 1.5
            cost_list['misc_ore23'] = math.floor(cost_count)
            return true
        end
    elseif lv == 500 then
        if grade == 'LOW' then
            local cost_count = 1 + math.floor(count / 5)
            cost_list['misc_BlessedStone_1'] = math.floor(cost_count)

            cost_count = 300 * math.pow(1.04, count)
            cost_list['RadaCertificate'] = math.floor(cost_count)

            cost_count = 100 * math.pow(1.04, count)
            cost_list['misc_ore28'] = math.floor(cost_count)
            
            return true
        else    
            local cost_count = 1 + math.floor(count / 3)
            cost_count = cost_count * 1.5
            cost_list['misc_BlessedStone_1'] = math.floor(cost_count)

            cost_count = 300 * math.pow(1.04, count)
            cost_count = cost_count * 1.3
            cost_list['RadaCertificate'] = math.floor(cost_count)

            cost_count = 100 * math.pow(1.04, count)
            cost_count = cost_count * 1.5
            cost_list['misc_ore28'] = math.floor(cost_count) -- 
            return true
        end
    elseif lv == 520 then
        if grade == 'LOW' then
            local cost_count = 1 + math.floor(count / 4)
            cost_list['misc_BlessedStone_1'] = math.floor(cost_count)

            cost_count = 300 * math.pow(1.04, count)
            cost_list['JurateCertificate'] = math.floor(cost_count)

            cost_count = 100 * math.pow(1.05, count)
            cost_list['misc_ore28'] = math.floor(cost_count)
            
            return true
        else    
            local cost_count = 1 + math.floor(count / 2.5)
            cost_count = cost_count * 1.5
            cost_list['misc_BlessedStone_1'] = math.floor(cost_count)

            cost_count = 300 * math.pow(1.04, count)
            cost_count = cost_count * 1.3
            cost_list['JurateCertificate'] = math.floor(cost_count)

            cost_count = 100 * math.pow(1.05, count)
            cost_count = cost_count * 1.5
            cost_list['misc_ore28'] = math.floor(cost_count) -- 
            return true
        end
    elseif lv == 540 then
        if grade == 'LOW' then
            local cost_count = 1 + math.floor(count / 4)
            cost_list['misc_BlessedStone_2'] = math.floor(cost_count)

            cost_count = 300 * math.pow(1.04, count)
            cost_list['AustejaCertificate'] = math.floor(cost_count)

            cost_count = 100 * math.pow(1.05, count)
            cost_list['misc_ore29'] = math.floor(cost_count)
            
            return true
        else    
            local cost_count = 1 + math.floor(count / 2.5)
            cost_count = cost_count * 1.5
            cost_list['misc_BlessedStone_2'] = math.floor(cost_count)

            cost_count = 300 * math.pow(1.04, count)
            cost_count = cost_count * 1.3
            cost_list['AustejaCertificate'] = math.floor(cost_count)

            cost_count = 100 * math.pow(1.05, count)
            cost_count = cost_count * 1.5
            cost_list['misc_ore29'] = math.floor(cost_count) -- 
            return true
        end
    end

    return false
end

shared_item_goddess_icor.get_reroll_cost_table = function(item)
    if TryGetProp(item, 'StringArg3', 'None') ~= 'None' then
        return nil, false
    end
    
    local cost_list = {}
    local valid = false

    local lv = TryGetProp(item, 'UseLv', 0)
    local grade = 'LOW'
    if string.find(TryGetProp(item, 'ClassName', 'None'), '_high') ~= nil then
        grade = 'HIGH'
    end

    local count = TryGetProp(item, 'RerollCount', 0) 

    valid = shared_item_goddess_icor.get_cost(lv, count, grade, cost_list)

    return cost_list, valid
end

-- 0: 아님, 1:하급, 2:상급
shared_item_goddess_icor.get_goddess_icor_grade = function(item)    
    if TryGetProp(item, 'GroupName', 'None') == 'Icor' then
        local str = TryGetProp(item, 'StringArg', 'None')            
        if string.find(str, 'GoddessIcor') ~= nil then
            if TryGetProp(item, 'NumberArg1', 0) == 20 then
                return 2        
            elseif TryGetProp(item, 'NumberArg1', 0) == 1 then
                return 1
            else
                return 0
            end        
        else
            return 0
        end
    else
        local level = TryGetProp(item, 'IsGoddessIcorOption', 0)    
        return level
    end
end

shared_item_goddess_icor.get_candidate_count = function(item)
    return 3
end

shared_item_goddess_icor.get_option_list_by_index = function(item, index)
    local option_group = {'ATK', 'STAT', 'UTIL_ARMOR', 'DEF'}
    local level = TryGetProp(item, 'UseLv', 0)


    local spot = TryGetProp(item, 'StringArg2', 'None')
    return shared_item_goddess_icor.get_option_list_by_group(level, spot, option_group[index])
end

shared_item_goddess_icor.is_valid_reroll_option = function(item, index, option_name)
    local class_name = TryGetProp(item, 'ClassName', 'None')    
    local max = shared_item_goddess_icor.get_max_option_count()
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

function GET_MAX_REG_VALUE(lv)
    local pivot = 480
    local diff = lv - pivot
    diff = math.max(0, diff)
    
    local max = pivot / math.pow(0.75, diff * 0.1)
    return math.floor(max)
end
