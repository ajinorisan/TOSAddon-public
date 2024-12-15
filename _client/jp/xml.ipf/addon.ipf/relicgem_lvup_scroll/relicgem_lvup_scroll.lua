function RELICGEM_LVUP_SCROLL_ON_INIT(addon, frame)
	addon:RegisterMsg("RELICGEM_LVUP_COMPLETE", "RELICGEM_LVUP_SCROLL_RESULT")
end

function RELICGEM_LVUP_SCROLL_TARGET_ITEM_SLOT(slot, invItem, scrollClsID)
	local frame = slot:GetTopParentFrame()
	frame:SetUserValue('CABINET_ITEM_TYPE', 0)

	local itemCls = GetClassByType("Item", invItem.type)

	local type = itemCls.ClassID
	local obj = GetIES(invItem:GetObject())
	local img = GET_ITEM_ICON_IMAGE(obj)

	SET_SLOT_IMG(slot, img)
	SET_SLOT_COUNT(slot, count)
	SET_SLOT_IESID(slot, invItem:GetIESID())
	
	local icon = slot:GetIcon()
	local iconInfo = icon:GetInfo()
	iconInfo.type = type

	icon:SetTooltipType("reinforceitem")
	icon:SetTooltipArg("transcendscroll", scrollClsID, invItem:GetIESID())
end

function RELICGEM_LVUP_SCROLL_EXEC_ASK_AGAIN(frame, btn)
	local scrollType = frame:GetUserValue("ScrollType")
	if scrollType ~= "RelicGemLVUPScroll" then return end

	local clickable = frame:GetUserValue("EnableTranscendButton")
	if tonumber(clickable) ~= 1 then
		return
	end

	local acc = GetMyAccountObj()
	if acc == nil then return end

	local itemObj = nil
	local gemLv = 0
	local slot = GET_CHILD(frame, "slot")
	local cabinetType = frame:GetUserIValue('CABINET_ITEM_TYPE')
	if cabinetType > 0 then
		local cabinetCls = GetClassByType('cabinet_relicgem', cabinetType)
		if cabinetCls == nil then
			ui.MsgBox(ScpArgMsg("DropItemPlz"))
			imcSound.PlaySoundEvent(frame:GetUserConfig("TRANS_BTN_OVER_SOUND"))
			return
		end

		itemObj = GetClass('Item', cabinetCls.ClassName)
		gemLv = TryGetProp(acc, cabinetCls.UpgradeAccountProperty, 0)
	else
		local invItem = GET_SLOT_ITEM(slot)
		if invItem == nil then
			ui.MsgBox(ScpArgMsg("DropItemPlz"))
			imcSound.PlaySoundEvent(frame:GetUserConfig("TRANS_BTN_OVER_SOUND"))
			return
		end

		itemObj = GetIES(invItem:GetObject())
		gemLv = TryGetProp(itemObj, "GemLevel", 1)
	end

	local scrollGuid = frame:GetUserValue("ScrollGuid")
	local scrollInvItem = session.GetInvItemByGuid(scrollGuid)
	if scrollInvItem == nil then
		ui.SysMsg(ScpArgMsg("TranscendScrollNotExist"))
		return
	end

	local scrollObj = GetIES(scrollInvItem:GetObject())
	local clmsg = ScpArgMsg("ArkLvupScrollWarning{Before}{After}", "Before", gemLv, "After", TryGetProp(scrollObj, "NumberArg1", 0))
	imcSound.PlaySoundEvent(frame:GetUserConfig("TRANS_BTN_OK_SOUND"))
	ui.MsgBox_NonNested(clmsg, frame:GetName(), "RELICGEM_LVUP_SCROLL_EXEC", "None")
end

