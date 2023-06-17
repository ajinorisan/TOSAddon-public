
function UPGRADE_VIBORA_ON_INIT(addon, frame)
	addon:RegisterMsg("OPEN_DLG_UPGRADE_VIBORA", "ON_OPEN_DLG_UPGRADE_VIBORA");
	addon:RegisterMsg("UPGRADE_VIBORA_SUCCESS", "UPGRADE_VIBORA_SUCCESS");
	addon:RegisterMsg("UPGRADE_VIBORA_FAIL", "UPGRADE_VIBORA_FAIL");
end

local function show_windows(name, number)
	if number == true then
		number = 1
	elseif number == false then
		number = 0
	end	

	local frame = ui.GetFrame('upgrade_vibora')	
	local set = GET_CHILD_RECURSIVELY(frame, name)
	if set ~= nil then
		set:ShowWindow(number)
	end
end

local function PLAY_EXEC_EFFECT_VIBORA()
	local frame = ui.GetFrame("upgrade_vibora");
	local EXTRACT_RESULT_EFFECT_NAME = frame:GetUserConfig('EXTRACT_RESULT_EFFECT');
	local EFFECT_SCALE = tonumber(frame:GetUserConfig('EFFECT_SCALE'));
	local EFFECT_DURATION = tonumber(frame:GetUserConfig('EFFECT_DURATION'));
	local result_slot = GET_CHILD_RECURSIVELY(frame, 'start_gb');	
	if result_slot == nil then
		return;
	end
		
	result_slot:PlayUIEffect(EXTRACT_RESULT_EFFECT_NAME, EFFECT_SCALE, 'EXTRACT_RESULT_EFFECT');	
	ui.SetHoldUI(true);	
    ReserveScript('release_ui_lock_vibora()', EFFECT_DURATION);
end

function release_ui_effect_for_vibora()
	local frame = ui.GetFrame("upgrade_vibora");
	local successItem = GET_CHILD_RECURSIVELY(frame, "successItem");
	if successItem ~= nil then
		successItem:StopUIEffect('RESULT_EFFECT', true, 0);		
	end    
end

function ON_OPEN_DLG_UPGRADE_VIBORA()
	ui.OpenFrame("upgrade_vibora");
end

function UPGRADE_VIBORA_OPEN(frame)
    UPGRADE_VIBORA_UI_RESET();
	
	INVENTORY_SET_CUSTOM_RBTNDOWN("UPGRADE_VIBORA_INV_RBTNDOWN");
	ui.OpenFrame("inventory");
end

function UPGRADE_VIBORA_CLOSE(frame)
	if ui.CheckHoldedUI() == true then
		return;
	end

	INVENTORY_SET_CUSTOM_RBTNDOWN("None");
    frame:ShowWindow(0);
end

function UPGRADE_VIBORA_SLOT_RESET(slot, slotIndex)	
	if IS_CHECK_UPGRADE_VIBORA_RESULT() == true then
		return;
	end

	slot:SetUserValue("CLASS_NAME", "None");
	slot:SetUserValue("GUID", "None");
	slot:ClearIcon();
	
	local slot_img = GET_CHILD_RECURSIVELY(slot, 'slot_img_'..slotIndex);
	slot_img:ShowWindow(1);
	
	local gauge = GET_CHILD_RECURSIVELY(ui.GetFrame("upgrade_vibora"), "refine_gauge_" .. slotIndex);		
	gauge:SetPoint(0, 100)
	gauge:ShowWindow(0);	

	if slotIndex > 1 then		
		local text = GET_CHILD_RECURSIVELY(ui.GetFrame("upgrade_vibora"), "text_warning");
		text:ShowWindow(0)
	end
end

function UPGRADE_VIBORA_UI_RESET()
	local frame = ui.GetFrame("upgrade_vibora");
	
	local reinfResultBox = GET_CHILD(frame, "reinfResultBox");
	reinfResultBox:ShowWindow(0);

	local doBtn = GET_CHILD(frame, "doBtn");
	doBtn:ShowWindow(1);

	local resetBtn = GET_CHILD(frame, "resetBtn");
	resetBtn:ShowWindow(0);

	local result_gb = GET_CHILD(frame, "result_gb");
	result_gb:ShowWindow(0);

    local slot_count = GET_UPGRADE_VIROBA_SOURCE_COUNT();
	for i = 1, slot_count do 
		local slot = GET_CHILD_RECURSIVELY(frame, "slot_"..i);
		UPGRADE_VIBORA_SLOT_RESET(slot, i);
	end

	show_windows('text_notice', false)
	show_windows('successPic', true)
	show_windows('successTextPic', true)

	UPGRADE_VIBORA_MATERIAL_UI_RESET();
