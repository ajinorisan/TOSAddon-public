-- v1.0.0 indun_panelから機能独立
-- v1.0.1 作り直し。instantccと連携、instantcc入れてたらバラック順に並び替え。
-- v1.0.2 CCボタン追加。クローズボタンの位置調整。
-- v1.0.3 クローズボタンを戻した。ツールチップ追加。
-- v1.0.4 ゲームスタート時の不可軽減
-- v1.0.5 ゲーム立ち上げ時の初期化処理がバグってたのを修正。
local addonName = "indun_list_viewer"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.0.5"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)
g.logpath = string.format('../addons/%s/log.txt', addonNameLower)

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
        settings = {
            raid_reset_time = 1702846800,
            charactors = {} -- 初期化として空のテーブルを設定
        }

        local accountInfo = session.barrack.GetMyAccount()
        local cnt = accountInfo:GetBarrackPCCount()

        for i = 0, cnt - 1 do
            local pcInfo = accountInfo:GetBarrackPCByIndex(i)
            local pcName = pcInfo:GetName()

            -- 新しいキャラのデータを一時的な変数に作成
            local newCharData = {
                name = pcName,
                raid_count = {
                    SlogutisH = "-",
                    SlogutisN = "-",
                    UpinisH = "-",
                    UpinisN = "-",
                    RozeH = "-",
                    RozeN = "-",
                    TurbulentH = "-",
                    TurbulentN = "-"
                },
                buffid = {},
                memo = "",
                check = 0,
                layer = 0,
                order = 0
            }

            -- 一時的な変数を settings.charactors に挿入
            table.insert(settings.charactors, newCharData)
        end
    else
        -- settings.charactors が存在する場合、名前が一致するか確認して追加
        local accountInfo = session.barrack.GetMyAccount()
        local cnt = accountInfo:GetBarrackPCCount()

        for i = 0, cnt - 1 do
            local pcInfo = accountInfo:GetBarrackPCByIndex(i)
            local pcName = pcInfo:GetName()

            local found = false
            for _, charData in ipairs(settings.charactors) do
                if charData.name == pcName then
                    found = true
                    break
                end
            end

            if not found then
                -- 新しいキャラのデータを一時的な変数に作成
                local newCharData = {
                    name = pcName,
                    raid_count = {
                        SlogutisH = "-",
                        SlogutisN = "-",
                        UpinisH = "-",
                        UpinisN = "-",
                        RozeH = "-",
                        RozeN = "-",
                        TurbulentH = "-",
                        TurbulentN = "-"
                    },
                    buffid = {},
                    memo = "",
                    check = 0,
                    layer = 0,
                    order = 0
                }

                -- 一時的な変数を settings.charactors に挿入
                table.insert(settings.charactors, newCharData)
            end
        end
    end

    g.settings = settings
    indun_list_viewer_save_settings()
end

function indun_list_viewer_instantcc()
    local ic = _G["ADDONS"]["ebisuke"]["INSTANTCC"]
    ic.settingsFileLoc = string.format('../addons/%s/settings.json', "instantcc")
    ic.settings = acutil.loadJSON(ic.settingsFileLoc, ic.settings)

    for _, gChar in ipairs(g.settings.charactors) do
        local found = false

        for _, icChar in ipairs(ic.settings.charactors) do
            if icChar.name == gChar.name then
                -- 同じ名前が見つかった場合、上書き
                gChar.layer = icChar.layer
                gChar.order = icChar.order
                found = true
                break
            end
        end

        if not found then
            -- 見つからない場合、デフォルトの値を代入
            gChar.layer = 9
            gChar.order = 99
        end
    end
    local function sortCharactors(a, b)
        if a.layer == b.layer then
            return a.order < b.order
        else
            return a.layer < b.layer
        end
    end

    -- ソートを実行
    table.sort(g.settings.charactors, sortCharactors)

    indun_list_viewer_save_settings()
    -- indun_list_viewer_load_settings()

end

