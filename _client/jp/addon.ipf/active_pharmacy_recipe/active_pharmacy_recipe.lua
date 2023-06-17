function ACTIVE_PHARMACY_RECIPE_ON_INIT(addon, frame)
	addon:RegisterMsg('OPEN_DLG_ACTIVE_PHARMACY_RECIPE', 'ON_OPEN_DLG_ACTIVE_PHARMACY_RECIPE')
	addon:RegisterMsg('ACTIVE_PHARMACY_RECIPE_COMPLETE', 'ON_ACTIVE_PHARMACY_RECIPE_COMPLETE')
end

function ON_OPEN_DLG_ACTIVE_PHARMACY_RECIPE(frame, msg, argStr, argNum)
	ACTIVE_PHARMACY_RECIPE_UI_RESET()

	local invframe = ui.GetFrame('inventory')
	invframe:ShowWindow(1)

	local frame = ui.GetFrame('active_pharmacy_recipe')
	frame:ShowWindow(1)
	frame:SetMargin(0, 65, invframe:GetWidth(), 0)

	INVENTORY_SET_CUSTOM_RBTNDOWN('ACTIVE_PHARMACY_RECIPE_INV_RBTN')
end

function ON_ACTIVE_PHARMACY_RECIPE_COMPLETE(frame, msg, argStr, argNum)
	local guid = frame:GetUserValue('RECIPE_GUID')
	if guid ~= "None" then
		local invItem = GET_PC_ITEM_BY_GUID(guid)
		if invItem ~= nil then
			local itemObj = GetIES(invItem:GetObject())
			if TryGetProp(itemObj, "ClassName", "None") == "pharmacy_recipe_Tuto" then
				item.UseByGUID(guid);
			end
		end
	end

	ACTIVE_PHARMACY_RECIPE_UI_RESET()
end

function ACTIVE_PHARMACY_RECIPE_UI_RESET()
	local frame = ui.GetFrame('active_pharmacy_recipe')
	frame:SetUserValue('RECIPE_GUID', 'None')
	frame:SetUserValue('ACTIVE_COST_TYPE', 'None')
	frame:SetUserValue('ACTIVE_COST_VALUE', 0)

	local itemName = GET_CHILD_RECURSIVELY(frame, 'itemName')
	itemName:SetTextByKey('name', '')
	itemName:ShowWindow(0)

	local slot = GET_CHILD_RECURSIVELY(frame, 'slot')
	slot:ClearIcon()

	local costText = GET_CHILD_RECURSIVELY(frame, 'costText')
	costText:SetTextByKey('img', 'icon_item_season_coin_gabia')
	costText:SetTextByKey('name', '')
	costText:SetTextByKey('value', tostring(0))
	costText:ShowWindow(0)

	local continueText = GET_CHILD_RECURSIVELY(frame, 'continueText')
	continueText:ShowWindow(0)

	local continueBtn = GET_CHILD_RECURSIVELY(frame, 'continueBtn')
	continueBtn:ShowWindow(0)

	local activeBtn = GET_CHILD_RECURSIVELY(frame, 'activeBtn')
	activeBtn:ShowWindow(1)
end

function OPEN_ACTIVE_PHARMACY_RECIPE(frame)
	ACTIVE_PHARMACY_RECIPE_UI_RESET()
end

function CLOSE_ACTIVE_PHARMACY_RECIPE(frame)
	ACTIVE_PHARMACY_RECIPE_UI_RESET()

	local invframe = ui.GetFrame('inventory')
	INVENTORY_SET_CUSTOM_RBTNDOWN('None')

	invframe:ShowWindow(0)
end

function ACTIVE_PHARMACY_RECIPE_ITEM_DROP(parent, ctrl)
	local frame	= parent:GetTopParentFrame()
	local liftIcon = ui.GetLiftIcon()
	local slot = tolua.cast(ctrl, 'ui::CSlot')
	local iconInfo = liftIcon:GetInfo()
	local invItem = GET_PC_ITEM_BY_GUID(iconInfo:GetIESID())
	
	if nil == invItem then return end

	ACTIVE_PHARMACY_RECIPE_REG_ITEM(slot, invItem)
end

function ACTIVE_PHARMACY_RECIPE_INV_RBTN(itemObj, slot)
	local icon = slot:GetIcon()
	local iconInfo = icon:GetInfo()
	local invItem = GET_PC_ITEM_BY_GUID(iconInfo:GetIESID())
	
	local frame = ui.GetFrame('active_pharmacy_recipe')
	local slot = GET_CHILD_RECURSIVELY(frame, 'slot')
	ACTIVE_PHARMACY_RECIPE_REG_ITEM(slot, invItem)
end

