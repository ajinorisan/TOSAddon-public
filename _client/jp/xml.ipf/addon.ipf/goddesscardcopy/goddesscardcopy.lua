-- goddesscardcopy.lua


function GODDESSCARDCOPY_ON_INIT(addon, frame)
	addon:RegisterMsg("MSG_CLEAR_GODDESS_CARD_COPY", "GODDESS_CARD_COPY_UI_CLEAR");
end

function OPEN_GODDESS_CARD_COPY()
	ui.OpenFrame("goddesscardcopy");
end
function GODDESS_CARD_COPY_OPEN(frame)
	INVENTORY_SET_CUSTOM_RBTNDOWN("GODDESS_CARD_COPY_INV_RBTN");
	GODDESS_CARD_COPY_UI_CLEAR();
	GODDESS_CARD_COPY_UI_INIT_SETTING(frame);
	ui.OpenFrame("inventory");
end

function GODDESS_CARD_COPY_CLOSE(frame)
	GODDESS_CARD_COPY_UI_CLEAR();
	INVENTORY_SET_CUSTOM_RBTNDOWN("None");
end

function GODDESS_CARD_COPY_UI_INIT_SETTING(frame)
	if frame ~= nil then
		local help_pic = GET_CHILD_RECURSIVELY(frame, "helpPic");
		if help_pic ~= nil then
			local tooltip_text = ClMsg("GoddessCardCopyHelp")
			help_pic:SetTextTooltip(tooltip_text);
			-- 툴팁 변경해야함
			help_pic:Invalidate();
		end
	end
end

local function _ADD_ITEM_TO_GODDESS_CARD_COPY_FROM_INV(frame, item, invSlot, invItemGuid, slotNum)
	local invItem = session.GetInvItemByGuid(invItemGuid);
	if true == invItem.isLockState then
		ui.SysMsg(ClMsg("MaterialItemIsLock"));
		return;
	end

	local item_temp = item

	local isExchange = IS_GODDESS_LEGEND_CARD(item_temp)

	if isExchange == false then
		ui.SysMsg(ScpArgMsg("NotGoddessCard"))
		return;
	end	

	if slotNum == 1 then
		local lv = GET_ITEM_LEVEL(item)
		if lv < 2 then
			ui.SysMsg(ClMsg("LessLevelofSourceCard"));
			return
		end
		GODDESS_CARD_COPY_CREATE_LIST(frame, item, invItemGuid)
	elseif slotNum == 2 then
		local srcItem = GODDESS_CARD_COPY_GET_SLOT_ITEM_OBJECT(frame, 1)
		if  srcItem == nil then
			ui.SysMsg(ClMsg("NeedRegisterForCardCopy"));
			return
		end

		local ret, msg = IS_VALID_COND_LEGEND_GODDESS_CARD(srcItem, item)
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

function GODDESS_CARD_COPY_CREATE_LIST(frame, item, guid)
	local pc = GetMyPCObject();
	if pc == nil then
		return;
	end

	if item == nil or guid == nil then
		return;
	end

	local isExchange = IS_GODDESS_LEGEND_CARD(item)

	if isExchange == false then
		ui.SysMsg(ScpArgMsg("NotGoddessCard"));
		return;
	end

	local bodyGbox_midle = GET_CHILD_RECURSIVELY(frame, 'bodyGbox_middle');
	if bodyGbox_midle == nil then 
		return; 
	end

	local aObj = GetMyAccountObj();
	local ctrlSet = bodyGbox_midle:CreateOrGetControlSet("eachmaterial_in_item_cabinet", "ITEM_CABINET_MAT", 0, 0);
	if ctrlSet ~= nil then
		ctrlSet:Resize(bodyGbox_midle:GetWidth(), ctrlSet:GetHeight())
		local icon = GET_CHILD_RECURSIVELY(ctrlSet, "material_icon", "ui::CPicture");
		local questionmark = GET_CHILD_RECURSIVELY(ctrlSet, "material_questionmark", "ui::CPicture");
		local name = GET_CHILD_RECURSIVELY(ctrlSet, "material_name", "ui::CRichText");
		local count = GET_CHILD_RECURSIVELY(ctrlSet, "material_count", "ui::CRichText");
		local grade = GET_CHILD_RECURSIVELY(ctrlSet, "grade", "ui::CRichText");
		local labelline =  GET_CHILD_RECURSIVELY(ctrlSet, "labelline");
		icon:ShowWindow(1);
		count:ShowWindow(1);
		questionmark:ShowWindow(0);
		labelline:Resize(bodyGbox_midle:GetWidth() - 20, labelline:GetHeight())
		
		local coinName, cointneedCnt = GET_COPY_COST_LEGEND_GODDESS_CARD(item);

		local curCoinCount = TryGetProp(aObj, coinName, '0');
		if curCoinCount == "None" then
			curCoinCount = '0'
		end

		if math.is_larger_than(cointneedCnt, curCoinCount) == 1 then
			count:SetTextByKey("color", "{#EE0000}");
		else
			count:SetTextByKey("color", nil);		
			frame:SetUserValue("IS_ABLE_EXCHANGE", 1);
		end
		count:SetTextByKey("curCount", curCoinCount);
		count:SetTextByKey("needCount", cointneedCnt);
		local coinCls = GetClass("accountprop_inventory_list", coinName);
		name:SetText(ClMsg(coinName));
		icon:SetImage(coinCls.Icon);
	end
