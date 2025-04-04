function ARK_LVUP_SCROLL_ON_INIT(addon, frame)
	addon:RegisterMsg("ARK_LVUP_COMPLETE", "ARK_LVUP_SCROLL_RESULT")
	addon:RegisterMsg("ARK_CONVERT_COMPLETE", "ARK_CONVERT_SCROLL_RESULT")
end

function ARK_LVUP_SCROLL_TARGET_ITEM_SLOT(slot, invItem, scrollClsID)
	local itemCls = GetClassByType("Item", invItem.type);

	local type = itemCls.ClassID;
	local obj = GetIES(invItem:GetObject());
	local img = GET_ITEM_ICON_IMAGE(obj);
	SET_SLOT_IMG(slot, img)
	SET_SLOT_COUNT(slot, count)
	SET_SLOT_IESID(slot, invItem:GetIESID())
	
	local icon = slot:GetIcon();
	local iconInfo = icon:GetInfo();
	iconInfo.type = type;

	icon:SetTooltipType("reinforceitem");
	icon:SetTooltipArg("transcendscroll", scrollClsID, invItem:GetIESID());
	
end

function ARK_LVUP_SCROLL_EXEC_ASK_AGAIN(frame, btn)
	local scrollType = frame:GetUserValue("ScrollType")
	if scrollType ~= "ArkLVUPScroll" then return end

	local clickable = frame:GetUserValue("EnableTranscendButton")
	if tonumber(clickable) ~= 1 then
		return;
	end

	local slot = GET_CHILD(frame, "slot");
	local invItem = GET_SLOT_ITEM(slot);
	if invItem == nil then
		ui.MsgBox(ScpArgMsg("DropItemPlz"));
		imcSound.PlaySoundEvent(frame:GetUserConfig("TRANS_BTN_OVER_SOUND"));
		return;
	end

	local itemObj = GetIES(invItem:GetObject());

	local scrollGuid = frame:GetUserValue("ScrollGuid")
	local scrollInvItem = session.GetInvItemByGuid(scrollGuid);
	if scrollInvItem == nil then
		ui.SysMsg(ScpArgMsg('TranscendScrollNotExist'));
		return;
	end
	local scrollObj = GetIES(scrollInvItem:GetObject());
	local clmsg = ScpArgMsg("ArkLvupScrollWarning{Before}{After}", "Before", TryGetProp(itemObj, 'ArkLevel', 1), "After", TryGetProp(scrollObj, 'NumberArg1', 0))    
	imcSound.PlaySoundEvent(frame:GetUserConfig("TRANS_BTN_OK_SOUND"));
	ui.MsgBox_NonNested(clmsg, frame:GetName(), "ARK_LVUP_SCROLL_EXEC", "None");
end

function ARK_LVUP_SCROLL_RESULT(frame, msg, arg_str, arg_num)
	local frame = ui.GetFrame("ark_lvup_scroll");
	if arg_num == 1 then
		local animpic_bg = GET_CHILD_RECURSIVELY(frame, "animpic_bg");
		animpic_bg:ShowWindow(1);
		animpic_bg:ForcePlayAnimation();
		ReserveScript("ARK_LVUP_SCROLL_CHANGE_BUTTON()", 0.3);
	else
		ARK_LVUP_SCROLL_RESULT_UPDATE(frame, 0);
	end
	
	ARK_LVUP_SCROLL_LOCK_ITEM("None");
	
	local slot = GET_CHILD(frame, "slot");
	local icon = slot:GetIcon();
	icon:SetTooltipType("None");
	icon:SetTooltipArg("", 0, "");
	ReserveScript("ARK_LVUP_SCROLL_CHANGE_TOOLTIP()", 0.3);
end

function ARK_LVUP_SCROLL_CHANGE_TOOLTIP()
	local frame = ui.GetFrame("ark_lvup_scroll");
	local slot = GET_CHILD(frame, "slot");
	local icon = slot:GetIcon();
	local invItem = GET_SLOT_ITEM(slot);
	if invItem ~= nil then
		local obj = GetIES(invItem:GetObject());
		icon:SetTooltipType("wholeitem");
		icon:SetTooltipArg("", 0, invItem:GetIESID());
	end
