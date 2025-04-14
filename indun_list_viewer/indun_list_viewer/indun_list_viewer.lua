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
-- v1.1.8 作り直して最適化。資材アイコンからレイド入れる様に。サブアカでもバグらない様に。
-- v1.1.9 520環境に作り替え。cidでセーブデータ保持すると制約あるのでnameで保持に変更。
-- v1.2.0 instantccとの連携コードミスってたので修正。
-- v1.2.1 フォルダ作るコードをアドオン導入時のみに。
-- v1.2.2 表示するレイドを選べる様に。UI変更
-- v1.2.3 レイド選択の初期設定が出来ていなかったので、修正
-- v1.2.4 レダニア追加。表示崩れるバグ直した。
-- v1.2.5 メモ欄バグってたの修正
-- v1.2.6 再修正。。。
-- v1.2.7 レイドカウント取るタイミング修正
local addonName = "indun_list_viewer"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.2.7"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

local acutil = require("acutil")
local json = require("json")
local os = require("os")

function g.mkdir_new_folder()
    local folder_path = string.format("../addons/%s", addonNameLower)
    local file_path = string.format("../addons/%s/mkdir.txt", addonNameLower)
    local file = io.open(file_path, "r")
    if not file then
        os.execute('mkdir "' .. folder_path .. '"')
        file = io.open(file_path, "w")
        if file then
            file:write("A new file has been created")
            file:close()
        end
    else
        file:close()
    end
end
g.mkdir_new_folder()

local function unicode_to_codepoint(char)
    local codepoint = utf8.codepoint(char)
    return string.format("%X", codepoint)
end

local function convert_to_ascii(input)
    local result = ""
    for char in input:gmatch(utf8.charpattern) do
        result = result .. unicode_to_codepoint(char)
    end
    return result
end

local input = GETMYFAMILYNAME()
local output = convert_to_ascii(input)
g.settings_file_location = string.format('../addons/%s/%s.json', addonNameLower, output .. "2410")

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
    acutil.saveJSON(g.settings_file_location, g.settings)
end

function indun_list_viewer_load_settings()

    local file = io.open(g.settings_file_location, "r")
    if file then
        local content = file:read("*all")
        file:close()
        g.settings = json.decode(content)
    else
        g.settings = {
            reset_time = 1702846800,
            display_mode = "full"
        }
    end

    local account_info = session.barrack.GetMyAccount()
    local barrack_pc_count = account_info:GetBarrackPCCount()

    for i = 0, barrack_pc_count - 1 do
        local barrack_pc_info = account_info:GetBarrackPCByIndex(i)
        local barrack_pc_name = barrack_pc_info:GetName()
        if not g.settings[barrack_pc_name] then
            g.settings[barrack_pc_name] = {
                pc_name = barrack_pc_name,
                layer = 9,
                order = 99,
                hide = false,
                memo = "",
                president_jobid = "",
                jobid = "",
                raid_count = {
                    N_H = "?",
                    N_A = "?",
                    G_H = "?",
                    G_A = "?",
                    M_H = "?",
                    M_A = "?",
                    S_H = "?",
                    S_A = "?",
                    U_H = "?",
                    U_A = "?"
                },
                auto_clear_count = {
                    N_S = "?",
                    G_S = "?",
                    M_S = "?",
                    U_S = "?",
                    S_S = "?"
                }
            }
        end
        if not g.settings[barrack_pc_name]["raid_count"].R_H then
            g.settings[barrack_pc_name]["raid_count"].R_H = "?"
            g.settings[barrack_pc_name]["raid_count"].R_A = "?"
            g.settings[barrack_pc_name]["auto_clear_count"].R_S = "?"
        end
    end

    indun_list_viewer_save_settings()
    indun_list_viewer_sort_characters(account_info)

    if g.load == true then
        local now = os.time()
        if now > g.settings.reset_time then
            indun_list_viewer_raid_reset()
        end
    end
    if g.load == false then
        g.load = true
    end

    g.cid = session.GetMySession():GetCID();
    g.lang = option.GetCurrentCountry()
    g.login_name = session.GetMySession():GetPCApc():GetName()
    indun_list_viewer_frame_init()
end

function indun_list_viewer_raid_reset()
    local account_info = session.barrack.GetMyAccount()
    local barrack_pc_count = account_info:GetBarrackPCCount()

    for i = 0, barrack_pc_count - 1 do
        local barrack_pc_info = account_info:GetBarrackPCByIndex(i)
        local barrack_pc_name = barrack_pc_info:GetName()

        g.settings[barrack_pc_name]["raid_count"] = {
            N_H = "?",
            N_A = "?",
            G_H = "?",
            G_A = "?",
            M_H = "?",
            M_A = "?",
            S_H = "?",
            S_A = "?",
            U_H = "?",
            U_A = "?",
            R_H = "?",
            R_A = "?"
        }
    end
    g.settings.reset_time = indun_list_viewer_get_reset_time()
    indun_list_viewer_save_settings()

    if g.lang == "Japanese" then
        ui.SysMsg("[ILV]レイドの回数を初期化しました。")
    else
        ui.SysMsg("[ILV]Raid counts were initialized.")
    end
end

