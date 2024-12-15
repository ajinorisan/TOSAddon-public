-- slogutis_card_upgrade.lua
function OPEN_SLOGUTIS_CARD_UPGRADE()
    ui.OpenFrame('slogutis_card_upgrade');
end

function SLOGUTIS_CARD_UPGRADE_OPEN()
    SLOGUTIS_CARD_UPGRADE_INIT();
    INVENTORY_SET_CUSTOM_RBTNDOWN("SLOGUTIS_CARD_UPGRADE_SELECT_ITEM"); -- 인벤토리 처리
end

function SLOGUTIS_CARD_UPGRADE_CLOSE()
    SLOGUTIS_CARD_UPGRADE_CLEAR();
    INVENTORY_SET_CUSTOM_RBTNDOWN("None"); -- 인벤토리 처리
end

function SLOGUTIS_CARD_UPGRADE_INIT()
    SLOGUTIS_CARD_UPGRADE_INIT_SLOT();
    SLOGUTIS_CARD_UPGRADE_UPDATE();
end

function SLOGUTIS_CARD_UPGRADE_CLEAR()
    local frame = ui.GetFrame('slogutis_card_upgrade');
    if frame ~= nil then
        local slot_giltine = GET_CHILD_RECURSIVELY(frame, "material_slot_giltine");
        local slot_legend = GET_CHILD_RECURSIVELY(frame, "material_slot_legend");
        SLOGUTIS_CARD_UPGRADE_SLOT_CLEAR(frame, slot_giltine);
        SLOGUTIS_CARD_UPGRADE_SLOT_CLEAR(frame, slot_legend);
    end
end

function SLOGUTIS_CARD_UPGRADE_SLOT_CLEAR(parent, slot)
    if slot ~= nil then
        slot:ClearIcon();
        slot:SetUserValue("GUID", "None");
    end
    SLOGUTIS_CARD_UPGRADE_UPDATE();
end

function SLOGUTIS_CARD_UPGRADE_UPDATE()
    local frame = ui.GetFrame('slogutis_card_upgrade');
    if frame ~= nil then
        local slot_giltine = GET_CHILD_RECURSIVELY(frame, "material_slot_giltine");
        local slot_legend = GET_CHILD_RECURSIVELY(frame, "material_slot_legend");
        local slot_material = GET_CHILD_RECURSIVELY(frame, "material_item_slot");
        local need_itme_count = 0;
        local need_item = session.GetInvItemByName("misc_circle_of_chaos");
        if need_item ~= nil then
            need_itme_count = need_item.count;
        end
    
        if need_itme_count < 20 then
            slot_material:SetText(string.format("{@st66d}{#e50002}{s20}%s/%s{/}", need_itme_count, 20));
        else
            slot_material:SetText(string.format("{@st66d}{s20}%s/%s{/}", need_itme_count, 20));
        end
    
        local is_count = need_itme_count >= 20;
        local is_enable_giltine = slot_giltine:GetUserValue("GUID") ~= nil and slot_giltine:GetUserValue("GUID") ~= "None";
        local is_enable_legend = slot_legend:GetUserValue("GUID") ~= nil and slot_legend:GetUserValue("GUID") ~= "None";
    
        local btn_upgrade = GET_CHILD_RECURSIVELY(frame, "upgrade_btn");
        local slot_center = GET_CHILD_RECURSIVELY(frame, "target_card_slot");
        if is_count and is_enable_giltine and is_enable_legend then
            btn_upgrade:SetEnable(1);
            slot_center:SetEnable(1);
        else
            btn_upgrade:SetEnable(0);
            slot_center:SetEnable(0);
        end
    end
end

function SLOGUTIS_CARD_UPGRADE_INIT_SLOT()
    local frame = ui.GetFrame('slogutis_card_upgrade')
    if frame ~= nil then
        local slot_center = GET_CHILD_RECURSIVELY(frame, "target_card_slot")
        local item = GetClass("Item", "Legend_card_Slogutis");
        if item ~= nil then
            -- 카드 setting
            local class_id = TryGetProp(item, "ClassID", 0);
            local icon = TryGetProp(item, "Icon", "None");
            SET_SLOT_IMG(slot_center, icon);
            SET_ITEM_TOOLTIP_BY_TYPE(slot_center:GetIcon(), class_id)
            slot_center:GetIcon():SetTooltipOverlap(1);
            -- 고리 setting
            local slot_material = GET_CHILD_RECURSIVELY(frame, "material_item_slot");
            local item_material = GetClass("Item", "misc_circle_of_chaos");
            if item_material ~= nil then
                local class_id = TryGetProp(item_material, "ClassID", 0);
                local icon = TryGetProp(item_material, "Icon", "None");
                SET_SLOT_IMG(slot_material, icon);
                SET_ITEM_TOOLTIP_BY_TYPE(slot_material:GetIcon(), class_id);
                slot_material:GetIcon():SetTooltipOverlap(1);
            end
        end
    end
