-- v2.0.2 変数スコープの見直し、メンテの挙動見直し
-- v2.0.3 SetupHookの修正、メンテの挙動見直し
-- v2.0.4 全体的に見直し
-- v2.0.5 食事の時バグってたの修正。
-- v2.0.6 修正したと思ったけど修正出来てなかったのを修正
-- v2.0.7 バフ屋も付与時確認追加。
-- v2.0.8 自分がメンテ屋開店時のバグ修正
-- v2.0.9 飯屋に設定ボタン付けた。飯屋の挙動変更。その他コードリニューアル
local addon_name = "EASYBUFF"
local addon_name_lower = string.lower(addon_name)
local author = "Kiicchan"
local version = "2.0.9"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addon_name] = _G["ADDONS"][author][addon_name] or {}
local g = _G["ADDONS"][author][addon_name]
local json = require("json")

function g.mkdir_new_folder()
    local function create_folder(folder_path, file_path)
        local file = io.open(file_path, "r")
        if not file then
            os.execute('mkdir "' .. folder_path .. '"')
            file = io.open(file_path, "w")
            if file then
                file:write("A new file has been created")
                file:close()
            end
        else
            file:close()
        end
    end

    local folder = string.format("../addons/%s", addon_name_lower)
    local file_path = string.format("../addons/%s/mkdir.txt", addon_name_lower)
    create_folder(folder, file_path)

    g.active_id = session.loginInfo.GetAID()
    local user_folder = string.format("../addons/%s/%s", addon_name_lower, g.active_id)
    local user_file_path = string.format("../addons/%s/%s/mkdir.txt", addon_name_lower, g.active_id)
    create_folder(user_folder, user_file_path)

    g.settings_path = string.format("../addons/%s/%s/settings.json", addon_name_lower, g.active_id)
end
g.mkdir_new_folder()

function g.setup_hook_and_event(my_addon, origin_func_name, my_func_name, bool)

    g.FUNCS = g.FUNCS or {}
    if not g.FUNCS[origin_func_name] then
        g.FUNCS[origin_func_name] = _G[origin_func_name]
    end
    local origin_func = g.FUNCS[origin_func_name]
    local function hooked_function(...)

        local original_results

        if bool == true then
            original_results = {origin_func(...)}
        end

        g.ARGS = g.ARGS or {}
        g.ARGS[origin_func_name] = {...}
        imcAddOn.BroadMsg(origin_func_name)

        if bool == true and original_results ~= nil then
            return table.unpack(original_results)
        else
            return
        end
    end

    _G[origin_func_name] = hooked_function

    if not g.RAGISTER[origin_func_name] then -- g.RAGISTERはON_INIT内で都度初期化
        g.RAGISTER[origin_func_name] = true
        my_addon:RegisterMsg(origin_func_name, my_func_name)
    end
end

function g.get_event_args(origin_func_name)
    local args = g.ARGS[origin_func_name]
    if args then
        return table.unpack(args)
    end
    return nil
end

function g.save_settings()
    local function save_json(path, tbl)
        local file = io.open(path, "w")
        local str = json.encode(tbl)
        file:write(str)
        file:close()
    end
    save_json(g.settings_path, g.settings)
end

function g.load_settings()

    local function load_json(path)

        local file = io.open(path, "r")
        if file then
            local content = file:read("*all")
            file:close()
            local table = json.decode(content)
            return table
        else
            return nil
        end
    end

    local settings = load_json(g.settings_path)

    if not settings then
        settings = {}
    end

    g.settings = settings
    g.save_settings()
end

function g.settings_make()

    if next(g.settings) then
        return
    end

    g.settings = {
        use = 0,
        confirm = 1,
        food_presets_check = {
            ["1"] = {
                ["1"] = 1,
                ["2"] = 1,
                ["3"] = 1,
                ["4"] = 1,
                ["5"] = 1,
                ["6"] = 1
            },
            ["2"] = {
                ["1"] = 1,
                ["2"] = 1,
                ["3"] = 1,
                ["4"] = 1,
                ["5"] = 1,
                ["6"] = 1
            },
            ["3"] = {
                ["1"] = 1,
                ["2"] = 1,
                ["3"] = 1,
                ["4"] = 1,
                ["5"] = 1,
                ["6"] = 1
            },
            ["4"] = {
                ["1"] = 1,
                ["2"] = 1,
                ["3"] = 1,
                ["4"] = 1,
                ["5"] = 1,
                ["6"] = 1
            }
        },
        food_presets_name = {
            ["1"] = "preset 1",
            ["2"] = "preset 2",
            ["3"] = "preset 3",
            ["4"] = "preset 4"
        }
    }
    g.save_settings()
