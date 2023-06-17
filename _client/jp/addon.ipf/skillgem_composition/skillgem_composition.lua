
function SKILLGEM_COMPOSITION_ON_INIT(addon, frame)
	addon:RegisterMsg("SKILLGEM_COMPOSITION_SUCCESS", "SKILLGEM_COMPOSITION_SUCCESS");
end

function SKILLGEM_COMPOSITION_OPEN()
	ui.OpenFrame("skillgem_composition");
end

function SKILLGEM_COMPOSITION_OPEN_SCP(frame)
    SKILLGEM_COMPOSITION_UI_RESET();
	
	INVENTORY_SET_CUSTOM_RBTNDOWN("SKILLGEM_COMPOSITION_INV_RBTNDOWN");
	ui.OpenFrame("inventory");
end

function SKILLGEM_COMPOSITION_CLOSE(frame)
	if ui.CheckHoldedUI() == true then
		return;
	end

	INVENTORY_SET_CUSTOM_RBTNDOWN("None");
    frame:ShowWindow(0);
end

local maxslotCnt = 5;
function SKILLGEM_COMPOSITION_SLOT_RESET(slot, slotIndex)
	local parent = slot:GetParent();
	local itemCnt = parent:GetUserIValue("ITEM_COUNT");
	itemCnt = itemCnt - 1;
	if itemCnt < 0 then
		itemCnt = 0;
	end
	parent:SetUserValue("ITEM_COUNT", itemCnt);

	local slotname = GET_CHILD(parent, "slot_"..slotIndex.."_name");
	slotname:ShowWindow(0);

	local frame = ui.GetFrame("skillgem_composition");
	local doBtn = GET_CHILD(frame, "doBtn");
	local pre_text = GET_CHILD_RECURSIVELY(frame, "result_preview_text");

	if itemCnt ~= maxslotCnt then
		doBtn:ShowWindow(0)
		pre_text:ShowWindow(0)
	end

	slot:SetBgImage("socket_slot_bg");
	slot:SetBgImageSize(slot:GetWidth() - 15 , slot:GetHeight() - 15);
	slot:ClearIcon();
	slot:ShowWindow(1);
end

function SKILLGEM_COMPOSITION_UI_RESET()
	local frame = ui.GetFrame("skillgem_composition");

	frame:SetUserValue("ITEM_COUNT", 0);
	
	local reinfResultBox = GET_CHILD(frame, "reinfResultBox");
	reinfResultBox:ShowWindow(0);

	local doBtn = GET_CHILD(frame, "doBtn");
	doBtn:ShowWindow(0);

	local resetBtn = GET_CHILD(frame, "resetBtn");
	resetBtn:ShowWindow(0);

	local pre_text = GET_CHILD_RECURSIVELY(frame, "result_preview_text");
	pre_text:ShowWindow(0);

	for i = 1, maxslotCnt do 
		local slot = GET_CHILD(frame, "slot_"..i);
		SKILLGEM_COMPOSITION_SLOT_RESET(slot, i);
	end
end

function ENABLE_SKILLGEM_COMPOSITION_ITEM(invItem)
	if invItem == nil then
		return false;
	end

	if invItem.isLockState == true then
		ui.SysMsg(ClMsg("MaterialItemIsLock"));
		return false;
	end

	local itemObj = GetIES(invItem:GetObject());	
	if IS_RANDOM_OPTION_SKILL_GEM(itemObj) == true then
		ui.SysMsg(ClMsg('CantUseCabinetCuzRandomOption'))
		return false
	end

    if CAN_COMPOSITION_SKILL_GEM(itemObj) == false then
        return false;
	end
	
	return true;
end

-- 젬 레벨에 따라 slot 개 수가 달라져서 엉뚱한 slot에 아이템 등록하지 않도록 무조건 순서대로 등록하게 함
function SKILLGEM_COMPOSITION_ITEM_REG(guid)
	local frame = ui.GetFrame("skillgem_composition");
	if ui.CheckHoldedUI() == true then
		return;
	end

	local invItem = session.GetInvItemByGuid(guid);
	if ENABLE_SKILLGEM_COMPOSITION_ITEM(invItem) == false then
		return;
	end
	
	local itemObj = GetIES(invItem:GetObject());
	local gem_job = TryGetProp(GetClass('Skill', TryGetProp(itemObj, 'SkillName', 'None')), 'Job', 'None')
	local gem_ctrlType = TryGetProp(GetClassByStrProp('Job', 'JobName', gem_job), 'CtrlType', "None")

	if gem_ctrlType == 'None' then
		 return 
	end

	local cls = GetClassByType("item_gem_composition", 1);
	if cls == nil then
		return;
	end

	local slotindexcheck = false;
	local slotCnt = cls.NeedCount;
	for i = 1, maxslotCnt do 
		local slot = GET_CHILD(frame, "slot_"..i);
		local slotitem = GET_SLOT_ITEM(slot);
		local slotname = GET_CHILD(frame, "slot_"..i.."_name");
		if i > slotCnt then
			slot:ShowWindow(0);
			slotname:ShowWindow(0);
		else
			if slotitem ~= nil and guid == slotitem:GetIESID() then
				return;
			end

			local itemCnt = frame:GetUserIValue("ITEM_COUNT");
			if slot:GetIcon() == nil and slotindexcheck == false then
				slotindexcheck = true;

				slot:SetBgImageSize(0, 0);
				SET_SLOT_ITEM(slot, invItem);

				slot:SetUserValue('GEM_CTRLTYPE', gem_ctrlType)

				slotname:SetTextByKey("value", itemObj.Name);
				slotname:ShowWindow(1);

				frame:SetUserValue("ITEM_COUNT", itemCnt + 1);
				
				local doBtn = GET_CHILD(frame, "doBtn");
				local pre_text = GET_CHILD_RECURSIVELY(frame, "result_preview_text");
				
				local ct_Warrior, ct_Archer, ct_Wizard, ct_Cleric, ct_Scout = 0,0,0,0,0

				if itemCnt == maxslotCnt - 1 then

					doBtn:ShowWindow(1)
					pre_text:ShowWindow(1)

					for j = 1, maxslotCnt do 
						local slot = GET_CHILD(frame, "slot_"..j)
						local ctrltype = slot:GetUserValue("GEM_CTRLTYPE")
						if ctrltype == 'Warrior' then
							ct_Warrior = ct_Warrior + 1
						elseif ctrltype == 'Archer' then
							ct_Archer = ct_Archer + 1
						elseif ctrltype == 'Wizard' then
							ct_Wizard = ct_Wizard + 1
						elseif ctrltype == 'Cleric' then
							ct_Cleric = ct_Cleric + 1
						elseif ctrltype == 'Scout' then
							ct_Scout = ct_Scout + 1 
						end
					end

					pre_text:SetTextByKey("value", ScpArgMsg('composition_sklgem_result', 'RATE1', ct_Warrior * 20, 'RATE2', ct_Wizard * 20, 'RATE3', ct_Archer * 20, 'RATE4', ct_Cleric * 20, 'RATE5', ct_Scout * 20))

				else
					doBtn:ShowWindow(0)
					pre_text:ShowWindow(0)
				end

			end
		end		
	end
