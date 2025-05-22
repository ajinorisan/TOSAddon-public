-- v1.0.5 23.9.5のアプデのに伴いフィールドマップではどこでも表示に変更。メンドイので（
-- v1.0.6 未知の聖域でも表示される様に。未知用自動レリックOFF隠し要素追加
-- v1.0.7 継続してマップのアイテム取得分析
-- v1.0.8 分析を詳細に
-- v1.0.9 チャレンジとかで無駄に増えるマップを無効化
-- v1.1.0 インフォフレームをちゃんと作った。褒めて欲しい。
-- v1.1.1 フレームのレイヤーを上げた。
-- v1.1.2 インフォフレームの横幅調整。TP画面出してもフレーム復帰するように
-- v1.1.3 チャレンジとかで出ない様に、再度見直し。
-- v1.1.4 フレームのxmlにAutoOpen書いた。謎にzoneInsts取得してバグってたの直した
-- v1.1.5 mapinfoのエラー処理追加
-- v1.1.6 ウルトラワイド対応。ID毎のセーブファイルに
local addon_name = "KLCOUNT"
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

    g.settings_file_location = string.format("../addons/%s/%s/settings.json", addon_name_lower, g.active_id)
end
g.mkdir_new_folder()

function g.save_json(path, tbl)
    local file = io.open(path, "w")
    if file then
        local str = json.encode(tbl)
        file:write(str)
        file:close()
    end
end

function g.load_json(path)
    local file = io.open(path, "r")
    if not file then
        return nil, "Error opening file: " .. path
    end

    local content = file:read("*all")
    file:close()

    if not content or content == "" then
        return nil, "File content is empty or could not be read: " .. path
    end

    local decoded_table, decode_err = json.decode(content)

    if not decoded_table then
        return nil, decode_err
    end

    return decoded_table, nil
end

function g.get_map_type()
    local map_name = session.GetMapName()
    local map_cls = GetClass("Map", map_name)
    local map_type = map_cls.MapType
    return map_type
end

function klcount_load_settings()

    local settings = g.load_json(g.settings_file_location)

    if not settings then
        settings = {
            frame_x = 1340,
            frame_y = 20,
            map_ids = {}
        }
    end

    g.settings = settings
    g.save_json(g.settings_file_location, g.settings)

end

function KLCOUNT_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame

    klcount_load_settings()

    g.lang = option.GetCurrentCountry()
    g.challenge_mode = false

    addon:RegisterMsg("UI_CHALLENGE_MODE_TOTAL_KILL_COUNT", "klcount_ON_CHALLENGE_MODE_TOTAL_KILL_COUNT")
    addon:RegisterMsg("GAME_START", "klcount_GAME_START")

    local menu_data = {
        name = "Kl Count Map Info",
        icon = "icon_item_gold",
        func = "klcount_information_context",
        image = ""
    }
    _G["norisan"]["MENU"][addon_name] = menu_data
    _G["norisan"]["MENU"].frame_name = "klcount"
    _G["norisan"]["MENU"].last_addon = addon_name
    addon:RegisterMsg("GAME_START", "norisan_menu_create_frame")

end

function klcount_ON_CHALLENGE_MODE_TOTAL_KILL_COUNT(frame, msg, str, arg)
    local msgList = StringSplit(str, '#');

    if msgList[1] == "SHOW" then
        g.challenge_mode = true
    end
end

function klcount_GAME_START()

    local addon = g.addon

    local map_type = g.get_map_type()
    local map_id = session.GetMapID()
    local map_name = GetClassByType("Map", map_id).ClassName

    if map_type == "Field" or map_type == "Dungeon" then

        addon:RegisterMsg("EXP_UPDATE", "klcount__count_UPDATE")
        addon:RegisterMsg('ITEM_PICK', 'klcount_ITEM_PICK');

        local map_file_location = string.format("../addons/%s/%s/%s.json", addon_name_lower, g.active_id, map_id)

        local map_data = g.load_json(map_file_location);
        if not map_data then

            map_data = {
                map_name = map_name,
                stay_time = 0,
                kill_count = 0,
                get_items = {}
            }
            g.save_json(map_file_location, map_data)
        end
        g.map_data = map_data
        g.map_file_location = map_file_location

        local id_check = false
        for _, id in ipairs(g.settings.map_ids) do
            if id == map_id then
                id_check = true
                break
            end
        end

        if not id_check then
            table.insert(g.settings.map_ids, map_id)
            g.save_json(g.settings_file_location, g.settings)
        end

        klcount_frame_init()
    end
