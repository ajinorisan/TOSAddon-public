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

function g.save_json(path, tbl)
    local file = io.open(path, "w")
    if file then
        local str = json.encode(tbl)
        file:write(str)
        file:close()
    end
end

function g.load_json(path)

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
local norisan_menu_addons = string.format("../%s", "addons")
local norisan_menu_addons_mkfile = string.format("../%s/mkdir.txt", "addons")
local norisan_menu_settings = string.format("../addons/%s/settings.json", "norisan_menu")
local norisan_menu_folder = string.format("../addons/%s", "norisan_menu")
local norisan_menu_mkfile = string.format("../addons/%s/mkdir.txt", "norisan_menu")
_G["norisan"] = _G["norisan"] or {}
_G["norisan"]["MENU"] = _G["norisan"]["MENU"] or {}

local json = require("json")

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
        y = tbl.y,
        move = tbl.move,
        open = tbl.open,
        layer = tbl.layer
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

function _G.norisan_menu_move_drag(frame, ctrl)
    if not frame then
        return
    end

    local current_frame_y = frame:GetY()
    local current_frame_h = frame:GetHeight()
    local base_button_h = 40

    local y_to_save = current_frame_y

    if current_frame_h > base_button_h and (_G["norisan"]["MENU"].open == 1) then
        local items_area_h_calculated = current_frame_h - base_button_h
        y_to_save = current_frame_y + items_area_h_calculated

    end

    _G["norisan"]["MENU"].x = frame:GetX()
    _G["norisan"]["MENU"].y = y_to_save

    norisan_menu_save_json(norisan_menu_settings, _G["norisan"]["MENU"])
end

function _G.norisan_menu_setting_frame_ctrl(setting, ctrl)
    local ctrl_name = ctrl:GetName()

    local frame_name = _G["norisan"]["MENU"].frame_name
    local frame = ui.GetFrame(frame_name)

    if ctrl_name == "layer_edit" then
        local layer = tonumber(ctrl:GetText())
        if layer then
            _G["norisan"]["MENU"].layer = layer
            frame:SetLayerLevel(layer)
            norisan_menu_save_json(norisan_menu_settings, _G["norisan"]["MENU"])

            local notice = _G["norisan"]["MENU"].lang == "Japanese" and "{ol}レイヤーを変更" or
                               "{ol}Change Layer"
            ui.SysMsg(notice)
            _G.norisan_menu_create_frame()
            setting:ShowWindow(0)
            return
        end
    end

    if ctrl_name == "def_setting" then

        _G["norisan"]["MENU"].x = 1190
        _G["norisan"]["MENU"].y = 30
        _G["norisan"]["MENU"].move = true
        _G["norisan"]["MENU"].open = 0
        _G["norisan"]["MENU"].layer = 79
        norisan_menu_save_json(norisan_menu_settings, _G["norisan"]["MENU"])
        _G.norisan_menu_create_frame()
        setting:ShowWindow(0)
        return
    end
    if ctrl_name == "close" then
        setting:ShowWindow(0)
        return
    end

    local is_check = ctrl:IsChecked()
    if ctrl_name == "move_toggle" then
        if is_check == 1 then
            _G["norisan"]["MENU"].move = false
        else
            _G["norisan"]["MENU"].move = true
        end
        frame:EnableMove(_G["norisan"]["MENU"].move == true and 1 or 0)
        norisan_menu_save_json(norisan_menu_settings, _G["norisan"]["MENU"])
        return
    elseif ctrl_name == "open_toggle" then
        _G["norisan"]["MENU"].open = is_check
        norisan_menu_save_json(norisan_menu_settings, _G["norisan"]["MENU"])
        _G.norisan_menu_create_frame()
        return
    end

end

