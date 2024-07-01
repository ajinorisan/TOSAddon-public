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

g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)

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
local colortbl = {
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

local handlelist = {
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
    -- "sys_alarm_fullcharge",
    -- "sys_card_battle_roulette_turn",
    -- "sys_class_change",
    -- "button_v_click",
}
local effectlist = {
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

function skill_notice_load_settings()

    local settings, err = acutil.loadJSON(g.settingsFileLoc, g.settings)
    if err then
        -- 設定ファイル読み込み失敗時処理
        CHAT_SYSTEM(string.format("[%s] cannot load setting files", addonNameLower))
    end
    if not settings then

        settings = {
            x = 400,
            y = 400,
            pyktis = {
                sound = "None",
                color = "FFFFFF00",
                effect = "None",
                size = 2

            },
            battlespirit8 = {
                sound = "None",
                color = "FFFFFF00",
                effect = "None",
                size = 2

            },
            battlespirit10 = {
                sound = "None",
                color = "FFFFFF00",
                effect = "None",
                size = 2

            },
            chargearrow = {
                sound = "None",
                color = "FFFFFF00",
                effect = "None",
                size = 2

            },
            reload = {
                sound = "None",
                color = "FFFFFF00",
                effect = "None",
                size = 2

            }
        }

        skill_notice_save_settings()

    end

    g.settings = settings

    if g.settings.new_x == nil then
        g.settings.new_x = 1000

    end

    if g.settings.new_y == nil then
        g.settings.new_y = 500
    end

    local LoginName = session.GetMySession():GetPCApc():GetName()
    if g.settings[LoginName] == nil then
        g.settings[LoginName] = {}
    end

    if g.settings[LoginName].new_check == nil then
        g.settings[LoginName].new_check = {
            use = 1
        }

    end
    skill_notice_save_settings()
end

function skill_notice_save_settings()
    acutil.saveJSON(g.settingsFileLoc, g.settings)
end

function SKILL_NOTICE_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame

    skill_notice_load_settings()
    addon:RegisterMsg('BUFF_UPDATE', 'skill_notice_buff_update');
    addon:RegisterMsg('BUFF_ADD', 'skill_notice_buff_add');
    addon:RegisterMsg('BUFF_REMOVE', 'skill_notice_buff_remove');
    addon:RegisterMsg('GAME_START', "skill_notice_frame_init")

    g.pyktismax = 0
    g.battlespirit8max = 0
    g.battlespirit10max = 0
    g.chargearrow = 0
    g.reload = 0
end
function skill_notice_buff_remove(frame, msg, argStr, argNum)
    local frame = ui.GetFrame("skill_notice")
    local myHandle = session.GetMyHandle()
    local actor = world.GetActor(myHandle)
    local bufftype = argNum

    for index, buffData in ipairs(bufftbl) do
        if tostring(bufftype) == tostring(buffData.id) then
            local text = buffData.text
            local max = buffData.max

            local gauge = GET_CHILD_RECURSIVELY(frame, "gauge" .. buffData.name)
            AUTO_CAST(gauge)
            gauge:RemoveAllChild()
            gauge:SetPoint(0, max);
            -- gauge:AddStat("");
            -- gauge:AddStat('{ol}{s20}%v/%m');
            gauge:SetStatFont(0, 'quickiconfont');
            gauge:SetStatAlign(0, ui.CENTER_HORZ, ui.CENTER_VERT);
            gauge:EnableHitTest(0)

            -- pyktis
            if bufftype == 1158 then
                if g.settings.pyktis.effect ~= "None" then
                    effect.DetachActorEffect(actor, g.settings.pyktis.effect, 0);
                end
                gauge:SetColorTone(g.settings.pyktis.color);
                g.pyktismax = 0
            elseif bufftype == 1164 then
                if g.settings.chargearrow.effect ~= "None" then
                    effect.DetachActorEffect(actor, g.settings.chargearrow.effect, 0);
                end
                gauge:SetColorTone(g.settings.chargearrow.color);
                g.chargearrow = 0
            elseif bufftype == 1112 then
                if g.settings.reload.effect ~= "None" then
                    effect.DetachActorEffect(actor, g.settings.reload.effect, 0);
                end
                gauge:SetColorTone(g.settings.reload.color);
                g.reload = 0
            elseif bufftype == 1163 then
                if g.settings.battlespirit8.effect ~= "None" then
                    effect.DetachActorEffect(actor, g.settings.battlespirit8.effect, 0);
                end
                if g.settings.battlespirit10.effect ~= "None" then
                    effect.DetachActorEffect(actor, g.settings.battlespirit10.effect, 0);
                end
                gauge:SetColorTone(g.settings.battlespirit10.color);
                g.battlespirit10max = 0
            end

        end
    end
end
function skill_notice_buff_add(frame, msg, argStr, argNum)
    local frame = ui.GetFrame("skill_notice")
    local myHandle = session.GetMyHandle()
    local actor = world.GetActor(myHandle)
    local bufftype = argNum

    for index, buffData in ipairs(bufftbl) do
        if tostring(bufftype) == tostring(buffData.id) then
            local text = buffData.text
            local max = buffData.max
            local buff = info.GetBuff(myHandle, buffData.id);

            if buff ~= nil then
                local gauge = GET_CHILD_RECURSIVELY(frame, "gauge" .. buffData.name)
                AUTO_CAST(gauge)
                gauge:RemoveAllChild()
                gauge:SetPoint(buff.over, max);
                -- gauge:AddStat("");
                -- gauge:AddStat('{ol}{s20}%v/%m');
                gauge:SetStatFont(0, 'quickiconfont');
                gauge:SetStatAlign(0, ui.CENTER_HORZ, ui.CENTER_VERT);
                gauge:EnableHitTest(0)

            end

        end
    end
end
function skill_notice_buff_update(frame, msg, argStr, argNum)

    local frame = ui.GetFrame("skill_notice")
    local myHandle = session.GetMyHandle()
    local actor = world.GetActor(myHandle)
    local bufftype = argNum

    for index, buffData in ipairs(bufftbl) do
        if tostring(bufftype) == tostring(buffData.id) then
            local text = buffData.text
            local max = buffData.max
            local buff = info.GetBuff(myHandle, buffData.id);

            if buff ~= nil then
                local gauge = GET_CHILD_RECURSIVELY(frame, "gauge" .. buffData.name)
                AUTO_CAST(gauge)
                gauge:RemoveAllChild()
                gauge:SetPoint(buff.over, max);
                -- gauge:AddStat("");
                -- gauge:AddStat('{ol}{s20}%v/%m');
                gauge:SetStatFont(0, 'quickiconfont');
                gauge:SetStatAlign(0, ui.CENTER_HORZ, ui.CENTER_VERT);
                gauge:EnableHitTest(0)

                -- pyktis
                if bufftype == 1158 and buff.over == buffData.max and g.pyktismax == 0 then
                    if g.settings.pyktis.effect ~= "None" then
                        -- effect.DetachActorEffect(actor, g.settings.pyktis.effect, 0);
                        effect.AddActorEffectByOffset(actor, g.settings.pyktis.effect, g.settings.pyktis.size, "MID",
                            true, true);
                    end
                    if g.settings.pyktis.sound ~= "None" then
                        imcSound.PlaySoundEvent(g.settings.pyktis.sound);
                    end
                    gauge:SetColorTone("FFFF0000");
                    g.pyktismax = 1
                    --[[elseif bufftype == 1158 and buff.over == buffData.max then
                    if g.settings.pyktis.effect ~= "None" then
                        effect.DetachActorEffect(actor, g.settings.pyktis.effect, 0);
                        effect.AddActorEffectByOffset(actor, g.settings.pyktis.effect, g.settings.pyktis.size, "MID",
                            true, true);
                    end
                    gauge:SetColorTone("FFFF0000");]]
                elseif bufftype == 1158 and buff.over ~= buffData.max then
                    if g.settings.pyktis.effect ~= "None" then
                        effect.DetachActorEffect(actor, g.settings.pyktis.effect, 0);
                    end
                    gauge:SetColorTone(g.settings.pyktis.color);
                    g.pyktismax = 0
                end

                -- chargearrow
                if bufftype == 1164 and buff.over == buffData.max and g.chargearrow == 0 then
                    if g.settings.chargearrow.effect ~= "None" then

                        effect.AddActorEffectByOffset(actor, g.settings.chargearrow.effect, g.settings.chargearrow.size,
                            "MID", true, true);
                    end
                    if g.settings.chargearrow.sound ~= "None" then
                        imcSound.PlaySoundEvent(g.settings.chargearrow.sound);
                    end
                    gauge:SetColorTone("FFFF0000");
                    g.chargearrow = 1
                    --[[elseif bufftype == 1164 and buff.over == buffData.max then
                    if g.settings.chargearrow.effect ~= "None" then
                        effect.AddActorEffectByOffset(actor, g.settings.chargearrow.effect, g.settings.chargearrow.size,
                            "MID", true, true);
                    end
                    gauge:SetColorTone("FFFF0000");]]
                elseif bufftype == 1164 and buff.over ~= buffData.max then
                    if g.settings.chargearrow.effect ~= "None" then
                        effect.DetachActorEffect(actor, g.settings.chargearrow.effect, 0);
                    end

                    gauge:SetColorTone(g.settings.chargearrow.color);
                    g.chargearrow = 0
                end

                -- reload
                if bufftype == 1112 and buff.over == buffData.max and g.reload == 0 then
                    if (IsBattleState(GetMyPCObject()) == 1) then
                        if g.settings.reload.effect ~= "None" then

                            effect.AddActorEffectByOffset(actor, g.settings.reload.effect, g.settings.reload.size,
                                "MID", true, true);
                        end
                        if g.settings.reload.sound ~= "None" then
                            imcSound.PlaySoundEvent(g.settings.reload.sound);
                        end
                    end
                    gauge:SetColorTone("FFFF0000");
                    g.reload = 1
                    --[[elseif bufftype == 1112 and buff.over == buffData.max then
                    if (IsBattleState(GetMyPCObject()) == 1) then
                        if g.settings.reload.effect ~= "None" then
                           
                            effect.AddActorEffectByOffset(actor, g.settings.reload.effect, g.settings.reload.size,
                                "MID", true, true);
                        end
                    end
                    gauge:SetColorTone("FFFF0000");]]
                elseif bufftype == 1112 and buff.over ~= buffData.max then
                    if g.settings.reload.effect ~= "None" then
                        effect.DetachActorEffect(actor, g.settings.reload.effect, 0);
                    end
                    gauge:SetColorTone(g.settings.reload.color);
                    g.reload = 0
                end

                -- battlespirit
                if bufftype == 1163 and buff.over == 8 then
                    if g.settings.battlespirit8.effect ~= "None" then
                        effect.AddActorEffectByOffset(actor, g.settings.battlespirit8.effect,
                            g.settings.battlespirit8.size, "MID", true, true);
                    end
                    if g.settings.battlespirit8.sound ~= "None" then
                        imcSound.PlaySoundEvent(g.settings.battlespirit8.sound);
                    end
                elseif bufftype == 1163 and buff.over == 10 and g.battlespirit10max == 0 then
                    if g.settings.battlespirit8.effect ~= "None" then
                        effect.DetachActorEffect(actor, g.settings.battlespirit8.effect, 0);
                    end
                    if g.settings.battlespirit10.effect ~= "None" then
                        effect.AddActorEffectByOffset(actor, g.settings.battlespirit10.effect,
                            g.settings.battlespirit10.size, "MID", true, true);
                    end
                    if g.settings.battlespirit10.sound ~= "None" then
                        imcSound.PlaySoundEvent(g.settings.battlespirit10.sound);
                    end
                    gauge:SetColorTone("FFFF0000");
                    g.battlespirit10max = 1

                elseif bufftype == 1163 and buff.over < 8 then
                    if g.settings.battlespirit8.effect ~= "None" then
                        effect.DetachActorEffect(actor, g.settings.battlespirit8.effect, 0);
                    end
                    if g.settings.battlespirit10.effect ~= "None" then
                        effect.DetachActorEffect(actor, g.settings.battlespirit10.effect, 0);
                    end
                    gauge:SetColorTone(g.settings.battlespirit10.color);

                end

            end

        end
    end
end

function skill_notice_frame_init(frame)

    local frame = ui.GetFrame("skill_notice")
    frame:RemoveAllChild()
    frame:SetSkinName("chat_window");
    frame:SetAlpha(20);
    frame:SetTitleBarSkin("None")
    frame:EnableMove(1);
    frame:EnableHitTest(1)

    frame:Resize(200, 400);
    frame:SetEventScript(ui.LBUTTONUP, "skill_notice_end_drag")
    frame:SetEventScript(ui.RBUTTONUP, "skill_notice_setting")

    frame:SetPos(g.settings.x, g.settings.y)

    local setting = frame:CreateOrGetControl("button", "setting", 150, 5, 20, 20)
    AUTO_CAST(setting)
    setting:SetSkinName("None");
    setting:SetText("{img config_button_normal 20 20}")
    setting:SetEventScript(ui.LBUTTONUP, "skill_notice_setting")
    setting:SetTextTooltip("Skill Notice{nl}Left-Click Settings")

    -- local text = frame:CreateOrGetControl("richtext", "text", 0, 5, 250, 15)
    -- AUTO_CAST(text)
    -- text:SetText("{ol}{s12}Skill Notice")
    -- text:SetEventScript(ui.RBUTTONUP, "skill_notice_setting")
    -- text:SetTextTooltip("Right-Click Settings")

    local buffgb = frame:CreateOrGetControl('groupbox', "buffgb", 0, 20, 190, 25);
    buffgb:SetSkinName("None");
    buffgb:RemoveAllChild()

    local LoginName = session.GetMySession():GetPCApc():GetName()
    local y = 0
    local colortone = ""
    local max = 0
    for index, buffData in ipairs(bufftbl) do

        if g.settings[LoginName][buffData.name] == nil then
            g.settings[LoginName][buffData.name] = 1
            skill_notice_save_settings()
        end

        if index ~= 2 then
            if g.settings[LoginName][buffData.name] == 1 then
                local gauge = buffgb:CreateOrGetControl("gauge", "gauge" .. buffData.name, 10, y * 25 + 10, 160, 20);
                AUTO_CAST(gauge)

                if buffData.text == "Pyktis" then
                    colortone = g.settings.pyktis.color
                    max = 30
                elseif buffData.text == "Battle Spirit 10" then
                    colortone = g.settings.battlespirit10.color
                    max = 10
                elseif buffData.text == "Charge Arrow" then
                    colortone = g.settings.chargearrow.color
                    max = 5
                elseif buffData.text == "Reload" then
                    colortone = g.settings.reload.color
                    max = 10
                end

                local myHandle = session.GetMyHandle()
                local actor = world.GetActor(myHandle)
                local buff = info.GetBuff(myHandle, buffData.id)

                gauge:SetSkinName("gauge");
                gauge:SetColorTone(colortone);
                if buff ~= nil then
                    gauge:SetPoint(buff.over, max);
                    gauge:AddStat('{ol}{s20}%v/%m');
                    gauge:SetStatFont(0, 'quickiconfont');
                    gauge:SetStatOffset(0, 20, 0);
                    gauge:SetStatAlign(0, ui.CENTER_HORZ, ui.CENTER_VERT);
                else
                    gauge:SetPoint(0, max);
                    gauge:AddStat('{ol}{s20}%v/%m');
                    gauge:SetStatFont(0, 'quickiconfont');
                    gauge:SetStatOffset(0, 20, 0);
                    gauge:SetStatAlign(0, ui.CENTER_HORZ, ui.CENTER_VERT);
                end

                local bufftext = buffgb:CreateOrGetControl("richtext", "bufftext" .. buffData.name, 0, y * 25 + 10, 160,
                    20)
                AUTO_CAST(bufftext)

                if buffData.name == "Thunder_Charge_Buff" then
                    bufftext:SetText("{ol}{s12}" .. buffData.text)
                elseif buffData.name == "BattleSpirit_Buff" then
                    bufftext:SetText("{ol}{s12}Battle Spirit")
                elseif buffData.name == "ChargeArrow_Buff" then
                    bufftext:SetText("{ol}{s12}" .. buffData.text)
                elseif buffData.name == "Reload_Buff" then
                    bufftext:SetText("{ol}{s12}" .. buffData.text)
                end

                y = y + 1
            end
        end
    end

    buffgb:Resize(180, y * 25 + 30)
    frame:Resize(180, y * 25 + 30)
    frame:ShowWindow(1);

    local LoginName = session.GetMySession():GetPCApc():GetName()
    if g.settings[LoginName].new_check.use == 1 then
        frame:RunUpdateScript("skill_notice_new_buff_frame", 0.1);

    end

end

function skill_notice_end_drag(frame, ctrl, argStr, argNum)

    if frame:GetName() == "notice_frame" then
        g.settings.new_x = frame:GetX();
        g.settings.new_y = frame:GetY();
    else
        local frame = ui.GetFrame("skill_notice")

        g.settings.x = frame:GetX();
        g.settings.y = frame:GetY();
    end
    skill_notice_save_settings()
end

function skill_notice_setting(frame, ctrl, argStr, argNum)
    local newframe = ui.CreateNewFrame("notice_on_pc", addonNameLower .. "_new", 0, 0, 200, 400)
    AUTO_CAST(newframe)
    newframe:SetSkinName("test_frame_midle_light")
    newframe:SetPos(200, 300)
    newframe:SetLayerLevel(61);
    newframe:Resize(540, 440)
    newframe:RemoveAllChild()

    local text = newframe:CreateOrGetControl("richtext", "text", 20, 5, 200, 20)
    AUTO_CAST(text)
    text:SetText("{ol}Skill Notice Setting")

    local new_check = newframe:CreateOrGetControl("checkbox", "new_check", 480, 10, 20, 20)
    AUTO_CAST(new_check)
    new_check:SetTextTooltip("Check to new buff frame display{nl}Settings for each character")

    local LoginName = session.GetMySession():GetPCApc():GetName()

    if g.settings[LoginName].new_check == nil then
        g.settings[LoginName].new_check = {
            use = 1
        }
        skill_notice_save_settings()
    end
    new_check:SetCheck(g.settings[LoginName].new_check.use)
    new_check:SetEventScript(ui.LBUTTONUP, "skill_notice_ischeck")

    local new_display = newframe:CreateOrGetControl("richtext", "new_display", 210, 10, 200, 20)
    AUTO_CAST(new_display)
    new_display:SetText("{ol}Toggle display of new buff frame")

    local close = newframe:CreateOrGetControl("button", "close", 0, 0, 20, 20)
    AUTO_CAST(close)
    close:SetImage("testclose_button")
    close:SetGravity(ui.RIGHT, ui.TOP)
    close:SetEventScript(ui.LBUTTONUP, "skill_notice_newframe_close")
    newframe:ShowWindow(1)

    -- カラー、エフェクト、サウンド、サイズ、名前、表示非表示
    local y = 50
    for index, buffData in ipairs(bufftbl) do
        -- print("Index: " .. index)
        local buffName = newframe:CreateOrGetControl("richtext", "buffName" .. index, 10, y - 20, 200, 20)
        AUTO_CAST(buffName)
        buffName:SetText("{ol}" .. buffData.text)

        local sound = newframe:CreateOrGetControl("richtext", "sound" .. index, 70, y, 200, 20)
        AUTO_CAST(sound)
        sound:SetText("{ol}Sound Config")

        local soundconfig = newframe:CreateOrGetControl("button", "soundconfig" .. index, 180, y, 25, 25)
        AUTO_CAST(soundconfig)
        soundconfig:SetSkinName("None")
        soundconfig:SetText("{img config_button_normal 25 25}")
        soundconfig:SetEventScript(ui.LBUTTONUP, "skill_notice_sound_select")
        soundconfig:SetEventScriptArgString(ui.LBUTTONUP, buffData.text)

        if buffData.text ~= "Battle Spirit 8" then
            local gaugecolor = newframe:CreateOrGetControl("richtext", "gaugecolor" .. index, 220, y, 200, 20)
            AUTO_CAST(gaugecolor)
            gaugecolor:SetText("{ol}Gauge Color")

            local colorbox = newframe:CreateOrGetControl('groupbox', "colorbox" .. index, 320, y, 220, 20);
            AUTO_CAST(colorbox)
            for i = 0, 9 do
                local colorCls = colortbl[i + 1]
                -- print(tostring(colorCls))
                if colorCls ~= nil then
                    local color =
                        colorbox:CreateOrGetControl("picture", "color" .. index .. "_" .. i, 20 * i, 0, 20, 20);
                    AUTO_CAST(color)
                    color:SetImage("chat_color");
                    color:SetColorTone("FF" .. colorCls)
                    color:SetEventScript(ui.LBUTTONUP, "skill_notice_color_select")
                    color:SetEventScriptArgString(ui.LBUTTONUP, buffData.text .. "/" .. "FF" .. colorCls)
                    color:SetEventScriptArgNumber(ui.LBUTTONUP, buffData.id)

                end
            end
        end
        local effect = newframe:CreateOrGetControl("richtext", "effect" .. index, 70, y + 30, 200, 20)
        AUTO_CAST(effect)
        effect:SetText("{ol}Effect Config")

        local effectconfig = newframe:CreateOrGetControl("button", "effectconfig" .. index, 180, y + 30, 25, 25)
        AUTO_CAST(effectconfig)
        effectconfig:SetSkinName("None")
        effectconfig:SetText("{img config_button_normal 25 25}")
        effectconfig:SetEventScript(ui.LBUTTONUP, "skill_notice_effect_select")
        effectconfig:SetEventScriptArgString(ui.LBUTTONUP, buffData.text)

        local effectsize = newframe:CreateOrGetControl("richtext", "effectsize" .. index, 220, y + 30, 200, 20)
        AUTO_CAST(effectsize)
        effectsize:SetText("{ol}Effect Size")

        local effectedit = newframe:CreateOrGetControl("edit", "effectedit" .. index, 310, y + 30, 50, 20)
        AUTO_CAST(effectedit)
        effectedit:SetFontName("white_16_ol")
        effectedit:SetTextAlign("center", "center")

        if buffData.text == "Pyktis" then
            effectedit:SetText("{ol}" .. g.settings.pyktis.size)

        elseif buffData.text == "Battle Spirit 8" then
            effectedit:SetText("{ol}" .. g.settings.battlespirit8.size)

        elseif buffData.text == "Battle Spirit 10" then
            effectedit:SetText("{ol}" .. g.settings.battlespirit10.size)

        elseif buffData.text == "Charge Arrow" then
            effectedit:SetText("{ol}" .. g.settings.chargearrow.size)

        elseif buffData.text == "Reload" then
            effectedit:SetText("{ol}" .. g.settings.reload.size)
        end

        effectedit:SetEventScript(ui.ENTERKEY, "skill_notice_effect_size")
        effectedit:SetEventScriptArgString(ui.ENTERKEY, buffData.text)

        if buffData.text ~= "Battle Spirit 8" then
            local display = newframe:CreateOrGetControl("richtext", "display" .. index, 370, y + 30, 200, 20)
            AUTO_CAST(display)
            display:SetText("{ol}display or hide")

            local displaycheck = newframe:CreateOrGetControl("checkbox", "displaycheck" .. index, 500, y + 30, 200, 20)
            AUTO_CAST(displaycheck)
            displaycheck:SetTextTooltip("Check to display{nl}Settings for each character")
            local LoginName = session.GetMySession():GetPCApc():GetName()
            displaycheck:SetCheck(g.settings[LoginName][buffData.name])

            displaycheck:SetEventScript(ui.LBUTTONUP, "skill_notice_ischeck")
            displaycheck:SetEventScriptArgString(ui.LBUTTONUP, buffData.name)
        end

        local slot = newframe:CreateOrGetControl("slot", "slot" .. index, 10, y, 50, 50)
        AUTO_CAST(slot)
        slot:EnablePop(0)
        slot:EnableDrop(0)
        slot:EnableDrag(0)
        slot:SetSkinName('invenslot2');
        local buff = GetClassByType("Buff", buffData.id);
        local imageName = GET_BUFF_ICON_NAME(buff);
        SET_SLOT_ICON(slot, imageName)

        local icon = CreateIcon(slot)
        AUTO_CAST(icon)
        icon:SetTooltipType('buff');
        icon:SetTooltipArg(buff.Name, buffData.id, 0);

        slot:Invalidate();

        y = y + 80
    end
    skill_notice_frame_init(frame)
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
    local skilltable = {51712} -- 51712:ロシアンルーレット

    local cnt = #bufftable + #skilltable

    slotset:ClearIconAll()
    slotset:SetMaxSelectionCount(1)
    slotset:SetSlotSize(50, 50)
    slotset:SetSkinName("None")
    slotset:SetColRow(2, 1)
    slotset:CreateSlots()

    local skill1 = GetClassByType("Skill", skilltable[1])
    local slot2 = GET_CHILD(slotset, "slot2")
    AUTO_CAST(slot2)
    local iconname = TryGetProp(skill1, "Icon", "None")
    local icon = CreateIcon(slot2);
    AUTO_CAST(icon)
    iconname = "icon_" .. iconname
    SET_SLOT_ICON(slot2, iconname)

    local totalTime = 0;
    local curTime = 0;
    local skl = session.GetSkill(skilltable[1]);
    if skl ~= nil then
        curTime = skl:GetCurrentCoolDownTime();
        totalTime = skl:GetTotalCoolDownTime();
    end
    local gauge = slot2:CreateOrGetControl("gauge", "gauge", 0, 0, 50, 50)
    AUTO_CAST(gauge)
    gauge:SetSkinName("dot_skillslot")
    gauge:SetPoint(curTime / 1000);
    gauge:AddStat(string.format('{ol}{s25}%.1f', curTime / 1000))
    gauge:SetStatFont(0, 'quickiconfont');
    gauge:SetStatOffset(0, 0, 0);
    gauge:SetStatAlign(0, ui.CENTER_HORZ, ui.CENTER_VERT);
    if curTime == 0 then
        icon:SetColorTone("FFFFFFFF")
        gauge:SetStatOffset(0, 50, 0)
    else

        icon:SetColorTone("FF111111")
    end

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

function skill_notice_effect_select(frame, ctrl, argStr, argNum)

    local context = ui.CreateContextMenu("SOUND_SETTING", "Effect Setting", 300, 0, 100, 100)

    for i, effect in ipairs(effectlist) do

        local scp = string.format("skill_notice_effect_setting('%s','%s')", argStr, effect)
        ui.AddContextMenuItem(context, effect, scp)
    end

    ui.OpenContextMenu(context)
end

function skill_notice_effect_setting(argStr, effect)

    local effectName = tostring(effect)
    local size = 0
    local sound

    if argStr == "Pyktis" then

        g.settings.pyktis.effect = effect
        size = g.settings.pyktis.size
        sound = g.settings.pyktis.sound

    elseif argStr == "Battle Spirit 8" then
        g.settings.battlespirit8.effect = effect
        size = g.settings.battlespirit8.size
        sound = g.settings.battlespirit8.sound

    elseif argStr == "Battle Spirit 10" then
        g.settings.battlespirit10.effect = effect
        size = g.settings.battlespirit10.size
        sound = g.settings.battlespirit10.sound

    elseif argStr == "Charge Arrow" then
        g.settings.chargearrow.effect = effect
        size = g.settings.chargearrow.size
        sound = g.settings.chargearrow.sound

    elseif argStr == "Reload" then
        g.settings.reload.effect = effect
        size = g.settings.reload.size
        sound = g.settings.reload.sound

    end
    skill_notice_save_settings()
    ReserveScript(string.format("skill_notice_effect_test('%s','%s',%d)", effectName, sound, size), 0.1)

end

function skill_notice_effect_test(effectName, sound, size)

    local myHandle = session.GetMyHandle();
    local actor = world.GetActor(myHandle)

    effect.AddActorEffectByOffset(actor, effectName, tonumber(size), "MID", true, true);
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

function skill_notice_color_select(frame, ctrl, argStr, argNum)
    local split = SCR_STRING_CUT(argStr, '/')
    local front = split[1]
    local back = split[2]
    local buffid = argNum
    skill_notice_color_test_gauge(front, back, buffid)

    if front == "Pyktis" then
        g.settings.pyktis.color = back
    elseif front == "Battle Spirit 8" then
        g.settings.battlespirit8.color = back
    elseif front == "Battle Spirit 10" then
        g.settings.battlespirit10.color = back
    elseif front == "Charge Arrow" then
        g.settings.chargearrow.color = back
    elseif front == "Reload" then
        g.settings.reload.color = back
    end
    skill_notice_save_settings()
end
function skill_notice_color_test_gauge(front, back, buffid)
    local gaugeframe = ui.GetFrame(addonNameLower .. "_new")

    local gaugebox = gaugeframe:CreateOrGetControl('groupbox', "gaugebox", 100, 10, 200, 30);
    AUTO_CAST(gaugebox)
    gaugebox:RemoveAllChild()

    local gauge = gaugebox:CreateOrGetControl("gauge", "gauge", 5, 5, 180, 20);
    AUTO_CAST(gauge)
    imcSound.PlaySoundEvent("sys_tp_box_3")
    ui.SysMsg(front .. ":Gauge Color Setting")
    gauge:SetSkinName("gauge");
    -- gauge:SetSkinName("pcbang_point_gauge_s");
    gauge:SetColorTone(back);
    gauge:SetPoint(5, 10);
    gauge:AddStat('{ol}{s20}%v/%m');
    gauge:SetStatFont(0, 'quickiconfont');
    gauge:SetStatAlign(0, ui.CENTER_HORZ, ui.CENTER_VERT);

    gaugeframe:ShowWindow(1)
    gaugebox:ShowWindow(1)
    ReserveScript("skill_notice_color_test_close()", 3.0)
end

function skill_notice_color_test_close()
    local gaugeframe = ui.GetFrame(addonNameLower .. "_new")

    local gaugebox = gaugeframe:GetChildRecursively("gaugebox")

    gaugebox:ShowWindow(0)
end

function skill_notice_sound_select(frame, ctrl, argStr, argNum)

    local context = ui.CreateContextMenu("SOUND_SETTING", "Sound Setting", 300, 0, 100, 100)

    for i, handle in ipairs(handlelist) do

        local scp = string.format("skill_notice_sound_setting('%s','%s')", argStr, handle)
        ui.AddContextMenuItem(context, handle, scp)
    end

    ui.OpenContextMenu(context)
end

function skill_notice_sound_setting(argStr, handle)

    imcSound.PlaySoundEvent(handle);
    if argStr == "Pyktis" then
        g.settings.pyktis.sound = handle
    elseif argStr == "Battle Spirit 8" then
        g.settings.battlespirit8.sound = handle
    elseif argStr == "Battle Spirit 10" then
        g.settings.battlespirit10.sound = handle
    elseif argStr == "Charge Arrow" then
        g.settings.chargearrow.sound = handle
    elseif argStr == "Reload" then
        g.settings.reload.sound = handle
    end
    skill_notice_save_settings()

end

function skill_notice_newframe_close(frame, ctrl, argStr, argNum)
    frame:ShowWindow(0)
end