end

function klcount_frame_init()

    local frame = ui.CreateNewFrame("chat_memberlist", addon_name_lower .. "_frame", 0, 0, 0, 0)
    AUTO_CAST(frame)

    frame:SetSkinName("shadow_box")
    frame:SetTitleBarSkin("None")
    frame:EnableHitTest(1)
    frame:EnableMove(1)
    frame:SetAlpha(80)
    frame:SetLayerLevel(31)
    frame:SetEventScript(ui.LBUTTONUP, "klcount_pos_setting")

    local map_frame = ui.GetFrame("map")
    local width = map_frame:GetWidth()

    if g.settings.frame_x > 1920 and width <= 1920 then
        g.settings.frame_x = 1340
        g.settings.frame_y = 20
    end

    frame:SetPos(g.settings.frame_x, g.settings.frame_y)

    g.count = 0
    g.start_time = imcTime.GetAppTimeMS()

    local count_text = frame:CreateOrGetControl("richtext", "count_text", 10, 10, 170, 30)
    AUTO_CAST(count_text)
    count_text:SetText(string.format("{ol}{s16}Count : %d{/}", g.count))

    local map_id = session.GetMapID()
    local map_name = GetClassByType("Map", map_id).Name
    local map_text = frame:CreateOrGetControl("richtext", "map_text", 10, 35, 170, 30)
    AUTO_CAST(map_text)

    map_text:SetText(string.format("{ol}{s16}%s{/}", map_name))
    local w = 170
    if map_text:GetWidth() + 15 > 170 then
        w = map_text:GetWidth() + 15
    end

    local timer_text = frame:CreateOrGetControl("richtext", "timer_text", 90, 60, 200, 30)
    AUTO_CAST(timer_text)
    timer_text:SetGravity(ui.RIGHT, ui.BOTTOM)
    local rect = timer_text:GetMargin()
    timer_text:SetMargin(rect.left, rect.top, rect.right + 15, rect.bottom + 15)

    frame:Resize(w, 95)
    frame:ShowWindow(1)

    g.save_counter = 0
    g.save_interval = 5

    frame:RunUpdateScript("klcount_time_update", 1.0)
end

function klcount_time_update(frame)
    if g.challenge_mode then
        if frame:IsVisible() == 1 then
            frame:ShowWindow(0)
        end
        g.save_counter = 0
        return 0
    end

    local now_ms = imcTime.GetAppTimeMS()
    local diff_ms = now_ms - g.start_time
    local total_sec = math.floor(diff_ms / 1000)

    if not g.map_data then
        return 1
    end

    g.map_data.stay_time = g.map_data.stay_time + total_sec

    local h = math.floor(total_sec / 3600)
    local m = math.floor((total_sec % 3600) / 60)
    local s = total_sec % 60

    local timer_text = GET_CHILD(frame, " timer_text")
    AUTO_CAST(timer_text)
    timer_text:SetText(string.format("{ol}{s16}%02d:%02d:%02d{/}", h, m, s))

    g.save_counter = g.save_counter + 1
    if g.save_counter >= g.save_interval then
        g.save_json(g.map_file_location, g.map_data)
        g.save_counter = 0
    end

    return 1
end

function klcount_pos_setting(frame, ctrl)

    g.settings.frame_x = frame:GetX()
    g.settings.frame_y = frame:GetY()

    g.save_json(g.settings_file_location, g.settings)
end

