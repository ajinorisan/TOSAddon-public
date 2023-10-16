-- 각인
function GODDESS_MGR_RANDOMOPTION_CLEAR(frame)
    local randomoption_tab = GET_CHILD_RECURSIVELY(frame, 'randomoption_tab')
    randomoption_tab:SelectTab(0)
    GODDESS_MGR_RANDOMOPTION_PRESET_UPDATE(frame)
end

function CLEAR_GODDESS_ICOR_TEXT(frame)
    local text = GET_CHILD_RECURSIVELY(frame, 'goddess_icor_spot_text')
    if text ~= nil then
        text:ShowWindow(0)
    end
    local list = GET_CHILD_RECURSIVELY(frame, 'goddess_icor_spot_list')
    if list ~= nil then
        list:ShowWindow(0)
    end
end

function SHOW_GODDESS_ICOR_TEXT(frame)
    local text = GET_CHILD_RECURSIVELY(frame, 'goddess_icor_spot_text')
    if text ~= nil then
        text:ShowWindow(1)
    end
    local list = GET_CHILD_RECURSIVELY(frame, 'goddess_icor_spot_list')
    if list ~= nil then
        list:ShowWindow(1)
    end
end

local function _GODDESS_MGR_RANDOMOPTION_GET_PAGE_NAME(index)
    local pc_etc = GetMyEtcObject()
    local acc = GetMyAccountObj()
    if pc_etc == nil or acc == nil then
        return nil
    end

    local page_max = GET_MAX_ENGARVE_SLOT_COUNT(acc)
    if index > page_max then
        return nil
    end

    local page_name = TryGetProp(pc_etc, 'RandomOptionPresetName_' .. index, 'None')
    if page_name == 'None' then
        return ScpArgMsg('EngravePageNumber{index}', 'index', index)
    else
        return page_name
    end
end

function _GODDESS_MGR_MAKE_RANDOM_OPTION_TEXT(gBox, item_obj, option_list)
    local tooltip_equip_property_CSet = gBox:CreateOrGetControlSet('tooltip_equip_property_narrow',
        'tooltip_equip_property_narrow', 0, 0)
    local labelline = GET_CHILD_RECURSIVELY(tooltip_equip_property_CSet, 'labelline')
    labelline:ShowWindow(0)
    local property_gbox = GET_CHILD(tooltip_equip_property_CSet, 'property_gbox', 'ui::CGroupBox')

    tooltip_equip_property_CSet:Resize(gBox:GetWidth(), tooltip_equip_property_CSet:GetHeight())
    property_gbox:Resize(gBox:GetWidth() + 5, property_gbox:GetHeight())

    local inner_yPos = 0
    if item_obj == nil then
        if option_list == nil then
            return
        end

        item_obj = option_list
    end

    for i = 1, MAX_RANDOM_OPTION_COUNT do
        local group_name = 'RandomOptionGroup_' .. i
        local prop_name = 'RandomOption_' .. i
        local prop_value = 'RandomOptionValue_' .. i
        local clmsg = 'None'

        if item_obj[group_name] == 'ATK' then
            clmsg = 'ItemRandomOptionGroupATK'
        elseif item_obj[group_name] == 'DEF' then
            clmsg = 'ItemRandomOptionGroupDEF'
        elseif item_obj[group_name] == 'UTIL_WEAPON' then
            clmsg = 'ItemRandomOptionGroupUTIL'
        elseif item_obj[group_name] == 'UTIL_ARMOR' then
            clmsg = 'ItemRandomOptionGroupUTIL'
        elseif item_obj[group_name] == 'UTIL_SHILED' then
            clmsg = 'ItemRandomOptionGroupUTIL'
        elseif item_obj[group_name] == 'STAT' then
            clmsg = 'ItemRandomOptionGroupSTAT'
        elseif item_obj[group_name] == 'SPECIAL' then
            clmsg = 'ItemRandomOptionGroupSPECIAL'
        end

        local _value = item_obj[prop_value]
        local _name = item_obj[prop_name]
        if _value ~= nil and _value ~= 0 and _name ~= nil and _name ~= 'None' then
            local font = ''
            local font_end = ''
            if option_list ~= nil then
                if option_list['is_goddess_option'] >= 1 then
                    font = '{@st47}{s15}{#00EEEE}'
                    font_end = '{/}{/}{/}'
                end
            end
            local op_name = string.format('%s %s', ClMsg(clmsg), font .. ScpArgMsg(item_obj[prop_name]) .. font_end)
            local str_info = ABILITY_DESC_NO_PLUS(op_name, item_obj[prop_value], 0)
            inner_yPos = ADD_ITEM_PROPERTY_TEXT_NARROW(property_gbox, str_info, 0, inner_yPos)
        end
    end

    tooltip_equip_property_CSet:Resize(tooltip_equip_property_CSet:GetWidth(), tooltip_equip_property_CSet:GetHeight() +
        property_gbox:GetHeight() + property_gbox:GetY())
    gBox:Resize(gBox:GetWidth(), tooltip_equip_property_CSet:GetHeight())
end

function GODDESS_MGR_PREMIUM_REMAIN_TIME_UPDATE(ctrl)
    local elapsed_sec = imcTime.GetAppTime() - ctrl:GetUserIValue('STARTSEC')
    local start_sec = ctrl:GetUserIValue('REMAINSEC')
    start_sec = start_sec - elapsed_sec
    if 0 > start_sec then
        ctrl:SetTextByKey('value', '')
        return 0
    end

    local time_str = GET_TIME_TXT(start_sec)
    ctrl:SetTextByKey('value', time_str)

    return 1
end

function GODDESS_MGR_RANDOMOPTION_OPEN(frame)
    GODDESS_MGR_RANDOMOPTION_CLEAR(frame)
    GODDESS_MGR_RANDOMOPTION_ENGRAVE_ICOR_OPEN(frame)

    local acc = GetMyAccountObj()
    if acc == nil then
        return
    end

    local premium_remaintime = GET_CHILD_RECURSIVELY(frame, 'premium_remaintime')
    local remain_time = GET_REMAIN_SECOND_ENGRAVE_SLOT_EXTENSION_TIME(acc)
    if 0 < remain_time then
        premium_remaintime:SetUserValue('REMAINSEC', remain_time)
        premium_remaintime:SetUserValue('STARTSEC', imcTime.GetAppTime())
        premium_remaintime:RunUpdateScript('GODDESS_MGR_PREMIUM_REMAIN_TIME_UPDATE')
        premium_remaintime:ShowWindow(1)
    else
        premium_remaintime:StopUpdateScript('GODDESS_MGR_PREMIUM_REMAIN_TIME_UPDATE')
        premium_remaintime:ShowWindow(0)
    end
end

function GODDESS_MGR_RANDOMOPTION_PRESET_SELECT(parent, ctrl)
    local frame = parent:GetTopParentFrame()
    local index = ctrl:GetSelItemKey()
    local randomoption_bg = GET_CHILD_RECURSIVELY(frame, 'randomoption_bg')
    randomoption_bg:SetUserValue('PRESET_INDEX', index)

    local randomoption_tab = GET_CHILD_RECURSIVELY(frame, 'randomoption_tab')
    local index = randomoption_tab:GetSelectItemIndex()
    if index == 0 then
        GODDESS_MGR_RANDOMOPTION_ENGRAVE_ICOR_UPDATE(frame) -- 각인 저장(아이커)
    elseif index == 1 then
        GODDESS_MGR_RANDOMOPTION_APPLY_OPEN(frame) -- 각인 부여
    elseif index == 2 then
        GODDESS_MGR_RANDOMOPTION_ENGRAVE_OPEN(frame) -- 각인 저장(옛날)
    end