function RELICGEM_LVUP_SCROLL_RESULT(frame, msg, arg_str, arg_num)
	local frame = ui.GetFrame("relicgem_lvup_scroll")
	if arg_num == 1 then
		local animpic_bg = GET_CHILD_RECURSIVELY(frame, "animpic_bg")
		animpic_bg:ShowWindow(1)
		animpic_bg:ForcePlayAnimation()
		ReserveScript("RELICGEM_LVUP_SCROLL_CHANGE_BUTTON()", 0.3)
	else
		RELICGEM_LVUP_SCROLL_RESULT_UPDATE(frame, 0)
	end
	
	RELICGEM_LVUP_SCROLL_LOCK_ITEM("None")
	
	local slot = GET_CHILD(frame, "slot")
	local icon = slot:GetIcon()
	icon:SetTooltipType("None")
	icon:SetTooltipArg("", 0, "")
	ReserveScript("RELICGEM_LVUP_SCROLL_CHANGE_TOOLTIP()", 0.3)
end

function RELICGEM_LVUP_SCROLL_CHANGE_TOOLTIP()
	local frame = ui.GetFrame("relicgem_lvup_scroll")
	local slot = GET_CHILD(frame, "slot")
	local icon = slot:GetIcon()
	local invItem = GET_SLOT_ITEM(slot)
	if invItem ~= nil then
		local obj = GetIES(invItem:GetObject())
		icon:SetTooltipType("wholeitem")
		icon:SetTooltipArg("", 0, invItem:GetIESID())
	end
end

function RELICGEM_LVUP_SCROLL_CHANGE_BUTTON()
	local frame = ui.GetFrame("relicgem_lvup_scroll")
	local button_transcend = frame:GetChild("button_transcend")
	local button_close = frame:GetChild("button_close")
	button_transcend:ShowWindow(0)
	button_close:ShowWindow(1)
end

function RELICGEM_LVUP_SCROLL_RESULT_UPDATE(frame, isSuccess)
	local slot = GET_CHILD(frame, "slot")
	
	local timesecond = 0
	if isSuccess == 1 then
		imcSound.PlaySoundEvent(frame:GetUserConfig("TRANS_SUCCESS_SOUND"))
		slot:StopActiveUIEffect()
		slot:PlayActiveUIEffect()
		timesecond = 2
	else
		imcSound.PlaySoundEvent(frame:GetUserConfig("TRANS_FAIL_SOUND"))
		local slot_temp = GET_CHILD(frame, "slot_temp")
		slot_temp:ShowWindow(1)
		slot_temp:StopActiveUIEffect()
		slot_temp:PlayActiveUIEffect()
		timesecond = 1
	end
	
	frame:StopUpdateScript("TIMEWAIT_STOP_RELICGEM_LVUP_SCROLL")
	frame:RunUpdateScript("TIMEWAIT_STOP_RELICGEM_LVUP_SCROLL", timesecond)
end

function TIMEWAIT_STOP_RELICGEM_LVUP_SCROLL()
	local frame = ui.GetFrame("relicgem_lvup_scroll")
	local slot_temp = GET_CHILD(frame, "slot_temp")
	slot_temp:ShowWindow(0)
	slot_temp:StopActiveUIEffect()

	local popupFrame = ui.GetFrame("ark_lvup_scroll_result")
	local gbox = popupFrame:GetChild("gbox")
	popupFrame:ShowWindow(1)
	popupFrame:SetDuration(6.0)
	
	frame:StopUpdateScript("TIMEWAIT_STOP_RELICGEM_LVUP_SCROLL")
	
	return 1
end

function RELICGEM_LVUP_SCROLL_BG_ANIM_TICK(ctrl, str, tick)
	if tick == 10 then
		local frame = ctrl:GetTopParentFrame()
		local animpic_slot = GET_CHILD_RECURSIVELY(frame, "animpic_slot")
		animpic_slot:ForcePlayAnimation()
		ReserveScript("RELICGEM_LVUP_SCROLL_EFFECT()", 0.3)
	end
end

