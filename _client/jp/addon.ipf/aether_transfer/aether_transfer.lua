--aether_transfer.lua 2022/07/
--@desc : transfer aether gem from 460Lv -> 480Lv
function AETHER_TRANSFER_ON_INIT(addon, frame)
	addon:RegisterMsg('OPEN_DLG_AETHER_TRANSFER', 'ON_OPEN_DLG_AETHER_TRANSFER');
	addon:RegisterMsg('MSG_SUCCESS_AETHER_TRANSFER', 'SUCCESS_AETHER_TRANSFER');
	
	GET_CHILD_RECURSIVELY(frame,"text_itemname_left"):ShowWindow(0)
	GET_CHILD_RECURSIVELY(frame,"text_itemname_right"):ShowWindow(0)
	GET_CHILD_RECURSIVELY(frame,"text_desc"):ShowWindow(0)
end

--Called from Pyromancer Dialog menu 
function ON_OPEN_DLG_AETHER_TRANSFER(frame)
	frame:ShowWindow(1)
end

--Called from When you open UI
function AETHER_TRANSFER_OPEN(frame)
	ui.OpenFrame('inventory')
	local frame = ui.GetFrame('aether_transfer')
	INVENTORY_SET_CUSTOM_RBTNDOWN('AETHER_TRANSFER_PRESET_SLOT_INV_RBTN')
	AETHER_TRANSFER_RESET_ALL_SLOT(frame)
end

--Called from When you close UI
function AETHER_TRANSFER_CLOSE(frame)
	SetCraftState(0)
	INVENTORY_SET_CUSTOM_RBTNDOWN('None')
	ui.CloseFrame('inventory')
	frame:ShowWindow(0)
end

--SLOT UI.MOUSE INPUT EVENT START--
--Deletes the information of the set slot.
function AETHER_TRANSFER_REMOVE_SLOT_RBTN(parent,ctrl)
	local topFrame 	 = parent:GetTopParentFrame();
	ctrl:ClearIcon();
	local ctrl_name = ctrl:GetName();
	if ctrl_name==nil then return end
	local split_list = SCR_STRING_CUT_UNDERBAR(ctrl_name)
	local str_lower = split_list[2]
	if str_lower==nil then return end

	GET_CHILD_RECURSIVELY(topFrame,"slot_bg_image_"..str_lower):ShowWindow(1)
	GET_CHILD_RECURSIVELY(topFrame,"text_putonitem_"..str_lower):ShowWindow(1)
	local text_itemname = GET_CHILD_RECURSIVELY(topFrame,"text_itemname_"..str_lower)
	text_itemname:ShowWindow(0)
	text_itemname:SetTextByKey('name',"");

	local user_str = "SLOT_GUID_"..string.upper(str_lower)
	local user_val = ctrl:GetUserValue(user_str)
	if user_val ~= "None" then 
		SELECT_INV_SLOT_BY_GUID(user_val,0)
		ctrl:SetUserValue(user_str,"None")
	end
	AETHER_TRANSFER_UPDATE_IS_READY(topFrame)
end

-- Drag & Drop Aether
function AETHER_TRANSFER_SET_SLOT_DROP(parent, ctrl)
	if ui.CheckHoldedUI() == true then return; end
	local liftIcon 	= ui.GetLiftIcon();
	local liftSlot  = liftIcon:GetParent();
	local iconInfo  = liftIcon:GetInfo();
	local guid 	 	= iconInfo:GetIESID()	
	local inv_item  = session.GetInvItemByGuid(guid)
	local item_obj 	= GetIES(inv_item:GetObject())
	AETHER_TRANSFER_PRESET_SLOT_INV_RBTN(item_obj,liftSlot,guid)
end