end

function GODDESS_MGR_RANDOMOPTION_PRESET_UPDATE(frame)
    local rand_preset_list = GET_CHILD_RECURSIVELY(frame, 'rand_preset_list')
    rand_preset_list:ClearItems()

    local acc_obj = GetMyAccountObj()
    if acc_obj == nil then
        return
    end

    local max_page = GET_MAX_ENGARVE_SLOT_COUNT(acc_obj)
    for i = 1, max_page do
        local page_name = _GODDESS_MGR_RANDOMOPTION_GET_PAGE_NAME(i)
        rand_preset_list:AddItem(tostring(i), page_name)
    end

    rand_preset_list:SelectItemByKey(0)
    GODDESS_MGR_RANDOMOPTION_PRESET_SELECT(frame, rand_preset_list)
end

function GODDESS_MGR_RANDOMOPTION_TAB_CHANGE(parent, tab)
    local frame = parent:GetTopParentFrame()

    local index = tab:GetSelectItemIndex()
    if index == 0 then
        CLEAR_GODDESS_ICOR_TEXT(frame)
        GODDESS_MGR_RANDOMOPTION_ENGRAVE_ICOR_OPEN(frame)
    elseif index == 1 then
        GODDESS_MGR_RANDOMOPTION_APPLY_OPEN(frame)
    elseif index == 2 then
        GODDESS_MGR_RANDOMOPTION_ENGRAVE_OPEN(frame) -- 각인 저장(옛날)
    end
end

function _CHECK_RANDOMOPTION_CHANGE_NAME_BTN()
    local frame = ui.GetFrame('goddess_equip_manager')
    local btn = GET_CHILD_RECURSIVELY(frame, 'change_preset_name')
    btn:SetEnable(1)
end

function _DISABLE_RANDOMOPTION_CHANGE_NAME_BTN()
    local frame = ui.GetFrame('goddess_equip_manager')
    local btn = GET_CHILD_RECURSIVELY(frame, 'change_preset_name')
    if btn ~= nil then
        ReserveScript('_CHECK_RANDOMOPTION_CHANGE_NAME_BTN()', 1)
        btn:SetEnable(0)
    end
end

function GODDESS_MGR_RANDOMOPTION_CHANGE_NAME(parent, ctrl)
    local frame = parent:GetTopParentFrame()
    local randomoption_bg = GET_CHILD_RECURSIVELY(frame, 'randomoption_bg')
    local index = randomoption_bg:GetUserIValue('PRESET_INDEX')
    local preset_name = _GODDESS_MGR_RANDOMOPTION_GET_PAGE_NAME(index)
    local newframe = ui.GetFrame('inputstring')
    newframe:SetUserValue('InputType', 'InputNameForChange')
    INPUT_STRING_BOX(ClMsg('ChangeAncientDefenseDeckTabName'), 'GODDESS_MGR_RANDOMOPTION_CHANGE_NAME_EXEC', preset_name,
        0, 16)
end

function GODDESS_MGR_RANDOMOPTION_CHANGE_NAME_EXEC(input_frame, ctrl)
    if ctrl:GetName() == 'inputstr' then
        input_frame = ctrl
    end

    local new_name = GET_INPUT_STRING_TXT(input_frame)

    local frame = ui.GetFrame('goddess_equip_manager')
    local randomoption_bg = GET_CHILD_RECURSIVELY(frame, 'randomoption_bg')
    local index = randomoption_bg:GetUserIValue('PRESET_INDEX')
    local preset_name = _GODDESS_MGR_RANDOMOPTION_GET_PAGE_NAME(index)
    if new_name == preset_name then
        ui.SysMsg(ClMsg('AlreadyorImpossibleName'))
        return
    end

    local name_str = TRIM_STRING_WITH_SPACING(new_name)
    if name_str == '' then
        ui.SysMsg(ClMsg('InvalidStringOrUnderMinLen'))
        return
    end

    local arg_str = index .. '/' .. new_name

    pc.ReqExecuteTx('SCR_ICOR_PRESET_CHANGE_NAME', arg_str)

    _DISABLE_RANDOMOPTION_CHANGE_NAME_BTN()

    input_frame:ShowWindow(0)
end

function ON_SUCCESS_RANDOMOPTION_CHANGE_NAME(frame, msg, arg_str, arg_num)
    GODDESS_MGR_RANDOMOPTION_PRESET_UPDATE(frame)
end

-- 각인 - 저장
-- 刻印・保存
function GODDESS_MGR_RANDOMOPTION_ENGRAVE_CLEAR(frame)
    local rand_ok_engrave = GET_CHILD_RECURSIVELY(frame, 'rand_ok_engrave')
    rand_ok_engrave:ShowWindow(0)

    local rand_do_engrave = GET_CHILD_RECURSIVELY(frame, 'rand_do_engrave')
    rand_do_engrave:ShowWindow(1)

    local rand_engrave_slot = GET_CHILD_RECURSIVELY(frame, 'rand_engrave_slot')
    rand_engrave_slot:ClearIcon()

    local rand_item_name = GET_CHILD_RECURSIVELY(frame, 'rand_item_name')
    rand_item_name:ShowWindow(0)
    rand_item_name:SetTextByKey('name', '')

    local rand_item_text = GET_CHILD_RECURSIVELY(frame, 'rand_item_text')
    rand_item_text:ShowWindow(1)

    local rand_equip_list = GET_CHILD_RECURSIVELY(frame, 'rand_equip_list')
    rand_equip_list:SetMargin(30, rand_item_text:GetMargin().top + rand_item_text:GetHeight() + 10, 0, 0)

    local rand_engrave_current_inner = GET_CHILD_RECURSIVELY(frame, 'rand_engrave_current_inner')
    rand_engrave_current_inner:RemoveChild('tooltip_equip_property_narrow')

    local rand_engrave_before_inner = GET_CHILD_RECURSIVELY(frame, 'rand_engrave_before_inner')
    rand_engrave_before_inner:RemoveChild('tooltip_equip_property_narrow')

    GODDESS_MGR_RANDOMOPTION_ENGRAVE_UPDATE(frame)
end

function GODDESS_MGR_RANDOMOPTION_ENGRAVE_SET_MATERIAL(frame)
    local rand_mat_list = GET_CHILD_RECURSIVELY(frame, 'rand_mat_list', 'ui::CSlotSet')
    rand_mat_list:ClearIconAll()

    local inv_item_list = session.GetInvItemList()
    FOR_EACH_INVENTORY(inv_item_list, function(inv_item_list, inv_item, slotset)
        local frame = slotset:GetTopParentFrame()
        local item_slot = GET_CHILD_RECURSIVELY(frame, 'rand_engrave_slot')
        local use_lv = item_slot:GetUserIValue('ITEM_USE_LEVEL')
        local obj = GetIES(inv_item:GetObject())
        local flag, rate = IS_ENGRAVE_MATERIAL_ITEM(obj, use_lv)
        if flag == true then
            local slotindex = imcSlot:GetEmptySlotIndex(slotset)
            local slot = slotset:GetSlotByIndex(slotindex)
            local icon = CreateIcon(slot)
            icon:Set(obj.Icon, 'Item', inv_item.type, slotindex, inv_item:GetIESID(), inv_item.count)
            slot:SetUserValue('ITEM_GUID', inv_item:GetIESID())
            slot:SetUserValue('ADD_RATE', rate)
            slot:SetMaxSelectCount(inv_item.count)
            local class = GetClassByType('Item', inv_item.type)
            SET_SLOT_ITEM_TEXT_USE_INVCOUNT(slot, inv_item, obj, inv_item.count)
            ICON_SET_INVENTORY_TOOLTIP(icon, inv_item, 'poisonpot', class)
        end
    end, false, rand_mat_list)

    GODDESS_MGR_RANDOMOPTION_ENGRAVE_MAT_UPDATE(frame)