end

g.loaded = false
function EASYBUFF_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame

    g.lang = option.GetCurrentCountry()

    g.RAGISTER = {}

    if not g.loaded then
        g.load_settings()

        g.settings_make()
        g.loaded = true
    end

    g.setup_hook_and_event(addon, "OPEN_FOOD_TABLE_UI", "easybuff_OPEN_FOOD_TABLE_UI", true)
    g.setup_hook_and_event(addon, "ITEMBUFF_REPAIR_UI_COMMON", "easybuff_ITEMBUFF_REPAIR_UI_COMMON", true)
    g.setup_hook_and_event(addon, "SQUIRE_BUFF_EQUIP_CTRL", "EASYBUFF_SQUIRE_BUFF_EQUIP_CTRL", true)
    g.setup_hook_and_event(addon, "SQIORE_TARGET_UI_CLOSE", "EASYBUFF_SQUIRE_TARGET_UI_CLOSE", true)
    g.setup_hook_and_event(addon, "TARGET_BUFF_AUTOSELL_LIST", "easybuff_TARGET_BUFF_AUTOSELL_LIST", true)

    g.buff_first = true
end

-- バフ屋

function easybuff_buy_buffs(handle, sell_type, item_count, current_buff_index)

    if current_buff_index < tonumber(item_count) then
        session.autoSeller.Buy(handle, current_buff_index, 1, sell_type)
        current_buff_index = current_buff_index + 1
        local reserve_script_str = string.format("easybuff_buy_buffs(%d, %d, %d, %d)", handle, sell_type, item_count,
                                                 current_buff_index)
        ReserveScript(reserve_script_str, 0.6)
        return
    else
        easybuff_end_process()
    end
end

function easybuff_end_process()
    local frame = ui.GetFrame("buffseller_target")
    if frame then
        frame:ShowWindow(0)
    end
    g.buff_first = true
end

function easybuff_TARGET_BUFF_AUTOSELL_LIST(frame, msg)

    local group_name, sell_type, handle = g.get_event_args(msg)

    if g.settings.use == 1 then
        return
    end

    if sell_type ~= 0 then
        return
    end

    local item_info = session.autoSeller.GetByIndex(group_name, 0)
    if not item_info then
        ui.SysMsg(g.lang == "Japanese" and "バフアイテムが見つかりません" or "No buff item found")
        return
    end

    if not g.buff_first then
        return
    end

    g.buff_first = false

    local item_count = session.autoSeller.GetCount(group_name)
    local my_handle = session.GetMyHandle()
    local buff_ids_to_check = {358, 359, 360, 370}

    local needs_rebuff = false

    for _, buff_id in ipairs(buff_ids_to_check) do
        local buff = info.GetBuff(my_handle, buff_id)
        if not buff then
            needs_rebuff = true
            break
        end

        local buff_time = buff.time
        if buff_time <= 3600000 then
            needs_rebuff = true
            break
        end
    end

    if needs_rebuff then
        easybuff_buy_buffs(handle, sell_type, item_count, 0)
        return
    else
        if g.settings.confirm == 1 then
            local msg_text = g.lang == "Japanese" and "{#FFFFFF}{ol}バフをかけ直しますか？" or
                                 "{#FFFFFF}{ol}Do you want to reapply the buff?"
            local yes_script = string.format("easybuff_buy_buffs(%d, %d, %d, %d)", handle, sell_type, item_count, 0)
            local no_script = "easybuff_end_process()" -- キャンセル時は終了処理
            ui.MsgBox(msg_text, yes_script, no_script)
        else
            easybuff_buy_buffs(handle, sell_type, item_count, 0)
            return
        end
    end
end

-- メンテ処理

function EASYBUFF_SQUIRE_TARGET_UI_CLOSE()
    packet.StopTimeAction(1)
end

function EASYBUFF_SQUIRE_TARGET_UI_CLOSE_(frame)

    local frame = ui.GetFrame("itembuffopen")
    frame:ShowWindow(0)
    return 0
end

