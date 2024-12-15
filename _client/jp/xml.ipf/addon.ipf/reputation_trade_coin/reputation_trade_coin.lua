function REPUTATION_TRADE_COIN_ON_INIT(addon, frame)
    addon:RegisterMsg('REQUEST_REPUTATION_TRADE_COINT', 'OPEN_REPUTATION_TRADE_COIN')
end

function REPUTATION_TRADE_COIN_GET_TARGET_ITEM_LIST()
    local result = {}
    local tgt_list = {"reputation_relief_ep13_all",
             "reputation_relief_ep13_f_siauliai_1",
             "reputation_relief_ep13_f_siauliai_2",
             "reputation_relief_ep13_f_siauliai_3",
             "reputation_relief_ep13_f_siauliai_4",
             "reputation_relief_ep13_f_siauliai_5",
             "reputation_relief_ep13_mini"}
    for k, v in pairs(tgt_list) do
        result[v] = 10
    end

    return result
end


function ON_REQUEST_REPUTATION_TRADE_COIN_UPDATE()
    OPEN_REPUTATION_TRADE_COIN()
end

-- OPEN/CLOSE
function OPEN_REPUTATION_TRADE_COIN()
    ui.OpenFrame("reputation_trade_coin")
end

function CLOSE_REPUTATION_TRADE_COIN()
    
end

-- INIT
function REPUTATION_TRADE_COIN_INIT()
    REPUTATION_TRADE_COIN_INIT_SLOT()
    REPUTATION_TRADE_COIN_INIT_POINT()
end

function REPUTATION_TRADE_COIN_INIT_SLOT()
    local frame = ui.GetFrame('reputation_trade_coin')
    if frame == nil then
        return
    end

    local slotSet = GET_CHILD_RECURSIVELY(frame, "slotlist", "ui::CSlotSet")
	slotSet:ClearIconAll()

	local invItemList = session.GetInvItemList()
    local materialItemList = REPUTATION_TRADE_COIN_GET_TARGET_ITEM_LIST()
    
    FOR_EACH_INVENTORY(invItemList, 
    function(invItemList, invItem, slotSet, materialItemList)
		local obj = GetIES(invItem:GetObject())
        local itemName = TryGetProp(obj, "ClassName", "None")
        -- 대상 아이템이면
        if materialItemList[itemName] ~= nil and materialItemList[itemName] > 0 then
            -- 슬롯 공간 없을시 확장
            local slotindex = imcSlot:GetEmptySlotIndex(slotSet)
			if slotindex == 0 and imcSlot:GetFilledSlotCount(slotSet) == slotSet:GetSlotCount() then
				slotSet:ExpandRow()
				slotindex = imcSlot:GetEmptySlotIndex(slotSet)
            end
            
            -- 슬롯 정보
            local slot = slotSet:GetSlotByIndex(slotindex)
			slot:SetMaxSelectCount(invItem.count)
            slot:SetUserValue("ITEM_POINT", materialItemList[itemName])
            -- 아이콘
			local icon = CreateIcon(slot)
            icon:Set(obj.Icon, 'Item', invItem.type, slotindex, invItem:GetIESID(), invItem.count)
            
            -- 툴팁
			local class = GetClassByType('Item', invItem.type)
			SET_SLOT_ITEM_TEXT_USE_INVCOUNT(slot, invItem, obj, invItem.count)
			ICON_SET_INVENTORY_TOOLTIP(icon, invItem, "poisonpot", class)
        end
    end, 
    false, slotSet,materialItemList)

	local cnt = slotSet:GetRow() - tonumber(frame:GetUserConfig("DEFAULT_ROW"))
	for i = 1, cnt do
        slotSet:AutoCheckDecreaseRow()
	end
end

function REPUTATION_TRADE_COIN_INIT_POINT()
    local frame = ui.GetFrame('reputation_trade_coin')
    if frame == nil then
        return
    end

	local aObj = GetMyAccountObj()

	local addPoint = GET_CHILD_RECURSIVELY(frame, "addPoint")
    local addValue = GET_TOTAL_ADD_POINT(frame)

    addPoint:SetTextByKey("value", addValue)
end

-- BUTTONs
function REPUTATION_TRADE_COIN_ITEM_CLICK(frame, ctrl)
    local frame = ui.GetFrame('reputation_trade_coin')
    if frame == nil then
        return
    end

    ctrl:SetSelectCount(ctrl:GetSelectCount())

    -- 선택한게 없으면 포커스 풀어주기
    if ctrl:GetSelectCount() == 0 then
        ctrl:Select(0)
    end

	ui.EnableSlotMultiSelect(1)
	REPUTATION_TRADE_COIN_INIT_POINT()
end

function REPUTATION_TRADE_COIN_REQUEST()
    local frame = ui.GetFrame('reputation_trade_coin')
    if frame == nil then
        return
    end
    
    session.ResetItemList()

    local slotSet = GET_CHILD_RECURSIVELY(frame, "slotlist", "ui::CSlotSet")
    for i = 0, slotSet:GetSelectedSlotCount() -1 do
		local slot = slotSet:GetSelectedSlot(i)
		local Icon = slot:GetIcon()
		local iconInfo = Icon:GetInfo()
		
		local  cnt = slot:GetSelectCount()
		session.AddItemID(iconInfo:GetIESID(), cnt)
    end
    
	local resultlist = session.GetItemIDList()
    item.DialogTransaction("REPUTATION_TRADE_COIN", resultlist)
    ui.CloseFrame("reputation_trade_coin")
end