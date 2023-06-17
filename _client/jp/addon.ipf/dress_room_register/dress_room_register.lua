-- 신비한 돋보기
function DRESS_ROOM_REGISTER_ON_INIT(addon, frame)
	addon:RegisterMsg('DRESS_ROOM_SET', 'ON_DRESS_ROOM_REGISTER_COMPLETE')
end

function DRESS_ROOM_REGISTER_OPEN(frame)
	INVENTORY_SET_CUSTOM_RBTNDOWN('DRESS_ROOM_REGISTER_INV_RBTN')
end

function DRESS_ROOM_REGISTER_RESET(frame)
	local slot = GET_CHILD_RECURSIVELY(frame, 'slot')
	slot:ClearIcon()
end

function DRESS_ROOM_REGISTER_CLOSE(frame)
	DRESS_ROOM_REGISTER_RESET(frame)
	INVENTORY_SET_CUSTOM_RBTNDOWN('None')
end

function DRESS_ROOM_REGISTER_INIT(frame)
	DRESS_ROOM_REGISTER_RESET(frame)

	local dress_cls = GetClassByType('dress_room', frame:GetUserIValue('DRESS_CLS_ID'))
	if dress_cls == nil then
		ui.CloseFrame('dress_room_register')
		return
	end

	local item_cls = GetClass('Item', TryGetProp(dress_cls, 'ItemClassName', 'None'))
	if item_cls == nil then
		ui.CloseFrame('dress_room_register')
		return
	end

	local text_itemname = GET_CHILD_RECURSIVELY(frame, 'text_itemname')
	text_itemname:SetText(dic.getTranslatedStr(TryGetProp(item_cls, 'Name', 'None')))
end

function OPEN_DRESS_ROOM_REGISTER(parent, btn, arg_str, arg_num)
	local reward_cls = GetClassByType('dress_room', arg_num)
	if reward_cls == nil then return end

	ui.OpenFrame('dress_room_register')

	local frame = ui.GetFrame('dress_room_register')
	frame:SetUserValue('DRESS_CLS_ID', arg_num)
	DRESS_ROOM_REGISTER_INIT(frame)
end

function DRESS_ROOM_REGISTER_INV_RBTN(item_obj, slot)
	local frame = ui.GetFrame('dress_room_register')
	if frame == nil then return end

	local icon = slot:GetIcon()
    local icon_info = icon:GetInfo()
	local guid = icon_info:GetIESID()
	
    local inv_item = session.GetInvItemByGuid(guid)
	if inv_item == nil then return end

	local item_obj = GetIES(inv_item:GetObject())
	if item_obj == nil then return end

	DRESS_ROOM_REGISTER_SLOT_ITEM(frame, inv_item, item_obj)
end

function DRESS_ROOM_REGISTER_INV_ITEM_DROP(slot, icon, argStr, argNum)
	if ui.CheckHoldedUI() == true then return end

	local frame = slot:GetTopParentFrame()
	if frame == nil then return end

	local lift_icon = ui.GetLiftIcon()
	local from_frame = lift_icon:GetTopParentFrame()
    if from_frame:GetName() == 'inventory' then
        local icon_info = lift_icon:GetInfo()
        local guid = icon_info:GetIESID()
        local inv_item = session.GetInvItemByGuid(guid)
		if inv_item == nil then return end
		
		local item_obj = GetIES(inv_item:GetObject())
		if item_obj == nil then return end

		DRESS_ROOM_REGISTER_SLOT_ITEM(frame, inv_item, item_obj)
	end
end

function DRESS_ROOM_REGISTER_SLOT_ITEM(frame, inv_item, item_obj)
	local dress_cls_id = frame:GetUserIValue('DRESS_CLS_ID')
	local dress_cls = GetClassByType('dress_room', dress_cls_id)
	if dress_cls == nil then return end

	local item_cls_name = TryGetProp(dress_cls, 'ItemClassName', 'None')
	local item_name = TryGetProp(item_obj, 'ClassName', 'None')
	if item_cls_name ~= item_name then
		ui.SysMsg(ClMsg('NotValidItem'))
		return
	end

	local able, msgtxt = IS_REGISTER_ENABLE_COSTUME(item_obj)
	if able == false then
		if msgtxt ~= nil then
			ui.SysMsg(ClMsg(msgtxt))
		end
		return
	end

	local slot = GET_CHILD_RECURSIVELY(frame, 'slot')
	SET_SLOT_ITEM(slot, inv_item)
end

function DRESS_ROOM_REGISTER_SLOT_REMOVE(parent, ctrl, arg_str, arg_num)
	if ui.CheckHoldedUI() == true then
		return
	end

	local frame = parent:GetTopParentFrame()
	DRESS_ROOM_REGISTER_RESET(frame)
end

function DRESS_ROOM_REGISTER_REG_COSTUME(parent, btn, arg_str, arg_num)
	local frame = parent:GetTopParentFrame()
	if frame == nil then return end

	local slot = GET_CHILD_RECURSIVELY(frame, 'slot')
	local inv_item = GET_SLOT_ITEM(slot)
	if inv_item == nil then
		ui.SysMsg(ClMsg('RegisterCostumeItemFirst'))
		return
	end

	local item_obj = GetIES(inv_item:GetObject())
	local able, msgtxt = IS_REGISTER_ENABLE_COSTUME(item_obj)
	if able == false then
		if msgtxt ~= nil then
			ui.SysMsg(ClMsg(msgtxt))
		end
		return
	end

	local msg = ScpArgMsg('ReallyRegisterCostume{item}', 'item', dic.getTranslatedStr(TryGetProp(item_obj, 'Name', 'None')))
	local yes_scp = '_DRESS_ROOM_REGISTER_REG_COSTUME()'
	local msgbox = ui.MsgBox(msg, yes_scp, 'None')
	SET_MODAL_MSGBOX(msgbox)
end

function _DRESS_ROOM_REGISTER_REG_COSTUME()
	local frame = ui.GetFrame('dress_room_register')
	if frame == nil then return end

	local dress_cls_id = frame:GetUserIValue('DRESS_CLS_ID')
	local dress_cls = GetClassByType('dress_room', dress_cls_id)
	if dress_cls == nil then return end

	local slot = GET_CHILD_RECURSIVELY(frame, 'slot')
	local inv_item = GET_SLOT_ITEM(slot)
	if inv_item == nil then return end

	pc.ReqExecuteTx_Item('REGISTER_DRESS_ROOM_ITEM', inv_item:GetIESID(), tostring(dress_cls_id))
end

function ON_DRESS_ROOM_REGISTER_COMPLETE(frame, msg, arg_str, arg_num)
	print('????')
	ui.CloseFrame('dress_room_register')
end