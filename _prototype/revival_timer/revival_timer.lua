-- v1.0.0 公開。 effect.PlayActorEffect(actor, 'F_sys_TPBOX_great_300', 'None', 2.0, 5.0)このコードで怖い思いした。TOS落としても鳴ってる。
-- v1.0.1 修正。
-- v1.0.2 ui.Chatがアルファベットでないとバグってたの修正。
-- v1.0.3 PTチャットの英語修正。はずい。左ALTで隠すように。
-- v1.0.4 使用文字バグ修正したはず。なんでなってたかも良くワカラン
-- v1.0.5 ウルトラワイド対応
local addon_name = "REVIVAL_TIMER"
local addon_name_lower = string.lower(addon_name)
local author = "norisan"
local ver = "1.0.5"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addon_name] = _G["ADDONS"][author][addon_name] or {}
local g = _G["ADDONS"][author][addon_name]

g.settings_file_path = string.format('../addons/%s/settings.json', addon_name_lower)

local acutil = require("acutil")
local json = require('json')
local os = require("os")

function g.mkdir_new_folder()
    local folder_path = string.format("../addons/%s", addon_name_lower)
    local file_path = string.format("../addons/%s/mkdir.txt", addon_name_lower)
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
end

function revival_timer_load_settings()

    local settings, err = g.load_json(g.settings_file_path)

    if not settings then
        settings = {
            X = 400,
            Y = 300,
            set_second = 30,
            set_text = "TEST",
            with_ptchat = false
        }
    end

    if settings.ptchat_recv == nil then
        settings.ptchat_recv = false
    end

    if settings.short_cut == nil then
        settings.short_cut = false
    end

    g.settings = settings
    g.save_json(g.settings_file_path, g.settings)
end

function REVIVAL_TIMER_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame

    g.REGISTER = {}

    revival_timer_load_settings()

    local menu_data = {
        name = "Revival Timer",
        icon = "",
        func = "revival_timer_setting",
        image = "{img test_cooltime 30 30}"
    }
    _G["norisan"]["MENU"][addon_name] = menu_data

    if not _G["norisan"]["MENU"][addon_name_lower] or _G["norisan"]["MENU"].frame_name == addon_name_lower then
        _G["norisan"]["MENU"].frame_name = addon_name_lower
        addon:RegisterMsg("GAME_START", "norisan_menu_create_frame")
    end

    addon:RegisterMsg("GAME_START_3SEC", "revival_timer_frame_init")
    g.setup_hook_and_event(addon, "UI_CHAT", "revival_timer_UI_CHAT", false)
end

function revival_timer_UI_CHAT(my_fram, my_msg)
    local msg = g.get_event_args(my_msg)

    local found_rtimer = string.find(msg, "/rtimer", 1, true)

    if found_rtimer then

        local frame = ui.GetFrame(addon_name_lower .. "show_timer")

        if frame and frame:IsVisible() == 1 then
            frame:StopUpdateScript("revival_timer_timer_update");
            frame:ShowWindow(0)
        else
            local frame = ui.CreateNewFrame("notice_on_pc", addon_name_lower .. "show_timer", 0, 0, 0, 0)
            AUTO_CAST(frame)
            frame:ShowWindow(1)
            frame:StopUpdateScript("revival_timer_timer_update");
            revival_timer_show_timer()
        end
        return
    end
    ui.Chat(msg);

    if g_uiChatHandler ~= nil then
        local func = _G[g_uiChatHandler];
        if func ~= nil then
            func(msg);
        end
    end

end