end

function ARK_LVUP_SCROLL_CHANGE_BUTTON()
	local frame = ui.GetFrame("ark_lvup_scroll");
	local button_transcend = frame:GetChild("button_transcend");	
	local button_close = frame:GetChild("button_close");	
	button_transcend:ShowWindow(0);	
	button_close:ShowWindow(1);	
end

function ARK_LVUP_SCROLL_RESULT_UPDATE(frame, isSuccess)
	local slot = GET_CHILD(frame, "slot");
	
	local timesecond = 0;
	if isSuccess == 1 then
		imcSound.PlaySoundEvent(frame:GetUserConfig("TRANS_SUCCESS_SOUND"));
		slot:StopActiveUIEffect();
		slot:PlayActiveUIEffect();
		timesecond = 2;
	else
		imcSound.PlaySoundEvent(frame:GetUserConfig("TRANS_FAIL_SOUND"));
		local slot_temp = GET_CHILD(frame, "slot_temp");
		slot_temp:ShowWindow(1);
		slot_temp:StopActiveUIEffect();
		slot_temp:PlayActiveUIEffect();
		timesecond = 1;
	end
	
	local invItem = GET_SLOT_ITEM(slot);
	if invItem == nil then
		slot:ClearIcon();
		return;
	end
	
	local obj = GetIES(invItem:GetObject());
	
	local resultTxt = "";	
	local upfont = "{@st43_green}{s18}";
	local operTxt = " + ";	
	
	local text_color1 = 0xFF1DDB16;
	local text_color2 = 0xFF22741C;
	if isSuccess == 0 then
		upfont = "{@st43_red}{s18}";
		text_color1 = 0xFFFF0000;
		text_color2 = 0xFFFFBB00;
	end;
	
	frame:StopUpdateScript("TIMEWAIT_STOP_ARK_LVUP_SCROLL");
	frame:RunUpdateScript("TIMEWAIT_STOP_ARK_LVUP_SCROLL", timesecond);
end

function TIMEWAIT_STOP_ARK_LVUP_SCROLL()
	local frame = ui.GetFrame("ark_lvup_scroll");
	local slot_temp = GET_CHILD(frame, "slot_temp");
	slot_temp:ShowWindow(0);
	slot_temp:StopActiveUIEffect();

	local popupFrame = ui.GetFrame("ark_lvup_scroll_result");
	local gbox = popupFrame:GetChild("gbox");
	popupFrame:ShowWindow(1);	
	popupFrame:SetDuration(6.0);
	
	frame:StopUpdateScript("TIMEWAIT_STOP_ARK_LVUP_SCROLL");
	return 1;
end

function ARK_LVUP_SCROLL_BG_ANIM_TICK(ctrl, str, tick)
	if tick == 10 then
		local frame = ctrl:GetTopParentFrame();
		local animpic_slot = GET_CHILD_RECURSIVELY(frame, "animpic_slot");
		animpic_slot:ForcePlayAnimation();	
		ReserveScript("ARK_LVUP_SCROLL_EFFECT()", 0.3);
	end
end

function ARK_LVUP_SCROLL_EFFECT()
	local frame = ui.GetFrame("ark_lvup_scroll");
	ARK_LVUP_SCROLL_RESULT_UPDATE(frame, 1);	
end

function ARK_LVUP_SCROLL_EXEC()
	local frame = ui.GetFrame("ark_lvup_scroll");		
	imcSound.PlaySoundEvent(frame:GetUserConfig("TRANS_EVENT_EXEC"));
	frame:SetUserValue("EnableTranscendButton", 0);
	
	local slot = GET_CHILD(frame, "slot");
	local targetItem = GET_SLOT_ITEM(slot);
	local scrollGuid = frame:GetUserValue("ScrollGuid")
	
	session.ResetItemList();		
	session.AddItemID(targetItem:GetIESID());
	session.AddItemID(scrollGuid);	
	local resultlist = session.GetItemIDList();
	item.DialogTransaction("CABINET_ARK_LVUP_BY_SCROLL", resultlist);
	
	imcSound.PlaySoundEvent(frame:GetUserConfig("TRANS_CAST"));
