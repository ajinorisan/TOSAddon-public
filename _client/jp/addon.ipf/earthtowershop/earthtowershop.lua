local s_earth_shop_frame_name = ""
local s_earth_shop_parent_name = ""
local g_earth_shop_control_name = ""

local g_account_prop_shop_table = 
{
    ['PVPMine'] = 
    {
        ['coinName'] = 'misc_pvp_mine2',
        ['propName'] = 'MISC_PVP_MINE2',
    },
    ['SilverGachaShop'] = 
    {
        ['coinName'] = 'misc_silver_gacha_mileage',
        ['propName'] = 'Mileage_SilverGacha',
    },
    ['GabijaCertificate'] = 
    {
        ['coinName'] = 'dummy_GabijaCertificate',
        ['propName'] = 'GabijaCertificate',
    },
    ['VakarineCertificate'] = 
    {
        ['coinName'] = 'dummy_VakarineCertificate',
        ['propName'] = 'VakarineCertificate',
    },
    ['RadaCertificate'] = 
    {
        ['coinName'] = 'dummy_RadaCertificate',
        ['propName'] = 'RadaCertificate',
    },
    ['JurateCertificate'] = 
    {
        ['coinName'] = 'dummy_JurateCertificate',
        ['propName'] = 'JurateCertificate',
    },
    ['AustejaCertificate'] = 
    {
        ['coinName'] = 'dummy_AustejaCertificate',
        ['propName'] = 'AustejaCertificate',
    },
    ['TeamBattleLeagueShop'] = 
    {
        ['coinName'] = 'dummy_TeamBattleCoin',
        ['propName'] = 'TeamBattleCoin',
    },
    ['EVENT_TOS_WHOLE_SHOP'] =
    {
        ['coinName'] = 'Tos_Event_Coin',
        ['propName'] = 'EVENT_TOS_WHOLE_TOTAL_COIN'
    },
    ['EVENT_2304_ARBOR_DAY_SHOP'] =
    {
        ['coinName'] = 'Event_2304_ARBOR_DAY_coin'
    },
    ['EVENT_2312_8TH_ANNIVERSARY'] = 
    {
        ['coinName'] = 'Piece_Of_Memory_Snigo'
    },
    ['EVENT_2401_NEWYEAR'] =
    {
        ['coinName'] = "EVENT_2401_Newyear_Coin"
    },
    ['EVENT_2402_NEWYEAR'] =
    {
        ['coinName'] = "EVENT_2404_Old_Newyear_Coin"
    },
    ['EVENT_2404_W1TH'] = 
    {
        ['coinName'] = "EVENT_2404_W1th_Coin"
    },
    ['EVENT_2407_KUPOLE'] = 
    {
        ['coinName'] = "EVENT_2407_Coin"
    },
    ['EVENT_2410_MOONRISE'] = 
    {
        ['coinName'] = "EVENT_MOONRISE_2410"
    },
    ['EVENT_2410_MOONRISE_PAPAYA'] = 
    {
        ['coinName'] = "EVENT_MOONRISE_2410_PAPAYA"
    },
    ['event_2501_newyear'] = 
    {
        ['coinName'] = "Tos_Event_Platinum_Coin"
    }
}
--------------------------------------------------------------------------------------------------------------------------

local shop_list = {}
table.insert(shop_list, 'GabijaCertificate')
table.insert(shop_list, 'VakarineCertificate')
table.insert(shop_list, 'RadaCertificate')
table.insert(shop_list, 'JurateCertificate')
table.insert(shop_list, 'AustejaCertificate')
local shop_data = {}
local function _CLEAR_INFO(groupName, cls)
    shop_data = nil;
end

local function _ADD_INFO(groupName, cls)
    if shop_data == nil then
        shop_data = {}
    end

    if shop_data[groupName] == nil then
        shop_data[groupName] =
        {
            classList = {}
        }
    end

    local index = #shop_data[groupName].classList;
    shop_data[groupName].classList[index +1] = cls;
end

local function _GET_INFO(groupName)

    if shop_data == nil then
        return nil;
    end

    if shop_data[groupName] == nil then
        return nil;
    end

    return shop_data[groupName].classList;
end

local function _INSERT_ITEM_INFO(cls, shopType)
    local item = GetClass('Item', cls.TargetItem);
    if item == nil then
        return;
    end
    
    local groupName = item.GroupName;
    
    local item_category = TryGetProp(cls, 'ItemCategory', 'None')
    if item_category ~= 'None' then
        groupName = item_category;
    end

    local classType = nil;
    if GetPropType(item, "ClassType") ~= nil then
        classType = item.ClassType;
        if classType == 'None' then
            classType = nil
        end
    end

    EXCHANGE_MAKE_TAB_BTN(groupName) 
    _ADD_INFO(groupName, cls) 
end

local function _ADD_TAB_BTN_CTRL(bgCtrl, categoryName)

    if bgCtrl == nil then
		return;
    end    
    
    local ySpaceUnit = 1;
    local xSpaceUnit = 1;
    local xMargin = 30;
    local const_height = 44;
    local const_width = 120;
    
    
    local y = 0;
    local x = 0;
    local baseWidth = bgCtrl:GetWidth();
    local curLine =0;

    local findChild = bgCtrl:GetChild( "BTN_" .. categoryName );
    if findChild == nil then -- 검색해서 같은게 없으면 추가.
        local cnt = bgCtrl:GetChildCount();
        if cnt ~= 0 then
            local lastChild = bgCtrl:GetChildByIndex( cnt -1 );  -- 마지막 
            if lastChild ~= nil then -- 이게 없으면 안됨.
                tolua.cast(lastChild, "ui::CButton");
                local lastChildLine = lastChild:GetUserIValue('LINE');

                 -- 마지막 컨트롤 옆에 추가하는경우 baseWidth 를 넘어가는지 확인.
                 local lastWidth = lastChild:GetWidth();
                 local lastX = lastChild:GetX();
                 local lastHeight = lastChild:GetHeight();
                 local lastY = lastChild:GetY();

                curLine = lastChildLine;
                local checkX = lastX + lastWidth + xSpaceUnit;
                if checkX + const_width >= baseWidth then
                    -- 이경우 curLine을 증가 시키고 y값을 증가시킨다.
                    curLine = curLine +1;
                    y = lastY + lastHeight + ySpaceUnit;
                    x = xMargin;
                    
                    local compareHeight = ((curLine + 1) * const_height) + (curLine * ySpaceUnit ) + ySpaceUnit;
                    if bgCtrl:GetHeight() ~= compareHeight then
                        bgCtrl:Resize(bgCtrl:GetWidth(), compareHeight)
                    end

                else
                    x = lastX +lastWidth + xSpaceUnit;
                    y = lastY;
                end
            end
        else -- 맨처음 한번 온다.
            x = xMargin;
        end

        local mainCategory = ScpArgMsg(categoryName);
        local btn = bgCtrl:CreateOrGetControl('button', "BTN_" .. categoryName, x, y, const_width, const_height );
        tolua.cast(btn, "ui::CButton");
        btn:SetGravity(ui.LEFT, ui.TOP);
        btn:SetTextFixWidth(1);
        btn:EnableTextOmitByWidth(true);
        btn:SetSkinName("test_pvp_btn");
        btn:SetText(string.format("{@st66b}{s20}%s{/}", mainCategory));
        btn:SetTextTooltip(mainCategory);
        btn:SetUserValue("LINE", curLine);
        btn:SetUserValue("CATEGORY_NAME", categoryName);
        btn:SetEventScript(ui.LBUTTONUP, "CLICK_EXCHANGE_SHOP_CATEGORY");
        btn:SetEventScriptArgString(ui.LBUTTONUP, categoryName);
        
    end
end

--------------------------------------------------------------------------------------------------------------------------

function EARTHTOWERSHOP_ON_INIT(addon, frame)
    addon:RegisterMsg('EARTHTOWERSHOP_BUY_ITEM', 'EARTHTOWERSHOP_BUY_ITEM');
    addon:RegisterMsg('EARTHTOWERSHOP_BUY_ITEM_RESULT', 'EARTHTOWERSHOP_BUY_ITEM_RESULT');

    addon:RegisterMsg("EARTHTOWERSHOP_REMAIN_TIME", 'EARTHTOWERSHOP_REMAIN_TIME');
    addon:RegisterMsg("EARTHTOWERSHOP_CLOSE_SHOP_TYPE", 'EARTHTOWERSHOP_CLOSE_SHOP_TYPE');
end

function EARTHTOWERSHOP_BUY_ITEM_RESULT(frame, msg, argStr, argNum)
    local token = StringSplit(argStr, '/')
    local shopType = token[1]
    if g_account_prop_shop_table[shopType] == nil then
        return
    end

    local coinName = g_account_prop_shop_table[shopType]["coinName"]
    local propName = g_account_prop_shop_table[shopType]["propName"]
    if shopType == "PVPMine" then
        ui.SysMsg(ScpArgMsg("RESULT_MISC_PVP_MINE2", "count1", GET_COMMAED_STRING(token[2]), "count2", GET_COMMAED_STRING(token[3])));

        local propertyRemain = GET_CHILD_RECURSIVELY(frame,"propertyRemain")
        local itemCls = GetClass('Item', coinName)

        propertyRemain:SetTextByKey('itemName', itemCls.Name)
        propertyRemain:SetTextByKey('icon', "")

        local aObj = GetMyAccountObj()
        local count = TryGetProp(aObj, propName, '0')
        if count == 'None' then
            count = '0'
        end

        propertyRemain:SetTextByKey('itemCount', GET_COMMAED_STRING(count))

    elseif shopType == "SilverGachaShop" then
        ui.SysMsg(ScpArgMsg("SilverGachaShopResult", "count1", GET_COMMAED_STRING(token[2]), "count2", GET_COMMAED_STRING(token[3])));

        local propertyRemain = GET_CHILD_RECURSIVELY(frame,"propertyRemain")
        local itemCls = GetClass('Item', coinName)

        propertyRemain:SetTextByKey('itemName', itemCls.Name)
        propertyRemain:SetTextByKey('icon', "")
        local aObj = GetMyAccountObj()
        local count = TryGetProp(aObj, propName, '0')
        if count == 'None' then
            count = '0'
        end

        propertyRemain:SetTextByKey('itemCount', GET_COMMAED_STRING(count))
    elseif string.find(shopType, "Certificate") ~= nil then
        ui.SysMsg(ScpArgMsg("Result_" .. shopType, "count1", GET_COMMAED_STRING(token[2]), "count2", GET_COMMAED_STRING(token[3])));

        local propertyRemain = GET_CHILD_RECURSIVELY(frame,"propertyRemain")
        local itemCls = GetClass('Item', coinName)

        propertyRemain:SetTextByKey('itemName', itemCls.Name)
        propertyRemain:SetTextByKey('icon', "")
        local aObj = GetMyAccountObj()
        local count = TryGetProp(aObj, propName, '0')
        if count == 'None' then
            count = '0'
        end

        propertyRemain:SetTextByKey('itemCount', GET_COMMAED_STRING(count))
    elseif shopType == "EVENT_TOS_WHOLE_SHOP" then
        ui.SysMsg(ScpArgMsg("Result_" .. shopType, "count1", GET_COMMAED_STRING(token[2]), "count2", GET_COMMAED_STRING(token[3])));

        local propertyRemain = GET_CHILD_RECURSIVELY(frame,"propertyRemain")
        local itemCls = GetClass('Item', coinName)

        local clsmsg = ClMsg("REMAIN_COIN_EVENT_TOS_WHOLE_ICON")
        
        
        propertyRemain:SetTextByKey('itemName', itemCls.Name)
        propertyRemain:SetTextByKey('icon', clsmsg)

        local aObj = GetMyAccountObj()
        local count = TryGetProp(aObj, propName, '0')
        if count == 'None' then
            count = '0'
        end

        propertyRemain:SetTextByKey('itemCount', GET_COMMAED_STRING(count))   

    elseif shopType == "EVENT_2304_ARBOR_DAY_SHOP" then
        local propertyRemain = GET_CHILD_RECURSIVELY(frame,"propertyRemain")
        local itemCls = GetClass('Item', coinName)

        propertyRemain:SetTextByKey('itemName', itemCls.Name)
        propertyRemain:SetTextByKey('icon', "")
        local count = GetInvItemCount(GetMyPCObject(), coinName)
        if count == 'None' then
            count = '0'
        end
        propertyRemain:SetTextByKey('itemCount', GET_COMMAED_STRING(count))
    elseif shopType == "EVENT_2310_KLAPEDA_GHOST_SHOP" then
        local propertyRemain = GET_CHILD_RECURSIVELY(frame,"propertyRemain")
        local itemCls = GetClass('Item', coinName)

        propertyRemain:SetTextByKey('itemName', itemCls.Name)
        propertyRemain:SetTextByKey('icon', "")
        local count = GetInvItemCount(GetMyPCObject(), coinName)
        if count == 'None' then
            count = '0'
        end
        propertyRemain:SetTextByKey('itemCount', GET_COMMAED_STRING(count))
    elseif shopType == "EVENT_2310_KLAPEDA_GHOST_SHOP_W" then
        local propertyRemain = GET_CHILD_RECURSIVELY(frame,"propertyRemain")
        local itemCls = GetClass('Item', coinName)

        propertyRemain:SetTextByKey('itemName', itemCls.Name)
        propertyRemain:SetTextByKey('icon', "")
        local count = GetInvItemCount(GetMyPCObject(), coinName)
        if count == 'None' then
            count = '0'
        end
        propertyRemain:SetTextByKey('itemCount', GET_COMMAED_STRING(count))
        
    elseif shopType == "EVENT_2312_8TH_ANNIVERSARY" then
        local propertyRemain = GET_CHILD_RECURSIVELY(frame,"propertyRemain")
        local itemCls = GetClass('Item', coinName)

        propertyRemain:SetTextByKey('itemName', itemCls.Name)
        propertyRemain:SetTextByKey('icon', "")
        local count = GetInvItemCount(GetMyPCObject(), coinName)
        if count == 'None' then
            count = '0'
        end
        propertyRemain:SetTextByKey('itemCount', GET_COMMAED_STRING(count))
    elseif shopType == "EVENT_2401_NEWYEAR" then
        local propertyRemain = GET_CHILD_RECURSIVELY(frame,"propertyRemain")
        local itemCls = GetClass('Item', coinName)

        propertyRemain:SetTextByKey('itemName', itemCls.Name)
        propertyRemain:SetTextByKey('icon', "")
        local count = GetInvItemCount(GetMyPCObject(), coinName)
        if count == 'None' then
            count = '0'
        end
        propertyRemain:SetTextByKey('itemCount', GET_COMMAED_STRING(count))
    elseif shopType == "EVENT_2402_NEWYEAR" then
        local propertyRemain = GET_CHILD_RECURSIVELY(frame,"propertyRemain")
        local itemCls = GetClass('Item', coinName)

        propertyRemain:SetTextByKey('itemName', itemCls.Name)
        propertyRemain:SetTextByKey('icon', "")
        local count = GetInvItemCount(GetMyPCObject(), coinName)
        if count == 'None' then
            count = '0'
        end
        propertyRemain:SetTextByKey('itemCount', GET_COMMAED_STRING(count))
    elseif shopType == "EVENT_2404_W1TH" then
        local propertyRemain = GET_CHILD_RECURSIVELY(frame,"propertyRemain")
        local itemCls = GetClass('Item', coinName)

        propertyRemain:SetTextByKey('itemName', itemCls.Name)
        propertyRemain:SetTextByKey('icon', "")
        local count = GetInvItemCount(GetMyPCObject(), coinName)
        if count == 'None' then
            count = '0'
        end
        propertyRemain:SetTextByKey('itemCount', GET_COMMAED_STRING(count))
    elseif shopType == "EVENT_2407_KUPOLE" then
        local propertyRemain = GET_CHILD_RECURSIVELY(frame,"propertyRemain")
        local itemCls = GetClass('Item', coinName)
        if itemCls ~= nil then
            propertyRemain:SetTextByKey('icon', ClMsg("EVENT_COIN_MSG"));
            propertyRemain:SetTextByKey('itemName', "")
            local count = GetInvItemCount(GetMyPCObject(), coinName)
            if count == 'None' then
                count = '0'
            end
            propertyRemain:SetTextByKey('itemCount', GET_COMMAED_STRING(count))
        end
    elseif shopType == "EVENT_2410_MOONRISE" then
        local propertyRemain = GET_CHILD_RECURSIVELY(frame,"propertyRemain")
        local itemCls = GetClass('Item', coinName)
        if itemCls ~= nil then
            propertyRemain:SetTextByKey('icon', ClMsg("EVENT_COIN_MSG"));
            propertyRemain:SetTextByKey('itemName', "")
            local count = GetInvItemCount(GetMyPCObject(), coinName)
            if count == 'None' then
                count = '0'
            end
            propertyRemain:SetTextByKey('itemCount', GET_COMMAED_STRING(count))
        end 
    elseif shopType == "EVENT_2410_LEAVES" then
        local propertyRemain = GET_CHILD_RECURSIVELY(frame,"propertyRemain")
        local itemCls = GetClass('Item', coinName)
        if itemCls ~= nil then
            propertyRemain:SetTextByKey('icon', ClMsg("EVENT_COIN_MSG"));
            propertyRemain:SetTextByKey('itemName', "")
            local count = GetInvItemCount(GetMyPCObject(), coinName)
            if count == 'None' then
                count = '0'
            end
            propertyRemain:SetTextByKey('itemCount', GET_COMMAED_STRING(count))
        end 
    elseif shopType == "EVENT_W_MOON_SHOP" then
        local propertyRemain = GET_CHILD_RECURSIVELY(frame,"propertyRemain")
        local itemCls = GetClass('Item', coinName)

        propertyRemain:SetTextByKey('itemName', itemCls.Name)
        propertyRemain:SetTextByKey('icon', "")
        local count = GetInvItemCount(GetMyPCObject(), coinName)
        if count == 'None' then
            count = '0'
        end
        propertyRemain:SetTextByKey('itemCount', GET_COMMAED_STRING(count))
    elseif shopType == "event_2501_newyear" then
        local propertyRemain = GET_CHILD_RECURSIVELY(frame,"propertyRemain")
        local itemCls = GetClass('Item', coinName)

        propertyRemain:SetTextByKey('itemName', itemCls.Name)
        propertyRemain:SetTextByKey('icon', "")
        local count = GetInvItemCount(GetMyPCObject(), coinName)
        if count == 'None' then
            count = '0'
        end
        propertyRemain:SetTextByKey('itemCount', GET_COMMAED_STRING(count))

    end
