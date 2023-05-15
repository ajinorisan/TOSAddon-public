local addonName = "KYOUKARENDA"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "0.0.1"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

local acutil = require("acutil")

function KYOUKARENDA_ON_INIT(addon, frame)
    g.addon = addon
    g.frame = frame

    acutil.setupHook(KYOUKARENDA_GODDESS_MGR_REFORGE_REINFORCE_EXEC, "GODDESS_MGR_REFORGE_REINFORCE_EXEC")
    acutil.setupHook(_KYOUKARENDA_GODDESS_MGR_REFORGE_REINFORCE_EXEC, "_GODDESS_MGR_REFORGE_REINFORCE_EXEC")
    CHAT_SYSTEM("kyoukarenda loaded")
end

function KYOUKARENDA_GODDESS_MGR_REFORGE_REINFORCE_EXEC(parent, btn)
    local autoenhancement = 0
    local frame = parent:GetTopParentFrame()
    -- 追加したいボタンの親要素を取得する
    local bg = GET_CHILD_RECURSIVELY(frame, 'bg')
    local reforge_bg = GET_CHILD_RECURSIVELY(frame, 'reforge_bg')
    local ref_reinforce_bg = GET_CHILD_RECURSIVELY(frame, 'ref_reinforce_bg')
    local cancelbutton = ref_reinforce_bg:CreateControl("button", "CANCELBUTTON", 330, 0, 100, 70)
    cancelbutton:SetSkinName("test_red_button")
    cancelbutton:SetGravity(ui.CENTER_HORZ, ui.BOTTOM)
    cancelbutton:SetText("{@st41b}{s18}Cancel")
    cancelbutton:PlaySoundEvent("button_click_big")
    cancelbutton:SetEventScript(ui.LBUTTONUP, "KYOUKARENDA_STOP_SCRIPT")

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
    if inv_item == nil then
        return
    end
    local item_obj = GetIES(inv_item:GetObject())
    local item_name = dic.getTranslatedStr(TryGetProp(item_obj, 'Name', 'None'))

    local reinf_no_msgbox = GET_CHILD_RECURSIVELY(frame, 'reinf_no_msgbox')
    local ref_ok_reinforce = GET_CHILD_RECURSIVELY(frame, 'ref_ok_reinforce')
    local ref_do_reinforce = GET_CHILD_RECURSIVELY(frame, 'ref_do_reinforce')

    if reinf_no_msgbox:IsChecked() == 1 then
        _KYOUKARENDA_GODDESS_MGR_REFORGE_REINFORCE_EXEC()
        -- ReserveScript("GODDESS_MGR_REINFORCE_CLEAR_BTN()", 1.0)
    else
        local yesscp = '_GODDESS_MGR_REFORGE_REINFORCE_EXEC()'
        local msgbox = ui.MsgBox(ScpArgMsg('ReallyDoAetherGemReinforce', 'name', item_name), yesscp,
            'ENABLE_CONTROL_WITH_UI_HOLD(false)')
        SET_MODAL_MSGBOX(msgbox)
    end
end

function KYOUKARENDA_STOP_SCRIPT()
    local autoenhancement = 1
    ui.SysMsg("連続強化を中断します")
    ui.SysMsg("Continuous Interrupts reinforcement")

end

function _KYOUKARENDA_GODDESS_MGR_REFORGE_REINFORCE_EXEC(autoenhancement)

    local frame = ui.GetFrame('goddess_equip_manager')
    if frame == nil then
        return
    end

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
            if extra_mat_guid == 'None' then
                return
            end

            session.AddItemID(extra_mat_guid, cnt)
        end
    end

    local result_list = session.GetItemIDList()

    item.DialogTransaction('GODDESS_REINFORCE', result_list)

    -- local parent = parent:GetTopParentFrame()

    if autoenhancement == 0 and (icon ~= nil or icon:GetInfo() ~= nil) then

        GODDESS_MGR_REINFORCE_EXTRA_MAT_UPDATE(frame)
        GODDESS_MGR_REINFORCE_RATE_UPDATE(frame)
        -- KYOUKARENDA_GODDESS_MGR_REINFORCE_MAT_UPDATE(frame)

        ReserveScript("_KYOUKARENDA_GODDESS_MGR_REFORGE_REINFORCE_EXEC()", 2.0)

    else
        local autoenhancement = 1
        return

    end

end

--[[
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
		local dic = item_goddess_reinforce.get_material_list(use_lv, class_type, reinf_value + 1)
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
]]
