----- default function start
function HIGH_HAIRENCHANT_ON_INIT(addon, frame)

end
---- default function end

---- btn function start
function HIGH_HAIRENCHANT_SEND_BTN(frame, ctrl)
	if frame == nil then
		frame = ui.GetFrame('high_hairenchant')
	end
	frame = frame:GetTopParentFrame();
	
	local bg = GET_CHILD(frame,"bg")
	local gbox = GET_CHILD(bg,"gbox")
	local send_ok = GET_CHILD(gbox,"send_ok")
	local SendState = send_ok:GetUserIValue("State");

	if SendState == 0 then
		HIGH_ENCHANT_CHANGE_BUTTON_STATE(frame,1);
		HIGH_INIT_AUTO_HAIRENCHANT(frame);

		local option = ui.GetFrame("hairenchant_option");
		ENCHANT_OPTION_RESET(option)
	
	elseif SendState == 1 then
		HIGH_ENCHANT_CHANGE_BUTTON_STATE(frame,0);
		HIGH_HAIRENCHANT_OK_BTN(frame);
	end

end

function HIGH_HAIRENCHANT_OK_BTN(frame, ctrl)

	if frame == nil then
		frame = ui.GetFrame('high_hairenchant')
	end
	frame = frame:GetTopParentFrame();
	
	local enchantGuid = frame:GetUserValue("Enchant");
	local itemIES = frame:GetUserValue("itemIES");
	if "None" == itemIES or "None" == enchantGuid then
		return;
	end	

	item.DoPremiumItemEnchantchip(itemIES, enchantGuid);
end

function HIGH_ENCHANT_OPTION_OPEN_BTN(ctrl, frame)
	
	local frame = ui.GetFrame("high_hairenchant");
	if frame == nil  then
		return;
	end

	local enchantGuid = frame:GetUserValue("Enchant");
	local itemIES = frame:GetUserValue("itemIES");

	if "None" == itemIES or "None" == enchantGuid then
		return;
	end	

	local enchant_item = session.GetInvItemByGuid(enchantGuid);
	if enchant_item == nil then
		return;
	end
	
	enchant_item = GetIES(enchant_item:GetObject())
	local item_grade = shared_enchant_special_option.get_enchant_item_grade(enchant_item);
	
	if item_grade == "None" then
		ui.SysMsg("CantUse");
		return;
	end
	ui.OpenFrame('hairenchant_option')
end

function HIGH_HAIRENCHANT_CLOSE_BTN(frame, ctrl)
	local parent = frame:GetTopParentFrame();

	ui.RemoveGuideMsg("DropItemPlz");
	ui.SetEscapeScp("");

	HIGH_HAIRENCHANT_UI_RESET()

	local invframe = ui.GetFrame("inventory");
	SET_SLOT_APPLY_FUNC(invframe, "None");

	RESET_MOUSE_CURSOR();

	INVENTORY_SET_CUSTOM_RBTNDOWN("None");
	ui.CloseFrame('hairenchant_option');
end
---btn function end


---slot function start

function HIGH_HAIRENCHANT_ITEM_DROP(parent, ctrl)
	local frame				= parent:GetTopParentFrame();
	local liftIcon 			= ui.GetLiftIcon();
	local slot 			    = tolua.cast(ctrl, 'ui::CSlot');
	local iconInfo			= liftIcon:GetInfo();
	local invItem = GET_PC_ITEM_BY_GUID(iconInfo:GetIESID());

	if nil == invItem then
		return;	
	end

	RESET_HIGH_ENCHANT()

	HIGH_HAIRENCHANT_DRAW_HIRE_ITEM(slot, invItem);	
end

