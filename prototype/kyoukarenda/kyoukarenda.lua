local addonName = "KYOUKARENDA"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "0.0.1"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

local acutil = require("acutil")

g.autoreinforce = 0

function KYOUKARENDA_ON_INIT(addon, frame)
    g.addon = addon
    g.frame = frame

    acutil.setupHook(KYOUKARENDA_GODDESS_MGR_REFORGE_REINFORCE_EXEC, "GODDESS_MGR_REFORGE_REINFORCE_EXEC")
    acutil.setupHook(_KYOUKARENDA_GODDESS_MGR_REFORGE_REINFORCE_EXEC, "_GODDESS_MGR_REFORGE_REINFORCE_EXEC")
    -- acutil.setupHook(KYOUKARENDA_GODDESS_MGR_REINFORCE_CLEAR_BTN, "GODDESS_MGR_REINFORCE_CLEAR_BTN")
    CHAT_SYSTEM("kyoukarenda loaded")
    addon:RegisterMsg('GAME_START_3SEC', 'KYOUKARENDA_FRAME_INIT')
    addon:RegisterMsg('GODDESS_MGR_REINFORCE_CLEAR_BTN', 'KYOUKARENDA_GODDESS_MGR_REINFORCE_CLEAR_BTN')
end

function KYOUKARENDA_FRAME_INIT()
    CHAT_SYSTEM("testframeinit")
    local frame = ui.GetFrame('goddess_equip_manager')
    -- 追加したいボタンの親要素を取得する
    local bg = GET_CHILD_RECURSIVELY(frame, 'bg')
    local reforge_bg = GET_CHILD_RECURSIVELY(bg, 'reforge_bg')
    local ref_reinforce_bg = GET_CHILD_RECURSIVELY(reforge_bg, 'ref_reinforce_bg')
    local reinf_left_bg = GET_CHILD_RECURSIVELY(ref_reinforce_bg, 'reinf_left_bg')
    local cancelbutton = reinf_left_bg:CreateControl("button", "cancelbutton", 330, 100, 100, 70)
    cancelbutton:SetEventScript(ui.LBUTTONUP, "KYOUKARENDA_STOP_SCRIPT")
    cancelbutton:SetSkinName("test_red_button")
    cancelbutton:SetGravity(ui.RIGHT, ui.BOTTOM)
    cancelbutton:SetText("{@st41b}{s18}Cancel")

end

function KYOUKARENDA_STOP_SCRIPT()
    CHAT_SYSTEM("test")
    g.autoreinforce = 0
    CHAT_SYSTEM(g.autoreinforce)
    ui.SysMsg("連続強化を中断します")
    ui.SysMsg("Continuous Interrupts reinforcement")
    -- g.autoreinforce = 1
end

function KYOUKARENDA_GODDESS_MGR_REFORGE_REINFORCE_EXEC(parent, btn)
    g.autoreinforce = 1
    local frame = parent:GetTopParentFrame()

    local slot = GET_CHILD_RECURSIVELY(frame, 'ref_slot')
    local icon = slot:GetIcon()
    if icon == nil or icon:GetInfo() == nil then
        ui.SysMsg(ClMsg('NotExistTargetItem'))
        return
    end

    local mat_bg = GET_CHILD_RECURSIVELY(frame, 'reinf_main_mat_bg')
    for i = 0, mat_bg:GetChildCount() - 1 do
        local fdfd = mat_bg:GetChildByIndex(i)
        local ctrlset = GET_CHILD(mat_bg, 'GODDESS_REINF_MAT_' .. i)
        if ctrlset ~= nil and ctrlset:GetUserValue('MATERIAL_IS_SELECTED') ~= 'selected' then
            return
        end
    end

    local guid = slot:GetUserValue('ITEM_GUID')
    local inv_item = session.GetInvItemByGuid(guid)
    if inv_item == nil then
        return
    end
    local item_obj = GetIES(inv_item:GetObject())
    local item_name = dic.getTranslatedStr(TryGetProp(item_obj, 'Name', 'None'))

    local reinf_no_msgbox = GET_CHILD_RECURSIVELY(frame, 'reinf_no_msgbox')
    if reinf_no_msgbox:IsChecked() == 1 then

        _KYOUKARENDA_GODDESS_MGR_REFORGE_REINFORCE_EXEC()
    else
        local yesscp = '_GODDESS_MGR_REFORGE_REINFORCE_EXEC()'
        local msgbox = ui.MsgBox(ScpArgMsg('ReallyDoAetherGemReinforce', 'name', item_name), yesscp,
            'ENABLE_CONTROL_WITH_UI_HOLD(false)')
        SET_MODAL_MSGBOX(msgbox)
    end
end

