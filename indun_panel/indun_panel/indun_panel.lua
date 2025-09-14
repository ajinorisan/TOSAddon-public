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
local addonName = "indun_panel"
local addon_name_lower = string.lower(addonName)
local author = "norisan"
local ver = "1.6.5"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}

local g = _G["ADDONS"][author][addonName]
local json = require('json')

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
    [716] = {11210044, 11210043, 11210042},
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
    move = 0
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
        for key, value in pairs(DEFAULT_SETTINGS) do
            if settings[key] == nil then
                settings[key] = value
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

local function ts(...)
    local args = {...}
    if #args == 0 then
        return
    end

    local string_parts = {}
    for i = 1, #args do
        table.insert(string_parts, tostring(args[i]))
    end

    print(table.concat(string_parts, "\t"))
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

    -- REQ_DEMON_LAIR_UI_OPEN
    --[[local functionName = "AUTOMAPCHANGE_CAMERA_ZOOM"
    if _G[functionName] and type(_G[functionName]) == "function" then
        _G[functionName] = nil
    end]]

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
    indun_panel:RunUpdateScript("indun_panel_get_my_housing_point_callback_ready", 1.0)
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

--[[function indun_panel_get_next_reset_timestamp()
    local now = os.time()
    local date_table = os.date("*t", now)

    local today_6am_timestamp = os.time({
        year = date_table.year,
        month = date_table.month,
        day = date_table.day,
        hour = 6,
        min = 0,
        sec = 0
    })

    if now < today_6am_timestamp then

        return today_6am_timestamp
    else

        return today_6am_timestamp + 86400
    end
end

function indun_panel_daily_reset(indun_panel)
    local now = os.time()

    if g.settings.toscoin == nil then
        g.settings.toscoin = 0
    end

    if g.settings.reset_time == nil or g.settings.reset_time < now then
        g.settings.toscoin = 0
        g.recipe_trade = false
        g.settings.reset_time = indun_panel_get_next_reset_timestamp()
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
end]]

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

