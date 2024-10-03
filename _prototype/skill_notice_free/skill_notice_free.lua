-- v1.0.0 作ってみた
-- v1.0.1 見直した。
local addonName = "skill_notice_free"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.0.1"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

local acutil = require("acutil")
local json = require("json")
local os = require("os")

g.folder_path = string.format("../addons/%s", addonNameLower)
os.execute('mkdir "' .. g.folder_path .. '"')

g.settings_file_path = string.format("../addons/%s/settings.json", addonNameLower)

local base = {}

function g.SetupHook(func, baseFuncName)
    local addonUpper = string.upper(addonName)
    local replacementName = addonUpper .. "_BASE_" .. baseFuncName
    if (_G[replacementName] == nil) then
        _G[replacementName] = _G[baseFuncName]
        _G[baseFuncName] = func
    end
    base[baseFuncName] = _G[replacementName]
end

local color_tabel = {
    [1] = "C0C0C0", -- シルバー
    [2] = "ADFF2F", -- 黄緑
    [3] = "FFFF00", -- 黄色
    [4] = "FF4500", -- オレンジ
    [5] = "00FF00", -- 緑
    [6] = "1E90FF", -- 青
    [7] = "800080", -- 紫
    [8] = "8B4513", -- 茶色
    [9] = "FF1493", -- ピンク
    [10] = "4682B4" -- 白
}

local sound_list = {
    [1] = "None",
    [2] = "premium_enchantchip",
    [3] = "system_craft_potion_succes",
    [4] = "sys_confirm",
    [5] = "sys_cube_open_normal",
    [6] = "sys_cube_open_jackpot",
    [7] = "sys_tp_box_3",
    [8] = "sys_tp_box_4",
    [9] = "sys_transcend_cast",
    [10] = "sys_card_battle_roulette_turn_end",
    [11] = "sys_card_battle_rival_slot_show",
    [12] = "sys_card_battle_percussion_timpani",
    [13] = "sys_jam_slot_equip",
    [14] = "button_inven_click_item",
    [15] = "sys_secret_alarm",
    [16] = "sys_transcend_success",
    [17] = "sys_quest_item_get",
    [18] = "quest_success_1",
    [19] = "monster_state_1",
    [20] = "button_click_stats_up",
    [21] = "sys_atk_booster_on",
    [22] = "market buy",
    [23] = "statsup"
}

local effect_list = {
    [1] = "None",
    [2] = "F_pattern025_loop",
    [3] = "F_buff_Cleric_Haste_Buff",
    [4] = "F_ground013",
    [5] = "F_archer_SiegeBurst_explosion2",
    [6] = "F_spread_in044_ghost2_fast",
    [7] = "F_spread_in002_violet",
    [8] = "F_fire038_loop",
    [9] = "F_spin008",
    [10] = "F_archere_magicarrow_gruond_loop2"
}

function SKILL_NOTICE_FREE_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame
    g.buffs = {}

    addon:RegisterMsg("GAME_START", "skill_notice_free_load_settings")
    addon:RegisterMsg("BUFF_UPDATE", "skill_notice_free_buff_update")
    addon:RegisterMsg("BUFF_ADD", "skill_notice_free_buff_add")
    addon:RegisterMsg("BUFF_REMOVE", "skill_notice_free_buff_remove")
    addon:RegisterMsg("GAME_START", "skill_notice_free_frame_init")
    addon:RegisterMsg("FPS_UPDATE", "skill_notice_free_FPS_UPDATE")
end

function skill_notice_free_FPS_UPDATE()
    local icon_frame = ui.GetFrame(addonNameLower .. "icon_frame")
    if icon_frame == nil then
        return
    elseif icon_frame:IsVisible() == 1 then
        return
    else
        skill_notice_free_frame_init()
    end
end

function skill_notice_free_load_settings()

    local settings, err = acutil.loadJSON(g.settings_file_path, g.settings)
    if err then
        -- 設定ファイル読み込み失敗時処理
        -- CHAT_SYSTEM(string.format("[%s] cannot load setting files", addonNameLower))
    end

    if not settings then
        settings = {
            x = 490,
            y = 35,
            icon_x = 500,
            icon_y = 500,
            buffs = {}
        }
    end

    g.cid = session.GetMySession():GetCID()
    if not settings[tostring(g.cid)] then
        settings[tostring(g.cid)] = {}
    end

    g.settings = settings
    skill_notice_free_save_settings()
