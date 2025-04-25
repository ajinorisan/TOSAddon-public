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
local addonName = "MINI_ADDONS"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.6.6"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

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

local coin_item = {869001, 11200350, 11200303, 11200302, 11200301, 11200300, 11200299, 11200298, 11200297, 11200161,
                   11200160, 11200159, 11200158, 11200157, 11200156, 11200155, 11030215, 11030214, 11030213, 11030212,
                   11030211, 11030210, 11030201, 11035673, 11035670, 11035668, 11030394, 11030240, 646076, 11035672,
                   11035669, 11035667, 11035457, 11035426, 11035409, 11201239, 11201238, 11201237, 11201236, 11201235,
                   11201234, 11201233, 11201232}

local active_id = session.loginInfo.GetAID()
g.settingsFileLoc = string.format("../addons/%s/%s.json", addonNameLower, active_id .. "_1")
g.buffsFileLoc = string.format('../addons/%s/buffs.json', addonNameLower)

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

function MINI_ADDONS_SAVE_SETTINGS()
    acutil.saveJSON(g.settingsFileLoc, g.settings);
end

function MINI_ADDONS_LOAD_SETTINGS()

    local settings, err = acutil.loadJSON(g.settingsFileLoc)
    if err then
        -- 設定ファイル読み込み失敗時処理
        -- CHAT_SYSTEM(string.format("[%s] cannot load setting files", addonNameLower))
    end
    -- !追加の度に更新
    local defaultSettings = {
        reword_x = 1100,
        reword_y = 100,
        allcall = 0,
        under_staff = 1,
        raid_record = 1,
        party_buff = 1,
        chat_system = 1,
        channel_display = 0,
        channel_info = 1,
        mini_btn = 0,
        market_display = 1,
        restart_move = 0,
        pet_init = 0,
        dialog_ctrl = 1,
        auto_cast = 1,
        auto_casting = {},
        coin_use = 1,
        equip_info = 1,
        automatch_layer = 1,
        quest_hide = 1,
        pc_name = 1,
        auto_gacha = 0,
        skill_enchant = 1,
        party_info = 0,
        relic_gauge = 1,
        raid_check = 0,
        coin_count = 1,
        bgm = 0,
        my_effect = 1,
        other_effect = 1,
        vakarine = 0,
        weekly_boss_reward = 0,
        cupole_portion = {
            use = 0,
            x = 0,
            y = 0,
            def_x = 0,
            def_y = 0
        },
        goodbye_ragana = 1,
        status_upgrade = 1,
        icor_status_search = 1,
        velnice = {
            use = 1,
            level = ""
        },
        separated_buff = 1,
        group_name = {},
        group_chat = 1,
        memberinfo = 1,
        baubas_call = {
            use = 0,
            guild_notice = 0
        }
    }

    if not settings then
        settings = defaultSettings
    else
        for key, value in pairs(defaultSettings) do
            if settings[key] == nil then
                settings[key] = value
            end
        end
    end

    g.settings = settings

    MINI_ADDONS_SAVE_SETTINGS()

    MINI_ADDONS_SAVE_AND_CREATE_BUFFIDS()
end

function MINI_ADDONS_SAVE_AND_CREATE_BUFFIDS()
    local buffs = acutil.loadJSON(g.buffsFileLoc, g.buffs)

    if not buffs then
        buffs = {}
    end

    g.buffs = buffs
    acutil.saveJSON(g.buffsFileLoc, g.buffs);

end

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

    local equip_item_list = session.GetEquipItemList();
    local equip_guid_list = equip_item_list:GetGuidList();
    local count = equip_guid_list:Count();
    local vakarine_count = 0
    for i = 0, count - 1 do
        local guid = equip_guid_list:Get(i);
        if guid ~= '0' then
            local equip_item = equip_item_list:GetItemByGuid(guid);
            if equip_item ~= nil and equip_item:GetObject() ~= nil then

                local item = GetIES(equip_item:GetObject())

                for j = 1, MAX_OPTION_EXTRACT_COUNT do
                    local propGroupName = "RandomOptionGroup_" .. j;
                    local propName = "RandomOption_" .. j;
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
    local timer = frame:CreateOrGetControl("timer", "addontimer", 0, 0);
    AUTO_CAST(timer)
    timer:SetUpdateScript("mini_addons_ragana_remove");
    timer:Start(1.0);
end

function mini_addons_ragana_remove(frame)

    local selected_objects, selected_objects_count = SelectObject(GetMyPCObject(), 1000, "ALL")

    for i = 1, selected_objects_count do

        local handle = GetHandle(selected_objects[i])

        if handle ~= nil then
            if info.IsPC(handle) ~= 1 then
                local npcName = world.GetActor(handle):GetName()
                if npcName == "[마신의 유혹]{nl}마신 라가나의 환영" then

                    world.Leave(handle, 0.0);
                    local timer = frame:CreateOrGetControl("timer", "addontimer", 0, 0);
                    AUTO_CAST(timer)
                    timer:Stop();
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
        target_status_text:SetFontName("white_18_ol");
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
        target_status_edit:SetTextAlign("center", "center");
        target_status_edit:SetFontName("white_18_ol");
        target_status_edit:SetSkinName("test_weight_skin");
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

    local frame = parent:GetTopParentFrame();
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

    local frame = ui.GetFrame('indun_editmsgbox');
    frame:EnableHide(1);
    frame:SetUserValue("user_value", type);

    local text = GET_CHILD_RECURSIVELY(frame, "text");
    text:SetText(clmsg);

    local text_desc = GET_CHILD_RECURSIVELY(frame, "text_desc");
    text_desc:SetText(desc);

    local edit = GET_CHILD_RECURSIVELY(frame, "edit");

    edit:SetText(default_number);
    edit:SetNumberMode(1);
    edit:SetMaxNumber(max_number);
    edit:SetMinNumber(min_number);
    edit:AcquireFocus();

    local yesBtn = GET_CHILD_RECURSIVELY(frame, "yesBtn", "ui::CButton")
    yesBtn:SetEventScript(ui.LBUTTONUP, 'MINI_ADDONS_INDUN_EDITMSGBOX_FRAME_OPEN_YES');
    yesBtn:SetEventScriptArgString(ui.LBUTTONUP, yesScp);

    local noBtn = GET_CHILD_RECURSIVELY(frame, "noBtn", "ui::CButton")
    noBtn:SetEventScript(ui.LBUTTONUP, '_INDUN_EDITMSGBOX_FRAME_OPEN_NO');
    noBtn:SetEventScriptArgString(ui.LBUTTONUP, noScp);

    yesBtn:ShowWindow(1);
    noBtn:ShowWindow(1);
end

function MINI_ADDONS_SOLO_D_TIMER_UPDATE_TEXT_GAUGE(frame, msg, argStr)

    local argument_list = StringSplit(argStr, ";");
    local ui_msg = argument_list[1];
    local waveMsg = argument_list[2];
    local current_wave = tonumber(argument_list[3])
    if g.velnice ~= current_wave and current_wave ~= 1 then

        local frame = ui.GetFrame("solo_d_timer");
        local remaintimeValue = GET_CHILD_RECURSIVELY(frame, "remaintimeValue");
        local min = remaintimeValue:GetTextByKey("min");
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
    local text = edit:GetText();

    g.settings.velnice.level = tonumber(text)
    MINI_ADDONS_SAVE_SETTINGS()

    local scp = _G[argStr]
    if scp ~= nil then
        local user_value = tonumber(parent:GetUserValue("user_value"));
        scp(user_value, text)
    end
    ui.CloseFrame("indun_editmsgbox");
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

    acutil.saveJSON(g.buffsFileLoc, g.buffs)
    MINI_ADDONS_SAVE_AND_CREATE_BUFFIDS()
end

function MINI_ADDONS_BUFFLIST_FRAME_INIT()
    local bufflistframe = ui.CreateNewFrame("notice_on_pc", "mini_addons_bufflist", 0, 0, 10, 10)
    AUTO_CAST(bufflistframe)
    bufflistframe:SetSkinName("bg")
    bufflistframe:Resize(500, 1060)
    bufflistframe:SetPos(10, 10)
    bufflistframe:SetLayerLevel(121)
    bufflistframe:RemoveAllChild()

    local bg = bufflistframe:CreateOrGetControl("groupbox", "bufflist_bg", 5, 35, 490, 1015)
    AUTO_CAST(bg)
    bg:SetSkinName("bg")
    bg:SetEventScript(ui.RBUTTONUP, "MINI_ADDONS_BUFFLIST_FRAME_CLOSE");
    bg:SetTextTooltip(g.lang == "Japanese" and "{ol}右クリックで閉じます。" or "Right-click to close.")

    local closeBtn = bufflistframe:CreateOrGetControl('button', 'closeBtn', 450, 0, 30, 30)
    AUTO_CAST(closeBtn)
    closeBtn:SetImage("testclose_button")
    closeBtn:SetGravity(ui.RIGHT, ui.TOP)
    closeBtn:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_BUFFLIST_FRAME_CLOSE");

    local all_toggle = bufflistframe:CreateOrGetControl('checkbox', 'all_toggle', 425, 5, 25, 25)
    AUTO_CAST(all_toggle)
    all_toggle:SetTextTooltip(g.lang == "Japanese" and "{ol}全ての表示切替" or "Toggle All Displays")
    all_toggle:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_BUFFLIST_ALL_CHECK");

    local sortedBuffIDs = {}
    for buffID, _ in pairs(g.buffs) do
        table.insert(sortedBuffIDs, tonumber(buffID))
    end
    table.sort(sortedBuffIDs)

    local bufflisttext = bufflistframe:CreateOrGetControl('richtext', 'bufflisttext', 10, 10, 200, 30)
    AUTO_CAST(bufflisttext)
    bufflisttext:SetText("{ol}BUFF LIST")

    -- ソートされた順番で表示
    local y = 0
    local i = 1

    for _, buffID in ipairs(sortedBuffIDs) do

        local buffslot = bg:CreateOrGetControl('slot', 'buffslot' .. i, 10, y + 5, 30, 30)
        AUTO_CAST(buffslot)
        local buffCls = GetClassByType("Buff", buffID);

        if buffCls ~= nil then
            SET_SLOT_IMG(buffslot, GET_BUFF_ICON_NAME(buffCls));

            local icon = CreateIcon(buffslot)
            AUTO_CAST(icon)
            icon:SetTooltipType('buff');
            icon:SetTooltipArg(buffCls.Name, buffID, 0);

            local buffcheck = bg:CreateOrGetControl('checkbox', 'buffcheck' .. i, 45, y + 5, 30, 30)
            AUTO_CAST(buffcheck)
            local check = g.buffs[tostring(buffID)] or 0

            buffcheck:SetCheck(check)
            buffcheck:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_BUFFCHECK")
            buffcheck:SetEventScriptArgNumber(ui.LBUTTONUP, buffID)
            --[[if buffCls.Name == "None" then
                print(buffID)
            end]]
            buffcheck:SetText("{ol}" .. buffCls.Name)
            -- local clsid = buffCls.ClassID

            buffcheck:SetTextTooltip(g.lang == "Japanese" and "{ol}" .. buffID ..
                                         "{nl}チェックするとパーティーバフ表示" or "{ol}" .. buffID ..
                                         "{nl}Party buff display when checked")

            y = y + 35
            i = i + 1
        end

    end

    bufflistframe:ShowWindow(1)

end

function MINI_ADDONS_BUFFCHECK(frame, ctrl, argStr, buffID)
    local check = ctrl:IsChecked()

    if g.buffs[tostring(buffID)] ~= nil then
        g.buffs[tostring(buffID)] = check
        acutil.saveJSON(g.buffsFileLoc, g.buffs)
    end
    MINI_ADDONS_SAVE_AND_CREATE_BUFFIDS()
end

function MINI_ADDONS_BUFFLIST_FRAME_CLOSE()
    local frame = ui.GetFrame("mini_addons_bufflist")
    frame:ShowWindow(0)
end

function MINI_ADDONS_BUFF_TABLE_INSERT(buffID)

    local buffIDStr = tostring(buffID)
    if g.buffs[buffIDStr] == nil then
        g.buffs[buffIDStr] = 1
        acutil.saveJSON(g.buffsFileLoc, g.buffs)
    end
end

function MINI_ADDONS_ON_PARTYINFO_BUFFLIST_UPDATE(frame)
    local frame = ui.GetFrame("partyinfo");
    if frame == nil then
        return;
    end
    local pcparty = session.party.GetPartyInfo();
    if pcparty == nil then
        DESTROY_CHILD_BYNAME(frame, 'PTINFO_');
        frame:ShowWindow(0);
        return;
    end

    local partyInfo = pcparty.info;
    local obj = GetIES(pcparty:GetObject());
    local list = session.party.GetPartyMemberList(0);
    local count = list:Count();
    local memberIndex = 0;

    local myInfo = session.party.GetMyPartyObj();
    -- 접속중 파티원 버프리스트
    for i = 0, count - 1 do
        local partyMemberInfo = list:Element(i);

        if geMapTable.GetMapName(partyMemberInfo:GetMapID()) ~= 'None' then

            local buffCount = partyMemberInfo:GetBuffCount();

            local partyInfoCtrlSet = frame:GetChild('PTINFO_' .. partyMemberInfo:GetAID());
            if partyInfoCtrlSet ~= nil then

                local buffListSlotSet = GET_CHILD(partyInfoCtrlSet, "buffList", "ui::CSlotSet");
                local debuffListSlotSet = GET_CHILD(partyInfoCtrlSet, "debuffList", "ui::CSlotSet");

                -- 초기화
                for j = 0, buffListSlotSet:GetSlotCount() - 1 do
                    local slot = buffListSlotSet:GetSlotByIndex(j);
                    slot:SetKeyboardSelectable(false);
                    if slot == nil then
                        break
                    end
                    slot:ShowWindow(0);
                end

                for j = 0, debuffListSlotSet:GetSlotCount() - 1 do
                    local slot = debuffListSlotSet:GetSlotByIndex(j);
                    if slot == nil then
                        break
                    end
                    slot:ShowWindow(0);
                end

                -- 아이콘 셋팅
                if buffCount <= 0 then
                    partyMemberInfo:ResetBuff();
                    buffCount = partyMemberInfo:GetBuffCount();
                end

                if buffCount > 0 then
                    local buffIndex = 0;
                    local debuffIndex = 0;
                    for j = 0, buffCount - 1 do
                        local buffID = partyMemberInfo:GetBuffIDByIndex(j);
                        local cls = GetClassByType("Buff", buffID);
                        -- if cls ~= nil and IS_PARTY_INFO_SHOWICON(cls.ShowIcon) == true and cls.ClassName ~= "TeamLevel" then
                        if cls ~= nil and cls.ClassName ~= "TeamLevel" then
                            local buffOver = partyMemberInfo:GetBuffOverByIndex(j);
                            local buffTime = partyMemberInfo:GetBuffTimeByIndex(j);
                            local slot = nil;
                            if cls.Group1 == 'Buff' then

                                local image = TryGetProp(cls, 'Icon', 'None')
                                if image ~= "None" and cls.Name ~= "None" then
                                    MINI_ADDONS_BUFF_TABLE_INSERT(buffID)
                                end

                                if g.settings.party_buff == 1 then
                                    if g.buffs[tostring(buffID)] == 1 then
                                        slot = buffListSlotSet:GetSlotByIndex(buffIndex);
                                        buffIndex = buffIndex + 1;
                                    else
                                        slot = nil -- g.buffsに存在しない場合はslotをnilにする
                                    end
                                else
                                    slot = buffListSlotSet:GetSlotByIndex(buffIndex);
                                    buffIndex = buffIndex + 1;
                                end

                            elseif cls.Group1 == 'Debuff' then
                                slot = debuffListSlotSet:GetSlotByIndex(debuffIndex);
                                debuffIndex = debuffIndex + 1;
                            end

                            if slot ~= nil then
                                local icon = slot:GetIcon();
                                if icon == nil then
                                    icon = CreateIcon(slot);
                                end

                                local handle = 0;
                                if myInfo ~= nil then
                                    if myInfo:GetMapID() == partyMemberInfo:GetMapID() and myInfo:GetChannel() ==
                                        partyMemberInfo:GetChannel() then
                                        handle = partyMemberInfo:GetHandle();
                                    end
                                end

                                handle = tostring(handle);
                                icon:SetDrawCoolTimeText(math.floor(buffTime / 1000));
                                icon:SetTooltipType('buff');
                                icon:SetTooltipArg(handle, buffID, "");

                                local imageName = 'icon_' .. TryGetProp(cls, 'Icon', 'None');
                                if imageName ~= "icon_None" then
                                    icon:Set(imageName, 'BUFF', buffID, 0);
                                end

                                if buffOver > 1 then
                                    slot:SetText('{s13}{ol}{b}' .. buffOver, 'count', ui.RIGHT, ui.BOTTOM, 1, 2);
                                else
                                    slot:SetText("");
                                end

                                slot:ShowWindow(1);
                            end
                        end
                    end
                end
            end
        end
    end