function indun_panel_frame_init()

    local frame = ui.GetFrame("indun_panel")

    frame:SetSkinName('None')
    frame:SetLayerLevel(30)

    frame:EnableHittestFrame(1)
    frame:EnableMove(g.settings.move or 0)
    frame:SetEventScript(ui.LBUTTONUP, "indun_panel_frame_drag")
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
    frame:RemoveAllChild()

    local button = frame:CreateOrGetControl("button", "indun_panel_open", 5, 5, 80, 30)
    AUTO_CAST(button)
    button:SetText("{ol}{s10}INDUNPANEL")
    button:SetEventScript(ui.LBUTTONUP, "indun_panel_frame_open")
    button:SetEventScript(ui.RBUTTONUP, "indun_panel_always_init")
    button:SetEventScriptArgString(ui.RBUTTONUP, "OPEN")
    button:SetTextTooltip(g.lang == "Japanese" and "{ol}右クリック: 常時展開で開く" or
                              "{ol}Right click: Open in Always Expand")

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

    if #tooltip_parts > 0 then
        ccbtn:SetTextTooltip("{ol}" .. table.concat(tooltip_parts, "{nl}"))
    else
        ccbtn:SetTextTooltip(g.lang == "Japanese" and "{ol}バラックに戻ります" or "{ol}Return to Barracks")
    end

    local x = 115

    local temp_tbl =
        {"tos", "gabija", "vakarine", "rada", "jurate", "austeja", "pvp_mine", "market", "craft", "leticia"}

    if not g.settings.cols then
        g.settings.cols = {}
        for _, key_name in ipairs(temp_tbl) do

            if key_name == "leticia" then
                g.settings.cols[key_name] = 1
            else
                g.settings.cols[key_name] = 0
            end

        end

        g.save_settings()
    else
        for _, key_name in ipairs(temp_tbl) do
            if not g.settings.cols[key_name] then
                g.settings.cols[key_name] = 0
            end
        end
    end

    local account_obj = GetMyAccountObj()
    local coin_count = 0

    for _, key_name in ipairs(temp_tbl) do
        if g.settings.cols[key_name] == 1 then
            local tooltip_msg = ""
            if key_name == "tos" then
                if g.get_map_type() == "City" then
                    local tosshop = frame:CreateOrGetControl("button", "tosshop", x + 2, 8, 25, 25);
                    AUTO_CAST(tosshop)
                    tosshop:SetSkinName("None")
                    tosshop:SetText("{img icon_item_Tos_Event_Coin 25 25}")
                    coin_count = GET_COMMAED_STRING(TryGetProp(account_obj, "EVENT_TOS_WHOLE_TOTAL_COIN", "0"))
                    tooltip_msg = g.lang == "Japanese" and "{ol}TOSイベントショップ" or "{ol}TOS Event Shop"
                    tosshop:SetTextTooltip(tooltip_msg)
                    tosshop:SetEventScript(ui.LBUTTONDOWN, "INDUN_PANEL_EARTHTOWERSHOP_CLOSE_RESTART")
                    tosshop:SetEventScript(ui.LBUTTONUP, "indun_panel_event_tos_whole_shop_open")
                end
            elseif key_name == "gabija" then
                if g.get_map_type() == "City" then
                    local gabija = frame:CreateOrGetControl("button", "gabija", x, 7, 29, 29);
                    AUTO_CAST(gabija)
                    gabija:SetSkinName("None")
                    gabija:SetText("{img goddess_shop_btn 29 29}")
                    coin_count = GET_COMMAED_STRING(TryGetProp(account_obj, "GabijaCertificate", "0"))
                    tooltip_msg =
                        g.lang == "Japanese" and "{ol}ガビヤショップ{nl}" .. "{#FFFF00}" .. coin_count or
                            "{ol}Gabija Shop{nl}" .. "{#FFFF00}" .. coin_count
                    gabija:SetTextTooltip(tooltip_msg)
                    gabija:SetEventScript(ui.LBUTTONDOWN, "INDUN_PANEL_EARTHTOWERSHOP_CLOSE_RESTART")
                    gabija:SetEventScript(ui.LBUTTONUP, "REQ_GabijaCertificate_SHOP_OPEN")
                end
            elseif key_name == "vakarine" then
                if g.get_map_type() == "City" then
                    local vakarine = frame:CreateOrGetControl("button", "vakarine", x, 7, 29, 29);
                    AUTO_CAST(vakarine)
                    vakarine:SetSkinName("None")
                    vakarine:SetText("{img goddess2_shop_btn 29 29}")
                    coin_count = GET_COMMAED_STRING(TryGetProp(account_obj, "VakarineCertificate", "0"))
                    tooltip_msg = g.lang == "Japanese" and "{ol}ヴァカリネショップ{nl}" .. "{#FFFF00}" ..
                                      coin_count or "{ol}Vakarine Shop{nl}" .. "{#FFFF00}" .. coin_count
                    vakarine:SetTextTooltip(tooltip_msg)
                    vakarine:SetEventScript(ui.LBUTTONDOWN, "INDUN_PANEL_EARTHTOWERSHOP_CLOSE_RESTART")
                    vakarine:SetEventScript(ui.LBUTTONUP, "REQ_VakarineCertificate_SHOP_OPEN")
                end
            elseif key_name == "rada" then
                if g.get_map_type() == "City" then
                    local rada = frame:CreateOrGetControl("button", "rada", x, 8, 29, 29);
                    AUTO_CAST(rada)
                    rada:SetSkinName("None")
                    rada:SetText("{img goddess3_shop_btn 29 29}")
                    coin_count = GET_COMMAED_STRING(TryGetProp(account_obj, "RadaCertificate", "0"))
                    tooltip_msg = g.lang == "Japanese" and "{ol}ラダショップ{nl}" .. "{#FFFF00}" .. coin_count or
                                      "{ol}Rada Shop{nl}" .. "{#FFFF00}" .. coin_count
                    rada:SetTextTooltip(tooltip_msg)
                    rada:SetEventScript(ui.LBUTTONDOWN, "INDUN_PANEL_EARTHTOWERSHOP_CLOSE_RESTART")
                    rada:SetEventScript(ui.LBUTTONUP, "REQ_RadaCertificate_SHOP_OPEN")
                end
            elseif key_name == "jurate" then
                if g.get_map_type() == "City" then
                    local jurate = frame:CreateOrGetControl("button", "jurate", x, 7, 29, 29);
                    AUTO_CAST(jurate)

                    jurate:SetSkinName("None")
                    jurate:SetText("{img goddess4_shop_btn 29 29}")
                    coin_count = GET_COMMAED_STRING(TryGetProp(account_obj, "JurateCertificate", "0"))
                    tooltip_msg =
                        g.lang == "Japanese" and "{ol}ユラテショップ{nl}" .. "{#FFFF00}" .. coin_count or
                            "{ol}Jurate Shop{nl}" .. "{#FFFF00}" .. coin_count
                    jurate:SetTextTooltip(tooltip_msg)
                    jurate:SetEventScript(ui.LBUTTONDOWN, "INDUN_PANEL_EARTHTOWERSHOP_CLOSE_RESTART")
                    jurate:SetEventScript(ui.LBUTTONUP, "REQ_JurateCertificate_SHOP_OPEN")
                end
            elseif key_name == "austeja" then
                -- if g.get_map_type() == "City" then
                local austeja = frame:CreateOrGetControl("button", "austeja", x, 7, 29, 29);
                AUTO_CAST(austeja)
                if g.get_map_type() ~= "City" then
                    austeja:SetOffset(115, 7)
                end
                austeja:SetSkinName("None")
                austeja:SetText("{img goddess5_shop_btn 29 29}")
                coin_count = GET_COMMAED_STRING(TryGetProp(account_obj, "AustejaCertificate", "0"))
                tooltip_msg = g.lang == "Japanese" and "{ol}アウステヤショップ{nl}" .. "{#FFFF00}" ..
                                  coin_count or "{ol}Austeja Shop{nl}" .. "{#FFFF00}" .. coin_count
                austeja:SetTextTooltip(tooltip_msg)
                austeja:SetEventScript(ui.LBUTTONDOWN, "INDUN_PANEL_EARTHTOWERSHOP_CLOSE_RESTART")
                austeja:SetEventScript(ui.LBUTTONUP, "REQ_AustejaCertificate_SHOP_OPEN")
                -- end
            elseif key_name == "pvp_mine" then
                local pvp_mine = frame:CreateOrGetControl("button", "pvp_mine", x, 7, 29, 29);
                AUTO_CAST(pvp_mine)
                if g.get_map_type() ~= "City" then
                    pvp_mine:SetOffset(145, 7)
                end
                pvp_mine:SetSkinName("None")
                pvp_mine:SetText("{img pvpmine_shop_btn_total 29 29}")
                pvp_mine:SetTextTooltip(g.lang == "Japanese" and "{ol}傭兵団ショップ" or "{ol}Mercenary Shop")
                pvp_mine:SetEventScript(ui.LBUTTONDOWN, "INDUN_PANEL_EARTHTOWERSHOP_CLOSE_RESTART")
                -- pvp_mine:SetEventScript(ui.LBUTTONUP, "REQ_PVP_MINE_SHOP_OPEN")
                pvp_mine:SetEventScript(ui.LBUTTONUP, "MINIMIZED_PVPMINE_SHOP_BUTTON_CLICK")
                -- MINIMIZED_PVPMINE_SHOP_BUTTON_CLICK
            elseif key_name == "market" then
                if g.get_map_type() == "City" then
                    local market = frame:CreateOrGetControl("button", "market", x, 6, 29, 29);
                    AUTO_CAST(market)
                    market:SetSkinName("None")
                    market:SetText("{img market_shortcut_btn02 29 29}")
                    market:SetTextTooltip(g.lang == "Japanese" and "{ol}マーケット" or "{ol}Market")
                    market:SetEventScript(ui.LBUTTONUP, "MINIMIZED_MARKET_BUTTON_CLICK")
                end
            elseif key_name == "craft" then
                if g.get_map_type() == "City" then
                    local craft = frame:CreateOrGetControl("button", "craft", x, 5, 29, 29);
                    AUTO_CAST(craft)
                    craft:SetSkinName("None")
                    craft:SetText("{img icon_fullscreen_menu_equipment_processing 28 28}")
                    craft:SetTextTooltip(g.lang == "Japanese" and "{ol}装備加工" or "{ol}Equipment Processing")
                    craft:SetEventScript(ui.LBUTTONUP, "FULLSCREEN_NAVIGATION_MENU_DEATIL_EQUIPMENT_PROCESSING_NPC")
                end
            elseif key_name == "leticia" then
                if g.get_map_type() == "City" then
                    local leticia = frame:CreateOrGetControl("button", "leticia", x, 5, 29, 29);
                    AUTO_CAST(leticia)
                    leticia:SetSkinName("None")
                    leticia:SetText("{img icon_fullscreen_menu_letica 28 28}")
                    leticia:SetTextTooltip(g.lang == "Japanese" and "{ol}レティーシャへ移動" or
                                               "{ol}Leticia Move")
                    leticia:SetEventScript(ui.LBUTTONUP, "indun_panel_FULLSCREEN_NAVIGATION_MENU_DETAIL_MOVE_NPC")
                    leticia:SetEventScriptArgNumber(ui.LBUTTONUP, 309)
                end
            end
            x = x + 30
        end
    end

    frame:Resize(x, 40)
    frame:ShowWindow(1)

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
    closeBtn:SetEventScript(ui.LBUTTONUP, "indun_panel_frame_init");

    local button = frame:CreateOrGetControl("button", "indun_panel_open", 5, 5, 80, 30)
    AUTO_CAST(button)
    button:SetText("{ol}{s10}INDUNPANEL")
    button:SetEventScript(ui.LBUTTONUP, "indun_panel_frame_init")

    --[[local zoomedit = frame:CreateOrGetControl('edit', 'zoomedit', 100, 5, 50, 30)
    AUTO_CAST(zoomedit)
    zoomedit:SetText("{ol}" .. g.settings.zoom)
    zoomedit:SetFontName("white_16_ol")
    zoomedit:SetTextAlign("center", "center")
    zoomedit:SetEventScript(ui.ENTERKEY, "indun_panel_autozoom_save")
    local zoomtxt = g.lang == "Japanese" and
                        "{ol}1～700の値で入力。標準は336。マップ切り替え時に入力の値までZoomします。0入力で機能無効化。" or
                        "{ol}Input a value from 0 to 700. Standard is 336. Zoom to the input value when switching maps.{nl}Disable function by inputting 0."
    zoomedit:SetTextTooltip("Auto Zoom Setting{nl}" .. zoomtxt)]]

    local position = frame:CreateOrGetControl("button", "position", 160, 5, 60, 30)
    AUTO_CAST(position)
    position:SetText("{ol}{s10}BASE POS MOVE")
    position:SetEventScript(ui.LBUTTONUP, "indun_panel_frame_base_position")

    ---ここから

    local config_x = 15
    local tosshop = frame:CreateOrGetControl("checkbox", "tosshop", config_x, 47, 25, 25);
    AUTO_CAST(tosshop)
    tosshop:SetText("{img icon_item_Tos_Event_Coin 25 25}")
    tosshop:SetEventScript(ui.LBUTTONUP, "indun_panel_ischecked")
    tosshop:SetEventScriptArgString(ui.LBUTTONUP, "config")
    tosshop:SetTextTooltip(g.lang == "Japanese" and "{ol}チェックすると常に表示" or
                               "{ol}Always visible when checked")
    tosshop:SetCheck(g.settings.cols.tos)
    config_x = config_x + tosshop:GetWidth() + 5

    local gabija = frame:CreateOrGetControl("checkbox", "gabija", config_x, 47, 29, 29);
    AUTO_CAST(gabija)
    gabija:SetText("{img goddess_shop_btn 29 29}")
    gabija:SetEventScript(ui.LBUTTONUP, "indun_panel_ischecked")
    gabija:SetEventScriptArgString(ui.LBUTTONUP, "config")
    gabija:SetTextTooltip(g.lang == "Japanese" and "{ol}チェックすると常に表示" or
                              "{ol}Always visible when checked")
    gabija:SetCheck(g.settings.cols.gabija)
    config_x = config_x + gabija:GetWidth() + 5

    local vakarine = frame:CreateOrGetControl("checkbox", "vakarine", config_x, 47, 29, 29);
    AUTO_CAST(vakarine)
    vakarine:SetText("{img goddess2_shop_btn 29 29}")
    vakarine:SetEventScript(ui.LBUTTONUP, "indun_panel_ischecked")
    vakarine:SetEventScriptArgString(ui.LBUTTONUP, "config")
    vakarine:SetTextTooltip(g.lang == "Japanese" and "{ol}チェックすると常に表示" or
                                "{ol}Always visible when checked")
    vakarine:SetCheck(g.settings.cols.vakarine)
    config_x = config_x + vakarine:GetWidth() + 5

    local rada = frame:CreateOrGetControl("checkbox", "rada", config_x, 47, 29, 29);
    AUTO_CAST(rada)
    rada:SetText("{img goddess3_shop_btn 29 29}")
    rada:SetEventScript(ui.LBUTTONUP, "indun_panel_ischecked")
    rada:SetEventScriptArgString(ui.LBUTTONUP, "config")
    rada:SetTextTooltip(g.lang == "Japanese" and "{ol}チェックすると常に表示" or
                            "{ol}Always visible when checked")
    rada:SetCheck(g.settings.cols.rada)
    config_x = config_x + rada:GetWidth() + 5

    local jurate = frame:CreateOrGetControl("checkbox", "jurate", config_x, 47, 29, 29);
    AUTO_CAST(jurate)
    jurate:SetText("{img goddess4_shop_btn 29 29}")
    jurate:SetEventScript(ui.LBUTTONUP, "indun_panel_ischecked")
    jurate:SetEventScriptArgString(ui.LBUTTONUP, "config")
    jurate:SetTextTooltip(g.lang == "Japanese" and "{ol}チェックすると常に表示" or
                              "{ol}Always visible when checked")
    jurate:SetCheck(g.settings.cols.jurate)
    config_x = config_x + jurate:GetWidth() + 5

    local austeja = frame:CreateOrGetControl("checkbox", "austeja", config_x, 47, 29, 29);
    AUTO_CAST(austeja)
    austeja:SetText("{img goddess5_shop_btn 29 29}")
    austeja:SetEventScript(ui.LBUTTONUP, "indun_panel_ischecked")
    austeja:SetEventScriptArgString(ui.LBUTTONUP, "config")
    austeja:SetTextTooltip(g.lang == "Japanese" and "{ol}チェックすると常に表示" or
                               "{ol}Always visible when checked")
    austeja:SetCheck(g.settings.cols.austeja)
    config_x = config_x + austeja:GetWidth() + 5

    local pvp_mine = frame:CreateOrGetControl("checkbox", "pvp_mine", config_x, 47, 29, 29);
    AUTO_CAST(pvp_mine)
    pvp_mine:SetText("{img pvpmine_shop_btn_total 29 29}")
    pvp_mine:SetEventScript(ui.LBUTTONUP, "indun_panel_ischecked")
    pvp_mine:SetEventScriptArgString(ui.LBUTTONUP, "config")
    pvp_mine:SetTextTooltip(g.lang == "Japanese" and "{ol}チェックすると常に表示" or
                                "{ol}Always visible when checked")
    pvp_mine:SetCheck(g.settings.cols.pvp_mine)
    config_x = config_x + pvp_mine:GetWidth() + 5

    local market = frame:CreateOrGetControl("checkbox", "market", config_x, 47, 29, 29);
    AUTO_CAST(market)
    market:SetText("{img market_shortcut_btn02 29 29}")
    market:SetEventScript(ui.LBUTTONUP, "indun_panel_ischecked")
    market:SetEventScriptArgString(ui.LBUTTONUP, "config")
    market:SetTextTooltip(g.lang == "Japanese" and "{ol}チェックすると常に表示" or
                              "{ol}Always visible when checked")
    market:SetCheck(g.settings.cols.market)
    config_x = config_x + market:GetWidth() + 5

    local craft = frame:CreateOrGetControl("checkbox", "craft", config_x, 47, 29, 29);
    AUTO_CAST(craft)
    craft:SetText("{img icon_fullscreen_menu_equipment_processing 28 28}")
    craft:SetEventScript(ui.LBUTTONUP, "indun_panel_ischecked")
    craft:SetEventScriptArgString(ui.LBUTTONUP, "config")
    craft:SetTextTooltip(g.lang == "Japanese" and "{ol}チェックすると常に表示" or
                             "{ol}Always visible when checked")
    craft:SetCheck(g.settings.cols.craft)
    config_x = config_x + craft:GetWidth() + 5

    local leticia = frame:CreateOrGetControl("checkbox", "leticia", config_x, 47, 29, 29);
    AUTO_CAST(leticia)
    leticia:SetText("{img icon_fullscreen_menu_letica 28 28}")
    leticia:SetEventScript(ui.LBUTTONUP, "indun_panel_ischecked")
    leticia:SetEventScriptArgString(ui.LBUTTONUP, "config")
    leticia:SetTextTooltip(g.lang == "Japanese" and "{ol}チェックすると常に表示" or
                               "{ol}Always visible when checked")
    leticia:SetCheck(g.settings.cols.leticia)
    config_x = config_x + leticia:GetWidth() + 5

    local label_line2 = frame:CreateControl('labelline', 'label_line2', 10, 77, config_x, 5);
    AUTO_CAST(label_line2)
    label_line2:SetSkinName("labelline2")

    local en_ver = frame:CreateOrGetControl('checkbox', 'en_ver', 25, 85, 25, 25)
    AUTO_CAST(en_ver)
    if g.settings.en_ver == nil then
        g.settings.en_ver = 0
        g.save_settings()
    end
    en_ver:SetCheck(g.settings.en_ver)
    en_ver:SetEventScript(ui.LBUTTONUP, "indun_panel_ischecked")
    en_ver:SetText(g.lang == "Japanese" and "{ol}チェックすると英語表示に変更します" or
                       "{ol}Check to display to English")

    local move = frame:CreateOrGetControl('checkbox', 'move', 25, 120, 25, 25)
    AUTO_CAST(move)
    if g.settings.move == nil then
        g.settings.move = 0
        g.save_settings()
    end
    move:SetCheck(g.settings.move)
    move:SetEventScript(ui.LBUTTONUP, "indun_panel_ischecked")
    move:SetText(g.lang == "Japanese" and "{ol}チェックするとフレームを動かせます" or
                     "{ol}Check to move the frame")

    local field_mode = frame:CreateOrGetControl('checkbox', 'field_mode', 25, 155, 25, 25)
    AUTO_CAST(field_mode)
    if g.settings.field_mode == nil then
        g.settings.field_mode = 0
        g.save_settings()
    end
    field_mode:SetCheck(g.settings.field_mode)
    field_mode:SetEventScript(ui.LBUTTONUP, "indun_panel_ischecked")
    field_mode:SetText(g.lang == "Japanese" and "{ol}チェックするとフィールドで表示" or
                           "{ol}Check to display in field")

    local label_line = frame:CreateControl('labelline', 'label_line', 10, 180, config_x, 5);
    AUTO_CAST(label_line)
    label_line:SetSkinName("labelline2")

    local posY_left = 185 -- 左の列のY座標
    local posY_right = 185 -- 右の列のY座標

    local count = #induntype
    local half_count = math.ceil(count / 2)

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

            checkbox:SetCheck(g.settings[key .. '_checkbox'])
            checkbox:SetEventScript(ui.LBUTTONUP, "indun_panel_ischecked")
            checkbox:SetText("{ol}{#FFFFFF}" .. INDUN_PANEL_LANG(key))
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

