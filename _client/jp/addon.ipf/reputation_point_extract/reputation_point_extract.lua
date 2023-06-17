function REPUTATION_POINT_EXTRACT_ON_INIT(addon, frame)
    addon:RegisterMsg('REQUEST_REPUTATION_POINT_EXTRACT_UPDATE', 'ON_REQUEST_REPUTATION_POINT_EXTRACT_UPDATE')
end

-- Local Functions
function REPUTATION_POINT_EXTRACT_SET_REPUTATION(reputation)
    local frame = ui.GetFrame('reputation_point_extract')
    if frame == nil then
        return
    end

    frame:SetUserValue("REPUTATION", reputation)
end

function REPUTATION_POINT_EXTRACT_GET_REPUTATION()
    local frame = ui.GetFrame('reputation_point_extract')
    if frame == nil then
        return "None"
    end

    return frame:GetUserValue("REPUTATION")
end

function REPUTATION_POINT_EXTRACT_GET_TYPE()
    local frame = ui.GetFrame('reputation_point_extract')
    if frame == nil then
        return "None"
    end

    local tab = AUTO_CAST(frame:GetChild("material_tab"))
    local select = tab:GetSelectItemName()

    if select == "tab_material" then
        return "Common"
    else
        return "Relief"
    end
end

function REPUTATION_POINT_EXTRACT_GET_POINT_LIMIT()
    local maxLimit = GET_REPUTATION_MAX() - TryGetProp(GetMyAccountObj(), REPUTATION_POINT_EXTRACT_GET_REPUTATION(), 0)
    local weeklyLimit = GET_REPUTATION_POINT_EXTRACT_LIMIT() - TryGetProp(GetMyAccountObj(), "REPUTATION_POINT_EXTRACT_LIMIT", 0)

    if REPUTATION_POINT_EXTRACT_GET_TYPE() == "Common" then
        return math.min(maxLimit, weeklyLimit)
    else
        return maxLimit
    end
end

function REPUTATION_POINT_EXTRACT_GET_TARGET_ITEM_LIST()
    local type = REPUTATION_POINT_EXTRACT_GET_TYPE()

    local reputationName = REPUTATION_POINT_EXTRACT_GET_REPUTATION()
    local reputationClass = GetClass("reputation", reputationName)
    local reputationGroup = reputationClass.Group

    local result = {}
    local list, cnt = GetClassList("reputation_point")
    for i = 0, cnt-1 do
        local cls = GetClassByIndexFromList(list, i)

        result[cls.ItemName] = GET_REPUTATION_EXTRACT_POINT(cls, reputationName, type == "Common")
    end

    return result
end

-- AddOnMsg Functions
function REPUTATION_POINT_EXTRACT_OPEN(reputation)
    local frame = ui.GetFrame('reputation_point_extract')
    if frame == nil then
        return
    end

    REPUTATION_POINT_EXTRACT_SET_REPUTATION(reputation)
    ui.OpenFrame('reputation_point_extract')
end

function ON_REQUEST_REPUTATION_POINT_EXTRACT_UPDATE()
    OPEN_REPUTATION_POINT_EXTRACT()
end

-- OPEN/CLOSE
function OPEN_REPUTATION_POINT_EXTRACT()
    REPUTATION_POINT_EXTRACT_INIT()
end

function CLOSE_REPUTATION_POINT_EXTRACT()
    
end

-- INIT
function REPUTATION_POINT_EXTRACT_INIT()
    REPUTATION_POINT_EXTRACT_INIT_SLOT()
    REPUTATION_POINT_EXTRACT_INIT_POINT()
end

function REPUTATION_POINT_EXTRACT_INIT_SLOT()
    local frame = ui.GetFrame('reputation_point_extract')
    if frame == nil then
        return
    end

    local slotSet = GET_CHILD_RECURSIVELY(frame, "slotlist", "ui::CSlotSet")
	slotSet:ClearIconAll()

	local invItemList = session.GetInvItemList()
    local materialItemList = REPUTATION_POINT_EXTRACT_GET_TARGET_ITEM_LIST()
    
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

