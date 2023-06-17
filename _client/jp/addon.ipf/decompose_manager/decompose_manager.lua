function DECOMPOSE_MANAGER_ON_INIT(addon, frame)
	addon:RegisterMsg('OPEN_DLG_DECOMPOSE_MANAGER', 'ON_OPEN_DLG_DECOMPOSE_MANAGER')
	addon:RegisterMsg('RESULT_DECOMPOSE_MANAGER', 'ON_RESULT_DECOMPOSE_MANAGER')
	addon:RegisterMsg('RESULT_DECOMPOSE_VIBORA', 'ON_RESULT_DECOMPOSE_VIBORA')
end

function ON_OPEN_DLG_DECOMPOSE_MANAGER(frame, msg, argStr, argNum)
	local frame = ui.GetFrame('decompose_manager')
	frame:ShowWindow(1)
end

function DECOMPOSE_MANAGER_OPEN(frame)
	local tab = GET_CHILD_RECURSIVELY(frame, 'type_Tab')
	local index = 0
	if tab ~= nil then
		tab:SelectTab(0)
		index = tab:GetSelectItemIndex()
	end
	ui.OpenFrame('inventory')
	INVENTORY_SET_CUSTOM_RBTNDOWN('DECOMPOSE_MANAGER_INV_RBTN')
	TOGGLE_DECOMPOSE_MANAGER_TAB(frame, index)
end

function DECOMPOSE_MANAGER_CLOSE(frame)
	if ui.CheckHoldedUI() == true then
		return
	end

	INVENTORY_SET_CUSTOM_RBTNDOWN("None")
	frame:ShowWindow(0)
	ui.CloseFrame('inventory')
	control.DialogOk()
end

function TOGGLE_DECOMPOSE_MANAGER_TAB(frame, index)
	CLEAR_DECOMPOSE_MANAGER()

	local tip_text = GET_CHILD_RECURSIVELY(frame, 'tip_text')
	local clmsg = 'None'
	if index == 0 then
		clmsg = 'CanGetMiscWhenDecomposeArk'
	elseif index == 1 then
		clmsg = 'CanGetMiscWhenDecomposeUnique'
	elseif index == 2 then
		clmsg = 'CanGetMiscWhenDecomposeMiscLegend'
	elseif index == 3 then
		clmsg = 'CanGetMiscWhenDecomposeAccEp12'
	elseif index == 4 then
		clmsg = 'CanGetMiscWhenDecomposeVibora'
	end
	
	tip_text:SetTextByKey('value', ClMsg(clmsg))
end

function DECOMPOSE_MANAGER_TAB_CHANGE(parent, ctrl)
	local frame = parent:GetTopParentFrame()
	local tab = GET_CHILD_RECURSIVELY(frame, 'type_Tab')
	local index = tab:GetSelectItemIndex()
	TOGGLE_DECOMPOSE_MANAGER_TAB(frame, index)
end

function CLEAR_DECOMPOSE_MANAGER()
	local frame = ui.GetFrame('decompose_manager')
	local tab = GET_CHILD_RECURSIVELY(frame, 'type_Tab')
	local index = tab:GetSelectItemIndex()

	for i = 1, 7 do
		local slot_result = GET_CHILD_RECURSIVELY(frame, 'result' .. i)
		if slot_result ~= nil then
			slot_result:ClearIcon()
			slot_result:ShowWindow(0)
		end

		local text_result = GET_CHILD_RECURSIVELY(frame, 'text_result' .. i)
		if text_result ~= nil then
			text_result:SetText('')
		end
	end

	local resultbox = GET_CHILD_RECURSIVELY(frame, 'resultbox')
	resultbox:ShowWindow(0)

	local slot = GET_CHILD_RECURSIVELY(frame, 'slot', 'ui::CSlot')
	slot:ClearIcon()

	local slot_bg_image = GET_CHILD_RECURSIVELY(frame, 'slot_bg_image')
	slot_bg_image:ShowWindow(1)

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

	local costBox = GET_CHILD_RECURSIVELY(frame, 'costBox')
	if index == 2 then
		costBox:ShowWindow(1)
		DECOMPOSE_MANAGER_COST_UPDATE(frame, index)
	else
		costBox:ShowWindow(0)
	end
end

