function GODDESS_EQUIP_MANAGER_ON_INIT(addon, frame)
	addon:RegisterMsg('OPEN_DLG_GODDESS_EQUIP_MANAGER', 'ON_OPEN_DLG_GODDESS_EQUIP_MANAGER')
	addon:RegisterMsg('EQUIP_ITEM_LIST_GET', 'GODDESS_EQUIP_MANAGER_ON_MSG')

	addon:RegisterMsg('MSG_SUCCESS_GODDESS_REINFORCE_EXEC', 'ON_SUCCESS_REFORGE_REINFORCE_EXEC')
	addon:RegisterMsg('MSG_FAILED_GODDESS_REINFORCE_EXEC', 'ON_FAILED_REFORGE_REINFORCE_EXEC')

	addon:RegisterMsg('MSG_SUCCESS_GODDESS_ENCHANT_EXEC', 'ON_SUCCESS_REFORGE_ENCHANT_EXEC')
	addon:RegisterMsg('MSG_FAILED_GODDESS_ENCHANT_EXEC', 'ON_FAILED_REFORGE_ENCHANT_EXEC')

	addon:RegisterMsg('MSG_SUCCESS_GODDESS_TRANSCEND_EXEC', 'ON_SUCCESS_REFORGE_TRANSCEND_EXEC')
	addon:RegisterMsg('MSG_FAILED_GODDESS_TRANSCEND_EXEC', 'ON_FAILED_REFORGE_TRANSCEND_EXEC')

	addon:RegisterMsg('MSG_SUCCESS_GODDESS_EVOLUTION_EXEC', 'ON_SUCCESS_REFORGE_EVOLUTION_EXEC')

	addon:RegisterMsg('MSG_SUCCESS_ICOR_PRESET_CHANGE_NAME', 'ON_SUCCESS_RANDOMOPTION_CHANGE_NAME')
	addon:RegisterMsg('MSG_SUCCESS_ICOR_PRESET_ENGRAVE', 'ON_SUCCESS_RANDOMOPTION_ENGRAVE')
	addon:RegisterMsg('MSG_FAILED_ICOR_PRESET_ENGRAVE', 'ON_FAILED_RANDOMOPTION_ENGRAVE')
	addon:RegisterMsg('MSG_SUCCESS_ICOR_PRESET_ENGRAVE_APPLY', 'ON_SUCCESS_RANDOMOPTION_APPLY')
	addon:RegisterMsg('MSG_SUCCESS_ICOR_PRESET_ENGRAVE_ICOR', 'ON_SUCCESS_RANDOMOPTION_ENGRAVE_ICOR')

	addon:RegisterMsg('MSG_GODDESS_SOCKET_UPDATE', 'GODDESS_MGR_SOCKET_UPDATE')

	addon:RegisterMsg('MSG_SUCCESS_GODDESS_MAKE_EFFECT', 'PLAY_GODDESS_MAKE_SUCCESS_EFFECT')
	addon:RegisterMsg('MSG_SUCCESS_GODDESS_MAKE_EXEC', 'ON_SUCCESS_GODDESS_MAKE_EXEC')
	addon:RegisterMsg('MSG_FAILED_GODDESS_MAKE_EXEC', 'ON_FAILED_GODDESS_MAKE_EXEC')
	addon:RegisterMsg('MSG_SUCCESS_GODDESS_INHERIT_EXEC', 'ON_SUCCESS_GODDESS_INHERIT_EXEC')
	addon:RegisterMsg('MSG_SUCCESS_GODDESS_CONVERT_EXEC', 'ON_SUCCESS_GODDESS_CONVERT_EXEC')

	addon:RegisterMsg('ON_UI_TUTORIAL_NEXT_STEP', 'GODDESS_EQUIP_UI_TUTORIAL_CHECK')
end

function TOGGLE_GODDESS_EQUIP_MANAGER()
	local frame = ui.GetFrame('goddess_equip_manager')
	if frame:IsVisible() == 1 then
		frame:ShowWindow(0)
	else
		help.RequestAddHelp('TUTO_GODDESSEQUIP_1')
		frame:ShowWindow(1)
	end
end

function ON_OPEN_DLG_GODDESS_EQUIP_MANAGER(frame, msg, arg_str, arg_num)
	frame:ShowWindow(1)
end

local managed_slot_list = {
	{
		SlotName = 'RH',
		SkinName = 'rh',
		ClMsg = 'RH',
	},
	{
		SlotName = 'LH',
		SkinName = 'lh',
		ClMsg = 'LH',
	},	
	{
		SlotName = 'SHIRT',
		SkinName = 'shirt',
		ClMsg = 'Shirt',
	},
	{
		SlotName = 'PANTS',
		SkinName = 'pants',
		ClMsg = 'Pants',
	},
	{
		SlotName = 'GLOVES',
		SkinName = 'gloves',
		ClMsg = 'Gloves',
	},
	{
		SlotName = 'BOOTS',
		SkinName = 'boots',
		ClMsg = 'Boots',
	},
	{
		SlotName = 'RH_SUB',
		SkinName = 'rh',
		ClMsg = 'RH_SUB',
	},
	{
		SlotName = 'LH_SUB',
		SkinName = 'lh',
		ClMsg = 'LH_SUB',
	},
}

local managed_armor_slot_list = {	
	{
		SlotName = 'SHIRT',
		SkinName = 'shirt',
		ClMsg = 'Shirt',
	},
	{
		SlotName = 'PANTS',
		SkinName = 'pants',
		ClMsg = 'Pants',
	},
	{
		SlotName = 'GLOVES',
		SkinName = 'gloves',
		ClMsg = 'Gloves',
	},
	{
		SlotName = 'BOOTS',
		SkinName = 'boots',
		ClMsg = 'Boots',
	},	
}

local managed_weapon_slot_list = {	
	{
		SlotName = 'RH',
		SkinName = 'rh',
		ClMsg = 'RH',
	},
	{
		SlotName = 'LH',
		SkinName = 'lh',
		ClMsg = 'LH',
	},		
	{
		SlotName = 'RH_SUB',
		SkinName = 'rh',
		ClMsg = 'RH_SUB',
	},
	{
		SlotName = 'LH_SUB',
		SkinName = 'lh',
		ClMsg = 'LH_SUB',
	},
}

local function _GET_EFFECT_UI_MARGIN()
	local frame = ui.GetFrame('goddess_equip_manager')
	local effect_frame = ui.GetFrame('result_effect_ui')
	local left_margin = math.floor((frame:GetWidth() - effect_frame:GetWidth()) * 0.5)
	local top_margin = math.floor((frame:GetHeight() - effect_frame:GetHeight()) * 0.5)
	local margin = frame:GetMargin()
	left_margin = left_margin + margin.left
	top_margin = top_margin + margin.top

	return left_margin, top_margin
end

function GODDESS_EQUIP_MANAGER_OPEN(frame)
	-- if TUTORIAL_CLEAR_CHECK(GetMyPCObject()) == false then
	-- 	ui.SysMsg(ClMsg('CanUseAfterTutorialClear'))
	-- 	frame:ShowWindow(0)
	-- 	return
	-- end
	
	ui.CloseFrame('rareoption')
	ui.CloseFrame('item_cabinet')
	for i = 1, #revertrandomitemlist do
		local revert_name = revertrandomitemlist[i]
		local revert_frame = ui.GetFrame(revert_name)
		if revert_frame ~= nil and revert_frame:IsVisible() == 1 then
			ui.CloseFrame(revert_name)
		end
	end

	local main_tab = GET_CHILD_RECURSIVELY(frame, 'main_tab')
	main_tab:SelectTab(0)
	CLEAR_GODDESS_EQUIP_MANAGER(frame)
	TOGGLE_GODDESS_EQUIP_MANAGER_TAB(frame, 0)
	ui.OpenFrame('inventory')
end

function GODDESS_EQUIP_MANAGER_CLOSE(frame)
	if ui.CheckHoldedUI() == true then
		return
	end
	
	INVENTORY_SET_CUSTOM_RBTNDOWN('None')
	frame:ShowWindow(0)
	control.DialogOk()
	TUTORIAL_TEXT_CLOSE()
end

function GODDESS_REINFORCE_TUTORIAL_OPEN(frame, open_flag)
	local prop_name = "UITUTO_GODDESSEQUIP1"
	frame:SetUserValue('TUTO_PROP', prop_name)
	local tuto_step = GetUITutoProg(prop_name)
	if tuto_step >= 100 then return end

	local tuto_cls = GetClass('UITutorial', prop_name .. '_' .. tuto_step + 1)
	if tuto_cls == nil then
		tuto_cls = GetClass('UITutorial', prop_name .. '_100')
		if tuto_cls == nil then return end
	end

	local ctrl_name = TryGetProp(tuto_cls, 'ControlName', 'None')
	local title = dic.getTranslatedStr(TryGetProp(tuto_cls, 'Title', 'None'))
	local text = dic.getTranslatedStr(TryGetProp(tuto_cls, 'Note', 'None'))
	local ctrl = GET_CHILD_RECURSIVELY(frame, ctrl_name)
	if ctrl == nil then return end

	if open_flag == true then
		
	end

	TUTORIAL_TEXT_OPEN(ctrl, title, text, prop_name)
end

function GODDESS_ENCHANT_TUTORIAL_OPEN(frame, open_flag)
	local prop_name = "UITUTO_GODDESSEQUIP2"
	frame:SetUserValue('TUTO_PROP', prop_name)
	local tuto_step = GetUITutoProg(prop_name)
	if tuto_step >= 100 then return end

	local tuto_cls = GetClass('UITutorial', prop_name .. '_' .. tuto_step + 1)
	if tuto_cls == nil then
		tuto_cls = GetClass('UITutorial', prop_name .. '_100')
		if tuto_cls == nil then return end
	end

	local ctrl_name = TryGetProp(tuto_cls, 'ControlName', 'None')
	local title = dic.getTranslatedStr(TryGetProp(tuto_cls, 'Title', 'None'))
	local text = dic.getTranslatedStr(TryGetProp(tuto_cls, 'Note', 'None'))
	local ctrl = GET_CHILD_RECURSIVELY(frame, ctrl_name)
	if ctrl == nil then return end

	if open_flag == true then
		
	end

	TUTORIAL_TEXT_OPEN(ctrl, title, text, prop_name)
end

function GODDESS_EQUIP_UI_TUTORIAL_CHECK(frame, msg, arg_str, arg_num)
	if frame == nil or frame:IsVisible() == 0 then return end

	if session.shop.GetEventUserType() == 0 then return end

	if arg_num == 100 then
		if arg_str == 'UITUTO_GODDESSEQUIP1' then
			local tuto_icon_1 = GET_CHILD_RECURSIVELY(frame, "UITUTO_ICON_1")
			tuto_icon_1:ShowWindow(0)
		elseif arg_str == 'UITUTO_GODDESSEQUIP2' then
			local tuto_icon_2 = GET_CHILD_RECURSIVELY(frame, "UITUTO_ICON_2")
			tuto_icon_2:ShowWindow(0)
		end

		TUTORIAL_TEXT_CLOSE(frame)
		return
	end

	local open_flag = false
	if msg == nil then
		open_flag = true
	end

	local main_tab = GET_CHILD_RECURSIVELY(frame, "main_tab")
	local main_index = main_tab:GetSelectItemIndex()
	if main_index == 0 then
		local reforge_tab = GET_CHILD_RECURSIVELY(frame, "reforge_tab")
		local reforge_index = reforge_tab:GetSelectItemIndex()
		if reforge_index == 0 then
			GODDESS_REINFORCE_TUTORIAL_OPEN(frame, open_flag)
		elseif reforge_index == 1 then
			GODDESS_ENCHANT_TUTORIAL_OPEN(frame, open_flag)
		else
			TUTORIAL_TEXT_CLOSE(frame)
		end
	else
		TUTORIAL_TEXT_CLOSE(frame)
	end
end

function CLEAR_GODDESS_EQUIP_MANAGER(frame)
	GODDESS_MGR_REFORGE_CLEAR(frame)
	GODDESS_MGR_RANDOMOPTION_CLEAR(frame)
	GODDESS_MGR_SOCKET_CLEAR(frame)
	GODDESS_MGR_MAKE_CLEAR(frame)
	GODDESS_MGR_INHERIT_CLEAR(frame)
	GODDESS_MGR_CONVERT_CLEAR(frame)
end

function GODDESS_MGR_TAB_CHANGE(parent, tab)
	local frame = parent:GetTopParentFrame()
	CLEAR_GODDESS_EQUIP_MANAGER(frame)

	local index = tab:GetSelectItemIndex()	
	TOGGLE_GODDESS_EQUIP_MANAGER_TAB(frame, index)
end

function TOGGLE_GODDESS_EQUIP_MANAGER_TAB(frame, index)
	if index == 0 then
		GODDESS_MGR_REFORGE_OPEN(frame)
	elseif index == 1 then
		GODDESS_MGR_RANDOMOPTION_OPEN(frame)
	elseif index == 2 then
		GODDESS_MGR_SOCKET_OPEN(frame)
	elseif index == 3 then
		GODDESS_MGR_MAKE_OPEN(frame)
	elseif index == 4 then
		GODDESS_MGR_INHERIT_OPEN(frame)
	elseif index == 5 then
		GODDESS_MGR_CONVERT_OPEN(frame)
	end

	GODDESS_EQUIP_UI_TUTORIAL_CHECK(frame)
end

function GODDESS_EQUIP_MANAGER_ON_MSG(frame, msg, arg_str, arg_num)
	local main_tab = GET_CHILD_RECURSIVELY(frame, 'main_tab')
	local main_index = main_tab:GetSelectItemIndex()
	if msg == 'EQUIP_ITEM_LIST_GET' then
		if main_index == 1 then
			GODDESS_MGR_RANDOMOPTION_CLEAR(frame)
		end
	end
end

-- 재련
function GODDESS_MGR_REFORGE_CLEAR(frame)
	local slot = GET_CHILD_RECURSIVELY(frame, 'ref_slot')
	slot:ClearIcon()
	slot:SetUserValue('ITEM_GUID', 'None')

	local slot_pic = GET_CHILD_RECURSIVELY(frame, 'ref_slot_bg_image')
	slot_pic:ShowWindow(1)

	local ref_item_name = GET_CHILD_RECURSIVELY(frame, 'ref_item_name')
	ref_item_name:ShowWindow(0)

	local ref_item_text = GET_CHILD_RECURSIVELY(frame, 'ref_item_text')
	ref_item_text:ShowWindow(1)

	local reforge_tab = GET_CHILD_RECURSIVELY(frame, 'reforge_tab')
	reforge_tab:SelectTab(0)

	local ref_item_reinf_text = GET_CHILD_RECURSIVELY(frame, 'ref_item_reinf_text')
	ref_item_reinf_text:SetTextByKey('value', 0)

	local ref_item_trans_text = GET_CHILD_RECURSIVELY(frame, 'ref_item_trans_text')
	ref_item_trans_text:SetTextByKey('value', 0)

	local tuto_icon_1 = GET_CHILD_RECURSIVELY(frame, "UITUTO_ICON_1")
	local tuto_prop_1 = GetUITutoProg("UITUTO_GODDESSEQUIP1")
	if tuto_prop_1 == 100 then
		tuto_icon_1:ShowWindow(0)
	else
		tuto_icon_1:ShowWindow(1)
	end
	
	local tuto_icon_2 = GET_CHILD_RECURSIVELY(frame, "UITUTO_ICON_2")
	local tuto_prop_2 = GetUITutoProg("UITUTO_GODDESSEQUIP2")
	if tuto_prop_2 == 100 then
		tuto_icon_2:ShowWindow(0)
	else
		tuto_icon_2:ShowWindow(1)
	end

	GODDESS_MGR_REFORGE_TAB_CHANGE(frame, reforge_tab)
end

-- 재련 탭 아이템 등록
function GODDESS_MGR_REFORGE_INV_RBTN(item_obj, slot, guid)	
	local frame = ui.GetFrame('goddess_equip_manager')

	local inv_item = session.GetInvItemByGuid(guid)
	if inv_item ~= nil then
		local reforge_tab = GET_CHILD_RECURSIVELY(frame, 'reforge_tab')
		local index = reforge_tab:GetSelectItemIndex()				
		
		if index == 3 then
			local obj = GetIES(inv_item:GetObject())
			if IS_EVOLVED_ITEM(obj) == true then
				ui.SysMsg(ClMsg('EvolvedWeapon'))
				return
			end

			if IS_WEAPON_TYPE(TryGetProp(obj, "ClassType", "None")) == false then
				return
			end
		end

		local main_slot = GET_CHILD_RECURSIVELY(frame, 'ref_slot')
		local main_guid = main_slot:GetUserValue('ITEM_GUID')
		if index == 1 then			
			if main_guid ~= 'None' then
				GODDESS_MGR_REFORGE_ENCHANT_REG_MAT_ITEM(frame, inv_item, item_obj)
				return
			end
		end
		
		GODDESS_MGR_REFORGE_REG_ITEM(frame, inv_item, item_obj)
	end
end

function GODDESS_MGR_REFORGE_ITEM_DROP(parent, slot, arg_str, arg_num)
	local frame = parent:GetTopParentFrame()
	local main_tab = GET_CHILD_RECURSIVELY(frame, 'main_tab')
	local index = main_tab:GetSelectItemIndex()
	if index ~= 0 then return end

	local lift_icon = ui.GetLiftIcon()
	local from_frame = lift_icon:GetTopParentFrame()
    if from_frame:GetName() == 'inventory' then
        local icon_info = lift_icon:GetInfo()
        local guid = icon_info:GetIESID()
        local inv_item = session.GetInvItemByGuid(guid)
		if inv_item == nil then return end
		
		local item_obj = GetIES(inv_item:GetObject())
		if item_obj == nil then return end
        
		GODDESS_MGR_REFORGE_REG_ITEM(frame, inv_item, item_obj)
	end
end

-- 제련 가능 아이템 확인
function GODDESS_MGR_REFORGE_REG_ITEM(frame, inv_item, item_obj)
	if inv_item == nil or item_obj == nil then return end

	if TryGetProp(item_obj, 'ItemGrade', 0) < 6 then
		ui.SysMsg(ClMsg('GoddessGradeItemOnly'))
		return
	end

	local reforge_tab = GET_CHILD_RECURSIVELY(frame, 'reforge_tab')
	local index = reforge_tab:GetSelectItemIndex()
	
	if index == 0 then  -- 강화
		if IS_ABLE_TO_REINFORCE_GODDESS(item_obj) == false then		
			return
		end
	elseif index == 1 then  -- 인챈트
		local msg = item_goddess_transcend.is_able_to_enchant(item_obj)		
		if msg ~= 'YES' then
			ui.SysMsg(ClMsg(msg))
			return
		end
	elseif index == 2 then  -- 초월
		local msg = item_goddess_transcend.is_able_to_transcend(item_obj)
		if msg ~= 'YES' then
			ui.SysMsg(ClMsg(msg))
			return
		end
	elseif index == 3 then  -- 진화
		if item_goddess_growth.is_goddess_growth_item(item_obj) == true then
			ui.SysMsg(ClMsg('WebService_38'))
			return
		end
	end


	local slot = GET_CHILD_RECURSIVELY(frame, 'ref_slot')
	SET_SLOT_ITEM(slot, inv_item)
	slot:SetUserValue('ITEM_GUID', inv_item:GetIESID())
	slot:SetUserValue('ITEM_USE_LEVEL', TryGetProp(item_obj, 'UseLv', 1))

	local slot_pic = GET_CHILD_RECURSIVELY(frame, 'ref_slot_bg_image')
	slot_pic:ShowWindow(0)

	local ref_item_text = GET_CHILD_RECURSIVELY(frame, 'ref_item_text')
	ref_item_text:ShowWindow(0)

	local ref_item_name = GET_CHILD_RECURSIVELY(frame, 'ref_item_name')
	ref_item_name:SetTextByKey('name', dic.getTranslatedStr(TryGetProp(item_obj, 'Name', 'NONE')))
	ref_item_name:ShowWindow(1)

	local ref_item_reinf_text = GET_CHILD_RECURSIVELY(frame, 'ref_item_reinf_text')
	ref_item_reinf_text:SetTextByKey('value', TryGetProp(item_obj, 'Reinforce_2', 0))

	local ref_item_trans_text = GET_CHILD_RECURSIVELY(frame, 'ref_item_trans_text')
	ref_item_trans_text:SetTextByKey('value', TryGetProp(item_obj, 'Transcend', 0))

	
	if index == 0 then		
		GODDESS_MGR_REFORGE_REINFORCE_UPDATE(frame)
	elseif index == 1 then
		GODDESS_MGR_REFORGE_ENCHANT_UPDATE(frame)
	elseif index == 2 then
		GODDESS_MGR_REFORGE_TRANSCEND_UPDATE(frame)
	elseif index == 3 then		
		GODDESS_MGR_REFORGE_EVOLUTION_UPDATE(frame)
	end

	local tuto_prop = frame:GetUserValue('TUTO_PROP')
	if tuto_prop ~= 'None' then
		local tuto_value = GetUITutoProg(tuto_prop)
		if tuto_value == 0 then
			pc.ReqExecuteTx('SCR_UI_TUTORIAL_NEXT_STEP', tuto_prop)
		end
	end
end

function GODDESS_MGR_REFORGE_ITEM_REMOVE(parent, slot)
	local frame = parent:GetTopParentFrame()

	slot:ClearIcon()
	slot:SetUserValue('ITEM_GUID', 'None')
	slot:SetUserValue('ITEM_USE_LEVEL', 0)

	local slot_pic = GET_CHILD_RECURSIVELY(frame, 'ref_slot_bg_image')
	slot_pic:ShowWindow(1)

	local ref_item_name = GET_CHILD_RECURSIVELY(frame, 'ref_item_name')
	ref_item_name:ShowWindow(0)

	local ref_item_text = GET_CHILD_RECURSIVELY(frame, 'ref_item_text')
	ref_item_text:ShowWindow(1)

	local ref_item_reinf_text = GET_CHILD_RECURSIVELY(frame, 'ref_item_reinf_text')
	ref_item_reinf_text:SetTextByKey('value', 0)

	local ref_item_trans_text = GET_CHILD_RECURSIVELY(frame, 'ref_item_trans_text')
	ref_item_trans_text:SetTextByKey('value', 0)

	local reforge_tab = GET_CHILD_RECURSIVELY(frame, 'reforge_tab')
	local index = reforge_tab:GetSelectItemIndex()
	if index == 0 then
		GODDESS_MGR_REFORGE_REINFORCE_CLEAR(frame)
	elseif index == 1 then
		GODDESS_MGR_REFORGE_ENCHANT_CLEAR(frame)
	elseif index == 2 then
		GODDESS_MGR_REFORGE_TRANSCEND_CLEAR(frame)
	elseif index == 3 then
		GODDESS_MGR_REFORGE_EVOLUTION_CLEAR(frame)
	end
end

function GODDESS_MGR_REFORGE_OPEN(frame)
	GODDESS_MGR_REFORGE_CLEAR(frame)
	INVENTORY_SET_CUSTOM_RBTNDOWN('GODDESS_MGR_REFORGE_INV_RBTN')
end

function GODDESS_MGR_REFORGE_TAB_CHANGE(parent, tab)
	local frame = parent:GetTopParentFrame()
	local index = tab:GetSelectItemIndex()
	if index == 0 then
		GODDESS_MGR_REFORGE_REINFORCE_OPEN(frame)
	elseif index == 1 then
		GODDESS_MGR_REFORGE_ENCHANT_OPEN(frame)
	elseif index == 2 then
		GODDESS_MGR_REFORGE_TRANSCEND_OPEN(frame)
	elseif index == 3 then
		GODDESS_MGR_REFORGE_EVOLUTION_OPEN(frame)
	end

	GODDESS_EQUIP_UI_TUTORIAL_CHECK(frame)
end

-- 재련 - 강화
function GODDESS_REINFORCE_MAT_CHECK(frame)
	local all_selected = true
	local mat_bg = GET_CHILD_RECURSIVELY(frame, 'reinf_main_mat_bg')
	for i = 0, mat_bg:GetChildCount() - 1 do
		local ctrlset = GET_CHILD(mat_bg, 'GODDESS_REINF_MAT_' .. i)
		if ctrlset ~= nil and ctrlset:GetUserValue('MATERIAL_IS_SELECTED') ~= 'selected' then
			all_selected = false
			break
		end
	end

	if all_selected == true then
		local tuto_prop = frame:GetUserValue('TUTO_PROP')
		if tuto_prop == 'UITUTO_GODDESSEQUIP1' then
			local tuto_value = GetUITutoProg(tuto_prop)
			if tuto_value == 1 then
				pc.ReqExecuteTx('SCR_UI_TUTORIAL_NEXT_STEP', tuto_prop)
			end
		end
	end
end

function GODDESS_MGR_REFORGE_REINFORCE_REG_MAT(ctrlset, btn)		
	local item_name = ctrlset:GetUserValue('ITEM_NAME')
	
	local cur_count = 0
	if IS_ACCOUNT_COIN(item_name) == true then
		local mat_cls = GetClass('accountprop_inventory_list', item_name)
		if mat_cls == nil then return end

		local acc = GetMyAccountObj()
		cur_count = TryGetProp(acc, item_name, '0')
		if cur_count == 'None' then
			cur_count = '0'
		end
    else
		local inv_item = session.GetInvItemByName(item_name)
		if inv_item == nil then return end

		cur_count = tostring(inv_item.count)
	end

    local slot = GET_CHILD(ctrlset, 'slot')
    local need_count = slot:GetEventScriptArgString(ui.DROP)

    if math.is_larger_than(tostring(need_count), cur_count) == 1 then
        ui.SysMsg(ClMsg('NotEnoughRecipe'))
        return
    end

    local icon = slot:GetIcon()
    slot:SetEventScript(ui.RBUTTONUP, 'GODDESS_REINFORCE_MAT_CANCEL')

    --슬롯 컬러톤 및 폰트 밝게 변경.
    icon:SetColorTone('FFFFFFFF')
    ctrlset:SetUserValue('MATERIAL_IS_SELECTED', 'selected')

    local invframe = ui.GetFrame('inventory')
    btn:ShowWindow(0)
	
	local frame = ctrlset:GetTopParentFrame()
	GODDESS_REINFORCE_MAT_CHECK(frame)
end

function GODDESS_REINFORCE_MAT_ON_DROP(ctrlset, ctrl, arg_str, arg_num)		
	imcSound.PlaySoundEvent('inven_equip')

	local slot = tolua.cast(control, 'ui::CSlot')
	local need_count = tonumber(arg_str)
	
	local item_name = ctrlset:GetUserValue('ITEM_NAME')
	local inv_item = session.GetInvItemByName(item_name)
	
	local liftIcon = ui.GetLiftIcon()
	local iconInfo = liftIcon:GetInfo()

	if inv_item.isLockState == true then
		ui.SysMsg(ClMsg('MaterialItemIsLock'))
		return
	end

	if iconInfo.type == arg_num and iconInfo.count >= need_count  then
		local icon = slot:GetIcon()
		icon:SetColorTone('FFFFFFFF')
		ctrlset:SetUserValue('MATERIAL_IS_SELECTED', 'selected')
	end

	local invframe = ui.GetFrame('inventory')
	INVENTORY_UPDATE_ICONS(invframe)

	local frame = ctrlset:GetTopParentFrame()
	GODDESS_REINFORCE_MAT_CHECK(frame)
end

function GODDESS_REINFORCE_MAT_CANCEL(ctrlset, slot, arg_str, arg_num)
    if ctrlset ~= nil then
        ctrlset:SetUserValue('MATERIAL_IS_SELECTED', 'nonselected')

        local slot = GET_CHILD_RECURSIVELY(ctrlset, 'slot')
        if slot ~= nil then
            slot:SetEventScript(ui.DROP, 'GODDESS_REINFORCE_MAT_ON_DROP')
            slot:EnableDrag(0) 
            local icon = slot:GetIcon()
            icon:SetColorTone('33333333')
        end

        -- btn Reset
        local btn = GET_CHILD_RECURSIVELY(ctrlset, 'btn')
        if btn ~= nil then
            btn:ShowWindow(1)
        end
    end
    
    local invframe = ui.GetFrame('inventory')
    INVENTORY_UPDATE_ICONS(invframe)
end

local function _REFORGE_REINFORCE_ADD_MAT_CTRL(bg, item_name, count)
	local mat_cls = nil
	local _name = 'None'
	local _have = 0
	if IS_ACCOUNT_COIN(item_name) == true then
		mat_cls = GetClass('accountprop_inventory_list', item_name)
		if mat_cls == nil then return end
		
		_name = ClMsg(item_name)

		local acc = GetMyAccountObj()
		_have = TryGetProp(acc, item_name, '0')
		if _have == 'None' then
			_have = '0'
		end
	else
		mat_cls = GetClass('Item', item_name)
		if mat_cls == nil then return end

		_name = dic.getTranslatedStr(TryGetProp(mat_cls, 'Name', 'None'))
		local inv_item = session.GetInvItemByName(item_name)
		if inv_item == nil then
			_have = '0'
		else
			_have = tostring(inv_item.count)
		end
	end

	if _name == 'None' then return end

	local height = ui.GetControlSetAttribute('goddess_reinf_material', 'height')
	local index = bg:GetChildCount() - 1
	local ypos = height * index + 2
	local ctrlset = bg:CreateOrGetControlSet('goddess_reinf_material', 'GODDESS_REINF_MAT_' .. index, 5, ypos)

	ctrlset:SetUserValue('MATERIAL_IS_SELECTED', 'nonselected')

	local slot = GET_CHILD(ctrlset, 'slot')

	SET_SLOT_IMG(slot, TryGetProp(mat_cls, 'Icon', 'None'))

	slot:SetEventScript(ui.DROP, 'GODDESS_REINFORCE_MAT_ON_DROP')
	slot:SetEventScriptArgNumber(ui.DROP, TryGetProp(mat_cls, 'ClassID', 0))
	slot:SetEventScriptArgString(ui.DROP, tostring(count))
	slot:EnableDrag(0)
	slot:SetOverSound('button_cursor_over_2')
	slot:SetClickSound('button_click')

	local icon = slot:GetIcon()
	icon:SetColorTone('33333333')

	ctrlset:SetUserValue('ITEM_NAME', item_name)

	local name_text = GET_CHILD(ctrlset, 'item')
	name_text:SetTextByKey('name', _name)

	local need_count = GET_CHILD_RECURSIVELY(ctrlset, 'needcount')
	need_count:SetTextByKey('count', count)

	local inv_count = GET_CHILD_RECURSIVELY(ctrlset, 'invcount')
	inv_count:SetTextByKey('have', _have)
	inv_count:SetTextByKey('need', count)
	
	return ctrlset:GetHeight()
end

local function _REFORGE_REINFORCE_MAT_COUNT_UPDATE(frame)
	local mat_bg = GET_CHILD_RECURSIVELY(frame, 'reinf_main_mat_bg')
	for i = 0, mat_bg:GetChildCount() - 1 do
		local ctrlset = GET_CHILD(mat_bg, 'GODDESS_REINF_MAT_' .. i)
		if ctrlset ~= nil then
			local slot = GET_CHILD(ctrlset, 'slot')
			local mat_name = ctrlset:GetUserValue('ITEM_NAME')
			local cur_count = '0'
			if IS_ACCOUNT_COIN(mat_name) == true then
				local acc = GetMyAccountObj()
				cur_count = TryGetProp(acc, mat_name, '0')
				if cur_count == 'None' then
					cur_count = '0'
				end
			else
				local mat_item = session.GetInvItemByName(mat_name)
				if mat_item == nil then
					cur_count = '0'
				else
					cur_count = tostring(mat_item.count)
				end
			end

			local need_count = slot:GetEventScriptArgString(ui.DROP)
			local inv_count = GET_CHILD_RECURSIVELY(ctrlset, 'invcount')
			inv_count:SetTextByKey('have', cur_count)
			inv_count:SetTextByKey('need', need_count)
		end
	end
