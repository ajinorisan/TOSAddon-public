-- v1.0.2 ディレイ時間設定
-- v1.0.3 ボタンの色変更。SetupHookの競合修正
local addonName = "CONTINUERF"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.0.3"

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

g.autoreinforce = 0

if not g.loaded then
    g.settings = {

        delay = 0.8

    }
end

function CONTINUERF_ON_INIT(addon, frame)
    g.addon = addon
    g.frame = frame

    -- acutil.setupHook(CONTINUERF_GODDESS_MGR_REFORGE_REINFORCE_EXEC, "GODDESS_MGR_REFORGE_REINFORCE_EXEC")
    g.SetupHook(CONTINUERF_GODDESS_MGR_REFORGE_REINFORCE_EXEC, "_GODDESS_MGR_REFORGE_REINFORCE_EXEC")
    g.SetupHook(CONTINUERF_GODDESS_MGR_REINFORCE_CLEAR_BTN, "GODDESS_MGR_REINFORCE_CLEAR_BTN")
    -- CHAT_SYSTEM("CONTINUE_RF loaded")
    if not g.loaded then
        g.settings = {

            delay = 0.8

        }
    end
    addon:RegisterMsg('GAME_START_3SEC', 'CONTINUERF_FRAME_INIT')
    CONTINUERF_LOAD_SETTINGS()

    -- addon:RegisterMsg('GODDESS_MGR_REINFORCE_CLEAR_BTN', 'CONTINUERF_GODDESS_MGR_REINFORCE_CLEAR_BTN')
end

function CONTINUERF_FRAME_INIT()
    -- CHAT_SYSTEM("testframeinit")
    local frame = ui.GetFrame('goddess_equip_manager')
    -- 追加したいボタンの親要素を取得する
    local bg = GET_CHILD_RECURSIVELY(frame, 'bg')
    local reforge_bg = GET_CHILD_RECURSIVELY(bg, 'reforge_bg')
    local ref_reinforce_bg = GET_CHILD_RECURSIVELY(reforge_bg, 'ref_reinforce_bg')
    local reinf_left_bg = GET_CHILD_RECURSIVELY(ref_reinforce_bg, 'reinf_left_bg')
    local cancelbutton = reinf_left_bg:CreateOrGetControl("button", "cancelbutton", 0, 647, 100, 70)
    AUTO_CAST(cancelbutton)
    cancelbutton:SetEventScript(ui.LBUTTONUP, "CONTINUERF_STOP_SCRIPT")
    cancelbutton:SetSkinName("test_red_button")
    -- cancelbutton:SetGravity(ui.RIGHT, ui.BOTTOM)
    cancelbutton:SetText("{@st41b}{s18}Cancel")

    local settingbutton = reinf_left_bg:CreateOrGetControl("button", "settingbutton", 320, 600, 30, 30)
    AUTO_CAST(settingbutton)
    settingbutton:SetImage("config_button_normal")
    settingbutton:SetTextTooltip("{@st59}Left-click delay setting")
    settingbutton:SetEventScript(ui.LBUTTONUP, "CONTINUERF_SETTING_FRAME_INIT")
    -- CONTINUERF_SETTING_FRAME_INIT()

end

