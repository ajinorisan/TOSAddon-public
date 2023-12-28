-- v1.0.0 indun_panelから機能独立
local addonName = "indun_list_viewer"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.0.0"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)

local acutil = require("acutil")
local os = require("os")
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

function indun_list_viewer_save_settings()

    acutil.saveJSON(g.settingsFileLoc, g.settings);

end

function indun_list_viewer_load_settings()

    local settings, err = acutil.loadJSON(g.settingsFileLoc, g.settings)

    if err then
        -- 設定ファイル読み込み失敗時処理
        CHAT_SYSTEM(string.format("[%s] cannot load setting files", addonNameLower))
    end
    if not settings then
        settings = g.settings
    end

    g.settings = settings

end

if not g.loaded then
    g.settings = {
        raid_reset_time = 1702846800
    }
end

function INDUN_LIST_VIEWER_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame

    if not g.loaded then
        g.loaded = true
    end

    indun_list_viewer_load_settings()

    local pc = GetMyPCObject();
    local curMap = GetZoneName(pc)
    local mapCls = GetClass("Map", curMap)
    if mapCls.MapType == "City" then

        addon:RegisterMsg('GAME_START_3SEC', "indun_list_viewer_raid_reset_time") -- !!
        addon:RegisterMsg('GAME_START', "indun_list_viewer_frame_init")
        addon:RegisterMsg("BUFF_ADD", "indun_list_viewer_autosweep_save");
        addon:RegisterMsg("BUFF_UPDATE", "indun_list_viewer_autosweep_save");
        addon:RegisterMsg("BUFF_REMOVE", "indun_list_viewer_autosweep_save");
        -- addon:RegisterMsg("FPS_UPDATE", "indun_list_viewer_autosweep_save");

    end

end

function indun_list_viewer_autosweep_save(frame, msg, argStr, argNum)

    -- print(msg)
    -- print(tostring(argNum))
    local buffid = tostring(argNum)
    local LoginName = session.GetMySession():GetPCApc():GetName()
    -- g.settings[LoginName].buffid = {}
    -- indun_list_viewer_save_settings()
    if buffid ~= (tostring(80015) or tostring(80016) or tostring(80017) or tostring(80030) or tostring(80031)) then
        -- print(tostring(argNum .. "owata"))
        return
    end
    if msg == "BUFF_UPDATE" then
        local handle = session.GetMyHandle()
        local buffframe = ui.GetFrame("buff")
        local buffslotset = GET_CHILD_RECURSIVELY(buffframe, "buffslot")
        local buffslotcount = buffslotset:GetChildCount()
        local sweepcount = 0
        for i = 0, buffslotcount - 1 do
            local child = buffslotset:GetChildByIndex(i)
            local icon = child:GetIcon()
            local iconinfo = icon:GetInfo()

            if buffid == tostring(iconinfo.type) then
                local buff = info.GetBuff(handle, iconinfo.type)

                sweepcount = buff.over

                g.settings[LoginName].buffid[buffid] = sweepcount

            end

        end

    elseif msg == "BUFF_REMOVE" then
        local sweepcount = 0
        g.settings[LoginName].buffid[buffid] = sweepcount

    end
    indun_list_viewer_save_settings()
    indun_list_viewer_load_settings()
end

function indun_list_viewer_frame_init()
    --[[local bgm_frame = ui.GetFrame("minimap_outsidebutton")
    bgm_frame:SetPos(1670, 280)
    -- bgm_frame:SetOffset(100, 0)
    bgm_frame:ShowWindow(1)]]

    local frame = ui.GetFrame("indun_list_viewer")
    frame:SetSkinName('None')
    frame:SetTitleBarSkin("None")
    frame:Resize(35, 35)
    -- frame:SetPos(1555, 305)
    frame:SetPos(665, 0)

    local btn = frame:CreateOrGetControl('button', 'btn', 0, 0, 35, 35)
    btn:SetSkinName("None")
    btn:SetText("{img sysmenu_sys 35 35}")
    btn:SetEventScript(ui.LBUTTONDOWN, "indun_list_viewer_title_frame_open")
    btn:SetTextTooltip(
        "{ol}Indun List Viewer{nl}キャラ毎のレイド回数表示{nl}Raid count display per character{nl}" ..
            "{@st45r14}※掃討はキャラ毎の最終ログイン時の値なので、期限切れなどで実際とは異なる場合があります。{nl}" ..
            "{@st45r14}※The AutoClear is the value at the last login for each character{nl}and may differ from the actual value due to expiration or other reasons.") -- !!

