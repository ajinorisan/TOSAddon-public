function RELICMANAGER_ON_INIT(addon, frame)
	addon:RegisterMsg('OPEN_DLG_RELICMANAGER', 'ON_OPEN_DLG_RELICMANAGER')

	addon:RegisterMsg('MSG_SUCCESS_RELIC_CHARGE', 'RELICMANAGER_RP_UP_END')
	addon:RegisterMsg('MSG_SUCCESS_RELIC_EXP', 'RELICMANAGER_EXP_UP_END')
	addon:RegisterMsg('MSG_SUCCESS_RELIC_SOCKET', 'SUCCESS_RELIC_SOCKET')
	addon:RegisterMsg('UPDATE_RELIC_EQUIP', 'UPDATE_RELICMANAGER_VISIBLE')
	addon:RegisterMsg('RELIC_AUTO_CHARGE', 'RELIC_AUTO_CHARGE');
end

function ON_OPEN_DLG_RELICMANAGER(frame)
	frame:ShowWindow(1)
end

function UPDATE_RELICMANAGER_VISIBLE(frame, msg, argStr, argNum)
	if argNum == 0 then
		ui.CloseFrame('relicmanager')
	end
end

local function RELICMANAGER_GET_EQUIP_RELIC()
	local relic_item = session.GetEquipItemBySpot(item.GetEquipSpotNum('RELIC'))
	local relic_obj = GetIES(relic_item:GetObject())
	if IS_NO_EQUIPITEM(relic_obj) == 1 then
		return
	end

	return relic_item, relic_obj
end

local function RELICMANAGER_GET_EMPTY_SOCKET_IMAGE(type)
	local image = 'freegemslot_image'
	if type == 0 then
		image = 'socket_cyan'
	elseif type == 1 then
		image = 'socket_magenta'
	elseif type == 2 then
		image = 'socket_black'
	end

	return image
end

function RELICMANAGER_OPEN(frame)
	ui.CloseFrame('rareoption')
	ui.CloseFrame('relic_gem_manager')

	local relic_item, relic_obj = RELICMANAGER_GET_EQUIP_RELIC()
	if relic_item == nil or relic_obj == nil then
		ui.SysMsg(ClMsg('NO_EQUIP_RELIC'))
		ui.CloseFrame('relicmanager')
		return
	end

	INVENTORY_SET_CUSTOM_RBTNDOWN('RELICMANAGER_INV_RBTN')

	frame:SetUserValue('RELIC_GUID', relic_item:GetIESID())

	local relic_slot = GET_CHILD_RECURSIVELY(frame, 'relic_slot')
	SET_SLOT_ITEM(relic_slot, relic_item)

	local relic_name = GET_CHILD_RECURSIVELY(frame, 'relic_name')
	relic_name:SetTextByKey('value', dic.getTranslatedStr(TryGetProp(relic_obj, 'Name', 'None')))

	local tab = GET_CHILD_RECURSIVELY(frame, 'type_Tab')
	local index = 0
	if tab ~= nil then
		tab:SelectTab(0)
		index = tab:GetSelectItemIndex()
	end
	TOGGLE_RELICMANAGER_TAB(frame, index)
	frame:SetUserValue('last_tab_index', index)
end

function RELICMANAGER_CLOSE(frame)
	if ui.CheckHoldedUI() == true then
		return
	end

	INVENTORY_SET_CUSTOM_RBTNDOWN('None')
	frame:ShowWindow(0)
	control.DialogOk()
end

function TOGGLE_RELICMANAGER_TAB(frame, index)
	if index == 0 then
		CLEAR_RELICMANAGER_CHARGE()
		RELICMANAGER_CHARGE_OPEN(frame)
	elseif index == 1 then
		CLEAR_RELICMANAGER_EXP()
		RELICMANAGER_EXP_OPEN(frame)
	elseif index == 2 then
		RELICMANAGER_SOCKET_OPEN(frame)
	end
end

function RELICMANAGER_TAB_CHANGE(parent, ctrl)	
	local frame = parent:GetTopParentFrame()	
	local tab = GET_CHILD_RECURSIVELY(frame, 'type_Tab')
	local index = tab:GetSelectItemIndex()		
	if tostring(frame:GetUserValue('last_tab_index')) == tostring(index) then
		return
	end
	frame:SetUserValue('last_tab_index', index)
	TOGGLE_RELICMANAGER_TAB(frame, index)	
end

function RELICMANAGER_INV_RBTN(item_obj, slot)
	
	local frame = ui.GetFrame('relicmanager')
	if frame == nil then return end

	local icon = slot:GetIcon()
    local icon_info = icon:GetInfo()
	local guid = icon_info:GetIESID()
	
    local inv_item = session.GetInvItemByGuid(guid)
	if inv_item == nil then return end

	local item_obj = GetIES(inv_item:GetObject())
	if item_obj == nil then return end
	
	local tab = GET_CHILD_RECURSIVELY(frame, 'type_Tab')
	if tab == nil then return end

	local index = tab:GetSelectItemIndex()
	if index == 0 then
		RELICMANAGER_CHARGE_REG_MAT_ITEM(frame, inv_item, item_obj)
	elseif index == 1 then
		RELICMANAGER_EXP_REG_MAT_ITEM(frame, inv_item, item_obj)
	elseif index == 2 then
		RELICMANAGER_SOCKET_GEM_ADD(frame, inv_item, item_obj)
	end
end

function RELICMANAGER_INV_ITEM_DROP(frame, icon, argStr, argNum)
	if ui.CheckHoldedUI() == true then return end

	frame = ui.GetFrame('relicmanager')
	if frame == nil then return end

	local tab = GET_CHILD_RECURSIVELY(frame, 'type_Tab')
	if tab == nil then return end

	local index = tab:GetSelectItemIndex()

	local lift_icon = ui.GetLiftIcon()
	local from_frame = lift_icon:GetTopParentFrame()
    if from_frame:GetName() == 'inventory' then
        local icon_info = lift_icon:GetInfo()
        local guid = icon_info:GetIESID()
        local inv_item = session.GetInvItemByGuid(guid)
		if inv_item == nil then return end
		
		local item_obj = GetIES(inv_item:GetObject())
		if item_obj == nil then return end
        
		if index == 0 then
			RELICMANAGER_CHARGE_REG_MAT_ITEM(frame, inv_item, item_obj)
		elseif index == 1 then
			RELICMANAGER_EXP_REG_MAT_ITEM(frame, inv_item, item_obj)
		elseif index == 2 then
			RELICMANAGER_SOCKET_GEM_ADD(frame, inv_item, item_obj)
		end
	end
end

