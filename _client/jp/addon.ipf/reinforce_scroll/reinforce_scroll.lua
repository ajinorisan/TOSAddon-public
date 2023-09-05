function REINFORCE_SCROLL_ON_INIT(addon, frame)
end

function REINFORCE_SCROLL_TARGET_ITEM_SLOT(slot, invItem, scrollClsID)
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
	slot:SetEventScript(ui.RBUTTONDOWN, "ON_REMOVE_TARGET_ITEM_REINFORCE_SCROLL");
end

function ON_REMOVE_TARGET_ITEM_REINFORCE_SCROLL(frame, slot, str)
	REINFORCE_SCROLL_LOCK_ITEM("None")
	REINFORCE_SCROLL_UI_RESET();
	REINFORCE_SCROLL_CANCEL();
end

function REINFORCE_SCROLL_EXEC_ASK_AGAIN(frame, btn)
	local scrollType = frame:GetUserValue("ScrollType")
	local clickable = frame:GetUserValue("EnableTranscendButton")
	if tonumber(clickable) ~= 1 then
		return;
	end

	local buffState = IS_ENABLE_BUFF_STATE_TO_REINFORCE_OR_TRANSCEND_C();
	if buffState ~= 'YES' then
		local buffCls = GetClass('Buff', buffState);
		if buffCls ~= nil then
			ui.SysMsg(ScpArgMsg("CannotReinforceAndTranscendBy{BUFFNAME}","BUFFNAME", buffCls.Name));
		end
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

	local potential = TryGetProp(itemObj, "PR", 0);	
	if potential == nil then
		return;
	end
	
	local before_reinforce = TryGetProp(itemObj, "Reinforce_2", 0);		
	local after_reinforce = TryGetProp(scrollObj, "NumberArg2", 0);	
	
	local clmsg = ScpArgMsg("ReinforceScrollWarning{Before}{After}", "Before", before_reinforce, "After", after_reinforce)
	if TryGetProp(scrollObj, 'StringArg', 'None') == 'rada_option_rescale_scroll' then
		clmsg = ScpArgMsg("RadaOptionReScaleScrollWarning")
	end

	imcSound.PlaySoundEvent(frame:GetUserConfig("TRANS_BTN_OK_SOUND"));
	ui.MsgBox_NonNested(clmsg, frame:GetName(), "REINFORCE_SCROLL_EXEC", "None");
end

function REINFORCE_SCROLL_RESULT(isSuccess, after_reinforce)	
	local frame = ui.GetFrame("reinforce_scroll");
	if isSuccess == 1 then
		local animpic_bg = GET_CHILD_RECURSIVELY(frame, "animpic_bg");
		animpic_bg:ShowWindow(1);
		animpic_bg:ForcePlayAnimation();
		ReserveScript("REINFORCE_SCROLL_CHANGE_BUTTON()", 0.3);
		local text_itemtranscend = GET_CHILD_RECURSIVELY(frame, "text_itemtranscend");
		text_itemtranscend:SetTextByKey("value", string.format("{s20}%s", after_reinforce));
	else
		REINFORCE_SCROLL_RESULT_UPDATE(frame, 0);
	end
	
	REINFORCE_SCROLL_LOCK_ITEM("None");
	
	local slot = GET_CHILD(frame, "slot");
	local icon = slot:GetIcon();
	icon:SetTooltipType("None");
	icon:SetTooltipArg("", 0, "");
	ReserveScript("REINFORCE_SCROLL_CHANGE_TOOLTIP()", 0.3);
end

function REINFORCE_SCROLL_CHANGE_TOOLTIP()
	local frame = ui.GetFrame("reinforce_scroll");
	local slot = GET_CHILD(frame, "slot");
	local icon = slot:GetIcon();
	local invItem = GET_SLOT_ITEM(slot);
	if invItem ~= nil then
		local obj = GetIES(invItem:GetObject());
		icon:SetTooltipType("wholeitem");
		icon:SetTooltipArg("", 0, invItem:GetIESID());
	end
end

function REINFORCE_SCROLL_CHANGE_BUTTON()
	local frame = ui.GetFrame("reinforce_scroll");
	local button_transcend = frame:GetChild("button_transcend");	
	local button_close = frame:GetChild("button_close");	
	button_transcend:ShowWindow(0);	
	button_close:ShowWindow(1);	
end

