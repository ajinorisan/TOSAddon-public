
function VIBORA_WEAPON_TRADE_ON_INIT(addon, frame)
	addon:RegisterMsg("OPEN_DLG_VIBORA_WEAPON_TRADE", "ON_OPEN_DLG_VIBORA_WEAPON_TRADE");
	addon:RegisterMsg("VIBORA_WEAPON_TRADE_SUCCESS", "VIBORA_WEAPON_TRADE_SUCCESS");
	addon:RegisterMsg("EVENT_2011_5TH_VIBORA_COMPOSITE_SUCCESS", "VIBORA_WEAPON_TRADE_SUCCESS");
end

function ON_OPEN_DLG_VIBORA_WEAPON_TRADE()
	local frame = ui.GetFrame("vibora_weapon_trade");
	frame:ShowWindow(1);
end

function VIBORA_WEAPON_TRADE_OPEN(frame)
	local title = GET_CHILD(frame, "title");
	title:SetTextByKey("value", frame:GetUserConfig("TITLE_COMMON"));

	local helpPic = GET_CHILD(frame, "helpPic");
	helpPic:SetTextTooltip(ClMsg("Vibora_Weapon_Trade_help"));

    VIBORA_WEAPON_TRADE_UI_RESET();
	
	INVENTORY_SET_CUSTOM_RBTNDOWN("VIBORA_WEAPON_TRADE_INV_RBTNDOWN");
	ui.OpenFrame("inventory");
end

function VIBORA_WEAPON_TRADE_CLOSE(frame)
	if ui.CheckHoldedUI() == true then
		return;
	end

	INVENTORY_SET_CUSTOM_RBTNDOWN("None");

    frame:ShowWindow(0);
end

function VIBORA_WEAPON_TRADE_SLOT_RESET(slot, slotIndex)	
	if IS_CHECK_VIBORA_WEAPON_TRADE_RESULT() == true then
		return;
	end

	slot:SetUserValue("CLASS_NAME", "None");
	slot:SetUserValue("GUID", "None");
	slot:SetText("", "count", ui.RIGHT, ui.BOTTOM, -5, -5);
	slot:ClearIcon();
	slot:SetBgImage("socket_slot_bg");
	slot:SetBgImageSize(slot:GetWidth() - 16, slot:GetHeight() - 16);
end

function VIBORA_WEAPON_TRADE_UI_RESET()
	local frame = ui.GetFrame("vibora_weapon_trade");
	frame:SetUserValue("MAIN_VIBORA_CLASSNAME", "None");
	frame:SetUserValue("TRADE_VIBORA_CLASSNAME", "None");
	
	local reinfResultBox = GET_CHILD(frame, "reinfResultBox");
	reinfResultBox:ShowWindow(0);

	local do_Btn = GET_CHILD(frame, "do_Btn");
	do_Btn:ShowWindow(1);

	local resetBtn = GET_CHILD(frame, "resetBtn");
	resetBtn:ShowWindow(0);

    local need_count = GET_VIBORA_WEAPON_TRADE_SOURCE_COUNT();
	for i = 1, need_count do 
		local slot = GET_CHILD(frame, "slot_"..i);
		VIBORA_WEAPON_TRADE_SLOT_RESET(slot, i);
	end
end

function VIBORA_WEAPON_TRADE_INV_RBTNDOWN(itemObj, slot)
	if ui.CheckHoldedUI() == true then
		return;
	end

	local frame = ui.GetFrame("vibora_weapon_trade");
	if frame == nil then
		return;
	end

	local icon = slot:GetIcon();
	local iconInfo = icon:GetInfo();
	local guid = iconInfo:GetIESID();
	
	-- 메인 재료 인지 확인
	if VIBORA_WEAPON_TRADE_MAIN_MAT_CHECK(itemObj) == true then
		local ctrl = GET_CHILD(frame, "slot_1");
		VIBORA_WEAPON_TRADE_MAIN_MAT_REG(guid, ctrl);
		return;
	end

	-- 서브 재료 인지 확인
	local index = GET_FIRST_EMPTY_SUB_SLOT_INDEX(frame);
	if index == 0 then return; end

	if VIBORA_WEAPON_TRADE_SUB_MAT_CHECK(itemObj, index) == true then
		local ctrl = GET_CHILD(frame, "slot_"..index);
		VIBORA_WEAPON_TRADE_SUB_MAT_REG(guid, ctrl, index);
		return;
	end
