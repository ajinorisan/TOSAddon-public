
function RELIC_EXP_REFINE_ON_INIT(addon, frame)
	addon:RegisterMsg('RELIC_EXP_REFINE_EXECUTE', 'ON_RELIC_EXP_REFINE_EXECUTE')
end

function REQ_RELIC_EXP_REFINE_OPEN()
	local frame = ui.GetFrame('relic_exp_refine')
	frame:ShowWindow(1)
end

function RELIC_EXP_REFINE_OPEN(frame)
	CLEAR_EXP_REFINE_EXECUTE(frame)
end

function RELIC_EXP_REFINE_CLOSE(frame)

end

function CLEAR_EXP_REFINE_EXECUTE()
	local frame = ui.GetFrame('relic_exp_refine')
	if frame == nil then return end

	local clearBtn = GET_CHILD_RECURSIVELY(frame, 'clearBtn')
	clearBtn:ShowWindow(0)

	local refineBtn = GET_CHILD_RECURSIVELY(frame, 'refineBtn')
	refineBtn:ShowWindow(1)

	UPDATE_RELIC_EXP_REFINE_UI(frame)
	RELIC_EXP_REFINE_SET_COUNT(frame)
end

function RELIC_EXP_REFINE_SET_COUNT(frame, slot)
	local requireCount = GET_CHILD_RECURSIVELY(frame, 'requireCount')
	local resultCount = GET_CHILD_RECURSIVELY(frame, 'resultCount')
	local refine_count = GET_TOTAL_REFINE_COUNT(frame)
	local max_refine_count = frame:GetUserIValue('MAX_REFINE_COUNT')
	if slot ~= nil and refine_count > max_refine_count then
		local refine_per = slot:GetUserIValue('REFINE_PER')
		local cur_count = slot:GetSelectCount()
		slot:SetSelectCount(cur_count - ((refine_count - max_refine_count) * refine_per))
		slot:SetUserValue('PREV_COUNT', slot:GetSelectCount())
		refine_count = max_refine_count
	end

	requireCount:SetTextByKey('value', refine_count * 10)
	resultCount:SetTextByKey('value', refine_count)
	
	local refineBtn = GET_CHILD_RECURSIVELY(frame, 'refineBtn')
	local price_gauge = GET_CHILD_RECURSIVELY(frame, 'price_gauge')
	if refine_count > 0 then
		local totalPrice = tonumber(RELIC_EXP_REFINE_TOTAL_PRICE()) / 100000
		local discountPrice = tonumber(RELIC_EXP_REFINE_TOTAL_DISCOUNT_PRICE()) / 100000
		price_gauge:SetPoint(discountPrice, totalPrice)
		price_gauge:ShowWindow(1)
		if discountPrice >= totalPrice then
			refineBtn:SetEnable(1)
		else
			refineBtn:SetEnable(0)
		end
	else
		price_gauge:ShowWindow(0)
		refineBtn:SetEnable(0)
	end

	SET_MATERIAL_COUNT_INFO_LIST(frame)
end

function RELIC_EXP_REFINE_TOTAL_DISCOUNT_PRICE()
    local frame = ui.GetFrame('relic_exp_refine')
    if frame == nil then
        return
    end

    local slotSet = GET_CHILD_RECURSIVELY(frame, "slotlist_discount")
    local totalDiscount = 0

	for i = 0, slotSet:GetSlotCount() - 1 do
		local slot = slotSet:GetSlotByIndex(i)
        local point = tonumber(slot:GetUserValue("DISCOUNT_POINT"))

		totalDiscount = SumForBigNumberInt64(totalDiscount, MultForBigNumberInt64(slot:GetSelectCount(), point))
    end
    
    return totalDiscount
end

function RELIC_EXP_REFINE_TOTAL_PRICE()
    local frame = ui.GetFrame('relic_exp_refine')
    if frame == nil then
        return
    end

    local refineCount = GET_TOTAL_REFINE_COUNT(frame)
    local costPerCount = shared_item_relic.get_require_money_for_refine()
    local totalPrice = MultForBigNumberInt64(refineCount, costPerCount)

    return totalPrice
