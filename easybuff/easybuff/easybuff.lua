-- v2.0.2 変数スコープの見直し、メンテの挙動見直し
-- v2.0.3 SetupHookの修正、メンテの挙動見直し
-- v2.0.4 全体的に見直し
-- v2.0.5 食事の時バグってたの修正。
-- v2.0.6 修正したと思ったけど修正出来てなかったのを修正
-- v2.0.7 バフ屋も付与時確認追加。
-- v2.0.8 自分がメンテ屋開店時のバグ修正
-- v2.0.9 飯屋に設定ボタン付けた。飯屋の挙動変更。その他コードリニューアル
-- v2.1.0 メンテ屋のキャンセルバグ修正。僭越コード導入。飯屋UI変更
local addon_name = "EASYBUFF"
local addon_name_lower = string.lower(addon_name)
local author = "Kiicchan"
local version = "2.1.0"

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

    if not g.REGISTER[origin_func_name] then -- g.REGISTERはON_INIT内で都度初期化
        g.REGISTER[origin_func_name] = true
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

    g.REGISTER = {}

    if not g.loaded then
        g.load_settings()

        g.settings_make()
        g.loaded = true
    end

    local menu_data = {
        name = "Easy Buff",
        icon = "",
        func = "easybuff_config_frame",
        image = "{img icon_item_sandwich 30 30}"
    }
    _G["norisan"]["MENU"][addon_name] = menu_data

    if not _G["norisan"]["MENU"][addon_name_lower] or _G["norisan"]["MENU"].frame_name == addon_name_lower then
        _G["norisan"]["MENU"].frame_name = addon_name_lower
        addon:RegisterMsg("GAME_START", "norisan_menu_create_frame")
    end

    g.setup_hook_and_event(addon, "OPEN_FOOD_TABLE_UI", "easybuff_OPEN_FOOD_TABLE_UI", true)
    g.setup_hook_and_event(addon, "ITEMBUFF_REPAIR_UI_COMMON", "easybuff_ITEMBUFF_REPAIR_UI_COMMON", true)
    g.setup_hook_and_event(addon, "SQUIRE_BUFF_EQUIP_CTRL", "EASYBUFF_SQUIRE_BUFF_EQUIP_CTRL", true)

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

function EASYBUFF_SQIORE_TARGET_UI_CLOSE(frame, ctrl)

    packet.StopTimeAction(1)
    ui.CloseFrame("itembuffopen");
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

    local close = GET_CHILD_RECURSIVELY(frame, 'close')
    AUTO_CAST(close)
    close:SetEventScript(ui.LBUTTONUP, "EASYBUFF_SQIORE_TARGET_UI_CLOSE")

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
        -- local foodtable_ui = ui.GetFrame("foodtable_ui")
        -- easybuff_OPEN_FOOD_TABLE_UI(foodtable_ui)
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
    local msg = g.lang == "Japanese" and text .. "{ol} 設定しました" or "{ol} Set up"
    ui.SysMsg(msg)
    g.settings.food_presets_name[last_char] = text
    g.save_settings()
    -- easybuff_OPEN_FOOD_TABLE_UI(frame)
end

