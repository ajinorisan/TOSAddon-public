-- legendcardupgrade.lua


function LEGENDCARDUPGRADE_ON_INIT(addon, frame)
end

function OPEN_LEGENDCARD_REINFORCE(frame)
	LEGENDCARD_UPGRADE_SLOT_CLEAR(frame, 3);
	ui.OpenFrame("inventory");
end

function CLOSE_LEGENDCARD_REINFORCE(frame)
	if ui.CheckHoldedUI() == true then
		return;
	end

	LEGENDCARD_UPGRADE_SLOT_CLEAR(frame, 3);
	ui.CloseFrame("inventory");
	ui.CloseFrame("legendcardupgrade");	
end

-- clearType
-- 1: 성공
-- 2: 실패
-- 3: 파괴
-- 0:
function LEGENDCARD_UPGRADE_SLOT_CLEAR(frame, clearType)
	local frame = ui.GetFrame('legendcardupgrade')
	
	--메인 카드
	local legendCardSlot = GET_CHILD_RECURSIVELY(frame, "LEGcard_slot")
	if clearType == 3 then
		legendCardSlot:ClearIcon()
		legendCardSlot:SetText("")
		local legendCardNameGbox = GET_CHILD_RECURSIVELY(frame, 'legendcardnameGbox')
		legendCardNameGbox:ShowWindow(0)
		local lv_bg = GET_CHILD_RECURSIVELY(frame, 'lv_bg')
		lv_bg:ShowWindow(0)
		
		local success_box = GET_CHILD_RECURSIVELY(frame, 'success_box')
		local success_percent = GET_CHILD(success_box, 'success_percent')
		success_percent:SetTextByKey("text",ScpArgMsg("AdvancedCardReinforceSuccessProb"))
		success_box:ShowWindow(1)
		local else_box = GET_CHILD_RECURSIVELY(frame, 'else_box')
		else_box:ShowWindow(1)

		frame:SetUserValue('GODDESS_GOAL_LV', 0)
	end
	--재료 카드
	for i = 1, 4 do
		local materialCardSlot = GET_CHILD_RECURSIVELY(frame, "material_slot" .. i)
		materialCardSlot:ClearIcon()
		materialCardSlot:SetText("")
	end		
	--재료 아이템
	local materialItemSlot = GET_CHILD_RECURSIVELY(frame, "materialItem_slot")
	if clearType == 3 then
		materialItemSlot:SetText("")
		materialItemSlot:ClearIcon()
	end
	
	local upgradeBtn = GET_CHILD_RECURSIVELY(frame, "upgradeBtn")
	upgradeBtn:SetTextByKey("value", ClMsg("Reinforce_2"))
	frame:SetUserValue("IsVisibleResult", 0)
	local resultGbox = GET_CHILD_RECURSIVELY(frame, "resultGbox")
	resultGbox:ShowWindow(0)
	local resultGbox2 = GET_CHILD_RECURSIVELY(frame, "resultGbox2")
	resultGbox2:ShowWindow(0)
	INV_APPLY_TO_ALL_SLOT(_G["LEGENDCARD_REINFORCE_RECOVER_ICON"])

	if legendCardSlot ~= nil then
		local legendSlotGuid = LEGENDCARD_REINFORCE_GET_GUID_BY_SLOT(legendCardSlot)
		local legendSlotItem = session.GetInvItemByGuid(legendSlotGuid);
		LEGENDCARD_REINFORCE_INV_RBTN(legendSlotItem, legendCardSlot)
	end
	CALC_UPGRADE_PERCENTS(frame)
end
--메인카드 레벨 세팅
function LEGENDCARD_UPGRADE_MAINSLOT_UPDATE(frame)
	local slot = GET_CHILD_RECURSIVELY(frame, "LEGcard_slot")
	local guid = LEGENDCARD_REINFORCE_GET_GUID_BY_SLOT(slot)
	local invItem = GET_ITEM_BY_GUID(guid)
	if invItem == nil then
		return
	end
	local obj = GetIES(invItem:GetObject())
	slot:SetText("")
	SET_SLOT_ITEM_TEXT_USE_INVCOUNT(slot, invItem, obj, 1);
	if TryGetProp(obj, "Reinforce_Type", "None") == "GoddessCard" then
		local cur_lv = GET_ITEM_LEVEL(obj)
		if cur_lv < 10 then
			GODDESS_CARD_SET_LEVEL_INFO(frame, cur_lv + 1)
		end
	end
end

--우클릭 카드 제거
function MATERIAL_CARD_SLOT_RBTNUP_ITEM_INFO(parent, slot, argStr, argNum)
	local frame = slot:GetTopParentFrame()
	if frame == nil then
		return
	end
	
	if slot:GetName() == 'LEGcard_slot' then
		LEGENDCARD_UPGRADE_SLOT_CLEAR(frame, 3)
	else
		local legendSlot = GET_CHILD_RECURSIVELY(frame, "LEGcard_slot")
		local legendSlotGuid = LEGENDCARD_REINFORCE_GET_GUID_BY_SLOT(legendSlot)
		local legendSlotItem = session.GetInvItemByGuid(legendSlotGuid)
		if legendSlotItem == nil then return end

		local legendCardObj = GetIES(legendSlotItem:GetObject())
		if TryGetProp(legendCardObj, "Reinforce_Type", "None") == "GoddessCard" then return end

		LEGENDCARD_REINFORCE_RECOVER_INVICON(slot)
		slot:ClearIcon();
		slot:SetText("");
		CALC_UPGRADE_PERCENTS(frame)
	end