function CONTINUERF_SETTING_FRAME_INIT()

    -- local setframe = ui.GetFrame(addonNameLower)
    local frame = ui.GetFrame('goddess_equip_manager')
    local reinf_left_bg = GET_CHILD_RECURSIVELY(frame, 'reinf_left_bg')
    local groupbox = reinf_left_bg:CreateOrGetControl("groupbox", "bg", 270, 647, 96, 70)
    AUTO_CAST(groupbox)

    if groupbox:IsVisible() == 1 then
        groupbox:ShowWindow(0)
    else
        groupbox:ShowWindow(1)

    end

    -- local parentX, parentY = reinf_left_bg:GetX(), reinf_left_bg:GetY()
    local groupbox = reinf_left_bg:CreateOrGetControl("groupbox", "bg", 270, 647, 96, 70)
    local btn03 = groupbox:CreateOrGetControl("button", "btn03", 0, 0, 30, 33)
    AUTO_CAST(btn03)
    btn03:SetText("0.3")
    btn03:SetTextTooltip("Set the delay time to 0.3 seconds.")
    btn03:SetEventScript(ui.LBUTTONUP, "CONTINUERF_DELAY_SAVE")
    btn03:SetEventScriptArgString(ui.LBUTTONUP, "0.3")

    local btn04 = groupbox:CreateOrGetControl("button", "btn04", 32, 0, 30, 33)
    AUTO_CAST(btn04)
    btn04:SetText("0.4")
    btn04:SetTextTooltip("Set the delay time to 0.4 seconds.")
    btn04:SetEventScript(ui.LBUTTONUP, "CONTINUERF_DELAY_SAVE")
    btn04:SetEventScriptArgString(ui.LBUTTONUP, "0.4")

    local btn05 = groupbox:CreateOrGetControl("button", "btn05", 64, 0, 30, 33)
    AUTO_CAST(btn05)
    btn05:SetText("0.5")
    btn05:SetTextTooltip("Set the delay time to 0.5 seconds.")
    btn05:SetEventScript(ui.LBUTTONUP, "CONTINUERF_DELAY_SAVE")
    btn05:SetEventScriptArgString(ui.LBUTTONUP, "0.5")

    local btn06 = groupbox:CreateOrGetControl("button", "btn06", 0, 37, 30, 33)
    AUTO_CAST(btn06)
    btn06:SetText("0.6")
    btn06:SetTextTooltip("Set the delay time to 0.6 seconds.")
    btn06:SetEventScript(ui.LBUTTONUP, "CONTINUERF_DELAY_SAVE")
    btn06:SetEventScriptArgString(ui.LBUTTONUP, "0.6")

    local btn07 = groupbox:CreateOrGetControl("button", "btn07", 32, 37, 30, 33)
    AUTO_CAST(btn07)
    btn07:SetText("0.7")
    btn07:SetTextTooltip("Set the delay time to 0.7 seconds.")
    btn07:SetEventScript(ui.LBUTTONUP, "CONTINUERF_DELAY_SAVE")
    btn07:SetEventScriptArgString(ui.LBUTTONUP, "0.7")

    local btn08 = groupbox:CreateOrGetControl("button", "btn08", 64, 37, 30, 33)
    AUTO_CAST(btn08)
    btn08:SetText("0.8")
    btn08:SetTextTooltip("Set the delay time to 0.8 seconds.")
    btn08:SetEventScript(ui.LBUTTONUP, "CONTINUERF_DELAY_SAVE")
    btn08:SetEventScriptArgString(ui.LBUTTONUP, "0.8")

    -- groupbox:ShowWindow(1)
    -- groupbox:SetskinName("None")
    -- groupbox:SetLayerLevel(100)

end

function CONTINUERF_SAVE_SETTINGS()

    acutil.saveJSON(g.settingsFileLoc, g.settings)
end

function CONTINUERF_LOAD_SETTINGS()
    local settings, err = acutil.loadJSON(g.settingsFileLoc, g.settings)

    if err then
        -- 設定ファイル読み込み失敗時処理
        CHAT_SYSTEM(string.format("[%s] cannot load setting files", addonNameLower))
    end

    if not settings then

        settings = g.settings
    end
    g.delay = g.settings.delay
end

function CONTINUERF_DELAY_SAVE(frame, ctrl, argStr, argNum)
    -- frame:ShowWindow(0)
    CONTINUERF_SETTING_FRAME_INIT()
    -- ReserveScript("ONTINUERF_SETTING_FRAME_INIT()", 0.5)
    ui.SysMsg("Delay time is now set to " .. tonumber(argStr) .. " seconds")
    g.settings.delay = tonumber(argStr)
    CONTINUERF_SAVE_SETTINGS()
    CONTINUERF_LOAD_SETTINGS()
