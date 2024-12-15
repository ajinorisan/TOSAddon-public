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
