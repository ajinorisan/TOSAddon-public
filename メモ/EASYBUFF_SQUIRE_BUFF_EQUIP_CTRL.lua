function EASYBUFF_SQUIRE_BUFF_EQUIP_CTRL()
    local frame = ui.GetFrame("itembuffopen") -- frameを関数内で定義

    local checkall = GET_CHILD_RECURSIVELY(frame, 'checkall')
    checkall:SetCheck(0)

    local ctrlGbox = GET_CHILD_RECURSIVELY(frame, 'ctrlGbox')
    ctrlGbox:RemoveAllChild()

    local index = 0
    for i = 1, #enable_slot_list do
        local slot_name = enable_slot_list[i]
        local inv_item = session.GetEquipItemBySpot(item.GetEquipSpotNum(slot_name))
        if inv_item ~= nil then
            local item_obj = GetIES(inv_item:GetObject())
            if SQUIRE_BUFF_ENABLE_ITEM_CHECK(frame, inv_item, item_obj) == true then
                local ctrl_height = ui.GetControlSetAttribute('itembuff_ctrlset', 'height')
                local ctrlset = ctrlGbox:CreateOrGetControlSet('itembuff_ctrlset', 'ITEMBUFF_CTRL_' .. slot_name, 2, ctrl_height * index)

                if ctrlset ~= nil then
                    local slot = GET_CHILD(ctrlset, 'slot')
                    SET_SLOT_ITEM(slot, inv_item)
                    slot:SetUserValue('ITEM_GUID', inv_item:GetIESID())
                    slot:SetUserValue('ITEM_SLOT', slot_name)
    
                    local item_name = GET_CHILD(ctrlset, 'item_name')
                    item_name:SetTextByKey('name', dic.getTranslatedStr(TryGetProp(item_obj, 'Name', 'NONE')))
    
                    local checkbox = GET_CHILD(ctrlset, 'checkbox')
                    checkbox:SetCheck(1) -- すべてのチェックボックスにチェックを設定

                    local time = GET_CHILD_RECURSIVELY(ctrlset, 'time')
                    time:ShowWindow(0)
                    local timestr = GET_CHILD_RECURSIVELY(ctrlset, 'timestr')
                    timestr:ShowWindow(0)
    
                    index = index + 1
                end
            end
        end
    end

    SQUIRE_BUFF_COST_UPDATE(frame)
end
