function EXCHANGE_ON_INIT(addon, frame)
   addon:RegisterMsg('EXCHANGE_START', 'EXCHANGE_MSG_START');
   addon:RegisterMsg('EXCHANGE_UPDATE', 'EXCHANGE_MSG_UPDATE');   
   addon:RegisterMsg('EXCHANGE_CANCEL', 'EXCHANGE_MSG_END');
   addon:RegisterMsg('EXCHANGE_SUCCESS', 'EXCHANGE_MSG_END');
   addon:RegisterMsg('EXCHANGE_AGREE', 'EXCHANGE_MSG_AGREE');
   addon:RegisterMsg('EXCHANGE_FINALAGREE', 'EXCHANGE_MSG_FINALAGREE');
   addon:RegisterMsg('EXCHANGE_REQUEST', 'EXCHANGE_MSG_REQUEST');
end 

function BEING_TRADING_STATE()
	local exchangeFrame = ui.GetFrame("exchange");
	if nil == exchangeFrame then
		return false;
	end
	
	local nameRichText = GET_CHILD_RECURSIVELY(exchangeFrame,'opponentname','ui::CRichText');
	if nameRichText == nil then
		return false;
	end

	local targetName = nameRichText:GetTextByKey("value");
	if targetName == "" or targetName == "None" then
		return false;
	end

	ui.MsgBox(ScpArgMsg("CannotLockUnlockWhenExchanging"));
	return true;
end

function EXCHANGE_ON_OPEN(frame)
	packet.RequestItemList(IT_WAREHOUSE);
	INVENTORY_SET_CUSTOM_RBTNDOWN("EXCHANGE_INV_RBTN");
	local myfinalbutton = GET_CHILD_RECURSIVELY(frame,'myfinalagree','ui::CButton');
	local oppfinalbutton = GET_CHILD_RECURSIVELY(frame,'opponentfinalagree','ui::CButton');
	myfinalbutton:SetEnable(0);
	oppfinalbutton:SetEnable(0);
	EXCHANGE_OPTIONCTRL_INIT(frame);
end

function EXCHANGE_ON_CANCEL(frame) 
	frame:SetUserValue("CHECK_TOKENSTATE_OPPO", 0);
	exchange.SendCancelExchangeMsg();
	exchange.ResetExchangeItem();
	
	local invFrame = ui.GetFrame('inventory');	
	INVENTORY_SET_CUSTOM_RBTNDOWN("None");
	INVENTORY_CLEAR_SELECT(invFrame);
	EXCHANGE_SELL_FILTER_RESET(frame);
end 

function EXCHANGE_OPTIONCTRL_INIT(frame)
	if frame == nil then return; end
	local exchangeFilter = GET_CHILD_RECURSIVELY(frame, "exchangefilter");
	if exchangeFilter ~= nil then
		exchangeFilter:SetTextByKey("option_name", ClMsg("ApplyFilter"));
	end
end

function EXCHANGE_ON_AGREE(frame)
 	local itemCount = exchange.GetExchangeItemCount(1);	
	local isEquip = false;
	for  i = 0, itemCount-1 do 		
		local itemData = exchange.GetExchangeItemInfo(1,i);
		local class 			= GetClassByType('Item', itemData.type);
		if class.ItemType == 'Equip' then
			isEquip = true;
		end
	end

	exchange.SendAgreeExchangeMsg();
end 

function EXCHANGE_ON_FINALAGREE(frame)
	local oppoTokenState = frame:GetTopParentFrame():GetUserIValue("CHECK_TOKENSTATE_OPPO");
	OPEN_EXCHANGE_FILNAL_BOX(oppoTokenState);
end 

function EXCHANGE_MSG_REQUEST(frame)
	ui.MsgBox(ScpArgMsg("Auto_KeoLaeyoCheong_SuLageul_KiDaLiKoissSeupNiDa."));
end

