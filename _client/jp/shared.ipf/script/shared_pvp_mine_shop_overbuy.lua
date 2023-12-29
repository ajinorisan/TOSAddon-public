-- shared_pvp_mine_shop_overbuy.lua

function GET_OVERBUY_NEED_COUNT(base, over_count, ratio, recipecls)  
    base = base + (((base * ratio) * over_count) / 10000)
    return math.floor(base)
end

function IS_OVERBUY_SHOP(shopType)
    if shopType == 'PVPMine' then
        return true
    end

    if string.find(shopType, 'Certificate') ~= nil then
        return true
    end
end

function IS_OVERBUY_ITEM(shopType, recipecls, aObj)
    if IS_OVERBUY_SHOP(shopType) == false then
        return false
    end
    
    local need_acc_property = TryGetProp(recipecls, 'AccountNeedProperty', 'None')

    if need_acc_property ~= 'None' and TryGetProp(aObj, need_acc_property, 0) <= 0 then
        if TryGetProp(recipecls, 'MaxOverBuyCount', 0) > 0 then
            local overbuy_prop = TryGetProp(recipecls, 'OverBuyProperty', 'None')  
            if overbuy_prop ~= 'None' then
                return true
            end
        end
    end

    return false
end
function IS_EXCEED_OVERBUY_COUNT(shopType, acc, cls, itemCnt)  -- 아이템을 추가적으로 얻게 되면 개수를 초과하게 되는가?
    if IS_OVERBUY_SHOP(shopType) == false then
        return true
    end

    local max = TryGetProp(cls, 'MaxOverBuyCount', 100)
    local prop_name = TryGetProp(cls, 'OverBuyProperty', 'None')
    if prop_name == 'None' then
        return true
    end
    local now = TryGetProp(acc, prop_name, 0)
    now = now + itemCnt
    
    if now > max then
        return true
    end

    return false
end
function GET_CURRENT_OVERBUY_COUNT(shopType, base_value, recipecls, aObj)    
    if IS_OVERBUY_SHOP(shopType) == false then
        return base_value
    end

    local need_acc_property = TryGetProp(recipecls, 'AccountNeedProperty', 'None')

    local OverBuyRatioFunc_name = 'OverBuyRatioFunc'
    if TryGetProp(recipecls, 'OverBuyRatioFunc', 'None') ~= 'None' then
        OverBuyRatioFunc_name = TryGetProp(recipecls, 'OverBuyRatioFunc', 'None')
    end

    if need_acc_property ~= 'None' and TryGetProp(aObj, need_acc_property, 0) <= 0 then                    
        if TryGetProp(recipecls, 'MaxOverBuyCount', 0) > 0 then
            local overbuy_prop = TryGetProp(recipecls, 'OverBuyProperty', 'None')  
            if overbuy_prop ~= 'None' then
                local current_overbuy = TryGetProp(aObj, overbuy_prop, TryGetProp(recipecls, 'MaxOverBuyCount', 0))               

                if _G[OverBuyRatioFunc_name] ~= nil then
                    local over_count = _G[OverBuyRatioFunc_name](base_value, current_overbuy + 1, tonumber(TryGetProp(recipecls, 'OverBuyRatio', 5000)), recipecls)
                    base_value = over_count
                    return base_value
                else
                    local over_count = GET_OVERBUY_NEED_COUNT(base_value, current_overbuy + 1, tonumber(TryGetProp(recipecls, 'OverBuyRatio', 5000)), recipecls)
                    base_value = over_count
                    return base_value
                end
            end
        end
    end

    return base_value
end
function GET_TOTAL_AMOUNT_OVERBUY(shopType, base_value, recipecls, aObj, count) 
    if IS_OVERBUY_SHOP(shopType) == false then
        return base_value
    end

    local need_acc_property = TryGetProp(recipecls, 'AccountNeedProperty', 'None')

    local OverBuyRatioFunc_name = 'OverBuyRatioFunc'
    if TryGetProp(recipecls, 'OverBuyRatioFunc', 'None') ~= 'None' then
        OverBuyRatioFunc_name = TryGetProp(recipecls, 'OverBuyRatioFunc', 'None')
    end

    if need_acc_property ~= 'None' and TryGetProp(aObj, need_acc_property, 0) <= 0 then
        if TryGetProp(recipecls, 'MaxOverBuyCount', 0) > 0 then
            local overbuy_prop = TryGetProp(recipecls, 'OverBuyProperty', 'None')  
            if overbuy_prop ~= 'None' then                
                local current_overbuy = TryGetProp(aObj, overbuy_prop, TryGetProp(recipecls, 'MaxOverBuyCount', 0))                
                local over_count = 0
                local idx = current_overbuy

                for idx = current_overbuy, current_overbuy + count - 1 do                                        
                    if _G[OverBuyRatioFunc_name] ~= nil then
                        over_count = over_count + _G[OverBuyRatioFunc_name](base_value, idx + 1, tonumber(TryGetProp(recipecls, 'OverBuyRatio',  5000)), recipecls)
                    else
                        over_count = over_count + GET_OVERBUY_NEED_COUNT(base_value, idx + 1, tonumber(TryGetProp(recipecls, 'OverBuyRatio',  5000)), recipecls)
                    end
                end
                
                return over_count
            end
        end
    end

    return base_value
end