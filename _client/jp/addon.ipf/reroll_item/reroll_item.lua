function REROLL_ITEM_ON_INIT(addon, frame)
	addon:RegisterMsg('OPEN_DLG_REROLL_ITEM', 'ON_OPEN_DLG_REROLL_ITEM')
	addon:RegisterMsg('MSG_SUCCESS_REROLL_OPTION', 'SUCCESS_REROLL_OPTION')
	addon:RegisterMsg('MSG_SUCCESS_REROLL_OPTION_SELECT', 'SUCCESS_REROLL_OPTION_SELECT')
end

local other_reroll_list = {
	'itemrevertrandom',
	'itemunrevertrandom',
	'itemsandrarevertrandom',
	'itemsandraoneline_revert_random',
	'itemsandra_precision_revert_random'
}

function ON_OPEN_DLG_REROLL_ITEM(frame)
	frame:ShowWindow(1)
end

function REROLL_ITEM_OPEN(frame)
	for i = 1, #other_reroll_list do
		local other_frame = ui.GetFrame(other_reroll_list[i])
		if other_frame ~= nil and other_frame:IsVisible() == 1 then
			other_frame:ShowWindow(0)
		end
	end

	CLEAR_REROLL_ITEM_UI()
	INVENTORY_SET_CUSTOM_RBTNDOWN('REROLL_ITEM_INV_RBTN')
	ui.OpenFrame('inventory')
end

function REROLL_ITEM_CLOSE(frame)
	if ui.CheckHoldedUI() == true then
		return
	end

	INVENTORY_SET_CUSTOM_RBTNDOWN('None')
	frame:ShowWindow(0)
	control.DialogOk()
	ui.CloseFrame('inventory')
	ui.CloseFrame('reroll_item_option')
end

function CLEAR_REROLL_ITEM_UI()
	if ui.CheckHoldedUI() == true then return end

	local frame = ui.GetFrame('reroll_item')
	frame:SetUserValue('CURRENT_INDEX', 'None')

	local slot = GET_CHILD_RECURSIVELY(frame, 'slot', 'ui::CSlot')
	slot:ClearIcon()
	local slot_bg_image = GET_CHILD_RECURSIVELY(frame, 'slot_bg_image')
	slot_bg_image:ShowWindow(1)
	
	local text_itemname = GET_CHILD_RECURSIVELY(frame, 'text_itemname')
	text_itemname:SetText('')
	local text_putonitem = GET_CHILD_RECURSIVELY(frame, 'text_putonitem')
	text_putonitem:ShowWindow(1)
	
	local text_optionselect = GET_CHILD_RECURSIVELY(frame, 'text_optionselect')
	text_optionselect:ShowWindow(0)
	local text_currentoption = GET_CHILD_RECURSIVELY(frame, 'text_currentoption')
	text_currentoption:ShowWindow(1)
	local currentGbox_inner = GET_CHILD_RECURSIVELY(frame, 'currentGbox_inner')
	currentGbox_inner:RemoveAllChild()
	local currentGbox = GET_CHILD_RECURSIVELY(frame, 'currentGbox')
	currentGbox:ShowWindow(1)
	
	local text_material = GET_CHILD_RECURSIVELY(frame, 'text_material')
	text_material:ShowWindow(1)
	local materialGbox = GET_CHILD_RECURSIVELY(frame, 'materialGbox')
	materialGbox:RemoveAllChild()
	materialGbox:ShowWindow(1)

	local send_select = GET_CHILD_RECURSIVELY(frame, 'send_select')
	send_select:ShowWindow(0)
	local do_reroll = GET_CHILD_RECURSIVELY(frame, 'do_reroll')
	do_reroll:ShowWindow(1)

	ui.CloseFrame('reroll_item_option')
end

