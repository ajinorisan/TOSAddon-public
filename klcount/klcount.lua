local addonName = "KLCOUNT"
local addonNameLower = string.lower(addonName)
local author = "norisan"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

g.settingsDirLoc = string.format("../addons/%s", addonNameLower)
g.settingsFileLoc = string.format("%s/settings.json", g.settingsDirLoc)

local acutil = require("acutil")

local count = 0

local maptable = {
    {mapid = 11260, name = "懺悔の祈祷室", zonename = "ep15_1_f_abbey_3"},
    {mapid = 11259, name = "ノヴァハ書庫", zonename = "ep15_1_f_abbey_2"},
    {mapid = 11258, name = "ノヴァハ本院", zonename = "ep15_1_f_abbey_1"}, 
    {mapid = 11255, name = "魔法結社の議事堂", zonename = "ep14_2_d_castle_3"}, 
    {mapid = 11258, name = "隠し通路", zonename = "ep14_2_d_castle_2"},
    {mapid = 11258, name = "デルムーア待合室", zonename = "ep14_2_d_castle_1"}
}

 
function KLCOUNT_ON_INIT(addon, frame)
    CHAT_SYSTEM("KLCOUNT_ON_INIT")
    g.addon = addon
    g.frame = frame

    if not g.loaded then
        g.loaded = true
    end
    
    --local frame = ui.GetFrame("klcount")
    --frame:ShowWindow(1)
    --frame:Resize(300, 150)
    --frame:SetOffset(450, 0)
    --frame:SetAlpha(0)
    --local count = 0
    --countText:SetText(string.format("{#FFFFFF}{s18}モンスター退治数: %d{/}{/}", count))
    addon:RegisterMsg('GAME_START_3SEC', 'KLCOUNT_MAP_NAME')
    addon:RegisterMsg('CHANGE_MAP', 'KLCOUNT_MAP_NAME')
    addon:RegisterMsg('EXP_UPDATE', 'KLCOUNT_COUNT')
    KLCOUNT_MAP_NAME()

end


function KLCOUNT_MAP_NAME()
   count=0
    local mapID = session.GetMapID()
    for i = 1, #maptable do
        if mapID == maptable[i].mapid then
           KLCOUNT_GO(maptable[i].name)
           KLCOUNT_COUNT(frame, msg, argStr, argNum)
            break
        end
    end
end

function KLCOUNT_GO(mapname)
   local frame = ui.GetFrame("klcount")
    frame:ShowWindow(1)
    frame:Resize(300, 150)
    frame:SetOffset(450, 0)
    frame:SetAlpha(0)
    local mapText = frame:CreateOrGetControl("richtext", "map_text", 10, 10, 130, 30)
    mapText:SetText(string.format("{#FF0000}{s18}%s{/}{/}", mapname))
    mapText:SetOffset(10, 60)

end

function KLCOUNT_COUNT(frame, msg, argStr, argNum)
local frame = ui.GetFrame("klcount")
    frame:ShowWindow(1)
    frame:Resize(300, 150)
    frame:SetOffset(450, 0)
    frame:SetAlpha(0)
local countText = frame:CreateOrGetControl("richtext", "count_text", 10, 10, 130, 30)
    countText:SetOffset(10, 30)
    
    if msg == 'EXP_UPDATE' then
        
        countText:SetText(string.format("{#FF0000}{s18}モンスター退治数: %d{/}{/}", count))
        count = count + 1
    end

end
