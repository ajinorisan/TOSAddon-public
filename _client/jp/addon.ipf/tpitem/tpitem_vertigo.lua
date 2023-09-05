-- tpitem_vertigo.lua : (tp shop)

local g_max_cash_inven_size = 18

function ON_TPITEM_VERTIGO_PROCESS_MSG(frame, msg, type, num)	
	TPTITEM_VERTIGO_PROCESS_POPUP();

	if type == 'start' then
		-- num : 구매할 아이템의 총 개수
		SET_MAXPOINT_AT_VERTIGO_PROCESS(num);
	elseif type == 'add' then
		-- num : 구매 성공한 누적 아이템 개수
		SET_CURPOINT_AT_VERTIGO_PROCESS(num);
	elseif type == 'end' then
		-- 구매작업 완료
		END_VERTIGO_PROCESS(num);
	elseif type == 'start_fail' then
		-- 구매작업 시작 실패
		FAIL_VERTIGO_PROCESS(num);		
	end
end

local function GET_CASH_INVEN_SLOT(index)
	local frame = ui.GetFrame("tpitem");
	local rightFrame = GET_CHILD(frame,"rightFrame");	
	local rightgbox = GET_CHILD(rightFrame,"rightgbox");	
	local cashRecharge = GET_TPSHP_RECHARGE_UI();
	local cashInvGbox = GET_CHILD(cashRecharge, "cashInvGbox", "ui::CGroupBox");
	local cashInvSlotSet = GET_CHILD(cashInvGbox, "cashInvSlotSet", "ui::CSlotSet");

	local slot = cashInvSlotSet:GetSlot("slot".. tostring(index));
	return slot
end

local function get_total_price()
	local total = 0
	for i = 1, g_max_cash_inven_size do
		local slot = GET_CASH_INVEN_SLOT(i)
		if slot ~= nil then
			local icon = slot:GetIcon()
			if icon ~= nil then
				local price = icon:GetUserIValue('UnitPrice')
				total = total + price
			end
		end
	end
	return total
end



local function PURCAHSEBTN_PARAMETER_UPDATE(count)
	local cashRecharge = GET_TPSHP_RECHARGE_UI();
	local cashInvGbox = GET_CHILD(cashRecharge, "cashInvGbox", "ui::CGroupBox");	
	local cashInfoGBox = GET_CHILD_RECURSIVELY(cashInvGbox,"cashInfoGBox");
	local ctrlPurchaseBtn = GET_CHILD_RECURSIVELY(cashInfoGBox, "CashBuyBtn");
	local purchaseBtn = tolua.cast(ctrlPurchaseBtn,"ui::CButton");
	if purchaseBtn~= nil then
		purchaseBtn:SetEventScript(ui.LBUTTONUP, "TPSHOP_PRESS_PURCHASEBTN_CHECK");
		purchaseBtn:SetEventScriptArgNumber(ui.LBUTTONUP, count);
	end	
end

local function ADD_CASH_INVEN_ITEM(product_id, class_id, price)
	local count = 1;
	for i = 1, g_max_cash_inven_size do
		local slot = GET_CASH_INVEN_SLOT(i);
		slot:SetEventScript(ui.RBUTTONUP, 'REMOVE_CASHTP_AT_SLOT_VERTIGO');

		if slot ~= nil then
			local icon = slot:GetIcon()
			if icon == nil then
				icon = CreateIcon(slot);
				local cls = GetClassByType('Item', class_id)
				SET_SLOT_IMG(slot, cls.Icon);
				icon:SetUserValue("itemClassID", class_id)
				icon:SetUserValue("UnitPrice", price)
				icon:SetUserValue("ProductID", product_id)								
            	icon:SetTooltipType("wholeitem");
				icon:SetTooltipArg("", class_id, 0);
				PURCAHSEBTN_PARAMETER_UPDATE(count);
				return true
			else
				if icon:GetUserIValue('itemClassID') == 0 then
					local cls = GetClassByType('Item', class_id)
					SET_SLOT_IMG(slot, cls.Icon);
					icon:SetUserValue("itemClassID", class_id)
					icon:SetUserValue("UnitPrice", price)
					icon:SetUserValue("ProductID", product_id)
					icon:SetTooltipType("wholeitem");
					icon:SetTooltipArg("", class_id, 0);
					PURCAHSEBTN_PARAMETER_UPDATE(count);
					return true
				end
			end
			count = count + 1;
		end
	end
	return false
