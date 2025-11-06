-- custom_tooltip.lua

local function get_enable_msg(item, msg, msg2)
    local re = TryGetProp(item, 'Reinforce_2', 0)
    local rank = TryGetProp(item, 'UpgradeRank', 0)

    if rank == 0 and re >= 25 then
        msg2 = msg2 .. '{nl} {nl}' .. ScpArgMsg(msg)
        return msg2
    else
        return msg2
    end
end

local function get_item_effect_name(item)
    local ClassName = TryGetProp(item, "ClassName", "None")
    local EqpType = TryGetProp(item, "EqpType", "None")

    local optionname = ""

    if string.find(ClassName, '_NECK_01') ~= nil or string.find(ClassName, '_BRC_01') ~= nil then
        optionname = ClMsg("EP16_EFFECT_NAME01")
    elseif string.find(ClassName, '_NECK_02') ~= nil or string.find(ClassName, '_BRC_02') ~= nil then
        optionname = ClMsg("EP16_EFFECT_NAME02")
    elseif string.find(ClassName, '_NECK_03') ~= nil or string.find(ClassName, '_BRC_03') ~= nil then
        optionname = ClMsg("EP16_EFFECT_NAME03")
    elseif string.find(ClassName, '_NECK_04') ~= nil or string.find(ClassName, '_BRC_04') ~= nil then
        optionname = ClMsg("EP16_EFFECT_NAME04")
    end
    return optionname;
end

function tooltip_EP16_NECK_02(item)
    local a, b, c, d, e, f, g, h = GET_EP16_NECK_02_POINT(item)
    
    local value1, value2 = shared_upgrade_acc.get_value(item)    
    if value1 > 0 then
        e = e .. '{ol}{#0055aa}({img green_up_arrow 16 16}' .. value1  .. '){/}{/}'
    end

    local msg = ScpArgMsg('tooltip_EP16_NECK_02', 'a', a, 'b', b, 'c', c, 'd', d, 'e', e, 'f', f, 'g', g, 'h', h)    
    msg = get_enable_msg(item, 'enable_acc_upgrade_msg2', msg)
    optionname = get_item_effect_name(item)
    return msg, optionname
end

function tooltip_EP16_BRC_02(item)
    local a, b, c, d, e, f, g, h = GET_EP16_BRC_02_POINT(item)

    local value1, value2 = shared_upgrade_acc.get_value(item)    
    if value1 > 0 then
        e = e .. '{ol}{#0055aa}({img green_up_arrow 16 16}' .. value1  .. '){/}{/}'
    end

    local msg = ScpArgMsg('tooltip_EP16_NECK_02', 'a', a, 'b', b, 'c', c, 'd', d, 'e', e, 'f', f, 'g', g, 'h', h)
    msg = get_enable_msg(item, 'enable_acc_upgrade_msg2', msg)
    optionname = get_item_effect_name(item)

    return msg, optionname
end

function tooltip_EP16_NECK_01(item)
    local aa = '4,000'
    local a = '2,250'
    local b = '675'

    local value1, value2 = shared_upgrade_acc.get_value(item)
    if value1 > 0 then
        value1 = GET_COMMAED_STRING(value1)
        a = a .. '{ol}{#0055aa}({img green_up_arrow 16 16}' .. value1  .. '){/}{/}'
    end
    if value2 > 0 then
        value2 = GET_COMMAED_STRING(value2)
        b = b .. '{ol}{#0055aa}({img green_up_arrow 16 16}' .. value2  .. '){/}{/}'
    end

    local msg = ScpArgMsg('tooltip_EP16_NECK_01', 'aa', aa, 'a', a, 'b', b, 'c', 0.5)
    msg = get_enable_msg(item, 'enable_acc_upgrade_msg1', msg)
    optionname = get_item_effect_name(item)

    return msg, optionname
end

