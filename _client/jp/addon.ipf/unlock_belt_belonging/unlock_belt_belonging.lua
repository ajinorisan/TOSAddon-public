function UNLOCK_BELT_BELONGING_SCROLL_ON_INIT(addon, frame)
end

function UNLOCK_BELT_BELONGING_SCROLL_TARGET_ITEM_SLOT(slot, invItem, scrollClsID)
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

	icon:SetTooltipType('wholeitem');
	icon:SetTooltipArg("", TryGetProp(itemCls, "ClassID", 0), invItem:GetIESID());
	icon:SetTooltipOverlap(1)
end

function UNLOCK_BELT_BELONGING_SCROLL_EXEC_ASK_AGAIN(frame, btn)
	local scrollType = frame:GetUserValue("ScrollType")
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
		return;
	end
	local scrollObj = GetIES(scrollInvItem:GetObject());
	local clmsg = ScpArgMsg("ReallyUnlockBelonging")    
	if TryGetProp(scrollObj, 'StringArg', 'None') == 'unlock_belt_team_belonging' then
		clmsg = ScpArgMsg('MakeTeamBelonging')
	end

	imcSound.PlaySoundEvent(frame:GetUserConfig("TRANS_BTN_OK_SOUND"));
	ui.MsgBox_NonNested(clmsg, frame:GetName(), "UNLOCK_BELT_BELONGING_SCROLL_EXEC", "None");
end

function UNLOCK_BELT_BELONGING_SCROLL_RESULT(isSuccess)
	local frame = ui.GetFrame("unlock_belt_belonging");
	if isSuccess == 1 then
		local animpic_bg = GET_CHILD_RECURSIVELY(frame, "animpic_bg");
		animpic_bg:ShowWindow(1);
		animpic_bg:ForcePlayAnimation();
		ReserveScript("UNLOCK_BELT_BELONGING_SCROLL_CHANGE_BUTTON()", 0.3);
	else
		UNLOCK_BELT_BELONGING_SCROLL_RESULT_UPDATE(frame, 0);
	end
	
	UNLOCK_BELT_BELONGING_SCROLL_LOCK_ITEM("None");
	
	local slot = GET_CHILD(frame, "slot");
	local icon = slot:GetIcon();
	icon:SetTooltipType("None");
	icon:SetTooltipArg("", 0, "");
	ReserveScript("UNLOCK_BELT_BELONGING_SCROLL_CHANGE_TOOLTIP()", 0.3);
end

function UNLOCK_BELT_BELONGING_SCROLL_CHANGE_TOOLTIP()
	local frame = ui.GetFrame("unlock_belt_belonging");
	local slot = GET_CHILD(frame, "slot");
	local icon = slot:GetIcon();
	local invItem = GET_SLOT_ITEM(slot);
	if invItem ~= nil then
		local obj = GetIES(invItem:GetObject());
		icon:SetTooltipType("wholeitem");
		icon:SetTooltipArg("", 0, invItem:GetIESID());
	end
end

function UNLOCK_BELT_BELONGING_SCROLL_CHANGE_BUTTON()
	local frame = ui.GetFrame("unlock_belt_belonging");
	local button_transcend = frame:GetChild("button_transcend");	
	local button_close = frame:GetChild("button_close");	
	button_transcend:ShowWindow(0);	
	button_close:ShowWindow(1);	
end

function UNLOCK_BELT_BELONGING_SCROLL_RESULT_UPDATE(frame, isSuccess)
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
	
	frame:StopUpdateScript("TIMEWAIT_STOP_unlock_belt_belonging");
	frame:RunUpdateScript("TIMEWAIT_STOP_unlock_belt_belonging", timesecond);
end

function TIMEWAIT_STOP_unlock_belt_belonging()
	local frame = ui.GetFrame("unlock_belt_belonging");
	local slot_temp = GET_CHILD(frame, "slot_temp");
	slot_temp:ShowWindow(0);
	slot_temp:StopActiveUIEffect();

	local popupFrame = ui.GetFrame("ark_lvup_scroll_result");
	local gbox = popupFrame:GetChild("gbox");
	popupFrame:ShowWindow(1);	
	popupFrame:SetDuration(6.0);
	
	frame:StopUpdateScript("TIMEWAIT_STOP_unlock_belt_belonging");
	return 1;
end

function UNLOCK_BELT_BELONGING_SCROLL_BG_ANIM_TICK(ctrl, str, tick)
	if tick == 10 then
		local frame = ctrl:GetTopParentFrame();
		local animpic_slot = GET_CHILD_RECURSIVELY(frame, "animpic_slot");
		animpic_slot:ForcePlayAnimation();	
		ReserveScript("UNLOCK_BELT_BELONGING_SCROLL_EFFECT()", 0.3);
	end