function REROLL_TARGET_ITEM_DROP(frame, icon, argStr, argNum)
	if ui.CheckHoldedUI() == true then return end

	local liftIcon = ui.GetLiftIcon()
	local FromFrame = liftIcon:GetTopParentFrame()
	local toFrame = frame:GetTopParentFrame()
	if FromFrame:GetName() == 'inventory' then
		local iconInfo = liftIcon:GetInfo()
		REROLL_ITEM_REG_TARGETITEM(frame, iconInfo:GetIESID())
	end
end

function REROLL_ITEM_REG_TARGETITEM(frame, itemID, reroll_index, reroll_str)
	if ui.CheckHoldedUI() == true then return end

	local inv_item = session.GetInvItemByGuid(itemID)
	if inv_item == nil then return end

	local item_obj = GetIES(inv_item:GetObject())
	local item_cls = GetClassByType('Item', inv_item.type)
	if item_obj == nil or item_cls == nil then return end

	local pc = GetMyPCObject()
	if pc == nil then return end
		
	if IS_ABLT_TO_REROLL(item_obj) == false then
		-- 재설정 가능한 아이템인지의 조건 체크용 스크립트를 별도로 추가해야 할 듯
		ui.SysMsg(ClMsg('CantRerollEquipment'))
		return
	end

	local invframe = ui.GetFrame('inventory')
	if true == inv_item.isLockState or true == IS_TEMP_LOCK(invframe, inv_item) then
		ui.SysMsg(ClMsg('MaterialItemIsLock'))
		return
	end
	
	local group_name = TryGetProp(item_obj, 'GroupName', 'None')
	local reroll_mat_list, is_valid

	if group_name == 'Icor' then
		reroll_mat_list, is_valid = shared_item_goddess_icor.get_reroll_cost_table(item_obj)	
	elseif group_name == 'BELT' then
		reroll_mat_list, is_valid = shared_item_belt.get_reroll_cost_table(item_obj)	
	elseif group_name == 'SHOULDER' then
		reroll_mat_list, is_valid = shared_item_shoulder.get_reroll_cost_table(item_obj)			
	end
	if reroll_mat_list == nil or is_valid == false then 
		ui.SysMsg(ClMsg('CantRerollEquipment'))
		return 
	end

	CLEAR_REROLL_ITEM_UI()

	-- 재설정 중인 아이템 등록 시 메시지 출력
	local item_reroll_str = TryGetProp(item_obj, 'RerollStr', 'None')
	if item_reroll_str ~= 'None' then
		ui.SysMsg(ClMsg('FirstSelectRerollOption'))
	end

	local slot = GET_CHILD_RECURSIVELY(frame, 'slot')
	SET_SLOT_ITEM(slot, inv_item)

	local text_putonitem = GET_CHILD_RECURSIVELY(frame, 'text_putonitem')
	text_putonitem:ShowWindow(0)

	local slot_bg_image = GET_CHILD_RECURSIVELY(frame, 'slot_bg_image')
	slot_bg_image:ShowWindow(0)

	local text_itemname = GET_CHILD_RECURSIVELY(frame, 'text_itemname')
	text_itemname:SetText(item_obj.Name)

	REROLL_ITEM_MAKE_SELECT_LIST(frame, item_obj, reroll_index, reroll_str)	

	REROLL_ITEM_MAKE_MATERIAL_LIST(frame, item_obj, reroll_str)
end