function DECOMPOSE_MANAGER_DROP_TARGET(parent, ctrl)
	local liftIcon = ui.GetLiftIcon()
	local fromFrame = liftIcon:GetTopParentFrame()
	if fromFrame:GetName() == 'inventory' then
		local iconInfo = liftIcon:GetInfo()
		local frame = parent:GetTopParentFrame()
		DECOMPOSE_MANAGER_SET_TARGET(frame, iconInfo:GetIESID())
	end
end

function DECOMPOSE_MANAGER_INV_RBTN(itemObj, slot)
	local frame = ui.GetFrame('decompose_manager')

	local icon = slot:GetIcon()
	local iconInfo = icon:GetInfo()
	local invItem = GET_PC_ITEM_BY_GUID(iconInfo:GetIESID())
	if invItem == nil then
		return
	end
	
	DECOMPOSE_MANAGER_SET_TARGET(frame, iconInfo:GetIESID())
end

function _COST_ITEM_UPDATE(frame)
	local pc = GetMyPCObject()
	if pc == nil then
		return
	end

	local slot = GET_CHILD_RECURSIVELY(frame, 'slot')
	local itemNameText = GET_CHILD_RECURSIVELY(frame, 'itemNameText')
	local itemSlot = GET_CHILD_RECURSIVELY(frame, 'itemSlot')
	local cost_count = GET_CHILD_RECURSIVELY(frame, 'cost_count')

	local item = GET_SLOT_ITEM(slot)
	if item == nil then
		itemNameText:ShowWindow(0)
		itemSlot:ShowWindow(0)
		cost_count:ShowWindow(0)
	else
		itemNameText:ShowWindow(1)
		itemSlot:ShowWindow(1)
		cost_count:ShowWindow(1)

		local name, count = GET_LEGEND_MISC_DECOMPOSE_COST()
		local costItem = GetClass('Item', name)
		if costItem ~= nil then
			itemNameText:SetTextByKey('name', dic.getTranslatedStr(TryGetProp(costItem, 'Name', 'None')))
			SET_SLOT_ICON(itemSlot, TryGetProp(costItem, 'TooltipImage', 'None'))

			local curCount = GetInvItemCount(pc, name)
			local color = nil
			if curCount < count then
				color = '{#EE0000}'
			end

			cost_count:SetTextByKey('color', color)
			cost_count:SetTextByKey('curCount', curCount)
			cost_count:SetTextByKey('needCount', count)
		end
	end
end

function _COST_MONEY_UPDATE(frame)
	local pc = GetMyPCObject()
	if pc == nil then
		return
	end

	local slot = GET_CHILD_RECURSIVELY(frame, 'slot')
	local itemNameText = GET_CHILD_RECURSIVELY(frame, 'itemNameText')
	local costStaticText = GET_CHILD_RECURSIVELY(frame, 'costStaticText')
	local priceText = GET_CHILD_RECURSIVELY(frame, 'priceText')
	
	local item = GET_SLOT_ITEM(slot)
	if item == nil then
		itemNameText:ShowWindow(0)
		costStaticText:ShowWindow(0)
		priceText:ShowWindow(0)
	else
		itemNameText:ShowWindow(1)
		costStaticText:ShowWindow(1)
		priceText:ShowWindow(1)

		local money = GetClass('Item', MONEY_NAME)
		itemNameText:SetTextByKey('name', dic.getTranslatedStr(TryGetProp(money, 'Name', 'None')))
		local cost = GET_ACC_EP12_DECOMPOSE_COST()
		priceText:SetTextByKey('price', GET_COMMAED_STRING(cost))
	end
end

function DECOMPOSE_MANAGER_COST_UPDATE(frame, index)
	if index < 2 then
		return
	end

	local itemSlot = GET_CHILD_RECURSIVELY(frame, 'itemSlot')
	local cost_count = GET_CHILD_RECURSIVELY(frame, 'cost_count')
	local costStaticText = GET_CHILD_RECURSIVELY(frame, 'costStaticText')
	local priceText = GET_CHILD_RECURSIVELY(frame, 'priceText')
	if index == 2 then
		costStaticText:ShowWindow(0)
		priceText:ShowWindow(0)
		_COST_ITEM_UPDATE(frame)
	elseif index == 3 then
		itemSlot:ShowWindow(0)
		cost_count:ShowWindow(0)
		_COST_MONEY_UPDATE(frame)
	end
end

function _CHECK_DECOMPOSABLE_ARK(itemObj)
	local flag, clmsg = IS_DECOMPOSABLE_ARK(itemObj)
	if clmsg ~= nil and clmsg ~= 'None' then
		ui.SysMsg(ClMsg(clmsg))
	end

	return flag
