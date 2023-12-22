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

        addon:RegisterMsg('GAME_START', "indun_list_viewer_raid_reset_time") -- !!
        addon:RegisterMsg('GAME_START', "indun_list_viewer_frame_init")
        addon:RegisterMsg('GAME_START', "indun_list_viewer_get_sweep_count")
        addon:RegisterMsg('BUFF_UPDATE', 'indun_list_viewer_get_sweep_count');

    end

end

if not g.loaded then
    g.settings = {}
end

function indun_list_viewer_frame_init()
    local frame = ui.GetFrame("indun_list_viewer")
    frame:SetSkinName('None')
    frame:SetTitleBarSkin("None")
    frame:Resize(30, 30)
    frame:SetPos(1580, 340)

    local btn = frame:CreateOrGetControl('button', 'btn', 0, 0, 25, 30)
    btn:SetSkinName("None")
    btn:SetText("{img sysmenu_sys 25 30}")
    btn:SetEventScript(ui.LBUTTONDOWN, "indun_list_viewer_frame_open") -- !!

end

function indun_list_viewer_get_sweep_count()

    local accountInfo = session.barrack.GetMyAccount()
    local cnt = accountInfo:GetBarrackPCCount()

    if g.settings == nil then
        g.settings = {}
    end

    local LoginName = session.GetMySession():GetPCApc():GetName()

    for i = 0, cnt - 1 do
        local pcInfo = accountInfo:GetBarrackPCByIndex(i)
        local pcName = pcInfo:GetName()

        if g.settings[pcName] == nil then
            g.settings[pcName] = {}
        end

        local sweepbuff_table = {80015, 80016, 80017, 80030, 80031}
        for _, buffid in ipairs(sweepbuff_table) do
            -- print(tostring(g.settings[pcName][tostring(buffid)]))
            if g.settings[pcName][tostring(buffid)] == nil then

                g.settings[pcName][tostring(buffid)] = 0
            end
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
                if tonumber(g.settings[pcName][tostring(buffid)]) ~= tonumber(sweepcount) then
                    g.settings[pcName][tostring(buffid)] = sweepcount

                    indun_list_viewer_get_raid_count(LoginName)
                end
            end
        end

    end

    -- 保存処理を最後にまとめて実行
    indun_list_viewer_save_settings()
    indun_list_viewer_load_settings()
end

function indun_list_viewer_raid_reset()

    g.settings.raid = {} -- !!

end

function indun_list_viewer_raid_reset_time()
    -- 現在の日時を取得
    local currentTime = os.time()

    -- 今日の曜日を取得 (0: 日曜日, 1: 月曜日, ..., 6: 土曜日)
    local currentWeekday = tonumber(os.date("%w", currentTime))

    -- 月曜日からの日数を計算
    local daysUntilMonday = (currentWeekday + 7 - 1) % 7
    if g.settings.raid_reset_time == nil then
        g.settings.raid_reset_time = 1702846800

    end
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
    local secondsSinceMondayAM6 = currentTime - mondayAM6

    print("月曜日の朝6時から現在までの経過時間（秒）: " .. secondsSinceMondayAM6)

    local nextreset = 604800 -- 次の月曜日の6時までの秒数
    -- local nextreset = 280000
    if secondsSinceMondayAM6 > nextreset then
        g.settings.raid_reset_time = mondayAM6
        indun_list_viewer_raid_reset()

    else
        local Name = session.GetMySession():GetPCApc():GetName()
        indun_list_viewer_get_raid_count(Name)
    end
    indun_list_viewer_save_settings()
    indun_list_viewer_load_settings()
end