end

function ARK_LVUP_SCROLL_CANCEL()
	ARK_LVUP_SCROLL_LOCK_ITEM("None");
end

function ARK_LVUP_SCROLL_CLOSE()
	local frame = ui.GetFrame("ark_lvup_scroll");
	frame:SetUserValue("ScrollType", "None")
	frame:SetUserValue("ScrollGuid", "None")	
	frame:OpenFrame(0);
	
	ui.RemoveGuideMsg("DropItemPlz");
	ui.SetEscapeScp("");

	ARK_LVUP_SCROLL_LOCK_ITEM("None")
	ARK_LVUP_SCROLL_UI_RESET();
	ARK_LVUP_SCROLL_CANCEL();
	
	local invframe = ui.GetFrame("inventory");
	SET_SLOT_APPLY_FUNC(invframe, "None");
	INVENTORY_SET_CUSTOM_RBTNDOWN("None");

	local gbox = invframe:GetChild("inventoryGbox");
	local tab = gbox:GetChild("inventype_Tab");	
	tolua.cast(tab, "ui::CTabControl");
	tab:SelectTab(0);
end

function ARK_LVUP_SCROLL_LOCK_ITEM(guid)
	local lockItemGuid = nil;
	local frame = ui.GetFrame("ark_lvup_scroll");
	if frame ~= nil and guid == "None" then
		local slot = GET_CHILD_RECURSIVELY(frame, "slot");
		if slot ~= nil then
			local icon = slot:GetIcon();
			if icon ~= nil then
				tolua.cast(icon, "ui::CIcon");
				lockItemGuid = icon:GetInfo():GetIESID();
			end
		end
	end

	if lockItemGuid == nil then
		lockItemGuid = guid;
	end

	if lockItemGuid == "None" then
		return;
	end

	local invframe = ui.GetFrame("inventory");
	if invframe == nil then return; end
	invframe:SetUserValue("ITEM_GUID_IN_ARK_LVUP_SCROLL", guid);
	INVENTORY_ON_MSG(invframe, "UPDATE_ITEM_ARK_LVUP_SCROLL", lockItemGuid);
end

function ARK_LVUP_SCROLL_UI_INIT()
	local frame = ui.GetFrame("ark_lvup_scroll");
	local scrollGuid = frame:GetUserValue("ScrollGuid")	
	local scrollInvItem = session.GetInvItemByGuid(scrollGuid);
	if scrollInvItem == nil then
		return
	end
	local scrollObj = GetIES(scrollInvItem:GetObject());

	local scrollType = frame:GetUserValue("ScrollType");

	local convert_list = GET_CHILD_RECURSIVELY(frame, "convert_list");
	convert_list:ShowWindow(0)
	
	local title_msg = "None"
	local desc_msg = "None"
	local btn_msg = "None"
	local btn_scp = "None"
	local text_title = GET_CHILD(frame, "text_title");
	if scrollType == "ArkLVUPScroll" then
		title_msg = "ark_lvup_scroll"
		desc_msg = ScpArgMsg("ArkLvUpTo{Level}", "Level", TryGetProp(scrollObj, 'NumberArg1', 0))
		btn_msg = "Reinforce_2"
		btn_scp = "ARK_LVUP_SCROLL_EXEC_ASK_AGAIN"
		text_title:SetTextByKey("value", ClMsg(title_msg));
	elseif scrollType == "ArkConvertScroll" then
		title_msg = "ark_convert_scroll"
		desc_msg = ClMsg("ArkConvertTo")
		btn_msg = "convert"
		btn_scp = "ARK_CONVERT_SCROLL_EXEC_ASK_AGAIN"
		text_title:SetTextByKey("value", ClMsg(title_msg));
	else
		title_msg = dic.getTranslatedStr(TryGetProp(scrollObj, 'Name', 'None'))
		text_title:SetTextByKey("value", title_msg);
		desc_msg = ClMsg("AetherConvertTo")
		btn_msg = "convert"
		btn_scp = "AETHER_CONVERT_SCROLL_EXEC_ASK_AGAIN"
	end
		
	local button_close = GET_CHILD(frame, "button_close");	
	button_close:ShowWindow(1);
	
	local transcend_gb = GET_CHILD_RECURSIVELY(frame, "transcend_gb");
	transcend_gb:ShowWindow(1);
	
	local text_desc = GET_CHILD_RECURSIVELY(frame, "text_desc");
	text_desc:SetTextByKey("value", desc_msg)
	text_desc:ShowWindow(1);	

	local main_gb = GET_CHILD_RECURSIVELY(frame, "main_gb");
	main_gb:ShowWindow(0);

	local button_transcend = GET_CHILD(frame, "button_transcend");
	button_transcend:SetTextByKey("value", ClMsg(btn_msg));
	button_transcend:SetEventScript(ui.LBUTTONUP, btn_scp);