function _KYOUKARENDA_GODDESS_MGR_REFORGE_REINFORCE_EXEC()

    local frame = ui.GetFrame('goddess_equip_manager')
    if frame == nil then
        return
    end

    local slot = GET_CHILD_RECURSIVELY(frame, 'ref_slot')
    local icon = slot:GetIcon()

    local ref_do_reinforce = GET_CHILD_RECURSIVELY(frame, 'ref_do_reinforce')

    if g.autoreinforce == 1 and ref_do_reinforce:IsEnable() == 0 and (icon ~= nil or icon:GetInfo() ~= nil) then
        CHAT_SYSTEM("TEST1")
        CHAT_SYSTEM(g.autoreinforce)
        local parent = GET_CHILD_RECURSIVELY(frame, 'reinf_left_bg')
        local btn = GET_CHILD_RECURSIVELY(parent, 'ref_ok_reinforce')
        KYOUKARENDA_GODDESS_MGR_REINFORCE_CLEAR_BTN(parent, btn)
    end

    session.ResetItemList()

    if icon == nil or icon:GetInfo() == nil then
        ui.SysMsg(ClMsg('NotExistTargetItem'))
        return
    end

    local guid = slot:GetUserValue('ITEM_GUID')
    session.AddItemID(guid, 1)

    local mat_bg = GET_CHILD_RECURSIVELY(frame, 'reinf_main_mat_bg')
    for i = 0, mat_bg:GetChildCount() - 1 do
        local ctrlset = GET_CHILD(mat_bg, 'GODDESS_REINF_MAT_' .. i)
        if ctrlset ~= nil then
            if ctrlset:GetUserValue('MATERIAL_IS_SELECTED') ~= 'selected' then
                return
            end

            local mat_name = ctrlset:GetUserValue('ITEM_NAME')
            if IS_ACCOUNT_COIN(mat_name) == false then
                local mat_item = session.GetInvItemByName(mat_name)
                local mat_guid = mat_item:GetIESID()
                local slot = GET_CHILD(ctrlset, 'slot')
                local mat_count = slot:GetEventScriptArgString(ui.DROP)
                session.AddItemID(mat_guid, tonumber(mat_count))
            end
        end
    end

    local extra_mat_list = GET_CHILD_RECURSIVELY(frame, 'reinf_extra_mat_list')
    for i = 0, extra_mat_list:GetSlotCount() - 1 do
        local _slot = extra_mat_list:GetSlotByIndex(i)
        local cnt = _slot:GetSelectCount()
        if cnt > 0 then
            local extra_mat_guid = _slot:GetUserValue('ITEM_GUID')
            if extra_mat_guid == 'None' then
                return
            end

            session.AddItemID(extra_mat_guid, cnt)
        end
    end

    local result_list = session.GetItemIDList()

    item.DialogTransaction('GODDESS_REINFORCE', result_list)

    if g.autoreinforce == 1 and ref_do_reinforce:IsEnable() == 1 and (icon ~= nil or icon:GetInfo() ~= nil) then
        CHAT_SYSTEM("TEST2")
        CHAT_SYSTEM(g.autoreinforce)
        ref_do_reinforce:SetEnable(0)
        ReserveScript("_KYOUKARENDA_GODDESS_MGR_REFORGE_REINFORCE_EXEC()", 5.0)

    else
        g.autoreinforce = 0
        CHAT_SYSTEM(g.autoreinforce)
        return
    end

end

