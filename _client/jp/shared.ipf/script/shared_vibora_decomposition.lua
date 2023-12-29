-- shared_vibora_decomposition.lua

local vibora_return_list = nil
local goddess_return_list = nil
local evil_return_list = nil

-- a를 dest에 병합한다.
local function merge_dic(dest, a)
    for k, v in pairs(a) do
        if dest[k] == nil then
            dest[k] = v
        else
            dest[k] = dest[k] + v
        end
    end

    return dest
end

local function make_vibora_return_list()
    if vibora_return_list == nil then
        vibora_return_list = {}

        vibora_return_list[1] = {} 
        vibora_return_list[1]['Vibora_misc_Lv2'] = 500

        vibora_return_list[2] = {} -- 바이보를 제외한 하위 잡재료
        vibora_return_list[2]['Vibora_misc_Lv2'] = 20

        vibora_return_list[3] = {}
        vibora_return_list[3]['EP12_enrich_Vibora_misc'] = 15
        vibora_return_list[3]['Vis'] = 75000000
        vibora_return_list[3]['Vibora_misc_Lv2'] = 40

        vibora_return_list[4] = {}
        vibora_return_list[4]['EP12_enrich_Vibora_misc'] = 70
        vibora_return_list[4]['Vis'] = 430000000
        vibora_return_list[4]['Vibora_misc_Lv2'] = 80
    end
end

local function make_goddess_evil_return_list()
    if goddess_return_list == nil then
        goddess_return_list = {}
        evil_return_list = {}

        goddess_return_list[1] = {}
        goddess_return_list[1]['goddess_misc'] = 2
        goddess_return_list[1]['misc_archenium'] = 1
        evil_return_list[1] = {}
        evil_return_list[1]['evil_misc'] = 2
        evil_return_list[1]['misc_archenium'] = 1

        goddess_return_list[2] = {}
        goddess_return_list[2]['EP12_enrich_Goddess_misc'] = 10
        goddess_return_list[2]['Vis'] = 25000000        
        evil_return_list[2] = {}
        evil_return_list[2]['EP12_enrich_Goddess_misc'] = 10
        evil_return_list[2]['Vis'] = 25000000

        goddess_return_list[3] = {}
        goddess_return_list[3]['EP12_enrich_Goddess_misc'] = 25
        goddess_return_list[3]['Vis'] = 100000000
        evil_return_list[3] = {}
        evil_return_list[3]['EP12_enrich_Goddess_misc'] = 25
        evil_return_list[3]['Vis'] = 100000000
    end
end

make_vibora_return_list()
make_goddess_evil_return_list()

function GET_VIBORA_DECOMPOSITION_MATERIAL(item)
    if vibora_return_list == nil then
        make_vibora_return_list()
    end

    local is_icor = TryGetProp(item, 'GroupName', 'None') == 'Icor'
    if is_icor == true then
        local item_name = TryGetProp(item, 'InheritanceItemName', 'None')
        if item_name == 'None' then
            return nil 
        end
        local cls = GetClass('Item', item_name)
        if cls == nil then
            return nil
        else
            item = cls
        end
    end

    if TryGetProp(item, 'StringArg', 'None') ~= 'Vibora' then        
        return nil
    end

    local lv = TryGetProp(item, 'NumberArg1', 1)
    if lv < 1 then
        return nil
    end

    return vibora_return_list[lv]
end

-- 두번째 반환 인자가 false 인 경우, 바이보라가 아니거나 해당 사항없음
-- 현재 레벨에서의 연성수치에 해당하는 재료를 반환
function GET_EXTRA_REFINE_VIBORA_MATERIAL(item)
    local check_item = item
    local is_icor = TryGetProp(item, 'GroupName', 'None') == 'Icor'
    if is_icor == true then
        local item_name = TryGetProp(item, 'InheritanceItemName', 'None')
        if item_name == 'None' then
            return nil, false
        end
        local cls = GetClass('Item', item_name)
        if cls == nil then
            return nil, false
        else
            check_item = cls
        end
    end

    if TryGetProp(check_item, 'StringArg', 'None') ~= 'Vibora' then
        return nil, false
    end

    local dic = {}
    local lv = TryGetProp(check_item, 'NumberArg1', 1)
    if lv == 1 then
        return dic, true
    end
    if lv <= 0 or lv >= 4 then
        return dic, true
    end
    
    -- 2렙, 3렙인 경우
    local count = TryGetProp(item, 'UPGRADE_TRY_COUNT', 0)
    if count == 0 then        
        return dic, true
    end
    if lv == 2 then
        dic['EP12_enrich_Vibora_misc'] = 1 * count
        dic['Vis'] = 5000000 * count
        return dic, true
    elseif lv == 3 then
        dic['EP12_enrich_Vibora_misc'] = 1 * count
        dic['Vis'] = 7000000 * count
        return dic, true
    end

    return nil, false
