local addon_name = "_AJINORI_UTILITY"
local addon_name_lower = string.lower(addon_name)
local author = "norisan"
local ver = "0.01"

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

function g.setup_hook_and_event_control(my_addon, origin_func_name, my_func_name, bool)

    local table_name, func_name = string.match(origin_func_name, "^(.-)%.(.*)$")

    g.FUNCS = g.FUNCS or {}
    if not g.FUNCS[origin_func_name] then
        g.FUNCS[origin_func_name] = _G[table_name][func_name]
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

    _G[table_name][func_name] = hooked_function

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

function _ajinori_utility_load_settings()
    local settings = g.load_json(g.settings_path)

    if not settings then
        settings = {}
    end

    if not settings[g.cid] then
        settings[g.cid] = {}
    end

    g.settings = settings
    g.save_settings()
end

function _AJINORI_UTILITY(addon, frame)

    g.addon = addon
    g.frame = frame
    g.lang = option.GetCurrentCountry()
    g.cid = session.GetMySession():GetCID()
    g.login_name = session.GetMySession():GetPCApc():GetName()

    g.REGISTER = {}

    _ajinori_utility_load_settings()

    g.setup_hook_and_event(addon, "_PROCESS_MOVE_MAIN_POPUPCHAT_FRAME",
                           "_ajinori_utility__PROCESS_MOVE_MAIN_POPUPCHAT_FRAME", false)

    g.setup_hook_and_event_control(addon, "control.SummonPet", "_ajinori_utility_control_summonpet", true)
    g.setup_hook_and_event(addon, "TOGGLE_PET_ACTIVITY", "_ajinori_utility_TOGGLE_PET_ACTIVITY", true)

    if g.get_map_type() ~= "City" then
        addon:RegisterMsg('TARGET_SET_BOSS', '_ajinori_utility_ON_MSG')
        addon:RegisterMsg('TARGET_BUFF_UPDATE', '_ajinori_utility_ON_MSG')
        addon:RegisterMsg('TARGET_CLEAR_BOSS', '_ajinori_utility_ON_MSG')
        addon:RegisterMsg('TARGET_UPDATE', '_ajinori_utility_ON_MSG')
    end

end

function _ajinori_utility_TOGGLE_PET_ACTIVITY(my_frame, my_msg)
    _ajinori_utility_control_summonpet(nil, nil)
end

function _ajinori_utility_control_summonpet(my_frame, my_msg)

    g.inanimate = false
    local summoned_pet = session.pet.GetSummonedPet()
    if summoned_pet then
        local pet_obj = summoned_pet:GetObject()
        if pet_obj.IsActivated == 1 then
            local cls_name = GetIES(pet_obj).ClassName
            local cls_list, list_cnt = GetClassList('companion')
            for index = 0, list_cnt - 1 do
                local companion_ies = GetClassByIndexFromList(cls_list, index)
                local ies_cls_name = companion_ies.ClassName
                if cls_name == ies_cls_name then
                    local Ride_only = companion_ies.RidingOnly
                    if Ride_only == "YES" then
                        g.inanimate = true
                        return
                    end
                end
            end
        end
    end
end

function _ajinori_utility_ON_MSG(frame, msg)

    local my_frame = ui.GetFrame("_ajinori_utility")

    if msg == "TARGET_CLEAR_BOSS" then
        my_frame:StopUpdateScript("_ajinori_utility_get_cooldown")
        return
    end
    my_frame:RunUpdateScript("_ajinori_utility_get_cooldown", 0.1)
end

function _ajinori_utility_get_cooldown(frame)

    local quickslotnexpbar = ui.GetFrame('quickslotnexpbar')

    for i = 0, MAX_QUICKSLOT_CNT - 1 do
        local quick_slot_info = quickslot.GetInfoByIndex(i)

        local slot = GET_CHILD_RECURSIVELY(frame, "slot" .. i + 1, "ui::CSlot")
        local pain_cool = 0
        local icon = slot:GetIcon()
        if quickslotnexpbar.type == 10005 then
            pain_cool = ICON_UPDATE_SKILL_COOLDOWN(icon)
            if pain_cool == 0 then
                ICON_USE(icon)
            end
        end
        if g.inanimate then

            local void_cool = 0
            local dance_enable = 0

            if quick_slot_info.type == 12329 then
                void_cool = ICON_UPDATE_SKILL_COOLDOWN(icon)
            elseif quick_slot_info.type == 12332 then
                dance_enable = ICON_UPDATE_SKILL_ENABLE(icon)
            end

            if void_cool ~= 0 and dance_enable == 0 then
                ON_RIDING_VEHICLE(1)
            end

            --[[if void_cool == 0 then
                ON_RIDING_VEHICLE(0)
            elseif dance_enable ~= 0 then
                ON_RIDING_VEHICLE(0)
            else
                ON_RIDING_VEHICLE(1)
            end]]
        end
    end
    return 1
end

function _ajinori_utility__PROCESS_MOVE_MAIN_POPUPCHAT_FRAME(my_frame, my_msg)
    local frame = g.get_event_args(my_msg)
    frame:RunUpdateScript("test_norisan_PROCESS_MOVE_MAIN_POPUPCHAT_FRAME", 0.1)
end

function _ajinori_utility_PROCESS_MOVE_MAIN_POPUPCHAT_FRAME(frame)
    if mouse.IsLBtnPressed() == 0 then
        MOVE_FRAME_MAIN_POPUP_CHAT_END(frame)
        return 0
    end

    local ratio = option.GetClientHeight() / option.GetClientWidth()
    local limit_offset = 10 -- limit_Offset -> limit_offset
    local limit_max_w = ui.GetSceneWidth() - limit_offset
    local limit_max_h = limit_max_w * ratio - limit_offset * 12

    local mx, my = GET_MOUSE_POS()
    mx = mx / ui.GetRatioWidth()
    my = my / ui.GetRatioHeight()

    local prev_mouse_x = frame:GetUserIValue("MOUSE_X")
    local prev_mouse_y = frame:GetUserIValue("MOUSE_Y")
    local diff_x = (mx - prev_mouse_x) -- dx -> diff_x
    local diff_y = (my - prev_mouse_y) -- dy -> diff_y

    local new_x = frame:GetUserIValue("BEFORE_W")
    local new_y = frame:GetUserIValue("BEFORE_H")
    new_x = new_x + diff_x
    new_y = new_y + diff_y

    if new_x < limit_offset then
        new_x = limit_offset
    end

    if new_y < limit_offset then
        new_y = limit_offset
    end

    local frame_w = frame:GetWidth()
    local frame_h = frame:GetHeight()

    if (new_x + frame_w) > limit_max_w then
        new_x = limit_max_w - frame_w
    end

    if (new_y + frame_h) > limit_max_h then
        new_y = (limit_max_h - frame_h)
    end

    frame:SetOffset(new_x, new_y)
    return 1
end