end

-- 몬스터 카드를 카드 슬롯에 드레그드롭으로 장착하려 할 경우.
function MATERIAL_CARD_SLOT_DROP(frame, slot, argStr, argNum)
	local liftIcon 				= ui.GetLiftIcon();
	local FromFrame 			= liftIcon:GetTopParentFrame();
	local toFrame				= frame:GetTopParentFrame();

	local iconInfo = liftIcon:GetInfo();
	if iconInfo == nil then
		return
	end

	local invItem = session.GetInvItem(iconInfo.ext);		
	if nil == invItem then
		return;
	end
	
	local obj = GetIES(invItem:GetObject())
	if obj == nil then
		return
	end

	if slot:GetName() == 'LEGcard_slot' then
		LEGENDCARD_SET_SLOT(slot, invItem)
	else
		LEGENDCARD_MATERIAL_SET_SLOT(slot, invItem);
	end
end
	
function LEGENDCARD_SET_SLOT(slot, invItem)	
	local frame = ui.GetFrame('legendcardupgrade');
	if frame == nil then return end

	-- 업그레이드 이후 결과가 나오고 있을 때에는 Set Slot을 하지 않음
	local isVisibleResult = frame:GetUserIValue("IsVisibleResult")
	if isVisibleResult == 1 then
		return
	end		

	local obj = GetIES(invItem:GetObject());

	if TryGetProp(obj, "ClassName", "None") == 'Legendcard_Leticia' or TryGetProp(obj, 'ClassName', 'None') == 'Goddess_card_Reinforce' or TryGetProp(obj, 'ClassName', 'None') == 'Goddess_card_Reinforce_2' then
	    ui.SysMsg(ClMsg("ThisGemCantReinforce"))
	    return
	end

	if obj.GroupName ~= "Card" then
		return
	end
	local namespace = LEGENDCARD_REINFORCE_GET_MAIN_CARD_NAMESPACE(obj)
	if namespace == nil then
		ui.SysMsg(ClMsg("WrongDropItem"));
		return
	end
	if true == invItem.isLockState then
		ui.SysMsg(ClMsg("MaterialItemIsLock"));
		return;
	end
	local legendCardLv = GET_ITEM_LEVEL(obj)
	if legendCardLv >= 10 then
		ui.SysMsg(ClMsg("CanNotEnchantMore"));
		return
	end
	
	local invFrame = ui.GetFrame("inventory");
	if LEGENDCARD_UPGRADE_ALREADY_REGISTER(frame,invItem:GetIESID()) == true then
		return
	end

	LEGENDCARD_UPGRADE_SLOT_CLEAR(frame, 3)

	--set name
	local legendCardNameGbox = GET_CHILD_RECURSIVELY(frame, 'legendcardnameGbox')
	legendCardNameGbox:ShowWindow(1)
	local legendCardNameText = GET_CHILD_RECURSIVELY(frame, "legendcard_name_text")
	legendCardNameText:SetTextByKey("value", obj.Name)

	--set old inven slot
	LEGENDCARD_REINFORCE_RECOVER_INVICON(slot)

	--set slot
	slot:SetText("")
	SET_SLOT_INVITEM_NOT_COUNT(slot, invItem)
	SET_SLOT_ITEM_TEXT_USE_INVCOUNT(slot, invItem, obj, 1);
	
	--set material count		
	local cls = LEGENDCARD_GET_REINFORCE_CLASS(legendCardLv,obj.Reinforce_Type,namespace)
	
	frame:SetUserValue(slot:GetName(), invItem:GetIESID())
	LEGENDCARD_REINFORCE_INV_RBTN(invItem, slot)
	
	if obj.Reinforce_Type == "GoddessCard" then
		GODDESS_CARD_SET_LEVEL_INFO(frame, legendCardLv + 1)
		
		local success_box = GET_CHILD_RECURSIVELY(frame, 'success_box')
		success_box:ShowWindow(0)

		local else_box = GET_CHILD_RECURSIVELY(frame, 'else_box')
		else_box:ShowWindow(0)
		
		local lv_bg = GET_CHILD_RECURSIVELY(frame, 'lv_bg')
		lv_bg:ShowWindow(1)
	else
		LEGENDCARD_SET_MATERIAL_ITEM(frame,cls,obj)
		CALC_UPGRADE_PERCENTS(frame)
	end
end

