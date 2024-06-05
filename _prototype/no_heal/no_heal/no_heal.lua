-- v1.0.0 とりあえず作った。
-- v1.0.1 いつものバグ修正。BUFF_REMOVEの際の挙動修正。
-- v1.0.2 richtextがslotに書き換わってた。なんでや妖精か？？
local addonName = "no_heal"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.0.2"

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
    addon:RegisterMsg('BUFF_UPDATE', 'no_heal_delete_buff');

    addon:RegisterMsg('BUFF_ADD', 'no_heal_notice_buff');
    addon:RegisterMsg('BUFF_UPDATE', 'no_heal_notice_buff');
    addon:RegisterMsg('BUFF_REMOVE', 'no_heal_notice_buff');
    -- addon:RegisterMsg('FPS_UPDATE', 'no_heal_notice_buff');

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
            fx = 500,
            fy = 400,
            buffid = {}
        } -- 新しく追加
    else
        g.settings = settings
    end

    no_heal_save_settings()
end

function no_heal_get_buff()

    local handle = session.GetMyHandle()
    local buffframe = ui.GetFrame("buff")

    local buffslot = GET_CHILD_RECURSIVELY(buffframe, "buffslot")
    local buffslotcount = buffslot:GetChildCount()

    local bufftbl = {}
    local cnt = 0
    for i = 0, buffslotcount - 1 do
        local child = buffslot:GetChildByIndex(i)
        local icon = child:GetIcon()
        local iconinfo = icon:GetInfo()
        local clsid = iconinfo.type
        if clsid == 0 then
            break
        end
        for _, id in ipairs(g.settings.buffid) do
            if tostring(clsid) == tostring(id) then
                cnt = cnt + 1
                table.insert(bufftbl, id)
            end
        end
    end

    local buffcountslot = GET_CHILD_RECURSIVELY(buffframe, "buffcountslot")
    local buffcountslotcount = buffcountslot:GetChildCount()

    for i = 0, buffcountslotcount - 1 do
        local child = buffcountslot:GetChildByIndex(i)
        local icon = child:GetIcon()
        local iconinfo = icon:GetInfo()
        local clsid = iconinfo.type
        if clsid == 0 then
            break
        end
        for _, id in ipairs(g.settings.buffid) do
            -- print(tostring(clsid) .. ":" .. tostring(id))
            if tostring(clsid) == tostring(id) then
                cnt = cnt + 1
                table.insert(bufftbl, id)
            end
        end
    end

    local buffcountslot_sub = GET_CHILD_RECURSIVELY(buffframe, "buffcountslot_sub")
    local buffcountslotsubcount = buffcountslot_sub:GetChildCount()

    for i = 0, buffcountslotsubcount - 1 do
        local child = buffcountslot_sub:GetChildByIndex(i)
        local icon = child:GetIcon()
        local iconinfo = icon:GetInfo()
        local clsid = iconinfo.type
        if clsid == 0 then
            break
        end
        for _, id in ipairs(g.settings.buffid) do
            if tostring(clsid) == tostring(id) then
                cnt = cnt + 1
                table.insert(bufftbl, id)
            end
        end
    end
    return bufftbl, cnt

end

function no_heal_notice_buff(frame, msg, argStr, argNum)

    if g.settings.use ~= 1 then
        return
    end

    local bufftbl, cnt = no_heal_get_buff()

    local noticeframe = ui.CreateNewFrame("chat_memberlist", "noticeframe", 0, 0, 10, 10)
    AUTO_CAST(noticeframe)

    noticeframe:SetSkinName("shadow_box")
    noticeframe:SetTitleBarSkin("None")
    noticeframe:SetAlpha(50)
    noticeframe:SetLayerLevel(89)
    noticeframe:EnableHitTest(1)
    noticeframe:EnableMove(1)

    noticeframe:SetPos(g.settings.fx, g.settings.fy)
    noticeframe:SetEventScript(ui.LBUTTONUP, "no_heal_noticeframe_move")

    local slotset = noticeframe:CreateOrGetControl("slotset", "slotset", 0, 10, 0, 0)
    AUTO_CAST(slotset)

    slotset:ClearIconAll()
    slotset:SetMaxSelectionCount(1)
    slotset:SetSlotSize(30, 30)
    slotset:SetSkinName("None")
    slotset:SetColRow(cnt, 1)
    slotset:CreateSlots()

    if cnt == 0 then
        return
    end

    for i = 1, cnt do
        local slot = GET_CHILD(slotset, "slot" .. i)
        AUTO_CAST(slot)
        if slot ~= nil then
            local id = bufftbl[i] -- ループごとに異なるバフIDを取得する
            local buff = GetClassByType("Buff", id)
            if buff ~= nil then
                slot:SetEventScript(ui.RBUTTONUP, "no_heal_delete_buff")
                slot:SetEventScriptArgNumber(ui.RBUTTONUP, id)
                slot:SetEventScriptArgString(ui.RBUTTONUP, slot:GetName())

                local imageName = GET_BUFF_ICON_NAME(buff)
                SET_SLOT_ICON(slot, imageName)

            end
        end
    end
    noticeframe:Resize(cnt * 40 + 10, 50)
    noticeframe:ShowWindow(1)

