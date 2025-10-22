-- v1.0.2 on_init読み込み時にリペアーアイテムの数量確認
-- v1.0.3 SetupHookの競合修正
-- v1.0.4 23.09.05patch対応。修理キット買うコード変えてやがった許せねえ。
-- v1.0.5 数量設定を可能に
-- v1.0.6 イベント修理キットと緊急修理キットを先に使うように設定('EVENT_2005_repairPotion')と('Premium_repairPotion')それ以外持ってない
-- v1.0.7 510修理キットに対応。
-- v1.0.8 フレームの場所変更 
-- v1.0.9 フレーム動かせて記憶する様に。表示最適化
-- v1.1.0 520アップデート対応
-- v1.1.1 ロードが早すぎて、セッティングファイルがnullになる不具合修正
-- v1.1.2 530update
-- v1.1.3 セッティングファイルがnullになるの修正
-- v1.1.4 acutil止めた。独自のアドオンボタン実装。僭越。自動補充チェック付けた。
-- v1.1.5 アドオンボタン回りを修正し、他アドオンとの共通コードに
-- v1.1.6 250902大型アップデート対応
local addon_name = "AUTO_REPAIR"
local addon_name_lower = string.lower(addon_name)
local author = "norisan"
local ver = "1.1.6"

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

function g.get_map_type()
    local map_name = session.GetMapName()
    local map_cls = GetClass("Map", map_name)
    local map_type = map_cls.MapType
    return map_type
end

function g.save_settings()
    local function save_json(path, tbl)
        local file = io.open(path, "w")
        if file then
            local str = json.encode(tbl)
            file:write(str)
            file:close()
        end
    end
    save_json(g.settings_path, g.settings)
end

function g.load_json(path)

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

        if original_results then
            return table.unpack(original_results)
        else
            return
        end
    end

    _G[origin_func_name] = hooked_function

    if not g.REGISTER[origin_func_name .. my_func_name] then -- g.REGISTERはON_INIT内で都度初期化
        g.REGISTER[origin_func_name .. my_func_name] = true
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

-- ここを変更すればいつまでも使えそう。知らんけど。
local repair_item_classid = 11202000
local repair_item_name = "QuestReward_repairPotion_540"
local repair_tradeshop_item = "AustejaCertificate_14"
local shop_type = "AustejaCertificate"

function AUTO_REPAIR_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame
    g.lang = option.GetCurrentCountry()

    g.REGISTER = {}

    local menu_data = {
        name = "Auto Repair",
        icon = "sysmenu_mac",
        func = "auto_repair_settings_frame_init",
        image = ""
    }
    if g.get_map_type() == "City" then
        _G["norisan"]["MENU"][addon_name] = menu_data
    else
        _G["norisan"]["MENU"][addon_name] = nil
    end

    if not _G["norisan"]["MENU"][addon_name_lower] or _G["norisan"]["MENU"].frame_name == addon_name_lower then
        _G["norisan"]["MENU"].frame_name = addon_name_lower
        addon:RegisterMsg("GAME_START", "norisan_menu_create_frame")
    end

    g.setup_hook_and_event(addon, "DURNOTIFY_UPDATE", "auto_repair_DURNOTIFY_UPDATE", false)

    local map_type = g.get_map_type()

    if g.get_map_type() == "City" then
        addon:RegisterMsg("GAME_START", "auto_repair_load_settings")

        local auto_repair_item = session.GetInvItemByName(repair_item_name)

        if not auto_repair_item or (auto_repair_item and auto_repair_item.count < g.settings.msg_qty) then
            addon:RegisterMsg("GAME_START_3SEC", "auto_repair_notice_frame_init")
        end
    end
end