function REPUTATION_POINT_EXTRACT_INIT_POINT()
    local frame = ui.GetFrame('reputation_point_extract')
    if frame == nil then
        return
    end

	local aObj = GetMyAccountObj()
	local pointName = REPUTATION_POINT_EXTRACT_GET_REPUTATION()
	local totalPoint = GET_CHILD_RECURSIVELY(frame, "totalPoint")
	local totalValue = TryGetProp(aObj, pointName)
    totalPoint:SetTextByKey("value", totalValue)
    totalPoint:SetTextByKey("max", GET_REPUTATION_MAX())

	local addPoint = GET_CHILD_RECURSIVELY(frame, "addPoint")
    local addValue = GET_TOTAL_ADD_POINT(frame)
    
    if REPUTATION_POINT_EXTRACT_GET_TYPE() == "Common" then
        addPoint:SetTextByKey("value", addValue.." ("..ClMsg("ReputationPointExtractWeeklyLimit").."{#FF0000}"..REPUTATION_POINT_EXTRACT_GET_POINT_LIMIT().."{/})")
    else
        addPoint:SetTextByKey("value", addValue)
    end

	local afterPoint = GET_CHILD_RECURSIVELY(frame, "afterPoint")
    afterPoint:SetTextByKey("value", totalValue + addValue)
    afterPoint:SetTextByKey("max", GET_REPUTATION_MAX())

	SET_MATERIAL_POINT_INFO_LIST(frame)
end

-- BUTTONs
function REPUTATION_POINT_EXTRACT_ITEM_CLICK(frame, ctrl)
    local frame = ui.GetFrame('reputation_point_extract')
    if frame == nil then
        return
    end

    local limitValue = REPUTATION_POINT_EXTRACT_GET_POINT_LIMIT()
    local selectValue = GET_TOTAL_ADD_POINT(frame)
    local adjustValue = selectValue - limitValue

    if adjustValue > 0 then
        ctrl:SetSelectCount(ctrl:GetSelectCount() - math.floor(adjustValue / ctrl:GetUserValue("ITEM_POINT")))

        -- 선택한게 없으면 포커스 풀어주기
        if ctrl:GetSelectCount() == 0 then
            ctrl:Select(0)
        end
    end

	ui.EnableSlotMultiSelect(1)
	REPUTATION_POINT_EXTRACT_INIT_POINT()
end

-- EXEC
function REPUTATION_POINT_EXTRACT_EXEC()
    local frame = ui.GetFrame('reputation_point_extract')
    if frame == nil then
        return
    end

    local limitValue = REPUTATION_POINT_EXTRACT_GET_POINT_LIMIT()
    local selectValue = GET_TOTAL_ADD_POINT(frame)
    local adjustValue = selectValue - limitValue

    if adjustValue > 0 then
        ui.MsgBox(ScpArgMsg("DoReputationPointExtractWithLimit{LIMIT}{POINT}", "LIMIT", adjustValue, "POINT", selectValue - adjustValue), "REPUTATION_POINT_EXTRACT_REQUEST", "None")
    else
        ui.MsgBox(ScpArgMsg("DoReputationPointExtract{POINT}", "POINT", selectValue), "REPUTATION_POINT_EXTRACT_REQUEST", "None")
    end
end

function REPUTATION_POINT_EXTRACT_REQUEST()
    local frame = ui.GetFrame('reputation_point_extract')
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
    local argStrList = NewStringList()
    
    -- reputation 전달
    argStrList:Add(REPUTATION_POINT_EXTRACT_GET_REPUTATION())

    -- Common 전달
    if REPUTATION_POINT_EXTRACT_GET_TYPE() == "Common" then
        argStrList:Add("YES")
    else
        argStrList:Add("NO")
    end
    
	item.DialogTransaction("REPUTATION_POINT_EXTRACT", resultlist, "", argStrList)
end