function klcount_information_context(frame, ctrl, str, num)
    local context = ui.CreateContextMenu("klcount_context", "{ol}Map Info", 0, 0, 200, 0)

    for i = 1, #g.settings.map_ids do

        local map_name = GetClassByType("Map", g.settings.map_ids[i]).ClassName

        local map_file_location = string.format("../addons/%s/%s/%s.json", addon_name_lower, g.active_id,
                                                g.settings.map_ids[i])

        local map_data, err = g.load_json(map_file_location);

        if err then

            CHAT_SYSTEM("Error loading map data for " .. g.settings.map_ids[i] .. "{nl} " .. err)

            map_data = {
                map_name = map_name,
                stay_time = 0,
                kill_count = 0,
                get_items = {}
            }

            g.save_json(map_file_location, map_data)

        elseif next(map_data.get_items) then
            local display_text = g.settings.map_ids[i] .. " " .. GetClassByType("Map", g.settings.map_ids[i]).Name
            local script = ui.AddContextMenuItem(context, display_text,
                                                 string.format("klcount_map_information(%d)", g.settings.map_ids[i]))
        else
            map_data = {
                map_name = map_name,
                stay_time = 0,
                kill_count = 0,
                get_items = {}
            }
            g.save_json(map_file_location, map_data)
        end
    end

    ui.OpenContextMenu(context)
end

function klcount_map_information_close(frame, ctrl, str, num)
    local frame = ui.GetFrame(addon_name_lower .. "map_info")
    frame:ShowWindow(0)
end

