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
-- v1.2.8 acutil終わり。indunpanelに統合準備。非表示のキャラを非表示にする機能。
-- v1.2.9 250902大型対応。新レイド追加、設定画面修正。他鯖の時差修正したつもり
-- v1.2.9.1 デルムーアまで拡張 
-- v1.2.9.2 IMCの20251023バグ修正
-- v1.2.9.3 リファクタリング。最初から作り直し
-- v1.3.0 デルムーアのダンジョンタイプ変わってたの修正
-- v1.3.1 移行時メモ欄消えるの修正、ジョブアイコン変わらないの修正。
local addon_name = "indun_list_viewer"
local addon_name_lower = string.lower(addon_name)
local author = "norisan"
local ver = "1.3.1"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addon_name] = _G["ADDONS"][author][addon_name] or {}
local g = _G["ADDONS"][author][addon_name]

local json = require("json")
local function ts(...)
    local num_args = select('#', ...)
    if num_args == 0 then
        print("ts() -- 引数がありません")
        return
    end
    local string_parts = {}
    for i = 1, num_args do
        local arg = select(i, ...)
        local arg_type = type(arg)
        local is_success, value_str = pcall(tostring, arg)
        if not is_success then
            value_str = "[tostringでエラー発生]"
        end
        table.insert(string_parts, string.format("(%s) %s", arg_type, value_str))
    end
    print(table.concat(string_parts, "   |   "))
end

function g.mkdir_new_folder()
    local function create_folder(folder_path, file_path)
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
    local folder = string.format("../addons/%s", addon_name_lower)
    local file_path = string.format("../addons/%s/mkdir.txt", addon_name_lower)
    create_folder(folder, file_path)
    g.active_id = session.loginInfo.GetAID()
    local user_folder = string.format("../addons/%s/%s", addon_name_lower, g.active_id)
    local user_file_path = string.format("../addons/%s/%s/mkdir.txt", addon_name_lower, g.active_id)
    create_folder(user_folder, user_file_path)
    g.settings_path = string.format("../addons/%s/%s/settings_2510.json", addon_name_lower, g.active_id)
end
g.mkdir_new_folder()

function g.save_json(path, tbl)
    local file = io.open(path, "w")
    if file then
        local str = json.encode(tbl)
        file:write(str)
        file:close()
    end
end

function g.load_json(path)
    local file = io.open(path, "r")
    if not file then
        return nil, "Error opening file: " .. path
    end
    local content = file:read("*all")
    file:close()
    if not content or content == "" then
        return nil, "File content is empty or could not be read: " .. path
    end
    local decoded_table, decode_err = json.decode(content)
    if not decoded_table then
        return nil, decode_err
    end
    return decoded_table, nil
end

function g.get_map_type()
    local map_name = session.GetMapName()
    local map_cls = GetClass("Map", map_name)
    local map_type = map_cls.MapType
    return map_type
end

function g.setup_hook_and_event(my_addon, origin_func_name, my_func_name, bool)
    g.FUNCS = g.FUNCS or {}
    if not g.FUNCS[origin_func_name] then
        g.FUNCS[origin_func_name] = _G[origin_func_name]
    end
    local origin_func = g.FUNCS[origin_func_name]
    local function hooked_function(...)
        local original_results
        if bool == true then
            original_results = {origin_func(...)}
        end
        g.ARGS = g.ARGS or {}
        g.ARGS[origin_func_name] = {...}
        imcAddOn.BroadMsg(origin_func_name)
        if original_results then
            return table.unpack(original_results)
        else
            return
        end
    end
    _G[origin_func_name] = hooked_function
    if not g.REGISTER[origin_func_name .. my_func_name] then -- g.REGISTERはON_INIT内で都度初期化
        g.REGISTER[origin_func_name .. my_func_name] = true
        my_addon:RegisterMsg(origin_func_name, my_func_name)
    end
end

function g.get_event_args(origin_func_name)
    local args = g.ARGS[origin_func_name]
    if args then
        return table.unpack(args)
    end
    return nil
end

local function indun_list_viewer_ensure_defaults(target_table, default_table)
    local applied_change = false
    for key, default_value in pairs(default_table) do
        if target_table[key] == nil then
            if type(default_value) == 'table' then
                target_table[key] = json.decode(json.encode(default_value))
            else
                target_table[key] = default_value
            end
            applied_change = true
        elseif type(target_table[key]) == "table" and type(default_value) == "table" then
            if indun_list_viewer_ensure_defaults(target_table[key], default_value) then
                applied_change = true
            end
        end
    end
    return applied_change
end

local function indun_list_viewer_old_memo()
    local old_path = string.format("../addons/%s/%s/settings.json", addon_name_lower, g.active_id)
    local new_memo_path = string.format("../addons/%s/%s/memos.json", addon_name_lower, g.active_id)
    g.memos = g.load_json(new_memo_path)
    if not g.memos then
        local old_settings = g.load_json(old_path)
        if not old_settings then
            g.memos = {} -- どちらもなければ空テーブルを作成
            return
        end
        local new_memos = {}
        for key, value in pairs(old_settings) do
            if type(value) == "table" and value.pc_name and value.memo then
                new_memos[value.pc_name] = value.memo or ""
            end
        end
        g.memos = new_memos
        g.save_json(new_memo_path, g.memos) -- 新しく作成した場合のみ保存
    end
end