function tooltip_EP16_BRC_01(item)
    local aa = '2,000'
    local a = '1,125'
    local b = '337'

    local value1, value2 = shared_upgrade_acc.get_value(item)
    if value1 > 0 then
        value1 = GET_COMMAED_STRING(value1)
        a = a .. '{ol}{#0055aa}({img green_up_arrow 16 16}' .. value1  .. '){/}{/}'
    end
    if value2 > 0 then
        value2 = GET_COMMAED_STRING(value2)
        b = b .. '{ol}{#0055aa}({img green_up_arrow 16 16}' .. value2  .. '){/}{/}'
    end

    local msg = ScpArgMsg('tooltip_EP16_NECK_01', 'aa', aa, 'a', a, 'b', b, 'c', 0.25)
    msg = get_enable_msg(item, 'enable_acc_upgrade_msg1', msg)
    optionname = get_item_effect_name(item)

    return msg, optionname
end

function tooltip_EP16_NECK_03(item)
    local aa = '4,000'
    local a = '4,200'
    local b = '1,260'

    local value1, value2 = shared_upgrade_acc.get_value(item)    
    if value1 > 0 then
        value1 = GET_COMMAED_STRING(value1)
        a = a .. '{ol}{#0055aa}({img green_up_arrow 16 16}' .. value1  .. '){/}{/}'
    end
    if value2 > 0 then
        value2 = GET_COMMAED_STRING(value2)
        b = b .. '{ol}{#0055aa}({img green_up_arrow 16 16}' .. value2  .. '){/}{/}'
    end

    local msg = ScpArgMsg('tooltip_EP16_NECK_03', 'aa', aa, 'a', a, 'b', b, 'c', 0.5)
    msg = get_enable_msg(item, 'enable_acc_upgrade_msg1', msg)
    optionname = get_item_effect_name(item)

    return msg, optionname
end

function tooltip_EP16_BRC_03(item)
    local aa = '2,000'
    local a = '2,100'
    local b = '630'

    local value1, value2 = shared_upgrade_acc.get_value(item)
    if value1 > 0 then
        value1 = GET_COMMAED_STRING(value1)
        a = a .. '{ol}{#0055aa}({img green_up_arrow 16 16}' .. value1  .. '){/}{/}'
    end
    if value2 > 0 then
        value2 = GET_COMMAED_STRING(value2)
        b = b .. '{ol}{#0055aa}({img green_up_arrow 16 16}' .. value2  .. '){/}{/}'
    end

    local msg = ScpArgMsg('tooltip_EP16_NECK_03', 'aa', aa, 'a', a, 'b', b, 'c', 0.25)
    msg = get_enable_msg(item, 'enable_acc_upgrade_msg1', msg)
    optionname = get_item_effect_name(item)

    return msg, optionname
end

function tooltip_EP16_NECK_04(item)
    local aa = '4,000'
    local a = '2,626'
    local b = '788'

    local value1, value2 = shared_upgrade_acc.get_value(item)    
    if value1 > 0 then
        value1 = GET_COMMAED_STRING(value1)
        a = a .. '{ol}{#0055aa}({img green_up_arrow 16 16}' .. value1  .. '){/}{/}'
    end
    if value2 > 0 then
        value2 = GET_COMMAED_STRING(value2)
        b = b .. '{ol}{#0055aa}({img green_up_arrow 16 16}' .. value2  .. '){/}{/}'
    end

    local msg = ScpArgMsg('tooltip_EP16_NECK_04', 'aa', aa, 'a', a, 'b', b, 'c', 0.5)
    msg = get_enable_msg(item, 'enable_acc_upgrade_msg1', msg)
    optionname = get_item_effect_name(item)

    return msg, optionname
end

function tooltip_EP16_BRC_04(item)
    local aa = '2,000'
    local a = '1,313'
    local b = '394'

    local value1, value2 = shared_upgrade_acc.get_value(item)
    if value1 > 0 then
        value1 = GET_COMMAED_STRING(value1)
        a = a .. '{ol}{#0055aa}({img green_up_arrow 16 16}' .. value1  .. '){/}{/}'
    end
    if value2 > 0 then
        value2 = GET_COMMAED_STRING(value2)
        b = b .. '{ol}{#0055aa}({img green_up_arrow 16 16}' .. value2  .. '){/}{/}'
    end

    local msg = ScpArgMsg('tooltip_EP16_NECK_04', 'aa', aa, 'a', a, 'b', b, 'c', 0.25)
    msg = get_enable_msg(item, 'enable_acc_upgrade_msg1', msg)
    optionname = get_item_effect_name(item)

    return msg, optionname
end

