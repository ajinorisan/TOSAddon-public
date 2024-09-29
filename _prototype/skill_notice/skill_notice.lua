-- v1.0.1 エフェクト重ね掛けバグ修正
-- v1.0.2 ゲージ短くした。サイズ入力の時に空白とか文字入れたらバグってたの修正。
-- v1.0.3 バイオレントバフをデカめに表示機能追加。
local addonName = "SKILL_NOTICE"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.0.3"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

g.settingsFileLoc = string.format('../addons/%s/newsettings.json', addonNameLower)

local acutil = require("acutil")
local json = require('json')

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

local bufftbl = {
    [1] = {
        text = "Pyktis",
        name = "Thunder_Charge_Buff",
        id = 1158,
        max = 30
    },
    [2] = {
        text = "Battle Spirit 8",
        name = "BattleSpirit_Buff",
        id = 1163,
        max = 8
    },
    [3] = {
        text = "Battle Spirit 10",
        name = "BattleSpirit_Buff",
        id = 1163,
        max = 10
    },
    [4] = {
        text = "Charge Arrow",
        name = "ChargeArrow_Buff",
        id = 1164,
        max = 5
    },
    [5] = {
        text = "Reload",
        name = "Reload_Buff",
        id = 1112,
        max = 10
    }

}
local color_tabel = {
    [1] = "C0C0C0", -- シルバー
    [2] = "ADFF2F", -- 黄緑
    [3] = "FFFF00", -- 黄色
    [4] = 'FF4500', -- オレンジ
    [5] = '00FF00', -- 緑
    [6] = '1E90FF', -- 青
    [7] = '800080', -- 紫
    [8] = '8B4513', -- 茶色
    [9] = "FF1493", -- ピンク
    [10] = "4682B4" -- 白
}

local sound_list = {
    [1] = "None",
    [2] = "premium_enchantchip",
    [3] = "system_craft_potion_succes",
    [4] = 'sys_confirm',
    [5] = 'sys_cube_open_normal',
    [6] = 'sys_cube_open_jackpot',
    [7] = 'sys_tp_box_3',
    [8] = 'sys_tp_box_4',
    [9] = "sys_transcend_cast",
    [10] = "sys_card_battle_roulette_turn_end",
    [11] = "sys_card_battle_rival_slot_show",
    [12] = "sys_card_battle_percussion_timpani",
    [13] = "sys_jam_slot_equip",
    [14] = 'button_inven_click_item',
    [15] = 'sys_secret_alarm',
    [16] = "sys_transcend_success",
    [17] = "sys_quest_item_get",
    [18] = "quest_success_1",
    [19] = "monster_state_1",
    [20] = 'button_click_stats_up',
    [21] = 'sys_atk_booster_on',
    [22] = "market buy",
    [23] = 'statsup'

}
local effect_list = {
    [1] = "None",
    [2] = "F_pattern025_loop",
    [3] = "F_buff_Cleric_Haste_Buff",
    [4] = 'F_ground013',
    [5] = 'F_archer_SiegeBurst_explosion2',
    [6] = 'F_spread_in044_ghost2_fast',
    [7] = 'F_spread_in002_violet',
    [8] = 'F_fire038_loop',
    [9] = "F_spin008",
    [10] = "F_archere_magicarrow_gruond_loop2"
}

function SKILL_NOTICE_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame

    skill_notice_load_settings()
    addon:RegisterMsg('BUFF_UPDATE', 'skill_notice_buff_update');
    addon:RegisterMsg('BUFF_ADD', 'skill_notice_buff_add');
    addon:RegisterMsg('BUFF_REMOVE', 'skill_notice_buff_remove');
    addon:RegisterMsg('GAME_START', "skill_notice_frame_init")

    g.cid = session.GetMySession():GetCID()
    g.buffs = {}
end

function skill_notice_load_settings()

    local settings, err = acutil.loadJSON(g.settingsFileLoc, g.settings)
    if err then
        -- 設定ファイル読み込み失敗時処理
        -- CHAT_SYSTEM(string.format("[%s] cannot load setting files", addonNameLower))
    end

    if not settings then
        settings = {
            x = 400,
            y = 400,
            buffs = {}
        }
    end

    if not settings[tostring(g.cid)] then
        settings[tostring(g.cid)] = {}
    end

    g.settings = settings
    skill_notice_save_settings()
end

