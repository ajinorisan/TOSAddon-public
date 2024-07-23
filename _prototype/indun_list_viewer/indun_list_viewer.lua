-- v1.0.0 indun_panelから機能独立
-- v1.0.1 作り直し。instantccと連携、instantcc入れてたらバラック順に並び替え。
-- v1.0.2 CCボタン追加。クローズボタンの位置調整。
-- v1.0.3 クローズボタンを戻した。ツールチップ追加。
-- v1.0.4 ゲームスタート時の不可軽減
-- v1.0.5 ゲーム立ち上げ時の初期化処理がバグってたのを修正。
-- v1.0.6 メレジナオート足した。
-- v1.0.7 アップデートだと正常に動くけどクリーンインストールだとおそらく動かなかったのを修正。
-- v1.0.8 メレジナ掃討の誤字修正。仕方ない人間だもの。のりお
-- v1.0.9 ICC入れてる時に職アイコンでCC出来る様に。自前でキャラ順並べる様に。
-- v1.1.0 ICCあるなし判定バグってたの修正
-- v1.1.1 一部のユーザーで開く時重いの修正したい。僕はならない。なんでや。
-- v1.1.2 スクロールモードを選べる様に。職アイコンを代表キャラに。フレーム閉じた時にボタン消えるバグ修正。
-- v1.1.3 キャラ削除に対応。
-- v1.1.4 スロットアイコンからinstantCCを使ってキャラチェンした場合に順番バグるの修正。
-- v1.1.5 まれにsettingsが初期化されるのを直したと思うけどわからん。挙動見直しボタン押した時に情報集める様に。
-- v1.1.6 情報集めるポイント修正
-- v1.1.7 やっぱりFPS_UPDATE使って情報収集
local addonName = "indun_list_viewer"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.1.7"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)
g.new_settingsFileLoc = string.format('../addons/%s/new_settings.json', addonNameLower)

g.logpath = string.format('../addons/%s/log.txt', addonNameLower)

local acutil = require("acutil")
local os = require("os")
local json = require("json")
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

function indun_list_viewer_load_settings()
    local file = io.open(g.new_settingsFileLoc, "r")
    if file then
        local content = file:read("*all")
        file:close()

        g.settings = json.decode(content)
    else
        g.settings = {
            time = 1702846800,
            reset = false,
            mode = 0
        }
        acutil.saveJSON(g.new_settingsFileLoc, g.settings)
    end

    local accountInfo = session.barrack.GetMyAccount()
    local barrackPCCount = accountInfo:GetBarrackPCCount()

    for i = 0, barrackPCCount - 1 do
        local barrackPCInfo = accountInfo:GetBarrackPCByIndex(i)
        local barrackPCName = barrackPCInfo:GetName()

        local cnt = accountInfo:GetPCCount()
        for j = 0, cnt - 1 do
            local pcInfo = accountInfo:GetPCByIndex(j)
            local pcApc = pcInfo:GetApc()
            local pcName = pcApc:GetName()
            local pccid = pcInfo:GetCID()

            if barrackPCName == pcName then

                g.change[pcName] = pccid
                local changeFileLoc = string.format('../addons/%s/change.json', addonNameLower)
                acutil.saveJSON(changeFileLoc, g.change)

                if not g.settings[pccid] then
                    g.settings[pccid] = {
                        name = pcName,
                        layer = g.layer or 9,
                        order = j or 99,
                        hide = false,
                        memo = ""
                    }
                end
            end
        end
    end
    g.layer = nil
    -- ループ外で一度だけ呼び出し.

    acutil.saveJSON(g.new_settingsFileLoc, g.settings)

    local function sortByLayerAndOrder(a, b)
        if a.layer ~= b.layer then
            return a.layer < b.layer
        else
            return a.order < b.order
        end
    end

    -- ソートの準備
    g.sortedSettings = {}
    for pccid, data in pairs(g.settings) do
        if type(data) == "table" and data.layer and data.order then
            data.cid = pccid
            table.insert(g.sortedSettings, data)
        end
    end

    -- ソート
    table.sort(g.sortedSettings, sortByLayerAndOrder)

    -- 並べ替え後の結果を表示（デバッグ用）
    for _, data in ipairs(g.sortedSettings) do
        print(string.format("Name: %s, Order: %d, Layer: %d", data.name, data.order, data.layer))
    end