function revival_timer_DRAW_CHAT_MSG(my_frame, my_msg)

    if not g.settings.ptchat_recv then
        return
    end

    local now = os.clock()
    if g.last_rtimer_proc_time and (now - g.last_rtimer_proc_time < g.rtimer_cooldown) then
        return
    end

    local groupboxname, startindex, chatframe = g.get_event_args(my_msg)

    local frame = ui.GetFrame("chatframe")
    local size = session.ui.GetMsgInfoSize(groupboxname)
    local chat = session.ui.GetChatMsgInfo(groupboxname, size - 1)

    for i = startindex, size - 1 do

        local clusterinfo = session.ui.GetChatMsgInfo(groupboxname, i)

        local chat_id = clusterinfo:GetMsgInfoID()

        if not g.chat_check[chat_id] ~= true then
            g.chat_check[chat_id] = true
        end

        local clustername = "cluster_" .. chat_id
        local cluster = GET_CHILD_RECURSIVELY(frame, clustername)

        if not cluster then
            return
        end
        local msg = chat:GetMsg()
        local name = chat:GetCommanderName()
        local my_name = GETMYFAMILYNAME()
        if name == my_name then
            return
        end

        local found = string.find(msg, "%[R Timer%]")
        if found then
            msg = msg:gsub("%[R Timer%]", "")
            revival_timer_NICO_CHAT("{@st55_a}" .. name .. ":" .. msg)
            found = string.find(msg, " 5 sec rem.")
            if found then
                imcSound.PlaySoundEvent('sys_tp_box_3')
            end
            g.last_rtimer_proc_time = os.clock()
        end

    end
end

function revival_timer_frame_init()

    g.last_rtimer_proc_time = 0
    g.rtimer_cooldown = 3.0
    g.setup_hook_and_event(g.addon, "DRAW_CHAT_MSG", "revival_timer_DRAW_CHAT_MSG", true)

    if g.settings.short_cut then
        local sysmenu = ui.GetFrame("sysmenu")
        if sysmenu then
            sysmenu:ShowWindow(1)
            sysmenu:RunUpdateScript("revival_timer_start", 0.1)
        end
    end
end

function revival_timer_frame_close(frame, ctrl, str, num)

    local frame_name = frame:GetName()
    local frame = ui.GetFrame(frame_name)

    if frame_name == addon_name_lower .. "setting" then
        frame:ShowWindow(0)

    elseif frame_name == addon_name_lower .. "show_timer" then
        frame:ShowWindow(0)

    end
end

function revival_timer_edit_save(frame, ctrl, str, num)

    local ctrl_name = ctrl:GetName()
    local edit_text = ctrl:GetText()

    if ctrl_name == "info_edit" then
        g.settings.set_text = edit_text
        ui.SysMsg("Registration complete")
    elseif ctrl_name == "set_second_edit" and tonumber(edit_text) ~= nil then
        g.settings.set_second = tonumber(edit_text)
        ui.SysMsg("Registration complete")
    else
        ui.SysMsg("Invalid value")
        return
    end
    g.save_json(g.settings_file_path, g.settings)
end

function revival_timer_end_drag(frame, ctrl, str, num)

    g.settings.X = frame:GetX()
    g.settings.Y = frame:GetY()
    g.save_json(g.settings_file_path, g.settings)
end

