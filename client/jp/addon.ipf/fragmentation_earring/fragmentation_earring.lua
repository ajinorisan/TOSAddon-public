function FRAGMENTATION_EARRING_ON_INIT(addon, frame)
    addon:RegisterMsg('FRAGMENTATION_EARRING_END', 'ON_FRAGMENTATION_EARRING_END');
end

function OPEN_FRAGMENTATION_EARRING(frame)
	frame = ui.GetFrame('fragmentation_earring')
	ui.OpenFrame('inventory')
	FRAGMENTATION_EARRING_INIT(frame)
	INVENTORY_SET_CUSTOM_RBTNDOWN('FRAGMENTATION_EARRING_RBTN_CLICK')
end

function CLOSE_FRAGMENTATION_EARRING(frame)
	frame:ShowWindow(0)
	INVENTORY_SET_CUSTOM_RBTNDOWN('None')
	
	local guid = frame:GetUserValue("ITEM_GUID")
	SELECT_INV_SLOT_BY_GUID(guid, 0)
	frame:SetUserValue("ITEM_GUID", 0)
end

local function SET_TARGET_SLOT(frame, targetItem)
	local slot = GET_CHILD_RECURSIVELY(frame, 'slot');
	local slot_bg_image = GET_CHILD_RECURSIVELY(frame, 'slot_bg_image');
	local text_putonitem = GET_CHILD_RECURSIVELY(frame, 'text_putonitem');
	local text_itemname = GET_CHILD_RECURSIVELY(frame, 'text_itemname');
	local text_desc = GET_CHILD_RECURSIVELY(frame, 'text_desc');
	if targetItem ~= nil then
		local targetItemObj = GetIES(targetItem:GetObject());
		local guid = targetItem:GetIESID()
		frame:SetUserValue("ITEM_GUID", guid)
		SET_SLOT_ITEM(slot, targetItem);
		SELECT_INV_SLOT_BY_GUID(guid, 1)

		text_itemname:SetText(targetItemObj.Name);
		if TryGetProp(targetItemObj, 'GroupName', 'None') == 'Earring' then
			text_desc:SetTextByKey('value', ScpArgMsg('ItemFragmentationMaxCount', 'count', shared_item_earring.get_fragmentation_count(targetItemObj)))
		elseif TryGetProp(targetItemObj, 'GroupName', 'None') == 'BELT' or 
			TryGetProp(targetItemObj, 'GroupName', 'None') == 'SHOULDER' or
			shared_item_goddess_icor.get_goddess_icor_grade(targetItemObj) > 0 then
			text_desc:SetTextByKey('value', ScpArgMsg('ItemFragmentationCount', 'count', shared_item_earring.get_fragmentation_count(targetItemObj)))
		elseif IS_RANDOM_OPTION_SKILL_GEM(targetItemObj) then
			text_desc:SetTextByKey('value', ScpArgMsg('ItemFragmentationCount', 'count', shared_item_earring.get_fragmentation_count(targetItemObj)))
		end
		text_desc:ShowWindow(1)
		slot_bg_image:ShowWindow(0);
		text_putonitem:ShowWindow(0);
	else
		local guid = frame:GetUserValue("ITEM_GUID")
		SELECT_INV_SLOT_BY_GUID(guid, 0)
		frame:SetUserValue("ITEM_GUID", 0)

		slot:ClearIcon();
		text_itemname:SetText('');
		text_desc:ShowWindow(0)
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

function FRAGMENTATION_EARRING_INIT(frame)
	if ui.CheckHoldedUI() == true then
		return;
	end
	frame = frame:GetTopParentFrame();
	SET_TARGET_SLOT(frame, nil)
end

function FRAGMENTATION_EARRING_RBTN_CLICK(itemObj, invSlot, invItemGuid)
	local frame = ui.GetFrame('fragmentation_earring');
	if invSlot:IsSelected() == 1 then
		FRAGMENTATION_EARRING_INIT(frame);
	else
		FRAGMENTATION_EARRING_REGISTER_ITEM(frame, invItemGuid);
	end
end

function FRAGMENTATION_EARRING_DROP_ITEM(parent, slot)
	if ui.CheckHoldedUI() == true then return; end
	local liftIcon = ui.GetLiftIcon();
	local fromFrame = liftIcon:GetTopParentFrame();
	local toFrame = parent:GetTopParentFrame();
	if fromFrame:GetName() == 'inventory' then
		local iconInfo = liftIcon:GetInfo();
		FRAGMENTATION_EARRING_REGISTER_ITEM(toFrame, iconInfo:GetIESID());
	end
end

function FRAGMENTATION_EARRING_REGISTER_ITEM(frame, invItemID)
	if ui.CheckHoldedUI() == true then return; end
	local targetItem = session.GetInvItemByGuid(invItemID);
	if targetItem == nil then return end
	if targetItem.isLockState == true then
        ui.SysMsg(ClMsg("MaterialItemIsLock"));
	end

	local itemObject = GetIES(targetItem:GetObject())
	if shared_item_earring.is_able_to_fragmetation(itemObject) == false then
		ui.SysMsg(ClMsg("IMPOSSIBLE_ITEM"))
		return
	end
	
	SET_TARGET_SLOT(frame, nil)
	SET_TARGET_SLOT(frame, targetItem);
end

function FRAGMENTATION_EARRING_EXECUTE(parent, ctrl)
	local frame = parent:GetTopParentFrame();
	local slot = GET_CHILD_RECURSIVELY(frame, 'slot');
	local icon = slot:GetIcon();
	if icon == nil or icon:GetInfo() == nil then
		ui.SysMsg(ClMsg('NotExistTargetItem'));
		return;
	end

	local item = GET_TARGET_SLOT_ITEM(frame);
	if item == nil then
		ui.SysMsg(ClMsg('NotExistTargetItem'));
		return
	end
	if item.isLockState == true then
		ui.SysMsg(ClMsg('MaterialItemIsLock'));
		return;
	end

	if frame:GetUserValue("ON_FRAGMENTATION") ~= "YES" then
		frame:SetUserValue("ON_FRAGMENTATION","YES")
		PLAY_FRAGMENTATION_EARRING_EFFECT()
		pc.ReqExecuteTx_Item("FRAGMENTATION_EARRING", item:GetIESID())
	end
end

function ON_FRAGMENTATION_EARRING_CLOSE(frame, msg, argStr, argNum)
	local frame = ui.GetFrame('fragmentation_earring');
	frame:ShowWindow(0);
end

function PLAY_FRAGMENTATION_EARRING_EFFECT()
	local frame = ui.GetFrame("fragmentation_earring");

	local effect_gb = GET_CHILD_RECURSIVELY(frame, 'effect_gb');
	effect_gb:ShowWindow(1);
    effect_gb:PlayUIEffect('UI_item_parts', 4.6, 'FRAGMENTATION_EARRING_EFFECT', true);
    
    ui.SetHoldUI(true);
    ReserveScript('RELEASE_FRAGMENTATION_EARRING_UI_HOLD()', 1);
end

function RELEASE_FRAGMENTATION_EARRING_UI_HOLD()
	local frame = ui.GetFrame("fragmentation_earring");

	local effect_gb = GET_CHILD_RECURSIVELY(frame, 'effect_gb');
	effect_gb:StopUIEffect('FRAGMENTATION_EARRING_EFFECT', true, 0);
    ui.SetHoldUI(false);
end

function ON_FRAGMENTATION_EARRING_END(frame)
	frame:SetUserValue("ON_FRAGMENTATION", "NO")
	FRAGMENTATION_EARRING_INIT(frame)
end