function indun_list_viewer_sort_characters(account_info)

    local layer_pc_count = account_info:GetPCCount()
    for order = 0, layer_pc_count - 1 do
        local pc_info = account_info:GetPCByIndex(order)
        local pc_apc = pc_info:GetApc()
        local pc_name = pc_apc:GetName()
        local pc_cid = pc_info:GetCID()
        g.settings[pc_name].cid = pc_cid
        g.settings[pc_name].order = order
        if g.layer ~= nil and g.layer ~= g.settings[pc_name].layer then
            g.settings[pc_name].layer = g.layer
        end
    end
    g.layer = nil

    indun_list_viewer_save_settings()

    g.sorted_settings = {}
    for _, data in pairs(g.settings) do
        if type(data) == "table" then
            table.insert(g.sorted_settings, data)
        end
    end

    local function sort_layer_order(a, b)
        if a.layer ~= b.layer then
            return a.layer < b.layer
        else
            return a.order < b.order
        end
    end

    table.sort(g.sorted_settings, sort_layer_order)
end

function indun_list_viewer_BARRACK_TO_GAME()
    local frame = ui.GetFrame("barrack_charlist")
    local layer = tonumber(frame:GetUserValue("SelectBarrackLayer"))
    g.layer = layer

    local start_frame = ui.GetFrame("barrack_gamestart")
    local hide_check = GET_CHILD_RECURSIVELY(start_frame, "hidelogin")
    AUTO_CAST(hide_check)
    hide_check:SetCheck(1)
    barrack.SetHideLogin(1)
    base["BARRACK_TO_GAME"]()
end

g.load = false
function INDUN_LIST_VIEWER_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame

    local pc = GetMyPCObject()
    local current_map = GetZoneName(pc)
    local map_class = GetClass("Map", current_map)
    if map_class.MapType == "City" then

        g.SetupHook(indun_list_viewer_BARRACK_TO_GAME, "BARRACK_TO_GAME")
        addon:RegisterMsg('GAME_START', "indun_list_viewer_load_settings")

        addon:RegisterMsg('GAME_START_3SEC', "indun_list_viewer_get_raid_count")
        acutil.setupEvent(addon, "APPS_TRY_MOVE_BARRACK", "indun_list_viewer_get_raid_count")
        acutil.setupEvent(addon, "APPS_TRY_LOGOUT", "indun_list_viewer_get_raid_count")
        acutil.setupEvent(addon, "APPS_TRY_EXIT", "indun_list_viewer_get_raid_count")

        acutil.setupEvent(addon, "STATUS_SELET_REPRESENTATION_CLASS",
            "indun_list_viewer_STATUS_SELET_REPRESENTATION_CLASS")

    end
end

function indun_list_viewer_get_raid_count()
    -- CHAT_SYSTEM("TEST")
    local function create_data()
        local data = {
            R_H = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 718).PlayPerResetType),
            R_A = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 716).PlayPerResetType),
            N_H = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 709).PlayPerResetType),
            N_A = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 707).PlayPerResetType),
            G_H = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 712).PlayPerResetType),
            G_A = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 710).PlayPerResetType),
            M_H = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 697).PlayPerResetType),
            M_A = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 695).PlayPerResetType),
            S_H = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 690).PlayPerResetType),
            S_A = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 688).PlayPerResetType),
            U_H = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 687).PlayPerResetType),
            U_A = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 685).PlayPerResetType)
        }

        return data
    end

    local data = create_data()
    g.settings[g.login_name]["raid_count"] = data

    local sweepbuff_table = {
        R_S = 80039,
        N_S = 80035,
        G_S = 80037,
        M_S = 80032,
        U_S = 80030,
        S_S = 80031
    }
    local my_handle = session.GetMyHandle()

    local buff_frame = ui.GetFrame("buff")
    local buff_slotset = GET_CHILD_RECURSIVELY(buff_frame, "buffslot")
    local buff_slotcount = buff_slotset:GetChildCount()

    for key, value in pairs(sweepbuff_table) do
        g.settings[g.login_name]["auto_clear_count"][key] = 0

        for i = 0, buff_slotcount - 1 do
            local child = buff_slotset:GetChildByIndex(i)
            local icon = child:GetIcon()
            local icon_info = icon:GetInfo()
            local buff_id = icon_info.type

            if buff_id == value then
                local buff_class = info.GetBuff(my_handle, buff_id)
                g.settings[g.login_name]["auto_clear_count"][key] = buff_class.over
                break
            end
        end
    end

    indun_list_viewer_save_settings()
end

function indun_list_viewer_get_reset_time()
    local now = os.time()
    local date_table = os.date("*t", now)
    local current_day = date_table.wday
    local next_monday_timestamp

    if current_day == 2 and date_table.hour < 6 then
        next_monday_timestamp = os.time({
            year = date_table.year,
            month = date_table.month,
            day = date_table.day,
            hour = 6,
            min = 0,
            sec = 0
        })
    else
        local days_to_next_monday = (9 - current_day) % 7
        if days_to_next_monday == 0 then
            days_to_next_monday = 7 -- 次週の月曜日に設定
        end

        local next_monday_date = os.date("*t", now + days_to_next_monday * 86400)
        next_monday_timestamp = os.time({
            year = next_monday_date.year,
            month = next_monday_date.month,
            day = next_monday_date.day,
            hour = 6,
            min = 0,
            sec = 0
        })
    end

    return next_monday_timestamp
end

local check_table = {"Redania_H", "Neringa_H", "Golem_H", "Merregina_H", "Slogutis_H", "Upinis_H", "Redania_S",
                     "Neringa_S", "Golem_S", "Merregina_S", "Slogutis_S", "Upinis_S", "Memo"}