function LEGENDCARD_MATERIAL_SET_SLOT(slot, invItem)	
	local frame = ui.GetFrame('legendcardupgrade');
	if frame == nil then return end

	-- 업그레이드 이후 결과가 나오고 있을 때에는 Set Slot을 하지 않음
	local isVisibleResult = frame:GetUserIValue("IsVisibleResult")
	if isVisibleResult == 1 then
		return
	end		
	
	local obj = GetIES(invItem:GetObject());
	if obj.GroupName ~= "Card" then
		return
	end
	if true == invItem.isLockState then
		ui.SysMsg(ClMsg("MaterialItemIsLock"));
		return;
	end

	if frame:GetUserValue("LEGcard_slot") == "None" then
		ui.SysMsg(ClMsg("AdvancedCardReinforce_Need_LegCard")); -- 강화할 고급 카드를 먼저 등록해 주시기 바랍니다.
		return
	end
	if LEGENDCARD_UPGRADE_ALREADY_REGISTER(frame,invItem:GetIESID()) == true then
		return
	end

	local legendSlot = GET_CHILD_RECURSIVELY(frame, "LEGcard_slot")
	local legendSlotGuid = LEGENDCARD_REINFORCE_GET_GUID_BY_SLOT(legendSlot)
	local legendSlotItem = session.GetInvItemByGuid(legendSlotGuid);
	local legendSlotItemObj = legendSlotItem:GetObject()
	local legendSlotItemIES = GetIES(legendSlotItemObj)
	local namespace = LEGENDCARD_REINFORCE_GET_MATERIAL_CARD_NAMESPACE(legendSlotItemIES, obj)
	if namespace == nil then
		ui.SysMsg(ClMsg("WrongDropItem")); -- 기간이 만료된 아이템이거나 등록할 수 없는 아이템입니다.
		return
	end
		
	if TryGetProp(obj, "ClassName", "None") == "Goddess_card_Reinforce" then
		ui.SysMsg(ClMsg("IMPOSSIBLE_ITEM"));
		return
	end

	local cls = LEGENDCARD_GET_REINFORCE_CLASS(legendCardLv,obj.Reinforce_Type,namespace)
	LEGENDCARD_SET_MATERIAL_ITEM(frame,cls,obj)

	--set old inven slot
	LEGENDCARD_REINFORCE_RECOVER_INVICON(slot)

	--set slot
	slot:SetText("")
	SET_SLOT_INVITEM_NOT_COUNT(slot, invItem)
	SET_SLOT_ITEM_TEXT_USE_INVCOUNT(slot, invItem, obj, 1);

	CALC_UPGRADE_PERCENTS(frame)

	LEGENDCARD_REINFORCE_INV_RBTN(invItem, slot)
end

function LEGENDCARD_UPGRADE_ALREADY_REGISTER(frame,guid)
	do
		local legendSlot = GET_CHILD_RECURSIVELY(frame, "LEGcard_slot")
		local legendSlotGuid = LEGENDCARD_REINFORCE_GET_GUID_BY_SLOT(legendSlot)
		if legendSlotGuid == guid then
			return true
		end
	end

	for i = 1, 4 do
		local materialSlot = GET_CHILD_RECURSIVELY(frame, "material_slot"..i)
		local materialSlotGuid = LEGENDCARD_REINFORCE_GET_GUID_BY_SLOT(materialSlot)
		local icon = materialSlot:GetIcon()
		if materialSlotGuid == guid then
			return true
		end
	end
	return false
end

function CALC_UPGRADE_PERCENTS(frame)
	local legendCardSlot = GET_CHILD_RECURSIVELY(frame, 'LEGcard_slot')
	local legendCardGuid = LEGENDCARD_REINFORCE_GET_GUID_BY_SLOT(legendCardSlot)
	local legendCardObj = nil
	if legendCardGuid ~= 0 then
		local legendCardInvItem = GET_ITEM_BY_GUID(legendCardGuid)
		legendCardObj = GetIES(legendCardInvItem:GetObject());
	end

	--여신카드 예외처리
	if TryGetProp(legendCardObj,"Reinforce_Type","None") == "GoddessCard" then
		return
	end

	local materialCardObjList = {}
	for i = 1, 4 do
		local materialSlot = GET_CHILD_RECURSIVELY(frame, 'material_slot'..i)
		local materialSlotGuid = LEGENDCARD_REINFORCE_GET_GUID_BY_SLOT(materialSlot)
		if materialSlotGuid ~= 0 then
			local materialInvItem = GET_ITEM_BY_GUID(materialSlotGuid)
			local materialCardObj = GetIES(materialInvItem:GetObject());
			table.insert(materialCardObjList,materialCardObj)
		end
	end

	local successPercent,failPercent,brokenPercent,needPoint, totalGivePoint = CALC_LEGENDCARD_REINFORCE_PERCENTS(legendCardObj,materialCardObjList)

	local successPercentText = GET_CHILD_RECURSIVELY(frame, 'success_percent')
	local failPercentText = GET_CHILD_RECURSIVELY(frame, 'fail_percent')
	local brokenPercentText = GET_CHILD_RECURSIVELY(frame, 'broken_percent')
	if successPercentText == nil or failPercentText == nil or brokenPercentText == nil then
		return
	end
	
	successPercent = successPercent .. '%'
	successPercentText:SetTextByKey("value", successPercent);
	failPercentText:SetTextByKey("value", failPercent);
	brokenPercentText:SetTextByKey("value", brokenPercent);