function RELICMANAGER_SLOT_ITEM_REMOVE(frame, icon)
	if ui.CheckHoldedUI() == true then return end

	frame = ui.GetFrame('relicmanager')
	if frame == nil then return end

	local tab = GET_CHILD_RECURSIVELY(frame, 'type_Tab')
	if tab == nil then return end

	local index = tab:GetSelectItemIndex()
	if index == 0 then
		CLEAR_RELICMANAGER_CHARGE()
	elseif index == 1 then
		CLEAR_RELICMANAGER_EXP()
	end
end

function UPDATE_RELICMANAGER_MAT_COUNT(parent, ctrl)
	if ui.CheckHoldedUI() == true then return end
	
	local frame = parent:GetTopParentFrame()
	local tab = GET_CHILD_RECURSIVELY(frame, 'type_Tab')
	local index = tab:GetSelectItemIndex()
	if index == 0 then
		RELICMANAGER_RPMAT_COUNT_CHANGE(ctrl, 0)
	elseif index == 1 then
		RELICMANAGER_EXPMAT_COUNT_CHANGE(ctrl, 0)
	end
end

function RELICMANAGER_MAT_UPBTN(parent, ctrl)
	if ui.CheckHoldedUI() == true then return end

	local frame = parent:GetTopParentFrame()
	local tab = GET_CHILD_RECURSIVELY(frame, 'type_Tab')
	local index = tab:GetSelectItemIndex()
	if index == 0 then
		RELICMANAGER_RPMAT_COUNT_CHANGE(ctrl, 1)
	elseif index == 1 then
		RELICMANAGER_EXPMAT_COUNT_CHANGE(ctrl, 1)
	end
end

function RELICMANAGER_MAT_DOWNBTN(parent, ctrl)
	if ui.CheckHoldedUI() == true then return end

	local frame = parent:GetTopParentFrame()
	local tab = GET_CHILD_RECURSIVELY(frame, 'type_Tab')
	local index = tab:GetSelectItemIndex()
	if index == 0 then
		RELICMANAGER_RPMAT_COUNT_CHANGE(ctrl, -1)
	elseif index == 1 then
		RELICMANAGER_EXPMAT_COUNT_CHANGE(ctrl, -1)
	end
end

-- 마력 충전
function UPDATE_RELICMANAGER_CHARGE(frame)
	local relic_item, relic_obj = RELICMANAGER_GET_EQUIP_RELIC()
	if relic_item == nil or relic_obj == nil then
		ui.CloseFrame('relicmanager')
		return
	end

	local pc = GetMyPCObject()
	local cur_rp, max_rp = shared_item_relic.get_rp(pc)
	local rp_gauge = GET_CHILD_RECURSIVELY(frame, 'rp_gauge')
	rp_gauge:SetPoint(cur_rp, max_rp)

	local do_charge = GET_CHILD_RECURSIVELY(frame, 'do_charge')

	local add_rp = 0
	local mat_ctrl = GET_CHILD_RECURSIVELY(frame, 'charge_mat_ctrl')
	if mat_ctrl ~= nil then
		local item_count = GET_CHILD_RECURSIVELY(mat_ctrl, 'item_count')
		local mat_type = mat_ctrl:GetUserIValue('MAT_TYPE')
		local mat_count = tonumber(item_count:GetText())
		if mat_type > 0 then
			local rp_per = mat_ctrl:GetUserIValue('MAT_RP_PER')
			local mat_cls = GetClassByType('Item', mat_type)
			if rp_per ~= nil and rp_per > 0 then
				add_rp = add_rp + (rp_per * mat_count)
			end
			if mat_count > 0 then
				do_charge:SetEnable(1)
			else
				do_charge:SetEnable(0)
			end
		else
			do_charge:SetEnable(0)
		end
	end

	if cur_rp + add_rp > max_rp then
		add_rp = max_rp - cur_rp
	end

	local rp_up_text = GET_CHILD_RECURSIVELY(frame, 'rp_up_text')
	rp_up_text:SetTextByKey('value', add_rp)
end

function CLEAR_RELICMANAGER_CHARGE()
	local frame = ui.GetFrame('relicmanager')
	if frame == nil then return end

	frame:StopUpdateScript('RELICMANAGER_RP_GAUGE_UPDATE_RP_UP')

	local send_ok_charge = GET_CHILD_RECURSIVELY(frame, 'send_ok_charge')
	send_ok_charge:ShowWindow(0)

	local rp_gauge_gb = GET_CHILD_RECURSIVELY(frame, 'rp_gauge_gb')
	rp_gauge_gb:ShowWindow(1)

	local do_charge = GET_CHILD_RECURSIVELY(frame, 'do_charge')
	do_charge:ShowWindow(1)
	do_charge:EnableHitTest(1)

	local mat_ctrl = GET_CHILD_RECURSIVELY(frame, 'charge_mat_ctrl')
	if mat_ctrl ~= nil then
		local mat_slot = GET_CHILD_RECURSIVELY(mat_ctrl, 'mat_slot')
		mat_slot:ClearIcon()

		local empty_pic = GET_CHILD_RECURSIVELY(mat_ctrl, 'empty_pic')
		empty_pic:ShowWindow(1)

		local name_text = GET_CHILD_RECURSIVELY(mat_ctrl, 'name_text')
		name_text:ShowWindow(0)

		local input_text = GET_CHILD_RECURSIVELY(mat_ctrl, 'input_text')
		input_text:ShowWindow(1)

		local item_count = GET_CHILD_RECURSIVELY(mat_ctrl, 'item_count')
		item_count:SetText(0)

		mat_ctrl:SetUserValue('MAT_TYPE', 0)
		mat_ctrl:SetUserValue('MAT_GUID', '0')
		mat_ctrl:SetUserValue('MAT_RP_PER', 0)
	end

	UPDATE_RELICMANAGER_CHARGE(frame)
end

