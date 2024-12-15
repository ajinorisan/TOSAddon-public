function DUCTILITY_ITEM_ON_INIT(addon, frame)
	addon:RegisterMsg('OPEN_DLG_DUCTILITY_ITEM', 'ON_OPEN_DLG_DUCTILITY_ITEM')
	addon:RegisterMsg('MSG_SUCCESS_DUCTILITY_OPTION', 'SUCCESS_DUCTILITY_OPTION')
	
end

function SUCCESS_DUCTILITY_OPTION(frame, msg, arg_str, arg_num)
	local RESET_SUCCESS_EFFECT_NAME = frame:GetUserConfig('RESET_SUCCESS_EFFECT')
	local EFFECT_SCALE = tonumber(frame:GetUserConfig('EFFECT_SCALE'))
	local EFFECT_DURATION = tonumber(frame:GetUserConfig('EFFECT_DURATION'))
	local pic_bg = GET_CHILD_RECURSIVELY(frame, 'pic_bg')
	if pic_bg == nil then return end

	pic_bg:PlayUIEffect(RESET_SUCCESS_EFFECT_NAME, EFFECT_SCALE, 'SUCCESS_DUCTILITY_OPTION')

	local do_ductility = GET_CHILD_RECURSIVELY(frame, 'do_ductility')
	do_ductility:ShowWindow(0)

	ui.SetHoldUI(true)

	local reserve_scp = string.format('_SUCCESS_DUCTILITY_OPTION(\'%s\', %d)', arg_str, arg_num)
	ReserveScript(reserve_scp, EFFECT_DURATION)
end

function _SUCCESS_DUCTILITY_OPTION(item_id,ductility_cnt)
	ui.SetHoldUI(false)

	local frame = ui.GetFrame('ductility_item')
	if frame:IsVisible() == 0 then return end

	-- CHECK DUCTILITY HISTORY --
	local curr_index = frame:GetUserValue('CURRENT_INDEX')
	if curr_index~="None" then
		frame:SetUserValue('SAVED_DUCTILITY_INDEX',curr_index)
	end

	local pic_bg = GET_CHILD_RECURSIVELY(frame, 'pic_bg')
	if pic_bg == nil then return end

	pic_bg:StopUIEffect('SUCCESS_DUCTILITY_OPTION', true, 0.5)

	local duc_item = session.GetInvItemByGuid(item_id)
	if duc_item == nil then
		duc_item = session.GetEquipItemByGuid(item_id)
	end
	local item_obj = GetIES(duc_item:GetObject())
	local refreshScp = item_obj.RefreshScp
	if refreshScp ~= 'None' then
		refreshScp = _G[refreshScp]
		refreshScp(item_obj)
	end
	CLEAR_DUCTILITY_ITEM_UI()
	DUCTILITY_ITEM_REG_TARGETITEM(frame, item_id)
end
function ON_OPEN_DLG_DUCTILITY_ITEM(frame)
	frame:ShowWindow(1)
end

function DUCTILITY_ITEM_OPEN(frame)
	CLEAR_DUCTILITY_ITEM_UI()
	ui.OpenFrame('inventory')
	INVENTORY_SET_CUSTOM_RBTNDOWN('DUCTILITY_ITEM_INV_RBTN')

	frame:SetUserValue('SAVED_DUCTILITY_INDEX','None')
end

function DUCTILITY_ITEM_CLOSE(frame)
	if ui.CheckHoldedUI() == true then
		return
	end

	INVENTORY_SET_CUSTOM_RBTNDOWN('None')
	control.DialogOk()
	frame:ShowWindow(0)
	ui.CloseFrame('inventory')
end

function DUCTILITY_ITEM_INV_RBTN(item_obj, slot)
    local frame = ui.GetFrame('ductility_item')
	if frame == nil then return end

	local icon = slot:GetIcon()
	local iconInfo = icon:GetInfo()
	local inv_item = GET_PC_ITEM_BY_GUID(iconInfo:GetIESID())
	local item_obj = GetIES(inv_item:GetObject())
    DUCTILITY_ITEM_REG_TARGETITEM(frame, iconInfo:GetIESID())