end

function MINI_ADDONS_ON_PARTYINFO_INST_UPDATE(frame, msg, argStr, argNum)
    local frame = ui.GetFrame("partyinfo");
    MINI_ADDONS_ON_PARTYINFO_BUFFLIST_UPDATE(frame);
end

function mini_addons_basefunction_old()
    return
end

-- グループチャットの切り替え機能
g.group_chat = nil
function MINI_ADDONS_CHAT_GROUPLIST_OPTION_OK(frame)

    local frame = ui.GetFrame("chat_grouplist_option")
    local roomid = frame:GetUserValue("ROOMID")

    local selectedColor = frame:GetUserValue("SelectedColor")
    local info = session.chat.GetByStringID(roomid);

    if info == nil then
        frame:ShowWindow(0)
        return;
    end

    if info:GetRoomType() == 3 then

        local titleedit = GET_CHILD_RECURSIVELY(frame, "groupname_edit")
        local newtitle = titleedit:GetText()

        g.settings.group_name[tostring(roomid)] = newtitle
        MINI_ADDONS_SAVE_SETTINGS()

        local chatframe = ui.GetFrame("chat")
        -- local chat_type
        if chatframe ~= nil then
            -- chat_type = chatframe:GetUserValue("CHAT_TYPE_SELECTED_VALUE")

            -- chatframe:SetUserValue("CHAT_TYPE_SELECTED_VALUE", 6)
            ui.SetChatType(5)
            MINI_ADDONS_SEND_POPUP_FRAME_CHAT(_, _, roomid, 1)
            -- and chatframe:GetUserValue("CHAT_TYPE_SELECTED_VALUE") == "6" then

            local frame = ui.GetFrame('chat_grouplist');
            local gbox = GET_CHILD_RECURSIVELY(frame, "chatlist_group");

            local eachcset = GET_CHILD_RECURSIVELY(gbox, 'btn_' .. roomid)
            local title = g.settings.group_name[roomid]
            local titletext = GET_CHILD(eachcset, "title");

            AUTO_CAST(titletext)
            local persons = string.match(titletext:GetText(), "%[[^%]]+%]")
            titletext:SetText(title .. persons)
            frame:ShowWindow(0)
        end
        -- chatframe:SetUserValue("CHAT_TYPE_SELECTED_VALUE", chat_type)
    end

end

function MINI_ADDONS_CHAT_SET_TO_TITLENAME(targetName, roomid)

    local frame = ui.GetFrame('chat')
    AUTO_CAST(frame)
    local chatEditCtrl = frame:GetChild('mainchat')
    AUTO_CAST(chatEditCtrl)
    local titleCtrl = GET_CHILD(frame, 'edit_to_bg')
    AUTO_CAST(titleCtrl)
    local editbg = GET_CHILD(frame, 'edit_bg')
    AUTO_CAST(editbg)
    local name = GET_CHILD(titleCtrl, 'title_to')
    AUTO_CAST(name)

    local btn_ChatType = GET_CHILD(frame, 'button_type')

    titleCtrl:SetOffset(btn_ChatType:GetOriginalWidth(), titleCtrl:GetOriginalY())
    local offsetX = btn_ChatType:GetOriginalWidth() -- 시작 offset은 type btn 넓이 다음으로.
    local titleText = ''
    local isVisible = 0

    if targetName ~= "" then

        isVisible = 1
        titleText = targetName
        if titleText == "" or titleText == nil then
            return
        end

    end
    -- 이름을 먼저 설정해줘야 크기와 위치 설정이 이루어진다.

    if titleText ~= '' then
        titleCtrl:Resize(name:GetWidth() + 20, titleCtrl:GetOriginalHeight())

        name:SetText(titleText)
        name:ShowWindow(1)

    else
        titleCtrl:Resize(name:GetWidth(), titleCtrl:GetOriginalHeight())
    end

    if isVisible == 1 then
        titleCtrl:SetVisible(1)
        offsetX = offsetX + titleCtrl:GetWidth()

    else
        titleCtrl:SetVisible(0)
    end

    local width = chatEditCtrl:GetOriginalWidth() - titleCtrl:GetWidth() - btn_ChatType:GetWidth()
    chatEditCtrl:Resize(width, chatEditCtrl:GetOriginalHeight())
    chatEditCtrl:SetOffset(offsetX, chatEditCtrl:GetOriginalY())
    -- print(tostring(targetName) .. ":" .. tostring(titleText))
    frame:Invalidate()
end

function MINI_ADDONS_SEND_POPUP_FRAME_CHAT(frame, ctrl, roomid, num)

    local chatframe = ui.GetFrame('chat')
    local edit = chatframe:GetChild('mainchat');
    AUTO_CAST(edit)
    edit:RunEnterKeyScript();
    ui.ProcessReturnKey()

    local info = session.chat.GetByStringID(roomid);
    if info == nil then
        g.room_id = nil
        chatframe:ShowWindow(0)
        return
    end

    local chat_type = chatframe:GetUserValue("CHAT_TYPE_SELECTED_VALUE")
    -- CHAT_SYSTEM(chat_type)
    ui.SetChatType(5)
    MINI_ADDONS_CHAT_SET_TO_TITLENAME(g.settings.group_name[tostring(roomid)], roomid)
    ui.SetChatType(chat_type - 1)
    -- chatframe:SetUserValue("CHAT_TYPE_SELECTED_VALUE", chat_type)

    for room_id, title in pairs(g.settings.group_name) do

        local info = session.chat.GetByStringID(room_id);

        if info:GetRoomType() == 3 then
            -- print(tostring(room_id) .. ":" .. tostring(title))
            session.chat.SetRoomConfigTitle(room_id, title)

        end
    end

    g.room_id = roomid
    ui.SetGroupChatTargetID(roomid)
    chatframe:ShowWindow(0)

    if num == 1 then
        local frame = ui.GetFrame('chat_grouplist');
        frame:ShowWindow(0)
        chatframe:ShowWindow(1)
    end
end

function MINI_ADDONS_CHAT_CREATE_OR_UPDATE_GROUP_LIST_3SEC(frame, msg, str, num)
    CHAT_GROUPLIST_SELECT_LISTTYPE(3)
end

function MINI_ADDONS_CHAT_GROUPLIST_SELECT_LISTTYPE(frame, msg)

    local type = acutil.getEventArgs(msg)
    if type ~= 3 then
        return
    end

    local frame = ui.GetFrame("chat_grouplist")
    local gbox = GET_CHILD_RECURSIVELY(frame, "chatlist_group");

    local child_count = gbox:GetChildCount()
    local existing_room_ids = {}

    for i = 0, child_count - 1 do
        local child = gbox:GetChildByIndex(i)
        if string.find(child:GetName(), "btn_") then
            local room_id = string.gsub(child:GetName(), "btn_", "")
            local eachcset = GET_CHILD_RECURSIVELY(gbox, 'btn_' .. room_id)

            eachcset:SetEventScript(ui.LBUTTONUP, 'MINI_ADDONS_SEND_POPUP_FRAME_CHAT');
            eachcset:SetEventScriptArgString(ui.LBUTTONUP, room_id);
            eachcset:SetEventScriptArgNumber(ui.LBUTTONUP, 1);

            eachcset:SetEventScript(ui.RBUTTONUP, 'MINI_ADDONS_SEND_POPUP_FRAME_CHAT');
            eachcset:SetEventScriptArgString(ui.RBUTTONUP, room_id);
            eachcset:SetEventScriptArgNumber(ui.RBUTTONUP, 1);

            eachcset:SetTextTooltip(g.lang == "Japanese" and
                                        "{ol}右クリック:メインチャットのグループを切り替えます" or
                                        "{ol}Right click:Switch the main chat group")

            local titletext = GET_CHILD(eachcset, "title");

            local title = string.gsub(titletext:GetText(), "%[%s*[^%]]-%s*%]", "")
            g.settings.group_name[tostring(room_id)] = g.settings.group_name[tostring(room_id)] or title

            existing_room_ids[tostring(room_id)] = true

        end
    end

    for room_id in pairs(g.settings.group_name) do
        if not existing_room_ids[room_id] then
            g.settings.group_name[room_id] = nil
            g.room_id = nil
        else
            local info = session.chat.GetByStringID(room_id);

            if info:GetRoomType() == 3 then

                function MINI_ADDONS_CHAT_GROUP_CONTEXT(frame, ctrl, str, num)

                    local context = ui.CreateContextMenu("select_group", " ", 0, 0, 0, 0)

                    for key, value in pairs(g.settings.group_name) do
                        ui.AddContextMenuItem(context, value, string.format(
                            "MINI_ADDONS_SEND_POPUP_FRAME_CHAT(%s,%s,'%s',%d)", "nil", "main_chat", key, 1))
                    end
                    ui.OpenContextMenu(context)
                end

                local frame = ui.GetFrame('chat')
                local titleCtrl = GET_CHILD(frame, 'edit_to_bg')
                local name = GET_CHILD(titleCtrl, 'title_to')
                AUTO_CAST(name)
                name:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_CHAT_GROUP_CONTEXT")
                name:SetTextTooltip(g.lang == "Japanese" and "左クリック：グループチャット選択" or
                                        "{ol}Left click:Select group chat")
                frame:Invalidate();

                g.temp_id = room_id

                local eachcset = GET_CHILD_RECURSIVELY(gbox, 'btn_' .. room_id)
                local title = g.settings.group_name[room_id]
                local titletext = GET_CHILD(eachcset, "title");

                AUTO_CAST(titletext)

                local persons = string.match(titletext:GetText(), "%[[^%]]+%]")
                titletext:SetText(title .. persons)

            end
        end
    end

    MINI_ADDONS_SAVE_SETTINGS()
    if g.group_chat then
        MINI_ADDONS_SEND_POPUP_FRAME_CHAT(frame, _, g.room_id or g.temp_id, _)
    end
    g.group_chat = true
end

function MINI_ADDONS_GROUPCHAT_OUT(frame)

    local frame = ui.GetFrame("chat_grouplist_option")
    local roomid = frame:GetUserValue("ROOMID")
    g.settings.group_name[roomid] = nil
    MINI_ADDONS_SAVE_SETTINGS()

    g.room_id = nil
    CHAT_GROUPLIST_SELECT_LISTTYPE(3)
end

function MINI_ADDONS_CREATE_NEW_GROUPCHAT()
    ReserveScript(string.format("CHAT_GROUPLIST_SELECT_LISTTYPE(%d)", 3), 1.0)
end

-- どこでもメンバーインフォ機能
function MINI_ADDONS_CHAT_RBTN_POPUP(frame, chatCtrl)
    if g.settings.memberinfo ~= 1 then
        base["CHAT_RBTN_POPUP"](frame, chatCtrl)
    else
        MINI_ADDONS_CHAT_RBTN_POPUP_(frame, chatCtrl)
    end
end

function MINI_ADDONS_CHAT_RBTN_POPUP_(frame, chatCtrl)
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
    ui.AddContextMenuItem(context, "-----", "None")
    -- ui.AddContextMenuItem(context, ScpArgMsg('ShowInfomation'), string.format("ui.Chat(%s)", "/ " .. targetName))
    ui.AddContextMenuItem(context, ScpArgMsg('ShowInfomation'),
        string.format("ui.Chat('%s')", "/memberinfo " .. targetName))
    ui.OpenContextMenu(context)
end

function MINI_ADDONS_POPUP_GUILD_MEMBER(parent, ctrl)
    if g.settings.memberinfo ~= 1 then
        base["MINI_ADDONS_POPUP_GUILD_MEMBER"](parent, ctrl)
    else
        MINI_ADDONS_POPUP_GUILD_MEMBER_(parent, ctrl)
    end
end

function MINI_ADDONS_POPUP_GUILD_MEMBER_(parent, ctrl)
    local aid = parent:GetUserValue("AID");
    if aid == "None" then
        aid = ctrl:GetUserValue("AID");
    end

    local memberInfo = session.party.GetPartyMemberInfoByAID(PARTY_GUILD, aid);
    local isLeader = AM_I_LEADER(PARTY_GUILD);
    local myAid = session.loginInfo.GetAID();

    local name = memberInfo:GetName();

    local contextMenuCtrlName = string.format("{@st41}%s{/}", name);
    local context = ui.CreateContextMenu("PC_CONTEXT_MENU", name, 0, 0, 170, 100);

    if isLeader == 1 or HAS_KICK_CLAIM() then
        ui.AddContextMenuItem(context, ScpArgMsg("Ban"), string.format("GUILD_BAN('%s')", aid));
    end

    if isLeader == 1 and aid ~= myAid then
        local mapName = session.GetMapName();
        if mapName == 'guild_agit_1' or mapName == 'guild_agit_extension' then
            ui.AddContextMenuItem(context, ScpArgMsg("GiveGuildLeaderPermission"),
                string.format("SEND_REQ_GUILD_MASTER('%s')", name));
        end
    end

    if isLeader == 1 then
        local count = session.party.GetAllMemberCount(PARTY_GUILD);
        if count == 1 then
            ui.AddContextMenuItem(context, ScpArgMsg("Disband"), "DESTROY_GUILD()");
        end
    else
        if aid == myAid then
            ui.AddContextMenuItem(context, ScpArgMsg("GULID_OUT"), "OUT_GUILD_CHECK()");
        end
    end

    if isLeader == 1 and aid ~= myAid then
        local summonSkl = GetClass('Skill', 'Templer_SummonGuildMember');
        ui.AddContextMenuItem(context, summonSkl.Name, string.format("SUMMON_GUILD_MEMBER('%s')", aid));
    end

    if isLeader == 1 and aid ~= myAid then
        local goSkl = GetClass('Skill', 'Templer_WarpToGuildMember');
        ui.AddContextMenuItem(context, goSkl.Name, string.format("WARP_GUILD_MEMBER('%s')", aid));
    end

    ui.AddContextMenuItem(context, ScpArgMsg("WHISPER"), string.format("ui.WhisperTo('%s')", name));
    ui.AddContextMenuItem(context, ScpArgMsg("Cancel"), "None");

    ui.AddContextMenuItem(context, "-----", "None")

    ui.AddContextMenuItem(context, ScpArgMsg('ShowInfomation'), string.format("ui.Chat('%s')", "/memberinfo " .. name))
    ui.OpenContextMenu(context);

end

function MINI_ADDONS_CONTEXT_PARTY(frame, ctrl, aid)
    if g.settings.memberinfo ~= 1 then
        base["MINI_ADDONS_CONTEXT_PARTY"](frame, ctrl, aid)
    else
        MINI_ADDONS_CONTEXT_PARTY_(frame, ctrl, aid)
    end
end