function EASYBUFF_SQUIRE_BUFF_EQUIP_CTRL_DELAY()

    local frame = ui.GetFrame("itembuffopen")
    if session.GetMyHandle() == frame:GetUserIValue("HANDLE") then
        return
    end
    local checkall = GET_CHILD_RECURSIVELY(frame, 'checkall')
    AUTO_CAST(checkall)
    checkall:SetCheck(1)

    SQUIRE_BUFF_EQUIP_SELECT_ALL(frame, checkall)
    local ctrl = GET_CHILD_RECURSIVELY(frame, "btn_excute")
    -- 
    SQUIRE_BUFF_EXCUTE(frame, ctrl)
    local str = g.lang == "Japanese" and
                    "{#FFFFFF}{ol}装備メンテナンス自動付与中{nl}フレームを閉じればキャンセルします" or
                    "{#FFFFFF}{ol}Equipment maintenance automatic grant is in progress.{nl}Canceled when frame is closed."
    ui.SysMsg(str)
    frame:StopUpdateScript("EASYBUFF_SQUIRE_BUFF_EQUIP_CTRL_DELAY")
    frame:RunUpdateScript("EASYBUFF_SQUIRE_TARGET_UI_CLOSE_", 5.5)
end

function EASYBUFF_SQUIRE_BUFF_EQUIP_CTRL(frame, msg)

    if g.settings.use == 1 then
        return
    end
    local frame = ui.GetFrame("itembuffopen")
    frame:StopUpdateScript("EASYBUFF_SQUIRE_TARGET_UI_CLOSE_")
    frame:RunUpdateScript("EASYBUFF_SQUIRE_BUFF_EQUIP_CTRL_DELAY", 0.5)
    return
end

-- Repair buff
function easybuff_ITEMBUFF_REPAIR_UI_COMMON(frame, msg)

    if g.settings.use == 1 then
        return
    end

    local itembuffrepair = ui.GetFrame("itembuffrepair")
    if itembuffrepair then
        session.ResetItemList()

        local handle = itembuffrepair:GetUserValue("HANDLE")
        local skill_name = itembuffrepair:GetUserValue("SKILLNAME")
        local slot_set = GET_CHILD_RECURSIVELY(itembuffrepair, "slotlist", "ui::CSlotSet")
        local slot_count = slot_set:GetSlotCount()

        local cheapest = nil
        local price = 0
        for i = 0, slot_count - 1 do
            local slot = slot_set:GetSlotByIndex(i)
            if slot:GetIcon() then
                local icon = slot:GetIcon()
                local icon_info = icon:GetInfo()
                local invitem = GET_ITEM_BY_GUID(icon_info:GetIESID())
                local itemobj = GetIES(invitem:GetObject())
                local need_item, need_count = ITEMBUFF_NEEDITEM_Squire_Repair(GetMyPCObject(), itemobj)

                if need_count < price or price == 0 then
                    cheapest = slot
                    price = need_count
                end
            end
        end
        if cheapest then
            local icon = cheapest:GetIcon()
            local icon_info = icon:GetInfo()
            session.AddItemID(icon_info:GetIESID())
        end

        session.autoSeller.BuyItems(handle, AUTO_SELL_SQUIRE_BUFF, session.GetItemIDList(), skill_name)
        imcSound.PlaySoundEvent('system_craft_potion_succes')
    end
end

function easybuff_config_frame_close(frame, ctrl)
    frame:ShowWindow(0)
end

function easybuff_config_check_toggle(parent, ctrl)

    local ctrl_name = ctrl:GetName()
    local is_check = ctrl:IsChecked()
    if ctrl_name == "use_check" then
        g.settings.use = is_check
        local foodtable_ui = ui.GetFrame("foodtable_ui")
        easybuff_OPEN_FOOD_TABLE_UI(foodtable_ui)
    elseif ctrl_name == "confirm_check" then
        g.settings.confirm = is_check
    else
        local preset_str, check_str = string.match(ctrl_name, "^check_(%d)_(%d)$")
        g.settings.food_presets_check[preset_str][check_str] = is_check
    end
    g.save_settings()

end

function easybuff_check_ui_close(frame)
    local foodtable_ui = ui.GetFrame("foodtable_ui")
    if foodtable_ui:IsVisible() == 1 then
        return 1
    else
        local easybuff = ui.GetFrame("easybuff")
        easybuff:ShowWindow(0)
        return 0
    end
end

