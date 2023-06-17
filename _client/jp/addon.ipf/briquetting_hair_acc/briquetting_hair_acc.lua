-- briquetting_hair_acc.lua
function BRIQUETTING_HAIR_ACC_ON_INIT(addon, frame)
	addon:RegisterMsg('SUCCESS_BRIQUETTING_HAIR_ACC', 'BRIQUETTING_HAIR_ACC_REFRESH_INVENTORY_ICON');
end

function BRIQUETTING_HAIR_ACC_UI_OPEN(frame)
	INVENTORY_SET_CUSTOM_RBTNDOWN('BRIQUETTING_HAIR_ACC_INVENTORY_RBTN_CLICK');
	BRIQUETTING_HAIR_ACC_UI_RESET(frame);
	
	local priceStaticText = GET_CHILD_RECURSIVELY(frame, "priceStaticText")
	ui.OpenFrame('inventory');
end

function BRIQUETTING_HAIR_ACC_UI_CLOSE()
	INVENTORY_SET_CUSTOM_RBTNDOWN('None');

	ui.CloseFrame('inventory');
	RESET_INVENTORY_ICON();
end

function REQ_BRIQUETTING_HAIR_ACC_UI_OPEN()
	local frame = ui.GetFrame('briquetting_hair_acc');
	ui.OpenFrame('briquetting_hair_acc');
end

function ON_BRIQUETTING_HAIR_ACC_UPDATE_COLONY_TAX_RATE_SET(frame)
	BRIQUETTING_HAIR_ACC_UI_RESET(frame);
	local priceStaticText = GET_CHILD_RECURSIVELY(frame, "priceStaticText")
end

function BRIQUETTING_HAIR_ACC_SLOT_POP(parent, ctrl)
	local frame = parent:GetTopParentFrame();
	BRIQUETTING_HAIR_ACC_UI_RESET(frame);
end

function BRIQUETTING_HAIR_ACC_SLOT_SET(richtxt, item)
	if nil == item then
		richtxt:SetTextByKey("guid", "");
		richtxt:SetTextByKey("itemtype", "");
		return;
	end
	richtxt:SetTextByKey("guid", item:GetIESID());
	richtxt:SetTextByKey("itemtype", item.type);
end

function BRIQUETTING_HAIR_ACC_SLOT_DROP(parent, ctrl)	
	local frame = parent:GetTopParentFrame();
	local invItem, invSlot = BRIQUETTING_HAIR_ACC_SLOT_ITEM(parent, ctrl);
	if nil == invItem or nil == ctrl or nil == invItem:GetObject() then
		return;
	end

	if true == invItem.isLockState then
		ui.SysMsg(ClMsg("MaterialItemIsLock"));
		return;
	end

	local invItemObj = GetIES(invItem:GetObject());
	if invItemObj == nil then
		return;
	end

	local slot = tolua.cast(ctrl, 'ui::CSlot');
	BRIQUETTING_HAIR_ACC_SET_TARGET_SLOT(frame, invItemObj, invSlot, slot, invItem:GetIESID());
end