g.first = 0
function INDUN_LIST_VIEWER_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame

    indun_list_viewer_load_settings()

    -- acutil.setupEvent(addon, "CREATE_SCROLL_CHAR_LIST", "indun_list_viewer_CREATE_SCROLL_CHAR_LIST")
    -- acutil.setupHook(indun_list_viewer_CREATE_SCROLL_CHAR_LIST, "CREATE_SCROLL_CHAR_LIST");
    g.first = g.first + 1
    local pc = GetMyPCObject();

    local curMap = GetZoneName(pc)
    local mapCls = GetClass("Map", curMap)
    if mapCls.MapType == "City" then

        addon:RegisterMsg('GAME_START', "indun_list_viewer_frame_init")
        addon:RegisterMsg('GAME_START', "indun_list_viewer_raid_reset_time")
        addon:RegisterMsg('GAME_START', "indun_list_viewer_get_raid_count")
        addon:RegisterMsg('FPS_UPDATE', "indun_list_viewer_get_count_loginname")
        if _G["ADDONS"]["ebisuke"]["INSTANTCC"] then
            addon:RegisterMsg('GAME_START_3SEC', "indun_list_viewer_instantcc")
        end

    end
    -- print(g.first)
    --[[local accountInfo = session.barrack.GetMyAccount()
    local cnt = accountInfo:GetBarrackPCCount()
    for i = 0, cnt - 1 do
        local pcInfo = accountInfo:GetBarrackPCByIndex(i)
        local pcName = pcInfo:GetName()
        print(tostring(pcName))
    end]]

end

function indun_list_viewer_get_count_loginname()

    local LoginName = session.GetMySession():GetPCApc():GetName()

    for _, charData in pairs(g.settings.charactors) do
        if charData.name == LoginName then
            charData.raid_count = {
                SlogutisH = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 690).PlayPerResetType),
                SlogutisN = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 688).PlayPerResetType),
                UpinisH = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 687).PlayPerResetType),
                UpinisN = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 685).PlayPerResetType),
                RozeH = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 681).PlayPerResetType),
                RozeN = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 679).PlayPerResetType),
                TurbulentH = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 678).PlayPerResetType),
                TurbulentN = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 676).PlayPerResetType)
            }

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

            local sweepbuff_table = {80015, 80016, 80017, 80030, 80031}

            for _, buffid in ipairs(sweepbuff_table) do
                local found = false

                for i = 0, iconcount - 1 do
                    local child = buffslotset:GetChildByIndex(i)
                    local icon = child:GetIcon()
                    local iconinfo = icon:GetInfo()
                    local buff = info.GetBuff(handle, iconinfo.type)

                    if tostring(buff.buffID) == tostring(buffid) then
                        charData.buffid[tostring(buffid)] = buff.over
                        found = true
                        break
                    end
                end

                if not found then
                    charData.buffid[tostring(buffid)] = 0
                end
            end

            indun_list_viewer_save_settings()
        end
    end

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

    if g.settings.raid_reset == nil then
        g.settings.raid_reset = false
    end
    local secondsSinceMondayAM6 = 0
    -- 月曜日からの経過秒数を計算
    if g.settings.raid_reset_time == 1707685200 and g.settings.raid_reset == false and g.first >= 2 then
        -- local secondsSinceMondayAM6 = currentTime - g.settings.raid_reset_time
        -- print("false")
        secondsSinceMondayAM6 = currentTime - 1702846800
        g.settings.raid_reset = true
        indun_list_viewer_save_settings()
    else
        secondsSinceMondayAM6 = currentTime - g.settings.raid_reset_time
    end
    -- print("indun_list_viewer 月曜日の朝6時から現在までの経過時間（秒）: " .. secondsSinceMondayAM6)

    local nextreset = 604800 -- 次の月曜日の6時までの秒数

    if secondsSinceMondayAM6 > nextreset and g.first >= 2 then
        g.settings.raid_reset_time = mondayAM6
        indun_list_viewer_save_settings()
        -- indun_list_viewer_load_settings()
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
        -- print(tostring(pcName))
        for _, charData in pairs(g.settings.charactors) do
            if charData.name == pcName then
                charData.raid_count = {

                    SlogutisH = "-",
                    SlogutisN = "-",
                    UpinisH = "-",
                    UpinisN = "-",
                    RozeH = "-",
                    RozeN = "-",
                    TurbulentH = "-",
                    TurbulentN = "-"

                } -- 対応する要素のraid_countを初期化
            end
        end
    end

    indun_list_viewer_save_settings()
    -- indun_list_viewer_load_settings()
    ui.SysMsg("Raid counts were initialized.{nl}" .. "レイドの回数を初期化しました。")
    indun_list_viewer_get_raid_count()

