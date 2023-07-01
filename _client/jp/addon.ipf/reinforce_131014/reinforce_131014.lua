function REINFORCE_131014_ON_INIT(addon, frame)
	
end

function _CHECK_REINFORCE_ITEM(slot)
	local item = GET_SLOT_ITEM(slot);
	if item ~= nil then
		local obj = GetIES(item:GetObject());
		if REINFORCE_ABLE_131014(obj) == 1 or IS_MORU_ITEM(obj) == 1 then
			slot:GetIcon():SetGrayStyle(0);
		else
			slot:GetIcon():SetGrayStyle(1);
		end
	end
end

function REINFORCE_131014_ITEM_LOCK(guid, from_hair_enchantchip)
	if nil == guid then
		guid = 'None'
	end
	
	local invframe = ui.GetFrame("inventory");
	if invframe ~= nil then
		if from_hair_enchantchip == nil then
			invframe:SetUserValue("ITEM_GUID_IN_MORU", guid);
			INVENTORY_ON_MSG(invframe, 'UPDATE_ITEM_REPAIR', "Equip");
		end
	end

	local rankresetFrame = ui.GetFrame("rankreset");
	if 1 == rankresetFrame:IsVisible() then
		RANKRESET_PC_TIMEACTION_STATE(rankresetFrame)
	end
end

function REINFORCE_131014_OPEN(frame)
	local invframe = ui.GetFrame("inventory");
	--SET_SLOT_APPLY_FUNC(invframe, "_CHECK_REINFORCE_ITEM");
end

function REINFORCE_131014_CLOSE(frame)
	local invframe = ui.GetFrame("inventory");
	--SET_SLOT_APPLY_FUNC(invframe, "None");
end

function REINFORCE_131014_GET_ITEM(frame)
	local fromItemSlot = GET_CHILD(frame, "fromItemSlot", "ui::CSlot");
	local fromMoruSlot = GET_CHILD(frame, "fromMoruSlot", "ui::CSlot");
	local fromItem = GET_SLOT_ITEM(fromItemSlot);
	local fromMoru = GET_SLOT_ITEM(fromMoruSlot);
	
	return fromItem, fromMoru;
end

function REINFORCE_131014_UPDATE_MORU_COUNT(frame)
	local fromItem, fromMoru = REINFORCE_131014_GET_ITEM(frame);
	local hitCountDesc = frame:GetChild("hitCountDesc");
	local hitPriceDesc = GET_CHILD(frame, "hitPriceDesc", "ui::CRichText")
	local fromPRTxt = GET_CHILD_RECURSIVELY(frame, "t_fromItemPR", "ui::CRichText")
	if fromItem == nil or fromMoru == nil then
		hitCountDesc:ShowWindow(0);
		hitPriceDesc:ShowWindow(0);
		fromPRTxt:ShowWindow(0);
		return;
	end

	hitCountDesc:ShowWindow(1);
	hitPriceDesc:ShowWindow(1);
	fromPRTxt:ShowWindow(1);

	local moruObj = GetIES(fromMoru:GetObject());
	local fromItemObj = GetIES(fromItem:GetObject());
	local toItemObj = GetIES(fromMoru:GetObject());
	local hitCount = GET_REINFORCE_HITCOUNT(fromItemObj, toItemObj);
	hitCountDesc:SetTextByKey("hitcount", hitCount);

	local fromItemPR = TryGetProp(fromItemObj, 'PR', 0)
	local prColor = '#00c4c6'
	if fromItemPR == 0 then
		prColor = '#ff1212'
	end
	fromPRTxt:SetTextByKey('color', prColor)
	fromPRTxt:SetTextByKey('value', ClMsg("PR").." "..fromItemPR)
	REINFORCE_SKIP_OPTION_DRAW(frame, 1);

	-- Event_LuckyBreak
	-- if ENABLE_EVENT_LUCKYBREAK_REINFOCE(fromItemObj, TryGetProp(moruObj, "StringArg", "None")) == true then
	-- 	fromPRTxt:SetTextByKey('value', ClMsg("SHOWLIST_ITEM_TYPE_4"))
	-- 	REINFORCE_SKIP_OPTION_DRAW(frame, 0);
	-- end
	
	local pc = GetMyPCObject()
	local price = GET_REINFORCE_PRICE(fromItemObj, moruObj, pc);
	local msg = GET_COMMAED_STRING(price)
    
    -- EVENT_1903_WEEKEND
    --if SCR_EVENT_1903_WEEKEND_CHECK('REINFORCE', false) == 'YES' then
    --    msg = msg..ScpArgMsg('EVENT_REINFORCE_DISCOUNT_MSG1')
    --end
    
    -- burning_event
    if IsBuffApplied(pc, "Event_Reinforce_Discount_50") == "YES" then
        msg = msg..ScpArgMsg('EVENT_REINFORCE_DISCOUNT_MSG1')
	end
	
	--steam_new_world
	-- if IsBuffApplied(pc, "Event_Steam_New_World_Buff") == "YES" then
	-- 	msg = msg..ScpArgMsg('EVENT_REINFORCE_DISCOUNT_MSG1')
	-- end
	
    if toItemObj.StringArg =='Reinforce_Discount_50' then
        msg = msg..ScpArgMsg('EVENT_REINFORCE_DISCOUNT_MSG1')
    end
    