end

function skill_notice_free_save_settings()
    acutil.saveJSON(g.settings_file_path, g.settings)
end

function skill_notice_free_end_drag(frame, ctrl, str, num)

    if frame:GetName() == "skill_notice_free" then
        g.settings.x = frame:GetX()
        g.settings.y = frame:GetY()
    elseif frame:GetName() == addonNameLower .. "icon_frame" then
        g.settings.icon_x = frame:GetX()
        g.settings.icon_y = frame:GetY()
    end
    skill_notice_free_save_settings()
end

function skill_notice_free_frame_init()

    local frame = ui.GetFrame("skill_notice_free")
    frame:RemoveAllChild()
    frame:SetSkinName("chat_window")
    frame:SetAlpha(20)
    frame:SetTitleBarSkin("None")
    frame:EnableMove(1)
    frame:EnableHitTest(1)
    frame:SetEventScript(ui.LBUTTONUP, "skill_notice_free_end_drag")
    frame:SetEventScript(ui.RBUTTONUP, "skill_notice_free_setting")
    frame:SetPos(g.settings.x or 490, g.settings.y or 35)

    local setting = frame:CreateOrGetControl("button", "setting", 150, 5, 20, 20)
    AUTO_CAST(setting)
    setting:SetSkinName("None")
    setting:SetText("{img config_button_normal 20 20}")
    setting:SetEventScript(ui.LBUTTONUP, "skill_notice_free_setting")
    setting:SetTextTooltip("Skill Notice{nl}Left-Click Settings")

    local buffgb = frame:CreateOrGetControl("groupbox", "buffgb", 0, 20, 190, 25)
    buffgb:SetSkinName("None")
    buffgb:RemoveAllChild()

    local buff_table = g.settings["buffs"]
    local cid_table = g.settings[tostring(g.cid)]
    local icon_count = 1

    local icon_frame = ui.CreateNewFrame("chat_memberlist", addonNameLower .. "icon_frame", 0, 0, 0, 0)
    AUTO_CAST(icon_frame)

    icon_frame:RemoveAllChild()
    icon_frame:SetSkinName("None")
    icon_frame:SetTitleBarSkin("None")
    icon_frame:SetAlpha(30)
    icon_frame:SetLayerLevel(61)
    icon_frame:EnableHitTest(1)
    icon_frame:EnableMove(1)
    icon_frame:SetPos(g.settings.icon_x or 500, g.settings.icon_y or 500)
    icon_frame:SetEventScript(ui.LBUTTONUP, "skill_notice_free_end_drag")
    icon_frame:ShowWindow(1)
    icon_frame:Resize(0, 0)

    local y = 0
    for str_buff_id, _ in pairs(buff_table) do

        if cid_table[str_buff_id] == nil then
            cid_table[str_buff_id] = "YES"
        end

        local buff_id = tonumber(str_buff_id)
        local mode = buff_table[str_buff_id].mode

        if cid_table[str_buff_id] == "YES" then

            local my_handle = session.GetMyHandle()
            local info_buff = info.GetBuff(my_handle, buff_id)
            local buff_class = GetClassByType("Buff", buff_id)

            if mode == "icon" then

                local icon_slot = icon_frame:CreateOrGetControl("slot", "icon_slot" .. buff_id, (icon_count - 1) * 50,
                                                                10, 50, 50)
                AUTO_CAST(icon_slot)
                icon_slot:EnablePop(0)
                icon_slot:EnableDrop(0)
                icon_slot:EnableDrag(0)
                icon_slot:SetSkinName("invenslot2")
                local image_name = GET_BUFF_ICON_NAME(buff_class)
                SET_SLOT_ICON(icon_slot, image_name)
                icon_slot:EnableHitTest(0)

                local buff_name = buff_class.ClassName
                local icon = CreateIcon(icon_slot)
                AUTO_CAST(icon)
                icon:SetTooltipType("buff")
                icon:SetTooltipArg(buff_name, buff_id, 0)
                icon_slot:Invalidate()

                local buff_count = icon_slot:CreateOrGetControl("richtext", "buff_count" .. buff_id, 0, 0, 40, 40)
                AUTO_CAST(buff_count)
                buff_count:SetGravity(ui.CENTER_HORZ, ui.CENTER_VERT)
                buff_count:SetColorTone("FFFFFFFF")
                if info_buff == nil then
                    buff_count:SetText("{ol}{s35}0")
                else
                    buff_count:SetText("{ol}{s35}" .. info_buff.over)
                end

                icon_frame:Resize(icon_count * 50 + 10, 50 + 10)
                icon_count = icon_count + 1

            else
                local gauge = buffgb:CreateOrGetControl("gauge", "gauge" .. buff_id, 10, y * 25 + 10, 160, 20)
                AUTO_CAST(gauge)
                local max_charge = buff_table[str_buff_id].max_charge
                local color = buff_table[str_buff_id].color

                gauge:SetSkinName("gauge")
                gauge:SetColorTone(color)
                if info_buff ~= nil then
                    gauge:SetPoint(info_buff.over, max_charge)
                    gauge:AddStat("{ol}{s20}%v/%m")
                    gauge:SetStatFont(0, "quickiconfont")
                    gauge:SetStatOffset(0, 20, 0)
                    gauge:SetStatAlign(0, ui.CENTER_HORZ, ui.CENTER_VERT)
                else
                    gauge:SetPoint(0, max_charge)
                    gauge:AddStat("{ol}{s20}%v/%m")
                    gauge:SetStatFont(0, "quickiconfont")
                    gauge:SetStatOffset(0, 20, 0)
                    gauge:SetStatAlign(0, ui.CENTER_HORZ, ui.CENTER_VERT)
                end

                local buff_text = buffgb:CreateOrGetControl("richtext", "buff_text" .. buff_id, 0, y * 25 + 10, 160, 20)
                AUTO_CAST(buff_text)
                local dic_buff_name = buff_class.Name
                buff_text:SetText("{ol}{s12}" .. dic_buff_name)

                y = y + 1
            end
        end

    end
    skill_notice_free_save_settings()

    buffgb:Resize(180, y * 25 + 30)
    frame:Resize(180, y * 25 + 30)
    frame:ShowWindow(1)