function MINI_ADDONS_CONTEXT_PARTY_(frame, ctrl, aid)
    local myAid = session.loginInfo.GetAID();
    local pcparty = session.party.GetPartyInfo();
    local iamLeader = false;
    if pcparty.info:GetLeaderAID() == myAid then
        iamLeader = true;
    end

    local myInfo = session.party.GetPartyMemberInfoByAID(PARTY_NORMAL, myAid);
    local memberInfo = session.party.GetPartyMemberInfoByAID(PARTY_NORMAL, aid);
    local context = ui.CreateContextMenu("CONTEXT_PARTY", "", 0, 0, 170, 100);
    if session.world.IsIntegrateServer() == true and session.world.IsIntegrateIndunServer() == false then
        local actor = GetMyActor();
        local execScp = string.format("ui.Chat(\"/changePVPObserveTarget %d 0\")", memberInfo:GetHandle());
        ui.AddContextMenuItem(context, ScpArgMsg("Observe{PC}", 'PC', memberInfo:GetName()), execScp);
        ui.OpenContextMenu(context);
        return;
    end

    if aid == myAid then
        -- 1. 누구든 자기 자신.
        ui.AddContextMenuItem(context, ScpArgMsg("WithdrawParty"), "OUT_PARTY()");
    elseif iamLeader == true then
        -- 2. 파티장이 파티원 우클릭
        -- 대화하기. 세부정보보기. 파티장 위임. 추방.
        ui.AddContextMenuItem(context, ScpArgMsg("WHISPER"), string.format("ui.WhisperTo('%s')", memberInfo:GetName()));
        local strRequestAddFriendScp = string.format("friends.RequestRegister('%s')", memberInfo:GetName());
        ui.AddContextMenuItem(context, ScpArgMsg("ReqAddFriend"), strRequestAddFriendScp);
        --[[ui.AddContextMenuItem(context, ScpArgMsg("ShowInfomation"),
            string.format("OPEN_PARTY_MEMBER_INFO(%d)", memberInfo:GetHandle()));]]
        ui.AddContextMenuItem(context, ScpArgMsg("GiveLeaderPermission"),
            string.format("GIVE_PARTY_LEADER(\"%s\")", memberInfo:GetName()));
        ui.AddContextMenuItem(context, ScpArgMsg("Ban"), string.format("BAN_PARTY_MEMBER(\"%s\")", memberInfo:GetName()));

        if session.world.IsDungeon() and session.world.IsIntegrateIndunServer() == true then
            local aid = memberInfo:GetAID();
            local serverName = GetServerNameByGroupID(GetServerGroupID());
            local playerName = memberInfo:GetName();
            local scp =
                string.format("SHOW_INDUN_BADPLAYER_REPORT(\"%s\", \"%s\", \"%s\")", aid, serverName, playerName);
            ui.AddContextMenuItem(context, ScpArgMsg("IndunBadPlayerReport"), scp);
        end
    else
        -- 3. 파티원이 파티원 우클릭
        -- 대화하기. 세부 정보 보기.
        ui.AddContextMenuItem(context, ScpArgMsg("WHISPER"), string.format("ui.WhisperTo('%s')", memberInfo:GetName()));
        local strRequestAddFriendScp = string.format("friends.RequestRegister('%s')", memberInfo:GetName());
        ui.AddContextMenuItem(context, ScpArgMsg("ReqAddFriend"), strRequestAddFriendScp);
        --[[ui.AddContextMenuItem(context, ScpArgMsg("ShowInfomation"),
            string.format("OPEN_PARTY_MEMBER_INFO(%d)", memberInfo:GetHandle()));]]

        if session.world.IsDungeon() and session.world.IsIntegrateIndunServer() == true then
            local aid = memberInfo:GetAID();
            local serverName = GetServerNameByGroupID(GetServerGroupID());
            local playerName = memberInfo:GetName();
            local scp =
                string.format("SHOW_INDUN_BADPLAYER_REPORT(\"%s\", \"%s\", \"%s\")", aid, serverName, playerName);
            ui.AddContextMenuItem(context, ScpArgMsg("IndunBadPlayerReport"), scp);
        end
    end

    ui.AddContextMenuItem(context, ScpArgMsg("Cancel"), "None");

    ui.AddContextMenuItem(context, "-----", "None")
    local playerName = memberInfo:GetName();
    ui.AddContextMenuItem(context, ScpArgMsg('ShowInfomation'),
        string.format("ui.Chat('%s')", "/memberinfo " .. playerName))
    ui.OpenContextMenu(context);
end

function MINI_ADDONS_SHOW_PC_CONTEXT_MENU(handle)
    if g.settings.memberinfo ~= 1 then
        base["MINI_ADDONS_SHOW_PC_CONTEXT_MENU"](handle)
    else
        MINI_ADDONS_SHOW_PC_CONTEXT_MENU_(handle)
    end
end

function MINI_ADDONS_SHOW_PC_CONTEXT_MENU_(handle)
    if world.IsPVPMap() == true or session.colonywar.GetIsColonyWarMap() == true or IS_IN_EVENT_MAP() == true then
        return;
    end

    local pcObj = world.GetActor(handle);
    if pcObj == nil then
        return;
    end

    local targetInfo = info.GetTargetInfo(handle);
    if targetInfo.IsDummyPC == 1 then
        -- 유체이탈 or 환영 클릭해도 아무반응 없도록 한다.
        local is_enable = true;
        local cid = info.GetCID(handle);
        if cid ~= nil and cid ~= "" and cid ~= "None" then
            local ies_obj = GetPCObjectByCID(cid);
            if ies_obj ~= nil then
                if IsBuffApplied(ies_obj, "Illusion_Buff") == "YES" then
                    is_enable = false;
                end
            end
        end
        if targetInfo.isSkillObj == 0 and is_enable == true then
            POPUP_DUMMY(handle, targetInfo);
        end
        return
    end

    local strscp
    if pcObj:IsMyPC() == 1 then
        if 1 == session.IsGM() then
            local contextMenuCtrlName = string.format("{@st41}%s (%d){/}", pcObj:GetPCApc():GetFamilyName(), handle);
            local context = ui.CreateContextMenu("PC_CONTEXT_MENU", pcObj:GetPCApc():GetFamilyName(), 0, 0, 100, 100);

            strscp = string.format("ui.Chat(\"//runscp TEST_SERVPOS %d\")", handle);
            ui.AddContextMenuItem(context, ScpArgMsg("Auto_{@st42b}SeoBeowiChiBoKi{/}"), strscp);

            strscp = string.format("debug.TestNode(%d)", handle);
            ui.AddContextMenuItem(context, ScpArgMsg("Auto_{@st42b}NodeBoKi{/}"), strscp);

            strscp = string.format("debug.CheckModelFilePath(%d)", handle);
            ui.AddContextMenuItem(context, ScpArgMsg("Auto_{@st42b}XACTegSeuChyeoKyeongLo{/}"), strscp);

            strscp = string.format("debug.TestSnapTexture(%d)", handle);
            ui.AddContextMenuItem(context, "{@st42b}SnapTexture{/}", strscp);

            strscp = string.format("debug.TestShowBoundingBox(%d)", handle);
            ui.AddContextMenuItem(context, ScpArgMsg("Auto_{@st42b}BaunDingBagSeuBoKi{/}"), strscp);

            strscp = string.format("SCR_OPER_RELOAD_HOTKEY(%d)", handle);
            ui.AddContextMenuItem(context, "ReloadHotKey", strscp);

            strscp = string.format("SCR_CLIENTTESTSCP(%d)", handle);
            ui.AddContextMenuItem(context, "ClientTestScp", strscp);

            ui.OpenContextMenu(context);

            return context;
        end

    end

    local partyinfo = session.party.GetPartyInfo();
    local accountObj = GetMyAccountObj();
    if pcObj:IsMyPC() == 0 and info.IsPC(pcObj:GetHandleVal()) == 1 then
        if targetInfo.IsDummyPC == 1 then
            packet.DummyPCDialog(handle);
            return context;
        end

        local contextMenuCtrlName = string.format("{@st41}%s (%d){/}", pcObj:GetPCApc():GetFamilyName(), handle);
        local context = ui.CreateContextMenu("PC_CONTEXT_MENU", pcObj:GetPCApc():GetFamilyName(), 0, 0, 270, 100);

        -- 여기에 캐릭터 정보보기, 로그아웃PC관련 메뉴 추가하면됨
        if session.world.IsIntegrateServer() == false then
            local strScp = string.format("exchange.RequestChange(%d)", pcObj:GetHandleVal());
            ui.AddContextMenuItem(context, "{img context_transaction 18 18} " .. ClMsg("Exchange"), strScp);

            local strWhisperScp = string.format("ui.WhisperTo('%s')", pcObj:GetPCApc():GetFamilyName());
            ui.AddContextMenuItem(context, "{img context_whisper 18 17} " .. ClMsg("WHISPER"), strWhisperScp);
            strScp = string.format("PARTY_INVITE(\"%s\")", pcObj:GetPCApc():GetFamilyName());
            ui.AddContextMenuItem(context, "{img context_party_invitation 18 17} " .. ClMsg("PARTY_INVITE"), strScp);

            --[[
			if AM_I_LEADER(PARTY_GUILD) == 1 or IS_GUILD_AUTHORITY(1, session.loginInfo.GetAID()) == 1 then
				strScp = string.format("GUILD_INVITE(\"%s\")", pcObj:GetPCApc():GetFamilyName());
				ui.AddContextMenuItem(context, ClMsg("GUILD_INVITE"), strScp);
			end
			--]]
            if session.party.GetPartyInfo(PARTY_GUILD) ~= nil and targetInfo.hasGuild == false then
                strScp = string.format("GUILD_INVITE(\"%s\")", pcObj:GetPCApc():GetFamilyName());
                ui.AddContextMenuItem(context, "{img context_guild_invitation 18 17} " .. ClMsg("GUILD_INVITE"), strScp);
            end

            strscp = string.format("barrackNormal.Visit(%d)", handle);
            ui.AddContextMenuItem(context, "{img context_lodging_visit 16 17} " .. ScpArgMsg("VisitBarrack"), strscp);
            strscp = string.format("ui.ToggleHeaderText(%d)", handle);
            if pcObj:GetHeaderText() ~= nil and string.len(pcObj:GetHeaderText()) ~= 0 then
                if pcObj:IsHeaderTextVisible() == true then
                    ui.AddContextMenuItem(context, "{img context_preface_block 18 17} " .. ClMsg("BlockTitleText"),
                        strscp);
                else
                    ui.AddContextMenuItem(context, "{img context_preface_remove 18 17} " .. ClMsg("UnblockTitleText"),
                        strscp);
                end
            end
        end

        if session.world.IsIntegrateServer() == false then
            local strRequestAddFriendScp = string.format("friends.RequestRegister('%s')",
                pcObj:GetPCApc():GetFamilyName());
            ui.AddContextMenuItem(context, "{img context_friend_application 18 13} " .. ScpArgMsg("ReqAddFriend"),
                strRequestAddFriendScp);
        end

        ui.AddContextMenuItem(context, "{img context_friendly_match 18 17} " .. ScpArgMsg("RequestFriendlyFight"),
            string.format("REQUEST_FIGHT(\"%d\")", pcObj:GetHandleVal()));
        -- ui.AddContextMenuItem(context, ScpArgMsg("RequestFriendlyAncientFight"), string.format("REQUEST_ANCIENT_FIGHT(\"%d\")", pcObj:GetHandleVal()));

        local mapprop = session.GetCurrentMapProp();
        local mapCls = GetClassByType("Map", mapprop.type);
        if IS_TOWN_MAP(mapCls) == true then
            ui.AddContextMenuItem(context, "{img context_personal_housing 18 17} " .. ScpArgMsg("PH_SEL_DLG_2"),
                string.format("REQUEST_PERSONAL_HOUSING_WARP(\"%s\")", pcObj:GetPCApc():GetAID()));
        end

        local familyname = pcObj:GetPCApc():GetFamilyName()
        local otherpcinfo = session.otherPC.GetByFamilyName(familyname);

        if session.world.IsIntegrateServer() == false then
            local strRequestLikeItScp = string.format("SEND_PC_INFO(%d)", handle);
            if session.likeit.AmILikeYou(familyname) == true then
                ui.AddContextMenuItem(context, "{img context_like 18 17} " .. ScpArgMsg("ReqUnlikeIt"),
                    strRequestLikeItScp);
            else
                ui.AddContextMenuItem(context, "{img context_like 18 17} " .. ScpArgMsg("ReqLikeIt"),
                    strRequestLikeItScp);
            end
        end

        ui.AddContextMenuItem(context, "{img context_automatic_suspicion 16 17} " .. ScpArgMsg("Report_AutoBot"),
            string.format("REPORT_AUTOBOT_MSGBOX(\"%s\")", pcObj:GetPCApc():GetFamilyName()));

        -- report guild emblem
        if pcObj:IsGuildExist() == true then
            ui.AddContextMenuItem(context,
                "{img context_inappropriate_emblem 17 17} " .. ScpArgMsg("Report_GuildEmblem"), string.format(
                    "REPORT_GUILDEMBLEM_MSGBOX(\"%s\")", pcObj:GetPCApc():GetFamilyName()));
        end

        -- 보호모드, 강제킥
        if 1 == session.IsGM() then
            ui.AddContextMenuItem(context, ScpArgMsg("GM_Order_Protected"),
                string.format("REQUEST_GM_ORDER_PROTECTED(\"%s\")", pcObj:GetPCApc():GetFamilyName()));
            ui.AddContextMenuItem(context, ScpArgMsg("GM_Order_Kick"),
                string.format("REQUEST_GM_ORDER_KICK(\"%s\")", pcObj:GetPCApc():GetFamilyName()));
        end

        if session.world.IsDungeon() and session.world.IsIntegrateIndunServer() == true then
            local aid = pcObj:GetPCApc():GetAID();
            local serverName = GetServerNameByGroupID(GetServerGroupID());
            local playerName = pcObj:GetPCApc():GetFamilyName();
            local scp =
                string.format("SHOW_INDUN_BADPLAYER_REPORT(\"%s\", \"%s\", \"%s\")", aid, serverName, playerName);
            ui.AddContextMenuItem(context, ScpArgMsg("IndunBadPlayerReport"), scp);
        end

        ui.AddContextMenuItem(context, "{img context_cancel 18 17} " .. ClMsg("Cancel"), "None");
        ui.AddContextMenuItem(context, "-----", "None")
        strscp = string.format("PROPERTY_COMPARE(%d)", handle);
        ui.AddContextMenuItem(context, "{img context_look_into 18 17} " .. ScpArgMsg("Auto_SalPyeoBoKi"), strscp);

        ui.OpenContextMenu(context);
        return context;
    end
end

function MINI_ADDONS_POPUP_DUMMY(handle, targetInfo)
    if g.settings.memberinfo ~= 1 then
        base["POPUP_DUMMY"](handle, targetInfo)
    else
        MINI_ADDONS_POPUP_DUMMY_(handle, targetInfo)
    end
end

function MINI_ADDONS_POPUP_DUMMY_(handle, targetInfo)
    local context = ui.CreateContextMenu("DPC_CONTEXT", targetInfo.name, 0, 0, 100, 100);

    local ownerHandle = info.GetOwner(handle);
    local myHandle = session.GetMyHandle();

    local strscp

    --  매입의뢰상점후 핼퍼 고용 메시지 제거	
    --	if ownerHandle == 0 then
    --		strscp = string.format("DUMMYPC_HIRE(%d)", handle);
    --		ui.AddContextMenuItem(context, ScpArgMsg("Auto_yongByeongKoyong"), strscp);
    --
    --	elseif ownerHandle == myHandle then
    --		strscp = string.format("dummyPC.Fire(%d)", handle);
    --		ui.AddContextMenuItem(context, ScpArgMsg("Auto_yongByeongHaeKo"), strscp);
    --	end

    if 1 == session.IsGM() then
        strscp = string.format("debug.TestE(%d)", handle);
        ui.AddContextMenuItem(context, ScpArgMsg("Auto_{@st42b}NodeBoKi{/}"), strscp);
        strscp = string.format("ui.Chat(\"//killmon %d\")", handle);
        ui.AddContextMenuItem(context, ScpArgMsg("Auto_JeKeo"), strscp)
        ui.AddContextMenuItem(context, ScpArgMsg("GM_Order_Kick"),
            string.format("REQUEST_ORDER_DUMMY_KICK(\"%s\")", handle))
    end

    if session.world.IsIntegrateServer() == false then
        strscp = string.format("barrackNormal.Visit(%d)", handle);
        ui.AddContextMenuItem(context, ScpArgMsg("VisitBarrack"), strscp);

    end

    ui.AddContextMenuItem(context, ScpArgMsg("Auto_DatKi"), "")

    ui.AddContextMenuItem(context, "-----", "None")

    strscp = string.format("PROPERTY_COMPARE(%d)", handle);
    ui.AddContextMenuItem(context, ScpArgMsg("Auto_SalPyeoBoKi"), strscp);
    ui.OpenContextMenu(context)
end

-- EP13ショップを街で開ける
function mini_addons_REPUTATION_SHOP_OPEN_context(frame, ctrl, str, num)

    function mini_addons_ON_REQUEST_REPUTATION_SHOP_OPEN(shop_type)
        -- print(tostring(shop_type))
        REPUTATION_SHOP_SET_SHOPTYPE(shop_type)
        ui.OpenFrame("reputation_shop")
    end

    local context = ui.CreateContextMenu("select_shop", "EP13 Shop List ", 0, 0, 0, 0)
    local shop_tbl = {{
        name = "REPUTATION_ep13_f_siauliai_1",
        id = 11209
    }, {
        name = "REPUTATION_ep13_f_siauliai_2",
        id = 11210
    }, {
        name = "REPUTATION_ep13_f_siauliai_3",
        id = 11211
    }, {
        name = "REPUTATION_ep13_f_siauliai_4",
        id = 11212
    }, {
        name = "REPUTATION_ep13_f_siauliai_5",
        id = 11213
    }}

    for index, shop in ipairs(shop_tbl) do
        local shop_name = shop.name
        local id = shop.id
        local map_name = GetClassByType("Map", id).Name
        ui.AddContextMenuItem(context, map_name,
            string.format("mini_addons_ON_REQUEST_REPUTATION_SHOP_OPEN('%s')", shop_name))
    end
    ui.OpenContextMenu(context)