end

function indun_list_viewer_get_raid_count()

    local LoginName = session.GetMySession():GetPCApc():GetName()

    for _, charData in pairs(g.settings.charactors) do
        if charData.name == LoginName then
            charData.raid_count = {
                SlogutisH = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 690).PlayPerResetType),
                SlogutisN = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 688).PlayPerResetType),
                UpinisH = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 687).PlayPerResetType),
                UpinisN = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 685).PlayPerResetType),
                RozeH = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 681).PlayPerResetType),
                RozeN = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 679).PlayPerResetType),
                TurbulentH = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 678).PlayPerResetType),
                TurbulentN = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 676).PlayPerResetType)
            }
        end
    end
    indun_list_viewer_save_settings()
    -- indun_list_viewer_load_settings()

    indun_list_viewer_get_sweep_count()

end

function indun_list_viewer_get_sweep_count()
    local accountInfo = session.barrack.GetMyAccount()
    local cnt = accountInfo:GetBarrackPCCount()

    for i = 0, cnt - 1 do
        local pcInfo = accountInfo:GetBarrackPCByIndex(i)
        local pcName = pcInfo:GetName()
        local LoginName = session.GetMySession():GetPCApc():GetName()

        local sweepbuff_table = {80015, 80016, 80017, 80030, 80031}

        for _, charData in pairs(g.settings.charactors) do
            if charData.name == LoginName then
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

                for _, buffid in ipairs(sweepbuff_table) do
                    local found = false

                    for i = 0, iconcount - 1 do
                        local child = buffslotset:GetChildByIndex(i)
                        local icon = child:GetIcon()
                        local iconinfo = icon:GetInfo()
                        local buff = info.GetBuff(handle, iconinfo.type)

                        if tostring(buff.buffID) == tostring(buffid) then
                            charData.buffid[tostring(buffid)] = buff.over
                            found = true
                            break
                        end
                    end

                    if not found then
                        charData.buffid[tostring(buffid)] = 0
                    end
                end
            elseif charData.name == pcName then

                -- charData.name が pcName と一致する場合の処理
                for _, buffid in ipairs(sweepbuff_table) do
                    local Value = charData.buffid[tostring(buffid)]

                    if Value == nil or type(Value) ~= "number" then
                        charData.buffid[tostring(buffid)] = "-"
                    end
                end
            end
        end
    end

    indun_list_viewer_save_settings()
    -- indun_list_viewer_load_settings()
end

