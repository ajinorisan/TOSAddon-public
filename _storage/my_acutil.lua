local addon_name = "ADDON_NAME"
local addon_name_lower = string.lower(addon_name)
local author = "norisan"
local ver = "1.0.0"

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
        local str = json.encode(tbl)
        file:write(str)
        file:close()
    end
    g.save_json(g.settings_path, g.settings)
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

    local settings = g.load_json(g.settings_path)

    if not settings then
        settings = {}
    end

    g.settings = settings
    g.save_settings()
end

function g.setup_hook_and_event(my_addon, origin_func_name, my_func_name, bool)

    if not g.FUNCS[origin_func_name] then
        g.FUNCS[origin_func_name] = _G[origin_func_name]
    end
    local origin_func = g.FUNCS[origin_func_name]
    local function hooked_function(...)

        local original_results
        local original_success = false

        if bool == true then
            original_results = {pcall(origin_func, ...)}
        end

        g.ARGS[origin_func_name] = {...}
        local b_success = pcall(imcAddOn.BroadMsg, origin_func_name)
        if bool == true and original_success then
            return table.unpack(original_results, 2, #original_results)
        else
            return
        end
    end

    _G[origin_func_name] = hooked_function
    pcall(my_addon.RegisterMsg, my_addon, origin_func_name, my_func_name)
end

function g.get_event_args(origin_func_name)
    local args = g.ARGS[origin_func_name]
    if args then
        return table.unpack(args)
    end
    return nil
end

function g.log_to_file(message)

    local file, err = io.open(g.log_file_path, "a")

    if file then
        local timestamp = os.date("[%Y-%m-%d %H:%M:%S] ")
        file:write(timestamp .. tostring(message) .. "\n")
        file:close()
    end
end

function ADDON_NAME_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame
    g.lang = option.GetCurrentCountry()
    g.cid = session.GetMySession():GetCID()
    g.login_name = session.GetMySession():GetPCApc():GetName()
    g.map_id = session.GetMapID()
    g.map_name = session.GetMapName();
end

function g.on_chat_hook(msg)

    if g.prev_chat_func then
        pcall(g.prev_chat_func, msg)
    end

    if type(msg) ~= "string" or msg == "" then
        return
    end

    local words = {}
    for word in msg:gmatch('%S+') do
        table.insert(words, word)
    end

    if #words == 0 then
        return
    end

    local cmd = table.remove(words, 1);
    if cmd then
        for _, chat_type in ipairs({"/r", "/w", "/p", "/y", "/s", "/g"}) do
            if cmd == chat_type then
                cmd = (#words > 0) and table.remove(words, 1) or nil
                break
            end
        end

        if type(cmd) == "string" and cmd:sub(1, 1) == "/" then

            local my_func = g.slash_cmds[cmd]
            if my_func then
                pcall(my_func)
                return
            end
        end
    end
end

-- アドオン読み込み時に実行する必要がある
function g.init_chat_hook()
    if g.prev_chat_func then
        return
    end
    g.prev_chat_func = ui.Chat
    ui.Chat = g.on_chat_hook
end

function g.slash_cmd(cmd, my_func)
    if cmd:sub(1, 1) ~= "/" then
        cmd = "/" .. cmd
    end
    g.slash_cmds = g.slash_cmds or {}
    g.slash_cmds[cmd] = my_func
end

-- g.init_chat_hook()

-- 必要に応じてアドオン読み込み時に実行
-- acutil.InitializeChatHook()

--[[function g.setup_hook(my_func, base_func_name)
    g.FUNCS = g.FUNCS or {}
    local addon_upper = string.upper(addon_name)
    local replace_name = addon_upper .. "_BASE_" .. base_func_name
    if (_G[replace_name] == nil) then
        _G[replace_name] = _G[base_func_name];
        _G[base_func_name] = my_func
    end
    g.FUNCS[base_func_name] = _G[replace_name]
end]]

--[[function g.setup_hook(my_func, origin_func_name)

    g.FUNCS = g.FUNCS or {}
    if not g.FUNCS[origin_func_name] then
        g.FUNCS[origin_func_name] = _G[origin_func_name]
    end

    local origin_func = _G[origin_func_name]

    local hooked_function = function(...)

        pcall(my_func, ...)
        if origin_func then
            return g.FUNCS[origin_func_name](...)
        end
    end

    _G[origin_func_name] = hooked_function
end

function g.setup_event(my_addon, origin_func_name, my_func_name)
    g.ARGS = g.ARGS or {}
    g.FUNCS = g.FUNCS or {}
    if not g.FUNCS[origin_func_name] then
        g.FUNCS[origin_func_name] = _G[origin_func_name]
    end
    local original_func = _G[origin_func_name]

    local function hooked_function(...)

        -- pcall(g.FUNCS[origin_func_name], ...)
        local success, results = pcall(original_func, ...)
        if not success then
            print("error: " .. results)
            return
        end
        g.ARGS[origin_func_name] = {...} -- 元の関数名で引数を保存
        imcAddOn.BroadMsg(origin_func_name)
        return table.unpack(results)
    end

    _G[origin_func_name] = hooked_function
    my_addon:RegisterMsg(origin_func_name, my_func_name)
end

function g.setup_event(my_addon, origin_func_name, my_func_name, bool)

    local origin_func = _G[origin_func_name]

    local function hooked_function(...)

        if bool == true then

            local results_table = {pcall(origin_func, ...)}
            local success = results_table[1]

            if not success then
                return
            end
        end

        g.ARGS = g.ARGS or {}
        g.ARGS[origin_func_name] = {...}
        imcAddOn.BroadMsg(origin_func_name)

        return table.unpack(results_table, 2, #results_table)
    end

    _G[origin_func_name] = hooked_function
    my_addon:RegisterMsg(origin_func_name, my_func_name)
end]]
