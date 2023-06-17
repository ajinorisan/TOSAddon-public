
function COMPOSITION_VIBORA_ON_INIT(addon, frame)
	addon:RegisterMsg("OPEN_DLG_COMPOSITION_VIBORA", "ON_OPEN_DLG_COMPOSITION_VIBORA");
	addon:RegisterMsg("COMPOSITION_VIBORA_SUCCESS", "COMPOSITION_VIBORA_SUCCESS");
	addon:RegisterMsg("EVENT_2011_5TH_VIBORA_COMPOSITE_SUCCESS", "COMPOSITION_VIBORA_SUCCESS");
end

-- TYPE = 1 : 일반, 2 : 5주년 이벤트(EVENT_2011_5TH), 3 : 왕국 재건단의 보급품(EVENT_2101_SUPPLY)
function ON_OPEN_DLG_COMPOSITION_VIBORA(type)
	if type == nil then
		type = 1;
	end

	local frame = ui.GetFrame("composition_vibora");
	frame:SetUserValue("TYPE", type);
	frame:ShowWindow(1);
end

function COMPOSITION_VIBORA_OPEN(frame)
	local type = frame:GetUserIValue("TYPE");
	local title = GET_CHILD(frame, "title");
	title:SetTextByKey("value", frame:GetUserConfig("TITLE_COMMON"));

	local do_composition = GET_CHILD(frame, "do_composition");
	do_composition:SetTextTooltip("");

	if type == 2 then -- EVENT_2011_5TH
		title:SetTextByKey("value", ClMsg("EVENT_2011_5TH_Special_Vibora_Shop_title"));		
		do_composition:SetTextTooltip(ClMsg("EVENT_2011_5TH_Use_5th_Coin_tip_MSG_2"));
	elseif type == 3 then
		title:SetTextByKey("value", ClMsg("EVENT_2101_SUPPLY_COMPOSITION_VIBORA_TITLE"));
	end

    COMPOSITION_VIBORA_UI_RESET();
	
	INVENTORY_SET_CUSTOM_RBTNDOWN("COMPOSITION_VIBORA_INV_RBTNDOWN");
	ui.OpenFrame("inventory");
end

function COMPOSITION_VIBORA_CLOSE(frame)
	if ui.CheckHoldedUI() == true then
		return;
	end

	INVENTORY_SET_CUSTOM_RBTNDOWN("None");

    frame:ShowWindow(0);
end

function COMPOSITION_VIBORA_SLOT_RESET(slot, slotIndex)	
	if IS_CHECK_COMPOSITION_VIBORA_RESULT() == true then
		return;
	end

	slot:SetUserValue("CLASS_NAME", "None");
	slot:SetUserValue("GUID", "None");
	slot:SetText("", "count", ui.RIGHT, ui.BOTTOM, -5, -5);
	slot:ClearIcon();
	
	local slot_img = GET_CHILD(slot, 'slot_img_'..slotIndex);
	slot_img:ShowWindow(1);
end