end


function VIBORA_WEAPON_TRADE_MAIN_MAT_CHECK(itemObj)
	local frame = ui.GetFrame("vibora_weapon_trade");
	local ret, ret_classname = IS_VIRORA_ITEM(itemObj, 4);
    if ret == false or ret_classname == 'None' then
        return false;
	end

	local tradeVCN = frame:GetUserValue("TRADE_VIBORA_CLASSNAME");
	if tradeName ~= "None" then
		local mainVCN = GET_LV1_VIBORA_CLASS_NAME(ret_classname, 4);
		if tradeVCN == mainVCN then
			ui.SysMsg(ClMsg("Vibora_Weapon_Trade_Msg2"));
			return false;
		end
	end

	return true;
end

function VIBORA_WEAPON_TRADE_MAIN_MAT_REG(guid, ctrl)
	if ui.CheckHoldedUI() == true then
		return;
    end
    
	if IS_CHECK_VIBORA_WEAPON_TRADE_RESULT() == true then
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
	local ret, ret_classname = IS_VIRORA_ITEM(itemObj, 4);
    if ret == false or ret_classname == 'None' then
        return false;
	end

	SET_SLOT_ITEM(ctrl, invItem);
	ctrl:SetUserValue("GUID", guid);
	ctrl:SetBgImageSize(0, 0);
	
    local mainVCN = GET_LV1_VIBORA_CLASS_NAME(ret_classname, 4);

	local frame = ui.GetFrame("vibora_weapon_trade");
	frame:SetUserValue("MAIN_VIBORA_CLASSNAME", mainVCN);
end

function VIBORA_WEAPON_TRADE_MAIN_MAT_DROP(parent, ctrl, argStr, slotIndex)
	local liftIcon = ui.GetLiftIcon();
	local FromFrame = liftIcon:GetTopParentFrame();
	if FromFrame:GetName() == 'inventory' then
		local iconInfo = liftIcon:GetInfo();
		local guid = iconInfo:GetIESID();
		local invItem = session.GetInvItemByGuid(guid);
		local itemObj = GetIES(invItem:GetObject());
		VIBORA_WEAPON_TRADE_MAIN_MAT_REG(guid, ctrl);
	end
end

function VIBORA_WEAPON_TRADE_MAIN_MAT_POP(parent, ctrl, argStr, slotIndex)
	if ui.CheckHoldedUI() == true then
		return;
	end

	VIBORA_WEAPON_TRADE_SLOT_RESET(ctrl, slotIndex);

	local frame = ui.GetFrame("vibora_weapon_trade");
	frame:SetUserValue("MAIN_VIBORA_CLASSNAME", "None");
end


function VIBORA_WEAPON_TRADE_SUB_MAT_CHECK(itemObj, slotIndex)
	local frame = ui.GetFrame("vibora_weapon_trade");

	if slotIndex < 1 or GET_VIBORA_WEAPON_TRADE_SOURCE_COUNT() < slotIndex then
		return false;
	end

	local ret, ret_classname = IS_VIRORA_ITEM(itemObj, 2);
    if ret == false or ret_classname == 'None' then
        return false;
	end

	local subVCN = GET_LV1_VIBORA_CLASS_NAME(ret_classname, 2);
	local tradeVCN = frame:GetUserValue("TRADE_VIBORA_CLASSNAME");
	if tradeVCN ~= "None" then
		if tradeVCN ~= subVCN then
			ui.SysMsg(ClMsg("Vibora_Weapon_Trade_Msg1"));
			return false;
		end
	end

	local mainVCN = frame:GetUserValue("MAIN_VIBORA_CLASSNAME");
	if mainVCN ~= "None" then
		if mainVCN == subVCN then
			ui.SysMsg(ClMsg("Vibora_Weapon_Trade_Msg2"));
			return false;
		end
	end

	local guid = GetIESID(itemObj);
	local need_count = GET_VIBORA_WEAPON_TRADE_SOURCE_COUNT()
	for i = 1, need_count do 
		if slotIndex ~= i then
			local slot = GET_CHILD(frame, "slot_"..i);
			if slot:GetIcon() ~= nil and guid == slot:GetUserValue("GUID") then
				return false;
			end
		end		
	end

	return true;