function EXEC_INPUT_EXCHANGE_CNT(frame, inputframe, ctrl)
	if ctrl ~= nil then
		if ctrl:GetName() == "inputstr" then
			inputframe = ctrl;
		end
	end
	
	local inputCnt = tonumber(GET_INPUT_STRING_TXT(inputframe));
	inputframe:ShowWindow(0);
	local iesid = inputframe:GetUserValue("ArgString");
	local invItemList = session.GetInvItemList();	
	if FOR_EACH_INVENTORY(invItemList, function(invItemList, invItem, iesid, inputCnt)
		if invItem:GetIESID() == iesid then
			local obj = GetIES(invItem:GetObject());
			local noTrade = TryGetProp(obj, "BelongingCount");
			local tradeCount = invItem.count;
			if nil ~= noTrade then
				local wareItem = nil;
				if obj.MaxStack > 1 then
					wareItem = session.GetWarehouseItemByType(obj.ClassID);
				end
				local wareCnt = 0;
				if nil ~= wareItem then
					wareCnt = wareItem.count;
				end
				tradeCount = (invItem.count + wareCnt) - noTrade;
				if tradeCount > invItem.count then
					tradeCount = invItem.count;
				end
				if 0 >= tradeCount then
					if IS_EQUIP(obj) == true then
						ui.SysMsg(ClMsg("ItemIsNotTradable"));	
					else
						ui.SysMsg(ClMsg("ItemOverCount"));	
					end
					return 'end';
				end
			end
			if tradeCount >= inputCnt then
				exchange.SendOfferItem(iesid, inputCnt);
			else
				ui.AlarmMsg("ItemOverCount"); -- 등록수가 소비개수보다 큼
			end
			return 'break';
		end
	end, false, iesid, inputCnt) == false then
		return;
	end
end

local function _EXCHANGE_ADD_FROM_INV(obj, item, tradeCnt)    
	local reason = GetTradeLockByProperty(obj);
	if reason ~= "None" then
		ui.SysMsg(ScpArgMsg(reason));
		return;
	end

	if true == item.isLockState then
		ui.SysMsg(ClMsg("MaterialItemIsLock"));
		return;
	end

	local itemProp = geItemTable.GetPropByName(obj.ClassName);
	if itemProp:IsEnableUserTrade() == false then
		ui.AlarmMsg("ItemIsNotTradable");
		return;
	end
    
    if TryGetProp(obj, 'TeamBelonging', 0) ~= 0 or TryGetProp(obj, 'CharacterBelonging', 0) ~= 0 then
        ui.AlarmMsg("ItemIsNotTradable");
		return;
    end

	if geItemTable.IsHavePotential(obj.ClassID) == 1 and obj.PR == 0 then
		ui.AlarmMsg("NoPotentialForExchange");
		return;
	end

	if nil ~= string.find(obj.ClassName, "PremiumToken") then -- 토큰 아이템 칼럼이 생기면 바뀌어야 할 부분
		ui.AlarmMsg("ItemIsNotTradable");
		return;
	end

	local check = GetClassByType('market_trade_restrict', TryGetProp(obj, 'ClassID', 0))
	if check ~= nil then
		if IS_SEASON_SERVER() == "YES" then
			if TryGetProp(check, 'Type', 'None') == 'NoTrade2' then
				ui.AlarmMsg("ItemIsNotTradable");	
				return;
			end
		end
	end

	local invframe = ui.GetFrame("inventory");
	if true == IS_TEMP_LOCK(invframe, item) then
		return;
	end

	if geItemTable.IsStack(obj.ClassID) == 1  then
		local noTrade = TryGetProp(obj, "BelongingCount");
		local tradeCount = item.count;
		if nil ~= noTrade then
			local wareItem = nil 
			if obj.MaxStack > 1 then
				wareItem = session.GetWarehouseItemByType(obj.ClassID);
			end
			local wareCnt = 0;
			if nil ~= wareItem then
				wareCnt = wareItem.count;
			end
			tradeCount = (item.count + wareCnt) - noTrade;
			if tradeCount > item.count then
				tradeCount = item.count;
			end

			if 0 >= tradeCount then
				if IS_EQUIP(obj) == true then
					ui.SysMsg(ClMsg("ItemIsNotTradable"));	
				else
					ui.SysMsg(ClMsg("ItemOverCount"));	
				end
				return;
			end
		end
		
		if tradeCount >= 1 then
			INPUT_NUMBER_BOX(nil, ScpArgMsg("InputCount"), "EXEC_INPUT_EXCHANGE_CNT", tradeCnt, 1, tradeCnt, nil, tostring(item:GetIESID()));
			return;
		else
			ui.AlarmMsg("ItemOverCount"); -- 등록수가 소비개수보다 큼
		end
	else
        local noTrade = TryGetProp(obj, "BelongingCount");
        if 0 < noTrade then
            ui.SysMsg(ClMsg("ItemIsNotTradable"));	
            return;
        end
	end
	
	if TryGetProp(obj, 'Rebuildchangeitem', 0) > 0 then		
		ui.MsgBox(ScpArgMsg('IfUDoCannotExchangeWeaponType'), 'IMPL_EXCHANGE_ADD_FROM_INV("'..item:GetIESID()..'")', 'None');
		return;
	end

	exchange.SendOfferItem(tostring(item:GetIESID()), 1);
	SELECT_INV_SLOT_BY_GUID(item:GetIESID(), 1);
