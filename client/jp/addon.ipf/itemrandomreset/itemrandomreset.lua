
function ITEMRANDOMRESET_ON_INIT(addon, frame)

	addon:RegisterMsg("OPEN_DLG_ITEMRANDOMRESET", "ON_OPEN_DLG_ITEMRANDOMRESET");
	addon:RegisterMsg("MSG_SUCCESS_RESET_RANDOM_OPTION", "SUCCESS_RESET_RANDOM_OPTION");

end

function ON_OPEN_DLG_ITEMRANDOMRESET(frame)
	local itemrevertrandom = ui.GetFrame('itemrevertrandom');
	if itemrevertrandom ~= nil and itemrevertrandom:IsVisible() == 1 then
		return;
	end

	local itemunrevertrandom = ui.GetFrame('itemunrevertrandom');
	if itemunrevertrandom ~= nil and itemunrevertrandom:IsVisible() == 1 then
		return;
	end

	local itemunrevertrandom = ui.GetFrame('itemsandrarevertrandom');
	if itemunrevertrandom ~= nil and itemunrevertrandom:IsVisible() == 1 then
		return;
	end	

	frame:ShowWindow(1);
end

function ITEMRANDOMRESET_OPEN(frame)
	local itemrevertrandom = ui.GetFrame('itemrevertrandom');
	if itemrevertrandom ~= nil and itemrevertrandom:IsVisible() == 1 then
		frame:ShowWindow(0);
		ui.OpenFrame("inventory");
		return;
	end

	local itemunrevertrandom = ui.GetFrame('itemunrevertrandom');
	if itemunrevertrandom ~= nil and itemunrevertrandom:IsVisible() == 1 then
		frame:ShowWindow(0);
		ui.OpenFrame("inventory");
		return;
	end
	
	local itemunrevertrandom = ui.GetFrame('itemsandrarevertrandom');
	if itemunrevertrandom ~= nil and itemunrevertrandom:IsVisible() == 1 then
		frame:ShowWindow(0);
		ui.OpenFrame("inventory");
		return;
	end	

	SET_RANDOMRESET_RESET(frame);
	CLEAR_ITEMRANDOMRESET_UI()
	INVENTORY_SET_CUSTOM_RBTNDOWN("ITEMRANDOMRESET_INV_RBTN")	
	ui.OpenFrame("inventory");
end

function ITEMRANDOMRESET_CLOSE(frame)
	if ui.CheckHoldedUI() == true then
		return;
	end
	INVENTORY_SET_CUSTOM_RBTNDOWN("None");
	frame:ShowWindow(0);
	control.DialogOk();
	ui.CloseFrame("inventory");
 end

function RANDOMRESET_UPDATE(isSuccess)
	local frame = ui.GetFrame("itemrandomreset");
	UPDATE_RANDOMRESET_ITEM(frame);
	UPDATE_RANDOMRESET_RESULT(frame, isSuccess);
end

function CHECK_RESET_ITEM_TRUE_AND_FALSE()
	local frame = ui.GetFrame("itemrandomreset");

	local check_no_msgbox = GET_CHILD_RECURSIVELY(frame, 'check_no_reset_item')
	if check_no_msgbox:IsChecked() == 1 then
		local slot = GET_CHILD(frame, "slot");
		local icon = slot:GetIcon();
		local iconInfo = icon:GetInfo();
		local invItem = GET_PC_ITEM_BY_GUID(iconInfo:GetIESID());
		local obj = GetIES(invItem:GetObject());

		local couponSlot = GET_CHILD_RECURSIVELY(frame, "couponSlot")
		local coupon = GET_SLOT_ITEM(couponSlot)

		ITEM_RANDOMRESET_REG_TARGETITEM(frame, iconInfo:GetIESID())
		if coupon ~= nil then
			ITEM_RANDOMRESET_REG_COUPONITEM(frame, coupon:GetIESID())
		end
	else
		CLEAR_ITEMRANDOMRESET_UI();
	end
end

