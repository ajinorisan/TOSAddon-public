function PHARMACY_UI_ON_INIT(addon, frame)
    addon:RegisterMsg('PHARMACY_DISPENSE_COMPLETE', 'PHARMACY_UI_COMPLETE_DISPENSE')
    addon:RegisterMsg('PHARMACY_DISPENSE_FAILED', 'PHARMACY_UI_FAILED_ACTION')
    addon:RegisterMsg('PHARMACY_NEUTRALIZE_COMPLETE', 'PHARMACY_UI_COMPLETE_NEUTRALIZE')
	addon:RegisterMsg('ON_UI_TUTORIAL_NEXT_STEP', 'PHARMACY_UI_TUTORIAL_CHECK')
end

local function get_slot_index(x, y, size)
    return x + size * y + 1
end

local function get_material_add_pos(mat_obj)
    local type = TryGetProp(mat_obj, 'StringArg2', 'None')
    local material_cls = GetClass('pharmacy_material_type', type)
    if material_cls == nil then
        return 0, 0
    end

    return TryGetProp(material_cls, 'X_POS', 0), TryGetProp(material_cls, 'Y_POS', 0)
end

function PHARMACY_UI_REMAIN_TIME_UPDATE(ctrl)	
    local elapsed_sec = imcTime.GetAppTime() - ctrl:GetUserIValue('STARTSEC')
    local start_sec = ctrl:GetUserIValue('REMAINSEC')
    start_sec = start_sec - elapsed_sec
    if 0 > start_sec then
        ctrl:SetTextByKey('value', '')
        ui.SysMsg(ClMsg('RecipeTimeExpired'))
        ui.CloseFrame('pharmacy_ui')
        return 0
	end
	
    local time_str = GET_TIME_TXT_NO_LANG(start_sec)
	ctrl:SetTextByKey('value', time_str)
	
    return 1
end

function PHARMACY_UI_SET_REMAIN_TIME(frame)
    local recipe_guid = frame:GetUserValue('RECIPE_GUID')
    if recipe_guid == 'None' then return end

    local recipe_item = session.GetInvItemByGuid(recipe_guid)
    if recipe_item == nil then return end

    local recipe_obj = GetIES(recipe_item:GetObject())
    local remain_time = GET_PHARMACY_RECIPE_REMAIN_SEC(recipe_obj)
    local recipe_remaintime = GET_CHILD_RECURSIVELY(frame, 'recipe_remaintime')
    
    if TryGetProp(recipe_obj, "ClassName", "None") == "pharmacy_recipe_Tuto" then
        local time_str = GET_TIME_TXT_NO_LANG(15 * 60)
        recipe_remaintime:SetTextByKey('value', time_str)
        recipe_remaintime:StopUpdateScript('PHARMACY_UI_REMAIN_TIME_UPDATE')
        recipe_remaintime:ShowWindow(1)
    else
        if 0 < remain_time then
            recipe_remaintime:SetUserValue('REMAINSEC', remain_time)
            recipe_remaintime:SetUserValue('STARTSEC', imcTime.GetAppTime())
            recipe_remaintime:RunUpdateScript('PHARMACY_UI_REMAIN_TIME_UPDATE')
            recipe_remaintime:ShowWindow(1)
        else
            recipe_remaintime:StopUpdateScript('PHARMACY_UI_REMAIN_TIME_UPDATE')
            recipe_remaintime:ShowWindow(0)
        end
    end
end

function PHARMACY_UI_OPEN(guid)
    ui.CloseFrame('active_pharmacy_recipe')

    local recipe = session.GetInvItemByGuid(guid)
    if recipe == nil then
        ui.CloseFrame('pharmacy_ui')
        return
    end
    
    local frame = ui.GetFrame('pharmacy_ui')
    if frame == nil then return end

    local recipe_obj = GetIES(recipe:GetObject())
    local size = TryGetProp(recipe_obj, 'RecipeSize', 0)
    local use_lv = TryGetProp(recipe_obj, 'NumberArg1', 0)

    frame:SetUserValue('RECIPE_GUID', guid)
    frame:SetUserValue('RECIPE_SIZE', size)
    frame:SetUserValue('RECIPE_LV', use_lv)
    frame:SetUserValue('CUR_POS_X', 'None')
    frame:SetUserValue('CUR_POS_Y', 'None')
    frame:ShowWindow(1)
end

function OPEN_PHARMACY_UI(frame)
    local guid = frame:GetUserValue('RECIPE_GUID')
    if guid == 'None' then
        frame:ShowWindow(0)
        return
    end

    local recipe_item = session.GetInvItemByGuid(guid)
    if recipe_item == nil then
        frame:ShowWindow(0)
        return
    end

    local recipe_obj = GetIES(recipe_item:GetObject())
    
    local isTuto = false
    if TryGetProp(recipe_obj, 'ClassName', 'None') == 'pharmacy_recipe_Tuto' then
        frame:SetUserValue("IS_TUTO", "YES")
        isTuto = true
        PHARMACY_UI_TUTORIAL_CHECK(frame)
    else
        frame:SetUserValue("IS_TUTO", "NO")
    end

    local size = TryGetProp(recipe_obj, 'RecipeSize', 0)
    for k, v in ipairs(pharmacy_recipe_size_list) do
        local _slotset = GET_CHILD_RECURSIVELY(frame, 'slotset_'..v)
        if _slotset == nil then return end
        
        for i = 1, v ^ 2 do
            local _slot = GET_CHILD(_slotset, 'slot'..i)
            _slot:ClearIcon()
            _slot:SetUserValue('IS_CUR_POS', 0)
            _slot:SetUserValue('IS_GOAL', 0)
            _slot:SetUserValue('IS_HURDLE', 0)
        end
        _slotset:ShowWindow(BoolToNumber(v == size))
    end

    PHARMACY_UI_MAT_SLOT_CLEAR(frame)

    local dispense_btn = GET_CHILD_RECURSIVELY(frame, 'dispense_btn')
    dispense_btn:SetEnable(0)
    dispense_btn:ShowWindow(0)

    local mat_gb = GET_CHILD_RECURSIVELY(frame, 'mat_gb')
    mat_gb:SetScrollBarSkinName("alchemy_cupboard_scroll")
    mat_gb:SetScrollBarBottomMargin(0)
    mat_gb:SetScrollBarOffset(0, 0)
    mat_gb:SetScrollPos(0)

    PHARMACY_UI_SET_GOAL_AND_HURDLE(frame)
    PHARMACY_UI_SET_MATERIAL_LIST(frame)
    PHARMACY_UI_SET_NEUTRALIZER_LIST(frame)
    PHARMACY_UI_SET_COUNT_BOX(frame)
    PHARMACY_UI_SET_REMAIN_TIME(frame)
    PHARMACY_UI_EXTRACTOR_INITIALIZE(frame)

    if isTuto == true then
        local prop_name = "UITUTO_PHARMACY"
        local tuto_step = GetUITutoProg(prop_name)
        if tuto_step == 10 then
            -- 슬롯에 등록
            local material_slotset = GET_CHILD_RECURSIVELY(frame, 'material_slotset', 'ui::CSlotSet')
            local slotCnt = material_slotset:GetSlotCount()
            for i = 1, slotCnt do
                local slot = material_slotset:GetSlotByIndex(i - 1)
                local guid = slot:GetUserValue('ITEM_GUID')
                local invItem = session.GetInvItemByGuid(guid)
                local itemObj = GetIES(invItem:GetObject())
                if TryGetProp(itemObj, "ClassName", "None") == 'pharmacy_material_C1_470_tutorial' then
                    PHARMACY_UI_CLICK_MAT_SLOTSET(material_slotset, slot)
                    break
                end
            end
        end
    end

    if frame:GetUserValue("IS_TUTO") == "YES" then
        control.EnableControl(0);
    end
end

function CLOSE_PHARMACY_UI(frame)
    if frame == nil then
        frame = ui.GetFrame('pharmacy_ui')
    end
    
    frame:StopUpdateScript('PHARMACY_UI_GRINDER_RUN')
    PHARMACY_UI_HOLD_ACTION(frame, 1)
    TUTORIAL_TEXT_CLOSE()

    if frame:GetUserValue("IS_TUTO") == "YES" then
        local tuto_prop = frame:GetUserValue('TUTO_PROP')
        pc.ReqExecuteTx('SCR_UI_TUTORIAL_CLOSE', tuto_prop)

        control.EnableControl(1);
    end
end

function PHARMACY_UI_SET_GOAL_AND_HURDLE(frame)
    local guid = frame:GetUserValue('RECIPE_GUID')
    local recipe_item = session.GetInvItemByGuid(guid)
    if recipe_item == nil then return end

    local size = frame:GetUserValue('RECIPE_SIZE')
    local slotset = GET_CHILD_RECURSIVELY(frame, 'slotset_'..size)
    
    local recipe_obj = GetIES(recipe_item:GetObject())
    local goal_img = frame:GetUserConfig('GOAL_IMG')
    for i = 1, _max_pharmacy_reward_count do
        local name = 'GoalPos_' .. i
        local pos_str = TryGetProp(recipe_obj, name, 'None')
        if pos_str ~= 'None' and TryGetProp(recipe_obj, 'GoalReward_' .. i, 0) ~= 1 then
            local goal = SCR_STRING_CUT(pos_str, ',')
            local slot = GET_CHILD(slotset, 'slot'..get_slot_index(goal[1], goal[2], size), 'ui::CSlot')
            slot:SetUserValue('IS_GOAL', 1)
            local icon = CreateIcon(slot)
            icon:SetImage(goal_img)
        end
    end

    local hurdle_img = frame:GetUserConfig('HURDLE_IMG')
    for i = 1, _max_hurdle_count do
        local name = 'HurdlePos_' .. i
        local pos_str = TryGetProp(recipe_obj, name, 'None')
        if pos_str ~= 'None' then
            local hurdle = SCR_STRING_CUT(pos_str, ',')
            local slot = GET_CHILD(slotset, 'slot'..get_slot_index(hurdle[1], hurdle[2], size), 'ui::CSlot')
            slot:SetUserValue('IS_HURDLE', 1)
            local icon = CreateIcon(slot)
            icon:SetImage(hurdle_img)
        end
    end

    PHARMACY_UI_SET_CURRENT_POS(frame)
end