function revival_timer_show_timer(frame, ctrl, str, num)

    local frame = ui.CreateNewFrame("notice_on_pc", addon_name_lower .. "show_timer", 0, 0, 0, 0)
    AUTO_CAST(frame)
    frame:SetPos(g.settings.X, g.settings.Y)
    frame:SetSkinName("chat_window")
    frame:SetLayerLevel(61)
    frame:Resize(160, 150)
    frame:EnableHittestFrame(1)
    frame:EnableMove(1)
    frame:SetEventScript(ui.LBUTTONUP, "revival_timer_end_drag")

    local show_timer_gb = frame:CreateOrGetControl("groupbox", "buffgb", 0, 30, 150, 120)
    AUTO_CAST(show_timer_gb)
    show_timer_gb:RemoveAllChild()
    show_timer_gb:SetSkinName("chat_window")

    local close_button = frame:CreateOrGetControl("button", "close_button", 0, 0, 30, 30)
    AUTO_CAST(close_button)
    close_button:SetImage("testclose_button")
    close_button:SetGravity(ui.RIGHT, ui.TOP)
    close_button:SetEventScript(ui.LBUTTONUP, "revival_timer_frame_close");

    local info_text = show_timer_gb:CreateOrGetControl('richtext', 'info_text', 10, 5, 50, 20)
    AUTO_CAST(info_text)
    info_text:SetText("{ol}{#FF0000}" .. g.settings.set_text)

    local timer_text = show_timer_gb:CreateOrGetControl('richtext', 'timer_text', 15, 30, 50, 20)
    AUTO_CAST(timer_text)
    local m = math.floor((g.settings.set_second / 60) % 60)
    local s = math.floor(g.settings.set_second % 60)
    timer_text:SetText(string.format("{ol}{s46}%02d:%02d{/}", m, s))

    local loop_timer_text = show_timer_gb:CreateOrGetControl('richtext', 'loop_timer_text', 10, 90, 50, 20)
    AUTO_CAST(loop_timer_text)
    local m = math.floor((g.settings.set_second / 60) % 60)
    local s = math.floor(g.settings.set_second % 60)
    loop_timer_text:SetText("{ol}Set Time : " .. string.format("%02d:%02d{/}", m, s))

    g.start_seconds = g.settings.set_second
    frame:RunUpdateScript("revival_timer_timer_update", 1.0)

    frame:ShowWindow(1)
    if str == "test" then
        local setting_frame = ui.GetFrame(addon_name_lower .. "setting")
        setting_frame:ShowWindow(0)
        frame:RunUpdateScript("revival_timer_frame_close", 5.0)
    end
end

function revival_timer_NICO_CHAT(msg)

    local x = ui.GetClientInitialWidth();
    local factor;
    if IMCRandom(0, 1) == 1 then
        factor = IMCRandomFloat(0.05, 0.4);
    else
        factor = IMCRandomFloat(0.6, 0.9);
    end

    local y = ui.GetClientInitialHeight() * factor;
    local spd = -IMCRandom(150, 200);

    local frame = ui.GetFrame("nico_chat");
    change_client_size(frame)
    local name = UI_EFFECT_GET_NAME(frame, "NICO_");
    local ctrl = frame:CreateControl("richtext", name, x, y, 200, 20);
    frame:SetLayerLevel(90)
    frame:ShowWindow(1);
    ctrl = tolua.cast(ctrl, "ui::CRichText");
    ctrl:EnableResizeByText(1);
    ctrl:SetText(msg);
    ctrl:RunUpdateScript("NICO_MOVING");
    ctrl:SetUserValue("NICO_SPD", spd);
    ctrl:SetUserValue("NICO_START_X", x);
    ctrl:ShowWindow(1);
    frame:RunUpdateScript("INVALIDATE_NICO");
end

function revival_timer_timer_update(frame)

    local frame = ui.GetFrame(addon_name_lower .. "show_timer")
    local timer_text = GET_CHILD_RECURSIVELY(frame, "timer_text")

    g.start_seconds = g.start_seconds - 1
    if g.start_seconds >= 0 then

        local m = math.floor((g.start_seconds / 60) % 60)
        local s = math.floor(g.start_seconds % 60)

        timer_text:SetText(string.format("{ol}{s46}%02d:%02d{/}", m, s))
        if g.start_seconds <= 10.5 and g.start_seconds >= 9.5 then

            if g.settings.with_ptchat then
                ui.Chat("/p " .. "[R Timer]" .. tostring(g.settings.set_text) .. " 10 sec rem.")
            end
            revival_timer_NICO_CHAT("{@st55_a}" .. g.settings.set_text .. " 10 sec rem.")
        elseif g.start_seconds <= 5.5 and g.start_seconds >= 4.5 then

            if g.settings.with_ptchat then
                ui.Chat("/p " .. "[R Timer]" .. tostring(g.settings.set_text) .. " 5 sec rem.")
            end
            imcSound.PlaySoundEvent('sys_tp_box_3')
            revival_timer_NICO_CHAT("{@st55_a}" .. g.settings.set_text .. " 5 sec rem.")
        end
        return 1
    else

        frame:StopUpdateScript("revival_timer_timer_update");
        revival_timer_show_timer(frame, nil, nil, nil)

    end