function auto_repair_notice_frame_init()

    if g.settings.auto_buy then

        local text = g.lang == "Japanese" and "{ol}[Auto Repair] 自動補充します" or
                         "{ol}[Auto Repair] Auto Replenish"
        ui.SysMsg(text)
        auto_repair_buy_item()
        return
    end

    local frame = ui.CreateNewFrame("chat_memberlist", "auto_repair_notice")
    AUTO_CAST(frame)
    frame:SetPos(g.settings.notice_x or 680, g.settings.notice_y or 660)
    frame:SetSkinName("chat_window")
    frame:SetEventScript(ui.LBUTTONUP, "auto_repair_end_drag")

    local item_class = GetClassByType('Item', repair_item_classid)
    local item_name = item_class.Name

    local text_1 = frame:CreateOrGetControl('richtext', 'text_1', 10, 10)
    AUTO_CAST(text_1)
    local texts = g.lang == "Japanese" and "残り少ないですが補充しますか？" or
                      "Do you want to replenish the few remaining?"
    text_1:SetText("{s18}{ol}" .. item_name .. "{nl}" .. texts)
    text_1:SetTextAlign("center", "center")

    local yes_button = frame:CreateOrGetControl('button', 'yes_button', 50, 65, 80, 40)
    yes_button:SetSkinName("test_red_button")
    yes_button:SetText("{ol}YES")
    yes_button:SetEventScript(ui.LBUTTONUP, "auto_repair_buy_item")

    local no_button = frame:CreateOrGetControl('button', 'no_button', 140, 65, 80, 40)
    no_button:SetSkinName("test_gray_button")
    no_button:SetText("{ol}NO")
    no_button:SetEventScript(ui.LBUTTONUP, "auto_repair_notice_frame_close")

    if g.lang == "Japanese" then
        frame:Resize(290, 110)
    else
        frame:Resize(420, 110)
        yes_button:SetMargin(115, 65, 80, 40)
        no_button:SetMargin(205, 65, 80, 40)
    end
    frame:EnableHittestFrame(1)
    frame:EnableMove(1)
    frame:ShowWindow(1)
    frame:RunUpdateScript("auto_repair_notice_frame_close", 7.0)

end

function auto_repair_notice_frame_close(frame)
    local frame = ui.GetFrame("auto_repair_notice")
    frame:ShowWindow(0)
    return 0
end

function auto_repair_buy_item()

    local auto_repair_item = session.GetInvItemByName(repair_item_name)
    local recipe_class = GetClass("ItemTradeShop", repair_tradeshop_item)
    local count = 0

    if auto_repair_item ~= nil then
        local repair_count = auto_repair_item.count
        count = g.settings.buy_qty - repair_count
    else
        count = g.settings.buy_qty
    end

    session.ResetItemList()
    session.AddItemID(tostring(0), 1)
    local item_list = session.GetItemIDList()
    local count_text = string.format("%s %s", tostring(recipe_class.ClassID), tostring(count))
    local str_list = NewStringList()
    str_list:Add(shop_type)

    item.DialogTransaction("Certificate_SHOP", item_list, count_text, str_list)
    auto_repair_notice_frame_close()
end

function auto_repair_load_settings()

    local settings = g.load_json(g.settings_path)

    if not settings then
        settings = {
            buy_qty = 50,
            msg_qty = 20,
            setting_x = 900,
            setting_y = 730,
            notice_x = 680,
            notice_y = 660,
            auto_buy = false
        }
    end
    g.settings = settings
    g.save_settings()
end

function auto_repair_end_drag(frame, ctrl)

    local frame_name = frame:GetName()
    if frame_name == "auto_repair_notice" then
        g.settings.notice_x = frame:GetX()
        g.settings.notice_y = frame:GetY()
    elseif frame_name == "auto_repair_setting" then
        g.settings.setting_x = frame:GetX()
        g.settings.setting_y = frame:GetY()
    end
    g.save_settings()
end