end

g.loaded = false
function INDUN_LIST_VIEWER_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame
    g.settings = g.settings or {}
    g.cid = session.GetMySession():GetCID();
    g.charname = GETMYPCNAME()
    g.lang = option.GetCurrentCountry()
    g.change = g.change or {}

    local pc = GetMyPCObject();
    local curMap = GetZoneName(pc)
    local mapCls = GetClass("Map", curMap)
    if mapCls.MapType == "City" then

        addon:RegisterMsg('GAME_START', "indun_list_viewer_load_settings")
        addon:RegisterMsg('GAME_START', "indun_list_viewer_frame_init")
        if g.loaded == true then
            addon:RegisterMsg('GAME_START', "indun_list_viewer_raid_reset_time")
        end
        if g.loaded == false then
            g.loaded = true
        end
        -- addon:RegisterMsg('GAME_START', "indun_list_viewer_get_raid_count")
        -- addon:RegisterMsg('GAME_START_3SEC', "indun_list_viewer_get_count_loginname")
        -- addon:RegisterMsg('FPS_UPDATE', "indun_list_viewer_get_raid_count")
        -- g.SetupHook(indun_list_viewer_STATUS_SELET_REPRESENTATION_CLASS, "STATUS_SELET_REPRESENTATION_CLASS")
        -- g.SetupHook(indun_list_viewer_BARRACK_TO_GAME, "BARRACK_TO_GAME")

    end
end

function indun_list_viewer_raid_reset_time()
    local currentTime = os.time()
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

    local elapsed_time = currentTime - g.settings.time
    local nextreset = 604800 -- 次の月曜日の6時までの秒数
    if elapsed_time > nextreset then
        g.settings.time = mondayAM6
        acutil.saveJSON(g.new_settingsFileLoc, g.settings)
        indun_list_viewer_raid_reset()
        return
    end
    indun_list_viewer_get_raid_count()
end

function indun_list_viewer_raid_reset()
    local accountInfo = session.barrack.GetMyAccount()
    local barrackPCCount = accountInfo:GetBarrackPCCount()

    for i = 0, barrackPCCount - 1 do
        local barrackPCInfo = accountInfo:GetBarrackPCByIndex(i)
        local barrackPCName = barrackPCInfo:GetName()
        local cid = g.change[barrackPCName]
        local path = string.format('../addons/%s/%s.json', addonNameLower, cid)
        local file = io.open(path, "r")
        if file then
            file:close()
            local personal = {
                S_H = "-",
                S_N = "-",
                U_H = "-",
                U_N = "-",
                R_H = "-",
                R_N = "-",
                T_H = "-",
                T_N = "-",
                M_H = "-",
                M_N = "-"
            }
            acutil.saveJSON(path, personal)
        end
    end

    if g.lang == "Japanese" then
        ui.SysMsg("レイドの回数を初期化しました。")
    else
        ui.SysMsg("Raid counts were initialized.")
    end
    indun_list_viewer_get_raid_count()
end