end

function UPGRADE_VIBORA_MATERIAL_UI_RESET()			
	if IS_CHECK_UPGRADE_VIBORA_RESULT() == true then
		return;
	end

	local frame = ui.GetFrame("upgrade_vibora");
	
	local idx = 1
	for idx = 1, 2 do
		local matrial_slot = GET_CHILD_RECURSIVELY(frame, "matrial_slot_" .. tostring(idx));
		if matrial_slot ~= nil then
			matrial_slot:ClearIcon();
		end
		
		local matrial_name = GET_CHILD_RECURSIVELY(frame, "matrial_name_" .. tostring(idx));
		if matrial_name ~= nil then
			matrial_name:ShowWindow(0);
		end
	
		local matrial_count = GET_CHILD_RECURSIVELY(frame, "matrial_count_" .. tostring(idx));
		if matrial_count ~= nil then
			matrial_count:ShowWindow(0);
		end
	end

	local matrial_count = GET_CHILD_RECURSIVELY(frame, "matrial_silver_count");
	matrial_count:ShowWindow(0);

	local matrial_upbtn = GET_CHILD_RECURSIVELY(frame, "upBtn");
	local matrial_downbtn = GET_CHILD_RECURSIVELY(frame, "downBtn");
	matrial_upbtn:ShowWindow(0);
	matrial_downbtn:ShowWindow(0);
	matrial_upbtn:SetEnable(1);
	matrial_downbtn:SetEnable(1);
	-- local gauge = GET_CHILD_RECURSIVELY(frame, "refine_gauge");
	-- gauge:SetPoint(0, 100)
	-- gauge:ShowWindow(0)
	frame:SetUserValue("Upgrade_Cnt", 1);
	UPGRADE_VIBORA_MATERIAL_INIT();
end

function UPGRADE_VIBORA_SAME_ITEM_CHECK(guid, classname)
	local frame = ui.GetFrame("upgrade_vibora");
	for i = 1, 2 do 
		local slot = GET_CHILD_RECURSIVELY(frame, "slot_"..i);
		if slot:GetIcon() ~= nil then
			if guid == slot:GetUserValue("GUID") then
				return false;
			end
			
			if classname ~= slot:GetUserValue("CLASS_NAME") then
				return false;
			end
		end
	end

	return true;
end

function UPGRADE_VIBORA_ITEM_REG(guid, ctrl, slotIndex)			
	if ui.CheckHoldedUI() == true then
		return;
    end
    
	if IS_CHECK_UPGRADE_VIBORA_RESULT() == true then
		return;
	end

	local invItem = session.GetInvItemByGuid(guid);
	if invItem == nil then
		return;
    end
    
	if invItem.isLockState == true then
		ui.SysMsg(ClMsg("MaterialItemIsLock"));
		return;
	end

	local itemObj = GetIES(invItem:GetObject());	
	local ret, ret_classname, cur_lv = CAN_UPGRADE_VIBORA(itemObj);		
	if ret == false or ret_classname == 'None' or cur_lv == 0 then
		ui.SysMsg(ClMsg('WrongDropItem'))
        return;
	end
	
	local result_item_classname = GET_UPGRADE_VIBORA_ITEM_NAME(itemObj);
	local cls = GetClass('Item', result_item_classname)
	if cls == nil then
		return;
	end

	if UPGRADE_VIBORA_SAME_ITEM_CHECK(guid, ret_classname) == false then
		ui.SysMsg(ClMsg('CanRegisterOnlySameItem'))
		return;
	end

	SET_SLOT_ITEM(ctrl, invItem);
	ctrl:SetUserValue("CLASS_NAME", ret_classname);
	ctrl:SetUserValue("GUID", guid);
	
	local slot_img = GET_CHILD_RECURSIVELY(ctrl, 'slot_img_'.. slotIndex);
	slot_img:ShowWindow(0);

	local refine_count = TryGetProp(itemObj, 'UPGRADE_TRY_COUNT', 0)
	if cur_lv >= 2 then
		local gauge = GET_CHILD_RECURSIVELY(ui.GetFrame("upgrade_vibora"), "refine_gauge_" .. slotIndex)
		gauge:SetPoint(refine_count, GET_UPGRADE_VIBORA_MAX_COUNT(cur_lv + 1))
		gauge:ShowWindow(1);

		show_windows('text_notice', true)

		if slotIndex > 1 and refine_count > 0 then			
			show_windows('text_warning', true)
		end	
	end

	UPGRADE_VIBORA_RESULT_ITEM_INIT(result_item_classname);
	UPGRADE_VIBORA_MATERIAL_INIT();