function PHARMACY_UI_SET_CURRENT_POS(frame)
    local guid = frame:GetUserValue('RECIPE_GUID')
    local size = frame:GetUserValue('RECIPE_SIZE')
    local recipe_item = session.GetInvItemByGuid(guid)
    if recipe_item == nil then return end

    local recipe_obj = GetIES(recipe_item:GetObject())
    local cur_str = TryGetProp(recipe_obj, 'CurrentPos', 'None')
    local cur_pos = SCR_STRING_CUT(cur_str, ',')
    local slotset = GET_CHILD_RECURSIVELY(frame, 'slotset_'..size)

    local prev_x = frame:GetUserValue('CUR_POS_X')
    local prev_y = frame:GetUserValue('CUR_POS_Y')
    if prev_x ~= 'None' and prev_y ~= 'None' then
        local prev_slot = GET_CHILD(slotset, 'slot'..get_slot_index(tonumber(prev_x), tonumber(prev_y), size), 'ui::CSlot')
        prev_slot:SetUserValue('IS_CUR_POS', 0)
        prev_slot:ClearIcon()
    end

    local slot = GET_CHILD(slotset, 'slot'..get_slot_index(cur_pos[1], cur_pos[2], size), 'ui::CSlot')
    slot:SetUserValue('IS_CUR_POS', 1)
    frame:SetUserValue('CUR_POS_X', cur_pos[1])
    frame:SetUserValue('CUR_POS_Y', cur_pos[2])
    if slot:GetUserIValue('IS_GOAL') == 1 then
        slot:SetUserValue('IS_GOAL', 0)
    end

    local icon = CreateIcon(slot)
    local pos_img = frame:GetUserConfig('POS_IMG')
    icon:SetImage(pos_img)
end

function PHARMACY_UI_MATERIAL_TAB_CHANGE(parent, ctrl)
    local frame = parent:GetTopParentFrame()
    local index = ctrl:GetSelectItemIndex()
    local sort_list = GET_CHILD_RECURSIVELY(frame, 'sort_list')
    if index == 0 then
        sort_list:SelectItemByKey(1)
        sort_list:ShowWindow(1)
    elseif index == 1 then
        sort_list:ShowWindow(0)
    end
end

local _material_list_by_grade = {}
local function make_material_list_by_grade(frame)
    local use_lv = frame:GetUserIValue('RECIPE_LV')
    local strArg = 'pharmacy_material'
    if frame:GetUserValue("IS_TUTO") == "YES" then
        strArg = 'pharmacy_material_tutorial'
    end

    _material_list_by_grade = {}
    for i = 1, 4 do
        _material_list_by_grade[i] = {}
    end

    local inv_item_list = session.GetInvItemList()
    FOR_EACH_INVENTORY(inv_item_list, function(inv_item_list, inv_item, list, lv)
        local obj = GetIES(inv_item:GetObject())
        local mat_type = TryGetProp(obj, 'StringArg2', 'None')
        local mat_cls = GetClass('pharmacy_material_type', mat_type)
        if mat_cls ~= nil and TryGetProp(obj, 'StringArg', 'None') == strArg and TryGetProp(obj, 'NumberArg1', 0) == lv then
            table.insert(list[1], inv_item:GetIESID())
            
            local poison = TryGetProp(mat_cls, 'PoisonPoint', 0)
            if poison == 1 then
                table.insert(list[2], inv_item:GetIESID())
            elseif poison == 2 then
                table.insert(list[3], inv_item:GetIESID())
            elseif poison == 5 then
                table.insert(list[4], inv_item:GetIESID())
            end
        end
    end, false, _material_list_by_grade, use_lv)
end

function PHARMACY_UI_SET_MATERIAL_LIST(frame)
    make_material_list_by_grade(frame)

    local sort_list = GET_CHILD_RECURSIVELY(frame, 'sort_list')
    sort_list:ClearItems()
    for i, _list in ipairs(_material_list_by_grade) do
        local key = 'AllList'
        if i == 2 then
            key = 'LowGradePharmacyMaterial'
        elseif i == 3 then
            key = 'MiddleGradePharmacyMaterial'
        elseif i == 4 then
            key = 'HighGradePharmacyMaterial'
        end
        sort_list:AddItem(i, ClMsg(key))
    end

    sort_list:SelectItemByKey(1)
    
    PHARMACY_UI_SELECT_MATERIAL_LIST_BY_GRADE(frame, sort_list)
end

function PHARMACY_UI_SELECT_MATERIAL_LIST_BY_GRADE(parent, ctrl)
    local frame = parent:GetTopParentFrame()
    local material_slotset = GET_CHILD_RECURSIVELY(frame, 'material_slotset')
    material_slotset:RemoveAllChild()

    local sel_key = tonumber(ctrl:GetSelItemKey())
    if _material_list_by_grade == nil or _material_list_by_grade[sel_key] == nil then
        make_material_list_by_grade(frame)
    end

    local row_count = 0
    local material_list = _material_list_by_grade[sel_key]
    if material_list ~= nil then
        row_count = #material_list
    end

    material_slotset:SetColRow(material_slotset:GetCol(), math.max(3, math.ceil(row_count / 4)))
    material_slotset:CreateSlots()
    
    if material_list ~= nil and #material_list > 0 then
        if #material_list > 1 then
            table.sort(material_list, function(a, b)
                local aMat = session.GetInvItemByGuid(a)
                local bMat = session.GetInvItemByGuid(b)
                local a_obj = GetIES(aMat:GetObject())
                local b_obj = GetIES(bMat:GetObject())
                return a_obj.ClassID < b_obj.ClassID
            end)
        end

        for k, v in pairs(material_list) do
            local mat = session.GetInvItemByGuid(v)
            if mat ~= nil then
                local mat_obj = GetIES(mat:GetObject())
                local slotindex = imcSlot:GetEmptySlotIndex(material_slotset)
                local slot = material_slotset:GetSlotByIndex(slotindex)
                slot:SetUserValue('ITEM_GUID', mat:GetIESID())
                slot:SetMaxSelectCount(mat.count)
                SET_SLOT_IMG(slot, mat_obj.Icon)
                SET_SLOT_COUNT(slot, mat.count)
                SET_SLOT_COUNT_TEXT(slot, mat.count, '{@sti1c}{s14}')
                SET_SLOT_IESID(slot, mat:GetIESID())
                local class = GetClassByType('Item', mat.type)
                local icon = CreateIcon(slot)
                ICON_SET_INVENTORY_TOOLTIP(icon, mat, 'poisonpot', class)
            end
        end
    end

    local material_gb = GET_CHILD_RECURSIVELY(frame, 'material_gb')
    material_gb:Resize(material_slotset:GetWidth(), material_slotset:GetHeight() + 17)
    local mat_gb = GET_CHILD_RECURSIVELY(frame, 'mat_gb')
    mat_gb:SetScrollBar(material_gb:GetHeight())
end

function PHARMACY_UI_SET_NEUTRALIZER_LIST(frame)
    local use_lv = frame:GetUserIValue('RECIPE_LV')
    local neutralizer_slotset = GET_CHILD_RECURSIVELY(frame, 'neutralizer_slotset')
    neutralizer_slotset:RemoveAllChild()
    local strArg = 'pharmacy_counteractive'
    if frame:GetUserValue("IS_TUTO") == "YES" then
        strArg = 'pharmacy_counteractive_tutorial'
    end

    local neutralizer_list = {}
    local inv_item_list = session.GetInvItemList()
    FOR_EACH_INVENTORY(inv_item_list, function(inv_item_list, inv_item, list, lv)
        local obj = GetIES(inv_item:GetObject())
        if TryGetProp(obj, 'StringArg', 'None') == strArg and TryGetProp(obj, 'NumberArg1', 0) == lv then
            table.insert(list, inv_item:GetIESID())
        end
    end, false, neutralizer_list, use_lv)
    
    local row_count = 0
    if neutralizer_list ~= nil then
        row_count = #neutralizer_list
    end

    neutralizer_slotset:SetColRow(neutralizer_slotset:GetCol(), math.max(3, math.ceil(row_count / 4)))
    neutralizer_slotset:CreateSlots()
    
    if #neutralizer_list > 0 then
        if #neutralizer_list > 1 then
            table.sort(neutralizer_list, function(a, b)
                local aMat = session.GetInvItemByGuid(a)
                local bMat = session.GetInvItemByGuid(b)
                local a_obj = GetIES(aMat:GetObject())
                local b_obj = GetIES(bMat:GetObject())
                return a_obj.ClassID < b_obj.ClassID
            end)
        end

        for k, v in pairs(neutralizer_list) do
            local mat = session.GetInvItemByGuid(v)
            local mat_obj = GetIES(mat:GetObject())
            local slotindex = imcSlot:GetEmptySlotIndex(neutralizer_slotset)
            local slot = neutralizer_slotset:GetSlotByIndex(slotindex)
            slot:SetUserValue('ITEM_GUID', mat:GetIESID())
            slot:SetMaxSelectCount(mat.count)
            SET_SLOT_IMG(slot, mat_obj.Icon)
            SET_SLOT_COUNT(slot, mat.count)
            SET_SLOT_COUNT_TEXT(slot, mat.count, '{@sti1c}{s14}')
            SET_SLOT_IESID(slot, mat:GetIESID())
            local class = GetClassByType('Item', mat.type)
            local icon = CreateIcon(slot)
            ICON_SET_INVENTORY_TOOLTIP(icon, mat, 'poisonpot', class)
        end
    end

    local neutralizer_gb = GET_CHILD_RECURSIVELY(frame, 'neutralizer_gb')
    neutralizer_gb:Resize(neutralizer_slotset:GetWidth(), neutralizer_slotset:GetHeight() + 17)
    local mat_gb = GET_CHILD_RECURSIVELY(frame, 'mat_gb')
    mat_gb:SetScrollBar(neutralizer_gb:GetHeight())
end

function PHARMACY_UI_CLICK_MAT_SLOTSET(slotset, slot)
    local frame = slotset:GetTopParentFrame()
    
    local mat_guid = slot:GetUserValue('ITEM_GUID')
    if mat_guid == 'None' then return end

    local mat_item = session.GetInvItemByGuid(mat_guid)
    if mat_item == nil then return end
    
    local mat_slot = GET_CHILD_RECURSIVELY(frame, 'mat_slot')
    mat_slot:SetUserValue('MAT_GUID', mat_guid)

    PHARMACY_UI_REG_MATERIAL(frame, mat_item)
end

function PHARMACY_UI_DROP_MAT_SLOT(parent, ctrl)
    local frame	= parent:GetTopParentFrame()
    local liftIcon = ui.GetLiftIcon()
    local from_frame = liftIcon:GetTopParentFrame()
    if from_frame ~= frame then return end

    local slot = tolua.cast(ctrl, 'ui::CSlot')
    local iconInfo = liftIcon:GetInfo()
    local mat_item = GET_PC_ITEM_BY_GUID(iconInfo:GetIESID())
    if mat_item == nil then return end
    
    PHARMACY_UI_REG_MATERIAL(frame, mat_item)
end

