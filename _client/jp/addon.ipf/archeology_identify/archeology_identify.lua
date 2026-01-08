function ARCHEOLOGY_IDENTIFY_ON_INIT(addon, frame)
	addon:RegisterMsg('OPEN_DLG_ARCHEOLOGY_IDENTIFY', 'ON_OPEN_DLG_ARCHEOLOGY_IDENTIFY')
	addon:RegisterMsg('SUCCESS_ARCH_IDENTIFY', 'ON_SUCCESS_ARCH_IDENTIFY')
end

function OPEN_ARCHEOLOGY_IDENTIFY_UI()
	ui.OpenFrame('archeology_identify')
end

function ON_OPEN_DLG_ARCHEOLOGY_IDENTIFY(frame, msg, argStr, argNum)
	ARCHEOLOGY_IDENTIFY_UI_RESET()

	local invframe = ui.GetFrame('inventory')
	invframe:ShowWindow(1)

	local frame = ui.GetFrame('archeology_identify')
	frame:ShowWindow(1)

	INVENTORY_SET_CUSTOM_RBTNDOWN('ARCHEOLOGY_IDENTIFY_INV_RBTN')
end

function ON_SUCCESS_ARCH_IDENTIFY(frame, msg, argStr, argNum)
	--성공시 이펙트 재생
	local slot = GET_CHILD_RECURSIVELY(frame, "slot")
	local resultText = GET_CHILD_RECURSIVELY(frame, "resultText")
	slot:PlayUIEffect("I_sys_item_slot", 5.3, "Inventory_Exp_ORB", true);

	local results = GET_ARCHEOLOGY_OPTION_INFO(argStr)
	local txt = "";
	if results and #results > 0 then
		-- 옵션 합산
		for i, opt in ipairs(results) do
			local opt_str = GET_ARCHEOLOGY_STAT_DESC(opt.tag, opt.value)
			txt = txt..opt_str.."{nl}"
		end
	end
	
	resultText:SetTextByKey("option", txt)
	resultText:ShowWindow(1);
	--arc_prefix
end

function ARCHEOLOGY_IDENTIFY_UI_RESET()
	local frame = ui.GetFrame('archeology_identify')
	frame:SetUserValue('ITEM_GUID', 'None')

	local itemName = GET_CHILD_RECURSIVELY(frame, 'itemName')
	itemName:SetTextByKey('name', '')
	itemName:ShowWindow(0)

	local slot = GET_CHILD_RECURSIVELY(frame, 'slot')
	slot:ClearIcon()

	local resultText = GET_CHILD_RECURSIVELY(frame, 'resultText')
	resultText:ShowWindow(0)

	local identifyBtn = GET_CHILD_RECURSIVELY(frame, 'identifyBtn')
	identifyBtn:ShowWindow(1)

	INVENTORY_SET_CUSTOM_RBTNDOWN('ARCHEOLOGY_IDENTIFY_INV_RBTN')
end

function OPEN_ARCHEOLOGY_IDENTIFY(frame)
	ARCHEOLOGY_IDENTIFY_UI_RESET()
end

function CLOSE_ARCHEOLOGY_IDENTIFY(frame)
	ARCHEOLOGY_IDENTIFY_UI_RESET()

	local invframe = ui.GetFrame('inventory')
	INVENTORY_SET_CUSTOM_RBTNDOWN('None')

	invframe:ShowWindow(0)
end

function ARCHEOLOGY_IDENTIFY_ITEM_DROP(parent, ctrl)
	local frame	= parent:GetTopParentFrame()
	local liftIcon = ui.GetLiftIcon()
	local slot = tolua.cast(ctrl, 'ui::CSlot')
	local iconInfo = liftIcon:GetInfo()
	local invItem = GET_PC_ITEM_BY_GUID(iconInfo:GetIESID())
	local resultText = GET_CHILD_RECURSIVELY(frame, "resultText")
	resultText:ShowWindow(0)
	resultText:SetTextByKey("option", "")
	if nil == invItem then return end

	ARCHEOLOGY_IDENTIFY_REG_ITEM(slot, invItem)
end

function ARCHEOLOGY_IDENTIFY_INV_RBTN(itemObj, slot)
	local icon = slot:GetIcon()
	local iconInfo = icon:GetInfo()
	local invItem = GET_PC_ITEM_BY_GUID(iconInfo:GetIESID())
	
	local frame = ui.GetFrame('archeology_identify')
	local slot = GET_CHILD_RECURSIVELY(frame, 'slot')
	local resultText = GET_CHILD_RECURSIVELY(frame, "resultText")
	resultText:ShowWindow(0)
	resultText:SetTextByKey("option", "")

	if not invItem then
		return; 
	end

	ARCHEOLOGY_IDENTIFY_REG_ITEM(slot, invItem)
end

function ARCHEOLOGY_IDENTIFY_REG_ITEM(slot, invItem)
	if true == invItem.isLockState then
		ui.SysMsg(ClMsg('MaterialItemIsLock'))
		return
	end

	local clslist, cnt = GetClassList("archeology_exhibition_item");
	local obj = GetIES(invItem:GetObject())
	
	if TryGetProp(obj, 'Arc_Prefix', 'None') ~= 'None' then
		ui.SysMsg(ClMsg('DontUseItem'))
		return
	end

	local exhibition_item = GetClassByNameFromList(clslist, TryGetProp(obj, "ClassName", "None"))
	if exhibition_item == nil then
		ui.SysMsg(ClMsg('DontUseItem'))
		return
	end

	local frame = ui.GetFrame('archeology_identify')
	local guid = invItem:GetIESID()
	frame:SetUserValue('ITEM_GUID', guid)
	
	local slot = GET_CHILD_RECURSIVELY(frame, 'slot')
	SET_SLOT_ITEM_IMAGE(slot, invItem)
	
	local itemName = frame:GetChild('itemName')
	itemName:SetTextByKey('name', obj.Name)
	itemName:ShowWindow(1)
	
	-- local costText = GET_CHILD_RECURSIVELY(frame, 'costText')
	-- costText:ShowWindow(1)
	
	imcSound.PlaySoundEvent('inven_equip')
end

function ARCHEOLOGY_IDENTIFY_ITEM_REMOVE(parent, ctrl)
	ARCHEOLOGY_IDENTIFY_UI_RESET()
end

function ARCHEOLOGY_IDENTIFY_OK_BTN(parent, ctrl)
	local frame = parent:GetTopParentFrame()
	local guid = frame:GetUserValue('ITEM_GUID')
	if guid == 'None' or session.GetInvItemByGuid(guid) == nil then return end

	local yesscp = string.format('EXEC_ARCHEOLOGY_IDENTIFY(\'%s\')', guid)
	local msgbox = ui.MsgBox(ScpArgMsg("archeology_identify_check"), yesscp, 'None')
	SET_MODAL_MSGBOX(msgbox)
end

function EXEC_ARCHEOLOGY_IDENTIFY(guid)
	local frame = ui.GetFrame('archeology_identify')
	guid = frame:GetUserValue('ITEM_GUID')
	local invItem = session.GetInvItemByGuid(guid)

	if invItem == nil then return end

	local obj = GetIES(invItem:GetObject())
	if TryGetProp(obj, "Arc_Prefix", "None") == "None" then
		pc.ReqExecuteTx_Item("ARCHEOLOGY_IDENTIFY", guid)
	end
end
