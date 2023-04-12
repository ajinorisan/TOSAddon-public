function RELIC_GEM_MANAGER_ON_INIT(addon, frame)
	addon:RegisterMsg('OPEN_DLG_RELIC_GEM_MANAGER', 'ON_OPEN_DLG_RELIC_GEM_MANAGER')

	addon:RegisterMsg('MSG_END_RELIC_GEM_REINFORCE', 'END_RELIC_GEM_REINFORCE')
	addon:RegisterMsg('MSG_END_RELIC_GEM_COMPOSE', 'END_RELIC_GEM_COMPOSE')
	addon:RegisterMsg('MSG_SUCCESS_RELIC_GEM_TRANSFER', 'SUCCESS_RELIC_GEM_TRANSFER')
	addon:RegisterMsg('MSG_SUCCESS_RELIC_GEM_DECOMPOSE', 'SUCCESS_RELIC_GEM_DECOMPOSE')
end

function ON_OPEN_DLG_RELIC_GEM_MANAGER(frame)
	frame:ShowWindow(1)
end

function RELIC_GEM_MANAGER_OPEN(frame)
	ui.CloseFrame('rareoption')
	ui.CloseFrame('relicmanager')

	ui.OpenFrame('inventory')
	
	local tab = GET_CHILD_RECURSIVELY(frame, 'type_Tab')
	local index = 0
	if tab ~= nil then
		tab:SelectTab(0)
		index = tab:GetSelectItemIndex()
	end
	TOGGLE_RELIC_GEM_MANAGER_TAB(frame, index)
end

function RELIC_GEM_MANAGER_CLOSE(frame)
	if ui.CheckHoldedUI() == true then
		return
	end

	INVENTORY_SET_CUSTOM_RBTNDOWN('None')
	frame:ShowWindow(0)
	control.DialogOk()
end

function CLEAR_RELIC_GEM_MANAGER_ALL()
	CLEAR_RELIC_GEM_MANAGER_REINFORCE()
	CLEAR_RELIC_GEM_MANAGER_COMPOSE()
	CLEAR_RELIC_GEM_MANAGER_TRANSFER()
	CLEAR_RELIC_GEM_MANAGER_DECOMPOSE()
end

function TOGGLE_RELIC_GEM_MANAGER_TAB(frame, index)
	CLEAR_RELIC_GEM_MANAGER_ALL()
	if index == 0 then
		RELIC_GEM_MANAGER_REINFORCE_OPEN(frame)
		INVENTORY_SET_CUSTOM_RBTNDOWN('RELIC_GEM_MANAGER_REINFORCE_INV_RBTN')
	elseif index == 1 then
		RELIC_GEM_MANAGER_COMPOSE_OPEN(frame)
		INVENTORY_SET_CUSTOM_RBTNDOWN('RELIC_GEM_MANAGER_COMPOSE_INV_RBTN')
	elseif index == 2 then
		RELIC_GEM_MANAGER_TRANSFER_OPEN(frame)
		INVENTORY_SET_CUSTOM_RBTNDOWN('RELIC_GEM_MANAGER_TRANSFER_INV_RBTN')
	elseif index == 3 then
		RELIC_GEM_MANAGER_DECOMPOSE_OPEN(frame)
	end
end

function RELIC_GEM_MANAGER_TAB_CHANGE(parent, ctrl)
	local frame = parent:GetTopParentFrame()
	local tab = GET_CHILD_RECURSIVELY(frame, 'type_Tab')
	local index = tab:GetSelectItemIndex()
	TOGGLE_RELIC_GEM_MANAGER_TAB(frame, index)
end

-- 강화
local function _REINFORCE_MAT_CTRL_UPDATE(frame, index, mat_name, mat_cnt, is_discount)
	if is_discount == nil then
		is_discount = 0
	end

	local ctrlset = GET_CHILD_RECURSIVELY(frame, 'rmat_' .. index)
	if mat_name ~= nil then
		local mat_cls = GetClass('Item', mat_name)
		if mat_cls ~= nil then
			local mat_slot = GET_CHILD(ctrlset, 'mat_slot', 'ui::CSlot')
			mat_slot:SetUserValue('NEED_COUNT', mat_cnt)

			if mat_cnt > 0 then
				ctrlset:ShowWindow(1)
				
				mat_slot:SetEventScript(ui.DROP, 'RELIC_GEM_MANAGER_REINFORCE_MAT_DROP')
				mat_slot:SetEventScriptArgString(ui.DROP, mat_name)
				mat_slot:SetEventScriptArgNumber(ui.DROP, mat_cnt)
				
				mat_slot:SetEventScript(ui.RBUTTONUP, 'REMOVE_RELIC_GEM_REINF_MATERIAL')
				mat_slot:SetEventScriptArgString(ui.RBUTTONUP, mat_name)
				mat_slot:SetEventScriptArgNumber(ui.RBUTTONUP, mat_cnt)
				
				if is_discount ~= 1 then
					mat_slot:SetUserValue('ITEM_GUID', 'None')
					local icon = imcSlot:SetImage(mat_slot, mat_cls.Icon)
					icon:SetColorTone('FFFF0000')
				end

				local cntText = string.format('{s16}{ol}{b} %d', mat_cnt)
				mat_slot:SetText(cntText, 'count', ui.RIGHT, ui.BOTTOM, -5, -5)

				local mat_name = GET_CHILD(ctrlset, 'mat_name', 'ui::CRichText')
				mat_name:SetTextByKey('value', dic.getTranslatedStr(TryGetProp(mat_cls, 'Name', 'None')))
			else
				ctrlset:ShowWindow(0)
			end
		end
	end
end

local function _REINFORCE_PRICE_UPDATE(frame, discountStone)
	if discountStone == nil then
		discountStone = 0
	end

	local r_price_gauge = GET_CHILD_RECURSIVELY(frame, 'r_price_gauge')
	local check_no_msgbox = GET_CHILD_RECURSIVELY(frame, 'check_no_msgbox')

	local price = frame:GetUserValue('REINFORCE_CUR_PRICE')
	if price == nil or price == 'None' then
		price = '0'
	end

	local totalPrice = frame:GetUserValue('REINFORCE_PRICE')
	if totalPrice == nil or totalPrice == 'None' then
		totalPrice = '0'
	end

	price = math.max(tonumber(DivForBigNumberInt64(price, '100000')), 0)
	totalPrice = math.max(tonumber(DivForBigNumberInt64(totalPrice, '100000')), 0)
	r_price_gauge:SetPoint(price, totalPrice)
	
	local gem_lv = tonumber(frame:GetUserValue('GEM_LV'))
	if gem_lv ~= nil then
		local _, stone_name = shared_item_relic.get_gem_reinforce_mat_name(gem_lv)
		local stone_cnt = shared_item_relic.get_gem_reinforce_mat_stone(gem_lv)

		if discountStone == stone_cnt and check_no_msgbox:IsChecked() ~= 1 then
			local textmsg = string.format("[ %s ]{nl}%s", ClMsg('RELIC_GEM_UPGRADE_TITLE_MSG'), ScpArgMsg("Enough_Relic_Gem_DiscountStone"))
			ui.MsgBox(textmsg)
		end

		if discountStone > 0 then
			stone_cnt = stone_cnt - discountStone
			if stone_cnt < 0 then
				stone_cnt = 0
			end
		end
		_REINFORCE_MAT_CTRL_UPDATE(frame, 2, stone_name, stone_cnt, 1)
	end
end

local function _REINFORCE_EXEC_BTN_UPDATE(frame)
	local do_reinforce = GET_CHILD_RECURSIVELY(frame, 'do_reinforce')

	local price = frame:GetUserValue('REINFORCE_CUR_PRICE')
	if price == nil or price == 'None' then
		price = '0'
	end

	local total_price = frame:GetUserValue('REINFORCE_PRICE')
	if total_price == nil or total_price == 'None' then
		total_price = '0'
	end

	local rmat_1 = GET_CHILD_RECURSIVELY(frame, 'rmat_1')
	local rmat_1_slot = GET_CHILD(rmat_1, 'mat_slot', 'ui::CSlot')
	local rmat_1_guid = rmat_1_slot:GetUserValue('ITEM_GUID')
	
	local rmat_2 = GET_CHILD_RECURSIVELY(frame, 'rmat_2')
	local rmat_2_slot = GET_CHILD(rmat_2, 'mat_slot', 'ui::CSlot')
	local rmat_2_guid = rmat_2_slot:GetUserValue('ITEM_GUID')
	local rmat_2_need = rmat_2_slot:GetUserIValue('NEED_COUNT')
	
	if IsGreaterThanForBigNumber(total_price, price) == 0 and rmat_1_guid ~= 'None' and (rmat_2_guid ~= 'None' or rmat_2_need <= 0) then
		do_reinforce:SetEnable(1)
	else
		do_reinforce:SetEnable(0)
	end
end

local function _CLEAR_ALL_REINFORCE_MATERIAL(frame)
	local rmat_1 = GET_CHILD_RECURSIVELY(frame, 'rmat_1')
	local rmat_1_slot = GET_CHILD(rmat_1, 'mat_slot', 'ui::CSlot')
	REMOVE_RELIC_GEM_REINF_MATERIAL(frame, rmat_1_slot)

	local rmat_2 = GET_CHILD_RECURSIVELY(frame, 'rmat_2')
	local rmat_2_slot = GET_CHILD(rmat_2, 'mat_slot', 'ui::CSlot')
	REMOVE_RELIC_GEM_REINF_MATERIAL(frame, rmat_2_slot)

	local discountSet = GET_CHILD_RECURSIVELY(frame, 'rslotlist_discount', 'ui::CSlotSet')
	for i = 0, discountSet:GetSlotCount() - 1 do
		frame:SetUserValue('DISCOUNT_MAT_' .. i, 0)
	end

	local extraMatSet = GET_CHILD_RECURSIVELY(frame, 'rslotlist_extra_mat')
	for i = 0, extraMatSet:GetSlotCount() - 1 do
		frame:SetUserValue('EXTRA_MAT_' .. i, 0)
	end
end

-- 강화 실패 시의 강화 UI 업데이트
function UPDATE_RELIC_GEM_MANAGER_REINFORCE(frame)
	if frame == nil then return end

	local rresult_gb = GET_CHILD_RECURSIVELY(frame, 'rresult_gb')
	rresult_gb:ShowWindow(0)

	local send_ok_reinforce = GET_CHILD_RECURSIVELY(frame, 'send_ok_reinforce')
	send_ok_reinforce:ShowWindow(0)

	local do_reinforce = GET_CHILD_RECURSIVELY(frame, 'do_reinforce')
	do_reinforce:ShowWindow(1)

	local gem_guid = frame:GetUserValue('GEM_GUID')
	if gem_guid == 'None' then return end
	local gem_item = session.GetInvItemByGuid(gem_guid)
	if gem_item ~= nil then
		_REINFORCE_PRICE_UPDATE(frame, 0)
		
		local clear_flag = false
		
		local gem_lv = tonumber(frame:GetUserValue('GEM_LV'))
		local misc_name, stone_name = shared_item_relic.get_gem_reinforce_mat_name(gem_lv)
		local inv_misc = session.GetInvItemByName(misc_name)
		local inv_stone = session.GetInvItemByName(stone_name)

		local stone_discount = 0
		local slotSet = GET_CHILD_RECURSIVELY(frame, 'rslotlist_discount')
		for i = 0, slotSet:GetSelectedSlotCount() - 1 do
			local slot = slotSet:GetSelectedSlot(i)
			local icon = CreateIcon(slot)
			local iconInfo = icon:GetInfo()
			local coupon_item = session.GetInvItemByGuid(iconInfo:GetIESID())
			local prevCnt = frame:GetUserIValue('DISCOUNT_MAT_' .. slot:GetSlotIndex())

			if coupon_item == nil or coupon_item.count < prevCnt then
				clear_flag = true
				break
			end

			local stone = tonumber(slot:GetUserValue("DISCOUNT_STONE"))
			stone_discount = stone_discount + (prevCnt * stone)
		end

		local extraMatSet = GET_CHILD_RECURSIVELY(frame, 'rslotlist_extra_mat')
		for i = 0, extraMatSet:GetSelectedSlotCount() - 1 do
			local slot = extraMatSet:GetSelectedSlot(i)
			local _guid = slot:GetUserValue('ITEM_GUID')
			local mat_item = session.GetInvItemByGuid(_guid)
			local prevCnt = frame:GetUserIValue('EXTRA_MAT_' .. slot:GetSlotIndex())
			if mat_item == nil or mat_item.count < prevCnt then
				clear_flag = true
				break
			end
		end

		local rmat_1 = GET_CHILD_RECURSIVELY(frame, 'rmat_1')
		local rmat_1_slot = GET_CHILD(rmat_1, 'mat_slot', 'ui::CSlot')
		local misc_cnt = rmat_1_slot:GetUserIValue('NEED_COUNT')
		if misc_cnt > 0 and (inv_misc == nil or inv_misc.count < misc_cnt) then
			clear_flag = true
		end
		
		local rmat_2 = GET_CHILD_RECURSIVELY(frame, 'rmat_2')
		local rmat_2_slot = GET_CHILD(rmat_2, 'mat_slot', 'ui::CSlot')
		local stone_cnt = rmat_2_slot:GetUserIValue('NEED_COUNT')
		local inv_cnt = 0
		if inv_stone ~= nil then
			inv_cnt = inv_stone.count
		end

		if stone_cnt > 0 and inv_cnt < stone_cnt - stone_discount then
			clear_flag = true
		end

		if clear_flag == true then
			_CLEAR_ALL_REINFORCE_MATERIAL(frame)
		end

		UPDATE_RELIC_GEM_MANAGER_REINFORCE_DISCOUNT(frame)

		UPDATE_RELIC_GEM_REINF_EXTRA_MAT(frame)

		RELIC_GEM_REINF_RATE_UPDATE(frame)
	end