function PHARMACY_UI_REG_MATERIAL(frame, mat_item)
    if mat_item == nil then return end
    
    local mat_obj = GetIES(mat_item:GetObject())
    local string_arg = TryGetProp(mat_obj, 'StringArg', 'None')
    if string_arg ~= 'pharmacy_material' and string_arg ~= 'pharmacy_material_tutorial' then
        ui.SysMsg(ClMsg('CantMovablePharmacyMaterial'))
        return
    end

    local mat_slot = GET_CHILD_RECURSIVELY(frame, 'mat_slot')
    mat_slot:SetUserValue('MAT_GUID', mat_item:GetIESID())
    SET_SLOT_IESID(mat_slot, mat_item:GetIESID())

    local sound_name = frame:GetUserConfig('MAT_REGISTER_SOUND')
    local sound_scp = string.format('PHARMACY_UI_PLAY_SOUND(\'%s\')', sound_name)
    ReserveScript(sound_scp, 0.01)

    if frame:GetUserValue("IS_TUTO") == "YES" then
        local mat_obj = GetIES(mat_item:GetObject())
        local mat_name = TryGetProp(mat_obj, "ClassName", "None")
        local tuto_prop = frame:GetUserValue('TUTO_PROP')
        local tuto_value = GetUITutoProg(tuto_prop)
        if tuto_value == 9 then
            if mat_name ~= "pharmacy_material_C1_470_tutorial" then
                return
            end
            pc.ReqExecuteTx('SCR_UI_TUTORIAL_NEXT_STEP', tuto_prop)
        elseif tuto_value == 11 or tuto_value == 14 then
            if mat_name ~= "pharmacy_material_D2_470_tutorial" then
                return
            end
        elseif tuto_value == 13 then
            if mat_name ~= "Pharmacy_470_Counteractive_1_tutorial" then
                return
            end
        elseif tuto_value == 10 then
            -- 슬롯에 아이템 등록되고 끝
        else
            return
        end
    end
    
    PHARMACY_UI_CLEAR_PATH(frame)
    PHARMACY_UI_GRINDER_CAP_OPEN(frame)
end

function PHARMACY_UI_MAT_SLOT_CLEAR(parent, ctrl)
    local frame = parent:GetTopParentFrame()
    local mat_slot = GET_CHILD_RECURSIVELY(frame, 'mat_slot')
    mat_slot:ClearIcon()
    mat_slot:SetUserValue('MAT_GUID', 'None')

    frame:SetUserValue('CAP_RUN_SCP', 'None')
    PHARMACY_UI_CLEAR_PATH(frame)
    
    if ctrl ~= nil then
        -- 재료를 클릭해서 제거한 경우 열린 뚜껑을 닫아줌
        PHARMACY_UI_GRINDER_CAP_CLOSE(frame)
    else
        -- 그라인더 분쇄가 완료된 경우 접시에서 가루를 치워줌
        frame:RunUpdateScript('PHARMACY_UI_GRINDER_POWDER_FADEOUT', 0, 0, 0, 1)
    end
end

function PHARMACY_UI_PATH_PREVIEW(frame)
    local recipe_guid = frame:GetUserValue('RECIPE_GUID')
    local size = frame:GetUserIValue('RECIPE_SIZE')
    local recipe_item = session.GetInvItemByGuid(recipe_guid)
    if recipe_item == nil then return end

    local recipe_obj = GetIES(recipe_item:GetObject())

    local mat_slot = GET_CHILD_RECURSIVELY(frame, 'mat_slot')
    local mat_guid = mat_slot:GetUserValue('MAT_GUID')
    local mat_item = session.GetInvItemByGuid(mat_guid)
    if mat_item == nil then return end

    local cur_x = frame:GetUserIValue('CUR_POS_X')
    local cur_y = frame:GetUserIValue('CUR_POS_Y')
    
    local mat_obj = GetIES(mat_item:GetObject())
    local add_x, add_y = get_material_add_pos(mat_obj)
    local move_x = cur_x + add_x
    local move_y = cur_y + add_y

    local bg_img = frame:GetUserConfig('MOVE_IMG')
    local blocked = shared_item_pharmacy.is_passing_hurdle(cur_x, cur_y, move_x, move_y, recipe_obj)
    if move_x < 0 or move_x >= size or move_y < 0 or move_y >= size then
        blocked = true
    end

    if blocked == false then
        frame:SetUserValue('ADD_X', add_x)
        frame:SetUserValue('ADD_Y', add_y)
        frame:SetUserValue('MOVE_COUNT', math.abs(add_x) + math.abs(add_y))
    end

    local map_slotset = GET_CHILD_RECURSIVELY(frame, 'slotset_'..size)
    for x = cur_x, move_x, (move_x - cur_x) / math.abs(move_x - cur_x) do
        if x < 0 or x >= size then return end

        local _slot = GET_CHILD(map_slotset, 'slot'..get_slot_index(x, cur_y, size), 'ui::CSlot')
        if _slot ~= nil and x >= 0 and x < size and _slot:GetUserIValue('IS_CUR_POS') ~= 1 then
            local _icon = CreateIcon(_slot)
            if _slot:GetUserIValue('IS_GOAL') == 1 then
                _icon:SetColorTone('FF00FF00')
            elseif _slot:GetUserIValue('IS_HURDLE') ~= 1 then
                _icon:SetImage(bg_img)
            end

            if blocked == true then
                _icon:SetColorTone('FFFF0000')
            end
        end
    end

    for y = cur_y, move_y, (move_y - cur_y) / math.abs(move_y - cur_y) do
        if y < 0 or y >= size then return end
        local _slot = GET_CHILD(map_slotset, 'slot'..get_slot_index(move_x, y, size), 'ui::CSlot')
        if _slot ~= nil and y >= 0 and y < size and _slot:GetUserIValue('IS_CUR_POS') ~= 1 then
            local _icon = CreateIcon(_slot)
            if _slot:GetUserIValue('IS_GOAL') == 1 then
                _icon:SetColorTone('FF00FF00')
            elseif _slot:GetUserIValue('IS_HURDLE') ~= 1 then
                _icon:SetImage(bg_img)
            end

            if blocked == true then
                _icon:SetColorTone('FFFF0000')
            end
        end
    end
end

function PHARMACY_UI_CLEAR_PATH(frame)
    local size = frame:GetUserValue('RECIPE_SIZE')
    local map_slotset = GET_CHILD_RECURSIVELY(frame, 'slotset_'..size)
    for i = 1, size ^ 2 do
        local _slot = GET_CHILD(map_slotset, 'slot'..i, 'ui::CSlot')
        if _slot ~= nil and _slot:GetUserIValue('IS_CUR_POS') ~= 1 then
            if _slot:GetUserIValue('IS_GOAL') == 1 or _slot:GetUserIValue('IS_HURDLE') == 1 then
                local _icon = CreateIcon(_slot)
                _icon:SetColorTone('FFFFFFFF')
            else
                _slot:ClearIcon()
            end
        end
    end

    frame:SetUserValue('MOVE_COUNT', 0)
    frame:SetUserValue('CUR_MOVE_COUNT', 0)
    frame:SetUserValue('CUR_SOUND_COUNT', 0)
    frame:SetUserValue('ADD_X', 0)
    frame:SetUserValue('ADD_Y', 0)
end

function PHARMACY_UI_SET_COUNT_BOX(frame)
    local recipe_guid = frame:GetUserValue('RECIPE_GUID')
    if recipe_guid == 'None' then return end

    local recipe_item = session.GetInvItemByGuid(recipe_guid)
    if recipe_item == nil then return end

    local recipe_obj = GetIES(recipe_item:GetObject())
    local enable_goal, max_goal = shared_item_pharmacy.get_remain_goal_count(recipe_obj)
    local neutralize_count, max_neutralize_count = shared_item_pharmacy.get_current_neutralize_count(recipe_obj)
    local try_count, max_try_count = shared_item_pharmacy.get_current_try_count(recipe_obj)
    
    local empty_img = frame:GetUserConfig('EMPTY_POTION_IMG')
    empty_img = string.format('{img %s 20 30} ', empty_img)
    local reward_img = frame:GetUserConfig('REWARD_POTION_IMG')
    reward_img = string.format('{img %s 20 30} ', reward_img)
    local neutralize_img = frame:GetUserConfig('NEUTRALIZE_POTION_IMG')
    neutralize_img = string.format('{img %s 20 30} ', neutralize_img)

    local reward_str = ''
    for i = max_goal, 1, -1 do
        if i > enable_goal then
            reward_str = reward_str .. reward_img
        else
            reward_str = reward_str .. empty_img
        end
    end
    
    local neutralize_str = ''
    for i = 1, max_neutralize_count do
        if i > neutralize_count then
            neutralize_str = neutralize_str .. empty_img
        else
            neutralize_str = neutralize_str .. neutralize_img
        end
    end

    local reward_count_text = GET_CHILD_RECURSIVELY(frame, 'reward_count')
    reward_count_text:SetTextByKey('value', reward_str)

    local neutralize_count_text = GET_CHILD_RECURSIVELY(frame, 'neutralize_count')
    neutralize_count_text:SetTextByKey('value', neutralize_str)

    local poison_gauge = GET_CHILD_RECURSIVELY(frame, 'poison_gauge')
    poison_gauge:SetPoint(max_try_count - try_count, max_try_count)
end

function PHARMACY_UI_CLICK_DISPENSE_BTN(parent, ctrl)
    local frame = parent:GetTopParentFrame()
    local recipe_guid = frame:GetUserValue('RECIPE_GUID')
    if recipe_guid == 'None' then return end
    
    local recipe_item = session.GetInvItemByGuid(recipe_guid)
    if recipe_item == nil then return end

    local mat_slot = GET_CHILD_RECURSIVELY(frame, 'mat_slot')
    local mat_guid = mat_slot:GetUserValue('MAT_GUID')
    if mat_guid == 'None' then return end

    local mat_item = session.GetInvItemByGuid(mat_guid)
    if mat_item == nil then return end

    local recipe_obj = GetIES(recipe_item:GetObject())
    local mat_obj = GetIES(mat_item:GetObject())
    if shared_item_pharmacy.enable_move_to(recipe_obj, mat_obj) == false then
        ui.SysMsg(ClMsg('CantMovablePharmacyMaterial'))
        return
    end

    if shared_item_pharmacy.move_to(recipe_obj, mat_obj) == false then
        ui.SysMsg(ClMsg('CantMovablePharmacyMaterial'))
        return
    end

    PHARMACY_UI_GRINDER_CAP_CLOSE(frame)
end

function PHARMACY_UI_REQ_DISPENSE(parent, ctrl)
    local frame = parent:GetTopParentFrame()
    local recipe_guid = frame:GetUserValue('RECIPE_GUID')
    if recipe_guid == 'None' then return end
    
    local recipe_item = session.GetInvItemByGuid(recipe_guid)
    if recipe_item == nil then return end

    local mat_slot = GET_CHILD_RECURSIVELY(frame, 'mat_slot')
    local mat_guid = mat_slot:GetUserValue('MAT_GUID')
    if mat_guid == 'None' then return end

    local mat_item = session.GetInvItemByGuid(mat_guid)
    if mat_item == nil then return end

    local recipe_obj = GetIES(recipe_item:GetObject())
    local mat_obj = GetIES(mat_item:GetObject())
    if shared_item_pharmacy.enable_move_to(recipe_obj, mat_obj) == false then
        ui.SysMsg(ClMsg('CantMovablePharmacyMaterial'))
        return
    end

    if shared_item_pharmacy.move_to(recipe_obj, mat_obj) == false then
        ui.SysMsg(ClMsg('CantMovablePharmacyMaterial'))
        return
    end

    PHARMACY_UI_GRINDER_START(frame)