end

local function _REFORGE_REINFORCE_EXTRA_MAT_COUNT_UPDATE(frame)
	local slotset = GET_CHILD_RECURSIVELY(frame, 'reinf_extra_mat_list')
	for i = 0, slotset:GetSlotCount() - 1 do
		local slot = slotset:GetSlotByIndex(i)
		local cnt = slot:GetSelectCount()
		if cnt > 0 then
			local mat_guid = slot:GetUserValue('ITEM_GUID')
			local inv_item = session.GetInvItemByGuid(mat_guid)
			if inv_item ~= nil then
				local obj = GetIES(inv_item:GetObject())
				local icon = slot:GetIcon()
				local slotindex = slot:GetSlotIndex()
				icon:Set(obj.Icon, 'Item', inv_item.type, slotindex, inv_item:GetIESID(), inv_item.count)
				slot:SetMaxSelectCount(inv_item.count)
				SET_SLOT_ITEM_TEXT_USE_INVCOUNT(slot, inv_item, obj, inv_item.count)
			end
		end

		if cnt == 0 then
			slot:Select(0)
		end
	end
end

function GODDESS_MGR_REINFORCE_MAT_UPDATE(frame)
	local reinf_main_mat_bg = GET_CHILD_RECURSIVELY(frame, 'reinf_main_mat_bg')
	reinf_main_mat_bg:RemoveAllChild()

	local ref_slot = GET_CHILD_RECURSIVELY(frame, 'ref_slot')
	local guid = ref_slot:GetUserValue('ITEM_GUID')
	if guid ~= 'None' then
		local inv_item = session.GetInvItemByGuid(guid)
		if inv_item == nil then return end

		local item_obj = GetIES(inv_item:GetObject())
		local use_lv = TryGetProp(item_obj, 'UseLv', 1)
		local class_type = TryGetProp(item_obj, 'ClassType', 'None')
		local reinf_value = TryGetProp(item_obj, 'Reinforce_2', 0)
		local popoboost_item_prop = TryGetProp(item_obj, 'popoboost', 0)
		
		local dic = item_goddess_reinforce.get_material_list(use_lv, class_type, reinf_value + 1, popoboost_item_prop)
		if dic == nil then
			if item_goddess_growth.is_goddess_growth_item(item_obj) == true then
				local _max = false
				dic, _max = item_goddess_growth.get_material_list(item_obj, class_type, reinf_value + 1)				
				if dic == nil then					
					return
				end
			else
				return
			end
		end
		for mat_name, mat_count in pairs(dic) do
			_REFORGE_REINFORCE_ADD_MAT_CTRL(reinf_main_mat_bg, mat_name, mat_count)
		end
	end
end

function SCR_LBTNDOWN_GODDESS_REINFORCE_EXTRA_MAT(slotset, slot)
	if ui.CheckHoldedUI() == true then return end

	local frame = slotset:GetTopParentFrame()
	ui.EnableSlotMultiSelect(1)

	local ref_slot = GET_CHILD_RECURSIVELY(frame, 'ref_slot')
	local guid = ref_slot:GetUserValue('ITEM_GUID')
	if guid == 'None' then return end

	local use_lv = ref_slot:GetUserIValue('ITEM_USE_LEVEL')
	
	local normal_max = GET_MAX_SUB_REVISION_COUNT(use_lv)
	local premium_max = GET_MAX_PREMIUM_SUB_REVISION_COUNT(use_lv)
	local normal_cnt = 0
	local premium_cnt = 0
	for i = 0, slotset:GetSlotCount() - 1 do
		local _slot = slotset:GetSlotByIndex(i)
		local cnt = _slot:GetSelectCount()
		if cnt > 0 then
			local arg_str = _slot:GetUserValue('MAT_TYPE')
			if arg_str == 'normal' then
				normal_cnt = normal_cnt + cnt
				if normal_cnt > normal_max then
					local adjust_cnt = normal_cnt - normal_max
					cnt = cnt - adjust_cnt
					normal_cnt = normal_cnt - adjust_cnt
					_slot:SetSelectCount(cnt)
				end
			elseif arg_str == 'premium' then
				premium_cnt = premium_cnt + cnt
				if premium_cnt > premium_max then
					local adjust_cnt = premium_cnt - premium_max
					cnt = cnt - adjust_cnt
					premium_cnt = premium_cnt - adjust_cnt
					_slot:SetSelectCount(cnt)
				end
			end
		end

		if cnt == 0 then
			_slot:Select(0)
		end
	end

	local reinf_normal_mat_text = GET_CHILD_RECURSIVELY(frame, 'reinf_normal_mat_text')
	reinf_normal_mat_text:SetTextByKey('current', normal_cnt)

	local reinf_premium_mat_text = GET_CHILD_RECURSIVELY(frame, 'reinf_premium_mat_text')
	reinf_premium_mat_text:SetTextByKey('current', premium_cnt)

	slotset:SetUserValue('NORMAL_MAT_COUNT', normal_cnt)
	slotset:SetUserValue('PREMIUM_MAT_COUNT', premium_cnt)

	if normal_cnt > 0 or premium_cnt > 0 then
		local tuto_prop = frame:GetUserValue('TUTO_PROP')
		if tuto_prop == 'UITUTO_GODDESSEQUIP1' then
			local tuto_value = GetUITutoProg(tuto_prop)
			if tuto_value == 2 then
				pc.ReqExecuteTx('SCR_UI_TUTORIAL_NEXT_STEP', tuto_prop)
			end
		end
	end

	GODDESS_MGR_REINFORCE_RATE_UPDATE(frame)
end

function GODDESS_MGR_REINFORCE_EXTRA_MAT_UPDATE(frame)
	local slotset = GET_CHILD_RECURSIVELY(frame, 'reinf_extra_mat_list')
	slotset:ClearIconAll()
	for i = 0, slotset:GetSlotCount() - 1 do
		local slot = slotset:GetSlotByIndex(i)
		slot:RemoveChild('lv_txt')
	end
	slotset:SetUserValue('NORMAL_MAT_COUNT', 0)
	slotset:SetUserValue('PREMIUM_MAT_COUNT', 0)
	
	local reinf_normal_mat_text = GET_CHILD_RECURSIVELY(frame, 'reinf_normal_mat_text')
	reinf_normal_mat_text:SetTextByKey('current', 0)

	local reinf_premium_mat_text = GET_CHILD_RECURSIVELY(frame, 'reinf_premium_mat_text')
	reinf_premium_mat_text:SetTextByKey('current', 0)

	local ref_slot = GET_CHILD_RECURSIVELY(frame, 'ref_slot')
	local guid = ref_slot:GetUserValue('ITEM_GUID')
	if guid ~= 'None' then
		local inv_item = session.GetInvItemByGuid(guid)
		if inv_item == nil then return end

		local item_obj = GetIES(inv_item:GetObject())
		if item_goddess_growth.is_goddess_growth_item(item_obj) == true then
			reinf_normal_mat_text:SetTextByKey('total', 0)
			reinf_premium_mat_text:SetTextByKey('total', 0)
			return
		end

		local use_lv = ref_slot:GetUserIValue('ITEM_USE_LEVEL')

		local normal_cnt = GET_MAX_SUB_REVISION_COUNT(use_lv)
		reinf_normal_mat_text:SetTextByKey('total', normal_cnt)

		local premium_cnt = GET_MAX_PREMIUM_SUB_REVISION_COUNT(use_lv)
		reinf_premium_mat_text:SetTextByKey('total', premium_cnt)

		local inv_item_list = session.GetInvItemList()

		FOR_EACH_INVENTORY(inv_item_list, function(inv_item_list, inv_item, slotset, use_lv)
			local obj = GetIES(inv_item:GetObject())
			local flag, rate = IS_ENGRAVE_MATERIAL_ITEM(obj, use_lv)
			local arg_str = item_goddess_reinforce.is_reinforce_percentUp(obj, use_lv)
			if arg_str ~= 'NO' then
				local slotindex = imcSlot:GetEmptySlotIndex(slotset)
				local slot = slotset:GetSlotByIndex(slotindex)
				local icon = CreateIcon(slot)
				icon:Set(obj.Icon, 'Item', inv_item.type, slotindex, inv_item:GetIESID(), inv_item.count)
				slot:SetUserValue('ITEM_GUID', inv_item:GetIESID())
				slot:SetUserValue('MAT_TYPE', arg_str)
				slot:SetMaxSelectCount(inv_item.count)
				local class = GetClassByType('Item', inv_item.type)
				SET_SLOT_ITEM_TEXT_USE_INVCOUNT(slot, inv_item, obj, inv_item.count)
				ICON_SET_INVENTORY_TOOLTIP(icon, inv_item, 'poisonpot', class)
				if arg_str == 'normal' then
					local lv_txt = slot:CreateOrGetControl('richtext', 'lv_txt', 0, 0, slot:GetWidth(), slot:GetHeight() * 0.3)
					local lv_str = string.format('{@sti1c}{s16}Lv.%d', TryGetProp(obj, 'NumberArg1', 0))
					lv_txt:SetText(lv_str)
				end
			end
		end, false, slotset, use_lv)
	else
		reinf_normal_mat_text:SetTextByKey('total', 0)
		reinf_premium_mat_text:SetTextByKey('total', 0)
	end
end

function GODDESS_MGR_REINFORCE_RATE_UPDATE(frame)
	local reinf_adjust_rate = GET_CHILD_RECURSIVELY(frame, 'reinf_adjust_rate')
	local reinf_total_rate = GET_CHILD_RECURSIVELY(frame, 'reinf_total_rate')

	local ref_slot = GET_CHILD_RECURSIVELY(frame, 'ref_slot')
	local guid = ref_slot:GetUserValue('ITEM_GUID')
	if guid ~= 'None' then
		local inv_item = session.GetInvItemByGuid(guid)
		if inv_item == nil then return end

		local item_obj = GetIES(inv_item:GetObject())
		local use_lv = TryGetProp(item_obj, 'UseLv', 1)
		local class_type = TryGetProp(item_obj, 'ClassType', 'None')
		local reinf_value = TryGetProp(item_obj, 'Reinforce_2', 0)
		local adjust_rate = item_goddess_reinforce.get_current_fail_revision_prop_percent(item_obj)
	
		local slotset = GET_CHILD_RECURSIVELY(frame, 'reinf_extra_mat_list')
		local normal_cnt = slotset:GetUserIValue('NORMAL_MAT_COUNT')
		local premium_cnt = slotset:GetUserIValue('PREMIUM_MAT_COUNT')
		local def_rate = item_goddess_reinforce.get_final_reinforce_prop_percent(item_obj, normal_cnt, premium_cnt)
		local total_rate = def_rate + adjust_rate
		def_rate = string.format('%.2f', math.min(tonumber(def_rate), 100))
		total_rate = string.format('%.2f', math.min(tonumber(total_rate), 100))

		reinf_adjust_rate:SetTextByKey('rate', adjust_rate)
		reinf_total_rate:SetTextByKey('rate', def_rate)
		reinf_total_rate:SetTextByKey('add', adjust_rate)
		reinf_total_rate:SetTextByKey('total', total_rate)
	else
		local _zero = string.format('%.2f', 0)
		reinf_adjust_rate:SetTextByKey('rate', _zero)
		reinf_total_rate:SetTextByKey('rate', _zero)
		reinf_total_rate:SetTextByKey('add', _zero)
		reinf_total_rate:SetTextByKey('total', _zero)
	end
end

function GODDESS_MGR_REFORGE_REINFORCE_CLEAR(frame, is_success)
	local ref_ok_reinforce = GET_CHILD_RECURSIVELY(frame, 'ref_ok_reinforce')
	ref_ok_reinforce:ShowWindow(0)

	local ref_do_reinforce = GET_CHILD_RECURSIVELY(frame, 'ref_do_reinforce')
	ref_do_reinforce:SetEnable(1)
	ref_do_reinforce:ShowWindow(1)

	GODDESS_MGR_REFORGE_REINFORCE_UPDATE(frame);
	if is_success == true then 
		GODDESS_MGR_REFORGE_REINFORCE_AUTO_MAT_FILL(frame); 
	end
end

function GODDESS_MGR_REFORGE_REINFORCE_OPEN(frame)
	GODDESS_MGR_REFORGE_REINFORCE_CLEAR(frame)
end

function GODDESS_MGR_REFORGE_REINFORCE_UPDATE(frame)
	GODDESS_MGR_REINFORCE_MAT_UPDATE(frame)
	GODDESS_MGR_REINFORCE_EXTRA_MAT_UPDATE(frame)
	GODDESS_MGR_REINFORCE_RATE_UPDATE(frame)
end

function GODDESS_MGR_REFORGE_REINFORCE_AUTO_MAT_FILL(frame)
	if frame == nil then return; end
	local reinf_main_mat_bg = GET_CHILD_RECURSIVELY(frame, 'reinf_main_mat_bg');
	if reinf_main_mat_bg == nil then return; end
	local child_count = reinf_main_mat_bg:GetChildCount();
	for i = 0, child_count - 1 do
		local child = reinf_main_mat_bg:GetChildByIndex(i);
		if child ~= nil and string.find(child:GetName(), "GODDESS_REINF_MAT_") ~= nil then
			local btn = GET_CHILD_RECURSIVELY(child, "btn");
			if btn ~= nil then
				GODDESS_MGR_REFORGE_REINFORCE_REG_MAT(child, btn);
			end
		end
	end
end

function GODDESS_MGR_REFORGE_REINFORCE_EXEC(parent, btn)
	local frame = parent:GetTopParentFrame()
	local slot = GET_CHILD_RECURSIVELY(frame, 'ref_slot')
	local icon = slot:GetIcon()
	if icon == nil or icon:GetInfo() == nil then
		ui.SysMsg(ClMsg('NotExistTargetItem'))
		return
	end

	local mat_bg = GET_CHILD_RECURSIVELY(frame, 'reinf_main_mat_bg')
	for i = 0, mat_bg:GetChildCount() - 1 do
		local fdfd = mat_bg:GetChildByIndex(i)
		local ctrlset = GET_CHILD(mat_bg, 'GODDESS_REINF_MAT_' .. i)
		if ctrlset ~= nil and ctrlset:GetUserValue('MATERIAL_IS_SELECTED') ~= 'selected' then
			return
		end
	end

	local guid = slot:GetUserValue('ITEM_GUID')
	local inv_item = session.GetInvItemByGuid(guid)
	if inv_item == nil then return end
	local item_obj = GetIES(inv_item:GetObject())
	local item_name = dic.getTranslatedStr(TryGetProp(item_obj, 'Name', 'None'))

	local reinf_no_msgbox = GET_CHILD_RECURSIVELY(frame, 'reinf_no_msgbox')
	if reinf_no_msgbox:IsChecked() == 1 then
		_GODDESS_MGR_REFORGE_REINFORCE_EXEC()
	else
		local yesscp = '_GODDESS_MGR_REFORGE_REINFORCE_EXEC()'
		local msgbox = ui.MsgBox(ScpArgMsg('ReallyDoAetherGemReinforce', 'name', item_name), yesscp, 'ENABLE_CONTROL_WITH_UI_HOLD(false)')
		SET_MODAL_MSGBOX(msgbox)
	end
end

function _GODDESS_MGR_REFORGE_REINFORCE_EXEC()
	local frame = ui.GetFrame('goddess_equip_manager')
	if frame == nil then return end
	
	session.ResetItemList()

	local slot = GET_CHILD_RECURSIVELY(frame, 'ref_slot')
	local icon = slot:GetIcon()
	if icon == nil or icon:GetInfo() == nil then
		ui.SysMsg(ClMsg('NotExistTargetItem'))
		return
	end

	local guid = slot:GetUserValue('ITEM_GUID')
	session.AddItemID(guid, 1)

	local mat_bg = GET_CHILD_RECURSIVELY(frame, 'reinf_main_mat_bg')
	for i = 0, mat_bg:GetChildCount() - 1 do
		local ctrlset = GET_CHILD(mat_bg, 'GODDESS_REINF_MAT_' .. i)
		if ctrlset ~= nil then
			if ctrlset:GetUserValue('MATERIAL_IS_SELECTED') ~= 'selected' then
				return
			end
	
			local mat_name = ctrlset:GetUserValue('ITEM_NAME')
			if IS_ACCOUNT_COIN(mat_name) == false then
				local mat_item = session.GetInvItemByName(mat_name)
				local mat_guid = mat_item:GetIESID()
				local slot = GET_CHILD(ctrlset, 'slot')
				local mat_count = slot:GetEventScriptArgString(ui.DROP)
				session.AddItemID(mat_guid, tonumber(mat_count))
			end
		end
	end

	local extra_mat_list = GET_CHILD_RECURSIVELY(frame, 'reinf_extra_mat_list')
	for i = 0, extra_mat_list:GetSlotCount() - 1 do
		local _slot = extra_mat_list:GetSlotByIndex(i)
		local cnt = _slot:GetSelectCount()
		if cnt > 0 then
			local extra_mat_guid = _slot:GetUserValue('ITEM_GUID')
			if extra_mat_guid == 'None' then return end

			session.AddItemID(extra_mat_guid, cnt)
		end
	end

	local result_list = session.GetItemIDList()
	
	item.DialogTransaction('GODDESS_REINFORCE', result_list)

	local ref_do_reinforce = GET_CHILD_RECURSIVELY(frame, 'ref_do_reinforce')
	ref_do_reinforce:SetEnable(0)
end

function GODDESS_MGR_REINFORCE_CLEAR_BTN(parent, btn)
	local effect_frame = ui.GetFrame('result_effect_ui')
	effect_frame:ShowWindow(0)

	local frame = parent:GetTopParentFrame()

	local reinforce_value = 0
	local slot = GET_CHILD_RECURSIVELY(frame, 'ref_slot')
	local guid = slot:GetUserValue('ITEM_GUID')
	if guid ~= 'None' then
		local inv_item = session.GetInvItemByGuid(guid)
		if inv_item ~= nil then
			local item_obj = GetIES(inv_item:GetObject())
			reinforce_value = TryGetProp(item_obj, 'Reinforce_2', 0)
		end
	end

	local ref_item_reinf_text = GET_CHILD_RECURSIVELY(frame, 'ref_item_reinf_text')
	ref_item_reinf_text:SetTextByKey('value', reinforce_value)
	
	local result_str = frame:GetUserValue('REINFORCE_RESULT')
	if result_str == 'SUCCESS' then
		GODDESS_MGR_REFORGE_REINFORCE_CLEAR(frame, true)
	else
		local ref_ok_reinforce = GET_CHILD_RECURSIVELY(frame, 'ref_ok_reinforce')
		ref_ok_reinforce:ShowWindow(0)
		local ref_do_reinforce = GET_CHILD_RECURSIVELY(frame, 'ref_do_reinforce')
		ref_do_reinforce:SetEnable(1)
		ref_do_reinforce:ShowWindow(1)

		local clear_flag = false
		local mat_bg = GET_CHILD_RECURSIVELY(frame, 'reinf_main_mat_bg')
		for i = 0, mat_bg:GetChildCount() - 1 do
			local ctrlset = GET_CHILD(mat_bg, 'GODDESS_REINF_MAT_' .. i)
			if ctrlset ~= nil then
				local slot = GET_CHILD(ctrlset, 'slot')
				local mat_name = ctrlset:GetUserValue('ITEM_NAME')
				local cur_count = '0'
				if IS_ACCOUNT_COIN(mat_name) == true then
					local acc = GetMyAccountObj()
					cur_count = TryGetProp(acc, mat_name, '0')
					if cur_count == 'None' then
						cur_count = '0'
					end
				else
					local mat_item = session.GetInvItemByName(mat_name)
					if mat_item == nil then
						clear_flag = true
						break
					end

					cur_count = tostring(mat_item.count)
				end

				local need_count = slot:GetEventScriptArgString(ui.DROP)
				if math.is_larger_than(tostring(need_count), cur_count) == 1 then
					clear_flag = true
					break
				end
			end
		end

		local extra_mat_list = GET_CHILD_RECURSIVELY(frame, 'reinf_extra_mat_list')
		for i = 0, extra_mat_list:GetSlotCount() - 1 do
			local slot = extra_mat_list:GetSlotByIndex(i)
			local cnt = slot:GetSelectCount()
			if cnt > 0 then
				local _guid = slot:GetUserValue('ITEM_GUID')
				local extra_mat = session.GetInvItemByGuid(_guid)
				if extra_mat == nil then
					clear_flag = true
					break
				end

				if extra_mat.count < cnt then
					clear_flag = true
					break
				end
			end
		end

		if clear_flag == true then
			GODDESS_MGR_REFORGE_REINFORCE_CLEAR(frame)
		else
			_REFORGE_REINFORCE_MAT_COUNT_UPDATE(frame)
			_REFORGE_REINFORCE_EXTRA_MAT_COUNT_UPDATE(frame)
			GODDESS_MGR_REINFORCE_RATE_UPDATE(frame)
		end
	end

	local tuto_prop = frame:GetUserValue('TUTO_PROP')
	if tuto_prop == 'UITUTO_GODDESSEQUIP1' then
		local tuto_value = GetUITutoProg(tuto_prop)
		if tuto_value == 4 then
			pc.ReqExecuteTx('SCR_UI_TUTORIAL_NEXT_STEP', tuto_prop)
		end
	end
end

function ON_SUCCESS_REFORGE_REINFORCE_EXEC(frame, msg, arg_str, arg_num)	

	if arg_str == nil or arg_str == 'None' then
		arg_str = '0'
	end

	arg_str = tonumber(arg_str)

	frame:SetUserValue('REINFORCE_RESULT', 'SUCCESS')

	local ref_do_reinforce = GET_CHILD_RECURSIVELY(frame, 'ref_do_reinforce')
	ref_do_reinforce:ShowWindow(0)

	local ref_slot = GET_CHILD_RECURSIVELY(frame, 'ref_slot')
	local guid = ref_slot:GetUserValue('ITEM_GUID')
	local inv_item = session.GetInvItemByGuid(guid)
	local item_obj = GetIES(inv_item:GetObject())
	local icon = TryGetProp(item_obj, 'Icon', 'None')

	local left, top = _GET_EFFECT_UI_MARGIN()

	local high_grade = 0
	if arg_str >= 480 and arg_num >= 22 then
		high_grade = 1
	end
	
	local success_scp = string.format('RESULT_EFFECT_UI_RUN_SUCCESS(\'%s\', \'%s\', \'%d\', \'%d\', %d)', '_END_REFORGE_REINFORCE_EXEC', icon, left, top, high_grade)
	ReserveScript(success_scp, 0)
end

function ON_FAILED_REFORGE_REINFORCE_EXEC(frame, msg, arg_str, arg_num)
	frame:SetUserValue('REINFORCE_RESULT', 'FAILED')

	local ref_do_reinforce = GET_CHILD_RECURSIVELY(frame, 'ref_do_reinforce')
	ref_do_reinforce:ShowWindow(0)
	
	local left, top = _GET_EFFECT_UI_MARGIN()

	local failed_scp = string.format('RESULT_EFFECT_UI_RUN_FAILED(\'%s\', \'%d\', \'%d\')', '_END_REFORGE_REINFORCE_EXEC', left, top)
	ReserveScript(failed_scp, 0)
end

function _END_REFORGE_REINFORCE_EXEC()
	local frame = ui.GetFrame('goddess_equip_manager')
	local ref_ok_reinforce = GET_CHILD_RECURSIVELY(frame, 'ref_ok_reinforce')
	ref_ok_reinforce:ShowWindow(1)

	local tuto_prop = frame:GetUserValue('TUTO_PROP')
	if tuto_prop == 'UITUTO_GODDESSEQUIP1' then
		local tuto_value = GetUITutoProg(tuto_prop)
		if tuto_value == 3 then
			pc.ReqExecuteTx('SCR_UI_TUTORIAL_NEXT_STEP', tuto_prop)
		end
	end
end
-- 재련 - 강화 끝

-- 재련 - 인챈트
local function _GODDESS_MGR_MAKE_ENCHANT_OPTION(box, item_obj)
	box:RemoveAllChild()
	
	if item_obj ~= nil then
		local rareOptionText = GET_RANDOM_OPTION_RARE_CLIENT_TEXT(item_obj)
		if rareOptionText ~= nil then
			local rareOptionCtrl = box:CreateOrGetControlSet('eachproperty_in_itemrandomreset', 'PROPERTY_CSET_RARE', 0, 0)
			rareOptionCtrl = AUTO_CAST(rareOptionCtrl)
			rareOptionCtrl:Resize(box:GetWidth(), rareOptionCtrl:GetWidth())
			rareOptionCtrl:Move(0, 30)
			local propertyList = GET_CHILD_RECURSIVELY(rareOptionCtrl, 'property_name', 'ui::CRichText')
			propertyList:SetOffset(30, propertyList:GetY())
			propertyList:SetText(rareOptionText)
			
			local width = propertyList:GetWidth()
			local frame = box:GetTopParentFrame()
			local fixwidth = box:GetWidth() - 50

			if fixwidth < width then
				propertyList:SetTextFixWidth(1)
				propertyList:SetTextMaxWidth(fixwidth)
			end			
		end
	end
end

function GODDESS_MGR_REFORGE_ENCHANT_MAT_DROP(parent, slot)
	local frame = parent:GetTopParentFrame()
	local lift_icon = ui.GetLiftIcon()
	local from_frame = lift_icon:GetTopParentFrame()
    if from_frame:GetName() == 'inventory' then        
        local icon_info = lift_icon:GetInfo()
        local guid = icon_info:GetIESID()
		local inv_item = session.GetInvItemByGuid(guid)
		local item_obj = GetIES(inv_item:GetObject())
		if item_obj ~= nil and inv_item ~= nil then
			GODDESS_MGR_REFORGE_ENCHANT_REG_MAT_ITEM(frame, inv_item, item_obj)
		end
	end
end

function GODDESS_MGR_REFORGE_ENCHANT_REG_MAT_ITEM(frame, inv_item, item_obj)
	local equip_slot = GET_CHILD_RECURSIVELY(frame, 'ref_slot')
	local equip_guid = equip_slot:GetUserValue('ITEM_GUID')
	local equip_item = session.GetInvItemByGuid(equip_guid)
	if equip_item == nil then
		return
	end

	local equip_obj = GetIES(equip_item:GetObject())
	if equip_obj == nil then
		return
	end

	if IS_ENABLE_APPLY_GODDESS_ENCHANT(item_obj, equip_obj) == false then
		ui.SysMsg(ClMsg('IT_ISNT_REINFORCEABLE_ITEM'))
		return
	end
	
	local slot = GET_CHILD_RECURSIVELY(frame, 'ref_enchant_slot')
	SET_SLOT_ITEM(slot, inv_item)
	slot:SetUserValue('ITEM_GUID', inv_item:GetIESID())

	local slot_pic = GET_CHILD_RECURSIVELY(frame, 'ref_enchant_slot_bg_image')
	slot_pic:ShowWindow(0)

	local puton_text = GET_CHILD_RECURSIVELY(frame, 'ref_enchant_puton_item_text')
	puton_text:ShowWindow(0)
	
	local name_text = GET_CHILD_RECURSIVELY(frame, 'ref_enchant_item_name_text')
	name_text:SetText(dic.getTranslatedStr(TryGetProp(item_obj, 'Name', 'None')))
	name_text:ShowWindow(1)

	GODDESS_MGR_REFORGE_ENCHANT_MAT_COUNT(frame)

	local tuto_prop = frame:GetUserValue('TUTO_PROP')
	if tuto_prop == 'UITUTO_GODDESSEQUIP2' then
		local tuto_value = GetUITutoProg(tuto_prop)
		if tuto_value == 1 then
			pc.ReqExecuteTx('SCR_UI_TUTORIAL_NEXT_STEP', tuto_prop)
		end
	end
end

function GODDESS_MGR_REFORGE_ENCHANT_MAT_REMOVE(parent, slot)
	local frame = parent:GetTopParentFrame()
	slot:ClearIcon()
	slot:SetUserValue('ITEM_GUID', 'None')

	local slot_pic = GET_CHILD_RECURSIVELY(frame, 'ref_enchant_slot_bg_image')
	slot_pic:ShowWindow(1)

	local name_text = GET_CHILD_RECURSIVELY(frame, 'ref_enchant_item_name_text')
	name_text:ShowWindow(0)

	local puton_text = GET_CHILD_RECURSIVELY(frame, 'ref_enchant_puton_item_text')
	puton_text:ShowWindow(1)

	GODDESS_MGR_REFORGE_ENCHANT_MAT_COUNT(frame)
end

function GODDESS_MGR_REFORGE_ENCHANT_MAT_COUNT(frame)
	local have_text = GET_CHILD_RECURSIVELY(frame, 'ref_enchant_have_mat')
	local need_text = GET_CHILD_RECURSIVELY(frame, 'ref_enchant_need_mat')

	local mat_slot = GET_CHILD_RECURSIVELY(frame, 'ref_enchant_slot')
	local icon = mat_slot:GetIcon()
	if icon == nil or icon:GetInfo() == nil then
		have_text:ShowWindow(0)
		need_text:ShowWindow(0)
	else
		local mat_item = session.GetInvItemByGuid(mat_slot:GetUserValue('ITEM_GUID'))
		if mat_item == nil then
			have_text:ShowWindow(0)
			need_text:ShowWindow(0)
		else
			local mat_obj = GetIES(mat_item:GetObject())
			local mat_name = dic.getTranslatedStr(TryGetProp(mat_obj, 'Name', 'None'))
	
			have_text:SetTextByKey('name', mat_name)
			have_text:SetTextByKey('count', mat_item.count)
			have_text:ShowWindow(1)
	
			need_text:SetTextByKey('name', mat_name)
			need_text:SetTextByKey('count', 1)
			need_text:ShowWindow(1)
		end
	end
end

function GODDESS_MGR_REFORGE_ENCHANT_CLEAR(frame)
	local ref_enchant_send_ok = GET_CHILD_RECURSIVELY(frame, 'ref_enchant_send_ok')
	ref_enchant_send_ok:ShowWindow(0)

	local ref_enchant_do = GET_CHILD_RECURSIVELY(frame, 'ref_enchant_do')
	ref_enchant_do:ShowWindow(1)
	ref_enchant_do:SetEnable(1)
	
	local ref_enchant_after_sub = GET_CHILD_RECURSIVELY(frame, 'ref_enchant_after_sub')
	ref_enchant_after_sub:RemoveAllChild()

	local slot = GET_CHILD_RECURSIVELY(frame, 'ref_enchant_slot')
	GODDESS_MGR_REFORGE_ENCHANT_MAT_REMOVE(frame, slot)

	GODDESS_MGR_REFORGE_ENCHANT_UPDATE(frame)
end