function indun_list_viewer_get_raid_count(pcName)

    local Name = session.GetMySession():GetPCApc():GetName()

    if g.settings == nil then
        g.settings = {}
    end

    if g.settings.raid == nil then
        g.settings.raid = {}
    end

    if g.settings.raid[pcName] == nil then
        g.settings.raid[pcName] = {
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

    if tostring(Name) == tostring(pcName) then

        for key, value in pairs(g.settings.raid[pcName]) do

            if key == "SlogutisH" then
                g.settings.raid[pcName][key] =
                    GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 690).PlayPerResetType)
            elseif key == "SlogutisN" then
                g.settings.raid[pcName][key] =
                    GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 688).PlayPerResetType)
            elseif key == "UpinisH" then
                g.settings.raid[pcName][key] =
                    GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 687).PlayPerResetType)
            elseif key == "UpinisN" then
                g.settings.raid[pcName][key] =
                    GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 685).PlayPerResetType)
            elseif key == "RozeH" then
                g.settings.raid[pcName][key] =
                    GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 681).PlayPerResetType)
            elseif key == "RozeN" then
                g.settings.raid[pcName][key] =
                    GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 679).PlayPerResetType)
            elseif key == "TurbulentH" then
                g.settings.raid[pcName][key] =
                    GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 678).PlayPerResetType)
            elseif key == "TurbulentN" then
                g.settings.raid[pcName][key] =
                    GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 676).PlayPerResetType)
            end

        end
    end

    indun_list_viewer_save_settings()
    indun_list_viewer_load_settings()
end

function indun_list_viewer_memo_save(frame, ctrl, argStr, argNum)
    local text = ctrl:GetText()
    -- print(tostring(text))
    -- print(tostring(argStr))
    if g.settings.memo == nil then
        g.settings.memo = {}
    end
    if g.settings.memo[argStr] == nil then
        g.settings.memo[argStr] = {}
    end

    g.settings.memo[argStr] = text
    ui.SysMsg("MEMO registered.")

    indun_list_viewer_save_settings()
    indun_list_viewer_load_settings()

end

function indun_list_viewer_save(frame, ctrl, argStr, argNum)
    local ischeck = ctrl:IsChecked()
    -- print(tostring(ischeck))
    -- print(argStr)
    if g.settings.check == nil then
        g.settings.check = {}
    end
    if g.settings.check[argStr] == nil then
        g.settings.check[argStr] = {}
    end

    g.settings.check[argStr] = ischeck

    indun_list_viewer_save_settings()
    indun_list_viewer_load_settings()
end