end

function _CHECK_DECOMPOSABLE_EVIL(itemObj)
	if CAN_DECOMPOSE_EVIL_GODDESS_ITEM(itemObj) == false then
		ui.SysMsg(ClMsg('decomposeCant'))
		return false
	end

	return true
end

function _CHECK_DECOMPOSABLE_UNIQUE(itemObj)
	if ENABLE_DECOMPOSE_EVIL_GODDESS_ITEM(itemObj) == false then
		ui.SysMsg(ClMsg('decomposeCant'))
		return false
	end

	return true
end

function _CHECK_DECOMPOSABLE_LEGEND_MISC(itemObj)
	if IS_DECOMPOSABLE_LEGEND_MISC(itemObj) == false then
		ui.SysMsg(ClMsg('decomposeCant'))
		return false
	end

	return true
end

function _CHECK_DECOMPOSABLE_ACC_EP12(itemObj)
	local ret, msg = IS_DECOMPOSABLE_ACC_EP12(itemObj)

	if ret == false then
		ui.SysMsg(ClMsg(msg))
		return false
	end

	return true
end

function _CHECK_DECOMPOSABLE_VIBORA(itemObj)
	local ret, msg = IS_DECOMPOSABLE_VIBORA(itemObj)
	if ret == false then
		if msg ~= 'None' then
			ui.SysMsg(ClMsg(msg))
		else
			ui.SysMsg(ClMsg('decomposeCant'))
		end
		return false
	end

	return true
end

function _CHECK_COST_ITEM()
	local pc = GetMyPCObject()
	if pc == nil then
		return false
	end

	local name, count = GET_LEGEND_MISC_DECOMPOSE_COST()
	local cost_item = session.GetInvItemByName(name)
	if cost_item == nil then
		ui.SysMsg(ClMsg('NotEnoughRecipe'))
		return false
	end

	local curCount = GetInvItemCount(pc, name)
	if curCount < count then
		ui.SysMsg(ClMsg('NotEnoughRecipe'))
		return false
	end

	if cost_item.isLockState == true then
		ui.SysMsg(ClMsg('MaterialItemIsLock'))
		return
	end
end

function _CHECK_COST_MONEY()
	local cost_money = GET_ACC_EP12_DECOMPOSE_COST()

	local money = 0
	local money_item = session.GetInvItemByName(MONEY_NAME)
	if money_item ~= nil then
		money = tonumber(money_item:GetAmountStr())
	end

	if money < cost_money then
		ui.SysMsg(ClMsg('NotEnoughMoney'))
		return false
	end
end

function DECOMPOSE_MANAGER_SET_TARGET(frame, itemGuid)
	local invItem = session.GetInvItemByGuid(itemGuid)
	if invItem == nil then
		return
	end

	if invItem.isLockState == true then
		ui.SysMsg(ClMsg('MaterialItemIsLock'))
		return
	end
	
	local tab = GET_CHILD_RECURSIVELY(frame, 'type_Tab')
	local index = tab:GetSelectItemIndex()	
	local checkScp = 'None'
	if index == 0 then
		checkScp = '_CHECK_DECOMPOSABLE_ARK'
	elseif index == 1 then
		checkScp = '_CHECK_DECOMPOSABLE_EVIL'
	elseif index == 2 then
		checkScp = '_CHECK_DECOMPOSABLE_LEGEND_MISC'
	elseif index == 3 then
		checkScp = '_CHECK_DECOMPOSABLE_ACC_EP12'
	elseif index == 4 then
		checkScp = '_CHECK_DECOMPOSABLE_VIBORA'
	else
		return
	end
	
	local itemObj = GetIES(invItem:GetObject())
	local func = _G[checkScp]
	if func(itemObj) == false then
		return
	end

	CLEAR_DECOMPOSE_MANAGER()
	
	local slot = GET_CHILD_RECURSIVELY(frame, "slot")
	SET_SLOT_ITEM(slot, invItem)

	local slot_bg_image = GET_CHILD_RECURSIVELY(frame, 'slot_bg_image')
	slot_bg_image:ShowWindow(0)

	local txt_puton = GET_CHILD_RECURSIVELY(frame, 'text_putonitem')
	txt_puton:ShowWindow(0)
	
	local item_name = GET_CHILD_RECURSIVELY(frame, 'text_itemname')
	item_name:SetText(dic.getTranslatedStr(TryGetProp(itemObj, 'Name', 'None')))

	frame:SetUserValue('TARGET_ITEM_GUID', itemGuid)
	
	if index == 0 then
		DRAW_RESULT_DECOMPOSITION_ARK(frame)
	elseif index == 1 then
		DRAW_RESULT_DECOMPOSITION_EVIL(frame)
	elseif index == 3 then
		DRAW_RESULT_DECOMPOSITION_ACC(frame)
	elseif index == 4 then
		DRAW_RESULT_DECOMPOSITION_VIBORA(frame)
	end

	DECOMPOSE_MANAGER_COST_UPDATE(frame, index)
