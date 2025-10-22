-- v1.0.1 1chが満員の場合にエラーになるのでギルドイベント地域に飛んでからチャンネルチェンジ
-- v1.0.2 23.09.05patch対応。ボルタからドラグーンに変更
-- v1.0.3 TPショップ開くと消えるのを修正
-- v1.0.4 UI気に食わなかったので修正
-- v1.0.5 ウルトラワイド対応。
-- v1.0.6 アラクネ姉妹に変更。閉じる設定追加
local addon_name = "GUILDEVENTWARP"
local addon_name_lower = string.lower(addon_name)
local author = "norisan"
local ver = "1.0.6"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addon_name] = _G["ADDONS"][author][addon_name] or {}
local g = _G["ADDONS"][author][addon_name]

local json = require('json')
-- local FRAME_X_POS = 1785
-- local FRAME_Y_POS = 4
local ICON_SIZE = 28
local ICON_SPACING = 35
local CH1_ID = 0

local function ts(...)

    local num_args = select('#', ...)

    if num_args == 0 then
        return
    end

    local string_parts = {}

    for i = 1, num_args do
        local arg = select(i, ...)
        table.insert(string_parts, tostring(arg))
    end

    print(table.concat(string_parts, "\t"))
end

local active_id = session.loginInfo.GetAID()
g.settings_path = string.format("../addons/%s/%s.json", addon_name_lower, active_id)

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

function GUILDEVENTWARP_SAVE_SETTINGS()
    g.save_json(g.settings_path, g.settings)
end

function GUILDEVENTWARP_LOAD_SETTINGS()

    local settings = g.load_json(g.settings_path)

    if not settings then
        settings = {
            open = 1
        }
        GUILDEVENTWARP_SAVE_SETTINGS()
    end
    g.settings = settings
end

g.channel_change = false

function GUILDEVENTWARP_ON_INIT(addon, frame)
    g.addon = addon
    g.frame = frame
    g.lang = option.GetCurrentCountry()

    g.frame:SetSkinName('None')
    g.frame:SetGravity(ui.RIGHT, ui.TOP)
    local rect = g.frame:GetMargin();
    -- g.frame:SetMargin(rect.left, rect.top + 4, rect.right + 35, rect.bottom);
    g.frame:SetMargin(rect.left, rect.top + 4, rect.right, rect.bottom);
    g.frame:SetTitleBarSkin("None")
    g.frame:RemoveAllChild()

    g.addon:RegisterMsg("GAME_START", "GUILDEVENTWARP_LOAD_SETTINGS")
    g.addon:RegisterMsg("GAME_START", "GUILDEVENTWARP_frame_init")

    if g.channel_change then
        g.channel_change = false
        g.addon:RegisterMsg("GAME_START_3SEC", "GUILDEVENTWARP_ch_change")
    end
end

--[[local induninfo = ui.GetFrame("induninfo")
local boruta_move_btn = GET_CHILD_RECURSIVELY(induninfo, "boruta_move_btn")
local indunClsID = boruta_move_btn:GetUserValue('MOVE_INDUN_CLASSID');
ts(indunClsID)]]

local guild_event_info = {{
    name = "dragoon",
    event_id = 500,
    monster = "guild_boss_dragoon_ex",
    tooltip = g.lang == "Japanese" and "{ol}ギルドイベント、ドラグーンのマップに移動します" or
        "{ol}Guild event move to the Dragoon map",
    click_func_name = "GUILDEVENTWARP_move_to_guild_event"
}, {
    name = "veliora",
    monster = "boss_Veliora_GMission",
    event_id = 501,
    tooltip = g.lang == "Japanese" and "{ol}ギルドイベント、アラクネ姉妹のマップに移動します" or
        "{ol}Guild event move to the Arachne Sisters map",
    click_func_name = "GUILDEVENTWARP_move_to_guild_event"
}, {
    name = "baubas",
    monster = "GuildEvent_npc_baubas2",
    event_id = 502,
    tooltip = g.lang == "Japanese" and "{ol}ギルドイベント、バウバスのマップに移動します" or
        "{ol}Guild event move to the Baubus map",
    click_func_name = "GUILDEVENTWARP_move_to_guild_event"
}}

function GUILDEVENTWARP_toggle_frame(frame, ctrl, str, num)

    if g.settings.open == 1 then
        for _, info in ipairs(guild_event_info) do
            local slot_name = info.name .. "_slot"
            local slot = GET_CHILD(frame, slot_name)
            AUTO_CAST(slot)
            slot:ShowWindow(0)
        end

        ctrl:SetImage("quest_arrow_l_btn")
        g.settings.open = 0

    else
        for _, info in ipairs(guild_event_info) do
            local slot_name = info.name .. "_slot"
            local slot = GET_CHILD(frame, slot_name)
            AUTO_CAST(slot)
            slot:ShowWindow(1)
        end
        ctrl:SetImage("quest_arrow_r_btn")
        g.settings.open = 1
    end
    GUILDEVENTWARP_SAVE_SETTINGS()
end

function GUILDEVENTWARP_frame_init()

    local current_x = 0

    for _, info in ipairs(guild_event_info) do
        local slot_name = info.name .. "_slot"
        local slot = g.frame:CreateOrGetControl("slot", slot_name, current_x, 0, ICON_SIZE, ICON_SIZE)
        AUTO_CAST(slot)
        slot:EnablePop(0)
        slot:EnableDrop(0)
        slot:EnableDrag(0)
        slot:SetEventScript(ui.LBUTTONUP, info.click_func_name)
        slot:SetEventScriptArgString(ui.LBUTTONUP, tostring(info.event_id))

        local mon_cls = GetClass("Monster", info.monster)
        if mon_cls then
            local icon = CreateIcon(slot);
            AUTO_CAST(icon)
            icon:SetImage(mon_cls.Icon)
            icon:SetTextTooltip(info.tooltip)
        end
        if g.settings.open == 1 then
            slot:ShowWindow(1)
        else
            slot:ShowWindow(0)
        end

        current_x = current_x + ICON_SPACING
    end

    local open = g.frame:CreateOrGetControl('picture', "open", current_x, 0, 20, 20)
    AUTO_CAST(open)

    if g.settings.open == 1 then
        open:SetImage("quest_arrow_r_btn")
    else
        open:SetImage("quest_arrow_l_btn")
    end
    open:SetEnableStretch(1)
    open:SetEventScript(ui.LBUTTONUP, "GUILDEVENTWARP_toggle_frame")

    current_x = current_x + ICON_SPACING

    g.frame:Resize(current_x - (ICON_SPACING - ICON_SIZE), ICON_SIZE)
    g.frame:ShowWindow(1)
end

function GUILDEVENTWARP_move_to_guild_event(_, _, event_id)
    g.channel_change = true
    _BORUTA_ZONE_MOVE_CLICK(event_id)
end

function GUILDEVENTWARP_ch_change()
    local current_channel_num = session.loginInfo.GetChannel() + 1
    if current_channel_num ~= 1 then
        RUN_GAMEEXIT_TIMER("Channel", CH1_ID);
    end
end