function easybuff_config_frame(frame, ctrl, str, num)

    local frame = ui.GetFrame("easybuff")
    frame:RemoveAllChild()
    frame:SetSkinName("test_frame_low")
    frame:SetLayerLevel(80)
    frame:Resize(470, 410)
    -- frame:SetPos(480, 100)
    frame:SetGravity(ui.CENTER_HORZ, ui.CENTER_VERT);
    frame:SetTitleBarSkin("None")
    frame:EnableHittestFrame(1)
    frame:EnableHitTest(1)
    frame:ShowWindow(1)
    -- frame:RunUpdateScript("easybuff_check_ui_close", 0.1)

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
        local x = 300
        local y = 60
        for i = 1, 4 do

            local str_i = tostring(i)
            local button_ctrl = frame:CreateOrGetControl("button", "btn" .. i, x, y, 85, 30)
            AUTO_CAST(button_ctrl)
            -- button_ctrl:SetText("")
            button_ctrl:SetSkinName("test_red_button")
            local text = g.settings.food_presets_name[str_i]
            button_ctrl:SetText("{ol}" .. text)
            button_ctrl:SetEventScript(ui.LBUTTONUP, "easybuff_clear_food_buff_timer")
            if button_ctrl:GetWidth() >= 85 then
                button_ctrl:Resize(85, 30)
            end

            if i == 1 then
                x = x + 80
            elseif i == 2 then
                x = 300
                y = 90
            elseif i == 3 then
                x = x + 80
            end
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
    --[[local setbtn = frame:CreateOrGetControl("button", "set", 425, 85, 30, 30)
    AUTO_CAST(setbtn)
    setbtn:SetSkinName("None")
    setbtn:SetText("{img config_button_normal 30 30}")
    setbtn:SetTextTooltip(g.lang == "Japanese" and "{ol}Easy Buff 設定" or "{ol}Easy Buff Config")
    setbtn:SetEventScript(ui.LBUTTONUP, "easybuff_config_frame")]]

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

-- アドオンメニューボタン
local norisan_menu_addons = string.format("../%s", "addons")
local norisan_menu_addons_mkfile = string.format("../%s/mkdir.txt", "addons")
local norisan_menu_settings = string.format("../addons/%s/settings.json", "norisan_menu")
local norisan_menu_folder = string.format("../addons/%s", "norisan_menu")
local norisan_menu_mkfile = string.format("../addons/%s/mkdir.txt", "norisan_menu")
_G["norisan"] = _G["norisan"] or {}
_G["norisan"]["MENU"] = _G["norisan"]["MENU"] or {}

local json = require("json")

local function norisan_menu_create_folder_file()

    local addons_file = io.open(norisan_menu_addons_mkfile, "r")
    if not addons_file then
        os.execute('mkdir "' .. norisan_menu_addons .. '"')
        addons_file = io.open(norisan_menu_addons_mkfile, "w")
        if addons_file then
            addons_file:write("created");
            addons_file:close()
        end
    else
        addons_file:close()
    end

    local file = io.open(norisan_menu_mkfile, "r")
    if not file then
        os.execute('mkdir "' .. norisan_menu_folder .. '"')
        file = io.open(norisan_menu_mkfile, "w")
        if file then
            file:write("created");
            file:close()
        end
    else
        file:close()
    end
end
norisan_menu_create_folder_file()

local function norisan_menu_save_json(path, tbl)

    local data_to_save = {
        x = tbl.x,
        y = tbl.y,
        move = tbl.move,
        open = tbl.open,
        layer = tbl.layer
    }
    local file = io.open(path, "w")
    if file then
        local str = json.encode(data_to_save)
        file:write(str)
        file:close()
    end
end

local function norisan_menu_load_json(path)

    local file = io.open(path, "r")
    if file then
        local content = file:read("*all")
        file:close()
        if content and content ~= "" then
            local decoded, err = json.decode(content)
            if decoded then
                return decoded
            end
        end
    end
    return nil
end

function _G.norisan_menu_move_drag(frame, ctrl)
    if not frame then
        return
    end

    local current_frame_y = frame:GetY()
    local current_frame_h = frame:GetHeight()
    local base_button_h = 40

    local y_to_save = current_frame_y

    if current_frame_h > base_button_h and (_G["norisan"]["MENU"].open == 1) then
        local items_area_h_calculated = current_frame_h - base_button_h
        y_to_save = current_frame_y + items_area_h_calculated

    end

    _G["norisan"]["MENU"].x = frame:GetX()
    _G["norisan"]["MENU"].y = y_to_save

    norisan_menu_save_json(norisan_menu_settings, _G["norisan"]["MENU"])
end