end

function _PHARMACY_UI_REQ_DISPENSE()
    local frame = ui.GetFrame('pharmacy_ui')
    if frame == nil then return end
    if frame:IsVisible() ~= 1 then
        PHARMACY_UI_FAILED_ACTION(frame)
        return
    end

    local recipe_guid = frame:GetUserValue('RECIPE_GUID')
    if recipe_guid == 'None' then return end
    
    local recipe_item = session.GetInvItemByGuid(recipe_guid)
    if recipe_item == nil then return end

    local mat_slot = GET_CHILD_RECURSIVELY(frame, 'mat_slot')
    local mat_guid = mat_slot:GetUserValue('MAT_GUID')
    if mat_guid == nil or mat_guid == 'None' then
        PHARMACY_UI_FAILED_ACTION(frame)
        return
    end

    local mat_item = session.GetInvItemByGuid(mat_guid)
    if mat_item == nil then
        PHARMACY_UI_FAILED_ACTION(frame)
        return
    end

    local recipe_obj = GetIES(recipe_item:GetObject())
    local mat_obj = GetIES(mat_item:GetObject())
    if shared_item_pharmacy.enable_move_to(recipe_obj, mat_obj) == false then
        ui.SysMsg(ClMsg('CantMovablePharmacyMaterial'))
        PHARMACY_UI_FAILED_ACTION(frame)
        return
    end

    if shared_item_pharmacy.move_to(recipe_obj, mat_obj) == false then
        ui.SysMsg(ClMsg('CantMovablePharmacyMaterial'))
        PHARMACY_UI_FAILED_ACTION(frame)
        return
    end

    session.ResetItemList()
    session.AddItemID(recipe_guid, 1)
    session.AddItemID(mat_guid, 1)
	local resultlist = session.GetItemIDList()
    item.DialogTransaction('PHARMACY_DISPENSE', resultlist)
end

function PHARMACY_UI_COMPLETE_DISPENSE(frame, msg, arg_str, arg_num)
    PHARMACY_UI_SET_CURRENT_POS(frame)
    PHARMACY_UI_SET_MATERIAL_LIST(frame)
    PHARMACY_UI_MAT_SLOT_CLEAR(frame)
    PHARMACY_UI_CLEAR_PATH(frame)
    PHARMACY_UI_SET_COUNT_BOX(frame)

    if arg_str ~= 'None' and arg_num > 0 then
        frame:SetUserValue('REWARD_NAME', arg_str)
        frame:SetUserValue('REWARD_COUNT', arg_num)
        ReserveScript('PHARMACY_UI_EXTRACTOR_START()', 0.1)
    else
        PHARMACY_UI_HOLD_ACTION(frame, 1)
    end
    
    local tuto_prop = frame:GetUserValue('TUTO_PROP')
    local tuto_step = GetUITutoProg(tuto_prop)
    
    if tuto_step == 10 or tuto_step == 11 or tuto_step == 14 then
        pc.ReqExecuteTx('SCR_UI_TUTORIAL_NEXT_STEP', tuto_prop)
    end
end

function PHARMACY_UI_CLICK_NEUTRALIZER(slotset, slot)
    local frame = slotset:GetTopParentFrame()

    local mat_guid = slot:GetUserValue('ITEM_GUID')
    if mat_guid == 'None' then return end

    local mat_item = session.GetInvItemByGuid(mat_guid)
    if mat_item == nil then return end

    PHARMACY_UI_REQ_NEUTRALIZE(frame, mat_item)
end

function PHARMACY_UI_DROP_EXTRACTOR_CAP(parent, ctrl)
    local frame	= parent:GetTopParentFrame()
    local liftIcon = ui.GetLiftIcon()
    local from_frame = liftIcon:GetTopParentFrame()
    if from_frame ~= frame then return end

	local slot = tolua.cast(ctrl, 'ui::CSlot')
	local iconInfo = liftIcon:GetInfo()
    local mat_item = GET_PC_ITEM_BY_GUID(iconInfo:GetIESID())
    if mat_item == nil then return end

    PHARMACY_UI_REQ_NEUTRALIZE(frame, mat_item)
end

function PHARMACY_UI_REQ_NEUTRALIZE(frame, mat_item)
    local recipe_guid = frame:GetUserValue('RECIPE_GUID')
    if recipe_guid == 'None' then return end
    
    local recipe_item = session.GetInvItemByGuid(recipe_guid)
    if recipe_item == nil then return end
    
    local recipe_obj = GetIES(recipe_item:GetObject())
    local mat_obj = GetIES(mat_item:GetObject())
    if shared_item_pharmacy.usable_neutralizer(recipe_obj, mat_obj) == false then
        ui.SysMsg(ClMsg('CantMovablePharmacyMaterial'))
        return
    end

    local cur_use_count, max_use_count = shared_item_pharmacy.get_current_neutralize_count(recipe_obj)
    if cur_use_count <= 0 then
        ui.SysMsg(ClMsg('NeutralizeCountExpired'))
        return
    end

    local extractor_cap = GET_CHILD_RECURSIVELY(frame, 'extractor_cap')
    extractor_cap:SetUserValue('MAT_GUID', mat_item:GetIESID())
    frame:RunUpdateScript('PHARMACY_UI_EXTRACTOR_CAP_OPEN', 0, 0, 0, 1)

    local mat_name = dic.getTranslatedStr(TryGetProp(mat_obj, 'Name', 'None'))
    local yesscp = string.format('_PHARMACY_UI_REQ_NEUTRALIZE()')
    local noscp = string.format('_PHARMACY_UI_CANCEL_NEUTRALIZE()')
    local msgbox = ui.MsgBox(ScpArgMsg('ReallyUseNeutralizer{Name}', 'Name', mat_name), yesscp, noscp)
    SET_MODAL_MSGBOX(msgbox)
end

function _PHARMACY_UI_REQ_NEUTRALIZE()
    local frame = ui.GetFrame('pharmacy_ui')
    local recipe_guid = frame:GetUserValue('RECIPE_GUID')
    if recipe_guid == 'None' then return end
    
    local recipe_item = session.GetInvItemByGuid(recipe_guid)
    if recipe_item == nil then return end

    local extractor_cap = GET_CHILD_RECURSIVELY(frame, 'extractor_cap')
    local mat_guid = extractor_cap:GetUserValue('MAT_GUID')
    local mat_item = session.GetInvItemByGuid(mat_guid)
    if mat_item == nil then return end

    local recipe_obj = GetIES(recipe_item:GetObject())
    local mat_obj = GetIES(mat_item:GetObject())
    if shared_item_pharmacy.usable_neutralizer(recipe_obj, mat_obj) == false then
        ui.SysMsg(ClMsg('CantMovablePharmacyMaterial'))
        return
    end

    session.ResetItemList()
    session.AddItemID(recipe_guid, 1)
    session.AddItemID(mat_guid, 1)
    local resultlist = session.GetItemIDList()
    item.DialogTransaction('PHARMACY_NEUTRALIZE', resultlist)
end

function _PHARMACY_UI_CANCEL_NEUTRALIZE()
    local frame = ui.GetFrame('pharmacy_ui')
    local extractor_cap = GET_CHILD_RECURSIVELY(frame, 'extractor_cap')
    extractor_cap:SetUserValue('MAT_GUID', 'None')
    frame:RunUpdateScript('PHARMACY_UI_EXTRACTOR_CAP_CLOSE', 0, 0, 0, 1)
end

function PHARMACY_UI_COMPLETE_NEUTRALIZE(frame, msg, arg_str, arg_num)
    local extractor_cap = GET_CHILD_RECURSIVELY(frame, 'extractor_cap')
    extractor_cap:SetUserValue('MAT_GUID', 'None')
    frame:RunUpdateScript('PHARMACY_UI_EXTRACTOR_CAP_CLOSE', 0, 0, 0, 1)
    PHARMACY_UI_SET_COUNT_BOX(frame)
    PHARMACY_UI_SET_NEUTRALIZER_LIST(frame)

    local tuto_prop = frame:GetUserValue('TUTO_PROP')
    local tuto_step = GetUITutoProg(tuto_prop)
    if tuto_step == 13 then
        pc.ReqExecuteTx('SCR_UI_TUTORIAL_NEXT_STEP', tuto_prop)
    end
end

function PHARMACY_UI_FAILED_ACTION(frame, msg, arg_str, arg_num)
    PHARMACY_UI_HOLD_ACTION(frame, 1)

    PHARMACY_UI_SET_CURRENT_POS(frame)
    PHARMACY_UI_SET_MATERIAL_LIST(frame)
    PHARMACY_UI_SET_NEUTRALIZER_LIST(frame)
    PHARMACY_UI_MAT_SLOT_CLEAR(frame)
    PHARMACY_UI_CLEAR_PATH(frame)
    PHARMACY_UI_SET_COUNT_BOX(frame)
end

function PHARMACY_UI_HOLD_ACTION(frame, flag)
    ui.SetHoldUI(flag == 0)
    SetCraftState(1 - flag)
    local mat_slot = GET_CHILD_RECURSIVELY(frame, 'mat_slot')
    mat_slot:SetEnable(flag)
    local material_slotset = GET_CHILD_RECURSIVELY(frame, 'material_slotset')
    material_slotset:SetEnable(flag)
    local neutralizer_slotset = GET_CHILD_RECURSIVELY(frame, 'neutralizer_slotset')
    neutralizer_slotset:SetEnable(flag)
    local dispense_btn = GET_CHILD_RECURSIVELY(frame,'dispense_btn')
    dispense_btn:SetEnable(flag)
    local clost_btn = GET_CHILD_RECURSIVELY(frame, 'close')
    clost_btn:SetEnable(flag)
end

-- grinder --
-- grinder cap
function PHARMACY_UI_GRINDER_CAP_RUN(frame, elapsedTime)
    frame = frame:GetTopParentFrame()
    local term = shared_item_pharmacy.get_cap_speed()
    
    local ratio = elapsedTime / term
    if frame:GetUserIValue('IS_OPEN') ~= 1 then
        ratio = 1 - ratio
    end
    
    local origin_width = 134
    local origin_height = 62
    local origin_length = math.sqrt(math.pow(origin_width, 2) + math.pow(origin_height, 2))
    local length = origin_length - (origin_length - origin_width - 6) * ratio
    
    local start_angle = math.atan(origin_height / origin_width)
    local end_angle = 0.25 * math.pi
    
    local angle = start_angle + (end_angle - start_angle) * ratio
    if angle < start_angle then
        angle = start_angle
    elseif angle > end_angle then
        angle = end_angle
    end

    local width = math.floor(length * math.cos(angle))
    local height = math.floor(length * math.sin(angle))
    
    local image_angle = 45 * ratio
    
    local cap = GET_CHILD_RECURSIVELY(frame, 'grinder_cap')
    cap:Resize(width, height)
    cap:SetAngle(image_angle)

    if elapsedTime >= term then
        if frame:GetUserIValue('IS_OPEN') ~= 1 then
            cap:Resize(origin_width, origin_height)
            cap:SetAngle(0)
        end

        local run_scp_str = frame:GetUserValue('CAP_RUN_SCP')
        if run_scp_str ~= 'None' and _G[run_scp_str] ~= nil then
            local run_scp = _G[run_scp_str]
            run_scp(frame)
        end
        
        return 0
    else
        return 1
    end