end

function GODDESS_CARD_COPY_DROP(frame, icon)
	local slot = tolua.cast(icon, 'ui::CSlot');
	local slotNum = 0
	for num in string.gmatch(slot:GetName(), '%d') do
		slotNum = tonumber(num)
	end

	if slotNum == 1 then 
		GODDESS_CARD_COPY_UI_CLEAR();
	else
		GODDESS_CARD_COPY_SLOT_POP(frame, slot);
	end

	local frame = ui.GetFrame('goddesscardcopy');
	local liftIcon = ui.GetLiftIcon();
	local FromFrame = liftIcon:GetTopParentFrame();
	frame = frame:GetTopParentFrame();
	if FromFrame:GetName() == 'inventory' then
		local iconInfo = liftIcon:GetInfo();
		local guid = iconInfo:GetIESID();
		local invItem = GET_ITEM_BY_GUID(guid);
		local obj = GetIES(invItem:GetObject());
		_ADD_ITEM_TO_GODDESS_CARD_COPY_FROM_INV(frame, obj, liftIcon:GetParent(), guid, slotNum);
	end
end

function GODDESS_CARD_COPY_INV_RBTN(itemobj, invSlot, invItemGuid)
	local frame = ui.GetFrame("goddesscardcopy")
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
			GODDESS_CARD_COPY_UI_CLEAR();
		elseif slotitemguid2 == invItemGuid then
			GODDESS_CARD_COPY_SLOT_POP(frame, slot);
		end
	else
		if slotnum == 0 then
			local lv = GET_ITEM_LEVEL(slotitem1)
			local target_lv = GET_ITEM_LEVEL(itemobj)
			if target_lv >= lv then
				GODDESS_CARD_COPY_UI_CLEAR();
				slotnum = 1;
			else
				GODDESS_CARD_COPY_SLOT_POP(frame, slot)
				slotnum = 2;
			end
		end
		_ADD_ITEM_TO_GODDESS_CARD_COPY_FROM_INV(frame, itemobj, invSlot, invItemGuid, slotnum);

	end
end

function GODDESS_CARD_COPY_SET_SLOT_ITEM(slot, isSelect)
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

function GODDESS_CARD_COPY_SLOT_POP(parent, ctrl)
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

	if frame ~= nil and slotNum == 1 then
		local bodyGbox_middle = GET_CHILD_RECURSIVELY(frame, 'bodyGbox_middle');
		bodyGbox_middle:RemoveAllChild();
	end
end

function GODDESS_CARD_COPY_GET_SLOT_ITEM_OBJECT(frame, slotNum)
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



function GODDESS_CARD_COPY_BUTTON_CLICK(parent, ctrl)
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

	if IS_VALID_COND_LEGEND_GODDESS_CARD(srcItem, targetItem) == false then 
		return; 
	end
	
	-- 교환 가능 여부
	local isAbleExchange = frame:GetUserIValue("IS_ABLE_EXCHANGE");
	if isAbleExchange == 0 then
		ui.SysMsg(ScpArgMsg("NotEnoughRecipe"));
		return;
	end

	session.ResetItemList()
    
    session.AddItemID(srcItemGuid, 1) -- 원본
    session.AddItemID(targetItemGuid, 1) -- 복사할 대상

    local resultlist = session.GetItemIDList()    
	item.DialogTransaction("COPY_LEGENDCARD_EXP", resultlist);	 
end


function GODDESS_CARD_COPY_UI_CLEAR()
	local frame = ui.GetFrame("goddesscardcopy");
	if frame == nil then return; end

	frame:SetUserValue("IS_ABLE_EXCHANGE", 0);

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

	local bodyGbox_midle = GET_CHILD_RECURSIVELY(frame, 'bodyGbox_middle');
	if bodyGbox_midle ~= nil then
		bodyGbox_midle:RemoveAllChild();
	end

	local bodyGbox_middle = GET_CHILD_RECURSIVELY(frame, 'bodyGbox_middle');
	if bodyGbox_middle ~= nil then
		bodyGbox_middle:RemoveAllChild();
	end
end