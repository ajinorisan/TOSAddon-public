function GODDESSCARDMOVE_ON_INIT(addon, frame)
	addon:RegisterMsg("MSG_CLEAR_GODDESS_CARD_MOVE", "CLOSE_GODDESS_CARD_MOVE");
end

function OPEN_GODDESS_CARD_MOVE(invItem)
    local mapCls = GetClass("Map", session.GetMapName());
	if nil == mapCls then
		return;
	end

	if 'City' ~= mapCls.MapType then
		ui.SysMsg(ClMsg("AllowedInTown"));
		return;
	end

	if true == invItem.isLockState then
		ui.SysMsg(ClMsg("MaterialItemIsLock"));
		return;
    end
    
	ui.OpenFrame("goddesscardmove");
end

function CLOSE_GODDESS_CARD_MOVE()
	ui.CloseFrame("goddesscardmove");
end

function GODDESS_CARD_MOVE_OPEN(frame)
    
	INVENTORY_SET_CUSTOM_RBTNDOWN("GODDESS_CARD_MOVE_INV_RBTN");
	GODDESS_CARD_MOVE_UI_CLEAR();
	ui.OpenFrame("inventory");
end

function GODDESS_CARD_MOVE_CLOSE(frame)
	GODDESS_CARD_MOVE_UI_CLEAR();
	INVENTORY_SET_CUSTOM_RBTNDOWN("None");
end


local function _ADD_ITEM_TO_GODDESS_CARD_MOVE_FROM_INV(frame, item, invSlot, invItemGuid, slotNum)
	local invItem = session.GetInvItemByGuid(invItemGuid);
	if true == invItem.isLockState then
		ui.SysMsg(ClMsg("MaterialItemIsLock"));
		return;
	end

	local item_temp = item

	local isExchange = IS_LEGEND_CARD(item_temp)

	if isExchange == false then
		ui.SysMsg(ScpArgMsg("CanNotRegCard"))
		return;
	end	

	if slotNum == 1 then
		local lv = GET_ITEM_LEVEL(item)
		if lv < 2 then
			ui.SysMsg(ClMsg("LessLevelofSourceCard"));
			return
        end
        
	    if TryGetProp(item, 'ClassName', 'None') ~= "Legend_card_Falouros" then
			ui.SysMsg(ClMsg('CanNotRegCard'));
	    	return
	    end
	elseif slotNum == 2 then
		local srcItem = GODDESS_CARD_COPY_GET_SLOT_ITEM_OBJECT(frame, 1)
		if  srcItem == nil then
			ui.SysMsg(ClMsg("NeedRegisterForCardMove"));
			return
		end

		local ret, msg = IS_VALID_COND_LEGEND_CARD(srcItem, item)
		if ret == false then
			ui.SysMsg(ClMsg(msg));
			return
		end
	end


	local itemObj = GetIES(invItem:GetObject());
	if itemObj == nil then
		return;
	end

	local targetSlot = GET_CHILD_RECURSIVELY(frame, 'item_slot_'..slotNum);
	GODDESS_CARD_COPY_SET_SLOT_ITEM(invSlot, 1);
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
	slotText:SetText(GET_FULL_NAME(item) .. " Lv ".. GET_ITEM_LEVEL(item));
end

function GODDESS_CARD_MOVE_DROP(frame, icon)
	local slot = tolua.cast(icon, 'ui::CSlot');
	local slotNum = 0
	for num in string.gmatch(slot:GetName(), '%d') do
		slotNum = tonumber(num)
	end

	if slotNum == 1 then 
		GODDESS_CARD_MOVE_UI_CLEAR();
	else
		GODDESS_CARD_MOVE_SLOT_POP(frame, slot);
	end

	local frame = ui.GetFrame('goddesscardmove');
	local liftIcon = ui.GetLiftIcon();
	local FromFrame = liftIcon:GetTopParentFrame();
	frame = frame:GetTopParentFrame();
	if FromFrame:GetName() == 'inventory' then
		local iconInfo = liftIcon:GetInfo();
		local guid = iconInfo:GetIESID();
		local invItem = GET_ITEM_BY_GUID(guid);
		local obj = GetIES(invItem:GetObject());
		_ADD_ITEM_TO_GODDESS_CARD_MOVE_FROM_INV(frame, obj, liftIcon:GetParent(), guid, slotNum);
	end
end

function GODDESS_CARD_MOVE_INV_RBTN(itemobj, invSlot, invItemGuid)
	local frame = ui.GetFrame("goddesscardmove")
	local slotnum = 0;
	local slotitem1, slotitemguid1 = GODDESS_CARD_COPY_GET_SLOT_ITEM_OBJECT(frame, 1)
	local slotitem2, slotitemguid2 = GODDESS_CARD_COPY_GET_SLOT_ITEM_OBJECT(frame, 2)
	local slot = GET_CHILD_RECURSIVELY(frame,"item_slot_2");

	if slotitem1 == nil then
		slotnum = 1;
	elseif slotitem2 == nil then
		slotnum = 2;
	end
	if invSlot:IsSelected() == 1 then
		if slotitemguid1 == invItemGuid then
			GODDESS_CARD_MOVE_UI_CLEAR();
		elseif slotitemguid2 == invItemGuid then
			GODDESS_CARD_MOVE_SLOT_POP(frame, slot);
		end
	else
		if slotnum == 0 then
			local lv = GET_ITEM_LEVEL(slotitem1)
			local target_lv = GET_ITEM_LEVEL(itemobj)
			if target_lv >= lv then
				GODDESS_CARD_MOVE_UI_CLEAR();
				slotnum = 1;
			else
				GODDESS_CARD_MOVE_SLOT_POP(frame, slot)
				slotnum = 2;
			end
		end
		_ADD_ITEM_TO_GODDESS_CARD_MOVE_FROM_INV(frame, itemobj, invSlot, invItemGuid, slotnum);

	end