end

function indun_list_viewer_raid_reset_time()
    -- 現在の日時を取得
    local currentTime = os.time()

    if g.settings.raid_reset_time == nil then
        g.settings.raid_reset_time = 1702846800

    end

    -- 今日の曜日を取得 (0: 日曜日, 1: 月曜日, ..., 6: 土曜日)
    local currentWeekday = tonumber(os.date("%w", currentTime))

    -- 月曜日からの日数を計算
    local daysUntilMonday = (currentWeekday + 7 - 1) % 7

    -- 月曜日の朝6時の日時を計算
    local mondayAM6 = os.time({
        year = os.date("%Y", currentTime),
        month = os.date("%m", currentTime),
        day = os.date("%d", currentTime) - daysUntilMonday,
        hour = 6,
        min = 0,
        sec = 0
    })

    -- 月曜日からの経過秒数を計算
    local secondsSinceMondayAM6 = currentTime - g.settings.raid_reset_time
    print("indun_list_viewer 月曜日の朝6時から現在までの経過時間（秒）: " .. secondsSinceMondayAM6)

    local nextreset = 604800 -- 次の月曜日の6時までの秒数
    -- local nextreset = 295500 -- 次の月曜日の6時までの秒数

    if secondsSinceMondayAM6 > nextreset then
        g.settings.raid_reset_time = mondayAM6
        indun_list_viewer_save_settings()
        indun_list_viewer_load_settings()
        indun_list_viewer_raid_reset()

        return
    end

    indun_list_viewer_get_raid_count()

end

function indun_list_viewer_raid_reset()
    local accountInfo = session.barrack.GetMyAccount()
    local cnt = accountInfo:GetBarrackPCCount()
    for i = 0, cnt - 1 do
        local pcInfo = accountInfo:GetBarrackPCByIndex(i)
        local pcName = pcInfo:GetName()
        if g.settings[pcName].raid_count ~= nil then
            g.settings[pcName].raid_count = {}
        end
    end

    indun_list_viewer_save_settings()
    indun_list_viewer_load_settings()
    ui.SysMsg("Raid counts were initialized.{nl}" .. "レイドの回数を初期化しました。")
    indun_list_viewer_get_raid_count()

end