function klcount_map_information(map_id)
    local new_path = string.format("../addons/%s/%s/%s.json", addon_name_lower, g.active_id, map_id) -- new_map_file_path -> new_path
    local old_path = string.format("../addons/%s/%s.json", addon_name_lower, map_id) -- old_map_file_path -> old_path

    local map_data, err_old = g.load_json(old_path)
    local check_file = io.open(new_path, "r")

    if not check_file then

        if map_data and not err_old then
            g.save_json(new_path, map_data)
        else

            if err_old then
                CHAT_SYSTEM("klcount_map_information: Error loading old map data for migration: " .. tostring(err_old))
            end
            local map_cls_name = GetClassByType("Map", map_id).ClassName
            map_data = {
                map_name = map_cls_name,
                stay_time = 0,
                kill_count = 0,
                get_items = {}
            }
            g.save_json(new_path, map_data)
        end
    else

        check_file:close()
        local data_new, err_new = g.load_json(new_path)
        if data_new and not err_new then
            map_data = data_new
        else
            if err_new then
                CHAT_SYSTEM("klcount_map_information: Error loading new map data: " .. tostring(err_new))
            end
            local map_cls_name = GetClassByType("Map", map_id).ClassName
            map_data = {
                map_name = map_cls_name,
                stay_time = 0,
                kill_count = 0,
                get_items = {}
            }
            g.save_json(new_path, map_data)
        end
    end

    if not map_data then
        CHAT_SYSTEM("klcount_map_information: map_data is still nil after loading attempts. Using empty data.")
        local map_cls_name = GetClassByType("Map", map_id).ClassName
        map_data = {
            map_name = map_cls_name,
            stay_time = 0,
            kill_count = 0,
            get_items = {}
        }
        g.save_json(new_path, map_data)
    end

    local frame_name_info = addon_name_lower .. "map_info"
    local ui_frame = ui.CreateNewFrame("notice_on_pc", frame_name_info, 0, 0, 0, 0)
    AUTO_CAST(ui_frame)
    ui_frame:SetPos(1000, 30)
    ui_frame:SetSkinName("test_frame_low")

    local close_btn = ui_frame:CreateOrGetControl("button", "close_button", 0, 0, 30, 30)
    AUTO_CAST(close_btn)
    close_btn:SetImage("testclose_button")
    close_btn:SetGravity(ui.RIGHT, ui.TOP)
    close_btn:SetEventScript(ui.LBUTTONUP, "klcount_map_information_close");

    local map_name_label = ui_frame:CreateOrGetControl('richtext', 'map_name_text', 20, 10, 50, 20)
    AUTO_CAST(map_name_label)
    local map_disp_name = GetClassByType("Map", map_id).Name
    map_name_label:SetText("{ol}" .. map_disp_name)

    local info_box = ui_frame:CreateOrGetControl("groupbox", "info_gbox", 10, 40, ui_frame:GetWidth() - 20,
                                                 ui_frame:GetHeight() - 55)
    AUTO_CAST(info_box)
    info_box:RemoveAllChild()
    info_box:SetSkinName("bg")

    local total_sec = map_data.stay_time or 0
    local h = math.floor(total_sec / 3600)
    local m = math.floor((total_sec % 3600) / 60)
    local s = total_sec % 60

    local stay_label = info_box:CreateOrGetControl('richtext', 'stay_time', 10, 10, 50, 20)
    AUTO_CAST(stay_label)
    local stay_time_str = g.lang == "Japanese" and "滞在時間 : " or "Stay Time : "
    stay_label:SetText("{ol}" .. stay_time_str .. string.format("%03d:%02d:%02d", h, m, s))

    local kill_label = info_box:CreateOrGetControl('richtext', 'kill_count', 10, 35, 50, 20) -- kill_count -> kill_label
    AUTO_CAST(kill_label)
    local kill_count_val = map_data.kill_count or 0
    local kill_count_str = g.lang == "Japanese" and "討伐数 : " or "Kill Count : "
    kill_label:SetText("{ol}" .. kill_count_str .. kill_count_val)

    local kill_per_hour_label = info_box:CreateOrGetControl('richtext', 'kill_count_hour', kill_label:GetWidth() + 20,
                                                            35, 50, 20)
    AUTO_CAST(kill_per_hour_label)
    if total_sec > 0 then
        local kills_ph_val = math.floor(kill_count_val / total_sec * 3600)
        local kills_ph_prefix = total_sec >= 3600 and (g.lang == "Japanese" and " (実績 " or " (Measured ") or
                                    (g.lang == "Japanese" and " (予測 " or " (Predicted ")
        local kills_ph_suffix = g.lang == "Japanese" and " 体/時)" or " Per Hour )"
        kill_per_hour_label:SetText("{ol}" .. kills_ph_prefix .. kills_ph_val .. kills_ph_suffix)
    else
        kill_per_hour_label:SetText("{ol}" .. (g.lang == "Japanese" and " (計測不能)" or " (N/A)"))
    end

    local item_keys = {}
    local total_item_num = 0
    if map_data.get_items then
        for item_id_str, count_val in pairs(map_data.get_items) do
            table.insert(item_keys, tonumber(item_id_str))
            total_item_num = total_item_num + count_val
        end
    end
    table.sort(item_keys)

    local total_items_label = info_box:CreateOrGetControl('richtext', 'total_items_text', 10, 60, 50, 20)
    AUTO_CAST(total_items_label)
    local total_items_str = g.lang == "Japanese" and "総獲得アイテム数 : " or "Total Items : "
    total_items_label:SetText("{ol}" .. total_items_str .. total_item_num)

    local current_y = 0 -- y -> current_y
    local max_x = 0 -- x -> max_x
    for _, item_id_num in ipairs(item_keys) do
        local item_id_str_key = tostring(item_id_num)
        local item_cls = GetClassByType('Item', item_id_num)
        if item_cls and map_data.get_items and map_data.get_items[item_id_str_key] then
            local item_name_disp = item_cls.Name
            local item_icon_disp = item_cls.Icon
            local item_get_count = map_data.get_items[item_id_str_key]
            local pcs_str = g.lang == "Japanese" and " 個" or " pcs"

            local item_disp_str1 =
                "{ol}" .. string.format("{img %s 24 24}", item_icon_disp) .. "  " .. item_name_disp ..
                    (g.lang == "Japanese" and " 獲得数 : " or " Get Count : ") .. item_get_count .. pcs_str

            local item_label1 = info_box:CreateOrGetControl('richtext', 'display_text' .. item_id_str_key, 10,
                                                            95 + current_y, 50, 20)
            AUTO_CAST(item_label1)
            item_label1:SetText(item_disp_str1)

            if max_x < item_label1:GetWidth() + 10 then
                max_x = item_label1:GetWidth() + 10
            end

            local kc_percent = 0
            if kill_count_val > 0 then
                kc_percent = item_get_count / kill_count_val * 100
            end
            local rounded_kc_percent = math.floor(kc_percent * 10 + 0.5) / 10

            local ti_percent = 0
            if total_item_num > 0 then
                ti_percent = item_get_count / total_item_num * 100
            end
            local rounded_ti_percent = math.floor(ti_percent * 10 + 0.5) / 10

            local sec_per_item = 0
            if item_get_count > 0 then
                sec_per_item = total_sec / item_get_count
            end
            local rounded_sec_per_item = math.floor(sec_per_item * 10 + 0.5) / 10

            local kc_str = g.lang == "Japanese" and "%(対討伐数)   " or "%(@Kill Count)   "
            local ti_str = g.lang == "Japanese" and "%(対総アイテム数)   " or "%(@Total Items)   "
            local st_str = g.lang == "Japanese" and "秒(対滞在時間)" or "sec(@Stay Time)"

            local item_disp_str2 = "        " .. rounded_kc_percent .. kc_str .. rounded_ti_percent .. ti_str ..
                                       rounded_sec_per_item .. st_str

            local item_label2 = info_box:CreateOrGetControl('richtext', 'display_text2' .. item_id_str_key, 10,
                                                            120 + current_y, 50, 20)
            AUTO_CAST(item_label2)
            item_label2:SetText("{ol}" .. item_disp_str2)
            current_y = current_y + 55
            if max_x < item_label2:GetWidth() + 10 then
                max_x = item_label2:GetWidth() + 10
            end
        end
    end

    local reset_btn_x = map_name_label:GetWidth() + 30
    local reset_btn = ui_frame:CreateOrGetControl("button", "reset_button", reset_btn_x, 5, 80, 30)
    AUTO_CAST(reset_btn)
    reset_btn:SetSkinName("test_red_button")
    -- local reset_btn_text = g.lang == "Japanese" and "マップリセット" or "Map Reset"
    local reset_btn_text = "Map Reset"
    reset_btn:SetText("{ol}" .. reset_btn_text)
    reset_btn:SetEventScript(ui.LBUTTONUP, "klcount_map_reset_reserve")
    reset_btn:SetEventScriptArgNumber(ui.LBUTTONUP, map_id)

    if current_y >= 840 then
        current_y = 840
    end
    if max_x == 0 then
        max_x = 200
    end

    ui_frame:Resize(max_x + 40, 160 + current_y)
    ui_frame:SetLayerLevel(150)
    info_box:Resize(ui_frame:GetWidth() - 20, ui_frame:GetHeight() - 55)
    ui_frame:ShowWindow(1)
