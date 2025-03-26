-- v1.0.1 BOSS倒したら矢印速攻消える様に。サイズ控え目に。
-- v1.0.2 角度調整
-- v1.0.3 レイヤー修正。スキルショートカットより低く設定。
-- v1.0.4 バグ修正
-- v1.0.5 クエストモードから復帰した時にちゃんと動かなかったの修正。
-- v1.0.6 レダニアの本体を見つける
local addonName = "BOSS_DIRECTION"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.0.6"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)

local acutil = require("acutil")

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

function BOSS_DIRECTION_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame
    g.framename = addonNameLower

    local pc = GetMyPCObject();
    local curMap = GetZoneName(pc)
    local mapCls = GetClass("Map", curMap)
    g.map_name = mapCls.ClassName

    if mapCls.MapType ~= "City" then

        addon:RegisterMsg('TARGET_SET_BOSS', 'BOSS_DIRECTION_ON_MSG');
        addon:RegisterMsg('TARGET_BUFF_UPDATE', 'BOSS_DIRECTION_ON_MSG');
        addon:RegisterMsg('TARGET_CLEAR_BOSS', 'BOSS_DIRECTION_ON_MSG');
        addon:RegisterMsg('TARGET_UPDATE', 'BOSS_DIRECTION_ON_MSG');
    end
end

function BOSS_DIRECTION_CHECK_HANDLE_STATUS(frame)

    frame:ShowWindow(0)
    return 0
end

function BOSS_DIRECTION_ON_MSG(frame, msg, str, num)

    if msg == "TARGET_CLEAR_BOSS" then
        local frame = ui.GetFrame(addonNameLower .. "_" .. num)
        frame:RunUpdateScript("BOSS_DIRECTION_CHECK_HANDLE_STATUS", 2.0)
        return
    end

    local handle = session.GetTargetBossHandle();
    if handle ~= 0 then
        local frame = ui.GetFrame(addonNameLower .. "_" .. handle)
        if not frame then
            frame = ui.CreateNewFrame("notice_on_pc", addonNameLower .. "_" .. handle, 0, 0, 0, 0)
        end
        frame:SetSkinName("None")
        frame:SetTitleBarSkin("None")
        frame:Resize(130, 130);
        frame:SetLayerLevel(89)

        local arrow = frame:CreateOrGetControl("picture", "arrow", 0, 0, 70, 70);
        AUTO_CAST(arrow)
        arrow:SetImage("class_tree_arrow")
        arrow:SetEnableStretch(1);
        arrow:EnableHitTest(0);
        arrow:SetGravity(ui.CENTER_HORZ, ui.CENTER_VERT);
        arrow:SetAngle(info.GetAngle(handle) - 23);
        -- arrow:SetAngle(info.GetAngle(handle));
        arrow:Resize(70, 70);
        arrow:SetColorTone("FFFF0000");
        FRAME_AUTO_POS_TO_OBJ(frame, handle, -frame:GetWidth() / 2, -frame:GetHeight() / 2, 0, 0);
        frame:ShowWindow(1);
        -- Raid_Redania
        if string.find(g.map_name, "Raid_Redania") then
            if msg == 'TARGET_SET_BOSS' or msg == 'TARGET_UPDATE' or msg == 'TARGET_BUFF_UPDATE' then
                local stat = info.GetStat(handle);
                if stat then
                    local tib_frame = ui.GetFrame("targetinfotoboss");
                    local faint_gauge = GET_CHILD_RECURSIVELY(tib_frame, "faint", "ui::CGauge");
                    local cur_faint = stat.cur_faint;
                    local max_faint = stat.max_faint;

                    if cur_faint > 0 and max_faint > 0 and faint_gauge and faint_gauge:IsVisible() == 1 then
                        local notice = frame:CreateOrGetControl("picture", "notice", 0, 0, 20, 20);
                        AUTO_CAST(notice)
                        notice:SetEnableStretch(1);
                        notice:EnableHitTest(0);
                        notice:SetGravity(ui.CENTER_HORZ, ui.CENTER_VERT);
                        local mon_cls = GetClassByType("Monster", 59864)
                        local img_name = mon_cls.Icon
                        notice:SetImage(img_name)
                        notice:SetAngleLoop(5);
                        -- arrow:SetColorTone("FFFFFF00");

                    end
                end

            end
        end
    end
end