local RAID_KEYS = {"V", "L", "R", "N", "G", "M", "S", "U", "RO", "F", "P", "D"}
local RAID_INFO = {
    V = {
        name = "Veliora",
        hard = 727,
        solo = 726,
        auto = 725,
        icon = "icon_item_misc_boss_Veliora",
        sweep_buff = 80045
    },
    L = {
        name = "Limara",
        hard = 724,
        solo = 723,
        auto = 722,
        icon = "icon_item_misc_boss_Laimara",
        sweep_buff = 80043
    },
    R = {
        name = "Redania",
        hard = 718,
        solo = 717,
        auto = 716,
        icon = "icon_item_misc_boss_Redania",
        sweep_buff = 80039
    },
    N = {
        name = "Neringa",
        hard = 709,
        solo = 708,
        auto = 707,
        icon = "icon_item_misc_boss_DarkNeringa",
        sweep_buff = 80035
    },
    G = {
        name = "Golem",
        hard = 712,
        solo = 711,
        auto = 710,
        icon = "icon_item_misc_boss_CrystalGolem",
        sweep_buff = 80037
    },
    M = {
        name = "Merregina",
        hard = 697,
        solo = 696,
        auto = 695,
        icon = "icon_item_misc_merregina_blackpearl",
        sweep_buff = 80032
    },
    S = {
        name = "Slogutis",
        hard = 690,
        solo = 689,
        auto = 688,
        icon = "icon_item_misc_boss_Slogutis",
        sweep_buff = 80031
    },
    U = {
        name = "Upinis",
        hard = 687,
        solo = 686,
        auto = 685,
        icon = "icon_item_misc_boss_Upinis",
        sweep_buff = 80030
    },
    RO = {
        name = "Roze",
        hard = 681,
        solo = 680,
        auto = 679,
        icon = "icon_item_misc_boss_Roze",
        sweep_buff = 80015
    },
    F = {
        name = "Falouros",
        hard = 678,
        solo = 677,
        auto = 676,
        icon = "icon_item_misc_high_falouros",
        sweep_buff = 80017
    },
    P = {
        name = "Spreader",
        hard = 675,
        solo = 674,
        auto = 673,
        icon = "icon_item_misc_high_transmutationSpreader",
        sweep_buff = 80016
    },
    D = {
        name = "Delmore",
        hard = 665,
        solo = 667,
        auto = 666,
        icon = "icon_item_misc_RevivalPaulius",
        sweep_buff = nil
    }
}
local CHECK_KEYS = {}
for _, key in ipairs(RAID_KEYS) do
    table.insert(CHECK_KEYS, RAID_INFO[key].name .. "_H")
end
for _, key in ipairs(RAID_KEYS) do
    table.insert(CHECK_KEYS, RAID_INFO[key].name .. "_S")
end
table.insert(CHECK_KEYS, "Memo")
local DEFAULT_CHAR_DATA = {
    layer = 9,
    order = 99,
    hide = false,
    memo = "",
    president_jobid = "",
    jobid = "",
    raid_count = {},
    auto_clear_count = {}
}

for _, key in ipairs(RAID_KEYS) do
    DEFAULT_CHAR_DATA.raid_count[key .. "_H"] = "?"
    DEFAULT_CHAR_DATA.raid_count[key .. "_A"] = "?"
    DEFAULT_CHAR_DATA.auto_clear_count[key .. "_S"] = "?"
end

local DEFAULT_SETTINGS = {
    default_options = {
        reset_time = 0,
        display_mode = "full",
        hidden = 0
    },
    display_options = {}
}

for _, key in ipairs(CHECK_KEYS) do
    DEFAULT_SETTINGS.display_options[key] = 1
end

function indun_list_viewer_save_settings()
    g.save_json(g.settings_path, g.settings)
end

function indun_list_viewer_load_settings()
    indun_list_viewer_old_memo()
    local memos_changed = false
    local settings = g.load_json(g.settings_path) or {}
    local changed = false
    indun_list_viewer_ensure_defaults(settings, DEFAULT_SETTINGS)
    if not settings[g.login_name] then
        settings[g.login_name] = {
            pc_name = g.login_name
        }
        indun_list_viewer_ensure_defaults(settings[g.login_name], DEFAULT_CHAR_DATA)
        changed = true
    end
    if g.memos and g.memos[g.login_name] then
        settings[g.login_name].memo = g.memos[g.login_name]
        g.memos[g.login_name] = nil
        memos_changed = true
    end
    indun_list_viewer_sort_characters(nil, settings)
    g.settings = settings
    if changed then
        indun_list_viewer_save_settings()
    end
    if memos_changed then
        local new_memo_path = string.format("../addons/%s/%s/memos.json", addon_name_lower, g.active_id)
        g.save_json(new_memo_path, g.memos)
    end
end