end

--[[function klcount_map_information(map_id)

    local new_map_file_path = string.format("../addons/%s/%s/%s.json", addon_name_lower, g.active_id, map_id)

    local old_map_file_path = string.format("../addons/%s/%s.json", addon_name_lower, map_id)
    local map_data = g.load_json(old_map_file_path)
    local check_file = io.open(new_map_file_path, "r")

    if not check_file then
        g.save_json(new_map_file_path, map_data)
    else
        map_data = g.load_json(new_map_file_path)
        check_file:close()
    end

    local frame = ui.CreateNewFrame("notice_on_pc", addon_name_lower .. "map_info", 0, 0, 0, 0)
    AUTO_CAST(frame)
    frame:SetPos(1000, 30)
    frame:SetSkinName("test_frame_low")

    local close_button = frame:CreateOrGetControl("button", "close_button", 0, 0, 30, 30)
    AUTO_CAST(close_button)
    close_button:SetImage("testclose_button")
    close_button:SetGravity(ui.RIGHT, ui.TOP)
    close_button:SetEventScript(ui.LBUTTONUP, "klcount_map_information_close");

    local map_name_text = frame:CreateOrGetControl('richtext', 'map_name_text', 20, 10, 50, 20)
    AUTO_CAST(map_name_text)
    local map_name = GetClassByType("Map", map_id).Name

    map_name_text:SetText("{ol}" .. map_name)

    local info_gbox = frame:CreateOrGetControl("groupbox", "info_gbox", 10, 40, frame:GetWidth() - 20,
                                               frame:GetHeight() - 55)
    AUTO_CAST(info_gbox)
    info_gbox:RemoveAllChild()
    info_gbox:SetSkinName("bg")

    local total_seconds = map_data.stay_time
    local hours = math.floor(total_seconds / 3600)
    local minutes = math.floor((total_seconds % 3600) / 60)
    local seconds = total_seconds % 60

    local stay_time = info_gbox:CreateOrGetControl('richtext', 'stay_time', 10, 10, 50, 20)
    AUTO_CAST(stay_time)
    stay_time:SetText("{ol}Stay Time : " .. string.format("%03d:%02d:%02d", hours, minutes, seconds))

    local kill_count = info_gbox:CreateOrGetControl('richtext', 'kill_count', 10, 35, 50, 20)
    AUTO_CAST(kill_count)
    kill_count:SetText("{ol}Kill Count : " .. map_data.kill_count)

    local kill_count_hour = info_gbox:CreateOrGetControl('richtext', 'kill_count_hour', kill_count:GetWidth() + 20, 35,
                                                         50, 20)
    AUTO_CAST(kill_count_hour)
    if total_seconds >= 3600 then
        kill_count_hour:SetText("{ol}( Measured " .. math.floor(map_data.kill_count / total_seconds * 3600) ..
                                    " Per Hour )")
    else
        kill_count_hour:SetText("{ol}( Predicted " .. math.floor(map_data.kill_count / total_seconds * 3600) ..
                                    " Per Hour )")
    end

    local keys = {}
    local total_items = 0
    for key, value in pairs(map_data.get_items) do
        table.insert(keys, tonumber(key))
        total_items = total_items + value
    end
    table.sort(keys)

    local total_count = total_items
    local total_items_text = info_gbox:CreateOrGetControl('richtext', 'total_items_text', 10, 60, 50, 20)
    AUTO_CAST(total_items_text)
    total_items_text:SetText("{ol}Total Items : " .. total_items)

    local y = 0
    local x = 0
    for _, k in ipairs(keys) do
        local str_key = tostring(k)
        if str_key ~= nil then
            local display = "{ol}" .. string.format("{img %s 24 24}", GetClassByType('Item', k).Icon) .. "  " ..
                                GetClassByType("Item", k).Name .. "  Get Count : " .. map_data.get_items[str_key] ..
                                " pcs"

            local display_text = info_gbox:CreateOrGetControl('richtext', 'display_text' .. str_key, 10, 95 + y, 50, 20)
            AUTO_CAST(display_text)
            display_text:SetText("{ol}" .. display)

            if x < display_text:GetWidth() + 10 then
                x = display_text:GetWidth() + 10
            end

            local kill_count_percent = map_data.get_items[str_key] / map_data.kill_count * 100
            local rounded_kill_count_percent = math.floor(kill_count_percent * 10 + 0.5) / 10
            local total_items_percent = map_data.get_items[str_key] / total_count * 100
            local rounded_total_items_percent = math.floor(total_items_percent * 10 + 0.5) / 10
            local stay_time_items = total_seconds / map_data.get_items[str_key]
            local rounded_stay_time_items = math.floor(stay_time_items * 10 + 0.5) / 10
            local display2 = "        " .. rounded_kill_count_percent .. "%(@Kill Count)   " ..
                                 rounded_total_items_percent .. "%(@Total Items)   " .. rounded_stay_time_items ..
                                 "sec(@Stay Time)"

            local display_text2 = info_gbox:CreateOrGetControl('richtext', 'display_text2' .. str_key, 10, 120 + y, 50,
                                                               20)
            AUTO_CAST(display_text2)
            display_text2:SetText("{ol}" .. display2)
            y = y + 55
            if x < display_text2:GetWidth() + 10 then
                x = display_text2:GetWidth() + 10
            end
        end
    end

    local reset_x = map_name_text:GetWidth() + 30
    local reset_button = frame:CreateOrGetControl("button", "reset_button", reset_x, 5, 80, 30)
    AUTO_CAST(reset_button)
    reset_button:SetSkinName("test_red_button")
    reset_button:SetText("{ol}Map Reset")
    reset_button:SetEventScript(ui.LBUTTONUP, "klcount_map_reset_reserve")
    reset_button:SetEventScriptArgNumber(ui.LBUTTONUP, map_id)

    if y >= 840 then
        y = 840
    end
    frame:Resize(x + 40, 160 + y)
    frame:SetLayerLevel(150)
    info_gbox:Resize(frame:GetWidth() - 20, frame:GetHeight() - 55)
    frame:ShowWindow(1)

end]]

