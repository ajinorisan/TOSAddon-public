local addonName = "BOSS_DIRECTION"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.0.0"

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

    addon:RegisterMsg('TARGET_SET_BOSS', 'BOSS_DIRECTION_ON_MSG');
    addon:RegisterMsg('TARGET_BUFF_UPDATE', 'BOSS_DIRECTION_ON_MSG');
    addon:RegisterMsg('TARGET_CLEAR_BOSS', 'BOSS_DIRECTION_ON_MSG');
    addon:RegisterMsg('TARGET_UPDATE', 'BOSS_DIRECTION_ON_MSG');

    local pc = GetMyPCObject();
    local curMap = GetZoneName(pc)
    local mapCls = GetClass("Map", curMap)
    if mapCls.MapType ~= "City" then
        addon:RegisterMsg('FPS_UPDATE', 'BOSS_DIRECTION_ON_MSG');
    end

end

function BOSS_DIRECTION_ON_MSG(frame, msg, argStr, argNum)

    local handle = session.GetTargetBossHandle();
    local targetinfo = info.GetTargetInfo(handle);
    local frame = ui.GetFrame(g.framename)

    local scale = 3.0
    frame:Resize(200 * scale, 220 * scale);
    frame:SetLayerLevel(91)

    local picCircle = frame:GetChild("point_circle");
    if picCircle == nil then
        picCircle = frame:CreateOrGetControl("picture", "point_circle", 0, 0, 220, 220);
        tolua.cast(picCircle, "ui::CPicture");
        -- picCircle:SetImage("boss_direction");
        picCircle:SetImage("class_tree_arrow")
        picCircle:SetEnableStretch(1);
        picCircle:EnableHitTest(0);
        picCircle:SetGravity(ui.CENTER_HORZ, ui.CENTER_VERT);
    end
    local assistCurrentX = 45
    picCircle:SetAngle(info.GetAngle(handle) + assistCurrentX);
    picCircle:Resize(220 * scale, 220 * scale);
    picCircle:SetColorTone("FF7777FF");
    FRAME_AUTO_POS_TO_OBJ(frame, handle, -frame:GetWidth() / 2, -frame:GetHeight() / 2, 0, 0);
    frame:ShowWindow(1);
    return
end