end

function no_heal_frame_init(frame, ctrl, argStr, argNum)
    local frame = ui.GetFrame("no_heal")

    frame:SetSkinName("None")
    frame:Resize(60, 50)
    frame:SetPos(g.settings.x, g.settings.y)
    frame:SetTitleBarSkin("None")
    frame:EnableHittestFrame(1);
    frame:EnableMove(1)
    frame:SetLayerLevel(61)
    frame:SetEventScript(ui.LBUTTONUP, "no_heal_frame_move")
    frame:SetEventScript(ui.RBUTTONUP, "no_heal_test")

    local btn = frame:CreateOrGetControl("button", "btn", 5, 5, 50, 30)
    AUTO_CAST(btn)

    if g.settings.use == 0 then
        btn:SetSkinName("test_gray_button");
        btn:SetText("{ol}{s14}OFF")
        btn:SetEventScript(ui.LBUTTONUP, "no_heal_toggle");
        btn:SetEventScriptArgNumber(ui.LBUTTONUP, g.settings.use);
        btn:SetTextTooltip("{ol}Noheal suspended{nl}" ..
                               "Left-click on a buff attached to you with ON to register it.{nl}" ..
                               "Right-click to setting")
    elseif g.settings.use == 1 then
        btn:SetSkinName("test_red_button")
        btn:SetText("{ol}{s14}ON")
        btn:SetEventScript(ui.LBUTTONUP, "no_heal_toggle");
        btn:SetEventScriptArgNumber(ui.LBUTTONUP, g.settings.use);
        btn:SetTextTooltip("{ol}Noheal in operation{nl}" ..
                               "Left-click on a buff attached to you with ON to register it.{nl}" ..
                               "Right-click to setting")
    else
        btn:SetSkinName("baseyellow_btn")
        btn:SetText("{ol}{s14}ON")
        btn:SetEventScript(ui.LBUTTONUP, "no_heal_toggle");
        btn:SetEventScriptArgNumber(ui.LBUTTONUP, g.settings.use);
        btn:SetTextTooltip("{ol}Noheal in auto operation{nl}" ..
                               "Left-click on a buff attached to you with ON to register it.{nl}" ..
                               "Right-click to setting")
    end
    btn:SetEventScript(ui.RBUTTONUP, "no_heal_setting_frame");

    if MUTEKI2_SET_BUFFICON_LBTNCLICK then
        g.SetupHook(no_heal_MUTEKI2_ADD_BUFFID, "MUTEKI2_ADD_BUFFID")

    end
    frame:ShowWindow(1)
end

function no_heal_setframe_close(frame)
    frame:ShowWindow(0)
end

function no_heal_auto_check(frame)
    local check = frame:CreateOrGetControl("checkbox", "check", 200, 5, 20, 20)
    AUTO_CAST(check)
    check:SetEventScript(ui.LBUTTONUP, "no_heal_auto")

    if g.settings.use == 9 then
        check:SetCheck(1)
    else
        check:SetCheck(0)
    end

end

function no_heal_auto(frame, ctrl)
    local ischeck = ctrl:IsChecked()
    local nhframe = ui.GetFrame("no_heal")
    local btn = GET_CHILD_RECURSIVELY(nhframe, "btn")
    local text = btn:GetText()

    if ischeck == 1 then
        g.settings.use = 9
        btn:SetSkinName("baseyellow_btn")
        btn:SetText("{ol}{s14}ON")
        btn:SetEventScript(ui.LBUTTONUP, "no_heal_toggle");
        btn:SetEventScriptArgNumber(ui.LBUTTONUP, g.settings.use);
        btn:SetTextTooltip("{ol}Noheal in auto operation")

    elseif ischeck == 0 and text == "{ol}{s14}ON" then

        g.settings.use = 1
        btn:SetSkinName("test_red_button")
    elseif ischeck == 0 and text == "{ol}{s14}OFF" then

        g.settings.use = 0
        btn:SetSkinName("test_gray_button")
    end
    no_heal_save_settings()
