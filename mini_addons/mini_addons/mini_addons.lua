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
-- v1.7.9.1 イベントシャウトチャット機能、インベントリor検索
-- v1.7.9.2 コード見直し。書き直し。acutil排除
-- v1.8.0 チャットフレーム改造のバグ修正
local addon_name = "MINI_ADDONS"
local addon_name_lower = string.lower(addon_name)
local author = "norisan"
local ver = "1.8.0"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addon_name] = _G["ADDONS"][author][addon_name] or {}
local g = _G["ADDONS"][author][addon_name]

local os = require("os")
local json = require("json")
local json_imc = require("json_imc")

local function ts(...)
    local num_args = select("#", ...)
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

local active_id = session.loginInfo.GetAID()
g.settings_path = string.format("../addons/%s/%s.json", addon_name_lower, active_id .. "_1")
g.buffs_path = string.format("../addons/%s/buffs.json", addon_name_lower)

function g.setup_hook(my_func, origin_func_name)
    local addon_upper = string.upper(addon_name)
    local replace_name = addon_upper .. "_REPLACE_" .. origin_func_name
    g.FUNCS = g.FUNCS or {}
    if not _G[replace_name] then
        _G[replace_name] = _G[origin_func_name]
    end
    _G[origin_func_name] = my_func
    g.FUNCS[origin_func_name] = _G[replace_name]
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
    auto_gacha_start = 0,
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
    multiple_item = 0,
    event_shout = {
        use = 0,
        guild_notice = 0
    },
    select_bgm = ""
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
                       "boss_rank", "auto_craft", "keep_first", "multiple_item", "event_shout"}

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
    name = "event_shout",
    text_jp = "{#FF0000}New!{/}{/}{ol}イベントグローバルシャウトをチャットに表示",
    text_kr = "{#FF0000}New!{/}{/}{ol}이벤트 글로벌 샤우트를 채팅에 표시",
    text_en = "{#FF0000}New!{/}{/}{ol}Displays Event Global Shouts in the chat"
}, {
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
    name = "icor_status_search",
    text_jp = "インベントリでイコルのステータスを検索 半角スペースでor検索",
    text_kr = "인벤토리에서 아이커 능력치 검색 반각 공백으로 OR 검색",
    text_en = "Search Icor status in Inventory OR search using half-width spaces"
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
    }, {
        name = "chat_frame",
        text_jp = "ワイドモニターの追加チャットフレームの移動制限解除",
        text_kr = "와이드 모니터에서 추가 채팅창의 이동 제한 해제",
        text_en = "Freely move additional chat frames on wide monitors"
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
    }, {
        name = "equip_info",
        text_jp = "アーク/エンブレム装備忘れ通知",
        text_kr = "아크/엠블렘 장비 미착용 알림",
        text_en = "Notification for unequipped Ark/Emblem"
    }, {
        name = "vakarine",
        text_jp = "レイドでヴァカリネ装備を通知",
        text_kr = "레이드에서 바카리네 장비 알림",
        text_en = "Vakarine Equipment Notification in Raids"
    }, {
        name = "skill_cool_sound",
        text_jp = "スキル連打時のクールタイムの音を消去",
        text_kr = "스킬 연타 시의 재사용 대기시간(쿨타임) 효과음을 삭제했습니다",
        text_en = "Removed the cooldown sound when a skill is spammed"
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
        text_jp = "パーティー情報フレームをバフ数に合わせてリサイズ",
        text_kr = "파티 정보 프레임을 버프 수에 맞춰 리사이즈",
        text_en = "Resized the party information frame to match the number of buffs"
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
    }, {
        name = "daily_quest",
        text_jp = "デイリークエストを別窓で表示",
        text_kr = "일일 퀘스트를 별도 창에 표시합니다",
        text_en = "Display the daily quest in a separate window"
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
    }, {
        name = "dialog_ctrl",
        text_jp = "各種ダイアログを制御",
        text_kr = "각종 다이얼로그 제어",
        text_en = "Controls various dialogs"
    }, {
        name = "goodbye_ragana",
        text_jp = "街でラガナを非表示",
        text_kr = "마을에서 라가나 숨기기",
        text_en = "Hide Ragana in city"
    }, {
        name = "rp_charge",
        text_jp = "レリック自動補充を補完",
        text_kr = "레릭 자동 보충 기능에 보완(복구) 기능이 추가되었습니다",
        text_en = "Relic auto-replenishment now includes a recovery function"
    }}
}

function mini_addons_subframe_close()
    ui.DestroyFrame(addon_name_lower .. "sub_frame")
end

function mini_addons_subframe_open(frame, ctrl, str)
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
    close:SetEventScript(ui.LBUTTONUP, "mini_addons_subframe_close")
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
        local checkbox = gbox:CreateOrGetControl("checkbox", setting.name, 10, y, 25, 25)
        AUTO_CAST(checkbox)
        checkbox:SetCheck(check_value)
        checkbox:SetEventScript(ui.LBUTTONUP, "mini_addons_ISCHECK")
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
        if setting.name == "baubas_call" then -- チェックボックスの隣に特殊なUIを追加する処理
            local baubas_call_btn = gbox:CreateOrGetControl("button", "baubas_call_btn", text_width + 15, y - 5, 50, 30)
            AUTO_CAST(baubas_call_btn)
            if g.settings.baubas_call.guild_notice == 0 or not g.settings.baubas_call.guild_notice then
                baubas_call_btn:SetText("{ol}{#FFFFFF}OFF")
                baubas_call_btn:SetSkinName("test_gray_button")
                g.settings.baubas_call.guild_notice = 0
                mini_addons_save_settings()
            else
                baubas_call_btn:SetText("{ol}{#FFFFFF}ON")
                baubas_call_btn:SetSkinName("test_red_button")
            end
            local tooltip_text = g.lang == "Japanese" and "{ol}ギルドチャットへのお知らせ切替え" or
                                     g.lang == "kr" and "{ol}길드 채팅으로 알림 전환" or
                                     "{ol}Notification switch to guild chat"
            baubas_call_btn:SetTextTooltip(tooltip_text)
            baubas_call_btn:SetEventScript(ui.LBUTTONUP, "mini_addons_baubas_call_switch")
            local btn_width = baubas_call_btn:GetWidth()
            if x < text_width + 15 + btn_width then
                x = text_width + 15 + btn_width
            end
        elseif setting.name == "other_effect" or setting.name == "my_effect" or setting.name == "boss_effect" then
            local edit_name = setting.name .. "_edit"
            local edit_ctrl = gbox:CreateOrGetControl("edit", edit_name, text_width + 15, y, 60, 25)
            AUTO_CAST(edit_ctrl)
            local event_name = "mini_addons_" .. string.upper(setting.name) .. "_EDIT"
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
            local auto_gacha_btn = gbox:CreateOrGetControl("button", "auto_gacha_btn", text_width + 15, y - 5, 50, 30)
            AUTO_CAST(auto_gacha_btn)
            if g.settings.auto_gacha_start == 0 then
                auto_gacha_btn:SetText("{ol}{#FFFFFF}OFF")
                auto_gacha_btn:SetSkinName("test_gray_button")
            else
                auto_gacha_btn:SetText("{ol}{#FFFFFF}ON")
                auto_gacha_btn:SetSkinName("test_red_button")
            end
            local tooltip_text = g.lang == "Japanese" and "{ol}ONにすると自動でガチャスタートします" or
                                     g.lang == "kr" and
                                     "{ol}ON으로 설정하면 자동으로 가챠가 시작됩니다" or
                                     "{ol}When turned on, the gacha starts automatically"
            auto_gacha_btn:SetTextTooltip(tooltip_text)
            auto_gacha_btn:SetEventScript(ui.LBUTTONUP, "mini_addons_GP_AUTOSTART_OPERATION")
            if x < text_width + 15 + 50 then
                x = text_width + 15 + 50
            end
        elseif setting.name == "weekly_boss_reward" then
            if not g.settings.reward_switch then
                g.settings.reward_switch = 1
                mini_addons_save_settings()
            end
            local switch_btn = gbox:CreateOrGetControl("button", "switch", text_width + 15, y, 80, 25)
            AUTO_CAST(switch_btn)
            if g.settings.reward_switch == 1 then
                switch_btn:SetText(g.lang == "Japanese" and "{ol}先週分" or g.lang == "kr" and "{ol}지난 주분" or
                                       "{ol}last week")
            else
                switch_btn:SetText(g.lang == "Japanese" and "{ol}今週分" or g.lang == "kr" and "{ol}이번 주분" or
                                       "{ol}this week")
            end
            switch_btn:SetEventScript(ui.LBUTTONUP, "mini_addons_WEEKLY_BOSS_REWARD_SWITCH")
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

function mini_addons_SETTING_FRAME_INIT(frame_arg, ctrl_arg, str_arg, num_arg)
    local setting = ui.CreateNewFrame("notice_on_pc", addon_name_lower .. "setting", 0, 0, 10, 10)
    AUTO_CAST(setting)
    if setting:GetWidth() > 100 and str_arg == "false" then
        setting:Resize(0, 0)
        setting:ShowWindow(0)
        return
    end
    setting:SetSkinName("test_frame_low")
    setting:SetLayerLevel(93)
    setting:EnableHittestFrame(1)
    setting:ShowTitleBar(0)
    setting:RemoveAllChild()
    setting:SetEventScript(ui.RBUTTONUP, "mini_addons_FRAME_CLOSE")
    local title = setting:CreateOrGetControl("richtext", "title", 30, 10)
    AUTO_CAST(title)
    title:SetText("{@st66b18}Mini Addons {/}{#000000}{s13} ver " .. ver)
    local close = setting:CreateOrGetControl("button", "close", 0, 5, 30, 30)
    AUTO_CAST(close)
    close:SetGravity(ui.RIGHT, ui.TOP)
    close:SetSkinName("None")
    close:SetText("{img testclose_button 30 30}")
    close:SetEventScript(ui.LBUTTONUP, "mini_addons_FRAME_CLOSE")
    local gbox = setting:CreateOrGetControl("groupbox", "gbox", 10, 30, 0, 0)
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
        button:SetTextAlign("left", "center")
        button:SetEventScript(ui.LBUTTONUP, "mini_addons_subframe_open")
        button:SetEventScriptArgString(ui.LBUTTONUP, temp_text)
        button:SetEventScript(ui.RBUTTONUP, "mini_addons_subframe_close")
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
        elseif setting.name == "event_shout" then
            check_value = g.settings.event_shout.use
        else
            check_value = g.settings[setting.name]
        end
        local checkbox = gbox:CreateOrGetControl("checkbox", setting.name, 10, y, 25, 25)
        AUTO_CAST(checkbox)
        checkbox:SetCheck(check_value)
        checkbox:SetEventScript(ui.LBUTTONUP, "mini_addons_ISCHECK")
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
            local party_buff_btn = gbox:CreateOrGetControl("button", "party_buff_btn", text_width + 15, y - 5, 80, 30)
            AUTO_CAST(party_buff_btn)
            party_buff_btn:SetText("{ol}{#FFFFFF}bufflist")
            local tooltip_text =
                g.lang == "Japanese" and "表示するバフを選択できます" or g.lang == "kr" and
                    "표시할 버프를 선택할 수 있습니다" or "You can choose which buffs to display"
            party_buff_btn:SetTextTooltip(tooltip_text)
            party_buff_btn:SetSkinName("test_red_button")
            party_buff_btn:SetEventScript(ui.LBUTTONUP, "mini_addons_buff_list_open")
        elseif setting.name == "auto_zoom" then
            local edit_name = setting.name .. "_edit"
            local edit_ctrl = gbox:CreateOrGetControl("edit", edit_name, text_width + 15, y, 60, 25)
            AUTO_CAST(edit_ctrl)
            edit_ctrl:SetEventScript(ui.ENTERKEY, "mini_addons_autozoom_edit")
            edit_ctrl:SetTextTooltip("{ol}1~700 Default 336")
            edit_ctrl:SetFontName("white_16_ol")
            edit_ctrl:SetTextAlign("center", "center")
            edit_ctrl:SetText("{ol}" .. g.settings.auto_zoom.zoom)
            if x < text_width + 15 + 60 then
                x = text_width + 15 + 60
            end
        elseif setting.name == "event_shout" then
            local event_shout_btn = gbox:CreateOrGetControl("button", "event_shout_btn", text_width + 15, y - 5, 50, 30)
            AUTO_CAST(event_shout_btn)
            if g.settings.event_shout.guild_notice == 0 or not g.settings.event_shout.guild_notice then
                event_shout_btn:SetText("{ol}{#FFFFFF}OFF")
                event_shout_btn:SetSkinName("test_gray_button")
                g.settings.event_shout.guild_notice = 0
                mini_addons_save_settings()
            else
                event_shout_btn:SetText("{ol}{#FFFFFF}ON")
                event_shout_btn:SetSkinName("test_red_button")
            end
            local tooltip_text = g.lang == "Japanese" and "{ol}ギルドチャットへのお知らせ切替え" or
                                     g.lang == "kr" and "{ol}길드 채팅으로 알림 전환" or
                                     "{ol}Notification switch to guild chat"
            event_shout_btn:SetTextTooltip(tooltip_text)
            event_shout_btn:SetEventScript(ui.LBUTTONUP, "mini_addons_event_shout_switch")
            local btn_width = event_shout_btn:GetWidth()
            if x < text_width + 15 + btn_width then
                x = text_width + 15 + btn_width
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
    setting:Resize(x + 65, y + 45)
    gbox:Resize(setting:GetWidth() - 20, setting:GetHeight() - 40)
    local screen_width = ui.GetClientInitialWidth()
    local screen_height = ui.GetClientInitialHeight()
    setting:SetPos((screen_width - setting:GetWidth()) / 2, (screen_height - setting:GetHeight()) / 2)
    setting:ShowWindow(1)
end

function mini_addons_FRAME_CLOSE(setting)
    ui.DestroyFrame(setting:GetName())
    mini_addons_subframe_close()
end

function mini_addons_ISCHECK(frame, ctrl, argStr, argNum)
    local is_checked = ctrl:IsChecked()
    local ctrl_name = ctrl:GetName()
    for _, setting_name in ipairs(SETTINGS_NAME) do
        if ctrl_name == setting_name then
            if setting_name == "cupole_portion" or setting_name == "velnice" or setting_name == "baubas_call" or
                setting_name == "auto_zoom" or setting_name == "event_shout" then
                g.settings[setting_name] = g.settings[setting_name] or {}
                g.settings[setting_name].use = is_checked
            else
                g.settings[setting_name] = is_checked
            end
            if setting_name == "bgm" then -- 特定の機能に対する即時処理
                if is_checked == 0 then
                    local max_frame = ui.GetFrame("bgmplayer")
                    local play_btn = GET_CHILD_RECURSIVELY(max_frame, "playStart_btn")
                    BGMPLAYER_PLAY(max_frame, play_btn)
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
    mini_addons_save_settings()
end

function mini_addons_load_settings()
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
    mini_addons_save_settings()
end

function mini_addons_save_settings()
    g.save_json(g.settings_path, g.settings)
end

function mini_addons_load_buffs()
    local buffs = g.load_json(g.buffs_path)
    if not buffs then
        buffs = {}
    end
    g.buffs = buffs
    g.save_json(g.buffs_path, g.buffs)
end

function MINI_ADDONS_ON_INIT(addon, frame)
    g.addon = addon
    g.frame = frame
    g.REGISTER = {}
    g.cid = info.GetCID(session.GetMyHandle())
    g.lang = option.GetCurrentCountry()
    g.load_time = os.clock()
    g.last_inventory_open_time = 0
    if not g.settings then
        mini_addons_load_settings()
    end
    if not g.buffs then -- PTバフの準備
        mini_addons_load_buffs()
    end
    g.setup_hook(mini_addons_CHAT_SYSTEM, "CHAT_SYSTEM")
    -- スキル連打音消す
    g.setup_hook(mini_addons_ICON_USE, "ICON_USE")
    addon:RegisterMsg("GAME_START", "mini_addons_GAME_START")
    addon:RegisterMsg("GAME_START_3SEC", "mini_addons_GAME_START_3SEC")
end

function mini_addons_GAME_START(frame, msg, str, num)
    local mini_addons = ui.GetFrame("mini_addons")
    mini_addons:RunUpdateScript("mini_addons_runupdate_5", 0.5)
    -- AUTOMAPCHANGEに付けていたオートズーム機能を殺す
    if _G["AUTOMAPCHANGE_CAMERA_ZOOM"] and type(_G["AUTOMAPCHANGE_CAMERA_ZOOM"]) == "function" then
        _G["AUTOMAPCHANGE_CAMERA_ZOOM"] = nil
    end
    -- クポルポーションフレームの移動と非表示
    local cupole_external_addon = ui.GetFrame("cupole_external_addon")
    cupole_external_addon:SetEventScript(ui.LBUTTONUP, "mini_addons_cupole_portion_frame_save")
    -- クエストインフォを隠す
    mini_addons_ON_UPDATE_QUESTINFOSET_2(nil)
    g.setup_hook(mini_addons_ON_UPDATE_QUESTINFOSET_2, "ON_UPDATE_QUESTINFOSET_2")
    -- お使いクエストフレーム
    g.addon:RegisterMsg("QUEST_UPDATE", "mini_addons_quest_update")
    g.addon:RegisterMsg("QUEST_UPDATE_", "mini_addons_quest_update")
    g.addon:RegisterMsg("GET_NEW_QUEST", "mini_addons_quest_update")
    mini_addons_quest_update()
    -- 最初回のイベントバナーのレイヤー下げる
    g.addon:RegisterMsg("DO_OPEN_EVENTBANNER_UI", "mini_addons_event_banner_layer")
    g.addon:RegisterMsg("EVENTBANNER_SOLODUNGEON", "mini_addons_event_banner_layer")
    -- 追加報酬券チェック
    g.addon:RegisterMsg("REQ_PLAYER_CONTENTS_RECORD", "mini_addons_REQ_PLAYER_CONTENTS_RECORD")
end

function mini_addons_GAME_START_3SEC(frame, msg, str, num)
    -- チャットフレーム改造
    if type(_G["ZCHATEXTENDS_ON_INIT"]) ~= "function" then
        mini_addons_update_chat_frame()
        g.setup_hook_and_event(g.addon, "INVENTORY_OP_POP", "mini_addons_INVENTORY_OP_POP", true)
    elseif g.settings.chat_new_btn == 1 then
        g.settings.chat_new_btn = 0
        mini_addons_save_settings()
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
    g.addon:RegisterMsg("WEEKLY_BOSS_UI_UPDATE", "mini_addons_WEEKLYBOSS_PATTERNINFO_UI_UPDATE")
    g.setup_hook_and_event(g.addon, "WEEKLY_BOSS_RANK_UPDATE", "mini_addons_WEEKLY_BOSS_RANK_UPDATE", true)
    g.setup_hook_and_event(g.addon, "INDUNINFO_UI_CLOSE", "mini_addons_INDUNINFO_UI_CLOSE", true)
    -- 製造自動セット
    g.setup_hook_and_event(g.addon, "CRAFT_RECIPE_FOCUS", "mini_addons_CRAFT_RECIPE_FOCUS", true)
    g.setup_hook_and_event(g.addon, "CRAFT_START_CRAFT", "mini_addons_CRAFT_START_CRAFT", true)
    -- パーティーメンバーの場所表示
    mini_addons_partymember_get_map()
    -- PTメンバーの死亡と復活をNICO_CHATで流す
    g.setup_hook_and_event(g.addon, "DRAW_CHAT_MSG", "mini_addons_DRAW_CHAT_MSG", true)
    -- ワールドマップにトークンワープのクールダウンを表示
    g.setup_hook_and_event(g.addon, "OPEN_WORLDMAP2_MINIMAP", "mini_addons_OPEN_WORLDMAP2_MINIMAP", true)
    -- どこでもメンバーインフォ
    g.setup_hook(mini_addons_CHAT_RBTN_POPUP, "CHAT_RBTN_POPUP")
    g.setup_hook(mini_addons_POPUP_GUILD_MEMBER, "POPUP_GUILD_MEMBER")
    g.setup_hook(mini_addons_CONTEXT_PARTY, "CONTEXT_PARTY")
    g.setup_hook(mini_addons_SHOW_PC_CONTEXT_MENU, "SHOW_PC_CONTEXT_MENU")
    g.setup_hook(mini_addons_POPUP_DUMMY, "POPUP_DUMMY")
    g.setup_hook(mini_addons_POPUP_FRIEND_COMPLETE_CTRLSET, "POPUP_FRIEND_COMPLETE_CTRLSET")
    -- バウバスお知らせ
    g.setup_hook_and_event(g.addon, "NOTICE_ON_MSG", "mini_addons_NOTICE_ON_MSG_baubas", true)
    -- ブラックマーケット削除
    g.setup_hook(mini_addons_NOTICE_ON_MSG, "NOTICE_ON_MSG")
    g.setup_hook(mini_addons_CHAT_TEXT_LINKCHAR_FONTSET, "CHAT_TEXT_LINKCHAR_FONTSET")
    -- FPS設定を手動入力
    g.setup_hook_and_event(g.addon, "SYS_OPTION_OPEN", "mini_addons_SYS_OPTION_OPEN", true)
    -- ボスレランキングにメンバーインフォ
    g.setup_hook_and_event(g.addon, "WEEKLY_BOSS_RANK_UPDATE", "mini_addons_WEEKLY_BOSS_RANK_UPDATE_", true)
    -- ヘアエンチャント関係
    g.setup_hook_and_event(g.addon, "HIGH_ENCHANT_OPTION_OPEN_BTN", "mini_addons_HIGH_ENCHANT_OPTION_OPEN_BTN", true)
    g.setup_hook_and_event(g.addon, "HIGH_HAIRENCHANT_CLOSE_BTN", "mini_addons_HIGH_HAIRENCHANT_CLOSE_BTN", true)
    g.setup_hook_and_event(g.addon, "HIGH_HAIRENCHANT_OK_BTN", "mini_addons_HIGH_HAIRENCHANT_OK_BTN", false)
    -- チャットフレーム移動のワイドモニター制限解除
    g.setup_hook_and_event(g.addon, "_PROCESS_MOVE_MAIN_POPUPCHAT_FRAME",
        "mini_addons__PROCESS_MOVE_MAIN_POPUPCHAT_FRAME", false)
    -- ヴァカリネを伝える
    mini_addons_vakarine_notice()
    -- コインショップの数値を拡張
    g.setup_hook(mini_addons_EARTHTOWERSHOP_CHANGECOUNT_NUM_CHANGE, "EARTHTOWERSHOP_CHANGECOUNT_NUM_CHANGE")
    -- 4人以下の入場確認スキップ
    g.setup_hook(mini_addons_INDUNENTER_REQ_UNDERSTAFF_ENTER_ALLOW, "INDUNENTER_REQ_UNDERSTAFF_ENTER_ALLOW")
    -- ヴェルニケ階数を覚える
    g.setup_hook(mini_addons_INDUN_EDITMSGBOX_FRAME_OPEN, "INDUN_EDITMSGBOX_FRAME_OPEN")
    g.addon:RegisterMsg("SOLO_D_TIMER_TEXT_GAUGE_UPDATE", "mini_addons_SOLO_D_TIMER_UPDATE_TEXT_GAUGE")
    -- PTバフの表示非表示切り替え
    g.setup_hook(mini_addons_ON_PARTYINFO_BUFFLIST_UPDATE, "ON_PARTYINFO_BUFFLIST_UPDATE")
    -- チャンネルのズレを直す
    g.setup_hook(mini_addons_UPDATE_CURRENT_CHANNEL_TRAFFIC, "UPDATE_CURRENT_CHANNEL_TRAFFIC")
    -- インベントリイコル検索
    g.setup_hook(mini_addons_INVENTORY_TOTAL_LIST_GET, "INVENTORY_TOTAL_LIST_GET")
    -- イベントグローバルシャウトをチャットに残す
    mini_addons_event_frame()
    g.addon:RegisterMsg("NOTICE_Dm_Global_Shout", "mini_addons_event_NOTICE_ON_MSG")
    g.addon:RegisterMsg("INV_ITEM_ADD", "mini_addons_event_frame")
    g.addon:RegisterMsg("INV_ITEM_REMOVE", "mini_addons_event_frame")
    -- 装備錬成を自動化
    g.setup_hook(mini_addons_COMMON_EQUIP_UPGRADE_PROGRESS, "COMMON_EQUIP_UPGRADE_PROGRESS")
    g.setup_hook_and_event(g.addon, "COMMON_EQUIP_UPGRADE_OPEN", "mini_addons_COMMON_EQUIP_UPGRADE_OPEN", true)
    -- マーケット販売時に持ってる最大値を自動入力
    g.setup_hook_and_event(g.addon, "MARKET_SELL_UPDATE_REG_SLOT_ITEM", "mini_addons_MARKET_SELL_UPDATE_REG_SLOT_ITEM",
        true)
    -- レイドレコードの2度呼ばれるバグ修正
    g.addon:RegisterMsg("REQ_PLAYER_CONTENTS_RECORD", "mini_addons__REQ_PLAYER_CONTENTS_RECORD")
    -- レイドレコードのサイズ、位置変更
    g.setup_hook_and_event(g.addon, "RAID_RECORD_INIT", "mini_addons_RAID_RECORD_INIT", true)
    -- 自分のエフェクト設定を戻すIMCのバグ修正
    mini_addons_MY_EFFECT_SETTING()
    -- ボスのエフェクト設定を戻すIMCのバグ修正
    mini_addons_BOSS_EFFECT_SETTING()
    -- その他のエフェクト設定を戻すIMCのバグ修正
    mini_addons_OTHER_EFFECT_SETTING()
    -- エンブレム、アークの着け忘れお知らせ
    g.setup_hook_and_event(g.addon, "SHOW_INDUNENTER_DIALOG", "mini_addons_SHOW_INDUNENTER_DIALOG", true)
    -- 自動マッチのレイヤーを下げる
    g.setup_hook_and_event(g.addon, "INDUNENTER_AUTOMATCH_TYPE", "mini_addons_INDUNENTER_AUTOMATCH_TYPE", true)
    -- 死んだ時の選択肢を動かす
    g.addon:RegisterMsg("RESTART_HERE", "mini_addons_RESTART_HERE")
    g.addon:RegisterMsg("RESTART_CONTENTS_HERE", "mini_addons_RESTART_HERE")
    -- 死んだ時のマウス位置制御
    g.setup_hook_and_event(g.addon, "RESTART_CONTENTS_ON_HERE", "mini_addons_RESTART_CONTENTS_ON_HERE", true)
    -- コロニー死んだ時に30秒タイマー動かないバグ修正
    g.setup_hook(mini_addons_RESTART_ON_MSG, "RESTART_ON_MSG")
    -- ダイアログ制御系
    g.addon:RegisterMsg("DIALOG_CHANGE_SELECT", "mini_addons_DIALOG_CHANGE_SELECT")
    -- ファミリーネームからログインネームへ変換
    g.addon:RegisterMsg("BUFF_ADD", "mini_addons_PCNAME_REPLACE")
    g.addon:RegisterMsg("BUFF_UPDATE", "mini_addons_PCNAME_REPLACE")
    -- オートキャスティングをキャラ毎に設定
    g.setup_hook_and_event(g.addon, "CONFIG_ENABLE_AUTO_CASTING", "mini_addons_CONFIG_ENABLE_AUTO_CASTING", true)
    mini_addons_SET_ENABLE_AUTO_CASTING()
    -- チャンネル切替フレーム
    mini_addons_GAME_START_CHANNEL_LIST()
    -- ペットコマンド制御
    g.setup_hook_and_event(g.addon, "SHOW_PET_RINGCOMMAND", "mini_addons_SHOW_PET_RINGCOMMAND", false)
    -- レリックゲージ
    local map_name = session.GetMapName()
    local colony_cls_list, cnt = GetClassList("guild_colony")
    for i = 0, cnt - 1 do
        local colonyCls = GetClassByIndexFromList(colony_cls_list, i)
        local check_word = "GuildColony_"
        if not string.find(map_name, check_word) then
            mini_addons_CHARBASE_RELIC()
            g.addon:RegisterMsg("RP_UPDATE", "mini_addons_CHARBASE_RELIC")
        end
    end
    -- パーティー情報フレームを小さくする
    g.addon:RegisterMsg("PARTY_BUFFLIST_UPDATE", "mini_addons_PARTY_BUFFLIST_UPDATE")
    -- EP13ショップを街で開ける
    mini_addons_REPUTATION_SHOP_OPEN()
    -- 町でBGMPLAYERを常に動かす
    mini_addons_BGM_PLAY()
    -- 小さいボタンをレイドで非表示
    mini_addons_MINIMIZED_CLOSE()
    -- ボタン右クリックでサウンドオフ
    mini_addons_toggle_sound_set()
    -- インベントリを改造
    g.addon:RegisterMsg("INV_ITEM_ADD", "mini_addons_inventory_open_func")
    g.addon:RegisterMsg("INV_ITEM_REMOVE", "mini_addons_inventory_open_func")
    g.setup_hook_and_event(g.addon, "INVENTORY_OPEN", "mini_addons_INVENTORY_OPEN", true)
    if g.get_map_type() == "City" then
        -- ヴェルニケ自動受取り
        mini_addons_SOLODUNGEON_RANKINGPAGE_GET_REWARD()
        -- ボスレ報酬自動受取り
        mini_addons_WEEKLY_BOSS_REWARD()
        -- 街のラガナを非表示
        mini_addons_ragana_remove_timer()
        -- RPチャージを補完
        mini_addons_rp_check()
        -- 町でマーケットボタンを常に表示
        mini_addons_MINIMIZED_TOTAL_SHOP_BUTTON_CLICK()
        -- 傭兵団コイン、女神コイン、王国再建団コインを取得時、自動で使用
        mini_addons_INV_ICON_USE()
        -- 錬成時に自動でアイテムセット
        g.setup_hook_and_event(g.addon, "COMMON_SKILL_ENCHANT_MAT_SET", "mini_addons_COMMON_SKILL_ENCHANT_MAT_SET", true)
        g.setup_hook_and_event(g.addon, "SUCCESS_COMMON_SKILL_ENCHANT", "mini_addons_SUCCESS_COMMON_SKILL_ENCHANT", true)
        -- 自動女神ガチャ
        mini_addons_GP_FULL_BET()
        g.addon:RegisterMsg("FIELD_BOSS_WORLD_EVENT_START", "mini_addons_GP_DO_OPEN")
        g.addon:RegisterMsg("FIELD_BOSS_WORLD_EVENT_END", "mini_addons_FIELD_BOSS_WORLD_EVENT_END")
        -- オプションリロールの表を横に表示
        g.addon:RegisterMsg("OPEN_DLG_REROLL_ITEM", "mini_addons_OPEN_DLG_REROLL_ITEM")
    end
    g.addon:RegisterMsg("FPS_UPDATE", "mini_addons_FPS_UPDATE")
    local sysmenu = ui.GetFrame("sysmenu")
    sysmenu:RunUpdateScript("mini_addons_make_menu", 2.0)