end

function UPGRADE_VIBORA_ITEM_DROP(parent, ctrl, argStr, slotIndex)
	local liftIcon = ui.GetLiftIcon();
	local FromFrame = liftIcon:GetTopParentFrame();
	if FromFrame:GetName() == 'inventory' then
		local iconInfo = liftIcon:GetInfo();
		UPGRADE_VIBORA_ITEM_REG(iconInfo:GetIESID(), ctrl, slotIndex);
	end
end

function UPGRADE_VIBORA_ITEM_POP(parent, ctrl, argStr, slotIndex)	
	if ui.CheckHoldedUI() == true then
		return;
	end

	UPGRADE_VIBORA_SLOT_RESET(ctrl, slotIndex);
	UPGRADE_VIBORA_MATERIAL_UI_RESET();

	local frame = ui.GetFrame("upgrade_vibora");
	local slot_count = GET_UPGRADE_VIROBA_SOURCE_COUNT();
	local nil_count = slot_count;
	for i = 1, slot_count do 
		local slot = GET_CHILD_RECURSIVELY(frame, "slot_"..i);		
		if slot:GetIcon() == nil then
			nil_count = nil_count - 1;
		end
	end

	if nil_count == 0 then
		local result_gb = GET_CHILD_RECURSIVELY(frame, "result_gb");
		result_gb:ShowWindow(0);
	end	

	if slotIndex == 1 then
		show_windows('text_notice', false)
	end
end

function UPGRADE_VIBORA_RESULT_ITEM_INIT(classname)
	local frame = ui.GetFrame("upgrade_vibora");
	
	local result_gb = GET_CHILD(frame, "result_gb");
	result_gb:ShowWindow(1);
	
	local result_slot = GET_CHILD(result_gb, "result_slot");	
	local itemCls = GetClass("Item", classname);
	SET_SLOT_ITEM_CLS(result_slot, itemCls);
end

function UPGRADE_VIBORA_MATERIAL_INIT()
	local frame = ui.GetFrame("upgrade_vibora");

	local count = 0;
    local slot_count = GET_UPGRADE_VIROBA_SOURCE_COUNT();
	for i = 1, slot_count do 
		local slot = GET_CHILD_RECURSIVELY(frame, "slot_"..i);
		if slot:GetIcon() ~= nil then
			count = count + 1;
		end
	end
	
	local goal_lv = 2

	local slot = GET_CHILD_RECURSIVELY(frame, "slot_1");
	if slot ~= nil and slot:GetIcon() ~= nil then
		local iconInfo = slot:GetIcon():GetInfo()
		if iconInfo ~= nil then
			local invitem = GET_ITEM_BY_GUID(iconInfo:GetIESID());
			if invitem ~= nil then				
				local itemobj = GetIES(invitem:GetObject());
				if itemobj ~= nil then
					if TryGetProp(itemobj, 'GroupName', 'None') == 'Icor' then
						local inheri_name = TryGetProp(itemobj, 'InheritanceItemName', 'None')
						local cls = GetClass('Item', inheri_name)
						if cls ~= nil then
							goal_lv = TryGetProp(cls, 'NumberArg1', 0) + 1
						end
					else
						goal_lv = TryGetProp(itemobj, 'NumberArg1', 0) + 1
					end
				end
			end
		end
		
	end
	
	local dic_misc, dic_size, dic_index = GET_UPGRADE_VIBORA_MISC_LIST(goal_lv)		
	local silver_cost = GET_UPGRADE_VIBORA_SILVER_COST(goal_lv)
	if count == slot_count and dic_misc ~= nil then
		local idx = 1
		for k, v in pairs(dic_misc) do				
			local cls = GetClass('Item', k)
			local material_name = TryGetProp(cls, 'Name', 'None')
			idx = dic_index[TryGetProp(cls, 'ClassName', 'None')]			
			local matrial_name = GET_CHILD_RECURSIVELY(frame, "matrial_name_" .. tostring(idx));
			matrial_name:SetTextByKey("value", material_name);
			matrial_name:ShowWindow(1);			
		end
		
		if silver_cost ~= 0 then
			local material_count = GET_CHILD_RECURSIVELY(frame, "matrial_silver_count")			
			material_count:SetTextByKey("value", GetCommaedText(silver_cost));
			material_count:ShowWindow(1)
		end
	end