end

function DUCTILITY_ITEM_TARGET_DROP(frame, icon, argStr, argNum)
	if ui.CheckHoldedUI() == true then return end
	local liftIcon = ui.GetLiftIcon()
	local FromFrame = liftIcon:GetTopParentFrame()
	local toFrame = frame:GetTopParentFrame()
	if FromFrame:GetName() == 'inventory' then
		local iconInfo = liftIcon:GetInfo()
		DUCTILITY_ITEM_REG_TARGETITEM(frame, iconInfo:GetIESID())
	end
end

function DUCTILITY_ITEM_REG_TARGETITEM(frame, itemID, ductilityArg)
	if ui.CheckHoldedUI() == true then return end
	local inv_item = session.GetInvItemByGuid(itemID)
	if inv_item == nil then return end

	local item_obj = GetIES(inv_item:GetObject())
	local item_cls = GetClassByType('Item', inv_item.type)
	if item_obj == nil or item_cls == nil then return end

	local pc = GetMyPCObject()
	if pc == nil then return end
	
	local ret,msg = shared_item_ductility.is_able_to_ductility_without_index(item_obj)

    if ret == false then
		if msg ~= nil then
			ui.SysMsg(ClMsg(msg));
        end
        return
    end

	local invframe = ui.GetFrame('inventory')
	if true == inv_item.isLockState or true == IS_TEMP_LOCK(invframe, inv_item) then
		ui.SysMsg(ClMsg('MaterialItemIsLock'))
		return
	end

	CLEAR_DUCTILITY_ITEM_UI()

	local slot = GET_CHILD_RECURSIVELY(frame, 'slot')
	SET_SLOT_ITEM(slot, inv_item)

	local text_putonitem = GET_CHILD_RECURSIVELY(frame, 'text_putonitem')
	text_putonitem:ShowWindow(0)

	local slot_bg_image = GET_CHILD_RECURSIVELY(frame, 'slot_bg_image')
	slot_bg_image:ShowWindow(0)

	local text_itemname = GET_CHILD_RECURSIVELY(frame, 'text_itemname')
	text_itemname:SetText(item_obj.Name)

	DUCTILITY_ITEM_MAKE_SELECT_LIST(frame,item_obj, ductilityArg)
	DUCTILITY_ITEM_MAKE_MATERIAL_LIST(frame, item_obj, ductilityArg)
end

function DUCTILITY_ITEM_MAKE_SELECT_LIST(frame,item_obj,ductilityArg)
	if ductilityArg == nil then 
		ductilityArg = TryGetProp(item_obj, 'Ductility_Count', 'None') 
	end

	local saved_index = frame:GetUserIValue('SAVED_DUCTILITY_INDEX')

	frame:SetUserValue('CURRENT_INDEX', 'None')

	local y_adj = 21
	local currentGbox_inner = GET_CHILD_RECURSIVELY(frame, 'currentGbox_inner')
	currentGbox_inner:RemoveAllChild()		

	local function _MAKE_REROLL_OPTION_CTRL(gBox, item_obj, group, name, value, ctrl_count, ind, adj, list_flag)
		value = tonumber(value)
		local clmsg = GET_CLMSG_BY_OPTION_GROUP(group)
		local name_str = string.format('%s %s', ClMsg(clmsg), ScpArgMsg(name))		
		local info_str = ABILITY_DESC_NO_PLUS(name_str, value, 0)	
		local option_ctrlset = gBox:CreateOrGetControlSet('eachproperty_in_ductility_item', 'PROPERTY_CSET_' .. ctrl_count, 0, 0)
		option_ctrlset = AUTO_CAST(option_ctrlset)
		local pos_y = option_ctrlset:GetUserConfig('POS_Y')
		option_ctrlset:Move(0, (ctrl_count - 1) * pos_y + adj)
		local property_name = GET_CHILD_RECURSIVELY(option_ctrlset, 'property_name', 'ui::CRichText')
		property_name:SetEventScriptArgNumber(ui.LBUTTONUP, ind)
		property_name:SetText(info_str)
		return option_ctrlset
	end

	for i = 1, MAX_RANDOM_OPTION_COUNT do
		local group_name = 'RandomOptionGroup_' .. i
		local prop_name = 'RandomOption_' .. i
		local prop_value = 'RandomOptionValue_' .. i
		if item_obj[prop_value] ~= 0 and item_obj[prop_name] ~= 'None' then				
			local ctrlset =  _MAKE_REROLL_OPTION_CTRL(currentGbox_inner, item_obj, item_obj[group_name], item_obj[prop_name], item_obj[prop_value], i, i, y_adj, 1)
			if saved_index==i then
				DUCTILITY_ITEM_SELECT_OPTION(frame,ctrlset,saved_index)
			end
		end
	end