function RELICMANAGER_CHARGE_REG_MAT_ITEM(frame, inv_item, item_obj)
	if frame == nil or inv_item == nil or item_obj == nil then return end

	local mat_ctrl = GET_CHILD_RECURSIVELY(frame, 'charge_mat_ctrl')
	if mat_ctrl == nil then return end

	local mat_class_name = TryGetProp(item_obj, 'ClassName', 'None')
	local name_list = shared_item_relic.get_rp_material_name_list()
	local mat_index = table.find(name_list, mat_class_name)
	if mat_index <= 0 then
		ui.SysMsg(ClMsg('IMPOSSIBLE_ITEM'))
		return
	end
	
	local mat_class = GetClass('Item', mat_class_name)
	local mat_class_id = TryGetProp(mat_class, 'ClassID', 0)
	local mat_guid = inv_item:GetIESID()
	local rp_per_list = shared_item_relic.get_rp_material_value_list()
	local rp_per = rp_per_list[mat_index]
	
	mat_ctrl:SetUserValue('MAT_TYPE', mat_class_id)
	mat_ctrl:SetUserValue('MAT_GUID', mat_guid)
	mat_ctrl:SetUserValue('MAT_RP_PER', rp_per)
	
	local empty_pic = GET_CHILD_RECURSIVELY(mat_ctrl, 'empty_pic')
	empty_pic:ShowWindow(0)

	local mat_slot = GET_CHILD_RECURSIVELY(mat_ctrl, 'mat_slot', 'ui::CSlot')
	SET_SLOT_ITEM(mat_slot, inv_item)

	local input_text = GET_CHILD_RECURSIVELY(mat_ctrl, 'input_text', 'ui::CRichText')
	input_text:ShowWindow(0)

	local name_text = GET_CHILD_RECURSIVELY(mat_ctrl, 'name_text', 'ui::CRichText')
	name_text:SetTextByKey('value', dic.getTranslatedStr(TryGetProp(mat_class, 'Name', 'None')))
	name_text:ShowWindow(1)

	local item_count = GET_CHILD_RECURSIVELY(mat_ctrl, 'item_count')
	item_count:SetText(0)

	UPDATE_RELICMANAGER_CHARGE(frame)
end

function RELICMANAGER_RPMAT_COUNT_CHANGE(ctrl, count)
	if ui.CheckHoldedUI() == true then return end
	
	if ctrl == nil then return end

	local count_box = ctrl:GetParent()
	if count_box == nil then return end
	
	local parent_ctrl = count_box:GetParent()
	if parent_ctrl == nil then return end

	local ctrlset = parent_ctrl:GetParent()
	if ctrlset == nil then return end

	local frame = ctrlset:GetTopParentFrame()
	if frame == nil then return end

	local item_count = GET_CHILD_RECURSIVELY(ctrlset, 'item_count')
	if item_count == nil then return end

	local cur_count = tonumber(item_count:GetText())
	if cur_count == nil then
		cur_count = 0
	end

	cur_count = cur_count + count

	local mat_type = ctrlset:GetUserIValue('MAT_TYPE')
	if mat_type <= 0 then
		item_count:SetText(0)
		return
	end

	local mat_guid = ctrlset:GetUserValue('MAT_GUID')
	local max_count = session.GetInvItemCountByType(mat_type)
	if cur_count > max_count then
		cur_count = max_count
	elseif cur_count < 0 then
		cur_count = 0
	end

	local cur_rp, max_rp = shared_item_relic.get_rp(GetMyPCObject())
	local mat_class = GetClassByType('Item', mat_type)
	if mat_class == nil then
		return
	end

	local mat_name = TryGetProp(mat_class, 'ClassName', 'None')
	local mat_name_list = shared_item_relic.get_rp_material_name_list()
	local mat_index = table.find(mat_name_list, mat_name)
	if mat_index <= 0 then
		return
	end

	local rp_per_list = shared_item_relic.get_rp_material_value_list()
	local rp_per = rp_per_list[mat_index]
	local add_rp = cur_count * rp_per
	if cur_rp + add_rp > max_rp then
		local over_rp = cur_rp + add_rp - max_rp
        local over_cnt = math.floor(over_rp / rp_per)
		cur_count = cur_count - over_cnt
	end
	
	item_count:SetText(cur_count)
	
	UPDATE_RELICMANAGER_CHARGE(frame)
end

function RELICMANAGER_CHARGE_OPEN(frame)
	local relic_item, relic_obj = RELICMANAGER_GET_EQUIP_RELIC()
	if relic_item == nil or relic_obj == nil then
		ui.CloseFrame('relicmanager')
		return
	end

	local chargeBg = GET_CHILD_RECURSIVELY(frame, 'chargeBg')
	if chargeBg:IsVisible() ~= 1 then return end

	UPDATE_RELICMANAGER_CHARGE(frame)
end

function RELICMANAGER_CHARGE_EXEC(parent)
	local frame = parent:GetTopParentFrame()
	if frame == nil then return end

	local relic_item, relic_obj = RELICMANAGER_GET_EQUIP_RELIC()
	if relic_item == nil or relic_obj == nil then
		ui.CloseFrame('relicmanager')
		return
	end

	session.ResetItemList()

	local mat_ctrl = GET_CHILD_RECURSIVELY(frame, 'charge_mat_ctrl')
	if mat_ctrl == nil then return end
	
	local mat_guid = mat_ctrl:GetUserValue('MAT_GUID')
	if mat_guid == '0' then return end

	local mat_item = session.GetInvItemByGuid(mat_guid)
	if mat_item == nil then return end

	if mat_item.isLockState == true then
		ui.SysMsg(ClMsg('MaterialItemIsLock'))
		return
	end

	local item_count = GET_CHILD_RECURSIVELY(mat_ctrl, 'item_count')
	if item_count == nil then return end

	local cur_count = tonumber(item_count:GetText())
	if cur_count ~= nil and cur_count > 0 then
		session.AddItemID(mat_guid, cur_count)
	end

	local msg = ClMsg('REALLY_CHARGE_RELIC_RP')
	local yesScp = '_RELICMANAGER_CHARGE_EXEC()'
	local msgbox = ui.MsgBox(msg, yesScp, 'None')
	SET_MODAL_MSGBOX(msgbox)
end

function _RELICMANAGER_CHARGE_EXEC()
	local frame = ui.GetFrame('relicmanager')
	if frame == nil then return end

	local acc_obj = GetMyAccountObj()
	if acc_obj == nil then return end

	local result_list = session.GetItemIDList()

	item.DialogTransaction('RELIC_CHARGE_RP', result_list)
	CloneTempObj('RELIC_RP_TEMPOBJ', acc_obj)
end