function indun_list_viewer_frame_init()

    local frame = ui.GetFrame("indun_list_viewer")
    frame:SetSkinName('None')
    frame:SetTitleBarSkin("None")
    frame:Resize(35, 35)

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

    local hard_text = titlegb:CreateOrGetControl("richtext", "hard_text", 200, 5)
    AUTO_CAST(hard_text)
    hard_text:SetText("{ol}Hard Count")

    local auto_text = titlegb:CreateOrGetControl("richtext", "auto_text", 325, 5)
    AUTO_CAST(auto_text)
    auto_text:SetText("{ol}Auto or Solo Count/ AutoClearBuff Count")

    local icon_table = {"icon_item_misc_boss_Slogutis", "icon_item_misc_boss_Upinis", "icon_item_misc_boss_Roze",
                        "icon_item_misc_high_falouros", "icon_item_misc_high_transmutationSpreader",
                        "icon_item_misc_boss_Slogutis", "icon_item_misc_boss_Upinis", "icon_item_misc_boss_Roze",
                        "icon_item_misc_falouros", "icon_item_misc_transmutationSpreader"}

    local y = 175
    for i = 1, 5 do
        local slot = titlegb:CreateOrGetControl("slot", "slot" .. i, y, 30, 25, 25)
        AUTO_CAST(slot)

        slot:SetSkinName("None");
        slot:EnablePop(0)
        slot:EnableDrop(0)
        slot:EnableDrag(0)

        local icon = CreateIcon(slot);
        local iconName = icon_table[i]

        icon:SetImage(iconName)

        y = y + 30
    end
    y = 350
    for i = 6, 10 do
        if i <= 8 then
            local slot = titlegb:CreateOrGetControl("slot", "slot" .. i, y + 10, 30, 25, 25)
            AUTO_CAST(slot)

            slot:SetSkinName("None");
            slot:EnablePop(0)
            slot:EnableDrop(0)
            slot:EnableDrag(0)

            local icon = CreateIcon(slot);
            local iconName = icon_table[i]

            icon:SetImage(iconName)

            y = y + 70
        else
            local slot = titlegb:CreateOrGetControl("slot", "slot" .. i, y, 30, 25, 25)
            AUTO_CAST(slot)

            slot:SetSkinName("None");
            slot:EnablePop(0)
            slot:EnableDrop(0)
            slot:EnableDrag(0)

            local icon = CreateIcon(slot);
            local iconName = icon_table[i]
            icon:SetImage(iconName)

            y = y + 30
        end
    end

    local mapframe = ui.GetFrame('worldmap2_mainmap')
    local screenWidth = mapframe:GetWidth()
    local frameWidth = 800
    -- local x = (screenWidth - frameWidth) / 2

    icframe:SetSkinName("bg")
    -- icframe:SetPos(x, 5)
    icframe:SetPos(665, 5)
    titlegb:Resize(800, 55)

    titlegb:SetEventScript(ui.RBUTTONUP, "indun_list_viewer_close")
    titlegb:SetTextTooltip("右クリックで閉じます。{nl}Right-click to close.")

    local close = titlegb:CreateOrGetControl("button", "close", 0, 0, 20, 20)
    AUTO_CAST(close)
    close:SetImage("testclose_button")
    close:SetGravity(ui.RIGHT, ui.TOP)
    close:SetEventScript(ui.LBUTTONUP, "indun_list_viewer_close")

    local ccbtn = titlegb:CreateOrGetControl('button', 'ccbtn', 40, 5, 30, 30)
    AUTO_CAST(ccbtn)
    ccbtn:SetSkinName("None")
    -- ccbtn:SetGravity(ui.LEFTT, ui.TOP)
    ccbtn:SetText("{img barrack_button_normal 30 30}")
    ccbtn:SetEventScript(ui.LBUTTONUP, "APPS_TRY_MOVE_BARRACK")

    local memo_text = titlegb:CreateOrGetControl("richtext", "memo_text", 650, 35)
    memo_text:SetText("{ol}Memo")
    local display_text = titlegb:CreateOrGetControl("richtext", "display_text", 720, 35)
    display_text:SetText("{ol}Display")
    display_text:SetTextTooltip(
        "チェックしたキャラはレイド回数非表示{nl}Checked characters hide raid count")

    icframe:ShowWindow(1)

    indun_list_viewer_frame_open(icframe)
end