end

function EARTHTOWERSHOP_BUY_ITEM(frame, msg, itemName, itemCount)    
	local controlFrame = ui.GetFrame(s_earth_shop_frame_name);
	if controlFrame == nil then
		return
	end

    local parent = GET_CHILD_RECURSIVELY(controlFrame, s_earth_shop_parent_name);
	local control = GET_CHILD_RECURSIVELY(parent, g_earth_shop_control_name);
	if control == nil or parent == nil then
		return
	end

    local ctrlset = parent;
    local recipecls = GetClass('ItemTradeShop', ctrlset:GetName());
    local exchangeCountText = GET_CHILD(ctrlset, "exchangeCount");
	if recipecls.NeedProperty ~= 'None' then
		local sObj = GetSessionObject(GetMyPCObject(), "ssn_shop");
		local sCount = TryGetProp(sObj, recipecls.NeedProperty); 
		local cntText = string.format("%d", sCount).. ScpArgMsg("Excnaged_Count_Remind");
		local tradeBtn = GET_CHILD(ctrlset, "tradeBtn");
		if sCount <= 0 then
			cntText = ScpArgMsg("Excnaged_No_Enough");
			tradeBtn:SetColorTone("FF444444");
			tradeBtn:SetEnable(0);
		end;
		exchangeCountText:SetTextByKey("value", cntText);
	end;
	
	if recipecls.AccountNeedProperty ~= 'None' then
	    local aObj = GetMyAccountObj()
        local sCount = TryGetProp(aObj, recipecls.AccountNeedProperty); 
		local cntText
		if recipecls.ShopType == "PVPMine" then
			if recipecls.ResetInterval == 'Week' then
				cntText = ScpArgMsg("Excnaged_AccountCount_Remind_Week","COUNT",string.format("%d", sCount))
			else
				cntText = ScpArgMsg("Excnaged_AccountCount_Remind_Day","COUNT",string.format("%d", sCount))
			end
        elseif recipecls.ShopType == "EVENT_TOS_WHOLE_SHOP" then
            if recipecls.ResetInterval == 'Month' then    
                cntText = ScpArgMsg("Excnaged_AccountCount_Remind_Month","COUNT",string.format("%d", sCount))
            elseif recipecls.ResetInterval == 'Week' then
                cntText = ScpArgMsg("Excnaged_AccountCount_Remind_Week","COUNT",string.format("%d", sCount))
            elseif recipecls.ResetInterval == 'Day' then
                cntText = ScpArgMsg("Excnaged_AccountCount_Remind_Day","COUNT",string.format("%d", sCount))
            end
		else
			cntText = ScpArgMsg("Excnaged_AccountCount_Remind","COUNT",string.format("%d", sCount))
		end
        local tradeBtn = GET_CHILD(ctrlset, "tradeBtn");
        if sCount <= 0 then
            if TryGetProp(recipecls, 'MaxOverBuyCount', 0) > 0 then
                local overbuy_prop = TryGetProp(recipecls, 'OverBuyProperty', 'None')          
                local overbuy_count = TryGetProp(aObj, overbuy_prop, 0)          
                
                if overbuy_prop ~= 'None' then
                    if recipecls.ResetInterval == 'Week' then
                        cntText = ScpArgMsg("OverBuyCount{count}_Week{max}","count", overbuy_count, 'max', TryGetProp(recipecls, 'MaxOverBuyCount', 100) )
                    elseif recipecls.ResetInterval == 'Day' then
                        cntText = ScpArgMsg("OverBuyCount{count}_Day{max}","count", overbuy_count, 'max', TryGetProp(recipecls, 'MaxOverBuyCount', 100) )
                    end
                end
                
                if overbuy_count >= TryGetProp(recipecls, 'MaxOverBuyCount', 100) then
                    cntText = ScpArgMsg("Excnaged_No_Enough");
                    tradeBtn:SetColorTone("FF444444");
                    tradeBtn:SetEnable(0);
                end
            else
            cntText = ScpArgMsg("Excnaged_No_Enough");
            tradeBtn:SetColorTone("FF444444");
            tradeBtn:SetEnable(0);
        end
        end
        
        exchangeCountText:SetTextByKey("value", cntText);
    end

    local shopType = frame:GetUserValue("SHOP_TYPE");
    if shopType == "EVENT_2011_5TH_Normal_Shop" or 
        string.find(shopType, "EVENT_2011_5TH_Special_Shop") ~= nil then
        local ctrlSet = GET_CHILD_RECURSIVELY(frame, "EVENT_CONTROL_SET");
    
        local coinTOS_text = GET_CHILD(ctrlSet, "coinTOS_text", "ui::CRichText");
        local coinTOS_count = GET_INV_ITEM_COUNT_BY_PROPERTY({{Name = "ClassName", Value = "Event_2011_TOS_Coin"}}, false);
        coinTOS_text:SetTextByKey("value", coinTOS_count);

        local coin5TH_text = GET_CHILD(ctrlSet, "coin5TH_text", "ui::CRichText");
        local coin5TH_count = GET_INV_ITEM_COUNT_BY_PROPERTY({{Name = "ClassName", Value = "Event_2011_5th_Coin"}}, false);
        coin5TH_text:SetTextByKey("value", coin5TH_count);
    end
end

function EARTHTOWERSHOP_REMAIN_TIME(frame, msg, argStr, remaintime)
    local remain_time = GET_CHILD_RECURSIVELY(frame, "remain_time")
    remain_time:SetTextByKey("value", remaintime);

	frame:SetUserValue("REMAINSEC", remaintime);
	frame:SetUserValue("STARTSEC", math.floor(imcTime.GetAppTime()));
    frame:RunUpdateScript("EARTHTOWERSHOP_REMAIN_TIME_UPDATE", 0, 0, 0, 1);
    EARTHTOWERSHOP_REMAIN_TIME_UPDATE(frame)
end

function EARTHTOWERSHOP_REMAIN_TIME_UPDATE(frame)
    local startsec = frame:GetUserValue("STARTSEC");
    local remainsec = frame:GetUserValue("REMAINSEC");

    local difsec = imcTime.GetAppTime() - startsec;
    local remainTime = math.floor(remainsec - difsec);
    
    local remain_time = GET_CHILD_RECURSIVELY(frame, "remain_time");

    if remainTime < 0 then
        remain_time:SetTextByKey("value", 0);
        return 0;
    end

    remain_time:SetTextByKey("value", remainTime);

    return 1;
end

function EARTHTOWERSHOP_CLOSE_SHOP_TYPE(frame, msg, argStr, argNum)
    local shopType = frame:GetUserValue("SHOP_TYPE");
    if string.find(shopType, argStr) ~= nil then
        frame:ShowWindow(0);
    end
end

function REQ_EARTH_TOWER_SHOP_OPEN()

    local frame = ui.GetFrame("earthtowershop");
    frame:SetUserValue("SHOP_TYPE", 'EarthTower');
    ui.OpenFrame('earthtowershop');
end

function REQ_EARTH_TOWER2_SHOP_OPEN()

    local frame = ui.GetFrame("earthtowershop");
    frame:SetUserValue("SHOP_TYPE", 'EarthTower2');
    ui.OpenFrame('earthtowershop');
end

function REQ_EVENT_ITEM_SHOP_OPEN()
    local frame = ui.GetFrame("earthtowershop");
    frame:SetUserValue("SHOP_TYPE", 'EventShop');
    ui.OpenFrame('earthtowershop');
end

function REQ_EVENT_ITEM_SHOP2_OPEN()
    local frame = ui.GetFrame("earthtowershop");
    frame:SetUserValue("SHOP_TYPE", 'EventShop2');
    ui.OpenFrame('earthtowershop');
end

function REQ_EVENT_ITEM_SHOP3_OPEN()
    local frame = ui.GetFrame("earthtowershop");
    frame:SetUserValue("SHOP_TYPE", 'EventShop3');
    ui.OpenFrame('earthtowershop');
end

function REQ_KEY_QUEST_TRADE_HETHRAN_LV1_OPEN()
    local frame = ui.GetFrame("earthtowershop");
    frame:SetUserValue("SHOP_TYPE", 'KeyQuestShop1');
    ui.OpenFrame('earthtowershop');
end

function REQ_KEY_QUEST_TRADE_HETHRAN_LV2_OPEN()
    local frame = ui.GetFrame("earthtowershop");
    frame:SetUserValue("SHOP_TYPE", 'KeyQuestShop2');
    ui.OpenFrame('earthtowershop');
end

function HALLOWEEN_EVENT_ITEM_SHOP_OPEN()
    local frame = ui.GetFrame("earthtowershop");
    frame:SetUserValue("SHOP_TYPE", 'HALLOWEEN');
    ui.OpenFrame('earthtowershop');
end

function REQ_EVENT_ITEM_SHOP8_OPEN()
    local frame = ui.GetFrame("earthtowershop");
    frame:SetUserValue("SHOP_TYPE", 'EventShop8');
    ui.OpenFrame('earthtowershop');
end

function REQ_PVP_MINE_SHOP_OPEN()
    local frame = ui.GetFrame("earthtowershop");
    frame:SetUserValue("SHOP_TYPE", 'PVPMine');
    ui.OpenFrame('earthtowershop');
end

function REQ_GabijaCertificate_SHOP_OPEN()
    local frame = ui.GetFrame("earthtowershop");
    frame:SetUserValue("SHOP_TYPE", 'GabijaCertificate');
    ui.OpenFrame('earthtowershop');
end

function REQ_VakarineCertificate_SHOP_OPEN()
    local frame = ui.GetFrame("earthtowershop");
    frame:SetUserValue("SHOP_TYPE", 'VakarineCertificate');
    ui.OpenFrame('earthtowershop');
end

function REQ_RadaCertificate_SHOP_OPEN()
    local frame = ui.GetFrame("earthtowershop");
    frame:SetUserValue("SHOP_TYPE", 'RadaCertificate');
    ui.OpenFrame('earthtowershop');
end

function REQ_JurateCertificate_SHOP_OPEN()
    local frame = ui.GetFrame("earthtowershop");
    frame:SetUserValue("SHOP_TYPE", 'JurateCertificate');
    ui.OpenFrame('earthtowershop');
end

function REQ_AustejaCertificate_SHOP_OPEN()
    local frame = ui.GetFrame("earthtowershop");
    frame:SetUserValue("SHOP_TYPE", 'AustejaCertificate');
    ui.OpenFrame('earthtowershop');
end



function REQ_MASSIVE_CONTENTS_SHOP1_OPEN()
    local frame = ui.GetFrame("earthtowershop");
    frame:SetUserValue("SHOP_TYPE", 'MCShop1');
    ui.OpenFrame('earthtowershop');
end

function REQ_SoloDungeon_Bernice_SHOP_OPEN()
    local frame = ui.GetFrame("earthtowershop");
    frame:SetUserValue("SHOP_TYPE", 'Bernice');
    ui.OpenFrame('earthtowershop');
end

function REQ_DAILY_REWARD_SHOP_1_OPEN()
    local frame = ui.GetFrame("earthtowershop");
    if IS_SEASON_SERVER() == 'YES' then
        frame:SetUserValue("SHOP_TYPE", 'DailyRewardShop_Season');
    else
        frame:SetUserValue("SHOP_TYPE", 'DailyRewardShop');
    end
    ui.OpenFrame('earthtowershop');
