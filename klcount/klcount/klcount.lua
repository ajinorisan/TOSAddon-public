-- v1.0.5 23.9.5のアプデのに伴いフィールドマップではどこでも表示に変更。メンドイので（
-- v1.0.6 未知の聖域でも表示される様に。未知用自動レリックOFF隠し要素追加
-- v1.0.7 継続してマップのアイテム取得分析
-- v1.0.8 分析を詳細に
-- v1.0.9 チャレンジとかで無駄に増えるマップを無効化
-- v1.1.0 インフォフレームをちゃんと作った。褒めて欲しい。
local addonName = "KLCOUNT"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.1.0"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

local acutil = require("acutil")
local json = require("json")
local os = require("os")

g.settings_file_location = string.format("../addons/%s/new_settings.json", addonNameLower);

function KLCOUNT_SAVE_SETTINGS()

    acutil.saveJSON(g.settings_file_location, g.settings);
end

function KLCOUNT_LOADSETTINGS()

    local settings, err = acutil.loadJSON(g.settings_file_location, g.settings)

    if not settings then
        settings = {
            frame_x = 1340,
            frame_y = 20,
            auto_cut = false,
            map_ids = {}
        }
    end

    g.settings = settings
    KLCOUNT_SAVE_SETTINGS()

end

function klcount_information_context(frame, ctrl, str, num)

    local context = ui.CreateContextMenu("klcount_context", "{ol}Map Info", 0, 0, 200, 0)

    for i = 1, #g.settings.map_ids do

        local map_file_location = string.format("../addons/%s/%s.json", addonNameLower, g.settings.map_ids[i])
        local map_data = acutil.loadJSON(map_file_location);

        if next(map_data.get_items) ~= nil then

            local display_text = GetClassByType("Map", g.settings.map_ids[i]).Name
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

    local map_file_location = string.format("../addons/%s/%s.json", addonNameLower, map_id)
    local map_data = acutil.loadJSON(map_file_location);

    local frame = ui.CreateNewFrame("notice_on_pc", addonNameLower .. "map_info", 0, 0, 0, 0)
    AUTO_CAST(frame)
    frame:SetPos(1000, 50)
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
            if x < display_text2:GetWidth() then
                x = display_text2:GetWidth()
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

    frame:Resize(x + 40, 160 + y)
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
    local frame = ui.GetFrame(addonNameLower .. "map_info")
    frame:ShowWindow(0)

end

function klcount_information_button(frame)

    local frame = ui.GetFrame("klcount")
    frame:RemoveAllChild()
    frame:SetPos(g.settings.frame_x, g.settings.frame_y)
    frame:SetSkinName("None")
    frame:SetTitleBarSkin("None")
    local info_button = frame:CreateOrGetControl("button", "info_button", 0, 0, 100, 30)
    AUTO_CAST(info_button)
    frame:Resize(100, 30)
    info_button:SetText("Map Info")
    info_button:SetEventScript(ui.LBUTTONUP, "klcount_information_context")
    frame:ShowWindow(1)
end

function KLCOUNT_INIT_FRAME()
    local frame = ui.GetFrame("klcount")

    frame:ShowWindow(1)
    frame:EnableHitTest(1)
    frame:EnableMove(1)
    frame:Resize(170, 95)

    frame:SetPos(g.settings.frame_x, g.settings.frame_y)

    frame:SetAlpha(80)
    frame:SetLayerLevel(31)
    frame:SetTitleBarSkin("shadow_box")
    frame:SetEventScript(ui.LBUTTONUP, "KLCOUNT_POSITION_SETTING")

    g.count = 0
    g.start_time = imcTime.GetAppTimeMS()

    local count_text = frame:CreateOrGetControl("richtext", "count_text", 10, 10, 200, 30)
    count_text:SetText(string.format("{ol}{s16}Count : %d{/}", g.count))

    local map_id = session.GetMapID()

    local map_name = GetClassByType("Map", map_id).Name
    local map_text = frame:CreateOrGetControl("richtext", "map_text", 10, 35, 200, 30)
    map_text:SetText(string.format("{s16}%s{/}", map_name))

    frame:RunUpdateScript("KLCOUNT_TIME_UPDATE", 1.0)

end

function KLCOUNT_TIME_UPDATE(frame)

    local time = imcTime.GetAppTimeMS() - g.start_time
    local h = math.floor(time / (60 * 60 * 1000))
    local m = math.floor((time / (60 * 1000)) % 60)
    local s = math.floor((time / 1000) % 60)
    local timer_text = frame:CreateOrGetControl("richtext", "timer_text", 90, 60, 200, 30)
    timer_text:SetText(string.format("{ol}{s16}%02d:%02d:%02d{/}", h, m, s))
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

        g.map_file_location = string.format("../addons/%s/%s.json", addonNameLower, map_id)
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
        klcount_information_button(frame)
    end
end

function KLCOUNT_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame

    KLCOUNT_LOADSETTINGS()

    addon:RegisterMsg("UI_CHALLENGE_MODE_TOTAL_KILL_COUNT", "klcount_ON_CHALLENGE_MODE_TOTAL_KILL_COUNT");
    addon:RegisterMsg("GAME_START", "klcount_GAME_START")
end

function KLCOUNT_POSITION_SETTING(frame)

    g.settings.frame_x = frame:GetX()
    g.settings.frame_y = frame:GetY()
    KLCOUNT_SAVE_SETTINGS()
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