end

function ARK_LVUP_SCROLL_UI_RESET()
	local frame = ui.GetFrame("ark_lvup_scroll");

	local slot = GET_CHILD(frame, "slot");
	slot:ClearIcon();

	local text_name = GET_CHILD(frame, "text_name");
	local text_itemtranscend = frame:GetChild("text_itemtranscend");	

	local text_title = GET_CHILD(frame, "text_title");
	text_title:SetTextByKey("value", "");
	
	text_name:ShowWindow(0);	
end

function ARK_LVUP_SCROLL_INV_RBTN(itemObj, slot)	
	local icon = slot:GetIcon();
	local iconInfo = icon:GetInfo();
	local invItem = GET_PC_ITEM_BY_GUID(iconInfo:GetIESID());

	local invframe = ui.GetFrame("inventory");
	ARK_LVUP_SCROLL_SET_TARGET_ITEM(invframe, invItem)
end

function ARK_LVUP_SCROLL_ITEM_DROP(parent, ctrl)
	local liftIcon = ui.GetLiftIcon();
	local iconInfo = liftIcon:GetInfo();
	local invItem = GET_PC_ITEM_BY_GUID(iconInfo:GetIESID());	
	if nil == invItem then
		return;
	end

	local invframe = ui.GetFrame("inventory");
	ARK_LVUP_SCROLL_SET_TARGET_ITEM(invframe, invItem)
end

function ARK_LVUP_SCROLL_SET_TARGET_ITEM(invframe, invItem)
	local frame = ui.GetFrame("ark_lvup_scroll");

	local scrollType = frame:GetUserValue("ScrollType");

	local button_transcend = GET_CHILD(frame, "button_transcend");	
	local button_close = GET_CHILD(frame, "button_close");
	button_close:ShowWindow(0);	
	button_transcend:ShowWindow(1);	
	
	local slot_temp = GET_CHILD(frame, "slot_temp");
	slot_temp:StopActiveUIEffect();
	slot_temp:ShowWindow(0);	

	local scrollGuid = frame:GetUserValue("ScrollGuid")
	local scrollInvItem = session.GetInvItemByGuid(scrollGuid);
	if scrollInvItem == nil then
		return;
	end

	if true == invItem.isLockState or true == scrollInvItem.isLockState then
		ui.SysMsg(ClMsg("MaterialItemIsLock"));
		return;
	end

	local invframe = ui.GetFrame("inventory");
	if true == IS_TEMP_LOCK(invframe, invItem) or true == IS_TEMP_LOCK(invframe, scrollInvItem) then
		ui.SysMsg(ClMsg("MaterialItemIsLock"));
		return;
	end

	local scrollObj = GetIES(scrollInvItem:GetObject());
	local itemObj = GetIES(invItem:GetObject());

	local ret, msg = IS_VALID_ARK_LVUP_BY_SCROLL(itemObj, scrollObj)	
	if scrollType == "ArkConvertScroll" then
		ret, msg = shared_item_ark.is_able_to_convert(itemObj, scrollObj)
	elseif scrollType == 'AetherConvertScroll' then
		ret, msg = IS_ABLE_TO_CONVERT_AETHER_GEM(itemObj, scrollObj)
	end
	if ret == false then				
		ui.SysMsg(ClMsg(msg));
		return;
	end

	local slot = GET_CHILD(frame, "slot");
	
	local text_name = GET_CHILD_RECURSIVELY(frame, "text_name")
	text_name:SetTextByKey("value", "");
	text_name:SetTextByKey("value", itemObj.Name)
	text_name:ShowWindow(1);

	local lev = TryGetProp(itemObj, 'ArkLevel', 1)
	
	ARK_LVUP_SCROLL_CANCEL();
	ARK_LVUP_SCROLL_TARGET_ITEM_SLOT(slot, invItem, scrollObj.ClassID);
	ARK_LVUP_SCROLL_LOCK_ITEM(invItem:GetIESID())

	if scrollType == "ArkConvertScroll" then
		local convert_list = GET_CHILD_RECURSIVELY(frame, "convert_list");
		_MAKE_CONVERTABLE_ARK_LIST(frame, convert_list);
		convert_list:ShowWindow(1)
	elseif scrollType == "AetherConvertScroll" then
		local convert_list = GET_CHILD_RECURSIVELY(frame, "convert_list");
		_MAKE_CONVERTABLE_AETHER_LIST(frame, convert_list, scrollObj);
		convert_list:ShowWindow(1)
	end

	frame:SetUserValue("EnableTranscendButton", 1);	
	frame:OpenFrame(1);