function ACTIVE_PHARMACY_RECIPE_REG_ITEM(slot, invItem)
	if true == invItem.isLockState then
		ui.SysMsg(ClMsg('MaterialItemIsLock'))
		return
	end

	local obj = GetIES(invItem:GetObject())
	if TryGetProp(obj, 'StringArg', 'None') ~= 'pharmacy_recipe' then
		ui.SysMsg(ClMsg('DontUseItem'))
		return
	end

	if TryGetProp(obj, 'TeamBelonging', 0) == 1 then
		ui.SysMsg(ClMsg('AlreadyActivatedPharmacyRecipe'))
		return
	end
	
	local type, value = shared_item_pharmacy.get_reveal_cost(obj)
	if type == 'None' then
		ui.SysMsg(ClMsg('DontUseItem'))
		return
	end

	local frame = ui.GetFrame('active_pharmacy_recipe')
	local guid = invItem:GetIESID()
	frame:SetUserValue('RECIPE_GUID', guid)
	
	local slot = GET_CHILD_RECURSIVELY(frame, 'slot')
	SET_SLOT_ITEM_IMAGE(slot, invItem)
	
	local itemName = frame:GetChild('itemName')
	itemName:SetTextByKey('name', obj.Name)
	itemName:ShowWindow(1)
	
	imcSound.PlaySoundEvent('inven_equip')
	
	if TryGetProp(obj, 'TeamBelonging', 0) == 1 then
		ACTIVE_PHARMACY_RECIPE_UPDATE_CONTINUE(frame)
	else
		frame:SetUserValue('ACTIVE_COST_TYPE', type)
		frame:SetUserValue('ACTIVE_COST_VALUE', value)
	
		ACTIVE_PHARMACY_RECIPE_UPDATE_COST(frame)
	end
end

function ACTIVE_PHARMACY_RECIPE_ITEM_REMOVE(parent, ctrl)
	ACTIVE_PHARMACY_RECIPE_UI_RESET()
end

function ACTIVE_PHARMACY_RECIPE_UPDATE_COST(frame)
	local guid = frame:GetUserValue('RECIPE_GUID')
	local invItem = session.GetInvItemByGuid(guid)
	if nil == invItem then return end

	local type = frame:GetUserValue('ACTIVE_COST_TYPE')
	local value = frame:GetUserIValue('ACTIVE_COST_VALUE')

	local costCls = GetClass('accountprop_inventory_list', type)
	if costCls == nil then return end

	local imgName = TryGetProp(costCls, 'Icon', 'None')

	local continueText = GET_CHILD_RECURSIVELY(frame, 'continueText')
	continueText:ShowWindow(0)

	local costText = GET_CHILD_RECURSIVELY(frame, 'costText')
	costText:SetTextByKey('img', imgName)
	costText:SetTextByKey('name', ClMsg(type))
	costText:SetTextByKey('value', value)
	costText:ShowWindow(1)

	local continueBtn = GET_CHILD_RECURSIVELY(frame, 'continueBtn')
	continueBtn:ShowWindow(0)

	local activeBtn = GET_CHILD_RECURSIVELY(frame, 'activeBtn')
	activeBtn:ShowWindow(1)
end

function ACTIVE_PHARMACY_RECIPE_UPDATE_CONTINUE(frame)
	local guid = frame:GetUserValue('RECIPE_GUID')
	local invItem = session.GetInvItemByGuid(guid)
	if nil == invItem then return end

	local costText = GET_CHILD_RECURSIVELY(frame, 'costText')
	costText:ShowWindow(0)

	local continueText = GET_CHILD_RECURSIVELY(frame, 'continueText')
	continueText:ShowWindow(1)

	local activeBtn = GET_CHILD_RECURSIVELY(frame, 'activeBtn')
	activeBtn:ShowWindow(0)

	local continueBtn = GET_CHILD_RECURSIVELY(frame, 'continueBtn')
	continueBtn:ShowWindow(1)
end

function ACTIVE_PHARMACY_RECIPE_OK_BTN(parent, ctrl)
	local frame = parent:GetTopParentFrame()
	local guid = frame:GetUserValue('RECIPE_GUID')
	if guid == 'None' or session.GetInvItemByGuid(guid) == nil then return end

	local yesscp = string.format('EXEC_ACTIVE_PHARMACY_RECIPE(\'%s\')', guid)
	local msgbox = ui.MsgBox(ClMsg('TryRandomOptionPresetEngrave'), yesscp, 'None')
	SET_MODAL_MSGBOX(msgbox)
end

function EXEC_ACTIVE_PHARMACY_RECIPE(guid)
	local frame = ui.GetFrame('active_pharmacy_recipe')
	guid = frame:GetUserValue('RECIPE_GUID')
	local invItem = session.GetInvItemByGuid(guid)
	if invItem == nil then return end

	pc.ReqExecuteTx_Item('ACTIVE_PHARMACY_RECIPE', guid)
end

function CONTINUE_PHARMACY_RECIPE(parent, ctrl)
	local frame = parent:GetTopParentFrame()
	local guid = frame:GetUserValue('RECIPE_GUID')
	local invItem = session.GetInvItemByGuid(guid)
	if invItem == nil then return end

	local yesscp = string.format('EXEC_CONTINUE_PHARMACY_RECIPE(\'%s\')', guid)
	local msgbox = ui.MsgBox(ClMsg('TryRandomOptionPresetEngrave'), yesscp, 'None')
	SET_MODAL_MSGBOX(msgbox)
end

function EXEC_CONTINUE_PHARMACY_RECIPE(guid)
	local frame = ui.GetFrame('active_pharmacy_recipe')
	guid = frame:GetUserValue('RECIPE_GUID')
	PHARMACY_UI_OPEN(guid)
end