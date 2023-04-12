function UNIQUEDECOMPOSE_ON_INIT(addon, frame)
	addon:RegisterMsg('OPEN_DLG_UNIQUEDECOMPOSE', 'ON_OPEN_DLG_UNIQUEDECOMPOSE')
	addon:RegisterMsg('RESULT_UNIQUE_DECOMPOSE', 'ON_RESULT_UNIQUE_DECOMPOSE')
end

function ON_OPEN_DLG_UNIQUEDECOMPOSE(frame, msg, argStr, argNum)
	ui.OpenFrame('uniquedecompose')
end

function UNIQUEDECOMPOSE_OPEN(frame)
	ui.OpenFrame('inventory')
	CLEAR_UNIQUEDECOMPOSE()
	INVENTORY_SET_CUSTOM_RBTNDOWN("UNIQUEDECOMPOSE_INV_RBTN")
end

function UNIQUEDECOMPOSE_CLOSE(frame)
	INVENTORY_SET_CUSTOM_RBTNDOWN("None")
	control.DialogOk()
	ui.CloseFrame('inventory')
end

function CLEAR_UNIQUEDECOMPOSE()
	local frame = ui.GetFrame('uniquedecompose')

	local slot_result = GET_CHILD_RECURSIVELY(frame, 'slot_result')
	slot_result:ClearIcon()
	slot_result:ShowWindow(0)

	local text_result = GET_CHILD_RECURSIVELY(frame, 'text_result')
	text_result:SetText('')

	local slot = GET_CHILD_RECURSIVELY(frame, 'slot', 'ui::CSlot')
	slot:ClearIcon()

	local item_name = GET_CHILD_RECURSIVELY(frame, 'text_itemname')
	item_name:SetText('')
	
	local txt_complete = GET_CHILD_RECURSIVELY(frame, 'text_complete')
	txt_complete:ShowWindow(0)

	local txt_puton = GET_CHILD_RECURSIVELY(frame, 'text_putonitem')
	txt_puton:ShowWindow(1)

	local okbutton = GET_CHILD_RECURSIVELY(frame, 'okbutton')
	okbutton:ShowWindow(0)

	local execbutton = GET_CHILD_RECURSIVELY(frame, 'execbutton')
	execbutton:ShowWindow(1)
end

function UNIQUEDECOMPOSE_DROP_TARGET(parent, ctrl)
	local liftIcon = ui.GetLiftIcon()
	local fromFrame = liftIcon:GetTopParentFrame()
	if fromFrame:GetName() == 'inventory' then
		local iconInfo = liftIcon:GetInfo()
		local frame = parent:GetTopParentFrame()
		UNIQUEDECOMPOSE_SET_TARGET(frame, iconInfo:GetIESID())
	end
end

function UNIQUEDECOMPOSE_INV_RBTN(itemObj, slot)
	local frame = ui.GetFrame('uniquedecompose')

	local icon = slot:GetIcon()
	local iconInfo = icon:GetInfo()
	local invItem = GET_PC_ITEM_BY_GUID(iconInfo:GetIESID())
	if invItem == nil then
		return
	end
	
	UNIQUEDECOMPOSE_SET_TARGET(frame, iconInfo:GetIESID())
end

function UNIQUEDECOMPOSE_SET_TARGET(frame, itemGuid)
	local invItem = session.GetInvItemByGuid(itemGuid)
	if invItem == nil then
		return
	end

	if invItem.isLockState == true then
		ui.SysMsg(ClMsg('MaterialItemIsLock'))
		return
	end

	local itemObj = GetIES(invItem:GetObject())
	if ENABLE_DECOMPOSE_EVIL_GODDESS_ITEM(itemObj) == false then
		ui.SysMsg(ClMsg('decomposeCant'))
		return
	end

	CLEAR_UNIQUEDECOMPOSE()
	
	local slot = GET_CHILD_RECURSIVELY(frame, "slot")
	SET_SLOT_ITEM(slot, invItem)

	local txt_puton = GET_CHILD_RECURSIVELY(frame, 'text_putonitem')
	txt_puton:ShowWindow(0)
	
	local item_name = GET_CHILD_RECURSIVELY(frame, 'text_itemname')
	item_name:SetText(dic.getTranslatedStr(TryGetProp(itemObj, 'Name', 'None')))

	frame:SetUserValue('TARGET_ITEM_GUID', itemGuid)
end

function UNIQUEDECOMPOSE_EXECUTE(parent, ctrl)
	local frame = parent:GetTopParentFrame()
	local targetGuid = frame:GetUserValue('TARGET_ITEM_GUID')
	if targetGuid == "None" then
		return
	end
	
	local targetItem = session.GetInvItemByGuid(targetGuid)
	if targetItem == nil then
		return
	end
    
	if targetItem.isLockState == true then
		ui.SysMsg(ClMsg('MaterialItemIsLock'))
		return
	end
	
	local targetObj = GetIES(targetItem:GetObject())
	if ENABLE_DECOMPOSE_EVIL_GODDESS_ITEM(targetObj) == false then
		ui.SysMsg(ClMsg('decomposeCant'))
		return
	end

	local yesScp = string.format('_UNIQUEDECOMPOSE_EXECUTE("%s")', targetGuid)
	ui.MsgBox(ClMsg('ReallyDecomposeEvilGoddess'), yesScp, 'None')
end

function _UNIQUEDECOMPOSE_EXECUTE(targetGuid)
	local frame = ui.GetFrame('uniquedecompose')
	local itemGuid = frame:GetUserValue('TARGET_ITEM_GUID')
	if itemGuid == 'None' then
		return
	end
	
    pc.ReqExecuteTx_Item("ITEM_EVIL_GODDESS_DECOMPOSE", itemGuid)
end

function ON_RESULT_UNIQUE_DECOMPOSE(frame, msg, argStr, argNum)
	if argStr == nil or argStr == 'None' then
		return
	end

	local slot = GET_CHILD_RECURSIVELY(frame, 'slot', 'ui::CSlot')
	slot:ClearIcon()
	
	local item_name = GET_CHILD_RECURSIVELY(frame, 'text_itemname')
	item_name:SetText('')
	
	local txt_complete = GET_CHILD_RECURSIVELY(frame, 'text_complete')
	txt_complete:ShowWindow(1)

	local rewardCls = GetClass('Item', argStr)
	if rewardCls ~= nil then
		local slot_result = GET_CHILD_RECURSIVELY(frame, 'slot_result')
		slot_result:ShowWindow(1)
		SET_SLOT_IMG(slot_result, rewardCls.Icon)

		local text_result = GET_CHILD_RECURSIVELY(frame, 'text_result')
		local reward_name = dic.getTranslatedStr(rewardCls.Name)
		text_result:SetText(reward_name)
	end

	local execbutton = GET_CHILD_RECURSIVELY(frame, 'execbutton')
	execbutton:ShowWindow(0)

	local okbutton = GET_CHILD_RECURSIVELY(frame, 'okbutton')
	okbutton:ShowWindow(1)
end