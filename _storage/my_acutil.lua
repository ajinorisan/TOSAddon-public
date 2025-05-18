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

function g.settings_make()

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

function g.log_to_file(message)

    local file_path = string.format("../addons/%s/log.txt", addon_name_lower)
    local file = io.open(file_path, "a")

    if file then
        local timestamp = os.date("[%Y-%m-%d %H:%M:%S] ")
        file:write(timestamp .. tostring(message) .. "\n")
        file:close()
    end
end

function g.format_json(data, indent)
    local indent = indent or 0
    local formatting = string.rep(" ", indent)
    local result = ""

    if type(data) == "table" then
        result = result .. "{\n"
        local is_first = true
        for k, v in pairs(data) do
            if not is_first then
                result = result .. ",\n"
            end
            is_first = false
            result = result .. formatting .. "  \"" .. tostring(k) .. "\": " .. g.format_json(v, indent + 2)
        end
        result = result .. "\n" .. formatting .. "}"
    elseif type(data) == "string" then
        result = result .. "\"" .. data .. "\""
    else
        result = result .. tostring(data)
    end

    return result
end

function g.setup_hook(func, baseFuncName)
    g.FUNCS = g.FUNCS or {}
    local addonUpper = string.upper(addonName)
    local replacementName = addonUpper .. "_BASE_" .. baseFuncName
    if (_G[replacementName] == nil) then
        _G[replacementName] = _G[baseFuncName];
        _G[baseFuncName] = func
    end
    g.FUNCS[baseFuncName] = _G[replacementName]
end

function ADDON_NAME_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame

    g.REGISTER = {}

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
        if _G["norisan"]["MENU"].x > 1920 and width <= 1920 then
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

    --[[ アドオンメニューボタンここまで
この部分はON_INIT内で書く
local menu_data = {
        name = "Auto Repair",
        icon = "sysmenu_mac",
        func = "AUTO_REPAIR_SETTING_FRAME_INIT"
    }
    _G["norisan"]["MENU"][addonName] = menu_data
    addon:RegisterMsg("GAME_START", "norisan_menu_create_frame")]]

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