end

function PHARMACY_UI_GRINDER_CAP_OPEN(frame)
    frame:SetUserValue('IS_OPEN', 1)
    frame:SetUserValue('CAP_RUN_SCP', 'PHARMACY_UI_GRINDER_CAP_OPEN_COMPLETE')
    frame:RunUpdateScript('PHARMACY_UI_GRINDER_CAP_RUN', 0, 0, 0, 1)
end

function PHARMACY_UI_GRINDER_CAP_OPEN_COMPLETE(frame)
    local mat_slot = GET_CHILD_RECURSIVELY(frame, 'mat_slot')
    local mat_guid = mat_slot:GetUserValue('MAT_GUID')
    if mat_guid == 'None' then return end

    local mat_item = session.GetInvItemByGuid(mat_guid)
    if mat_item == nil then return end
    
    local mat_obj = GetIES(mat_item:GetObject())
    local mat_icon = CreateIcon(mat_slot)
    mat_icon:SetImage(TryGetProp(mat_obj, 'Icon', 'None'))

    PHARMACY_UI_PATH_PREVIEW(frame)

    local dispense_btn = GET_CHILD_RECURSIVELY(frame, 'dispense_btn')
    dispense_btn:SetEnable(1)
    dispense_btn:ShowWindow(1)
end

function PHARMACY_UI_GRINDER_CAP_CLOSE(frame)
    local dispense_btn = GET_CHILD_RECURSIVELY(frame, 'dispense_btn')
    dispense_btn:ShowWindow(0)
    dispense_btn:SetEnable(0)

    frame:SetUserValue('IS_OPEN', 0)
    frame:SetUserValue('CAP_RUN_SCP', 'PHARMACY_UI_GRINDER_CAP_CLOSE_COMPLETE')
    frame:RunUpdateScript('PHARMACY_UI_GRINDER_CAP_RUN', 0, 0, 0, 1)
end

function PHARMACY_UI_GRINDER_CAP_CLOSE_COMPLETE(frame)
    PHARMACY_UI_REQ_DISPENSE(frame)
end

-- grinder handle
function PHARMACY_UI_GRINDER_START(frame)
    PHARMACY_UI_HOLD_ACTION(frame, 0)

    local frame = frame:GetTopParentFrame()
    local dispense_btn = GET_CHILD_RECURSIVELY(frame, 'dispense_btn')
    dispense_btn:ShowWindow(0)
    dispense_btn:SetEnable(0)
    
    local sound_name = frame:GetUserConfig('WHEEL_START_SOUND')
    local sound_scp = string.format('PHARMACY_UI_PLAY_SOUND(\'%s\')', sound_name)
    ReserveScript(sound_scp, 0.01)
    
	frame:RunUpdateScript('PHARMACY_UI_GRINDER_RUN', 0, 0, 0, 1)
end

function PHARMACY_UI_MOVE_POS_ONE_SLOT(frame)
    local size = frame:GetUserValue('RECIPE_SIZE')
    local map_slotset = GET_CHILD_RECURSIVELY(frame, 'slotset_'..size)
    local goal_img = frame:GetUserConfig('GOAL_IMG')

    local cur_x = frame:GetUserValue('CUR_POS_X')
    local cur_y = frame:GetUserValue('CUR_POS_Y')
        local before_slot = GET_CHILD(map_slotset, 'slot'..get_slot_index(cur_x, cur_y, size), 'ui::CSlot')
        before_slot:SetUserValue('IS_CUR_POS', 0)
        if before_slot:GetUserIValue('IS_GOAL') == 1 then
            local icon = CreateIcon(before_slot)
            icon:SetImage(goal_img)
        else
            before_slot:ClearIcon()
        end

    local move_count = frame:GetUserIValue('MOVE_COUNT')
    local cur_move_count = frame:GetUserIValue('CUR_MOVE_COUNT')
    local sound_name = frame:GetUserConfig('MOVE_SOUND')
    if move_count == cur_move_count then
        sound_name = frame:GetUserConfig('ARRIVED_SOUND')
    end
    local sound_scp = string.format('PHARMACY_UI_PLAY_SOUND(\'%s\')', sound_name)
    ReserveScript(sound_scp, 0.01)

    local add_x = frame:GetUserIValue('ADD_X')
    local add_y = frame:GetUserIValue('ADD_Y')
    if add_x ~= 0 then
        local adder = add_x / math.abs(add_x)
        local move_slot = GET_CHILD(map_slotset, 'slot'..get_slot_index(cur_x + adder, cur_y, size), 'ui::CSlot')
        local icon = CreateIcon(move_slot)
        local pos_img = frame:GetUserConfig('POS_IMG')
        icon:SetImage(pos_img)
        move_slot:SetUserValue('IS_CUR_POS', 1)

        frame:SetUserValue('CUR_POS_X', cur_x + adder)
        frame:SetUserValue('ADD_X', add_x - adder)
    elseif add_y ~= 0 then
        local adder = add_y / math.abs(add_y)
        local move_slot = GET_CHILD(map_slotset, 'slot'..get_slot_index(cur_x, cur_y + adder, size), 'ui::CSlot')
        local icon = CreateIcon(move_slot)
        local pos_img = frame:GetUserConfig('POS_IMG')
        icon:SetImage(pos_img)
        move_slot:SetUserValue('IS_CUR_POS', 1)

        frame:SetUserValue('CUR_POS_Y', cur_y + adder)
        frame:SetUserValue('ADD_Y', add_y - adder)
    end
end

function PHARMACY_UI_GRINDER_POWDER_STACK(frame, elapsedTime, total_time)
    local powder_term = total_time / 3
    local grinder_powder1 = GET_CHILD_RECURSIVELY(frame, 'grinder_powder1')
    local grinder_powder2 = GET_CHILD_RECURSIVELY(frame, 'grinder_powder2')
    local grinder_powder3 = GET_CHILD_RECURSIVELY(frame, 'grinder_powder3')
    if elapsedTime >= powder_term * 2 then
        local alpha = ((elapsedTime - powder_term * 2) / powder_term) * 100
        grinder_powder3:SetAlpha(alpha)
    elseif elapsedTime >= powder_term then
        local alpha = ((elapsedTime -powder_term) / powder_term) * 100
        grinder_powder2:SetAlpha(alpha)
    else
        local alpha = (elapsedTime / powder_term) * 100
        grinder_powder1:SetAlpha(alpha)
    end
end

function PHARMACY_UI_GRINDER_POWDER_DROP(frame, time_by_term, move_time)
    local drop_term = move_time / 3
    local grinder_drop1 = GET_CHILD_RECURSIVELY(frame, 'grinder_drop1')
    local grinder_drop2 = GET_CHILD_RECURSIVELY(frame, 'grinder_drop2')
    local grinder_drop3 = GET_CHILD_RECURSIVELY(frame, 'grinder_drop3')
    if time_by_term >= drop_term * 2 then
        -- increase
        local alpha = ((time_by_term - drop_term * 2) / drop_term) * 100
        grinder_drop1:SetAlpha(alpha)
    elseif time_by_term < drop_term then
        -- decrease
        local alpha = ((drop_term - time_by_term) / drop_term) * 100
        grinder_drop1:SetAlpha(alpha)
    end

    if time_by_term > drop_term * 2 then
        -- decrease
        local alpha = ((move_time - time_by_term) / drop_term) * 100
        grinder_drop2:SetAlpha(alpha)
    elseif time_by_term >= drop_term then
        -- increase
        local alpha = ((time_by_term - drop_term) / drop_term) * 100
        grinder_drop2:SetAlpha(alpha)
    end

    if time_by_term >= drop_term and time_by_term < drop_term * 2 then
        -- decrease
        local alpha = ((drop_term * 2 - time_by_term) / drop_term) * 100
        grinder_drop3:SetAlpha(alpha)
    elseif time_by_term < drop_term then
        -- increase
        local alpha = (time_by_term / drop_term) * 100
        grinder_drop3:SetAlpha(alpha)
    end
end

function PHARMACY_UI_GRINDER_RUN(frame, elapsedTime)
    frame = frame:GetTopParentFrame()
    local move_count = frame:GetUserIValue('MOVE_COUNT')
    local cur_move_count = frame:GetUserIValue('CUR_MOVE_COUNT')
    local cur_sound_count = frame:GetUserIValue('CUR_SOUND_COUNT')
    local move_time = shared_item_pharmacy.get_handle_speed()
    local cur_count, time_by_term = math.modf(elapsedTime / move_time)
    local total_time = move_count * move_time
	local isEnd = false
	if elapsedTime >= total_time then
		isEnd = true
    end

    local angle = PHARMACY_UI_GRINDER_ANGLE(elapsedTime, move_time)
    angle = angle % 360
	
	local grinder_handle = GET_CHILD_RECURSIVELY(frame, 'grinder_handle')
    grinder_handle:SetAngle(angle)
    
    -- powder stack
    PHARMACY_UI_GRINDER_POWDER_STACK(frame, elapsedTime, total_time)

    -- powder drop
    PHARMACY_UI_GRINDER_POWDER_DROP(frame, time_by_term, move_time)

    if isEnd == false and cur_count >= cur_sound_count then
        frame:SetUserValue('CUR_SOUND_COUNT', cur_count + 1)
        local sound_name = frame:GetUserConfig('WHEEL_RUN_SOUND')
        local sound_scp = string.format('PHARMACY_UI_PLAY_SOUND(\'%s\')', sound_name)
        ReserveScript(sound_scp, 0.01)
    end

    if cur_count > cur_move_count then
        frame:SetUserValue('CUR_MOVE_COUNT', cur_count)
        PHARMACY_UI_MOVE_POS_ONE_SLOT(frame)
    end

	if isEnd == true then
        ReserveScript('_PHARMACY_UI_REQ_DISPENSE()', 0.5)
		return 0
	else
		return 1
	end
end