function COMPOSITION_VIBORA_UI_RESET()
	local frame = ui.GetFrame("composition_vibora");
	
	local reinfResultBox = GET_CHILD(frame, "reinfResultBox");
	reinfResultBox:ShowWindow(0);

	local do_composition = GET_CHILD(frame, "do_composition");
	do_composition:ShowWindow(1);

	local resetBtn = GET_CHILD(frame, "resetBtn");
	resetBtn:ShowWindow(0);
	
	local tip_text = GET_CHILD(frame, "tip_text");
	tip_text:ShowWindow(1);

	local event_gb = GET_CHILD(frame, "event_gb");
	event_gb:ShowWindow(0);

	local event_tip_text = GET_CHILD(frame, "event_tip_text");
	event_tip_text:ShowWindow(0);	

	local count_text = GET_CHILD(frame, "count_text");
	count_text:ShowWindow(0);

	local type = frame:GetUserIValue("TYPE");
	if type == 2 then -- EVENT_2011_5TH
		event_gb:RemoveAllChild();
		local msg1 = event_gb:CreateOrGetControl('richtext', "msg1", 0, 0, 400, 20);
		msg1:SetGravity(ui.CENTER_HORZ, ui.TOP);
		msg1:SetText("{@st43}{s22}"..ClMsg("NeedItem"));

		local msg2 = event_gb:CreateOrGetControl('richtext', "msg2", 0, 0, 400, 20);
		msg2:SetGravity(ui.CENTER_HORZ, ui.TOP);
		msg2:SetMargin(0, 45, 0, 0)
		msg2:SetText("");
		msg2:SetText("{@st66b}{s20}"..ClMsg("EVENT_2011_5TH_Special_Vibora_Shop_Material"));
		msg2:SetTextAlign("center", "center");
		event_tip_text:SetTextByKey("value", ClMsg("EVENT_2011_5TH_Special_Vibora_Shop_tip"));

		local aObj = GetMyAccountObj();
		local cnt = TryGetProp(aObj, "EVENT_2011_5TH_SPECIAL_VIBORA_SHOP_USE_COUNT", 9999999);
		count_text:SetTextByKey("cur", cnt);
		count_text:SetTextByKey("max", GET_EVENT_2011_5TH_VIBORA_COMPOSITE_MAX_COUNT());

		event_gb:ShowWindow(1);
		event_tip_text:ShowWindow(1);
		tip_text:ShowWindow(0);
		count_text:ShowWindow(1);
	elseif type == 3 then
		event_gb:RemoveAllChild();
		
		local msg1 = event_gb:CreateOrGetControl('richtext', "msg1", 0, 0, 400, 20);
		msg1:SetGravity(ui.CENTER_HORZ, ui.TOP);
		msg1:SetText("{@st43}{s22}"..ClMsg("NeedItem"));

		local msg2 = event_gb:CreateOrGetControl('richtext', "msg2", 0, 0, 400, 20);
		msg2:SetGravity(ui.CENTER_HORZ, ui.TOP);
		msg2:SetMargin(0, 45, 0, 0)
		msg2:SetText("");
		msg2:SetText("{@st66b}{s20}"..ClMsg("EVENT_2101_SUPPLY_COMPOSITION_VIBORA_NEED_ITEM"));
		msg2:SetTextAlign("center", "center");

		event_tip_text:SetTextByKey("value", ClMsg("EVENT_2101_SUPPLY_COMPOSITION_VIBORA_TIP_TEXT"));

		event_gb:ShowWindow(1);
		event_tip_text:ShowWindow(1);
		tip_text:ShowWindow(0);
	end

    local need_count = GET_COMPOSITION_VIROBA_SOURCE_COUNT();
	for i = 1, need_count do 
		local slot = GET_CHILD(frame, "slot_"..i);
		COMPOSITION_VIBORA_SLOT_RESET(slot, i);
	end
end

function COMPOSITION_VIBORA_SAME_ITEM_CHECK(guid)
	local frame = ui.GetFrame("composition_vibora");
    local need_count = GET_COMPOSITION_VIROBA_SOURCE_COUNT()
	for i = 1, need_count do 
		local slot = GET_CHILD(frame, "slot_"..i);
		if slot:GetIcon() ~= nil and guid == slot:GetUserValue("GUID") then
			return false;
		end
	end

	return true;
end