end

function RELIC_EXP_REFINE_DISCOUNT_CLICK(slotSet, slot)
    local frame = ui.GetFrame('relic_exp_refine')
    if frame == nil then
        return
    end

    local totalPrice = RELIC_EXP_REFINE_TOTAL_PRICE()
    local discountPrice = RELIC_EXP_REFINE_TOTAL_DISCOUNT_PRICE()

    -- 할인가 계산
    local adjustValue = SumForBigNumberInt64(totalPrice, '-'..discountPrice)

    -- 할인가가 0보다 작을 경우
    if IsGreaterThanForBigNumber(0, adjustValue) == 1 then
        local point = tonumber(slot:GetUserValue("DISCOUNT_POINT"))
        if point == nil or point == 0 then
            return
        end

        local nowCount = slot:GetSelectCount()
        local adjustCount = math.floor(tonumber(DivForBigNumberInt64(adjustValue, point)))

        slot:SetSelectCount(slot:GetSelectCount() + adjustCount)

        -- 선택한게 없으면 포커스 풀어주기
        if slot:GetSelectCount() == 0 then
            slot:Select(0)
        end
    end

    ui.EnableSlotMultiSelect(1)
    RELIC_EXP_REFINE_SET_COUNT(frame)
end

function RELIC_EXP_REFINE_DISCOUNT_RELEASE()
    local frame = ui.GetFrame('relic_exp_refine')
    if frame == nil then
        return
    end

    local slotSet = GET_CHILD_RECURSIVELY(frame, 'slotlist_discount', 'ui::CSlotSet')
    for i = 0, slotSet:GetSlotCount() - 1 do
        local slot = slotSet:GetSlotByIndex(i)
        if slot ~= nil then
            slot:Select(0)
        end
	end
end

function GET_TOTAL_REFINE_COUNT(frame)
	local slotSet = GET_CHILD_RECURSIVELY(frame, 'slotlist', 'ui::CSlotSet')
	local count = 0
	for i = 0, slotSet:GetSlotCount() - 1 do
		local slot = slotSet:GetSlotByIndex(i)
		local refine_per = tonumber(slot:GetUserValue('REFINE_PER'))
		if refine_per == nil then
			break
		end
		count = count + math.floor(slot:GetSelectCount() / refine_per)
	end

	return count
end

function SET_MATERIAL_COUNT_INFO_LIST(frame)
	local OFFSET_Y = 10
	local HEIGHT = 65
	local slotSet = GET_CHILD_RECURSIVELY(frame, 'slotlist', 'ui::CSlotSet')
	local gbox = GET_CHILD_RECURSIVELY(frame, 'materialInfoGbox')
	gbox:RemoveAllChild()
	for i = 0, slotSet:GetSlotCount() - 1 do
		local slot = slotSet:GetSlotByIndex(i)
		local refine_per = tonumber(slot:GetUserValue('REFINE_PER'))
		if refine_per == nil then
			break
		end
		local cnt = slot:GetSelectCount()
		if cnt > 0 then
			local info = slot:GetIcon():GetInfo()
			local ctrlSet = gbox:CreateOrGetControlSet('item_point_price', 'PRICE' .. info.type.. i, 10, OFFSET_Y)
			local itemSlot = GET_CHILD(ctrlSet, 'itemSlot')
			local itemCount = GET_CHILD(itemSlot, 'itemCount')
			local icon = CreateIcon(itemSlot)
			icon:SetImage(info:GetImageName())
			local cntText = string.format('{#ffe400}{ds}{ol}{b}{s18}%d', cnt)
			itemCount:SetText(cntText)

			local itemPrice = GET_CHILD(ctrlSet, 'itemPrice')
			local text = string.format('{s18}{ol}{b} ▶{/} {@st204_green}%d{/}{/}{/}', math.floor(cnt / refine_per))
			itemPrice:SetText(text)
			OFFSET_Y = OFFSET_Y + HEIGHT
		end
	end
end