function indun_list_viewer_sync_characters()
    if not g.load then
        return
    end
    local settings = g.settings
    local memos_changed = false
    local changed = false
    local acc_info = session.barrack.GetMyAccount()
    local barrack_cnt = acc_info:GetBarrackPCCount()
    local barrack_names = {}
    for i = 0, barrack_cnt - 1 do
        local pc_info = acc_info:GetBarrackPCByIndex(i)
        local pc_name = pc_info:GetName()
        barrack_names[pc_name] = true
        if not settings[pc_name] then
            settings[pc_name] = {
                pc_name = pc_name
            }
            indun_list_viewer_ensure_defaults(settings[pc_name], DEFAULT_CHAR_DATA)
            changed = true
        end
        if g.memos and g.memos[pc_name] then
            settings[pc_name].memo = g.memos[pc_name]
            g.memos[pc_name] = nil
            memos_changed = true
            changed = true
        end
    end
    local keys_to_delete = {}
    for key, data in pairs(settings) do
        if type(data) == "table" and data.pc_name and not barrack_names[key] then
            table.insert(keys_to_delete, key)
        end
    end
    if #keys_to_delete > 0 then
        for _, key in ipairs(keys_to_delete) do
            settings[key] = nil
        end
        changed = true
    end
    indun_list_viewer_sort_characters(acc_info, settings)
    local server_time_str = date_time.get_lua_now_datetime_str()
    if server_time_str then
        local y, m, d, H, M, S = server_time_str:match("(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)")
        if y then
            local server_now_timestamp = os.time({
                year = tonumber(y),
                month = tonumber(m),
                day = tonumber(d),
                hour = tonumber(H),
                min = tonumber(M),
                sec = tonumber(S)
            })
            if server_now_timestamp > settings.default_options.reset_time then
                indun_list_viewer_raid_reset(settings)
                changed = true
            end
        end
    end
end

function indun_list_viewer_raid_reset(settings)
    local account_info = session.barrack.GetMyAccount()
    if not account_info then
        return
    end
    local barrack_pc_count = account_info:GetBarrackPCCount()
    if not barrack_pc_count then
        return
    end
    for i = 0, barrack_pc_count - 1 do
        local barrack_pc_info = account_info:GetBarrackPCByIndex(i)
        if barrack_pc_info then
            local barrack_pc_name = barrack_pc_info:GetName()
            local char_data = settings[barrack_pc_name]

            if char_data then
                char_data.raid_count = {}
                for _, key in ipairs(RAID_KEYS) do
                    char_data.raid_count[key .. "_H"] = "?"
                    char_data.raid_count[key .. "_A"] = "?"
                end
            end
        end
    end
    settings.default_options.reset_time = indun_list_viewer_get_reset_time()
    if g.lang == "Japanese" then
        ui.SysMsg("[ILV]レイドの回数を初期化しました。")
    else
        ui.SysMsg("[ILV]Raid counts were initialized.")
    end
end

function indun_list_viewer_get_reset_time()
    local server_time_str = date_time.get_lua_now_datetime_str()
    if not server_time_str then
        return 0
    end
    local year, month, day, hour, min, sec = server_time_str:match("(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)")
    if not year then
        return 0
    end
    local now_table = {
        year = tonumber(year),
        month = tonumber(month),
        day = tonumber(day),
        hour = tonumber(hour),
        min = tonumber(min),
        sec = tonumber(sec)
    }
    local now_timestamp = os.time(now_table)
    local current_day_of_week = tonumber(os.date("%w", now_timestamp)) + 1
    local days_to_next_monday
    if current_day_of_week == 2 and now_table.hour < 6 then
        days_to_next_monday = 0
    else
        days_to_next_monday = (9 - current_day_of_week) % 7
        if days_to_next_monday == 0 then
            days_to_next_monday = 7
        end
    end
    local next_monday_timestamp_base = now_timestamp + days_to_next_monday * 86400
    local next_monday_date = os.date("*t", next_monday_timestamp_base)
    local next_monday_6am_timestamp = os.time({
        year = next_monday_date.year,
        month = next_monday_date.month,
        day = next_monday_date.day,
        hour = 6,
        min = 0,
        sec = 0
    })
    return next_monday_6am_timestamp
end

function indun_list_viewer_sort_characters(account_info, settings_table)
    if account_info then
        local layer_pc_count = account_info:GetPCCount()
        for order = 0, layer_pc_count - 1 do
            local pc_info = account_info:GetPCByIndex(order)
            if pc_info then
                local pc_apc = pc_info:GetApc()
                local pc_name = pc_apc:GetName()
                if settings_table[pc_name] then
                    settings_table[pc_name].cid = pc_info:GetCID()
                    settings_table[pc_name].order = order
                    if g.layer and g.layer ~= settings_table[pc_name].layer then
                        settings_table[pc_name].layer = g.layer
                    end
                end
            end
        end
        g.settings_changed = true
    end
    g.sorted_settings = {}
    for key, data in pairs(settings_table) do
        if type(data) == "table" and data.pc_name then
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

function INDUN_LIST_VIEWER_ON_INIT(addon, frame)
    g.addon = addon
    g.frame = frame
    g.REGISTER = {}
    g.cid = session.GetMySession():GetCID();
    g.lang = option.GetCurrentCountry()
    g.login_name = session.GetMySession():GetPCApc():GetName()
    if _G["BARRACK_CHARLIST_ON_INIT"] and _G["current_layer"] then
        g.layer = _G["current_layer"] or 1
    end
    addon:RegisterMsg('GAME_START', "indun_list_viewer_GAME_START")
    if g.get_map_type() == "City" then
        addon:RegisterMsg('GAME_START_3SEC', "indun_list_viewer_post_load_tasks")
    end
end