end

function mini_addons_reputation_shop_close()
    local shopframe = ui.GetFrame("reputation_shop")
    if shopframe:IsVisible() == 1 then
        ui.CloseFrame("reputation_shop")
        ui.ToggleFrame('inventory');
    end
end

function MINI_ADDONS_NOTICE_ON_MSG_baubas(frame, msg)

    local frame, msg, str, num = acutil.getEventArgs(msg)

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
    local edit = chatframe:GetChild('mainchat');
    AUTO_CAST(edit)
    edit:RunEnterKeyScript();
    ui.ProcessReturnKey()
    chatframe:ShowWindow(0)
end

-- testcode
-- _G.imcAddOn.BroadMsg('NOTICE_Dm_Global_Shout', _G.ScpArgMsg('AppearFieldBoss_ep14_2_d_castle_3{name}', 'name', "name"),
--   1)
-- _G.imcAddOn.BroadMsg('NOTICE_Dm_Global_Shout',
--   _G.ScpArgMsg('{name}DisappearFieldBoss', 'name', "맹화의 바우바스"), 1)

function MINI_ADDONS_ON_INIT(addon, frame)
    g.addon = addon
    g.frame = frame
    g.cid = info.GetCID(session.GetMyHandle())
    g.lang = option.GetCurrentCountry()

    MINI_ADDONS_LOAD_SETTINGS()

    g.SetupHook(MINI_ADDONS_CHAT_RBTN_POPUP, "CHAT_RBTN_POPUP")
    g.SetupHook(MINI_ADDONS_POPUP_GUILD_MEMBER, "POPUP_GUILD_MEMBER")
    g.SetupHook(MINI_ADDONS_CONTEXT_PARTY, "CONTEXT_PARTY") -- SHOW_PC_CONTEXT_MENU(handle)
    g.SetupHook(MINI_ADDONS_SHOW_PC_CONTEXT_MENU, "SHOW_PC_CONTEXT_MENU")
    g.SetupHook(MINI_ADDONS_POPUP_DUMMY, "POPUP_DUMMY")
    -- g.SetupHook(MINI_ADDONS_ACCOUNTPROP_INVENTORY_UPDATE, "ACCOUNTPROP_INVENTORY_UPDATE")

    g.call = {}
    acutil.setupEvent(addon, "NOTICE_ON_MSG", "MINI_ADDONS_NOTICE_ON_MSG_baubas")

    if g.settings.group_chat == 1 then

        addon:RegisterMsg("GAME_START_3SEC", "MINI_ADDONS_CHAT_CREATE_OR_UPDATE_GROUP_LIST_3SEC")
        acutil.setupEvent(addon, "CHAT_GROUPLIST_SELECT_LISTTYPE", "MINI_ADDONS_CHAT_GROUPLIST_SELECT_LISTTYPE");
        acutil.setupEvent(addon, "CHAT_GROUPLIST_OPTION_OK", "MINI_ADDONS_CHAT_GROUPLIST_OPTION_OK");
        acutil.setupEvent(addon, "GROUPCHAT_OUT", "MINI_ADDONS_GROUPCHAT_OUT");
        acutil.setupEvent(addon, "CREATE_NEW_GROUPCHAT", "MINI_ADDONS_CREATE_NEW_GROUPCHAT");
    end

    local map = GetClass('Map', session.GetMapName());
    local keyword = TryGetProp(map, 'Keyword', 'None');
    local keyword_table = StringSplit(keyword, ';');
    if table.find(keyword_table, 'IsRaidField') > 0 and g.settings.vakarine == 1 then
        addon:RegisterMsg('GAME_START', "MINI_ADDONS_VAKARINE_NOTICE")
    end

    g.SetupHook(MINI_ADDONS_EARTHTOWERSHOP_CHANGECOUNT_NUM_CHANGE, "EARTHTOWERSHOP_CHANGECOUNT_NUM_CHANGE")
    g.SetupHook(MINI_ADDONS_INDUNENTER_REQ_UNDERSTAFF_ENTER_ALLOW, "INDUNENTER_REQ_UNDERSTAFF_ENTER_ALLOW")
    g.SetupHook(MINI_ADDONS_INDUN_EDITMSGBOX_FRAME_OPEN, "INDUN_EDITMSGBOX_FRAME_OPEN")
    if g.settings.velnice.use == 1 then
        addon:RegisterMsg("SOLO_D_TIMER_TEXT_GAUGE_UPDATE", "MINI_ADDONS_SOLO_D_TIMER_UPDATE_TEXT_GAUGE");
        g.velnice = 0
    end

    -- IMCのON_PARTYINFO_BUFFLIST_UPDATEを削除
    g.SetupHook(mini_addons_basefunction_old, "ON_PARTYINFO_BUFFLIST_UPDATE")
    addon:RegisterMsg("PARTY_BUFFLIST_UPDATE", "MINI_ADDONS_ON_PARTYINFO_BUFFLIST_UPDATE")
    addon:RegisterMsg("PARTY_INST_UPDATE", "MINI_ADDONS_ON_PARTYINFO_INST_UPDATE")
    -- g.SetupHook(MINI_ADDONS_ON_PARTYINFO_BUFFLIST_UPDATE, "ON_PARTYINFO_BUFFLIST_UPDATE")

    g.SetupHook(MINI_ADDONS_CHAT_SYSTEM, "CHAT_SYSTEM")
    g.SetupHook(MINI_ADDONS_UPDATE_CURRENT_CHANNEL_TRAFFIC, "UPDATE_CURRENT_CHANNEL_TRAFFIC")
    g.SetupHook(MINI_ADDONS_NOTICE_ON_MSG, "NOTICE_ON_MSG")
    g.SetupHook(MINI_ADDONS_CHAT_TEXT_LINKCHAR_FONTSET, "CHAT_TEXT_LINKCHAR_FONTSET")

    g.SetupHook(MINI_ADDONS_INVENTORY_TOTAL_LIST_GET, 'INVENTORY_TOTAL_LIST_GET')

    g.SetupHook(MINI_ADDONS_COMMON_EQUIP_UPGRADE_PROGRESS, "COMMON_EQUIP_UPGRADE_PROGRESS")
    acutil.setupEvent(addon, "COMMON_EQUIP_UPGRADE_OPEN", "MINI_ADDONS_COMMON_EQUIP_UPGRADE_OPEN");

    acutil.setupEvent(addon, "MARKET_SELL_UPDATE_REG_SLOT_ITEM", "MINI_ADDONS_MARKET_SELL_UPDATE_REG_SLOT_ITEM");
    acutil.setupEvent(addon, "OPEN_WORLDMAP2_MINIMAP", "MINI_ADDONS_OPEN_WORLDMAP2_MINIMAP");
    -- !

    local frame = ui.GetFrame("cupole_external_addon")
    frame:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_CUPOLE_PORTION_FRAME_SAVE")
    acutil.setupEvent(addon, "TOGGLE_CUPOLE_EXTERNAL_ADDON", "MINI_ADDONS_TOGGLE_CUPOLE_EXTERNAL_ADDON")

    if g.settings.separated_buff == 1 then
        local frame = ui.GetFrame("buff_separatedlist")
        local gbox = GET_CHILD_RECURSIVELY(frame, "gbox")
        AUTO_CAST(gbox)
        gbox:SetSkinName("None")
    else
        local frame = ui.GetFrame("buff_separatedlist")
        local gbox = GET_CHILD_RECURSIVELY(frame, "gbox")
        AUTO_CAST(gbox)
        gbox:SetSkinName("chat_window")
    end

    if g.settings.raid_record == 1 then
        acutil.setupEvent(addon, "RAID_RECORD_INIT", "MINI_ADDONS_RAID_RECORD_INIT")
    end

    if g.settings.my_effect == 1 then
        addon:RegisterMsg("GAME_START_3SEC", "MINI_ADDONS_MY_EFFECT_SETTING")
    end

    if g.settings.other_effect == 1 then
        addon:RegisterMsg("GAME_START_3SEC", "MINI_ADDONS_OTHER_EFFECT_SETTING")
    end

    if g.settings.equip_info == 1 then
        acutil.setupEvent(addon, "SHOW_INDUNENTER_DIALOG", "MINI_ADDONS_SHOW_INDUNENTER_DIALOG");
    end

    if g.settings.automatch_layer == 1 then
        acutil.setupEvent(addon, "INDUNENTER_AUTOMATCH_TYPE", "MINI_ADDONS_INDUNENTER_AUTOMATCH_TYPE");
    elseif g.settings.automatch_layer == 0 then
        local ideframe = ui.GetFrame("indunenter");
        ideframe:SetLayerLevel(100)
    end

    if g.settings.quest_hide == 1 then
        addon:RegisterMsg("GAME_START", "MINI_ADDONS_QUESTINFO_HIDE_RESERVE")
        acutil.setupEvent(addon, "INVENTORY_OPEN", "MINI_ADDONS_QUESTINFO_HIDE_RESERVE");
        acutil.setupEvent(addon, "INVENTORY_CLOSE", "MINI_ADDONS_QUESTINFO_HIDE_RESERVE");
    end

    if g.settings.restart_move == 1 then
        addon:RegisterMsg("RESTART_HERE", "MINI_ADDONS_FRAME_MOVE")
        addon:RegisterMsg("RESTART_CONTENTS_HERE", "MINI_ADDONS_FRAME_MOVE")
        acutil.setupEvent(addon, "RESTART_CONTENTS_ON_HERE", "MINI_ADDONS_RESTART_CONTENTS_ON_HERE");
        g.mouse = false
    end

    if g.settings.dialog_ctrl == 1 then
        addon:RegisterMsg("DIALOG_CHANGE_SELECT", "MINI_ADDONS_DIALOG_CHANGE_SELECT")
    end

    if g.settings.pc_name == 1 then
        -- addon:RegisterMsg("FPS_UPDATE", "MINI_ADDONS_PCNAME_REPLACE")
        acutil.setupEvent(addon, 'HEADSUPDISPLAY_ON_MSG', "MINI_ADDONS_PCNAME_REPLACE")
    end

    acutil.setupEvent(addon, "CONFIG_ENABLE_AUTO_CASTING", "MINI_ADDONS_CONFIG_ENABLE_AUTO_CASTING");
    if g.settings.auto_cast == 1 then
        addon:RegisterMsg("GAME_START_3SEC", "MINI_ADDONS_SET_ENABLE_AUTO_CASTING_3SEC")
    end

    if g.settings.channel_info == 1 then
        addon:RegisterMsg("GAME_START_3SEC", "MINI_ADDONS_GAME_START_CHANNEL_LIST")
    end

    if g.settings.relic_gauge == 1 then
        addon:RegisterMsg("GAME_START", "MINI_ADDONS_CHARBASE_RELIC")
        addon:RegisterMsg("RP_UPDATE", "MINI_ADDONS_CHARBASE_RELIC")
    end

    if g.settings.raid_check == 1 then
        g.settings.raid_check = 0
        MINI_ADDONS_SAVE_SETTINGS()
        -- acutil.setupEvent(addon, 'ACCOUNTWAREHOUSE_OPEN', "MINI_ADDONS_CHECK_DREAMY_ABYSS")
    end

    if g.settings.party_info == 1 then
        local piframe = ui.GetFrame('partyinfo')
        local tooltip = piframe:CreateOrGetControl("richtext", "tooltip", 0, 0, 170, 60)
        AUTO_CAST(tooltip)
        tooltip:SetText("{s30}                             ")
        tooltip:SetTextTooltip("{ol}Right-click to switch display for mouse mode")
        acutil.setupEvent(addon, "SET_PARTYINFO_ITEM", "MINI_ADDONS_SET_PARTYINFO_ITEM");
        g.partyinfo = 0
    end

    if session.weeklyboss.GetNowWeekNum() == 0 then
        weekly_boss.RequestWeeklyBossNowWeekNum()
    end

    local pc = GetMyPCObject();
    local curMap = GetZoneName(pc)
    local mapCls = GetClass("Map", curMap)

    local inv = ui.GetFrame("inventory")
    local inventory_accpropinv = GET_CHILD_RECURSIVELY(inv, "inventory_accpropinv")
    AUTO_CAST(inventory_accpropinv)

    if mapCls.MapType == "City" then

        inventory_accpropinv:SetEventScript(ui.RBUTTONUP, "mini_addons_REPUTATION_SHOP_OPEN_context")
        inventory_accpropinv:SetEventScript(ui.RBUTTONDOWN, "mini_addons_reputation_shop_close")

        if g.settings.goodbye_ragana == 1 then
            addon:RegisterMsg("GAME_START", "mini_addons_ragana_remove_timer");
        end

        if g.settings.weekly_boss_reward == 1 then

            addon:RegisterMsg("GAME_START_3SEC", "MINI_ADDONS_WEEKLY_BOSS_REWARD")
        end

        if g.settings.coin_use == 1 then
            addon:RegisterMsg('INV_ITEM_ADD', "MINI_ADDONS_INV_ICON_USE")
            addon:RegisterMsg('INV_ITEM_REMOVE', 'MINI_ADDONS_INV_ICON_USE')
        end

        if g.settings.market_display == 1 then
            addon:RegisterMsg("GAME_START", "MINIMIZED_TOTAL_SHOP_BUTTON_CLICK")
        end

        if g.settings.skill_enchant == 1 then
            acutil.setupEvent(addon, "COMMON_SKILL_ENCHANT_MAT_SET", "MINI_ADDONS_COMMON_SKILL_ENCHANT_MAT_SET");
            acutil.setupEvent(addon, "SUCCESS_COMMON_SKILL_ENCHANT", "MINI_ADDONS_SUCCESS_COMMON_SKILL_ENCHANT");
        end

        if g.settings.auto_gacha == 1 then
            addon:RegisterMsg('FIELD_BOSS_WORLD_EVENT_START', 'MINI_ADDONS_GP_DO_OPEN');
            addon:RegisterMsg('FIELD_BOSS_WORLD_EVENT_END', 'MINI_ADDONS_FIELD_BOSS_WORLD_EVENT_END');
        end

        MINI_ADDONS_GP_FULL_BET()

        if g.settings.bgm == 1 then
            addon:RegisterMsg("FPS_UPDATE", "MINI_ADDONS_BGM_PLAY_LIST")
            addon:RegisterMsg("GAME_START", "MINI_ADDONS_BGM_PLAY")
        end
    elseif mapCls.MapType ~= "City" then
        ui.CloseFrame("bgmplayer_reduction")
        local max_frame = ui.GetFrame("bgmplayer");
        local play_btn = GET_CHILD_RECURSIVELY(max_frame, "playStart_btn");
        MINIADDONS_BGMPLAYER_PLAY(max_frame, play_btn);

        inventory_accpropinv:SetEventScript(ui.RBUTTONUP, "None")
        inventory_accpropinv:SetEventScript(ui.RBUTTONDOWN, "None")
    end

    if g.settings.mini_btn == 1 then
        if mapCls.MapType ~= "Field" and mapCls.MapType ~= "City" then
            addon:RegisterMsg("GAME_START", "MINI_ADDONS_MINIMIZED_CLOSE")
        end
    end

    MINI_ADDONS_NEW_FRAME_INIT()
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

    if g.settings.cupole_portion.use == 1 then -- !
        frame:ShowWindow(0)
    elseif frame:IsVisible() == 1 then
        if g.settings.cupole_portion.x == 0 and g.settings.cupole_portion.y == 0 then
            frame:SetPos(g.settings.cupole_portion.def_x, g.settings.cupole_portion.def_y)
        else
            frame:SetPos(g.settings.cupole_portion.x, g.settings.cupole_portion.y)
            -- frame:SetMargin(g.settings.cupole_portion.x, 0, 0, 0)
            -- local margin = frame:GetMargin()
            -- print(margin.left .. ":" .. margin.top .. ":" .. margin.right .. ":" .. margin.bottom)
        end
        frame:ShowWindow(1)
    end
end

-- 週間ボスレの報酬受け取り
g.wbreward = nil
function MINI_ADDONS_WEEKLY_BOSS_REWARD()

    local week_num = WEEKLY_BOSS_RANK_WEEKNUM_NUMBER();
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
            tab:SelectTab(3);

            INDUNINFO_TAB_CHANGE(tab, tab)

            local season_tab = GET_CHILD_RECURSIVELY(indun_info, "season_tab")
            AUTO_CAST(season_tab)
            season_tab:SelectTab(1);
            --[[local x, y = GET_SCREEN_XY(season_tab)
            mouse.SetPos(x + 5, y - 50);]]
            g.index = 0

            indun_info:RunUpdateScript("MINI_ADDONS_WEEKLY_BOSS_RANK_REWARD", 1.5)
        end
    end