function _G.norisan_menu_setting_frame_ctrl(setting, ctrl)
    local ctrl_name = ctrl:GetName()

    local frame_name = _G["norisan"]["MENU"].frame_name
    local frame = ui.GetFrame(frame_name)

    if ctrl_name == "layer_edit" then
        local layer = tonumber(ctrl:GetText())
        if layer then
            _G["norisan"]["MENU"].layer = layer
            frame:SetLayerLevel(layer)
            norisan_menu_save_json(norisan_menu_settings, _G["norisan"]["MENU"])

            local notice = _G["norisan"]["MENU"].lang == "Japanese" and "{ol}レイヤーを変更" or
                               "{ol}Change Layer"
            ui.SysMsg(notice)
            _G.norisan_menu_create_frame()
            setting:ShowWindow(0)
            return
        end
    end

    if ctrl_name == "def_setting" then

        _G["norisan"]["MENU"].x = 1190
        _G["norisan"]["MENU"].y = 30
        _G["norisan"]["MENU"].move = true
        _G["norisan"]["MENU"].open = 0
        _G["norisan"]["MENU"].layer = 79
        norisan_menu_save_json(norisan_menu_settings, _G["norisan"]["MENU"])
        _G.norisan_menu_create_frame()
        setting:ShowWindow(0)
        return
    end
    if ctrl_name == "close" then
        setting:ShowWindow(0)
        return
    end

    local is_check = ctrl:IsChecked()
    if ctrl_name == "move_toggle" then
        if is_check == 1 then
            _G["norisan"]["MENU"].move = false
        else
            _G["norisan"]["MENU"].move = true
        end
        frame:EnableMove(_G["norisan"]["MENU"].move == true and 1 or 0)
        norisan_menu_save_json(norisan_menu_settings, _G["norisan"]["MENU"])
        return
    elseif ctrl_name == "open_toggle" then
        _G["norisan"]["MENU"].open = is_check
        norisan_menu_save_json(norisan_menu_settings, _G["norisan"]["MENU"])
        _G.norisan_menu_create_frame()
        return
    end

end

function _G.norisan_menu_setting_frame(frame, ctrl)
    local setting = ui.CreateNewFrame("chat_memberlist", "norisan_menu_setting", 0, 0, 0, 0)
    AUTO_CAST(setting)

    setting:SetTitleBarSkin("None")
    setting:SetSkinName("chat_window")
    setting:Resize(260, 135)
    setting:SetLayerLevel(999)
    setting:EnableHitTest(1)
    setting:EnableMove(1)

    setting:SetPos(frame:GetX() + 200, frame:GetY())
    setting:ShowWindow(1)

    local close = setting:CreateOrGetControl("button", "close", 0, 0, 30, 30)
    AUTO_CAST(close)
    close:SetImage("testclose_button")
    close:SetGravity(ui.RIGHT, ui.TOP)
    close:SetEventScript(ui.LBUTTONUP, "norisan_menu_setting_frame_ctrl");

    local def_setting = setting:CreateOrGetControl("button", "def_setting", 10, 5, 150, 30)
    AUTO_CAST(def_setting)
    local notice = _G["norisan"]["MENU"].lang == "Japanese" and "{ol}デフォルトに戻す" or "{ol}Reset to default"
    def_setting:SetText(notice)
    def_setting:SetEventScript(ui.LBUTTONUP, "norisan_menu_setting_frame_ctrl");

    local move_toggle = setting:CreateOrGetControl('checkbox', "move_toggle", 10, 35, 30, 30)
    AUTO_CAST(move_toggle)
    move_toggle:SetCheck(_G["norisan"]["MENU"].move == true and 0 or 1)
    move_toggle:SetEventScript(ui.LBUTTONDOWN, 'norisan_menu_setting_frame_ctrl')
    local notice = _G["norisan"]["MENU"].lang == "Japanese" and "{ol}チェックするとフレーム固定" or
                       "{ol}Check to fix frame"
    move_toggle:SetText(notice)

    local open_toggle = setting:CreateOrGetControl('checkbox', "open_toggle", 10, 70, 30, 30)
    AUTO_CAST(open_toggle)
    open_toggle:SetCheck(_G["norisan"]["MENU"].open)
    open_toggle:SetEventScript(ui.LBUTTONDOWN, 'norisan_menu_setting_frame_ctrl')
    local notice = _G["norisan"]["MENU"].lang == "Japanese" and "{ol}チェックすると上開き" or
                       "{ol}Check to open upward"
    open_toggle:SetText(notice)

    local layer_text = setting:CreateOrGetControl('richtext', 'layer_text', 10, 105, 50, 20)
    AUTO_CAST(layer_text)
    local notice = _G["norisan"]["MENU"].lang == "Japanese" and "{ol}レイヤー設定" or "{ol}Set Layer"
    layer_text:SetText(notice)

    local layer_edit = setting:CreateOrGetControl('edit', 'layer_edit', 130, 105, 70, 20)
    AUTO_CAST(layer_edit)
    layer_edit:SetFontName("white_16_ol")
    layer_edit:SetTextAlign("center", "center")
    layer_edit:SetText(_G["norisan"]["MENU"].layer or 79)
    layer_edit:SetEventScript(ui.ENTERKEY, "norisan_menu_setting_frame_ctrl")
