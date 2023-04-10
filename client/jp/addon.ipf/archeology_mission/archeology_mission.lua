function ARCHEOLOGY_MISSION_ON_INIT(addon, frame)
	addon:RegisterMsg('ARCHEOLOGY_MISSION_OPEN', 'ON_ARCHEOLOGY_MISSION_OPEN');
	addon:RegisterMsg('ARCHEOLOGY_MISSION_CLOSE', 'ON_ARCHEOLOGY_MISSION_CLOSE');
end

function ON_ARCHEOLOGY_MISSION_OPEN(frame, msg, argStr, argNum)
	frame:SetUserValue('lv', argNum)	
	local cost_item, cost_count = shared_archeology.get_cost(frame:GetUserIValue('lv'))
	
	local cls = GetClass('Item', cost_item)
	local desc_item = GET_CHILD_RECURSIVELY(frame, 'richtext_2')
	desc_item:SetTextByKey('value1', cls.Name)
	desc_item:SetTextByKey('value2', cost_count)

	frame:ShowWindow(1)
	if argNum ~= nil then
		frame:SetUserValue("MSG_BOX_CHECK_FLAG", argNum);
	end

	ARCHEOLOGY_MISSION_FIND_AND_REGISTER_ITEM(frame);
end


function OPEN_ARCHEOLOGY_MISSION(frame)	
	ui.OpenFrame('inventory')
	ARCHEOLOGY_MISSION_INIT(frame)
	INVENTORY_SET_CUSTOM_RBTNDOWN('ARCHEOLOGY_MISSION_INVENTORY_RBTN_CLICK')
end

function CLOSE_ARCHEOLOGY_MISSION(frame)
	frame:ShowWindow(0)
	ui.CloseFrame('inventory')
	INVENTORY_SET_CUSTOM_RBTNDOWN('None')
end

local function SET_TARGET_SLOT(frame, targetItem)
	local slot = GET_CHILD_RECURSIVELY(frame, 'slot');	
	local slot_bg_image = GET_CHILD_RECURSIVELY(frame, 'slot_bg_image');
	local text_putonitem = GET_CHILD_RECURSIVELY(frame, 'text_putonitem');
	local text_itemname = GET_CHILD_RECURSIVELY(frame, 'text_itemname');	

	if targetItem ~= nil then
		local targetItemObj = GetIES(targetItem:GetObject());
		local cost_name, cost_count = shared_archeology.get_cost(frame:GetUserIValue('lv'))
		local slot_item_name = TryGetProp(targetItemObj, "ClassName", "None")
		local now_count = session.GetInvItemCountByType(targetItemObj.ClassID)

		if cost_name == slot_item_name then
			if now_count >= cost_count then
				SET_SLOT_ITEM(slot, targetItem);
				text_itemname:SetText(targetItemObj.Name);
				slot_bg_image:ShowWindow(0);
				text_putonitem:ShowWindow(0);
			else
				ui.SysMsg(ClMsg('Auto_SuLyangi_BuJogHapNiDa.'))
				return
			end
		else
			ui.SysMsg(ClMsg('IMPOSSIBLE_ITEM'))
			return
		end

	else
		slot:ClearIcon();
		text_itemname:SetText('');
		slot_bg_image:ShowWindow(1);
		text_putonitem:ShowWindow(1);
	end
end

local function GET_TARGET_SLOT_ITEM(frame)
	local slot = GET_CHILD_RECURSIVELY(frame, 'slot');
	local icon = slot:GetIcon();
	if icon == nil then
		return nil;
	end

	local targetItem = session.GetInvItemByGuid(icon:GetInfo():GetIESID());
	if targetItem == nil then
		return nil;
	end
	return targetItem;
end

function ARCHEOLOGY_MISSION_INIT(frame)
	if ui.CheckHoldedUI() == true then
		return;
	end
	frame = frame:GetTopParentFrame();
	SET_TARGET_SLOT(frame, nil)
end

function ARCHEOLOGY_MISSION_INVENTORY_RBTN_CLICK(itemObj, invSlot, invItemGuid)
	local frame = ui.GetFrame('archeology_mission');
	if invSlot:IsSelected() == 1 then
		ARCHEOLOGY_MISSION_INIT(frame);
	else
		ARCHEOLOGY_MISSION_REGISTER_ITEM(frame, invItemGuid);
	end
end