end

function DO_LEGENDCARD_UPGRADE_LBTNUP(frame, slot, argStr, argNum)	
	local frame = ui.GetFrame('legendcardupgrade');
	local isVisibleResult = frame:GetUserIValue("IsVisibleResult")

	-- 업그레이드 이후 결과가 나왔을 때 확인 버튼
	if isVisibleResult == 1 then
		LEGENDCARD_UPGRADE_SLOT_CLEAR(frame, 1)
		LEGENDCARD_UPGRADE_MAINSLOT_UPDATE(frame)
		return
	end		

	local legendCardSlot = GET_CHILD_RECURSIVELY(frame, 'LEGcard_slot') -- 강화할 메인 카드
	local legendCardSlotIcon = legendCardSlot:GetIcon()

	if legendCardSlotIcon == nil then
		ui.SysMsg(ClMsg("AdvancedCardReinforce_Need_LegCard")); -- 강화할 고급 카드를 먼저 등록해 주시기 바랍니다
		return
	end
	local legendCardSlotID = LEGENDCARD_REINFORCE_GET_GUID_BY_SLOT(legendCardSlot)
	if legendCardSlotID == 0 then
		return
	end
	local legendCardInvItem = GET_ITEM_BY_GUID(legendCardSlotID)
	if legendCardInvItem == nil then
		return
	end
	if legendCardInvItem.isLockState then
		ui.SysMsg(ClMsg("MaterialItemIsLock"));
		return;
	end
	local legendCardObj = GetIES(legendCardInvItem:GetObject())

	session.ResetItemList();	
	session.AddItemID(legendCardSlotID);

	if TryGetProp(legendCardObj,"Reinforce_Type") == "GoddessCard" then
		local goal_lv = frame:GetUserIValue('GODDESS_GOAL_LV')
		local mat_list = goddess_card_reinforce.get_goddess_card_mat_list(legendCardObj, goal_lv)
		for name, count in pairs(mat_list) do
			local mat_cls = GetClass('Item', name)
			if mat_cls ~= nil then
				local mat_slot = GET_CHILD_RECURSIVELY(frame, 'materialItem_slot')
				local inv_item = session.GetInvItemByName(name)
				local inv_count = 0
				if inv_item ~= nil then
					inv_count = inv_item.count
				end

				if inv_count < count then
					ui.SysMsg(ScpArgMsg("{item}NotEnoughMaterial", "item", TryGetProp(mat_cls, "Name", "None"))) -- 재료가 부족합니다
					return
				end

				if name ~= TryGetProp(legendCardObj, "StringArg", "None") then
					local mat_guid = inv_item:GetIESID()
					session.AddItemID(mat_guid, count)
				end
			end
		end

		LEGENDCARD_REINFORCE_EXEC()
	else
		-- 4를 빼놓자
		local isSlotEmpty = 1
		local materialCardObjList = {}
		local materialCardLvMax = 0
		for i = 1, 4 do
			local materialCardSlot = GET_CHILD_RECURSIVELY(frame, 'material_slot'..i)
			local materialCardID = LEGENDCARD_REINFORCE_GET_GUID_BY_SLOT(materialCardSlot)
			if materialCardID ~= 0 then
				local materialCardInvItem = GET_ITEM_BY_GUID(materialCardID)
				if materialCardInvItem ~= nil then
					isSlotEmpty = 0
					local materialCardObj = GetIES(materialCardInvItem:GetObject());
					table.insert(materialCardObjList,materialCardObj)
					local materialCardLv = GET_ITEM_LEVEL(materialCardObj)
					if materialCardLvMax < materialCardLv then
						materialCardLvMax = materialCardLv
					end

					session.AddItemID(materialCardID);
				end
			end
		end

		if isSlotEmpty == 1 then
			ui.SysMsg(ClMsg("AdvancedCardReinforce_Need_Card")); -- 제물로 사용될 카드를 등록해 주시기 바랍니다
			return
		end
		
		local needReinforceItem = 'None';
		local needReinforceItemCount = 0;
		local legendCardLv = GET_ITEM_LEVEL(legendCardObj)
		local levelWarning = false
		if legendCardLv < materialCardLvMax then
			levelWarning = true;
		end

		local namespace = LEGENDCARD_REINFORCE_GET_MAIN_CARD_NAMESPACE(legendCardObj)
		if namespace ~= nil then
			local cls = LEGENDCARD_GET_REINFORCE_CLASS(legendCardLv,legendCardObj.Reinforce_Type,namespace)
			needReinforceItem = TryGetProp(cls, 'NeedReinforceItem')
			if TryGetProp(cls, 'NeedItem_Script') ~= 'None' and TryGetProp(cls, 'NeedItem_Script') ~= nil then
				local scp = _G[TryGetProp(cls, 'NeedItem_Script')]
				needReinforceItem = scp(cls,legendCardObj)
			end
			needReinforceItemCount = TryGetProp(cls, 'NeedReinforceItemCount')
		end

		if needReinforceItem == nil or needReinforceItem == 'None' then
			return
		end

		local needInvItem = session.GetInvItemByName(needReinforceItem)
		if needInvItem == nil or needInvItem.count < needReinforceItemCount then
			ui.SysMsg(ClMsg("AdvancedCardReinforce_NeedItem")); -- 고급 카드 강화 재료가 부족합니다.
			return
		end

		-- Request #97447 / 재료 카드의 레벨이 강화할 카드의 레벨보다 높을 때 주의 추가 팝업
		if levelWarning == true then
			WARNINGMSGBOX_FRAME_OPEN(ClMsg("MaterialCardLvHighThanGoddessReinforceCard"), "LEGENDCARD_REINFORCE_REINFORCE_OK_MSGBOX", "None")
		else
			LEGENDCARD_REINFORCE_REINFORCE_OK_MSGBOX()
		end
	end