end

function REQ_NEW_CHAR_SHOP_1_OPEN()
--    local frame = ui.GetFrame("earthtowershop");
--    frame:SetUserValue("SHOP_TYPE", 'NewChar');
--    ui.OpenFrame('earthtowershop');
end

function REQ_VIVID_CITY2_SHOP_OPEN()
    local frame = ui.GetFrame("earthtowershop");
    frame:SetUserValue("SHOP_TYPE", 'VividCity2_Shop');
    ui.OpenFrame('earthtowershop');
end

function REQ_EVENT1906_TOTAL_SHOP_OPEN()
--    local frame = ui.GetFrame("earthtowershop");
--    frame:SetUserValue("SHOP_TYPE", 'EventTotalShop1906');
--    ui.OpenFrame('earthtowershop');
end


function REQ_EVENT1907_ICE_SHOP_OPEN()
--    local frame = ui.GetFrame("earthtowershop");
--    frame:SetUserValue("SHOP_TYPE", 'EventIceShop1907');
--    ui.OpenFrame('earthtowershop');
end

function REQ_EVENT_1909_MINI_FULLMOON_SHOP_OPEN()
--    local frame = ui.GetFrame("earthtowershop");
--    frame:SetUserValue("SHOP_TYPE", 'EventMiniMoonShop1909');
--    ui.OpenFrame('earthtowershop');
end

function REQ_EVENT_1910_HALLOWEEN_SHOP_OPEN()
        -- local frame = ui.GetFrame("earthtowershop");
        -- frame:SetUserValue("SHOP_TYPE", 'HalloweenShop');
        -- ui.OpenFrame('earthtowershop');
end

function REQ_EVENT1912_4TH_SHOP_OPEN()
--    local frame = ui.GetFrame("earthtowershop");
--    frame:SetUserValue("SHOP_TYPE", 'Event4thShop1912');
--    ui.OpenFrame('earthtowershop');
end

function REQ_SELL_TPSHOP1912_SHOP_OPEN()
    local frame = ui.GetFrame("earthtowershop");
    frame:SetUserValue("SHOP_TYPE", 'Sell_TPShop1912');
    ui.OpenFrame('earthtowershop');
end

function REQ_BUY_TPSHOP1912_SHOP_OPEN()
    local frame = ui.GetFrame("earthtowershop");
    frame:SetUserValue("SHOP_TYPE", 'Buy_TPShop1912');
    ui.OpenFrame('earthtowershop');
end

function REQ_EVENT1912_GREWUP_SHOP_OPEN()
--    local frame = ui.GetFrame("earthtowershop");
--    frame:SetUserValue("SHOP_TYPE", 'GrewUpShop');
--    ui.OpenFrame('earthtowershop');
end

function REQ_EVENT_2001_NEWYEAR_SHOP_OPEN()
    local frame = ui.GetFrame("earthtowershop");
    frame:SetUserValue("SHOP_TYPE", 'NewYearShop');
    ui.OpenFrame('earthtowershop');
end

function REQ_EVENT_2002_FISHING_SHOP_OPEN()
    -- local frame = ui.GetFrame("earthtowershop");
    -- frame:SetUserValue("SHOP_TYPE", 'FishingShop2002');
    -- ui.OpenFrame('earthtowershop');
end

function REQ_TEAM_BATTLE_SHOP_OPEN()
    local frame = ui.GetFrame("earthtowershop");
    frame:SetUserValue("SHOP_TYPE", 'TeamBattleLeagueShop');
    ui.OpenFrame('earthtowershop');
end

function REQ_COMMON_SKILL_ENCHANT_UI_OPEN()
    ui.OpenFrame('common_skill_enchant');
end

function REQ_COMMON_ACC_UPGRADE_UI_OPEN()
    ui.OpenFrame('common_acc_upgrade');
end


function REQ_EVENT_SHOP_OPEN_COMMON(shopType)
    ui.CloseFrame('earthtowershop');

    local frame = ui.GetFrame("earthtowershop");
    frame:SetUserValue("SHOP_TYPE", shopType);
    ui.OpenFrame('earthtowershop');
end

function REQ_SILVER_GACHA_SHOP_OPEN()
    local frame = ui.GetFrame("earthtowershop");
    frame:SetUserValue("SHOP_TYPE", "SilverGachaShop");
    ui.OpenFrame('earthtowershop');
end

function EARTH_TOWER_SHOP_OPEN(frame)
    if frame == nil then
        frame = ui.GetFrame("earthtowershop")
    end
    
    local shopType = frame:GetUserValue("SHOP_TYPE");
    if shopType == 'None' then
        shopType = "EarthTower";
        frame:SetUserValue("SHOP_TYPE", shopType);
    end

    EARTH_TOWER_INIT(frame, shopType)

    local bg = GET_CHILD(frame, "bg", "ui::CGroupBox");
    bg:ShowWindow(1);

    local article = GET_CHILD(frame, 'recipe', "ui::CGroupBox");
    if article ~= nil then
        article:ShowWindow(0)
    end

    local bg = GET_CHILD(frame, "bg", "ui::CGroupBox");
    bg:ShowWindow(0);
    
    local group = GET_CHILD(frame, 'Recipe', 'ui::CGroupBox')
    group:ShowWindow(1)
    imcSound.PlaySoundEvent('button_click_3');


    session.ResetItemList();
end

function EARTH_TOWER_SHOP_OPTION(frame, ctrl)
    session.ResetItemList();
    frame = frame:GetTopParentFrame();
    local shopType = frame:GetUserValue("SHOP_TYPE");
    EARTH_TOWER_INIT(frame, shopType);
end

function EARTH_TOWER_INIT(frame, shopType)    

    EXCHANGE_INIT_TAB_INFO();

    INVENTORY_SET_CUSTOM_RBTNDOWN("None");
    RESET_INVENTORY_ICON();
   
    local propertyRemain = GET_CHILD_RECURSIVELY(frame,"propertyRemain")
    local pointbuyBtn = GET_CHILD_RECURSIVELY(frame,"pointbuyBtn")
    local prevShopBtn = GET_CHILD_RECURSIVELY(frame,"prevShopBtn")
    local event_gb = GET_CHILD_RECURSIVELY(frame, "event_gb")
    local remain_time = GET_CHILD_RECURSIVELY(frame, "remain_time")
    local catuion = GET_CHILD_RECURSIVELY(frame, "catuion");

    catuion:ShowWindow(0);
    propertyRemain:ShowWindow(0)
    pointbuyBtn:ShowWindow(0)
    prevShopBtn:ShowWindow(0)
    
    remain_time:ShowWindow(0)

    pointbuyBtn:SetTextByKey("name", ScpArgMsg("pointextract"))
    if shopType ~= "EVENT_2011_5TH_Normal_Shop" and string.find(shopType, "EVENT_2011_5TH_Special_Shop") == nil then
        event_gb:RemoveAllChild();
        event_gb:ShowWindow(0);
    end

    local resetDatetime = GET_CHILD_RECURSIVELY(frame, 'resetDatetime')
    if resetDatetime ~= nil then
        resetDatetime:ShowWindow(0)
    end

    local title = GET_CHILD(frame, 'title', 'ui::CRichText')
    local close = GET_CHILD(frame, 'close');
    if shopType == 'EarthTower' or shopType == 'EarthTower2' then
        title:SetText('{@st43}'..ScpArgMsg("EarthTowerShop"));
        close:SetTextTooltip(ScpArgMsg('CloseUI{NAME}', 'NAME', ScpArgMsg("EarthTowerShop")));
    elseif shopType == 'EventShop' or shopType == 'EventShop2' or shopType == 'EventShop3' then
        title:SetText('{@st43}'..ScpArgMsg("EventShop"));
        close:SetTextTooltip(ScpArgMsg('CloseUI{NAME}', 'NAME', ScpArgMsg("EventShop")));
    elseif shopType == 'KeyQuestShop1' then
        title:SetText('{@st43}'..ScpArgMsg("KeyQuestShopTitle1"));
        close:SetTextTooltip(ScpArgMsg('CloseUI{NAME}', 'NAME', ScpArgMsg("KeyQuestShopTitle1")));
    elseif shopType == 'KeyQuestShop2' then
        title:SetText('{@st43}'..ScpArgMsg("KeyQuestShopTitle2"));
        close:SetTextTooltip(ScpArgMsg('CloseUI{NAME}', 'NAME', ScpArgMsg("KeyQuestShopTitle2")));
    elseif shopType == 'HALLOWEEN' then
        title:SetText('{@st43}'..ScpArgMsg("EVENT_HALLOWEEN_SHOP_NAME"));
        close:SetTextTooltip(ScpArgMsg('CloseUI{NAME}', 'NAME', ScpArgMsg("EVENT_HALLOWEEN_SHOP_NAME")));
    elseif shopType == 'PVPMine' then
        title:SetText('{@st43}'..ScpArgMsg("pvp_mine_shop_name"));
        close:SetTextTooltip(ScpArgMsg('CloseUI{NAME}', 'NAME', ScpArgMsg("pvp_mine_shop_name")));
        if resetDatetime ~= nil then
            resetDatetime:SetText(ClMsg('PVPMineShopWeeklyResetDateTime'))
            resetDatetime:ShowWindow(1)
        end
        EARTH_TOWER_SET_PROPERTY_COUNT(propertyRemain, 'misc_pvp_mine2', "MISC_PVP_MINE2")    
    elseif shopType == 'MCShop1' then
        title:SetText('{@st43}'..ScpArgMsg("MASSIVE_CONTENTS_SHOP_NAME"));
        close:SetTextTooltip(ScpArgMsg('CloseUI{NAME}', 'NAME', ScpArgMsg("MASSIVE_CONTENTS_SHOP_NAME")));
    elseif shopType == 'EventShop8' then
        local taltPropCls = GetClassByType('Anchor_c_Klaipe', 5187);
        title:SetText('{@st43}'..taltPropCls.Name);
        close:SetTextTooltip(ScpArgMsg('CloseUI{NAME}', 'NAME', taltPropCls.Name));
    elseif shopType == 'DailyRewardShop' or shopType == 'DailyRewardShop_Season' then
        title:SetText('{@st43}'..ScpArgMsg("DAILY_REWARD_SHOP_1"));
        close:SetTextTooltip(ScpArgMsg('CloseUI{NAME}', 'NAME', ScpArgMsg("DAILY_REWARD_SHOP_1")));
    elseif shopType == 'Bernice' then
        title:SetText('{@st43}'..ScpArgMsg("SoloDungeonSelectMsg_5"));
        close:SetTextTooltip(ScpArgMsg('CloseUI{NAME}', 'NAME', ScpArgMsg("SoloDungeonSelectMsg_5")));
    elseif shopType == 'NewChar' then
        title:SetText('{@st43}'..ScpArgMsg("NEW_CHAR_SHOP_1"));
        close:SetTextTooltip(ScpArgMsg('CloseUI{NAME}', 'NAME', ScpArgMsg("NEW_CHAR_SHOP_1")));
    elseif shopType == 'VividCity2_Shop' then
        title:SetText('{@st43}'..ScpArgMsg("EventShop"));
        close:SetTextTooltip(ScpArgMsg('CloseUI{NAME}', 'NAME', ScpArgMsg("EventShop")));
    elseif shopType == 'EventTotalShop1906' then
        title:SetText('{@st43}'..ScpArgMsg("EventShop"));
        close:SetTextTooltip(ScpArgMsg('CloseUI{NAME}', 'NAME', ScpArgMsg("EventShop")));
    elseif shopType == 'EventIceShop1907' then
--        title:SetText('{@st43}'..ScpArgMsg("EventShop"));
--        close:SetTextTooltip(ScpArgMsg('CloseUI{NAME}', 'NAME', ScpArgMsg("EVENT_1907_ICESHOP_TITLE_NAME_1")));
    elseif shopType == 'EventMiniMoonShop1909' then
--        title:SetText('{@st43}'..ScpArgMsg("EventMiniMoonShop1909_TITLE_NAME_1"));
--        close:SetTextTooltip(ScpArgMsg('CloseUI{NAME}', 'NAME', ScpArgMsg("EventMiniMoonShop1909_TITLE_NAME_1")));
    elseif shopType == 'HalloweenShop' then
        -- title:SetText('{@st43}'..ScpArgMsg("EVENT_1910_HALLOWEEN_SHOP"));
        -- close:SetTextTooltip(ScpArgMsg('CloseUI{NAME}', 'NAME', ScpArgMsg("EventShop")));
    elseif shopType == 'Event4thShop1912' then
        title:SetText('{@st43}'..ScpArgMsg("Event4thShop1912_TITLE_NAME_1"));
        close:SetTextTooltip(ScpArgMsg('CloseUI{NAME}', 'NAME', ScpArgMsg("Event4thShop1912_TITLE_NAME_1")));
    elseif shopType == 'Sell_TPShop1912' then
        title:SetText('{@st43}'..ScpArgMsg("TP_201912_Wing_change"));
        close:SetTextTooltip(ScpArgMsg('CloseUI{NAME}', 'NAME', ScpArgMsg("TP_201912_Wing_change")));
    elseif shopType == 'Buy_TPShop1912' then
        title:SetText('{@st43}'..ScpArgMsg("TP_201912_fur_change"));
        close:SetTextTooltip(ScpArgMsg('CloseUI{NAME}', 'NAME', ScpArgMsg("TP_201912_fur_change")));