end

function _G.norisan_menu_toggle_items_display(frame, ctrl, open_dir)

    local open_up = (open_dir == 1)

    local menu_src = _G["norisan"]["MENU"]
    local max_cols = 5
    local item_w = 35
    local item_h = 35
    local y_off_down = 35

    local items = {}
    if menu_src then
        for key, data in pairs(menu_src) do
            if type(data) == "table" then
                if key ~= "x" and key ~= "y" and key ~= "open" and key ~= "move" and data.name and data.func and
                    ((data.image and data.image ~= "") or (data.icon and data.icon ~= "")) then
                    table.insert(items, {
                        key = key,
                        data = data
                    })
                end
            end
        end
    end

    local num_items = #items

    local num_rows = math.ceil(num_items / max_cols)

    local items_h = num_rows * item_h
    local frame_h_new = 40 + items_h
    local frame_y_new = _G["norisan"]["MENU"].y or 30

    if open_up then
        frame_y_new = frame_y_new - items_h
    end

    local frame_w_new
    if num_rows == 1 then
        frame_w_new = math.max(40, num_items * item_w)
    else
        frame_w_new = math.max(40, max_cols * item_w)
    end

    frame:SetPos(frame:GetX(), frame_y_new)
    frame:Resize(frame_w_new, frame_h_new)

    for idx, entry in ipairs(items) do
        local item_sidx = idx - 1
        local data = entry.data
        local key = entry.key
        local col = item_sidx % max_cols
        local x = col * item_w
        local y = 0

        if open_up then

            local logical_row_from_bottom = math.floor(item_sidx / max_cols)

            y = (frame_h_new - 40) - ((logical_row_from_bottom + 1) * item_h)
        else

            local row_down = math.floor(item_sidx / max_cols)
            y = y_off_down + (row_down * item_h)
        end

        local ctrl_name = "menu_item_" .. key
        local item_elem

        if data.image and data.image ~= "" then
            item_elem = frame:CreateOrGetControl('button', ctrl_name, x, y, item_w, item_h)
            AUTO_CAST(item_elem);
            item_elem:SetSkinName("None");
            item_elem:SetText(data.image)
        else
            item_elem = frame:CreateOrGetControl('picture', ctrl_name, x, y, item_w, item_h)
            AUTO_CAST(item_elem);
            item_elem:SetImage(data.icon);
            item_elem:SetEnableStretch(1)
        end

        if item_elem then
            item_elem:SetTextTooltip("{ol}" .. data.name)
            item_elem:SetEventScript(ui.LBUTTONUP, data.func)
            item_elem:ShowWindow(1)
        end
    end

    local main_btn = GET_CHILD(frame, "norisan_menu_pic")
    if main_btn then
        if open_up then
            main_btn:SetPos(0, frame_h_new - 40)
        else
            main_btn:SetPos(0, 0)
        end
    end
end