end

function LEGENDCARD_REINFORCE_REINFORCE_OK_MSGBOX()
	ui.MsgBox_NonNested(ClMsg("AdvancedCardReinforce_OK"), frame:GetName(), "LEGENDCARD_REINFORCE_EXEC", "None");
	-- WARNINGMSGBOX_FRAME_OPEN(ClMsg("MaterialCardLvHighThanGoddessReinforceCard"), "LEGENDCARD_REINFORCE_EXEC", "None")
end

function LEGENDCARD_REINFORCE_EXEC()
	local frame = ui.GetFrame("legendcardupgrade")
	local legendCardSlot = GET_CHILD_RECURSIVELY(frame, 'LEGcard_slot') -- 강화할 메인 카드
	local legendCardSlotIcon = legendCardSlot:GetIcon()
	if legendCardSlotIcon == nil then
		ui.SysMsg(ClMsg("AdvancedCardReinforce_Need_LegCard")) -- 강화할 고급 카드를 먼저 등록해 주시기 바랍니다
		return
	end
	local legendCardSlotID = LEGENDCARD_REINFORCE_GET_GUID_BY_SLOT(legendCardSlot)
	if legendCardSlotID == 0 then
		return
	end
	local legendCardInvItem = GET_ITEM_BY_GUID(legendCardSlotID)
	if legendCardInvItem == nil then
		return
	end
	if legendCardInvItem.isLockState then
		ui.SysMsg(ClMsg("MaterialItemIsLock"));
		return
	end
	local argList = nil
	local legendCardObj = GetIES(legendCardInvItem:GetObject())
	if TryGetProp(legendCardObj, "Reinforce_Type", "None") == "GoddessCard" then
		local goal_lv = frame:GetUserValue('GODDESS_GOAL_LV')
		argList = NewStringList()
		argList:Add(goal_lv)
	end

	ui.SetHoldUI(true);
	SetCraftState(1);
	local resultlist = session.GetItemIDList();
	item.DialogTransaction("LEGENDCARD_UPGRADE_TX", resultlist, '', argList);
end

function LEGENDCARD_REINFORCE_TIMER(ctrl, str, tick)
	if tick == 20 then
		local frame = ctrl:GetTopParentFrame()
		LEGENDCARD_UPGRADE_DRAW_RESULT(frame)
	elseif tick == 30 then
		local frame = ctrl:GetTopParentFrame()
		if frame:GetUserIValue("IsVisibleResult") == 1 then
			LEGENDCARD_UPGRADE_SLOT_CLEAR(frame,0)
		end
	end
end

function LEGENDCARD_UPGRADE_DRAW_RESULT(frame)
	ui.SetHoldUI(false);
	SetCraftState(0);

	local resultGbox = GET_CHILD_RECURSIVELY(frame, 'resultGbox')
	local upgradeBtn = GET_CHILD_RECURSIVELY(frame, 'upgradeBtn')
	resultGbox:ShowWindow(1)
	
	upgradeBtn:EnableHitTest(1)
	LEGENDCARD_UPGRADE_MAINSLOT_UPDATE(frame)
end

function LEGENDCARD_UPGRADE_UPDATE(resultFlag, beforeLv, afterLv, reinforceType)
	local frame = ui.GetFrame("legendcardupgrade")
	LEGENDCARD_UPGRADE_SLOT_CLEAR(frame, resultFlag)

	if reinforceType ~= 'GoddessReinForceCard' then
		local timer = GET_CHILD_RECURSIVELY(frame, "timer");
		timer:ShowWindow(1);
		timer:ForcePlayAnimation();
	end
	
	frame:SetUserValue("IsVisibleResult", 1)
	
	--결과에 따라 이팩트 따로 출력
	LEGENDCARD_UPGRADE_EFFECT_EXEC(frame,resultFlag,reinforceType)
	LEGENDCARD_UPGRADE_EFFECT_UI_EXEC(frame,beforeLv,afterLv,reinforceType,resultFlag)
end