end

function UPDATE_RELIC_GEM_MANAGER_REINFORCE_DISCOUNT(frame)
    local discountSet = GET_CHILD_RECURSIVELY(frame, 'rslotlist_discount', 'ui::CSlotSet')
    discountSet:ClearIconAll()

	local invItemList = session.GetInvItemList()
	local discountItemList = SCR_RELIC_GEM_REINFORCE_COUPON()

    FOR_EACH_INVENTORY(invItemList, 
    function(invItemList, invItem, discountSet, materialItemList, discountItemList)
		local obj = GetIES(invItem:GetObject())
        local itemName = TryGetProp(obj, 'ClassName', 'None')
        
        if table.find(discountItemList, itemName) > 0 then
			if imcSlot:GetFilledSlotCount(discountSet) == discountSet:GetSlotCount() then
				return
            end

            local slotindex = imcSlot:GetEmptySlotIndex(discountSet)
            local slot = discountSet:GetSlotByIndex(slotindex)
			slot:SetMaxSelectCount(invItem.count)
			slot:SetSelectCountPerCtrlClick(1000)
			slot:SetUserValue('DISCOUNT_POINT', obj.NumberArg1)
			slot:SetUserValue('DISCOUNT_STONE', obj.NumberArg2)
			slot:SetUserValue('DISCOUNT_TYPE', invItem.type)

			local icon = CreateIcon(slot)
            icon:Set(obj.Icon, 'Item', invItem.type, slotindex, invItem:GetIESID(), invItem.count)
            
			local class = GetClassByType('Item', invItem.type)
			SET_SLOT_ITEM_TEXT_USE_INVCOUNT(slot, invItem, obj, invItem.count)
			ICON_SET_INVENTORY_TOOLTIP(icon, invItem, 'poisonpot', class)

			local prevSelectedCount = frame:GetUserIValue('DISCOUNT_MAT_' .. slotindex)
			if prevSelectedCount <= invItem.count then
				slot:Select(1)
				slot:SetSelectCount(prevSelectedCount)
				RELIC_GEM_MANAGER_REINFORCE_DISCOUNT_CLICK(discountSet, slot)
			else
				slot:SetSelectCount(0)
				slot:Select(0)
				frame:SetUserValue('DISCOUNT_MAT_' .. slotindex, 0)
			end
        end

	end, false, discountSet, materialItemList, discountItemList)

	discountSet:MakeSelectionList()
end

function RELIC_GEM_MANAGER_REINFORCE_TOTAL_DISCOUNT_PRICE()
    local frame = ui.GetFrame('relic_gem_manager')
    if frame == nil then
        return
    end

    local slotSet = GET_CHILD_RECURSIVELY(frame, "rslotlist_discount")
	local totalDiscount = 0
	local stoneDiscount = 0

	for i = 0, slotSet:GetSlotCount() - 1 do
		local slot = slotSet:GetSlotByIndex(i)
		local point = tonumber(slot:GetUserValue("DISCOUNT_POINT"))
		local stone = tonumber(slot:GetUserValue("DISCOUNT_STONE"))
		if point == nil then 
			break
		end

		totalDiscount = SumForBigNumberInt64(totalDiscount, MultForBigNumberInt64(slot:GetSelectCount(), point))
		stoneDiscount = stoneDiscount + (slot:GetSelectCount() * stone)
    end
    
    return totalDiscount, stoneDiscount
end

-- 추가 재료 업데이트
function UPDATE_RELIC_GEM_REINF_EXTRA_MAT(frame)
	local slotset = GET_CHILD_RECURSIVELY(frame, 'rslotlist_extra_mat')
	slotset:ClearIconAll()
	for i = 0, slotset:GetSlotCount() - 1 do
		local slot = slotset:GetSlotByIndex(i)
		slot:RemoveChild('lv_txt')
	end
	slotset:SetUserValue('NORMAL_MAT_COUNT', 0)
	slotset:SetUserValue('PREMIUM_MAT_COUNT', 0)

	local guid = frame:GetUserValue('GEM_GUID')
	if guid ~= 'None' then
		local inv_item = session.GetInvItemByGuid(guid)
		if inv_item == nil then return end

		local inv_item_list = session.GetInvItemList()

		FOR_EACH_INVENTORY(inv_item_list, function(inv_item_list, inv_item, slotset)
			local obj = GetIES(inv_item:GetObject())
			local arg_str = item_relic_reinforce.is_reinforce_percentUp(obj)
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

				local prevSelectedCount = frame:GetUserIValue('EXTRA_MAT_' .. slotindex)
				if prevSelectedCount <= inv_item.count then
					slot:Select(1)
					slot:SetSelectCount(prevSelectedCount)
					SCR_LBTNDOWN_RELIC_GEM_REINF_EXTRA_MAT(slotset, slot)
				else
					slot:SetSelectCount(0)
					slot:Select(0)
					frame:SetUserValue('EXTRA_MAT_' .. slotindex, 0)
				end
			end
		end, false, slotset)
	end

	slotset:MakeSelectionList()
end

function RELIC_GEM_REINF_RATE_UPDATE(frame)
	local guid = frame:GetUserValue('GEM_GUID')
	if guid == nil or guid == 'None' then return end
	
	local inv_item = session.GetInvItemByGuid(guid)
	if inv_item == nil then return end

	local item_obj = GetIES(inv_item:GetObject())
	local gem_lv = frame:GetUserIValue('GEM_LV')

	local def_rate = shared_item_relic.get_gem_reinforce_ratio(gem_lv)
	local rdef_rate_value = GET_CHILD_RECURSIVELY(frame, 'rdef_rate_value')
	rdef_rate_value:SetTextByKey('value', string.format('%.2f', def_rate * 0.0001))

	local add_rate_by_failure = item_relic_reinforce.get_additional_ratio(item_obj)
	local radd_rate_value = GET_CHILD_RECURSIVELY(frame, 'radd_rate_value')
	radd_rate_value:SetTextByKey('value', string.format('%.3f', add_rate_by_failure * 0.0001))

	local final_rate = def_rate + add_rate_by_failure
	local rtotal_rate_value = GET_CHILD_RECURSIVELY(frame, 'rtotal_rate_value')
	rtotal_rate_value:SetTextByKey('value', string.format('%.3f', final_rate * 0.0001))

	local slotset = GET_CHILD_RECURSIVELY(frame, 'rslotlist_extra_mat')
	local normal_cnt = slotset:GetUserIValue('NORMAL_MAT_COUNT')
	local premium_cnt = slotset:GetUserIValue('PREMIUM_MAT_COUNT')
	local add_rate_when_failed = item_relic_reinforce.get_revision_ratio(def_rate, normal_cnt, premium_cnt)	
	local rextra_mat_text = GET_CHILD_RECURSIVELY(frame, 'rextra_mat_text')
	rextra_mat_text:SetTextByKey('value', string.format('%.3f', add_rate_when_failed * 0.0001))
end

function SCR_LBTNDOWN_RELIC_GEM_REINF_EXTRA_MAT(slotset, slot)
	if ui.CheckHoldedUI() == true then return end

	local frame = slotset:GetTopParentFrame()
	ui.EnableSlotMultiSelect(1)

	local guid = frame:GetUserValue('GEM_GUID')
	if guid == 'None' then return end
	
	local normal_max = GET_RELIC_MAX_SUB_REVISION_COUNT()
	local premium_max = GET_RELIC_MAX_PREMIUM_SUB_REVISION_COUNT()
	local normal_cnt = 0
	local premium_cnt = 0
	for i = 0, slotset:GetSlotCount() - 1 do
		local _slot = slotset:GetSlotByIndex(i)
		if _slot ~= slot then
			local cnt = _slot:GetSelectCount()
			if cnt > 0 then
				local arg_str = _slot:GetUserValue('MAT_TYPE')
				if arg_str == 'normal' then
					normal_cnt = normal_cnt + cnt
				elseif arg_str == 'premium' then
					premium_cnt = premium_cnt + cnt
				end
			end
			
			if cnt == 0 then
				_slot:Select(0)
			end
		end
	end

	local select_cnt = slot:GetSelectCount()
	local arg_str = slot:GetUserValue('MAT_TYPE')
	if arg_str == 'normal' then
		if normal_cnt + select_cnt > normal_max then
			local adjust_cnt = normal_max - normal_cnt
			if adjust_cnt < 0 then
				adjust_cnt = 0
			end

			select_cnt = adjust_cnt
		end
		normal_cnt = normal_cnt + select_cnt
	elseif arg_str == 'premium' then
		if premium_cnt + select_cnt > premium_max then
			local adjust_cnt = premium_max - premium_cnt
			if adjust_cnt < 0 then
				adjust_cnt = 0
			end
			
			select_cnt = adjust_cnt
		end
		premium_cnt = premium_cnt + select_cnt
	end

	slot:SetSelectCount(select_cnt)
	if select_cnt == 0 then
		slot:Select(0)
	end

	frame:SetUserValue('EXTRA_MAT_' .. slot:GetSlotIndex(), select_cnt)

	slotset:SetUserValue('NORMAL_MAT_COUNT', normal_cnt)
	slotset:SetUserValue('PREMIUM_MAT_COUNT', premium_cnt)

	RELIC_GEM_REINF_RATE_UPDATE(frame)
end

function RELIC_GEM_MANAGER_REINFORCE_COUPON_CLICK(slotset, slot)
	local frame = slotset:GetTopParentFrame()
	if frame == nil then return end

	local gem_lv = frame:GetUserIValue('GEM_LV')
	if gem_lv <= 0 then return end

	local totalPrice = frame:GetUserValue('REINFORCE_PRICE')
	local totalStone = shared_item_relic.get_gem_reinforce_mat_stone(gem_lv)
end

function RELIC_GEM_MANAGER_REINFORCE_DISCOUNT_CLICK(slotSet, slot)
    local frame = ui.GetFrame('relic_gem_manager')
    if frame == nil then
        return
	end
	
	local gem_lv = tonumber(frame:GetUserValue('GEM_LV'))
	if gem_lv == nil then
		return
	end

	local totalPrice = frame:GetUserValue('REINFORCE_PRICE')
	local totalStone = shared_item_relic.get_gem_reinforce_mat_stone(gem_lv)
    local discountPrice, discountStone = RELIC_GEM_MANAGER_REINFORCE_TOTAL_DISCOUNT_PRICE()

    -- 할인가 계산
	local adjustValue = SumForBigNumberInt64(totalPrice, tostring(tonumber(discountPrice) * -1))
	local adjustStone = totalStone - discountStone

	-- 할인가가 0보다 작을 경우
	if IsGreaterThanForBigNumber(0, adjustValue) == 1 then
		local stone = tonumber(slot:GetUserValue("DISCOUNT_STONE"))
		-- 축석 할인 있음 -> 촉매제
		if stone ~= nil and stone > 0 then
			local point = tonumber(slot:GetUserValue("DISCOUNT_POINT"))
			if point == nil or point == 0 then
				return
			end
	
			local nowCount = slot:GetSelectCount()
			local adjustByPoint = math.floor(tonumber(DivForBigNumberInt64(adjustValue, point)))
			local adjustByStone = math.floor(adjustStone / stone)
			if adjustByPoint <= 0 and adjustByStone < 0 then
				local adjustCount = math.max(adjustByPoint, adjustByStone)
				local adjustedCount = math.max(nowCount + adjustCount, 0)
				slot:SetSelectCount(adjustedCount)
				adjustValue = SumForBigNumberInt64(adjustValue, tostring(adjustCount * point * -1))
			end

			-- 일반 강화 쿠폰 감소 처리
			local _adjustValue = adjustValue
			for i = 0, slotSet:GetSelectedSlotCount() - 1 do
				local _slot = slotSet:GetSelectedSlot(i)
				local _point = tonumber(_slot:GetUserValue("DISCOUNT_POINT"))
				local _stone = tonumber(_slot:GetUserValue("DISCOUNT_STONE"))
				if _stone == 0 then
					local _nowCount = _slot:GetSelectCount()
					local _adjustCount = math.floor(tonumber(DivForBigNumberInt64(_adjustValue, _point)))
					local _adjustedCount = math.max(_nowCount + _adjustCount, 0)
					_slot:SetSelectCount(_adjustedCount)
					frame:SetUserValue('DISCOUNT_MAT_' .. _slot:GetSlotIndex(), _adjustedCount)

					if _adjustedCount == 0 then
						_slot:Select(0)
					end

					_adjustValue = _adjustValue - (_adjustedCount * _point)
					if _adjustValue >= 0 then
						break
					end
				end
			end
		else
			local point = tonumber(slot:GetUserValue("DISCOUNT_POINT"))
			if point == nil or point == 0 then
				return
			end
	
			local nowCount = slot:GetSelectCount()
			local adjustCount = math.floor(tonumber(DivForBigNumberInt64(adjustValue, point)))
			adjustCount = math.max(nowCount + adjustCount, 0)
			slot:SetSelectCount(adjustCount)
		end
	end

	-- 선택한게 없으면 포커스 풀어주기
	local selectedCount = slot:GetSelectCount()
	if selectedCount == 0 then
		slot:Select(0)
	end

	local mat_type = slot:GetUserValue('DISCOUNT_TYPE')
	frame:SetUserValue('DISCOUNT_MAT_' .. slot:GetSlotIndex(), selectedCount)

    ui.EnableSlotMultiSelect(1)

    -- 초과금액 걷어내기 끝난다음 다시 계산
    local totalPrice = frame:GetUserValue('REINFORCE_PRICE')
	local discountPrice, discountStone = RELIC_GEM_MANAGER_REINFORCE_TOTAL_DISCOUNT_PRICE()
	frame:SetUserValue('REINFORCE_CUR_PRICE', discountPrice)
	_REINFORCE_PRICE_UPDATE(frame, discountStone)
	_REINFORCE_EXEC_BTN_UPDATE(frame)