function indun_list_viewer_GAME_START()
    if g.get_map_type() == "City" then
        if not g.load then
            local start_time = os.clock()
            indun_list_viewer_load_settings()
            local end_time = os.clock()
            local elapsed_time = end_time - start_time
            -- CHAT_SYSTEM(string.format("%s: %.4f seconds", addon_name_lower .. "_on_init", elapsed_time))
        end
        g.setup_hook_and_event(g.addon, "APPS_TRY_MOVE_BARRACK", "indun_list_viewer_save_current_char_counts", true)
        g.setup_hook_and_event(g.addon, "APPS_TRY_LOGOUT", "indun_list_viewer_save_current_char_counts", true)
        g.setup_hook_and_event(g.addon, "APPS_TRY_EXIT", "indun_list_viewer_save_current_char_counts", true)
        g.setup_hook_and_event(g.addon, "STATUS_SELET_REPRESENTATION_CLASS",
            "indun_list_viewer_STATUS_SELET_REPRESENTATION_CLASS", true) -- STATUS_OPEN_CLASS_DROPLIST
    end
end

function indun_list_viewer_post_load_tasks()
    indun_list_viewer_sync_characters()
    if not g.load then
        g.settings[g.login_name] = g.settings[g.login_name] or {}
        if not g.settings[g.login_name].auto_clear_count then
            g.settings[g.login_name].auto_clear_count = {}
        end
        g.load = true
    end
    indun_list_viewer_save_current_char_counts()
    if g.settings_changed then
        indun_list_viewer_save_settings()
        g.settings_changed = false
    end
    indun_list_viewer_frame_init()
end

function indun_list_viewer_save_current_char_counts()
    if g.get_map_type() ~= "City" then
        return
    end
    if not g.settings[g.login_name] then
        return
    end
    local function get_safe_entrance_count(indun_type)
        local indun_cls = GetClassByType("Indun", indun_type)
        if indun_cls and indun_cls.PlayPerResetType then
            return GET_CURRENT_ENTERANCE_COUNT(indun_cls.PlayPerResetType)
        end
        return nil
    end
    local raid_data = {}
    for key, raid in pairs(RAID_INFO) do
        local count = get_safe_entrance_count(raid.hard)
        raid_data[key .. "_H"] = count or "?"

        count = get_safe_entrance_count(raid.auto)
        raid_data[key .. "_A"] = count or "?"
    end
    g.settings[g.login_name].raid_count = raid_data
    local auto_clear_data = g.settings[g.login_name].auto_clear_count
    local my_handle = session.GetMyHandle()
    for _, key in ipairs(RAID_KEYS) do
        local raid = RAID_INFO[key]
        auto_clear_data[key .. "_S"] = 0
        if raid.sweep_buff then
            local buff_info = info.GetBuff(my_handle, raid.sweep_buff)
            if buff_info then
                auto_clear_data[key .. "_S"] = buff_info.over
            end
        end
    end
    g.settings[g.login_name].auto_clear_count = auto_clear_data
    indun_list_viewer_save_settings()
    g.settings_changed = false
end

function indun_list_viewer_frame_init()
    local addon_frame = ui.GetFrame("indun_list_viewer")
    addon_frame:SetSkinName('None')
    addon_frame:SetTitleBarSkin("None")
    addon_frame:Resize(35, 35)
    local map_frame = ui.GetFrame("map")
    addon_frame:SetPos((map_frame:GetWidth() - addon_frame:GetWidth()) / 2, 0)
    local open_button = addon_frame:CreateOrGetControl('button', 'open_button', 0, 0, 35, 35)
    AUTO_CAST(open_button)
    open_button:SetSkinName("None")
    open_button:SetText("{img sysmenu_qu 35 35}")
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
end

function indun_list_viewer_display_check(frame, ctrl, key, num)
    g.settings.display_options[key] = ctrl:IsChecked() == 1 and 1 or 0
    indun_list_viewer_save_settings()
end