function LEGENDCARD_UPGRADE_EFFECT_EXEC(frame,resultFlag,reinforceType)
	local resulteffect_position_slot = GET_CHILD_RECURSIVELY(frame, "resulteffect_position_slot");
	local posX, posY = GET_SCREEN_XY(resulteffect_position_slot);

	local effectName = ""
	--성공
	if resultFlag == 1 then
		effectName = frame:GetUserConfig("UPGRADE_RESULT_EFFECT_SUCCESS")
	--실패
	elseif resultFlag == 2 then
		effectName = frame:GetUserConfig("UPGRADE_RESULT_EFFECT_FAIL")
	--파괴
	elseif resultFlag == 3 then
		effectName = frame:GetUserConfig("UPGRADE_RESULT_EFFECT_BROKEN")
	else
		return
	end
	local startEffectName = frame:GetUserConfig("UPGRADE_RESULT_EFFECT_START");
	if reinforceType == 'GoddessCard' then
		effectName = effectName.."_GODDESS"
		startEffectName = startEffectName.."_GODDESS"
	elseif reinforceType == 'GoddessReinForceCard' then
		return
	end
	movie.PlayUIEffect(startEffectName, posX, posY, tonumber(frame:GetUserConfig("UPGRADE_RESULT_EFFECT_SCALE")))
	movie.PlayUIEffect(effectName, posX, posY, tonumber(frame:GetUserConfig("LEGENDCARD_OPEN_EFFECT_SCALE")))
end

function LEGENDCARD_UPGRADE_EFFECT_UI_EXEC(frame, beforeLv, afterLv, reinforceType,resultFlag)
	local beforeLvText = GET_CHILD_RECURSIVELY(frame, 'before_lv')
	local afterLvText = GET_CHILD_RECURSIVELY(frame, 'after_lv')
	local legendSlot = GET_CHILD_RECURSIVELY(frame, 'LEGcard_slot')

	beforeLvText:SetTextByKey("value", "LV" .. beforeLv)
	afterLvText:SetTextByKey("value", "DESTROY")

	local legendSlotGuid = LEGENDCARD_REINFORCE_GET_GUID_BY_SLOT(legendSlot)
	local legendSlotItem = session.GetInvItemByGuid(legendSlotGuid);
	if legendSlotItem ~= nil then
		local legendCardObj = GetIES(legendSlotItem:GetObject())
		if TryGetProp(legendCardObj, 'Reinforce_Type', 'None') == 'GoddessCard' and afterLv < 10 then
			GODDESS_CARD_SET_LEVEL_INFO(frame, afterLv + 1)
		else
			local namespace = LEGENDCARD_REINFORCE_GET_MAIN_CARD_NAMESPACE(legendCardObj)
			local cls = LEGENDCARD_GET_REINFORCE_CLASS(afterLv,reinforceType,namespace)
			LEGENDCARD_SET_MATERIAL_ITEM(frame,cls,legendCardObj)
		end
		afterLvText:SetTextByKey("value", "LV " .. afterLv)
	end
	local resultGbox2 = GET_CHILD_RECURSIVELY(frame, 'resultGbox2')
	resultGbox2:ShowWindow(1)

	local upgradeBtn = GET_CHILD_RECURSIVELY(frame, 'upgradeBtn')
	upgradeBtn:SetTextByKey("value", ClMsg("Confirm"))
	upgradeBtn:EnableHitTest(0)

	local result_etccard = GET_CHILD_RECURSIVELY(frame,"result_etccard")
	if reinforceType == 'GoddessReinForceCard' then
		LEGENDCARD_UPGRADE_DRAW_RESULT(frame)
		result_etccard:ShowWindow(1)
		if resultFlag == 1 then
			result_etccard:SetImage("card_reinforce_SUCCESS")
		elseif resultFlag == 2 then
			result_etccard:SetImage("card_reinforce_FAIL")
		elseif resultFlag == 3 then
			result_etccard:SetImage("card_reinforce_DESTROY")
		end
	else
		result_etccard:ShowWindow(0)
	end
end

function LEGENDCARD_REINFORCE_INV_RBTN(invitem, slot)
	if invitem == nil then return end
	if slot == nil then return end

	local nowselectedcount = slot:GetUserIValue("LEGENDCARD_REINFORCE_SELECTED")
	if nowselectedcount < invitem.count then
		-- 카드탭
		local slot = INV_GET_SLOT_BY_ITEMGUID(invitem:GetIESID())
		if slot == nil then return end
		local icon = slot:GetIcon();
		if icon == nil then return end

		-- 모두 보기 탭
		local slot_All = INV_GET_SLOT_BY_ITEMGUID(invitem:GetIESID(), nil, 1)
		local icon_All = slot_All:GetIcon();

		slot:SetUserValue("LEGENDCARD_REINFORCE_SELECTED", nowselectedcount + 1);
		slot_All:SetUserValue("LEGENDCARD_REINFORCE_SELECTED", nowselectedcount + 1);

		local nowselectedcount = slot:GetUserIValue("LEGENDCARD_REINFORCE_SELECTED")
					
		if icon ~= nil and nowselectedcount == invitem.count then
			icon:SetColorTone("AA000000");
			icon_All:SetColorTone("AA000000");
		end
	end