end

-- Belonging Check Function To save resource DB loading in client
function GET_RELIC_IS_BELONGING(guid)
    local inv_item = session.GetInvItemByGuid(guid)
	if inv_item == nil then return end

	local item_obj = GetIES(inv_item:GetObject())	
	if item_obj == nil then return end
	
	local belonging = TryGetProp(item_obj,"CharacterBelonging",0)
	return tonumber(belonging)
end

function RELIC_GEM_MANAGER_REINFORCE_INV_RBTN(item_obj, slot)
	local frame = ui.GetFrame('relic_gem_manager')
	if frame == nil then return end

	local icon = CreateIcon(slot)
    local icon_info = icon:GetInfo()
	local guid = icon_info:GetIESID()
	
	if GET_RELIC_IS_BELONGING(guid) == 1 then
		ui.SysMsg(ClMsg('InvalidGem'))
		return
	end

	local inv_item = session.GetInvItemByGuid(guid)
	if inv_item == nil then return end

	local item_obj = GetIES(inv_item:GetObject())
	
	if item_obj == nil then return end
	
	local tab = GET_CHILD_RECURSIVELY(frame, 'type_Tab')
	if tab == nil then return end

	local index = tab:GetSelectItemIndex()
	if index ~= 0 then return end

	RELIC_GEM_MANAGER_REINFORCE_REG_ITEM(frame, inv_item, item_obj)
end

function RELIC_GEM_MANAGER_REINFORCE_GEM_DROP(frame, icon, argStr, argNum)
	if ui.CheckHoldedUI() == true then return end
	frame = ui.GetFrame('relic_gem_manager')
	if frame == nil then return end

	local tab = GET_CHILD_RECURSIVELY(frame, 'type_Tab')
	if tab == nil then return end

	local index = tab:GetSelectItemIndex()
	if index ~= 0 then return end

	local lift_icon = ui.GetLiftIcon()
	local icon_info = lift_icon:GetInfo()
	local guid = icon_info:GetIESID()
	local from_frame = lift_icon:GetTopParentFrame()

	if GET_RELIC_IS_BELONGING(guid) == 1 then
		ui.SysMsg(ClMsg('InvalidGem'))
		return
	end

    if from_frame:GetName() == 'inventory' then
        local icon_info = lift_icon:GetInfo()
        local guid = icon_info:GetIESID()
        local inv_item = session.GetInvItemByGuid(guid)
		if inv_item == nil then return end
		
		local item_obj = GetIES(inv_item:GetObject())
		if item_obj == nil then return end
        
		RELIC_GEM_MANAGER_REINFORCE_REG_GEM(frame, inv_item, item_obj)
	end
end

function RELIC_GEM_MANAGER_REINFORCE_MAT_DROP(frame, icon, argStr, argNum)
	if ui.CheckHoldedUI() == true then return end

	frame = ui.GetFrame('relic_gem_manager')
	if frame == nil then return end

	local tab = GET_CHILD_RECURSIVELY(frame, 'type_Tab')
	if tab == nil then return end

	local index = tab:GetSelectItemIndex()
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
        
		RELIC_GEM_MANAGER_REINFORCE_REG_MAT(frame, inv_item, item_obj)
	end
end

function RELIC_GEM_MANAGER_REINFORCE_GEM_REMOVE(frame, slot)
	if ui.CheckHoldedUI() == true then return end

	frame = ui.GetFrame('relic_gem_manager')
	if frame == nil then return end

	CLEAR_RELIC_GEM_MANAGER_REINFORCE()
end

function REMOVE_RELIC_GEM_REINF_MATERIAL(frame, slot)
	if ui.CheckHoldedUI() == true then return end

	frame = ui.GetFrame('relic_gem_manager')
	if frame == nil then return end

	slot:SetUserValue('ITEM_GUID', 'None')

    local icon = CreateIcon(slot)
	icon:SetColorTone('FFFF0000')
	
	_REINFORCE_EXEC_BTN_UPDATE(frame)
end

function RELIC_GEM_MANAGER_REINFORCE_REG_GEM(frame, inv_item, item_obj)
	if TryGetProp(item_obj, 'GroupName', 'None') ~= 'Gem_Relic' then
		-- 성물 젬이 아닙니다
		ui.SysMsg(ClMsg('NOT_A_RELIC_GEM'))
		return
	end

	if shared_item_relic.is_max_gem_lv(item_obj) then
		-- 최대 레벨
		ui.SysMsg(ClMsg('CantUseInMaxLv'))
		return
	end

	local rinput_gb = GET_CHILD_RECURSIVELY(frame, 'rinput_gb')
	if rinput_gb:IsVisible() == 1 then
		rinput_gb:ShowWindow(0)
	end

	local rslot_gb = GET_CHILD_RECURSIVELY(frame, 'rslot_gb')
	if rslot_gb:IsVisible() == 0 then
		rslot_gb:ShowWindow(1)
	end

	local rgem_name = GET_CHILD_RECURSIVELY(frame, 'rgem_name')
	local name_str = GET_RELIC_GEM_NAME_WITH_FONT(item_obj)
	rgem_name:SetTextByKey('value', name_str)

	local rgem_slot = GET_CHILD_RECURSIVELY(frame, 'rgem_slot')
	SET_SLOT_ITEM(rgem_slot, inv_item)

	local gem_id = TryGetProp(item_obj, 'ClassID', 0)
	local gem_lv = TryGetProp(item_obj, 'GemLevel', 1)
	frame:SetUserValue('GEM_TYPE', gem_id)
	frame:SetUserValue('GEM_LV', gem_lv)
	frame:SetUserValue('GEM_GUID', inv_item:GetIESID())

	_CLEAR_ALL_REINFORCE_MATERIAL(frame)

	local rmat_inner = GET_CHILD_RECURSIVELY(frame, 'rmat_inner')

	local misc_name, stone_name = shared_item_relic.get_gem_reinforce_mat_name(gem_lv)
	local misc_cnt = shared_item_relic.get_gem_reinforce_mat_misc(gem_lv)
	local stone_cnt = shared_item_relic.get_gem_reinforce_mat_stone(gem_lv)
	_REINFORCE_MAT_CTRL_UPDATE(frame, 1, misc_name, misc_cnt)
	_REINFORCE_MAT_CTRL_UPDATE(frame, 2, stone_name, stone_cnt)
	
	local silver_cnt = shared_item_relic.get_gem_reinforce_silver(gem_lv)
	frame:SetUserValue('REINFORCE_PRICE', silver_cnt)
	_REINFORCE_PRICE_UPDATE(frame, 0)

	rmat_inner:ShowWindow(1)

	local rextra_mat_info = GET_CHILD_RECURSIVELY(frame, 'rextra_mat_info')
	rextra_mat_info:ShowWindow(1)

	UPDATE_RELIC_GEM_REINF_EXTRA_MAT(frame)

	local rprice_info = GET_CHILD_RECURSIVELY(frame, 'rprice_info')
	rprice_info:ShowWindow(1)

	UPDATE_RELIC_GEM_MANAGER_REINFORCE_DISCOUNT(frame)

	RELIC_GEM_REINF_RATE_UPDATE(frame)

	_REINFORCE_EXEC_BTN_UPDATE(frame)
end

local function _REG_REINFORCE_MATERIAL(frame, ctrlset, inv_item, item_obj, itemtype)
	if itemtype == 'mat' then
	
		if ctrlset == nil then return end
	
		local slot = GET_CHILD(ctrlset, 'mat_slot', 'ui::CSlot')
		if slot == nil then return end
	
		local need_cnt = slot:GetUserIValue('NEED_COUNT')
	    local cur_cnt = GET_INV_ITEM_COUNT_BY_PROPERTY({
	        { Name = 'ClassName', Value = item_obj.ClassName }
	    }, false)
	
		if cur_cnt < need_cnt then
	        ui.SysMsg(ClMsg('NotEnoughRecipe'))
	        return
	    end
	
	    local icon = CreateIcon(slot)
	    icon:SetColorTone('FFFFFFFF')
	
		local guid = GetIESID(item_obj)
	    slot:SetUserValue('ITEM_GUID', guid)

		--use only compose tab--
		local btn = ctrlset:GetChild("btn");
		if btn~=nil then btn:ShowWindow(0) end 
		------------------------
	elseif itemtype == 'gem' then

		if ctrlset == nil then return end

		local slot = GET_CHILD(ctrlset, 'slot_bg1', 'ui::CSlot')
		if slot == nil then return end
	
		local guid = GetIESID(item_obj)
	    slot:SetUserValue('ITEM_GUID', guid)
	
	end
end

function RELIC_GEM_MANAGER_REINFORCE_REG_MAT(frame, inv_item, item_obj)
	local item_name = TryGetProp(item_obj, 'ClassName', 'None')
	local gem_lv = frame:GetUserIValue('GEM_LV')
	local misc_name, stone_name = shared_item_relic.get_gem_reinforce_mat_name(gem_lv)
	if item_name == misc_name then
		local ctrlset = GET_CHILD_RECURSIVELY(frame, 'rmat_1')
		_REG_REINFORCE_MATERIAL(frame, ctrlset, inv_item, item_obj, 'mat')
	elseif item_name == stone_name then
		local ctrlset = GET_CHILD_RECURSIVELY(frame, 'rmat_2')
		_REG_REINFORCE_MATERIAL(frame, ctrlset, inv_item, item_obj, 'mat')
	else
		ui.SysMsg(ClMsg('IMPOSSIBLE_ITEM'))
	end

	_REINFORCE_EXEC_BTN_UPDATE(frame)
end

function RELIC_GEM_MANAGER_REINFORCE_REG_ITEM(frame, inv_item, item_obj)
	if inv_item.isLockState == true then
		ui.SysMsg(ClMsg('MaterialItemIsLock'))
		return
	end

	local gem_guid = frame:GetUserValue('GEM_GUID')
	if gem_guid == 'None' then
		RELIC_GEM_MANAGER_REINFORCE_REG_GEM(frame, inv_item, item_obj)
	else
		RELIC_GEM_MANAGER_REINFORCE_REG_MAT(frame, inv_item, item_obj)
	end
end

function CONFIRM_RELIC_GEM_MANAGER_REINFORCE()
	local frame = ui.GetFrame('relic_gem_manager')
	if frame == nil then return end

	local result = frame:GetUserValue('END_RELIC_GEM_REINFORCE')
	if result == "SUCCESS" then
		CLEAR_RELIC_GEM_MANAGER_REINFORCE()
	elseif result == "FAILED" then
		UPDATE_RELIC_GEM_MANAGER_REINFORCE(frame)
	end
end