function indun_list_viewer_get_raid_count()

    local function createData()
        local data = {
            S_H = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 690).PlayPerResetType),
            S_N = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 688).PlayPerResetType),
            U_H = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 687).PlayPerResetType),
            U_N = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 685).PlayPerResetType),
            R_H = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 681).PlayPerResetType),
            R_N = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 679).PlayPerResetType),
            T_H = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 678).PlayPerResetType),
            T_N = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 676).PlayPerResetType),
            M_H = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 697).PlayPerResetType),
            M_N = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 695).PlayPerResetType)
        }

        return data
    end

    local function insertbuff()
        local buffframe = ui.GetFrame("buff")
        local handle = session.GetMyHandle()
        local buffslotset = GET_CHILD_RECURSIVELY(buffframe, "buffslot")
        local buffslotcount = buffslotset:GetChildCount()

        -- 複数のバッファIDをリストとして指定
        local sweepbuff_table = {
            R_S = 80015,
            T_S = {80016, 80017}, -- 複数のバッファIDをリストとして指定
            U_S = 80030,
            S_S = 80031,
            M_S = 80032
        }

        local buffs = {}

        for raid in pairs(sweepbuff_table) do
            buffs[raid] = 0
        end

        for i = 0, buffslotcount - 1 do
            local child = buffslotset:GetChildByIndex(i)
            local icon = child:GetIcon()
            local iconinfo = icon:GetInfo()
            local type = iconinfo.type
            local buff = info.GetBuff(handle, iconinfo.type)

            for raid, buffid in pairs(sweepbuff_table) do
                if type == buffid or (type == 80016 and raid == "T_S") or (type == 80017 and raid == "T_S") then
                    buffs[raid] = buff.over
                    break
                end
            end
        end

        return buffs
    end

    local path = string.format('../addons/%s/%s.json', addonNameLower, g.cid)

    local file = io.open(path, "r")
    local data = createData()
    local buffs = insertbuff()

    -- `data` テーブルに `buffs` を追加
    for k, v in pairs(buffs) do
        data[k] = v
    end

    -- ファイルが存在するかどうかをチェックし、ファイルが存在する場合は閉じる
    if file then
        file:close()
    end

    -- JSON をファイルに保存
    acutil.saveJSON(path, data)

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

    if g.lang == "Japanese" then
        btn:SetTextTooltip("{ol}Indun List Viewer{nl}キャラ毎のレイド回数表示{nl}" ..
                               "{@st45r14}※掃討はキャラ毎の最終ログイン時の値なので、期限切れなどで実際とは異なる場合があります")
    else
        btn:SetTextTooltip("{ol}Indun List Viewer{nl}Raid count display per character{nl}" ..
                               "{@st45r14}※The AutoClear is the value at the last login for each character{nl}" ..
                               "and may differ from the actual value due to expiration or other reasons.")
    end
end

