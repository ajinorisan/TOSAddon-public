-- type : 1 = 실버 사용 추출, 2 = 특성 포인트 사용 추출
function ABILITY_POINT_EXTRACTOR_ON_INIT(addon, frame)
    addon:RegisterMsg('SUCCESS_EXTRACT_ABILITY_POINT', 'ABILITY_POINT_EXTRACTOR_RESET');
end

function ABILITY_POINT_EXTRACTOR_OPEN(frame)
    local checkType_1 = GET_CHILD_RECURSIVELY(frame, "checkType_1");
    checkType_1:Select();
    ABILITY_POINT_EXTRACTOR_TYPE_RADIO_BTN_CLICK(frame, nil, "", 1);

    local sklAbilFrame = ui.GetFrame('skillability');
    SET_FRAME_OFFSET_TO_RIGHT_TOP(frame, sklAbilFrame);
end

function ABILITY_POINT_EXTRACTOR_RESET(frame, msg, argStr, type)
    local frame = frame:GetTopParentFrame();

    local feeValueText = GET_CHILD_RECURSIVELY(frame, 'feeValueText');
    local extractScrollEdit = GET_CHILD_RECURSIVELY(frame, 'extractScrollEdit');
    local consumeMoney2Box = GET_CHILD(frame, 'consumeMoney2Box');
    local consumeMoneyBox = GET_CHILD(frame, 'consumeMoneyBox');
    local expectMoneyBox = GET_CHILD(frame, 'expectMoneyBox');

    local enableCountByMoney = 0;
    local enableCountByPoint = 0;
    local enableCount = 0;

    if type == 1 then
        local consumeMoney, eventDiscount = ABILITY_POINT_EXTRACTOR_GET_CONSUME_MONEY(frame)        
        if IS_SEASON_SERVER() == 'YES' then
            feeValueText:SetTextByKey('value', GET_COMMAED_STRING(ABILITY_POINT_EXTRACTOR_FEE_SEASON));
        else
            feeValueText:SetTextByKey('value', GET_COMMAED_STRING(ABILITY_POINT_EXTRACTOR_FEE));
        end
        feeValueText:SetTextByKey('value2', ClMsg("Auto_SilBeo"));
        
        local money = GET_TOTAL_MONEY_STR();

        if IS_SEASON_SERVER() == 'YES' then
            enableCountByMoney = math.floor(tonumber(money));
        else
            enableCountByMoney = math.floor(tonumber(money) / ABILITY_POINT_EXTRACTOR_FEE);
        end
        
        enableCountByPoint = math.floor(session.ability.GetAbilityPoint() / ABILITY_POINT_SCROLL_RATE);

        if eventDiscount == 0 then
            enableCount = math.min(enableCountByMoney, enableCountByPoint);
        else
            enableCount = enableCountByPoint;
        end
        
        consumeMoney2Box:ShowWindow(0);
        consumeMoneyBox:ShowWindow(1);
        expectMoneyBox:ShowWindow(1);

    elseif type == 2 then
        local fee = GET_ABILITY_POINT_EXTRACTOR_FEE(type);
        feeValueText:SetTextByKey('value', GET_COMMAED_STRING(fee));
        feeValueText:SetTextByKey('value2', "%");
        
        enableCountByMoney = math.floor(session.ability.GetAbilityPoint() / (ABILITY_POINT_SCROLL_RATE + (ABILITY_POINT_SCROLL_RATE / 100 * fee)));
        enableCountByPoint = math.floor(session.ability.GetAbilityPoint() / ABILITY_POINT_SCROLL_RATE);
        enableCount = math.min(enableCountByMoney, enableCountByPoint);
        consumeMoney2Box:ShowWindow(1);
        consumeMoneyBox:ShowWindow(0);
        expectMoneyBox:ShowWindow(0);
    end
    
    frame:SetUserValue('TYPE', type);
    frame:SetUserValue('ENABLE_COUNT', enableCount);
    
    local minRemainPoint = GET_ABILITY_POINT_EXTRACTOR_MIN_REMAIN_POINT(type)
    if session.ability.GetAbilityPoint() < minRemainPoint then
        ABILITY_POINT_EXTRACTOR_SET_EDIT(extractScrollEdit, 0);
    else
        ABILITY_POINT_EXTRACTOR_SET_EDIT(extractScrollEdit, GET_ABILITY_POINT_EXTRACTOR_MIN_VALUE(type));
    end
    ABILITY_POINT_EXTRACTOR_UPDATE_MONEY(frame);