-- The First Process that you trying to transfer 
function AETHER_TRANSFER_PRESET_SLOT_INV_RBTN(item_obj, slot, argStr)
	local frame = ui.GetFrame("aether_transfer")
	if frame == nil then return end
	
	if GETMYPCLEVEL() < PC_MAX_LEVEL then 
		ui.SysMsg(ClMsg('NeedMorePcLevel'))
		return 
	end

	if slot:IsSelected()==1 then slot:Select(0) end
	
	local fromFrame = slot:GetTopParentFrame();
	if fromFrame:GetName() ~= "inventory" then return end

	local group_name = TryGetProp(item_obj,"GroupName","None")
	if group_name=="None" then return elseif group_name~="Gem_High_Color" then return end
	
	local numberArg =  TryGetProp(item_obj,"NumberArg1",0)
	if numberArg==0 then return end

	local item_icon = slot:GetIcon()
	local icon_info = item_icon:GetInfo()
	local guid 	 	= icon_info:GetIESID()	
	local inv_item 	= session.GetInvItemByGuid(guid)
	local item_obj  = GetIES(inv_item:GetObject())

	if inv_item.isLockState ==true then
		ui.SysMsg(ClMsg('MaterialItemIsLock'))
		return 
	end
	
	local slot_left  = GET_CHILD_RECURSIVELY(frame,"slot_left")
	local slot_right = GET_CHILD_RECURSIVELY(frame,"slot_right")
	local currLv 	 = get_current_aether_gem_level(item_obj)
	
	if numberArg==460 then
		if is_max_aether_gem_level(item_obj) then 
			--SETTING LEFT SLOT 
			AETHER_TRANSFER_SET_SLOT(frame,inv_item,argStr,"left")
		else
			ui.SysMsg(ClMsg('invalidAetherGem'))
			return
		end
	elseif numberArg==480 then
		if currLv < 120 then 
			--SETTING RIGHT SLOT
			AETHER_TRANSFER_SET_SLOT(frame,inv_item,argStr,"right")
			
		elseif currLv >= 120 then
			ui.SysMsg(ClMsg('aleadyHighLevel'))
			return
		end
	end

	AETHER_TRANSFER_UPDATE_IS_READY(frame)
end
---SLOT UI.MOUSE INPUT EVENT END--- 

-- Depending on the type of aether gem,this func will find it and set it up.
function AETHER_TRANSFER_SET_SLOT(frame,inv_item,argStr,Left_or_Right)
	if ui.CheckHoldedUI() == true then return; end	
	local slot 	 	  = GET_CHILD_RECURSIVELY(frame,"slot_"..Left_or_Right)
	local new_guid	  = inv_item:GetIESID()
	local str_upper	  = string.upper(Left_or_Right)
	local curr_guid = slot:GetUserValue("SLOT_GUID_"..str_upper)
	if curr_guid ~="None"then 
		slot:ClearIcon();
		SELECT_INV_SLOT_BY_GUID(curr_guid,0)
	end

	slot:SetUserValue("SLOT_GUID_"..str_upper,new_guid)
	SET_SLOT_ITEM(slot,inv_item)
	SELECT_INV_SLOT_BY_GUID(new_guid,1)
	
	-- slot text setting --
	local item_obj  = GetIES(inv_item:GetObject())
	local text_itemname = GET_CHILD_RECURSIVELY(frame,"text_itemname_"..Left_or_Right)
	text_itemname:SetTextByKey('name', TryGetProp(item_obj,"Name","None"));
	text_itemname:ShowWindow(1)
	GET_CHILD_RECURSIVELY(frame,"text_putonitem_"..Left_or_Right):ShowWindow(0)
	GET_CHILD_RECURSIVELY(frame,"slot_bg_image_"..Left_or_Right):ShowWindow(0)
	-- slot text setting --
end

--Reset ALL UI SLOT before select
function AETHER_TRANSFER_RESET_ALL_SLOT(parent)
	local topFrame 	 = parent:GetTopParentFrame();
	local slot_left  = GET_CHILD_RECURSIVELY(topFrame,"slot_left")
	local slot_left_userval = slot_left:GetUserValue("SLOT_GUID_LEFT")
	
	local slot_right = GET_CHILD_RECURSIVELY(topFrame,"slot_right")
	local slot_right_userval = slot_right:GetUserValue("SLOT_GUID_RIGHT")

	if slot_left_userval ~="None" then AETHER_TRANSFER_REMOVE_SLOT_RBTN(parent,slot_left)  end
	if slot_right_userval~="None" then AETHER_TRANSFER_REMOVE_SLOT_RBTN(parent,slot_right) end
end