function auto_repair_settings_frame_init()

    local frame = ui.CreateNewFrame("chat_memberlist", "auto_repair_setting")
    AUTO_CAST(frame)
    frame:SetPos(g.settings.setting_x or 900, g.settings.setting_y or 730)
    frame:EnableHitTest(1)
    frame:SetSkinName("chat_window")
    frame:SetEventScript(ui.LBUTTONUP, "auto_repair_end_drag")

    local text_1 = frame:CreateOrGetControl('richtext', 'text_1', 10, 10)
    AUTO_CAST(text_1)
    local item_class = GetClassByType('Item', repair_item_classid)
    local item_name = item_class.Name
    local texts = g.lang == "Japanese" and " 購入設定" or " Purchase Settings"
    text_1:SetText("{ol}{s18}" .. item_name .. texts)

    local text_2 = frame:CreateOrGetControl('richtext', 'text_2', 10, 50)
    AUTO_CAST(text_2)
    local texts = g.lang == "Japanese" and "自動購入数入力" or "Number of automatic purchases"
    text_2:SetText("{s18}{ol}" .. texts)

    local text_3 = frame:CreateOrGetControl('richtext', 'text_3', 10, 80)
    AUTO_CAST(text_3)
    local texts = g.lang == "Japanese" and "入力数以下で補充メッセージ" or
                      "Message with less than input quantit"
    text_3:SetText("{s18}{ol}" .. texts)

    local auto_purchase = frame:CreateOrGetControl('checkbox', "auto_purchase", 10, 110, 100, 25)
    AUTO_CAST(auto_purchase)
    local texts = g.lang == "Japanese" and "自動補充有効化" or "Auto Replenishment Enable"
    auto_purchase:SetText("{s18}{ol}" .. texts)
    local texts = g.lang == "Japanese" and "{ol}チェックすると自動で購入" or
                      "{ol}Automatic purchase when checked"
    auto_purchase:SetTextTooltip("{s18}{ol}" .. texts)
    auto_purchase:SetCheck(g.settings.auto_buy and 1 or 0)
    auto_purchase:SetEventScript(ui.LBUTTONUP, "auto_repair_setting")

    local width = math.max(text_2:GetWidth(), text_3:GetWidth())

    local edit_1 = frame:CreateOrGetControl('edit', 'edit_1', width + 20, 45, 60, 30)
    AUTO_CAST(edit_1)
    edit_1:SetText("{ol}" .. g.settings.buy_qty)
    edit_1:SetFontName("white_16_ol")
    edit_1:SetTextAlign("center", "center")
    edit_1:SetEventScript(ui.ENTERKEY, "auto_repair_setting")
    edit_1:SetTextTooltip(g.lang == "Japanese" and "{ol}エンターキー押下で登録" or
                              "{ol}Register by pressing enter key")

    local edit_2 = frame:CreateOrGetControl('edit', 'edit_2', width + 20, 75, 60, 30)
    AUTO_CAST(edit_2)
    edit_2:SetText("{ol}" .. g.settings.msg_qty)
    edit_2:SetFontName("white_16_ol")
    edit_2:SetTextAlign("center", "center")
    edit_2:SetEventScript(ui.ENTERKEY, "auto_repair_setting")
    edit_2:SetTextTooltip(g.lang == "Japanese" and "{ol}エンターキー押下で登録" or
                              "{ol}Register by pressing enter key")

    function auto_repair_setting_frame_close(frame)
        ui.CloseFrame("auto_repair_setting")
    end

    local close_button = frame:CreateOrGetControl("button", "close_button", text_1:GetWidth() + 20, 0, 30, 30)
    AUTO_CAST(close_button)
    close_button:SetSkinName("None")
    close_button:SetImage("testclose_button")
    close_button:SetEventScript(ui.LBUTTONUP, "auto_repair_setting_frame_close")
    close_button:SetGravity(ui.RIGHT, ui.TOP)

    frame:Resize(width + 90, 145)
    frame:ShowWindow(1)

end