end

local function COUNT_SLOT_REMAIN_ITEM()
	local count = 0;
	for i = 1, g_max_cash_inven_size do
		local slot = GET_CASH_INVEN_SLOT(i)
		if slot ~= nil then
			local icon = slot:GetIcon()
			if icon ~= nil then
				count = count + 1;
			end
		end
	end
	return count;
end
--보유, 담은, 최종 TP출력
function SET_PURCHASE_TP_AMOUNT(frame)		
	local accountObj = GetMyAccountObj();
	local currentTOC = session.loginInfo.GetUserBalance();
	local purchaseTOC = get_total_price();
	local totalTOC =  currentTOC - purchaseTOC;

	local haveRich = GET_CHILD_RECURSIVELY(frame,"cash_haveTOC");
	local basketRich =GET_CHILD_RECURSIVELY(frame,"cash_basketTOC");
	local totalRich = GET_CHILD_RECURSIVELY(frame,"cash_totalTOC");
	
	if haveRich ~= nil then
		haveRich:SetText(tostring(currentTOC));
	end
	if basketRich ~= nil then
		basketRich:SetText(tostring(purchaseTOC));
	end
	if totalRich ~= nil then
		totalRich:SetText(tostring(totalTOC));
	end

end

--슬롯에서 제거(우클릭 up시)
function REMOVE_CASHTP_AT_SLOT_VERTIGO(frame, slot, argStr, count)
	slot:ClearText();
	slot:ClearIcon();

	slot:SetUserValue("CLASSNAME", "None");
	slot:SetUserValue("TPITEMNAME", "None");

	local topFrame = frame:GetParent();
	SET_PURCHASE_TP_AMOUNT(topFrame);

	local count = COUNT_SLOT_REMAIN_ITEM();
	PURCAHSEBTN_PARAMETER_UPDATE(count);
end

--슬롯에 담긴 모든 아이템 제거.
function CLEAR_CASH_INVEN_SLOT_VERTIGO()
	for i = 1, g_max_cash_inven_size do
		local slot = GET_CASH_INVEN_SLOT(i)
		if slot ~= nil then
			local icon = slot:GetIcon()
			if icon ~= nil then
				icon:SetUserValue("itemClassID", 0)
				icon:SetUserValue("UnitPrice", 0)
				icon:SetUserValue("ProductID", 0)
			end
		end
	end

	local frame = ui.GetFrame("tpitem");
	local rightFrame = GET_CHILD(frame,"rightFrame");	
	local rightgbox = GET_CHILD(rightFrame,"rightgbox");	
	local cashRecharge = GET_TPSHP_RECHARGE_UI();
	local cashInvGbox = GET_CHILD(cashRecharge,"cashInvGbox");	
	local cashInvSlotSet = GET_CHILD(cashInvGbox,"cashInvSlotSet");	
	local slotSet = tolua.cast(cashInvSlotSet, "ui::CSlotSet");	
	slotSet:ClearIconAll();
	SET_PURCHASE_TP_AMOUNT(frame);
	PURCAHSEBTN_PARAMETER_UPDATE(0);
end