function indun_list_viewer_config()
    local frame = ui.GetFrame(addon_name_lower .. "list_frame")
    frame:RemoveAllChild()
    local title_gb = frame:CreateOrGetControl("groupbox", "title_gb", 0, 0, 10, 10)
    AUTO_CAST(title_gb)
    local config_gb = frame:CreateOrGetControl("groupbox", "config_gb", 10, 35, 10, 10)
    AUTO_CAST(config_gb)
    config_gb:SetSkinName("bg")
    local text = config_gb:CreateOrGetControl("richtext", "text", 10, 10)
    AUTO_CAST(text)
    text:SetText(g.lang == "Japanese" and "チェックすると表示" or "{ol}Check to show")
    local x = text:GetX() + text:GetWidth() + 5
    local text_x = 0
    for _, raid_key in ipairs(RAID_KEYS) do
        local raid_info = RAID_INFO[raid_key]
        if text_x == 0 then
            text_x = x
        end
        local pic = title_gb:CreateOrGetControl('picture', "title_pic_" .. raid_key .. "_H", x + 5, 5, 30, 30)
        AUTO_CAST(pic)
        pic:SetImage(raid_info.icon)
        pic:SetEnableStretch(1)
        pic:EnableHitTest(1)
        local check = config_gb:CreateOrGetControl('checkbox', "check_" .. raid_key .. "_H", x, 5, 30, 30)
        AUTO_CAST(check)
        check:SetCheck(g.settings.display_options[raid_info.name .. "_H"])
        check:SetEventScript(ui.LBUTTONDOWN, "indun_list_viewer_display_check")
        check:SetEventScriptArgString(ui.LBUTTONDOWN, raid_info.name .. "_H")
        x = x + 30
    end
    local hard_text = title_gb:CreateOrGetControl("richtext", "hard_text", text_x - 40, 10)
    AUTO_CAST(hard_text)
    hard_text:SetText("{ol}Hard")
    x = x + 100
    text_x = 0
    for _, raid_key in ipairs(RAID_KEYS) do
        local raid_info = RAID_INFO[raid_key]
        if text_x == 0 then
            text_x = x
        end
        local pic = title_gb:CreateOrGetControl('picture', "title_pic_" .. raid_key .. "_S", x + 5, 5, 30, 30)
        AUTO_CAST(pic)
        pic:SetImage(raid_info.icon)
        pic:SetEnableStretch(1)
        pic:EnableHitTest(1)
        local check = config_gb:CreateOrGetControl('checkbox', "check_" .. raid_key .. "_S", x, 5, 30, 30)
        AUTO_CAST(check)
        check:SetCheck(g.settings.display_options[raid_info.name .. "_S"])
        check:SetEventScript(ui.LBUTTONDOWN, "indun_list_viewer_display_check")
        check:SetEventScriptArgString(ui.LBUTTONDOWN, raid_info.name .. "_S")
        x = x + 30
    end
    local auto_text = title_gb:CreateOrGetControl("richtext", "auto_text", text_x - 80, 10)
    AUTO_CAST(auto_text)
    auto_text:SetText("{ol}Solo/Auto")
    x = x + 30
    local memo_text = title_gb:CreateOrGetControl("richtext", "memo_text", x, 10)
    AUTO_CAST(memo_text)
    memo_text:SetText("{ol}Memo")
    local memo_check = config_gb:CreateOrGetControl('checkbox', "check_memo", x, 5, 30, 30)
    AUTO_CAST(memo_check)
    memo_check:SetCheck(g.settings.display_options["Memo"])
    memo_check:SetEventScript(ui.LBUTTONDOWN, "indun_list_viewer_display_check")
    memo_check:SetEventScriptArgString(ui.LBUTTONDOWN, "Memo")
    local close_button = title_gb:CreateOrGetControl("button", "close_button", 0, 0, 20, 20)
    AUTO_CAST(close_button)
    close_button:SetImage("testclose_button")
    close_button:SetGravity(ui.LEFT, ui.TOP)
    close_button:SetEventScript(ui.LBUTTONUP, "indun_list_viewer_close")
    close_button:SetEventScriptArgNumber(ui.LBUTTONUP, 1)
    title_gb:Resize(x + 50, 55)
    frame:Resize(title_gb:GetWidth() + 20, 85)
    config_gb:Resize(frame:GetWidth() - 20, frame:GetHeight() - 45)
end

