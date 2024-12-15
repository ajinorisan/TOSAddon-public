-- exchangeweapontype
function EXCHANGEWEAPONTYPE_ON_INIT(addon, frame)
	addon:RegisterMsg("MSG_CLEAR_EXCHANGE_EWEAPONTYPE", "EXCHANGEWEAPONTYPE_UI_CLEAR");
end

function OPEN_EXCHANGE_WEAPONTYPE()
	ui.OpenFrame("exchangeweapontype");
end

function OPEN_EXCHANGE_WEAPONTYPE()
	ui.OpenFrame("exchangeweapontype");
end

function EXCHANGEWEAPONTYPE_OPEN(frame)
	INVENTORY_SET_CUSTOM_RBTNDOWN("EXCHANGEWEAPONTYPE_INV_RBTN");
	EXCHANGEWEAPONTYPE_UI_CLEAR();
	EXCHANGEWEAPONTYPE_UI_INIT_SETTING(frame);
	ui.OpenFrame("inventory");
end

function EXCHANGEWEAPONTYPE_CLOSE(frame)
	RESET_INVENTORY_ICON();
	INVENTORY_SET_CUSTOM_RBTNDOWN("None");
end

function EXCHANGEWEAPONTYPE_UI_INIT_SETTING(frame)
	if frame ~= nil then
		local help_pic = GET_CHILD_RECURSIVELY(frame, "helpPic");
		if help_pic ~= nil then
			local tooltip_text = ClMsg("WeaponTypeExchange_Help");
			help_pic:SetTextTooltip(tooltip_text);
			help_pic:Invalidate();
		end
		GET_CHILD_RECURSIVELY(frame, "title"):SetUserValue("IsLuciferi",0);
	end
end

local function _ADD_ITEM_TO_EXCHANGEWEAPONTYPE_FROM_INV(frame, item, invSlot, invItemGuid, slotNum, isLuciferi)
	local invItem = session.GetInvItemByGuid(invItemGuid);
	if true == invItem.isLockState then
		ui.SysMsg(ClMsg("MaterialItemIsLock"));
		return;
	end

	if slotNum == 1 then
		local group = TryGetProp(item, "ExchangeGroup", "None");
		if group ~= "Luciferi_Neck" and group ~= "Luciferi_Ring" and isLuciferi == true then
			ui.SysMsg(ScpArgMsg("IMPOSSIBLE_ITEM"))
			return;
		elseif isLuciferi == false then
			local isExchange = IS_EXCHANGE_WEAPONTYPE(group, item.ClassName);
			if isExchange == false or group == "Luciferi_Neck" or group == "Luciferi_Ring" then
				ui.SysMsg(ScpArgMsg("IMPOSSIBLE_ITEM"))
				return;
			end

			-- 미감정 아이템 체크.
			local needAppraisal = TryGetProp(item, "NeedAppraisal");
			local needRandomOption = TryGetProp(item, "NeedRandomOption");
			if needAppraisal == 1 or needRandomOption == 1 then
				ui.SysMsg(ScpArgMsg("NoAppraiseExchangeWeaponType"));
				return;
			end

			-- 아이커가 장착된 아이템은 무기 계열 변경이 불가능 하도록
			if item.ItemType == "Equip" then
				if IS_ENABLE_RELEASE_OPTION(item) == true then
					ui.SysMsg(ScpArgMsg("IMPOSSIBLE_ITEM"));
					return;
				end
			else 
				return;
			end

			-- 트링켓 아이템은 무기 계열 변경이 불가능 하도록.
				if TryGetProp(item, 'ClassType', 'None') == "Trinket" then
				ui.SysMsg(ScpArgMsg("IMPOSSIBLE_ITEM"));
				return;
			end
		end

		-- 포텐셜 체크.
		if item.PR ~= 0 then
			ui.SysMsg(ScpArgMsg("NoNeedPRExchangeWeaponType"));
			return;
		end

		EXCHANGEWEAPONTYPE_CREATE_LIST(frame, item, invItemGuid);
	end
	
	local itemObj = GetIES(invItem:GetObject());
	if itemObj == nil then
		return;
	end

	local targetSlot = GET_CHILD_RECURSIVELY(frame, 'item_slot_'..slotNum);
	EXCHANGEWEAPONTYPE_SET_SLOT_ITEM(invSlot, 1);
	targetSlot:SetUserValue('SELECTED_INV_GUID', invItemGuid);
	tolua.cast(targetSlot, "ui::CSlot");
	
	local targetIcon = targetSlot:GetIcon();
	if targetIcon == nil then
		targetIcon = CreateIcon(targetSlot);
	end
	SET_ITEM_TOOLTIP_ALL_TYPE(targetIcon, invItem, invItem.ClassName, "None", invItem.type, invItem:GetIESID());

	local slotPic = GET_CHILD_RECURSIVELY(frame, 'item_pic_'..slotNum, "ui::CPicture");
	slotPic:SetImage(item.Icon)
	local slotText = GET_CHILD_RECURSIVELY(frame, "item_text_"..slotNum, "ui::CRichText");
	slotText:SetText(GET_FULL_NAME(item));
