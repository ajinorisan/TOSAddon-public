-- v1.0.5 23.9.5のアプデのに伴いフィールドマップではどこでも表示に変更。メンドイので（
-- v1.0.6 未知の聖域でも表示される様に。未知用自動レリックOFF隠し要素追加
local addonName = "KLCOUNT"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.0.6"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

local acutil = require("acutil")

g.settingsFileLoc = string.format("../addons/%s/settings.json", addonNameLower);

g.settings = {
    f_x = 450,
    f_y = 20
}

g.count = 0

--[[local targetMap = {11260, -- 懺悔の祈祷室
11259, -- ノヴァハ書庫
11258, -- ノヴァハ本院
11255, -- 魔法結社の議事堂
11254, -- 隠し通路
11253 -- デルムーア待合室
}]]

local targetmap = {11239, -- 1F
11242, -- 2F
11244 -- 3F
}

g.ischecked = 0

function KLCOUNT_SAVE_SETTINGS()
    -- CHAT_SYSTEM("save")
    acutil.saveJSON(g.settingsFileLoc, g.settings);

end

function KLCOUNT_LOADSETTINGS()

    local settings, err = acutil.loadJSON(g.settingsFileLoc, g.settings)

    if err then
        -- 設定ファイル読み込み失敗時処理
        CHAT_SYSTEM(string.format("[%s] cannot load setting files", addonNameLower))
    end
    if not settings then
        settings = g.settings
    end

    g.settings = settings
    KLCOUNT_SAVE_SETTINGS()
end

function KLCOUNT_UPDATESETTINGS(frame)
    if g.settings.f_x ~= frame:GetX() or g.settings.f_y ~= frame:GetY() then
        g.settings.f_x = frame:GetX()
        g.settings.f_y = frame:GetY()
        KLCOUNT_SAVE_SETTINGS()
    end
end

function _G.KLCOUNT_ON_INIT(addon, frame)

    -- _G.CHAT_SYSTEM(addonNameLower .. " loaded")
    g.addon = addon
    g.frame = frame

    g.starttime = imcTime.GetAppTimeMS()

    -- addon:RegisterMsg("GAME_START_3SEC", "KLCOUNT_UPDATE")
    -- addon:RegisterMsg("GAME_START_3SEC", "KLCOUNT_TIME_UPDATE")

    local pc = GetMyPCObject();
    local curMap = GetZoneName(pc)
    local mapCls = GetClass("Map", curMap)
    -- CHAT_SYSTEM(tostring(mapCls.MapType))

    if mapCls.MapType == "Field" or mapCls.MapType == "Dungeon" then
        addon:RegisterMsg("FPS_UPDATE", "KLCOUNT_TIME_UPDATE")
        addon:RegisterMsg("GAME_START", "KLCOUNT_INIT_FRAME")
        addon:RegisterMsg("EXP_UPDATE", "KLCOUNT_UPDATE")
    end

    if g.IsTargetMap() == true then

        frame:SetEventScript(ui.RBUTTONUP, "KLCOUNT_CHECKBOX_OPEN")

        addon:RegisterMsg('BUFF_ADD', 'KLCOUNT_BUFF_ADD');

    end

    KLCOUNT_LOADSETTINGS()
end

function KLCOUNT_BUFF_ADD(frame, msg, argStr, classID)
    -- local buff = info.GetBuff(session.GetMyHandle(), 40049)
    -- if buff ~= nil then
    if g.ischecked == 1 then
        ReserveScript("KLCOUNT_CHECK_ALL_SLOTS()", 5.0)
    else
        return
    end

end

function KLCOUNT_CHECK_ALL_SLOTS()

    local frame = ui.GetFrame("quickslotnexpbar")
    if not frame then
        return
    end

    local buff = info.GetBuff(session.GetMyHandle(), 40049)
    -- CHAT_SYSTEM(g.ischecked)

    local slotCount = 40
    if g.ischecked == 1 then
        -- CHAT_SYSTEM(tostring(buff))
        for i = 0, slotCount - 1 do
            local slot = tolua.cast(frame:GetChildRecursively("slot" .. i + 1), "ui::CSlot")
            if slot and slot:GetIcon() then
                local iconInfo = slot:GetIcon():GetInfo()

                local iconName = iconInfo:GetImageName()
                if iconName == "icon_common_relic_release" and buff ~= nil then
                    local icon = tolua.cast(frame:GetChildRecursively("slot" .. i + 1), "ui::CSlot"):GetIcon()

                    ICON_USE(icon)
                    return
                    -- 
                end
            end
        end
    end
end