--    elseif shopType == 'GrewUpShop' then
--        title:SetText('{@st43}'..ScpArgMsg("NEW_CHAR_SHOP_1"));
--        close:SetTextTooltip(ScpArgMsg('CloseUI{NAME}', 'NAME', ScpArgMsg("NEW_CHAR_SHOP_1")));
    elseif shopType == 'NewYearShop' then
        title:SetText('{@st43}'..ScpArgMsg("EVENT_2001_NEWYEAR_SHOP"));
        close:SetTextTooltip(ScpArgMsg('CloseUI{NAME}', 'NAME', ScpArgMsg("EventShop")));
    elseif shopType == 'TeamBattleLeagueShop' then
        title:SetText('{@st43}'..ScpArgMsg("TEAMBATTLEShop"));
        close:SetTextTooltip(ScpArgMsg('CloseUI{NAME}', 'NAME', ScpArgMsg("TEAMBATTLEShop")));
    elseif shopType == 'FishingShop2002' then
        -- title:SetText('{@st43}'..ScpArgMsg("EVENT_2002_FISHING_SHOP"));
        -- close:SetTextTooltip(ScpArgMsg('CloseUI{NAME}', 'NAME', ScpArgMsg("EventShop")));
    elseif shopType == "SilverGachaShop" then
        title:SetText('{@st43}'..ScpArgMsg("SilverGachaShopName"));
        close:SetTextTooltip(ScpArgMsg('CloseUI{NAME}', 'NAME', ScpArgMsg("SilverGachaShopName")));
        EARTH_TOWER_SET_PROPERTY_COUNT(propertyRemain, 'misc_silver_gacha_mileage', "Mileage_SilverGacha")
        pointbuyBtn:ShowWindow(1)
    elseif shopType == "EVENT_2011_5TH_Normal_Shop" then
        title:SetText('{@st43}'..ScpArgMsg(shopType));
        close:SetTextTooltip(ScpArgMsg('CloseUI{NAME}', 'NAME', ScpArgMsg("EventShop")));

        local ctrlSet = event_gb:CreateOrGetControlSet("event_5th_special_shop_controlset", "EVENT_CONTROL_SET", 0, 0);        

        local coinTOS = GetClass("Item", "Event_2011_TOS_Coin");
        local coinTOS_text = GET_CHILD(ctrlSet, "coinTOS_text", "ui::CRichText");
        local coinTOS_count = GET_INV_ITEM_COUNT_BY_PROPERTY({{Name = "ClassName", Value = "Event_2011_TOS_Coin"}}, false);
        coinTOS_text:SetTextByKey("name", coinTOS.Name);
        coinTOS_text:SetTextByKey("value", coinTOS_count);

        local coin5TH = GetClass("Item", "Event_2011_5th_Coin");
        local coin5TH_text = GET_CHILD(ctrlSet, "coin5TH_text", "ui::CRichText");
        local coin5TH_count = GET_INV_ITEM_COUNT_BY_PROPERTY({{Name = "ClassName", Value = "Event_2011_5th_Coin"}}, false);
        coin5TH_text:SetTextByKey("name", coin5TH.Name);
        coin5TH_text:SetTextByKey("value", coin5TH_count);

        local btn = GET_CHILD(ctrlSet, "update_Btn");
        btn:ShowWindow(0);

        event_gb:ShowWindow(1);
    elseif string.find(shopType, "EVENT_2011_5TH_Special_Shop") ~= nil then
        local common, shopStr = string.match(shopType,'(EVENT_2011_5TH_Special_Shop_)(.+)');
        local shopStrlist = StringSplit(shopStr, "_");
        local grade = shopStrlist[1];

        title:SetText('{@st43}'..ScpArgMsg("EVENT_2011_5TH_Special_Shop_name{GRADE}", "GRADE", grade));
        close:SetTextTooltip(ScpArgMsg('CloseUI{NAME}', 'NAME', ScpArgMsg("EventShop")));

        local ctrlSet = event_gb:CreateOrGetControlSet("event_5th_special_shop_controlset", "EVENT_CONTROL_SET", 0, 0);
        
        local coinTOS = GetClass("Item", "Event_2011_TOS_Coin");
        local coinTOS_text = GET_CHILD(ctrlSet, "coinTOS_text", "ui::CRichText");
        local coinTOS_count = GET_INV_ITEM_COUNT_BY_PROPERTY({{Name = "ClassName", Value = "Event_2011_TOS_Coin"}}, false);
        coinTOS_text:SetTextByKey("name", coinTOS.Name);
        coinTOS_text:SetTextByKey("value", coinTOS_count);

        local coin5TH = GetClass("Item", "Event_2011_5th_Coin");
        local coin5TH_text = GET_CHILD(ctrlSet, "coin5TH_text", "ui::CRichText");
        local coin5TH_count = GET_INV_ITEM_COUNT_BY_PROPERTY({{Name = "ClassName", Value = "Event_2011_5th_Coin"}}, false);
        coin5TH_text:SetTextByKey("name", coin5TH.Name);
        coin5TH_text:SetTextByKey("value", coin5TH_count);

        local btn = GET_CHILD(ctrlSet, "update_Btn");
        btn:SetEventScript(ui.LBUTTONUP, "EVENT_2011_5TH_SPECIAL_SHOP_UPDATE_BTN_CLICK");
        btn:SetTextTooltip(ClMsg("EVENT_2011_5TH_Special_Shop_Update_Tooltip"));
        btn:ShowWindow(1);
        
        event_gb:ShowWindow(1);
        REQ_EARTH_TOWER_SHOP_SUB_COMMON(shopType)
    elseif string.find(shopType, "EVENT_2101_SUPPLY_Shop2") ~= nil or string.find(shopType, "EVENT_2101_SUPPLY_Shop1") ~= nil then
        title:SetText('{@st43}'..ScpArgMsg(shopType));
        close:SetTextTooltip(ScpArgMsg('CloseUI{NAME}', 'NAME', ScpArgMsg("EventShop")));

        remain_time:ShowWindow(1);
	elseif shopType == "BOSS_COOP_SHOP" then
		 title:SetText('{@st43}'..ScpArgMsg(shopType));
        close:SetTextTooltip(ScpArgMsg('CloseUI{NAME}', 'NAME', ScpArgMsg("bosscoopshop")));
    elseif string.find(shopType, 'Certificate') ~= nil then -- 증표 상점
        title:SetText('{@st43}'..ScpArgMsg(shopType .. "_shop"));
        close:SetTextTooltip(ScpArgMsg('CloseUI{NAME}', 'NAME', ScpArgMsg(shopType .. "_shop")));        
        EARTH_TOWER_SET_PROPERTY_COUNT(propertyRemain, 'dummy_' .. shopType, shopType)        
        pointbuyBtn:ShowWindow(1)

        -- for i = 1, #shop_list do
        --     if shop_list[i] == shopType then
        --         if shop_list[i - 1] ~= nil then                
        --             prevShopBtn:ShowWindow(1)    
        --             break
        --         end
        --     end
        -- end
        
    elseif shopType == "EVENT_TOS_WHOLE_SHOP" then -- 이벤트 통합 상점
        title:SetText('{@st43}'..ScpArgMsg("EVENT_TOS_WHOLE_SHOP"));
        close:SetTextTooltip(ScpArgMsg('CloseUI{NAME}', 'NAME', ScpArgMsg("EVENT_TOS_WHOLE_SHOP")));        
        EARTH_TOWER_SET_PROPERTY_COUNT(propertyRemain, 'Tos_Event_Coin', "EVENT_TOS_WHOLE_TOTAL_COIN")
    elseif string.find(shopType, 'BOUNTY_NPC_TRADE_SHOP_') ~= nil then
        title:SetText('{@st43}'..ScpArgMsg('BountyNpcShop'));
        close:SetTextTooltip(ScpArgMsg('CloseUI{NAME}', 'NAME', ScpArgMsg("BountyNpcShop")));
    elseif string.find(shopType, 'archeology') ~= nil then
        title:SetText('{@st43}'..ScpArgMsg(shopType));
        close:SetTextTooltip(ScpArgMsg('ui_close'));
        pointbuyBtn:ShowWindow(1)
    elseif shopType == "EVENT_2312_8TH_ANNIVERSARY" then
        if resetDatetime ~= nil then
            resetDatetime:SetText(ClMsg('EVENT_2312_8TH_SNIGO_SHOP'))
            resetDatetime:ShowWindow(1)
        end
        title:SetText('{@st43}'..ScpArgMsg(shopType));
        if g_account_prop_shop_table[shopType]~=nil then
            EARTH_TOWER_SET_PROPERTY_COUNT(propertyRemain, g_account_prop_shop_table[shopType]['coinName'], "Event")
        end
        close:SetTextTooltip(ScpArgMsg('CloseUI{NAME}', 'NAME', ScpArgMsg("EventShop")));
    elseif shopType == "event_2512_ice_piece" then
        title:SetText('{@st43}'..ScpArgMsg(shopType));
        close:SetTextTooltip(ScpArgMsg('ui_close'));
        pointbuyBtn:SetTextByKey("name", ScpArgMsg("costumeextract"))
        pointbuyBtn:ShowWindow(1)
        catuion:ShowWindow(1);    
    else
        title:SetText('{@st43}'..ScpArgMsg(shopType));
        if g_account_prop_shop_table[shopType]~=nil then
            EARTH_TOWER_SET_PROPERTY_COUNT(propertyRemain, g_account_prop_shop_table[shopType]['coinName'], "Event")
        end
        close:SetTextTooltip(ScpArgMsg('CloseUI{NAME}', 'NAME', ScpArgMsg("EventShop")));
    end
    
    local showonlyhavemat = GET_CHILD_RECURSIVELY(frame, 'showonlyhavemat');
    AUTO_CAST(showonlyhavemat)
    local checkHaveMaterial = showonlyhavemat:IsChecked();
    local showExchangeEnable = GET_CHILD_RECURSIVELY(frame, "showExchangeEnable");
    AUTO_CAST(showExchangeEnable)
    local checkExchangeEnable = showExchangeEnable:IsChecked();

    if string.find(shopType, "EarthTower") ~= nil or shopType == "DailyRewardShop" or ShopType == 'DailyRewardShop_Season' or shopType == "EVENT_2407_KUPOLE" then
        showExchangeEnable:ShowWindow(0);
        checkExchangeEnable = 0;
    end
    
    local clslist = GetClassList("ItemTradeShop");
    if clslist == nil then return end

    local i = 0;
    local cls = GetClassByIndexFromList(clslist, i);
    while cls ~= nil do
        if cls.ShopType == shopType then
            if EARTH_TOWER_IS_ITEM_SELL_TIME(cls) == true then
                local isExchangeEnable = true;
                if checkExchangeEnable == 1 and EXCHANGE_COUNT_CHECK(cls) <= 0 then
                    isExchangeEnable = false;                    
                end
                local haveM = CRAFT_HAVE_MATERIAL(cls);
                if checkHaveMaterial == 1 then
                    if haveM == 1 then
                        if isExchangeEnable == true then
                            _INSERT_ITEM_INFO(cls, shopType)
                        end
                    end
                else
                    if isExchangeEnable == true then
                        _INSERT_ITEM_INFO(cls, shopType);
                    end
                end
            end
        end
        
        i = i + 1;
        cls = GetClassByIndexFromList(clslist, i);
    end

    EXCHANGE_AUTO_DRAW(shopType)

end

function EARTH_TOWER_SET_PROPERTY_COUNT(ctrl, itemName, propName)
    local aObj = GetMyAccountObj()
    local count = TryGetProp(aObj, propName, '0')
    local itemCls = GetClass('Item', itemName)
    
    if count == 'None' then
        count = '0'
    end

    if propName == "Event" then
        count = tostring(GetInvItemCount(GetMyPCObject(), itemName))
    end
    if itemName == "Tos_Event_Coin" then
        local clsmsg = ClMsg("REMAIN_COIN_EVENT_TOS_WHOLE_ICON")
        ctrl:SetTextByKey('icon', clsmsg)
    elseif itemName == "EVENT_2407_Coin" then
        local clsmsg = ClMsg("EVENT_COIN_MSG");
        ctrl:SetTextByKey('icon', clsmsg);
        ctrl:SetTextByKey('itemName', "");
        ctrl:SetTextByKey('itemCount', GET_COMMAED_STRING(count));
        ctrl:ShowWindow(1);
        return;
    elseif itemName == "EVENT_MOONRISE_2410" then
        local clsmsg = ClMsg("EVENT_COIN_MSG");
        ctrl:SetTextByKey('icon', clsmsg);
        ctrl:SetTextByKey('itemName', "");
        ctrl:SetTextByKey('itemCount', GET_COMMAED_STRING(count));
        ctrl:ShowWindow(1);
        return;
    elseif itemName == "Tos_Event_Platinum_Coin" then
        local clsmsg = ClMsg("EVENT_COIN_MSG");
        ctrl:SetTextByKey('icon', clsmsg);
        ctrl:SetTextByKey('itemName', "");
        ctrl:SetTextByKey('itemCount', GET_COMMAED_STRING(count));
        ctrl:ShowWindow(1);
        return;
    else
        ctrl:SetTextByKey('icon', "")  
    end

    ctrl:SetTextByKey('itemName', itemCls.Name)
    ctrl:SetTextByKey('itemCount', GET_COMMAED_STRING(count))
    ctrl:ShowWindow(1)
end

function EARTH_TOWER_IS_ITEM_SELL_TIME(recipeCls)
    local startDateString = TryGetProp(recipeCls,'SellStartTime',nil)
    local endDateString = TryGetProp(recipeCls,'SellEndTime',nil)
    if startDateString ~= nil and endDateString ~= nil then
        return IS_CURREUNT_IN_PERIOD(startDateString, endDateString, true)
    end
    return true;
end

function EXCHANGE_COUNT_CHECK(cls)
    local recipecls = GetClass('ItemTradeShop', cls.ClassName);    

    if recipecls.AccountNeedProperty ~= 'None' then
        local aObj = GetMyAccountObj()
        local sCount = TryGetProp(aObj, recipecls.AccountNeedProperty, 0);
                
        if sCount <= 0 then
            local overbuy_prop = TryGetProp(recipecls, 'OverBuyProperty', 'None')
            if overbuy_prop ~= 'None' then
                local now = TryGetProp(aObj, overbuy_prop, 0)
                local max = TryGetProp(recipecls, 'MaxOverBuyCount', 10000)                
                return max - now
            end
        end

        return sCount;
    end

    if recipecls.NeedProperty ~= 'None' then
        local sObj = GetSessionObject(GetMyPCObject(), "ssn_shop");
        local sCount = TryGetProp(sObj, recipecls.NeedProperty);
        return sCount;
    end

    return 1
end

function INSERT_ITEM(cls, tree, slotHeight, haveMaterial, shopType)    
    local item = GetClass('Item', cls.TargetItem);
    if item == nil then
        return;
    end

    local groupName = item.GroupName;

    if shopType == 'PVPMine' then
        local item_category = TryGetProp(cls, 'ItemCategory', 'None')
        if item_category ~= 'None' then
            groupName = item_category
        end
    end
    
    EXCHANGE_CREATE_TREE_PAGE(tree, slotHeight, groupName, nil, cls, shopType);
end