function REROLL_ITEM_MAKE_SELECT_LIST(frame, item_obj, reroll_index, reroll_str)
	if reroll_index == nil then
		reroll_index = TryGetProp(item_obj, 'RerollIndex', 0)
	end
	
	if reroll_str == nil then
		reroll_str = TryGetProp(item_obj, 'RerollStr', 'None')
	end

	frame:SetUserValue('CURRENT_INDEX', 'None')

	local function _MAKE_REROLL_OPTION_CTRL(gBox, item_obj, group, name, value, ctrl_count, ind, adj, list_flag)
		value = tonumber(value)
		local clmsg = GET_CLMSG_BY_OPTION_GROUP(group)
		local name_str = string.format('%s %s', ClMsg(clmsg), ScpArgMsg(name))		
		local info_str = ABILITY_DESC_NO_PLUS(name_str, value, 0)		
		local option_ctrlset = gBox:CreateOrGetControlSet('eachproperty_in_reroll_item', 'PROPERTY_CSET_' .. ctrl_count, 0, 0)
		option_ctrlset = AUTO_CAST(option_ctrlset)
		local pos_y = option_ctrlset:GetUserConfig('POS_Y')
		option_ctrlset:Move(0, (ctrl_count - 1) * pos_y + adj)
		local property_name = GET_CHILD_RECURSIVELY(option_ctrlset, 'property_name', 'ui::CRichText')
		property_name:SetEventScriptArgNumber(ui.LBUTTONUP, ind)
		property_name:SetText(info_str)
		local help_pic = GET_CHILD_RECURSIVELY(option_ctrlset, 'help_pic')
		help_pic:ShowWindow(list_flag)

		return option_ctrlset
	end
	
	local y_adj = 21
	local currentGbox_inner = GET_CHILD_RECURSIVELY(frame, 'currentGbox_inner')
	currentGbox_inner:RemoveAllChild()		
	if reroll_index == 0 then
		-- 최초
		for i = 1, MAX_RANDOM_OPTION_COUNT do
			local group_name = 'RandomOptionGroup_' .. i
			local prop_name = 'RandomOption_' .. i
			local prop_value = 'RandomOptionValue_' .. i

			local ret = true
			if TryGetProp(item_obj, 'GroupName', 'None') == 'Icor' then
				ret = shared_item_goddess_icor.is_able_to_reroll(item_obj, i)		
			end			

			if ret == true and item_obj[prop_value] ~= 0 and item_obj[prop_name] ~= 'None' then				
				_MAKE_REROLL_OPTION_CTRL(currentGbox_inner, item_obj, item_obj[group_name], item_obj[prop_name], item_obj[prop_value], i, i, y_adj, 1)
			end
		end
	else
		-- 2회차 이상
		local group_name = 'RandomOptionGroup_' .. reroll_index
		local prop_name = 'RandomOption_' .. reroll_index
		local prop_value = 'RandomOptionValue_' .. reroll_index
		if item_obj[prop_value] ~= 0 and item_obj[prop_name] ~= 'None' then
			local list_flag = BOOLEAN_TO_NUMBER(reroll_str == 'None')			
			if reroll_str == 'None' then
				local ctrlset = _MAKE_REROLL_OPTION_CTRL(currentGbox_inner, item_obj, item_obj[group_name], item_obj[prop_name], item_obj[prop_value], 1, reroll_index, y_adj, list_flag)
				REROLL_ITEM_SELECT_OPTION(frame, ctrlset, reroll_index)
			else
				-- 재설정 도중				
				local ctrlset = _MAKE_REROLL_OPTION_CTRL(currentGbox_inner, item_obj, item_obj[group_name], item_obj[prop_name], item_obj[prop_value], 1, 1, y_adj, list_flag)				

				-- 현재 옵션과 후보 옵션 구분을 위하여 라인 추가
				local pos_y = ctrlset:GetUserConfig('POS_Y')
				local line = currentGbox_inner:CreateControl('labelline', 'line_div', 5, pos_y + y_adj + 4, currentGbox_inner:GetWidth() - 10, 4)
				line = AUTO_CAST(line)
				line:SetSkinName('labelline_def_2')
				y_adj = y_adj + 6

				local candidate_list = StringSplit(reroll_str, ';')
				for i = 1, #candidate_list do
					local candidate_info = StringSplit(candidate_list[i], '/')
					local candidate_name = candidate_info[1]
					local candidate_value = candidate_info[2]
					local candidate_group = 'None'
					local group_name = TryGetProp(item_obj, 'GroupName', 'None')
					if group_name == 'Icor' then
						candidate_group = shared_item_goddess_icor.get_option_group_name(candidate_name)
					elseif group_name == 'BELT' then
						candidate_group = shared_item_belt.get_option_group_name(candidate_name)
					elseif group_name == 'SHOULDER' then
						candidate_group = shared_item_shoulder.get_option_group_name(candidate_name)
					end
					_MAKE_REROLL_OPTION_CTRL(currentGbox_inner, item_obj, candidate_group, candidate_name, candidate_value, i + 1, i + 1, y_adj, list_flag)
				end
			end
		end
	end

	local text_currentoption = GET_CHILD_RECURSIVELY(frame, 'text_currentoption')
	text_currentoption:ShowWindow(BOOLEAN_TO_NUMBER(reroll_str == 'None'))

	local text_optionselect = GET_CHILD_RECURSIVELY(frame, 'text_optionselect')
	text_optionselect:ShowWindow(BOOLEAN_TO_NUMBER(reroll_str ~= 'None'))

	local do_reroll = GET_CHILD_RECURSIVELY(frame, 'do_reroll')
	do_reroll:ShowWindow(BOOLEAN_TO_NUMBER(reroll_str == 'None'))

	local send_select = GET_CHILD_RECURSIVELY(frame, 'send_select')
	send_select:ShowWindow(BOOLEAN_TO_NUMBER(reroll_str ~= 'None'))