function CLEAR_RELIC_GEM_MANAGER_REINFORCE()
	local frame = ui.GetFrame('relic_gem_manager')
	if frame == nil then return end

	local rresult_gb = GET_CHILD_RECURSIVELY(frame, 'rresult_gb')
	rresult_gb:ShowWindow(0)

	local rgem_slot = GET_CHILD_RECURSIVELY(frame, 'rgem_slot')
	rgem_slot:ClearIcon()
	
	local rgem_name = GET_CHILD_RECURSIVELY(frame, 'rgem_name')
	rgem_name:SetText('')

	local rslot_gb = GET_CHILD_RECURSIVELY(frame, 'rslot_gb')
	rslot_gb:ShowWindow(0)
	
	local rinput_gb = GET_CHILD_RECURSIVELY(frame, 'rinput_gb')
	rinput_gb:ShowWindow(1)

	local send_ok_reinforce = GET_CHILD_RECURSIVELY(frame, 'send_ok_reinforce')
	send_ok_reinforce:ShowWindow(0)
	
	local do_reinforce = GET_CHILD_RECURSIVELY(frame, 'do_reinforce')
	do_reinforce:ShowWindow(1)
	do_reinforce:SetEnable(0)

	frame:SetUserValue('GEM_TYPE', 0)
	frame:SetUserValue('GEM_GUID', 'None')

	local discountSet = GET_CHILD_RECURSIVELY(frame, 'rslotlist_discount', 'ui::CSlotSet')
	for i = 0, discountSet:GetSlotCount() - 1 do
		frame:SetUserValue('DISCOUNT_MAT_' .. i, 0)
	end

	local extraMatSet = GET_CHILD_RECURSIVELY(frame, 'rslotlist_extra_mat', 'ui::CSlotSet')
	for i = 0, extraMatSet:GetSlotCount() - 1 do
		frame:SetUserValue('EXTRA_MAT_' .. i, 0)
	end

	local rmat_inner = GET_CHILD_RECURSIVELY(frame, 'rmat_inner')
	rmat_inner:ShowWindow(0)

	local rextra_mat_info = GET_CHILD_RECURSIVELY(frame, 'rextra_mat_info')
	rextra_mat_info:ShowWindow(0)

	local rprice_info = GET_CHILD_RECURSIVELY(frame, 'rprice_info')
	rprice_info:ShowWindow(0)
end

function RELIC_GEM_MANAGER_REINFORCE_OPEN(frame)
	local reinforceBg = GET_CHILD_RECURSIVELY(frame, 'reinforceBg')
	if reinforceBg:IsVisible() ~= 1 then return end
end

local function _CHECK_MAT_MATERIAL_STATE(ctrlset)
	local mat_slot = GET_CHILD(ctrlset, 'mat_slot', 'ui::CSlot')
	local guid = mat_slot:GetUserValue('ITEM_GUID')
	local inv_item = session.GetInvItemByGuid(guid)
	if inv_item == nil then
		return false, 'None'
	end

	local item_obj = GetIES(inv_item:GetObject())
	if item_obj == nil then
		return false, 'None'
	end

	local need_cnt = mat_slot:GetUserIValue('NEED_COUNT')
	local cur_cnt = GET_INV_ITEM_COUNT_BY_PROPERTY({
        { Name = 'ClassName', Value = item_obj.ClassName }
	}, false)
	if cur_cnt < need_cnt then
        return false, 'NotEnoughRecipe'
	end

	if inv_item.isLockState == true then
		return false, 'MaterialItemIsLock'
	end

	return true
end

function RELIC_GEM_MANAGER_REINFORCE_EXEC(parent)	
	local frame = parent:GetTopParentFrame()
	if frame == nil then return end
	
	local guid = frame:GetUserValue('GEM_GUID')
	if guid == 'None' then return end
	
	local gem_item = session.GetInvItemByGuid(guid)
	if gem_item == nil then return end
	
	local gem_obj = GetIES(gem_item:GetObject())
	if gem_obj == nil then return end
	
	if gem_item.isLockState == true then
		ui.SysMsg(ClMsg('MaterialItemIsLock'))
		return
	end
	
	local rmat_1 = GET_CHILD_RECURSIVELY(frame, 'rmat_1')
	if rmat_1:IsVisible() == 1 then
		local check1, msg1 = _CHECK_MAT_MATERIAL_STATE(rmat_1)
		if check1 == false then
			if msg1 ~= nil and msg1 ~= 'None' then
				ui.SysMsg(ClMsg(msg1))
			end
			return
		end
	end
	
	local rmat_2 = GET_CHILD_RECURSIVELY(frame, 'rmat_2')
	if rmat_2:IsVisible() == 1 then
		local check2, msg2 = _CHECK_MAT_MATERIAL_STATE(rmat_2)
		if check2 == false then
			if msg2 ~= nil and msg2 ~= 'None' then
				ui.SysMsg(ClMsg(msg2))
			end
			return
		end
	end

    local original = frame:GetUserValue('REINFORCE_PRICE')
    local discount = RELIC_GEM_MANAGER_REINFORCE_TOTAL_DISCOUNT_PRICE()

	local silver_cnt = SumForBigNumberInt64(original, tostring(tonumber(discount) * -1))
	silver_cnt = math.max(tonumber(silver_cnt), 0)
    local my_money = GET_TOTAL_MONEY_STR()
    
    if IsGreaterThanForBigNumber(silver_cnt, my_money) == 1 then
        ui.SysMsg(ClMsg('NotEnoughMoney'))
        return
	end
	
	session.ResetItemList()
    session.AddItemID(guid, 1)

    -- 강화 할인 쿠폰 등록
    local discountSet = GET_CHILD_RECURSIVELY(frame, 'rslotlist_discount', 'ui::CSlotSet')
    for i = 0, discountSet:GetSelectedSlotCount() -1 do
        local slot = discountSet:GetSelectedSlot(i)
        local Icon = CreateIcon(slot)
        local iconInfo = Icon:GetInfo()
		local cnt = slot:GetSelectCount()
		local dis_item = session.GetInvItemByGuid(iconInfo:GetIESID())
        session.AddItemID(iconInfo:GetIESID(), cnt)
    end
	
	-- 여기서 보조제를 등록
	local extraMatSet = GET_CHILD_RECURSIVELY(frame, 'rslotlist_extra_mat')
	for i = 0, extraMatSet:GetSelectedSlotCount() - 1 do
		local slot = extraMatSet:GetSelectedSlot(i)
		local _guid = slot:GetUserValue('ITEM_GUID')
		local cnt = slot:GetSelectCount()
		session.AddItemID(_guid, cnt)
	end
	
	local check_no_msgbox = GET_CHILD_RECURSIVELY(frame, 'check_no_msgbox')
	if check_no_msgbox:IsChecked() == 1 then
		_RELIC_GEM_MANAGER_REINFORCE_EXEC()
	else
		local gem_name = dic.getTranslatedStr(TryGetProp(gem_obj, 'Name', 'None'))
		local msg = ScpArgMsg('REALLY_DO_RELIC_GEM_REINFORCE', 'SILVER', silver_cnt, 'NAME', gem_name)
		local yesScp = '_RELIC_GEM_MANAGER_REINFORCE_EXEC()'
		local msgbox = ui.MsgBox(msg, yesScp, 'None')
		SET_MODAL_MSGBOX(msgbox)
	end
end

function _RELIC_GEM_MANAGER_REINFORCE_EXEC()
	local frame = ui.GetFrame('relic_gem_manager')
	if frame == nil then return end

	local do_reinforce = GET_CHILD_RECURSIVELY(frame, 'do_reinforce')

	local result_list = session.GetItemIDList()

	item.DialogTransaction('RELIC_GEM_REINFORCE', result_list)
end

function END_RELIC_GEM_REINFORCE(frame, msg, arg_str, arg_num)
	local do_reinforce = GET_CHILD_RECURSIVELY(frame, 'do_reinforce')
	if do_reinforce ~= nil then
		do_reinforce:ShowWindow(0)
	end

	frame:SetUserValue('END_RELIC_GEM_REINFORCE', arg_str)

	if arg_str == 'SUCCESS' then
		ReserveScript('_RUN_RELIC_GEM_REINFORCE_SUCCESS()', 0)
	elseif arg_str == 'FAILED' then
		ReserveScript('_RUN_RELIC_GEM_REINFORCE_FAILED()', 0)
	end
end

function _RUN_RELIC_GEM_REINFORCE_SUCCESS()
	local frame = ui.GetFrame('relic_gem_manager')
	if frame:IsVisible() == 0 then return end

	local rslot_gb = GET_CHILD_RECURSIVELY(frame, 'rslot_gb')
	if rslot_gb == nil then return end

	rslot_gb:ShowWindow(0)

	local send_ok_reinforce = GET_CHILD_RECURSIVELY(frame, 'send_ok_reinforce')
	send_ok_reinforce:ShowWindow(1)

	local rresult_gb = GET_CHILD_RECURSIVELY(frame, 'rresult_gb')
	rresult_gb:ShowWindow(1)

	local r_success_effect_bg = GET_CHILD_RECURSIVELY(frame, 'r_success_effect_bg')
	local r_success_skin = GET_CHILD_RECURSIVELY(frame, 'r_success_skin')
	local r_text_success = GET_CHILD_RECURSIVELY(frame, 'r_text_success')
	r_success_effect_bg:ShowWindow(1)
	r_success_skin:ShowWindow(1)
	r_text_success:ShowWindow(1)

	local r_fail_effect_bg = GET_CHILD_RECURSIVELY(frame, 'r_fail_effect_bg')
	local r_fail_skin = GET_CHILD_RECURSIVELY(frame, 'r_fail_skin')
	local r_text_fail = GET_CHILD_RECURSIVELY(frame, 'r_text_fail')
	r_fail_effect_bg:ShowWindow(0)
	r_fail_skin:ShowWindow(0)
	r_text_fail:ShowWindow(0)

	local r_result_item_img = GET_CHILD_RECURSIVELY(frame, 'r_result_item_img')
	r_result_item_img:ShowWindow(1)

	local gem_guid = frame:GetUserValue('GEM_GUID')
	local gem_item = session.GetInvItemByGuid(gem_guid)
	local gem_obj = GetIES(gem_item:GetObject())
	r_result_item_img:SetImage(TryGetProp(gem_obj, 'Icon', 'None'))
				
	RELIC_GEM_REINFORCE_SUCCESS_EFFECT(frame)
end

function RELIC_GEM_REINFORCE_SUCCESS_EFFECT(frame)
	local frame = ui.GetFrame('relic_gem_manager')
	local SUCCESS_EFFECT_NAME = frame:GetUserConfig('DO_SUCCESS_EFFECT')
	local SUCCESS_EFFECT_SCALE = tonumber(frame:GetUserConfig('SUCCESS_EFFECT_SCALE'))
	local SUCCESS_EFFECT_DURATION = tonumber(frame:GetUserConfig('SUCCESS_EFFECT_DURATION'))
	local r_success_effect_bg = GET_CHILD_RECURSIVELY(frame, 'r_success_effect_bg')
	if r_success_effect_bg == nil then return end

	local rslot_gb = GET_CHILD_RECURSIVELY(frame, 'rslot_gb')
	if rslot_gb == nil then return end

	rslot_gb:ShowWindow(0)

	r_success_effect_bg:PlayUIEffect(SUCCESS_EFFECT_NAME, SUCCESS_EFFECT_SCALE, 'DO_SUCCESS_EFFECT')

	ReserveScript('_RELIG_GEM_REINFORCE_SUCCESS_EFFECT()', SUCCESS_EFFECT_DURATION)
end

function  _RELIG_GEM_REINFORCE_SUCCESS_EFFECT()
	local frame = ui.GetFrame('relic_gem_manager')
	if frame:IsVisible() == 0 then return end

	local r_success_effect_bg = GET_CHILD_RECURSIVELY(frame, 'r_success_effect_bg')
	if r_success_effect_bg == nil then return end

	r_success_effect_bg:StopUIEffect('DO_SUCCESS_EFFECT', true, 0.5)

	ui.SetHoldUI(false)
end

function _RUN_RELIC_GEM_REINFORCE_FAILED()
	local frame = ui.GetFrame('relic_gem_manager')
	if frame:IsVisible() == 0 then return end

	local rslot_gb = GET_CHILD_RECURSIVELY(frame, 'rslot_gb')
	if rslot_gb == nil then return end

	rslot_gb:StopUIEffect('DO_RESULT_EFFECT', true, 0.5)
	rslot_gb:ShowWindow(1)

	local send_ok_reinforce = GET_CHILD_RECURSIVELY(frame, 'send_ok_reinforce')
	if send_ok_reinforce ~= nil then
		send_ok_reinforce:ShowWindow(1)
	end

	local rresult_gb = GET_CHILD_RECURSIVELY(frame, 'rresult_gb')
	rresult_gb:ShowWindow(1)
	local r_success_effect_bg = GET_CHILD_RECURSIVELY(frame, 'r_success_effect_bg')
	local r_success_skin = GET_CHILD_RECURSIVELY(frame, 'r_success_skin')
	local r_text_success = GET_CHILD_RECURSIVELY(frame, 'r_text_success')
	r_success_effect_bg:ShowWindow(0)
	r_success_skin:ShowWindow(0)
	r_text_success:ShowWindow(0)

	local r_fail_skin = GET_CHILD_RECURSIVELY(frame, 'r_fail_skin')
	local r_text_fail = GET_CHILD_RECURSIVELY(frame, 'r_text_fail')
	r_fail_skin:ShowWindow(1)
	r_text_fail:ShowWindow(1)

	RELIC_GEM_REINFORCE_FAIL_EFFECT(frame)	
end