end

function skill_notice_free_setting(frame, ctrl, str, num)

    local setting_frame = ui.CreateNewFrame("notice_on_pc", addonNameLower .. "setting_frame", 0, 0, 200, 400)
    AUTO_CAST(setting_frame)
    setting_frame:SetSkinName("test_frame_midle_light")
    setting_frame:SetPos(200, 300)
    setting_frame:SetLayerLevel(61)
    setting_frame:RemoveAllChild()

    local title_text = setting_frame:CreateOrGetControl("richtext", "title_text", 20, 5, 200, 20)
    AUTO_CAST(title_text)
    title_text:SetText("{ol}Skill Notice Setting")

    local close = setting_frame:CreateOrGetControl("button", "close", 0, 0, 20, 20)
    AUTO_CAST(close)
    close:SetImage("testclose_button")
    close:SetGravity(ui.RIGHT, ui.TOP)
    close:SetEventScript(ui.LBUTTONUP, "skill_notice_free_newframe_close")

    local y = 50
    local index = 1

    local function create_slot_and_edit(index, y, buff_id)

        local buff_slot = setting_frame:CreateOrGetControl("slot", "buff_slot" .. index, 10, y, 50, 50)
        AUTO_CAST(buff_slot)
        buff_slot:EnablePop(0)
        buff_slot:EnableDrop(0)
        buff_slot:EnableDrag(0)
        buff_slot:SetSkinName("invenslot2")

        local buffid_edit = setting_frame:CreateOrGetControl("edit", "buffid_edit" .. index, 10, y - 20, 70, 20)
        AUTO_CAST(buffid_edit)
        buffid_edit:SetFontName("white_16_ol")
        buffid_edit:SetTextAlign("center", "center")
        buffid_edit:SetEventScript(ui.ENTERKEY, "skill_notice_free_buffid_edit")
        buffid_edit:SetEventScriptArgString(ui.ENTERKEY, setting_frame:GetName())
        buffid_edit:SetEventScriptArgNumber(ui.ENTERKEY, index)

        if buff_id then
            buffid_edit:SetText(buff_id)

            local buff_class = GetClassByType("Buff", buff_id)
            if buff_class then

                local buff_name = buff_class.ClassName
                local image_name = GET_BUFF_ICON_NAME(buff_class)
                SET_SLOT_ICON(buff_slot, image_name)

                local icon = CreateIcon(buff_slot)
                AUTO_CAST(icon)
                icon:SetTooltipType("buff")
                icon:SetTooltipArg(buff_name, buff_id, 0)
                buff_slot:Invalidate()
            end
            local save_flag = false
            skill_notice_free_buffid_edit(frame, buffid_edit, setting_frame:GetName(), index, save_flag)
        end

    end

    local buff_table = g.settings["buffs"]

    if next(buff_table) == nil then
        create_slot_and_edit(index, y, nil)
    else
        for str_buff_id, _ in pairs(buff_table) do
            local buff_id = tonumber(str_buff_id)
            create_slot_and_edit(index, y, buff_id)
            index = index + 1
            y = y + 80
        end
        create_slot_and_edit(index, y, nil)
    end

    setting_frame:Resize(615, y + 60)
    setting_frame:ShowWindow(1)