function skill_notice_save_settings()
    acutil.saveJSON(g.settingsFileLoc, g.settings)
end

function skill_notice_sound_setting(buff_id, sound)

    imcSound.PlaySoundEvent(sound);
    local buff_table = g.settings["buffs"]
    if buff_table[tostring(buff_id)] then
        buff_table[tostring(buff_id)].sound = sound
        skill_notice_save_settings()
    end
end

function skill_notice_sound_select(frame, ctrl, str, buff_id)

    local context = ui.CreateContextMenu("SOUND_SETTING", "Sound Setting", 300, 0, 100, 100)
    for i, sound in ipairs(sound_list) do
        local script = string.format("skill_notice_sound_setting(%d,'%s')", buff_id, sound)
        ui.AddContextMenuItem(context, sound, script)
    end
    ui.OpenContextMenu(context)
end

function skill_notice_color_test_close()
    local frame = ui.GetFrame(addonNameLower .. "setting_frame")
    local gauge_box = GET_CHILD_RECURSIVELY(frame, "gauge_box")
    gauge_box:ShowWindow(0)
end

function skill_notice_color_test_gauge(buff_name, color_name, buff_id)
    local frame = ui.GetFrame(addonNameLower .. "setting_frame")

    local gauge_box = frame:CreateOrGetControl('groupbox', "gauge_box", 100, 10, 200, 30);
    AUTO_CAST(gauge_box)
    gauge_box:RemoveAllChild()

    local gauge = gauge_box:CreateOrGetControl("gauge", "gauge", 5, 5, 180, 20);
    AUTO_CAST(gauge)
    imcSound.PlaySoundEvent("sys_tp_box_3")
    ui.SysMsg(buff_name .. ":Gauge Color Setting")
    gauge:SetSkinName("gauge");
    gauge:SetColorTone(color_name);
    gauge:SetPoint(5, 10);
    gauge:AddStat('{ol}{s20}%v/%m');
    gauge:SetStatFont(0, 'quickiconfont');
    gauge:SetStatAlign(0, ui.CENTER_HORZ, ui.CENTER_VERT);

    frame:ShowWindow(1)
    gauge_box:ShowWindow(1)
    ReserveScript("skill_notice_color_test_close()", 3.0)
end

function skill_notice_color_select(frame, ctrl, connect_str, buff_id)
    local split = SCR_STRING_CUT(connect_str, '/')
    local buff_name = split[1]
    local color_name = split[2]

    local buff_table = g.settings["buffs"]
    if buff_table[tostring(buff_id)] then
        buff_table[tostring(buff_id)].color = color_name
        skill_notice_save_settings()
    end

    skill_notice_color_test_gauge(buff_name, color_name, buff_id)
end

function skill_notice_effect_test(effectName, sound, size)

    local myHandle = session.GetMyHandle();
    local actor = world.GetActor(myHandle)
    effect.AddActorEffectByOffset(actor, effectName, size, "MID", true, true);
    effect.DetachActorEffect(actor, effectName, 5.0);
    if sound ~= "None" then
        imcSound.PlaySoundEvent(sound);
    end
end

function skill_notice_effect_setting(buff_id, effect_Name)

    local size = 0
    local sound

    local buff_table = g.settings["buffs"]

    if buff_table[tostring(buff_id)] then
        buff_table[tostring(buff_id)].effect = effect_Name
        size = buff_table[tostring(buff_id)].size
        sound = buff_table[tostring(buff_id)].sound
    end
    skill_notice_save_settings()
    ReserveScript(string.format("skill_notice_effect_test('%s','%s',%d)", effect_Name, sound, size), 0.1)
end

function skill_notice_effect_select(frame, ctrl, str, buff_id)

    local context = ui.CreateContextMenu("SOUND_SETTING", "Effect Setting", 300, 0, 100, 100)
    for i, effect_Name in ipairs(effect_list) do
        local script = string.format("skill_notice_effect_setting(%d,'%s')", buff_id, effect_Name)
        ui.AddContextMenuItem(context, effect_Name, script)
    end
    ui.OpenContextMenu(context)
end