end

function VIBORA_WEAPON_TRADE_SUB_MAT_REG(guid, ctrl, slotIndex)
	if ui.CheckHoldedUI() == true then
		return;
    end
    
	if IS_CHECK_VIBORA_WEAPON_TRADE_RESULT() == true then
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

	SET_SLOT_ITEM(ctrl, invItem);
	ctrl:SetUserValue("GUID", guid);
	ctrl:SetBgImageSize(0, 0);
	
	local frame = ui.GetFrame("vibora_weapon_trade");
	local tradeitem = frame:GetUserValue("TRADE_VIBORA_CLASSNAME");
	if tradeitem == "None" then
		local itemObj = GetIES(invItem:GetObject());
		local ret, ret_className = IS_VIRORA_ITEM(itemObj, 2);
		local tradeVCN = GET_LV1_VIBORA_CLASS_NAME(ret_className, 2);
		frame:SetUserValue("TRADE_VIBORA_CLASSNAME", tradeVCN);
	end


end

function VIBORA_WEAPON_TRADE_SUB_MAT_DROP(parent, ctrl, argStr, slotIndex)
	local liftIcon = ui.GetLiftIcon();
	local FromFrame = liftIcon:GetTopParentFrame();
	if FromFrame:GetName() == 'inventory' then
		local iconInfo = liftIcon:GetInfo();
		local guid = iconInfo:GetIESID();
		local invItem = session.GetInvItemByGuid(guid);
		local itemObj = GetIES(invItem:GetObject());
		if VIBORA_WEAPON_TRADE_SUB_MAT_CHECK(itemObj, slotIndex) == false then
			return;
		end

		VIBORA_WEAPON_TRADE_SUB_MAT_REG(guid, ctrl, slotIndex);
	end
end

function VIBORA_WEAPON_TRADE_SUB_MAT_POP(parent, ctrl, argStr, slotIndex)
	if ui.CheckHoldedUI() == true then
		return;
	end

	VIBORA_WEAPON_TRADE_SLOT_RESET(ctrl, slotIndex);

	local frame = parent:GetTopParentFrame();

	local cnt = 0;
	local need_count = GET_VIBORA_WEAPON_TRADE_SOURCE_COUNT()
	for i = 2, need_count do 
		local slot = GET_CHILD(frame, "slot_"..i);
		if slot:GetIcon() ~= nil then
			return;
		end
	end

	-- 보조 재료 다 해제 시
	if cnt == 0 then
		frame:SetUserValue("TRADE_VIBORA_CLASSNAME", "None");
	end
end


function VIBORA_WEAPON_TRADE_BTN_CLICK(parent, ctrl)
	if ui.CheckHoldedUI() == true then
		return;
	end

	local frame = parent:GetTopParentFrame();
	
    local need_count = GET_VIBORA_WEAPON_TRADE_SOURCE_COUNT();
	for i = 1, need_count do 
		local slot = GET_CHILD(frame, "slot_"..i);
		if slot:GetIcon() == nil then
			ui.SysMsg(ClMsg('NotEnoughMaterial'));
			return;
		end
	end

	local main, trade = GET_RESULT_VIBORA_ITEM_NAME(frame);
	local str = ScpArgMsg("Vibora_Weapon_Trade_check_Msg{ITEM}{TARGET}", "ITEM", main, "TARGET", trade);
	local msgBox = ui.MsgBox(str, "VIBORA_WEAPON_TRADE", "VIBORA_WEAPON_TRADE_UNFREEZE");