function PHARMACY_UI_GRINDER_POWDER_FADEOUT(frame, elapsedTime)
    local term = 0.2 -- sec

    local grinder_powder1 = GET_CHILD_RECURSIVELY(frame, 'grinder_powder1')
    local grinder_powder2 = GET_CHILD_RECURSIVELY(frame, 'grinder_powder2')
    local grinder_powder3 = GET_CHILD_RECURSIVELY(frame, 'grinder_powder3')
    local grinder_drop1 = GET_CHILD_RECURSIVELY(frame, 'grinder_drop1')
    local grinder_drop2 = GET_CHILD_RECURSIVELY(frame, 'grinder_drop2')
    local grinder_drop3 = GET_CHILD_RECURSIVELY(frame, 'grinder_drop3')

    if elapsedTime >= term then
        grinder_powder1:SetAlpha(0)
        grinder_powder2:SetAlpha(0)
        grinder_powder3:SetAlpha(0)
        grinder_drop1:SetAlpha(0)
        grinder_drop2:SetAlpha(0)
        grinder_drop3:SetAlpha(0)

        return 0
    else
        local alpha = ((term - elapsedTime) / term) * 100
        grinder_powder1:SetAlpha(alpha)
        grinder_powder2:SetAlpha(alpha)
        grinder_powder3:SetAlpha(alpha)
        grinder_drop1:SetAlpha(alpha)
        grinder_drop2:SetAlpha(alpha)
        grinder_drop3:SetAlpha(alpha)

        return 1
    end
end

function PHARMACY_UI_GRINDER_ANGLE(time, term)
    local time_by_term = math.fmod(time, term)
    local accel = 180 / (0.5 * math.pow(0.5 * term, 2))
    if time_by_term >= term * 0.5 then
        return 360 - 0.5 * accel * math.pow(time_by_term - term, 2)
    else
        return 0.5 * accel * math.pow(time_by_term, 2)
    end
end
-- end of grinder --

-- extractor
function PHARMACY_UI_EXTRACTOR_CAP_OPEN(frame, elapsedTime)
    local term = 0.5 -- sec
    local extractor_cap = GET_CHILD_RECURSIVELY(frame, 'extractor_cap')
    local extractor_cap_pic = GET_CHILD_RECURSIVELY(frame, 'extractor_cap_pic')
    if elapsedTime >= term then
        extractor_cap:SetAlpha(0)
        extractor_cap_pic:SetAlpha(100)
        return 0
    else
        local alpha = (elapsedTime / term) * 100
        extractor_cap:SetAlpha(100 - alpha)
        extractor_cap_pic:SetAlpha(alpha)
        return 1
    end
end

function PHARMACY_UI_EXTRACTOR_CAP_CLOSE(frame, elapsedTime)
    local term = 0.5 -- sec
    local extractor_cap = GET_CHILD_RECURSIVELY(frame, 'extractor_cap')
    local extractor_cap_pic = GET_CHILD_RECURSIVELY(frame, 'extractor_cap_pic')
    if elapsedTime >= term then
        extractor_cap:SetAlpha(100)
        extractor_cap_pic:SetAlpha(0)
        return 0
    else
        local alpha = (elapsedTime / term) * 100
        extractor_cap:SetAlpha(alpha)
        extractor_cap_pic:SetAlpha(100 - alpha)
        return 1
    end
end

function PHARMACY_UI_EXTRACTOR_INITIALIZE(frame)
    local extractor_cap = GET_CHILD_RECURSIVELY(frame, 'extractor_cap')
    local extractor_cap_pic = GET_CHILD_RECURSIVELY(frame, 'extractor_cap_pic')
    extractor_cap:SetAlpha(100)
    extractor_cap_pic:SetAlpha(0)

    local extractor_valve_close = GET_CHILD_RECURSIVELY(frame, 'extractor_valve_close')
    local extractor_valve_half = GET_CHILD_RECURSIVELY(frame, 'extractor_valve_half')
    local extractor_valve_open = GET_CHILD_RECURSIVELY(frame, 'extractor_valve_open')
    extractor_valve_close:SetAlpha(100)
    extractor_valve_half:SetAlpha(0)
    extractor_valve_open:SetAlpha(0)

    local extractor_funnel_1 = GET_CHILD_RECURSIVELY(frame, 'extractor_funnel_1')
    local extractor_funnel_2 = GET_CHILD_RECURSIVELY(frame, 'extractor_funnel_2')
    local extractor_funnel_3 = GET_CHILD_RECURSIVELY(frame, 'extractor_funnel_3')
    local extractor_funnel_4 = GET_CHILD_RECURSIVELY(frame, 'extractor_funnel_4')
    local extractor_funnel_5 = GET_CHILD_RECURSIVELY(frame, 'extractor_funnel_5')
    local extractor_funnel_6 = GET_CHILD_RECURSIVELY(frame, 'extractor_funnel_6')
    local extractor_funnel_7 = GET_CHILD_RECURSIVELY(frame, 'extractor_funnel_7')
    extractor_funnel_1:SetAlpha(100)
    extractor_funnel_2:SetAlpha(0)
    extractor_funnel_3:SetAlpha(0)
    extractor_funnel_4:SetAlpha(0)
    extractor_funnel_5:SetAlpha(0)
    extractor_funnel_6:SetAlpha(0)
    extractor_funnel_7:SetAlpha(0)

    local extractor_funnel_1_1 = GET_CHILD_RECURSIVELY(frame, 'extractor_funnel_1_1')
    local extractor_funnel_1_2 = GET_CHILD_RECURSIVELY(frame, 'extractor_funnel_1_2')
    local extractor_funnel_2_1 = GET_CHILD_RECURSIVELY(frame, 'extractor_funnel_2_1')
    local extractor_funnel_3_1 = GET_CHILD_RECURSIVELY(frame, 'extractor_funnel_3_1')
    local extractor_funnel_4_1 = GET_CHILD_RECURSIVELY(frame, 'extractor_funnel_4_1')
    local extractor_funnel_5_1 = GET_CHILD_RECURSIVELY(frame, 'extractor_funnel_5_1')
    local extractor_funnel_6_1 = GET_CHILD_RECURSIVELY(frame, 'extractor_funnel_6_1')
    local extractor_funnel_7_1 = GET_CHILD_RECURSIVELY(frame, 'extractor_funnel_7_1')
    extractor_funnel_1_1:SetAlpha(0)
    extractor_funnel_1_2:SetAlpha(0)
    extractor_funnel_2_1:SetAlpha(0)
    extractor_funnel_3_1:SetAlpha(0)
    extractor_funnel_4_1:SetAlpha(0)
    extractor_funnel_5_1:SetAlpha(0)
    extractor_funnel_6_1:SetAlpha(0)
    extractor_funnel_7_1:SetAlpha(0)

    local extractor_filter_2 = GET_CHILD_RECURSIVELY(frame, 'extractor_filter_2')
    local extractor_filter_3 = GET_CHILD_RECURSIVELY(frame, 'extractor_filter_3')
    local extractor_filter_4 = GET_CHILD_RECURSIVELY(frame, 'extractor_filter_4')
    extractor_filter_2:SetAlpha(0)
    extractor_filter_3:SetAlpha(0)
    extractor_filter_4:SetAlpha(0)

    local extractor_pipe_1 = GET_CHILD_RECURSIVELY(frame, 'extractor_pipe_1')
    local extractor_pipe_2 = GET_CHILD_RECURSIVELY(frame, 'extractor_pipe_2')
    local extractor_pipe_3 = GET_CHILD_RECURSIVELY(frame, 'extractor_pipe_3')
    local extractor_pipe_4 = GET_CHILD_RECURSIVELY(frame, 'extractor_pipe_4')
    local extractor_pipe_5 = GET_CHILD_RECURSIVELY(frame, 'extractor_pipe_5')
    extractor_pipe_1:SetAlpha(0)
    extractor_pipe_2:SetAlpha(0)
    extractor_pipe_3:SetAlpha(0)
    extractor_pipe_4:SetAlpha(0)
    extractor_pipe_5:SetAlpha(0)

    local extractor_pipe_1_1 = GET_CHILD_RECURSIVELY(frame, 'extractor_pipe_1_1')
    local extractor_pipe_2_1 = GET_CHILD_RECURSIVELY(frame, 'extractor_pipe_2_1')
    local extractor_pipe_3_1 = GET_CHILD_RECURSIVELY(frame, 'extractor_pipe_3_1')
    local extractor_pipe_3_2 = GET_CHILD_RECURSIVELY(frame, 'extractor_pipe_3_2')
    local extractor_pipe_4_1 = GET_CHILD_RECURSIVELY(frame, 'extractor_pipe_4_1')
    local extractor_pipe_4_2 = GET_CHILD_RECURSIVELY(frame, 'extractor_pipe_4_2')
    local extractor_pipe_5_1 = GET_CHILD_RECURSIVELY(frame, 'extractor_pipe_5_1')
    local extractor_pipe_5_2 = GET_CHILD_RECURSIVELY(frame, 'extractor_pipe_5_2')
    extractor_pipe_1_1:SetAlpha(0)
    extractor_pipe_2_1:SetAlpha(0)
    extractor_pipe_3_1:SetAlpha(0)
    extractor_pipe_3_2:SetAlpha(0)
    extractor_pipe_4_1:SetAlpha(0)
    extractor_pipe_4_2:SetAlpha(0)
    extractor_pipe_5_1:SetAlpha(0)
    extractor_pipe_5_2:SetAlpha(0)

    local extractor_flask_1 = GET_CHILD_RECURSIVELY(frame, 'extractor_flask_1')
    local extractor_flask_2 = GET_CHILD_RECURSIVELY(frame, 'extractor_flask_2')
    local extractor_flask_3 = GET_CHILD_RECURSIVELY(frame, 'extractor_flask_3')
    extractor_flask_1:SetAlpha(0)
    extractor_flask_2:SetAlpha(0)
    extractor_flask_3:SetAlpha(0)
end

function PHARMACY_UI_EXTRACTOR_START()
    local frame = ui.GetFrame('pharmacy_ui')
    local extractor_valve_close = GET_CHILD_RECURSIVELY(frame, 'extractor_valve_close')
    local extractor_valve_half = GET_CHILD_RECURSIVELY(frame, 'extractor_valve_half')
    local extractor_valve_open = GET_CHILD_RECURSIVELY(frame, 'extractor_valve_open')

    extractor_valve_close:SetAlpha(100)
    extractor_valve_half:SetAlpha(0)
    extractor_valve_open:SetAlpha(0)

    local sound_name = frame:GetUserConfig('EXTRACTOR_RUN_SOUND')
    local sound_scp = string.format('PHARMACY_UI_PLAY_SOUND(\'%s\')', sound_name)
	ReserveScript(sound_scp, 0.01)

    frame:RunUpdateScript('PHARAMCY_UI_EXRACTOR_RUN', 0, 0, 0, 1)
end