-- use color effect sound size max_count
function skill_notice_buffid_edit(frame, buffid_edit, frame_name, index, no_save)
    local frame = ui.GetFrame(frame_name)
    local buff_id = tonumber(buffid_edit:GetText())
    if buff_id == nil then
        return
    end
    local buff_table = g.settings["buffs"]

    local buff_class = GetClassByType("Buff", buff_id)
    if buff_class ~= nil then
        local buff_slot = GET_CHILD_RECURSIVELY(frame, "buff_slot" .. index)
        local buff_name = buff_class.ClassName
        local image_name = GET_BUFF_ICON_NAME(buff_class);
        SET_SLOT_ICON(buff_slot, image_name)

        local icon = CreateIcon(buff_slot)
        AUTO_CAST(icon)
        icon:SetTooltipType('buff');
        icon:SetTooltipArg(buff_name, buff_id, 0);
        buff_slot:Invalidate();

        local buff_name = buff_class.ClassName

        local y = index == 1 and 50 or (index - 1) * 80 + 50
        local buff_text = frame:CreateOrGetControl("richtext", "buff_text" .. index, 90, y - 20, 200, 20)
        AUTO_CAST(buff_text)
        buff_text:SetText("{ol}" .. buff_name)

        local sound_text = frame:CreateOrGetControl("richtext", "sound_text" .. index, 70, y, 200, 20)
        AUTO_CAST(sound_text)
        sound_text:SetText("{ol}Sound Config")

        local sound_config = frame:CreateOrGetControl("button", "sound_config" .. index, 180, y, 25, 25)
        AUTO_CAST(sound_config)
        sound_config:SetSkinName("None")
        sound_config:SetText("{img config_button_normal 25 25}")
        sound_config:SetEventScript(ui.LBUTTONUP, "skill_notice_sound_select")
        sound_config:SetEventScriptArgNumber(ui.LBUTTONUP, buff_id)

        local color_text = frame:CreateOrGetControl("richtext", "color_text" .. index, 220, y, 200, 20)
        AUTO_CAST(color_text)
        color_text:SetText("{ol}Gauge Color")

        local color_box = frame:CreateOrGetControl('groupbox', "color_box" .. index, 320, y, 220, 20);
        AUTO_CAST(color_box)
        for i = 0, 9 do
            local color_class = color_tabel[i + 1]

            if color_class ~= nil then
                local color = color_box:CreateOrGetControl("picture", "color" .. index .. "_" .. i, 20 * i, 0, 20, 20);
                AUTO_CAST(color)
                color:SetImage("chat_color");
                color:SetColorTone("FF" .. color_class)
                color:SetEventScript(ui.LBUTTONUP, "skill_notice_color_select")
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
        effect_config:SetEventScript(ui.LBUTTONUP, "skill_notice_effect_select")
        effect_config:SetEventScriptArgNumber(ui.LBUTTONUP, buff_id)

        if no_save == nil then
            buff_table[tostring(buff_id)] = buff_table[tostring(buff_id)] or {}
            buff_table[tostring(buff_id)].name = buff_name
            buff_table[tostring(buff_id)].color = "FFFFFF00"
            buff_table[tostring(buff_id)].effect = "None"
            buff_table[tostring(buff_id)].sound = "None"
            buff_table[tostring(buff_id)].size = 2
            buff_table[tostring(buff_id)].max_charge = 10
            buff_table[tostring(buff_id)].mode = "gauge"
            skill_notice_save_settings()
            skill_notice_frame_init()
        end

        local size_text = frame:CreateOrGetControl("richtext", "size_text" .. index, 220, y + 30, 200, 20)
        AUTO_CAST(size_text)
        size_text:SetText("{ol}Effect Size")

        local size_edit = frame:CreateOrGetControl("edit", "size_edit" .. index, 310, y + 30, 40, 20)
        AUTO_CAST(size_edit)
        size_edit:SetFontName("white_16_ol")
        size_edit:SetTextAlign("center", "center")
        local size = buff_table[tostring(buff_id)].size
        size_edit:SetText("{ol}" .. size)

        local charge_text = frame:CreateOrGetControl("richtext", "charge_text" .. index, 355, y + 30, 200, 20)
        AUTO_CAST(charge_text)
        charge_text:SetText("{ol}Max Charge")

        local charge_edit = frame:CreateOrGetControl("edit", "charge_edit" .. index, 455, y + 30, 40, 20)
        AUTO_CAST(charge_edit)
        charge_edit:SetFontName("white_16_ol")
        charge_edit:SetTextAlign("center", "center")
        local charge = buff_table[tostring(buff_id)].max_charge
        charge_edit:SetText("{ol}" .. charge)

        local mode_text = frame:CreateOrGetControl("richtext", "mode_text" .. index, 500, y + 30, 200, 20)
        AUTO_CAST(mode_text)
        mode_text:SetText("{ol}Mode")

        local mode_check = frame:CreateOrGetControl("checkbox", "mode_check" .. index, 550, y + 25, 20, 20)
        AUTO_CAST(mode_check)
        mode_check:SetTextTooltip("Icon mode when checked")

    end
