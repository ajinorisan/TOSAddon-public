local addonName = "SKILL_SLOT_NOTICE"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.0.0"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)

local acutil = require("acutil")
local json = require('json')

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

function SKILL_SLOT_NOTICE_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame
    g.settings = g.settings or {}

    -- skill_notice_load_settings()
    -- addon:RegisterMsg('GAME_START', "skill_slot_notice_frame_init")
    -- addon:RegisterMsg('GAME_START_3SEC', "skill_slot_notice_frame_update")

end

function skill_slot_notice_frame_update(frame)
    frame:RemoveAllChild()
    local slotset = frame:CreateOrGetControl("slotset", "slotset", 0, 10, 0, 0)
    AUTO_CAST(slotset)

    local bufftable = {4483}
    local skilltable = {51712} -- 51712:ロシアンルーレット

    local cnt = #bufftable + #skilltable

    slotset:ClearIconAll()
    slotset:SetMaxSelectionCount(1)
    slotset:SetSlotSize(50, 50)
    slotset:SetSkinName("None")
    slotset:SetColRow(2, 1)
    slotset:CreateSlots()

    local skill1 = GetClassByType("Skill", skilltable[1])
    local slot2 = GET_CHILD(slotset, "slot2")
    AUTO_CAST(slot2)
    local iconname = TryGetProp(skill1, "Icon", "None")
    local icon = CreateIcon(slot2);
    AUTO_CAST(icon)
    iconname = "icon_" .. iconname
    SET_SLOT_ICON(slot2, iconname)

    local totalTime = 0;
    local curTime = 0;
    local skl = session.GetSkill(skilltable[1]);
    if skl ~= nil then
        curTime = skl:GetCurrentCoolDownTime();
        totalTime = skl:GetTotalCoolDownTime();
    end
    local gauge = slot2:CreateOrGetControl("gauge", "gauge", 0, 0, 50, 50)
    AUTO_CAST(gauge)
    gauge:SetSkinName("dot_skillslot")
    gauge:SetPoint(curTime / 1000);
    gauge:AddStat(string.format('{ol}{s25}%.1f', curTime / 1000))
    gauge:SetStatFont(0, 'quickiconfont');
    gauge:SetStatOffset(0, 0, 0);
    gauge:SetStatAlign(0, ui.CENTER_HORZ, ui.CENTER_VERT);
    if curTime == 0 then
        icon:SetColorTone("FFFFFFFF")
        gauge:SetStatOffset(0, 50, 0)
    else

        icon:SetColorTone("FF111111")
    end

    local slot = GET_CHILD(slotset, "slot1")
    AUTO_CAST(slot)

    local buff = GetClassByType("Buff", bufftable[1])
    local handle = session.GetMyHandle();
    local time = info.GetBuff(handle, bufftable[1]):GetCurrentCoolDownTime();
    print(tostring(time))
    local imageName = GET_BUFF_ICON_NAME(buff)
    SET_SLOT_ICON(slot, imageName)

    local bvframe = ui.GetFrame("buff_visibility")
    local Violent_stack_value = GET_CHILD_RECURSIVELY(bvframe, "Violent_stack_value")
    if Violent_stack_value ~= nil then
        local value = string.gsub(Violent_stack_value:GetText(), "{@st41b}{s14}", "")
        local count = slot:CreateOrGetControl("richtext", "count", 12, 0, 40, 40)
        AUTO_CAST(count)
        count:SetText("{ol}{s40}" .. value)
    else
        local count = slot:CreateOrGetControl("richtext", "count", 12, 0, 40, 40)
        AUTO_CAST(count)
        count:SetText("{ol}{s40}0")
    end

    frame:Resize(cnt * 50 + 10, 60)
    frame:ShowWindow(1)

    return 1

end

function skill_notice_load_settings()

    local settings, err = acutil.loadJSON(g.settingsFileLoc, g.settings)
    if err then
        -- 設定ファイル読み込み失敗時処理
        CHAT_SYSTEM(string.format("[%s] cannot load setting files", addonNameLower))
    end

    if not settings then

        settings = {}

    end

    g.settings = settings

    local LoginName = session.GetMySession():GetPCApc():GetName()
    if g.settings[LoginName] == nil then
        g.settings[LoginName] = {
            framex = 900,
            framey = 400
        }
    end

    skill_slot_notice_save_settings()
end

function skill_slot_notice_save_settings()
    acutil.saveJSON(g.settingsFileLoc, g.settings)
end

function skill_slot_notice_end_drag(frame, ctrl, argStr, argNum)

    g.settings.framex = frame:GetX();
    g.settings.framey = frame:GetY();

    skill_slot_notice_save_settings()
end

function skill_slot_notice_frame_init(frame)

    local LoginName = session.GetMySession():GetPCApc():GetName()

    frame:SetSkinName("chat_window")
    frame:SetTitleBarSkin("None")
    frame:SetAlpha(30)
    frame:SetLayerLevel(61)
    frame:EnableHitTest(1)
    frame:EnableMove(1)
    print(tostring(frame:GetName()))
    frame:SetPos(g.settings[LoginName].framex, g.settings[LoginName].framey)
    frame:SetEventScript(ui.LBUTTONUP, "skill_slot_notice_end_drag")
    frame:Resize(60, 60)
    frame:ShowWindow(1)
    frame:RunUpdateScript("skill_slot_notice_frame_update", 0.1);
end
