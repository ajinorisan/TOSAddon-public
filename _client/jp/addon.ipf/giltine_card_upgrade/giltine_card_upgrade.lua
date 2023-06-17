-- giltine_card_upgrade.lua

function OPEN_GILTINE_CARD_UPGRADE()
    ui.OpenFrame('giltine_card_upgrade')
end

function GILTINE_CARD_UPGRADE_OPEN()
    GILTINE_CARD_UPGRADE_INIT()

    -- 인벤토리 처리
    INVENTORY_SET_CUSTOM_RBTNDOWN("GILTINE_CARD_UPGRADE_SELECT_ITEM")
end

function GILTINE_CARD_UPGRADE_CLOSE()
    GILTINE_CARD_UPGRADE_CLEAR()

    -- 인벤토리 처리
    INVENTORY_SET_CUSTOM_RBTNDOWN("None")
end

function GILTINE_CARD_UPGRADE_INIT()
    GILTINE_CARD_UPGRADE_INIT_SLOT()
    GILTINE_CARD_UPGRADE_UPDATE()
end

function GILTINE_CARD_UPGRADE_CLEAR()
    local frame = ui.GetFrame('giltine_card_upgrade')

    local borutaSlot = GET_CHILD_RECURSIVELY(frame, "material_slot_boruta")
    local legendSlot = GET_CHILD_RECURSIVELY(frame, "material_slot_legend")

    GILTINE_CARD_UPGRADE_SLOT_CLEAR(frame, borutaSlot)
    GILTINE_CARD_UPGRADE_SLOT_CLEAR(frame, legendSlot)
end

function GILTINE_CARD_UPGRADE_SLOT_CLEAR(parent, slot)
    slot:ClearIcon()
    slot:SetUserValue("GUID", "None")
    GILTINE_CARD_UPGRADE_UPDATE()
end

function GILTINE_CARD_UPGRADE_UPDATE()
    local frame = ui.GetFrame('giltine_card_upgrade')

    local borutaSlot = GET_CHILD_RECURSIVELY(frame, "material_slot_boruta")
    local legendSlot = GET_CHILD_RECURSIVELY(frame, "material_slot_legend")
    local materialSlot = GET_CHILD_RECURSIVELY(frame, "material_item_slot")

    local needItem = session.GetInvItemByName("misc_Guilty_LegCard")
    local needItemCount = 0
    
    if needItem ~= nil then
        needItemCount = needItem.count
    end

    if needItemCount < 10 then
		materialSlot:SetText(string.format("{@st66d}{#e50002}{s20}%s/%s{/}", needItemCount, 10))
    else
		materialSlot:SetText(string.format("{@st66d}{s20}%s/%s{/}", needItemCount, 10))
    end

    local cond1 = needItemCount >= 10
    local cond2 = borutaSlot:GetUserValue("GUID") ~= nil and borutaSlot:GetUserValue("GUID") ~= "None"
    local cond3 = legendSlot:GetUserValue("GUID") ~= nil and legendSlot:GetUserValue("GUID") ~= "None"

    local upgradeBtn = GET_CHILD_RECURSIVELY(frame, "upgrade_btn")
    local centerSlot = GET_CHILD_RECURSIVELY(frame, "target_card_slot")

    if cond1 and cond2 and cond3 then
        upgradeBtn:SetEnable(1)
        centerSlot:SetEnable(1)
    else
        upgradeBtn:SetEnable(0)
        centerSlot:SetEnable(0)
    end
end

function GILTINE_CARD_UPGRADE_INIT_SLOT()
    local frame = ui.GetFrame('giltine_card_upgrade')

    -- 길티네 카드 세팅
    local centerSlot = GET_CHILD_RECURSIVELY(frame, "target_card_slot")
    local item = GetClass("Item", "Legendcard_Guilty")

    SET_SLOT_IMG(centerSlot, item.Icon)
    SET_ITEM_TOOLTIP_BY_TYPE(centerSlot:GetIcon(), item.ClassID)

    centerSlot:GetIcon():SetTooltipOverlap(1)

    -- 편린 세팅
    local materialSlot = GET_CHILD_RECURSIVELY(frame, "material_item_slot")
    local materialItem = GetClass("Item", "misc_Guilty_LegCard")

    SET_SLOT_IMG(materialSlot, materialItem.Icon)
    SET_ITEM_TOOLTIP_BY_TYPE(materialSlot:GetIcon(), materialItem.ClassID)

    materialSlot:GetIcon():SetTooltipOverlap(1)
