function DARK_MARKET_ON_INIT(addon, frame)
	addon:RegisterOpenOnlyMsg('UPDATE_BLACK_MARKET_ITEM', 'UPDATE_BLACK_MARKET_ITEM');
    addon:RegisterOpenOnlyMsg('UPDATE_BLACK_MARKET_ITEM_ADDON_MSG', 'UPDATE_BLACK_MARKET_ITEM_ADDON_MSG');    
end


function RESERVED_BLACK_MARKET_REQUEST_INFO()
    RequestBlackMarketBidInfo()
end


function UPDATE_BLACK_MARKET_ITEM_ADDON_MSG(frame)
    ReserveScript('RESERVED_BLACK_MARKET_REQUEST_INFO()', 1.5) 
end

function UPDATE_BLACK_MARKET_ITEM(frame, msg, argStr, argNum)    
    if frame:IsVisible() == 1 then
        local token = StringSplit(argStr, ';')

        local start = token[1]
        local eend = token[2]
        local item_name = token[3]
        local price = token[4]
        local is_my = tonumber(token[5])
        local my_price = token[6]
        local active_id = tonumber(token[7])
        
        SET_BLACK_MARKET_INIT(start, eend, item_name, price, is_my)        
        SET_BM_MY_AUCTION_STATE(frame, item_name, price, my_price, active_id)
    end
end

function BLACK_MARKET_UI_OPEN(start, eend, item_name, price, is_my, my_price, active_id)
    ui.OpenFrame("dark_market");
    local frame = ui.GetFrame("dark_market");
    local managerTab = frame:GetChild("managerTab")
    frame:SetUserValue("StartTime",start);
    frame:SetUserValue("EndTime",eend)
    frame:SetUserValue("MyPrice",my_price)

    local real = GET_CHILD_RECURSIVELY(frame, 'real')
    local price_frame = GET_CHILD_RECURSIVELY(frame, 'price')    
    real:SetTextByKey('price', GET_COMMAED_STRING(string.format("%s000000", price_frame:GetText())))

    frame:RunUpdateScript('BM_REMIAN_TIME_UPDATE', 1)    

    local processGbox = GET_CHILD_RECURSIVELY(frame,"processGbox")    
    local processinfo = GET_CHILD_RECURSIVELY(processGbox,"processinfo")
    local noinfo = GET_CHILD_RECURSIVELY(processGbox,"noinfo")

    if active_id ~= 0 then
        processinfo:ShowWindow(1)
        noinfo:ShowWindow(0)
        SET_BLACK_MARKET_INIT(start, eend, item_name, price, is_my)
    else
        processinfo:ShowWindow(0)
        noinfo:ShowWindow(1)
    end
    BLACK_MARKET_TAB_CHANGE(managerTab)    
    SET_BM_SCHEDULE(managerTab)
    SET_BM_MY_AUCTION_STATE(managerTab, item_name, price, my_price, active_id)
    BM_REMIAN_TIME_UPDATE(frame)
end

function SET_BLACK_MARKET_INIT(start, eend, item_name, price, is_my)        
    local frame = ui.GetFrame("dark_market");
    local itemCls = GetClass("Item", item_name)    
    if itemCls == nil then
        return;
    end

    local managerTab = GET_CHILD_RECURSIVELY(frame,"managerTab")
    local processGbox = GET_CHILD_RECURSIVELY(managerTab,"processGbox");
        
    SET_BLACK_MARKET_ICON(processGbox, itemCls, active_id);
    SET_BALCK_MARKET_ITEM_NAME(processGbox,itemCls, active_id)
    SET_BALCK_MARKET_ITEM_PRICE(frame, itemCls, price, is_my)
    SET_CURRENT_CASH_IN_HAND(managerTab)
end

function SET_BLACK_MARKET_ICON(frame, itemCls, active_id)
    if active_id == 0 then
        return
    end

    local fullImage = GET_LEGENDEXPPOTION_ICON_IMAGE_FULL(itemCls);
    local pic = GET_CHILD_RECURSIVELY(frame,"pic","ui::CSlot");
    
    local icon = pic:GetIcon()
    if icon ~= nil then
        icon:SetImage(fullImage)
    else
        icon = CreateIcon(pic);
        icon:SetImage(fullImage)
    end       
    SET_BALCK_MARKET_TOOLTIP(icon,itemCls)