function HIGH_HAIRENCHANT_DRAW_HIRE_ITEM(slot, invItem)
	if true == invItem.isLockState then
		ui.SysMsg(ClMsg("MaterialItemIsLock"));
		return;
	end

	local obj = GetIES(invItem:GetObject());
	if ENCHANTCHIP_ABLIE(obj) ~= 1 then
		ui.SysMsg(ClMsg("MagicEnchant").." "..ClMsg("IT_ISNT_REINFORCEABLE_ITEM"));
		return;
	end

	local itemIES = invItem:GetIESID();
	if nil ~= session.GetEquipItemByGuid(itemIES) then
		ui.SysMsg(ClMsg("CantRegisterEquipItemToEnchant"));
		return;
	end

	local frame = ui.GetFrame("high_hairenchant");
	frame:SetUserValue("itemIES", itemIES);
	SET_SLOT_ITEM_IMAGE(slot, invItem);

	local bg = GET_CHILD(frame, "bg");
	local gbox = GET_CHILD(bg, "gbox");
	local pic_bg = GET_CHILD(gbox, "pic_bg");
	local groupbox_1 = GET_CHILD(pic_bg, "groupbox_1");

	local rank_up = GET_CHILD_RECURSIVELY(frame,"rank_up");

	local slot_bg_image = GET_CHILD_RECURSIVELY(frame, "slot_bg_image")
	slot_bg_image:ShowWindow(0)
	groupbox_1:ShowWindow(0);
	local groupbox_2 = GET_CHILD_RECURSIVELY(frame, 'groupbox_2');
	groupbox_2:ShowWindow(0);
	rank_up:ShowWindow(1);
	
	local itemName = groupbox_1:GetChild("text_itemname")
	itemName:SetTextByKey("value", obj.Name);

	imcSound.PlaySoundEvent('inven_equip');

	HIGH_HAIRENCHANT_UPDATE_ITEM_OPTION(itemIES);
end

---slot function end


---reset function start

function HIGH_HAIRENCHANT_UI_RESET()
	local frame = ui.GetFrame("high_hairenchant");

	CLEAR_ENCHANT_OPTION_ITEM_DATA_UI(frame)
	RESET_HIGH_ENCHANT()
	frame:ShowWindow(0);

end

function HIGH_ENCHANT_DEST_OPTION_SUCCESS()
	local frame = ui.GetFrame("high_hairenchant");
	RESET_HIGH_ENCHANT()
	HIGH_ENCHANT_CLEAR_DEST_OPTION_LIST(frame)
end


function RESET_HIGH_ENCHANT()
	local frame = ui.GetFrame("high_hairenchant");
	HIGH_INIT_AUTO_HAIRENCHANT(frame)
	HIGH_ENCHANT_CHANGE_BUTTON_STATE(frame, 1)

	local option = ui.GetFrame("hairenchant_option");
	ENCHANT_OPTION_RESET(option)
end

function HIGH_INIT_AUTO_HAIRENCHANT(frame)
	frame:SetUserValue('option_1', 'None')
	frame:SetUserValue('option_2', 'None')
	frame:SetUserValue('option_3', 'None')
	frame:SetUserValue('auto_run', 0)
end

function STOP_high_hairenchant()
	local frame = ui.GetFrame("high_hairenchant");
	frame:SetUserValue('auto_run', 0)
end

function REMOVE_ENCHANT_OPTION_TARGET_ITEM(frame)
	if ui.CheckHoldedUI() == true then
		return;
	end

	frame = frame:GetTopParentFrame();
	if isCloseable == 0 then
		ui.SysMsg(ClMsg("CannotCloseRandomReset"));
		return
	end

	local slot = GET_CHILD_RECURSIVELY(frame, "slot");
	slot:ClearIcon();
	CLEAR_ENCHANT_OPTION_ITEM_DATA_UI(frame)

	local option = ui.GetFrame("hairenchant_option");
	ENCHANT_OPTION_RESET(option)
end

function CLEAR_ENCHANT_OPTION_ITEM_DATA_UI(frame)
	if ui.CheckHoldedUI() == true then
		return;
	end
	-- local itemName = frame:GetChild("itemName")
	-- itemName:SetTextByKey("value", "");


	local slot = GET_CHILD_RECURSIVELY(frame, "slot", "ui::CSlot");
	slot:ClearIcon();
	local slot_bg_image = GET_CHILD_RECURSIVELY(frame, "slot_bg_image")
	slot_bg_image:ShowWindow(1)
	local bodyGbox1_1 = GET_CHILD_RECURSIVELY(frame, 'bodyGbox1_1');
	bodyGbox1_1:RemoveAllChild();
	local bodyGbox2_1 = GET_CHILD_RECURSIVELY(frame, 'bodyGbox2_1');
	bodyGbox2_1:RemoveAllChild();
	local groupbox_1 = GET_CHILD_RECURSIVELY(frame, 'groupbox_1');
	groupbox_1:ShowWindow(1);
	local rank_up = GET_CHILD_RECURSIVELY(frame,"rank_up");
	rank_up:ShowWindow(0);
	local groupbox_2 = GET_CHILD_RECURSIVELY(frame, 'groupbox_2');
	groupbox_2:ShowWindow(1);

	local option = frame:GetChild('rank_up_count')	
	option:SetTextByKey("value","");

	frame:SetUserValue("itemIES", "None");

	HIGH_ENCHANT_CHANGE_BUTTON_STATE(frame,1);