function RELIC_AUTO_CHARGE()
	if config.GetRelicAutoCharge() == 0 then
		return;
	end

	local pc = GetMyPCObject()
	if IsBuffApplied(pc, 'Colony_Limit_Relic_Release_Buff') == 'YES' or IsBuffApplied(pc, 'GuildRaid_Limit_Relic_Release_Buff') == 'YES' or IsBuffApplied(pc, 'Colony_Limit_Relic_Release_Buff2') == 'YES' or IsBuffApplied(pc, 'GoddessRaid_Limit_Relic_Release_Buff') == 'YES' then		
		return;
	end

	local zoneName = GetZoneName();
	local map = GetClass("Map",zoneName);
	local keyword = TryGetProp(map, "Keyword", "None")
    local keyword_table = SCR_STRING_CUT(keyword, ';');
    local drop_bounty_ticket = 0
    for i = 1, #keyword_table do
        if keyword_table[i] == 'SilverDrop' then
            drop_bounty_ticket = 1;
        end
    end

	if TryGetProp(map, "MapType", "None") ~= "City" and drop_bounty_ticket == 0 then
		return;
	end

	local relic_item, relic_obj = RELICMANAGER_GET_EQUIP_RELIC()
	if relic_item == nil or relic_obj == nil then		
		return;
	end
	
	local cur_rp, max_rp = shared_item_relic.get_rp(pc)
	if cur_rp == max_rp then
		return;
	end 
	
	local item_idx = nil;
	local cur_count = 0;
	local mat_item = session.GetInvItemByName('misc_Ectonite');
	if mat_item ~= nil and mat_item.isLockState == false then
		item_idx = mat_item:GetIESID()
		cur_count = mat_item.count;
	end

	local item_care_idx = nil;
	local care_cur_count = 0;
	local mat_item_care = session.GetInvItemByName("misc_Ectonite_Care");
	if mat_item_care ~= nil and mat_item_care.isLockState == false then
		item_care_idx = mat_item_care:GetIESID();
		care_cur_count = mat_item_care.count;
	end
	
	session.ResetItemList();
	if item_idx ~= nil and cur_count > 0 then
		session.AddItemID(item_idx, cur_count);
	end
	if item_care_idx ~= nil and care_cur_count > 0 then
		session.AddItemID(item_care_idx, care_cur_count);
	end
	local result_list = session.GetItemIDList();
	item.DialogTransaction('RELIC_CHARGE_RP', result_list)
end

function RELICMANAGER_RP_UP_END(frame, msg, argStr, argNum)
	local total_point = argNum
	local do_charge = GET_CHILD_RECURSIVELY(frame, 'do_charge')
	if do_charge ~= nil then
		do_charge:EnableHitTest(0)
    end
	imcSound.PlaySoundEvent('sys_jam_mix_whoosh')

	local rp_up_text = GET_CHILD_RECURSIVELY(frame, 'rp_up_text')
	rp_up_text:ShowWindow(0)

	local rp_gauge = GET_CHILD_RECURSIVELY(frame, 'rp_gauge', 'ui::CGauge')
	local gx, gy = GET_UI_FORCE_POS(rp_gauge)
	gx = gx - 50
	UI_FORCE('reinf_result_normal', gx, gy)

	frame:SetUserValue('_FORCE_SHOOT_RP', total_point)
	frame:SetUserValue('EXECUTE_RP_UP', 0)

	ReserveScript('RELICMANAGER_RP_FORCE_END()', 0.5)
end

function RELICMANAGER_RP_RESTORE_TEXT(frame)
	local rp_up_text = GET_CHILD_RECURSIVELY(frame, 'rp_up_text')
	rp_up_text:ShowWindow(1)
end

function RELICMANAGER_RP_FORCE_END()
	local frame = ui.GetFrame('relicmanager')
	local rp = frame:GetUserIValue('_FORCE_SHOOT_RP')
	if rp == 0 then
		return
	end

	frame:SetUserValue('_FORCE_SHOOT_RP', '0')
	frame:SetUserValue('_RP_UP_VALUE', rp)
	
	frame:SetUserValue('_RP_UP_START_TIME', rp)
	frame:StopUpdateScript('RELICMANAGER_RP_GAUGE_UPDATE_RP_UP')
	frame:RunUpdateScript('RELICMANAGER_RP_GAUGE_UPDATE_RP_UP', 0.2)

	local relic_slot_bg = GET_CHILD_RECURSIVELY(frame, 'relic_slot_bg', 'ui::CSlot')
	relic_slot_bg:SetBlink(1, 1, '00FFFFFF')
    if frame ~= nil then
        RELICMANAGER_RP_RESTORE_TEXT(frame)
    end
end

function RELICMANAGER_RP_GAUGE_UPDATE_RP_UP(frame)
	local rp_gauge = GET_CHILD_RECURSIVELY(frame, 'rp_gauge', 'ui::CGauge')
	local rp = frame:GetUserIValue('_RP_UP_VALUE')
	if rp == 0 then
		return 0
	end

	if rp_gauge:IsTimeProcessing() == 1 then
		return 1
	end

	local acc_clone = GetTempObj('RELIC_RP_TEMPOBJ')

	local cur_rp = acc_clone.RP
	local max_rp = tonumber(RELIC_MAX_RP)

	local remain_to_max = max_rp - cur_rp
	local process_rp = 0
	if rp >= remain_to_max then
		process_rp = remain_to_max
	else
		process_rp = rp
	end

	if rp_gauge:GetCurPoint() == rp_gauge:GetMaxPoint() then
		if process_rp == 0 then
			if cur_rp > max_rp then
				cur_rp = max_rp
			end
			rp_gauge:SetPoint(cur_rp, max_rp)
			frame:SetUserValue('IS_ING', 0)
			return 0
		end

		local cur_rp = acc_clone.RP
		local max_rp = tonumber(RELIC_MAX_RP)

		local remain_to_max = max_rp - cur_rp
		rp_gauge:SetPoint(max_rp, max_rp)
		return -0.5
	end

	rp = rp - process_rp
	frame:SetUserValue('_RP_UP_VALUE', rp)
	
	local gaugeTime = process_rp / max_rp * 3.0
	local point = cur_rp + process_rp
	
	rp_gauge:SetPoint(cur_rp, max_rp)
	rp_gauge:SetPointWithTime(point, gaugeTime)
	rp_gauge:SetProgressSound('sys_jam_shot', 0.05)
	acc_clone.RP = acc_clone.RP + process_rp
	local reservtime = gaugeTime * 0.7
	ReserveScript('SUCCESS_RELIC_CHARGE()', reservtime)

	return 1
end

function SUCCESS_RELIC_CHARGE()
	local frame = ui.GetFrame('relicmanager')
	
	local do_charge = GET_CHILD_RECURSIVELY(frame, 'do_charge')
	if do_charge ~= nil then
		do_charge:EnableHitTest(1)
		do_charge:ShowWindow(0)
	end
	
	local send_ok_charge = GET_CHILD_RECURSIVELY(frame, 'send_ok_charge')
	if send_ok_charge ~= nil then
		send_ok_charge:ShowWindow(1)
	end
end
-- 마력 충전 끝