end

function skill_notice_free_newframe_close(frame, ctrl, argStr, argNum)

    frame:ShowWindow(0)
    skill_notice_free_frame_init()
end

function skill_notice_free_buffid_edit(frame, buffid_edit, frame_name, index, save_flag)

    local frame = ui.GetFrame(frame_name)
    local buff_id = tonumber(buffid_edit:GetText())
    if buff_id == nil then
        return
    end

    local buff_table = g.settings["buffs"]
    local cid_table = g.settings[tostring(g.cid)]
    local str_buff_id = tostring(buff_id)
    local buff_class = GetClassByType("Buff", buff_id)

    if buff_class ~= nil then

        local buff_name = buff_class.ClassName

        if save_flag == nil then
            save_flag = true
        end
        if save_flag then

            buff_table[str_buff_id] = buff_table[str_buff_id] or {}
            buff_table[str_buff_id].name = buff_name
            buff_table[str_buff_id].color = "FFFFFF00"
            buff_table[str_buff_id].effect = "None"
            buff_table[str_buff_id].sound = "None"
            buff_table[str_buff_id].size = 2
            buff_table[str_buff_id].max_charge = 10
            buff_table[str_buff_id].mode = "gauge"
            skill_notice_free_save_settings()
            skill_notice_free_frame_init()
            skill_notice_free_setting(nil, nil, nil, nil)
        end

        local buff_slot = GET_CHILD_RECURSIVELY(frame, "buff_slot" .. index)
        local image_name = GET_BUFF_ICON_NAME(buff_class)
        SET_SLOT_ICON(buff_slot, image_name)

        local icon = CreateIcon(buff_slot)
        AUTO_CAST(icon)
        icon:SetTooltipType("buff")
        icon:SetTooltipArg(buff_name, buff_id, 0)
        buff_slot:Invalidate()

        local y = index == 1 and 50 or (index - 1) * 80 + 50
        local buff_text = frame:CreateOrGetControl("richtext", "buff_text" .. index, 115, y - 20, 200, 20)
        AUTO_CAST(buff_text)
        local dic_buff_name = buff_class.Name
        buff_text:SetText("{ol}" .. dic_buff_name)

        local sound_text = frame:CreateOrGetControl("richtext", "sound_text" .. index, 70, y, 200, 20)
        AUTO_CAST(sound_text)
        sound_text:SetText("{ol}Sound Config")

        local sound_config = frame:CreateOrGetControl("button", "sound_config" .. index, 180, y, 25, 25)
        AUTO_CAST(sound_config)
        sound_config:SetSkinName("None")
        sound_config:SetText("{img config_button_normal 25 25}")
        sound_config:SetEventScript(ui.LBUTTONUP, "skill_notice_free_sound_select")
        sound_config:SetEventScriptArgNumber(ui.LBUTTONUP, buff_id)

        local color_text = frame:CreateOrGetControl("richtext", "color_text" .. index, 215, y, 200, 20)
        AUTO_CAST(color_text)
        color_text:SetText("{ol}Gauge Color")

        local color_box = frame:CreateOrGetControl("groupbox", "color_box" .. index, 315, y, 220, 20)
        AUTO_CAST(color_box)
        for i = 0, 9 do
            local color_class = color_tabel[i + 1]

            if color_class ~= nil then
                local color = color_box:CreateOrGetControl("picture", "color" .. index .. "_" .. i, 20 * i, 0, 20, 20)
                AUTO_CAST(color)
                color:SetImage("chat_color")
                color:SetColorTone("FF" .. color_class)
                color:SetEventScript(ui.LBUTTONUP, "skill_notice_free_color_select")
                color:SetEventScriptArgString(ui.LBUTTONUP, buff_name .. "/" .. "FF" .. color_class)
                color:SetEventScriptArgNumber(ui.LBUTTONUP, buff_id)

            end
        end

        local effect_text = frame:CreateOrGetControl("richtext", "effect_text" .. index, 70, y + 30, 200, 20)
        AUTO_CAST(effect_text)
        effect_text:SetText("{ol}Effect Config")

        local effect_config = frame:CreateOrGetControl("button", "effect_config" .. index, 180, y + 30, 25, 25)
        AUTO_CAST(effect_config)
        effect_config:SetSkinName("None")
        effect_config:SetText("{img config_button_normal 25 25}")
        effect_config:SetEventScript(ui.LBUTTONUP, "skill_notice_free_effect_select")
        effect_config:SetEventScriptArgNumber(ui.LBUTTONUP, buff_id)

        local size_text = frame:CreateOrGetControl("richtext", "size_text" .. index, 215, y + 30, 200, 20)
        AUTO_CAST(size_text)
        size_text:SetText("{ol}Effect Size")

        local size_edit = frame:CreateOrGetControl("edit", "size_edit" .. index, 310, y + 30, 40, 20)
        AUTO_CAST(size_edit)
        size_edit:SetFontName("white_16_ol")
        size_edit:SetTextAlign("center", "center")
        local size = buff_table[str_buff_id].size
        size_edit:SetText("{ol}" .. size)
        size_edit:SetEventScript(ui.ENTERKEY, "skill_notice_free_size_edit")
        size_edit:SetEventScriptArgNumber(ui.ENTERKEY, buff_id)

        local charge_text = frame:CreateOrGetControl("richtext", "charge_text" .. index, 355, y + 30, 200, 20)
        AUTO_CAST(charge_text)
        charge_text:SetText("{ol}Max Charge")

        local charge_edit = frame:CreateOrGetControl("edit", "charge_edit" .. index, 455, y + 30, 40, 20)
        AUTO_CAST(charge_edit)
        charge_edit:SetFontName("white_16_ol")
        charge_edit:SetTextAlign("center", "center")
        local charge = buff_table[str_buff_id].max_charge
        charge_edit:SetText("{ol}" .. charge)
        charge_edit:SetEventScript(ui.ENTERKEY, "skill_notice_free_charge_edit")
        charge_edit:SetEventScriptArgNumber(ui.ENTERKEY, buff_id)

        local display_text = frame:CreateOrGetControl("richtext", "display_text" .. index, 520, y, 200, 20)
        AUTO_CAST(display_text)
        display_text:SetText("{ol}Display")

        local display_check = frame:CreateOrGetControl("checkbox", "display_check" .. index, 585, y - 5, 20, 20)
        AUTO_CAST(display_check)
        display_check:SetTextTooltip("Displayed when checked{nl}Set by character")

        display_check:SetCheck(cid_table[str_buff_id] == "YES" and 1 or 0)
        display_check:SetEventScript(ui.LBUTTONUP, "skill_notice_free_setting_check")
        display_check:SetEventScriptArgNumber(ui.LBUTTONUP, buff_id)

        local mode_text = frame:CreateOrGetControl("richtext", "mode_text" .. index, 520, y + 30, 200, 20)
        AUTO_CAST(mode_text)
        mode_text:SetText("{ol}Mode")

        local mode_check = frame:CreateOrGetControl("checkbox", "mode_check" .. index, 585, y + 25, 20, 20)
        AUTO_CAST(mode_check)
        mode_check:SetTextTooltip("Icon mode when checked")
        local mode_set = 0
        if buff_table[str_buff_id].mode ~= "gauge" then
            mode_set = 1
        end
        mode_check:SetCheck(mode_set)
        mode_check:SetEventScript(ui.LBUTTONUP, "skill_notice_free_setting_check")
        mode_check:SetEventScriptArgNumber(ui.LBUTTONUP, buff_id)

        local delete_btn = frame:CreateOrGetControl("button", "delete_btn" .. index, 85, y - 25, 30, 30)
        AUTO_CAST(delete_btn)
        delete_btn:SetSkinName("test_red_button")
        delete_btn:SetText("{ol}×")
        delete_btn:SetEventScript(ui.LBUTTONUP, "skill_notice_free_setting_delete")
        delete_btn:SetEventScriptArgNumber(ui.LBUTTONUP, buff_id)

    end