end

function GILTINE_CARD_UPGRADE_SELECT_ITEM(itemObj, slot, itemGUID)
	local invItem = GET_ITEM_BY_GUID(itemGUID)
	if invItem == nil then
		return
    end
    
    -- 잠겨있는가?
    if invItem.isLockState == true then
		ui.SysMsg(ClMsg("MaterialItemIsLock"))
		return
    end

    -- 카드인가?
	if itemObj.GroupName ~= 'Card' then
		return
	end

    -- 레전드 카드인가?
    if itemObj.CardGroupName ~= 'LEG' then
        return
    end
    
    -- 레벨이 10레벨인가?
    if GET_ITEM_LEVEL(itemObj) < 10 then
        return
    end

    -- 등록
    GILTINE_CARD_UPGRADE_SET_SLOT(itemGUID)

    -- 업데이트
    GILTINE_CARD_UPGRADE_UPDATE()
end

function GILTINE_CARD_UPGRADE_SET_SLOT(itemGUID)
    local frame = ui.GetFrame('giltine_card_upgrade')
    if frame == nil then
        return
    end

    local invItem = GET_ITEM_BY_GUID(itemGUID)
    if invItem == nil then
        return
    end

    local itemObj = GetIES(invItem:GetObject())
    if itemObj == nil then
        return
    end

    -- 보루타 카드 / 그 외로 슬롯 구분
    local slot = nil

    if itemObj.ClassName == "Legend_card_boruta" then
        slot =  GET_CHILD_RECURSIVELY(frame, "material_slot_boruta")
    else
        slot =  GET_CHILD_RECURSIVELY(frame, "material_slot_legend")
    end

    if slot == nil then
        return
    end

    -- 슬롯 등록
    SET_SLOT_IMG(slot, itemObj.Icon)
    SET_ITEM_TOOLTIP_BY_OBJ(slot:GetIcon(), invItem)

    slot:GetIcon():SetTooltipOverlap(1)
    slot:SetUserValue("GUID", itemGUID)
end

function GILTINE_CARD_UPGRADE_EXEC()
    local frame = ui.GetFrame('giltine_card_upgrade')
    if frame == nil then
        return
    end

    local borutaSlot = GET_CHILD_RECURSIVELY(frame, "material_slot_boruta")
    local legendSlot = GET_CHILD_RECURSIVELY(frame, "material_slot_legend")

    local borutaGUID = borutaSlot:GetUserValue("GUID")
    local legendGUID = legendSlot:GetUserValue("GUID")

    if borutaGUID == nil or borutaGUID == "None" then
        return
    end

    if legendGUID == nil or legendGUID == "None" then
        return
    end

    local borutaItem = GET_ITEM_BY_GUID(borutaGUID)
    local legendItem = GET_ITEM_BY_GUID(legendGUID)

    if borutaItem == nil then
        return
    end

    if legendItem == nil then
        return
    end

    local borutaObj = GetIES(borutaItem:GetObject())
    local legendObj = GetIES(legendItem:GetObject())

    ui.MsgBox(ScpArgMsg("ReallyWantToMakeGiltineCard{Material1}{Material2}", "Material1", borutaObj.Name, "Material2", legendObj.Name), "GILTINE_CARD_UPGRADE_REQUEST", "None")
end

function GILTINE_CARD_UPGRADE_REQUEST()
    local frame = ui.GetFrame('giltine_card_upgrade')
    if frame == nil then
        return
    end

    local borutaSlot = GET_CHILD_RECURSIVELY(frame, "material_slot_boruta")
    local legendSlot = GET_CHILD_RECURSIVELY(frame, "material_slot_legend")

    local borutaGUID = borutaSlot:GetUserValue("GUID")
    local legendGUID = legendSlot:GetUserValue("GUID")

    if borutaGUID == nil or borutaGUID == "None" then
        return
    end

    if legendGUID == nil or legendGUID == "None" then
        return
    end

    session.ResetItemList()

    session.AddItemID(borutaGUID, 1)
    session.AddItemID(legendGUID, 1)

    item.DialogTransaction("GILTINE_CARD_UPGRADE", session.GetItemIDList())

    ui.CloseFrame('giltine_card_upgrade')
end