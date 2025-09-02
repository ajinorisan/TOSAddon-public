function TP_SHOP_DO_OPEN(frame, msg, shopName, argNum)
	
	ui.CloseAllOpenedUI();
	ui.OpenIngameShopUI();	-- Tpshop을 열었을때에 Tpitem에 대한 정보와 NexonCash 정보 등을 서버에 요청한다.

	-- 탭정렬 먼저 한번 하고 요청.
	TPSHOP_SORT_TAB(frame)
	-- 요청
	session.shop.RequestLoadShopBuyLimit();
	session.shop.RequestEventUserTypeInfo(); -- 신규/복귀/일반 변경정보 요청.

	frame:ShowWindow(1);
	local leftgFrame = frame:GetChild("leftgFrame");	
	local leftgbox = leftgFrame:GetChild("leftgbox");
	local rightFrame = frame:GetChild('rightFrame');   
	local rightgbox = rightFrame:GetChild('rightgbox');
	local shopTab = leftgbox:GetChild('shopTab');
	local itembox_tab = tolua.cast(shopTab, "ui::CTabControl");

	-- 그외에는 TP 구매 탭을 제거한다.
	itembox_tab:DeleteTab(itembox_tab:GetIndexByName("Itembox2"));	
	itembox_tab:SetItemsFixWidth(170);		
	itembox_tab:SelectTab(itembox_tab:GetIndexByName("Itembox1"));

	local banner = GET_CHILD_RECURSIVELY(frame,"banner");	
	banner:ShowWindow(0);
	
	local banner1 = GET_CHILD_RECURSIVELY(frame,"banner1");	
	banner1:SetImage("market_event_test");
	
	local haveStaticNCbox = GET_CHILD_RECURSIVELY(frame,"haveStaticNCbox");	
	haveStaticNCbox:ShowWindow(0);
	
	local ncReflashbtn = GET_CHILD_RECURSIVELY(frame,"ncReflashbtn");	
	ncReflashbtn:ShowWindow(0);
	
	local ncChargebtn = GET_CHILD_RECURSIVELY(frame,"ncChargebtn");	
	ncChargebtn:ShowWindow(0);
	
	local remainNexonCash = GET_CHILD_RECURSIVELY(frame,"remainNexonCash");	
	remainNexonCash:ShowWindow(0);
			
	local ncReflashbtn = GET_CHILD_RECURSIVELY(frame,"ncReflashbtn");	
	ncReflashbtn:ShowWindow(0);
	
	end
		
	
	MAKE_CATEGORY_TREE();
	
	frame:SetUserValue("CASHINVEN_PAGENUMBER", 1);

	local screenbgTemp = GET_CHILD_RECURSIVELY(frame, 'screenbgTemp');
	screenbgTemp:ShowWindow(0);
		
	local ratio = option.GetClientHeight()/option.GetClientWidth();	
	local limitMaxWidth = ui.GetSceneWidth() / ui.GetRatioWidth();
	local limitMaxHeight = limitMaxWidth * ratio;
	
	if limitMaxWidth < option.GetClientWidth() then
		limitMaxWidth = option.GetClientWidth();
	end
	
	local div = 2;
	if limitMaxHeight < option.GetClientHeight() then
		limitMaxHeight = option.GetClientHeight();
		div = 6;
	end
	frame:Resize(0,0 , limitMaxWidth * 1.2, limitMaxHeight * 1.2);	
	
	--session.shop.RequestLoadShopBuyLimit();
	SET_TOPMOST_FRAME_SHOWFRAME(0);	
	
	-- 프리미엄 탭을 설정.
	local premiumTabIndex = TPSHOP_GET_INDEX_BY_TAB_NAME("Itembox1");
	if premiumTabIndex < 0 then
		premiumTabIndex = 0
	end
	itembox_tab:SelectTab(premiumTabIndex);
	TPSHOP_TAB_VIEW(frame, premiumTabIndex);
	
	local input = GET_CHILD_RECURSIVELY(frame, "input");
	local editDiff = GET_CHILD_RECURSIVELY(frame, "editDiff");
	input:ClearText();
	editDiff:SetVisible(1);
		
	local basketslotset = GET_CHILD_RECURSIVELY(frame,"basketslotset")
	TPITEM_CLEAR_SLOTSET(basketslotset);

	local newbie_basketbuyslotset = GET_CHILD_RECURSIVELY(frame,"newbie_basketbuyslotset")	
	TPITEM_CLEAR_SLOTSET(newbie_basketbuyslotset);
	local returnuser_basketbuyslotset = GET_CHILD_RECURSIVELY(frame,"returnuser_basketbuyslotset")	
	TPITEM_CLEAR_SLOTSET(returnuser_basketbuyslotset);
	
	local rcycle_basketbuyslotset = GET_CHILD_RECURSIVELY(frame,"rcycle_basketbuyslotset")
	rcycle_basketbuyslotset:ClearIconAll();
	local rcycle_basketsellslotset = GET_CHILD_RECURSIVELY(frame,"rcycle_basketsellslotset")
	rcycle_basketsellslotset:ClearIconAll();
	
	local specialGoods = GET_CHILD_RECURSIVELY(frame,"specialGoods");	
	--specialGoods:SetImage("market_default2");
		
	local basketTP = GET_CHILD_RECURSIVELY(frame,"basketTP")
	basketTP:SetText(tostring(0))	

	ON_TPSHOP_RESET_PREVIEWMODEL();	
	
	local tpPackageGbox = GET_CHILD_RECURSIVELY(frame,"tpPackageGbox");		
	tpPackageGbox:ShowWindow(0);	

	UPDATE_BASKET_MONEY(frame);
	UPDATE_RECYCLE_BASKET_MONEY(frame,"sell");
	
	local rightFrame = frame:GetChild('rightFrame');
	local leftgFrame = frame:GetChild("leftgFrame");	
	local leftgbox = leftgFrame:GetChild("leftgbox");
	local alignmentgbox = GET_CHILD(leftgbox,"alignmentgbox");				
	local alignTypeList = GET_CHILD_RECURSIVELY(frame,"alignTypeList");	
	local showTypeList = GET_CHILD_RECURSIVELY(frame,"showTypeList");	
	showTypeList:ClearItems();

	local resol = math.floor((limitMaxHeight - leftgFrame:GetHeight()) / div);
	if resol < 0  then
		resol = 0;
	end
	
	for i = 0 , 3 do
	local resString = string.format("{@st42b}{s16}%s{/}", ScpArgMsg("SHOWLIST_ITEM_TYPE_" .. i));
		showTypeList:AddItem(i, resString);
	end
	showTypeList:SelectItem(0);

	local alignTypeList = GET_CHILD_RECURSIVELY(frame,"alignTypeList");	
	alignTypeList:ClearItems();

	for i = 0 , 3 do
	local resString = string.format("{@st42b}{s16}%s{/}", ScpArgMsg("ALIGN_ITEM_TYPE_" .. i));
		alignTypeList:AddItem(i, resString);
	end
	alignTypeList:SelectItem(0);
	
	local tempGbox_for_scroll = GET_CHILD_RECURSIVELY(frame,"tempGbox_for_scroll")
	tempGbox_for_scroll:SetEventScript(ui.MOUSEWHEEL, "TPSHOP_PREVIEW_ZOOM");

end