end

function SET_BALCK_MARKET_TOOLTIP(icon, itemCls)
    SET_ITEM_TOOLTIP_BY_NAME(icon, itemCls.ClassName)
    icon:SetTooltipOverlap(1)
end

function SET_BALCK_MARKET_ITEM_NAME(frame, itemCls, active_id)
    local name = GET_CHILD_RECURSIVELY(frame,"name")
    local ItemName = TryGetProp(itemCls, "Name", "None");
    name:SetTextByKey("value",ItemName);

    if name:GetWidth() < name:GetTextWidth() then
        name:EnableSlideShow(1)
        name:SetCompareTextWidthBySlideShow(true);
    else
        name:EnableSlideShow(0)
        name:SetCompareTextWidthBySlideShow(false);
    end

end

function SET_BALCK_MARKET_ITEM_PRICE(frame, itemCls, price,is_my)
    local managerTab = GET_CHILD_RECURSIVELY(frame,"managerTab")
    local processGbox = GET_CHILD_RECURSIVELY(managerTab,"processGbox");
    local money = GET_CHILD_RECURSIVELY(processGbox,"money")
    local SetPrice = GET_COMMAED_STRING(price);
    local PriceStr;
    if is_my == 1 then
        PriceStr = string.format("{#FFFF00}%s",SetPrice)
    else
        PriceStr = SetPrice
    end
    money:SetTextByKey("value", PriceStr)
end

function BLACK_MARKET_PRICE_TYPING(parent, ctrl, argStr, argNum)
    local prop_name = GET_BLACK_MARKET_COIN_NAME()
    local silverAmountStr = TryGetProp(GetMyAccountObj(), prop_name, 'None')
    if silverAmountStr == 'None' then
        silverAmountStr = '0'
    end
    local real = GET_CHILD_RECURSIVELY(parent, 'real')
    local price = ctrl:GetText();
    price = string.format("%s000000",price);    
    
    real:SetTextByKey('price', GET_COMMAED_STRING(price))
    local isLarger = math.is_larger_than(price,silverAmountStr)

    if isLarger == 1 then
        local sliverlen = string.len(silverAmountStr);
        if sliverlen > 6 then
            local setPrice = CUT_RPICE_BLILLION(silverAmountStr);
            ctrl:SetText(setPrice)            
            real:SetTextByKey('price', GET_COMMAED_STRING(setPrice .. '000000'))
        else
            ctrl:SetText(0)
            real:SetTextByKey('price', '0')
        end
    end
end

function CUT_RPICE_BLILLION(price)
    local len = string.len(price);
    local maxpos = len - 6
    local price = string.sub(price,1,maxpos);
    return price
end

function BLACK_MARKET_BID(parent, ctrl)
    local frame = ui.GetFrame('dark_market')
    local managerTab = GET_CHILD_RECURSIVELY(frame,"managerTab")
    local processGbox = GET_CHILD_RECURSIVELY(managerTab,"processGbox");
    local text_box = GET_CHILD_RECURSIVELY(parent, 'price')
    local price = text_box:GetText()
    price = price .. '000000'
    RequestBlackMarketBid(price)
end

function BLACK_MARKET_TAB_CHANGE(parent, ctrl, argStr, argNum)
	local tabObj		    = parent:GetChild('markettab');
	local itembox_tab		= tolua.cast(tabObj, "ui::CTabControl");
	local curtabIndex	    = itembox_tab:GetSelectItemIndex();
    if curtabIndex == 2 then
        RequestBlackMarketBidInfo()        
    end
	BM_TAB_VIEW(parent, curtabIndex);
end

