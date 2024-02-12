-- v1.0.2 音選べる様に。
local addonName = "BATTLESPIRIT"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.0.2"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)

g.buffid = 1163 -- 戦場の気概

local acutil = require("acutil")
local os = require("os")

function BATTLESPIRIT_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame

    addon:RegisterMsg('BUFF_UPDATE', 'BATTLESPIRIT_BUFF_UPDATE');
    addon:RegisterMsg('BUFF_ADD', 'BATTLESPIRIT_BUFF_ADD');
    addon:RegisterMsg('BUFF_REMOVE', 'BATTLESPIRIT_BUFF_REMOVE');
    addon:RegisterMsg('GAME_START_3SEC', "BATTLESPIRIT_FRAME_INIT")
    BATTLESPIRIT_LOAD_SETTINGS()

end

function BATTLESPIRIT_BUFF_ADD(frame, msg, buffIndex, buffType)

    if (buffType == g.buffid) then

        local gauge = frame:GetChildRecursively('gauge');
        AUTO_CAST(gauge)

        local myHandle = session.GetMyHandle();
        local buff = info.GetBuff(myHandle, g.buffid)
        gauge:SetPoint(buff.over, 10);
        local actor = world.GetActor(myHandle)
        local effectName = "F_pattern025_loop"
        effect.DetachActorEffect(actor, effectName, 0);
        gauge:SetColorTone("FFFFFF00");
        gauge:ShowWindow(1)

        g.buffmax = 0
    end

end

function BATTLESPIRIT_BUFF_REMOVE(frame, msg, buffIndex, buffType)

    if (buffType == g.buffid) then
        local gauge = frame:GetChildRecursively('gauge');
        AUTO_CAST(gauge)
        gauge:ShowWindow(0)
        local myHandle = session.GetMyHandle();
        local actor = world.GetActor(myHandle)
        local effectName = "F_pattern025_loop"
        effect.DetachActorEffect(actor, effectName, 0);
        local gauge = frame:GetChildRecursively('gauge');
        AUTO_CAST(gauge)
        gauge:ShowWindow(0)

        g.buffmax = 0
    end

end

function BATTLESPIRIT_END_DRAG(frame, ctrl)
    g.settings.X = frame:GetX();
    g.settings.Y = frame:GetY();
    BATTLESPIRIT_SAVE_SETTINGS();
end

function BATTLESPIRIT_FRAME_INIT(frame)
    local pc = GetMyPCObject();
    local nowjobName = pc.JobName;

    local nowjobID = GetClass("Job", nowjobName).ClassID;

    if nowjobID >= 1001 and nowjobID <= 1025 then
        local frame = ui.GetFrame("battlespirit")

        frame:SetSkinName("None");
        frame:SetTitleBarSkin("None")
        frame:EnableMove(1);

        frame:SetPos(g.settings.X, g.settings.Y)

        frame:Resize(200, 40);

        frame:SetEventScript(ui.LBUTTONUP, "BATTLESPIRIT_END_DRAG")
        frame:ShowWindow(1);

        local text = frame:CreateOrGetControl("richtext", "text", 5, 0, 200, 20)
        AUTO_CAST(text)
        text:SetText("{ol}battle spirit")
        text:SetEventScript(ui.RBUTTONUP, "BATTLESPIRIT_CONTEXTMENU")
        text:SetTextTooltip("Right-click Sound Setting")

        local gauge = frame:CreateOrGetControl("gauge", "gauge", 5, 20, 190, 20);
        AUTO_CAST(gauge)
        gauge:SetSkinName("gauge")
        gauge:SetPoint(0, 10);
        gauge:AddStat('{ol}%v/%m');
        gauge:SetStatFont(0, 'quickiconfont');
        gauge:SetStatAlign(0, ui.CENTER_HORZ, ui.CENTER_VERT);
    end

end

function BATTLESPIRIT_CONTEXTMENU()

    local handlelist = {
        [1] = "premium_enchantchip",
        [2] = "system_craft_potion_succes",
        [3] = 'sys_confirm',
        [4] = 'sys_cube_open_normal',
        [5] = 'sys_cube_open_jackpot',
        [6] = 'sys_tp_box_3',
        [7] = 'sys_tp_box_4'

    }

    local context = ui.CreateContextMenu("SOUND_SETTING", "Sound Setting", 0, 0, 100, 100);

    local handle = ""
    local scp
    scp = string.format("BATTLESPIRIT_SOUND_SELECT('%s')", handlelist[1])
    ui.AddContextMenuItem(context, "Cancel");
    ui.AddContextMenuItem(context, "-------------------");
    ui.AddContextMenuItem(context, "8+ levels of setting");
    ui.AddContextMenuItem(context, "--------------------");
    scp = string.format("BATTLESPIRIT_SOUND_SELECT('%s')", handlelist[1])
    ui.AddContextMenuItem(context, "premium_enchantchip", scp);
    scp = string.format("BATTLESPIRIT_SOUND_SELECT('%s')", handlelist[2])
    ui.AddContextMenuItem(context, "sys_jam_barguage", scp);
    scp = string.format("BATTLESPIRIT_SOUND_SELECT('%s')", handlelist[3])
    ui.AddContextMenuItem(context, "sys_confirm", scp);
    scp = string.format("BATTLESPIRIT_SOUND_SELECT('%s')", handlelist[4])
    ui.AddContextMenuItem(context, "sys_cube_open_normal", scp);
    scp = string.format("BATTLESPIRIT_SOUND_SELECT('%s')", handlelist[5])
    ui.AddContextMenuItem(context, "sys_cube_open_jackpot", scp);
    scp = string.format("BATTLESPIRIT_SOUND_SELECT('%s')", handlelist[6])
    ui.AddContextMenuItem(context, "sys_tp_box_3", scp);
    scp = string.format("BATTLESPIRIT_SOUND_SELECT('%s')", handlelist[7])
    ui.AddContextMenuItem(context, "sys_tp_box_4", scp);

    ui.AddContextMenuItem(context, "---------------------");
    ui.AddContextMenuItem(context, "10 levels of setting");
    ui.AddContextMenuItem(context, "----------------------");
    scp = string.format("BATTLESPIRIT_SOUND_SELECT_TENLV('%s')", handlelist[1])
    ui.AddContextMenuItem(context, " premium_enchantchip", scp);
    scp = string.format("BATTLESPIRIT_SOUND_SELECT_TENLV('%s')", handlelist[2])
    ui.AddContextMenuItem(context, " sys_jam_barguage", scp);
    scp = string.format("BATTLESPIRIT_SOUND_SELECT_TENLV('%s')", handlelist[3])
    ui.AddContextMenuItem(context, " sys_confirm", scp);
    scp = string.format("BATTLESPIRIT_SOUND_SELECT_TENLV('%s')", handlelist[4])
    ui.AddContextMenuItem(context, " sys_cube_open_normal", scp);
    scp = string.format("BATTLESPIRIT_SOUND_SELECT_TENLV('%s')", handlelist[5])
    ui.AddContextMenuItem(context, " sys_cube_open_jackpot", scp);
    scp = string.format("BATTLESPIRIT_SOUND_SELECT_TENLV('%s')", handlelist[6])
    ui.AddContextMenuItem(context, " sys_tp_box_3", scp);
    scp = string.format("BATTLESPIRIT_SOUND_SELECT_TENLV('%s')", handlelist[7])
    ui.AddContextMenuItem(context, " sys_tp_box_4", scp);
    ui.OpenContextMenu(context);