function RELIC_GEM_REINFORCE_FAIL_EFFECT(frame)
	local frame = ui.GetFrame('relic_gem_manager')
	local FAIL_EFFECT_NAME = frame:GetUserConfig('DO_FAIL_EFFECT')
	local FAIL_EFFECT_SCALE = tonumber(frame:GetUserConfig('FAIL_EFFECT_SCALE'))
	local FAIL_EFFECT_DURATION = tonumber(frame:GetUserConfig('FAIL_EFFECT_DURATION'))
	local r_fail_effect_bg = GET_CHILD_RECURSIVELY(frame, 'r_fail_effect_bg')
	if r_fail_effect_bg == nil then return end

	local r_result_item_img = GET_CHILD_RECURSIVELY(frame, 'r_result_item_img')
	r_result_item_img:ShowWindow(0)

	r_fail_effect_bg:PlayUIEffect(FAIL_EFFECT_NAME, FAIL_EFFECT_SCALE, 'DO_FAIL_EFFECT')

	ReserveScript('_RELIC_GEM_REINFORCE_FAIL_EFFECT()', FAIL_EFFECT_DURATION)
end

function  _RELIC_GEM_REINFORCE_FAIL_EFFECT()
	local frame = ui.GetFrame('relic_gem_manager')
	if frame:IsVisible() == 0 then return end

	local r_fail_effect_bg = GET_CHILD_RECURSIVELY(frame, 'r_fail_effect_bg')
	if r_fail_effect_bg == nil then return end

	r_fail_effect_bg:StopUIEffect('DO_FAIL_EFFECT', true, 0.5)
	ui.SetHoldUI(false)
end
-- 강화 끝

-- 합성
local function _COMPOSE_MAT_CTRL_UPDATE(frame, index, mat_name, mat_cnt)
	local ctrlset = GET_CHILD_RECURSIVELY(frame, 'cmat_' .. index)
	if mat_name ~= nil then
		local mat_cls = GetClass('Item', mat_name)
		if mat_cls ~= nil then
			local mat_slot = GET_CHILD(ctrlset, 'mat_slot', 'ui::CSlot')
			local needcount_text = GET_CHILD(ctrlset,'needcount') 
			mat_slot:SetUserValue('NEED_COUNT', mat_cnt)
			if mat_cnt > 0 then
				ctrlset:ShowWindow(1)
				
				mat_slot:SetEventScript(ui.DROP, 'RELIC_GEM_MANAGER_COMPOSE_MAT_DROP')
				mat_slot:SetEventScriptArgString(ui.DROP, mat_name)
				mat_slot:SetEventScriptArgNumber(ui.DROP, mat_cnt)
				
				mat_slot:SetEventScript(ui.RBUTTONUP, 'REMOVE_RELIC_GEM_COMP_MATERIAL')
				mat_slot:SetEventScriptArgString(ui.RBUTTONUP, mat_name)
				mat_slot:SetEventScriptArgNumber(ui.RBUTTONUP, mat_cnt)
				
				if is_discount ~= 1 then
					mat_slot:SetUserValue('ITEM_GUID', 'None')
					local icon = imcSlot:SetImage(mat_slot, mat_cls.Icon)
					icon:SetColorTone('FFFF0000')
				end
	
				needcount_text:SetTextByKey('count',mat_cnt)
				local btn = ctrlset:GetChild('btn')
				if btn~=nil then btn:ShowWindow(1) end

				local mat_name = GET_CHILD(ctrlset, 'mat_name', 'ui::CRichText')
				mat_name:SetTextByKey('value', dic.getTranslatedStr(TryGetProp(mat_cls, 'Name', 'None')))
			else
				ctrlset:ShowWindow(0)
			end
		end
	end
end

local function _COMPOSE_EXEC_BTN_UPDATE(frame)
	local do_compose = GET_CHILD_RECURSIVELY(frame, 'do_compose')

	local cmat_1 = GET_CHILD_RECURSIVELY(frame, 'cmat_1')
	local cmat_1_slot = GET_CHILD(cmat_1, 'mat_slot', 'ui::CSlot')
	local cmat_1_guid = cmat_1_slot:GetUserValue('ITEM_GUID')

	local cgem_1_slot = GET_CHILD_RECURSIVELY(frame, 'cgem_slot1')
	local cgem_1_guid = cgem_1_slot:GetUserValue('ITEM_GUID')
            
	local cgem_2_slot = GET_CHILD_RECURSIVELY(frame, 'cgem_slot2')
	local cgem_2_guid = cgem_2_slot:GetUserValue('ITEM_GUID')

	local cgem_3_slot = GET_CHILD_RECURSIVELY(frame, 'cgem_slot3')
	local cgem_3_guid = cgem_3_slot:GetUserValue('ITEM_GUID')

	if cmat_1_guid ~= 'None' and cgem_1_guid ~= 'None' and cgem_2_guid ~= 'None' and cgem_3_guid ~= 'None' then
		do_compose:SetEnable(1)
	else
		do_compose:SetEnable(0)
    end
end

function UPDATE_RELIC_GEM_MANAGER_COMPOSE(frame)
	local tab = GET_CHILD_RECURSIVELY(frame, 'type_Tab')
	if tab == nil then return end

	local tab_index = tab:GetSelectItemIndex()
	if tab_index ~= 1 then return end

	_COMPOSE_EXEC_BTN_UPDATE(frame)
end

function RELIC_GEM_MAT_CONTROLSET_BTN_EVENT(parent,self)
	local frame = ui.GetFrame('relic_gem_manager')
	if frame == nil then return end
	local invItemList = session.GetInvItemList();
	local item_name = nil;
	local misc_name = shared_item_relic.get_gem_compose_mat_name()
	
	FOR_EACH_INVENTORY(invItemList, function(invItemList, invItem, type, slotset)
		if invItem ~= nil then
			local item_obj = GetIES(invItem:GetObject());
			item_name = TryGetProp(item_obj, 'ClassName', 'None')
			if misc_name == item_name then
				RELIC_GEM_MANAGER_COMPOSE_REG_MAT(frame, invItem, item_obj)
			end
       	end
	end, false, type, slotset);
end

function RELIC_GEM_MANAGER_COMPOSE_INV_RBTN(item_obj, cslot)
	local frame = ui.GetFrame('relic_gem_manager')
	if frame == nil then return end

	local result = frame:GetUserIValue('C_RESULT_CLASSID')
	if result ~= 0 then return end

	local icon = cslot:GetIcon()
    local icon_info = icon:GetInfo()
	local guid = icon_info:GetIESID()
	
    local inv_item = session.GetInvItemByGuid(guid)
	if inv_item == nil then return end

	if GET_RELIC_IS_BELONGING(guid) == 1 then
		ui.SysMsg(ClMsg('InvalidGem'))
		return
	end

	local item_obj = GetIES(inv_item:GetObject())
	if item_obj == nil then return end
	
	local tab = GET_CHILD_RECURSIVELY(frame, 'type_Tab')
	if tab == nil then return end

	local index = tab:GetSelectItemIndex()
	if index ~= 1 then return end

	RELIC_GEM_MANAGER_COMPOSE_REG_MAT(frame, inv_item, item_obj)
end

function REMOVE_RELIC_GEM_COMP_MATERIAL(frame, cslot, isGem)
	if ui.CheckHoldedUI() == true then return end

	frame = ui.GetFrame('relic_gem_manager')
	if frame == nil then return end

	cslot:SetUserValue('ITEM_GUID', 'None')

	local icon = cslot:GetIcon()
	if icon ~= nil and isGem ~= 1 then
		icon:SetColorTone('FFFF0000')
		local ctrlset = cslot:GetParent();
		local btn = ctrlset:GetChild("btn");
		if btn ~= nil then btn:ShowWindow(1) end
	elseif icon ~= nil and isGem == 1 then
		cslot:ClearIcon()
	end
	
	UPDATE_RELIC_GEM_MANAGER_COMPOSE(frame)
end

function RELIC_GEM_MANAGER_COMPOSE_REG_MAT(frame, inv_item, item_obj)
	if inv_item.isLockState == true then
		ui.SysMsg(ClMsg('MaterialItemIsLock'))
		return
	end

	local item_name = TryGetProp(item_obj, 'ClassName', 'None')
	local misc_name = shared_item_relic.get_gem_compose_mat_name()
	if item_name == misc_name then
		local ctrlset = GET_CHILD_RECURSIVELY(frame, 'cmat_1')
		local itemtype = 'mat'
		_REG_REINFORCE_MATERIAL(frame, ctrlset, inv_item, item_obj, itemtype)


	elseif TryGetProp(item_obj, 'GroupName', 'None') == 'Gem_Relic' then
			if TryGetProp(item_obj, 'GemLevel', 'None') > 1 then
				ui.SysMsg(ClMsg('DO_NOT_RELIC_GEM_COMPOSE_LEVEL'))
				return
			end
	
			if TryGetProp(item_obj, "DecomposeAble", "NO") == "NO" then ui.SysMsg(ClMsg('IMPOSSIBLE_ITEM')) return end

			local cgem_slot1 = GET_CHILD_RECURSIVELY(frame, 'cgem_slot1')
			local cgem_slot2 = GET_CHILD_RECURSIVELY(frame, 'cgem_slot2')
			local cgem_slot3 = GET_CHILD_RECURSIVELY(frame, 'cgem_slot3')

		--- 세 번째 슬롯 검사
		if cgem_slot1:GetUserValue('ITEM_GUID') ~= 'None' and cgem_slot1:GetUserValue('ITEM_GUID') ~= nil and cgem_slot2:GetUserValue('ITEM_GUID') ~= 'None' and cgem_slot2:GetUserValue('ITEM_GUID') ~= nil then
			SET_SLOT_ITEM(cgem_slot3, inv_item)
			local icon = cgem_slot3:GetIcon()
		    local icon_info = icon:GetInfo()
			local guid = icon_info:GetIESID()
			cgem_slot3:SetUserValue('ITEM_GUID', guid)
	
			if cgem_slot1:GetUserValue('ITEM_GUID') == guid or cgem_slot2:GetUserValue('ITEM_GUID') == guid then
				cgem_slot3:ClearIcon()
				cgem_slot3:SetUserValue('ITEM_GUID', 'None')
			end

			--- 같은 등급 같은 색깔만 가능
			local slot1_gem_grade = TryGetProp(GetObjectByGuid(cgem_slot1:GetUserValue('ITEM_GUID')), "ItemGrade", "None")
			local slot1_gem_type = TryGetProp(GetObjectByGuid(cgem_slot1:GetUserValue('ITEM_GUID')), "GemType", "None")
		
			if slot1_gem_grade ~= TryGetProp(item_obj, "ItemGrade", "None") or slot1_gem_type ~= TryGetProp(item_obj, "GemType", "None") then
				cgem_slot3:ClearIcon()
				cgem_slot3:SetUserValue('ITEM_GUID', 'None')
				ui.SysMsg(ClMsg('RelicGemCompose1'))
			end

		-- 두 번째 슬롯 검사
		elseif cgem_slot1:GetUserValue('ITEM_GUID') ~= 'None' and cgem_slot1:GetUserValue('ITEM_GUID') ~= nil then
			SET_SLOT_ITEM(cgem_slot2, inv_item)
			local icon = cgem_slot2:GetIcon()
		    local icon_info = icon:GetInfo()
			local guid = icon_info:GetIESID()
			cgem_slot2:SetUserValue('ITEM_GUID', guid)

			if cgem_slot1:GetUserValue('ITEM_GUID') == guid or cgem_slot3:GetUserValue('ITEM_GUID') == guid then
				cgem_slot2:ClearIcon()
				cgem_slot2:SetUserValue('ITEM_GUID', 'None')
			end


			--- 같은 등급 같은 색깔만 가능
			local slot1_gem_grade = TryGetProp(GetObjectByGuid(cgem_slot1:GetUserValue('ITEM_GUID')), "ItemGrade", "None")
			local slot1_gem_type = TryGetProp(GetObjectByGuid(cgem_slot1:GetUserValue('ITEM_GUID')), "GemType", "None")
		
			if slot1_gem_grade ~= TryGetProp(item_obj, "ItemGrade", "None") or slot1_gem_type ~= TryGetProp(item_obj, "GemType", "None") then
				cgem_slot2:ClearIcon()
				cgem_slot2:SetUserValue('ITEM_GUID', 'None')
				ui.SysMsg(ClMsg('RelicGemCompose1'))
			end

		--- 첫 번째 슬롯
		else
			SET_SLOT_ITEM(cgem_slot1, inv_item)
			local icon = cgem_slot1:GetIcon()
		    local icon_info = icon:GetInfo()
			local guid = icon_info:GetIESID()
			cgem_slot1:SetUserValue('ITEM_GUID', guid)
			
			if cgem_slot2:GetUserValue('ITEM_GUID') == guid or cgem_slot3:GetUserValue('ITEM_GUID') == guid then
				cgem_slot1:ClearIcon()
				cgem_slot1:SetUserValue('ITEM_GUID', 'None')
			end

		end

	else
		ui.SysMsg(ClMsg('IMPOSSIBLE_ITEM'))
	end

	UPDATE_RELIC_GEM_MANAGER_COMPOSE(frame)
end


