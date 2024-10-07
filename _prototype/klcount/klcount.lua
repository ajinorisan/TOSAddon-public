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

local target_map_id = {11239, -- 1F
11242, -- 2F
11244 -- 3F
}

g.ischecked = 0

function KLCOUNT_SAVE_SETTINGS()

    acutil.saveJSON(g.settingsFileLoc, g.settings);
end

function KLCOUNT_LOADSETTINGS()

    local settings, err = acutil.loadJSON(g.settingsFileLoc, g.settings)

    if not settings then
        settings = {
            frame_x = 1500,
            frame_y = 20
        }
    end

    g.settings = settings
    KLCOUNT_SAVE_SETTINGS()
end

function KLCOUNT_INIT_FRAME()
    local frame = _G.ui.GetFrame("klcount")

    frame:ShowWindow(1)
    frame:EnableHitTest(1)
    frame:EnableMove(1)
    frame:Resize(170, 95)

    frame:SetPos(g.settings.frame_x, g.settings.frame_y)

    frame:SetAlpha(80)
    frame:SetLayerLevel(31)
    frame:SetTitleBarSkin("shadow_box")
    frame:SetEventScript(ui.LBUTTONUP, "KLCOUNT_POSITION_SETTING")

    g.count = 0
    g.start_time = imcTime.GetAppTimeMS()

    local count_text = frame:CreateOrGetControl("richtext", "count_text", 10, 10, 200, 30)
    count_text:SetText(string.format("{ol}{s16}KLCounter : %d{/}", g.count))

    local map_name = g.GetMapName()
    local map_text = frame:CreateOrGetControl("richtext", "map_text", 10, 35, 200, 30)
    map_text:SetText(string.format("{s16}%s{/}", map_name))

    local timer_text = frame:CreateOrGetControl("richtext", "timer_text", 90, 60, 200, 30)
    local h = 0
    local m = 0
    local s = 0
    timer_text:SetText(string.format("{ol}{s16}%02d:%02d:%02d{/}", h, m, s))
    frame:RunUpdateScript("KLCOUNT_TIME_UPDATE", 1.0)
end

function KLCOUNT_TIME_UPDATE(frame)
    local time = imcTime.GetAppTimeMS() - g.start_time
    local h = math.floor(time / (60 * 60 * 1000))
    local m = math.floor((time / (60 * 1000)) % 60)
    local s = math.floor((time / 1000) % 60)
    local timer_text = GET_CHILD_RECURSIVELY(frame, "timer_text")
    timer_text:SetText(string.format("{ol}{s16}%02d:%02d:%02d{/}", h, m, s))
    return 1
end

function KLCOUNT_POSITION_SETTING(frame)

    g.settings.frame_x = frame:GetX()
    g.settings.frame_y = frame:GetY()
    KLCOUNT_SAVE_SETTINGS()
end

function KLCOUNT_UPDATE(frame)

    local count_text = GET_CHILD_RECURSIVELY(frame, "count_text")
    g.count = g.count + 1
    count_text:SetText(string.format("{ol}{s16}KLCounter : %d{/}", g.count))

end

function g.IsTargetMap()
    local map_id = _G.session.GetMapID()
    for i = 1, #target_map_id do
        if map_id == target_map_id[i] then
            return true
        end
    end
    return false
end

function g.GetMapName()
    local map_id = _G.session.GetMapID()
    return _G.GetClassByType("Map", map_id).Name
end

function _G.KLCOUNT_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame

    local pc = GetMyPCObject();
    local curMap = GetZoneName(pc)
    local mapCls = GetClass("Map", curMap)

    if mapCls.MapType == "Field" or mapCls.MapType == "Dungeon" then
        addon:RegisterMsg("GAME_START", "KLCOUNT_INIT_FRAME")
        addon:RegisterMsg("EXP_UPDATE", "KLCOUNT_UPDATE")
    end

    if g.IsTargetMap() == true then
        frame:SetEventScript(ui.RBUTTONUP, "KLCOUNT_CHECKBOX_OPEN")
        addon:RegisterMsg('BUFF_ADD', 'KLCOUNT_BUFF_ADD');
    end

    KLCOUNT_LOADSETTINGS()
end

function KLCOUNT_BUFF_ADD(frame, msg, str, num)

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

    local slotCount = 40
    if g.ischecked == 1 then

        for i = 0, slotCount - 1 do
            local slot = tolua.cast(frame:GetChildRecursively("slot" .. i + 1), "ui::CSlot")
            if slot and slot:GetIcon() then
                local iconInfo = slot:GetIcon():GetInfo()

                local iconName = iconInfo:GetImageName()
                if iconName == "icon_common_relic_release" and buff ~= nil then
                    local icon = tolua.cast(frame:GetChildRecursively("slot" .. i + 1), "ui::CSlot"):GetIcon()

                    ICON_USE(icon)
                    return
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

end

function KLCOUNT_ISCHECKED(frame)

    local checkbox = GET_CHILD_RECURSIVELY(frame, "checkbox")
    local ischeck = checkbox:IsChecked()

    if ischeck == 1 then
        g.ischecked = 1
        CHAT_SYSTEM("Automatic relic off")
        ReserveScript("KLCOUNT_CHECKBOX_CLOSE()", 5.0)
    elseif ischeck == 0 then
        g.ischecked = 0
        ReserveScript("KLCOUNT_CHECKBOX_CLOSE()", 5.0)
    end

end

function KLCOUNT_CHECKBOX_CLOSE()
    local frame = ui.GetFrame(addonNameLower)
    local checkbox = GET_CHILD_RECURSIVELY(frame, "checkbox")
    checkbox:ShowWindow(0)
end