function GODDESS_MGR_REFORGE_ENCHANT_CLEAR_AFTER_EXEC(parent, btn)
	local frame = parent:GetTopParentFrame()

	local ref_enchant_send_ok = GET_CHILD_RECURSIVELY(frame, 'ref_enchant_send_ok')
	ref_enchant_send_ok:ShowWindow(0)

	local ref_enchant_do = GET_CHILD_RECURSIVELY(frame, 'ref_enchant_do')
	ref_enchant_do:ShowWindow(1)
	ref_enchant_do:SetEnable(1)
	
	local ref_enchant_after_sub = GET_CHILD_RECURSIVELY(frame, 'ref_enchant_after_sub')
	ref_enchant_after_sub:RemoveAllChild()
	
	local slot = GET_CHILD_RECURSIVELY(frame, 'ref_enchant_slot')
	local mat_guid = slot:GetUserValue('ITEM_GUID')
	local mat_item = session.GetInvItemByGuid(mat_guid)
	if mat_item == nil then
		GODDESS_MGR_REFORGE_ENCHANT_MAT_REMOVE(frame, slot)
	end

	GODDESS_MGR_REFORGE_ENCHANT_MAT_COUNT(frame)

	GODDESS_MGR_REFORGE_ENCHANT_UPDATE(frame)

	local tuto_prop = frame:GetUserValue('TUTO_PROP')
	if tuto_prop == 'UITUTO_GODDESSEQUIP2' then
		local tuto_value = GetUITutoProg(tuto_prop)
		if tuto_value == 4 then
			pc.ReqExecuteTx('SCR_UI_TUTORIAL_NEXT_STEP', tuto_prop)
		end
	end
end

function GODDESS_MGR_REFORGE_ENCHANT_OPEN(frame)
	GODDESS_MGR_REFORGE_ENCHANT_CLEAR(frame)
end

function GODDESS_MGR_REFORGE_ENCHANT_UPDATE(frame)	
	local ref_enchant_before_sub = GET_CHILD_RECURSIVELY(frame, 'ref_enchant_before_sub')
	ref_enchant_before_sub:RemoveAllChild()

	local slot = GET_CHILD_RECURSIVELY(frame, 'ref_slot')
	local guid = slot:GetUserValue('ITEM_GUID')
	if guid ~= 'None' then
		local inv_item = session.GetInvItemByGuid(guid)
		if inv_item ~= nil then
			local item_obj = GetIES(inv_item:GetObject())
			if item_goddess_transcend.is_able_to_enchant(item_obj) ~= 'YES' then
				CLEAR_REFORGE_MAIN_SLOT(frame)
				return
			end

			_GODDESS_MGR_MAKE_ENCHANT_OPTION(ref_enchant_before_sub, item_obj)
		end
	end
end

function GODDESS_MGR_REFORGE_ENCHANT_EXEC(parent, btn)
	local frame = parent:GetTopParentFrame()
	local slot = GET_CHILD_RECURSIVELY(frame, 'ref_slot')
	local icon = slot:GetIcon()
	if icon == nil or icon:GetInfo() == nil then
		ui.SysMsg(ClMsg('NotExistTargetItem'))
		return
	end

	local mat_slot = GET_CHILD_RECURSIVELY(frame, 'ref_enchant_slot')
	local icon = mat_slot:GetIcon()
	if icon == nil or icon:GetInfo() == nil then
		ui.SysMsg(ClMsg('NotExistTargetItem'))
		return
	end

	local guid = slot:GetUserValue('ITEM_GUID')
	local inv_item = session.GetInvItemByGuid(guid)
	if inv_item == nil then return end

	local mat_guid = mat_slot:GetUserValue('ITEM_GUID')
	local mat_item = session.GetInvItemByGuid(mat_guid)
	if mat_item == nil then return end

	local enchant_no_msgbox = GET_CHILD_RECURSIVELY(frame, 'enchant_no_msgbox')
	if enchant_no_msgbox:IsChecked() == 1 then
		_GODDESS_MGR_REFORGE_ENCHANT_EXEC()
	else
		local yesscp = '_GODDESS_MGR_REFORGE_ENCHANT_EXEC()'
		local msgbox = ui.MsgBox(ClMsg('CommitEnchantOption'), yesscp, 'ENABLE_CONTROL_WITH_UI_HOLD(false)')
		SET_MODAL_MSGBOX(msgbox)
	end

	ENABLE_CONTROL_WITH_UI_HOLD(true)
end

function _GODDESS_MGR_REFORGE_ENCHANT_EXEC()
	local frame = ui.GetFrame('goddess_equip_manager')
	if frame == nil or frame:IsVisible() == 0 then
		ENABLE_CONTROL_WITH_UI_HOLD(false)
		return
	end

	local slot = GET_CHILD_RECURSIVELY(frame, 'ref_slot')
	local icon = slot:GetIcon()
	if icon == nil or icon:GetInfo() == nil then
		ui.SysMsg(ClMsg('NotExistTargetItem'))
		ENABLE_CONTROL_WITH_UI_HOLD(false)
		return
	end

	local mat_slot = GET_CHILD_RECURSIVELY(frame, 'ref_enchant_slot')
	local icon = mat_slot:GetIcon()
	if icon == nil or icon:GetInfo() == nil then
		ui.SysMsg(ClMsg('NotExistTargetItem'))
		ENABLE_CONTROL_WITH_UI_HOLD(false)
		return
	end

	local guid = slot:GetUserValue('ITEM_GUID')
	local inv_item = session.GetInvItemByGuid(guid)

	local mat_guid = mat_slot:GetUserValue('ITEM_GUID')
	local mat_item = session.GetInvItemByGuid(mat_guid)

	if inv_item == nil or mat_item == nil then
		ui.SysMsg(ClMsg('CannotEnchantOptionEquipItem'))
		ENABLE_CONTROL_WITH_UI_HOLD(false)
		return
	end
	
	if inv_item.isLockState == true or mat_item.isLockState == true then
		ui.SysMsg(ClMsg('MaterialItemIsLock'))
		ENABLE_CONTROL_WITH_UI_HOLD(false)
		return
	end

	session.ResetItemList()
    session.AddItemID(guid, 1)
	session.AddItemID(mat_guid, 1)
	
    local result_list = session.GetItemIDList()
	item.DialogTransaction('EXECUTE_GODDESS_ENCHANT', result_list)
end

function ON_SUCCESS_REFORGE_ENCHANT_EXEC(frame, msg, arg_str, arg_num)
	local RESET_SUCCESS_EFFECT_NAME = frame:GetUserConfig('RESET_SUCCESS_EFFECT')
	local EFFECT_SCALE = tonumber(frame:GetUserConfig('EFFECT_SCALE'))
	local EFFECT_DURATION = tonumber(frame:GetUserConfig('EFFECT_DURATION'))
	local pic_bg = GET_CHILD_RECURSIVELY(frame, 'ref_enchant_pic')
	if pic_bg == nil then
		ENABLE_CONTROL_WITH_UI_HOLD(false)
		return
	end

	local ref_enchant_do = GET_CHILD_RECURSIVELY(frame, 'ref_enchant_do')
	ref_enchant_do:SetEnable(0)

	pic_bg:StopUIEffect('RESET_SUCCESS_EFFECT', true, 0.5)
	pic_bg:PlayUIEffect(RESET_SUCCESS_EFFECT_NAME, EFFECT_SCALE, 'RESET_SUCCESS_EFFECT')
	ReserveScript('_SUCCESS_REFORGE_ENCHANT_EXEC()', EFFECT_DURATION)
end

function _SUCCESS_REFORGE_ENCHANT_EXEC()
	ENABLE_CONTROL_WITH_UI_HOLD(false)

	local frame = ui.GetFrame('goddess_equip_manager')
	if frame == nil then
		return
	end

	GODDESS_MGR_REFORGE_ENCHANT_MAT_COUNT(frame)

	local ref_enchant_do = GET_CHILD_RECURSIVELY(frame, 'ref_enchant_do')
	ref_enchant_do:ShowWindow(0)
	
	local ref_enchant_send_ok = GET_CHILD_RECURSIVELY(frame, 'ref_enchant_send_ok')
	ref_enchant_send_ok:ShowWindow(1)

	local tuto_prop = frame:GetUserValue('TUTO_PROP')
	if tuto_prop == 'UITUTO_GODDESSEQUIP2' then
		local tuto_value = GetUITutoProg(tuto_prop)
		if tuto_value == 3 then
			pc.ReqExecuteTx('SCR_UI_TUTORIAL_NEXT_STEP', tuto_prop)
		end
	end

	local ref_enchant_after_sub = GET_CHILD_RECURSIVELY(frame, 'ref_enchant_after_sub')
	ref_enchant_after_sub:RemoveAllChild()

	local slot = GET_CHILD_RECURSIVELY(frame, 'ref_slot')
	local guid = slot:GetUserValue('ITEM_GUID')
	if guid ~= 'None' then
		local inv_item = session.GetInvItemByGuid(guid)
		if inv_item ~= nil then
			local item_obj = GetIES(inv_item:GetObject())
			_GODDESS_MGR_MAKE_ENCHANT_OPTION(ref_enchant_after_sub, item_obj)
		end
	end

	local pic_bg = GET_CHILD_RECURSIVELY(frame, 'ref_enchant_pic')
	if pic_bg == nil then
		return
	end
	pic_bg:StopUIEffect('RESET_SUCCESS_EFFECT', true, 0.5)
end

function ON_FAILED_REFORGE_ENCHANT_EXEC(frame, msg, arg_str, arg_num)
	ENABLE_CONTROL_WITH_UI_HOLD(false)
	ui.SysMsg(ClMsg('FailEnchantJewell'))
	GODDESS_MGR_REFORGE_ENCHANT_CLEAR(frame)
end
-- 재련 - 인챈트 끝

-- 재련 - 초월
function GODDESS_MGR_REFORGE_TRANSCEND_CLEAR(frame)
	local ref_transcend_send_ok = GET_CHILD_RECURSIVELY(frame, 'ref_transcend_send_ok')
	ref_transcend_send_ok:ShowWindow(0)
	
	local ref_transcend_do = GET_CHILD_RECURSIVELY(frame, 'ref_transcend_do')
	ref_transcend_do:SetEnable(1)
	ref_transcend_do:ShowWindow(1)

	local result_bg = GET_CHILD_RECURSIVELY(frame, 'ref_transcend_result_bg')
	result_bg:RemoveAllChild()
	result_bg:ShowWindow(0)

	local slot = GET_CHILD_RECURSIVELY(frame, 'ref_transcend_slot')
	slot:StopActiveUIEffect()

	frame:StopUpdateScript('TIMEWAIT_STOP_GODDESS_TRANSCEND')

	local slot_temp = GET_CHILD_RECURSIVELY(frame, 'ref_transcend_slot_temp')
	slot_temp:StopActiveUIEffect()
	slot_temp:ShowWindow(0)	
	frame:SetUserValue('ONANIPICTURE_PLAY', 0)

	GODDESS_MGR_REFORGE_TRANSCEND_UPDATE(frame)
end

function GODDESS_MGR_REFORGE_TRANSCEND_OPEN(frame)
	GODDESS_MGR_REFORGE_TRANSCEND_CLEAR(frame)
end

function GODDESS_MGR_REFORGE_TRANSCEND_CLEAR_AFTER_EXEC(parent, btn)
	local frame = parent:GetTopParentFrame()

	local transcend_lv = 0
	local slot = GET_CHILD_RECURSIVELY(frame, 'ref_slot')
	local guid = slot:GetUserValue('ITEM_GUID')
	if guid ~= 'None' then
		local inv_item = session.GetInvItemByGuid(guid)
		if inv_item ~= nil then
			local item_obj = GetIES(inv_item:GetObject())
			transcend_lv = TryGetProp(item_obj, 'Transcend', 0)
		end
	end

	local ref_item_trans_text = GET_CHILD_RECURSIVELY(frame, 'ref_item_trans_text')
	ref_item_trans_text:SetTextByKey('value', transcend_lv)

	GODDESS_MGR_REFORGE_TRANSCEND_CLEAR(frame)
end

function GODDESS_MGR_TRANSCEND_LEVEL_UPBTN(parent, btn)
	local frame = parent:GetTopParentFrame()
	GODDESS_MGR_REFORGE_TRANSCEND_MAT_UPDATE(frame, 1)
end

function GODDESS_MGR_TRANSCEND_LEVEL_DOWNBTN(parent, btn)
	local frame = parent:GetTopParentFrame()
	GODDESS_MGR_REFORGE_TRANSCEND_MAT_UPDATE(frame, -1)
end

function GODDESS_MGR_TRANSCEND_BG_ANIM_TICK(ctrl, str, tick)	
	if tick == 14 then
		local frame = ctrl:GetTopParentFrame()
		local slot_material = GET_CHILD(frame, 'ref_transcend_slot_material')
		slot_material:StopActiveUIEffect()
		local animpic_slot = GET_CHILD_RECURSIVELY(frame, 'ref_transcend_animpic_slot')
		animpic_slot:ForcePlayAnimation()
		ReserveScript('GODDESS_TRANSCEND_EFFECT()', 0.3)
	end
end

function GODDESS_TRANSCEND_EFFECT()
	local frame = ui.GetFrame('goddess_equip_manager')
	_UPDATE_GODDESS_TRANSCEND_RESULT(frame)
end

function UPDATE_GODDESS_TRANSCEND_RESULT(frame)
	ReserveScript('GODDESS_TRANSCEND_EFFECT()', 0.3)
end

function _UPDATE_GODDESS_TRANSCEND_RESULT(frame)
	local ref_transcend_do = GET_CHILD_RECURSIVELY(frame, 'ref_transcend_do')
	ref_transcend_do:ShowWindow(0)
	
	local ref_transcend_send_ok = GET_CHILD_RECURSIVELY(frame, 'ref_transcend_send_ok')
	ref_transcend_send_ok:ShowWindow(1)
	
	local slot = GET_CHILD_RECURSIVELY(frame, 'ref_transcend_slot')
	
	imcSound.PlaySoundEvent(frame:GetUserConfig('TRANS_SUCCESS_SOUND'))
	slot:StopActiveUIEffect()
	slot:PlayActiveUIEffect()

	local timesecond = 0.1

	local gbox = frame:GetChild('gbox')

	local inv_item = GET_SLOT_ITEM(slot)
	if inv_item == nil then
		ui.SetHoldUI(false)
		slot:ClearIcon()
		ITEMTRANSCEND_LOCK_ITEM('None')
		frame:StopUpdateScript('TIMEWAIT_STOP_GODDESS_TRANSCEND')
		frame:SetUserValue('ONANIPICTURE_PLAY', 0)

		return
	end

	local item_obj = GetIES(inv_item:GetObject())
	local transcend = TryGetProp(item_obj, 'Transcend', 0)
	local beforetranscend = transcend - 1

	local transcendCls = GetClass('ItemTranscend', transcend)
	if transcendCls == nil then
		ui.SetHoldUI(false)
		return
	end
	
	local result_bg = GET_CHILD_RECURSIVELY(frame, 'ref_transcend_result_bg')
	result_bg:RemoveAllChild()
	
	local result_txt = ''
	local upfont = '{@st43_green}{s18}'
	local oper_txt = ' + '
	local prop_name_list, prop_value_list = GET_ITEM_TRANSCENDED_PROPERTY(item_obj)
	for i = 1 , #prop_name_list do
		local prop_name = prop_name_list[i]
		local prop_value = prop_value_list[i]

		if result_txt ~= '' then
			result_txt = result_txt .. '{nl}{/}'
		end

		result_txt = string.format('%s%s%s%s%s', result_txt, upfont, ScpArgMsg(prop_name), oper_txt, prop_value)
		result_txt = result_txt .. '%{/}'
		local ctrlSet = result_bg:CreateOrGetControlSet('transcend_result_text', 'RV_' .. prop_name, ui.CENTER_HORZ, ui.TOP, 0, 0, 0, 0)
		local text = ctrlSet:GetChild('text')
		text:SetTextByKey('propname', ScpArgMsg(prop_name))
		text:SetTextByKey('propoper', oper_txt)
		text:SetTextByKey('propvalue', prop_value)
	end

	GBOX_AUTO_ALIGN(result_bg, 0, 0, 0, true , true)

	frame:StopUpdateScript('TIMEWAIT_STOP_GODDESS_TRANSCEND')
	frame:RunUpdateScript('TIMEWAIT_STOP_GODDESS_TRANSCEND', timesecond)
	frame:SetUserValue('ONANIPICTURE_PLAY', 0)

	ui.SetHoldUI(false)
end

function GODDESS_TRANSCEND_RESULT_REMOVE()
	local frame = ui.GetFrame('goddess_equip_manager')
	local result_bg = GET_CHILD_RECURSIVELY(frame, 'ref_transcend_result_bg')
	result_bg:ShowWindow(0)
end

function TIMEWAIT_STOP_GODDESS_TRANSCEND()
	local frame = ui.GetFrame('goddess_equip_manager')
	local slot_temp = GET_CHILD_RECURSIVELY(frame, 'ref_transcend_slot_temp')
	slot_temp:ShowWindow(0)
	slot_temp:StopActiveUIEffect()

	local result_bg = GET_CHILD_RECURSIVELY(frame, 'ref_transcend_result_bg')
	result_bg:ShowWindow(1)
	ReserveScript('GODDESS_TRANSCEND_RESULT_REMOVE()', 6.0)
	
	frame:StopUpdateScript('TIMEWAIT_STOP_GODDESS_TRANSCEND')

	return 1
end

function GODDESS_MGR_REFORGE_TRANSCEND_MAT_UPDATE(frame, count)
	local ref_transcend_bg = GET_CHILD_RECURSIVELY(frame, 'ref_transcend_bg')
	local ref_slot = GET_CHILD_RECURSIVELY(frame, 'ref_slot')
	local mat_slot = GET_CHILD_RECURSIVELY(frame, 'ref_transcend_slot_material')
	local trans_lv_bg = GET_CHILD_RECURSIVELY(frame, 'ref_trans_lv_bg')
	local trans_max_lv_text = GET_CHILD_RECURSIVELY(frame, 'trans_max_lv_text')
	local trans_mat_btn_bg = GET_CHILD_RECURSIVELY(frame, 'ref_trans_mat_btn_bg')
	local trans_from_lv_text = GET_CHILD_RECURSIVELY(frame, 'trans_from_lv_text')
	local trans_to_lv_text = GET_CHILD_RECURSIVELY(frame, 'trans_to_lv_text')
	
	local equip_guid = ref_slot:GetUserValue('ITEM_GUID')
	local inv_item = session.GetInvItemByGuid(equip_guid)
	if inv_item == nil then return end
	
	local item_obj = GetIES(inv_item:GetObject())
	local mat_name = GET_TRANSCEND_MATERIAL_ITEM(item_obj)
	local mat_item = session.GetInvItemByName(mat_name)
	local max_lv = GET_MAX_TRANSCEND_POINT()

	local cur_lv = ref_transcend_bg:GetUserIValue('CURRENT_LEVEL')
	local goal_lv = 0
	local is_max_lv = false
	if cur_lv == max_lv then
		goal_lv = cur_lv
		is_max_lv = true
	else
		goal_lv = ref_transcend_bg:GetUserIValue('GOAL_LEVEL') + count
		if goal_lv > max_lv then
			goal_lv = max_lv
		elseif goal_lv <= cur_lv then
			goal_lv = cur_lv + 1
		end
	end

	if is_max_lv == true then
		trans_lv_bg:ShowWindow(0)
		trans_mat_btn_bg:ShowWindow(0)
		trans_max_lv_text:ShowWindow(1)
		trans_max_lv_text:SetTextByKey('value', cur_lv)
	else
		trans_from_lv_text:SetTextByKey('value', cur_lv)
		trans_to_lv_text:SetTextByKey('value', goal_lv)
		trans_max_lv_text:ShowWindow(0)
		trans_lv_bg:ShowWindow(1)
		trans_mat_btn_bg:ShowWindow(1)
	end
	
	ref_transcend_bg:SetUserValue('GOAL_LEVEL', goal_lv)

	local use_lv = ref_slot:GetUserIValue('ITEM_USE_LEVEL')
	local class_type = TryGetProp(item_obj, 'ClassType', 'None')
	local mat_list = item_goddess_transcend.get_material_list(use_lv, class_type, cur_lv, goal_lv)
	if mat_list == nil then		
			ref_slot:ClearIcon()
			ref_slot:SetUserValue('ITEM_GUID', 'None')		
			local transcend_slot = GET_CHILD_RECURSIVELY(frame, 'ref_transcend_slot')
			transcend_slot:ClearIcon()
		return
	end

	local need_count = mat_list[mat_name]
	local have_count = 0
	if mat_item ~= nil and is_max_lv == false then
		have_count = mat_item.count
	end
	local count_str = string.format('%d/%d', have_count, need_count)

	SET_SLOT_COUNT_TEXT(mat_slot, count_str)

	if TryGetProp(item_obj, 'Transcend', 0) == 10 then
		mat_slot:ShowWindow(0)
	else
		mat_slot:ShowWindow(1)		
	end
	
	if mat_item == nil then return end

	local icon = mat_slot:GetIcon()
	if have_count < need_count then
		icon:SetColorTone('FFFF0000')
		mat_slot:SetUserValue('ITEM_GUID', 'None')
		mat_slot:SetUserValue('MAT_NEED_COUNT', -1)
	else
		icon:SetColorTone('FFFFFFFF')
		mat_slot:SetUserValue('ITEM_GUID', mat_item:GetIESID())
		mat_slot:SetUserValue('MAT_NEED_COUNT', need_count)
	end
end

function GODDESS_MGR_REFORGE_TRANSCEND_UPDATE(frame)
	local ref_transcend_bg = GET_CHILD_RECURSIVELY(frame, 'ref_transcend_bg')
	local ref_slot = GET_CHILD_RECURSIVELY(frame, 'ref_slot')
	local transcend_slot = GET_CHILD_RECURSIVELY(frame, 'ref_transcend_slot')
	local mat_slot = GET_CHILD_RECURSIVELY(frame, 'ref_transcend_slot_material')
	local ref_trans_lv_bg = GET_CHILD_RECURSIVELY(frame, 'ref_trans_lv_bg')
	local trans_max_lv_text = GET_CHILD_RECURSIVELY(frame, 'trans_max_lv_text')
	local ref_trans_mat_btn_bg = GET_CHILD_RECURSIVELY(frame, 'ref_trans_mat_btn_bg')
	local equip_guid = ref_slot:GetUserValue('ITEM_GUID')
	if equip_guid == 'None' then
		ref_transcend_bg:SetUserValue('CURRENT_LEVEL', 0)
		transcend_slot:ClearIcon()
		mat_slot:ClearIcon()
		ref_trans_lv_bg:ShowWindow(0)
		trans_max_lv_text:ShowWindow(0)
		ref_trans_mat_btn_bg:ShowWindow(0)
	else
		local inv_item = session.GetInvItemByGuid(equip_guid)
		if inv_item == nil then return end

		local item_obj = GetIES(inv_item:GetObject())
		if item_goddess_transcend.is_able_to_enchant(item_obj) ~= 'YES' then
			CLEAR_REFORGE_MAIN_SLOT(frame)
			return
		end

		SET_SLOT_ITEM(transcend_slot, inv_item)
		
		local cur_lv = TryGetProp(item_obj, 'Transcend', 0)
		
		local mat_name = GET_TRANSCEND_MATERIAL_ITEM(item_obj)
		local mat_cls = GetClass('Item', mat_name)
		if mat_cls == nil then return end

		SET_SLOT_ITEM_CLS(mat_slot, mat_cls)

		ref_transcend_bg:SetUserValue('CURRENT_LEVEL', cur_lv)
		ref_transcend_bg:SetUserValue('GOAL_LEVEL', cur_lv)

		GODDESS_MGR_REFORGE_TRANSCEND_MAT_UPDATE(frame, 1)
	end
end

function GODDESS_MGR_REFORGE_TRANSCEND_EXEC(parent, btn)
	local frame = parent:GetTopParentFrame()
	local ref_slot = GET_CHILD_RECURSIVELY(frame, 'ref_slot')
	local mat_slot = GET_CHILD_RECURSIVELY(frame, 'ref_transcend_slot_material')

	local equip_guid = ref_slot:GetUserValue('ITEM_GUID')
	if equip_guid == 'None' then
		ui.SysMsg(ClMsg('NotExistTargetItem'))
		return
	end
	
	local inv_item = session.GetInvItemByGuid(equip_guid)
	if inv_item == nil then
		ui.SysMsg(ClMsg('NotExistTargetItem'))
		return
	end

	local item_obj = GetIES(inv_item:GetObject())

	if TryGetProp(item_obj, "Transcend", 0) == 10 then
		ui.SysMsg(ClMsg('MaxTranscend'))
		return
	end

	if item_goddess_transcend.is_able_to_transcend(item_obj) ~= 'YES' then
		ui.SysMsg(ClMsg('ThisItemIsNotAbleToTranscend'))
		return
	end

	local need_count = mat_slot:GetUserIValue('MAT_NEED_COUNT')
	if need_count <= 0 then
		ui.SysMsg(ClMsg('NotEnoughRecipe'))
		return
	end

	local yesscp = '_GODDESS_MGR_REFORGE_TRANSCEND_EXEC()'
	local msgbox = ui.MsgBox(ScpArgMsg('DoGoddessTranscend', 'count', need_count), yesscp, 'ENABLE_CONTROL_WITH_UI_HOLD(false)')
	SET_MODAL_MSGBOX(msgbox)
end

function _GODDESS_MGR_REFORGE_TRANSCEND_EXEC()
	local frame = ui.GetFrame('goddess_equip_manager')
	if frame == nil then return end
	
	local slot = GET_CHILD_RECURSIVELY(frame, 'ref_slot')
	local ref_transcend_bg = GET_CHILD_RECURSIVELY(frame, 'ref_transcend_bg')
	local mat_slot = GET_CHILD_RECURSIVELY(frame, 'ref_transcend_slot_material')

	frame:SetUserValue('ONANIPICTURE_PLAY', 1)

	ui.SetHoldUI(true)

	imcSound.PlaySoundEvent(frame:GetUserConfig('TRANS_EVENT_EXEC'))

	mat_slot:StopActiveUIEffect()
	
	session.ResetItemList()

	local icon = slot:GetIcon()
	if icon == nil or icon:GetInfo() == nil then
		ui.SysMsg(ClMsg('NotExistTargetItem'))
		return
	end

	local guid = slot:GetUserValue('ITEM_GUID')
	session.AddItemID(guid, 1)
	
	local mat_guid = mat_slot:GetUserValue('ITEM_GUID')
	local mat_count = mat_slot:GetUserIValue('MAT_NEED_COUNT')
	if mat_guid == 'None' then return end
	
	session.AddItemID(mat_guid, mat_count)
	
	local result_list = session.GetItemIDList()
	
	local goal_lv = ref_transcend_bg:GetUserValue('GOAL_LEVEL')
	local arg_list = NewStringList()
	arg_list:Add(goal_lv)

	item.DialogTransaction('GODDESS_TRANSCEND', result_list, '', arg_list)

	imcSound.PlaySoundEvent(frame:GetUserConfig('TRANS_CAST'))

	local ref_transcend_do = GET_CHILD_RECURSIVELY(frame, 'ref_transcend_do')
	ref_transcend_do:SetEnable(0)
end

function ON_SUCCESS_REFORGE_TRANSCEND_EXEC(frame, msg, arg_str, arg_num)
	ReserveScript('GODDESS_TRANSCEND_EFFECT()', 0.3)
end

function ON_FAILED_REFORGE_TRANSCEND_EXEC(frame, msg, arg_str, arg_num)
	ui.SetHoldUI(false)

	local ref_transcend_do = GET_CHILD_RECURSIVELY(frame, 'ref_transcend_do')
	ref_transcend_do:SetEnable(1)
end
-- 재련 - 초월 끝

-- 재련 - 진화
function GODDESS_MGR_REFORGE_EVOLUTION_CLEAR(frame)
	local ref_evolution_do = GET_CHILD_RECURSIVELY(frame, 'ref_evolution_do')
	ref_evolution_do:SetEnable(1)
	ref_evolution_do:ShowWindow(1)
	
	local ref_evolution_send_ok = GET_CHILD_RECURSIVELY(frame, 'ref_evolution_send_ok')
	ref_evolution_send_ok:ShowWindow(0)

	GODDESS_MGR_REFORGE_EVOLUTION_UPDATE(frame)
end

function GODDESS_MGR_REFORGE_EVOLUTION_OPEN(frame)
	GODDESS_MGR_REFORGE_EVOLUTION_CLEAR(frame)
end

local function GODDESS_EVOLUTION_MAT_SLOT_UPDATE(frame, inv_item, item_obj)
	local use_lv = TryGetProp(item_obj, 'UseLv', 0)

	local acc = GetMyAccountObj()
	if acc == nil then return end

	local mat_list = GET_EVOLVE_MAT_LIST(use_lv)
	if mat_list == nil then return end
	
	local index = 1
	for _name, _count in pairs(mat_list) do
		local mat_slot = GET_CHILD_RECURSIVELY(frame, 'evolve_mat_slot_' .. index)
		local mat_cls = GetClass('Item', _name)
		if IS_ACCOUNT_COIN(_name) == true then
			mat_cls = GetClass('accountprop_inventory_list', _name)
		end
		
		if mat_cls ~= nil and _count > 0 then
			SET_SLOT_COUNT_TEXT(mat_slot, _count)
			mat_slot:SetUserValue('MAT_NAME', _name)
			mat_slot:SetUserValue('MAT_COUNT', _count)
			local icon = imcSlot:SetImage(mat_slot, TryGetProp(mat_cls, 'Icon', 'None'))
			
			if IS_EVOLVED_ITEM(item_obj) == true then
				icon:SetColorTone('FFFF0000')
				mat_slot:SetUserValue('MAT_REG', 'NO')
			else
				local inv_mat_count = '0'
				if IS_ACCOUNT_COIN(_name) == true then
					inv_mat_count = TryGetProp(acc, _name, '0')		
					local dummy_coin_name = 'dummy_'.._name
					local mat_cls = GetClass('Item', dummy_coin_name)	
					icon:SetTooltipType('texthelp');
					icon:SetTooltipArg(TryGetProp(mat_cls, 'Name', 'None'));
					icon:SetTooltipOverlap(1)
				else
					local inv_mat_item = session.GetInvItemByName(_name)
					if inv_mat_item ~= nil then
						inv_mat_count = tostring(inv_mat_item.count)
					end
					icon:SetTooltipType('wholeitem');
					local mat_cls = GetClass('Item', _name)
					icon:SetTooltipArg("", TryGetProp(mat_cls, "ClassID", 0), 0);
					icon:SetTooltipOverlap(1)
				end
				
				if inv_mat_count == 'None' then
					inv_mat_count = '0'
				end

				if tonumber(inv_mat_count) >= tonumber(_count) then
					icon:SetColorTone('FFFFFFFF')
					mat_slot:SetUserValue('MAT_REG', 'YES')
				else
					icon:SetColorTone('FFFF0000')
					mat_slot:SetUserValue('MAT_REG', 'NO')
				end
			end
		end

		index = index + 1
	end
end