function easybuff_config_presetname_change(frame, ctrl)

    local ctrl_name = ctrl:GetName()
    local last_char = string.sub(ctrl_name, -1)
    local text = ctrl:GetText()
    g.settings.food_presets_name[last_char] = text
    g.save_settings()
    easybuff_OPEN_FOOD_TABLE_UI(frame)
end

function easybuff_config_frame(frame, ctrl, str, num)

    local frame = ui.GetFrame("easybuff")
    frame:RemoveAllChild()
    frame:SetSkinName("test_frame_low")
    frame:SetLayerLevel(80)
    frame:Resize(470, 410)
    frame:SetPos(480, 100)
    frame:SetTitleBarSkin("None")
    frame:EnableHittestFrame(1)
    frame:EnableHitTest(1)
    frame:ShowWindow(1)
    frame:RunUpdateScript("easybuff_check_ui_close", 0.1)

    local title_text = frame:CreateOrGetControl('richtext', 'title_text', 20, 15, 50, 30)
    AUTO_CAST(title_text)
    title_text:SetText("{ol}Easy Buff Config")

    local close = frame:CreateOrGetControl("button", "close", 0, 0, 20, 20)
    AUTO_CAST(close)
    close:SetImage("testclose_button")
    close:SetGravity(ui.RIGHT, ui.TOP)
    close:SetEventScript(ui.LBUTTONUP, "easybuff_config_frame_close")

    local gbox = frame:CreateOrGetControl("groupbox", "gbox", 10, 40, frame:GetWidth() - 20, frame:GetHeight() - 50)
    AUTO_CAST(gbox)
    gbox:SetSkinName("test_frame_midle_light")

    local icons = {"icon_item_sandwich", "icon_item_soup", "icon_item_yogurt", "icon_item_salad", "icon_item_BBQ",
                   "icon_item_champagne"}
    local x_offsets = {5, 75, 145, 215, 285, 355}
    local y = 0
    for i = 1, 4 do

        local str_i = tostring(i)

        local title_edit = gbox:CreateOrGetControl('edit', "preset_title_" .. i, 10, y + 5, 80, 20)
        AUTO_CAST(title_edit)
        title_edit:SetFontName('white_14_ol')
        title_edit:SetSkinName('test_weight_skin')
        title_edit:SetTextAlign('center', 'center')
        title_edit:SetText(g.settings.food_presets_name[str_i])
        if str_i == "1" then
            title_edit:Focus()
        end
        title_edit:SetEventScript(ui.ENTERKEY, "easybuff_config_presetname_change")

        local preset_gbox = gbox:CreateOrGetControl("groupbox", "preset_gbox_" .. i, 10, y + 30, gbox:GetWidth() - 20,
                                                    40)
        AUTO_CAST(preset_gbox)
        preset_gbox:SetSkinName("test_frame_midle_light")

        for check_index = 1, #icons do

            local str_index = tostring(check_index)
            local icon_name = icons[check_index]
            local checkbox_x = x_offsets[check_index]

            local checkbox_name = "check_" .. i .. "_" .. check_index
            local checkbox_ctrl = preset_gbox:CreateOrGetControl('checkbox', checkbox_name, checkbox_x, 5, 30, 30)

            AUTO_CAST(checkbox_ctrl)
            checkbox_ctrl:SetText("{img " .. icon_name .. " 30 30}")
            checkbox_ctrl:SetCheck(g.settings.food_presets_check[str_i][str_index])
            checkbox_ctrl:SetEventScript(ui.LBUTTONUP, "easybuff_config_check_toggle")
        end
        y = y + 70
    end

    local use_check = gbox:CreateOrGetControl('checkbox', "use_check", 10, y + 10, 30, 30)
    AUTO_CAST(use_check)
    use_check:SetText(g.lang == "Japanese" and "{ol}チェックするとアドオン無効化" or
                          "{ol}Check to disable addon")
    use_check:SetEventScript(ui.LBUTTONUP, "easybuff_config_check_toggle")
    use_check:SetCheck(g.settings.use or 0)

    local confirm_check = gbox:CreateOrGetControl('checkbox', "confirm_check", 10, y + 45, 30, 30)
    AUTO_CAST(confirm_check)
    confirm_check:SetText(g.lang == "Japanese" and
                              "{ol}チェックするとバフ掛け直し確認(残り1時間以上)" or
                              "{ol}Check to Confirm Re-buffing (remaining over 1h)")
    confirm_check:SetEventScript(ui.LBUTTONUP, "easybuff_config_check_toggle")
    confirm_check:SetCheck(g.settings.confirm or 1)