end

function REROLL_ITEM_MAKE_MATERIAL_LIST(frame, item_obj, reroll_str)	
	local pc = GetMyPCObject()
	if pc == nil then return end


	local group_name = TryGetProp(item_obj, 'GroupName', 'None')
	local reroll_mat_list, is_valid

	if group_name == 'Icor' then
		reroll_mat_list, is_valid = shared_item_goddess_icor.get_reroll_cost_table(item_obj)	
	elseif group_name == 'BELT' then
		reroll_mat_list, is_valid = shared_item_belt.get_reroll_cost_table(item_obj)	
	elseif group_name == 'SHOULDER' then
		reroll_mat_list, is_valid = shared_item_shoulder.get_reroll_cost_table(item_obj)			
	end

	if reroll_mat_list == nil or is_valid == false then
		return
	end

	local text_material = GET_CHILD_RECURSIVELY(frame, 'text_material')
	local materialGbox = GET_CHILD_RECURSIVELY(frame, 'materialGbox')
	
	if reroll_str == nil then
		reroll_str = TryGetProp(item_obj, 'RerollStr', 'None')
	end

	if reroll_str ~= 'None' then
		-- 재설정 도중
		text_material:ShowWindow(0)
		materialGbox:ShowWindow(0)
		return
	else
		text_material:ShowWindow(1)
		materialGbox:ShowWindow(1)
	end

	local isAbleExchange = 1

	local mat_item_slot_count = 0
	for mat_clsname, mat_count in pairs(reroll_mat_list) do
		local mat_ctrl = materialGbox:CreateOrGetControlSet('eachmaterial_in_itemrandomreset', 'MATERIAL_CSET_' .. (mat_item_slot_count + 1), 0, 0)
		mat_ctrl = AUTO_CAST(mat_ctrl)
		local pos_y = mat_ctrl:GetUserConfig('POS_Y')
		mat_ctrl:Move(0, mat_item_slot_count * pos_y)
		local material_icon = GET_CHILD_RECURSIVELY(mat_ctrl, 'material_icon', 'ui::CPicture')
		local material_questionmark = GET_CHILD_RECURSIVELY(mat_ctrl, 'material_questionmark', 'ui::CPicture')
		local material_name = GET_CHILD_RECURSIVELY(mat_ctrl, 'material_name', 'ui::CRichText')
		local material_count = GET_CHILD_RECURSIVELY(mat_ctrl, 'material_count', 'ui::CRichText')
		local gradetext2 = GET_CHILD_RECURSIVELY(mat_ctrl, 'grade', 'ui::CRichText')

		material_icon:ShowWindow(1)
		material_questionmark:ShowWindow(0)
		material_count:ShowWindow(1)

		local mat_name = ScpArgMsg('NotDecidedYet')
		local mat_icon = 'question_mark'

		if item_obj ~= nil then
			local mat_cls = nil			
			if IS_STRING_COIN(mat_clsname) == true then
				mat_cls = GetClass('Item', 'dummy_' .. mat_clsname)
			else
				mat_cls = GetClass('Item', mat_clsname)
			end
			
			if mat_cls ~= nil then
				mat_ctrl:ShowWindow(1)

				mat_icon = mat_cls.Icon
				mat_name = mat_cls.Name

				local inv_mat_count = 0
				local inv_mat_item = nil

				if IS_STRING_COIN(mat_clsname) == true then
					local acc = GetMyAccountObj()
					inv_mat_count = TryGetProp(acc, mat_clsname, 'None')
					if inv_mat_count == 'None' then
						inv_mat_count = '0'
					end					
				else
					inv_mat_count = GetInvItemCount(pc, mat_clsname)
					inv_mat_item = session.GetInvItemByName(mat_clsname)
				end
				
				local type = item_obj.ClassID
				
				if math.is_larger_than(tostring(mat_count), tostring(inv_mat_count)) == 1 then
					material_count:SetTextByKey('color', '{#EE0000}')					
					isAbleExchange = 0
				elseif inv_mat_item ~= nil and inv_mat_item.isLockState == true then
					isAbleExchange = -1
				else 
					material_count:SetTextByKey('color', nil)
				end

				material_count:SetTextByKey('curCount', inv_mat_count)

				if IsBuffApplied(pc, 'Event_Steam_New_World_Buff') == 'YES' then
					material_count:SetTextByKey('needCount', mat_count .. ' ' .. ScpArgMsg('EVENT_REINFORCE_DISCOUNT_MSG_70'))
				elseif IsBuffApplied(pc, 'Event_Reappraisal_Discount_50') == 'YES' then
                    material_count:SetTextByKey('needCount', mat_count .. ' ' ..ScpArgMsg('EVENT_REINFORCE_DISCOUNT_MSG1'))
    			else
    				material_count:SetTextByKey('needCount', mat_count)
    			end

				material_count:ShowWindow(1)

				mat_item_slot_count = mat_item_slot_count + 1
			else
				mat_ctrl:ShowWindow(0)
			end
		else
			mat_ctrl:ShowWindow(0)
		end

		material_icon:SetImage(mat_icon)
		material_name:SetText(mat_name)
	end

	frame:SetUserValue('MAX_EXCHANGEITEM_CNT', mat_item_slot)
	frame:SetUserValue('isAbleExchange', isAbleExchange)