end

function GET_LV1_VIBORA_NAME(item)
    local is_icor = TryGetProp(item, 'GroupName', 'None') == 'Icor'
    if is_icor == true then
        local item_name = TryGetProp(item, 'InheritanceItemName', 'None')
        if item_name == 'None' then
            return '', false 
        end
        local cls = GetClass('Item', item_name)
        if cls == nil then
            return '', false
        else
            item = cls
        end
    end
    
    if TryGetProp(item, 'StringArg', 'None') ~= 'Vibora' then
        return '', false
    end

    -- 2,3,4 렙만 대상
    local lv = TryGetProp(item, 'NumberArg1', 1) 
    if lv <= 1 or lv > 4 then
        return '', false
    end
    
    local name = TryGetProp(item, 'ClassName', 'None')
    if GetClass('Item', name) == nil then
        return '', false
    end

    local token = StringSplit(name, '_')
    local full_name = ''
    for i = 1, #token - 1 do
        if i == #token - 1 then
            full_name = full_name .. token[i]
        else
            full_name = full_name .. token[i] .. '_'
        end
    end

    full_name = GET_PARENT_VIBORA_NAME(full_name)

    return full_name, true
end

-- 최종 재료를 반환하는 함수
function GET_FINAL_VIBORA_DECOMPOSITION_MATERIAL(item)
    local final_dic = {}

    local dic_extra, bool_extra = GET_EXTRA_REFINE_VIBORA_MATERIAL(item) -- 추가 연성이 되어 있는 재료 가져오기
    if bool_extra == false then        
        return nil
    end

    local lv = 1

    local is_icor = TryGetProp(item, 'GroupName', 'None') == 'Icor'
    if is_icor == true then
        local item_name = TryGetProp(item, 'InheritanceItemName', 'None')
        if item_name == 'None' then
            return nil 
        end
        local cls = GetClass('Item', item_name)
        if cls == nil then
            return nil
        else
            lv = TryGetProp(cls, 'NumberArg1', 1)
        end
    else
        lv = TryGetProp(item, 'NumberArg1', 1)
    end
    
    if lv < 1 or lv >= 5 then
        return nil
    end

    for k, v in pairs(dic_extra) do
        if final_dic[k] == nil then
            final_dic[k] = v
        else
            final_dic[k] = final_dic[k] + v
        end
    end

    local main_dic = GET_VIBORA_DECOMPOSITION_MATERIAL(item)
    if main_dic == nil then        
        return nil
    end
    
    for k, v in pairs(main_dic) do
        if final_dic[k] == nil then
            final_dic[k] = v
        else
            final_dic[k] = final_dic[k] + v
        end
    end

    local vibora_lv1_count = 0    
    if lv == 2 then
        vibora_lv1_count = 2
    elseif lv == 3 then
        vibora_lv1_count = 4
    elseif lv == 4 then
        vibora_lv1_count = 8
    end

    if lv > 1 then
        local name, bool_name = GET_LV1_VIBORA_NAME(item)
        if bool_name == false then
            return nil
        end
        final_dic[name] = vibora_lv1_count
    end

    
    return final_dic
end

