local addonName = "KLCOUNT"
local addonNameLower = string.lower(addonName)
local author = "norisan"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

g.settingsDirLoc = string.format("../addons/%s", addonNameLower)
g.settingsFileLoc = string.format("%s/settings.json", g.settingsDirLoc)

local count = 0

local targetMap = {
    11260, -- 懺悔の祈祷室
    11259, -- ノヴァハ書庫
    11258, -- ノヴァハ本院
    11255, -- 魔法結社の議事堂
    11258, -- 隠し通路
    11258  -- デルムーア待合室
}

function _G.KLCOUNT_ON_INIT(addon, frame)
    _G.CHAT_SYSTEM("KLCOUNT_ON_INIT")
    g.addon = addon
    g.frame = frame

    addon:RegisterMsg("GAME_START_3SEC", "KLCOUNT_INIT_FRAME")
    addon:RegisterMsg("CHANGE_MAP", "KLCOUNT_INIT_FRAME")
    addon:RegisterMsg("EXP_UPDATE", "KLCOUNT_UPDATE")
end

function _G.KLCOUNT_INIT_FRAME()
    local frame = _G.ui.GetFrame("klcount")
    -- 対象外マップ時は非表示
    if g.IsTargetMap() == false then
        frame:ShowWindow(0)
        return
    end

    frame:ShowWindow(1)
    frame:Resize(250, 70)
    frame:SetOffset(450, 20)
    frame:SetAlpha(80)
    frame:EnableHitTest(0)
    frame:SetLayerLevel(31)
    frame:SetTitleBarSkin("shadow_box")

    count = 0
    local countText = frame:CreateOrGetControl("richtext", "count_text", 10, 10, 200, 30)
    countText:SetText(string.format("{s18}モンスター退治数: %d{/}", count))

    local mapName = g.GetMapName()
    local mapText = frame:CreateOrGetControl("richtext", "map_text", 10, 35, 200, 30)
    mapText:SetText(string.format("{s18}%s{/}", mapName))
end

function _G.KLCOUNT_UPDATE()
    if g.IsTargetMap() == false then
        return
    end

    local frame = _G.ui.GetFrame("klcount")
    local countText = frame:CreateOrGetControl("richtext", "count_text", 10, 10, 200, 30)

    count = count + 1
    countText:SetText(string.format("{s18}モンスター退治数: %d{/}", count))
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