end

function HIGH_ENCHANT_CLEAR_DEST_OPTION_LIST(frame)
	local bg = GET_CHILD(frame,"bg")
	local gbox = GET_CHILD(bg,"gbox")
	local bodyGbox1 = GET_CHILD(gbox,"bodyGbox1")
	local bodyGbox1_1 = GET_CHILD(bodyGbox1,"bodyGbox1_1")
	bodyGbox1_1:RemoveAllChild();
end

function HIGH_HAIRENCHANT_UPDATE_ITEM_OPTION(itemIES)	
	local invItem = session.GetInvItemByGuid(itemIES)
	if nil == invItem then
		return;
	end
	local obj = GetIES(invItem:GetObject());

	local frame = ui.GetFrame("high_hairenchant");
	local bg =GET_CHILD(frame,"bg")
	local gbox = GET_CHILD(bg,"gbox")
	local bodyGbox1 = GET_CHILD(gbox,"bodyGbox2")
	local bodyGbox1_1 = GET_CHILD(bodyGbox1,"bodyGbox2_1")

	local nonOption = false;

	for i = 1, 3 do
		local propName = "HatPropName_"..i;
		local propValue = "HatPropValue_"..i;

		local option = frame:GetChild(propName)
		local txt = "";

		if obj[propValue] ~= 0 and obj[propName] ~= "None" then

			local opName
			--일반로직
			if string.find(obj[propName], 'ALLSKILL_') == nil then
				opName = string.format("%s",ScpArgMsg(obj[propName]));
			--스킬 레벨 up 로직
			else
				local token = StringSplit(obj[propName], '_')
				local job = token[2]
				if job == 'ShadowMancer' then
					job = 'Shadowmancer'
				end
				opName = string.format("%s", ScpArgMsg(job) .. ' ' .. ScpArgMsg('skill_lv_up_by_count'));
			end
			local strInfo = ABILITY_DESC_NO_PLUS(opName, tonumber(obj[propValue]), 0);

			local itemClsCtrl = bodyGbox1_1:CreateOrGetControlSet('eachproperty_in_itemrandomreset', 'PROPERTY_CSET_'..i, 0, 0);
			itemClsCtrl = AUTO_CAST(itemClsCtrl)
			local pos_y = itemClsCtrl:GetUserConfig("POS_Y")
			itemClsCtrl:Move(0, i * pos_y)
			local propertyList = GET_CHILD_RECURSIVELY(itemClsCtrl, "property_name", "ui::CRichText");
			propertyList:SetText(strInfo);
		end

	end
	
	local enchantGuid = frame:GetUserValue("Enchant");
	if enchantGuid ~= 'None' then
		local enchant_item = session.GetInvItemByGuid(enchantGuid)
		if enchant_item ~= nil then
			local enchant_obj = GetIES(enchant_item:GetObject())
			local enchant_grade = shared_enchant_special_option.get_enchant_item_grade(enchant_obj)
			if enchant_grade == 'None' then
				return
			end

			local option = frame:GetChild('rank_up_count')	
			local rank = shared_enchant_special_option.get_item_rank(obj)	
			local a, b = shared_enchant_special_option.get_item_rank_up_count(obj)
			local add_text = ScpArgMsg('hair_item_grade', 'grade', rank) 
			
			if b > 0 then
				add_text = string.format("%s{nl}%s",add_text,ScpArgMsg('hair_item_grade_insurance', 'num1', a, 'num2', b));
			end
			option:SetTextByKey("value", add_text);
		end
	end

end