end

function ABILITY_POINT_EXTRACTOR_DOWN(parent, ctrl, argstr, argnum)
    local extractScrollEdit = parent:GetChild('extractScrollEdit');
    local topFrame = parent:GetTopParentFrame();
    local currentCount = topFrame:GetUserIValue('SCROLL_COUNT');
    local type = topFrame:GetUserIValue('TYPE');
    local minvalue = GET_ABILITY_POINT_EXTRACTOR_MIN_VALUE(type);    

    ABILITY_POINT_EXTRACTOR_SET_EDIT(extractScrollEdit, math.max(minvalue, tonumber(currentCount) - argnum));
    ABILITY_POINT_EXTRACTOR_UPDATE_MONEY(parent:GetTopParentFrame());
end

function ABILITY_POINT_EXTRACTOR_UP(parent, ctrl, argstr, argnum)
    local extractScrollEdit = parent:GetChild('extractScrollEdit');
    local topFrame = parent:GetTopParentFrame();
    local currentCount = topFrame:GetUserIValue('SCROLL_COUNT');
    local enableCountByPoint = topFrame:GetUserIValue('ENABLE_COUNT');
    local type = topFrame:GetUserIValue('TYPE');
    local nextvalue = math.min(enableCountByPoint, tonumber(currentCount) + argnum);
    if nextvalue < GET_ABILITY_POINT_EXTRACTOR_MIN_VALUE(type) then
        nextvalue = GET_ABILITY_POINT_EXTRACTOR_MIN_VALUE(type);
    end
    ABILITY_POINT_EXTRACTOR_SET_EDIT(extractScrollEdit, nextvalue);
    ABILITY_POINT_EXTRACTOR_UPDATE_MONEY(parent:GetTopParentFrame());
end

function ABILITY_POINT_EXTRACTOR_MIN(parent, ctrl, argstr, argnum)
    local extractScrollEdit = parent:GetChild('extractScrollEdit');
    local topFrame = parent:GetTopParentFrame();
    local currentCount = topFrame:GetUserIValue('SCROLL_COUNT');
    local type = topFrame:GetUserIValue('TYPE');
    ABILITY_POINT_EXTRACTOR_SET_EDIT(extractScrollEdit, GET_ABILITY_POINT_EXTRACTOR_MIN_VALUE(type));
    ABILITY_POINT_EXTRACTOR_UPDATE_MONEY(parent:GetTopParentFrame());
end

function ABILITY_POINT_EXTRACTOR_MAX(parent, ctrl, argstr, argnum)
    local extractScrollEdit = parent:GetChild('extractScrollEdit');
    local topFrame = parent:GetTopParentFrame();
    local currentCount = topFrame:GetUserIValue('SCROLL_COUNT');
    local enableCountByPoint = topFrame:GetUserIValue('ENABLE_COUNT');
    local type = topFrame:GetUserIValue('TYPE');
    if enableCountByPoint < GET_ABILITY_POINT_EXTRACTOR_MIN_VALUE(type) then
        enableCountByPoint = GET_ABILITY_POINT_EXTRACTOR_MIN_VALUE(type);
    end
    ABILITY_POINT_EXTRACTOR_SET_EDIT(extractScrollEdit, enableCountByPoint);
    ABILITY_POINT_EXTRACTOR_UPDATE_MONEY(parent:GetTopParentFrame());
end

function ABILITY_POINT_EXTRACTOR_CANCEL(parent, ctrl)
    ui.CloseFrame('ability_point_extractor');
end

