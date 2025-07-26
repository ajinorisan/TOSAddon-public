-- text_input_helper
local addon_name = "TEXT_INPUT_HELPER"
local addon_name_lower = string.lower(addon_name)
local author = "norisan"
local ver = "0.0.1"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addon_name] = _G["ADDONS"][author][addon_name] or {}
local g = _G["ADDONS"][author][addon_name]

g.exe_path = string.format('../addons/%s/text_input_helper-v0.0.1.exe', addon_name_lower)
g.input_dat = string.format('../addons/%s/input.dat', addon_name_lower)

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

function TEXT_INPUT_HELPER_ON_INIT(addon, frame)
    g.addon = addon
    g.frame = frame
    g.watching_file = false
    g.REGISTER = {}
    addon:RegisterMsg("GAME_START_3SEC", "text_input_helper_GAME_START_3SEC")
    g.setup_hook_and_event(addon, "CHAT_SET_TO_TITLENAME", "text_input_helper_CHAT_SET_TO_TITLENAME", true)

end

function text_input_helper_CHAT_SET_TO_TITLENAME(my_frame, my_msg)
    local chatType, targetName = g.get_event_args(my_msg)
    g.chat_type = chatType
    -- print(tostring(chatType))
    -- シャウト 1--PT 2 --ギルド 3 --一般 0--ささやき 4
end

function text_input_helper_GAME_START_3SEC(frame, msg)
    frame:RunUpdateScript("text_input_helper_open_reserve", 0.01)
end

function text_input_helper_open_reserve(frame)
    local chat = ui.GetFrame("chat")
    if not chat then
        return 1;
    end
    local mainchat = chat:GetChild('mainchat')
    if not mainchat or mainchat:IsVisible() == 0 then
        return 1;
    end
    if keyboard.IsKeyPressed("RCTRL") == 1 then
        text_input_helper_open(frame);
    end
    return 1
end

function text_input_helper_open(frame)
    if g.watching_file then
        return;
    end

    local command = string.format('start "PyHelper" /B "%s"', g.exe_path)
    os.execute(command)

    g.watching_file = true
    frame:RunUpdateScript("text_input_helper_check_file", 0.1)
end

function text_input_helper_check_file(frame)

    local file = io.open(g.input_dat, "r")
    if not file then
        return 1;
    end

    g.watching_file = false
    local text_data = file:read("*a")
    file:close()
    os.remove(g.input_dat)

    if text_data == "" then
        local chat = ui.GetFrame("chat")
        chat:RunUpdateScript("text_input_helper_chatwindow_close", 0.1)
        return 0;
    end

    text_input_helper_ui_chat(text_data)
    return 0
end

function text_input_helper_ui_chat(msg)
    local msg_head = ""
    local chat = ui.GetFrame("chat")
    if g.chat_type == 0 then
        msg_head = ""
    elseif g.chat_type == 1 then
        msg_head = "/y "
    elseif g.chat_type == 2 then
        msg_head = "/p "
    elseif g.chat_type == 3 then
        msg_head = "/g "
    elseif g.chat_type == 4 then
        local chat = ui.GetFrame("chat")
        local edit_to_bg = GET_CHILD(chat, 'edit_to_bg')
        AUTO_CAST(edit_to_bg)
        local name = GET_CHILD(edit_to_bg, 'title_to')
        AUTO_CAST(name)
        local target = string.gsub(name:GetText(), "To. ", "")

        msg_head = "/w " .. target .. " " .. "⇒【 " .. target .. " 】"
    else
        chat:RunUpdateScript("text_input_helper_chatwindow_close", 0.1)
        return
    end
    msg = msg_head .. msg
    ui.Chat(msg)
    chat:RunUpdateScript("text_input_helper_chatwindow_close", 0.1)
end

function text_input_helper_chatwindow_close(chat)
    local chat = ui.GetFrame("chat")
    local mainchat = chat:GetChild('mainchat')
    mainchat:RunEnterKeyScript()
    ui.ProcessReturnKey()
    chat:ShowWindow(0)
    return 0
end