end

function GODDESS_MGR_RANDOMOPTION_ENGRAVE_MAT_UPDATE(frame)
    local rand_engrave_slot = GET_CHILD_RECURSIVELY(frame, 'rand_engrave_slot')
    local def_rate = rand_engrave_slot:GetUserIValue('DEFAULT_RATE')

    local OFFSET_Y = 10
    local HEIGHT = 65
    local add_rate = 0
    local slotSet = GET_CHILD_RECURSIVELY(frame, 'rand_mat_list', 'ui::CSlotSet')
    local gbox = GET_CHILD_RECURSIVELY(frame, 'rand_mat_info_bg')
    gbox:RemoveAllChild()
    for i = 0, slotSet:GetSlotCount() - 1 do
        local slot = slotSet:GetSlotByIndex(i)
        local rate = tonumber(slot:GetUserValue('ADD_RATE'))
        if rate == nil then
            break
        end
        local cnt = slot:GetSelectCount()
        if cnt > 0 then
            add_rate = add_rate + (rate * cnt)
            if def_rate + add_rate > 100 then
                local adjust_cnt = math.ceil((def_rate + add_rate - 100) / rate)
                cnt = cnt - adjust_cnt
                slot:SetSelectCount(cnt)
                add_rate = add_rate - (rate * adjust_cnt)
            end

            if cnt > 0 then
                local info = slot:GetIcon():GetInfo()
                local ctrlSet = gbox:CreateOrGetControlSet('item_point_price', 'PRICE' .. info.type .. i, 10, OFFSET_Y)

                local itemSlot = GET_CHILD(ctrlSet, 'itemSlot')
                local icon = CreateIcon(itemSlot)
                icon:SetImage(info:GetImageName())

                local itemCount = GET_CHILD(itemSlot, 'itemCount')
                local cntText = string.format('{#ffe400}{ds}{ol}{b}{s18}%d', cnt)
                itemCount:SetText(cntText)

                local itemPrice = GET_CHILD(ctrlSet, 'itemPrice')
                local text = string.format('{s18}{ol}{b} X %d%% ={/} {#ec0000}+%d%%{/}{/}{/}', rate, rate * cnt)
                itemPrice:SetText(text)

                OFFSET_Y = OFFSET_Y + HEIGHT
            else
                slot:Select(0)
            end
        end
    end

    local total_rate = def_rate + add_rate

    local rand_probability_text = GET_CHILD_RECURSIVELY(frame, 'rand_probability_text')
    rand_probability_text:SetTextByKey('total', total_rate)
    rand_probability_text:SetTextByKey('default', def_rate)
    rand_probability_text:SetTextByKey('add', add_rate)

    local rand_do_engrave = GET_CHILD_RECURSIVELY(frame, 'rand_do_engrave')
    if total_rate <= 0 then
        rand_do_engrave:SetEnable(0)
    else
        rand_do_engrave:SetEnable(1)
    end
end

function GODDESS_MGR_RANDOMOPTION_ENGRAVE_SPOT_SELECT(parent, ctrl)
    local frame = parent:GetTopParentFrame()
    local spot = ctrl:GetSelItemKey()
    local inv_item = session.GetEquipItemBySpot(item.GetEquipSpotNum(spot))

    if inv_item ~= nil then
        local item_obj = GetIES(inv_item:GetObject())
        if IS_NO_EQUIPITEM(item_obj) == 0 then
            GODDESS_MGR_RANDOMOPTION_ENGRAVE_REG_ITEM(frame, inv_item, item_obj, spot)
        end
    end

    GODDESS_MGR_RANDOMOPTION_ENGRAVE_SET_MATERIAL(frame)
end

function SCR_LBTNDOWN_GODDESS_MGR_RANDOMOPTION_MAT(slotset, slot)
    local frame = slotset:GetTopParentFrame()
    ui.EnableSlotMultiSelect(1)
    GODDESS_MGR_RANDOMOPTION_ENGRAVE_MAT_UPDATE(frame)
end

function GODDESS_MGR_RANDOMOPTION_ENGRAVE_OPEN(frame) -- 각인 저장(옛날)-- 刻印保存(昔)
    local rand_equip_list = GET_CHILD_RECURSIVELY(frame, 'rand_equip_list')
    rand_equip_list:SelectItemByKey(0)
    GODDESS_MGR_RANDOMOPTION_ENGRAVE_SET_SPOT(frame)
    GODDESS_MGR_RANDOMOPTION_ENGRAVE_CLEAR(frame)
    INVENTORY_SET_CUSTOM_RBTNDOWN('None')

    local checkall = GET_CHILD_RECURSIVELY(frame, 'checkall')
    checkall:ShowWindow(0)
end

function GODDESS_MGR_RANDOMOPTION_ENGRAVE_SET_SPOT(frame) -- 각인 저장(옛날)	
    local rand_equip_list = GET_CHILD_RECURSIVELY(frame, 'rand_equip_list')
    rand_equip_list:ClearItems()

    for i = 1, #managed_slot_list do
        local slot_info = managed_slot_list[i]
        local inv_item = session.GetEquipItemBySpot(item.GetEquipSpotNum(slot_info.SlotName))
        local item_obj = GetIES(inv_item:GetObject())

        if IS_NO_EQUIPITEM(item_obj) == 0 and IS_ENABLE_TO_ENGARVE(item_obj, 2) == true then
            rand_equip_list:AddItem(slot_info.SlotName, ClMsg(slot_info.ClMsg))
        end
    end
end

function GODDESS_MGR_RANDOMOPTION_ENGRAVE_UPDATE(frame)
    local rand_equip_list = GET_CHILD_RECURSIVELY(frame, 'rand_equip_list')
    GODDESS_MGR_RANDOMOPTION_ENGRAVE_SPOT_SELECT(frame, rand_equip_list)
end

