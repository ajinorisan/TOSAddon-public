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
local addonName = "AUTO_REPAIR"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.1.4"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

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

    local folder = string.format("../addons/%s", addonNameLower)
    local file_path = string.format("../addons/%s/mkdir.txt", addonNameLower)
    create_folder(folder, file_path)

    g.active_id = session.loginInfo.GetAID()
    local user_folder = string.format("../addons/%s/%s", addonNameLower, g.active_id)
    local user_file_path = string.format("../addons/%s/%s/mkdir.txt", addonNameLower, g.active_id)
    create_folder(user_folder, user_file_path)

    g.settings_path = string.format("../addons/%s/%s/settings.json", addonNameLower, g.active_id)
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

-- アドオンメニューボタン
local norisan_menu_settings = string.format("../addons/%s/settings.json", "norisan_menu")
local norisan_menu_folder = string.format("../addons/%s", "norisan_menu")
local norisan_menu_mkfile = string.format("../addons/%s/mkdir.txt", "norisan_menu")
_G["norisan"] = _G["norisan"] or {}
_G["norisan"]["MENU"] = _G["norisan"]["MENU"] or {}

local function norisan_menu_create_folder_file()
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

local function norisan_menu_save_json(path, tbl)

    local data_to_save = {
        x = tbl.x,
        y = tbl.y

    }
    local file = io.open(path, "w")
    if file then
        local str = json.encode(data_to_save)
        file:write(str)
        file:close()
    end
end

function _G.norisan_menu_frame_open(frame, ctrl) -- frame, ctrl はそのまま

    if not frame then
        return
    end

    imcSound.PlaySoundEvent("window_open")
    if frame:GetHeight() > 40 then
        local child_count = frame:GetChildCount()
        local remove_list = {}
        for i = 0, child_count - 1 do
            local child_ctrl = frame:GetChildByIndex(i)
            if child_ctrl then
                local child_name = child_ctrl:GetName()
                if child_name ~= "norisan_menu_pic" then
                    table.insert(remove_list, child_name)
                end
            end
        end
        for _, name_to_remove in ipairs(remove_list) do
            frame:RemoveChild(name_to_remove)
        end
        frame:Resize(40, 40)
        return
    end

    local menu_items_tbl = _G["norisan"]["MENU"]
    local item_count = 0
    local disp_idx = 0

    if menu_items_tbl then
        for key, item_data in pairs(menu_items_tbl) do

            if key ~= "x" and key ~= "y" and type(item_data) == "table" and item_data.name and item_data.icon and
                item_data.func then

                item_count = item_count + 1
                local item_pic_name = "menu_item_" .. key -- menu_pic_ctrl_name から変更
                local item_pic = frame:CreateOrGetControl('picture', item_pic_name, disp_idx * 35, 35, 35, 40) -- menu_pic を item_pic に
                AUTO_CAST(item_pic)
                item_pic:SetImage(item_data.icon)
                item_pic:SetEnableStretch(1)
                item_pic:SetTextTooltip("{ol}" .. item_data.name)
                item_pic:SetEventScript(ui.LBUTTONUP, item_data.func)
                item_pic:ShowWindow(1)
                disp_idx = disp_idx + 1
            end
        end
    end

    if item_count > 0 then
        frame:Resize(math.max(40, item_count * 35), 70)
    else
        frame:Resize(40, 40)
    end
end

function _G.norisan_menu_move_drag(frame, ctrl)
    if not frame then
        return
    end
    _G["norisan"]["MENU"].x = frame:GetX()
    _G["norisan"]["MENU"].y = frame:GetY()
    norisan_menu_save_json(norisan_menu_settings, _G["norisan"]["MENU"])
end

function _G.norisan_menu_create_frame()

    norisan_menu_create_folder_file()

    local loaded_cfg = norisan_menu_load_json(norisan_menu_settings)
    local cfg_x = nil
    local cfg_y = nil

    if loaded_cfg then
        cfg_x = loaded_cfg.x
        cfg_y = loaded_cfg.y
    end

    if cfg_x == nil or cfg_y == nil then

        _G["norisan"]["MENU"].x = _G["norisan"]["MENU"].x or 510
        _G["norisan"]["MENU"].y = _G["norisan"]["MENU"].y or 30
        norisan_menu_save_json(norisan_menu_settings, _G["norisan"]["MENU"])
    else

        local map_frame = ui.GetFrame("map")
        local width = map_frame:GetWidth()

        if _G["norisan"]["MENU"].x and _G["norisan"]["MENU"].x > 1920 and width <= 1920 then
            cfg_x = 510
            cfg_y = 30
        end

        _G["norisan"]["MENU"].x = cfg_x
        _G["norisan"]["MENU"].y = cfg_y
    end

    local frame = ui.GetFrame("norisan_menu")
    if not frame then

        frame = ui.CreateNewFrame("chat_memberlist", "norisan_menu")
        AUTO_CAST(frame)
        frame:SetSkinName("chat_window")
        frame:SetSkinName("None")
        frame:SetTitleBarSkin("None")
        frame:Resize(40, 40)

        frame:SetPos(_G["norisan"]["MENU"].x, _G["norisan"]["MENU"].y)
        frame:SetEventScript(ui.LBUTTONUP, "norisan_menu_move_drag")

        local norisan_menu_pic = frame:CreateOrGetControl('picture', "norisan_menu_pic", 0, 0, 35, 40)
        AUTO_CAST(norisan_menu_pic)
        norisan_menu_pic:SetImage("sysmenu_sys")
        norisan_menu_pic:SetEnableStretch(1)
        norisan_menu_pic:SetEventScript(ui.LBUTTONUP, "norisan_menu_frame_open") -- グローバル関数名を指定
        norisan_menu_pic:SetTextTooltip("{ol}addons menu")
    end

    if frame then

        frame:ShowWindow(1)
    end

end

-- アドオンメニューボタンここまで

-- ここを変更すればいつまでも使えそう。知らんけど。
local repair_item_classid = 11201325
local repair_item_name = "QuestReward_repairPotion_530"
local repair_tradeshop_item = "JurateCertificate_13"
local shop_type = "JurateCertificate"

function AUTO_REPAIR_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame
    g.lang = option.GetCurrentCountry()

    g.REGISTER = {}

    local menu_data = {
        name = "Auto Repair",
        icon = "sysmenu_mac",
        func = "auto_repair_settings_frame_init"
    }
    _G["norisan"]["MENU"][addonName] = menu_data
    addon:RegisterMsg("GAME_START", "norisan_menu_create_frame")

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

