-- v1.0.0 とりあえず作った。自動デリートは隠しコードにしよかな
local addonName = "no_heal"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.0.0"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

local muteki = _G["ADDONS"]["WRIT"]["MUTEKI2EX"];

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

function NO_HEAL_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame

    addon:RegisterMsg("GAME_START", "no_heal_load_settings")
    addon:RegisterMsg("GAME_START", "no_heal_frame_init")
    addon:RegisterMsg('BUFF_ADD', 'no_heal_delete_buff');
    addon:RegisterMsg('BUFF_ADD', 'no_heal_notice_buff');
    addon:RegisterMsg('BUFF_UPDATE', 'no_heal_notice_buff');
    addon:RegisterMsg('BUFF_REMOVE', 'no_heal_notice_buff');
    acutil.setupEvent(addon, 'SET_BUFF_SLOT', "no_heal_bufficon_lbtn")

end

function no_heal_save_settings()

    acutil.saveJSON(g.settingsFileLoc, g.settings)
end

function no_heal_load_settings()

    local settings, err = acutil.loadJSON(g.settingsFileLoc, g.settings)
    if err then
        -- 設定ファイル読み込み失敗時処理
        CHAT_SYSTEM(string.format("[%s] cannot load setting files", addonNameLower))
    end
    if not settings then

        g.settings = {
            use = 0,
            x = 500,
            y = 30,
            buffid = {}
        } -- 新しく追加
    else
        g.settings = settings
    end

    no_heal_save_settings()
end