function indun_list_viewer_get_raid_count()

    if g.settings == nil then
        g.settings = {}
    end

    local accountInfo = session.barrack.GetMyAccount()
    local cnt = accountInfo:GetBarrackPCCount()
    for i = 0, cnt - 1 do

        local pcInfo = accountInfo:GetBarrackPCByIndex(i)
        local pcName = pcInfo:GetName()

        if g.settings[pcName] == nil then
            g.settings[pcName] = {}
        end

        if g.settings[pcName].raid_count == nil or next(g.settings[pcName].raid_count) == nil then
            g.settings[pcName].raid_count = {
                SlogutisH = 0,
                SlogutisN = 0,
                UpinisH = 0,
                UpinisN = 0,
                RozeH = 0,
                RozeN = 0,
                TurbulentH = 0,
                TurbulentN = 0
            }
        end

        local LoginName = session.GetMySession():GetPCApc():GetName()

        if tostring(LoginName) == tostring(pcName) then

            for key, value in pairs(g.settings[pcName].raid_count) do

                if key == "SlogutisH" then
                    g.settings[pcName].raid_count[key] = GET_CURRENT_ENTERANCE_COUNT(
                        GetClassByType("Indun", 690).PlayPerResetType)
                elseif key == "SlogutisN" then
                    g.settings[pcName].raid_count[key] = GET_CURRENT_ENTERANCE_COUNT(
                        GetClassByType("Indun", 688).PlayPerResetType)
                elseif key == "UpinisH" then
                    g.settings[pcName].raid_count[key] = GET_CURRENT_ENTERANCE_COUNT(
                        GetClassByType("Indun", 687).PlayPerResetType)
                elseif key == "UpinisN" then
                    g.settings[pcName].raid_count[key] = GET_CURRENT_ENTERANCE_COUNT(
                        GetClassByType("Indun", 685).PlayPerResetType)
                elseif key == "RozeH" then
                    g.settings[pcName].raid_count[key] = GET_CURRENT_ENTERANCE_COUNT(
                        GetClassByType("Indun", 681).PlayPerResetType)
                elseif key == "RozeN" then
                    g.settings[pcName].raid_count[key] = GET_CURRENT_ENTERANCE_COUNT(
                        GetClassByType("Indun", 679).PlayPerResetType)
                elseif key == "TurbulentH" then
                    g.settings[pcName].raid_count[key] = GET_CURRENT_ENTERANCE_COUNT(
                        GetClassByType("Indun", 678).PlayPerResetType)
                elseif key == "TurbulentN" then
                    g.settings[pcName].raid_count[key] = GET_CURRENT_ENTERANCE_COUNT(
                        GetClassByType("Indun", 676).PlayPerResetType)
                end

            end
        end
    end

    indun_list_viewer_save_settings()
    indun_list_viewer_load_settings()
    --
    indun_list_viewer_get_sweep_count()

end

function indun_list_viewer_get_sweep_count()

    local accountInfo = session.barrack.GetMyAccount()
    local cnt = accountInfo:GetBarrackPCCount()

    for i = 0, cnt - 1 do
        local pcInfo = accountInfo:GetBarrackPCByIndex(i)
        local pcName = pcInfo:GetName()
        -- print(tostring(pcName))
        local sweepbuff_table = {80015, 80016, 80017, 80030, 80031}
        for _, buffid in ipairs(sweepbuff_table) do
            if g.settings[pcName].buffid == nil then
                g.settings[pcName].buffid = {}
            end
            if g.settings[pcName].buffid[tostring(buffid)] == nil then

                g.settings[pcName].buffid[tostring(buffid)] = 0
            end
            local LoginName = session.GetMySession():GetPCApc():GetName()
            if LoginName == pcName then
                local handle = session.GetMyHandle()
                local buffframe = ui.GetFrame("buff")
                local buffslotset = GET_CHILD_RECURSIVELY(buffframe, "buffslot")
                local buffslotcount = buffslotset:GetChildCount()
                local iconcount = 0
                for i = 0, buffslotcount - 1 do
                    local achild = buffslotset:GetChildByIndex(i)
                    local aicon = achild:GetIcon()
                    local aiconinfo = aicon:GetInfo()
                    local abuff = info.GetBuff(handle, aiconinfo.type)
                    -- print(tostring(abuff))
                    -- print(tostring(aiconinfo.type))
                    if abuff ~= nil then
                        iconcount = iconcount + 1
                    end
                end

                local sweepcount = 0

                for i = 0, iconcount - 1 do
                    local child = buffslotset:GetChildByIndex(i)
                    local icon = child:GetIcon()
                    local iconinfo = icon:GetInfo()
                    local buff = info.GetBuff(handle, iconinfo.type)

                    if tostring(buff.buffID) == tostring(buffid) then

                        sweepcount = buff.over

                    end

                end
                if tonumber(g.settings[pcName].buffid[tostring(buffid)]) ~= tonumber(sweepcount) then
                    g.settings[pcName].buffid[tostring(buffid)] = sweepcount

                end
            end
        end

    end

    -- 保存処理を最後にまとめて実行
    indun_list_viewer_save_settings()
    indun_list_viewer_load_settings()