function GODDESS_MGR_REFORGE_EVOLUTION_UPDATE(frame)
	local ref_slot = GET_CHILD_RECURSIVELY(frame, 'ref_slot')	
	local slot_pic = GET_CHILD_RECURSIVELY(frame, 'ref_slot_bg_image')
	local ref_item_name = GET_CHILD_RECURSIVELY(frame, 'ref_item_name')
	local ref_item_text = GET_CHILD_RECURSIVELY(frame, 'ref_item_text')
	local ref_evolution_do = GET_CHILD_RECURSIVELY(frame, 'ref_evolution_do')
	local target_slot = GET_CHILD_RECURSIVELY(frame, 'evolve_target_slot')

	local equip_guid = ref_slot:GetUserValue('ITEM_GUID')
	if equip_guid == 'None' then
		ref_evolution_do:SetEnable(0)
		target_slot:ClearIcon()
		for i = 1, MAX_EVOLVE_MAT_COUNT do
			local mat_slot = GET_CHILD_RECURSIVELY(frame, 'evolve_mat_slot_' .. i)
			mat_slot:ClearIcon()
			SET_SLOT_COUNT_TEXT(mat_slot, '')
			mat_slot:SetUserValue('MAT_NAME', 'None')
			mat_slot:SetUserValue('MAT_COUNT', 0)
		end
	else
		local inv_item = session.GetInvItemByGuid(equip_guid)
		if inv_item == nil then return end

		local obj = GetIES(inv_item:GetObject())
		if IS_EVOLVED_ITEM(obj) == true or IS_WEAPON_TYPE(TryGetProp(obj, "ClassType", "None")) == false then
			ui.SysMsg(ClMsg('CantEvolvedEquip'))
			ref_evolution_do:SetEnable(0)
			target_slot:ClearIcon()
			for i = 1, MAX_EVOLVE_MAT_COUNT do
				local mat_slot = GET_CHILD_RECURSIVELY(frame, 'evolve_mat_slot_' .. i)
				mat_slot:ClearIcon()
				SET_SLOT_COUNT_TEXT(mat_slot, '')
				mat_slot:SetUserValue('MAT_NAME', 'None')
				mat_slot:SetUserValue('MAT_COUNT', 0)
			end
			ref_slot:ClearIcon()
			ref_slot:SetUserValue('ITEM_GUID', 'None')
			slot_pic:ShowWindow(1)
			ref_item_name:ShowWindow(0)
			ref_item_text:ShowWindow(1)
			local ref_item_reinf_text = GET_CHILD_RECURSIVELY(frame, 'ref_item_reinf_text')
			ref_item_reinf_text:SetTextByKey('value', 0)	
		else
			SET_SLOT_ITEM(target_slot, inv_item)

			local icon = target_slot:GetIcon()
			local item_obj = GetIES(inv_item:GetObject())
			if IS_EVOLVED_ITEM(item_obj) == false then
				icon:SetColorTone('FFFFFFFF')
				ref_evolution_do:SetEnable(1)
				GODDESS_EVOLUTION_MAT_SLOT_UPDATE(frame, inv_item, item_obj)
			end
		end
	end
end

function GODDESS_MGR_REFORGE_EVOLUTION_EXEC(parent, btn)
	local frame = parent:GetTopParentFrame()
	local ref_slot = GET_CHILD_RECURSIVELY(frame, 'ref_slot')
	local guid = ref_slot:GetUserValue('ITEM_GUID')
	if guid == 'None' then return end

	local inv_item = session.GetInvItemByGuid(guid)
	if inv_item == nil then return end

	local itemObj = GetIES(inv_item:GetObject())
	if TryGetProp(itemObj, "Transcend", 0) < 10 and TryGetProp(itemObj, 'UseLv', 0) <= 460 then
		ui.SysMsg(ClMsg('TargetItemIsNot10Transcend'))
		return
	end

	if inv_item.isLockState == true then
		ui.SysMsg(ClMsg('MaterialItemIsLock'))
		return
	end

	for i = 1, MAX_EVOLVE_MAT_COUNT do
		local mat_slot = GET_CHILD_RECURSIVELY(frame, 'evolve_mat_slot_' .. i)
		local enable = mat_slot:GetUserValue('MAT_REG')
		if enable == 'NO' then
			ui.SysMsg(ClMsg('NotEnoughMaterial'))
			return
		end
	end

	local yesscp = '_GODDESS_MGR_REFORGE_EVOLUTION_EXEC()'
	local msgbox = ui.MsgBox(ClMsg('ReallyDoEvolution'), yesscp, '')
	SET_MODAL_MSGBOX(msgbox)
end

function _GODDESS_MGR_REFORGE_EVOLUTION_EXEC()
	local frame = ui.GetFrame('goddess_equip_manager')
	local ref_slot = GET_CHILD_RECURSIVELY(frame, 'ref_slot')
	local guid = ref_slot:GetUserValue('ITEM_GUID')
	if guid == 'None' then return end

	local inv_item = session.GetInvItemByGuid(guid)
	if inv_item == nil then return end

	if inv_item.isLockState == true then
		ui.SysMsg(ClMsg('MaterialItemIsLock'))
		return
	end

	local resulteffect_slot = GET_CHILD_RECURSIVELY(frame, "resulteffect_slot");
	local posX, posY = GET_SCREEN_XY(resulteffect_slot);
	local effectName = frame:GetUserConfig("EVOLVE_EFFECT");
	local effectName2 = frame:GetUserConfig("EVOLVE_SUCCESS")
	movie.PlayUIEffect(effectName, posX, posY, tonumber(frame:GetUserConfig("EVOLVE_EFFECT_SCALE")))
	movie.PlayUIEffect(effectName2, posX, posY, tonumber(frame:GetUserConfig("EVOLVE_SUCCESS_SCALE")))

	pc.ReqExecuteTx_Item('GODDESS_EVOLUTION', guid, '')

	local ref_evolution_do = GET_CHILD_RECURSIVELY(frame, 'ref_evolution_do')
	ref_evolution_do:SetEnable(0)
end

function ON_SUCCESS_REFORGE_EVOLUTION_EXEC(frame, msg, arg_str, arg_num)
	local ref_slot = GET_CHILD_RECURSIVELY(frame, 'ref_slot')
	ref_slot:SetUserValue('ITEM_GUID', 'None')
	local ref_evolution_do = GET_CHILD_RECURSIVELY(frame, 'ref_evolution_do')
	ref_evolution_do:ShowWindow(0)
	
	local ref_evolution_send_ok = GET_CHILD_RECURSIVELY(frame, 'ref_evolution_send_ok')
	ref_evolution_send_ok:ShowWindow(1)
	GODDESS_MGR_REFORGE_EVOLUTION_UPDATE(frame)
end

function GODDESS_MGR_EVOLUTION_CLEAR_BTN(parent, btn)
	local frame = parent:GetTopParentFrame()
	GODDESS_MGR_REFORGE_EVOLUTION_CLEAR(frame)
end
-- 재련 - 진화 끝
-- 재련 끝

-- 각인
function GODDESS_MGR_RANDOMOPTION_CLEAR(frame)
	local randomoption_tab = GET_CHILD_RECURSIVELY(frame, 'randomoption_tab')
	randomoption_tab:SelectTab(0)
	GODDESS_MGR_RANDOMOPTION_PRESET_UPDATE(frame)
end

function CLEAR_GODDESS_ICOR_TEXT(frame)	
	local text = GET_CHILD_RECURSIVELY(frame, 'goddess_icor_spot_text')
	if text ~= nil then
		text:ShowWindow(0)
	end
	local list = GET_CHILD_RECURSIVELY(frame, 'goddess_icor_spot_list')
	if list ~= nil then
		list:ShowWindow(0)
	end
end

function SHOW_GODDESS_ICOR_TEXT(frame)
	local text = GET_CHILD_RECURSIVELY(frame, 'goddess_icor_spot_text')
	if text ~= nil then
		text:ShowWindow(1)
	end
	local list = GET_CHILD_RECURSIVELY(frame, 'goddess_icor_spot_list')
	if list ~= nil then
		list:ShowWindow(1)
	end
end

local function _GODDESS_MGR_RANDOMOPTION_GET_PAGE_NAME(index)
	local pc_etc = GetMyEtcObject()
	local acc = GetMyAccountObj()
	if pc_etc == nil or acc == nil then return nil end

	local page_max = GET_MAX_ENGARVE_SLOT_COUNT(acc)
	if index > page_max then return nil end

	local page_name = TryGetProp(pc_etc, 'RandomOptionPresetName_' .. index, 'None')
	if page_name == 'None' then
		return ScpArgMsg('EngravePageNumber{index}', 'index', index)
	else
		return page_name
	end
end

function _GODDESS_MGR_MAKE_RANDOM_OPTION_TEXT(gBox, item_obj, option_list)
	local tooltip_equip_property_CSet = gBox:CreateOrGetControlSet('tooltip_equip_property_narrow', 'tooltip_equip_property_narrow', 0, 0)
	local labelline = GET_CHILD_RECURSIVELY(tooltip_equip_property_CSet, 'labelline')
	labelline:ShowWindow(0)
	local property_gbox = GET_CHILD(tooltip_equip_property_CSet, 'property_gbox', 'ui::CGroupBox')
	
	tooltip_equip_property_CSet:Resize(gBox:GetWidth(), tooltip_equip_property_CSet:GetHeight())
	property_gbox:Resize(gBox:GetWidth() + 5, property_gbox:GetHeight())

	local inner_yPos = 0
	if item_obj == nil then
		if option_list == nil then
			return
		end

		item_obj = option_list
	end

	for i = 1 , MAX_RANDOM_OPTION_COUNT do
		local group_name = 'RandomOptionGroup_'..i
		local prop_name = 'RandomOption_'..i
		local prop_value = 'RandomOptionValue_'..i
		local clmsg = 'None'
		
		if item_obj[group_name] == 'ATK' then
			clmsg = 'ItemRandomOptionGroupATK'
		elseif item_obj[group_name] == 'DEF' then
			clmsg = 'ItemRandomOptionGroupDEF'
		elseif item_obj[group_name] == 'UTIL_WEAPON' then
			clmsg = 'ItemRandomOptionGroupUTIL'
		elseif item_obj[group_name] == 'UTIL_ARMOR' then
			clmsg = 'ItemRandomOptionGroupUTIL'
		elseif item_obj[group_name] == 'UTIL_SHILED' then
			clmsg = 'ItemRandomOptionGroupUTIL'
		elseif item_obj[group_name] == 'STAT' then
			clmsg = 'ItemRandomOptionGroupSTAT'
		elseif item_obj[group_name] == 'SPECIAL' then
			clmsg = 'ItemRandomOptionGroupSPECIAL'			
		end

		local _value = item_obj[prop_value]
		local _name = item_obj[prop_name]		
		if _value ~= nil and _value ~= 0 and _name ~= nil and _name ~= 'None' then
			local font = ''
			local font_end = ''
			if option_list ~= nil then				
				if option_list['is_goddess_option'] >= 1 then
					font = '{@st47}{s15}{#00EEEE}'
					font_end = '{/}{/}{/}'
				end
			end
			local op_name = string.format('%s %s', ClMsg(clmsg), font..ScpArgMsg(item_obj[prop_name]) .. font_end )
			local str_info = ABILITY_DESC_NO_PLUS(op_name, item_obj[prop_value], 0)
			inner_yPos = ADD_ITEM_PROPERTY_TEXT_NARROW(property_gbox, str_info, 0, inner_yPos)
		end
	end

	tooltip_equip_property_CSet:Resize(tooltip_equip_property_CSet:GetWidth(),tooltip_equip_property_CSet:GetHeight() + property_gbox:GetHeight() + property_gbox:GetY())
	gBox:Resize(gBox:GetWidth(), tooltip_equip_property_CSet:GetHeight())
end

function GODDESS_MGR_PREMIUM_REMAIN_TIME_UPDATE(ctrl)	
    local elapsed_sec = imcTime.GetAppTime() - ctrl:GetUserIValue('STARTSEC')
    local start_sec = ctrl:GetUserIValue('REMAINSEC')
    start_sec = start_sec - elapsed_sec
    if 0 > start_sec then
        ctrl:SetTextByKey('value', '')
        return 0
	end
	
    local time_str = GET_TIME_TXT(start_sec)
	ctrl:SetTextByKey('value', time_str)
	
    return 1
end

function GODDESS_MGR_RANDOMOPTION_OPEN(frame)
	GODDESS_MGR_RANDOMOPTION_CLEAR(frame)
	GODDESS_MGR_RANDOMOPTION_ENGRAVE_ICOR_OPEN(frame)

	local acc = GetMyAccountObj()
	if acc == nil then return end

	local premium_remaintime = GET_CHILD_RECURSIVELY(frame, 'premium_remaintime')
	local remain_time = GET_REMAIN_SECOND_ENGRAVE_SLOT_EXTENSION_TIME(acc)
	if 0 < remain_time then
		premium_remaintime:SetUserValue('REMAINSEC', remain_time)
		premium_remaintime:SetUserValue('STARTSEC', imcTime.GetAppTime())
		premium_remaintime:RunUpdateScript('GODDESS_MGR_PREMIUM_REMAIN_TIME_UPDATE')
		premium_remaintime:ShowWindow(1)
	else
		premium_remaintime:StopUpdateScript('GODDESS_MGR_PREMIUM_REMAIN_TIME_UPDATE')
		premium_remaintime:ShowWindow(0)
	end
end

function GODDESS_MGR_RANDOMOPTION_PRESET_SELECT(parent, ctrl)
	local frame = parent:GetTopParentFrame()
	local index = ctrl:GetSelItemKey()
	local randomoption_bg = GET_CHILD_RECURSIVELY(frame, 'randomoption_bg')
	randomoption_bg:SetUserValue('PRESET_INDEX', index)

	local randomoption_tab = GET_CHILD_RECURSIVELY(frame, 'randomoption_tab')
	local index = randomoption_tab:GetSelectItemIndex()
	if index == 0 then
		GODDESS_MGR_RANDOMOPTION_ENGRAVE_ICOR_UPDATE(frame) -- 각인 저장(아이커)
	elseif index == 1 then
		GODDESS_MGR_RANDOMOPTION_APPLY_OPEN(frame)		-- 각인 부여
	elseif index == 2 then
		GODDESS_MGR_RANDOMOPTION_ENGRAVE_OPEN(frame) 	-- 각인 저장(옛날)
	end
end

function GODDESS_MGR_RANDOMOPTION_PRESET_UPDATE(frame)
	local rand_preset_list = GET_CHILD_RECURSIVELY(frame, 'rand_preset_list')
	rand_preset_list:ClearItems()
	
	local acc_obj = GetMyAccountObj()
	if acc_obj == nil then return end

	local max_page = GET_MAX_ENGARVE_SLOT_COUNT(acc_obj)
	for i = 1, max_page do
		local page_name = _GODDESS_MGR_RANDOMOPTION_GET_PAGE_NAME(i)
		rand_preset_list:AddItem(tostring(i), page_name)
	end

	rand_preset_list:SelectItemByKey(0)
	GODDESS_MGR_RANDOMOPTION_PRESET_SELECT(frame, rand_preset_list)
end

function GODDESS_MGR_RANDOMOPTION_TAB_CHANGE(parent, tab)
	local frame = parent:GetTopParentFrame()

	local index = tab:GetSelectItemIndex()
	if index == 0 then
		CLEAR_GODDESS_ICOR_TEXT(frame)
		GODDESS_MGR_RANDOMOPTION_ENGRAVE_ICOR_OPEN(frame)
	elseif index == 1 then
		GODDESS_MGR_RANDOMOPTION_APPLY_OPEN(frame)
	elseif index == 2 then
		GODDESS_MGR_RANDOMOPTION_ENGRAVE_OPEN(frame)		 -- 각인 저장(옛날)
	end
end

function _CHECK_RANDOMOPTION_CHANGE_NAME_BTN()
	local frame = ui.GetFrame('goddess_equip_manager')
	local btn = GET_CHILD_RECURSIVELY(frame, 'change_preset_name')
	btn:SetEnable(1)
end

function _DISABLE_RANDOMOPTION_CHANGE_NAME_BTN()
	local frame = ui.GetFrame('goddess_equip_manager')
	local btn = GET_CHILD_RECURSIVELY(frame, 'change_preset_name')
	if btn ~= nil then
		ReserveScript('_CHECK_RANDOMOPTION_CHANGE_NAME_BTN()', 1)
    	btn:SetEnable(0)
	end
end

function GODDESS_MGR_RANDOMOPTION_CHANGE_NAME(parent, ctrl)
	local frame = parent:GetTopParentFrame()
	local randomoption_bg = GET_CHILD_RECURSIVELY(frame, 'randomoption_bg')
	local index = randomoption_bg:GetUserIValue('PRESET_INDEX')
	local preset_name = _GODDESS_MGR_RANDOMOPTION_GET_PAGE_NAME(index)
    local newframe = ui.GetFrame('inputstring')
    newframe:SetUserValue('InputType', 'InputNameForChange')
	INPUT_STRING_BOX(ClMsg('ChangeAncientDefenseDeckTabName'), 'GODDESS_MGR_RANDOMOPTION_CHANGE_NAME_EXEC', preset_name, 0, 16)
end

function GODDESS_MGR_RANDOMOPTION_CHANGE_NAME_EXEC(input_frame, ctrl)
	if ctrl:GetName() == 'inputstr' then
        input_frame = ctrl
	end

    local new_name = GET_INPUT_STRING_TXT(input_frame)
	
	local frame = ui.GetFrame('goddess_equip_manager')
	local randomoption_bg = GET_CHILD_RECURSIVELY(frame, 'randomoption_bg')
	local index = randomoption_bg:GetUserIValue('PRESET_INDEX')
	local preset_name = _GODDESS_MGR_RANDOMOPTION_GET_PAGE_NAME(index)
	if new_name == preset_name then
		ui.SysMsg(ClMsg('AlreadyorImpossibleName'))
		return
	end

	local name_str = TRIM_STRING_WITH_SPACING(new_name)
	if name_str == '' then
		ui.SysMsg(ClMsg('InvalidStringOrUnderMinLen'))
		return
	end

	local arg_str = index .. '/' .. new_name

	pc.ReqExecuteTx('SCR_ICOR_PRESET_CHANGE_NAME', arg_str)

	_DISABLE_RANDOMOPTION_CHANGE_NAME_BTN()

	input_frame:ShowWindow(0)
end

function ON_SUCCESS_RANDOMOPTION_CHANGE_NAME(frame, msg, arg_str, arg_num)
	GODDESS_MGR_RANDOMOPTION_PRESET_UPDATE(frame)
end

-- 각인 - 저장
function GODDESS_MGR_RANDOMOPTION_ENGRAVE_CLEAR(frame)
	local rand_ok_engrave = GET_CHILD_RECURSIVELY(frame, 'rand_ok_engrave')
	rand_ok_engrave:ShowWindow(0)

	local rand_do_engrave = GET_CHILD_RECURSIVELY(frame, 'rand_do_engrave')
	rand_do_engrave:ShowWindow(1)

	local rand_engrave_slot = GET_CHILD_RECURSIVELY(frame, 'rand_engrave_slot')
	rand_engrave_slot:ClearIcon()

	local rand_item_name = GET_CHILD_RECURSIVELY(frame, 'rand_item_name')
	rand_item_name:ShowWindow(0)
	rand_item_name:SetTextByKey('name', '')

	local rand_item_text = GET_CHILD_RECURSIVELY(frame, 'rand_item_text')
	rand_item_text:ShowWindow(1)

	local rand_equip_list = GET_CHILD_RECURSIVELY(frame, 'rand_equip_list')
	rand_equip_list:SetMargin(30, rand_item_text:GetMargin().top + rand_item_text:GetHeight() + 10, 0, 0)

	local rand_engrave_current_inner = GET_CHILD_RECURSIVELY(frame, 'rand_engrave_current_inner')
	rand_engrave_current_inner:RemoveChild('tooltip_equip_property_narrow')

	local rand_engrave_before_inner = GET_CHILD_RECURSIVELY(frame, 'rand_engrave_before_inner')
	rand_engrave_before_inner:RemoveChild('tooltip_equip_property_narrow')

	GODDESS_MGR_RANDOMOPTION_ENGRAVE_UPDATE(frame)	
end

function GODDESS_MGR_RANDOMOPTION_ENGRAVE_SET_MATERIAL(frame)
	local rand_mat_list = GET_CHILD_RECURSIVELY(frame, 'rand_mat_list', 'ui::CSlotSet')
	rand_mat_list:ClearIconAll()

	local inv_item_list = session.GetInvItemList()
	FOR_EACH_INVENTORY(inv_item_list, function(inv_item_list, inv_item, slotset)
		local frame = slotset:GetTopParentFrame()
		local item_slot = GET_CHILD_RECURSIVELY(frame, 'rand_engrave_slot')
		local use_lv = item_slot:GetUserIValue('ITEM_USE_LEVEL')
		local obj = GetIES(inv_item:GetObject())
		local flag, rate = IS_ENGRAVE_MATERIAL_ITEM(obj, use_lv)
		if flag == true then
			local slotindex = imcSlot:GetEmptySlotIndex(slotset)
			local slot = slotset:GetSlotByIndex(slotindex)
			local icon = CreateIcon(slot)
			icon:Set(obj.Icon, 'Item', inv_item.type, slotindex, inv_item:GetIESID(), inv_item.count)
			slot:SetUserValue('ITEM_GUID', inv_item:GetIESID())
			slot:SetUserValue('ADD_RATE', rate)
			slot:SetMaxSelectCount(inv_item.count)
			local class = GetClassByType('Item', inv_item.type)
			SET_SLOT_ITEM_TEXT_USE_INVCOUNT(slot, inv_item, obj, inv_item.count)
			ICON_SET_INVENTORY_TOOLTIP(icon, inv_item, 'poisonpot', class)
		end
	end, false, rand_mat_list)

	GODDESS_MGR_RANDOMOPTION_ENGRAVE_MAT_UPDATE(frame)
end

function GODDESS_MGR_RANDOMOPTION_ENGRAVE_MAT_UPDATE(frame)
	local rand_engrave_slot = GET_CHILD_RECURSIVELY(frame, 'rand_engrave_slot')
	local def_rate = rand_engrave_slot:GetUserIValue('DEFAULT_RATE')

	local OFFSET_Y = 10
	local HEIGHT = 65
	local add_rate = 0
	local slotSet = GET_CHILD_RECURSIVELY(frame, 'rand_mat_list', 'ui::CSlotSet')
	local gbox = GET_CHILD_RECURSIVELY(frame, 'rand_mat_info_bg')
	gbox:RemoveAllChild()
	for i = 0, slotSet:GetSlotCount() - 1 do
		local slot = slotSet:GetSlotByIndex(i)
		local rate = tonumber(slot:GetUserValue('ADD_RATE'))
		if rate == nil then
			break
		end
		local cnt = slot:GetSelectCount()
		if cnt > 0 then
			add_rate = add_rate + (rate * cnt)
			if def_rate + add_rate > 100 then
				local adjust_cnt = math.ceil((def_rate + add_rate - 100) / rate)
				cnt = cnt - adjust_cnt
				slot:SetSelectCount(cnt)
				add_rate = add_rate - (rate * adjust_cnt)
			end
			
			if cnt > 0 then
				local info = slot:GetIcon():GetInfo()
				local ctrlSet = gbox:CreateOrGetControlSet('item_point_price', 'PRICE' .. info.type .. i, 10, OFFSET_Y)
				
				local itemSlot = GET_CHILD(ctrlSet, 'itemSlot')
				local icon = CreateIcon(itemSlot)
				icon:SetImage(info:GetImageName())
				
				local itemCount = GET_CHILD(itemSlot, 'itemCount')
				local cntText = string.format('{#ffe400}{ds}{ol}{b}{s18}%d', cnt)
				itemCount:SetText(cntText)
				
				local itemPrice = GET_CHILD(ctrlSet, 'itemPrice')
				local text = string.format('{s18}{ol}{b} X %d%% ={/} {#ec0000}+%d%%{/}{/}{/}', rate, rate * cnt)
				itemPrice:SetText(text)
				
				OFFSET_Y = OFFSET_Y + HEIGHT
			else
				slot:Select(0)
			end
		end
	end
	
	local total_rate = def_rate + add_rate

	local rand_probability_text = GET_CHILD_RECURSIVELY(frame, 'rand_probability_text')
	rand_probability_text:SetTextByKey('total', total_rate)
	rand_probability_text:SetTextByKey('default', def_rate)
	rand_probability_text:SetTextByKey('add', add_rate)

	local rand_do_engrave = GET_CHILD_RECURSIVELY(frame, 'rand_do_engrave')
	if total_rate <= 0 then
		rand_do_engrave:SetEnable(0)
	else
		rand_do_engrave:SetEnable(1)
	end
end

function GODDESS_MGR_RANDOMOPTION_ENGRAVE_SPOT_SELECT(parent, ctrl)
	local frame = parent:GetTopParentFrame()
	local spot = ctrl:GetSelItemKey()	
	local inv_item = session.GetEquipItemBySpot(item.GetEquipSpotNum(spot))
	
	if inv_item ~= nil then
		local item_obj = GetIES(inv_item:GetObject())
		if IS_NO_EQUIPITEM(item_obj) == 0 then
			GODDESS_MGR_RANDOMOPTION_ENGRAVE_REG_ITEM(frame, inv_item, item_obj, spot)
		end
	end

	GODDESS_MGR_RANDOMOPTION_ENGRAVE_SET_MATERIAL(frame)
end

function SCR_LBTNDOWN_GODDESS_MGR_RANDOMOPTION_MAT(slotset, slot)
	local frame = slotset:GetTopParentFrame()
	ui.EnableSlotMultiSelect(1)
	GODDESS_MGR_RANDOMOPTION_ENGRAVE_MAT_UPDATE(frame)
end

function GODDESS_MGR_RANDOMOPTION_ENGRAVE_OPEN(frame) -- 각인 저장(옛날)
	local rand_equip_list = GET_CHILD_RECURSIVELY(frame, 'rand_equip_list')
	rand_equip_list:SelectItemByKey(0)
	GODDESS_MGR_RANDOMOPTION_ENGRAVE_SET_SPOT(frame)
	GODDESS_MGR_RANDOMOPTION_ENGRAVE_CLEAR(frame)
	INVENTORY_SET_CUSTOM_RBTNDOWN('None')

	local checkall = GET_CHILD_RECURSIVELY(frame, 'checkall')
	checkall:ShowWindow(0)
end

function GODDESS_MGR_RANDOMOPTION_ENGRAVE_SET_SPOT(frame) -- 각인 저장(옛날)	
	local rand_equip_list = GET_CHILD_RECURSIVELY(frame, 'rand_equip_list')
	rand_equip_list:ClearItems()

	for i = 1, #managed_slot_list do
		local slot_info = managed_slot_list[i]
		local inv_item = session.GetEquipItemBySpot(item.GetEquipSpotNum(slot_info.SlotName))
		local item_obj = GetIES(inv_item:GetObject())

		if IS_NO_EQUIPITEM(item_obj) == 0 and IS_ENABLE_TO_ENGARVE(item_obj, 2) == true then
			rand_equip_list:AddItem(slot_info.SlotName, ClMsg(slot_info.ClMsg))
		end
	end
end

function GODDESS_MGR_RANDOMOPTION_ENGRAVE_UPDATE(frame)	
	local rand_equip_list = GET_CHILD_RECURSIVELY(frame, 'rand_equip_list')	
	GODDESS_MGR_RANDOMOPTION_ENGRAVE_SPOT_SELECT(frame, rand_equip_list)
end

function GODDESS_MGR_RANDOMOPTION_ENGRAVE_REG_ITEM(frame, inv_item, item_obj, spot)	 -- 각인 저장(옛날)	
	if inv_item == nil then return end

	local etc = GetMyEtcObject()
	if etc == nil then return end

	local enable, def_rate = IS_ENABLE_TO_ENGARVE(item_obj, 2)
	if enable == false then
		return
	end

	local slot = GET_CHILD_RECURSIVELY(frame, 'rand_engrave_slot')
	SET_SLOT_ITEM(slot, inv_item)
	slot:SetUserValue('ITEM_GUID', inv_item:GetIESID())
	slot:SetUserValue('ITEM_USE_LEVEL', TryGetProp(item_obj, 'UseLv', 0))
	slot:SetUserValue('DEFAULT_RATE', def_rate)
	slot:SetUserValue('EQUIP_SPOT', spot)

	local rand_item_text = GET_CHILD_RECURSIVELY(frame, 'rand_item_text')
	rand_item_text:ShowWindow(0)

	local rand_engrave_slot_pic = GET_CHILD_RECURSIVELY(frame, 'rand_engrave_slot_pic')
	rand_engrave_slot_pic:ShowWindow(0)

	local rand_item_name = GET_CHILD_RECURSIVELY(frame, 'rand_item_name')
	rand_item_name:SetTextByKey('name', dic.getTranslatedStr(TryGetProp(item_obj, 'Name', 'NONE')))
	rand_item_name:ShowWindow(1)

	local rand_equip_list = GET_CHILD_RECURSIVELY(frame, 'rand_equip_list')
	rand_equip_list:SetMargin(30, rand_item_name:GetMargin().top + rand_item_name:GetHeight() + 10, 0, 0)

	local rand_engrave_current_inner = GET_CHILD_RECURSIVELY(frame, 'rand_engrave_current_inner')
	rand_engrave_current_inner:RemoveChild('tooltip_equip_property_narrow')
	_GODDESS_MGR_MAKE_RANDOM_OPTION_TEXT(rand_engrave_current_inner, item_obj)

	local randomoption_bg = GET_CHILD_RECURSIVELY(frame, 'randomoption_bg')
	local index = randomoption_bg:GetUserValue('PRESET_INDEX')
	local before_option = GET_ENGRAVED_OPTION_BY_INDEX_SPOT(etc, index, spot)
	if before_option ~= nil then
		slot:SetUserValue('BEFORE_OPTION_EXIST', 1)
	else
		slot:SetUserValue('BEFORE_OPTION_EXIST', 0)
	end
	local rand_engrave_before_inner = GET_CHILD_RECURSIVELY(frame, 'rand_engrave_before_inner')
	rand_engrave_before_inner:RemoveChild('tooltip_equip_property_narrow')
	_GODDESS_MGR_MAKE_RANDOM_OPTION_TEXT(rand_engrave_before_inner, nil, before_option)

	local item_dic = GET_ITEM_RANDOMOPTION_DIC(item_obj)
	if COMPARE_ITEM_OPTION_TO_ENGRAVED_OPTION(item_dic, before_option) == true then
		slot:SetUserValue('IS_SAME_OPTION', 1)
	else
		slot:SetUserValue('IS_SAME_OPTION', 0)
	end
end

function GODDESS_MGR_RANDOMOPTION_ENGRAVE_EXEC(parent, btn)
	local frame = parent:GetTopParentFrame()

	local rand_engrave_slot = GET_CHILD_RECURSIVELY(frame, 'rand_engrave_slot')
	if rand_engrave_slot:GetUserIValue('IS_SAME_OPTION') == 1 then
		ui.SysMsg(ClMsg('SameOptionEngravedAlready'))
		return
	end

	local rand_mat_list = GET_CHILD_RECURSIVELY(frame, 'rand_mat_list')
	local selected_cnt = rand_mat_list:GetSelectedSlotCount()
	if selected_cnt == 0 then
		return
	end

	local yesscp = string.format('_GODDESS_MGR_RANDOMOPTION_ENGRAVE_EXEC()')
	local before_option = rand_engrave_slot:GetUserIValue('BEFORE_OPTION_EXIST')
	if before_option == 1 then
		WARNINGMSGBOX_EX_ENGRAVE_OPEN()
	else
		local msgbox = ui.MsgBox(ClMsg('TryRandomOptionPresetEngrave'), yesscp, 'None')
		SET_MODAL_MSGBOX(msgbox)
	end