end

function mini_addons_FPS_UPDATE()
    -- オートズーム
    mini_addons_autozoom()
    -- 傭兵団コイン獲得フレームを表示
    if g.get_map_type() == "City" then
        local coin_get_gauge = ui.GetFrame("coin_get_gauge")
        if config.GetXMLStrConfig("ShowCoinGetGauge") ~= "0" and coin_get_gauge:IsVisible() == 0 then
            coin_get_gauge:ShowWindow(1)
        end
    end
    local norisan_menu_frame = ui.GetFrame("norisan_menu_frame")
    if norisan_menu_frame and norisan_menu_frame:IsVisible() == 0 then
        norisan_menu_frame:ShowWindow(1)
    end
end

function mini_addons_make_menu(frame)
    _G["norisan"] = _G["norisan"] or {}
    _G["norisan"]["MENU"] = _G["norisan"]["MENU"] or {}
    local menu_data = {
        name = "Mini Addons",
        icon = "sysmenu_jal",
        func = "mini_addons_SETTING_FRAME_INIT",
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

function mini_addons_runupdate_5(mini_addons)
    -- セパレートバフフレームの周りを綺麗に
    mini_addons_buff_separatedlist()
    -- クポルポーションフレームの移動と非表示
    mini_addons_cupole_portion_frame()
    -- パーティーメンバーの場所表示
    mini_addons_partymember_get_map()
    local restart = ui.GetFrame("restart")
    if restart:IsVisible() == 0 then
        restart:SetUserValue("COLONY_TIMER_RUNNING", 0)
    end
    local mini_addons_channel = ui.GetFrame("mini_addons_channel")
    if g.zone_insts and mini_addons_channel and mini_addons_channel:IsVisible() == 0 then
        mini_addons_channel:ShowWindow(1)
    end
    -- 町でマーケットボタンを常に表示
    mini_addons_MINIMIZED_TOTAL_SHOP_BUTTON_CLICK()
    -- 傭兵団コイン、女神コイン、王国再建団コインを取得時、自動で使用
    mini_addons_INV_ICON_USE()
    -- 町でBGMPLAYERを常に動かす
    mini_addons_BGM_PLAY_LIST()
    -- パーティー情報フレームを小さくする
    mini_addons_PARTY_BUFFLIST_UPDATE()
    return 1
end

function mini_addons_CHAT_SYSTEM(msg, color)
    if msg and g.settings.chat_system == 1 then
        if msg == "&lt완벽함&gt 효과가 사라졌습니다." or msg ==
            "&lt완벽함&gt 효과가 발동되었습니다." or msg == "@dicID_^*$ETC_20220830_069434$*^" or msg ==
            "@dicID_^*$ETC_20220830_069435$*^" or msg == "[__m2util] is loaded" or msg == "[adjustlayer] is loaded" or
            msg == "[extendcharinfo] is loaded" or msg == "[ICC]Attempt to CC." or
            string.find(msg, "StartBlackMarketBetween") or string.find(msg, "[__m2util] is loaded") or
            string.find(msg, "[adjustlayer] is loaded") or string.find(msg, "MapMate") then
            return
        end
    end
    g.FUNCS["CHAT_SYSTEM"](msg, "FFFF00")
end
-- オートズーム
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
    mini_addons_save_settings()
    ctrl:RunUpdateScript("mini_addons_autozoom", 1.0)
end

function mini_addons_autozoom(ctrl)
    if g.settings.auto_zoom.use == 1 then
        camera.CustomZoom(tonumber(g.settings.auto_zoom.zoom))
    end
end
-- セパレートバフフレームの周りを綺麗に
function mini_addons_buff_separatedlist()
    local buff_separatedlist = ui.GetFrame("buff_separatedlist")
    local gbox = GET_CHILD_RECURSIVELY(buff_separatedlist, "gbox")
    AUTO_CAST(gbox)
    if g.settings.separated_buff == 1 then
        gbox:SetSkinName("None")
    else
        gbox:SetSkinName("chat_window")
    end
end
-- クポルポーションフレームの移動と非表示
function mini_addons_cupole_portion_frame_save(cupole_external_addon)
    g.settings.cupole_portion.x = cupole_external_addon:GetX()
    g.settings.cupole_portion.y = cupole_external_addon:GetY()
    mini_addons_save_settings()
end

function mini_addons_cupole_portion_frame()
    local cupole_external_addon = ui.GetFrame("cupole_external_addon")
    if g.settings.cupole_portion.x == 0 and g.settings.cupole_portion.y == 0 then
        local cur_x = cupole_external_addon:GetX()
        local cur_y = cupole_external_addon:GetY()
        if g.settings.cupole_portion.def_x ~= cur_x or g.settings.cupole_portion.def_y ~= cur_y then
            g.settings.cupole_portion.def_x = cur_x
            g.settings.cupole_portion.def_y = cur_y
            mini_addons_save_settings()
        end
    end
    if g.settings.cupole_portion.use == 1 then
        cupole_external_addon:ShowWindow(0)
    else
        if g.settings.cupole_portion.x == 0 and g.settings.cupole_portion.y == 0 then
            cupole_external_addon:SetPos(g.settings.cupole_portion.def_x, g.settings.cupole_portion.def_y)
        else
            cupole_external_addon:SetPos(g.settings.cupole_portion.x, g.settings.cupole_portion.y)
        end
        cupole_external_addon:ShowWindow(1)
    end
end
-- クエストインフォを隠す
function mini_addons_ON_UPDATE_QUESTINFOSET_2(questinfoset_2, msg, check, update_quest_id)
    local chase_info = ui.GetFrame("chaseinfo")
    local open_mark_quest = GET_CHILD_RECURSIVELY(chase_info, "openMark_quest")
    AUTO_CAST(open_mark_quest)
    open_mark_quest:ShowWindow(1)
    open_mark_quest:SetEventScript(ui.RBUTTONUP, "mini_addons_questinfo_toggle")
    local notice =
        g.lang == "Japanese" and "{ol}Mini Addons{nl}右クリック: クエストの表示/非表示切替" or
            "{ol}Mini Addons{nl}Right-click: Show/hide quests"
    open_mark_quest:SetTextTooltip(notice)
    if not questinfoset_2 then
        questinfoset_2 = ui.GetFrame("questinfoset_2")
    end
    if g.settings.quest_hide == 1 then
        questinfoset_2:ShowWindow(0)
        return
    end
    if CHASEINFO_IS_SHOW() == 0 then
        CHASEINFO_CLOSE_FRAME()
        return
    end
    CHASEINFO_SHOW_QUEST_TOGGLE(QUESTINFOSET_2_IS_DRAW())
    CHASEINFO_SHOW_ACHIEVE_TOGGLE(ACHIEVEINFOSET_IS_DRAW())
    if QUESTINFOSET_2_IS_DRAW() == 0 then
        questinfoset_2:ShowWindow(0)
        return
    else
        if ACHIEVEINFOSET_IS_DRAW() == 1 then
            if CHASEINFO_IS_ACHIEVE_FOLD() == 0 then
                CHASEINFO_SET_QUEST_INFOSET_FOLD(1)
            else
                if CHASEINFO_IS_QUEST_FOLD() == 1 then
                    CHASEINFO_SET_QUEST_INFOSET_FOLD(1)
                else
                    CHASEINFO_SET_QUEST_INFOSET_FOLD(0)
                end
            end
        else
            CHASEINFO_SET_QUEST_INFOSET_FOLD(0)
        end
    end
    if ACHIEVEINFOSET_IS_VALID_ACHIEVE() == 1 and CHASEINFO_IS_ACHIEVE_FOLD() == 0 then
        questinfoset_2:ShowWindow(0)
        return
    elseif CHASEINFO_IS_QUEST_FOLD() == 1 then
        questinfoset_2:ShowWindow(0)
        return
    else
        questinfoset_2:ShowWindow(1)
    end
    if update_quest_id ~= nil and update_quest_id > 0 then
        local group_ctrl = GET_CHILD(questinfoset_2, "member", "ui::CGroupBox")
        UPDATE_QUESTINFOSET_2_BY_TYPE(group_ctrl, msg, update_quest_id)
        QUESTINFOSET_2_AUTO_ALIGN(questinfoset_2, group_ctrl)
        return
    end
    if msg == "GAME_START" then
        PC_ENTER_QUESTINFO(questinfoset_2)
    end
    local group_ctrl = GET_CHILD(questinfoset_2, "member", "ui::CGroupBox")
    group_ctrl:DeleteAllControl()
    local quest_custom = GET_CHILD(questinfoset_2, "quest_custom")
    local quest_custom_size = quest_custom:GetMargin().top + quest_custom:GetHeight()
    local y = quest_custom_size
    local custom_option = GET_CHILD(questinfoset_2, "quest_custom", "ui::CCheckBox")
    if custom_option:IsChecked() == 0 then
        local cnt = QUESTINFOSET_2_GET_QUEST_NUM()
        for i = 0, cnt - 1 do
            local quest_id = quest.GetCheckQuest(i)
            local quest_cls = GetClassByType("QuestProgressCheck", quest_id)
            local ctrl_set = MAKE_QUEST_INFO_C(group_ctrl, quest_cls, msg)
            if ctrl_set ~= nil then
                y = y + ctrl_set:GetHeight()
            end
        end
    end
    local value = custom_option:GetUserIValue("is_quest_custom_draw")
    local custom_cnt = QUESTINFOSET_2_GET_CUSTOM_QUEST_NUM()
    if custom_cnt > 0 and (value ~= -1 or custom_option:IsChecked() == 1) then
        local ctrl_set = QUESTINFOSET_2_MAKE_CUSTOM(questinfoset_2, true)
        if ctrl_set ~= nil then
            y = y + ctrl_set:GetHeight()
        end
    end
    QUESTINFOSET_2_AUTO_ALIGN(questinfoset_2, group_ctrl)
    if custom_option:IsChecked() == 0 then
        QUEST_PARTY_MEMBER_PROP_UPDATE(questinfoset_2)
    end
end

function mini_addons_questinfo_toggle(parent, openMark_quest)
    g.settings.quest_hide = 1 - g.settings.quest_hide
    mini_addons_save_settings()
    mini_addons_ON_UPDATE_QUESTINFOSET_2(nil)
end
-- お使いクエストフレーム
function mini_addons_quest_update(frame, msg)
    if g.settings.daily_quest == 0 then
        ui.DestroyFrame("mini_addons_q7quest")
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
        local extracted_text = text:match(pattern) or "Quest"
        local q7quest = ui.GetFrame("mini_addons_q7quest")
        if not q7quest then
            q7quest = ui.CreateNewFrame("notice_on_pc", "mini_addons_q7quest", 0, 0, 0, 0)
            AUTO_CAST(q7quest)
        end
        if not msg then
            q7quest:RemoveAllChild()
        end
        q7quest:SetSkinName("bg2")
        q7quest:Resize(200, 85)
        local current_frame_w = q7quest:GetWidth()
        local map_frame = ui.GetFrame("map")
        local map_width = map_frame:GetWidth()
        q7quest:SetPos((map_width - current_frame_w) / 2, 130)
        q7quest:SetLayerLevel(100)
        if _G["INDUN_PANEL_ON_INIT"] and type(_G["INDUN_PANEL_ON_INIT"]) == "function" then
            local indun_panel = ui.GetFrame("indun_panel")
            if indun_panel then
                indun_panel_always_init(indun_panel, nil, nil)
            end
        end
        if _G["indun_panel_on_init"] and type(_G["indun_panel_on_init"]) == "function" then
            local indun_panel = ui.GetFrame("_nexus_addonsindun_panel")
            if indun_panel then
                Indun_panel_always_init(indun_panel, nil, nil)
            end
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
        local is_token_state = session.loginInfo.IsPremiumState(ITEM_TOKEN)
        local image_name = ""
        if is_token_state == true and GET_TOKEN_WARP_COOLDOWN() == 0 then
            image_name = "{img worldmap2_token_gold 35 35} {@st101lightbrown_16}"
        else
            image_name = "{img worldmap2_token_gray 35 35} {@st101lightbrown_16}"
        end
        token_warp:SetText(image_name)
        token_warp:SetTextTooltip("{ol}" .. last_part)
        token_warp:SetEventScript(ui.LBUTTONUP, "mini_addons_quest_token_warp")
        q7quest:ShowWindow(1)
        local abandon = q7quest:CreateOrGetControl("button", "abandon", 165, 53, 30, 30)
        AUTO_CAST(abandon)
        abandon:SetSkinName("test_gray_button")
        abandon:SetText("×")
        abandon:SetEventScript(ui.LBUTTONUP, "SCR_QUEST_ABANDON_SELECT")
        abandon:SetEventScriptArgNumber(ui.LBUTTONUP, 7)
    else
        ui.DestroyFrame("mini_addons_q7quest")
    end
end

function mini_addons_quest_token_warp()
    local target_map = mini_addons_quest_get_map()
    if target_map then
        WORLDMAP2_TOKEN_WARP(target_map)
    end
end

function mini_addons_quest_get_map()
    local quest_ies = GetClassByType("QuestProgressCheck", 7)
    local pc = SCR_QUESTINFO_GET_PC()
    local quest_max_mon_check = 6
    if quest_ies.Quest_SSN ~= "None" then
        local s_obj_quest = GetSessionObject(pc, quest_ies.Quest_SSN)
        if s_obj_quest and s_obj_quest.SSNMonKill ~= "None" then
            local mon_list = SCR_STRING_CUT(s_obj_quest.SSNMonKill, ":")
            if mon_list[1] == "ZONEMONKILL" then
                for i = 1, quest_max_mon_check do
                    if #mon_list - 1 >= i then
                        local index = i + 1
                        local zone_mon_info = SCR_STRING_CUT(mon_list[index])
                        local target_map = tostring(zone_mon_info[1])
                        return target_map
                    end
                end
            end
        end
    end
    return nil
end
-- 最初回のイベントバナーのレイヤー下げる
function mini_addons_event_banner_layer()
    local ingameeventbanner = ui.GetFrame("ingameeventbanner")
    if ingameeventbanner and ingameeventbanner:IsVisible() == 1 then
        AUTO_CAST(ingameeventbanner)
        ingameeventbanner:SetLayerLevel(99)
    end
end
-- 追加報酬券チェック ここから
local multiple_tokens = {
    ["Goddess_Raid_DespairIsland_Party"] = {11200361, 11200362},
    ["Goddess_Raid_BlackRevelation_Party"] = {11200387, 11200388},
    ["Goddess_Raid_CollapsingMine_Party"] = {11200395, 11200396},
    ["Goddess_Raid_Redania_Party"] = {11200403, 11200404},
    ["Goddess_Raid_Laimara_Party"] = {11200434, 11200435},
    ["Goddess_Raid_Veliora_Party"] = {11200438, 11200439}
}
function mini_addons_REQ_PLAYER_CONTENTS_RECORD(frame, msg)
    local current_raid_name = session.mgame.GetCurrentMGameName()
    local target_tokens = multiple_tokens[current_raid_name]
    if not target_tokens then
        return
    end
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
    for _, token_id in ipairs(target_tokens) do
        if has_inv_item(token_id) then
            local msg = g.lang == "Japanese" and "追加報酬券持ってるで！！" or
                            "I've got Additional Reward Tickets!"
            _G.imcAddOn.BroadMsg("NOTICE_Dm_Global_Shout", "{st55_a}{#FF8C00}" .. msg, 10)
            if _G["NICO_CHAT"] then
                for j = 1, 10 do
                    NICO_CHAT(string.format("{@st55_a}%s", msg))
                end
            end
            return 0
        end
    end
end
-- チャットフレーム改造
function mini_addons_chat_frame_drop(chat)
    g.settings.chat_xy.x = chat:GetX()
    g.settings.chat_xy.y = chat:GetY()
    mini_addons_save_settings()
end

function mini_addons_my_pos()
    local map_frame = ui.GetFrame("map")
    local map_pic = GET_CHILD(map_frame, "map")
    local my_pos = GET_CHILD(map_frame, "my")
    local x, y = GET_C_XY(my_pos)
    x = x + (my_pos:GetWidth() / 2) - map_pic:GetX()
    y = y + (my_pos:GetHeight() / 2) - map_pic:GetY()
    local map_name = session.GetMapName()
    local map_prop = geMapTable.GetMapProp(map_name)
    local worldPos = map_prop:MinimapPosToWorldPos(x, y, map_pic:GetWidth(), map_pic:GetHeight())
    LINK_MAP_POS(map_name, worldPos.x, worldPos.y)
end

function mini_addons_toggle_inventory()
    ui.ToggleFrame("inventory")
end

function mini_addons_update_chat_frame()
    local chat = ui.GetFrame("chat")
    local mainchat = GET_CHILD(chat, "mainchat")
    local edit_bg = GET_CHILD(chat, "edit_bg")
    local edit_to_bg = GET_CHILD(chat, "edit_to_bg")
    AUTO_CAST(mainchat)
    AUTO_CAST(edit_bg)
    AUTO_CAST(edit_to_bg)
    chat:RemoveChild("pos_btn")
    chat:RemoveChild("party_btn")
    chat:RemoveChild("item_btn")
    chat:SetEventScript(ui.LBUTTONUP, "mini_addons_chat_frame_drop")
    if g.settings.chat_new_btn == 0 then
        chat:Resize(chat:GetOriginalWidth(), chat:GetOriginalHeight())
        mainchat:SetGravity(ui.LEFT, ui.TOP)
        chat:SetPos(g.settings.chat_xy.x or chat:GetX(), g.settings.chat_xy.y or chat:GetY())
        return
    end
    chat:Resize(585, chat:GetOriginalHeight())
    edit_bg:Resize(567, 36)
    mainchat:Resize(585, mainchat:GetOriginalHeight())
    mainchat:SetGravity(ui.LEFT, ui.TOP)
    edit_to_bg:SetGravity(ui.LEFT, ui.TOP)
    local button_emo = GET_CHILD(chat, "button_emo")
    local base_x = button_emo:GetX() - 35
    local function create_btn(name, x_offset, img, script, w, h)
        local btn = chat:CreateOrGetControl("button", name, 0, 0, 0, 0)
        AUTO_CAST(btn)
        btn:SetPos(base_x + x_offset, 0)
        btn:SetClickSound("button_click")
        btn:SetOverSound("button_cursor_over_2")
        btn:SetAnimation("MouseOnAnim", "btn_mouseover")
        btn:SetAnimation("MouseOffAnim", "btn_mouseoff")
        btn:SetEventScript(ui.LBUTTONDOWN, script)
        if img:find("{") then
            btn:SetText(img)
            btn:SetSkinName("textbutton")
        else
            btn:SetImage(img)
        end
        btn:Resize(w, h)
        return btn
    end
    create_btn("pos_btn", 0, "button_pos_img", "mini_addons_my_pos", 39, 39)
    create_btn("party_btn", -32, "btn_partyshare", "LINK_PARTY_INVITE", 36, 36)
    create_btn("item_btn", -70, "{img sysmenu_inv 42 42}", "mini_addons_toggle_inventory", 40, 37)
    chat:SetPos(g.settings.chat_xy.x or chat:GetX(), g.settings.chat_xy.y or chat:GetY())
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
    local inv_item = session.GetInvItemByGuid(iesid)
    if inv_item then
        LINK_ITEM_TEXT(inv_item)
    end
end
-- ちょい残し　ここから
local reward_map = {"125000", "2000000", "5000000", "10000000", "18750000", "25000000", "37500000", "50000000",
                    "125000000", "175000000", "250000000", "300000000", "375000000", "625000000", "750000000",
                    "1250000000", "1750000000"}
function mini_addons_WEEKLYBOSSREWARD_REWARD_OPEN(my_frame, my_msg)
    local index = g.get_event_args(my_msg)
    local weeklyboss_reward = ui.GetFrame("weeklyboss_reward")
    local btn_reward = GET_CHILD(weeklyboss_reward, "btn_reward")
    if g.settings.keep_first == 0 or index ~= 1 or btn_reward:IsEnable() == 0 then
        local my_btn = GET_CHILD(weeklyboss_reward, "my_btn")
        if my_btn then
            weeklyboss_reward:StopUpdateScript("mini_addons_get_damage_reward")
            weeklyboss_reward:RemoveChild("my_btn")
        end
        return
    end
    local close = GET_CHILD(weeklyboss_reward, "closeBtn")
    AUTO_CAST(close)
    close:SetEventScript(ui.LBUTTONDOWN, "mini_addons_start_get_reward_stop")
    local my_btn = weeklyboss_reward:CreateOrGetControl("button", "my_btn", 315, 655, 120, 40)
    AUTO_CAST(my_btn)
    my_btn:SetText("{ol}keep first")
    my_btn:SetEventScript(ui.LBUTTONUP, "mini_addons_start_get_reward")
    local max_index = #reward_map
    my_btn:SetEventScriptArgString(ui.LBUTTONUP, reward_map[max_index])
    my_btn:SetEventScriptArgNumber(ui.LBUTTONUP, max_index)
end

function mini_addons_start_get_reward_stop(weeklyboss_reward)
    local my_btn = GET_CHILD(weeklyboss_reward, "my_btn")
    my_btn:StopUpdateScript("mini_addons_get_damage_reward")
end

function mini_addons_start_get_reward(weeklyboss_reward, my_btn, amount_str, index_num)
    local reward = GET_CHILD_RECURSIVELY(weeklyboss_reward, "REWARD_" .. index_num)
    local attr_btn = GET_CHILD(reward, "attr_btn")
    if attr_btn and attr_btn:IsEnable() == 1 then
        local week_num = weeklyboss_reward:GetUserValue("WEEK_NUM")
        weekly_boss.RequestAcceptAbsoluteReward(week_num, amount_str)
    end
    my_btn:SetUserValue("REWARD_INDEX", index_num - 1) -- 最大値から開始
    my_btn:SetUserValue("LAST_REQ_INDEX", 0)
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
        mini_addons_save_settings()
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
    local chat = ui.GetFrame("chat")
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
        mini_addons_save_settings()
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
    mini_addons_save_settings()
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
        mini_addons_save_settings()
    end
end

function mini_addons_group_chat_setting(chat, target_id)
    local group_data = g.settings.new_groups[target_id]
    if not group_data then
        return
    end
    local chat = ui.GetFrame("chat")
    AUTO_CAST(chat)
    local mainchat = chat:GetChild("mainchat")
    AUTO_CAST(mainchat)
    local edit_bg = GET_CHILD(chat, "edit_bg")
    AUTO_CAST(edit_bg)
    local button_type = GET_CHILD(chat, "button_type")
    AUTO_CAST(button_type)
    local edit_to_bg = GET_CHILD(chat, "edit_to_bg")
    AUTO_CAST(edit_to_bg)
    local title_to = GET_CHILD(edit_to_bg, "title_to")
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
end

function mini_addons_CHAT_SET_TO_TITLENAME_(chat)
    local target_id = chat:GetUserValue("ROOM_ID")
    mini_addons_now_chat_setting(target_id)
    mini_addons_group_chat_setting(chat, target_id)
end

function mini_addons_CHAT_SET_TO_TITLENAME(my_frame, my_msg)
    local chat_type, target_id = g.get_event_args(my_msg) -- グルチャはchat_type=5 強調も何故か5
    local chat = ui.GetFrame("chat")
    local edit_to_bg = GET_CHILD(chat, "edit_to_bg")
    local title_to = GET_CHILD(edit_to_bg, "title_to")
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
    chat:RunUpdateScript("mini_addons_CHAT_SET_TO_TITLENAME_", 0.05)
end

function mini_addons_change_title_name(target_id)
    local chat = ui.GetFrame("chat")
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
    local data_btn = rank_gb:CreateOrGetControl("button", "data_btn", -4, 300, 52, 52)
    AUTO_CAST(data_btn)
    data_btn:SetSkinName("None")
    data_btn:SetText("{img indun_season_tap 52 52}")
    local tooltip = g.lang == "Japanese" and "{ol}データ取得" or "{ol}Data Acquisition"
    data_btn:SetTextTooltip(tooltip)
    local data_btn_text = data_btn:CreateOrGetControl("richtext", "data_btn_text", 10, 15, 0, 20)
    AUTO_CAST(data_btn_text)
    data_btn_text:SetText("{ol}data")
    data_btn_text:SetTextTooltip(tooltip)
    data_btn_text:SetEventScript(ui.LBUTTONUP, "mini_addons_get_weekly_boss_data_context")
    data_btn:SetEventScript(ui.LBUTTONUP, "mini_addons_get_weekly_boss_data_context")
    local rank_btn = rank_gb:CreateOrGetControl("button", "rank_btn", -4, 354, 52, 52)
    AUTO_CAST(rank_btn)
    rank_btn:SetSkinName("None")
    rank_btn:SetText("{img indun_season_tap 52 52}") -- tab2
    local tooltip = g.lang == "Japanese" and "{ol}ランキング表示" or "{ol}Show Leaderboard"
    rank_btn:SetTextTooltip(tooltip)
    local rank_btn_text = rank_btn:CreateOrGetControl("richtext", "rank_btn_text", 10, 15, 0, 20)
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
                        found = true
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
            local job_cls = GetClassByType("Job", job_id)
            if job_cls then
                local job_icon = gbox:CreateOrGetControl("picture", "job_icon_" .. i .. "_" .. j, icon_x, y - 5, 25, 25)
                AUTO_CAST(job_icon)
                job_icon:SetImage(job_cls.Icon)
                job_icon:SetEnableStretch(1)
                job_icon:EnableHitTest(1)
                job_icon:SetTooltipType("adventure_book_job_info")
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
    gbox:SetScrollPos(0)
    rank_frame:ShowWindow(1)
end

function mini_addons_get_weekly_boss_data_context(frame, ctrl, str, num)
    local context = ui.CreateContextMenu("weekly_boss_data", "{ol}WEEKLY BOSS DATA", 0, 0, 0, 0)
    ui.AddContextMenuItem(context, "four weeks", "None")
    for i = 1, #base_jobids do
        local scp = string.format("mini_addons_get_weekly_boss_data_reserve(%d, 1)", base_jobids[i])
        local job_cls = GetClassByType("Job", base_jobids[i])
        ui.AddContextMenuItem(context, job_cls.Name .. " (Data takes about 120 sec)", scp)
    end
    local scp_all_four = string.format("mini_addons_get_weekly_boss_data_reserve(1, 1)")
    ui.AddContextMenuItem(context, "data for all classes (Data takes about 600 sec)", scp_all_four)
    ui.AddContextMenuItem(context, "This week", "None")
    for i = 1, #base_jobids do
        local scp = string.format("mini_addons_get_weekly_boss_data_reserve(%d, 0)", base_jobids[i])
        local job_cls = GetClassByType("Job", base_jobids[i])
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
                AUTO_CAST(classList)
                classList:SetScrollPos(0)
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
            local job_cls = GetClassByType("Job", tonumber(job_id))
            local job_name = dic.getTranslatedStr(job_cls.Name)
            local msg = g.lang == "Japanese" and job_name .. " データを取得しました" or job_name ..
                            " Data obtained"
            imcAddOn.BroadMsg("NOTICE_Dm_quest_complete", msg, 1.2)
            local result_data = {week_num, job_id, i, name, damage, job_name, is_confirmed}
            table.insert(result_tbl, result_data)
        else
            if i == 1 then
                local job_cls = GetClassByType("Job", tonumber(job_id))
                local job_name = dic.getTranslatedStr(job_cls.Name)
                local result_data = {week_num, job_id, i, "None", "0", job_name, is_confirmed}
                table.insert(result_tbl, result_data)
            end
            break
        end
    end
    if rankListBox:GetUserIValue("SHOULD_SAVE") == 1 then
        local base_id = tonumber(job_id) - (tonumber(job_id) % 1000) + 1
        local job_cls = GetClassByType("Job", tonumber(base_id))
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
                    local icon = GET_CHILD(ctrlset, "job_icon" .. j)
                    if icon then
                        icon:ShowWindow(0)
                    end
                end
                local nodata = GET_CHILD(ctrlset, "nodata_" .. i)
                if nodata then
                    nodata:ShowWindow(0)
                end
                if job_ids then
                    local rect = attr_name_text:GetMargin()
                    attr_name_text:SetMargin(rect.left, rect.top + 4, rect.right, rect.bottom)
                    for j = 1, 3 do
                        local job_id = job_ids[j]
                        if job_id then
                            local job_cls = GetClassByType("Job", job_id)
                            if job_cls then
                                local job_icon = ctrlset:CreateOrGetControl("picture", "job_icon" .. j,
                                    (attr_name_text:GetWidth() + ((j - 1) * 30)), 5, 30, 30)
                                AUTO_CAST(job_icon)
                                job_icon:SetImage(job_cls.Icon)
                                job_icon:SetEnableStretch(1)
                                job_icon:EnableHitTest(1)
                                ctrlset:EnableHitTest(1)
                                job_icon:SetTooltipType("adventure_book_job_info")
                                job_icon:SetTooltipArg(job_id, 0, 0)
                                job_icon:ShowWindow(1)
                            end
                        end
                    end
                else
                    local nodata = ctrlset:CreateOrGetControl("richtext", "nodata_" .. i, attr_name_text:GetWidth(), 10,
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
-- 製造自動セット
function mini_addons_itemcraft_item_set(item_set, slot, recipe_item_cnt_str, cls_id, current_make_count)
    imcSound.PlaySoundEvent("inven_equip")
    AUTO_CAST(slot)
    local need_count = tonumber(recipe_item_cnt_str)
    local item_name = item_set:GetUserValue("ClassName")
    local inv_item = session.GetInvItemByName(item_name)
    if true == inv_item.isLockState then
        ui.SysMsg(ClMsg("MaterialItemIsLock"))
        return 0
    end
    local next_make_count = current_make_count
    if inv_item.type == cls_id and inv_item.count >= need_count then
        local possible_count = math.floor(inv_item.count / need_count)
        if next_make_count ~= 0 then
            if next_make_count == nil or next_make_count > possible_count then
                next_make_count = possible_count
            end
        end
        session.AddItemID(inv_item:GetIESID(), need_count)
        local icon = slot:GetIcon()
        icon:SetColorTone("FFFFFFFF")
        item_set:SetUserValue("MATERIAL_IS_SELECTED", "selected")
        local number = slot:CreateOrGetControl("richtext", "number", 0, 0, slot:GetWidth(), 20)
        AUTO_CAST(number)
        number:SetText("{ol}" .. inv_item.count)
    else
        next_make_count = 0
    end
    local btn = GET_CHILD(item_set, "btn", "ui::CButton")
    if btn then
        AUTO_CAST(btn)
        btn:ShowWindow(0)
    end
    local inv_frame = ui.GetFrame("inventory")
    INVENTORY_UPDATE_ICONS(inv_frame)
    return next_make_count
end

function mini_addons_CRAFT_RECIPE_FOCUS(frame, msg)
    if g.settings.auto_craft == 0 then
        return
    end
    local page, ctrl_set = g.get_event_args(msg)
    local make_count = nil
    for i = 1, 5 do
        local item_set = GET_CHILD(ctrl_set, "EACHMATERIALITEM_" .. i)
        if not item_set then
            break
        end
        AUTO_CAST(item_set)
        local slot = GET_CHILD(item_set, "slot")
        AUTO_CAST(slot)
        DESTROY_CHILD_BYNAME(slot, "number")
        local top_frame = page:GetTopParentFrame()
        local id_space = top_frame:GetUserValue("IDSPACE")
        local recipe_cls = GetClass(id_space, ctrl_set:GetName())
        local recipe_item_cnt, inv_item_cnt, drag_recipe_item, inv_item, recipe_item_lv, inv_item_list =
            GET_RECIPE_MATERIAL_INFO(recipe_cls, i)
        local recipe_item_cnt_str = tostring(recipe_item_cnt)
        local cls_id = drag_recipe_item.ClassID
        make_count = mini_addons_itemcraft_item_set(item_set, slot, recipe_item_cnt_str, cls_id, make_count)
    end
    local top_frame = page:GetTopParentFrame()
    local up_down = GET_CHILD_RECURSIVELY(top_frame, "upDown", "ui::CNumUpDown")
    up_down:SetNumberValue(make_count or 0)
end

function mini_addons_CRAFT_START_CRAFT(frame, msg)
    if g.settings.auto_craft == 0 then
        return
    end
    local item_craft = ui.GetFrame("itemcraft")
    if item_craft then
        item_craft:RunUpdateScript("CREATE_CRAFT_ARTICLE", 8.2)
    end
end
-- パーティーメンバーの場所表示
function mini_addons_partymember_get_map()
    if g.settings.pt_info == 0 then
        return
    end
    local list = session.party.GetPartyMemberList(PARTY_NORMAL)
    local count = list:Count()
    if count == 1 then
        return
    end
    local party_info = ui.GetFrame("partyinfo")
    if not party_info then
        return
    end
    for i = 0, count - 1 do
        local party_member_info = list:Element(i)
        if party_member_info and party_member_info:GetMapID() > 0 then
            local map_cls = GetClassByType("Map", party_member_info:GetMapID())
            if map_cls then
                local party_info_ctrl_set = party_info:GetChild("PTINFO_" .. party_member_info:GetAID())
                if party_info_ctrl_set then
                    local location = party_info_ctrl_set:CreateOrGetControl("richtext", "location" .. i, 0, 0, 0, 0)
                    AUTO_CAST(location)
                    location:SetText("")
                    location:SetText(string.format("{s12}{ol}[%s-%d]", map_cls.Name, party_member_info:GetChannel() + 1))
                    location:Resize(100, 20)
                    location:SetOffset(10, 0)
                    location:ShowWindow(1)
                    local lv_box = party_info_ctrl_set:GetChild("lvbox")
                    local name_text = party_info_ctrl_set:GetChild("name_text")
                    if lv_box and name_text then
                        AUTO_CAST(lv_box)
                        AUTO_CAST(name_text)
                        local name_x = lv_box:GetX() + lv_box:GetWidth()
                        name_text:SetPos(name_x, -12)
                    end
                end
            end
        end
    end
end
-- PTメンバーの死亡と復活をNICO_CHATで流す
local last_time = 0
local cd_time = 0.5
function mini_addons_DRAW_CHAT_MSG(my_frame, my_msg)
    if g.settings.chat_recv == 0 then
        return
    end
    local now = os.clock()
    if (now - last_time) < cd_time then
        return
    end
    local groupboxname, startindex, frame = g.get_event_args(my_msg)
    local size = session.ui.GetMsgInfoSize(groupboxname)
    local chat = session.ui.GetChatMsgInfo(groupboxname, size - 1)
    local msg_type = chat:GetMsgType()
    if msg_type ~= "Battle" then
        return
    end
    local chat_option = ui.GetFrame("chat_option")
    local resurrectCheck_party = GET_CHILD_RECURSIVELY(chat_option, "resurrectCheck_party")
    AUTO_CAST(resurrectCheck_party)
    resurrectCheck_party:SetCheck(1)
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
-- ワールドマップにトークンワープのクールダウンを表示
function mini_addons_OPEN_WORLDMAP2_MINIMAP(my_frame, my_msg)
    local worldmap2_minimap = ui.GetFrame("worldmap2_minimap")
    mini_addons_TOKEN_WARP_COOLDOWN(worldmap2_minimap)
    worldmap2_minimap:RunUpdateScript("mini_addons_TOKEN_WARP_COOLDOWN", 1.0)
end

function mini_addons_TOKEN_WARP_COOLDOWN(worldmap2_minimap)
    local minimap_token_btn = GET_CHILD_RECURSIVELY(worldmap2_minimap, "minimap_token_btn")
    AUTO_CAST(minimap_token_btn)
    local is_token_state = session.loginInfo.IsPremiumState(ITEM_TOKEN)
    local image_name = ""
    local cd = GET_TOKEN_WARP_COOLDOWN()
    if is_token_state == true and cd == 0 then
        image_name = "{img worldmap2_token_gold 38 38} {@st101lightbrown_16}"
    else
        image_name = "{img worldmap2_token_gray 38 38} {@st101lightbrown_16}"
    end
    minimap_token_btn:SetText(image_name .. ScpArgMsg("TokenWarp"))
    local cdtext = worldmap2_minimap:CreateOrGetControl("richtext", "cdtext", 50, 820)
    AUTO_CAST(cdtext)
    local minutes = math.floor(cd / 60)
    local seconds = cd % 60
    local cdtimer = string.format("%d:%02d", minutes, seconds)
    cdtext:SetText("{ol}{#FFFFFF}TokenWarp CD: " .. cdtimer)
    return 1
end
-- どこでもメンバーインフォ機能
function mini_addons_add_memberinfo_menu(context, target_name)
    if g.settings.memberinfo == 1 and target_name and target_name ~= "" then
        ui.AddContextMenuItem(context, "-----", "None")
        ui.AddContextMenuItem(context, ScpArgMsg("ShowInfomation"),
            string.format("ui.Chat('/memberinfo %s')", target_name))
    end
end

function mini_addons_CHAT_RBTN_POPUP(frame, chat_ctrl)
    local top_frame = frame:GetTopParentFrame()
    local parent_frame = frame:GetParent()
    local top_frame_name = top_frame:GetName()
    local parent_frame_name = parent_frame:GetName()
    if session.world.IsIntegrateServer() == true then
        ui.SysMsg(ScpArgMsg("CantUseThisInIntegrateServer"))
        return
    end
    local target_name = chat_ctrl:GetUserValue("TARGET_NAME")
    local target_txt = chat_ctrl:GetUserValue("SENTENCE")
    if target_name == "" or GETMYFAMILYNAME() == target_name then
        return
    end
    local context = ui.CreateContextMenu("CONTEXT_CHAT_RBTN", target_name, 0, 0, 350, 100)
    ui.AddContextMenuItem(context, ScpArgMsg("WHISPER"), string.format("ui.WhisperTo('%s')", target_name))
    local str_req_add_friend_scp = string.format("friends.RequestRegister('%s')", target_name)
    ui.AddContextMenuItem(context, ScpArgMsg("ReqAddFriend"), str_req_add_friend_scp)
    local party_invite_scp = string.format("PARTY_INVITE('%s')", target_name)
    ui.AddContextMenuItem(context, ScpArgMsg("PARTY_INVITE"), party_invite_scp)
    local ctrl_name = frame:GetName()
    if GET_PRIVATE_CHANNEL_ACTIVE_STATE() == true then
        local translate_scp = string.format("REQ_TRANSLATE_TEXT('%s','%s','%s')", top_frame_name, parent_frame_name,
            ctrl_name)
        ui.AddContextMenuItem(context, ScpArgMsg("TRANSLATE"), translate_scp)
    end
    local copy_pc_id = string.format("COPY_PC_ID('%s')", target_name)
    ui.AddContextMenuItem(context, ScpArgMsg("CopyPcId"), copy_pc_id)
    local copy_pc_sentence = string.format("COPY_PC_SENTENCE('%s')", target_txt)
    ui.AddContextMenuItem(context, ScpArgMsg("CopyPcSentence"), copy_pc_sentence)
    local block_scp = string.format("CHAT_BLOCK_MSG('%s')", target_name)
    ui.AddContextMenuItem(context, ScpArgMsg("FriendBlock"), block_scp)
    ui.AddContextMenuItem(context, ScpArgMsg("Report_AutoBot"),
        string.format("REPORT_AUTOBOT_MSGBOX('%s')", target_name))
    ui.AddContextMenuItem(context, ScpArgMsg("Cancel"), "None")
    mini_addons_add_memberinfo_menu(context, target_name)
    ui.OpenContextMenu(context)
end

function mini_addons_POPUP_GUILD_MEMBER(parent, ctrl)
    local aid = parent:GetUserValue("AID")
    if aid == "None" then
        aid = ctrl:GetUserValue("AID")
    end
    local member_info = session.party.GetPartyMemberInfoByAID(PARTY_GUILD, aid)
    local is_leader = AM_I_LEADER(PARTY_GUILD)
    local my_aid = session.loginInfo.GetAID()
    local name = member_info:GetName()
    local context = ui.CreateContextMenu("PC_CONTEXT_MENU", name, 0, 0, 170, 100)
    if is_leader == 1 or HAS_KICK_CLAIM() then
        ui.AddContextMenuItem(context, ScpArgMsg("Ban"), string.format("GUILD_BAN('%s')", aid))
    end
    if is_leader == 1 and aid ~= my_aid then
        local map_name = session.GetMapName()
        if map_name == "guild_agit_1" then
            ui.AddContextMenuItem(context, ScpArgMsg("GiveGuildLeaderPermission"),
                string.format("SEND_REQ_GUILD_MASTER('%s')", name))
        end
    end
    if is_leader == 1 then
        local list = session.party.GetPartyMemberList(PARTY_GUILD)
        if list:Count() == 1 then
            ui.AddContextMenuItem(context, ScpArgMsg("Disband"), "DESTROY_GUILD()")
        end
    else
        if aid == my_aid then
            ui.AddContextMenuItem(context, ScpArgMsg("GULID_OUT"), "OUT_GUILD_CHECK()")
        end
    end
    if is_leader == 1 and aid ~= my_aid then
        local summon_skl = GetClass("Skill", "Templer_SummonGuildMember")
        ui.AddContextMenuItem(context, summon_skl.Name, string.format("SUMMON_GUILD_MEMBER('%s')", aid))
        local go_skl = GetClass("Skill", "Templer_WarpToGuildMember")
        ui.AddContextMenuItem(context, go_skl.Name, string.format("WARP_GUILD_MEMBER('%s')", aid))
    end
    ui.AddContextMenuItem(context, ScpArgMsg("WHISPER"), string.format("ui.WhisperTo('%s')", name))
    ui.AddContextMenuItem(context, ScpArgMsg("Cancel"), "None")
    mini_addons_add_memberinfo_menu(context, name)
    ui.OpenContextMenu(context)
end

function mini_addons_CONTEXT_PARTY(frame, ctrl, aid)
    local my_aid = session.loginInfo.GetAID()
    local pc_party = session.party.GetPartyInfo()
    local iam_leader = (pc_party.info:GetLeaderAID() == my_aid)
    local member_info = session.party.GetPartyMemberInfoByAID(PARTY_NORMAL, aid)
    local context = ui.CreateContextMenu("CONTEXT_PARTY", "", 0, 0, 170, 100)
    if session.world.IsIntegrateServer() == true and session.world.IsIntegrateIndunServer() == false then
        local exec_scp = string.format("ui.Chat('/changePVPObserveTarget %d 0')", member_info:GetHandle())
        ui.AddContextMenuItem(context, ScpArgMsg("Observe{PC}", "PC", member_info:GetName()), exec_scp)
        ui.OpenContextMenu(context)
        return
    end
    if aid == my_aid then
        ui.AddContextMenuItem(context, ScpArgMsg("WithdrawParty"), "OUT_PARTY()")
    elseif iam_leader == true then
        ui.AddContextMenuItem(context, ScpArgMsg("WHISPER"), string.format("ui.WhisperTo('%s')", member_info:GetName()))
        local str_req_add_friend_scp = string.format("friends.RequestRegister('%s')", member_info:GetName())
        ui.AddContextMenuItem(context, ScpArgMsg("ReqAddFriend"), str_req_add_friend_scp)
        ui.AddContextMenuItem(context, ScpArgMsg("GiveLeaderPermission"),
            string.format("GIVE_PARTY_LEADER('%s')", member_info:GetName()))
        ui.AddContextMenuItem(context, ScpArgMsg("Ban"), string.format("BAN_PARTY_MEMBER('%s')", member_info:GetName()))
        if session.world.IsDungeon() and session.world.IsIntegrateIndunServer() == true then
            local server_name = GetServerNameByGroupID(GetServerGroupID())
            local scp = string.format("SHOW_INDUN_BADPLAYER_REPORT('%s', '%s', '%s')", member_info:GetAID(),
                server_name, member_info:GetName())
            ui.AddContextMenuItem(context, ScpArgMsg("IndunBadPlayerReport"), scp)
        end
    else
        ui.AddContextMenuItem(context, ScpArgMsg("WHISPER"), string.format("ui.WhisperTo('%s')", member_info:GetName()))
        local str_req_add_friend_scp = string.format("friends.RequestRegister('%s')", member_info:GetName())
        ui.AddContextMenuItem(context, ScpArgMsg("ReqAddFriend"), str_req_add_friend_scp)
        if session.world.IsDungeon() and session.world.IsIntegrateIndunServer() == true then
            local server_name = GetServerNameByGroupID(GetServerGroupID())
            local scp = string.format("SHOW_INDUN_BADPLAYER_REPORT('%s', '%s', '%s')", member_info:GetAID(),
                server_name, member_info:GetName())
            ui.AddContextMenuItem(context, ScpArgMsg("IndunBadPlayerReport"), scp)
        end
    end
    ui.AddContextMenuItem(context, "----", "None")
    ui.AddContextMenuItem(context, ScpArgMsg("RequestFriendlyFight"),
        string.format("REQUEST_FIGHT(%d)", member_info:GetHandle()))
    ui.AddContextMenuItem(context, ScpArgMsg("Cancel"), "None")
    mini_addons_add_memberinfo_menu(context, member_info:GetName())
    ui.OpenContextMenu(context)
end

function mini_addons_SHOW_PC_CONTEXT_MENU(handle)
    if world.IsPVPMap() == true or session.colonywar.GetIsColonyWarMap() == true or IS_IN_EVENT_MAP() == true then
        return
    end
    local target_info = info.GetTargetInfo(handle)
    if target_info.IsDummyPC == 1 then
        if target_info.isSkillObj == 0 then
            mini_addons_POPUP_DUMMY(handle, target_info)
        end
        return
    end
    local pc_obj = world.GetActor(handle)
    if pc_obj == nil then
        return
    end
    if pc_obj:IsMyPC() == 1 then
        if 1 == session.IsGM() then
            local context = ui.CreateContextMenu("PC_CONTEXT_MENU", pc_obj:GetPCApc():GetFamilyName(), 0, 0, 100, 100)
            local strscp = string.format("ui.Chat('//runscp TEST_SERVPOS %d')", handle)
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
    if pc_obj:IsMyPC() == 0 and info.IsPC(pc_obj:GetHandleVal()) == 1 then
        if target_info.IsDummyPC == 1 then
            packet.DummyPCDialog(handle)
            return
        end
        local family_name = pc_obj:GetPCApc():GetFamilyName()
        local context = ui.CreateContextMenu("PC_CONTEXT_MENU", family_name, 0, 0, 170, 100)
        if session.world.IsIntegrateServer() == false then
            local str_scp = string.format("exchange.RequestChange(%d)", pc_obj:GetHandleVal())
            ui.AddContextMenuItem(context, "{img context_transaction 18 18} " .. ClMsg("Exchange"), str_scp)
            local str_whisper_scp = string.format("ui.WhisperTo('%s')", family_name)
            ui.AddContextMenuItem(context, "{img context_whisper 18 17} " .. ClMsg("WHISPER"), str_whisper_scp)
            str_scp = string.format("PARTY_INVITE('%s')", family_name)
            ui.AddContextMenuItem(context, "{img context_party_invitation 18 17} " .. ClMsg("PARTY_INVITE"), str_scp)
            if session.party.GetPartyInfo(PARTY_GUILD) ~= nil and target_info.hasGuild == false then
                str_scp = string.format("GUILD_INVITE('%s')", family_name)
                ui.AddContextMenuItem(context, "{img context_guild_invitation 18 17} " .. ClMsg("GUILD_INVITE"), str_scp)
            end
            str_scp = string.format("barrackNormal.Visit(%d)", handle)
            ui.AddContextMenuItem(context, "{img context_lodging_visit 16 17} " .. ScpArgMsg("VisitBarrack"), str_scp)
            str_scp = string.format("ui.ToggleHeaderText(%d)", handle)
            if pc_obj:GetHeaderText() ~= nil and string.len(pc_obj:GetHeaderText()) ~= 0 then
                if pc_obj:IsHeaderTextVisible() == true then
                    ui.AddContextMenuItem(context, "{img context_preface_block 18 17} " .. ClMsg("BlockTitleText"),
                        str_scp)
                else
                    ui.AddContextMenuItem(context, "{img context_preface_remove 18 17} " .. ClMsg("UnblockTitleText"),
                        str_scp)
                end
            end
        end
        if g.settings.memberinfo ~= 1 then
            local str_scp = string.format("PROPERTY_COMPARE(%d)", handle)
            ui.AddContextMenuItem(context, "{img context_look_into 18 17} " .. ScpArgMsg("Auto_SalPyeoBoKi"), str_scp)
        end
        if session.world.IsIntegrateServer() == false then
            local str_req_add_friend_scp = string.format("friends.RequestRegister('%s')", family_name)
            ui.AddContextMenuItem(context, "{img context_friend_application 18 13} " .. ScpArgMsg("ReqAddFriend"),
                str_req_add_friend_scp)
        end
        ui.AddContextMenuItem(context, "{img context_friendly_match 18 17} " .. ScpArgMsg("RequestFriendlyFight"),
            string.format("REQUEST_FIGHT(%d)", pc_obj:GetHandleVal()))
        local map_prop = session.GetCurrentMapProp()
        local map_cls = GetClassByType("Map", map_prop.type)
        if IS_TOWN_MAP(map_cls) == true then
            ui.AddContextMenuItem(context, "{img context_personal_housing 18 17} " .. ScpArgMsg("PH_SEL_DLG_2"),
                string.format("REQUEST_PERSONAL_HOUSING_WARP('%s')", pc_obj:GetPCApc():GetAID()))
        end
        if session.world.IsIntegrateServer() == false then
            local str_req_like_it_scp = string.format("SEND_PC_INFO(%d)", handle)
            if session.likeit.AmILikeYou(family_name) == true then
                ui.AddContextMenuItem(context, "{img context_like 18 17} " .. ScpArgMsg("ReqUnlikeIt"),
                    str_req_like_it_scp)
            else
                ui.AddContextMenuItem(context, "{img context_like 18 17} " .. ScpArgMsg("ReqLikeIt"),
                    str_req_like_it_scp)
            end
        end
        ui.AddContextMenuItem(context, "{img context_automatic_suspicion 16 17} " .. ScpArgMsg("Report_AutoBot"),
            string.format("REPORT_AUTOBOT_MSGBOX('%s')", family_name))
        if pc_obj:IsGuildExist() == true then
            ui.AddContextMenuItem(context,
                "{img context_inappropriate_emblem 17 17} " .. ScpArgMsg("Report_GuildEmblem"),
                string.format("REPORT_GUILDEMBLEM_MSGBOX('%s')", family_name))
        end
        if 1 == session.IsGM() then
            ui.AddContextMenuItem(context, ScpArgMsg("GM_Order_Protected"),
                string.format("REQUEST_GM_ORDER_PROTECTED('%s')", family_name))
            ui.AddContextMenuItem(context, ScpArgMsg("GM_Order_Kick"),
                string.format("REQUEST_GM_ORDER_KICK('%s')", family_name))
        end
        if session.world.IsDungeon() and session.world.IsIntegrateIndunServer() == true then
            local aid = pc_obj:GetPCApc():GetAID()
            local server_name = GetServerNameByGroupID(GetServerGroupID())
            local scp = string.format("SHOW_INDUN_BADPLAYER_REPORT('%s', '%s', '%s')", aid, server_name, family_name)
            ui.AddContextMenuItem(context, ScpArgMsg("IndunBadPlayerReport"), scp)
        end
        ui.AddContextMenuItem(context, ClMsg("Cancel"), "None")
        mini_addons_add_memberinfo_menu(context, family_name)
        ui.OpenContextMenu(context)
        return context
    end
end

function mini_addons_POPUP_DUMMY(handle, target_info)
    local context = ui.CreateContextMenu("DPC_CONTEXT", target_info.name, 0, 0, 100, 100)
    if 1 == session.IsGM() then
        local str_scp = string.format("debug.TestE(%d)", handle)
        ui.AddContextMenuItem(context, ScpArgMsg("Auto_{@st42b}NodeBoKi{/}"), str_scp)
        str_scp = string.format("ui.Chat('//killmon %d')", handle)
        ui.AddContextMenuItem(context, ScpArgMsg("Auto_JeKeo"), str_scp)
        ui.AddContextMenuItem(context, ScpArgMsg("GM_Order_Kick"),
            string.format("REQUEST_ORDER_DUMMY_KICK('%s')", handle))
    end
    if session.world.IsIntegrateServer() == false then
        local str_scp = string.format("barrackNormal.Visit(%d)", handle)
        ui.AddContextMenuItem(context, ScpArgMsg("VisitBarrack"), str_scp)
    end
    ui.AddContextMenuItem(context, ScpArgMsg("Auto_DatKi"), "")
    if g.settings.memberinfo == 1 then
        ui.AddContextMenuItem(context, "-----", "None")
        local str_scp = string.format("PROPERTY_COMPARE(%d)", handle)
        ui.AddContextMenuItem(context, ScpArgMsg("Auto_SalPyeoBoKi"), str_scp)
    end
    ui.OpenContextMenu(context)
end

function mini_addons_POPUP_FRIEND_COMPLETE_CTRLSET(parent, ctrlset)
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
        local party_invite_scp = string.format("PARTY_INVITE('%s')", info:GetFamilyName())
        ui.AddContextMenuItem(context, ScpArgMsg("PARTY_INVITE"), party_invite_scp)
        local memo_scp = string.format("FRIEND_SET_MEMO('%s')", aid)
        ui.AddContextMenuItem(context, ScpArgMsg("FriendAddMemo"), memo_scp)
    end
    local whisper_scp = string.format("ui.WhisperTo('%s')", info:GetFamilyName())
    ui.AddContextMenuItem(context, ScpArgMsg("WHISPER"), whisper_scp)
    local group_name_list = {}
    local cnt = session.friends.GetFriendCount(FRIEND_LIST_COMPLETE)
    for i = 0, cnt - 1 do
        local all_friend = session.friends.GetFriendByIndex(FRIEND_LIST_COMPLETE, i)
        local group_name = all_friend:GetGroupName()
        if group_name ~= nil and group_name ~= "" and group_name ~= "None" and group_name ~= f:GetGroupName() and
            group_name_list[group_name] == nil then
            table.insert(group_name_list, group_name)
        end
    end
    local sub_context = ui.CreateContextMenu("SUB", "", 0, 0, 0, 0)
    for k, custom_group_name in pairs(group_name_list) do
        local group_scp = string.format("FRIEND_SET_GROUPNAME(%d,'%s')", tonumber(aid), custom_group_name)
        ui.AddContextMenuItem(sub_context, custom_group_name, group_scp)
    end
    local now_group_name = f:GetGroupName()
    if now_group_name ~= nil and now_group_name ~= "" and now_group_name ~= "None" then
        local group_scp = string.format("FRIEND_SET_GROUPNAME('%s','%s')", aid, "")
        ui.AddContextMenuItem(sub_context, ScpArgMsg(FRIEND_GET_GROUPNAME(FRIEND_LIST_COMPLETE)), group_scp)
    end
    local group_scp = string.format("FRIEND_SET_GROUP('%s')", aid)
    ui.AddContextMenuItem(sub_context, ScpArgMsg("FriendAddNewGroup"), group_scp)
    group_scp = string.format("POPUP_FRIEND_GROUP_CONTEXTMENU('%s')", aid)
    ui.AddContextMenuItem(context, ScpArgMsg("FriendAddGroup"), group_scp, nil, 0, 1, sub_context)
    local block_scp = string.format("friends.RequestBlock('%s')", info:GetFamilyName())
    ui.AddContextMenuItem(context, ScpArgMsg("FriendBlock"), block_scp)
    local delete_scp = string.format("FRIEND_EXEC_DELETE('%s')", aid)
    ui.AddContextMenuItem(context, ScpArgMsg("FriendDelete"), delete_scp)
    ui.AddContextMenuItem(context, ScpArgMsg("Cancel"), "None")
    mini_addons_add_memberinfo_menu(context, info:GetFamilyName())
    ui.OpenContextMenu(context)
end
-- バウバスお知らせ
function mini_addons_NOTICE_ON_MSG_baubas(frame, msg)
    local _, _, str, _ = g.get_event_args(msg)
    if g.settings.baubas_call.use ~= 1 then
        return
    end
    local name_text = dictionary.ReplaceDicIDInCompStr("@dicID_^*$ETC_20221117_069848$*^")
    if string.find(str, "AppearFieldBoss_ep14_2_d_castle_3{name}") then
        local current_time = os.time()
        if g.last_baubas_time and (current_time - g.last_baubas_time < 60) then
            return
        end
        g.last_baubas_time = current_time
        imcSound.PlaySoundEvent("sys_tp_box_4")
        local fmt = "마법 결사의 의사당에 필드 보스[{name}]가 등장하였습니다."
        local readable_str = dictionary.ReplaceDicIDInCompStr(fmt)
        local clean_str = string.gsub(readable_str, "{name}", name_text)
        NICO_CHAT(string.format("{@st55_a}%s", clean_str))
        CHAT_SYSTEM(clean_str)
        mini_addons_NOTICE_ON_MSG_GUILD(clean_str)
    elseif string.find(str, "{name}DisappearFieldBoss") and string.find(str, "맹화의 바우바") then
        local fmt = "필드 보스[{name}]가 처치되었습니다."
        local readable_str = dictionary.ReplaceDicIDInCompStr(fmt)
        local clean_str = string.gsub(readable_str, "{name}", name_text)
        CHAT_SYSTEM(clean_str)
        mini_addons_NOTICE_ON_MSG_GUILD(clean_str)
    end
end

function mini_addons_NOTICE_ON_MSG_GUILD(clean_str)
    if g.settings.baubas_call.guild_notice == 0 then
        return
    end
    ui.Chat("/g " .. clean_str)
end

function mini_addons_baubas_call_switch(frame, ctrl, str)
    if g.settings.baubas_call.guild_notice == 0 then
        g.settings.baubas_call.guild_notice = 1
    else
        g.settings.baubas_call.guild_notice = 0
    end
    mini_addons_save_settings()
    local temp_text = g.lang == "Japanese" and ("{ol}" .. CATEGORY_BUTTONS[1].text_jp) or g.lang == "kr" and
                          ("{ol}" .. CATEGORY_BUTTONS[1].text_kr) or ("{ol}" .. CATEGORY_BUTTONS[1].text_en)
    local setting = ui.GetFrame(addon_name_lower .. "setting")
    local button = GET_CHILD_RECURSIVELY(setting, "chats")
    AUTO_CAST(button)
    mini_addons_subframe_open(frame, button, temp_text)
end
-- ブラックマーケットのお知らせ
function mini_addons_NOTICE_ON_MSG(frame, msg, str, num)
    ts(msg, str)
    if g.settings.chat_system == 1 then
        if string.find(str, "StartBlackMarketBetween") then
            return
        end
    end
    g.FUNCS["NOTICE_ON_MSG"](frame, msg, str, num)
end

function mini_addons_CHAT_TEXT_LINKCHAR_FONTSET(frame, msg)
    if not msg then
        return
    end
    if g.settings.chat_system == 1 then
        if string.find(msg, "StartBlackMarketBetween") then
            return
        end
    end
    local font_style = frame:GetUserConfig("TEXTCHAT_FONTSTYLE_LINK")
    local result_str = string.gsub(msg, "({#%x+}){img", font_style .. "{img")
    if config.GetXMLConfig("EnableChatFrameMotionEmoticon") == 0 and string.find(result_str, "{spine motion_") then
        result_str = string.gsub(msg, "{spine motion_", "{img ")
    end
    return result_str
end
-- FPS設定を手動入力
function mini_addons_SYS_OPTION_OPEN(frame, msg)
    local systemoption = ui.GetFrame("systemoption")
    local perfBox = GET_CHILD_RECURSIVELY(systemoption, "perfBox")
    local fps_edit = perfBox:CreateOrGetControl("edit", "fps_edit", 20, 200, 60, 25)
    AUTO_CAST(fps_edit)
    fps_edit:SetEventScript(ui.ENTERKEY, "mini_addons_fps_edit")
    fps_edit:SetTextTooltip("{ol}1~240")
    fps_edit:SetFontName("white_16_ol")
    fps_edit:SetTextAlign("center", "center")
    fps_edit:SetNumberMode(1)
    local fps_config_lv = config.GetPerformanceLimit()
    fps_edit:SetText("{ol}" .. fps_config_lv)
end

function mini_addons_fps_edit(parent, ctrl)
    local fps_num = tonumber(ctrl:GetText())
    local performance_limit_text = GET_CHILD(parent, "performance_limit_text")
    AUTO_CAST(performance_limit_text)
    performance_limit_text:SetTextByKey("opValue", fps_num)
    local performance_limit_slide = GET_CHILD(parent, "performance_limit_slide")
    AUTO_CAST(performance_limit_slide)
    config.SetPerformanceLimit(fps_num)
    performance_limit_slide:SetLevel(fps_num)
end
-- ボスレランキングにメンバーインフォ
function mini_addons_WEEKLY_BOSS_RANK_UPDATE_()
    if type(_G["native_lang_WEEKLY_BOSS_RANK_UPDATE"]) == "function" then
        return
    end
    local induninfo = ui.GetFrame("induninfo")
    local rankListBox = GET_CHILD_RECURSIVELY(induninfo, "rankListBox", "ui::CGroupBox")
    local cnt = session.weeklyboss.GetRankInfoListSize()
    if cnt == 0 then
        return
    end
    for i = 1, cnt do
        local ctrl_set = GET_CHILD_RECURSIVELY(rankListBox, "CTRLSET_" .. i)
        if ctrl_set then
            AUTO_CAST(ctrl_set)
            local name = GET_CHILD(ctrl_set, "attr_name_text", "ui::CRichText")
            local teamname = session.weeklyboss.GetRankInfoTeamName(i - 1)
            local info_btn = rankListBox:CreateOrGetControl("button", "info_btn_" .. i, name:GetX(), (i - 1) * 73 + 50,
                50, 25)
            AUTO_CAST(info_btn)
            info_btn:SetText("{ol}Info")
            info_btn:SetEventScript(ui.LBUTTONUP, "mini_addons_MEMBERINFO_ONCLICK")
            info_btn:SetEventScriptArgString(ui.LBUTTONUP, teamname)
            local txtGs = GET_CHILD(rankListBox, "txtGs_" .. i)
            if txtGs then
                rankListBox:RemoveChild("txtGs_" .. i)
            end
        end
    end
end

function mini_addons_MEMBERINFO_ONCLICK(frame, ctrl, teamname, num)
    ui.Chat("/memberinfo " .. teamname)
    local compare = ui.GetFrame("compare")
    compare:SetLayerLevel(102)
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
    local item = session.GetInvItemByGuid(itemIES)
    local enchant_item = session.GetInvItemByGuid(enchantGuid)
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

        ui.OpenFrame("hairenchant_option")
        return
    end
    ui.CloseFrame("hairenchant_option")
    reroll_option = ui.CreateNewFrame("notice_on_pc", addon_name_lower .. "reroll_option", 0, 0, 0, 0)
    AUTO_CAST(reroll_option)
    reroll_option:SetSkinName("test_Item_tooltip_equip")
    reroll_option:SetGravity(ui.RIGHT, ui.TOP) -- ui.GetClientInitialWidth() 1920が取れるui.GetSceneWidt()今の横幅 結構nilになったりする。信頼性低いui.GetRatioWidth()=ui.GetSceneWidth()/ui.GetClientInitialWidth()
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
    local close = reroll_option:CreateOrGetControl("button", "close", 0, 0, 30, 30)
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
                local op_name = string.format("%s %s", ClMsg("ItemRandomOptionGroupSTAT"), "{ol}" .. value.text)
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
        local RangeTable = shared_enchant_special_option.get_value_range(cls.ClassName, item_grade, item_rank, 1)
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
    local repeat_count = gbox:CreateOrGetControl("edit", "repeat_count", 330, y, 60, 30)
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
    local cancel = gbox:CreateOrGetControl("button", "cancel", 260, y, 60, 30)
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
        frame = ui.GetFrame("high_hairenchant")
    end
    frame = frame:GetTopParentFrame()
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
        repeatCount:SetTextByKey("value", string.format("%s : %d", ClMsg("REPEAT"), set_repeat_num - count))
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
    if befor_rank ~= "None" and item_rank ~= befor_rank then
        imcAddOn.BroadMsg("NOTICE_Dm_TrapPlus", "{st41b}" .. ClMsg("MagicAutoRankUpMessage"), 5.0)
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
                local propName = "HatPropName_" .. i
                local propValue = "HatPropValue_" .. i
                if obj[propValue] ~= 0 and obj[propName] ~= "None" then
                    local yes_scp = string.format("mini_addons_hair_enchant_msgbox('%s','%s','%s','%s')", "YES",
                        frame:GetName(), itemIES, enchantGuid)
                    local no_scp = string.format("mini_addons_hair_enchant_msgbox('%s','%s','%s','%s')", "NO",
                        frame:GetName(), itemIES, enchantGuid)
                    local msg = string.format(g.lang == "Japanese" and "{#FFFFFF}{ol}続けますか？" or
                                                  "{#FFFFFF}{ol}Do you want to continue? ")
                    if string.find(obj[propName], "ALLSKILL_") == nil then
                        if target_text == ScpArgMsg(obj[propName]) then
                            if margin.right == 905 then
                                reroll_option:SetMargin(margin.left, margin.top, 1150 * retio, margin.bottom)
                            end
                            repeatCount:SetTextByKey("value",
                                string.format("%s : %d", ClMsg("REPEAT"), set_repeat_num - count))
                            local befor_rank = reroll_option:GetUserValue("RANK")
                            ui.MsgBox(msg, yes_scp, no_scp)
                            return 0
                        end
                    else
                        if margin.right == 905 then
                            reroll_option:SetMargin(margin.left, margin.top, 1150 * retio, margin.bottom)
                        end
                        repeatCount:SetTextByKey("value",
                            string.format("%s : %d", ClMsg("REPEAT"), set_repeat_num - count))
                        ui.MsgBox(msg, yes_scp, no_scp)
                        return 0
                    end
                end
            end
        end
    end
    reroll_option:SetGravity(ui.RIGHT, ui.TOP)
    local margin = reroll_option:GetMargin()
    reroll_option:SetMargin(margin.left, margin.top, 905, margin.bottom)
    reroll_option:SetPos(reroll_option:GetX(), frame:GetY())
    item.DoPremiumItemEnchantchip(itemIES, enchantGuid)
    repeatCount:SetTextByKey("value", string.format("%s : %d", ClMsg("REPEAT"), set_repeat_num - count))
    reroll_option:SetUserValue("REPERT", reroll_option:GetUserIValue("REPERT") + 1)
    reroll_option:SetUserValue("STATUS", "is_repeat")
    return 1
end
-- チャットフレーム移動のワイドモニター制限解除
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
        limit_max_h = limit_max_w * ratio - limit_offset
    else
        limit_max_w = ui.GetSceneWidth() / ui.GetRatioWidth() - limit_offset
        limit_max_h = limit_max_w * ratio - limit_offset * 12
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
-- ヴァカリネを伝える
function mini_addons_vakarine_notice()
    if g.settings.vakarine == 0 then
        return
    end
    local map_name = session.GetMapName()
    local map_cls = GetClass("Map", map_name)
    local keyword = TryGetProp(map_cls, "Keyword", "None")
    local keyword_table = StringSplit(keyword, ";")
    if table.find(keyword_table, "IsRaidField") == 0 then
        return
    end
    local equip_item_list = session.GetEquipItemList()
    local equip_guid_list = equip_item_list:GetGuidList()
    local count = equip_guid_list:Count()
    local vakarine_count = 0
    local max_option = MAX_OPTION_EXTRACT_COUNT or 6
    for i = 0, count - 1 do
        local guid = equip_guid_list:Get(i)
        if guid ~= "0" then
            local equip_item = equip_item_list:GetItemByGuid(guid)
            if equip_item and equip_item:GetObject() then
                local item = GetIES(equip_item:GetObject())
                for j = 1, max_option do
                    local prop_name = "RandomOption_" .. j
                    local cls_msg = ScpArgMsg(item[prop_name])
                    if string.find(cls_msg, "vakarine_bless") then
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
-- スキル連打音消す
function mini_addons_ICON_USE(object, re_action)
    local original_func = g.FUNCS["ICON_USE"]
    if g.settings.skill_cool_sound == 0 then
        if original_func then
            original_func(object, re_action)
        end
        return
    end
    if object then
        local icon = tolua.cast(object, "ui::CIcon")
        local icon_info = icon:GetInfo()
        local category = icon_info:GetCategory()
        if category == "Skill" then
            if ICON_UPDATE_SKILL_COOLDOWN(icon) > 0 then
                return
            end
        end
    end
    if original_func then
        original_func(object, re_action)
    end
end
-- コインショップの数値を拡張
function mini_addons_EARTHTOWERSHOP_CHANGECOUNT_NUM_CHANGE(ctrlset, change)
    if g.settings.coin_count ~= 1 then
        if g.FUNCS["EARTHTOWERSHOP_CHANGECOUNT_NUM_CHANGE"] then
            g.FUNCS["EARTHTOWERSHOP_CHANGECOUNT_NUM_CHANGE"](ctrlset, change)
        end
        return
    end
    local recipe_cls = GetClass("ItemTradeShop", ctrlset:GetName())
    local edit_item_count = GET_CHILD_RECURSIVELY(ctrlset, "itemcount")
    local count_text = tonumber(edit_item_count:GetText()) or 0
    count_text = count_text + change
    local target_acc = TryGetProp(recipe_cls, "TargetAccountProperty", "None")
    local max_target_acc = TryGetProp(recipe_cls, "MaxTargetAccountProperty", 99999)
    if target_acc ~= "None" then
        local now = TryGetProp(GetMyAccountObj(), target_acc, 0)
        if now + count_text > max_target_acc then
            count_text = math.max(0, max_target_acc - now)
        end
    end
    if count_text < 0 then
        count_text = 0
    elseif count_text > 99999 then
        count_text = 99999
    end
    if recipe_cls.NeedProperty ~= "None" then
        local s_obj = GetSessionObject(GetMyPCObject(), "ssn_shop")
        local s_count = TryGetProp(s_obj, recipe_cls.NeedProperty)
        if s_count < count_text then
            count_text = s_count
        end
    end
    if recipe_cls.AccountNeedProperty ~= "None" then
        local a_obj = GetMyAccountObj()
        local s_count = TryGetProp(a_obj, recipe_cls.AccountNeedProperty)
        local frame = ui.GetFrame("earthtowershop")
        local shop_type = frame:GetUserValue("SHOP_TYPE")
        if IS_OVERBUY_ITEM(shop_type, recipe_cls, a_obj) == true then
            s_count = count_text
            if IS_EXCEED_OVERBUY_COUNT(shop_type, a_obj, recipe_cls, 1) == true then
                s_count = 0
            end
            local max_over_buy = TryGetProp(recipe_cls, "MaxOverBuyCount", 100)
            local current_over_buy = TryGetProp(a_obj, TryGetProp(recipe_cls, "OverBuyProperty", "None"), 0)
            count_text = max_over_buy - current_over_buy
        end
        if s_count < count_text then
            count_text = s_count
        end
    end
    edit_item_count:SetText(count_text)
    return count_text
end
-- 4人以下の入場確認スキップ
function mini_addons_INDUNENTER_REQ_UNDERSTAFF_ENTER_ALLOW(parent, ctrl)
    local top_frame = parent:GetTopParentFrame()
    local use_count = tonumber(top_frame:GetUserValue("multipleCount"))
    if use_count > 0 then
        local multiple_item_list = GET_INDUN_MULTIPLE_ITEM_LIST()
        for i = 1, #multiple_item_list do
            local item_name = multiple_item_list[i]
            local inv_item = session.GetInvItemByName(item_name)
            if inv_item ~= nil and inv_item.isLockState then
                ui.SysMsg(ClMsg("MaterialItemIsLock"))
                return
            end
        end
    end
    local with_match_mode = top_frame:GetUserValue("WITHMATCH_MODE")
    if top_frame:GetUserValue("AUTOMATCH_MODE") ~= "YES" and with_match_mode == "NO" then
        ui.SysMsg(ScpArgMsg("EnableWhenAutoMatching"))
        return
    end
    local indun_type = top_frame:GetUserIValue("INDUN_TYPE")
    local indun_cls = GetClassByType("Indun", indun_type)
    local min_member = TryGetProp(indun_cls, "UnderstaffEnterAllowMinMember")
    if min_member == nil then
        return
    end
    local yes_scp_str = "_INDUNENTER_REQ_UNDERSTAFF_ENTER_ALLOW()"
    local client_msg = ScpArgMsg("ReallyAllowUnderstaffMatchingWith{MIN_MEMBER}?", "MIN_MEMBER", min_member)
    if INDUNENTER_CHECK_UNDERSTAFF_MODE_WITH_PARTY(top_frame) == true then
        client_msg = ClMsg("CancelUnderstaffMatching")
    end
    if with_match_mode == "YES" then
        yes_scp_str = "ReqUnderstaffEnterAllowModeWithParty(" .. indun_type .. ")"
    end
    if g.settings.under_staff == 1 then
        if with_match_mode == "NO" then
            _INDUNENTER_REQ_UNDERSTAFF_ENTER_ALLOW()
            return
        end
    end
    ui.MsgBox(client_msg, yes_scp_str, "None")
end
-- ヴェルニケ階数を覚える
function mini_addons_INDUN_EDITMSGBOX_FRAME_OPEN(type, clmsg, desc, yes_scp, no_scp, min_number, max_number,
    default_number)
    if g.settings.velnice.use == 0 then
        if g.FUNCS["INDUN_EDITMSGBOX_FRAME_OPEN"] then
            g.FUNCS["INDUN_EDITMSGBOX_FRAME_OPEN"](type, clmsg, desc, yes_scp, no_scp, min_number, max_number,
                default_number)
        end
        return
    end
    default_number = g.settings.velnice.level
    ui.OpenFrame("indun_editmsgbox")
    local frame = ui.GetFrame("indun_editmsgbox")
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
    local yes_btn = GET_CHILD_RECURSIVELY(frame, "yesBtn", "ui::CButton")
    yes_btn:SetEventScript(ui.LBUTTONUP, "mini_addons_INDUN_EDITMSGBOX_FRAME_OPEN_YES")
    yes_btn:SetEventScriptArgString(ui.LBUTTONUP, yes_scp)
    local no_btn = GET_CHILD_RECURSIVELY(frame, "noBtn", "ui::CButton")
    no_btn:SetEventScript(ui.LBUTTONUP, "_INDUN_EDITMSGBOX_FRAME_OPEN_NO")
    no_btn:SetEventScriptArgString(ui.LBUTTONUP, no_scp)
    yes_btn:ShowWindow(1)
    no_btn:ShowWindow(1)
end

function mini_addons_SOLO_D_TIMER_UPDATE_TEXT_GAUGE(frame, msg, arg_str)
    if g.settings.velnice.use == 0 then
        return
    end
    local argument_list = StringSplit(arg_str, ";")
    local current_wave = tonumber(argument_list[3])
    local timer_frame = ui.GetFrame("solo_d_timer")
    local last_wave = timer_frame:GetUserIValue("LAST_WAVE")
    if last_wave ~= current_wave and current_wave ~= 1 then
        local remain_time_value = GET_CHILD_RECURSIVELY(timer_frame, "remaintimeValue")
        local min = remain_time_value:GetTextByKey("min")
        local sec = string.format("%02d", tonumber(remain_time_value:GetTextByKey("sec")))
        imcAddOn.BroadMsg("NOTICE_Dm_stage_start",
            string.format("{nl} {nl} {nl} {nl} {nl} {nl} {nl}{@st55_a}Round %s / 8 Fight{nl}{@st64}Remain Time %s : %s",
                current_wave - 1, min, sec), 2.0)
        timer_frame:SetUserValue("LAST_WAVE", current_wave)
    end
end

function mini_addons_INDUN_EDITMSGBOX_FRAME_OPEN_YES(parent, ctrl, arg_str, arg_num)
    local edit = GET_CHILD_RECURSIVELY(parent, "edit")
    local text = edit:GetText()
    g.settings.velnice.level = tonumber(text)
    mini_addons_save_settings()
    local scp = _G[arg_str]
    if scp ~= nil then
        local user_value = tonumber(parent:GetUserValue("user_value"))
        scp(user_value, text)
    end
    ui.CloseFrame("indun_editmsgbox")
end
-- PTバフの表示非表示切り替え
function mini_addons_buff_list_open(frame, ctrl, ctrl_text, num)
    local buff_list = ui.GetFrame(addon_name_lower .. "buff_list")
    if not buff_list then
        buff_list = ui.CreateNewFrame("notice_on_pc", addon_name_lower .. "buff_list", 0, 0, 10, 10)
        AUTO_CAST(buff_list)
        buff_list:SetSkinName("test_frame_low")
        buff_list:Resize(500, 1005)
        buff_list:SetPos(20, 30)
        buff_list:SetLayerLevel(999)
        local title_text = buff_list:CreateOrGetControl('richtext', 'title_text', 15, 15, 10, 30)
        AUTO_CAST(title_text)
        title_text:SetText("{#000000}{s20}Buff List")
        local search_edit = buff_list:CreateOrGetControl("edit", "search_edit", title_text:GetWidth() + 30, 10, 305, 38)
        AUTO_CAST(search_edit)
        search_edit:SetFontName("white_18_ol")
        search_edit:SetTextAlign("left", "center")
        search_edit:SetSkinName("inventory_serch")
        search_edit:SetEventScript(ui.ENTERKEY, "mini_addons_buff_list_search")
        local search_btn = search_edit:CreateOrGetControl("button", "search_btn", 0, 0, 40, 38)
        AUTO_CAST(search_btn)
        search_btn:SetImage("inven_s")
        search_btn:SetGravity(ui.RIGHT, ui.TOP)
        search_btn:SetEventScript(ui.LBUTTONUP, "mini_addons_buff_list_search")
        local close_button = buff_list:CreateOrGetControl('button', 'close_button', 0, 0, 20, 20)
        AUTO_CAST(close_button)
        close_button:SetImage("testclose_button")
        close_button:SetGravity(ui.RIGHT, ui.TOP)
        close_button:SetEventScript(ui.LBUTTONUP, "mini_addons_buff_list_frame_close")
    end
    local buff_list_gb = buff_list:CreateOrGetControl("groupbox", "buff_list_gb", 10, 50, 480,
        buff_list:GetHeight() - 60)
    AUTO_CAST(buff_list_gb)
    buff_list_gb:SetSkinName("bg")
    buff_list_gb:RemoveAllChild()
    local cls_list, count = GetClassList("Buff")
    local y = 0
    for i = 0, count - 1 do
        local buff_cls = GetClassByIndexFromList(cls_list, i)
        if buff_cls and buff_cls.Group1 == "Buff" and IS_PARTY_INFO_SHOWICON(buff_cls.ShowIcon) == true and
            buff_cls.ClassName ~= "TeamLevel" then
            local buff_id = buff_cls.ClassID
            local buff_name = dictionary.ReplaceDicIDInCompStr(buff_cls.Name)
            if ctrl_text == "" or (ctrl_text ~= "" and string.find(buff_name, ctrl_text)) then
                local buff_slot = buff_list_gb:CreateOrGetControl('slot', 'buffslot' .. i, 10, y + 5, 30, 30)
                AUTO_CAST(buff_slot)
                local image_name = GET_BUFF_ICON_NAME(buff_cls)
                if buff_name ~= "None" and image_name ~= "icon_None" then
                    SET_SLOT_IMG(buff_slot, image_name)
                    local icon = CreateIcon(buff_slot)
                    AUTO_CAST(icon)
                    icon:SetTooltipType('buff')
                    icon:SetTooltipArg(buff_name, buff_id, 0)
                    local buffcheck = buff_list_gb:CreateOrGetControl("checkbox", "buffcheck" .. buff_id, 45, y + 5, 30,
                        30)
                    AUTO_CAST(buffcheck)
                    buffcheck:SetCheck(g.buffs[tostring(buff_id)] or 1)
                    buffcheck:SetEventScript(ui.LBUTTONUP, "mini_addons_buff_check")
                    buffcheck:SetEventScriptArgNumber(ui.LBUTTONUP, buff_id)
                    buffcheck:SetText("{ol}" .. buff_cls.Name)
                    buffcheck:SetTextTooltip(g.lang == "Japanese" and "{ol}" .. buff_id ..
                                                 "{nl}チェックするとパーティーバフ表示" or "{ol}" ..
                                                 buff_id .. "{nl}Party buff display when checked")
                    buffcheck:AdjustFontSizeByWidth(380)
                    y = y + 35
                end
            end
        end
    end
    buff_list:ShowWindow(1)
end

function mini_addons_buff_list_frame_close(buff_list)
    ui.DestroyFrame(buff_list:GetName())
end

function mini_addons_buff_list_search(frame, ctrl, str, num)
    local search_edit = GET_CHILD_RECURSIVELY(frame, "search_edit")
    local ctrl_text = search_edit:GetText()
    if ctrl_text ~= "" then
        mini_addons_buff_list_open(frame, ctrl, ctrl_text, num)
    else
        mini_addons_buff_list_open(frame, ctrl, "", num)
    end
end

function mini_addons_buff_check(frame, ctrl, str, buff_id)
    local check = ctrl:IsChecked()
    local buff_id_str = tostring(buff_id)
    g.buffs[buff_id_str] = check
    g.save_json(g.buffs_path, g.buffs)
end

function mini_addons_ON_PARTYINFO_BUFFLIST_UPDATE(partyinfo)
    local partyinfo = ui.GetFrame("partyinfo")
    if not partyinfo then
        return
    end
    local pc_party = session.party.GetPartyInfo()
    if pc_party == nil then
        DESTROY_CHILD_BYNAME(partyinfo, "PTINFO_")
        partyinfo:ShowWindow(0)
        return
    end
    local list = session.party.GetPartyMemberList(0)
    local count = list:Count()
    local my_info = session.party.GetMyPartyObj()
    for i = 0, count - 1 do
        local party_member_info = list:Element(i)
        if geMapTable.GetMapName(party_member_info:GetMapID()) ~= "None" then
            local buff_count = party_member_info:GetBuffCount()
            local party_info_ctrl_set = partyinfo:GetChild("PTINFO_" .. party_member_info:GetAID())
            if party_info_ctrl_set then
                local buff_list_slot_set = GET_CHILD(party_info_ctrl_set, "buffList", "ui::CSlotSet")
                local debuff_list_slot_set = GET_CHILD(party_info_ctrl_set, "debuffList", "ui::CSlotSet")
                for j = 0, buff_list_slot_set:GetSlotCount() - 1 do
                    local slot = buff_list_slot_set:GetSlotByIndex(j)
                    if not slot then
                        break
                    end
                    slot:SetKeyboardSelectable(false)
                    slot:ShowWindow(0)
                end
                for j = 0, debuff_list_slot_set:GetSlotCount() - 1 do
                    local slot = debuff_list_slot_set:GetSlotByIndex(j)
                    if not slot then
                        break
                    end
                    slot:ShowWindow(0)
                end
                if buff_count <= 0 then
                    party_member_info:ResetBuff()
                    buff_count = party_member_info:GetBuffCount()
                end
                if buff_count > 0 then
                    local buff_index = 0
                    local debuff_index = 0
                    for j = 0, buff_count - 1 do
                        local buff_id = party_member_info:GetBuffIDByIndex(j)
                        local cls = GetClassByType("Buff", buff_id)
                        if cls and IS_PARTY_INFO_SHOWICON(cls.ShowIcon) == true and cls.ClassName ~= "TeamLevel" then
                            local buff_over = party_member_info:GetBuffOverByIndex(j)
                            local buff_time = party_member_info:GetBuffTimeByIndex(j)
                            local slot = nil
                            if cls.Group1 == "Buff" then
                                if g.settings.party_buff == 1 then
                                    if g.buffs[tostring(buff_id)] == 1 then
                                        slot = buff_list_slot_set:GetSlotByIndex(buff_index)
                                        buff_index = buff_index + 1
                                    end
                                else
                                    slot = buff_list_slot_set:GetSlotByIndex(buff_index)
                                    buff_index = buff_index + 1
                                end
                            elseif cls.Group1 == "Debuff" then
                                slot = debuff_list_slot_set:GetSlotByIndex(debuff_index)
                                debuff_index = debuff_index + 1
                            end
                            if slot then
                                local icon = slot:GetIcon()
                                if not icon then
                                    icon = CreateIcon(slot)
                                end
                                local handle = 0
                                if my_info then
                                    if my_info:GetMapID() == party_member_info:GetMapID() and my_info:GetChannel() ==
                                        party_member_info:GetChannel() then
                                        handle = party_member_info:GetHandle()
                                    end
                                end
                                icon:SetDrawCoolTimeText(math.floor(buff_time / 1000))
                                icon:SetTooltipType("buff")
                                icon:SetTooltipArg(tostring(handle), buff_id, "")
                                local image_name = "icon_" .. TryGetProp(cls, "Icon", "None")
                                if image_name ~= "icon_None" then
                                    icon:Set(image_name, "BUFF", buff_id, 0)
                                end
                                if buff_over > 1 then
                                    slot:SetText("{s13}{ol}{b}" .. buff_over, "count", ui.RIGHT, ui.BOTTOM, 1, 2)
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
-- チャンネルのズレを直す
function mini_addons_UPDATE_CURRENT_CHANNEL_TRAFFIC(frame)
    local curchannel = frame:GetChild("curchannel")
    local channel = session.loginInfo.GetChannel()
    local zone_inst = session.serverState.GetZoneInst(channel)
    local function set_channel_text(str, state_string)
        local spacing = (g.lang == "Japanese") and "                      " or "                                  "
        curchannel:SetTextByKey("value", str .. spacing .. state_string)
    end
    if g.settings.channel_display == 1 and zone_inst then
        local str, state_string
        if GET_PRIVATE_CHANNEL_ACTIVE_STATE() == false then
            str, state_string = GET_CHANNEL_STRING(zone_inst)
        else
            local suffix = GET_SUFFIX_PRIVATE_CHANNEL(zone_inst.mapID, zone_inst.channel + 1)
            str, state_string = GET_CHANNEL_STRING(zone_inst, suffix)
        end
        set_channel_text(str, state_string)
    else
        curchannel:SetTextByKey("value", "")
    end
end
-- インベントリイコル検索
local inven_title_name = nil
local _inven_sort_type_option = {}
local function mini_addons_is_match_or(text, keyword_list)
    if text == nil then
        return false
    end
    for _, word in ipairs(keyword_list) do
        if string.find(text, word) then
            return true
        end
    end
    return false
end

function mini_addons_INVENTORY_TOTAL_LIST_GET(frame, set_pos, is_ignore_lift_icon, inven_type_str)
    if g.settings.icor_status_search == 0 then
        if g.FUNCS["INVENTORY_TOTAL_LIST_GET"] then
            g.FUNCS["INVENTORY_TOTAL_LIST_GET"](frame, set_pos, is_ignore_lift_icon, inven_type_str)
        end
        return
    end
    local inv_frame = ui.GetFrame("inventory")
    if not inv_frame then
        return
    end
    local lift_icon = ui.GetLiftIcon()
    if not is_ignore_lift_icon then
        is_ignore_lift_icon = "NO"
    end
    if is_ignore_lift_icon ~= "NO" and lift_icon ~= nil then
        return
    end
    local my_session = session.GetMySession()
    local cid = my_session:GetCID()
    local sort_type = _inven_sort_type_option[cid] or 0
    session.BuildInvItemSortedList()
    local sorted_list = session.GetInvItemSortedList()
    local inv_item_count = sorted_list:size()
    local group = GET_CHILD_RECURSIVELY(inv_frame, "inventoryGbox", "ui::CGroupBox")
    for type_no = 1, #g_invenTypeStrList do
        if inven_type_str == nil or inven_type_str == g_invenTypeStrList[type_no] or type_no == 1 then
            local tree_box = GET_CHILD_RECURSIVELY(group, "treeGbox_" .. g_invenTypeStrList[type_no], "ui::CGroupBox")
            local tree =
                GET_CHILD_RECURSIVELY(tree_box, "inventree_" .. g_invenTypeStrList[type_no], "ui::CTreeControl")
            local group_font_name = inv_frame:GetUserConfig("TREE_GROUP_FONT")
            local tab_width = inv_frame:GetUserConfig("TREE_TAB_WIDTH")
            tree:Clear()
            tree:EnableDrawFrame(false)
            tree:SetFitToChild(true, 60)
            tree:SetFontName(group_font_name)
            tree:SetTabWidth(tab_width)
            local slot_set_name_list_cnt = ui.inventory.GetInvenSlotSetNameCount()
            for i = 1, slot_set_name_list_cnt do
                local slot_set_name = ui.inventory.GetInvenSlotSetNameByIndex(i - 1)
                ui.inventory.RemoveInvenSlotSetName(slot_set_name)
            end
            local group_name_list_cnt = ui.inventory.GetInvenGroupNameCount()
            for i = 1, group_name_list_cnt do
                local group_name = ui.inventory.GetInvenGroupNameByIndex(i - 1)
                ui.inventory.RemoveInvenGroupName(group_name)
            end
        end
    end
    local search_gbox = group:GetChild("searchGbox")
    local search_skin = GET_CHILD_RECURSIVELY(search_gbox, "searchSkin", "ui::CGroupBox")
    local edit = GET_CHILD_RECURSIVELY(search_skin, "ItemSearch", "ui::CEditControl")
    local cap = edit:GetText()
    local search_keywords = {}
    local is_searching = false
    if cap ~= "" then
        local query = string.lower(cap)
        for word in string.gmatch(query, "%S+") do
            table.insert(search_keywords, word)
        end
        if #search_keywords > 0 then
            is_searching = true
        end
    end
    local inv_item_list = {}
    local index_count = 1
    for i = 0, inv_item_count - 1 do
        local inv_item = sorted_list:at(i)
        if inv_item ~= nil then
            inv_item_list[index_count] = inv_item
            index_count = index_count + 1
        end
    end
    if sort_type == 1 then
        table.sort(inv_item_list, INVENTORY_SORT_BY_GRADE)
    elseif sort_type == 2 then
        table.sort(inv_item_list, INVENTORY_SORT_BY_WEIGHT)
    elseif sort_type == 3 then
        table.sort(inv_item_list, INVENTORY_SORT_BY_NAME)
    elseif sort_type == 4 then
        table.sort(inv_item_list, INVENTORY_SORT_BY_COUNT)
    else
        table.sort(inv_item_list, INVENTORY_SORT_BY_NAME)
    end
    if inven_title_name == nil then
        inven_title_name = {}
        local base_id_cls_list, base_id_cnt = GetClassList("inven_baseid")
        for i = 1, base_id_cnt do
            local base_id_cls = GetClassByIndexFromList(base_id_cls_list, i - 1)
            local temp_title = base_id_cls.ClassName
            if base_id_cls.MergedTreeTitle ~= "NO" then
                temp_title = base_id_cls.MergedTreeTitle
            end
            if table.find(inven_title_name, temp_title) == 0 then
                inven_title_name[#inven_title_name + 1] = temp_title
            end
        end
    end
    local cls_inv_index = {}
    for i = 1, #inven_title_name do
        local category = inven_title_name[i]
        for j = 1, #inv_item_list do
            local inv_item = inv_item_list[j]
            if inv_item ~= nil then
                local item_cls = GetIES(inv_item:GetObject())
                if item_cls.MarketCategory ~= "None" then
                    local base_id_cls = nil
                    if cls_inv_index[inv_item.invIndex] == nil then
                        base_id_cls = GET_BASEID_CLS_BY_INVINDEX(inv_item.invIndex)
                        cls_inv_index[inv_item.invIndex] = base_id_cls
                    else
                        base_id_cls = cls_inv_index[inv_item.invIndex]
                    end
                    local title_name = base_id_cls.ClassName
                    if base_id_cls.MergedTreeTitle ~= "NO" then
                        title_name = base_id_cls.MergedTreeTitle
                    end
                    if category == title_name then
                        local type_str = GET_INVENTORY_TREEGROUP(base_id_cls)
                        if item_cls ~= nil then
                            local make_slot = true
                            if is_searching then
                                make_slot = false
                                local item_name = string.lower(dictionary.ReplaceDicIDInCompStr(item_cls.Name))
                                local prefix_class_name = TryGetProp(item_cls, "LegendPrefix")
                                if prefix_class_name ~= nil and prefix_class_name ~= "None" then
                                    local prefix_cls = GetClass("LegendSetItem", prefix_class_name)
                                    local prefix_name = string.lower(dictionary.ReplaceDicIDInCompStr(prefix_cls.Name))
                                    item_name = prefix_name .. " " .. item_name
                                end
                                if mini_addons_is_match_or(item_name, search_keywords) then
                                    make_slot = true
                                else
                                    if TryGetProp(item_cls, "GroupName", "None") == "Earring" then
                                        local max_option_count =
                                            shared_item_earring.get_max_special_option_count(TryGetProp(item_cls,
                                                "UseLv", 1))
                                        for ii = 1, max_option_count do
                                            local option_name = "EarringSpecialOption_" .. ii
                                            local job = TryGetProp(item_cls, option_name, "None")
                                            if job ~= "None" then
                                                local job_cls = GetClass("Job", job)
                                                if job_cls ~= nil then
                                                    item_name = string.lower(
                                                        dictionary.ReplaceDicIDInCompStr(job_cls.Name))
                                                    if mini_addons_is_match_or(item_name, search_keywords) then
                                                        make_slot = true
                                                        break
                                                    end
                                                end
                                            end
                                        end
                                    elseif TryGetProp(item_cls, "GroupName", "None") == "Icor" then
                                        local max_option = 5
                                        for iii = 1, max_option do
                                            local item = GetIES(inv_item:GetObject())
                                            local option_name = "RandomOption_" .. iii
                                            local option = TryGetProp(item, option_name, "None")
                                            if option ~= "None" and option ~= nil then
                                                item_name =
                                                    string.lower(dictionary.ReplaceDicIDInCompStr(ClMsg(option)))
                                                if mini_addons_is_match_or(item_name, search_keywords) then
                                                    make_slot = true
                                                    break
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                            local view_option_check = 1
                            if type_str == "Equip" then
                                view_option_check = CHECK_INVENTORY_OPTION_EQUIP(item_cls)
                            elseif type_str == "Card" then
                                view_option_check = CHECK_INVENTORY_OPTION_CARD(item_cls)
                            elseif type_str == "Etc" then
                                view_option_check = CHECK_INVENTORY_OPTION_ETC(item_cls)
                            elseif type_str == "Gem" then
                                view_option_check = CHECK_INVENTORY_OPTION_GEM(item_cls)
                            end
                            if make_slot == true and view_option_check == 1 then
                                if inv_item.count > 0 and base_id_cls.ClassName ~= "Unused" then
                                    if inven_type_str == nil or inven_type_str == type_str then
                                        local tree_box = GET_CHILD_RECURSIVELY(group, "treeGbox_" .. type_str,
                                            "ui::CGroupBox")
                                        local tree = GET_CHILD_RECURSIVELY(tree_box, "inventree_" .. type_str,
                                            "ui::CTreeControl")
                                        INSERT_ITEM_TO_TREE(inv_frame, tree, inv_item, item_cls, base_id_cls)
                                    end
                                    if type_str ~= "Quest" then
                                        local tree_box_all =
                                            GET_CHILD_RECURSIVELY(group, "treeGbox_All", "ui::CGroupBox")
                                        local tree_all = GET_CHILD_RECURSIVELY(tree_box_all, "inventree_All",
                                            "ui::CTreeControl")
                                        INSERT_ITEM_TO_TREE(inv_frame, tree_all, inv_item, item_cls, base_id_cls)
                                    end
                                end
                            else
                                local is_option_applied = CHECK_INVENTORY_OPTION_APPLIED(base_id_cls)
                                if is_option_applied == 1 and cap == "" then
                                    if inven_type_str == nil or inven_type_str == type_str then
                                        local tree_box = GET_CHILD_RECURSIVELY(group, "treeGbox_" .. type_str,
                                            "ui::CGroupBox")
                                        local tree = GET_CHILD_RECURSIVELY(tree_box, "inventree_" .. type_str,
                                            "ui::CTreeControl")
                                        EMPTY_TREE_INVENTORY_OPTION_TEXT(base_id_cls, tree)
                                    end
                                    if type_str ~= "Quest" then
                                        local tree_box_all =
                                            GET_CHILD_RECURSIVELY(group, "treeGbox_All", "ui::CGroupBox")
                                        local tree_all = GET_CHILD_RECURSIVELY(tree_box_all, "inventree_All",
                                            "ui::CTreeControl")
                                        EMPTY_TREE_INVENTORY_OPTION_TEXT(base_id_cls, tree_all)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    for type_no = 1, #g_invenTypeStrList do
        local tree_box = GET_CHILD_RECURSIVELY(group, "treeGbox_" .. g_invenTypeStrList[type_no], "ui::CGroupBox")
        local tree = GET_CHILD_RECURSIVELY(tree_box, "inventree_" .. g_invenTypeStrList[type_no], "ui::CTreeControl")
        local slot_set_name_list_cnt = ui.inventory.GetInvenSlotSetNameCount()
        for i = 1, slot_set_name_list_cnt do
            local get_slot_set_name = ui.inventory.GetInvenSlotSetNameByIndex(i - 1)
            local slot_set = GET_CHILD_RECURSIVELY(tree, get_slot_set_name, "ui::CSlotSet")
            if slot_set ~= nil then
                ui.InventoryHideEmptySlotBySlotSet(slot_set)
            end
        end
        ADD_GROUP_BOTTOM_MARGIN(inv_frame, tree)
        tree:OpenNodeAll()
        tree:SetEventScript(ui.LBUTTONDOWN, "INVENTORY_TREE_OPENOPTION_CHANGE")
        INVENTORY_CATEGORY_OPENCHECK(inv_frame, tree)
        for i = 1, slot_set_name_list_cnt do
            if set_pos == "setpos" then
                local saved_pos = inv_frame:GetUserValue("INVENTORY_CUR_SCROLL_POS")
                if saved_pos == "None" then
                    saved_pos = 0
                end
                tree_box:SetScrollPos(tonumber(saved_pos))
            end
        end
    end
end
-- イベントグローバルシャウトをチャットに残す
function mini_addons_event_NOTICE_ON_MSG(frame, msg, str, num)
    local current_time = os.clock()
    if not g.mini_addons_event_notice_time or (current_time - g.mini_addons_event_notice_time < 1800) then
        g.event_maps = g.event_maps or {} -- nilガード
    else
        g.event_maps = {}
    end
    if g.mini_addons_event_notice_time and (current_time - g.mini_addons_event_notice_time < 1.0) then
        if g.mini_addons_event_last_notice_str == str then
            return
        end
    end
    local is_appear = string.find(str, "{name}AppearFieldBoss{map}")
    local is_disappear = string.find(str, "{name}DisappearFieldBoss{map}")
    if not is_appear and not is_disappear then
        return
    end
    g.mini_addons_event_notice_time = current_time
    g.mini_addons_event_last_notice_str = str
    g.event_maps = g.event_maps or {}
    local clean_str = str
    local args_part = str:match("%$%*%$(.*)#%$|#@!")
    args_part = string.gsub(args_part, "%$%*%$|%$#", ":::")
    args_part = string.gsub(args_part, "#%$|%$%*%$", ":::")
    local name, map = "", ""
    if args_part then
        _, name, _, map = args_part:match("^(.-):::(.-):::(.-):::(.*)$")
    end
    local class_name
    local map_list, cnt = GetClassList("Map")
    for i = 0, cnt - 1 do
        local map_cls = GetClassByIndexFromList(map_list, i)
        if map_cls then
            local map_name = map_cls.Name
            if dictionary.ReplaceDicIDInCompStr(map_name) == dictionary.ReplaceDicIDInCompStr(map) then
                class_name = map_cls.ClassName
                break
            end
        end
    end
    name = dictionary.ReplaceDicIDInCompStr(name)
    map = dictionary.ReplaceDicIDInCompStr(map)
    if is_appear then
        table.insert(g.event_maps, {map, class_name, name, os.time()})
    elseif is_disappear then
        for i = #g.event_maps, 1, -1 do
            if g.event_maps[i][2] == class_name then
                table.remove(g.event_maps, i)
                break
            end
        end
    end
    local fmt = ""
    if is_appear then
        fmt = "[{map}]에 필드 보스[{name}]가 등장하였습니다."
    elseif is_disappear then
        fmt = "[{map}]에 필드 보스[{name}]가 처치되었습니다."
    else
        return
    end
    clean_str = dictionary.ReplaceDicIDInCompStr(fmt)
    clean_str = string.gsub(clean_str, "{name}", name)
    clean_str = string.gsub(clean_str, "{map}", map)
    CHAT_SYSTEM(clean_str)
    if g.settings.event_shout.guild_notice == 1 then
        ui.Chat("/g " .. clean_str)
    end
    mini_addons_event_frame()
end

function mini_addons_event_frame()
    if not g.event_maps or #g.event_maps == 0 then
        ui.DestroyFrame(addon_name_lower .. "event_frame")
        return
    end
    local event_frame = ui.CreateNewFrame("notice_on_pc", addon_name_lower .. "event_frame", 0, 0, 0, 0)
    AUTO_CAST(event_frame)
    event_frame:SetSkinName("None")
    event_frame:RunUpdateScript("mini_addons_event_check_time", 5.0)
    local gbox = event_frame:CreateOrGetControl("groupbox", "gbox", 0, 0, 0, 0)
    AUTO_CAST(gbox)
    gbox:SetSkinName("bg2")
    gbox:RemoveAllChild()
    local close = gbox:CreateOrGetControl("button", "close", 0, 0, 30, 30)
    AUTO_CAST(close)
    close:SetImage("testclose_button")
    close:EnableHitTest(1)
    close:SetGravity(ui.RIGHT, ui.TOP)
    close:SetEventScript(ui.LBUTTONUP, "mini_addons_event_frame_close")
    local name_text = gbox:CreateOrGetControl("richtext", "name_text", 20, 5, 10, 20)
    AUTO_CAST(name_text)
    name_text:SetText("{ol}" .. g.event_maps[#g.event_maps][3])
    local x = name_text:GetWidth() + 60
    local y = 30
    for i, data in ipairs(g.event_maps) do
        local icon = gbox:CreateOrGetControl("picture", "icon_" .. i, 10, y, 20, 20)
        AUTO_CAST(icon)
        icon:SetImage("questinfo_return") -- GET_TOKEN_WARP_COOLDOWN() == 0 then
        icon:SetTextTooltip(g.lang == "Japanese" and "{ol}トークンワープ" or "{ol}token warp")
        icon:SetEventScript(ui.LBUTTONUP, "mini_addons_event_tokenwarp")
        icon:SetEventScriptArgString(ui.LBUTTONUP, data[2])
        icon:EnableHitTest(1)
        icon:SetAngleLoop(-3)
        icon:SetEnableStretch(1)
        local text = gbox:CreateOrGetControl("richtext", "text_" .. i, 35, y, 0, 0)
        AUTO_CAST(text)
        text:SetText("{ol}" .. data[1])
        text:EnableHitTest(0)
        y = y + 25
        local temp_x = 30 + text:GetWidth()
        if x < temp_x then
            x = temp_x
        end
    end
    local slot = gbox:CreateOrGetControl("picture", "slot", 30, y, 30, 30)
    AUTO_CAST(slot)
    local item_cls = GetClassByType('Item', 11202062)
    slot:SetImage(item_cls.Icon)
    slot:EnableHitTest(1)
    slot:SetEnableStretch(1)
    local slot_text = slot:CreateOrGetControl("richtext", "slot_text", 0, 0, 10, 10)
    AUTO_CAST(slot_text)
    slot_text:SetGravity(ui.RIGHT, ui.BOTTOM)
    slot:RunUpdateScript("mini_addons_event_check_count_change", 0.1)
    slot:SetEventScript(ui.LBUTTONUP, "mini_addons_event_check_itemuse")
    slot:SetEventScript(ui.RBUTTONUP, "mini_addons_event_check_itemuse")
    slot_text:SetEventScript(ui.LBUTTONUP, "mini_addons_event_check_itemuse")
    slot_text:SetEventScript(ui.RBUTTONUP, "mini_addons_event_check_itemuse")
    slot:SetTextTooltip(g.lang == "Japanese" and "{ol}アイテム使用" or "{ol}Item use")
    y = y + 30
    local screen_width = ui.GetClientInitialWidth()
    event_frame:SetPos(screen_width / 2 + 200, 20)
    event_frame:Resize(x, y + 10)
    gbox:Resize(x, y + 10)
    event_frame:ShowWindow(1)
end

function mini_addons_event_check_count_change(slot)
    local slot_text = GET_CHILD(slot, "slot_text")
    local inv_item = session.GetInvItemByType(11202062)
    if inv_item then
        slot_text:SetText("{ol}{s10}" .. inv_item.count)
    else
        slot_text:SetText("{ol}{s10}0")
        slot:SetColorTone("FF990000")
    end
    return 0
end

function mini_addons_event_check_itemuse(frame, ctrl)
    local inv_item_list = session.GetInvItemList()
    local guid_list = inv_item_list:GetGuidList()
    local cnt = guid_list:Count()
    for i = 0, cnt - 1 do
        local guid = guid_list:Get(i)
        local inv_item = inv_item_list:GetItemByGuid(guid)
        local item_obj = GetIES(inv_item:GetObject())
        if item_obj and item_obj.ClassID == 11202062 then
            mini_addons_event_frame()
            item.UseByGUID(guid)
            break
        end
    end
end

function mini_addons_event_check_time(frame)
    if not g.event_maps or #g.event_maps == 0 then
        ui.DestroyFrame(addon_name_lower .. "event_frame")
        return 0
    end
    local current_time = os.time()
    local changed = false
    for i = #g.event_maps, 1, -1 do
        local data = g.event_maps[i]
        if data[4] and (current_time - data[4] >= 1800) then
            table.remove(g.event_maps, i)
            changed = true
        end
    end
    if changed then
        mini_addons_event_frame()
    end
    return 1
end

function mini_addons_event_tokenwarp(frame, ctrl, class_name)
    if class_name then
        WORLDMAP2_TOKEN_WARP(class_name)
    end
end

function mini_addons_event_frame_close(frame, ctrl)
    ui.DestroyFrame(addon_name_lower .. "event_frame")
    g.event_maps = {}
end

function mini_addons_event_shout_switch(frame, ctrl, str)
    if g.settings.event_shout.guild_notice == 0 then
        g.settings.event_shout.guild_notice = 1
    else
        g.settings.event_shout.guild_notice = 0
    end
    mini_addons_save_settings()
    mini_addons_SETTING_FRAME_INIT()
end

function mini_addons_event_NOTICE_ON_MSG_test()
    local appear =
        {"!@#${name}AppearFieldBoss{map}$*$name$*$|$#(10주년) 황금 개복치#$|$*$map$*$|$#제단로#$|#@!",
         "!@#${name}AppearFieldBoss{map}$*$name$*$|$#(10주년) 황금 개복치#$|$*$map$*$|$#마법사의 탑 1층#$|#@!",
         "!@#${name}AppearFieldBoss{map}$*$name$*$|$#(10주년) 황금 개복치#$|$*$map$*$|$#라우키메 저습지#$|#@!",
         "!@#${name}AppearFieldBoss{map}$*$name$*$|$#(10주년) 황금 개복치#$|$*$map$*$|$#왕의 고원#$|#@!",
         "!@#${name}AppearFieldBoss{map}$*$name$*$|$#(10주년) 황금 개복치#$|$*$map$*$|$#미르키티 농장#$|#@!"}
    for _, str in ipairs(appear) do
        mini_addons_event_NOTICE_ON_MSG(nil, nil, str, nil)
    end
    --[[local disappear =
        {"!@#${name}DisappearFieldBoss{map}$*$name$*$|$#(10주년) 황금 개복치#$|$*$map$*$|$#왕의 고원#$|#@!",
         "!@#${name}DisappearFieldBoss{map}$*$name$*$|$#(10주년) 황금 개복치#$|$*$map$*$|$#마법사의 탑 1층#$|#@!",
         "!@#${name}DisappearFieldBoss{map}$*$name$*$|$#(10주년) 황금 개복치#$|$*$map$*$|$#미르키티 농장#$|#@!",
         "!@#${name}DisappearFieldBoss{map}$*$name$*$|$#(10주년) 황금 개복치#$|$*$map$*$|$#라우키메 저습지#$|#@!",
         "!@#${name}DisappearFieldBoss{map}$*$name$*$|$#(10주년) 황금 개복치#$|$*$map$*$|$#제단로#$|#@!"}
    for _, str in ipairs(disappear) do
        mini_addons_event_NOTICE_ON_MSG(nil, nil, str, nil)
    end]]
end
-- mini_addons_event_NOTICE_ON_MSG_test()
-- 装備錬成を自動化
function mini_addons_COMMON_EQUIP_UPGRADE_OPEN(my_frame, my_msg)
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
        if g.settings.target_status_value == nil then
            g.settings.target_status_value = 20
            mini_addons_save_settings()
        end
        local target_status_edit = frame:CreateOrGetControl("edit", "target_status_edit", 30, 680, 80, 25)
        AUTO_CAST(target_status_edit)
        target_status_edit:SetTextAlign("center", "center")
        target_status_edit:SetFontName("white_18_ol")
        target_status_edit:SetSkinName("test_weight_skin")
        target_status_edit:SetText(g.settings.target_status_value)
        target_status_edit:SetTextTooltip(g.lang == "Japanese" and "1~20の間で設定" or "Set between 1~20")
        target_status_edit:SetEventScript(ui.ENTERKEY, "mini_addons_EQUIP_UPGRADE_SET")
        target_status_edit:ShowWindow(1)
    end
end

function mini_addons_EQUIP_UPGRADE_SET(frame, ctrl, str, num)
    if not tonumber(ctrl:GetText()) then
        ui.SysMsg("Invalid value")
        return
    elseif tonumber(ctrl:GetText()) > 20 or tonumber(ctrl:GetText()) < 1 then
        ui.SysMsg("Invalid value")
        return
    else
        g.settings.target_status_value = tonumber(ctrl:GetText())
        ui.SysMsg("Set target value")
        mini_addons_save_settings()
    end
end

function mini_addons_COMMON_EQUIP_UPGRADE_PROGRESS(parent, ctrl, str, nym)
    if g.settings.status_upgrade == 0 then
        g.FUNCS["COMMON_EQUIP_UPGRADE_PROGRESS"](parent, ctrl, str, nym)
        return
    end
    local frame = parent:GetTopParentFrame()
    local slot = GET_CHILD_RECURSIVELY(frame, "slot")
    local guid = slot:GetUserValue("SET_ID")
    pc.ReqExecuteTx_Item("UPGRADE_EQUIP", guid)
    local inv_item = session.GetInvItemByGuid(guid)
    if inv_item == nil then
        return
    end
    local item_obj = GetIES(inv_item:GetObject())
    COMMON_EQUIP_UPGRADE_MAT_NUM_SET(frame, item_obj)
    local cur_rank = TryGetProp(item_obj, "UpgradeRank", 0)
    if tonumber(cur_rank) < g.settings.target_status_value then
        ReserveScript("mini_addons_COMMON_EQUIP_UPGRADE_PROGRESS_CONTINUE()", 2.0)
        return
    end
end

function mini_addons_COMMON_EQUIP_UPGRADE_PROGRESS_CONTINUE()
    local parent = ui.GetFrame("common_equip_upgrade")
    if parent:IsVisible() == 0 then
        return
    end
    mini_addons_COMMON_EQUIP_UPGRADE_PROGRESS_(parent, nil, nil, nil)
end
-- マーケット販売時に持ってる最大値を自動入力
function mini_addons_MARKET_SELL_UPDATE_REG_SLOT_ITEM(frame, msg)
    local market_sell = ui.GetFrame("market_sell")
    local edit_count = GET_CHILD_RECURSIVELY(market_sell, "edit_count")
    AUTO_CAST(edit_count)
    local slot = GET_CHILD_RECURSIVELY(market_sell, "slot_item")
    local icon = slot:GetIcon()
    if icon then
        local info = icon:GetInfo()
        local iesid = info:GetIESID()
        local inv_item = session.GetInvItemByGuid(iesid)
        if inv_item then
            edit_count:SetText(inv_item.count)
        end
    end
end
-- レイドレコードの2度呼ばれるバグ修正。正確に測れる
function mini_addons__REQ_PLAYER_CONTENTS_RECORD(frame, msg, arg_str, state)
    g.raid_msg = g.raid_msg or {}
    if g.raid_msg[msg] then
        return
    end
    g.raid_msg[msg] = true
    frame:SetUserValue("MA_arg_str", arg_str)
    frame:RunUpdateScript("mini_addons_REQ_PLAYER_CONTENTS_RECORD_", 0.3)
end

function mini_addons_REQ_PLAYER_CONTENTS_RECORD_(frame)
    local arg_str = frame:GetUserValue("MA_arg_str")
    local raid_record = ui.GetFrame("raid_record")
    if not raid_record then
        g.raid_msg = {}
        return
    end
    local token = StringSplit(arg_str, ";")
    if not token or not token[1] or not token[2] or not token[3] then
        g.raid_msg = {}
        return
    end
    local name = token[1]
    local before_str = token[2]
    local record_str = token[3]
    local function time_to_milliseconds(time_str)
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
    local before_ms = time_to_milliseconds(before_str)
    local record_ms = time_to_milliseconds(record_str)
    if not before_ms or not record_ms then
        g.raid_msg = {}
        return
    end
    local record_time = GET_CHILD_RECURSIVELY(raid_record, "textRecord")
    local my_info = GET_CHILD_RECURSIVELY(raid_record, "myInfo")
    local time = GET_CHILD_RECURSIVELY(my_info, "time")
    record_time:SetTextByKey("value", record_str)
    if before_ms >= record_ms then
        local text_new_record = GET_CHILD_RECURSIVELY(raid_record, "textNewRecord")
        text_new_record:ShowWindow(1)
        local effect_name = raid_record:GetUserConfig("DO_NEWRECORD_EFFECT")
        local effect_scale = tonumber(raid_record:GetUserConfig("NEWRECORD_EFFECT_SCALE"))
        local effect_duration = tonumber(raid_record:GetUserConfig("NEWRECORD_EFFECT_DURATION"))
        local effect_bg = GET_CHILD_RECURSIVELY(raid_record, "success_effect_bg")
        if effect_bg then
            effect_bg:PlayUIEffect(effect_name, effect_scale, "DoNewRecordEffect")
            raid_record:RunUpdateScript("_RAID_NEWRECORD_EFFECT", effect_duration)
        end
        time:SetTextByKey("value", before_str .. "→" .. record_str)
    else
        time:SetTextByKey("value", before_str)
    end
    g.raid_msg = {}
    GetPlayerRecord("callback_get_player_current_record", name)
    return 0
end
-- レイドレコードのサイズ、位置変更
function mini_addons_RAID_RECORD_INIT(my_frame, my_msg)
    if g.settings.raid_record == 0 then
        return
    end
    local raid_record = ui.GetFrame("raid_record")
    raid_record:SetSkinName("shadow_box")
    raid_record:SetEventScript(ui.LBUTTONUP, "mini_addons_raid_record_loc_save")
    raid_record:SetLayerLevel(5)
    raid_record:SetTitleBarSkin("None")
    raid_record:ShowTitleBar(0)
    raid_record:Resize(550, 260)
    raid_record:SetOffset(g.settings.reword_x, g.settings.reword_y)
    local widget_list = {{
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
    for i, data in ipairs(widget_list) do
        local widget = GET_CHILD_RECURSIVELY(raid_record, data.name)
        local name = GET_CHILD_RECURSIVELY(widget, "name")
        local time = GET_CHILD_RECURSIVELY(widget, "time")
        name:SetFontName(data.font)
        time:SetFontName(data.font)
    end
end

function mini_addons_raid_record_loc_save(raid_record)
    g.settings.reword_x = raid_record:GetX()
    g.settings.reword_y = raid_record:GetY()
    mini_addons_save_settings()
end
-- 自分のエフェクト設定を戻すIMCのバグ修正
function mini_addons_MY_EFFECT_SETTING()
    if g.settings.my_effect == 0 then
        return
    end
    local systemoption = ui.GetFrame("systemoption")
    local slide = GET_CHILD_RECURSIVELY(systemoption, "effect_transparency_my_value", "ui::CSlideBar")
    if g.settings.my_effect_value then
        config.SetMyEffectTransparency(g.settings.my_effect_value)
        slide:SetLevel(g.settings.my_effect_value)
    else
        local my_effect = config.GetMyEffectTransparency()
        config.SetMyEffectTransparency(my_effect)
    end
end

function mini_addons_MY_EFFECT_EDIT(frame, ctrl)
    local my_effect = tonumber(ctrl:GetText())
    if my_effect <= 100 and my_effect >= 1 then
        local num = math.floor(my_effect / 0.392156862745 + 0.5)
        g.settings.my_effect_value = num
        mini_addons_save_settings()
        config.SetMyEffectTransparency(num)
        ui.SysMsg("my effect changed.")
    else
        ui.SysMsg("Not a valid value.")
        return
    end
end
-- ボスのエフェクト設定を戻すIMCのバグ修正
function mini_addons_BOSS_EFFECT_SETTING()
    if g.settings.boss_effect == 0 then
        return
    end
    local systemoption = ui.GetFrame("systemoption")
    local slide = GET_CHILD_RECURSIVELY(systemoption, "effect_transparency_boss_monster_value", "ui::CSlideBar")
    if g.settings.boss_effect_value then
        config.SetBossMonsterEffectTransparency(g.settings.boss_effect_value)
        slide:SetLevel(g.settings.boss_effect_value)
    else
        local boss_effect = config.GetBossMonsterEffectTransparency()
        config.SetBossMonsterEffectTransparency(boss_effect)
    end
end

function mini_addons_BOSS_EFFECT_EDIT(frame, ctrl)
    local boss_effect = tonumber(ctrl:GetText())
    if boss_effect <= 100 and boss_effect >= 1 then
        local num = math.floor(boss_effect / 0.392156862745 + 0.5)
        g.settings.boss_effect_value = num
        mini_addons_save_settings()
        config.SetBossMonsterEffectTransparency(num)
        ui.SysMsg("boss effect changed.")
    else
        ui.SysMsg("Not a valid value.")
        return
    end
end
-- その他のエフェクト設定を戻すIMCのバグ修正
function mini_addons_OTHER_EFFECT_SETTING()
    if g.settings.other_effect == 0 then
        return
    end
    local frame = ui.GetFrame("systemoption")
    local slide = GET_CHILD_RECURSIVELY(frame, "effect_transparency_other_value", "ui::CSlideBar")
    if g.settings.other_effect_value then
        config.SetOtherEffectTransparency(g.settings.other_effect_value)
        slide:SetLevel(g.settings.other_effect_value)
    else
        local other_effect = config.GetOtherEffectTransparency()
        config.SetOtherEffectTransparency(other_effect)
    end
end

function mini_addons_OTHER_EFFECT_EDIT(frame, ctrl)
    local other_effect = tonumber(ctrl:GetText())
    if other_effect <= 100 and other_effect >= 1 then
        local num = math.floor(other_effect / 0.392156862745 + 0.5)
        g.settings.other_effect_value = num
        mini_addons_save_settings()
        config.SetOtherEffectTransparency(num)
        ui.SysMsg("other effect changed.")
    else
        ui.SysMsg("Not a valid value.")
        return
    end
end
-- エンブレム、アークの着け忘れお知らせ
function mini_addons_SHOW_INDUNENTER_DIALOG(my_frame, my_msg)
    local current_time = os.clock()
    if g.last_indun_check_time and (current_time - g.last_indun_check_time < 1.0) then
        return
    end
    g.last_indun_check_time = current_time
    if g.settings.equip_info == 0 then
        return
    end
    local indun_frame = ui.GetFrame("indunenter")
    local indun_type = indun_frame:GetUserValue("INDUN_TYPE")
    local target_indun_list = {665, 670, 675, 678, 681, 628, 687, 690, 697, 709, 712, 718, 724, 727}
    local is_target = false
    for i = 1, #target_indun_list do
        if tostring(target_indun_list[i]) == tostring(indun_type) then
            is_target = true
            break
        end
    end
    if not is_target then
        return
    end
    local equip_item_list = session.GetEquipItemList()
    local cnt = equip_item_list:Count()
    for i = 0, cnt - 1 do
        local equip_item = equip_item_list:GetEquipItemByIndex(i)
        local spot_name = item.GetEquipSpotName(equip_item.equipSpot)
        local iesid = tostring(equip_item:GetIESID())
        if tostring(spot_name) == "SEAL" and tonumber(iesid) == 0 then
            if g.lang == "Japanese" then
                imcAddOn.BroadMsg("NOTICE_Dm_Global_Shout",
                    "{st55_a}{#FF8C00}エンブレム装備してないけど{nl}ええんか？", 3.0)
            else -- You don't have an emblem equipped. {nl} Is this okay?
                imcAddOn.BroadMsg("NOTICE_Dm_Global_Shout",
                    "{st55_a}{#FF8C00}You don't have an emblem equipped{nl}Is this okay?", 3.0)
            end
            break
        elseif tostring(spot_name) == "ARK" and tonumber(iesid) == 0 then
            if g.lang == "Japanese" then
                imcAddOn.BroadMsg("NOTICE_Dm_Global_Shout",
                    "{st55_a}{#FF8C00}アーク装備してないけど{nl}ええんか？", 3.0)
            else
                imcAddOn.BroadMsg("NOTICE_Dm_Global_Shout",
                    "{st55_a}{#FF8C00}You don't have an ark equipped{nl}Is this okay?", 3.0)
            end
            break
        end
    end
end
-- 自動マッチのレイヤーを下げる
function mini_addons_INDUNENTER_AUTOMATCH_TYPE(my_frame, my_msg)
    local indunenter = ui.GetFrame("indunenter")
    if g.settings.automatch_layer == 1 then
        indunenter:SetLayerLevel(97)
    elseif g.settings.automatch_layer == 0 then
        indunenter:SetLayerLevel(100)
    end
end
-- 死んだ時の選択肢を動かす
function mini_addons_RESTART_HERE()
    if g.settings.restart_move == 0 then
        return
    end
    local restart_contents = ui.GetFrame("restart_contents")
    if restart_contents:IsVisible() == 1 then
        restart_contents:EnableHittestFrame(1)
        restart_contents:EnableMove(1)
    end
    local restart = ui.GetFrame("restart")
    if restart:IsVisible() == 1 then
        restart:EnableHittestFrame(1)
        restart:EnableMove(1)
    end
end
-- 死んだ時のマウス位置制御
function mini_addons_RESTART_CONTENTS_ON_HERE(my_frame, my_msg)
    if g.settings.restart_move == 0 then
        return
    end
    local restart_contents = ui.GetFrame("restart_contents")
    local btn_restart = GET_CHILD_RECURSIVELY(restart_contents, "btn_restart_" .. 1)
    local item_width = btn_restart:GetWidth()
    local item_height = btn_restart:GetHeight()
    local x, y = GET_SCREEN_XY(btn_restart + item_width / 2, btn_restart + item_height / 2)
    mouse.SetPos(x, y)
end
-- コロニー死んだ時に30秒タイマー動かないバグ修正
function mini_addons_RESTART_ON_MSG(frame, msg, str, num)
    if not g.settings.restart_colony or g.settings.restart_colony ~= 1 or msg ~= "RESTART_HERE" or
        (BitGet(num, 12) ~= 1 and BitGet(num, 14) ~= 1) then
        if g.FUNCS["RESTART_ON_MSG"] then
            g.FUNCS["RESTART_ON_MSG"](frame, msg, str, num)
        end
        return
    end
    local restart = ui.GetFrame("restart")
    restart:ShowWindow(1)
    for i = 1, 5 do
        local res_btn = GET_CHILD(restart, "restart" .. i .. "btn", "ui::CButton")
        if res_btn then
            res_btn:ShowWindow(BitGet(num, i))
        end
    end
    local mystic_btn = GET_CHILD(restart, "restart8btn", "ui::CButton")
    if mystic_btn then
        if BitGet(num, 14) == 1 then
            mystic_btn:ShowWindow(1)
        else
            mystic_btn:ShowWindow(0)
        end
    end
    if restart:GetUserIValue("COLONY_TIMER_RUNNING") ~= 1 then
        restart:SetUserValue("COLONY_TIMER_RUNNING", 1) -- 実行中フラグを立てる
        local res_btn_6 = GET_CHILD(restart, "restart6btn", "ui::CButton")
        if res_btn_6 then
            res_btn_6:ShowWindow(1)
            local text = "{@st66b}" .. ScpArgMsg("ReturnCity{SEC}", "SEC", 30) .. "{/}"
            res_btn_6:SetText(text)
        end
        g.colony_wait_time = 30
        restart:RunUpdateScript("Mini_addons_COLONY_WAR_RESTART_UPDATE", 1)
        AUTORESIZE_RESTART(restart)
        local res_btn_9 = GET_CHILD(restart, "restart9btn", "ui::CButton")
        if res_btn_9 then
            res_btn_9:ShowWindow(0)
        end
        local res_btn_10 = GET_CHILD(restart, "restart10btn", "ui::CButton")
        if res_btn_10 then
            res_btn_10:ShowWindow(0)
        end
        local restart_wait = GET_CHILD(restart, "restart_wait")
        if restart_wait then
            AUTO_CAST(restart_wait)
            restart_wait:ShowWindow(0)
        end
        restart:ShowWindow(1)
    end
end

function mini_addons_COLONY_WAR_RESTART_UPDATE(restart)
    local res_btn = GET_CHILD(restart, "restart6btn", "ui::CButton")
    if not res_btn then
        return 0
    end
    g.colony_wait_time = g.colony_wait_time - 1
    if g.colony_wait_time < 0 then
        g.colony_wait_time = 0
    end
    local text = "{@st66b}" .. ScpArgMsg("ReturnCity{SEC}", "SEC", g.colony_wait_time) .. "{/}"
    res_btn:SetText(text)
    if g.colony_wait_time <= 0 then
        restart:SetUserValue("COLONY_TIMER_RUNNING", 0)
        return 0
    end
    if _G["COLONY_WAR_RESTART_BY_MYSTIC_UPDATE"] then
        COLONY_WAR_RESTART_BY_MYSTIC_UPDATE(restart)
    end
    return 1
end
-- ダイアログ制御系
function mini_addons_DIALOG_CHANGE_SELECT(frame, msg, str, num)
    if g.settings.dialog_ctrl == 0 then
        return
    end
    local dialogselect = ui.GetFrame("dialogselect")
    if str == "WAREHOUSE_DLG" or str == "ORSHA_WAREHOUSE_DLG" or str == "WAREHOUSE_FEDIMIAN_DLG" and msg ==
        "DIALOG_CHANGE_SELECT" then -- 倉庫
        session.SetSelectDlgList()
        ui.OpenFrame("dialogselect")
        DialogSelect_index = 2
        local btn2 = GET_CHILD_RECURSIVELY(dialogselect, "item2Btn")
        local x, y = GET_SCREEN_XY(btn2)
        mouse.SetPos(x + 190, y)
        return
    end
    if str == "NPC_PERSONAL_HOUSING_MANAGER_DLG_2" then -- 住居クポル
        session.SetSelectDlgList()
        ui.OpenFrame("dialogselect")
        control.DialogItemSelect(1)
    elseif string.find(str, "PERSONAL_HOUSING_POINT_CHECK_MSG_1") then
        session.SetSelectDlgList()
        ui.OpenFrame("dialogselect")
        control.DialogItemSelect(1)
    elseif string.find(str, "PH_POINT_SHOP_DLG_SEL_1") then
        session.SetSelectDlgList()
        ui.CloseFrame("dialog")
        ui.OpenFrame("dialogselect")
        DialogSelect_index = 3
        local btn = GET_CHILD_RECURSIVELY(dialogselect, "item3Btn")
        local x, y = GET_SCREEN_XY(btn)
        mouse.SetPos(x + 190, y)
        return
    end
    if str == "Goddess_Raid_Rozethemiserable_Start_Npc_Dlg" or str == "Goddess_Raid_Spreader_Start_Npc_DLG1" or str ==
        "Goddess_Raid_Jellyzele_Start_Npc_DLG1" or str == "EP14_Raid_Delmore_NPC_DLG1" or str ==
        "Goddess_Raid_DespairIsland_Start_Npc_Dlg" then
        session.SetSelectDlgList()
        ui.CloseFrame("dialog")
        ui.OpenFrame("dialogselect")
        DialogSelect_index = 2
        local btn = GET_CHILD_RECURSIVELY(dialogselect, "item2Btn")
        local x, y = GET_SCREEN_XY(btn)
        mouse.SetPos(x + 190, y)
        return
    end
    local pc = GetMyPCObject()
    local cur_map = GetZoneName(pc)
    if (str == "Legend_Raid_Giltine_ENTER_MSG" and cur_map == "raid_dcapital_108") then
        session.SetSelectDlgList()
        ui.CloseFrame("dialog")
        ui.OpenFrame("dialogselect")
        DialogSelect_index = 2
        local btn = GET_CHILD_RECURSIVELY(dialogselect, "item2Btn")
        local x, y = GET_SCREEN_XY(btn)
        mouse.SetPos(x + 190, y)
        return
    end
end
-- ファミリーネームからログインネームへ変換
function mini_addons_PCNAME_REPLACE(frame, msg)
    if g.settings.pc_name == 0 then
        return
    end
    local headsupdisplay = ui.GetFrame("headsupdisplay")
    local name_text = GET_CHILD_RECURSIVELY(headsupdisplay, "name_text")
    local login_name = session.GetMySession():GetPCApc():GetName()
    if name_text:GetText() ~= "{@st41}" .. tostring(login_name) then
        name_text:SetText("{@st41}" .. tostring(login_name))
    end
end
-- オートキャスティングをキャラ毎に設定
function mini_addons_CONFIG_ENABLE_AUTO_CASTING(my_frame, my_msg)
    local parent, ctrl = g.get_event_args(my_msg)
    local enable = ctrl:IsChecked()
    g.settings.auto_casting[g.cid] = enable
    mini_addons_save_settings()
end

function mini_addons_SET_ENABLE_AUTO_CASTING()
    if g.settings.auto_cast == 0 then
        return
    end
    local systemoption = ui.GetFrame("systemoption")
    local Check_EnableAutoCasting = GET_CHILD_RECURSIVELY(systemoption, "Check_EnableAutoCasting", "ui::CCheckBox")
    Check_EnableAutoCasting:SetCheck(g.settings.auto_casting[g.cid] or 1)
    config.SetEnableAutoCasting(g.settings.auto_casting[g.cid] or 1)
    config.SaveConfig()
end
-- チャンネル切替フレーム
function mini_addons_GAME_START_CHANNEL_LIST()
    if g.settings.channel_info == 0 then
        return
    end
    mini_addons_POPUP_CHANNEL_LIST()
    local sysmenu = ui.GetFrame("sysmenu")
    if sysmenu then
        local system = GET_CHILD(sysmenu, "system")
        if system then
            if system:HaveUpdateScript("mini_addons_POPUP_CHANNEL_LIST") == false then
                system:RunUpdateScript("mini_addons_POPUP_CHANNEL_LIST", 2)
            end
        end
    end
end

function mini_addons_POPUP_CHANNEL_LIST()
    local zone_insts = session.serverState.GetMap()
    local frame_name = "mini_addons_channel"
    if not zone_insts then
        local frame = ui.GetFrame(frame_name)
        if frame then
            frame:ShowWindow(0)
        end
        g.zone_insts = false
        return 0
    else
        g.zone_insts = true
    end
    local frame = ui.CreateNewFrame("notice_on_pc", frame_name, 10, 10, 10, 10)
    AUTO_CAST(frame)
    frame:RemoveAllChild()
    frame:SetSkinName("None")
    frame:SetTitleBarSkin("None")
    frame:EnableHittestFrame(1)
    frame:EnableMove(1)
    if not g.settings.frame_X then
        g.settings.frame_X = 1500
        g.settings.frame_Y = 385
        mini_addons_save_settings()
    end
    if not g.settings.ch_frame_size then
        g.settings.ch_frame_size = 40
        mini_addons_save_settings()
    end
    local map_frame = ui.GetFrame("map")
    local screen_width = map_frame:GetWidth()
    local x = g.settings.frame_X
    local y = g.settings.frame_Y
    if x > 1920 and screen_width <= 1920 then
        x = 1500
        y = 385
    end
    frame:SetPos(x, y)
    frame:SetEventScript(ui.LBUTTONUP, "mini_addons_channelframe_move")
    frame:SetEventScript(ui.RBUTTONUP, "mini_addons_ch_frame_resize")
    local title = frame:CreateOrGetControl("richtext", "title", 5, 0)
    title:SetText("{ol}{s12}channel info")
    if zone_insts:NeedToCheckUpdate() == true then
        app.RequestChannelTraffics()
    end
    local cnt = zone_insts:GetZoneInstCount()
    local current_channel = session.loginInfo.GetChannel()
    local size = g.settings.ch_frame_size
    for i = 0, cnt - 1 do
        local zone_inst = zone_insts:GetZoneInstByIndex(i)
        local pc_count = zone_inst.pcCount
        local btn = frame:CreateOrGetControl("button", "slot" .. i, i * size + 5, 15, size, size)
        AUTO_CAST(btn)
        btn:SetEventScript(ui.LBUTTONUP, "mini_addons_ch_change")
        btn:SetEventScriptArgString(ui.LBUTTONUP, i)
        if i == current_channel then
            btn:SetSkinName("test_pvp_btn")
        end
        local color_tag = ""
        if tonumber(pc_count) >= 50 then
            color_tag = "{#FF0000}" -- 赤
        elseif tonumber(pc_count) >= 20 then
            color_tag = "{#FFCC33}" -- 黄
        else
            color_tag = "" -- デフォルト(白)
        end
        local text = string.format("{ol}{s12}ch%d{nl}{s16}%s%d", i + 1, color_tag, pc_count)
        btn:SetText(text)
    end
    frame:Resize(cnt * size + 20, 60)
    frame:ShowWindow(1)
    return 1
end

function mini_addons_channelframe_move(frame)
    g.settings.frame_X = frame:GetX()
    g.settings.frame_Y = frame:GetY()
    mini_addons_save_settings()
end

function mini_addons_ch_frame_resize(frame, btn, str, num)
    if g.settings.ch_frame_size == 40 then
        g.settings.ch_frame_size = 50
    else
        g.settings.ch_frame_size = 40
    end
    mini_addons_save_settings()
    mini_addons_POPUP_CHANNEL_LIST()
end

function mini_addons_ch_change(frame, ctrl, str, num)
    local channel = tonumber(str) -- 0が1chらしい
    RUN_GAMEEXIT_TIMER("Channel", str)
end
-- ペットコマンド制御
function mini_addons_SHOW_PET_RINGCOMMAND(my_frame, my_msg)
    local actor = g.get_event_args(my_msg)
    if g.settings.pet_ring == 1 then
        return
    else
        g.FUNCS["SHOW_PET_RINGCOMMAND"](actor)
    end
end
-- レリックゲージ
function mini_addons_CHARBASE_RELIC()
    if g.settings.relic_gauge == 0 then
        return
    end
    if HEADSUPDISPLAY_OPTION.relic_equip == 0 then
        return
    end
    local charbaseinfo1_my = ui.GetFrame("charbaseinfo1_my")
    local pcRelicGauge = charbaseinfo1_my:CreateOrGetControl("gauge", "pcRelicGauge", -1, 54, 104, 11)
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
-- パーティー情報フレームを小さくする
function mini_addons_PARTY_BUFFLIST_UPDATE(frame, msg)
    local party_info = ui.GetFrame("partyinfo")
    local list = session.party.GetPartyMemberList(PARTY_NORMAL)
    local member_count = list:Count()
    local display_count = member_count - 1
    if display_count < 0 then
        display_count = 0
    end
    if g.settings.party_info == 0 then
        party_info:Resize(560, display_count * 100 + 60)
        party_info:SetLayerLevel(50)
        return
    end
    local max_buff_width = 0
    local slot_size = 25 -- スロット1つの幅
    for i = 0, member_count - 1 do
        local party_member_info = list:Element(i)
        local party_info_ctrl_set = party_info:GetChild('PTINFO_' .. party_member_info:GetAID())
        if party_info_ctrl_set then
            local current_member_buffs = 0
            local buff_list = GET_CHILD(party_info_ctrl_set, "buffList", "ui::CSlotSet")
            if buff_list then
                for j = 0, buff_list:GetSlotCount() - 1 do
                    local slot = buff_list:GetSlotByIndex(j)
                    if slot and slot:IsVisible() == 1 then
                        local icon = slot:GetIcon()
                        if icon then
                            current_member_buffs = current_member_buffs + 1
                        end
                    end
                end
            end
            local debuff_list = GET_CHILD(party_info_ctrl_set, "debuffList", "ui::CSlotSet")
            if debuff_list then
                for j = 0, debuff_list:GetSlotCount() - 1 do
                    local slot = debuff_list:GetSlotByIndex(j)
                    if slot and slot:IsVisible() == 1 then
                        local icon = slot:GetIcon()
                        if icon then
                            current_member_buffs = current_member_buffs + 1
                        end
                    end
                end
            end
            local needed_width = current_member_buffs * slot_size
            if needed_width > max_buff_width then
                max_buff_width = needed_width
            end
        end
    end
    party_info:Resize(250 + max_buff_width, display_count * 100 + 60)
    party_info:SetLayerLevel(0)
end

--[[function mini_addons_partyinfo_resize(partyinfo, ctrl, str, num)
    local list = session.party.GetPartyMemberList(PARTY_NORMAL)
    local count = list:Count() - 1
    if count < 0 then
        count = 0
    end
    if partyinfo:GetWidth() == 80 then
        partyinfo:Resize(560, count * 100 + 60)
    else
        partyinfo:Resize(80, count * 100 + 60)
    end
end]]
-- EP13ショップを街で開ける
function mini_addons_REPUTATION_SHOP_OPEN()
    local inventory = ui.GetFrame("inventory")
    local inventory_accpropinv = GET_CHILD_RECURSIVELY(inventory, "inventory_accpropinv")
    AUTO_CAST(inventory_accpropinv)
    if g.get_map_type() == "City" then
        inventory_accpropinv:SetEventScript(ui.RBUTTONUP, "mini_addons_REPUTATION_SHOP_OPEN_context")
        inventory_accpropinv:SetEventScript(ui.RBUTTONDOWN, "mini_addons_reputation_shop_close")
    else
        inventory_accpropinv:SetEventScript(ui.RBUTTONUP, "None")
        inventory_accpropinv:SetEventScript(ui.RBUTTONDOWN, "None")
    end
end

function mini_addons_ON_REQUEST_REPUTATION_SHOP_OPEN(shop_type)
    REPUTATION_SHOP_SET_SHOPTYPE(shop_type)
    ui.OpenFrame("reputation_shop")
end

function mini_addons_REPUTATION_SHOP_OPEN_context(frame, ctrl, str, num)
    local context = ui.CreateContextMenu("select_shop", "EP13 Shop List ", 0, -200, 0, 0)
    local shop_tbl = {{
        name = "REPUTATION_ep13_f_siauliai_1",
        id = 11209,
        text = ClMsg("MonInfo_RaceType_Velnias"),
        box = ""
    }, {
        name = "REPUTATION_ep13_f_siauliai_2",
        id = 11210,
        text = ClMsg("MonInfo_RaceType_Widling"),
        box = ""
    }, {
        name = "REPUTATION_ep13_f_siauliai_3",
        id = 11211,
        text = ClMsg("MonInfo_RaceType_Klaida"),
        box = GetClassByType("Item", 640530).Name
    }, {
        name = "REPUTATION_ep13_f_siauliai_4",
        id = 11212,
        text = ClMsg("MonInfo_RaceType_Paramune"),
        box = GetClassByType("Item", 640531).Name
    }, {
        name = "REPUTATION_ep13_f_siauliai_5",
        id = 11213,
        text = ClMsg("MonInfo_RaceType_Forester"),
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
        ui.ToggleFrame("inventory")
    end
end
-- ヴェルニケ自動受取り
function mini_addons_SOLODUNGEON_RANKINGPAGE_GET_REWARD()
    if g.settings.solodun_reward == 0 then
        return
    end
    if g.solodun_reward then
        return
    end
    soloDungeonClient.ReqSoloDungeonReward()
    g.solodun_reward = true
end
-- ボスレ報酬自動受取り
function mini_addons_WEEKLY_BOSS_REWARD()
    if g.settings.weekly_boss_reward == 0 then
        return
    end
    if session.weeklyboss.GetNowWeekNum() == 0 then
        weekly_boss.RequestWeeklyBossNowWeekNum()
    end
    local week_num = WEEKLY_BOSS_RANK_WEEKNUM_NUMBER()
    if g.settings.reward_switch == 1 then
        week_num = WEEKLY_BOSS_RANK_WEEKNUM_NUMBER() - 1
    end
    if week_num ~= 0 then
        weekly_boss.RequestAcceptAbsoluteRewardAll(week_num)
        if not g.wbreward then
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
            g.index = 0
            indun_info:RunUpdateScript("mini_addons_WEEKLY_BOSS_RANK_REWARD", 1.5)
        end
    end
end

function mini_addons_WEEKLY_BOSS_RANK_REWARD(indun_info)
    local classtype_tab = GET_CHILD_RECURSIVELY(indun_info, "classtype_tab")
    AUTO_CAST(classtype_tab)
    classtype_tab:SelectTab(g.index)
    if g.index <= 4 then
        WEEKLY_BOSS_DATA_REUQEST()
        classtype_tab:RunUpdateScript("mini_addons_WEEKLY_BOSS_RANK_GET_REWARD", 1.0)
        return 1
    else
        indun_info:ShowWindow(0)
        indun_info:Resize(1095, 610)
        indun_info:StopUpdateScript("mini_addons_WEEKLY_BOSS_RANK_REWARD")
        g.wbreward = true
        return 0
    end
end

function mini_addons_WEEKLY_BOSS_RANK_GET_REWARD(classtype_tab)
    local week_num = WEEKLY_BOSS_RANK_WEEKNUM_NUMBER()
    local myrank = session.weeklyboss.GetMyRankInfo(week_num)
    local indun_info = ui.GetFrame("induninfo")
    local classtype_tab = GET_CHILD_RECURSIVELY(indun_info, "classtype_tab")
    AUTO_CAST(classtype_tab)
    if myrank ~= 0 and myrank <= 100 then
        weekly_boss.RequestAccpetRankingReward(week_num, myrank)
        indun_info:ShowWindow(0)
        indun_info:Resize(1095, 610)
        indun_info:StopUpdateScript("mini_addons_WEEKLY_BOSS_RANK_REWARD")
        classtype_tab:StopUpdateScript("mini_addons_WEEKLY_BOSS_RANK_GET_REWARD")
        g.wbreward = true
        return
    elseif myrank ~= 0 and myrank > 100 then
        indun_info:ShowWindow(0)
        indun_info:Resize(1095, 610)
        indun_info:StopUpdateScript("mini_addons_WEEKLY_BOSS_RANK_REWARD")
        classtype_tab:StopUpdateScript("mini_addons_WEEKLY_BOSS_RANK_GET_REWARD")
        g.wbreward = true
        return
    end
    g.index = g.index + 1
end

function mini_addons_WEEKLY_BOSS_REWARD_SWITCH(frame, ctrl, str, num)
    if g.settings.reward_switch == 1 then
        g.settings.reward_switch = 0
        ctrl:SetText(g.lang == "Japanese" and "{ol}今週分" or "{ol}this week")
    else
        g.settings.reward_switch = 1
        ctrl:SetText(g.lang == "Japanese" and "{ol}先週分" or "{ol}last week")
    end
    mini_addons_save_settings()
    mini_addons_SETTING_FRAME_INIT(frame, ctrl, "true", num)
end
-- 街のラガナを非表示
function mini_addons_ragana_remove_timer()
    if g.settings.goodbye_ragana == 0 then
        return
    end
    local mini_addons = ui.GetFrame("mini_addons")
    mini_addons:RunUpdateScript("mini_addons_ragana_remove", 1.0)
end

function mini_addons_ragana_remove(mini_addons)
    local selected_objects, selected_objects_count = SelectObject(GetMyPCObject(), 1000, "ALL")
    for i = 1, selected_objects_count do
        local handle = GetHandle(selected_objects[i])
        if handle then
            if info.IsPC(handle) ~= 1 then
                local npc_name = world.GetActor(handle):GetName()
                if npc_name == "[마신의 유혹]{nl}마신 라가나의 환영" then
                    world.Leave(handle, 0.0)
                    return 0
                end

            end
        end
    end
    return 1
end
-- RPチャージを補完
function mini_addons_rp_check()
    if g.settings.rp_charge == 0 then
        return
    end
    local openingameshopbtn = ui.GetFrame("openingameshopbtn")
    local open_openingameshopbtn = GET_CHILD(openingameshopbtn, "open_openingameshopbtn")
    AUTO_CAST(open_openingameshopbtn)
    open_openingameshopbtn:RunUpdateScript("mini_addons_rp_check_", 0.1)
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
    local item_names = {"misc_Ectonite", "misc_Ectonite_Care"}
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
    item.DialogTransaction("RELIC_CHARGE_RP", result_list)
    frame:StopUpdateScript("mini_addons_rp_check_")
    frame:RunUpdateScript("mini_addons_rp_check_end", 0.1)
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
-- 町でマーケットボタンを常に表示
function mini_addons_MINIMIZED_TOTAL_SHOP_BUTTON_CLICK()
    local market_button = ui.GetFrame("minimized_market_button")
    if g.settings.market_display == 1 and market_button:IsVisible() == 0 then
        MINIMIZED_TOTAL_SHOP_BUTTON_CLICK()
    end
end
-- 傭兵団コイン、女神コイン、王国再建団コインを取得時、自動で使用
function mini_addons_INV_ICON_USE(mini_addons)
    if g.settings.coin_use == 0 then
        return
    end
    if g.get_map_type() ~= "City" then
        return
    end
    local god_protection = ui.GetFrame("godprotection")
    if god_protection:IsVisible() == 1 then
        return
    end
    local inv_item_list = session.GetInvItemList()
    local guid_list = inv_item_list:GetGuidList()
    local cnt = guid_list:Count()
    for i = 0, cnt - 1 do
        local guid = guid_list:Get(i)
        local inv_item = inv_item_list:GetItemByGuid(guid)
        local item_obj = GetIES(inv_item:GetObject())
        for _, coin_id in ipairs(COIN_ITEM) do
            if item_obj.ClassID == coin_id then
                item.UseByGUID(guid)
                return
            end
        end
    end
end
-- 錬成時に自動でアイテムセット
function mini_addons_SUCCESS_COMMON_SKILL_ENCHANT(frame, msg)
    if g.settings.skill_enchant == 0 then
        return
    end
    ReserveScript("mini_addons_COMMON_SKILL_ENCHANT_ADD_MAT()", 0.9)
    return
end

function mini_addons_COMMON_SKILL_ENCHANT_MAT_SET(my_frame, my_msg)
    if g.settings.skill_enchant == 0 then
        return
    end
    ReserveScript("mini_addons_COMMON_SKILL_ENCHANT_ADD_MAT()", 0.2)
    return
end

function mini_addons_COMMON_SKILL_ENCHANT_ADD_MAT(parent, ctrl)
    local common_skill_enchant = ui.GetFrame("common_skill_enchant")
    if not common_skill_enchant then
        return
    end
    local bottom_bg = GET_CHILD_RECURSIVELY(common_skill_enchant, "bottom_Bg")
    local cnt = bottom_bg:GetChildCount()
    local set_ready_count = 0
    for i = 1, cnt - 1 do
        local ctrl_set = bottom_bg:GetChildByIndex(i)
        local mat_slot = GET_CHILD_RECURSIVELY(ctrl_set, "mat_slot")
        local plus = GET_CHILD_RECURSIVELY(ctrl_set, "plus")
        plus:ShowWindow(1)
        local mat_name = GET_CHILD_RECURSIVELY(ctrl_set, "mat_name")
        local cnt_in_my_bag = GET_CHILD_RECURSIVELY(ctrl_set, "cnt_in_my_bag")
        local val_1 = GET_NOT_COMMAED_NUMBER(mat_name:GetTextByKey("value2"))
        local val_2 = GET_NOT_COMMAED_NUMBER(cnt_in_my_bag:GetTextByKey("value"))
        val_1 = tonumber(val_1)
        val_2 = tonumber(val_2)
        if val_1 <= val_2 then
            local icon = mat_slot:GetIcon()
            if icon then
                icon:SetColorTone("FFFFFFFF")
            end
            plus:ShowWindow(0)
            set_ready_count = set_ready_count + 1
        else
            local msg = string.format("<%s> %s", mat_name:GetTextByKey("value"), ClMsg("NotEnoughMaterial"))
            ui.SysMsg(msg)
        end
    end
    if set_ready_count == (cnt - 1) then
        common_skill_enchant:SetUserValue("IS_READY", "TRUE")
        GET_CHILD_RECURSIVELY(common_skill_enchant, "do_enchant"):SetEnable(1)
    else
        common_skill_enchant:SetUserValue("IS_READY", "FALSE")
    end
end
-- 自動女神ガチャ
function mini_addons_GP_FULL_BET()
    local godprotection = ui.GetFrame("godprotection")
    local auto_gb = GET_CHILD_RECURSIVELY(godprotection, "auto_gb")
    if g.settings.auto_gacha == 1 then
        local fbbtn = auto_gb:CreateOrGetControl("button", "fbbtn", 200, 30, 100, 40)
        AUTO_CAST(fbbtn)
        fbbtn:SetSkinName("None")
        fbbtn:SetText("{img login_test_button 95 35}")
        local fbtext = fbbtn:CreateOrGetControl("button", "fbtext", 0, 0, 100, 40)
        fbtext:SetSkinName("None")
        fbtext:SetText("{ol}  Full Bet")
        fbtext:SetAnimation("MouseOnAnim", "btn_mouseover")
        fbtext:SetEventScript(ui.LBUTTONUP, "mini_addons_GP_FULL_BET_START")
    else
        auto_gb:RemoveChild("fbbtn")
    end
end

function mini_addons_GP_DO_OPEN()
    if g.settings.auto_gacha == 0 then
        g.first = nil
        return
    end
    if not g.first then
        g.first = true
        GODPROTECTION_DO_OPEN()
        if g.settings.auto_gacha_start == 1 then
            local mini_addons = ui.GetFrame("mini_addons")
            mini_addons:RunUpdateScript("mini_addons_GP_FULL_BET_START", 2.0)
        end
    end
end

function mini_addons_GP_FULL_BET_START(mini_addons)
    local godprotection = ui.GetFrame("godprotection")
    local multiple_count = 20
    local multiple_count_edit = GET_CHILD_RECURSIVELY(godprotection, "multiple_count_edit")
    multiple_count_edit:SetText(multiple_count)
    local edit = GET_CHILD_RECURSIVELY(godprotection, "auto_edit")
    local count = 99999999
    local next_count = count - 1
    edit:SetText(next_count)
    local auto_text = GET_CHILD_RECURSIVELY(godprotection, "auto_text")
    auto_text:ShowWindow(0)
    local parent = GET_CHILD_RECURSIVELY(godprotection, "auto_gb")
    local auto_btn = GET_CHILD_RECURSIVELY(godprotection, "auto_btn")
    GODPROTECTION_AUTO_START_BTN_CLICK(parent, auto_btn)
    return 0
end

function mini_addons_FIELD_BOSS_WORLD_EVENT_END(frame)
    local godprotection = ui.GetFrame("godprotection")
    godprotection:ShowWindow(0)
    g.first = nil
end

function mini_addons_GP_AUTOSTART_OPERATION(frame, ctrl)
    AUTO_CAST(ctrl)
    if g.settings.auto_gacha_start == 0 then
        g.settings.auto_gacha_start = 1
        ctrl:SetText("{ol}{#FFFFFF}ON")
        ctrl:SetSkinName("test_red_button")
    else
        g.settings.auto_gacha_start = 0
        ctrl:SetText("{ol}{#FFFFFF}OFF")
        ctrl:SetSkinName("test_gray_button")
    end
    mini_addons_save_settings()
end
-- 町でBGMPLAYERを常に動かす
function mini_addons_BGM_PLAY()
    if g.get_map_type() ~= "City" then
        ui.CloseFrame("bgmplayer_reduction")
        local bgm_player = ui.GetFrame("bgmplayer")
        local play_btn = GET_CHILD_RECURSIVELY(bgm_player, "playStart_btn")
        mini_addons_BGMPLAYER_PLAY(bgm_player, play_btn)
        return
    end
    if g.settings.bgm == 0 then
        return
    end
    BGMPLAYER_OPEN_UI(nil, nil)
    local bgm_player = ui.GetFrame("bgmplayer")
    local player_controller_gb = GET_CHILD_RECURSIVELY(bgm_player, "playercontroler_gb")
    local play_start_btn = GET_CHILD_RECURSIVELY(bgm_player, "playStart_btn")
    local mode = tonumber(bgm_player:GetUserValue("MODE_ALL_LIST"))
    local option = tonumber(bgm_player:GetUserValue("MODE_FAVO_LIST"))
    local play_random = tonumber(bgm_player:GetUserConfig("PLAY_RANDOM"))
    local bgm_music_title_text = GET_CHILD_RECURSIVELY(bgm_player, "bgm_music_title")
    if bgm_music_title_text then
        local title = bgm_music_title_text:GetTextByKey("value")
        if title then
            local halt_image_name = bgm_player:GetUserConfig("PLAY_HALT_BTN_IMAGE_NAME")
            local start_image_name = bgm_player:GetUserConfig("PLAY_START_BTN_IMAGE_NAME")
            local select_ctrl_set_name = g.settings.select_bgm
            if not select_ctrl_set_name then
                return
            end
            local select_ctrl_set = GET_CHILD_RECURSIVELY(bgm_player, select_ctrl_set_name)
            local title_text = nil
            if select_ctrl_set then
                local parent = select_ctrl_set:GetParent()
                if parent ~= nil then
                    BGMPLAYER_SET_MUSIC_TITLE(bgm_player, parent, select_ctrl_set)
                end
                title_text = GET_CHILD_RECURSIVELY(select_ctrl_set, "musictitle_text")
            end
            if title_text == nil then
                return
            end
            local music_title = title_text:GetTextByKey("value")
            if music_title then
                local music_title_parts = StringSplit(music_title, ". ")
                local index_str = music_title_parts[1]
                if string.find(index_str, "{#ffc03a}") ~= nil then
                    local find_start, find_end = string.find(index_str, "{#ffc03a}")
                    if find_start ~= nil and find_end ~= nil then
                        index_str = string.sub(index_str, find_end + 1, string.len(index_str))
                    end
                end
                local index = tonumber(index_str)
                local bgm_type = GET_BGMPLAYER_MODE(bgm_player, mode, option)
                if bgm_type == 1 then
                    SetBgmCurIndex(index, play_random)
                elseif bgm_type == 0 then
                    SetBgmCurFVIndex(index, play_random)
                end
                title = bgm_music_title_text:GetTextByKey("value")
                PlayBgm(title, select_ctrl_set_name)
                BGMPLAYER_REDUCTION_SET_PLAYBTN(true)
                BGMPLAYER_REDUCTION_SET_TITLE(title)
                local total_time = GetPlayBgmTotalTime()
                total_time = total_time / 1000
                local start_time = 0
                if GetBgmPauseTime() > 0 then
                    start_time = GetBgmPauseTime() / 1000
                    SetPauseTime(0)
                end
                BGMPLAYER_PLAYTIME_GAUGE(start_time, total_time)
            end
            if play_start_btn:GetImageName() == start_image_name then
                play_start_btn:SetImage(halt_image_name)
                play_start_btn:SetTooltipArg(ScpArgMsg("BgmPlayer_HaltBtnToolTip"))
            else
                play_start_btn:SetImage(start_image_name)
                play_start_btn:SetTooltipArg(ScpArgMsg("BgmPlayer_StartBtnToolTip"))
            end
            BGMPLAYER_CLOSE_UI()
        end
    end
end

function mini_addons_BGMPLAYER_PLAY(bgm_player, play_btn)
    local bgm_music_title_text = GET_CHILD_RECURSIVELY(bgm_player, "bgm_music_title")
    if bgm_music_title_text then
        local title = bgm_music_title_text:GetTextByKey("value")
        local delay_time = 0
        StopBgm(title, delay_time)
        BGMPLAYER_REDUCTION_SET_PLAYBTN(false)
        return
    end
end

function mini_addons_BGM_PLAY_LIST()
    if g.settings.bgm == 0 then
        return
    end
    local bgm_player = ui.GetFrame("bgmplayer")
    if not bgm_player then
        return
    end
    if not g.settings.select_bgm or g.settings.select_bgm == "" or g.settings.select_bgm == "None" then
        g.settings.select_bgm = "MUSICINFO_1"
        mini_addons_save_settings()
    end
    local current_sel = bgm_player:GetUserValue("CTRLSET_NAME_SELECTED")
    if bgm_player:IsVisible() == 0 and current_sel == "None" then
        bgm_player:SetUserValue("CTRLSET_NAME_SELECTED", g.settings.select_bgm)
        current_sel = g.settings.select_bgm
    end
    if current_sel ~= "None" and g.settings.select_bgm ~= current_sel then
        g.settings.select_bgm = current_sel
        mini_addons_save_settings()
    end
end
-- 小さいボタンをレイドで非表示
function mini_addons_MINIMIZED_CLOSE()
    if g.settings.mini_btn == 0 then
        return
    end
    if g.get_map_type() ~= "Instance" then
        return
    end
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
-- ボタン右クリックでサウンドオフ
function mini_addons_toggle_sound_set()
    local minimap_outsidebutton = ui.GetFrame("minimap_outsidebutton")
    local BGM_PLAYER = GET_CHILD(minimap_outsidebutton, "BGM_PLAYER")
    AUTO_CAST(BGM_PLAYER)
    BGM_PLAYER:SetEventScript(ui.RBUTTONUP, "mini_addons_SOUND_TOGGLE")
    local tooltip = g.lang == "Japanese" and "{@st59}BGMプレイヤー{nl}右クリック: Sound Play/Mute{/}" or
                        g.lang == "kr" and "{@st59}BGM 플레이어{nl}우클릭: 소리 켜기/끄기{/}" or
                        "{@st59}BGM Player{nl}Right-click: Sound Play/Mute{/}"
    BGM_PLAYER:SetTextTooltip(tooltip)
end

function mini_addons_SOUND_TOGGLE(frame, ctrl, str, num)
    local volume = config.GetTotalVolume()
    AUTO_CAST(ctrl)
    local systemoption = ui.GetFrame("systemoption")
    if g.settings.volume == nil or volume ~= 0 then
        g.settings.volume = volume
        mini_addons_save_settings()
        config.SetTotalVolume(0)
        return
    end
    config.SetTotalVolume(g.settings.volume)
end
-- オプションリロールの表を横に表示
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
    local reroll_frame = ui.GetFrame("reroll_item")
    if reroll_frame == nil or reroll_frame:IsVisible() ~= 1 then
        ui.CloseFrame("reroll_item_option")
        return 1
    end
    local slot = GET_CHILD_RECURSIVELY(reroll_frame, "slot")
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
        ui.CloseFrame("reroll_item_option")
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
    local group = TryGetProp(item_obj, "GroupName", "None")
    for i = 1, MAX_RANDOM_OPTION_COUNT do
        local group_name = "RandomOptionGroup_" .. i
        local prop_name = "RandomOption_" .. i
        local prop_value = "RandomOptionValue_" .. i
        local min, max = 0, 0
        if group == "BELT" then
            min, max = shared_item_belt.get_option_value_range_equip(item_obj, item_obj[prop_name])
        elseif group == "SHOULDER" then
            min, max = shared_item_shoulder.get_option_value_range_equip(item_obj, item_obj[prop_name])
        elseif group == "Icor" then
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
    end
    local cur_index = reroll_frame:GetUserValue("CURRENT_INDEX")
    if cur_index == "None" then
        cur_index = 1
    end
    if cur_index == nil or cur_index == "None" then
        return 1
    end
    local reroll_index = TryGetProp(item_obj, "RerollIndex", 0)
    if reroll_index <= 0 then
        reroll_index = tonumber(cur_index)
    end
    local candidate_option_list = nil
    local group_name = TryGetProp(item_obj, "GroupName", "None")
    if group_name == "BELT" then
        candidate_option_list = shared_item_belt.get_option_list_by_index(item_obj, reroll_index)
    elseif group_name == "SHOULDER" then
        candidate_option_list = shared_item_shoulder.get_option_list_by_index(item_obj, reroll_index)
    elseif group_name == "Icor" then
        candidate_option_list = shared_item_goddess_icor.get_random_option_list(item_obj, false)
    end
    if candidate_option_list == nil or #candidate_option_list == 0 then
        return 1
    end
    local max_random_option_count = 0
    if group_name == "BELT" then
        max_random_option_count = shared_item_belt.get_max_random_option_count(item_obj)
    elseif group_name == "SHOULDER" then
        max_random_option_count = shared_item_shoulder.get_max_random_option_count(item_obj)
    elseif group_name == "Icor" then
        max_random_option_count = shared_item_goddess_icor.get_max_option_count()
    end
    if max_random_option_count == nil then
        return 1
    end
    local optionGbox = GET_CHILD_RECURSIVELY(reroll_item_option, "optionGbox")
    optionGbox:RemoveAllChild()
    local op_count = 0
    local function _MAKE_PROPERTY_MIN_MAX_DESC(desc, min, max)
        return string.format(" %s " .. ScpArgMsg("PropUp") .. "%d" .. " ~ " .. ScpArgMsg("PropUp") .. "%d", desc,
            math.abs(min), math.abs(max))
    end
    for i = 1, #candidate_option_list do
        local prop_name = candidate_option_list[i]
        if group_name == "BELT" then
            if shared_item_belt.is_valid_reroll_option(item_obj, reroll_index, prop_name, max_random_option_count) ==
                true then
                op_count = op_count + 1
                local group_name = shared_item_belt.get_option_group_name(prop_name)
                local clmsg = GET_CLMSG_BY_OPTION_GROUP(group_name)
                local min, max = shared_item_belt.get_option_value_range_equip(item_obj, prop_name)
                local op_name = string.format("%s %s", ClMsg(clmsg), ScpArgMsg(prop_name))
                local info_str = _MAKE_PROPERTY_MIN_MAX_DESC(op_name, min, max)
                local option_ctrlset = optionGbox:CreateOrGetControlSet("eachproperty_in_reroll_item",
                    "PROPERTY_CSET_" .. op_count, 0, 0)
                option_ctrlset = AUTO_CAST(option_ctrlset)
                local pos_y = option_ctrlset:GetUserConfig("POS_Y")
                option_ctrlset:Move(0, (op_count - 1) * pos_y)
                local property_name = GET_CHILD_RECURSIVELY(option_ctrlset, "property_name", "ui::CRichText")
                property_name:SetEventScript(ui.LBUTTONUP, "None")
                property_name:SetText(info_str)
                local help_pic = GET_CHILD_RECURSIVELY(option_ctrlset, "help_pic")
                help_pic:ShowWindow(0)
            end
        elseif group_name == "SHOULDER" then
            if shared_item_shoulder.is_valid_reroll_option(item_obj, reroll_index, prop_name, max_random_option_count) ==
                true then
                op_count = op_count + 1
                local group_name = shared_item_shoulder.get_option_group_name(prop_name)
                local clmsg = GET_CLMSG_BY_OPTION_GROUP(group_name)
                local min, max = shared_item_shoulder.get_option_value_range_equip(item_obj, prop_name)
                local op_name = string.format("%s %s", ClMsg(clmsg), ScpArgMsg(prop_name))
                local info_str = _MAKE_PROPERTY_MIN_MAX_DESC(op_name, min, max)
                local option_ctrlset = optionGbox:CreateOrGetControlSet("eachproperty_in_reroll_item",
                    "PROPERTY_CSET_" .. op_count, 0, 0)
                option_ctrlset = AUTO_CAST(option_ctrlset)
                local pos_y = option_ctrlset:GetUserConfig("POS_Y")
                option_ctrlset:Move(0, (op_count - 1) * pos_y)
                local property_name = GET_CHILD_RECURSIVELY(option_ctrlset, "property_name", "ui::CRichText")
                property_name:SetEventScript(ui.LBUTTONUP, "None")
                property_name:SetText(info_str)
                local help_pic = GET_CHILD_RECURSIVELY(option_ctrlset, "help_pic")
                help_pic:ShowWindow(0)
            end
        elseif group_name == "Icor" then
            if shared_item_goddess_icor.is_valid_reroll_option(item_obj, reroll_index, prop_name) == true then
                op_count = op_count + 1
                local group_name = shared_item_goddess_icor.get_option_group_name(prop_name)
                local clmsg = GET_CLMSG_BY_OPTION_GROUP(group_name)
                local min, max = shared_item_goddess_icor.get_option_value_range_icor(item_obj, prop_name)
                local op_name = string.format("%s %s", ClMsg(clmsg), ScpArgMsg(prop_name))
                local info_str = _MAKE_PROPERTY_MIN_MAX_DESC(op_name, min, max)
                local option_ctrlset = optionGbox:CreateOrGetControlSet("eachproperty_in_reroll_item",
                    "PROPERTY_CSET_" .. op_count, 0, 0)
                option_ctrlset = AUTO_CAST(option_ctrlset)
                local pos_y = option_ctrlset:GetUserConfig("POS_Y")
                option_ctrlset:Move(0, (op_count - 1) * pos_y)
                local property_name = GET_CHILD_RECURSIVELY(option_ctrlset, "property_name", "ui::CRichText")
                property_name:SetEventScript(ui.LBUTTONUP, "None")
                property_name:SetText(info_str)
                local help_pic = GET_CHILD_RECURSIVELY(option_ctrlset, "help_pic")
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
-- インベントリを改造
function mini_addons_inventory_open_func(frame, msg)
    g.inven_tbl = g.inven_tbl or {}
    local inventory = ui.GetFrame("inventory")
    local tab = GET_CHILD_RECURSIVELY(inventory, "inventype_Tab")
    if not tab then
        return 1
    end
    local tab_index = tab:GetSelectItemIndex()
    if tab_index ~= 0 and tab_index ~= 3 and tab_index ~= 5 and tab_index ~= 1 and tab_index ~= 2 and tab_index ~= 4 and
        tab_index ~= 6 then
        return 1
    end
    local group = GET_CHILD_RECURSIVELY(inventory, "inventoryGbox", "ui::CGroupBox")
    if not group then
        return 1
    end
    local trees_to_process = {}
    if tab_index == 0 then
        for i = 1, #g_invenTypeStrList do
            local tab_name = g_invenTypeStrList[i]
            local tree_box = GET_CHILD_RECURSIVELY(group, "treeGbox_" .. tab_name, "ui::CGroupBox")
            if tree_box then
                local tree = GET_CHILD_RECURSIVELY(tree_box, "inventree_" .. tab_name, "ui::CTreeControl")
                if tree then
                    table.insert(trees_to_process, tree)
                end
            end
        end
    else
        local tab_name = g_invenTypeStrList[tab_index + 1]
        if tab_name then
            local tree_box = GET_CHILD_RECURSIVELY(group, "treeGbox_" .. tab_name, "ui::CGroupBox")
            if tree_box then
                local tree = GET_CHILD_RECURSIVELY(tree_box, "inventree_" .. tab_name, "ui::CTreeControl")
                if tree then
                    table.insert(trees_to_process, tree)
                end
            end
        end
    end
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
                                    local recipe_cls = GetClass("Recipe", item_cls.ClassName)
                                    if recipe_cls then
                                        local target_item_cls = GetClass("Item", recipe_cls.TargetItem)
                                        if target_item_cls then
                                            local image = nil
                                            if g.settings.inventory_mod == 1 then
                                                local image = GET_ITEM_ICON_IMAGE(target_item_cls)
                                                local recipe_pic =
                                                    slot:CreateOrGetControl("picture", "recipe_pic" .. i, 0, 0, 25, 25)
                                                AUTO_CAST(recipe_pic)
                                                recipe_pic:SetEnableStretch(1)
                                                recipe_pic:SetGravity(ui.RIGHT, ui.TOP)
                                                recipe_pic:SetImage(image)
                                                SET_ITEM_TOOLTIP_TYPE(recipe_pic, target_item_cls.ClassID,
                                                    target_item_cls, "accountwarehouse")
                                            else
                                                local recipe_pic = GET_CHILD(slot, "recipe_pic" .. i)
                                                if recipe_pic then
                                                    DESTROY_CHILD_BYNAME(slot, "recipe_pic" .. i)
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
                                    icon:Set(image, "Item", inv_item.type, inv_item.invIndex, inv_item:GetIESID(),
                                        inv_item.count)
                                end
                            end
                        end
                    end
                end
            end
        end
        local gem_skill_slotset = GET_CHILD_RECURSIVELY(tree, "sset_Gem_GemSkill", "ui::CSlotSet")
        if gem_skill_slotset then
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
                                        local skill_name = TryGetProp(item_cls, "SkillName", "None")
                                        local skill_cls = GetClass("Skill", skill_name)
                                        local skill_pic = slot:CreateOrGetControl("picture", "skill_pic" .. i, 0, 0, 35,
                                            35)
                                        AUTO_CAST(skill_pic)
                                        skill_pic:SetEnableStretch(1)
                                        skill_pic:SetGravity(ui.LEFT, ui.TOP)
                                        skill_pic:SetImage(image)
                                        SET_ITEM_TOOLTIP_TYPE(skill_pic, item_cls.ClassID, item_cls, "accountwarehouse")
                                        image = "icon_" .. GET_ITEM_ICON_IMAGE(skill_cls)
                                    else
                                        local trade = GET_CHILD(slot, "skill_pic" .. i)
                                        if trade then
                                            DESTROY_CHILD_BYNAME(slot, "skill_pic" .. i)
                                        end
                                    end
                                    if item_cls then
                                        icon:Set(image, "Item", inv_item.type, inv_item.invIndex, inv_item:GetIESID(),
                                            inv_item.count)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        local Gem_High_Color_slotset = GET_CHILD_RECURSIVELY(tree, "sset_Gem_High_Color", "ui::CSlotSet")
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
                                local item_cls = GetClassByType("Item", item_obj.ClassID)
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
        local sset_Ancient_Card = GET_CHILD_RECURSIVELY(tree, "sset_Ancient_Card", "ui::CSlotSet")
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
                                local ancient_pic = slot:CreateOrGetControl("picture", "ancient_pic" .. i, 0, 0, 25, 25)
                                AUTO_CAST(ancient_pic)
                                ancient_pic:SetEnableStretch(1)
                                ancient_pic:SetGravity(ui.LEFT, ui.TOP)
                                ancient_pic:SetImage(icon_name)
                                SET_ITEM_TOOLTIP_TYPE(ancient_pic, item_cls.ClassID, item_cls, "accountwarehouse")
                            else
                                local trade = GET_CHILD(slot, "ancient_pic" .. i)
                                if trade then
                                    DESTROY_CHILD_BYNAME(slot, "ancient_pic" .. i)
                                end
                            end
                        end

                    end
                end
            end
        end
        local icor_slot_set = GET_CHILD_RECURSIVELY(tree, "sset_Icor", "ui::CSlotSet")
        if icor_slot_set then
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
                                            local trade = slot:CreateOrGetControl("richtext", "trade" .. i, 5, 40, 30,
                                                10)
                                            AUTO_CAST(trade)
                                            trade:SetText("{ol}{s10}NoTrade")
                                        end
                                    else
                                        local trade = GET_CHILD(slot, "trade" .. i)
                                        if trade then
                                            DESTROY_CHILD_BYNAME(slot, "trade" .. i)
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
        local armor_slot_set = GET_CHILD_RECURSIVELY(tree, "sset_Armor", "ui::CSlotSet")
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
    inventory:Invalidate()
    local try = inventory:GetUserIValue("TRY")
    if (msg == "INV_ITEM_REMOVE" or msg == "INV_ITEM_ADD") and try < 2 then
        try = try + 1
        inventory:SetUserValue("TRY", try)
        inventory:StopUpdateScript("mini_addons_inventory_open_func")
        inventory:RunUpdateScript("mini_addons_INVENTORY_OPEN_logic", 1.0)
        return 1
    elseif (msg == "INV_ITEM_REMOVE" or msg == "INV_ITEM_ADD") and try >= 2 then
        inventory:SetUserValue("TRY", 0)
        inventory:StopUpdateScript("mini_addons_inventory_open_func")
        inventory:StopUpdateScript("mini_addons_INVENTORY_OPEN_logic")

    elseif try >= 2 then
        inventory:SetUserValue("TRY", 0)
        return 0
    else
        try = try + 1
        inventory:SetUserValue("TRY", try)
        return 1 -- スクリプトを継続
    end
end

function mini_addons_INVENTORY_OPEN_logic(frame)
    if frame:IsVisible() == 1 then
        frame:StopUpdateScript("mini_addons_inventory_open_func")
        frame:RunUpdateScript("mini_addons_inventory_open_func", 1.0)
    else
        frame:StopUpdateScript("mini_addons_inventory_open_func")
    end
    return 0
end

function mini_addons_INVENTORY_OPEN(my_frame, my_msg)
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
        inventory:RunUpdateScript("mini_addons_INVENTORY_OPEN_logic", final_delay)
    else
        mini_addons_INVENTORY_OPEN_logic(inventory)
    end
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
    local move_toggle = setting:CreateOrGetControl("checkbox", "move_toggle", 10, 35, 30, 30)
    AUTO_CAST(move_toggle)
    move_toggle:SetCheck(_G["norisan"]["MENU"].move == true and 0 or 1)
    move_toggle:SetEventScript(ui.LBUTTONDOWN, "norisan_menu_setting_frame_ctrl")
    local notice = _G["norisan"]["MENU"].lang == "Japanese" and "{ol}チェックするとフレーム固定" or
                       "{ol}Check to fix frame"
    move_toggle:SetText(notice)
    local open_toggle = setting:CreateOrGetControl("checkbox", "open_toggle", 10, 70, 30, 30)
    AUTO_CAST(open_toggle)
    open_toggle:SetCheck(_G["norisan"]["MENU"].open)
    open_toggle:SetEventScript(ui.LBUTTONDOWN, "norisan_menu_setting_frame_ctrl")
    local notice = _G["norisan"]["MENU"].lang == "Japanese" and "{ol}チェックすると上開き" or
                       "{ol}Check to open upward"
    open_toggle:SetText(notice)
    local layer_text = setting:CreateOrGetControl("richtext", "layer_text", 10, 105, 50, 20)
    AUTO_CAST(layer_text)
    local notice = _G["norisan"]["MENU"].lang == "Japanese" and "{ol}レイヤー設定" or "{ol}Set Layer"
    layer_text:SetText(notice)
    local layer_edit = setting:CreateOrGetControl("edit", "layer_edit", 130, 105, 70, 20)
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
            item_elem = frame:CreateOrGetControl("button", ctrl_name, x, y, item_w, item_h)
            AUTO_CAST(item_elem)
            item_elem:SetSkinName("None")
            item_elem:SetText(data.image)
        else
            item_elem = frame:CreateOrGetControl("picture", ctrl_name, x, y, item_w, item_h)
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
    local norisan_menu_pic = frame:CreateOrGetControl("picture", "norisan_menu_pic", 0, 0, 35, 40)
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