function PHARAMCY_UI_EXRACTOR_RUN(frame, elapsedTime)
    local cur_time = elapsedTime
    local valve_time = shared_item_pharmacy.get_valve_speed()
    local fluid_time = shared_item_pharmacy.get_fluid_speed()
    local part_time = fluid_time * 2 / 3
    local start_term = fluid_time / 9

    PHARMACY_UI_EXTRACTOR_VALVE_RUN(frame, cur_time, valve_time)

    cur_time = cur_time - valve_time
    PHARMACY_UI_EXTRACTOR_FUNNEL_RUN(frame, cur_time, part_time, start_term)

    cur_time = cur_time - start_term
    PHARMACY_UI_EXTRACTOR_FILTER_RUN(frame, cur_time, part_time, start_term)

    cur_time = cur_time - start_term
    PHARMACY_UI_EXTRACTOR_PIPE_RUN(frame, cur_time, part_time, start_term)

    cur_time = cur_time - start_term
    PHARMACY_UI_EXTRACTOR_FLASK_RUN(frame, cur_time, part_time)

    if elapsedTime >= valve_time + fluid_time then
        ReserveScript('PHARMACY_UI_REWARD_POPUP()', 0.5)
        return 0
    else
        return 1
    end
end

function PHARMACY_UI_EXTRACTOR_VALVE_RUN(frame, elapsedTime, total_time)
    local term = total_time / 2
    local q, r = math.modf(elapsedTime / term)
    local alpha = r * 100
    if alpha < 0 then
        alpha = 0
    elseif alpha > 100 then
        alpha = 100
    end

    local extractor_valve_close = GET_CHILD_RECURSIVELY(frame, 'extractor_valve_close')
    local extractor_valve_half = GET_CHILD_RECURSIVELY(frame, 'extractor_valve_half')
    local extractor_valve_open = GET_CHILD_RECURSIVELY(frame, 'extractor_valve_open')

    if q == 1 then
        extractor_valve_half:SetAlpha(100 - alpha)
        extractor_valve_open:SetAlpha(alpha)
    elseif q == 0 then
        extractor_valve_close:SetAlpha(100 - alpha)
        extractor_valve_half:SetAlpha(alpha)
    end
end

function PHARMACY_UI_EXTRACTOR_FUNNEL_RUN(frame, elapsedTime, total_time, start_term)
    if elapsedTime < 0 or elapsedTime > total_time + start_term then return end

    local extractor_funnel_1 = GET_CHILD_RECURSIVELY(frame, 'extractor_funnel_1')
    local extractor_funnel_2 = GET_CHILD_RECURSIVELY(frame, 'extractor_funnel_2')
    local extractor_funnel_3 = GET_CHILD_RECURSIVELY(frame, 'extractor_funnel_3')
    local extractor_funnel_4 = GET_CHILD_RECURSIVELY(frame, 'extractor_funnel_4')
    local extractor_funnel_5 = GET_CHILD_RECURSIVELY(frame, 'extractor_funnel_5')
    local extractor_funnel_6 = GET_CHILD_RECURSIVELY(frame, 'extractor_funnel_6')
    local extractor_funnel_7 = GET_CHILD_RECURSIVELY(frame, 'extractor_funnel_7')

    local extractor_funnel_1_1 = GET_CHILD_RECURSIVELY(frame, 'extractor_funnel_1_1')
    local extractor_funnel_1_2 = GET_CHILD_RECURSIVELY(frame, 'extractor_funnel_1_2')
    local extractor_funnel_2_1 = GET_CHILD_RECURSIVELY(frame, 'extractor_funnel_2_1')
    local extractor_funnel_3_1 = GET_CHILD_RECURSIVELY(frame, 'extractor_funnel_3_1')
    local extractor_funnel_4_1 = GET_CHILD_RECURSIVELY(frame, 'extractor_funnel_4_1')
    local extractor_funnel_5_1 = GET_CHILD_RECURSIVELY(frame, 'extractor_funnel_5_1')
    local extractor_funnel_6_1 = GET_CHILD_RECURSIVELY(frame, 'extractor_funnel_6_1')
    local extractor_funnel_7_1 = GET_CHILD_RECURSIVELY(frame, 'extractor_funnel_7_1')

    if elapsedTime >= total_time then
        local alpha = ((total_time + start_term - elapsedTime) / (total_time + start_term)) * 100
        extractor_funnel_1_1:SetAlpha(alpha)
        return
    end

    local term = total_time / 7
    local q, r = math.modf(elapsedTime / term)
    local alpha = r * 100
    if alpha < 0 then
        alpha = 0
    elseif alpha > 100 then
        alpha = 100
    end
    
    local drop_term = 1 / 8
    local drop_q, drop_r = math.modf(r / drop_term)
    local drop_alpha = drop_r * 100

    if q == 6 then
        extractor_funnel_7:SetAlpha(100 - alpha)
    elseif q == 5 then
        extractor_funnel_6:SetAlpha(100 - alpha)
        extractor_funnel_7:SetAlpha(alpha)
    elseif q == 4 then
        extractor_funnel_5:SetAlpha(100 - alpha)
        extractor_funnel_6:SetAlpha(alpha)
    elseif q == 3 then
        extractor_funnel_4:SetAlpha(100 - alpha)
        extractor_funnel_5:SetAlpha(alpha)
    elseif q == 2 then
        extractor_funnel_3:SetAlpha(100 - alpha)
        extractor_funnel_4:SetAlpha(alpha)
    elseif q == 1 then
        extractor_funnel_2:SetAlpha(100 - alpha)
        extractor_funnel_3:SetAlpha(alpha)
    elseif q == 0 then
        extractor_funnel_1:SetAlpha(100 - alpha)
        extractor_funnel_2:SetAlpha(alpha)
    end

    if drop_q == 7 then
        extractor_funnel_7_1:SetAlpha(100 - drop_alpha)
        extractor_funnel_1_1:SetAlpha(drop_alpha)
    elseif drop_q == 6 then
        extractor_funnel_6_1:SetAlpha(100 - drop_alpha)
        extractor_funnel_7_1:SetAlpha(drop_alpha)
    elseif drop_q == 5 then
        extractor_funnel_5_1:SetAlpha(100 - drop_alpha)
        extractor_funnel_6_1:SetAlpha(drop_alpha)
    elseif drop_q == 4 then
        extractor_funnel_4_1:SetAlpha(100 - drop_alpha)
        extractor_funnel_5_1:SetAlpha(drop_alpha)
    elseif drop_q == 3 then
        extractor_funnel_3_1:SetAlpha(100 - drop_alpha)
        extractor_funnel_4_1:SetAlpha(drop_alpha)
    elseif drop_q == 2 then
        extractor_funnel_2_1:SetAlpha(100 - drop_alpha)
        extractor_funnel_3_1:SetAlpha(drop_alpha)
    elseif drop_q == 1 then
        extractor_funnel_1_2:SetAlpha(100 - drop_alpha)
        extractor_funnel_2_1:SetAlpha(drop_alpha)
    elseif drop_q == 0 then
        extractor_funnel_1_1:SetAlpha(100 - drop_alpha)
        extractor_funnel_1_2:SetAlpha(drop_alpha)
    end
end

function PHARMACY_UI_EXTRACTOR_FILTER_RUN(frame, elapsedTime, total_time, start_term)
    if elapsedTime < 0 or elapsedTime >= total_time + start_term then return end

    local extractor_filter_2 = GET_CHILD_RECURSIVELY(frame, 'extractor_filter_2')
    local extractor_filter_3 = GET_CHILD_RECURSIVELY(frame, 'extractor_filter_3')
    local extractor_filter_4 = GET_CHILD_RECURSIVELY(frame, 'extractor_filter_4')

    -- if elapsedTime >= total_time then
    --     local alpha = ((total_time + start_term - elapsedTime) / (total_time + start_term)) * 100
    --     extractor_filter_2:SetAlpha(alpha)
    --     extractor_filter_3:SetAlpha(alpha)
    --     extractor_filter_4:SetAlpha(alpha)
    --     return
    -- end

    local term = total_time / 9
    local q, r = math.modf(elapsedTime / term)
    local alpha = r * 100
    if alpha < 0 then
        alpha = 0
    elseif alpha > 100 then
        alpha = 100
    end

    if q == 2 then
        extractor_filter_4:SetAlpha(alpha)
    elseif q == 1 then
        extractor_filter_3:SetAlpha(alpha)
    elseif q == 0 then
        extractor_filter_2:SetAlpha(alpha)
    end
end

function PHARMACY_UI_EXTRACTOR_PIPE_RUN(frame, elapsedTime, total_time, start_term)
    if elapsedTime < 0 or elapsedTime >= total_time + start_term then return end

    local inner_start_term = start_term / 3
    local inner_total_time = total_time - inner_start_term * 2

    PHARMACY_UI_EXTRACTOR_PIPE_TOP_RUN(frame, elapsedTime, inner_total_time, inner_start_term)

    elapsedTime = elapsedTime - inner_start_term
    PHARMACY_UI_EXTRACTOR_PIPE_BODY_RUN(frame, elapsedTime, inner_total_time, inner_start_term)

    elapsedTime = elapsedTime - inner_start_term
    PHARMACY_UI_EXTRACTOR_PIPE_BOTTOM_RUN(frame, elapsedTime, inner_total_time, inner_start_term)
end

function PHARMACY_UI_EXTRACTOR_PIPE_TOP_RUN(frame, elapsedTime, total_time, start_term)
    if elapsedTime < 0 or elapsedTime >= total_time + start_term then return end

    local extractor_pipe_1 = GET_CHILD_RECURSIVELY(frame, 'extractor_pipe_1')
    local extractor_pipe_2 = GET_CHILD_RECURSIVELY(frame, 'extractor_pipe_2')
    local extractor_pipe_3 = GET_CHILD_RECURSIVELY(frame, 'extractor_pipe_3')
    local extractor_pipe_4 = GET_CHILD_RECURSIVELY(frame, 'extractor_pipe_4')

    if elapsedTime >= total_time then
        local alpha = ((total_time + start_term - elapsedTime) / (total_time + start_term)) * 100
        extractor_pipe_1:SetAlpha(alpha)
        extractor_pipe_2:SetAlpha(alpha)
        extractor_pipe_3:SetAlpha(alpha)
        extractor_pipe_4:SetAlpha(alpha)
        return
    end

    local frame_count = 4
    local update_count = 2
    local term = total_time / (frame_count * update_count)
    local q, r = math.modf(elapsedTime / term)
    local alpha = r * 100
    if alpha < 0 then
        alpha = 0
    elseif alpha > 100 then
        alpha = 100
end

    if q == 3 or q == 7 then
        extractor_pipe_3:SetAlpha(alpha)
        extractor_pipe_4:SetAlpha(100 - alpha)
    elseif q == 2 or q == 6 then
        extractor_pipe_2:SetAlpha(alpha)
        extractor_pipe_3:SetAlpha(100 - alpha)
    elseif q == 1 or q == 5 then
        extractor_pipe_1:SetAlpha(alpha)
        extractor_pipe_2:SetAlpha(100 - alpha)
    elseif q == 4 then
        extractor_pipe_1:SetAlpha(alpha)
        extractor_pipe_2:SetAlpha(100 - alpha)
    elseif q == 0 then
        extractor_pipe_1:SetAlpha(alpha)
    end
end