function COMPOSITION_VIBORA_ITEM_REG(guid, ctrl, slotIndex)
	if ui.CheckHoldedUI() == true then
		return;
    end
    
	if IS_CHECK_COMPOSITION_VIBORA_RESULT() == true then
		return;
	end

	local invItem = session.GetInvItemByGuid(guid);
	if invItem == nil then
		return;
    end
    
	if invItem.isLockState == true then
		ui.SysMsg(ClMsg("MaterialItemIsLock"));
		return;
	end

    local itemObj = GetIES(invItem:GetObject());
	local ret, ret_classname = IS_COMPOSABLE_VIRORA(itemObj);
    if ret == false or ret_classname == 'None' then
        return;
	end
		
	if COMPOSITION_VIBORA_SAME_ITEM_CHECK(guid) == false then
		return;
	end

	SET_SLOT_ITEM(ctrl, invItem);
	ctrl:SetUserValue("CLASS_NAME", ret_classname);
	ctrl:SetUserValue("GUID", guid);
	
	local slot_img = GET_CHILD(ctrl, 'slot_img_'..slotIndex);
	slot_img:ShowWindow(0);
end

function COMPOSITION_VIBORA_INV_RBTNDOWN(itemObj, slot)
	if ui.CheckHoldedUI() == true then
		return;
	end

	local frame = ui.GetFrame("composition_vibora");
	if frame == nil then
		return;
	end

	local type = frame:GetUserIValue("TYPE");
	local icon = slot:GetIcon();
	local iconInfo = icon:GetInfo();
	
	if type == 2 then -- EVENT_2011_5TH
		EVENT_2011_5TH_SPECIAL_VIBORA_ITEM_REG(iconInfo:GetIESID());
		return;
	elseif type == 3 then
		EVENT_2101_SUPPLY_VIBORA_ITEM_REG(iconInfo:GetIESID());
		return;
	end

	local need_count = GET_COMPOSITION_VIROBA_SOURCE_COUNT()
	for i = 1, need_count do 
		local ctrl = GET_CHILD(frame, "slot_"..i);
		if ctrl:GetIcon() == nil then
			local ctrl = GET_CHILD(frame, "slot_"..i);
			COMPOSITION_VIBORA_ITEM_REG(iconInfo:GetIESID(), ctrl, i);
			return;
		end
	end
end

function COMPOSITION_VIBORA_ITEM_DROP(parent, ctrl, argStr, slotIndex)
	local liftIcon = ui.GetLiftIcon();
	local FromFrame = liftIcon:GetTopParentFrame();
	if FromFrame:GetName() == 'inventory' then
		local iconInfo = liftIcon:GetInfo();

		local frame = ctrl:GetTopParentFrame();
		local type = frame:GetUserIValue("TYPE");
		if type == 2 then -- EVENT_2011_5TH
			EVENT_2011_5TH_SPECIAL_VIBORA_ITEM_REG(iconInfo:GetIESID());
			return;
		elseif type == 3 then 
			EVENT_2101_SUPPLY_VIBORA_ITEM_REG(iconInfo:GetIESID());
			return;
		end

		COMPOSITION_VIBORA_ITEM_REG(iconInfo:GetIESID(), ctrl, slotIndex);
	end
end

function COMPOSITION_VIBORA_ITEM_POP(parent, ctrl, argStr, slotIndex)
	if ui.CheckHoldedUI() == true then
		return;
	end

	COMPOSITION_VIBORA_SLOT_RESET(ctrl, slotIndex);
end

function COMPOSITION_VIBORA_BTN_CLICK(parent, ctrl)
	if ui.CheckHoldedUI() == true then
		return;
	end

	local frame = parent:GetTopParentFrame();
	local type = frame:GetUserIValue("TYPE");
	if type == 2 then -- EVENT_2011_5TH
		EVENT_2011_5TH_SPECIAL_VIBORA_BTN_CLLICK();
		return;
	elseif type == 3 then
		EVENT_2101_SUPPLY_VIBORA_BTN_CLLICK();
		return;
	end

	session.ResetItemList();
    local need_count = GET_COMPOSITION_VIROBA_SOURCE_COUNT();
	for i = 1, need_count do 
		local slot = GET_CHILD(frame, "slot_"..i);
		if slot:GetIcon() == nil then
			return;
		end

		local invItem = GET_SLOT_ITEM(slot);
		local itemobj = GetIES(invItem:GetObject());
		if IS_COMPOSABLE_VIRORA(itemobj) == false then
			return;
		end

		local guid = slot:GetUserValue("GUID");
		session.AddItemID(guid, 1);
	end

	local COMPOSITON_SLOT_EFFECT = frame:GetUserConfig("COMPOSITON_SLOT_EFFECT");
	local need_count = GET_COMPOSITION_VIROBA_SOURCE_COUNT();
	for i = 1, need_count do 
		local slot = GET_CHILD(frame, "slot_"..i);
		slot:PlayUIEffect(COMPOSITON_SLOT_EFFECT, 4.2, "COMPOSITON_SLOT_EFFECT", true);
	end

	ui.SetHoldUI(true);
	ReserveScript("COMPOSITION_VIBORA_UNFREEZE()", 3);

	local resultlist = session.GetItemIDList();
	item.DialogTransaction("COMPOSITION_VIBORA", resultlist);