---reset function end
function HIGH_HAIRENCHANT_SUCEECD(itemIES, moruItemClassID)
	HIGH_HAIRENCHANT_UPDATE_ITEM_OPTION(itemIES);

	local invItem = session.GetInvItemByGuid(itemIES);
	if invItem == nil then
		return;
	end

	local itemCls = GetClassByType("Item", invItem.type);
	local typeStr = "Item"	
	if itemCls.ItemType == "Equip" then
		typeStr = itemCls.ItemType; 
	end	

	imcSound.PlaySoundEvent("premium_enchantchip");
	
	local invframe = ui.GetFrame("inventory");
	local inventoryGbox = invframe:GetChild("inventoryGbox");
	local treeGbox = inventoryGbox:GetChild("treeGbox_" .. typeStr);
	local tree = GET_CHILD(treeGbox,"inventree_" .. typeStr);
	tree:CloseNodeAll();

	local treegroup = tree:FindByValue("Premium");
	tree:ShowTreeNode(treegroup, 1);
	treegroup = tree:FindByValue("EquipGroup");
	tree:ShowTreeNode(treegroup, 1);

	local enchantFrame = ui.GetFrame("high_hairenchant");
	local enchantGuid = enchantFrame:GetUserValue("Enchant");
	local invItem = session.GetInvItemByGuid(enchantGuid)
	local cnt = enchantFrame:GetChild("scrollCnt");
	if invItem ~= nil then
		cnt:SetTextByKey("value", tostring(invItem.count));
	else
		enchantGuid = GET_NEXT_ITEM_GUID_BY_CLASSID(moruItemClassID);
		enchantFrame:SetUserValue("Enchant", enchantGuid);
		local itemHaveCount = GET_INV_ITEM_COUNT_BY_CLASSID(moruItemClassID);

		cnt:SetTextByKey("value", itemHaveCount);
	end
end

-----auto function start

function AUTO_high_hairenchant(OptionList, repeatCount)
	local frame = ui.GetFrame("high_hairenchant");
	-- 초기화
	frame:SetUserValue('option_1', 'None')
	frame:SetUserValue('option_2', 'None')
	frame:SetUserValue('option_3', 'None')
	-- 종료 조건 설정
	frame:SetUserValue('option_1', OptionList[1])
	frame:SetUserValue('option_2', OptionList[2])
	frame:SetUserValue('option_3', OptionList[3])

	frame:SetUserValue('auto_run', 1)
end



local function sort_by_value_enchant(a, b) 
	return a[2] > b[2]	
end

function HIGH_HAIRENCHANT_SUCEECD_RESULT(option_list, option_value_list, is_rank_up)	
	local frame = ui.GetFrame("high_hairenchant");

	local token = StringSplit(option_list, ';')
	local token2 = StringSplit(option_value_list, ';')

	HIGH_HAIRENCHANT_UIEFFECT(frame);

	local cnt = EXT_GET_BTN_ENCAHNT_REPEAT_COUNT();
	local IsCheckRankUp = GET_CHECKBOX_STATE(frame);
	if IsCheckRankUp == 1 then
		if cnt > 1 and is_rank_up == 1 then
			RESET_HIGH_ENCHANT()
			ui.SysMsg(ClMsg('MagicAutoRankUpMessage'));
			--send system msg
			return;
		end
	end

	if frame:GetUserIValue('auto_run') == 1 then
		local prefix = 'option_'
		local goal_count = 0
		local match_count = 0
		local dic = {} -- goal value
		local dic_result = {}
		for i = 1, 3 do
			local prop = prefix .. i
			local option = frame:GetUserValue(prop)
			if option ~= 'None' then
				local token3 = StringSplit(option, ';')
				table.insert(dic, {token3[1], tonumber(token3[2])})
			end

			table.insert(dic_result, { token[i], tonumber(token2[i]) })
		end

		table.sort(dic, sort_by_value_enchant)
		table.sort(dic_result, sort_by_value_enchant)
		
		for i = 1, #dic do			
			local name = dic[i][1]
			local value = tonumber(dic[i][2])
			for j = 1, #dic_result do	
				if dic_result[j][1] == name and tonumber(dic_result[j][2]) > 0 then		
					if value <= tonumber(dic_result[j][2]) then
						match_count = match_count + 1
						dic_result[j][2] = 0					
						break
					end
				else
					if name == 'ALLSKILL' and string.find(dic_result[j][1], 'ALLSKILL') ~= nil and tonumber(dic_result[j][2]) > 0 then
						if value <= tonumber(dic_result[j][2]) then
							match_count = match_count + 1
							dic_result[j][2] = 0						
							break
						end
					end
				end
			end
			
			goal_count = goal_count + 1
		end
		frame:SetUserValue('Repeat',cnt - 1);
		if match_count > 0 then
			--print(option_list, option_value_list)
		end
		EXT_SET_BTN_ENCAHNT_REPEAT_COUNT(cnt - 1)
		if cnt > 1 then
			if match_count >= goal_count then
				HIGH_ENCHANT_DEST_OPTION_SUCCESS();
			else		
				HIGH_HAIRENCHANT_OK_BTN(frame)
			end
		else
			RESET_HIGH_ENCHANT()
		end
	end
end

