-- v1.0.2 ディレイ時間設定
-- v1.0.3 ボタンの色変更。SetupHookの競合修正
-- v1.0.4 コード見直し。装備右クリック時に素材もセットする様に変更。
-- v1.0.5 補助剤スロットのエラー修正。
-- v1.0.6 バグ再修正
local addonName = "CONTINUERF"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.0.6"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

local acutil = require("acutil")
local base = {}

function g.SetupHook(func, baseFuncName)
    local addonUpper = string.upper(addonName)
    local replacementName = addonUpper .. "_BASE_" .. baseFuncName
    if (_G[replacementName] == nil) then
        _G[replacementName] = _G[baseFuncName];
        _G[baseFuncName] = func
    end
    base[baseFuncName] = _G[replacementName]
end

g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)

function CONTINUERF_SAVE_SETTINGS()
    acutil.saveJSON(g.settingsFileLoc, g.settings)
end

function CONTINUERF_LOAD_SETTINGS()
    local settings, err = acutil.loadJSON(g.settingsFileLoc, g.settings)

    if err then
        -- 設定ファイル読み込み失敗時処理
        -- CHAT_SYSTEM(string.format("[%s] cannot load setting files", addonNameLower))
    end

    if not settings then
        settings = {
            delay = 0.5
        }
    end
    g.settings = settings
    CONTINUERF_SAVE_SETTINGS()
end

function CONTINUERF_ON_INIT(addon, frame)
    g.addon = addon
    g.frame = frame
    g.settings = g.settings or {}

    CONTINUERF_LOAD_SETTINGS()

    addon:RegisterMsg('GAME_START', 'CONTINUERF_FRAME_INIT')

    g.SetupHook(CONTINUERF_GODDESS_MGR_REFORGE_REINFORCE_EXEC, "_GODDESS_MGR_REFORGE_REINFORCE_EXEC")
    acutil.setupEvent(addon, "GODDESS_MGR_REFORGE_REG_ITEM", "CONTINUERF_GODDESS_MGR_REFORGE_REG_ITEM");

end

function CONTINUERF_GODDESS_MGR_REFORGE_REG_ITEM(frame, msg)
    local inv_item, item_obj = acutil.getEventArgs(msg)
    local frame = ui.GetFrame('goddess_equip_manager')
    local reinf_no_msgbox = GET_CHILD_RECURSIVELY(frame, 'reinf_no_msgbox')
    reinf_no_msgbox:SetCheck(1)
    local main_tab = GET_CHILD_RECURSIVELY(frame, 'main_tab')

    local index = main_tab:GetSelectItemIndex()

    if index == 0 then

        local reinf_main_mat_bg = GET_CHILD_RECURSIVELY(frame, 'reinf_main_mat_bg');
        if reinf_main_mat_bg == nil then
            return;
        end
        local child_count = reinf_main_mat_bg:GetChildCount();
        for i = 0, child_count - 1 do
            local child = reinf_main_mat_bg:GetChildByIndex(i);
            if child ~= nil and string.find(child:GetName(), "GODDESS_REINF_MAT_") ~= nil then
                local btn = GET_CHILD_RECURSIVELY(child, "btn");
                if btn ~= nil then
                    GODDESS_MGR_REFORGE_REINFORCE_REG_MAT(child, btn);
                end
            end
        end
    end

end

function CONTINUERF_FRAME_INIT()

    local frame = ui.GetFrame('goddess_equip_manager')

    local reinf_left_bg = GET_CHILD_RECURSIVELY(frame, 'reinf_left_bg')

    local cancel = reinf_left_bg:CreateOrGetControl("button", "cancel", 0, 647, 100, 70)
    AUTO_CAST(cancel)
    cancel:SetEventScript(ui.LBUTTONDOWN, "CONTINUERF_STOP_SCRIPT")
    cancel:SetSkinName("test_red_button")
    cancel:SetText("{@st41b}{s18}Cancel")

    local setting = reinf_left_bg:CreateOrGetControl("button", "setting", 0, 610, 30, 30)
    AUTO_CAST(setting)
    setting:SetSkinName("None")
    setting:SetText("{img config_button_normal 30 30}")
    setting:SetTextTooltip("{ol}}Left-click delay setting")
    setting:SetEventScript(ui.LBUTTONUP, "CONTINUERF_SETTING_FRAME_INIT")

    local ref_ok_reinforce = GET_CHILD_RECURSIVELY(frame, 'ref_ok_reinforce')
    ref_ok_reinforce:SetSkinName("baseyellow_btn")

end

