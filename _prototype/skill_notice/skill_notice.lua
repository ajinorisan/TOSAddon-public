local addonName = "SKILL_NOTICE"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "0.0.1"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)

local acutil = require("acutil")
local json = require('json')

local base = {}
-- icon_guild_boss_dragoon_ex
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
end

function skill_notice_save_settings()
    acutil.saveJSON(g.settingsFileLoc, g.settings)
end

function SKILL_NOTICE_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame

    addon:RegisterMsg('BUFF_UPDATE', 'skill_notice_buff_update');
    addon:RegisterMsg('BUFF_ADD', 'skill_notice_buff_add');
    addon:RegisterMsg('BUFF_REMOVE', 'skill_notice_buff_remove');
    addon:RegisterMsg('GAME_START_3SEC', "skill_notice_frame_init")
    skill_notice_load_settings()
end

function skill_notice_set_gauge(frame, myHandle, buffType, text, index, max)

    local gauge = frame:CreateOrGetControl("gauge", "gauge" .. index, 5, 5, 180, 20);
    AUTO_CAST(gauge)
    local colortone = ""
    local sound = "None"
    local effect = "None"
    local size = 0
    if text == "Pyktis" then
        colortone = g.settings.pyktis.color
        sound = g.settings.pyktis.sound
        effect = g.settings.pyktis.effect
        size = g.settings.pyktis.size
    elseif text == "Battle Spirit 8" then
        colortone = g.settings.battlespirit8.color
        sound = g.settings.battlespirit8.sound
        effect = g.settings.battlespirit8.effect
        size = g.settings.battlespirit8.size

    elseif text == "Battle Spirit 10" then
        colortone = g.settings.battlespirit10.color
        sound = g.settings.battlespirit10.sound
        effect = g.settings.battlespirit10.effect
        size = g.settings.battlespirit10.size

    elseif text == "Charge Arrow" then
        colortone = g.settings.chargearrow.color
        sound = g.settings.chargearrow.sound
        effect = g.settings.chargearrow.effect
        size = g.settings.chargearrow.size

    elseif text == "Reload" then
        colortone = g.settings.reload.color
        sound = g.settings.reload.sound
        effect = g.settings.reload.effect
        size = g.settings.reload.size

    end

    local actor = world.GetActor(myHandle)
    local buff = info.GetBuff(myHandle, buffType)

    gauge:SetSkinName("gauge");
    gauge:SetColorTone(colortone);
    gauge:SetPoint(buff.over, max);
    gauge:AddStat('{ol}{s20}%v/%m');
    gauge:SetStatFont(0, 'quickiconfont');
    gauge:SetStatAlign(0, ui.CENTER_HORZ, ui.CENTER_VERT);

    if (buff ~= nil and buff:GetHandle() == session.GetMyHandle()) then

        if (buff.over == 30) and g.buffmax == 0 then
            if (IsBattleState(GetMyPCObject()) == 1) then

                effect.AddActorEffectByOffset(actor, effectName, 3.0, "MID", true, true);
                effect.PlayActorEffect(actor, "F_sys_TPBOX_great_300", "None", 1.0, 6.0)

            end
            gauge:SetSkinName("test_gauge_barrack_defence");
            gauge:SetColorTone("FFFF0000");
            g.buffmax = 1

        elseif (buff.over == 30) and g.buffmax == 1 then
            gauge:SetSkinName("test_gauge_barrack_defence");
            gauge:SetColorTone("FFFF0000");
        else
            effect.DetachActorEffect(actor, effectName, 0);
            gauge:SetSkinName("test_gauge_barrack_defence");
            if g.buffup == 1 then
                gauge:SetColorTone("FFFFFF00");
            else
                gauge:SetColorTone("FF0000FF");
            end
        end

    end
end

function skill_notice_buff_update(frame, msg, buffIndex, buffType)

    -- print(frame:GetName())
    -- print(msg)
    -- print(buffIndex)
    -- print(buffType)
    local myHandle = session.GetMyHandle()
    local effectName = ""

    for index, buffData in ipairs(bufftbl) do
        if tostring(buffType) == tostring(buffData.id) then
            local text = buffData.text
            local max = buffData.max
            local buff = info.GetBuff(myHandle, buffType);

            if buff ~= nil then

                skill_notice_set_gauge(frame, myHandle, buffType, text, index, max)
            end
        end
    end