function ABILITY_POINT_EXTRACTOR_UPDATE_MONEY(frame)
    local frame = ui.GetFrame("ability_point_extractor")
    local type = frame:GetUserIValue('TYPE');
    local consumePointText = GET_CHILD_RECURSIVELY(frame, 'consumePointText');
    local remainPointText = GET_CHILD_RECURSIVELY(frame, 'remainPointText');

    local consumeMoney, eventDiscount = ABILITY_POINT_EXTRACTOR_GET_CONSUME_MONEY(frame);
    local consumePoint = ABILITY_POINT_EXTRACTOR_GET_CONSUME_POINT(frame);
    
    local abilityPoint = session.ability.GetAbilityPoint();
    local expectAbilityPoint = abilityPoint - tonumber(consumePoint);

    local extractScrollEdit = GET_CHILD_RECURSIVELY(frame, 'extractScrollEdit');
    local extractScrollBox = GET_CHILD_RECURSIVELY(frame, 'extractScrollBox');
    local extractScrollDown = GET_CHILD_RECURSIVELY(frame, 'extractScrollDown');
    local extractScrollUp = GET_CHILD_RECURSIVELY(frame, 'extractScrollUp');
    local extractScrollReset = GET_CHILD_RECURSIVELY(frame, 'extractScrollReset');
    local extractScrollMax = GET_CHILD_RECURSIVELY(frame, 'extractScrollMax');

    local minRemainPoint = GET_ABILITY_POINT_EXTRACTOR_MIN_REMAIN_POINT(type)
    if abilityPoint < minRemainPoint then
        remainPointText:SetFontName('red_18')
        remainPointText:SetTextTooltip(ScpArgMsg("AbilityPointExtractor_NotEnoughAbilityPoint", "MIN", GET_COMMAED_STRING(GET_ABILITY_POINT_EXTRACTOR_MIN_REMAIN_POINT(type))))
        extractScrollBox:SetEnable(0)
        extractScrollDown:SetEnable(0)
        extractScrollUp:SetEnable(0)
        extractScrollReset:SetEnable(0)
        extractScrollMax:SetEnable(0)
    else
        remainPointText:SetFontName('brown_18')
        remainPointText:SetTextTooltip('')
        extractScrollBox:SetEnable(1)
        extractScrollDown:SetEnable(1)
        extractScrollUp:SetEnable(1)
        extractScrollReset:SetEnable(1)
        extractScrollMax:SetEnable(1)
    end

    if type == 1 then        
        local expectMoneyStr = "";
        local consumeMoneyStr = GET_COMMAED_STRING(consumeMoney);
        
        local money = GET_TOTAL_MONEY_STR();
        local expectMoney = SumForBigNumberInt64(money, '-'..consumeMoney);
        if tonumber(consumeMoney) > 0 then
            consumeMoneyStr = '-'..consumeMoneyStr;
        end
    
        if tonumber(expectMoney) >= 0 then
            expectMoneyStr = GET_COMMAED_STRING(expectMoney);
        else
            local EXCEED_MONEY_STYLE = frame:GetUserConfig('EXCEED_MONEY_STYLE');
            expectMoneyStr = EXCEED_MONEY_STYLE..'-'..GET_COMMAED_STRING(-expectMoney)..'{/}';
        end

        -- if eventDiscount == 1 then
        --     consumeMoneyStr = consumeMoneyStr..' '..ScpArgMsg('EVENT_1811_ABILITY_EXTRACTOR_MSG1','COUNT',100)
        -- end
    
        if eventDiscount == 1 then
            consumeMoneyStr = consumeMoneyStr..' '..ScpArgMsg('AbilityPointFreeExtract')
        end

        local consumeMoneyText = GET_CHILD_RECURSIVELY(frame, 'consumeMoneyText');
        consumeMoneyText:SetTextByKey('value', consumeMoneyStr);
        
        local expectMoneyText = GET_CHILD_RECURSIVELY(frame, 'expectMoneyText');
        expectMoneyText:SetTextByKey('value', expectMoneyStr);   
    elseif type == 2 then
        expectAbilityPoint = expectAbilityPoint - consumeMoney;

        local consumeMoney2Text = GET_CHILD_RECURSIVELY(frame, 'consumeMoney2Text');
        local consumeMoneyStr = GET_COMMAED_STRING(consumeMoney);
        consumeMoney2Text:SetTextByKey('value', consumeMoneyStr);
    end

    local consumePointStr = GET_COMMAED_STRING(consumePoint);
    local expectAbilityPointStr = GET_COMMAED_STRING(expectAbilityPoint);
    if expectAbilityPoint < 0 then
        local EXCEED_MONEY_STYLE = frame:GetUserConfig('EXCEED_MONEY_STYLE');
        expectAbilityPointStr = EXCEED_MONEY_STYLE..GET_COMMAED_STRING(expectAbilityPoint)..'{/}';
    end

    consumePointText:SetTextByKey('value', consumePointStr);
    remainPointText:SetTextByKey('value', expectAbilityPointStr);