end

function UPGRADE_VIBORA_MATERIAL_REG(guid)	
	if ui.CheckHoldedUI() == true then
		return;
    end
    
	if IS_CHECK_UPGRADE_VIBORA_RESULT() == true then
		return;
	end

	local invItem = session.GetInvItemByGuid(guid);
	if invItem == nil then
		return;
    end
    
	if invItem.isLockState == true then
		ui.SysMsg(ClMsg("MaterialItemIsLock"));
		return;
	end

	local frame = ui.GetFrame("upgrade_vibora");
	local goal_lv = 0;
    local slot_count = GET_UPGRADE_VIROBA_SOURCE_COUNT();
	for i = 1, slot_count do 
		local slot = GET_CHILD_RECURSIVELY(frame, "slot_"..i);
		if slot:GetIcon() == nil then
			return;
		else
			local slot_invItem = GET_SLOT_ITEM(slot);
			local slot_itemobj = GetIES(slot_invItem:GetObject());
			local ret, ret_classname, cur_lv = CAN_UPGRADE_VIBORA(slot_itemobj);
			goal_lv = cur_lv + 1; 
		end
	end

	local dic_misc, misc_size, dic_index = GET_UPGRADE_VIBORA_MISC_LIST(goal_lv)		
	if dic_misc == nil then
		return
	end

	local itemObj = GetIES(invItem:GetObject());
	local material_class_name = TryGetProp(itemObj, 'ClassName', 'None')
	
	if IS_UPGARDE_VIBORA_MISC(material_class_name, dic_misc) == false then
		return;
	end

	local material_index = dic_index[material_class_name]	
	local curCnt = GET_INV_ITEM_COUNT_BY_PROPERTY({{Name = "ClassName", Value = itemObj.ClassName}}, false);	

	local need_count = dic_misc[material_class_name]
	local matrial_name = GET_CHILD_RECURSIVELY(frame, "matrial_name_" .. tostring(dic_index[material_class_name]));
	matrial_name:SetTextByKey("value", itemObj.Name);
	matrial_name:ShowWindow(1);

	local matrial_count = GET_CHILD_RECURSIVELY(frame, "matrial_count_" .. tostring(dic_index[material_class_name]));
	matrial_count:ShowWindow(1);
	matrial_count:SetTextByKey("cur", curCnt);
	matrial_count:SetTextByKey("need", need_count);
	
	local matrial_slot = GET_CHILD_RECURSIVELY(frame, "matrial_slot_" .. tostring(dic_index[material_class_name]));
	SET_SLOT_ITEM(matrial_slot, invItem);

	if goal_lv > 2 then
		local matrial_upbtn = GET_CHILD_RECURSIVELY(frame, "upBtn");
		local matrial_downbtn = GET_CHILD_RECURSIVELY(frame, "downBtn");
		matrial_upbtn:ShowWindow(1);
		matrial_downbtn:ShowWindow(1);
	end
end

function UPGRADE_VIBORA_MATERIAL_DROP(parent, ctrl)
	local liftIcon = ui.GetLiftIcon();
	local FromFrame = liftIcon:GetTopParentFrame();
	if FromFrame:GetName() == 'inventory' then
		local iconInfo = liftIcon:GetInfo();
		UPGRADE_VIBORA_MATERIAL_REG(iconInfo:GetIESID());
	end
end