function CONTINUERF_SETTING_FRAME_INIT()

    local context = ui.CreateContextMenu("SET_DELAY", "SET DELAY", 0, 0, 100, 100)
    ui.AddContextMenuItem(context, " ", "None")

    for i = 3, 8 do
        local delay = i / 10
        -- local delay = i
        ui.AddContextMenuItem(context, string.format("Set the delay time %.1f", delay),
            string.format("CONTINUERF_DELAY_SAVE(%.1f)", delay))
    end

    ui.OpenContextMenu(context)

end

function CONTINUERF_DELAY_SAVE(delay)

    ui.SysMsg("Delay time is set to " .. delay .. " seconds")
    g.settings.delay = tonumber(delay)
    CONTINUERF_SAVE_SETTINGS()

end

function CONTINUERF_STOP_SCRIPT()

    ui.SysMsg("{ol}Continuous Reinforcement Cancelled")

    local frame = ui.GetFrame('goddess_equip_manager')
    frame:StopUpdateScript("CONTINUERF__GODDESS_MGR_REFORGE_REINFORCE_EXEC");
    GODDESS_MGR_REFORGE_REINFORCE_CLEAR(frame, true)

    return
end

function CONTINUERF_GODDESS_MGR_REFORGE_REINFORCE_EXEC(parent, btn)
    local frame = ui.GetFrame('goddess_equip_manager')
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
        frame:SetUserValue('REINFORCE_RESULT', "None")
        local delay = g.settings.delay
        frame:RunUpdateScript("CONTINUERF__GODDESS_MGR_REFORGE_REINFORCE_EXEC", delay);
    else
        local yesscp = '_GODDESS_MGR_REFORGE_REINFORCE_EXEC()'
        local msgbox = ui.MsgBox(ScpArgMsg('ReallyDoAetherGemReinforce', 'name', item_name), yesscp,
            'ENABLE_CONTROL_WITH_UI_HOLD(false)')
        SET_MODAL_MSGBOX(msgbox)
    end

end

function CONTINUERF_BTN_DISPLAY(frame)
    local frame = ui.GetFrame('goddess_equip_manager')
    frame:StopUpdateScript("CONTINUERF_BTN_DISPLAY");
    local ref_do_reinforce = GET_CHILD_RECURSIVELY(frame, 'ref_do_reinforce')
    local ref_ok_reinforce = GET_CHILD_RECURSIVELY(frame, 'ref_ok_reinforce')
    ref_do_reinforce:ShowWindow(1)
    ref_do_reinforce:SetEnable(1)

    ref_ok_reinforce:ShowWindow(0)

    return 0
end

function CONTINUERF_END_OF_REINFORCE(frame)
    local frame = ui.GetFrame('goddess_equip_manager')
    frame:StopUpdateScript("CONTINUERF__GODDESS_MGR_REFORGE_REINFORCE_EXEC");

    GODDESS_MGR_REFORGE_REINFORCE_CLEAR(frame, true)

    GODDESS_MGR_REINFORCE_RATE_UPDATE(frame)

    CONTINUERF_REFORGE_REINFORCE_MAT_COUNT_UPDATE(frame)

    CONTINUERF_REFORGE_REINFORCE_EXTRA_MAT_COUNT_UPDATE(frame)

    local slot = GET_CHILD_RECURSIVELY(frame, 'ref_slot')

    local iconInfo = slot:GetIcon():GetInfo()

    local guid = iconInfo:GetIESID();

    local invItem = GET_ITEM_BY_GUID(guid);

    local obj = GetIES(invItem:GetObject());

    local ref_item_reinf_text = GET_CHILD_RECURSIVELY(frame, 'ref_item_reinf_text')

    ref_item_reinf_text:SetTextByKey('value', TryGetProp(obj, 'Reinforce_2', 0))

    local delay = g.settings.delay
    frame:RunUpdateScript("CONTINUERF_BTN_DISPLAY", delay);

end