end

function skill_notice_free_sound_select(frame, ctrl, str, buff_id)

    local context = ui.CreateContextMenu("SOUND_SETTING", "Sound Setting", 300, 0, 100, 100)
    for i, sound in ipairs(sound_list) do
        local script = string.format("skill_notice_free_sound_setting(%d,'%s')", buff_id, sound)
        ui.AddContextMenuItem(context, sound, script)
    end
    ui.OpenContextMenu(context)
end

function skill_notice_free_sound_setting(buff_id, sound)

    imcSound.PlaySoundEvent(sound)
    local buff_table = g.settings["buffs"]
    local str_buff_id = tostring(buff_id)
    if buff_table[str_buff_id] then
        buff_table[str_buff_id].sound = sound
        skill_notice_free_save_settings()
    end
end

function skill_notice_free_color_select(frame, ctrl, connect_str, buff_id)

    local split = SCR_STRING_CUT(connect_str, "/")
    local buff_name = split[1]
    local color_name = split[2]
    local str_buff_id = tostring(buff_id)

    local buff_table = g.settings["buffs"]
    if buff_table[str_buff_id] then
        buff_table[str_buff_id].color = color_name
        skill_notice_free_save_settings()
    end

    skill_notice_free_color_test_gauge(buff_name, color_name, buff_id)
    skill_notice_free_frame_init()