function indun_list_viewer_frame_open(icframe)

    local gb = icframe:CreateOrGetControl("groupbox", "gb", 0, 55, 10, 10)
    AUTO_CAST(gb)
    gb:SetSkinName("bg")
    gb:SetColorTone("FF000000");

    local x = 6

    for _, charData in ipairs(g.settings.charactors) do

        local pcName = charData.name
        local jobList, level, lastJobID = GetJobListFromAdventureBookCharData(pcName);
        local lastJobCls = GetClassByType("Job", lastJobID);
        local lastJobIcon = TryGetProp(lastJobCls, "Icon");
        local jobslot = gb:CreateOrGetControl("slot", "jobslot" .. pcName, 5, x - 4, 25, 25)
        AUTO_CAST(jobslot)
        jobslot:SetSkinName("None");

        local jobicon = CreateIcon(jobslot);
        jobicon:SetImage(lastJobIcon)

        local name = gb:CreateOrGetControl("richtext", charData.name, 35, x)
        AUTO_CAST(name)

        name:SetText("{ol}" .. pcName)

        local line = gb:CreateOrGetControl("labelline", "line" .. pcName, 30, x - 7, 750, 2)
        line:SetSkinName("labelline_def_3")
        if charData.check == 0 then
            local Slogutis_hard = gb:CreateOrGetControl("richtext", "Slogutis_hard" .. pcName, 175, x)
            Slogutis_hard:SetText("{ol}{s14}( " .. charData.raid_count.SlogutisH .. " )")
            Slogutis_hard:SetTextTooltip("Hard Raid Weekly Entry Count 1 times per character{nl}" ..
                                             "ハードレイド週間入場回数1キャラ1回")
            if type(charData.raid_count.SlogutisH) == "number" then
                if tonumber(charData.raid_count.SlogutisH) == 1 then
                    Slogutis_hard:SetColorTone("FF990000");
                else
                    Slogutis_hard:SetColorTone("FFFFFFFF");
                end
            end

            local Upinis_hard = gb:CreateOrGetControl("richtext", "Upinis_hard" .. pcName, 205, x)
            Upinis_hard:SetText("{ol}{s14}( " .. charData.raid_count.UpinisH .. " )")
            Upinis_hard:SetTextTooltip("Hard Raid Weekly Entry Count 1 times per character{nl}" ..
                                           "ハードレイド週間入場回数1キャラ1回")
            if type(charData.raid_count.UpinisH) == "number" then
                if tonumber(charData.raid_count.UpinisH) == 1 then
                    Upinis_hard:SetColorTone("FF990000");
                else
                    Upinis_hard:SetColorTone("FFFFFFFF");
                end
            end

            local Roze_hard = gb:CreateOrGetControl("richtext", "Roze_hard" .. pcName, 235, x)
            Roze_hard:SetText("{ol}{s14}( " .. charData.raid_count.RozeH .. " )")
            Roze_hard:SetTextTooltip("Hard Raid Weekly Entry Count 1 times per character{nl}" ..
                                         "ハードレイド週間入場回数1キャラ1回")
            if type(charData.raid_count.RozeH) == "number" then
                if tonumber(charData.raid_count.RozeH) == 1 then
                    Roze_hard:SetColorTone("FF990000");
                else
                    Roze_hard:SetColorTone("FFFFFFFF");
                end
            end

            local Turbulent_hard = gb:CreateOrGetControl("richtext", "Turbulent_hard" .. pcName, 280, x)
            Turbulent_hard:SetText("{ol}{s14}( " .. charData.raid_count.TurbulentH .. " )")
            Turbulent_hard:SetTextTooltip("Hard Raid Weekly Entry Count 2 times per character{nl}" ..
                                              "ハードレイド週間入場回数1キャラ2回")
            if type(charData.raid_count.TurbulentH) == "number" then
                if tonumber(charData.raid_count.TurbulentH) == 2 then
                    Turbulent_hard:SetColorTone("FF990000");
                elseif tonumber(charData.raid_count.TurbulentH) == 1 then
                    Turbulent_hard:SetColorTone("FF999900");
                else
                    Turbulent_hard:SetColorTone("FFFFFFFF");
                end
            else
                Turbulent_hard:SetColorTone("FFFFFFFF");
            end

            local Slogutis_auto = gb:CreateOrGetControl("richtext", "Slogutis_auto" .. pcName, 350, x)
            Slogutis_auto:SetText("{ol}{s14}( " .. charData.raid_count.SlogutisN .. " ) /")
            Slogutis_auto:SetTextTooltip("Auto Raid Weekly Entry Count 2 times per character{nl}" ..
                                             "自動レイド週間入場回数1キャラ2回")
            if type(charData.raid_count.SlogutisN) == "number" then
                if tonumber(charData.raid_count.SlogutisN) == 2 then
                    Slogutis_auto:SetColorTone("FF990000");
                elseif tonumber(charData.raid_count.SlogutisN) == 1 then
                    Slogutis_auto:SetColorTone("FF999900");
                else
                    Slogutis_auto:SetColorTone("FFFFFFFF");
                end
            else
                Slogutis_auto:SetColorTone("FFFFFFFF");
            end

            local Slogutis_buff = gb:CreateOrGetControl("richtext", "Slogutis_buff" .. pcName, 385, x)
            local Slogutis_buff_count = 0
            for buffid, v in pairs(charData.buffid) do
                if buffid == tostring(80031) then
                    Slogutis_buff_count = v

                end
            end

            Slogutis_buff:SetText("{ol}{s14}( " .. Slogutis_buff_count .. " )")
            Slogutis_buff:SetTextTooltip("Number of Auto Clear Buff remaining{nl}" .. "自動掃討残り回数")
            if type(Slogutis_buff_count) == "number" then
                if tonumber(Slogutis_buff_count) >= 1 then -- or type(Slogutis_buff_count) ~= "string"
                    Slogutis_buff:SetColorTone("FF999900")
                end
            end

            local Upinis_auto = gb:CreateOrGetControl("richtext", "Upinis_auto" .. pcName, 420, x)
            Upinis_auto:SetText("{ol}{s14}( " .. charData.raid_count.UpinisN .. " ) /")
            Upinis_auto:SetTextTooltip("Auto Raid Weekly Entry Count 2 times per character{nl}" ..
                                           "自動レイド週間入場回数1キャラ2回")
            if type(charData.raid_count.UpinisN) == "number" then
                if tonumber(charData.raid_count.UpinisN) == 2 then
                    Upinis_auto:SetColorTone("FF990000");
                elseif tonumber(charData.raid_count.UpinisN) == 1 then
                    Upinis_auto:SetColorTone("FF999900");
                else
                    Upinis_auto:SetColorTone("FFFFFFFF");
                end
            else
                Upinis_auto:SetColorTone("FFFFFFFF");
            end

            local Upinis_buff = gb:CreateOrGetControl("richtext", "Upinis_buff" .. pcName, 455, x)
            local Upinis_buff_count = 0
            for buffid, v in pairs(charData.buffid) do
                if buffid == tostring(80030) then
                    Upinis_buff_count = v

                end
            end

            Upinis_buff:SetText("{ol}{s14}( " .. Upinis_buff_count .. " )")
            Upinis_buff:SetTextTooltip("Number of Auto Clear Buff remaining{nl}" .. "自動掃討残り回数")
            if type(Upinis_buff_count) == "number" then
                if tonumber(Upinis_buff_count) >= 1 then -- or type(Upinis_buff_count) ~= "string"
                    Upinis_buff:SetColorTone("FF999900")
                end
            end

            local Roze_auto = gb:CreateOrGetControl("richtext", "Roze_auto" .. pcName, 490, x)
            Roze_auto:SetText("{ol}{s14}( " .. charData.raid_count.RozeN .. " ) /")
            Roze_auto:SetTextTooltip("Auto Raid Weekly Entry Count 2 times per character{nl}" ..
                                         "自動レイド週間入場回数1キャラ2回")
            if type(charData.raid_count.RozeN) == "number" then
                if tonumber(charData.raid_count.RozeN) == 2 then
                    Roze_auto:SetColorTone("FF990000");
                elseif tonumber(charData.raid_count.RozeN) == 1 then
                    Roze_auto:SetColorTone("FF999900");
                else
                    Roze_auto:SetColorTone("FFFFFFFF");
                end
            else
                Roze_auto:SetColorTone("FFFFFFFF");
            end

            local Roze_buff = gb:CreateOrGetControl("richtext", "Roze_buff" .. pcName, 525, x)
            local Roze_buff_count = 0
            for buffid, v in pairs(charData.buffid) do
                if buffid == tostring(80015) then
                    Roze_buff_count = v

                end
            end

            Roze_buff:SetText("{ol}{s14}( " .. Roze_buff_count .. " )")
            Roze_buff:SetTextTooltip("Number of Auto Clear Buff remaining{nl}" .. "自動掃討残り回数")
            if type(Roze_buff_count) == "number" then
                if tonumber(Roze_buff_count) >= 1 then -- or type(Roze_buff_count) ~= "string"
                    Roze_buff:SetColorTone("FF999900")
                end
            end

            local Turbulent_auto = gb:CreateOrGetControl("richtext", "Turbulent_auto" .. pcName, 560, x)
            Turbulent_auto:SetText("{ol}{s14}( " .. charData.raid_count.TurbulentN .. " ) /")
            Turbulent_auto:SetTextTooltip("Auto Raid Weekly Entry Count 4 times per character{nl}" ..
                                              "自動レイド週間入場回数1キャラ4回")
            if type(charData.raid_count.TurbulentN) == "number" then

                if tonumber(charData.raid_count.TurbulentN) == 4 then
                    Turbulent_auto:SetColorTone("FF990000");
                elseif tonumber(charData.raid_count.TurbulentN) > 1 and tonumber(charData.raid_count.TurbulentN) < 4 then
                    Turbulent_auto:SetColorTone("FF999900");
                else
                    Turbulent_auto:SetColorTone("FFFFFFFF");
                end
            else
                Turbulent_auto:SetColorTone("FFFFFFFF");
            end

            local Turbulent_buff = gb:CreateOrGetControl("richtext", "Turbulent_buff" .. pcName, 595, x)
            local Falouros_buff_count = 0
            for buffid, v in pairs(charData.buffid) do
                if buffid == tostring(80017) then
                    Falouros_buff_count = v

                end
            end
            local Spreader_buff_count = 0
            for buffid, v in pairs(charData.buffid) do
                if buffid == tostring(80016) then
                    Spreader_buff_count = v

                end
            end

            local Turbulent_buff_count
            if type(Falouros_buff_count) == "number" and type(Spreader_buff_count) == "number" then
                Turbulent_buff_count = Falouros_buff_count + Spreader_buff_count
            elseif type(Falouros_buff_count) == "number" and type(Spreader_buff_count) == "string" then
                Turbulent_buff_count = Falouros_buff_count
            elseif type(Falouros_buff_count) == "string" and type(Spreader_buff_count) == "number" then
                Turbulent_buff_count = Spreader_buff_count
            else
                Turbulent_buff_count = "-"
            end

            Turbulent_buff:SetText("{ol}{s14}( " .. Turbulent_buff_count .. " )")
            Turbulent_buff:SetTextTooltip("Number of Auto Clear Buff remaining{nl}" .. "自動掃討残り回数")
            if type(Turbulent_buff_count) == "number" then
                if tonumber(Turbulent_buff_count) >= 1 then -- or type(Turbulent_buff_count) ~= "string"
                    Turbulent_buff:SetColorTone("FF999900")
                end
            end
        end
        local memo = gb:CreateOrGetControl('edit', 'memo' .. pcName, 630, x - 5, 100, 25)
        AUTO_CAST(memo)
        memo:SetFontName("white_16_ol")
        memo:SetTextAlign("center", "center")
        memo:SetEventScript(ui.ENTERKEY, "indun_list_viewer_memo_save")
        memo:SetEventScriptArgString(ui.ENTERKEY, pcName)

        local memoData = charData.memo

        memo:SetText(memoData)

        local display = gb:CreateOrGetControl('checkbox', 'display' .. pcName, 740, x - 5, 25, 25)
        AUTO_CAST(display)
        display:SetEventScript(ui.LBUTTONUP, "indun_list_viewer_display_save")
        display:SetEventScriptArgString(ui.LBUTTONUP, pcName)

        local check = charData.check

        display:SetCheck(check)

        x = x + 25
    end
    local cnt = #g.settings.charactors
    local framex = cnt * 25

    icframe:Resize(800, framex + 70)
    gb:Resize(800, framex + 15)
    gb:SetEventScript(ui.RBUTTONUP, "indun_list_viewer_close")
    gb:SetEventScript(ui.LBUTTONUP, "indun_list_viewer_close")

    icframe:ShowWindow(1)

end

function indun_list_viewer_close(frame)
    local topframe = frame:GetTopParentFrame();
    topframe:ShowWindow(0)

end

function indun_list_viewer_display_save(frame, ctrl, argStr, argNum)
    local ischeck = ctrl:IsChecked()
    for _, charData in ipairs(g.settings.charactors) do
        local pcName = charData.name
        if pcName == argStr then
            charData.check = ischeck
        end
    end

    indun_list_viewer_save_settings()
    -- indun_list_viewer_load_settings()
end

function indun_list_viewer_memo_save(frame, ctrl, argStr, argNum)
    local text = ctrl:GetText()

    for _, charData in ipairs(g.settings.charactors) do
        local pcName = charData.name
        if pcName == argStr then
            charData.memo = text
        end
    end
    ui.SysMsg("MEMO registered.")

    indun_list_viewer_save_settings()
    -- indun_list_viewer_load_settings()

end