------------------ 여마신 분해 -----------------------
-- 두번째 반환 인자가 false 인 경우, 바이보라가 아니거나 해당 사항없음
-- 현재 레벨에서의 연성수치에 해당하는 재료를 반환
function GET_EXTRA_REFINE_EVIL_MATERIAL(item)
    local check_item = item
    local is_icor = TryGetProp(item, 'GroupName', 'None') == 'Icor'
    if is_icor == true then
        local item_name = TryGetProp(item, 'InheritanceItemName', 'None')
        if item_name == 'None' then
            return nil, false
        end
        local cls = GetClass('Item', item_name)
        if cls == nil then
            return nil, false
        else
            check_item = cls
        end
    end

    if TryGetProp(check_item, 'StringArg', 'None') ~= 'evil' and TryGetProp(check_item, 'StringArg', 'None') ~= 'goddess' then
        return nil, false
    end

    local dic = {}
    local lv = TryGetProp(check_item, 'NumberArg1', 1)
    if lv <= 0 or lv >= 3 then
        return dic, true
    end
    
    -- 1렙, 2렙인 경우
    local count = TryGetProp(item, 'UPGRADE_GODDESS_TRY_COUNT', 0)
    if count == 0 then        
        return dic, true
    end
    if lv == 1 then
        dic['EP12_enrich_Goddess_misc'] = 1 * count
        dic['Vis'] = 2500000 * count
        return dic, true
    elseif lv == 2 then
        dic['EP12_enrich_Goddess_misc'] = 1 * count
        dic['Vis'] = 4000000 * count
        return dic, true
    end

    return nil, false
end

-- 분해 가능한 마신/여신방어구 인가? (모든 레벨 분해 가능)
-- stringArg, NumberArg1 체크
function CAN_DECOMPOSE_EVIL_GODDESS_ITEM(item)    
    if TryGetProp(item, 'GroupName', 'None') == 'Icor' then  -- 아이커인 경우
        local inheritance_name = TryGetProp(item, 'InheritanceItemName', 'None')
        if inheritance_name ~= 'None' then
            local item_obj = GetClass('Item', inheritance_name)
            if item_obj == nil then
                return false
            end
            local string_arg = TryGetProp(item_obj, 'StringArg', 'None')
            if (string_arg == 'evil' or string_arg == 'goddess') and TryGetProp(item_obj, 'NumberArg1', 0) >= 1 then
                return true    
            end
        end
    else
        local string_arg = TryGetProp(item, 'StringArg', 'None')
        if (string_arg == 'evil' or string_arg == 'goddess') and TryGetProp(item, 'NumberArg1', 0) >= 1 then
            return true    
        end
    end

    return false
end

function GET_EVIL_DECOMPOSITION_MATERIAL(item)
    if goddess_return_list == nil then
        make_goddess_evil_return_list()
    end

    local is_icor = TryGetProp(item, 'GroupName', 'None') == 'Icor'
    if is_icor == true then
        local item_name = TryGetProp(item, 'InheritanceItemName', 'None')
        if item_name == 'None' then
            return nil 
        end
        local cls = GetClass('Item', item_name)
        if cls == nil then
            return nil
        else
            item = cls
        end
    end

    local type = TryGetProp(item, 'StringArg', 'None')

    if type ~= 'evil' and type ~= 'goddess' then        
        return nil
    end

    local item_name = TryGetProp(item, 'ClassName', 'None')       

    local lv = TryGetProp(item, 'NumberArg1', 1)    
    if lv <= 0 then
        return nil
    end

    local ret_dic = {}

    for i = 1, lv do
        local mat = nil
        if type == 'evil' then
            mat = evil_return_list[i]
        else
            mat = goddess_return_list[i]
        end

        if mat == nil then
            return nil
        end

        local repeat_count = math.pow(2, lv - i)
        
        for j = 1, repeat_count do
            ret_dic = merge_dic(ret_dic, mat)
        end
    end

    return ret_dic
end

function GET_FINAL_EVIL_DECOMPOSITION_MATERIAL(item)
    local final_dic = {}

    local dic_extra, bool_extra = GET_EXTRA_REFINE_EVIL_MATERIAL(item) -- 추가 연성이 되어 있는 재료 가져오기
    if bool_extra == false then        
        return nil
    end
    local mat_dic = GET_EVIL_DECOMPOSITION_MATERIAL(item)
    if mat_dic == nil then        
        return nil
    end

    final_dic = merge_dic(final_dic, dic_extra)
    final_dic = merge_dic(final_dic, mat_dic)
    return final_dic
end