end

function skill_notice_free_color_test_gauge(buff_name, color_name, buff_id)
    local frame = ui.GetFrame(addonNameLower .. "setting_frame")

    local gauge_box = frame:CreateOrGetControl("groupbox", "gauge_box", 100, 10, 200, 30)
    AUTO_CAST(gauge_box)
    gauge_box:RemoveAllChild()

    local gauge = gauge_box:CreateOrGetControl("gauge", "gauge", 5, 5, 180, 20)
    AUTO_CAST(gauge)
    imcSound.PlaySoundEvent("sys_tp_box_3")
    ui.SysMsg(buff_name .. ":Gauge Color Setting")
    gauge:SetSkinName("gauge")
    gauge:SetColorTone(color_name)
    gauge:SetPoint(5, 10)
    gauge:AddStat("{ol}{s20}%v/%m")
    gauge:SetStatFont(0, "quickiconfont")
    gauge:SetStatAlign(0, ui.CENTER_HORZ, ui.CENTER_VERT)

    frame:ShowWindow(1)
    gauge_box:ShowWindow(1)
    ReserveScript("skill_notice_free_color_test_close()", 3.0)
end

function skill_notice_free_color_test_close()
    local frame = ui.GetFrame(addonNameLower .. "setting_frame")
    local gauge_box = GET_CHILD_RECURSIVELY(frame, "gauge_box")
    gauge_box:ShowWindow(0)
end

function skill_notice_free_effect_select(frame, ctrl, str, buff_id)

    local context = ui.CreateContextMenu("SOUND_SETTING", "Effect Setting", 300, 0, 100, 100)
    for i, effect_name in ipairs(effect_list) do
        local script = string.format("skill_notice_free_effect_setting(%d,'%s')", buff_id, effect_name)
        ui.AddContextMenuItem(context, effect_name, script)
    end
    ui.OpenContextMenu(context)
end

function skill_notice_free_effect_setting(buff_id, effect_name)

    local buff_table = g.settings["buffs"]
    local str_buff_id = tostring(buff_id)

    if buff_table[str_buff_id] then
        buff_table[str_buff_id].effect = effect_name
        local size = buff_table[str_buff_id].size
        local sound = buff_table[str_buff_id].sound

        skill_notice_free_save_settings()
        ReserveScript(string.format("skill_notice_free_effect_test('%s','%s',%d)", effect_name, sound, size), 0.1)
    end

end

function skill_notice_free_effect_test(effect_name, sound, size)

    local my_handle = session.GetMyHandle()
    local actor = world.GetActor(my_handle)
    effect.AddActorEffectByOffset(actor, effect_name, size, "MID", true, true)
    effect.DetachActorEffect(actor, effect_name, 5.0)
    if sound ~= "None" then
        imcSound.PlaySoundEvent(sound)
    end
end