function indun_list_viewer_frame_open()
    local icframe = ui.CreateNewFrame("notice_on_pc", "icframe", 0, 0, 10, 10)
    AUTO_CAST(icframe)
    icframe:RemoveAllChild()
    icframe:SetSkinName("None")
    icframe:SetLayerLevel(107);

    local gb = icframe:CreateOrGetControl("groupbox", "gb", 0, 0, 10, 10)
    AUTO_CAST(gb)
    gb:SetSkinName("bg")
    gb:SetColorTone("FF000000");

    local charname = gb:CreateOrGetControl("richtext", "charname", 10, 35)
    AUTO_CAST(charname)
    charname:SetText("{ol}CharacterName")

    local loginCharID = info.GetCID(session.GetMyHandle())

    local icon_table = {"icon_item_misc_boss_Slogutis", "icon_item_misc_boss_Upinis", "icon_item_misc_boss_Roze",
                        "icon_item_misc_high_falouros", "icon_item_misc_high_transmutationSpreader",
                        "icon_item_misc_falouros", "icon_item_misc_transmutationSpreader"}

    local y = 175
    for i = 1, 7 do
        local slot = gb:CreateOrGetControl("slot", "slot" .. i, y, 5, 25, 25)
        AUTO_CAST(slot)

        slot:SetSkinName("None");

        local icon = CreateIcon(slot);
        local iconName = icon_table[i]

        icon:SetImage(iconName)
        local text = gb:CreateOrGetControl("richtext", "text" .. i, y + 30, 10)
        local hard_text = gb:CreateOrGetControl("richtext", "hard_text" .. i, y, 35)
        local auto_text = gb:CreateOrGetControl("richtext", "auto_text" .. i, y + 45, 35)
        local buff_text = gb:CreateOrGetControl("richtext", "buff_text" .. i, y + 90, 35)

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

    local indunClsList, indunCount = GetClassList('Indun')
    local accountInfo = session.barrack.GetMyAccount();
    local cnt = accountInfo:GetBarrackPCCount();

    for i = 0, cnt - 1 do
        local pcInfo = accountInfo:GetBarrackPCByIndex(i);

        local pcName = pcInfo:GetName()
        indun_list_viewer_get_raid_count(pcName)
    end

    local x = 60

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

        local memo_text = gb:CreateOrGetControl("richtext", "memo_text", y + 30, 35)
        memo_text:SetText("{ol}Memo")
        local display_text = gb:CreateOrGetControl("richtext", "display_text", y + 85, 35)
        display_text:SetText("{ol}Display")
        display_text:SetTextTooltip(
            "チェックしたキャラはレイド回数非表示{nl}Checked characters hide raid count")

        local memo = gb:CreateOrGetControl('edit', 'memo' .. i, 780, x - 5, 100, 25)
        AUTO_CAST(memo)
        memo:SetFontName("white_16_ol")
        memo:SetTextAlign("center", "center")
        memo:SetEventScript(ui.ENTERKEY, "indun_list_viewer_memo_save")
        memo:SetEventScriptArgString(ui.ENTERKEY, pcName)

        local display = gb:CreateOrGetControl('checkbox', 'display' .. i, 890, x - 5, 25, 25)
        AUTO_CAST(display)
        display:SetEventScript(ui.LBUTTONUP, "indun_list_viewer_display_save")
        display:SetEventScriptArgString(ui.LBUTTONUP, pcName)

        for key, _ in pairs(g.settings.raid) do

            if key == pcName then
                -- print("プレイヤー名: " .. key)
                if g.settings.memo ~= nil then

                    local memoData = g.settings.memo[pcName]
                    if memoData ~= nil then

                        memo:SetText(memoData)

                    end

                end

                if g.settings.check ~= nil then

                    local check = g.settings.check[pcName]
                    if check ~= nil then
                        -- print(tostring(check))
                        display:SetCheck(check)

                    end

                end

                -- if display:IsChecked() == 0 then

                local Slogutis_hard = gb:CreateOrGetControl("richtext", "Slogutis_hard" .. i, 175, x)

                Slogutis_hard:SetText("{ol}{s14}(" .. g.settings.raid[pcName].SlogutisH .. " / 1)")
                if Slogutis_hard:GetText() == "{ol}{s14}(1 / 1)" then
                    Slogutis_hard:SetColorTone("FF990000");
                end

                local Slogutis_auto = gb:CreateOrGetControl("richtext", "Slogutis_auto" .. i, 220, x)
                Slogutis_auto:SetText("{ol}{s14}(" .. g.settings.raid[pcName].SlogutisN .. " / 2)")
                if Slogutis_auto:GetText() == "{ol}{s14}(2 / 2)" then
                    Slogutis_auto:SetColorTone("FF990000");
                elseif Slogutis_auto:GetText() == "{ol}{s14}(1 / 2)" then
                    Slogutis_auto:SetColorTone("FF999900");
                end

                local Slogutis_buff = gb:CreateOrGetControl("richtext", "Slogutis_buff" .. i, 270, x)
                local Slogutis_buff_count = 0

                for buffid, entry in pairs(g.settings[pcName] or {}) do
                    if buffid == tostring(80031) then
                        Slogutis_buff_count = tostring(entry)
                        break
                    end
                end

                Slogutis_buff:SetText("{ol}{s14}(" .. Slogutis_buff_count .. ")")

                if tonumber(Slogutis_buff_count) ~= 0 then
                    Slogutis_buff:SetColorTone("FF999900")
                end

                local Upinis_hard = gb:CreateOrGetControl("richtext", "Upinis_hard" .. i, 335, x)
                Upinis_hard:SetText("{ol}{s14}(" .. g.settings.raid[pcName].UpinisH .. " / 1)")
                if Upinis_hard:GetText() == "{ol}{s14}(1 / 1)" then
                    Upinis_hard:SetColorTone("FF990000");
                end

                local Upinis_auto = gb:CreateOrGetControl("richtext", "Upinis_auto" .. i, 380, x)
                Upinis_auto:SetText("{ol}{s14}(" .. g.settings.raid[pcName].UpinisN .. " / 2)")
                if Upinis_auto:GetText() == "{ol}{s14}(2 / 2)" then
                    Upinis_auto:SetColorTone("FF990000");
                elseif Upinis_auto:GetText() == "{ol}{s14}(1 / 2)" then
                    Upinis_auto:SetColorTone("FF999900");
                end

                local Upinis_buff = gb:CreateOrGetControl("richtext", "Upinis_buff" .. i, 430, x)
                local Upinis_buff_count = 0

                for buffid, entry in pairs(g.settings[pcName] or {}) do
                    if buffid == tostring(80030) then
                        Upinis_buff_count = tostring(entry)
                        break
                    end
                end

                Upinis_buff:SetText("{ol}{s14}(" .. Upinis_buff_count .. ")")

                if tonumber(Upinis_buff_count) ~= 0 then
                    Upinis_buff:SetColorTone("FF999900")
                end

                local Roze_hard = gb:CreateOrGetControl("richtext", "Roze_hard" .. i, 495, x)
                Roze_hard:SetText("{ol}{s14}(" .. g.settings.raid[pcName].RozeH .. " / 1)")
                if Roze_hard:GetText() == "{ol}{s14}(1 / 1)" then
                    Roze_hard:SetColorTone("FF990000");
                end

                local Roze_auto = gb:CreateOrGetControl("richtext", "Roze_auto" .. i, 540, x)
                Roze_auto:SetText("{ol}{s14}(" .. g.settings.raid[pcName].RozeN .. " / 2)")
                if Roze_auto:GetText() == "{ol}{s14}(2 / 2)" then
                    Roze_auto:SetColorTone("FF990000");
                elseif Roze_auto:GetText() == "{ol}{s14}(1 / 2)" then
                    Roze_auto:SetColorTone("FF999900");
                end

                local Roze_buff = gb:CreateOrGetControl("richtext", "Roze_buff" .. i, 590, x)
                local Roze_buff_count = 0

                for buffid, entry in pairs(g.settings[pcName] or {}) do
                    if buffid == tostring(80015) then
                        Roze_buff_count = tostring(entry)
                        break
                    end
                end

                Roze_buff:SetText("{ol}{s14}(" .. Roze_buff_count .. ")")

                if tonumber(Roze_buff_count) ~= 0 then
                    Roze_buff:SetColorTone("FF999900")
                end

                local Turbulent_hard = gb:CreateOrGetControl("richtext", "Turbulent_hard" .. i, 655, x)
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
                end

                break
                -- end
            end
        end

        x = x + 25

    end
    local framex = cnt * 25
    local mapframe = ui.GetFrame('worldmap2_mainmap')
    local screenWidth = mapframe:GetWidth()
    local frameWidth = 925
    local x = (screenWidth - frameWidth) / 2
    -- print(tostring(screenWidth))
    icframe:SetPos(x, 10)
    icframe:Resize(925, framex + 100)
    gb:Resize(925, framex + 65)
    gb:SetEventScript(ui.RBUTTONUP, "indun_list_viewer_close")

    local close = gb:CreateOrGetControl("button", "close", 0, 0, 20, 20)
    AUTO_CAST(close)
    close:SetImage("testclose_button")
    close:SetGravity(ui.LEFT, ui.TOP)
    close:SetEventScript(ui.LBUTTONUP, "indun_list_viewer_close")
    icframe:ShowWindow(1)
