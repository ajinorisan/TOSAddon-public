
function COIN_GET_GAUGE_ON_INIT(addon, frame)
    addon:RegisterMsg("SET_COIN_GET_GAUGE", "COIN_GET_GAUGE_SET")
    addon:RegisterMsg("UPDATE_COIN_GET_GAUGE", "COIN_GET_GAUGE_UPDATE")
end

function ON_COIN_GET_GAUGE_OPEN(frame)
    COIN_GET_GAUGE_SET(frame)
end

function COIN_GET_GAUGE_SET(frame, msg, argStr, argNum)
    local acc = GetMyAccountObj()
    if acc == nil then
        return
    end

    local currentValue = TryGetProp(acc, 'WEEKLY_PVP_MINE_COUNT', 0)
    local maxValue = tonumber(MAX_WEEKLY_PVP_MINE_COUNT)
    local isTokenState = session.loginInfo.IsPremiumState(ITEM_TOKEN)
    if isTokenState == true then
        local bonusValue = tonumber(WEEKLY_PVP_MINE_COUNT_TOKEN_BONUS)
        maxValue = maxValue + bonusValue
    end

    if PVP_MINE_MISC_BOOST_EXPIRED(GetMyPCObject()) == false then
        maxValue = maxValue + GET_PVP_MINE_MISC_BOOST_COUNT2()
    end

    local get_gauge = GET_CHILD_RECURSIVELY(frame, "get_gauge")
    if currentValue >= maxValue then
        get_gauge:SetPoint(maxValue, maxValue)
        get_gauge:SetSkinName("pcbang_point_gauge_max")
        get_gauge:ShowStat(0, false)
        get_gauge:ShowStat(1, true)
    else
        get_gauge:SetPoint(currentValue, maxValue)
        get_gauge:SetSkinName("pcbang_point_gauge_s");
        get_gauge:ShowStat(0, true)
        get_gauge:ShowStat(1, false)
    end
end

function COIN_GET_GAUGE_UPDATE(frame, msg, argStr, argNum)
    local get_gauge = GET_CHILD_RECURSIVELY(frame, "get_gauge")
    local currentValue = get_gauge:GetCurPoint()

    if argStr == 'minus' then
        currentValue = currentValue - argNum
    else
        if argNum ~= nil then
            currentValue = currentValue + argNum
        end
    end
    
    local maxValue = tonumber(MAX_WEEKLY_PVP_MINE_COUNT)
    local isTokenState = session.loginInfo.IsPremiumState(ITEM_TOKEN)
    if isTokenState == true then
        local bonusValue = tonumber(WEEKLY_PVP_MINE_COUNT_TOKEN_BONUS)
        maxValue = maxValue + bonusValue
    end

    if PVP_MINE_MISC_BOOST_EXPIRED(GetMyPCObject()) == false then
        maxValue = maxValue + GET_PVP_MINE_MISC_BOOST_COUNT2()
    end

    if currentValue >= maxValue then
        get_gauge:SetPoint(maxValue, maxValue)
        get_gauge:SetSkinName("pcbang_point_gauge_max")
        get_gauge:ShowStat(0, false)
        get_gauge:ShowStat(1, true)
    else
        get_gauge:SetPoint(currentValue, maxValue)
        get_gauge:SetSkinName("pcbang_point_gauge_s");
        get_gauge:ShowStat(0, true)
        get_gauge:ShowStat(1, false)
    end
end