end

function COMPOSITION_VIBORA_UNFREEZE()	
	ui.SetHoldUI(false);
end

function COMPOSITION_VIBORA_SUCCESS(frame, msg, guid)
	local frame = ui.GetFrame("composition_vibora");

	local reinfResultBox = GET_CHILD(frame, "reinfResultBox");
	reinfResultBox:ShowWindow(1);

	local do_composition = GET_CHILD(frame, "do_composition");
	do_composition:ShowWindow(0);

	local resetBtn = GET_CHILD(frame, "resetBtn");
	resetBtn:ShowWindow(1);

	local invItem = session.GetInvItemByGuid(guid);
	local successItem = GET_CHILD_RECURSIVELY(frame, "successItem");
	SET_SLOT_ITEM(successItem, invItem);	

	local RESULT_EFFECT = frame:GetUserConfig("RESULT_EFFECT");
	local successItem = GET_CHILD_RECURSIVELY(reinfResultBox, "successItem");
	successItem:PlayUIEffect(RESULT_EFFECT, 5, "RESULT_EFFECT", true);	
end

function IS_CHECK_COMPOSITION_VIBORA_RESULT()
	local frame = ui.GetFrame("composition_vibora");

	local resetBtn = GET_CHILD(frame, "resetBtn");
	if resetBtn:IsVisible() == 1 then
		return true;
	end

	return false;
end