end

function UNLOCK_BELT_BELONGING_SCROLL_EFFECT()
	local frame = ui.GetFrame("unlock_belt_belonging");
	UNLOCK_BELT_BELONGING_SCROLL_RESULT_UPDATE(frame, 1);	
end

function UNLOCK_BELT_BELONGING_SCROLL_EXEC()
	local frame = ui.GetFrame("unlock_belt_belonging");		
	imcSound.PlaySoundEvent(frame:GetUserConfig("TRANS_EVENT_EXEC"));
	frame:SetUserValue("EnableTranscendButton", 0);
	
	local slot = GET_CHILD(frame, "slot");
	local targetItem = GET_SLOT_ITEM(slot);
	local scrollGuid = frame:GetUserValue("ScrollGuid")
	
	session.ResetItemList();		
	session.AddItemID(targetItem:GetIESID());
	session.AddItemID(scrollGuid);	
	local resultlist = session.GetItemIDList();
	item.DialogTransaction("ITEM_UNLOCK_BELT_BELONGING_SCROLL", resultlist);
	
	imcSound.PlaySoundEvent(frame:GetUserConfig("TRANS_CAST"));
end

function UNLOCK_BELT_BELONGING_SCROLL_CANCEL()
	UNLOCK_BELT_BELONGING_SCROLL_LOCK_ITEM("None");
end

function UNLOCK_BELT_BELONGING_SCROLL_CLOSE()
	local frame = ui.GetFrame("unlock_belt_belonging");
	frame:SetUserValue("ScrollType", "None")
	frame:SetUserValue("ScrollGuid", "None")	
	frame:OpenFrame(0);
	
	ui.RemoveGuideMsg("DropItemPlz");
	ui.SetEscapeScp("");

	UNLOCK_BELT_BELONGING_SCROLL_LOCK_ITEM("None")
	UNLOCK_BELT_BELONGING_SCROLL_UI_RESET();
	UNLOCK_BELT_BELONGING_SCROLL_CANCEL();
	
	local invframe = ui.GetFrame("inventory");
	SET_SLOT_APPLY_FUNC(invframe, "None");
	INVENTORY_SET_CUSTOM_RBTNDOWN("None");
end

function UNLOCK_BELT_BELONGING_SCROLL_LOCK_ITEM(guid)
	local lockItemGuid = nil;
	local frame = ui.GetFrame("unlock_belt_belonging");
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
	invframe:SetUserValue("ITEM_GUID_IN_unlock_belt_belonging", guid);
	INVENTORY_ON_MSG(invframe, "UPDATE_ITEM_unlock_belt_belonging", lockItemGuid);
end

function UNLOCK_BELT_BELONGING_SCROLL_UI_INIT()	
	local frame = ui.GetFrame("unlock_belt_belonging");
	local scrollGuid = frame:GetUserValue("ScrollGuid")	
	local scrollInvItem = session.GetInvItemByGuid(scrollGuid);
	if scrollInvItem == nil then
		return
	end
	local scrollObj = GetIES(scrollInvItem:GetObject());

	local button_close = GET_CHILD(frame, "button_close");	
	button_close:ShowWindow(1);
	
	local transcend_gb = GET_CHILD_RECURSIVELY(frame, "transcend_gb");
	transcend_gb:ShowWindow(1);
	
	local text_desc = GET_CHILD_RECURSIVELY(frame, "text_desc");

	local text_title = GET_CHILD_RECURSIVELY(frame, "text_title");		

	text_title:SetTextByKey("value", scrollObj.Name)
	if TryGetProp(scrollObj, 'StringArg', 'None') == 'unlock_belt_team_belonging' then
		text_desc:SetTextByKey("value", ClMsg('TeamBelongingWhenUsage'))		
	else
		text_desc:SetTextByKey('value', ClMsg('UnlockBelongingWhenUsage'))
	end

	text_desc:ShowWindow(1);	

	local main_gb = GET_CHILD_RECURSIVELY(frame, "main_gb");
	main_gb:ShowWindow(0);

	local button_transcend = GET_CHILD(frame, "button_transcend");
	button_transcend:SetTextByKey("value", ClMsg("UnlockBelonging"));
end

function UNLOCK_BELT_BELONGING_SCROLL_UI_RESET()
	local frame = ui.GetFrame("unlock_belt_belonging");

	local slot = GET_CHILD(frame, "slot");
	slot:ClearIcon();

	local text_name = GET_CHILD(frame, "text_name");
	local text_itemtranscend = frame:GetChild("text_itemtranscend");	
		
	text_name:ShowWindow(0);	
end