end

function REROLL_ITEM_EXEC(parent, ctrl)
	local frame = parent:GetTopParentFrame()
	local slot = GET_CHILD_RECURSIVELY(frame, 'slot')
	local inv_item = GET_SLOT_ITEM(slot)
	if inv_item == nil then return end

	local item_obj = GetIES(inv_item:GetObject())
	if TryGetProp(item_obj, 'TeamBelonging', 0) == 0 then
		-- 최초 실행 시 팀 귀속 경고
		WARNINGMSGBOX_FRAME_OPEN(ScpArgMsg('ConvertToNoTradeWarningReroll{NAME}', 'NAME', TryGetProp(item_obj, 'Name', 'None')), '_REROLL_ITEM_EXEC', '_REROLL_ITEM_CANCEL', nil, ScpArgMsg('WarningTeamBelonging'))
	else
		local check_no_msgbox = GET_CHILD_RECURSIVELY(frame, 'check_no_reset_item')
		if check_no_msgbox:IsChecked() ~= 1 then
			local clmsg = ScpArgMsg('DoRerollOption')
			local msgbox = ui.MsgBox_NonNested(clmsg, frame:GetName(), '_REROLL_ITEM_EXEC', '_REROLL_ITEM_CANCEL')
			SET_MODAL_MSGBOX(msgbox)
		else
			_REROLL_ITEM_EXEC()
		end
	end