function CONTINUERF__GODDESS_MGR_REFORGE_REINFORCE_EXEC(frame)

    if frame == nil or frame:IsVisible() == 0 then
        return 0
    end

    session.ResetItemList()

    local ref_do_reinforce = GET_CHILD_RECURSIVELY(frame, 'ref_do_reinforce')
    local ref_ok_reinforce = GET_CHILD_RECURSIVELY(frame, 'ref_ok_reinforce')
    local result_str = frame:GetUserValue('REINFORCE_RESULT')

    if result_str == 'SUCCESS' then
        CONTINUERF_END_OF_REINFORCE(frame)
        return 0
    else
        ref_do_reinforce:ShowWindow(1)

        ref_ok_reinforce:ShowWindow(0)

    end

    local slot = GET_CHILD_RECURSIVELY(frame, 'ref_slot')
    local icon = slot:GetIcon()
    if icon == nil or icon:GetInfo() == nil then
        ui.SysMsg(ClMsg('NotExistTargetItem'))

        return 0
    end

    local guid = slot:GetUserValue('ITEM_GUID')
    session.AddItemID(guid, 1)

    local mat_bg = GET_CHILD_RECURSIVELY(frame, 'reinf_main_mat_bg')
    for i = 0, mat_bg:GetChildCount() - 1 do
        local ctrlset = GET_CHILD(mat_bg, 'GODDESS_REINF_MAT_' .. i)

        if ctrlset ~= nil then
            if ctrlset:GetUserValue('MATERIAL_IS_SELECTED') ~= 'selected' then
                CONTINUERF_END_OF_REINFORCE(frame)
                return 0
            end

            local inv_count = GET_CHILD_RECURSIVELY(ctrlset, 'invcount')
            local need_count = inv_count:GetTextByKey('need')
            local have_count = inv_count:GetTextByKey('have')
            for i = 0, mat_bg:GetChildCount() - 1 do
                local ctrlset = GET_CHILD(mat_bg, 'GODDESS_REINF_MAT_' .. i)
                if tonumber(need_count) > tonumber(have_count) then

                    CONTINUERF_END_OF_REINFORCE(frame)

                    return 0
                end
            end

            local mat_name = ctrlset:GetUserValue('ITEM_NAME')

            if IS_ACCOUNT_COIN(mat_name) == false then
                local mat_item = session.GetInvItemByName(mat_name)
                local mat_guid = mat_item:GetIESID()
                -- local mat_count = slot:GetEventScriptArgString(ui.DROP)
                local mat_count = tonumber(have_count)
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

                CONTINUERF_END_OF_REINFORCE(frame)
                return 0
            end
            local inv_item = session.GetInvItemByGuid(extra_mat_guid)
            if inv_item == nil then
                _slot:ClearIcon()
                if cnt == 0 then
                    _slot:Select(0)
                end
                CONTINUERF_END_OF_REINFORCE(frame)
                return 0
            end

            session.AddItemID(extra_mat_guid, cnt)
        end
    end

    local result_list = session.GetItemIDList()

    GODDESS_MGR_REINFORCE_RATE_UPDATE(frame)

    local slotset = GET_CHILD_RECURSIVELY(frame, 'reinf_extra_mat_list')
    for i = 0, slotset:GetSlotCount() - 1 do
        local slot = slotset:GetSlotByIndex(i)
        local mat_guid = slot:GetUserValue('ITEM_GUID')
        local select_count = slot:GetSelectCount()

        if select_count ~= 0 then
            if mat_guid ~= "None" then

                local inv_item = session.GetInvItemByGuid(mat_guid)
                local cnt = 0

                if inv_item == nil then
                    slot:ClearIcon()
                    if cnt == 0 then
                        slot:Select(0)
                    end
                    CONTINUERF_END_OF_REINFORCE(frame)

                    return 0
                else
                    local obj = GetIES(inv_item:GetObject())
                    local cnt = inv_item.count
                    SET_SLOT_ITEM_TEXT_USE_INVCOUNT(slot, inv_item, obj, inv_item.count)

                    if select_count > cnt then
                        CONTINUERF_END_OF_REINFORCE(frame)

                        return 0
                    end
                end
            end
        end
    end

    item.DialogTransaction('GODDESS_REINFORCE', result_list)
    CONTINUERF_REFORGE_REINFORCE_MAT_COUNT_UPDATE(frame)
    CONTINUERF_REFORGE_REINFORCE_EXTRA_MAT_COUNT_UPDATE(frame)
    ref_do_reinforce:SetEnable(0)

    return 1
end

function CONTINUERF_REFORGE_REINFORCE_MAT_COUNT_UPDATE(frame)
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
end

function CONTINUERF_REFORGE_REINFORCE_EXTRA_MAT_COUNT_UPDATE(frame)
    local slotset = GET_CHILD_RECURSIVELY(frame, 'reinf_extra_mat_list')
    for i = 0, slotset:GetSlotCount() - 1 do
        local slot = slotset:GetSlotByIndex(i)
        local mat_guid = slot:GetUserValue('ITEM_GUID')
        local inv_item = session.GetInvItemByGuid(mat_guid)
        if inv_item ~= nil then
            local obj = GetIES(inv_item:GetObject())
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
    end
end