function GODDESS_MGR_RANDOMOPTION_ENGRAVE_REG_ITEM(frame, inv_item, item_obj, spot) -- 각인 저장(옛날)	
    if inv_item == nil then
        return
    end

    local etc = GetMyEtcObject()
    if etc == nil then
        return
    end

    local enable, def_rate = IS_ENABLE_TO_ENGARVE(item_obj, 2)
    if enable == false then
        return
    end

    local slot = GET_CHILD_RECURSIVELY(frame, 'rand_engrave_slot')
    SET_SLOT_ITEM(slot, inv_item)
    slot:SetUserValue('ITEM_GUID', inv_item:GetIESID())
    slot:SetUserValue('ITEM_USE_LEVEL', TryGetProp(item_obj, 'UseLv', 0))
    slot:SetUserValue('DEFAULT_RATE', def_rate)
    slot:SetUserValue('EQUIP_SPOT', spot)

    local rand_item_text = GET_CHILD_RECURSIVELY(frame, 'rand_item_text')
    rand_item_text:ShowWindow(0)

    local rand_engrave_slot_pic = GET_CHILD_RECURSIVELY(frame, 'rand_engrave_slot_pic')
    rand_engrave_slot_pic:ShowWindow(0)

    local rand_item_name = GET_CHILD_RECURSIVELY(frame, 'rand_item_name')
    rand_item_name:SetTextByKey('name', dic.getTranslatedStr(TryGetProp(item_obj, 'Name', 'NONE')))
    rand_item_name:ShowWindow(1)

    local rand_equip_list = GET_CHILD_RECURSIVELY(frame, 'rand_equip_list')
    rand_equip_list:SetMargin(30, rand_item_name:GetMargin().top + rand_item_name:GetHeight() + 10, 0, 0)

    local rand_engrave_current_inner = GET_CHILD_RECURSIVELY(frame, 'rand_engrave_current_inner')
    rand_engrave_current_inner:RemoveChild('tooltip_equip_property_narrow')
    _GODDESS_MGR_MAKE_RANDOM_OPTION_TEXT(rand_engrave_current_inner, item_obj)

    local randomoption_bg = GET_CHILD_RECURSIVELY(frame, 'randomoption_bg')
    local index = randomoption_bg:GetUserValue('PRESET_INDEX')
    local before_option = GET_ENGRAVED_OPTION_BY_INDEX_SPOT(etc, index, spot)
    if before_option ~= nil then
        slot:SetUserValue('BEFORE_OPTION_EXIST', 1)
    else
        slot:SetUserValue('BEFORE_OPTION_EXIST', 0)
    end
    local rand_engrave_before_inner = GET_CHILD_RECURSIVELY(frame, 'rand_engrave_before_inner')
    rand_engrave_before_inner:RemoveChild('tooltip_equip_property_narrow')
    _GODDESS_MGR_MAKE_RANDOM_OPTION_TEXT(rand_engrave_before_inner, nil, before_option)

    local item_dic = GET_ITEM_RANDOMOPTION_DIC(item_obj)
    if COMPARE_ITEM_OPTION_TO_ENGRAVED_OPTION(item_dic, before_option) == true then
        slot:SetUserValue('IS_SAME_OPTION', 1)
    else
        slot:SetUserValue('IS_SAME_OPTION', 0)
    end
end

function GODDESS_MGR_RANDOMOPTION_ENGRAVE_EXEC(parent, btn)
    local frame = parent:GetTopParentFrame()

    local rand_engrave_slot = GET_CHILD_RECURSIVELY(frame, 'rand_engrave_slot')
    if rand_engrave_slot:GetUserIValue('IS_SAME_OPTION') == 1 then
        ui.SysMsg(ClMsg('SameOptionEngravedAlready'))
        return
    end

    local rand_mat_list = GET_CHILD_RECURSIVELY(frame, 'rand_mat_list')
    local selected_cnt = rand_mat_list:GetSelectedSlotCount()
    if selected_cnt == 0 then
        return
    end

    local yesscp = string.format('_GODDESS_MGR_RANDOMOPTION_ENGRAVE_EXEC()')
    local before_option = rand_engrave_slot:GetUserIValue('BEFORE_OPTION_EXIST')
    if before_option == 1 then
        WARNINGMSGBOX_EX_ENGRAVE_OPEN()
    else
        local msgbox = ui.MsgBox(ClMsg('TryRandomOptionPresetEngrave'), yesscp, 'None')
        SET_MODAL_MSGBOX(msgbox)
    end
end

function _GODDESS_MGR_RANDOMOPTION_ENGRAVE_EXEC()
    local frame = ui.GetFrame('goddess_equip_manager')
    if frame == nil then
        return
    end

    session.ResetItemList()

    local rand_engrave_slot = GET_CHILD_RECURSIVELY(frame, 'rand_engrave_slot')
    local tgt_guid = rand_engrave_slot:GetUserValue('ITEM_GUID')
    local tgt_spot = rand_engrave_slot:GetUserValue('EQUIP_SPOT')
    local tgt_item = session.GetEquipItemBySpot(item.GetEquipSpotNum(tgt_spot))
    if tgt_item == nil then
        ui.SysMsg(ClMsg('NoSelectedItem'))
        return
    end

    if tgt_item.isLockState == true then
        ui.SysMsg(ClMsg('MaterialItemIsLock'))
        return
    end

    session.AddItemID(tgt_guid, 1)

    local rand_mat_list = GET_CHILD_RECURSIVELY(frame, 'rand_mat_list')
    local selected_cnt = rand_mat_list:GetSelectedSlotCount()
    for i = 0, selected_cnt - 1 do
        local _slot = rand_mat_list:GetSelectedSlot(i)
        local mat_guid = _slot:GetUserValue('ITEM_GUID')
        local mat_item = session.GetInvItemByGuid(mat_guid)
        if mat_item == nil then
            ui.SysMsg(ClMsg('NoSelectedItem'))
            return
        end

        if mat_item.isLockState == true then
            ui.SysMsg(ClMsg('MaterialItemIsLock'))
            return
        end

        local cnt = _slot:GetSelectCount()
        session.AddItemID(mat_guid, cnt)
    end

    local rand_equip_list = GET_CHILD_RECURSIVELY(frame, 'rand_equip_list')
    local spot = rand_equip_list:GetSelItemKey()

    local randomoption_bg = GET_CHILD_RECURSIVELY(frame, 'randomoption_bg')
    local index = randomoption_bg:GetUserValue('PRESET_INDEX')

    local arg_list = NewStringList()
    arg_list:Add(index)
    arg_list:Add(spot)

    local result_list = session.GetItemIDList()
    item.DialogTransaction('ICOR_PRESET_ENGRAVE', result_list, '', arg_list)
end

function GODDESS_MGR_ENGRAVE_CLEAR_BTN(parent, btn)
    local effect_frame = ui.GetFrame('result_effect_ui')
    effect_frame:ShowWindow(0)

    local frame = parent:GetTopParentFrame()
    GODDESS_MGR_RANDOMOPTION_ENGRAVE_CLEAR(frame)
end

function ON_SUCCESS_RANDOMOPTION_ENGRAVE(frame, msg, arg_str, arg_num)
    local rand_do_engrave = GET_CHILD_RECURSIVELY(frame, 'rand_do_engrave')
    rand_do_engrave:ShowWindow(0)

    local ref_slot = GET_CHILD_RECURSIVELY(frame, 'rand_engrave_slot')
    local guid = ref_slot:GetUserValue('ITEM_GUID')
    local inv_item = session.GetEquipItemByGuid(guid)
    local item_obj = GetIES(inv_item:GetObject())
    local icon = TryGetProp(item_obj, 'Icon', 'None')

    local left, top = _GET_EFFECT_UI_MARGIN()

    local success_scp = string.format('RESULT_EFFECT_UI_RUN_SUCCESS(\'%s\', \'%s\', \'%d\', \'%d\')',
        '_END_RAMDOMOPTION_ENGRAVE_EXEC', icon, left, top)
    ReserveScript(success_scp, 0)
end

function ON_FAILED_RANDOMOPTION_ENGRAVE(frame, msg, arg_str, arg_num)
    local rand_do_engrave = GET_CHILD_RECURSIVELY(frame, 'rand_do_engrave')
    rand_do_engrave:ShowWindow(0)

    local left, top = _GET_EFFECT_UI_MARGIN()

    local failed_scp = string.format('RESULT_EFFECT_UI_RUN_FAILED(\'%s\', \'%d\', \'%d\')',
        '_END_RAMDOMOPTION_ENGRAVE_EXEC', left, top)
    ReserveScript(failed_scp, 0)
end

function _END_RAMDOMOPTION_ENGRAVE_EXEC()
    local frame = ui.GetFrame('goddess_equip_manager')
    local rand_ok_engrave = GET_CHILD_RECURSIVELY(frame, 'rand_ok_engrave')
    rand_ok_engrave:ShowWindow(1)