function _G.norisan_menu_setting_frame(frame, ctrl)
    local setting = ui.CreateNewFrame("chat_memberlist", "norisan_menu_setting", 0, 0, 0, 0)
    AUTO_CAST(setting)

    setting:SetTitleBarSkin("None")
    setting:SetSkinName("chat_window")
    setting:Resize(260, 135)
    setting:SetLayerLevel(999)
    setting:EnableHitTest(1)
    setting:EnableMove(1)

    setting:SetPos(frame:GetX() + 200, frame:GetY())
    setting:ShowWindow(1)

    local close = setting:CreateOrGetControl("button", "close", 0, 0, 30, 30)
    AUTO_CAST(close)
    close:SetImage("testclose_button")
    close:SetGravity(ui.RIGHT, ui.TOP)
    close:SetEventScript(ui.LBUTTONUP, "norisan_menu_setting_frame_ctrl");

    local def_setting = setting:CreateOrGetControl("button", "def_setting", 10, 5, 150, 30)
    AUTO_CAST(def_setting)
    local notice = _G["norisan"]["MENU"].lang == "Japanese" and "{ol}デフォルトに戻す" or "{ol}Reset to default"
    def_setting:SetText(notice)
    def_setting:SetEventScript(ui.LBUTTONUP, "norisan_menu_setting_frame_ctrl");

    local move_toggle = setting:CreateOrGetControl('checkbox', "move_toggle", 10, 35, 30, 30)
    AUTO_CAST(move_toggle)
    move_toggle:SetCheck(_G["norisan"]["MENU"].move == true and 0 or 1)
    move_toggle:SetEventScript(ui.LBUTTONDOWN, 'norisan_menu_setting_frame_ctrl')
    local notice = _G["norisan"]["MENU"].lang == "Japanese" and "{ol}チェックするとフレーム固定" or
                       "{ol}Check to fix frame"
    move_toggle:SetText(notice)

    local open_toggle = setting:CreateOrGetControl('checkbox', "open_toggle", 10, 70, 30, 30)
    AUTO_CAST(open_toggle)
    open_toggle:SetCheck(_G["norisan"]["MENU"].open)
    open_toggle:SetEventScript(ui.LBUTTONDOWN, 'norisan_menu_setting_frame_ctrl')
    local notice = _G["norisan"]["MENU"].lang == "Japanese" and "{ol}チェックすると上開き" or
                       "{ol}Check to open upward"
    open_toggle:SetText(notice)

    local layer_text = setting:CreateOrGetControl('richtext', 'layer_text', 10, 105, 50, 20)
    AUTO_CAST(layer_text)
    local notice = _G["norisan"]["MENU"].lang == "Japanese" and "{ol}レイヤー設定" or "{ol}Set Layer"
    layer_text:SetText(notice)

    local layer_edit = setting:CreateOrGetControl('edit', 'layer_edit', 130, 105, 70, 20)
    AUTO_CAST(layer_edit)
    layer_edit:SetFontName("white_16_ol")
    layer_edit:SetTextAlign("center", "center")
    layer_edit:SetText(_G["norisan"]["MENU"].layer or 79)
    layer_edit:SetEventScript(ui.ENTERKEY, "norisan_menu_setting_frame_ctrl")
end