end

function SLOGUTIS_CARD_UPGRADE_SELECT_ITEM(obj, slot, guid)
    local inv_item = GET_ITEM_BY_GUID(guid)
	if inv_item == nil then
		return;
    end
    -- 잠겨있는가?
    if inv_item.isLockState == true then
		ui.SysMsg(ClMsg("MaterialItemIsLock"));
		return;
    end
    -- 카드인가?
	if obj.GroupName ~= 'Card' then
		return;
	end
    -- 가디스 카드인가?
    if obj.CardGroupName ~= 'LEG' then
        return;
    end
    -- 레벨이 10레벨인가?
    if GET_ITEM_LEVEL(obj) < 10 then
        return;
    end
    -- 등록
    SLOGUTIS_CARD_UPGRADE_SET_SLOT(guid);
    -- 업데이트
    SLOGUTIS_CARD_UPGRADE_UPDATE();
end

function SLOGUTIS_CARD_UPGRADE_SET_SLOT(guid)
    local frame = ui.GetFrame('slogutis_card_upgrade')
    if frame == nil then
        return;
    end
    local inv_item = GET_ITEM_BY_GUID(guid);
    if inv_item == nil then
        return;
    end
    local obj = GetIES(inv_item:GetObject());
    if obj == nil then
        return;
    end
    -- 길티네 카드 / 그 외로 슬롯 구분
    local slot = nil;
    if obj.ClassName == "Legendcard_Guilty" then
        slot = GET_CHILD_RECURSIVELY(frame, "material_slot_giltine");
        if slot ~= nil then
            local slot_guid = slot:GetUserValue("GUID");
            if slot_guid ~= "None" and guid ~= slot_guid then
                slot = GET_CHILD_RECURSIVELY(frame, "material_slot_legend");
            end
        end
    else
        slot = GET_CHILD_RECURSIVELY(frame, "material_slot_legend");
    end
    if slot == nil then
        return;
    end
    -- 슬롯 등록
    SET_SLOT_IMG(slot, obj.Icon);
    SET_ITEM_TOOLTIP_BY_OBJ(slot:GetIcon(), inv_item);
    slot:GetIcon():SetTooltipOverlap(1);
    slot:SetUserValue("GUID", guid);
end

function SLOGUTIS_CARD_UPGRADE_EXEC()
    local frame = ui.GetFrame('slogutis_card_upgrade');
    if frame == nil then
        return;
    end

    local slot_giltine = GET_CHILD_RECURSIVELY(frame, "material_slot_giltine");
    local slot_legend = GET_CHILD_RECURSIVELY(frame, "material_slot_legend");

    local giltine_guid = slot_giltine:GetUserValue("GUID");
    if giltine_guid == nil or giltine_guid == "None" then return; end

    local legend_guid = slot_legend:GetUserValue("GUID");
    if legend_guid == nil or legend_guid == "None" then return; end

    local giltine_item = GET_ITEM_BY_GUID(giltine_guid);
    if giltine_item == nil then return; end

    local legend_item = GET_ITEM_BY_GUID(legend_guid);
    if legend_item == nil then return; end

    local giltine_obj = GetIES(giltine_item:GetObject());
    local legend_obj = GetIES(legend_item:GetObject());
    if giltine_obj ~= nil and legend_obj ~= nil then
        ui.MsgBox(ScpArgMsg("ReallyWantToMakeSlogutisCard{Material1}{Material2}", "Material1", giltine_obj.Name, "Material2", legend_obj.Name), "SLOGUTIS_CARD_UPGRADE_REQUEST", "None");
    end
end

function SLOGUTIS_CARD_UPGRADE_REQUEST()
    local frame = ui.GetFrame('slogutis_card_upgrade');
    if frame == nil then return; end

    local slot_giltine = GET_CHILD_RECURSIVELY(frame, "material_slot_giltine");
    local slot_legend = GET_CHILD_RECURSIVELY(frame, "material_slot_legend");

    local giltine_guid = slot_giltine:GetUserValue("GUID");
    local legend_guid = slot_legend:GetUserValue("GUID");
    if giltine_guid == nil or giltine_guid == "None" then return; end
    if legend_guid == nil or legend_guid == "None" then return; end

    session.ResetItemList();
    session.AddItemID(giltine_guid, 1);
    session.AddItemID(legend_guid, 1);
    item.DialogTransaction("SLOGUTIS_CARD_UPGRADE", session.GetItemIDList());
    ui.CloseFrame('slogutis_card_upgrade');
end