function CLEAR_ITEMRANDOMRESET_UI()
	if ui.CheckHoldedUI() == true then
		return;
	end

	local frame = ui.GetFrame("itemrandomreset");

	local slot = GET_CHILD_RECURSIVELY(frame, "slot", "ui::CSlot");
	slot:ClearIcon();

	local sendOK = GET_CHILD_RECURSIVELY(frame, "send_ok")
	sendOK:ShowWindow(0)

	local do_randomreset = GET_CHILD_RECURSIVELY(frame, "do_randomreset")
	do_randomreset:ShowWindow(1)

	local putOnItem = GET_CHILD_RECURSIVELY(frame, "text_putonitem")
	putOnItem:ShowWindow(1)

	local text_currentoption = GET_CHILD_RECURSIVELY(frame, "text_currentoption")
	text_currentoption:ShowWindow(1)
	local text_material = GET_CHILD_RECURSIVELY(frame, "text_material")
	text_material:ShowWindow(1)
	local text_beforereset = GET_CHILD_RECURSIVELY(frame, "text_beforereset")
	text_beforereset:ShowWindow(0)
	local text_afterreset = GET_CHILD_RECURSIVELY(frame, "text_afterreset")
	text_afterreset:ShowWindow(0)

	local slot_bg_image = GET_CHILD_RECURSIVELY(frame, "slot_bg_image")
	slot_bg_image:ShowWindow(1)
		
	local arrowbox = GET_CHILD_RECURSIVELY(frame, "arrowbox")
	arrowbox:ShowWindow(0)

	local itemName = GET_CHILD_RECURSIVELY(frame, "text_itemname")
	itemName:SetText("")

	local bodyGbox1 = GET_CHILD_RECURSIVELY(frame, 'bodyGbox1');
	bodyGbox1:ShowWindow(1)
	local bodyGbox2 = GET_CHILD_RECURSIVELY(frame, 'bodyGbox2');
	bodyGbox2:ShowWindow(1)
	local bodyGbox2_1 = GET_CHILD_RECURSIVELY(frame, 'bodyGbox2_1');
	bodyGbox2_1:ShowWindow(1)
	local bodyGbox3 = GET_CHILD_RECURSIVELY(frame, 'bodyGbox3');
	bodyGbox3:ShowWindow(0)

	local bodyGbox1_1 = GET_CHILD_RECURSIVELY(frame, 'bodyGbox1_1');
	bodyGbox1_1:RemoveAllChild();
	local bodyGbox2_1 = GET_CHILD_RECURSIVELY(frame, 'bodyGbox2_1');
	bodyGbox2_1:RemoveAllChild();
	local bodyGbox3_1 = GET_CHILD_RECURSIVELY(frame, 'bodyGbox3_1');
	bodyGbox3_1:RemoveAllChild();

	-- local gbox_infomation = GET_CHILD_RECURSIVELY(frame, 'gbox_infomation');
	-- gbox_infomation:ShowWindow(1)

	local couponGbox = GET_CHILD_RECURSIVELY(frame, "couponGbox")
	couponGbox:ShowWindow(0)
	local couponSlot = GET_CHILD_RECURSIVELY(frame, "couponSlot")
	REMOVE_RANDOMRESET_COUPON_ITEM(couponGbox, couponSlot)
end

function ITEM_RANDOMRESET_DROP(frame, icon, argStr, argNum)
	if ui.CheckHoldedUI() == true then
		return;
	end

	local liftIcon = ui.GetLiftIcon();
	local FromFrame = liftIcon:GetTopParentFrame();
	local toFrame = frame:GetTopParentFrame();
	if FromFrame:GetName() == 'inventory' then
		local iconInfo = liftIcon:GetInfo();
		ITEM_RANDOMRESET_REG_TARGETITEM(frame, iconInfo:GetIESID());
	end
end

