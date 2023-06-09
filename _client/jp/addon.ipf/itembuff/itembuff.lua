--itembuff.lua

function ITEMBUFF_ON_INIT(addon, frame)
	MAX_BYTE_OF_TITLE = 40;
end

function ITEMBUFF_SET_SKILLTYPE(frame, skillName, skillLevel, titleName)
	frame:SetUserValue("SKILLNAME", skillName)
	frame:SetUserValue("SKILLLEVEL", skillLevel)

	local title = GET_CHILD_RECURSIVELY(frame, "title");
	title:SetTextByKey("txt", titleName);
end

function ITEMBUFF_REFRESH_LIST(frame)
	local reqitemtext = GET_CHILD_RECURSIVELY(frame, "reqitemCount");
	local reqitemName = GET_CHILD_RECURSIVELY(frame, "reqitemName");
	local reqitemStr = GET_CHILD_RECURSIVELY(frame, "reqitemStr");
	local pc = GetMyPCObject();
	local invItemList = session.GetInvItemList();
	local checkFunc = _G["ITEMBUFF_STONECOUNT_" .. frame:GetUserValue("SKILLNAME")];
	local name, cnt = checkFunc(invItemList, frame);
	local cls = GetClass("Item", name);
	local txt = GET_ITEM_IMG_BY_CLS(cls, 60);
	reqitemName:SetTextByKey("txt", txt);
	reqitemStr:SetTextByKey("txt", cls.Name);
	local text = cnt .. " " .. ClMsg("CountOfThings");
	reqitemtext:SetTextByKey("txt", text);
end

function ITEM_BUFF_CREATE_STORE(frame)    
	ITEM_BUFF_CLOSE();
	local optionBox = frame:GetChild("OptionBox");
	local edit = GET_CHILD(optionBox, "TitleInput")
	local moneyInput = GET_CHILD(optionBox, "MoneyInput");

	local price = moneyInput:GetNumber();
	if price <= 0 then
		ui.MsgBox(ClMsg("InputPriceMoreThanOne"));
		return;
	end

	local titleLen = ui.GetCharNameLength(edit:GetText());
	if titleLen < 1 then
		ui.MsgBox(ClMsg("InputTitlePlease"));
		return;
	elseif titleLen > MAX_BYTE_OF_TITLE then
		ui.MsgBox(ScpArgMsg("ShopNameMustLongerThen{ENG_LEN}{KOR_LEN}", "ENG_LEN", MAX_BYTE_OF_TITLE, "KOR_LEN", MAX_BYTE_OF_TITLE / 2));
		return;
	end

	session.autoSeller.ClearGroup("ItemBuffStore");	
	local sklName = frame:GetUserValue("SKILLNAME");
	local sklLevel = frame:GetUserIValue("SKILLLEVEL");
	local dummyInfo = session.autoSeller.CreateToGroup("ItemBuffStore");

	if sklName == 'Appraiser_Apprise' and price > APPRRISE_MAX_UNIT_MONEY then
		ui.MsgBox(ScpArgMsg("ApprisePriceMustLowerThan{PRICE}", "PRICE", APPRRISE_MAX_UNIT_MONEY));
		return;
	end

	dummyInfo.classID = GetClass("Skill", sklName).ClassID;
	dummyInfo.price = price;
	dummyInfo.level = sklLevel;
	
	local storeGroupName = frame:GetUserValue("STORE_GROUP_NAME");
	local pc = GetMyPCObject();
	if storeGroupName == 'None' then
		storeGroupName = 'Squire';
		local abilSquire14 = GetAbility(pc, 'Squire14');
		local abilSquire15 = GetAbility(pc, 'Squire15');
		local abilSquire16 = GetAbility(pc, 'Squire16');
		local abilState = 0;		
		if abilSquire14 ~= nil then
			local squire14_buff = info.GetBuffByName(session.GetMyHandle(), "Squire14_Buff");
			if squire14_buff ~= nil then
				abilState = 1;
			end
		end
		if abilSquire15 ~= nil then
			local squire15_buff = info.GetBuffByName(session.GetMyHandle(), "Squire15_Buff");
			if squire15_buff ~= nil then
				abilState = 2;
			end
		end
		if abilSquire16 ~= nil then
			local squire16_buff = info.GetBuffByName(session.GetMyHandle(), "Squire16_Buff");
			if squire16_buff ~= nil then
				abilState = 3;
			end
		end
		
		dummyInfo.squireAbilState = abilState;
	end

	if "" == edit:GetText() then
		return;
	end

	local invItemList = session.GetInvItemList();
	local checkFunc = _G["ITEMBUFF_STONECOUNT_" .. frame:GetUserValue("SKILLNAME")];
	local name, cnt = checkFunc(invItemList, frame);

	if 0 == cnt then
		ui.MsgBox(ClMsg("NotEnoughRecipe"));
		return;
	end

	local material = session.GetInvItemByName(name);
	if nil == material then
		return;
	end

	if true == material.isLockState then
		ui.SysMsg(ClMsg("MaterialItemIsLock"));
		return;
	end

	local x, y, z = GetPos(pc);
	if 0 == IsFarFromNPC(pc, x, y, z, 50) then
		ui.SysMsg(ClMsg("TooNearFromNPC"));	
		return 0;
	end
	
	session.autoSeller.RequestRegister("ItemBuffStore", storeGroupName, edit:GetText(), sklName);
    packet.SendMoveStopMyCharacter()