function tooltip_Vasilisa(item)
    local msg = ScpArgMsg('enable_acc_upgrade_msg3')
    return msg, 'None'
end

function tooltip_EP17_Kalentis_NECK_01(item)    
    local aa = shared_upgrade_acc.get_add_atk_value(item)
    aa = GET_COMMAED_STRING(aa)

    local a = '4,500'
    local b = '1,350'    
    local msg = ScpArgMsg('tooltip_EP16_NECK_01', 'aa', aa, 'a', a, 'b', b, 'c', 0.5)
    
    optionname = get_item_effect_name(item)

    return msg, optionname
end

function tooltip_EP17_Kalentis_BRC_01(item)    
    local aa = shared_upgrade_acc.get_add_atk_value(item)
    aa = GET_COMMAED_STRING(aa)

    local a = '2,250'
    local b = '675'
    
    local msg = ScpArgMsg('tooltip_EP16_NECK_01', 'aa', aa, 'a', a, 'b', b, 'c', 0.25)
    
    optionname = get_item_effect_name(item)

    return msg, optionname
end
-- 칸트리베는 기존 툴팁으로 대응 가능

function tooltip_EP17_Kalentis_NECK_03(item)
    local aa = shared_upgrade_acc.get_add_atk_value(item)
    aa = GET_COMMAED_STRING(aa)

    local a = '8,400'
    local b = '2,520'
   
    local msg = ScpArgMsg('tooltip_EP16_NECK_03', 'aa', aa, 'a', a, 'b', b, 'c', 0.5)
    
    optionname = get_item_effect_name(item)

    return msg, optionname
end

function tooltip_EP17_Kalentis_BRC_03(item)
    local aa = shared_upgrade_acc.get_add_atk_value(item)
    aa = GET_COMMAED_STRING(aa)

    local a = '4,200'
    local b = '1,260'

    local msg = ScpArgMsg('tooltip_EP16_NECK_03', 'aa', aa, 'a', a, 'b', b, 'c', 0.25)
    
    optionname = get_item_effect_name(item)

    return msg, optionname
end

function tooltip_EP17_Kalentis_NECK_04(item)
    local aa = shared_upgrade_acc.get_add_atk_value(item)
    aa = GET_COMMAED_STRING(aa)

    local a = '5,252'
    local b = '1,576'

    local msg = ScpArgMsg('tooltip_EP16_NECK_04', 'aa', aa, 'a', a, 'b', b, 'c', 0.5)
    
    optionname = get_item_effect_name(item)

    return msg, optionname
end

function tooltip_EP17_Kalentis_BRC_04(item)
    local aa = shared_upgrade_acc.get_add_atk_value(item)
    aa = GET_COMMAED_STRING(aa)

    local a = '2,626'
    local b = '788'

    local msg = ScpArgMsg('tooltip_EP16_NECK_04', 'aa', aa, 'a', a, 'b', b, 'c', 0.25)
   
    optionname = get_item_effect_name(item)

    return msg, optionname
end

function tooltip_EP17_Kalentis_NECK_02(item)
    local a, b, c, d, e, f, g, h = GET_EP16_NECK_02_POINT(item)
    
    local value1, value2 = shared_upgrade_acc.get_value(item)    
    if value1 > 0 then
        e = e .. '{ol}{#0055aa}({img green_up_arrow 16 16}' .. value1  .. '){/}{/}'
    end

    local msg = ScpArgMsg('tooltip_EP16_NECK_02', 'a', a, 'b', b, 'c', c, 'd', d, 'e', e, 'f', f, 'g', g, 'h', h)    
    
    optionname = get_item_effect_name(item)    
    return msg, optionname
end

function tooltip_EP17_Kalentis_BRC_02(item)
    local a, b, c, d, e, f, g, h = GET_EP16_BRC_02_POINT(item)

    local value1, value2 = shared_upgrade_acc.get_value(item)    
    if value1 > 0 then
        e = e .. '{ol}{#0055aa}({img green_up_arrow 16 16}' .. value1  .. '){/}{/}'
    end

    local msg = ScpArgMsg('tooltip_EP16_NECK_02', 'a', a, 'b', b, 'c', c, 'd', d, 'e', e, 'f', f, 'g', g, 'h', h)
    
    optionname = get_item_effect_name(item)

    return msg, optionname
end