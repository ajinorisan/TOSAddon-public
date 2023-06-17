-- 산드라의 무료 감정 돋보기
function ITEMRANDOMFREE_ON_INIT(addon, frame)
	addon:RegisterMsg("MSG_SUCCESS_FREE_RANDOM_OPTION", "SUCCESS_FREE_RANDOM_OPTION");
end

function OPEN_FREE_RANDOM_OPTION(invItem)
	for i = 1, #revertrandomitemlist do
		local frame = ui.GetFrame(revertrandomitemlist[i]);
		if frame ~= nil and frame:IsVisible() == 1 and revertrandomitemlist[i] ~= "itemrandomfree" then
			return;
		end
	end

	local item = GetIES(invItem:GetObject());
	local frame = ui.GetFrame('itemrandomfree');
	frame:SetUserValue('REVERTITEM_GUID', invItem:GetIESID());
	frame:SetUserValue("CLASS_ID", item.ClassID);

	local slot = GET_CHILD_RECURSIVELY(frame, "slot", "ui::CSlot");
	slot:ClearIcon();

	local richtext_1 = GET_CHILD_RECURSIVELY(frame, "richtext_1");
	richtext_1:SetTextByKey("value", item.Name);	
		
	local sendOK = GET_CHILD_RECURSIVELY(frame, "send_ok")
	sendOK:ShowWindow(0)

	local do_sandrarevertrandom = GET_CHILD_RECURSIVELY(frame, "do_sandrarevertrandom")
	do_sandrarevertrandom:ShowWindow(1)

	frame:ShowWindow(1);
end

function ITEM_FREE_RANDOM_OPTION_OPEN(frame)
	ui.OpenFrame("inventory")

	local tab = GET_CHILD_RECURSIVELY(ui.GetFrame("inventory"), "inventype_Tab");	
	tolua.cast(tab, "ui::CTabControl");
	tab:SelectTab(0);

	INVENTORY_SET_CUSTOM_RBTNDOWN("ITEM_FREE_RANDOM_OPTION_INV_RBTN")
end

function ITEM_FREE_RANDOM_OPTION_CLOSE(frame)
	if ui.CheckHoldedUI() == true then
		return;
	end
	INVENTORY_SET_CUSTOM_RBTNDOWN("None");
	frame:ShowWindow(0);
	control.DialogOk();
end

function ITEM_FREE_RANDOM_OPTION_CHECKBOX_CHECK(parent, ctrl)
	local frame = parent:GetTopParentFrame()
	if ctrl:IsChecked() == 1 then
		local tuto_prop = frame:GetUserValue('TUTO_PROP')
		if tuto_prop == 'UITUTO_GLASS2' then
			local tuto_value = GetUITutoProg(tuto_prop)
			if tuto_value == 1 then
				pc.ReqExecuteTx('SCR_UI_TUTORIAL_NEXT_STEP', tuto_prop)
			end
		end
	end
end

function SENDOK_ITEM_FREE_RANDOM_OPTION_UI()
	local frame = ui.GetFrame("itemrandomfree");

	local slot = GET_CHILD_RECURSIVELY(frame, "slot");
	local icon = slot:GetIcon();
	local iconInfo = icon:GetInfo();
	slot:ClearIcon();
	
	local sendOK = GET_CHILD_RECURSIVELY(frame, "send_ok")
	sendOK:ShowWindow(0)

	local do_sandrarevertrandom = GET_CHILD_RECURSIVELY(frame, "do_sandrarevertrandom")
	do_sandrarevertrandom:ShowWindow(1)

	local slot_bg_image = GET_CHILD_RECURSIVELY(frame, "slot_bg_image")
	slot_bg_image:ShowWindow(1)
end

function ITEM_FREE_RANDOM_OPTION_DROP(frame, icon, argStr, argNum)
	if ui.CheckHoldedUI() == true then
		return;
	end

	local liftIcon 				= ui.GetLiftIcon();
	local FromFrame 			= liftIcon:GetTopParentFrame();
	local toFrame				= frame:GetTopParentFrame();
	
	if FromFrame:GetName() == 'inventory' then
		local iconInfo = liftIcon:GetInfo();
	
		local invItem = session.GetInvItemByGuid(iconInfo:GetIESID())
		if invItem == nil then return; end
		local itemObj = GetIES(invItem:GetObject());
		if TryGetProp(itemObj, 'UseLv', 1) < 430 then
			ui.SysMsg(ScpArgMsg('CanUseGreaterThan430'))
			return
		end

		local guid = toFrame:GetUserValue('REVERTITEM_GUID')
		local mat_item = GetIES(session.GetInvItemByGuid(guid):GetObject())
		local mat_lv = TryGetProp(mat_item, 'NumberArg1', 0)
		if mat_lv ~= 0 then
			if TryGetProp(itemObj, 'UseLv', 1) > mat_lv then
				ui.SysMsg(ClMsg('ItemLevelIsGreaterThanMatItem'))
				return
			end
		end

		ITEM_FREE_RANDOM_OPTION_REG_TARGETITEM(toFrame, iconInfo:GetIESID());
	end
end