end

function skill_notice_frame_init(frame)

    local frame = ui.GetFrame("skill_notice")

    frame:SetSkinName("None");
    frame:SetTitleBarSkin("None")
    frame:EnableMove(1);

    frame:SetPos(g.settings.x, g.settings.y)

    frame:Resize(200, 400);
    -- frame:SetPos(500, 500)

    frame:SetEventScript(ui.LBUTTONUP, "skill_notice_end_drag")
    frame:SetEventScript(ui.RBUTTONUP, "skill_notice_setting")
    -- frame:SetTextTooltip("Right-Click Settings")

    local text = frame:CreateOrGetControl("richtext", "text", 0, 0, 200, 15)
    AUTO_CAST(text)
    text:SetText("{ol}{s12}skill notice")
    text:SetEventScript(ui.RBUTTONUP, "skill_notice_setting")
    text:SetTextTooltip("Right-Click Settings")

    local buffgb = frame:CreateOrGetControl('groupbox', "buffgb", 0, 0, 200, 25);

    local y = 0
    local colortone = ""
    for index, buffData in ipairs(bufftbl) do

        local LoginName = session.GetMySession():GetPCApc():GetName()
        if g.settings[LoginName] == nil then
            g.settings[LoginName] = {}
        end
        -- print(tostring(g.settings[LoginName][buffData.name]))
        if g.settings[LoginName][buffData.name] == nil then
            g.settings[LoginName][buffData.name] = 1
            skill_notice_save_settings()
            local gauge = buffgb:CreateOrGetControl("gauge", "gauge" .. buffData.name, 5, 5, 180, 20);
            AUTO_CAST(gauge)
            y = y + 1
        elseif g.settings[LoginName][buffData.name] == 1 then
            local gauge = buffgb:CreateOrGetControl("gauge", "gauge" .. buffData.name, 5, 5, 180, 20);
            AUTO_CAST(gauge)
            y = y + 1

        end

    end
    buffgb:Resize(200, y * 25)
    frame:ShowWindow(1);
end