function BM_TAB_VIEW(frame, curtabIndex)
    local processGbox = frame:GetChild("processGbox")
    local scheduleGbox = frame:GetChild("scheduleGbox")
    local myMarketGbox = frame:GetChild("myMarketGbox")

    if curtabIndex == 0 then
        processGbox:ShowWindow(1)
        scheduleGbox:ShowWindow(0)
        myMarketGbox:ShowWindow(0)
    elseif curtabIndex == 1 then
        processGbox:ShowWindow(0)
        scheduleGbox:ShowWindow(1)
        myMarketGbox:ShowWindow(0)
    elseif curtabIndex == 2 then
        processGbox:ShowWindow(0)
        scheduleGbox:ShowWindow(0)
        myMarketGbox:ShowWindow(1)
    end
end

function CLOSE_DARK_MARKET(parent, ctrl, argStr, argNum)
    ui.CloseFrame("dark_market");
    parent:StopUpdateScript('BM_REMIAN_TIME_UPDATE')
end

function SET_CURRENT_CASH_IN_HAND(frame)
    local prop_name = GET_BLACK_MARKET_COIN_NAME()
    local silverAmountStr = TryGetProp(GetMyAccountObj(), prop_name, 'None')
    if silverAmountStr == 'None' then
        silverAmountStr = '0'
    end

    local cashinhand = GET_CHILD_RECURSIVELY(frame, 'cashinhand')
    local price = GET_COMMAED_STRING(silverAmountStr)
    cashinhand:SetTextByKey('value',price)
end

function BM_REMIAN_TIME_UPDATE(frame)    
    local frame = ui.GetFrame("dark_market");
    local startTime = frame:GetUserValue("StartTime");    
    local endTime = frame:GetUserValue("EndTime");

    if startTime == 'None' or endTime == 'None' then
        return 1
    end

    local totalsec = date_time.get_diff_sec(endTime,startTime);
    local sysTime = geTime.GetServerSystemTime();
    local nowTime = string.format("%04d-%02d-%02d %02d:%02d:%02d", sysTime.wYear, sysTime.wMonth, sysTime.wDay, sysTime.wHour, sysTime.wMinute, sysTime.wSecond)
    local diffsec = date_time.get_diff_sec(endTime,nowTime);

    local managerTab = GET_CHILD_RECURSIVELY(frame,"managerTab")
    local processGbox = GET_CHILD_RECURSIVELY(managerTab,"processGbox")
    local remianTime = GET_CHILD_RECURSIVELY(processGbox,"remianTime")
    local remianTimeGauge = GET_CHILD_RECURSIVELY(processGbox,"remianTimeGauge")

    if diffsec < 0 then
        diffsec = 0
    end
    
    remianTimeGauge:SetMaxPointWithTime(diffsec, totalsec, 0.1, 0.5);
    
    if diffsec == 0 then                
        remianTime:SetTextByKey("value", '{#ff0000}' .. ClMsg('TimeExpired'))
        return 0
    else
        local text = GET_TIME_TXT(diffsec)
        remianTime:SetTextByKey("value",text)
    end
    
    return 1;
end

function BM_SCHEDULE_FRAME_UPDATE(frame)
    local startTime = frame:GetUserValue("ctrlStart");
    local sysTime = geTime.GetServerSystemTime();
    local nowTime = string.format("%04d-%02d-%02d %02d:%02d:%02d", sysTime.wYear, sysTime.wMonth, sysTime.wDay, sysTime.wHour, sysTime.wMinute, sysTime.wSecond)
    local diffsec = date_time.get_diff_sec(startTime,nowTime);
    if diffsec < 0 then
        diffsec = 0
    end
    local remainTime = GET_TIME_TXT(diffsec)

    local remain = GET_CHILD_RECURSIVELY(frame,"remain")
    if remain == nil then
        return 1;
    end
    remain:SetTextByKey("value",remainTime)
    return 1;
end