--    --EVENT_1804_TRANSCEND_REINFORCE
--	if SCR_EVENT_REINFORCE_DISCOUNT_CHECK(pc) == 'YES' then
--	    msg = msg..ScpArgMsg('EVENT_REINFORCE_DISCOUNT_MSG1')
--	end
    
    local retPrice, retCouponList = SCR_REINFORCE_COUPON_PRECHECK(pc, price)
    
    if price == retPrice then
    	hitPriceDesc:SetTextByKey("price", msg);
    else
        msg = GET_COMMAED_STRING(retPrice)
    	hitPriceDesc:SetTextByKey("price", msg..ScpArgMsg('EVENT_REINFORCE_COUPON_MSG1','VALUE',GET_COMMAED_STRING(price-retPrice)));
    	local msgBoxText
    	for i = 1, #retCouponList do
    	    if msgBoxText == nil then
    	        msgBoxText = ScpArgMsg('EVENT_REINFORCE_COUPON_MSG2')..'{nl}'..ScpArgMsg('EVENT_REINFORCE_COUPON_MSG3','ITEM',GetClassString('Item',retCouponList[i][1],'Name'),'COUNT',retCouponList[i][3])
    	    else
    	        msgBoxText = msgBoxText..'{nl}'..ScpArgMsg('EVENT_REINFORCE_COUPON_MSG3','ITEM',GetClassString('Item',retCouponList[i][1],'Name'),'COUNT',retCouponList[i][3])
    	    end
        end
        
        if REINFORCE_131014_SKIP_COUPON_INFO() == false then
            ui.MsgBox_NonNested(msgBoxText,0x00000000)
        end
    end

end

function REINFORCE_131014_IS_ABLE(frame)	
	local fromItem, fromMoru = GET_REINFORCE_TARGET_AND_MORU(frame);
	if fromItem == nil or fromMoru == nil then
		return false;
	end

	return true;
end

function REINFORCE_131014_MSGBOX(frame)    
	local fromItem, fromMoru = GET_REINFORCE_TARGET_AND_MORU(frame);
	local fromItemObj = GetIES(fromItem:GetObject());
	local moruObj = GetIES(fromMoru:GetObject());
	
	-- Event_LuckyBreak
	-- if ENABLE_EVENT_LUCKYBREAK_REINFOCE(fromItemObj, TryGetProp(moruObj, "StringArg", "None")) == true then
	-- 	REINFORCE_131014_EXEC();
	-- 	return;
	-- end

	local curReinforce = fromItemObj.Reinforce_2;
	local curPR = fromItemObj.PR;

	local strArg = TryGetProp(moruObj, "StringArg", "None")
	if strArg == "blessed_ruby_Moru" or strArg == "blessed_gold_Moru" then
		if TryGetProp(fromItemObj, "UseLv", 1) > 440 then
			ui.SysMsg(ScpArgMsg('CanNotUseItemLv'))
			return;
		end
	end
	
	local not_destory, moru_type = IS_MORU_NOT_DESTROY_TARGET_ITEM(moruObj)
    local isDanger = (curPR == 0 and not_destory == false)
    local skipWarning = REINFORCE_131014_SKIP_OVER5_INFO()
	local pc = GetMyPCObject();

	local price = GET_REINFORCE_PRICE(fromItemObj, moruObj, pc)	
    local retPrice, retCouponList = SCR_REINFORCE_COUPON_PRECHECK(pc, price)
	if IsGreaterThanForBigNumber(retPrice, GET_TOTAL_MONEY_STR()) == 1 then
		ui.AddText("SystemMsgFrame", ScpArgMsg('NotEnoughMoney'));
		return;
	end
	
	local classType = TryGetProp(fromItemObj,"ClassType");
    DISABLE_BUTTON_DOUBLECLICK("reinforce_131014","exec", 1)

    if curReinforce >= 5 then
        -- 5강 이상 강화 안내문을 스킵할 경우
        if skipWarning == true then
            if isDanger == true then
                REINFORCE_131014_WARNING()
            else
                REINFORCE_131014_EXEC()
            end

        -- 5강 이상 강화 안내문을 스킵하지 않을 경우
        else
            if isDanger == true then
                ui.MsgBox(ScpArgMsg("ProcessReinforceBy{Name}Moru", "Name", moruObj.Name), 'REINFORCE_131014_WARNING', "None");
            else
                ui.MsgBox(ScpArgMsg("ProcessReinforceBy{Name}Moru", "Name", moruObj.Name), 'REINFORCE_131014_EXEC', "None");
            end
        end
    else
        REINFORCE_131014_EXEC()
    end