end

function _REROLL_ITEM_CANCEL()
	local frame = ui.GetFrame('reroll_item')
end

function _REROLL_ITEM_EXEC()
	local frame = ui.GetFrame('reroll_item')
	if frame:IsVisible() == 0 then return end

	local slot = GET_CHILD_RECURSIVELY(frame, 'slot')
	local inv_item = GET_SLOT_ITEM(slot)
	if inv_item == nil then return end
	
	local isAbleExchange = frame:GetUserIValue('isAbleExchange')	
	if isAbleExchange == 0 then
		ui.SysMsg(ClMsg('NotEnoughRecipe'))
		return
	end

	if isAbleExchange == -1 then
		ui.SysMsg(ClMsg('MaterialItemIsLock'))
		return
	end

	if isAbleExchange == -2 then
		ui.SysMsg(ClMsg('MaxDurUnderflow')) 
		return
	end

	local index = frame:GetUserValue('CURRENT_INDEX')
	if index == nil or index == 'None' then
		ui.SysMsg(ClMsg('CannotCloseRandomReset'))
		return
	end
	
	pc.ReqExecuteTx_Item('REROLL_ITEM', inv_item:GetIESID(), tonumber(index))
end

function SUCCESS_REROLL_OPTION(frame, msg, arg_str, arg_num)
	local RESET_SUCCESS_EFFECT_NAME = frame:GetUserConfig('RESET_SUCCESS_EFFECT')
	local EFFECT_SCALE = tonumber(frame:GetUserConfig('EFFECT_SCALE'))
	local EFFECT_DURATION = tonumber(frame:GetUserConfig('EFFECT_DURATION'))
	local pic_bg = GET_CHILD_RECURSIVELY(frame, 'pic_bg')
	if pic_bg == nil then return end

	pic_bg:PlayUIEffect(RESET_SUCCESS_EFFECT_NAME, EFFECT_SCALE, 'SUCCESS_REROLL_OPTION')

	local do_reroll = GET_CHILD_RECURSIVELY(frame, 'do_reroll')
	do_reroll:ShowWindow(0)

	ui.SetHoldUI(true)

	local reserve_scp = string.format('_SUCCESS_REROLL_OPTION(\'%s\', %d)', arg_str, arg_num)
	ReserveScript(reserve_scp, EFFECT_DURATION)
end

function _SUCCESS_REROLL_OPTION(reroll_str, reroll_index)
	ui.SetHoldUI(false)

	local frame = ui.GetFrame('reroll_item')
	if frame:IsVisible() == 0 then return end

	local slot = GET_CHILD_RECURSIVELY(frame, 'slot')
	local inv_item = GET_SLOT_ITEM(slot)
	if inv_item == nil then return end

	local RESET_SUCCESS_EFFECT_NAME = frame:GetUserConfig('RESET_SUCCESS_EFFECT')
	local EFFECT_SCALE = tonumber(frame:GetUserConfig('EFFECT_SCALE'))
	local pic_bg = GET_CHILD_RECURSIVELY(frame, 'pic_bg')
	if pic_bg == nil then return end

	pic_bg:StopUIEffect('SUCCESS_REROLL_OPTION', true, 0.5)

	local send_select = GET_CHILD_RECURSIVELY(frame, 'send_select')
	send_select:ShowWindow(1)
	
	local text_currentoption = GET_CHILD_RECURSIVELY(frame, 'text_currentoption')
	text_currentoption:ShowWindow(0)
	
	local text_optionselect = GET_CHILD_RECURSIVELY(frame, 'text_optionselect')
	text_optionselect:ShowWindow(1)
	
	local text_material = GET_CHILD_RECURSIVELY(frame, 'text_material')
	text_material:ShowWindow(0)

	local materialGbox = GET_CHILD_RECURSIVELY(frame, 'materialGbox')
	materialGbox:ShowWindow(0)

	inv_item = GET_SLOT_ITEM(slot)
	local item_guid = inv_item:GetIESID()
	local reroll_item = session.GetInvItemByGuid(item_guid)
	if reroll_item == nil then
		reroll_item = session.GetEquipItemByGuid(item_guid)
	end

	local item_obj = GetIES(reroll_item:GetObject())
	local refreshScp = item_obj.RefreshScp
	if refreshScp ~= 'None' then
		refreshScp = _G[refreshScp]
		refreshScp(item_obj)
	end

	REROLL_ITEM_MAKE_SELECT_LIST(frame, item_obj, reroll_index, reroll_str)

	REROLL_ITEM_MAKE_MATERIAL_LIST(frame, item_obj, reroll_str)