-- 경험치
function UPDATE_RELICMANAGER_EXP(frame)
	local tab = GET_CHILD_RECURSIVELY(frame, 'type_Tab')
	if tab == nil then return end

	local tab_index = tab:GetSelectItemIndex()
	if tab_index ~= 1 then return end

	local relic_item, relic_obj = RELICMANAGER_GET_EQUIP_RELIC()
	if relic_item == nil or relic_obj == nil then
		ui.SysMsg(ClMsg('NO_EQUIP_RELIC'))
		ui.CloseFrame('relicmanager')
		return
	end
	
	local cur_lv = shared_item_relic.get_current_lv(relic_obj)
	local cur_exp = shared_item_relic.get_current_exp(relic_obj)
	local cur_lv_exp = shared_item_relic.get_current_lv_exp(relic_obj)
	local next_exp = shared_item_relic.get_current_lv_exp_interval(relic_obj)
	local cur_exp = cur_exp - cur_lv_exp
	if shared_item_relic.is_max_lv(relic_obj) == 'YES' then -- 경험치 full
		cur_exp = next_exp
	end

	local relic_lv = GET_CHILD_RECURSIVELY(frame, 'relic_lv')
	relic_lv:SetTextByKey('value', cur_lv)

	local exp_gauge = GET_CHILD_RECURSIVELY(frame, 'exp_gauge', 'ui::CGauge')
	exp_gauge:SetPoint(cur_exp, next_exp)

	local add_exp = 0
	local mat_ctrl = GET_CHILD_RECURSIVELY(frame, 'exp_mat_ctrl')
	if mat_ctrl ~= nil then
		local mat_type = mat_ctrl:GetUserIValue('MAT_TYPE')
		if mat_type > 0 then
			local exp_per = mat_ctrl:GetUserIValue('MAT_EXP_PER')
			local mat_cls = GetClassByType('Item', mat_type)
			local item_count = GET_CHILD_RECURSIVELY(mat_ctrl, 'item_count')
			local mat_count = tonumber(item_count:GetText())
			if exp_per ~= nil and exp_per > 0 then
				add_exp = add_exp + (exp_per * mat_count)
			end
		end
	end

	local do_exp = GET_CHILD_RECURSIVELY(frame, 'do_exp')
	if add_exp <= 0 then
		do_exp:SetEnable(0)
	else
		do_exp:SetEnable(1)
	end
		
	
	local cur_lv = shared_item_relic.get_current_lv(relic_obj)
	local lvup_value, add_exp_adjust = shared_item_relic.get_lvup_value_by_expup(relic_obj, add_exp)
	
	local exp_up_text = GET_CHILD_RECURSIVELY(frame, 'exp_up_text')
	exp_up_text:SetTextByKey('value', add_exp_adjust)
	
	local relic_lv = GET_CHILD_RECURSIVELY(frame, 'relic_lv')
	relic_lv:SetTextByKey('value', cur_lv)

	local relic_lv_arrow = GET_CHILD_RECURSIVELY(frame, 'relic_lv_arrow')
	local relic_lv_up = GET_CHILD_RECURSIVELY(frame, 'relic_lv_up')
	if lvup_value > 0 then
		relic_lv_arrow:ShowWindow(1)
		relic_lv_up:ShowWindow(1)
		relic_lv_up:SetTextByKey('value', cur_lv + lvup_value)
	else
		relic_lv_arrow:ShowWindow(0)
		relic_lv_up:ShowWindow(0)
	end
end

local function _EXP_MATCTRL_CLEAR(mat_ctrl)
	local mat_slot = GET_CHILD_RECURSIVELY(mat_ctrl, 'mat_slot')
	mat_slot:ClearIcon()

	local empty_pic = GET_CHILD_RECURSIVELY(mat_ctrl, 'empty_pic')
	empty_pic:ShowWindow(1)
	
	local name_text = GET_CHILD_RECURSIVELY(mat_ctrl, 'name_text')
	name_text:ShowWindow(0)

	local input_text = GET_CHILD_RECURSIVELY(mat_ctrl, 'input_text')
	input_text:ShowWindow(1)

	local item_count = GET_CHILD_RECURSIVELY(mat_ctrl, 'item_count')
	item_count:SetText(0)

	mat_ctrl:SetUserValue('MAT_TYPE', 0)
	mat_ctrl:SetUserValue('MAT_GUID', '0')
	mat_ctrl:SetUserValue('MAT_EXP_PER', 0)
end

function CLEAR_RELICMANAGER_EXP()
	local frame = ui.GetFrame('relicmanager')
	if frame == nil then return end

	frame:StopUpdateScript('RELICMANAGER_EXP_GAUGE_UPDATE_EXP_UP')

	local send_ok_exp = GET_CHILD_RECURSIVELY(frame, 'send_ok_exp')
	send_ok_exp:ShowWindow(0)

	local exp_gauge_gb = GET_CHILD_RECURSIVELY(frame, 'exp_gauge_gb')
	exp_gauge_gb:ShowWindow(1)

	local do_exp = GET_CHILD_RECURSIVELY(frame, 'do_exp')
	do_exp:ShowWindow(1)
	do_exp:EnableHitTest(1)

	local mat_ctrl = GET_CHILD_RECURSIVELY(frame, 'exp_mat_ctrl')
	if mat_ctrl ~= nil then
		_EXP_MATCTRL_CLEAR(mat_ctrl)
	end

	UPDATE_RELICMANAGER_EXP(frame)
end

function RELICMANAGER_EXP_REG_MAT_ITEM(frame, inv_item, item_obj)
	if frame == nil or inv_item == nil or item_obj == nil then return end

	CLEAR_RELICMANAGER_EXP(frame)

	local mat_ctrl = GET_CHILD_RECURSIVELY(frame, 'exp_mat_ctrl')
	if mat_ctrl == nil then return end

	local mat_name = TryGetProp(item_obj, 'ClassName', 'None')
	local mat_name_list = shared_item_relic.get_exp_material_name()
	local mat_index = table.find(mat_name_list, mat_name)
	if mat_index <= 0 then
		ui.SysMsg(ClMsg('IMPOSSIBLE_ITEM'))
		return
	end

	local mat_class = GetClass('Item', mat_name)
	local mat_class_id = TryGetProp(mat_class, 'ClassID', 0)
	local mat_guid = inv_item:GetIESID()
	local exp_per = shared_item_relic.get_exp_material_value()
	
	mat_ctrl:SetUserValue('MAT_TYPE', mat_class_id)
	mat_ctrl:SetUserValue('MAT_GUID', mat_guid)
	mat_ctrl:SetUserValue('MAT_EXP_PER', exp_per)

	local empty_pic = GET_CHILD_RECURSIVELY(mat_ctrl, 'empty_pic')
	empty_pic:ShowWindow(0)

	local mat_slot = GET_CHILD_RECURSIVELY(mat_ctrl, 'mat_slot', 'ui::CSlot')
	SET_SLOT_ITEM(mat_slot, inv_item)

	local input_text = GET_CHILD_RECURSIVELY(mat_ctrl, 'input_text')
	input_text:ShowWindow(0)

	local name_text = GET_CHILD_RECURSIVELY(mat_ctrl, 'name_text', 'ui::CRichText')
	name_text:SetTextByKey('value', dic.getTranslatedStr(TryGetProp(mat_class, 'Name', 'None')))
	name_text:ShowWindow(1)
	
	local item_count = GET_CHILD_RECURSIVELY(mat_ctrl, 'item_count')
	item_count:SetText(0)

	UPDATE_RELICMANAGER_EXP(frame)
