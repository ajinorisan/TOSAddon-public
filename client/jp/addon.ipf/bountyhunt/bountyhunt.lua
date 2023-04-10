function BOUNTYHUNT_ON_INIT(addon, frame)
	addon:RegisterMsg('BOUNTYHUNT_OPEN', 'ON_BOUNTYHUNT_OPEN');
	addon:RegisterMsg('BOUNTYHUNT_CLOSE', 'ON_BOUNTYHUNT_CLOSE');
end

function ON_BOUNTYHUNT_OPEN(frame, msg, argStr, argNum)
	local bountyhunt = ui.GetFrame('bountyhunt')
	bountyhunt:ShowWindow(1)
	if argNum ~= nil then
		bountyhunt:SetUserValue("MSG_BOX_CHECK_FLAG", argNum);
	end
end


function OPEN_BOUNTY_HUNT(frame)
	ui.OpenFrame('inventory')
	BOUNTYHUNT_INIT(frame)
	INVENTORY_SET_CUSTOM_RBTNDOWN('BOUNTYHUNT_INVENTORY_RBTN_CLICK')
end

function CLOSE_BOUNTY_HUNT(frame)
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
		local str = SCR_STRING_CUT(TryGetProp(targetItemObj, "StringArg", "None"), '/')
		if session.GetMapName() == str[1] then
			SET_SLOT_ITEM(slot, targetItem);
			text_itemname:SetText(targetItemObj.Name);
			slot_bg_image:ShowWindow(0);
			text_putonitem:ShowWindow(0);
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

function BOUNTYHUNT_INIT(frame)
	if ui.CheckHoldedUI() == true then
		return;
	end
	frame = frame:GetTopParentFrame();
	SET_TARGET_SLOT(frame, nil)
end

function BOUNTYHUNT_INVENTORY_RBTN_CLICK(itemObj, invSlot, invItemGuid)
	local frame = ui.GetFrame('bountyhunt');
	if invSlot:IsSelected() == 1 then
		BOUNTYHUNT_INIT(frame);
	else
		BOUNTYHUNT_REGISTER_ITEM(frame, invItemGuid);
	end
end

function BOUNTYHUNT_DROP_ITEM(parent, slot)
	if ui.CheckHoldedUI() == true then return; end
	local liftIcon = ui.GetLiftIcon();
	local fromFrame = liftIcon:GetTopParentFrame();
	local toFrame = parent:GetTopParentFrame();
	if fromFrame:GetName() == 'inventory' then
		local iconInfo = liftIcon:GetInfo();
		BOUNTYHUNT_REGISTER_ITEM(toFrame, iconInfo:GetIESID());
	end
end

function BOUNTYHUNT_REGISTER_ITEM(frame, invItemID)
	if ui.CheckHoldedUI() == true then return; end
	local targetItem = session.GetInvItemByGuid(invItemID);
	SET_TARGET_SLOT(frame, targetItem);
end

function BOUNTYHUNT_EXECUTE(parent, ctrl)
	local frame = parent:GetTopParentFrame();
	local slot = GET_CHILD_RECURSIVELY(frame, 'slot');
	local icon = slot:GetIcon();
	if icon == nil or icon:GetInfo() == nil then
		ui.SysMsg(ClMsg('NotExistTargetItem'));
		return;
	end

	local bounty_item = GET_TARGET_SLOT_ITEM(frame);
	if bounty_item.isLockState == true then
		ui.SysMsg(ClMsg('MaterialItemIsLock'));
		return;
	end

	local targetItemID = icon:GetInfo():GetIESID();
	frame:SetUserValue('guid', targetItemID)
	local yesscp = string.format('_BOUNTYHUNT_EXECUTE("%s")', targetItemID)

	local msgBoxCheckFlag = frame:GetUserValue("MSG_BOX_CHECK_FLAG");
	local clMsg = 'ReallyUseContentsMultiple';

	local bounty_item_obj = GetIES(bounty_item:GetObject());
	local msgBox = ui.MsgBox(ScpArgMsg(clMsg, 'Name', TryGetProp(bounty_item_obj, 'Name', 'None')), yesscp, '');
	SET_MODAL_MSGBOX(msgBox);
end

function _BOUNTYHUNT_EXECUTE(targetItemID)	
	local frame = ui.GetFrame('bountyhunt')
	if frame:IsVisible() == 0 then
		return;
	end

	targetItemID = frame:GetUserValue('guid')

	local targetInvItem = session.GetInvItemByGuid(targetItemID)
	if targetInvItem == nil then
		ui.SysMsg(ClMsg('NotExistTargetItem'))
		BOUNTYHUNT_INIT(frame)
		return;
	end

	if targetInvItem.isLockState == true then
		ui.SysMsg(ClMsg('MaterialItemIsLock'))
		BOUNTYHUNT_INIT(frame)
		return;
	end

	local self = GetMyPCObject()
	if IsBuffApplied(self, "BountyHunt_BUFF") == "YES" then
		ui.SysMsg(ClMsg('AlreadyBountyHunt'))
		BOUNTYHUNT_INIT(frame)
		return
	end

	local argStr = targetItemID;
	CLOSE_BOUNTY_HUNT(frame)
	pc.ReqExecuteTx_Item("SCR_USE_BOUNTYHUNT_TICKET", argStr)
end

function ON_BOUNTYHUNT_CLOSE(frame, msg, argStr, argNum)
	local bountyhunt = ui.GetFrame('bountyhunt');
	bountyhunt:ShowWindow(0);
end