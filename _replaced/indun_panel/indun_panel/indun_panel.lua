-- v1.0.2 チーム倉庫でESC押してもインベントリが表示される様に変更
-- v1.0.3 CCアイコンを配置、掃討の残りを表示（使っても減らないツライ）
-- v1.0.4　print排除
-- v1.0.5 イヤリングレイド
-- v1.0.6 チャレと分裂のチケット交換、表示更新機能
-- v1.0.7 当日分裂券が更新しないのを修正 イヤリングレイド回数表示更新 フレーム変えた。ヴェルニケのBUYUSE作成。コイン商店の残高表示
-- AUTOMODE時に直接ボタン押した状態に。ハードは再入場系が怖いのでそのまま
-- v1.0.8 チャレとか分裂券買う時にヴェルニケ券買っちゃうバグ修正('Д')
-- v1.0.9 分裂券を買う辺りを修正。不要になったので倉庫閉めたらインベも閉める
-- v1.1.0 ヴェルニケチケットの傭兵団コインの表示バグ修正。ゲームスタート時の傭兵団コインショップの閉じ方を修正。オートズーム機能
-- v1.1.1 23.09.05patch対応。オートズーム機能をフィールド時には独立させた。嘆きの墓地追加、チャレ分裂のチケットの使い方を修正。
-- v1.1.2 蝶々とスローガティスの掃討バグ修正
-- v1.1.3 オートズーム無効機能。常時展開中でも閉められる様に変更
-- v1.1.4 表示するレイドを選択出来る様に変更
-- v1.1.5 選択表示使用の際の表示更新バグ修正。ペットボタン撤去。TOSイベントショップボタン設置
-- v1.1.6 谷間園児対応
-- v1.1.7 台湾verに対応
-- v1.1.8 日本語Verに台湾語が混ざってたのを修正。BUYUSEボタンに説明追加。
-- v1.1.9 スロガ、ウピニスハード入場追加
-- v1.2.0 嘆きの墓地異空間追加、バラックキャラのレイド消化一覧機能
-- v1.2.1 2秒毎に重い処理して画面カクついてたのを修正。オートクリアを使用した時とCC3秒後だけ処理を走らせる様に変更。反省してる。ウピニスハードの色替え。
-- v1.2.2 レイド消化一覧機能、月曜6時のリセットに対応
-- v1.2.3 レイド消化一覧機能が重いので、使うか選べる様に。
-- v1.2.4 バグ修正
-- v1.2.5 月曜日初期化処理の見直し修正。
-- v1.2.6 レイド消化一覧機能削除
-- v1.2.7 協同ボスレイド追加。チャレンジと分裂を連続で入れる様に。分裂の自動マッチングボタンを押すのを切替出来る様に。英語モードを選べる様に。
-- v1.2.8 メレジナ追加。週ボスのとこ修正。めっちゃコード変えた。ChatGPTありがとう。
-- v1.2.9 海外バージョンバグってたの修正。INDUN_PANEL_LANG関数ミスってた。
-- v1.3.0 ギルティネとイヤリングとファロウロスハードバグってたの修正
-- v1.3.1 レイヤー見直した。やっぱり前までが良いよね。
-- v1.3.2 メレジナハード、シーズンチャレンジ追加
-- v1.3.3 チャレンジ券と分裂券と真摯に向き合った。優先順位とか変更した。
-- v1.3.4 メレジナ、スロガ、ウピニスの自動チケットを使うボタンを付けた。
-- v1.3.5 掃討バフある場合、自動でアイテム使って掃討する様に変更
-- v1.3.6 TOSショップの分裂を好感したいのにチャレンジ券交換していたバグ修正。
-- v1.3.7 メレジナハードに入れなかった問題修正。
-- v1.3.8 チャレ券使用の順番ミスってたので修正。
-- v1.3.9 リファクタリング。過去女神商店。
-- v1.4.0 パネル開いてる時に他のフレームに干渉してそうなところを修正。テルハルシャ修正。
-- v1.4.1 240912アップデート対応
-- v1.4.2 色々バグ修正。
-- v1.4.3 設定でレイドを非表示にしてた場合に更新処理バグってたの修正。
-- v1.4.4 分裂券のデイリー分買えなかったの修正。くやしい
-- v1.4.5 ネリゴレハード追加
-- v1.4.6 分裂券とチャレ券使う順番明確化。
-- v1.4.7 20241112のチャレンジアップデートで殺されたのを直した。
-- v1.4.8 デザインをユーザーに叩かれたので元に戻した。クヤシイ
-- v1.4.9 レイドチケット周り修正、ヴェルニケチケ修正
-- v1.5.0 ヴェルニケチケット周り再修正。チャレと分裂のチケット使用時のコード見直し。
-- v1.5.1 装備加工とか付けた。ヴェルニケバグってたクヤシイTOSイベコイン表示とか。レティワープ付けた。
-- v1.5.2 バグ修正
-- v1.5.3 傭兵団コインのチャレンジ券変換をMAXまで出来る様に。そんなヤツおるんか？バグ修正
-- v1.5.4 レダニア足したけどまだテスト出来てない
-- v1.5.5 チャレンジ系をいじった
-- v1.5.6 フレーム移動出来るように
-- v1.5.7 移動後フレーム固定
-- v1.5.8 フレーム固定を設定に変更。墓チケットを使える様に。その他コード見直しacutilやめた。
-- v1.5.9 傭兵団コインの1日分裂券バグってたの修正。でもIMCが勝手に仕様変更したのもアカンと思うんです。
-- v1.6.0 ヴェルニケBUYUSEで入れる様に。マーケットボタン。テスト的にフィールドでも表示出来る様に。
-- v1.6.1 閉じてる時に出すアイコン選べる様に。ilvと一部統合。
-- v1.6.2 チャレ券4枚で分裂券作って入場まで。アイコンバグ修正。
-- v1.6.3 傭兵団チャレ券オーバーバイの場合にUIおかしかったの修正。フィールドの仕様も修正。チャレンジ券の切替時分かりやすく
-- v1.6.4 CCボタン右クリックでOCSL表示機能、傭兵団コイン商店の開き方修正
-- v1.6.5 250902大型アプデ対応。住宅ポイント表示他。魔の巣窟、テルハルシャBUYUSE、JSRの時差調整
-- v1.6.5.1 セット表示切替。表示中の負荷軽く
-- v1.6.5.2 セット名変更機能追加。網掛け表示変更、フレームスキン変更機能追加。
-- v1.6.5.3 テルハルシャUSEボタンバグってたの修正、IMCの20251023バグ修正
-- v1.6.5.4 チャレンジ回数バグってたの修正
-- v1.6.6 正式版
-- v1.6.7 520チャレンジ券買えなかったバグ修正
-- v1.6.8 チャレンジスケジュール機能追加
local addonName = "indun_panel"
local addon_name_lower = string.lower(addonName)
local author = "norisan"
local ver = "1.6.8"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}

local g = _G["ADDONS"][author][addonName]
local json = require('json')

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

local convert_tbl = {
    ["veliora"] = "belliora",
    ["limara"] = "laimara",
    ["redania"] = "ledania",
    ["spreader"] = "reservoir",
    ["velnice"] = "bernice",
    ["earring"] = "memory",
    ["cemetery"] = "wailing",
    ["demonlair"] = "ashaq"
}

-- 1001 520ソロチャレ 1004 540ソロチャレ 1005 540自動チャレ 2000 520分裂 2001 540分裂
local induntype = {{
    challenge = {
        solo_520 = 1001,
        solo_540 = 1004,
        pt_540 = 1005
    }
}, {
    singularity = {
        singularity_520 = 2000,
        singularity_540 = 2001
    }
}, {
    veliora = {
        h = 727,
        s = 726,
        a = 725,
        ac = 80045
    }
}, {
    limara = {
        h = 724,
        s = 723,
        a = 722,
        ac = 80043
    }
}, {
    redania = {
        h = 718,
        s = 717,
        a = 716,
        ac = 80039
    }
}, {
    neringa = {
        h = 709,
        s = 708,
        a = 707,
        ac = 80035
    }
}, {
    golem = {
        h = 712,
        s = 711,
        a = 710,
        ac = 80037
    }
}, {
    merregina = {
        s = 696,
        a = 695,
        h = 697,
        ac = 80032
    }
}, {
    slogutis = {
        s = 689,
        a = 688,
        h = 690,
        ac = 80031
    }
}, {
    upinis = {
        s = 686,
        a = 685,
        h = 687,
        ac = 80030
    }
}, {
    roze = {
        s = 680,
        a = 679,
        h = 681,
        ac = 80015
    }
}, {
    falouros = {
        s = 677,
        a = 676,
        h = 678,
        ac = 80017
    }
}, {
    spreader = {
        s = 674,
        a = 673,
        h = 675,
        ac = 80016
    }
}, {
    jellyzele = {
        s = 672,
        a = 671,
        h = 670
    }
}, {
    delmore = {
        s = 667,
        a = 666,
        h = 665
    }
}, {
    telharsha = 623
}, {
    velnice = 201
}, {
    giltine = {
        s = 669,
        a = 635,
        h = 628
    }
}, {
    earring = {
        s = 661,
        a = 662,
        h = 663
    }
}, {
    cemetery = 684
}, {
    demonlair = 728
}, {
    jsr = 0
}}

local buffIDs = {
    [725] = 80045, -- ベリオラ
    [722] = 80043, -- ライマラ
    [716] = 80039, -- レダニア
    [707] = 80035, -- ネリンガ
    [710] = 80037, -- ゴーレム
    [673] = 80016, -- スプレッダー
    [676] = 80017, -- ファロウス
    [679] = 80015, -- ロゼ
    [685] = 80030, -- 蝶々
    [688] = 80031, -- スロガ
    [695] = 80032 -- メレジ
}
local raidTable = {
    [725] = {11210057, 11210056, 11210055},
    [722] = {11210053, 11210052, 11210051},
    [716] = {11210044, 10820040, 11210043, 11210042},
    [707] = {11210024, 11210023, 11210022},
    [710] = {11210028, 11210027, 11210026},
    [695] = {11200356, 11200355, 11200354},
    [688] = {11200290, 10820036, 11200289, 11200288},
    [685] = {11200281, 10820035, 11200280, 11200279},
    [679] = {108020026, 11200222, 11200221, 11200220}
}

local DEFAULT_SETTINGS = {
    checkbox = 0,
    zoom = 0,
    challenge_checkbox = 1,
    singularity_checkbox = 1,
    veliora_checkbox = 1,
    limara_checkbox = 1,
    redania_checkbox = 1,
    neringa_checkbox = 1,
    golem_checkbox = 1,
    merregina_checkbox = 1,
    slogutis_checkbox = 1,
    upinis_checkbox = 1,
    roze_checkbox = 1,
    falouros_checkbox = 1,
    spreader_checkbox = 1,
    jellyzele_checkbox = 1,
    delmore_checkbox = 1,
    telharsha_checkbox = 1,
    velnice_checkbox = 1,
    giltine_checkbox = 1,
    earring_checkbox = 1,
    cemetery_checkbox = 1,
    demonlair_checkbox = 1,
    jsr_checkbox = 1,
    singularity_check = 0,
    en_ver = 0,
    season_checkbox = 1,
    x = 665,
    y = 30,
    move = 0,
    use_set = "None",
    set_a = {},
    set_b = {},
    set_c = {},
    challenge_map = 0,
    base_date = ""
}

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
    if not g.REGISTER[origin_func_name] then -- g.REGISTERはON_INIT内で都度初期化
        g.REGISTER[origin_func_name] = true
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
    g.settingsFileLoc = string.format("../addons/%s/%s/settings.json", addon_name_lower, g.active_id)
    g.settings_path = g.settingsFileLoc
end
g.mkdir_new_folder()

function g.save_settings()
    local function save_json(path, tbl)
        local file = io.open(path, "w")
        local str = json.encode(tbl)
        file:write(str)
        file:close()
    end
    save_json(g.settings_path, g.settings)
end

function g.load_settings()
    local function load_json(path)
        local file = io.open(path, "r")
        if file then
            local content = file:read("*all")
            file:close()
            local table = json.decode(content)
            return table
        else
            return nil
        end
    end
    local settings = load_json(g.settings_path)
    if not settings then
        settings = DEFAULT_SETTINGS
    else
        for key, default_value in pairs(DEFAULT_SETTINGS) do
            if settings[key] == nil then
                settings[key] = default_value
            end
        end
        if settings.use_set and settings.use_set ~= "None" then
            local keys_to_remove = {}
            for key, value in pairs(settings) do
                if string.find(key, "_checkbox$") then
                    table.insert(keys_to_remove, key)
                end
            end
            for _, key_to_remove in ipairs(keys_to_remove) do
                settings[key_to_remove] = nil
            end
        else
            local checkboxes_to_copy = {}
            for key, value in pairs(settings) do
                if string.find(key, "_checkbox$") then
                    checkboxes_to_copy[key] = value
                end
            end
            for set_key, set_table in pairs(settings) do
                if string.find(set_key, "set_") and type(set_table) == "table" then

                    for checkbox_key, checkbox_value in pairs(checkboxes_to_copy) do
                        set_table[checkbox_key] = checkbox_value
                    end
                end
            end
        end
    end
    g.settings = settings
    g.save_settings()
end

function g.get_map_type()
    local map_name = session.GetMapName()
    local map_cls = GetClass("Map", map_name)
    local map_type = map_cls.MapType
    return map_type
end

function g.setup_hook_and_event_before_after(my_addon, origin_func_name, my_func_name, bool, before_after)
    g.FUNCS = g.FUNCS or {}
    if not g.FUNCS[origin_func_name] then
        g.FUNCS[origin_func_name] = _G[origin_func_name]
    end
    local origin_func = g.FUNCS[origin_func_name]
    if bool == nil then
        bool = true
    end
    local function hooked_function(...)
        if bool == true then
            if before_after == "before" then
                _G[my_func_name](...)
            end
            local results = {origin_func(...)}
            if before_after == "after" then
                _G[my_func_name](...)
            end
            return table.unpack(results)
        else
            imcAddOn.BroadMsg(origin_func_name, ...)
            return
        end
    end
    _G[origin_func_name] = hooked_function
    if not bool then
        g.REGISTER = g.REGISTER or {}
        if not g.REGISTER[origin_func_name .. my_func_name] then
            g.REGISTER[origin_func_name .. my_func_name] = true
            my_addon:RegisterMsg(origin_func_name, my_func_name)
        end
    end
end

g.sing = false
function INDUN_PANEL_ON_INIT(addon, frame)
    g.addon = addon
    g.frame = frame
    g.framename = addonName
    g.lang = option.GetCurrentCountry()
    g.REGISTER = {}
    local map_id = session.GetMapID()
    -- 8022 ヴェルニケ
    if g.get_map_type() == "City" or (g.settings.field_mode == 1 and g.get_map_type() ~= "Instance" and map_id ~= 8022) then
        addon:RegisterMsg('GAME_START', "indun_panel_GAME_START")
    end
    g.setup_hook_and_event(addon, "INDUN_ALREADY_PLAYING", "indun_panel_INDUN_ALREADY_PLAYING", false)
    g.setup_hook_and_event_before_after(addon, "CHAT_SYSTEM", "indun_panel_CHAT_SYSTEM", true, "after")
    addon:RegisterMsg('GAME_START_3SEC', "indun_panel_GAME_START_3SEC")
    addon:RegisterMsg('INV_ITEM_ADD', "indun_panel_inventory_change_msg")
    addon:RegisterMsg('INV_ITEM_REMOVE', "indun_panel_inventory_change_msg")
    addon:RegisterMsg("UI_CHALLENGE_MODE_TOTAL_KILL_COUNT", "indun_panel_ON_CHALLENGE_MODE_TOTAL_KILL_COUNT")
end

function indun_panel_GAME_START()
    -- if not g.settings then
    g.load_settings()
    -- end
    if g.settings.checkbox == 0 then
        indun_panel_frame_init()
    else
        indun_panel_frame_open()
    end
    indun_panel_daily_reset()
    local indun_panel = ui.GetFrame("indun_panel")
    indun_panel:RunUpdateScript("indun_panel_daily_reset", 60.0)
end