function UPDATE_RELIC_EXP_REFINE_UI(frame)
	local slotSet = GET_CHILD_RECURSIVELY(frame, 'slotlist', 'ui::CSlotSet')
    slotSet:ClearIconAll()
    
    local discountSet = GET_CHILD_RECURSIVELY(frame, 'slotlist_discount', 'ui::CSlotSet')
    discountSet:ClearIconAll()

	local item_count = 0
	local req_item = session.GetInvItemByName('Relic_exp_token')
	if req_item ~= nil then
		item_count = req_item.count
	end

	frame:SetUserValue('MAX_REFINE_COUNT', math.floor(item_count / 10))

	local invItemList = session.GetInvItemList()
    local materialItemList = shared_item_relic.get_refine_material_list()
    local discountItemList = SCR_RELIC_REINFORCE_COUPON()
	FOR_EACH_INVENTORY(invItemList, function(invItemList, invItem, slotSet, discountSet, materialItemList, discountItemList)
		local obj = GetIES(invItem:GetObject())
        local itemName = TryGetProp(obj, 'ClassName', 'None')
        
        -- 재료 아이템 목록 세팅
		if materialItemList[itemName] ~= nil then
			local slotindex = imcSlot:GetEmptySlotIndex(slotSet)
			if slotindex == 0 and imcSlot:GetFilledSlotCount(slotSet) == slotSet:GetSlotCount() then
				slotSet:ExpandRow()
				slotindex = imcSlot:GetEmptySlotIndex(slotSet)
			end
			
			local slot = slotSet:GetSlotByIndex(slotindex)
			local refine_point = materialItemList[itemName]
			local refine_per = 100 / refine_point
			local top_parent = slotSet:GetTopParentFrame()
			local max_refine_count = top_parent:GetUserIValue('MAX_REFINE_COUNT')
            local max_count = math.min(math.floor(invItem.count / refine_per) * refine_per, max_refine_count * refine_per)
            
			slot:SetMaxSelectCount(max_count)
			slot:SetUserValue('REFINE_PER', refine_per)
            slot:SetUserValue('PREV_COUNT', 0)
            
			local icon = CreateIcon(slot)
            icon:Set(obj.Icon, 'Item', invItem.type, slotindex, invItem:GetIESID(), invItem.count)
            
			local class = GetClassByType('Item', invItem.type)
			SET_SLOT_ITEM_TEXT_USE_INVCOUNT(slot, invItem, obj, invItem.count)
			ICON_SET_INVENTORY_TOOLTIP(icon, invItem, 'poisonpot', class)
        end
        
        -- 할인 아이템 목록 세팅
        if table.find(discountItemList, itemName) > 0 then
			local slotindex = imcSlot:GetEmptySlotIndex(discountSet)
			if slotindex == 0 and imcSlot:GetFilledSlotCount(discountSet) == discountSet:GetSlotCount() then
				return
			end
			
            local slot = discountSet:GetSlotByIndex(slotindex)
            slot:SetMaxSelectCount(invItem.count)
			slot:SetSelectCountPerCtrlClick(1000)
            slot:SetUserValue('DISCOUNT_POINT', obj.NumberArg1)

			local icon = CreateIcon(slot)
            icon:Set(obj.Icon, 'Item', invItem.type, slotindex, invItem:GetIESID(), invItem.count)
            
			local class = GetClassByType('Item', invItem.type)
			SET_SLOT_ITEM_TEXT_USE_INVCOUNT(slot, invItem, obj, invItem.count)
			ICON_SET_INVENTORY_TOOLTIP(icon, invItem, 'poisonpot', class)
        end

	end, false, slotSet, discountSet, materialItemList, discountItemList)

	local cnt = slotSet:GetRow() - tonumber(frame:GetUserConfig('DEFAULT_ROW'))
	for i = 1, cnt do
		local row_num = slotSet:GetRow()
		slotSet:AutoCheckDecreaseRow()
		if row_num == slotSet:GetRow() then
			break
		end
	end
end