end

function no_heal_setting_frame()

    local setframe = ui.CreateNewFrame("chat_memberlist", "setframe", 0, 0, 10, 10)
    AUTO_CAST(setframe)
    setframe:RemoveAllChild();
    setframe:SetPos(400, 100)
    setframe:SetEventScript(ui.RBUTTONUP, "no_heal_auto_check")

    local close = setframe:CreateOrGetControl("button", "close", 0, 0, 20, 20)
    AUTO_CAST(close)
    close:SetImage("testclose_button")
    close:SetGravity(ui.RIGHT, ui.TOP)
    close:SetEventScript(ui.LBUTTONUP, "no_heal_setframe_close")

    local y = 30
    for i, id in ipairs(g.settings.buffid) do

        local slot = setframe:CreateOrGetControl("slot", "slot" .. i, 10, y, 50, 50)
        AUTO_CAST(slot)
        slot:EnablePop(0)
        slot:EnableDrop(0)
        slot:EnableDrag(0)
        slot:SetSkinName('invenslot2');

        local buffname = setframe:CreateOrGetControl("richtext", "buffname" .. i, 60, y, 150, 25)
        AUTO_CAST(buffname)

        local buffid = setframe:CreateOrGetControl("richtext", "buffid" .. i, 60, y + 25, 150, 25)
        AUTO_CAST(buffid)

        local delete = setframe:CreateOrGetControl("button", "delete" .. i, 220, y + 15, 30, 30)
        AUTO_CAST(delete)

        local buff = GetClassByType("Buff", id);
        local imageName = GET_BUFF_ICON_NAME(buff);
        SET_SLOT_ICON(slot, imageName)

        local icon = CreateIcon(slot)
        AUTO_CAST(icon)
        icon:SetTooltipType('buff');
        icon:SetTooltipArg(buff.Name, id, 0);

        slot:Invalidate();

        buffname:SetText("{ol}" .. buff.Name)
        buffname:AdjustFontSizeByWidth(150)

        buffid:SetText("{ol}" .. id)

        delete:SetSkinName("test_red_button")
        delete:SetText("{ol}×")
        delete:SetEventScript(ui.LBUTTONUP, "no_heal_remove_table")
        delete:SetEventScriptArgNumber(ui.LBUTTONUP, id)
        y = y + 55
    end
    if y == 30 then
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
            no_heal_save_settings()
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
            no_heal_setting_frame()
            return
        end
        for _, id in ipairs(g.settings.buffid) do
            if id ~= buffid then
                table.insert(g.settings.buffid, buffid)
                ui.SysMsg(argStr .. " Registered.")
                no_heal_save_settings()
                no_heal_setting_frame()
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
    elseif g.settings.use == 1 then
        local buffid = argNum

        for _, id in ipairs(g.settings.buffid) do

            if tostring(id) == tostring(buffid) then

                local noticeframe = ui.GetFrame("noticeframe")
                local slot = GET_CHILD_RECURSIVELY(noticeframe, argStr)

                if slot ~= nil then
                    REMOVE_BUF(frame, _, argStr, buffid)
                    ReserveScript("no_heal_notice_buff()", 0.3)
                    -- ReserveScript(string.format("no_heal_icon_clear('%s')", argStr), 0.3)
                    return
                end

            end
        end
    elseif g.settings.use == 9 then
        local buffid = argNum

        for _, id in ipairs(g.settings.buffid) do

            if tostring(id) == tostring(buffid) then

                REMOVE_BUF(frame, _, argStr, buffid)

            end
        end
    end
end

function no_heal_icon_clear(argStr)
    local noticeframe = ui.GetFrame("noticeframe")
    local slot = GET_CHILD_RECURSIVELY(noticeframe, argStr)

    slot:ClearIcon()
end

function no_heal_noticeframe_move(frame)

    if g.settings.fx ~= frame:GetX() or g.settings.fy ~= frame:GetY() then
        g.settings.fx = frame:GetX()
        g.settings.fy = frame:GetY()
        no_heal_save_settings()
        return
    end

end

function no_heal_frame_move(frame)

    if g.settings.x ~= frame:GetX() or g.settings.y ~= frame:GetY() then
        g.settings.x = frame:GetX()
        g.settings.y = frame:GetY()
        no_heal_save_settings()
        return
    end
end

