-- v1.0.0 freefromtrivialsttresからの焼き直し。オートキャスティングをキャラ毎に。機能の有効化無効化を選択出来る様に。
-- v1.0.1 チェック外したら機能しない様に。各キャラ毎のオートキャスティングを直したと思う
-- v1.0.2 ADDONSに表示されない人がいるのでMINIMAP左下ボタンに変更
-- v1.0.3 バフ一覧設定がテレコになっていたのを修正。センスのないボタンを変更
-- v1.0.4 パーティーバフ非表示機能
-- v1.0.5 コインアイテムを取得時に自動使用機能追加
-- v1.0.6 コインアイテム自動使用を街だけに。女神ガチャ時は使用しない様に。レイド入場時装備チェック機能。
-- v1.0.7 女神ガチャ時は使用しない様にしたつもりが出来てなかったのを修正。
-- v1.0.8 ブラックマーケットのお知らせ削除
-- v1.0.9 クエストリスト非表示機能。オートマッチ中のフレームのレイヤー下げる機能。
-- v1.1.0 クエストリスト非表示機能。インベントリ開けたら表示されていたのを修正。
-- v1.1.1 左上の名前をキャラクター名に変更
-- v1.1.2 GAME_START_3SECが重すぎる様になったので3.5SECに
-- v1.1.3 メレジナダイアログ制御。おまけで死んだときに出るダイアログで「近くで復活」にマウスが合うように
-- v1.1.4 チャンネルインフォを作った。
-- v1.1.5 チャンネルインフォのバグ修正。フレーム作る前にrunupdateしてた。
-- v1.1.6 チャンネルインフォ昨日1chだと動かなかったの修正。
-- v1.1.7 メレジナのダイアログ直した。
-- v1.1.8 他人のエフェクトの設定がバグっているらしいので、直した気もする。
-- v1.1.9 チャンネルインフォの表示バグの原因っぽいところを修正。
-- v1.2.0 英語圏のstrの取得方法間違ってたの修正。今いるチャンネルが分かる様にした。
-- v1.2.1 英語版の再修正。これで無理ならもう無理や。
-- v1.2.2 バフリスト表示されないバグ修正。
-- v1.2.3 女神ガチャ自動化。錬成アイテム装備入れたら嵌まる様に。
-- v1.2.4 女神ガチャ機能デフォルトONをOFFに変更
-- v1.2.5 女神ガチャ制御強化
-- v1.2.6 女神ガチャ切り替え後にCCしないと、自動ガチャ機能OFFにならなかったの修正。
-- v1.2.7 女神ガチャフルベットボタンつけた。女神ガチャ中CCやチャンネル移動でフレーム表示されてたの1回目のみに修正。
-- v1.2.8 パーティーインフォフレームの表示切替
-- v1.2.9 パーティーインフォフレーム。いつものバグ修正
-- v1.3.1 プレイヤーゲージにレリック追加。スロガウピニス回ってる時の確認機能。
-- v1.3.2 キャラ毎のオートキャスティング修正。ペットフレーム呼び出し機能OFF
-- v1.3.3 女神証商店のコインの限界値を99999に変更。スロガウピニスのお知らせを派手に。
-- v1.3.4 クローズボタンの場所修正。TP商店開いた時にフレーム消えてたの修正。
-- v1.3.5 BGMプレイヤー。割とガチで10曲目イカレてる。
-- v1.3.6 小さいBGMプレイヤー出さない様に変更
-- v1.3.7 チャンネルインフォフレームをレイドなどでは表示しない様に。マーケット出店時の数量バグ修正。
-- v1.3.8 マーケット出店時の数量バグ修正のバグ修正。
-- v1.3.9 サウンドミュート機能。説明を韓国語版に翻訳。
-- v1.4.0 ユラテコインも自動使用。バフリストバグってたの修正。
-- v1.4.1 自分のエフェクト調整機能追加
-- v1.4.2 ユラテコイン自動使用のバグ修正。装備忘れメッセージを520環境まで拡張。
-- v1.4.3 トークンワープ画面でクールダウン時間表示するように。
-- v1.4.4 ヴァカリネ装備をレイド時に他人に知らせる機能
-- v1.4.5 週ボス報酬を自動で受け取る機能。不安定かも。
-- v1.4.6 テスト用。
-- v1.4.7 死んだときのフレーム制御ミスってたの修正
-- v1.4.8 週ボスのダメージ累計報酬を先週分か今週分か切替出来る様に
-- v1.4.9 ワイドスクリーンだとSetPosおかしいらしい。アドオンの前提が色々崩れそう。コワイヨ
-- v1.5.0 クポルポーションのフレームを非表示に
-- v1.5.1 PTメンバーの希望の啓示見えるように
-- v1.5.2 ラガナを非表示に
-- v1.5.3 インベントリでイコルステータス検索出来る様に。装備錬成の武器防具ステータス付与自動化
-- v1.5.4 ヴェルニケ階数覚える様に、クポルポーション改修、セパレートフレームのスキン消した、チャンネルの混み具合直した。
-- v1.5.5 JSON作るとこバグってたので直した。。。
-- v1.5.6 パーティーバフリスト取るとこが他のアドオンと喧嘩してるらしいので直した。韓国語を教えてもらった。
-- v1.5.7 グループチャットをチャットフレームから選択出来る様にした。
-- v1.5.8 グループチャットバグ修正
-- v1.5.9 どこでもmemberinfo出来る様に。
-- v1.6.0 デバフ表示バグってたの修正
-- v1.6.1 チャンネルインフォのサイズ変更。ちょっとバグ修正。
-- v1.6.2 EP13ショップを街で開けられる様に。
-- v1.6.3 バウバスのお知らせ
-- v1.6.4 多分グルチャ直った。IMCに勝ったかも
-- v1.6.5 ウルトラワイドモードから通常に戻した時にフレーム消えたの修正
-- v1.6.6 ウルトラワイドで位置保存機能バグってたの修正。
-- v1.6.7 ウルトラワイドを再修正。クエストフレームの挙動を追加
-- v1.6.8 チャンネルフレームの初期場所修正。セッティングファイルバグ修正
-- v1.6.9 ボスのエフェクト調整。FPSの手入力。ブラックマーケットのお知らせ修正。ヴェルニケ報酬自動受け取り
-- v1.7.0 週間ボス報酬系修正。いつでもメンバーチャット修正。
-- v1.7.1 エフェクト関係のバグ修正。NOTICE_ON_MSGのバグ修正。
-- v1.7.2 アドオンボタン回り修正。どこでもメンバーインフォ修正。バフリスト検索機能
-- v1.7.3 PTメンバーの死亡をニコチャットでお知らせ機能
-- v1.7.4 フレームの分類分け、ペットリング非表示、コロニーの街へ移動のタイマー修正（IMCが直せよ）
-- v1.7.5 コロニーの街へ移動のタイマー再修正、追加チャットフレームの移動制限削除、デイリクエストを別窓表示。グルチャ系を直したつもり
-- v1.7.6 250902大型アプデ対応。アウステヤコイン。indunpanelからオートズーム機能移行、RP補充補完機能、スキルクール音消去、インベントリいじった、
-- v1.7.7 ペット呼び出しバグ修正。オプション数値の常時表示
-- v1.7.8 オプション数値のテキスト消えなかったの修正
-- v1.7.8.1 傭兵クエストの諦めるボタン、EP13ショップの製造書の種類表示
-- v1.7.8.2 ヘアエンチャントロールを便利に
-- v1.7.8.3 グルチャ直した
-- v1.7.8.5 グルチャ再修正
-- v1.7.8.6 ヘアエンチャントのバグ修正、チャットに機能追加、スキル錬成にツールチップ追加
-- v1.7.8.7 チャットエクステンド有効の場合はチャット機能OFF、ボスレランキング機能、製造自動セット、場所表示バグ修正
-- v1.7.8.8 ボスレランキングソードマン系統タブから取得しないと正常に動かないの修正、恩恵付きイコルの場合に数値表出ないバグ修正、レイドレコードの計算修正、読込遅い問題修正
-- v1.7.8.9 ボスレダメージランキング報酬にちょい残しボタンを追加
-- v1.7.9 追加報酬券お知らせ機能
local addon_name = "MINI_ADDONS"
local addon_name_lower = string.lower(addon_name)
local author = "norisan"
local ver = "1.7.9"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addon_name] = _G["ADDONS"][author][addon_name] or {}
local g = _G["ADDONS"][author][addon_name]

local acutil = require("acutil")
local os = require("os")
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

local base = {}
local active_id = session.loginInfo.GetAID()
g.settings_path = string.format("../addons/%s/%s.json", addon_name_lower, active_id .. "_1")
g.buffs_path = string.format('../addons/%s/buffs.json', addon_name_lower)

function g.SetupHook(func, baseFuncName)
    local addonUpper = string.upper(addon_name)
    local replacementName = addonUpper .. "_BASE_" .. baseFuncName

    if (_G[replacementName] == nil) then
        _G[replacementName] = _G[baseFuncName]
        _G[baseFuncName] = func
    end
    base[baseFuncName] = _G[replacementName]
end

function g.mkdir_new_folder()
    local folder_path = string.format("../addons/%s", addon_name_lower)
    local file_path = string.format("../addons/%s/mkdir.txt", addon_name_lower)
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
    if not g.REGISTER[origin_func_name .. my_func_name] then
        g.REGISTER[origin_func_name .. my_func_name] = true
        my_addon:RegisterMsg(origin_func_name, my_func_name)
    end
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

function g.get_event_args(origin_func_name)
    local args = g.ARGS[origin_func_name]
    if args then
        return table.unpack(args)
    end
    return nil
end

function g.split(input_str, separator)
    local parts = {}
    local start_pos = 1
    while true do
        local sep_start, sep_end = string.find(input_str, separator, start_pos, true)
        if not sep_start then
            table.insert(parts, string.sub(input_str, start_pos))
            break
        end
        table.insert(parts, string.sub(input_str, start_pos, sep_start - 1))
        start_pos = sep_end + 1
    end
    return parts
end

function g.load_dat(path)
    local file = io.open(path, "r")
    if not file then
        return nil
    end
    local content = file:read("*all")
    file:close()
    if content == "" or content == nil then
        return {}
    end
    local records = {}
    for line in content:gmatch("([^\n]+)") do
        if line ~= "" then
            local parts = g.split(line, ":::")
            if #parts == 7 then
                table.insert(records, parts)
            end
        end
    end
    return records
end

-- !追加の度に更新
local DEFAULT_SETTINGS = {
    reword_x = 1100,
    reword_y = 100,
    allcall = 0,
    under_staff = 0,
    raid_record = 0,
    party_buff = 0,
    chat_system = 0,
    channel_display = 0,
    channel_info = 0,
    mini_btn = 0,
    market_display = 0,
    restart_move = 0,
    pet_init = 0,
    dialog_ctrl = 0,
    auto_cast = 0,
    auto_casting = {},
    coin_use = 0,
    equip_info = 0,
    automatch_layer = 0,
    quest_hide = 0,
    pc_name = 0,
    auto_gacha = 0,
    skill_enchant = 0,
    party_info = 0,
    relic_gauge = 0,
    raid_check = 0,
    coin_count = 0,
    bgm = 0,
    my_effect = 0,
    other_effect = 0,
    boss_effect = 0,
    vakarine = 0,
    weekly_boss_reward = 0,
    solodun_reward = 0,
    cupole_portion = {
        use = 0,
        x = 0,
        y = 0,
        def_x = 0,
        def_y = 0
    },
    goodbye_ragana = 0,
    status_upgrade = 0,
    icor_status_search = 0,
    velnice = {
        use = 0,
        level = ""
    },
    separated_buff = 0,
    group_name = {},
    group_chat = 0,
    memberinfo = 0,
    baubas_call = {
        use = 0,
        guild_notice = 0
    },
    chat_recv = 0,
    pet_ring = 0,
    daily_quest = 0,
    chat_frame = 0,
    restart_colony = 0,
    auto_zoom = {
        use = 0,
        zoom = 336
    },
    rp_charge = 0,
    skill_cool_sound = 0,
    inventory_mod = 0,
    reroll_option = 0,
    hair_enchant = 0,
    new_groups = {},
    chat_new_btn = 0,
    chat_xy = {},
    pt_info = 0,
    enchant_tooltip = 0,
    boss_rank = 0,
    auto_craft = 0,
    keep_first = 0,
    multiple_item = 0
}

local SETTINGS_NAME = {"other_effect", "my_effect", "boss_effect", "channel_info", "pc_name", "quest_hide",
                       "automatch_layer", "equip_info", "under_staff", "raid_record", "party_buff", "chat_system",
                       "channel_display", "mini_btn", "market_display", "restart_move", "pet_init", "dialog_ctrl",
                       "auto_cast", "coin_use", "auto_gacha", "skill_enchant", "party_info", "relic_gauge",
                       "raid_check", "coin_count", "bgm", "vakarine", "weekly_boss_reward", "solodun_reward",
                       "cupole_portion", "goodbye_ragana", "status_upgrade", "icor_status_search", "velnice",
                       "separated_buff", "group_chat", "memberinfo", "baubas_call", "pt_buff", "chat_recv", "pet_ring",
                       "daily_quest", "chat_frame", "restart_colony", "auto_zoom", "rp_charge", "skill_cool_sound",
                       "inventory_mod", "reroll_option", "hair_enchant", "chat_new_btn", "pt_info", "enchant_tooltip",
                       "boss_rank", "auto_craft", "keep_first", "multiple_item"}

local COIN_ITEM = {869001, 11200350, 11200303, 11200302, 11200301, 11200300, 11200299, 11200298, 11200297, 11200161,
                   11200160, 11200159, 11200158, 11200157, 11200156, 11200155, 11030215, 11030214, 11030213, 11030212,
                   11030211, 11030210, 11030201, 11035673, 11035670, 11035668, 11030394, 11030240, 646076, 11035672,
                   11035669, 11035667, 11035457, 11035426, 11035409, 11201239, 11201238, 11201237, 11201236, 11201235,
                   11201234, 11201233, 11201232, 11202008, 11202007, 11202006, 11202005, 11202004, 11202003, 11202002,
                   11202001}

-- メイン設定ウィンドウに表示するカテゴリボタンの定義
local CATEGORY_BUTTONS = {{
    name = "chats",
    text_jp = "チャット関連",
    text_kr = "채팅 관련",
    text_en = "Chat-related"
}, {
    name = "chars",
    text_jp = "キャラクター関連",
    text_kr = "캐릭터 관련",
    text_en = "Character-related"
}, {
    name = "frames",
    text_jp = "フレーム関連",
    text_kr = "프레임 관련",
    text_en = "Frame-related"
}, {
    name = "autos",
    text_jp = "自動処理関連",
    text_kr = "자동 처리 관련",
    text_en = "Automation-related"
}}
-- メイン設定ウィンドウに表示する主要なチェックボックスの定義
local MAIN_FRAME_SETTINGS = {{
    name = "multiple_item",
    text_jp = "{#FF0000}New!{/}{/}{ol}メレジナハード以降のハードレイドで追加報酬券お知らせ",
    text_kr = "{#FF0000}New!{/}{/}{ol}메레지나 하드 이후의 하드 레이드에서 추가 보상권 알림",
    text_en = "{#FF0000}New!{/}{/}{ol}Merregina Hard & above Hard Raids: Bonus Ticket Notice"
}, {
    name = "keep_first",
    text_jp = "{#FF0000}New!{/}{/}{ol}週ボスダメージ報酬の1段目を残すボタンを作成",
    text_kr = "{#FF0000}New!{/}{/}{ol}주간 보스 보상 첫 번째 유지 컨트롤 생성",
    text_en = "{#FF0000}New!{/}{/}{ol}Create Weekly Boss Damage Reward 1st Keep Control"
}, {
    name = "auto_craft",
    text_jp = "{#FF0000}New!{/}{/}{ol}アイテム製造時 自動でセットします",
    text_kr = "{#FF0000}New!{/}{/}{ol}아이템 제조 시 자동으로 세트됩니다",
    text_en = "{#FF0000}New!{/}{/}{ol}Automatically set during item crafting"
}, {
    name = "boss_rank",
    text_jp = "{#FF0000}New!{/}{/}{ol}ボスレイドのビルドランキング作成",
    text_kr = "{#FF0000}New!{/}{/}{ol}보스 레이드 빌드 랭킹 생성",
    text_en = "{#FF0000}New!{/}{/}{ol}Create the build ranking for boss raids"
}, {
    name = "enchant_tooltip",
    text_jp = "{#FF0000}New!{/}{/}{ol}スキル錬成スロットにツールチップ追加",
    text_kr = "{#FF0000}New!{/}{/}{ol}스킬 인챈트 슬롯에 툴팁을 추가했습니다",
    text_en = "{#FF0000}New!{/}{/}{ol}Added tooltips to the skill enchantment slots"
}, {
    name = "pt_info",
    text_jp = "{#FF0000}New!{/}{/}{ol}PT情報にメンバーの場所追加",
    text_kr = "{#FF0000}New!{/}{/}{ol}PT 정보에 멤버 위치를 추가했습니다",
    text_en = "{#FF0000}New!{/}{/}{ol}Added member locations to PT information"
}, {
    name = "chat_new_btn",
    text_jp = "{#FF0000}New!{/}{/}{ol}チャット入力フレームにボタン追加",
    text_kr = "{#FF0000}New!{/}{/}{ol}채팅 입력 창에 버튼을 추가했습니다",
    text_en = "{#FF0000}New!{/}{/}{ol}Added a button to the chat input frame"
}, {
    name = "hair_enchant",
    text_jp = "{#FF0000}New!{/}{/}{ol}ヘアアクセサリーのエンチャント自動付与を使いやすく",
    text_kr = "{#FF0000}New!{/}{/}{ol}헤어 액세서리 자동 인챈트 사용성 개선",
    text_en = "{#FF0000}New!{/}{/}{ol}Hair Accessory Auto-Enchant UX improved"
}, {
    name = "reroll_option",
    text_jp = "オプション設定の数値表を常に表示",
    text_kr = "옵션 설정의 수치 표를 항상 표시합니다",
    text_en = "Always display the numerical table for option settings"
}, {
    name = "inventory_mod",
    text_jp = "インベントリのスロットを少し改造",
    text_kr = "인벤토리 슬롯을 약간 개조했습니다",
    text_en = "Slightly modified the inventory slots"
}, {
    name = "skill_cool_sound",
    text_jp = "スキル連打時のクールタイムの音を消去",
    text_kr = "스킬 연타 시의 재사용 대기시간(쿨타임) 효과음을 삭제했습니다",
    text_en = "Removed the cooldown sound when a skill is spammed"
}, {
    name = "rp_charge",
    text_jp = "レリック自動補充を補完",
    text_kr = "레릭 자동 보충 기능에 보완(복구) 기능이 추가되었습니다",
    text_en = "Relic auto-replenishment now includes a recovery function"
}, {
    name = "auto_zoom",
    text_jp = "マップ切り替え時に自動でズーム",
    text_kr = "맵 이동 시 자동으로 지도를 확대합니다",
    text_en = "Automatically zooms the map when changing maps"
}, {
    name = "restart_colony",
    text_jp = "コロニー死亡時の30秒タイマーを修正",
    text_kr = "콜로니 사망 시 30초 타이머 수정",
    text_en = "Fixed the 30-second timer on death in Colonies"
}, {
    name = "chat_frame",
    text_jp = "ワイドモニターの追加チャットフレームの移動制限解除",
    text_kr = "와이드 모니터에서 추가 채팅창의 이동 제한 해제",
    text_en = "Freely move additional chat frames on wide monitors"
}, {
    name = "daily_quest",
    text_jp = "デイリークエストを別窓で表示",
    text_kr = "일일 퀘스트를 별도 창에 표시합니다",
    text_en = "Display the daily quest in a separate window"
}, {
    name = "under_staff",
    text_jp = "4人以下の入場確認をスキップ",
    text_kr = "4인 이하 입장 확인 건너뛰기",
    text_en = "Skip confirmation for admission of 4 or fewer people"
}, {
    name = "party_buff",
    text_jp = "PTメンバーのバフを非表示",
    text_kr = "파티원 버프 숨기기",
    text_en = "Hide buffs for party members"
}, {
    name = "channel_display",
    text_jp = "チャンネル表示のズレを修正(日本語版)",
    text_kr = "채널 표시 오류 수정(일본어)",
    text_en = "Fixed channel display misalignment for Japanese ver"
}, {
    name = "dialog_ctrl",
    text_jp = "各種ダイアログを制御",
    text_kr = "각종 다이얼로그 제어",
    text_en = "Controls various dialogs"
}, {
    name = "equip_info",
    text_jp = "アーク/エンブレム装備忘れ通知",
    text_kr = "아크/엠블렘 장비 미착용 알림",
    text_en = "Notification for unequipped Ark/Emblem"
}, {
    name = "coin_count",
    text_jp = "各商店のコイン上限を99999に",
    text_kr = "각 상점 코인 상한을 99999로",
    text_en = "Raise coin limit to 99999 for each shop"
}, {
    name = "bgm",
    text_jp = "街でBGMプレイヤーを常にオンにする",
    text_kr = "도시에서는 항상 BGM 플레이어를 재생합니다",
    text_en = "Always play BGM in the city"
}, {
    name = "vakarine",
    text_jp = "レイドでヴァカリネ装備を通知",
    text_kr = "레이드에서 바카리네 장비 알림",
    text_en = "Vakarine Equipment Notification in Raids"
}, {
    name = "goodbye_ragana",
    text_jp = "街でラガナを非表示",
    text_kr = "마을에서 라가나 숨기기",
    text_en = "Hide Ragana in city"
}, {
    name = "icor_status_search",
    text_jp = "インベントリでイコルのステータスを検索",
    text_kr = "인벤토리에서 아이커 능력치 검색",
    text_en = "Search Icor status in Inventory"
}, {
    name = "velnice",
    text_jp = "ヴェルニケの以前の階層を覚える",
    text_kr = "벨니케의 이전 레벨을 기억하다",
    text_en = "Remember Velnice's previous level"
}, {
    name = "memberinfo",
    text_jp = "各種右クリックメニューにメンバーインフォを追加",
    text_kr = "각종 오른쪽 클릭 메뉴에 멤버 정보 추가",
    text_en = "Add member info to various right-click menus"
}}

-- サブフレームに表示する設定項目の定義（カテゴリ別）
local SUB_FRAME_SETTINGS = {
    chats = {{
        name = "chat_system",
        text_jp = "パーフェクトとブラックマーケットのお知らせをチャットに表示しません",
        text_kr = "완벽함 메시지 및 블랙 마켓 공지를 채팅에 표시 하지 않습니다",
        text_en = "Perfect and Black Market notices not displayed in chat"
    }, {
        name = "group_chat",
        text_jp = "グループチャットをチャットフレームから選択出来ます",
        text_kr = "채팅 프레임에서 그룹 채팅을 선택할 수 있습니다",
        text_en = "Group chats can be selected from chat frame"
    }, {
        name = "baubas_call",
        text_jp = "バウバス登場をお知らせ",
        text_kr = "바우버스 등장 소식",
        text_en = "Announcing the arrival of Baubas"
    }, {
        name = "chat_recv",
        text_jp = "PTメンバーの死亡をニコチャットで表示",
        text_kr = "PT 멤버의 사망을 니코챗으로 표시하기",
        text_en = "Death of a PT member is indicated in Nicochat"
    }},
    chars = {{
        name = "my_effect",
        text_jp = "自分のエフェクトを調整します(1~100)",
        text_kr = "나만의 효과를 조정합니다(1~100)",
        text_en = "Adjust my effects(1~100)"
    }, {
        name = "other_effect",
        text_jp = "他人のエフェクトを調整します(1~100)",
        text_kr = "다른 사람의 효과를 조정합니다(1~100)",
        text_en = "Adjust other people's effects(1~100)"
    }, {
        name = "boss_effect",
        text_jp = "ボスのエフェクトを調整します(1~100)",
        text_kr = "보스 효과를 조정합니다(1~100)",
        text_en = "Adjust boss effects(1~100)"
    }, {
        name = "auto_cast",
        text_jp = "オートキャスティングをキャラ毎に設定",
        text_kr = "캐릭터별로 자동 시전 설정",
        text_en = "Set auto casting per character"
    }, {
        name = "pc_name",
        text_jp = "左上の名前をキャラクター名に変更します",
        text_kr = "좌측 상단의 이름을 캐릭터 이름으로 변경합니다",
        text_en = "Change the name in the top left to your character's name"
    }, {
        name = "relic_gauge",
        text_jp = "キャラクターゲージにレリックを追加します",
        text_kr = "캐릭터 게이지에 유물을 추가합니다",
        text_en = "Add a Relic to the character's gauge"
    }},
    frames = {{
        name = "raid_record",
        text_jp = "レイドレコードを移動可能にしてサイズを変更",
        text_kr = "레이드 기록의 이동이 가능하고, 크기 조절을 할 수 있습니다",
        text_en = "Raid records movable and resizable"
    }, {
        name = "mini_btn",
        text_jp = "レイド時右上のミニボタン非表示",
        text_kr = "레이드 중 오른쪽 상단의 미니 버튼을 숨깁니다",
        text_en = "Hide minibutton in upper right corner during raid"
    }, {
        name = "market_display",
        text_jp = "街では、右上の商店一覧を常に表示します",
        text_kr = "도시 이동 시 상점 목록을 항상 열어둡니다",
        text_en = "Keep shop list open when moving to city"
    }, {
        name = "restart_move",
        text_jp = "リスタート時の選択肢フレームを動かせる様にします",
        text_kr = "재시작 시 선택 프레임을 이동할 수 있게 합니다",
        text_en = "Allow moving selection frame on restart"
    }, {
        name = "automatch_layer",
        text_jp = "オートマッチ時のフレームのレイヤーレベルを下げます",
        text_kr = "자동 매칭 시 프레임 레이어 레벨을 낮춥니다",
        text_en = "Lower frame layer level during auto match"
    }, {
        name = "quest_hide",
        text_jp = "クエストリストを非表示にします",
        text_kr = "퀘스트 목록을 숨깁니다",
        text_en = "Hide the quest list"
    }, {
        name = "channel_info",
        text_jp = "チャンネル切替フレームを表示します",
        text_kr = "채널 전환 프레임을 표시합니다",
        text_en = "Displays the channel switching frame"
    }, {
        name = "auto_gacha",
        text_jp = "女神の加護ガチャフレーム表示を自動化します",
        text_kr = "여신의 가호 가챠 프레임 표시를 자동화합니다",
        text_en = "Automate the display of the Goddess Protection gacha frame"
    }, {
        name = "party_info",
        text_jp = "パーティーフレームの表示切替。右クリックで小さくします。マウスモード用",
        text_kr = "파티 정보 프레임 표시 전환. 마우스 모드용. 오른쪽 클릭으로 작게 합니다",
        text_en = "Toggle party info frame. For mouse mode.Party info rightclick"
    }, {
        name = "cupole_portion",
        text_jp = "クポルのポーションフレームを非表示に。OFFでもフレームの位置記憶",
        text_kr = "큐폴의 포션 프레임을 숨기고, OFF 상태에서도 프레임 위치를 기억합니다",
        text_en = "Hide the potion frame of the cupole.Memorizes frame position even when OFF"
    }, {
        name = "separated_buff",
        text_jp = "セパレートバフフレームの周りを綺麗にします",
        text_kr = "분리형 버프 프레임 주변을 없앱니다",
        text_en = "Eliminate around separate buff frame"
    }, {
        name = "pet_ring",
        text_jp = "ペットリングフレームを非表示にします",
        text_kr = "펫 링 프레임을 숨깁니다",
        text_en = "Hides the pet ring frame"
    }},
    autos = {{
        name = "coin_use",
        text_jp = "各種コインを取得時に自動で使用します",
        text_kr = "각종 코인 획득 시 자동 사용",
        text_en = "Automatically use various coins upon acquisition"
    }, {
        name = "skill_enchant",
        text_jp = "スキル錬成のアイテムを自動でセットします",
        text_kr = "스킬 연성을 위한 아이템을 자동으로 설정합니다",
        text_en = "Automatically sets items for skill refining"
    }, {
        name = "weekly_boss_reward",
        text_jp = "週間ボスレイド報酬を自動で受け取り",
        text_kr = "주간 보스 레이드 보상을 자동으로 수령",
        text_en = "Receive weekly boss reward automatically"
    }, {
        name = "solodun_reward",
        text_jp = "ヴェルニケダンジョン報酬を自動で受け取り",
        text_kr = "벨니체 던전 보상 자동 받기",
        text_en = "Receive Velnice dungeon reward automatically"
    }, {
        name = "status_upgrade",
        text_jp = "装備錬成、武器防具ステータス付与を自動化",
        text_kr = "장비 연성, 무기 방어구 스테이터스 부여 자동화",
        text_en = "Equip Refining, Automate weapon/armor enhancement"
    }}
}

function MINI_ADDONS_subframe_close(frame, ctrl)
    local sub_frame = ui.GetFrame(addon_name_lower .. "sub_frame")
    sub_frame:ShowWindow(0)
end

function MINI_ADDONS_subframe_open(frame, ctrl, str)
    local sub_frame = ui.CreateNewFrame("notice_on_pc", addon_name_lower .. "sub_frame", 0, 0, 0, 0)
    AUTO_CAST(sub_frame)
    sub_frame:SetSkinName("test_frame_low")
    sub_frame:SetLayerLevel(94)
    sub_frame:EnableHittestFrame(1)
    sub_frame:ShowTitleBar(0)
    sub_frame:RemoveAllChild()
    local title = sub_frame:CreateOrGetControl("richtext", "title", 30, 10)
    AUTO_CAST(title)
    local clean_str = string.gsub(str, "{ol}", "")
    title:SetText("{@st66b18}" .. clean_str)
    local gbox = sub_frame:CreateOrGetControl("groupbox", "gbox", 10, 30, 0, 0)
    AUTO_CAST(gbox)
    gbox:SetSkinName("bg")
    local close = sub_frame:CreateOrGetControl("button", "close", 0, 0, 30, 30)
    AUTO_CAST(close)
    close:SetGravity(ui.RIGHT, ui.TOP)
    close:SetSkinName("None")
    close:SetText("{img testclose_button 30 30}")
    close:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_subframe_close")
    local ctrl_name = ctrl:GetName()
    local y = 10
    local x = 0
    local settings_data = SUB_FRAME_SETTINGS[ctrl_name] or {}
    for _, setting in ipairs(settings_data) do
        local check_value
        if setting.name == "cupole_portion" or setting.name == "baubas_call" or setting.name == "velnice" then
            check_value = g.settings[setting.name].use
        elseif setting.name == "my_effect" or setting.name == "boss_effect" then
            check_value = g.settings[setting.name] or 0
        else
            check_value = g.settings[setting.name]
        end
        local checkbox = gbox:CreateOrGetControl('checkbox', setting.name, 10, y, 25, 25)
        AUTO_CAST(checkbox)
        checkbox:SetCheck(check_value)
        checkbox:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_ISCHECK")
        local text = g.lang == "Japanese" and ("{ol}" .. setting.text_jp) or g.lang == "kr" and
                         ("{ol}" .. setting.text_kr) or ("{ol}" .. setting.text_en)
        checkbox:SetText(text)
        local tooltip_text = g.lang == "Japanese" and "{ol}チェックすると有効化" or g.lang == "kr" and
                                 "{ol}체크 시 활성화" or "{ol}Check to enable"
        checkbox:SetTextTooltip(tooltip_text)
        local text_width = checkbox:GetWidth()
        if x < text_width then
            x = text_width
        end
        -- チェックボックスの隣に特殊なUIを追加する処理
        if setting.name == "baubas_call" then
            local baubas_call_btn = gbox:CreateOrGetControl('button', 'baubas_call_btn', text_width + 15, y - 5, 50, 30)
            AUTO_CAST(baubas_call_btn)
            if g.settings.baubas_call.guild_notice == 0 or not g.settings.baubas_call.guild_notice then
                baubas_call_btn:SetText("{ol}{#FFFFFF}OFF")
                baubas_call_btn:SetSkinName("test_gray_button")
                g.settings.baubas_call.guild_notice = 0
                MINI_ADDONS_SAVE_SETTINGS()
            else
                baubas_call_btn:SetText("{ol}{#FFFFFF}ON")
                baubas_call_btn:SetSkinName("test_red_button")
            end
            local tooltip_text = g.lang == "Japanese" and "{ol}ギルドチャットへのお知らせ切替え" or
                                     g.lang == "kr" and "{ol}길드 채팅으로 알림 전환" or
                                     "{ol}Notification switch to guild chat"
            baubas_call_btn:SetTextTooltip(tooltip_text)
            baubas_call_btn:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_baubas_call_switch")
            local btn_width = baubas_call_btn:GetWidth()
            if x < text_width + 15 + btn_width then
                x = text_width + 15 + btn_width
            end
        elseif setting.name == "other_effect" or setting.name == "my_effect" or setting.name == "boss_effect" then
            local edit_name = setting.name .. "_edit"
            local edit_ctrl = gbox:CreateOrGetControl('edit', edit_name, text_width + 15, y, 60, 25)
            AUTO_CAST(edit_ctrl)
            local event_name = "MINI_ADDONS_" .. string.upper(setting.name) .. "_EDIT"
            edit_ctrl:SetEventScript(ui.ENTERKEY, event_name)
            edit_ctrl:SetTextTooltip("{ol}1~100")
            edit_ctrl:SetFontName("white_16_ol")
            edit_ctrl:SetTextAlign("center", "center")

            local transparency_value
            if setting.name == "other_effect" then
                transparency_value = config.GetOtherEffectTransparency()
            elseif setting.name == "my_effect" then
                transparency_value = config.GetMyEffectTransparency()
            elseif setting.name == "boss_effect" then
                transparency_value = config.GetBossMonsterEffectTransparency()
            end
            local num_value = math.floor(transparency_value * 0.392156862745 + 0.5)
            edit_ctrl:SetText("{ol}" .. num_value)
            if x < text_width + 15 + 60 then
                x = text_width + 15 + 60
            end
        elseif setting.name == "auto_gacha" then
            local auto_gacha_btn = gbox:CreateOrGetControl('button', 'auto_gacha_btn', text_width + 15, y - 5, 50, 30)
            AUTO_CAST(auto_gacha_btn)
            if g.settings.auto_gacha_start == 0 or g.settings.auto_gacha_start == nil then
                auto_gacha_btn:SetText("{ol}{#FFFFFF}OFF")
                auto_gacha_btn:SetSkinName("test_gray_button")
                g.settings.auto_gacha_start = 0
                MINI_ADDONS_SAVE_SETTINGS()
            else
                auto_gacha_btn:SetText("{ol}{#FFFFFF}ON")
                auto_gacha_btn:SetSkinName("test_red_button")
            end
            local tooltip_text = g.lang == "Japanese" and
                                     "{ol}ONにすると自動でガチャスタートします。切替にCC必要です" or
                                     g.lang == "kr" and
                                     "{ol}ON으로 설정하면 자동으로 가챠가 시작됩니다. 전환 시 CC 필요합니다" or
                                     "{ol}When turned on, the gacha starts automatically.CC required for switching"
            auto_gacha_btn:SetTextTooltip(tooltip_text)
            auto_gacha_btn:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_GP_AUTOSTART_OPERATION")
            if x < text_width + 15 + 50 then
                x = text_width + 15 + 50
            end
        elseif setting.name == "weekly_boss_reward" then
            if not g.settings.reward_switch then
                g.settings.reward_switch = 1
                MINI_ADDONS_SAVE_SETTINGS()
            end
            local switch_btn = gbox:CreateOrGetControl('button', 'switch', text_width + 15, y, 80, 25)
            AUTO_CAST(switch_btn)
            if g.settings.reward_switch == 1 then
                switch_btn:SetText(g.lang == "Japanese" and "{ol}先週分" or g.lang == "kr" and "{ol}지난 주분" or
                                       "{ol}last week")
            else
                switch_btn:SetText(g.lang == "Japanese" and "{ol}今週分" or g.lang == "kr" and "{ol}이번 주분" or
                                       "{ol}this week")
            end
            switch_btn:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_WEEKLY_BOSS_REWARD_SWITCH")
            local tooltip_text =
                g.lang == "Japanese" and "{ol}ダメージ報酬受取り週切替" or g.lang == "kr" and
                    "{ol}데미지 보상 수령 주차 변경" or "{ol}Switch Damage Reward Receipt Week"
            switch_btn:SetTextTooltip(tooltip_text)
            if x < text_width + 15 + 80 then
                x = text_width + 15 + 80
            end
        end
        y = y + 30
    end
    sub_frame:Resize(x + 65, y + 45)
    gbox:Resize(sub_frame:GetWidth() - 20, sub_frame:GetHeight() - 40)
    local screen_width = ui.GetClientInitialWidth()
    local screen_height = ui.GetClientInitialHeight()
    local width = sub_frame:GetWidth()
    sub_frame:SetPos((screen_width - width) / 2 + 250, screen_height / 2 - 200)
    sub_frame:ShowWindow(1)
end

function MINI_ADDONS_SETTING_FRAME_INIT(frame_arg, ctrl_arg, str_arg, num_arg)
    local frame = ui.GetFrame("mini_addons")
    if frame:GetWidth() > 100 and str_arg == "false" then
        frame:Resize(0, 0)
        frame:ShowWindow(0)
        return
    end
    frame:SetSkinName("test_frame_low")
    frame:SetLayerLevel(93)
    frame:EnableHittestFrame(1)
    frame:ShowTitleBar(0)
    frame:RemoveAllChild()
    frame:SetEventScript(ui.RBUTTONUP, "MINI_ADDONS_FRAME_CLOSE")
    local title = frame:CreateOrGetControl("richtext", "title", 30, 10)
    AUTO_CAST(title)
    title:SetText("{@st66b18}Mini Addons {/}{#000000}{s13} ver " .. ver)
    local close = frame:CreateOrGetControl("button", "close", 0, 5, 30, 30)
    AUTO_CAST(close)
    close:SetGravity(ui.RIGHT, ui.TOP)
    close:SetSkinName("None")
    close:SetText("{img testclose_button 30 30}")
    close:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_FRAME_CLOSE")
    local gbox = frame:CreateOrGetControl("groupbox", "gbox", 10, 30, 0, 0)
    AUTO_CAST(gbox)
    gbox:SetSkinName("bg")
    local y = 10
    local x = 0
    for _, category in ipairs(CATEGORY_BUTTONS) do
        local button = gbox:CreateOrGetControl("button", category.name, 40, y, 0, 25)
        AUTO_CAST(button)
        button:SetSkinName("None")
        local temp_text = g.lang == "Japanese" and ("{ol}" .. category.text_jp) or g.lang == "kr" and
                              ("{ol}" .. category.text_kr) or ("{ol}" .. category.text_en)
        button:SetText(temp_text)
        button:SetTextAlign('left', 'center')
        button:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_subframe_open")
        button:SetEventScriptArgString(ui.LBUTTONUP, temp_text)
        button:SetEventScript(ui.RBUTTONUP, "MINI_ADDONS_subframe_close")
        if x < button:GetWidth() then
            x = button:GetWidth()
        end
        y = y + 30
    end
    y = y + 10
    for _, setting in ipairs(MAIN_FRAME_SETTINGS) do
        local check_value
        if setting.name == "velnice" then
            check_value = g.settings.velnice.use
        elseif setting.name == "auto_zoom" then
            check_value = g.settings.auto_zoom.use
        else
            check_value = g.settings[setting.name]
        end
        local checkbox = gbox:CreateOrGetControl('checkbox', setting.name, 10, y, 25, 25)
        AUTO_CAST(checkbox)
        checkbox:SetCheck(check_value)
        checkbox:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_ISCHECK")
        local temp_text = g.lang == "Japanese" and ("{ol}" .. setting.text_jp) or g.lang == "kr" and
                              ("{ol}" .. setting.text_kr) or ("{ol}" .. setting.text_en)
        checkbox:SetText(temp_text)
        local tooltip_text = g.lang == "Japanese" and "{ol}チェックすると有効化" or g.lang == "kr" and
                                 "{ol}체크 시 활성화" or "{ol}Check to enable"
        checkbox:SetTextTooltip(tooltip_text)
        local text_width = checkbox:GetWidth()
        if x < text_width then
            x = text_width
        end
        if setting.name == "party_buff" then
            local party_buff_btn = gbox:CreateOrGetControl("button", "party_buff_btn", text_width + 15, y - 5, 50, 30)
            AUTO_CAST(party_buff_btn)
            party_buff_btn:SetText("{ol}{#FFFFFF}bufflist")
            local tooltip_text =
                g.lang == "Japanese" and "表示するバフを選択できます" or g.lang == "kr" and
                    "표시할 버프를 선택할 수 있습니다" or "You can choose which buffs to display"
            party_buff_btn:SetTextTooltip(tooltip_text)
            party_buff_btn:SetSkinName("test_red_button")
            party_buff_btn:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_BUFFLIST_FRAME_INIT")

            local pt_buff_check = gbox:CreateOrGetControl('checkbox', "pt_buff", text_width + 15 + 70, y, 25, 25)
            AUTO_CAST(pt_buff_check)
            pt_buff_check:SetCheck(g.settings.pt_buff or 0)
            pt_buff_check:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_ISCHECK")
            local tooltip_text =
                g.lang == "Japanese" and "チェックすると初見バフ非表示" or g.lang == "kr" and
                    "체크하면 첫눈에 반한 버프 숨기기" or "First-time buffs hidden when checked"
            pt_buff_check:SetTextTooltip(tooltip_text)

            local combined_width = text_width + 15 + 70 + pt_buff_check:GetWidth()
            if x < combined_width then
                x = combined_width
            end
        elseif setting.name == "auto_zoom" then
            local edit_name = setting.name .. "_edit"
            local edit_ctrl = gbox:CreateOrGetControl('edit', edit_name, text_width + 15, y, 60, 25)
            AUTO_CAST(edit_ctrl)

            edit_ctrl:SetEventScript(ui.ENTERKEY, "mini_addons_autozoom_edit")
            edit_ctrl:SetTextTooltip("{ol}1~700 Default 336")
            edit_ctrl:SetFontName("white_16_ol")
            edit_ctrl:SetTextAlign("center", "center")
            edit_ctrl:SetText("{ol}" .. g.settings.auto_zoom.zoom)
            if x < text_width + 15 + 60 then
                x = text_width + 15 + 60
            end

        end
        y = y + 30
    end
    local description = gbox:CreateOrGetControl("richtext", "description", 10, y + 5)
    AUTO_CAST(description)
    local temp_text = g.lang == "Japanese" and
                          "{ol}{#FFA500}※一部機能の有効/無効の切替はキャラクターチェンジが必要です" or
                          g.lang == "kr" and
                          "{ol}{#FFA500}※일부 기능의 활성화/비활성화 전환은 캐릭터 변경이 필요합니다" or
                          "{ol}{#FFA500}※Character change is required to enable or disable some functions"
    description:SetText(temp_text)
    local text_width = description:GetWidth()
    if x < text_width then
        x = text_width
    end
    y = y + 30
    frame:Resize(x + 65, y + 45)
    gbox:Resize(frame:GetWidth() - 20, frame:GetHeight() - 40)
    local screen_width = ui.GetClientInitialWidth()
    local screen_height = ui.GetClientInitialHeight()
    frame:SetPos((screen_width - frame:GetWidth()) / 2, (screen_height - frame:GetHeight()) / 2)
    frame:ShowWindow(1)
end

function MINI_ADDONS_ISCHECK(frame, ctrl, argStr, argNum)
    local is_checked = ctrl:IsChecked()
    local ctrl_name = ctrl:GetName()
    for _, setting_name in ipairs(SETTINGS_NAME) do
        if ctrl_name == setting_name then
            if setting_name == "cupole_portion" or setting_name == "velnice" or setting_name == "baubas_call" or
                setting_name == "auto_zoom" then
                g.settings[setting_name] = g.settings[setting_name] or {}
                g.settings[setting_name].use = is_checked
            else
                g.settings[setting_name] = is_checked
            end
            -- 特定の機能に対する即時処理
            if setting_name == "bgm" then
                if is_checked == 0 then
                    local max_frame = ui.GetFrame("bgmplayer")
                    local play_btn = GET_CHILD_RECURSIVELY(max_frame, "playStart_btn")
                    BGMPLAYER_PLAY(max_frame, play_btn)
                end
            elseif setting_name == "quest_hide" then
                if is_checked == 0 then
                    MINI_ADDONS_QUESTINFO_SHOW()
                else
                    MINI_ADDONS_QUESTINFO_HIDE_RESERVE()
                end
            elseif setting_name == "daily_quest" then
                local q7quest = ui.GetFrame("mini_addons_q7quest")
                if is_checked == 0 then
                    if q7quest then
                        ui.DestroyFrame("mini_addons_q7quest")
                    end
                else
                    if q7quest then
                        ui.DestroyFrame("mini_addons_q7quest")
                    end
                    mini_addons_quest_update()
                end
            elseif setting_name == "inventory_mod" then
                local inventory = ui.GetFrame("inventory")
                local tab = GET_CHILD_RECURSIVELY(inventory, "inventype_Tab")
                tab:SelectTab(0)
                local tab_index = tab:GetSelectItemIndex()
                inventory:SetUserValue("TRY", 0)
                g.inven_tbl = {}
                mini_addons_INVENTORY_OPEN_logic(inventory)
            elseif setting_name == "chat_new_btn" then
                mini_addons_update_chat_frame()
            end
            break
        end
    end
    MINI_ADDONS_SAVE_SETTINGS()
end

function MINI_ADDONS_LOAD_SETTINGS()
    local settings = g.load_json(g.settings_path)
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
    MINI_ADDONS_SAVE_SETTINGS()
end

function MINI_ADDONS_SAVE_SETTINGS()
    g.save_json(g.settings_path, g.settings)
end

g.solodun_reward = false
g.game_start = nil
function MINI_ADDONS_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame
    g.REGISTER = {}
    g.corony_count = nil
    g.cid = info.GetCID(session.GetMyHandle())
    g.lang = option.GetCurrentCountry()
    if not g.settings then
        -- local start_time = os.clock()
        MINI_ADDONS_LOAD_SETTINGS()
        -- local end_time = os.clock()
        -- local elapsed_time = end_time - start_time
        -- CHAT_SYSTEM(string.format("%s: %.4f seconds", addon_name_lower .. "_on_init", elapsed_time))
    end

    g.setup_hook_and_event_before_after(g.addon, "CHAT_SYSTEM", "MINI_ADDONS_CHAT_SYSTEM", false)
    addon:RegisterMsg("GAME_START", "mini_addons_GAME_START")
    addon:RegisterMsg("GAME_START_3SEC", "mini_addons_GAME_START_3SEC")

    g.load_time = os.clock()
    g.last_inventory_open_time = 0
end

function mini_addons_GAME_START(frame, msg, str, num)

    -- セパレートバフフレームの周りを綺麗に
    local buff_separatedlist = ui.GetFrame("buff_separatedlist")
    local gbox = GET_CHILD_RECURSIVELY(buff_separatedlist, "gbox")
    AUTO_CAST(gbox)
    if g.settings.separated_buff == 1 then
        gbox:SetSkinName("None")
    else
        gbox:SetSkinName("chat_window")
    end

    local functionName = "AUTOMAPCHANGE_CAMERA_ZOOM"
    if _G[functionName] and type(_G[functionName]) == "function" then
        _G[functionName] = nil
    end
    local cupole_external_addon = ui.GetFrame("cupole_external_addon")
    if cupole_external_addon then
        cupole_external_addon:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_CUPOLE_PORTION_FRAME_SAVE")
        acutil.setupEvent(g.addon, "TOGGLE_CUPOLE_EXTERNAL_ADDON", "MINI_ADDONS_TOGGLE_CUPOLE_EXTERNAL_ADDON")
        MINI_ADDONS_TOGGLE_CUPOLE_EXTERNAL_ADDON(frame, msg, str, num)
    end
    if g.settings.quest_hide == 1 then
        MINI_ADDONS_QUESTINFO_HIDE_RESERVE(frame, msg, str, num)
        acutil.setupEvent(g.addon, "INVENTORY_OPEN", "MINI_ADDONS_QUESTINFO_HIDE_RESERVE")
        acutil.setupEvent(g.addon, "INVENTORY_CLOSE", "MINI_ADDONS_QUESTINFO_HIDE_RESERVE")
    end
    if g.settings.rp_charge == 1 and g.get_map_type() == "City" then
        mini_addons_rp_check()
    end

    -- お使いクエストフレーム
    g.addon:RegisterMsg('QUEST_UPDATE', 'mini_addons_quest_update')
    g.addon:RegisterMsg('QUEST_UPDATE_', "mini_addons_quest_update")
    g.addon:RegisterMsg('GET_NEW_QUEST', 'mini_addons_quest_update')
    mini_addons_quest_update(frame, msg, str, num)

    MINI_ADDONS_SAVE_AND_CREATE_BUFFIDS()
    -- 最初回のイベントバナーのレイヤー下げる
    g.addon:RegisterMsg("DO_OPEN_EVENTBANNER_UI", "mini_addons_event_banner_layer")
    g.addon:RegisterMsg("EVENTBANNER_SOLODUNGEON", "mini_addons_event_banner_layer")
end

-- 最初回のイベントバナーのレイヤー下げる
function mini_addons_event_banner_layer()
    local ingameeventbanner = ui.GetFrame("ingameeventbanner")
    if ingameeventbanner and ingameeventbanner:IsVisible() == 1 then
        AUTO_CAST(ingameeventbanner)
        ingameeventbanner:SetLayerLevel(99)
    end
end
-- チャットフレーム改造
function mini_addons_update_chat_frame()
    function mini_addons_chat_frame_dorop(frame)
        g.settings.chat_xy.x = frame:GetX()
        g.settings.chat_xy.y = frame:GetY()
        MINI_ADDONS_SAVE_SETTINGS()
    end
    local chat = ui.GetFrame("chat")
    chat:RemoveChild("pos_btn")
    chat:RemoveChild("party_btn")
    chat:RemoveChild("item_btn")

    chat:Resize(chat:GetOriginalWidth(), chat:GetOriginalHeight())
    chat:SetPos(g.settings.chat_xy.x or chat:GetX(), g.settings.chat_xy.y or chat:GetY())
    chat:SetEventScript(ui.LBUTTONUP, "mini_addons_chat_frame_dorop")
    local mainchat = GET_CHILD(chat, "mainchat")
    AUTO_CAST(mainchat)
    local edit_bg = GET_CHILD(chat, "edit_bg");
    AUTO_CAST(edit_bg)
    local edit_to_bg = GET_CHILD(chat, 'edit_to_bg')
    AUTO_CAST(edit_to_bg)
    mainchat:SetGravity(ui.LEFT, ui.TOP)
    edit_to_bg:SetGravity(ui.LEFT, ui.TOP)
    if g.settings.chat_new_btn == 0 then
        return
    end
    -- local margin = chat:GetMargin()
    chat:Resize(585, chat:GetOriginalHeight())
    edit_bg:Resize(567, 36)
    mainchat:SetGravity(ui.LEFT, ui.TOP)
    mainchat:Resize(585, mainchat:GetOriginalHeight())
    edit_to_bg:SetGravity(ui.LEFT, ui.TOP)
    -- chat:SetMargin(margin.left, margin.top, margin.right, margin.bottom)
    chat:SetPos(g.settings.chat_xy.x or chat:GetX(), g.settings.chat_xy.y or chat:GetY())
    local button_emo = GET_CHILD(chat, "button_emo");
    local x = button_emo:GetX() - 35
    function mini_addons_my_pos()
        local map_frame = ui.GetFrame("map");
        local map_pic = GET_CHILD(map_frame, "map");
        local my_pos = GET_CHILD(map_frame, "my");
        local x, y = GET_C_XY(my_pos);
        x = x + (my_pos:GetWidth() / 2) - map_pic:GetX();
        y = y + (my_pos:GetHeight() / 2) - map_pic:GetY();
        local map_name = session.GetMapName();
        local map_prop = geMapTable.GetMapProp(map_name);
        local worldPos = map_prop:MinimapPosToWorldPos(x, y, map_pic:GetWidth(), map_pic:GetHeight());
        LINK_MAP_POS(map_name, worldPos.x, worldPos.y);
    end
    local pos_btn = chat:CreateOrGetControl("button", "pos_btn", 0, 0, 0, 0)
    AUTO_CAST(pos_btn)
    pos_btn:SetPos(x, 0)
    pos_btn:SetClickSound("button_click");
    pos_btn:SetOverSound("button_cursor_over_2");
    pos_btn:SetAnimation("MouseOnAnim", "btn_mouseover");
    pos_btn:SetAnimation("MouseOffAnim", "btn_mouseoff");
    pos_btn:SetEventScript(ui.LBUTTONDOWN, "mini_addons_my_pos");
    pos_btn:SetImage("button_pos_img");
    pos_btn:Resize(39, 39);

    local party_btn = chat:CreateOrGetControl("button", "party_btn", 0, 0, 0, 0);
    AUTO_CAST(party_btn)
    party_btn:SetPos(x - 32, 0)
    party_btn:SetClickSound("button_click");
    party_btn:SetOverSound("button_cursor_over_2");
    party_btn:SetAnimation("MouseOnAnim", "btn_mouseover");
    party_btn:SetAnimation("MouseOffAnim", "btn_mouseoff");
    party_btn:SetEventScript(ui.LBUTTONDOWN, "LINK_PARTY_INVITE");
    party_btn:SetImage("btn_partyshare");
    party_btn:Resize(36, 36);

    function mini_addons_toggle_inventory()
        ui.ToggleFrame("inventory")
    end

    local item_btn = chat:CreateOrGetControl("button", "item_btn", 0, 0, 0, 0);
    AUTO_CAST(party_btn)
    item_btn:SetPos(x - 70, 0)
    item_btn:SetClickSound("button_click");
    item_btn:SetOverSound("button_cursor_over_2");
    item_btn:SetAnimation("MouseOnAnim", "btn_mouseover");
    item_btn:SetAnimation("MouseOffAnim", "btn_mouseoff");
    item_btn:SetSkinName("textbutton")
    item_btn:SetEventScript(ui.LBUTTONDOWN, "mini_addons_toggle_inventory");
    item_btn:SetText("{img sysmenu_inv 42 42}")
    item_btn:Resize(40, 37);
    item_btn:SetTextTooltip(g.lang == "Japanese" and "" or "")
    chat:Invalidate()
end

function mini_addons_INVENTORY_OP_POP(my_frame, my_msg)
    if g.settings.chat_new_btn == 0 then
        return
    end
    local chat = ui.GetFrame("chat")
    if chat:IsVisible() == 0 then
        return
    end
    if keyboard.IsKeyPressed("LCTRL") == 1 then
        return
    end
    local frame, slot, str, num = g.get_event_args(my_msg)
    local icon = slot:GetIcon()
    local icon_info = icon:GetInfo()
    local iesid = icon_info:GetIESID()
    local invItem = session.GetInvItemByGuid(iesid)
    LINK_ITEM_TEXT(invItem)
end
-- チャットフレーム改造　ここまで

-- ボスレランキング ここから
local base_jobids = {1001, 2001, 3001, 4001, 5001}
local processed_job_ids = {}
local result_tbl = {}
local existing_data_check = {}
local start_time = 0
function mini_addons_INDUNINFO_UI_CLOSE()
    local induninfo = ui.GetFrame("induninfo")
    local rankListBox = GET_CHILD_RECURSIVELY(induninfo, "rankListBox")
    AUTO_CAST(rankListBox)
    if rankListBox:HaveUpdateScript("mini_addons_get_weekly_boss_data") == false then
        return
    end
    rankListBox:StopUpdateScript("mini_addons_get_weekly_boss_data")
    rankListBox:StopUpdateScript("mini_addons_get_weekly_boss_damage")
    local induninfo_class_selector = ui.GetFrame("induninfo_class_selector")
    induninfo_class_selector:SetEnable(1)
    local msg = g.lang == "Japanese" and
                    "データ取得処理を終了します{nl}データは保存出来ていません" or
                    "Data acquisition process terminated{nl}The data could not be saved"
    imcAddOn.BroadMsg("NOTICE_Dm_!", msg, 3.0)
end

function mini_addons_WEEKLYBOSS_PATTERNINFO_UI_UPDATE(frame, msg, str, num)
    if g.settings.boss_rank == 0 then
        return
    end
    local induninfo = ui.GetFrame("induninfo")
    local rank_gb = GET_CHILD_RECURSIVELY(induninfo, "rank_gb")
    local data_btn = rank_gb:CreateOrGetControl('button', 'data_btn', -4, 300, 52, 52)
    AUTO_CAST(data_btn)
    data_btn:SetSkinName("None")
    data_btn:SetText("{img indun_season_tap 52 52}")
    local tooltip = g.lang == "Japanese" and "{ol}データ取得" or "{ol}Data Acquisition"
    data_btn:SetTextTooltip(tooltip)
    local data_btn_text = data_btn:CreateOrGetControl('richtext', 'data_btn_text', 10, 15, 0, 20)
    AUTO_CAST(data_btn_text)
    data_btn_text:SetText("{ol}data")
    data_btn_text:SetTextTooltip(tooltip)
    data_btn_text:SetEventScript(ui.LBUTTONUP, "mini_addons_get_weekly_boss_data_context")
    data_btn:SetEventScript(ui.LBUTTONUP, "mini_addons_get_weekly_boss_data_context")
    local rank_btn = rank_gb:CreateOrGetControl('button', 'rank_btn', -4, 354, 52, 52)
    AUTO_CAST(rank_btn)
    rank_btn:SetSkinName("None")
    rank_btn:SetText("{img indun_season_tap 52 52}") -- tab2
    local tooltip = g.lang == "Japanese" and "{ol}ランキング表示" or "{ol}Show Leaderboard"
    rank_btn:SetTextTooltip(tooltip)
    local rank_btn_text = rank_btn:CreateOrGetControl('richtext', 'rank_btn_text', 10, 15, 0, 20)
    AUTO_CAST(rank_btn_text)
    rank_btn_text:SetText("{ol}rank")
    rank_btn_text:SetTextTooltip(tooltip)
    rank_btn_text:SetEventScript(ui.LBUTTONUP, "mini_addons_create_ranking_data")
    rank_btn:SetEventScript(ui.LBUTTONUP, "mini_addons_create_ranking_data")
end

function mini_addons_create_ranking_data()
    local induninfo = ui.GetFrame("induninfo")
    local file_path = string.format("../addons/%s/log.dat", addon_name_lower)
    local log_data = g.load_dat(file_path)
    if not log_data then
        local msg = g.lang == "Japanese" and
                        "ランキングデータが未取得です{nl}ランキングデータを取得してください" or
                        "Ranking data has not been acquired{nl}Please acquire the ranking data"
        ui.SysMsg(msg)
        return
    end
    local week_num = session.weeklyboss.GetNowWeekNum()
    local season_tab = GET_CHILD_RECURSIVELY(induninfo, "season_tab")
    local season_index = season_tab:GetSelectItemIndex()
    local season = week_num - season_index
    local is_save = true
    local checked_jobs = {}
    local all_derived_jobs = {}
    local function get_base_jobid_local(job_cls_id)
        if not job_cls_id then
            return nil
        end
        return job_cls_id - (job_cls_id % 1000) + 1
    end
    for _, base_id in ipairs(base_jobids) do
        local job_list = GET_JOB_LIST(base_id)
        for _, job_cls in ipairs(job_list) do
            local job_id = TryGetProp(job_cls, "ClassID", 0)
            if job_id ~= 0 and job_id % 100 ~= 1 then
                all_derived_jobs[job_id] = false -- チェックリストをfalseで初期化
            end
        end
    end
    for _, record in ipairs(log_data) do
        local week_num_ = tonumber(record[1])
        if week_num_ == season then
            local job_id = tonumber(record[2])
            local is_confirmed_str = record[7]
            if is_confirmed_str == "false" then
                is_save = false
                break
            end
            if all_derived_jobs[job_id] ~= nil then
                all_derived_jobs[job_id] = true
            end
        end
    end
    if is_save then
        for job_id, checked in pairs(all_derived_jobs) do
            if not checked then
                is_save = false
                break
            end
        end
    end
    local player_data = {}
    for _, record in ipairs(log_data) do
        local week_num_ = tonumber(record[1])
        if week_num_ == season then
            local job_id = tonumber(record[2])
            local name = record[4]
            local damage = tonumber(record[5])
            if not player_data[name] then
                player_data[name] = {
                    all_jobs = {},
                    max_damage = 0
                }
            end
            if #player_data[name].all_jobs < 4 then
                local found = false
                for _, existing_id in ipairs(player_data[name].all_jobs) do
                    if existing_id == job_id then
                        found = true;
                        break
                    end
                end
                if not found then
                    table.insert(player_data[name].all_jobs, job_id)
                end
            end
            if damage > player_data[name].max_damage then
                player_data[name].max_damage = damage
            end
        end
    end
    local ranking_list = {}
    for name, data in pairs(player_data) do
        table.insert(ranking_list, {
            name = name,
            damage = data.max_damage,
            all_jobs = data.all_jobs
        })
    end
    table.sort(ranking_list, function(a, b)
        return a.damage > b.damage
    end)
    local display_data_list = {}
    for i, data in ipairs(ranking_list) do
        if i > 100 then
            break
        end
        local base_job_id = nil
        local derived_jobs = {}
        local base_id_counts = {}
        for _, job_id in ipairs(data.all_jobs) do
            if job_id % 100 == 1 then
                base_job_id = job_id
            else
                table.insert(derived_jobs, job_id)
                local b_id = get_base_jobid_local(job_id)
                if b_id then
                    base_id_counts[b_id] = (base_id_counts[b_id] or 0) + 1
                end
            end
        end
        if not base_job_id and #derived_jobs > 0 then
            local max_count = 0
            for b_id, count in pairs(base_id_counts) do
                if count > max_count then
                    max_count = count
                    base_job_id = b_id
                end
            end
        end
        local build_parts = {}
        if base_job_id then
            table.insert(build_parts, base_job_id)
        end
        for _, job_id in ipairs(derived_jobs) do
            table.insert(build_parts, job_id)
        end
        table.insert(display_data_list, {
            season = season,
            rank = i,
            name = data.name,
            damage = data.damage,
            build = build_parts
        })
        local build_str = table.concat(build_parts, ", ")
    end
    mini_addons_create_ranking_data_frame(display_data_list, is_save)
end

function mini_addons_ranking_close(frame)
    local frame_name = frame:GetName()
    ui.DestroyFrame(frame_name)
end

function mini_addons_create_ranking_data_frame(ranking_data, is_save)
    if not ranking_data or #ranking_data == 0 then
        local msg = g.lang == "Japanese" and
                        "ランキングデータが未取得です{nl}ランキングデータを取得してください" or
                        "Ranking data has not been acquired{nl}Please acquire the ranking data"
        ui.SysMsg(msg)
        return
    end
    local induninfo = ui.GetFrame("induninfo")
    local rank_frame = ui.CreateNewFrame("notice_on_pc", addon_name_lower .. "rank_frame", 0, 0, 0, 0)
    AUTO_CAST(rank_frame)
    rank_frame:SetSkinName("test_frame_low")
    rank_frame:SetLayerLevel(102)
    rank_frame:EnableHittestFrame(1)
    rank_frame:ShowTitleBar(0)
    rank_frame:RemoveAllChild()
    local season = ranking_data[1].season
    local status_text = ""
    if is_save == false then
        status_text = " (Unconfirmed)"
    else
        status_text = " (Confirmed)"
    end
    local title = rank_frame:CreateOrGetControl("richtext", "title", 30, 10)
    AUTO_CAST(title)
    title:SetText("{@st66b18}Weekly Ranking [" .. season .. "] week" .. status_text)
    local gbox = rank_frame:CreateOrGetControl("groupbox", "gbox", 10, 30, 0, 0)
    AUTO_CAST(gbox)
    gbox:SetSkinName("bg")
    local close = rank_frame:CreateOrGetControl("button", "close", 0, 0, 30, 30)
    AUTO_CAST(close)
    close:SetGravity(ui.RIGHT, ui.TOP)
    close:SetSkinName("None")
    close:SetText("{img testclose_button 30 30}")
    close:SetEventScript(ui.LBUTTONUP, "mini_addons_ranking_close")
    local y = 10
    local max_rank_width = 0
    local max_name_width = 0
    local max_damage_width = 0
    local temp_rank_text = gbox:CreateOrGetControl("richtext", "temp_rank", 0, 0)
    temp_rank_text:SetText("100.")
    max_rank_width = temp_rank_text:GetWidth()
    temp_rank_text:ShowWindow(0)
    for i, data in ipairs(ranking_data) do
        local temp_name_text = gbox:CreateOrGetControl("richtext", "temp_name_" .. i, 0, 0)
        temp_name_text:SetText("{ol}" .. data.name)
        if temp_name_text:GetWidth() > max_name_width then
            max_name_width = temp_name_text:GetWidth()
        end
        temp_name_text:ShowWindow(0)
        local temp_damage_text = gbox:CreateOrGetControl("richtext", "temp_damage_" .. i, 0, 0)
        temp_damage_text:SetText(string.format("Damage: %d", data.damage))
        if temp_damage_text:GetWidth() > max_damage_width then
            max_damage_width = temp_damage_text:GetWidth()
        end
        temp_damage_text:ShowWindow(0)
    end
    local rank_col_x = 10
    local name_col_x = rank_col_x + max_rank_width
    local icon_col_x = name_col_x + max_name_width
    local damage_col_x = icon_col_x + (4 * 25) - 10
    for i, data in ipairs(ranking_data) do
        local rank_text = gbox:CreateOrGetControl("richtext", "rank_" .. i, rank_col_x, y)
        AUTO_CAST(rank_text)
        rank_text:SetText("{ol}" .. string.format("%d.", data.rank))
        local name_text = gbox:CreateOrGetControl("richtext", "name_" .. i, name_col_x, y)
        AUTO_CAST(name_text)
        name_text:SetText("{ol}" .. data.name)
        local icon_x = icon_col_x
        for j, job_id in ipairs(data.build) do
            if j > 4 then
                break
            end
            local job_cls = GetClassByType('Job', job_id)
            if job_cls then
                local job_icon = gbox:CreateOrGetControl('picture', 'job_icon_' .. i .. '_' .. j, icon_x, y - 5, 25, 25)
                AUTO_CAST(job_icon)
                job_icon:SetImage(job_cls.Icon)
                job_icon:SetEnableStretch(1)
                job_icon:EnableHitTest(1)
                job_icon:SetTooltipType('adventure_book_job_info')
                job_icon:SetTooltipArg(job_id, 0, 0)
                icon_x = icon_x + 25
            end
        end
        local damage_text = gbox:CreateOrGetControl("richtext", "damage_" .. i, damage_col_x, y)
        AUTO_CAST(damage_text)
        damage_text:SetText("{ol}" .. GET_COMMAED_STRING(data.damage))
        local text_width = damage_text:GetWidth()
        local centered_x = damage_col_x + (max_damage_width - text_width) / 2
        damage_text:SetPos(centered_x, y)
        y = y + 30
    end
    local max_x = damage_col_x + max_damage_width
    rank_frame:SetPos(induninfo:GetX() + 20, induninfo:GetY() + 20)
    rank_frame:Resize(max_x + 20, 550)
    gbox:Resize(rank_frame:GetWidth() - 20, rank_frame:GetHeight() - 40)
    gbox:EnableScrollBar(1)
    gbox:SetScrollPos(0);
    rank_frame:ShowWindow(1)
end

function mini_addons_get_weekly_boss_data_context(frame, ctrl, str, num)
    local context = ui.CreateContextMenu("weekly_boss_data", "{ol}WEEKLY BOSS DATA", 0, 0, 0, 0)
    ui.AddContextMenuItem(context, "four weeks", "None")
    for i = 1, #base_jobids do
        local scp = string.format("mini_addons_get_weekly_boss_data_reserve(%d, 1)", base_jobids[i])
        local job_cls = GetClassByType('Job', base_jobids[i])
        ui.AddContextMenuItem(context, job_cls.Name .. " (Data takes about 120 sec)", scp)
    end
    local scp_all_four = string.format("mini_addons_get_weekly_boss_data_reserve(1, 1)")
    ui.AddContextMenuItem(context, "data for all classes (Data takes about 600 sec)", scp_all_four)
    ui.AddContextMenuItem(context, "This week", "None")
    for i = 1, #base_jobids do
        local scp = string.format("mini_addons_get_weekly_boss_data_reserve(%d, 0)", base_jobids[i])
        local job_cls = GetClassByType('Job', base_jobids[i])
        ui.AddContextMenuItem(context, job_cls.Name .. " (Data takes about 30 sec)", scp)
    end
    local scp_all_this = string.format("mini_addons_get_weekly_boss_data_reserve(0, 0)")
    ui.AddContextMenuItem(context, "data for all classes (Data takes about 150 sec)", scp_all_this)
    ui.OpenContextMenu(context)
end

function mini_addons_save_log()
    local file_path = string.format("../addons/%s/log.dat", addon_name_lower)
    local existing_records = g.load_dat(file_path) or {}
    local new_records_check = {}
    for _, new_record in ipairs(result_tbl) do
        local week_str = tostring(new_record[1])
        local job_id_str = tostring(new_record[2])
        if not new_records_check[week_str] then
            new_records_check[week_str] = {}
        end
        new_records_check[week_str][job_id_str] = true
    end
    local final_records_to_save = {}
    if #existing_records > 0 then
        for _, old_record in ipairs(existing_records) do
            local old_week_str, old_job_id_str = old_record[1], old_record[2]
            if not (new_records_check[old_week_str] and new_records_check[old_week_str][old_job_id_str]) then
                table.insert(final_records_to_save, old_record)
            end
        end
    end
    for _, new_record in ipairs(result_tbl) do
        table.insert(final_records_to_save, new_record)
    end
    local lines_to_write = {}
    for _, record in ipairs(final_records_to_save) do
        table.insert(lines_to_write, table.concat(record, ":::"))
    end
    local content_to_write = table.concat(lines_to_write, "\n")
    local file = io.open(file_path, "w")
    if file then
        file:write(content_to_write)
        file:close()
        -- print("log.datに結果を保存しました。")
    else
        -- print("エラー: log.datを開けませんでした。")
    end
end

function mini_addons_get_weekly_boss_data_reserve(base_job_id, is_four_weeks)
    result_tbl = {}
    processed_job_ids = {}
    local induninfo = ui.GetFrame("induninfo")
    local rankListBox = GET_CHILD_RECURSIVELY(induninfo, "rankListBox")
    AUTO_CAST(rankListBox)
    rankListBox:SetUserValue("MODE_BASE_ID", base_job_id)
    rankListBox:SetUserValue("MODE_IS_4W", is_four_weeks)
    rankListBox:SetUserValue("B_IDX", 1)
    rankListBox:SetUserValue("C_IDX", 1)
    rankListBox:SetUserValue("W_IDX", 0)
    rankListBox:SetUserValue("SHOULD_SAVE", 0)
    local classtype_tab = GET_CHILD_RECURSIVELY(induninfo, "classtype_tab")
    classtype_tab:SelectTab(0)
    start_time = os.clock()
    local file_path = string.format("../addons/%s/log.dat", addon_name_lower)
    local loaded_data = g.load_dat(file_path)
    if loaded_data then
        for _, record in ipairs(loaded_data) do
            local week_str = record[1]
            local job_id_str = record[2]
            local is_confirmed_str = record[7]
            if is_confirmed_str == "true" then
                processed_job_ids[week_str .. job_id_str] = true
            end
        end
    end
    local induninfo_class_selector = ui.GetFrame("induninfo_class_selector")
    induninfo_class_selector:SetEnable(0)
    local msg = g.lang == "Japanese" and
                    "データ取得を開始します{nl}フレームを閉じずに暫くお待ちください" or
                    "Starting data acquisition{nl}Please wait a moment without closing the frame"
    imcAddOn.BroadMsg("NOTICE_Dm_!", msg, 3.0)
    mini_addons_get_weekly_boss_data(rankListBox)
    rankListBox:RunUpdateScript("mini_addons_get_weekly_boss_data", 1.2)
end

function mini_addons_get_weekly_boss_data(rankListBox)
    local mode_base_id = rankListBox:GetUserIValue("MODE_BASE_ID")
    local mode_is_4w = rankListBox:GetUserIValue("MODE_IS_4W")
    local b_idx = rankListBox:GetUserIValue("B_IDX")
    local c_idx = rankListBox:GetUserIValue("C_IDX")
    local w_idx = rankListBox:GetUserIValue("W_IDX")
    if w_idx == 0 and b_idx == 1 and c_idx == 1 then
        local induninfo = ui.GetFrame("induninfo")
        local season_tab = GET_CHILD_RECURSIVELY(induninfo, "season_tab")
        season_tab:SelectTab(0)
        rankListBox:SetUserValue("CURRENT_WEEK_NUM", WEEKLY_BOSS_RANK_WEEKNUM_NUMBER())
    end
    local current_week_num = rankListBox:GetUserIValue("CURRENT_WEEK_NUM")
    local target_base_jobids
    local is_all_classes_mode = false
    if mode_base_id == 0 or mode_base_id == 1 then
        target_base_jobids = base_jobids
        is_all_classes_mode = true
    else
        target_base_jobids = {mode_base_id}
    end
    local num_weeks = (mode_base_id == 1 or mode_is_4w == 1) and 4 or 1
    if w_idx >= num_weeks then
        local induninfo_class_selector = ui.GetFrame("induninfo_class_selector")
        if induninfo_class_selector:IsVisible() == 1 then
            local classList = GET_CHILD_RECURSIVELY(induninfo_class_selector, "classList")
            if classList then
                AUTO_CAST(classList);
                classList:SetScrollPos(0);
            end
            INDUNINFO_CLASS_SELECTOR_UI_CLOSE(induninfo_class_selector)
        end
        induninfo_class_selector:SetEnable(1)
        local end_time = os.clock()
        local elapsed_time = end_time - start_time
        local msg = g.lang == "Japanese" and
                        string.format("処理が完了しました。所要時間: %.2f 秒", elapsed_time) or
                        string.format("The process is complete. Time elapsed: %.2f seconds", elapsed_time)
        ui.SysMsg(msg)
        return 0
    end
    local current_base_jobid = target_base_jobids[b_idx]
    local job_list = GET_JOB_LIST(current_base_jobid)
    local job_cls = job_list[c_idx]
    local next_b_idx, next_c_idx, next_w_idx = b_idx, c_idx + 1, w_idx
    local should_save_flag = 0
    if next_c_idx > #job_list then
        next_c_idx = 1
        next_b_idx = b_idx + 1
        if is_all_classes_mode then
            should_save_flag = 1
        end
    end
    if next_b_idx > #target_base_jobids then
        next_b_idx = 1
        next_c_idx = 1
        next_w_idx = w_idx + 1
        if not is_all_classes_mode then
            should_save_flag = 1
        end
    end
    if job_cls then
        local job_cls_id = TryGetProp(job_cls, "ClassID", 0)
        local week_offset = (num_weeks == 4) and (3 - w_idx) or 0
        local week_num = current_week_num - week_offset
        local key_to_check = tostring(week_num) .. tostring(job_cls_id)
        if job_cls_id ~= 0 and not processed_job_ids[key_to_check] then
            local induninfo = ui.GetFrame("induninfo")
            local induninfo_class_selector = ui.GetFrame("induninfo_class_selector")
            ui.OpenFrame("induninfo_class_selector")
            local season_tab = GET_CHILD_RECURSIVELY(induninfo, "season_tab")
            season_tab:SelectTab(week_offset)
            local classtype_tab = GET_CHILD_RECURSIVELY(induninfo, "classtype_tab")
            for k = 1, #base_jobids do
                if base_jobids[k] == current_base_jobid then
                    classtype_tab:SelectTab(k - 1)
                    break
                end
            end
            INDUNINFO_CLASS_SELECTOR_FILL_CLASS(current_base_jobid)
            weekly_boss.RequestWeeklyBossRankingInfoList(week_num, job_cls_id)
            local classList = GET_CHILD_RECURSIVELY(induninfo_class_selector, "classList")
            AUTO_CAST(classList)
            local pos = 0
            if c_idx > 18 then
                pos = 180
            elseif c_idx > 12 then
                pos = 120
            elseif c_idx > 6 then
                pos = 60
            end
            classList:SetScrollPos(pos)
            for i = 1, #job_list do
                local list_job = GET_CHILD_RECURSIVELY(induninfo_class_selector, "list_job_" .. i)
                if list_job then
                    local icon = GET_CHILD(list_job, "icon_pic")
                    if icon then
                        AUTO_CAST(icon)
                        if i == c_idx then
                            icon:SetColorTone("FFFFFFFF")
                        else
                            icon:SetColorTone("FF444444")
                        end
                    end
                end
            end
            rankListBox:SetUserValue("JOB_ID", job_cls_id)
            rankListBox:SetUserValue("WEEK_NUM", week_num)
            rankListBox:SetUserValue("SHOULD_SAVE", should_save_flag)
            rankListBox:RunUpdateScript("mini_addons_get_weekly_boss_damage", 0.2)
            processed_job_ids[key_to_check] = true

            rankListBox:SetUserValue("B_IDX", next_b_idx)
            rankListBox:SetUserValue("C_IDX", next_c_idx)
            rankListBox:SetUserValue("W_IDX", next_w_idx)
            rankListBox:StopUpdateScript("mini_addons_get_weekly_boss_data")
            rankListBox:RunUpdateScript("mini_addons_get_weekly_boss_data", 1.2)
            return 0
        end
    end
    rankListBox:SetUserValue("B_IDX", next_b_idx)
    rankListBox:SetUserValue("C_IDX", next_c_idx)
    rankListBox:SetUserValue("W_IDX", next_w_idx)
    rankListBox:StopUpdateScript("mini_addons_get_weekly_boss_data")
    rankListBox:RunUpdateScript("mini_addons_get_weekly_boss_data", 0)
    return 0
end

function mini_addons_get_weekly_boss_damage(rankListBox)

    local induninfo = ui.GetFrame("induninfo")
    local rankListBox = GET_CHILD_RECURSIVELY(induninfo, "rankListBox")
    AUTO_CAST(rankListBox)
    local job_id = rankListBox:GetUserValue("JOB_ID")
    local week_num = tonumber(rankListBox:GetUserValue("WEEK_NUM"))
    if not job_id or not week_num then
        return 0
    end
    local current_week_num = tonumber(rankListBox:GetUserIValue("CURRENT_WEEK_NUM"))
    local is_confirmed = (week_num < current_week_num) and "true" or "false"
    for i = 1, 20 do
        local ctrlset = GET_CHILD(rankListBox, "CTRLSET_" .. i)
        if ctrlset then
            AUTO_CAST(ctrlset)
            local name_ctrl = GET_CHILD(ctrlset, "attr_name_text", "ui::CRichText")
            local name = name_ctrl:GetTextByKey("value")
            local damage = session.weeklyboss.GetRankInfoDamage(i - 1)
            damage = string.gsub(damage, ",", "")
            damage = tonumber(damage)
            local job_cls = GetClassByType('Job', tonumber(job_id))
            local job_name = dic.getTranslatedStr(job_cls.Name)
            local msg = g.lang == "Japanese" and job_name .. " データを取得しました" or job_name ..
                            " Data obtained"
            imcAddOn.BroadMsg("NOTICE_Dm_quest_complete", msg, 1.2)
            local result_data = {week_num, job_id, i, name, damage, job_name, is_confirmed}
            table.insert(result_tbl, result_data)
        else
            if i == 1 then
                local job_cls = GetClassByType('Job', tonumber(job_id))
                local job_name = dic.getTranslatedStr(job_cls.Name)
                local result_data = {week_num, job_id, i, "None", "0", job_name, is_confirmed}
                table.insert(result_tbl, result_data)
            end
            break
        end
    end
    if rankListBox:GetUserIValue("SHOULD_SAVE") == 1 then
        local base_id = tonumber(job_id) - (tonumber(job_id) % 1000) + 1
        local job_cls = GetClassByType('Job', tonumber(base_id))
        local job_name = dic.getTranslatedStr(job_cls.Name)
        local msg = g.lang == "Japanese" and "[" .. week_num .. "] 週の " .. job_name ..
                        " クラスのデータを保存しました" or "Saved data for the [" .. week_num ..
                        "] week's " .. job_name .. " class"
        ui.SysMsg(msg)
        mini_addons_save_log()
        rankListBox:SetUserValue("SHOULD_SAVE", 0)
    end
    return 0
end

function mini_addons_rebuild_log_file(induninfo)
    local file_path = string.format("../addons/%s/log.dat", addon_name_lower)
    local log_data = g.load_dat(file_path)
    if not log_data then
        return 0
    end
    local classtype_tab = GET_CHILD_RECURSIVELY(induninfo, "classtype_tab")
    AUTO_CAST(classtype_tab)
    local cls_index = classtype_tab:GetSelectItemIndex()
    local base_job = base_jobids[cls_index + 1]
    local week_num = session.weeklyboss.GetNowWeekNum()
    local season_tab = GET_CHILD_RECURSIVELY(induninfo, "season_tab")
    AUTO_CAST(season_tab)
    local season_index = season_tab:GetSelectItemIndex()
    local season = week_num - season_index
    local rebuilt_table = {}
    for _, record in ipairs(log_data) do
        local week_num_ = tonumber(record[1])
        local job_id = tonumber(record[2])
        local name = record[4]
        if week_num_ == season and (job_id > base_job and job_id < base_job + 1000) then
            if not rebuilt_table[name] then
                rebuilt_table[name] = {}
            end
            table.insert(rebuilt_table[name], job_id)
        end
    end
    local rankListBox = GET_CHILD_RECURSIVELY(induninfo, "rankListBox")
    AUTO_CAST(rankListBox)
    for i = 1, 20 do
        local ctrlset = GET_CHILD(rankListBox, "CTRLSET_" .. i)
        if ctrlset then
            AUTO_CAST(ctrlset)
            local attr_name_text = GET_CHILD(ctrlset, "attr_name_text")
            if attr_name_text then
                AUTO_CAST(attr_name_text)
                local raw_name = attr_name_text:GetText()
                local job_ids = rebuilt_table[raw_name]
                for j = 1, 3 do
                    local icon = GET_CHILD(ctrlset, 'job_icon' .. j)
                    if icon then
                        icon:ShowWindow(0)
                    end
                end
                local nodata = GET_CHILD(ctrlset, 'nodata_' .. i)
                if nodata then
                    nodata:ShowWindow(0)
                end
                if job_ids then
                    local rect = attr_name_text:GetMargin()
                    attr_name_text:SetMargin(rect.left, rect.top + 4, rect.right, rect.bottom)
                    for j = 1, 3 do
                        local job_id = job_ids[j]
                        if job_id then
                            local job_cls = GetClassByType('Job', job_id)
                            if job_cls then
                                local job_icon = ctrlset:CreateOrGetControl('picture', 'job_icon' .. j,
                                    (attr_name_text:GetWidth() + ((j - 1) * 30)), 5, 30, 30)
                                AUTO_CAST(job_icon)
                                job_icon:SetImage(job_cls.Icon)
                                job_icon:SetEnableStretch(1)
                                job_icon:EnableHitTest(1)
                                ctrlset:EnableHitTest(1)
                                job_icon:SetTooltipType('adventure_book_job_info')
                                job_icon:SetTooltipArg(job_id, 0, 0)
                                job_icon:ShowWindow(1)
                            end
                        end
                    end
                else
                    local nodata = ctrlset:CreateOrGetControl('richtext', 'nodata_' .. i, attr_name_text:GetWidth(), 10,
                        30, 30)
                    AUTO_CAST(nodata)
                    nodata:SetText("{#000000}No data")
                    nodata:ShowWindow(1)
                end
            end
        end
    end
    return 0
end

function mini_addons_WEEKLY_BOSS_RANK_UPDATE()
    if g.settings.boss_rank == 0 then
        return
    end
    local induninfo = ui.GetFrame("induninfo")
    local rankListBox = GET_CHILD_RECURSIVELY(induninfo, "rankListBox")
    AUTO_CAST(rankListBox)
    if rankListBox:HaveUpdateScript("mini_addons_get_weekly_boss_data") == false then
        mini_addons_rebuild_log_file(induninfo)
    end
end
-- ボスレランキング　ここまで

-- パーティーメンバーの場所表示
function mini_addons_partymember_get_map()

    if g.settings.pt_info == 0 then
        return
    end
    --[[local pcparty = session.party.GetPartyInfo()
    if pcparty == nil then
        return;
    end]]
    local list = session.party.GetPartyMemberList(PARTY_NORMAL)
    local count = list:Count()
    if count == 1 then
        return
    end
    local party = ui.GetFrame("party")
    if party:IsVisible() == 1 then
        return
    end
    for i = 0, count - 1 do
        local partyMemberInfo = list:Element(i)
        if partyMemberInfo and partyMemberInfo:GetMapID() > 0 then
            local map_cls = GetClassByType("Map", partyMemberInfo:GetMapID())
            if map_cls then
                local partyinfo = ui.GetFrame("partyinfo")
                local partyInfoCtrlSet = partyinfo:GetChild('PTINFO_' .. partyMemberInfo:GetAID());
                if partyInfoCtrlSet then
                    local location = partyInfoCtrlSet:CreateOrGetControl('richtext', "location" .. i, 0, 0, 0, 0)
                    AUTO_CAST(location)
                    location:SetText(string.format("{s12}{ol}[%s-%d]", map_cls.Name, partyMemberInfo:GetChannel() + 1))
                    location:Resize(100, 20)
                    location:SetOffset(10, 0)
                    location:ShowWindow(1)

                    local lvbox = partyInfoCtrlSet:GetChild('lvbox')
                    local name_text = partyInfoCtrlSet:GetChild('name_text')
                    if lvbox and name_text then
                        AUTO_CAST(lvbox)
                        AUTO_CAST(name_text)
                        local name_x = lvbox:GetX() + lvbox:GetWidth()
                        name_text:SetPos(name_x, -12)
                    end
                end
            end
        end
    end
end
-- パーティーメンバーの場所表示　ここまで

-- スキル錬成のスロットにツールチップ
function mini_addons_COMMON_SKILL_ENCHANT_SET_GB(my_frame, my_msg)

    if g.settings.enchant_tooltip == 0 then
        return
    end
    local gb, index, argStr1, argStr2 = g.get_event_args(my_msg)
    AUTO_CAST(gb)
    local cls_list, count = GetClassList("Skill")
    for i = 1, 2 do
        local mat_slot = GET_CHILD_RECURSIVELY(gb, "mat_slot" .. index)
        local text = GET_CHILD_RECURSIVELY(gb, "mat_name" .. index)
        if text:IsVisible() == 1 then
            local icon = mat_slot:GetIcon()
            if icon then
                AUTO_CAST(mat_slot)
                mat_slot:EnableHitTest(1)
                for j = 0, count - 1 do
                    AUTO_CAST(icon)
                    local skill_cls = GetClassByIndexFromList(cls_list, j)
                    if skill_cls then
                        local skill_cls_name = skill_cls.ClassName
                        if tostring(skill_cls_name) == tostring(argStr1) then
                            local skill_id = skill_cls.ClassID
                            SET_SLOT_SKILL_BY_LEVEL(mat_slot, skill_id, tonumber(argStr2))
                            break
                        end
                    end
                end
            end
        end
    end
end
-- スキル錬成のスロットにツールチップ ここまで

-- 製造自動セット
local make_count = 0
function mini_addons_itemcraft_item_set(itemSet, slot, recipeItemCnt_str, cls_id)
    imcSound.PlaySoundEvent('inven_equip')
    AUTO_CAST(slot)

    local needcount = tonumber(recipeItemCnt_str)
    local itemname = itemSet:GetUserValue("ClassName")
    local invItem = session.GetInvItemByName(itemname)

    if true == invItem.isLockState then
        ui.SysMsg(ClMsg("MaterialItemIsLock"));
        return
    end

    if invItem.type == cls_id and invItem.count >= needcount then
        if make_count > invItem.count / needcount or make_count == 0 then
            make_count = invItem.count / needcount
        end
        session.AddItemID(invItem:GetIESID(), needcount)
        local icon = slot:GetIcon()
        icon:SetColorTone('FFFFFFFF')
        itemSet:SetUserValue("MATERIAL_IS_SELECTED", 'selected')
        local number = slot:CreateOrGetControl("richtext", "number", 0, 0, slot:GetWidth(), 20)
        AUTO_CAST(number)
        number:SetText("{ol}" .. invItem.count)
    else
        make_count = 0
    end
    local top_frame = itemSet:GetTopParentFrame()
    local upDown = GET_CHILD_RECURSIVELY(top_frame, "upDown", "ui::CNumUpDown")
    upDown:SetNumberValue(make_count)
    local btn = GET_CHILD(itemSet, "btn", "ui::CButton")
    if btn then
        AUTO_CAST(btn)
        btn:ShowWindow(0)
    end
    local invframe = ui.GetFrame('inventory')
    INVENTORY_UPDATE_ICONS(invframe)
end

function mini_addons_CRAFT_RECIPE_FOCUS(my_frame, my_msg)

    if g.settings.auto_craft == 0 then
        return
    end
    local page, ctrlSet = g.get_event_args(my_msg)
    make_count = 0
    for i = 1, 5 do
        local itemSet = GET_CHILD(ctrlSet, "EACHMATERIALITEM_" .. i)
        AUTO_CAST(itemSet)
        local slot = GET_CHILD(itemSet, "slot")
        AUTO_CAST(slot)
        DESTROY_CHILD_BYNAME(slot, "number")
        local top_frame = page:GetTopParentFrame()
        local idSpace = top_frame:GetUserValue("IDSPACE")
        local recipecls = GetClass(idSpace, ctrlSet:GetName())
        local recipeItemCnt, invItemCnt, dragRecipeItem, invItem, recipeItemLv, invItemlist = GET_RECIPE_MATERIAL_INFO(
            recipecls, i)
        local recipeItemCnt_str = tostring(recipeItemCnt)
        local cls_id = dragRecipeItem.ClassID
        mini_addons_itemcraft_item_set(itemSet, slot, recipeItemCnt_str, cls_id)
    end
end

function mini_addons_CRAFT_START_CRAFT(idSpace, recipeName, totalCount, upDown)
    if g.settings.auto_craft == 0 then
        return
    end
    local idSpace, recipeName, totalCount, upDown
    local itemcraft = ui.GetFrame("itemcraft")
    if itemcraft then
        itemcraft:RunUpdateScript("CREATE_CRAFT_ARTICLE", 8.2)
    end
end
-- 製造自動セット ここまで

-- ちょい残し　ここから
local reward_map = {"125000", "2000000", "5000000", "10000000", "18750000", "25000000", "37500000", "50000000",
                    "125000000", "175000000", "250000000", "300000000", "375000000", "625000000", "750000000",
                    "1250000000", "1750000000"}
function mini_addons_WEEKLYBOSSREWARD_REWARD_OPEN(my_frame, my_msg)
    local index = g.get_event_args(my_msg)

    local weeklyboss_reward = ui.GetFrame("weeklyboss_reward")
    local my_btn = GET_CHILD(weeklyboss_reward, "my_btn")
    if my_btn then
        AUTO_CAST(my_btn)
        my_btn:StopUpdateScript("mini_addons_get_damage_reward")
        DESTROY_CHILD_BYNAME(weeklyboss_reward, my_btn:GetName())
    end
    if g.settings.keep_first == 0 then
        return
    end
    local btn_reward = GET_CHILD(weeklyboss_reward, "btn_reward")
    AUTO_CAST(btn_reward)
    if index ~= 1 or btn_reward:IsEnable() == 0 then
        return
    end
    local my_btn = weeklyboss_reward:CreateOrGetControl("button", "my_btn", 315, 655, 120, 40)
    AUTO_CAST(my_btn)
    my_btn:SetText("{ol}keep first")
    my_btn:SetEventScript(ui.LBUTTONUP, "mini_addons_start_get_reward")
    local amount_str = reward_map[#reward_map]
    my_btn:SetEventScriptArgString(ui.LBUTTONUP, amount_str)
    my_btn:SetEventScriptArgNumber(ui.LBUTTONUP, #reward_map)
end

function mini_addons_start_get_reward(weeklyboss_reward, my_btn, amount_str, index_num)
    local reward = GET_CHILD_RECURSIVELY(weeklyboss_reward, "REWARD_" .. index_num)
    local attr_btn = GET_CHILD(reward, "attr_btn")
    if attr_btn and attr_btn:IsEnable() == 1 then
        local week_num = weeklyboss_reward:GetUserValue("WEEK_NUM")
        weekly_boss.RequestAcceptAbsoluteReward(week_num, amount_str)
    end
    my_btn:SetUserValue("REWARD_INDEX", index_num - 1)
    my_btn:RunUpdateScript("mini_addons_get_damage_reward", 0.3)
end

function mini_addons_get_damage_reward(my_btn)
    local index = my_btn:GetUserIValue("REWARD_INDEX")
    if not index or index < 2 then
        return 0
    end
    local weeklyboss_reward = my_btn:GetParent()
    local reward = GET_CHILD_RECURSIVELY(weeklyboss_reward, "REWARD_" .. index)

    if reward then
        local attr_btn = GET_CHILD(reward, "attr_btn")
        if attr_btn:IsEnable() == 1 then
            local week_num = weeklyboss_reward:GetUserValue("WEEK_NUM")
            weekly_boss.RequestAcceptAbsoluteReward(week_num, reward_map[index])
            return 1
        else
            my_btn:SetUserValue("REWARD_INDEX", index - 1)
            return 1
        end
        return 1
    end
    return 0
end
-- ちょい残し　ここまで

-- 追加報酬券チェック ここから
local multiple_tokens = {
    ["Goddess_Raid_DespairIsland_Party"] = {11200361, 11200362},
    ["Goddess_Raid_BlackRevelation_Party"] = {11200387, 11200388},
    ["Goddess_Raid_CollapsingMine_Party"] = {11200395, 11200396},
    ["Goddess_Raid_Redania_Party"] = {11200403, 11200404},
    ["Goddess_Raid_Laimara_Party"] = {11200434, 11200435},
    ["Goddess_Raid_Veliora_Party"] = {11200438, 11200439}
    --[[["Goddess_Raid_Redania_Solo"] = {490005}
    ["Goddess_Raid_Veliora_Solo"] = {490005},
    ["Goddess_Raid_Roze_Party"] = {490005},
    ["Goddess_Raid_DespairIsland_Solo"] = {490005},
    ["Goddess_Raid_CollapsingMine_Solo"] = {490005},
    ["Goddess_Raid_BlackRevelation_Solo"] = {490005}]]
}
local function has_inv_item(target_cls_id)
    local inv_item_list = session.GetInvItemList()
    local guid_list = inv_item_list:GetGuidList()
    local cnt = guid_list:Count()
    for i = 0, cnt - 1 do
        local guid = guid_list:Get(i)
        local inv_item = inv_item_list:GetItemByGuid(guid)
        if inv_item and inv_item.type == target_cls_id then
            return true
        end
    end
    return false
end

function mini_addons_REQ_PLAYER_CONTENTS_RECORD(frame, msg)
    local current_raid_name = session.mgame.GetCurrentMGameName()
    local target_tokens = multiple_tokens[current_raid_name]
    if not target_tokens then
        return
    end
    for _, token_id in ipairs(target_tokens) do
        if has_inv_item(token_id) then
            local msg = g.lang == "Japanese" and "追加報酬券持ってるで！！" or
                            "I've got Additional Reward Tickets!"
            _G.imcAddOn.BroadMsg('NOTICE_Dm_Global_Shout', "{st55_a}{#FF8C00}" .. msg, 10)
            if _G["NICO_CHAT"] then
                for j = 1, 10 do
                    NICO_CHAT(string.format("{@st55_a}%s", msg))
                end
            end
            return 0
        end
    end
end
-- 追加報酬券チェック ここまで

function mini_addons_GAME_START_3SEC(frame, msg, str, num)
    -- 追加報酬券チェック
    g.addon:RegisterMsg('REQ_PLAYER_CONTENTS_RECORD', 'mini_addons_REQ_PLAYER_CONTENTS_RECORD')

    -- チャットフレーム改造
    if type(_G["ZCHATEXTENDS_ON_INIT"]) ~= "function" then
        mini_addons_update_chat_frame()
        g.setup_hook_and_event(g.addon, "INVENTORY_OP_POP", "mini_addons_INVENTORY_OP_POP", true)
    elseif g.settings.chat_new_btn == 1 then
        g.settings.chat_new_btn = 0
        MINI_ADDONS_SAVE_SETTINGS()
    end

    -- ちょい残しボタンcuervoexから移植
    g.setup_hook_and_event(g.addon, "WEEKLYBOSSREWARD_REWARD_OPEN", "mini_addons_WEEKLYBOSSREWARD_REWARD_OPEN", true)

    -- スキル錬成のスロットにツールチップ
    g.setup_hook_and_event(g.addon, "COMMON_SKILL_ENCHANT_SET_GB", "mini_addons_COMMON_SKILL_ENCHANT_SET_GB", true)

    -- グループチャット機能
    if g.settings.group_chat == 1 then
        g.setup_hook_and_event(g.addon, "CHAT_GROUPLIST_SELECT_LISTTYPE", "mini_addons_CHAT_GROUPLIST_SELECT_LISTTYPE_",
            true)
        frame:RunUpdateScript("mini_addons_CHAT_GROUPLIST_SELECT_LISTTYPE", 1.0)
        g.setup_hook_and_event(g.addon, "CHAT_GROUPLIST_OPTION_OK", "mini_addons_CHAT_GROUPLIST_OPTION_OK", true)
        g.setup_hook_and_event(g.addon, "CHAT_SET_TO_TITLENAME", "mini_addons_CHAT_SET_TO_TITLENAME", true)
    end

    -- ボスレランキング
    g.addon:RegisterMsg('WEEKLY_BOSS_UI_UPDATE', 'mini_addons_WEEKLYBOSS_PATTERNINFO_UI_UPDATE')
    g.setup_hook_and_event(g.addon, "WEEKLY_BOSS_RANK_UPDATE", "mini_addons_WEEKLY_BOSS_RANK_UPDATE", true)
    g.setup_hook_and_event(g.addon, "INDUNINFO_UI_CLOSE", "mini_addons_INDUNINFO_UI_CLOSE", true)

    -- 製造自動セット
    g.setup_hook_and_event(g.addon, "CRAFT_RECIPE_FOCUS", "mini_addons_CRAFT_RECIPE_FOCUS", true)
    g.setup_hook_and_event(g.addon, "CRAFT_START_CRAFT", "mini_addons_CRAFT_START_CRAFT", true)

    -- PTメンバーの死亡と復活をNICO_CHATで流す
    if g.settings.chat_recv == 1 then
        local chat_option = ui.GetFrame("chat_option")
        local resurrectCheck_party = GET_CHILD_RECURSIVELY(chat_option, "resurrectCheck_party")
        AUTO_CAST(resurrectCheck_party)
        resurrectCheck_party:SetCheck(1)
        g.setup_hook_and_event(g.addon, "DRAW_CHAT_MSG", "MINI_ADDONS_DRAW_CHAT_MSG", true)
    end
    -- どこでもメンバーインフォ
    g.setup_hook_and_event(g.addon, "CHAT_RBTN_POPUP", "MINI_ADDONS_CHAT_RBTN_POPUP", false)
    g.setup_hook_and_event(g.addon, "POPUP_GUILD_MEMBER", "MINI_ADDONS_POPUP_GUILD_MEMBER", false)
    g.setup_hook_and_event(g.addon, "CONTEXT_PARTY", "MINI_ADDONS_CONTEXT_PARTY", false)
    g.setup_hook_and_event(g.addon, "SHOW_PC_CONTEXT_MENU", "MINI_ADDONS_SHOW_PC_CONTEXT_MENU", false)
    g.setup_hook_and_event(g.addon, "POPUP_DUMMY", "MINI_ADDONS_POPUP_DUMMY", false)
    g.setup_hook_and_event(g.addon, "POPUP_FRIEND_COMPLETE_CTRLSET", "MINI_ADDONS_POPUP_FRIEND_COMPLETE_CTRLSET", false)

    g.call = {}
    g.setup_hook_and_event(g.addon, "NOTICE_ON_MSG", "MINI_ADDONS_NOTICE_ON_MSG_baubas", true)

    g.setup_hook_and_event(g.addon, "SYS_OPTION_OPEN", "MINI_ADDONS_SYS_OPTION_OPEN", true)

    g.setup_hook_and_event(g.addon, "WEEKLY_BOSS_RANK_UPDATE", "MINI_ADDONS_WEEKLY_BOSS_RANK_UPDATE", true)

    -- ヘアエンチャント関係
    g.setup_hook_and_event(g.addon, "HIGH_ENCHANT_OPTION_OPEN_BTN", "mini_addons_HIGH_ENCHANT_OPTION_OPEN_BTN", true)
    g.setup_hook_and_event(g.addon, "HIGH_HAIRENCHANT_CLOSE_BTN", "mini_addons_HIGH_HAIRENCHANT_CLOSE_BTN", true)
    g.setup_hook_and_event(g.addon, "HIGH_HAIRENCHANT_OK_BTN", "mini_addons_HIGH_HAIRENCHANT_OK_BTN", false)

    -- チャットフレーム移動のワイドモニター制限解除
    g.setup_hook_and_event(g.addon, "_PROCESS_MOVE_MAIN_POPUPCHAT_FRAME",
        "mini_addons__PROCESS_MOVE_MAIN_POPUPCHAT_FRAME", false)

    local map = GetClass('Map', session.GetMapName())
    local keyword = TryGetProp(map, 'Keyword', 'None')
    local keyword_table = StringSplit(keyword, '')
    if table.find(keyword_table, 'IsRaidField') > 0 and g.settings.vakarine == 1 then
        MINI_ADDONS_VAKARINE_NOTICE(frame, msg, str, num)
    end

    g.SetupHook(MINI_ADDONS_ICON_USE, "ICON_USE")
    g.SetupHook(MINI_ADDONS_EARTHTOWERSHOP_CHANGECOUNT_NUM_CHANGE, "EARTHTOWERSHOP_CHANGECOUNT_NUM_CHANGE")
    g.SetupHook(MINI_ADDONS_INDUNENTER_REQ_UNDERSTAFF_ENTER_ALLOW, "INDUNENTER_REQ_UNDERSTAFF_ENTER_ALLOW")
    g.SetupHook(MINI_ADDONS_INDUN_EDITMSGBOX_FRAME_OPEN, "INDUN_EDITMSGBOX_FRAME_OPEN")
    if g.settings.velnice.use == 1 then
        g.addon:RegisterMsg("SOLO_D_TIMER_TEXT_GAUGE_UPDATE", "MINI_ADDONS_SOLO_D_TIMER_UPDATE_TEXT_GAUGE")
        g.velnice = 0
    end

    -- IMCのON_PARTYINFO_BUFFLIST_UPDATEを削除
    g.SetupHook(mini_addons_basefunction_old, "ON_PARTYINFO_BUFFLIST_UPDATE")
    g.addon:RegisterMsg("PARTY_BUFFLIST_UPDATE", "MINI_ADDONS_ON_PARTYINFO_BUFFLIST_UPDATE")
    g.addon:RegisterMsg("PARTY_INST_UPDATE", "MINI_ADDONS_ON_PARTYINFO_INST_UPDATE")

    g.SetupHook(MINI_ADDONS_UPDATE_CURRENT_CHANNEL_TRAFFIC, "UPDATE_CURRENT_CHANNEL_TRAFFIC")

    g.setup_hook_and_event(g.addon, "NOTICE_ON_MSG", "MINI_ADDONS_NOTICE_ON_MSG", false)

    g.SetupHook(MINI_ADDONS_CHAT_TEXT_LINKCHAR_FONTSET, "CHAT_TEXT_LINKCHAR_FONTSET")

    g.SetupHook(MINI_ADDONS_INVENTORY_TOTAL_LIST_GET, 'INVENTORY_TOTAL_LIST_GET')

    g.SetupHook(MINI_ADDONS_COMMON_EQUIP_UPGRADE_PROGRESS, "COMMON_EQUIP_UPGRADE_PROGRESS")
    acutil.setupEvent(g.addon, "COMMON_EQUIP_UPGRADE_OPEN", "MINI_ADDONS_COMMON_EQUIP_UPGRADE_OPEN")

    acutil.setupEvent(g.addon, "MARKET_SELL_UPDATE_REG_SLOT_ITEM", "MINI_ADDONS_MARKET_SELL_UPDATE_REG_SLOT_ITEM")
    acutil.setupEvent(g.addon, "OPEN_WORLDMAP2_MINIMAP", "MINI_ADDONS_OPEN_WORLDMAP2_MINIMAP")

    -- レイドレコードの2度呼ばれるバグ修正
    g.addon:RegisterMsg('REQ_PLAYER_CONTENTS_RECORD', 'mini_addons__REQ_PLAYER_CONTENTS_RECORD')
    g.raid_msg = {}
    if g.settings.raid_record == 1 then
        acutil.setupEvent(g.addon, "RAID_RECORD_INIT", "MINI_ADDONS_RAID_RECORD_INIT")
    end

    if g.settings.my_effect == 1 then
        MINI_ADDONS_MY_EFFECT_SETTING(frame, msg, str, num)
    end
    if g.settings.boss_effect == 1 then
        MINI_ADDONS_BOSS_EFFECT_SETTING(frame, msg, str, num)
    end
    if g.settings.other_effect == 1 then
        MINI_ADDONS_OTHER_EFFECT_SETTING(frame, msg, str, num)
    end

    if g.settings.equip_info == 1 then
        acutil.setupEvent(g.addon, "SHOW_INDUNENTER_DIALOG", "MINI_ADDONS_SHOW_INDUNENTER_DIALOG")
    end

    if g.settings.automatch_layer == 1 then
        acutil.setupEvent(g.addon, "INDUNENTER_AUTOMATCH_TYPE", "MINI_ADDONS_INDUNENTER_AUTOMATCH_TYPE")
    elseif g.settings.automatch_layer == 0 then
        local indunenter = ui.GetFrame("indunenter")
        indunenter:SetLayerLevel(100)
    end

    if g.settings.restart_move == 1 then
        g.addon:RegisterMsg("RESTART_HERE", "MINI_ADDONS_FRAME_MOVE")
        g.addon:RegisterMsg("RESTART_CONTENTS_HERE", "MINI_ADDONS_FRAME_MOVE")
        acutil.setupEvent(g.addon, "RESTART_CONTENTS_ON_HERE", "MINI_ADDONS_RESTART_CONTENTS_ON_HERE")
        g.mouse = false
    end

    local restart = ui.GetFrame("restart")
    restart:SetUserValue("COLONY_TIMER_RUNNING", "0")

    g.setup_hook_and_event(g.addon, "RESTART_ON_MSG", "mini_addons_RESTART_ON_MSG", false)

    if g.settings.dialog_ctrl == 1 then
        g.addon:RegisterMsg("DIALOG_CHANGE_SELECT", "MINI_ADDONS_DIALOG_CHANGE_SELECT")
    end

    if g.settings.pc_name == 1 then
        g.addon:RegisterMsg("BUFF_ADD", "MINI_ADDONS_PCNAME_REPLACE")
        g.addon:RegisterMsg("BUFF_UPDATE", "MINI_ADDONS_PCNAME_REPLACE")
    end

    acutil.setupEvent(g.addon, "CONFIG_ENABLE_AUTO_CASTING", "MINI_ADDONS_CONFIG_ENABLE_AUTO_CASTING")
    if g.settings.auto_cast == 1 then
        MINI_ADDONS_SET_ENABLE_AUTO_CASTING_3SEC(frame, msg, str, num)
    end

    if g.settings.channel_info == 1 then
        MINI_ADDONS_GAME_START_CHANNEL_LIST(frame, msg, str, num)
    end

    -- SHOW_PET_RINGCOMMAND
    g.setup_hook_and_event(g.addon, "SHOW_PET_RINGCOMMAND", "mini_addons_SHOW_PET_RINGCOMMAND", false)

    if g.settings.relic_gauge == 1 then
        local map_name = session.GetMapName()
        local colony_cls_list, cnt = GetClassList('guild_colony')
        for i = 0, cnt - 1 do
            local colonyCls = GetClassByIndexFromList(colony_cls_list, i)
            local check_word = "GuildColony_"
            if not string.find(map_name, check_word) then
                MINI_ADDONS_CHARBASE_RELIC(frame, msg, str, num)
                g.addon:RegisterMsg("RP_UPDATE", "MINI_ADDONS_CHARBASE_RELIC")
            end
        end
    end

    if g.settings.raid_check == 1 then
        g.settings.raid_check = 0
        MINI_ADDONS_SAVE_SETTINGS()
    end

    if g.settings.party_info == 1 then
        local partyinfo = ui.GetFrame('partyinfo')
        local tooltip = partyinfo:CreateOrGetControl("richtext", "tooltip", 0, 0, 170, 60)
        AUTO_CAST(tooltip)
        tooltip:SetText("{s30}                             ")
        tooltip:SetTextTooltip("{ol}Right-click to switch display for mouse mode")
        acutil.setupEvent(g.addon, "SET_PARTYINFO_ITEM", "MINI_ADDONS_SET_PARTYINFO_ITEM")
        g.partyinfo = 0
    end

    if session.weeklyboss.GetNowWeekNum() == 0 then
        weekly_boss.RequestWeeklyBossNowWeekNum()
    end

    local pc = GetMyPCObject()
    local curMap = GetZoneName(pc)
    local mapCls = GetClass("Map", curMap)

    local inv = ui.GetFrame("inventory")
    local inventory_accpropinv = GET_CHILD_RECURSIVELY(inv, "inventory_accpropinv")
    AUTO_CAST(inventory_accpropinv)

    if mapCls.MapType == "City" then

        inventory_accpropinv:SetEventScript(ui.RBUTTONUP, "mini_addons_REPUTATION_SHOP_OPEN_context")
        inventory_accpropinv:SetEventScript(ui.RBUTTONDOWN, "mini_addons_reputation_shop_close")

        if g.settings.solodun_reward == 1 and not g.solodun_reward then
            mini_addons_SOLODUNGEON_RANKINGPAGE_GET_REWARD(frame, msg, str, num)
        end

        if g.settings.goodbye_ragana == 1 then
            mini_addons_ragana_remove_timer(frame, msg, str, num)
        end

        if g.settings.weekly_boss_reward == 1 then
            MINI_ADDONS_WEEKLY_BOSS_REWARD(frame, msg, str, num)

        end

        if g.settings.coin_use == 1 then
            MINI_ADDONS_INV_ICON_USE()
            g.addon:RegisterMsg('INV_ITEM_ADD', "MINI_ADDONS_INV_ICON_USE")
            g.addon:RegisterMsg('INV_ITEM_REMOVE', 'MINI_ADDONS_INV_ICON_USE')
        end

        if g.settings.market_display == 1 then
            MINIMIZED_TOTAL_SHOP_BUTTON_CLICK(frame, msg, str, num)
        end

        if g.settings.skill_enchant == 1 then
            acutil.setupEvent(g.addon, "COMMON_SKILL_ENCHANT_MAT_SET", "MINI_ADDONS_COMMON_SKILL_ENCHANT_MAT_SET")
            acutil.setupEvent(g.addon, "SUCCESS_COMMON_SKILL_ENCHANT", "MINI_ADDONS_SUCCESS_COMMON_SKILL_ENCHANT")
        end

        if g.settings.auto_gacha == 1 then
            g.addon:RegisterMsg('FIELD_BOSS_WORLD_EVENT_START', 'MINI_ADDONS_GP_DO_OPEN')
            g.addon:RegisterMsg('FIELD_BOSS_WORLD_EVENT_END', 'MINI_ADDONS_FIELD_BOSS_WORLD_EVENT_END')
        end

        MINI_ADDONS_GP_FULL_BET()

        if g.settings.bgm == 1 then
            g.addon:RegisterMsg("FPS_UPDATE", "MINI_ADDONS_BGM_PLAY_LIST")
            MINI_ADDONS_BGM_PLAY(frame, msg, str, num)
        end

    elseif mapCls.MapType ~= "City" then
        ui.CloseFrame("bgmplayer_reduction")
        local bgmplayer = ui.GetFrame("bgmplayer")
        local play_btn = GET_CHILD_RECURSIVELY(bgmplayer, "playStart_btn")
        MINIADDONS_BGMPLAYER_PLAY(bgmplayer, play_btn)

        inventory_accpropinv:SetEventScript(ui.RBUTTONUP, "None")
        inventory_accpropinv:SetEventScript(ui.RBUTTONDOWN, "None")
    end

    if g.settings.mini_btn == 1 then
        if mapCls.MapType ~= "Field" and mapCls.MapType ~= "City" then
            MINI_ADDONS_MINIMIZED_CLOSE(frame, msg, str, num)
        end
    end

    local sysmenu = ui.GetFrame("sysmenu")

    sysmenu:RunUpdateScript("mini_addons_make_menu", 2.0)
    sysmenu:RunUpdateScript("mini_addons_second_frame", 3.0)

    g.addon:RegisterMsg("FPS_UPDATE", "MINI_ADDONS_FPS_UPDATE")

    mini_addons_toggle_sound_set(frame, msg, str, num)
    mini_addons_toggle_quest_set(frame, msg, str, num)

    g.addon:RegisterMsg('INV_ITEM_ADD', "mini_addons_inventory_open_func")
    g.addon:RegisterMsg('INV_ITEM_REMOVE', "mini_addons_inventory_open_func")
    g.setup_hook_and_event(g.addon, "INVENTORY_OPEN", "mini_addons_INVENTORY_OPEN", true)
    g.addon:RegisterMsg('OPEN_DLG_REROLL_ITEM', 'mini_addons_OPEN_DLG_REROLL_ITEM')

    -- パーティーメンバーの場所表示
    g.addon:RegisterMsg("PARTY_UPDATE", "mini_addons_partymember_get_map");
    g.addon:RegisterMsg("PARTY_BUFFLIST_UPDATE", "mini_addons_partymember_get_map");
    g.addon:RegisterMsg("PARTY_INST_UPDATE", "mini_addons_partymember_get_map");

end

function MINI_ADDONS_FPS_UPDATE()
    mini_addons_autozoom()
    if g.get_map_type() == "City" then
        local coin_get_gauge = ui.GetFrame("coin_get_gauge")
        if config.GetXMLStrConfig('ShowCoinGetGauge') ~= "0" and coin_get_gauge:IsVisible() == 0 then
            coin_get_gauge:ShowWindow(1)
        end
        local market_button = ui.GetFrame('minimized_market_button')
        if g.settings.market_display == 1 and market_button:IsVisible() == 0 then
            MINIMIZED_TOTAL_SHOP_BUTTON_CLICK()
        end
    end

    -- パーティーメンバーの場所表示
    mini_addons_partymember_get_map()

    -- if g.settings.auto_zoom

    -- g.setup_hook_and_event(g.addon, "UPDATE_PARTYINFO_HP", "mini_addons_UPDATE_PARTYINFO_HP", true)

    local restart = ui.GetFrame("restart")
    if restart:IsVisible() == 0 then
        restart:SetUserValue("COLONY_TIMER_RUNNING", "0")
    end
    local norisan_menu_frame = ui.GetFrame("norisan_menu_frame")
    if norisan_menu_frame and norisan_menu_frame:IsVisible() == 0 then
        norisan_menu_frame:ShowWindow(1)
    end
    local mini_addons_channel = ui.GetFrame("mini_addons_channel")
    if g.zone_insts and mini_addons_channel and mini_addons_channel:IsVisible() == 0 then
        mini_addons_channel:ShowWindow(1)
    else
        return
    end
end

function mini_addons_make_menu(frame)
    _G["norisan"] = _G["norisan"] or {}
    _G["norisan"]["MENU"] = _G["norisan"]["MENU"] or {}
    local menu_data = {
        name = "Mini Addons",
        icon = "sysmenu_jal",
        func = "MINI_ADDONS_SETTING_FRAME_INIT",
        image = ""
    }
    _G["norisan"]["MENU"][addon_name] = menu_data
    local frame_name = _G["norisan"]["MENU"].frame_name
    local menu_frame = ui.GetFrame(frame_name)
    if menu_frame and frame_name ~= "norisan_menu_frame" then
        ui.DestroyFrame(frame_name)
    end
    frame_name = "norisan_menu_frame"
    menu_frame = ui.GetFrame(frame_name)
    if not menu_frame or menu_frame:IsVisible() == 0 then
        _G["norisan"]["MENU"].frame_name = frame_name
        g.norisan_menu_create_frame()
        return 1
    end
    return 0
end

function mini_addons_autozoom_edit(frame, ctrl)
    local value = tonumber(ctrl:GetText())
    if value < 1 or value > 700 then
        local errorMsg =
            g.lang == "Japanese" and "無効な値です。1から700の間で設定してください。" or
                "Invalid value please set between 1 and 700"
        ui.SysMsg(errorMsg)
        ctrl:SetText("336")
        g.settings.auto_zoom.zoom = 336
    else
        if value ~= g.settings.auto_zoom.zoom then
            ui.SysMsg("Auto Zoom setting set to " .. value)
            g.settings.auto_zoom.zoom = value
        end
    end
    MINI_ADDONS_SAVE_SETTINGS()
    ctrl:RunUpdateScript("mini_addons_autozoom", 1.0)
end

-- グループチャット機能
function mini_addons_CHAT_GROUPLIST_SELECT_LISTTYPE_(my_frame, my_msg)

    local type = g.get_event_args(my_msg)
    if type ~= 3 then
        return
    end
    mini_addons_CHAT_GROUPLIST_SELECT_LISTTYPE(nil)
end

function mini_addons_CHAT_GROUPLIST_SELECT_LISTTYPE(mini_addons)

    local chat_grouplist = ui.GetFrame("chat_grouplist")
    local listbtn_group = GET_CHILD_RECURSIVELY(chat_grouplist, "listbtn_group")
    local group_str = string.gsub(listbtn_group:GetText(), "{@st66b}", "")
    if not g.settings.group_caption then
        g.settings.group_caption = group_str
        MINI_ADDONS_SAVE_SETTINGS()
    end
    local chatlist_group = GET_CHILD_RECURSIVELY(chat_grouplist, "chatlist_group")
    local child_count = chatlist_group:GetChildCount()
    local delete_ids = {}

    for room_id, _ in pairs(g.settings.new_groups) do
        delete_ids[room_id] = true
    end
    local default_name = session.chat.GetNewGroupChatDefName()
    local pattern = "%s*%d+$"
    default_name = string.gsub(default_name, pattern, "")

    local chat = ui.GetFrame('chat')
    local groups = g.settings.new_groups
    if not groups then
        return
    end
    local changed = false
    local index = 1
    for i = 0, child_count - 1 do
        local child = chatlist_group:GetChildByIndex(i)
        local child_name = child:GetName()
        if string.find(child_name, "btn_") then
            local room_id = string.gsub(child_name, "btn_", "")
            if delete_ids[room_id] then
                delete_ids[room_id] = nil
            end
            local info = session.chat.GetByStringID(room_id)
            local title = GET_CHILD(child, "title")
            AUTO_CAST(title)
            local title_text = title:GetText()
            title_text = string.gsub(title_text, "%s*%[.-%]", "")
            local def_name = string.gsub(session.chat.GetNewGroupChatDefName(), "%s*%d+$", "")
            if string.find(title_text, def_name) then
                title_text = def_name .. index
                index = index + 1
            end
            local text = GET_CHILD_RECURSIVELY(child, "text")
            AUTO_CAST(text)
            local text_str = text:GetText()
            local color_code = "ffffff"
            if mini_addons and not text_str then
                return 1
            end
            if not string.find(text_str, "%{img ") then
                color_code = string.match(text_str, "%{#(%x+)%}")
            end
            if mini_addons and not color_code then
                return 1
            end
            if not groups[room_id] then
                groups[room_id] = {
                    name = title_text,
                    color = color_code,
                    room_id = room_id,
                    now = 0
                }
                changed = true
            end
            local name = groups[room_id].name
            title_text = ScpArgMsg("GroupChatTitleWithMemCnt", "Text", name, "Cnt", tostring(info:GetMemberCount()))
            title:SetText(title_text)
        end
    end

    if next(delete_ids) then
        for delete_room_id, _ in pairs(delete_ids) do
            g.settings.new_groups[delete_room_id] = nil
            changed = true
        end
    end
    if changed then
        MINI_ADDONS_SAVE_SETTINGS()
    end
    local is_start = chat_grouplist:GetUserValue("IS_START")
    if is_start == "None" then
        local active_room_id = ""
        for room_id, data in pairs(g.settings.new_groups) do
            active_room_id = room_id
            if data.now == 1 then
                active_room_id = room_id
                break
            end
        end
        mini_addons_group_chat_setting(chat, active_room_id)
        chat_grouplist:SetUserValue("IS_START", "start")
    end

    local selected_chat_str = chat:GetUserValue("CHAT_TYPE_SELECTED_VALUE")
    local selected_chat_num = 0
    if selected_chat_str then
        if selected_chat_str == "None" then
            chat:SetUserValue("CHAT_TYPE_SELECTED_VALUE", "0")
        else
            selected_chat_num = tonumber(selected_chat_str) - 1
        end
        ui.SetChatType(selected_chat_num)
    end
    return 0
end

function mini_addons_CHAT_GROUPLIST_OPTION_OK()

    local chat_grouplist_option = ui.GetFrame("chat_grouplist_option")
    local room_id = chat_grouplist_option:GetUserValue("ROOMID")
    local info = session.chat.GetByStringID(room_id)
    if not info then
        return
    end
    if info:GetRoomType() ~= 3 then
        return
    end
    local color_num = tonumber(chat_grouplist_option:GetUserValue("SelectedColor"))
    if color_num == 0 then
        local vmark = GET_CHILD_RECURSIVELY(chat_grouplist_option, "vmark")
        local x = vmark:GetX()
        color_num = x / 25 + 100
    end
    local color_cls = GetClassByType("ChatColorStyle", color_num)
    if color_cls then
        g.settings.new_groups[room_id].color = color_cls.TextColor
    end
    local groupname_edit = GET_CHILD_RECURSIVELY(chat_grouplist_option, "groupname_edit")
    local new_title = groupname_edit:GetText()
    g.settings.new_groups[room_id].name = new_title
    mini_addons_now_chat_setting(room_id)
    MINI_ADDONS_SAVE_SETTINGS()
    CHAT_GROUPLIST_SELECT_LISTTYPE(3)
end

function mini_addons_now_chat_setting(target_id)

    local target_group = g.settings.new_groups[target_id]
    if target_group and target_group.now ~= 1 then
        g.settings.new_groups[target_id].now = 1
        for room_id, data in pairs(g.settings.new_groups) do
            if room_id ~= target_id then
                data.now = 0
            end
        end
        MINI_ADDONS_SAVE_SETTINGS()
    end
end

function mini_addons_group_chat_setting(chat, target_id)

    local group_data = g.settings.new_groups[target_id]

    if not group_data then
        return
    end

    local chat = ui.GetFrame('chat')
    AUTO_CAST(chat)

    local mainchat = chat:GetChild('mainchat')
    AUTO_CAST(mainchat)
    local edit_bg = GET_CHILD(chat, 'edit_bg')
    AUTO_CAST(edit_bg)
    local button_type = GET_CHILD(chat, 'button_type')
    AUTO_CAST(button_type)
    local edit_to_bg = GET_CHILD(chat, 'edit_to_bg')
    AUTO_CAST(edit_to_bg)
    local title_to = GET_CHILD(edit_to_bg, 'title_to')
    AUTO_CAST(title_to)
    ui.SetGroupChatTargetID(target_id)

    local btn_text = g.settings.group_caption
    local color = "{#" .. group_data.color .. "}"
    btn_text = color .. btn_text
    button_type:SetText("{ol}{s18}" .. color .. btn_text)
    local color_tone = "FF" .. group_data.color
    title_to:SetText(group_data.name)
    title_to:SetColorTone(color_tone)
    button_type:SetColorTone(color_tone)
    edit_to_bg:SetSkinName("bg")
    edit_to_bg:SetOffset(button_type:GetOriginalWidth(), edit_to_bg:GetOriginalY())
    local offset_x = button_type:GetOriginalWidth()
    title_to:SetEventScript(ui.LBUTTONUP, "mini_addons_chat_group_context")
    title_to:SetEventScriptArgString(ui.LBUTTONUP, group_data.name)
    edit_to_bg:Resize(title_to:GetWidth() + 20, edit_to_bg:GetOriginalHeight())
    edit_to_bg:SetVisible(1)
    offset_x = offset_x + edit_to_bg:GetWidth()
    local width = mainchat:GetOriginalWidth() - edit_to_bg:GetWidth() - button_type:GetWidth()
    mainchat:Resize(width, mainchat:GetOriginalHeight())
    mainchat:SetOffset(offset_x, mainchat:GetOriginalY())
    -- edit_to_bg:ShowWindow(1)
    -- ui.SetGroupChatTargetID(target_id)

end
-- tab
function mini_addons_CHAT_SET_TO_TITLENAME_(chat)
    local target_id = chat:GetUserValue("ROOM_ID")
    mini_addons_now_chat_setting(target_id)
    mini_addons_group_chat_setting(chat, target_id)
end

function mini_addons_CHAT_SET_TO_TITLENAME(my_frame, my_msg)

    -- グルチャはchat_type=5 強調も何故か5
    local chat_type, target_id = g.get_event_args(my_msg)
    local chat = ui.GetFrame('chat')
    local edit_to_bg = GET_CHILD(chat, 'edit_to_bg')
    local title_to = GET_CHILD(edit_to_bg, 'title_to')
    AUTO_CAST(title_to)
    if string.find(title_to:GetText(), "To.") then
        title_to:SetFontName("white_16_ol")
        title_to:SetColorTone("FFFFFFFF")
        edit_to_bg:SetSkinName("bg")
        title_to:SetEventScript(ui.LBUTTONUP, "")
        title_to:SetEventScriptArgString(ui.LBUTTONUP, "None")
        return
    end
    if chat_type ~= 5 then
        return
    end
    local selected_chat_str = chat:GetUserValue("CHAT_TYPE_SELECTED_VALUE")
    if selected_chat_str ~= "5" then
        return
    end
    local group_data = g.settings.new_groups[target_id]
    if not group_data or not next(group_data) then
        return
    end
    title_to:SetEventScript(ui.LBUTTONUP, "mini_addons_chat_group_context")
    title_to:SetEventScriptArgString(ui.LBUTTONUP, group_data.name)
    chat:SetUserValue("ROOM_ID", target_id)
    edit_to_bg:SetVisible(0)
    -- edit_to_bg:ShowWindow(0)
    chat:RunUpdateScript("mini_addons_CHAT_SET_TO_TITLENAME_", 0.05)
end

function mini_addons_change_title_name(target_id)
    local chat = ui.GetFrame('chat')
    mini_addons_now_chat_setting(target_id)
    mini_addons_group_chat_setting(chat, target_id)
end

function mini_addons_chat_group_context(parent, title_to, target_name, num)

    local context = ui.CreateContextMenu("select_group", "{ol}GROUP SELECT", 0, 0, 0, 0)
    for room_id, data in pairs(g.settings.new_groups) do
        local color = data.color
        color = "{#" .. data.color .. "}"
        local name = data.name
        if name ~= target_name then
            local scp = string.format("mini_addons_change_title_name('%s')", room_id)
            ui.AddContextMenuItem(context, color .. name, scp)
        end
    end
    ui.OpenContextMenu(context)
end

function mini_addons_autozoom(ctrl)

    if g.settings.auto_zoom.use == 1 then
        camera.CustomZoom(tonumber(g.settings.auto_zoom.zoom))
    end
    return 0
end

function mini_addons_RESTART_ON_MSG(my_frame, my_msg)
    local frame, msg, str, num = g.get_event_args(my_msg)

    if not g.settings.restart_colony or g.settings.restart_colony ~= 1 or msg ~= 'RESTART_HERE' or
        (BitGet(num, 12) ~= 1 and BitGet(num, 14) ~= 1) then
        return g.FUNCS["RESTART_ON_MSG"](frame, msg, str, num)
    end

    local restart_frame = ui.GetFrame("restart")
    restart_frame:ShowWindow(1)
    for i = 1, 5 do
        local resButtonObj = GET_CHILD(frame, "restart" .. i .. "btn", 'ui::CButton');
        if resButtonObj then
            resButtonObj:ShowWindow(BitGet(num, i));
        end
    end

    local mystic_button = GET_CHILD(restart_frame, "restart8btn", 'ui::CButton');
    if mystic_button then
        if BitGet(num, 14) == 1 then
            mystic_button:ShowWindow(1);
        else
            mystic_button:ShowWindow(0);
        end
    end

    if restart_frame:GetUserValue("COLONY_TIMER_RUNNING") ~= "1" then
        restart_frame:SetUserValue("COLONY_TIMER_RUNNING", "1")

        local resButtonObj = GET_CHILD(restart_frame, "restart6btn", 'ui::CButton');
        if resButtonObj then
            resButtonObj:ShowWindow(1)
            local text = "{@st66b}" .. ScpArgMsg("ReturnCity{SEC}", "SEC", 30) .. "{/}"
            resButtonObj:SetText(text)
        end

        g.corny_time = 30
        restart_frame:RunUpdateScript("mini_addons_COLONY_WAR_RESTART_UPDATE", 1)
        AUTORESIZE_RESTART(frame);

        local resButtonObj = GET_CHILD(frame, "restart9btn", 'ui::CButton');
        if resButtonObj then
            resButtonObj:ShowWindow(0);
        end

        local resButtonObj = GET_CHILD(frame, "restart10btn", 'ui::CButton');
        if resButtonObj then
            resButtonObj:ShowWindow(0);
        end

        local restart_wait = GET_CHILD(frame, "restart_wait")
        if restart_wait then
            AUTO_CAST(restart_wait)
            restart_wait:ShowWindow(0);
        end
        restart_frame:ShowWindow(1);
    end

end

function mini_addons_COLONY_WAR_RESTART_UPDATE(frame)
    local resButtonObj = GET_CHILD(frame, "restart6btn", 'ui::CButton')
    if not resButtonObj then
        return 0
    end

    g.corny_time = g.corny_time - 1
    if g.corny_time < 0 then
        g.corny_time = 0
    end

    local text = "{@st66b}" .. ScpArgMsg("ReturnCity{SEC}", "SEC", g.corny_time) .. "{/}"
    resButtonObj:SetText(text)

    if g.corny_time <= 0 then
        frame:SetUserValue("COLONY_TIMER_RUNNING", "0")
        return 0
    end
    COLONY_WAR_RESTART_BY_MYSTIC_UPDATE(frame)

    return 1
end

function MINI_ADDONS_FRAME_MOVE()

    local rcframe = ui.GetFrame("restart_contents")
    rcframe:EnableHittestFrame(1)
    rcframe:EnableMove(1)

end

function mini_addons_SHOW_PET_RINGCOMMAND(my_frame, my_msg)
    local actor = g.get_event_args(my_msg)
    if g.settings.pet_ring == 1 then
        return
    else
        g.FUNCS["SHOW_PET_RINGCOMMAND"](actor)
    end
end

-- お使いクエストフレーム
function mini_addons_quest_get_map()
    local questIES = GetClassByType("QuestProgressCheck", 7)
    local pc = SCR_QUESTINFO_GET_PC();
    local QUEST_MAX_MON_CHECK = 6

    if questIES.Quest_SSN ~= 'None' then
        local sObj_quest = GetSessionObject(pc, questIES.Quest_SSN)
        if sObj_quest ~= nil and sObj_quest.SSNMonKill ~= 'None' then
            local monList = SCR_STRING_CUT(sObj_quest.SSNMonKill, ':')
            if monList[1] == 'ZONEMONKILL' then

                for i = 1, QUEST_MAX_MON_CHECK do
                    if #monList - 1 >= i then
                        local index = i + 1
                        local zoneMonInfo = SCR_STRING_CUT(monList[index])

                        local target_map = tostring(zoneMonInfo[1])
                        return target_map
                    end
                end
            end
        end
    end
end

function mini_addons_quest_token_warp(frame, ctrl, str, num)
    local target_map = mini_addons_quest_get_map()
    WORLDMAP2_TOKEN_WARP(target_map)
end

function mini_addons_quest_update(frame, msg, str, num)

    if g.settings.daily_quest == 0 then
        return
    end

    local questinfoset_2 = ui.GetFrame("questinfoset_2")
    local _Q_7 = GET_CHILD_RECURSIVELY(questinfoset_2, "_Q_7")
    if _Q_7 then

        local color = "{#FFFFFF}"
        local extracted_content
        local MON_1 = GET_CHILD(_Q_7, "MON_1")
        if MON_1 then

            local text = MON_1:GetText()
            local pattern = "%((.-)%)"
            extracted_content = text:match(pattern)
            extracted_content = color .. extracted_content
        else
            color = "{#FF0000}"
            extracted_content = color .. "150/150"
        end
        local QUESTINFOMAP = GET_CHILD(_Q_7, "QUESTINFOMAP")
        local last_part
        if QUESTINFOMAP then
            local text = QUESTINFOMAP:GetText()
            last_part = text:match(".*{nl}(.-)$") or ""
        end

        if last_part == "" then
            local q7quest = ui.GetFrame("mini_addons_q7quest")
            if q7quest then
                AUTO_CAST(q7quest)
                q7quest:ShowWindow(0)
                return
            end
        end

        local groupQuest_title = GET_CHILD(_Q_7, "groupQuest_title")
        local text = groupQuest_title:GetText()
        local pattern = "{#ffe792}(.-) %-"
        local extracted_text = text:match(pattern)

        local q7quest = ui.CreateNewFrame("notice_on_pc", "mini_addons_q7quest", 0, 0, 0, 0)
        AUTO_CAST(q7quest)
        q7quest:SetSkinName("bg2")
        q7quest:Resize(200, 85)
        local current_frame_w = q7quest:GetWidth()
        local map_frame = ui.GetFrame("map")
        local map_width = map_frame:GetWidth()
        q7quest:SetPos((map_width - current_frame_w) / 2, 130)
        -- q7quest:SetPos(450, 36)
        q7quest:SetLayerLevel(100)
        if type(_G["INDUN_PANEL_ON_INIT"]) == "function" then
            local indun_panel = ui.GetFrame("indun_panel")
            indun_panel_always_init(indun_panel, nil, nil)
        end
        if msg == nil then
            q7quest:RemoveAllChild()
        end

        local quest_name = q7quest:CreateOrGetControl("richtext", "quest_name", 10, 5, 180, 25)
        AUTO_CAST(quest_name)
        quest_name:SetTextAlign("center", "center")
        quest_name:SetText("{ol}{s16}" .. extracted_text)

        quest_name:EnableTextOmitByWidth(1)

        local map_name = q7quest:CreateOrGetControl("richtext", "map_name", 10, 30, 180, 25)
        AUTO_CAST(map_name)
        map_name:SetTextAlign("center", "center")
        map_name:SetText("{ol}{s16}" .. last_part)
        map_name:EnableTextOmitByWidth(1)

        local kill_count = q7quest:CreateOrGetControl("richtext", "kill_count", 10, 55, 180, 25)
        AUTO_CAST(kill_count)
        kill_count:SetTextAlign("center", "center")
        kill_count:SetText("{ol}{s18}" .. extracted_content)

        local token_warp = q7quest:CreateOrGetControl("button", "token_warp", 5, 48, 40, 40)
        AUTO_CAST(token_warp)
        token_warp:SetSkinName("None")

        local isTokenState = session.loginInfo.IsPremiumState(ITEM_TOKEN)
        local imageName = ""

        if isTokenState == true and GET_TOKEN_WARP_COOLDOWN() == 0 then
            imageName = "{img worldmap2_token_gold 35 35} {@st101lightbrown_16}"
        else
            imageName = "{img worldmap2_token_gray 35 35} {@st101lightbrown_16}"
        end
        token_warp:SetText(imageName)
        token_warp:SetTextTooltip("{ol}" .. last_part)
        token_warp:SetEventScript(ui.LBUTTONUP, "mini_addons_quest_token_warp")

        q7quest:ShowWindow(1)

        local abandon = q7quest:CreateOrGetControl("button", "abandon", 165, 53, 30, 30)
        AUTO_CAST(abandon)
        abandon:SetSkinName("test_gray_button")
        abandon:SetText("{ol}×")
        abandon:SetEventScript(ui.LBUTTONUP, "SCR_QUEST_ABANDON_SELECT")
        abandon:SetEventScriptArgNumber(ui.LBUTTONUP, 7)

        -- local questIES = GetClassByType("QuestProgressCheck", 7);
        -- ts(questIES.Name)
    else
        local q7quest = ui.GetFrame("mini_addons_q7quest")
        if q7quest then
            AUTO_CAST(q7quest)
            q7quest:ShowWindow(0)
        end
    end
end

-- お使いクエストフレーム　ここまで

function mini_addons__PROCESS_MOVE_MAIN_POPUPCHAT_FRAME(my_frame, my_msg)
    local frame = g.get_event_args(my_msg)
    frame:RunUpdateScript("mini_addons_PROCESS_MOVE_MAIN_POPUPCHAT_FRAME", 0.1)
end

function mini_addons_PROCESS_MOVE_MAIN_POPUPCHAT_FRAME(frame)
    if mouse.IsLBtnPressed() == 0 then
        MOVE_FRAME_MAIN_POPUP_CHAT_END(frame)
        return 0
    end

    local ratio = option.GetClientHeight() / option.GetClientWidth()
    local limit_offset = 10
    local limit_max_w
    local limit_max_h
    if g.settings.chat_frame == 1 then
        limit_max_w = ui.GetSceneWidth() - limit_offset
        -- local limit_max_h = limit_max_w * ratio - limit_offset * 12
        limit_max_h = limit_max_w * ratio - limit_offset
    else
        limit_max_w = ui.GetSceneWidth() / ui.GetRatioWidth() - limit_offset;
        limit_max_h = limit_max_w * ratio - limit_offset * 12;
    end
    local mx, my = GET_MOUSE_POS()
    mx = mx / ui.GetRatioWidth()
    my = my / ui.GetRatioHeight()

    local prev_mouse_x = frame:GetUserIValue("MOUSE_X")
    local prev_mouse_y = frame:GetUserIValue("MOUSE_Y")
    local diff_x = (mx - prev_mouse_x)
    local diff_y = (my - prev_mouse_y)

    local new_x = frame:GetUserIValue("BEFORE_W")
    local new_y = frame:GetUserIValue("BEFORE_H")
    new_x = new_x + diff_x
    new_y = new_y + diff_y

    if new_x < limit_offset then
        new_x = limit_offset
    end

    if new_y < limit_offset then
        new_y = limit_offset
    end

    local frame_w = frame:GetWidth()
    local frame_h = frame:GetHeight()

    if (new_x + frame_w) > limit_max_w then
        new_x = limit_max_w - frame_w
    end

    if (new_y + frame_h) > limit_max_h then
        new_y = (limit_max_h - frame_h)
    end

    frame:SetOffset(new_x, new_y)
    return 1
end

function MINI_ADDONS_ICON_USE(object, reAction)
    if g.settings.skill_cool_sound == 0 then
        base["ICON_USE"](object, reAction)
    else
        MINI_ADDONS_ICON_USE_(object, reAction)
    end
end

function MINI_ADDONS_ICON_USE_(object, reAction)

    local iconPt = object;
    if iconPt ~= nil then
        local icon = tolua.cast(iconPt, 'ui::CIcon');

        local iconInfo = icon:GetInfo();

        if iconInfo:GetCategory() == 'Item' then
            local itemObj = GetClassByType('Item', iconInfo.type);
            if IS_EQUIP(itemObj) == true then
                ITEM_EQUIP_BY_ID(icon:GetTooltipIESID());
                return;
            else
                local itemType = itemObj.ItemType;
                local groupName = TryGetProp(itemObj, "GroupName");

                if itemType == 'Consume' or itemType == "Quest" or groupName == "Cube" or groupName == "ExpOrb" then
                    local usable = itemObj.Usable;
                    if usable ~= 'ITEMTARGET' then
                        local invenItemInfo = GET_ICON_ITEM(iconInfo);
                        if invenItemInfo ~= nil then
                            local iconInfoType = iconInfo.type;
                            local curTime = item.GetCoolDown(iconInfoType);
                            local stat = info.GetStat(session.GetMyHandle());
                            if curTime ~= 0 or stat.HP <= 0 then
                                imcSound.PlaySoundEvent("skill_cooltime");
                                return;
                            end

                            INV_ICON_USE(invenItemInfo);
                            return;
                        end
                        item.UseByInvIndex(iconInfo.ext);
                    end
                end
            end
        elseif iconInfo:GetCategory() == 'Skill' then
            -- ts(iconInfo:GetCategory())
            if icon and ICON_UPDATE_SKILL_COOLDOWN(icon) == 0 then
                control.Skill(iconInfo.type);
            end
        elseif iconInfo:GetCategory() == 'Ability' then
            QUICKSLOT_TOGGLE_ABILITY(iconInfo.type)
        elseif iconInfo:GetCategory() == 'ACTION' then
            local script = GetClassString('Action', iconInfo.type, 'Script');
            loadstring(script)();
        elseif iconInfo:GetCategory() == 'CHEAT' then
            local script = GetClassString('Cheat', iconInfo.type, 'Scp');
            if string.find(script, '//') ~= nil then
                ui.Chat(script);
            else
                loadstring(script)();
            end
        elseif iconInfo:GetCategory() == 'ITEMCREATE' then
            local msg = '//item ' .. iconInfo.type .. ' 1';
            ui.Chat(msg);
        elseif iconInfo:GetCategory() == 'MONCREATE' then
            local msg = '//mon ' .. iconInfo.type .. ' 1';
            ui.Chat(msg);
        else

            base["ICON_USE"](object, reAction)
        end
    end

end

-- ヘアエンチャント
function mini_addons_HIGH_HAIRENCHANT_CLOSE_BTN(my_frame, my_msg)
    local reroll_option = ui.GetFrame(addon_name_lower .. "reroll_option")
    if reroll_option then
        local high_hairenchant = ui.GetFrame("high_hairenchant")
        local bodyGbox1_1 = GET_CHILD_RECURSIVELY(high_hairenchant, "bodyGbox1_1")
        AUTO_CAST(bodyGbox1_1)
        bodyGbox1_1:RemoveAllChild()
        SET_REPEAT_COUNT_TEXT(0)
        RESET_HIGH_ENCHANT()
        high_hairenchant:StopUpdateScript("mini_addons_HIGH_HAIRENCHANT_OK_BTN_")
        ui.DestroyFrame(reroll_option:GetName())
    end
end

local function get_current_enchant_item_grade_and_rank()
    local hairenchant = ui.GetFrame("high_hairenchant")
    if hairenchant == nil then
        return
    end
    local enchantGuid = hairenchant:GetUserValue("Enchant")
    local itemIES = hairenchant:GetUserValue("itemIES")
    if enchantGuid == "None" or itemIES == "None" then
        return
    end
    local item = session.GetInvItemByGuid(itemIES);
    local enchant_item = session.GetInvItemByGuid(enchantGuid);
    if enchant_item == nil or item == nil then
        return
    end
    enchant_item = GetIES(enchant_item:GetObject())
    item = GetIES(item:GetObject())
    local item_grade = shared_enchant_special_option.get_enchant_item_grade(enchant_item)
    local item_rank = shared_enchant_special_option.get_item_rank(item)
    return item_grade, item_rank
end

function mini_addons_HIGH_ENCHANT_OPTION_OPEN_BTN(my_frame, my_msg)
    if g.settings.hair_enchant == 0 then
        return
    end
    local ctrl, frame = g.get_event_args(my_msg)

    local hairenchant_option = ui.GetFrame("hairenchant_option")
    local high_hairenchant = ui.GetFrame("high_hairenchant")
    local enchantGuid = high_hairenchant:GetUserValue("Enchant")
    local itemIES = high_hairenchant:GetUserValue("itemIES")
    if enchantGuid == "None" or itemIES == "None" then
        return
    end
    local reroll_option = ui.GetFrame(addon_name_lower .. "reroll_option")
    if reroll_option then
        mini_addons_HIGH_HAIRENCHANT_CLOSE_BTN(nil, "")

        ui.OpenFrame('hairenchant_option')
        return
    end
    ui.CloseFrame('hairenchant_option')
    reroll_option = ui.CreateNewFrame("notice_on_pc", addon_name_lower .. "reroll_option", 0, 0, 0, 0)
    AUTO_CAST(reroll_option)
    reroll_option:SetSkinName("test_Item_tooltip_equip")
    -- ui.GetClientInitialWidth() 1920が取れる
    -- ui.GetSceneWidt()今の横幅 結構nilになったりする。信頼性低い
    -- ui.GetRatioWidth()=ui.GetSceneWidth()/ui.GetClientInitialWidth()
    -- local inventory = ui.GetFrame("inventory")
    reroll_option:SetGravity(ui.RIGHT, ui.TOP)
    local margin = reroll_option:GetMargin()
    reroll_option:SetMargin(margin.left, margin.top, margin.right + 905, margin.bottom)
    reroll_option:SetPos(reroll_option:GetX(), high_hairenchant:GetY())
    reroll_option:SetLayerLevel(100)

    local gbox = reroll_option:CreateOrGetControl("groupbox", "gbox", 0, 40, 0, 0)
    AUTO_CAST(gbox)
    gbox:SetSkinName("None")

    function mini_addons_reroll_option_close(reroll_option)
        mini_addons_HIGH_HAIRENCHANT_CLOSE_BTN(nil, "")

    end

    local close = reroll_option:CreateOrGetControl('button', 'close', 0, 0, 30, 30)
    AUTO_CAST(close)
    close:SetImage("testclose_button")
    close:SetGravity(ui.LEFT, ui.TOP)
    close:SetEventScript(ui.LBUTTONUP, "mini_addons_HIGH_HAIRENCHANT_CLOSE_BTN")

    local item_grade, item_rank = get_current_enchant_item_grade_and_rank()

    if item_grade == nil or item_rank == nil then
        return
    end

    g.need_options = {}
    function mini_addons_reroll_option_check(gbox, ctrl, str)

        g.need_options[ctrl:GetName()] = {
            is_check = ctrl:IsChecked(),
            text = str
        }
        local bodyGbox1 = GET_CHILD_RECURSIVELY(high_hairenchant, "bodyGbox1")
        local dest = bodyGbox1:GetUserValue("DESTROY")

        local bodyGbox1_1 = GET_CHILD_RECURSIVELY(high_hairenchant, "bodyGbox1_1")
        if dest == "None" then

            bodyGbox1:SetUserValue("DESTROY", "destroy")
            DESTROY_CHILD_BYNAME(bodyGbox1, "bodyGbox1_1")
        end
        local bodyGbox1_1 = bodyGbox1:CreateOrGetControl("groupbox", "bodyGbox1_1", 5, 35, 370, 135)
        AUTO_CAST(bodyGbox1_1)
        bodyGbox1_1:RemoveAllChild()
        bodyGbox1_1:SetSkinName("None")
        bodyGbox1_1:SetGravity(ui.LEFT, ui.TOP)
        local ypos = 10

        for key, value in pairs(g.need_options) do
            if value.is_check == 1 then

                local op_name = string.format("%s %s", ClMsg('ItemRandomOptionGroupSTAT'), "{ol}" .. value.text)
                local property_text = bodyGbox1_1:CreateOrGetControl("richtext", "property_text" .. key, 5, ypos, 0, 20)
                property_text:SetText(op_name)
                ypos = ypos + 25
            end
        end

    end

    local OptionList, cnt = GetClassList("enchant_special_option")
    local y = 5
    for i = 0, cnt - 1 do
        local cls = GetClassByIndexFromList(OptionList, i)
        if cls == nil then
            break
        end
        local RangeTable = shared_enchant_special_option.get_value_range(cls.ClassName, item_grade, item_rank, 1);
        if RangeTable[1] ~= 0 and RangeTable[2] ~= 0 then
            local OptionString = string.format("%s %d~%d", ScpArgMsg(cls.ClassName), RangeTable[1], RangeTable[2])
            local option_text = gbox:CreateOrGetControl("checkbox", "option_text" .. i, 10, y, 0, 20)
            AUTO_CAST(option_text)
            option_text:SetText("{ol}" .. OptionString)
            option_text:SetEventScript(ui.LBUTTONUP, "mini_addons_reroll_option_check")
            option_text:SetEventScriptArgString(ui.LBUTTONUP, ScpArgMsg(cls.ClassName))
            y = y + 25
        end
    end

    function mini_addons_hair_enchant_repeat(gbox, repeat_count)
        local count = tonumber(repeat_count:GetText())
        if count == nil then
            count = 0
        end
        if count < 0 then
            count = 0
        end
        SET_REPEAT_COUNT_TEXT(count)
    end

    local repeat_count = gbox:CreateOrGetControl('edit', "repeat_count", 330, y, 60, 30)
    AUTO_CAST(repeat_count)
    repeat_count:SetTypingScp("mini_addons_hair_enchant_repeat")
    repeat_count:SetTextTooltip(g.lang == "Japanese" and "{ol}リピート回数を入力" or
                                    "{ol}Enter the repeat count")
    repeat_count:SetFontName("white_16_ol")
    repeat_count:SetTextAlign("center", "center")
    repeat_count:SetNumberMode(1)
    local enchantGuid = high_hairenchant:GetUserValue("Enchant")
    local invItem = session.GetInvItemByGuid(enchantGuid)
    if not invItem then
        repeat_count:SetText(1)
    else
        repeat_count:SetText(invItem.count)
    end

    local cancel = gbox:CreateOrGetControl('button', "cancel", 260, y, 60, 30)
    AUTO_CAST(cancel)
    cancel:SetText("{ol}Cancel")
    cancel:SetTextTooltip(g.lang == "Japanese" and "{ol}連続エンチャントを強制的に止めます" or
                              "{ol}Force stop continuous enchantment")
    cancel:SetSkinName("test_red_button")
    cancel:SetEventScript(ui.LBUTTONUP, "mini_addons_HIGH_HAIRENCHANT_CLOSE_BTN")

    y = y + 30

    reroll_option:Resize(400, y + 45)
    gbox:Resize(reroll_option:GetWidth(), reroll_option:GetHeight() - 40)
    reroll_option:ShowWindow(1)
end

function mini_addons_HIGH_HAIRENCHANT_OK_BTN(my_frame, my_msg)

    local frame, ctrl = g.get_event_args(my_msg)

    if g.settings.hair_enchant == 0 then
        g.FUNCS["HIGH_HAIRENCHANT_OK_BTN"](frame, ctrl)
    end
    local reroll_option = ui.GetFrame(addon_name_lower .. "reroll_option")
    if reroll_option and reroll_option:IsVisible() == 1 then
        frame:RunUpdateScript("mini_addons_HIGH_HAIRENCHANT_OK_BTN_", 1.0)
    else
        g.FUNCS["HIGH_HAIRENCHANT_OK_BTN"](frame, ctrl)
    end

end

function mini_addons_HIGH_HAIRENCHANT_OK_BTN_(frame, ctrl)

    if frame == nil then
        frame = ui.GetFrame('high_hairenchant')
    end
    frame = frame:GetTopParentFrame();

    local enchantGuid = frame:GetUserValue("Enchant")
    local itemIES = frame:GetUserValue("itemIES")

    if "None" == itemIES or "None" == enchantGuid then
        return 0
    end

    local reroll_option = ui.GetFrame(addon_name_lower .. "reroll_option")
    if not reroll_option and reroll_option:IsVisible() == 0 and reroll_option:GetUserValue("STATUS") == "None" then
        item.DoPremiumItemEnchantchip(itemIES, enchantGuid)
        return 0
    end

    local repeatCount = GET_CHILD_RECURSIVELY(frame, "repeatCount")
    local repeat_count = GET_CHILD_RECURSIVELY(reroll_option, "repeat_count")
    local set_repeat_num = tonumber(repeat_count:GetText())
    local count = reroll_option:GetUserIValue("REPERT")
    if count == set_repeat_num then
        repeatCount:SetTextByKey("value", string.format("%s : %d", ClMsg('REPEAT'), set_repeat_num - count))
        reroll_option:SetUserValue("REPERT", "None")
        reroll_option:SetUserValue("STATUS", "None")
        return 0
    end

    local invItem = session.GetInvItemByGuid(itemIES)
    if nil == invItem then
        return
    end
    local obj = GetIES(invItem:GetObject())
    local item_grade, item_rank = get_current_enchant_item_grade_and_rank()
    local befor_rank = reroll_option:GetUserValue("RANK")

    local rank_up = GET_CHILD_RECURSIVELY(frame, "rank_up")
    local rank_check = rank_up:IsChecked()
    -- ts(item_grade, item_rank, befor_rank)
    if befor_rank ~= "None" and item_rank ~= befor_rank then
        imcAddOn.BroadMsg("NOTICE_Dm_TrapPlus", "{st41b}" .. ClMsg('MagicAutoRankUpMessage'), 5.0)
        imcSound.PlaySoundEvent("sys_transcend_success")
        reroll_option:SetUserValue("REPERT", "None")
        reroll_option:SetUserValue("STATUS", "None")
        mini_addons_HIGH_HAIRENCHANT_CLOSE_BTN(nil, "")
        return 0
    end
    reroll_option:SetUserValue("RANK", item_rank)

    function mini_addons_hair_enchant_msgbox(boolean, frame_name, itemIES, enchantGuid)
        local frame = ui.GetFrame(frame_name)
        frame:StopUpdateScript("mini_addons_HIGH_HAIRENCHANT_OK_BTN_")
        if boolean == "YES" then
            item.DoPremiumItemEnchantchip(itemIES, enchantGuid)
            local reroll_option = ui.GetFrame(addon_name_lower .. "reroll_option")
            reroll_option:SetUserValue("REPERT", reroll_option:GetUserIValue("REPERT") + 1)
            mini_addons_HIGH_HAIRENCHANT_OK_BTN(nil, "HIGH_HAIRENCHANT_OK_BTN")
        else
            mini_addons_HIGH_HAIRENCHANT_CLOSE_BTN(nil, "")
        end
    end
    local margin = reroll_option:GetMargin()
    reroll_option:SetMargin(margin.left, margin.top, 905, margin.bottom)
    local map_frame = ui.GetFrame("map")
    local width = map_frame:GetWidth()
    local retio = width / ui.GetClientInitialWidth()
    for key, value in pairs(g.need_options) do

        if value.is_check == 1 then
            local target_text = value.text
            for i = 1, 3 do
                local propName = "HatPropName_" .. i;
                local propValue = "HatPropValue_" .. i;

                if obj[propValue] ~= 0 and obj[propName] ~= "None" then
                    local yes_scp = string.format("mini_addons_hair_enchant_msgbox('%s','%s','%s','%s')", "YES",
                        frame:GetName(), itemIES, enchantGuid)
                    local no_scp = string.format("mini_addons_hair_enchant_msgbox('%s','%s','%s','%s')", "NO",
                        frame:GetName(), itemIES, enchantGuid)
                    local msg = string.format(g.lang == "Japanese" and "{#FFFFFF}{ol}続けますか？" or
                                                  "{#FFFFFF}{ol}Do you want to continue? ")
                    if string.find(obj[propName], 'ALLSKILL_') == nil then
                        if target_text == ScpArgMsg(obj[propName]) then
                            if margin.right == 905 then
                                reroll_option:SetMargin(margin.left, margin.top, 1150 * retio, margin.bottom)
                            end
                            repeatCount:SetTextByKey("value",
                                string.format("%s : %d", ClMsg('REPEAT'), set_repeat_num - count))
                            local befor_rank = reroll_option:GetUserValue("RANK")
                            ui.MsgBox(msg, yes_scp, no_scp)
                            return 0
                        end
                    else
                        if margin.right == 905 then
                            reroll_option:SetMargin(margin.left, margin.top, 1150 * retio, margin.bottom)
                        end
                        repeatCount:SetTextByKey("value",
                            string.format("%s : %d", ClMsg('REPEAT'), set_repeat_num - count))
                        ui.MsgBox(msg, yes_scp, no_scp)
                        return 0
                    end
                end
            end
        end
    end
    -- local inventory = ui.GetFrame("inventory")
    reroll_option:SetGravity(ui.RIGHT, ui.TOP)
    local margin = reroll_option:GetMargin()
    reroll_option:SetMargin(margin.left, margin.top, 905, margin.bottom)
    reroll_option:SetPos(reroll_option:GetX(), frame:GetY())

    item.DoPremiumItemEnchantchip(itemIES, enchantGuid)
    repeatCount:SetTextByKey("value", string.format("%s : %d", ClMsg('REPEAT'), set_repeat_num - count))
    reroll_option:SetUserValue("REPERT", reroll_option:GetUserIValue("REPERT") + 1)
    reroll_option:SetUserValue("STATUS", "is_repeat")
    return 1
end
-- ヘアエンチャント ここまで

function MINI_ADDONS_SAVE_AND_CREATE_BUFFIDS()
    local buffs = g.load_json(g.buffs_path)
    if not buffs then
        buffs = {}
    end
    g.buffs = buffs
    g.save_json(g.buffs_path, g.buffs)
end

function mini_addons_OPEN_DLG_REROLL_ITEM()

    local reroll_item = ui.GetFrame("reroll_item")
    for i = 1, MAX_RANDOM_OPTION_COUNT do
        local op = GET_CHILD_RECURSIVELY(reroll_item, "op" .. i)
        if op then
            AUTO_CAST(op)
            DESTROY_CHILD_BYNAME(reroll_item, op:GetName())
        end
    end
    if g.settings.reroll_option == 0 then
        reroll_item:StopUpdateScript("mini_addons_REROLL_ITEM_OPTION_LIST")
        return
    end

    if reroll_item and reroll_item:IsVisible() == 1 and g.settings.reroll_option == 1 then
        reroll_item:RunUpdateScript("mini_addons_REROLL_ITEM_OPTION_LIST", 0.2)
    end
end

function mini_addons_REROLL_ITEM_OPTION_LIST(reroll_frame)

    local reroll_item_option = ui.GetFrame("reroll_item_option")
    local reroll_frame = ui.GetFrame('reroll_item')
    if reroll_frame == nil or reroll_frame:IsVisible() ~= 1 then
        ui.CloseFrame('reroll_item_option')
        return 1
    end

    local slot = GET_CHILD_RECURSIVELY(reroll_frame, 'slot')
    local inv_item = GET_SLOT_ITEM(slot)

    if inv_item == nil then
        for i = 1, MAX_RANDOM_OPTION_COUNT do
            local op = GET_CHILD_RECURSIVELY(reroll_frame, "op" .. i)
            if op then
                -- ts(op:GetName())
                AUTO_CAST(op)
                DESTROY_CHILD_BYNAME(reroll_frame, op:GetName())
            end
        end
        ui.CloseFrame('reroll_item_option')
        return 1
    end

    if reroll_item_option:IsVisible() == 1 then
        return 1
    end

    local img_tbl = {
        ["ATK"] = "{img tooltip_attribute1}",
        ["DEF"] = "{img tooltip_attribute2}",
        ["UTIL_ARMOR"] = "{img tooltip_attribute3}",
        ["STAT"] = "{img tooltip_attribute4}",
        ["SPECIAL"] = "{img tooltip_attribute5}"
    }

    local item_obj = GetIES(inv_item:GetObject())
    local group = TryGetProp(item_obj, 'GroupName', 'None')

    for i = 1, MAX_RANDOM_OPTION_COUNT do
        local group_name = 'RandomOptionGroup_' .. i
        local prop_name = 'RandomOption_' .. i
        local prop_value = 'RandomOptionValue_' .. i
        local min, max = 0, 0

        if group == 'BELT' then
            min, max = shared_item_belt.get_option_value_range_equip(item_obj, item_obj[prop_name])
        elseif group == 'SHOULDER' then
            min, max = shared_item_shoulder.get_option_value_range_equip(item_obj, item_obj[prop_name])
        elseif group == 'Icor' then
            min, max = shared_item_goddess_icor.get_option_value_range_icor(item_obj, item_obj[prop_name])
        end
        reroll_frame:RemoveChild("op" .. i)
        local op = reroll_frame:CreateOrGetControl("richtext", "op" .. i, 60, i * 20 + 75, 20, 160)
        AUTO_CAST(op)
        local op_value = item_obj[prop_value]
        if op_value > max then
            op_value = "{/}{s16}{#9932CC}" .. GET_COMMAED_STRING(op_value)
        elseif op_value == max then
            op_value = "{/}{s16}{#98FB98}" .. GET_COMMAED_STRING(op_value)
        end
        if item_obj[group_name] ~= "SPECIAL" then
            op_value = GET_COMMAED_STRING(op_value) .. " {#98FB98}(" .. GET_COMMAED_STRING(max) .. ")" ..
                           "{@st43b}{s16}"
        else
            op_value = GET_COMMAED_STRING(op_value) .. "{@st43b}{s16}"
        end

        if item_obj[prop_name] ~= "None" then
            local op_text = img_tbl[item_obj[group_name]] .. "{@st43b}{s16}" .. " " .. op_value .. " " ..
                                ScpArgMsg(item_obj[prop_name])
            op:SetText(op_text)
        end

        -- 

    end

    local cur_index = reroll_frame:GetUserValue('CURRENT_INDEX')

    if cur_index == 'None' then
        cur_index = 1
    end

    if cur_index == nil or cur_index == 'None' then
        return 1
    end

    local reroll_index = TryGetProp(item_obj, 'RerollIndex', 0)

    if reroll_index <= 0 then
        reroll_index = tonumber(cur_index)
    end

    local candidate_option_list = nil

    local group_name = TryGetProp(item_obj, 'GroupName', 'None')
    if group_name == 'BELT' then
        candidate_option_list = shared_item_belt.get_option_list_by_index(item_obj, reroll_index)
    elseif group_name == 'SHOULDER' then
        candidate_option_list = shared_item_shoulder.get_option_list_by_index(item_obj, reroll_index)
    elseif group_name == 'Icor' then
        candidate_option_list = shared_item_goddess_icor.get_random_option_list(item_obj, false)
    end

    if candidate_option_list == nil or #candidate_option_list == 0 then
        return 1
    end

    local max_random_option_count = 0

    if group_name == 'BELT' then
        max_random_option_count = shared_item_belt.get_max_random_option_count(item_obj)
    elseif group_name == 'SHOULDER' then
        max_random_option_count = shared_item_shoulder.get_max_random_option_count(item_obj)
    elseif group_name == 'Icor' then
        max_random_option_count = shared_item_goddess_icor.get_max_option_count()
    end

    if max_random_option_count == nil then
        return 1
    end

    local optionGbox = GET_CHILD_RECURSIVELY(reroll_item_option, 'optionGbox')
    optionGbox:RemoveAllChild()
    local op_count = 0

    local function _MAKE_PROPERTY_MIN_MAX_DESC(desc, min, max)
        return string.format(" %s " .. ScpArgMsg("PropUp") .. "%d" .. ' ~ ' .. ScpArgMsg("PropUp") .. "%d", desc,
            math.abs(min), math.abs(max))
    end

    for i = 1, #candidate_option_list do
        local prop_name = candidate_option_list[i]

        if group_name == 'BELT' then
            if shared_item_belt.is_valid_reroll_option(item_obj, reroll_index, prop_name, max_random_option_count) ==
                true then
                op_count = op_count + 1
                local group_name = shared_item_belt.get_option_group_name(prop_name)
                local clmsg = GET_CLMSG_BY_OPTION_GROUP(group_name)
                local min, max = shared_item_belt.get_option_value_range_equip(item_obj, prop_name)
                local op_name = string.format('%s %s', ClMsg(clmsg), ScpArgMsg(prop_name))
                local info_str = _MAKE_PROPERTY_MIN_MAX_DESC(op_name, min, max)
                local option_ctrlset = optionGbox:CreateOrGetControlSet('eachproperty_in_reroll_item',
                    'PROPERTY_CSET_' .. op_count, 0, 0)
                option_ctrlset = AUTO_CAST(option_ctrlset)
                local pos_y = option_ctrlset:GetUserConfig('POS_Y')
                option_ctrlset:Move(0, (op_count - 1) * pos_y)
                -- local bg = GET_CHILD_RECURSIVELY(option_ctrlset, 'bg')
                -- bg:ShowWindow(0)
                local property_name = GET_CHILD_RECURSIVELY(option_ctrlset, 'property_name', 'ui::CRichText')
                property_name:SetEventScript(ui.LBUTTONUP, 'None')
                property_name:SetText(info_str)
                local help_pic = GET_CHILD_RECURSIVELY(option_ctrlset, 'help_pic')
                help_pic:ShowWindow(0)
            end
        elseif group_name == 'SHOULDER' then
            if shared_item_shoulder.is_valid_reroll_option(item_obj, reroll_index, prop_name, max_random_option_count) ==
                true then
                op_count = op_count + 1
                local group_name = shared_item_shoulder.get_option_group_name(prop_name)
                local clmsg = GET_CLMSG_BY_OPTION_GROUP(group_name)
                local min, max = shared_item_shoulder.get_option_value_range_equip(item_obj, prop_name)
                local op_name = string.format('%s %s', ClMsg(clmsg), ScpArgMsg(prop_name))
                local info_str = _MAKE_PROPERTY_MIN_MAX_DESC(op_name, min, max)
                local option_ctrlset = optionGbox:CreateOrGetControlSet('eachproperty_in_reroll_item',
                    'PROPERTY_CSET_' .. op_count, 0, 0)
                option_ctrlset = AUTO_CAST(option_ctrlset)
                local pos_y = option_ctrlset:GetUserConfig('POS_Y')
                option_ctrlset:Move(0, (op_count - 1) * pos_y)
                -- local bg = GET_CHILD_RECURSIVELY(option_ctrlset, 'bg')
                -- bg:ShowWindow(0)
                local property_name = GET_CHILD_RECURSIVELY(option_ctrlset, 'property_name', 'ui::CRichText')
                property_name:SetEventScript(ui.LBUTTONUP, 'None')
                property_name:SetText(info_str)
                local help_pic = GET_CHILD_RECURSIVELY(option_ctrlset, 'help_pic')
                help_pic:ShowWindow(0)
            end
        elseif group_name == 'Icor' then
            if shared_item_goddess_icor.is_valid_reroll_option(item_obj, reroll_index, prop_name) == true then

                op_count = op_count + 1
                local group_name = shared_item_goddess_icor.get_option_group_name(prop_name)

                local clmsg = GET_CLMSG_BY_OPTION_GROUP(group_name)

                local min, max = shared_item_goddess_icor.get_option_value_range_icor(item_obj, prop_name)

                local op_name = string.format('%s %s', ClMsg(clmsg), ScpArgMsg(prop_name))

                local info_str = _MAKE_PROPERTY_MIN_MAX_DESC(op_name, min, max)

                local option_ctrlset = optionGbox:CreateOrGetControlSet('eachproperty_in_reroll_item',
                    'PROPERTY_CSET_' .. op_count, 0, 0)
                option_ctrlset = AUTO_CAST(option_ctrlset)
                local pos_y = option_ctrlset:GetUserConfig('POS_Y')
                option_ctrlset:Move(0, (op_count - 1) * pos_y)
                local property_name = GET_CHILD_RECURSIVELY(option_ctrlset, 'property_name', 'ui::CRichText')
                property_name:SetEventScript(ui.LBUTTONUP, 'None')
                property_name:SetText(info_str)
                local help_pic = GET_CHILD_RECURSIVELY(option_ctrlset, 'help_pic')
                help_pic:ShowWindow(0)

            end
        end
    end
    reroll_item_option:Resize(500, 970)
    reroll_item_option:SetSkinName("None")
    local bg = GET_CHILD(reroll_item_option, "bg")
    bg:Resize(470, reroll_item_option:GetHeight())
    local optionGbox = GET_CHILD(reroll_item_option, "optionGbox")
    optionGbox:Resize(430, bg:GetHeight() - 100)

    reroll_item_option:ShowWindow(1)
    return 1
end

function mini_addons_inventory_open_func(frame, msg, str, num)

    g.inven_tbl = g.inven_tbl or {}

    local frame = ui.GetFrame("inventory")

    local tab = GET_CHILD_RECURSIVELY(frame, "inventype_Tab")
    if not tab then
        return 1
    end

    local tab_index = tab:GetSelectItemIndex()

    if tab_index ~= 0 and tab_index ~= 3 and tab_index ~= 5 and tab_index ~= 1 and tab_index ~= 2 and tab_index ~= 4 and
        tab_index ~= 6 then
        return 1
    end

    local group = GET_CHILD_RECURSIVELY(frame, 'inventoryGbox', 'ui::CGroupBox')
    if not group then
        return 1
    end

    local trees_to_process = {}

    if tab_index == 0 then
        -- Allタブの場合: 全てのtreeをリストに追加
        for i = 1, #g_invenTypeStrList do
            local tab_name = g_invenTypeStrList[i]

            local tree_box = GET_CHILD_RECURSIVELY(group, 'treeGbox_' .. tab_name, 'ui::CGroupBox')

            if tree_box then
                local tree = GET_CHILD_RECURSIVELY(tree_box, 'inventree_' .. tab_name, 'ui::CTreeControl')

                if tree then
                    table.insert(trees_to_process, tree)
                end
            end
        end
    else
        -- Allタブ以外の場合: 対応するtreeだけをリストに追加
        local tab_name = g_invenTypeStrList[tab_index + 1]

        if tab_name then
            local tree_box = GET_CHILD_RECURSIVELY(group, 'treeGbox_' .. tab_name, 'ui::CGroupBox')

            if tree_box then
                local tree = GET_CHILD_RECURSIVELY(tree_box, 'inventree_' .. tab_name, 'ui::CTreeControl')
                if tree then
                    table.insert(trees_to_process, tree)
                end
            end
        end
    end

    -- 準備したtreeのリストをループして、UI更新処理を実行
    for _, tree in ipairs(trees_to_process) do

        local recipe_ssets = {}
        for i = 0, tree:GetChildCount() - 1 do
            local child = tree:GetChildByIndex(i)
            if child and string.find(child:GetName(), "sset_Recipe", 1, true) then
                table.insert(recipe_ssets, child)
            end
        end

        for _, recipe_slot_set in ipairs(recipe_ssets) do

            local child_count = recipe_slot_set:GetChildCount()
            -- ts(tab_index, recipe_slot_set:GetName())
            for i = 0, child_count - 1 do

                local slot = recipe_slot_set:GetChildByIndex(i)
                if slot then
                    AUTO_CAST(slot)
                    local icon = slot:GetIcon()
                    if icon then
                        local info = icon:GetInfo()
                        local iesid = info:GetIESID()
                        local inv_item = GET_ITEM_BY_GUID(iesid)
                        local inv_index = inv_item.invIndex
                        local unique_key = iesid .. "_" .. inv_index
                        if not g.inven_tbl[unique_key] or msg ~= "INV_ITEM_ADD" then
                            g.inven_tbl[unique_key] = true

                            if inv_item then
                                local item_obj = GetIES(inv_item:GetObject())
                                local item_cls = GetClassByType("Item", item_obj.ClassID)
                                if item_cls then
                                    local recipe_cls = GetClass('Recipe', item_cls.ClassName)
                                    if recipe_cls then
                                        local target_item_cls = GetClass("Item", recipe_cls.TargetItem)
                                        if target_item_cls then
                                            local image = nil

                                            if g.settings.inventory_mod == 1 then
                                                local image = GET_ITEM_ICON_IMAGE(target_item_cls)
                                                local recipe_pic =
                                                    slot:CreateOrGetControl('picture', 'recipe_pic' .. i, 0, 0, 25, 25)
                                                AUTO_CAST(recipe_pic)
                                                recipe_pic:SetEnableStretch(1)
                                                recipe_pic:SetGravity(ui.RIGHT, ui.TOP)
                                                recipe_pic:SetImage(image)
                                                SET_ITEM_TOOLTIP_TYPE(recipe_pic, target_item_cls.ClassID,
                                                    target_item_cls, "accountwarehouse")
                                            else
                                                local recipe_pic = GET_CHILD(slot, 'recipe_pic' .. i)
                                                if recipe_pic then
                                                    DESTROY_CHILD_BYNAME(slot, 'recipe_pic' .. i)
                                                end
                                            end

                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

        local card_ssets = {}
        for i = 0, tree:GetChildCount() - 1 do
            local child = tree:GetChildByIndex(i)
            if child and string.find(child:GetName(), "^sset_Card") and not string.find(child:GetName(), "Summon") then
                table.insert(card_ssets, child)
            end
        end

        for _, card_slot_set in ipairs(card_ssets) do
            local child_count = card_slot_set:GetChildCount()
            for i = 0, child_count - 1 do
                local slot = card_slot_set:GetChildByIndex(i)
                if slot then
                    AUTO_CAST(slot)
                    local icon = slot:GetIcon()
                    if icon then
                        local info = icon:GetInfo()
                        local iesid = info:GetIESID()
                        local inv_item = GET_ITEM_BY_GUID(iesid)
                        local inv_index = inv_item.invIndex
                        local unique_key = iesid .. "_" .. inv_index
                        if not g.inven_tbl[unique_key] or msg ~= "INV_ITEM_ADD" then
                            g.inven_tbl[unique_key] = true
                            if inv_item then
                                local item_obj = GetIES(inv_item:GetObject())
                                local item_cls = GetClassByType("Item", item_obj.ClassID)
                                local image = nil
                                if g.settings.inventory_mod == 1 then
                                    image = TryGetProp(item_obj, "TooltipImage", "None")
                                else
                                    image = GET_ITEM_ICON_IMAGE(item_cls)
                                end

                                if item_cls then
                                    icon:Set(image, 'Item', inv_item.type, inv_item.invIndex, inv_item:GetIESID(),
                                        inv_item.count);

                                end
                            end
                        end
                    end
                end
            end
        end

        local gem_skill_slotset = GET_CHILD_RECURSIVELY(tree, "sset_Gem_GemSkill", 'ui::CSlotSet')

        if gem_skill_slotset then
            -- ts(tab_index, icor_slot_set:GetName())
            local child_count = gem_skill_slotset:GetChildCount()
            for i = 0, child_count - 1 do
                local slot = gem_skill_slotset:GetChildByIndex(i)
                if slot then
                    AUTO_CAST(slot)
                    local icon = slot:GetIcon()
                    if icon then
                        local info = icon:GetInfo()
                        local iesid = info:GetIESID()
                        local inv_item = GET_ITEM_BY_GUID(iesid)
                        local inv_index = inv_item.invIndex
                        local unique_key = iesid .. "_" .. inv_index
                        if not g.inven_tbl[unique_key] or msg ~= "INV_ITEM_ADD" then
                            g.inven_tbl[unique_key] = true
                            if inv_item then
                                local item_obj = GetIES(inv_item:GetObject())
                                local item_cls = GetClassByType("Item", item_obj.ClassID)

                                if item_cls then
                                    local cls_name = item_cls.ClassName

                                    local image = GET_ITEM_ICON_IMAGE(item_cls)
                                    if g.settings.inventory_mod == 1 then
                                        local skill_name = TryGetProp(item_cls, 'SkillName', 'None')
                                        local skill_cls = GetClass("Skill", skill_name);
                                        local skill_pic = slot:CreateOrGetControl('picture', 'skill_pic' .. i, 0, 0, 35,
                                            35)
                                        AUTO_CAST(skill_pic)
                                        skill_pic:SetEnableStretch(1)
                                        skill_pic:SetGravity(ui.LEFT, ui.TOP)
                                        skill_pic:SetImage(image)
                                        SET_ITEM_TOOLTIP_TYPE(skill_pic, item_cls.ClassID, item_cls, "accountwarehouse")
                                        image = "icon_" .. GET_ITEM_ICON_IMAGE(skill_cls)
                                    else
                                        local trade = GET_CHILD(slot, 'skill_pic' .. i)
                                        if trade then
                                            DESTROY_CHILD_BYNAME(slot, 'skill_pic' .. i)
                                        end

                                    end

                                    if item_cls then
                                        icon:Set(image, 'Item', inv_item.type, inv_item.invIndex, inv_item:GetIESID(),
                                            inv_item.count);

                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        -- sset_Gem_High_Color
        local Gem_High_Color_slotset = GET_CHILD_RECURSIVELY(tree, "sset_Gem_High_Color", 'ui::CSlotSet')

        if Gem_High_Color_slotset then
            local child_count = Gem_High_Color_slotset:GetChildCount()
            for i = 0, child_count - 1 do
                local slot = Gem_High_Color_slotset:GetChildByIndex(i)
                if slot then
                    AUTO_CAST(slot)
                    local icon = slot:GetIcon()
                    if icon then
                        local info = icon:GetInfo()
                        local iesid = info:GetIESID()
                        local inv_item = GET_ITEM_BY_GUID(iesid)
                        local inv_index = inv_item.invIndex
                        local unique_key = iesid .. "_" .. inv_index
                        if not g.inven_tbl[unique_key] or msg ~= "INV_ITEM_ADD" then
                            g.inven_tbl[unique_key] = true
                            if inv_item then
                                local item_obj = GetIES(inv_item:GetObject())
                                -- ts(i, "item_obj", item_obj)
                                local item_cls = GetClassByType("Item", item_obj.ClassID)
                                -- ts(i, "item_cls", item_cls)
                                if item_cls then
                                    if g.settings.inventory_mod == 1 then
                                        local cls_name = item_cls.ClassName
                                        if string.find(cls_name, 540) then
                                            slot:SetSkinName("invenslot_pic_goddess")
                                        elseif string.find(cls_name, 520) then
                                            slot:SetSkinName("invenslot_legend")
                                        elseif string.find(cls_name, 500) then
                                            slot:SetSkinName("invenslot_unique")
                                        elseif string.find(cls_name, 480) then
                                            slot:SetSkinName("invenslot_rare")
                                        else
                                            slot:SetSkinName("invenslot_nomal")
                                        end
                                    else
                                        slot:SetSkinName("invenslot_nomal")
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

        local sset_Ancient_Card = GET_CHILD_RECURSIVELY(tree, "sset_Ancient_Card", 'ui::CSlotSet')

        if sset_Ancient_Card then

            local child_count = sset_Ancient_Card:GetChildCount()

            for i = 0, child_count - 1 do
                local slot = sset_Ancient_Card:GetChildByIndex(i)

                if slot then
                    AUTO_CAST(slot)
                    local icon = slot:GetIcon()
                    if icon then
                        local info = icon:GetInfo()
                        local inv_item = GET_ITEM_BY_GUID(info:GetIESID())
                        if inv_item then
                            local item_obj = GetIES(inv_item:GetObject())
                            local item_cls = GetClassByType("Item", item_obj.ClassID)
                            local name = string.gsub(item_obj.ClassName, "Ancient_Card_", "Ancient_")
                            local mon_cls = GetClass("Monster", name)
                            local icon_name = TryGetProp(mon_cls, "Icon", "None")
                            if g.settings.inventory_mod == 1 then

                                local ancient_pic = slot:CreateOrGetControl('picture', 'ancient_pic' .. i, 0, 0, 25, 25)
                                AUTO_CAST(ancient_pic)
                                ancient_pic:SetEnableStretch(1)
                                ancient_pic:SetGravity(ui.LEFT, ui.TOP)
                                ancient_pic:SetImage(icon_name)
                                SET_ITEM_TOOLTIP_TYPE(ancient_pic, item_cls.ClassID, item_cls, "accountwarehouse")
                            else
                                local trade = GET_CHILD(slot, 'ancient_pic' .. i)
                                if trade then
                                    DESTROY_CHILD_BYNAME(slot, 'ancient_pic' .. i)
                                end
                            end
                        end

                    end
                end
            end
        end
        -- === 処理2: イコルのスキンと取引不可表示 ===
        local icor_slot_set = GET_CHILD_RECURSIVELY(tree, "sset_Icor", 'ui::CSlotSet')

        if icor_slot_set then
            -- ts(tab_index, icor_slot_set:GetName())
            local child_count = icor_slot_set:GetChildCount()
            for i = 0, child_count - 1 do
                local slot = icor_slot_set:GetChildByIndex(i)
                if slot then
                    AUTO_CAST(slot)
                    local icon = slot:GetIcon()
                    if icon then
                        local info = icon:GetInfo()
                        local iesid = info:GetIESID()
                        local inv_item = GET_ITEM_BY_GUID(iesid)
                        local inv_index = inv_item.invIndex
                        local unique_key = iesid .. "_" .. inv_index
                        if not g.inven_tbl[unique_key] or msg ~= "INV_ITEM_ADD" then
                            g.inven_tbl[unique_key] = true
                            if inv_item then
                                local item_obj = GetIES(inv_item:GetObject())
                                local item_cls = GetClassByType("Item", item_obj.ClassID)
                                if item_cls then
                                    local cls_name = item_cls.ClassName
                                    if g.settings.inventory_mod == 1 then
                                        local is_special_item =
                                            string.find(cls_name, "EP17") or string.find(cls_name, "Weapon2") or
                                                string.find(cls_name, "Armor2")

                                        if not is_special_item then
                                            slot:SetSkinName("invenslot_rare")
                                        end

                                        local market_trade = TryGetProp(item_cls, "MarketTrade")
                                        if market_trade == "NO" then
                                            local trade = slot:CreateOrGetControl('richtext', 'trade' .. i, 5, 40, 30,
                                                10)
                                            AUTO_CAST(trade)
                                            trade:SetText("{ol}{s10}NoTrade")
                                        end
                                    else
                                        local trade = GET_CHILD(slot, 'trade' .. i)
                                        if trade then
                                            DESTROY_CHILD_BYNAME(slot, 'trade' .. i)
                                        end
                                        slot:SetSkinName("invenslot_pic_goddess")
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

        local armor_slot_set = GET_CHILD_RECURSIVELY(tree, "sset_Armor", 'ui::CSlotSet')

        if armor_slot_set then
            -- ts(tab_index, armor_slot_set:GetName())
            local child_count = armor_slot_set:GetChildCount()
            for i = 0, child_count - 1 do
                local slot = armor_slot_set:GetChildByIndex(i)
                if slot then
                    AUTO_CAST(slot)
                    local icon = slot:GetIcon()
                    if icon then
                        local info = icon:GetInfo()
                        local iesid = info:GetIESID()
                        local inv_item = GET_ITEM_BY_GUID(iesid)
                        local inv_index = inv_item.invIndex
                        local unique_key = iesid .. "_" .. inv_index
                        if not g.inven_tbl[unique_key] or msg ~= "INV_ITEM_ADD" then
                            g.inven_tbl[unique_key] = true
                            if inv_item then
                                local item_obj = GetIES(inv_item:GetObject())
                                local item_cls = GetClassByType("Item", item_obj.ClassID)

                                if item_cls then
                                    if g.settings.inventory_mod == 1 then
                                        local cls_name = item_cls.ClassName

                                        local is_special_item =
                                            string.find(cls_name, "EP17") or
                                                (string.find(cls_name, "EP16") and string.find(cls_name, "high")) or
                                                (string.find(cls_name, "EP13") and string.find(cls_name, "high2"))

                                        if not is_special_item and
                                            (string.find(cls_name, "belt") or string.find(cls_name, "shoulder")) then
                                            slot:SetSkinName("invenslot_rare")
                                        end
                                    else
                                        slot:SetSkinName("invenslot_pic_goddess")
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    frame:Invalidate()
    local try = frame:GetUserIValue("TRY")
    -- ts(msg, "try", try)
    if (msg == "INV_ITEM_REMOVE" or msg == "INV_ITEM_ADD") and try < 2 then
        try = try + 1
        frame:SetUserValue("TRY", try)
        frame:StopUpdateScript("mini_addons_inventory_open_func")
        frame:RunUpdateScript("mini_addons_INVENTORY_OPEN_logic", 1.0)
        return 1
    elseif (msg == "INV_ITEM_REMOVE" or msg == "INV_ITEM_ADD") and try >= 2 then
        frame:SetUserValue("TRY", 0)
        frame:StopUpdateScript("mini_addons_inventory_open_func")
        frame:StopUpdateScript("mini_addons_INVENTORY_OPEN_logic")

    elseif try >= 2 then
        frame:SetUserValue("TRY", 0)
        return 0
    else
        try = try + 1
        frame:SetUserValue("TRY", try)
        return 1 -- スクリプトを継続
    end

end

function mini_addons_INVENTORY_OPEN_logic(frame)
    -- ts(frame:GetName())
    if frame:IsVisible() == 1 then
        frame:StopUpdateScript("mini_addons_inventory_open_func")
        frame:RunUpdateScript("mini_addons_inventory_open_func", 1.0)
    else
        frame:StopUpdateScript("mini_addons_inventory_open_func")
    end
    return 0
end

function mini_addons_INVENTORY_OPEN(my_frame, my_msg)

    --[[if g.settings.inventory_mod == 0 then
        return
    end]]

    local frame = g.get_event_args(my_msg)
    if not frame then
        return
    end
    local inventory = ui.GetFrame("inventory")
    if not inventory then
        return
    end

    if (os.clock() - (g.last_inventory_open_time or 0)) < 1.0 then
        return
    end
    g.last_inventory_open_time = os.clock()
    inventory:SetUserValue("TRY", 0)
    g.inven_tbl = {}

    local elapsed_time = os.clock() - (g.load_time or 0)

    if elapsed_time < 5.0 then
        local delay = 5.0 - elapsed_time

        local delay_str = tostring(delay)

        local truncated_str = string.sub(delay_str, 1, 3)

        local final_delay = tonumber(truncated_str)

        final_delay = math.max(final_delay, 0.1)
        -- ts(frame:GetName())
        inventory:RunUpdateScript("mini_addons_INVENTORY_OPEN_logic", final_delay)

    else
        mini_addons_INVENTORY_OPEN_logic(inventory)
    end

end

function mini_addons_second_frame(frame)

    local menu_frame = ui.GetFrame("norisan_menu_frame") or ui.GetFrame(_G["norisan"]["MENU"].frame_name)
    -- ts(menu_frame:GetName())
    if menu_frame and menu_frame:IsVisible() == 1 then
        return 0
    end

    local frame_name = addon_name_lower .. "second_open"
    local second_open = ui.CreateNewFrame("notice_on_pc", frame_name, 0, 0, 0, 0)
    AUTO_CAST(second_open)
    second_open:SetSkinName("None")
    second_open:Resize(40, 40)
    second_open:SetGravity(ui.RIGHT, ui.TOP)
    local rect = second_open:GetMargin();
    second_open:SetMargin(rect.left, rect.top - 100, rect.right, rect.bottom);
    second_open:SetTitleBarSkin("None")

    local open_btn = second_open:CreateOrGetControl('picture', 'open_btn', 0, 0, 40, 40)
    AUTO_CAST(open_btn)
    open_btn:SetImage("sysmenu_jal")
    open_btn:SetEnableStretch(1)
    open_btn:SetTextTooltip("{ol}Mini Addons Setting")
    open_btn:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_SETTING_FRAME_INIT")
    second_open:ShowWindow(1)
    return 0
end

function mini_addons_rp_check_end(frame)
    local pc = GetMyPCObject()
    local cur_rp, max_rp = shared_item_relic.get_rp(pc)
    if cur_rp == max_rp then
        ui.SysMsg(g.lang == "Japanese" and "レリック自動補充完了" or "Relic auto-replenishment complete")
    elseif cur_rp < max_rp then
        ui.SysMsg(g.lang == "Japanese" and "レリック自動補充完了出来ませんでした" or
                      "Relic auto-replenishment failed")
    end
end

function mini_addons_rp_check_(frame)
    local indunenter = ui.GetFrame("indunenter")
    if not indunenter then
        return 1
    end
    if indunenter:IsVisible() == 0 then
        return 1
    end
    local pc = GetMyPCObject()
    local cur_rp, max_rp = shared_item_relic.get_rp(pc)
    if cur_rp == max_rp then
        return 1
    end
    local item_count = 0
    local item_names = {'misc_Ectonite', 'misc_Ectonite_Care'}
    for _, item_name in ipairs(item_names) do
        local item = session.GetInvItemByName(item_name)
        if item and item.count > 0 then
            item_count = item_count + item.count
        end
    end
    if item_count == 0 then
        ui.SysMsg(g.lang == "Japanese" and
                      "エクトナイトを持っていません{nl}自動補充監視を終了します" or
                      "You don't have an Ectonite{nl}Automatic replenishment monitoring will be terminated")
        return 0
    end
    session.ResetItemList()
    for _, item_name in ipairs(item_names) do
        local item = session.GetInvItemByName(item_name)

        if item and not item.isLockState then
            session.AddItemID(item:GetIESID(), item.count)
        end
    end
    local result_list = session.GetItemIDList()
    item.DialogTransaction('RELIC_CHARGE_RP', result_list)
    frame:StopUpdateScript("mini_addons_rp_check_")
    frame:RunUpdateScript("mini_addons_rp_check_end", 0.1)
    return 0
end

function mini_addons_rp_check()
    local openingameshopbtn = ui.GetFrame("openingameshopbtn")
    local open_openingameshopbtn = GET_CHILD(openingameshopbtn, "open_openingameshopbtn")
    AUTO_CAST(open_openingameshopbtn)
    open_openingameshopbtn:RunUpdateScript("mini_addons_rp_check_", 0.1)
end

local last_time = 0
local cd_time = 0.5
-- PTメンバーの死亡と復活をNICO_CHATで流す
function MINI_ADDONS_DRAW_CHAT_MSG(my_frame, my_msg)

    local now = os.clock()
    if (now - last_time) < cd_time then
        return
    end

    local groupboxname, startindex, chatframe = g.get_event_args(my_msg)

    local frame = ui.GetFrame("chatframe")
    local size = session.ui.GetMsgInfoSize(groupboxname)
    local chat = session.ui.GetChatMsgInfo(groupboxname, size - 1)
    local msg_type = chat:GetMsgType()
    if msg_type ~= "Battle" then
        -- return
    end
    local msg = chat:GetMsg()
    if string.find(msg, "!@#$Dead{MEMBER}$*$MEMBER$*$", 1, true) then
        local pattern = "^!@#%$Dead%{MEMBER%}%$%*%$MEMBER%$%*%$(.-)#@!$"
        local rep_msg = string.match(msg, pattern)
        if rep_msg then
            rep_msg = "[ " .. rep_msg .. " ]"
            rep_msg = g.lang == "Japanese" and rep_msg .. " が死亡" or rep_msg .. " died"
            NICO_CHAT(tostring("{ol}{#FF0000}{s40}" .. rep_msg))
        end
    elseif string.find(msg, "!@#$Resurrect{MEMBER}$*$MEMBER$*$", 1, true) then
        local pattern = "^!@#%$Resurrect{MEMBER}%$%*%$MEMBER%$%*%$(.-)#@!$"

        local rep_msg = string.match(msg, pattern)
        if rep_msg then
            rep_msg = "[ " .. rep_msg .. " ]"
            rep_msg = g.lang == "Japanese" and rep_msg .. " が復活" or rep_msg .. " revived"
            NICO_CHAT(tostring("{ol}{#00BFFF}{s40}" .. rep_msg))
        end
    end

    last_time = os.clock()

end
-- PTメンバーの死亡と復活をNICO_CHATで流す　ここまで

-- ワールドマップにトークンワープのクールダウンを表示
function MINI_ADDONS_OPEN_WORLDMAP2_MINIMAP(frame, msg)
    local frame = ui.GetFrame("worldmap2_minimap")
    frame:RunUpdateScript("MINI_ADDONS_TOKEN_WARP_COOLDOWN", 1.0)
end

function MINI_ADDONS_TOKEN_WARP_COOLDOWN(frame)
    local minimap_token_btn = GET_CHILD_RECURSIVELY(frame, "minimap_token_btn")
    AUTO_CAST(minimap_token_btn)
    local isTokenState = session.loginInfo.IsPremiumState(ITEM_TOKEN)
    local imageName = ""
    local cd = GET_TOKEN_WARP_COOLDOWN()
    if isTokenState == true and cd == 0 then
        imageName = "{img worldmap2_token_gold 38 38} {@st101lightbrown_16}"
    else
        imageName = "{img worldmap2_token_gray 38 38} {@st101lightbrown_16}"
    end
    minimap_token_btn:SetText(imageName .. ScpArgMsg("TokenWarp"))
    local cdtext = frame:CreateOrGetControl('richtext', 'cdtext', 50, 820)
    AUTO_CAST(cdtext)
    local minutes = math.floor(cd / 60)
    local seconds = cd % 60
    local cdtimer = string.format('%d:%02d', minutes, seconds)
    cdtext:SetText("{ol}{#FFFFFF}TokenWarp CD: " .. cdtimer)
    return 1
end

-- ヴァカリネ装備判定
function MINI_ADDONS_VAKARINE_NOTICE()

    local equip_item_list = session.GetEquipItemList()
    local equip_guid_list = equip_item_list:GetGuidList()
    local count = equip_guid_list:Count()
    local vakarine_count = 0
    for i = 0, count - 1 do
        local guid = equip_guid_list:Get(i)
        if guid ~= '0' then
            local equip_item = equip_item_list:GetItemByGuid(guid)
            if equip_item ~= nil and equip_item:GetObject() ~= nil then

                local item = GetIES(equip_item:GetObject())

                for j = 1, MAX_OPTION_EXTRACT_COUNT do
                    local propGroupName = "RandomOptionGroup_" .. j
                    local propName = "RandomOption_" .. j
                    local cls_msg = ScpArgMsg(item[propName])
                    -- plagueDoctor_bless
                    if string.find(cls_msg, "vakarine_bless") ~= nil then
                        vakarine_count = vakarine_count + 1
                    end

                end

            end
        end
    end
    if vakarine_count >= 5 then
        ui.Chat("!! " .. "vakarine")
    end
end

-- 街のラガナを非表示
function mini_addons_ragana_remove_timer(frame, msg, str, num)
    local frame = ui.GetFrame("mini_addons")
    local timer = frame:CreateOrGetControl("timer", "addontimer", 0, 0)
    AUTO_CAST(timer)
    timer:SetUpdateScript("mini_addons_ragana_remove")
    timer:Start(1.0)
end

function mini_addons_ragana_remove(frame)

    local selected_objects, selected_objects_count = SelectObject(GetMyPCObject(), 1000, "ALL")

    for i = 1, selected_objects_count do

        local handle = GetHandle(selected_objects[i])

        if handle ~= nil then
            if info.IsPC(handle) ~= 1 then
                local npcName = world.GetActor(handle):GetName()
                if npcName == "[마신의 유혹]{nl}마신 라가나의 환영" then

                    world.Leave(handle, 0.0)
                    local timer = frame:CreateOrGetControl("timer", "addontimer", 0, 0)
                    AUTO_CAST(timer)
                    timer:Stop()
                    return
                end

            end
        end
    end

end

-- 装備錬成を自動化
function MINI_ADDONS_COMMON_EQUIP_UPGRADE_OPEN(frame, msg)
    local frame = ui.GetFrame("common_equip_upgrade")
    if g.settings.status_upgrade == 0 then
        local target_status_text = GET_CHILD_RECURSIVELY(frame, "target_status_text")
        if target_status_text ~= nil then
            AUTO_CAST(target_status_text)
            target_status_text:ShowWindow(0)
        end
        local target_status_edit = GET_CHILD_RECURSIVELY(frame, "target_status_edit")
        if target_status_edit ~= nil then
            AUTO_CAST(target_status_edit)
            target_status_edit:ShowWindow(0)
        end
    else
        local target_status_text = frame:CreateOrGetControl("richtext", "target_status_text", 20, 650, 80, 30)
        AUTO_CAST(target_status_text)
        target_status_text:SetFontName("white_18_ol")
        target_status_text:SetText("Target Status")
        target_status_text:ShowWindow(1)

        function MINI_ADDONS_EQUIP_UPGRADE_SET(frame, ctrl, str, num)

            if not tonumber(ctrl:GetText()) then
                ui.SysMsg("Invalid value")
                return
            elseif tonumber(ctrl:GetText()) > 20 or tonumber(ctrl:GetText()) < 1 then
                ui.SysMsg("Invalid value")
                return
            else
                g.settings.target_status_value = tonumber(ctrl:GetText())
                ui.SysMsg("Set target value")
                MINI_ADDONS_SAVE_SETTINGS()
            end
        end

        if g.settings.target_status_value == nil then
            g.settings.target_status_value = 20
            MINI_ADDONS_SAVE_SETTINGS()
        end

        local target_status_edit = frame:CreateOrGetControl("edit", "target_status_edit", 30, 680, 80, 25)
        AUTO_CAST(target_status_edit)
        target_status_edit:SetTextAlign("center", "center")
        target_status_edit:SetFontName("white_18_ol")
        target_status_edit:SetSkinName("test_weight_skin")
        target_status_edit:SetText(g.settings.target_status_value)
        target_status_edit:SetTextTooltip(g.lang == "Japanese" and "1~20の間で設定" or "Set between 1~20")
        target_status_edit:SetEventScript(ui.ENTERKEY, "MINI_ADDONS_EQUIP_UPGRADE_SET")
        target_status_edit:ShowWindow(1)
    end
end

function MINI_ADDONS_COMMON_EQUIP_UPGRADE_PROGRESS(parent, ctrl, argStr, argNum)

    if g.settings.status_upgrade == 0 then
        base["COMMON_EQUIP_UPGRADE_PROGRESS"](parent, ctrl, argStr, argNum)
    else
        MINI_ADDONS_COMMON_EQUIP_UPGRADE_PROGRESS_(parent, ctrl, argStr, argNum)
    end
end

function MINI_ADDONS_COMMON_EQUIP_UPGRADE_PROGRESS_(parent, ctrl, argStr, argNum)

    local frame = parent:GetTopParentFrame()
    local slot = GET_CHILD_RECURSIVELY(frame, 'slot')
    local guid = slot:GetUserValue("SET_ID")
    pc.ReqExecuteTx_Item('UPGRADE_EQUIP', guid)

    local inv_item = session.GetInvItemByGuid(guid)
    if inv_item == nil then
        return
    end
    local item_obj = GetIES(inv_item:GetObject())

    COMMON_EQUIP_UPGRADE_MAT_NUM_SET(frame, item_obj)

    local cur_rank = TryGetProp(item_obj, "UpgradeRank", 0)

    if tonumber(cur_rank) < g.settings.target_status_value then

        ReserveScript("MINI_ADDONS_COMMON_EQUIP_UPGRADE_PROGRESS_CONTINUE()", 2.0)
        return
    end
end

function MINI_ADDONS_COMMON_EQUIP_UPGRADE_PROGRESS_CONTINUE()
    local parent = ui.GetFrame("common_equip_upgrade")
    if parent:IsVisible() == 0 then
        return
    end
    MINI_ADDONS_COMMON_EQUIP_UPGRADE_PROGRESS_(parent, nil, nil, nil)
end

-- ヴェルニケ階数を覚える。
function MINI_ADDONS_INDUN_EDITMSGBOX_FRAME_OPEN(type, clmsg, desc, yesScp, noScp, min_number, max_number,
    default_number)
    if g.settings.velnice.use == 0 then
        base["INDUN_EDITMSGBOX_FRAME_OPEN"](type, clmsg, desc, yesScp, noScp, min_number, max_number, default_number)
    else
        MINI_ADDONS_INDUN_EDITMSGBOX_FRAME_OPEN_(type, clmsg, desc, yesScp, noScp, min_number, max_number,
            default_number)

    end
end

function MINI_ADDONS_INDUN_EDITMSGBOX_FRAME_OPEN_(type, clmsg, desc, yesScp, noScp, min_number, max_number,
    default_number)

    default_number = g.settings.velnice.level

    ui.OpenFrame("indun_editmsgbox")

    local frame = ui.GetFrame('indun_editmsgbox')
    frame:EnableHide(1)
    frame:SetUserValue("user_value", type)

    local text = GET_CHILD_RECURSIVELY(frame, "text")
    text:SetText(clmsg)

    local text_desc = GET_CHILD_RECURSIVELY(frame, "text_desc")
    text_desc:SetText(desc)

    local edit = GET_CHILD_RECURSIVELY(frame, "edit")

    edit:SetText(default_number)
    edit:SetNumberMode(1)
    edit:SetMaxNumber(max_number)
    edit:SetMinNumber(min_number)
    edit:AcquireFocus()

    local yesBtn = GET_CHILD_RECURSIVELY(frame, "yesBtn", "ui::CButton")
    yesBtn:SetEventScript(ui.LBUTTONUP, 'MINI_ADDONS_INDUN_EDITMSGBOX_FRAME_OPEN_YES')
    yesBtn:SetEventScriptArgString(ui.LBUTTONUP, yesScp)

    local noBtn = GET_CHILD_RECURSIVELY(frame, "noBtn", "ui::CButton")
    noBtn:SetEventScript(ui.LBUTTONUP, '_INDUN_EDITMSGBOX_FRAME_OPEN_NO')
    noBtn:SetEventScriptArgString(ui.LBUTTONUP, noScp)

    yesBtn:ShowWindow(1)
    noBtn:ShowWindow(1)
end

function MINI_ADDONS_SOLO_D_TIMER_UPDATE_TEXT_GAUGE(frame, msg, argStr)

    local argument_list = StringSplit(argStr, ";")
    local ui_msg = argument_list[1]
    local waveMsg = argument_list[2]
    local current_wave = tonumber(argument_list[3])

    if g.velnice ~= current_wave and current_wave ~= 1 then

        local frame = ui.GetFrame("solo_d_timer")
        local remaintimeValue = GET_CHILD_RECURSIVELY(frame, "remaintimeValue")
        local min = remaintimeValue:GetTextByKey("min")
        local sec = string.format("%02d", tonumber(remaintimeValue:GetTextByKey("sec")))

        imcAddOn.BroadMsg("NOTICE_Dm_stage_start",
            string.format("{nl} {nl} {nl} {nl} {nl} {nl} {nl}{@st55_a}Round %s / 8 Fight{nl}{@st64}Remain Time %s : %s",
                current_wave - 1, min, sec), 2.0)
        g.velnice = current_wave
    else
        return
    end

end

function MINI_ADDONS_INDUN_EDITMSGBOX_FRAME_OPEN_YES(parent, ctrl, argStr, argNum)
    local edit = GET_CHILD_RECURSIVELY(parent, "edit")
    local text = edit:GetText()

    g.settings.velnice.level = tonumber(text)
    MINI_ADDONS_SAVE_SETTINGS()

    local scp = _G[argStr]
    if scp ~= nil then
        local user_value = tonumber(parent:GetUserValue("user_value"))
        scp(user_value, text)
    end
    ui.CloseFrame("indun_editmsgbox")
end

-- PTバフの表示非表示切り替え
function MINI_ADDONS_BUFFLIST_ALL_CHECK(frame, ctrl, str, num)
    local is_check = ctrl:IsChecked()
    local frame = ctrl:GetTopParentFrame()
    local bg = GET_CHILD_RECURSIVELY(frame, "bg")

    local i = 1
    for buff_id, _ in pairs(g.buffs) do

        local buffcheck = GET_CHILD_RECURSIVELY(frame, "buffcheck" .. i)
        if buffcheck then
            AUTO_CAST(buffcheck)
            buffcheck:SetCheck(is_check)
            g.buffs[buff_id] = is_check
            i = i + 1
        end
    end

    g.save_json(g.buffs_path, g.buffs)
    MINI_ADDONS_SAVE_AND_CREATE_BUFFIDS()
end

function mini_addons_bufflist_search(frame, ctrl)
    if ctrl:GetName() == "search_btn" then
        ctrl = frame
    end
    local ctrl_text = ctrl:GetText()

    if ctrl_text == "" then
        MINI_ADDONS_BUFFLIST_FRAME_INIT()
        return
    end

    local top_frame = ctrl:GetTopParentFrame()

    local bufflist_bg = GET_CHILD(top_frame, "bufflist_bg")
    bufflist_bg:RemoveAllChild()

    local buffs = {}
    local buff_id = tonumber(ctrl_text)
    if buff_id then

        for buff_id_str, check_state in pairs(g.buffs) do
            if string.find(buff_id_str, ctrl_text, 1, true) then
                local buff_data = {
                    buff_id = tonumber(buff_id_str),
                    check = check_state
                }
                table.insert(buffs, buff_data)
            end
        end

    else
        for buff_id_str, check_state in pairs(g.buffs) do
            local buff_name = dic.getTranslatedStr(GetClassByType("Buff", buff_id_str).Name)
            if string.find(buff_name, ctrl_text, 1, true) then
                local buff_data = {
                    buff_id = tonumber(buff_id_str),
                    check = check_state
                }
                table.insert(buffs, buff_data)
            end
        end

        local y = 0

    end

    local y = 0
    for i, buff_data in ipairs(buffs) do
        local buff_id = buff_data.buff_id
        local check = buff_data.check
        local bufflist_bg = GET_CHILD(top_frame, "bufflist_bg")
        local buff_slot = bufflist_bg:CreateOrGetControl('slot', 'buff_slot' .. buff_id, 10, y + 5, 30, 30)
        AUTO_CAST(buff_slot)
        local buff_cls = GetClassByType("Buff", buff_id)

        if buff_cls then
            SET_SLOT_IMG(buff_slot, GET_BUFF_ICON_NAME(buff_cls))

            local icon = CreateIcon(buff_slot)
            AUTO_CAST(icon)
            icon:SetTooltipType('buff')
            icon:SetTooltipArg(buff_cls.Name, buff_id, 0)

            local buffcheck = bufflist_bg:CreateOrGetControl('checkbox', 'buffcheck' .. buff_id, 45, y + 5, 30, 30)
            AUTO_CAST(buffcheck)

            buffcheck:SetCheck(check)

            buffcheck:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_BUFFCHECK")
            buffcheck:SetEventScriptArgNumber(ui.LBUTTONUP, buff_id)
            buffcheck:SetText("{ol}" .. buff_cls.Name)
            buffcheck:SetTextTooltip(g.lang == "Japanese" and "{ol}" .. buff_id ..
                                         "{nl}チェックするとパーティーバフ表示" or "{ol}" .. buff_id ..
                                         "{nl}Party buff display when checked")
            y = y + 35

        end
    end

end

function MINI_ADDONS_BUFFLIST_FRAME_INIT()
    local bufflistframe = ui.CreateNewFrame("notice_on_pc", "mini_addons_bufflist", 0, 0, 10, 10)
    AUTO_CAST(bufflistframe)
    bufflistframe:SetSkinName("test_frame_low")
    bufflistframe:Resize(500, 1060)
    bufflistframe:SetPos(10, 10)
    bufflistframe:SetLayerLevel(121)
    bufflistframe:RemoveAllChild()

    local bg = bufflistframe:CreateOrGetControl("groupbox", "bufflist_bg", 10, 45, 480, 1005)
    AUTO_CAST(bg)
    bg:SetSkinName("bg")
    bg:SetEventScript(ui.RBUTTONUP, "MINI_ADDONS_BUFFLIST_FRAME_CLOSE")
    bg:SetTextTooltip(g.lang == "Japanese" and "{ol}右クリックで閉じます。" or "Right-click to close.")

    local closeBtn = bufflistframe:CreateOrGetControl('button', 'closeBtn', 450, 0, 30, 30)
    AUTO_CAST(closeBtn)
    closeBtn:SetImage("testclose_button")
    closeBtn:SetGravity(ui.RIGHT, ui.TOP)
    closeBtn:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_BUFFLIST_FRAME_CLOSE")

    local all_toggle = bufflistframe:CreateOrGetControl('checkbox', 'all_toggle', 435, 10, 25, 25)
    AUTO_CAST(all_toggle)
    all_toggle:SetTextTooltip(g.lang == "Japanese" and "{ol}全ての表示切替" or "Toggle All Displays")
    all_toggle:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_BUFFLIST_ALL_CHECK")

    local bufflisttext = bufflistframe:CreateOrGetControl('richtext', 'bufflisttext', 10, 15, 200, 30)
    AUTO_CAST(bufflisttext)
    bufflisttext:SetText("{ol}BUFF LIST")

    local search_edit = bufflistframe:CreateOrGetControl("edit", "search_edit", 120, 10, 305, 38)
    AUTO_CAST(search_edit)
    search_edit:SetFontName("white_18_ol")
    search_edit:SetTextAlign("left", "center")
    search_edit:SetSkinName("inventory_serch")

    search_edit:SetEventScript(ui.ENTERKEY, "mini_addons_bufflist_search")

    local search_btn = search_edit:CreateOrGetControl("button", "search_btn", 0, 0, 40, 38)
    AUTO_CAST(search_btn)
    search_btn:SetImage("inven_s")
    search_btn:SetGravity(ui.RIGHT, ui.TOP)
    search_btn:SetEventScript(ui.LBUTTONUP, "mini_addons_bufflist_search")

    local buff_id_list_to_sort = {}
    for buff_id_str, check_state in pairs(g.buffs) do
        table.insert(buff_id_list_to_sort, {
            id = tonumber(buff_id_str),
            checked = (check_state == 0)
        })
    end

    table.sort(buff_id_list_to_sort, function(a, b)
        if b.checked and not a.checked then
            return true
        elseif not b.checked and a.checked then
            return false
        else

            return a.id < b.id
        end
    end)

    local y = 0

    for item_index, buff_entry in ipairs(buff_id_list_to_sort) do
        local buffID = buff_entry.id -- バフIDを取得
        local is_checked_for_this_buff = buff_entry.checked
        local buffslot = bg:CreateOrGetControl('slot', 'buffslot' .. buffID, 10, y + 5, 30, 30)
        AUTO_CAST(buffslot)
        local buffCls = GetClassByType("Buff", buffID)

        if buffCls then -- nilチェックは大事
            SET_SLOT_IMG(buffslot, GET_BUFF_ICON_NAME(buffCls))

            local icon = CreateIcon(buffslot)
            AUTO_CAST(icon)
            icon:SetTooltipType('buff')
            icon:SetTooltipArg(buffCls.Name, buffID, 0)

            local buffcheck = bg:CreateOrGetControl('checkbox', 'buffcheck' .. buffID, 45, y + 5, 30, 30)
            AUTO_CAST(buffcheck)

            buffcheck:SetCheck(is_checked_for_this_buff and 0 or 1)

            buffcheck:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_BUFFCHECK")
            buffcheck:SetEventScriptArgNumber(ui.LBUTTONUP, buffID)
            buffcheck:SetText("{ol}" .. buffCls.Name)
            buffcheck:SetTextTooltip(g.lang == "Japanese" and "{ol}" .. buffID ..
                                         "{nl}チェックするとパーティーバフ表示" or "{ol}" .. buffID ..
                                         "{nl}Party buff display when checked")
            y = y + 35

        end
    end

    bufflistframe:ShowWindow(1)

end

function MINI_ADDONS_BUFFCHECK(frame, ctrl, argStr, buffID)
    local check = ctrl:IsChecked()

    if g.buffs[tostring(buffID)] ~= nil then
        g.buffs[tostring(buffID)] = check
        g.save_json(g.buffs_path, g.buffs)
    end
    MINI_ADDONS_SAVE_AND_CREATE_BUFFIDS()
end

function MINI_ADDONS_BUFFLIST_FRAME_CLOSE()
    local frame = ui.GetFrame("mini_addons_bufflist")
    frame:ShowWindow(0)
end

function MINI_ADDONS_BUFF_TABLE_INSERT(buff_id)

    local str_buff_id = tostring(buff_id)
    if g.buffs[str_buff_id] == nil then
        if g.settings.pt_buff == 0 then
            g.buffs[str_buff_id] = 1
        else
            g.buffs[str_buff_id] = 0
        end
        g.save_json(g.buffs_path, g.buffs)
    end
end

function MINI_ADDONS_ON_PARTYINFO_BUFFLIST_UPDATE(frame)
    local frame = ui.GetFrame("partyinfo")
    if frame == nil then
        return
    end
    local pcparty = session.party.GetPartyInfo()
    if pcparty == nil then
        DESTROY_CHILD_BYNAME(frame, 'PTINFO_')
        frame:ShowWindow(0)
        return
    end

    local partyInfo = pcparty.info
    local obj = GetIES(pcparty:GetObject())
    local list = session.party.GetPartyMemberList(0)
    local count = list:Count()
    local memberIndex = 0

    local myInfo = session.party.GetMyPartyObj()
    -- 접속중 파티원 버프리스트
    for i = 0, count - 1 do
        local partyMemberInfo = list:Element(i)

        if geMapTable.GetMapName(partyMemberInfo:GetMapID()) ~= 'None' then

            local buffCount = partyMemberInfo:GetBuffCount()

            local partyInfoCtrlSet = frame:GetChild('PTINFO_' .. partyMemberInfo:GetAID())
            if partyInfoCtrlSet ~= nil then

                local buffListSlotSet = GET_CHILD(partyInfoCtrlSet, "buffList", "ui::CSlotSet")
                local debuffListSlotSet = GET_CHILD(partyInfoCtrlSet, "debuffList", "ui::CSlotSet")

                -- 초기화
                for j = 0, buffListSlotSet:GetSlotCount() - 1 do
                    local slot = buffListSlotSet:GetSlotByIndex(j)
                    slot:SetKeyboardSelectable(false)
                    if slot == nil then
                        break
                    end
                    slot:ShowWindow(0)
                end

                for j = 0, debuffListSlotSet:GetSlotCount() - 1 do
                    local slot = debuffListSlotSet:GetSlotByIndex(j)
                    if slot == nil then
                        break
                    end
                    slot:ShowWindow(0)
                end

                -- 아이콘 셋팅
                if buffCount <= 0 then
                    partyMemberInfo:ResetBuff()
                    buffCount = partyMemberInfo:GetBuffCount()
                end

                if buffCount > 0 then
                    local buffIndex = 0
                    local debuffIndex = 0
                    for j = 0, buffCount - 1 do
                        local buffID = partyMemberInfo:GetBuffIDByIndex(j)
                        local cls = GetClassByType("Buff", buffID)
                        -- if cls ~= nil and IS_PARTY_INFO_SHOWICON(cls.ShowIcon) == true and cls.ClassName ~= "TeamLevel" then
                        if cls ~= nil and cls.ClassName ~= "TeamLevel" then
                            local buffOver = partyMemberInfo:GetBuffOverByIndex(j)
                            local buffTime = partyMemberInfo:GetBuffTimeByIndex(j)
                            local slot = nil
                            if cls.Group1 == 'Buff' then

                                local image = TryGetProp(cls, 'Icon', 'None')
                                if image ~= "None" and cls.Name ~= "None" then
                                    MINI_ADDONS_BUFF_TABLE_INSERT(buffID)
                                end

                                if g.settings.party_buff == 1 then
                                    if g.buffs[tostring(buffID)] == 1 then
                                        slot = buffListSlotSet:GetSlotByIndex(buffIndex)
                                        buffIndex = buffIndex + 1
                                    else
                                        slot = nil -- g.buffsに存在しない場合はslotをnilにする
                                    end
                                else
                                    slot = buffListSlotSet:GetSlotByIndex(buffIndex)
                                    buffIndex = buffIndex + 1
                                end

                            elseif cls.Group1 == 'Debuff' then
                                slot = debuffListSlotSet:GetSlotByIndex(debuffIndex)
                                debuffIndex = debuffIndex + 1
                            end

                            if slot ~= nil then
                                local icon = slot:GetIcon()
                                if icon == nil then
                                    icon = CreateIcon(slot)
                                end

                                local handle = 0
                                if myInfo ~= nil then
                                    if myInfo:GetMapID() == partyMemberInfo:GetMapID() and myInfo:GetChannel() ==
                                        partyMemberInfo:GetChannel() then
                                        handle = partyMemberInfo:GetHandle()
                                    end
                                end

                                handle = tostring(handle)
                                icon:SetDrawCoolTimeText(math.floor(buffTime / 1000))
                                icon:SetTooltipType('buff')
                                icon:SetTooltipArg(handle, buffID, "")

                                local imageName = 'icon_' .. TryGetProp(cls, 'Icon', 'None')
                                if imageName ~= "icon_None" then
                                    icon:Set(imageName, 'BUFF', buffID, 0)
                                end

                                if buffOver > 1 then
                                    slot:SetText('{s13}{ol}{b}' .. buffOver, 'count', ui.RIGHT, ui.BOTTOM, 1, 2)
                                else
                                    slot:SetText("")
                                end

                                slot:ShowWindow(1)
                            end
                        end
                    end
                end
            end
        end
    end
end

function MINI_ADDONS_ON_PARTYINFO_INST_UPDATE(frame, msg, argStr, argNum)
    local frame = ui.GetFrame("partyinfo")
    MINI_ADDONS_ON_PARTYINFO_BUFFLIST_UPDATE(frame)
end

function mini_addons_basefunction_old()
    return
end

-- EP13ショップを街で開ける
function mini_addons_REPUTATION_SHOP_OPEN_context(frame, ctrl, str, num)

    function mini_addons_ON_REQUEST_REPUTATION_SHOP_OPEN(shop_type)

        REPUTATION_SHOP_SET_SHOPTYPE(shop_type)
        ui.OpenFrame("reputation_shop")
    end

    local context = ui.CreateContextMenu("select_shop", "EP13 Shop List ", 0, -200, 0, 0)
    local shop_tbl = {{
        name = "REPUTATION_ep13_f_siauliai_1",
        id = 11209,
        text = ClMsg('MonInfo_RaceType_Velnias'),
        box = ""
    }, {
        name = "REPUTATION_ep13_f_siauliai_2",
        id = 11210,
        text = ClMsg('MonInfo_RaceType_Widling'),
        box = ""
    }, {
        name = "REPUTATION_ep13_f_siauliai_3",
        id = 11211,
        text = ClMsg('MonInfo_RaceType_Klaida'),
        box = GetClassByType("Item", 640530).Name
    }, {
        name = "REPUTATION_ep13_f_siauliai_4",
        id = 11212,
        text = ClMsg('MonInfo_RaceType_Paramune'),
        box = GetClassByType("Item", 640531).Name
    }, {
        name = "REPUTATION_ep13_f_siauliai_5",
        id = 11213,
        text = ClMsg('MonInfo_RaceType_Forester'),
        box = ""
    }}

    for index, shop in ipairs(shop_tbl) do
        local shop_name = shop.name
        local id = shop.id
        local map_name = GetClassByType("Map", id).Name
        local box = shop.box
        local text = g.lang == "Japanese" and
                         string.gsub(dic.getTranslatedStr(shop.text), "型", " 憤怒ポーション ") ..
                         "製造書 : " .. box or shop.text .. " Recipe : " .. box
        ui.AddContextMenuItem(context, map_name .. " (" .. text .. ") ",
            string.format("mini_addons_ON_REQUEST_REPUTATION_SHOP_OPEN('%s')", shop_name))
    end
    ui.OpenContextMenu(context)
end

function mini_addons_reputation_shop_close()
    local shopframe = ui.GetFrame("reputation_shop")
    if shopframe:IsVisible() == 1 then
        ui.CloseFrame("reputation_shop")
        ui.ToggleFrame('inventory')
    end
end

function MINI_ADDONS_NOTICE_ON_MSG_baubas(frame, msg)

    local frame, msg, str, num = g.get_event_args(msg)

    if g.settings.baubas_call.use == 1 then
        if string.find(str, 'AppearFieldBoss_ep14_2_d_castle_3{name}') then

            imcSound.PlaySoundEvent('sys_tp_box_4')

            local current_time = os.time()
            g.current_time = g.current_time or current_time
            if current_time - g.current_time >= 60 then
                g.call = {}
                g.current_time = current_time
            end
            if not g.call["AppearFieldBoss_ep14_2_d_castle_3"] then

                NICO_CHAT(string.format("{@st55_a}%s", str))
                CHAT_SYSTEM(str)
                g.call["AppearFieldBoss_ep14_2_d_castle_3"] = true

                local guild_notice = "[NOTICE]Baubas has appeared"
                MINI_ADDONS_NOTICE_ON_MSG_GUILD(guild_notice)

            end

        elseif string.find(str, '{name}DisappearFieldBoss') and string.find(str, '맹화의 바우바') then
            CHAT_SYSTEM(str)
            local guild_notice = "[NOTICE]Baubas has been defeated"
            MINI_ADDONS_NOTICE_ON_MSG_GUILD(guild_notice)
        end
    end
end

function MINI_ADDONS_NOTICE_ON_MSG_GUILD(str)

    if g.settings.baubas_call.guild_notice == 0 then
        return
    end

    local chatframe = ui.GetFrame("chat")
    ui.SetChatType(3) -- 2pt 3guild 4wis 5gurop
    SET_CHAT_TEXT_TO_CHATFRAME(str)
    local edit = chatframe:GetChild('mainchat')
    AUTO_CAST(edit)
    edit:RunEnterKeyScript()
    ui.ProcessReturnKey()
    chatframe:ShowWindow(0)
end

-- testcode
-- _G.imcAddOn.BroadMsg('NOTICE_Dm_Global_Shout', _G.ScpArgMsg('AppearFieldBoss_ep14_2_d_castle_3{name}', 'name', "name"),
--   1)
-- _G.imcAddOn.BroadMsg('NOTICE_Dm_Global_Shout',
--   _G.ScpArgMsg('{name}DisappearFieldBoss', 'name', "맹화의 바우바스"), 1)

function MINI_ADDONS_fps_edit(parent, ctrl)

    local fps_num = tonumber(ctrl:GetText())
    local performance_limit_text = GET_CHILD(parent, "performance_limit_text")
    AUTO_CAST(performance_limit_text)
    performance_limit_text:SetTextByKey("opValue", fps_num)

    local performance_limit_slide = GET_CHILD(parent, "performance_limit_slide")
    AUTO_CAST(performance_limit_slide)
    config.SetPerformanceLimit(fps_num)
    performance_limit_slide:SetLevel(fps_num)
end

function MINI_ADDONS_SYS_OPTION_OPEN(frame, msg)

    local systemoption = ui.GetFrame("systemoption")
    local perfBox = GET_CHILD_RECURSIVELY(systemoption, "perfBox")
    local fps_edit = perfBox:CreateOrGetControl('edit', 'fps_edit', 20, 200, 60, 25)
    AUTO_CAST(fps_edit)
    fps_edit:SetEventScript(ui.ENTERKEY, "MINI_ADDONS_fps_edit")
    fps_edit:SetTextTooltip("{ol}1~240")
    fps_edit:SetFontName("white_16_ol")
    fps_edit:SetTextAlign("center", "center")
    local fps_config_lv = config.GetPerformanceLimit()
    fps_edit:SetText("{ol}" .. fps_config_lv)

end

function mini_addons_SOLODUNGEON_RANKINGPAGE_GET_REWARD()
    soloDungeonClient.ReqSoloDungeonReward()
    g.solodun_reward = true
end

-- どこでもメンバーインフォ機能
function MINI_ADDONS_CHAT_RBTN_POPUP(my_frame, my_msg)

    local frame, chatCtrl = g.get_event_args(my_msg)

    local topFrame = frame:GetTopParentFrame()
    local parentFrame = frame:GetParent()
    local topFrame_Name = topFrame:GetName()
    local parentFrame_Name = parentFrame:GetName()
    if session.world.IsIntegrateServer() == true then
        ui.SysMsg(ScpArgMsg("CantUseThisInIntegrateServer"))
        return
    end

    local targetName = chatCtrl:GetUserValue("TARGET_NAME")
    local targetTxt = chatCtrl:GetUserValue("SENTENCE")
    if targetName == "" or GETMYFAMILYNAME() == targetName then
        return
    end
    local context = ui.CreateContextMenu("CONTEXT_CHAT_RBTN", targetName, 0, 0, 350, 100)
    ui.AddContextMenuItem(context, ScpArgMsg("WHISPER"), string.format("ui.WhisperTo('%s')", targetName))
    local strRequestAddFriendScp = string.format("friends.RequestRegister('%s')", targetName)
    ui.AddContextMenuItem(context, ScpArgMsg("ReqAddFriend"), strRequestAddFriendScp)
    local partyinviteScp = string.format("PARTY_INVITE(\"%s\")", targetName)
    ui.AddContextMenuItem(context, ScpArgMsg("PARTY_INVITE"), partyinviteScp)

    -- translate Menu
    local txt = chatCtrl:GetTextByKey("text")
    local ctrlName = frame:GetName()
    if GET_PRIVATE_CHANNEL_ACTIVE_STATE() == true then
        local translateScp = string.format("REQ_TRANSLATE_TEXT('%s','%s','%s')", topFrame_Name, parentFrame_Name,
            ctrlName)
        ui.AddContextMenuItem(context, ScpArgMsg("TRANSLATE"), translateScp)
    end
    local copyPcId = string.format("COPY_PC_ID('%s')", targetName)
    ui.AddContextMenuItem(context, ScpArgMsg("CopyPcId"), copyPcId)

    local copyPcSentence = string.format("COPY_PC_SENTENCE('%s')", targetTxt)
    ui.AddContextMenuItem(context, ScpArgMsg("CopyPcSentence"), copyPcSentence)

    local blockScp = string.format("CHAT_BLOCK_MSG('%s')", targetName)
    ui.AddContextMenuItem(context, ScpArgMsg("FriendBlock"), blockScp)
    ui.AddContextMenuItem(context, ScpArgMsg("Report_AutoBot"),
        string.format("REPORT_AUTOBOT_MSGBOX(\"%s\")", targetName))

    ui.AddContextMenuItem(context, ScpArgMsg("Cancel"), "None")

    -- ui.AddContextMenuItem(context, ScpArgMsg('ShowInfomation'), string.format("ui.Chat(%s)", "/ " .. targetName))
    if g.settings.memberinfo == 1 then
        ui.AddContextMenuItem(context, "-----", "None")
        ui.AddContextMenuItem(context, ScpArgMsg('ShowInfomation'),
            string.format("ui.Chat('%s')", "/memberinfo " .. targetName))
    end
    ui.OpenContextMenu(context)
end

function MINI_ADDONS_POPUP_GUILD_MEMBER(my_frame, my_msg)

    local parent, ctrl = g.get_event_args(my_msg)

    local aid = parent:GetUserValue("AID")
    if aid == "None" then
        aid = ctrl:GetUserValue("AID")
    end

    local memberInfo = session.party.GetPartyMemberInfoByAID(PARTY_GUILD, aid)
    local isLeader = AM_I_LEADER(PARTY_GUILD)
    local myAid = session.loginInfo.GetAID()

    local name = memberInfo:GetName()

    local contextMenuCtrlName = string.format("{@st41}%s{/}", name)
    local context = ui.CreateContextMenu("PC_CONTEXT_MENU", name, 0, 0, 170, 100)

    if isLeader == 1 or HAS_KICK_CLAIM() then
        ui.AddContextMenuItem(context, ScpArgMsg("Ban"), string.format("GUILD_BAN('%s')", aid))
    end

    if isLeader == 1 and aid ~= myAid then
        local mapName = session.GetMapName()
        if mapName == 'guild_agit_1' then
            ui.AddContextMenuItem(context, ScpArgMsg("GiveGuildLeaderPermission"),
                string.format("SEND_REQ_GUILD_MASTER('%s')", name))
        end
    end

    if isLeader == 1 then
        local list = session.party.GetPartyMemberList(PARTY_GUILD)
        if list:Count() == 1 then
            ui.AddContextMenuItem(context, ScpArgMsg("Disband"), "DESTROY_GUILD()")
        end
    else
        if aid == myAid then
            ui.AddContextMenuItem(context, ScpArgMsg("GULID_OUT"), "OUT_GUILD_CHECK()")
        end
    end

    if isLeader == 1 and aid ~= myAid then
        local summonSkl = GetClass('Skill', 'Templer_SummonGuildMember')
        ui.AddContextMenuItem(context, summonSkl.Name, string.format("SUMMON_GUILD_MEMBER('%s')", aid))
    end

    if isLeader == 1 and aid ~= myAid then
        local goSkl = GetClass('Skill', 'Templer_WarpToGuildMember')
        ui.AddContextMenuItem(context, goSkl.Name, string.format("WARP_GUILD_MEMBER('%s')", aid))
    end

    ui.AddContextMenuItem(context, ScpArgMsg("WHISPER"), string.format("ui.WhisperTo('%s')", name))
    ui.AddContextMenuItem(context, ScpArgMsg("Cancel"), "None")

    if g.settings.memberinfo == 1 then

        ui.AddContextMenuItem(context, "-----", "None")

        ui.AddContextMenuItem(context, ScpArgMsg('ShowInfomation'),
            string.format("ui.Chat('%s')", "/memberinfo " .. name))
    end
    ui.OpenContextMenu(context)

end

function MINI_ADDONS_CONTEXT_PARTY(my_frame, my_msg)

    local frame, ctrl, aid = g.get_event_args(my_msg)

    local myAid = session.loginInfo.GetAID()

    local pcparty = session.party.GetPartyInfo()
    local iamLeader = false

    if pcparty.info:GetLeaderAID() == myAid then
        iamLeader = true
    end

    local myInfo = session.party.GetPartyMemberInfoByAID(PARTY_NORMAL, myAid)
    local memberInfo = session.party.GetPartyMemberInfoByAID(PARTY_NORMAL, aid)
    local context = ui.CreateContextMenu("CONTEXT_PARTY", "", 0, 0, 170, 100)
    if session.world.IsIntegrateServer() == true and session.world.IsIntegrateIndunServer() == false then
        local actor = GetMyActor()
        local execScp = string.format("ui.Chat(\"/changePVPObserveTarget %d 0\")", memberInfo:GetHandle())
        ui.AddContextMenuItem(context, ScpArgMsg("Observe{PC}", 'PC', memberInfo:GetName()), execScp)
        ui.OpenContextMenu(context)
        return
    end
    if aid == myAid then
        -- 1. 누구든 자기 자신.
        ui.AddContextMenuItem(context, ScpArgMsg("WithdrawParty"), "OUT_PARTY()")
    elseif iamLeader == true then
        -- 2. 파티장이 파티원 우클릭
        -- 대화하기. 세부정보보기. 파티장 위임. 추방.
        ui.AddContextMenuItem(context, ScpArgMsg("WHISPER"), string.format("ui.WhisperTo('%s')", memberInfo:GetName()))
        local strRequestAddFriendScp = string.format("friends.RequestRegister('%s')", memberInfo:GetName())
        ui.AddContextMenuItem(context, ScpArgMsg("ReqAddFriend"), strRequestAddFriendScp)

        ui.AddContextMenuItem(context, ScpArgMsg("GiveLeaderPermission"),
            string.format("GIVE_PARTY_LEADER(\"%s\")", memberInfo:GetName()))
        ui.AddContextMenuItem(context, ScpArgMsg("Ban"), string.format("BAN_PARTY_MEMBER(\"%s\")", memberInfo:GetName()))

        if session.world.IsDungeon() and session.world.IsIntegrateIndunServer() == true then
            local aid = memberInfo:GetAID()
            local serverName = GetServerNameByGroupID(GetServerGroupID())
            local playerName = memberInfo:GetName()
            local scp =
                string.format("SHOW_INDUN_BADPLAYER_REPORT(\"%s\", \"%s\", \"%s\")", aid, serverName, playerName)
            ui.AddContextMenuItem(context, ScpArgMsg("IndunBadPlayerReport"), scp)
        end

    else
        -- 3. 파티원이 파티원 우클릭
        -- 대화하기. 세부 정보 보기.
        ui.AddContextMenuItem(context, ScpArgMsg("WHISPER"), string.format("ui.WhisperTo('%s')", memberInfo:GetName()))
        local strRequestAddFriendScp = string.format("friends.RequestRegister('%s')", memberInfo:GetName())
        ui.AddContextMenuItem(context, ScpArgMsg("ReqAddFriend"), strRequestAddFriendScp)

        if session.world.IsDungeon() and session.world.IsIntegrateIndunServer() == true then
            local aid = memberInfo:GetAID()
            local serverName = GetServerNameByGroupID(GetServerGroupID())
            local playerName = memberInfo:GetName()
            local scp =
                string.format("SHOW_INDUN_BADPLAYER_REPORT(\"%s\", \"%s\", \"%s\")", aid, serverName, playerName)
            ui.AddContextMenuItem(context, ScpArgMsg("IndunBadPlayerReport"), scp)

        end

    end

    ui.AddContextMenuItem(context, ScpArgMsg("Cancel"), "None")

    if g.settings.memberinfo == 1 then
        ui.AddContextMenuItem(context, "-----", "None")

        ui.AddContextMenuItem(context, ScpArgMsg('ShowInfomation'),
            string.format("ui.Chat('%s')", "/memberinfo " .. memberInfo:GetName()))
        ui.AddContextMenuItem(context, "----", "None")
        ui.AddContextMenuItem(context, ScpArgMsg("RequestFriendlyFight"),
            string.format("REQUEST_FIGHT(\"%d\")", memberInfo:GetHandle()))
    end
    ui.OpenContextMenu(context)
end

function MINI_ADDONS_SHOW_PC_CONTEXT_MENU(my_frame, my_msg)

    local handle = g.get_event_args(my_msg)

    if world.IsPVPMap() == true or session.colonywar.GetIsColonyWarMap() == true or IS_IN_EVENT_MAP() == true then
        return
    end

    local targetInfo = info.GetTargetInfo(handle)
    if targetInfo.IsDummyPC == 1 then
        if targetInfo.isSkillObj == 0 then -- 유체이탈은 클릭해도 아무반응 없도록 한다.
            POPUP_DUMMY(handle, targetInfo)
        end
        return
    end

    local pcObj = world.GetActor(handle)
    if pcObj == nil then
        return
    end

    if pcObj:IsMyPC() == 1 then
        if 1 == session.IsGM() then
            local contextMenuCtrlName = string.format("{@st41}%s (%d){/}", pcObj:GetPCApc():GetFamilyName(), handle)
            local context = ui.CreateContextMenu("PC_CONTEXT_MENU", pcObj:GetPCApc():GetFamilyName(), 0, 0, 100, 100)

            local strscp = string.format("ui.Chat(\"//runscp TEST_SERVPOS %d\")", handle)
            ui.AddContextMenuItem(context, ScpArgMsg("Auto_{@st42b}SeoBeowiChiBoKi{/}"), strscp)

            strscp = string.format("debug.TestNode(%d)", handle)
            ui.AddContextMenuItem(context, ScpArgMsg("Auto_{@st42b}NodeBoKi{/}"), strscp)

            strscp = string.format("debug.CheckModelFilePath(%d)", handle)
            ui.AddContextMenuItem(context, ScpArgMsg("Auto_{@st42b}XACTegSeuChyeoKyeongLo{/}"), strscp)

            strscp = string.format("debug.TestSnapTexture(%d)", handle)
            ui.AddContextMenuItem(context, "{@st42b}SnapTexture{/}", strscp)

            strscp = string.format("debug.TestShowBoundingBox(%d)", handle)
            ui.AddContextMenuItem(context, ScpArgMsg("Auto_{@st42b}BaunDingBagSeuBoKi{/}"), strscp)

            strscp = string.format("SCR_OPER_RELOAD_HOTKEY(%d)", handle)
            ui.AddContextMenuItem(context, "ReloadHotKey", strscp)

            strscp = string.format("SCR_CLIENTTESTSCP(%d)", handle)
            ui.AddContextMenuItem(context, "ClientTestScp", strscp)

            ui.OpenContextMenu(context)

            return context
        end

    end

    local partyinfo = session.party.GetPartyInfo()
    local accountObj = GetMyAccountObj()
    if pcObj:IsMyPC() == 0 and info.IsPC(pcObj:GetHandleVal()) == 1 then
        if targetInfo.IsDummyPC == 1 then
            packet.DummyPCDialog(handle)
            return
        end

        local contextMenuCtrlName = string.format("{@st41}%s (%d){/}", pcObj:GetPCApc():GetFamilyName(), handle)
        local context = ui.CreateContextMenu("PC_CONTEXT_MENU", pcObj:GetPCApc():GetFamilyName(), 0, 0, 170, 100)

        -- 여기에 캐릭터 정보보기, 로그아웃PC관련 메뉴 추가하면됨
        if session.world.IsIntegrateServer() == false then
            local strscp = string.format("exchange.RequestChange(%d)", pcObj:GetHandleVal())
            ui.AddContextMenuItem(context, "{img context_transaction 18 18} " .. ClMsg("Exchange"), strscp)

            local strWhisperScp = string.format("ui.WhisperTo('%s')", pcObj:GetPCApc():GetFamilyName())
            ui.AddContextMenuItem(context, "{img context_whisper 18 17} " .. ClMsg("WHISPER"), strWhisperScp)
            strscp = string.format("PARTY_INVITE(\"%s\")", pcObj:GetPCApc():GetFamilyName())
            ui.AddContextMenuItem(context, "{img context_party_invitation 18 17} " .. ClMsg("PARTY_INVITE"), strscp)

            --[[
			if AM_I_LEADER(PARTY_GUILD) == 1 or IS_GUILD_AUTHORITY(1, session.loginInfo.GetAID()) == 1 then
				strscp = string.format("GUILD_INVITE(\"%s\")", pcObj:GetPCApc():GetFamilyName())
				ui.AddContextMenuItem(context, ClMsg("GUILD_INVITE"), strscp)
			end
			--]]
            if session.party.GetPartyInfo(PARTY_GUILD) ~= nil and targetInfo.hasGuild == false then
                strscp = string.format("GUILD_INVITE(\"%s\")", pcObj:GetPCApc():GetFamilyName())
                ui.AddContextMenuItem(context, "{img context_guild_invitation 18 17} " .. ClMsg("GUILD_INVITE"), strscp)
            end

            strscp = string.format("barrackNormal.Visit(%d)", handle)
            ui.AddContextMenuItem(context, "{img context_lodging_visit 16 17} " .. ScpArgMsg("VisitBarrack"), strscp)
            strscp = string.format("ui.ToggleHeaderText(%d)", handle)
            if pcObj:GetHeaderText() ~= nil and string.len(pcObj:GetHeaderText()) ~= 0 then
                if pcObj:IsHeaderTextVisible() == true then
                    ui.AddContextMenuItem(context, "{img context_preface_block 18 17} " .. ClMsg("BlockTitleText"),
                        strscp)
                else
                    ui.AddContextMenuItem(context, "{img context_preface_remove 18 17} " .. ClMsg("UnblockTitleText"),
                        strscp)
                end
            end
        end
        if g.settings.memberinfo ~= 1 then
            local strscp = string.format("PROPERTY_COMPARE(%d)", handle)
            ui.AddContextMenuItem(context, "{img context_look_into 18 17} " .. ScpArgMsg("Auto_SalPyeoBoKi"), strscp)
        end
        if session.world.IsIntegrateServer() == false then
            local strRequestAddFriendScp = string.format("friends.RequestRegister('%s')",
                pcObj:GetPCApc():GetFamilyName())
            ui.AddContextMenuItem(context, "{img context_friend_application 18 13} " .. ScpArgMsg("ReqAddFriend"),
                strRequestAddFriendScp)
        end

        ui.AddContextMenuItem(context, "{img context_friendly_match 18 17} " .. ScpArgMsg("RequestFriendlyFight"),
            string.format("REQUEST_FIGHT(\"%d\")", pcObj:GetHandleVal()))

        local mapprop = session.GetCurrentMapProp()
        local mapCls = GetClassByType("Map", mapprop.type)
        if IS_TOWN_MAP(mapCls) == true then
            ui.AddContextMenuItem(context, "{img context_personal_housing 18 17} " .. ScpArgMsg("PH_SEL_DLG_2"),

                string.format("REQUEST_PERSONAL_HOUSING_WARP(\"%s\")", pcObj:GetPCApc():GetAID()))
        end

        local familyname = pcObj:GetPCApc():GetFamilyName()
        local otherpcinfo = session.otherPC.GetByFamilyName(familyname)

        if session.world.IsIntegrateServer() == false then
            local strRequestLikeItScp = string.format("SEND_PC_INFO(%d)", handle)
            if session.likeit.AmILikeYou(familyname) == true then
                ui.AddContextMenuItem(context, "{img context_like 18 17} " .. ScpArgMsg("ReqUnlikeIt"),
                    strRequestLikeItScp)
            else
                ui.AddContextMenuItem(context, "{img context_like 18 17} " .. ScpArgMsg("ReqLikeIt"),
                    strRequestLikeItScp)
            end
        end

        ui.AddContextMenuItem(context, "{img context_automatic_suspicion 16 17} " .. ScpArgMsg("Report_AutoBot"),
            string.format("REPORT_AUTOBOT_MSGBOX(\"%s\")", pcObj:GetPCApc():GetFamilyName()))

        -- report guild emblem
        if pcObj:IsGuildExist() == true then
            ui.AddContextMenuItem(context,
                "{img context_inappropriate_emblem 17 17} " .. ScpArgMsg("Report_GuildEmblem"), string.format(
                    "REPORT_GUILDEMBLEM_MSGBOX(\"%s\")", pcObj:GetPCApc():GetFamilyName()))
        end

        -- 보호모드, 강제킥
        if 1 == session.IsGM() then
            ui.AddContextMenuItem(context, ScpArgMsg("GM_Order_Protected"),
                string.format("REQUEST_GM_ORDER_PROTECTED(\"%s\")", pcObj:GetPCApc():GetFamilyName()))
            ui.AddContextMenuItem(context, ScpArgMsg("GM_Order_Kick"),
                string.format("REQUEST_GM_ORDER_KICK(\"%s\")", pcObj:GetPCApc():GetFamilyName()))
        end

        if session.world.IsDungeon() and session.world.IsIntegrateIndunServer() == true then
            local aid = pcObj:GetPCApc():GetAID()
            local serverName = GetServerNameByGroupID(GetServerGroupID())
            local playerName = pcObj:GetPCApc():GetFamilyName()
            local scp =
                string.format("SHOW_INDUN_BADPLAYER_REPORT(\"%s\", \"%s\", \"%s\")", aid, serverName, playerName)
            ui.AddContextMenuItem(context, ScpArgMsg("IndunBadPlayerReport"), scp)
        end

        ui.AddContextMenuItem(context, ClMsg("Cancel"), "None")

        if g.settings.memberinfo == 1 then
            ui.AddContextMenuItem(context, "-----", "None")
            local strscp = string.format("PROPERTY_COMPARE(%d)", handle)
            ui.AddContextMenuItem(context, "{img context_look_into 18 17} " .. ScpArgMsg("Auto_SalPyeoBoKi"), strscp)
        end

        ui.OpenContextMenu(context)
        return context
    end
end

function MINI_ADDONS_POPUP_DUMMY(my_frame, my_msg)

    local handle, targetInfo = g.get_event_args(my_msg)

    local context = ui.CreateContextMenu("DPC_CONTEXT", targetInfo.name, 0, 0, 100, 100)

    local ownerHandle = info.GetOwner(handle)
    local myHandle = session.GetMyHandle()

    local strscp

    --  매입의뢰상점후 핼퍼 고용 메시지 제거	
    --	if ownerHandle == 0 then
    --		strscp = string.format("DUMMYPC_HIRE(%d)", handle)
    --		ui.AddContextMenuItem(context, ScpArgMsg("Auto_yongByeongKoyong"), strscp)
    --
    --	elseif ownerHandle == myHandle then
    --		strscp = string.format("dummyPC.Fire(%d)", handle)
    --		ui.AddContextMenuItem(context, ScpArgMsg("Auto_yongByeongHaeKo"), strscp)
    --	end

    if 1 == session.IsGM() then
        strscp = string.format("debug.TestE(%d)", handle)
        ui.AddContextMenuItem(context, ScpArgMsg("Auto_{@st42b}NodeBoKi{/}"), strscp)
        strscp = string.format("ui.Chat(\"//killmon %d\")", handle)
        ui.AddContextMenuItem(context, ScpArgMsg("Auto_JeKeo"), strscp)
        ui.AddContextMenuItem(context, ScpArgMsg("GM_Order_Kick"),
            string.format("REQUEST_ORDER_DUMMY_KICK(\"%s\")", handle))
    end

    if session.world.IsIntegrateServer() == false then
        strscp = string.format("barrackNormal.Visit(%d)", handle)
        ui.AddContextMenuItem(context, ScpArgMsg("VisitBarrack"), strscp)

    end

    ui.AddContextMenuItem(context, ScpArgMsg("Auto_DatKi"), "")

    if g.settings.memberinfo == 1 then
        ui.AddContextMenuItem(context, "-----", "None")

        strscp = string.format("PROPERTY_COMPARE(%d)", handle)
        ui.AddContextMenuItem(context, ScpArgMsg("Auto_SalPyeoBoKi"), strscp)
    end
    ui.OpenContextMenu(context)
end

function MINI_ADDONS_POPUP_FRIEND_COMPLETE_CTRLSET(my_frame, my_msg)

    local parent, ctrlset = g.get_event_args(my_msg)

    local aid = ctrlset:GetUserValue("AID")
    if aid == "" then
        return
    end

    local f = session.friends.GetFriendByAID(FRIEND_LIST_COMPLETE, aid)

    if f == nil then
        return
    end

    local info = f:GetInfo()
    local context = ui.CreateContextMenu("FRIEND_CONTEXT", "", 0, 0, 0, 0)

    if f.mapID ~= 0 then
        local partyinviteScp = string.format("PARTY_INVITE(\"%s\")", info:GetFamilyName())
        ui.AddContextMenuItem(context, ScpArgMsg("PARTY_INVITE"), partyinviteScp)

        -- 메모 추가
        local memoScp = string.format("FRIEND_SET_MEMO(\"%s\")", aid)
        ui.AddContextMenuItem(context, ScpArgMsg("FriendAddMemo"), memoScp)
    end

    local whisperScp = string.format("ui.WhisperTo('%s')", info:GetFamilyName())
    ui.AddContextMenuItem(context, ScpArgMsg("WHISPER"), whisperScp)

    local groupnamelist = {}
    local cnt = session.friends.GetFriendCount(FRIEND_LIST_COMPLETE)

    for i = 0, cnt - 1 do
        local allfriend = session.friends.GetFriendByIndex(FRIEND_LIST_COMPLETE, i)
        local groupname = allfriend:GetGroupName()

        if groupname ~= nil and groupname ~= "" and groupname ~= "None" and groupname ~= f:GetGroupName() and
            groupnamelist[groupname] == nil then

            table.insert(groupnamelist, groupname)

        end
    end

    local subcontext = ui.CreateContextMenu("SUB", "", 0, 0, 0, 0)
    -- 그룹 설정

    for k, customgroupname in pairs(groupnamelist) do
        local groupScp = string.format("FRIEND_SET_GROUPNAME('%d',\"%s\")", tonumber(aid), customgroupname)
        ui.AddContextMenuItem(subcontext, customgroupname, groupScp)
    end

    local nowgroupname = f:GetGroupName()
    if nowgroupname ~= nil and nowgroupname ~= "" and nowgroupname ~= "None" then
        local groupScp = string.format("FRIEND_SET_GROUPNAME('%s','%s')", aid, '')
        ui.AddContextMenuItem(subcontext, ScpArgMsg(FRIEND_GET_GROUPNAME(FRIEND_LIST_COMPLETE)), groupScp)
    end

    local groupScp = string.format("FRIEND_SET_GROUP(\"%s\")", aid)
    ui.AddContextMenuItem(subcontext, ScpArgMsg("FriendAddNewGroup"), groupScp)

    local groupScp = string.format("POPUP_FRIEND_GROUP_CONTEXTMENU(\"%s\")", aid)
    ui.AddContextMenuItem(context, ScpArgMsg("FriendAddGroup"), groupScp, nil, 0, 1, subcontext)

    local blockScp = string.format("friends.RequestBlock('%s')", info:GetFamilyName())
    ui.AddContextMenuItem(context, ScpArgMsg("FriendBlock"), blockScp)

    local deleteScp = string.format("FRIEND_EXEC_DELETE(\"%s\")", aid)
    ui.AddContextMenuItem(context, ScpArgMsg("FriendDelete"), deleteScp)

    ui.AddContextMenuItem(context, ScpArgMsg("Cancel"), "None")
    if g.settings.memberinfo == 1 then
        ui.AddContextMenuItem(context, "-----", "None")

        ui.AddContextMenuItem(context, ScpArgMsg('ShowInfomation'),
            string.format("ui.Chat('%s')", "/memberinfo " .. info:GetFamilyName()))
    end
    ui.OpenContextMenu(context)

end

function MINI_ADDONS_MEMBERINFO_ONCLICK(frame, ctrl, teamname, num)

    ui.Chat('/memberinfo ' .. teamname)
    local compare = ui.GetFrame("compare")
    compare:SetLayerLevel(102)
end

function MINI_ADDONS_WEEKLY_BOSS_RANK_UPDATE()

    local frame = ui.GetFrame("induninfo")
    local rankListBox = GET_CHILD_RECURSIVELY(frame, "rankListBox", "ui::CGroupBox")
    local cnt = session.weeklyboss.GetRankInfoListSize()

    if cnt == 0 then
        return
    end

    for i = 1, cnt do
        local ctrlSet = GET_CHILD_RECURSIVELY(rankListBox, "CTRLSET_" .. i)
        AUTO_CAST(ctrlSet)

        local name = GET_CHILD(ctrlSet, "attr_name_text", "ui::CRichText")

        local teamname = session.weeklyboss.GetRankInfoTeamName(i - 1)

        local functionName = "native_lang_WEEKLY_BOSS_RANK_UPDATE"
        if type(_G[functionName]) ~= "function" then

            local info_btn = rankListBox:CreateOrGetControl('button', "info_btn_" .. i, name:GetX(), (i - 1) * 73 + 50,
                50, 25)
            AUTO_CAST(info_btn)
            info_btn:SetText("{ol}Info")
            info_btn:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_MEMBERINFO_ONCLICK")

            info_btn:SetEventScriptArgString(ui.LBUTTONUP, teamname)
        end
    end

end

function mini_addons_toggle_quest_set(frame, ctrl)
    local chaseinfo = ui.GetFrame("chaseinfo")
    local openMark_quest = GET_CHILD_RECURSIVELY(chaseinfo, "openMark_quest")
    AUTO_CAST(openMark_quest)
    openMark_quest:SetEventScript(ui.RBUTTONDOWN, "MINI_ADDONS_QUESTINFO_TOGGLE")
    local notice =
        g.lang == "Japanese" and "{ol}Mini Addons{nl}右クリック: クエストの表示/非表示切替" or
            "{ol}Mini Addons{nl}Right-click: Show/hide quests"
    openMark_quest:SetTextTooltip(notice)
end

function mini_addons_toggle_sound_set(frame, ctrl)

    local minimap_outsidebutton = ui.GetFrame("minimap_outsidebutton")

    local BGM_PLAYER = GET_CHILD(minimap_outsidebutton, "BGM_PLAYER")
    AUTO_CAST(BGM_PLAYER)
    BGM_PLAYER:SetEventScript(ui.RBUTTONUP, "MINI_ADDONS_SOUND_TOGGLE")

    local tooltip = g.lang == "Japanese" and "{@st59}BGMプレイヤー{nl}右クリック: Sound Play/Mute{/}" or
                        g.lang == "kr" and "{@st59}BGM 플레이어{nl}우클릭: 소리 켜기/끄기{/}" or
                        "{@st59}BGM Player{nl}Right-click: Sound Play/Mute{/}"
    BGM_PLAYER:SetTextTooltip(tooltip)
end

function MINI_ADDONS_GAME_START_CHANNEL_LIST()

    MINI_ADDONS_POPUP_CHANNEL_LIST()
    local sysmenu = ui.GetFrame("sysmenu")
    if sysmenu then
        local system = GET_CHILD(sysmenu, "system")
        if system then
            if system:HaveUpdateScript("MINI_ADDONS_POPUP_CHANNEL_LIST") == false then
                system:RunUpdateScript("MINI_ADDONS_POPUP_CHANNEL_LIST", 2)
            end
        end
    end

end

function MINI_ADDONS_channelframe_move(frame)

    if g.settings.frame_X ~= frame:GetX() or g.settings.frame_Y ~= frame:GetY() then
        g.settings.frame_X = frame:GetX()
        g.settings.frame_Y = frame:GetY()
        MINI_ADDONS_SAVE_SETTINGS()
    end
end

function MINI_ADDONS_CH_FRAME_RESIZE(frame, btn, str, num)

    if g.settings.ch_frame_size == 40 then
        g.settings.ch_frame_size = 50
    else
        g.settings.ch_frame_size = 40
    end

    MINI_ADDONS_SAVE_SETTINGS()
    MINI_ADDONS_POPUP_CHANNEL_LIST()
end

function MINI_ADDONS_POPUP_CHANNEL_LIST()

    local zoneInsts = session.serverState.GetMap()
    if not zoneInsts then
        local frame = ui.GetFrame("mini_addons_channel")
        if frame then
            frame:ShowWindow(0)
        end
        g.zone_insts = false
        return 0
    else
        g.zone_insts = true
    end
    local mini_addons_channel = ui.GetFrame("mini_addons_channel")

    local frame = ui.CreateNewFrame("notice_on_pc", "mini_addons_channel", 10, 10, 10, 10)
    AUTO_CAST(frame)
    frame:RemoveAllChild()
    frame:SetSkinName('None')
    frame:SetTitleBarSkin("None")
    frame:EnableHittestFrame(1)
    frame:EnableMove(1)
    -- frame:SetLayerLevel(102)

    if not g.settings.frame_X then
        g.settings.frame_X = 1500
        g.settings.frame_Y = 385
        MINI_ADDONS_SAVE_SETTINGS()
    end

    if not g.settings.ch_frame_size then
        g.settings.ch_frame_size = 40
        MINI_ADDONS_SAVE_SETTINGS()
    end

    local map_frame = ui.GetFrame("map")
    local width = map_frame:GetWidth()
    local x = g.settings.frame_X
    local y = g.settings.frame_Y
    if g.settings.frame_X > 1920 and width <= 1920 then
        x = 1500
        y = 385
    end

    local size = g.settings.ch_frame_size

    frame:SetPos(x, y)
    frame:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_channelframe_move")
    frame:SetEventScript(ui.RBUTTONUP, "MINI_ADDONS_CH_FRAME_RESIZE")

    local title = frame:CreateOrGetControl("richtext", "title", 5, 0)
    title:SetText("{ol}{s12}channel info")

    if zoneInsts:NeedToCheckUpdate() == true then
        app.RequestChannelTraffics()
    end
    local cnt = zoneInsts:GetZoneInstCount()
    for i = 0, cnt - 1 do
        local zoneInst = zoneInsts:GetZoneInstByIndex(i)
        -- local str, gaugeString = GET_CHANNEL_STRING(zoneInst, true)

        local String = zoneInst.pcCount
        local btn = frame:CreateOrGetControl("button", "slot" .. i, i * size + 5, 15, size, size)
        AUTO_CAST(btn)
        btn:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_CH_CHANGE")

        local channelnum = session.loginInfo.GetChannel()
        if i == channelnum then
            btn:SetSkinName("test_pvp_btn")
        end
        btn:SetEventScriptArgString(ui.LBUTTONUP, i)
        if tonumber(String) >= 50 then
            local text = "{ol}{s12}ch" .. tonumber(i + 1) .. "{nl}{s16}{#FF0000}" .. String
            btn:SetText(text)
        elseif tonumber(String) < 20 then
            local text = "{ol}{s12}ch" .. tonumber(i + 1) .. "{nl}{s16}" .. String
            -- local text = "{ol}{s12}ch" .. tonumber(i + 1) .. "{nl}{s16}" .. 100
            btn:SetText(text)
        else
            local text = "{ol}{s12}ch" .. tonumber(i + 1) .. "{nl}{s16}{#FFCC33}" .. String
            btn:SetText(text)
        end
    end
    frame:Resize(cnt * size + 20, 60)
    frame:ShowWindow(1)

    return 1
end

function MINI_ADDONS_CH_CHANGE(frame, ctrl, argStr, argNum)
    local channelID = tonumber(argStr) -- 0が1chらしい
    RUN_GAMEEXIT_TIMER("Channel", channelID)
end

-- クポルポーションフレームの移動と非表示
function MINI_ADDONS_CUPOLE_PORTION_FRAME_SAVE(frame, ctrl, str, num)
    g.settings.cupole_portion.x = frame:GetX()
    g.settings.cupole_portion.y = frame:GetY()
    MINI_ADDONS_SAVE_SETTINGS()
end

function MINI_ADDONS_TOGGLE_CUPOLE_EXTERNAL_ADDON()
    local frame = ui.GetFrame("cupole_external_addon")
    if g.settings.cupole_portion.x == 0 and g.settings.cupole_portion.y == 0 then
        g.settings.cupole_portion.def_x = frame:GetX()
        g.settings.cupole_portion.def_y = frame:GetY()
        MINI_ADDONS_SAVE_SETTINGS()
    end

    if g.settings.cupole_portion.use == 1 then
        frame:ShowWindow(0)
    elseif frame:IsVisible() == 1 then
        if g.settings.cupole_portion.x == 0 and g.settings.cupole_portion.y == 0 then
            frame:SetPos(g.settings.cupole_portion.def_x, g.settings.cupole_portion.def_y)
        else
            frame:SetPos(g.settings.cupole_portion.x, g.settings.cupole_portion.y)
        end
        frame:ShowWindow(1)
    end
end

-- 週間ボスレの報酬受け取り
g.wbreward = nil
function MINI_ADDONS_WEEKLY_BOSS_REWARD()

    local week_num = WEEKLY_BOSS_RANK_WEEKNUM_NUMBER()
    if g.settings.reward_switch == 1 then
        week_num = WEEKLY_BOSS_RANK_WEEKNUM_NUMBER() - 1
    end

    if week_num ~= 0 then
        weekly_boss.RequestAcceptAbsoluteRewardAll(week_num)

        if g.wbreward ~= true then

            local indun_info = ui.GetFrame("induninfo")
            indun_info:Resize(0, 0)
            indun_info:ShowWindow(1)

            TOGGLE_INDUNINFO(indun_info, 3)
            local tab = GET_CHILD_RECURSIVELY(indun_info, "tab")
            AUTO_CAST(tab)
            tab:SelectTab(3)

            INDUNINFO_TAB_CHANGE(tab, tab)

            local season_tab = GET_CHILD_RECURSIVELY(indun_info, "season_tab")
            AUTO_CAST(season_tab)
            season_tab:SelectTab(1)
            --[[local x, y = GET_SCREEN_XY(season_tab)
            mouse.SetPos(x + 5, y - 50)]]
            g.index = 0

            indun_info:RunUpdateScript("MINI_ADDONS_WEEKLY_BOSS_RANK_REWARD", 1.5)
        end
    end
end

function MINI_ADDONS_WEEKLY_BOSS_RANK_REWARD(indun_info)
    local classtype_tab = GET_CHILD_RECURSIVELY(indun_info, "classtype_tab")
    AUTO_CAST(classtype_tab)
    local frame = ui.GetFrame("weeklyboss_reward")

    classtype_tab:SelectTab(g.index)

    if g.index <= 4 then

        WEEKLY_BOSS_DATA_REUQEST()
        classtype_tab:RunUpdateScript("MINI_ADDONS_WEEKLY_BOSS_RANK_GET_REWARD", 1.0)
        --[[local x, y = GET_SCREEN_XY(classtype_tab)
        mouse.SetPos(x - 120 + g.index * 60, y + 5)]]
        return 1
    else
        indun_info:ShowWindow(0)
        indun_info:Resize(1095, 610)
        indun_info:StopUpdateScript("MINI_ADDONS_WEEKLY_BOSS_RANK_REWARD")
        g.wbreward = true
        return 0
    end

end

function MINI_ADDONS_WEEKLY_BOSS_RANK_GET_REWARD(frame)

    local week_num = WEEKLY_BOSS_RANK_WEEKNUM_NUMBER()

    local myrank = session.weeklyboss.GetMyRankInfo(week_num)

    local indun_info = ui.GetFrame("induninfo")
    local classtype_tab = GET_CHILD_RECURSIVELY(indun_info, "classtype_tab")
    AUTO_CAST(classtype_tab)

    if myrank ~= 0 and myrank <= 100 then
        weekly_boss.RequestAccpetRankingReward(week_num, myrank)

        indun_info:ShowWindow(0)
        indun_info:Resize(1095, 610)
        indun_info:StopUpdateScript("MINI_ADDONS_WEEKLY_BOSS_RANK_REWARD")
        classtype_tab:StopUpdateScript("MINI_ADDONS_WEEKLY_BOSS_RANK_GET_REWARD")
        g.wbreward = true
        return
    elseif myrank ~= 0 and myrank > 100 then
        indun_info:ShowWindow(0)
        indun_info:Resize(1095, 610)
        indun_info:StopUpdateScript("MINI_ADDONS_WEEKLY_BOSS_RANK_REWARD")
        classtype_tab:StopUpdateScript("MINI_ADDONS_WEEKLY_BOSS_RANK_GET_REWARD")
        g.wbreward = true
        return

    end
    g.index = g.index + 1
end

-- ボタン右クリックでサウンドオフ
function MINI_ADDONS_SOUND_TOGGLE(frame, ctrl, str, num)

    local volume = config.GetTotalVolume()
    AUTO_CAST(ctrl)

    local frame = ui.GetFrame("systemoption")
    if g.settings.volume == nil or volume ~= 0 then
        g.settings.volume = volume
        MINI_ADDONS_SAVE_SETTINGS()
        config.SetTotalVolume(0)

        return
    end

    config.SetTotalVolume(g.settings.volume)
end

function MINI_ADDONS_baubas_call_switch(frame, ctrl, str, num)
    if g.settings.baubas_call.guild_notice == 0 then

        g.settings.baubas_call.guild_notice = 1

    else
        g.settings.baubas_call.guild_notice = 0
    end
    MINI_ADDONS_SAVE_SETTINGS()
    MINI_ADDONS_SETTING_FRAME_INIT(frame, ctrl, "true", num)
end

function MINI_ADDONS_WEEKLY_BOSS_REWARD_SWITCH(frame, ctrl, str, num)
    if g.settings.reward_switch == 1 then
        g.settings.reward_switch = 0
        ctrl:SetText(g.lang == "Japanese" and "{ol}今週分" or "{ol}this week")
    else
        g.settings.reward_switch = 1
        ctrl:SetText(g.lang == "Japanese" and "{ol}先週分" or "{ol}last week")
    end
    MINI_ADDONS_SAVE_SETTINGS()
    MINI_ADDONS_SETTING_FRAME_INIT(frame, ctrl, "true", num)
end

function MINI_ADDONS_FRAME_MOVE_RESERVE(frame, ctrl, str, num)

    frame:SetSkinName("chat_window")
    frame:Resize(40, 30)
    frame:EnableHittestFrame(1)
    frame:EnableMove(1)
    frame:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_FRAME_MOVE_SAVE")
end

function MINI_ADDONS_FRAME_MOVE_SAVE(frame, ctrl, str, num)
    local x = frame:GetX()
    local y = frame:GetY()
    g.settings["screen"] = {
        x = x,
        y = y
    }
    MINI_ADDONS_SAVE_SETTINGS()
    frame:StopUpdateScript("MINI_ADDONS_FRAME_MOVE_SETSKIN")
    frame:RunUpdateScript("MINI_ADDONS_FRAME_MOVE_SETSKIN", 5.0)

end

function MINI_ADDONS_FRAME_MOVE_SETSKIN(frame)
    frame:SetSkinName("None")
    frame:Resize(30, 30)
end

function MINI_ADDONS_NEW_FRAME_INIT()

    local newframe = ui.CreateNewFrame("notice_on_pc", "mini_addons_new", 0, 0, 0, 0)
    AUTO_CAST(newframe)
    newframe:SetSkinName('None')
    newframe:Resize(30, 30)

    if not g.settings["screen"] then
        g.settings["screen"] = {
            x = 1580,
            y = 305
        }
        MINI_ADDONS_SAVE_SETTINGS()
    end

    local map_frame = ui.GetFrame("map")
    local width = map_frame:GetWidth()

    local x = g.settings["screen"].x
    local y = g.settings["screen"].y

    if g.settings["screen"].x > 1920 and width <= 1920 then
        x = 1580
        y = 305
    end

    newframe:SetPos(x, y)
    newframe:SetTitleBarSkin("None")

    local btn = newframe:CreateOrGetControl('button', 'mini', 0, 0, 30, 30)
    AUTO_CAST(btn)
    btn:SetSkinName("None")
    btn:SetText("{img sysmenu_mac 30 30}")

    btn:SetEventScript(ui.LBUTTONDOWN, "MINI_ADDONS_SETTING_FRAME_INIT")
    btn:SetEventScriptArgString(ui.LBUTTONDOWN, "false")
    local text = g.lang == "Japanese" and
                     "{ol}左クリック: Mini Addons 設定{nl}右クリック: MUTE{nl}フレームの端を掴んで動かせます" or
                     "{ol}Left click: Mini Addons settings{nl}Right click: MUTE{nl}Grab the edge of the frame and move it"
    btn:SetTextTooltip(text)
    btn:SetGravity(ui.LEFT, ui.TOP)

    btn:SetEventScript(ui.MOUSEON, "MINI_ADDONS_FRAME_MOVE_RESERVE")
    btn:SetEventScript(ui.MOUSEOFF, "MINI_ADDONS_FRAME_MOVE_SAVE")

    newframe:ShowWindow(1)
    btn:SetEventScript(ui.RBUTTONUP, "MINI_ADDONS_SOUND_TOGGLE")
    g.addon:RegisterMsg("FPS_UPDATE", "MINI_ADDONS_FPS_UPDATE")

    local chaseinfo = ui.GetFrame("chaseinfo")
    local openMark_quest = GET_CHILD_RECURSIVELY(chaseinfo, "openMark_quest")
    AUTO_CAST(openMark_quest)
    openMark_quest:SetEventScript(ui.RBUTTONDOWN, "MINI_ADDONS_QUESTINFO_TOGGLE")
    local notice =
        g.lang == "Japanese" and "{ol}Mini Addons{nl}右クリック: クエストの表示/非表示切替" or
            "{ol}Mini Addons{nl}Right-click: Show/hide quests"
    openMark_quest:SetTextTooltip(notice)
end

function MINI_ADDONS_FRAME_CLOSE(frame)
    local frame = ui.GetFrame("mini_addons")
    frame:ShowWindow(0)
    MINI_ADDONS_subframe_close()
end

function MINI_ADDONS_MINIMIZED_CLOSE()

    local tp_button = ui.GetFrame("openingameshopbtn") -- TP受け取りボタン
    if tp_button and tp_button:IsVisible() == 1 then
        tp_button:ShowWindow(0)
    end

    local pilgrim_mode = ui.GetFrame("minimized_pilgrim_mode") -- ピルグリムボタン
    if pilgrim_mode and pilgrim_mode:IsVisible() == 1 then
        pilgrim_mode:ShowWindow(0)
    end

    local total_shop_button = ui.GetFrame("minimized_total_shop_button") -- マーケットとかのボタン
    if total_shop_button and total_shop_button:IsVisible() == 1 then
        total_shop_button:ShowWindow(0)
    end

    local total_party_button = ui.GetFrame("minimized_total_party_button") -- パーティー募集ボタン
    if total_party_button and total_party_button:IsVisible() == 1 then
        total_party_button:ShowWindow(0)
    end

    local tpshop_button = ui.GetFrame("minimized_tp_button") -- TPショップボタン
    if tpshop_button and tpshop_button:IsVisible() == 1 then
        tpshop_button:ShowWindow(0)
    end

    local total_bord = ui.GetFrame("minimized_total_board_button") -- 掲示板
    if total_bord and total_bord:IsVisible() == 1 then
        total_bord:ShowWindow(0)
    end

    local guidequest = ui.GetFrame("minimized_guidequest_button") -- なんか冒険者ガイドのやつ
    if guidequest and guidequest:IsVisible() == 1 then
        guidequest:ShowWindow(0)
    end

    local menu = ui.GetFrame("minimized_fullscreen_navigation_menu_button") -- menu
    if menu and menu:IsVisible() == 1 then
        menu:ShowWindow(0)
    end
end

function MINI_ADDONS_BGM_PLAY_LIST()
    local frame = ui.GetFrame("bgmplayer")
    if frame:GetUserValue("CTRLSET_NAME_SELECTED") == nil or frame:IsVisible() == 1 or
        frame:GetUserValue("CTRLSET_NAME_SELECTED") == "None" then
        return
    end
    local name_selected = frame:GetUserValue("CTRLSET_NAME_SELECTED")

    if not g.selected_name or g.selected_name ~= name_selected then
        -- ts(name_selected, g.selected_name)
        g.selected_name = name_selected

        g.settings.selectCtrlSetName = frame:GetUserValue("CTRLSET_NAME_SELECTED")
        MINI_ADDONS_SAVE_SETTINGS()
    end
    return
end

function MINIADDONS_BGMPLAYER_PLAY(frame, btn)

    local mode = tonumber(frame:GetUserValue("MODE_ALL_LIST"))
    local option = tonumber(frame:GetUserValue("MODE_FAVO_LIST"))
    local delayTime = 0
    local playRandom = tonumber(frame:GetUserConfig("PLAY_RANDOM"))

    local bgmMusicTitle_text = GET_CHILD_RECURSIVELY(frame, "bgm_music_title")
    if bgmMusicTitle_text ~= nil then
        local title = bgmMusicTitle_text:GetTextByKey("value")
        StopBgm(title, delayTime)
        BGMPLAYER_REDUCTION_SET_PLAYBTN(false)
        return
    end
end

function MINI_ADDONS_BGM_PLAY()
    BGMPLAYER_OPEN_UI(nil, nil)

    local frame = ui.GetFrame("bgmplayer")
    local topFrame = frame

    local playercontroler_gb = GET_CHILD_RECURSIVELY(frame, "playercontroler_gb")
    local playStart_btn = GET_CHILD_RECURSIVELY(frame, "playStart_btn")
    local btn = playStart_btn

    local mode = tonumber(topFrame:GetUserValue("MODE_ALL_LIST"))

    local option = tonumber(topFrame:GetUserValue("MODE_FAVO_LIST"))
    local delayTime = 0

    local playRandom = tonumber(topFrame:GetUserConfig("PLAY_RANDOM"))

    local bgmMusicTitle_text = GET_CHILD_RECURSIVELY(topFrame, "bgm_music_title")

    if bgmMusicTitle_text ~= nil then
        local title = bgmMusicTitle_text:GetTextByKey("value")

        if title ~= nil then
            local haltImageName = topFrame:GetUserConfig("PLAY_HALT_BTN_IMAGE_NAME")
            local startImageName = topFrame:GetUserConfig("PLAY_START_BTN_IMAGE_NAME")

            local selectCtrlSetName = g.settings.selectCtrlSetName

            local selectCtrlSet = GET_CHILD_RECURSIVELY(topFrame, selectCtrlSetName)
            local titleText = nil
            local parent = nil
            if selectCtrlSet ~= nil then
                parent = selectCtrlSet:GetParent()
                if parent ~= nil then
                    BGMPLAYER_SET_MUSIC_TITLE(topFrame, parent, selectCtrlSet)
                end
                titleText = GET_CHILD_RECURSIVELY(selectCtrlSet, "musictitle_text")
            end

            if titleText == nil then
                return
            end
            local musicTitle = titleText:GetTextByKey("value")
            if musicTitle ~= nil then
                musicTitle = StringSplit(musicTitle, '. ')

                if string.find(musicTitle[1], "{#ffc03a}") ~= nil then
                    local find_start, find_end = string.find(musicTitle[1], "{#ffc03a}")
                    if find_start ~= nil and find_end ~= nil then
                        musicTitle[1] = string.sub(musicTitle[1], find_end + 1, string.len(musicTitle[1]))
                    end
                end

                local index = tonumber(musicTitle[1])
                local bgmType = GET_BGMPLAYER_MODE(topFrame, mode, option)

                if bgmType == 1 then
                    SetBgmCurIndex(index, playRandom)
                elseif bgmType == 0 then
                    SetBgmCurFVIndex(index, playRandom)
                end
                -- end

                title = bgmMusicTitle_text:GetTextByKey("value")
                PlayBgm(title, selectCtrlSetName)
                BGMPLAYER_REDUCTION_SET_PLAYBTN(true)
                BGMPLAYER_REDUCTION_SET_TITLE(title)

                local totalTime = GetPlayBgmTotalTime()
                totalTime = totalTime / 1000
                local startTime = 0
                if GetBgmPauseTime() > 0 then
                    startTime = GetBgmPauseTime() / 1000
                    SetPauseTime(0)
                end
                BGMPLAYER_PLAYTIME_GAUGE(startTime, totalTime)
            end

            if btn:GetImageName() == startImageName then
                btn:SetImage(haltImageName)
                btn:SetTooltipArg(ScpArgMsg('BgmPlayer_HaltBtnToolTip'))
            else
                btn:SetImage(startImageName)
                btn:SetTooltipArg(ScpArgMsg('BgmPlayer_StartBtnToolTip'))
            end
            BGMPLAYER_CLOSE_UI()

        end
    end
end
-- 女神ガチャ ここから
g.first = 0
function MINI_ADDONS_FIELD_BOSS_WORLD_EVENT_END(frame)
    local frame = ui.GetFrame("godprotection")
    frame:ShowWindow(0)
    g.first = 0
    return
end

function MINI_ADDONS_GP_FULL_BET()
    local frame = ui.GetFrame("godprotection")
    local auto_gb = GET_CHILD_RECURSIVELY(frame, "auto_gb")
    local fbbtn = auto_gb:CreateOrGetControl("button", "fbbtn", 200, 30, 100, 40)
    AUTO_CAST(fbbtn)
    fbbtn:SetSkinName("None")
    fbbtn:SetText("{img login_test_button 95 35}")

    local fbtext = fbbtn:CreateOrGetControl("button", "fbtext", 0, 0, 100, 40)
    fbtext:SetSkinName("None")
    fbtext:SetText("{ol}  Full Bet")
    fbtext:SetAnimation("MouseOnAnim", "btn_mouseover")
    fbtext:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_GP_FULL_BET_START")
end

function MINI_ADDONS_GP_DO_OPEN()

    if g.first == 0 or g.first == nil then
        ReserveScript("GODPROTECTION_DO_OPEN()", 2.0)
        ReserveScript("MINI_ADDONS_GP_AUTOSTART()", 4.0)
    end
    return
end

function MINI_ADDONS_GP_FULL_BET_START(frame, ctrl, argStr, argNum)

    local frame = ui.GetFrame("godprotection")
    local multiple_count = 20
    local multiple_count_edit = GET_CHILD_RECURSIVELY(frame, 'multiple_count_edit')
    multiple_count_edit:SetText(multiple_count)

    local edit = GET_CHILD_RECURSIVELY(frame, "auto_edit")
    local count = 99999999
    local next_count = count - 1
    edit:SetText(next_count)

    local parent = GET_CHILD_RECURSIVELY(frame, "auto_gb")
    local auto_btn = GET_CHILD_RECURSIVELY(frame, "auto_btn")
    local auto_text = GET_CHILD_RECURSIVELY(frame, "auto_text")
    auto_text:ShowWindow(0)
    GODPROTECTION_AUTO_START_BTN_CLICK(parent, auto_btn)

end

function MINI_ADDONS_GP_AUTOSTART()
    g.first = 1
    local frame = ui.GetFrame("godprotection")
    if g.settings.auto_gacha_start == 1 then
        local multiple_count = 20
        local multiple_count_edit = GET_CHILD_RECURSIVELY(frame, 'multiple_count_edit')
        multiple_count_edit:SetText(multiple_count)

        local edit = GET_CHILD_RECURSIVELY(frame, "auto_edit")
        local count = 99999999
        local next_count = count - 1
        edit:SetText(next_count)

        local parent = GET_CHILD_RECURSIVELY(frame, "auto_gb")
        local auto_btn = GET_CHILD_RECURSIVELY(frame, "auto_btn")
        local auto_text = GET_CHILD_RECURSIVELY(frame, "auto_text")
        auto_text:ShowWindow(0)

        GODPROTECTION_AUTO_START_BTN_CLICK(parent, auto_btn)
    else
        return
    end

end

function MINI_ADDONS_GP_AUTOSTART_OPERATION(frame, ctrl)
    local text = ctrl:GetText()

    if text == "{ol}{#FFFFFF}OFF" then
        ctrl:SetText("{ol}{#FFFFFF}ON")
        ctrl:SetSkinName("test_red_button")
        g.settings.auto_gacha_start = 1
        ui.SysMsg("Automatically turn the Goddess Protection Gacha.")
        MINI_ADDONS_SAVE_SETTINGS()
        ReserveScript(string.format("APPS_TRY_LEAVE('%s')", "Barrack"), 1.0)

    else
        ctrl:SetText("{ol}{#FFFFFF}OFF")
        ctrl:SetSkinName("test_gray_button")
        g.settings.auto_gacha_start = 0
        ui.SysMsg("Turned off the automatic Goddess Protection gacha function.")
        MINI_ADDONS_SAVE_SETTINGS()
        ReserveScript(string.format("APPS_TRY_LEAVE('%s')", "Barrack"), 1.0)

    end
end
-- 女神ガチャ ここまで
function MINI_ADDONS_COMMON_SKILL_ENCHANT_MAT_SET(frame, msg)
    local itemObj = acutil.getEventArgs(msg)
    local frame = ui.GetFrame('common_skill_enchant')
    ReserveScript("MINI_ADDONS_COMMON_SKILL_ENCHANT_ADD_MAT()", 0.2)
    return
end

function MINI_ADDONS_COMMON_SKILL_ENCHANT_ADD_MAT(parent, ctrl)
    local frame = ui.GetFrame('common_skill_enchant')
    if frame == nil then
        return
    end

    local invItemList = session.GetInvItemList()
    local bottom_bg = GET_CHILD_RECURSIVELY(frame, "bottom_Bg")
    local cnt = bottom_bg:GetChildCount()
    local set_ready_count = 0
    for i = 1, cnt - 1 do
        local ctrlSet = bottom_bg:GetChildByIndex(i)

        local mat_slot = GET_CHILD_RECURSIVELY(ctrlSet, "mat_slot")
        local plus = GET_CHILD_RECURSIVELY(ctrlSet, "plus")
        plus:ShowWindow(1)
        local mat_name = GET_CHILD_RECURSIVELY(ctrlSet, "mat_name")
        local cnt_in_my_bag = GET_CHILD_RECURSIVELY(ctrlSet, "cnt_in_my_bag")

        local val_1 = GET_NOT_COMMAED_NUMBER(mat_name:GetTextByKey('value2'))
        local val_2 = GET_NOT_COMMAED_NUMBER(cnt_in_my_bag:GetTextByKey('value'))
        val_1 = tonumber(val_1)
        val_2 = tonumber(val_2)
        if val_1 <= val_2 then
            local icon = mat_slot:GetIcon()
            icon:SetColorTone('FFFFFFFF')
            plus:ShowWindow(0)
            set_ready_count = set_ready_count + 1
        else
            local msg = string.format("<%s> %s", mat_name:GetTextByKey('value'), ClMsg("NotEnoughMaterial"))
            ui.SysMsg(msg)
        end
    end

    if set_ready_count == (cnt - 1) then
        frame:SetUserValue("IS_READY", "TRUE")
        GET_CHILD_RECURSIVELY(frame, "do_enchant"):SetEnable(1)
    else
        frame:SetUserValue("IS_READY", "FALSE")
    end
end

function MINI_ADDONS_SUCCESS_COMMON_SKILL_ENCHANT(frame, msg)
    local msg, arg_str, arg_num = acutil.getEventArgs(msg)
    local frame = ui.GetFrame('common_skill_enchant')
    ReserveScript("MINI_ADDONS_COMMON_SKILL_ENCHANT_ADD_MAT()", 0.9)
    return
end

-- 傭兵団コイン、女神コイン、王国再建団コインを取得時、自動で使用
function MINI_ADDONS_INV_ICON_USE()

    local frame = ui.GetFrame('godprotection')
    if frame:IsVisible() == 1 then
        return
    end

    local invItemList = session.GetInvItemList()
    local guidList = invItemList:GetGuidList()
    local cnt = guidList:Count()

    for i = 0, cnt - 1 do
        local guid = guidList:Get(i)
        local invItem = invItemList:GetItemByGuid(guid)
        local itemobj = GetIES(invItem:GetObject())

        for _, coinID in ipairs(COIN_ITEM) do
            if tostring(itemobj.ClassID) == tostring(coinID) then

                ReserveScript(string.format("item.UseByGUID(%d)", invItem:GetIESID()), 1.5)

                break -- 使ったらループを抜ける
            end
        end
    end
end

function MINI_ADDONS_SET_PARTYINFO_ITEM(frame, msg)

    local frame = ui.GetFrame('partyinfo')

    local list = session.party.GetPartyMemberList(PARTY_NORMAL)
    local count = list:Count() - 1
    frame:SetEventScript(ui.RBUTTONUP, "MINI_ADDONS_PARTYINFO_RESIZE")
    if g.partyinfo == 1 then
        frame:Resize(80, count * 100 + 60)
        frame:SetLayerLevel(0)

    elseif g.partyinfo == 0 then
        frame:Resize(560, count * 100 + 60)
        frame:SetLayerLevel(50)

    end

    return

end

function MINI_ADDONS_PARTYINFO_RESIZE(frame, ctrl, argStr, argNum)

    local list = session.party.GetPartyMemberList(PARTY_NORMAL)
    local count = list:Count() - 1

    if frame:GetWidth() == 80 then
        frame:Resize(560, count * 100 + 60)
        g.partyinfo = 0
    else
        frame:Resize(80, count * 100 + 60)
        g.partyinfo = 1
    end
end

function MINI_ADDONS_CHECK_DREAMY_ABYSS()
    local slogutis = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 690).PlayPerResetType)
    local upinis = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 687).PlayPerResetType)

    local langcode = option.GetCurrentCountry()

    if slogutis ~= upinis then
        if langcode == "Japanese" then
            if slogutis ~= 1 then
                imcSound.PlayMusicQueueLocal('colonywar_win')
                _G.imcAddOn.BroadMsg('NOTICE_Dm_Global_Shout', "{st47}スローガティスまだやってへんで？",
                    5.0)
                NICO_CHAT("{@st55_a}スローガティスまだやってへんで？")
            elseif upinis ~= 1 then
                imcSound.PlayMusicQueueLocal('colonywar_win')
                _G.imcAddOn.BroadMsg('NOTICE_Dm_Global_Shout', "{st47}ウピニスまだやってへんで？", 5.0)
                NICO_CHAT("{@st55_a}ウピニスまだやってへんで？")
            end
        else
            if slogutis ~= 1 then
                imcSound.PlayMusicQueueLocal('colonywar_win')
                _G.imcAddOn.BroadMsg('NOTICE_Dm_Global_Shout', "{st47}I haven't done Abyss yet, okay?", 5.0)
            elseif upinis ~= 1 then
                imcSound.PlayMusicQueueLocal('colonywar_win')
                _G.imcAddOn.BroadMsg('NOTICE_Dm_Global_Shout', "{st47}I haven't done Dreamy yet, okay?", 5.0)
            end
        end
    end

    local neringa = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 709).PlayPerResetType)
    local golem = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 712).PlayPerResetType)

    if neringa ~= golem then
        if langcode == "Japanese" then
            if neringa ~= 1 then
                imcSound.PlayMusicQueueLocal('colonywar_win')
                _G.imcAddOn.BroadMsg('NOTICE_Dm_Global_Shout', "{st47}ネリンガまだやってへんで？", 5.0)
                NICO_CHAT("{@st55_a}ネリンガまだやってへんで？")
            elseif golem ~= 1 then
                imcSound.PlayMusicQueueLocal('colonywar_win')
                _G.imcAddOn.BroadMsg('NOTICE_Dm_Global_Shout', "{st47}ゴーレムまだやってへんで？", 5.0)
                NICO_CHAT("{@st55_a}ゴーレムまだやってへんで？")
            end
        else
            if neringa ~= 1 then
                imcSound.PlayMusicQueueLocal('colonywar_win')
                _G.imcAddOn.BroadMsg('NOTICE_Dm_Global_Shout', "{st47}I haven't done Neringa yet, okay?", 5.0)
            elseif golem ~= 1 then
                imcSound.PlayMusicQueueLocal('colonywar_win')
                _G.imcAddOn.BroadMsg('NOTICE_Dm_Global_Shout', "{st47}I haven't done Golem yet, okay?", 5.0)
            end
        end
    end

end

local invenTitleName = nil
local g_invenTypeStrList = {"All", "Equip", "Consume", "Recipe", "Card", "Etc", "Gem", "Premium", "Housing", "Pharmacy",
                            "Quest"}
local _invenSortTypeOption = {}

function MINI_ADDONS_INVENTORY_TOTAL_LIST_GET(frame, setpos, isIgnorelifticon, invenTypeStr)
    if g.settings.icor_status_search == 0 then
        base["INVENTORY_TOTAL_LIST_GET"](frame, setpos, isIgnorelifticon, invenTypeStr)
    else
        MINI_ADDONS_INVENTORY_TOTAL_LIST_GET_(frame, setpos, isIgnorelifticon, invenTypeStr)
    end
end

function MINI_ADDONS_INVENTORY_TOTAL_LIST_GET_(frame, setpos, isIgnorelifticon, invenTypeStr)

    local frame = ui.GetFrame("inventory")
    if frame == nil then
        return
    end

    local liftIcon = ui.GetLiftIcon()
    if nil == isIgnorelifticon then
        isIgnorelifticon = "NO"
    end

    if isIgnorelifticon ~= "NO" and liftIcon ~= nil then
        return
    end

    local mySession = session.GetMySession()
    local cid = mySession:GetCID()
    local sortType = _invenSortTypeOption[cid]
    session.BuildInvItemSortedList()
    local sortedList = session.GetInvItemSortedList()
    local invItemCount = sortedList:size()

    if sortType == nil then
        sortType = 0
    end

    local blinkcolor = frame:GetUserConfig("TREE_SEARCH_BLINK_COLOR")
    local group = GET_CHILD_RECURSIVELY(frame, 'inventoryGbox', 'ui::CGroupBox')

    for typeNo = 1, #g_invenTypeStrList do
        if invenTypeStr == nil or invenTypeStr == g_invenTypeStrList[typeNo] or typeNo == 1 then
            local tree_box = GET_CHILD_RECURSIVELY(group, 'treeGbox_' .. g_invenTypeStrList[typeNo], 'ui::CGroupBox')
            local tree = GET_CHILD_RECURSIVELY(tree_box, 'inventree_' .. g_invenTypeStrList[typeNo], 'ui::CTreeControl')

            local groupfontname = frame:GetUserConfig("TREE_GROUP_FONT")
            local tabwidth = frame:GetUserConfig("TREE_TAB_WIDTH")

            tree:Clear()
            tree:EnableDrawFrame(false)
            tree:SetFitToChild(true, 60)
            tree:SetFontName(groupfontname)
            tree:SetTabWidth(tabwidth)

            local slotSetNameListCnt = ui.inventory.GetInvenSlotSetNameCount()
            for i = 1, slotSetNameListCnt do
                local slotSetName = ui.inventory.GetInvenSlotSetNameByIndex(i - 1)
                ui.inventory.RemoveInvenSlotSetName(slotSetName)
            end

            local groupNameListCnt = ui.inventory.GetInvenGroupNameCount()
            for i = 1, groupNameListCnt do
                local groupName = ui.inventory.GetInvenGroupNameByIndex(i - 1)
                ui.inventory.RemoveInvenGroupName(groupName)
            end

            local customFunc = nil
            local scriptName = frame:GetUserValue("CUSTOM_ICON_SCP")
            local scriptArg = nil
            if scriptName ~= nil then
                customFunc = _G[scriptName]
                local getArgFunc = _G[frame:GetUserValue("CUSTOM_ICON_ARG_SCP")]
                if getArgFunc ~= nil then
                    scriptArg = getArgFunc()
                end
            end
        end
    end

    local baseidclslist, baseidcnt = GetClassList("inven_baseid")
    local searchGbox = group:GetChild('searchGbox')
    local searchSkin = GET_CHILD_RECURSIVELY(searchGbox, "searchSkin", 'ui::CGroupBox')
    local edit = GET_CHILD_RECURSIVELY(searchSkin, "ItemSearch", "ui::CEditControl")
    local cap = edit:GetText()
    if cap ~= "" then
        local slotSetNameListCnt = ui.inventory.GetInvenSlotSetNameCount()
        for i = 1, slotSetNameListCnt do
            local getSlotSetName = ui.inventory.GetInvenSlotSetNameByIndex(i - 1)
            local slotset = GET_CHILD_RECURSIVELY(tree, getSlotSetName, 'ui::CSlotSet')
            slotset:RemoveAllChild()
            slotset:SetUserValue("SLOT_ITEM_COUNT", 0)
        end
    end

    local invItemList = {}
    local index_count = 1
    for i = 0, invItemCount - 1 do
        local invItem = sortedList:at(i)
        if invItem ~= nil then
            invItemList[index_count] = invItem
            index_count = index_count + 1
        end
    end

    -- 1 등급순 / 2 무게순 / 3 이름순 / 4 소지량순
    if sortType == 1 then
        table.sort(invItemList, INVENTORY_SORT_BY_GRADE)
    elseif sortType == 2 then
        table.sort(invItemList, INVENTORY_SORT_BY_WEIGHT)
    elseif sortType == 3 then
        table.sort(invItemList, INVENTORY_SORT_BY_NAME)
    elseif sortType == 4 then
        table.sort(invItemList, INVENTORY_SORT_BY_COUNT)
    else
        table.sort(invItemList, INVENTORY_SORT_BY_NAME)
    end

    if invenTitleName == nil then
        invenTitleName = {}
        for i = 1, baseidcnt do
            local baseidcls = GetClassByIndexFromList(baseidclslist, i - 1)
            local tempTitle = baseidcls.ClassName
            if baseidcls.MergedTreeTitle ~= "NO" then
                tempTitle = baseidcls.MergedTreeTitle
            end

            if table.find(invenTitleName, tempTitle) == 0 then
                invenTitleName[#invenTitleName + 1] = tempTitle
            end
        end
    end

    local cls_inv_index = {}
    local i_cnt = 0
    for i = 1, #invenTitleName do
        local category = invenTitleName[i]
        for j = 1, #invItemList do
            local invItem = invItemList[j]
            if invItem ~= nil then
                local itemCls = GetIES(invItem:GetObject())
                if itemCls.MarketCategory ~= "None" then
                    local baseidcls = nil
                    if cls_inv_index[invItem.invIndex] == nil then
                        baseidcls = GET_BASEID_CLS_BY_INVINDEX(invItem.invIndex)
                        cls_inv_index[invItem.invIndex] = baseidcls
                    else
                        baseidcls = cls_inv_index[invItem.invIndex]
                    end

                    local titleName = baseidcls.ClassName
                    if baseidcls.MergedTreeTitle ~= "NO" then
                        titleName = baseidcls.MergedTreeTitle
                    end

                    if category == titleName then
                        local typeStr = GET_INVENTORY_TREEGROUP(baseidcls)
                        if itemCls ~= nil then
                            local makeSlot = true
                            if cap ~= "" then
                                -- 인벤토리 안에 있는 아이템을 찾기 위한 로직
                                local itemname = string.lower(dictionary.ReplaceDicIDInCompStr(itemCls.Name))
                                -- 접두어도 포함시켜 검색해야되기 때문에, 접두를 찾아서 있으면 붙여주는 작업
                                local prefixClassName = TryGetProp(itemCls, "LegendPrefix")
                                if prefixClassName ~= nil and prefixClassName ~= "None" then
                                    local prefixCls = GetClass('LegendSetItem', prefixClassName)
                                    local prefixName = string.lower(dictionary.ReplaceDicIDInCompStr(prefixCls.Name))
                                    itemname = prefixName .. " " .. itemname
                                end

                                local tempcap = string.lower(cap)
                                local a = string.find(itemname, tempcap)

                                if a == nil then
                                    makeSlot = false

                                    if TryGetProp(itemCls, 'GroupName', 'None') == 'Earring' then
                                        local max_option_count =
                                            shared_item_earring.get_max_special_option_count(TryGetProp(itemCls,
                                                'UseLv', 1))
                                        for ii = 1, max_option_count do
                                            local option_name = 'EarringSpecialOption_' .. ii
                                            local job = TryGetProp(itemCls, option_name, 'None')
                                            if job ~= 'None' then
                                                local job_cls = GetClass('Job', job)
                                                if job_cls ~= nil then
                                                    itemname = string.lower(
                                                        dictionary.ReplaceDicIDInCompStr(job_cls.Name))
                                                    a = string.find(itemname, tempcap)
                                                    if a ~= nil then
                                                        makeSlot = true
                                                        break
                                                    end
                                                end
                                            end
                                        end
                                    elseif TryGetProp(itemCls, 'GroupName', 'None') == 'Icor' then

                                        local max_option = 5
                                        for iii = 1, max_option do
                                            local item = GetIES(invItem:GetObject())
                                            local option_name = 'RandomOption_' .. iii
                                            local option = TryGetProp(item, option_name, 'None')
                                            if option ~= "None" or option ~= nil then
                                                itemname = string.lower(dictionary.ReplaceDicIDInCompStr(ClMsg(option)))
                                            end
                                            a = string.find(itemname, tempcap)
                                            if a ~= nil then
                                                makeSlot = true
                                                break
                                            end
                                        end
                                    end

                                end
                            end

                            local viewOptionCheck = 1
                            if typeStr == "Equip" then
                                viewOptionCheck = CHECK_INVENTORY_OPTION_EQUIP(itemCls)
                            elseif typeStr == "Card" then
                                viewOptionCheck = CHECK_INVENTORY_OPTION_CARD(itemCls)
                            elseif typeStr == "Etc" then
                                viewOptionCheck = CHECK_INVENTORY_OPTION_ETC(itemCls)
                            elseif typeStr == "Gem" then
                                viewOptionCheck = CHECK_INVENTORY_OPTION_GEM(itemCls)
                            end

                            if makeSlot == true and viewOptionCheck == 1 then
                                if invItem.count > 0 and baseidcls.ClassName ~= 'Unused' then -- Unused로 설정된 것은 안보임
                                    if invenTypeStr == nil or invenTypeStr == typeStr then
                                        local tree_box = GET_CHILD_RECURSIVELY(group, 'treeGbox_' .. typeStr,
                                            'ui::CGroupBox')
                                        local tree = GET_CHILD_RECURSIVELY(tree_box, 'inventree_' .. typeStr,
                                            'ui::CTreeControl')
                                        INSERT_ITEM_TO_TREE(frame, tree, invItem, itemCls, baseidcls)
                                    end
                                    -- Request #95788 / 퀘스트 항목은 모두 보기 탭에서 보이지 않도록 함
                                    if typeStr ~= "Quest" then
                                        local tree_box_all =
                                            GET_CHILD_RECURSIVELY(group, 'treeGbox_All', 'ui::CGroupBox')
                                        local tree_all = GET_CHILD_RECURSIVELY(tree_box_all, 'inventree_All',
                                            'ui::CTreeControl')
                                        INSERT_ITEM_TO_TREE(frame, tree_all, invItem, itemCls, baseidcls)
                                    end
                                end
                            else
                                --[[if customFunc ~= nil then
                                    local slot = slotSet:GetSlotByIndex(i)
                                    if slot ~= nil then
                                        customFunc(slot, scriptArg, invItem, nil)
                                    end
                                end]]

                                -- 인벤토리 옵션 적용 중이면 빈 tree 만들어 "필터링 옵션 적용 중"이라는 문구 표시해주기
                                local isOptionApplied = CHECK_INVENTORY_OPTION_APPLIED(baseidcls)
                                if isOptionApplied == 1 and cap == "" then -- 검색 중에는 조건에 맞는 아이템 없으면 tree 안 만듬
                                    if invenTypeStr == nil or invenTypeStr == typeStr then
                                        local tree_box = GET_CHILD_RECURSIVELY(group, 'treeGbox_' .. typeStr,
                                            'ui::CGroupBox')
                                        local tree = GET_CHILD_RECURSIVELY(tree_box, 'inventree_' .. typeStr,
                                            'ui::CTreeControl')
                                        EMPTY_TREE_INVENTORY_OPTION_TEXT(baseidcls, tree) -- 해당 아이템이 속한 탭
                                    end

                                    -- Request #95788 / 퀘스트 항목은 모두 보기 탭에서 보이지 않도록 함
                                    if typeStr ~= "Quest" then
                                        local tree_box_all =
                                            GET_CHILD_RECURSIVELY(group, 'treeGbox_All', 'ui::CGroupBox')
                                        local tree_all = GET_CHILD_RECURSIVELY(tree_box_all, 'inventree_All',
                                            'ui::CTreeControl')
                                        EMPTY_TREE_INVENTORY_OPTION_TEXT(baseidcls, tree_all) -- ALL 탭 
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    for typeNo = 1, #g_invenTypeStrList do
        local tree_box = GET_CHILD_RECURSIVELY(group, 'treeGbox_' .. g_invenTypeStrList[typeNo], 'ui::CGroupBox')
        local tree = GET_CHILD_RECURSIVELY(tree_box, 'inventree_' .. g_invenTypeStrList[typeNo], 'ui::CTreeControl')

        -- 아이템 없는 빈 슬롯은 숨겨라
        local slotSetNameListCnt = ui.inventory.GetInvenSlotSetNameCount()
        for i = 1, slotSetNameListCnt do
            local getSlotSetName = ui.inventory.GetInvenSlotSetNameByIndex(i - 1)
            local slotset = GET_CHILD_RECURSIVELY(tree, getSlotSetName, 'ui::CSlotSet')
            if slotset ~= nil then
                ui.InventoryHideEmptySlotBySlotSet(slotset)
            end
        end

        ADD_GROUP_BOTTOM_MARGIN(frame, tree)
        tree:OpenNodeAll()
        tree:SetEventScript(ui.LBUTTONDOWN, "INVENTORY_TREE_OPENOPTION_CHANGE")
        INVENTORY_CATEGORY_OPENCHECK(frame, tree)

        -- 검색결과 스크롤 세팅은 여기서 하자. 트리 업데이트 후에 위치가 고정된 다음에.
        for i = 1, slotSetNameListCnt do
            local getSlotSetName = ui.inventory.GetInvenSlotSetNameByIndex(i - 1)
            -- slotset = GET_CHILD_RECURSIVELY(tree, getSlotSetName, 'ui::CSlotSet')

            local slotsetnode = tree:FindByValue(getSlotSetName)
            if setpos == 'setpos' then
                local savedPos = frame:GetUserValue("INVENTORY_CUR_SCROLL_POS")
                if savedPos == 'None' then
                    savedPos = 0
                end
                tree_box:SetScrollPos(tonumber(savedPos))
            end
        end
    end

end

function MINI_ADDONS_CHARBASE_RELIC()

    if HEADSUPDISPLAY_OPTION.relic_equip == 0 then
        return
    end

    local frame = ui.GetFrame("charbaseinfo1_my")
    local pcRelicGauge = frame:CreateOrGetControl("gauge", "pcRelicGauge", -1, 54, 104, 11)
    AUTO_CAST(pcRelicGauge)
    local pcRelic_text = pcRelicGauge:CreateOrGetControl("richtext", "pcRelic_text", 0, 0, 50, 0)
    AUTO_CAST(pcRelic_text)

    pcRelicGauge:SetGravity(ui.CENTER_HORZ, ui.TOP)
    pcRelicGauge:EnableHitTest(0)
    pcRelicGauge:SetSkinName("pcinfo_gauge_rp_relic")
    pcRelicGauge:StopTimeProcess()

    local pc = GetMyPCObject()
    local cur_rp, max_rp = shared_item_relic.get_rp(pc)

    pcRelic_text:SetGravity(ui.CENTER_HORZ, ui.CENTER_VERT)
    pcRelic_text:SetText("{ol}{s12}" .. cur_rp)
    pcRelicGauge:SetPoint(cur_rp / 10, max_rp / 10)

end

function MINI_ADDONS_CONFIG_ENABLE_AUTO_CASTING(frame, msg)

    local parent, ctrl = acutil.getEventArgs(msg)
    local enable = ctrl:IsChecked()
    g.settings.auto_casting[g.cid] = enable
    MINI_ADDONS_SAVE_SETTINGS()
end

function MINI_ADDONS_SET_ENABLE_AUTO_CASTING_3SEC()
    local systemoption_frame = ui.GetFrame("systemoption")
    local Check_EnableAutoCasting =
        GET_CHILD_RECURSIVELY(systemoption_frame, "Check_EnableAutoCasting", "ui::CCheckBox")

    Check_EnableAutoCasting:SetCheck(tostring(g.settings.auto_casting[g.cid] or 1))
    config.SetEnableAutoCasting(g.settings.auto_casting[g.cid] or 1)
    config.SaveConfig()
end

-- ファミリーネームからログインネームへ変換
function MINI_ADDONS_PCNAME_REPLACE(frame, msg)
    -- local family_name = GETMYFAMILYNAME()
    local frame = ui.GetFrame("headsupdisplay")
    local name_text = GET_CHILD_RECURSIVELY(frame, "name_text")
    local login_name = session.GetMySession():GetPCApc():GetName()
    if name_text:GetText() ~= "{@st41}" .. tostring(login_name) then
        name_text:SetText("{@st41}" .. tostring(login_name))
    else
        return
    end
end

-- ダイアログ制御系
function MINI_ADDONS_DIALOG_CHANGE_SELECT(frame, msg, argStr, argNum)
    local frame = ui.GetFrame("dialogselect")
    local dframe = ui.GetFrame("dialog")

    -- 倉庫
    if argStr == tostring("WAREHOUSE_DLG") or argStr == tostring("ORSHA_WAREHOUSE_DLG") or argStr ==
        tostring("WAREHOUSE_FEDIMIAN_DLG") and msg == ("DIALOG_CHANGE_SELECT") then

        session.SetSelectDlgList()
        ui.OpenFrame("dialogselect")
        DialogSelect_index = 2
        local btn2 = GET_CHILD_RECURSIVELY(frame, 'item2Btn')
        local x, y = GET_SCREEN_XY(btn2)
        mouse.SetPos(x + 190, y)
        return
    end
    -- 住居クポル
    if argStr == "NPC_PERSONAL_HOUSING_MANAGER_DLG_2" then

        session.SetSelectDlgList()
        ui.OpenFrame("dialogselect")
        control.DialogItemSelect(1)

    elseif string.find(argStr, "PERSONAL_HOUSING_POINT_CHECK_MSG_1") ~= nil then

        session.SetSelectDlgList()
        ui.OpenFrame("dialogselect")
        control.DialogItemSelect(1)

    elseif string.find(argStr, "PH_POINT_SHOP_DLG_SEL_1") ~= nil then
        session.SetSelectDlgList()
        ui.CloseFrame("dialog")
        ui.OpenFrame("dialogselect")
        DialogSelect_index = 3
        local btn = GET_CHILD_RECURSIVELY(frame, 'item3Btn')
        local x, y = GET_SCREEN_XY(btn)
        mouse.SetPos(x + 190, y)
        return
    end

    local pc = GetMyPCObject()
    local curMap = GetZoneName(pc)
    if argStr == "Goddess_Raid_Rozethemiserable_Start_Npc_Dlg" or argStr == "Goddess_Raid_Spreader_Start_Npc_DLG1" or
        argStr == "Goddess_Raid_Jellyzele_Start_Npc_DLG1" or argStr == "EP14_Raid_Delmore_NPC_DLG1" or argStr ==
        "Goddess_Raid_DespairIsland_Start_Npc_Dlg" then

        session.SetSelectDlgList()
        ui.CloseFrame("dialog")
        ui.OpenFrame("dialogselect")
        DialogSelect_index = 2
        local btn = GET_CHILD_RECURSIVELY(frame, 'item2Btn')
        local x, y = GET_SCREEN_XY(btn)
        mouse.SetPos(x + 190, y)
        return

    end
    if (argStr == "Legend_Raid_Giltine_ENTER_MSG" and curMap == "raid_dcapital_108") then

        session.SetSelectDlgList()
        ui.CloseFrame("dialog")
        ui.OpenFrame("dialogselect")
        DialogSelect_index = 2
        local btn = GET_CHILD_RECURSIVELY(frame, 'item2Btn')
        local x, y = GET_SCREEN_XY(btn)
        mouse.SetPos(x + 190, y)
        return

    end
end
-- quest_arrow_r_btn
function MINI_ADDONS_QUESTINFO_TOGGLE(frame, ctrl, str, num)
    local frame = ui.GetFrame("questinfoset_2")
    local width = frame:GetWidth()
    if width > 0 then
        MINI_ADDONS_QUESTINFO_HIDE_RESERVE()
        g.settings.quest_hide = 1
        -- ctrl:SetImage("btn_plus")
        ctrl:SetImage("quest_arrow_l_btn")
        -- ctrl:SetEventScript(ui.LBUTTONDOWN, "MINI_ADDONS_QUESTINFO_TOGGLE")
    else
        MINI_ADDONS_QUESTINFO_SHOW()
        g.settings.quest_hide = 0
        -- ctrl:SetImage("btn_minus")
        ctrl:SetImage("quest_arrow_r_btn")
    end
    MINI_ADDONS_SAVE_SETTINGS()
end

function MINI_ADDONS_QUESTINFO_SHOW()
    local frame = ui.GetFrame("questinfoset_2")
    frame:Resize(400, 500)
    frame:ShowWindow(1)
    local chaseinfoframe = ui.GetFrame("chaseinfo")
    local name_quest = GET_CHILD_RECURSIVELY(chaseinfoframe, "name_quest")
    name_quest:Resize(220, 30)
    name_quest:ShowWindow(1)
    local name_achieve = GET_CHILD_RECURSIVELY(chaseinfoframe, "name_achieve")
    name_achieve:Resize(220, 30)
    name_achieve:ShowWindow(1)
    local openMark_quest = GET_CHILD_RECURSIVELY(chaseinfoframe, "openMark_quest")
    openMark_quest:ShowWindow(1)

    -- openMark_quest:SetImage("btn_minus")
    openMark_quest:SetImage("quest_arrow_r_btn")
    openMark_quest:SetColorTone("FFFFFFFF")
    --[[local chaseinfo = ui.GetFrame("chaseinfo")
    local index = chaseinfo:GetUserIValue("LastOpen")
    ts(index)]]
    frame:StopUpdateScript("MINI_ADDONS_QUESTINFO_HIDE")

end

function MINI_ADDONS_QUESTINFO_HIDE_RESERVE()
    local frame = ui.GetFrame("questinfoset_2")
    frame:Resize(0, 0)
    -- frame:SetUserValue("COLOR", "FFFF0000")
    frame:RunUpdateScript("MINI_ADDONS_QUESTINFO_HIDE", 0.1)

end

function MINI_ADDONS_QUESTINFO_HIDE(frame)
    if frame:IsVisible() == 1 then
        frame:ShowWindow(0)
        local chaseinfoframe = ui.GetFrame("chaseinfo")
        local name_quest = GET_CHILD_RECURSIVELY(chaseinfoframe, "name_quest")
        name_quest:Resize(0, 0)
        name_quest:ShowWindow(0)
        local name_achieve = GET_CHILD_RECURSIVELY(chaseinfoframe, "name_achieve")
        name_achieve:Resize(0, 0)
        name_achieve:ShowWindow(0)
        local openMark_quest = GET_CHILD_RECURSIVELY(chaseinfoframe, "openMark_quest")
        openMark_quest:ShowWindow(1)
        -- openMark_quest:SetImage("btn_plus")
        openMark_quest:SetImage("quest_arrow_l_btn")
        -- local color = frame:GetUserValue("COLOR")
        -- openMark_quest:SetColorTone(color)
        -- frame:SetUserValue("COLOR", "")
        return 1
    else
        local chaseinfoframe = ui.GetFrame("chaseinfo")
        local openMark_quest = GET_CHILD_RECURSIVELY(chaseinfoframe, "openMark_quest")
        openMark_quest:ShowWindow(1)
        return 1
    end

end

function MINI_ADDONS_INDUNENTER_AUTOMATCH_TYPE()
    local frame = ui.GetFrame("indunenter")
    frame:SetLayerLevel(97)
end

function MINI_ADDONS_SHOW_INDUNENTER_DIALOG(indunType)
    local frame = ui.GetFrame('indunenter')
    local indunType = frame:GetUserValue('INDUN_TYPE', indunType)

    local indunType_table = {665, 670, 675, 678, 681, 628, 687, 690, 697, 709, 712, 718, 724, 727}

    for i = 1, #indunType_table do
        if tostring(indunType_table[i]) == tostring(indunType) then
            local equipItemList = session.GetEquipItemList()
            local cnt = equipItemList:Count()
            local count = 0

            for i = 0, cnt - 1 do
                local equipItem = equipItemList:GetEquipItemByIndex(i)
                local spotName = item.GetEquipSpotName(equipItem.equipSpot)
                local iesid = tostring(equipItem:GetIESID())
                local langcode = option.GetCurrentCountry()

                if tostring(spotName) == "SEAL" and tonumber(iesid) == 0 then
                    if langcode == "Japanese" then
                        _G.imcAddOn.BroadMsg('NOTICE_Dm_Global_Shout',
                            "{st55_a}{#FF8C00}エンブレム装備してないけど{nl}やれるんか？", 3.0)
                        -- ui.SysMsg("{#FF8C00}エンブレム装備忘れてない?")
                    else
                        ui.SysMsg("{#FF8C00}Did you forget to equip an Emblem?")
                    end
                    break

                elseif tostring(spotName) == "ARK" and tonumber(iesid) == 0 then
                    if langcode == "Japanese" then
                        _G.imcAddOn.BroadMsg('NOTICE_Dm_Global_Shout',
                            "{st55_a}{#FF8C00}アーク装備してないけど{nl}やれるんか?", 3.0)
                        -- ui.SysMsg("{st55_a}{#FF8C00}アーク装備忘れてない?")
                    else
                        ui.SysMsg("{#FF8C00}Did you forget to equip an Ark?")
                    end
                    break

                end
            end

        end

    end

end

function MINI_ADDONS_BOSS_EFFECT_EDIT(frame, ctrl)
    local boss_effect = tonumber(ctrl:GetText())
    if boss_effect <= 100 and boss_effect >= 1 then
        local num = math.floor(boss_effect / 0.392156862745 + 0.5)

        g.settings.boss_effect_value = num
        MINI_ADDONS_SAVE_SETTINGS()
        config.SetBossMonsterEffectTransparency(num)
        ui.SysMsg("boss effect changed.")
    else
        ui.SysMsg("Not a valid value.")
        return
    end

end

function MINI_ADDONS_BOSS_EFFECT_SETTING()

    local frame = ui.GetFrame("systemoption")
    local slide = GET_CHILD_RECURSIVELY(frame, "effect_transparency_boss_monster_value", "ui::CSlideBar")

    if g.settings.boss_effect_value ~= nil then
        config.SetBossMonsterEffectTransparency(g.settings.boss_effect_value)
        slide:SetLevel(g.settings.boss_effect_value)
    else
        local boss_effect = config.GetBossMonsterEffectTransparency()
        config.SetBossMonsterEffectTransparency(boss_effect)

    end

end

function MINI_ADDONS_MY_EFFECT_EDIT(frame, ctrl)
    local my_effect = tonumber(ctrl:GetText())
    if my_effect <= 100 and my_effect >= 1 then
        local num = math.floor(my_effect / 0.392156862745 + 0.5)

        g.settings.my_effect_value = num
        MINI_ADDONS_SAVE_SETTINGS()
        config.SetMyEffectTransparency(num)
        ui.SysMsg("my effect changed.")
    else
        ui.SysMsg("Not a valid value.")
        return
    end

end

function MINI_ADDONS_MY_EFFECT_SETTING()

    local frame = ui.GetFrame("systemoption")
    local slide = GET_CHILD_RECURSIVELY(frame, "effect_transparency_my_value", "ui::CSlideBar")

    if g.settings.my_effect_value ~= nil then
        config.SetMyEffectTransparency(g.settings.my_effect_value)
        slide:SetLevel(g.settings.my_effect_value)
    else
        local my_effect = config.GetMyEffectTransparency()
        config.SetMyEffectTransparency(my_effect)
    end

end

function MINI_ADDONS_OTHER_EFFECT_EDIT(frame, ctrl)
    local other_effect = tonumber(ctrl:GetText())
    if other_effect <= 100 and other_effect >= 1 then
        local num = math.floor(other_effect / 0.392156862745 + 0.5)

        g.settings.other_effect_value = num
        MINI_ADDONS_SAVE_SETTINGS()
        config.SetOtherEffectTransparency(num)
        ui.SysMsg("other effect changed.")
    else
        ui.SysMsg("Not a valid value.")
        return
    end

end

function MINI_ADDONS_OTHER_EFFECT_SETTING()

    local frame = ui.GetFrame("systemoption")
    local slide = GET_CHILD_RECURSIVELY(frame, "effect_transparency_other_value", "ui::CSlideBar")
    if g.settings.other_effect_value ~= nil then
        config.SetOtherEffectTransparency(g.settings.other_effect_value)
        slide:SetLevel(g.settings.other_effect_value)
    else
        local other_effect = config.GetOtherEffectTransparency()
        config.SetOtherEffectTransparency(other_effect)
    end
end

function MINI_ADDONS_MARKET_SELL_UPDATE_REG_SLOT_ITEM(frame, msg)
    local frame = ui.GetFrame('market_sell')
    local edit_count = GET_CHILD_RECURSIVELY(frame, "edit_count")
    AUTO_CAST(edit_count)

    local slot = GET_CHILD_RECURSIVELY(frame, "slot_item")
    local icon = slot:GetIcon()
    local count = 0
    if icon ~= nil then
        local info = icon:GetInfo()
        local iesid = info:GetIESID()
        local invItem = session.GetInvItemByGuid(iesid)

        if invItem ~= nil then
            count = tonumber(invItem.count)
        end
    end
    edit_count:SetText(count)
end

function MINI_ADDONS_RESTART_CONTENTS_ON_HERE()
    if not g.mouse then
        local frame = ui.GetFrame("restart_contents")

        local ItemBtn = GET_CHILD_RECURSIVELY(frame, "btn_restart_" .. 1)
        local itemWidth = ItemBtn:GetWidth()

        local x, y = GET_SCREEN_XY(ItemBtn, itemWidth / 2.5)
        mouse.SetPos(x, y)
        DialogSelect_index = 1
        g.mouse = true
    else
        return
    end
end

function MINI_ADDONS_CHAT_TEXT_LINKCHAR_FONTSET(frame, msg)

    if msg == nil then
        return
    end
    if g.settings.chat_system == 1 then
        if string.find(msg, "StartBlackMarketBetween") then
            return
        end
    end
    local fontStyle = frame:GetUserConfig("TEXTCHAT_FONTSTYLE_LINK")
    local resultStr = string.gsub(msg, "({#%x+}){img", fontStyle .. "{img")
    -- 모션 이모티콘 채팅창에서는 이미지 이모티콘으로 출력
    if config.GetXMLConfig("EnableChatFrameMotionEmoticon") == 0 and string.find(resultStr, "{spine motion_") ~= nil then
        resultStr = string.gsub(msg, "{spine motion_", "{img ")
    end
    return resultStr
end
---
function MINI_ADDONS_NOTICE_ON_MSG(frame, origin_func_name)

    local frame, msg, str, num = g.get_event_args(origin_func_name)

    if g.settings.chat_system == 1 then
        if string.find(str, "StartBlackMarketBetween") then
            return
        end
    end
    g.FUNCS["NOTICE_ON_MSG"](frame, msg, str, num)
end

function MINI_ADDONS_CHAT_SYSTEM(my_frame, my_msg, ...)

    local msg, color = ...
    if msg then

        if g.settings.chat_system == 1 then
            if msg == "&lt완벽함&gt 효과가 사라졌습니다." or msg ==
                "&lt완벽함&gt 효과가 발동되었습니다." or msg == "@dicID_^*$ETC_20220830_069434$*^" or msg ==
                "@dicID_^*$ETC_20220830_069435$*^" or msg == "[__m2util] is loaded" or msg == "[adjustlayer] is loaded" or
                msg == "[extendcharinfo] is loaded" or msg == "[ICC]Attempt to CC." or
                string.find(msg, "StartBlackMarketBetween") or string.find(msg, "[__m2util] is loaded") or
                string.find(msg, "[adjustlayer] is loaded") or string.find(msg, "MapMate") then
                return
            end

        end
    end
    g.FUNCS["CHAT_SYSTEM"](msg, "FFFF00")
    -- session.ui.GetChatMsg():AddSystemMsg(msg, true, 'System', "FFFF00")
end

function MINI_ADDONS_UPDATE_CURRENT_CHANNEL_TRAFFIC(frame)
    local curchannel = frame:GetChild("curchannel")
    local channel = session.loginInfo.GetChannel()
    local zoneInst = session.serverState.GetZoneInst(channel)

    local function setChannelText(str, stateString)
        local spacing = (g.lang == "Japanese") and "                      " or "                                  "
        curchannel:SetTextByKey("value", str .. spacing .. stateString)
    end

    if g.settings.channel_display == 1 and zoneInst ~= nil then
        local str, stateString
        if GET_PRIVATE_CHANNEL_ACTIVE_STATE() == false then
            str, stateString = GET_CHANNEL_STRING(zoneInst)
        else
            local suffix = GET_SUFFIX_PRIVATE_CHANNEL(zoneInst.mapID, zoneInst.channel + 1)
            str, stateString = GET_CHANNEL_STRING(zoneInst, suffix)
        end
        setChannelText(str, stateString)
    else
        curchannel:SetTextByKey("value", "")
    end
end

function MINI_ADDONS_UPDATESETTINGS(frame)
    if g.settings.reword_x ~= frame:GetX() or g.settings.reword_y ~= frame:GetY() then
        g.settings.reword_x = frame:GetX()
        g.settings.reword_y = frame:GetY()
        MINI_ADDONS_SAVE_SETTINGS()
    end
end

-- レイドレコードのサイズ、位置変更
function MINI_ADDONS_RAID_RECORD_INIT(frame, msg)

    local frame = ui.GetFrame("raid_record")
    frame:SetSkinName("shadow_box")
    frame:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_UPDATESETTINGS")
    frame:SetLayerLevel(5)
    frame:SetTitleBarSkin("None")
    frame:ShowTitleBar(0)
    frame:Resize(550, 260)
    frame:SetOffset(g.settings.reword_x, g.settings.reword_y)

    local widgetList = {{
        name = "myInfo",
        font = "white_16_ol"
    }, {
        name = "friendInfo1",
        font = "white_16_ol"
    }, {
        name = "friendInfo2",
        font = "white_16_ol"
    }, {
        name = "friendInfo3",
        font = "white_16_ol"
    }}

    for i, widgetData in ipairs(widgetList) do
        local widget = GET_CHILD_RECURSIVELY(frame, widgetData.name)
        local name = GET_CHILD_RECURSIVELY(widget, "name")
        local time = GET_CHILD_RECURSIVELY(widget, "time")
        name:SetFontName(widgetData.font)
        time:SetFontName(widgetData.font)
    end
end

-- レイドレコードの2度呼ばれるバグ修正。正確に測れる
local json_imc = require("json_imc")
function mini_addons__REQ_PLAYER_CONTENTS_RECORD(frame, msg, arg_str, state)
    if g.raid_msg[msg] then
        return
    end
    g.raid_msg[msg] = true
    frame:SetUserValue(addon_name_lower .. "arg_str", arg_str)
    frame:RunUpdateScript("mini_addons_REQ_PLAYER_CONTENTS_RECORD_", 0.3)
end

function mini_addons_REQ_PLAYER_CONTENTS_RECORD_(frame)
    local arg_str = frame:GetUserValue(addon_name_lower .. "arg_str")
    local raid_record = ui.GetFrame("raid_record")
    if not raid_record then
        return
    end
    local token = StringSplit(arg_str, ';')
    if not token or not token[1] or not token[2] or not token[3] then
        return
    end
    local name = token[1]
    local before_str = token[2]
    local record_str = token[3]
    local function TimeToMilliseconds(time_str)
        if type(time_str) ~= "string" then
            return nil
        end
        local min_str, sec_str, ms_str = time_str:match("(%d+):(%d+)%.(%d+)")
        if min_str and sec_str and ms_str then
            local ms_num = tonumber(ms_str)
            if not ms_num then
                return nil
            end
            if string.len(ms_str) == 1 then
                ms_num = ms_num * 100
            elseif string.len(ms_str) == 2 then
                ms_num = ms_num * 10
            end
            local minutes = tonumber(min_str)
            local seconds = tonumber(sec_str)
            return (minutes * 60 * 1000) + (seconds * 1000) + ms_num
        end
        return nil
    end
    local before_ms = TimeToMilliseconds(before_str)
    local record_ms = TimeToMilliseconds(record_str)
    if not before_ms or not record_ms then
        return
    end
    local record_time = GET_CHILD_RECURSIVELY(raid_record, 'textRecord');
    local myInfo = GET_CHILD_RECURSIVELY(raid_record, 'myInfo')
    local time = GET_CHILD_RECURSIVELY(myInfo, 'time');
    record_time:SetTextByKey('value', record_str)
    CHAT_SYSTEM(before_ms .. ":" .. record_ms)
    if before_ms >= record_ms then
        local textNewRecord = GET_CHILD_RECURSIVELY(raid_record, 'textNewRecord')
        textNewRecord:ShowWindow(1)
        local effect_name = raid_record:GetUserConfig("DO_NEWRECORD_EFFECT");
        local effect_scale = tonumber(raid_record:GetUserConfig("NEWRECORD_EFFECT_SCALE"));
        local effect_duration = tonumber(raid_record:GetUserConfig("NEWRECORD_EFFECT_DURATION"));
        local effect_bg = GET_CHILD_RECURSIVELY(raid_record, "success_effect_bg");
        if effect_bg ~= nil then
            effect_bg:PlayUIEffect(effect_name, effect_scale, "DoNewRecordEffect");
            raid_record:RunUpdateScript("_RAID_NEWRECORD_EFFECT", effect_duration);
        end
        local text = string.format("%s,%s,%s,%s,%s", "best", "befor", before_str, "record", record_str)
        time:SetTextByKey('value', before_str .. "→" .. record_str)
    else
        local text = string.format("%s,%s,%s,%s,%s", "not best", "befor", before_str, "record", record_str)
        time:SetTextByKey('value', before_str)
    end

    GetPlayerRecord('callback_get_player_current_record', name)
    return 0
end
-- レイドレコードのサイズ、位置変更 ここまで

function MINI_ADDONS_INDUNENTER_REQ_UNDERSTAFF_ENTER_ALLOW(parent, ctrl)
    local topFrame = parent:GetTopParentFrame()
    local useCount = tonumber(topFrame:GetUserValue("multipleCount"))
    if useCount > 0 then
        local multipleItemList = GET_INDUN_MULTIPLE_ITEM_LIST()
        for i = 1, #multipleItemList do
            local itemName = multipleItemList[i]
            local invItem = session.GetInvItemByName(itemName)
            if invItem ~= nil and invItem.isLockState then
                ui.SysMsg(ClMsg("MaterialItemIsLock"))
                return
            end
        end
    end

    local withMatchMode = topFrame:GetUserValue('WITHMATCH_MODE')
    if topFrame:GetUserValue('AUTOMATCH_MODE') ~= 'YES' and withMatchMode == 'NO' then
        ui.SysMsg(ScpArgMsg('EnableWhenAutoMatching'))
        return
    end

    local indunType = topFrame:GetUserIValue('INDUN_TYPE')
    local indunCls = GetClassByType('Indun', indunType)
    local UnderstaffEnterAllowMinMember = TryGetProp(indunCls, 'UnderstaffEnterAllowMinMember')
    if UnderstaffEnterAllowMinMember == nil then
        return
    end

    -- ??티??과 ??동매칭??경우 처리
    local yesScpStr = '_INDUNENTER_REQ_UNDERSTAFF_ENTER_ALLOW()'
    local clientMsg = ScpArgMsg('ReallyAllowUnderstaffMatchingWith{MIN_MEMBER}?', 'MIN_MEMBER',
        UnderstaffEnterAllowMinMember)
    if INDUNENTER_CHECK_UNDERSTAFF_MODE_WITH_PARTY(topFrame) == true then
        clientMsg = ClMsg('CancelUnderstaffMatching')
    end

    if withMatchMode == 'YES' then
        yesScpStr = 'ReqUnderstaffEnterAllowModeWithParty(' .. indunType .. ')'
    end

    if g.settings.under_staff == 1 then
        if withMatchMode == 'NO' then
            _INDUNENTER_REQ_UNDERSTAFF_ENTER_ALLOW()
            return
        end
    end
    ui.MsgBox(clientMsg, yesScpStr, "None")
end

function MINI_ADDONS_EARTHTOWERSHOP_CHANGECOUNT_NUM_CHANGE(ctrlset, change)
    if g.settings.coin_count ~= 1 then
        base["EARTHTOWERSHOP_CHANGECOUNT_NUM_CHANGE"](ctrlset, change)
        return
    end
    local recipecls = GetClass('ItemTradeShop', ctrlset:GetName())

    local edit_itemcount = GET_CHILD_RECURSIVELY(ctrlset, "itemcount")
    local countText = tonumber(edit_itemcount:GetText())
    if countText == nil then
        countText = 0
    end
    countText = countText + change

    local target_acc = TryGetProp(recipecls, 'TargetAccountProperty', 'None')
    local max_target_acc = TryGetProp(recipecls, 'MaxTargetAccountProperty', 99999)
    if target_acc ~= 'None' then
        local now = TryGetProp(GetMyAccountObj(), target_acc, 0)
        if now + countText > max_target_acc then
            countText = countText - 1
        end
    end

    if countText < 0 then
        countText = 0
    elseif countText > 99999 then
        countText = 99999
    end

    if recipecls.NeedProperty ~= 'None' then
        local sObj = GetSessionObject(GetMyPCObject(), "ssn_shop")
        local sCount = TryGetProp(sObj, recipecls.NeedProperty)
        if sCount < countText then
            countText = sCount
        end
    end
    if recipecls.AccountNeedProperty ~= 'None' then
        local aObj = GetMyAccountObj()
        local sCount = TryGetProp(aObj, recipecls.AccountNeedProperty)

        local frame = ui.GetFrame("earthtowershop")
        local shopType = frame:GetUserValue("SHOP_TYPE")
        if IS_OVERBUY_ITEM(shopType, recipecls, aObj) == true then
            sCount = countText
            if IS_EXCEED_OVERBUY_COUNT(shopType, aObj, recipecls, 1) == true then
                sCount = 0
            end
            countText = TryGetProp(recipecls, 'MaxOverBuyCount', 100) -
                            TryGetProp(aObj, TryGetProp(recipecls, 'OverBuyProperty', 'None'), 0)
        end

        if sCount < countText then
            countText = sCount
        end
    end
    edit_itemcount:SetText(countText)
    return countText
end

-- アドオンメニューボタン
local norisan_menu_addons = string.format("../%s", "addons")
local norisan_menu_addons_mkfile = string.format("../%s/mkdir.txt", "addons")
local norisan_menu_settings = string.format("../addons/%s/settings.json", "norisan_menu")
local norisan_menu_folder = string.format("../addons/%s", "norisan_menu")
local norisan_menu_mkfile = string.format("../addons/%s/mkdir.txt", "norisan_menu")
_G["norisan"] = _G["norisan"] or {}
_G["norisan"]["MENU"] = _G["norisan"]["MENU"] or {}

local json = require("json")

local function norisan_menu_create_folder_file()

    local addons_file = io.open(norisan_menu_addons_mkfile, "r")
    if not addons_file then
        os.execute('mkdir "' .. norisan_menu_addons .. '"')
        addons_file = io.open(norisan_menu_addons_mkfile, "w")
        if addons_file then
            addons_file:write("created")
            addons_file:close()
        end
    else
        addons_file:close()
    end

    local file = io.open(norisan_menu_mkfile, "r")
    if not file then
        os.execute('mkdir "' .. norisan_menu_folder .. '"')
        file = io.open(norisan_menu_mkfile, "w")
        if file then
            file:write("created")
            file:close()
        end
    else
        file:close()
    end
end
norisan_menu_create_folder_file()

local function norisan_menu_save_json(path, tbl)

    local data_to_save = {
        x = tbl.x,
        y = tbl.y,
        move = tbl.move,
        open = tbl.open,
        layer = tbl.layer
    }
    local file = io.open(path, "w")
    if file then
        local str = json.encode(data_to_save)
        file:write(str)
        file:close()
    end
end

local function norisan_menu_load_json(path)

    local file = io.open(path, "r")
    if file then
        local content = file:read("*all")
        file:close()
        if content and content ~= "" then
            local decoded, err = json.decode(content)
            if decoded then
                return decoded
            end
        end
    end
    return nil
end

function _G.norisan_menu_move_drag(frame, ctrl)
    if not frame then
        return
    end

    local current_frame_y = frame:GetY()
    local current_frame_h = frame:GetHeight()
    local base_button_h = 40

    local y_to_save = current_frame_y

    if current_frame_h > base_button_h and (_G["norisan"]["MENU"].open == 1) then
        local items_area_h_calculated = current_frame_h - base_button_h
        y_to_save = current_frame_y + items_area_h_calculated

    end

    _G["norisan"]["MENU"].x = frame:GetX()
    _G["norisan"]["MENU"].y = y_to_save

    norisan_menu_save_json(norisan_menu_settings, _G["norisan"]["MENU"])
end

function _G.norisan_menu_setting_frame_ctrl(setting, ctrl)
    local ctrl_name = ctrl:GetName()

    local frame_name = _G["norisan"]["MENU"].frame_name
    local frame = ui.GetFrame(frame_name)

    if ctrl_name == "layer_edit" then
        local layer = tonumber(ctrl:GetText())
        if layer then
            _G["norisan"]["MENU"].layer = layer
            frame:SetLayerLevel(layer)
            norisan_menu_save_json(norisan_menu_settings, _G["norisan"]["MENU"])

            local notice = _G["norisan"]["MENU"].lang == "Japanese" and "{ol}レイヤーを変更" or
                               "{ol}Change Layer"
            ui.SysMsg(notice)
            _G.norisan_menu_create_frame()
            setting:ShowWindow(0)
            return
        end
    end

    if ctrl_name == "def_setting" then

        _G["norisan"]["MENU"].x = 1190
        _G["norisan"]["MENU"].y = 30
        _G["norisan"]["MENU"].move = true
        _G["norisan"]["MENU"].open = 0
        _G["norisan"]["MENU"].layer = 79
        norisan_menu_save_json(norisan_menu_settings, _G["norisan"]["MENU"])
        _G.norisan_menu_create_frame()
        setting:ShowWindow(0)
        return
    end
    if ctrl_name == "close" then
        setting:ShowWindow(0)
        return
    end

    local is_check = ctrl:IsChecked()
    if ctrl_name == "move_toggle" then
        if is_check == 1 then
            _G["norisan"]["MENU"].move = false
        else
            _G["norisan"]["MENU"].move = true
        end
        frame:EnableMove(_G["norisan"]["MENU"].move == true and 1 or 0)
        norisan_menu_save_json(norisan_menu_settings, _G["norisan"]["MENU"])
        return
    elseif ctrl_name == "open_toggle" then
        _G["norisan"]["MENU"].open = is_check
        norisan_menu_save_json(norisan_menu_settings, _G["norisan"]["MENU"])
        _G.norisan_menu_create_frame()
        return
    end

end

function _G.norisan_menu_setting_frame(frame, ctrl)
    local setting = ui.CreateNewFrame("chat_memberlist", "norisan_menu_setting", 0, 0, 0, 0)
    AUTO_CAST(setting)

    setting:SetTitleBarSkin("None")
    setting:SetSkinName("chat_window")
    setting:Resize(260, 135)
    setting:SetLayerLevel(999)
    setting:EnableHitTest(1)
    setting:EnableMove(1)

    setting:SetPos(frame:GetX() + 200, frame:GetY())
    setting:ShowWindow(1)

    local close = setting:CreateOrGetControl("button", "close", 0, 0, 30, 30)
    AUTO_CAST(close)
    close:SetImage("testclose_button")
    close:SetGravity(ui.RIGHT, ui.TOP)
    close:SetEventScript(ui.LBUTTONUP, "norisan_menu_setting_frame_ctrl")

    local def_setting = setting:CreateOrGetControl("button", "def_setting", 10, 5, 150, 30)
    AUTO_CAST(def_setting)
    local notice = _G["norisan"]["MENU"].lang == "Japanese" and "{ol}デフォルトに戻す" or "{ol}Reset to default"
    def_setting:SetText(notice)
    def_setting:SetEventScript(ui.LBUTTONUP, "norisan_menu_setting_frame_ctrl")

    local move_toggle = setting:CreateOrGetControl('checkbox', "move_toggle", 10, 35, 30, 30)
    AUTO_CAST(move_toggle)
    move_toggle:SetCheck(_G["norisan"]["MENU"].move == true and 0 or 1)
    move_toggle:SetEventScript(ui.LBUTTONDOWN, 'norisan_menu_setting_frame_ctrl')
    local notice = _G["norisan"]["MENU"].lang == "Japanese" and "{ol}チェックするとフレーム固定" or
                       "{ol}Check to fix frame"
    move_toggle:SetText(notice)

    local open_toggle = setting:CreateOrGetControl('checkbox', "open_toggle", 10, 70, 30, 30)
    AUTO_CAST(open_toggle)
    open_toggle:SetCheck(_G["norisan"]["MENU"].open)
    open_toggle:SetEventScript(ui.LBUTTONDOWN, 'norisan_menu_setting_frame_ctrl')
    local notice = _G["norisan"]["MENU"].lang == "Japanese" and "{ol}チェックすると上開き" or
                       "{ol}Check to open upward"
    open_toggle:SetText(notice)

    local layer_text = setting:CreateOrGetControl('richtext', 'layer_text', 10, 105, 50, 20)
    AUTO_CAST(layer_text)
    local notice = _G["norisan"]["MENU"].lang == "Japanese" and "{ol}レイヤー設定" or "{ol}Set Layer"
    layer_text:SetText(notice)

    local layer_edit = setting:CreateOrGetControl('edit', 'layer_edit', 130, 105, 70, 20)
    AUTO_CAST(layer_edit)
    layer_edit:SetFontName("white_16_ol")
    layer_edit:SetTextAlign("center", "center")
    layer_edit:SetText(_G["norisan"]["MENU"].layer or 79)
    layer_edit:SetEventScript(ui.ENTERKEY, "norisan_menu_setting_frame_ctrl")
end

function _G.norisan_menu_toggle_items_display(frame, ctrl, open_dir)

    local open_up = (open_dir == 1)

    local menu_src = _G["norisan"]["MENU"]
    local max_cols = 5
    local item_w = 35
    local item_h = 35
    local y_off_down = 35

    local items = {}
    if menu_src then
        for key, data in pairs(menu_src) do
            if type(data) == "table" then
                if key ~= "x" and key ~= "y" and key ~= "open" and key ~= "move" and data.name and data.func and
                    ((data.image and data.image ~= "") or (data.icon and data.icon ~= "")) then
                    table.insert(items, {
                        key = key,
                        data = data
                    })
                end
            end
        end
    end

    local num_items = #items

    local num_rows = math.ceil(num_items / max_cols)

    local items_h = num_rows * item_h
    local frame_h_new = 40 + items_h
    local frame_y_new = _G["norisan"]["MENU"].y or 30

    if open_up then
        frame_y_new = frame_y_new - items_h
    end

    local frame_w_new
    if num_rows == 1 then
        frame_w_new = math.max(40, num_items * item_w)
    else
        frame_w_new = math.max(40, max_cols * item_w)
    end

    frame:SetPos(frame:GetX(), frame_y_new)
    frame:Resize(frame_w_new, frame_h_new)

    for idx, entry in ipairs(items) do
        local item_sidx = idx - 1
        local data = entry.data
        local key = entry.key
        local col = item_sidx % max_cols
        local x = col * item_w
        local y = 0

        if open_up then

            local logical_row_from_bottom = math.floor(item_sidx / max_cols)

            y = (frame_h_new - 40) - ((logical_row_from_bottom + 1) * item_h)
        else

            local row_down = math.floor(item_sidx / max_cols)
            y = y_off_down + (row_down * item_h)
        end

        local ctrl_name = "menu_item_" .. key
        local item_elem

        if data.image and data.image ~= "" then
            item_elem = frame:CreateOrGetControl('button', ctrl_name, x, y, item_w, item_h)
            AUTO_CAST(item_elem)
            item_elem:SetSkinName("None")
            item_elem:SetText(data.image)
        else
            item_elem = frame:CreateOrGetControl('picture', ctrl_name, x, y, item_w, item_h)
            AUTO_CAST(item_elem)
            item_elem:SetImage(data.icon)
            item_elem:SetEnableStretch(1)
        end

        if item_elem then
            item_elem:SetTextTooltip("{ol}" .. data.name)
            item_elem:SetEventScript(ui.LBUTTONUP, data.func)
            item_elem:ShowWindow(1)
        end
    end

    local main_btn = GET_CHILD(frame, "norisan_menu_pic")
    if main_btn then
        if open_up then
            main_btn:SetPos(0, frame_h_new - 40)
        else
            main_btn:SetPos(0, 0)
        end
    end
end

function _G.norisan_menu_frame_open(frame, ctrl)
    -- ts(frame:GetName())
    if not frame then
        return
    end

    if frame:GetHeight() > 40 then

        local children = {}
        for i = 0, frame:GetChildCount() - 1 do
            local child_obj = frame:GetChildByIndex(i)
            if child_obj then
                table.insert(children, child_obj)
            end
        end

        for _, child_obj in ipairs(children) do
            if child_obj:GetName() ~= "norisan_menu_pic" then

                frame:RemoveChild(child_obj:GetName())
            end
        end

        frame:Resize(40, 40)
        frame:SetPos(frame:GetX(), _G["norisan"]["MENU"].y or 30)
        local main_pic = GET_CHILD(frame, "norisan_menu_pic")
        if main_pic then
            main_pic:SetPos(0, 0)
        end
        return
    end

    local open_dir_val = _G["norisan"]["MENU"].open or 0
    _G.norisan_menu_toggle_items_display(frame, ctrl, open_dir_val)
end

function g.norisan_menu_create_frame()

    _G["norisan"]["MENU"].lang = option.GetCurrentCountry()

    local loaded_cfg = norisan_menu_load_json(norisan_menu_settings)

    if loaded_cfg and loaded_cfg.layer ~= nil then
        _G["norisan"]["MENU"].layer = loaded_cfg.layer
    elseif _G["norisan"]["MENU"].layer == nil then
        _G["norisan"]["MENU"].layer = 79
    end

    if loaded_cfg and loaded_cfg.move ~= nil then
        _G["norisan"]["MENU"].move = loaded_cfg.move
    elseif _G["norisan"]["MENU"].move == nil then
        _G["norisan"]["MENU"].move = true
    end

    if loaded_cfg and loaded_cfg.open ~= nil then
        _G["norisan"]["MENU"].open = loaded_cfg.open
    elseif _G["norisan"]["MENU"].open == nil then
        _G["norisan"]["MENU"].open = 0
    end

    local default_x = 1190
    local default_y = 30

    local final_x = default_x
    local final_y = default_y

    if _G["norisan"]["MENU"].x ~= nil then
        final_x = _G["norisan"]["MENU"].x
    end
    if _G["norisan"]["MENU"].y ~= nil then
        final_y = _G["norisan"]["MENU"].y
    end

    if loaded_cfg and type(loaded_cfg.x) == "number" then
        final_x = loaded_cfg.x
    end
    if loaded_cfg and type(loaded_cfg.y) == "number" then
        final_y = loaded_cfg.y
    end

    local map_ui = ui.GetFrame("map")
    local screen_w = 1920
    if map_ui and map_ui:IsVisible() then
        screen_w = map_ui:GetWidth()
    end

    if final_x > 1920 and screen_w <= 1920 then
        final_x = default_x
        final_y = default_y
    end

    _G["norisan"]["MENU"].x = final_x
    _G["norisan"]["MENU"].y = final_y

    norisan_menu_save_json(norisan_menu_settings, _G["norisan"]["MENU"])

    local frame = ui.CreateNewFrame("chat_memberlist", "norisan_menu_frame", 0, 0, 0, 0)

    AUTO_CAST(frame)
    frame:RemoveAllChild()
    frame:SetSkinName("None")
    frame:SetTitleBarSkin("None")
    frame:Resize(40, 40)
    frame:SetLayerLevel(_G["norisan"]["MENU"].layer)
    frame:EnableMove(_G["norisan"]["MENU"].move == true and 1 or 0)
    frame:SetPos(_G["norisan"]["MENU"].x, _G["norisan"]["MENU"].y)
    frame:SetEventScript(ui.LBUTTONUP, "norisan_menu_move_drag")

    local norisan_menu_pic = frame:CreateOrGetControl('picture', "norisan_menu_pic", 0, 0, 35, 40)
    AUTO_CAST(norisan_menu_pic)
    norisan_menu_pic:SetImage("sysmenu_sys")
    norisan_menu_pic:SetEnableStretch(1)
    local notice = _G["norisan"]["MENU"].lang == "Japanese" and "{nl}{ol}右クリック: 設定" or
                       "{nl}{ol}Right click: Settings"
    norisan_menu_pic:SetTextTooltip("{ol}Addons Menu" .. notice)
    norisan_menu_pic:SetEventScript(ui.LBUTTONUP, "norisan_menu_frame_open")
    norisan_menu_pic:SetEventScript(ui.RBUTTONUP, "norisan_menu_setting_frame")

    frame:ShowWindow(1)

end