function ITEM_RANDOMRESET_REG_TARGETITEM(frame, itemID)
	if ui.CheckHoldedUI() == true then
		return;
	end

	local invItem = session.GetInvItemByGuid(itemID)
	if invItem == nil then
		return;
	end

	local item = GetIES(invItem:GetObject());
	local itemCls = GetClassByType('Item', item.ClassID)

	if TryGetProp(itemCls, "NeedRandomOption", 0) ~= 1 then
		ui.SysMsg(ClMsg("NotAllowedRandomReset"));
		return;
	end

	local pc = GetMyPCObject();
	if pc == nil then
		return;
	end

	local obj = GetIES(invItem:GetObject());
	if IS_NEED_APPRAISED_ITEM(obj) == true or IS_NEED_RANDOM_OPTION_ITEM(obj) == true then 
		ui.SysMsg(ClMsg("NeedAppraisd"));
		return;
	end
		
	local invframe = ui.GetFrame("inventory");
	if true == invItem.isLockState or true == IS_TEMP_LOCK(invframe, invItem) then
		ui.SysMsg(ClMsg("MaterialItemIsLock"));
		return;
	end

	CLEAR_ITEMRANDOMRESET_UI();

	local putOnItem = GET_CHILD_RECURSIVELY(frame, "text_putonitem")
	putOnItem:ShowWindow(0)

	local slot_bg_image = GET_CHILD_RECURSIVELY(frame, "slot_bg_image")
	slot_bg_image:ShowWindow(0)

	local itemName = GET_CHILD_RECURSIVELY(frame, "text_itemname")
	itemName:SetText(obj.Name)

	local ypos = 0;
	local gBox = GET_CHILD_RECURSIVELY(frame, "bodyGbox1_1");
	for i = 1 , MAX_RANDOM_OPTION_COUNT do
	    local propGroupName = "RandomOptionGroup_"..i;
		local propName = "RandomOption_"..i;
		local propValue = "RandomOptionValue_"..i;
		local clientMessage = 'None'
		
		if obj[propGroupName] == 'ATK' then
		    clientMessage = 'ItemRandomOptionGroupATK'
		elseif obj[propGroupName] == 'DEF' then
		    clientMessage = 'ItemRandomOptionGroupDEF'
		elseif obj[propGroupName] == 'UTIL_WEAPON' then
		    clientMessage = 'ItemRandomOptionGroupUTIL'
		elseif obj[propGroupName] == 'UTIL_ARMOR' then
		    clientMessage = 'ItemRandomOptionGroupUTIL'
		elseif obj[propGroupName] == 'UTIL_SHILED' then
		    clientMessage = 'ItemRandomOptionGroupUTIL'
		elseif obj[propGroupName] == 'STAT' then
		    clientMessage = 'ItemRandomOptionGroupSTAT'
		end

		if obj[propValue] ~= 0 and obj[propName] ~= "None" then
			local opName = string.format("%s %s", ClMsg(clientMessage), ScpArgMsg(obj[propName]));
			local strInfo = ABILITY_DESC_NO_PLUS(opName, obj[propValue], 0);
			local itemClsCtrl = gBox:CreateOrGetControlSet('eachproperty_in_itemrandomreset', 'PROPERTY_CSET_'..i, 0, 0);
			itemClsCtrl = AUTO_CAST(itemClsCtrl)
			local pos_y = itemClsCtrl:GetUserConfig("POS_Y")			
			itemClsCtrl:Move(0, i * pos_y);
			local propertyList = GET_CHILD_RECURSIVELY(itemClsCtrl, "property_name", "ui::CRichText");
			propertyList:SetText(strInfo);
			ypos = i * pos_y + propertyList:GetHeight();
		end
	end

	local itemRandomResetMaterial = nil;

	local list, cnt = GetClassList("item_random_reset_material")
	
	if list == nil then
		return;
	end
					
	for i = 0, cnt - 1 do
		local cls = GetClassByIndexFromList(list, i);
		if cls == nil then
			return;
		end

		if obj.ClassType == cls.ItemType and obj.ItemGrade == cls.ItemGrade then
			itemRandomResetMaterial = cls
		end
	end

	if itemRandomResetMaterial == nil then
		return;
	end

	local isAbleExchange = 1;
	if obj.MaxDur <= MAXDUR_DECREASE_POINT_PER_RANDOM_RESET or obj.Dur <= MAXDUR_DECREASE_POINT_PER_RANDOM_RESET then
		isAbleExchange = -2;
	end

	local materialItemSlot = itemRandomResetMaterial.MaterialItemSlot;
	frame:SetUserValue('MAX_EXCHANGEITEM_CNT', materialItemSlot);

	local bodyGbox2_1 = GET_CHILD_RECURSIVELY(frame, "bodyGbox2_1")
	for i = 1, materialItemSlot do
		local materialItemIndex = "MaterialItem_" ..i
		local materialItemCount = 0
		local materialCountScp = itemRandomResetMaterial[materialItemIndex .."_SCP"]
		if materialCountScp ~= "None" then
			materialCountScp = _G[materialCountScp];
			materialItemCount = materialCountScp(obj);
		else
			return
		end

		if materialItemCount == 0 then
			break;
		end

		local materialClsCtrl = bodyGbox2_1:CreateOrGetControlSet('eachmaterial_in_itemrandomreset', 'MATERIAL_CSET_'..i, 0, 0);
		materialClsCtrl = AUTO_CAST(materialClsCtrl)
		local pos_y = materialClsCtrl:GetUserConfig("POS_Y")
		materialClsCtrl:Move(0, (i - 1) * pos_y)
		local material_icon = GET_CHILD_RECURSIVELY(materialClsCtrl, "material_icon", "ui::CPicture");
		local material_questionmark = GET_CHILD_RECURSIVELY(materialClsCtrl, "material_questionmark", "ui::CPicture");
		local material_name = GET_CHILD_RECURSIVELY(materialClsCtrl, "material_name", "ui::CRichText");
		local material_count = GET_CHILD_RECURSIVELY(materialClsCtrl, "material_count", "ui::CRichText");
		local gradetext2 = GET_CHILD_RECURSIVELY(materialClsCtrl, "grade", "ui::CRichText");
		
		material_count:ShowWindow(1)

		local itemName = ScpArgMsg('NotDecidedYet')

		local itemIcon = 'question_mark'
		material_icon:ShowWindow(1)
		material_questionmark : ShowWindow(0)

		if item ~= nil then
			local materialCls = GetClass("Item", itemRandomResetMaterial[materialItemIndex]);

			if i <= materialItemSlot and materialCls ~= 'None' then
				materialClsCtrl:ShowWindow(1)
				itemIcon = materialCls.Icon;
				itemName = materialCls.Name;
				local itemCount = GetInvItemCount(pc, materialCls.ClassName)
				local invMaterial = session.GetInvItemByName(materialCls.ClassName)

				local type = item.ClassID;
				
				if itemCount < materialItemCount then
					material_count:SetTextByKey("color", "{#EE0000}");
					isAbleExchange = 0;
				elseif invMaterial.isLockState == true then
					isAbleExchange = -1;
				else 
					material_count:SetTextByKey("color", nil);
				end
				material_count:SetTextByKey("curCount", itemCount);
				
				--EVENT_1903_WEEKEND