function indun_list_viewer_frame_init()

    local frame = ui.GetFrame("indun_list_viewer")
    frame:SetSkinName('None')
    frame:SetTitleBarSkin("None")
    frame:Resize(35, 35)
    frame:SetPos(665, 0)

    local open_button = frame:CreateOrGetControl('button', 'open_button', 0, 0, 35, 35)
    open_button:SetSkinName("None")
    open_button:SetText("{img sysmenu_sys 35 35}")
    open_button:SetEventScript(ui.LBUTTONDOWN, "indun_list_viewer_title_frame_open")

    if g.lang == "Japanese" then
        open_button:SetTextTooltip("{ol}Indun List Viewer{nl}キャラ毎のレイド回数表示{nl}{nl}" ..
                                       "{@st45r14}※掃討はキャラ毎の最終ログイン時の値なので、期限切れなどで実際とは異なる場合があります{nl}" ..
                                       "{@st45r14}※キャラの順番を並べるには一度バラックに戻る必要があります。(instant cc不可)")
    else
        open_button:SetTextTooltip("{ol}Indun List Viewer{nl}Raid count display per character{nl}{nl}" ..
                                       "{@st45r14}※The AutoClear is the value at the last login for each character{nl}" ..
                                       "and may differ from the actual value due to expiration or other reasons.{nl}" ..
                                       "You must return to the barracks once to rearrange the order of the characters.{nl}" ..
                                       "(instant cc not available)")
    end

    for i = 1, #check_table do
        if g.settings[tostring(check_table[i])] == nil then
            g.settings[tostring(check_table[i])] = 1
        end
    end
    indun_list_viewer_save_settings()
end
-- ゴーレムH712 A710 S711 ネリンガH709 A707 S708 