function SET_BM_SCHEDULE(frame)
    local scheduleGbox = frame:GetChild("scheduleGbox");
    local schedule, cnt = GetClassList("black_market_schedule")
    if scheduleGbox == nil then
        return;
    end 
    if schedule == nil  then
        return;
    end
    scheduleGbox:RemoveAllChild();    
    local sysTime = geTime.GetServerSystemTime();
    local nowTime = string.format("%04d-%02d-%02d %02d:%02d:%02d", sysTime.wYear, sysTime.wMonth, sysTime.wDay, sysTime.wHour, sysTime.wMinute, sysTime.wSecond)
    local posY = 45;
    local OffsetY = 120;
    local number = 0;
    local MaxNumber = 100;
    for i = 0 , cnt - 1 do
        if number >= MaxNumber then
            break;
        end
        local cls = GetClassByIndexFromList(schedule, i)
        if cls ~= nil then
            local startTime = TryGetProp(cls, "start_datetime", "1999-01-01 00:00:00")
            local endTime = TryGetProp(cls, "end_datetime", "1999-01-01 00:00:00")
            local ItemClsName = TryGetProp(cls, "item_class_name", "None")
            local hammerpirce = TryGetProp(cls, "hammer_price", 0)
            
            local ret = date_time.is_later_than(startTime, nowTime)            
            if ret == true then
                local classCtrl = scheduleGbox:CreateOrGetControlSet('blackmarket_schedule', endTime, -30, posY + number * OffsetY);
                classCtrl:RunUpdateScript('BM_SCHEDULE_FRAME_UPDATE', 1)
                classCtrl:SetUserValue("ctrlStart",startTime)
                classCtrl:SetUserValue("ctrlEnd",endTime)

                local pic = GET_CHILD_RECURSIVELY(classCtrl,"pic")
                local name  = GET_CHILD_RECURSIVELY(classCtrl,"name")
                local duration  = GET_CHILD_RECURSIVELY(classCtrl,"duration")
                local remain = GET_CHILD_RECURSIVELY(classCtrl,"remain")

                local itemCls = GetClass("Item", ItemClsName)
                local itemName = TryGetProp(itemCls, "Name", "None");
                
                local diffsec = date_time.get_diff_sec(startTime,nowTime);
                if diffsec < 0 then
                    diffsec = 0
                end
                local remainTime = GET_TIME_TXT(diffsec)
                

                local icon = pic:GetIcon();
                if icon == nil then
                    icon = CreateIcon(pic);
                end
                if itemCls ~= nil then
                    local fullImage = GET_LEGENDEXPPOTION_ICON_IMAGE_FULL(itemCls);
                    icon:SetImage(fullImage)                    
                    SET_BALCK_MARKET_TOOLTIP(icon, itemCls)
                end 
                name:SetTextByKey("value",itemName);
                --슬라이드 on off
                if name:GetWidth() < name:GetTextWidth() then
                    name:EnableSlideShow(1)
                    name:SetCompareTextWidthBySlideShow(true);
                else
                    name:EnableSlideShow(0)
                    name:SetCompareTextWidthBySlideShow(false);
                end
            

                duration:SetTextByKey("start",startTime)
                duration:SetTextByKey("end",endTime)
                remain:SetTextByKey("value",remainTime)
                
                number = number + 1;
            end
        end
    end
end

function SET_BM_MY_AUCTION_STATE(frame, item_name, price, my_price, active_id)
    local myMarketGbox = GET_CHILD_RECURSIVELY(frame,"myMarketGbox")
    local myinfo = GET_CHILD_RECURSIVELY(myMarketGbox,"myinfo")
    local noinfo = GET_CHILD_RECURSIVELY(myMarketGbox,"noinfo")

    local money = GET_CHILD_RECURSIVELY(myinfo,"money")
    local myprice = GET_CHILD_RECURSIVELY(myinfo,"myprice")

    local itemCls = GetClass("Item", item_name)
    
    if active_id == 0 then
        myinfo:ShowWindow(0)
        noinfo:ShowWindow(1)
        return
    else
        myinfo:ShowWindow(1)
        noinfo:ShowWindow(0)
    end

    SET_BLACK_MARKET_ICON(myinfo, itemCls);
    SET_BALCK_MARKET_ITEM_NAME(myinfo,itemCls)
    SET_BM_PRICE(money,price)
    SET_BM_PRICE(myprice,my_price)
    if my_price == "0" then
        myinfo:ShowWindow(0)
        noinfo:ShowWindow(1)
    else
        myinfo:ShowWindow(1)
        noinfo:ShowWindow(0)
    end
end

function SET_BM_PRICE(ctrl, price)
    local SetPrice = GET_COMMAED_STRING(price)
    ctrl:SetTextByKey('value',SetPrice)
end