----------------------------- EVENT_2011_5TH
function EVENT_2011_5TH_SPECIAL_VIBORA_ITEM_REG(guid)
	local frame = ui.GetFrame("composition_vibora");
	local invItem = session.GetInvItemByGuid(guid);
	if invItem == nil then return; end	
	local itemObj = GetIES(invItem:GetObject());
	if itemObj.ClassName == "Event_2011_TOS_Coin" then
		slotIndex = 2;
	elseif itemObj.ClassName == "Event_2011_5th_Coin" then
		slotIndex = 3;
	else 
		slotIndex = 1;
	end

	local invItem = session.GetInvItemByGuid(guid);
	if invItem == nil then
		return;
    end
    
	if invItem.isLockState == true then
		ui.SysMsg(ClMsg("MaterialItemIsLock"));
		return;
	end

	local itemObj = GetIES(invItem:GetObject());
	local ctrl = GET_CHILD(frame, "slot_"..slotIndex);

	if slotIndex == 1 then
		local ret, ret_classname = IS_COMPOSABLE_VIRORA(itemObj);
		local test = TryGetProp(itemObj, 'InheritanceItemName', 'None')
		if ret == false or ret_classname == 'None' then
			local group_name = TryGetProp(itemObj, 'GroupName', 'None');
			if group_name == 'Icor' then
				local class_name = TryGetProp(itemObj, 'InheritanceItemName', 'None')
				local cls = GetClass('Item', class_name)
				if cls ~= nil then
					if TryGetProp(cls, 'StringArg', 'None') == 'Vibora' and 1 < TryGetProp(cls, 'NumberArg1', 0) then
						ui.SysMsg(ClMsg("CannotCompositionUpgradeItem"));
					return;
					end
				end
			else
				if TryGetProp(itemObj, 'StringArg', 'None') == 'Vibora' and 1 < TryGetProp(itemObj, 'NumberArg1', 0) then
					ui.SysMsg(ClMsg("CannotCompositionUpgradeItem"));
					return;
				end
			end

			ui.SysMsg(ClMsg("CannotCompositionItem"));
			return;
		end

		SET_SLOT_ITEM(ctrl, invItem);
		ctrl:SetUserValue("CLASS_NAME", ret_classname);
		ctrl:SetUserValue("GUID", guid);

		local slot_img = GET_CHILD(ctrl, 'slot_img_'..slotIndex);
		slot_img:ShowWindow(0);
	elseif slotIndex == 2 then
		if itemObj.ClassName ~= "Event_2011_TOS_Coin" then
			ui.SysMsg(ClMsg("CannotCompositionItem"));
			return;
		end

		local curCnt = GET_INV_ITEM_COUNT_BY_PROPERTY({{Name = "ClassName", Value = "Event_2011_TOS_Coin"}}, false);
		local needCnt = GET_EVENT_2011_5TH_SPECIAL_VIBORA_NEED_COIN_TOS_COUNT();
		if curCnt < needCnt then
			ui.SysMsg(ClMsg("NotEnoughCompositionNeedItem"));
			return;
		end

		SET_SLOT_ITEM(ctrl, invItem);
		ctrl:SetUserValue("CLASS_NAME", ret_classname);
		ctrl:SetUserValue("GUID", guid);
		ctrl:SetText("{s18}{ol}{b}"..GET_EVENT_2011_5TH_SPECIAL_VIBORA_NEED_COIN_TOS_COUNT(), "count", ui.RIGHT, ui.BOTTOM, -5, -5);

		local slot_img = GET_CHILD(ctrl, 'slot_img_'..slotIndex);
		slot_img:ShowWindow(0);
	elseif slotIndex == 3 then
		if itemObj.ClassName ~= "Event_2011_5th_Coin" then
			ui.SysMsg(ClMsg("CannotCompositionItem"));
			return;
		end

		local curCnt = GET_INV_ITEM_COUNT_BY_PROPERTY({{Name = "ClassName", Value = "Event_2011_5th_Coin"}}, false);
		local needCnt = GET_EVENT_2011_5TH_SPECIAL_VIBORA_NEED_COIN_COUNT();
		if curCnt < needCnt then
			ui.SysMsg(ClMsg("NotEnoughCompositionNeedItem"));
			return;
		end

		SET_SLOT_ITEM(ctrl, invItem);
		ctrl:SetUserValue("CLASS_NAME", ret_classname);
		ctrl:SetUserValue("GUID", guid);
		ctrl:SetText("{s18}{ol}{b}"..needCnt, "count", ui.RIGHT, ui.BOTTOM, -5, -5);

		local slot_img = GET_CHILD(ctrl, 'slot_img_'..slotIndex);
		slot_img:ShowWindow(0);
	end
end

