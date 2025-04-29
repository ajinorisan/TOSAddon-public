-- shared_leticia_prop.lua

function GET_LETICIA_PROBABILITY()
    local total = 0
    local ret = {}
    local start = 7001
    local group_name = 'Gacha_TP2_001'
    if config.GetServiceNation() == 'PAPAYA' then
        start = 7501
        group_name = 'Gacha_TP2_001_PAPAYA'
    end
    for i = start, start + 100 do
        local cls = GetClassByType('reward_tp', i)
        if TryGetProp(cls, 'Group', 'None') == group_name then
            total = total + TryGetProp(cls, 'Ratio', 0)
        end
    end

    -- ItemName, Count, Prop
    for i = start, start + 100 do
        local cls = GetClassByType('reward_tp', i)
        if TryGetProp(cls, 'Group', 'None') == group_name then
            local name = TryGetProp(cls, 'ItemName', 'None')
            local count = TryGetProp(cls, 'Count', 0)
            local ratio = TryGetProp(cls, 'Ratio', 0)
            local rank = TryGetProp(cls, 'Rank', 'None')

            local str = string.format('%.5f', ratio / total * 100)
            table.insert(ret, {name, count, str, rank})
        end
    end

    return ret
end

local cachelist =
{
    s_goddess_gacha_cache = {};
}

----캐싱 시작
local function get_cached_list(key, fetch_func, timeout, arg_val)
    local data = cachelist.key
    if data and data.expires > os.time() then
        return data.value
    end

    if fetch_func then
        local value = fetch_func(arg_val)
        cachelist.key = {
            value = value,
            expires = os.time() + (timeout or 300) -- 기본 5분
        }
        return value
    end
    return nil
end

-- Item group data definitions
local GODDESS_GROUPS = {
    ["Gacha_Blessed_CUBE_001"] = {
        start = 10000001,
        items = {
            {10000001, 10, "S", "Blessed_New_S"},
            {20000001, 10, "A", "Blessed_New_A"},
            {50000001, 100, "A", "Blessed_Old_A"},
            {30000001, 20, "B", "Blessed_New_B"},
            {60000001, 150, "B", "Blessed_Old_B"},
            {40000001, 50, "C", "Blessed_HairAcc_C"}
        }
    },
    ["Gacha_Blessed_CUBE_001_PAPAYA"] = {
        start = 75005,
        items = {
            {75111, 10, "S", "Blessed_New_S_PAPAYA"},
            {75211, 10, "A", "Blessed_New_A_PAPAYA"},
            {75311, 30, "B", "Blessed_New_B_PAPAYA"},
            {75505, 100, "C", "Blessed_HairAcc_C_PAPAYA"}
        }
    }
}

-- Get goddess group data by name
local function GET_GODDESS_GROUP(ratioGroupName)
    local group_data = GODDESS_GROUPS[ratioGroupName]
    if not group_data then
        return {}, 0
    end
    
    return group_data.items, group_data.start
end

local function GET_GOEESS_CUBE_GROUP_TABLE(ratioGroupName)
    local table_list = {}    
    local item_group_list = {}
    local ratio_group_table = {}
    local ratio_start = 0;

    item_group_list, ratio_start = GET_GODDESS_GROUP(ratioGroupName)

    for i = ratio_start, ratio_start + 5 do
        local cls = GetClassByType('reward_tp', i)
        if TryGetProp(cls, 'Group', 'None') == ratioGroupName then
            local Rank = TryGetProp(cls, 'Rank', 'None');
            local Ratio = TryGetProp(cls, 'Ratio', 0);

            ratio_group_table[Rank] = Ratio;
        end
    end


    for _, idx_list in pairs(item_group_list) do
        local startidx = idx_list[1]
        local size = idx_list[2]
        local Rank = idx_list[3]
        local group = idx_list[4]
        --해당 그룹의 아이템 총 개수
        
        --현재 파파야 아이템이 추가되는 오류있음 수정 해야함
        local grade_count = 0;
        for i = startidx, startidx + size do
            local cls = GetClassByType('reward_tp', i)
            if TryGetProp(cls, 'Rank', 'None') == Rank and
            TryGetProp(cls, 'Group', 'None') == group
             then
                grade_count = grade_count + 1;                
            end
        end

        for i = startidx, startidx + size do
            local cls = GetClassByType('reward_tp', i)
            if TryGetProp(cls, 'Group', 'None') == group then
                local group_ratio = ratio_group_table[Rank];
                local name = TryGetProp(cls, 'ItemName', 'None')
                local count = TryGetProp(cls, 'Count', 0)
                local ratio = TryGetProp(cls, 'Ratio', 0)
                local rank = TryGetProp(cls, 'Rank', 'None')
    
                local str = string.format('%.5f', ratio / grade_count * group_ratio / 100)
                table.insert(table_list, {name, count, str, rank})    
            end
        end
    end


    return table_list;
end

function GET_GODDESS_CUBE_PROBABILITY(ratioGroupName)
 
    return get_cached_list("s_goddess_gacha_cache", GET_GOEESS_CUBE_GROUP_TABLE, 600, ratioGroupName)
end