end

function REINFORCE_131014_EXEC(checkReuildFlag)
	local frame = ui.GetFrame("reinforce_131014");
	local fromItem, fromMoru = REINFORCE_131014_GET_ITEM(frame);
	if fromItem ~= nil and fromMoru ~= nil then
		if checkReuildFlag ~= false then
			local fromItemObj = GetIES(fromItem:GetObject());
			if TryGetProp(fromItemObj, 'Rebuildchangeitem', 0) > 0 then		
				ui.MsgBox(ScpArgMsg('IfUDoCannotExchangeWeaponType'), 'REINFORCE_131014_EXEC(false)', 'None');
				return;
			end
		end

		session.ResetItemList();
		session.AddItemID(fromItem:GetIESID());
		session.AddItemID(fromMoru:GetIESID());
		local resultlist = session.GetItemIDList();
		item.DialogTransaction("ITEM_REINFORCE_131014", resultlist);
		frame:ShowWindow(0);
	end
	
	local fromItemSlot = GET_CHILD(frame, "fromItemSlot", "ui::CSlot");
	local fromMoruSlot = GET_CHILD(frame, "fromMoruSlot", "ui::CSlot");
	CLEAR_SLOT_ITEM_INFO(fromItemSlot);
	CLEAR_SLOT_ITEM_INFO(fromMoruSlot);

	REINFORCE_131014_UPDATE_MORU_COUNT(frame);

end

function GET_REINFORCE_TARGET_AND_MORU(frame)
	local fromItemSlot = GET_CHILD(frame, "fromItemSlot", "ui::CSlot");
	local fromMoruSlot = GET_CHILD(frame, "fromMoruSlot", "ui::CSlot");
	local fromItem = GET_SLOT_ITEM(fromItemSlot);
	local fromMoru = GET_SLOT_ITEM(fromMoruSlot);
	return fromItem, fromMoru;
end

function REINFORCE_131014_WARNING()
	local frame = ui.GetFrame("reinforce_131014")
	local fromItem, fromMoru = REINFORCE_131014_GET_ITEM(frame)
	if fromItem ~= nil and fromMoru ~= nil then
		WARNINGMSGBOX_EX_REINFORCE_OPEN(frame)
	end
end

function REINFORCE_131014_SKIP_OVER5_INFO()
    local frame = ui.GetFrame("reinforce_131014")
    local checkbox = AUTO_CAST(GET_CHILD_RECURSIVELY(frame, "skipOver5"))

    return checkbox:IsChecked() == 1
end

function REINFORCE_131014_SKIP_COUPON_INFO()
    local frame = ui.GetFrame("reinforce_131014")
    local checkbox = AUTO_CAST(GET_CHILD_RECURSIVELY(frame, "skipCouponInfo"))

    return checkbox:IsChecked() == 1
end

function REINFORCE_SKIP_OPTION_DRAW(frame, isValue)
	local skip_gb = GET_CHILD(frame, "skip_gb");
	skip_gb:ShowWindow(isValue);

	if isValue == 1 then
		frame:Resize(420, 460);
	else
		frame:Resize(420, 350);
	end

end