end

function OPEN_MY_ITEMBUFF_UI(groupName, sellType, handle)
	local groupInfo = session.autoSeller.GetByIndex(groupName, 0);
	if groupInfo == nil then
		return;
	end

	local sklName = GetClassByType("Skill", groupInfo.classID).ClassName;
	if "Squire_Repair" == sklName then
		ITEMBUFF_REPAIR_UI_COMMON(groupName, sellType, handle);
		return;
	elseif "Alchemist_Roasting" == sklName then
		ITEMBUFFGEMROASTING_UI_COMMON(groupName, sellType, handle);
		return;
	elseif sklName == 'Appraiser_Apprise' then
		APPRAISAL_PC_UI_COMMON(groupName, sellType, handle);
		return;
    elseif groupName == 'Portal' then
		PORTAL_SELLER_OPEN_UI(groupName, sellType, handle);
		return;
	end

	OPEN_ITEMBUFF_UI_COMMON(groupName, sellType, handle);
end

function OPEN_ITEMBUFF_UI(groupName, sellType, handle)
	local groupInfo = session.autoSeller.GetByIndex(groupName, 0);
	if groupInfo == nil then
		return;
	end

	local sklName = GetClassByType("Skill", groupInfo.classID).ClassName;
	if "Squire_Repair" == sklName then
		local frame = ui.GetFrame("itembuffrepair");
		ITEMBUFF_REPAIR_UI_COMMON(groupName, sellType, handle);
		SQUIRE_HIDE_UI(frame);
		REGISTERR_LASTUIOPEN_POS(frame);
		frame:RunUpdateScript("LASTUIOPEN_CHECK_PC_POS", 0.1);
		return
	elseif "Alchemist_Roasting" == sklName then
		local frame = ui.GetFrame("itembuffgemroasting");
		ITEMBUFFGEMROASTING_UI_COMMON(groupName, sellType, handle);
		GEMROASTING_HIDE_UI(frame);
		REGISTERR_LASTUIOPEN_POS(frame);
		frame:RunUpdateScript("LASTUIOPEN_CHECK_PC_POS", 0.1);
		return
	elseif sklName == 'Appraiser_Apprise' then
		APPRAISAL_PC_UI_COMMON(groupName, sellType, handle);
		return;
    elseif groupName == 'Portal' then
		PORTAL_SELLER_OPEN_UI(groupName, sellType, handle);
		return;
	end

	OPEN_ITEMBUFF_UI_COMMON(groupName, sellType, handle);

	local frame = ui.GetFrame("itembuffopen");
	SQUIRE_HIDE_UI(frame);
	REGISTERR_LASTUIOPEN_POS(frame);
	frame:RunUpdateScript("LASTUIOPEN_CHECK_PC_POS", 0.1);
end

function GEMROASTING_HIDE_UI(frame)
	local log = frame:GetChild("statusTab");
	log:SetVisible(0);
	local repairBox = frame:GetChild("roasting");
	local material = repairBox:GetChild("materialGbox");
	material:SetVisible(0);
end

function SQUIRE_HIDE_UI(frame)
	local log = GET_CHILD_RECURSIVELY(frame, "statusTab");
	log:SetVisible(0);

	local material = GET_CHILD_RECURSIVELY(frame, "materialGbox");
	material:SetVisible(0);
end