function EXCHANGE_CREATE_TREE_PAGE(tree, slotHeight, groupName, classType, cls, shopType)    
    local hGroup = tree:FindByValue(groupName);
    if tree:IsExist(hGroup) == 0 then
        hGroup = tree:Add(ScpArgMsg(groupName), groupName);
        tree:SetNodeFont(hGroup,"brown_18_b")
    end

    local hParent = nil;
    if classType == nil then
        hParent = hGroup;
    else
        local hClassType = tree:FindByValue(hGroup, classType);
        if tree:IsExist(hClassType) == 0 then
            hClassType = tree:Add(hGroup, ScpArgMsg(classType), classType);
            tree:SetNodeFont(hClassType,"brown_18_b");
        end
        hParent = hClassType;
    end
    
    local pageCtrlName = "PAGE_" .. groupName;
    if classType ~= nil then
        pageCtrlName = pageCtrlName .. "_" .. classType;
    end

    local page = tree:GetChild(pageCtrlName);
    if page == nil then
        page = tree:CreateOrGetControl('page', pageCtrlName, 0, 1000, tree:GetWidth()-35, 470);

        tolua.cast(page, 'ui::CPage')
        page:SetSkinName('None');
        page:SetSlotSize(415, slotHeight);
        page:SetFocusedRowHeight(-1, slotHeight);
        page:SetFitToChild(true, 10);
        page:SetSlotSpace(0, 0)
        page:SetBorder(5, 0, 0, 0)
        CRAFT_MINIMIZE_FOCUS(page);
        tree:Add(hParent, page);    
        tree:SetNodeFont(hParent,"brown_18_b")      
    end

    local ctrlset = page:CreateOrGetControlSet('earthTowerRecipe', cls.ClassName, 10, 10);
    local groupbox = ctrlset:CreateOrGetControl('groupbox', pageCtrlName, 0, 0, 530, 200);
    local sale = GET_CHILD_RECURSIVELY(ctrlset, "sale")
    groupbox:SetSkinName("None")
    groupbox:EnableHitTest(0);
    groupbox:ShowWindow(1);
    sale:ShowWindow(0);
    tree:Add(hParent, groupbox);    
    tree:SetNodeFont(hParent,"brown_18_b")

    local height = EXCHANGE_CREATE_TREE_NODE_CTRL(ctrlset,  cls, shopType)
    ctrlset:Resize(ctrlset:GetWidth(), height);
    GBOX_AUTO_ALIGN(groupbox, 0, 0, 10, true, false);
    groupbox:SetUserValue("HEIGHT_SIZE", groupbox:GetUserIValue("HEIGHT_SIZE") + ctrlset:GetHeight())
    groupbox:Resize(groupbox:GetWidth(), groupbox:GetUserIValue("HEIGHT_SIZE"));

    SET_ITEM_SALE_STATE(ctrlset, cls)

    local maxSlotHeight = page:GetUserIValue("MAX_SLOT_HEIGHT");
    if maxSlotHeight == nil then
        maxSlotHeight = ctrlset:GetHeight()
    end

    if maxSlotHeight < ctrlset:GetHeight() then
        maxSlotHeight = ctrlset:GetHeight()
    end

    page:SetSlotSize(ctrlset:GetWidth(), maxSlotHeight);
    page:SetUserValue("MAX_SLOT_HEIGHT", maxSlotHeight);

end

function EXCHANGE_CREATE_TREE_NODE_CTRL(ctrlset, cls, shopType) 
    local aObj = GetMyAccountObj()
    local x = 180;
    local startY = 80;
    local y = startY; 
    y = y + 10;
    local itemHeight = 0
    if g_account_prop_shop_table[shopType] ~= nil then
        itemHeight = ui.GetControlSetAttribute('craftRecipe_detail_pvp_mine_item', 'height');
    else
        itemHeight = ui.GetControlSetAttribute('craftRecipe_detail_item', 'height');
    end
    local recipecls = GetClass('ItemTradeShop', ctrlset:GetName());
    local targetItem = GetClass("Item", recipecls.TargetItem);
    local itemName = GET_CHILD(ctrlset, "itemName")
    local itemIcon = GET_CHILD(ctrlset, "itemIcon")
    local minHeight = itemIcon:GetHeight() + startY + 10;

    if TryGetProp(recipecls, "Item_2_1", 'None') ~= "None" or string.find(shopType, 'BOUNTY_NPC_TRADE_SHOP_') ~= nil then
        local itemCountGBox = GET_CHILD_RECURSIVELY(ctrlset, "gbox");
        if itemCountGBox ~= nil then
            itemCountGBox:ShowWindow(0);
        end
    end

    itemName:SetTextByKey("value", targetItem.Name .. " [" .. recipecls.TargetItemCnt .. ScpArgMsg("Piece") .. "]");
    
    if targetItem.StringArg == "EnchantJewell" and cls.TargetItemAppendProperty ~= 'None' then
        local number_arg1 = TryGetProp(targetItem, 'NumberArg1', 0)
        if number_arg1 ~= 0 then
            itemName:SetTextByKey("value", targetItem.Name .. " [" .. recipecls.TargetItemCnt .. ScpArgMsg("Piece") .. "]");
        else
            itemName:SetTextByKey("value", "[Lv. "..cls.TargetItemAppendValue.."] "..targetItem.Name .. " [" .. recipecls.TargetItemCnt .. ScpArgMsg("Piece") .. "]");
        end      
    end
    
    itemIcon:SetImage(targetItem.Icon);
    itemIcon:SetEnableStretch(1);
    SET_SLOT_STAR_TEXT(itemIcon, targetItem)	

    if targetItem.StringArg == "EnchantJewell" and cls.TargetItemAppendProperty ~= 'None' then
        SET_ITEM_TOOLTIP_BY_CLASSID(itemIcon, targetItem.ClassName, 'ItemTradeShop', cls.ClassName);
    else  
        SET_ITEM_TOOLTIP_ALL_TYPE(itemIcon, nil, targetItem.ClassName, '', targetItem.ClassID, 0);    
        if TryGetProp(recipecls, 'BelongingType', 'None') == 'Team' then
            itemIcon:SetTooltipStrArg('team_belonging') -- 팀 귀속용 str arg
        elseif TryGetProp(recipecls, 'BelongingType', 'None') == 'Character' then
            itemIcon:SetTooltipStrArg('char_belonging') -- 캐릭터 귀속용 str arg
        end
        if shopType == "EVENT_2312_8TH_ANNIVERSARY" then
            itemIcon:SetTooltipStrArg('team_belonging') -- 팀 귀속용 str arg
        end
    end
    
    local itemCount = 0;
    for i = 1, 5 do
        if TryGetProp(recipecls, "Item_"..i.."_1", 'None') ~= "None" then
        local recipeItemCnt, invItemCnt, dragRecipeItem, invItem, recipeItemLv, invItemlist  = GET_RECIPE_MATERIAL_INFO(recipecls, i, GetMyPCObject());
            if invItemlist ~= nil then
                for j = 0, recipeItemCnt - 1 do
                    local itemSet = nil
                    if g_account_prop_shop_table[shopType] ~= nil then
                        itemSet = ctrlset:CreateOrGetControlSet('craftRecipe_detail_pvp_mine_item', "EACHMATERIALITEM_" .. i ..'_'.. j, x, y);
                    else
                        itemSet = ctrlset:CreateOrGetControlSet('craftRecipe_detail_item', "EACHMATERIALITEM_" .. i ..'_'.. j, x, y);
                    end
                    
                    itemSet:SetUserValue("MATERIAL_IS_SELECTED", 'nonselected');

                    local slot = GET_CHILD(itemSet, "slot", "ui::CSlot");
                    local needcountTxt = GET_CHILD(itemSet, "needcount", "ui::CSlot");
                    needcountTxt:SetTextByKey("count", recipeItemCnt)

                    SET_SLOT_ITEM_CLS(slot, dragRecipeItem);
                    slot:SetEventScript(ui.DROP, "ITEMCRAFT_ON_DROP");
                    slot:SetEventScriptArgNumber(ui.DROP, dragRecipeItem.ClassID);
                    slot:SetEventScriptArgString(ui.DROP, 1)
                    slot:EnableDrag(0);
                    slot:SetOverSound('button_cursor_over_2');
                    slot:SetClickSound('button_click');

                    local icon      = slot:GetIcon();
                    icon:SetColorTone('33333333')
                    itemSet:SetUserValue("ClassName", dragRecipeItem.ClassName);
                    
                    local itemtext = GET_CHILD(itemSet, "item", "ui::CRichText");
                    itemtext:SetText(dragRecipeItem.Name);

                    y = y + itemHeight;
                    itemCount = itemCount + 1;              
                end
            else            
                local itemSet = nil
                if g_account_prop_shop_table[shopType] ~= nil then
                    itemSet = ctrlset:CreateOrGetControlSet('craftRecipe_detail_pvp_mine_item', "EACHMATERIALITEM_" .. i, x, y);
                else
                    itemSet = ctrlset:CreateOrGetControlSet('craftRecipe_detail_item', "EACHMATERIALITEM_" .. i, x, y);
                end
                 
                itemSet:SetUserValue("MATERIAL_IS_SELECTED", 'nonselected');

                local slot = GET_CHILD(itemSet, "slot", "ui::CSlot");
                local needcountTxt = GET_CHILD(itemSet, "needcount", "ui::CSlot");

                recipeItemCnt = GET_CURRENT_OVERBUY_COUNT(shopType, recipeItemCnt, recipecls, GetMyAccountObj()) -- 추가 회득
                
                if string.find(shopType, 'Certificate') == nil then                    
                needcountTxt:SetTextByKey("count", recipeItemCnt);
                else
                    needcountTxt:SetTextByKey("count", M_NUMBER_FORMAT(recipeItemCnt));                
                end

                SET_SLOT_ITEM_CLS(slot, dragRecipeItem);
                slot:SetEventScript(ui.DROP, "ITEMCRAFT_ON_DROP");
                slot:SetEventScriptArgNumber(ui.DROP, dragRecipeItem.ClassID);
                slot:SetEventScriptArgString(ui.DROP, tostring(recipeItemCnt));
                slot:EnableDrag(0); 
                slot:SetOverSound('button_cursor_over_2');
                slot:SetClickSound('button_click');

                local icon = slot:GetIcon();
                icon:SetColorTone('33333333')
                itemSet:SetUserValue("ClassName", dragRecipeItem.ClassName)

                local itemtext = GET_CHILD(itemSet, "item", "ui::CRichText");
                itemtext:SetText(dragRecipeItem.Name);

                y = y + itemHeight;
                itemCount = itemCount + 1;
            end
        end
    end

    -- edittext Reset
    local edit_itemcount = GET_CHILD_RECURSIVELY(ctrlset, "itemcount");
    if edit_itemcount ~= nil then
        edit_itemcount:SetText(1);
    end

    local height = 0;   
    if y < minHeight then
        height = minHeight;
    else
        height = 120 + (itemCount * 55);
    end;
        
    local lableLine = GET_CHILD(ctrlset, "labelline_1");
    local exchangeCountText = GET_CHILD(ctrlset, "exchangeCount");  
    
    local exchangeCountTextFlag = 0
    if recipecls.NeedProperty ~= 'None' then
        local sObj = GetSessionObject(GetMyPCObject(), "ssn_shop");
        local sCount = TryGetProp(sObj, recipecls.NeedProperty); 
        local cntText = string.format("%d", sCount).. ScpArgMsg("Excnaged_Count_Remind");
        local tradeBtn = GET_CHILD(ctrlset, "tradeBtn");
        if sCount <= 0 then
            cntText = ScpArgMsg("Excnaged_No_Enough");
            tradeBtn:SetColorTone("FF444444");
            tradeBtn:SetEnable(0);
        end

        exchangeCountText:SetTextByKey("value", cntText);

        lableLine:SetPos(0, height);
        height = height + 10 + lableLine:GetHeight();
        exchangeCountText:SetPos(0, height);
        height = height + 10 + exchangeCountText:GetHeight() + 15;
        lableLine:SetVisible(1);
        exchangeCountText:SetVisible(1);
        exchangeCountTextFlag = 1
    end;
    
    if recipecls.AccountNeedProperty ~= 'None' then
		local sCount = TryGetProp(aObj, recipecls.AccountNeedProperty, 0); 
		local cntText
        if recipecls.ShopType == "PVPMine" 
        or string.find(recipecls.ShopType, "Certificate") ~= nil        
        or recipecls.ShopType == 'EVENT_TOS_WHOLE_SHOP' then                        
			if recipecls.ResetInterval == 'Week' then
				cntText = ScpArgMsg("Excnaged_AccountCount_Remind_Week","COUNT",string.format("%d", sCount))
            elseif recipecls.ResetInterval == 'Month' then    
                cntText = ScpArgMsg("Excnaged_AccountCount_Remind_Month","COUNT",string.format("%d", sCount))  
            else
				cntText = ScpArgMsg("Excnaged_AccountCount_Remind_Day","COUNT",string.format("%d", sCount))
			end
        else
            local reset = TryGetProp(recipecls, "ResetInterval", "None");
            if reset == "Day" then
                cntText = ScpArgMsg("Excnaged_AccountCount_Remind_Day","COUNT",string.format("%d", sCount))
            else
			    cntText = ScpArgMsg("Excnaged_AccountCount_Remind","COUNT",string.format("%d", sCount))
            end
		end
        local tradeBtn = GET_CHILD(ctrlset, "tradeBtn");
        if sCount <= 0 then
            if TryGetProp(recipecls, 'MaxOverBuyCount', 0) > 0 then
                local overbuy_prop = TryGetProp(recipecls, 'OverBuyProperty', 'None')          
                local overbuy_count = TryGetProp(aObj, overbuy_prop, 0)          
                if overbuy_prop ~= 'None' then
                    if recipecls.ResetInterval == 'Week' then
                        cntText = ScpArgMsg("OverBuyCount{count}_Week{max}","count", overbuy_count, 'max', TryGetProp(recipecls, 'MaxOverBuyCount', 100) )
                    elseif recipecls.ResetInterval == 'Day' then
                        cntText = ScpArgMsg("OverBuyCount{count}_Day{max}","count", overbuy_count, 'max', TryGetProp(recipecls, 'MaxOverBuyCount', 100) )
                    end
                end

                if overbuy_count >= TryGetProp(recipecls, 'MaxOverBuyCount', 100) then
                    cntText = ScpArgMsg("Excnaged_No_Enough");
                    tradeBtn:SetColorTone("FF444444");
                    tradeBtn:SetEnable(0);
                end
            else
            cntText = ScpArgMsg("Excnaged_No_Enough");
            tradeBtn:SetColorTone("FF444444");
            tradeBtn:SetEnable(0);
        end
        end
        
        exchangeCountText:SetTextByKey("value", cntText);

        lableLine:SetPos(0, height);
        height = height + 10 + lableLine:GetHeight();
        exchangeCountText:SetPos(0, height);
        height = height + 10 + exchangeCountText:GetHeight() + 15;
        lableLine:SetVisible(1);
        exchangeCountText:SetVisible(1);
        exchangeCountTextFlag = 1
    end
    
    if recipecls.ShopType == "EVENT_2312_8TH_ANNIVERSARY" then
        exchangeCountTextFlag = 0
    end

    if exchangeCountTextFlag == 0 then
        height = height + 20;
        lableLine:SetVisible(0);
        exchangeCountText:SetVisible(0);
    end;


    local tradeBtn = GET_CHILD(ctrlset, "tradeBtn");
    local textTooltip = TryGetProp(recipecls, "TradeBtnTextTooltip", "None");
    if tradeBtn:IsVisible() == 1 and textTooltip ~= "None" then
        tradeBtn:SetTextTooltip(ClMsg(textTooltip))
    end
    return height;
end

function EXCHANGE_INIT_TAB_INFO()
    local frame = ui.GetFrame('earthtowershop');
    local bg_category = GET_CHILD_RECURSIVELY(frame, 'bg_category');
    bg_category:RemoveAllChild();
    bg_category:Resize(bg_category:GetOriginalWidth(), bg_category:GetOriginalHeight());
    _CLEAR_INFO();

    local tree = GET_CHILD_RECURSIVELY(frame, 'recipetree','ui::CTreeControl')
    if nil ~= tree then
        AUTO_CAST(tree)
        tree:Clear();
        tree:EnableDrawTreeLine(false)
        tree:EnableDrawFrame(false)
        tree:SetFitToChild(true,200)
        tree:SetFontName("brown_18_b");
        tree:SetTabWidth(5);
    
    end
