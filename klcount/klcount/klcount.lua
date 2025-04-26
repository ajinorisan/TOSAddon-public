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
local addonName = "KLCOUNT"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.1.6"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

local acutil = require("acutil")
local json = require("json")
local os = require("os")

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

    local active_id = session.loginInfo.GetAID()
    local user_folder = string.format("../addons/%s/%s", addonNameLower, active_id)
    local user_file_path = string.format("../addons/%s/%s/mkdir.txt", addonNameLower, active_id)
    create_folder(user_folder, user_file_path)

    g.settings_file_location = string.format("../addons/%s/%s/settings.json", addonNameLower, active_id)
end
g.mkdir_new_folder()

function KLCOUNT_SAVE_SETTINGS()
    acutil.saveJSON(g.settings_file_location, g.settings);
end

function KLCOUNT_LOADSETTINGS()

    local settings = acutil.loadJSON(g.settings_file_location)

    if not settings then
        settings = {
            frame_x = 1340,
            frame_y = 20,
            map_ids = {}
        }
    end

    g.settings = settings
    KLCOUNT_SAVE_SETTINGS()

end

function klcount_information_context(frame, ctrl, str, num)
    local context = ui.CreateContextMenu("klcount_context", "{ol}Map Info", 0, 0, 200, 0)

    for i = 1, #g.settings.map_ids do
        local active_id = session.loginInfo.GetAID()
        local map_file_location = string.format("../addons/%s/%s/%s.json", addonNameLower, active_id,
            g.settings.map_ids[i])
        -- local map_file_location = string.format("../addons/%s/%s.json", addonNameLower, g.settings.map_ids[i])
        local map_data, err = acutil.loadJSON(map_file_location);

        if err then
            -- エラーが発生した場合
            CHAT_SYSTEM("Error loading map data for " .. g.settings.map_ids[i] .. ": " .. err)

            local map_name = GetClassByType("Map", g.settings.map_ids[i]).ClassName
            map_data = {
                map_name = map_name,
                stay_time = 0,
                kill_count = 0,
                get_items = {}
            }

            acutil.saveJSON(map_file_location, map_data)
            -- スキップして次のループに進む
        elseif next(map_data.get_items) ~= nil then
            local display_text = g.settings.map_ids[i] .. " " .. GetClassByType("Map", g.settings.map_ids[i]).Name
            local script = ui.AddContextMenuItem(context, display_text,
                string.format("klcount_map_information(%d)", g.settings.map_ids[i]))
        else
            local map_name = GetClassByType("Map", g.settings.map_ids[i]).ClassName
            map_data = {
                map_name = map_name,
                stay_time = 0,
                kill_count = 0,
                get_items = {}
            }
            acutil.saveJSON(map_file_location, map_data)
        end
    end

    ui.OpenContextMenu(context)
end

function klcount_map_information_close(frame, ctrl, str, num)
    local frame = ui.GetFrame(addonNameLower .. "map_info")
    frame:ShowWindow(0)
end

function klcount_map_information(map_id)

    local active_id = session.loginInfo.GetAID()
    local active_map_file_location = string.format("../addons/%s/%s/%s.json", addonNameLower, active_id, map_id)

    local map_file_location = string.format("../addons/%s/%s.json", addonNameLower, map_id)
    local map_data = acutil.loadJSON(map_file_location);
    local user_check_file = io.open(active_map_file_location, "r")

    if not user_check_file then
        acutil.saveJSON(active_map_file_location, map_data)
    else
        map_data = acutil.loadJSON(active_map_file_location)

        user_check_file:close()
    end

    local frame = ui.CreateNewFrame("notice_on_pc", addonNameLower .. "map_info", 0, 0, 0, 0)
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
    -- info_gbox:SetSkinName("test_frame_midle_light")
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
        table.insert(keys, tonumber(key)) -- 数値として挿入
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
    -- frame:Resize(x + 40, 250)
    frame:SetLayerLevel(150)
    info_gbox:Resize(frame:GetWidth() - 20, frame:GetHeight() - 55)
    frame:ShowWindow(1)

end

function klcount_map_reset_reserve(frame, ctrl, str, map_id)

    ui.MsgBox("Map Reset?", string.format("klcount_map_reset(%d)", map_id), "None")
end

function klcount_map_reset(map_id)
    local map_file_location = string.format("../addons/%s/%s.json", addonNameLower, map_id)
    local map_data = acutil.loadJSON(map_file_location);
    local map_name = GetClassByType("Map", map_id).ClassName
    map_data = {
        map_name = map_name,
        stay_time = 0,
        kill_count = 0,
        get_items = {}
    }

    acutil.saveJSON(map_file_location, map_data)

    local active_id = session.loginInfo.GetAID()
    local active_map_file_location = string.format("../addons/%s/%s/%s.json", addonNameLower, active_id, map_id)
    local map_data = acutil.loadJSON(active_map_file_location);
    local map_name = GetClassByType("Map", map_id).ClassName
    map_data = {
        map_name = map_name,
        stay_time = 0,
        kill_count = 0,
        get_items = {}
    }

    acutil.saveJSON(active_map_file_location, map_data)

    local frame = ui.GetFrame(addonNameLower .. "map_info")
    frame:ShowWindow(0)
end

function klcount_information_button(frame)

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
end

function KLCOUNT_POSITION_SETTING(frame)

    local name = frame:GetName()
    local x = frame:GetX()
    local y = frame:GetY()

    if name == addonNameLower .. "info_frame" then
        g.settings.info.x = x
        g.settings.info.y = y
    else
        g.settings.frame_x = x
        g.settings.frame_y = y
    end

    KLCOUNT_SAVE_SETTINGS()