function KLCOUNT_CHECKBOX_OPEN(frame)

    local checkbox = frame:CreateOrGetControl('checkbox', 'checkbox', 20, 60, 15, 15)
    AUTO_CAST(checkbox)
    checkbox:SetTextTooltip("チェックすると自動でレリックOFF{nl}Automatic relic off when checked.")
    checkbox:ShowWindow(1)
    local ischeck = checkbox:IsChecked(g.ischecked);
    checkbox:SetEventScript(ui.LBUTTONUP, "KLCOUNT_ISCHECKED")
    ReserveScript("KLCOUNT_CHECKBOX_CLOSE()", 10.0)
    -- frame:RunUpdateScript("KLCOUNT_ISCHECKED", 1)
end

function KLCOUNT_ISCHECKED(frame)
    -- CHAT_SYSTEM(ischeck)
    local checkbox = GET_CHILD_RECURSIVELY(frame, "checkbox")
    local ischeck = checkbox:IsChecked()
    -- CHAT_SYSTEM(ischeck)
    if ischeck == 1 then
        g.ischecked = 1
        CHAT_SYSTEM("Automatic relic off")
        ReserveScript("KLCOUNT_CHECKBOX_CLOSE()", 5.0)
    elseif ischeck == 0 then
        g.ischecked = 0
        -- CHAT_SYSTEM(g.ischecked)
        ReserveScript("KLCOUNT_CHECKBOX_CLOSE()", 5.0)
    end

end

function KLCOUNT_CHECKBOX_CLOSE()
    local frame = ui.GetFrame(addonNameLower)
    local checkbox = GET_CHILD_RECURSIVELY(frame, "checkbox")
    -- CHAT_SYSTEM(tostring(checkbox))
    checkbox:ShowWindow(0)
end

function KLCOUNT_INIT_FRAME()
    local frame = _G.ui.GetFrame("klcount")
    -- 対象外マップ時は非表示
    --[[if g.IsTargetMap() == false then
        frame:ShowWindow(0)
        return
    end]]

    frame:ShowWindow(1)
    frame:EnableHitTest(1)
    frame:EnableMove(1)
    frame:Resize(170, 95)
    if g.settings.f_x ~= nil then
        frame:SetOffset(g.settings.f_x, g.settings.f_y)
    else
        frame:SetOffset(450, 20)
    end
    frame:SetAlpha(80)
    frame:SetLayerLevel(31)
    frame:SetTitleBarSkin("shadow_box")
    frame:SetEventScript(ui.LBUTTONUP, "KLCOUNT_UPDATESETTINGS")

    g.count = 0

    local countText = frame:CreateOrGetControl("richtext", "count_text", 10, 10, 200, 30)
    -- local klStr = "KLCounter"
    countText:SetText(string.format("{s16}KLCounter : %d{/}", g.count))

    local mapName = g.GetMapName()
    local mapText = frame:CreateOrGetControl("richtext", "map_text", 10, 35, 200, 30)
    mapText:SetText(string.format("{s16}%s{/}", mapName))

    local timer = frame:CreateOrGetControl("richtext", "timer_text", 90, 60, 200, 30)
    local h = 0
    local m = 0
    local s = 0
    timer:SetText(string.format("{s16}%02d:%02d:%02d{/}", h, m, s))
    KLCOUNT_TIME_UPDATE(frame)
    -- KLCOUNT_UPDATE(frame)

end

function KLCOUNT_TIME_UPDATE(frame)
    local time = imcTime.GetAppTimeMS() - g.starttime
    local h = math.floor(time / (60 * 60 * 1000))
    local m = math.floor((time / (60 * 1000)) % 60)
    local s = math.floor((time / 1000) % 60)
    local timer = GET_CHILD_RECURSIVELY(frame, "timer_text")
    timer:SetText(string.format("{s16}%02d:%02d:%02d{/}", h, m, s))

end

function KLCOUNT_UPDATE(frame)
    --[[if g.IsTargetMap() == false then
        return
    end]]
    local countText = GET_CHILD_RECURSIVELY(frame, "count_text")
    g.count = g.count + 1
    countText:SetText(string.format("{s16}KLCounter : %d{/}", g.count))

end

-- 対象マップか判定。対象マップtrue、対象外マップfalse
function g.IsTargetMap()
    local mapID = _G.session.GetMapID()
    for i = 1, #targetmap do
        if mapID == targetmap[i] then
            return true
        end
    end
    return false
end

function g.GetMapName()
    local mapID = _G.session.GetMapID()
    return _G.GetClassByType("Map", mapID).Name
end