function CLEAR_RELIC_GEM_MANAGER_COMPOSE()
	local frame = ui.GetFrame('relic_gem_manager')
	if frame == nil then return end

	local result = frame:SetUserValue('C_RESULT_CLASSID', 0)

	local cresult_gb = GET_CHILD_RECURSIVELY(frame, 'cresult_gb')
	cresult_gb:ShowWindow(0)

	local send_ok_compose = GET_CHILD_RECURSIVELY(frame, 'send_ok_compose')
	send_ok_compose:ShowWindow(0)

	local do_compose = GET_CHILD_RECURSIVELY(frame, 'do_compose')
	do_compose:ShowWindow(1)

	local cmat_1 = GET_CHILD_RECURSIVELY(frame, 'cmat_1')
	local cmat_1_slot = GET_CHILD(cmat_1, 'mat_slot', 'ui::CSlot')
	REMOVE_RELIC_GEM_COMP_MATERIAL(frame, cmat_1_slot)

	for i = 1 , 3 do 
		local cgem_slot = GET_CHILD_RECURSIVELY(frame, 'cgem_slot'..i)
		local isGem = 1
		REMOVE_RELIC_GEM_COMP_MATERIAL(frame, cgem_slot, isGem)
	end
	
	UPDATE_RELIC_GEM_MANAGER_COMPOSE(frame)
end

function RELIC_GEM_MANAGER_COMPOSE_OPEN(frame)
	local composeBg = GET_CHILD_RECURSIVELY(frame, 'composeBg')
	if composeBg:IsVisible() ~= 1 then return end

	local mat_1 = shared_item_relic.get_gem_compose_mat_name()
	local cnt_1 = shared_item_relic.get_gem_compose_mat_cnt()

	_COMPOSE_MAT_CTRL_UPDATE(frame, 1, mat_1, cnt_1)

	UPDATE_RELIC_GEM_MANAGER_COMPOSE(frame)
end

function RELIC_GEM_MANAGER_COMPOSE_EXEC(parent)
	local frame = parent:GetTopParentFrame()
	if frame == nil then return end
	
	session.ResetItemList()

	-- 프리즘 콜을 아이템 리스트에 넣는다
	local cmat_1 = GET_CHILD_RECURSIVELY(frame, 'cmat_1')
	if cmat_1:IsVisible() == 1 then
		local cmat_slot_1 = GET_CHILD(cmat_1, 'mat_slot', 'ui::CSlot')
		local guid_1 = cmat_slot_1:GetUserValue('ITEM_GUID')
		local cnt_1 = cmat_slot_1:GetUserValue('NEED_COUNT')
		local check1, msg1 = _CHECK_MAT_MATERIAL_STATE(cmat_1)
		if check1 == false then
			if msg1 ~= nil and msg1 ~= 'None' then
				ui.SysMsg(ClMsg(msg1))
			end
			return
		end
		session.AddItemID(guid_1, cnt_1)
	end

	-- 성물 젬을 아이템 리스트에 넣는다
	for i = 1, 3 do
		local cgem = GET_CHILD_RECURSIVELY(frame, 'cgem_slot'..i)
		if cgem:IsVisible() == 1 then
			local guid = cgem:GetUserValue('ITEM_GUID')
			if guid == 'None' or guid == nil then
				return
			end
			session.AddItemID(guid, 1)
		end
	end
 
	local msg = ScpArgMsg('REALLY_DO_RELIC_GEM_COMPOSE')
	local yesScp = '_RELIC_GEM_MANAGER_COMPOSE_EXEC()'
	local msgbox = ui.MsgBox(msg, yesScp, 'None')
	SET_MODAL_MSGBOX(msgbox)
end

function _RELIC_GEM_MANAGER_COMPOSE_EXEC()
	local frame = ui.GetFrame('relic_gem_manager')
	if frame == nil then return end

	local do_compose = GET_CHILD_RECURSIVELY(frame, 'do_compose')

	local result_list = session.GetItemIDList()
	local arg_list = NewStringList()

	item.DialogTransaction('RELIC_GEM_COMPOSE', result_list, '', arg_list)
end

function END_RELIC_GEM_COMPOSE(frame, msg, arg_str, arg_num)
	local do_compose = GET_CHILD_RECURSIVELY(frame, 'do_compose')
	if do_compose ~= nil then
		do_compose:ShowWindow(0)
	end

	if arg_str == 'SUCCESS' then
		local gem_class = GetClassByType('Item', arg_num)
		if gem_class ~= nil then
			frame:SetUserValue('C_RESULT_CLASSID', arg_num)
			ReserveScript('_RUN_RELIC_GEM_COMPOSE_SUCCESS()', 0)
		end
	elseif arg_str == 'FAILED' then
		ReserveScript('_RUN_RELIC_GEM_COMPOSE_FAILED()', 0)
	end

	CLEAR_RELIC_GEM_MANAGER_COMPOSE_SLOT()
	
end

function _RUN_RELIC_GEM_COMPOSE_SUCCESS()
	local frame = ui.GetFrame('relic_gem_manager')
	if frame:IsVisible() == 0 then return end

	local send_ok_compose = GET_CHILD_RECURSIVELY(frame, 'send_ok_compose')
	send_ok_compose:ShowWindow(1)

	local cresult_gb = GET_CHILD_RECURSIVELY(frame, 'cresult_gb')
	cresult_gb:ShowWindow(1)

	local c_success_effect_bg = GET_CHILD_RECURSIVELY(frame, 'c_success_effect_bg')
	local c_success_skin = GET_CHILD_RECURSIVELY(frame, 'c_success_skin')
	local c_text_success = GET_CHILD_RECURSIVELY(frame, 'c_text_success')
	c_success_effect_bg:ShowWindow(1)
	c_success_skin:ShowWindow(1)
	c_text_success:ShowWindow(1)

	local c_fail_effect_bg = GET_CHILD_RECURSIVELY(frame, 'c_fail_effect_bg')
	local c_fail_skin = GET_CHILD_RECURSIVELY(frame, 'c_fail_skin')
	local c_text_fail = GET_CHILD_RECURSIVELY(frame, 'c_text_fail')
	c_fail_effect_bg:ShowWindow(0)
	c_fail_skin:ShowWindow(0)
	c_text_fail:ShowWindow(0)

	local c_result_item_img = GET_CHILD_RECURSIVELY(frame, 'c_result_item_img')
	c_result_item_img:ShowWindow(1)
	
	local gem_guid = frame:GetUserIValue('C_RESULT_CLASSID')
	local gem_class = GetClassByType('Item', gem_guid)
	c_result_item_img:SetImage(TryGetProp(gem_class, 'Icon', 'None'))

	local cgem_name = GET_CHILD_RECURSIVELY(frame, 'cgem_name')
	cgem_name:ShowWindow(1)

	local gem_name = GET_RELIC_GEM_NAME_WITH_FONT(gem_class)
	cgem_name:SetTextByKey('value', gem_name)
				
	RELIC_GEM_COMPOSE_SUCCESS_EFFECT(frame)
end

function RELIC_GEM_COMPOSE_SUCCESS_EFFECT(frame)
	local frame = ui.GetFrame('relic_gem_manager')
	local SUCCESS_EFFECT_NAME = frame:GetUserConfig('DO_SUCCESS_EFFECT')
	local SUCCESS_EFFECT_SCALE = tonumber(frame:GetUserConfig('SUCCESS_EFFECT_SCALE'))
	local SUCCESS_EFFECT_DURATION = tonumber(frame:GetUserConfig('SUCCESS_EFFECT_DURATION'))
	local c_success_effect_bg = GET_CHILD_RECURSIVELY(frame, 'c_success_effect_bg')
	if c_success_effect_bg == nil then return end

	c_success_effect_bg:PlayUIEffect(SUCCESS_EFFECT_NAME, SUCCESS_EFFECT_SCALE, 'DO_SUCCESS_EFFECT')

	ReserveScript('_RELIG_GEM_COMPOSE_SUCCESS_EFFECT()', SUCCESS_EFFECT_DURATION)
end

function  _RELIG_GEM_COMPOSE_SUCCESS_EFFECT()
	local frame = ui.GetFrame('relic_gem_manager')
	if frame:IsVisible() == 0 then return end

	local c_success_effect_bg = GET_CHILD_RECURSIVELY(frame, 'c_success_effect_bg')
	if c_success_effect_bg == nil then return end

	c_success_effect_bg:StopUIEffect('DO_SUCCESS_EFFECT', true, 0.5)

	ui.SetHoldUI(false)
end

function _RUN_RELIC_GEM_COMPOSE_FAILED()
	local frame = ui.GetFrame('relic_gem_manager')
	if frame:IsVisible() == 0 then return end

	local send_ok_compose = GET_CHILD_RECURSIVELY(frame, 'send_ok_compose')
	if send_ok_compose ~= nil then
		send_ok_compose:ShowWindow(1)
	end

	local cresult_gb = GET_CHILD_RECURSIVELY(frame, 'cresult_gb')
	cresult_gb:ShowWindow(1)
	local c_success_effect_bg = GET_CHILD_RECURSIVELY(frame, 'c_success_effect_bg')
	local c_success_skin = GET_CHILD_RECURSIVELY(frame, 'c_success_skin')
	local c_text_success = GET_CHILD_RECURSIVELY(frame, 'c_text_success')
	c_success_effect_bg:ShowWindow(0)
	c_success_skin:ShowWindow(0)
	c_text_success:ShowWindow(0)

	local c_fail_skin = GET_CHILD_RECURSIVELY(frame, 'c_fail_skin')
	local c_text_fail = GET_CHILD_RECURSIVELY(frame, 'c_text_fail')
	c_fail_skin:ShowWindow(1)
	c_text_fail:ShowWindow(1)

	RELIC_GEM_COMPOSE_FAIL_EFFECT(frame)
end


function RELIC_GEM_COMPOSE_FAIL_EFFECT(frame)
	local frame = ui.GetFrame('relic_gem_manager')
	local FAIL_EFFECT_NAME = frame:GetUserConfig('DO_FAIL_EFFECT')
	local FAIL_EFFECT_SCALE = tonumber(frame:GetUserConfig('FAIL_EFFECT_SCALE'))
	local FAIL_EFFECT_DURATION = tonumber(frame:GetUserConfig('FAIL_EFFECT_DURATION'))
	local c_fail_effect_bg = GET_CHILD_RECURSIVELY(frame, 'c_fail_effect_bg')
	if c_fail_effect_bg == nil then return end

	local c_result_item_img = GET_CHILD_RECURSIVELY(frame, 'c_result_item_img')
	c_result_item_img:ShowWindow(0)

	local cgem_name = GET_CHILD_RECURSIVELY(frame, 'cgem_name')
	cgem_name:ShowWindow(0)

	c_fail_effect_bg:PlayUIEffect(FAIL_EFFECT_NAME, FAIL_EFFECT_SCALE, 'DO_FAIL_EFFECT')

	ReserveScript('_RELIC_GEM_COMPOSE_FAIL_EFFECT()', FAIL_EFFECT_DURATION)
end

function  _RELIC_GEM_COMPOSE_FAIL_EFFECT()
	local frame = ui.GetFrame('relic_gem_manager')
	if frame:IsVisible() == 0 then return end

	local c_fail_effect_bg = GET_CHILD_RECURSIVELY(frame, 'c_fail_effect_bg')
	if c_fail_effect_bg == nil then return end

	c_fail_effect_bg:StopUIEffect('DO_FAIL_EFFECT', true, 0.5)
	ui.SetHoldUI(false)
end

function CLEAR_RELIC_GEM_MANAGER_COMPOSE_SLOT()
	local frame = ui.GetFrame('relic_gem_manager')
	if frame == nil then return end

	for i = 1, 3 do
		local cgem_slot = GET_CHILD_RECURSIVELY(frame, 'cgem_slot'..i)
		cgem_slot:ClearIcon()
		cgem_slot:SetUserValue('ITEM_GUID', 'None')
	end
	
	UPDATE_RELIC_GEM_MANAGER_COMPOSE(frame)
end


function RELIC_GEM_MANAGER_COMPOSE_GEM_DROP(frame, icon, argStr, argNum)
	if ui.CheckHoldedUI() == true then return end

	frame = ui.GetFrame('relic_gem_manager')
	if frame == nil then return end

	local tab = GET_CHILD_RECURSIVELY(frame, 'type_Tab')
	if tab == nil then return end

	local index = tab:GetSelectItemIndex()
	if index ~= 1 then return end

	local lift_icon = ui.GetLiftIcon()
	local icon_info = lift_icon:GetInfo()
	local guid = icon_info:GetIESID()

	if GET_RELIC_IS_BELONGING(guid) == 1 then
		ui.SysMsg(ClMsg('InvalidGem'))
		return
	end

	local from_frame = lift_icon:GetTopParentFrame()
    if from_frame:GetName() == 'inventory' then
        local icon_info = lift_icon:GetInfo()
        local guid = icon_info:GetIESID()
        local inv_item = session.GetInvItemByGuid(guid)
		if inv_item == nil then return end
		
		local item_obj = GetIES(inv_item:GetObject())
		if item_obj == nil then return end

		RELIC_GEM_MANAGER_COMPOSE_REG_MAT(frame, inv_item, item_obj)
	end
end

-- 합성 끝