--				if SCR_EVENT_1903_WEEKEND_CHECK('ITEMRANDOMRESET', false) == 'YES' then
--    			    material_count:SetTextByKey("needCount", materialItemCount..' '..ScpArgMsg('EVENT_REINFORCE_DISCOUNT_MSG1'))
    			    
                --burning_event
                if IsBuffApplied(pc, "Event_Reappraisal_Discount_50") == "YES" then
                    material_count:SetTextByKey("needCount", materialItemCount..' '..ScpArgMsg('EVENT_REINFORCE_DISCOUNT_MSG1'))
    			else
    				material_count:SetTextByKey("needCount", materialItemCount)
    			end
					
				session.AddItemID(materialCls.ClassID, materialItemCount);
	
				material_count:ShowWindow(1)
			else
				materialClsCtrl:ShowWindow(0)
			end

		else
			materialClsCtrl:ShowWindow(0)
		end

		material_icon:SetImage(itemIcon)
		material_name:SetText(itemName)
	end

	frame:SetUserValue("isAbleExchange", isAbleExchange)

	local slot = GET_CHILD(frame, "slot");
	SET_SLOT_ITEM(slot, invItem);
	SET_RANDOMRESET_RESET(frame);

	local couponGbox = GET_CHILD_RECURSIVELY(frame, "couponGbox")
	couponGbox:ShowWindow(1)
end

function SET_RANDOMRESET_RESET(frame)
	-- reg:ShowWindow(0);
end

function ITEMRANDOMRESET_EXEC(frame)

	frame = frame:GetTopParentFrame();
	local slot = GET_CHILD(frame, "slot");
	local invItem = GET_SLOT_ITEM(slot);
	local check_no_msgbox = GET_CHILD_RECURSIVELY(frame, 'check_no_reset_item')

	if invItem == nil then
		return
	end

	if check_no_msgbox:IsChecked() ~= 1 then
		local clmsg = ScpArgMsg("DoRandomReset")
		ui.MsgBox_NonNested(clmsg, frame:GetName(), "_ITEMRANDOMRESET_EXEC", "_ITEMRANDOMRESET_CANCEL");
	else
		_ITEMRANDOMRESET_EXEC()
	end