end

function DECOMPOSE_MANAGER_EXECUTE(parent, ctrl)
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
	
	local tab = GET_CHILD_RECURSIVELY(frame, 'type_Tab')
	local index = tab:GetSelectItemIndex()
	local checkScp = 'None'
	if index == 0 then
		checkScp = '_CHECK_DECOMPOSABLE_ARK'
	elseif index == 1 then
		checkScp = '_CHECK_DECOMPOSABLE_EVIL'
	elseif index == 2 then
		checkScp = '_CHECK_DECOMPOSABLE_LEGEND_MISC'
	elseif index == 3 then
		checkScp = '_CHECK_DECOMPOSABLE_ACC_EP12'
	elseif index == 4 then
		checkScp = '_CHECK_DECOMPOSABLE_VIBORA'
	else
		return
	end
	
	local func = _G[checkScp]
	local targetObj = GetIES(targetItem:GetObject())
	if func(targetObj) == false then
		return
	end

	if index == 2 and _CHECK_COST_ITEM() == false then
		return
	end

	local yesScp = string.format('_DECOMPOSE_MANAGER_EXECUTE("%s", %d)', targetGuid, index)
	ui.MsgBox(ScpArgMsg('ReallyDecomposeThisItem'), yesScp, 'None')
end

function _DECOMPOSE_MANAGER_EXECUTE(targetGuid, index)
	local frame = ui.GetFrame('decompose_manager')
	local itemGuid = frame:GetUserValue('TARGET_ITEM_GUID')
	if itemGuid == 'None' then
		return
	end

	local exec = 'None'
	if index == 0 then
		exec = 'ITEM_ARK_DECOMPOSE'
	elseif index == 1 then
		exec = 'ITEM_EVIL_DECOMPOSITION'
	elseif index == 2 then
		exec = 'ITEM_LEGEND_MISC_DECOMPOSE'
	elseif index == 3 then
		exec = 'ITEM_ACC_RETURN_ITEM'
	elseif index == 4 then
		exec = 'ITEM_VIBORA_DECOMPOSE'
	else
		return
	end
	
	if exec ~= 'None' then
		pc.ReqExecuteTx_Item(exec, itemGuid)
	end
end

function ON_RESULT_DECOMPOSE_MANAGER(frame, msg, argStr, argNum)
	if argStr == nil then
		return
	end

	local rewardList = StringSplit(argStr, ';')
	if #rewardList <= 0 or #rewardList > 2 then
		return
	end

	local slot = GET_CHILD_RECURSIVELY(frame, 'slot', 'ui::CSlot')
	slot:ClearIcon()

	local slot_bg_image = GET_CHILD_RECURSIVELY(frame, 'slot_bg_image')
	slot_bg_image:ShowWindow(1)
	
	local item_name = GET_CHILD_RECURSIVELY(frame, 'text_itemname')
	item_name:SetText('')
	
	local txt_complete = GET_CHILD_RECURSIVELY(frame, 'text_complete')
	txt_complete:ShowWindow(1)

	local resultbox = GET_CHILD_RECURSIVELY(frame, 'resultbox')
	resultbox:ShowWindow(1)

	for i = 1, #rewardList do
		local rewardStr = StringSplit(rewardList[i], '/')
		local rewardClassName = rewardStr[1]
		local rewardCount = rewardStr[2]
		local rewardCls = GetClass('Item', rewardClassName)
		if rewardCls ~= nil then
			local slot_result = GET_CHILD_RECURSIVELY(frame, 'result' .. i)
			if slot_result ~= nil then
				slot_result:ShowWindow(1)
				SET_SLOT_IMG(slot_result, rewardCls.Icon)
				SET_SLOT_COUNT(slot_result, rewardCount)
				SET_SLOT_COUNT_TEXT(slot_result, rewardCount)

				local text_result = GET_CHILD_RECURSIVELY(frame, 'text_result' .. i)
				local reward_name = dic.getTranslatedStr(rewardCls.Name)
				text_result:SetText(reward_name)
			end
		end
	end

	local execbutton = GET_CHILD_RECURSIVELY(frame, 'execbutton')
	execbutton:ShowWindow(0)

	local okbutton = GET_CHILD_RECURSIVELY(frame, 'okbutton')
	okbutton:ShowWindow(1)