function skill_notice_free_size_edit(frame, ctrl, str, buff_id)

    local size_text = tonumber(ctrl:GetText())
    if size_text <= 10 then
        local buff_table = g.settings["buffs"]
        local str_buff_id = tostring(buff_id)

        buff_table[str_buff_id].size = size_text
        skill_notice_free_save_settings()

        local effect_name = buff_table[str_buff_id].effect
        if effect_name ~= "None" then
            local size = buff_table[str_buff_id].size
            local sound = buff_table[str_buff_id].sound
            ReserveScript(string.format("skill_notice_free_effect_test('%s','%s',%d)", effect_name, sound, size), 0.1)
        end
    else
        ui.SysMsg("Set at less than 10")
    end
end

function skill_notice_free_charge_edit(frame, ctrl, str, buff_id)

    local charge_text = tonumber(ctrl:GetText())
    local buff_table = g.settings["buffs"]
    local str_buff_id = tostring(buff_id)

    buff_table[str_buff_id].max_charge = charge_text
    skill_notice_free_save_settings()
    skill_notice_free_frame_init()
end

function skill_notice_free_setting_check(frame, ctrl, str, buff_id)
    local ischeck = ctrl:IsChecked()
    local ctrl_name = ctrl:GetName()
    local cid_table = g.settings[tostring(g.cid)]
    local buff_table = g.settings["buffs"]
    local str_buff_id = tostring(buff_id)

    if string.find(ctrl_name, "display_check") ~= nil and ischeck == 1 then
        cid_table[str_buff_id] = "YES"
    elseif string.find(ctrl_name, "display_check") ~= nil and ischeck == 0 then
        cid_table[str_buff_id] = "NO"
    elseif string.find(ctrl_name, "mode_check") ~= nil and ischeck == 1 then
        buff_table[str_buff_id].mode = "icon"
    elseif string.find(ctrl_name, "mode_check") ~= nil and ischeck == 0 then
        buff_table[str_buff_id].mode = "gauge"
    end
    skill_notice_free_save_settings()
    skill_notice_free_frame_init()
end

function skill_notice_free_setting_delete(frame, ctrl, str, buff_id)
    local buff_table = g.settings["buffs"]
    local str_buff_id = tostring(buff_id)
    buff_table[str_buff_id] = nil
    skill_notice_free_save_settings()
    skill_notice_free_setting(frame, ctrl, str, nil)
end

function skill_notice_free_buff_remove(frame, msg, str, buff_id)
    local frame = ui.GetFrame("skill_notice_free")
    local my_handle = session.GetMyHandle()
    local actor = world.GetActor(my_handle)

    local buff_table = g.settings["buffs"]
    local cid_table = g.settings[tostring(g.cid)]
    local str_buff_id = tostring(buff_id)

    if cid_table[str_buff_id] ~= "YES" or not buff_table[str_buff_id] then
        return
    end

    local buff_data = buff_table[str_buff_id]

    if buff_data.mode == "icon" then
        local icon_frame = ui.GetFrame(addonNameLower .. "icon_frame")
        if icon_frame then
            local icon_slot = GET_CHILD_RECURSIVELY(icon_frame, "icon_slot" .. buff_id)
            if icon_slot then
                AUTO_CAST(icon_slot)
                local buff_count = GET_CHILD_RECURSIVELY(icon_slot, "buff_count" .. buff_id)
                AUTO_CAST(buff_count)
                if buff_count then
                    buff_count:SetText("{ol}{s35}0")
                    buff_count:SetColorTone("FFFFFFFF")
                end
            end
        end
    else
        local gauge = GET_CHILD_RECURSIVELY(frame, "gauge" .. buff_id)
        if gauge then
            AUTO_CAST(gauge)
            gauge:RemoveAllChild()
            gauge:SetPoint(0, buff_data.max_charge)
            gauge:SetStatFont(0, "quickiconfont")
            gauge:SetStatAlign(0, ui.CENTER_HORZ, ui.CENTER_VERT)
            gauge:EnableHitTest(0)
            local color = buff_table[str_buff_id].color
            gauge:SetColorTone(color)

        end

        local effect_name = buff_data.effect
        if effect_name ~= "None" then
            effect.DetachActorEffect(actor, effect_name, 0)
        end
        g.buffs[str_buff_id] = nil
    end
end