end

function DUCTILITY_ITEM_OPTION_LBTN_CLICK(parent,ctrl, arg_str, arg_num)
	local frame = parent:GetTopParentFrame()
	DUCTILITY_ITEM_SELECT_OPTION(frame,parent,arg_num)
end

local function DUCTILITY_ITEM_OPTION_REWRITE(frame,item_obj,index,addval,isPreindex)
	local group_name = 'RandomOptionGroup_' .. index
	local prop_name = 'RandomOption_' .. index
	local prop_value = 'RandomOptionValue_' .. index

	if item_obj[prop_value] ~= 0 and item_obj[prop_name] ~= 'None' then
		local clmsg = GET_CLMSG_BY_OPTION_GROUP(item_obj[group_name])
		local name_str = string.format('%s %s', ClMsg(clmsg), ScpArgMsg(item_obj[prop_name]))		
		local origin_text = ABILITY_DESC_NO_PLUS(name_str, item_obj[prop_value], 0)
		if isPreindex == 0 then
			local val = item_obj[prop_value]+addval
			local add_str = string.format('%s %s',ScpArgMsg("PropRight"), ScpArgMsg("PropUp"))
			local new_text = origin_text..add_str..tostring(val)..ClMsg("ExpectedValAfterDuctility")
			return new_text
		else
			return origin_text
		end
	else
		ui.SysMsg(ClMsg("Auto_eLeo_BalSaeng"))
		return 
	end
end

function DUCTILITY_ITEM_SELECT_OPTION(frame, parent, cur_index)
	local bg 					= GET_CHILD_RECURSIVELY(parent, 'bg')
	local SELECTED_BTN_SKIN 	= parent:GetUserConfig('SELECTED_BTN_SKIN')
	local NOT_SELECTED_BTN_SKIN = parent:GetUserConfig('NOT_SELECTED_BTN_SKIN')
	
	local slot  				= GET_CHILD_RECURSIVELY(frame, 'slot')
	local icon					= slot:GetIcon()
	local icon_info 			= icon:GetInfo()
	local invitem 				= GET_ITEM_BY_GUID(icon_info:GetIESID());
	local item_obj 				= GetIES(invitem:GetObject());
	
	local addval = shared_item_ductility.get_add_point(item_obj, cur_index)

	local ret, msg = shared_item_ductility.is_able_to_ductility_option(item_obj, cur_index)
	if ret==false then 
		ui.SysMsg(ClMsg(msg))
		return
	end
	
	local currentGbox_inner = GET_CHILD_RECURSIVELY(frame, 'currentGbox_inner')
	local ctrlset 	= GET_CHILD_RECURSIVELY(currentGbox_inner,"PROPERTY_CSET_"..tostring(cur_index))
	local prop_name = GET_CHILD_RECURSIVELY(ctrlset, 'property_name', 'ui::CRichText')
	
	local prev_index = frame:GetUserValue('CURRENT_INDEX')
	
	if prev_index ~= nil and prev_index ~= 'None' then
		local prev_ctrlset = GET_CHILD_RECURSIVELY(frame, 'PROPERTY_CSET_' .. prev_index)
		local prev_prop_name = GET_CHILD_RECURSIVELY(prev_ctrlset, 'property_name', 'ui::CRichText')
	
		if prev_ctrlset ~= nil then
			local prev_bg = GET_CHILD_RECURSIVELY(prev_ctrlset, 'bg')
			prev_bg:SetSkinName(NOT_SELECTED_BTN_SKIN)
			prev_prop_name:SetText(DUCTILITY_ITEM_OPTION_REWRITE(frame,item_obj,prev_index,addval,1))
		end
		if tonumber(prev_index) == cur_index then
			frame:SetUserValue('CURRENT_INDEX', 'None')
			
		else
			frame:SetUserValue('CURRENT_INDEX', cur_index)
			bg:SetSkinName(SELECTED_BTN_SKIN)
			prop_name:SetText(DUCTILITY_ITEM_OPTION_REWRITE(frame,item_obj,cur_index,addval,0))
		end
	else
		frame:SetUserValue('CURRENT_INDEX', cur_index)
		bg:SetSkinName(SELECTED_BTN_SKIN)
		prop_name:SetText(DUCTILITY_ITEM_OPTION_REWRITE(frame,item_obj,cur_index,addval,0))
	end