function _G.norisan_menu_toggle_items_display(frame, ctrl, open_dir)

    local open_up = (open_dir == 1)

    local menu_src = _G["norisan"]["MENU"]
    local max_cols = 5
    local item_w = 35
    local item_h = 35
    local y_off_down = 35

    local items = {}
    if menu_src then
        for key, data in pairs(menu_src) do
            if type(data) == "table" then
                if key ~= "x" and key ~= "y" and key ~= "open" and key ~= "move" and data.name and data.func and
                    ((data.image and data.image ~= "") or (data.icon and data.icon ~= "")) then
                    table.insert(items, {
                        key = key,
                        data = data
                    })
                end
            end
        end
    end

    local num_items = #items

    local num_rows = math.ceil(num_items / max_cols)

    local items_h = num_rows * item_h
    local frame_h_new = 40 + items_h
    local frame_y_new = _G["norisan"]["MENU"].y or 30

    if open_up then
        frame_y_new = frame_y_new - items_h
    end

    local frame_w_new
    if num_rows == 1 then
        frame_w_new = math.max(40, num_items * item_w)
    else
        frame_w_new = math.max(40, max_cols * item_w)
    end

    frame:SetPos(frame:GetX(), frame_y_new)
    frame:Resize(frame_w_new, frame_h_new)

    for idx, entry in ipairs(items) do
        local item_sidx = idx - 1
        local data = entry.data
        local key = entry.key
        local col = item_sidx % max_cols
        local x = col * item_w
        local y = 0

        if open_up then

            local logical_row_from_bottom = math.floor(item_sidx / max_cols)

            y = (frame_h_new - 40) - ((logical_row_from_bottom + 1) * item_h)
        else

            local row_down = math.floor(item_sidx / max_cols)
            y = y_off_down + (row_down * item_h)
        end

        local ctrl_name = "menu_item_" .. key
        local item_elem

        if data.image and data.image ~= "" then
            item_elem = frame:CreateOrGetControl('button', ctrl_name, x, y, item_w, item_h)
            AUTO_CAST(item_elem);
            item_elem:SetSkinName("None");
            item_elem:SetText(data.image)
        else
            item_elem = frame:CreateOrGetControl('picture', ctrl_name, x, y, item_w, item_h)
            AUTO_CAST(item_elem);
            item_elem:SetImage(data.icon);
            item_elem:SetEnableStretch(1)
        end

        if item_elem then
            item_elem:SetTextTooltip("{ol}" .. data.name)
            item_elem:SetEventScript(ui.LBUTTONUP, data.func)
            item_elem:ShowWindow(1)
        end
    end

    local main_btn = GET_CHILD(frame, "norisan_menu_pic")
    if main_btn then
        if open_up then
            main_btn:SetPos(0, frame_h_new - 40)
        else
            main_btn:SetPos(0, 0)
        end
    end
end

function _G.norisan_menu_frame_open(frame, ctrl)
    if not frame then
        return
    end

    if frame:GetHeight() > 40 then

        local children = {}
        for i = 0, frame:GetChildCount() - 1 do
            local child_obj = frame:GetChildByIndex(i)
            if child_obj then
                table.insert(children, child_obj)
            end
        end

        for _, child_obj in ipairs(children) do
            if child_obj:GetName() ~= "norisan_menu_pic" then

                frame:RemoveChild(child_obj:GetName())
            end
        end

        frame:Resize(40, 40)
        frame:SetPos(frame:GetX(), _G["norisan"]["MENU"].y or 30)
        local main_pic = GET_CHILD(frame, "norisan_menu_pic")
        if main_pic then
            main_pic:SetPos(0, 0)
        end
        return
    end

    local open_dir_val = _G["norisan"]["MENU"].open or 0
    _G.norisan_menu_toggle_items_display(frame, ctrl, open_dir_val)
end