end

function RELICMANAGER_EXPMAT_COUNT_CHANGE(ctrl, count)
	if ui.CheckHoldedUI() == true then
        return
	end
	
	if ctrl == nil then return end

	local count_box = ctrl:GetParent()
	if count_box == nil then return end
	
	local parent_ctrl = count_box:GetParent()
	if parent_ctrl == nil then return end

	local ctrlset = parent_ctrl:GetParent()
	if ctrlset == nil then return end

	local frame = ctrlset:GetTopParentFrame()
	if frame == nil then return end

	local item_count = GET_CHILD_RECURSIVELY(ctrlset, 'item_count')
	if item_count == nil then return end

	local cur_count = tonumber(item_count:GetText())
	if cur_count == nil then
		cur_count = 0
	end

	cur_count = cur_count + count

	local mat_type = ctrlset:GetUserIValue('MAT_TYPE')
	if mat_type <= 0 then
		item_count:SetText(0)
		return
	end

	local max_count = session.GetInvItemCountByType(mat_type)
	if cur_count > max_count then
		cur_count = max_count
	elseif cur_count < 0 then
		cur_count = 0
	end

	local relic_item, relic_obj = RELICMANAGER_GET_EQUIP_RELIC()
	local cur_exp = shared_item_relic.get_current_exp(relic_obj)
	local max_exp = shared_item_relic.get_require_exp_sum(tonumber(RELIC_MAX_LEVEL))
	local exp_per = shared_item_relic.get_exp_material_value()
	local add_exp = cur_count * exp_per
	if cur_exp + add_exp > max_exp then
        local over_exp = cur_exp + add_exp - max_exp
        local over_cnt = math.floor(over_exp / exp_per)
        cur_count = cur_count - over_cnt
    end
	
	item_count:SetText(cur_count)
	
	UPDATE_RELICMANAGER_EXP(frame)
end

function RELICMANAGER_EXP_OPEN(frame)
	local relic_item, relic_obj = RELICMANAGER_GET_EQUIP_RELIC()
	if relic_item == nil or relic_obj == nil then
		ui.SysMsg(ClMsg('NO_EQUIP_RELIC'))
		ui.CloseFrame('relicmanager')
		return
	end

	local expBg = GET_CHILD_RECURSIVELY(frame, 'expBg')
	if expBg:IsVisible() ~= 1 then return end

	UPDATE_RELICMANAGER_EXP(frame)
end

function RELICMANAGER_EXP_EXEC(parent)
	local frame = parent:GetTopParentFrame()
	if frame == nil then return end

	local relic_id = frame:GetUserValue('RELIC_GUID')
	if relic_id == nil or relic_id == 'None' or relic_id == '0' then
		return
	end

	session.ResetItemList()
	
	local mat_ctrl = GET_CHILD_RECURSIVELY(frame, 'exp_mat_ctrl')
	if mat_ctrl == nil then return end
	
	local mat_guid = mat_ctrl:GetUserValue('MAT_GUID')
	if mat_guid == '0' then return end

	local mat_item = session.GetInvItemByGuid(mat_guid)
	if mat_item == nil then return end

	if mat_item.isLockState == true then
		ui.SysMsg(ClMsg('MaterialItemIsLock'))
		return
	end

	local item_count = GET_CHILD_RECURSIVELY(mat_ctrl, 'item_count')
	if item_count == nil then return end
	
	local cur_count = tonumber(item_count:GetText())
	if cur_count ~= nil and cur_count > 0 then
		session.AddItemID(mat_guid, cur_count)
	end

	local msg = ClMsg('REALLY_DO_RELIC_EXP')
	local yesScp = '_RELICMANAGER_EXP_EXEC()'
	local msgbox = ui.MsgBox(msg, yesScp, 'None')
	SET_MODAL_MSGBOX(msgbox)
end

function _RELICMANAGER_EXP_EXEC()
	local frame = ui.GetFrame('relicmanager')
	if frame == nil then return end
	
	local relic_item, relic_obj = RELICMANAGER_GET_EQUIP_RELIC()
	if relic_item == nil or relic_obj == nil then return end
	
	local relic_id = frame:GetUserValue('RELIC_GUID')
	local do_exp = GET_CHILD_RECURSIVELY(frame, 'do_exp')
	
	local result_list = session.GetItemIDList()
	local arg_list = NewStringList()
	arg_list:Add(relic_id)
	
	item.DialogTransaction('RELIC_EXP_UP', result_list, '', arg_list)
	CloneTempObj("RELIC_EXP_TEMPOBJ", relic_obj)
end

function RELICMANAGER_EXP_UP_END(frame, msg, argStr, argNum)
	local total_point = argNum
	local do_exp = GET_CHILD_RECURSIVELY(frame, 'do_exp')
	if do_exp ~= nil then
		do_exp:EnableHitTest(0)
    end
	imcSound.PlaySoundEvent('sys_jam_mix_whoosh')

	local relic_lv_text = GET_CHILD_RECURSIVELY(frame, 'relic_lv_text')
	relic_lv_text:ShowWindow(0)
	local relic_lv = GET_CHILD_RECURSIVELY(frame, 'relic_lv')
	relic_lv:ShowWindow(0)
	local relic_lv_arrow = GET_CHILD_RECURSIVELY(frame, 'relic_lv_arrow')
	if relic_lv_arrow:IsVisible() == 1 then
		relic_lv_arrow:ShowWindow(0)
	end
	local relic_lv_up = GET_CHILD_RECURSIVELY(frame, 'relic_lv_up')
	if relic_lv_up:IsVisible() == 1 then
		relic_lv_up:ShowWindow(0)
	end
	local mat_ctrl = GET_CHILD_RECURSIVELY(frame, 'exp_mat_ctrl')
	if mat_ctrl ~= nil then
		_EXP_MATCTRL_CLEAR(mat_ctrl)
	end

	local exp_gauge = GET_CHILD_RECURSIVELY(frame, 'exp_gauge', 'ui::CGauge')
	local gx, gy = GET_UI_FORCE_POS(exp_gauge)
	gx = gx - 50
	UI_FORCE('reinf_result_normal', gx, gy)

	frame:SetUserValue('_FORCE_SHOOT_EXP', total_point)
	frame:SetUserValue('EXECUTE_EXP_UP', 0)

	ReserveScript('RELICMANAGER_EXP_FORCE_END()', 0.5)
