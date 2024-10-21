-- v1.0.0 公開。 effect.PlayActorEffect(actor, 'F_sys_TPBOX_great_300', 'None', 2.0, 5.0)このコードで怖い思いした。TOS落としても鳴ってる。
-- v1.0.1 修正。
local addonName = "REVIVAL_TIMER"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.0.1"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

g.settings_file_path = string.format('../addons/%s/settings.json', addonNameLower)

local folder_path = string.format("../addons/%s", addonNameLower)
os.execute('mkdir "' .. folder_path .. '"')

local acutil = require("acutil")
local json = require('json')
local os = require("os")

local base = {}
function g.SetupHook(func, baseFuncName)
    local addonUpper = string.upper(addonName)
    local replacementName = addonUpper .. "_BASE_" .. baseFuncName
    if (_G[replacementName] == nil) then
        _G[replacementName] = _G[baseFuncName];
        _G[baseFuncName] = func
    end
    base[baseFuncName] = _G[replacementName]
end

function revival_timer_save_settings()
    acutil.saveJSON(g.settings_file_path, g.settings)
end

function revival_timer_load_settings()
    local settings, err = acutil.loadJSON(g.settings_file_path, g.settings)

    if not settings then
        settings = {
            X = 400,
            Y = 300,
            set_second = 30,
            set_text = "TEST",
            with_ptchat = false
        }
    end

    g.settings = settings
    revival_timer_save_settings()
end

function REVIVAL_TIMER_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame
    revival_timer_load_settings()
    addon:RegisterMsg("GAME_START", "revival_timer_frame_init")

end

function revival_timer_frame_init()

    local frame = ui.GetFrame("revival_timer")
    frame:SetSkinName('None')
    frame:Resize(60, 30)
    frame:SetTitleBarSkin("None")
    frame:EnableHittestFrame(1)
    frame:EnableHide(0)
    frame:SetPos(1570, 0)
    frame:ShowWindow(1)
    frame:RunUpdateScript("revival_timer_start", 0.01)

    local set_timer = frame:CreateOrGetControl('button', 'set_timer', 0, 0, 60, 30)
    AUTO_CAST(set_timer)
    set_timer:SetText("{ol}Timer")
    set_timer:SetEventScript(ui.LBUTTONUP, "revival_timer_setting")

end

function revival_timer_frame_close(frame, ctrl, str, num)

    local frame_name = frame:GetName()
    local frame = ui.GetFrame(frame_name)

    if frame_name == addonNameLower .. "setting" then
        frame:ShowWindow(0)

    elseif frame_name == addonNameLower .. "show_timer" then
        frame:ShowWindow(0)
        -- ui.DestroyFrame(frame_name);
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
    revival_timer_save_settings()
end

function revival_timer_end_drag(frame, ctrl, str, num)

    g.settings.X = frame:GetX()
    g.settings.Y = frame:GetY()
    revival_timer_save_settings()
end

function revival_timer_show_timer(frame, ctrl, str, num)

    local frame = ui.CreateNewFrame("notice_on_pc", addonNameLower .. "show_timer", 0, 0, 0, 0)
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
        local setting_frame = ui.GetFrame(addonNameLower .. "setting")
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
    frame:SetLayerLevel(999)
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

    local frame = ui.GetFrame(addonNameLower .. "show_timer")
    local timer_text = GET_CHILD_RECURSIVELY(frame, "timer_text")

    g.start_seconds = g.start_seconds - 1
    if g.start_seconds >= 0 then

        local m = math.floor((g.start_seconds / 60) % 60)
        local s = math.floor(g.start_seconds % 60)

        timer_text:SetText(string.format("{ol}{s46}%02d:%02d{/}", m, s))
        if g.start_seconds <= 10.5 and g.start_seconds >= 9.5 then
            revival_timer_NICO_CHAT("{@st55_a}" .. g.settings.set_text .. "10 seconds ago")
            if g.settings.with_ptchat then
                ui.Chat("/p " .. g.settings.set_text .. "10 seconds ago")
            end
        elseif g.start_seconds <= 5.5 and g.start_seconds >= 4.5 then
            revival_timer_NICO_CHAT("{@st55_a}" .. g.settings.set_text .. "5 seconds ago")

            imcSound.PlaySoundEvent('sys_tp_box_3')
            if g.settings.with_ptchat then
                ui.Chat("/p " .. g.settings.set_text .. "5 seconds ago")
            end
        end
        return 1
    else

        frame:StopUpdateScript("revival_timer_timer_update");
        revival_timer_show_timer(frame, nil, nil, nil)

    end
end

function revival_timer_setting(frame, ctrl, str, num)

    local frame = ui.CreateNewFrame("notice_on_pc", addonNameLower .. "setting", 0, 0, 0, 0)
    AUTO_CAST(frame)
    frame:SetPos(1570, 30)
    frame:SetSkinName("chat_window")
    frame:Resize(180, 200)
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

    local show_timer = frame:CreateOrGetControl("button", "show_timer", 50, 135, 90, 30)
    AUTO_CAST(show_timer)
    show_timer:SetText("{ol}Test Show")
    show_timer:SetEventScript(ui.LBUTTONUP, "revival_timer_show_timer");
    show_timer:SetEventScriptArgString(ui.LBUTTONUP, "test");

    local with_ptchat = frame:CreateOrGetControl('checkbox', "with_ptchat", 10, 100, 30, 30)
    AUTO_CAST(with_ptchat)
    with_ptchat:SetCheck(g.settings.with_ptchat and 1 or 0)
    with_ptchat:SetEventScript(ui.LBUTTONDOWN, 'revival_timer_checkbox_save')
    with_ptchat:SetText("{ol}With PT Chat")

    local notice = frame:CreateOrGetControl('richtext', 'notice', 10, 170, 100, 20)
    AUTO_CAST(notice)
    notice:SetText("{ol}{#FFD700}※Start at Right ALT")

    frame:ShowWindow(1)
end

function revival_timer_checkbox_save(frame, ctrl, str, num)

    local is_check = ctrl:IsChecked()
    if is_check == 1 then
        g.settings.with_ptchat = true
    else
        g.settings.with_ptchat = false
    end
    revival_timer_save_settings()
end

function revival_timer_start(frame)
    local downKey = keyboard.GetDownKey();
    if downKey ~= nil then
        if downKey == "RALT" then
            local frame = ui.GetFrame(addonNameLower .. "show_timer")
            revival_timer_show_timer(frame, nil, nil, nil)
        end
    end
    return 1
end