function RELICGEM_LVUP_SCROLL_EFFECT()
	local frame = ui.GetFrame("relicgem_lvup_scroll")
	RELICGEM_LVUP_SCROLL_RESULT_UPDATE(frame, 1)
end

function RELICGEM_LVUP_SCROLL_EXEC()
	local frame = ui.GetFrame("relicgem_lvup_scroll")
	local scrollGuid = frame:GetUserValue("ScrollGuid")
	local scrollItem = session.GetInvItemByGuid(scrollGuid)
	if scrollItem == nil then return end

	imcSound.PlaySoundEvent(frame:GetUserConfig("TRANS_EVENT_EXEC"))
	frame:SetUserValue("EnableTranscendButton", 0)
	
	local cabinetType = frame:GetUserIValue('CABINET_ITEM_TYPE')
	if cabinetType > 0 then
		session.ResetItemList()
		session.AddItemID(scrollGuid)
		local resultlist = session.GetItemIDList()
		local arglist = NewStringList()
		arglist:Add(tostring(cabinetType))
		item.DialogTransaction("RELIC_GEM_LVUP_SCROLL", resultlist, '', arglist)
	else
		local slot = GET_CHILD(frame, "slot")
		local targetItem = GET_SLOT_ITEM(slot)
		session.ResetItemList()
		session.AddItemID(targetItem:GetIESID())
		session.AddItemID(scrollGuid)
		local resultlist = session.GetItemIDList()
		item.DialogTransaction("RELIC_GEM_LVUP_SCROLL", resultlist)
	end
	
	imcSound.PlaySoundEvent(frame:GetUserConfig("TRANS_CAST"))
end

function RELICGEM_LVUP_SCROLL_CANCEL()
	RELICGEM_LVUP_SCROLL_LOCK_ITEM("None")
end

function RELICGEM_LVUP_SCROLL_CLOSE()
	local frame = ui.GetFrame("relicgem_lvup_scroll")
	frame:SetUserValue("ScrollType", "None")
	frame:SetUserValue("ScrollGuid", "None")
	frame:OpenFrame(0)
	
	ui.RemoveGuideMsg("DropItemPlz")
	ui.RemoveGuideMsg("NOT_A_RELIC_GEM")
	ui.SetEscapeScp("")

	RELICGEM_LVUP_SCROLL_LOCK_ITEM("None")
	RELICGEM_LVUP_SCROLL_UI_RESET()
	RELICGEM_LVUP_SCROLL_CANCEL()
	
	local invframe = ui.GetFrame("inventory")
	SET_SLOT_APPLY_FUNC(invframe, "None")
	INVENTORY_SET_CUSTOM_RBTNDOWN("None")

	local gbox = invframe:GetChild("inventoryGbox")
	local tab = gbox:GetChild("inventype_Tab")
	tolua.cast(tab, "ui::CTabControl")
	tab:SelectTab(0)
end

function RELICGEM_LVUP_SCROLL_LOCK_ITEM(guid)
	local lockItemGuid = nil;
	local frame = ui.GetFrame("relicgem_lvup_scroll")
	if frame ~= nil and guid == "None" then
		local slot = GET_CHILD_RECURSIVELY(frame, "slot")
		if slot ~= nil then
			local icon = slot:GetIcon()
			if icon ~= nil then
				tolua.cast(icon, "ui::CIcon")
				lockItemGuid = icon:GetInfo():GetIESID()
			end
		end
	end

	if lockItemGuid == nil then
		lockItemGuid = guid
	end

	if lockItemGuid == "None" then
		return
	end

	local invframe = ui.GetFrame("inventory")
	if invframe == nil then return end
	invframe:SetUserValue("ITEM_GUID_IN_RELICGEM_LVUP_SCROLL", guid)
	INVENTORY_ON_MSG(invframe, "UPDATE_ITEM_RELICGEM_LVUP_SCROLL", lockItemGuid)
end