end

function EXCHANGEWEAPONTYPE_CREATE_LIST(frame, item, guid)
	local pc = GetMyPCObject();
	if pc == nil then
		return;
	end

	if item == nil or guid == nil then
		return;
	end

	local group = TryGetProp(item, "ExchangeGroup", "None");
	local isExchange = IS_EXCHANGE_WEAPONTYPE(group, item.ClassName);		
	if isExchange == false then
		ui.SysMsg(ScpArgMsg("IMPOSSIBLE_ITEM"));
		return;
	end

	local bodyGbox_midle = GET_CHILD_RECURSIVELY(frame, 'bodyGbox_middle');
	if bodyGbox_midle == nil then 
		return; 
	end
	
	-- 교환 가능한 장비
	local exchangeItemNameList = GetExchangeItemList(group, item.ClassName);
	if exchangeItemNameList ~= nil then
		local exchangeItmeCount = #exchangeItemNameList;
		for i = 1, exchangeItmeCount do
			local className = exchangeItemNameList[i];
			if className ~= nil and className ~= "None" then
				local cls = GetClass("Item", className);
				if cls == nil then return; end
				local ctrlset = bodyGbox_midle:CreateOrGetControlSet("eachitem_in_exchange_weapontype", "EXCHANGE_WEAPONTYPE_CSET_"..(i - 1), 0, (i - 1) * 90);
				if ctrlset ~= nil then
					local icon = GET_CHILD_RECURSIVELY(ctrlset, "item_icon", "ui::CPicture");
					icon:ShowWindow(1);
					icon:SetImage(cls.Icon);

					local questionmark = GET_CHILD_RECURSIVELY(ctrlset, "item_questionmark", "ui::CPicture");
					questionmark:ShowWindow(0);
					
					local itemName = GET_LEGEND_PREFIX_ITEM_NAME(cls, TryGetProp(item, "LegendPrefix", "None"));
					local name = GET_CHILD_RECURSIVELY(ctrlset, "item_name", "ui::CRichText");
					name:SetText(itemName);

					ctrlset:ShowWindow(1);
					ctrlset:SetUserValue("ITEM_ID", cls.ClassID);

					local radioBtn = GET_CHILD_RECURSIVELY(ctrlset, "radioBtn", "ui::CRadioButton");
					if radioBtn ~= nil then
						radioBtn:SetEventScript(ui.LBUTTONUP, "EXCHANGEWEAPONTYPE_RADIOBTN_CLICK");
						radioBtn:SetCheck(false);
						radioBtn:ShowWindow(1);
					end
				end
			end
		end
		frame:SetUserValue("IS_ABLE_EXCHANGE", 1);
		frame:SetUserValue('MAX_EXCHANGEITEM_CNT', #exchangeItemNameList);
	else
		ui.SysMsg(ScpArgMsg("IMPOSSIBLE_ITEM_EXCHANGE"));
		return;
	end
end

function CLICK_EXCHANGE_WEAPONTYPE_RADIOBTN(parent)
	if parent == nil then return; end
	local frame = ui.GetFrame("exchangeweapontype");
	if frame ~= nil then
		local radioBtn = GET_CHILD_RECURSIVELY(parent, "radioBtn");
		local max_exchangeitem_cnt = frame:GetUserIValue("MAX_EXCHANGEITEM_CNT");
		for i = 0, max_exchangeitem_cnt - 1 do
			local ctrlSet = GET_CHILD_RECURSIVELY(frame, "EXCHANGE_WEAPONTYPE_CSET_"..i);
			if ctrlSet ~= nil then
				local search_radioBtn = GET_CHILD_RECURSIVELY(ctrlSet, "radioBtn", "ui::CRadioButton");
				if search_radioBtn ~= radioBtn then
					search_radioBtn:SetCheck(false);
				else
					radioBtn:SetCheck(true);
					local itemId = ctrlSet:GetUserIValue("ITEM_ID");
					frame:SetUserValue("NOW_SELECT_ITEM_ID", itemId);
					EXCHANGEWEAPONTYPE_SHOW_MATERIAL(frame, itemId);
					EXCHANGEWEAPONTYPE_SHOW_RESULT_ITEM(frame, itemId);
				end
			end
		end
	end
end

function EXCHANGEWEAPONTYPE_SHOW_MATERIAL(frame, itemId)
	if frame == nil then return; end
	if itemId == nil then return; end

	local pc = GetMyPCObject();
	if pc == nil then return; end

	local item = GetClassByType("Item", itemId);
	if item == nil then return; end

	local bodyGbox2 = GET_CHILD_RECURSIVELY(frame, "bodyGbox2");
	if bodyGbox2 == nil then return; end

	local drawDivisionArrow = bodyGbox2:CreateOrGetControlSet("draw_division_arrow", "DIVISION_ARROW", 12, 0);
	local divisionArrow = GET_CHILD_RECURSIVELY(drawDivisionArrow, "division_arrow");
	
	-- material
	local group = TryGetProp(item, "ExchangeGroup", "None");
	local nameList, countList = GET_EXCHANGE_WEAPONTYPE_MATERIAL(group, item.ClassName);
	if nameList ~= nil and countList ~= nil and #nameList > 0 and #countList > 0 then
		for i = 1, #nameList do
			local ctrlSet = bodyGbox2:CreateOrGetControlSet("eachmaterial_in_exchangeantique", "EXCHANGE_WEAPONTYPE_MAT_CSET"..i, 20, (i - 1) * 40);
			 if ctrlSet ~= nil then
				local icon = GET_CHILD_RECURSIVELY(ctrlSet, "material_icon", "ui::CPicture");
				local questionmark = GET_CHILD_RECURSIVELY(ctrlSet, "material_questionmark", "ui::CPicture");
				local name = GET_CHILD_RECURSIVELY(ctrlSet, "material_name", "ui::CRichText");
				local count = GET_CHILD_RECURSIVELY(ctrlSet, "material_count", "ui::CRichText");
				local grade = GET_CHILD_RECURSIVELY(ctrlSet, "grade", "ui::CRichText");

				icon:ShowWindow(1);
				count:ShowWindow(1);
				questionmark:ShowWindow(0);

				local materialCls = GetClass("Item", nameList[i]);
				if materialCls ~= nil and countList[i] > 0 then
					if i - 1 < #nameList then
						ctrlSet:ShowWindow(1);
						local invItemCount = GetInvItemCount(pc, materialCls.ClassName);
						if invItemCount < countList[i] then
							count:SetTextByKey("color", "{#EE0000}");
							frame:SetUserValue("IS_ABLE_EXCHANGE", 0);
						else
							count:SetTextByKey("color", nil);							
							frame:SetUserValue("IS_ABLE_EXCHANGE", 1);
						end
						count:SetTextByKey("curCount", invItemCount);
						count:SetTextByKey("needCount", countList[i]);
						session.AddItemID(materialCls.ClassID, countList[i]);
					else
						ctrlSet:ShowWindow(0);
					end
					name:SetText(materialCls.Name);
					icon:SetImage(materialCls.Icon);
				end
			 end
		end
	end
end

function EXCHANGEWEAPONTYPE_SHOW_RESULT_ITEM(frame, itemId)
	if frame == nil or itemId == nil then return; end
	local item = GetClassByType("Item", itemId);
	if item == nil then 
		return; 
	end
	
	if EXCHANGEWEAPONTYPE_CHANGE_ITEM_CHECK(frame, item) == false then
		return;
	end

	local resultSlot = GET_CHILD_RECURSIVELY(frame, "item_slot_2");
	if resultSlot ~= nil then
		resultSlot:SetUserValue("SELECTED_ID", itemId);
	end
	
	local targetIcon = resultSlot:GetIcon();
	if targetIcon == nil then
		targetIcon = CreateIcon(resultSlot);
	end
	targetIcon:SetTooltipType('wholeitem');
	targetIcon:SetTooltipArg("None", itemId);

	local resultSlotPicture = GET_CHILD_RECURSIVELY(frame, "item_pic_2", "ui::CPicture");
	if resultSlotPicture ~= nil then
		resultSlotPicture:SetImage(item.Icon);
	end

	local resultSlotText = GET_CHILD_RECURSIVELY(frame, "item_text_2", "ui::CRichText");
	if resultSlotText ~= nil then
		resultSlotText:SetText(GET_FULL_NAME(item));
	end
end

function EXCHANGEWEAPONTYPE_CHANGE_ITEM_CHECK(frame, item)
	if item == nil then
		return false;
	end

	if EXCHANGEWEAPONTYPE_GET_SLOT_ITEM_OBJECT(frame, 1) == nil then
		return false;
	end

	local group = TryGetProp(item, "ExchangeGroup", "None");
	local isExchange = IS_EXCHANGE_WEAPONTYPE(group, item.ClassName);
	if isExchange == nil or isExchange == false then
		ui.SysMsg(ScpArgMsg("IMPOSSIBLE_ITEM"));
		return false;
	end

	local targetSlot = GET_CHILD_RECURSIVELY(frame, 'item_slot_1');
	if targetSlot ~= nil then
		local guid = targetSlot:GetUserValue('SELECTED_INV_GUID');
		local targetItem = session.GetInvItemByGuid(guid);
		local targetObj = GetIES(targetItem:GetObject());
		if IS_ENABLE_EXCHANGE_WEAPONTYPE(targetObj, item.ClassID) == false then
			ui.SysMsg(ScpArgMsg("IMPOSSIBLE_ITEM"));
			return false;
		end	

		if item.ClassID == targetObj.ClassID then 
			ui.SysMsg(ScpArgMsg("SameItemClass"));
			return false;
		end		
	end
	return true;
end

function EXCHANGEWEAPONTYPE_DROP(frame, icon)
	local slotNum = 0;
	local slot = tolua.cast(icon, 'ui::CSlot');
	if slot:GetName() == 'item_slot_1' then
		slotNum = 1;
	else
		return;
	end
	EXCHANGEWEAPONTYPE_UI_CLEAR();
	local frame = ui.GetFrame('exchangeweapontype');
	local liftIcon = ui.GetLiftIcon();
	local FromFrame = liftIcon:GetTopParentFrame();
	frame = frame:GetTopParentFrame();
	if FromFrame:GetName() == 'inventory' then
		local iconInfo = liftIcon:GetInfo();
		local guid = iconInfo:GetIESID();
		local invItem = GET_ITEM_BY_GUID(guid);
		local obj = GetIES(invItem:GetObject());
		local isLuciferi = GET_CHILD_RECURSIVELY(frame,'title'):GetUserIValue('IsLuciferi') == 1
		_ADD_ITEM_TO_EXCHANGEWEAPONTYPE_FROM_INV(frame, obj, liftIcon:GetParent(), guid, slotNum, isLuciferi);
	end
end

function EXCHANGEWEAPONTYPE_INV_RBTN(itemobj, invSlot, invItemGuid)
	if invSlot:IsSelected() == 1 then
		EXCHANGEWEAPONTYPE_UI_CLEAR();
	else
		local frame = ui.GetFrame("exchangeweapontype")
		if EXCHANGEWEAPONTYPE_GET_SLOT_ITEM_OBJECT(frame, 1) == nil then
			local isLuciferi = GET_CHILD_RECURSIVELY(frame,'title'):GetUserIValue('IsLuciferi') == 1
			_ADD_ITEM_TO_EXCHANGEWEAPONTYPE_FROM_INV(frame, itemobj, invSlot, invItemGuid, 1, isLuciferi);
		else
			EXCHANGEWEAPONTYPE_UI_CLEAR();
		end
	end
end

function EXCHANGEWEAPONTYPE_SET_SLOT_ITEM(slot, isSelect)
	slot = AUTO_CAST(slot);
	if isSelect == 1 then
		slot:SetSelectedImage('socket_slot_check');
		slot:Select(1);
	else
		local guid = slot:GetUserValue('SELECTED_INV_GUID');
		if guid == 'None' then
			return;
		end
		SELECT_INV_SLOT_BY_GUID(guid, 0);
	end
end

function EXCHANGEWEAPONTYPE_SLOT_POP(parent, ctrl)
	if ctrl:GetName() == 'item_slot_1' then
		EXCHANGEWEAPONTYPE_UI_CLEAR();
	elseif ctrl:GetName() == 'item_slot_2' then
		local item_slot_2 = GET_CHILD_RECURSIVELY(parent,'item_slot_2', "ui::CSlot");
		if item_slot_2 ~= nil then
			item_slot_2:ClearIcon();
			EXCHANGEWEAPONTYPE_SET_SLOT_ITEM(item_slot_2, 0);
			item_slot_2:SetUserValue('SELECTED_INV_GUID', 'None');
			item_slot_2:SetUserValue('SELECTED_ID', 'None');
		end

		local item_pic_2 = GET_CHILD_RECURSIVELY(parent, 'item_pic_2', "ui::CPicture");
		if item_pic_2 ~= nil then
			item_pic_2:SetImage('socket_slot_bg');
		end

		local item_text_2 = GET_CHILD_RECURSIVELY(parent, 'item_text_2', "ui::CRichText");
		if item_text_2 ~= nil then
			item_text_2:SetText("");
		end
		
		local frame = parent:GetTopParentFrame();
		if frame ~= nil then
			local bodyGbox2 = GET_CHILD_RECURSIVELY(frame, 'bodyGbox2');
			bodyGbox2:RemoveAllChild();
		end
	end	
end

function EXCHANGEWEAPONTYPE_GET_SLOT_ITEM_OBJECT(frame, slotNum)
	local targetSlot = GET_CHILD_RECURSIVELY(frame, 'item_slot_'..slotNum, "ui::CSlot");
	if targetSlot == nil then
		return nil;
	end

	local guid = targetSlot:GetUserValue('SELECTED_INV_GUID');
	if guid == nil or guid == "None" then
		return nil;
	end
	
	local invItem = session.GetInvItemByGuid(guid);
	if invItem == nil or invItem:GetObject() == nil then
		return nil;
	end

	return GetIES(invItem:GetObject()), invItem:GetIESID();
end

function EXCHANGEWEAPONTYPE_RADIOBTN_CLICK(parent)
	local frame = ui.GetFrame("exchangeweapontype");
	local radioBtn = parent:GetChild('radioBtn');
	
	local MAX_EXCHANGEITEM_CNT = frame:GetUserIValue('MAX_EXCHANGEITEM_CNT');
	for i = 0, MAX_EXCHANGEITEM_CNT - 1 do
		local ctrlset = GET_CHILD_RECURSIVELY(frame, 'EXCHANGE_WEAPONTYPE_CSET_'..i);
		local _radioBtn = GET_CHILD(ctrlset, 'radioBtn', 'ui::CRadioButton');
		_radioBtn:SetEventScript(ui.LBUTTONUP, "EXCHANGEWEAPONTYPE_RADIOBTN_CLICK");
		if _radioBtn ~= radioBtn then
			_radioBtn:SetCheck(false);
		else
			radioBtn:SetCheck(true);
			frame:SetUserValue('NOW_SELECT_ITEM_ID', ctrlset:GetUserIValue('ITEM_ID'));			
		end
	end
end

function EXCHANGEWEAPONTYPE_EXCHANGE_BUTTON_CLICK(parent, ctrl)
	local frame = parent:GetTopParentFrame();
	if frame == nil then return; end

	local targetItem, targetItemGuid = EXCHANGEWEAPONTYPE_GET_SLOT_ITEM_OBJECT(frame, 1);
	if targetItem == nil then
		local targetSlot = GET_CHILD_RECURSIVELY(frame, 'item_slot_1');
		if targetSlot:GetIcon() ~= nil then
			ui.SysMsg(ClMsg('InvalidItemRegisterStep'));
		else
			ui.SysMsg(ClMsg('SelectSomeItemPlz'));
		end		
		return;
	end

	local changeSlot = GET_CHILD_RECURSIVELY(frame, "item_slot_2");
	if changeSlot == nil then 
		return; 
	end

	local changeItemid = changeSlot:GetUserIValue("SELECTED_ID");
	if changeItemid == nil then
		ui.SysMsg(ClMsg('SelectSomeItemPlz'));
		return;
	end

	if IS_ENABLE_EXCHANGE_WEAPONTYPE(targetItem, changeItemid) == false then 
		return; 
	end
	
	local invItem = session.GetInvItemByGuid(targetItemGuid);
	if invItem == nil then return; end		
	
	local function _GET_CHANGED_OPTION_STR(item, invItem)
		local str = '';
		local baseCls = GetClass('Item', item.ClassName);
		local checkPropList = GET_COPY_TARGET_OPTION_LIST();
		for i = 1, #checkPropList do
			if TryGetProp(baseCls, checkPropList[i]) ~= TryGetProp(item, checkPropList[i]) then
				if IsExistMsg(checkPropList[i]) == 1 then
					if str ~= '' then
						str = str..', ';
					end
					str = str..ClMsg(checkPropList[i]);
				end
			end
		end
        
        if item.MaxSocket > 100 then item.MaxSocket = 0 end
		for i = 0, item.MaxSocket - 1 do
			if invItem:IsAvailableSocket(i) == true then
				if str ~= '' then
					str = str..', ';
				end
				str = str..ClMsg('Gem');
				break;
			end
		end
		if str ~= '' then
			str = '['..str..'] ';
		end	
		return str;
	end

	local function _GET_CHANGED_PR_SOCKET_STR(invItem, exchangeItem)
		if invItem == nil or invItem:GetObject() == nil or exchangeItem == nil then
			return '';
		end
		local invItemObj = GetIES(invItem:GetObject());
		local addPR = GET_REBUILD_CARE_ADD_PR(invItemObj, exchangeItem, invItem);
		local str = '{@st66d_y}';
		if addPR ~= 0 then
			str = str..ClMsg('PR')..' '
			local resultPR = exchangeItem.MaxPR + addPR;
			resultPR = math.min(exchangeItem.MaxPR, resultPR);
			addPR = resultPR - invItemObj.PR;

			if addPR > 0 then
				str = str..tostring(addPR)..' '..ClMsg('Increase');
			else
				str = str..tostring(-addPR)..' '..ClMsg('Decrease');
			end
		end

		local curAvailableSocket = GET_CURRENT_AVAILABLE_SOCKET_COUNT(invItemObj, invItem);
		local resultSocket = curAvailableSocket;		
		if IS_REBUILD_CARE_ADD_PR_TARGET(invItemObj, exchangeItem) == true then
			resultSocket = resultSocket + 2;
		end		
		resultSocket = math.min(SCR_GET_MAX_SOKET(exchangeItem), resultSocket);		
		local addSocket = resultSocket - curAvailableSocket;
		if addSocket ~= 0 then
			if str ~= '' then
				str = str..', ';
			end

			str = str..ClMsg('JustSocket')..' '
			if addSocket > 0 then
				str = str..tostring(addSocket)..' '..ClMsg('Increase');
			else
				str = str..tostring(-addSocket)..' '..ClMsg('Decrease');
			end
		end
		return str..'{/}';
	end

	local isLuciferi = TryGetProp(targetItem, "ExchangeGroup", "None") == "Luciferi_Neck" or 
					   TryGetProp(targetItem, "ExchangeGroup", "None") == "Luciferi_Ring";

	if isLuciferi == false then 
		local msg = 'AntiqueExchange{OPTIONS}';
		local changeItemObj = GetClassByType('Item', changeItemid)

    	if TryGetProp(targetItem, "GroupName", "None") == "Armor" or TryGetProp(changeItemObj, "GroupName", "None") == "Armor" then
			msg = 'AntiqueExchange_Delete{OPTIONS}';
		end
	    local str = ScpArgMsg(msg, 'OPTIONS', _GET_CHANGED_OPTION_STR(targetItem, invItem), 'ADDINFO', _GET_CHANGED_PR_SOCKET_STR(invItem, GetClassByType('Item', tempSelectedItemIndex)));
		if frame:GetUserIValue('CARE_MODE') == 1 then
			str = str..'{nl}'..ClMsg('CanExchangeOnlyOnce');
	   	end
   
	   	local yesScp = string.format("EXCHANGEWEAPONTYPE_EXCHANGE_CHECK")
	   	ui.MsgBox(str, yesScp, "None");
	else
		EXCHANGEWEAPONTYPE_EXCHANGE_CHECK();
	end
end

function EXCHANGEWEAPONTYPE_EXCHANGE_CHECK()
	local frame = ui.GetFrame("exchangeweapontype");
	if frame == nil then return; end
	
	-- slot1 아이템
	local targetItem, targetItemGuid = EXCHANGEWEAPONTYPE_GET_SLOT_ITEM_OBJECT(frame, 1); 	
	if targetItem == nil or targetItemGuid == nil then return; end

	-- slot2 아이템
	local changeSlot = GET_CHILD_RECURSIVELY(frame, "item_slot_2");
	if changeSlot == nil then 
		return; 
	end

	local changeItemid = changeSlot:GetUserIValue("SELECTED_ID");
	if changeItemid == nil then 
		return; 
	end
	
	-- 교환 가능 여부
	local isAbleExchange = frame:GetUserIValue("IS_ABLE_EXCHANGE");
	if isAbleExchange == 0 then
		ui.SysMsg(ScpArgMsg("NotEnoughRecipe"));
		return;
	end

	local isExchange = IS_ENABLE_EXCHANGE_WEAPONTYPE(targetItem, changeItemid);
	if isExchange == false then 
		return; 
	end

	EXCHANGEWEAPONTYPE_EXEC(targetItemGuid, changeItemid);
	EXCHANGEWEAPONTYPE_UI_CLEAR();
end

function EXCHANGEWEAPONTYPE_EXEC(guid, id)
	if guid == nil or id == nil then
		return;
	end	
	item.ExchangeWeapontype(guid, id);
end

function EXCHANGEWEAPONTYPE_UI_CLEAR()
	local frame = ui.GetFrame("exchangeweapontype");
	if frame == nil then return; end

	frame:SetUserValue('NOW_SELECT_ITEM_ID', 0)
	frame:SetUserValue("IS_ABLE_EXCHANGE", 0);

	local item_slot_1 = GET_CHILD_RECURSIVELY(frame, 'item_slot_1', "ui::CSlotSet");
	if item_slot_1 ~= nil then
		item_slot_1:ClearIcon();
		EXCHANGEWEAPONTYPE_SET_SLOT_ITEM(item_slot_1, 0);
		item_slot_1:SetUserValue('SELECTED_INV_GUID', 'None');
	end

	local item_pic_1 = GET_CHILD_RECURSIVELY(frame, 'item_pic_1', "ui::CPicture");
	if item_pic_1 ~= nil then
		item_pic_1:SetImage('socket_slot_bg')
	end

	local item_text_1 = GET_CHILD_RECURSIVELY(frame, 'item_text_1', "ui::CRichText");
	if item_text_1 ~= nil then
		item_text_1:SetText(ScpArgMsg('DropItemPlz'))
	end

	local item_slot_2 = GET_CHILD_RECURSIVELY(frame,'item_slot_2', "ui::CSlotSet");
	if item_slot_2 ~= nil then
		item_slot_2:ClearIcon();
		EXCHANGEWEAPONTYPE_SET_SLOT_ITEM(item_slot_2, 0);
		item_slot_2:SetUserValue('SELECTED_INV_GUID', 'None');
		item_slot_2:SetUserValue('SELECTED_ID', 'None');
	end

	local item_pic_2 = GET_CHILD_RECURSIVELY(frame, 'item_pic_2', "ui::CPicture");
	if item_pic_2 ~= nil then
		item_pic_2:SetImage('socket_slot_bg')
	end

	local item_text_2 = GET_CHILD_RECURSIVELY(frame, 'item_text_2', "ui::CRichText");
	if item_text_2 ~= nil then
		item_text_2:SetText("");
	end

	local bodyGbox_midle = GET_CHILD_RECURSIVELY(frame, 'bodyGbox_middle');
	if bodyGbox_midle ~= nil then
		bodyGbox_midle:RemoveAllChild();
	end

	local bodyGbox2 = GET_CHILD_RECURSIVELY(frame, 'bodyGbox2');
	if bodyGbox2 ~= nil then
		bodyGbox2:RemoveAllChild();
	end
end




--------- 루시페리 장신구 교환 ------------

function EXCHANGELUCIFERI_OPEN()
	local frame = ui.GetFrame("exchangeweapontype")
	INVENTORY_SET_CUSTOM_RBTNDOWN("EXCHANGEWEAPONTYPE_INV_RBTN");
	EXCHANGEWEAPONTYPE_UI_CLEAR();
	EXCHANGELUCIFERI_UI_INIT_SETTING(frame);
	frame:OpenFrame(1);
	ui.OpenFrame("inventory");
end

function EXCHANGELUCIFERI_UI_INIT_SETTING(frame)
	if frame ~= nil then
		local help_pic = GET_CHILD_RECURSIVELY(frame, "helpPic");
		if help_pic ~= nil then
			local tooltip_text = ClMsg("LuciferiTypeExchange_Help");
			-- 루시페리 교환 텍스트 따로 파서 설정할 수 있도록
			help_pic:SetTextTooltip(tooltip_text);
			help_pic:Invalidate();
		end
		local title = GET_CHILD_RECURSIVELY(frame, "title");
		title:SetTextByKey('title',ClMsg('ExchangeLuciferi'));
		title:SetUserValue("IsLuciferi",1)
	end
end