end

function MINI_ADDONS_WEEKLY_BOSS_RANK_REWARD(indun_info)
    local classtype_tab = GET_CHILD_RECURSIVELY(indun_info, "classtype_tab")
    AUTO_CAST(classtype_tab)
    local frame = ui.GetFrame("weeklyboss_reward")

    classtype_tab:SelectTab(g.index);

    if g.index <= 4 then

        WEEKLY_BOSS_DATA_REUQEST();
        classtype_tab:RunUpdateScript("MINI_ADDONS_WEEKLY_BOSS_RANK_GET_REWARD", 1.0)
        --[[local x, y = GET_SCREEN_XY(classtype_tab)
        mouse.SetPos(x - 120 + g.index * 60, y + 5);]]
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

    local week_num = WEEKLY_BOSS_RANK_WEEKNUM_NUMBER();

    local myrank = session.weeklyboss.GetMyRankInfo(week_num);

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

    local frame = ui.GetFrame("systemoption")
    if g.settings.volume == nil or volume ~= 0 then
        g.settings.volume = volume
        MINI_ADDONS_SAVE_SETTINGS()
        config.SetTotalVolume(0);
        return
    end
    config.SetTotalVolume(g.settings.volume);
end

function MINI_ADDONS_LANG(str)
    -- !追加の度に更新
    if g.lang == "Japanese" then
        if str == "Skip confirmation for admission of 4 or less people" then
            str = "4人以下入場時の確認をスキップ"
        elseif str == "Raid records movable and resizable" then
            str = "レイドレコードを移動可能にしてサイズを変更"
        elseif str == "Hide buffs for party members" then
            str = "パーティーメンバーのバフを非表示にします"
        elseif str == "You can choose which buffs to display" then
            str = "表示するバフを選択できます"
        elseif str == "Perfect and Black Market notices not displayed in chat" then
            str = "パーフェクトとブラックマーケットのお知らせをチャットに表示しません"
        elseif str == "Fixed channel display misalignment for Japanese ver" then
            str = "チャンネル表示のズレを修正"
        elseif str == "Hide minibutton in upper right corner during raid" then
            str = "レイド時右上のミニボタン非表示"
        elseif str == "Keep shop list open when moving to town" then
            str = "街では、右上の商店一覧を常に表示します"
        elseif str == "Allow moving selection frame on restart" then
            str = "リスタート時の選択肢フレームを動かせる様にします"
        elseif str == "Automatic display of pet summon frame" then
            str = "ペット召喚フレームを自動表示"
        elseif str == "Controls various dialogs" then
            str = "各種ダイアログをコントロールします"
        elseif str == "Set auto casting per character" then
            str = "オートキャスティングをキャラ毎に設定"
        elseif str == "Automatically used when acquiring coin items" then
            str =
                "傭兵団コイン、シーズンコイン、王国再建団コインを取得時に自動で使用します"
        elseif str == "Notification of forgetting to equip ark and emblem upon entry to the hard raid" then
            str = "ハードレイド入場時にアークやエンブレムの装備忘れをお知らせします"
        elseif str == "Lower frame layer level during auto match" then
            str = "オートマッチ時のフレームのレイヤーレベルを下げます"
        elseif str == "Hide the quest list" then
            str = "クエストリストを非表示にします"
        elseif str == "Change the upper left display to the character's name" then
            str = "左上の表示をキャラクター名に変更します"
        elseif str == "Displays the channel switching frame" then
            str = "チャンネル切替フレームを表示します"
        elseif str == "Adjust my effects from 1 to 100" then
            str = "自分のエフェクトを調整します。1~100"
        elseif str == "Adjust other people's effects from 1 to 100, recommended 75" then
            str = "他人のエフェクトを調整します。1~100。おすすめは75"
        elseif str == "Automate the display of the Goddess Protection gacha frame" then
            str = "女神の加護ガチャフレーム表示を自動化します"
        elseif str == "When turned on, the gacha starts automatically.CC required for switching" then
            str = "ONにすると自動でガチャスタートします。切替にCC必要です"
        elseif str == "Automatically sets items for skill refining" then
            str = "スキル錬成のアイテムを自動でセットします"
        elseif str == "Add a Relic to the character's gauge" then
            str = "キャラクターゲージにレリックを追加します"
        elseif str == "Prevents character change mistakes during the hard raid on the Dreamy& Abyss" then
            str = "夢幻＆深淵のハードレイド時のキャラクターチェンジミスを防ぎます"
        elseif str == "Toggle party info frame. For mouse mode.Party info rightclick" then
            str =
                "パーティーフレームの表示切替。右クリックで小さくします。マウスモード用"
        elseif str == "The maximum coin limit for each store is raised to 99999" then
            str = "各商店のコインの上限を99999に引き上げます"
        elseif str == "Always move the BGM player in city" then
            str = "街でBGMプレイヤーを常に動かします"
        elseif str == "Notify others of vakarine equipment in raid" then
            str = "レイド時、ヴァカリネ装備を他人にお知らせ"
        elseif str == "Receive weekly boss reward automatically" then
            str = "週間ボスレイド報酬を自動で受け取り"
        elseif str == "Hide the potion frame of the cupole.Memorizes frame position even when OFF" then -- Hide Ragana in city
            str = "クポルのポーションフレームを非表示に。OFFでもフレームの位置記憶"
        elseif str == "Hide Ragana in city" then -- icor_status_search
            str = "街にいるラガナを非表示にします" -- Equip Refining, Automate weapon/armor enhancement
        elseif str == "Equip Refining, Automate weapon/armor enhancement" then
            str = "装備錬成、武器防具ステータス付与を自動化"
        elseif str == "Search the status of icor in the inventory" then
            str = "インベントリでイコルをステータス検索出来る様に" -- Remember the previous level of the Velnice dungeon
        elseif str == "Remember the previous level of the Velnice dungeon" then -- Eliminate around separate buff frame
            str = "ヴェルニケダンジョンの前回の階層を覚えます"
        elseif str == "Eliminate around separate buff frame" then -- Group chat selection can be selected from chat frame
            str = "セパレートバフフレームの周りを綺麗にします"
        elseif str == "Group chats can be selected from chat frame" then -- Group chat selection can be selected from chat frame
            str = "グループチャットをチャットフレームから選択出来ます" -- "Add member info to various rightclick menu"
        elseif str == "Add member info to various rightclick menu" then -- Announcing the arrival of Baubas
            str = "様々な右クリックメニューにメンバーインフォを追加します"
        elseif str == "Announcing the arrival of Baubas" then -- Announcing the arrival of Baubas
            str = "バウバス登場をお知らせ"
        elseif str == "Notification switch to guild chat" then
            str = "ギルドチャットへのお知らせ切替え"
        elseif str == "Check to enable" then
            str = "チェックすると有効化"
        elseif str == "※Character change is required to enable or disable some functions" then
            str = "※一部の機能の有効化、無効化の切替はキャラクターチェンジが必要です"
        end
    elseif g.lang == "kr" then
        if str == "Skip confirmation for admission of 4 or less people" then
            str = "4인 이하 입장 시 확인을 건너뜁니다"
        elseif str == "Raid records movable and resizable" then
            str = "레이드 기록의 이동이 가능하고, 크기 조절을 할 수 있습니다"
        elseif str == "Hide buffs for party members" then
            str = "파티원 버프를 숨깁니다"
        elseif str == "You can choose which buffs to display" then
            str = "표시할 버프를 선택할 수 있습니다"
        elseif str == "Perfect and Black Market notices not displayed in chat" then
            str = "완벽함 메시지 및 블랙 마켓 공지를 채팅에 표시 하지 않습니다"
        elseif str == "Fixed channel display misalignment for Japanese ver" then
            str = "일본어 버전의 채널 표시 정렬을 수정했습니다"
        elseif str == "Hide minibutton in upper right corner during raid" then
            str = "레이드 중 오른쪽 상단의 미니 버튼을 숨깁니다"
        elseif str == "Keep shop list open when moving to town" then
            str = "도시 이동 시 상점 목록을 항상 열어둡니다"
        elseif str == "Allow moving selection frame on restart" then
            str = "재시작 시 선택 프레임을 이동할 수 있게 합니다"
        elseif str == "Automatic display of pet summon frame" then
            str = "펫 소환 프레임을 자동으로 표시합니다"
        elseif str == "Controls various dialogs" then
            str = "각종 채팅을 제어합니다"
        elseif str == "Set auto casting per character" then
            str = "캐릭터별로 자동 시전 설정"
        elseif str == "Automatically used when acquiring coin items" then
            str =
                "용병단 증표, 시즌 여신의 증표, 왕국 재건단 주화를 획득할 때 자동으로 사용합니다"
        elseif str == "Notification of forgetting to equip ark and emblem upon entry to the hard raid" then
            str = "하드 레이드 입장시 아크 및 인장의 미착용을 알립니다"
        elseif str == "Lower frame layer level during auto match" then
            str = "자동 매칭 시 프레임 레이어 레벨을 낮춥니다"
        elseif str == "Hide the quest list" then
            str = "퀘스트 목록을 숨깁니다"
        elseif str == "Change the upper left display to the character's name" then
            str = "왼쪽 상단 표시를 캐릭터 이름으로 변경합니다"
        elseif str == "Displays the channel switching frame" then
            str = "채널 전환 프레임을 표시합니다"
        elseif str == "Adjust my effects from 1 to 100" then
            str = "자신의 효과를 조정합니다 1에서 100까지"
        elseif str == "Adjust other people's effects from 1 to 100, recommended 75" then
            str = "다른 사람의 이펙트를 1에서 100까지 조정합니다. 추천 75"
        elseif str == "Automate the display of the Goddess Protection gacha frame" then
            str = "여신의 가호 가챠 프레임 표시를 자동화합니다"
        elseif str == "When turned on, the gacha starts automatically.CC required for switching" then
            str = "ON으로 설정하면 자동으로 가챠가 시작됩니다. 전환 시 CC 필요합니다"
        elseif str == "Automatically sets items for skill refining" then
            str = "스킬 연성을 위한 아이템을 자동으로 설정합니다"
        elseif str == "Add a Relic to the character's gauge" then
            str = "캐릭터 게이지에 유물을 추가합니다"
        elseif str == "Prevents character change mistakes during the hard raid on the Dreamy& Abyss" then
            str = "몽환 & 심연의 하드 레이드 중 캐릭터 변경 실수를 방지합니다"
        elseif str == "Toggle party info frame. For mouse mode.Party info rightclick" then
            str = "파티 정보 프레임 표시 전환. 마우스 모드용. 오른쪽 클릭으로 작게 합니다"
        elseif str == "The maximum coin limit for each store is raised to 99999" then
            str = "각 상점의 코인 최대 한도를 99999로 올립니다"
        elseif str == "Always move the BGM player in city" then
            str = "도시에서 BGM 플레이어 항상 이동"
        elseif str == "Notify others of vakarine equipment in raid" then
            str = "레이드에서 바카리네 장비를 착용시 다른 플레이어에게 알립니다"
        elseif str == "Receive weekly boss reward automatically" then ---- Hide Ragana in city
            str = " 주간 보스 레이드 보상을 자동으로 수령"
        elseif str == "Hide the potion frame of the cupole.Memorizes frame position even when OFF" then
            str = "큐폴의 포션 프레임을 숨기고, OFF 상태에서도 프레임 위치를 기억합니다."
        elseif str == "Hide Ragana in city" then
            str = "도시에 있는 라가나를 숨깁니다"
        elseif str == "Equip Refining, Automate weapon/armor enhancement" then
            str = "장비 연성, 무기 방어구 스테이터스 부여 자동화"
        elseif str == "Search the status of icor in the inventory" then
            str = "인벤토리에서 'icor' 상태 검색하기"
        elseif str == "Remember the previous level of the Velnice dungeon" then
            str = "베르니케 던전의 이전 계층을 기억합니다"
        elseif str == "Eliminate around separate buff frame" then
            str = "분리형 버프 프레임 주변을 없앱니다"
        elseif str == "Group chats can be selected from chat frame" then -- Group chat selection can be selected from chat frame
            str = "채팅 프레임에서 그룹 채팅을 선택할 수 있습니다"
        elseif str == "Add member info to various rightclick menu" then
            str = "다양한 우클릭 메뉴에 회원 정보를 추가합니다"
        elseif str == "Announcing the arrival of Baubas" then -- Announcing the arrival of Baubas
            str = "바우버스 등장 소식" -- "Add member info to various rightclick menu"
        elseif str == "Notification switch to guild chat" then
            str = "길드 채팅으로 알림 전환"
        elseif str == "Check to enable" then
            str = "체크 시 활성화"
        elseif str == "※Character change is required to enable or disable some functions" then
            str = "※일부 기능을 활성화하거나 비활성화하려면 캐릭터 변경이 필요합니다"
        end
    end
    return str
end

function MINI_ADDONS_baubas_call_switch(frame, ctrl, str, num)
    if g.settings.baubas_call.guild_notice == 0 then

        g.settings.baubas_call.guild_notice = 1

    else
        g.settings.baubas_call.guild_notice = 0
    end
    MINI_ADDONS_SAVE_SETTINGS()
    MINI_ADDONS_SETTING_FRAME_INIT()
end