function RELICGEM_LVUP_SCROLL_UI_INIT()
	local frame = ui.GetFrame("relicgem_lvup_scroll")
	local scrollGuid = frame:GetUserValue("ScrollGuid")
	local scrollInvItem = session.GetInvItemByGuid(scrollGuid)
	if scrollInvItem == nil then
		return
	end

	local scrollObj = GetIES(scrollInvItem:GetObject())
	local scrollType = frame:GetUserValue("ScrollType")
	
	local title_msg = "relicgem_lvup_scroll"
	local desc_msg = ScpArgMsg("ArkLvUpTo{Level}", "Level", TryGetProp(scrollObj, "NumberArg1", 0))
	local btn_msg = "Reinforce_2"
	local btn_scp = "RELICGEM_LVUP_SCROLL_EXEC_ASK_AGAIN"
	
	local text_title = GET_CHILD(frame, "text_title")
	text_title:SetTextByKey("value", ClMsg(title_msg))
	
	local button_close = GET_CHILD(frame, "button_close")
	button_close:ShowWindow(1)
	
	local transcend_gb = GET_CHILD_RECURSIVELY(frame, "transcend_gb")
	transcend_gb:ShowWindow(1)
	
	local text_desc = GET_CHILD_RECURSIVELY(frame, "text_desc")
	text_desc:SetTextByKey("value", desc_msg)
	text_desc:ShowWindow(1)

	local main_gb = GET_CHILD_RECURSIVELY(frame, "main_gb")
	main_gb:ShowWindow(0)

	local button_transcend = GET_CHILD(frame, "button_transcend")
	button_transcend:SetTextByKey("value", ClMsg(btn_msg))
	button_transcend:SetEventScript(ui.LBUTTONUP, btn_scp)
end

function RELICGEM_LVUP_SCROLL_UI_RESET()
	local frame = ui.GetFrame("relicgem_lvup_scroll")
	frame:SetUserValue("CABINET_ITEM_TYPE", 0)

	local slot = GET_CHILD(frame, "slot")
	slot:ClearIcon()

	local text_name = GET_CHILD(frame, "text_name")
	local text_itemtranscend = frame:GetChild("text_itemtranscend")

	local text_title = GET_CHILD(frame, "text_title")
	text_title:SetTextByKey("value", "")
	
	text_name:ShowWindow(0)
end

function RELICGEM_LVUP_SCROLL_INV_RBTN(itemObj, slot)	
	local icon = slot:GetIcon()
	local iconInfo = icon:GetInfo()
	local invItem = GET_PC_ITEM_BY_GUID(iconInfo:GetIESID())

	local invframe = ui.GetFrame("inventory")
	RELICGEM_LVUP_SCROLL_SET_TARGET_ITEM(invframe, invItem)
end

function RELICGEM_LVUP_SCROLL_ITEM_DROP(parent, ctrl)
	local liftIcon = ui.GetLiftIcon()
	local iconInfo = liftIcon:GetInfo()
	local invItem = GET_PC_ITEM_BY_GUID(iconInfo:GetIESID())
	if nil == invItem then
		return
	end

	local invframe = ui.GetFrame("inventory")
	RELICGEM_LVUP_SCROLL_SET_TARGET_ITEM(invframe, invItem)
end