function BRIQUETTING_HAIR_ACC_SET_TARGET_SLOT(frame, invItemObj, invSlot, targetSlot, invItemGuid)	
	local invItem = session.GetInvItemByGuid(invItemGuid);
	if invItem == nil then
		return;
	end

	if true == invItem.isLockState then
		ui.SysMsg(ClMsg("MaterialItemIsLock"));
		return;
	end

	if invItemObj.ItemLifeTimeOver > 0 then
		ui.SysMsg(ClMsg('CannotUseLifeTimeOverItem'));
		return;
	end

	local lookItem, lookItemGuid = BRIQUETTING_HAIR_ACC_GET_SLOT_ITEM_OBJECT(frame, 'look');
	if lookItemGuid == invItemGuid then
		return;
	end	
	if lookItem ~= nil and invItemObj.ClassType ~= lookItem.ClassType then
		ui.SysMsg(ClMsg('NeedSameHairAcc'));
		return;
	end

	if IS_VALID_BRIQUETTING_HAIR_ACC_TARGET_ITEM(invItemObj) == false then
		ui.SysMsg(ScpArgMsg('InvalidTargetFor{CONTENTS}', 'CONTENTS', ClMsg('Briquetting_Hair_Acc')));
		return;
	end

	if targetSlot:GetUserValue('SELECTED_INV_GUID') ~= 'None' then
		BRIQUETTING_HAIR_ACC_SELECT_INVENTORY_ITEM(targetSlot, 0);
	end

	BRIQUETTING_HAIR_ACC_SELECT_INVENTORY_ITEM(invSlot, 1);
	targetSlot:SetUserValue('SELECTED_INV_GUID', invItemGuid);
    
	-- 슬롯 박스에 이미지를 넣고	
	SET_SLOT_ITEM_IMAGE(targetSlot, invItem);
	local targetEmptyPic = GET_CHILD(targetSlot, 'targetEmptyPic');
	local staticInfoText = GET_CHILD_RECURSIVELY(frame, 'staticInfoText');
	targetEmptyPic:ShowWindow(0);	
	staticInfoText:ShowWindow(0);

	local bodyGBox = frame:GetChild("bodyGbox");
	local slotNametext = bodyGBox:GetChild("slotName");

	-- 이름을 표시한다.
	slotNametext:SetTextByKey("txt", invItemObj.Name);
	BRIQUETTING_HAIR_ACC_SLOT_SET(slotNametext, invItem);

	INVENTORY_SET_ICON_SCRIPT('BRIQUETTING_HAIR_ACC_CHECK_LOOK_ICON_IN_INVENTORY');
end

function BRIQUETTING_HAIR_ACC_SELECT_INVENTORY_ITEM(slot, isSelect)
	slot = AUTO_CAST(slot);
	if isSelect == 1 then
		slot:SetSelectedImage('socket_slot_check');
		slot:Select(1);
	else
		local guid = slot:GetUserValue('SELECTED_INV_GUID');
		if guid == 'None' then
			return;
		end
		SELECT_INV_SLOT_BY_GUID(guid, 0);
	end
end

function BRIQUETTING_HAIR_ACC_SPEND_DROP(parent, ctrl)
	local invItem, invSlot = BRIQUETTING_HAIR_ACC_SLOT_ITEM(parent, ctrl);	
	local slot = tolua.cast(ctrl, 'ui::CSlot');
	if nil == invItem or nil == slot then
		return;
	end

	local obj = GetIES(invItem:GetObject());
	if nil == obj then 
		return;
	end

	BRIQUETTING_HAIR_ACC_SET_LOOK_ITEM(parent:GetTopParentFrame(), obj, invSlot, slot, invItem:GetIESID());
end

g_invSlot = nil;
function BRIQUETTING_HAIR_ACC_SET_LOOK_ITEM(frame, itemObj, invSlot, lookSlot, invItemGuid)
	local invItem = session.GetInvItemByGuid(invItemGuid);
	if invItem == nil then
		return;
	end

	if true == invItem.isLockState then
		ui.SysMsg(ClMsg("MaterialItemIsLock"));
		return;
	end

	if itemObj.ItemLifeTimeOver > 0 then
		ui.SysMsg(ClMsg('CannotUseLifeTimeOverItem'));
		return;
	end

	local targetItem, targetItemGuid = BRIQUETTING_HAIR_ACC_GET_SLOT_ITEM_OBJECT(frame, 'target');
	if targetItem == nil then
		ui.SysMsg(ClMsg('FirstRegisterTargetForBriquetting_HairAcc'));
		return;
	end

	if targetItemGuid == invItemGuid then
		return;
	end

	if targetItem ~= nil and targetItem.EqpType ~= itemObj.EqpType then
		ui.SysMsg(ClMsg('NeedSameHairAcc'));
		return;
	end

	g_invSlot = invSlot;

	_BRIQUETTING_HAIR_ACC_SET_LOOK_ITEM(invItemGuid);	
end