function MINI_ADDONS_SETTING_FRAME_INIT()
    local frame = ui.GetFrame("mini_addons")
    frame:SetSkinName("test_frame_midle_light")
    frame:SetLayerLevel(93)
    frame:EnableHittestFrame(1)
    frame:ShowTitleBar(0)
    frame:RemoveAllChild()
    frame:SetEventScript(ui.RBUTTONUP, "MINI_ADDONS_FRAME_CLOSE")

    local close = frame:CreateOrGetControl("button", "close", 615, 5, 30, 30)
    AUTO_CAST(close)
    close:SetGravity(ui.RIGHT, ui.TOP)
    close:SetSkinName("None")
    close:SetText("{img testclose_button 30 30}")
    close:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_FRAME_CLOSE")
    -- !
    local settings = {{
        name = "under_staff",
        check = g.settings.under_staff,
        text = "{ol}{#FF4500}" .. MINI_ADDONS_LANG("Skip confirmation for admission of 4 or less people")
    }, {
        name = "raid_record",
        check = g.settings.raid_record,
        text = "{ol}{#FF4500}" .. MINI_ADDONS_LANG("Raid records movable and resizable")
    }, {
        name = "party_buff",
        check = g.settings.party_buff,
        text = "{ol}{#FF4500}" .. MINI_ADDONS_LANG("Hide buffs for party members")
    }, {
        name = "chat_system",
        check = g.settings.chat_system,
        text = "{ol}{#FF4500}" .. MINI_ADDONS_LANG("Perfect and Black Market notices not displayed in chat")
    }, {
        name = "channel_display",
        check = g.settings.channel_display,
        text = "{ol}{#FF4500}" .. MINI_ADDONS_LANG("Fixed channel display misalignment for Japanese ver")
    }, {
        name = "mini_btn",
        check = g.settings.mini_btn,
        text = "{ol}{#FF4500}" .. MINI_ADDONS_LANG("Hide minibutton in upper right corner during raid")
    }, {
        name = "market_display",
        check = g.settings.market_display,
        text = "{ol}{#FF4500}" .. MINI_ADDONS_LANG("Keep shop list open when moving to town")
    }, {
        name = "restart_move",
        check = g.settings.restart_move,
        text = "{ol}{#FF4500}" .. MINI_ADDONS_LANG("Allow moving selection frame on restart")
    }, {
        name = "dialog_ctrl",
        check = g.settings.dialog_ctrl,
        text = "{ol}{#FF4500}" .. MINI_ADDONS_LANG("Controls various dialogs")
    }, {
        name = "auto_cast",
        check = g.settings.auto_cast,
        text = "{ol}{#FF4500}" .. MINI_ADDONS_LANG("Set auto casting per character")
    }, {
        name = "coin_use",
        check = g.settings.coin_use,
        text = "{ol}{#FF4500}" .. MINI_ADDONS_LANG("Automatically used when acquiring coin items")
    }, {
        name = "equip_info",
        check = g.settings.equip_info,
        text = "{ol}{#FF4500}" ..
            MINI_ADDONS_LANG("Notification of forgetting to equip ark and emblem upon entry to the hard raid")
    }, {
        name = "automatch_layer",
        check = g.settings.automatch_layer,
        text = "{ol}{#FF4500}" .. MINI_ADDONS_LANG("Lower frame layer level during auto match")
    }, {
        name = "quest_hide",
        check = g.settings.quest_hide,
        text = "{ol}{#FF4500}" .. MINI_ADDONS_LANG("Hide the quest list")
    }, {
        name = "pc_name",
        check = g.settings.pc_name,
        text = "{ol}{#FF4500}" .. MINI_ADDONS_LANG("Change the upper left display to the character's name")
    }, {
        name = "channel_info",
        check = g.settings.channel_info,
        text = "{ol}{#FF4500}" .. MINI_ADDONS_LANG("Displays the channel switching frame")
    }, {
        name = "my_effect",
        check = g.settings.my_effect or 0,
        text = "{ol}{#FF4500}" .. MINI_ADDONS_LANG("Adjust my effects from 1 to 100")
    }, {
        name = "other_effect",
        check = g.settings.other_effect,
        text = "{ol}{#FF4500}" .. MINI_ADDONS_LANG("Adjust other people's effects from 1 to 100, recommended 75")
    }, {
        name = "auto_gacha",
        check = g.settings.auto_gacha,
        text = "{ol}{#FF4500}" .. MINI_ADDONS_LANG("Automate the display of the Goddess Protection gacha frame")
    }, {
        name = "skill_enchant",
        check = g.settings.skill_enchant,
        text = "{ol}{#FF4500}" .. MINI_ADDONS_LANG("Automatically sets items for skill refining")
    }, {
        name = "relic_gauge",
        check = g.settings.relic_gauge,
        text = "{ol}{#FF4500}" .. MINI_ADDONS_LANG("Add a Relic to the character's gauge")
    } --[[, {
        name = "raid_check",
        check = g.settings.raid_check,
        text = "{ol}{#FF4500}" ..
            MINI_ADDONS_LANG("Prevents character change mistakes during the hard raid on the Dreamy& Abyss")
    }]] , {
        name = "party_info",
        check = g.settings.party_info,
        text = "{ol}{#FF4500}" .. MINI_ADDONS_LANG("Toggle party info frame. For mouse mode.Party info rightclick")
    }, {
        name = "coin_count",
        check = g.settings.coin_count,
        text = "{ol}{#FF4500}" .. MINI_ADDONS_LANG("The maximum coin limit for each store is raised to 99999")
    }, {
        name = "bgm",
        check = g.settings.bgm,
        text = "{ol}{#FF4500}" .. MINI_ADDONS_LANG("Always move the BGM player in city")
    }, {
        name = "vakarine",
        check = g.settings.vakarine,
        text = "{ol}{#FF4500}" .. MINI_ADDONS_LANG("Notify others of vakarine equipment in raid")
    }, {
        name = "weekly_boss_reward",
        check = g.settings.weekly_boss_reward,
        text = "{ol}{#FF4500}" .. MINI_ADDONS_LANG("Receive weekly boss reward automatically")
    }, {
        name = "cupole_portion",
        check = g.settings.cupole_portion.use,
        text = "{ol}{#FF4500}" ..
            MINI_ADDONS_LANG("Hide the potion frame of the cupole.Memorizes frame position even when OFF")

    }, {
        name = "goodbye_ragana",
        check = g.settings.goodbye_ragana,
        text = "{ol}{#FF4500}" .. MINI_ADDONS_LANG("Hide Ragana in city")

    }, {
        name = "status_upgrade",
        check = g.settings.status_upgrade,
        text = "{ol}{#FF4500}" .. MINI_ADDONS_LANG("Equip Refining, Automate weapon/armor enhancement")

    }, {
        name = "icor_status_search",
        check = g.settings.icor_status_search,
        text = "{ol}{#FF4500}" .. MINI_ADDONS_LANG("Search the status of icor in the inventory")

    }, {
        name = "velnice", -- separated_buff
        check = g.settings.velnice.use,
        text = "{ol}{#FF4500}" .. MINI_ADDONS_LANG("Remember the previous level of the Velnice dungeon")

    }, {
        name = "separated_buff", -- separated_buff
        check = g.settings.separated_buff,
        text = "{ol}{#FF4500}" .. MINI_ADDONS_LANG("Eliminate around separate buff frame")

    }, {
        name = "group_chat", -- separated_buff
        check = g.settings.group_chat,
        text = "{ol}{#FF4500}" .. MINI_ADDONS_LANG("Group chats can be selected from chat frame")

    }, {
        name = "memberinfo",
        check = g.settings.memberinfo,
        text = "{ol}{#FF4500}" .. MINI_ADDONS_LANG("Add member info to various rightclick menu")

    }, {
        name = "baubas_call",
        check = g.settings.baubas_call.use,
        text = "{ol}{#FF4500}" .. MINI_ADDONS_LANG("Announcing the arrival of Baubas")

    }}

    local x = 10
    for i, setting in ipairs(settings) do

        local checkbox = frame:CreateOrGetControl('checkbox', setting.name .. "_checkbox", 10, x, 25, 25)
        AUTO_CAST(checkbox)
        checkbox:SetCheck(setting.check)
        checkbox:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_ISCHECK")
        checkbox:SetText(setting.text)
        checkbox:SetTextTooltip(MINI_ADDONS_LANG("Check to enable"))
        local textWidth = checkbox:GetWidth()
        if setting.name == "party_buff" then
            local party_buff_btn = frame:CreateOrGetControl("button", "party_buff_btn", textWidth + 15, x - 5, 50, 30)
            AUTO_CAST(party_buff_btn)
            party_buff_btn:SetText("{ol}{#FFFFFF}bufflist")
            party_buff_btn:SetTextTooltip(MINI_ADDONS_LANG("You can choose which buffs to display"))
            party_buff_btn:SetSkinName("test_red_button")
            party_buff_btn:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_BUFFLIST_FRAME_INIT")
        elseif setting.name == "baubas_call" then
            local baubas_call_btn = frame:CreateOrGetControl('button', 'baubas_call_btn', textWidth + 15, x - 5, 50, 30)
            AUTO_CAST(baubas_call_btn)
            if g.settings.baubas_call.guild_notice == 0 or not g.settings.baubas_call.guild_notice then
                baubas_call_btn:SetText("{ol}{#FFFFFF}OFF")
                baubas_call_btn:SetSkinName("test_gray_button");
                g.settings.baubas_call.guild_notice = 0
                MINI_ADDONS_SAVE_SETTINGS()
            else
                baubas_call_btn:SetText("{ol}{#FFFFFF}ON")
                baubas_call_btn:SetSkinName("test_red_button")

            end
            baubas_call_btn:SetTextTooltip(MINI_ADDONS_LANG("Notification switch to guild chat"))
            baubas_call_btn:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_baubas_call_switch")
        elseif setting.name == "auto_gacha" then
            local auto_gacha_btn = frame:CreateOrGetControl('button', 'auto_gacha_btn', textWidth + 15, x - 5, 50, 30)
            AUTO_CAST(auto_gacha_btn)
            if g.settings.auto_gacha_start == 0 or g.settings.auto_gacha_start == nil then
                auto_gacha_btn:SetText("{ol}{#FFFFFF}OFF")
                auto_gacha_btn:SetSkinName("test_gray_button");
                g.settings.auto_gacha_start = 0
                MINI_ADDONS_SAVE_SETTINGS()
            else
                auto_gacha_btn:SetText("{ol}{#FFFFFF}ON")
                auto_gacha_btn:SetSkinName("test_red_button")

            end
            auto_gacha_btn:SetTextTooltip(MINI_ADDONS_LANG(
                "When turned on, the gacha starts automatically.CC required for switching"))
            auto_gacha_btn:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_GP_AUTOSTART_OPERATION")
        elseif setting.name == "other_effect" then
            local other_effect_edit = frame:CreateOrGetControl('edit', 'other_effect_edit', textWidth + 15, x - 5, 60,
                25)
            AUTO_CAST(other_effect_edit)
            other_effect_edit:SetEventScript(ui.ENTERKEY, "MINI_ADDONS_OTHER_EFFECT_EDIT")
            other_effect_edit:SetTextTooltip("{ol}1~100")
            other_effect_edit:SetFontName("white_16_ol")
            other_effect_edit:SetTextAlign("center", "center")
            local other_effect = config.GetOtherEffectTransparency()
            local num = math.floor(other_effect * 0.392156862745 + 0.5)
            other_effect_edit:SetText("{ol}" .. num)
        elseif setting.name == "my_effect" then

            local my_effect_edit = frame:CreateOrGetControl('edit', 'my_effect_edit', textWidth + 15, x - 5, 60, 25)
            AUTO_CAST(my_effect_edit)
            my_effect_edit:SetEventScript(ui.ENTERKEY, "MINI_ADDONS_MY_EFFECT_EDIT")
            my_effect_edit:SetTextTooltip("{ol}1~100")
            my_effect_edit:SetFontName("white_16_ol")
            my_effect_edit:SetTextAlign("center", "center")

            local my_effect = config.GetMyEffectTransparency()
            local num = math.floor(my_effect * 0.392156862745 + 0.5)
            my_effect_edit:SetText("{ol}" .. num)
        elseif setting.name == "weekly_boss_reward" then
            -- g.lang = "en"
            if not g.settings.reward_switch then
                g.settings.reward_switch = 1
                MINI_ADDONS_SAVE_SETTINGS()
            end
            local switch = frame:CreateOrGetControl('button', 'switch', textWidth + 15, x, 80, 25)
            AUTO_CAST(switch)
            if g.settings.reward_switch == 1 then
                switch:SetText(g.lang == "Japanese" and "{ol}先週分" or "{ol}last week")
            else
                switch:SetText(g.lang == "Japanese" and "{ol}今週分" or "{ol}this week")
            end
            switch:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_WEEKLY_BOSS_REWARD_SWITCH")
            local switch_width = switch:GetWidth()
            local switch_text = frame:CreateOrGetControl("richtext", "switch_text", textWidth + 15 + switch_width,
                x + 2, 80, 25)
            AUTO_CAST(switch_text)
            switch_text:SetText(g.lang == "Japanese" and "{ol}ダメージ報酬切替" or "{ol}Damage Reward Switch")
            -- g.lang = "Japanese"
        end
        x = x + 27

    end

    local description = frame:CreateOrGetControl("richtext", "description", 40, x + 5)
    description:SetText("{ol}{#FFA500}" ..
                            MINI_ADDONS_LANG("※Character change is required to enable or disable some functions"))
    -- description:SetTextTooltip("일부 기능의 활성화, 비활성화 전환은 캐릭터 변경이 필요합니다")
    x = x + 30

    if g.lang ~= "Japanese" then
        frame:Resize(720, x)
    else
        frame:Resize(650, x)
    end

    local screenWidth = ui.GetClientInitialWidth() -- 画面の幅
    local screenHeight = ui.GetClientInitialHeight() -- 画面の高さ
    local frameWidth = frame:GetWidth() -- フレームの幅
    local frameHeight = frame:GetHeight() -- フレームの高さ

    frame:SetPos((screenWidth - frameWidth) / 2, (screenHeight - frameHeight) / 2)
    frame:ShowWindow(1)

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
    MINI_ADDONS_SETTING_FRAME_INIT()
end

function MINI_ADDONS_ISCHECK(frame, ctrl, argStr, argNum)
    local ischeck = ctrl:IsChecked()
    local ctrlname = ctrl:GetName()
    -- !追加の度に更新
    local settingNames = {
        other_effect = "other_effect_checkbox",
        my_effect = "my_effect_checkbox",
        channel_info = "channel_info_checkbox",
        pc_name = "pc_name_checkbox",
        quest_hide = "quest_hide_checkbox",
        automatch_layer = "automatch_layer_checkbox",
        equip_info = "equip_info_checkbox",
        under_staff = "under_staff_checkbox",
        raid_record = "raid_record_checkbox",
        party_buff = "party_buff_checkbox",
        chat_system = "chat_system_checkbox",
        channel_display = "channel_display_checkbox",
        mini_btn = "mini_btn_checkbox",
        market_display = "market_display_checkbox",
        restart_move = "restart_move_checkbox",
        pet_init = "pet_init_checkbox",
        dialog_ctrl = "dialog_ctrl_checkbox",
        auto_cast = "auto_cast_checkbox",
        coin_use = "coin_use_checkbox",
        auto_gacha = "auto_gacha_checkbox",
        skill_enchant = "skill_enchant_checkbox",
        party_info = "party_info_checkbox",
        relic_gauge = "relic_gauge_checkbox",
        raid_check = "raid_check_checkbox",
        coin_count = "coin_count_checkbox",
        bgm = "bgm_checkbox",
        vakarine = "vakarine_checkbox",
        weekly_boss_reward = "weekly_boss_reward_checkbox",
        cupole_portion = "cupole_portion_checkbox",
        goodbye_ragana = "goodbye_ragana_checkbox",
        status_upgrade = "status_upgrade_checkbox",
        icor_status_search = "icor_status_search_checkbox",
        velnice = "velnice_checkbox",
        separated_buff = "separated_buff_checkbox",
        group_chat = "group_chat_checkbox",
        memberinfo = "memberinfo_checkbox",
        baubas_call = "baubas_call_checkbox"
    }

    for settingName, checkboxName in pairs(settingNames) do
        if ctrlname == checkboxName then
            if checkboxName == "cupole_portion_checkbox" or checkboxName == "velnice_checkbox" or checkboxName ==
                "baubas_call_checkbox" then

                g.settings[settingName].use = ischeck
            else
                g.settings[settingName] = ischeck
            end
            if checkboxName == "bgm_checkbox" then
                if ischeck == 0 then
                    local max_frame = ui.GetFrame("bgmplayer")
                    local play_btn = GET_CHILD_RECURSIVELY(max_frame, "playStart_btn")
                    BGMPLAYER_PLAY(max_frame, play_btn)
                end
            elseif checkboxName == "quest_hide_checkbox" then
                if ischeck == 0 then
                    MINI_ADDONS_QUESTINFO_SHOW()
                else
                    MINI_ADDONS_QUESTINFO_HIDE_RESERVE()
                end
            end
            break
        end
    end

    MINI_ADDONS_SAVE_SETTINGS()
    MINI_ADDONS_ON_INIT(g.addon, g.frame)
end

function MINI_ADDONS_FRAME_MOVE_RESERVE(frame, ctrl, str, num)

    frame:SetSkinName("chat_window")
    frame:Resize(40, 30)
    frame:EnableHittestFrame(1);
    frame:EnableMove(1)
    frame:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_FRAME_MOVE_SAVE")
end

function MINI_ADDONS_FRAME_MOVE_SAVE(frame, ctrl, str, num)
    local x = frame:GetX();
    local y = frame:GetY();
    g.settings["screen"] = {
        x = x,
        y = y
    }
    MINI_ADDONS_SAVE_SETTINGS()

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
    end

    local map_frame = ui.GetFrame("map")
    local width = map_frame:GetWidth()
    if g.settings["screen"].x > 1920 and width < 1920 then
        g.settings["screen"] = {
            x = 1580,
            y = 305
        }
    end
    MINI_ADDONS_SAVE_SETTINGS()

    newframe:SetPos(g.settings["screen"].x, g.settings["screen"].y)
    newframe:SetTitleBarSkin("None")

    local btn = newframe:CreateOrGetControl('button', 'mini', 0, 0, 30, 30)
    AUTO_CAST(btn)
    btn:SetSkinName("None")
    btn:SetText("{img sysmenu_mac 30 30}")

    btn:SetEventScript(ui.LBUTTONDOWN, "MINI_ADDONS_SETTING_FRAME_INIT")
    local text = g.lang == "Japanese" and
                     "{ol}左クリック: Mini Addons 設定{nl}右クリック: MUTE{nl}フレームの端を掴んで動かせます" or
                     "{ol}Left click: Mini Addons settings{nl}Right click: MUTE{nl}Grab the edge of the frame and move it"
    btn:SetTextTooltip(text)
    btn:SetGravity(ui.LEFT, ui.TOP)
    btn:SetEventScript(ui.RBUTTONUP, "MINI_ADDONS_SOUND_TOGGLE")
    btn:SetEventScript(ui.MOUSEON, "MINI_ADDONS_FRAME_MOVE_RESERVE")

    newframe:ShowWindow(1)
    g.addon:RegisterMsg("FPS_UPDATE", "MINI_ADDONS_FPS_UPDATE")
end

function MINI_ADDONS_FRAME_CLOSE(frame)
    local frame = ui.GetFrame("mini_addons")
    frame:ShowWindow(0)
end

function MINI_ADDONS_FPS_UPDATE()
    local newframe = ui.GetFrame("mini_addons_new")
    if newframe:IsVisible() == 1 then

        local frame = ui.GetFrame("mini_addons_channel")
        if frame ~= nil then
            AUTO_CAST(frame)
            if frame:IsVisible() == 0 then
                local addonframe = ui.GetFrame("mini_addons")
                addonframe:StopUpdateScript("MINI_ADDONS_POPUP_CHANNEL_LIST")
                MINI_ADDONS_GAME_START_CHANNEL_LIST()
            end
        end

        return
    else
        MINI_ADDONS_NEW_FRAME_INIT()
    end