function indun_panel_frame_open(frame)

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

    local frame = ui.GetFrame("indun_panel")

    frame:SetPos(x, g.settings.y)
    frame:SetTitleBarSkin("None")
    frame:EnableHittestFrame(1)
    if not g.settings.move then
        g.settings.move = 0
    end
    frame:EnableMove(g.settings.move)
    if g.settings.move == 1 then
        frame:SetEventScript(ui.LBUTTONUP, "indun_panel_frame_drag")
    else
        frame:SetEventScript(ui.LBUTTONUP, "None")
    end
    frame:RemoveAllChild()

    local button = frame:CreateOrGetControl("button", "indun_panel_open", 5, 5, 80, 30)
    AUTO_CAST(button)
    button:SetText("{ol}{s10}INDUNPANEL")
    button:SetEventScript(ui.RBUTTONUP, "indun_panel_always_init")
    button:SetTextTooltip(g.lang == "Japanese" and "{ol}右クリック: 常時展開解除で閉じる" or
                              "{ol}Right click: Close with permanent unexpand")

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

    if #tooltip_parts > 0 then
        ccbtn:SetTextTooltip("{ol}" .. table.concat(tooltip_parts, "{nl}"))
    else
        ccbtn:SetTextTooltip(g.lang == "Japanese" and "{ol}バラックに戻ります" or "{ol}Return to Barracks")
    end

    function indun_panel_frame_base_position(frame, ctrl, str, num)
        frame:SetPos(665, 30)
        g.settings.x = 665
        g.settings.y = 30
        g.save_settings()
        indun_panel_frame_init()
    end
    frame:ShowWindow(1)

    local configbtn = frame:CreateOrGetControl('button', 'configbtn', 115, 5, 30, 30)
    AUTO_CAST(configbtn)
    configbtn:SetSkinName("None")
    configbtn:SetText("{img config_button_normal 30 30}")
    configbtn:SetEventScript(ui.LBUTTONUP, "indun_panel_config_gb_open")
    configbtn:SetTextTooltip(g.lang == "Japanese" and "{ol}Indun Panel 設定" or "{ol}Indun Panel Config")

    if configbtn:IsVisible() == 1 then
        button:SetEventScript(ui.LBUTTONUP, "indun_panel_frame_init")
    end

    local account_obj = GetMyAccountObj()
    local tooltip_msg = ""
    local coin_count = 0

    if g.get_map_type() == "City" then

        local market = frame:CreateOrGetControl("button", "market", 360, 6, 29, 29);
        AUTO_CAST(market)
        market:SetSkinName("None")
        market:SetText("{img market_shortcut_btn02 29 29}")
        market:SetTextTooltip(g.lang == "Japanese" and "{ol}マーケット" or "{ol}Market")
        market:SetEventScript(ui.LBUTTONUP, "MINIMIZED_MARKET_BUTTON_CLICK")

        local leticia = frame:CreateOrGetControl("button", "leticia", 420, 5, 29, 29);
        AUTO_CAST(leticia)
        leticia:SetSkinName("None")
        leticia:SetText("{img icon_fullscreen_menu_letica 28 28}")
        leticia:SetTextTooltip(g.lang == "Japanese" and "{ol}レティーシャへ移動" or "{ol}Leticia Move")
        leticia:SetEventScript(ui.LBUTTONUP, "indun_panel_FULLSCREEN_NAVIGATION_MENU_DETAIL_MOVE_NPC")
        leticia:SetEventScriptArgNumber(ui.LBUTTONUP, 309)

        local tosshop = frame:CreateOrGetControl("button", "tosshop", 150, 8, 25, 25);
        AUTO_CAST(tosshop)
        tosshop:SetSkinName("None")
        tosshop:SetText("{img icon_item_Tos_Event_Coin 25 25}")
        coin_count = GET_COMMAED_STRING(TryGetProp(account_obj, "EVENT_TOS_WHOLE_TOTAL_COIN", "0"))
        tooltip_msg = g.lang == "Japanese" and "{ol}TOSイベントショップ" or "{ol}TOS Event Shop"
        tosshop:SetTextTooltip(tooltip_msg)
        -- INDUN_PANEL_EARTHTOWERSHOP_CLOSE_RESTART
        tosshop:SetEventScript(ui.LBUTTONDOWN, "INDUN_PANEL_EARTHTOWERSHOP_CLOSE_RESTART")
        tosshop:SetEventScript(ui.LBUTTONUP, "indun_panel_event_tos_whole_shop_open")

        local gabija = frame:CreateOrGetControl("button", "gabija", 180, 7, 29, 29);
        AUTO_CAST(gabija)
        gabija:SetSkinName("None")
        gabija:SetText("{img goddess_shop_btn 29 29}")
        coin_count = GET_COMMAED_STRING(TryGetProp(account_obj, "GabijaCertificate", "0"))
        tooltip_msg = g.lang == "Japanese" and "{ol}ガビヤショップ{nl}" .. "{#FFFF00}" .. coin_count or
                          "{ol}Gabija Shop{nl}" .. "{#FFFF00}" .. coin_count
        gabija:SetTextTooltip(tooltip_msg)
        gabija:SetEventScript(ui.LBUTTONDOWN, "INDUN_PANEL_EARTHTOWERSHOP_CLOSE_RESTART")
        gabija:SetEventScript(ui.LBUTTONUP, "REQ_GabijaCertificate_SHOP_OPEN")

        local vakarine = frame:CreateOrGetControl("button", "vakarine", 210, 7, 29, 29);
        AUTO_CAST(vakarine)
        vakarine:SetSkinName("None")
        vakarine:SetText("{img goddess2_shop_btn 29 29}")
        coin_count = GET_COMMAED_STRING(TryGetProp(account_obj, "VakarineCertificate", "0"))
        tooltip_msg = g.lang == "Japanese" and "{ol}ヴァカリネショップ{nl}" .. "{#FFFF00}" .. coin_count or
                          "{ol}Vakarine Shop{nl}" .. "{#FFFF00}" .. coin_count
        vakarine:SetTextTooltip(tooltip_msg)
        vakarine:SetEventScript(ui.LBUTTONDOWN, "INDUN_PANEL_EARTHTOWERSHOP_CLOSE_RESTART")
        vakarine:SetEventScript(ui.LBUTTONUP, "REQ_VakarineCertificate_SHOP_OPEN")

        local rada = frame:CreateOrGetControl("button", "rada", 240, 8, 29, 29);
        AUTO_CAST(rada)
        rada:SetSkinName("None")
        rada:SetText("{img goddess3_shop_btn 29 29}")
        coin_count = GET_COMMAED_STRING(TryGetProp(account_obj, "RadaCertificate", "0"))
        tooltip_msg = g.lang == "Japanese" and "{ol}ラダショップ{nl}" .. "{#FFFF00}" .. coin_count or
                          "{ol}Rada Shop{nl}" .. "{#FFFF00}" .. coin_count
        rada:SetTextTooltip(tooltip_msg)
        rada:SetEventScript(ui.LBUTTONDOWN, "INDUN_PANEL_EARTHTOWERSHOP_CLOSE_RESTART")
        rada:SetEventScript(ui.LBUTTONUP, "REQ_RadaCertificate_SHOP_OPEN")

        local jurate = frame:CreateOrGetControl("button", "jurate", 270, 7, 29, 29);
        AUTO_CAST(jurate)

        jurate:SetSkinName("None")
        jurate:SetText("{img goddess4_shop_btn 29 29}")
        coin_count = GET_COMMAED_STRING(TryGetProp(account_obj, "JurateCertificate", "0"))
        tooltip_msg = g.lang == "Japanese" and "{ol}ユラテショップ{nl}" .. "{#FFFF00}" .. coin_count or
                          "{ol}Jurate Shop{nl}" .. "{#FFFF00}" .. coin_count
        jurate:SetTextTooltip(tooltip_msg)
        jurate:SetEventScript(ui.LBUTTONDOWN, "INDUN_PANEL_EARTHTOWERSHOP_CLOSE_RESTART")
        jurate:SetEventScript(ui.LBUTTONUP, "REQ_JurateCertificate_SHOP_OPEN")
    end

    local austeja = frame:CreateOrGetControl("button", "austeja", 300, 7, 29, 29);
    AUTO_CAST(austeja)
    if g.get_map_type() ~= "City" then
        austeja:SetOffset(150, 7)
    end
    austeja:SetSkinName("None")
    austeja:SetText("{img goddess5_shop_btn 29 29}")
    coin_count = GET_COMMAED_STRING(TryGetProp(account_obj, "AustejaCertificate", "0"))
    tooltip_msg = g.lang == "Japanese" and "{ol}アウステアショップ{nl}" .. "{#FFFF00}" .. coin_count or
                      "{ol}Austeja Shop{nl}" .. "{#FFFF00}" .. coin_count
    austeja:SetTextTooltip(tooltip_msg)
    austeja:SetEventScript(ui.LBUTTONDOWN, "INDUN_PANEL_EARTHTOWERSHOP_CLOSE_RESTART")
    austeja:SetEventScript(ui.LBUTTONUP, "REQ_AustejaCertificate_SHOP_OPEN")

    local pvp_mine = frame:CreateOrGetControl("button", "pvp_mine", 330, 7, 29, 29);
    AUTO_CAST(pvp_mine)
    if g.get_map_type() ~= "City" then
        pvp_mine:SetOffset(180, 7)
    end
    pvp_mine:SetSkinName("None")
    pvp_mine:SetText("{img pvpmine_shop_btn_total 29 29}")
    pvp_mine:SetTextTooltip(g.lang == "Japanese" and "{ol}傭兵団ショップ" or "{ol}Mercenary Shop")
    pvp_mine:SetEventScript(ui.LBUTTONDOWN, "INDUN_PANEL_EARTHTOWERSHOP_CLOSE_RESTART")
    -- pvp_mine:SetEventScript(ui.LBUTTONUP, "REQ_PVP_MINE_SHOP_OPEN")
    pvp_mine:SetEventScript(ui.LBUTTONUP, "MINIMIZED_PVPMINE_SHOP_BUTTON_CLICK")
    if g.get_map_type() == "City" then
        local craft = frame:CreateOrGetControl("button", "craft", 390, 5, 29, 29);
        AUTO_CAST(craft)
        craft:SetSkinName("None")
        craft:SetText("{img icon_fullscreen_menu_equipment_processing 28 28}")
        craft:SetTextTooltip(g.lang == "Japanese" and "{ol}装備加工" or "{ol}Equipment Processing")
        craft:SetEventScript(ui.LBUTTONUP, "FULLSCREEN_NAVIGATION_MENU_DEATIL_EQUIPMENT_PROCESSING_NPC")
    end

    local checkbox = frame:CreateOrGetControl('checkbox', 'checkbox', 715, 5, 30, 30)
    AUTO_CAST(checkbox)
    checkbox:SetCheck(g.settings.checkbox)
    checkbox:SetEventScript(ui.LBUTTONUP, "indun_panel_ischecked")
    checkbox:SetTextTooltip(g.lang == "Japanese" and "{ol}チェックすると常時展開" or "{ol}IsCheck AlwaysOpen")

    if g.settings.season_checkbox == nil then
        g.settings.season_checkbox = 1
        g.save_settings()
    end

    --[[function indun_panel_FIELD_BOSS_TIME_TAB_SETTING(frame)
        local frame = ui.GetFrame("induninfo")
        local field_boss_ranking_control = GET_CHILD_RECURSIVELY(frame, "field_boss_ranking_control")
        local now_time = geTime.GetServerSystemTime()
        local sub_tab = GET_CHILD_RECURSIVELY(field_boss_ranking_control, "sub_tab")

        local currentTime = os.time()
        -- 今日の日付を取得
        local today = os.date("*t", currentTime)
        -- 今日の12時5分
        local time12_5 = os.time({
            year = today.year,
            month = today.month,
            day = today.day,
            hour = 12,
            min = 5,
            sec = 0
        })
        -- 今日の22時5分
        local time22_5 = os.time({
            year = today.year,
            month = today.month,
            day = today.day,
            hour = 22,
            min = 5,
            sec = 0
        })
        if (time12_5 - currentTime) > 0 then
            sub_tab:SelectTab(0)
        else
            sub_tab:SelectTab(1)
        end
    end]]

    function indun_panel_FIELD_BOSS_TIME_TAB_SETTING()
        local frame = ui.GetFrame("induninfo")
        if not frame then
            return
        end

        local field_boss_ranking_control = GET_CHILD_RECURSIVELY(frame, "field_boss_ranking_control")
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

    indun_panel_frame_contents(frame)
    configbtn:RunUpdateScript("indun_panel_frame_contents", 1.0)