end

function DUCTILITY_ITEM_MAKE_MATERIAL_LIST(frame, item_obj, ductilityArg)
	local pc = GetMyPCObject()
	if pc == nil then return end

	local group_name = TryGetProp(item_obj, 'GroupName', 'None')
	local ductility_mat_list, is_valid

	ductility_mat_list, is_valid = shared_item_ductility.get_ductility_cost_table(item_obj)	

	if ductility_mat_list == nil or is_valid == false then
		return
	end

	local text_material = GET_CHILD_RECURSIVELY(frame, 'text_material')
	local materialGbox = GET_CHILD_RECURSIVELY(frame, 'materialGbox')
	
	if ductilityArg == nil then
		ductilityArg = TryGetProp(item_obj, 'Ductility_Count', 'None')
	end

	local isAbleExchange = 1

	local mat_item_slot_count = 0
	for mat_clsname, mat_count in pairs(ductility_mat_list) do
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
					local cls = GetClass('Item', mat_clsname .. '_NoTrade')
					inv_mat_count = GetInvItemCount(pc, mat_clsname)
					if cls ~=nil then 
						inv_mat_count =  inv_mat_count + GetInvItemCount(pc, cls.ClassName)
					end
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
	frame:SetUserValue('MAX_EXCHANGEITEM_CNT', mat_item_slot_count)
	frame:SetUserValue('isAbleExchange', isAbleExchange)
end

function REMOVE_DUCTILITY_TARGET_ITEM(frame)
	if ui.CheckHoldedUI() == true then
		return
	end
	
	frame = frame:GetTopParentFrame()
	local slot = GET_CHILD_RECURSIVELY(frame, 'slot')
	slot:ClearIcon()
	CLEAR_DUCTILITY_ITEM_UI()
end

function CLEAR_DUCTILITY_ITEM_UI()
	if ui.CheckHoldedUI() == true then return end

	local frame = ui.GetFrame('ductility_item')
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
	
	local materialGbox = GET_CHILD_RECURSIVELY(frame, 'materialGbox')
	materialGbox:RemoveAllChild()
	local send_select = GET_CHILD_RECURSIVELY(frame, 'send_select')
	send_select:ShowWindow(0)
	local do_ductility = GET_CHILD_RECURSIVELY(frame, 'do_ductility')
	do_ductility:ShowWindow(1)
	
end

function DUCTILITY_ITEM_EXEC(parent,ctrl)
	local frame = parent:GetTopParentFrame()
	_DUCTILITY_ITEM_EXEC()
end

function _DUCTILITY_ITEM_EXEC()
	local frame = ui.GetFrame('ductility_item')
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
		ui.SysMsg(ClMsg('MaterialItemIsLockEither'))
		return
	end

	local index = frame:GetUserValue('CURRENT_INDEX')
	if index == nil or index == 'None' then
		ui.SysMsg(ClMsg('CannotCloseRandomReset'))
		return
	end

	pc.ReqExecuteTx_Item('ITEM_DUCTILITY', inv_item:GetIESID(), tonumber(index))
end


function _REROLL_ITEM_CANCEL()
	local frame = ui.GetFrame('ductility_item')
end