end

function MINI_ADDONS_MINIMIZED_CLOSE()

    local tp_button = ui.GetFrame("openingameshopbtn") -- TP受け取りボタン
    if tp_button:IsVisible() then
        tp_button:ShowWindow(0)
    end

    local pilgrim_mode = ui.GetFrame("minimized_pilgrim_mode") -- ピルグリムボタン
    if pilgrim_mode:IsVisible() then
        pilgrim_mode:ShowWindow(0)
    end

    local total_shop_button = ui.GetFrame("minimized_total_shop_button") -- マーケットとかのボタン
    if total_shop_button:IsVisible() then
        total_shop_button:ShowWindow(0)
    end

    local total_party_button = ui.GetFrame("minimized_total_party_button") -- パーティー募集ボタン
    if total_party_button:IsVisible() then
        total_party_button:ShowWindow(0)
    end

    local tpshop_button = ui.GetFrame("minimized_tp_button") -- TPショップボタン
    if tpshop_button:IsVisible() then
        tpshop_button:ShowWindow(0)
    end

    local total_bord = ui.GetFrame("minimized_total_board_button") -- 掲示板
    if total_bord:IsVisible() then
        total_bord:ShowWindow(0)
    end

    local guidequest = ui.GetFrame("minimized_guidequest_button") -- なんか冒険者ガイドのやつ
    if guidequest:IsVisible() then
        guidequest:ShowWindow(0)
    end

    local menu = ui.GetFrame("minimized_fullscreen_navigation_menu_button") -- menu
    if menu:IsVisible() then
        menu:ShowWindow(0)
    end
end

function MINI_ADDONS_BGM_PLAY_LIST()
    local frame = ui.GetFrame("bgmplayer")
    if frame:GetUserValue("CTRLSET_NAME_SELECTED") == nil or frame:IsVisible() == 1 or
        frame:GetUserValue("CTRLSET_NAME_SELECTED") == "None" then
        return
    end
    g.settings.selectCtrlSetName = frame:GetUserValue("CTRLSET_NAME_SELECTED");
    MINI_ADDONS_SAVE_SETTINGS()
    return
end

function MINIADDONS_BGMPLAYER_PLAY(frame, btn)

    local mode = tonumber(frame:GetUserValue("MODE_ALL_LIST"));
    local option = tonumber(frame:GetUserValue("MODE_FAVO_LIST"));
    local delayTime = 0
    local playRandom = tonumber(frame:GetUserConfig("PLAY_RANDOM"));

    local bgmMusicTitle_text = GET_CHILD_RECURSIVELY(frame, "bgm_music_title");
    if bgmMusicTitle_text ~= nil then
        local title = bgmMusicTitle_text:GetTextByKey("value");
        StopBgm(title, delayTime);
        BGMPLAYER_REDUCTION_SET_PLAYBTN(false);
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

    local mode = tonumber(topFrame:GetUserValue("MODE_ALL_LIST"));

    local option = tonumber(topFrame:GetUserValue("MODE_FAVO_LIST"));
    local delayTime = 0

    local playRandom = tonumber(topFrame:GetUserConfig("PLAY_RANDOM"));

    local bgmMusicTitle_text = GET_CHILD_RECURSIVELY(topFrame, "bgm_music_title");

    if bgmMusicTitle_text ~= nil then
        local title = bgmMusicTitle_text:GetTextByKey("value");

        if title ~= nil then
            local haltImageName = topFrame:GetUserConfig("PLAY_HALT_BTN_IMAGE_NAME");
            local startImageName = topFrame:GetUserConfig("PLAY_START_BTN_IMAGE_NAME");

            local selectCtrlSetName = g.settings.selectCtrlSetName

            local selectCtrlSet = GET_CHILD_RECURSIVELY(topFrame, selectCtrlSetName);
            local titleText = nil;
            local parent = nil;
            if selectCtrlSet ~= nil then
                parent = selectCtrlSet:GetParent();
                if parent ~= nil then
                    BGMPLAYER_SET_MUSIC_TITLE(topFrame, parent, selectCtrlSet);
                end
                titleText = GET_CHILD_RECURSIVELY(selectCtrlSet, "musictitle_text");
            end

            if titleText == nil then
                return;
            end
            local musicTitle = titleText:GetTextByKey("value");
            if musicTitle ~= nil then
                musicTitle = StringSplit(musicTitle, '. ');

                if string.find(musicTitle[1], "{#ffc03a}") ~= nil then
                    local find_start, find_end = string.find(musicTitle[1], "{#ffc03a}");
                    if find_start ~= nil and find_end ~= nil then
                        musicTitle[1] = string.sub(musicTitle[1], find_end + 1, string.len(musicTitle[1]));
                    end
                end

                local index = tonumber(musicTitle[1]);
                local bgmType = GET_BGMPLAYER_MODE(topFrame, mode, option);

                if bgmType == 1 then
                    SetBgmCurIndex(index, playRandom);
                elseif bgmType == 0 then
                    SetBgmCurFVIndex(index, playRandom);
                end
                -- end

                title = bgmMusicTitle_text:GetTextByKey("value");
                PlayBgm(title, selectCtrlSetName);
                BGMPLAYER_REDUCTION_SET_PLAYBTN(true);
                BGMPLAYER_REDUCTION_SET_TITLE(title);

                local totalTime = GetPlayBgmTotalTime();
                totalTime = totalTime / 1000;
                local startTime = 0;
                if GetBgmPauseTime() > 0 then
                    startTime = GetBgmPauseTime() / 1000;
                    SetPauseTime(0);
                end
                BGMPLAYER_PLAYTIME_GAUGE(startTime, totalTime);
            end

            if btn:GetImageName() == startImageName then
                btn:SetImage(haltImageName);
                btn:SetTooltipArg(ScpArgMsg('BgmPlayer_HaltBtnToolTip'));
            else
                btn:SetImage(startImageName);
                btn:SetTooltipArg(ScpArgMsg('BgmPlayer_StartBtnToolTip'));
            end
            BGMPLAYER_CLOSE_UI()

        end
    end
end

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
    fbtext:SetAnimation("MouseOnAnim", "btn_mouseover");
    fbtext:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_GP_FULL_BET_START")
end

function MINI_ADDONS_GP_DO_OPEN()

    if g.first == 0 or g.first == nil then
        ReserveScript("GODPROTECTION_DO_OPEN()", 2.0);
        ReserveScript("MINI_ADDONS_GP_AUTOSTART()", 4.0)
    end
    return
end

function MINI_ADDONS_GP_FULL_BET_START(frame, ctrl, argStr, argNum)

    local frame = ui.GetFrame("godprotection")
    local multiple_count = 20
    local multiple_count_edit = GET_CHILD_RECURSIVELY(frame, 'multiple_count_edit')
    multiple_count_edit:SetText(multiple_count);

    local edit = GET_CHILD_RECURSIVELY(frame, "auto_edit");
    local count = 99999999
    local next_count = count - 1;
    edit:SetText(next_count);

    local parent = GET_CHILD_RECURSIVELY(frame, "auto_gb");
    local auto_btn = GET_CHILD_RECURSIVELY(frame, "auto_btn")
    local auto_text = GET_CHILD_RECURSIVELY(frame, "auto_text");
    auto_text:ShowWindow(0);
    GODPROTECTION_AUTO_START_BTN_CLICK(parent, auto_btn)

end

function MINI_ADDONS_GP_AUTOSTART()
    g.first = 1
    local frame = ui.GetFrame("godprotection")
    if g.settings.auto_gacha_start == 1 then
        local multiple_count = 20
        local multiple_count_edit = GET_CHILD_RECURSIVELY(frame, 'multiple_count_edit')
        multiple_count_edit:SetText(multiple_count);

        local edit = GET_CHILD_RECURSIVELY(frame, "auto_edit");
        local count = 99999999
        local next_count = count - 1;
        edit:SetText(next_count);

        local parent = GET_CHILD_RECURSIVELY(frame, "auto_gb");
        local auto_btn = GET_CHILD_RECURSIVELY(frame, "auto_btn")
        local auto_text = GET_CHILD_RECURSIVELY(frame, "auto_text");
        auto_text:ShowWindow(0);

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
        ctrl:SetSkinName("test_gray_button");
        g.settings.auto_gacha_start = 0
        ui.SysMsg("Turned off the automatic Goddess Protection gacha function.")
        MINI_ADDONS_SAVE_SETTINGS()
        ReserveScript(string.format("APPS_TRY_LEAVE('%s')", "Barrack"), 1.0)

    end
end

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

    local invItemList = session.GetInvItemList();
    local bottom_bg = GET_CHILD_RECURSIVELY(frame, "bottom_Bg")
    local cnt = bottom_bg:GetChildCount();
    local set_ready_count = 0;
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
            plus:ShowWindow(0);
            set_ready_count = set_ready_count + 1;
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
    local guidList = invItemList:GetGuidList();
    local cnt = guidList:Count();

    for i = 0, cnt - 1 do
        local guid = guidList:Get(i);
        local invItem = invItemList:GetItemByGuid(guid)
        local itemobj = GetIES(invItem:GetObject())

        for _, coinID in ipairs(coin_item) do
            if tostring(itemobj.ClassID) == tostring(coinID) then

                ReserveScript(string.format("item.UseByGUID(%d)", invItem:GetIESID()), 1.5)

                break -- 使ったらループを抜ける
            end
        end
    end
end

function MINI_ADDONS_SET_PARTYINFO_ITEM(frame, msg)

    local frame = ui.GetFrame('partyinfo')

    local list = session.party.GetPartyMemberList(PARTY_NORMAL);
    local count = list:Count() - 1;
    frame:SetEventScript(ui.RBUTTONUP, "MINI_ADDONS_PARTYINFO_RESIZE")
    if g.partyinfo == 1 then
        frame:Resize(80, count * 100 + 60)
        frame:SetLayerLevel(0)

    elseif g.partyinfo == 0 then
        frame:Resize(560, count * 100 + 60);
        frame:SetLayerLevel(50)

    end

    return

end

function MINI_ADDONS_PARTYINFO_RESIZE(frame, ctrl, argStr, argNum)

    local list = session.party.GetPartyMemberList(PARTY_NORMAL);
    local count = list:Count() - 1;

    if frame:GetWidth() == 80 then
        frame:Resize(560, count * 100 + 60);
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
                            "Quest"};
local _invenSortTypeOption = {};

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
        return;
    end

    local liftIcon = ui.GetLiftIcon();
    if nil == isIgnorelifticon then
        isIgnorelifticon = "NO";
    end

    if isIgnorelifticon ~= "NO" and liftIcon ~= nil then
        return;
    end

    local mySession = session.GetMySession();
    local cid = mySession:GetCID();
    local sortType = _invenSortTypeOption[cid];
    session.BuildInvItemSortedList();
    local sortedList = session.GetInvItemSortedList();
    local invItemCount = sortedList:size();

    if sortType == nil then
        sortType = 0;
    end

    local blinkcolor = frame:GetUserConfig("TREE_SEARCH_BLINK_COLOR");
    local group = GET_CHILD_RECURSIVELY(frame, 'inventoryGbox', 'ui::CGroupBox')

    for typeNo = 1, #g_invenTypeStrList do
        if invenTypeStr == nil or invenTypeStr == g_invenTypeStrList[typeNo] or typeNo == 1 then
            local tree_box = GET_CHILD_RECURSIVELY(group, 'treeGbox_' .. g_invenTypeStrList[typeNo], 'ui::CGroupBox')
            local tree = GET_CHILD_RECURSIVELY(tree_box, 'inventree_' .. g_invenTypeStrList[typeNo], 'ui::CTreeControl')

            local groupfontname = frame:GetUserConfig("TREE_GROUP_FONT");
            local tabwidth = frame:GetUserConfig("TREE_TAB_WIDTH");

            tree:Clear();
            tree:EnableDrawFrame(false)
            tree:SetFitToChild(true, 60)
            tree:SetFontName(groupfontname);
            tree:SetTabWidth(tabwidth);

            local slotSetNameListCnt = ui.inventory.GetInvenSlotSetNameCount();
            for i = 1, slotSetNameListCnt do
                local slotSetName = ui.inventory.GetInvenSlotSetNameByIndex(i - 1);
                ui.inventory.RemoveInvenSlotSetName(slotSetName);
            end

            local groupNameListCnt = ui.inventory.GetInvenGroupNameCount();
            for i = 1, groupNameListCnt do
                local groupName = ui.inventory.GetInvenGroupNameByIndex(i - 1);
                ui.inventory.RemoveInvenGroupName(groupName);
            end

            local customFunc = nil;
            local scriptName = frame:GetUserValue("CUSTOM_ICON_SCP");
            local scriptArg = nil;
            if scriptName ~= nil then
                customFunc = _G[scriptName];
                local getArgFunc = _G[frame:GetUserValue("CUSTOM_ICON_ARG_SCP")];
                if getArgFunc ~= nil then
                    scriptArg = getArgFunc();
                end
            end
        end
    end

    local baseidclslist, baseidcnt = GetClassList("inven_baseid");
    local searchGbox = group:GetChild('searchGbox');
    local searchSkin = GET_CHILD_RECURSIVELY(searchGbox, "searchSkin", 'ui::CGroupBox');
    local edit = GET_CHILD_RECURSIVELY(searchSkin, "ItemSearch", "ui::CEditControl");
    local cap = edit:GetText();
    if cap ~= "" then
        local slotSetNameListCnt = ui.inventory.GetInvenSlotSetNameCount();
        for i = 1, slotSetNameListCnt do
            local getSlotSetName = ui.inventory.GetInvenSlotSetNameByIndex(i - 1);
            local slotset = GET_CHILD_RECURSIVELY(tree, getSlotSetName, 'ui::CSlotSet');
            slotset:RemoveAllChild();
            slotset:SetUserValue("SLOT_ITEM_COUNT", 0);
        end
    end

    local invItemList = {}
    local index_count = 1
    for i = 0, invItemCount - 1 do
        local invItem = sortedList:at(i);
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
            local invItem = invItemList[j];
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
                            local makeSlot = true;
                            if cap ~= "" then
                                -- 인벤토리 안에 있는 아이템을 찾기 위한 로직
                                local itemname = string.lower(dictionary.ReplaceDicIDInCompStr(itemCls.Name));
                                -- 접두어도 포함시켜 검색해야되기 때문에, 접두를 찾아서 있으면 붙여주는 작업
                                local prefixClassName = TryGetProp(itemCls, "LegendPrefix")
                                if prefixClassName ~= nil and prefixClassName ~= "None" then
                                    local prefixCls = GetClass('LegendSetItem', prefixClassName)
                                    local prefixName = string.lower(dictionary.ReplaceDicIDInCompStr(prefixCls.Name));
                                    itemname = prefixName .. " " .. itemname;
                                end

                                local tempcap = string.lower(cap);
                                local a = string.find(itemname, tempcap);

                                if a == nil then
                                    makeSlot = false;

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
                                                        dictionary.ReplaceDicIDInCompStr(job_cls.Name));
                                                    a = string.find(itemname, tempcap);
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
                                            a = string.find(itemname, tempcap);
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
                                        INSERT_ITEM_TO_TREE(frame, tree, invItem, itemCls, baseidcls);
                                    end
                                    -- Request #95788 / 퀘스트 항목은 모두 보기 탭에서 보이지 않도록 함
                                    if typeStr ~= "Quest" then
                                        local tree_box_all =
                                            GET_CHILD_RECURSIVELY(group, 'treeGbox_All', 'ui::CGroupBox')
                                        local tree_all = GET_CHILD_RECURSIVELY(tree_box_all, 'inventree_All',
                                            'ui::CTreeControl')
                                        INSERT_ITEM_TO_TREE(frame, tree_all, invItem, itemCls, baseidcls);
                                    end
                                end
                            else
                                --[[if customFunc ~= nil then
                                    local slot = slotSet:GetSlotByIndex(i);
                                    if slot ~= nil then
                                        customFunc(slot, scriptArg, invItem, nil);
                                    end
                                end]]

                                -- 인벤토리 옵션 적용 중이면 빈 tree 만들어 "필터링 옵션 적용 중"이라는 문구 표시해주기
                                local isOptionApplied = CHECK_INVENTORY_OPTION_APPLIED(baseidcls);
                                if isOptionApplied == 1 and cap == "" then -- 검색 중에는 조건에 맞는 아이템 없으면 tree 안 만듬
                                    if invenTypeStr == nil or invenTypeStr == typeStr then
                                        local tree_box = GET_CHILD_RECURSIVELY(group, 'treeGbox_' .. typeStr,
                                            'ui::CGroupBox');
                                        local tree = GET_CHILD_RECURSIVELY(tree_box, 'inventree_' .. typeStr,
                                            'ui::CTreeControl');
                                        EMPTY_TREE_INVENTORY_OPTION_TEXT(baseidcls, tree); -- 해당 아이템이 속한 탭
                                    end

                                    -- Request #95788 / 퀘스트 항목은 모두 보기 탭에서 보이지 않도록 함
                                    if typeStr ~= "Quest" then
                                        local tree_box_all =
                                            GET_CHILD_RECURSIVELY(group, 'treeGbox_All', 'ui::CGroupBox');
                                        local tree_all = GET_CHILD_RECURSIVELY(tree_box_all, 'inventree_All',
                                            'ui::CTreeControl');
                                        EMPTY_TREE_INVENTORY_OPTION_TEXT(baseidcls, tree_all); -- ALL 탭 
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
        local tree_box = GET_CHILD_RECURSIVELY(group, 'treeGbox_' .. g_invenTypeStrList[typeNo], 'ui::CGroupBox');
        local tree = GET_CHILD_RECURSIVELY(tree_box, 'inventree_' .. g_invenTypeStrList[typeNo], 'ui::CTreeControl');

        -- 아이템 없는 빈 슬롯은 숨겨라
        local slotSetNameListCnt = ui.inventory.GetInvenSlotSetNameCount();
        for i = 1, slotSetNameListCnt do
            local getSlotSetName = ui.inventory.GetInvenSlotSetNameByIndex(i - 1);
            local slotset = GET_CHILD_RECURSIVELY(tree, getSlotSetName, 'ui::CSlotSet');
            if slotset ~= nil then
                ui.InventoryHideEmptySlotBySlotSet(slotset);
            end
        end

        ADD_GROUP_BOTTOM_MARGIN(frame, tree)
        tree:OpenNodeAll();
        tree:SetEventScript(ui.LBUTTONDOWN, "INVENTORY_TREE_OPENOPTION_CHANGE");
        INVENTORY_CATEGORY_OPENCHECK(frame, tree);

        -- 검색결과 스크롤 세팅은 여기서 하자. 트리 업데이트 후에 위치가 고정된 다음에.
        for i = 1, slotSetNameListCnt do
            local getSlotSetName = ui.inventory.GetInvenSlotSetNameByIndex(i - 1);
            -- slotset = GET_CHILD_RECURSIVELY(tree, getSlotSetName, 'ui::CSlotSet');

            local slotsetnode = tree:FindByValue(getSlotSetName);
            if setpos == 'setpos' then
                local savedPos = frame:GetUserValue("INVENTORY_CUR_SCROLL_POS");
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

    pcRelicGauge:SetGravity(ui.CENTER_HORZ, ui.TOP);
    pcRelicGauge:EnableHitTest(0);
    pcRelicGauge:SetSkinName("pcinfo_gauge_rp_relic")
    pcRelicGauge:StopTimeProcess()

    local pc = GetMyPCObject()
    local cur_rp, max_rp = shared_item_relic.get_rp(pc)

    pcRelic_text:SetGravity(ui.CENTER_HORZ, ui.CENTER_VERT);
    pcRelic_text:SetText("{ol}{s12}" .. cur_rp)
    pcRelicGauge:SetPoint(cur_rp / 10, max_rp / 10)