function OPEN_ITEMBUFF_UI_COMMON(groupName, sellType, handle)	
	if 	groupName == "None" then
		ui.CloseFrame("itembuffopen");
		ui.CloseFrame("inventory");	
		return;
	end
	
	local groupInfo = session.autoSeller.GetByIndex(groupName, 0);
	local open = ui.GetFrame("itembuffopen");
	open:ShowWindow(1);
	open:SetUserValue("GroupName", groupName);

	local statusTab = GET_CHILD_RECURSIVELY(open, 'statusTab');
	ITEMBUFF_SHOW_TAB(statusTab, handle);

	local sklName = GetClassByType("Skill", groupInfo.classID).ClassName;	
	open:SetUserValue("SKILLNAME", sklName)
	open:SetUserValue("SKILLLEVEL", groupInfo.level);
	open:SetUserValue("HANDLE", handle);

	local repairBox = GET_CHILD_RECURSIVELY(open, "repair");

	if session.GetMyHandle() == handle then
		local money = GET_CHILD_RECURSIVELY(open, "reqitemMoney");
		money:SetTextByKey("txt", groupInfo.price);
		local effectGbox = GET_CHILD_RECURSIVELY(open, "effectGbox");
	end

	-- 아츠 특성 표시
	local abilState = groupInfo.squireAbilState;
	local abil_text = GET_CHILD_RECURSIVELY(open, 'abil_text');
	if abilState == 1 then
		abil_text:SetTextByKey('txt', ScpArgMsg('Squire14AbilityAble'));
	elseif abilState == 2 then
		abil_text:SetTextByKey('txt', ScpArgMsg('Squire15AbilityAble'));
	elseif abilState == 3 then
		abil_text:SetTextByKey('txt', ScpArgMsg('Squire16AbilityAble'));
	else
		abil_text:SetTextByKey('txt', '');
	end
	
	open:SetUserValue("PRICE", groupInfo.price)
	
	local itembox_tab = GET_CHILD_RECURSIVELY(open, 'statusTab');
	itembox_tab:SelectTab(0);
	SQUIRE_BUFF_VIEW(open);
	SQUIRE_UI_RESET(open);
	SQUIRE_UPDATE_MATERIAL(open);
	ui.OpenFrame("inventory");
end

function ITEM_BUFF_CLOSE()
	ui.CloseFrame("itembuff");
end

function ITEM_BUFF_UI_CLOSE(handle)
	local frame = ui.GetFrame("BUFF_BALLOON_" .. handle);
	if nil ~= frame then
		DESTROY_FRAME("BUFF_BALLOON_" .. handle);
		frame:ShowWindow(0);
	end

	ui.CloseFrame("itembuffopen");	
end

function ITEMBUFF_SHOW_TAB(tabCtrl, handle)
	if handle == session.GetMyHandle() then
		tabCtrl:ShowWindow(1);
	else
		tabCtrl:ShowWindow(0);
	end
end

function ITEMBUFF_INIT_USER_PRICE(frame, sklClassName)
	local MoneyInput = GET_CHILD_RECURSIVELY(frame, 'MoneyInput');
	PROCESS_USER_SHOP_PRICE(sklClassName, MoneyInput);
end

local function GET_PC_ABILITY_OBJECT_LIST()
    local abilObjList = {};
    local pcSession = session.GetMySession();
	local abilList = pcSession:GetAbilityList();
	local abilListCnt = 0;
	if abilList ~= nil then
		abilListCnt = abilList:Count();
	end

	for i=0, abilListCnt - 1 do
		local abil = abilList:Element(i);
		if abil ~= nil and abil:GetObject() ~= nil then
            abilObjList[#abilObjList + 1] = GetIES(abil:GetObject());
		end
    end
    return abilObjList;
end

function PROCESS_USER_SHOP_PRICE(sklClassName, editCtrl, buffClassID)
	local userPriceCls = GetClass('UserShopPrice', sklClassName);	
	if userPriceCls ~= nil then
		local priceType = userPriceCls.PriceType;
		local price = 0;
		if priceType == 'UnitPrice' then
			price = userPriceCls.DefaultPrice;
		elseif priceType == 'ConstantPrice' then
			local GetPriceScp = _G[TryGetProp(userPriceCls, 'Price', 'None')];
			if GetPriceScp ~= nil then
				local buffCls = GetClassByType('Buff', buffClassID);
				local argStr = '';
				if buffSklCls ~= nil then
					argStr = buffCls.ClassName;
				end

				price = GetPriceScp(sklClassName, GetZoneName(), argStr, GET_PC_ABILITY_OBJECT_LIST());
				if price < 1 then
					IMC_LOG('ERROR_LOGIC', 'PROCESS_USER_SHOP_PRICE: price error- shop['..sklClassName..'], argStr['..argStr..']');
				end
			end	
		end
		editCtrl:SetText(price);
			editCtrl:EnableHitTest(0);
			return;
		end
	editCtrl:EnableHitTest(1);
end