end

function skill_notice_setting(frame, ctrl, argStr, argNum)
    local setting_frame = ui.CreateNewFrame("notice_on_pc", addonNameLower .. "setting_frame", 0, 0, 200, 400)
    AUTO_CAST(setting_frame)
    setting_frame:SetSkinName("test_frame_midle_light")
    setting_frame:SetPos(200, 300)
    setting_frame:SetLayerLevel(61);
    setting_frame:RemoveAllChild()

    local title_text = setting_frame:CreateOrGetControl("richtext", "title_text", 20, 5, 200, 20)
    AUTO_CAST(title_text)
    title_text:SetText("{ol}Skill Notice Setting")

    local close = setting_frame:CreateOrGetControl("button", "close", 0, 0, 20, 20)
    AUTO_CAST(close)
    close:SetImage("testclose_button")
    close:SetGravity(ui.RIGHT, ui.TOP)
    close:SetEventScript(ui.LBUTTONUP, "skill_notice_newframe_close")

    local buff_table = g.settings["buffs"]
    local y = 50
    local index = 1

    -- 関数なしでスロットと編集ボックスを生成する共通処理をまとめたパターン
    local function create_slot_and_edit(index, y, buff_id)
        -- スロットの生成
        local buff_slot = setting_frame:CreateOrGetControl("slot", "buff_slot" .. index, 10, y, 50, 50)
        AUTO_CAST(buff_slot)
        buff_slot:EnablePop(0)
        buff_slot:EnableDrop(0)
        buff_slot:EnableDrag(0)
        buff_slot:SetSkinName('invenslot2')

        if buff_id then
            local buff_class = GetClassByType("Buff", buff_id)
            local buff_name = buff_class.ClassName
            local image_name = GET_BUFF_ICON_NAME(buff_class)
            SET_SLOT_ICON(buff_slot, image_name)

            local icon = CreateIcon(buff_slot)
            AUTO_CAST(icon)
            icon:SetTooltipType('buff')
            icon:SetTooltipArg(buff_name, buff_id, 0)
            buff_slot:Invalidate()
        end

        -- 編集ボックスの生成
        local buffid_edit = setting_frame:CreateOrGetControl("edit", "buffid_edit" .. index, 10, y - 20, 70, 20)
        AUTO_CAST(buffid_edit)
        buffid_edit:SetFontName("white_16_ol")
        buffid_edit:SetTextAlign("center", "center")

        if buff_id then
            buffid_edit:SetText(buff_id)
        end

        buffid_edit:SetEventScript(ui.ENTERKEY, "skill_notice_buffid_edit")
        buffid_edit:SetEventScriptArgString(ui.ENTERKEY, setting_frame:GetName())
        buffid_edit:SetEventScriptArgNumber(ui.ENTERKEY, index)

        -- 必要に応じてスクリプトを呼び出す
        if buff_id then
            local no_save = true
            skill_notice_buffid_edit(frame, buffid_edit, setting_frame:GetName(), index, no_save)
        end
    end

    -- バフが空の場合
    if next(buff_table) == nil then
        create_slot_and_edit(index, y, nil)
    else
        -- バフがある場合、テーブル内のバフ情報をループ
        for str_buff_id, _ in pairs(buff_table) do
            local buff_id = tonumber(str_buff_id)
            create_slot_and_edit(index, y, buff_id)
            index = index + 1
            y = y + 80
        end
        -- 新しいスロットの生成
        create_slot_and_edit(index, y, nil)
    end

    -- ウィンドウのリサイズと表示
    setting_frame:Resize(580, y + 60)
    setting_frame:ShowWindow(1)
end