function UPGRADE_VIBORA_MATERIAL_POP(parent, ctrl)
	UPGRADE_VIBORA_MATERIAL_UI_RESET();
end

function UPGRADE_VIBORA_INV_RBTNDOWN(itemObj, slot)
	if ui.CheckHoldedUI() == true then
		return;
	end

	local frame = ui.GetFrame("upgrade_vibora");
	if frame == nil then
		return;
	end

	local icon = slot:GetIcon();
	local iconInfo = icon:GetInfo();
    local slot_count = GET_UPGRADE_VIROBA_SOURCE_COUNT();
	for i = 1, slot_count do 
		local ctrl = GET_CHILD_RECURSIVELY(frame, "slot_"..i);
		if ctrl:GetIcon() == nil then
			UPGRADE_VIBORA_ITEM_REG(iconInfo:GetIESID(), ctrl, i);
			return;
		end
	end

	UPGRADE_VIBORA_MATERIAL_REG(iconInfo:GetIESID())
end

function UPGRADE_VIBORA_BTN_CLICK(parent, ctrl)
	if ui.CheckHoldedUI() == true then
		return;
	end

	local frame = parent:GetTopParentFrame();
	
	session.ResetItemList();
	local goal_lv = 0;
	local slot_count = GET_UPGRADE_VIROBA_SOURCE_COUNT();
	for i = 1, slot_count do 
		local slot = GET_CHILD_RECURSIVELY(frame, "slot_"..i);
		if slot:GetIcon() == nil then
			ui.SysMsg(ClMsg("REQUEST_TAKE_ITEM"));
			return;
		end

		local slot_invItem = GET_SLOT_ITEM(slot);
		local slot_itemobj = GetIES(slot_invItem:GetObject());
		local ret, ret_classname, cur_lv = CAN_UPGRADE_VIBORA(slot_itemobj);
		if ret == false then
			return;
		end
		
		goal_lv = cur_lv + 1;
		local guid = slot:GetUserValue("GUID");
		session.AddItemID(guid, 1);
	end
	
	local dic_misc, dic_size, dic_index = GET_UPGRADE_VIBORA_MISC_LIST(goal_lv)	
	local idx = 1
	
	local upgrade_count = frame:GetUserIValue("Upgrade_Cnt");
	-- 입력된 값을 가져온다.
	
	for idx = 1 , dic_size do
		local matrial_slot = GET_CHILD_RECURSIVELY(frame, "matrial_slot_" .. tostring(idx));			
		local matrial_slot_invItem = GET_SLOT_ITEM(matrial_slot);				
		if matrial_slot_invItem ~= nil then
			local matrial_slot_itemobj = GetIES(matrial_slot_invItem:GetObject());
			
			local curCnt = GET_INV_ITEM_COUNT_BY_PROPERTY({{Name = "ClassName", Value = matrial_slot_itemobj.ClassName}}, false);
			local need_count = dic_misc[matrial_slot_itemobj.ClassName]
			if curCnt < (need_count * upgrade_count) then
				ui.SysMsg(ClMsg('NotEnoughRecipe'));
				return;
			end
		
			session.AddItemID(matrial_slot_invItem:GetIESID(), need_count);				
		else
			if goal_lv > 2 then
				ui.SysMsg(ClMsg('NotEnoughRecipe'));
				return
			else
				if idx == 1 then
					ui.SysMsg(ClMsg('NotEnoughRecipe'));
					return
				end
			end
		end
	end

	local required_silver = GET_UPGRADE_VIBORA_SILVER_COST(goal_lv) * upgrade_count
	if IsGreaterThanForBigNumber(required_silver, GET_TOTAL_MONEY_STR()) == 1 then
		ui.SysMsg(ClMsg('Auto_SilBeoKa_BuJogHapNiDa.'));
		return;
	end
	
	local matrial_upbtn = GET_CHILD_RECURSIVELY(frame, "upBtn");
	local matrial_downbtn = GET_CHILD_RECURSIVELY(frame, "downBtn");
	matrial_upbtn:SetEnable(0);
	matrial_downbtn:SetEnable(0);

	local countList = NewStringList();
	if goal_lv > 2 then
		countList:Add(upgrade_count) 
	end
	local resultlist = session.GetItemIDList();
	item.DialogTransaction("UPGRADE_VIBORA", resultlist, '', countList);
	if goal_lv > 2 then	
		PLAY_EXEC_EFFECT_VIBORA()
	end