end

function IMPL_EXCHANGE_ADD_FROM_INV(guid)
	exchange.SendOfferItem(guid, 1);
	SELECT_INV_SLOT_BY_GUID(guid, 1);
end

function EXCHANGE_INV_RBTN(itemobj, slot)
	local icon = slot:GetIcon();
	local iconInfo = icon:GetInfo();
	local item = session.GetInvItem(iconInfo.ext);
	if nil == item then
		return;
	end

	local obj = GetIES(item:GetObject());
	local noTradeCnt = TryGetProp(obj, "BelongingCount");
	local tradeCount = item.count;
	if noTradeCnt ~= nil then
		local wareItem = nil;
		if obj.MaxStack > 1 then
			wareItem = session.GetWarehouseItemByType(obj.ClassID);
		end
		local wareCnt = 0;
		if nil ~= wareItem then
			wareCnt = wareItem.count;
		end
		tradeCount = (item.count + wareCnt) - noTradeCnt;
		if tradeCount > item.count then
			tradeCount = item.count;
		end
	end
	
	_EXCHANGE_ADD_FROM_INV(obj, item, tradeCount);	
end

function EXCHANGE_ON_DROP(frame, control, argStr, argNum)
	if 'YES' == frame:GetTopParentFrame():GetUserValue('CLICK_EQUIP_INV_ITEM') then
		ui.SysMsg(ScpArgMsg("Auto_JangChagJungin_aiTemeun_KeoLae_Hal_Su_eopSeupNiDa."));
		frame:GetTopParentFrame():SetUserValue('CLICK_EQUIP_INV_ITEM', 'NO')
		return;
	end
	
	local liftIcon 		= ui.GetLiftIcon();	
	local iconParentFrame = liftIcon:GetTopParentFrame();
	if iconParentFrame:GetName() == 'inventory' then 
		local iconInfo = liftIcon:GetInfo();
		local item = session.GetInvItem(iconInfo.ext);
		if item == nil then
			return;
		end

		local obj = GetIES(item:GetObject());
		local noTradeCnt = TryGetProp(obj, "BelongingCount");
		local tradeCount = item.count;
		if noTradeCnt ~= nil then
			local wareItem = nil
			if obj.MaxStack > 1 then
				wareItem = session.GetWarehouseItemByType(obj.ClassID);
			end
			local wareCnt = 0;
			if nil ~= wareItem then
				wareCnt = wareItem.count;
			end
			tradeCount = (item.count + wareCnt) - noTradeCnt;
			if tradeCount > item.count then
				tradeCount = item.count;
			end

			if 0 >= tradeCount then
				if IS_EQUIP(obj) == true then
					ui.SysMsg(ClMsg("ItemIsNotTradable"));	
				else
					ui.SysMsg(ClMsg("ItemOverCount"));	
				end
				return;
			end
		end
		_EXCHANGE_ADD_FROM_INV(obj, item, tradeCount);	
	end 	