function TPSHOP_PRESS_PURCHASEBTN_CHECK(frame, ctrl, dump, count)	
	if count == 0 then
		strMsg = string.format("{@st43d}{s20}%s{/}", ScpArgMsg("EMPTY_CASHINVAN"));
		ui.MsgBox_NonNested(strMsg, 0x00000000, frame:GetName(), "None", "None");	
	else
		local currentTOC = tonumber(session.loginInfo.GetUserBalance())
		local purchaseTOC = get_total_price();
		local totalTOC =  currentTOC - purchaseTOC;
		if totalTOC < 0 then
			WARNINGMSGBOX_FRAME_OPEN('Would you like to purchase?', 'ON_TPITEM_VERTIGO_CHARGE_YES', 'ON_TPITEM_VERTIGO_CHARGE_NO', nil, 'Insufficient TOC.')			
		else
			TPITEM_PURCHASEPOPUP_OPEN();
		end
	end
end

--///////////////////////////////////////////////////////////////////////////////////////////TPITEM DRAW Code start
function TPITEM_DRAW_VERTIGO_TP()	
	local frame = ui.GetFrame("tpitem");
	local leftgFrame = GET_CHILD(frame,"leftgFrame");	
	local leftgbox = GET_CHILD(leftgFrame,"leftgbox");	
	local tpSubgbox = GET_CHILD(leftgbox,"tpSubgbox");		
	local tpMaingbox = GET_CHILD(leftgbox,"tpMaingbox");	
	local mainSubGbox = GET_CHILD_RECURSIVELY(tpMaingbox,"tpMainSubGbox");	
	local index = 0;
	DESTROY_CHILD_BYNAME(mainSubGbox, "eachitem_");
	DESTROY_CHILD_BYNAME(tpSubgbox, "specialProduct_");

	local shopTab = GET_CHILD_RECURSIVELY(frame, 'shopTab');
	local itembox_tab = tolua.cast(shopTab, "ui::CTabControl");
	local index = itembox_tab:GetIndexByName('Itembox2');
	itembox_tab:ChangeCaptionOnly(index, '{@st66b}Purchase TP', false)
	
	local mainText = GET_CHILD_RECURSIVELY(frame, 'mainText1')
	mainText:SetText('TP Deals')
	-- #125286
	-- mainText:SetText('{#FF0000}TP Deals: 10% Extra Bonus TP for a limited week! (June 27th - 6PM, July 4th Server time){/}')
	
	local gachaInfoTitle = GET_CHILD_RECURSIVELY(frame, 'gachaInfoTitle')
	gachaInfoTitle:SetText("{@st66d}{s18}TOC (Tree of Savior Cash){/}")
	local gachaInfoGuide = GET_CHILD_RECURSIVELY(frame, 'gachaInfoGuide')
	gachaInfoGuide:SetText("{@st43d}{s18}- To purchase TP, you need to have TOC (Tree of Savior Cash) first. Visit our official Papaya Play website to acquire TOC.{/}")
	local title = GET_CHILD_RECURSIVELY(frame, 'rightItem2Title')
	title:SetText('{@st43}{s24}Purchase TP')
	local cashStaticTOC = GET_CHILD_RECURSIVELY(frame, 'cashStaticTOC')
	cashStaticTOC:SetText('TOC Used')
	local cashInvTitle2 = GET_CHILD_RECURSIVELY(frame, 'cashInvTitle2')
	cashInvTitle2:SetText('{@st66d}{s18}TP (Tree of Savior Points){/}')
	local cashInvGuide = GET_CHILD_RECURSIVELY(frame, 'cashInvGuide')
	cashInvGuide:SetText('{@st43d}{s18}- The purchased TP will be found in your character inventory as an item. You can charge your Current TP by right-clicking on the item in your inventory.{nl}- The TP can only be used to purchase items once it is charged into your Current TP.{nl}- All TP purchases are non-refundable.{nl}- You must have a character level of 15 or above to make purchases.{/}')

	local cls_list, cnt = GetClassList('vertigo_games_product')	
	if cnt == 0 then
		return;
	end
	
	local index = cnt;
	local x, y;

	local specialGoodCount = 0;
	local packageClsID = 0;
	local packageJobCount = 0;
	
	local lastControlset = nil;
	local productNo = nil;
	local itemClsID = nil;
	local clsList, listcnt = GetClassList("item_package");	
	local jobNum = GETPACKAGE_JOBNUM_BYJOBNGENDER();	
	-- 해당 카테고리의 노드들의 프레임을 만들기.
	
	for i = cnt -1,0, -1 do
		local iteminfo = GetClassByIndexFromList(cls_list, i)
		if iteminfo == nil then
			return;
		end
		
		local cls = GetClass('Item', iteminfo.ClassName)

		local ItemClassName = iteminfo.Name;
		local buyBtn = nil;
		
		local itemPrice = iteminfo.Price;
		-- local imgURL = iteminfo.imgAddress;
		productNo = iteminfo.ClassID;
		itemClsID = cls.ClassID;
		
		local tttt = math.ceil(index / 4);
		x = ( (index - 1) % 4) * ui.GetControlSetAttribute("tpshop_itemtp", 'width');
		y = (math.ceil(index / 4) - 1) * ui.GetControlSetAttribute("tpshop_itemtp", 'height');
		local itemcset = mainSubGbox:CreateOrGetControlSet('tpshop_itemtp', 'eachitem_'..index, x, y);
		index = index - 1;

		local title = GET_CHILD_RECURSIVELY(itemcset,"title");
		local staticTPbox = GET_CHILD_RECURSIVELY(itemcset,"staticTPbox")
		local slot = GET_CHILD_RECURSIVELY(itemcset, "icon");
					
		local cls = GetClassByType("Item", itemClsID);
		if cls == nil  then
			return;
		end
		SET_SLOT_IMG(slot, cls.Icon);
		
		staticTPbox:SetText("{img toc_mark 30 30}{/}{@st43}{s18}".. itemPrice .."{/}");
		
		title:SetText(ItemClassName);

		local icon = slot:GetIcon();

		buyBtn = GET_CHILD_RECURSIVELY(itemcset, "buyBtn");	
		buyBtn:SetEventScriptArgNumber(ui.LBUTTONUP, productNo);
		buyBtn:SetEventScriptArgString(ui.LBUTTONUP, string.format("%d", itemClsID));		
		buyBtn:SetUserValue("LISTINDEX", i);
	end

	if lastControlset == nil then
		return;
	end

	mainSubGbox:Invalidate()
	frame:Invalidate()
