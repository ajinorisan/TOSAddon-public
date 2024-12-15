-- extract_luciferi_property
function EXTRACT_LUCIFERI_PROPERTY_ON_INIT(addon, frame)
	addon:RegisterMsg("MSG_CLEAR_EXCHANGE_EWEAPONTYPE", "EXTRACT_LUCIFERI_PROPERTY_UI_CLEAR");
end
function OPEN_EXTRACT_LUCIFERI_PROPERTY()
	ui.OpenFrame("extract_luciferi_property");
end
function EXTRACT_LUCIFERI_PROPERTY_OPEN(frame)
	INVENTORY_SET_CUSTOM_RBTNDOWN("EXTRACT_LUCIFERI_PROPERTY_INV_RBTN");
	EXTRACT_LUCIFERI_PROPERTY_UI_CLEAR();
	EXTRACT_LUCIFERI_PROPERTY_UI_INIT_SETTING(frame);
	ui.OpenFrame("inventory");
end

function EXTRACT_LUCIFERI_PROPERTY_CLOSE(frame)
	RESET_INVENTORY_ICON();
	INVENTORY_SET_CUSTOM_RBTNDOWN("None");
end

function EXTRACT_LUCIFERI_PROPERTY_UI_INIT_SETTING(frame)
	if frame ~= nil then
		local help_pic = GET_CHILD_RECURSIVELY(frame, "helpPic");
		if help_pic ~= nil then
			local tooltip_text = ClMsg("LuciferiExtract_Help");
			help_pic:SetTextTooltip(tooltip_text);			
			help_pic:Invalidate();
		end
	end
end

local function _ADD_ITEM_TO_EXTRACT_LUCIFERI_PROPERTY_FROM_INV(frame, item, invSlot, invItemGuid, slotNum)
	local invItem = session.GetInvItemByGuid(invItemGuid);
	if true == invItem.isLockState then
		ui.SysMsg(ClMsg("MaterialItemIsLock"));
		return;
	end
	if slotNum == 1 then
		local msg = IS_VALID_EXTRACTABLE_LUCIFERI_ITEM(item)
		if msg ~= 'YES' then
			ui.SysMsg(ScpArgMsg(msg))
			return;
		end			
	end
	
	local itemObj = GetIES(invItem:GetObject());
	if itemObj == nil then
		return;
	end

	local targetSlot = GET_CHILD_RECURSIVELY(frame, 'item_slot_'..slotNum);

	EXTRACT_LUCIFERI_PROPERTY_SET_SLOT_ITEM(invSlot, 1);
	targetSlot:SetUserValue('SELECTED_INV_GUID', invItemGuid);
	tolua.cast(targetSlot, "ui::CSlot");

	local targetIcon = targetSlot:GetIcon();
	if targetIcon == nil then
		targetIcon = CreateIcon(targetSlot);
	end
	SET_ITEM_TOOLTIP_ALL_TYPE(targetIcon, invItem, invItem.ClassName, "None", invItem.type, invItem:GetIESID());

	local slotPic = GET_CHILD_RECURSIVELY(frame, 'item_pic_'..slotNum, "ui::CPicture");
	slotPic:SetImage(item.Icon)
	local slotText = GET_CHILD_RECURSIVELY(frame, "item_text_"..slotNum, "ui::CRichText");
	slotText:SetText(GET_FULL_NAME(item));
end

function EXTRACT_LUCIFERI_PROPERTY_INV_RBTN(itemobj, invSlot, invItemGuid)
	if invSlot:IsSelected() == 1 then
		EXTRACT_LUCIFERI_PROPERTY_UI_CLEAR();
	else
		local frame = ui.GetFrame("extract_luciferi_property")
		local slotItemObj, slotItemGuid = EXTRACT_LUCIFERI_PROPERTY_GET_SLOT_ITEM_OBJECT(frame, 1)
		if slotItemObj == nil then
			_ADD_ITEM_TO_EXTRACT_LUCIFERI_PROPERTY_FROM_INV(frame, itemobj, invSlot, invItemGuid, 1);
		else
			if slotItemGuid ~= invItemGuid then
				EXTRACT_LUCIFERI_PROPERTY_UI_CLEAR();
				_ADD_ITEM_TO_EXTRACT_LUCIFERI_PROPERTY_FROM_INV(frame, itemobj, invSlot, invItemGuid, 1);
			end
		end
	end
end

function EXTRACT_LUCIFERI_PROPERTY_DROP(parent, ctrl, argStr, argNum)
	local lifticon = ui.GetLiftIcon()
	local fromframe = lifticon:GetTopParentFrame()
	if fromframe:GetName() == 'inventory' then
		local iconinfo = lifticon:GetInfo()
		local invSlot = lifticon:GetParent()
        local invItemGuid = iconinfo:GetIESID()
        local invitem = session.GetInvItemByGuid(invItemGuid)
		if invitem == nil then return end
		
		local itemobj = GetIES(invitem:GetObject())
		if itemobj == nil then return end
		
		local frame = ui.GetFrame("extract_luciferi_property")
		local slotItemObj, slotItemGuid = EXTRACT_LUCIFERI_PROPERTY_GET_SLOT_ITEM_OBJECT(frame, 1)
		if slotItemObj == nil then
			_ADD_ITEM_TO_EXTRACT_LUCIFERI_PROPERTY_FROM_INV(frame, itemobj, invSlot, invItemGuid, 1);
		else
			if slotItemGuid ~= invItemGuid then
				EXTRACT_LUCIFERI_PROPERTY_UI_CLEAR();
				_ADD_ITEM_TO_EXTRACT_LUCIFERI_PROPERTY_FROM_INV(frame, itemobj, invSlot, invItemGuid, 1);
			end
		end
	end