end
-- 각인 - 저장 끝-- 刻印・保存の終わり

-- 각인 - 적용- 刻印・適用
function GODDESS_MGR_RANDOMOPTION_APPLY_CLEAR(frame)
    local etc = GetMyEtcObject()
    if etc == nil then
        return
    end

    local rand_ok_apply = GET_CHILD_RECURSIVELY(frame, 'rand_ok_apply')
    rand_ok_apply:ShowWindow(0)

    local rand_do_apply = GET_CHILD_RECURSIVELY(frame, 'rand_do_apply')
    rand_do_apply:ShowWindow(1)

    local checkall = GET_CHILD_RECURSIVELY(frame, 'checkall')
    checkall:SetCheck(0)

    local randomoption_bg = GET_CHILD_RECURSIVELY(frame, 'randomoption_bg')
    local index = randomoption_bg:GetUserValue('PRESET_INDEX')

    local apply_cost = 0
    local coin_type = 'None'
    for i = 1, #managed_slot_list do
        local slot_info = managed_slot_list[i]
        local ctrlset = GET_CHILD_RECURSIVELY(frame, 'rand_slot_' .. slot_info.SlotName)

        local inv_item = session.GetEquipItemBySpot(item.GetEquipSpotNum(slot_info.SlotName))
        local item_obj = GetIES(inv_item:GetObject())

        local gBox = GET_CHILD_RECURSIVELY(ctrlset, 'optionGbox_1')
        gBox:RemoveChild('tooltip_equip_property_narrow')

        local slot = GET_CHILD(ctrlset, 'slot')
        local slot_name = GET_CHILD(ctrlset, 'slot_name')
        local item_name = GET_CHILD(ctrlset, 'item_name')
        local checkbox = GET_CHILD(ctrlset, 'checkbox')

        slot:SetSkinName(slot_info.SkinName)
        slot:SetUserValue('EQUIP_SPOT', slot_info.SlotName)
        slot_name:SetTextByKey('name', ClMsg(slot_info.ClMsg))
        checkbox:SetCheck(0)

        if item_obj == nil or IS_NO_EQUIPITEM(item_obj) == 1 or item_goddess_growth.is_goddess_growth_item(item_obj) ==
            true then
            slot:ClearIcon()
            slot:SetUserValue('ITEM_GUID', 'None')
            slot:SetUserValue('IS_APPLY', 0)
            item_name:SetTextByKey('name', ClMsg('NONE'))
        else
            SET_SLOT_ITEM(slot, inv_item)
            slot:SetUserValue('ITEM_GUID', inv_item:GetIESID())
            item_name:SetTextByKey('name', dic.getTranslatedStr(TryGetProp(item_obj, 'Name', 'NONE')))
            local option_dic = GET_ENGRAVED_OPTION_BY_INDEX_SPOT(etc, index, slot_info.SlotName)
            if option_dic ~= nil then
                local ret = IS_ENABLE_TO_ENGRAVE_APPLY(item_obj, index, slot_info.SlotName, GetMyEtcObject())
                if ret == true then
                    _GODDESS_MGR_MAKE_RANDOM_OPTION_TEXT(gBox, nil, option_dic)
                else
                    slot:ClearIcon()
                    slot:SetUserValue('ITEM_GUID', 'None')
                    slot:SetUserValue('IS_APPLY', 0)
                    item_name:SetTextByKey('name', ClMsg('NONE'))
                end
            end
        end
    end

    GODDESS_MGR_RANDOMOPTION_APPLY_COST_UPDATE(frame)
end

function GODDESS_MGR_RANDOMOPTION_APPLY_COST_UPDATE(frame)
    local etc = GetMyEtcObject()
    if etc == nil then
        return
    end

    local randomoption_bg = GET_CHILD_RECURSIVELY(frame, 'randomoption_bg')
    local index = randomoption_bg:GetUserValue('PRESET_INDEX')
    local cost_list = {}

    for i = 1, #managed_slot_list do
        local slot_info = managed_slot_list[i]
        local ctrlset = GET_CHILD_RECURSIVELY(frame, 'rand_slot_' .. slot_info.SlotName)
        local slot = GET_CHILD(ctrlset, 'slot')
        local checkbox = GET_CHILD(ctrlset, 'checkbox')
        local guid = slot:GetUserValue('ITEM_GUID')
        if guid ~= 'None' and checkbox:IsChecked() == 1 then
            local inv_item = session.GetEquipItemBySpot(item.GetEquipSpotNum(slot_info.SlotName))
            local item_obj = GetIES(inv_item:GetObject())
            local _type, _cost = GET_COST_APPLY_ENGRAVE(item_obj)
            if cost_list[_type] == nil then
                cost_list[_type] = _cost
            else
                cost_list[_type] = cost_list[_type] + _cost
            end
        end
    end

    local cost_bg = GET_CHILD_RECURSIVELY(frame, 'rand_apply_cost_bg')
    cost_bg:RemoveAllChild()

    local coin_type = ''
    local apply_cost = ''
    local cset_height = ui.GetControlSetAttribute('engrave_apply_cost', 'height')
    local ind = 0
    for type, cost in pairs(cost_list) do
        local cost_cset = cost_bg:CreateOrGetControlSet('engrave_apply_cost', 'COST_' .. ind, 0, ind * cset_height)
        local cost_name = GET_CHILD(cost_cset, 'cost_name')
        cost_name:SetTextByKey('name', ClMsg(type))
        local cost_value = GET_CHILD(cost_cset, 'cost_value')
        cost_value:SetTextByKey('value', cost)
        if IS_ACCOUNT_COIN(type) == true then
            local coin_cls = GetClass('accountprop_inventory_list', type)
            if coin_cls ~= nil then
                local pic = TryGetProp(coin_cls, 'Icon', 'None')
                cost_value:SetTextByKey('pic', pic)
            end
        end

        coin_type = coin_type .. type .. ';'
        apply_cost = apply_cost .. cost .. ';'
        ind = ind + 1
    end

    local rand_do_apply = GET_CHILD_RECURSIVELY(frame, 'rand_do_apply')
    if ind == 0 then
        rand_do_apply:SetEnable(0)
    else
        rand_do_apply:SetEnable(1)
    end

    local origin_height = tonumber(frame:GetUserConfig('APPLY_COST_BG_HEIGHT'))
    local inner_height = cset_height * ind
    if inner_height > origin_height then
        cost_bg:Resize(cost_bg:GetWidth(), inner_height + 5)
    else
        cost_bg:Resize(cost_bg:GetWidth(), origin_height)
    end

    local rand_apply_bg = GET_CHILD_RECURSIVELY(frame, 'rand_apply_bg')
    rand_apply_bg:SetUserValue('COIN_TYPE', coin_type)
    rand_apply_bg:SetUserValue('REQ_COST', apply_cost)
end

function GODDESS_ENGRAVE_APPLY_CHECK(frame, ctrlset)
    local etc = GetMyEtcObject()
    if etc == nil then
        return false, 'None'
    end

    local randomoption_bg = GET_CHILD_RECURSIVELY(frame, 'randomoption_bg')
    local index = randomoption_bg:GetUserValue('PRESET_INDEX')

    local slot = GET_CHILD(ctrlset, 'slot')
    local guid = slot:GetUserValue('ITEM_GUID')
    if guid == 'None' then
        return false, 'None'
    end

    local spot_name = slot:GetUserValue('EQUIP_SPOT')
    local inv_item = session.GetEquipItemBySpot(item.GetEquipSpotNum(spot_name))
    if inv_item == nil then
        return false, 'None'
    end

    local item_obj = GetIES(inv_item:GetObject())
    local item_dic = GET_ITEM_RANDOMOPTION_DIC(item_obj)
    if item_dic == nil then
        return false, 'None'
    end

    local option_dic = GET_ENGRAVED_OPTION_BY_INDEX_SPOT(etc, index, spot_name)
    if option_dic == nil then
        return false, 'None'
    end

    if COMPARE_ITEM_OPTION_TO_ENGRAVED_OPTION(item_dic, option_dic) == true then
        return false, 'SameEngraveAppliedAlready'
    end

    return true
