--- item_luciferi_decomposition.lua

-- 루시페리 분해 관련
g_luciferi_return_list = nil

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


function make_luciferi_return_list()
    if g_luciferi_return_list ~= nil then
        return
    end

    if g_luciferi_return_list == nil then
        g_luciferi_return_list = {}
    end

    local dic = {}
    dic['EP12_NECK06_HIGH_001'] = 1
    dic['EP12_NECK06_HIGH_002'] = 1
    dic['EP12_NECK06_HIGH_003'] = 1
    dic['EP12_NECK06_HIGH_004'] = 1
    dic['EP12_NECK06_HIGH_005'] = 1
    dic['EP12_NECK06_HIGH_006'] = 1

    dic['EP12_BRC06_HIGH_001'] = 1
    dic['EP12_BRC06_HIGH_002'] = 1
    dic['EP12_BRC06_HIGH_003'] = 1
    dic['EP12_BRC06_HIGH_004'] = 1
    dic['EP12_BRC06_HIGH_005'] = 1
    dic['EP12_BRC06_HIGH_006'] = 1

    g_luciferi_return_list['EP12_NECK05_HIGH_001'] = {}
    g_luciferi_return_list['EP12_NECK05_HIGH_001']['NECK05_010'] = 1
    g_luciferi_return_list['EP12_NECK05_HIGH_001']['NECK05_006'] = 1
    g_luciferi_return_list['EP12_NECK05_HIGH_001']['misc_mothstone'] = 2
    g_luciferi_return_list['EP12_NECK05_HIGH_002'] = {}
    g_luciferi_return_list['EP12_NECK05_HIGH_002']['NECK05_012'] = 1
    g_luciferi_return_list['EP12_NECK05_HIGH_002']['NECK05_004'] = 1
    g_luciferi_return_list['EP12_NECK05_HIGH_002']['misc_mothstone'] = 2
    g_luciferi_return_list['EP12_NECK05_HIGH_003'] = {}
    g_luciferi_return_list['EP12_NECK05_HIGH_003']['NECK05_009'] = 1
    g_luciferi_return_list['EP12_NECK05_HIGH_003']['NECK05_007'] = 1
    g_luciferi_return_list['EP12_NECK05_HIGH_003']['misc_mothstone'] = 2
    g_luciferi_return_list['EP12_NECK05_HIGH_004'] = {}
    g_luciferi_return_list['EP12_NECK05_HIGH_004']['NECK05_009'] = 1
    g_luciferi_return_list['EP12_NECK05_HIGH_004']['NECK05_005'] = 1
    g_luciferi_return_list['EP12_NECK05_HIGH_004']['misc_mothstone'] = 2
    g_luciferi_return_list['EP12_NECK05_HIGH_005'] = {}
    g_luciferi_return_list['EP12_NECK05_HIGH_005']['NECK05_008'] = 1
    g_luciferi_return_list['EP12_NECK05_HIGH_005']['NECK05_003'] = 1
    g_luciferi_return_list['EP12_NECK05_HIGH_005']['misc_mothstone'] = 2
    g_luciferi_return_list['EP12_NECK05_HIGH_006'] = {}
    g_luciferi_return_list['EP12_NECK05_HIGH_006']['NECK05_011'] = 1
    g_luciferi_return_list['EP12_NECK05_HIGH_006']['NECK05_001'] = 1
    g_luciferi_return_list['EP12_NECK05_HIGH_006']['misc_mothstone'] = 2
    g_luciferi_return_list['EP12_NECK05_HIGH_007'] = {}
    g_luciferi_return_list['EP12_NECK05_HIGH_007']['NECK05_008'] = 1
    g_luciferi_return_list['EP12_NECK05_HIGH_007']['NECK05_002'] = 1
    g_luciferi_return_list['EP12_NECK05_HIGH_007']['misc_mothstone'] = 2

    g_luciferi_return_list['EP12_BRC05_HIGH_001'] = {}
    g_luciferi_return_list['EP12_BRC05_HIGH_001']['BRC05_010'] = 1
    g_luciferi_return_list['EP12_BRC05_HIGH_001']['BRC05_006'] = 1
    g_luciferi_return_list['EP12_BRC05_HIGH_001']['misc_mothstone'] = 1
    g_luciferi_return_list['EP12_BRC05_HIGH_002'] = {}
    g_luciferi_return_list['EP12_BRC05_HIGH_002']['BRC05_012'] = 1
    g_luciferi_return_list['EP12_BRC05_HIGH_002']['BRC05_004'] = 1
    g_luciferi_return_list['EP12_BRC05_HIGH_002']['misc_mothstone'] = 1
    g_luciferi_return_list['EP12_BRC05_HIGH_003'] = {}
    g_luciferi_return_list['EP12_BRC05_HIGH_003']['BRC05_009'] = 1
    g_luciferi_return_list['EP12_BRC05_HIGH_003']['BRC05_007'] = 1
    g_luciferi_return_list['EP12_BRC05_HIGH_003']['misc_mothstone'] = 1
    g_luciferi_return_list['EP12_BRC05_HIGH_004'] = {}
    g_luciferi_return_list['EP12_BRC05_HIGH_004']['BRC05_009'] = 1
    g_luciferi_return_list['EP12_BRC05_HIGH_004']['BRC05_005'] = 1
    g_luciferi_return_list['EP12_BRC05_HIGH_004']['misc_mothstone'] = 1
    g_luciferi_return_list['EP12_BRC05_HIGH_005'] = {}
    g_luciferi_return_list['EP12_BRC05_HIGH_005']['BRC05_008'] = 1
    g_luciferi_return_list['EP12_BRC05_HIGH_005']['BRC05_003'] = 1
    g_luciferi_return_list['EP12_BRC05_HIGH_005']['misc_mothstone'] = 1
    g_luciferi_return_list['EP12_BRC05_HIGH_006'] = {}
    g_luciferi_return_list['EP12_BRC05_HIGH_006']['BRC05_011'] = 1
    g_luciferi_return_list['EP12_BRC05_HIGH_006']['BRC05_001'] = 1
    g_luciferi_return_list['EP12_BRC05_HIGH_006']['misc_mothstone'] = 1
    g_luciferi_return_list['EP12_BRC05_HIGH_007'] = {}
    g_luciferi_return_list['EP12_BRC05_HIGH_007']['BRC05_008'] = 1
    g_luciferi_return_list['EP12_BRC05_HIGH_007']['BRC05_002'] = 1
    g_luciferi_return_list['EP12_BRC05_HIGH_007']['misc_mothstone'] = 1

    g_luciferi_return_list['EP12_NECK05_LOW_001'] = {}
    g_luciferi_return_list['EP12_NECK05_LOW_001']['NECK05_010'] = 1
    g_luciferi_return_list['EP12_NECK05_LOW_001']['NECK05_006'] = 1
    g_luciferi_return_list['EP12_NECK05_LOW_001']['misc_mothstone'] = 1
    g_luciferi_return_list['EP12_NECK05_LOW_001']['misc_Telharsha_neck'] = 16
    g_luciferi_return_list['EP12_NECK05_LOW_002'] = {}
    g_luciferi_return_list['EP12_NECK05_LOW_002']['NECK05_012'] = 1
    g_luciferi_return_list['EP12_NECK05_LOW_002']['NECK05_004'] = 1
    g_luciferi_return_list['EP12_NECK05_LOW_002']['misc_mothstone'] = 1
    g_luciferi_return_list['EP12_NECK05_LOW_002']['misc_Telharsha_neck'] = 16
    g_luciferi_return_list['EP12_NECK05_LOW_003'] = {}
    g_luciferi_return_list['EP12_NECK05_LOW_002']['NECK05_009'] = 1
    g_luciferi_return_list['EP12_NECK05_LOW_002']['NECK05_007'] = 1
    g_luciferi_return_list['EP12_NECK05_LOW_002']['misc_mothstone'] = 1
    g_luciferi_return_list['EP12_NECK05_LOW_002']['misc_Telharsha_neck'] = 16
    g_luciferi_return_list['EP12_NECK05_LOW_004'] = {}
    g_luciferi_return_list['EP12_NECK05_LOW_004']['NECK05_009'] = 1
    g_luciferi_return_list['EP12_NECK05_LOW_004']['NECK05_005'] = 1
    g_luciferi_return_list['EP12_NECK05_LOW_004']['misc_mothstone'] = 1
    g_luciferi_return_list['EP12_NECK05_LOW_004']['misc_Telharsha_neck'] = 16
    g_luciferi_return_list['EP12_NECK05_LOW_005'] = {}
    g_luciferi_return_list['EP12_NECK05_LOW_005']['NECK05_008'] = 1
    g_luciferi_return_list['EP12_NECK05_LOW_005']['NECK05_003'] = 1
    g_luciferi_return_list['EP12_NECK05_LOW_005']['misc_mothstone'] = 1
    g_luciferi_return_list['EP12_NECK05_LOW_005']['misc_Telharsha_neck'] = 16
    g_luciferi_return_list['EP12_NECK05_LOW_006'] = {}
    g_luciferi_return_list['EP12_NECK05_LOW_006']['NECK05_011'] = 1
    g_luciferi_return_list['EP12_NECK05_LOW_006']['NECK05_001'] = 1
    g_luciferi_return_list['EP12_NECK05_LOW_006']['misc_mothstone'] = 1
    g_luciferi_return_list['EP12_NECK05_LOW_006']['misc_Telharsha_neck'] = 16
    g_luciferi_return_list['EP12_NECK05_LOW_007'] = {}
    g_luciferi_return_list['EP12_NECK05_LOW_007']['NECK05_008'] = 1
    g_luciferi_return_list['EP12_NECK05_LOW_007']['NECK05_002'] = 1
    g_luciferi_return_list['EP12_NECK05_LOW_007']['misc_mothstone'] = 1
    g_luciferi_return_list['EP12_NECK05_LOW_007']['misc_Telharsha_neck'] = 16

    g_luciferi_return_list['EP12_BRC05_LOW_001'] = {}
    g_luciferi_return_list['EP12_BRC05_LOW_001']['BRC05_010'] = 1
    g_luciferi_return_list['EP12_BRC05_LOW_001']['BRC05_006'] = 1
    g_luciferi_return_list['EP12_BRC05_LOW_001']['misc_low_mothstone'] = 1
    g_luciferi_return_list['EP12_BRC05_LOW_001']['misc_Telharsha_neck'] = 8
    g_luciferi_return_list['EP12_BRC05_LOW_002'] = {}
    g_luciferi_return_list['EP12_BRC05_LOW_002']['BRC05_012'] = 1
    g_luciferi_return_list['EP12_BRC05_LOW_002']['BRC05_004'] = 1
    g_luciferi_return_list['EP12_BRC05_LOW_002']['misc_low_mothstone'] = 1
    g_luciferi_return_list['EP12_BRC05_LOW_002']['misc_Telharsha_neck'] = 8
    g_luciferi_return_list['EP12_BRC05_LOW_003'] = {}
    g_luciferi_return_list['EP12_BRC05_LOW_003']['BRC05_009'] = 1
    g_luciferi_return_list['EP12_BRC05_LOW_003']['BRC05_007'] = 1
    g_luciferi_return_list['EP12_BRC05_LOW_003']['misc_low_mothstone'] = 1
    g_luciferi_return_list['EP12_BRC05_LOW_003']['misc_Telharsha_neck'] = 8
    g_luciferi_return_list['EP12_BRC05_LOW_004'] = {}
    g_luciferi_return_list['EP12_BRC05_LOW_004']['BRC05_009'] = 1
    g_luciferi_return_list['EP12_BRC05_LOW_004']['BRC05_005'] = 1
    g_luciferi_return_list['EP12_BRC05_LOW_004']['misc_low_mothstone'] = 1
    g_luciferi_return_list['EP12_BRC05_LOW_004']['misc_Telharsha_neck'] = 8
    g_luciferi_return_list['EP12_BRC05_LOW_005'] = {}
    g_luciferi_return_list['EP12_BRC05_LOW_005']['BRC05_008'] = 1
    g_luciferi_return_list['EP12_BRC05_LOW_005']['BRC05_003'] = 1
    g_luciferi_return_list['EP12_BRC05_LOW_005']['misc_low_mothstone'] = 1
    g_luciferi_return_list['EP12_BRC05_LOW_005']['misc_Telharsha_neck'] = 8
    g_luciferi_return_list['EP12_BRC05_LOW_006'] = {}
    g_luciferi_return_list['EP12_BRC05_LOW_006']['BRC05_011'] = 1
    g_luciferi_return_list['EP12_BRC05_LOW_006']['BRC05_001'] = 1
    g_luciferi_return_list['EP12_BRC05_LOW_006']['misc_low_mothstone'] = 1
    g_luciferi_return_list['EP12_BRC05_LOW_006']['misc_Telharsha_neck'] = 8
    g_luciferi_return_list['EP12_BRC05_LOW_007'] = {}
    g_luciferi_return_list['EP12_BRC05_LOW_007']['BRC05_008'] = 1
    g_luciferi_return_list['EP12_BRC05_LOW_007']['BRC05_002'] = 1
    g_luciferi_return_list['EP12_BRC05_LOW_007']['misc_low_mothstone'] = 1
    g_luciferi_return_list['EP12_BRC05_LOW_007']['misc_Telharsha_neck'] = 8

    -- local list, cnt = GetClassList('legendrecipe')
    -- for i = 0, cnt - 1 do
    --     local cls = GetClassByIndexFromList(list, i)
    --     local class_name = TryGetProp(cls, 'TargetItem', 'None')        
    --     if dic[class_name] ~= nil then            
    --         local MaterialItemSlotCnt = TryGetProp(cls, 'MaterialItemSlotCnt', 0)
    --         if MaterialItemSlotCnt > 0 then
    --             local pass = false
    --             for j = 1, MaterialItemSlotCnt do
    --                 local _item_name = 'MaterialItem_' .. j
    --                 local _item_count = 'MaterialItemCnt_' .. j
    --                 local _transcend = 'MaterialItemTranscend_' .. j
    --                 local name = TryGetProp(cls, _item_name, 'None')

    --                 if string.find(name, '_LOW_') ~= nil and string.find(name, 'EP12_') ~= nil then
    --                     pass = true                        
    --                     break
    --                 end
    --             end

    --             if pass == false then
    --                 g_luciferi_return_list[class_name] = {}
    --                 for j = 1, MaterialItemSlotCnt do
    --                     local _item_name = 'MaterialItem_' .. j
    --                     local _item_count = 'MaterialItemCnt_' .. j
    --                     -- local _transcend = 'MaterialItemTranscend_' .. j
    --                     local name = TryGetProp(cls, _item_name, 'None')

    --                     local count = TryGetProp(cls, _item_count, 0)
    --                     -- local transcend = TryGetProp(cls, _transcend, 0)
    --                     if name ~= 'None' and count > 0 then                        
    --                         if g_luciferi_return_list[class_name][name] == nil then
    --                             g_luciferi_return_list[class_name][name] = count
    --                         else
    --                             g_luciferi_return_list[class_name][name] = g_luciferi_return_list[class_name][name] + count
    --                         end
    --                     end
    --                 end                
    --             end
    --         end
    --     end
    -- end    

    local list1, cnt1 = GetClassList('legendrecipe_luciferi')
    for i = 0, cnt1 - 1 do
        local cls = GetClassByIndexFromList(list1, i)
        local class_name = TryGetProp(cls, 'TargetItem', 'None')        
        if dic[class_name] ~= nil then            
            local MaterialItemSlotCnt = TryGetProp(cls, 'MaterialItemSlotCnt', 0)
            if MaterialItemSlotCnt > 0 then
                local pass = false
                for j = 1, MaterialItemSlotCnt do
                    local _item_name = 'MaterialItem_' .. j
                    local _item_count = 'MaterialItemCnt_' .. j
                    local _transcend = 'MaterialItemTranscend_' .. j
                    local name = TryGetProp(cls, _item_name, 'None')

                    if string.find(name, '_LOW_') ~= nil and string.find(name, 'EP12_') ~= nil then
                        pass = true                        
                        break
                    end
                end

                if pass == false then
                    g_luciferi_return_list[class_name] = {}
                    for j = 1, MaterialItemSlotCnt do
                        local _item_name = 'MaterialItem_' .. j
                        local _item_count = 'MaterialItemCnt_' .. j
                        -- local _transcend = 'MaterialItemTranscend_' .. j
                        local name = TryGetProp(cls, _item_name, 'None')

                        local count = TryGetProp(cls, _item_count, 0)
                        -- local transcend = TryGetProp(cls, _transcend, 0)
                        if name ~= 'None' and count > 0 then                        
                            if g_luciferi_return_list[class_name][name] == nil then
                                g_luciferi_return_list[class_name][name] = count
                            else
                                g_luciferi_return_list[class_name][name] = g_luciferi_return_list[class_name][name] + count
                            end
                        end
                    end                
                end
            end
        end
    end 