function indun_panel_GAME_START_3SEC()
    -- indun_panel_autozoom()
    local indun_panel = ui.GetFrame("indun_panel")
    g.challenge_start_time = imcTime.GetAppTimeMS()
    indun_panel:StopUpdateScript("indun_panel_challenge")
    indun_panel:RunUpdateScript("indun_panel_challenge", 0.1)
    -- indun_panel:RunUpdateScript("indun_panel_get_my_housing_point_callback_ready", 30.0)
end

function indun_panel_inventory_change_msg(frame, msg, str, num)
    g.update_try = 0
end

function indun_panel_challenge(frame)
    if not g.challenge_start_time then
        frame:StopUpdateScript("indun_panel_challenge")
        return 0
    end
    local now = imcTime.GetAppTimeMS()
    if (now - g.challenge_start_time) >= 3000 then
        frame:StopUpdateScript("indun_panel_challenge")
        g.challenge_start_time = nil
        return 0
    end
    local isAutoChallengeMap = session.IsAutoChallengeMap()
    local isSoloChallengeMap = session.IsSoloChallengeMap()
    if isAutoChallengeMap == true or isSoloChallengeMap == true then
        frame:ShowWindow(0)
        frame:StopUpdateScript("indun_panel_challenge")
        g.challenge_start_time = nil
        return 0
    end
    return 1
end

function indun_panel_ON_CHALLENGE_MODE_TOTAL_KILL_COUNT(frame, msg)
    if g.settings.base_date ~= "" then
        return
    end
    local current_map_name = session.GetMapName()
    local cnt = 0
    local found_clsid = nil
    local challenge_map_list, count = GetClassList('challenge_mode_auto_map')
    for i = 0, count - 1 do
        local map_cls = GetClassByIndexFromList(challenge_map_list, i)
        if map_cls then
            local map_name = map_cls.MapName
            if current_map_name == map_name then
                cnt = cnt + 1
                if found_clsid == nil then
                    found_clsid = map_cls.ClassID
                end
            end
        end
    end
    if cnt == 1 then
        g.settings.challenge_map = found_clsid
        local server_time_str = date_time.get_lua_now_datetime_str()
        if server_time_str then
            local y, m, d, H, M, S = server_time_str:match("(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)")
            if y then
                local time_table = {
                    year = tonumber(y),
                    month = tonumber(m),
                    day = tonumber(d),
                    hour = 0,
                    min = 0,
                    sec = 0
                }
                g.settings.base_date = os.time(time_table)
            end
        end
        g.save_settings()
    end
end

function indun_panel_daily_reset(indun_panel)
    if g.settings.toscoin == nil then
        g.settings.toscoin = 0
    end
    local server_time_str = date_time.get_lua_now_datetime_str()
    if not server_time_str then
        return 1
    end
    local y, m, d, H, M, S = server_time_str:match("(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)")
    if not y then
        return 1
    end
    local now_table = {
        year = tonumber(y),
        month = tonumber(m),
        day = tonumber(d),
        hour = tonumber(H),
        min = tonumber(M),
        sec = tonumber(S)
    }
    local server_now_timestamp = os.time(now_table)
    if g.settings.reset_time == nil or g.settings.reset_time < server_now_timestamp then
        g.settings.toscoin = 0
        g.recipe_trade = false
        g.settings.reset_time = indun_panel_get_next_reset_timestamp(server_now_timestamp, now_table)
        g.save_settings()
    end
    if g.get_map_type() == "City" and not g.recipe_trade then
        if INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_41") == 0 then
            local earthtowershop = ui.GetFrame('earthtowershop')
            if earthtowershop then
                earthtowershop:Resize(0, 0)
                indun_panel_minimized_pvpmine_shop_init()
                g.recipe_trade = true
            end
        end
    end
    return 1
end

function indun_panel_get_next_reset_timestamp(now_timestamp, date_table)
    if not now_timestamp or not date_table then
        return 0
    end
    local today_6am_timestamp = os.time({
        year = date_table.year,
        month = date_table.month,
        day = date_table.day,
        hour = 6,
        min = 0,
        sec = 0
    })
    if now_timestamp < today_6am_timestamp then
        return today_6am_timestamp
    else
        return today_6am_timestamp + 86400
    end
end

function indun_panel_minimized_pvpmine_shop_init()
    local shopframe = ui.GetFrame('earthtowershop')
    pc.ReqExecuteTx_NumArgs("SCR_PVP_MINE_SHOP_OPEN", 0);
    shopframe:RunUpdateScript("INDUN_PANEL_EARTHTOWERSHOP_CLOSE_RESTART", 0.2)
end

function INDUN_PANEL_EARTHTOWERSHOP_CLOSE_RESTART(frame)
    local shopframe = ui.GetFrame('earthtowershop')
    if shopframe:IsVisible() == 1 then
        shopframe:Resize(580, 1920)
        ui.CloseFrame("earthtowershop")
        return 0
    else
        shopframe:Resize(580, 1920)
        return 1
    end
end

function indun_panel_INPUT_STRING_BOX(frame, ctrl, ctrl_name, num)
    local inputstring = ui.GetFrame("inputstring")
    inputstring:Resize(500, 220)
    inputstring:SetLayerLevel(999)
    local edit = GET_CHILD(inputstring, 'input', "ui::CEditControl")
    -- edit:SetEnableEditTag(1)
    edit:SetNumberMode(0)
    edit:SetMaxLen(999)
    edit:SetText("")
    inputstring:ShowWindow(1)
    inputstring:SetEnable(1)
    local title = inputstring:GetChild("title")
    AUTO_CAST(title)
    local text = g.lang == "Japanese" and "{ol}{#FFFFFF}セット名を入力" or "{ol}{#FFFFFF}Enter set name"
    title:SetText(text)
    local confirm = inputstring:GetChild("confirm")
    confirm:SetEventScript(ui.LBUTTONUP, "indun_panel_save_setname")
    confirm:SetEventScriptArgString(ui.LBUTTONUP, ctrl_name)
    edit:SetEventScript(ui.ENTERKEY, "indun_panel_save_setname")
    edit:SetEventScriptArgString(ui.ENTERKEY, ctrl_name)
    edit:AcquireFocus()
end

function indun_panel_save_setname(inputstring, ctrl, ctrl_name, num)
    inputstring:ShowWindow(0)
    local edit = GET_CHILD(inputstring, 'input')
    local get_text = edit:GetText()
    if get_text == "" then
        local text = g.lang == "Japanese" and "{ol}文字を入力してください" or "{ol}Please enter text"
        ui.SysMsg(text)
        indun_panel_INPUT_STRING_BOX(ctrl_name)
        return
    end
    local text = g.lang == "Japanese" and "{ol}セット名を登録しました" or "{ol}Set name registered"
    ui.SysMsg(text)
    if not g.settings.set_names then
        g.settings.set_names = {}
    end
    g.settings.set_names[ctrl_name] = get_text
    g.save_settings()
    indun_panel_config_gb_open("", "", "", "")
end

function indun_panel_setup_frame(frame)
    local map_frame = ui.GetFrame("map")
    local width = map_frame:GetWidth()
    if not g.settings.x then
        g.settings.x = 665
        g.settings.y = 30
        g.save_settings()
    end
    local x = g.settings.x
    if width <= 1920 and x > 1920 then
        x = g.settings.x / 21 * 16
    end
    frame:SetPos(x, g.settings.y)
    frame:SetTitleBarSkin("None")
    frame:EnableHittestFrame(1)
    frame:EnableMove(g.settings.move or 0)
    if g.settings.move == 1 then
        frame:SetEventScript(ui.LBUTTONUP, "indun_panel_frame_drag")
    else
        frame:SetEventScript(ui.LBUTTONUP, "None")
    end
end