function skill_notice_frame_init()

    local frame = ui.GetFrame("skill_notice")
    frame:RemoveAllChild()
    frame:SetSkinName("chat_window")
    frame:SetAlpha(20)
    frame:SetTitleBarSkin("None")
    frame:EnableMove(1)
    frame:EnableHitTest(1)
    frame:SetEventScript(ui.LBUTTONUP, "skill_notice_end_drag")
    frame:SetEventScript(ui.RBUTTONUP, "skill_notice_setting")

    frame:SetPos(g.settings.x, g.settings.y)

    local setting = frame:CreateOrGetControl("button", "setting", 150, 5, 20, 20)
    AUTO_CAST(setting)
    setting:SetSkinName("None");
    setting:SetText("{img config_button_normal 20 20}")
    setting:SetEventScript(ui.LBUTTONUP, "skill_notice_setting")
    setting:SetTextTooltip("Skill Notice{nl}Left-Click Settings")

    local buffgb = frame:CreateOrGetControl('groupbox', "buffgb", 0, 20, 190, 25);
    buffgb:SetSkinName("None");
    buffgb:RemoveAllChild()

    local buff_table = g.settings["buffs"]
    local cid_table = g.settings[tostring(g.cid)]
    local y = 0
    for str_buff_id, _ in pairs(buff_table) do

        if cid_table[str_buff_id] == nil then
            cid_table[str_buff_id] = "YES"
        end

        local buff_id = tonumber(str_buff_id)

        if cid_table[str_buff_id] == "YES" then
            local gauge = buffgb:CreateOrGetControl("gauge", "gauge" .. buff_id, 10, y * 25 + 10, 160, 20);
            AUTO_CAST(gauge)
            local myHandle = session.GetMyHandle()
            local actor = world.GetActor(myHandle)
            local buff = info.GetBuff(myHandle, buff_id)
            local max_charge = buff_table[str_buff_id].max_charge
            local color = buff_table[str_buff_id].color

            gauge:SetSkinName("gauge");
            gauge:SetColorTone(color)
            if buff ~= nil then
                gauge:SetPoint(buff.over, max_charge);
                gauge:AddStat('{ol}{s20}%v/%m');
                gauge:SetStatFont(0, 'quickiconfont');
                gauge:SetStatOffset(0, 20, 0);
                gauge:SetStatAlign(0, ui.CENTER_HORZ, ui.CENTER_VERT);
            else
                gauge:SetPoint(0, max_charge);
                gauge:AddStat('{ol}{s20}%v/%m');
                gauge:SetStatFont(0, 'quickiconfont');
                gauge:SetStatOffset(0, 20, 0);
                gauge:SetStatAlign(0, ui.CENTER_HORZ, ui.CENTER_VERT);
            end

            local buff_text = buffgb:CreateOrGetControl("richtext", "buff_text" .. buff_id, 0, y * 25 + 10, 160, 20)
            AUTO_CAST(buff_text)
            buff_text:SetText("{ol}{s12}" .. GetClassByType("Buff", tonumber(str_buff_id)).Name)

            y = y + 1
        end

    end
    skill_notice_save_settings()

    buffgb:Resize(180, y * 25 + 30)
    frame:Resize(180, y * 25 + 30)
    frame:ShowWindow(1)

end

function skill_notice_buff_remove(frame, msg, str, buff_type)
    local frame = ui.GetFrame("skill_notice")
    local myHandle = session.GetMyHandle()
    local actor = world.GetActor(myHandle)

    local buff_table = g.settings["buffs"]
    local cid_table = g.settings[tostring(g.cid)]

    for str_buff_id, _ in pairs(buff_table) do
        if tostring(buff_type) == str_buff_id and cid_table[str_buff_id] == "YES" then
            local buff_id = tonumber(str_buff_id)
            local effect = buff_table[str_buff_id].effect
            local max_charge = buff_table[str_buff_id].max_charge

            local gauge = GET_CHILD_RECURSIVELY(frame, "gauge" .. buff_id)
            AUTO_CAST(gauge)
            gauge:RemoveAllChild()
            gauge:SetPoint(0, max_charge);
            gauge:SetStatFont(0, 'quickiconfont');
            gauge:SetStatAlign(0, ui.CENTER_HORZ, ui.CENTER_VERT);
            gauge:EnableHitTest(0)

            gauge:SetColorTone(buff_table[str_buff_id].color);

            if effect ~= "None" then
                effect.DetachActorEffect(actor, buff_table[str_buff_id].effect, 0)
            end
            g.buffs[str_buff_id] = nil
        end
    end
end

