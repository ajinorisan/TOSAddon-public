local addonName = "KLCOUNT"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.0.2"

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

--CHAT_SYSTEM(imcTime.GetAppTimeMS())

function _G.KLCOUNT_ON_INIT(addon, frame)
    --CancelReserveScript("_G.KLCOUNT_TIME_UPDATE()")
    _G.CHAT_SYSTEM("KLCOUNT_ON_INIT")
    g.addon = addon
    g.frame = frame
    
    g.starttime =imcTime.GetAppTimeMS()
    --g.starttime = 11773799
    addon:RegisterMsg("GAME_START_3SEC", "KLCOUNT_INIT_FRAME")
    addon:RegisterMsg("CHANGE_MAP", "KLCOUNT_INIT_FRAME")
    addon:RegisterMsg("EXP_UPDATE", "KLCOUNT_UPDATE")
    addon:RegisterMsg("FPS_UPDATE", "KLCOUNT_TIME_UPDATE")
    --KLCOUNT_TIME_UPDATE()
    --ReserveScript("_G.KLCOUNT_TIME_UPDATE()", 1.0)
    
end

function _G.KLCOUNT_INIT_FRAME()
    local frame = _G.ui.GetFrame("klcount")
     --対象外マップ時は非表示
    if g.IsTargetMap() == false then
        frame:ShowWindow(0)
        return
    end

    frame:ShowWindow(1)
    frame:Resize(250, 95)
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
    
    local timer = frame:CreateOrGetControl("richtext", "timer_text", 140, 60, 200, 30)
    local h = 0
    local m = 0
    local s = 0
    timer:SetText(string.format("{s18}%02d:%02d:%02d{/}", h, m, s))
    KLCOUNT_TIME_UPDATE()
    --ReserveScript("_G.KLCOUNT_TIME_UPDATE()", 1.0)
end

function KLCOUNT_TIME_UPDATE()
    local time = imcTime.GetAppTimeMS() - g.starttime
    local h = math.floor(time / (60 * 60 * 1000))
    local m = math.floor((time / (60 * 1000)) % 60)
    local s = math.floor((time / 1000) % 60)
    local frame = _G.ui.GetFrame("klcount")
    local timer = frame:CreateOrGetControl("richtext", "timer_text", 140, 60, 200, 30)
    timer:SetText(string.format("{s18}%02d:%02d:%02d{/}", h, m, s))
    --ReserveScript("KLCOUNT_TIME_UPDATE()",1)
    --_G.KLCOUNT_TIME_ON()
end

--function _G.KLCOUNT_TIME_ON()
    --ui.sleep(1000)
    --_G.KLCOUNT_TIME_UPDATE()
--end

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