end

-- TP 구매 버튼 클릭(장바구니에 아이템 넣기)
function TPSHOP_TRY_BUY_TPITEM_BY_NEXONCASH(parent, control, ItemClassIDstr, itemid)
	if config.GetServiceNation() == "PAPAYA" then
		local frame = ui.GetFrame("tpitem");	
		
		if IS_ENABLE_BUY_TP_ITEM() == false then
			return;
		end		

		local productID = control:GetUserIValue("LISTINDEX");		
		local product_cls = GetClassByType('vertigo_games_product', productID + 1)
		local cls = GetClass('Item', product_cls.ClassName)

		local class_id = cls.ClassID
		local price = product_cls.Price
		local result = ADD_CASH_INVEN_ITEM(productID + 1, class_id, price)		
		SET_PURCHASE_TP_AMOUNT(frame);
		if result == false then
			strMsg = string.format("{@st43d}{s20}%s{/}", ScpArgMsg("MAX_CASHINVAN"));
			ui.MsgBox_NonNested(strMsg, 0x00000000, frame:GetName(), "None", "None");	
			return;
		end
		return
	else
		local frame = ui.GetFrame("tpitem");	
		
		if IS_ENABLE_BUY_TP_ITEM() == false then
			return;
		end

		local nMaxCnt = session.ui.Get_NISMS_CashInven_ItemListSize();
		if nMaxCnt >= g_max_cash_inven_size then
			strMsg = string.format("{@st43d}{s20}%s{/}", ScpArgMsg("MAX_CASHINVAN"));
			ui.MsgBox_NonNested(strMsg, 0x00000000, frame:GetName(), "None", "None");	
			return;
		end
		
		local screenbgTemp = frame:GetChild('screenbgTemp');	
		screenbgTemp:ShowWindow(1);	

		local listIndex = control:GetUserIValue("LISTINDEX");
		local iteminfo = session.ui.Get_NISMS_ItemInfo(listIndex)
		if iteminfo == nil then
			return;
		end
		
		local amount = iteminfo.limitOnce;-- control:GetUserIValue("LimitOnce");	
		ui.BuyIngameShopItem(itemid, amount);
		return;
	end