end

function indun_list_viewer_title_frame_open()
    local icframe = ui.CreateNewFrame("notice_on_pc", "icframe", 0, 0, 10, 10)
    AUTO_CAST(icframe)
    icframe:RemoveAllChild()

    icframe:SetLayerLevel(107);
    local titlegb = icframe:CreateOrGetControl("groupbox", "titlegb", 0, 0, 10, 10)
    AUTO_CAST(titlegb)
    titlegb:SetSkinName("bg")
    titlegb:SetColorTone("FF000000");

    local charname = titlegb:CreateOrGetControl("richtext", "charname", 20, 35)
    AUTO_CAST(charname)
    charname:SetText("{ol}CharacterName")

    local icon_table = {"icon_item_misc_boss_Slogutis", "icon_item_misc_boss_Upinis", "icon_item_misc_boss_Roze",
                        "icon_item_misc_high_falouros", "icon_item_misc_high_transmutationSpreader",
                        "icon_item_misc_falouros", "icon_item_misc_transmutationSpreader"}

    local y = 175
    for i = 1, 7 do
        local slot = titlegb:CreateOrGetControl("slot", "slot" .. i, y, 5, 25, 25)
        AUTO_CAST(slot)

        slot:SetSkinName("None");
        slot:EnablePop(0)
        slot:EnableDrop(0)
        slot:EnableDrag(0)

        local icon = CreateIcon(slot);
        local iconName = icon_table[i]

        icon:SetImage(iconName)
        local text = titlegb:CreateOrGetControl("richtext", "text" .. i, y + 30, 10)
        local hard_text = titlegb:CreateOrGetControl("richtext", "hard_text" .. i, y, 35)
        local auto_text = titlegb:CreateOrGetControl("richtext", "auto_text" .. i, y + 45, 35)
        local buff_text = titlegb:CreateOrGetControl("richtext", "buff_text" .. i, y + 90, 35)

        if i == 1 then
            hard_text:SetText("{ol}Hard")
            auto_text:SetText("{ol}Auto")
            buff_text:SetText("{ol}AClear")
            text:SetText("{ol}Abyss")
            y = y + 160
        elseif i == 2 then
            hard_text:SetText("{ol}Hard")
            auto_text:SetText("{ol}Auto")
            buff_text:SetText("{ol}AClear")
            text:SetText("{ol}Dreamy")
            y = y + 160
        elseif i == 3 then
            hard_text:SetText("{ol}Hard")
            auto_text:SetText("{ol}Auto")
            buff_text:SetText("{ol}AClear")
            text:SetText("{ol}Roze")
            y = y + 160
        elseif i == 4 then
            hard_text:SetText("{ol}Hard")
            auto_text:SetText("{ol}Auto")
            buff_text:SetText("{ol}AClear")
            y = y + 30
        elseif i == 5 then
            y = y + 30
        elseif i == 6 then

            y = y + 30
        elseif i == 7 then
            -- text:SetText("{ol}Turbulent")
            y = y + 30
        end
    end

    local mapframe = ui.GetFrame('worldmap2_mainmap')
    local screenWidth = mapframe:GetWidth()
    local frameWidth = 925
    local x = (screenWidth - frameWidth) / 2
    -- print(tostring(screenWidth))
    icframe:SetSkinName("bg")
    icframe:SetPos(x, 10)
    titlegb:Resize(925, 60)
    titlegb:SetEventScript(ui.RBUTTONUP, "indun_list_viewer_close")
    -- titlegb:SetEventScript(ui.LBUTTONUP, "indun_list_viewer_close")

    local close = titlegb:CreateOrGetControl("button", "close", 0, 0, 20, 20)
    AUTO_CAST(close)
    close:SetImage("testclose_button")
    close:SetGravity(ui.RIGHT, ui.TOP)
    close:SetEventScript(ui.LBUTTONUP, "indun_list_viewer_close")

    local memo_text = titlegb:CreateOrGetControl("richtext", "memo_text", 805, 35)
    memo_text:SetText("{ol}Memo")
    local display_text = titlegb:CreateOrGetControl("richtext", "display_text", 860, 35)
    display_text:SetText("{ol}Display")
    display_text:SetTextTooltip(
        "チェックしたキャラはレイド回数非表示{nl}Checked characters hide raid count")

    icframe:ShowWindow(1)

    indun_list_viewer_frame_open(icframe)