end 

function EXCHANGE_MSG_END(frame, msg, argStr, argNum)
	local opponenGBox = GET_CHILD(frame, 'opbgGbox');
	local nameRichText = GET_CHILD_RECURSIVELY(opponenGBox,'opponentname','ui::CRichText');
	nameRichText:SetTextByKey('value',argStr)
	frame:ShowWindow(0);	
end 

function EXCHANGE_INIT_SLOT(frame)
	local myGBox = GET_CHILD(frame, 'mybgGbox');
	local myslotset = GET_CHILD_RECURSIVELY(myGBox,'myslot','ui::CSlotSet')	
	myslotset:ClearIconAll();
	myslotset:SetSkinName("invenslot2")
	local myslotsetCnt = myslotset:GetSlotCount();
	for i = 0, myslotsetCnt - 1 do
		local tempSlot = myslotset:GetSlotByIndex(i)
		DESTROY_CHILD_BYNAME(tempSlot, "styleset_")		
	end

	local opponenGBox = GET_CHILD(frame, 'opbgGbox');
	local oppslotset = GET_CHILD_RECURSIVELY(opponenGBox,'opponentslot','ui::CSlotSet')
	oppslotset:ClearIconAll();
	oppslotset:SetSkinName("invenslot2")
	local oppslotsetCnt = oppslotset:GetSlotCount();
	for i = 0, oppslotsetCnt - 1 do
		local tempSlot = oppslotset:GetSlotByIndex(i)
		DESTROY_CHILD_BYNAME(tempSlot, "styleset_")		
	end

	local slotCnt = myslotset:GetSlotCount();
	for i = 0, slotCnt - 1 do
		local tempSlot1 = myslotset:GetSlotByIndex(i)
		local tempSlot2 = oppslotset:GetSlotByIndex(i)
		SET_SLOT_STAR_TEXT(tempSlot1,nil)
		SET_SLOT_STAR_TEXT(tempSlot2,nil)
	end
end 