end


function _TPSHOP_PURCHASE_RESULT_VERTIGO(parent, control, msg, ret)	
	local frame = ui.GetFrame("tpitem");

	if frame:IsVisible() == 0 then
		return;
	end

	local screenbgTemp = frame:GetChild('screenbgTemp');
	screenbgTemp:ShowWindow(1);
	local strSCP = "ON_TPSHOP_FREE_UI";
	
	local strMsg = "";
	local retValue = tonumber(ret);
	if retValue == 0 then
		strMsg = string.format("{@st66d}{s20}%s{/}{nl}{s10}{/} {/}{nl}{@st43d}{s18}%s{/}", ScpArgMsg("PutOnTheCashInven"), ScpArgMsg("CashInven_Guide"));
		
		local rightFrame = GET_CHILD(frame,"rightFrame");	
		local rightgbox = GET_CHILD(rightFrame,"rightgbox");	
		local cashInvGbox = GET_CHILD(rightgbox,"cashInvGbox");	
		local cashInvSlotSet = GET_CHILD(cashInvGbox,"cashInvSlotSet");	
		cashInvSlotSet = tolua.cast(cashInvSlotSet, "ui::CSlotSet");	
		cashInvSlotSet:ClearIconAll();	
		TPSHOP_SHOW_CASHINVEN_VERTIGO_ITEMLIST();
	else		
		strMsg = string.format("{@st43d}{s18}%s{/}", ScpArgMsg("FAILED_PURCHASED_" .. retValue));
		if retValue == 12040 then		
			strSCP = "WEB_TPSHOP_OPEN_URL_NEXONCASH";	
		end
	end

	ui.MsgBox_NonNested(strMsg, 0x00000000, frame:GetName(), strSCP, "None");		
	return;
end


function _TPSHOP_PICKUP_RESULT_VERTIGO(parent, control, msg, ret)	
	local frame = ui.GetFrame("tpitem");
	
	if frame:IsVisible() == 0 then
		return;
	end

	local rightFrame = GET_CHILD(frame,"rightFrame");	
	local rightgbox = GET_CHILD(rightFrame,"rightgbox");	
	local cashInvGbox = GET_CHILD(rightgbox,"cashInvGbox");	
	local cashInvSlotSet = GET_CHILD(cashInvGbox,"cashInvSlotSet");	
	cashInvSlotSet = tolua.cast(cashInvSlotSet, "ui::CSlotSet");	
	cashInvSlotSet:ClearIconAll();	
	TPSHOP_SHOW_CASHINVEN_VERTIGO_ITEMLIST();
	SET_PURCHASE_TP_AMOUNT(frame);
end

function _TPSHOP_REFUND_RESULT_VERTIGO(parent, control, msg, ret)	
	local frame = ui.GetFrame("tpitem");
	
	if frame:IsVisible() == 0 then
		return;
	end

	local screenbgTemp = frame:GetChild('screenbgTemp');
	screenbgTemp:ShowWindow(1);
	
	local retValue = tonumber(ret);
	local strMsg = "";
	if (retValue == 3) or (retValue == 7) then
		retValue = 0;
	elseif retValue == 1 then		
		local rightFrame = GET_CHILD(frame,"rightFrame");	
		local rightgbox = GET_CHILD(rightFrame,"rightgbox");	
		local cashInvGbox = GET_CHILD(rightgbox,"cashInvGbox");	
		local cashInvSlotSet = GET_CHILD(cashInvGbox,"cashInvSlotSet");	
		cashInvSlotSet = tolua.cast(cashInvSlotSet, "ui::CSlotSet");	
		cashInvSlotSet:ClearIconAll();	
		TPSHOP_SHOW_CASHINVEN_VERTIGO_ITEMLIST();
		SET_PURCHASE_TP_AMOUNT(frame);
	end	

	strMsg = string.format("{@st43d}{s18}%s{/}", ScpArgMsg("FAILED_REFUND_" .. retValue));
	ui.MsgBox_NonNested(strMsg, 0x00000000, frame:GetName(), "ON_TPSHOP_FREE_UI", "None");		
	return;