end

function SKILLGEM_COMPOSITION_INV_RBTNDOWN(itemObj, slot)
	local isCharbelonging = TryGetProp(itemObj,'CharacterBelonging','0')
	if isCharbelonging==1 then
		ui.SysMsg(ClMsg('InvalidGem'))
		return 
	end

	if ui.CheckHoldedUI() == true then
		return;
	end

	local frame = ui.GetFrame("skillgem_composition");
	if frame == nil then
		return;
	end
	
	local icon = slot:GetIcon();
	local iconInfo = icon:GetInfo();
	SKILLGEM_COMPOSITION_ITEM_REG(iconInfo:GetIESID());
end

function SKILLGEM_COMPOSITION_ITEM_DROP(parent, ctrl, argStr, slotIndex)
	local liftIcon = ui.GetLiftIcon();
	local FromFrame = liftIcon:GetTopParentFrame();
	if FromFrame:GetName() == 'inventory' then
		local iconInfo = liftIcon:GetInfo();
		SKILLGEM_COMPOSITION_ITEM_REG(iconInfo:GetIESID());
	end
end

function SKILLGEM_COMPOSITION_ITEM_POP(parent, ctrl, argStr, slotIndex)
	if ui.CheckHoldedUI() == true then
		return;
	end

	SKILLGEM_COMPOSITION_SLOT_RESET(ctrl, slotIndex);
	local itemCnt = parent:GetUserIValue("ITEM_COUNT");
	if itemCnt == 0 then
		SKILLGEM_COMPOSITION_UI_RESET();
	end
end

function SKILLGEM_COMPOSITION_BTN_CLICK(parent, ctrl)
	if ui.CheckHoldedUI() == true then
		return;
	end

	local frame = parent:GetTopParentFrame();
	local itemCnt = frame:GetUserIValue("ITEM_COUNT");
	
	local cls = GetClassByType("item_gem_composition", 1);
	if cls == nil then
		return;
	end

	local needCnt = cls.NeedCount;
	if itemCnt < needCnt then
		return;
	end

	local COMPOSITON_SLOT_EFFECT = frame:GetUserConfig("COMPOSITON_SLOT_EFFECT");
	session.ResetItemList();
	for i = 1, needCnt do 
		local slot = GET_CHILD(frame, "slot_"..i);
		if slot:GetIcon() == nil then
			return;
		end

		local invItem = GET_SLOT_ITEM(slot);
		if ENABLE_SKILLGEM_COMPOSITION_ITEM(invItem) == false then
			return;
		end

		slot:PlayUIEffect(COMPOSITON_SLOT_EFFECT, 2, "COMPOSITON_SLOT_EFFECT", true);
		imcSound.PlaySoundEvent("sys_class_change")
		session.AddItemID(invItem:GetIESID(), 1);
	end

	ui.SetHoldUI(true);
    ReserveScript("SKILLGEM_COMPOSITION_UNFREEZE()", 3);

	local resultlist = session.GetItemIDList();
	item.DialogTransaction("COMPOSITION_SKILL_GEM", resultlist);
end

function SKILLGEM_COMPOSITION_UNFREEZE()
	ui.SetHoldUI(false);
end

function SKILLGEM_COMPOSITION_SUCCESS(frame, msg, guid)
	SKILLGEM_COMPOSITION_UNFREEZE();

	local frame = ui.GetFrame("skillgem_composition");

	local reinfResultBox = GET_CHILD(frame, "reinfResultBox");
	reinfResultBox:ShowWindow(1);

	local doBtn = GET_CHILD(frame, "doBtn");
	doBtn:ShowWindow(0);

	local resetBtn = GET_CHILD(frame, "resetBtn");
	resetBtn:ShowWindow(1);

	local invItem = session.GetInvItemByGuid(guid);
	local successItem = GET_CHILD_RECURSIVELY(frame, "successItem");
	SET_SLOT_ITEM(successItem, invItem);

	local RESULT_EFFECT = frame:GetUserConfig("RESULT_EFFECT");
	local successItem = GET_CHILD_RECURSIVELY(reinfResultBox, "successItem");
	successItem:PlayUIEffect(RESULT_EFFECT, 5, "RESULT_EFFECT", true);	
end