function indun_list_viewer_title_frame_open()

    indun_list_viewer_get_raid_count()

    local frame = ui.CreateNewFrame("notice_on_pc", addonNameLower .. "list_frame", 0, 0, 10, 10)
    AUTO_CAST(frame)
    frame:RemoveAllChild()
    frame:SetLayerLevel(99);

    local titlegb = frame:CreateOrGetControl("groupbox", "titlegb", 0, 0, 10, 10)
    AUTO_CAST(titlegb)
    titlegb:SetSkinName("bg")
    titlegb:SetColorTone("FF000000");

    local charname_text = ""
    local hc_text = ""
    local ac_text = ""
    local titlegb_text = ""
    local mode_text = ""
    local displaytext = ""
    local memo = ""
    local display = ""

    if g.lang == "Japanese" then
        charname_text = "キャラクター名"
        hc_text = "ハード"
        ac_text = "オート ソロ / オート掃討"
        titlegb_text = "右クリックで閉じます"
        mode_text = "チェックを入れるとスクロールモードに切替"
        displaytext = "チェックしたキャラはレイド回数非表示"
        memo = "メモ"
        display = "表示"
    else
        charname_text = "CharacterName"
        hc_text = "Hard Count"
        ac_text = "Auto or Solo Count/ AutoClearBuff Count"
        titlegb_text = "Right-click to close"
        mode_text = "Switch to scroll mode when checked"
        displaytext = "Checked characters hide raid count"
        memo = "Memo"
        display = "Display"
    end

    local charname = titlegb:CreateOrGetControl("richtext", "charname", 20, 35)
    AUTO_CAST(charname)
    charname:SetText("{ol}" .. charname_text)

    local hard_text = titlegb:CreateOrGetControl("richtext", "hard_text", 200, 5)
    AUTO_CAST(hard_text)
    hard_text:SetText("{ol}" .. hc_text)

    local auto_text = titlegb:CreateOrGetControl("richtext", "auto_text", 360, 5)
    AUTO_CAST(auto_text)
    auto_text:SetText("{ol}" .. ac_text)

    local icon_table = {"icon_item_misc_boss_Slogutis", "icon_item_misc_boss_Upinis", "icon_item_misc_boss_Roze",
                        "icon_item_misc_high_falouros", "icon_item_misc_high_transmutationSpreader",
                        "icon_item_misc_merregina_blackpearl", "icon_item_misc_boss_Slogutis",
                        "icon_item_misc_boss_Upinis", "icon_item_misc_boss_Roze", "icon_item_misc_falouros",
                        "icon_item_misc_transmutationSpreader"}

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
    for i = 6, 11 do
        if i <= 9 then
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
    local frameWidth = 900 + 70

    frame:SetSkinName("bg")

    if g.settings.mode == 1 then
        frame:SetPos(665, 35)
    else
        frame:SetPos(665, 5)
    end
    titlegb:Resize(900 + 70, 55)
    titlegb:SetEventScript(ui.RBUTTONUP, "indun_list_viewer_close")
    titlegb:SetTextTooltip("{ol}" .. titlegb_text)

    local close = titlegb:CreateOrGetControl("button", "close", 0, 0, 20, 20)
    AUTO_CAST(close)
    close:SetImage("testclose_button")
    close:SetGravity(ui.RIGHT, ui.TOP)
    close:SetEventScript(ui.LBUTTONUP, "indun_list_viewer_close")

    local ccbtn = titlegb:CreateOrGetControl('button', 'ccbtn', 40, 5, 30, 30)
    AUTO_CAST(ccbtn)
    ccbtn:SetSkinName("None")
    ccbtn:SetText("{img barrack_button_normal 30 30}")
    ccbtn:SetEventScript(ui.LBUTTONUP, "APPS_TRY_MOVE_BARRACK")

    local mode_check = titlegb:CreateOrGetControl('checkbox', 'mode_check', 80, 5, 30, 30)
    AUTO_CAST(mode_check)

    mode_check:SetCheck(g.settings.mode)
    mode_check:SetEventScript(ui.LBUTTONUP, "indun_list_viewer_modechange")
    mode_check:SetTextTooltip("{ol}" .. mode_text)

    local memo_text = titlegb:CreateOrGetControl("richtext", "memo_text", 700 + 70, 35)
    AUTO_CAST(memo_text)
    memo_text:SetText("{ol}" .. memo)

    local display_text = titlegb:CreateOrGetControl("richtext", "display_text", 820 + 70, 35)
    AUTO_CAST(display_text)
    display_text:SetText("{ol}" .. display)
    display_text:SetTextTooltip("{ol}" .. displaytext)

    frame:ShowWindow(1)

    indun_list_viewer_frame_open(frame)
end

function indun_list_viewer_close(frame)

    local frame = ui.GetFrame(addonNameLower .. "list_frame")
    frame:ShowWindow(0)

end