end

function _ITEMRANDOMRESET_CANCEL()
	local frame = ui.GetFrame("itemrandomreset");
end

function _ITEMRANDOMRESET_EXEC()
	local frame = ui.GetFrame("itemrandomreset");
	if frame:IsVisible() == 0 then
		return;
	end
	
	local isAbleExchange = frame:GetUserIValue("isAbleExchange")
	local couponRegister = frame:GetUserIValue("COUPON_REG")

	if couponRegister == 0 then
		if isAbleExchange == 0 then
			ui.SysMsg(ClMsg('NotEnoughRecipe'));
			return
		end
	
		if isAbleExchange == -1 then
			ui.SysMsg(ClMsg("MaterialItemIsLock"));
			return
		end
	end

	if isAbleExchange == -2 then
		ui.SysMsg(ClMsg("MaxDurUnderflow")); 
		return
	end

	local slot = GET_CHILD(frame, "slot");
	local invItem = GET_SLOT_ITEM(slot);
	if invItem == nil then
		return;
	end

	local itemObj = GetIES(invItem:GetObject());
	local itemCls = GetClassByType('Item', itemObj.ClassID)

	if itemCls.NeedRandomOption ~= 1 then
		ui.SysMsg(ClMsg("NotAllowedRandomReset"));
		return;
	end

	session.ResetItemList();
	session.AddItemID(invItem:GetIESID(), 1);
	if couponRegister == 1 then
		local couponSlot = GET_CHILD_RECURSIVELY(frame, "couponSlot")
		local couponItem = GET_SLOT_ITEM(couponSlot)
		if couponItem == nil then
			ui.SysMsg(ClMsg('NotEnoughRecipe'));
			return
		end

		if couponItem.isLockState == true then
			ui.SysMsg(ClMsg("MaterialItemIsLock"));
			return
		end

		session.AddItemID(couponItem:GetIESID(), 1)
	end

	local resultlist = session.GetItemIDList()
	local argList = NewStringList()
	item.DialogTransaction("RESET_RANDOM_OPTION_ITEM", resultlist, '', argList)
end

function SUCCESS_RESET_RANDOM_OPTION(frame)
	local RESET_SUCCESS_EFFECT_NAME = frame:GetUserConfig('RESET_SUCCESS_EFFECT');
	local EFFECT_SCALE = tonumber(frame:GetUserConfig('EFFECT_SCALE'));
	local EFFECT_DURATION = tonumber(frame:GetUserConfig('EFFECT_DURATION'));
	local pic_bg = GET_CHILD_RECURSIVELY(frame, 'pic_bg');
	if pic_bg == nil then
		return;
	end
	-- pic_bg:PlayActiveUIEffect();
	pic_bg:PlayUIEffect(RESET_SUCCESS_EFFECT_NAME, EFFECT_SCALE, 'RESET_SUCCESS_EFFECT');

	local do_randomreset = GET_CHILD_RECURSIVELY(frame, "do_randomreset")
	do_randomreset:ShowWindow(0)

	ui.SetHoldUI(true);

	ReserveScript("_SUCCESS_RESET_RANDOM_OPTION()", EFFECT_DURATION)
end