end

function indun_list_viewer_frame_open(icframe)

    local gb = icframe:CreateOrGetControl("groupbox", "gb", 0, 60, 10, 10)
    AUTO_CAST(gb)
    gb:SetSkinName("bg")
    gb:SetColorTone("FF000000");

    local accountInfo = session.barrack.GetMyAccount();
    local cnt = accountInfo:GetBarrackPCCount();

    local x = 5

    for i = 0, cnt - 1 do

        local pcInfo = accountInfo:GetBarrackPCByIndex(i);
        local pcName = pcInfo:GetName()

        local jobList, level, lastJobID = GetJobListFromAdventureBookCharData(pcName);
        local lastJobCls = GetClassByType("Job", lastJobID);
        local lastJobIcon = TryGetProp(lastJobCls, "Icon");
        local jobslot = gb:CreateOrGetControl("slot", "jobslot" .. i, 5, x - 4, 25, 25)
        AUTO_CAST(jobslot)
        jobslot:SetSkinName("None");

        local jobicon = CreateIcon(jobslot);
        jobicon:SetImage(lastJobIcon)
        -- local iconName = icon_table[i]
        local name = gb:CreateOrGetControl("richtext", pcName, 35, x)
        AUTO_CAST(name)

        name:SetText("{ol}" .. pcName)

        local line = gb:CreateOrGetControl("labelline", "line" .. i, 30, x - 7, 860, 2)
        line:SetSkinName("labelline_def_3")

        local Slogutis_hard = gb:CreateOrGetControl("richtext", "Slogutis_hard" .. pcName, 175, x)
        local Slogutis_auto = gb:CreateOrGetControl("richtext", "Slogutis_auto" .. pcName, 220, x)
        local Slogutis_buff = gb:CreateOrGetControl("richtext", "Slogutis_buff" .. pcName, 270, x)

        local Upinis_hard = gb:CreateOrGetControl("richtext", "Upinis_hard" .. pcName, 335, x)
        local Upinis_auto = gb:CreateOrGetControl("richtext", "Upinis_auto" .. pcName, 380, x)
        local Upinis_buff = gb:CreateOrGetControl("richtext", "Upinis_buff" .. pcName, 430, x)

        local Roze_hard = gb:CreateOrGetControl("richtext", "Roze_hard" .. pcName, 495, x)
        local Roze_auto = gb:CreateOrGetControl("richtext", "Roze_auto" .. pcName, 540, x)
        local Roze_buff = gb:CreateOrGetControl("richtext", "Roze_buff" .. pcName, 590, x)

        local Turbulent_hard = gb:CreateOrGetControl("richtext", "Turbulent_hard" .. pcName, 655, x)
        local Turbulent_auto = gb:CreateOrGetControl("richtext", "Turbulent_auto" .. pcName, 700, x)
        local Turbulent_buff = gb:CreateOrGetControl("richtext", "Turbulent_buff" .. pcName, 750, x)

        local memo = gb:CreateOrGetControl('edit', 'memo' .. i, 780, x - 5, 100, 25)
        AUTO_CAST(memo)
        memo:SetFontName("white_16_ol")
        memo:SetTextAlign("center", "center")
        memo:SetEventScript(ui.ENTERKEY, "indun_list_viewer_memo_save")
        memo:SetEventScriptArgString(ui.ENTERKEY, pcName)
        if g.settings[pcName].memo ~= nil then

            local memoData = g.settings[pcName].memo

            memo:SetText(memoData)

        end

        local display = gb:CreateOrGetControl('checkbox', 'display' .. i, 890, x - 5, 25, 25)
        AUTO_CAST(display)
        display:SetEventScript(ui.LBUTTONUP, "indun_list_viewer_display_save")
        display:SetEventScriptArgString(ui.LBUTTONUP, pcName)
        if g.settings[pcName].check ~= nil then

            local check = g.settings[pcName].check

            display:SetCheck(check)

        end

        x = x + 25
    end
    local framex = cnt * 25

    icframe:Resize(925, framex + 65)
    gb:Resize(925, framex + 30)
    gb:SetEventScript(ui.RBUTTONUP, "indun_list_viewer_close")
    gb:SetEventScript(ui.LBUTTONUP, "indun_list_viewer_close")

    indun_list_viewer_count_display(gb, accountInfo, cnt)
    icframe:ShowWindow(1)