function KYOUKARENDA_GODDESS_MGR_REINFORCE_CLEAR_BTN(parent, btn)
    local effect_frame = ui.GetFrame('result_effect_ui')
    effect_frame:ShowWindow(0)

    local frame = parent:GetTopParentFrame()

    local reinforce_value = 0
    local slot = GET_CHILD_RECURSIVELY(frame, 'ref_slot')
    local guid = slot:GetUserValue('ITEM_GUID')
    if guid ~= 'None' then
        local inv_item = session.GetInvItemByGuid(guid)
        if inv_item ~= nil then
            local item_obj = GetIES(inv_item:GetObject())
            reinforce_value = TryGetProp(item_obj, 'Reinforce_2', 0)
        end
    end

    local ref_item_reinf_text = GET_CHILD_RECURSIVELY(frame, 'ref_item_reinf_text')
    ref_item_reinf_text:SetTextByKey('value', reinforce_value)

    local result_str = frame:GetUserValue('REINFORCE_RESULT')
    if result_str == 'SUCCESS' then
        CHAT_SYSTEM("ISSUCCESS") -- tasita
        g.autoreinforce = 0 -- tasita
        GODDESS_MGR_REFORGE_REINFORCE_CLEAR(frame, true)
    else
        local ref_ok_reinforce = GET_CHILD_RECURSIVELY(frame, 'ref_ok_reinforce')
        ref_ok_reinforce:ShowWindow(0)
        local ref_do_reinforce = GET_CHILD_RECURSIVELY(frame, 'ref_do_reinforce')
        ref_do_reinforce:SetEnable(1)
        ref_do_reinforce:ShowWindow(1)

        local clear_flag = false
        local mat_bg = GET_CHILD_RECURSIVELY(frame, 'reinf_main_mat_bg')
        for i = 0, mat_bg:GetChildCount() - 1 do
            local ctrlset = GET_CHILD(mat_bg, 'GODDESS_REINF_MAT_' .. i)
            if ctrlset ~= nil then
                local slot = GET_CHILD(ctrlset, 'slot')
                local mat_name = ctrlset:GetUserValue('ITEM_NAME')
                local cur_count = '0'
                if IS_ACCOUNT_COIN(mat_name) == true then
                    local acc = GetMyAccountObj()
                    cur_count = TryGetProp(acc, mat_name, '0')
                    if cur_count == 'None' then
                        cur_count = '0'
                    end
                else
                    local mat_item = session.GetInvItemByName(mat_name)
                    if mat_item == nil then
                        clear_flag = true
                        break
                    end

                    cur_count = tostring(mat_item.count)
                end

                local need_count = slot:GetEventScriptArgString(ui.DROP)
                if math.is_larger_than(tostring(need_count), cur_count) == 1 then
                    clear_flag = true
                    break
                end
            end
        end

        local extra_mat_list = GET_CHILD_RECURSIVELY(frame, 'reinf_extra_mat_list')
        for i = 0, extra_mat_list:GetSlotCount() - 1 do
            local slot = extra_mat_list:GetSlotByIndex(i)
            local cnt = slot:GetSelectCount()
            if cnt > 0 then
                local _guid = slot:GetUserValue('ITEM_GUID')
                local extra_mat = session.GetInvItemByGuid(_guid)
                if extra_mat == nil then
                    clear_flag = true
                    break
                end

                if extra_mat.count < cnt then
                    clear_flag = true
                    break
                end
            end
        end

        if clear_flag == true then
            CHAT_SYSTEM("FLAGTRUE")
            g.autoreinforce = 0 -- tasita
            GODDESS_MGR_REFORGE_REINFORCE_CLEAR(frame)
        else
            CHAT_SYSTEM("TEST3")
            KYOUKARENDA_REFORGE_REINFORCE_MAT_COUNT_UPDATE(frame)
            KYOUKARENDA_REFORGE_REINFORCE_EXTRA_MAT_COUNT_UPDATE(frame)
            GODDESS_MGR_REINFORCE_RATE_UPDATE(frame)
            -- ReserveScript("_KYOUKARENDA_GODDESS_MGR_REFORGE_REINFORCE_EXEC()", 5.0)
        end
    end

    local tuto_prop = frame:GetUserValue('TUTO_PROP')
    if tuto_prop == 'UITUTO_GODDESSEQUIP1' then
        local tuto_value = GetUITutoProg(tuto_prop)
        if tuto_value == 4 then
            pc.ReqExecuteTx('SCR_UI_TUTORIAL_NEXT_STEP', tuto_prop)
        end
    end
end

function KYOUKARENDA_REFORGE_REINFORCE_MAT_COUNT_UPDATE(frame)
    local mat_bg = GET_CHILD_RECURSIVELY(frame, 'reinf_main_mat_bg')
    for i = 0, mat_bg:GetChildCount() - 1 do
        local ctrlset = GET_CHILD(mat_bg, 'GODDESS_REINF_MAT_' .. i)
        if ctrlset ~= nil then
            local slot = GET_CHILD(ctrlset, 'slot')
            local mat_name = ctrlset:GetUserValue('ITEM_NAME')
            local cur_count = '0'
            if IS_ACCOUNT_COIN(mat_name) == true then
                local acc = GetMyAccountObj()
                cur_count = TryGetProp(acc, mat_name, '0')
                if cur_count == 'None' then
                    cur_count = '0'
                end
            else
                local mat_item = session.GetInvItemByName(mat_name)
                if mat_item == nil then
                    cur_count = '0'
                else
                    cur_count = tostring(mat_item.count)
                end
            end

            local need_count = slot:GetEventScriptArgString(ui.DROP)
            local inv_count = GET_CHILD_RECURSIVELY(ctrlset, 'invcount')
            inv_count:SetTextByKey('have', cur_count)
            inv_count:SetTextByKey('need', need_count)
        end
    end
    -- ref_do_reinforce:SetEnable(1)
end

function KYOUKARENDA_REFORGE_REINFORCE_EXTRA_MAT_COUNT_UPDATE(frame)
    local slotset = GET_CHILD_RECURSIVELY(frame, 'reinf_extra_mat_list')
    for i = 0, slotset:GetSlotCount() - 1 do
        local slot = slotset:GetSlotByIndex(i)
        local cnt = slot:GetSelectCount()
        if cnt > 0 then
            local mat_guid = slot:GetUserValue('ITEM_GUID')
            local inv_item = session.GetInvItemByGuid(mat_guid)
            if inv_item ~= nil then
                local obj = GetIES(inv_item:GetObject())
                local icon = slot:GetIcon()
                local slotindex = slot:GetSlotIndex()
                icon:Set(obj.Icon, 'Item', inv_item.type, slotindex, inv_item:GetIESID(), inv_item.count)
                slot:SetMaxSelectCount(inv_item.count)
                SET_SLOT_ITEM_TEXT_USE_INVCOUNT(slot, inv_item, obj, inv_item.count)
            end
        end

        if cnt == 0 then
            slot:Select(0)
        end
    end
    -- ref_do_reinforce:SetEnable(1)
end
