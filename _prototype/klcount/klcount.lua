local addonName = "KLCOUNT"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.0.3"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

g.settingsFileLoc = string.format("%s/settings.json", addonNameLower)

g.settings = {
    f_x = 450,
    f_y = 20
}
local count = 0

local targetMap = {11260, -- 懺悔の祈祷室
11259, -- ノヴァハ書庫
11258, -- ノヴァハ本院
11255, -- 魔法結社の議事堂
11254, -- 隠し通路
11253 -- デルムーア待合室
}

function KLCOUNT_SAVE_SETTINGS()
    -- CHAT_SYSTEM("save")
    acutil.saveJSON(g.settingsFileLoc, g.settings);

end

function KLCOUNT_LOADSETTINGS()

    local settings, err = acutil.loadJSON(g.settingsFileLoc, g.settings)

    if err then
        -- 設定ファイル読み込み失敗時処理
        CHAT_SYSTEM(string.format("[%s] cannot load setting files",
                                  addonNameLower))
    end
    if not settings then
        settings = g.settings
    end

    g.settings = settings
end

function KLCOUNT_UPDATESETTINGS(frame)
    if g.settings.f_x ~= frame:GetX() or g.settings.f_y ~= frame:GetY() then
        g.settings.f_x = frame:GetX()
        g.settings.f_y = frame:GetY()
        KLCOUNT_SAVE_SETTINGS()
    end
end

function _G.KLCOUNT_ON_INIT(addon, frame)

    _G.CHAT_SYSTEM(addonNameLower .. " loaded")
    g.addon = addon
    g.frame = frame

    g.starttime = imcTime.GetAppTimeMS()

    addon:RegisterMsg("GAME_START_3SEC", "KLCOUNT_INIT_FRAME")
    addon:RegisterMsg("GAME_START_3SEC", "KLCOUNT_UPDATE")
    addon:RegisterMsg("GAME_START_3SEC", "KLCOUNT_TIME_UPDATE")
    addon:RegisterMsg("EXP_UPDATE", "KLCOUNT_UPDATE")

    if g.IsTargetMap() == true then
        addon:RegisterMsg("FPS_UPDATE", "KLCOUNT_TIME_UPDATE")
    end

end

function _G.KLCOUNT_INIT_FRAME()
    local frame = _G.ui.GetFrame("klcount")
    -- 対象外マップ時は非表示
    if g.IsTargetMap() == false then
        frame:ShowWindow(0)
        return
    end

    frame:ShowWindow(1)
    frame:Resize(250, 95)
    if g.settings.f_x ~= nil then
        frame:SetOffset(g.settings.f_x, g.settings.f_y)
    else
        frame:SetOffset(450, 20)
    end
    frame:SetAlpha(80)
    -- frame:EnableHitTest(0)
    frame:SetLayerLevel(31)
    frame:SetTitleBarSkin("shadow_box")
    frame:EnableMove(1)
    frame:SetEventScript(ui.LBUTTONUP, "KLCOUNT_UPDATESETTINGS")

    count = 0

    local countText = frame:CreateOrGetControl("richtext", "count_text", 10, 10,
                                               200, 30)
    local klStr = "KLCounter: "
    countText:SetText(string.format("{s16}%s: %d{/}", klStr, count))

    local mapName = g.GetMapName()
    local mapText = frame:CreateOrGetControl("richtext", "map_text", 10, 35,
                                             200, 30)
    mapText:SetText(string.format("{s16}%s{/}", mapName))

    local timer = frame:CreateOrGetControl("richtext", "timer_text", 140, 60,
                                           200, 30)
    local h = 0
    local m = 0
    local s = 3
    timer:SetText(string.format("{s16}%02d:%02d:%02d{/}", h, m, s))
    KLCOUNT_TIME_UPDATE(frame)
    KLCOUNT_UPDATE(frame, klStr)

end

function KLCOUNT_TIME_UPDATE(frame)
    local time = imcTime.GetAppTimeMS() - g.starttime
    local h = math.floor(time / (60 * 60 * 1000))
    local m = math.floor((time / (60 * 1000)) % 60)
    local s = math.floor((time / 1000) % 60)
    local timer = GET_CHILD_RECURSIVELY(frame, "timer_text")
    timer:SetText(string.format("{s16}%02d:%02d:%02d{/}", h, m, s))
end

function KLCOUNT_UPDATE(frame, klStr)
    if g.IsTargetMap() == false then
        return
    end

    count = count + 1
    countText:SetText(string.format("{s16}%s: %d{/}", klStr, count))
end

-- 対象マップか判定。対象マップtrue、対象外マップfalse
function g.IsTargetMap()
    local mapID = _G.session.GetMapID()
    for i = 1, #targetMap do
        if mapID == targetMap[i] then
            return true
        end
    end
    return false
end

function g.GetMapName()
    local mapID = _G.session.GetMapID()
    return _G.GetClassByType("Map", mapID).Name
end