end

function RELICMANAGER_EXP_RESTORE_LEVEL_TEXT(frame)
	local relic_lv_text = GET_CHILD_RECURSIVELY(frame, 'relic_lv_text')
	relic_lv_text:ShowWindow(1)
	local relic_lv = GET_CHILD_RECURSIVELY(frame, 'relic_lv')
	relic_lv:ShowWindow(1)
end

function RELICMANAGER_EXP_FORCE_END()
	local frame = ui.GetFrame('relicmanager')
	local exp = frame:GetUserIValue('_FORCE_SHOOT_EXP')
	if exp == 0 then
		return
	end

	frame:SetUserValue('_FORCE_SHOOT_EXP', '0')
	frame:SetUserValue('_EXP_UP_VALUE', exp)
	
	frame:SetUserValue('_EXP_UP_START_TIME', exp)
	frame:StopUpdateScript('RELICMANAGER_EXP_GAUGE_UPDATE_EXP_UP')
	frame:RunUpdateScript('RELICMANAGER_EXP_GAUGE_UPDATE_EXP_UP', 0.2)

	local relic_slot_bg = GET_CHILD_RECURSIVELY(frame, 'relic_slot_bg', 'ui::CSlot')
	relic_slot_bg:SetBlink(1, 1, '00FFFFFF')
    if frame ~= nil then
        RELICMANAGER_EXP_RESTORE_LEVEL_TEXT(frame)
    end
end

function RELICMANAGER_EXP_GAUGE_UPDATE_EXP_UP(frame)
	local exp_gauge = GET_CHILD_RECURSIVELY(frame, 'exp_gauge', 'ui::CGauge')
	local relic_lv = GET_CHILD_RECURSIVELY(frame, 'relic_lv')
	local relic_clone = GetTempObj('RELIC_EXP_TEMPOBJ')
	local exp = frame:GetUserIValue('_EXP_UP_VALUE')
	if exp == 0 then
		relic_lv:SetTextByKey('value', relic_clone.Relic_LV)
		return 0
	end

	if exp_gauge:IsTimeProcessing() == 1 then
		return 1
	end

	local cur_exp = shared_item_relic.get_current_exp(relic_clone)
	local cur_lv_exp = shared_item_relic.get_current_lv_exp(relic_clone)
	local next_exp = shared_item_relic.get_current_lv_exp_interval(relic_clone)
	local cur_exp = cur_exp - cur_lv_exp

	local need_exp = next_exp - cur_exp
	local process_exp = 0
	if exp >= need_exp then
		process_exp = need_exp
	else
		process_exp = exp
	end

	if exp_gauge:GetCurPoint() == exp_gauge:GetMaxPoint() then
		relic_lv:SetTextByKey('value', relic_clone.Relic_LV)

		if process_exp == 0 then
			if cur_exp > next_exp then
				cur_exp = next_exp
			end
			exp_gauge:SetPoint(cur_exp, next_exp)
			frame:SetUserValue('IS_ING', 0)
			return 0
		end

		local cur_exp = shared_item_relic.get_current_exp(relic_clone)
		local cur_lv_exp = shared_item_relic.get_current_lv_exp(relic_clone)
		local next_exp = shared_item_relic.get_current_lv_exp_interval(relic_clone)
		local cur_exp = cur_exp - cur_lv_exp

		local need_exp = next_exp - cur_exp
		exp_gauge:SetPoint(0, next_exp)
		return -0.5
	end

	exp = exp - process_exp
	frame:SetUserValue('_EXP_UP_VALUE', exp)
	
	local gaugeTime = process_exp / next_exp * 3.0
	local point = cur_exp + process_exp
	
	exp_gauge:SetPoint(cur_exp, next_exp)
	exp_gauge:SetPointWithTime(point, gaugeTime)
	exp_gauge:SetProgressSound('sys_jam_shot', 0.05)
	relic_clone.Relic_EXP = relic_clone.Relic_EXP + process_exp
	local cur_lv = relic_clone.Relic_LV
	local process_lv = shared_item_relic.get_current_lv_by_exp(relic_clone)
	if cur_lv ~= process_lv then
		relic_clone.Relic_LV = process_lv
	end
	local reservtime = gaugeTime * 0.7
	ReserveScript('SUCCESS_RELIC_EXP()', reservtime)

	return 1
end

function SUCCESS_RELIC_EXP()
	local frame = ui.GetFrame('relicmanager')
	
	local do_exp = GET_CHILD_RECURSIVELY(frame, 'do_exp')
	if do_exp ~= nil then
		do_exp:ShowWindow(0)
		do_exp:EnableHitTest(1)
	end
	
	local send_ok_exp = GET_CHILD_RECURSIVELY(frame, 'send_ok_exp')
	if send_ok_exp ~= nil then
		send_ok_exp:ShowWindow(1)
	end
end
-- 경험치 끝

-- 소켓 관리
function RELICMANAGER_SOCKET_UPDATE(frame)
	local relic_item, relic_obj = RELICMANAGER_GET_EQUIP_RELIC()
	if relic_item == nil or relic_obj == nil then
		ui.SysMsg(ClMsg('NO_EQUIP_RELIC'))
		ui.CloseFrame('relicmanager')
		return
	end

	local socketBg = GET_CHILD_RECURSIVELY(frame, 'socketBg')
	if socketBg:IsVisible() == 0 then
		return
	end

	local bodyGbox_midle = GET_CHILD_RECURSIVELY(frame, 'bodyGbox_midle')
	for _name, _type in pairs(relic_gem_type) do
		local is_char_belonging = frame:GetUserIValue('SOCKET_GEM_BELONGING_'.._type)
		local sub_ctrl = GET_CHILD_RECURSIVELY(frame, 'cset_'.._type)
		sub_ctrl:SetUserValue('GEM_TYPE', _type)
		local gem_slot = GET_CHILD_RECURSIVELY(sub_ctrl, 'gem_slot', 'ui::CSlot')
		local gem_name = GET_CHILD_RECURSIVELY(sub_ctrl, 'gem_name', 'ui::CRichText')
		local socket_icon = GET_CHILD_RECURSIVELY(sub_ctrl, 'socket_icon', 'ui::CPicture')
		local socket_name = GET_CHILD_RECURSIVELY(sub_ctrl, 'socket_name', 'ui::CRichText')
		socket_name:SetTextByKey('name', ScpArgMsg('EMPTY_RELIC_GEM_SOCKET', 'NAME', ClMsg(_name)))
		local do_remove = GET_CHILD_RECURSIVELY(sub_ctrl, 'do_remove', 'ui::CButton')
		local gem_id = relic_item:GetEquipGemID(_type)
		
		if gem_id == 0 then
			local empty_image = RELICMANAGER_GET_EMPTY_SOCKET_IMAGE(_type)
			gem_name:ShowWindow(0)
			gem_slot:ClearIcon()
			socket_name:ShowWindow(1)
			socket_icon:ShowWindow(1)
			socket_icon:SetImage(empty_image)			
			do_remove:SetEnable(0)
		else	
			local gem_cls = GetClassByType('Item', gem_id)
			local name_str = GET_RELIC_GEM_NAME_WITH_FONT(gem_cls)
			socket_icon:ShowWindow(0)
			socket_name:ShowWindow(0)
			gem_name:ShowWindow(1)
			gem_name:SetTextByKey('name', name_str)
			if is_char_belonging == 1 then
				local icon = CreateIcon(gem_slot);
				icon:SetImage(TryGetProp(gem_cls, 'Icon'));
				icon:GetInfo().type = gem_cls.ClassID;
				icon:SetTooltipNumArg(gem_cls.ClassID);
				icon:SetTooltipStrArg('char_belonging');
				icon:SetTooltipType('wholeitem')
			else
				SET_SLOT_ITEM_CLS(gem_slot, gem_cls)	
			end			
			do_remove:SetEnable(1)
		end
	end