end

function EXTRACT_LUCIFERI_PROPERTY_SET_SLOT_ITEM(slot, isSelect)
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

function EXTRACT_LUCIFERI_PROPERTY_SLOT_POP(parent, ctrl)
	if ctrl:GetName() == 'item_slot_1' then
		EXTRACT_LUCIFERI_PROPERTY_UI_CLEAR();
	elseif ctrl:GetName() == 'item_slot_2' then
		local item_slot_2 = GET_CHILD_RECURSIVELY(parent,'item_slot_2', "ui::CSlot");
		if item_slot_2 ~= nil then
			item_slot_2:ClearIcon();
			EXTRACT_LUCIFERI_PROPERTY_SET_SLOT_ITEM(item_slot_2, 0);
			item_slot_2:SetUserValue('SELECTED_INV_GUID', 'None');
			item_slot_2:SetUserValue('SELECTED_ID', 'None');
		end

		local item_pic_2 = GET_CHILD_RECURSIVELY(parent, 'item_pic_2', "ui::CPicture");
		if item_pic_2 ~= nil then
			item_pic_2:SetImage('socket_slot_bg');
		end

		local item_text_2 = GET_CHILD_RECURSIVELY(parent, 'item_text_2', "ui::CRichText");
		if item_text_2 ~= nil then
			item_text_2:SetText("");
		end
		
		local frame = parent:GetTopParentFrame();
		if frame ~= nil then
			local bodyGbox2 = GET_CHILD_RECURSIVELY(frame, 'bodyGbox2');
			bodyGbox2:RemoveAllChild();
		end
	end	
end

function EXTRACT_LUCIFERI_PROPERTY_GET_SLOT_ITEM_OBJECT(frame, slotNum)
	local targetSlot = GET_CHILD_RECURSIVELY(frame, 'item_slot_'..slotNum, "ui::CSlot");
	if targetSlot == nil then
		return nil;
	end

	local guid = targetSlot:GetUserValue('SELECTED_INV_GUID');
	if guid == nil or guid == "None" then
		return nil;
	end
	
	local invItem = session.GetInvItemByGuid(guid);
	if invItem == nil or invItem:GetObject() == nil then
		return nil;
	end

	return GetIES(invItem:GetObject()), invItem:GetIESID();
end

function EXTRACT_LUCIFERI_PROPERTY_RADIOBTN_CLICK(parent)
	local frame = ui.GetFrame("extract_luciferi_property");
	local radioBtn = parent:GetChild('radioBtn');
	
	local MAX_EXCHANGEITEM_CNT = frame:GetUserIValue('MAX_EXCHANGEITEM_CNT');
	for i = 0, MAX_EXCHANGEITEM_CNT - 1 do
		local ctrlset = GET_CHILD_RECURSIVELY(frame, 'EXCHANGE_WEAPONTYPE_CSET_'..i);
		local _radioBtn = GET_CHILD(ctrlset, 'radioBtn', 'ui::CRadioButton');
		_radioBtn:SetEventScript(ui.LBUTTONUP, "EXTRACT_LUCIFERI_PROPERTY_RADIOBTN_CLICK");
		if _radioBtn ~= radioBtn then
			_radioBtn:SetCheck(false);
		else
			radioBtn:SetCheck(true);
			frame:SetUserValue('NOW_SELECT_ITEM_ID', ctrlset:GetUserIValue('ITEM_ID'));			
		end
	end
end

function EXTRACT_LUCIFERI_PROPERTY_EXCHANGE_BUTTON_CLICK(parent, ctrl)
	local frame = parent:GetTopParentFrame();
	if frame == nil then return; end

	local targetItem, targetItemGuid = EXTRACT_LUCIFERI_PROPERTY_GET_SLOT_ITEM_OBJECT(frame, 1);	
	if targetItem == nil then
		local targetSlot = GET_CHILD_RECURSIVELY(frame, 'item_slot_1');
		if targetSlot:GetIcon() ~= nil then
			ui.SysMsg(ClMsg('InvalidItemRegisterStep'));
		else
			ui.SysMsg(ClMsg('SelectSomeItemPlz'));
		end		
		return;
	end
		
	local invItem = session.GetInvItemByGuid(targetItemGuid);
	if invItem == nil then return; end		

	pc.ReqExecuteTx_Item('EXTRACT_REINFOCRE_PR_TO_SCROLL', targetItemGuid, 0);

end

function EXTRACT_LUCIFERI_PROPERTY_UI_CLEAR()
	local frame = ui.GetFrame("extract_luciferi_property");
	if frame == nil then return; end

	frame:SetUserValue('NOW_SELECT_ITEM_ID', 0)
	
	local item_slot_1 = GET_CHILD_RECURSIVELY(frame, 'item_slot_1', "ui::CSlotSet");
	if item_slot_1 ~= nil then
		item_slot_1:ClearIcon();
		EXTRACT_LUCIFERI_PROPERTY_SET_SLOT_ITEM(item_slot_1, 0);
		item_slot_1:SetUserValue('SELECTED_INV_GUID', 'None');
	end

	local item_pic_1 = GET_CHILD_RECURSIVELY(frame, 'item_pic_1', "ui::CPicture");
	if item_pic_1 ~= nil then
		item_pic_1:SetImage('socket_slot_bg')
	end

	local item_text_1 = GET_CHILD_RECURSIVELY(frame, 'item_text_1', "ui::CRichText");
	if item_text_1 ~= nil then
		item_text_1:SetText(ScpArgMsg('DropItemPlz'))
	end
end