end

function _GODDESS_MGR_RANDOMOPTION_ENGRAVE_EXEC()
	local frame = ui.GetFrame('goddess_equip_manager')
	if frame == nil then return end

	session.ResetItemList()

	local rand_engrave_slot = GET_CHILD_RECURSIVELY(frame, 'rand_engrave_slot')
	local tgt_guid = rand_engrave_slot:GetUserValue('ITEM_GUID')
	local tgt_spot = rand_engrave_slot:GetUserValue('EQUIP_SPOT')
	local tgt_item = session.GetEquipItemBySpot(item.GetEquipSpotNum(tgt_spot))
	if tgt_item == nil then
		ui.SysMsg(ClMsg('NoSelectedItem'))
		return
	end

	if tgt_item.isLockState == true then
		ui.SysMsg(ClMsg('MaterialItemIsLock'))
		return
	end

	session.AddItemID(tgt_guid, 1)

	local rand_mat_list = GET_CHILD_RECURSIVELY(frame, 'rand_mat_list')
	local selected_cnt = rand_mat_list:GetSelectedSlotCount()
	for i = 0, selected_cnt - 1 do
		local _slot = rand_mat_list:GetSelectedSlot(i)
		local mat_guid = _slot:GetUserValue('ITEM_GUID')
		local mat_item = session.GetInvItemByGuid(mat_guid)
		if mat_item == nil then
			ui.SysMsg(ClMsg('NoSelectedItem'))
			return
		end

		if mat_item.isLockState == true then
			ui.SysMsg(ClMsg('MaterialItemIsLock'))
			return
		end

		local cnt = _slot:GetSelectCount()
		session.AddItemID(mat_guid, cnt)
	end

	local rand_equip_list = GET_CHILD_RECURSIVELY(frame, 'rand_equip_list')
	local spot = rand_equip_list:GetSelItemKey()

	local randomoption_bg = GET_CHILD_RECURSIVELY(frame, 'randomoption_bg')
	local index = randomoption_bg:GetUserValue('PRESET_INDEX')

	local arg_list = NewStringList()
	arg_list:Add(index)
    arg_list:Add(spot)

	local result_list = session.GetItemIDList()
	item.DialogTransaction('ICOR_PRESET_ENGRAVE', result_list, '', arg_list)
end

function GODDESS_MGR_ENGRAVE_CLEAR_BTN(parent, btn)
	local effect_frame = ui.GetFrame('result_effect_ui')
	effect_frame:ShowWindow(0)

	local frame = parent:GetTopParentFrame()
	GODDESS_MGR_RANDOMOPTION_ENGRAVE_CLEAR(frame)
end

function ON_SUCCESS_RANDOMOPTION_ENGRAVE(frame, msg, arg_str, arg_num)
	local rand_do_engrave = GET_CHILD_RECURSIVELY(frame, 'rand_do_engrave')
	rand_do_engrave:ShowWindow(0)

	local ref_slot = GET_CHILD_RECURSIVELY(frame, 'rand_engrave_slot')
	local guid = ref_slot:GetUserValue('ITEM_GUID')
	local inv_item = session.GetEquipItemByGuid(guid)
	local item_obj = GetIES(inv_item:GetObject())
	local icon = TryGetProp(item_obj, 'Icon', 'None')

	local left, top = _GET_EFFECT_UI_MARGIN()

	local success_scp = string.format('RESULT_EFFECT_UI_RUN_SUCCESS(\'%s\', \'%s\', \'%d\', \'%d\')', '_END_RAMDOMOPTION_ENGRAVE_EXEC', icon, left, top)
	ReserveScript(success_scp, 0)
end

function ON_FAILED_RANDOMOPTION_ENGRAVE(frame, msg, arg_str, arg_num)
	local rand_do_engrave = GET_CHILD_RECURSIVELY(frame, 'rand_do_engrave')
	rand_do_engrave:ShowWindow(0)
	
	local left, top = _GET_EFFECT_UI_MARGIN()

	local failed_scp = string.format('RESULT_EFFECT_UI_RUN_FAILED(\'%s\', \'%d\', \'%d\')', '_END_RAMDOMOPTION_ENGRAVE_EXEC', left, top)
	ReserveScript(failed_scp, 0)
end

function _END_RAMDOMOPTION_ENGRAVE_EXEC()
	local frame = ui.GetFrame('goddess_equip_manager')
	local rand_ok_engrave = GET_CHILD_RECURSIVELY(frame, 'rand_ok_engrave')
	rand_ok_engrave:ShowWindow(1)
end
-- 각인 - 저장 끝

-- 각인 - 적용
function GODDESS_MGR_RANDOMOPTION_APPLY_CLEAR(frame)	
	local etc = GetMyEtcObject()
	if etc == nil then return end

	local rand_ok_apply = GET_CHILD_RECURSIVELY(frame, 'rand_ok_apply')
	rand_ok_apply:ShowWindow(0)

	local rand_do_apply = GET_CHILD_RECURSIVELY(frame, 'rand_do_apply')
	rand_do_apply:ShowWindow(1)

	local checkall = GET_CHILD_RECURSIVELY(frame, 'checkall')
	checkall:SetCheck(0)

	local randomoption_bg = GET_CHILD_RECURSIVELY(frame, 'randomoption_bg')
	local index = randomoption_bg:GetUserValue('PRESET_INDEX')

	local apply_cost = 0
	local coin_type = 'None'
	for i = 1, #managed_slot_list do
		local slot_info = managed_slot_list[i]
		local ctrlset = GET_CHILD_RECURSIVELY(frame, 'rand_slot_' .. slot_info.SlotName)

		local inv_item = session.GetEquipItemBySpot(item.GetEquipSpotNum(slot_info.SlotName))
		local item_obj = GetIES(inv_item:GetObject())
		
		local gBox = GET_CHILD_RECURSIVELY(ctrlset, 'optionGbox_1')
		gBox:RemoveChild('tooltip_equip_property_narrow')

		local slot = GET_CHILD(ctrlset, 'slot')
		local slot_name = GET_CHILD(ctrlset, 'slot_name')
		local item_name = GET_CHILD(ctrlset, 'item_name')
		local checkbox = GET_CHILD(ctrlset, 'checkbox')

		slot:SetSkinName(slot_info.SkinName)
		slot:SetUserValue('EQUIP_SPOT', slot_info.SlotName)		
		slot_name:SetTextByKey('name', ClMsg(slot_info.ClMsg))
		checkbox:SetCheck(0)

		if item_obj == nil or IS_NO_EQUIPITEM(item_obj) == 1 or item_goddess_growth.is_goddess_growth_item(item_obj) == true then
			slot:ClearIcon()
			slot:SetUserValue('ITEM_GUID', 'None')
			slot:SetUserValue('IS_APPLY', 0)
			item_name:SetTextByKey('name', ClMsg('NONE'))
		else
			SET_SLOT_ITEM(slot, inv_item)
			slot:SetUserValue('ITEM_GUID', inv_item:GetIESID())
			item_name:SetTextByKey('name', dic.getTranslatedStr(TryGetProp(item_obj, 'Name', 'NONE')))
			local option_dic = GET_ENGRAVED_OPTION_BY_INDEX_SPOT(etc, index, slot_info.SlotName)
			if option_dic ~= nil then
				local ret = IS_ENABLE_TO_ENGRAVE_APPLY(item_obj, index, slot_info.SlotName, GetMyEtcObject())
				if ret == true then
					_GODDESS_MGR_MAKE_RANDOM_OPTION_TEXT(gBox, nil, option_dic)
				else
					slot:ClearIcon()
					slot:SetUserValue('ITEM_GUID', 'None')
					slot:SetUserValue('IS_APPLY', 0)
					item_name:SetTextByKey('name', ClMsg('NONE'))
				end
			end
		end
	end

	GODDESS_MGR_RANDOMOPTION_APPLY_COST_UPDATE(frame)
end

function GODDESS_MGR_RANDOMOPTION_APPLY_COST_UPDATE(frame)
	local etc = GetMyEtcObject()
	if etc == nil then return end

	local randomoption_bg = GET_CHILD_RECURSIVELY(frame, 'randomoption_bg')
	local index = randomoption_bg:GetUserValue('PRESET_INDEX')
	local cost_list = {}

	for i = 1, #managed_slot_list do
		local slot_info = managed_slot_list[i]
		local ctrlset = GET_CHILD_RECURSIVELY(frame, 'rand_slot_' .. slot_info.SlotName)
		local slot = GET_CHILD(ctrlset, 'slot')
		local checkbox = GET_CHILD(ctrlset, 'checkbox')
		local guid = slot:GetUserValue('ITEM_GUID')
		if guid ~= 'None' and checkbox:IsChecked() == 1 then
			local inv_item = session.GetEquipItemBySpot(item.GetEquipSpotNum(slot_info.SlotName))
			local item_obj = GetIES(inv_item:GetObject())
			local _type, _cost = GET_COST_APPLY_ENGRAVE(item_obj)
			if cost_list[_type] == nil then
				cost_list[_type] = _cost
			else
				cost_list[_type] = cost_list[_type] + _cost
			end
		end
	end

	local cost_bg = GET_CHILD_RECURSIVELY(frame, 'rand_apply_cost_bg')
	cost_bg:RemoveAllChild()

	local coin_type = ''
	local apply_cost = ''
	local cset_height = ui.GetControlSetAttribute('engrave_apply_cost', 'height')
	local ind = 0
	for type, cost in pairs(cost_list) do
		local cost_cset = cost_bg:CreateOrGetControlSet('engrave_apply_cost', 'COST_' .. ind, 0, ind * cset_height)
		local cost_name = GET_CHILD(cost_cset, 'cost_name')
		cost_name:SetTextByKey('name', ClMsg(type))
		local cost_value = GET_CHILD(cost_cset, 'cost_value')
		cost_value:SetTextByKey('value', cost)
		if IS_ACCOUNT_COIN(type) == true then
			local coin_cls = GetClass('accountprop_inventory_list', type)
			if coin_cls ~= nil then
				local pic = TryGetProp(coin_cls, 'Icon', 'None')
				cost_value:SetTextByKey('pic', pic)
			end
		end
		
		coin_type = coin_type .. type .. ';'
		apply_cost = apply_cost .. cost .. ';'
		ind = ind + 1
	end

	local rand_do_apply = GET_CHILD_RECURSIVELY(frame, 'rand_do_apply')
	if ind == 0 then
		rand_do_apply:SetEnable(0)
	else
		rand_do_apply:SetEnable(1)
	end
	
	local origin_height = tonumber(frame:GetUserConfig('APPLY_COST_BG_HEIGHT'))
	local inner_height = cset_height * ind
	if inner_height > origin_height then
		cost_bg:Resize(cost_bg:GetWidth(), inner_height + 5)
	else
		cost_bg:Resize(cost_bg:GetWidth(), origin_height)
	end

	local rand_apply_bg = GET_CHILD_RECURSIVELY(frame, 'rand_apply_bg')
	rand_apply_bg:SetUserValue('COIN_TYPE', coin_type)
	rand_apply_bg:SetUserValue('REQ_COST', apply_cost)
end

function GODDESS_ENGRAVE_APPLY_CHECK(frame, ctrlset)
	local etc = GetMyEtcObject()
	if etc == nil then
		return false, 'None'
	end
	
	local randomoption_bg = GET_CHILD_RECURSIVELY(frame, 'randomoption_bg')
	local index = randomoption_bg:GetUserValue('PRESET_INDEX')

	local slot = GET_CHILD(ctrlset, 'slot')
	local guid = slot:GetUserValue('ITEM_GUID')
	if guid == 'None' then
		return false, 'None'
	end
	
	local spot_name = slot:GetUserValue('EQUIP_SPOT')
	local inv_item = session.GetEquipItemBySpot(item.GetEquipSpotNum(spot_name))
	if inv_item == nil then
		return false, 'None'
	end

	local item_obj = GetIES(inv_item:GetObject())
	local item_dic = GET_ITEM_RANDOMOPTION_DIC(item_obj)
	if item_dic == nil then
		return false, 'None'
	end

	local option_dic = GET_ENGRAVED_OPTION_BY_INDEX_SPOT(etc, index, spot_name)
	if option_dic == nil then
		return false, 'None'
	end

	if COMPARE_ITEM_OPTION_TO_ENGRAVED_OPTION(item_dic, option_dic) == true then
		return false, 'SameEngraveAppliedAlready'
	end

	return true
end

function GODDESS_MGR_RANDOMOPTION_APPLY_CHECK(ctrlset, checkbox, arg_str)
	local frame = ctrlset:GetTopParentFrame()
	if checkbox:IsChecked() == 1 then
		local flag, clmsg = GODDESS_ENGRAVE_APPLY_CHECK(frame, ctrlset)
		if flag == false then
			if clmsg ~= 'None' and arg_str ~= 'All' then
				ui.SysMsg(ClMsg(clmsg))
			end
			checkbox:SetCheck(0)
			return
		end
	end

	GODDESS_MGR_RANDOMOPTION_APPLY_COST_UPDATE(frame)
end

function GODDESS_MGR_RANDOMOPTION_APPLY_CHECK_ALL(parent, ctrl)
	local frame = parent:GetTopParentFrame()
	for i = 1, #managed_slot_list do
		local slot_info = managed_slot_list[i]
		local ctrlset = GET_CHILD_RECURSIVELY(frame, 'rand_slot_' .. slot_info.SlotName)
		local checkbox = GET_CHILD(ctrlset, 'checkbox')
		checkbox:SetCheck(ctrl:IsChecked())
		GODDESS_MGR_RANDOMOPTION_APPLY_CHECK(ctrlset, checkbox, 'All')
	end
end

function GODDESS_MGR_RANDOMOPTION_APPLY_OPEN(frame)
	GODDESS_MGR_RANDOMOPTION_APPLY_CLEAR(frame)
	INVENTORY_SET_CUSTOM_RBTNDOWN('None')

	local checkall = GET_CHILD_RECURSIVELY(frame, 'checkall')
	checkall:ShowWindow(1)
end

function GODDESS_MGR_RANDOMOPTION_APPLY_EXEC(parent, btn)
	local frame = parent:GetTopParentFrame()

	local acc = GetMyAccountObj()
	if acc == nil then return end
	
	local randomoption_bg = GET_CHILD_RECURSIVELY(frame, 'randomoption_bg')
	local index = randomoption_bg:GetUserValue('PRESET_INDEX')
	
	local apply_cnt = 0
	local same_cnt = 0
	for i = 1, #managed_slot_list do
		local slot_info = managed_slot_list[i]
		local ctrlset = GET_CHILD_RECURSIVELY(frame, 'rand_slot_' .. slot_info.SlotName)
		local tgt_item = session.GetEquipItemBySpot(item.GetEquipSpotNum(slot_info.SlotName))
		local checkbox = GET_CHILD(ctrlset, 'checkbox')
		if tgt_item ~= nil and checkbox:IsChecked() == 1 then
			if tgt_item.isLockState == true then
				ui.SysMsg(ClMsg('MaterialItemIsLock'))
				return
			end
			apply_cnt = apply_cnt + 1
		end
	end
	
	if apply_cnt == 0 then
		ui.SysMsg(ClMsg('NoSelectedItem'))
		return
	end
	
	local rand_apply_bg = GET_CHILD_RECURSIVELY(frame, 'rand_apply_bg')
	local type_str = rand_apply_bg:GetUserValue('COIN_TYPE')
	local cost_str = rand_apply_bg:GetUserValue('REQ_COST')

	local type_list = SCR_STRING_CUT(type_str, ';')
	local cost_list = SCR_STRING_CUT(cost_str, ';')
	if #type_list ~= #cost_list then
		return
	end

	for i = 1, #type_list do
		local coin_type = type_list[i]
		local cost = cost_list[i]

		local cur_coin = TryGetProp(acc, coin_type, '0')
		if cur_coin == 'None' then
			cur_coin = '0'
		end

		if math.is_larger_than(cur_coin, cost) ~= 1 then
			ui.SysMsg(ClMsg('NOT_ENOUGH_MONEY'))
			return
		end
	end

	local yesscp = string.format('_GODDESS_MGR_RANDOMOPTION_APPLY_EXEC()')
	local msgbox = ui.MsgBox(ClMsg('TryRandomOptionPresetApply'), yesscp, 'None')
	SET_MODAL_MSGBOX(msgbox)
end

function _GODDESS_MGR_RANDOMOPTION_APPLY_EXEC()
	local frame = ui.GetFrame('goddess_equip_manager')
	if frame == nil then return end

	session.ResetItemList()

	local arg_list = NewStringList()

	local apply_cnt = 0
	for i = 1, #managed_slot_list do
		local slot_info = managed_slot_list[i]
		local ctrlset = GET_CHILD_RECURSIVELY(frame, 'rand_slot_' .. slot_info.SlotName)
		local tgt_item = session.GetEquipItemBySpot(item.GetEquipSpotNum(slot_info.SlotName))
		local checkbox = GET_CHILD(ctrlset, 'checkbox')
		if tgt_item ~= nil and checkbox:IsChecked() == 1 then
			if tgt_item.isLockState == true then
				ui.SysMsg(ClMsg('MaterialItemIsLock'))
				return
			end
			local slot = GET_CHILD(ctrlset, 'slot')
			local guid = slot:GetUserValue('ITEM_GUID')
			if guid ~= 'None' then
				session.AddItemID(guid, 1)
				arg_list:Add(slot_info.SlotName)
				apply_cnt = apply_cnt + 1
			end
		end
	end
	
	if apply_cnt == 0 then
		ui.SysMsg(ClMsg('NoSelectedItem'))
		return
	end

	local randomoption_bg = GET_CHILD_RECURSIVELY(frame, 'randomoption_bg')
	local index = randomoption_bg:GetUserValue('PRESET_INDEX')

	arg_list:Add(index)

	local result_list = session.GetItemIDList()
	item.DialogTransaction('ICOR_PRESET_ENGRAVE_APPLY', result_list, '', arg_list)
end

function ON_SUCCESS_RANDOMOPTION_APPLY(frame, msg, arg_str, arg_num)
	ui.SysMsg(ClMsg('AppliedEngraveOption'))
	GODDESS_MGR_RANDOMOPTION_APPLY_CLEAR(frame)
end
-- 각인 - 적용 끝

-- 각인 - 아이커
function GODDESS_MGR_RANDOMOPTION_ENGRAVE_ICOR_CLEAR(frame)
	local rand_ok_icor = GET_CHILD_RECURSIVELY(frame, 'rand_ok_icor')
	rand_ok_icor:ShowWindow(0)

	local rand_do_icor = GET_CHILD_RECURSIVELY(frame, 'rand_do_icor')
	rand_do_icor:ShowWindow(1)

	local rand_icor_slot = GET_CHILD_RECURSIVELY(frame, 'rand_icor_slot')
	rand_icor_slot:ClearIcon()
	rand_icor_slot:SetUserValue('ITEM_GUID', 'None')

	local rand_icor_slot_pic = GET_CHILD_RECURSIVELY(frame, 'rand_icor_slot_pic')
	rand_icor_slot_pic:ShowWindow(1)

	local rand_icor_name = GET_CHILD_RECURSIVELY(frame, 'rand_icor_name')
	rand_icor_name:ShowWindow(0)
	rand_icor_name:SetTextByKey('name', '')

	local rand_icor_text = GET_CHILD_RECURSIVELY(frame, 'rand_icor_text')
	rand_icor_text:ShowWindow(1)

	local rand_icor_help_text = GET_CHILD_RECURSIVELY(frame, 'rand_icor_help_text')
	rand_icor_help_text:ShowWindow(1)

	local current_icor_option_inner = GET_CHILD_RECURSIVELY(frame, 'current_icor_option_inner')
	current_icor_option_inner:RemoveChild('tooltip_equip_property_narrow')

	local before_preset_option_inner = GET_CHILD_RECURSIVELY(frame, 'before_preset_option_inner')
	before_preset_option_inner:RemoveChild('tooltip_equip_property_narrow')
	CLEAR_GODDESS_ICOR_TEXT(frame)

	GODDESS_MGR_RANDOMOPTION_ENGRAVE_ICOR_COST_UPDATE(frame)
end

function GODDESS_MGR_RANDOMOPTION_ENGRAVE_ICOR_OPEN(frame)
	GODDESS_MGR_RANDOMOPTION_ENGRAVE_ICOR_CLEAR(frame)
	INVENTORY_SET_CUSTOM_RBTNDOWN('GODDESS_MGR_RANDOMOPTION_ENGRAVE_ICOR_INV_RBTN')

	local checkall = GET_CHILD_RECURSIVELY(frame, 'checkall')
	checkall:ShowWindow(0)
end

function GODDESS_MGR_RANDOMOPTION_ENGRAVE_ICOR_INV_RBTN(item_obj, slot, guid)
	local frame = ui.GetFrame('goddess_equip_manager')

	local inv_item = session.GetInvItemByGuid(guid)
	if item_obj ~= nil and inv_item ~= nil then
		GODDESS_MGR_RANDOMOPTION_ENGRAVE_ICOR_REG_ITEM(frame, inv_item, item_obj)
	end
end

function GODDESS_MGR_RANDOMOPTION_ENGRAVE_ICOR_ITEM_DROP(parent, slot)
	local frame = parent:GetTopParentFrame()
	local lift_icon = ui.GetLiftIcon()
	local from_frame = lift_icon:GetTopParentFrame()
    if from_frame:GetName() == 'inventory' then        
        local icon_info = lift_icon:GetInfo()
        local guid = icon_info:GetIESID()
		local inv_item = session.GetInvItemByGuid(guid)
		local item_obj = GetIES(inv_item:GetObject())
		if item_obj ~= nil and inv_item ~= nil then
			GODDESS_MGR_RANDOMOPTION_ENGRAVE_ICOR_REG_ITEM(frame, inv_item, item_obj)
		end
	end
end

function GODDESS_MGR_RANDOMOPTION_ENGRAVE_ICOR_UPDATE(frame)
	local etc = GetMyEtcObject()
	if etc == nil then return end

	local randomoption_bg = GET_CHILD_RECURSIVELY(frame, 'randomoption_bg')
	local index = randomoption_bg:GetUserValue('PRESET_INDEX')

	
	local slot = GET_CHILD_RECURSIVELY(frame, 'rand_icor_slot')
	local guid = slot:GetUserValue('ITEM_GUID')
	if guid == 'None' then return end

	local inv_item = session.GetInvItemByGuid(guid)
	local item_obj = GetIES(inv_item:GetObject())
	local spot = slot:GetUserValue('EQUIP_SPOT')
	local before_option = GET_ENGRAVED_OPTION_BY_INDEX_SPOT(etc, index, spot)	
	local before_preset_option_inner = GET_CHILD_RECURSIVELY(frame, 'before_preset_option_inner')
	before_preset_option_inner:RemoveChild('tooltip_equip_property_narrow')
	_GODDESS_MGR_MAKE_RANDOM_OPTION_TEXT(before_preset_option_inner, nil, before_option)

	local item_dic = GET_ITEM_RANDOMOPTION_DIC(item_obj)
	if COMPARE_ITEM_OPTION_TO_ENGRAVED_OPTION(item_dic, before_option) == true then
		slot:SetUserValue('IS_SAME_OPTION', 1)
	else
		slot:SetUserValue('IS_SAME_OPTION', 0)
	end
end

function GODDESS_MGR_RANDOMOPTION_ENGRAVE_ICOR_COST_UPDATE(frame)
	local rand_icor_prob_text = GET_CHILD_RECURSIVELY(frame, 'rand_icor_prob_text')
	local rand_icor_cost_name = GET_CHILD_RECURSIVELY(frame, 'rand_icor_cost_name')
	local rand_icor_cost = GET_CHILD_RECURSIVELY(frame, 'rand_icor_cost')
	local rand_do_icor = GET_CHILD_RECURSIVELY(frame, 'rand_do_icor')

	local slot = GET_CHILD_RECURSIVELY(frame, 'rand_icor_slot')
	local guid = slot:GetUserValue('ITEM_GUID')
	if guid ~= 'None' then
		local rate = slot:GetUserValue('DEFAULT_RATE')
		local coin = slot:GetUserValue('COIN_TYPE')
		local cost = slot:GetUserValue('REQ_COST')
	
		rand_icor_prob_text:SetTextByKey('total', rate)
		if cost == 'None' then
			cost = '0'
		end
		rand_icor_cost:SetTextByKey('value', cost)
	
		local coin_cls = GetClass('accountprop_inventory_list', coin)
		if coin_cls ~= nil then
			local pic = TryGetProp(coin_cls, 'Icon', 'None')
			rand_icor_cost:SetTextByKey('pic', pic)
		end

		rand_icor_prob_text:ShowWindow(1)
		rand_icor_cost_name:ShowWindow(1)
		rand_icor_cost:ShowWindow(1)
		rand_do_icor:SetEnable(1)
	else
		rand_icor_prob_text:ShowWindow(0)
		rand_icor_cost_name:ShowWindow(0)
		rand_icor_cost:ShowWindow(0)
		rand_do_icor:SetEnable(0)
	end
end

function GODDESS_MGR_RANDOMOPTION_ENGRAVE_ICOR_REG_ITEM(frame, inv_item, item_obj)
	if inv_item == nil then return end

	local etc = GetMyEtcObject()
	if etc == nil then return end

	local enable, def_rate = IS_ENABLE_TO_ENGARVE(item_obj, 0)	
	
	if enable == false then
		ui.SysMsg(ClMsg('IMPOSSIBLE_ITEM'))
		return
	end

	local is_goddess_icor = shared_item_goddess_icor.get_goddess_icor_grade(item_obj)
	
	local inherit_item = GetClass('Item', TryGetProp(item_obj, 'InheritanceRandomItemName', 'None'))	
	if is_goddess_icor == 0 and inherit_item == nil then
		ui.SysMsg(ClMsg('IMPOSSIBLE_ITEM'))
		return
	end

	local spot = TryGetProp(inherit_item, 'DefaultEqpSlot', 'None')

	if is_goddess_icor > 0 then
		SHOW_GODDESS_ICOR_TEXT(frame)
		init_goddess_icor_spot_list(frame, TryGetProp(item_obj, 'StringArg2', 'None'))
		if TryGetProp(item_obj, 'StringArg2', 'None') == 'Armor' then
		spot = 'SHIRT'
	else		
			spot = 'RH'
		end
	else		
		CLEAR_GODDESS_ICOR_TEXT(frame)
	end

	local slot = GET_CHILD_RECURSIVELY(frame, 'rand_icor_slot')
	SET_SLOT_ITEM(slot, inv_item)
	slot:SetUserValue('ITEM_GUID', inv_item:GetIESID())
	slot:SetUserValue('ITEM_CLASSNAME', TryGetProp(item_obj, 'ClassName', 'None'))	
	slot:SetUserValue('ITEM_USE_LEVEL', TryGetProp(inherit_item, 'UseLv', 0))
	slot:SetUserValue('DEFAULT_RATE', def_rate)
	slot:SetUserValue('EQUIP_SPOT', spot)

	local coin = GET_COST_SAVE_ENGRAVE(inherit_item)
	slot:SetUserValue('COIN_TYPE', coin)
	slot:SetUserValue('REQ_COST', 0)

	local slot_pic = GET_CHILD_RECURSIVELY(frame, 'rand_icor_slot_pic')
	slot_pic:ShowWindow(0)

	local rand_icor_text = GET_CHILD_RECURSIVELY(frame, 'rand_icor_text')
	rand_icor_text:ShowWindow(0)

	local rand_icor_name = GET_CHILD_RECURSIVELY(frame, 'rand_icor_name')
	rand_icor_name:SetTextByKey('name', dic.getTranslatedStr(TryGetProp(item_obj, 'Name', 'NONE')))
	rand_icor_name:ShowWindow(1)

	local rand_icor_help_text = GET_CHILD_RECURSIVELY(frame, 'rand_icor_help_text')
	rand_icor_help_text:ShowWindow(0)

	local current_icor_option_inner = GET_CHILD_RECURSIVELY(frame, 'current_icor_option_inner')
	current_icor_option_inner:RemoveChild('tooltip_equip_property_narrow')
	_GODDESS_MGR_MAKE_RANDOM_OPTION_TEXT(current_icor_option_inner, item_obj)

	GODDESS_MGR_RANDOMOPTION_ENGRAVE_ICOR_UPDATE(frame)

	GODDESS_MGR_RANDOMOPTION_ENGRAVE_ICOR_COST_UPDATE(frame)
end

function GODDESS_ICOR_SPOT_SELECT(parent, ctrl)
	local frame = parent:GetTopParentFrame()
	local index = ctrl:GetSelItemKey()
	
	local slot = GET_CHILD_RECURSIVELY(frame, 'rand_icor_slot')	
	slot:SetUserValue('EQUIP_SPOT', index)

	GODDESS_MGR_RANDOMOPTION_ENGRAVE_ICOR_UPDATE(frame)
end

function GODDESS_MGR_RANDOMOPTION_ENGRAVE_ICOR_ITEM_REMOVE(parent, ctrl)
	local frame = parent:GetTopParentFrame()
	GODDESS_MGR_RANDOMOPTION_ENGRAVE_ICOR_CLEAR(frame)
end

function GODDESS_MGR_RANDOMOPTION_ENGRAVE_ICOR_EXEC(parent, btn)
	local frame = parent:GetTopParentFrame()

	local rand_icor_slot = GET_CHILD_RECURSIVELY(frame, 'rand_icor_slot')
	local coin_type = rand_icor_slot:GetUserValue('COIN_TYPE')
	local acc = GetMyAccountObj()
	if acc == nil then return end

	local spot = rand_icor_slot:GetUserValue('EQUIP_SPOT')
	if spot == 'None' then
		ui.SysMsg(ClMsg('FirstSelectSpotForGoddessIcorEngrave'))
		return
	end

	local cur_coin = TryGetProp(acc, coin_type, '0')
	if cur_coin == 'None' then
		cur_coin = '0'
	end
	
	local cost = rand_icor_slot:GetUserValue('REQ_COST')
	if cost == 'None' then
		cost = '0'
	end
	
	if math.is_larger_than(cost, cur_coin) == 1 then
		ui.SysMsg(ClMsg('NOT_ENOUGH_MONEY'))
		return
	end

	if rand_icor_slot:GetUserIValue('IS_SAME_OPTION') == 1 then
		ui.SysMsg(ClMsg('SameOptionEngravedAlready'))
		return
	end

	local yesscp = string.format('_GODDESS_MGR_RANDOMOPTION_ENGRAVE_ICOR_EXEC()')
	local msgbox = ui.MsgBox(ClMsg('TryRandomOptionPresetEngrave'), yesscp, 'None')
	SET_MODAL_MSGBOX(msgbox)
end