function _G.norisan_menu_frame_open(frame, ctrl)
    if not frame then
        return
    end

    if frame:GetHeight() > 40 then

        local children = {}
        for i = 0, frame:GetChildCount() - 1 do
            local child_obj = frame:GetChildByIndex(i)
            if child_obj then
                table.insert(children, child_obj)
            end
        end

        for _, child_obj in ipairs(children) do
            if child_obj:GetName() ~= "norisan_menu_pic" then

                frame:RemoveChild(child_obj:GetName())
            end
        end

        frame:Resize(40, 40)
        frame:SetPos(frame:GetX(), _G["norisan"]["MENU"].y or 30)
        local main_pic = GET_CHILD(frame, "norisan_menu_pic")
        if main_pic then
            main_pic:SetPos(0, 0)
        end
        return
    end

    local open_dir_val = _G["norisan"]["MENU"].open or 0
    _G.norisan_menu_toggle_items_display(frame, ctrl, open_dir_val)
end

function _G.norisan_menu_create_frame()

    _G["norisan"]["MENU"].lang = option.GetCurrentCountry()

    local loaded_cfg = norisan_menu_load_json(norisan_menu_settings)

    if loaded_cfg and loaded_cfg.layer ~= nil then
        _G["norisan"]["MENU"].layer = loaded_cfg.layer
    elseif _G["norisan"]["MENU"].layer == nil then
        _G["norisan"]["MENU"].layer = 79
    end

    if loaded_cfg and loaded_cfg.move ~= nil then
        _G["norisan"]["MENU"].move = loaded_cfg.move
    elseif _G["norisan"]["MENU"].move == nil then
        _G["norisan"]["MENU"].move = true
    end

    if loaded_cfg and loaded_cfg.open ~= nil then
        _G["norisan"]["MENU"].open = loaded_cfg.open
    elseif _G["norisan"]["MENU"].open == nil then
        _G["norisan"]["MENU"].open = 0
    end

    local default_x = 1190
    local default_y = 30

    local final_x = default_x
    local final_y = default_y

    if _G["norisan"]["MENU"].x ~= nil then
        final_x = _G["norisan"]["MENU"].x
    end
    if _G["norisan"]["MENU"].y ~= nil then
        final_y = _G["norisan"]["MENU"].y
    end

    if loaded_cfg and type(loaded_cfg.x) == "number" then
        final_x = loaded_cfg.x
    end
    if loaded_cfg and type(loaded_cfg.y) == "number" then
        final_y = loaded_cfg.y
    end

    local map_ui = ui.GetFrame("map")
    local screen_w = 1920
    if map_ui and map_ui:IsVisible() then
        screen_w = map_ui:GetWidth()
    end

    if final_x > 1920 and screen_w <= 1920 then
        final_x = default_x
        final_y = default_y
    end

    _G["norisan"]["MENU"].x = final_x
    _G["norisan"]["MENU"].y = final_y

    norisan_menu_save_json(norisan_menu_settings, _G["norisan"]["MENU"])

    local frame_name = _G["norisan"]["MENU"].frame_name
    local frame = ui.GetFrame(frame_name)

    if frame then
        AUTO_CAST(frame)
        frame:RemoveAllChild()
        frame:SetSkinName("None")
        frame:SetTitleBarSkin("None")
        frame:Resize(40, 40)
        frame:SetLayerLevel(_G["norisan"]["MENU"].layer)
        frame:EnableMove(_G["norisan"]["MENU"].move == true and 1 or 0)
        frame:SetPos(_G["norisan"]["MENU"].x, _G["norisan"]["MENU"].y)
        frame:SetEventScript(ui.LBUTTONUP, "norisan_menu_move_drag")

        local norisan_menu_pic = frame:CreateOrGetControl('picture', "norisan_menu_pic", 0, 0, 35, 40)
        AUTO_CAST(norisan_menu_pic)
        norisan_menu_pic:SetImage("sysmenu_sys")
        norisan_menu_pic:SetEnableStretch(1)
        local notice = _G["norisan"]["MENU"].lang == "Japanese" and "{nl}{ol}右クリック: 設定" or
                           "{nl}{ol}Right click: Settings"
        norisan_menu_pic:SetTextTooltip("{ol}Addons Menu" .. notice)
        norisan_menu_pic:SetEventScript(ui.LBUTTONUP, "norisan_menu_frame_open")
        norisan_menu_pic:SetEventScript(ui.RBUTTONUP, "norisan_menu_setting_frame")

        frame:ShowWindow(1)
    end

end