function indun_list_viewer_frame_open(frame)
    -- g.sortedSettings
    local gb = frame:CreateOrGetControl("groupbox", "gb", 0, 55, 10, 10)
    AUTO_CAST(gb)
    gb:SetSkinName("bg")
    gb:SetColorTone("FF000000")

    local myHandle = session.GetMyHandle()
    local myCharName = info.GetName(myHandle)
    local x = 6
    local cnt = 0

    local cid_table = {}
    local accountInfo = session.barrack.GetMyAccount()
    local barrackPCCount = accountInfo:GetBarrackPCCount()

    for _, data in ipairs(g.sortedSettings) do
        local pcname = data.name
        local cid = data.cid
        for i = 0, barrackPCCount - 1 do

            local path = string.format('../addons/%s/%s.json', addonNameLower, cid)
            local file = io.open(path, "r")
            if file then
                local content = file:read("*all")
                file:close()
                local decoded = json.decode(content)
                cid_table = decoded
                cnt = cnt + 1
                local name = gb:CreateOrGetControl("richtext", cid, 35, x)
                AUTO_CAST(name)

                if myCharName == pcname then
                    name:SetText("{ol}{#FF4500}" .. pcname)
                else
                    name:SetText("{ol}" .. pcname)
                end

                local line = gb:CreateOrGetControl("labelline", "line" .. cid, 30, x - 7, 850 + 60, 2)
                line:SetSkinName("labelline_def_3")
                if not data.hide then
                    local S_H = gb:CreateOrGetControl("richtext", "S_H" .. cid, 175, x)
                    S_H:SetText("{ol}{s14}( " .. cid_table.S_H .. " )")
                    if cid_table.S_H == 1 then
                        S_H:SetColorTone("FF990000");
                    else
                        S_H:SetColorTone("FFFFFFFF");
                    end

                    local U_H = gb:CreateOrGetControl("richtext", "U_H" .. cid, 205, x)
                    U_H:SetText("{ol}{s14}( " .. cid_table.U_H .. " )")
                    if cid_table.U_H == 1 then
                        U_H:SetColorTone("FF990000");
                    else
                        U_H:SetColorTone("FFFFFFFF");
                    end

                    local R_H = gb:CreateOrGetControl("richtext", "R_H" .. cid, 235, x)
                    R_H:SetText("{ol}{s14}( " .. cid_table.R_H .. " )")
                    if cid_table.R_H == 1 then
                        R_H:SetColorTone("FF990000");
                    else
                        R_H:SetColorTone("FFFFFFFF");
                    end

                    local T_H = gb:CreateOrGetControl("richtext", "T_H" .. cid, 285, x)
                    T_H:SetText("{ol}{s14}( " .. cid_table.T_H .. " )")
                    if cid_table.T_H == 2 then
                        T_H:SetColorTone("FF990000");
                    else
                        T_H:SetColorTone("FFFFFFFF");
                    end

                    local M_N = gb:CreateOrGetControl("richtext", "M_N" .. cid, 350, x)
                    if cid_table.M_N == 2 then
                        M_N:SetText("{ol}{s14}{#990000}( " .. cid_table.M_N .. " ){/}" .. "{ol}{s14}/")
                    else
                        M_N:SetText("{ol}{s14}{#FFFFFF}( " .. cid_table.M_N .. " ){/}" .. "{ol}{s14}/")
                    end

                    local M_S = gb:CreateOrGetControl("richtext", "M_S" .. cid, 385, x)
                    M_S:SetText("{ol}{s14}( " .. cid_table.M_S .. " )")
                    if cid_table.M_S >= 1 then
                        M_S:SetColorTone("FF990000");
                    else
                        M_S:SetColorTone("FFFFFFFF");
                    end

                    local S_N = gb:CreateOrGetControl("richtext", "S_N" .. cid, 420, x)
                    if cid_table.S_N == 2 then
                        S_N:SetText("{ol}{s14}{#990000}( " .. cid_table.S_N .. " ){/}" .. "{ol}{s14}/")
                    else
                        S_N:SetText("{ol}{s14}{#FFFFFF}( " .. cid_table.S_N .. " ){/}" .. "{ol}{s14}/")
                    end

                    local S_S = gb:CreateOrGetControl("richtext", "S_S" .. cid, 455, x)
                    S_S:SetText("{ol}{s14}( " .. cid_table.S_S .. " )")
                    if cid_table.S_S >= 1 then
                        S_S:SetColorTone("FF990000");
                    else
                        S_S:SetColorTone("FFFFFFFF");
                    end

                    local U_N = gb:CreateOrGetControl("richtext", "U_N" .. cid, 490, x)
                    if cid_table.U_N == 2 then
                        U_N:SetText("{ol}{s14}{#990000}( " .. cid_table.U_N .. " ){/}" .. "{ol}{s14}/")
                    else
                        U_N:SetText("{ol}{s14}{#FFFFFF}( " .. cid_table.U_N .. " ){/}" .. "{ol}{s14}/")
                    end

                    local U_S = gb:CreateOrGetControl("richtext", "U_S" .. cid, 525, x)
                    U_S:SetText("{ol}{s14}( " .. cid_table.U_S .. " )")
                    if cid_table.U_S >= 1 then
                        U_S:SetColorTone("FF990000");
                    else
                        U_S:SetColorTone("FFFFFFFF");
                    end

                    local R_N = gb:CreateOrGetControl("richtext", "R_N" .. cid, 560, x)
                    if cid_table.R_N == 2 then
                        R_N:SetText("{ol}{s14}{#990000}( " .. cid_table.R_N .. " ){/}" .. "{ol}{s14}/")
                    else
                        R_N:SetText("{ol}{s14}{#FFFFFF}( " .. cid_table.R_N .. " ){/}" .. "{ol}{s14}/")
                    end

                    local R_S = gb:CreateOrGetControl("richtext", "R_S" .. cid, 595, x)
                    R_S:SetText("{ol}{s14}( " .. cid_table.R_S .. " )")
                    if cid_table.R_S >= 1 then
                        R_S:SetColorTone("FF990000");
                    else
                        R_S:SetColorTone("FFFFFFFF");
                    end

                    local T_N = gb:CreateOrGetControl("richtext", "T_N" .. cid, 630, x)
                    if cid_table.T_N == 4 then
                        T_N:SetText("{ol}{s14}{#990000}( " .. cid_table.T_N .. " ){/}" .. "{ol}{s14}/")
                    else
                        T_N:SetText("{ol}{s14}{#FFFFFF}( " .. cid_table.T_N .. " ){/}" .. "{ol}{s14}/")
                    end

                    local T_S = gb:CreateOrGetControl("richtext", "T_S" .. cid, 665, x)
                    T_S:SetText("{ol}{s14}( " .. cid_table.T_S .. " )")
                    if cid_table.T_S >= 1 then
                        T_S:SetColorTone("FF990000");
                    else
                        T_S:SetColorTone("FFFFFFFF");
                    end

                    local memo = gb:CreateOrGetControl('edit', 'memo' .. cid, 630 + 70 + 5, x - 5, 200, 25)
                    AUTO_CAST(memo)
                    memo:SetFontName("white_14_ol")
                    memo:SetTextAlign("left", "center")
                    memo:SetSkinName("inventory_serch"); -- test_edit_skin--test_weight_skin--inventory_serch
                    memo:SetEventScript(ui.ENTERKEY, "indun_list_viewer_memo_save")
                    memo:SetEventScriptArgString(ui.ENTERKEY, cid)
                    local memoData = data.memo
                    memo:SetText(memoData)

                    local display = gb:CreateOrGetControl('checkbox', 'display' .. cid, 840 + 70, x - 5, 25, 25)
                    AUTO_CAST(display)
                    display:SetEventScript(ui.LBUTTONUP, "indun_list_viewer_display_save")
                    display:SetEventScriptArgString(ui.LBUTTONUP, cid)
                    local check = 1
                    if not data.hide then
                        check = 0
                    end
                    display:SetCheck(check)

                end
                x = x + 25
                break
            end
        end

    end

    local framex = cnt * 25

    frame:Resize(900 + 70, framex + 70)
    gb:Resize(900 + 70, framex + 15)
    gb:SetEventScript(ui.RBUTTONUP, "indun_list_viewer_close")
    gb:SetEventScript(ui.LBUTTONUP, "indun_list_viewer_close")
    if g.settings.mode == 1 then
        frame:Resize(900 + 70, framex / 2 + 70 + 185)
        gb:Resize(900 + 70, framex / 2 + 15 + 175)
    else
        gb:Resize(900 + 70, framex + 15)
    end
    frame:ShowWindow(1)