-- 이전
local function _TRANSFER_FROM_CTRL_UPDATE(frame, inv_item, item_obj)
	local from_name = GET_CHILD_RECURSIVELY(frame, 'from_name')
	local from_slot = GET_CHILD_RECURSIVELY(frame, 'from_slot')
	local from_lv = GET_CHILD_RECURSIVELY(frame, 'from_lv')
	
	if inv_item ~= nil and item_obj ~= nil then
		local name_str = GET_RELIC_GEM_NAME_WITH_FONT(item_obj)
		from_name:SetTextByKey('value', name_str)
		from_name:ShowWindow(1)
		from_lv:SetTextByKey('value', TryGetProp(item_obj, 'GemLevel', 1))
		from_lv:ShowWindow(1)
	
		SET_SLOT_ITEM(from_slot, inv_item)
	
		frame:SetUserValue('FROM_GUID', inv_item:GetIESID())
	else
		from_slot:ClearIcon()
		from_name:ShowWindow(0)
		from_lv:ShowWindow(0)
		frame:SetUserValue('FROM_GUID', 'None')
	end
end

local function _TRANSFER_TO_CTRL_UPDATE(frame, inv_item, item_obj)
	local to_input_plz = GET_CHILD_RECURSIVELY(frame, 'to_input_plz')
	local to_name = GET_CHILD_RECURSIVELY(frame, 'to_name')
	local to_slot = GET_CHILD_RECURSIVELY(frame, 'to_slot')
	local to_lv = GET_CHILD_RECURSIVELY(frame, 'to_lv')

	if inv_item ~= nil and item_obj ~= nil then
		local name_str = GET_RELIC_GEM_NAME_WITH_FONT(item_obj)
		to_name:SetTextByKey('value', name_str)
		to_input_plz:ShowWindow(0)
		to_name:ShowWindow(1)
		to_lv:SetTextByKey('value', TryGetProp(item_obj, 'GemLevel', 1))
		to_lv:ShowWindow(1)
	
		SET_SLOT_ITEM(to_slot, inv_item)
	
		frame:SetUserValue('TO_GUID', inv_item:GetIESID())
	else
		to_slot:ClearIcon()
		to_name:ShowWindow(0)
		to_lv:ShowWindow(0)
		to_input_plz:ShowWindow(1)
		frame:SetUserValue('TO_GUID', 'None')
	end
end

function UPDATE_RELIC_GEM_MANAGER_TRANSFER(frame)
	local tab = GET_CHILD_RECURSIVELY(frame, 'type_Tab')
	if tab == nil then return end

	local tab_index = tab:GetSelectItemIndex()
	if tab_index ~= 2 then return end

	local do_transfer = GET_CHILD_RECURSIVELY(frame, 'do_transfer')
	if frame:GetUserValue('FROM_GUID') ~= 'None' and frame:GetUserValue('TO_GUID') ~= 'None' then
		do_transfer:SetEnable(1)
	else
		do_transfer:SetEnable(0)
	end
end

function RELIC_GEM_MANAGER_TRANSFER_INV_RBTN(item_obj, slot)
	local frame = ui.GetFrame('relic_gem_manager')
	if frame == nil then return end

	local icon = slot:GetIcon()
    local icon_info = icon:GetInfo()
	local guid = icon_info:GetIESID()
	
    local inv_item = session.GetInvItemByGuid(guid)
	if inv_item == nil then return end

	if GET_RELIC_IS_BELONGING(guid) == 1 then
		ui.SysMsg(ClMsg('InvalidGem'))
		return
	end

	local item_obj = GetIES(inv_item:GetObject())
	if item_obj == nil then return end
	
	local tab = GET_CHILD_RECURSIVELY(frame, 'type_Tab')
	if tab == nil then return end

	local index = tab:GetSelectItemIndex()
	if index ~= 2 then return end

	RELIC_GEM_MANAGER_TRANSFER_REG_ITEM(frame, inv_item, item_obj)
end

function RELIC_GEM_MANAGER_TRANSFER_INV_ITEM_DROP(frame, icon, argStr, argNum)
	if ui.CheckHoldedUI() == true then return end

	frame = ui.GetFrame('relic_gem_manager')
	if frame == nil then return end

	local tab = GET_CHILD_RECURSIVELY(frame, 'type_Tab')
	if tab == nil then return end

	local index = tab:GetSelectItemIndex()
	if index ~= 2 then return end

	local lift_icon = ui.GetLiftIcon()
	local icon_info = lift_icon:GetInfo()
	local guid = icon_info:GetIESID()

	if GET_RELIC_IS_BELONGING(guid) == 1 then
		ui.SysMsg(ClMsg('InvalidGem'))
		return
	end

	local from_frame = lift_icon:GetTopParentFrame()
    if from_frame:GetName() == 'inventory' then
        local icon_info = lift_icon:GetInfo()
        local guid = icon_info:GetIESID()
        local inv_item = session.GetInvItemByGuid(guid)
		if inv_item == nil then return end
		
		local item_obj = GetIES(inv_item:GetObject())
		if item_obj == nil then return end
        
		RELIC_GEM_MANAGER_TRANSFER_REG_ITEM(frame, inv_item, item_obj)
	end
end

function RELIC_GEM_MANAGER_TRANSFER_SLOT_ITEM_REMOVE(frame, icon)
	if ui.CheckHoldedUI() == true then return end

	frame = ui.GetFrame('relic_gem_manager')
	if frame == nil then return end

	if frame:GetUserValue('TO_GUID') ~= 'None' then
		_TRANSFER_TO_CTRL_UPDATE(frame)
	else
		CLEAR_RELIC_GEM_MANAGER_TRANSFER()
	end

	UPDATE_RELIC_GEM_MANAGER_TRANSFER(frame)
end

function RELIC_GEM_MANAGER_TRANSFER_REG_ITEM(frame, inv_item, item_obj)
	if TryGetProp(item_obj, 'GroupName', 'None') ~= 'Gem_Relic' then
		-- 성물 젬이 아닙니다
		ui.SysMsg(ClMsg('NOT_A_RELIC_GEM'))
		return
	end

	local tinput_gb = GET_CHILD_RECURSIVELY(frame, 'tinput_gb')
	local tslot_gb = GET_CHILD_RECURSIVELY(frame, 'tslot_gb')
	if tinput_gb:IsVisible() == 1 and frame:GetUserValue('FROM_GUID') == 'None' then
		local from_lv = TryGetProp(item_obj, 'GemLevel', 0)
		if from_lv <= 1 then
			ui.SysMsg(ClMsg('TransferAbleOnlyOverLv2RelicGem'))
			return
		end

		tinput_gb:ShowWindow(0)
		tslot_gb:ShowWindow(1)
		_TRANSFER_FROM_CTRL_UPDATE(frame, inv_item, item_obj)
	else
		local to_guid = inv_item:GetIESID()
		local from_guid = frame:GetUserValue('FROM_GUID')
		if to_guid == from_guid then
			ui.SysMsg(ClMsg('AlreadRegSameItem'))
			return
		end

		local to_lv = TryGetProp(item_obj, 'GemLevel', 0)
		if to_lv ~= 1 then
			ui.SysMsg(ClMsg('TransferAbleOnlyLv1RelicGem'))
			return
		end

		_TRANSFER_TO_CTRL_UPDATE(frame, inv_item, item_obj)
	end

	UPDATE_RELIC_GEM_MANAGER_TRANSFER(frame)
end

function CLEAR_RELIC_GEM_MANAGER_TRANSFER()
	local frame = ui.GetFrame('relic_gem_manager')
	if frame == nil then return end

	local send_ok_transfer = GET_CHILD_RECURSIVELY(frame, 'send_ok_transfer')
	send_ok_transfer:ShowWindow(0)

	local do_transfer = GET_CHILD_RECURSIVELY(frame, 'do_transfer')
	do_transfer:ShowWindow(1)

	local tslot_gb = GET_CHILD_RECURSIVELY(frame, 'tslot_gb')
	tslot_gb:ShowWindow(0)

	local tinput_gb = GET_CHILD_RECURSIVELY(frame, 'tinput_gb')
	tinput_gb:ShowWindow(1)

	_TRANSFER_FROM_CTRL_UPDATE(frame)
	_TRANSFER_TO_CTRL_UPDATE(frame)

	UPDATE_RELIC_GEM_MANAGER_TRANSFER(frame)
end

function RELIC_GEM_MANAGER_TRANSFER_OPEN(frame)
	local transferBg = GET_CHILD_RECURSIVELY(frame, 'transferBg')
	if transferBg:IsVisible() ~= 1 then return end

	UPDATE_RELIC_GEM_MANAGER_TRANSFER(frame)
end

function RELIC_GEM_MANAGER_TRANSFER_EXEC(parent)
	local frame = parent:GetTopParentFrame()
	if frame == nil then return end

	session.ResetItemList()

	local from_guid = frame:GetUserValue('FROM_GUID')
	local to_guid = frame:GetUserValue('TO_GUID')
	if from_guid == 'None' or to_guid == 'None' then return end

	local from_gem = session.GetInvItemByGuid(from_guid)
	local to_gem = session.GetInvItemByGuid(to_guid)
	if from_gem == nil or to_gem == nil then return end

	local from_obj = GetIES(from_gem:GetObject())
	local to_obj = GetIES(to_gem:GetObject())
	if from_obj == nil or to_obj == nil then return end

	if from_gem.isLockState == true or to_gem.isLockState == true then
		ui.SysMsg(ClMsg('MaterialItemIsLock'))
		return
	end

	session.AddItemID(from_guid, 1)
	session.AddItemID(to_guid, 1)

	local from_name = GET_RELIC_GEM_NAME_WITH_FONT(from_obj)
	local to_name = GET_RELIC_GEM_NAME_WITH_FONT(to_obj)
	local msg = ScpArgMsg('REALLY_DO_RELIC_GEM_TRANSFER', 'NAME1', from_name, 'NAME2', to_name, 'NAME3', from_name)
	local yesScp = '_RELIC_GEM_MANAGER_TRANSFER_EXEC()'
	local msgbox = ui.MsgBox(msg, yesScp, 'None')
	SET_MODAL_MSGBOX(msgbox)
end

function _RELIC_GEM_MANAGER_TRANSFER_EXEC()
	local frame = ui.GetFrame('relic_gem_manager')
	if frame == nil then return end

	local do_transfer = GET_CHILD_RECURSIVELY(frame, 'do_transfer')

	local result_list = session.GetItemIDList()
	local arg_list = NewStringList()

	item.DialogTransaction('RELIC_GEM_TRANSFER', result_list, '', arg_list)
end

function SUCCESS_RELIC_GEM_TRANSFER(frame)
	local do_transfer = GET_CHILD_RECURSIVELY(frame, 'do_transfer')
	if do_transfer ~= nil then
		do_transfer:ShowWindow(0)
	end
	
	local send_ok_transfer = GET_CHILD_RECURSIVELY(frame, 'send_ok_transfer')
	if send_ok_transfer ~= nil then
		send_ok_transfer:ShowWindow(1)
	end

	local to_guid = frame:GetUserValue('TO_GUID')
	local to_item = session.GetInvItemByGuid(to_guid)
	local to_obj = GetIES(to_item:GetObject())

	_TRANSFER_TO_CTRL_UPDATE(frame, to_item, to_obj)
	_TRANSFER_FROM_CTRL_UPDATE(frame)
end
-- 이전 끝

-- 분해
local function _DECOMPOSE_PRICE_UPDATE(frame, price)
	local total_price = frame:GetUserValue('DECOMPOSE_PRICE')
	if total_price == nil or total_price == 'None' then
		total_price = '0'
	end
	price = tonumber(DivForBigNumberInt64(price, '100000'))
	total_price = tonumber(DivForBigNumberInt64(total_price, '100000'))

	local d_price_gauge = GET_CHILD_RECURSIVELY(frame, 'd_price_gauge')
	d_price_gauge:SetPoint(price, total_price)

	local do_decompose = GET_CHILD_RECURSIVELY(frame, 'do_decompose')
	if total_price > 0 and price >= total_price then
		do_decompose:SetEnable(1)
	else
		do_decompose:SetEnable(0)
	end
end

function CHECKBOX_DECOMPOSE(parent,ctrl)
	local frame = parent:GetTopParentFrame();
	frame:SetUserValue("IS_SELECTED_ALL","FALSE")
	UPDATE_RELIC_GEM_MANAGER_DECOMPOSE(frame)
	RELIC_GEM_DECOMPOSE_SET_COUNT(frame)
end

function RELIC_GEM_DECOMPOSE_MAKE_FILTER_LIST()
	local filter_list_type = {};
	local filter_list_grade = {};
	
	local frame = ui.GetFrame("relic_gem_manager") 
	local type_filterGroup  = GET_CHILD_RECURSIVELY(frame,"filter_by_type_bg")
	local grade_filterGroup = GET_CHILD_RECURSIVELY(frame,"filter_by_grade_bg")
	
	if GET_CHILD(type_filterGroup, "cb_cyan"):IsChecked()== 1 then table.insert(filter_list_type,"Gem_Relic_Cyan") end
	if GET_CHILD(type_filterGroup, "cb_magenta"):IsChecked()== 1 then table.insert(filter_list_type,"Gem_Relic_Magenta") end
	if GET_CHILD(type_filterGroup, "cb_black"):IsChecked()== 1 then table.insert(filter_list_type,"Gem_Relic_Black") end

	if GET_CHILD(grade_filterGroup, "cb_legend"):IsChecked()== 1 then table.insert(filter_list_grade,5) end
	if GET_CHILD(grade_filterGroup, "cb_goddess"):IsChecked()== 1 then table.insert(filter_list_grade,6) end
	
	return filter_list_type,filter_list_grade