function REINFORCE_SCROLL_RESULT_UPDATE(frame, isSuccess)	
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
	
	local scroll_type = frame:GetUserValue("ScrollType");
	if scroll_type == "ENCHANT" or scroll_type == "SETOPTION" then
		return;
	end

	local invItem = GET_SLOT_ITEM(slot);
	if invItem == nil then
		slot:ClearIcon();
		return;
	end
	
	local obj = GetIES(invItem:GetObject());
	local transcend = obj.Transcend;
	local tempValue = transcend;
	local beforetranscend;

	if isSuccess == 0 then
		beforetranscend = transcend;
		transcend = transcend + 1;
	else
		beforetranscend = transcend - 1;
	end

	local transcendCls = GetClass("ItemTranscend", transcend);
	if transcendCls == nil then
		return;
	end

	local resultTxt = "";
	local afterNames, afterValues = GET_ITEM_TRANSCENDED_PROPERTY(obj);
	local upfont = "{@st43_green}{s18}";
	local operTxt = " + ";	
	local text_itemtranscend = frame:GetChild("text_itemtranscend");
	local text_color1 = 0xFF1DDB16;
	local text_color2 = 0xFF22741C;
	if isSuccess == 0 then
		upfont = "{@st43_red}{s18}";
		text_color1 = 0xFFFF0000;
		text_color2 = 0xFFFFBB00;
	end;
	text_itemtranscend:ShowWindow(0);	
	text_itemtranscend:StopColorBlend();	
	text_itemtranscend:ShowWindow(1);

	frame:StopUpdateScript("TIMEWAIT_STOP_REINFORCE_SCROLL");
	frame:RunUpdateScript("TIMEWAIT_STOP_REINFORCE_SCROLL", timesecond);
end

function TIMEWAIT_STOP_REINFORCE_SCROLL()
	local frame = ui.GetFrame("transcend_scroll");
	local slot_temp = GET_CHILD(frame, "slot_temp");
	slot_temp:ShowWindow(0);
	slot_temp:StopActiveUIEffect();

	local popupFrame = ui.GetFrame("saved_reinforce_scroll_result");
	local gbox = popupFrame:GetChild("gbox");
	popupFrame:ShowWindow(1);	
	popupFrame:SetDuration(6.0);
	
	frame:StopUpdateScript("TIMEWAIT_STOP_REINFORCE_SCROLL");
	return 1;
end

function REINFORCE_SCROLL_BG_ANIM_TICK(ctrl, str, tick)
	if tick == 10 then
		local frame = ctrl:GetTopParentFrame();
		local animpic_slot = GET_CHILD_RECURSIVELY(frame, "animpic_slot");
		animpic_slot:ForcePlayAnimation();	
		ReserveScript("REINFORCE_SCROLL_EFFECT()", 0.3);
	end
end

function REINFORCE_SCROLL_EFFECT()
	local frame = ui.GetFrame("reinforce_scroll");
	REINFORCE_SCROLL_RESULT_UPDATE(frame, 1);	
end

function REINFORCE_SCROLL_EXEC()
	local frame = ui.GetFrame("reinforce_scroll");		
	imcSound.PlaySoundEvent(frame:GetUserConfig("TRANS_EVENT_EXEC"));
	frame:SetUserValue("EnableTranscendButton", 0);
	
	local slot = GET_CHILD(frame, "slot");
	local targetItem = GET_SLOT_ITEM(slot);
	local scrollGuid = frame:GetUserValue("ScrollGuid")
	
	session.ResetItemList();
	session.AddItemID(targetItem:GetIESID());
	session.AddItemID(scrollGuid);
	
	local resultlist = session.GetItemIDList();
	item.DialogTransaction("ITEM_REINFORCE_SCROLL", resultlist);
	
	imcSound.PlaySoundEvent(frame:GetUserConfig("TRANS_CAST"));
end

function REINFORCE_SCROLL_CANCEL()
	REINFORCE_SCROLL_LOCK_ITEM("None");
end

function REINFORCE_SCROLL_CLOSE()
	local frame = ui.GetFrame("reinforce_scroll");
	frame:SetUserValue("ScrollType", "None")
	frame:SetUserValue("ScrollGuid", "None")
	frame:SetUserValue("BeforeTranscend", "None");
	frame:OpenFrame(0);
	
	ui.RemoveGuideMsg("DropItemPlz");
	ui.SetEscapeScp("");

	REINFORCE_SCROLL_LOCK_ITEM("None")
	REINFORCE_SCROLL_UI_RESET();
	REINFORCE_SCROLL_CANCEL();
	
	local invframe = ui.GetFrame("inventory");
	SET_SLOT_APPLY_FUNC(invframe, "None");
	INVENTORY_SET_CUSTOM_RBTNDOWN("None");