end

function release_ui_lock_vibora()
	local frame = ui.GetFrame("upgrade_vibora");
	local EXTRACT_RESULT_EFFECT_NAME = frame:GetUserConfig('EXTRACT_RESULT_EFFECT');

	local result_slot = GET_CHILD_RECURSIVELY(frame, 'start_gb');	
	if result_slot ~= nil then
		result_slot:StopUIEffect('EXTRACT_RESULT_EFFECT', true, 0);		
	end
    ui.SetHoldUI(false)
end

function UPGRADE_VIBORA_SUCCESS(frame, msg, guid)	
	local frame = ui.GetFrame("upgrade_vibora");

	local reinfResultBox = GET_CHILD(frame, "reinfResultBox");
	reinfResultBox:ShowWindow(1);

	local doBtn = GET_CHILD(frame, "doBtn");
	doBtn:ShowWindow(0);

	local resetBtn = GET_CHILD(frame, "resetBtn");
	resetBtn:ShowWindow(1);

	show_windows('successPic', false)	
	show_windows('successItem', true)
	show_windows('completeTextPic', false)

	local invItem = session.GetInvItemByGuid(guid);
	local successItem = GET_CHILD_RECURSIVELY(frame, "successItem");
	SET_SLOT_ITEM(successItem, invItem);	

	local RESULT_EFFECT = frame:GetUserConfig("RESULT_EFFECT");
	local successItem = GET_CHILD_RECURSIVELY(reinfResultBox, "successItem");
	successItem:PlayUIEffect(RESULT_EFFECT, 5, "RESULT_EFFECT", true);	

	ReserveScript('release_ui_effect_for_vibora()', 1);
end

function UPGRADE_VIBORA_FAIL(frame, msg, guid, count)
	local frame = ui.GetFrame("upgrade_vibora");

	local reinfResultBox = GET_CHILD(frame, "reinfResultBox");
	reinfResultBox:ShowWindow(1);

	local doBtn = GET_CHILD(frame, "doBtn");
	doBtn:ShowWindow(0);

	local resetBtn = GET_CHILD(frame, "resetBtn");
	resetBtn:ShowWindow(1);

	show_windows('successPic', false)
	show_windows('completeTextPic', true)
	show_windows('successTextPic', false)	
	

	local invItem = session.GetInvItemByGuid(guid);
	local successItem = GET_CHILD_RECURSIVELY(frame, "successItem");
	SET_SLOT_ITEM(successItem, invItem);	

	show_windows('successItem', true)

	local RESULT_EFFECT = frame:GetUserConfig("RESULT_EFFECT");
	local successItem = GET_CHILD_RECURSIVELY(reinfResultBox, "successItem");
	successItem:PlayUIEffect(RESULT_EFFECT, 5, "RESULT_EFFECT", true);	

	ReserveScript('release_ui_effect_for_vibora()', 1);
end

function IS_CHECK_UPGRADE_VIBORA_RESULT()
	local frame = ui.GetFrame("upgrade_vibora");

	local resetBtn = GET_CHILD(frame, "resetBtn");
	if resetBtn:IsVisible() == 1 then
		return true;
	end

	return false;
end

function UPGRADE_VIBORA_UP_BTN(parent)	
	local frame = parent:GetTopParentFrame();
	local upgradecnt = frame:GetUserIValue("Upgrade_Cnt");
	local matrial_slot = GET_CHILD_RECURSIVELY(frame, "slot_1");	
	local matrial_slot_invItem = GET_SLOT_ITEM(matrial_slot);	
	if matrial_slot_invItem ~= nil then		
		local matrial_slot_itemobj = GetIES(matrial_slot_invItem:GetObject());
		local now = TryGetProp(matrial_slot_itemobj, 'UPGRADE_TRY_COUNT', 0)
		local ret, ret_classname, cur_lv = CAN_UPGRADE_VIBORA(matrial_slot_itemobj);
		if ret == false then
			return;
		end
		local max_count = GET_UPGRADE_VIBORA_MAX_COUNT(cur_lv + 1)		
		if now + upgradecnt + 1 > max_count then
			ui.SysMsg(ClMsg('BeExceedMaxUpgrade'))
			UPGRADE_VIBORA_UPDATE_MISC_SILVER_CNT(frame);
			return		
		end
	end
	frame:SetUserValue("Upgrade_Cnt", upgradecnt + 1);
	UPGRADE_VIBORA_UPDATE_MISC_SILVER_CNT(frame);