function RELICGEM_LVUP_SCROLL_SET_TARGET_ITEM(invframe, invItem)
	local frame = ui.GetFrame("relicgem_lvup_scroll")

	local scrollType = frame:GetUserValue("ScrollType")

	local button_transcend = GET_CHILD(frame, "button_transcend")
	local button_close = GET_CHILD(frame, "button_close")
	button_close:ShowWindow(0)
	button_transcend:ShowWindow(1)
	
	local slot_temp = GET_CHILD(frame, "slot_temp")
	slot_temp:StopActiveUIEffect()
	slot_temp:ShowWindow(0)

	local scrollGuid = frame:GetUserValue("ScrollGuid")
	local scrollInvItem = session.GetInvItemByGuid(scrollGuid)
	if scrollInvItem == nil then
		return
	end

	if true == invItem.isLockState or true == scrollInvItem.isLockState then
		ui.SysMsg(ClMsg("MaterialItemIsLock"))
		return
	end

	local invframe = ui.GetFrame("inventory")
	if true == IS_TEMP_LOCK(invframe, invItem) or true == IS_TEMP_LOCK(invframe, scrollInvItem) then
		ui.SysMsg(ClMsg("MaterialItemIsLock"))
		return
	end

	local scrollObj = GetIES(scrollInvItem:GetObject())
	local itemObj = GetIES(invItem:GetObject())

	local ret, msg = IS_VALID_RELICGEM_LVUP_BY_SCROLL(itemObj, scrollObj)
	if ret == false then
		ui.SysMsg(ClMsg(msg))
		return
	end

	local slot = GET_CHILD(frame, "slot")
	
	local text_name = GET_CHILD_RECURSIVELY(frame, "text_name")
	text_name:SetTextByKey("value", "")
	text_name:SetTextByKey("value", itemObj.Name)
	text_name:ShowWindow(1);

	local lev = TryGetProp(itemObj, "GemLevel", 1)
	
	RELICGEM_LVUP_SCROLL_CANCEL()
	RELICGEM_LVUP_SCROLL_TARGET_ITEM_SLOT(slot, invItem, scrollObj.ClassID)
	RELICGEM_LVUP_SCROLL_LOCK_ITEM(invItem:GetIESID())

	frame:SetUserValue("EnableTranscendButton", 1)
	frame:OpenFrame(1)
end

function RELICGEM_LVUP_SCROLL_CHECK_TARGET_ITEM(slot) -- _CHECK_MORU_TARGET_ITEM
	local frame = ui.GetFrame("relicgem_lvup_scroll")	
	local scrollType = frame:GetUserValue("ScrollType")
	local item = GET_SLOT_ITEM(slot)
	if item ~= nil then
		local obj = GetIES(item:GetObject())
		local scrollGuid = frame:GetUserValue("ScrollGuid")
    	local scrollInvItem = session.GetInvItemByGuid(scrollGuid)
    	if scrollInvItem == nil then
    		return
		end
		
		local scrollObj = GetIES(scrollInvItem:GetObject())
		local ret, msg = IS_VALID_RELICGEM_LVUP_BY_SCROLL(obj, scrollObj)
		if ret == true then
			slot:GetIcon():SetGrayStyle(0)
		else			
			slot:GetIcon():SetGrayStyle(1)
		end
	end
end

function RELICGEM_LVUP_SCROLL_SELECT_TARGET_ITEM(scrollItem)	
	if session.colonywar.GetIsColonyWarMap() == true then
        ui.SysMsg(ClMsg("CannotUseInPVPZone"))
        return
    end

	if IsPVPServer() == 1 then
		ui.SysMsg(ScpArgMsg("CantUseThisInIntegrateServer"))
		return
	end

	local rankresetFrame = ui.GetFrame("rankreset")
	if 1 == rankresetFrame:IsVisible() then
		ui.SysMsg(ScpArgMsg("CannotDoAction"))
		return
	end
	
	local frame = ui.GetFrame("relicgem_lvup_scroll")
	local scrollObj = GetIES(scrollItem:GetObject())
	local scrollType = TryGetProp(scrollObj, "StringArg", "None")
	if scrollType == "None" then
		return
	end

	local scrollGuid = GetIESGuid(scrollObj)
	frame:SetUserValue("ScrollType", scrollType)
	frame:SetUserValue("ScrollGuid", scrollGuid)
	
	if scrollObj.ItemLifeTimeOver > 0 then
		ui.SysMsg(ScpArgMsg("LessThanItemLifeTime"))
		return
	end

	RELICGEM_LVUP_SCROLL_CANCEL()
	RELICGEM_LVUP_SCROLL_UI_RESET()
	RELICGEM_LVUP_SCROLL_UI_INIT()
	frame:ShowWindow(1)
	
	ui.GuideMsg("DropItemPlz")

	local invframe = ui.GetFrame("inventory")
	local gbox = invframe:GetChild("inventoryGbox")
	ui.SetEscapeScp("RELICGEM_LVUP_SCROLL_CANCEL()")
		
	local tab = gbox:GetChild("inventype_Tab")
	tolua.cast(tab, "ui::CTabControl")
	tab:SelectTab(6)

	SET_SLOT_APPLY_FUNC(invframe, "RELICGEM_LVUP_SCROLL_CHECK_TARGET_ITEM", nil, "Equip")
	INVENTORY_SET_CUSTOM_RBTNDOWN("RELICGEM_LVUP_SCROLL_INV_RBTN")