-- 슬롯에 아이템 등록 시 아이템 옵션 관련 UI 정보 갱신
function ITEM_FREE_RANDOM_OPTION_REG_TARGETITEM(frame, itemID)
	if ui.CheckHoldedUI() == true then
		return;
	end
	local invItem = session.GetInvItemByGuid(itemID)
	if invItem == nil then
		return;
	end

	local obj = GetIES(invItem:GetObject());
	local itemCls = GetClassByType('Item', obj.ClassID)

	if TryGetProp(itemCls, "NeedRandomOption") == nil or itemCls.NeedRandomOption ~= 1 then
		ui.SysMsg(ClMsg("NotAllowedRandomReset"));
		return;
	end

	if IS_NEED_APPRAISED_ITEM(obj) ~= false and IS_NEED_RANDOM_OPTION_ITEM(obj) ~= false then 
		ui.SysMsg(ClMsg("AppraisdEquip"));
		return;
	end
		
	if invItem.isLockState == true then
		ui.SysMsg(ClMsg("MaterialItemIsLock"));
		return;
	end

	local invframe = ui.GetFrame("inventory");

	local putOnItem = GET_CHILD_RECURSIVELY(frame, "text_putonitem")
	putOnItem:ShowWindow(0)

	local slot_bg_image = GET_CHILD_RECURSIVELY(frame, "slot_bg_image")
	slot_bg_image:ShowWindow(0)

	local itemName = GET_CHILD_RECURSIVELY(frame, "text_itemname")
	itemName:SetText(obj.Name);

	local slot = GET_CHILD_RECURSIVELY(frame, "slot");
	SET_SLOT_ITEM(slot, invItem);

	frame:SetUserValue("RANDOM_PROP_CNT", cnt);	
end

function ITEM_FREE_RANDOM_OPTION_EXEC(frame)
	frame = frame:GetTopParentFrame();
	local slot = GET_CHILD_RECURSIVELY(frame, "slot");
	local invItem = GET_SLOT_ITEM(slot);
	
	if invItem == nil then
		return;
	end

	if invItem.isLockState == true then
		ui.SysMsg(ClMsg("MaterialItemIsLock"));
		return;
	end

	local item_obj = GetIES(invItem:GetObject())
	if item_obj == nil then
		return;
	end

	if item_obj.NeedRandomOption == 0 then
		ui.SysMsg(ClMsg("AppraisdEquip"));
		return;
	end
	
	_ITEM_FREE_RANDOM_OPTION_EXEC()
end

function _ITEM_FREE_RANDOM_OPTION_EXEC()
	local frame = ui.GetFrame("itemrandomfree");
	if frame:IsVisible() == 0 then
		return;
	end
	
	local slot = GET_CHILD_RECURSIVELY(frame, "slot");
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

	if ui.GetFrame("apps") ~= nil then
		ui.CloseFrame("apps")
	end

	local revertItemGUID = frame:GetUserValue('REVERTITEM_GUID');
	local revertItem = session.GetInvItemByGuid(revertItemGUID);
	if revertItem == nil then
		revertItemGUID = GET_NEXT_ITEM_GUID_BY_CLASSID(frame:GetUserValue("CLASS_ID"));
	end

	session.ResetItemList();
	session.AddItemID(revertItemGUID);
	session.AddItemID(invItem:GetIESID());
	local resultlist = session.GetItemIDList();
	local optionList = NewStringList();

	item.DialogTransaction("REVERT_ITEM_OPTION", resultlist, "", optionList);
end

function SUCCESS_FREE_RANDOM_OPTION(frame, msg, argStr, argNum)
	local RESET_SUCCESS_EFFECT_NAME = frame:GetUserConfig('RESET_SUCCESS_EFFECT');
	local EFFECT_SCALE = tonumber(frame:GetUserConfig('EFFECT_SCALE'));
	local EFFECT_DURATION = tonumber(frame:GetUserConfig('EFFECT_DURATION'));
	local pic_bg = GET_CHILD_RECURSIVELY(frame, 'pic_bg');
	if pic_bg == nil then
		return;
	end

	pic_bg:PlayUIEffect(RESET_SUCCESS_EFFECT_NAME, EFFECT_SCALE, 'RESET_SUCCESS_EFFECT');

	local do_sandrarevertrandom = GET_CHILD_RECURSIVELY(frame, "do_sandrarevertrandom")
	do_sandrarevertrandom:ShowWindow(0)

	ui.SetHoldUI(true);
	
	ReserveScript("_SUCCESS_FREE_RANDOM_OPTION()", EFFECT_DURATION)
end

function _SUCCESS_FREE_RANDOM_OPTION()
	ui.SetHoldUI(false);
	local frame = ui.GetFrame("itemrandomfree");
	if frame:IsVisible() == 0 then
		return;
	end

	local slot = GET_CHILD_RECURSIVELY(frame, "slot");
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

	local sendOK = GET_CHILD_RECURSIVELY(frame, "send_ok")
	sendOK:ShowWindow(1)

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
	
end

-- 슬롯에서 마우스 오른쪽 버튼클릭 시 등록된 아이템 해제
function REMOVE_ITEM_FREE_RANDOM_OPTION_TARGET_ITEM(frame)
	if ui.CheckHoldedUI() == true then
		return;
	end

	frame = frame:GetTopParentFrame();
	local slot = GET_CHILD_RECURSIVELY(frame, "slot");
	slot:ClearIcon();
end

-- 인벤토리에서 마우스 오른쪽 버튼을 이용해 슬롯에 아이템 등록
function ITEM_FREE_RANDOM_OPTION_INV_RBTN(itemObj, slot)	
	local frame = ui.GetFrame("itemrandomfree");
	if frame == nil then
		return;
	end

	local icon = slot:GetIcon();
	local iconInfo = icon:GetInfo();
	local invItem = GET_PC_ITEM_BY_GUID(iconInfo:GetIESID());
	local obj = GetIES(invItem:GetObject());
	
	local slot = GET_CHILD_RECURSIVELY(frame, "slot");
	local slotInvItem = GET_SLOT_ITEM(slot);

	ITEM_FREE_RANDOM_OPTION_REG_TARGETITEM(frame, iconInfo:GetIESID()); 
end