end

function indun_list_viewer_count_display(gb, accountInfo, cnt)

    -- local indunClsList, indunCount = GetClassList('Indun')
    -- local accountInfo = session.barrack.GetMyAccount();
    -- local cnt = accountInfo:GetBarrackPCCount();

    local x = 5
    for i = 0, cnt - 1 do
        for key, _ in pairs(g.settings) do

            local pcInfo = accountInfo:GetBarrackPCByIndex(i);
            local pcName = pcInfo:GetName()

            if key == pcName and g.settings[pcName].check ~= 1 then

                local Slogutis_hard = GET_CHILD_RECURSIVELY(gb, "Slogutis_hard" .. pcName)

                Slogutis_hard:SetText("{ol}{s14}(" .. g.settings[pcName].raid_count.SlogutisH .. " / 1)")
                if Slogutis_hard:GetText() == "{ol}{s14}(1 / 1)" then
                    Slogutis_hard:SetColorTone("FF990000");
                end

                local Slogutis_auto = GET_CHILD_RECURSIVELY(gb, "Slogutis_auto" .. pcName)
                Slogutis_auto:SetText("{ol}{s14}(" .. g.settings[pcName].raid_count.SlogutisN .. " / 2)")
                if Slogutis_auto:GetText() == "{ol}{s14}(2 / 2)" then
                    Slogutis_auto:SetColorTone("FF990000");
                elseif Slogutis_auto:GetText() == "{ol}{s14}(1 / 2)" then
                    Slogutis_auto:SetColorTone("FF999900");
                end

                local Slogutis_buff = GET_CHILD_RECURSIVELY(gb, "Slogutis_buff" .. pcName)
                local Slogutis_buff_count = 0

                for buffid, v in pairs(g.settings[pcName].buffid) do
                    if buffid == tostring(80031) then
                        Slogutis_buff_count = tostring(v)

                    end
                end

                Slogutis_buff:SetText("{ol}{s14}(" .. Slogutis_buff_count .. ")")

                if tonumber(Slogutis_buff_count) ~= 0 then
                    Slogutis_buff:SetColorTone("FF999900")
                end

                -- local Upinis_hard = gb:CreateOrGetControl("richtext", "Upinis_hard" .. i, 335, x)
                local Upinis_hard = GET_CHILD_RECURSIVELY(gb, "Upinis_hard" .. pcName)
                Upinis_hard:SetText("{ol}{s14}(" .. g.settings[pcName].raid_count.UpinisH .. " / 1)")
                if Upinis_hard:GetText() == "{ol}{s14}(1 / 1)" then
                    Upinis_hard:SetColorTone("FF990000");
                end

                -- local Upinis_auto = gb:CreateOrGetControl("richtext", "Upinis_auto" .. i, 380, x)
                local Upinis_auto = GET_CHILD_RECURSIVELY(gb, "Upinis_auto" .. pcName)
                Upinis_auto:SetText("{ol}{s14}(" .. g.settings[pcName].raid_count.UpinisN .. " / 2)")
                if Upinis_auto:GetText() == "{ol}{s14}(2 / 2)" then
                    Upinis_auto:SetColorTone("FF990000");
                elseif Upinis_auto:GetText() == "{ol}{s14}(1 / 2)" then
                    Upinis_auto:SetColorTone("FF999900");
                end

                -- local Upinis_buff = gb:CreateOrGetControl("richtext", "Upinis_buff" .. i, 430, x)
                local Upinis_buff = GET_CHILD_RECURSIVELY(gb, "Upinis_buff" .. pcName)
                local Upinis_buff_count = 0

                for buffid, v in pairs(g.settings[pcName].buffid) do
                    if buffid == tostring(80030) then
                        Upinis_buff_count = tostring(v)

                    end
                end

                Upinis_buff:SetText("{ol}{s14}(" .. Upinis_buff_count .. ")")

                if tonumber(Upinis_buff_count) ~= 0 then
                    Upinis_buff:SetColorTone("FF999900")
                end
                -- 80015

                local Roze_hard = GET_CHILD_RECURSIVELY(gb, "Roze_hard" .. pcName)
                Roze_hard:SetText("{ol}{s14}(" .. g.settings[pcName].raid_count.RozeH .. " / 1)")
                if Roze_hard:GetText() == "{ol}{s14}(1 / 1)" then
                    Roze_hard:SetColorTone("FF990000");
                end

                local Roze_auto = GET_CHILD_RECURSIVELY(gb, "Roze_auto" .. pcName)
                Roze_auto:SetText("{ol}{s14}(" .. g.settings[pcName].raid_count.RozeN .. " / 2)")
                if Roze_auto:GetText() == "{ol}{s14}(2 / 2)" then
                    Roze_auto:SetColorTone("FF990000");
                elseif Roze_auto:GetText() == "{ol}{s14}(1 / 2)" then
                    Roze_auto:SetColorTone("FF999900");
                end

                -- local Roze_buff = gb:CreateOrGetControl("richtext", "Roze_buff" .. i, 430, x)
                local Roze_buff = GET_CHILD_RECURSIVELY(gb, "Roze_buff" .. pcName)
                local Roze_buff_count = 0

                for buffid, v in pairs(g.settings[pcName].buffid) do
                    if buffid == tostring(80015) then
                        Roze_buff_count = tostring(v)

                    end
                end

                Roze_buff:SetText("{ol}{s14}(" .. Roze_buff_count .. ")")

                if tonumber(Roze_buff_count) ~= 0 then
                    Roze_buff:SetColorTone("FF999900")
                end

                -- 80016 80017

                local Turbulent_hard = GET_CHILD_RECURSIVELY(gb, "Turbulent_hard" .. pcName)
                Turbulent_hard:SetText("{ol}{s14}(" .. g.settings[pcName].raid_count.TurbulentH .. " / 2)")
                if Turbulent_hard:GetText() == "{ol}{s14}(2 / 2)" then
                    Turbulent_hard:SetColorTone("FF990000");
                elseif Turbulent_hard:GetText() == "{ol}{s14}(1 / 2)" then
                    Turbulent_hard:SetColorTone("FF999900");
                end

                -- local Turbulent_auto = gb:CreateOrGetControl("richtext", "Turbulent_auto" .. i, 380, x)
                local Turbulent_auto = GET_CHILD_RECURSIVELY(gb, "Turbulent_auto" .. pcName)
                Turbulent_auto:SetText("{ol}{s14}(" .. g.settings[pcName].raid_count.TurbulentN .. " / 4)")
                if Turbulent_auto:GetText() == "{ol}{s14}(4 / 4)" then
                    Turbulent_auto:SetColorTone("FF990000");
                elseif Turbulent_auto:GetText() == "{ol}{s14}(3 / 4)" or Turbulent_auto:GetText() == "{ol}{s14}(2 / 4)" or
                    Turbulent_auto:GetText() == "{ol}{s14}(1 / 4)" then
                    Turbulent_auto:SetColorTone("FF999900");
                end

                -- local Turbulent_buff = gb:CreateOrGetControl("richtext", "Turbulent_buff" .. i, 430, x)
                local Turbulent_buff = GET_CHILD_RECURSIVELY(gb, "Turbulent_buff" .. pcName)
                local Turbulent_buff_count = 0

                for buffid, v in pairs(g.settings[pcName].buffid) do
                    if buffid == tostring(80016) then
                        Turbulent_buff_count = tonumber(v)

                    end
                end
                for buffid, v in pairs(g.settings[pcName].buffid) do
                    if buffid == tostring(80017) then
                        Turbulent_buff_count = Turbulent_buff_count + tonumber(v)

                    end
                end

                Turbulent_buff:SetText("{ol}{s14}(" .. Turbulent_buff_count .. ")")

                if tonumber(Turbulent_buff_count) ~= 0 then
                    Turbulent_buff:SetColorTone("FF999900")
                end
                x = x + 25
                --[[local Turbulent_hard = gb:CreateOrGetControl("richtext", "Turbulent_hard" .. i, 655, x)
                Turbulent_hard:SetText("{ol}{s14}(" .. g.settings.raid[pcName].TurbulentH .. " / 2)")
                if Turbulent_hard:GetText() == "{ol}{s14}(2 / 2)" then
                    Turbulent_hard:SetColorTone("FF990000");
                elseif Turbulent_hard:GetText() == "{ol}{s14}(1 / 2)" then
                    Turbulent_hard:SetColorTone("FF999900");
                end

                local Turbulent_auto = gb:CreateOrGetControl("richtext", "Turbulent_auto" .. i, 700, x)
                Turbulent_auto:SetText("{ol}{s14}(" .. g.settings.raid[pcName].TurbulentN .. " / 4)")

                if Turbulent_auto:GetText() == "{ol}{s14}(4 / 4)" then
                    Turbulent_auto:SetColorTone("FF990000");
                elseif Turbulent_auto:GetText() == "{ol}{s14}(3 / 4)" or Turbulent_auto:GetText() == "{ol}{s14}(2 / 4)" or
                    Turbulent_auto:GetText() == "{ol}{s14}(1 / 4)" then
                    Turbulent_auto:SetColorTone("FF999900");
                end

                local Turbulent_buff = gb:CreateOrGetControl("richtext", "Turbulent_buff" .. i, 750, x)
                local Turbulent_buff_count = 0

                for buffid, entry in pairs(g.settings[pcName] or {}) do
                    if buffid == tostring(80016) then
                        Turbulent_buff_count = tonumber(entry)
                        break
                    end
                end
                for buffid, entry in pairs(g.settings[pcName] or {}) do
                    if buffid == tostring(80017) then
                        Turbulent_buff_count = Turbulent_buff_count + tonumber(entry)
                        break
                    end
                end

                Turbulent_buff:SetText("{ol}{s14}(" .. Turbulent_buff_count .. ")")

                if tonumber(Turbulent_buff_count) ~= 0 then
                    Turbulent_buff:SetColorTone("FF999900")
                end]]

            end
        end
    end
end

function indun_list_viewer_close(frame)
    local topframe = frame:GetTopParentFrame();
    topframe:ShowWindow(0)

end

function indun_list_viewer_display_save(frame, ctrl, argStr, argNum)
    local ischeck = ctrl:IsChecked()
    -- print(ischeck)
    local pcName = argStr
    -- print(argStr)
    if g.settings[pcName].check == nil then
        g.settings[pcName].check = 0
    end

    g.settings[pcName].check = ischeck

    indun_list_viewer_save_settings()
    indun_list_viewer_load_settings()
end

function indun_list_viewer_memo_save(frame, ctrl, argStr, argNum)
    local text = ctrl:GetText()
    local pcName = argStr

    if g.settings[pcName].memo == nil or g.settings[pcName].memo ~= text then
        g.settings[pcName].memo = text
    end

    ui.SysMsg("MEMO registered.")

    indun_list_viewer_save_settings()
    indun_list_viewer_load_settings()

end