end

function indun_list_viewer_close(frame)
    local topframe = frame:GetTopParentFrame();
    topframe:ShowWindow(0)

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

--[[function indun_list_viewer_autosweep(frame, ctrl, argStr, argNum)
    local indun_classid = tonumber(argNum);
    local BuffID = 0

    if argNum == 673 then -- プロパゲオート
        BuffID = 80016
    elseif argNum == 676 then -- ファロオート
        BuffID = 80017
    elseif argNum == 679 then -- ロゼオート
        BuffID = 80015
    elseif argNum == 685 then -- 蝶々
        BuffID = 80030
    elseif argNum == 688 then -- スロガ
        BuffID = 80031

    end

    local sweepcount = 0
    sweepcount = indun_list_viewer_sweep_count(BuffID)
    if sweepcount >= 1 then
        ReqUseRaidAutoSweep(indun_classid);

    else
        ui.SysMsg("Does not have a sweeping buff")

    end
    ReserveScript("indun_panel_sweep_count_get()", 1.5)
end

-- オート掃討の数をキャラのバフ欄から取得して返す
function indun_list_viewer_sweep_count(buffid)

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

    if sweepcount ~= 0 then
        indun_list_viewer_get_sweep_count()
        return sweepcount
    else
        return 0
    end

end]]

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