function skill_notice_buff_add(frame, msg, str, buff_type)
    local frame = ui.GetFrame("skill_notice")
    local myHandle = session.GetMyHandle()
    local actor = world.GetActor(myHandle)

    local buff_table = g.settings["buffs"]
    local cid_table = g.settings[tostring(g.cid)]

    for str_buff_id, _ in pairs(buff_table) do
        if tostring(buff_type) == str_buff_id and cid_table[str_buff_id] == "YES" then
            local buff_id = tonumber(str_buff_id)
            local max_charge = buff_table[str_buff_id].max_charge
            local buff_class = info.GetBuff(myHandle, buff_id)

            if buff_class ~= nil then
                local gauge = GET_CHILD_RECURSIVELY(frame, "gauge" .. buff_id)
                AUTO_CAST(gauge)
                gauge:RemoveAllChild()
                gauge:SetPoint(buff_class.over, max_charge)
                gauge:SetStatFont(0, 'quickiconfont');
                gauge:SetStatAlign(0, ui.CENTER_HORZ, ui.CENTER_VERT);
                gauge:EnableHitTest(0)

                g.buffs[str_buff_id] = false
            end

        end
    end

end

function skill_notice_buff_update(frame, msg, str, buff_type)

    local frame = ui.GetFrame("skill_notice")
    local myHandle = session.GetMyHandle()
    local actor = world.GetActor(myHandle)

    local buff_table = g.settings["buffs"]
    local cid_table = g.settings[tostring(g.cid)]

    for str_buff_id, _ in pairs(buff_table) do
        if tostring(buff_type) == str_buff_id and cid_table[str_buff_id] == "YES" then
            local buff_id = tonumber(str_buff_id)
            local max_charge = buff_table[str_buff_id].max_charge
            local buff_class = info.GetBuff(myHandle, buff_id)

            if buff_class ~= nil then
                local gauge = GET_CHILD_RECURSIVELY(frame, "gauge" .. buff_id)
                AUTO_CAST(gauge)
                gauge:RemoveAllChild()
                gauge:SetPoint(buff_class.over, max_charge)
                gauge:SetStatFont(0, 'quickiconfont');
                gauge:SetStatAlign(0, ui.CENTER_HORZ, ui.CENTER_VERT);
                gauge:EnableHitTest(0)

                if buff_class.over == max_charge and not g.buffs[buff_id] then
                    local effect = buff_table[str_buff_id].effect
                    local size = buff_table[str_buff_id].size
                    effect.AddActorEffectByOffset(actor, effect, size, "MID", true, true)

                    local sound = buff_table[str_buff_id].sound
                    if sound ~= "None" then
                        imcSound.PlaySoundEvent(sound)
                    end
                    gauge:SetColorTone("FFFF0000")
                    g.buffs[str_buff_id] = true
                end
            end

        end
    end

end

function skill_notice_end_drag(frame, ctrl, str, num)

    if frame:GetName() == "skill_notice" then
        g.settings.x = frame:GetX()
        g.settings.y = frame:GetY()
    end
    skill_notice_save_settings()
end

function skill_notice_new_buff_frame()

    local noticeframe = ui.CreateNewFrame("chat_memberlist", "notice_frame", 0, 0, 10, 10)
    AUTO_CAST(noticeframe)

    local LoginName = session.GetMySession():GetPCApc():GetName()

    if g.settings[LoginName].new_check.use == 0 then
        noticeframe:ShowWindow(0)
        return 0
    else
        noticeframe:ShowWindow(1)
    end

    noticeframe:SetSkinName("chat_window")
    noticeframe:SetTitleBarSkin("None")
    noticeframe:SetAlpha(30)
    noticeframe:SetLayerLevel(61)
    noticeframe:EnableHitTest(1)
    noticeframe:EnableMove(1)

    noticeframe:SetPos(g.settings.new_x, g.settings.new_y)
    noticeframe:RemoveAllChild()
    noticeframe:SetEventScript(ui.LBUTTONUP, "skill_notice_end_drag")

    local slotset = noticeframe:CreateOrGetControl("slotset", "slotset", 0, 10, 0, 0)
    AUTO_CAST(slotset)

    local bufftable = {2461}

    local cnt = #bufftable

    slotset:ClearIconAll()
    slotset:SetMaxSelectionCount(1)
    slotset:SetSlotSize(50, 50)
    slotset:SetSkinName("None")
    slotset:SetColRow(1, 1)
    slotset:CreateSlots()

    local slot = GET_CHILD(slotset, "slot1")
    AUTO_CAST(slot)

    local buff = GetClassByType("Buff", bufftable[1])
    local imageName = GET_BUFF_ICON_NAME(buff)
    SET_SLOT_ICON(slot, imageName)

    local frame = ui.GetFrame("buff_visibility")
    local Violent_stack_value = GET_CHILD_RECURSIVELY(frame, "Violent_stack_value")
    if Violent_stack_value ~= nil then
        local value = string.gsub(Violent_stack_value:GetText(), "{@st41b}{s14}", "")
        local count = slot:CreateOrGetControl("richtext", "count", 12, 0, 40, 40)
        AUTO_CAST(count)
        count:SetText("{ol}{s40}" .. value)
    else
        local count = slot:CreateOrGetControl("richtext", "count", 12, 0, 40, 40)
        AUTO_CAST(count)
        count:SetText("{ol}{s40}0")
    end

    noticeframe:Resize(cnt * 50 + 10, 60)
    noticeframe:ShowWindow(1)

    return 1

