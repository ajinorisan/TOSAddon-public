-- v1.0.5 23.9.5のアプデのに伴いフィールドマップではどこでも表示に変更。メンドイので（
-- v1.0.6 未知の聖域でも表示される様に。未知用自動レリックOFF隠し要素追加
local addonName = "KLCOUNT"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.0.6"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

local acutil = require("acutil")
local json = require("json")

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

    local context = ui.CreateContextMenu("klcount_context", "Kl Count", 0, 0, 200, 0)

    for i = 1, #g.settings.map_ids do
        local display_text = GetClassByType("Map", g.settings.map_ids[i]).Name
        local script = ui.AddContextMenuItem(context, display_text,
                                             string.format("klcount_map_information(%d)", g.settings.map_ids[i]))
    end

    ui.OpenContextMenu(context)
end

function klcount_map_information(map_id)
    local context = ui.CreateContextMenu("klcount_context", "Kl Count", 0, 0, 100, 0)
    local map_file_location = string.format("../addons/%s/%s.json", addonNameLower, map_id)
    local map_data = acutil.loadJSON(map_file_location);

    local total_seconds = map_data.stay_time
    local hours = math.floor(total_seconds / 3600)
    local minutes = math.floor((total_seconds % 3600) / 60)
    local seconds = total_seconds % 60

    local stay_time = "Stay Time : " .. string.format("%02d:%02d:%02d", hours, minutes, seconds)
    local kill_count = "Kill Count : " .. map_data.kill_count

    ui.AddContextMenuItem(context, display_text)
    ui.AddContextMenuItem(context, display_text)

    for k, v in pairs(map_data.get_items) do
        local display_text = GetClassByType("Item", k).Name .. ":" .. v
        if display_text ~= nil then
            ui.AddContextMenuItem(context, display_text)
        end
    end
    ui.OpenContextMenu(context)
end

function klcount_information_button(frame)

    local frame = ui.GetFrame("klcount")
    frame:RemoveAllChild()
    frame:SetPos(g.settings.frame_x, g.settings.frame_y)
    frame:SetSkinName("None")
    frame:SetTitleBarSkin("None")
    local info_button = frame:CreateOrGetControl("button", "info_button", 0, 0, 80, 30)
    AUTO_CAST(info_button)
    frame:Resize(80, 30)
    info_button:SetText("klcount")
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

    g.map_id = session.GetMapID()
    local map_name = GetClassByType("Map", g.map_id).Name
    local map_text = frame:CreateOrGetControl("richtext", "map_text", 10, 35, 200, 30)
    map_text:SetText(string.format("{s16}%s{/}", map_name))

    frame:RunUpdateScript("KLCOUNT_TIME_UPDATE", 1.0)

end

function KLCOUNT_TIME_UPDATE(frame)

    g.time = imcTime.GetAppTimeMS() - g.start_time
    local h = math.floor(g.time / (60 * 60 * 1000))
    local m = math.floor((g.time / (60 * 1000)) % 60)
    local s = math.floor((g.time / 1000) % 60)
    local timer_text = frame:CreateOrGetControl("richtext", "timer_text", 90, 60, 200, 30)
    timer_text:SetText(string.format("{ol}{s16}%02d:%02d:%02d{/}", h, m, s))
    g.map_data.stay_time = g.map_data.stay_time + 60
    acutil.saveJSON(g.map_file_location, g.map_data)

    return 1
end

function klcount_ITEMMSG_ITEM_COUNT(frame, msg, class_id, item_count)

    if not g.map_data.get_items[class_id] then
        g.map_data.get_items[class_id] = item_count
    else
        g.map_data.get_items[class_id] = g.map_data.get_items[class_id] + item_count
    end
    acutil.saveJSON(g.map_file_location, g.map_data)
end

function klcount_ON_CHALLENGE_MODE_TOTAL_KILL_COUNT(frame, msg, str, arg)
    local msgList = StringSplit(str, '#');

    if msgList[1] == "SHOW" then
        local frame = ui.GetFrame("klcount")
        frame:ShowWindow(0)
    end

end

function klcount_GAME_START()

    local addon = g.addon
    local frame = g.frame

    local player_character = GetMyPCObject();
    local current_map = GetZoneName(player_character)
    local map_class = GetClass("Map", current_map)
    local map_id = session.GetMapID()

    if map_class.MapType == "Field" or map_class.MapType == "Dungeon" then
        KLCOUNT_INIT_FRAME()

        addon:RegisterMsg("EXP_UPDATE", "KLCOUNT_UPDATE")
        addon:RegisterMsg('ITEM_PICK', 'klcount_ITEMMSG_ITEM_COUNT');

        g.map_file_location = string.format("../addons/%s/%s.json", addonNameLower, map_id)
        local map_data = acutil.loadJSON(g.map_file_location, g.map_data);
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
    else
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
    count_text:SetText(string.format("{ol}{s16}KLCounter : %d{/}", g.count))
    g.map_data.kill_count = g.map_data.kill_count + 1
    acutil.saveJSON(g.map_file_location, g.map_data)
end

--[[local target_map_id = {11239, -- 1F
    11242, -- 2F
    11244 -- 3F
    }

    local function is_target_map()
        local map_id = session.GetMapID()
        for i = 1, #target_map_id do
            if map_id == target_map_id[i] then
                return true
            end
        end
        return false
    end

    if is_target_map() == true then
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

    local check_box = frame:CreateOrGetControl('check_box', 'checkbox', 20, 60, 15, 15)
    AUTO_CAST(check_box)
    check_box:ShowWindow(1)
    local auto_cut = g.settings.auto_cut
    local is_check = 0
    if auto_cut then
        is_check = 1
    end
    check_box:SetCheck(is_check)
    check_box:SetEventScript(ui.LBUTTONUP, "KLCOUNT_ISCHECKED")
    check_box:SetEventScriptArgNumber(ui.LBUTTONUP, is_check)
    ReserveScript("KLCOUNT_CHECKBOX_CLOSE()", 10.0)
end

function KLCOUNT_ISCHECKED(frame, ctrl, str, is_check)

    local auto_cut = g.settings.auto_cut
    if is_check == 1 then
        auto_cut = true
    else
        auto_cut = false
    end
    KLCOUNT_SAVE_SETTINGS()
    ReserveScript("KLCOUNT_CHECKBOX_CLOSE()", 5.0)
end

function KLCOUNT_CHECKBOX_CLOSE()

    local frame = ui.GetFrame("klcount")
    local check_box = GET_CHILD_RECURSIVELY(frame, "check_box")
    check_box:ShowWindow(0)
end]]