end

function VIBORA_WEAPON_TRADE()
	local frame = ui.GetFrame("vibora_weapon_trade");

	session.ResetItemList();
    local need_count = GET_VIBORA_WEAPON_TRADE_SOURCE_COUNT();
	for i = 1, need_count do 
		local slot = GET_CHILD(frame, "slot_"..i);
		if slot:GetIcon() == nil then
			ui.SysMsg(ClMsg('NotEnoughMaterial'));
			return;
		end

		local invItem = GET_SLOT_ITEM(slot);
		local itemObj = GetIES(invItem:GetObject());
		if i == 1 then
			if VIBORA_WEAPON_TRADE_MAIN_MAT_CHECK(itemObj) == false then
				return;
			end
		else
			if VIBORA_WEAPON_TRADE_SUB_MAT_CHECK(itemObj, i) == false then
				return;
			end
		end

		local guid = slot:GetUserValue("GUID");
		session.AddItemID(guid, 1);
	end

	ui.SetHoldUI(true);
	ReserveScript("VIBORA_WEAPON_TRADE_UNFREEZE()", 3);

	local resultlist = session.GetItemIDList();
	item.DialogTransaction("VIBORA_WEAPON_TRADE", resultlist);
end

function VIBORA_WEAPON_TRADE_UNFREEZE()	
	ui.SetHoldUI(false);
end

function VIBORA_WEAPON_TRADE_SUCCESS(frame, msg, guid)
	local frame = ui.GetFrame("vibora_weapon_trade");

	local reinfResultBox = GET_CHILD(frame, "reinfResultBox");
	reinfResultBox:ShowWindow(1);

	local do_Btn = GET_CHILD(frame, "do_Btn");
	do_Btn:ShowWindow(0);

	local resetBtn = GET_CHILD(frame, "resetBtn");
	resetBtn:ShowWindow(1);

	local invItem = session.GetInvItemByGuid(guid);
	local successItem = GET_CHILD_RECURSIVELY(frame, "successItem");
	SET_SLOT_ITEM(successItem, invItem);	

	local RESULT_EFFECT = frame:GetUserConfig("RESULT_EFFECT");
	local successItem = GET_CHILD_RECURSIVELY(reinfResultBox, "successItem");
	successItem:PlayUIEffect(RESULT_EFFECT, 5, "RESULT_EFFECT", true);	
end

function IS_CHECK_VIBORA_WEAPON_TRADE_RESULT()
	local frame = ui.GetFrame("vibora_weapon_trade");

	local resetBtn = GET_CHILD(frame, "resetBtn");
	if resetBtn:IsVisible() == 1 then
		return true;
	end

	return false;
end

function GET_FIRST_EMPTY_SUB_SLOT_INDEX(frame)
	local need_count = GET_VIBORA_WEAPON_TRADE_SOURCE_COUNT();
	for i = 2, need_count do 
		local ctrl = GET_CHILD(frame, "slot_"..i);
		if ctrl:GetIcon() == nil then
			return i;
		end
	end

	return 0;
end

function GET_RESULT_VIBORA_ITEM_NAME(frame)
	local mainVCN = frame:GetUserValue("MAIN_VIBORA_CLASSNAME");
	local mainClsName = GET_LV_VIBORA_CLASS_NAME(mainVCN, 4);
	local maincls = GetClass("Item", mainClsName);

	local tradeVCN = frame:GetUserValue("TRADE_VIBORA_CLASSNAME");
	local tradeClsName = GET_LV_VIBORA_CLASS_NAME(tradeVCN, 4);
	local tradecls = GetClass("Item", tradeClsName);

	return TryGetProp(maincls, "Name", "None"), TryGetProp(tradecls, "Name", "None");
end