end

function skill_notice_ischeck(frame, ctrl, argStr, argNum)
    local ischeck = ctrl:IsChecked()
    local ctrlname = ctrl:GetName()
    local LoginName = session.GetMySession():GetPCApc():GetName()

    if ctrlname == "new_check" then
        g.settings[LoginName].new_check.use = ischeck
        if ischeck == 1 then
            skill_notice_new_buff_frame()

        end
    else
        g.settings[LoginName][argStr] = ischeck
        -- print(tostring(ctrlname) .. ":" .. tostring(ischeck))

    end
    skill_notice_save_settings()
    skill_notice_frame_init(frame)
end

function skill_notice_effect_size(frame, ctrl, argStr, argNum)

    local size = tonumber(ctrl:GetText())
    if size == nil then
        ui.SysMsg("The entered text is not numeric.{nl}入力された文字が数値ではないです。")
        return
    end

    if argStr == "Pyktis" then

        g.settings.pyktis.size = size

    elseif argStr == "Battle Spirit 8" then
        g.settings.battlespirit8.size = size

    elseif argStr == "Battle Spirit 10" then
        g.settings.battlespirit10.size = size

    elseif argStr == "Charge Arrow" then
        g.settings.chargearrow.size = size

    elseif argStr == "Reload" then
        g.settings.reload.size = size

    end
    skill_notice_save_settings()
    ReserveScript(string.format("skill_notice_effect_test_size('%s',%d)", argStr, size), 0.1)

end

function skill_notice_effect_test_size(argStr, size)
    local myHandle = session.GetMyHandle();
    local actor = world.GetActor(myHandle)
    local effectName
    local sound
    if argStr == "Pyktis" then

        effectName = g.settings.pyktis.effect
        sound = g.settings.pyktis.sound
    elseif argStr == "Battle Spirit 8" then
        effectName = g.settings.battlespirit8.effect
        sound = g.settings.battlespirit8.sound
    elseif argStr == "Battle Spirit 10" then
        effectName = g.settings.battlespirit10.effect
        sound = g.settings.battlespirit10.sound
    elseif argStr == "Charge Arrow" then
        effectName = g.settings.chargearrow.effect
        sound = g.settings.chargearrow.sound
    elseif argStr == "Reload" then
        effectName = g.settings.reload.effect
        sound = g.settings.reload.sound
    end

    effect.AddActorEffectByOffset(actor, effectName, size, "MID", true, true);
    effect.DetachActorEffect(actor, effectName, 5.0);
    if sound ~= "None" then
        imcSound.PlaySoundEvent(sound);
    end

end

-- local myHandle = session.GetMyHandle();
-- local actor = world.GetActor(myHandle)
-- local effectName = "F_pattern025_loop"
-- local effectName = "F_buff_Cleric_Haste_Buff"
-- local effectName = "F_ground013"
-- local effectName = "F_archer_SiegeBurst_explosion2"
-- local effectName = "F_spread_in044_ghost2_fast"
-- local effectName = "F_spread_in002_violet"
-- local effectName = "F_fire038_loop"
-- local effectName = "F_spin008"

-- effect.DetachActorEffect(actor, effectName, 0);
-- effect.AddActorEffectByOffset(actor, effectName, 3.0, "MID", true, true);

function skill_notice_newframe_close(frame, ctrl, argStr, argNum)
    frame:ShowWindow(0)
end