end

function revival_timer_setting(frame, ctrl, str, num)

    local frame = ui.CreateNewFrame("notice_on_pc", addon_name_lower .. "setting", 0, 0, 0, 0)
    AUTO_CAST(frame)
    frame:SetPos(1570, 30)
    frame:SetSkinName("bg")
    frame:Resize(190, 290)
    frame:SetLayerLevel(999)

    local close_button = frame:CreateOrGetControl("button", "close_button", 0, 0, 30, 30)
    AUTO_CAST(close_button)
    close_button:SetImage("testclose_button")
    close_button:SetGravity(ui.RIGHT, ui.TOP)
    close_button:SetEventScript(ui.LBUTTONUP, "revival_timer_frame_close");

    local info_text = frame:CreateOrGetControl('richtext', 'info_text', 10, 10, 50, 20)
    AUTO_CAST(info_text)
    info_text:SetText("{ol}Notice Text")

    local info_edit = frame:CreateOrGetControl('edit', 'info_edit', 10, 30, 140, 20)
    AUTO_CAST(info_edit)
    info_edit:SetFontName("white_16_ol")
    info_edit:SetTextAlign("center", "center")
    info_edit:SetText("{ol}" .. g.settings.set_text)
    info_edit:SetEventScript(ui.ENTERKEY, "revival_timer_edit_save")

    local set_second = frame:CreateOrGetControl('richtext', 'set_second', 10, 55, 50, 20)
    AUTO_CAST(set_second)
    set_second:SetText("{ol}Set Seconds")

    local set_second_edit = frame:CreateOrGetControl('edit', 'set_second_edit', 10, 75, 80, 20)
    AUTO_CAST(set_second_edit)
    set_second_edit:SetFontName("white_16_ol")
    set_second_edit:SetTextAlign("center", "center")
    set_second_edit:SetText("{ol}" .. g.settings.set_second)
    set_second_edit:SetEventScript(ui.ENTERKEY, "revival_timer_edit_save")

    local show_timer = frame:CreateOrGetControl("button", "show_timer", 50, 210, 90, 30)
    AUTO_CAST(show_timer)
    show_timer:SetText("{ol}Test Show")
    show_timer:SetEventScript(ui.LBUTTONUP, "revival_timer_show_timer");
    show_timer:SetEventScriptArgString(ui.LBUTTONUP, "test");

    local with_ptchat = frame:CreateOrGetControl('checkbox', "with_ptchat", 10, 100, 30, 30)
    AUTO_CAST(with_ptchat)
    with_ptchat:SetCheck(g.settings.with_ptchat and 1 or 0)
    with_ptchat:SetEventScript(ui.LBUTTONDOWN, 'revival_timer_checkbox_save')
    with_ptchat:SetText("{ol}With PT Chat")

    local ptchat_recv = frame:CreateOrGetControl('checkbox', "ptchat_recv", 10, 130, 30, 30)
    AUTO_CAST(ptchat_recv)
    ptchat_recv:SetCheck(g.settings.with_ptchat and 1 or 0)
    ptchat_recv:SetEventScript(ui.LBUTTONDOWN, 'revival_timer_checkbox_save')
    ptchat_recv:SetText("{ol}Receive PT chat{nl}display Nico chat")

    local short_cut = frame:CreateOrGetControl('checkbox', "short_cut", 10, 170, 30, 30)
    AUTO_CAST(short_cut)
    short_cut:SetCheck(g.settings.short_cut and 1 or 0)
    short_cut:SetEventScript(ui.LBUTTONDOWN, 'revival_timer_checkbox_save')
    short_cut:SetText("{ol}Shortcut ON/OFF{nl}{#FFD700}(Right ALT)")

    local notice = frame:CreateOrGetControl('richtext', 'notice', 10, 240, 100, 20)
    AUTO_CAST(notice)
    notice:SetText("{ol}{#FFD700}※Start and Hide{nl}Chat with '/rtimer'")

    frame:ShowWindow(1)