end

function ON_RESULT_DECOMPOSE_VIBORA(frame, msg, argStr, argNum)	
	local slot = GET_CHILD_RECURSIVELY(frame, 'slot', 'ui::CSlot')
	slot:ClearIcon()

	local slot_bg_image = GET_CHILD_RECURSIVELY(frame, 'slot_bg_image')
	slot_bg_image:ShowWindow(1)
	
	local item_name = GET_CHILD_RECURSIVELY(frame, 'text_itemname')
	item_name:SetText('')
	
	local txt_complete = GET_CHILD_RECURSIVELY(frame, 'text_complete')
	txt_complete:ShowWindow(1)

	local execbutton = GET_CHILD_RECURSIVELY(frame, 'execbutton')
	execbutton:ShowWindow(0)

	local okbutton = GET_CHILD_RECURSIVELY(frame, 'okbutton')
	okbutton:ShowWindow(1)
end

function DRAW_RESULT_DECOMPOSITION_VIBORA(frame)
	local targetGuid = frame:GetUserValue('TARGET_ITEM_GUID')
	
	if targetGuid == "None" then
		return
	end
	
	local targetItem = session.GetInvItemByGuid(targetGuid)	
	if targetItem == nil then
		return
	end
	
	local resultbox = GET_CHILD_RECURSIVELY(frame, 'resultbox')
	resultbox:ShowWindow(1)

	local item = GetIES(targetItem:GetObject())
	local dic_item = GET_FINAL_VIBORA_DECOMPOSITION_MATERIAL(item)
	
	local idx = 1
	for k, v in pairs(dic_item) do
		local rewardClassName = k
		local rewardCount = v
		local rewardCls = GetClass('Item', rewardClassName)
		if rewardCls ~= nil then
			local slot_result = GET_CHILD_RECURSIVELY(frame, 'result' .. idx)
			if slot_result ~= nil then
				slot_result:ShowWindow(1)
				SET_SLOT_IMG(slot_result, rewardCls.Icon)
				SET_SLOT_COUNT(slot_result, rewardCount)
				
				if rewardClassName == 'Vis' then
					SET_SLOT_COUNT_TEXT(slot_result, '')
				else
					SET_SLOT_COUNT_TEXT(slot_result, rewardCount)
				end

				local text_result = GET_CHILD_RECURSIVELY(frame, 'text_result' .. idx)
				local reward_name = dic.getTranslatedStr(rewardCls.Name)
				if rewardClassName == 'Vis' then
					reward_name = reward_name .. ' (' .. GET_COMMAED_STRING(rewardCount) .. ')'
				end
				text_result:SetText(reward_name)
			end
			idx = idx + 1
		end
	end
end

function DRAW_RESULT_DECOMPOSITION_EVIL(frame)
	local targetGuid = frame:GetUserValue('TARGET_ITEM_GUID')
	
	if targetGuid == "None" then
		return
	end
	
	local targetItem = session.GetInvItemByGuid(targetGuid)	
	if targetItem == nil then
		return
	end
	
	local resultbox = GET_CHILD_RECURSIVELY(frame, 'resultbox')
	resultbox:ShowWindow(1)

	local item = GetIES(targetItem:GetObject())
	local dic_item = GET_FINAL_EVIL_DECOMPOSITION_MATERIAL(item)
	
	local idx = 1
	for k, v in pairs(dic_item) do
		local rewardClassName = k
		local rewardCount = v
		local rewardCls = GetClass('Item', rewardClassName)
		if rewardCls ~= nil then
			local slot_result = GET_CHILD_RECURSIVELY(frame, 'result' .. idx)
			if slot_result ~= nil then
				slot_result:ShowWindow(1)
				SET_SLOT_IMG(slot_result, rewardCls.Icon)
				SET_SLOT_COUNT(slot_result, rewardCount)
				
				if rewardClassName == 'Vis' then
					SET_SLOT_COUNT_TEXT(slot_result, '')					
				else
					SET_SLOT_COUNT_TEXT(slot_result, rewardCount)
				end

				local text_result = GET_CHILD_RECURSIVELY(frame, 'text_result' .. idx)
				local reward_name = dic.getTranslatedStr(rewardCls.Name)
				if rewardClassName == 'Vis' then
					reward_name = reward_name .. ' (' .. GET_COMMAED_STRING(rewardCount) .. ')'
				end

				text_result:SetText(reward_name)
			end
			idx = idx + 1
		end
	end