end

function indun_list_viewer_modechange(frame, ctrl, argStr, argNum)
    local ischeck = ctrl:IsChecked()
    g.settings.mode = ischeck

    acutil.saveJSON(g.new_settingsFileLoc, g.settings)
end

function indun_list_viewer_display_save(frame, ctrl, argStr, argNum)
    local ischeck = ctrl:IsChecked()
    local tf = true
    for _, data in ipairs(g.sortedSettings) do
        local cid = data.cid
        if cid == argStr then
            g.settings[cid].hide = ischeck
            acutil.saveJSON(g.new_settingsFileLoc, g.settings)
            break
        end
    end

    indun_list_viewer_save_settings()
    -- indun_list_viewer_load_settings()
end

function indun_list_viewer_memo_save(frame, ctrl, argStr, argNum)

    local text = ctrl:GetText()
    for _, data in ipairs(g.sortedSettings) do
        local cid = data.cid
        if cid == argStr then
            g.settings[cid].memo = text
            acutil.saveJSON(g.new_settingsFileLoc, g.settings)
            break
        end
    end
    if g.lang == "Japanese" then
        ui.SysMsg("メモを登録しました。")
    else
        ui.SysMsg("MEMO registered.")
    end
end

function indun_list_viewer_STATUS_SELET_REPRESENTATION_CLASS(selectedIndex, selectedKey)
    -- print(tostring(selectedKey))

    local LoginName = session.GetMySession():GetPCApc():GetName()
    -- print(LoginName)
    for _, charData in ipairs(g.settings.charactors) do
        if charData.name == LoginName then
            local mainSession = session.GetMainSession();
            local pcJobInfo = mainSession:GetPCJobInfo();
            local jobCount = pcJobInfo:GetJobCount();
            charData.jobid = ""
            for i = 0, jobCount - 1 do
                local jobInfo = pcJobInfo:GetJobInfoByIndex(i);
                charData.jobid = charData.jobid .. "/" .. tonumber(jobInfo.jobID)
                -- local jobCls = GetClassByType('Job', jobInfo.jobID);
                -- ui.AddDropListItem(jobCls.Name, nil, jobCls.ClassID);
            end
            charData.president_jobid = tonumber(selectedKey)

            indun_list_viewer_save_settings()
            break
        end
    end

    ChangeRepresentationClass(selectedKey);
    -- base["STATUS_SELET_REPRESENTATION_CLASS"](selectedIndex, selectedKey)