end

function ABILITY_POINT_EXTRACTOR_GET_CONSUME_MONEY(frame)
    local type = frame:GetUserIValue('TYPE');
    local scrollCount = frame:GetUserIValue('SCROLL_COUNT');
    local exchangeFee = ABILITY_POINT_EXTRACTOR_FEE;
    
    if type == 2 then
        local fee = GET_ABILITY_POINT_EXTRACTOR_FEE(type);
        exchangeFee = ABILITY_POINT_SCROLL_RATE / 100 * fee;
    end

    local consumeMoney = MultForBigNumberInt64(scrollCount, exchangeFee);
    local sObj = session.GetSessionObjectByName("ssn_klapeda");
    if sObj ~= nil then
    	sObj = GetIES(sObj:GetIESObject());
    end
    
    local eventDiscount = 0

    -- 특포 무료 추출권은 실버에만 적용
    if type == 1 then
        -- ABILITY_EXTRACT_FREE_COUPON
        local invItem = session.GetInvItemByName("Event_free_ap_return")
        if invItem ~= nil then
            consumeMoney = 0
            eventDiscount = 1
        end
        
        -- EVENT_2012_YAK_ABILITY_EXTRACT_FREE_COUPON
        local invItem = session.GetInvItemByName("Event_free_ap_return2")
        if invItem ~= nil then
            consumeMoney = 0
            eventDiscount = 1
        end
    end
    
    if IS_SEASON_SERVER() == 'YES' then
        return 0, 1
    end 

    return consumeMoney, eventDiscount;
end

function ABILITY_POINT_EXTRACTOR_GET_CONSUME_POINT(frame)
    local type = frame:GetUserIValue("TYPE");
    local scrollCount = frame:GetUserIValue('SCROLL_COUNT');
    local exchangeRate = ABILITY_POINT_SCROLL_RATE;
    local exchangeCount = MultForBigNumberInt64(scrollCount, exchangeRate);
    return exchangeCount;
end

function ABILITY_POINT_EXTRACTOR_TYPING(parent, ctrl)
    ABILITY_POINT_EXTRACTOR_SET_EDIT(ctrl, ctrl:GetText());
    ABILITY_POINT_EXTRACTOR_UPDATE_MONEY(parent:GetTopParentFrame());
end

function ABILITY_POINT_EXTRACTOR_SET_EDIT(edit, count)
    local topFrame = edit:GetTopParentFrame();
    local enableCount = topFrame:GetUserIValue('ENABLE_COUNT');
    count = tonumber(count)
    if count == nil then
        count = 0;
        edit:SetText('0');
    end
    count = math.min(count, MAX_ABILITY_POINT);
    if count > enableCount then
        local EXCEED_POINT_STYLE = topFrame:GetUserConfig('EXCEED_POINT_STYLE');
        edit:SetText(EXCEED_POINT_STYLE..count..'{/}');
    else
        edit:SetText(count);
    end
    topFrame:SetUserValue('SCROLL_COUNT', count);
end