function AUTO_OPTION_SETTING(frame, OptionList, count)
	local bg = GET_CHILD(frame,"bg")
	local gbox = GET_CHILD(bg,"gbox")
	local bodyGbox1 = GET_CHILD(gbox,"bodyGbox1")
	local bodyGbox1_1 = GET_CHILD(bodyGbox1,"bodyGbox1_1")

	HIGH_ENCHANT_CLEAR_DEST_OPTION_LIST(frame);

	local ypos = 25;
	local nonOption = false;
	AUTO_high_hairenchant(OptionList, count);
	for k, v in pairs(OptionList) do
		local Option = StringSplit(v,';')
		if Option[1] ~= "None" then
			local opName = string.format("%s %s", ClMsg('ItemRandomOptionGroupSTAT'), ScpArgMsg(Option[1]));
			local strInfo = ABILITY_DESC_NO_PLUS(opName, tonumber(Option[2]), 0);
			local itemClsCtrl = bodyGbox1_1:CreateOrGetControlSet('eachproperty_in_itemrandomreset', 'PROPERTY_CSET_'..k, 0, 0);
			itemClsCtrl = AUTO_CAST(itemClsCtrl)
			local pos_y = itemClsCtrl:GetUserConfig("POS_Y")
			local propertyList = GET_CHILD_RECURSIVELY(itemClsCtrl, "property_name", "ui::CRichText");
			propertyList:SetText(strInfo);
			itemClsCtrl:Move(0, ypos)
			ypos = ypos + pos_y;	
		end
	end
end

function HIGH_ENCHANT_CHANGE_BUTTON_STATE(frame, state)
	local bg = GET_CHILD(frame,"bg")
	local gbox = GET_CHILD(bg,"gbox")
	local send_ok = GET_CHILD(gbox,"send_ok")
	if state == 1 then
		send_ok:SetTextByKey("value", ClMsg('MagicEnchant'));
	elseif state == 0 then
		local auto_run = frame:GetUserIValue('auto_run')
		if auto_run == 1 then
			send_ok:SetTextByKey("value", ClMsg('MagicStop'));
		else
			state = 1
		end
	end
	send_ok:SetUserValue("State",state);
end
-----auto function end


----ui effect start

function HIGH_HAIRENCHANT_UIEFFECT(frame)
	local RESET_SUCCESS_EFFECT_NAME = frame:GetUserConfig('RESET_SUCCESS_EFFECT');
	local EFFECT_SCALE = tonumber(frame:GetUserConfig('EFFECT_SCALE'));
	local EFFECT_DURATION = tonumber(frame:GetUserConfig('EFFECT_DURATION'));
	local pic_bg = GET_CHILD_RECURSIVELY(frame, 'pic_bg');
	if pic_bg == nil then
		return;
	end

	pic_bg:PlayUIEffect(RESET_SUCCESS_EFFECT_NAME, EFFECT_SCALE, 'RESET_SUCCESS_EFFECT');

	local do_revertrandom = GET_CHILD_RECURSIVELY(frame, "do_revertrandom")
	do_revertrandom:ShowWindow(0)

	ui.SetHoldUI(true);

	ReserveScript("_HIGH_HAIRENCHANT_SUCCESS()", EFFECT_DURATION)

end

function _HIGH_HAIRENCHANT_SUCCESS()
	frame = ui.GetFrame('high_hairenchant')

	local RESET_SUCCESS_EFFECT_NAME = frame:GetUserConfig('RESET_SUCCESS_EFFECT');
	local EFFECT_SCALE = tonumber(frame:GetUserConfig('EFFECT_SCALE'));

	local pic_bg = GET_CHILD_RECURSIVELY(frame, 'pic_bg');
	if pic_bg == nil then
		return;
	end
	pic_bg:StopUIEffect('RESET_SUCCESS_EFFECT', true, 0.5);
	ui.SetHoldUI(false);
end

---- ui effect end



----external function start

function SET_REPEAT_COUNT_TEXT(count)
	local frame = ui.GetFrame('high_hairenchant')
	local repeatCount = GET_CHILD(frame,"repeatCount");
	repeatCount:SetTextByKey("value",string.format("%s : %d",ClMsg('REPEAT'),count));
end

---external function end

function GET_CHECKBOX_STATE(frame)
	if frame == nil then
		local frame = ui.GetFrame("high_hairenchant")
	end
	local rank_up = GET_CHILD_RECURSIVELY(frame,"rank_up");
	if rank_up == nil then
		return 0;
	end

	local check = rank_up:IsChecked()
	return check;
end