function klcount_map_reset_reserve(frame, ctrl, str, map_id)

    ui.MsgBox("Map Reset?", string.format("klcount_map_reset(%d)", map_id), "None")
end

function klcount_map_reset(map_id)

    --[[local old_map_file_path = string.format("../addons/%s/%s.json", addon_name_lower, map_id)
    local map_data = g.load_json(old_map_file_path);
    local map_name = GetClassByType("Map", map_id).ClassName
    map_data = {
        map_name = map_name,
        stay_time = 0,
        kill_count = 0,
        get_items = {}
    }
    g.save_json(old_map_file_path, map_data)]]

    local new_map_file_path = string.format("../addons/%s/%s/%s.json", addon_name_lower, g.active_id, map_id)
    local map_data = g.load_json(new_map_file_path);
    local map_name = GetClassByType("Map", map_id).ClassName
    map_data = {
        map_name = map_name,
        stay_time = 0,
        kill_count = 0,
        get_items = {}
    }
    g.save_json(new_map_file_path, map_data)
    local frame = ui.GetFrame(addon_name_lower .. "map_info")
    frame:ShowWindow(0)
end

function klcount_ITEM_PICK(frame, msg, class_id, item_count)

    class_id = string.gsub(class_id, ".000000", "")

    if not g.map_data.get_items[class_id] then
        g.map_data.get_items[class_id] = item_count
    else
        g.map_data.get_items[class_id] = g.map_data.get_items[class_id] + item_count
    end

    if not g.challenge_mode then
        g.save_json(g.map_file_location, g.map_data)
    end