end

function MINI_ADDONS_GAME_START_CHANNEL_LIST()
    MINI_ADDONS_POPUP_CHANNEL_LIST()
    local frame = ui.GetFrame("mini_addons")
    frame:RunUpdateScript("MINI_ADDONS_POPUP_CHANNEL_LIST", 15)
    return
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

    local frame = ui.CreateNewFrame("notice_on_pc", "mini_addons_channel", 10, 10, 10, 10)
    AUTO_CAST(frame)
    frame:RemoveAllChild();
    frame:SetSkinName('None')
    frame:SetTitleBarSkin("None")
    frame:EnableHittestFrame(1);
    frame:EnableMove(1)

    g.settings.frame_X = g.settings.frame_X or 1500
    g.settings.frame_Y = g.settings.frame_Y or 395
    g.settings.ch_frame_size = g.settings.ch_frame_size or 40

    MINI_ADDONS_SAVE_SETTINGS()

    local size = g.settings.ch_frame_size

    frame:SetPos(g.settings.frame_X, g.settings.frame_Y)
    frame:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_channelframe_move")
    frame:SetEventScript(ui.RBUTTONUP, "MINI_ADDONS_CH_FRAME_RESIZE")

    local title = frame:CreateOrGetControl("richtext", "title", 5, 0)
    title:SetText("{ol}{s12}channel info")

    local zoneInsts = session.serverState.GetMap();

    if zoneInsts ~= nil then

        if zoneInsts:NeedToCheckUpdate() == true then
            app.RequestChannelTraffics();
        end
        local cnt = zoneInsts:GetZoneInstCount();
        for i = 0, cnt - 1 do
            local zoneInst = zoneInsts:GetZoneInstByIndex(i);
            -- local str, gaugeString = GET_CHANNEL_STRING(zoneInst, true);

            local String = zoneInst.pcCount
            local btn = frame:CreateOrGetControl("button", "slot" .. i, i * size + 5, 15, size, size)
            AUTO_CAST(btn)
            btn:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_CH_CHANGE")

            local channelnum = session.loginInfo.GetChannel();
            if i == channelnum then
                btn:SetSkinName("test_pvp_btn");
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
    else
        frame:ShowWindow(0)
        return 0
    end
    return 1
end

function MINI_ADDONS_CH_CHANGE(frame, ctrl, argStr, argNum)
    local channelID = tonumber(argStr) -- 0が1chらしい
    RUN_GAMEEXIT_TIMER("Channel", channelID);
end

function MINI_ADDONS_CONFIG_ENABLE_AUTO_CASTING(frame, msg)

    local parent, ctrl = acutil.getEventArgs(msg);
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

function MINI_ADDONS_PCNAME_REPLACE(frame, msg)
    local frame = ui.GetFrame("headsupdisplay")
    local LoginName = session.GetMySession():GetPCApc():GetName()
    local name_text = GET_CHILD_RECURSIVELY(frame, "name_text")
    if name_text:GetText() ~= "{@st41}" .. tostring(LoginName) then
        name_text:SetText("{@st41}" .. tostring(LoginName))
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
        DialogSelect_index = 2;
        local btn2 = GET_CHILD_RECURSIVELY(frame, 'item2Btn')
        local x, y = GET_SCREEN_XY(btn2)
        mouse.SetPos(x + 190, y);
        return
    end
    -- 住居クポル
    if argStr == "NPC_PERSONAL_HOUSING_MANAGER_DLG_2" then

        session.SetSelectDlgList()
        ui.OpenFrame("dialogselect")
        control.DialogItemSelect(1);
        -- test_norisan_DIALOGSELECT_STRING_ENTER_2(frame, msg, argStr, argNum)
        -- control.DialogOk()
        -- DialogSelect_index = 1
    elseif string.find(argStr, "PERSONAL_HOUSING_POINT_CHECK_MSG_1") ~= nil then

        session.SetSelectDlgList()
        ui.OpenFrame("dialogselect")
        control.DialogItemSelect(1);

    elseif string.find(argStr, "PH_POINT_SHOP_DLG_SEL_1") ~= nil then
        session.SetSelectDlgList()
        ui.CloseFrame("dialog")
        ui.OpenFrame("dialogselect")
        DialogSelect_index = 3
        local btn = GET_CHILD_RECURSIVELY(frame, 'item3Btn')
        local x, y = GET_SCREEN_XY(btn)
        mouse.SetPos(x + 190, y);
        return
    end

    local pc = GetMyPCObject();
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
        mouse.SetPos(x + 190, y);
        return

    end
    if (argStr == "Legend_Raid_Giltine_ENTER_MSG" and curMap == "raid_dcapital_108") then

        session.SetSelectDlgList()
        ui.CloseFrame("dialog")
        ui.OpenFrame("dialogselect")
        DialogSelect_index = 2
        local btn = GET_CHILD_RECURSIVELY(frame, 'item2Btn')
        local x, y = GET_SCREEN_XY(btn)
        mouse.SetPos(x + 190, y);
        return

    end
end

function MINI_ADDONS_FRAME_MOVE()

    local rcframe = ui.GetFrame("restart_contents")
    rcframe:EnableHittestFrame(1)
    rcframe:EnableMove(1)
    -- 多分コロニー時はこっちちゃうかな
    local rframe = ui.GetFrame("restart")
    rframe:EnableHittestFrame(1)
    rframe:EnableMove(1)
    rframe:SetSkinName("None")
    local buttonSkin = "chat_window"
    local buttonNames = {"btn_restart_1", "btn_restart_2", "btn_restart_3", "btn_restart_4", "btn_restart_5"}

    for i, buttonName in ipairs(buttonNames) do
        local button = GET_CHILD_RECURSIVELY(rframe, buttonName)
        if button ~= nil then
            button:SetSkinName(buttonSkin)
        end
    end
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
    frame:StopUpdateScript("MINI_ADDONS_QUESTINFO_HIDE");

end

function MINI_ADDONS_QUESTINFO_HIDE_RESERVE()
    local frame = ui.GetFrame("questinfoset_2")
    frame:Resize(0, 0)
    frame:RunUpdateScript("MINI_ADDONS_QUESTINFO_HIDE", 0.1);
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
        return 1
    end
    return 1
end

function MINI_ADDONS_INDUNENTER_AUTOMATCH_TYPE()
    local frame = ui.GetFrame("indunenter");
    frame:SetLayerLevel(97)
end

function MINI_ADDONS_SHOW_INDUNENTER_DIALOG(indunType)
    local frame = ui.GetFrame('indunenter');
    local indunType = frame:GetUserValue('INDUN_TYPE', indunType)

    local indunType_table = {665, 670, 675, 678, 681, 628, 687, 690, 697, 709, 712}

    for i = 1, #indunType_table do
        if tostring(indunType_table[i]) == tostring(indunType) then
            local equipItemList = session.GetEquipItemList();
            local cnt = equipItemList:Count();
            local count = 0

            for i = 0, cnt - 1 do
                local equipItem = equipItemList:GetEquipItemByIndex(i);
                local spotName = item.GetEquipSpotName(equipItem.equipSpot);
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

    EFFECT_TRANSPARENCY_ON()
    local my_effect = config.GetMyEffectTransparency()
    if g.settings.my_effect_value ~= nil then
        config.SetMyEffectTransparency(g.settings.my_effect_value)
    else
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

    EFFECT_TRANSPARENCY_ON()
    local other_effect = config.GetOtherEffectTransparency()
    if g.settings.other_effect_value ~= nil then
        config.SetOtherEffectTransparency(g.settings.other_effect_value)
    else
        config.SetOtherEffectTransparency(other_effect)
    end
end

function MINI_ADDONS_MARKET_SELL_UPDATE_REG_SLOT_ITEM(frame, msg)
    local frame = ui.GetFrame('market_sell');
    local edit_count = GET_CHILD_RECURSIVELY(frame, "edit_count");
    AUTO_CAST(edit_count)

    local slot = GET_CHILD_RECURSIVELY(frame, "slot_item")
    local icon = slot:GetIcon()
    local count = 0
    if icon ~= nil then
        local info = icon:GetInfo();
        local iesid = info:GetIESID();
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

        local ItemBtn = GET_CHILD_RECURSIVELY(frame, "btn_restart_" .. 1);
        local itemWidth = ItemBtn:GetWidth();

        local x, y = GET_SCREEN_XY(ItemBtn, itemWidth / 2.5);
        mouse.SetPos(x, y);
        DialogSelect_index = 1;
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

function MINI_ADDONS_NOTICE_ON_MSG(frame, msg, argStr, argNum)
    if g.settings.chat_system == 1 then
        if string.find(argStr, "StartBlackMarketBetween") then
            return
        end
    end
    base["NOTICE_ON_MSG"](frame, msg, argStr, argNum)
end

function MINI_ADDONS_CHAT_SYSTEM(msg, color)

    if g.settings.chat_system == 1 then
        if msg == "&lt;완벽함&gt; 효과가 사라졌습니다." or msg ==
            "&lt;완벽함&gt; 효과가 발동되었습니다." or msg == "@dicID_^*$ETC_20220830_069434$*^" or msg ==
            "@dicID_^*$ETC_20220830_069435$*^" or msg == "[__m2util] is loaded" or msg == "[adjustlayer] is loaded" or
            msg == "[extendcharinfo] is loaded" or msg == "[ICC]Attempt to CC." or
            string.find(msg, "StartBlackMarketBetween") then
            return
        end
    end
    session.ui.GetChatMsg():AddSystemMsg(msg, true, 'System', color)
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

function MINI_ADDONS_RAID_RECORD_INIT(frame, msg)

    local frame = ui.GetFrame("raid_record")
    frame:SetOffset(g.settings.reword_x, g.settings.reword_y)
    frame:SetSkinName("shadow_box")
    frame:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_UPDATESETTINGS")
    frame:SetLayerLevel(5)
    frame:SetTitleBarSkin("None")
    frame:ShowTitleBar(0)
    frame:Resize(550, 260)

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

function MINI_ADDONS_INDUNENTER_REQ_UNDERSTAFF_ENTER_ALLOW(parent, ctrl)
    local topFrame = parent:GetTopParentFrame();
    local useCount = tonumber(topFrame:GetUserValue("multipleCount"));
    if useCount > 0 then
        local multipleItemList = GET_INDUN_MULTIPLE_ITEM_LIST();
        for i = 1, #multipleItemList do
            local itemName = multipleItemList[i];
            local invItem = session.GetInvItemByName(itemName);
            if invItem ~= nil and invItem.isLockState then
                ui.SysMsg(ClMsg("MaterialItemIsLock"));
                return;
            end
        end
    end

    local withMatchMode = topFrame:GetUserValue('WITHMATCH_MODE');
    if topFrame:GetUserValue('AUTOMATCH_MODE') ~= 'YES' and withMatchMode == 'NO' then
        ui.SysMsg(ScpArgMsg('EnableWhenAutoMatching'));
        return;
    end

    local indunType = topFrame:GetUserIValue('INDUN_TYPE');
    local indunCls = GetClassByType('Indun', indunType);
    local UnderstaffEnterAllowMinMember = TryGetProp(indunCls, 'UnderstaffEnterAllowMinMember');
    if UnderstaffEnterAllowMinMember == nil then
        return;
    end

    -- ??티??과 ??동매칭??경우 처리
    local yesScpStr = '_INDUNENTER_REQ_UNDERSTAFF_ENTER_ALLOW()';
    local clientMsg = ScpArgMsg('ReallyAllowUnderstaffMatchingWith{MIN_MEMBER}?', 'MIN_MEMBER',
        UnderstaffEnterAllowMinMember);
    if INDUNENTER_CHECK_UNDERSTAFF_MODE_WITH_PARTY(topFrame) == true then
        clientMsg = ClMsg('CancelUnderstaffMatching');
    end

    if withMatchMode == 'YES' then
        yesScpStr = 'ReqUnderstaffEnterAllowModeWithParty(' .. indunType .. ')';
    end

    if g.settings.under_staff == 1 then
        if withMatchMode == 'NO' then
            _INDUNENTER_REQ_UNDERSTAFF_ENTER_ALLOW()
            return
        end
    end
    ui.MsgBox(clientMsg, yesScpStr, "None");
end

function MINI_ADDONS_EARTHTOWERSHOP_CHANGECOUNT_NUM_CHANGE(ctrlset, change)
    if g.settings.coin_count ~= 1 then
        base["EARTHTOWERSHOP_CHANGECOUNT_NUM_CHANGE"](ctrlset, change)
        return
    end
    local recipecls = GetClass('ItemTradeShop', ctrlset:GetName());

    local edit_itemcount = GET_CHILD_RECURSIVELY(ctrlset, "itemcount");
    local countText = tonumber(edit_itemcount:GetText());
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
        local sObj = GetSessionObject(GetMyPCObject(), "ssn_shop");
        local sCount = TryGetProp(sObj, recipecls.NeedProperty);
        if sCount < countText then
            countText = sCount
        end
    end
    if recipecls.AccountNeedProperty ~= 'None' then
        local aObj = GetMyAccountObj()
        local sCount = TryGetProp(aObj, recipecls.AccountNeedProperty);

        local frame = ui.GetFrame("earthtowershop");
        local shopType = frame:GetUserValue("SHOP_TYPE");
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
    edit_itemcount:SetText(countText);
    return countText;
end