end

function indun_list_viewer_removing_character()
    local accountInfo = session.barrack.GetMyAccount()
    local cnt = accountInfo:GetBarrackPCCount()
    local currentCharacters = {}

    for i = 0, cnt - 1 do
        local pcInfo = accountInfo:GetBarrackPCByIndex(i)
        local pcName = pcInfo:GetName()
        -- print(pcName)
        currentCharacters[pcName] = true
    end

    -- settings.charactors から存在しないキャラクターを削除
    for i = #g.settings.charactors, 1, -1 do
        local charData = g.settings.charactors[i]
        if not currentCharacters[charData.name] then
            -- print(string.format("[%s] Removing character: %s", addonNameLower, charData.name))
            table.remove(g.settings.charactors, i)
        end
    end
    indun_list_viewer_save_settings()
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
                TurbulentN = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 676).PlayPerResetType),
                MerreginaN = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 695).PlayPerResetType)
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

            local sweepbuff_table = {80015, 80016, 80017, 80030, 80031, 80032}

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

function indun_list_viewer_get_sweep_count()
    local accountInfo = session.barrack.GetMyAccount()
    local cnt = accountInfo:GetBarrackPCCount()

    for i = 0, cnt - 1 do
        local pcInfo = accountInfo:GetBarrackPCByIndex(i)
        local pcName = pcInfo:GetName()
        local LoginName = session.GetMySession():GetPCApc():GetName()

        local sweepbuff_table = {80015, 80016, 80017, 80030, 80031, 80032}

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

function indun_list_viewer_INSTANTCC_DO_CC(frame, ctrl, cid, layer)

    local frame = ui.GetFrame("indun_list_viewer")
    frame:ShowWindow(0)
    INSTANTCC_DO_CC(cid, layer)
    g.layer = nil
end