end

function GODDESS_MGR_RANDOMOPTION_APPLY_CHECK(ctrlset, checkbox, arg_str)
    local frame = ctrlset:GetTopParentFrame()
    if checkbox:IsChecked() == 1 then
        local flag, clmsg = GODDESS_ENGRAVE_APPLY_CHECK(frame, ctrlset)
        if flag == false then
            if clmsg ~= 'None' and arg_str ~= 'All' then
                ui.SysMsg(ClMsg(clmsg))
            end
            checkbox:SetCheck(0)
            return
        end
    end

    GODDESS_MGR_RANDOMOPTION_APPLY_COST_UPDATE(frame)
end

function GODDESS_MGR_RANDOMOPTION_APPLY_CHECK_ALL(parent, ctrl)
    local frame = parent:GetTopParentFrame()
    for i = 1, #managed_slot_list do
        local slot_info = managed_slot_list[i]
        local ctrlset = GET_CHILD_RECURSIVELY(frame, 'rand_slot_' .. slot_info.SlotName)
        local checkbox = GET_CHILD(ctrlset, 'checkbox')
        checkbox:SetCheck(ctrl:IsChecked())
        GODDESS_MGR_RANDOMOPTION_APPLY_CHECK(ctrlset, checkbox, 'All')
    end
end

function GODDESS_MGR_RANDOMOPTION_APPLY_OPEN(frame)
    GODDESS_MGR_RANDOMOPTION_APPLY_CLEAR(frame)
    INVENTORY_SET_CUSTOM_RBTNDOWN('None')

    local checkall = GET_CHILD_RECURSIVELY(frame, 'checkall')
    checkall:ShowWindow(1)
end

function GODDESS_MGR_RANDOMOPTION_APPLY_EXEC(parent, btn)
    local frame = parent:GetTopParentFrame()

    local acc = GetMyAccountObj()
    if acc == nil then
        return
    end

    local randomoption_bg = GET_CHILD_RECURSIVELY(frame, 'randomoption_bg')
    local index = randomoption_bg:GetUserValue('PRESET_INDEX')

    local apply_cnt = 0
    local same_cnt = 0
    for i = 1, #managed_slot_list do
        local slot_info = managed_slot_list[i]
        local ctrlset = GET_CHILD_RECURSIVELY(frame, 'rand_slot_' .. slot_info.SlotName)
        local tgt_item = session.GetEquipItemBySpot(item.GetEquipSpotNum(slot_info.SlotName))
        local checkbox = GET_CHILD(ctrlset, 'checkbox')
        if tgt_item ~= nil and checkbox:IsChecked() == 1 then
            if tgt_item.isLockState == true then
                ui.SysMsg(ClMsg('MaterialItemIsLock'))
                return
            end
            apply_cnt = apply_cnt + 1
        end
    end

    if apply_cnt == 0 then
        ui.SysMsg(ClMsg('NoSelectedItem'))
        return
    end

    local rand_apply_bg = GET_CHILD_RECURSIVELY(frame, 'rand_apply_bg')
    local type_str = rand_apply_bg:GetUserValue('COIN_TYPE')
    local cost_str = rand_apply_bg:GetUserValue('REQ_COST')

    local type_list = SCR_STRING_CUT(type_str, ';')
    local cost_list = SCR_STRING_CUT(cost_str, ';')
    if #type_list ~= #cost_list then
        return
    end

    for i = 1, #type_list do
        local coin_type = type_list[i]
        local cost = cost_list[i]

        local cur_coin = TryGetProp(acc, coin_type, '0')
        if cur_coin == 'None' then
            cur_coin = '0'
        end

        if math.is_larger_than(cur_coin, cost) ~= 1 then
            ui.SysMsg(ClMsg('NOT_ENOUGH_MONEY'))
            return
        end
    end

    local yesscp = string.format('_GODDESS_MGR_RANDOMOPTION_APPLY_EXEC()')
    local msgbox = ui.MsgBox(ClMsg('TryRandomOptionPresetApply'), yesscp, 'None')
    SET_MODAL_MSGBOX(msgbox)
end

function _GODDESS_MGR_RANDOMOPTION_APPLY_EXEC()
    local frame = ui.GetFrame('goddess_equip_manager')
    if frame == nil then
        return
    end

    session.ResetItemList()

    local arg_list = NewStringList()

    local apply_cnt = 0
    for i = 1, #managed_slot_list do
        local slot_info = managed_slot_list[i]
        local ctrlset = GET_CHILD_RECURSIVELY(frame, 'rand_slot_' .. slot_info.SlotName)
        local tgt_item = session.GetEquipItemBySpot(item.GetEquipSpotNum(slot_info.SlotName))
        local checkbox = GET_CHILD(ctrlset, 'checkbox')
        if tgt_item ~= nil and checkbox:IsChecked() == 1 then
            if tgt_item.isLockState == true then
                ui.SysMsg(ClMsg('MaterialItemIsLock'))
                return
            end
            local slot = GET_CHILD(ctrlset, 'slot')
            local guid = slot:GetUserValue('ITEM_GUID')
            if guid ~= 'None' then
                session.AddItemID(guid, 1)
                arg_list:Add(slot_info.SlotName)
                apply_cnt = apply_cnt + 1
            end
        end
    end

    if apply_cnt == 0 then
        ui.SysMsg(ClMsg('NoSelectedItem'))
        return
    end

    local randomoption_bg = GET_CHILD_RECURSIVELY(frame, 'randomoption_bg')
    local index = randomoption_bg:GetUserValue('PRESET_INDEX')

    arg_list:Add(index)

    local result_list = session.GetItemIDList()
    item.DialogTransaction('ICOR_PRESET_ENGRAVE_APPLY', result_list, '', arg_list)
end

function ON_SUCCESS_RANDOMOPTION_APPLY(frame, msg, arg_str, arg_num)
    ui.SysMsg(ClMsg('AppliedEngraveOption'))
    GODDESS_MGR_RANDOMOPTION_APPLY_CLEAR(frame)
end
-- 각인 - 적용 끝-- 刻印 - 適用端