end

function revival_timer_checkbox_save(frame, ctrl, str, num)

    local is_check = ctrl:IsChecked()
    local ctrl_name = ctrl:GetName()
    if is_check == 1 then
        g.settings[ctrl_name] = true
    else
        g.settings[ctrl_name] = false
    end
    g.save_json(g.settings_file_path, g.settings)

    if ctrl_name == "short_cut" then
        local sysmenu = ui.GetFrame("sysmenu")
        if sysmenu then
            sysmenu:ShowWindow(1)
            if is_check == 1 then
                sysmenu:RunUpdateScript("revival_timer_start", 0.01)
            else
                sysmenu:StopUpdateScript("revival_timer_start")
            end
        end
    end
end

function revival_timer_start(frame)

    local downKey = keyboard.GetDownKey();
    if downKey ~= nil then

        if downKey == "RALT" then
            local frame = ui.GetFrame(addon_name_lower .. "show_timer")

            if frame and frame:IsVisible() == 1 then
                frame:StopUpdateScript("revival_timer_timer_update");
                frame:ShowWindow(0)
            else

                local frame = ui.CreateNewFrame("notice_on_pc", addon_name_lower .. "show_timer", 0, 0, 0, 0)
                AUTO_CAST(frame)
                frame:ShowWindow(1)
                frame:StopUpdateScript("revival_timer_timer_update");
                revival_timer_show_timer()
            end

            --[[elseif downKey == "LALT" then
            local frame = ui.CreateNewFrame("notice_on_pc", addon_name_lower .. "show_timer", 0, 0, 0, 0)
            AUTO_CAST(frame)
            frame:StopUpdateScript("revival_timer_timer_update");
            frame:ShowWindow(0)]]
        end
    end
    return 1
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

--[[function revival_timer_frame_init()

    local frame = ui.GetFrame("revival_timer")
    frame:SetSkinName('None')
    frame:Resize(60, 30)
    frame:SetTitleBarSkin("None")
    frame:EnableHittestFrame(1)
    frame:EnableHide(0)

    if not g.settings["screen"] then
        g.settings["screen"] = {
            x = 1570,
            y = 0
        }
        revival_timer_save_settings()
    end

    local map_frame = ui.GetFrame("map")
    local width = map_frame:GetWidth()

    local x = g.settings["screen"].x
    local y = g.settings["screen"].y

    if g.settings["screen"].x > 1920 and width <= 1920 then
        x = 1570
        y = 0
    end

    frame:SetPos(x, y)
    frame:ShowWindow(1)
    frame:RunUpdateScript("revival_timer_start", 0.01)

    local set_timer = frame:CreateOrGetControl('button', 'set_timer', 0, 0, 60, 30)
    AUTO_CAST(set_timer)
    set_timer:SetText("{ol}Timer")
    set_timer:SetEventScript(ui.LBUTTONUP, "revival_timer_setting")

    function revival_timer_frame_move_reserve(frame, ctrl, str, num)
        AUTO_CAST(frame)
        frame:SetSkinName("chat_window")
        frame:Resize(75, 30)
        frame:EnableHitTest(1)
        frame:EnableHittestFrame(1);
        frame:EnableMove(1)
        frame:SetEventScript(ui.LBUTTONUP, "revival_timer_frame_move_save")
    end

    function revival_timer_frame_move_save(frame, ctrl, str, num)
        local x = frame:GetX();
        local y = frame:GetY();
        g.settings["screen"] = {
            x = x,
            y = y
        }
        revival_timer_save_settings()
        frame:StopUpdateScript("revival_timer_move_setskin")
        frame:RunUpdateScript("revival_timer_move_setskin", 5.0)

    end

    function revival_timer_move_setskin(frame)
        frame:SetSkinName("None")
        frame:Resize(60, 30)
    end

    set_timer:SetEventScript(ui.MOUSEON, "revival_timer_frame_move_reserve")
    set_timer:SetEventScript(ui.MOUSEOFF, "revival_timer_frame_move_save")
end]]