function _GODDESS_MGR_RANDOMOPTION_ENGRAVE_ICOR_EXEC()
	local frame = ui.GetFrame('goddess_equip_manager')
	if frame == nil then return end

	session.ResetItemList()

	local rand_icor_slot = GET_CHILD_RECURSIVELY(frame, 'rand_icor_slot')
	local tgt_guid = rand_icor_slot:GetUserValue('ITEM_GUID')
	local tgt_item = session.GetInvItemByGuid(tgt_guid)
	if tgt_item == nil then
		ui.SysMsg(ClMsg('NoSelectedItem'))
		return
	end

	if tgt_item.isLockState == true then
		ui.SysMsg(ClMsg('MaterialItemIsLock'))
		return
	end

	local obj = GetIES(tgt_item:GetObject())	
	session.AddItemID(tgt_guid, 1)

	local randomoption_bg = GET_CHILD_RECURSIVELY(frame, 'randomoption_bg')
	local index = randomoption_bg:GetUserValue('PRESET_INDEX')

	local spot = rand_icor_slot:GetUserValue('EQUIP_SPOT')
	local arg_list = NewStringList()
	arg_list:Add(index)

	if shared_item_goddess_icor.get_goddess_icor_grade(obj) > 0 then		
		arg_list:Add(spot)
	end

	local result_list = session.GetItemIDList()
	item.DialogTransaction('ICOR_PRESET_ENGRAVE_ICOR', result_list, '', arg_list)
end

function GODDESS_MGR_ENGRAVE_ICOR_CLEAR_BTN(parent, btn)
	local effect_frame = ui.GetFrame('result_effect_ui')
	effect_frame:ShowWindow(0)

	local frame = parent:GetTopParentFrame()
	GODDESS_MGR_RANDOMOPTION_ENGRAVE_ICOR_CLEAR(frame)
end

function ON_SUCCESS_RANDOMOPTION_ENGRAVE_ICOR(frame, msg, arg_str, arg_num)
	local rand_do_engrave = GET_CHILD_RECURSIVELY(frame, 'rand_do_icor')
	rand_do_engrave:ShowWindow(0)

	local ref_slot = GET_CHILD_RECURSIVELY(frame, 'rand_icor_slot')
	local left, top = _GET_EFFECT_UI_MARGIN()
	local class_name = ref_slot:GetUserValue('ITEM_CLASSNAME')
	local cls = GetClass('Item', class_name)
	local icon = nil
	if cls ~= nil then
		icon = TryGetProp(cls, 'Icon', 'None')
	end

	local success_scp = string.format('RESULT_EFFECT_UI_RUN_SUCCESS(\'%s\', \'%s\', \'%d\', \'%d\')', '_END_RAMDOMOPTION_ENGRAVE_ICOR_EXEC', icon, left, top)
	ReserveScript(success_scp, 0)
end

function _END_RAMDOMOPTION_ENGRAVE_ICOR_EXEC()
	local frame = ui.GetFrame('goddess_equip_manager')
	local rand_ok_engrave = GET_CHILD_RECURSIVELY(frame, 'rand_ok_icor')
	rand_ok_engrave:ShowWindow(1)
end
-- 각인 - 아이커 끝
-- 각인 끝

-- 소켓 관리
function GODDESS_MGR_SOCKET_CLEAR(frame)
	local slot = GET_CHILD_RECURSIVELY(frame, 'socket_slot')
	slot:ClearIcon()
	slot:SetUserValue('ITEM_GUID', 'None')

	local slot_pic = GET_CHILD_RECURSIVELY(frame, 'socket_slot_bg_image')
	slot_pic:ShowWindow(1)

	local weapon_tooltip_title = GET_CHILD_RECURSIVELY(frame, 'weapon_tooltip_title')
	local weapon_tooltip = GET_CHILD_RECURSIVELY(frame, 'weapon_tooltip')
	local armor_tooltip_title = GET_CHILD_RECURSIVELY(frame, 'armor_tooltip_title')
	local armor_tooltip = GET_CHILD_RECURSIVELY(frame, 'armor_tooltip')
	weapon_tooltip_title:ShowWindow(0)
	weapon_tooltip:ShowWindow(0)
	armor_tooltip_title:ShowWindow(0)
	armor_tooltip:ShowWindow(0)

	local socket_item_name = GET_CHILD_RECURSIVELY(frame, 'socket_item_name')
	socket_item_name:ShowWindow(0)

	local socket_item_text = GET_CHILD_RECURSIVELY(frame, 'socket_item_text')
	socket_item_text:ShowWindow(1)
	
	GODDESS_MGR_SOCKET_NORMAL_UPDATE(frame)
	GODDESS_MGR_SOCKET_AETHER_UPDATE(frame)
end

function GODDESS_MGR_SOCKET_INV_RBTN(item_obj, slot, guid)	
	local frame = ui.GetFrame('goddess_equip_manager')

	local inv_item = session.GetInvItemByGuid(guid)
	if inv_item ~= nil then
		local slot = GET_CHILD_RECURSIVELY(frame, 'socket_slot')
		local guid = slot:GetUserValue('ITEM_GUID')		
		if guid == 'None' or TryGetProp(item_obj, 'ItemType', 'None') == 'Equip' then			
			GODDESS_MGR_SOCKET_REG_ITEM(frame, inv_item, item_obj)
		else
			local equip_item = session.GetInvItemByGuid(guid)
			if equip_item == nil then return end

			local equip_obj = GetIES(equip_item:GetObject())
			if item_goddess_socket.enable_aether_socket_add(equip_obj) == true then
				local aether_cover_bg = GET_CHILD_RECURSIVELY(frame, 'aether_cover_bg')
				local aether_open_mat_slot = GET_CHILD(aether_cover_bg, 'aether_open_mat_slot')				
				GODDESS_AETHER_SOCKET_OPEN_MAT_REG(aether_cover_bg, aether_open_mat_slot, inv_item, item_obj, equip_obj)
				return
			end

			local gem_type = GET_EQUIP_GEM_TYPE(item_obj)
			if gem_type == nil then return end

			local use_lv = TryGetProp(equip_obj, 'UseLv', 0)
			if gem_type == 'aether' then
				local aether_inner_bg = GET_CHILD_RECURSIVELY(frame, 'aether_inner_bg')
				local max_socket_cnt = GET_MAX_GODDESS_AETHER_SOCKET_COUNT(lv)
				for i = 0, max_socket_cnt - 1 do
					local ctrlset = GET_CHILD(aether_inner_bg, 'AETHER_CSET_' .. i)
					local gem_id = ctrlset:GetUserIValue('GEM_ID')
					if gem_id == 0 then
						local gem_slot = GET_CHILD(ctrlset, 'gem_slot')						
						GODDESS_MGR_SOCKET_AETHER_GEM_EQUIP(ctrlset, gem_slot, inv_item, item_obj)
						break
					end
				end
			else
				local normal_inner_bg = GET_CHILD_RECURSIVELY(frame, 'normal_inner_bg')
				local max_socket_cnt = GET_MAX_GODDESS_NORMAL_SOCKET_COUNT(use_lv)
				for i = 0, max_socket_cnt - 1 do
					local ctrlset = GET_CHILD(normal_inner_bg, 'NORMAL_CSET_' .. i)
					local gem_id = ctrlset:GetUserIValue('GEM_ID')
					if gem_id == 0 then
						local gem_slot = GET_CHILD(ctrlset, 'gem_slot')						
						GODDESS_MGR_SOCKET_NORMAL_GEM_EQUIP(ctrlset, gem_slot, inv_item, item_obj)
						break
					end
				end
			end
		end
	end
end

function GODDESS_MGR_SOCKET_ITEM_DROP(parent, slot, arg_str, arg_num)	
	local frame = parent:GetTopParentFrame()
	local main_tab = GET_CHILD_RECURSIVELY(frame, 'main_tab')
	local index = main_tab:GetSelectItemIndex()
	if index ~= 2 then return end

	local lift_icon = ui.GetLiftIcon()
	local from_frame = lift_icon:GetTopParentFrame()
    if from_frame:GetName() == 'inventory' then
        local icon_info = lift_icon:GetInfo()
        local guid = icon_info:GetIESID()
        local inv_item = session.GetInvItemByGuid(guid)
		if inv_item == nil then return end
		
		local item_obj = GetIES(inv_item:GetObject())
		if item_obj == nil then return end
        
		GODDESS_MGR_SOCKET_REG_ITEM(frame, inv_item, item_obj)
	end
end

function GODDESS_MGR_SOCKET_REG_ITEM(frame, inv_item, item_obj)	
	if inv_item == nil or item_obj == nil then return end	

	if item_goddess_transcend.is_able_to_socket(item_obj) == false then
		ui.SysMsg(ClMsg('WebService_38'))
		return
	end

	if TryGetProp(item_obj, 'ItemGrade', 0) < 6 then
		ui.SysMsg(ClMsg('GoddessGradeItemOnly'))
		return
	end

	local weapon_tooltip_title = GET_CHILD_RECURSIVELY(frame, 'weapon_tooltip_title')
	local weapon_tooltip = GET_CHILD_RECURSIVELY(frame, 'weapon_tooltip')
	local armor_tooltip_title = GET_CHILD_RECURSIVELY(frame, 'armor_tooltip_title')
	local armor_tooltip = GET_CHILD_RECURSIVELY(frame, 'armor_tooltip')

	local slot = GET_CHILD_RECURSIVELY(frame, 'socket_slot')
	SET_SLOT_ITEM(slot, inv_item)
	slot:SetUserValue('ITEM_GUID', inv_item:GetIESID())
	slot:SetUserValue('ITEM_USE_LEVEL', TryGetProp(item_obj, 'UseLv', 1))

	local slot_pic = GET_CHILD_RECURSIVELY(frame, 'socket_slot_bg_image')
	slot_pic:ShowWindow(0)

	local socket_item_text = GET_CHILD_RECURSIVELY(frame, 'socket_item_text')
	socket_item_text:ShowWindow(0)

	local socket_item_name = GET_CHILD_RECURSIVELY(frame, 'socket_item_name')
	socket_item_name:SetTextByKey('name', dic.getTranslatedStr(TryGetProp(item_obj, 'Name', 'NONE')))
	socket_item_name:ShowWindow(1)

	local open_mat_slot = GET_CHILD_RECURSIVELY(frame, 'aether_open_mat_slot')
	open_mat_slot:ClearIcon()

	local equipGroup = TryGetProp(item_obj, 'EquipGroup', 'None')
	if equipGroup == 'THWeapon' or equipGroup == 'SubWeapon' or equipGroup == 'Weapon' then
		weapon_tooltip_title:ShowWindow(1)
		weapon_tooltip:ShowWindow(1)
		armor_tooltip_title:ShowWindow(0)
		armor_tooltip:ShowWindow(0)
	elseif equipGroup == 'SHIRT' or equipGroup == 'PANTS' or equipGroup == 'BOOTS' or equipGroup == 'GLOVES' then
		weapon_tooltip_title:ShowWindow(0)
		weapon_tooltip:ShowWindow(0)
		armor_tooltip_title:ShowWindow(1)
		armor_tooltip:ShowWindow(1)
	end


	GODDESS_MGR_SOCKET_NORMAL_UPDATE(frame)
	GODDESS_MGR_SOCKET_AETHER_UPDATE(frame)
end

function GODDESS_MGR_SOCKET_ITEM_REMOVE(parent, slot)
	local frame = parent:GetTopParentFrame()

	slot:ClearIcon()
	slot:SetUserValue('ITEM_GUID', 'None')
	slot:SetUserValue('ITEM_USE_LEVEL', 0)

	local slot_pic = GET_CHILD_RECURSIVELY(frame, 'socket_slot_bg_image')
	slot_pic:ShowWindow(1)

	local socket_item_name = GET_CHILD_RECURSIVELY(frame, 'socket_item_name')
	socket_item_name:ShowWindow(0)

	local socket_item_text = GET_CHILD_RECURSIVELY(frame, 'socket_item_text')
	socket_item_text:ShowWindow(1)

	GODDESS_MGR_SOCKET_NORMAL_UPDATE(frame)
	GODDESS_MGR_SOCKET_AETHER_UPDATE(frame)
end

function GODDESS_MGR_SOCKET_NORMAL_UPDATE(frame)
	local normal_inner_bg = GET_CHILD_RECURSIVELY(frame, 'normal_inner_bg')
	normal_inner_bg:RemoveAllChild()

	local socket_slot = GET_CHILD_RECURSIVELY(frame, 'socket_slot')
	local guid = socket_slot:GetUserValue('ITEM_GUID')
	if guid ~= 'None' then
		local inv_item = session.GetInvItemByGuid(guid)
		if inv_item == nil then return end

		local item_obj = GetIES(inv_item:GetObject())
		local use_lv = TryGetProp(item_obj, 'UseLv', 0)
		local max_socket_cnt = GET_MAX_GODDESS_NORMAL_SOCKET_COUNT(use_lv)
		local not_available = false
		for i = 0, max_socket_cnt - 1 do
			local ctrlset = normal_inner_bg:CreateOrGetControlSet('eachsocket_in_goddessmgr', 'NORMAL_CSET_'..i , 5, i * 90)
			ctrlset:SetUserValue('SLOT_INDEX', i)

			local gem_slot = GET_CHILD(ctrlset, 'gem_slot')
			local socket_name = GET_CHILD(ctrlset, 'socket_name')
			local do_remove = GET_CHILD(ctrlset, 'do_remove')
			local do_enable = GET_CHILD(ctrlset, 'do_enable')
			local socket_questionmark = GET_CHILD(ctrlset, 'socket_questionmark')

			local socketname = ScpArgMsg('NotDecidedYet')
			local enable = inv_item:IsAvailableSocket(i)
			if enable == true then
				local gem_id = inv_item:GetEquipGemID(i)
				local gem_exp = inv_item:GetEquipGemExp(i)
				local gem_equipped = 0
				if gem_id == 0 then
					local socket_cls = GetClassByType('Socket', GET_COMMON_SOCKET_TYPE())
					socketname = socket_cls.Name .. ' '.. ScpArgMsg('JustSocket')
					socketicon = socket_cls.SlotIcon
				else
					local gem_cls = GetClassByType('Item', gem_id)
					socketname = gem_cls.Name
					socketicon = gem_cls.Icon
					gem_equipped = 1
				end

				ctrlset:SetUserValue('GEM_ID', gem_id)

				socket_questionmark:ShowWindow(0)
				gem_slot:ShowWindow(1)
				local icon = CreateIcon(gem_slot)
				icon:SetImage(socketicon)
				do_enable:ShowWindow(0)
				do_remove:ShowWindow(1)
				do_remove:SetEnable(gem_equipped)
			else
				gem_slot:ShowWindow(0)
				socket_questionmark:ShowWindow(1)
				do_remove:ShowWindow(0)
				if not_available == false then
					do_enable:ShowWindow(1)
				else
					do_enable:ShowWindow(0)
				end

				not_available = true
			end

			socket_name:SetTextByKey('name', socketname)
		end
	end
end

function GODDESS_MGR_SOCKET_AETHER_UPDATE(frame)
	local aether_inner_bg = GET_CHILD_RECURSIVELY(frame, 'aether_inner_bg')
	aether_inner_bg:RemoveAllChild()

	local aether_cover_bg = GET_CHILD_RECURSIVELY(frame, 'aether_cover_bg')

	local socket_slot = GET_CHILD_RECURSIVELY(frame, 'socket_slot')	
	local guid = socket_slot:GetUserValue('ITEM_GUID')
	if guid ~= 'None' then
		local inv_item = session.GetInvItemByGuid(guid)
		if inv_item == nil then return end

		local item_obj = GetIES(inv_item:GetObject())
		local use_lv = TryGetProp(item_obj, 'UseLv', 0)
		local max_normal_cnt = GET_MAX_GODDESS_NORMAL_SOCKET_COUNT(use_lv)
		local aether_available = item_goddess_socket.enable_aether_socket_add(item_obj)
		if aether_available == false then
			aether_cover_bg:ShowWindow(0)
			if inv_item:IsAvailableSocket(max_normal_cnt) == false then
				return
			end
			local item_obj = GetIES(inv_item:GetObject())
			local use_lv = TryGetProp(item_obj, 'UseLv', 0)
			local max_aether_cnt = GET_MAX_GODDESS_AETHER_SOCKET_COUNT(use_lv)
			local not_available = false
			for i = 0, max_aether_cnt - 1 do
				local aether_index = i + max_normal_cnt
				local ctrlset = aether_inner_bg:CreateOrGetControlSet('eachsocket_in_goddessmgr', 'AETHER_CSET_'..i , 5, i * 90)
				ctrlset:SetUserValue('SLOT_INDEX', aether_index)

				local gem_slot = GET_CHILD(ctrlset, 'gem_slot')
				local socket_name = GET_CHILD(ctrlset, 'socket_name')
				local do_remove = GET_CHILD(ctrlset, 'do_remove')
				local do_enable = GET_CHILD(ctrlset, 'do_enable')
				local socket_questionmark = GET_CHILD(ctrlset, 'socket_questionmark')

				local socketname = ScpArgMsg('NotDecidedYet')
				local enable = inv_item:IsAvailableSocket(aether_index)
				if enable == true then
					local gem_id = inv_item:GetEquipGemID(aether_index)
					local gem_exp = inv_item:GetEquipGemExp(aether_index)
					local gem_equipped = 0
					if gem_id == 0 then
						local socket_cls = GetClassByType('Socket', GET_COMMON_SOCKET_TYPE())
						socketname = socket_cls.Name .. ' '.. ScpArgMsg('JustSocket')
						socketicon = socket_cls.SlotIcon
					else
						local gem_cls = GetClassByType('Item', gem_id)
						socketname = gem_cls.Name
						socketicon = gem_cls.Icon
						gem_equipped = 1
					end

					ctrlset:SetUserValue('GEM_ID', gem_id)

					socket_questionmark:ShowWindow(0)
					gem_slot:ShowWindow(1)
					local icon = CreateIcon(gem_slot)
					icon:SetImage(socketicon)
					do_enable:ShowWindow(0)
					do_remove:ShowWindow(1)
					do_remove:SetEnable(gem_equipped)
				else
					gem_slot:ShowWindow(0)
					socket_questionmark:ShowWindow(1)
					do_remove:ShowWindow(0)
					if not_available == false then
						do_enable:ShowWindow(1)
					else
						do_enable:ShowWindow(0)
					end

					not_available = true
				end

				socket_name:SetTextByKey('name', socketname)
			end
		else
			aether_cover_bg:ShowWindow(1)
			local aether_open_btn = GET_CHILD(aether_cover_bg, 'aether_open_btn')
			aether_open_btn:SetEnable(0)
			local lock_pic = GET_CHILD(aether_cover_bg, 'lock_pic')
			lock_pic:ShowWindow(1)
		end
	else
		aether_cover_bg:ShowWindow(0)
	end
end

function GODDESS_MGR_SOCKET_OPEN(frame)
	INVENTORY_SET_CUSTOM_RBTNDOWN('GODDESS_MGR_SOCKET_INV_RBTN')
	GODDESS_MGR_SOCKET_CLEAR(frame)
end

function GODDESS_MGR_SOCKET_UPDATE(frame, msg, arg_str, arg_num)
	GODDESS_MGR_SOCKET_NORMAL_UPDATE(frame)
	GODDESS_MGR_SOCKET_AETHER_UPDATE(frame)
end

function GODDESS_MGR_SOCKET_GEM_ITEM_DROP(parent, slot, arg_str, arg_num)
	local frame = parent:GetTopParentFrame()
	local main_tab = GET_CHILD_RECURSIVELY(frame, 'main_tab')
	local index = main_tab:GetSelectItemIndex()
	if index ~= 2 then return end

	local lift_icon = ui.GetLiftIcon()
	local from_frame = lift_icon:GetTopParentFrame()
    if from_frame:GetName() == 'inventory' then
        local icon_info = lift_icon:GetInfo()
        local guid = icon_info:GetIESID()
        local inv_item = session.GetInvItemByGuid(guid)
		if inv_item == nil then return end
		
		local item_obj = GetIES(inv_item:GetObject())
		if item_obj == nil then return end

		local gem_type = GET_EQUIP_GEM_TYPE(item_obj)
		if gem_type == 'normal' then
			local gem_prop = geItemTable.GetProp(item_obj.ClassID)
			local penalty_prop = gem_prop:GetSocketPropertyByLevel(0)
			local penalty_add = penalty_prop:GetPropPenaltyAddByIndex(0, 0) -- 스킬 젬인지 검사
			if penalty_add ~= nil and TryGetProp(item_obj, 'GemRoastingLv', 0) < TryGetProp(item_obj, 'GemLevel', 0) then
				ui.SysMsg(ClMsg('OnlyRoastedGemEquipableToGoddess'))
			else
				GODDESS_MGR_SOCKET_NORMAL_GEM_EQUIP(parent, slot, inv_item, item_obj)
			end
		elseif gem_type == 'skill' then
			GODDESS_MGR_SOCKET_NORMAL_GEM_EQUIP(parent, slot, inv_item, item_obj)
		elseif gem_type == 'aether' then
			GODDESS_MGR_SOCKET_AETHER_GEM_EQUIP(parent, slot, inv_item, item_obj)
		end
	end
end

function GODDESS_MGR_SOCKET_NORMAL_GEM_EQUIP(parent, slot, gem_item, gem_obj)
	local frame = parent:GetTopParentFrame()
	local equip_slot = GET_CHILD_RECURSIVELY(frame, 'socket_slot')
	local guid = equip_slot:GetUserValue('ITEM_GUID')
	if guid ~= 'None' then
		local equip_item = session.GetInvItemByGuid(guid)
		if equip_item == nil then return end

		local equip_obj = GetIES(equip_item:GetObject())

		local index = parent:GetUserIValue('SLOT_INDEX')		
		if equip_item:IsAvailableSocket(index) == false then
			return
		end

		local gem_id = equip_item:GetEquipGemID(index)
		if gem_id ~= nil and gem_id ~= 0 then
			return
		end
		
		local flag, msg = item_goddess_socket.check_equipable_normal_gem(equip_obj, gem_obj, index)
		if flag == false then
			ui.SysMsg(ClMsg(msg))
			return
		end

		session.ResetItemList()

		session.AddItemID(guid, 1)
		session.AddItemID(gem_item:GetIESID(), 1)

		local arg_list = NewStringList()
		arg_list:Add(tostring(index))

		local result_list = session.GetItemIDList()

		item.DialogTransaction('GODDESS_SOCKET_NORMAL_GEM_EQUIP', result_list, '', arg_list)
	end
end

function GODDESS_MGR_SOCKET_AETHER_GEM_EQUIP(parent, slot, gem_item, gem_obj)
	local frame = parent:GetTopParentFrame()
	local equip_slot = GET_CHILD_RECURSIVELY(frame, 'socket_slot')
	local guid = equip_slot:GetUserValue('ITEM_GUID')
	if guid ~= 'None' then
		local equip_item = session.GetInvItemByGuid(guid)
		if equip_item == nil then return end

		local equip_obj = GetIES(equip_item:GetObject())

		local index = parent:GetUserIValue('SLOT_INDEX')
		if equip_item:IsAvailableSocket(index) == false then
			return
		end

		local gem_id = equip_item:GetEquipGemID(index)
		if gem_id ~= nil and gem_id ~= 0 then
			return
		end

		if item_goddess_socket.check_equipable_aether_gem(equip_obj, gem_obj, index) == false then
			return
		end

		session.ResetItemList()

		session.AddItemID(guid, 1)
		session.AddItemID(gem_item:GetIESID(), 1)

		local arg_list = NewStringList()
		arg_list:Add(tostring(index))

		local result_list = session.GetItemIDList()

		item.DialogTransaction('GODDESS_SOCKET_AETHER_GEM_EQUIP', result_list, '', arg_list)
	end
end

function GODDESS_MGR_SOCKET_REQ_GEM_REMOVE(parent, btn)
	local frame = parent:GetTopParentFrame()
	local slot = GET_CHILD_RECURSIVELY(frame, 'socket_slot')
	local guid = slot:GetUserValue('ITEM_GUID')
	if guid ~= 'None' then
		local index = parent:GetUserValue('SLOT_INDEX')

		local inv_item = session.GetInvItemByGuid(guid)
		if inv_item == nil then return end

		local item_obj = GetIES(inv_item:GetObject())
		local item_name = dic.getTranslatedStr(TryGetProp(item_obj, 'Name', 'None'))


		local gem_id = inv_item:GetEquipGemID(index)
		local gem_cls = GetClassByType('Item', gem_id)
		local gem_numarg1 = TryGetProp(gem_cls, 'NumberArg1', 0)
		local price = gem_numarg1 * 100
		local clmsg = 'None'

		local msg_cls_name = ''

		if TryGetProp(gem_cls, 'GemType', 'None') == 'Gem_High_Color' then
			msg_cls_name = 'ReallyRemoveGem_AetherGem'
			clmsg = "[" .. item_name .. "]" .. ScpArgMsg(msg_cls_name) .. tostring(price)
		else
			local pc = GetMyPCObject();
			local isGemRemoveCare = IS_GEM_EXTRACT_FREE_CHECK(pc)

			local free_gem = nil
			for optionIdx = 1, MAX_RANDOM_OPTION_COUNT do
				free_gem = GET_GEM_PROPERTY_TEXT(item_obj, optionIdx, index)
				 if free_gem ~= nil then
					_GODDESS_MGR_SOCKET_REQ_GEM_REMOVE(index)
					return
				 end
			end

			if isGemRemoveCare == true then
				msg_cls_name = "ReallyRemoveGem_Care"
			else
				msg_cls_name = "ReallyRemoveGem"
			end

			clmsg = "'".. item_name .. ScpArgMsg("Auto_'_SeonTaeg")..ScpArgMsg(msg_cls_name)
		end

		local yesscp = string.format('_GODDESS_MGR_SOCKET_REQ_GEM_REMOVE(%s)', index)
		local msgbox = ui.MsgBox(clmsg, yesscp, '')
		SET_MODAL_MSGBOX(msgbox)
	end
end

function _GODDESS_MGR_SOCKET_REQ_GEM_REMOVE(index)
	local frame = ui.GetFrame('goddess_equip_manager')
	local slot = GET_CHILD_RECURSIVELY(frame, 'socket_slot')
	local guid = slot:GetUserValue('ITEM_GUID')
	if guid ~= 'None' then
		local inv_item = session.GetInvItemByGuid(guid)
		if inv_item == nil then return end

		local gem_id = inv_item:GetEquipGemID(tonumber(index))
		if gem_id == nil or gem_id == 0 then
			return
		end

		local item_obj = GetIES(inv_item:GetObject())
		local use_lv = TryGetProp(item_obj, 'UseLv', 0)
		
		local tx_name = 'GODDESS_SOCKET_NORMAL_GEM_UNEQUIP'
		if tonumber(index) >= GET_MAX_GODDESS_NORMAL_SOCKET_COUNT(use_lv) then
			tx_name = 'GODDESS_SOCKET_AETHER_GEM_UNEQUIP'
		end
	
		pc.ReqExecuteTx_Item(tx_name, guid, index)
	end
end

function GODDESS_MGR_SOCKET_REQ_NORMAL_ENABLE(parent, btn)
	local frame = parent:GetTopParentFrame()
	local slot = GET_CHILD_RECURSIVELY(frame, 'socket_slot')
	local guid = slot:GetUserValue('ITEM_GUID')
	local isMaterial = 1
	if guid ~= 'None' then
		local inv_item = session.GetInvItemByGuid(guid)
		if inv_item == nil then return end

		local index = parent:GetUserValue('SLOT_INDEX')
		local name = 'None'
		local value = 0
		local item_obj = GetIES(inv_item:GetObject())
		local lv = TryGetProp(item_obj, 'UseLv', 0)
		local list = item_goddess_socket.get_normal_socket_material_list(lv, TryGetProp(item_obj, 'ClassType', 'None'), index)
		for _name, _value in pairs(list) do
			if _name ~= 'None' then
				if IS_ACCOUNT_COIN(_name) == true then
					local mat_cls = GetClass('accountprop_inventory_list', _name)
					if mat_cls == nil then return end
			
					local acc = GetMyAccountObj()
					local cur_count = TryGetProp(acc, _name, '0')
					if cur_count == 'None' then
						cur_count = '0'
					end
					
					if math.is_larger_than(cur_count, tostring(_value)) ~= 1 then
						isMaterial = 0
					end

					name = _name
					value = _value
				else
					local inv_item = session.GetInvItemByName(_name)
					if inv_item == nil then return end
			
					if inv_item.count < _value then
						isMaterial = 0
					end
				end
			end
		end

		local icon = 'None'
		local cls = GetClass('accountprop_inventory_list', name)
		if cls ~= nil then
			icon = TryGetProp(cls, 'Icon', 'None')
		end

		local img = '{img '.. icon ..' 32 32}'

		local yesscp = string.format('_GODDESS_MGR_SOCKET_REQ_NORMAL_ENABLE(%s, %d)', index, isMaterial)
		local msgbox = ui.MsgBox(ScpArgMsg('ReallyMakeSocketGoddess{img}{value}', 'img', img, 'value', value), yesscp, '')
		SET_MODAL_MSGBOX(msgbox)
	end
end

function _GODDESS_MGR_SOCKET_REQ_NORMAL_ENABLE(index, isMaterial)
	if isMaterial == 1 then
		local frame = ui.GetFrame('goddess_equip_manager')
		local slot = GET_CHILD_RECURSIVELY(frame, 'socket_slot')
		local guid = slot:GetUserValue('ITEM_GUID')
		if guid == 'None' then return end

		local inv_item = session.GetInvItemByGuid(guid)
		if inv_item == nil then return end

		local arg_list = string.format('%s', index)

		pc.ReqExecuteTx_Item('GODDESS_ADD_NORMAL_SOCKET', guid, arg_list)
	else
		ui.SysMsg(ClMsg('NotEnoughRecipe'))
		return
	end
end

function GODDESS_AETHER_SOCKET_OPEN_MAT_DROP(parent, slot, arg_str, arg_num)
	local frame = parent:GetTopParentFrame()
	local lift_icon = ui.GetLiftIcon()
	local from_frame = lift_icon:GetTopParentFrame()
    if from_frame:GetName() == 'inventory' then
        local icon_info = lift_icon:GetInfo()
        local guid = icon_info:GetIESID()
        local inv_item = session.GetInvItemByGuid(guid)
		if inv_item == nil then return end
		
		local item_obj = GetIES(inv_item:GetObject())
		if item_obj == nil then return end

		local equip_slot = GET_CHILD_RECURSIVELY(frame, 'socket_slot')
		local equip_guid = equip_slot:GetUserValue('ITEM_GUID')
		if equip_guid == 'None' then
			return
		end
		local equip_item = session.GetInvItemByGuid(equip_guid)
		local equip_obj = GetIES(equip_item:GetObject())
		GODDESS_AETHER_SOCKET_OPEN_MAT_REG(parent, slot, inv_item, item_obj, equip_obj)
	end
end

function GODDESS_AETHER_SOCKET_OPEN_MAT_REG(parent, slot, inv_item, item_obj, target_obj)
	if item_goddess_socket.is_aether_socket_material(item_obj, target_obj) == true then
		local lock_pic = GET_CHILD(parent, 'lock_pic')
		lock_pic:ShowWindow(0)
		local aether_open_btn = GET_CHILD(parent, 'aether_open_btn')
		aether_open_btn:SetEnable(1)
		SET_SLOT_ITEM(slot, inv_item)
		slot:SetUserValue('ITEM_GUID', inv_item:GetIESID())
	else
		ui.SysMsg(ClMsg('CantMovablePharmacyMaterial'))
	end
end

function GODDESS_AETHER_SOCKET_OPEN_MAT_REMOVE(parent, slot, arg_str, arg_num)
	slot:ClearIcon()
	local aether_open_btn = GET_CHILD(parent, 'aether_open_btn')
	aether_open_btn:SetEnable(0)
	local lock_pic = GET_CHILD(parent, 'lock_pic')
	lock_pic:ShowWindow(1)
