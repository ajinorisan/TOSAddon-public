local addonName = "PYKTIS_NOTICE"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.0.0"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)

g.buffid = 1158 -- 充填(雷撃)

local acutil = require("acutil")
local os = require("os")

function PYKTIS_NOTICE_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame

    addon:RegisterMsg('BUFF_UPDATE', 'PYKTIS_NOTICE_BUFF_UPDATE');
    addon:RegisterMsg('BUFF_ADD', 'PYKTIS_NOTICE_BUFF_ADD');
    addon:RegisterMsg('BUFF_REMOVE', 'PYKTIS_NOTICE_BUFF_REMOVE');
    addon:RegisterMsg('GAME_START_3SEC', "PYKTIS_NOTICE_FRAME_INIT")
    PYKTIS_NOTICE_LOAD_SETTINGS()

end

function PYKTIS_NOTICE_BUFF_ADD(frame, msg, buffIndex, buffType)

    if (buffType == g.buffid) then
        local gauge = frame:GetChildRecursively('gauge');
        AUTO_CAST(gauge)
        gauge:ShowWindow(1)
        g.buffup = 1
    end

end

function PYKTIS_NOTICE_BUFF_REMOVE(frame, msg, buffIndex, buffType)

    if (buffType == g.buffid) then
        local gauge = frame:GetChildRecursively('gauge');
        AUTO_CAST(gauge)
        gauge:ShowWindow(0)
        g.buffup = 1
    end

end

function PYKTIS_NOTICE_END_DRAG(frame, ctrl)
    g.settings.X = frame:GetX();
    g.settings.Y = frame:GetY();
    PYKTIS_NOTICE_SAVE_SETTINGS();
end

function PYKTIS_NOTICE_FRAME_INIT(frame)

    local frame = ui.GetFrame("pyktis_notice")

    frame:SetSkinName("None");
    frame:SetTitleBarSkin("None")
    frame:EnableMove(1);

    frame:SetPos(g.settings.X, g.settings.Y)

    frame:Resize(200, 40);

    frame:SetPos(g.settings.X, g.settings.Y)

    frame:SetEventScript(ui.LBUTTONUP, "PYKTIS_NOTICE_END_DRAG")
    frame:ShowWindow(1);

    local text = frame:CreateOrGetControl("richtext", "text", 5, 0, 200, 20)
    AUTO_CAST(text)
    text:SetText("{ol}pyktis")

    local gauge = frame:CreateOrGetControl("gauge", "gauge", 5, 20, 190, 20);
    AUTO_CAST(gauge)
    gauge:SetSkinName("gauge")
    gauge:SetPoint(0, 30);
    gauge:AddStat('{ol}%v/%m');
    gauge:SetStatFont(0, 'quickiconfont');
    gauge:SetStatAlign(0, ui.CENTER_HORZ, ui.CENTER_VERT);

end

function PYKTIS_NOTICE_LOAD_SETTINGS()
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

        PYKTIS_NOTICE_SAVE_SETTINGS()

    end
    g.settings = settings
end

function PYKTIS_NOTICE_SAVE_SETTINGS()
    acutil.saveJSON(g.settingsFileLoc, g.settings)
end

function PYKTIS_NOTICE_SET_GAUGE(frame)

    local myHandle = session.GetMyHandle();
    local actor = world.GetActor(myHandle)
    local buff = info.GetBuff(myHandle, g.buffid)
    local effectName = "F_archere_magicarrow_gruond_loop2" -- E_effect_twinshark --F_pattern025_loop
    local gauge = frame:GetChildRecursively('gauge');
    AUTO_CAST(gauge)

    if (buff ~= nil and buff:GetHandle() == session.GetMyHandle()) then
        gauge:SetPoint(buff.over, 30);
        if (buff.over == 30) then
            if (IsBattleState(GetMyPCObject()) == 1) then

                effect.AddActorEffectByOffset(actor, effectName, 5.0, "MID", true, true);
                effect.PlayActorEffect(actor, "F_sys_TPBOX_great_300", "None", 1.0, 6.0)

            end
            gauge:SetSkinName("test_gauge_barrack_defence");

            gauge:SetColorTone("FFFF0000");
            g.buffup = 0

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

function PYKTIS_NOTICE_BUFF_UPDATE(frame, msg, buffIndex, buffType)

    local myHandle = session.GetMyHandle()
    if (buffType == g.buffid) then

        frame:ShowWindow(1)
        local buff = info.GetBuff(myHandle, buffType);

        if buff ~= nil then

            PYKTIS_NOTICE_SET_GAUGE(frame)
        end
    end
end