function indun_list_viewer_title_frame_open()
    indun_list_viewer_save_current_char_counts()
    local frame = ui.CreateNewFrame("notice_on_pc", addon_name_lower .. "list_frame", 0, 0, 10, 10)
    AUTO_CAST(frame)
    frame:RemoveAllChild()
    frame:SetLayerLevel(99)
    frame:SetSkinName("test_frame_low")
    local title_gb = frame:CreateOrGetControl("groupbox", "title_gb", 0, 0, 10, 10)
    AUTO_CAST(title_gb)
    local texts = (g.lang == "Japanese") and {
        hard_raid = "ハード",
        auto_raid = "左クリック:ソロ入場{nl}右クリック:自動入場{nl} {nl}/掃討回数",
        mode_text = "チェックを入れるとスクロールモードに切替",
        display_text = "チェックしたキャラはレイド回数非表示",
        memo = "メモ",
        display = "表示",
        hidden = "チェックを入れると非表示キャラを表示しません"
    } or {
        hard_raid = "Hard Count",
        auto_raid = "Left-click: Solo Entry{nl}Right-click: Automatic Entry{nl} {nl}/Auto clear count",
        mode_text = "Switch to scroll mode when checked",
        display_text = "Checked characters hide raid count",
        memo = "Memo",
        display = "Disp",
        hidden = "If checked, do not show hidden characters"
    }
    local x = 185
    for _, raid_key in ipairs(RAID_KEYS) do
        local raid_info = RAID_INFO[raid_key]
        if g.settings.display_options[raid_info.name .. "_H"] == 1 then
            local pic = title_gb:CreateOrGetControl('picture', "title_pic_" .. raid_key .. "_H", x, 5, 30, 30)
            AUTO_CAST(pic)
            pic:SetImage(raid_info.icon)
            pic:SetEnableStretch(1)
            pic:EnableHitTest(1)
            pic:SetEventScript(ui.LBUTTONDOWN, "indun_list_viewer_enter_hard")
            pic:SetEventScriptArgNumber(ui.LBUTTONDOWN, raid_info.hard)
            pic:SetEventScriptArgString(ui.LBUTTONDOWN, "false")
            pic:SetTextTooltip("{ol}" .. texts.hard_raid)
            x = x + 30
        end
    end
    x = x + 30
    for _, raid_key in ipairs(RAID_KEYS) do
        local raid_info = RAID_INFO[raid_key]
        if g.settings.display_options[raid_info.name .. "_S"] == 1 then
            local pic = title_gb:CreateOrGetControl('picture', "title_pic_" .. raid_key .. "_S", x, 5, 30, 30)
            AUTO_CAST(pic)
            pic:SetImage(raid_info.icon)
            pic:SetEnableStretch(1)
            pic:EnableHitTest(1)
            pic:SetEventScript(ui.LBUTTONUP, "indun_list_viewer_enter_solo_or_auto")
            pic:SetEventScriptArgString(ui.LBUTTONUP, "1")
            pic:SetEventScriptArgNumber(ui.LBUTTONUP, raid_info.solo)
            pic:SetEventScript(ui.RBUTTONUP, "indun_list_viewer_enter_solo_or_auto")
            pic:SetEventScriptArgString(ui.RBUTTONUP, "2")
            pic:SetEventScriptArgNumber(ui.RBUTTONUP, raid_info.auto)
            pic:SetTextTooltip("{ol}" .. texts.auto_raid)
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
    local config_btn = title_gb:CreateOrGetControl('button', 'config_btn', 75, 5, 30, 30)
    AUTO_CAST(config_btn)
    config_btn:SetSkinName("None")
    config_btn:SetText("{img config_button_normal 30 30}")
    config_btn:SetEventScript(ui.LBUTTONUP, "indun_list_viewer_config")
    local mode_check = title_gb:CreateOrGetControl('checkbox', 'mode_check', 115, 5, 30, 30)
    AUTO_CAST(mode_check)
    mode_check:SetCheck(g.settings.default_options.display_mode == "slide" and 1 or 0)
    mode_check:SetEventScript(ui.LBUTTONUP, "indun_list_viewer_modechange")
    mode_check:SetTextTooltip("{ol}" .. texts.mode_text)
    local hidden_check = title_gb:CreateOrGetControl('checkbox', 'hidden_check', 150, 5, 30, 30)
    AUTO_CAST(hidden_check)
    hidden_check:SetCheck(g.settings.default_options.hidden)
    hidden_check:SetEventScript(ui.LBUTTONUP, "indun_list_viewer_modechange")
    hidden_check:SetTextTooltip("{ol}" .. texts.hidden)
    if g.settings.display_options["Memo"] == 1 then
        local memo_text = title_gb:CreateOrGetControl("richtext", "memo_text", x, 10)
        AUTO_CAST(memo_text)
        memo_text:SetText("{ol}" .. texts.memo)
        x = x + 160
    end
    local display_text = title_gb:CreateOrGetControl("richtext", "display_text", x, 10)
    AUTO_CAST(display_text)
    display_text:SetText("{ol}" .. texts.display)
    display_text:SetTextTooltip("{ol}" .. texts.display_text)
    frame:ShowWindow(1)
    indun_list_viewer_frame_open(frame)
end

function indun_list_viewer_close(frame, ctrl, str, num)
    local list_frame = ui.GetFrame(addon_name_lower .. "list_frame")
    list_frame:ShowWindow(0)
    if num == 1 then
        indun_list_viewer_title_frame_open()
    end
end