end

function GODDESS_MGR_SOCKET_REQ_AETHER_ENABLE(parent, btn)
	local frame = parent:GetTopParentFrame()
	local equip_slot = GET_CHILD_RECURSIVELY(frame, 'socket_slot')
	local equip_guid = equip_slot:GetUserValue('ITEM_GUID')
	if equip_guid == 'None' then
		return
	end

	local mat_slot = GET_CHILD(parent, 'aether_open_mat_slot')
	local mat_guid = mat_slot:GetUserValue('ITEM_GUID')
	if mat_guid == 'None' then
		return
	end

	local equip_item = session.GetInvItemByGuid(equip_guid)
	local equip_obj = GetIES(equip_item:GetObject())
	if item_goddess_socket.enable_aether_socket_add(equip_obj) == false then
		return
	end

	local mat_item = session.GetInvItemByGuid(mat_guid)
	local mat_obj = GetIES(mat_item:GetObject())
	if item_goddess_socket.is_aether_socket_material(mat_obj, equip_obj) == false then
		return
	end

	local use_lv = TryGetProp(equip_obj, 'UseLv', 0)
	local aether_index = GET_MAX_GODDESS_NORMAL_SOCKET_COUNT(use_lv)
	if equip_item:IsAvailableSocket(aether_index) == true then
		return
	end
	
	local yesscp = string.format('_GODDESS_MGR_SOCKET_REQ_AETHER_ENABLE(%d)', aether_index)
	local msgbox = ui.MsgBox(ClMsg('ReallyMakeSocket'), yesscp, '')
	SET_MODAL_MSGBOX(msgbox)
end

function _GODDESS_MGR_SOCKET_REQ_AETHER_ENABLE(index)
	local frame = ui.GetFrame('goddess_equip_manager')
	local equip_slot = GET_CHILD_RECURSIVELY(frame, 'socket_slot')
	local equip_guid = equip_slot:GetUserValue('ITEM_GUID')
	if equip_guid == 'None' then
		return
	end

	local mat_slot = GET_CHILD_RECURSIVELY(frame, 'aether_open_mat_slot')
	local mat_guid = mat_slot:GetUserValue('ITEM_GUID')
	if mat_guid == 'None' then
		return
	end

	local equip_item = session.GetInvItemByGuid(equip_guid)
	local equip_obj = GetIES(equip_item:GetObject())
	if item_goddess_socket.enable_aether_socket_add(equip_obj) == false then
		return
	end

	local mat_item = session.GetInvItemByGuid(mat_guid)
	local mat_obj = GetIES(mat_item:GetObject())
	if item_goddess_socket.is_aether_socket_material(mat_obj, equip_obj) == false then
		return
	end

	session.ResetItemList()

	session.AddItemID(equip_guid, 1)
	session.AddItemID(mat_guid, 1)

	local result_list = session.GetItemIDList()


	local arg_list = NewStringList()

	arg_list:Add(index)

	item.DialogTransaction('GODDESS_ADD_AETHER_SOCKET', result_list, '', arg_list)
end
-- 소켓 관리 끝

-- 제작
local function pairsByKeys(t, f)
	local a = {}
	for n in pairs(t) do table.insert(a, n) end
	table.sort(a, f)
	local i = 0 -- iterator variable
	local iter = function() -- iterator function
		i = i + 1
		if a[i] == nil then return nil
		else return a[i], t[a[i]]
		end
	end
	return iter
end