end

function ARK_LVUP_SCROLL_CHECK_TARGET_ITEM(slot)-- _CHECK_MORU_TARGET_ITEM
	local frame = ui.GetFrame("ark_lvup_scroll");	
	local scrollType = frame:GetUserValue("ScrollType")
	local item = GET_SLOT_ITEM(slot);
	if item ~= nil then
		local obj = GetIES(item:GetObject());
		local scrollGuid = frame:GetUserValue("ScrollGuid")
    	local scrollInvItem = session.GetInvItemByGuid(scrollGuid);
    	if scrollInvItem == nil then
    		return;
    	end
		local scrollObj = GetIES(scrollInvItem:GetObject());		
		local ret, msg = IS_VALID_ARK_LVUP_BY_SCROLL(obj, scrollObj)		
		if scrollType == "ArkConvertScroll" then
			ret, msg = shared_item_ark.is_able_to_convert(obj, scrollObj)
		end
		if ret == true then
			slot:GetIcon():SetGrayStyle(0);
		else			
			slot:GetIcon():SetGrayStyle(1);
		end
	end
end

function AETHER_LVUP_SCROLL_CHECK_TARGET_ITEM(slot)
	local frame = ui.GetFrame("ark_lvup_scroll");	
	local scrollType = frame:GetUserValue("ScrollType")
	local item = GET_SLOT_ITEM(slot);
	if item ~= nil then
		local obj = GetIES(item:GetObject());
		local scrollGuid = frame:GetUserValue("ScrollGuid")
    	local scrollInvItem = session.GetInvItemByGuid(scrollGuid);
    	if scrollInvItem == nil then
    		return;
    	end
		local scrollObj = GetIES(scrollInvItem:GetObject());
		local ret, msg = IS_ABLE_TO_CONVERT_AETHER_GEM(obj, scrollObj)
		if ret == true then
			slot:GetIcon():SetGrayStyle(0);
		else			
			slot:GetIcon():SetGrayStyle(1);
		end
	end
end