end

function DRAW_RESULT_DECOMPOSITION_ACC(frame)
	local targetGuid = frame:GetUserValue('TARGET_ITEM_GUID')
	
	if targetGuid == "None" then
		return
	end
	
	local targetItem = session.GetInvItemByGuid(targetGuid)	
	if targetItem == nil then
		return
	end
	
	local resultbox = GET_CHILD_RECURSIVELY(frame, 'resultbox')
	resultbox:ShowWindow(1)

	local item = GetIES(targetItem:GetObject())
	local dic_item = GET_FINAL_LUCIFERI_RETURN_LIST(item)
	
	local idx = 1
	for k, v in pairs(dic_item) do
		local rewardClassName = k
		local rewardCount = v
		local rewardCls = GetClass('Item', rewardClassName)
		if rewardCls ~= nil then
			local slot_result = GET_CHILD_RECURSIVELY(frame, 'result' .. idx)
			if slot_result ~= nil then
				slot_result:ShowWindow(1)
				SET_SLOT_IMG(slot_result, rewardCls.Icon)
				SET_SLOT_COUNT(slot_result, rewardCount)
				
				if rewardClassName == 'Vis' then
					SET_SLOT_COUNT_TEXT(slot_result, 0)					
				else
					SET_SLOT_COUNT_TEXT(slot_result, rewardCount)
				end

				local text_result = GET_CHILD_RECURSIVELY(frame, 'text_result' .. idx)
				local reward_name = dic.getTranslatedStr(rewardCls.Name)
				if rewardClassName == 'Vis' then
					reward_name = reward_name .. ' (' .. GET_COMMAED_STRING(rewardCount) .. ')'
				end

				text_result:SetText(reward_name)
			end
			idx = idx + 1
		end
	end
end

function DRAW_RESULT_DECOMPOSITION_ARK(frame)
	local targetGuid = frame:GetUserValue('TARGET_ITEM_GUID')
	
	if targetGuid == "None" then
		return
	end
	
	local targetItem = session.GetInvItemByGuid(targetGuid)	
	if targetItem == nil then
		return
	end
	
	local resultbox = GET_CHILD_RECURSIVELY(frame, 'resultbox')
	resultbox:ShowWindow(1)

	local item = GetIES(targetItem:GetObject())
	local dic_item = {}
	if TryGetProp(item, 'StringArg2', 'None') == 'Made_Ark' then
		dic_item = shared_item_ark.get_final_return_ark_material_list(item)
	elseif TryGetProp(item, 'StringArg2', 'None') == 'Quest_Ark' then
		dic_item = shared_item_ark.get_final_return_exp(item)
	end
	
	local idx = 1
	for k, v in pairs(dic_item) do
		local rewardClassName = k
		local rewardCount = v
		local rewardCls = GetClass('Item', rewardClassName)
		if rewardCls ~= nil then
			local slot_result = GET_CHILD_RECURSIVELY(frame, 'result' .. idx)
			if slot_result ~= nil then
				slot_result:ShowWindow(1)
				SET_SLOT_IMG(slot_result, rewardCls.Icon)
				SET_SLOT_COUNT(slot_result, rewardCount)
				
				if rewardClassName == 'Vis' then
					SET_SLOT_COUNT_TEXT(slot_result, '')
				else
					SET_SLOT_COUNT_TEXT(slot_result, rewardCount)
				end

				local text_result = GET_CHILD_RECURSIVELY(frame, 'text_result' .. idx)
				local reward_name = dic.getTranslatedStr(rewardCls.Name)
				if rewardClassName == 'Vis' then
					reward_name = reward_name .. ' (' .. GET_COMMAED_STRING(rewardCount) .. ')'
				end

				text_result:SetText(reward_name)
			end
			idx = idx + 1
		end
	end

end