end

function BATTLESPIRIT_SOUND_SELECT_TENLV(handle)
    imcSound.PlaySoundEvent(handle);
    g.settings.tensound = handle
    BATTLESPIRIT_SAVE_SETTINGS()
end

function BATTLESPIRIT_SOUND_SELECT(handle)
    imcSound.PlaySoundEvent(handle);
    g.settings.sound = handle
    BATTLESPIRIT_SAVE_SETTINGS()
end

function BATTLESPIRIT_LOAD_SETTINGS()
    local settings, err = acutil.loadJSON(g.settingsFileLoc, g.settings)
    if err then
        -- 設定ファイル読み込み失敗時処理
        CHAT_SYSTEM(string.format("[%s] cannot load setting files", addonNameLower))
    end
    if not settings then

        g.settings = {
            X = 400,
            Y = 400,
            sound = "premium_enchantchip",
            tensound = "sys_tp_box_3"
        }

        BATTLESPIRIT_SAVE_SETTINGS()

    end

    g.settings = settings
end

function BATTLESPIRIT_SAVE_SETTINGS()
    acutil.saveJSON(g.settingsFileLoc, g.settings)
end

function BATTLESPIRIT_SET_GAUGE(frame)

    local myHandle = session.GetMyHandle();
    local actor = world.GetActor(myHandle)
    local buff = info.GetBuff(myHandle, g.buffid)
    local effectName = "F_pattern025_loop" -- E_effect_twinshark --F_pattern025_loop
    local gauge = frame:GetChildRecursively('gauge');
    AUTO_CAST(gauge)

    if (buff ~= nil and buff:GetHandle() == session.GetMyHandle()) then
        gauge:SetPoint(buff.over, 10);
        if (buff.over >= 8 and buff.over <= 9) and g.buffmax == 0 then

            if (IsBattleState(GetMyPCObject()) == 1) then

                effect.AddActorEffectByOffset(actor, effectName, 1.5, "MID", true, true);
                if g.settings.sound == nil then
                    g.settings.sound = "premium_enchantchip"
                    BATTLESPIRIT_SAVE_SETTINGS()
                end
                imcSound.PlaySoundEvent(g.settings.sound);

            end
            gauge:SetSkinName("None");

            gauge:SetSkinName("test_gauge_barrack_defence");
            gauge:SetSkinName("gauge");
            gauge:SetColorTone("FFFF6666");

        elseif (buff.over == 10) and g.buffmax == 0 then
            if (IsBattleState(GetMyPCObject()) == 1) then

                effect.AddActorEffectByOffset(actor, effectName, 2.0, "MID", true, true);
                -- effect.PlayActorEffect(actor, "F_sys_TPBOX_great_300", "None", 1.0, 6.0)
                if g.settings.tensound == nil then
                    g.settings.tensound = "sys_tp_box_3"
                    BATTLESPIRIT_SAVE_SETTINGS()
                end
                imcSound.PlaySoundEvent(g.settings.tensound);

            end
            gauge:SetSkinName("test_gauge_barrack_defence");
            gauge:SetSkinName("gauge");
            gauge:SetColorTone("FFFF0000");
            g.buffmax = 1

        elseif (buff.over == 10) and g.buffmax == 1 then
            gauge:SetSkinName("test_gauge_barrack_defence");
            gauge:SetSkinName("gauge");
            gauge:SetColorTone("FFFF0000");
        else

            effect.DetachActorEffect(actor, effectName, 0);
            gauge:SetSkinName("test_gauge_barrack_defence");
            gauge:SetSkinName("gauge");

        end

    end
end

function BATTLESPIRIT_BUFF_UPDATE(frame, msg, buffIndex, buffType)

    local myHandle = session.GetMyHandle()
    if (buffType == g.buffid) then

        frame:ShowWindow(1)
        local buff = info.GetBuff(myHandle, buffType);

        if buff ~= nil then

            BATTLESPIRIT_SET_GAUGE(frame)
        end
    end
end