end

function EXCHANGE_MAKE_TAB_BTN(groupName)
    local frame = ui.GetFrame('earthtowershop');
    local bg_category = GET_CHILD_RECURSIVELY(frame, 'bg_category');
    _ADD_TAB_BTN_CTRL(bg_category, groupName)
end

function EXCHANGE_AUTO_DRAW(shopType)

    local frame = ui.GetFrame('earthtowershop');
    if frame == nil then
        return;
    end

    local lastDrawShopType = frame:GetUserValue("LAST_DRAW_SHOP_TYPE");    
    if lastDrawShopType == nil or shopType ~= lastDrawShopType then
        -- 저장이 안됬거나, 타입이 틀리면 첫번째꺼 선택해서 다시 그리기.
        local categoryName = GET_EXCHANGE_FIRST_CATEGORY_NAME(frame);
        DRAW_EXCHANGE_SHOP_IETMS(categoryName);
        return;
    end

    -- shopType이 같으면 마지막 그려진 정보를 가져와서 다시 그려주기.
    local lastDrawCategoryName = frame:GetUserValue("LAST_DRAW_CATEGORY_NAME");    
    if lastDrawCategoryName == nil then
        local categoryName = GET_EXCHANGE_FIRST_CATEGORY_NAME(frame);
        DRAW_EXCHANGE_SHOP_IETMS(categoryName)
        return;
    end

    -- 마지막 저장된 카테고리 버튼이 사라졌으면 첫번째꺼 선택해서 다시그리기
    if EXIST_EXCHANGE_CATEGORY_NAME(frame, lastDrawCategoryName) == false then
        local categoryName = GET_EXCHANGE_FIRST_CATEGORY_NAME(frame);
        DRAW_EXCHANGE_SHOP_IETMS(categoryName);
        return;
    end
    
    DRAW_EXCHANGE_SHOP_IETMS(lastDrawCategoryName)
end

function EXIST_EXCHANGE_CATEGORY_NAME(frame, name)
    if frame == nil then
        frame = ui.GetFrame('earthtowershop');
        if frame == nil then
            return false;
        end
    end

    local bg_category = GET_CHILD_RECURSIVELY(frame, 'bg_category');
    local childCnt = bg_category:GetChildCount();
    for i = 1, childCnt do
        local btnChild = bg_category:GetChildByIndex(i); 
        if btnChild ~= nil then
            local categoryName = btnChild:GetUserValue("CATEGORY_NAME");
            if categoryName == name then
                return true;
            end    
        end
    end

    return false;
end

function GET_EXCHANGE_FIRST_CATEGORY_NAME(frame)
    if frame == nil then
        frame = ui.GetFrame('earthtowershop');
        if frame == nil then
            return nil;
        end
end

    local bg_category = GET_CHILD_RECURSIVELY(frame, 'bg_category');
    local childCnt = bg_category:GetChildCount();
    if childCnt > 0 then
        local btnChild = bg_category:GetChildByIndex(0); 
        if btnChild == nil then
            return nil;
        end
        --tolua.cast(btnChild, "ui::CButton");
        local categoryName = btnChild:GetUserValue("CATEGORY_NAME");
        if categoryName ~= nil then
            return categoryName;
        end
    end

    return nil;
end

function CLICK_EXCHANGE_SHOP_CATEGORY(ctrlSet, ctrl, strArg, numArg)
    DRAW_EXCHANGE_SHOP_IETMS(strArg)
end

local function sort_by_sort_idex(a, b)
    if TryGetProp(a, 'SortIndex', 0) > TryGetProp(b, 'SortIndex', 0) then
        return true
    elseif TryGetProp(a, 'SortIndex', 0) < TryGetProp(b, 'SortIndex', 0) then
        return false
    else
        return TryGetProp(a, 'ClassID', 0) < TryGetProp(b, 'ClassID', 0)
    end
end

function DRAW_EXCHANGE_SHOP_IETMS(categoryName)    
    if categoryName == nil then
        return;
    end

    local frame = ui.GetFrame('earthtowershop');
    if frame == nil then
        return;
    end

    session.ResetItemList();

    -- 한번 그려지면 frame에 마지막 그려진 상점 타입과 카테고리 이름을 저장한다.
    local shopType = frame:GetUserValue("SHOP_TYPE");
    frame:SetUserValue("LAST_DRAW_SHOP_TYPE", shopType);
    frame:SetUserValue("LAST_DRAW_CATEGORY_NAME", categoryName);

    -- bg_category 밑으로 정렬해야 하므로 가져옴.
    local bg_category = GET_CHILD(frame, 'bg_category','ui::CGroupBox');
    local group = GET_CHILD(frame, 'Recipe', 'ui::CGroupBox');
    local bg_bottom = GET_CHILD(frame, 'bg_bottom','ui::CGroupBox');
    if bg_category == nil or group == nil or bg_bottom == nil then
        return;
    end

    -- 아이템 표시 위치 정렬.
    local newY = bg_category:GetY() + bg_category:GetHeight() + 5;
    group:SetOffset(group:GetX(), newY);
    local bottomY = bg_bottom:GetY();
    local newHeight = bottomY - newY;
    if newHeight ~= group:GetHeight() then
        local recipetree_Box =  GET_CHILD(group, 'recipetree_Box', 'ui::CGroupBox');
        group:Resize(group:GetWidth(), newHeight);
        recipetree_Box:Resize(recipetree_Box:GetWidth(), newHeight - 20);
    end
   
    -- 트리 초기화
    local tree_box = GET_CHILD(group, 'recipetree_Box','ui::CGroupBox')
    local tree = GET_CHILD(tree_box, 'recipetree','ui::CTreeControl')
    if nil == tree then
        return;
    end

    tree:Clear();
    tree:EnableDrawTreeLine(false)
    tree:EnableDrawFrame(false)
    tree:SetFitToChild(true,200)
    tree:SetFontName("brown_18_b");
    tree:SetTabWidth(5);

    local classList = _GET_INFO(categoryName);
    table.sort(classList, sort_by_sort_idex)

    local shopType = frame:GetUserValue("SHOP_TYPE");
    local slotHeight = ui.GetControlSetAttribute('earthTowerRecipe', 'height') + 5;
    for index , cls in pairs(classList) do
        if cls.ShopType == shopType then
            if EARTH_TOWER_IS_ITEM_SELL_TIME(cls) == true then
                local haveM = CRAFT_HAVE_MATERIAL(cls);                
                INSERT_ITEM(cls, tree, slotHeight, haveM, shopType);
            end
        end    
    end

    tree:OpenNodeAll();

end


function EARTH_TOWER_SHOP_EXEC(parent, ctrl)
    local frame = parent:GetTopParentFrame();
    local shopType = frame:GetUserValue("SHOP_TYPE");
	s_earth_shop_frame_name = frame:GetName();
	s_earth_shop_parent_name = parent:GetName();
    g_earth_shop_control_name = ctrl:GetName();
    
    local parentcset = ctrl:GetParent();
    local edit_itemcount = GET_CHILD_RECURSIVELY(parentcset, "itemcount");
    if edit_itemcount == nil then 
        return; 
    end

    local itemCountGBox = GET_CHILD_RECURSIVELY(parentcset, "gbox");
    local resultCount = tonumber(edit_itemcount:GetText());
    if itemCountGBox:IsVisible() == 0 then
        resultCount = 1;
    end

    local recipecls = GetClass('ItemTradeShop', parent:GetName());
    if g_account_prop_shop_table[shopType] == nil then
        if recipecls ~= nil then
            local isExceptionFlag = false;
            for index = 1, 5 do
                local clsName = "Item_"..index.."_1";
                local itemName = TryGetProp(recipecls, clsName, 'None');
                local recipeItemCnt, invItemCnt, dragRecipeItem, invItem, recipeItemLv, invItemlist = GET_RECIPE_MATERIAL_INFO(recipecls, index, GetMyPCObject());
                
                recipeItemCnt = GET_CURRENT_OVERBUY_COUNT(shopType, recipeItemCnt, recipecls, GetMyAccountObj()) -- 추가 회득
                if dragRecipeItem ~= nil then
                    local itemCount = GET_TOTAL_ITEM_CNT(dragRecipeItem.ClassID);
                    if itemCount < recipeItemCnt * resultCount then                        
                        ui.AddText("SystemMsgFrame", ScpArgMsg('NotEnoughRecipe'));
                        isExceptionFlag = true;
                        break;
                    end
                end
            end

            if isExceptionFlag == true then
                isExceptionFlag = false;
                return;
            end
        end
    end

    local remain_time = GET_CHILD_RECURSIVELY(frame, "remain_time");
    if remain_time ~= nil and remain_time:IsVisible() == 1 then
        local remainTime = tonumber(remain_time:GetTextByKey("value"));
        if remainTime <= 0 then
            return;
        end
    end
    if (shopType == 'PVPMine' 
    or string.find(shopType ,'Certificate') ~= nil
    or shopType == 'DailyRewardShop' 
    or shopType == 'EVENT_TOS_WHOLE_SHOP'
    or shopType == 'DailyRewardShop_Season') and resultCount >= 10 then
        local coin_name = ""
        local recipeCnt = 0
        local before_count = 0
        local after_count = 0
        local recipecls = GetClass('ItemTradeShop', parent:GetName());
        local aObj = GetMyAccountObj()
        if g_account_prop_shop_table[shopType] == nil then -- 아이템
            local itemName = TryGetProp(recipecls, "Item_1_1", "None");
            recipeCnt = TryGetProp(recipecls, "Item_1_1_Cnt", 0);
            local itemCls = GetClass('Item', itemName)
            before_count = GET_TOTAL_ITEM_CNT(itemCls.ClassID)
            coin_name = TryGetProp(itemCls, "Name", "None")
        else -- 주화
            local coinCls = GetClassByStrProp('accountprop_inventory_list', 'ClassName', g_account_prop_shop_table[shopType]['propName'])
            recipeCnt = TryGetProp(recipecls, "Item_1_1_Cnt", 0);
            local count = TryGetProp(aObj, g_account_prop_shop_table[shopType]['propName'], '0')
            if count == 'None' then
                count = '0'
            end
            before_count = tonumber(count) -- 현재 갯수
            coin_name = ClMsg(TryGetProp(coinCls, "ClassName", "None"))
        end

        if IS_OVERBUY_ITEM(shopType, recipecls, aObj) == false then
            after_count = before_count - (recipeCnt * resultCount)
        else
            after_count = before_count - GET_TOTAL_AMOUNT_OVERBUY(shopType, recipeCnt, recipecls, aObj, resultCount)
        end

        before_count = GET_COMMAED_STRING(before_count)
        after_count = GET_COMMAED_STRING(after_count)

        local target_item = GetClass('Item', TryGetProp(recipecls, 'TargetItem', 'None'))
        local name = TryGetProp(target_item, 'Name', 'None')
        if recipecls==nil or  TryGetProp(recipecls, "Item_2_1", "None") ~='None' then            
            local msg = ScpArgMsg("TooManyItemBuy{name}{count}{coinname}{beforecount}{aftercount}", "name", name, "count", resultCount, "coinname", coin_name, "beforecount", before_count, "aftercount", after_count);
            local yesscp = string.format('YES_SCP_BUY_SHOP_EXEC_1(%d, "%s")', resultCount, shopType);
            ui.MsgBox_NonNested(msg, frame:GetName(), yesscp, 'None');
        else            
            local msg = ScpArgMsg("TooManyItemBuy{name}{count}{coinname}{beforecount}{aftercount}", "name", name, "count", resultCount, "coinname", coin_name, "beforecount", before_count, "aftercount", after_count);
            local yesscp = string.format('YES_SCP_BUY_SHOP_EXEC_2(%d, "%s")', resultCount, shopType);
            ui.MsgBox_NonNested(msg, frame:GetName(), yesscp, 'None');
        end
    elseif frame:GetName() == "legend_craft" and frame:GetUserValue("CRAFT_TYPE") == "SPECIAL_MISC_CRAFT" then  -- 특수 재료 제작
        local parent = GET_CHILD_RECURSIVELY(frame, s_earth_shop_parent_name);
        local control = GET_CHILD_RECURSIVELY(parent, g_earth_shop_control_name);
        local targetRecipeName = control:GetUserValue('TARGET_RECIPE_NAME');
        local itemCls = GetClassByStrProp("Item", "ClassName", targetRecipeName)
        local UsageDesc = TryGetProp(itemCls, "UsageDesc", "None")
        if UsageDesc ~= "None" then
            if recipecls==nil or TryGetProp(recipecls, "Item_2_1", "None") ~='None' then
                local msg = ScpArgMsg("ReallyManufactureItem_legendcraft{usage}", "usage", UsageDesc);
                local yesscp = string.format('YES_SCP_BUY_SHOP_EXEC_SPECIAL_MISC_CRAFT_1(%d)', resultCount);
                ui.MsgBox_NonNested(msg, frame:GetName(), yesscp, 'None');
            else
                local msg = ScpArgMsg("ReallyManufactureItem_legendcraft{usage}", "usage", UsageDesc);
                local yesscp = string.format('YES_SCP_BUY_SHOP_EXEC_SPECIAL_MISC_CRAFT_2');
                ui.MsgBox_NonNested(msg, frame:GetName(), yesscp, 'None');
            end
        end
    else
        if recipecls==nil or TryGetProp(recipecls, "Item_2_1", "None") ~='None' then                 
            if g_account_prop_shop_table[shopType] ~= nil then
                AddLuaTimerFuncWithLimitCountEndFunc("ACCOUNT_PROPERTY_SHOP_TRADE_ENTER", 100, resultCount - 1, "EARTH_TOWER_SHOP_TRADE_LEAVE");
        else
            AddLuaTimerFuncWithLimitCountEndFunc("EARTH_TOWER_SHOP_TRADE_ENTER", 100, resultCount - 1, "EARTH_TOWER_SHOP_TRADE_LEAVE");
        end
        
    else        
            
            if g_account_prop_shop_table[shopType] ~= nil and g_account_prop_shop_table[shopType]['propName'] ~= nil then
            AddLuaTimerFuncWithLimitCountEndFunc("ACCOUNT_PROPERTY_SHOP_TRADE_ENTER", 100, 0, "");
        else
            AddLuaTimerFuncWithLimitCountEndFunc("EARTH_TOWER_SHOP_TRADE_ENTER", 100, 0, "EARTH_TOWER_SHOP_TRADE_LEAVE");
        end
    end
    end
end