function EVENT_2011_5TH_SPECIAL_VIBORA_BTN_CLLICK()
	if ui.CheckHoldedUI() == true then
		return;
	end

	local lv = GETMYPCLEVEL();
	local limitLv = GET_EVENT_2011_5TH_VIBORA_COMPOSITE_LV_LIMIT();
	if lv < limitLv then
		ui.SysMsg(ScpArgMsg("Enable_Pc_{LV}", "LV", limitLv));
		return;
	end

	local aObj = GetMyAccountObj();
	local cnt = TryGetProp(aObj, "EVENT_2011_5TH_SPECIAL_VIBORA_SHOP_USE_COUNT", 9999999);
	if GET_EVENT_2011_5TH_VIBORA_COMPOSITE_MAX_COUNT() <= cnt then
		ui.SysMsg(ClMsg("EVENT_2011_5TH_Special_Vibora_Shop_Max_Count_Over"));
		return;
	end

	local frame = ui.GetFrame("composition_vibora");
	session.ResetItemList();
	for i = 1, 3 do 
		local slot = GET_CHILD(frame, "slot_"..i);
		if slot:GetIcon() == nil then
			ui.SysMsg(ClMsg("NotEnoughCompositionNeedItem"));
			return;
		end

		local invItem = GET_SLOT_ITEM(slot);
		local itemObj = GetIES(invItem:GetObject());
		if i == 1 then
			local ret, ret_classname = IS_COMPOSABLE_VIRORA(itemObj);
			if ret == false or ret_classname == 'None' then
				return;
			end

			local guid = slot:GetUserValue("GUID");
			session.AddItemID(guid, 1);
		elseif i == 2 then
			if itemObj.ClassName ~= "Event_2011_TOS_Coin" then
				return;
			end
		elseif i == 3 then
			if itemObj.ClassName ~= "Event_2011_5th_Coin" then
				return;
			end
		end
	end
	
	local COMPOSITON_SLOT_EFFECT = frame:GetUserConfig("COMPOSITON_SLOT_EFFECT");
	local need_count = GET_COMPOSITION_VIROBA_SOURCE_COUNT();
	for i = 1, need_count do 
		local slot = GET_CHILD(frame, "slot_"..i);
		slot:PlayUIEffect(COMPOSITON_SLOT_EFFECT, 4.2, "COMPOSITON_SLOT_EFFECT", true);
	end

	ui.SetHoldUI(true);
	ReserveScript("COMPOSITION_VIBORA_UNFREEZE()", 3);
	
	local resultlist = session.GetItemIDList();
	item.DialogTransaction("EVENT_2011_5TH_VIBORA_COMPOSITE", resultlist);
end

----------------------------- EVENT_2101_SUPPLY
function EVENT_2101_SUPPLY_VIBORA_ITEM_REG(guid)
	local frame = ui.GetFrame("composition_vibora");
	local invItem = session.GetInvItemByGuid(guid);
	if invItem == nil then return; end	
	
	if COMPOSITION_VIBORA_SAME_ITEM_CHECK(guid) == false then
		ui.SysMsg(ClMsg("AlreadRegSameItem"));
		return;
	end

	local matClassName = "Event_Vibora_Ticket";
	local itemObj = GetIES(invItem:GetObject());
	if itemObj.ClassName == matClassName then
		slotIndex = 3;
	else 
		local slot = GET_CHILD(frame, "slot_1");
		local invItem = GET_SLOT_ITEM(slot);
		if invItem == nil then
			slotIndex = 1;
		else
			slotIndex = 2;
		end
	end

	local invItem = session.GetInvItemByGuid(guid);
	if invItem == nil then
		return;
    end
    
	if invItem.isLockState == true then
		ui.SysMsg(ClMsg("MaterialItemIsLock"));
		return;
	end

	local itemObj = GetIES(invItem:GetObject());
	local ctrl = GET_CHILD(frame, "slot_"..slotIndex);

	if slotIndex == 3 then
		if itemObj.ClassName ~= matClassName then
			ui.SysMsg(ClMsg("CannotCompositionItem"));
			return;
		end

		local curCnt = GET_INV_ITEM_COUNT_BY_PROPERTY({{Name = "ClassName", Value = matClassName}}, false);
		local needCnt = GET_EVENT_2101_SUPPLY_VIBORA_COMPOSITE_TICKET_NEED_COUNT();
		if curCnt < needCnt then
			ui.SysMsg(ClMsg("NotEnoughCompositionNeedItem"));
			return;
		end

		SET_SLOT_ITEM(ctrl, invItem);
		ctrl:SetUserValue("CLASS_NAME", ret_classname);
		ctrl:SetUserValue("GUID", guid);
		ctrl:SetText("{s18}{ol}{b}"..needCnt, "count", ui.RIGHT, ui.BOTTOM, -5, -5);

		local slot_img = GET_CHILD(ctrl, 'slot_img_'..slotIndex);
		slot_img:ShowWindow(0);
	else
		local ret, ret_classname = IS_COMPOSABLE_VIRORA(itemObj);
		local test = TryGetProp(itemObj, 'InheritanceItemName', 'None')
		if ret == false or ret_classname == 'None' then
			local group_name = TryGetProp(itemObj, 'GroupName', 'None');
			if group_name == 'Icor' then
				local class_name = TryGetProp(itemObj, 'InheritanceItemName', 'None')
				local cls = GetClass('Item', class_name)
				if cls ~= nil then
					if TryGetProp(cls, 'StringArg', 'None') == 'Vibora' and 1 < TryGetProp(cls, 'NumberArg1', 0) then
						ui.SysMsg(ClMsg("CannotCompositionUpgradeItem"));
					return;
					end
				end
			else
				if TryGetProp(itemObj, 'StringArg', 'None') == 'Vibora' and 1 < TryGetProp(itemObj, 'NumberArg1', 0) then
					ui.SysMsg(ClMsg("CannotCompositionUpgradeItem"));
					return;
				end
			end

			ui.SysMsg(ClMsg("CannotCompositionItem"));
			return;
		end

		SET_SLOT_ITEM(ctrl, invItem);
		ctrl:SetUserValue("CLASS_NAME", ret_classname);
		ctrl:SetUserValue("GUID", guid);

		local slot_img = GET_CHILD(ctrl, 'slot_img_'..slotIndex);
		slot_img:ShowWindow(0);
	end