end

function RELICGEM_LVUP_SCROLL_OPEN_CABINET(parent, ctrl)
	OPEN_ITEM_CABINET_TO_RELICGEM_LVUP()
end

function RELICGEM_LVUP_SCROLL_SET_TARGET_ITEM_CABINET(cabinetframe, type)
	local frame = ui.GetFrame("relicgem_lvup_scroll")

	local cabinetCls = GetClassByType('cabinet_relicgem', type)
	if cabinetCls == nil then return end

	local itemName = cabinetCls.ClassName
	local itemCls = GetClass('Item', itemName)
	if itemCls == nil then return end

	local scrollType = frame:GetUserValue("ScrollType")

	local button_transcend = GET_CHILD(frame, "button_transcend")
	local button_close = GET_CHILD(frame, "button_close")
	button_close:ShowWindow(0)
	button_transcend:ShowWindow(1)
	
	local slot_temp = GET_CHILD(frame, "slot_temp")
	slot_temp:StopActiveUIEffect()
	slot_temp:ShowWindow(0)

	local scrollGuid = frame:GetUserValue("ScrollGuid")
	local scrollInvItem = session.GetInvItemByGuid(scrollGuid)
	if scrollInvItem == nil then
		return
	end

	local invframe = ui.GetFrame("inventory")
	if true == IS_TEMP_LOCK(invframe, scrollInvItem) then
		ui.SysMsg(ClMsg("MaterialItemIsLock"))
		return
	end

	local scrollObj = GetIES(scrollInvItem:GetObject())
	local ret, msg = IS_VALID_RELICGEM_LVUP_BY_SCROLL_CABINET(GetMyPCObject(), itemName, scrollObj)
	if ret == false then
		ui.SysMsg(ClMsg(msg))
		return
	end

	local slot = GET_CHILD(frame, "slot")
	
	local text_name = GET_CHILD_RECURSIVELY(frame, "text_name")
	text_name:SetTextByKey("value", "")
	text_name:SetTextByKey("value", itemCls.Name)
	text_name:ShowWindow(1);
	
	RELICGEM_LVUP_SCROLL_CANCEL()
	RELICGEM_LVUP_SCROLL_TARGET_ITEM_SLOT_CABINET(slot, type, scrollObj.ClassID)

	frame:SetUserValue("EnableTranscendButton", 1)
	frame:OpenFrame(1)
end

function RELICGEM_LVUP_SCROLL_TARGET_ITEM_SLOT_CABINET(slot, type, scrollClsID)
	local cabinetCls = GetClassByType('cabinet_relicgem', type)
	if cabinetCls == nil then return end

	local itemName = cabinetCls.ClassName
	local itemCls = GetClass('Item', itemName)
	local img = GET_ITEM_ICON_IMAGE(itemCls)
	
	local frame = slot:GetTopParentFrame()
	frame:SetUserValue('CABINET_ITEM_TYPE', type)

	SET_SLOT_IMG(slot, img)
	SET_SLOT_COUNT(slot, count)
	
	local icon = slot:GetIcon()
	local iconInfo = icon:GetInfo()
	iconInfo.type = type
end