function SCP_LBTDOWN_RELIC_EXP_REFINE(slotset, slot)
	ui.EnableSlotMultiSelect(1)
	local prev_count = slot:GetUserIValue('PREV_COUNT')
	local cur_count = slot:GetSelectCount()
	local refine_per = slot:GetUserIValue('REFINE_PER')
	slot:SetSelectCount(prev_count + ((cur_count - prev_count) * refine_per))
	slot:SetUserValue('PREV_COUNT', slot:GetSelectCount())
    local frame = slotset:GetTopParentFrame()
    RELIC_EXP_REFINE_DISCOUNT_RELEASE()
    RELIC_EXP_REFINE_SET_COUNT(frame, slot)
end

function SCP_RBTDOWN_RELIC_EXP_REFINE(slotset, slot)
	ui.EnableSlotMultiSelect(1)
	slot:SetSelectCount(0)
	slot:SetUserValue('PREV_COUNT', 0)
    local frame = slotset:GetTopParentFrame()
    RELIC_EXP_REFINE_DISCOUNT_RELEASE()
    RELIC_EXP_REFINE_SET_COUNT(frame)
end

function RELIC_EXP_REFINE_EXEC(frame)
	session.ResetItemList()

	local total_count = 0
	local slotSet = GET_CHILD_RECURSIVELY(frame, 'slotlist', 'ui::CSlotSet')
	if slotSet:GetSelectedSlotCount() < 1 then
		ui.MsgBox(ScpArgMsg('SelectSomeItemPlz'))
		return
    end
    
	for i = 0, slotSet:GetSelectedSlotCount() -1 do
		local slot = slotSet:GetSelectedSlot(i)
		local Icon = slot:GetIcon()
		local iconInfo = Icon:GetInfo()
		local cnt = slot:GetSelectCount()
		local refine_per = tonumber(slot:GetUserValue('REFINE_PER'))
		if refine_per == nil then
			break
		end
		total_count = total_count + math.floor(cnt / refine_per)
		session.AddItemID(iconInfo:GetIESID(), cnt)
    end

    local discountSet = GET_CHILD_RECURSIVELY(frame, 'slotlist_discount', 'ui::CSlotSet')
    
    for i = 0, discountSet:GetSelectedSlotCount() -1 do
		local slot = discountSet:GetSelectedSlot(i)
		local Icon = slot:GetIcon()
		local iconInfo = Icon:GetInfo()
		local cnt = slot:GetSelectCount()
		session.AddItemID(iconInfo:GetIESID(), cnt)
    end

    local totalPrice = RELIC_EXP_REFINE_TOTAL_PRICE()
    local discountPrice = RELIC_EXP_REFINE_TOTAL_DISCOUNT_PRICE()
    local discountedPrice = SumForBigNumberInt64(totalPrice, '-'..discountPrice)

	local myMoney = GET_TOTAL_MONEY_STR()
    if IsGreaterThanForBigNumber(discountedPrice, myMoney) == 1 then
        ui.SysMsg(ClMsg('NotEnoughMoney'))
        return
	end
	
	local msg = ScpArgMsg('REALLY_DO_RELIC_EXP_MAT_REFINE', 'SILVER', GET_COMMAED_STRING(discountedPrice), 'COUNT', total_count * 10, 'RESULT', total_count)
	local yesScp = '_RELIC_EXP_REFINE_EXEC()'
	local msgbox = ui.MsgBox(msg, yesScp, 'None')
	SET_MODAL_MSGBOX(msgbox)
end

function _RELIC_EXP_REFINE_EXEC(count)
	local frame = ui.GetFrame('relic_exp_refine')
	if frame == nil then return end

	local resultlist = session.GetItemIDList()
	item.DialogTransaction('RELIC_REFINE_MATERIAL', resultlist, '')
end

function ON_RELIC_EXP_REFINE_EXECUTE(frame, msg, argStr, argNum)
	local refineBtn = GET_CHILD_RECURSIVELY(frame, 'refineBtn')
	refineBtn:ShowWindow(0)

	local clearBtn = GET_CHILD_RECURSIVELY(frame, 'clearBtn')
	clearBtn:ShowWindow(1)
end