end

-- 받은 slot의 guid를 받고, 인벤토리에서 guid로 인벤토리의 슬롯을 찾아 RECOVER
function LEGENDCARD_REINFORCE_RECOVER_INVICON(slot)
	if slot == nil then return end
	
	local guid = LEGENDCARD_REINFORCE_GET_GUID_BY_SLOT(slot)
	if guid == 0 then return end

	-- 카드 탭
	local invenSlot = INV_GET_SLOT_BY_ITEMGUID(guid)
	LEGENDCARD_REINFORCE_RECOVER_ICON(invenSlot)

	-- 모두 보기 탭
	local invenSlot_All = INV_GET_SLOT_BY_ITEMGUID(guid, nil, 1)
	LEGENDCARD_REINFORCE_RECOVER_ICON(invenSlot_All)
end

function LEGENDCARD_REINFORCE_RECOVER_ICON(slot)
	if slot == nil then return end

	local icon = slot:GetIcon();
	if icon ~= nil then
		slot:SetUserValue("LEGENDCARD_REINFORCE_SELECTED", 0);
		icon:SetColorTone("FFFFFFFF");
	end
end

function LEGENDCARD_REINFORCE_GET_GUID_BY_SLOT(slot)
	local icon = slot:GetIcon()
	if icon == nil then
		return 0
	end
	local info = icon:GetInfo()
	return info:GetIESID()
end

function LEGENDCARD_SET_MATERIAL_ITEM(frame,cls,legendCardObj)
	local needReinforceItem = TryGetProp(cls, 'NeedReinforceItem')
	if TryGetProp(cls, 'NeedItem_Script') ~= 'None' and TryGetProp(cls, 'NeedItem_Script') ~= nil then
		local scp = _G[TryGetProp(cls, 'NeedItem_Script')]
		needReinforceItem = scp(cls,legendCardObj)
	end
	local needItemCls = GetClass("Item", needReinforceItem)
	if needItemCls ~= nil then
		local needReinforceItemCount = TryGetProp(cls, 'NeedReinforceItemCount')
		local needItemSlot = GET_CHILD_RECURSIVELY(frame, "materialItem_slot")
		local needInvItem = session.GetInvItemByName(needReinforceItem)
		local invItemCount = 0
		if needInvItem ~= nil then
			invItemCount = needInvItem.count
		end
		local color = ""
		if invItemCount < needReinforceItemCount then
			color = frame:GetUserConfig("TEXT_COLOR_LACK_OF_MATERIAL")
		else
			color = frame:GetUserConfig("TEXT_COLOR_ENOUGH_OF_MATERIAL")
		end
		local needItemCountText = string.format("%s%s/%s{/}",color,invItemCount,needReinforceItemCount)
		needItemSlot:SetText(needItemCountText)
		local needItemIcon = CreateIcon(needItemSlot);
		needItemIcon:SetImage(needItemCls.Icon)
		needItemIcon:SetTooltipType("wholeitem");
		needItemIcon:SetTooltipArg("", needItemCls.ClassID, 0);
	end
end

function GODDESSCARD_SET_MATERIAL_ITEM(frame, card_obj, goal_lv)
	for i = 1, 4 do
		local mat_slot = GET_CHILD_RECURSIVELY(frame, "material_slot" .. i)
		mat_slot:ClearIcon()
		mat_slot:SetText("")
	end

	local mat_list = goddess_card_reinforce.get_goddess_card_mat_list(card_obj, goal_lv)
	local mat_cnt = 0
	local string_arg = TryGetProp(card_obj, 'StringArg', 'None')
	for name, count in pairs(mat_list) do
		local mat_cls = GetClass('Item', name)
		if mat_cls ~= nil then
			if name == string_arg then
				local mat_slot = GET_CHILD_RECURSIVELY(frame, 'materialItem_slot')
				local inv_item = session.GetInvItemByName(name)
				local inv_count = 0
				if inv_item ~= nil then
					inv_count = inv_item.count
				end
				local color = ''
				if inv_count < count then
					color = frame:GetUserConfig('TEXT_COLOR_LACK_OF_MATERIAL')
				else
					color = frame:GetUserConfig('TEXT_COLOR_ENOUGH_OF_MATERIAL')
				end
				local count_txt = string.format('%s%s/%s{/}', color, inv_count, count)
				mat_slot:SetText(count_txt)
				local mat_icon = CreateIcon(mat_slot)
				mat_icon:SetImage(mat_cls.Icon)
				mat_icon:SetTooltipType("wholeitem")
				mat_icon:SetTooltipArg("", mat_cls.ClassID, 0)
			else
				mat_cnt = mat_cnt + 1
				local mat_slot = GET_CHILD_RECURSIVELY(frame, "material_slot" .. mat_cnt)
				local inv_item = session.GetInvItemByName(name)
				local inv_count = 0
				if inv_item ~= nil then
					inv_count = inv_item.count
				end
				local format_str = ''
				if inv_count < count then
					format_str = "{@st66d}{#e50002}{s14}%s/%s{/}{/}{/}"
				else
					format_str = "{@st66d}{s14}%s/%s{/}{/}"
				end
				local count_txt = string.format(format_str, inv_count, count)
				mat_slot:SetText(count_txt, 'default', ui.RIGHT, ui.BOTTOM, 0, 0)
				local mat_icon = CreateIcon(mat_slot)
				mat_icon:SetImage(mat_cls.Icon)
				mat_icon:SetTooltipType("wholeitem")
				mat_icon:SetTooltipArg("", mat_cls.ClassID, 0)
			end
		end
	end