function YES_SCP_BUY_SHOP_EXEC_1(resultCount, shopType)
    if g_account_prop_shop_table[shopType] ~= nil then
        AddLuaTimerFuncWithLimitCountEndFunc("ACCOUNT_PROPERTY_SHOP_TRADE_ENTER", 100, resultCount - 1, "EARTH_TOWER_SHOP_TRADE_LEAVE");
    else
        AddLuaTimerFuncWithLimitCountEndFunc("EARTH_TOWER_SHOP_TRADE_ENTER", 100, resultCount - 1, "EARTH_TOWER_SHOP_TRADE_LEAVE");
    end
end

function YES_SCP_BUY_SHOP_EXEC_2(resultCount, shopType)
    if g_account_prop_shop_table[shopType] ~= nil  then                    
        AddLuaTimerFuncWithLimitCountEndFunc("ACCOUNT_PROPERTY_SHOP_TRADE_ENTER", 100, 0, "");
    else        
        AddLuaTimerFuncWithLimitCountEndFunc("EARTH_TOWER_SHOP_TRADE_ENTER", 100, 0, "EARTH_TOWER_SHOP_TRADE_LEAVE");
    end
end

function YES_SCP_BUY_SHOP_EXEC_SPECIAL_MISC_CRAFT_1(resultCount) -- 특수 재료 제작
    AddLuaTimerFuncWithLimitCountEndFunc("EARTH_TOWER_SHOP_TRADE_ENTER", 100, resultCount - 1, "EARTH_TOWER_SHOP_TRADE_LEAVE");
end

function YES_SCP_BUY_SHOP_EXEC_SPECIAL_MISC_CRAFT_2() -- 특수 재료 제작
    AddLuaTimerFuncWithLimitCountEndFunc("EARTH_TOWER_SHOP_TRADE_ENTER", 100, 0, "EARTH_TOWER_SHOP_TRADE_LEAVE");
end

function EARTH_TOWER_SHOP_TRADE_ENTER()
	local frame = ui.GetFrame(s_earth_shop_frame_name);
	if frame == nil then
		return
    end

    local parent = GET_CHILD_RECURSIVELY(frame, s_earth_shop_parent_name);
    local control = GET_CHILD_RECURSIVELY(parent, g_earth_shop_control_name);
    
    if frame:GetName() == 'legend_craft' then
        LEGEND_CRAFT_EXECUTE(parent, control);
        return;
    end

    local parentcset = parent;
    local cnt = parentcset:GetChildCount();
    for i = 0, cnt - 1 do
        local eachcset = parentcset:GetChildByIndex(i);    
        if string.find(eachcset:GetName(),'EACHMATERIALITEM_') ~= nil then
            local selected = eachcset:GetUserValue("MATERIAL_IS_SELECTED")
            if selected ~= 'selected' then
                ui.AddText("SystemMsgFrame", ScpArgMsg('NotEnoughRecipe'));
                return;
            end
        end
    end

	local resultlist = session.GetItemIDList();
	local someflag = 0
	for i = 0, resultlist:Count() - 1 do
		local tempitem = resultlist:PtrAt(i);
		if IS_VALUEABLE_ITEM(tempitem.ItemID) == 1 then
			someflag = 1
		end
	end

    session.ResetItemList();

    local pc = GetMyPCObject();
    if pc == nil then
        return;
    end

    local recipeCls = GetClass("ItemTradeShop", parentcset:GetName())
    for index = 1, 5 do
        local clsName = "Item_"..index.."_1";
        local itemName = recipeCls[clsName];
        local recipeItemCnt, invItemCnt, dragRecipeItem, invItem, recipeItemLv, invItemlist = GET_RECIPE_MATERIAL_INFO(recipeCls, index, GetMyPCObject());

        local shopType = frame:GetUserValue("SHOP_TYPE");        
        recipeItemCnt = GET_CURRENT_OVERBUY_COUNT(shopType, recipeItemCnt, recipeCls, GetMyAccountObj()) -- 추가 회득

        if dragRecipeItem ~= nil then
            local itemCount = GET_TOTAL_ITEM_CNT(dragRecipeItem.ClassID);
            if itemCount < recipeItemCnt then
                ui.AddText("SystemMsgFrame", ScpArgMsg('NotEnoughRecipe'));
                break;
            end
        end

        local invItem = session.GetInvItemByName(itemName);
        if "None" ~= itemName then
            if nil == invItem then
                ui.AddText("SystemMsgFrame", ClMsg('NotEnoughRecipe'));
                return;
            else
                if true == invItem.isLockState then
                    ui.SysMsg(ClMsg("MaterialItemIsLock"));
                    return;
                end
                
                session.AddItemID(invItem:GetIESID(), recipeItemCnt);
            end
        end
    end

	local resultlist = session.GetItemIDList();
	
    local edit_itemcount = GET_CHILD_RECURSIVELY(parentcset, "itemcount");
    if edit_itemcount == nil then 
        return; 
    end

    local itemCountGBox = GET_CHILD_RECURSIVELY(parentcset, "gbox");
    local resultCount = tonumber(edit_itemcount:GetText());
    if itemCountGBox:IsVisible() == 0 then
        resultCount = 1;
	end
	local itemCls = GetClass("Item",recipeCls.TargetItem)
	if itemCls.MaxStack ~= 1 then
		local maxStackCount = resultCount * recipeCls.TargetItemCnt
        local invItem = session.GetInvItemByName(recipeCls.TargetItem);
		if invItem ~= nil then
			maxStackCount = maxStackCount + invItem.count
		end
		if maxStackCount > itemCls.MaxStack then
			addon.BroadMsg('NOTICE_Dm_!',ClMsg("ExceedItemGetLimit"),3)
			return
		end
	end
    local cntText = string.format("%s %s", recipeCls.ClassID, resultCount);
    local shopType = frame:GetUserValue("SHOP_TYPE");
	if shopType == 'EarthTower' then
		item.DialogTransaction("EARTH_TOWER_SHOP_TREAD", resultlist, cntText);
	elseif shopType == 'EarthTower2' then
		item.DialogTransaction("EARTH_TOWER_SHOP_TREAD2", resultlist, cntText);
	elseif shopType == 'EventShop' then
		item.DialogTransaction("EVENT_ITEM_SHOP_TREAD", resultlist, cntText);
	elseif shopType == 'EventShop2' then
		item.DialogTransaction("EVENT_ITEM_SHOP_TREAD2", resultlist, cntText);
	elseif shopType == 'KeyQuestShop1' then
		item.DialogTransaction("KEYQUESTSHOP1_SHOP_TREAD", resultlist, cntText);
	elseif shopType == 'KeyQuestShop2' then
		item.DialogTransaction("KEYQUESTSHOP2_SHOP_TREAD", resultlist, cntText);
	elseif shopType == 'HALLOWEEN' then
		item.DialogTransaction("HALLOWEEN_SHOP_TREAD", resultlist, cntText);
	elseif shopType == 'EventShop3' then
		item.DialogTransaction("EVENT_ITEM_SHOP_TREAD3", resultlist, cntText);	
	elseif shopType == 'EventShop4' then
		item.DialogTransaction("EVENT_ITEM_SHOP_TREAD4", resultlist, cntText);
    elseif shopType == 'EventShop8' then
        item.DialogTransaction("EVENT_ITEM_SHOP_TREAD8", resultlist, cntText);	
	elseif shopType == 'MCShop1' then
		item.DialogTransaction("MASSIVE_CONTENTS_SHOP_TREAD1", resultlist, cntText);
	elseif shopType == 'DailyRewardShop' or shopType == 'DailyRewardShop_Season' then
		item.DialogTransaction("DAILY_REWARD_SHOP_1_TREAD1", resultlist, cntText);
    elseif shopType == 'Bernice' then
        item.DialogTransaction("SoloDungeon_Bernice_SHOP", resultlist, cntText);
    elseif shopType == 'NewChar' then
        item.DialogTransaction("NEW_CHAR_SHOP_1_TREAD1", resultlist, cntText);
	elseif shopType == 'VividCity2_Shop' then
        item.DialogTransaction("EVENT_VIVID_CITY2_SHOP_1_TREAD1", resultlist, cntText);
    elseif shopType == 'EventTotalShop1906' then
        item.DialogTransaction("EVENT_1906_TOTAL_SHOP_1_TREAD1", resultlist, cntText);
    elseif shopType == 'EventIceShop1907' then
        item.DialogTransaction("EVENT_1907_ICE_SHOP_1_TREAD1", resultlist, cntText);
    elseif shopType == 'EventMiniMoonShop1909' then
--        item.DialogTransaction("EVENT_1909_MINI_FULLMOON_SHOP_1_TREAD1", resultlist, cntText);
    elseif shopType == 'HalloweenShop' then
        -- item.DialogTransaction("EVENT_1910_HALLOWEEN_SHOP_1_TREAD1", resultlist, cntText);
    elseif shopType == 'Event4thShop1912' then
        item.DialogTransaction("EVENT1912_4TH_SHOP_1_TREAD1", resultlist, cntText);
    elseif shopType == 'Sell_TPShop1912' then
        item.DialogTransaction("SELL_TPSHOP1912_SHOP_1_TREAD1", resultlist, cntText);
    elseif shopType == 'Buy_TPShop1912' then
        item.DialogTransaction("BUY_TPSHOP1912_SHOP_1_TREAD1", resultlist, cntText);
    elseif shopType == 'GrewUpShop' then
--        item.DialogTransaction("EVENT1912_GREWUP_SHOP_1_TREAD1", resultlist, cntText);
    elseif shopType == 'NewYearShop' then
        item.DialogTransaction("EVENT_2001_NEWYEAR_SHOP_1_THREAD1", resultlist, cntText);
    -- elseif shopType == 'TeamBattleLeagueShop' then
    --     item.DialogTransaction("TEAM_BATTLE_LEAGUE_SHOP_1_THREAD", resultlist, cntText);
    elseif shopType == 'FishingShop2002' then
        -- item.DialogTransaction("EVENT_2002_FISHING_SHOP_1_THREAD1", resultlist, cntText);
	else
        local strArgList = NewStringList();
		strArgList:Add(shopType);
        item.DialogTransaction("EVENT_SHOP_1_THREAD1", resultlist, cntText,strArgList);
	end
end

-- 용병단 증표
function ACCOUNT_PROPERTY_SHOP_TRADE_ENTER()    
	local frame = ui.GetFrame(s_earth_shop_frame_name);
	if frame == nil then
		return
    end

    local shopType = frame:GetUserValue("SHOP_TYPE");
    if g_account_prop_shop_table[shopType] == nil then
        return
    end    

    local parent = GET_CHILD_RECURSIVELY(frame, s_earth_shop_parent_name);    
        
    local parentcset = parent;
    local cnt = parentcset:GetChildCount();
    for i = 0, cnt - 1 do
        local eachcset = parentcset:GetChildByIndex(i);    
        if string.find(eachcset:GetName(),'EACHMATERIALITEM_') ~= nil then
            local selected = eachcset:GetUserValue("MATERIAL_IS_SELECTED")
            if selected ~= 'selected' then
                ui.AddText("SystemMsgFrame", ScpArgMsg('NotEnoughRecipe'));                
                return;
            end
        end
    end
	
    session.ResetItemList();
    session.AddItemID(tostring(0), 1);

    local recipeCls = GetClass("ItemTradeShop", parentcset:GetName())    
	local resultlist = session.GetItemIDList();
	local cntText = string.format("%s %s", recipeCls.ClassID, 1);
	
    local edit_itemcount = GET_CHILD_RECURSIVELY(parentcset, "itemcount");
    if edit_itemcount == nil then 
        return; 
    end

    local itemCountGBox = GET_CHILD_RECURSIVELY(parentcset, "gbox");
    local resultCount = tonumber(edit_itemcount:GetText());
    if itemCountGBox:IsVisible() == 0 then
        resultCount = 1;
    end
    

      
    -- cls Id / 구매 갯수
    cntText = string.format("%s %s", recipeCls.ClassID, resultCount);
    if shopType == 'PVPMine' then
    item.DialogTransaction("PVP_MINE_SHOP", resultlist, cntText);    
    elseif shopType == 'SilverGachaShop' then
        item.DialogTransaction("SILVER_GACHA_SHOP", resultlist, cntText);
    elseif string.find(shopType, 'Certificate') ~= nil then
        local str_list = NewStringList();
        str_list:Add(shopType)        
        item.DialogTransaction('Certificate_SHOP', resultlist, cntText, str_list);
    elseif shopType == 'TeamBattleLeagueShop' then --  팀배상점
        item.DialogTransaction("TEAM_BATTLE_LEAGUE_SHOP_1_THREAD", resultlist, cntText);
    elseif shopType == 'EVENT_TOS_WHOLE_SHOP' then --  이벤트 상점
        item.DialogTransaction("EVENT_TOS_WHOLE_SHOP", resultlist, cntText);
    end

end

function EARTH_TOWER_SHOP_TRADE_LEAVE()
	local frame = ui.GetFrame(s_earth_shop_frame_name);
	if frame == nil then
		return
	end

    local parent = GET_CHILD_RECURSIVELY(frame, s_earth_shop_parent_name);
	local control = GET_CHILD_RECURSIVELY(parent, g_earth_shop_control_name);
	if control == nil or parent == nil then
		return
	end
	
    session.ResetItemList();
	
    local ctrlSet = parent;

    local recipecls = GetClass('ItemTradeShop', ctrlSet:GetName());
    if recipecls == nil then
        return;
    end

    local targetItem = GetClass("Item", recipecls.TargetItem);

    -- itemName Reset
    local itemName = GET_CHILD_RECURSIVELY(ctrlSet, "itemName");
    if itemName ~= nil then
        itemName:SetTextByKey("value", targetItem.Name.." ["..recipecls.TargetItemCnt..ScpArgMsg("Piece").."]");
    end

    if targetItem.StringArg == "EnchantJewell" and recipecls.TargetItemAppendProperty ~= 'None' then
        itemName:SetTextByKey("value", "[Lv. "..recipecls.TargetItemAppendValue.."] "..targetItem.Name .. " [" .. recipecls.TargetItemCnt .. ScpArgMsg("Piece") .. "]");
    end  

    for i = 1, 5 do
        if TryGetProp(recipecls, "Item_"..i.."_1", 'None') ~= "None" then
            local recipeItemCnt, invItemCnt, dragRecipeItem, invItem, recipeItemLv, invItemlist  = GET_RECIPE_MATERIAL_INFO(recipecls, i, GetMyPCObject());
            local eachSet = GET_CHILD_RECURSIVELY(ctrlSet, "EACHMATERIALITEM_"..i);
            if invItemlist == nil and eachSet~=nil then
               -- needCount Reset
               local needCount = GET_CHILD_RECURSIVELY(eachSet, "needcount");
                               
                local shopType = frame:GetUserValue("SHOP_TYPE");                
                recipeItemCnt = GET_CURRENT_OVERBUY_COUNT(shopType, recipeItemCnt, recipecls, GetMyAccountObj()) -- 추가 회득                
                if string.find(shopType, 'Certificate') == nil then
               needCount:SetTextByKey("count", recipeItemCnt)
                else
                    needCount:SetTextByKey("count", M_NUMBER_FORMAT(recipeItemCnt))
                end
                
               -- material icon Reset
               eachSet:SetUserValue("MATERIAL_IS_SELECTED", 'nonselected');

               local slot = GET_CHILD_RECURSIVELY(eachSet, "slot");
               if slot ~= nil then
                   SET_SLOT_ITEM_CLS(slot, dragRecipeItem);
                   slot:SetEventScript(ui.DROP, "ITEMCRAFT_ON_DROP");
                   slot:SetEventScriptArgNumber(ui.DROP, dragRecipeItem.ClassID);
                   slot:SetEventScriptArgString(ui.DROP, tostring(recipeItemCnt));
                   slot:EnableDrag(0); 
                   slot:SetOverSound('button_cursor_over_2');
                   slot:SetClickSound('button_click');

                   local icon = slot:GetIcon();
                   icon:SetColorTone('33333333')
                   eachSet:SetUserValue("ClassName", dragRecipeItem.ClassName)
               end

               -- btn Reset
               local btn = GET_CHILD_RECURSIVELY(eachSet, "btn");
               if btn ~= nil then
                    btn:ShowWindow(1);
               end
            end
        end
    end

    -- edittext Reset
    local edit_itemcount = GET_CHILD_RECURSIVELY(ctrlSet, "itemcount");
    if edit_itemcount ~= nil then
        edit_itemcount:SetText(1);
    end

    INVENTORY_SET_CUSTOM_RBTNDOWN("None");
    RESET_INVENTORY_ICON();

    ctrlSet:Invalidate();