-- 각인 - 아이커-- 押すこと-アイカー
function GODDESS_MGR_RANDOMOPTION_ENGRAVE_ICOR_CLEAR(frame)
    local rand_ok_icor = GET_CHILD_RECURSIVELY(frame, 'rand_ok_icor')
    rand_ok_icor:ShowWindow(0)

    local rand_do_icor = GET_CHILD_RECURSIVELY(frame, 'rand_do_icor')
    rand_do_icor:ShowWindow(1)

    local rand_icor_slot = GET_CHILD_RECURSIVELY(frame, 'rand_icor_slot')
    rand_icor_slot:ClearIcon()
    rand_icor_slot:SetUserValue('ITEM_GUID', 'None')

    local rand_icor_slot_pic = GET_CHILD_RECURSIVELY(frame, 'rand_icor_slot_pic')
    rand_icor_slot_pic:ShowWindow(1)

    local rand_icor_name = GET_CHILD_RECURSIVELY(frame, 'rand_icor_name')
    rand_icor_name:ShowWindow(0)
    rand_icor_name:SetTextByKey('name', '')

    local rand_icor_text = GET_CHILD_RECURSIVELY(frame, 'rand_icor_text')
    rand_icor_text:ShowWindow(1)

    local rand_icor_help_text = GET_CHILD_RECURSIVELY(frame, 'rand_icor_help_text')
    rand_icor_help_text:ShowWindow(1)

    local current_icor_option_inner = GET_CHILD_RECURSIVELY(frame, 'current_icor_option_inner')
    current_icor_option_inner:RemoveChild('tooltip_equip_property_narrow')

    local before_preset_option_inner = GET_CHILD_RECURSIVELY(frame, 'before_preset_option_inner')
    before_preset_option_inner:RemoveChild('tooltip_equip_property_narrow')
    CLEAR_GODDESS_ICOR_TEXT(frame)

    GODDESS_MGR_RANDOMOPTION_ENGRAVE_ICOR_COST_UPDATE(frame)
end

function GODDESS_MGR_RANDOMOPTION_ENGRAVE_ICOR_OPEN(frame)
    GODDESS_MGR_RANDOMOPTION_ENGRAVE_ICOR_CLEAR(frame)
    INVENTORY_SET_CUSTOM_RBTNDOWN('GODDESS_MGR_RANDOMOPTION_ENGRAVE_ICOR_INV_RBTN')

    local checkall = GET_CHILD_RECURSIVELY(frame, 'checkall')
    checkall:ShowWindow(0)
end

function GODDESS_MGR_RANDOMOPTION_ENGRAVE_ICOR_INV_RBTN(item_obj, slot, guid)
    local frame = ui.GetFrame('goddess_equip_manager')

    local inv_item = session.GetInvItemByGuid(guid)
    if item_obj ~= nil and inv_item ~= nil then
        GODDESS_MGR_RANDOMOPTION_ENGRAVE_ICOR_REG_ITEM(frame, inv_item, item_obj)
    end
end

function GODDESS_MGR_RANDOMOPTION_ENGRAVE_ICOR_ITEM_DROP(parent, slot)
    local frame = parent:GetTopParentFrame()
    local lift_icon = ui.GetLiftIcon()
    local from_frame = lift_icon:GetTopParentFrame()
    if from_frame:GetName() == 'inventory' then
        local icon_info = lift_icon:GetInfo()
        local guid = icon_info:GetIESID()
        local inv_item = session.GetInvItemByGuid(guid)
        local item_obj = GetIES(inv_item:GetObject())
        if item_obj ~= nil and inv_item ~= nil then
            GODDESS_MGR_RANDOMOPTION_ENGRAVE_ICOR_REG_ITEM(frame, inv_item, item_obj)
        end
    end
end

function GODDESS_MGR_RANDOMOPTION_ENGRAVE_ICOR_UPDATE(frame)
    local etc = GetMyEtcObject()
    if etc == nil then
        return
    end

    local randomoption_bg = GET_CHILD_RECURSIVELY(frame, 'randomoption_bg')
    local index = randomoption_bg:GetUserValue('PRESET_INDEX')

    local slot = GET_CHILD_RECURSIVELY(frame, 'rand_icor_slot')
    local guid = slot:GetUserValue('ITEM_GUID')
    if guid == 'None' then
        return
    end

    local inv_item = session.GetInvItemByGuid(guid)
    local item_obj = GetIES(inv_item:GetObject())
    local spot = slot:GetUserValue('EQUIP_SPOT')
    local before_option = GET_ENGRAVED_OPTION_BY_INDEX_SPOT(etc, index, spot)
    local before_preset_option_inner = GET_CHILD_RECURSIVELY(frame, 'before_preset_option_inner')
    before_preset_option_inner:RemoveChild('tooltip_equip_property_narrow')
    _GODDESS_MGR_MAKE_RANDOM_OPTION_TEXT(before_preset_option_inner, nil, before_option)

    local item_dic = GET_ITEM_RANDOMOPTION_DIC(item_obj)
    if COMPARE_ITEM_OPTION_TO_ENGRAVED_OPTION(item_dic, before_option) == true then
        slot:SetUserValue('IS_SAME_OPTION', 1)
    else
        slot:SetUserValue('IS_SAME_OPTION', 0)
    end
end

function GODDESS_MGR_RANDOMOPTION_ENGRAVE_ICOR_COST_UPDATE(frame)
    local rand_icor_prob_text = GET_CHILD_RECURSIVELY(frame, 'rand_icor_prob_text')
    local rand_icor_cost_name = GET_CHILD_RECURSIVELY(frame, 'rand_icor_cost_name')
    local rand_icor_cost = GET_CHILD_RECURSIVELY(frame, 'rand_icor_cost')
    local rand_do_icor = GET_CHILD_RECURSIVELY(frame, 'rand_do_icor')

    local slot = GET_CHILD_RECURSIVELY(frame, 'rand_icor_slot')
    local guid = slot:GetUserValue('ITEM_GUID')
    if guid ~= 'None' then
        local rate = slot:GetUserValue('DEFAULT_RATE')
        local coin = slot:GetUserValue('COIN_TYPE')
        local cost = slot:GetUserValue('REQ_COST')

        rand_icor_prob_text:SetTextByKey('total', rate)
        if cost == 'None' then
            cost = '0'
        end
        rand_icor_cost:SetTextByKey('value', cost)

        local coin_cls = GetClass('accountprop_inventory_list', coin)
        if coin_cls ~= nil then
            local pic = TryGetProp(coin_cls, 'Icon', 'None')
            rand_icor_cost:SetTextByKey('pic', pic)
        end

        rand_icor_prob_text:ShowWindow(1)
        rand_icor_cost_name:ShowWindow(1)
        rand_icor_cost:ShowWindow(1)
        rand_do_icor:SetEnable(1)
    else
        rand_icor_prob_text:ShowWindow(0)
        rand_icor_cost_name:ShowWindow(0)
        rand_icor_cost:ShowWindow(0)
        rand_do_icor:SetEnable(0)
    end
end

