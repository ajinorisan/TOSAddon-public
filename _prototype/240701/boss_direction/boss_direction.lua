-- v1.0.1 BOSS倒したら矢印速攻消える様に。サイズ控え目に。
-- v1.0.2 角度調整
-- v1.0.3 運用見直し。レイヤー見直し
local addonName = "BOSS_DIRECTION"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.0.3"

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
    if mapCls.MapType ~= "City" then

        addon:RegisterMsg('TARGET_SET_BOSS', 'BOSS_DIRECTION_ON_MSG');
        addon:RegisterMsg('TARGET_BUFF_UPDATE', 'BOSS_DIRECTION_ON_MSG');
        addon:RegisterMsg('TARGET_CLEAR_BOSS', 'BOSS_DIRECTION_ON_MSG');
        addon:RegisterMsg('TARGET_UPDATE', 'BOSS_DIRECTION_ON_MSG');

        -- local frame = ui.GetFrame(g.framename)
        -- local headsup = ui.GetFrame("headsupdisplay");
        -- headsup:RunUpdateScript("BOSS_DIRECTION_ON_MSG", 0.1)
        local frame = ui.GetFrame("boss_direction")
        -- frame:RunUpdateScript("UPDATE_BOSS_DISTANCE", 0.1)
        local timer = frame:GetChild("addontimer");
        tolua.cast(timer, "ui::CAddOnTimer");
        timer:SetUpdateScript("BOSS_DIRECTION_ON_MSG");
        timer:Start(0.1);
    end

end

function BOSS_DIRECTION_ON_MSG(frame, msg, argStr, argNum)
    local frame = ui.GetFrame("boss_direction")

    local handle = session.GetTargetBossHandle();
    local targetinfo = info.GetTargetInfo(handle);
    if nil == targetinfo then
        session.ResetTargetBossHandle();
        frame:ShowWindow(0);
        return;
    end
    if msg == "TARGET_CLEAR_BOSS" then
        frame:ShowWindow(0)
        return
    end

    frame:SetSkinName("None")
    frame:SetTitleBarSkin("None")

    frame:Resize(130, 130);
    frame:SetLayerLevel(89)

    local arrow = frame:GetChild("arrow");
    if arrow == nil then
        arrow = frame:CreateOrGetControl("picture", "arrow", 0, 0, 80, 80);
        tolua.cast(arrow, "ui::CPicture");

        arrow:SetImage("class_tree_arrow")

        arrow:SetEnableStretch(1);
        arrow:EnableHitTest(0);
        arrow:SetGravity(ui.CENTER_HORZ, ui.CENTER_VERT);
    end
    if handle ~= 0 then
        -- arrow:SetAngle(info.GetAngle(handle) - 30);
        arrow:SetAngle(info.GetAngle(handle) - 23);
        arrow:Resize(100, 100);
        arrow:SetColorTone("FFFF0000");
        FRAME_AUTO_POS_TO_OBJ(frame, handle, -frame:GetWidth() / 2, -frame:GetHeight() / 2, 0, 0);
        frame:ShowWindow(1);
    end

    return

end