end

make_luciferi_return_list()

function GET_LUCIFERI_RETURN_LIST(class_name)    
    if g_luciferi_return_list[class_name] == nil then        
        return nil
    end    
    return g_luciferi_return_list[class_name]
end 

function GET_FINAL_LUCIFERI_RETURN_LIST(item)
    local ret_dic = {}

    local name = TryGetProp(item, 'ClassName', 'None')
    local dic = GET_LUCIFERI_RETURN_LIST(name)
    if dic == nil then        
        return nil
    end

    for k, v in pairs(dic) do
        if v == 1 then
            local _dic = GET_LUCIFERI_RETURN_LIST(k)
            if _dic ~= nil then
                ret_dic = merge_dic(ret_dic, _dic)           
            else
                if ret_dic[k] == nil then
                    ret_dic[k] = v
                else
                    ret_dic[k] = ret_dic[k] + v
                end     
            end
        else
            if ret_dic[k] == nil then
                ret_dic[k] = v
            else
                ret_dic[k] = ret_dic[k] + v
            end
        end
    end

    -- 초월 스크롤로 복구를 해줌
    -- if TryGetProp(item, 'StringArg', 'None') == 'Luciferi' then
    --     local count = GET_TRANSCEND_MATERIAL_COUNT_WITH_LEVEL(item, TryGetProp(item, 'Transcend', 0))    
    --     local transcend_dic = {}
    --     if count > 0 then
    --         transcend_dic['Premium_item_transcendence_Stone'] = count
    --         ret_dic = merge_dic(ret_dic, transcend_dic)
    --     end        
    -- end

    return ret_dic