function ARCHEOLOGY_MISSION_DROP_ITEM(parent, slot)
	if ui.CheckHoldedUI() == true then return; end
	local liftIcon = ui.GetLiftIcon();
	local fromFrame = liftIcon:GetTopParentFrame();
	local toFrame = parent:GetTopParentFrame();
	if fromFrame:GetName() == 'inventory' then
		local iconInfo = liftIcon:GetInfo();
		ARCHEOLOGY_MISSION_REGISTER_ITEM(toFrame, iconInfo:GetIESID());
	end
end

function ARCHEOLOGY_MISSION_SLOT_LBTN_CLICK(parent, ctrl)
	local frame = parent:GetTopParentFrame();
	ARCHEOLOGY_MISSION_FIND_AND_REGISTER_ITEM(frame);
end

function ARCHEOLOGY_MISSION_FIND_AND_REGISTER_ITEM(frame)
	local cost_name, cost_count = shared_archeology.get_cost(frame:GetUserIValue('lv'));
	local mat_item = session.GetInvItemByName(cost_name);
	if mat_item == nil or mat_item.count < cost_count then
		ui.SysMsg(ClMsg('Auto_SuLyangi_BuJogHapNiDa.'));
		ui.CloseFrame('archeology_mission');
		return;
	end

	ARCHEOLOGY_MISSION_REGISTER_ITEM(frame, mat_item:GetIESID());
end

function ARCHEOLOGY_MISSION_REGISTER_ITEM(frame, invItemID)
	if ui.CheckHoldedUI() == true then return; end	
	local targetItem = session.GetInvItemByGuid(invItemID);
	SET_TARGET_SLOT(frame, targetItem);
end

function ARCHEOLOGY_MISSION_EXECUTE(parent, ctrl)
	local frame = parent:GetTopParentFrame();
	local slot = GET_CHILD_RECURSIVELY(frame, 'slot');
	local icon = slot:GetIcon();
	if icon == nil or icon:GetInfo() == nil then
		ui.SysMsg(ClMsg('NotExistTargetItem'));
		return;
	end

	local archeologyy_item = GET_TARGET_SLOT_ITEM(frame);
	if archeologyy_item.isLockState == true then
		ui.SysMsg(ClMsg('MaterialItemIsLock'));
		return;
	end

	local targetItemID = icon:GetInfo():GetIESID();
	frame:SetUserValue('guid', targetItemID)

	local yesscp = string.format('_ARCHEOLOGY_MISSION_EXECUTE("%s")', targetItemID)

	local msgBoxCheckFlag = frame:GetUserValue("MSG_BOX_CHECK_FLAG");
	local clMsg = 'ReallyUseContentsMultiple';

	local archeologyy_item_obj = GetIES(archeologyy_item:GetObject());
	local msgBox = ui.MsgBox(ScpArgMsg(clMsg, 'Name', TryGetProp(archeologyy_item_obj, 'Name', 'None')), yesscp, '');
	SET_MODAL_MSGBOX(msgBox);
end

function _ARCHEOLOGY_MISSION_EXECUTE(targetItemID)
	local frame = ui.GetFrame('archeology_mission')
	if frame:IsVisible() == 0 then
		return;
	end

	local targetInvItem = session.GetInvItemByGuid(targetItemID)
	if targetInvItem == nil then
		ui.SysMsg(ClMsg('NotExistTargetItem'))
		ARCHEOLOGY_MISSION_INIT(frame)
		return;
	end

	if targetInvItem.isLockState == true then
		ui.SysMsg(ClMsg('MaterialItemIsLock'))
		ARCHEOLOGY_MISSION_INIT(frame)
		return;
	end

	local argStr = frame:GetUserValue('guid');
	local lv = frame:GetUserIValue('lv')

	CLOSE_ARCHEOLOGY_MISSION(frame)
	pc.ReqExecuteTx_Item("ACCEPT_ARCHEOLOGY_MISSION", argStr, lv)	
end

function ON_ARCHEOLOGY_MISSION_CLOSE(frame, msg, argStr, argNum)
	local ARCHEOLOGY_MISSION = ui.GetFrame('archeology_mission');
	ARCHEOLOGY_MISSION:ShowWindow(0);
end


function OPEN_ARCHEOLOGY_SHOP()
	local frame = ui.GetFrame('earthtowershop')
	if frame:IsVisible() == 1 then
		ui.CloseFrame('earthtowershop')
	end
	
    frame:SetUserValue("SHOP_TYPE", 'Archeology_Lv470');
    ui.OpenFrame('earthtowershop');
end