end

function EARTHTOWERSHOP_UPBTN(frame, ctrl)
    if ui.CheckHoldedUI() == true then
        return;
    end

    if frame == nil then
        return
    end
        
    local topFrame = frame:GetTopParentFrame()
    if topFrame == nil then
        return
    end

    EARTHTOWERSHOP_CHANGECOUNT(frame, ctrl, 1);
end

function EARTHTOWERSHOP_DOWNBTN(frame, ctrl)
    if ui.CheckHoldedUI() == true then
        return;
    end

    if frame == nil then
        return
    end
        
    local topFrame = frame:GetTopParentFrame()
    if topFrame == nil then
        return
    end

    EARTHTOWERSHOP_CHANGECOUNT(frame, ctrl, -1);
end

function EARTHTOWERSHOP_CHANGECOUNT(frame, ctrl, change)    
    if ctrl == nil then return; end
    
    local gbox = ctrl:GetParent(); if gbox == nil then return; end
    local parentCtrl = gbox:GetParent(); if parentCtrl == nil then return; end
    local ctrlset = parentCtrl:GetParent(); if ctrlset == nil then return; end
    local cnt = ctrlset:GetChildCount();

    -- item count increase
    local countText = EARTHTOWERSHOP_CHANGECOUNT_NUM_CHANGE(ctrlset,change)
    if cnt ~= nil then
        for i = 0, cnt - 1 do
            local eachSet = ctrlset:GetChildByIndex(i);
            if string.find(eachSet:GetName(), "EACHMATERIALITEM_") ~= nil then
                local recipecls = GetClass('ItemTradeShop', ctrlset:GetName());
                local targetItem = GetClass("Item", recipecls.TargetItem);
                
                -- item Name Setting
                local targetItemName_text = GET_CHILD_RECURSIVELY(ctrlset, "itemName");
                if targetItem.StringArg == "EnchantJewell" and recipecls.TargetItemAppendProperty ~= 'None' then
                    targetItemName_text:SetTextByKey("value", "[Lv. "..recipecls.TargetItemAppendValue.."] "..targetItem.Name .. " [" .. recipecls.TargetItemCnt * countText .. ScpArgMsg("Piece") .. "]");
                else
                    targetItemName_text:SetTextByKey("value", targetItem.Name.." ["..recipecls.TargetItemCnt * countText..ScpArgMsg("Piece").."]");
                end            

                for j = 1, 5 do
                    if TryGetProp(recipecls, "Item_"..j.."_1", 'None') ~= "None" then
                       local recipeItemCnt, recipeItemLv = GET_RECIPE_REQITEM_CNT(recipecls, "Item_"..j.."_1", GetMyPCObject());

                       local main_frame = ui.GetFrame("earthtowershop");
                       local shopType = main_frame:GetUserValue("SHOP_TYPE");
                       
                        recipeItemCnt = GET_TOTAL_AMOUNT_OVERBUY(shopType, recipeItemCnt, recipecls, GetMyAccountObj(), tonumber(countText))                        

                        if IS_OVERBUY_ITEM(shopType, recipecls, GetMyAccountObj()) == true then
                            local needcountText = GET_CHILD_RECURSIVELY(eachSet, "needcount", "ui::CSlot");
                            needcountText:SetTextByKey("count", recipeItemCnt);
                        else
                       -- needCnt Setting
                       local needcountText = GET_CHILD_RECURSIVELY(eachSet, "needcount", "ui::CSlot");
                            
                            if string.find(shopType, 'Certificate') == nil then
                       needcountText:SetTextByKey("count", countText * recipeItemCnt);
                            else
                                needcountText:SetTextByKey("count", M_NUMBER_FORMAT(countText * recipeItemCnt));
                            end
                    end
                end
            end
            end

            eachSet:Invalidate();
        end
    end
end

function UPDATE_EARTHTOWERSHOP_CHANGECOUNT(parent, ctrl)
    EARTHTOWERSHOP_CHANGECOUNT(parent,ctrl,0)
end

function EARTHTOWERSHOP_CHANGECOUNT_NUM_CHANGE(ctrlset,change)
    local recipecls = GetClass('ItemTradeShop', ctrlset:GetName());

    local edit_itemcount = GET_CHILD_RECURSIVELY(ctrlset, "itemcount");
    local countText = tonumber(edit_itemcount:GetText());
    if countText == nil then
        countText = 0
    end
    countText = countText + change
    
    local target_acc = TryGetProp(recipecls, 'TargetAccountProperty', 'None')
    local max_target_acc = TryGetProp(recipecls, 'MaxTargetAccountProperty', 9999)

    if target_acc ~= 'None' then
        local now = TryGetProp(GetMyAccountObj(), target_acc, 0)
        if now + countText > max_target_acc then
            countText = countText - 1
        end
    end

    if countText < 0 then
        countText = 0
    elseif countText > 9999 then
        countText = 9999
    end
    
    if recipecls.NeedProperty ~= 'None' then
		local sObj = GetSessionObject(GetMyPCObject(), "ssn_shop");
        local sCount = TryGetProp(sObj, recipecls.NeedProperty); 
        if sCount < countText then
            countText = sCount
        end
    end
    if recipecls.AccountNeedProperty ~= 'None' then
        local aObj = GetMyAccountObj()
        local sCount = TryGetProp(aObj, recipecls.AccountNeedProperty); 
--        --EVENT_1906_SUMMER_FESTA
--        local time = geTime.GetServerSystemTime()
--        time = time.wYear..time.wMonth..time.wDay
--        if time < '2019725' then
--            if recipecls.ClassName == 'EventTotalShop1906_25' or recipecls.ClassName == 'EventTotalShop1906_26' then
--                sCount = sCount - 2
--            end
--        end

        local frame = ui.GetFrame("earthtowershop");
        local shopType = frame:GetUserValue("SHOP_TYPE");
        if IS_OVERBUY_ITEM(shopType, recipecls, aObj) == true then 
            sCount = countText            
            if IS_EXCEED_OVERBUY_COUNT(shopType, aObj, recipecls, 1) == true then
                sCount = 0
            end
            countText = TryGetProp(recipecls, 'MaxOverBuyCount', 100) - TryGetProp(aObj, TryGetProp(recipecls, 'OverBuyProperty', 'None'), 0)                    
        end

        if sCount < countText then
            countText = sCount
        end
    end
    edit_itemcount:SetText(countText);
    return countText;
end

function CRAFT_ITEM_CANCEL(eachSet, slot, stringArg)
    if eachSet~=nil then
        eachSet:SetUserValue("MATERIAL_IS_SELECTED", 'nonselected');
        eachSet:SetUserValue(eachSet:GetName(), 'None');

        local slot = GET_CHILD_RECURSIVELY(eachSet, "slot");
        if slot ~= nil then
            slot:SetEventScript(ui.DROP, "ITEMCRAFT_ON_DROP");
            slot:EnableDrag(0); 
            local icon = slot:GetIcon();
            icon:SetColorTone('33333333')
            session.RemoveItemID(stringArg);
        end

        -- btn Reset
        local btn = GET_CHILD_RECURSIVELY(eachSet, "btn");
        if btn ~= nil then
            btn:ShowWindow(1);
        end
    end
    
    local invframe = ui.GetFrame('inventory');
    INVENTORY_UPDATE_ICONS(invframe);
end



local pre_season_coin_shop = {}
pre_season_coin_shop['GabijaCertificate'] = 'REQ_PREV_SEASON_COIN_SHOP_OPEN'
pre_season_coin_shop['VakarineCertificate'] = 'REQ_SEASON_COIN_SHOP_OPEN'
pre_season_coin_shop['RadaCertificate'] = 'REQ_RadaCertificate_COIN_SHOP_OPEN'
pre_season_coin_shop['JurateCertificate'] = 'REQ_JurateCertificate_COIN_SHOP_OPEN'
pre_season_coin_shop['AustejaCertificate'] = 'REQ_AustejaCertificate_COIN_SHOP_OPEN'

function EARTHTOWERSHOP_POINT_BUY_OPEN()
    local frame = ui.GetFrame('earthtowershop')
    local shopType = frame:GetUserValue("SHOP_TYPE")

    if shopType == "SilverGachaShop" then
        REQ_ITEM_POINT_EXTRACTOR_OPEN("Mileage_SilverGacha")
        ui.GetFrame('item_point_extractor'):SetMargin(575, 5, 0, 0)
    elseif string.find(shopType, 'Certificate') ~= nil then
        ui.CloseFrame('earthtowershop')
        control.CustomCommand(pre_season_coin_shop[shopType],0);    
    elseif shopType == "Archeology_Lv470" or shopType =="Archeology_Lv530" then
        REQ_ITEM_POINT_EXTRACTOR_OPEN("ARCHEOLOGY_COIN")
        ui.GetFrame('item_point_extractor'):SetMargin(575, 5, 0, 0)
    elseif shopType == "event_2512_ice_piece" then
        REQ_ITEM_POINT_EXTRACTOR_OPEN("event_2512_ice_piece")
        ui.GetFrame('item_point_extractor'):SetMargin(575, 5, 0, 0)
    end
end

function EARTHTOWERSHOP_PREV_SHOP_OPEN()
    local frame = ui.GetFrame('earthtowershop')
	if frame:IsVisible() == 1 then
		ui.CloseFrame('earthtowershop')
	end

    local shopType = frame:GetUserValue("SHOP_TYPE")
    
    for i = 1, #shop_list do
        if shop_list[i] == shopType then
            if shop_list[i - 1] ~= nil then                                
                frame:SetUserValue("SHOP_TYPE", shop_list[i - 1]);
                ui.OpenFrame('earthtowershop');
                break
            end
        end
    end
end

---------------------- EVENT_2011_5TH
function EVENT_2011_5TH_SPECIAL_SHOP_UPDATE_BTN_CLICK(parent, ctrl, argStr, argNum)
	if ui.CheckHoldedUI() == true then
		return;
    end
    
    local coinTOS_count = GET_INV_ITEM_COUNT_BY_PROPERTY({{Name = "ClassName", Value = "Event_2011_TOS_Coin"}}, false);
    if coinTOS_count < GET_EVENT_2011_5TH_SPECIAL_SHOP_UPDATE_NEED_COIN_COUNT() then
        ui.SysMsg(ClMsg("NotEnoughRecipe"));
        return;
    end

    ui.SetHoldUI(true);
    ReserveScript("RELEASE_2011_5TH_SPECIAL_SHOP_UPDATE_HOLD()", 2);
    ctrl:SetEnable(0);

    control.CustomCommand("REQ_EVENT_2011_5TH_SPECIAL_SHOP_UPDATE", 0);
end

function RELEASE_2011_5TH_SPECIAL_SHOP_UPDATE_HOLD()
    local frame = ui.GetFrame("earthtowershop");
    local shopType = frame:GetUserValue("SHOP_TYPE");
    if string.find(shopType, "EVENT_2011_5TH_Special_Shop") == nil then
        return;
    end

    local ctrlSet = GET_CHILD_RECURSIVELY(frame, "EVENT_CONTROL_SET");
    if ctrlSet ~= nil then
        local ctrl = GET_CHILD(ctrlSet, "EVENT_CONTROL_SET");
    end

    local btn = GET_CHILD(ctrlSet, "update_Btn");
    btn:SetEnable(1);

    ui.SetHoldUI(false);
end


function REQ_BOSS_CO_OP_SHOP_OPEN()
    local frame = ui.GetFrame("earthtowershop")
    frame:SetUserValue("SHOP_TYPE", 'BOSS_COOP_SHOP')
    ui.OpenFrame('earthtowershop')
end


function REQ_BOUNTYHUNT_NPC_TRADE_SHOP_OPEN()
    local frame = ui.GetFrame("earthtowershop")
    local pcetc = GetMyEtcObject()
    local tradeitem = TryGetProp(pcetc, 'BountyHunt_NPC_TradeItem', 'None')
    if tradeitem == nil then return end
    local shoptype = TryGetProp(GetClassByStrProp('ItemTradeShop', 'Item_1_1', tradeitem), 'ShopType', 'None')

    frame:SetUserValue("SHOP_TYPE", shoptype)
    ui.OpenFrame('earthtowershop')
end

function REQ_BOUNTYHUNT_NPC_TRADE_SHOP_CLOSE()
    local frame = ui.GetFrame("earthtowershop")
    if frame == nil then return end

    local shoptype = frame:GetUserValue("SHOP_TYPE")
    if string.find(shoptype, 'BOUNTY_NPC_TRADE_SHOP_') ~= nil then
        ui.CloseFrame('earthtowershop')
    end
end

function SET_ITEM_SALE_STATE(ctrlset, cls)
    -- SaleVal 값에 따른 UI 변경 로직
    local salebox = GET_CHILD_RECURSIVELY(ctrlset, "sale")
    local SaleVal = tonumber(TryGetProp(cls, "SaleVal", 0))
    if cls and SaleVal > 0 then
        --sale의 값은 10 단위로 10~70까지만 사용 가능하다.
        local salefire = GET_CHILD(salebox, "salefire")
        local salenum = GET_CHILD(salebox, "salenum")
        local firetext = "SaleFire"..SaleVal
        local numtext = "Sale"..SaleVal
        salefire:SetImage(firetext)
        salenum:SetImage(numtext)

        --salefire 위치 조절
        if SaleVal == 10 then
            salefire:SetMargin(0, 86, 0, 0)
        else
            salefire:SetMargin(0, 2, 0, 0)
        end 
        salebox:ShowWindow(1)
    else
        salebox:ShowWindow(0)
    end
end