end

function UPGRADE_VIBORA_DOWN_BTN(parent)
	local frame = parent:GetTopParentFrame();
	local upgradecnt = frame:GetUserIValue("Upgrade_Cnt");
	if upgradecnt ~= 1 then
		frame:SetUserValue("Upgrade_Cnt", upgradecnt - 1);
		UPGRADE_VIBORA_UPDATE_MISC_SILVER_CNT(frame);
	end
end

function UPGRADE_VIBORA_UPDATE_MISC_SILVER_CNT(frame)
	local goal_lv = 0;
	local slot_count = GET_UPGRADE_VIROBA_SOURCE_COUNT();
	for i = 1, slot_count do 
		local slot = GET_CHILD_RECURSIVELY(frame, "slot_"..i);
		if slot:GetIcon() == nil then
			ui.SysMsg(ClMsg("REQUEST_TAKE_ITEM"));
			return;
		end

		local slot_invItem = GET_SLOT_ITEM(slot);
		local slot_itemobj = GetIES(slot_invItem:GetObject());
		local ret, ret_classname, cur_lv = CAN_UPGRADE_VIBORA(slot_itemobj);
		if ret == false then
			return;
		end
		
		goal_lv = cur_lv + 1;
	end
	
	local dic_misc, dic_size, dic_index = GET_UPGRADE_VIBORA_MISC_LIST(goal_lv)	
	local idx = 1
	
	local upgrade_count = frame:GetUserIValue("Upgrade_Cnt");

	for idx = 1 , dic_size do
		local matrial_slot = GET_CHILD_RECURSIVELY(frame, "matrial_slot_" .. tostring(idx));			
		local matrial_slot_invItem = GET_SLOT_ITEM(matrial_slot);				
		if matrial_slot_invItem ~= nil then
			local matrial_slot_itemobj = GetIES(matrial_slot_invItem:GetObject());
			local curCnt = GET_INV_ITEM_COUNT_BY_PROPERTY({{Name = "ClassName", Value = matrial_slot_itemobj.ClassName}}, false);
			local need_count = dic_misc[matrial_slot_itemobj.ClassName]
			
			if curCnt < (need_count * upgrade_count) then
				ui.SysMsg(ClMsg('NotEnoughRecipe'));
				frame:SetUserValue("Upgrade_Cnt", upgrade_count - 1);
				return;
			end
		end
	end

	local required_silver = GET_UPGRADE_VIBORA_SILVER_COST(goal_lv) * upgrade_count
	if IsGreaterThanForBigNumber(required_silver, GET_TOTAL_MONEY_STR()) == 1 then
		ui.SysMsg(ClMsg('Auto_SilBeoKa_BuJogHapNiDa.'));
		frame:SetUserValue("Upgrade_Cnt", upgrade_count - 1);
		return;
	end
	for idx = 1 , dic_size do
		local matrial_slot = GET_CHILD_RECURSIVELY(frame, "matrial_slot_" .. tostring(idx));			
		local matrial_slot_invItem = GET_SLOT_ITEM(matrial_slot);				
		if matrial_slot_invItem ~= nil then
			local matrial_slot_itemobj = GetIES(matrial_slot_invItem:GetObject());
			local curCnt = GET_INV_ITEM_COUNT_BY_PROPERTY({{Name = "ClassName", Value = matrial_slot_itemobj.ClassName}}, false);
			local need_count = dic_misc[matrial_slot_itemobj.ClassName]
			local matrial_count = GET_CHILD_RECURSIVELY(frame, "matrial_count_" .. tostring(dic_index[matrial_slot_itemobj.ClassName]));
			matrial_count:SetTextByKey("cur", curCnt);
			matrial_count:SetTextByKey("need", need_count * upgrade_count);
		end
	end
	local material_count = GET_CHILD_RECURSIVELY(frame, "matrial_silver_count")			
	material_count:SetTextByKey("value", GetCommaedText(required_silver));
end