function EXCHANGE_MSG_START(frame, msg, argStr, argNum)
	EXCHANGE_INIT_SLOT(frame);
	EXCHANGE_RESET_AGREE_BUTTON(frame);

	local myGBox = GET_CHILD(frame, 'mybgGbox');	
	local nameRichText = GET_CHILD_RECURSIVELY(myGBox,'myname','ui::CRichText');
	local Name = info.GetFamilyName(session.GetMyHandle());
	nameRichText:SetTextByKey('value',Name)

	local opponenGBox = GET_CHILD(frame, 'opbgGbox');
	nameRichText = GET_CHILD_RECURSIVELY(opponenGBox,'opponentname','ui::CRichText');
	nameRichText:SetTextByKey('value',argStr)
	local oppfinalbutton = GET_CHILD_RECURSIVELY(opponenGBox,'opponentfinalagree','ui::CButton');
	oppfinalbutton:SetEnable(0);

	local myToken = IS_MYPC_EXCHANGE_BENEFIT_STATE();	
	local targetToken = false;
	 if 0 ~= argNum then
		targetToken = true;
	end

	local equipCannotTrade = GET_CHILD(frame, 'equipCannotTrade');
	local equipCanTrade = GET_CHILD(frame, 'equipCanTrade');
	local TokenState = GET_CHILD(frame, 'TokenState');
	local tradeStatePic = GET_CHILD(frame, 'tradeStatePic', "ui::CPicture");

	equipCannotTrade:ShowWindow(1);
	equipCanTrade:ShowWindow(0);
	TokenState:SetTextByKey('value',ScpArgMsg("NoneTokenState"))
	local opponentState = GET_CHILD(tradeStatePic, 'opponentState');
	local myState = GET_CHILD(tradeStatePic, 'myState');
	opponentState:SetTextByKey('value',ScpArgMsg("TokenNoneAppliedAtExchange"))
	myState:SetTextByKey('value',ScpArgMsg("TokenNoneAppliedAtExchange"))

	if myToken == true and targetToken == true then
		equipCannotTrade:ShowWindow(0);
		equipCanTrade:ShowWindow(1);
		TokenState:SetTextByKey('value',ScpArgMsg("TokenState"))
		tradeStatePic:SetImage("deal_wehave");
		opponentState:SetTextByKey('value',ScpArgMsg("TokenAppliedAtExchange"))
		myState:SetTextByKey('value',ScpArgMsg("TokenAppliedAtExchange"))

	elseif myToken == true and targetToken == false then
		tradeStatePic:SetImage("deal_righthave");
		myState:SetTextByKey('value',ScpArgMsg("TokenAppliedAtExchange"))
	elseif myToken == false and targetToken == true then
		tradeStatePic:SetImage("deal_lefthave");
		opponentState:SetTextByKey('value',ScpArgMsg("TokenAppliedAtExchange"))
	else
		tradeStatePic:SetImage("deal_nonehave");
	end

	frame:SetUserValue("CHECK_TOKENSTATE_OPPO", argNum);
	frame:ShowWindow(1);
	ui.OpenFrame('inventory');
end 

function EXCHANGE_ITEM_REMOVE(slot, agrNum, agrString)
	exchange.SendOfferItem(agrString, 0);	
end

function EXCHANGE_UPDATE_SLOT(slotset,listindex)
	local slotCnt = slotset:GetSlotCount();
	for i = 0, slotCnt - 1 do
		local tempSlot = slotset:GetSlotByIndex(i)
		SET_SLOT_STAR_TEXT(tempSlot,nil)
	end

	slotset:ClearIconAll();
	local frame = ui.GetFrame('exchange');
	local itemCount = exchange.GetExchangeItemCount(listindex);	
	local index = 0 
	for  i = 0, itemCount-1 do 		
		local itemData = exchange.GetExchangeItemInfo(listindex,i);
        local itemObj = itemData:GetObject();
        if itemObj ~= nil then
            itemObj = GetIES(itemObj);
        end
		local slot	= slotset:GetSlotByIndex(index);			
		if itemData.tradeType == TRADE_ITEM then
			local class = GetClassByType('Item', itemData.type);

			if class.ItemType == 'Unused' and listindex == 1 then
				moneyText:SetTextByKey('money', GetCommaedText(itemData.count));
			elseif class.ItemType ~= 'Unused' then
				local font = '{s20}{ol}{b}';
				if 100000 <= itemData.count then	-- 6자리 수 폰트 크기 조정
					font = '{s14}{ol}{b}';
				end
				local icon = SET_SLOT_ITEM_INFO(slot, itemObj, itemData.count, font);
				SET_ITEM_TOOLTIP_ALL_TYPE(icon, itemData, class.ClassName, 'exchange', itemData.type, i * 10 + listindex);
				SET_SLOT_STYLESET(slot, itemObj)
				SET_SLOT_STAR_TEXT(slot,itemObj)

				if listindex == 0 then 
					icon:SetDumpScp('EXCHANGE_DUMP_ICON');	
				end 

				index = index + 1
			end			

			slot:SetEventScript(ui.RBUTTONDOWN, 'EXCHANGE_ITEM_REMOVE');
			slot:SetEventScriptArgString(ui.RBUTTONDOWN, itemData:GetGUID());
		else
			local cls = GetClassByType("Wiki", itemData.itemID);
			SET_SLOT_ICON(slot, cls.Illust);
			SET_SLOT_STAR_TEXT(slot,itemObj)
			local icon = slot:GetIcon();
			icon:SetTextTooltip(string.format("%s{nl}%s", ClMsg("Recipe"), cls.Desc));
			index = index + 1;
		end			
	end