end

function RELICMANAGER_SOCKET_GEM_DROP()

end

function RELICMANAGER_SOCKET_OPEN(frame)
	RELICMANAGER_SOCKET_UPDATE(frame)
end

function RELICMANAGER_SOCKET_GEM_ADD(frame, inv_item, item_obj)
	local relic_item, relic_obj = RELICMANAGER_GET_EQUIP_RELIC()
	if relic_item == nil or relic_obj == nil then
		ui.SysMsg(ClMsg('NO_EQUIP_RELIC'))
		return
	end

	local group_name = TryGetProp(item_obj, 'GroupName', 'None')
	if group_name ~= 'Gem_Relic' then
		-- 성물 젬이 아닙니다
		ui.SysMsg(ClMsg('NOT_A_RELIC_GEM'))
		return
	end

	local gem_type_str = TryGetProp(item_obj, 'GemType', 'None')
	local gem_type_num = relic_gem_type[gem_type_str]
	if gem_type_num == nil then
		-- 존재하지 않는 성물 젬 타입
		return
	end

	local gem_class_id = relic_item:GetEquipGemID(gem_type_num)
	if gem_class_id ~= 0 then
		-- 이미 다른 젬이 장착되어 있습니다
		ui.SysMsg(ScpArgMsg('RELIC_GEM_EQUIPPED_ALREADY', 'TYPE', ClMsg(gem_type_str)))
		return
	end

	if inv_item.isLockState == true then
		ui.SysMsg(ClMsg('MaterialItemIsLock'))
		return
	end

	session.ResetItemList()
	session.AddItemID(relic_item:GetIESID(), 1)
	session.AddItemID(inv_item:GetIESID(), 1)
	
	local scp_arg_msg = 'REALLY_EQUIP_RELIC_GEM'
	local team_belong = TryGetProp(item_obj, 'TeamBelonging', 1)
	if team_belong == 0 then
		scp_arg_msg = 'REALLY_EQUIP_RELIC_GEM_IGNORE_BELONGING'
	end

	local gem_name = GET_RELIC_GEM_NAME_WITH_FONT(item_obj)
	local msg = ScpArgMsg(scp_arg_msg, 'NAME', gem_name)
	local yes_scp = '_RELICMANAGER_SOCKET_GEM_ADD()'

	local invItem_Obj = GetIES(inv_item:GetObject())
	local is_char_belonging = TryGetProp(invItem_Obj,"CharacterBelonging",0)
	if tonumber(is_char_belonging) == 1 then
		frame:SetUserValue('SOCKET_GEM_BELONGING_'..gem_type_num,is_char_belonging)
	else
		frame:SetUserValue('SOCKET_GEM_BELONGING_'..gem_type_num,is_char_belonging)
	end

	local msgbox = ui.MsgBox(msg, yes_scp, 'None')
	SET_MODAL_MSGBOX(msgbox)
end

function _RELICMANAGER_SOCKET_GEM_ADD()
	local frame = ui.GetFrame('relicmanager')
	if frame == nil then return end

	local resultlist = session.GetItemIDList()

	item.DialogTransaction('RELIC_SOCKET_GEM_ADD', resultlist)
end

function RELICMANAGER_GEM_REMOVE_BTN(ctrl, btn, argStr, argNum)
	local parent = ctrl:GetParent()
	local ctrlset = parent:GetParent()
	local gem_type = ctrlset:GetUserIValue('GEM_TYPE')
	local frame = ctrlset:GetTopParentFrame()
	local relic_id = frame:GetUserValue('RELIC_GUID')
	if relic_id == nil or relic_id == 'None' or relic_id == '0' then
		return
	end

	local relic_item = session.GetEquipItemBySpot(item.GetEquipSpotNum('RELIC'))
	local relic_obj = GetIES(relic_item:GetObject())
	if IS_NO_EQUIPITEM(relic_obj) == 1 then
		ui.SysMsg(ClMsg('NO_EQUIP_RELIC'))
		return
	end

	local gem_class_id = relic_item:GetEquipGemID(gem_type)
	if gem_class_id == 0 then
		-- 장착된 젬이 없어요
		ui.SysMsg(ClMsg('NO_RELIC_GEM_EQUIPPED'))
		return
	end

	local gem_class = GetClassByType('Item', gem_class_id)
	if gem_class == nil then
		-- no data
		return
	end

	local gem_name = GET_RELIC_GEM_NAME_WITH_FONT(gem_class)
	local msg = ScpArgMsg('REALLY_UNEQUIP_RELIC_GEM', 'NAME', gem_name)
	local yes_scp = string.format('RELICMANAGER_SOCKET_GEM_REMOVE(%d)', gem_type)

	local msgbox = ui.MsgBox(msg, yes_scp, 'None')
	SET_MODAL_MSGBOX(msgbox)
end

function RELICMANAGER_SOCKET_GEM_REMOVE(type)
	local frame = ui.GetFrame('relicmanager')
	local relic_id = frame:GetUserValue('RELIC_GUID')
	if relic_id == nil or relic_id == 'None' or relic_id == '0' then
		return
	end

	local arg_list = string.format('%d', type)

	pc.ReqExecuteTx_Item('RELIC_SOCKET_GEM_REMOVE', relic_id, arg_list)
end

function SUCCESS_RELIC_SOCKET(frame)
	RELICMANAGER_SOCKET_UPDATE(frame)
end
-- 소켓 관리 끝