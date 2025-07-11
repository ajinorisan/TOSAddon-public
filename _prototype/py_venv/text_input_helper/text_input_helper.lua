-- text_input_helper
local addon_name = "TEXT_INPUT_HELPER"
local addon_name_lower = string.lower(addon_name)
local author = "norisan"
local ver = "0.0.1"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addon_name] = _G["ADDONS"][author][addon_name] or {}
local g = _G["ADDONS"][author][addon_name]

g.input_dat = string.format('../addons/%s/kr_input.dat', addon_name_lower)
g.exe_path = string.format('../addons/%s/text_input_helper.exe', addon_name_lower)
g.watching_file = false

function TEXT_INPUT_HELPER_ON_INIT(addon, frame)
    g.addon = addon
    g.frame = frame
    addon:RegisterMsg("GAME_START_3SEC", "text_input_helper_GAME_START_3SEC")
end

function text_input_helper_GAME_START_3SEC(frame, msg)
    frame:RunUpdateScript("text_input_helper_open_reserve", 0.1)
end

function text_input_helper_open_reserve(frame)

    local chat = ui.GetFrame("chat")
    if not chat then
        return 1
    end

    local mainchat = GET_CHID(chat, "mainchat")
    if not mainchat or mainchat:IsVisible() == 0 then
        return 1
    end
    if keyboard.IsKeyPressed("RCTRL") == 1 then
        text_input_helper_open(frame)
    end
    return 1
end

function text_input_helper_open(frame)
    if g.watching_file then
        return
    end

    local command = string.format('start "" "%s"', g.exe_path)
    os.execute(command)

    g.watching_file = true
    frame:RunUpdateScript("text_input_helper_check_file", 0.1)

end

function text_input_helper_check_file(frame)

    local file = io.open(g.input_dat, "r")

    if not file then
        return 1
    end

    local hangul_text = file:read("*a")
    file:close()
    os.remove(g.input_dat)
    g.watching_file = false

    if hangul_text == nil or hangul_text == "" then
        return 0
    end
    text_input_helper_ui_chat(hangul_text)

    return 0
end

function text_input_helper_ui_chat(msg)
    ui.Chat(msg);
end

--[[local json = require("json")

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
end]]