function _G.norisan_menu_create_frame()

    _G["norisan"]["MENU"].lang = option.GetCurrentCountry()

    local loaded_cfg = norisan_menu_load_json(norisan_menu_settings)

    if loaded_cfg and loaded_cfg.layer ~= nil then
        _G["norisan"]["MENU"].layer = loaded_cfg.layer
    elseif _G["norisan"]["MENU"].layer == nil then
        _G["norisan"]["MENU"].layer = 79
    end

    if loaded_cfg and loaded_cfg.move ~= nil then
        _G["norisan"]["MENU"].move = loaded_cfg.move
    elseif _G["norisan"]["MENU"].move == nil then
        _G["norisan"]["MENU"].move = true
    end

    if loaded_cfg and loaded_cfg.open ~= nil then
        _G["norisan"]["MENU"].open = loaded_cfg.open
    elseif _G["norisan"]["MENU"].open == nil then
        _G["norisan"]["MENU"].open = 0
    end

    local default_x = 1190
    local default_y = 30

    local final_x = default_x
    local final_y = default_y

    if _G["norisan"]["MENU"].x ~= nil then
        final_x = _G["norisan"]["MENU"].x
    end
    if _G["norisan"]["MENU"].y ~= nil then
        final_y = _G["norisan"]["MENU"].y
    end

    if loaded_cfg and type(loaded_cfg.x) == "number" then
        final_x = loaded_cfg.x
    end
    if loaded_cfg and type(loaded_cfg.y) == "number" then
        final_y = loaded_cfg.y
    end

    local map_ui = ui.GetFrame("map")
    local screen_w = 1920
    if map_ui and map_ui:IsVisible() then
        screen_w = map_ui:GetWidth()
    end

    if final_x > 1920 and screen_w <= 1920 then
        final_x = default_x
        final_y = default_y
    end

    _G["norisan"]["MENU"].x = final_x
    _G["norisan"]["MENU"].y = final_y

    norisan_menu_save_json(norisan_menu_settings, _G["norisan"]["MENU"])

    local frame_name = _G["norisan"]["MENU"].frame_name
    local frame = ui.GetFrame(frame_name)

    if frame then
        AUTO_CAST(frame)
        frame:RemoveAllChild()
        frame:SetSkinName("None")
        frame:SetTitleBarSkin("None")
        frame:Resize(40, 40)
        frame:SetLayerLevel(_G["norisan"]["MENU"].layer)
        frame:EnableMove(_G["norisan"]["MENU"].move == true and 1 or 0)
        frame:SetPos(_G["norisan"]["MENU"].x, _G["norisan"]["MENU"].y)
        frame:SetEventScript(ui.LBUTTONUP, "norisan_menu_move_drag")

        local norisan_menu_pic = frame:CreateOrGetControl('picture', "norisan_menu_pic", 0, 0, 35, 40)
        AUTO_CAST(norisan_menu_pic)
        norisan_menu_pic:SetImage("sysmenu_sys")
        norisan_menu_pic:SetEnableStretch(1)
        local notice = _G["norisan"]["MENU"].lang == "Japanese" and "{nl}{ol}右クリック: 設定" or
                           "{nl}{ol}Right click: Settings"
        norisan_menu_pic:SetTextTooltip("{ol}Addons Menu" .. notice)
        norisan_menu_pic:SetEventScript(ui.LBUTTONUP, "norisan_menu_frame_open")
        norisan_menu_pic:SetEventScript(ui.RBUTTONUP, "norisan_menu_setting_frame")

        frame:ShowWindow(1)
    end

end

--[[ アドオンメニューボタンここまで
この部分はON_INIT内で書く]]
local menu_data = {
    name = "Sub Slot Set",
    icon = "icon_item_gold",
    func = "sub_slotset_make_frame",
    image = "{img btn_worldmap_zoomin 30 30}"
}
if g.get_map_type() == "City" then
    _G["norisan"]["MENU"][addon_name] = menu_data
else
    _G["norisan"]["MENU"][addon_name] = nil
end
if not _G["norisan"]["MENU"][addon_name_lower] or _G["norisan"]["MENU"].frame_name == addon_name_lower then
    _G["norisan"]["MENU"].frame_name = addon_name_lower
    addon:RegisterMsg("GAME_START", "norisan_menu_create_frame")
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
--[=[
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

function _G.norisan_menu_frame_open(frame, ctrl)

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

function _G.norisan_menu_always_visible_frame(system)

    local target_frame = ui.GetFrame("norisan_menu")
    if target_frame then
        if target_frame:IsVisible() == 0 then
            target_frame:ShowWindow(1)
        end
    else
        _G.norisan_menu_create_frame()
        return 1
    end
    return 1
end

function _G.norisan_menu_always_visible_set()

    local sysmenu = ui.GetFrame("sysmenu")
    if sysmenu then
        local system = GET_CHILD(sysmenu, "system")
        if system then
            if system:HaveUpdateScript("norisan_menu_always_visible_frame") == false then
                system:RunUpdateScript("norisan_menu_always_visible_frame", 1.0)
            end
        end
    end
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
        norisan_menu_pic:SetEventScript(ui.LBUTTONUP, "norisan_menu_frame_open")
        norisan_menu_pic:SetTextTooltip("{ol}addons menu")
    end

    if frame then
        frame:ShowWindow(1)
        _G.norisan_menu_always_visible_set()
    end

    --[[ アドオンメニューボタンここまで
この部分はON_INIT内で書く]]
    local menu_data = {
        name = "Auto Repair",
        icon = "sysmenu_mac",
        func = "AUTO_REPAIR_SETTING_FRAME_INIT"
    }
    _G["norisan"]["MENU"][addonName] = menu_data
    _G["norisan"]["MENU"].last_addon = addonName
    addon:RegisterMsg("GAME_START", "norisan_menu_create_frame")

end]=]