--[[function klcount_map_information(map_id)

    local map_name = GetClassByType("Map", map_id).Name
    local context = ui.CreateContextMenu("klcount_context", "{ol}" .. map_name, 0, 0, 200, 0)
    local map_file_location = string.format("../addons/%s/%s.json", addonNameLower, map_id)
    local map_data = acutil.loadJSON(map_file_location);

    local total_seconds = map_data.stay_time
    local hours = math.floor(total_seconds / 3600)
    local minutes = math.floor((total_seconds % 3600) / 60)
    local seconds = total_seconds % 60

    local stay_time = "Stay Time : " .. string.format("%03d:%02d:%02d", hours, minutes, seconds)
    local kill_count = "Kill Count : " .. map_data.kill_count

    ui.AddContextMenuItem(context, stay_time)
    ui.AddContextMenuItem(context, kill_count)

    local keys = {}
    local total_items = 0
    for key, value in pairs(map_data.get_items) do
        table.insert(keys, tonumber(key)) -- 数値として挿入
        total_items = total_items + value
    end
    local total_count = total_items
    total_items = "Total Items : " .. total_items
    ui.AddContextMenuItem(context, total_items)
    ui.AddContextMenuItem(context, "-----")

    table.sort(keys)

    for _, k in ipairs(keys) do
        local str_key = tostring(k)
        local kill_count_percent = map_data.get_items[str_key] / map_data.kill_count * 100
        local rounded_kill_count_percent = math.floor(kill_count_percent * 10 + 0.5) / 10
        local total_items_percent = map_data.get_items[str_key] / total_count * 100
        local rounded_total_items_percent = math.floor(total_items_percent * 10 + 0.5) / 10
        local stay_time_items = total_seconds / map_data.get_items[str_key]
        local rounded_stay_time_items = math.floor(stay_time_items * 10 + 0.5) / 10
        local display_text = "{ol}" .. string.format("{img %s 24 24}", GetClassByType('Item', k).Icon) .. "  " ..
                                 GetClassByType("Item", k).Name .. "{nl}" .. "         " .. map_data.get_items[str_key] ..
                                 "pcs" .. "  " .. rounded_kill_count_percent .. "%(@Kill Count)   " ..
                                 rounded_total_items_percent .. "%(@Total Items)   " .. rounded_stay_time_items ..
                                 "sec(@Stay Time)"
        if display_text ~= nil then
            ui.AddContextMenuItem(context, display_text)
        end
    end
    ui.AddContextMenuItem(context, "------")
    local script = string.format("klcount_map_reset_reserve(%d)", map_id)
    ui.AddContextMenuItem(context, "Map Info Reset", script)
    ui.OpenContextMenu(context)
end]]

--[[if map_id == 11244 then

            frame:SetEventScript(ui.RBUTTONUP, "KLCOUNT_CHECKBOX_OPEN")
            addon:RegisterMsg('BUFF_ADD', 'KLCOUNT_BUFF_ADD');
        end]]
--[[function KLCOUNT_BUFF_ADD(frame, msg, str, num)

    local auto_cut = g.settings.auto_cut
    if auto_cut then
        ReserveScript("KLCOUNT_CHECK_ALL_SLOTS()", 5.0)
    else
        return
    end
end

function KLCOUNT_CHECK_ALL_SLOTS()

    local frame = ui.GetFrame("quickslotnexpbar")
    if not frame then
        return
    end

    local info_buff = info.GetBuff(session.GetMyHandle(), 40049)
    local slot_count = 40
    for i = 1, slot_count do
        local slot = GET_CHILD_RECURSIVELY(frame, "slot" .. i)
        AUTO_CAST(slot)
        local icon = slot:GetIcon()
        if slot and icon then
            AUTO_CAST(icon)
            local icon_info = icon:GetInfo()
            local icon_name = icon_info:GetImageName()
            if icon_name == "icon_common_relic_release" and info_buff ~= nil then
                ICON_USE(icon)
                return
            end
        end
    end
end

function KLCOUNT_CHECKBOX_OPEN(frame)
    local frame = ui.GetFrame("klcount")

    local checkbox = frame:CreateOrGetControl('checkbox', 'checkbox', 20, 60, 15, 15)
    AUTO_CAST(checkbox)

    local auto_cut = g.settings.auto_cut
    local is_check = 0
    if auto_cut then
        is_check = 1
    end
    checkbox:SetCheck(is_check)
    checkbox:SetEventScript(ui.LBUTTONUP, "KLCOUNT_ISCHECKED")
    ReserveScript("KLCOUNT_CHECKBOX_CLOSE()", 10.0)
end

function KLCOUNT_ISCHECKED(frame, ctrl, str, num)
    local is_check = ctrl:IsChecked()

    if is_check == 1 then
        g.settings.auto_cut = true
    else
        g.settings.auto_cut = false
    end
    KLCOUNT_SAVE_SETTINGS()
    ReserveScript("KLCOUNT_CHECKBOX_CLOSE()", 5.0)
end

function KLCOUNT_CHECKBOX_CLOSE()

    local frame = ui.GetFrame("klcount")
    local check_box = GET_CHILD_RECURSIVELY(frame, "checkbox")
    check_box:ShowWindow(0)
end]]