end

function klcount__count_UPDATE(frame)

    local count_text = GET_CHILD_RECURSIVELY(frame, "count_text")
    g.count = g.count + 1
    count_text:SetText(string.format("{ol}{s16}Count : %d{/}", g.count))
    g.map_data.kill_count = g.map_data.kill_count + 1
    if not g.challenge_mode then
        g.save_json(g.map_file_location, g.map_data)
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
        y = tbl.y

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

function _G.norisan_menu_frame_open(frame, ctrl)

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

    local menu_items = _G["norisan"]["MENU"]
    local max_cols = 5
    local item_w = 35
    local item_h = 35
    local y_offset = 35

    local item_idx = 0

    if menu_items then
        for key, data in pairs(menu_items) do
            if key ~= "x" and key ~= "y" and type(data) == "table" and data.name and data.func and
                ((data.image and data.image ~= "") or (data.icon and data.icon ~= "")) then

                local col = item_idx % max_cols
                local row = math.floor(item_idx / max_cols)

                local x = col * item_w
                local y = y_offset + (row * item_h)

                local ctrl_name = "menu_item_" .. key

                local item_ui

                if data.image and data.image ~= "" then
                    item_ui = frame:CreateOrGetControl('button', ctrl_name, x, y, item_w, item_h)
                    AUTO_CAST(item_ui)
                    item_ui:SetSkinName("None")
                    item_ui:SetText(data.image)
                else
                    item_ui = frame:CreateOrGetControl('picture', ctrl_name, x, y, item_w, item_h)
                    AUTO_CAST(item_ui)
                    item_ui:SetImage(data.icon)
                    item_ui:SetEnableStretch(1)
                end

                if item_ui then
                    item_ui:SetTextTooltip("{ol}" .. data.name)
                    item_ui:SetEventScript(ui.LBUTTONUP, data.func)
                    item_ui:ShowWindow(1)
                    item_idx = item_idx + 1
                end
            end
        end
    end

    if item_idx > 0 then
        local num_rows = math.ceil(item_idx / max_cols)
        local frame_w = 0
        if num_rows == 1 then
            frame_w = math.max(40, item_idx * item_w)
        else
            frame_w = math.max(40, max_cols * item_w)
        end

        local items_h_total = (num_rows * item_h) + (num_rows > 1 and num_rows - 1 or 0)
        frame:Resize(frame_w, y_offset + items_h_total)
    else
        frame:Resize(40, 40)
    end