end

function GODDESS_CARD_MOVE_SLOT_POP(parent, ctrl)
	local slotNum = 0
	for num in string.gmatch(ctrl:GetName(), '%d') do
		slotNum = tonumber(num)
	end
	
	local item_slot = GET_CHILD_RECURSIVELY(parent,'item_slot_'..slotNum, "ui::CSlot");
	if item_slot ~= nil then
		item_slot:ClearIcon();
		GODDESS_CARD_COPY_SET_SLOT_ITEM(item_slot, 0);
		item_slot:SetUserValue('SELECTED_INV_GUID', 'None');
	end

	local item_pic = GET_CHILD_RECURSIVELY(parent, 'item_pic_'..slotNum, "ui::CPicture");
	if item_pic ~= nil then
		item_pic:SetImage('socket_slot_bg');
	end
	
	local frame = parent:GetTopParentFrame();

	local item_text_2 = GET_CHILD_RECURSIVELY(parent, 'item_text_'..slotNum, "ui::CRichText");
	if item_text_2 ~= nil then
		item_text_2:SetText(frame:GetUserConfig("TARGET_CARD"));
	end
end


function GODDESS_CARD_MOVE_BUTTON_CLICK(parent, ctrl)
	local frame = parent:GetTopParentFrame();
	if frame == nil then return; end

	local srcItem, srcItemGuid = GODDESS_CARD_COPY_GET_SLOT_ITEM_OBJECT(frame, 1);
	if srcItem == nil then
		local srcSlot = GET_CHILD_RECURSIVELY(frame, 'item_slot_1');
		if srcSlot:GetIcon() ~= nil then
			ui.SysMsg(ClMsg('InvalidItemRegisterStep'));
		else
			ui.SysMsg(ClMsg('SelectSomeItemPlz'));
		end		
		return;
	end

	local targetItem, targetItemGuid = GODDESS_CARD_COPY_GET_SLOT_ITEM_OBJECT(frame, 2);
	if targetItem == nil then 
		local targetSlot = GET_CHILD_RECURSIVELY(frame, 'item_slot_2');
		if targetSlot:GetIcon() ~= nil then
			ui.SysMsg(ClMsg('InvalidItemRegisterStep'));
		else
			ui.SysMsg(ClMsg('SelectSomeItemPlz'));
		end		
		return;
	end

	if IS_VALID_COND_LEGEND_CARD(srcItem, targetItem) == false then 
		return; 
	end
	
	session.ResetItemList()
    session.AddItemID(srcItemGuid, 1) -- 원본
    session.AddItemID(targetItemGuid, 1) -- 복사할 대상

    local resultlist = session.GetItemIDList()    
	item.DialogTransaction("MOVE_LEGENDCARD_EXP", resultlist);	 
end

function GODDESS_CARD_MOVE_UI_CLEAR()
	local frame = ui.GetFrame("goddesscardmove");
	if frame == nil then return; end

	local item_slot_1 = GET_CHILD_RECURSIVELY(frame, 'item_slot_1', "ui::CSlotSet");
	if item_slot_1 ~= nil then
		item_slot_1:ClearIcon();
		GODDESS_CARD_COPY_SET_SLOT_ITEM(item_slot_1, 0);
		item_slot_1:SetUserValue('SELECTED_INV_GUID', 'None');
	end

	local item_pic_1 = GET_CHILD_RECURSIVELY(frame, 'item_pic_1', "ui::CPicture");
	if item_pic_1 ~= nil then
		item_pic_1:SetImage('socket_slot_bg')
	end

	local item_text_1 = GET_CHILD_RECURSIVELY(frame, 'item_text_1', "ui::CRichText");
	if item_text_1 ~= nil then
		item_text_1:SetText(frame:GetUserConfig("SOURCE_CARD"))
	end

	local item_slot_2 = GET_CHILD_RECURSIVELY(frame,'item_slot_2', "ui::CSlotSet");
	if item_slot_2 ~= nil then
		item_slot_2:ClearIcon();
		GODDESS_CARD_COPY_SET_SLOT_ITEM(item_slot_2, 0);
		item_slot_2:SetUserValue('SELECTED_INV_GUID', 'None');
	end

	local item_pic_2 = GET_CHILD_RECURSIVELY(frame, 'item_pic_2', "ui::CPicture");
	if item_pic_2 ~= nil then
		item_pic_2:SetImage('socket_slot_bg')
	end

	local item_text_2 = GET_CHILD_RECURSIVELY(frame, 'item_text_2', "ui::CRichText");
	if item_text_2 ~= nil then
		item_text_2:SetText(frame:GetUserConfig("TARGET_CARD"));
	end
end