function UNLOCK_BELT_BELONGING_SCROLL_INV_RBTN(itemObj, slot)	
	local icon = slot:GetIcon();
	local iconInfo = icon:GetInfo();
	local invItem = GET_PC_ITEM_BY_GUID(iconInfo:GetIESID());

	local invframe = ui.GetFrame("inventory");
	UNLOCK_BELT_BELONGING_SCROLL_SET_TARGET_ITEM(invframe, invItem)
end

function UNLOCK_BELT_BELONGING_SCROLL_ITEM_DROP(parent, ctrl)
	local liftIcon = ui.GetLiftIcon();
	local iconInfo = liftIcon:GetInfo();
	local invItem = GET_PC_ITEM_BY_GUID(iconInfo:GetIESID());	
	if nil == invItem then
		return;
	end

	local invframe = ui.GetFrame("inventory");
	UNLOCK_BELT_BELONGING_SCROLL_SET_TARGET_ITEM(invframe, invItem)
end

function UNLOCK_BELT_BELONGING_SCROLL_SET_TARGET_ITEM(invframe, invItem)
	local frame = ui.GetFrame("unlock_belt_belonging");

	local button_transcend = GET_CHILD(frame, "button_transcend");	
	local button_close = GET_CHILD(frame, "button_close");
	button_close:ShowWindow(0);	
	
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

	local ret, msg = shared_item_belt.is_valid_unlock_item(scrollObj, itemObj)	
	if ret == false then
		ui.SysMsg(ClMsg(msg))
		return
	end

	local text_name = GET_CHILD_RECURSIVELY(frame, "text_name")
	local slot = GET_CHILD(frame, "slot");
	
	text_name:SetTextByKey("value", "");
	text_name:SetTextByKey("value", itemObj.Name)
	text_name:ShowWindow(1);

	if TryGetProp(scrollObj, 'StringArg', 'None') ~= 'unlock_belt_team_belonging' then
		button_transcend:SetTextByKey("value", ClMsg("UnlockBelonging"));
	else
		button_transcend:SetTextByKey("value", ClMsg("TeamBelonging"));
	end

	button_transcend:ShowWindow(1);	

	UNLOCK_BELT_BELONGING_SCROLL_CANCEL();
	UNLOCK_BELT_BELONGING_SCROLL_TARGET_ITEM_SLOT(slot, invItem, scrollObj.ClassID);
	UNLOCK_BELT_BELONGING_SCROLL_LOCK_ITEM(invItem:GetIESID())

	frame:SetUserValue("EnableTranscendButton", 1);	
	frame:OpenFrame(1);
end

function UNLOCK_BELT_BELONGING_SCROLL_CHECK_TARGET_ITEM(slot)-- _CHECK_MORU_TARGET_ITEM
	local frame = ui.GetFrame("unlock_belt_belonging");	
	local item = GET_SLOT_ITEM(slot);
	if item ~= nil then
		local obj = GetIES(item:GetObject());
		local scrollGuid = frame:GetUserValue("ScrollGuid")
    	local scrollInvItem = session.GetInvItemByGuid(scrollGuid);
    	if scrollInvItem == nil then
    		return;
    	end
		local scrollObj = GetIES(scrollInvItem:GetObject());		
		local ret, msg = shared_item_belt.is_valid_unlock_item(scrollObj, obj)		
		if ret == true then
			slot:GetIcon():SetGrayStyle(0);
		else			
			slot:GetIcon():SetGrayStyle(1);
		end
	end
end

function UNLOCK_BELT_BELONGING_SCROLL_SELECT_TARGET_ITEM(scrollItem)	
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
	
	local frame = ui.GetFrame("unlock_belt_belonging");
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

	UNLOCK_BELT_BELONGING_SCROLL_CANCEL();	
	UNLOCK_BELT_BELONGING_SCROLL_UI_INIT();
	UNLOCK_BELT_BELONGING_SCROLL_UI_RESET();
	frame:ShowWindow(1);
	
	ui.GuideMsg("DropItemPlz");

	local invframe = ui.GetFrame("inventory");
	local gbox = invframe:GetChild("inventoryGbox");
	ui.SetEscapeScp("UNLOCK_BELT_BELONGING_SCROLL_CANCEL()");
		
	local tab = gbox:GetChild("inventype_Tab");	
	tolua.cast(tab, "ui::CTabControl");
	tab:SelectTab(1);

	SET_SLOT_APPLY_FUNC(invframe, "UNLOCK_BELT_BELONGING_SCROLL_CHECK_TARGET_ITEM", nil, "Equip");
	INVENTORY_SET_CUSTOM_RBTNDOWN("UNLOCK_BELT_BELONGING_SCROLL_INV_RBTN");
end
