local addonName = "BATTLESPIRIT"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.0.0"

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
        g.buffup = 1
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
        g.buffup = 1
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
        text:SetText("{ol}battle spirt")

        local gauge = frame:CreateOrGetControl("gauge", "gauge", 5, 20, 190, 20);
        AUTO_CAST(gauge)
        gauge:SetSkinName("gauge")
        gauge:SetPoint(0, 10);
        gauge:AddStat('{ol}%v/%m');
        gauge:SetStatFont(0, 'quickiconfont');
        gauge:SetStatAlign(0, ui.CENTER_HORZ, ui.CENTER_VERT);
    end

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
            Y = 400
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
                -- print("test")
                effect.AddActorEffectByOffset(actor, effectName, 1.0, "MID", true, true);
                effect.PlayActorEffect(actor, "F_sys_TPBOX_great_300", "None", 1.0, 6.0)

            end
            gauge:SetSkinName("None");
            gauge:SetSkinName("test_gauge_barrack_defence");
            -- gauge:SetColorTone("FF800080");
            gauge:SetColorTone("FFEE82EE");
            -- g.buffmax = 1
        elseif (buff.over == 10) and g.buffmax == 0 then
            if (IsBattleState(GetMyPCObject()) == 1) then

                effect.AddActorEffectByOffset(actor, effectName, 1.5, "MID", true, true);
                effect.PlayActorEffect(actor, "F_sys_TPBOX_great_300", "None", 1.0, 6.0)

            end
            gauge:SetSkinName("test_gauge_barrack_defence");
            gauge:SetColorTone("FFFF0000");
            g.buffmax = 1

        elseif (buff.over == 10) and g.buffmax == 1 then
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