end

function EVENT_2101_SUPPLY_VIBORA_BTN_CLLICK()
	if ui.CheckHoldedUI() == true then
		return;
	end

	local lv = GETMYPCLEVEL();
	local limitLv = GET_EVENT_2101_SUPPLY_VIBORA_COMPOSITE_LEVEL();
	if lv < limitLv then
		ui.SysMsg(ScpArgMsg("Enable_Pc_{LV}", "LV", limitLv));
		return;
	end

	local aObj = GetMyAccountObj();

	local frame = ui.GetFrame("composition_vibora");
	session.ResetItemList();
	for i = 1, 3 do 
		local slot = GET_CHILD(frame, "slot_"..i);
		if slot:GetIcon() == nil then
			ui.SysMsg(ClMsg("NotEnoughCompositionNeedItem"));
			return;
		end

		local invItem = GET_SLOT_ITEM(slot);
		local itemObj = GetIES(invItem:GetObject());
		local guid = slot:GetUserValue("GUID");
		if i == 3 then
			if itemObj.ClassName ~= "Event_Vibora_Ticket" then
				ui.SysMsg(ClMsg("CannotCompositionItem"));
				return;
			end
			session.AddItemID(guid, i);
		else			
			local ret, ret_classname = IS_COMPOSABLE_VIRORA(itemObj);
			if ret == false or ret_classname == 'None' then
				ui.SysMsg(ClMsg("CannotCompositionItem"));
				return;
			end

			session.AddItemID(guid, i);
		end
	end
	
	local COMPOSITON_SLOT_EFFECT = frame:GetUserConfig("COMPOSITON_SLOT_EFFECT");
	local need_count = GET_COMPOSITION_VIROBA_SOURCE_COUNT();
	for i = 1, need_count do 
		local slot = GET_CHILD(frame, "slot_"..i);
		slot:PlayUIEffect(COMPOSITON_SLOT_EFFECT, 4.2, "COMPOSITON_SLOT_EFFECT", true);
	end

	ui.SetHoldUI(true);
	ReserveScript("COMPOSITION_VIBORA_UNFREEZE()", 3);
	
	local resultlist = session.GetItemIDList();
	item.DialogTransaction("EVENT_2101_SUPPLY_VIBORA_COMPOSITE", resultlist);
end