end

function _G.norisan_menu_move_drag(frame, ctrl)

    if frame then
        _G["norisan"]["MENU"].x = frame:GetX()
        _G["norisan"]["MENU"].y = frame:GetY()
        norisan_menu_save_json(norisan_menu_settings, _G["norisan"]["MENU"])
    end
end

function _G.norisan_menu_create_frame()

    local loaded_cfg = norisan_menu_load_json(norisan_menu_settings)
    local cfg_x = nil
    local cfg_y = nil

    if loaded_cfg then
        cfg_x = loaded_cfg.x
        cfg_y = loaded_cfg.y
    end

    if cfg_x == nil or cfg_y == nil then
        _G["norisan"]["MENU"].x = _G["norisan"]["MENU"].x or 1190
        _G["norisan"]["MENU"].y = _G["norisan"]["MENU"].y or 30
        norisan_menu_save_json(norisan_menu_settings, _G["norisan"]["MENU"])
    else
        local map_frame = ui.GetFrame("map")
        local width = map_frame:GetWidth()
        if _G["norisan"]["MENU"].x and _G["norisan"]["MENU"].x > 1920 and width <= 1920 then
            cfg_x = 1190
            cfg_y = 30
        end
        _G["norisan"]["MENU"].x = cfg_x
        _G["norisan"]["MENU"].y = cfg_y
    end

    local frame_name = _G["norisan"]["MENU"].frame_name
    local frame = ui.GetFrame(frame_name)

    if frame then
        AUTO_CAST(frame)
        frame:SetSkinName("None")
        frame:SetTitleBarSkin("None")
        frame:Resize(40, 40)
        frame:SetLayerLevel(999)
        frame:SetPos(_G["norisan"]["MENU"].x, _G["norisan"]["MENU"].y)
        frame:SetEventScript(ui.LBUTTONUP, "norisan_menu_move_drag")

        local norisan_menu_pic = frame:CreateOrGetControl('picture', "norisan_menu_pic", 0, 0, 35, 40)
        AUTO_CAST(norisan_menu_pic)
        norisan_menu_pic:SetImage("sysmenu_sys")
        norisan_menu_pic:SetEnableStretch(1)
        norisan_menu_pic:SetTextTooltip("{ol}addons menu")
        norisan_menu_pic:SetEventScript(ui.LBUTTONUP, "norisan_menu_frame_open")

        frame:ShowWindow(1)
    end

end

--[[function klcount_information_button(frame)

    AUTO_CAST(frame)
    frame:RemoveAllChild()
    if not g.settings.info then
        g.settings.info = {
            x = 670,
            y = 65
        }
        KLCOUNT_SAVE_SETTINGS()
    end

    local map_frame = ui.GetFrame("map")
    local width = map_frame:GetWidth()

    if g.settings.info.x > 1920 and width <= 1920 then
        g.settings.info.x = 670
        g.settings.info.y = 65
    end

    frame:SetPos(g.settings.info.x, g.settings.info.y)

    frame:SetSkinName("None")
    frame:SetTitleBarSkin("None")

    frame:EnableHittestFrame(1)
    frame:EnableMove(1)
    frame:SetEventScript(ui.LBUTTONUP, "KLCOUNT_POSITION_SETTING")
    local info_button = frame:CreateOrGetControl("button", "info_button", 0, 0, 80, 30)
    AUTO_CAST(info_button)
    -- info_button:SetGravity(ui.LEFT, ui.BOTTOM);
    frame:Resize(90, 40)
    info_button:SetText("{ol}MapInfo")
    info_button:SetEventScript(ui.LBUTTONUP, "klcount_information_context")
    frame:ShowWindow(1)
end]]