end

function REINFORCE_SCROLL_LOCK_ITEM(guid)
	local lockItemGuid = nil;
	local frame = ui.GetFrame("reinforce_scroll");
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
	invframe:SetUserValue("ITEM_GUID_IN_LUCIFERI_REINFORCE_SCROLL", guid);
	INVENTORY_ON_MSG(invframe, "UPDATE_ITEM_LUCIFERI_REINFORCE_SCROLL", lockItemGuid);
end

function REINFORCE_SCROLL_UI_INIT()		
	local frame = ui.GetFrame("reinforce_scroll");
	local scrollGuid = frame:GetUserValue("ScrollGuid")	
	local scrollInvItem = session.GetInvItemByGuid(scrollGuid);
	if scrollInvItem == nil then
		return
	end
	local scrollObj = GetIES(scrollInvItem:GetObject());

	local text_title = GET_CHILD(frame, "text_title");	
	text_title:SetTextByKey("value", ClMsg(TryGetProp(scrollObj, 'StringArg2', 'None')));
		
	local button_close = GET_CHILD(frame, "button_close");	
	button_close:ShowWindow(1);
	
	local transcend_gb = GET_CHILD_RECURSIVELY(frame, "transcend_gb");
	transcend_gb:ShowWindow(1);


	local text_reinforce = GET_CHILD_RECURSIVELY(frame, "text_reinforce")
	local num_2 = TryGetProp(scrollObj, 'NumberArg2', 0)
	if TryGetProp(scrollObj, 'StringArg', 'None') ~= 'rada_option_rescale_scroll' then	
		text_reinforce:SetTextByKey("value", TryGetProp(scrollObj, 'NumberArg2', 0))
	else
		local text_itemtranscend = GET_CHILD_RECURSIVELY(frame, 'text_itemtranscend')
		text_reinforce:ShowWindow(0)
		text_itemtranscend:ShowWindow(0)
	end
	
	local text_desc = GET_CHILD_RECURSIVELY(frame, "text_desc");		
	if TryGetProp(scrollObj, 'StringArg', 'None') ~= 'rada_option_rescale_scroll' then
		text_desc:SetTextByKey("value", TryGetProp(scrollObj, 'NumberArg2', 0))	
		text_desc:ShowWindow(1);	
	else
		text_desc:ShowWindow(0);
	end

	local main_gb = GET_CHILD_RECURSIVELY(frame, "main_gb");
	main_gb:ShowWindow(0);

	local button_transcend = GET_CHILD(frame, "button_transcend");
	button_transcend:SetTextByKey("value", ClMsg("GuildEmblemChange"));
end

function REINFORCE_SCROLL_UI_RESET()
	local frame = ui.GetFrame("reinforce_scroll");

	local scrollGuid = frame:GetUserValue("ScrollGuid")		
	if scrollGuid ~= 'None' then
		local scrollInvItem = session.GetInvItemByGuid(scrollGuid);
		if scrollInvItem ~= nil then
			local scrollObj = GetIES(scrollInvItem:GetObject());	
			local text_title = GET_CHILD(frame, "text_title");
			text_title:SetTextByKey("value", ClMsg(TryGetProp(scrollObj, 'StringArg2', 'None')));
		end	
	end

	local slot = GET_CHILD(frame, "slot");
	slot:ClearIcon();

	local text_name = GET_CHILD(frame, "text_name");
	local text_itemtranscend = frame:GetChild("text_itemtranscend");	
	
	text_name:ShowWindow(0);
	text_itemtranscend:ShowWindow(0);
end

function REINFORCE_SCROLL_INV_RBTN(itemObj, slot)
	local icon = slot:GetIcon();
	local iconInfo = icon:GetInfo();
	local invItem = GET_PC_ITEM_BY_GUID(iconInfo:GetIESID());

	local invframe = ui.GetFrame("inventory");
	REINFORCE_SCROLL_SET_TARGET_ITEM(invframe, invItem)
end

function REINFORCE_SCROLL_ITEM_DROP(parent, ctrl)
	local liftIcon = ui.GetLiftIcon();
	local iconInfo = liftIcon:GetInfo();
	local invItem = GET_PC_ITEM_BY_GUID(iconInfo:GetIESID());	
	if nil == invItem then
		return;
	end

	local invframe = ui.GetFrame("inventory");
	REINFORCE_SCROLL_SET_TARGET_ITEM(invframe, invItem)