function ARK_LVUP_SCROLL_SELECT_TARGET_ITEM(scrollItem)	
	if session.colonywar.GetIsColonyWarMap() == true then
        ui.SysMsg(ClMsg('CannotUseInPVPZone'));
        return;
    end

	if IsPVPServer() == 1 then	
		ui.SysMsg(ScpArgMsg('CantUseThisInIntegrateServer'));
		return;
	end

	local rankresetFrame = ui.GetFrame("rankreset");
	if 1 == rankresetFrame:IsVisible() then
		ui.SysMsg(ScpArgMsg('CannotDoAction'));
		return;
	end
	
	local frame = ui.GetFrame("ark_lvup_scroll");
	local scrollObj = GetIES(scrollItem:GetObject());		
	
	local scrollType = TryGetProp(scrollObj, 'StringArg', 'None');
	if scrollType == 'None' then
		return
	end
	local scrollGuid = GetIESGuid(scrollObj);
	frame:SetUserValue("ScrollType", scrollType)
	frame:SetUserValue("ScrollGuid", scrollGuid)
	
	if scrollObj.ItemLifeTimeOver > 0 then
		ui.SysMsg(ScpArgMsg('LessThanItemLifeTime'));
		return;
	end

	ARK_LVUP_SCROLL_CANCEL();
	ARK_LVUP_SCROLL_UI_RESET();
	ARK_LVUP_SCROLL_UI_INIT();
	frame:ShowWindow(1);
	
	ui.GuideMsg("DropItemPlz");

	local invframe = ui.GetFrame("inventory");
	local gbox = invframe:GetChild("inventoryGbox");
	ui.SetEscapeScp("ARK_LVUP_SCROLL_CANCEL()");
		
	local tab = gbox:GetChild("inventype_Tab");	
	tolua.cast(tab, "ui::CTabControl");
	
	
	if scrollType ~= 'AetherConvertScroll' then
		tab:SelectTab(1);
		SET_SLOT_APPLY_FUNC(invframe, "ARK_LVUP_SCROLL_CHECK_TARGET_ITEM", nil, "Equip");

	else		
		tab:SelectTab(6);
		SET_SLOT_APPLY_FUNC(invframe, "AETHER_LVUP_SCROLL_CHECK_TARGET_ITEM", nil, 'Gem');
	end
	
	INVENTORY_SET_CUSTOM_RBTNDOWN("ARK_LVUP_SCROLL_INV_RBTN");
	
end

function _MAKE_CONVERTABLE_ARK_LIST(frame, drop_list)
	local slot = GET_CHILD_RECURSIVELY(frame, 'slot')
	local ark_item = GET_SLOT_ITEM(slot)
	if ark_item == nil then return end

	local ark_obj = GetIES(ark_item:GetObject())
	
	local cabinet_cls = GetClass('cabinet_ark', TryGetProp(ark_obj, 'ClassName', 'None'))
	if cabinet_cls == nil then return end
	
	local cabinet_ark_list, cnt = GetClassList('cabinet_ark')
	if cabinet_ark_list == nil or cnt <= 0 then return end

	drop_list:ClearItems()
	for i = 0, cnt - 1 do
		local cabinet_ark_cls = GetClassByIndexFromList(cabinet_ark_list, i)
		if cabinet_ark_list ~= nil then
			local clsID = TryGetProp(cabinet_ark_cls, 'ClassID', 0)
			if clsID ~= TryGetProp(cabinet_cls, 'ClassID', 0) then
				local name = dic.getTranslatedStr(TryGetProp(cabinet_ark_cls, 'Name', 'None'))
				drop_list:AddItem(clsID, name)
			end
		end
    end

    drop_list:SelectItemByKey("")
end