function _SUCCESS_RESET_RANDOM_OPTION()
	ui.SetHoldUI(false);

	local frame = ui.GetFrame("itemrandomreset");
	if frame:IsVisible() == 0 then
		return;
	end

	local slot = GET_CHILD(frame, "slot");
	local invItem = GET_SLOT_ITEM(slot);
	if invItem == nil then
		return;
	end

	local RESET_SUCCESS_EFFECT_NAME = frame:GetUserConfig('RESET_SUCCESS_EFFECT');
	local EFFECT_SCALE = tonumber(frame:GetUserConfig('EFFECT_SCALE'));

	local pic_bg = GET_CHILD_RECURSIVELY(frame, 'pic_bg');
	if pic_bg == nil then
		return;
	end

	pic_bg:StopUIEffect('RESET_SUCCESS_EFFECT', true, 0.5);

	-- imcSound.PlaySoundEvent('battle_win');
	-- pic_bg:PlayUIEffect(RESET_SUCCESS_EFFECT_NAME, EFFECT_SCALE, 'RESET_SUCCESS_EFFECT');
	-- pic_bg:StopActiveUIEffect();

	local item = GetIES(invItem:GetObject());

	local sendOK = GET_CHILD_RECURSIVELY(frame, "send_ok")
	sendOK:ShowWindow(1)

	local bodyGbox2 = GET_CHILD_RECURSIVELY(frame, 'bodyGbox2');
	bodyGbox2:ShowWindow(0)
	local bodyGbox2_1 = GET_CHILD_RECURSIVELY(frame, 'bodyGbox2_1');
	bodyGbox2_1:ShowWindow(0)
	local couponGbox = GET_CHILD_RECURSIVELY(frame, 'couponGbox');
	couponGbox:ShowWindow(0)

	local arrowbox = GET_CHILD_RECURSIVELY(frame, "arrowbox")
	arrowbox:ShowWindow(1)
	local text_currentoption = GET_CHILD_RECURSIVELY(frame, "text_currentoption")
	text_currentoption:ShowWindow(0)		
	local text_material = GET_CHILD_RECURSIVELY(frame, "text_material")
	text_material:ShowWindow(0)
	local text_beforereset = GET_CHILD_RECURSIVELY(frame, "text_beforereset")
	text_beforereset:ShowWindow(1)
	local text_afterreset = GET_CHILD_RECURSIVELY(frame, "text_afterreset")
	text_afterreset:ShowWindow(1)

	local bodyGbox3 = GET_CHILD_RECURSIVELY(frame, 'bodyGbox3');
	bodyGbox3:ShowWindow(1)

	-- local gbox_infomation = GET_CHILD_RECURSIVELY(frame, 'gbox_infomation');
	-- gbox_infomation:ShowWindow(0)

	local gbox = frame:GetChild("gbox");
	invItem = GET_SLOT_ITEM(slot);
	local invItemGUID = invItem:GetIESID()
	local resetInvItem = session.GetInvItemByGuid(invItemGUID)
	if resetInvItem == nil then
		resetInvItem = session.GetEquipItemByGuid(invItemGUID)
	end
	local obj = GetIES(resetInvItem:GetObject());

	local refreshScp = obj.RefreshScp
	if refreshScp ~= "None" then
		refreshScp = _G[refreshScp];
		refreshScp(obj);
	end

	local gBox = GET_CHILD_RECURSIVELY(frame, "bodyGbox3_1");
    local ypos = 0;
	for i = 1 , MAX_RANDOM_OPTION_COUNT do
	    local propGroupName = "RandomOptionGroup_"..i;
		local propName = "RandomOption_"..i;
		local propValue = "RandomOptionValue_"..i;
		local clientMessage = 'None'
		
		if obj[propGroupName] == 'ATK' then
		    clientMessage = 'ItemRandomOptionGroupATK'
		elseif obj[propGroupName] == 'DEF' then
		    clientMessage = 'ItemRandomOptionGroupDEF'
		elseif obj[propGroupName] == 'UTIL_WEAPON' then
		    clientMessage = 'ItemRandomOptionGroupUTIL'
		elseif obj[propGroupName] == 'UTIL_ARMOR' then
		    clientMessage = 'ItemRandomOptionGroupUTIL'			
		elseif obj[propGroupName] == 'UTIL_SHILED' then
		    clientMessage = 'ItemRandomOptionGroupUTIL'
		elseif obj[propGroupName] == 'STAT' then
		    clientMessage = 'ItemRandomOptionGroupSTAT'
		end

		if obj[propValue] ~= 0 and obj[propName] ~= "None" then
			local opName = string.format("%s %s", ClMsg(clientMessage), ScpArgMsg(obj[propName]));
			local strInfo = ABILITY_DESC_NO_PLUS(opName, obj[propValue], 0);
			local itemClsCtrl = gBox:CreateOrGetControlSet('eachproperty_in_itemrandomreset', 'PROPERTY_CSET_'..i, 0, 0);
			itemClsCtrl = AUTO_CAST(itemClsCtrl)
			local pos_y = itemClsCtrl:GetUserConfig("POS_Y")
			itemClsCtrl:Move(0, i * pos_y);
			local propertyList = GET_CHILD_RECURSIVELY(itemClsCtrl, "property_name", "ui::CRichText");
			propertyList:SetText(strInfo);
            ypos = i * pos_y + propertyList:GetHeight();
		end
	end
end