end

function REINFORCE_SCROLL_SET_TARGET_ITEM(invframe, invItem)
	local frame = ui.GetFrame("reinforce_scroll");

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
	

	local scrollType = frame:GetUserValue("ScrollType");
	local itemObj = GetIES(invItem:GetObject());

	local enable_func_str = TryGetProp(scrollObj, 'EnableFunc', 'None')
	local enable_func = _G[enable_func_str]
	local can, msg = enable_func(itemObj, scrollObj)
	if can == false then			
		ui.SysMsg(ClMsg(msg));
		return;
	end

	local text_name = GET_CHILD_RECURSIVELY(frame, "text_name")	
	local text_reinforce = GET_CHILD_RECURSIVELY(frame, "text_reinforce")
	local text_rate = GET_CHILD_RECURSIVELY(frame, "text_rate")
	local text_desc = GET_CHILD_RECURSIVELY(frame, "text_desc")	
	local text_itemtranscend = GET_CHILD_RECURSIVELY(frame, "text_itemtranscend");
	local slot = GET_CHILD(frame, "slot");
	
	text_name:SetTextByKey("value", "");
	text_name:SetTextByKey("value", itemObj.Name)
	text_name:ShowWindow(1);
	
	local lev = TryGetProp(itemObj, 'Reinforce_2', 0)		
	local gem_lv = get_current_aether_gem_level(itemObj)
	lev = math.max(lev, gem_lv)
	text_itemtranscend:SetTextByKey("value", string.format("{s20}%s", lev));
	text_itemtranscend:StopColorBlend();
	text_itemtranscend:ShowWindow(1);

	if TryGetProp(scrollObj, 'StringArg', 'None') ~= 'rada_option_rescale_scroll' then
		text_reinforce:SetTextByKey("value", TryGetProp(scrollObj, 'NumberArg2', 0))
	else
		text_reinforce:ShowWindow(0)
		text_itemtranscend:ShowWindow(0)
	end

	REINFORCE_SCROLL_CANCEL();
	REINFORCE_SCROLL_TARGET_ITEM_SLOT(slot, invItem, scrollObj.ClassID);
	REINFORCE_SCROLL_LOCK_ITEM(invItem:GetIESID())

	frame:SetUserValue("EnableTranscendButton", 1);
	frame:SetUserValue("BeforeTranscend", lev);
	frame:OpenFrame(1);
end

function REINFORCE_SCROLL_CHECK_TARGET_ITEM(slot)-- _CHECK_MORU_TARGET_ITEM
	local frame = ui.GetFrame("reinforce_scroll");
	local scrollType = frame:GetUserValue("ScrollType");
	
	local item = GET_SLOT_ITEM(slot);
	if item ~= nil then
		local obj = GetIES(item:GetObject());
		local scrollGuid = frame:GetUserValue("ScrollGuid")
    	local scrollInvItem = session.GetInvItemByGuid(scrollGuid);
    	if scrollInvItem == nil then
    		return;
    	end
    	local scrollObj = GetIES(scrollInvItem:GetObject());
		slot:GetIcon():SetGrayStyle(1);
	end
end

function REINFORCE_SCROLL_SELECT_TARGET_ITEM(scrollItem)
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
	
	local frame = ui.GetFrame("reinforce_scroll");
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

	REINFORCE_SCROLL_CANCEL();
	REINFORCE_SCROLL_UI_INIT();
	REINFORCE_SCROLL_UI_RESET();
	frame:ShowWindow(1);
	
	ui.GuideMsg("DropItemPlz");

	local invframe = ui.GetFrame("inventory");
	local gbox = invframe:GetChild("inventoryGbox");
	ui.SetEscapeScp("REINFORCE_SCROLL_CANCEL()");
		
	local tab = gbox:GetChild("inventype_Tab");	
	tolua.cast(tab, "ui::CTabControl");
	tab:SelectTab(1);

	if string.find(TryGetProp(scrollObj, 'StringArg', 'None'), 'aether') ~= nil then
		tab:SelectTab(6);
	else
		tab:SelectTab(1);
	end

	SET_SLOT_APPLY_FUNC(invframe, "REINFORCE_SCROLL_CHECK_TARGET_ITEM", nil)
	INVENTORY_SET_CUSTOM_RBTNDOWN("REINFORCE_SCROLL_INV_RBTN")
end