function _BRIQUETTING_HAIR_ACC_SET_LOOK_ITEM(invItemGuid)
	local invItem = session.GetInvItemByGuid(invItemGuid);
	if invItem == nil or invItem:GetObject() == nil or invItem.isLockState == true then
		return;
	end

	local itemObj = GetIES(invItem:GetObject());
	if itemObj == nil then
		return;
	end

	local frame = ui.GetFrame('briquetting_hair_acc');
	local lookSlot = GET_CHILD_RECURSIVELY(frame, 'lookSlot');
	if lookSlot:GetUserValue('SELECTED_INV_GUID') ~= 'None' then
		BRIQUETTING_HAIR_ACC_SELECT_INVENTORY_ITEM(lookSlot, 0);
	end

	local invSlot = g_invSlot;

	-- 슬롯 박스에 이미지를 넣고
	BRIQUETTING_HAIR_ACC_SELECT_INVENTORY_ITEM(invSlot, 1);	
	lookSlot:SetUserValue('SELECTED_INV_GUID', invItemGuid);

	SET_SLOT_ITEM_IMAGE(lookSlot, invItem);
	local slotNametext = GET_CHILD_RECURSIVELY(frame, "spendName");
	local matInfoText = GET_CHILD_RECURSIVELY(frame, 'matInfoText');
	matInfoText:ShowWindow(1);

	-- 이름을 표시한다.
	slotNametext:SetTextByKey("txt", itemObj.Name);
	BRIQUETTING_HAIR_ACC_SLOT_SET(slotNametext, invItem);
	BRIQUETTING_HAIR_ACC_INIT_LOOK_MATERIAL_LIST(frame, itemObj);
	
	INVENTORY_SET_ICON_SCRIPT('BRIQUETTING_HAIR_ACC_CHECK_LOOK_MATERIAL_ICON_IN_INVENTORY');
end

function BRIQUETTING_HAIR_ACC_GET_SLOT_ITEM_OBJECT(frame, type)
	local slot = GET_CHILD_RECURSIVELY(frame, type..'Slot');

	local icon = slot:GetIcon()
	if icon == nil then
		return nil;
	end
	
	local iconInfo = icon:GetInfo();

	local invItem = session.GetInvItemByGuid(iconInfo:GetIESID());
	if invItem == nil or invItem:GetObject() == nil then
		return nil;
	end

	return GetIES(invItem:GetObject()), invItem:GetIESID();
end

function BRIQUETTING_HAIR_ACC_SPEND_POP(parent, ctrl)
	local frame = parent:GetTopParentFrame();
	BRIQUETTING_HAIR_ACC_UI_RESET(frame);
end

function BRIQUETTING_HAIR_ACC_SLOT_ITEM(parent, ctrl)
	local frame = parent:GetTopParentFrame();
	local liftIcon = ui.GetLiftIcon();
	local iconInfo = liftIcon:GetInfo();
	local invItem = GET_PC_ITEM_BY_GUID(iconInfo:GetIESID());	
	if nil == invItem then
		return nil;
	end
	if true == invItem.isLockState then
		ui.SysMsg(ClMsg("MaterialItemIsLock"));
		return;
	end
	
	if nil == session.GetInvItemByType(invItem.type) then
		ui.SysMsg(ClMsg("CannotDropItem"));
		return nil;
	end
	
	if iconInfo == nil or invItem == nil then
		return nil;
	end
    
	return invItem, liftIcon:GetParent();
end

function BRIQUETTING_HAIR_ACC_UI_RESET(frame)
	local bodyGBox = frame:GetChild("bodyGbox");
	local slot = bodyGBox:GetChild("targetSlot");
	slot = tolua.cast(slot, 'ui::CSlot');
	slot:ClearIcon();

	local targetEmptyPic = GET_CHILD(slot, 'targetEmptyPic');
	local staticInfoText = GET_CHILD_RECURSIVELY(frame, 'staticInfoText');
	targetEmptyPic:ShowWindow(1);
	staticInfoText:ShowWindow(1);

	BRIQUETTING_HAIR_ACC_SELECT_INVENTORY_ITEM(slot, 0);
	
	local slotName = bodyGBox:GetChild("slotName");
	slotName:SetTextByKey("txt", "");
	BRIQUETTING_HAIR_ACC_SLOT_SET(slotName);

	local lookSlot = GET_CHILD_RECURSIVELY(frame, 'lookSlot');	
	BRIQUETTING_HAIR_ACC_SELECT_INVENTORY_ITEM(lookSlot, 0);
	INVENTORY_SET_ICON_SCRIPT('BRIQUETTING_HAIR_ACC_CHECK_TARGET_ICON_IN_INVENTORY');
	lookSlot:SetUserValue('SELECTED_INV_GUID', 'None');

	BRIQUETTING_HAIR_ACC_INIT_LOOK_MATERIAL_LIST(frame);
	BRIQUETTING_HAIR_ACC_UI_SPEND_RESET(frame);