end

-- 장바구니를 가져온다.
function TPSHOP_SHOW_CASHINVEN_VERTIGO_ITEMLIST()	
	local frame = ui.GetFrame("tpitem");
	local rightFrame = GET_CHILD(frame,"rightFrame");	
	local rightgbox = GET_CHILD(rightFrame,"rightgbox");	

	local cashRecharge = GET_TPSHP_RECHARGE_UI();
	local cashInvGbox = GET_CHILD(cashRecharge, "cashInvGbox", "ui::CGroupBox");	
	local cashInvSlotSet = GET_CHILD_RECURSIVELY(cashInvGbox,"cashInvSlotSet");	
	local cashInfoGBox = GET_CHILD_RECURSIVELY(cashInvGbox,"cashInfoGBox");
	local resetBtn = GET_CHILD_RECURSIVELY(cashInfoGBox,"resetCashBtn");
	local ctrlPurchaseBtn = GET_CHILD_RECURSIVELY(cashInfoGBox, "CashBuyBtn");
	local currentPage = frame:GetUserValue("CASHINVEN_PAGENUMBER");

	local slotSet = tolua.cast(cashInvSlotSet, "ui::CSlotSet");	
	local resetCashBtn = tolua.cast(resetBtn,"ui::CButton");
	local purchaseBtn = tolua.cast(ctrlPurchaseBtn,"ui::CButton");

	PURCAHSEBTN_PARAMETER_UPDATE(0);

	if slotSet ~= nil then
		slotSet:ClearIconAll();
	end

	for i = 1, g_max_cash_inven_size do
		local slot = cashInvSlotSet:GetSlot("slot".. (i + 1));
		if slot ~= nil then
			local icon = slot:GetIcon()
			if icon ~= nil then
				local class_id = icon:GetUserIValue('itemClassID')
				if class_id ~= 0 then						
					local cls = GetClassByType("Item", class_id);
					if cls == nil  then
						return;
					end
					SET_SLOT_IMG(slot, cls.Icon);
				end
			end
		end;			
	end;

	if resetCashBtn ~= nil then
		resetCashBtn:SetEventScript(ui.LBUTTONUP, 'CLEAR_CASH_INVEN_SLOT_VERTIGO');
	end

	SET_PURCHASE_TP_AMOUNT(frame);
	rightgbox:Invalidate()
	frame:Invalidate()
end

--Getter
function GET_TPSHP_RECHARGE_UI()	
	local frame = ui.GetFrame("tpitem");
	local rightFrame = GET_CHILD(frame,"rightFrame");	
	local rightgbox = GET_CHILD(rightFrame,"rightgbox");	
	local cashRecharge = rightgbox:CreateOrGetControlSet('tpshop_cash_recharge', "cashRecharge", 0, 0);
    local ctrlSet = tolua.cast(cashRecharge, "ui::CControlSet");

	return ctrlSet;
end


function ON_TPITEM_VERTIGO_CHARGE()
	WARNINGMSGBOX_FRAME_OPEN('Would you like to purchase?', 'ON_TPITEM_VERTIGO_CHARGE_YES', 'ON_TPITEM_VERTIGO_CHARGE_NO', nil, 'Insufficient TOC.')
end


function ON_TPITEM_VERTIGO_CHARGE_YES()
	login.OpenURL('http://www.papayaplay.com/shop/main.do?sid=12')
end

function ON_TPITEM_VERTIGO_CHARGE_NO()

end