function skill_notice_free_buff_add(frame, msg, str, buff_id)

    local frame = ui.GetFrame("skill_notice_free")
    local my_handle = session.GetMyHandle()

    local buff_table = g.settings["buffs"]
    local cid_table = g.settings[tostring(g.cid)]
    local str_buff_id = tostring(buff_id)

    if cid_table[str_buff_id] ~= "YES" or not buff_table[str_buff_id] then
        return
    end

    local buff_data = buff_table[str_buff_id]
    local info_buff = info.GetBuff(my_handle, buff_id)

    if info_buff == nil then
        return
    end

    if buff_data.mode == "icon" then
        local icon_frame = ui.GetFrame(addonNameLower .. "icon_frame")
        if icon_frame then
            local icon_slot = GET_CHILD_RECURSIVELY(icon_frame, "icon_slot" .. str_buff_id)
            if icon_slot then
                AUTO_CAST(icon_slot)
                local buff_count = GET_CHILD_RECURSIVELY(icon_slot, "buff_count" .. str_buff_id)
                AUTO_CAST(buff_count)
                if buff_count then
                    buff_count:SetText("{ol}{s35}" .. info_buff.over)
                    buff_count:SetColorTone("FFFFFFFF")
                end

            end
        end

    else
        local gauge = GET_CHILD_RECURSIVELY(frame, "gauge" .. str_buff_id)
        if gauge then
            AUTO_CAST(gauge)
            gauge:RemoveAllChild()
            gauge:SetPoint(info_buff.over, buff_data.max_charge)
            gauge:SetStatFont(0, "quickiconfont")
            gauge:SetStatAlign(0, ui.CENTER_HORZ, ui.CENTER_VERT)
            gauge:EnableHitTest(0)
            local color = buff_table[str_buff_id].color
            gauge:SetColorTone(color)
        end
    end
    g.buffs[str_buff_id] = false

end

function skill_notice_free_buff_update(frame, msg, str, buff_id)

    local frame = ui.GetFrame("skill_notice_free")
    local my_handle = session.GetMyHandle()

    local buff_table = g.settings["buffs"]
    local cid_table = g.settings[tostring(g.cid)]
    local str_buff_id = tostring(buff_id)

    if cid_table[str_buff_id] ~= "YES" or not buff_table[str_buff_id] then
        return
    end

    local buff_data = buff_table[str_buff_id]
    local info_buff = info.GetBuff(my_handle, buff_id)

    if info_buff == nil then
        return
    end

    if buff_data.mode == "icon" then
        local icon_frame = ui.GetFrame(addonNameLower .. "icon_frame")
        if icon_frame then
            local icon_slot = GET_CHILD_RECURSIVELY(icon_frame, "icon_slot" .. str_buff_id)
            if icon_slot then
                AUTO_CAST(icon_slot)

                local buff_count = GET_CHILD_RECURSIVELY(icon_slot, "buff_count" .. str_buff_id)
                AUTO_CAST(buff_count)
                if buff_count then
                    buff_count:SetText("{ol}{s35}" .. info_buff.over)
                end

                if info_buff.over == buff_data.max_charge and not g.buffs[str_buff_id] then
                    buff_count:SetColorTone("FFFF0000")
                    skill_notice_free_apply_buff_effects(buff_data)

                    g.buffs[str_buff_id] = true
                end
            end
        end

    else
        local gauge = GET_CHILD_RECURSIVELY(frame, "gauge" .. str_buff_id)
        if gauge then
            AUTO_CAST(gauge)
            gauge:RemoveAllChild()
            gauge:SetPoint(info_buff.over, buff_data.max_charge)
            gauge:SetStatFont(0, "quickiconfont")
            gauge:SetStatAlign(0, ui.CENTER_HORZ, ui.CENTER_VERT)
            gauge:EnableHitTest(0)

            if info_buff.over == buff_data.max_charge and not g.buffs[str_buff_id] then

                gauge:SetColorTone("FFFF0000")
                skill_notice_free_apply_buff_effects(buff_data)
                g.buffs[str_buff_id] = true
            end
        end
    end
end

function skill_notice_free_apply_buff_effects(buff_data)
    local effect_name = buff_data.effect
    local my_handle = session.GetMyHandle()
    local actor = world.GetActor(my_handle)
    if effect_name and effect_name ~= "None" then
        local size = buff_data.size
        effect.AddActorEffectByOffset(actor, effect_name, size, "MID", true, true)
    end

    local sound = buff_data.sound
    if sound and sound ~= "None" then
        imcSound.PlaySoundEvent(sound)
    end
end