end

function indun_panel_get_entrance_count(indun_type, index)

    local return_str = ""
    if index == 2 then
        return_str = string.format("{ol}{#FFFFFF}{s16}(%d/%d)",
            GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", indun_type).PlayPerResetType),
            GET_INDUN_MAX_ENTERANCE_COUNT(GetClassByType("Indun", indun_type).PlayPerResetType))
    elseif index == 1 then
        return_str = string.format("{ol}{#FFFFFF}{s16}(%d)",
            GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", indun_type).PlayPerResetType))
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
        return_str = string.format("{ol}{#FFFFFF}{s16}(%d/%d)", count,
            GET_INDUN_MAX_ENTERANCE_COUNT(GetClassByType("Indun", indun_type).PlayPerResetType))
    elseif index == 4 then
        if indun_type == 1001 then
            return tonumber(GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", indun_type).PlayPerResetType))
        elseif indun_type == 1004 or indun_type == 1005 or indun_type == 2000 or indun_type == 2001 then
            local acc_obj = GetMyAccountObj()
            local etc = GetMyEtcObject();
            local cls = GetClassByType("Indun", indun_type)
            local class_name = TryGetProp(cls, 'ClassName', 'None')

            if cls ~= nil and string.find(class_name, 'Challenge_') ~= nil then
                local UnitPerReset = TryGetProp(cls, 'UnitPerReset', 'None')

                if UnitPerReset ~= 'None' then
                    local name = TryGetProp(cls, 'CheckCountName', 'None')
                    local ticket_type = TryGetProp(cls, 'TicketingType', 'None')

                    if UnitPerReset == 'ACCOUNT' then
                        return TryGetProp(acc_obj, name, 0)
                    elseif UnitPerReset == 'PC' then
                        return TryGetProp(etc, name, 0)
                    end
                end
            end
        end

    end

    return return_str
end

function indun_panel_item_use(frame, ctrl, str, indun_type)

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

--[[function indun_panel_item_use_sin(frame, ctrl, enterance_count, indun_type)

    enterance_count = tonumber(enterance_count)
    if enterance_count > 0 then
        return
    end

    local ticket_priority_list = {}
    if indun_type == 2000 then

        ticket_priority_list = { -- 【優先度1】期限が近い、ヤバいやつ
        {
            classid = 10820018,
            check_lifetime = true,
            is_urgent = true
        }, {
            classid = 11030067,
            check_lifetime = true,
            is_urgent = true
        }, -- 【優先度2】期限があるけど、まだ余裕なやつ
        {
            classid = 10820018,
            check_lifetime = true,
            is_urgent = false
        }, {
            classid = 11030067,
            check_lifetime = true,
            is_urgent = false
        }, -- 【優先度3】期限がない、いつでも使えるやつ
        {
            classid = 10000470,
            check_lifetime = false
        }, {
            classid = 11030021,
            check_lifetime = false
        }, {
            classid = 11030017,
            check_lifetime = false
        }}
    elseif indun_type == 2001 then
        ticket_priority_list = { -- 【優先度1】期限が近い、ヤバいやつ
        {
            classid = 11201303,
            check_lifetime = true,
            is_urgent = true
        }, {
            classid = 11201304,
            check_lifetime = true,
            is_urgent = true
        }, {
            classid = 11201302,
            check_lifetime = false
        }, {
            classid = 11201301,
            check_lifetime = false
        }}
    end
    session.ResetItemList()

    for _, ticket_info in ipairs(ticket_priority_list) do
        local use_item = session.GetInvItemByType(ticket_info.classid)
        if use_item then
            if ticket_info.check_lifetime then
                local life_time = tonumber(GET_REMAIN_ITEM_LIFE_TIME(GetIES(use_item:GetObject())))
                if life_time then
                    if ticket_info.is_urgent and life_time < 86400 then
                        indun_panel_item_use_and_run(use_item, indun_type)
                        return
                    elseif not ticket_info.is_urgent then

                        indun_panel_item_use_and_run(use_item, indun_type)
                        return
                    end
                end
            else

                indun_panel_item_use_and_run(use_item, indun_type)
                return

            end
        end
    end

    if indun_type == 2000 then
        local mcount = INDUN_PANEL_GET_RECIPE_TRADE_COUNT("EVENT_TOS_WHOLE_SHOP_314")
        if mcount >= 1 then
            INDUN_PANEL_ITEM_BUY_USE("EVENT_TOS_WHOLE_SHOP_314", indun_type)
            return
        end
    elseif indun_type == 2001 then

        local day_count = INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_41")
        if day_count >= 1 then
            INDUN_PANEL_ITEM_BUY_USE("PVP_MINE_41", indun_type)
            return
        end

        local week_count = INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_42")
        if week_count >= 1 then
            INDUN_PANEL_ITEM_BUY_USE("PVP_MINE_42", indun_type)
            return
        end
    end
end]]

function indun_panel_singularity_frame(frame, key, y, value)

    local btn_520 = frame:CreateOrGetControl('button', "btn_520", 135, y, 60, 30)
    AUTO_CAST(btn_520)
    btn_520:SetText("{ol}{#FFD900}520")
    btn_520:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_singularity")
    btn_520:SetEventScriptArgNumber(ui.LBUTTONUP, value.singularity_520)

    local count_520 = frame:CreateOrGetControl("richtext", "count_520", 200, y + 5, 30, 30)
    count_520:SetText("{ol}(" .. indun_panel_get_entrance_count(value.singularity_520, 4) .. ")")

    local ticket_520 = frame:CreateOrGetControl('button', key .. 'ticket_520', 230, y, 80, 30)
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

    local buy_count_520 = frame:CreateOrGetControl("richtext", key .. "buy_count_520", 320, y + 5, 40, 30)
    buy_count_520:SetText("{ol}{s16}({img icon_item_Tos_Event_Coin 15 15}" ..
                              INDUN_PANEL_GET_RECIPE_TRADE_COUNT("EVENT_TOS_WHOLE_SHOP_314") .. ")")

    local btn_540 = frame:CreateOrGetControl('button', "btn_540", 380, y, 60, 30)
    AUTO_CAST(btn_540)
    btn_540:SetText("{ol}{#FFD900}540")
    btn_540:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_singularity")
    btn_540:SetEventScriptArgNumber(ui.LBUTTONUP, value.singularity_540)

    local count_540 = frame:CreateOrGetControl("richtext", "count_540", 445, y + 5, 30, 30)
    count_540:SetText("{ol}(" .. indun_panel_get_entrance_count(value.singularity_540, 4) .. ")")

    local ticket_540 = frame:CreateOrGetControl('button', key .. 'ticket_540', 475, y, 80, 30)
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

    local buy_count_540 = frame:CreateOrGetControl("richtext", key .. "buy_count_540", 565, y + 5, 40, 30)
    buy_count_540:SetText("{ol}{#FFFFFF}{s16}({img pvpmine_shop_btn_total 18 18}d:" ..
                              INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_41") .. " w:" ..
                              INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_42") .. ")")

    local auto_check = frame:CreateOrGetControl("checkbox", key .. "auto_check", 665, y, 25, 25)
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
    if indun_type == 1001 then
        local enterance_count = indun_panel_get_entrance_count(indun_type, 4)
        if enterance_count == 1 then
            indun_panel_challenge_low(indun_type)
        end
    elseif indun_type == 1005 or indun_type == 1004 then
        local enterance_count = indun_panel_get_entrance_count(indun_type, 4)
        if enterance_count == 0 then
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

    if indun_panel_use_simple_ticket(non_expiring_tickets, enter_mode, indun_type) then
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

--[[function indun_panel_challenge_item_use(indun_panel, ctrl, str, indun_type)

    if indun_type == 1001 then
        local enterance_count = indun_panel_get_entrance_count(indun_type, 4)

        if enterance_count == 1 then

            local ticket_table = {10820019, 11030080, 641954, 641969, 641955, 10000073}

            session.ResetItemList()
            local candidate_tickets = {}

            for _, classid in ipairs(ticket_table) do
                local use_item = session.GetInvItemByType(classid)
                if use_item ~= nil then
                    local life_time_str = GET_REMAIN_ITEM_LIFE_TIME(GetIES(use_item:GetObject()))
                    local life_time = tonumber(life_time_str)
                    local priority = 0

                    if life_time == nil then
                        priority = 3
                    elseif life_time < 86400 then
                        priority = 1
                    else
                        priority = 2
                    end

                    table.insert(candidate_tickets, {
                        item = use_item,
                        priority = priority
                    })
                end
            end

            if #candidate_tickets > 0 then
                table.sort(candidate_tickets, function(a, b)
                    return a.priority < b.priority
                end)

                local use_ticket = candidate_tickets[1].item
                INV_ICON_USE(use_ticket)
                indun_panel_enter_reserve(1, indun_type)
                return
            end

            local event_trade_count = INDUN_PANEL_GET_RECIPE_TRADE_COUNT("EVENT_TOS_WHOLE_SHOP_315")
            if event_trade_count >= 1 then
                INDUN_PANEL_ITEM_BUY_USE("EVENT_TOS_WHOLE_SHOP_315", indun_type)
                indun_panel_enter_reserve(1, indun_type)
                return
            end

        end
    elseif indun_type == 1005 or indun_type == 1004 then

        local enterance_count = indun_panel_get_entrance_count(indun_type, 4)

        if enterance_count == 0 then
            local ticket_table = {11201299, 11201300, 11201298, 11201297}

            session.ResetItemList()
            local candidate_tickets = {}

            for _, classid in ipairs(ticket_table) do
                local use_item = session.GetInvItemByType(classid)
                if use_item ~= nil then
                    local life_time_str = GET_REMAIN_ITEM_LIFE_TIME(GetIES(use_item:GetObject()))
                    local life_time = tonumber(life_time_str)
                    local priority = 0

                    if life_time == nil then
                        priority = 3
                    elseif life_time < 86400 then
                        priority = 1
                    else
                        priority = 2
                    end

                    table.insert(candidate_tickets, {
                        item = use_item,
                        priority = priority
                    })
                end
            end

            if #candidate_tickets > 0 then
                table.sort(candidate_tickets, function(a, b)
                    return a.priority < b.priority
                end)

                local use_ticket = candidate_tickets[1].item
                INV_ICON_USE(use_ticket)
                if str == "SOLO" then
                    indun_panel_enter_reserve(1, indun_type)
                else
                    indun_panel_enter_reserve(2, indun_type)
                end

                return
            end

            local trade_count = INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_40")
            if trade_count >= 1 then
                INDUN_PANEL_ITEM_BUY_USE("PVP_MINE_40", indun_type)
                if str == "SOLO" then
                    indun_panel_enter_reserve(1, indun_type)
                else
                    indun_panel_enter_reserve(2, indun_type)
                end
                return
            elseif trade_count <= 0 then
                local account_obj = GetMyAccountObj()
                local recipe_cls = GetClass('ItemTradeShop', "PVP_MINE_40")
                local over_max = TryGetProp(recipe_cls, 'MaxOverBuyCount', 0)
                local over_prop = TryGetProp(recipe_cls, 'OverBuyProperty', 'None')
                local over_count = TryGetProp(account_obj, over_prop, 0)
                local overbuy_count = tonumber(over_max) - tonumber(over_count)

                if overbuy_count > 0 then
                    local msg = g.lang == "Japanese" and "{img pvpmine_shop_btn_total 29 29} " ..
                                    (1100 + over_count * 100) .. " 使用しました" or
                                    "{img pvpmine_shop_btn_total 29 29} " .. (1100 + over_count * 100) .. " Used"
                    ui.SysMsg(msg)
                    INDUN_PANEL_ITEM_BUY_USE("PVP_MINE_40", indun_type)
                    if str == "SOLO" then
                        indun_panel_enter_reserve(1, indun_type)
                    else
                        indun_panel_enter_reserve(2, indun_type)
                    end
                    return
                end
            end

        end
    end
end]]

function indun_panel_challenge_frame(indun_panel, key, y, value)

    local solo_520 = indun_panel:CreateOrGetControl('button', key .. 'solo_520', 135, y, 60, 30)
    AUTO_CAST(solo_520)
    solo_520:SetText("{ol}520")
    solo_520:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_challenge")
    solo_520:SetEventScriptArgString(ui.LBUTTONUP, "1")
    solo_520:SetEventScriptArgNumber(ui.LBUTTONUP, value.solo_520)

    local count_520 = indun_panel:CreateOrGetControl("richtext", key .. "count_520", 200, y + 5, 20, 30)
    count_520:SetText(indun_panel_get_entrance_count(value.solo_520, 2))

    local ticket_520 = indun_panel:CreateOrGetControl('button', 'ticket_520', 245, y, 80, 30)
    AUTO_CAST(ticket_520)
    ticket_520:SetText("{img icon_item_Tos_Event_Coin 13 13}{ol}{#EE7800}{s14}BUYUSE")
    ticket_520:SetEventScript(ui.LBUTTONUP, "indun_panel_challenge_item_use")
    ticket_520:SetEventScriptArgNumber(ui.LBUTTONUP, value.solo_520)
    local tooltip_text = g.lang == "Japanese" and
                             "優先順位{nl}1.24時間以内の期限付きチケット{nl}2.期限付きチケット{nl}" ..
                             "3.期限のないイベントチケット{nl}4.{img icon_item_Tos_Event_Coin 20 20}チケット(買って使います){nl}" or
                             "Priority{nl}1.Limited-time tickets (under 24 hours){nl}" .. "2.Limited-time tickets{nl}" ..
                             "3.Event tickets without an expiration date{nl}" ..
                             "4.{img icon_item_Tos_Event_Coin 20 20} Tickets (buy and use these)"
    ticket_520:SetTextTooltip("{ol}" .. tooltip_text)

    local tos_shop_count = indun_panel:CreateOrGetControl("richtext", "tos_shop_count", 335, y + 5, 20, 30)
    tos_shop_count:SetText("{ol}{s16}({img icon_item_Tos_Event_Coin 15 15}" ..
                               INDUN_PANEL_GET_RECIPE_TRADE_COUNT("EVENT_TOS_WHOLE_SHOP_315") .. ")")

    local solo_540 = indun_panel:CreateOrGetControl('button', key .. 'solo_540', 395, y, 60, 30)
    AUTO_CAST(solo_540)
    solo_540:SetText("{ol}540")
    solo_540:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_challenge")
    solo_540:SetEventScriptArgString(ui.LBUTTONUP, "1")
    solo_540:SetEventScriptArgNumber(ui.LBUTTONUP, value.solo_540)

    local pt_btn = indun_panel:CreateOrGetControl('button', key .. 'pt_btn', 460, y, 60, 30)
    AUTO_CAST(pt_btn)
    pt_btn:SetText("{ol}{#FFD900}PT")
    pt_btn:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_challenge")
    pt_btn:SetEventScriptArgString(ui.LBUTTONUP, "2")
    pt_btn:SetEventScriptArgNumber(ui.LBUTTONUP, value.pt_540)

    local count = indun_panel:CreateOrGetControl("richtext", key .. "count", 525, y + 5, 40, 30)
    -- print(tostring(indun_panel_get_entrance_count(value.pt_540, 3)))
    count:SetText(indun_panel_get_entrance_count(value.pt_540, 3))

    local ticket_540 = indun_panel:CreateOrGetControl('button', 'ticket_540', 570, y, 80, 30)
    AUTO_CAST(ticket_540)
    ticket_540:SetText("{img pvpmine_shop_btn_total 14 14}{ol}{#EE7800}{s14}BUYUSE")
    ticket_540:SetEventScript(ui.LBUTTONUP, "indun_panel_challenge_item_use")
    ticket_540:SetEventScriptArgNumber(ui.LBUTTONUP, value.pt_540)

    ticket_540:SetEventScript(ui.RBUTTONUP, "indun_panel_challenge_item_use")
    ticket_540:SetEventScriptArgNumber(ui.RBUTTONUP, value.solo_540)
    ticket_540:SetEventScriptArgString(ui.RBUTTONUP, "SOLO")

    local tooltip = g.lang == "Japanese" and "{ol}左クリック: PT入場{nl}右クリック: ソロ入場{nl}" ..
                        "優先順位{nl}1.24時間以内の期限付きチケット{nl}2.期限付きチケット{nl}" ..
                        "3.期限のないチケット{nl}4.{img pvpmine_shop_btn_total 20 20}チケット(買って使います)" or
                        "{ol}Left-click: Enter party{nl}Right-click: Enter solo{nl}" ..
                        "Priority{nl}1.Limited-time tickets (under 24 hours){nl}" .. "2.Limited-time tickets{nl}" ..
                        "3.Tickets without an expiration date{nl}" ..
                        "4.{img pvpmine_shop_btn_total 20 20} Tickets (buy and use these)"
    ticket_540:SetTextTooltip(tooltip)

    local ticket_count = indun_panel:CreateOrGetControl("richtext", key .. "ticket_count", 660, y + 5, 40, 30)
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

function indun_panel_frame_contents(frame)

    local frame = ui.GetFrame("indun_panel")
    local account_obj = GetMyAccountObj()
    local tos_coin_count = GET_CHILD_RECURSIVELY(frame, "tos_coin_count")
    if tos_coin_count ~= nil then
        local coin_count = GET_COMMAED_STRING(TryGetProp(account_obj, "EVENT_TOS_WHOLE_TOTAL_COIN", "0"))
        tos_coin_count:SetText(string.format("{ol}{#FFD900}{s18}%s", coin_count))
    end
    local pvpminecount = GET_CHILD_RECURSIVELY(frame, "pvpminecount")
    if pvpminecount ~= nil then
        local coin_count = GET_COMMAED_STRING(TryGetProp(account_obj, "MISC_PVP_MINE2", "0"))
        pvpminecount:SetText(string.format("{ol}{#FFD900}{s18}%s", coin_count))
    end

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

    local y = 40
    local x = 135
    local count = #induntype
    for i = 1, count do
        local entry = induntype[i]
        for key, value in pairs(entry) do
            -- print(tostring(key))
            if g.settings[key .. "_checkbox"] == 1 then
                local text = frame:CreateOrGetControl("richtext", key, x - 125, y + 5)
                text:SetText("{ol}{#FFFFFF}" .. INDUN_PANEL_LANG(key))
                text:AdjustFontSizeByWidth(120)
                if type(value) == "table" then
                    -- veliora_checkbox = 1,
                    -- redania_checkbox = 1,
                    if key == "slogutis" or key == "upinis" or key == "roze" or key == "falouros" or key == "spreader" or
                        key == "merregina" or key == "neringa" or key == "golem" or key == "redania" or key == "veliora" or
                        key == "limara" then

                        function indun_panel_create_frame_onsweep(frame, key, subKey, subValue, y, x)

                            function indun_panel_autosweep(frame, ctrl, argStr, induntype)

                                local buffID = buffIDs[induntype]

                                local sweepcount = indun_panel_sweep_count(buffID)
                                if sweepcount >= 1 then
                                    ReqUseRaidAutoSweep(induntype)
                                else
                                    if not string.find(argStr, "use") then
                                        ui.SysMsg(g.lang == "Japanese" and "掃討バフがありません。" or
                                                      "There is no autoclear buff.")
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

                            local invItemList = session.GetInvItemList()
                            local guidList = invItemList:GetGuidList()
                            local cnt = guidList:Count()

                            if raidTable[subValue] then

                                local use = frame:CreateOrGetControl('button', key .. "use", x + 470, y, 80, 30)

                                AUTO_CAST(use)
                                use:SetText("{ol}{#EE7800}USE")

                                local count = 0
                                for _, targetClassID in ipairs(raidTable[subValue]) do
                                    for i = 0, cnt - 1 do
                                        local itemobj = GetIES(invItemList:GetItemByGuid(guidList:Get(i)):GetObject())
                                        local invItem = invItemList:GetItemByGuid(guidList:Get(i))
                                        if itemobj.ClassID == targetClassID then
                                            count = count + invItem.count
                                        end
                                    end
                                end

                                local itemClass = GetClassByType('Item', raidTable[subValue][2])
                                local icon = itemClass.Icon
                                local text = g.lang == "Japanese" and
                                                 string.format("{ol}{img %s 25 25 } %d個持っています。", icon,
                                        count) or
                                                 string.format("{ol}{img %s 25 25 } Quantity in Inventory", icon, count)

                                function indun_panel_raid_itemuse(frame, ctrl, argStr, induntype)

                                    session.ResetItemList()
                                    local invItemList = session.GetInvItemList()
                                    local guidList = invItemList:GetGuidList()
                                    local cnt = guidList:Count()
                                    local targetItems = raidTable[induntype]
                                    local enter_count = GET_CURRENT_ENTERANCE_COUNT(
                                        GetClassByType("Indun", induntype).PlayPerResetType)
                                    local buffID = buffIDs[induntype]
                                    local sweep_count = indun_panel_sweep_count(buffID)

                                    if targetItems then
                                        for _, targetClassID in ipairs(targetItems) do
                                            for i = 0, cnt - 1 do
                                                local itemobj = GetIES(
                                                    invItemList:GetItemByGuid(guidList:Get(i)):GetObject())
                                                local classid = itemobj.ClassID

                                                if classid == targetClassID then

                                                    if enter_count == 2 and sweep_count >= 1 then
                                                        INV_ICON_USE(session.GetInvItemByType(tonumber(classid)))
                                                        ReserveScript(string.format(
                                                            "indun_panel_autosweep(nil,nil,'%s',%d)", ctrl:GetName(),
                                                            induntype), 0.2)
                                                        return
                                                    elseif enter_count == 2 and sweep_count == 0 then
                                                        INV_ICON_USE(session.GetInvItemByType(tonumber(classid)))
                                                        return
                                                    elseif enter_count <= 1 and sweep_count >= 1 then
                                                        ReserveScript(string.format(
                                                            "indun_panel_autosweep(nil,nil,'%s',%d)", ctrl:GetName(),
                                                            induntype), 0.2)
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
                                    ui.SysMsg(INDUN_PANEL_LANG("There are no ticket items in inventory."))
                                end

                                use:SetTextTooltip(text)
                                use:SetEventScript(ui.LBUTTONUP, "indun_panel_raid_itemuse")
                                use:SetEventScriptArgNumber(ui.LBUTTONUP, subValue)
                            end

                            local solo = frame:CreateOrGetControl('button', key .. "solo", x, y, 80, 30)
                            local auto = frame:CreateOrGetControl('button', key .. "auto", x + 85, y, 80, 30)
                            local count = frame:CreateOrGetControl("richtext", key .. "count", x + 170, y + 5, 50, 30)
                            local hard = frame:CreateOrGetControl('button', key .. "hard", x + 215, y, 80, 30)
                            local counthard = frame:CreateOrGetControl("richtext", key .. "counthard", x + 300, y + 5,
                                50, 30)
                            local sweep = frame:CreateOrGetControl('button', key .. "sweep", x + 350, y, 80, 30)
                            local sweepcount = frame:CreateOrGetControl("richtext", key .. "sweepcount", x + 435, y + 5,
                                50, 30)

                            solo:SetText("{ol}SOLO")
                            auto:SetText("{ol}{#FFD900}AUTO")
                            hard:SetText("{ol}{#FF0000}HARD")
                            sweep:SetText("{ol}{#00FF00}" .. "ACLEAR")

                            if subKey == "s" then
                                count:SetText(indun_panel_get_entrance_count(subValue, 2))
                                solo:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_solo")
                                solo:SetEventScriptArgNumber(ui.LBUTTONUP, subValue)
                            elseif subKey == "a" then
                                auto:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_auto")
                                auto:SetEventScriptArgNumber(ui.LBUTTONUP, subValue)
                                sweep:SetEventScript(ui.LBUTTONUP, "indun_panel_autosweep")
                                sweep:SetEventScriptArgNumber(ui.LBUTTONUP, subValue)
                            elseif subKey == "h" then
                                counthard:SetText(indun_panel_get_entrance_count(subValue, 2))
                                hard:SetEventScript(ui.LBUTTONDOWN, "indun_panel_enter_hard")
                                hard:SetEventScriptArgNumber(ui.LBUTTONDOWN, subValue)
                                hard:SetEventScriptArgString(ui.LBUTTONDOWN, "false")
                            elseif subKey == "ac" then

                                sweepcount:SetText("{ol}{#FFFFFF}{s16}(" .. indun_panel_sweep_count(subValue) .. ")")
                            end
                        end

                        for subKey, subValue in pairs(value) do
                            indun_panel_create_frame_onsweep(frame, key, subKey, subValue, y, x)
                        end
                    elseif key == "jellyzele" or key == "delmore" or key == "giltine" or key == "earring" then

                        function indun_panel_create_frame(frame, key, subKey, subValue, y)

                            local solo = frame:CreateOrGetControl('button', key .. "solo", 135, y, 80, 30)
                            local auto = frame:CreateOrGetControl('button', key .. "auto", 220, y, 80, 30)
                            local hard = frame:CreateOrGetControl('button', key .. "hard", 350, y, 80, 30)
                            local count = frame:CreateOrGetControl("richtext", key .. "count", 305, y + 5, 50, 30)
                            local counthard = frame:CreateOrGetControl("richtext", key .. "counthard", 435, y + 5, 50,
                                30)

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
                        for subKey, subValue in pairs(value) do
                            indun_panel_create_frame(frame, key, subKey, subValue, y)
                        end
                    elseif key == "challenge" then
                        indun_panel_challenge_frame(frame, key, y, value)
                    elseif key == "singularity" then
                        indun_panel_singularity_frame(frame, key, y, value)
                    end
                else

                    if key == "telharsha" then
                        function indun_panel_telharsha_frame(frame, key, y)

                            local btn = frame:CreateOrGetControl('button', key .. 'btn', 135, y, 80, 30)
                            btn:SetText("{ol}IN")
                            btn:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_solo")
                            btn:SetEventScriptArgNumber(ui.LBUTTONUP, value)

                            local count = frame:CreateOrGetControl("richtext", key .. "count", 220, y + 5)
                            count:SetText(indun_panel_get_entrance_count(value, 2))

                            local recipe_name = "EVENT_TOS_WHOLE_SHOP_306"
                            local change_count = INDUN_PANEL_GET_RECIPE_TRADE_COUNT(recipe_name)

                            local tos_shop_count = frame:CreateOrGetControl("richtext", key .. "tos_shop_count", 350,
                                y + 5, 20, 30)
                            tos_shop_count:SetText("{ol}{s16}({img icon_item_Tos_Event_Coin 15 15}" .. change_count ..
                                                       ")")

                            function indun_panel_enter_telharsha_solo()
                                ReqRaidAutoUIOpen(623)
                                ReqMoveToIndun(1, 0)
                            end

                            function indun_panel_buyuse_telharsha(frame, ctrl, recipename, indun_type)

                                local count = GET_CURRENT_ENTERANCE_COUNT(
                                    GetClassByType("Indun", indun_type).PlayPerResetType)

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
                                        if change_count >= 1 then
                                            INDUN_PANEL_ITEM_BUY_USE(recipename)
                                            ReserveScript("indun_panel_enter_telharsha_solo()", 2.0)
                                            return
                                        else
                                            ui.SysMsg(
                                                g.lang == "Japanese" and "トレード回数が足りません。" or
                                                    "No trade count.")
                                            return
                                        end
                                    end
                                else
                                    ReserveScript("indun_panel_enter_telharsha_solo()", 1.0)
                                    return
                                end
                            end

                            local ticket_btn = frame:CreateOrGetControl('button', key .. 'ticket_btn', 265, y, 80, 30)
                            AUTO_CAST(ticket_btn)
                            ticket_btn:SetText("{ol}{#EE7800}{s14}BUYUSE")
                            ticket_btn:SetEventScript(ui.LBUTTONUP, "indun_panel_buyuse_telharsha")
                            ticket_btn:SetEventScriptArgString(ui.LBUTTONUP, recipe_name)
                            ticket_btn:SetEventScriptArgNumber(ui.LBUTTONUP, value)

                        end
                        indun_panel_telharsha_frame(frame, key, y)
                    elseif key == "velnice" then
                        function indun_panel_velnice_frame(frame, key, y)

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

                            local btn = frame:CreateOrGetControl('button', key .. 'btn', 135, y, 80, 30)
                            AUTO_CAST(btn)
                            btn:SetText("{ol}IN")
                            btn:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_velnice_solo")

                            local count = frame:CreateOrGetControl("richtext", key .. "count", 220, y + 5, 50, 30)
                            count:SetText(indun_panel_get_entrance_count(value, 2))

                            local recipe_name = "PVP_MINE_52"
                            local change_count = INDUN_PANEL_GET_RECIPE_TRADE_COUNT(recipe_name)
                            if change_count < 0 then
                                change_count = 0
                            end

                            function indun_panel_buyuse_vel(frame, ctrl, recipename, indun_type)

                                local count = GET_CURRENT_ENTERANCE_COUNT(
                                    GetClassByType("Indun", indun_type).PlayPerResetType)

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
                                        ui.SysMsg(g.lang == "Japanese" and "トレード回数が足りません。" or
                                                      "No trade count.")
                                        return
                                    end
                                else
                                    ReserveScript("indun_panel_enter_velnice_solo()", 1.0)
                                    return
                                end
                            end

                            local ticket_btn = frame:CreateOrGetControl('button', key .. 'ticket_btn', 265, y, 80, 30)
                            AUTO_CAST(ticket_btn)
                            ticket_btn:SetText("{ol}{#EE7800}{s14}BUYUSE")
                            ticket_btn:SetEventScript(ui.LBUTTONUP, "indun_panel_buyuse_vel")
                            ticket_btn:SetEventScriptArgString(ui.LBUTTONUP, recipe_name)
                            ticket_btn:SetEventScriptArgNumber(ui.LBUTTONUP, value)

                            function indun_panel_overbuy_count(recipe_name)
                                local aObj = GetMyAccountObj()
                                local recipecls = GetClass('ItemTradeShop', recipe_name)
                                local overbuy_max = TryGetProp(recipecls, 'MaxOverBuyCount', 0)
                                local overbuy_prop = TryGetProp(recipecls, 'OverBuyProperty', 'None')
                                local overbuy_count = TryGetProp(aObj, overbuy_prop, 0)
                                return tonumber(overbuy_max) - tonumber(overbuy_count)
                            end

                            local change_text = frame:CreateOrGetControl("richtext", key .. "change_text", 350, y + 5,
                                60, 30)
                            change_text:SetText(string.format("{ol}{#FFFFFF}(%d/%d)", change_count,
                                indun_panel_overbuy_count(recipe_name)))

                            local amount = frame:CreateOrGetControl("richtext", key .. "amount", 415, y + 5, 50, 30)
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
                                                  string.format("{ol}{#FF0000}%s", GET_COMMAED_STRING(
                                        indun_panel_overbuy_amount(recipe_name))) .. "{ol}{#FFFFFF})"
                            end
                            amount:SetText(amount_text)

                        end
                        indun_panel_velnice_frame(frame, key, y)
                    elseif key == "cemetery" then
                        function indun_panel_cemetery_frame(frame, key, y)
                            local btn = frame:CreateOrGetControl('button', key .. 'btn', 135, y, 80, 30)
                            btn:SetText("{ol}490")
                            btn:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_solo")
                            btn:SetEventScriptArgNumber(ui.LBUTTONUP, value)

                            local count = frame:CreateOrGetControl("richtext", key .. "count", 220, y + 5)
                            count:SetText(indun_panel_get_entrance_count(value, 1))

                            local ticket_btn = frame:CreateOrGetControl('button', key .. 'ticket_btn', 250, y, 80, 30)
                            AUTO_CAST(ticket_btn)
                            ticket_btn:SetText("{ol}{#EE7800}{s14}USE")

                            local invItemList = session.GetInvItemList()
                            local guidList = invItemList:GetGuidList()
                            local cnt = guidList:Count()

                            local inv_count = 0
                            for i = 0, cnt - 1 do
                                local itemobj = GetIES(invItemList:GetItemByGuid(guidList:Get(i)):GetObject())
                                local invItem = invItemList:GetItemByGuid(guidList:Get(i))
                                if itemobj.ClassID == 11200276 or itemobj.ClassID == 11200275 or itemobj.ClassID ==
                                    11200274 then
                                    inv_count = inv_count + invItem.count
                                end
                            end

                            local item_class1 = GetClassByType('Item', 11200276)

                            local icon1 = item_class1.Icon

                            local ticket_notice = g.lang == "Japanese" and
                                                      string.format("{ol}{img %s 25 25 } %d個持っています。",
                                    icon1, inv_count) or
                                                      string.format("{ol}{img %s 25 25 } Quantity in Inventory", icon1,
                                    inv_count)

                            ticket_btn:SetTextTooltip(ticket_notice)
                            ticket_btn:SetEventScript(ui.LBUTTONUP, "indun_panel_item_use")
                            ticket_btn:SetEventScriptArgNumber(ui.LBUTTONUP, value)

                        end
                        indun_panel_cemetery_frame(frame, key, y)

                    elseif key == "demonlair" then

                        function indun_panel_demonlair_frame(frame, key, y)
                            local btn = frame:CreateOrGetControl('button', key .. 'btn', 135, y, 80, 30)
                            btn:SetText("{ol}540")
                            btn:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_solo")
                            btn:SetEventScriptArgNumber(ui.LBUTTONUP, value)

                            local count = frame:CreateOrGetControl("richtext", key .. "count", 220, y + 5)
                            count:SetText(indun_panel_get_entrance_count(value, 1))

                            local ticket_btn = frame:CreateOrGetControl('button', key .. 'ticket_btn', 250, y, 80, 30)
                            AUTO_CAST(ticket_btn)
                            ticket_btn:SetText("{ol}{#EE7800}{s14}USE")

                            local invItemList = session.GetInvItemList()
                            local guidList = invItemList:GetGuidList()
                            local cnt = guidList:Count()

                            local inv_count = 0
                            for i = 0, cnt - 1 do
                                local itemobj = GetIES(invItemList:GetItemByGuid(guidList:Get(i)):GetObject())
                                local invItem = invItemList:GetItemByGuid(guidList:Get(i))
                                if itemobj.ClassID == 11200484 or itemobj.ClassID == 11200485 or itemobj.ClassID ==
                                    11200486 then
                                    inv_count = inv_count + invItem.count
                                end
                            end

                            local item_class1 = GetClassByType('Item', 11200484)
                            local icon1 = item_class1.Icon

                            local ticket_notice = g.lang == "Japanese" and
                                                      string.format("{ol}{img %s 25 25 } %d個持っています。",
                                    icon1, inv_count) or
                                                      string.format("{ol}{img %s 25 25 } Quantity in Inventory", icon1,
                                    inv_count)

                            ticket_btn:SetTextTooltip(ticket_notice)
                            ticket_btn:SetEventScript(ui.LBUTTONUP, "indun_panel_item_use")
                            ticket_btn:SetEventScriptArgNumber(ui.LBUTTONUP, value)

                        end
                        indun_panel_demonlair_frame(frame, key, y)

                    elseif key == "jsr" then

                        --[[function indun_panel_FIELD_BOSS_ENTER_TIMER_SETTING(frame)

                            local function format_time(seconds)
                                local hours = math.floor(seconds / 3600)
                                local minutes = math.floor((seconds % 3600) / 60)
                                local seconds = seconds % 60

                                local japanese = string.format("%d時間%d分%d秒", hours, minutes, seconds)
                                local english = string.format("%d:%d:%d", hours, minutes, seconds)

                                return japanese, english
                            end

                            local currentTime = os.time()
                            local today = os.date("*t", currentTime)
                            local hour = today.hour
                            local min = today.min
                            local sec = today.sec
                            local todaysec = (hour * 3600) + (min * 60) + sec
                            local sec12 = 12 * 3600
                            local utilsec12 = sec12 - todaysec
                            local sec22 = 22 * 3600
                            local utilsec22 = sec22 - todaysec

                            local textstr = ""
                            if utilsec12 >= 0 then
                                local japanese, english = format_time(utilsec12)
                                textstr = g.settings.en_ver == 1 and english .. " After Start" or japanese ..
                                              ClMsg("After_Start");
                            elseif utilsec12 >= -300 then
                                local japanese, english = format_time(300 + utilsec12)
                                textstr = g.settings.en_ver == 1 and english .. " After Exit" or japanese ..
                                              ClMsg("After_Exit");
                            elseif utilsec22 >= 0 then
                                local japanese, english = format_time(utilsec22)
                                textstr = g.settings.en_ver == 1 and english .. " After Start" or japanese ..
                                              ClMsg("After_Start");
                            elseif utilsec22 >= -300 then
                                local japanese, english = format_time(300 + utilsec22)
                                textstr = g.settings.en_ver == 1 and english .. " After Exit" or japanese ..
                                              ClMsg("After_Exit");
                            else
                                textstr = g.settings.en_ver == 1 and "Already Exit" or ClMsg("Already_Exit");
                            end

                            local frame = ui.GetFrame("indun_panel")
                            local jsrbtn = GET_CHILD_RECURSIVELY(frame, "jsrbtn")
                            local y = jsrbtn:GetUserIValue("Y")
                            local jsrtime = frame:CreateOrGetControl("richtext", "jsrtime", 220, y + 5, 10, 10)
                            jsrtime:SetText("{ol}" .. textstr)
                            return 1
                        end]]

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

                            local _, _, _, hour_str, min_str, sec_str = server_time_str:match(
                                "(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)")
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
                                textstr = g.settings.en_ver == 1 and english .. " After Start" or japanese ..
                                              ClMsg("After_Start");
                            elseif utilsec12 >= -300 then
                                local japanese, english = format_time(300 + utilsec12)
                                textstr = g.settings.en_ver == 1 and english .. " After Exit" or japanese ..
                                              ClMsg("After_Exit");
                            elseif utilsec22 >= 0 then
                                local japanese, english = format_time(utilsec22)
                                textstr = g.settings.en_ver == 1 and english .. " After Start" or japanese ..
                                              ClMsg("After_Start");
                            elseif utilsec22 >= -300 then
                                local japanese, english = format_time(300 + utilsec22)
                                textstr = g.settings.en_ver == 1 and english .. " After Exit" or japanese ..
                                              ClMsg("After_Exit");
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
                            local jsrtime = frame:CreateOrGetControl("richtext", "jsrtime", 220, y + 5, 10, 10)
                            jsrtime:SetText("{ol}" .. textstr)

                            return 1
                        end

                        function indun_panel_jsr_frame(frame, key, y)

                            local jsrbtn = frame:CreateOrGetControl('button', 'jsrbtn', 135, y, 80, 30)
                            jsrbtn:SetText("{ol}JSR")
                            jsrbtn:SetEventScript(ui.LBUTTONUP, "FIELD_BOSS_JOIN_ENTER_CLICK")
                            jsrbtn:SetUserValue("Y", y)
                            indun_panel_FIELD_BOSS_ENTER_TIMER_SETTING(frame)
                            jsrbtn:RunUpdateScript("indun_panel_FIELD_BOSS_ENTER_TIMER_SETTING", 1.0)

                        end
                        indun_panel_jsr_frame(frame, key, y)
                    end
                end
                y = y + 33
            end
        end
    end

    local bonusTP_pic = frame:CreateOrGetControl("richtext", "bonusTP_pic", 320, y)
    AUTO_CAST(bonusTP_pic)
    bonusTP_pic:SetText("{img bonusTP_pic 22 22}")

    local accountObj = GetMyAccountObj();
    -- print(tostring(accountObj.Medal));

    local bonusTP_count = frame:CreateOrGetControl("richtext", "bonusTP_count", 350, y)
    AUTO_CAST(bonusTP_count)
    bonusTP_count:SetText("{ol}{#FFD900}{s18}" .. accountObj.Medal)
    bonusTP_count:SetTextTooltip("{ol}Free TP")

    if g.housing_point then
        local housing_btn = frame:CreateOrGetControl("richtext", "housing_btn", 370, y)
        AUTO_CAST(housing_btn)
        housing_btn:SetText("{img btn_housing_editmode_small_resize 23 23}")

        local housing_count = frame:CreateOrGetControl("richtext", "housing_count", 400, y)
        housing_count:SetText("{ol}{#FFD900}{s18}" .. g.housing_point)
        housing_count:SetTextTooltip("{ol}Housing Point")

        local housing_count = frame:CreateOrGetControl("richtext", "housing_count", 400, y)
        housing_count:SetText("{ol}{#FFD900}{s18}" .. g.housing_point)
        housing_count:SetTextTooltip("{ol}Housing Point")
    end

    local tos_coin = frame:CreateOrGetControl("richtext", "tos_coin", 450, y)
    tos_coin:SetText("{img icon_item_Tos_Event_Coin 21 21}")
    --[[local msg = g.lang == "Japanese" and "{ol}デイリーTOSコイン獲得量： " .. "{#FFD900}" ..
                    g.settings.toscoin or 0 or "{ol}Daily TOS Coin acquisition amount: " .. "{#FFD900}" ..
                    g.settings.toscoin or 0
    tos_coin:SetTextTooltip(msg)]]

    local tos_coin_count = frame:CreateOrGetControl("richtext", "tos_coin_count", 475, y)
    local coin_count = GET_COMMAED_STRING(TryGetProp(account_obj, "EVENT_TOS_WHOLE_TOTAL_COIN", "0"))

    --[[local msg = g.lang == "Japanese" and "{ol}デイリーTOSコイン獲得量： " .. "{#FFD900}" ..
                    GET_COMMAED_STRING(g.settings.toscoin) or 0 or "{ol}Daily TOS Coin acquisition amount: " ..
                    "{#FFD900}" .. GET_COMMAED_STRING(g.settings.toscoin) or 0]]
    tos_coin_count:SetText(string.format("{ol}{#FFD900}{s18}%s/%s", coin_count,
        "{#FFD900}" .. GET_COMMAED_STRING(g.settings.toscoin) or 0))
    -- tos_coin_count:SetTextTooltip(msg)

    local pvpmine = frame:CreateOrGetControl("richtext", "pvpmine", 605, y)
    pvpmine:SetText("{img pvpmine_shop_btn_total 25 25}")

    local pvpminecount = frame:CreateOrGetControl("richtext", "pvpminecount", 630, y)
    coin_count = GET_COMMAED_STRING(TryGetProp(account_obj, "MISC_PVP_MINE2", "0"))
    pvpminecount:SetText(string.format("{ol}{#FFD900}{s18}%s", coin_count))

    local version = frame:CreateOrGetControl("richtext", "ver", 15, y + 15)
    version:SetText(string.format("{ol}{#FFD900}{s13}ver: %s", ver))

    y = y + 35

    frame:SetLayerLevel(80)
    frame:Resize(x + 615, y)
    frame:SetSkinName("chat_window")
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

    if g.settings[ctrlname] then
        g.settings[ctrlname] = ischeck
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

    -- local msg, color = ...
    if msg then
        -- print("indun_panel: " .. tostring(msg) .. ":" .. tostring(color))
        local pattern = "EVENT_TOS_WHOLE_GET_SUCCESS_MSG"
        if string.find(msg, pattern) then
            local daily_value_str = msg:match("%$%*%$DAILY%$%*%$(%d+)%$%*%$")
            -- !@#$EVENT_TOS_WHOLE_GET_SUCCESS_MSG{GAIN}{DAILY}{DAILY_LIMIT}$*$GAIN$*$280$*$DAILY$*$1000$*$DAILY_LIMIT$*$2000#@!
            -- print("indun_panel: " .. tostring(daily_value_str))
            g.settings.toscoin = tonumber(daily_value_str)
            g.save_settings()

        end
    end
    -- g.FUNCS["CHAT_SYSTEM"](msg, "FFFF00")
    -- session.ui.GetChatMsg():AddSystemMsg(msg, true, 'System', "FFFF00")
end

function INDUN_PANEL_LANG(str)

    if g.settings.en_ver == 1 then
        if str == tostring("cemetery") then
            str = "wailing"
        end
        return "{s20}" .. str
    end

    if g.lang == "Japanese" then
        if str == tostring("veliora") then
            str = "ベリオラ"
        end
        if str == tostring("limara") then
            str = "ライマラ"
        end
        if str == tostring("redania") then
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
        if str == tostring("spreader") then
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
        if str == tostring("velnice") then
            str = "ヴェルニケ"
        end
        if str == tostring("giltine") then
            str = "ギルティネ"
        end
        if str == tostring("earring") then
            str = "焔の記憶"
        end
        -- if str == tostring("{s20}Wailing") then
        if str == tostring("cemetery") then
            str = "嘆きの墓地"
        end
        if str == tostring("ACLEAR") then
            str = "ACLEAR"
        end

        if str == tostring("demonlair") then
            str = "魔の巣窟"
        end

        if str == tostring("jsr") then
            str = "ボス協同戦"
        end
        if str == tostring("season") then
            str = "シーズンチャレンジ"
        end
        -- "I'll buy 4 Challenge Vouchers and craft a singularity Voucher"
        if str == "I'll buy 4 Challenge Vouchers{nl}craft a Singularity Voucher, and use it" then
            str = "チャレンジチケットを4枚買って{nl}分裂特異点チケットを作って使います"

        end

        if str == tostring("priority{nl}1.Tickets due within 24 hours{nl}2.Tickets with expiration date{nl}" ..
                               "3.{img pvpmine_shop_btn_total 20 20} tickets (buy and use){nl}4.{img icon_item_Tos_Event_Coin 20 20} tickets (buy and use))") then
            str = "優先順位{nl}1.24時間以内の期限付きチケット{nl}2.期限付きチケット{nl}" ..
                      "3.{img pvpmine_shop_btn_total 20 20}チケット(買って使います){nl}4.{img icon_item_Tos_Event_Coin 20 20}チケット(買って使います)"
        end
        if str == tostring("priority{nl}1.Tickets due within 24 hours{nl}2.Tickets with expiration date{nl}" ..
                               "3.Event tickets with no expiration date{nl}4.{img icon_item_Tos_Event_Coin 20 20} tickets (buy and use){nl}" ..
                               "5.{img pvpmine_shop_btn_total 20 20} tickets (buy and use){nl} {nl}" ..
                               "{#FFFF00}Right-click to switch priority") then
            str = "優先順位{nl}1.24時間以内の期限付きチケット{nl}2.期限付きチケット{nl}" ..
                      "3.期限のないイベントチケット{nl}4.{img icon_item_Tos_Event_Coin 20 20}チケット(買って使います){nl}" ..
                      "5.{img pvpmine_shop_btn_total 20 20}チケット(買って使います){nl}" ..
                      "{img pvpmine_shop_btn_total 20 20}このチケットで分裂券作れるで!{nl} {nl}" ..
                      "{#FFFF00}右クリックで優先順位切替"
        end
        -- "There are no ticket items in inventory."
        if str == tostring("There are no ticket items in inventory.") then
            str = "(自動マッチング/1人)入場券を持っていません。"
        end
        return "{s16}" .. str
    end

    return "{s20}" .. str
end

--[[function indun_panel_autozoom_init()

    local frame = ui.GetFrame("indun_panel")
    frame:SetSkinName('None')
    frame:SetLayerLevel(30)
    frame:Resize(140, 40)
    local rect = frame:GetMargin()
    frame:SetGravity(ui.RIGHT, ui.TOP)
    frame:SetMargin(rect.left, rect.top, rect.right + 140, rect.bottom)
    frame:SetTitleBarSkin("None")
    frame:EnableHittestFrame(1)
    frame:RemoveAllChild()

    local zoomedit = frame:CreateOrGetControl('edit', 'zoomedit', 80, 0, 60, 30)
    AUTO_CAST(zoomedit)
    zoomedit:SetText("{ol}" .. g.settings.zoom)
    zoomedit:SetFontName("white_16_ol")
    zoomedit:SetTextAlign("center", "center")
    zoomedit:SetEventScript(ui.ENTERKEY, "indun_panel_autozoom_save")
    zoomedit:SetTextTooltip(g.lang == "Japanese" and
                                "{ol}Auto Zoom Setting{nl}1～700の値で入力。標準は336。マップ切り替え時に入力の値までZoomします。0入力で機能無効化。" or
                                "{ol}Auto Zoom Setting{nl}Input a value from 0 to 700. Standard is 336. Zoom to the input value when switching maps.{nl}Disable function by inputting 0.")
    frame:ShowWindow(1)
end

function indun_panel_autozoom()
    if g.settings.zoom ~= 0 then
        camera.CustomZoom(tonumber(g.settings.zoom))
    end
end

function indun_panel_autozoom_save(frame, ctrl)

    local value = tonumber(ctrl:GetText())

    if value == 0 then
        g.settings.zoom = 0
    elseif value < 1 or value > 700 then
        local errorMsg =
            g.lang == "Japanese" and "無効な値です。1から700の間で設定してください。" or
                "Invalid value please set between 1 and 700"
        ui.SysMsg(errorMsg)
        local text = GET_CHILD_RECURSIVELY(frame, "zoomedit")
        text:SetText("336")
        g.settings.zoom = 336
    else
        if value ~= g.settings.zoom then
            ui.SysMsg("Auto Zoom setting set to " .. value)
            g.settings.zoom = value
        end
    end

    g.save_settings()
    ReserveScript("indun_panel_autozoom()", 1.0)
end]]

--[[function g.settings_make()
    if next(g.settings) then
        return
    end

    g.settings = {
        checkbox = 0,
        zoom = 336,
        challenge_checkbox = 1,
        singularity_checkbox = 1,
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
        jsr_checkbox = 1,
        singularity_check = 0,
        en_ver = 0,
        season_checkbox = 1,
        x = 665,
        y = 30,
        move = 0
    }

    g.save_settings()
end]]
--[[function indun_panel_time_update(openingameshopbtn)

    local time = os.date("*t")
    local hour = time.hour
    local min = time.min
    local sec = time.sec

    if g.get_map_type() == "City" then
        if g.sing == 1 then
            if INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_41") == 0 then
                local earthtowershop = ui.GetFrame('earthtowershop')
                if earthtowershop then
                    earthtowershop:Resize(0, 0)
                    indun_panel_minimized_pvpmine_shop_init()
                    g.sing = 2
                end
            end
        end
    end
    return 1
end]]
--[[function indun_panel_FPS_UPDATE(frame, msg)
    if frame:IsVisible() == 1 then
        return
    else
        indun_panel_frame_init()
    end
end]]