end

function REROLL_ITEM_SELECT_EXEC(parent, ctrl)	
	local frame = parent:GetTopParentFrame()
	local slot = GET_CHILD_RECURSIVELY(frame, 'slot')
	local inv_item = GET_SLOT_ITEM(slot)
	if inv_item == nil then return end

	local check_no_msgbox = GET_CHILD_RECURSIVELY(frame, 'check_no_reset_item')
	if check_no_msgbox:IsChecked() ~= 1 then
		local clmsg = ScpArgMsg('SelectRerollOption')
		local msgbox = ui.MsgBox_NonNested(clmsg, frame:GetName(), '_REROLL_ITEM_SELECT_EXEC', '_REROLL_ITEM_CANCEL')
		SET_MODAL_MSGBOX(msgbox)
	else
		_REROLL_ITEM_SELECT_EXEC()
	end
end

function _REROLL_ITEM_SELECT_EXEC()
	local frame = ui.GetFrame('reroll_item')
	if frame:IsVisible() == 0 then return end

	local slot = GET_CHILD_RECURSIVELY(frame, 'slot')
	local inv_item = GET_SLOT_ITEM(slot)
	if inv_item == nil then return end

	local index = frame:GetUserValue('CURRENT_INDEX')
	if index == nil or index == 'None' then
		ui.SysMsg(ClMsg('CannotCloseRandomReset'))
		return
	end

	index = tostring(tonumber(index) - 1)	

	pc.ReqExecuteTx_Item('SELECT_REROLL_ITEM', inv_item:GetIESID(), index)
end

function SUCCESS_REROLL_OPTION_SELECT(frame, msg, arg_str, arg_num)
	local RESET_SUCCESS_EFFECT_NAME = frame:GetUserConfig('RESET_SUCCESS_EFFECT')
	local EFFECT_SCALE = tonumber(frame:GetUserConfig('EFFECT_SCALE'))
	local EFFECT_DURATION = tonumber(frame:GetUserConfig('EFFECT_DURATION'))
	local pic_bg = GET_CHILD_RECURSIVELY(frame, 'pic_bg')
	if pic_bg == nil then return end

	pic_bg:PlayUIEffect(RESET_SUCCESS_EFFECT_NAME, EFFECT_SCALE, 'SUCCESS_REROLL_SELECT')

	local send_select = GET_CHILD_RECURSIVELY(frame, 'send_select')
	send_select:ShowWindow(0)

	ui.SetHoldUI(true)

	ReserveScript('_SUCCESS_REROLL_OPTION_SELECT()', EFFECT_DURATION)
end