end 

function BRIQUETTING_HAIR_ACC_UI_SPEND_RESET(frame)
	local slot = GET_CHILD_RECURSIVELY(frame, "lookSlot");
	slot = tolua.cast(slot, 'ui::CSlot');
	slot:ClearIcon();

	local slotNametext = GET_CHILD_RECURSIVELY(frame, "spendName");
	slotNametext:SetTextByKey("txt", "");
	BRIQUETTING_HAIR_ACC_SLOT_SET(slotNametext);

	frame:SetUserValue('SELECT', 'None');

	local matInfoText = GET_CHILD_RECURSIVELY(frame, 'matInfoText');
	matInfoText:ShowWindow(0);
end

function BRIQUETTING_HAIR_ACC_GET_LOOK_MATERIAL_LIST(frame)	
	local lookMatItemSlot = GET_CHILD_RECURSIVELY(frame, 'lookMatItemSlot');
	local material
	local materialGuid

	local slot = lookMatItemSlot:GetSlotByIndex(i);
	local guid = slot:GetUserValue('SELECTED_INV_GUID');
	if slot:IsVisible() == 1 and guid ~= 'None' then
		local invItem = session.GetInvItemByGuid(guid);
		if invItem ~= nil and invItem:GetObject() ~= nil then
			material = GetIES(invItem:GetObject());
			materialGuid = guid;
		else
			ui.SysMsg(ClMsg('InvalidItemRegisterStep'));
			ui.CloseFrame('briquetting_hair_acc');
			return nil, nil, false;
		end
	end

	return material, materialGuid, true;
end

function BRIQUETTING_HAIR_ACC_DROP_LOOK_MATERIAL_ITEM(parent, ctrl)
	local frame = parent:GetTopParentFrame();	
	local invItem, invSlot = BRIQUETTING_HAIR_ACC_SLOT_ITEM(parent, ctrl);
	if invItem == nil or invItem:GetObject() == nil then
		return;
	end

	local invItemObj = GetIES(invItem:GetObject());
	BRIQUETTING_HAIR_ACC_ADD_LOOK_MATERIAL_ITEM(frame, invItemObj, invSlot, invItem:GetIESID(), ctrl);
end

function BRIQUETTING_HAIR_ACC_ADD_LOOK_MATERIAL_ITEM(frame, invItemObj, invSlot, invItemGuid, lookMatSlot)		
	local invItem = session.GetInvItemByGuid(invItemGuid);
	if invItem == nil then
		return;
	end
	
	local targetItem = BRIQUETTING_HAIR_ACC_GET_SLOT_ITEM_OBJECT(frame, 'target');
	if targetItem == nil then
		ui.SysMsg(ClMsg('DropTargetItemFirst'));
		return;
	end

	local lookItem, lookItemGuid = BRIQUETTING_HAIR_ACC_GET_SLOT_ITEM_OBJECT(frame, 'look');
	if lookItem == nil then
		ui.SysMsg(ClMsg('DropLookItemFirst'));
		return;
	end

	if invItem.isLockState == true then
		ui.SysMsg(ClMsg('MaterialItemIsLock'));
		return;
	end

	if invItemObj.ItemLifeTimeOver > 0 then
		ui.SysMsg(ClMsg('CannotUseLifeTimeOverItem'));
		return;
	end
	
	if lookItemGuid == invItemGuid then
		ui.SysMsg(ClMsg('AlreadyEqualItemRegistered'));
		return;
	end
	
    local result = IS_VALID_LOOK_MATERIAL_ITEM_HARI_ACC(invItemObj);
	if result == false then		
		ui.SysMsg(ClMsg('WrongLookMaterialItem_HairAcc'));
		return;
	end

	g_invSlot = invSlot;
	
	_BRIQUETTING_HAIR_ACC_ADD_LOOK_MATERIAL_ITEM(lookMatSlot:GetName(), invItemGuid, containCoreItem);
end