end 

function EXCHANGE_DUMP_ICON(parent, icon, argStr, argNum)
    local slot = tolua.cast(parent, "ui::CSlot");
    exchange.SendRemoveOfferItem(slot:GetSlotIndex());
end 

function EXCHANGE_MSG_UPDATE(frame, msg, argStr, argNum)
	EXCHANGE_RESET_AGREE_BUTTON(frame);
	local myslotSet = GET_CHILD_RECURSIVELY(frame,'myslot','ui::CSlotSet');
	
	EXCHANGE_UPDATE_SLOT(myslotSet,0);
	
	local opslotSet = GET_CHILD_RECURSIVELY(frame,'opponentslot','ui::CSlotSet');
	EXCHANGE_UPDATE_SLOT(opslotSet,1);
end 

function EXCHANGE_RESET_AGREE_BUTTON(frame)
	local mybutton = GET_CHILD_RECURSIVELY(frame,'myagree','ui::CButton');
	mybutton:SetEnable(1);

	local myfinalbutton = GET_CHILD_RECURSIVELY(frame,'myfinalagree','ui::CButton');
	myfinalbutton:SetEnable(0);

	local oppbutton = GET_CHILD_RECURSIVELY(frame,'opponentagree','ui::CButton');
	oppbutton:SetEnable(1);

	local oppfinalbutton = GET_CHILD_RECURSIVELY(frame,'opponentfinalagree','ui::CButton');
	oppfinalbutton:SetEnable(0);
end 

function EXCHANGE_MSG_AGREE(frame, msg, argStr, argNum)
	local mybutton = GET_CHILD_RECURSIVELY(frame,'myagree','ui::CButton');
	local oppbutton = GET_CHILD_RECURSIVELY(frame,'opponentagree','ui::CButton');

	if argNum == 0 then 
	   mybutton:SetEnable(0);
	else
	   oppbutton:SetEnable(0);	
	end 

	if mybutton:IsEnable() == 0 and oppbutton:IsEnable() == 0 then
		local myfinalbutton = GET_CHILD_RECURSIVELY(frame,'myfinalagree','ui::CButton');
		local oppfinalbutton = GET_CHILD_RECURSIVELY(frame,'opponentfinalagree','ui::CButton');
		myfinalbutton:SetEnable(1);
		oppfinalbutton:SetEnable(1);
	end
end 

function EXCHANGE_MSG_FINALAGREE(frame, msg, argStr, argNum)
	if argNum == 0 then 
		local myfinalbutton = GET_CHILD_RECURSIVELY(frame,'myfinalagree','ui::CButton');
	   myfinalbutton:SetEnable(0);
	else 
	   local oppfinalbutton = GET_CHILD_RECURSIVELY(frame,'opponentfinalagree','ui::CButton');
	   oppfinalbutton:SetEnable(0);
	end 
end 

function EXCHANGE_SELL_FILTER(frame, ctrl)
	if frame == nil or ctrl == nil then return; end
	local isCheck = ctrl:IsChecked();
	ui.inventory.ApplyInventoryFilter("inventory", IVF_USER_TRADE, isCheck);
end

function EXCHANGE_SELL_FILTER_RESET(frame)
	if frame == nil then return; end
	local option = GET_CHILD_RECURSIVELY(frame, "exchangefilter", "ui::CCheckBox");
	if option ~= nil then
		option:SetCheck(0);
	end
	ui.inventory.ApplyInventoryFilter("inventory", IVF_USER_TRADE, 0);
end