function ARK_CONVERT_SCROLL_EXEC_ASK_AGAIN(frame, btn)
	local scrollType = frame:GetUserValue("ScrollType")
	if scrollType ~= "ArkConvertScroll" then return end

	local clickable = frame:GetUserValue("EnableTranscendButton")
	if tonumber(clickable) ~= 1 then
		return;
	end

	local slot = GET_CHILD(frame, "slot");
	local invItem = GET_SLOT_ITEM(slot);
	if invItem == nil then
		ui.MsgBox(ScpArgMsg("DropItemPlz"));
		imcSound.PlaySoundEvent(frame:GetUserConfig("TRANS_BTN_OVER_SOUND"));
		return;
	end

	local itemObj = GetIES(invItem:GetObject());
	
	local scrollGuid = frame:GetUserValue("ScrollGuid")
	local scrollInvItem = session.GetInvItemByGuid(scrollGuid);
	if scrollInvItem == nil then
		ui.SysMsg(ScpArgMsg('TranscendScrollNotExist'));
		return;
	end

	if true == invItem.isLockState or true == scrollInvItem.isLockState then
		ui.SysMsg(ClMsg("MaterialItemIsLock"));
		return;
	end

	local convert_list = GET_CHILD_RECURSIVELY(frame, 'convert_list');
	local convert_cls = GetClassByType('cabinet_ark', convert_list:GetSelItemKey())
	if convert_cls == nil then return end

	local cur_name = dic.getTranslatedStr(TryGetProp(itemObj, 'Name', 'None'))
	local convert_name = dic.getTranslatedStr(TryGetProp(convert_cls, 'Name', 'None'))
	local clmsg = ScpArgMsg("ArkConvertScrollWarning{Before}{After}", "Before", cur_name, "After", convert_name)
	imcSound.PlaySoundEvent(frame:GetUserConfig("TRANS_BTN_OK_SOUND"));
	ui.MsgBox_NonNested(clmsg, frame:GetName(), "ARK_CONVERT_SCROLL_EXEC", "None");
end

function ARK_CONVERT_SCROLL_EXEC()
	local frame = ui.GetFrame("ark_lvup_scroll");
	imcSound.PlaySoundEvent(frame:GetUserConfig("TRANS_EVENT_EXEC"));
	frame:SetUserValue("EnableTranscendButton", 0);
	
	local slot = GET_CHILD(frame, "slot");
	local targetItem = GET_SLOT_ITEM(slot);
	local scrollGuid = frame:GetUserValue("ScrollGuid");

	local convert_list = GET_CHILD_RECURSIVELY(frame, "convert_list");
	local selected = convert_list:GetSelItemKey();
	
	session.ResetItemList();

	session.AddItemID(targetItem:GetIESID());
	session.AddItemID(scrollGuid);
	
	local arglist = NewStringList();
	arglist:Add(selected);
	
	local resultlist = session.GetItemIDList();

	item.DialogTransaction("CONVERT_ARK", resultlist, "", arglist);
	
	imcSound.PlaySoundEvent(frame:GetUserConfig("TRANS_CAST"));
end

function ARK_CONVERT_SCROLL_RESULT(frame, msg, arg_str, arg_num)
	local frame = ui.GetFrame("ark_lvup_scroll");
	if arg_num == 1 then
		local animpic_bg = GET_CHILD_RECURSIVELY(frame, "animpic_bg");
		animpic_bg:ShowWindow(1);
		animpic_bg:ForcePlayAnimation();
		ReserveScript("ARK_LVUP_SCROLL_CHANGE_BUTTON()", 0.3);
	else
		ARK_LVUP_SCROLL_RESULT_UPDATE(frame, 0);
	end
	
	ARK_LVUP_SCROLL_LOCK_ITEM("None");
	
	local slot = GET_CHILD(frame, "slot");
	local icon = slot:GetIcon();
	icon:SetTooltipType("None");
	icon:SetTooltipArg("", 0, "");
	ReserveScript("ARK_CONVERT_SCROLL_CHANGE_TOOLTIP()", 0.3);
end

function ARK_CONVERT_SCROLL_CHANGE_TOOLTIP()
	local frame = ui.GetFrame("ark_lvup_scroll");
	local slot = GET_CHILD(frame, "slot");
	local icon = slot:GetIcon();
	local invItem = GET_SLOT_ITEM(slot);
	if invItem ~= nil then
		local obj = GetIES(invItem:GetObject());
		local img = GET_ITEM_ICON_IMAGE(obj);
		SET_SLOT_IMG(slot, img);
		icon:SetTooltipType("wholeitem");
		icon:SetTooltipArg("", 0, invItem:GetIESID());
	end
end