function skill_notice_setting(frame, ctrl, argStr, argNum)
    local newframe = ui.CreateNewFrame("notice_on_pc", addonNameLower .. "_new", 0, 0, 200, 400)
    AUTO_CAST(newframe)
    newframe:SetSkinName("test_frame_midle_light")
    newframe:SetPos(g.settings.x, g.settings.y + 20)
    newframe:SetLayerLevel(61);
    newframe:Resize(540, 440)
    newframe:RemoveAllChild()
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

        local gaugecolor = newframe:CreateOrGetControl("richtext", "gaugecolor" .. index, 220, y, 200, 20)
        AUTO_CAST(gaugecolor)
        gaugecolor:SetText("{ol}Gauge Color")

        local colorbox = newframe:CreateOrGetControl('groupbox', "colorbox" .. index, 320, y, 220, 20);
        AUTO_CAST(colorbox)
        for i = 0, 9 do
            local colorCls = colortbl[i + 1]
            -- print(tostring(colorCls))
            if colorCls ~= nil then
                local color = colorbox:CreateOrGetControl("picture", "color" .. index .. "_" .. i, 20 * i, 0, 20, 20);
                AUTO_CAST(color)
                color:SetImage("chat_color");
                color:SetColorTone("FF" .. colorCls)
                color:SetEventScript(ui.LBUTTONUP, "skill_notice_color_select")
                color:SetEventScriptArgString(ui.LBUTTONUP, buffData.text .. "/" .. "FF" .. colorCls)
                color:SetEventScriptArgNumber(ui.LBUTTONUP, buffData.id)

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

        local display = newframe:CreateOrGetControl("richtext", "display" .. index, 370, y + 30, 200, 20)
        AUTO_CAST(display)
        display:SetText("{ol}display or hide")

        local displaycheck = newframe:CreateOrGetControl("checkbox", "displaycheck" .. index, 500, y + 30, 200, 20)
        AUTO_CAST(displaycheck)
        displaycheck:SetTextTooltip("Check to display")
        local LoginName = session.GetMySession():GetPCApc():GetName()
        displaycheck:SetCheck(g.settings[LoginName][buffData.name])

        displaycheck:SetEventScript(ui.LBUTTONUP, "skill_notice_ischeck")
        displaycheck:SetEventScriptArgString(ui.LBUTTONUP, buffData.name)

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
        --[[print("Text: " .. buffData.text)
        print("Name: " .. buffData.name)
        print("ID: " .. buffData.id)
        print("Max: " .. buffData.max)]]
        y = y + 80
    end
    --[[ print(#bufftbl)
   
    for k, v in pairs(bufftbl) do
        print(k)
        for k2, v2 in pairs(v) do
            print(tostring(k2) .. ":" .. tostring(v2))
           local buffName = newframe:CreateOrGetControl("richtext", "buffName" .. i, 10, y - 20, 200, 20)
            AUTO_CAST(buffName)
            local slot = newframe:CreateOrGetControl("slot", "slot" .. i, 10, y, 50, 50)
            AUTO_CAST(slot)
            slot:EnablePop(0)
            slot:EnableDrop(0)
            slot:EnableDrag(0)
            slot:SetSkinName('invenslot2');
        end
       

    end]]
end

function skill_notice_ischeck(frame, ctrl, argStr, argNum)
    local ischeck = ctrl:IsChecked()
    local ctrlname = ctrl:GetName()
    local LoginName = session.GetMySession():GetPCApc():GetName()
    g.settings[LoginName][argStr] = ischeck
    -- print(tostring(ctrlname) .. ":" .. tostring(ischeck))
    skill_notice_save_settings()
end

function skill_notice_effect_size(frame, ctrl, argStr, argNum)
    print(argStr)
    print(tonumber(ctrl:GetText()))
    local size = tonumber(ctrl:GetText())

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
    if argStr == "Pyktis" then

        effectName = g.settings.pyktis.effect

    elseif argStr == "Battle Spirit 8" then
        effectName = g.settings.battlespirit8.effect

    elseif argStr == "Battle Spirit 10" then
        effectName = g.settings.battlespirit10.effect

    elseif argStr == "Charge Arrow" then
        effectName = g.settings.chargearrow.effect

    elseif argStr == "Reload" then
        effectName = g.settings.reload.effect

    end
    effect.AddActorEffectByOffset(actor, effectName, size, "MID", true, true);
    effect.DetachActorEffect(actor, effectName, 7.0);

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

    -- effect.AddActorEffectByOffset(actor, effectName, 3.0, "MID", true, true);

    if argStr == "Pyktis" then
        -- print(tostring(effectName) .. 1)
        -- effect.AddActorEffectByOffset(actor, effectName, tonumber(g.settings.pyktis.size), "MID", true, true);
        g.settings.pyktis.effect = effect

    elseif argStr == "Battle Spirit 8" then
        g.settings.battlespirit8.effect = effect
        -- effect.AddActorEffectByOffset(actor, effectName, 3.0, "MID", true, true);
    elseif argStr == "Battle Spirit 10" then
        g.settings.battlespirit10.effect = effect
        -- effect.AddActorEffectByOffset(actor, effectName, g.settings.battlespirit10.size, "MID", true, true);
    elseif argStr == "Charge Arrow" then
        g.settings.chargearrow.effect = effect
        -- effect.AddActorEffectByOffset(actor, effectName, g.settings.chargearrow.size, "MID", true, true);
    elseif argStr == "Reload" then
        g.settings.reload.effect = effect
        -- effect.AddActorEffectByOffset(actor, effectName, g.settings.reload.size, "MID", true, true);
    end
    skill_notice_save_settings()
    ReserveScript(string.format("skill_notice_effect_test('%s')", effectName), 0.1)

end

function skill_notice_effect_test(effectName)
    local myHandle = session.GetMyHandle();
    local actor = world.GetActor(myHandle)
    effect.AddActorEffectByOffset(actor, effectName, tonumber(g.settings.pyktis.size), "MID", true, true);
    effect.DetachActorEffect(actor, effectName, 7.0);
    -- ReserveScript(string.format("skill_notice_effect_test_close('%s')", effectName), 3.0)
    -- print(effectName)
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

function skill_notice_end_drag(frame, ctrl)
    g.settings.x = frame:GetX();
    g.settings.y = frame:GetY();
    skill_notice_save_settings()
end