function REMOVE_RANDOMRESET_TARGET_ITEM(frame)
	if ui.CheckHoldedUI() == true then
		return;
	end
	
	frame = frame:GetTopParentFrame();
	local slot = GET_CHILD(frame, "slot");
	slot:ClearIcon();
	CLEAR_ITEMRANDOMRESET_UI()
end

function ITEMRANDOMRESET_INV_RBTN(itemObj, slot)
	local frame = ui.GetFrame("itemrandomreset");
	if frame == nil then
		return
	end

	local icon = slot:GetIcon();
	local iconInfo = icon:GetInfo();
	local invItem = GET_PC_ITEM_BY_GUID(iconInfo:GetIESID());
	local obj = GetIES(invItem:GetObject());
	
	local slot = GET_CHILD(frame, "slot");
	local slotInvItem = GET_SLOT_ITEM(slot);
	if slotInvItem ~= nil and TryGetProp(obj, "StringArg", "None") == "FreeItemRandomReset" then
		ITEM_RANDOMRESET_REG_COUPONITEM(frame, iconInfo:GetIESID());
	else
		ITEM_RANDOMRESET_REG_TARGETITEM(frame, iconInfo:GetIESID());
	end
end

function ITEM_RANDOMRESET_COUPON_DROP(parent, ctrl, argStr, argNum)
	if ui.CheckHoldedUI() == true then
		return
	end

	local liftIcon = ui.GetLiftIcon()
	local FromFrame = liftIcon:GetTopParentFrame()
	local toFrame = parent:GetTopParentFrame()
	if FromFrame:GetName() == 'inventory' then
		local iconInfo = liftIcon:GetInfo()
		ITEM_RANDOMRESET_REG_COUPONITEM(toFrame, iconInfo:GetIESID())
	end
end

function ITEM_RANDOMRESET_REG_COUPONITEM(frame, itemID)
	if ui.CheckHoldedUI() == true then
		return
	end

	local invItem = session.GetInvItemByGuid(itemID)
	if invItem == nil then
		return
	end

	local itemObj = GetIES(invItem:GetObject())
	if TryGetProp(itemObj, 'StringArg', 'None') ~= 'FreeItemRandomReset' then
		return
	end
		
	local invframe = ui.GetFrame("inventory")
	if true == invItem.isLockState or true == IS_TEMP_LOCK(invframe, invItem) then
		ui.SysMsg(ClMsg("MaterialItemIsLock"))
		return
	end

	local slot = GET_CHILD_RECURSIVELY(frame, "couponSlot")
	SET_SLOT_ITEM(slot, invItem)

	local name = GET_CHILD_RECURSIVELY(frame, "couponName")
	name:SetTextByKey("value", dic.getTranslatedStr(TryGetProp(itemObj, "Name", "None")))

	local count = GET_CHILD_RECURSIVELY(frame, "couponCount")
	count:SetTextByKey("curCount", tostring(invItem.count))
	count:SetTextByKey("needCount", "1")
	count:ShowWindow(1)
	
	local mat_count = frame:GetUserIValue('MAX_EXCHANGEITEM_CNT')
	for i = 1, mat_count do
		local materialClsCtrl = GET_CHILD_RECURSIVELY(frame, "MATERIAL_CSET_" .. i)
		if materialClsCtrl ~= nil then
			materialClsCtrl:ShowWindow(0)
		end
	end

	frame:SetUserValue("COUPON_REG", 1)
end

function REMOVE_RANDOMRESET_COUPON_ITEM(parent, ctrl)
	local frame = parent:GetTopParentFrame()

	local slot = GET_CHILD_RECURSIVELY(frame, "couponSlot")
	slot:ClearIcon()

	local name = GET_CHILD_RECURSIVELY(frame, "couponName")
	name:SetTextByKey("value", frame:GetUserConfig("COUPON_DEFAULT"))

	local couponCount = GET_CHILD_RECURSIVELY(frame, "couponCount")
	couponCount:ShowWindow(0)

	local mat_count = frame:GetUserIValue('MAX_EXCHANGEITEM_CNT')
	for i = 1, mat_count do
		local materialClsCtrl = GET_CHILD_RECURSIVELY(frame, "MATERIAL_CSET_" .. i)
		if materialClsCtrl ~= nil then
			materialClsCtrl:ShowWindow(1)
		end
	end

	frame:SetUserValue("COUPON_REG", 0)
end