end

function RELIC_GEM_DECOMPOSE_APPLY_FILTER(targetObj,arglist,keyword)
	for i=1, #arglist do
		if TryGetProp(targetObj,keyword,"None")==arglist[i] then return true end
	end
	return false
end

function UPDATE_RELIC_GEM_MANAGER_DECOMPOSE(frame)
	local tab = GET_CHILD_RECURSIVELY(frame, 'type_Tab')
	if tab == nil then return end

	local tab_index = tab:GetSelectItemIndex()
	if tab_index ~= 3 then return end

	local gem_slotset = GET_CHILD_RECURSIVELY(frame, 'slotlist', 'ui::CSlotSet')
	gem_slotset:ClearIconAll()

	local filter_list_type,filter_list_grade = RELIC_GEM_DECOMPOSE_MAKE_FILTER_LIST()

	local invItemList = session.GetInvItemList()
	FOR_EACH_INVENTORY(invItemList, function(invItemList, invItem, slotSet, materialItemList)
		local obj = GetIES(invItem:GetObject())
		local group_name = TryGetProp(obj, 'GroupName', 'None')
		local gem_level = TryGetProp(obj, 'GemLevel', 0)
		local DecomposeAble = TryGetProp(obj, 'DecomposeAble', "NO")
		local item_guid  = invItem:GetIESID()
		if GET_RELIC_IS_BELONGING(item_guid) == 1 then
			return
		else
			if group_name == 'Gem_Relic' and gem_level == 1 and DecomposeAble == 'YES' then
				local isHitfilter1  = true;
				local isHitfilter2  = true;
				if #filter_list_type>0 then
					isHitfilter1 = RELIC_GEM_DECOMPOSE_APPLY_FILTER(obj,filter_list_type,"GemType")
				end
				if #filter_list_grade>0 then
					isHitfilter2 = RELIC_GEM_DECOMPOSE_APPLY_FILTER(obj,filter_list_grade,"ItemGrade")
				end
				if isHitfilter1 == true and isHitfilter2 == true then
					local slotindex = imcSlot:GetEmptySlotIndex(slotSet)
					local slot = slotSet:GetSlotByIndex(slotindex)
					slot:SetUserValue('GEM_GUID', invItem:GetIESID())
					slot:SetMaxSelectCount(invItem.count)
					local icon = CreateIcon(slot)
					icon:Set(obj.Icon, 'Item', invItem.type, slotindex, invItem:GetIESID(), invItem.count)
					local class = GetClassByType('Item', invItem.type)
					SET_SLOT_ITEM_TEXT_USE_INVCOUNT(slot, invItem, obj, invItem.count)
					ICON_SET_INVENTORY_TOOLTIP(icon, invItem, 'poisonpot', class)
				end
			end
		end
	end, false, gem_slotset, materialItemList)

	-- 할인 쿠폰
	local dis_slotSet = GET_CHILD_RECURSIVELY(frame, 'dslotlist_discount', 'ui::CSlotSet')
	dis_slotSet:ClearIconAll()
	FOR_EACH_INVENTORY(invItemList, function(invItemList, invItem, slotSet, materialItemList)
		local coupon_table = SCR_RELIC_REINFORCE_COUPON()
		local obj = GetIES(invItem:GetObject())
		for i, v in pairs(coupon_table) do
			if v == TryGetProp(obj, "ClassName", "None") then
				local slotindex = imcSlot:GetEmptySlotIndex(slotSet)
				local slot = slotSet:GetSlotByIndex(slotindex)
				slot:SetUserValue('COUPON_GUID', invItem:GetIESID())
				slot:SetMaxSelectCount(invItem.count)
				slot:SetSelectCountPerCtrlClick(1000)
				slot:SetUserValue('DISCOUNT_POINT', TryGetProp(obj, 'NumberArg1', 0))
				local icon = CreateIcon(slot)
				icon:Set(obj.Icon, 'Item', invItem.type, slotindex, invItem:GetIESID(), invItem.count)
				local class = GetClassByType('Item', invItem.type)
				SET_SLOT_ITEM_TEXT_USE_INVCOUNT(slot, invItem, obj, invItem.count)
				ICON_SET_INVENTORY_TOOLTIP(icon, invItem, 'poisonpot', class)
			end
		end

	end, false, dis_slotSet, materialItemList)
end

function RELIC_GEM_DECOMPOSE_SET_COUNT(frame)
	local slotSet = GET_CHILD_RECURSIVELY(frame, 'slotlist',"ui::CSlotSet")
	
	local d_slotSet = GET_CHILD_RECURSIVELY(frame, 'dprice_info')
	local d_slotlist = GET_CHILD_RECURSIVELY(frame, 'dslotlist_discount')

	local decompose_cnt = slotSet:GetSelectedSlotCount()
	
	if decompose_cnt <= 0 then
		d_slotSet:ShowWindow(0)
		d_slotlist:ShowWindow(0)
	else
		d_slotSet:ShowWindow(1)
		d_slotlist:ShowWindow(1)
	end

	local cost_per = shared_item_relic.get_gem_decompose_silver()
	local total_price = MultForBigNumberInt64(decompose_cnt, cost_per)
	frame:SetUserValue('DECOMPOSE_PRICE', total_price)
	_DECOMPOSE_PRICE_UPDATE(frame, '0')
end


function RELIC_GEM_DECOMPOSE_SELECT_ALL(parent,ctrl)
	local frame = parent:GetTopParentFrame()
	local userval = frame:GetUserValue("IS_SELECTED_ALL")
	
	ui.EnableSlotMultiSelect(1)
	local slotset = GET_CHILD_RECURSIVELY(parent,"slotlist","ui::CSlotSet")
	local slot_cnt = slotset:GetSlotCount();
	if userval=="TRUE" then
		for i = 0, slot_cnt-1 do 
			local slot = slotset:GetSlotByIndex(i)
			
			slot:Select(0)
		end	
		frame:SetUserValue("IS_SELECTED_ALL","FALSE")
	elseif userval=="FALSE" then
		for i = 0, slot_cnt-1 do 
			local slot = slotset:GetSlotByIndex(i)
			local icon = slot:GetIcon()
			if icon ~=nil then 	slot:Select(1) end
		end	
		frame:SetUserValue("IS_SELECTED_ALL","TRUE")
	else
	end

	slotset:MakeSelectionList()
	RELIC_GEM_DECOMPOSE_SET_COUNT(frame)
end

function SCP_LBTDOWN_RELIC_GEM_DECOMPOSE(frame, ctrl)
	ui.EnableSlotMultiSelect(1)
	RELIC_GEM_DECOMPOSE_SET_COUNT(frame:GetTopParentFrame())
end

function CLEAR_RELIC_GEM_MANAGER_DECOMPOSE()
	local frame = ui.GetFrame('relic_gem_manager')
	if frame == nil then return end

	local send_ok_decompose = GET_CHILD_RECURSIVELY(frame, 'send_ok_decompose')
	send_ok_decompose:ShowWindow(0)

	local do_decompose = GET_CHILD_RECURSIVELY(frame, 'do_decompose')
	do_decompose:ShowWindow(1)

	UPDATE_RELIC_GEM_MANAGER_DECOMPOSE(frame)
end

function RELIC_GEM_MANAGER_DECOMPOSE_OPEN(frame)
	frame:SetUserValue("IS_SELECTED_ALL","FALSE")
	local decomposeBg = GET_CHILD_RECURSIVELY(frame, 'decomposeBg')
	if decomposeBg:IsVisible() ~= 1 then return end

	UPDATE_RELIC_GEM_MANAGER_DECOMPOSE(frame)
	RELIC_GEM_DECOMPOSE_SET_COUNT(frame)
end

function RELIC_GEM_MANAGER_DECOMPOSE_EXEC(parent)
	local frame = parent:GetTopParentFrame()
	if frame == nil then return end

	local slotSet = GET_CHILD_RECURSIVELY(frame, 'slotlist', 'ui::CSlotSet')
	local decompose_cnt = slotSet:GetSelectedSlotCount()
	local cost_per = shared_item_relic.get_gem_decompose_silver()
	local total_price = MultForBigNumberInt64(decompose_cnt, cost_per)
	local discount = RELIC_GEM_MANAGER_DECOMPOSE_TOTAL_DISCOUNT_PRICE()
	total_price = SumForBigNumberInt64(total_price, tonumber(discount) * -1)
	local my_money = GET_TOTAL_MONEY_STR()
    if IsGreaterThanForBigNumber(total_price, my_money) == 1 then
        ui.SysMsg(ClMsg('NotEnoughMoney'))
        return
	end

	local inv_misc = session.GetInvItemByName('misc_Relic_Gem')
	if inv_misc ~= nil and inv_misc.count > 900000 then
		ui.SysMsg(ClMsg('misc_Relic_GemFullEnough'))		
		return
	end

	session.ResetItemList()
	
	for i = 0, decompose_cnt - 1 do
		local slot = slotSet:GetSelectedSlot(i)
		local gem_guid = slot:GetUserValue('GEM_GUID')
		session.AddItemID(gem_guid, 1)
	end

	local dslotlist_discount = GET_CHILD_RECURSIVELY(frame, 'dslotlist_discount')
	local discount_cnt = dslotlist_discount:GetSelectedSlotCount()
	if discount_cnt > 0 then
		for i = 0, discount_cnt - 1 do
			local _slot = dslotlist_discount:GetSelectedSlot(i)
			local _guid = _slot:GetUserValue('COUPON_GUID')
			local _count = _slot:GetSelectCount()
			session.AddItemID(_guid, _count)
		end
	end

	local msg = ClMsg('REALLY_DO_RELIC_GEM_DECOMPOSE')
	local yesScp = '_RELIC_GEM_MANAGER_DECOMPOSE_EXEC()'
	local msgbox = ui.MsgBox(msg, yesScp, 'None')
	SET_MODAL_MSGBOX(msgbox)
end

function _RELIC_GEM_MANAGER_DECOMPOSE_EXEC()
	local frame = ui.GetFrame('relic_gem_manager')
	if frame == nil then return end
	
	local result_list = session.GetItemIDList()
	local arg_list = NewStringList()

	item.DialogTransaction('RELIC_GEM_DECOMPOSE', result_list, '', arg_list)
end

function SUCCESS_RELIC_GEM_DECOMPOSE(frame)
	local do_decompose = GET_CHILD_RECURSIVELY(frame, 'do_decompose')
	if do_decompose ~= nil then
		do_decompose:ShowWindow(1)
	end
	frame:SetUserValue("IS_SELECTED_ALL","FALSE")
	UPDATE_RELIC_GEM_MANAGER_DECOMPOSE(frame)
	RELIC_GEM_DECOMPOSE_SET_COUNT(frame)
end

function RELIC_GEM_MANAGER_DECOMPOSE_TOTAL_DISCOUNT_PRICE()
	local frame = ui.GetFrame('relic_gem_manager')
    if frame == nil then
        return
    end

    local slotSet = GET_CHILD_RECURSIVELY(frame, 'dslotlist_discount')
	local totalDiscount = 0

	for i = 0, slotSet:GetSlotCount() - 1 do
		local slot = slotSet:GetSlotByIndex(i)
		local point = tonumber(slot:GetUserValue("DISCOUNT_POINT"))
		if point == nil then
			break
		end

		totalDiscount = SumForBigNumberInt64(totalDiscount, MultForBigNumberInt64(slot:GetSelectCount(), point))
    end
    
    return totalDiscount
end

function RELIC_GEM_MANAGER_DECOMPOSE_DISCOUNT_CLICK(slotSet, slot)
    local frame = ui.GetFrame('relic_gem_manager')
    if frame == nil then
        return
	end

	local totalPrice = frame:GetUserValue('DECOMPOSE_PRICE')
	local discountPrice = RELIC_GEM_MANAGER_DECOMPOSE_TOTAL_DISCOUNT_PRICE()
	local adjustValue = SumForBigNumberInt64(totalPrice, tostring(tonumber(discountPrice) * -1))

	if IsGreaterThanForBigNumber(0, adjustValue) == 1 then
		local point = tonumber(slot:GetUserValue("DISCOUNT_POINT"))
		if point == nil or point == 0 then
			return
		end

		local nowCount = slot:GetSelectCount()
		local adjustCount = math.floor(tonumber(DivForBigNumberInt64(adjustValue, point)))
		adjustCount = math.max(nowCount + adjustCount, 0)
		slot:SetSelectCount(adjustCount)
	end

	-- 선택한게 없으면 포커스 풀어주기
	if slot:GetSelectCount() == 0 then
		slot:Select(0)
	end

	ui.EnableSlotMultiSelect(1)
	
	local totalPrice = frame:GetUserValue('DECOMPOSE_PRICE')
	local discountPrice = RELIC_GEM_MANAGER_DECOMPOSE_TOTAL_DISCOUNT_PRICE()
	_DECOMPOSE_PRICE_UPDATE(frame, discountPrice)
end