end


-----------------------------------------------------------------------------------------------------
-- 루시페리 강화 추출 관련

-- 루시페리 강화 추출이 가능한 아이템인가?
function IS_VALID_EXTRACTABLE_LUCIFERI_ITEM(item_obj)
    if TryGetProp(item_obj, 'StringArg', 'None') ~= 'Luciferi' then
        return 'WebService_38'  -- 사용할 수 없는 대상입니다.
    end
    
    if TryGetProp(item_obj, 'CharacterBelonging', 0) == 1 then
        return 'CantExecCuzCharacterBelonging'
    end

    if TryGetProp(item_obj, 'DefaultEqpSlot', 'None') ~= 'NECK' and TryGetProp(item_obj, 'DefaultEqpSlot', 'None') ~= 'RING' then    
        return 'WebService_38'  -- 사용할 수 없는 대상입니다.
    end

    if TryGetProp(item_obj, 'ExtractProperty', 0) == 1 then
        return "AlreadyExtractedLuriferi"
    end    

    return "YES"
end

-- 루시페리 강화 스크롤인가?
function IS_LUCIFERI_REINFORCE_SCROLL_ITEM(obj)
    if TryGetProp(obj, 'StringArg', 'None') == 'saved_scroll_neck' or TryGetProp(obj, 'StringArg', 'None') == 'saved_scroll_ring' then
        return true
    end

    return false
end

-- 강화 부여가 가능한 아이템인가?
function IS_LUCIFERI_REINFORCE_SCROLL_ABLE_ITEM(itemObj, scrollType)    
    if TryGetProp(itemObj, 'StringArg', 'None') ~= 'Luciferi' then
        return 'WebService_38'
    end
    
    -- 귀속되지 않은 장비엔 사용불가
    if TryGetProp(itemObj, 'CharacterBelonging', 0) == 0 then
        return 'CanExecCuzCharacterBelonging'
    end

    local itemGroup = TryGetProp(itemObj, "DefaultEqpSlot", "None")    
    if scrollType == 'saved_scroll_neck' and itemGroup == 'NECK' then
        return 'YES'
    elseif scrollType == 'saved_scroll_ring' and itemGroup == 'RING' then
        return 'YES'
    else 
        return 'CantUseDiffenentDefaultEquipSlot'    
    end
    
    return 'WebService_38'
end

function GET_LUCIFERI_REINFORCE_SCROLL_TYPE(scrollObj)
    local scrollType = TryGetProp(scrollObj, 'StringArg', 'None');
    return scrollType;
end
-----------------------------------------------------------------------------------------------------