function _SUCCESS_REROLL_OPTION_SELECT()
	ui.SetHoldUI(false)

	local frame = ui.GetFrame('reroll_item')
	if frame:IsVisible() == 0 then return end

	local do_reroll = GET_CHILD_RECURSIVELY(frame, 'do_reroll')
	do_reroll:ShowWindow(1)

	local slot = GET_CHILD_RECURSIVELY(frame, 'slot')
	local inv_item = GET_SLOT_ITEM(slot)
	if inv_item == nil then return end

	local RESET_SUCCESS_EFFECT_NAME = frame:GetUserConfig('RESET_SUCCESS_EFFECT')
	local EFFECT_SCALE = tonumber(frame:GetUserConfig('EFFECT_SCALE'))
	local pic_bg = GET_CHILD_RECURSIVELY(frame, 'pic_bg')
	if pic_bg == nil then return end

	pic_bg:StopUIEffect('SUCCESS_REROLL_SELECT', true, 0.5)

	local item_guid = inv_item:GetIESID()
	local reroll_item = session.GetInvItemByGuid(item_guid)
	if reroll_item == nil then
		reroll_item = session.GetEquipItemByGuid(item_guid)
	end

	if reroll_item == nil then
		CLEAR_REROLL_ITEM_UI()
		return
	end

	local item_obj = GetIES(reroll_item:GetObject())
	local refreshScp = item_obj.RefreshScp
	if refreshScp ~= 'None' then
		refreshScp = _G[refreshScp]
		refreshScp(item_obj)
	end

	REROLL_ITEM_REG_TARGETITEM(frame, reroll_item:GetIESID())
end

function REMOVE_REROLL_TARGET_ITEM(frame)
	if ui.CheckHoldedUI() == true then
		return
	end
	
	frame = frame:GetTopParentFrame()
	local slot = GET_CHILD_RECURSIVELY(frame, 'slot')
	slot:ClearIcon()
	CLEAR_REROLL_ITEM_UI()
end

function REROLL_ITEM_INV_RBTN(item_obj, slot)
	local frame = ui.GetFrame('reroll_item')
	if frame == nil then return end

	local icon = slot:GetIcon()
	local iconInfo = icon:GetInfo()
	local inv_item = GET_PC_ITEM_BY_GUID(iconInfo:GetIESID())
	local item_obj = GetIES(inv_item:GetObject())
	
	local slot = GET_CHILD_RECURSIVELY(frame, 'slot')
	local slotInvItem = GET_SLOT_ITEM(slot)
	
	REROLL_ITEM_REG_TARGETITEM(frame, iconInfo:GetIESID())
end

function REROLL_ITEM_SELECT_OPTION(frame, parent, cur_index)
	local bg = GET_CHILD_RECURSIVELY(parent, 'bg')
	local option_frame = ui.GetFrame('reroll_item_option')
	local SELECTED_BTN_SKIN = parent:GetUserConfig('SELECTED_BTN_SKIN')
	local NOT_SELECTED_BTN_SKIN = parent:GetUserConfig('NOT_SELECTED_BTN_SKIN')
	
	local prev_index = frame:GetUserValue('CURRENT_INDEX')
	if prev_index ~= nil and prev_index ~= 'None' then
		local prev_ctrlset = GET_CHILD_RECURSIVELY(frame, 'PROPERTY_CSET_' .. prev_index)
		if prev_ctrlset ~= nil then
			local prev_bg = GET_CHILD_RECURSIVELY(prev_ctrlset, 'bg')
			prev_bg:SetSkinName(NOT_SELECTED_BTN_SKIN)
		end

		if tonumber(prev_index) == cur_index then
			frame:SetUserValue('CURRENT_INDEX', 'None')
			ui.CloseFrame('reroll_item_option')
		else
			frame:SetUserValue('CURRENT_INDEX', cur_index)
			bg:SetSkinName(SELECTED_BTN_SKIN)
			if option_frame:IsVisible() == 1 then
				REROLL_ITEM_OPTION_LIST(option_frame)
			end
		end
	else
		frame:SetUserValue('CURRENT_INDEX', cur_index)
		bg:SetSkinName(SELECTED_BTN_SKIN)
		if option_frame:IsVisible() == 1 then
			REROLL_ITEM_OPTION_LIST(option_frame)
		end
	end
end

function REROLL_ITEM_OPTION_LBTN_CLICK(parent, ctrl, arg_str, arg_num)
	local frame = parent:GetTopParentFrame()
	REROLL_ITEM_SELECT_OPTION(frame, parent, arg_num)
end