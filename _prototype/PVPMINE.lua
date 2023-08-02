function WORKPANEL_TICKET_STR(ticketname)

    local remain = WORKPANEL_GET_RECIPE_TRADE_COUNT(ticketname)
    local max = WORKPANEL_GET_MAX_RECIPE_TRADE_COUNT(ticketname)
    local overbuy = WORKPANEL_GET_MAX_OVERBUY_RECIPE_TRADE_COUNT(ticketname)
    local used = max - remain

    if (used >= max and overbuy and overbuy > 0) then
        return "{#FF3333}{ol}" .. used .. "/" .. (max + overbuy)
    end
    return "{#FFFFFF}{ol}" .. used .. "/" .. (max)
end

-- トレード可能数
function WORKPANEL_GET_RECIPE_TRADE_COUNT(recipeName)
    local recipeCls = GetClass("ItemTradeShop", recipeName)
    DBGOUT("recipeCls: " .. recipeName)
    if recipeCls.NeedProperty ~= "None" and recipeCls.NeedProperty ~= "" then
        local sObj = GetSessionObject(GetMyPCObject(), "ssn_shop")
        local sCount = TryGetProp(sObj, recipeCls.NeedProperty)

        if sCount then
            return sCount
        end
    end

    if recipeCls.AccountNeedProperty ~= "None" and recipeCls.AccountNeedProperty ~= "" then

        local aObj = GetMyAccountObj()
        local sCount = TryGetProp(aObj, recipeCls.AccountNeedProperty)

        if sCount then
            return sCount
        end
    end

    return nil
end

function WORKPANEL_GET_MAX_RECIPE_TRADE_COUNT(recipeName)
    local recipeCls = GetClass("ItemTradeShop", recipeName)
    local accountCls = GetClassByType("Account", 1)
    if recipeCls.NeedProperty ~= "None" and recipeCls.NeedProperty ~= "" then
        local sObj = GetSessionObject(GetMyPCObject(), "ssn_shop")
        local sCount = TryGetProp(accountCls, recipeCls.NeedProperty)

        if sCount then
            return sCount
        end
    end

    if recipeCls.AccountNeedProperty ~= "None" and recipeCls.AccountNeedProperty ~= "" then
        -- local aObj = GetMyAccountObj()
        local sCount = TryGetProp(accountCls, recipeCls.AccountNeedProperty)

        if sCount then
            return sCount
        end
    end
    return nil
end

function WORKPANEL_GET_RECIPE_OVERBUY_TRADE_COUNT(recipeName)
    local count = WORKPANEL_GET_MAX_RECIPE_TRADE_COUNT(recipeName) - (WORKPANEL_GET_RECIPE_TRADE_COUNT(recipeName) or 0)
    local overbuy = WORKPANEL_GET_MAX_OVERBUY_RECIPE_TRADE_COUNT(recipeName) or 0
    if overbuy <= -1 then
        overbuy = 0
    end
    -- DBGOUT("CURRENT:"..count.."MAX:"..WORKPANEL_GET_MAX_RECIPE_TRADE_COUNT(recipeName).."OVER:"..overbuy)
    return math.max(0, count - WORKPANEL_GET_MAX_RECIPE_TRADE_COUNT(recipeName))
end