end

function easybuff_OPEN_FOOD_TABLE_UI(frame, msg)

    local frame = ui.GetFrame("foodtable_ui")

    if g.settings.use == 0 then
        local x = 85
        for i = 1, 4 do

            local str_i = tostring(i)
            local button_ctrl = frame:CreateOrGetControl("button", "btn" .. i, x, 50, 90, 30)
            AUTO_CAST(button_ctrl)
            button_ctrl:SetText("")
            button_ctrl:SetSkinName("test_red_button")
            local text = g.settings.food_presets_name[str_i]
            button_ctrl:SetText("{ol}" .. text)
            button_ctrl:SetEventScript(ui.LBUTTONUP, "easybuff_clear_food_buff_timer")
            x = x + 95
        end
    else
        for i = 1, 4 do
            local button_ctrl = GET_CHILD(frame, "btn" .. i)
            if button_ctrl then
                local button_ctrl_name = button_ctrl:GetName()
                frame:RemoveChild(button_ctrl_name)
            end
        end
    end
    local setbtn = frame:CreateOrGetControl("button", "set", 425, 85, 30, 30)
    AUTO_CAST(setbtn)
    setbtn:SetSkinName("None")
    setbtn:SetText("{img config_button_normal 30 30}")
    setbtn:SetTextTooltip(g.lang == "Japanese" and "{ol}Easy Buff 設定" or "{ol}Easy Buff Config")
    setbtn:SetEventScript(ui.LBUTTONUP, "easybuff_config_frame")

end

function easybuff_clear_food_buff_timer(frame, button_ctrl)

    button_ctrl:RunUpdateScript("easybuff_clear_food_buff", 0.2)
end

local food_buffs = {4021, 4022, 4023, 4024, 4087, 4136}

function easybuff_clear_food_buff(button_ctrl)

    local my_handle = session.GetMyHandle()
    for _, buff_id in ipairs(food_buffs) do
        local buff = info.GetBuff(my_handle, buff_id)
        if buff then
            packet.ReqRemoveBuff(buff_id)
            return 1
        end
    end

    button_ctrl:StopUpdateScript("easybuff_clear_food_buff")

    g.temp_food = {}
    local last_char = string.sub(button_ctrl:GetName(), -1)
    for key, value in pairs(g.settings.food_presets_check[last_char]) do

        if value == 1 then
            local numeric_key = tonumber(key)

            if numeric_key then
                table.insert(g.temp_food, numeric_key - 1)
            end
        end
    end

    table.sort(g.temp_food, function(a, b)
        return a > b
    end)
    if next(g.temp_food) then
        easybuff_eat_food(button_ctrl)
        button_ctrl:RunUpdateScript("easybuff_eat_food", 0.6)
    end
    return 0
end

function easybuff_eat_food(button_ctrl)
    local frame = ui.GetFrame("foodtable_ui")
    local handle = frame:GetUserIValue("HANDLE")
    local sell_type = frame:GetUserIValue("SELLTYPE")
    if next(g.temp_food) then
        session.autoSeller.Buy(handle, g.temp_food[#g.temp_food], 1, sell_type)
        table.remove(g.temp_food)
        imcSound.PlaySoundEvent('system_craft_potion_succes')
        return 1
    else
        frame:ShowWindow(0)
        return 0
    end
end

function EASYBUFF_LANG(str)

    local langcode = option.GetCurrentCountry()

    if langcode == "Japanese" then

        if str == "{#FFFFFF}{ol}Equipment maintenance automatic grant is in progress.{nl}Canceled when frame is closed." then
            str =
                "{#FFFFFF}{ol}装備メンテナンス自動付与中。{nl}フレームを閉じればキャンセルします。"
        end

        if str == "{#FFFFFF}{ol}Remove food buffs?" then
            str = "{#FFFFFF}{ol}フードバフ削除しますか？"
        end
        -- {#FFFFFF}{ol}Food buff removed.
        if str == "{#FFFFFF}{ol}Food buff removed." then
            str = "{#FFFFFF}{ol}フードバフを削除しました。"
        end
        -- "{#FFFFFF}{ol}Do you want to re-buff it?"
        if str == "{#FFFFFF}{ol}Do you want to re-buff it?" then
            str = "{#FFFFFF}{ol}バフをかけ直しますか？"
        end
    end
    return str

end