end

function GODDESS_CARD_SET_LEVEL_INFO(frame, to_lv)
	local main_slot = GET_CHILD_RECURSIVELY(frame, 'LEGcard_slot')
	local card_guid = LEGENDCARD_REINFORCE_GET_GUID_BY_SLOT(main_slot)
	local card_item = session.GetInvItemByGuid(card_guid)
	if card_item == nil then return end

	local card_obj = GetIES(card_item:GetObject())
	local cur_lv = GET_ITEM_LEVEL(card_obj)

	if to_lv <= cur_lv or to_lv > 10 then
		return
	end

	local from_lv_text = GET_CHILD_RECURSIVELY(frame, 'from_lv_text')
	from_lv_text:SetTextByKey('value', cur_lv)

	local to_lv_text = GET_CHILD_RECURSIVELY(frame, 'to_lv_text')
	to_lv_text:SetTextByKey('value', to_lv)
	
	GODDESSCARD_SET_MATERIAL_ITEM(frame, card_obj, to_lv)
	
	frame:SetUserValue('GODDESS_GOAL_LV', to_lv)
end

function GODDESS_CARD_LEVEL_UPBTN(parent, ctrl)
	local frame = parent:GetTopParentFrame()
	local goal_lv = frame:GetUserIValue('GODDESS_GOAL_LV')
	GODDESS_CARD_SET_LEVEL_INFO(frame, goal_lv + 1)
end

function GODDESS_CARD_LEVEL_DOWNBTN(parent, ctrl)
	local frame = parent:GetTopParentFrame()
	local goal_lv = frame:GetUserIValue('GODDESS_GOAL_LV')
	GODDESS_CARD_SET_LEVEL_INFO(frame, goal_lv - 1)
end

function LEGENDCARD_EFFECT_TEST_C(resultFlag)
	resultFlag = tonumber(resultFlag)
	local beforeLv = 1
	local afterLv = 2
	local frame = ui.GetFrame("legendcardupgrade")
	LEGENDCARD_UPGRADE_SLOT_CLEAR(frame, resultFlag)

	--결과에 따라 이팩트 따로 출력
	
	local beforeLvText = GET_CHILD_RECURSIVELY(frame, 'before_lv')
	local afterLvText = GET_CHILD_RECURSIVELY(frame, 'after_lv')
	beforeLvText:SetTextByKey("value", "LV" .. beforeLv)

	local legendSlot = GET_CHILD_RECURSIVELY(frame, 'LEGcard_slot')
	local legendSlotGuid = LEGENDCARD_REINFORCE_GET_GUID_BY_SLOT(legendSlot)

	local resulteffect_position_slot = GET_CHILD_RECURSIVELY(frame, "resulteffect_position_slot");
	local posX, posY = GET_SCREEN_XY(resulteffect_position_slot);
	movie.PlayUIEffect("UI_card_strengthen_GODDESS", posX, posY, tonumber(frame:GetUserConfig("UPGRADE_RESULT_EFFECT_SCALE")))
	if resultFlag == 1 then
		--성공
		afterLvText:SetTextByKey("value", "LV " .. afterLv)
		movie.PlayUIEffect("UI_success_logo_GODDESS", posX, posY, tonumber(frame:GetUserConfig("LEGENDCARD_OPEN_EFFECT_SCALE")))
	elseif resultFlag == 2 then
		--실패
		afterLvText:SetTextByKey("value", "LV " ..afterLv)
		movie.PlayUIEffect("UI_fail_logo_GODDESS", posX, posY, tonumber(frame:GetUserConfig("LEGENDCARD_OPEN_EFFECT_SCALE")))
	elseif resultFlag == 3 then
		--파괴
		afterLvText:SetTextByKey("value", "DESTROY")
		movie.PlayUIEffect("UI_destroy_logo_GODDESS", posX, posY, tonumber(frame:GetUserConfig("LEGENDCARD_OPEN_EFFECT_SCALE")))
	else
		return
	end

	local resultGbox = GET_CHILD_RECURSIVELY(frame, 'resultGbox')
	local resultGbox2 = GET_CHILD_RECURSIVELY(frame, 'resultGbox2')
	resultGbox:ShowWindow(0)
	resultGbox2:ShowWindow(1)

	local upgradeBtn = GET_CHILD_RECURSIVELY(frame, 'upgradeBtn')
	upgradeBtn:SetTextByKey("value", ClMsg("Confirm"))
	upgradeBtn:EnableHitTest(0)
	frame:SetUserValue("IsVisibleResult", 1)
end