function indun_list_viewer_frame_open(frame)
    local title_gb = GET_CHILD(frame, "title_gb")
    AUTO_CAST(title_gb)
    local gb = frame:CreateOrGetControl("groupbox", "gb", 10, 35, 10, 10)
    AUTO_CAST(gb)
    gb:SetSkinName("bg")
    local sorted_char_list = {}
    for _, data in ipairs(g.sorted_settings) do
        if type(data) == "table" and data.pc_name then
            if g.settings.default_options.hidden == 0 or not data.hide then
                table.insert(sorted_char_list, data)
            end
        end
    end
    local y = 10
    local max_x = 0
    for _, data in ipairs(sorted_char_list) do
        local x = 35
        local pc_name = data.pc_name
        local name = gb:CreateOrGetControl("richtext", pc_name, x, y)
        AUTO_CAST(name)
        name:SetText(("{ol}{s14}" .. (g.login_name == pc_name and "{#FF4500}" or "") .. pc_name))
        indun_list_viewer_job_slot(frame, data, y)
        x = x + 60
        if not data.hide then
            local current_x = 180
            for _, raid_key in ipairs(RAID_KEYS) do
                local raid_info = RAID_INFO[raid_key]
                if g.settings.display_options[raid_info.name .. "_H"] == 1 then
                    local count = data.raid_count[raid_key .. "_H"] or "?"
                    local text_ctrl = gb:CreateOrGetControl("richtext", raid_key .. "_H_" .. pc_name, current_x, y)
                    AUTO_CAST(text_ctrl)
                    text_ctrl:SetText("{ol}{s14}( " .. count .. " )")
                    local limit = (raid_key == "P" or raid_key == "F") and 2 or 1
                    text_ctrl:SetColorTone(count == limit and "FF990000" or "FFFFFFFF")
                    current_x = current_x + 30
                end
            end
            current_x = current_x + 30
            for _, raid_key in ipairs(RAID_KEYS) do
                local raid_info = RAID_INFO[raid_key]
                if g.settings.display_options[raid_info.name .. "_S"] == 1 then
                    local count_a = data.raid_count[raid_key .. "_A"] or "?"
                    local text_a = gb:CreateOrGetControl("richtext", raid_key .. "_A_" .. pc_name, current_x, y)
                    AUTO_CAST(text_a)
                    text_a:SetText("{ol}{s14}( " .. count_a .. " )")
                    local limit = (raid_key == "P" or raid_key == "F") and 4 or 2
                    text_a:SetColorTone(count_a == limit and "FF990000" or "FFFFFFFF")
                    if raid_key ~= "D" then
                        current_x = current_x + 25
                        local count_s = data.auto_clear_count[raid_key .. "_S"] or 0
                        local text_s = gb:CreateOrGetControl("richtext", raid_key .. "_S_" .. pc_name, current_x, y)
                        AUTO_CAST(text_s)
                        text_s:SetText("{ol}{s14}/( " .. count_s .. " )")
                    end
                    current_x = current_x + 40
                end
            end
            if g.settings.display_options["Memo"] == 1 then
                local memo = gb:CreateOrGetControl('edit', 'memo' .. pc_name, current_x, y - 2, 180, 20)
                AUTO_CAST(memo)
                memo:SetFontName("white_14_ol")
                memo:SetTextAlign("left", "center")
                memo:SetSkinName("inventory_serch")
                memo:SetEventScript(ui.ENTERKEY, "indun_list_viewer_memo_save")
                memo:SetEventScriptArgString(ui.ENTERKEY, pc_name)
                memo:SetText(data.memo or "")
                current_x = current_x + 180
            end
            x = current_x
        end
        if x > max_x then
            max_x = x
        end
        y = y + 25
    end
    local display_x = max_x + 20
    y = 10
    for _, data in ipairs(sorted_char_list) do
        local pc_name = data.pc_name
        local line = gb:CreateOrGetControl("labelline", "line" .. pc_name, 25, y + 20, max_x - 20, 1)
        AUTO_CAST(line)
        line:SetSkinName("labelline_def_3")

        local display_check = gb:CreateOrGetControl('checkbox', 'display' .. pc_name, display_x, y - 5, 25, 25)
        AUTO_CAST(display_check)
        display_check:SetEventScript(ui.LBUTTONUP, "indun_list_viewer_display_save")
        display_check:SetEventScriptArgString(ui.LBUTTONUP, pc_name)
        display_check:SetCheck(data.hide and 1 or 0)
        y = y + 25
    end
    local frame_width = display_x + 60
    local frame_height = y + 50
    if g.settings.default_options.display_mode == "slide" and frame_height > 545 then
        frame_height = 545
        gb:EnableScrollBar(1)
    end
    frame:Resize(frame_width, frame_height)
    gb:Resize(frame:GetWidth() - 20, frame:GetHeight() - 45)
    title_gb:Resize(frame:GetWidth() - 20, 55)
    local display_text = GET_CHILD_RECURSIVELY(frame, "display_text")
    if display_text then
        AUTO_CAST(display_text)
        display_text:SetPos(display_x, 10)
    end
    local map_frame = ui.GetFrame("map")
    frame:SetPos((map_frame:GetWidth() - frame:GetWidth()) / 2, 35)
end

function indun_list_viewer_display_save(frame, ctrl, pc_name, num)
    local is_checked = ctrl:IsChecked()
    if g.settings[pc_name] then
        g.settings[pc_name].hide = (is_checked == 1)
        indun_list_viewer_save_settings()
    end
    indun_list_viewer_title_frame_open()
end

function indun_list_viewer_memo_save(frame, ctrl, pc_name, num)
    if g.settings[pc_name] then
        g.settings[pc_name].memo = ctrl:GetText()
        indun_list_viewer_save_settings()
    end
    ui.SysMsg(g.lang == "Japanese" and "メモを登録しました。" or "MEMO registered.")
end

function indun_list_viewer_job_slot(frame, data, y)
    local pc_name = data.pc_name
    local job_id_str = data.jobid or ""
    local president_id_str = data.president_jobid or ""
    local _, _, last_job_id = GetJobListFromAdventureBookCharData(pc_name)
    local prepresentative_job_id = (president_id_str ~= "") and president_id_str or last_job_id
    local job_class = GetClassByType("Job", tonumber(prepresentative_job_id))
    local job_icon_name = TryGetProp(job_class, "Icon")
    local gb = GET_CHILD_RECURSIVELY(frame, "gb")
    local job_slot = gb:CreateOrGetControl("slot", "jobslot" .. pc_name, 5, y - 4, 25, 25)
    AUTO_CAST(job_slot)
    job_slot:SetSkinName("None")
    job_slot:EnableHitTest(1)
    job_slot:EnablePop(0)
    local job_icon = CreateIcon(job_slot)
    job_icon:SetImage(job_icon_name)
    local tooltip_parts = {}
    if job_id_str ~= "" then
        local highlight_color = "{#FF0000}"
        for id_str in job_id_str:gmatch("/([^/]+)") do
            local job_id_num = tonumber(id_str)
            if job_id_num then
                local cls = GetClassByType("Job", job_id_num)
                if cls and cls.Name then
                    local name = (string.gsub(dic.getTranslatedStr(cls.Name), "{s18}", ""))
                    if id_str == president_id_str then
                        table.insert(tooltip_parts, highlight_color .. name .. "{/}")
                    else
                        table.insert(tooltip_parts, name)
                    end
                end
            end
        end
    else
        if job_class and job_class.Name then
            local name = TryGetProp(job_class, "Name")
            table.insert(tooltip_parts, (string.gsub(dic.getTranslatedStr(name), "{s18}", "")))
        end
    end
    local tooltip_text = "{ol}" .. table.concat(tooltip_parts, "{nl}")
    if g.login_name == pc_name then
        local r_click_text = (g.lang == "Japanese") and "右クリック: 表示アイコン選択" or
                                 "Right-click: Select Display Icon"
        tooltip_text = tooltip_text .. "{nl} {nl}" .. r_click_text
        job_slot:SetEventScript(ui.RBUTTONDOWN, "STATUS_OPEN_CLASS_DROPLIST")
        local name_text = GET_CHILD_RECURSIVELY(gb, pc_name)
        name_text:SetEventScript(ui.RBUTTONDOWN, "STATUS_OPEN_CLASS_DROPLIST")
    end
    -- InstantCCアドオン連携
    if type(_G["INSTANTCC_ON_INIT"]) == "function" then
        local cc_text = (g.lang == "Japanese") and "左クリック: キャラクターチェンジ" or
                            "Left-click: Character Change"
        tooltip_text = tooltip_text .. "{nl} {nl}{#FF4500}" .. cc_text
        job_slot:SetEventScript(ui.LBUTTONDOWN, "indun_list_viewer_INSTANTCC_DO_CC")
        job_slot:SetEventScriptArgString(ui.LBUTTONDOWN, data.cid)
        job_slot:SetEventScriptArgNumber(ui.LBUTTONDOWN, data.layer)
        local name_text = GET_CHILD_RECURSIVELY(gb, pc_name)
        name_text:SetEventScript(ui.LBUTTONDOWN, "indun_list_viewer_INSTANTCC_DO_CC")
        name_text:SetEventScriptArgString(ui.LBUTTONDOWN, data.cid)
        name_text:SetEventScriptArgNumber(ui.LBUTTONDOWN, data.layer)
        name_text:SetTextTooltip(tooltip_text)
    end
    job_icon:SetTextTooltip(tooltip_text)