function _BRIQUETTING_HAIR_ACC_ADD_LOOK_MATERIAL_ITEM(lookMatSlotName, invItemGuid, containCoreItem)
	local frame = ui.GetFrame('briquetting_hair_acc');
	local lookMatItemSlot = GET_CHILD_RECURSIVELY(frame, 'lookMatItemSlot');
	local lookMatSlot = GET_CHILD(lookMatItemSlot, lookMatSlotName);
	local invSlot = g_invSlot;
	local invItem = session.GetInvItemByGuid(invItemGuid);
	if invItem == nil or invItem:GetObject() == nil or invItem.isLockState == true then
		return;
	end

	if lookMatSlot:GetUserValue('SELECTED_INV_GUID') ~= 'None' then
		BRIQUETTING_HAIR_ACC_SELECT_INVENTORY_ITEM(lookMatSlot, 0);
	end

	BRIQUETTING_HAIR_ACC_SELECT_INVENTORY_ITEM(invSlot, 1);
	lookMatSlot:SetUserValue('SELECTED_INV_GUID', invItemGuid);

	if containCoreItem == true then
		BRIQUETTING_HAIR_ACC_SET_CORE_ITEM(frame, invItem);
		return;
	end

	SET_SLOT_ITEM_IMAGE(lookMatSlot, invItem);
	lookMatSlot:SetUserValue('SELECTED_INV_GUID', invItemGuid);
end

function BRIQUETTING_HAIR_ACC_SET_CORE_ITEM(frame, coreItem)
	local lookMatItemSlot = GET_CHILD_RECURSIVELY(frame, 'lookMatItemSlot');
	local firstSlot = lookMatItemSlot:GetSlotByIndex(0);
	BRIQUETTING_HAIR_ACC_SELECT_INVENTORY_ITEM(firstSlot, 0);
	SET_SLOT_ITEM_IMAGE(firstSlot, coreItem);
	firstSlot:SetUserValue('SELECTED_INV_GUID', coreItem:GetIESID());
	BRIQUETTING_HAIR_ACC_SELECT_INVENTORY_ITEM(g_invSlot, 1);

	local slot = lookMatItemSlot:GetSlotByIndex(1);
	BRIQUETTING_HAIR_ACC_SELECT_INVENTORY_ITEM(slot, 0);
	slot:SetUserValue('SELECTED_INV_GUID', 'None');
	slot:ClearIcon();
	slot:ShowWindow(0);		
end

function BRIQUETTING_HAIR_ACC_POP_LOOK_MATERIAL_ITEM(parent, ctrl)
	ctrl:ClearIcon();
	BRIQUETTING_HAIR_ACC_SELECT_INVENTORY_ITEM(ctrl, 0);
	ctrl:SetUserValue('SELECTED_INV_GUID', 'None');

	if parent ~= nil then
		local frame = parent:GetTopParentFrame();
		local lookItem, lookItemGuid = BRIQUETTING_HAIR_ACC_GET_SLOT_ITEM_OBJECT(frame, 'look');
		if lookItem ~= nil then
			BRIQUETTING_HAIR_ACC_INIT_LOOK_MATERIAL_LIST(frame, lookItem);
		end
	end
end