function no_heal_notice_buff(frame, msg, argStr, argNum)
    if g.settings.use == 0 then
        return
    else
        local noticeframe = ui.CreateNewFrame("shadow_box", "noticeframe", 0, 0, 10, 10)
        AUTO_CAST(noticeframe)
        noticeframe:ShowWindow(1)
        noticeframe:EnableHitTest(1)
        noticeframe:EnableMove(1)
        noticeframe:Resize(#g.settings.buffid * 40 + 10, 50)
        noticeframe:SetAlpha(30)
        noticeframe:SetLayerLevel(89)
        noticeframe:SetTitleBarSkin("shadow_box")
        noticeframe:RemoveAllChild();
        -- noticeframe:SetPos(400, 100)

        local slotset = noticeframe:CreateOrGetControl("slotset", "slotset", 0, 0, 0, 0)
        AUTO_CAST(slotset)

        slotset:SetMaxSelectionCount(1)
        local buffid = argNum
        for i = 1, #g.settings.buffid do
            for _, id in ipairs(g.settings.buffid) do
                if id == buffid then
                    local buff = GetClassByType("Buff", id);
                    slotset:SetColRow(i, 1)
                    slotset:SetSlotSize(40, 40)
                    slotset:SetSkinName("slot");
                    slotset:CreateSlots()
                    local slot = slotset:GetSlotByIndex(i - 1);
                    slot:SetImage(buff.Icon)
                    slot:SetEventScript(ui.RBUTTONUP, "no_heal_delete_buff")
                    slot:SetEventScriptArgNumber(ui.RBUTTONUP, id)
                end

            end
        end

    end
end

function no_heal_frame_init(frame, ctrl, argStr, argNum)
    local frame = ui.GetFrame("no_heal")
    local btn = frame:CreateOrGetControl("button", "btn", 5, 5, 50, 30)
    AUTO_CAST(btn)
    frame:SetSkinName("None")
    frame:Resize(60, 50)
    frame:SetPos(g.settings.x, g.settings.y)
    frame:SetTitleBarSkin("None")
    frame:EnableHittestFrame(1);
    frame:EnableMove(1)
    frame:SetLayerLevel(61)
    frame:SetEventScript(ui.LBUTTONUP, "no_heal_frame_move")
    if g.settings.use == 0 then
        btn:SetSkinName("test_gray_button");
        btn:SetText("{ol}{s14}ON")
        btn:SetEventScript(ui.LBUTTONUP, "no_heal_toggle");
        btn:SetEventScriptArgNumber(ui.LBUTTONUP, g.settings.use);
    else
        btn:SetSkinName("test_red_button")
        btn:SetText("{ol}{s14}OFF")
        btn:SetEventScript(ui.LBUTTONUP, "no_heal_toggle");
        btn:SetEventScriptArgNumber(ui.LBUTTONUP, g.settings.use);
    end
    btn:SetEventScript(ui.RBUTTONUP, "no_heal_setting_frame");

    if MUTEKI2_SET_BUFFICON_LBTNCLICK then
        acutil.setupHook(no_heal_MUTEKI2_ADD_BUFFID, "MUTEKI2_ADD_BUFFID")

    end
    frame:ShowWindow(1)
end

function no_heal_setframe_close(frame)
    frame:ShowWindow(0)
end

function no_heal_setting_frame()

    local setframe = ui.CreateNewFrame("chat_memberlist", "setframe", 0, 0, 10, 10)
    AUTO_CAST(setframe)
    setframe:RemoveAllChild();
    setframe:SetPos(400, 100)

    local close = setframe:CreateOrGetControl("button", "close", 0, 0, 20, 20)
    AUTO_CAST(close)
    close:SetImage("testclose_button")
    close:SetGravity(ui.RIGHT, ui.TOP)
    close:SetEventScript(ui.LBUTTONUP, "no_heal_setframe_close")

    local y = 10
    for i, id in ipairs(g.settings.buffid) do
        local slot = setframe:CreateOrGetControl("slot", "slot" .. i, 10, y, 50, 50)
        AUTO_CAST(slot)
        slot:EnablePop(0)
        slot:EnableDrop(0)
        slot:EnableDrag(0)
        slot:SetSkinName('invenslot2');
        local buffname = setframe:CreateOrGetControl("slot", "buffname" .. i, 60, y, 150, 25)
        AUTO_CAST(buffname)
        local buffidControl = setframe:CreateOrGetControl("slot", "buffid" .. i, 60, y + 25, 150, 25)
        AUTO_CAST(buffidControl)
        local delete = setframe:CreateOrGetControl("button", "delete" .. i, 220, y + 10, 30, 30)
        AUTO_CAST(delete)

        local buff = GetClassByType("Buff", id);
        -- local imageName = GET_BUFF_ICON_NAME(buff);
        -- SET_SLOT_ICON(slot, imageName)
        local icon = CreateIcon(slot)
        AUTO_CAST(icon)
        icon:SetImage(buff.Icon)
        icon:SetTooltipType('buff');
        -- local bicon = slot:GetIcon();
        -- local handle = bicon:GetTooltipStrArg();
        ---local buffType = bicon:GetTooltipNumArg();
        icon:SetTooltipArg(buff.Name, id, 0);
        slot:Invalidate();
        -- icon:SetTextTooltip(buff.Name)
        buffname:SetText("{ol}" .. buff.Name)
        buffname:AdjustFontSizeByWidth(150)
        buffidControl:SetText("{ol}" .. id)
        delete:SetSkinName("test_red_button")
        delete:SetText("{ol}×")
        delete:SetEventScript(ui.LBUTTONUP, "no_heal_remove_table")
        delete:SetEventScriptArgNumber(ui.LBUTTONUP, id)
        y = y + 55
    end
    if y == 10 then
        setframe:Resize(260, y + 60)
    else
        setframe:Resize(260, y + 5)
    end
    setframe:ShowWindow(1)
end

function no_heal_remove_table(frame, ctrl, argStr, argNum)

    for i, id in ipairs(g.settings.buffid) do
        if id == argNum then
            table.remove(g.settings.buffid, i)
            no_heal_setting_frame()
            return
        end
    end
end

function no_heal_bufficon_lbtn(frame, eventMsg)
    local slot, capt, class, buffType = acutil.getEventArgs(eventMsg)
    tolua.cast(slot, 'ui::CSlot')
    slot:SetEventScript(ui.LBUTTONUP, 'no_heal_MUTEKI2_ADD_BUFFID');
    slot:SetEventScriptArgNumber(ui.LBUTTONUP, buffType);
    slot:SetEventScriptArgString(ui.LBUTTONUP, class.Name);
end

local serviceNation = config.GetServiceNation()
local function _translate(key)
    local localization = muteki.translations[serviceNation] or muteki.translations["GLOBAL"]
    return localization[key] or "Translation not provided"
end

function no_heal_MUTEKI2_ADD_BUFFID(frame, control, argStr, buffid)

    if g.settings.use == 0 then

        if not muteki.settings.buffList[tostring(buffid)] then

            local buffObj = GetClassByType('Buff', buffid)
            local defaultColor = "FFCCCC22"
            muteki.settings.buffList[tostring(buffid)] = {
                color = defaultColor,
                isNotNotify = {}
            }

            ui.SysMsg(string.format(_translate('addBuff'), buffObj.Name))
            MUTEKI2_UPDATE_POSITIONS()
            MUTEKI2_UPDATE_CONTROL(buffid)
            MUTEKI2_CREATE_SETTING_FRAME()
        end
    else
        if #g.settings.buffid == 0 then
            table.insert(g.settings.buffid, buffid)
            ui.SysMsg(argStr .. " Registered.")
            no_heal_save_settings()
            return
        end
        for _, id in ipairs(g.settings.buffid) do
            if id ~= buffid then
                table.insert(g.settings.buffid, buffid)
                ui.SysMsg(argStr .. " Registered.")
                no_heal_save_settings()
                return
            end
        end
    end
end

function no_heal_toggle(frame, ctrl, argStr, argNum)

    if argNum == 0 then
        g.settings.use = 1
    else
        g.settings.use = 0
    end
    no_heal_save_settings()
    no_heal_frame_init(frame, ctrl, argStr, argNum)
end

function no_heal_delete_buff(frame, msg, argStr, argNum)
    if g.settings.use == 0 then
        return
    else
        local buffid = argNum
        for _, id in ipairs(g.settings.buffid) do

            if id == buffid then
                REMOVE_BUF(frame, _, argStr, buffid)
                return
            end
        end
    end
end

function no_heal_frame_move(frame)

    if g.settings.x ~= frame:GetX() or g.settings.y ~= frame:GetY() then
        g.settings.x = frame:GetX()
        g.settings.y = frame:GetY()
        no_heal_save_settings()
    end
end