function auto_repair_setting(frame, ctrl)

    local ctrl_name = ctrl:GetName()

    if ctrl_name ~= "auto_purchase" then
        local value = tonumber(ctrl:GetText())
        if not value then
            return
        end
        if tonumber(value) ~= tonumber(g.settings.buy_qty) and ctrl_name == "edit_1" then
            ui.SysMsg(g.lang == "Japanese" and "購入数量を " .. value .. " 個に設定しました" or
                          "Buy quantity set to " .. value)
            g.settings.buy_qty = value

        elseif tonumber(value) ~= tonumber(g.settings.msg_qty) and ctrl_name == "edit_2" then
            ui.SysMsg(g.lang == "Japanese" and "お知らせ数量を " .. value .. " 個に設定しました" or
                          "Msg quantity set to " .. value)
            g.settings.msg_qty = value
        end
    elseif ctrl_name == "auto_purchase" then
        local is_check = ctrl:IsChecked()
        g.settings.auto_buy = is_check == 1 and true or false
    end
    g.save_settings()
end

function auto_repair_item_use(obj, spot)
    session.ResetItemList()
    local repair_potion = session.GetInvItemByName(repair_item_name)
    if repair_potion ~= nil and not repair_potion.isLockState then

        local repeat_count = math.min(repair_potion.count, 4)
        for i = 0, repeat_count - 1 do
            if obj.Dur / obj.MaxDur < 0.9 then
                item.UseByGUID(repair_potion:GetIESID())
            else
                break
            end
        end
    end
end

function auto_repair_DURNOTIFY_UPDATE(my_frame, my_msg)

    local frame, notOpenFrame = g.get_event_args(my_msg)
    if frame:IsVisible() == 0 then
        frame:ShowWindow(1)
    end

    local slot_set = GET_CHILD_RECURSIVELY(frame, 'slotlist', 'ui::CSlotSet')
    slot_set:ClearIconAll()

    for i = 0, slot_set:GetSlotCount() - 1 do
        local slot = slot_set:GetSlotByIndex(i)
        slot:ShowWindow(0)
    end

    local reverse_index = slot_set:GetSlotCount() - 1
    local equip_list = session.GetEquipItemList()
    local some_flag = 1

    for i = 0, equip_list:Count() - 1 do
        local equip_item = equip_list:GetEquipItemByIndex(i)
        local spot = item.GetEquipSpotName(equip_item.equipSpot)
        local slot_cnt = imcSlot:GetFilledSlotCount(slot_set)
        local temp_obj = equip_item:GetObject()

        if temp_obj ~= nil then
            local obj = GetIES(temp_obj)
            if IS_DUR_UNDER_10PER(obj) == true then
                local color_tone = "FF999900"
                if some_flag < 2 then
                    some_flag = 2
                    local type = equip_item.type
                    auto_repair_item_use(obj, spot)
                end
                if IS_DUR_ZERO(obj) == true then
                    color_tone = "FF990000"
                    if some_flag < 3 then
                        some_flag = 3
                    end
                end

                local slot = slot_set:GetSlotByIndex(reverse_index - slot_cnt)
                local icon = CreateIcon(slot)
                local icon_img = obj.Icon
                local briquetting_id = TryGetProp(obj, 'BriquettingIndex', 0)
                if briquetting_id > 0 then
                    local briquetting_item_cls = GetClassByType('Item', briquetting_id)
                    icon_img = briquetting_item_cls.Icon
                end
                icon:Set(icon_img, 'Item', equip_item.type, reverse_index - slot_cnt, equip_item:GetIESID())
                icon:SetColorTone(color_tone)
                slot:ShowWindow(1)
            end

        end
    end

    local now_value = frame:GetValue()
    if some_flag == 1 then
        frame:SetValue(1)
    elseif some_flag == 2 and now_value < some_flag then
        frame:SetValue(2)
        ui.SysMsg(ScpArgMsg('DurUnder30'))
    elseif some_flag == 3 and now_value < some_flag then
        frame:SetValue(3)
        ui.SysMsg(ScpArgMsg('DurUnder0'))
    end
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