function PHARMACY_UI_EXTRACTOR_PIPE_BODY_RUN(frame, elapsedTime, total_time, start_term)
    if elapsedTime < 0 or elapsedTime >= total_time + start_term then return end
    
    -- start
    local extractor_pipe_1_1 = GET_CHILD_RECURSIVELY(frame, 'extractor_pipe_1_1')
    local extractor_pipe_2_1 = GET_CHILD_RECURSIVELY(frame, 'extractor_pipe_2_1')
    -- filled
    local extractor_pipe_3_1 = GET_CHILD_RECURSIVELY(frame, 'extractor_pipe_3_1')
    local extractor_pipe_4_1 = GET_CHILD_RECURSIVELY(frame, 'extractor_pipe_4_1')
    -- end
    local extractor_pipe_5 = GET_CHILD_RECURSIVELY(frame, 'extractor_pipe_5')

    if elapsedTime >= total_time then
        local time_left = total_time + start_term - elapsedTime
        local q, r = math.modf(time_left * 2 / start_term)
        local alpha = r * 100
        if alpha < 0 then
            alpha = 0
        elseif alpha > 100 then
            alpha = 100
        end

        if q == 1 then
            extractor_pipe_5:SetAlpha(alpha)
        elseif q == 0 then
            extractor_pipe_1_1:SetAlpha(alpha)
            extractor_pipe_2_1:SetAlpha(alpha)
            extractor_pipe_3_1:SetAlpha(alpha)
            extractor_pipe_4_1:SetAlpha(alpha)
        end
        return
    end
    
    if elapsedTime < start_term then
        local q, r = math.modf(elapsedTime * 2 / start_term)
        local alpha = r * 100
        if alpha < 0 then
            alpha = 0
        elseif alpha > 100 then
            alpha = 100
        end
    
        if q == 1 then
            extractor_pipe_2_1:SetAlpha(alpha)
        elseif q == 0 then
            extractor_pipe_1_1:SetAlpha(alpha)
        end
    else
        local frame_count = 2
        local update_count = 4
        local term = (total_time - start_term) / (frame_count * update_count)
        local q, r = math.modf((elapsedTime - start_term) / term)
        local alpha = r * 100
        if alpha < 0 then
            alpha = 0
        elseif alpha > 100 then
            alpha = 100
        end
    
        if q == 0 then
            extractor_pipe_3_1:SetAlpha(alpha)
        elseif q % frame_count == 1 then
            extractor_pipe_3_1:SetAlpha(100 - alpha)
            extractor_pipe_4_1:SetAlpha(alpha)
        elseif q % frame_count == 0 then
            extractor_pipe_3_1:SetAlpha(alpha)
            extractor_pipe_4_1:SetAlpha(100 - alpha)
        end
    end
    end

function PHARMACY_UI_EXTRACTOR_PIPE_BOTTOM_RUN(frame, elapsedTime, total_time, start_term)
    if elapsedTime < 0 or elapsedTime >= total_time + start_term then return end

    local extractor_pipe_5_1 = GET_CHILD_RECURSIVELY(frame, 'extractor_pipe_5_1')
    local extractor_pipe_3_2 = GET_CHILD_RECURSIVELY(frame, 'extractor_pipe_3_2')
    local extractor_pipe_4_2 = GET_CHILD_RECURSIVELY(frame, 'extractor_pipe_4_2')
    local extractor_pipe_5_2 = GET_CHILD_RECURSIVELY(frame, 'extractor_pipe_5_2')

    if elapsedTime >= total_time then
        local time_left = total_time + start_term - elapsedTime
        local q, r = math.modf(time_left * 2 / start_term)
        local alpha = r * 100
        if alpha < 0 then
            alpha = 0
        elseif alpha > 100 then
            alpha = 100
        end
    
        if q == 1 then
            extractor_pipe_5_1:SetAlpha(0)
            extractor_pipe_5_2:SetAlpha(alpha)
        elseif q == 0 then
            extractor_pipe_3_2:SetAlpha(0)
            extractor_pipe_4_2:SetAlpha(0)
            extractor_pipe_5_1:SetAlpha(alpha)
        end
        return
    end
    
    if elapsedTime < start_term then
        local q, r = math.modf(elapsedTime * 2 / start_term)
        local alpha = r * 100
        if alpha < 0 then
            alpha = 0
        elseif alpha > 100 then
            alpha = 100
        end

        if q == 1 then
            extractor_pipe_5_2:SetAlpha(alpha)
        elseif q == 0 then
            extractor_pipe_5_1:SetAlpha(alpha)
        end
    else
        local frame_count = 3
        local update_count = 2
        local term = (total_time - start_term) / (frame_count * update_count)
        local q, r = math.modf((elapsedTime - start_term) / term)
        local alpha = r * 100
        if alpha < 0 then
            alpha = 0
        elseif alpha > 100 then
            alpha = 100
        end
    
        if q % frame_count == 2 then
            extractor_pipe_3_2:SetAlpha(100 - alpha)
            extractor_pipe_5_1:SetAlpha(alpha)
            extractor_pipe_5_2:SetAlpha(alpha)
        elseif q % frame_count == 1 then
            extractor_pipe_3_2:SetAlpha(100 - alpha)
            extractor_pipe_4_2:SetAlpha(alpha)
        elseif q % frame_count == 0 then
            extractor_pipe_3_2:SetAlpha(alpha)
            extractor_pipe_5_1:SetAlpha(100 - alpha)
            extractor_pipe_5_2:SetAlpha(100 - alpha)
        end
    end
end

function PHARMACY_UI_EXTRACTOR_FLASK_RUN(frame, elapsedTime, total_time)
    if elapsedTime < 0 or elapsedTime > total_time then return end

    local term = total_time / 3
    local q, r = math.modf(elapsedTime / term)
    local alpha = r * 100
    if alpha < 0 then
        alpha = 0
    elseif alpha > 100 then
        alpha = 100
    end

    local extractor_flask_1 = GET_CHILD_RECURSIVELY(frame, 'extractor_flask_1')
    local extractor_flask_2 = GET_CHILD_RECURSIVELY(frame, 'extractor_flask_2')
    local extractor_flask_3 = GET_CHILD_RECURSIVELY(frame, 'extractor_flask_3')
    if q == 2 then
        extractor_flask_3:SetAlpha(alpha)
        extractor_flask_2:SetAlpha(100 - alpha)
    elseif q == 1 then
        extractor_flask_2:SetAlpha(alpha)
        extractor_flask_1:SetAlpha(100 - alpha)
    elseif q == 0 then
        extractor_flask_1:SetAlpha(alpha)
    end
end
-- end of extractor

function PHARMACY_UI_REWARD_POPUP()
    local frame = ui.GetFrame('pharmacy_ui')
    PHARMACY_UI_HOLD_ACTION(frame, 1)
    local reward_name = frame:GetUserValue('REWARD_NAME')
    local reward_count = frame:GetUserIValue('REWARD_COUNT')
    PHARMACY_EXTRACT_FULLDARK_UI_OPEN(reward_name, reward_count)

    local tuto_prop = frame:GetUserValue('TUTO_PROP')
    local tuto_step = GetUITutoProg(tuto_prop)
    if tuto_step == 15 then
        pc.ReqExecuteTx('SCR_UI_TUTORIAL_NEXT_STEP', tuto_prop)
    end
end

function PHARMACY_UI_EXTRACTOR_COMPLETE()
    local frame = ui.GetFrame('pharmacy_ui')
    local recipe_guid = frame:GetUserValue('RECIPE_GUID')
    local recipe_item = session.GetInvItemByGuid(recipe_guid)
    if recipe_item == nil then
        ui.CloseFrame('pharmacy_ui')
        return
    end

    local all_reward_get = true
    local recipe_obj = GetIES(recipe_item:GetObject())
    local enable_goal, max_goal = shared_item_pharmacy.get_remain_goal_count(recipe_obj)
    if enable_goal == 0 then
        ui.SysMsg(ClMsg('AllRecipeRewardGain'))
        ui.CloseFrame('pharmacy_ui')
        return
    end

    PHARMACY_UI_EXTRACTOR_INITIALIZE(frame)
    PHARMACY_UI_SET_CURRENT_POS(frame)
    PHARMACY_UI_SET_MATERIAL_LIST(frame)
    PHARMACY_UI_MAT_SLOT_CLEAR(frame)
    PHARMACY_UI_CLEAR_PATH(frame)
    PHARMACY_UI_SET_GOAL_AND_HURDLE(frame)
    PHARMACY_UI_SET_COUNT_BOX(frame)
end

function PHARMACY_UI_PLAY_SOUND(sound_name)
    imcSound.PlaySoundEvent(sound_name)
end

function PHARMACY_UI_TUTORIAL_CHECK(frame, msg, arg_str, arg_num)
	if frame == nil or frame:IsVisible() == 0 then return end

    if arg_num == 100 then
        TUTORIAL_TEXT_CLOSE(frame)
        return
    end

	local open_flag = false
	if msg == nil then
		open_flag = true
	end

    PHARMACY_UI_SET_MATERIAL_LIST(frame)
    PHARMACY_UI_SET_NEUTRALIZER_LIST(frame)

	PHARMACY_TUTORIAL_OPEN(frame, open_flag)
end

function PHARMACY_UI_TUTORIAL_END_CLOSE()
    ui.CloseFrame('pharmacy_ui')
end

function PHARMACY_TUTORIAL_OPEN(frame, open_flag)
	local prop_name = "UITUTO_PHARMACY"
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
    local right_force = TryGetProp(tuto_cls, 'Control_Right_Force', 'NO')
    local skip_btn = TryGetProp(tuto_cls, 'Skip_Btn', 'None')
    local next_btn = TryGetProp(tuto_cls, 'Next_Btn', 'None')
	local ctrl = GET_CHILD_RECURSIVELY(frame, ctrl_name)
	if ctrl == nil then return end

    if tuto_step == 0 or tuto_step == 9 or tuto_step == 11 or tuto_step == 14 then
        -- 합성 재료 탭 이동
        local mat_tab = GET_CHILD_RECURSIVELY(frame, "mat_tab")
        if mat_tab ~= nil then
            local tab_index = mat_tab:GetIndexByName("tab_material")
            if tab_index ~= -1 then
                mat_tab:SelectTab(tab_index)
            end
        end
    elseif tuto_step == 13 then
        -- 중화제 탭 이동
        local mat_tab = GET_CHILD_RECURSIVELY(frame, "mat_tab")
        if mat_tab ~= nil then
            local tab_index = mat_tab:GetIndexByName("tab_neutralizer")
            if tab_index ~= -1 then
                mat_tab:SelectTab(tab_index)
            end
        end
    end

	TUTORIAL_TEXT_OPEN(ctrl, title, text, prop_name, right_force, skip_btn, next_btn, 'PHARMACY_UI_TUTORIAL_END_CLOSE')
end

function PHARMACY_UI_HELP_POP(frame)
	help.RequestAddHelp('TUTO_PHARMACY_1')
end