function ABILITY_POINT_EXTRACTOR(parent, ctrl)
    local topFrame = parent:GetTopParentFrame();
    local count = topFrame:GetUserIValue('SCROLL_COUNT');
    local type = topFrame:GetUserIValue("TYPE");

    local abilityPoint = session.ability.GetAbilityPoint();
    local minRemainPoint = GET_ABILITY_POINT_EXTRACTOR_MIN_REMAIN_POINT(type)
    if abilityPoint < minRemainPoint then
        ui.SysMsg(ScpArgMsg("AbilityPointExtractor_NotEnoughAbilityPoint", "MIN", GET_COMMAED_STRING(minRemainPoint)))
        return
    end

    if count < 1 then
        return;
    end
    
    if type == 1 then
        local consumeMoney, eventDiscount = ABILITY_POINT_EXTRACTOR_GET_CONSUME_MONEY(topFrame);
        local money = GET_TOTAL_MONEY_STR();
        if IsGreaterThanForBigNumber(consumeMoney, money) == 1 then
            ui.SysMsg(ClMsg('NotEnoughMoney'));
            return;
        end

        local consumePoint = ABILITY_POINT_EXTRACTOR_GET_CONSUME_POINT(topFrame);
        
        --    local pointRateStr = GET_COMMAED_STRING(ABILITY_POINT_SCROLL_RATE);
        local consumeMoneyStr = GET_COMMAED_STRING(consumeMoney);
        local consumePointStr = GET_COMMAED_STRING(consumePoint);
        
        -- if eventDiscount == 1 then
        --     consumeMoneyStr = consumeMoneyStr..' '..ScpArgMsg('EVENT_1811_ABILITY_EXTRACTOR_MSG1','COUNT', 100)
        -- end
    
        if eventDiscount == 1 then
            consumeMoneyStr = consumeMoneyStr..' '..ScpArgMsg('AbilityPointFreeExtract')
        end
        
        local msg = ScpArgMsg("AskExtractAbilityPoint{Silver}{Scroll}{ConsumePoint}", "Silver", consumeMoneyStr, "Scroll", count, "ConsumePoint", consumePointStr);

        local yesscp = string.format('EXEC_ABILITY_POINT_EXTRACTOR(%d, %d)', count, type);
        ui.MsgBox_NonNested(msg, topFrame:GetName(), yesscp, 'None');
    elseif type == 2 then
        if count < GET_ABILITY_POINT_EXTRACTOR_MIN_VALUE(type) then
            ui.SysMsg(ScpArgMsg("AbilityPointExtractorMinCount{VALUE}", "VALUE", GET_ABILITY_POINT_EXTRACTOR_MIN_VALUE(type)))
            return;
        end
        local consumePoint = ABILITY_POINT_EXTRACTOR_GET_CONSUME_POINT(topFrame);
        local consumeMoney, eventDiscount = ABILITY_POINT_EXTRACTOR_GET_CONSUME_MONEY(topFrame);
        
        local consumePointStr = GET_COMMAED_STRING(consumePoint);
        local consumeMoneyStr = GET_COMMAED_STRING(consumeMoney + consumePoint);
        
        msg = ScpArgMsg("AskExtractAbilityPoint2{AllConsumePoint}{Scroll}{ConsumePoint}", "AllConsumePoint", consumeMoneyStr, "Scroll", count, "ConsumePoint", consumePointStr);
        local yesscp = string.format('EXEC_ABILITY_POINT_EXTRACTOR(%d, %d)', count, type);
        ui.MsgBox_NonNested(msg, topFrame:GetName(), yesscp, 'None');
    end
    
end

function EXEC_ABILITY_POINT_EXTRACTOR(count, type)
    if type == 1 then
        control.CustomCommand('REQ_EXTRACT_ABILITY', count);
    elseif type == 2 then
        control.CustomCommand('REQ_EXTRACT_ABILITY_BY_ABILITY_POINT', count);
    end
end

function ABILITY_POINT_EXTRACTOR_TYPE_RADIO_BTN_CLICK(parent, ctrl, argStr, type)
    local frame = parent:GetTopParentFrame();
    local question = GET_CHILD(frame, "question");
    local tooltipText = "";
    local minRemainPoint = GET_ABILITY_POINT_EXTRACTOR_MIN_REMAIN_POINT(type)
    local remainPoint = GET_COMMAED_STRING(minRemainPoint)
    if type == 1 then
        if IS_SEASON_SERVER() == 'YES' then
            tooltipText = ScpArgMsg("AbilityPointExtractorTooltipText_1{MIN_REMAIN_POINT}", 'silver', GET_COMMAED_STRING(0), "MIN_REMAIN_POINT", remainPoint)
        else
            tooltipText = ScpArgMsg("AbilityPointExtractorTooltipText_1{MIN_REMAIN_POINT}", 'silver', GET_COMMAED_STRING(100000), "MIN_REMAIN_POINT", remainPoint)
        end
    elseif type == 2 then
        local fee = GET_ABILITY_POINT_EXTRACTOR_FEE(type);
        tooltipText = ScpArgMsg("AbilityPointExtractorTooltipText_2{VALUE}{MIN_REMAIN_POINT}{MIN}", "VALUE", fee, "MIN_REMAIN_POINT", remainPoint, "MIN", GET_ABILITY_POINT_EXTRACTOR_MIN_VALUE(type));
    end
    question:SetTextTooltip(tooltipText);

    ABILITY_POINT_EXTRACTOR_RESET(frame, "", "", type);
end