end

function KLCOUNT_INIT_FRAME()
    local frame = ui.GetFrame("klcount")
    AUTO_CAST(frame)
    frame:ShowWindow(1)
    frame:EnableHitTest(1)
    frame:EnableMove(1)

    local map_frame = ui.GetFrame("map")
    local width = map_frame:GetWidth()

    if g.settings.frame_x > 1920 and width <= 1920 then
        g.settings.frame_x = 1340
        g.settings.frame_y = 20
    end

    frame:SetPos(g.settings.frame_x, g.settings.frame_y)

    frame:SetAlpha(80)
    frame:SetLayerLevel(31)
    frame:SetTitleBarSkin("shadow_box")
    frame:SetEventScript(ui.LBUTTONUP, "KLCOUNT_POSITION_SETTING")

    g.count = 0
    g.start_time = imcTime.GetAppTimeMS()

    local count_text = frame:CreateOrGetControl("richtext", "count_text", 10, 10, 170, 30)
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
    CHAT_SYSTEM(w)
    frame:Resize(w, 95)

    frame:RunUpdateScript("KLCOUNT_TIME_UPDATE", 1.0)

end

function KLCOUNT_TIME_UPDATE(frame)

    local time = imcTime.GetAppTimeMS() - g.start_time
    local h = math.floor(time / (60 * 60 * 1000))
    local m = math.floor((time / (60 * 1000)) % 60)
    local s = math.floor((time / 1000) % 60)
    local timer_text = frame:CreateOrGetControl("richtext", "timer_text", 90, 60, 200, 30)
    AUTO_CAST(timer_text)
    timer_text:SetText(string.format("{ol}{s16}%02d:%02d:%02d{/}", h, m, s))
    timer_text:SetGravity(ui.RIGHT, ui.BOTTOM);
    local rect = timer_text:GetMargin();
    -- timer_text:SetMargin(rect.left, rect.top, rect.right, rect.bottom);
    timer_text:SetMargin(rect.left, rect.top, rect.right + 15, rect.bottom + 15);
    g.map_data.stay_time = g.map_data.stay_time + 1
    if not g.challenge_mode then
        acutil.saveJSON(g.map_file_location, g.map_data)
    end
    return 1
end

function klcount_ITEM_PICK(frame, msg, class_id, item_count)

    class_id = string.gsub(class_id, ".000000", "")

    if not g.map_data.get_items[class_id] then
        g.map_data.get_items[class_id] = item_count
    else
        g.map_data.get_items[class_id] = g.map_data.get_items[class_id] + item_count
    end

    if not g.challenge_mode then
        acutil.saveJSON(g.map_file_location, g.map_data)
    end
end

function klcount_ON_CHALLENGE_MODE_TOTAL_KILL_COUNT(frame, msg, str, arg)
    local msgList = StringSplit(str, '#');

    if msgList[1] == "SHOW" then
        local frame = ui.GetFrame("klcount")
        frame:ShowWindow(0)
        g.challenge_mode = true
    end

end

function klcount_GAME_START()

    local addon = g.addon
    local frame = ui.GetFrame("klcount")

    local player_character = GetMyPCObject();
    local current_map = GetZoneName(player_character)
    local map_class = GetClass("Map", current_map)
    local map_id = session.GetMapID()

    if map_class.MapType == "Field" or map_class.MapType == "Dungeon" then
        g.challenge_mode = false
        addon:RegisterMsg("EXP_UPDATE", "KLCOUNT_UPDATE")
        addon:RegisterMsg('ITEM_PICK', 'klcount_ITEM_PICK');

        local active_id = session.loginInfo.GetAID()
        g.map_file_location = string.format("../addons/%s/%s/%s.json", addonNameLower, active_id, map_id)

        -- g.map_file_location = string.format("../addons/%s/%s.json", addonNameLower, map_id)
        local map_data = acutil.loadJSON(g.map_file_location);
        if not map_data then
            local map_name = GetClassByType("Map", map_id).ClassName
            map_data = {
                map_name = map_name,
                stay_time = 0,
                kill_count = 0,
                get_items = {}
            }
        end
        g.map_data = map_data
        acutil.saveJSON(g.map_file_location, g.map_data)

        local id_check = false
        for _, id in ipairs(g.settings.map_ids) do
            if id == map_id then
                id_check = true
                break
            end
        end

        if not id_check then
            table.insert(g.settings.map_ids, map_id)
            KLCOUNT_SAVE_SETTINGS()
        end

        KLCOUNT_INIT_FRAME()

    elseif map_class.MapType == "City" then

        local info_frame = ui.CreateNewFrame("notice_on_pc", addonNameLower .. "info_frame", 0, 0, 0, 0)
        AUTO_CAST(info_frame)

        klcount_information_button(info_frame)

    end
end

function KLCOUNT_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame

    KLCOUNT_LOADSETTINGS()

    addon:RegisterMsg("UI_CHALLENGE_MODE_TOTAL_KILL_COUNT", "klcount_ON_CHALLENGE_MODE_TOTAL_KILL_COUNT");
    addon:RegisterMsg("GAME_START", "klcount_GAME_START")

end

function KLCOUNT_UPDATE(frame)

    local count_text = GET_CHILD_RECURSIVELY(frame, "count_text")
    g.count = g.count + 1
    count_text:SetText(string.format("{ol}{s16}Count : %d{/}", g.count))
    g.map_data.kill_count = g.map_data.kill_count + 1
    if not g.challenge_mode then
        acutil.saveJSON(g.map_file_location, g.map_data)
    end
end