function AETHER_TRANSFER_UPDATE_IS_READY(frame)
	local slot_left  = GET_CHILD_RECURSIVELY(frame,"slot_left")
	local guid_left  = slot_left:GetUserValue("SLOT_GUID_LEFT")
	local slot_right = GET_CHILD_RECURSIVELY(frame,"slot_right")
	local guid_right = slot_right:GetUserValue("SLOT_GUID_RIGHT")
	local text_desc  = GET_CHILD_RECURSIVELY(frame,"text_desc")
	text_desc:ShowWindow(0) 
	local execbtn = GET_CHILD_RECURSIVELY(frame,"do_transfer")
	if execbtn==nil then return end
	execbtn:SetEnable(0)
	
	----------------------Boundary-----------------------------
	if guid_left =="None" or guid_right=="None" then return false end
	-----------------------------------------------------------
	local left_item    = session.GetInvItemByGuid(guid_left)
	local right_item   = session.GetInvItemByGuid(guid_right)
	if left_item == nil or right_item== nil then return end

	if left_item.isLockState == true or right_item.isLockState == true then
		ui.SysMsg(ClMsg('MaterialItemIsLock'))
		return
	end

	local from  =  GetIES(left_item:GetObject())
	local to = GetIES(right_item:GetObject())
	local to_name = TryGetProp(to,"Name","None")
	local from_name = TryGetProp(from,"Name","None")
	

	text_desc:SetTextByKey("value1", TryGetProp(to,"AetherGemLevel"))
	text_desc:SetTextByKey("value2", TryGetProp(from,"AetherGemLevel"))
	if text_desc:IsVisible()==0 then text_desc:ShowWindow(1) end
	execbtn:SetEnable(1)

	return guid_left,guid_right,to_name,from_name
end

function AETHER_TRANSFER_EXEC(parent)
	local frame = parent:GetTopParentFrame()
	if frame == nil then return end


	session.ResetItemList()
	local guid_left,guid_right,to_name,from_name = AETHER_TRANSFER_UPDATE_IS_READY(frame)
	local right_inv   = session.GetInvItemByGuid(guid_right)
	local right_obj = GetIES(right_inv:GetObject())
	local obj_lv = TryGetProp(right_obj,"AetherGemLevel",0)


	if guid_left==nil or guid_left=="None" or guid_right==nil or guid_right=="None" then return end
	
	session.AddItemID(guid_left,1)
	session.AddItemID(guid_right,1)

	if obj_lv > 1 then 
		local msg =  ScpArgMsg('AetherReallyWantTransfer{msg}{ITEM}{GEM_LV}', 'msg', ClMsg('transfer_now'), 'ITEM', to_name,'GEM_LV',obj_lv);
		local yesScp =  string.format("_AETHER_TRANSFER_EXEC")
		WARNINGMSGBOX_FRAME_OPEN_TRANSFER_ITEM(msg,yesScp,"None",guid_right)
	else
		_AETHER_TRANSFER_EXEC()
	end

end

function _AETHER_TRANSFER_EXEC()
	
	local result_list = session.GetItemIDList()
	local arg_list = NewStringList()
	
	item.DialogTransaction('AETHER_TRANSFER', result_list, '', arg_list)
end

function SUCCESS_AETHER_TRANSFER(frame)
	PLAY_AETHER_TRANSFER_EFFECT_MODULE()
end

-- EFFECT START --
function PLAY_AETHER_TRANSFER_EFFECT_MODULE()
	SetCraftState(1)
	
	local frame = ui.GetFrame('aether_transfer')
	GET_CHILD_RECURSIVELY(frame,"slot_left"):EnableHitTest(0)
	GET_CHILD_RECURSIVELY(frame,"slot_right"):EnableHitTest(0)
	GET_CHILD_RECURSIVELY(frame,"reset_all_btn"):SetEnable(0)
	
	INVENTORY_SET_CUSTOM_RBTNDOWN('None')
	
	imcSound.PlaySoundEvent("button_click_skill_up")
	PLAY_AETHER_TRANSFER_EFFECT_LEFT()
	PLAY_AETHER_TRANSFER_EFFECT_MIDDLE()
	ReserveScript('PLAY_AETHER_TRANSFER_EFFECT_RIGHT()', 1.0);