local _goddessRecipeTable = {} -- key: DropGroupName, vlaue: className list
local _goddessRecipeTableByGroupName = {} -- key: Item.GroupName, value: className list
local _goddessArmorTable = {}
local function GODDESS_MAKE_INIT_RECIPE_LIST()
	if #_goddessRecipeTable > 0 then
		return
	end

	local clslist, cnt = GetClassList('goddessrecipe')
	for i = 0, cnt - 1 do
		local cls = GetClassByIndexFromList(clslist, i)
		if TryGetProp(cls, "DropGroupName", "None") ~= "None" then
			if _goddessRecipeTable[cls.DropGroupName] == nil then
				_goddessRecipeTable[cls.DropGroupName] = {}
			end

			local recipe_list = _goddessRecipeTable[cls.DropGroupName]
			_goddessRecipeTable[cls.DropGroupName][#recipe_list + 1] = cls.ClassName

			local target_cls = GetClass('Item', cls.TargetItem)
			if _goddessRecipeTableByGroupName[target_cls.GroupName] == nil then
				_goddessRecipeTableByGroupName[target_cls.GroupName] = {}
			end

			local nameList = _goddessRecipeTableByGroupName[target_cls.GroupName]
			_goddessRecipeTableByGroupName[target_cls.GroupName][#nameList + 1] = cls.ClassName

			if target_cls.GroupName == 'Armor' and _goddessArmorTable[target_cls.Material] == nil then
				_goddessArmorTable[target_cls.Material] = true
			end
		end
	end
end

local function GODDESS_MAKE_DROPLIST_INIT(frame)
    local group_list = GET_CHILD_RECURSIVELY(frame, 'make_item_kind_droplist')
    group_list:ClearItems()
    local group_index = 1
    group_list:AddItem(0, '{@st42b}'..ClMsg('PartyShowAll')..'{/}')
	for _group, list in pairsByKeys(_goddessRecipeTable) do
		if _group ~= 'None' then
			group_list:AddItem(group_index, '{@st42b}'.._group..'{/}')
			group_list:SetUserValue('GROUP_INDEX_' .. group_index, _group)
			group_index = group_index + 1
		end
   	end
    
    local type_list = GET_CHILD_RECURSIVELY(frame, 'make_item_type_droplist')
    type_list:ClearItems()
    local type_index = 1
    type_list:AddItem(0, '{@st42b}'..ClMsg('PartyShowAll')..'{/}')
    for _type, list in pairsByKeys(_goddessRecipeTableByGroupName) do
		if _type ~= 'Armor' then -- 방어구는 재료별로 따로 하기로 함
	    	type_list:AddItem(type_index, '{@st42b}'..ClMsg(_type)..'{/}')
	    	type_list:SetUserValue('GROUPNAME_INDEX_' .. type_index, _type)
	    	type_index = type_index + 1
    	end
	end

	for material, dummy in pairsByKeys(_goddessArmorTable) do
		local clmsg = ClMsg('Armor')
		if material ~= 'None' then
			clmsg = clmsg..'-'..ClMsg(material)
		end
		type_list:AddItem(type_index, '{@st42b}'..clmsg..'{/}')
	    type_list:SetUserValue('GROUPNAME_INDEX_' .. type_index, 'Armor')
	    type_list:SetUserValue('MATERIAL_OPTION_' .. type_index, material)
	    type_index = type_index + 1
	end
end

local function GET_GODDESS_MAKE_SHOW_OPTION(frame)
	local group_list = GET_CHILD_RECURSIVELY(frame, 'make_item_kind_droplist')
	local type_list = GET_CHILD_RECURSIVELY(frame, 'make_item_type_droplist')
	local only_enable_equip = GET_CHILD_RECURSIVELY(frame, 'showOnlyEnableEquipCheck')
	local only_have_mat = GET_CHILD_RECURSIVELY(frame, 'showonlyhavemat')

	return group_list:GetUserValue('GROUP_INDEX_' .. group_list:GetSelItemIndex()), 
		   type_list:GetUserValue('MATERIAL_OPTION_' .. type_list:GetSelItemIndex()), 
		   type_list:GetUserValue('GROUPNAME_INDEX_' .. type_list:GetSelItemIndex()),
		   only_enable_equip:IsChecked(),
		   only_have_mat:IsChecked()
end

local function GET_GODDESS_MAKE_LIST_BY_GROUP(frame)
	local group_list = GET_CHILD_RECURSIVELY(frame, 'make_item_kind_droplist')
	return _goddessRecipeTable[group_list:GetUserValue('GROUP_INDEX_' .. group_list:GetSelItemIndex())]
end

local function GET_GODDESS_MAKE_LIST_BY_CLASS_TYPE(frame)
	local type_list = GET_CHILD_RECURSIVELY(frame, 'make_item_type_droplist')
	return _goddessRecipeTable[type_list:GetUserValue('GROUPNAME_INDEX_' .. type_list:GetSelItemIndex())]
end

local function GET_GODDESS_MAKE_TARGET_LIST(frame)
	local list = GET_GODDESS_MAKE_LIST_BY_GROUP(frame)
	local cnt = 0
	if list == nil then
		list = GET_GODDESS_MAKE_LIST_BY_CLASS_TYPE(frame)
	end
	return list
end

local function IS_NEED_TO_SHOW_GODDESS_RECIPE(frame, recipeCls, checkGroup, checkMaterial, checkGroupName, checkEquipable, checkHaveMaterial)
	if checkGroup ~= 'None' then -- 그룹 체크
		if recipeCls.DropGroupName ~= checkGroup then
			return false
		end
	end

	local targetItem = GetClass('Item', recipeCls.TargetItem)
	if checkGroupName ~= 'None' then -- 클래스 타입 체크
		if targetItem.GroupName ~= checkGroupName then
			return false
		end

		if checkMaterial ~= 'None' and checkMaterial ~= targetItem.Material then
			return false
		end
	end

	if checkEquipable == 1 then -- 착용 여부 체크
		local prop = geItemTable.GetProp(targetItem.ClassID)
		local result = prop:CheckEquip(GETMYPCLEVEL(), GETMYPCJOB(), GETMYPCGENDER())
		if result ~= 'OK' then
			return false
		end
	end

	if checkHaveMaterial == 1 then -- 재료 체크
		if IS_HAVE_LEGEND_CRAFT_MATERIAL(recipeCls) == false then
			return false
		end
	end
	
	if TryGetProp(recipeCls, "DropGroupName", "None") == "None" then -- 제작 예외처리 체크
		return false
	end

	return true
end

local function GODDESS_MAKE_MAKE_CTRLSET(recipeBox, recipeCls, checkGroup, checkMaterial, checkGroupName, checkEquipable, checkHaveMaterial)
	local frame = ui.GetFrame('goddess_equip_manager')
	if IS_NEED_TO_SHOW_GODDESS_RECIPE(frame, recipeCls, checkGroup, checkMaterial, checkGroupName, checkEquipable, checkHaveMaterial) == false then
		return
	end

	local targetItem = GetClass('Item', recipeCls.TargetItem)
	local ctrlset = recipeBox:CreateOrGetControlSet('earthTowerRecipe', 'RECIPE_'..recipeCls.ClassName, 0, 0)

	local itemCountGBox = GET_CHILD_RECURSIVELY(ctrlset, 'gbox')
    if itemCountGBox ~= nil then
		itemCountGBox:ShowWindow(0)
    end

	-- common
	local tradeBtn = GET_CHILD(ctrlset, 'tradeBtn')
	tradeBtn:SetSkinName('relic_btn_purple')
	tradeBtn:SetTextByKey('text', ClMsg('Manufacture'))
	tradeBtn:SetUserValue('TARGET_RECIPE_NAME', recipeCls.ClassName)
	tradeBtn:SetEventScript(ui.LBUTTONUP, 'GODDESS_MGR_MAKE_EXEC')

	local itemIcon = GET_CHILD(ctrlset, 'itemIcon')
	itemIcon:SetImage(targetItem.Icon)
	SET_ITEM_TOOLTIP_BY_NAME(itemIcon, targetItem.ClassName)

	local itemName = GET_CHILD(ctrlset, 'itemName')
	itemName:SetTextByKey('value', targetItem.Name)

	local exchangeCount = GET_CHILD(ctrlset, 'exchangeCount')
	local labelline_1 = GET_CHILD(ctrlset, 'labelline_1')
	exchangeCount:ShowWindow(0)
	labelline_1:ShowWindow(0)

	-- material
	local matBox = ctrlset:CreateControl('groupbox', 'matBox', itemIcon:GetX() + itemIcon:GetWidth(), itemIcon:GetY(), 500, 150)
	matBox = AUTO_CAST(matBox)
	matBox:SetSkinName('None')
	matBox:EnableScrollBar(0)

	local maxMaterialCnt = recipeCls.MaterialItemSlotCnt
	for i = 1, maxMaterialCnt do
		local materialItemName = TryGetProp(recipeCls, 'MaterialItem_'..i, 'None')
		if materialItemName ~= 'None' then
			local matCtrlset = matBox:CreateOrGetControlSet('craftRecipe_detail_item', 'MATERIAL_'..i, 0, 0)
			matCtrlset:SetUserValue('ClassName', materialItemName)
			matCtrlset:SetUserValue('MATERIAL_IS_SELECTED', 'nonselected')

			local matItemCls = GetClass('Item', materialItemName)
			local item = GET_CHILD(matCtrlset, 'item')
			local require_reinforce = TryGetProp(recipeCls, 'MaterialItemReinforce_'.. i, 0)
			local require_transcend = TryGetProp(recipeCls, 'MaterialItemTranscend_'.. i, 0)
			local prefix = ''
			local prefix_transcend = ''
			if require_reinforce ~= 0 then
				prefix = '{#FF0000}+' .. tostring(require_reinforce) .. '{img craft_reinforce 25 25}' ..  ' {/}'
			end

			if require_transcend ~= 0 then
				prefix_transcend = '{#FF0000}+' .. tostring(require_transcend) .. '{img craft_transcend 25 25}' .. ' {/}'
			end

			item:SetText(prefix_transcend .. prefix .. matItemCls.Name)

			local needcount = GET_CHILD(matCtrlset, 'needcount')
			local matItemCnt = recipeCls['MaterialItemCnt_'..i]
			needcount:SetTextByKey('count', matItemCnt)

			local slot = GET_CHILD(matCtrlset, 'slot')
			slot:SetEventScript(ui.DROP, 'ITEMCRAFT_ON_DROP')
			slot:SetEventScriptArgNumber(ui.DROP, matItemCls.ClassID)
			slot:SetEventScriptArgString(ui.DROP, matItemCnt)
			slot:SetUserValue('recipe_name', recipeCls.ClassName)  -- 제작 레시피
			slot:EnableDrag(0)

			local icon = slot:GetIcon()
			if icon == nil then
				icon = CreateIcon(slot)
			end
			icon:SetImage(matItemCls.Icon)
			icon:SetColorTone('33333333')
		end
	end

	GBOX_AUTO_ALIGN(matBox, 0, 0, 0, true, true, true)
	
	local ypos = math.max(matBox:GetY() + matBox:GetHeight() + 20, itemIcon:GetY() + itemIcon:GetHeight() + 30)
	ctrlset:Resize(ctrlset:GetWidth(), ypos)
end

function GODDESS_MGR_MAKE_MAKE_LIST(frame)
	frame = frame:GetTopParentFrame()
	session.ResetItemList()

	local list_gb = GET_CHILD_RECURSIVELY(frame, 'make_item_list_gb')
	list_gb:RemoveAllChild()

	local checkGroup, checkMaterial, checkGroupName, checkEquipable, checkHaveMaterial = GET_GODDESS_MAKE_SHOW_OPTION(frame)
	local list = GET_GODDESS_MAKE_TARGET_LIST(frame)
	if list ~= nil then
		for i = 1, #list do
			local cls = GetClass('goddessrecipe', list[i])
			GODDESS_MAKE_MAKE_CTRLSET(list_gb, cls, checkGroup, checkMaterial, checkGroupName, checkEquipable, checkHaveMaterial)
		end
	else -- 옵션이 전부 모두 보기인 경우
		local clslist, cnt = GetClassList('goddessrecipe')
		for i = 0, cnt - 1 do
			local cls = GetClassByIndexFromList(clslist, i)
			GODDESS_MAKE_MAKE_CTRLSET(list_gb, cls, checkGroup, checkMaterial, checkGroupName, checkEquipable, checkHaveMaterial)
		end
	end

	GBOX_AUTO_ALIGN(list_gb, 0, 0, 0, true, false, true)
    list_gb:SetScrollPos(0)
end

function GODDESS_MGR_MAKE_CLEAR(frame)
	GODDESS_MGR_MAKE_MAKE_LIST(frame)
end

function GODDESS_MGR_MAKE_OPEN(frame)
	INVENTORY_SET_CUSTOM_RBTNDOWN('None')
	RESET_INVENTORY_ICON()
	GODDESS_MAKE_INIT_RECIPE_LIST()
	GODDESS_MAKE_DROPLIST_INIT(frame)
	GODDESS_MGR_MAKE_MAKE_LIST(frame)
end

function GODDESS_MGR_MAKE_EXEC(parent, btn)
	local recipe_name = btn:GetUserValue('TARGET_RECIPE_NAME')
	local recipe_cls = GetClass('goddessrecipe', recipe_name)
	if recipe_cls == nil then
		return
	end

	local maxMaterialCnt = TryGetProp(recipe_cls, 'MaterialItemSlotCnt', 0)
	for i = 1, maxMaterialCnt do
		local matCtrlset = GET_CHILD_RECURSIVELY(parent, 'MATERIAL_' .. i)
		if matCtrlset ~= nil then
			local btn = GET_CHILD(matCtrlset, 'btn')
			if btn:IsVisible() == 1 then
				ui.SysMsg(ClMsg('NotEnoughRecipe'))
				return
			end
		end
	end

	local yesscp = string.format('_GODDESS_MGR_MAKE_EXEC(\'%s\')', recipe_name)
	local msgbox = ui.MsgBox(ClMsg('ReallyManufactureItem?'), yesscp, '')
	SET_MODAL_MSGBOX(msgbox)
end

function _GODDESS_MGR_MAKE_EXEC(recipe_name)
	local recipe_cls = GetClass('goddessrecipe', recipe_name)
	if recipe_cls == nil then
		return
	end

	local frame = ui.GetFrame('goddess_equip_manager')
	local list_gb = GET_CHILD_RECURSIVELY(frame, 'make_item_list_gb')
	local ctrlset = GET_CHILD(list_gb, 'RECIPE_' .. recipe_name)

	local argList = string.format('%d', recipe_cls.ClassID)
	local guid_list = {}

	local maxMaterialCnt = TryGetProp(recipe_cls, 'MaterialItemSlotCnt', 0)
	for i = 1, maxMaterialCnt do
		local matCtrlset = GET_CHILD_RECURSIVELY(ctrlset, 'MATERIAL_' .. i)
		guid_list[i] = tostring(matCtrlset:GetUserValue(matCtrlset:GetName()))
		if matCtrlset ~= nil then
			local btn = GET_CHILD(matCtrlset, 'btn')
			if btn:IsVisible() == 1 then
				ui.SysMsg(ClMsg('NotEnoughRecipe'))
				return
			end
		end
	end

	ui.SetHoldUI(true)

	local arg_list = NewStringList()
	arg_list:Add(recipe_cls.ClassID)

	session.ResetItemList()
	for i = 1, maxMaterialCnt do
		session.AddItemID(guid_list[i], 1)
	end

	local result_list = session.GetItemIDList()

	item.DialogTransaction('GODDESS_CRAFT_EQUIP', result_list, '', arg_list)
end

function _END_GODDESS_MAKE_EFFECT()
	local frame = ui.GetFrame('goddess_equip_manager')
	GODDESS_MGR_MAKE_CLEAR(frame)
end

function PLAY_GODDESS_MAKE_SUCCESS_EFFECT(frame, msg, item_name, recipe_id)
	ui.OpenFrame('fulldark_itemblacksmith')
	local bg_frame = ui.GetFrame('fulldark_itemblacksmith')

	local resultGbox = GET_CHILD_RECURSIVELY(bg_frame, 'resultGbox')
	local item_cls = GetClass('Item', item_name)
	if item_cls == nil then
		return
	end
	
	local recipe_cls = GetClassByType('goddessrecipe', recipe_id)
	if recipe_cls == nil then
		recipe_cls = GetClassByStrProp('goddessrecipe', 'TargetItem', item_name)
	end
	local bgname = TryGetProp(recipe_cls, 'RecipeBgImg')
	if bgname == nil then
		bgname = 'goddess_Equip'
	end

	local recipebg = GET_CHILD_RECURSIVELY(bg_frame, 'image')
	recipebg:SetImage(bgname)

	local itemIcon = GET_CHILD_RECURSIVELY(resultGbox, 'itemIcon')
	itemIcon:SetImage(item_cls.Icon)
	local screenWidth = ui.GetSceneWidth()
	local screenHeight = ui.GetSceneHeight()
	movie.PlayUIEffect(bg_frame:GetUserConfig('BLACKSMITH_RESULT_EFFECT'), screenWidth / 2, screenHeight / 2, tonumber(bg_frame:GetUserConfig('BLACKSMITH_RESULT_EFFECT_SCALE')))

	local duration = tonumber(frame:GetUserConfig('MAKE_EFFECT_DURATION'))
	bg_frame:SetDuration(duration)
	ReserveScript('_END_GODDESS_MAKE_EFFECT()', duration)
end

function ON_SUCCESS_GODDESS_MAKE_EXEC(frame, msg, arg_str, arg_num)
	ui.SetHoldUI(false)
	local main_tab = GET_CHILD_RECURSIVELY(frame, 'main_tab')
	local index = main_tab:GetSelectItemIndex()
	if index == 4 then
		GODDESS_MGR_INHERIT_CLEAR(frame)
	end
end

function ON_FAILED_GODDESS_MAKE_EXEC(frame, msg, arg_str, arg_num)
	ui.SetHoldUI(false)
	local main_tab = GET_CHILD_RECURSIVELY(frame, 'main_tab')
	local index = main_tab:GetSelectItemIndex()
	if index == 4 then
		GODDESS_MGR_INHERIT_CLEAR(frame)
	end
end
-- 제작 끝

-- 계승
local function GODDESS_MGR_MAKE_INHERIT_TARGET_LIST(gbox, inv_item, item_obj)
	local list = item_goddess_craft.get_inherit_target_item_list(item_obj)
	if list == nil then return end

	gbox:SetUserValue('TARGET_COUNT', #list)

	for i = 1, #list do
		local class_name = list[i]
		local cls = GetClass('Item', class_name)
		if cls == nil then return end
		local ctrlset = gbox:CreateOrGetControlSet('eachitem_in_exchange_weapontype', 'INHERIT_WEAPONTYPE_CSET_'..(i - 1), 0, (i - 1) * 90)
		if ctrlset ~= nil then
			local icon = GET_CHILD_RECURSIVELY(ctrlset, 'item_icon', 'ui::CPicture')

			local result = CHECK_EQUIPABLE(cls.ClassID);
			if result ~= "OK" then
				icon:SetColorTone("FFFF0000");
			end
			icon:ShowWindow(1)
			icon:SetImage(cls.Icon)

			local questionmark = GET_CHILD_RECURSIVELY(ctrlset, 'item_questionmark', 'ui::CPicture')
			questionmark:ShowWindow(0)
			
			local item_name = GET_LEGEND_PREFIX_ITEM_NAME(cls, TryGetProp(item, 'LegendPrefix', 'None'))
			local name_str = string.format('{@st42}{s20}%s{/}{/}', item_name)
			local name = GET_CHILD_RECURSIVELY(ctrlset, 'item_name', 'ui::CRichText')
			name:SetText(name_str)

			ctrlset:ShowWindow(1)
			ctrlset:SetUserValue('ITEM_ID', cls.ClassID)
			local radioBtn = GET_CHILD_RECURSIVELY(ctrlset, 'radioBtn', 'ui::CRadioButton')
			if radioBtn ~= nil then
				radioBtn:SetEventScript(ui.LBUTTONDOWN, 'GODDESS_MGR_INHERIT_RADIO_BTN_CLICK')
				radioBtn:SetCheck(false)
				radioBtn:ShowWindow(1)
			end
		end
	end

	local _ctrlset = GET_CHILD(gbox, 'INHERIT_WEAPONTYPE_CSET_0')
	if _ctrlset ~= nil then
		local _btn = GET_CHILD(_ctrlset, 'radioBtn')
		GODDESS_MGR_INHERIT_RADIO_BTN_CLICK(_ctrlset, _btn)
	end
end

function GODDESS_MGR_INHERIT_RADIO_BTN_CLICK(parent, btn)
	local frame = parent:GetTopParentFrame()
	local gbox = GET_CHILD_RECURSIVELY(frame, 'inherit_inner_bg')
	local target_cnt = gbox:GetUserIValue('TARGET_COUNT')
	for i = 0, target_cnt - 1 do
		local ctrlset = GET_CHILD(gbox, 'INHERIT_WEAPONTYPE_CSET_' .. i)
		local _radioBtn = GET_CHILD(ctrlset, 'radioBtn', 'ui::CRadioButton')
		_radioBtn:SetEventScript(ui.LBUTTONUP, 'GODDESS_MGR_INHERIT_RADIO_BTN_CLICK')
		if _radioBtn ~= btn then
			_radioBtn:SetCheck(false)
		else
			btn:SetCheck(true)
			gbox:SetUserValue('NOW_SELECT_ITEM_ID', ctrlset:GetUserIValue('ITEM_ID'))
		end
	end

	GODDESS_MGR_INHERIT_REG_TARGET(frame)
end

function GODDESS_MGR_INHERIT_REG_TARGET(frame)
	local before_slot = GET_CHILD_RECURSIVELY(frame, 'inherit_slot_before')
	local guid = before_slot:GetUserValue('ITEM_GUID')
	if guid == 'None' then return end

	local inv_item = session.GetInvItemByGuid(guid)
	if inv_item == nil then return end

	local item_obj = GetIES(inv_item:GetObject())
	local reinf_value, enchant_name, enchant_value = item_goddess_craft.get_inherit_option_value(item_obj)

	local gbox = GET_CHILD_RECURSIVELY(frame, 'inherit_inner_bg')
	local target_cls_id = gbox:GetUserIValue('NOW_SELECT_ITEM_ID')
	local target_cls = GetClassByType('Item', target_cls_id)
	if target_cls == nil then return end

	local inherit_help_text = GET_CHILD_RECURSIVELY(frame, 'inherit_help_text')
	inherit_help_text:ShowWindow(0)

	local arrow_pic = GET_CHILD_RECURSIVELY(frame, 'inherit_picture_arrow')
	arrow_pic:ShowWindow(1)

	local inherit_after_bg = GET_CHILD_RECURSIVELY(frame, 'inherit_after_bg')
	inherit_after_bg:ShowWindow(1)

	local after_slot = GET_CHILD_RECURSIVELY(frame, 'inherit_slot_after')

	local after_slot_icon = SET_SLOT_ITEM_CLS(after_slot, target_cls)
	if after_slot_icon ~= nil then		
		local key = 'copy_prop:Reinforce_2' .. '/' .. tostring(reinf_value) .. ';'
		for i = 1, 10 do
			local name = 'EnchantSkillName_' .. i
			local name1 = 'EnchantSkillLevel_' .. i
			if TryGetProp(item_obj, name, 'None') ~= 'None' then
				key = key .. name .. '/' .. TryGetProp(item_obj, name, 'None') .. ';'
				key = key .. name1 .. '/' .. TryGetProp(item_obj, name1, 0) .. ';'
			end
		end
		
		after_slot_icon:SetTooltipStrArg(key)
	end

	local after_name = GET_CHILD_RECURSIVELY(frame, 'inherit_after_item_name')
	local after_enchant = GET_CHILD_RECURSIVELY(frame, 'inherit_after_item_enchant')
	local dont_equip = GET_CHILD_RECURSIVELY(frame, 'inherit_dont_equip_item')

	local name_str = dic.getTranslatedStr(TryGetProp(target_cls, 'Name', 'None'))
	if reinf_value ~= nil then
		if reinf_value > 0 then
			name_str = string.format('+%d %s', reinf_value, name_str)
		end
		
		if enchant_name ~= 'None' or enchant_value ~= 0 then
			local enchant_str = _GET_RANDOM_OPTION_RARE_CLIENT_TEXT(enchant_name, enchant_value)			
			if enchant_str ~= nil then
				after_enchant:SetTextByKey('value', enchant_str)
				after_enchant:ShowWindow(1)
			end
		else
			after_enchant:ShowWindow(0)
		end

	else
		after_enchant:ShowWindow(0)
	end

	local result = CHECK_EQUIPABLE(target_cls_id);
	if result ~= "OK" then
		dont_equip:ShowWindow(1)
	else
		dont_equip:ShowWindow(0)
	end

	after_name:SetTextByKey('name', name_str)	
end

function GODDESS_MGR_INHERIT_UPDATE_TARGET_LIST(frame)
	local inherit_inner_bg = GET_CHILD_RECURSIVELY(frame, 'inherit_inner_bg')
	inherit_inner_bg:RemoveAllChild()

	local inherit_item_text = GET_CHILD_RECURSIVELY(frame, 'inherit_item_text')

	local before_slot = GET_CHILD_RECURSIVELY(frame, 'inherit_slot_before')
	local guid = before_slot:GetUserValue('ITEM_GUID')
	if guid ~= 'None' then
		local inv_item = session.GetInvItemByGuid(guid)
		if inv_item == nil then return end

		local item_obj = GetIES(inv_item:GetObject())

		inherit_item_text:ShowWindow(1)

		GODDESS_MGR_MAKE_INHERIT_TARGET_LIST(inherit_inner_bg, inv_item, item_obj)
	else
		inherit_item_text:ShowWindow(0)
	end
end

function GODDESS_MGR_INHERIT_MAT_DROP(parent, slot, arg_str, arg_num)
	local frame = parent:GetTopParentFrame()
	local lift_icon = ui.GetLiftIcon()
	local from_frame = lift_icon:GetTopParentFrame()
    if from_frame:GetName() == 'inventory' then
        local icon_info = lift_icon:GetInfo()
        local guid = icon_info:GetIESID()
        local inv_item = session.GetInvItemByGuid(guid)
		if inv_item == nil then return end
		
		local item_obj = GetIES(inv_item:GetObject())
		if item_obj == nil then return end

		GODDESS_MGR_INHERIT_REG_ITEM(frame, inv_item, item_obj)
	end
end

function GODDESS_MGR_INHERIT_INV_RBTN(item_obj, slot, guid)
	local frame = ui.GetFrame('goddess_equip_manager')

	local inv_item = session.GetInvItemByGuid(guid)
	if inv_item ~= nil then
		GODDESS_MGR_INHERIT_REG_ITEM(frame, inv_item, item_obj)
	end
end

-- 계승 등록
function GODDESS_MGR_INHERIT_REG_ITEM(frame, inv_item, item_obj)
	local ret, msg = item_goddess_craft.check_enable_inherit_item(item_obj)
	if ret == false then		
		if msg ~= nil then
			ui.SysMsg(ClMsg(msg))
		else
		ui.SysMsg(ClMsg('IMPOSSIBLE_ITEM'))
		end
		return
	end

	local grade = TryGetProp(item_obj, 'ItemGrade', 0)
	if grade == 5 then		
		if item_goddess_craft.check_enable_inherit_legend_item(item_obj) == false then
			local ret1, msg1 = IS_ENABLE_RELEASE_OPTION(item_obj)			
			if ret1 == false then
				ui.SysMsg(ClMsg('CantInheritIcorEquip'))
			else
				if msg1 ~= nil then
					ui.SysMsg(ClMsg(msg1))
				else
				ui.SysMsg(ClMsg('IMPOSSIBLE_ITEM'))
			end
			end
			return
		end

		local item_obj_className = TryGetProp(item_obj, "ClassName", "None")
		if string.find(item_obj_className, "EP12_PVP") ~= nil then
			ui.SysMsg(ClMsg('IMPOSSIBLE_ITEM'))
			return
		end
	end

	local before_slot = GET_CHILD_RECURSIVELY(frame, 'inherit_slot_before')
	SET_SLOT_ITEM(before_slot, inv_item)
	before_slot:SetUserValue('ITEM_GUID', inv_item:GetIESID())

	local before_pic = GET_CHILD_RECURSIVELY(frame, 'inherit_picture_before')
	before_pic:ShowWindow(0)

	local name_str = dic.getTranslatedStr(TryGetProp(item_obj, 'Name', 'None'))
	local before_reinf = TryGetProp(item_obj, 'Reinforce_2', 0)
	local before_trans = TryGetProp(item_obj, 'Transcend', 0)
	if before_reinf > 0 then
		name_str = string.format('+%d %s', before_reinf, name_str)
	end
	local before_name = GET_CHILD_RECURSIVELY(frame, 'inherit_before_item_name')
	before_name:SetTextByKey('name', name_str)

	local before_reinf_txt = GET_CHILD_RECURSIVELY(frame, 'inherit_before_item_reinf')
	before_reinf_txt:SetTextByKey('value', before_reinf)
	before_reinf_txt:ShowWindow(1)

	local before_trans_txt = GET_CHILD_RECURSIVELY(frame, 'inherit_before_item_trans')
	before_trans_txt:SetTextByKey('value', before_trans)
	before_trans_txt:ShowWindow(1)
	
	local before_enchant = GET_CHILD_RECURSIVELY(frame, 'inherit_before_item_enchant')
	local enchant_txt = GET_RANDOM_OPTION_RARE_CLIENT_TEXT(item_obj)
	before_enchant:SetTextByKey('value', enchant_txt)
	
	GODDESS_MGR_INHERIT_UPDATE_TARGET_LIST(frame)
end

function GODDESS_MGR_INHERIT_ITEM_REMOVE(parent, slot)
	local frame = parent:GetTopParentFrame()
	GODDESS_MGR_INHERIT_CLEAR(frame)
end

function GODDESS_MGR_INHERIT_CLEAR(frame)
	local before_slot = GET_CHILD_RECURSIVELY(frame, 'inherit_slot_before')
	before_slot:ClearIcon()
	before_slot:SetUserValue('ITEM_GUID', 'None')

	local before_pic = GET_CHILD_RECURSIVELY(frame, 'inherit_picture_before')
	before_pic:ShowWindow(1)

	local before_name = GET_CHILD_RECURSIVELY(frame, 'inherit_before_item_name')
	before_name:SetTextByKey('name', '')

	local before_reinf = GET_CHILD_RECURSIVELY(frame, 'inherit_before_item_reinf')
	before_reinf:SetTextByKey('value', 0)
	before_reinf:ShowWindow(0)

	local before_trans = GET_CHILD_RECURSIVELY(frame, 'inherit_before_item_trans')
	before_trans:SetTextByKey('value', 0)
	before_trans:ShowWindow(0)
	
	local before_enchant = GET_CHILD_RECURSIVELY(frame, 'inherit_before_item_enchant')
	before_enchant:SetTextByKey('value', '')

	local after_slot = GET_CHILD_RECURSIVELY(frame, 'inherit_slot_after')
	after_slot:ClearIcon()

	local after_name = GET_CHILD_RECURSIVELY(frame, 'inherit_after_item_name')
	after_name:SetTextByKey('name', '')

	local after_enchant = GET_CHILD_RECURSIVELY(frame, 'inherit_after_item_enchant')
	after_enchant:SetTextByKey('value', '')

	local arrow_pic = GET_CHILD_RECURSIVELY(frame, 'inherit_picture_arrow')
	arrow_pic:ShowWindow(0)

	local inherit_after_bg = GET_CHILD_RECURSIVELY(frame, 'inherit_after_bg')
	inherit_after_bg:ShowWindow(0)
	
	local inherit_help_text = GET_CHILD_RECURSIVELY(frame, 'inherit_help_text')
	inherit_help_text:SetTextByKey('text', ClMsg('GoddessInheritanceMsg'))
	inherit_help_text:ShowWindow(1)

	GODDESS_MGR_INHERIT_UPDATE_TARGET_LIST(frame)
end

function GODDESS_MGR_INHERIT_OPEN(frame)
	GODDESS_MGR_INHERIT_CLEAR(frame)
	INVENTORY_SET_CUSTOM_RBTNDOWN('GODDESS_MGR_INHERIT_INV_RBTN')
end

function GODDESS_MGR_INHERIT_EXEC(parent, btn)
	local frame = parent:GetTopParentFrame()
	local slot = GET_CHILD_RECURSIVELY(frame, 'inherit_slot_before')
	local guid = slot:GetUserValue('ITEM_GUID')
	if guid == 'None' then return end
	
	local inv_item = session.GetInvItemByGuid(guid)
	if inv_item == nil then return end

	local item_obj = GetIES(inv_item:GetObject())
	local item_name = dic.getTranslatedStr(TryGetProp(item_obj, 'Name', 'None'))

	local list_bg = GET_CHILD_RECURSIVELY(frame, 'inherit_inner_bg')
	local selected_id = list_bg:GetUserIValue('NOW_SELECT_ITEM_ID')
	if selected_id <= 0 then return end

	local selected_cls = GetClassByType("Item", selected_id)
	if selected_cls == nil then return end

	local is_acc = false
	if TryGetProp(item_obj, 'ClassType', 'None') == 'Neck' or TryGetProp(item_obj, 'ClassType', 'None') == 'Ring' then
		is_acc = true
	end
	local grade = TryGetProp(item_obj, 'ItemGrade', 0)

	local selected_lv = TryGetProp(selected_cls, "UseLv", 1)
	if TryGetProp(GetMyPCObject(), 'Lv', 1) < tonumber(selected_lv) then
		ui.SysMsg(ScpArgMsg("CannotBecauseLowLevel{LEVEL}", "LEVEL", selected_lv))
		return	
	end

	local clmsg = 'AllItemPropertyResetAlert'
	local _title = 'TitleAllItemPropertyResetAlert'
	if is_acc == false then
		if grade < 6 then
	if TryGetProp(item_obj, 'Transcend', 'None') == 10 and TryGetProp(item_obj, 'Reinforce_2', 'None') > 10 then
		clmsg = 'AllItemPropertyAlert'
	end
		else
			clmsg = 'AccItemPropertyAlert'	
			if item_goddess_growth.is_goddess_growth_item(item_obj) then
				clmsg = 'NoInheritReinforcement'
				_title = 'ProcessInheritance'
			end
		end
	else
		clmsg = 'AccItemPropertyAlert'
	end

	

	local item_classtype = TryGetProp(item_obj, 'ClassType', 'None')
	local select_classtype = TryGetProp(selected_cls, 'ClassType', 'None')
	local yesscp = '_GODDESS_MGR_INHERIT_EXEC'
	if item_classtype ~= select_classtype then
		yesscp = 'WARNINGMSGBOX_FRAME_INHERIT'
	end

	local option = {}
	option.ChangeTitle = _title
	option.CompareTextColor = nil
	option.CompareTextDesc = ClMsg('ReallyGoddessInherit')

	WARNINGMSGBOX_EX_FRAME_OPEN(frame, nil, clmsg .. ';Succession/' .. yesscp, 0, option)
end

function WARNINGMSGBOX_FRAME_INHERIT()
	local from_frame = ui.GetFrame('goddess_equip_manager')
	if from_frame:IsVisible() == 0 then return end

	local slot = GET_CHILD_RECURSIVELY(from_frame, 'inherit_slot_before')
	local guid = slot:GetUserValue('ITEM_GUID')
	if guid == 'None' then return end
	
	local inv_item = session.GetInvItemByGuid(guid)
	if inv_item == nil then return end

	local item_obj = GetIES(inv_item:GetObject())

	local list_bg = GET_CHILD_RECURSIVELY(from_frame, 'inherit_inner_bg')
	local selected_id = list_bg:GetUserIValue('NOW_SELECT_ITEM_ID')
	if selected_id <= 0 then return end

	local selected_cls = GetClassByType("Item", selected_id)
	if selected_cls == nil then return end
	
	ui.OpenFrame("warningmsgbox")
	local itemName = TryGetProp(item_obj, "Name", "None")
	local selectedName = TryGetProp(selected_cls, "Name", "None")

	local clmsg = ScpArgMsg('OtherSlotEquipMent{ITEM1}{ITEM2}', 'ITEM1', itemName, 'ITEM2', selectedName)

	local frame = ui.GetFrame('warningmsgbox')
	frame:EnableHide(1)
	
	local warningText = GET_CHILD_RECURSIVELY(frame, "warningtext")
	warningText:SetText(clmsg)

	local yesBtn = GET_CHILD_RECURSIVELY(frame, "yes")
	tolua.cast(yesBtn, "ui::CButton")
	local noBtn = GET_CHILD_RECURSIVELY(frame, "no")
	tolua.cast(noBtn, "ui::CButton")

	yesBtn:SetEventScript(ui.LBUTTONUP, '_GODDESS_MGR_INHERIT_EXEC')

	local buttonMargin = noBtn:GetMargin()
	local warningbox = GET_CHILD_RECURSIVELY(frame, 'warningbox')
	local totalHeight = warningbox:GetY() + warningText:GetY() + warningText:GetHeight() + noBtn:GetHeight() + 2 * buttonMargin.bottom

	yesBtn:ShowWindow(1)
	noBtn:ShowWindow(1)

	local input_frame = GET_CHILD_RECURSIVELY(frame, "input")
	local showTooltipCheck = GET_CHILD_RECURSIVELY(frame, "cbox_showTooltip")
	local okBtn = GET_CHILD_RECURSIVELY(frame, "ok")
	showTooltipCheck:ShowWindow(0)
	input_frame:ShowWindow(0)
	okBtn:ShowWindow(0)

	local bg = GET_CHILD_RECURSIVELY(frame, 'bg')
	warningbox:Resize(warningbox:GetWidth(), totalHeight)
	bg:Resize(bg:GetWidth(), totalHeight)
	frame:Resize(frame:GetWidth(), totalHeight)
end

function _GODDESS_MGR_INHERIT_EXEC()
	ui.CloseFrame("warningmsgbox")

	local frame = ui.GetFrame('goddess_equip_manager')
	local slot = GET_CHILD_RECURSIVELY(frame, 'inherit_slot_before')
	local guid = slot:GetUserValue('ITEM_GUID')
	if guid == 'None' then return end

	local list_bg = GET_CHILD_RECURSIVELY(frame, 'inherit_inner_bg')
	local selected_id = list_bg:GetUserIValue('NOW_SELECT_ITEM_ID')
	if selected_id <= 0 then return end
	
	local arg_list = string.format('%d', selected_id)

	pc.ReqExecuteTx_Item('GODDESS_CRAFT_EQUIP_BY_INHERIT', guid, arg_list)
end

function ON_SUCCESS_GODDESS_INHERIT_EXEC(frame, msg, arg_str, arg_num)
	ui.SetHoldUI(false)
	GODDESS_MGR_INHERIT_CLEAR(frame)
end
-- 계승 끝

-- 계열 변경
local function GODDESS_MGR_MAKE_CONVERT_TARGET_LIST(gbox, inv_item, item_obj)
	local conv_group = TryGetProp(item_obj, 'ExchangeGroup', 'None')
	if conv_group == 'None' then return end

	local list = GetExchangeItemList(conv_group, TryGetProp(item_obj, 'ClassName', 'None'))
	if list == nil then return end

	gbox:SetUserValue('TARGET_COUNT', #list)

	for i = 1, #list do
		local class_name = list[i]
		local cls = GetClass('Item', class_name)
		if cls == nil then return end
		local ctrlset = gbox:CreateOrGetControlSet('eachitem_in_exchange_weapontype', 'CONVERT_WEAPONTYPE_CSET_'..(i - 1), 0, (i - 1) * 90)
		if ctrlset ~= nil then
			local icon = GET_CHILD_RECURSIVELY(ctrlset, 'item_icon', 'ui::CPicture')
			icon:ShowWindow(1)
			icon:SetImage(cls.Icon)

			local questionmark = GET_CHILD_RECURSIVELY(ctrlset, 'item_questionmark', 'ui::CPicture')
			questionmark:ShowWindow(0)
			
			local item_name = GET_LEGEND_PREFIX_ITEM_NAME(cls, TryGetProp(item, 'LegendPrefix', 'None'))
			local name_str = string.format('{@st42}{s20}%s{/}{/}', item_name)
			local name = GET_CHILD_RECURSIVELY(ctrlset, 'item_name', 'ui::CRichText')
			name:SetText(name_str)

			ctrlset:ShowWindow(1)
			ctrlset:SetUserValue('ITEM_ID', cls.ClassID)

			local radioBtn = GET_CHILD_RECURSIVELY(ctrlset, 'radioBtn', 'ui::CRadioButton')
			if radioBtn ~= nil then
				radioBtn:SetEventScript(ui.LBUTTONUP, 'GODDESS_MGR_CONVERT_RADIO_BTN_CLICK')
				radioBtn:SetCheck(false)
				radioBtn:ShowWindow(1)
			end
		end
	end
	
	local _ctrlset = GET_CHILD(gbox, 'CONVERT_WEAPONTYPE_CSET_0')
	if _ctrlset ~= nil then
		local _btn = GET_CHILD(_ctrlset, 'radioBtn')
		GODDESS_MGR_CONVERT_RADIO_BTN_CLICK(_ctrlset, _btn)
	end
end

function GODDESS_MGR_CONVERT_RADIO_BTN_CLICK(parent, btn)
	local frame = parent:GetTopParentFrame()
	local gbox = GET_CHILD_RECURSIVELY(frame, 'convert_inner_bg')
	local target_cnt = gbox:GetUserIValue('TARGET_COUNT')
	for i = 0, target_cnt - 1 do
		local ctrlset = GET_CHILD(gbox, 'CONVERT_WEAPONTYPE_CSET_' .. i)
		local _radioBtn = GET_CHILD(ctrlset, 'radioBtn', 'ui::CRadioButton')
		_radioBtn:SetEventScript(ui.LBUTTONUP, 'GODDESS_MGR_CONVERT_RADIO_BTN_CLICK')
		if _radioBtn ~= btn then
			_radioBtn:SetCheck(false)
		else
			btn:SetCheck(true)
			gbox:SetUserValue('NOW_SELECT_ITEM_ID', ctrlset:GetUserIValue('ITEM_ID'))
		end
	end

	GODDESS_MGR_CONVERT_MAT_LIST_UPDATE(frame)
	GODDESS_MGR_CONVERT_REG_TARGET(frame)
end

function GODDESS_MGR_CONVERT_MAT_LIST_UPDATE(frame)
	if frame == nil then return end

	local before_slot = GET_CHILD_RECURSIVELY(frame, 'convert_slot_before')
	local guid = before_slot:GetUserValue('ITEM_GUID')
	if guid == 'None' then return end

	local inv_item = session.GetInvItemByGuid(guid)
	if inv_item == nil then return end

	local gbox = GET_CHILD_RECURSIVELY(frame, 'convert_inner_bg')
	local target_cls_id = gbox:GetUserIValue('NOW_SELECT_ITEM_ID')
	local target_cls = GetClassByType('Item', target_cls_id)
	if target_cls == nil then return end
	
	local pc = GetMyPCObject()
	if pc == nil then return end

	local mat_list_bg = GET_CHILD_RECURSIVELY(frame, 'convert_mat_list_bg')
	if mat_list_bg == nil then return end

	local convert_help_text = GET_CHILD_RECURSIVELY(frame, 'convert_help_text')
	convert_help_text:ShowWindow(0)

	local drawDivisionArrow = mat_list_bg:CreateOrGetControlSet('draw_division_arrow', 'DIVISION_ARROW', 12, 0)
	local divisionArrow = GET_CHILD_RECURSIVELY(drawDivisionArrow, 'division_arrow')

	local taget_is= 'Armor'  

	if TryGetProp(target_cls, "EquipGroup" ,"None") == "Weapon" or TryGetProp(target_cls, "EquipGroup" ,"None") == "THWeapon" or TryGetProp(target_cls, "EquipGroup" ,"None") == "SubWeapon" then
		taget_is = 'Weapon'
	elseif TryGetProp(target_cls, "ClassType" ,"None") == "Neck" or TryGetProp(target_cls, "ClassType" ,"None") == "Ring" then
		taget_is = 'Acc'
	end

	-- material
	local ex_group = TryGetProp(target_cls, 'ExchangeGroup', 'None')
	
	if ex_group == 'Weapon_Vasilisa' and taget_is == 'Weapon' then
		local invCareItemCount2 = GetInvItemCount(pc, 'Exchange_Weapon_Book_460_14d')
		if invCareItemCount2 > 0 then
			ex_group = 'Weapon_Vasilisa_Care'
		end
	end

	local nameList, countList = GET_EXCHANGE_WEAPONTYPE_MATERIAL(ex_group, target_cls.ClassName)
	if nameList ~= nil and countList ~= nil and #nameList > 0 and #countList > 0 then
		for i = 1, #nameList do
			local ctrlSet = mat_list_bg:CreateOrGetControlSet('eachmaterial_in_exchangeantique', 'CONVERT_WEAPONTYPE_MAT_CSET'..i, 20, (i - 1) * 40)
			 if ctrlSet ~= nil then
				local icon = GET_CHILD_RECURSIVELY(ctrlSet, 'material_icon', 'ui::CPicture')
				local questionmark = GET_CHILD_RECURSIVELY(ctrlSet, 'material_questionmark', 'ui::CPicture');
				local name = GET_CHILD_RECURSIVELY(ctrlSet, 'material_name', 'ui::CRichText')
				local count = GET_CHILD_RECURSIVELY(ctrlSet, 'material_count', 'ui::CRichText')
				local grade = GET_CHILD_RECURSIVELY(ctrlSet, 'grade', 'ui::CRichText');

				icon:ShowWindow(1)
				count:ShowWindow(1)
				questionmark:ShowWindow(0)

				local materialArg = nameList[i]
				local itemcls = nil
				local invItemCount = 0
				if countList[i] > 0 then
					if i - 1 < #nameList then
						ctrlSet:ShowWindow(1)
						local item_count = 0
						local invItemList = session.GetInvItemList();
						local guidList = invItemList:GetGuidList();
						local cnt = guidList:Count();

						for j = 1, cnt - 1 do
							local guid = guidList:Get(j);
							local invItem = invItemList:GetItemByGuid(guid);
							if invItem ~= nil and invItem:GetObject() ~= nil then
								local itemObj = GetIES(invItem:GetObject());
								if TryGetProp(itemObj, 'StringArg', 'None') == materialArg then
									itemcls = itemObj
									item_count = item_count + invItem.count
								end
							end
						end
						invItemCount = item_count

						if invItemCount < countList[i] then
							count:SetTextByKey('color', '{#EE0000}')
							frame:SetUserValue('IS_ABLE_EXCHANGE', 0)
						else
							count:SetTextByKey('color', nil);
							frame:SetUserValue('IS_ABLE_EXCHANGE', 1)
						end
						
						if itemcls ~= nil then
						count:SetTextByKey('curCount', invItemCount)
						count:SetTextByKey('needCount', countList[i])
						session.AddItemID(itemcls.ClassID, countList[i])
						end
					else
						ctrlSet:ShowWindow(0)
					end
					if itemcls ~= nil then
						name:SetText(itemcls.Name)
						icon:SetImage(itemcls.Icon)
					end
				end
			 end
		end
	end
end

function GODDESS_MGR_CONVERT_REG_TARGET(frame)
	local before_slot = GET_CHILD_RECURSIVELY(frame, 'convert_slot_before')
	local guid = before_slot:GetUserValue('ITEM_GUID')
	if guid == 'None' then return end

	local inv_item = session.GetInvItemByGuid(guid)
	if inv_item == nil then return end

	local item_obj = GetIES(inv_item:GetObject())
	local reinf_value = TryGetProp(item_obj, 'Reinforce_2', 0)

	local gbox = GET_CHILD_RECURSIVELY(frame, 'convert_inner_bg')
	local target_cls_id = gbox:GetUserIValue('NOW_SELECT_ITEM_ID')
	local target_cls = GetClassByType('Item', target_cls_id)
	if target_cls == nil then return end

	local arrow_pic = GET_CHILD_RECURSIVELY(frame, 'convert_picture_arrow')
	arrow_pic:ShowWindow(1)

	local after_pic = GET_CHILD_RECURSIVELY(frame, 'convert_picture_after')
	after_pic:ShowWindow(0)

	local after_slot = GET_CHILD_RECURSIVELY(frame, 'convert_slot_after')

	local img =	GET_EQUIP_ITEM_IMAGE_NAME(target_cls, "TooltipImage")
	SET_SLOT_IMG(after_slot, img)
	SET_ITEM_TOOLTIP_ALL_TYPE(after_slot:GetIcon(), nil, target_cls.ClassName, '', target_cls.ClassID, 0)
	if TryGetProp(item_obj, 'CharacterBelonging', 0) == 1 then
		after_slot:GetIcon():SetTooltipStrArg('char_belonging')
	end
	
	local after_name = GET_CHILD_RECURSIVELY(frame, 'convert_after_item_name')
	local name_str = dic.getTranslatedStr(TryGetProp(target_cls, 'Name', 'None'))
	if reinf_value > 0 then
		name_str = string.format('+%d %s', reinf_value, name_str)
	end

	after_name:SetTextByKey('name', name_str)
end

function GODDESS_MGR_CONVERT_UPDATE_TARGET_LIST(frame)
	local convert_inner_bg = GET_CHILD_RECURSIVELY(frame, 'convert_inner_bg')
	convert_inner_bg:RemoveAllChild()

	local convert_item_text = GET_CHILD_RECURSIVELY(frame, 'convert_item_text')

	local before_slot = GET_CHILD_RECURSIVELY(frame, 'convert_slot_before')
	local guid = before_slot:GetUserValue('ITEM_GUID')
	if guid ~= 'None' then
		local inv_item = session.GetInvItemByGuid(guid)
		if inv_item == nil then return end

		local item_obj = GetIES(inv_item:GetObject())

		convert_item_text:ShowWindow(1)

		GODDESS_MGR_MAKE_CONVERT_TARGET_LIST(convert_inner_bg, inv_item, item_obj)
	else
		convert_item_text:ShowWindow(0)
	end
end

function GODDESS_MGR_CONVERT_MAT_DROP(parent, slot, arg_str, arg_num)
	local frame = parent:GetTopParentFrame()
	local lift_icon = ui.GetLiftIcon()
	local from_frame = lift_icon:GetTopParentFrame()
    if from_frame:GetName() == 'inventory' then
        local icon_info = lift_icon:GetInfo()
        local guid = icon_info:GetIESID()
        local inv_item = session.GetInvItemByGuid(guid)
		if inv_item == nil then return end
		
		local item_obj = GetIES(inv_item:GetObject())
		if item_obj == nil then return end

		GODDESS_MGR_CONVERT_REG_ITEM(frame, inv_item, item_obj)
	end
end

function GODDESS_MGR_CONVERT_INV_RBTN(item_obj, slot, guid)
	local frame = ui.GetFrame('goddess_equip_manager')

	local inv_item = session.GetInvItemByGuid(guid)
	if inv_item ~= nil then
		GODDESS_MGR_CONVERT_REG_ITEM(frame, inv_item, item_obj)
	end
end

function GODDESS_MGR_CONVERT_REG_ITEM(frame, inv_item, item_obj)
	local grade = TryGetProp(item_obj, 'ItemGrade', 0)
	local type = TryGetProp(item_obj, 'ItemType', 'None')
	if type ~= 'Equip' then
		ui.SysMsg(ClMsg('IMPOSSIBLE_ITEM'))
		return
	end

	if grade < 6 then
		ui.SysMsg(ClMsg('IMPOSSIBLE_ITEM'))
		return
	end
	
	local msg = 'IMPOSSIBLE_ITEM'
    local _ret = false
	local targetGruop = TryGetProp(item_obj, 'ExchangeGroup', 'None')
	
    _ret, msg = item_goddess_craft.is_able_to_convert(item_obj, targetGruop)
	if _ret == false then
		ui.SysMsg(ClMsg(msg))
		return
    end

	local before_slot = GET_CHILD_RECURSIVELY(frame, 'convert_slot_before')
	SET_SLOT_ITEM(before_slot, inv_item)
	before_slot:SetUserValue('ITEM_GUID', inv_item:GetIESID())

	local before_pic = GET_CHILD_RECURSIVELY(frame, 'convert_picture_before')
	before_pic:ShowWindow(0)

	local name_str = dic.getTranslatedStr(TryGetProp(item_obj, 'Name', 'None'))
	local before_reinf = TryGetProp(item_obj, 'Reinforce_2', 0)
	if before_reinf > 0 then
		name_str = string.format('+%d %s', before_reinf, name_str)
	end
	local before_name = GET_CHILD_RECURSIVELY(frame, 'convert_before_item_name')
	before_name:SetTextByKey('name', name_str)
	
	GODDESS_MGR_CONVERT_UPDATE_TARGET_LIST(frame)
end

function GODDESS_MGR_CONVERT_ITEM_REMOVE(parent, slot)
	local frame = parent:GetTopParentFrame()
	GODDESS_MGR_CONVERT_CLEAR(frame)
end

function GODDESS_MGR_CONVERT_CLEAR(frame)
	local before_slot = GET_CHILD_RECURSIVELY(frame, 'convert_slot_before')
	before_slot:ClearIcon()
	before_slot:SetUserValue('ITEM_GUID', 'None')
	
	local before_pic = GET_CHILD_RECURSIVELY(frame, 'convert_picture_before')
	before_pic:ShowWindow(1)

	local before_name = GET_CHILD_RECURSIVELY(frame, 'convert_before_item_name')
	before_name:SetTextByKey('name', '')

	local after_slot = GET_CHILD_RECURSIVELY(frame, 'convert_slot_after')
	after_slot:ClearIcon()

	local after_pic = GET_CHILD_RECURSIVELY(frame, 'convert_picture_after')
	after_pic:ShowWindow(1)

	local after_name = GET_CHILD_RECURSIVELY(frame, 'convert_after_item_name')
	after_name:SetTextByKey('name', '')

	local arrow_pic = GET_CHILD_RECURSIVELY(frame, 'convert_picture_arrow')
	arrow_pic:ShowWindow(0)

	local mat_list_bg = GET_CHILD_RECURSIVELY(frame, 'convert_mat_list_bg')
	mat_list_bg:RemoveAllChild()

	local convert_help_text = GET_CHILD_RECURSIVELY(frame, 'convert_help_text')
	convert_help_text:ShowWindow(1)

	GODDESS_MGR_CONVERT_UPDATE_TARGET_LIST(frame)
end

function GODDESS_MGR_CONVERT_OPEN(frame)
	GODDESS_MGR_CONVERT_CLEAR(frame)
	INVENTORY_SET_CUSTOM_RBTNDOWN('GODDESS_MGR_CONVERT_INV_RBTN')
end

function GODDESS_MGR_CONVERT_EXEC(parent, btn)
	local frame = parent:GetTopParentFrame()
	local slot = GET_CHILD_RECURSIVELY(frame, 'convert_slot_before')
	local guid = slot:GetUserValue('ITEM_GUID')
	if guid == 'None' then return end
	
	local inv_item = session.GetInvItemByGuid(guid)
	if inv_item == nil then return end

	local item_obj = GetIES(inv_item:GetObject())
	local item_name = dic.getTranslatedStr(TryGetProp(item_obj, 'Name', 'None'))

	local list_bg = GET_CHILD_RECURSIVELY(frame, 'convert_inner_bg')
	local selected_id = list_bg:GetUserIValue('NOW_SELECT_ITEM_ID')
	if selected_id <= 0 then return end

	local selected_item_cls = GetClassByNumProp("Item", "ClassID", selected_id);
	if selected_item_cls == nil then return; end

	local clmsg = "None";
	local selectedName = TryGetProp(selected_item_cls, "Name", "None");
	local selected_item_group_name = TryGetProp(selected_item_cls, "GroupName", "None");
	local selected_item_class_type = TryGetProp(selected_item_cls, "ClassType", "None");
		
	if TryGetProp(item_obj, 'IsGoddessIcorOption', 0) == 0 then
		if selected_item_group_name == "Armor" and selected_item_class_type ~= "Shield" then
			clmsg = ScpArgMsg('ReallyDoCraftByConvertArmor{item1}{item2}', 'item1', item_name, 'item2', selectedName);
		else
			clmsg = ScpArgMsg('ReallyDoCraftByConvert{item1}{item2}', 'item1', item_name, 'item2', selectedName);
		end
	else
		if selected_item_group_name == "Armor" and selected_item_class_type ~= "Shield" then
			clmsg = ScpArgMsg('ReallyDoCraftByConvertArmor2{item1}{item2}', 'item1', item_name, 'item2', selectedName);
		else
			clmsg = ScpArgMsg('ReallyDoCraftByConvert2{item1}{item2}', 'item1', item_name, 'item2', selectedName);
		end
	end

	local yesscp = string.format('_GODDESS_MGR_CONVERT_EXEC(%d)', selected_id)
	local msgbox = ui.MsgBox(clmsg, yesscp, '')
	SET_MODAL_MSGBOX(msgbox)
end

function _GODDESS_MGR_CONVERT_EXEC(class_id)
	local frame = ui.GetFrame('goddess_equip_manager')
	local slot = GET_CHILD_RECURSIVELY(frame, 'convert_slot_before')
	local guid = slot:GetUserValue('ITEM_GUID')
	if guid == 'None' then return end

	local arg_list = string.format('%d', class_id)

	pc.ReqExecuteTx_Item('GODDESS_CRAFT_EQUIP_BY_CONVERT', guid, arg_list)
end

function ON_SUCCESS_GODDESS_CONVERT_EXEC(frame, msg, arg_str, arg_num)
	ui.SetHoldUI(false)
	GODDESS_MGR_CONVERT_CLEAR(frame)
end
-- 계열 변경 끝

function CLEAR_REFORGE_MAIN_SLOT(frame)
	local ref_slot = GET_CHILD_RECURSIVELY(frame, 'ref_slot')
	ref_slot:ClearIcon()
	ref_slot:SetUserValue('ITEM_GUID', 'None')	
	local ref_item_name = GET_CHILD_RECURSIVELY(frame, 'ref_item_name')
	ref_item_name:ShowWindow(0)
	local ref_item_text = GET_CHILD_RECURSIVELY(frame, 'ref_item_text')
	ref_item_text:ShowWindow(1)		
	local ref_item_reinf_text = GET_CHILD_RECURSIVELY(frame, 'ref_item_reinf_text')
	ref_item_reinf_text:SetTextByKey('value', 0)	
end

function init_goddess_icor_spot_list(frame, type)
	local goddess_icor_spot_list = GET_CHILD_RECURSIVELY(frame, 'goddess_icor_spot_list')
	goddess_icor_spot_list:ClearItems()
	
	local slot_list = nil

	if type == 'Armor' then
		slot_list = managed_armor_slot_list
	else
		slot_list = managed_weapon_slot_list
	end
	
	for i = 1, #slot_list do
		local slot_info = slot_list[i]		
		goddess_icor_spot_list:AddItem(slot_info.SlotName, ClMsg(slot_info.ClMsg))
	end
	
	goddess_icor_spot_list:SelectItemByKey(0)
end