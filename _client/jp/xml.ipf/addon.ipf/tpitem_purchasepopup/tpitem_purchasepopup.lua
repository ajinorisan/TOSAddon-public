function TPITEM_PURCHASEPOPUP_OPEN()
    local frame = ui.GetFrame("tpitem");
	local tpitem_purchasepopup = ui.GetFrame("tpitem_purchasepopup");

    if frame == nil or tpitem_purchasepopup == nil then
		return false;
	end

	if config.GetServiceNation() == 'PAPAYA' then		
		local title = GET_CHILD_RECURSIVELY(tpitem_purchasepopup, 'title')
		title:SetText('{@st43}TP Purchase List')

		local button_ok = GET_CHILD_RECURSIVELY(tpitem_purchasepopup, 'button_ok')
		button_ok:SetText('{@st66b}Confirm')

		local explain_buy2 = GET_CHILD_RECURSIVELY(tpitem_purchasepopup, 'explain_buy2')
		explain_buy2:SetText('All TP purchases are non-refundable.')
		
	end

	local screenbgTemp = frame:GetChild('screenbgTemp');	
    local cashTPSlotSet = GET_TPSHP_RECHARGE_UI();
	local itemlistgbox = GET_CHILD_RECURSIVELY(tpitem_purchasepopup,"itemlistgbox")
    local cashSlotSet = GET_CHILD_RECURSIVELY(cashTPSlotSet,"cashInvSlotSet");
	if itemlistgbox == nil or cashSlotSet == nil then
		return false;
	end
	--백그라운드 회색 느낌
	screenbgTemp:ShowWindow(1);	
	tpitem_purchasepopup:ShowWindow(1);

	--기존에 만들었던 슬롯 삭제
	DESTROY_CHILD_BYNAME(itemlistgbox, 'eachitem_');

	local nSlot = cashSlotSet:GetSlotCount();
	local allprice = 0;
	local nDraw = 0;

	for i = 0, nSlot -1 do
		--슬롯셋에 있는 슬롯 가져옴
		local slotIcon = cashSlotSet:GetIconByIndex(i);

		if slotIcon ~= nil then
			--슬롯에 있는 아이템의 정보를 가져온다.(우하단)
			local classID = slotIcon:GetUserIValue("itemClassID");
			local item = GetClassByType("Item",classID);
			if item ~= nil then
				--아이템을 넣기 위한 슬롯을 생성 (현재 ui)
				local itemCtrlSet = itemlistgbox:CreateOrGetControlSet('tpshop_cash_purchase', 'eachitem_'..nDraw, 0, ui.GetControlSetAttribute("tpshop_cash_purchase", 'height') * nDraw);
				local itemSlot = GET_CHILD_RECURSIVELY(itemCtrlSet,"itemicon")
				local itemName = GET_CHILD_RECURSIVELY(itemCtrlSet,"itemName");
				local itemStaticprice_buy = GET_CHILD_RECURSIVELY(itemCtrlSet,"itemStaticprice_buy");
				local itemprice = GET_CHILD_RECURSIVELY(itemCtrlSet,"itemprice");
				local itemStaticprice_sell = GET_CHILD_RECURSIVELY(itemCtrlSet,"itemStaticprice_sell");
				itemStaticprice_sell:SetVisible(0);
					
				
				if itemName ~= nil and itemStaticprice_buy ~= nil and itemprice ~= nil then
					--아이템의 가격 이미지 이름 설정.
					local Name = TryGetProp(item, 'Name', 'None');
					local price = slotIcon:GetUserIValue("UnitPrice");
					
					SET_SLOT_IMG(itemSlot,GET_ITEM_ICON_IMAGE(item));
					itemName:SetText(Name);
					itemprice:SetText(tostring(price));
					--최종 가격을 호출하는 함수가 있으나 교차검증 겸 계산.
					allprice = allprice + price;
				end
				nDraw = nDraw + 1;
			end
		end
	end

	--최종 가격 출력.
	local totalTP = GET_CHILD_RECURSIVELY(tpitem_purchasepopup,"totalTP");
	if totalTP ~= nil then
		totalTP:SetTextByKey("price",allprice);
	end

end

function TPITEM_POPUP_PRESS_PURCHASE_BTN(frame)	
	local cashTPSlotSet = GET_TPSHP_RECHARGE_UI();
    local cashSlotSet = GET_CHILD_RECURSIVELY(cashTPSlotSet,"cashInvSlotSet");

	local nSlot = cashSlotSet:GetSlotCount();
	local type_list = {};
	local count_list = {};
	
	for i = 0, nSlot - 1 do
		local slotIcon = cashSlotSet:GetIconByIndex(i);
		if slotIcon ~= nil then
			local product_id = slotIcon:GetUserIValue("ProductID");
			table.insert(type_list, tostring(product_id));
			table.insert(count_list, "1");
		end
	end
	
	if #type_list ~= 0 then		
		BuyVertigoGamesProduct(type_list, count_list);
		SUCCESS_PURCHASE_TPITEM(frame);
	end	
end

function TPITEM_PURCHASEPOPUP_CLOSE(frame)	
	local tpitem_purchasepopup = ui.GetFrame("tpitem_purchasepopup");		
	if tpitem_purchasepopup ~= nil then
		tpitem_purchasepopup:ShowWindow(0);
	end
	ON_TPSHOP_FREE_UI();
end

function SUCCESS_PURCHASE_TPITEM(frame, msg, argStr, argNum)		
	TPITEM_PURCHASEPOPUP_CLOSE(frame);
	CLEAR_CASH_INVEN_SLOT_VERTIGO();	
	--SET_PURCHASE_TP_AMOUNT(frame);
end

function ON_TPITEM_VERTIGO_PURCHASE_SUCCESS(frame, msg, argStr, argNum)
	SET_PURCHASE_TP_AMOUNT(frame);
end