function GODDESS_MGR_RANDOMOPTION_ENGRAVE_ICOR_REG_ITEM(frame, inv_item, item_obj)
    if inv_item == nil then
        return
    end

    local etc = GetMyEtcObject()
    if etc == nil then
        return
    end

    local enable, def_rate = IS_ENABLE_TO_ENGARVE(item_obj, 0)

    if enable == false then
        ui.SysMsg(ClMsg('IMPOSSIBLE_ITEM'))
        return
    end

    local is_goddess_icor = shared_item_goddess_icor.get_goddess_icor_grade(item_obj)

    local inherit_item = GetClass('Item', TryGetProp(item_obj, 'InheritanceRandomItemName', 'None'))
    if is_goddess_icor == 0 and inherit_item == nil then
        ui.SysMsg(ClMsg('IMPOSSIBLE_ITEM'))
        return
    end

    local spot = TryGetProp(inherit_item, 'DefaultEqpSlot', 'None')

    if is_goddess_icor > 0 then
        SHOW_GODDESS_ICOR_TEXT(frame)
        init_goddess_icor_spot_list(frame, TryGetProp(item_obj, 'StringArg2', 'None'))
        if TryGetProp(item_obj, 'StringArg2', 'None') == 'Armor' then
            spot = 'SHIRT'
        else
            spot = 'RH'
        end
    else
        CLEAR_GODDESS_ICOR_TEXT(frame)
    end

    local slot = GET_CHILD_RECURSIVELY(frame, 'rand_icor_slot')
    SET_SLOT_ITEM(slot, inv_item)
    slot:SetUserValue('ITEM_GUID', inv_item:GetIESID())
    slot:SetUserValue('ITEM_CLASSNAME', TryGetProp(item_obj, 'ClassName', 'None'))
    slot:SetUserValue('ITEM_USE_LEVEL', TryGetProp(inherit_item, 'UseLv', 0))
    slot:SetUserValue('DEFAULT_RATE', def_rate)
    slot:SetUserValue('EQUIP_SPOT', spot)

    local coin = GET_COST_SAVE_ENGRAVE(inherit_item)
    slot:SetUserValue('COIN_TYPE', coin)
    slot:SetUserValue('REQ_COST', 0)

    local slot_pic = GET_CHILD_RECURSIVELY(frame, 'rand_icor_slot_pic')
    slot_pic:ShowWindow(0)

    local rand_icor_text = GET_CHILD_RECURSIVELY(frame, 'rand_icor_text')
    rand_icor_text:ShowWindow(0)

    local rand_icor_name = GET_CHILD_RECURSIVELY(frame, 'rand_icor_name')
    rand_icor_name:SetTextByKey('name', dic.getTranslatedStr(TryGetProp(item_obj, 'Name', 'NONE')))
    rand_icor_name:ShowWindow(1)

    local rand_icor_help_text = GET_CHILD_RECURSIVELY(frame, 'rand_icor_help_text')
    rand_icor_help_text:ShowWindow(0)

    local current_icor_option_inner = GET_CHILD_RECURSIVELY(frame, 'current_icor_option_inner')
    current_icor_option_inner:RemoveChild('tooltip_equip_property_narrow')
    _GODDESS_MGR_MAKE_RANDOM_OPTION_TEXT(current_icor_option_inner, item_obj)

    GODDESS_MGR_RANDOMOPTION_ENGRAVE_ICOR_UPDATE(frame)

    GODDESS_MGR_RANDOMOPTION_ENGRAVE_ICOR_COST_UPDATE(frame)
end

function GODDESS_ICOR_SPOT_SELECT(parent, ctrl)
    local frame = parent:GetTopParentFrame()
    local index = ctrl:GetSelItemKey()

    local slot = GET_CHILD_RECURSIVELY(frame, 'rand_icor_slot')
    slot:SetUserValue('EQUIP_SPOT', index)

    GODDESS_MGR_RANDOMOPTION_ENGRAVE_ICOR_UPDATE(frame)
end

function GODDESS_MGR_RANDOMOPTION_ENGRAVE_ICOR_ITEM_REMOVE(parent, ctrl)
    local frame = parent:GetTopParentFrame()
    GODDESS_MGR_RANDOMOPTION_ENGRAVE_ICOR_CLEAR(frame)
end

function GODDESS_MGR_RANDOMOPTION_ENGRAVE_ICOR_EXEC(parent, btn)
    local frame = parent:GetTopParentFrame()

    local rand_icor_slot = GET_CHILD_RECURSIVELY(frame, 'rand_icor_slot')
    local coin_type = rand_icor_slot:GetUserValue('COIN_TYPE')
    local acc = GetMyAccountObj()
    if acc == nil then
        return
    end

    local spot = rand_icor_slot:GetUserValue('EQUIP_SPOT')
    if spot == 'None' then
        ui.SysMsg(ClMsg('FirstSelectSpotForGoddessIcorEngrave'))
        return
    end

    local cur_coin = TryGetProp(acc, coin_type, '0')
    if cur_coin == 'None' then
        cur_coin = '0'
    end

    local cost = rand_icor_slot:GetUserValue('REQ_COST')
    if cost == 'None' then
        cost = '0'
    end

    if math.is_larger_than(cost, cur_coin) == 1 then
        ui.SysMsg(ClMsg('NOT_ENOUGH_MONEY'))
        return
    end

    if rand_icor_slot:GetUserIValue('IS_SAME_OPTION') == 1 then
        ui.SysMsg(ClMsg('SameOptionEngravedAlready'))
        return
    end

    local yesscp = string.format('_GODDESS_MGR_RANDOMOPTION_ENGRAVE_ICOR_EXEC()')
    local msgbox = ui.MsgBox(ClMsg('TryRandomOptionPresetEngrave'), yesscp, 'None')
    SET_MODAL_MSGBOX(msgbox)
end

function _GODDESS_MGR_RANDOMOPTION_ENGRAVE_ICOR_EXEC()
    local frame = ui.GetFrame('goddess_equip_manager')
    if frame == nil then
        return
    end

    session.ResetItemList()

    local rand_icor_slot = GET_CHILD_RECURSIVELY(frame, 'rand_icor_slot')
    local tgt_guid = rand_icor_slot:GetUserValue('ITEM_GUID')
    local tgt_item = session.GetInvItemByGuid(tgt_guid)
    if tgt_item == nil then
        ui.SysMsg(ClMsg('NoSelectedItem'))
        return
    end

    if tgt_item.isLockState == true then
        ui.SysMsg(ClMsg('MaterialItemIsLock'))
        return
    end

    local obj = GetIES(tgt_item:GetObject())
    session.AddItemID(tgt_guid, 1)

    local randomoption_bg = GET_CHILD_RECURSIVELY(frame, 'randomoption_bg')
    local index = randomoption_bg:GetUserValue('PRESET_INDEX')

    local spot = rand_icor_slot:GetUserValue('EQUIP_SPOT')
    local arg_list = NewStringList()
    arg_list:Add(index)

    if shared_item_goddess_icor.get_goddess_icor_grade(obj) > 0 then
        arg_list:Add(spot)
    end

    local result_list = session.GetItemIDList()
    item.DialogTransaction('ICOR_PRESET_ENGRAVE_ICOR', result_list, '', arg_list)
end

function GODDESS_MGR_ENGRAVE_ICOR_CLEAR_BTN(parent, btn)
    local effect_frame = ui.GetFrame('result_effect_ui')
    effect_frame:ShowWindow(0)

    local frame = parent:GetTopParentFrame()
    GODDESS_MGR_RANDOMOPTION_ENGRAVE_ICOR_CLEAR(frame)
end

function ON_SUCCESS_RANDOMOPTION_ENGRAVE_ICOR(frame, msg, arg_str, arg_num)
    local rand_do_engrave = GET_CHILD_RECURSIVELY(frame, 'rand_do_icor')
    rand_do_engrave:ShowWindow(0)

    local ref_slot = GET_CHILD_RECURSIVELY(frame, 'rand_icor_slot')
    local left, top = _GET_EFFECT_UI_MARGIN()
    local class_name = ref_slot:GetUserValue('ITEM_CLASSNAME')
    local cls = GetClass('Item', class_name)
    local icon = nil
    if cls ~= nil then
        icon = TryGetProp(cls, 'Icon', 'None')
    end

    local success_scp = string.format('RESULT_EFFECT_UI_RUN_SUCCESS(\'%s\', \'%s\', \'%d\', \'%d\')',
        '_END_RAMDOMOPTION_ENGRAVE_ICOR_EXEC', icon, left, top)
    ReserveScript(success_scp, 0)
end

function _END_RAMDOMOPTION_ENGRAVE_ICOR_EXEC()
    local frame = ui.GetFrame('goddess_equip_manager')
    local rand_ok_engrave = GET_CHILD_RECURSIVELY(frame, 'rand_ok_icor')
    rand_ok_engrave:ShowWindow(1)
end
-- 刻印 - アイカーの端
-- 刻印の先端
