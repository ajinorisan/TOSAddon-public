local addonName = "KYOUKARENDA"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "0.0.1"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

local acutil = require("acutil")

function KYOUKARENDA_ON_INIT(addon, frame)
    g.addon = addon
    g.frame = frame

    acutil.setupHook(KYOUKARENDA_GODDESS_MGR_REFORGE_REINFORCE_EXEC, "GODDESS_MGR_REFORGE_REINFORCE_EXEC")
    acutil.setupHook(_KYOUKARENDA_GODDESS_MGR_REFORGE_REINFORCE_EXEC, "_GODDESS_MGR_REFORGE_REINFORCE_EXEC")
    CHAT_SYSTEM("kyoukarenda loaded")
end

function KYOUKARENDA_GODDESS_MGR_REFORGE_REINFORCE_EXEC(parent, btn)
    local autoenhancement = 0
    local frame = parent:GetTopParentFrame()
    -- 追加したいボタンの親要素を取得する
    local bg = GET_CHILD_RECURSIVELY(frame, 'bg')
    local reforge_bg = GET_CHILD_RECURSIVELY(frame, 'reforge_bg')
    local ref_reinforce_bg = GET_CHILD_RECURSIVELY(frame, 'ref_reinforce_bg')
    local reinf_left_bg = GET_CHILD_RECURSIVELY(frame, 'reinf_left_bg')
    local cancelbutton = reinf_left_bg:CreateControl("button", "cancelbutton", 330, 0, 100, 70)
    cancelbutton:SetSkinName("test_red_button")
    cancelbutton:SetGravity(ui.RIGHT, ui.BOTTOM)
    cancelbutton:SetText("{@st41b}{s18}Cancel")
    cancelbutton:PlaySoundEvent("button_click_big")
    cancelbutton:SetEventScript(ui.LBUTTONUP, "KYOUKARENDA_STOP_SCRIPT")

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
        _KYOUKARENDA_GODDESS_MGR_REFORGE_REINFORCE_EXEC(autoenhancement)
    else
        local yesscp = '_GODDESS_MGR_REFORGE_REINFORCE_EXEC()'
        local msgbox = ui.MsgBox(ScpArgMsg('ReallyDoAetherGemReinforce', 'name', item_name), yesscp,
            'ENABLE_CONTROL_WITH_UI_HOLD(false)')
        SET_MODAL_MSGBOX(msgbox)
    end
end

function KYOUKARENDA_STOP_SCRIPT()
    local autoenhancement = 1
    ui.SysMsg("連続強化を中断します")
    ui.SysMsg("Continuous Interrupts reinforcement")

end

function _KYOUKARENDA_GODDESS_MGR_REFORGE_REINFORCE_EXEC(autoenhancement)

    local frame = ui.GetFrame('goddess_equip_manager')
    if frame == nil then
        return
    end

    session.ResetItemList()

    local slot = GET_CHILD_RECURSIVELY(frame, 'ref_slot')
    local icon = slot:GetIcon()
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

    local ref_do_reinforce = GET_CHILD_RECURSIVELY(frame, 'ref_do_reinforce')

    if autoenhancement == 0 and ref_do_reinforce:IsEnable() == 0 and (icon ~= nil or icon:GetInfo() ~= nil) then
        local parent = GET_CHILD_RECURSIVELY(frame, 'reinf_left_bg')
        local btn = GET_CHILD_RECURSIVELY(frame, 'ref_ok_reinforce')
        GODDESS_MGR_REINFORCE_CLEAR_BTN(parent, btn)
        ref_do_reinforce:SetEnable(1)
        ReserveScript("_KYOUKARENDA_GODDESS_MGR_REFORGE_REINFORCE_EXEC()", 5.0)

    elseif autoenhancement == 0 and (icon ~= nil or icon:GetInfo() ~= nil) then
        ref_do_reinforce:SetEnable(0)
        ReserveScript("_KYOUKARENDA_GODDESS_MGR_REFORGE_REINFORCE_EXEC()", 5.0)

    else
        local autoenhancement = 1
        return
    end

end