function _MAKE_CONVERTABLE_AETHER_LIST(frame, drop_list, scrollObj)
	local lv = TryGetProp(scrollObj, 'NumberArg1', 0)
	local slot = GET_CHILD_RECURSIVELY(frame, 'slot')
	local aether_item = GET_SLOT_ITEM(slot)
	if aether_item == nil then return end

	local aether_obj = GetIES(aether_item:GetObject())
	
	local list = {'Gem_High_STR_', 'Gem_High_INT_', 'Gem_High_DEX_', 'Gem_High_MNA_', 'Gem_High_CON_'}

	drop_list:ClearItems()
	for i = 1, #list do
		local gem_name = list[i] .. lv
		if TryGetProp(aether_obj, 'ClassName', 'None') ~= gem_name then
			local cls = GetClass('Item', gem_name)
			if cls ~= nil then
				local clsID = TryGetProp(cls, 'ClassID', 0)
				local name = dic.getTranslatedStr(TryGetProp(cls, 'Name', 'None'))
				drop_list:AddItem(clsID, name)
			end
		end
    end

    drop_list:SelectItemByKey("")
end


function AETHER_CONVERT_SCROLL_EXEC_ASK_AGAIN(frame, btn)	
	local scrollType = frame:GetUserValue("ScrollType")
	if scrollType ~= "AetherConvertScroll" then return end

	local clickable = frame:GetUserValue("EnableTranscendButton")
	if tonumber(clickable) ~= 1 then
		return;
	end

	local slot = GET_CHILD(frame, "slot");
	local invItem = GET_SLOT_ITEM(slot);
	if invItem == nil then
		ui.MsgBox(ScpArgMsg("DropItemPlz"));
		imcSound.PlaySoundEvent(frame:GetUserConfig("TRANS_BTN_OVER_SOUND"));
		return;
	end

	local itemObj = GetIES(invItem:GetObject());
	
	local scrollGuid = frame:GetUserValue("ScrollGuid")
	local scrollInvItem = session.GetInvItemByGuid(scrollGuid);
	if scrollInvItem == nil then
		ui.SysMsg(ScpArgMsg('TranscendScrollNotExist'));
		return;
	end

	if true == invItem.isLockState or true == scrollInvItem.isLockState then
		ui.SysMsg(ClMsg("MaterialItemIsLock"));
		return;
	end

	local convert_list = GET_CHILD_RECURSIVELY(frame, 'convert_list');	
	local convert_cls = GetClassByType('Item', convert_list:GetSelItemKey())
	if convert_cls == nil then return end

	local cur_name = dic.getTranslatedStr(TryGetProp(itemObj, 'Name', 'None'))
	local convert_name = dic.getTranslatedStr(TryGetProp(convert_cls, 'Name', 'None'))
	local clmsg = ScpArgMsg("ArkConvertScrollWarning{Before}{After}", "Before", cur_name, "After", convert_name)
	imcSound.PlaySoundEvent(frame:GetUserConfig("TRANS_BTN_OK_SOUND"));
	ui.MsgBox_NonNested(clmsg, frame:GetName(), "AETHER_CONVERT_SCROLL_EXEC", "None");
end

function AETHER_CONVERT_SCROLL_EXEC()
	local frame = ui.GetFrame("ark_lvup_scroll");
	imcSound.PlaySoundEvent(frame:GetUserConfig("TRANS_EVENT_EXEC"));
	frame:SetUserValue("EnableTranscendButton", 0);
	
	local slot = GET_CHILD(frame, "slot");
	local targetItem = GET_SLOT_ITEM(slot);
	local scrollGuid = frame:GetUserValue("ScrollGuid");

	local convert_list = GET_CHILD_RECURSIVELY(frame, "convert_list");
	local selected = convert_list:GetSelItemKey();
	
	session.ResetItemList();

	session.AddItemID(targetItem:GetIESID());
	session.AddItemID(scrollGuid);
	
	local arglist = NewStringList();
	arglist:Add(selected);
	
	local resultlist = session.GetItemIDList();

	item.DialogTransaction("CONVERT_AETHER", resultlist, "", arglist);
	
	imcSound.PlaySoundEvent(frame:GetUserConfig("TRANS_CAST"));
end