function indun_list_viewer_title_frame_open()

    indun_list_viewer_get_raid_count()
    local frame = ui.CreateNewFrame("notice_on_pc", addonNameLower .. "list_frame", 0, 0, 10, 10)
    AUTO_CAST(frame)
    frame:RemoveAllChild()
    frame:SetLayerLevel(99);
    frame:SetSkinName("test_frame_low")

    local title_gb = frame:CreateOrGetControl("groupbox", "title_gb", 0, 0, 10, 10)
    AUTO_CAST(title_gb)

    local texts = {
        japanese = {
            charcter_name = "キャラクター名",
            hard_raid = "ハード",
            auto_raid = "オート ソロ / オート掃討",
            mode_text = "チェックを入れるとスクロールモードに切替",
            display_text = "チェックしたキャラはレイド回数非表示",
            memo = "メモ",
            display = "表示"
        },
        etc = {
            charcter_name = "CharacterName",
            hard_raid = "Hard Count",
            auto_raid = "Auto or Solo Count/ AutoClearBuff Count",
            titlegb_text = "Right-click to close",
            mode_text = "Switch to scroll mode when checked",
            display_text = "Checked characters hide raid count",
            memo = "Memo",
            display = "Disp"
        }
    }

    local select_texts = g.lang == "Japanese" and texts.japanese or texts.etc

    local icon_table = {{
        icon_name = "icon_item_misc_boss_Redania",
        hard = 718,
        solo = 717,
        auto = 716
    }, {
        icon_name = "icon_item_misc_boss_DarkNeringa",
        hard = 709,
        solo = 708,
        auto = 707
    }, {
        icon_name = "icon_item_misc_boss_CrystalGolem",
        hard = 712,
        solo = 711,
        auto = 710
    }, {
        icon_name = "icon_item_misc_merregina_blackpearl",
        hard = 697,
        solo = 696,
        auto = 695
    }, {
        icon_name = "icon_item_misc_boss_Slogutis",
        hard = 690,
        solo = 689,
        auto = 688
    }, {
        icon_name = "icon_item_misc_boss_Upinis",
        hard = 687,
        solo = 686,
        auto = 685
    }}

    local x = 185
    for i = 1, 6 do

        if g.settings[tostring(check_table[i])] == 1 then
            local title_picture = title_gb:CreateOrGetControl('picture', "title_picture" .. i, x, 5, 30, 30);
            AUTO_CAST(title_picture)
            local icon_name = icon_table[i].icon_name
            title_picture:SetImage(icon_name)
            title_picture:SetEnableStretch(1)
            title_picture:EnableHitTest(1)
            title_picture:SetEventScript(ui.LBUTTONDOWN, "indun_list_viewer_enter_hard")
            title_picture:SetEventScriptArgNumber(ui.LBUTTONDOWN, icon_table[i].hard)
            title_picture:SetEventScriptArgString(ui.LBUTTONDOWN, "false")
            title_picture:SetTextTooltip(g.lang == "Japanese" and "左クリックでレイド画面表示{nl}" ..
                                             select_texts.hard_raid or "Left click to display raid screen{nl}" ..
                                             select_texts.hard_raid)

            x = x + 30
        end
    end
    x = x + 30
    for i = 7, 12 do

        if g.settings[tostring(check_table[i])] == 1 then
            local title_picture = title_gb:CreateOrGetControl('picture', "title_picture" .. i, x, 5, 30, 30);
            AUTO_CAST(title_picture)
            local icon_name = icon_table[i - 6].icon_name --
            title_picture:SetImage(icon_name)
            title_picture:SetEnableStretch(1)
            title_picture:EnableHitTest(1)
            title_picture:SetUserValue("SOLO", icon_table[i - 6].solo)
            title_picture:SetUserValue("AUTO", icon_table[i - 6].auto)
            title_picture:SetEventScript(ui.LBUTTONUP, "indun_list_viewer_enter_context")
            title_picture:SetTextTooltip(g.lang == "Japanese" and "左クリックでレイド画面表示{nl}" ..
                                             select_texts.auto_raid or "Left click to display raid screen{nl}" ..
                                             select_texts.auto_raid)

            x = x + 65
        end
    end

    local close_button = title_gb:CreateOrGetControl("button", "close_button", 0, 0, 20, 20)
    AUTO_CAST(close_button)
    close_button:SetImage("testclose_button")
    close_button:SetGravity(ui.LEFT, ui.TOP)
    close_button:SetEventScript(ui.LBUTTONUP, "indun_list_viewer_close")

    local cc_button = title_gb:CreateOrGetControl('button', 'cc_button', 40, 5, 30, 30)
    AUTO_CAST(cc_button)
    cc_button:SetSkinName("None")
    cc_button:SetText("{img barrack_button_normal 30 30}")
    cc_button:SetEventScript(ui.LBUTTONUP, "APPS_TRY_MOVE_BARRACK")

    function indun_list_viewer_config(frame, ctrl, str, num)

        local frame = ui.GetFrame(addonNameLower .. "list_frame")
        frame:RemoveAllChild()
        local config_gb = frame:CreateOrGetControl("groupbox", "config_gb", 10, 35, 10, 10)
        AUTO_CAST(config_gb)
        config_gb:SetSkinName("bg")
        config_gb:ShowWindow(1)

        local title_gb = frame:CreateOrGetControl("groupbox", "title_gb", 0, 0, 10, 10)
        AUTO_CAST(title_gb)
        local x = 185
        for i = 1, 6 do

            local title_picture = title_gb:CreateOrGetControl('picture', "title_picture" .. i, x, 5, 30, 30);
            AUTO_CAST(title_picture)
            local icon_name = icon_table[i].icon_name
            title_picture:SetImage(icon_name)
            title_picture:SetEnableStretch(1)
            title_picture:EnableHitTest(1)
            title_picture:SetTextTooltip("{ol}" .. select_texts.hard_raid)

            x = x + 30
        end

        x = x + 30
        for i = 7, 12 do

            local title_picture = title_gb:CreateOrGetControl('picture', "title_picture" .. i, x, 5, 30, 30);
            AUTO_CAST(title_picture)
            local icon_name = icon_table[i - 6].icon_name
            title_picture:SetImage(icon_name)
            title_picture:SetEnableStretch(1)
            title_picture:EnableHitTest(1)
            title_picture:SetTextTooltip("{ol}" .. select_texts.auto_raid)

            x = x + 65
        end

        local memo_text = title_gb:CreateOrGetControl("richtext", "memo_text", x, 10)
        AUTO_CAST(memo_text)
        memo_text:SetText("{ol}" .. select_texts.memo)

        local close_button = title_gb:CreateOrGetControl("button", "close_button", 0, 0, 20, 20)
        AUTO_CAST(close_button)
        close_button:SetImage("testclose_button")
        close_button:SetGravity(ui.LEFT, ui.TOP)
        close_button:SetEventScript(ui.LBUTTONUP, "indun_list_viewer_close")
        close_button:SetEventScriptArgNumber(ui.LBUTTONUP, 1)

        local text = config_gb:CreateOrGetControl("richtext", "text", 10, 10)
        AUTO_CAST(text)
        text:SetText("{ol}Display if checked")

        function indun_list_viewer_display_check(frame, ctrl, str, num)

            local ischeck = ctrl:IsChecked()
            g.settings[str] = ischeck
            indun_list_viewer_save_settings()
        end

        for i = 1, #check_table do
            -- print(tostring(check_table[i]))
            if g.settings[tostring(check_table[i])] == nil then
                g.settings[tostring(check_table[i])] = 1
            end
        end
        indun_list_viewer_save_settings()

        local x = 180
        for i = 1, 6 do

            local check_box = config_gb:CreateOrGetControl('checkbox', "check_box" .. i, x, 5, 30, 30);
            AUTO_CAST(check_box)
            check_box:SetCheck(g.settings[tostring(check_table[i])] or 1)
            check_box:SetEventScript(ui.LBUTTONDOWN, "indun_list_viewer_display_check")
            check_box:SetEventScriptArgString(ui.LBUTTONDOWN, check_table[i])

            x = x + 30
        end
        x = x + 30
        for i = 7, 13 do

            local check_box = config_gb:CreateOrGetControl('checkbox', "check_box" .. i, x, 5, 30, 30);
            AUTO_CAST(check_box)
            check_box:SetCheck(g.settings[tostring(check_table[i])] or 1)
            check_box:SetEventScript(ui.LBUTTONDOWN, "indun_list_viewer_display_check")
            check_box:SetEventScriptArgString(ui.LBUTTONDOWN, check_table[i])

            x = x + 65
        end
        title_gb:Resize(900 + 70, 55)
        frame:Resize(865 + 80, 85)

        config_gb:Resize(865 + 60, frame:GetHeight() - 45)
    end

    local config_btn = title_gb:CreateOrGetControl('button', 'config_btn', 75, 5, 30, 30)
    AUTO_CAST(config_btn)
    config_btn:SetSkinName("None")
    config_btn:SetText("{img config_button_normal 30 30}")
    config_btn:SetEventScript(ui.LBUTTONUP, "indun_list_viewer_config")

    local mode_check = title_gb:CreateOrGetControl('checkbox', 'mode_check', 115, 5, 30, 30)
    AUTO_CAST(mode_check)
    if g.settings.display_mode == "full" then
        mode_check:SetCheck(0)
    else
        mode_check:SetCheck(1)
    end
    mode_check:SetEventScript(ui.LBUTTONUP, "indun_list_viewer_modechange")
    mode_check:SetTextTooltip("{ol}" .. select_texts.mode_text)

    if g.settings[tostring(check_table[#check_table])] == 1 then
        local memo_text = title_gb:CreateOrGetControl("richtext", "memo_text", x, 10)
        AUTO_CAST(memo_text)
        memo_text:SetText("{ol}" .. select_texts.memo)
        x = x + 160
    end

    local display_text = title_gb:CreateOrGetControl("richtext", "display_text", x, 10)
    AUTO_CAST(display_text)
    display_text:SetText("{ol}" .. select_texts.display)
    display_text:SetTextTooltip("{ol}" .. select_texts.display_text)

    title_gb:Resize(900 + 70, 55)
    frame:SetPos(665, 35)
    frame:Resize(900 + 70, 55)
    frame:ShowWindow(1)

    indun_list_viewer_frame_open(frame)
end

function indun_list_viewer_close(frame, ctrl, str, num)

    local frame = ui.GetFrame(addonNameLower .. "list_frame")
    frame:ShowWindow(0)

    if num == 1 then
        indun_list_viewer_title_frame_open()
    end
end

function indun_list_viewer_frame_open(frame)

    local title_gb = GET_CHILD_RECURSIVELY(frame, "title_gb")
    AUTO_CAST(title_gb)

    local gb = frame:CreateOrGetControl("groupbox", "gb", 10, 35, 10, 10)
    AUTO_CAST(gb)
    gb:SetSkinName("bg")

    local y = 10
    for _, data in ipairs(g.sorted_settings) do
        local x = 35
        if type(data) == "table" then
            local pc_name = data.pc_name

            local name = gb:CreateOrGetControl("richtext", pc_name, x, y)
            AUTO_CAST(name)
            if g.login_name == pc_name then
                name:SetText("{ol}{s14}{#FF4500}" .. pc_name)
            else
                name:SetText("{ol}{s14}" .. pc_name)
            end

            indun_list_viewer_job_slot(frame, data, y)

            local i = 1
            local index = 0
            if not data.hide then
                local raid_count = data["raid_count"]
                local auto_clear_count = data["auto_clear_count"]
                if g.settings[tostring(check_table[i])] == 1 then

                    x = index == 0 and x + 140 or x + 30
                    index = index + 1
                    local R_H = gb:CreateOrGetControl("richtext", "R_H" .. pc_name, x, y)
                    AUTO_CAST(R_H)
                    R_H:SetText("{ol}{s14}( " .. raid_count.R_H .. " )")
                    if raid_count.R_H == 1 then
                        R_H:SetColorTone("FF990000");
                    else
                        R_H:SetColorTone("FFFFFFFF");
                    end
                end

                i = i + 1
                if g.settings[tostring(check_table[i])] == 1 then
                    x = index == 0 and x + 140 or x + 30
                    index = index + 1
                    local N_H = gb:CreateOrGetControl("richtext", "N_H" .. pc_name, x, y)
                    AUTO_CAST(N_H)
                    N_H:SetText("{ol}{s14}( " .. raid_count.N_H .. " )")
                    if raid_count.N_H == 1 then
                        N_H:SetColorTone("FF990000");
                    else
                        N_H:SetColorTone("FFFFFFFF");
                    end
                end

                i = i + 1
                if g.settings[tostring(check_table[i])] == 1 then
                    x = index == 0 and x + 140 or x + 30
                    index = index + 1
                    local G_H = gb:CreateOrGetControl("richtext", "G_H" .. pc_name, x, y)
                    AUTO_CAST(G_H)
                    G_H:SetText("{ol}{s14}( " .. raid_count.G_H .. " )")
                    if raid_count.G_H == 1 then
                        G_H:SetColorTone("FF990000");
                    else
                        G_H:SetColorTone("FFFFFFFF");
                    end
                end

                i = i + 1
                if g.settings[tostring(check_table[i])] == 1 then
                    x = index == 0 and x + 140 or x + 30
                    index = index + 1
                    local M_H = gb:CreateOrGetControl("richtext", "M_H" .. pc_name, x, y)
                    AUTO_CAST(M_H)
                    M_H:SetText("{ol}{s14}( " .. raid_count.M_H .. " )")
                    if raid_count.M_H == 1 then
                        M_H:SetColorTone("FF990000");
                    else
                        M_H:SetColorTone("FFFFFFFF");
                    end
                end

                i = i + 1
                if g.settings[tostring(check_table[i])] == 1 then
                    x = index == 0 and x + 140 or x + 30
                    index = index + 1
                    local S_H = gb:CreateOrGetControl("richtext", "S_H" .. pc_name, x, y)
                    AUTO_CAST(S_H)
                    S_H:SetText("{ol}{s14}( " .. raid_count.S_H .. " )")
                    if raid_count.S_H == 1 then
                        S_H:SetColorTone("FF990000");
                    else
                        S_H:SetColorTone("FFFFFFFF");
                    end
                end

                i = i + 1
                if g.settings[tostring(check_table[i])] == 1 then
                    x = index == 0 and x + 140 or x + 30
                    index = index + 1

                    local U_H = gb:CreateOrGetControl("richtext", "U_H" .. pc_name, x, y)
                    AUTO_CAST(U_H)
                    U_H:SetText("{ol}{s14}( " .. raid_count.U_H .. " )")
                    if raid_count.U_H == 1 then
                        U_H:SetColorTone("FF990000");
                    else
                        U_H:SetColorTone("FFFFFFFF");
                    end

                end

                i = i + 1
                if x >= 175 then
                    index = 0
                else
                    x = 140
                end
                if g.settings[tostring(check_table[i])] == 1 then
                    x = index == 0 and x + 60 or x + 40
                    index = index + 1

                    local R_A = gb:CreateOrGetControl("richtext", "R_A" .. pc_name, x, y)
                    AUTO_CAST(R_A)
                    R_A:SetText("{ol}{s14}( " .. raid_count.R_A .. " )")
                    if raid_count.R_A == 2 then
                        R_A:SetColorTone("FF990000");
                    else
                        R_A:SetColorTone("FFFFFFFF");
                    end

                    x = x + 25
                    local R_S = gb:CreateOrGetControl("richtext", "R_S" .. pc_name, x, y)
                    AUTO_CAST(R_S)
                    R_S:SetText("{ol}{s14}/( " .. auto_clear_count.R_S .. " )")
                end

                i = i + 1
                if g.settings[tostring(check_table[i])] == 1 then
                    x = index == 0 and x + 60 or x + 40
                    index = index + 1
                    local N_A = gb:CreateOrGetControl("richtext", "N_A" .. pc_name, x, y)
                    AUTO_CAST(N_A)
                    N_A:SetText("{ol}{s14}( " .. raid_count.N_A .. " )")
                    if raid_count.N_A == 2 then
                        N_A:SetColorTone("FF990000");
                    else
                        N_A:SetColorTone("FFFFFFFF");
                    end

                    x = x + 25
                    local N_S = gb:CreateOrGetControl("richtext", "N_S" .. pc_name, x, y)
                    AUTO_CAST(N_S)
                    N_S:SetText("{ol}{s14}/( " .. auto_clear_count.N_S .. " )")
                end

                i = i + 1
                if g.settings[tostring(check_table[i])] == 1 then
                    x = index == 0 and x + 60 or x + 40
                    index = index + 1
                    local G_A = gb:CreateOrGetControl("richtext", "G_A" .. pc_name, x, y)
                    AUTO_CAST(G_A)
                    G_A:SetText("{ol}{s14}( " .. raid_count.G_A .. " )")
                    if raid_count.G_A == 2 then
                        G_A:SetColorTone("FF990000");
                    else
                        G_A:SetColorTone("FFFFFFFF");
                    end

                    x = x + 25
                    local G_S = gb:CreateOrGetControl("richtext", "G_S" .. pc_name, x, y)
                    AUTO_CAST(G_S)
                    G_S:SetText("{ol}{s14}/( " .. auto_clear_count.G_S .. " )")
                end

                i = i + 1
                if g.settings[tostring(check_table[i])] == 1 then
                    x = index == 0 and x + 60 or x + 40
                    index = index + 1
                    local M_A = gb:CreateOrGetControl("richtext", "M_A" .. pc_name, x, y)
                    AUTO_CAST(M_A)
                    M_A:SetText("{ol}{s14}( " .. raid_count.M_A .. " )")
                    if raid_count.M_A == 2 then
                        M_A:SetColorTone("FF990000");
                    else
                        M_A:SetColorTone("FFFFFFFF");
                    end
                    x = x + 25
                    local M_S = gb:CreateOrGetControl("richtext", "M_S" .. pc_name, x, y)
                    AUTO_CAST(M_S)
                    M_S:SetText("{ol}{s14}/( " .. auto_clear_count.M_S .. " )")

                end

                i = i + 1
                if g.settings[tostring(check_table[i])] == 1 then
                    x = index == 0 and x + 60 or x + 40
                    index = index + 1
                    local S_A = gb:CreateOrGetControl("richtext", "S_A" .. pc_name, x, y)
                    AUTO_CAST(S_A)
                    S_A:SetText("{ol}{s14}( " .. raid_count.S_A .. " )")
                    if raid_count.S_A == 2 then
                        S_A:SetColorTone("FF990000");
                    else
                        S_A:SetColorTone("FFFFFFFF");
                    end
                    x = x + 25
                    local S_S = gb:CreateOrGetControl("richtext", "S_S" .. pc_name, x, y)
                    AUTO_CAST(S_S)
                    S_S:SetText("{ol}{s14}/( " .. auto_clear_count.S_S .. " )")
                end

                i = i + 1
                if g.settings[tostring(check_table[i])] == 1 then
                    x = index == 0 and x + 60 or x + 40
                    index = index + 1
                    local U_A = gb:CreateOrGetControl("richtext", "U_A" .. pc_name, x, y)
                    AUTO_CAST(U_A)
                    U_A:SetText("{ol}{s14}( " .. raid_count.U_A .. " )")
                    if raid_count.U_A == 2 then
                        U_A:SetColorTone("FF990000");
                    else
                        U_A:SetColorTone("FFFFFFFF");
                    end
                    x = x + 25
                    local U_S = gb:CreateOrGetControl("richtext", "U_S" .. pc_name, x, y)
                    AUTO_CAST(U_S)
                    U_S:SetText("{ol}{s14}/( " .. auto_clear_count.U_S .. " )")
                end

                if g.settings[tostring(check_table[#check_table])] == 1 then

                    local memo = gb:CreateOrGetControl('edit', 'memo' .. pc_name, x + 40, y - 2, 180, 20)
                    AUTO_CAST(memo)
                    memo:SetFontName("white_14_ol")
                    memo:SetTextAlign("left", "center")
                    memo:SetSkinName("inventory_serch"); -- test_edit_skin--test_weight_skin--inventory_serch
                    memo:SetEventScript(ui.ENTERKEY, "indun_list_viewer_memo_save")
                    memo:SetEventScriptArgString(ui.ENTERKEY, pc_name)
                    local memoData = data.memo
                    memo:SetText(memoData)

                    x = x + 180
                end
                g.x = x
            end

            i = i + 1
            local line = gb:CreateOrGetControl("labelline", "line" .. pc_name, 25, y + 20, g.x + 10, 1)
            line:SetSkinName("labelline_def_3")

            local display = gb:CreateOrGetControl('checkbox', 'display' .. pc_name, g.x + 50, y - 5, 25, 25) -- 865
            AUTO_CAST(display)
            display:SetEventScript(ui.LBUTTONUP, "indun_list_viewer_display_save")
            display:SetEventScriptArgString(ui.LBUTTONUP, pc_name)
            local check = 1
            if not data.hide then
                check = 0
            end
            display:SetCheck(check)

            y = y + 25
        end
    end

    if g.settings.display_mode == "full" then
        frame:Resize(g.x + 40 + 80, y + 50)
        gb:Resize(frame:GetWidth() - 20, frame:GetHeight() - 45)
        title_gb:Resize(frame:GetWidth() - 20, 55)

    else
        frame:Resize(g.x + 40 + 80, 545)
        gb:Resize(frame:GetWidth() - 20, 500)
        gb:EnableScrollBar(1);
        gb:EnableDrawFrame(1);
        gb:SetScrollPos(0)
        title_gb:Resize(frame:GetWidth() - 20, 55)
    end

    local display_text = GET_CHILD_RECURSIVELY(frame, "display_text")
    AUTO_CAST(display_text)
    local charName = GETMYPCNAME();
    local display = GET_CHILD_RECURSIVELY(frame, 'display' .. charName)
    AUTO_CAST(display)
    local display_x = display:GetX()
    display_text:SetPos(display_x + 10, 10)
    frame:ShowWindow(1)
end

function indun_list_viewer_display_save(frame, ctrl, str, num)

    local ischeck = ctrl:IsChecked()

    for _, data in ipairs(g.sorted_settings) do
        local pc_name = data.pc_name
        if pc_name == str then
            if ischeck == 1 then
                g.settings[pc_name].hide = true
            else
                g.settings[pc_name].hide = false
            end
            indun_list_viewer_save_settings()
            break
        end
    end
    indun_list_viewer_title_frame_open()
end

function indun_list_viewer_memo_save(frame, ctrl, str, num)

    local text = ctrl:GetText()
    for _, data in ipairs(g.sorted_settings) do
        local pc_name = data.pc_name
        if pc_name == str then
            g.settings[pc_name].memo = text
            indun_list_viewer_save_settings()
            break
        end
    end
    if g.lang == "Japanese" then
        ui.SysMsg("メモを登録しました。")
    else
        ui.SysMsg("MEMO registered.")
    end
end

function indun_list_viewer_job_slot(frame, data, y)

    local pc_name = data.pc_name
    local job_id = data.jobid
    local president = data.president_jobid

    local last_job_class
    local job_list, level, last_job_id = GetJobListFromAdventureBookCharData(pc_name)
    if job_id == "" then
        last_job_class = GetClassByType("Job", last_job_id)
    else
        last_job_class = GetClassByType("Job", president)
    end

    local last_job_icon = TryGetProp(last_job_class, "Icon")

    local gb = GET_CHILD_RECURSIVELY(frame, "gb")
    local job_slot = gb:CreateOrGetControl("slot", "jobslot" .. pc_name, 5, y - 4, 25, 25)
    AUTO_CAST(job_slot)
    job_slot:SetSkinName("None")
    job_slot:EnableHitTest(1)
    job_slot:EnablePop(0)

    local job_icon = CreateIcon(job_slot)
    job_icon:SetImage(last_job_icon)

    local cc_text = ""
    if g.lang == "Japanese" then
        cc_text = "クリックするとキャラクターチェンジします。"
    else
        cc_text = "Click to change characters."
    end

    local text = ""
    local id1, id2, id3, id4 = nil, nil, nil, nil
    local job_name1, job_name2, job_name3, job_name4

    if job_id ~= "" then

        local ids = {}

        for part in string.gmatch(job_id, "[^/]+") do
            table.insert(ids, part)
        end

        id1, id2, id3, id4 = ids[1], ids[2], ids[3], ids[4]

        local function get_job_name(id)
            if not id then
                return nil
            end
            local job_class = GetClassByType("Job", tonumber(id))
            if job_class then
                return TryGetProp(job_class, "Name", nil)
            end
            return nil
        end

        job_name1 = get_job_name(id1)
        job_name2 = get_job_name(id2)
        job_name3 = get_job_name(id3)
        job_name4 = get_job_name(id4)

        local highlight_color = "{#FF0000}" -- 一致した場合の色
        local function color_if_match(jobName, jobId)
            if jobId and tonumber(jobId) == tonumber(president) then
                return highlight_color .. jobName .. "{/}"
            else
                return jobName
            end
        end
        local tooltip_text = "{ol}"
        if job_name1 then
            tooltip_text = tooltip_text ..
                               color_if_match(string.gsub(dic.getTranslatedStr(job_name1), "{s18}", ""), id1) .. "{nl}"
        end
        if job_name2 then
            tooltip_text = tooltip_text ..
                               color_if_match(string.gsub(dic.getTranslatedStr(job_name2), "{s18}", ""), id2) .. "{nl}"
        end
        if job_name3 then
            tooltip_text = tooltip_text ..
                               color_if_match(string.gsub(dic.getTranslatedStr(job_name3), "{s18}", ""), id3) .. "{nl}"
        end
        if job_name4 then
            tooltip_text = tooltip_text ..
                               color_if_match(string.gsub(dic.getTranslatedStr(job_name4), "{s18}", ""), id4) .. "{nl}"
        end
        text = tooltip_text
    else
        local job_name = TryGetProp(last_job_class, "Name")
        text = "{ol}" .. string.gsub(dic.getTranslatedStr(job_name), "{s18}", "")

    end

    local functionName = "INSTANTCC_ON_INIT"
    if type(_G[functionName]) == "function" then

        local cid = data.cid
        local layer = data.layer

        job_icon:SetTextTooltip(text .. "{nl} {nl}{#FF4500}" .. cc_text)
        job_slot:SetEventScript(ui.LBUTTONDOWN, "indun_list_viewer_INSTANTCC_DO_CC")
        job_slot:SetEventScriptArgString(ui.LBUTTONDOWN, cid)
        job_slot:SetEventScriptArgNumber(ui.LBUTTONDOWN, layer)

        local name_text = GET_CHILD_RECURSIVELY(gb, pc_name)
        name_text:SetEventScript(ui.LBUTTONDOWN, "indun_list_viewer_INSTANTCC_DO_CC")
        name_text:SetEventScriptArgString(ui.LBUTTONDOWN, cid)
        name_text:SetEventScriptArgNumber(ui.LBUTTONDOWN, layer)
        name_text:SetTextTooltip(text .. "{nl} {nl}{#FF4500}" .. cc_text)
    else
        job_icon:SetTextTooltip(text)
    end
end

function indun_list_viewer_INSTANTCC_DO_CC(frame, ctrl, cid, layer)
    g.layer = nil
    INSTANTCC_DO_CC(cid, layer)
end

function indun_list_viewer_modechange(frame, ctrl, argStr, argNum)

    local ischeck = ctrl:IsChecked()
    if ischeck == 1 then
        g.settings.display_mode = "slide"
    else
        g.settings.display_mode = "full"
    end
    indun_list_viewer_save_settings()
    indun_list_viewer_title_frame_open()
end

function indun_list_viewer_STATUS_SELET_REPRESENTATION_CLASS(frame, msg)
    local select_index, select_key = acutil.getEventArgs(msg)

    local main_session = session.GetMainSession();
    local pc_job_info = main_session:GetPCJobInfo();
    local job_count = pc_job_info:GetJobCount();
    g.settings[g.login_name].jobid = ""
    for i = 0, job_count - 1 do
        local job_info = pc_job_info:GetJobInfoByIndex(i);
        g.settings[g.login_name].jobid = g.settings[g.login_name].jobid .. "/" .. job_info.jobID
    end
    g.settings[g.login_name].president_jobid = select_key
    indun_list_viewer_save_settings()
end

function indun_list_viewer_enter_context(frame, ctrl, str, num)
    local solo = g.lang == "Japanese" and "ソロ" or "SOLO"
    local auto = g.lang == "Japanese" and "自動" or "AUTO"
    local context = ui.CreateContextMenu("context", "", 0, 0, 0, 0);

    local strScp = string.format("indun_list_viewer_enter_solo(%d)", ctrl:GetUserIValue("SOLO"))
    ui.AddContextMenuItem(context, solo, strScp)
    strScp = string.format("indun_list_viewer_enter_auto(%d)", ctrl:GetUserIValue("AUTO"))
    ui.AddContextMenuItem(context, auto, strScp)
    ui.OpenContextMenu(context);
end

function indun_list_viewer_enter_solo(induntype)
    local frame = ui.GetFrame(addonNameLower .. "list_frame")
    frame:ShowWindow(0)

    ReqRaidAutoUIOpen(induntype)
    ReserveScript(string.format("ReqMoveToIndun(%d,%d)", 1, 0), 0.3)
end

function indun_list_viewer_enter_auto(induntype)
    local frame = ui.GetFrame(addonNameLower .. "list_frame")
    frame:ShowWindow(0)

    ReqRaidAutoUIOpen(induntype)
    local topFrame = ui.GetFrame("indunenter")
    -- local useCount = tonumber(topFrame:GetUserValue("multipleCount"));
    local indunType = topFrame:GetUserValue('INDUN_TYPE');
    local indunCls = GetClassByType('Indun', indunType);
    local indunMinPCRank = TryGetProp(indunCls, 'PCRank')
    local totaljobcount = session.GetPcTotalJobGrade()

    if indunMinPCRank ~= nil then
        if indunMinPCRank > totaljobcount and indunMinPCRank ~= totaljobcount then
            ui.SysMsg(ScpArgMsg('IndunEnterNeedPCRank', 'NEED_RANK', indunMinPCRank))
            return;
        end
    end
    ReserveScript(string.format("ReqMoveToIndun(%d,%d)", 2, 0), 0.3)
end

function indun_list_viewer_INDUNINFO_SET_BUTTONS(induntype, ctrl)
    local frame = ui.GetFrame(addonNameLower .. "list_frame")
    local indunCls = GetClassByType('Indun', induntype)
    local dungeonType = TryGetProp(indunCls, "DungeonType", "None")
    local btnInfoCls = GetClassByStrProp("IndunInfoButton", "DungeonType", dungeonType)

    if dungeonType == "Raid" then
        btnInfoCls = INDUNINFO_SET_BUTTONS_FIND_CLASS(indunCls)
    end

    local redButtonScp = TryGetProp(btnInfoCls, "RedButtonScp")
    ctrl:SetUserValue('MOVE_INDUN_CLASSID', indunCls.ClassID)
    ctrl:SetEventScript(ui.LBUTTONUP, redButtonScp)
end

function indun_list_viewer_enter_hard(frame, ctrl, str, induntype)
    local frame = ui.GetFrame(addonNameLower .. "list_frame")
    local indunCls = GetClassByType("Indun", induntype)
    if str == "false" then
        indun_list_viewer_INDUNINFO_SET_BUTTONS(induntype, ctrl)
        str = "true"
        ReserveScript(string.format("indun_list_viewer_enter_hard('%s','%s','%s',%d)", frame, ctrl, str, induntype), 0.5)
        return
    else
        SHOW_INDUNENTER_DIALOG(induntype)
        frame:ShowWindow(0)
        return
    end
end