end

function PLAY_AETHER_TRANSFER_EFFECT_LEFT()
	--UI_item_parts2_success
	local frame 		 = ui.GetFrame("aether_transfer");
	local left_effect_gb = GET_CHILD_RECURSIVELY(frame, 'left_effect_gb');
	left_effect_gb:ShowWindow(1);
	left_effect_gb:PlayUIEffect(frame:GetUserConfig("DO_TRANSFER_EFFECT_LEFT"),tonumber(frame:GetUserConfig("DO_TRANSFER_EFFECT_LEFT_SCALE")), 'AETHER_TRANSFER_EFFECT_LEFT', true);
	
	--ui.SetHoldUI(true);
	ReserveScript('RELEASE_AETHER_TRANSFER_EFFECT_UI_HOLD_LEFT()', 0.7);
end

function RELEASE_AETHER_TRANSFER_EFFECT_UI_HOLD_LEFT()
	local frame 		 = ui.GetFrame("aether_transfer");
	local left_effect_gb = GET_CHILD_RECURSIVELY(frame, 'left_effect_gb');
	left_effect_gb:StopUIEffect('AETHER_TRANSFER_EFFECT_LEFT', true, 0);

	--remove visual icon-
	local slot_left  = GET_CHILD_RECURSIVELY(frame,"slot_left")
	slot_left:ClearIcon();
end

function PLAY_AETHER_TRANSFER_EFFECT_RIGHT()
	local frame 		 = ui.GetFrame("aether_transfer");
	local right_effect_gb = GET_CHILD_RECURSIVELY(frame, 'right_effect_gb');
	right_effect_gb:ShowWindow(1);
	right_effect_gb:PlayUIEffect(frame:GetUserConfig("DO_TRANSFER_EFFECT_RIGHT"),tonumber(frame:GetUserConfig("DO_TRANSFER_EFFECT_RIGHT_SCALE")), 'AETHER_TRANSFER_EFFECT_RIGHT', true);
	imcSound.PlaySoundEvent("sys_transcend_cast")
		
	ReserveScript('RELEASE_AETHER_TRANSFER_EFFECT_UI_HOLD_RIGHT()', 2.0);
	ReserveScript('UNLOCK_AETHER_TRANSFER_UI_CONTROL()', 4.0);
end

function UNLOCK_AETHER_TRANSFER_UI_CONTROL()
	local frame 		 = ui.GetFrame("aether_transfer");
	GET_CHILD_RECURSIVELY(frame,"slot_left"):EnableHitTest(1)
	GET_CHILD_RECURSIVELY(frame,"slot_right"):EnableHitTest(1)
	GET_CHILD_RECURSIVELY(frame,"reset_all_btn"):SetEnable(1)
	
	SetCraftState(0)
	INVENTORY_SET_CUSTOM_RBTNDOWN('AETHER_TRANSFER_PRESET_SLOT_INV_RBTN')
	AETHER_TRANSFER_RESET_ALL_SLOT(frame)
end

function RELEASE_AETHER_TRANSFER_EFFECT_UI_HOLD_RIGHT()
	local frame 		 = ui.GetFrame("aether_transfer");
	local right_effect_gb = GET_CHILD_RECURSIVELY(frame, 'left_effect_gb');
	right_effect_gb:StopUIEffect('AETHER_TRANSFER_EFFECT_RIGHT', true, 0);
	imcSound.ReleaseSoundEvent("sys_transcend_success");
	imcSound.PlaySoundEvent("sys_transcend_success");

end

function PLAY_AETHER_TRANSFER_EFFECT_MIDDLE()
	local frame 		 = ui.GetFrame("aether_transfer");
	local middle_effect_gb = GET_CHILD_RECURSIVELY(frame, 'middle_effect_gb');
	middle_effect_gb:ShowWindow(1);
	middle_effect_gb:PlayUIEffect(frame:GetUserConfig("TRANSFER_SUCCESS"),tonumber(frame:GetUserConfig("TRANSFER_EFFECT_SCALE")), 'AETHER_TRANSFER_SUCCESS', true);
end
-- EFFECT END --