function BRIQUETTING_HAIR_ACC_EXCUTE(parent, ctrl)
	local frame = parent:GetTopParentFrame();
	local targetItem, targetItemGuid = BRIQUETTING_HAIR_ACC_GET_SLOT_ITEM_OBJECT(frame, 'target');
	if targetItem == nil then
		local targetSlot = GET_CHILD_RECURSIVELY(frame, 'targetSlot');
		if targetSlot:GetIcon() ~= nil then
			ui.SysMsg(ClMsg('InvalidItemRegisterStep'));
			ui.CloseFrame('briquetting_hair_acc');
		else
			ui.SysMsg(ClMsg('PleaseRegisterBriquettingTarget'));			
		end
		return;
	end

	local lookItem, lookItemGuid = BRIQUETTING_HAIR_ACC_GET_SLOT_ITEM_OBJECT(frame, 'look');
	if lookItem == nil then
		local lookSlot = GET_CHILD_RECURSIVELY(frame, 'lookSlot');
		if lookSlot:GetIcon() ~= nil then
			ui.SysMsg(ClMsg('InvalidItemRegisterStep'));
			ui.CloseFrame('briquetting_hair_acc');
		else
			ui.SysMsg(ClMsg('PleaseRegisterBriquettingLook'));
		end
		return;
	end

	local lookMatItemSlot = GET_CHILD_RECURSIVELY(frame, 'lookMatItemSlot');
	local slot = lookMatItemSlot:GetSlotByIndex(0);
	local lookMatItemicon = slot:GetIcon()
	if lookMatItemicon == nil then
		return
	end
	
	local lookMatItemiconInfo = lookMatItemicon:GetInfo();

	local invlookMatItem = session.GetInvItemByGuid(lookMatItemiconInfo:GetIESID());
	if invlookMatItem == nil or invlookMatItem:GetObject() == nil then
		return
	end

	local lookMatItem = GetIES(invlookMatItem:GetObject())
	local lookMatItemGuid = invlookMatItem:GetIESID()

	if lookMatItem == nil then
		local lookMatItemSlot = GET_CHILD_RECURSIVELY(frame, 'lookMatItemSlot');
		if lookMatItemicon ~= nil then
			ui.SysMsg(ClMsg('InvalidItemRegisterStep'));
			ui.CloseFrame('briquetting_hair_acc');
		else
			ui.SysMsg(ClMsg('PleaseRegisterBriquettingLook'));
		end
		return;
	end

	local result = IS_VALID_LOOK_MATERIAL_ITEM_HARI_ACC(lookMatItem);
	if result == false then
		ui.SysMsg(ClMsg('WrongLookMaterialItem_HairAcc'));
		return;
	end

	frame:SetUserValue('BRIQUETTING_HAIR_ACC_TARGET_GUID', targetItemGuid);
	frame:SetUserValue('BRIQUETTING_HAIR_ACC_LOOK_GUID', lookItemGuid);
	frame:SetUserValue('BRIQUETTING_HAIR_ACC_LOOK_MAT_GUID', lookMatItemGuid);
	local clmsg = ScpArgMsg('Briquetting_Hair_Acc_Result', 'BEFORE', targetItem.Name, 'AFTER', lookItem.Name);
	WARNINGMSGBOX_FRAME_OPEN(clmsg, 'IMPL_BRIQUETTING_HAIR_ACC_SKILL_EXCUTE', 'None');
end

function IMPL_BRIQUETTING_HAIR_ACC_SKILL_EXCUTE()
	local frame = ui.GetFrame('briquetting_hair_acc');
	_BRIQUETTING_HAIR_ACC_SKILL_EXCUTE(frame:GetUserValue('BRIQUETTING_HAIR_ACC_TARGET_GUID'), frame:GetUserValue('BRIQUETTING_HAIR_ACC_LOOK_GUID'), frame:GetUserValue('BRIQUETTING_HAIR_ACC_LOOK_MAT_GUID'));
end

function _BRIQUETTING_HAIR_ACC_SKILL_EXCUTE(targetItemGuid, lookItemGuid, lookMatItemGuid)
	
	session.ResetItemList();
	session.AddItemID(targetItemGuid);	
	session.AddItemID(lookItemGuid);	
	session.AddItemID(lookMatItemGuid);	

	ui.CloseFrame('briquetting_hair_acc');
	
	local resultlist = session.GetItemIDList();
	item.DialogTransaction('DO_BRIQUETTING_HAIR_ACC', resultlist)
end

function BRIQUETTING_HAIR_ACC_REFRESH_INVENTORY_ICON(frame, msg, guid, argNum)
	local inventory = ui.GetFrame('inventory');
	if inventory == nil or inventory:IsVisible() ~= 1 then
		return;
	end

    local invItem = session.GetInvItemByGuid(guid);
    if invItem == nil then
    	return;
    end

    local itemSlot = INV_GET_SLOT_BY_ITEMGUID(mainGuid, inventory);
	if itemSlot ~= nil then
		INV_SLOT_UPDATE(inventory, invItem, itemSlot);
	end	
end

function BRIQUETTING_HAIR_ACC_INIT_LOOK_MATERIAL_LIST(frame, lookItem)
	local needLookMatItemCnt = 0;
	if lookItem ~= nil then
		needLookMatItemCnt = 1	
	end

	local lookMatItemSlot = GET_CHILD_RECURSIVELY(frame, 'lookMatItemSlot');
	local slot = lookMatItemSlot:GetSlotByIndex(0);
	BRIQUETTING_HAIR_ACC_POP_LOOK_MATERIAL_ITEM(nil, slot);

	if 0 < needLookMatItemCnt then
		slot:ShowWindow(1);
	else
		slot:ShowWindow(0);
	end
	
	lookMatItemSlot:ClearIconAll();		