end

function indun_list_viewer_INSTANTCC_DO_CC(frame, ctrl, cid, layer)
    INSTANTCC_DO_CC(cid, layer)
end

function indun_list_viewer_modechange(frame, ctrl, argStr, argNum)
    local ctrl_name = ctrl:GetName()
    local is_checked = ctrl:IsChecked()
    if ctrl_name == "hidden_check" then
        g.settings.default_options.hidden = is_checked
    else -- mode_check
        g.settings.default_options.display_mode = is_checked == 1 and "slide" or "full"
    end
    indun_list_viewer_save_settings()
    indun_list_viewer_title_frame_open()
end

function indun_list_viewer_STATUS_SELET_REPRESENTATION_CLASS(my_frame, my_msg)
    local _, select_key = g.get_event_args(my_msg)
    local pc_job_info = session.GetMainSession():GetPCJobInfo()
    local job_count = pc_job_info:GetJobCount()
    local job_id_parts = {}
    for i = 0, job_count - 1 do
        local job_info = pc_job_info:GetJobInfoByIndex(i)
        table.insert(job_id_parts, job_info.jobID)
    end
    g.settings[g.login_name].jobid = "/" .. table.concat(job_id_parts, "/")
    g.settings[g.login_name].president_jobid = tostring(select_key)
    indun_list_viewer_save_settings()
    indun_list_viewer_title_frame_open()
end

function indun_list_viewer_enter_solo_or_auto(frame, ctrl, move_type_str, indun_type)
    local move_type = tonumber(move_type_str)
    local frame = ui.GetFrame(addon_name_lower .. "list_frame")
    frame:ShowWindow(0)
    ReqRaidAutoUIOpen(indun_type)
    if move_type == 2 then
        local top_frame = ui.GetFrame("indunenter")
        local indun_cls = GetClassByType('Indun', top_frame:GetUserValue('INDUN_TYPE'))
        local min_rank = TryGetProp(indun_cls, 'PCRank')
        if min_rank and min_rank > session.GetPcTotalJobGrade() then
            ui.SysMsg(ScpArgMsg('IndunEnterNeedPCRank', 'NEED_RANK', min_rank))
            return
        end
    end
    ReserveScript(string.format("ReqMoveToIndun(%d, 0)", move_type), 0.3)
end

function indun_list_viewer_INDUNINFO_SET_BUTTONS(indun_type, ctrl)
    local indun_cls = GetClassByType('Indun', indun_type)
    local dungeon_type = TryGetProp(indun_cls, "DungeonType", "None")
    local btn_info_cls = GetClassByStrProp("IndunInfoButton", "DungeonType", dungeon_type)
    if dungeon_type == "Raid" then
        btn_info_cls = INDUNINFO_SET_BUTTONS_FIND_CLASS(indun_cls)
    end
    local red_button_scp = TryGetProp(btn_info_cls, "RedButtonScp")
    ctrl:SetUserValue('MOVE_INDUN_CLASSID', indun_cls.ClassID)
    ctrl:SetEventScript(ui.LBUTTONUP, red_button_scp)
end

function indun_list_viewer_enter_hard(frame, ctrl, str, indun_type)
    local list_frame = ui.GetFrame(addon_name_lower .. "list_frame")
    if str == "false" then
        indun_list_viewer_INDUNINFO_SET_BUTTONS(indun_type, ctrl)
        ReserveScript(string.format("indun_list_viewer_enter_hard(nil, nil, 'true', %d)", indun_type), 0.5)
    else
        SHOW_INDUNENTER_DIALOG(indun_type)
        list_frame:ShowWindow(0)
    end
end