-- 新設: 共通のボタンを作成する関数
function indun_panel_create_common_buttons(frame)
    local ccbtn = frame:CreateOrGetControl('button', 'ccbtn', 85, 5, 30, 30)
    AUTO_CAST(ccbtn)
    ccbtn:SetSkinName("None")
    ccbtn:SetText("{img barrack_button_normal 30 30}")
    local lbutton_action = "APPS_TRY_MOVE_BARRACK"
    local rbutton_action = nil
    local tooltip_parts = {}
    local lbutton_tooltip = nil
    if type(_G["INSTANTCC_APPS_TRY_MOVE_BARRACK"]) == "function" then
        lbutton_action = "INSTANTCC_APPS_TRY_MOVE_BARRACK"
        lbutton_tooltip = "[InstantCC] Open"
    end
    if type(_G["indun_list_viewer_title_frame_open"]) == "function" then
        lbutton_action = "indun_list_viewer_title_frame_open"
        lbutton_tooltip = "Left-Click: [ILV] Open"
        local indun_list_viewer = ui.GetFrame("indun_list_viewer")
        if indun_list_viewer:IsVisible() == 1 then
            indun_list_viewer:ShowWindow(0)
        end
    end
    if lbutton_tooltip then
        table.insert(tooltip_parts, lbutton_tooltip)
    end
    if type(_G["other_character_skill_list_frame_open"]) == "function" then
        rbutton_action = "other_character_skill_list_frame_open"
        table.insert(tooltip_parts, "Right-Click: [OCSL] Open")
    end
    ccbtn:SetEventScript(ui.LBUTTONUP, lbutton_action)
    if rbutton_action then
        ccbtn:SetEventScript(ui.RBUTTONUP, rbutton_action)
    end
    local default_tooltip = g.lang == "Japanese" and "{ol}バラックに戻ります" or "{ol}Return to Barracks"
    ccbtn:SetTextTooltip(#tooltip_parts > 0 and "{ol}" .. table.concat(tooltip_parts, "{nl}") or default_tooltip)
    return 115 -- 次のボタンを開始するX座標を返す
end

-- 新設: キー名に応じたボタンを作成するヘルパー関数
function indun_panel_create_shortcut_button(frame, key_name, x)
    local account_obj = GetMyAccountObj()
    local coin_count = 0
    local tooltip_msg = ""
    local btn = nil
    if key_name == "tos" and g.get_map_type() == "City" then
        btn = frame:CreateOrGetControl("button", "tosshop", x + 2, 8, 25, 25)
        btn:SetText("{img icon_item_Tos_Event_Coin 25 25}")
        tooltip_msg = g.lang == "Japanese" and "{ol}TOSイベントショップ" or "{ol}TOS Event Shop"
        btn:SetEventScript(ui.LBUTTONUP, "indun_panel_event_tos_whole_shop_open")
    elseif key_name == "gabija" and g.get_map_type() == "City" then
        btn = frame:CreateOrGetControl("button", "gabija", x, 7, 29, 29)
        btn:SetText("{img goddess_shop_btn 29 29}")
        coin_count = GET_COMMAED_STRING(TryGetProp(account_obj, "GabijaCertificate", "0"))
        tooltip_msg =
            (g.lang == "Japanese" and "{ol}ガビヤショップ{nl}" or "{ol}Gabija Shop{nl}") .. "{#FFFF00}" ..
                coin_count
        btn:SetEventScript(ui.LBUTTONUP, "REQ_GabijaCertificate_SHOP_OPEN")
    elseif key_name == "vakarine" and g.get_map_type() == "City" then
        btn = frame:CreateOrGetControl("button", "vakarine", x, 7, 29, 29)
        btn:SetText("{img goddess2_shop_btn 29 29}")
        coin_count = GET_COMMAED_STRING(TryGetProp(account_obj, "VakarineCertificate", "0"))
        tooltip_msg = (g.lang == "Japanese" and "{ol}ヴァカリネショップ{nl}" or "{ol}Vakarine Shop{nl}") ..
                          "{#FFFF00}" .. coin_count
        btn:SetEventScript(ui.LBUTTONUP, "REQ_VakarineCertificate_SHOP_OPEN")
    elseif key_name == "rada" and g.get_map_type() == "City" then
        btn = frame:CreateOrGetControl("button", "rada", x, 8, 29, 29)
        btn:SetText("{img goddess3_shop_btn 29 29}")
        coin_count = GET_COMMAED_STRING(TryGetProp(account_obj, "RadaCertificate", "0"))
        tooltip_msg = (g.lang == "Japanese" and "{ol}ラダショップ{nl}" or "{ol}Rada Shop{nl}") .. "{#FFFF00}" ..
                          coin_count
        btn:SetEventScript(ui.LBUTTONUP, "REQ_RadaCertificate_SHOP_OPEN")
    elseif key_name == "jurate" and g.get_map_type() == "City" then
        btn = frame:CreateOrGetControl("button", "jurate", x, 7, 29, 29)
        btn:SetText("{img goddess4_shop_btn 29 29}")
        coin_count = GET_COMMAED_STRING(TryGetProp(account_obj, "JurateCertificate", "0"))
        tooltip_msg =
            (g.lang == "Japanese" and "{ol}ユラテショップ{nl}" or "{ol}Jurate Shop{nl}") .. "{#FFFF00}" ..
                coin_count
        btn:SetEventScript(ui.LBUTTONUP, "REQ_JurateCertificate_SHOP_OPEN")
    elseif key_name == "austeja" then
        btn = frame:CreateOrGetControl("button", "austeja", x, 7, 29, 29)
        btn:SetText("{img goddess5_shop_btn 29 29}")
        coin_count = GET_COMMAED_STRING(TryGetProp(account_obj, "AustejaCertificate", "0"))
        tooltip_msg = (g.lang == "Japanese" and "{ol}アウステヤショップ{nl}" or "{ol}Austeja Shop{nl}") ..
                          "{#FFFF00}" .. coin_count
        btn:SetEventScript(ui.LBUTTONUP, "REQ_AustejaCertificate_SHOP_OPEN")
    elseif key_name == "pvp_mine" then
        btn = frame:CreateOrGetControl("button", "pvp_mine", x, 7, 29, 29)
        btn:SetText("{img pvpmine_shop_btn_total 29 29}")
        tooltip_msg = g.lang == "Japanese" and "{ol}傭兵団ショップ" or "{ol}Mercenary Shop"
        btn:SetEventScript(ui.LBUTTONUP, "MINIMIZED_PVPMINE_SHOP_BUTTON_CLICK")
    elseif key_name == "market" and g.get_map_type() == "City" then
        btn = frame:CreateOrGetControl("button", "market", x, 6, 29, 29)
        btn:SetText("{img market_shortcut_btn02 29 29}")
        tooltip_msg = g.lang == "Japanese" and "{ol}マーケット" or "{ol}Market"
        btn:SetEventScript(ui.LBUTTONUP, "MINIMIZED_MARKET_BUTTON_CLICK")
    elseif key_name == "craft" and g.get_map_type() == "City" then
        btn = frame:CreateOrGetControl("button", "craft", x, 5, 29, 29)
        btn:SetText("{img icon_fullscreen_menu_equipment_processing 28 28}")
        tooltip_msg = g.lang == "Japanese" and "{ol}装備加工" or "{ol}Equipment Processing"
        btn:SetEventScript(ui.LBUTTONUP, "FULLSCREEN_NAVIGATION_MENU_DEATIL_EQUIPMENT_PROCESSING_NPC")
    elseif key_name == "leticia" and g.get_map_type() == "City" then
        btn = frame:CreateOrGetControl("button", "leticia", x, 5, 29, 29)
        btn:SetText("{img icon_fullscreen_menu_letica 28 28}")
        tooltip_msg = g.lang == "Japanese" and "{ol}レティーシャへ移動" or "{ol}Leticia Move"
        btn:SetEventScript(ui.LBUTTONUP, "indun_panel_FULLSCREEN_NAVIGATION_MENU_DETAIL_MOVE_NPC")
        btn:SetEventScriptArgNumber(ui.LBUTTONUP, 309)
    end
    if btn then
        AUTO_CAST(btn)
        btn:SetSkinName("None")
        btn:SetTextTooltip(tooltip_msg)
        btn:SetEventScript(ui.LBUTTONDOWN, "INDUN_PANEL_EARTHTOWERSHOP_CLOSE_RESTART")
        return true -- ボタンが作成された
    end
    return false -- ボタンが作成されなかった
end

-- 修正: 折りたたみ時のUI構築
function indun_panel_frame_init()
    local map = ui.GetFrame(addon_name_lower .. "map")
    if map then
        ui.DestroyFrame(addon_name_lower .. "map")
    end
    local frame = ui.GetFrame("indun_panel")
    frame:SetSkinName('None')
    frame:SetLayerLevel(30)
    frame:RemoveAllChild()
    indun_panel_setup_frame(frame)
    local button = frame:CreateOrGetControl("button", "indun_panel_open", 5, 5, 80, 30)
    AUTO_CAST(button)
    button:SetText("{ol}{s10}INDUNPANEL")
    button:SetEventScript(ui.LBUTTONUP, "indun_panel_frame_open")
    button:SetEventScript(ui.RBUTTONUP, "indun_panel_always_init")
    button:SetEventScriptArgString(ui.RBUTTONUP, "OPEN")
    button:SetTextTooltip(g.lang == "Japanese" and "{ol}右クリック: 常時展開で開く" or
                              "{ol}Right click: Open in Always Expand")

    local x = indun_panel_create_common_buttons(frame)
    local temp_tbl =
        {"tos", "gabija", "vakarine", "rada", "jurate", "austeja", "pvp_mine", "market", "craft", "leticia"}
    if not g.settings.cols then
        g.settings.cols = {}
        for _, key_name in ipairs(temp_tbl) do
            g.settings.cols[key_name] = (key_name == "leticia") and 1 or 0
        end
        g.save_settings()
    else
        for _, key_name in ipairs(temp_tbl) do
            if g.settings.cols[key_name] == nil then
                g.settings.cols[key_name] = 0
            end
        end
    end
    for _, key_name in ipairs(temp_tbl) do
        if g.settings.cols[key_name] == 1 then
            if indun_panel_create_shortcut_button(frame, key_name, x) then
                x = x + 30
            end
        end
    end
    frame:Resize(x, 40)
    frame:ShowWindow(1)
end

-- 修正: 展開時のUI構築
function indun_panel_frame_open()
    local frame = ui.GetFrame("indun_panel")
    frame:RemoveAllChild()
    indun_panel_setup_frame(frame)
    local button = frame:CreateOrGetControl("button", "indun_panel_open", 5, 5, 80, 30)
    AUTO_CAST(button)
    button:SetText("{ol}{s10}INDUNPANEL")
    button:SetEventScript(ui.LBUTTONUP, "indun_panel_frame_init")
    button:SetEventScript(ui.RBUTTONUP, "indun_panel_always_init")
    button:SetTextTooltip(g.lang == "Japanese" and "{ol}右クリック: 常時展開解除で閉じる" or
                              "{ol}Right click: Close with permanent unexpand")

    local x = indun_panel_create_common_buttons(frame)
    local configbtn = frame:CreateOrGetControl('button', 'configbtn', x, 5, 30, 30)
    AUTO_CAST(configbtn)
    configbtn:SetSkinName("None")
    configbtn:SetText("{img config_button_normal 30 30}")
    configbtn:SetEventScript(ui.LBUTTONUP, "indun_panel_config_gb_open")
    configbtn:SetTextTooltip(g.lang == "Japanese" and "{ol}Indun Panel 設定" or "{ol}Indun Panel Config")
    x = x + 30
    local button_keys = {"tos", "gabija", "vakarine", "rada", "jurate", "austeja", "pvp_mine", "market", "craft",
                         "leticia"}
    for _, key_name in ipairs(button_keys) do
        if indun_panel_create_shortcut_button(frame, key_name, x) then
            x = x + 30
        end
    end
    if not g.settings.set_names then
        g.settings.set_names = {}
    end
    local set_buttons = {{
        name = "set_a",
        default_text = "SET A"
    }, {
        name = "set_b",
        default_text = "SET B"
    }, {
        name = "set_c",
        default_text = "SET C"
    }}
    local current_x = x + 10 -- SET A の開始位置
    for _, btn_info in ipairs(set_buttons) do
        local btn = frame:CreateOrGetControl("button", btn_info.name, current_x, 5, 80, 30)
        AUTO_CAST(btn)
        local text = g.settings.set_names[btn_info.name] or btn_info.default_text
        btn:Resize(80, 30)
        btn:SetText("{ol}" .. text)
        btn:Resize(80, 30)
        btn:AdjustFontSizeByWidth(80)
        btn:SetEventScript(ui.LBUTTONUP, "indun_panel_set_toggle")
        btn:SetEventScriptArgString(ui.LBUTTONUP, btn:GetName())
        if g.settings.use_set == btn_info.name then
            btn:SetSkinName("test_red_button")
        end
        current_x = current_x + 85
    end
    local checkbox = frame:CreateOrGetControl('checkbox', 'checkbox', current_x, 5, 30, 30)
    AUTO_CAST(checkbox)
    checkbox:SetCheck(g.settings.checkbox)
    checkbox:SetEventScript(ui.LBUTTONUP, "indun_panel_ischecked")
    checkbox:SetTextTooltip(g.lang == "Japanese" and "{ol}チェックすると常時展開" or "{ol}IsCheck AlwaysOpen")
    if g.settings.season_checkbox == nil then
        g.settings.season_checkbox = 1
        g.save_settings()
    end
    local function indun_panel_FIELD_BOSS_TIME_TAB_SETTING()
        local induninfo_frame = ui.GetFrame("induninfo")
        if not induninfo_frame then
            return
        end
        local field_boss_ranking_control = GET_CHILD_RECURSIVELY(induninfo_frame, "field_boss_ranking_control")
        if not field_boss_ranking_control then
            return
        end
        local sub_tab = GET_CHILD_RECURSIVELY(field_boss_ranking_control, "sub_tab")
        if not sub_tab then
            return
        end
        local server_time_str = date_time.get_lua_now_datetime_str()
        if not server_time_str then
            return
        end
        local _, _, _, hour_str, min_str, _ = server_time_str:match("(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)")
        if not hour_str then
            return
        end
        local server_hour = tonumber(hour_str)
        local server_min = tonumber(min_str)
        if (server_hour < 12) or (server_hour == 12 and server_min < 5) then
            sub_tab:SelectTab(0)
        else
            sub_tab:SelectTab(1)
        end
    end
    if g.settings.jsr_checkbox == 1 then
        indun_panel_FIELD_BOSS_TIME_TAB_SETTING()
    end
    local final_x = current_x + 30
    frame:Resize(final_x, 40)
    frame:ShowWindow(1)
    g.update_try = 0
    g.housing_call_time = nil
    indun_panel_frame_contents(frame)
    configbtn:RunUpdateScript("indun_panel_frame_contents", 1.0)
end

function indun_panel_frame_save(frame, ctrl, set_name, num)
    if not g.settings[set_name] then
        g.settings[set_name] = {}
    end
    if g.settings.use_set == "None" then
        for key, value in pairs(g.settings) do
            if string.match(key, "_checkbox$") then
                g.settings[set_name][key] = value
            end
        end
    end
    g.settings.use_set = set_name
    g.save_settings()
    indun_panel_config_gb_open("", "", "", "")
end

function indun_panel_frame_skin_select(frame, ctrl, str, num)
    local context = ui.CreateContextMenu("indun_panel_skin_select", "{ol}Skin Select", 0, 0, 0, 0)
    ui.AddContextMenuItem(context, " ")
    local skin_tbl = {"chat_window_2", "bg", "bg2"}
    for _, skin_name in ipairs(skin_tbl) do
        local str_scp
        str_scp = string.format("indun_panel_frame_skin_select_('%s')", skin_name)
        local text
        if skin_name == "chat_window_2" then
            text = g.lang == "Japanese" and "{ol}いつもの" or "The usual"
        elseif skin_name == "bg" then
            text = g.lang == "Japanese" and "{ol}黒" or "Solid black"
        elseif skin_name == "bg2" then
            text = g.lang == "Japanese" and "{ol}透明度高め" or "High transparency"
        end
        ui.AddContextMenuItem(context, text, str_scp)
    end
    ui.OpenContextMenu(context)
end

function indun_panel_frame_skin_select_(skin_name)
    g.settings.skin_name = skin_name
    g.save_settings()
    indun_panel_frame_open()
end

function indun_panel_config_gb_open(frame, ctrl, argStr, argNum)
    local frame = ui.GetFrame("indun_panel")
    frame:SetSkinName("test_frame_low")
    frame:SetLayerLevel(90)
    frame:EnableHittestFrame(1)
    frame:SetAlpha(100)
    frame:RemoveAllChild()
    frame:ShowWindow(1)
    local closeBtn = frame:CreateOrGetControl('button', 'closeBtn', 0, 0, 30, 30)
    AUTO_CAST(closeBtn)
    closeBtn:SetImage("testclose_button")
    closeBtn:SetGravity(ui.RIGHT, ui.TOP)
    closeBtn:SetEventScript(ui.LBUTTONUP, "indun_panel_frame_init")
    local button = frame:CreateOrGetControl("button", "indun_panel_open", 5, 5, 80, 30)
    AUTO_CAST(button)
    button:SetText("{ol}{s10}INDUNPANEL")
    button:SetEventScript(ui.LBUTTONUP, "indun_panel_frame_init")
    local position = frame:CreateOrGetControl("button", "position", 90, 5, 60, 30)
    AUTO_CAST(position)
    position:SetText("{ol}{s10}BASE POS")
    position:SetEventScript(ui.LBUTTONUP, "indun_panel_frame_base_position")
    -- SET A, B, C ボタンの作成をループ処理に
    local tool_text = g.lang == "Japanese" and "{ol}右クリック: セット名変更" or
                          "{ol}Right-click: Rename Set"
    local set_buttons = {{
        name = "set_a",
        default = "SET A",
        x = 200
    }, {
        name = "set_b",
        default = "SET B",
        x = 285
    }, {
        name = "set_c",
        default = "SET C",
        x = 370
    }}
    for _, btn_info in ipairs(set_buttons) do
        local btn = frame:CreateOrGetControl("button", btn_info.name, btn_info.x, 5, 80, 30)
        AUTO_CAST(btn)
        local text = g.settings.set_names[btn_info.name] or btn_info.default
        btn:Resize(80, 30)
        btn:SetText("{ol}" .. text)
        btn:Resize(80, 30)
        btn:AdjustFontSizeByWidth(80)
        btn:SetEventScript(ui.LBUTTONUP, "indun_panel_frame_save")
        btn:SetEventScriptArgString(ui.LBUTTONUP, btn:GetName())
        btn:SetEventScript(ui.RBUTTONUP, "indun_panel_INPUT_STRING_BOX")
        btn:SetEventScriptArgString(ui.RBUTTONUP, btn:GetName())
        if g.settings.use_set == btn_info.name then
            btn:SetSkinName("test_red_button")
        end
        btn:SetTextTooltip(tool_text)
    end
    local skin_change = frame:CreateOrGetControl("button", "skin_change", 470, 5, 80, 30)
    AUTO_CAST(skin_change)
    local skin_text = g.lang == "Japanese" and "{ol}フレームスキン選択" or "{ol}Select Frame Skin"
    skin_change:SetEventScript(ui.LBUTTONUP, "indun_panel_frame_skin_select")
    skin_change:SetText("{ol}SKIN SELECT")
    skin_change:SetTextTooltip(skin_text)
    -- ショートカットアイコンのチェックボックス作成をループ処理に
    local shortcut_icons = {{
        name = "tos",
        img = "icon_item_Tos_Event_Coin",
        size = 25
    }, {
        name = "gabija",
        img = "goddess_shop_btn",
        size = 29
    }, {
        name = "vakarine",
        img = "goddess2_shop_btn",
        size = 29
    }, {
        name = "rada",
        img = "goddess3_shop_btn",
        size = 29
    }, {
        name = "jurate",
        img = "goddess4_shop_btn",
        size = 29
    }, {
        name = "austeja",
        img = "goddess5_shop_btn",
        size = 29
    }, {
        name = "pvp_mine",
        img = "pvpmine_shop_btn_total",
        size = 29
    }, {
        name = "market",
        img = "market_shortcut_btn02",
        size = 29
    }, {
        name = "craft",
        img = "icon_fullscreen_menu_equipment_processing",
        size = 28
    }, {
        name = "leticia",
        img = "icon_fullscreen_menu_letica",
        size = 28
    }}
    local config_x = 15
    local tooltip_always_show = g.lang == "Japanese" and "{ol}チェックすると常に表示" or
                                    "{ol}Always visible when checked"
    for _, icon_info in ipairs(shortcut_icons) do
        local checkbox = frame:CreateOrGetControl("checkbox", icon_info.name, config_x, 47, icon_info.size,
            icon_info.size)
        AUTO_CAST(checkbox)
        checkbox:SetText(string.format("{img %s %d %d}", icon_info.img, icon_info.size, icon_info.size))
        checkbox:SetEventScript(ui.LBUTTONUP, "indun_panel_ischecked")
        checkbox:SetEventScriptArgString(ui.LBUTTONUP, "config")
        checkbox:SetTextTooltip(tooltip_always_show)
        checkbox:SetCheck(g.settings.cols[icon_info.name])
        config_x = config_x + checkbox:GetWidth() + 5
    end
    local label_line2 = frame:CreateControl('labelline', 'label_line2', 10, 77, config_x, 5)
    AUTO_CAST(label_line2)
    label_line2:SetSkinName("labelline2")
    -- その他の設定チェックボックス作成をループ処理に
    local other_settings = {{
        name = "en_ver",
        y = 85,
        jp = "チェックすると英語表示に変更します",
        en = "Check to display to English"
    }, {
        name = "move",
        y = 120,
        jp = "チェックするとフレームを動かせます",
        en = "Check to move the frame"
    }, {
        name = "field_mode",
        y = 155,
        jp = "チェックするとフィールドで表示",
        en = "Check to display in field"
    }, {
        name = "shading",
        y = 190,
        jp = "チェックすると網掛け表示",
        en = "Check to display shading"
    }}
    local settings_changed = false
    for _, setting_info in ipairs(other_settings) do
        local checkbox = frame:CreateOrGetControl('checkbox', setting_info.name, 25, setting_info.y, 25, 25)
        AUTO_CAST(checkbox)
        if g.settings[setting_info.name] == nil then
            g.settings[setting_info.name] = 0
            settings_changed = true
        end
        checkbox:SetCheck(g.settings[setting_info.name])
        checkbox:SetEventScript(ui.LBUTTONUP, "indun_panel_ischecked")
        checkbox:SetText(g.lang == "Japanese" and "{ol}" .. setting_info.jp or "{ol}" .. setting_info.en)
    end
    if settings_changed then
        g.save_settings()
    end
    local label_line = frame:CreateControl('labelline', 'label_line', 10, 215, config_x, 5)
    AUTO_CAST(label_line)
    label_line:SetSkinName("labelline2")
    local posY_left = 220
    local posY_right = 220
    local count = #induntype
    local half_count = math.ceil(count / 2)
    local use_tbl = g.settings[g.settings.use_set] ~= "None" and g.settings[g.settings.use_set] or g.settings
    for i = 1, count do
        local entry = induntype[i]
        for key, value in pairs(entry) do
            local checkbox
            if i <= half_count then
                checkbox = frame:CreateOrGetControl('checkbox', key .. '_checkbox', 15, posY_left, 25, 25)
                AUTO_CAST(checkbox)
                posY_left = posY_left + 35
            else
                checkbox = frame:CreateOrGetControl('checkbox', key .. '_checkbox', 325, posY_right, 25, 25)
                AUTO_CAST(checkbox)
                posY_right = posY_right + 35
            end
            checkbox:SetCheck(use_tbl[key .. '_checkbox'])
            checkbox:SetEventScript(ui.LBUTTONUP, "indun_panel_ischecked")
            checkbox:SetText("{ol}{#FFFFFF}" .. INDUN_PANEL_LANG(convert_tbl[key] or key))
            checkbox:SetTextTooltip(g.lang == "Japanese" and "チェックすると表示" or "Check to show")
        end
    end
    local final_height = math.max(posY_left, posY_right)
    frame:Resize(660, final_height + 5)
end

function indun_panel_event_tos_whole_shop_open()
    local frame = ui.GetFrame("earthtowershop");
    frame:SetUserValue("SHOP_TYPE", 'EVENT_TOS_WHOLE_SHOP');
    ui.OpenFrame('earthtowershop');
end

function indun_panel_set_toggle(frame, ctrl, set_name, num)
    if not g.settings[set_name] and g.settings[set_name] == "None" then
        local msg = g.lang == "Japanese" and "セットの設定をしてください" or "Please configure the set"
        ui.Sysmsg(msg)
        return
    end
    g.settings.use_set = set_name
    g.save_settings()
    indun_panel_frame_open(frame)
end

function indun_panel_get_entrance_count(indun_type, index)
    local return_str = ""
    if index == 2 then
        local current_count_str = "?"
        local max_count_str = "?"
        local indun_cls = GetClassByType("Indun", indun_type)
        if indun_cls and indun_cls.PlayPerResetType then
            local current_count = GET_CURRENT_ENTERANCE_COUNT(indun_cls.PlayPerResetType)
            local max_count = GET_INDUN_MAX_ENTERANCE_COUNT(indun_cls.PlayPerResetType)
            if current_count ~= nil and max_count ~= nil then
                current_count_str = tostring(current_count)
                max_count_str = tostring(max_count)
            end
        end
        return_str = string.format("{ol}{#FFFFFF}{s16}(%s/%s)", current_count_str, max_count_str)
    elseif index == 1 then
        local current_count_str = "?"
        local indun_cls = GetClassByType("Indun", indun_type)
        if indun_cls and indun_cls.PlayPerResetType then
            local current_count = GET_CURRENT_ENTERANCE_COUNT(indun_cls.PlayPerResetType)
            if current_count ~= nil then
                current_count_str = tostring(current_count)
            end
        end
        return_str = string.format("{ol}{#FFFFFF}{s16}(%s)", current_count_str)
    elseif index == 3 then
        local etc = GetMyEtcObject();
        local cls = GetClassByType("Indun", indun_type)
        local class_name = TryGetProp(cls, 'ClassName', 'None')
        local count = 1
        if cls ~= nil and string.find(class_name, 'Challenge_') ~= nil then
            local UnitPerReset = TryGetProp(cls, 'UnitPerReset', 'None')
            if UnitPerReset ~= 'None' then

                local ticket_type = TryGetProp(cls, 'TicketingType', 'None')
                if ticket_type == 'Entrance_Ticket' then
                    local name = TryGetProp(cls, 'CheckCountName', 'None')
                    if TryGetProp(etc, name, 0) == 1 then
                        count = 0
                    end
                end
            end
        end
        local max_count_str = "?"
        local indun_cls = GetClassByType("Indun", indun_type)
        if indun_cls and indun_cls.PlayPerResetType then
            local max_count = GET_INDUN_MAX_ENTERANCE_COUNT(indun_cls.PlayPerResetType)
            if max_count ~= nil then
                max_count_str = tostring(max_count)
            end
        end
        return_str = string.format("{ol}{#FFFFFF}{s16}(%s/%s)", count, max_count_str)
    elseif index == 4 then
        local indun_cls = GetClassByType("Indun", indun_type)
        if not indun_cls then
            return ""
        end
        if indun_type == 1001 then

            if indun_cls.PlayPerResetType then
                local current_count = GET_CURRENT_ENTERANCE_COUNT(indun_cls.PlayPerResetType)
                return tostring(current_count or "")
            end
        elseif indun_type == 1004 or indun_type == 1005 or indun_type == 2000 or indun_type == 2001 then
            local class_name = TryGetProp(indun_cls, 'ClassName', 'None')
            if string.find(class_name, 'Challenge_') then
                local unit_per_reset = TryGetProp(indun_cls, 'UnitPerReset', 'None')
                if unit_per_reset ~= 'None' then
                    local name = TryGetProp(indun_cls, 'CheckCountName', 'None')
                    if name == 'None' then
                        return ""
                    end
                    if unit_per_reset == 'ACCOUNT' then
                        local acc_obj = GetMyAccountObj()
                        return TryGetProp(acc_obj, name, 0)
                    elseif unit_per_reset == 'PC' then
                        local etc_obj = GetMyEtcObject()
                        return TryGetProp(etc_obj, name, 0)
                    end
                end
            end
        end
        return ""
    end
    return return_str
end

function indun_panel_item_use(frame, ctrl, str, indun_type)
    g.update_try = 0
    -- 墓地
    session.ResetItemList()
    local invItemList = session.GetInvItemList()
    if indun_type == 684 then
        local ticket_table = {11200276, 11200275, 11200274}
        for _, classid in ipairs(ticket_table) do
            local use_item = session.GetInvItemByType(classid)
            if use_item then
                INV_ICON_USE(use_item)
                return
            end
        end
    elseif indun_type == 728 then
        local ticket_table = {11200486, 11200485, 11200484}
        for _, classid in ipairs(ticket_table) do
            local use_item = session.GetInvItemByType(classid)
            if use_item then
                INV_ICON_USE(use_item)
                return
            end
        end
    end
end

function indun_panel_enter_singularity(frame, ctrl, str, indun_type)
    ReqChallengeAutoUIOpen(indun_type)
    local indunCls = GetClassByType('Indun', indun_type);
    local indunMinPCRank = TryGetProp(indunCls, 'PCRank')
    local totaljobcount = session.GetPcTotalJobGrade()
    if indunMinPCRank ~= nil then
        if indunMinPCRank > totaljobcount and indunMinPCRank ~= totaljobcount then
            ui.SysMsg(ScpArgMsg('IndunEnterNeedPCRank', 'NEED_RANK', indunMinPCRank))
            return;
        end
    end
    if g.settings.singularity_check == 0 then
        ReserveScript(string.format("ReqMoveToIndun(%d,%d)", 2, 0), 0.3)
    end
end

function indun_panel_item_use_and_run(item_to_use, indun_type)
    if not item_to_use then
        return
    end
    INV_ICON_USE(item_to_use)
    local script_to_run = string.format("indun_panel_enter_singularity('%s', '%s', '%s', %d)", '', '', '', indun_type)
    ReserveScript(script_to_run, 1.0)
end

function indun_panel_item_use_sin(frame, ctrl, enterance_count, indun_type)
    enterance_count = tonumber(enterance_count)
    if enterance_count > 0 then
        return
    end
    g.update_try = 0
    local expiring_tickets = {}
    local non_expiring_tickets = {}
    if indun_type == 2000 then
        -- 期限ありリスト
        expiring_tickets = {{
            classid = 10820018,
            is_urgent = true
        }, -- 期限が近い
        {
            classid = 11030067,
            is_urgent = true
        }, {
            classid = 10820018,
            is_urgent = false
        }, -- 期限に余裕あり
        {
            classid = 11030067,
            is_urgent = false
        }}
        -- 期限なしリスト
        non_expiring_tickets = {{
            classid = 10000470
        }, {
            classid = 11030021
        }, {
            classid = 11030017
        }}
    elseif indun_type == 2001 then
        -- 期限ありリスト
        expiring_tickets = {{
            classid = 11201303,
            is_urgent = true
        }, {
            classid = 11201304,
            is_urgent = false
        }}
        -- 期限なしリスト
        non_expiring_tickets = {{
            classid = 11201302
        }, {
            classid = 11201301
        }}
    end
    for _, ticket_info in ipairs(expiring_tickets) do
        local use_item = session.GetInvItemByType(ticket_info.classid)
        if use_item then
            local life_time = tonumber(GET_REMAIN_ITEM_LIFE_TIME(GetIES(use_item:GetObject())))
            if life_time then
                if ticket_info.is_urgent and life_time < 86400 then -- 期限が1日未満なら使用
                    indun_panel_item_use_and_run(use_item, indun_type)
                    return
                elseif not ticket_info.is_urgent then -- 期限に余裕があっても使用
                    indun_panel_item_use_and_run(use_item, indun_type)
                    return
                end
            end
        end
    end
    if indun_type == 2000 then
        if INDUN_PANEL_GET_RECIPE_TRADE_COUNT("EVENT_TOS_WHOLE_SHOP_314") >= 1 then
            INDUN_PANEL_ITEM_BUY_USE("EVENT_TOS_WHOLE_SHOP_314", indun_type)
            return
        end
    elseif indun_type == 2001 then
        if INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_41") >= 1 then
            INDUN_PANEL_ITEM_BUY_USE("PVP_MINE_41", indun_type)
            return
        end
        if INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_42") >= 1 then
            INDUN_PANEL_ITEM_BUY_USE("PVP_MINE_42", indun_type)
            return
        end
    end
    for _, ticket_info in ipairs(non_expiring_tickets) do
        local use_item = session.GetInvItemByType(ticket_info.classid)
        if use_item then
            if use_item.isLockState then
                ui.SysMsg(ClMsg("MaterialItemIsLock") .. " (" .. use_item.Name .. ")")
            else
                indun_panel_item_use_and_run(use_item, indun_type)
                return
            end
        end
    end
end

function indun_panel_singularity_frame(frame, key, y, value, x)
    local btn_520 = frame:CreateOrGetControl('button', "btn_520", x, y, 60, 30)
    AUTO_CAST(btn_520)
    btn_520:SetText("{ol}{#FFD900}520")
    btn_520:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_singularity")
    btn_520:SetEventScriptArgNumber(ui.LBUTTONUP, value.singularity_520)
    local count_520 = frame:CreateOrGetControl("richtext", "count_520", x + 65, y + 5, 30, 30)
    count_520:SetText("{ol}(" .. indun_panel_get_entrance_count(value.singularity_520, 4) .. ")")
    local ticket_520 = frame:CreateOrGetControl('button', key .. 'ticket_520', x + 95, y, 80, 30)
    AUTO_CAST(ticket_520)
    ticket_520:SetText("{img icon_item_Tos_Event_Coin 13 13}{ol}{#EE7800}{s14}BUYUSE")
    local tooltip = g.lang == "Japanese" and
                        "{ol}優先順位{nl}1.24時間以内の期限付きチケット{nl}2.期限付きチケット{nl}" ..
                        "3.{img icon_item_Tos_Event_Coin 20 20}チケット(買って使います){nl}4.期限の無いチケット" or
                        "{ol}Priority{nl}1.Limited-time tickets (under 24 hours){nl}2.Limited-time tickets{nl}" ..
                        "3.{img icon_item_Tos_Event_Coin 20 20}tickets(buy and use){nl}4.Tickets without an expiration date"
    ticket_520:SetTextTooltip(tooltip)
    ticket_520:SetEventScript(ui.LBUTTONUP, "indun_panel_item_use_sin")
    ticket_520:SetEventScriptArgNumber(ui.LBUTTONUP, value.singularity_520)
    local enterance_count = indun_panel_get_entrance_count(value.singularity_520, 4)
    ticket_520:SetEventScriptArgString(ui.LBUTTONUP, enterance_count)
    local buy_count_520 = frame:CreateOrGetControl("richtext", key .. "buy_count_520", x + 185, y + 5, 40, 30)
    buy_count_520:SetText("{ol}{s16}({img icon_item_Tos_Event_Coin 15 15}" ..
                              INDUN_PANEL_GET_RECIPE_TRADE_COUNT("EVENT_TOS_WHOLE_SHOP_314") .. ")")

    local btn_540 = frame:CreateOrGetControl('button', "btn_540", x + 245, y, 60, 30)
    AUTO_CAST(btn_540)
    btn_540:SetText("{ol}{#FFD900}540")
    btn_540:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_singularity")
    btn_540:SetEventScriptArgNumber(ui.LBUTTONUP, value.singularity_540)
    local count_540 = frame:CreateOrGetControl("richtext", "count_540", x + 310, y + 5, 30, 30)
    count_540:SetText("{ol}(" .. indun_panel_get_entrance_count(value.singularity_540, 4) .. ")")
    local ticket_540 = frame:CreateOrGetControl('button', key .. 'ticket_540', x + 345, y, 80, 30)
    AUTO_CAST(ticket_540)
    ticket_540:SetText("{img pvpmine_shop_btn_total 15 15}{ol}{#EE7800}{s14}BUYUSE")
    local tooltip = g.lang == "Japanese" and
                        "{ol}優先順位{nl}1.24時間以内の期限付きチケット{nl}2.期限付きチケット{nl}" ..
                        "3.{img pvpmine_shop_btn_total 20 20}チケット(買って使います){nl}4.期限の無いチケット" or
                        "{ol}Priority{nl}1.Limited-time tickets (under 24 hours){nl}2.Limited-time tickets{nl}" ..
                        "3.{img pvpmine_shop_btn_total 20 20}tickets(buy and use){nl}4.Tickets without an expiration date"
    ticket_540:SetTextTooltip(tooltip)
    ticket_540:SetEventScript(ui.LBUTTONUP, "indun_panel_item_use_sin")
    ticket_540:SetEventScriptArgNumber(ui.LBUTTONUP, value.singularity_540)
    local enterance_count = indun_panel_get_entrance_count(value.singularity_540, 4)
    ticket_540:SetEventScriptArgString(ui.LBUTTONUP, enterance_count)
    local buy_count_540 = frame:CreateOrGetControl("richtext", key .. "buy_count_540", x + 440, y + 5, 40, 30)
    buy_count_540:SetText("{ol}{#FFFFFF}{s16}({img pvpmine_shop_btn_total 18 18}d:" ..
                              INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_41") .. " w:" ..
                              INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_42") .. ")")

    local auto_check = frame:CreateOrGetControl("checkbox", key .. "auto_check", x + 540, y, 25, 25)
    AUTO_CAST(auto_check)
    auto_check:SetEventScript(ui.LBUTTONUP, "indun_panel_ischecked")
    auto_check:SetTextTooltip(g.lang == "Japanese" and
                                  "{ol}チェックをすると自動マッチングボタンを押しません。" or
                                  "{ol}If checked, the automatic matching button will not be pressed.")
    auto_check:SetCheck(g.settings.singularity_check)
end

function indun_panel_enter_reserve(index, indun_type)
    AnsGiveUpPrevPlayingIndun(1)
    ReserveScript(string.format("indun_panel_enter_challenge('%s','%s','%d', %d)", "", "", index, indun_type), 2.0)
    return
end

function indun_panel_enter_challenge(frame, ctrl, index, indun_type)
    index = tonumber(index)
    ReqChallengeAutoUIOpen(indun_type)
    ReserveScript(string.format("ReqMoveToIndun(%d,%d)", index, 0), 0.3)
    return
end

function indun_panel_challenge_item_use(indun_panel, ctrl, str, indun_type)
    g.update_try = 0
    if indun_type == 1001 then
        local enterance_count = indun_panel_get_entrance_count(indun_type, 4)
        if tonumber(enterance_count) == 1 then
            indun_panel_challenge_low(indun_type)
        end
    elseif indun_type == 1005 or indun_type == 1004 then
        local enterance_count = indun_panel_get_entrance_count(indun_type, 4)
        if tonumber(enterance_count) == 0 then
            indun_panel_challenge_high(indun_type, str)
        end
    end
end

function indun_panel_challenge_low(indun_type)
    local expiring_tickets = {10820019, 11030080, 641954, 641955, 641969}
    local non_expiring_tickets = {10000073, 10820028, 490363, 641953, 641963, 641987}
    if indun_panel_use_prioritized_ticket(expiring_tickets, 1, indun_type) then
        return
    end
    if INDUN_PANEL_GET_RECIPE_TRADE_COUNT("EVENT_TOS_WHOLE_SHOP_315") >= 1 then
        INDUN_PANEL_ITEM_BUY_USE("EVENT_TOS_WHOLE_SHOP_315", indun_type)
        indun_panel_enter_reserve(1, indun_type)
        return
    end
    if indun_panel_use_simple_ticket(non_expiring_tickets, 1, indun_type) then
        return
    end
end

function indun_panel_challenge_high(indun_type, str)
    local expiring_tickets = {11201299, 11201300}
    local non_expiring_tickets = {11201298, 11201297}
    local enter_mode = (str == "SOLO") and 1 or 2
    if indun_panel_use_prioritized_ticket(expiring_tickets, enter_mode, indun_type) then
        return
    end
    if INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_40") >= 1 then
        INDUN_PANEL_ITEM_BUY_USE("PVP_MINE_40", indun_type)
        indun_panel_enter_reserve(enter_mode, indun_type)
        return
    end
    if indun_panel_use_simple_ticket(non_expiring_tickets, enter_mode, indun_type) then
        return
    end
    local account_obj = GetMyAccountObj()
    local recipe_cls = GetClass('ItemTradeShop', "PVP_MINE_40")
    local over_max = TryGetProp(recipe_cls, 'MaxOverBuyCount', 0)
    local over_prop = TryGetProp(recipe_cls, 'OverBuyProperty', 'None')
    local over_count = TryGetProp(account_obj, over_prop, 0)
    if (tonumber(over_max) - tonumber(over_count)) > 0 then
        INDUN_PANEL_ITEM_BUY_USE("PVP_MINE_40", indun_type)
        indun_panel_enter_reserve(enter_mode, indun_type)
        return
    end
end

function indun_panel_use_prioritized_ticket(ticket_ids, enter_mode, indun_type)
    local candidate_tickets = {}
    for _, classid in ipairs(ticket_ids) do
        local use_item = session.GetInvItemByType(classid)
        if use_item then
            local life_time = tonumber(GET_REMAIN_ITEM_LIFE_TIME(GetIES(use_item:GetObject())))
            table.insert(candidate_tickets, {
                u_item = use_item,
                priority = (life_time and life_time < 86400) and 1 or 2
            })
        end
    end
    if #candidate_tickets > 0 then
        table.sort(candidate_tickets, function(a, b)
            return a.priority < b.priority
        end)
        INV_ICON_USE(candidate_tickets[1].u_item)
        indun_panel_enter_reserve(enter_mode, indun_type)
        return true
    end
    return false
end

function indun_panel_use_simple_ticket(ticket_ids, enter_mode, indun_type)
    for _, classid in ipairs(ticket_ids) do
        local use_item = session.GetInvItemByType(classid)
        if use_item then
            if use_item.isLockState then
                ui.SysMsg(ClMsg("MaterialItemIsLock") .. " (" .. use_item.Name .. ")")
            else
                INV_ICON_USE(use_item)
                indun_panel_enter_reserve(enter_mode, indun_type)
                return true
            end
        end
    end
    return false
end

function indun_panel_challenge_frame(indun_panel, key, y, value, x)
    local solo_520 = indun_panel:CreateOrGetControl('button', key .. 'solo_520', x, y, 60, 30)
    AUTO_CAST(solo_520)
    solo_520:SetText("{ol}520")
    solo_520:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_challenge")
    solo_520:SetEventScriptArgString(ui.LBUTTONUP, "1")
    solo_520:SetEventScriptArgNumber(ui.LBUTTONUP, value.solo_520)
    local count_520 = indun_panel:CreateOrGetControl("richtext", key .. "count_520", x + 65, y + 5, 20, 30)
    count_520:SetText(indun_panel_get_entrance_count(value.solo_520, 2))
    local ticket_520 = indun_panel:CreateOrGetControl('button', 'ticket_520', x + 110, y, 80, 30)
    AUTO_CAST(ticket_520)
    ticket_520:SetText("{img icon_item_Tos_Event_Coin 13 13}{ol}{#EE7800}{s14}BUYUSE")
    ticket_520:SetEventScript(ui.LBUTTONUP, "indun_panel_challenge_item_use")
    ticket_520:SetEventScriptArgNumber(ui.LBUTTONUP, value.solo_520)
    local tooltip_text = g.lang == "Japanese" and
                             "優先順位{nl}1.24時間以内の期限付きチケット{nl}2.期限付きチケット{nl}" ..
                             "3.期限のないチケット{nl}4.{img icon_item_Tos_Event_Coin 20 20}チケット(買って使います){nl}" or
                             "Priority{nl}1.Limited-time tickets (under 24 hours){nl}" .. "2.Limited-time tickets{nl}" ..
                             "3.tickets without an expiration date{nl}" ..
                             "4.{img icon_item_Tos_Event_Coin 20 20} Tickets (buy and use these)"
    ticket_520:SetTextTooltip("{ol}" .. tooltip_text)
    local tos_shop_count = indun_panel:CreateOrGetControl("richtext", "tos_shop_count", x + 200, y + 5, 20, 30)
    tos_shop_count:SetText("{ol}{s16}({img icon_item_Tos_Event_Coin 15 15}" ..
                               INDUN_PANEL_GET_RECIPE_TRADE_COUNT("EVENT_TOS_WHOLE_SHOP_315") .. ")")

    local solo_540 = indun_panel:CreateOrGetControl('button', key .. 'solo_540', x + 260, y, 60, 30)
    AUTO_CAST(solo_540)
    solo_540:SetText("{ol}540")
    solo_540:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_challenge")
    solo_540:SetEventScriptArgString(ui.LBUTTONUP, "1")
    solo_540:SetEventScriptArgNumber(ui.LBUTTONUP, value.solo_540)
    local pt_btn = indun_panel:CreateOrGetControl('button', key .. 'pt_btn', x + 325, y, 60, 30)
    AUTO_CAST(pt_btn)
    pt_btn:SetText("{ol}{#FFD900}PT")
    pt_btn:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_challenge")
    pt_btn:SetEventScriptArgString(ui.LBUTTONUP, "2")
    pt_btn:SetEventScriptArgNumber(ui.LBUTTONUP, value.pt_540)
    local count = indun_panel:CreateOrGetControl("richtext", key .. "count", x + 390, y + 5, 40, 30)
    count:SetText(indun_panel_get_entrance_count(value.pt_540, 3))
    local ticket_540 = indun_panel:CreateOrGetControl('button', 'ticket_540', x + 435, y, 80, 30)
    AUTO_CAST(ticket_540)
    ticket_540:SetText("{img pvpmine_shop_btn_total 14 14}{ol}{#EE7800}{s14}BUYUSE")
    ticket_540:SetEventScript(ui.LBUTTONUP, "indun_panel_challenge_item_use")
    ticket_540:SetEventScriptArgNumber(ui.LBUTTONUP, value.pt_540)
    ticket_540:SetEventScript(ui.RBUTTONUP, "indun_panel_challenge_item_use")
    ticket_540:SetEventScriptArgNumber(ui.RBUTTONUP, value.solo_540)
    ticket_540:SetEventScriptArgString(ui.RBUTTONUP, "SOLO")
    local tooltip = g.lang == "Japanese" and "{ol}左クリック: PT入場{nl}右クリック: ソロ入場{nl}" ..
                        "優先順位{nl}1.24時間以内の期限付きチケット{nl}2.期限付きチケット{nl}" ..
                        "3.{img pvpmine_shop_btn_total 20 20}チケット(買って使います){nl}" ..
                        "4.期限のないチケット" or "{ol}Left-click: Enter party{nl}Right-click: Enter solo{nl}" ..
                        "Priority{nl}1.Limited-time tickets (under 24 hours){nl}" .. "2.Limited-time tickets{nl}" ..
                        "3.{img pvpmine_shop_btn_total 20 20} Tickets (buy and use these){nl}" ..
                        "4.Tickets without an expiration date{nl}"
    ticket_540:SetTextTooltip(tooltip)
    local ticket_count = indun_panel:CreateOrGetControl("richtext", key .. "ticket_count", x + 525, y + 5, 40, 30)
    local recipe_trade_count = INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_40")
    if recipe_trade_count < 0 then
        recipe_trade_count = "{ol}{#FF0000}{s16}({/}" .. "{img pvpmine_shop_btn_total 18 18}" .. "{ol}{#FF0000}{s16}" ..
                                 math.abs(recipe_trade_count) .. "){/}{/}" -- 絶対値を取得
    else
        recipe_trade_count = "{ol}{#FFFFFF}{s16}({/}" .. "{img pvpmine_shop_btn_total 18 18}" .. "{ol}{#FFFFFF}{s16}" ..
                                 math.abs(recipe_trade_count) .. "){/}{/}" -- 絶対値を取得
    end
    ticket_count:SetText(recipe_trade_count)
end

function indun_panel_autosweep(frame, ctrl, argStr, induntype)

    g.update_try = 0

    local buffID = buffIDs[induntype]
    local sweepcount = indun_panel_sweep_count(buffID)
    if sweepcount >= 1 then
        ReqUseRaidAutoSweep(induntype)
    else
        if not string.find(argStr, "use") then
            ui.SysMsg(g.lang == "Japanese" and "掃討バフがありません。" or "There is no autoclear buff.")
            return
        end
    end
end

function indun_panel_sweep_count(buffid)
    local buffframe = ui.GetFrame("buff")
    local handle = session.GetMyHandle()
    local buffslotset = GET_CHILD_RECURSIVELY(buffframe, "buffslot")
    local buffslotcount = buffslotset:GetChildCount()
    for i = 0, buffslotcount - 1 do
        local child = buffslotset:GetChildByIndex(i)
        local icon = child:GetIcon()
        local iconinfo = icon:GetInfo()
        local type = iconinfo.type
        local buff = info.GetBuff(handle, iconinfo.type)
        if type == buffid then
            return buff.over
        end
    end
    return 0
end

function indun_panel_raid_itemuse(frame, ctrl, argStr, induntype)
    g.update_try = 0
    session.ResetItemList()
    local invItemList = session.GetInvItemList()
    local guidList = invItemList:GetGuidList()
    local cnt = guidList:Count()
    local targetItems = raidTable[induntype]
    local enter_count = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", induntype).PlayPerResetType) or ""
    local buffID = buffIDs[induntype]
    local sweep_count = indun_panel_sweep_count(buffID)
    if targetItems then
        for _, targetClassID in ipairs(targetItems) do
            for i = 0, cnt - 1 do
                local itemobj = GetIES(invItemList:GetItemByGuid(guidList:Get(i)):GetObject())
                local classid = itemobj.ClassID
                if classid == targetClassID then
                    if enter_count == 2 and sweep_count >= 1 then
                        INV_ICON_USE(session.GetInvItemByType(tonumber(classid)))
                        ReserveScript(
                            string.format("indun_panel_autosweep(nil,nil,'%s',%d)", ctrl:GetName(), induntype), 0.2)
                        return
                    elseif enter_count == 2 and sweep_count == 0 then
                        INV_ICON_USE(session.GetInvItemByType(tonumber(classid)))
                        return
                    elseif enter_count <= 1 and sweep_count >= 1 then
                        ReserveScript(
                            string.format("indun_panel_autosweep(nil,nil,'%s',%d)", ctrl:GetName(), induntype), 0.2)
                        return
                    elseif enter_count == 1 and sweep_count == 0 then
                        INV_ICON_USE(session.GetInvItemByType(tonumber(classid)))
                        return
                    elseif enter_count == 0 and sweep_count == 0 then
                        return
                    end
                end
            end
        end
    end
    local msg = g.lang == "Japanese" and "(自動マッチング/1人)入場券を持っていません" or
                    "There are no ticket items in inventory"
    ui.SysMsg(msg)
end

function Indun_panel_create_frame_onsweep(frame, key, sub_key, sub_value, y, x)
    -- 1. USEボタンの作成 (raidTableに定義がある場合)
    if raidTable[sub_value] then
        local use_btn = frame:CreateOrGetControl('button', key .. "use", x + 470, y, 80, 30)
        AUTO_CAST(use_btn)
        use_btn:SetText("{ol}{#EE7800}USE")

        -- 所持数のカウント (効率化)
        local count = 0
        for _, class_id in ipairs(raidTable[sub_value]) do
            local inv_item = session.GetInvItemByType(class_id)
            if inv_item then
                count = count + inv_item.count
            end
        end

        -- ツールチップ設定
        local item_cls = GetClassByType('Item', raidTable[sub_value][2])
        if item_cls then
            local fmt = g.lang == "Japanese" and "{ol}{img %s 25 25 } %d個持っています。" or
                            "{ol}{img %s 25 25 } Quantity in Inventory: %d"
            use_btn:SetTextTooltip(string.format(fmt, item_cls.Icon, count))
        end

        use_btn:SetEventScript(ui.LBUTTONUP, "indun_panel_raid_itemuse")
        use_btn:SetEventScriptArgNumber(ui.LBUTTONUP, sub_value)
    end

    -- 2. 各種ボタン・テキストの枠作成
    -- (CreateOrGetControlなので、ループで複数回呼ばれても既存のものを取得するだけ)
    local btn_solo = frame:CreateOrGetControl('button', key .. "solo", x, y, 80, 30)
    local btn_auto = frame:CreateOrGetControl('button', key .. "auto", x + 85, y, 80, 30)
    local btn_hard = frame:CreateOrGetControl('button', key .. "hard", x + 215, y, 80, 30)
    local btn_sweep = frame:CreateOrGetControl('button', key .. "sweep", x + 350, y, 80, 30)

    local txt_count = frame:CreateOrGetControl("richtext", key .. "count", x + 170, y + 5, 50, 30)
    local txt_hard_count = frame:CreateOrGetControl("richtext", key .. "counthard", x + 300, y + 5, 50, 30)
    local txt_sweep_count = frame:CreateOrGetControl("richtext", key .. "sweepcount", x + 435, y + 5, 50, 30)

    -- 固定テキストの設定
    btn_solo:SetText("{ol}SOLO")
    btn_auto:SetText("{ol}{#FFD900}AUTO")
    btn_hard:SetText("{ol}{#FF0000}HARD")
    btn_sweep:SetText("{ol}{#00FF00}ACLEAR")

    -- 3. sub_key (モード) に応じた設定
    if sub_key == "s" then
        -- Solo
        txt_count:SetText(Indun_panel_get_entrance_count(sub_value, 2))
        btn_solo:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_solo")
        btn_solo:SetEventScriptArgNumber(ui.LBUTTONUP, sub_value)

    elseif sub_key == "a" then
        -- Auto
        btn_auto:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_auto")
        btn_auto:SetEventScriptArgNumber(ui.LBUTTONUP, sub_value)

        btn_sweep:SetEventScript(ui.LBUTTONUP, "indun_panel_autosweep")
        btn_sweep:SetEventScriptArgNumber(ui.LBUTTONUP, sub_value)

    elseif sub_key == "h" then
        -- Hard
        local ent_count = Indun_panel_get_entrance_count(sub_value, 2)
        if ent_count then
            txt_hard_count:SetText(ent_count)
            btn_hard:SetEventScript(ui.LBUTTONDOWN, "indun_panel_enter_hard")
            btn_hard:SetEventScriptArgNumber(ui.LBUTTONDOWN, sub_value)
            btn_hard:SetEventScriptArgString(ui.LBUTTONDOWN, "false")
        end

    elseif sub_key == "ac" then
        -- Auto Clear (Sweep) Count
        local count_str = Indun_panel_sweep_count(sub_value)
        txt_sweep_count:SetText(string.format("{ol}{#FFFFFF}{s16}(%s)", count_str))
    end
end

function indun_panel_create_frame(frame, key, subKey, subValue, y, x)
    local solo = frame:CreateOrGetControl('button', key .. "solo", x, y, 80, 30)
    local auto = frame:CreateOrGetControl('button', key .. "auto", x + 85, y, 80, 30)
    local hard = frame:CreateOrGetControl('button', key .. "hard", x + 215, y, 80, 30)
    local count = frame:CreateOrGetControl("richtext", key .. "count", x + 170, y + 5, 50, 30)
    local counthard = frame:CreateOrGetControl("richtext", key .. "counthard", x + 300, y + 5, 50, 30)
    solo:SetText("{ol}SOLO")
    auto:SetText(key == "earring" and "{ol}{#FFD900}NORMAL" or "{ol}{#FFD900}AUTO")
    hard:SetText("{ol}{#FF0000}HARD")
    if subKey == "s" then
        if key == "earring" then
            count:SetText(indun_panel_get_entrance_count(subValue, 1))
            solo:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_solo")
            solo:SetEventScriptArgNumber(ui.LBUTTONUP, subValue)
        else
            count:SetText(indun_panel_get_entrance_count(subValue, 2))
            solo:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_solo")
            solo:SetEventScriptArgNumber(ui.LBUTTONUP, subValue)
        end
    elseif subKey == "a" then
        auto:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_auto")
        auto:SetEventScriptArgNumber(ui.LBUTTONUP, subValue)
    elseif subKey == "h" then
        if key == "giltine" then
            counthard:SetText(indun_panel_get_entrance_count(subValue, 1))
            hard:SetEventScript(ui.LBUTTONDOWN, "indun_panel_enter_hard")
            hard:SetEventScriptArgNumber(ui.LBUTTONDOWN, subValue)
            hard:SetEventScriptArgString(ui.LBUTTONDOWN, "false")
        elseif key == "earring" then
            hard:SetEventScript(ui.LBUTTONDOWN, "indun_panel_enter_hard")
            hard:SetEventScriptArgNumber(ui.LBUTTONDOWN, subValue)
            hard:SetEventScriptArgString(ui.LBUTTONDOWN, "false")
        else
            counthard:SetText(indun_panel_get_entrance_count(subValue, 2))
            hard:SetEventScript(ui.LBUTTONDOWN, "indun_panel_enter_hard")
            hard:SetEventScriptArgNumber(ui.LBUTTONDOWN, subValue)
            hard:SetEventScriptArgString(ui.LBUTTONDOWN, "false")
        end
    end
end

function indun_panel_enter_telharsha_solo()
    ReqRaidAutoUIOpen(623)
    ReqMoveToIndun(1, 0)
end

function indun_panel_buyuse_telharsha(frame, ctrl, recipe_name, indun_type)
    g.update_try = 0
    local count = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", indun_type).PlayPerResetType) or ""
    local tosshop_ticket = 108020009
    session.ResetItemList()
    local invItemList = session.GetInvItemList()
    if count == 3 then
        local use_item = session.GetInvItemByType(tosshop_ticket)
        if use_item ~= nil then
            INV_ICON_USE(use_item)
            ReserveScript("indun_panel_enter_telharsha_solo()", 2.0)
            return
        else
            local change_count = INDUN_PANEL_GET_RECIPE_TRADE_COUNT(recipe_name)
            if change_count >= 1 then
                INDUN_PANEL_ITEM_BUY_USE(recipe_name)
                ReserveScript("indun_panel_enter_telharsha_solo()", 2.0)
                return
            else
                ui.SysMsg(g.lang == "Japanese" and "トレード回数が足りません。" or "No trade count.")
                return
            end
        end
    else
        ReserveScript("indun_panel_enter_telharsha_solo()", 1.0)
        return
    end
end

function indun_panel_telharsha_frame(frame, key, value, y, x)
    local btn = frame:CreateOrGetControl('button', key .. 'btn', x, y, 80, 30)
    btn:SetText("{ol}IN")
    btn:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_solo")
    btn:SetEventScriptArgNumber(ui.LBUTTONUP, value)
    local count = frame:CreateOrGetControl("richtext", key .. "count", x + 85, y + 5)
    count:SetText(indun_panel_get_entrance_count(value, 2))
    local recipe_name = "EVENT_TOS_WHOLE_SHOP_306"
    local change_count = INDUN_PANEL_GET_RECIPE_TRADE_COUNT(recipe_name)
    local tos_shop_count = frame:CreateOrGetControl("richtext", key .. "tos_shop_count", x + 215, y + 5, 20, 30)
    tos_shop_count:SetText("{ol}{s16}({img icon_item_Tos_Event_Coin 15 15}" .. change_count .. ")")
    local ticket_btn = frame:CreateOrGetControl('button', key .. 'ticket_btn', x + 130, y, 80, 30)
    AUTO_CAST(ticket_btn)
    ticket_btn:SetText("{ol}{#EE7800}{s14}BUYUSE")
    ticket_btn:SetEventScript(ui.LBUTTONUP, "indun_panel_buyuse_telharsha")
    ticket_btn:SetEventScriptArgString(ui.LBUTTONUP, recipe_name)
    ticket_btn:SetEventScriptArgNumber(ui.LBUTTONUP, value)
end

function indun_panel_enter_velnice_solo()
    local indun_cls_id = 201
    local indun_cls = GetClassByType("Indun", indun_cls_id)
    if indun_cls ~= nil then
        local name = TryGetProp(indun_cls, "Name", "None")
        local account_obj = GetMyAccountObj()
        if account_obj ~= nil then
            local stage = TryGetProp(account_obj, "SOLO_DUNGEON_MINI_CLEAR_STAGE", 0)
            local yesScp = "INDUNINFO_MOVE_TO_SOLO_DUNGEON_PRECHECK"
            local title = ScpArgMsg("Select_Stage_SoloDungeon", "Stage", stage + 5)
            INDUN_EDITMSGBOX_FRAME_OPEN(indun_cls_id, title, "", yesScp, "", 1, stage + 5, 1)
            return
        end
    end
    -- ReqMoveToIndun(1, 0)
end

function indun_panel_buyuse_vel(frame, ctrl, recipename, indun_type)
    g.update_try = 0
    local count = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", indun_type).PlayPerResetType) or ""
    local trade_count = INDUN_PANEL_GET_RECIPE_TRADE_COUNT(recipename)
    local vel_oneday_ticket = 11030169 -- Ticket_Bernice_Enter_1d
    local vel_ticket = 11030257
    session.ResetItemList()
    local invItemList = session.GetInvItemList()
    if count == 1 then
        local use_item = session.GetInvItemByType(vel_oneday_ticket)
        if use_item ~= nil then
            INV_ICON_USE(use_item)
            ReserveScript("indun_panel_enter_velnice_solo()", 2.0)
            return
        end
        local use_item = session.GetInvItemByType(vel_ticket)
        if use_item ~= nil then
            INV_ICON_USE(use_item)
            ReserveScript("indun_panel_enter_velnice_solo()", 2.0)
            return
        end
        local vel_recipecls = GetClass('ItemTradeShop', recipename)
        local vel_overbuy_max = TryGetProp(vel_recipecls, 'MaxOverBuyCount', 0)
        local remain_count = vel_overbuy_max + trade_count
        if remain_count >= 1 then
            INDUN_PANEL_ITEM_BUY_USE(recipename, indun_type)
            ReserveScript("indun_panel_enter_velnice_solo()", 2.0)
            return
        else
            ui.SysMsg(g.lang == "Japanese" and "トレード回数が足りません。" or "No trade count.")
            return
        end
    else
        ReserveScript("indun_panel_enter_velnice_solo()", 1.0)
        return
    end
end

function indun_panel_overbuy_count(recipe_name)
    local aObj = GetMyAccountObj()
    local recipecls = GetClass('ItemTradeShop', recipe_name)
    local overbuy_max = TryGetProp(recipecls, 'MaxOverBuyCount', 0)
    local overbuy_prop = TryGetProp(recipecls, 'OverBuyProperty', 'None')
    local overbuy_count = TryGetProp(aObj, overbuy_prop, 0)
    return tonumber(overbuy_max) - tonumber(overbuy_count)
end

function indun_panel_velnice_frame(frame, key, value, y, x)
    local btn = frame:CreateOrGetControl('button', key .. 'btn', x, y, 80, 30)
    AUTO_CAST(btn)
    btn:SetText("{ol}IN")
    btn:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_velnice_solo")
    local count = frame:CreateOrGetControl("richtext", key .. "count", x + 85, y + 5, 50, 30)
    count:SetText(indun_panel_get_entrance_count(value, 2))
    local recipe_name = "PVP_MINE_52"
    local change_count = INDUN_PANEL_GET_RECIPE_TRADE_COUNT(recipe_name)
    if change_count < 0 then
        change_count = 0
    end
    local ticket_btn = frame:CreateOrGetControl('button', key .. 'ticket_btn', x + 130, y, 80, 30)
    AUTO_CAST(ticket_btn)
    ticket_btn:SetText("{ol}{#EE7800}{s14}BUYUSE")
    ticket_btn:SetEventScript(ui.LBUTTONUP, "indun_panel_buyuse_vel")
    ticket_btn:SetEventScriptArgString(ui.LBUTTONUP, recipe_name)
    ticket_btn:SetEventScriptArgNumber(ui.LBUTTONUP, value)
    local change_text = frame:CreateOrGetControl("richtext", key .. "change_text", x + 215, y + 5, 60, 30)
    change_text:SetText(string.format("{ol}{#FFFFFF}(%d/%d)", change_count, indun_panel_overbuy_count(recipe_name)))
    local amount = frame:CreateOrGetControl("richtext", key .. "amount", x + 280, y + 5, 50, 30)
    local amount_text = "{ol}{#FFFFFF}(" .. "{img pvpmine_shop_btn_total 20 20}"
    function indun_panel_overbuy_amount(recipe_name)
        local aObj = GetMyAccountObj()
        local recipecls = GetClass('ItemTradeShop', recipe_name)
        local overbuy_prop = TryGetProp(recipecls, 'OverBuyProperty', 'None')
        local overbuy_count = TryGetProp(aObj, overbuy_prop, 0)
        if INDUN_PANEL_GET_RECIPE_TRADE_COUNT(recipe_name) == 1 and overbuy_count == 0 then
            return 1000
        elseif overbuy_count >= 0 then
            return overbuy_count * 50 + 1050
        end
        return 0
    end
    if tonumber(change_count) == 1 then
        amount_text = amount_text .. "1,000)"
    else
        amount_text = amount_text ..
                          string.format("{ol}{#FF0000}%s", GET_COMMAED_STRING(indun_panel_overbuy_amount(recipe_name))) ..
                          "{ol}{#FFFFFF})"
    end
    amount:SetText(amount_text)
end

function indun_panel_cemetery_frame(frame, key, value, y, x)
    local btn = frame:CreateOrGetControl('button', key .. 'btn', x, y, 80, 30)
    btn:SetText("{ol}490")
    btn:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_solo")
    btn:SetEventScriptArgNumber(ui.LBUTTONUP, value)
    local count = frame:CreateOrGetControl("richtext", key .. "count", x + 85, y + 5)
    count:SetText(indun_panel_get_entrance_count(value, 1))
    local ticket_btn = frame:CreateOrGetControl('button', key .. 'ticket_btn', x + 115, y, 80, 30)
    AUTO_CAST(ticket_btn)
    ticket_btn:SetText("{ol}{#EE7800}{s14}USE")
    local invItemList = session.GetInvItemList()
    local guidList = invItemList:GetGuidList()
    local cnt = guidList:Count()
    local inv_count = 0
    for i = 0, cnt - 1 do
        local itemobj = GetIES(invItemList:GetItemByGuid(guidList:Get(i)):GetObject())
        local invItem = invItemList:GetItemByGuid(guidList:Get(i))
        if itemobj.ClassID == 11200276 or itemobj.ClassID == 11200275 or itemobj.ClassID == 11200274 then
            inv_count = inv_count + invItem.count
        end
    end
    local item_class1 = GetClassByType('Item', 11200276)
    local icon1 = item_class1.Icon
    local ticket_notice = g.lang == "Japanese" and
                              string.format("{ol}{img %s 25 25 } %d個持っています。", icon1, inv_count) or
                              string.format("{ol}{img %s 25 25 } Quantity in Inventory", icon1, inv_count)
    ticket_btn:SetTextTooltip(ticket_notice)
    ticket_btn:SetEventScript(ui.LBUTTONUP, "indun_panel_item_use")
    ticket_btn:SetEventScriptArgNumber(ui.LBUTTONUP, value)
end

function indun_panel_FIELD_BOSS_ENTER_TIMER_SETTING()
    local function format_time(seconds)
        local hours = math.floor(seconds / 3600)
        local minutes = math.floor((seconds % 3600) / 60)
        local seconds_rem = seconds % 60

        local japanese = string.format("%d時間%d分%d秒", hours, minutes, seconds_rem)
        local english = string.format("%d:%d:%d", hours, minutes, seconds_rem)

        return japanese, english
    end
    local server_time_str = date_time.get_lua_now_datetime_str()
    if not server_time_str then
        return 0
    end
    local _, _, _, hour_str, min_str, sec_str = server_time_str:match("(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)")
    if not hour_str then
        return 0
    end
    local todaysec = tonumber(hour_str) * 3600 + tonumber(min_str) * 60 + tonumber(sec_str)
    local sec12 = 12 * 3600
    local utilsec12 = sec12 - todaysec
    local sec22 = 22 * 3600
    local utilsec22 = sec22 - todaysec
    local textstr = ""
    if utilsec12 >= 0 then
        local japanese, english = format_time(utilsec12)
        textstr = g.settings.en_ver == 1 and english .. " After Start" or japanese .. ClMsg("After_Start");
    elseif utilsec12 >= -300 then
        local japanese, english = format_time(300 + utilsec12)
        textstr = g.settings.en_ver == 1 and english .. " After Exit" or japanese .. ClMsg("After_Exit");
    elseif utilsec22 >= 0 then
        local japanese, english = format_time(utilsec22)
        textstr = g.settings.en_ver == 1 and english .. " After Start" or japanese .. ClMsg("After_Start");
    elseif utilsec22 >= -300 then
        local japanese, english = format_time(300 + utilsec22)
        textstr = g.settings.en_ver == 1 and english .. " After Exit" or japanese .. ClMsg("After_Exit");
    else
        textstr = g.settings.en_ver == 1 and "Already Exit" or ClMsg("Already_Exit");
    end
    local frame = ui.GetFrame("indun_panel")
    if not frame then
        return 0
    end
    local jsrbtn = GET_CHILD_RECURSIVELY(frame, "jsrbtn")
    if not jsrbtn then
        return 0
    end
    local y = jsrbtn:GetUserIValue("Y")
    local x = jsrbtn:GetUserIValue("X")
    local jsrtime = frame:CreateOrGetControl("richtext", "jsrtime", x + 85, y + 5, 10, 10)
    jsrtime:SetText("{ol}" .. textstr)
    if x == 0 then
        jsrtime:ShowWindow(0)
    else
        jsrtime:ShowWindow(1)
    end
    return 1
end

function indun_panel_jsr_frame(frame, key, y, x)
    local jsrbtn = frame:CreateOrGetControl('button', 'jsrbtn', x, y, 80, 30)
    jsrbtn:SetText("{ol}JSR")
    jsrbtn:SetEventScript(ui.LBUTTONUP, "FIELD_BOSS_JOIN_ENTER_CLICK")
    jsrbtn:SetUserValue("Y", y)
    indun_panel_FIELD_BOSS_ENTER_TIMER_SETTING(frame)
    jsrbtn:RunUpdateScript("indun_panel_FIELD_BOSS_ENTER_TIMER_SETTING", 1.0)
    jsrbtn:SetUserValue("X", x)
end

function indun_panel_demonlair_frame(frame, key, value, y, x)
    local btn = frame:CreateOrGetControl('button', key .. 'btn', x, y, 80, 30)
    btn:SetText("{ol}540")
    btn:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_solo")
    btn:SetEventScriptArgNumber(ui.LBUTTONUP, value)
    local count = frame:CreateOrGetControl("richtext", key .. "count", x + 85, y + 5)
    count:SetText(indun_panel_get_entrance_count(value, 1))
    local ticket_btn = frame:CreateOrGetControl('button', key .. 'ticket_btn', x + 115, y, 80, 30)
    AUTO_CAST(ticket_btn)
    ticket_btn:SetText("{ol}{#EE7800}{s14}USE")
    local invItemList = session.GetInvItemList()
    local guidList = invItemList:GetGuidList()
    local cnt = guidList:Count()
    local inv_count = 0
    for i = 0, cnt - 1 do
        local itemobj = GetIES(invItemList:GetItemByGuid(guidList:Get(i)):GetObject())
        local invItem = invItemList:GetItemByGuid(guidList:Get(i))
        if itemobj.ClassID == 11200484 or itemobj.ClassID == 11200485 or itemobj.ClassID == 11200486 then
            inv_count = inv_count + invItem.count
        end
    end
    local item_class1 = GetClassByType('Item', 11200484)
    local icon1 = item_class1.Icon
    local ticket_notice = g.lang == "Japanese" and
                              string.format("{ol}{img %s 25 25 } %d個持っています。", icon1, inv_count) or
                              string.format("{ol}{img %s 25 25 } Quantity in Inventory", icon1, inv_count)
    ticket_btn:SetTextTooltip(ticket_notice)
    ticket_btn:SetEventScript(ui.LBUTTONUP, "indun_panel_item_use")
    ticket_btn:SetEventScriptArgNumber(ui.LBUTTONUP, value)
end

function indun_panel_challenge_map_context(frame, ctrl)
    local weekdays = {"Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"}
    local function get_server_timestamp()
        local server_time_str = date_time.get_lua_now_datetime_str()
        if server_time_str then
            local y, m, d, H, M, S = server_time_str:match("(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)")
            if y then
                local time_table = {
                    year = tonumber(y),
                    month = tonumber(m),
                    day = tonumber(d),
                    hour = tonumber(H),
                    min = tonumber(M),
                    sec = tonumber(S)
                }
                return os.time(time_table)
            end
        end
        return os.time()
    end
    local now_timestamp = get_server_timestamp()
    local diff_seconds = now_timestamp - g.settings.base_date
    local elapsed_days = math.floor(diff_seconds / 86400)
    local context = ui.CreateContextMenu("challenge_map_schedule", "{ol}Challenge Map Schedule", 0, 100, 0, 0)
    local challenge_map_list, count = GetClassList('challenge_mode_auto_map')
    for i = 0, 6 do
        local future_timestamp = now_timestamp + (i * 86400)
        local month_day = os.date("%m-%d", future_timestamp)
        local day_of_week_num = tonumber(os.date("%w", future_timestamp))
        local day_of_week_str = weekdays[day_of_week_num + 1]
        local date_str = string.format("%s (%s)", month_day, day_of_week_str)
        local map_index = (g.settings.challenge_map - 1 + i + elapsed_days) % count
        local map_cls = GetClassByIndexFromList(challenge_map_list, map_index)
        if map_cls then
            local map_name = map_cls.Name
            local map_clsname = map_cls.MapName
            local scp = string.format("indun_panel_challenge_map_display('%s','%s')", map_clsname, date_str)
            ui.AddContextMenuItem(context, date_str .. " " .. map_name, scp)
        end
    end
    ui.OpenContextMenu(context)
end

function indun_panel_challenge_map_close(frame)
    ui.DestroyFrame(frame:GetName())
end

function indun_panel_challenge_map_display(map_clsname, date_str)
    local map = ui.CreateNewFrame("notice_on_pc", addon_name_lower .. "map", 0, 0, 0, 0)
    AUTO_CAST(map)
    map:RemoveAllChild()
    map:SetSkinName("bg")
    map:SetLayerLevel(100)
    map:Resize(300, 300)
    local display = map:CreateOrGetControl("picture", "display", 0, 0, 0, 0)
    AUTO_CAST(display)
    display:Resize(320, 300)
    display:SetEnableStretch(1)
    display:EnableHitTest(0)
    local close = map:CreateOrGetControl('button', 'close', 0, 0, 30, 30)
    AUTO_CAST(close)
    close:SetImage("testclose_button")
    close:SetGravity(ui.RIGHT, ui.TOP)
    close:SetEventScript(ui.LBUTTONUP, "indun_panel_challenge_map_close")
    local map_width = display:GetWidth()
    local map_height = display:GetHeight()
    local map_cls = GetClass("Map", map_clsname)
    local map_title = map:CreateOrGetControl("richtext", "map_title", 0, 0)
    map_title:SetGravity(ui.LEFT, ui.TOP)
    map_title:SetText("{ol}" .. map_cls.Name .. " " .. date_str)
    local pic = AUTO_CAST(display:CreateOrGetControl('picture', "picture_" .. map_clsname, ui.CENTER_HORZ,
        ui.CENTER_VERT, map_width, map_height))
    pic:SetEnableStretch(1)
    local isValid = ui.IsImageExist(map_clsname .. "_fog")
    if isValid == false then
        world.PreloadMinimap(map_clsname)
    end
    pic:SetImage(map_clsname .. "_fog")
    local iconGroup = display:CreateOrGetControl("groupbox", "MapIconGroup", ui.CENTER_HORZ, ui.CENTER_VERT,
        display:GetWidth(), display:GetHeight())
    AUTO_CAST(iconGroup)
    iconGroup:SetSkinName("None")
    local nameGroup = display:CreateOrGetControl("groupbox", "RegionNameGroup", ui.CENTER_HORZ, ui.CENTER_VERT,
        display:GetWidth(), display:GetHeight())
    AUTO_CAST(nameGroup)
    nameGroup:SetSkinName("None")
    UPDATE_MAP_BY_NAME(iconGroup, map_clsname, pic, map_width, map_height, 0, 0)
    MAKE_MAP_AREA_INFO(nameGroup, map_clsname, "{s15}", map_width, map_height, -100, -30)
    local map_frame = ui.GetFrame("map")
    local width = map_frame:GetWidth()
    local height = map_frame:GetHeight()
    map:SetPos(width / 2 - 620, height / 2 - 300)
    map:ShowWindow(1)
end

function indun_panel_frame_contents(frame)

    local frame = ui.GetFrame("indun_panel")
    local account_obj = GetMyAccountObj()

    local gabija = GET_CHILD_RECURSIVELY(frame, "gabija")
    if gabija then
        AUTO_CAST(gabija)
        local coin_count = GET_COMMAED_STRING(TryGetProp(account_obj, "GabijaCertificate", "0"))
        local tooltip_msg = g.lang == "Japanese" and "{ol}ガビヤショップ{nl}" .. "{#FFFF00}" .. coin_count or
                                "{ol}Gabija Shop{nl}" .. "{#FFFF00}" .. coin_count
        gabija:SetTextTooltip(tooltip_msg)
    end
    local vakarine = GET_CHILD_RECURSIVELY(frame, "vakarine")
    if vakarine then
        AUTO_CAST(vakarine)
        local coin_count = GET_COMMAED_STRING(TryGetProp(account_obj, "VakarineCertificate", "0"))
        local tooltip_msg =
            g.lang == "Japanese" and "{ol}ヴァカリネショップ{nl}" .. "{#FFFF00}" .. coin_count or
                "{ol}Vakarine Shop{nl}" .. "{#FFFF00}" .. coin_count
        vakarine:SetTextTooltip(tooltip_msg)
    end
    local rada = GET_CHILD_RECURSIVELY(frame, "rada")
    if rada then
        AUTO_CAST(rada)
        local coin_count = GET_COMMAED_STRING(TryGetProp(account_obj, "RadaCertificate", "0"))
        local tooltip_msg = g.lang == "Japanese" and "{ol}ラダショップ{nl}" .. "{#FFFF00}" .. coin_count or
                                "{ol}Rada Shop{nl}" .. "{#FFFF00}" .. coin_count
        rada:SetTextTooltip(tooltip_msg)
    end
    local jurate = GET_CHILD_RECURSIVELY(frame, "jurate")
    if jurate then
        AUTO_CAST(jurate)
        local coin_count = GET_COMMAED_STRING(TryGetProp(account_obj, "JurateCertificate", "0"))
        local tooltip_msg = g.lang == "Japanese" and "{ol}ユラテショップ{nl}" .. "{#FFFF00}" .. coin_count or
                                "{ol}Jurate Shop{nl}" .. "{#FFFF00}" .. coin_count
        jurate:SetTextTooltip(tooltip_msg)
    end
    local austeja = GET_CHILD_RECURSIVELY(frame, "austeja")
    if austeja then
        AUTO_CAST(austeja)
        local coin_count = GET_COMMAED_STRING(TryGetProp(account_obj, "AustejaCertificate", "0"))
        local tooltip_msg =
            g.lang == "Japanese" and "{ol}アウステヤショップ{nl}" .. "{#FFFF00}" .. coin_count or
                "{ol}Austeja Shop{nl}" .. "{#FFFF00}" .. coin_count
        austeja:SetTextTooltip(tooltip_msg)
    end
    local icon_tbl = {
        ["challenge"] = {"Item", 490363},
        ["singularity"] = {"Item", 11030017},
        ["veliora"] = {"Monster", 71043},
        ["limara"] = {"Monster", 71040},
        ["redania"] = {"Monster", 59864},
        ["neringa"] = {"Monster", 59856},
        ["golem"] = {"Monster", 59859},
        ["merregina"] = {"Monster", 59824},
        ["slogutis"] = {"Monster", 59798},
        ["upinis"] = {"Monster", 59795},
        ["roze"] = {"Monster", 59773},
        ["falouros"] = {"Monster", 59760},
        ["spreader"] = {"Monster", 59752},
        ["jellyzele"] = {"Monster", 59730},
        ["delmore"] = {"Monster", 59690},
        ["telharsha"] = {"Monster", 59477},
        ["velnice"] = {"Item", 11030257},
        ["giltine"] = {"Monster", 59549},
        ["earring"] = {"Item", 11100001},
        ["cemetery"] = {"Item", 960213},
        ["demonlair"] = {"Item", 11200484},
        ["jsr"] = ""
    }
    local prefix = "DD"
    if g.settings.skin_name and g.settings.skin_name == "bg" then
        prefix = "FF"
    end
    local x = 150
    local use_tbl = g.settings[g.settings.use_set] ~= "None" and g.settings[g.settings.use_set] or g.settings
    if g.update_try < 3 then
        local y = 40
        local index = 1
        for i, entry in ipairs(induntype) do
            local key, value = next(entry)
            if use_tbl[key .. "_checkbox"] == 1 then
                local text = nil
                local img_icon = nil
                if g.settings.shading == 1 then
                    if index % 2 == 1 then
                        -- local line = frame:CreateOrGetControl("groupbox", "line" .. key, 0, y - 4, 750, 40)
                        local line = frame:CreateOrGetControl("picture", "line" .. key, 5, y - 2, 740, 33)
                        AUTO_CAST(line)
                        line:SetImage("fullwhite")
                        line:SetEnableStretch(1)
                        line:EnableHitTest(0)
                        line:SetColorTone(prefix .. "696969")
                        if icon_tbl[key] then
                            img_icon = frame:CreateOrGetControl("picture", "img_icon" .. key, x - 140, y + 5, 20, 20)
                            AUTO_CAST(img_icon)
                            local icon_cls
                            if key == "jsr" then
                                local fieldbossPattern = session.fieldboss.GetPatternInfo();
                                local icon_cls_name = fieldbossPattern.MonsterClassName
                                icon_cls = GetClass("Monster", icon_cls_name)
                            else
                                icon_cls = GetClassByType(icon_tbl[key][1], icon_tbl[key][2])
                            end
                            if icon_cls then
                                local img_name = icon_cls.Icon
                                img_icon:SetImage(img_name)
                                img_icon:SetEnableStretch(1)
                                img_icon:EnableHitTest(0)
                            end
                        end
                        text = frame:CreateOrGetControl("richtext", key, x - 120, y + 5)
                        text:SetText("{ol}{#FFFFFF}" .. INDUN_PANEL_LANG(convert_tbl[key] or key))
                    else
                        local line = frame:CreateOrGetControl("picture", "line" .. key, 5, y - 2, 740, 33)
                        AUTO_CAST(line)
                        line:SetImage("fullwhite")
                        line:SetEnableStretch(1)
                        line:EnableHitTest(0)
                        line:SetColorTone(prefix .. "A9A9A9")
                        if icon_tbl[key] then
                            img_icon = frame:CreateOrGetControl("picture", "img_icon" .. key, x - 140, y + 5, 20, 20)
                            AUTO_CAST(img_icon)
                            local icon_cls
                            if key == "jsr" then
                                local fieldbossPattern = session.fieldboss.GetPatternInfo();
                                local icon_cls_name = fieldbossPattern.MonsterClassName
                                icon_cls = GetClass("Monster", icon_cls_name)
                            else
                                icon_cls = GetClassByType(icon_tbl[key][1], icon_tbl[key][2])
                            end
                            if icon_cls then
                                local img_name = icon_cls.Icon
                                img_icon:SetImage(img_name)
                                img_icon:SetEnableStretch(1)
                                img_icon:EnableHitTest(0)
                            end
                        end
                        text = frame:CreateOrGetControl("richtext", key, x - 120, y + 5)
                        text:SetText("{ol}{#FFFFFF}" .. INDUN_PANEL_LANG(convert_tbl[key] or key))
                    end
                    index = index + 1
                else
                    if icon_tbl[key] then
                        img_icon = frame:CreateOrGetControl("picture", "img_icon" .. key, x - 140, y + 5, 20, 20)
                        AUTO_CAST(img_icon)
                        local icon_cls
                        if key == "jsr" then
                            local fieldbossPattern = session.fieldboss.GetPatternInfo();
                            local icon_cls_name = fieldbossPattern.MonsterClassName
                            icon_cls = GetClass("Monster", icon_cls_name)
                        else
                            icon_cls = GetClassByType(icon_tbl[key][1], icon_tbl[key][2])
                        end
                        if icon_cls then
                            local img_name = icon_cls.Icon
                            img_icon:SetImage(img_name)
                            img_icon:SetEnableStretch(1)
                            img_icon:EnableHitTest(0)
                        end
                    end
                    text = frame:CreateOrGetControl("richtext", key, x - 120, y + 5)
                    text:SetText("{ol}{#FFFFFF}" .. INDUN_PANEL_LANG(convert_tbl[key] or key))
                end
                if key == "challenge" then
                    local tooltip = g.lang == "Japanese" and
                                        "{ol}左クリック: チャレンジマップの1週間分のスケジュール表示" or
                                        "{ol}Left Click: Display the schedule for one week of the Challenge Map"
                    img_icon:EnableHitTest(1)
                    img_icon:SetEventScript(ui.LBUTTONUP, "indun_panel_challenge_map_context")
                    img_icon:SetTextTooltip(tooltip)
                    text:EnableHitTest(1)
                    text:SetEventScript(ui.LBUTTONUP, "indun_panel_challenge_map_context")
                    text:SetTextTooltip(tooltip)
                end
                text:AdjustFontSizeByWidth(120)
                if type(value) == "table" then
                    if key == "slogutis" or key == "upinis" or key == "roze" or key == "falouros" or key == "spreader" or
                        key == "merregina" or key == "neringa" or key == "golem" or key == "redania" or key == "veliora" or
                        key == "limara" then
                        for subKey, subValue in pairs(value) do
                            indun_panel_create_frame_onsweep(frame, key, subKey, subValue, y, x)
                        end
                    elseif key == "jellyzele" or key == "delmore" or key == "giltine" or key == "earring" then
                        for subKey, subValue in pairs(value) do
                            indun_panel_create_frame(frame, key, subKey, subValue, y, x)
                        end
                    elseif key == "challenge" then
                        indun_panel_challenge_frame(frame, key, y, value, x)
                    elseif key == "singularity" then
                        indun_panel_singularity_frame(frame, key, y, value, x)
                    end
                else
                    if key == "telharsha" then
                        indun_panel_telharsha_frame(frame, key, value, y, x)
                    elseif key == "velnice" then
                        indun_panel_velnice_frame(frame, key, value, y, x)
                    elseif key == "cemetery" then
                        indun_panel_cemetery_frame(frame, key, value, y, x)
                    elseif key == "demonlair" then
                        indun_panel_demonlair_frame(frame, key, value, y, x)
                    end
                end
                if key ~= "jsr" then
                    y = y + 33
                end
            end
        end
        g.index_remainder = index % 2
        g.update_try = g.update_try + 1
        g.last_y = y
    end
    local y = g.last_y or 40
    if use_tbl["jsr" .. "_checkbox"] == 1 then
        indun_panel_jsr_frame(frame, "jsr", y, x)
        y = y + 33
    end
    -- g.housing_call_time = 0
    local current_time = os.clock()
    if not g.housing_call_time or (current_time - g.housing_call_time) > 5 then
        indun_panel_get_my_housing_point_callback_ready(frame)
        g.housing_call_time = current_time
        local bonusTP_pic = frame:CreateOrGetControl("richtext", "bonusTP_pic", 320, y + 5)
        AUTO_CAST(bonusTP_pic)
        bonusTP_pic:SetText("{img bonusTP_pic 22 22}")
        local bonusTP_count = frame:CreateOrGetControl("richtext", "bonusTP_count", 350, y + 5)
        AUTO_CAST(bonusTP_count)
        bonusTP_count:SetText("{ol}{#FFD900}{s18}" .. account_obj.Medal)
        bonusTP_count:SetTextTooltip("{ol}Free TP")
        if g.housing_point then
            local housing_btn = frame:CreateOrGetControl("richtext", "housing_btn", 370, y + 5)
            AUTO_CAST(housing_btn)
            housing_btn:SetText("{img btn_housing_editmode_small_resize 23 23}")

            local housing_count = frame:CreateOrGetControl("richtext", "housing_count", 400, y + 5)
            AUTO_CAST(housing_count)
            housing_count:SetText("{ol}{#FFD900}{s18}" .. g.housing_point)
            housing_count:SetTextTooltip("{ol}Housing Point")

        end
    end
    if g.settings.shading == 1 then
        local line = frame:CreateOrGetControl("picture", "last_line", 5, y - 2, 740, 33)
        AUTO_CAST(line)
        line:SetImage("fullwhite")
        line:SetEnableStretch(1)
        line:EnableHitTest(0)
        if g.index_remainder == 1 then
            line:SetColorTone(prefix .. "696969")
        else
            line:SetColorTone(prefix .. "A9A9A9")
        end
    end
    local tos_coin = frame:CreateOrGetControl("richtext", "tos_coin", 450, y + 5)
    tos_coin:SetText("{img icon_item_Tos_Event_Coin 21 21}")
    local tos_coin_count = frame:CreateOrGetControl("richtext", "tos_coin_count", 475, y + 5)
    local coin_count = GET_COMMAED_STRING(TryGetProp(account_obj, "EVENT_TOS_WHOLE_TOTAL_COIN", "0"))
    tos_coin_count:SetText(string.format("{ol}{#FFD900}{s18}%s/%s", coin_count,
        "{#FFD900}" .. GET_COMMAED_STRING(g.settings.toscoin) or 0))

    local pvpmine = frame:CreateOrGetControl("richtext", "pvpmine", 605, y + 5)
    pvpmine:SetText("{img pvpmine_shop_btn_total 25 25}")
    local pvpminecount = frame:CreateOrGetControl("richtext", "pvpminecount", 630, y + 5)
    coin_count = GET_COMMAED_STRING(TryGetProp(account_obj, "MISC_PVP_MINE2", "0"))
    pvpminecount:SetText(string.format("{ol}{#FFD900}{s18}%s", coin_count))
    local version = frame:CreateOrGetControl("richtext", "ver", 15, y + 15)
    version:SetText(string.format("{ol}{#FFD900}{s13}ver: %s", ver))
    y = y + 33
    frame:SetLayerLevel(80)
    frame:Resize(x + 600, y)
    if not g.settings.skin_name then
        frame:SetSkinName("chat_window_2")
    else
        frame:SetSkinName(g.settings.skin_name)
    end
    -- frame:SetSkinName("pipwin_low")
    -- frame:SetSkinName("chat_window_2")--bg2
    frame:EnableHitTest(1);
    frame:SetAlpha(100)
    -- frame:SetLayerLevel(100)
    return 1
end

function indun_panel_get_my_housing_point_callback_ready(frame)
    local aidx = session.loginInfo.GetAID()
    GetMyHousingPageInfo("indun_panel_get_my_housing_point_callback", aidx)
    return 1
end

local json = require("json")
function indun_panel_get_my_housing_point_callback(code, ret_json)
    if code ~= 200 or not ret_json or ret_json == "" then
        return
    end
    local parsed = json.decode(ret_json)

    if not parsed or type(parsed) ~= "table" then
        return
    end
    if parsed["pointInfo"] and parsed["pointInfo"]["personalHousing_Point1"] then
        local point = parsed["pointInfo"]["personalHousing_Point1"]
        g.housing_point = tonumber(point)
    else
        g.housing_point = "NoData"
    end

end

function indun_panel_frame_drag(frame, ctrl, str, num)
    g.settings.x = frame:GetX()
    g.settings.y = frame:GetY()
    g.save_settings()
    indun_panel_frame_init()
end

function indun_panel_always_init(frame, ctrl, str)

    if str == "OPEN" then
        g.settings.checkbox = 1
        indun_panel_frame_open(frame)
    else
        g.settings.checkbox = 0
        indun_panel_frame_init()
    end
    g.save_settings()
end

function indun_panel_FULLSCREEN_NAVIGATION_MENU_DETAIL_MOVE_NPC(frame, ctrl, str, guid)
    if g.get_map_type() ~= "City" then
        return
    end
    if guid == nil then
        return;
    end
    local cls = GetClassByType("full_screen_navigation_menu", guid);
    if cls ~= nil then
        local name = TryGetProp(cls, "Name", "None");
        local move_zone_select = TryGetProp(cls, "MoveZoneSelect", "NO");
        local move_zone = TryGetProp(cls, "MoveZone", "None");
        local move_npc_dialog = TryGetProp(cls, "MoveNpcDialog", "None");
        local move_zone_select_msg = TryGetProp(cls, "MoveZoneSelectMsg", "None");
        local move_only_in_town = TryGetProp(cls, "MoveOnlyInTown", "None");
        if move_zone ~= "None" and move_npc_dialog ~= "None" then
            -- 매칭 던전중이거나 pvp존이면 이용 불가
            local pc = GetMyPCObject();
            if session.world.IsIntegrateServer() == true or IsPVPField(pc) == 1 or IsPVPServer(pc) == 1 then
                ui.SysMsg(ScpArgMsg("ThisLocalUseNot"));
                return;
            end
            -- 퀘스트나 챌린지 모드로 인해 레이어 변경되면 이용 불가
            if world.GetLayer() ~= 0 then
                ui.SysMsg(ScpArgMsg("ThisLocalUseNot"));
                return;
            end
            -- 프리던전 맵에서 이용 불가
            local cur_map = GetClass("Map", session.GetMapName());
            local map_type = TryGetProp(cur_map, "MapType");
            if map_type == "Dungeon" then
                ui.SysMsg(ScpArgMsg("ThisLocalUseNot"));
                return;
            end
            -- 레이드 지역에서 이용 불가
            local zoneKeyword = TryGetProp(cur_map, 'Keyword', 'None')
            local keywordTable = StringSplit(zoneKeyword, ';')
            if table.find(keywordTable, 'IsRaidField') > 0 or table.find(keywordTable, 'WeeklyBossMap') > 0 then
                ui.SysMsg(ScpArgMsg('ThisLocalUseNot'))
                return
            end
            FullScreenMenuMoveNpc(name, move_zone_select, move_zone, move_npc_dialog, move_zone_select_msg,
                move_only_in_town);
            ui.CloseFrame("fullscreen_navigation_menu");
        end
    end
end

function indun_panel_ischecked(frame, ctrl, argStr, argNum)
    local ischeck = ctrl:IsChecked()
    local ctrlname = ctrl:GetName()
    if ctrlname == "tosshop" then
        ctrlname = "tos"
    end
    if string.find(ctrl:GetName(), "auto_check") then
        ctrlname = "singularity_check"
    end
    local use_tbl
    if g.settings.use_set ~= "None" and string.find(ctrlname, "_checkbox") then
        use_tbl = g.settings[g.settings.use_set]
    else
        use_tbl = g.settings
    end
    if use_tbl[ctrlname] then
        use_tbl[ctrlname] = ischeck
    elseif g.settings.cols[ctrlname] then
        g.settings.cols[ctrlname] = ischeck
    end
    g.save_settings()
    if ctrlname == "move" then
        frame:EnableMove(g.settings.move)
    end
end

function indun_panel_singularity_ticket_craft(frame, ctrl, str_arg, step)
    local notice_msg
    if g.lang == "Japanese" then
        notice_msg = "{ol}[IDP]分裂券作成中{nl}バグ防止のため操作をしないでください"
    else
        notice_msg = "{ol}[IDP]Creating Singularity Voucher{nl}Please do not perform any actions to prevent bugs"
    end
    imcAddOn.BroadMsg("NOTICE_Dm_GetItem", notice_msg, 2.0)
    if step == 0 then
        local recipe_name = "PVP_MINE_40"
        if INDUN_PANEL_GET_RECIPE_TRADE_COUNT(recipe_name) >= 4 then
            local recipe_cls = GetClass("ItemTradeShop", recipe_name)
            session.ResetItemList()
            session.AddItemID(tostring(0), 1)
            local item_list = session.GetItemIDList()
            local cnt_text = string.format("%s %s", tostring(recipe_cls.ClassID), tostring(4))

            item.DialogTransaction("PVP_MINE_SHOP", item_list, cnt_text)
            ReserveScript(string.format("indun_panel_singularity_ticket_craft(nil,nil,nil,%d)", 1), 0.5)
            return
        else
            local msg
            if g.lang == "Japanese" then
                msg = "{ol}チャレンジ券が4枚未満です"
            else
                msg = "{ol}Less than 4 challenge tickets"
            end
            ui.SysMsg(msg)
            return
        end
    elseif step == 1 then
        local recipe_name = "PVP_MINE_122"
        local recipe_cls = GetClass("ItemTradeShop", recipe_name)
        session.ResetItemList()
        session.AddItemID(tostring(0), 1)
        local item_list = session.GetItemIDList()
        local cnt_text = string.format("%s %s", tostring(recipe_cls.ClassID), tostring(1))
        item.DialogTransaction("PVP_MINE_SHOP", item_list, cnt_text)
        ReserveScript(string.format("indun_panel_singularity_ticket_craft(nil,nil,nil,%d)", 2), 0.5)
        return
    elseif step == 2 then
        local recipe_name = "PVP_MINE_122"
        local recipe_cls = GetClass("ItemTradeShop", recipe_name)
        local item_cls = GetClass("Item", recipe_cls.TargetItem)
        local inv_item = session.GetInvItemByType(item_cls.ClassID)
        if inv_item then
            INV_ICON_USE(inv_item)
        else
            return
        end
        ReserveScript(string.format("indun_panel_singularity_ticket_craft(nil,nil,nil,%d)", 3), 0.5)
        return
    elseif step == 3 then
        local input_frame = ui.GetFrame("inputstring")
        if input_frame and input_frame:IsVisible() == 1 then
            INPUT_STRING_EXEC(input_frame)
        end
        ReserveScript(string.format("indun_panel_singularity_ticket_craft(nil,nil,nil,%d)", 4), 0.5)
        return
    elseif step == 4 then
        local item_id_ticket = 11030067 -- チャレンジモード：[Lv.520] 分裂特異点1回入場券(1日)
        local inv_item = session.GetInvItemByType(item_id_ticket)
        if inv_item then
            INV_ICON_USE(inv_item)
        else
            return
        end

        ReserveScript(string.format("indun_panel_enter_singularity(nil,nil,nil, %d)", 2000), 0.5)
        return
    end
end

function indun_panel_enter_solo(frame, ctrl, str, induntype)
    ReqRaidAutoUIOpen(induntype)
    ReqMoveToIndun(1, 0)
end

function indun_panel_enter_auto(frame, ctrl, str, induntype)
    ReqRaidAutoUIOpen(induntype)
    local indunCls = GetClassByType('Indun', induntype);
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

function indun_panel_enter_hard(frame, ctrl, str, induntype)
    local indunCls = GetClassByType("Indun", induntype)
    if str == "false" then
        function INDUN_PANEL_INDUNINFO_SET_BUTTONS(induntype, ctrl)

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
        INDUN_PANEL_INDUNINFO_SET_BUTTONS(induntype, ctrl)
        str = "true"
        ReserveScript(string.format("indun_panel_enter_hard('%s','%s','%s',%d)", frame, ctrl, str, induntype), 0.5)
        return
    else
        SHOW_INDUNENTER_DIALOG(induntype)
        frame:ShowWindow(0)
        return
    end
end

function indun_panel_INDUN_ALREADY_PLAYING()
    ReserveScript("indun_panel_INDUN_ALREADY_PLAYING_dilay()", 0.3)
end

function indun_panel_INDUN_ALREADY_PLAYING_dilay()
    local topFrame = ui.GetFrame("indunenter")
    local indunType = tostring(topFrame:GetUserValue('INDUN_TYPE'));
    if indunType == "1005" or indunType == "2000" or indunType == "2001" then -- 1005＝540チャレPT 2001＝540分裂
        indunType = tonumber(indunType)
        AnsGiveUpPrevPlayingIndun(1)
        ui.CloseFrame("indunenter")
        ReserveScript(string.format("indun_panel_enter_singularity('%s','%s','%s', %d)", _, _, _, indunType), 0.5)
        return
    else
        local yesScp = string.format("AnsGiveUpPrevPlayingIndun(%d)", 1);
        local noScp = string.format("AnsGiveUpPrevPlayingIndun(%d)", 0);
        ui.MsgBox(ClMsg("IndunAlreadyPlaying_AreYouGiveUp"), yesScp, noScp);
    end
end

function INDUN_PANEL_ITEM_BUY_USE(recipe_name, indun_type)
    local recipeCls = GetClass("ItemTradeShop", recipe_name)
    session.ResetItemList()
    session.AddItemID(tostring(0), 1)
    local itemlist = session.GetItemIDList()
    local cntText = string.format("%s %s", tostring(recipeCls.ClassID), tostring(1))
    if string.find(recipe_name, "EVENT_TOS") then
        item.DialogTransaction("EVENT_TOS_WHOLE_SHOP", itemlist, cntText)
    else
        item.DialogTransaction("PVP_MINE_SHOP", itemlist, cntText)
    end
    local itemCls = GetClass("Item", recipeCls.TargetItem)
    ReserveScript(string.format("INV_ICON_USE(session.GetInvItemByType(%d));", itemCls.ClassID), 1)

    if indun_type == 2000 or indun_type == 2001 then
        ReserveScript(string.format("indun_panel_enter_singularity('%s','%s','%s', %d)", _, _, _, indun_type), 2.0)
        return
    end
end

function INDUN_PANEL_GET_RECIPE_TRADE_COUNT(recipeName)
    local recipeCls = GetClass("ItemTradeShop", recipeName)
    if recipeCls.NeedProperty ~= "None" and recipeCls.NeedProperty ~= "" then
        local sCount = TryGetProp(GetSessionObject(GetMyPCObject(), "ssn_shop"), recipeCls.NeedProperty)
        if sCount then
            return sCount
        end
    end
    if recipeCls.AccountNeedProperty ~= "None" and recipeCls.AccountNeedProperty ~= "" then
        local sCount = TryGetProp(GetMyAccountObj(), recipeCls.AccountNeedProperty)
        if sCount then
            return sCount
        end
    end
    return nil
end

function indun_panel_CHAT_SYSTEM(msg, color)
    if msg then
        local pattern = "EVENT_TOS_WHOLE_GET_SUCCESS_MSG"
        if string.find(msg, pattern) then
            local daily_value_str = msg:match("%$%*%$DAILY%$%*%$(%d+)%$%*%$")
            g.settings.toscoin = tonumber(daily_value_str)
            g.save_settings()
        end
    end
end

function INDUN_PANEL_LANG(str)

    if g.settings.en_ver == 0 and g.lang == "Japanese" then
        if str == tostring("belliora") then
            str = "ベリオラ"
        end
        if str == tostring("laimara") then
            str = "ライマラ"
        end
        if str == tostring("ledania") then
            str = "レダニア"
        end
        if str == tostring("neringa") then
            str = "ネリンガ"
        end
        if str == tostring("golem") then
            str = "ゴーレム"
        end
        if str == tostring("challenge") then
            str = "チャレンジ"
        end
        if str == tostring("singularity") then
            str = "分裂特異点"
        end
        -- "merregina"
        if str == tostring("merregina") then
            str = "メレジナ"
        end
        if str == tostring("slogutis") then
            str = "スローガティス"
        end
        if str == tostring("upinis") then
            str = "ウピニス"
        end
        if str == tostring("roze") then
            str = "ロゼ"
        end
        if str == tostring("falouros") then
            str = "ファロウロス"
        end
        if str == tostring("reservoir") then
            str = "プロパゲーター"
        end
        if str == tostring("jellyzele") then
            str = "ジェリージェル"
        end
        if str == tostring("delmore") then
            str = "デルムーア"
        end
        if str == tostring("telharsha") then
            str = "テルハルシャ"
        end
        if str == tostring("bernice") then
            str = "ヴェルニケ"
        end
        if str == tostring("giltine") then
            str = "ギルティネ"
        end
        if str == tostring("memory") then
            str = "焔の記憶"
        end
        -- if str == tostring("{s20}Wailing") then
        if str == tostring("wailing") then
            str = "嘆きの墓地"
        end
        if str == tostring("ACLEAR") then
            str = "ACLEAR"
        end

        if str == tostring("ashaq") then
            str = "アシャーク"
        end

        if str == tostring("jsr") then
            str = "ボス協同戦"
        end
        if str == tostring("season") then
            str = "シーズンチャレンジ"
        end
        return "{s16}" .. str
    end
    return "{s20}" .. str
end