end

function BRIQUETTING_HAIR_ACC_INVENTORY_RBTN_CLICK(itemObj, invSlot, invItemGuid)
	local frame = ui.GetFrame('briquetting_hair_acc');
	if invSlot:IsSelected() == 1 then
		BRIQUETTING_HAIR_ACC_UI_RESET(frame);
	else
		if BRIQUETTING_HAIR_ACC_GET_SLOT_ITEM_OBJECT(frame, 'target') == nil then
			local targetSlot = GET_CHILD_RECURSIVELY(frame, 'targetSlot');
			BRIQUETTING_HAIR_ACC_SET_TARGET_SLOT(frame, itemObj, invSlot, targetSlot, invItemGuid);
		elseif BRIQUETTING_HAIR_ACC_GET_SLOT_ITEM_OBJECT(frame, 'look') == nil then
			local lookSlot = GET_CHILD_RECURSIVELY(frame, 'lookSlot');
			BRIQUETTING_HAIR_ACC_SET_LOOK_ITEM(frame, itemObj, invSlot, lookSlot, invItemGuid);
		else
			local lookMatSlot = GET_BRIQUETTING_HAIR_ACC_EMPTY_LOOK_MATERIAL_SLOT(frame);
			if lookMatSlot ~= nil then
				BRIQUETTING_HAIR_ACC_ADD_LOOK_MATERIAL_ITEM(frame, itemObj, invSlot, invItemGuid, lookMatSlot)
			end
		end
	end
end

function GET_BRIQUETTING_HAIR_ACC_EMPTY_LOOK_MATERIAL_SLOT(frame)
	local lookMatItemSlot = GET_CHILD_RECURSIVELY(frame, 'lookMatItemSlot');
	local slotCnt = lookMatItemSlot:GetSlotCount();
	local slot = lookMatItemSlot:GetSlotByIndex(0);
	local guid = slot:GetUserValue('SELECTED_INV_GUID');
	if slot:IsVisible() == 1 and guid == 'None' then
		return slot;
	end		
	return nil;
end

function BRIQUETTING_HAIR_ACC_CHECK_TARGET_ICON_IN_INVENTORY(slot, reinfItemObj, invItem, itemobj)
	local icon = slot:GetIcon();
	if itemobj ~= nil then
		if IS_VALID_BRIQUETTING_HAIR_ACC_TARGET_ITEM(itemobj) == true then
			icon:SetColorTone("FFFFFFFF");
		else
			icon:SetColorTone("33000000");
		end
		return;
	end		
	
	if icon ~= nil then
		icon:SetColorTone("AA000000");
	end
end

function BRIQUETTING_HAIR_ACC_CHECK_LOOK_ICON_IN_INVENTORY(slot, reinfItemObj, invItem, itemobj)
	local briquetting_hair_acc = ui.GetFrame('briquetting_hair_acc');
	local targetItem = BRIQUETTING_HAIR_ACC_GET_SLOT_ITEM_OBJECT(briquetting_hair_acc, 'target');
	local icon = slot:GetIcon();
	if itemobj ~= nil then
		if IS_VALID_LOOK_ITEM(itemobj) == true and targetItem ~= nil and targetItem.ClassType == itemobj.ClassType then
			icon:SetColorTone("FFFFFFFF");
		else
			icon:SetColorTone("33000000");
		end
		return;
	end		
	
	if icon ~= nil then
		icon:SetColorTone("AA000000");
	end
end

function BRIQUETTING_HAIR_ACC_CHECK_LOOK_MATERIAL_ICON_IN_INVENTORY(slot, reinfItemObj, invItem, itemobj)	
	local briquetting_hair_acc = ui.GetFrame('briquetting_hair_acc');
	local lookItem = BRIQUETTING_HAIR_ACC_GET_SLOT_ITEM_OBJECT(briquetting_hair_acc, 'look');
	local icon = slot:GetIcon();
	if itemobj ~= nil then
		if IS_VALID_LOOK_MATERIAL_ITEM_HARI_ACC(itemobj) == true then
			icon:SetColorTone("FFFFFFFF");
		else
			icon:SetColorTone("33000000");
		end
		return;
	end		
	
	if icon ~= nil then
		icon:SetColorTone("AA000000");
	end
end