end

function CONTINUERF_STOP_SCRIPT()

    -- CHAT_SYSTEM(g.autoreinforce)
    ui.SysMsg("連続強化を中断します")
    ui.SysMsg("Continuous Interrupts reinforcement")
    local frame = ui.GetFrame('goddess_equip_manager')
    g.autoreinforce = 0
    GODDESS_MGR_REFORGE_REINFORCE_CLEAR(frame)
    -- ref_do_reinforce:SetEnable(0)
    return
end

function CONTINUERF_GODDESS_MGR_REFORGE_REINFORCE_EXEC()
    g.autoreinforce = 1
    local frame = ui.GetFrame('goddess_equip_manager')
    if frame == nil then
        return
    end

    local slot = GET_CHILD_RECURSIVELY(frame, 'ref_slot')
    local icon = slot:GetIcon()

    local ref_do_reinforce = GET_CHILD_RECURSIVELY(frame, 'ref_do_reinforce')

    if g.autoreinforce == 1 and ref_do_reinforce:IsEnable() == 0 and (icon ~= nil or icon:GetInfo() ~= nil) then
        -- CHAT_SYSTEM("TEST1")
        -- CHAT_SYSTEM(g.autoreinforce)
        local parent = GET_CHILD_RECURSIVELY(frame, 'reinf_left_bg')
        local btn = GET_CHILD_RECURSIVELY(parent, 'ref_ok_reinforce')

        CONTINUERF_GODDESS_MGR_REINFORCE_CLEAR_BTN(parent, btn)

    elseif g.autoreinforce == 1 and ref_do_reinforce:IsEnable() == 1 and (icon ~= nil or icon:GetInfo() ~= nil) then
        -- CHAT_SYSTEM("TEST2")
        -- CHAT_SYSTEM(g.autoreinforce)

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

        ref_do_reinforce:SetEnable(0)
        ReserveScript("CONTINUERF_GODDESS_MGR_REFORGE_REINFORCE_EXEC()", g.delay)
        return
    else
        g.autoreinforce = 0
        -- ref_do_reinforce:SetEnable(1)
        -- CHAT_SYSTEM(g.autoreinforce)
        return
    end
end

function CONTINUERF_GODDESS_MGR_REINFORCE_CLEAR_BTN(parent, btn)
    -- return

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
        -- CHAT_SYSTEM("ISSUCCESS") -- tasita
        g.autoreinforce = 0 -- tasita
        -- ref_do_reinforce:SetEnable(1)
        GODDESS_MGR_REFORGE_REINFORCE_CLEAR(frame, true)
        return
    else
        local ref_ok_reinforce = GET_CHILD_RECURSIVELY(frame, 'ref_ok_reinforce')
        ref_ok_reinforce:SetSkinName("baseyellow_btn")
        ref_ok_reinforce:ShowWindow(0)
        local ref_do_reinforce = GET_CHILD_RECURSIVELY(frame, 'ref_do_reinforce')
        ref_do_reinforce:SetEnable(1)
        ref_do_reinforce:ShowWindow(1)
        ref_do_reinforce:SetSkinName("relic_btn_purple")

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
        -- print(tostring(clear_flag))
        if clear_flag == true then
            -- ref_do_reinforce:SetEnable(1)
            g.autoreinforce = 0 -- tasita
            GODDESS_MGR_REFORGE_REINFORCE_CLEAR(frame)
            return
        else
            -- print("test")
            CONTINUERF_REFORGE_REINFORCE_MAT_COUNT_UPDATE(frame)
            CONTINUERF_REFORGE_REINFORCE_EXTRA_MAT_COUNT_UPDATE(frame)
            GODDESS_MGR_REINFORCE_RATE_UPDATE(frame)
            ReserveScript("CONTINUERF_GODDESS_MGR_REFORGE_REINFORCE_EXEC()", g.delay)
            return
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
