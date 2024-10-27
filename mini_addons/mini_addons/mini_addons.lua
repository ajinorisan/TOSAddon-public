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
local addonName = "MINI_ADDONS"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.4.4"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

local acutil = require("acutil")
local os = require("os")
local folder_path = string.format("../addons/%s", addonNameLower)
os.execute('mkdir "' .. folder_path .. '"')

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

g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)
g.buffsFileLoc = string.format('../addons/%s/buffs.json', addonNameLower)

function MINI_ADDONS_SAVE_SETTINGS()
    acutil.saveJSON(g.settingsFileLoc, g.settings);
end

function MINI_ADDONS_LOAD_SETTINGS()

    local settings, err = acutil.loadJSON(g.settingsFileLoc, g.settings)
    if err then
        -- 設定ファイル読み込み失敗時処理
        -- CHAT_SYSTEM(string.format("[%s] cannot load setting files", addonNameLower))
    end

    local defaultSettings = {
        reword_x = 1100,
        reword_y = 100,
        allcall = 0,
        under_staff = 1,
        raid_record = 1,
        party_buff = 1,
        chat_system = 1,
        channel_display = 1,
        mini_btn = 1,
        market_display = 1,
        restart_move = 1,
        pet_init = 1,
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
        party_info = 1,
        relic_gauge = 1,
        raid_check = 1,
        coin_count = 0,
        bgm = 0,
        my_effect = 0,
        vakarine = 0
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

    local buffs = acutil.loadJSON(g.buffsFileLoc, g.buffs)

    if not buffs then
        buffs = {}
    end

    g.buffs = buffs
    acutil.saveJSON(g.buffsFileLoc, g.buffs);

    g.buffid = {}
    for key, value in pairs(g.buffs) do
        if value == 1 then
            table.insert(g.buffid, tonumber(key))
        end
    end

end

function MINI_ADDONS_OPEN_WORLDMAP2_MINIMAP(frame, msg)
    -- acutil.getEventArgs(msg)
    print("MINI_ADDONS_OPEN_WORLDMAP2_MINIMAP")
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
function MINI_ADDONS_ON_INIT(addon, frame)
    g.addon = addon
    g.frame = frame
    g.cid = info.GetCID(session.GetMyHandle())
    g.lang = option.GetCurrentCountry()

    MINI_ADDONS_LOAD_SETTINGS()

    local map = GetClass('Map', session.GetMapName());
    local keyword = TryGetProp(map, 'Keyword', 'None');
    local keyword_table = StringSplit(keyword, ';');
    if table.find(keyword_table, 'IsRaidField') > 0 and g.settings.vakarine == 1 then
        addon:RegisterMsg('GAME_START', "MINI_ADDONS_VAKARINE_NOTICE")
    end

    g.SetupHook(MINI_ADDONS_EARTHTOWERSHOP_CHANGECOUNT_NUM_CHANGE, "EARTHTOWERSHOP_CHANGECOUNT_NUM_CHANGE")
    g.SetupHook(MINI_ADDONS_INDUNENTER_REQ_UNDERSTAFF_ENTER_ALLOW, "INDUNENTER_REQ_UNDERSTAFF_ENTER_ALLOW")
    -- g.SetupHook(MINI_ADDONS_RAID_RECORD_INIT, "RAID_RECORD_INIT")
    g.SetupHook(MINI_ADDONS_ON_PARTYINFO_BUFFLIST_UPDATE, "ON_PARTYINFO_BUFFLIST_UPDATE")
    g.SetupHook(MINI_ADDONS_CHAT_SYSTEM, "CHAT_SYSTEM")
    g.SetupHook(MINI_ADDONS_UPDATE_CURRENT_CHANNEL_TRAFFIC, "UPDATE_CURRENT_CHANNEL_TRAFFIC")
    g.SetupHook(MINI_ADDONS_NOTICE_ON_MSG, "NOTICE_ON_MSG")
    g.SetupHook(MINI_ADDONS_CHAT_TEXT_LINKCHAR_FONTSET, "CHAT_TEXT_LINKCHAR_FONTSET")

    acutil.setupEvent(addon, "RESTART_CONTENTS_ON_HERE", "MINI_ADDONS_RESTART_CONTENTS_ON_HERE");
    acutil.setupEvent(addon, "MARKET_SELL_UPDATE_REG_SLOT_ITEM", "MINI_ADDONS_MARKET_SELL_UPDATE_REG_SLOT_ITEM");
    acutil.setupEvent(addon, "OPEN_WORLDMAP2_MINIMAP", "MINI_ADDONS_OPEN_WORLDMAP2_MINIMAP");

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
    end

    if g.settings.dialog_ctrl == 1 then
        addon:RegisterMsg("DIALOG_CHANGE_SELECT", "MINI_ADDONS_DIALOG_CHANGE_SELECT")
    end

    if g.settings.pc_name == 1 then
        addon:RegisterMsg("FPS_UPDATE", "MINI_ADDONS_PCNAME_REPLACE")
    end

    acutil.setupEvent(addon, "CONFIG_ENABLE_AUTO_CASTING", "MINI_ADDONS_CONFIG_ENABLE_AUTO_CASTING");
    if g.settings.auto_cast == 1 then
        addon:RegisterMsg("GAME_START_3SEC", "MINI_ADDONS_SET_ENABLE_AUTO_CASTING_3SEC")
    end

    if g.settings.channel_info == 1 then
        addon:RegisterMsg("GAME_START", "MINI_ADDONS_GAME_START_CHANNEL_LIST")
    end

    if g.settings.relic_gauge == 1 then
        addon:RegisterMsg("GAME_START", "MINI_ADDONS_CHARBASE_RELIC")
        addon:RegisterMsg("RP_UPDATE", "MINI_ADDONS_CHARBASE_RELIC")
    end

    if g.settings.raid_check == 1 then
        acutil.setupEvent(addon, 'ACCOUNTWAREHOUSE_OPEN', "MINI_ADDONS_CHECK_DREAMY_ABYSS")
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

    local pc = GetMyPCObject();
    local curMap = GetZoneName(pc)
    local mapCls = GetClass("Map", curMap)

    if mapCls.MapType == "City" then

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
    end

    if g.settings.mini_btn == 1 then
        if mapCls.MapType ~= "Field" and mapCls.MapType ~= "City" then
            addon:RegisterMsg("GAME_START", "MINI_ADDONS_MINIMIZED_CLOSE")
        end
    end

    MINI_ADDONS_NEW_FRAME_INIT()
end

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
        elseif str == "Check to enable" then
            str = "チェックすると有効化"
        elseif str == "※Character change is required to enable or disable some functions" then
            str = "※一部の機能の有効化、無効化の切替はキャラクターチェンジが必要です"
        end
    elseif g.lang == "kr" then
        if str == "Skip confirmation for admission of 4 or less people" then
            str = "4인 이하 입장 시 확인을 건너뜁니다"
        elseif str == "Raid records movable and resizable" then
            str = "레이드 기록을 이동 가능하고 크기 조정 가능하게 합니다"
        elseif str == "Hide buffs for party members" then
            str = "파티원 버프를 숨깁니다"
        elseif str == "You can choose which buffs to display" then
            str = "표시할 버프를 선택할 수 있습니다"
        elseif str == "Perfect and Black Market notices not displayed in chat" then
            str = "완벽 및 블랙 마켓 공지를 채팅에 표시하지 않습니다"
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
            str = "각종 대화를 제어합니다"
        elseif str == "Set auto casting per character" then
            str = "캐릭터별로 자동 시전 설정"
        elseif str == "Automatically used when acquiring coin items" then
            str =
                "용병단 코인, 시즌 코인, 왕국 재건단 코인을 획득할 때 자동으로 사용됩니다"
        elseif str == "Notification of forgetting to equip ark and emblem upon entry to the hard raid" then
            str = "하드 레이드 입장 시 아크 및 엠블렘 장착 잊음을 알림니다"
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
            str = " 레이드에 있는 바카린 장비를 다른 플레이어에게 알리기"
        elseif str == "Check to enable" then
            str = "체크 시 활성화"
        elseif str == "※Character change is required to enable or disable some functions" then
            str = "※일부 기능을 활성화하거나 비활성화하려면 캐릭터 변경이 필요합니다"
        end
    end
    return str
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
    }, {
        name = "raid_check",
        check = g.settings.raid_check,
        text = "{ol}{#FF4500}" ..
            MINI_ADDONS_LANG("Prevents character change mistakes during the hard raid on the Dreamy& Abyss")
    }, {
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
        end
        x = x + 30

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

function MINI_ADDONS_ISCHECK(frame, ctrl, argStr, argNum)
    local ischeck = ctrl:IsChecked()
    local ctrlname = ctrl:GetName()
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
        vakarine = "vakarine_checkbox"
    }

    for settingName, checkboxName in pairs(settingNames) do
        if ctrlname == checkboxName then
            g.settings[settingName] = ischeck
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
end

function MINI_ADDONS_NEW_FRAME_INIT()

    local newframe = ui.CreateNewFrame("notice_on_pc", "mini_addons_new", 0, 0, 110, 50)
    AUTO_CAST(newframe)
    newframe:SetSkinName('None')
    newframe:Resize(30, 30)
    newframe:SetPos(1580, 305)
    newframe:SetTitleBarSkin("None")
    local btn = newframe:CreateOrGetControl('button', 'mini', 0, 0, 25, 30)
    btn:SetSkinName("None")
    btn:SetText("{img sysmenu_mac 30 30}")

    btn:SetEventScript(ui.LBUTTONDOWN, "MINI_ADDONS_SETTING_FRAME_INIT")
    local text = g.lang == "Japanese" and "{ol}左クリック: Mini Addons 設定{nl}右クリック: MUTE" or
                     "{ol}Left click: Mini Addons settings{nl}Right click: MUTE"
    btn:SetTextTooltip(text)
    btn:SetEventScript(ui.RBUTTONUP, "MINI_ADDONS_SOUND_TOGGLE")
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
        return
    else
        MINI_ADDONS_NEW_FRAME_INIT()
        if g.settings.channel_info == 1 then
            MINI_ADDONS_GAME_START_CHANNEL_LIST()
        end
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
    frame:RunUpdateScript("MINI_ADDONS_POPUP_CHANNEL_LIST", 5.0)
    return
end

function MINI_ADDONS_channelframe_move(frame)

    if g.settings.frame_X ~= frame:GetX() or g.settings.frame_Y ~= frame:GetY() then
        g.settings.frame_X = frame:GetX()
        g.settings.frame_Y = frame:GetY()
        MINI_ADDONS_SAVE_SETTINGS()
    end
end

function MINI_ADDONS_POPUP_CHANNEL_LIST()

    local frame = ui.CreateNewFrame("notice_on_pc", "mini_addons_channel", 10, 10, 10, 10)
    AUTO_CAST(frame)
    frame:RemoveAllChild();
    frame:SetSkinName('None')
    frame:SetTitleBarSkin("None")
    frame:EnableHittestFrame(1);
    frame:EnableMove(1)
    if g.settings.frame_X == nil then
        g.settings.frame_X = 1500
    end
    if g.settings.frame_Y == nil then
        g.settings.frame_Y = 395
    end
    MINI_ADDONS_SAVE_SETTINGS()
    frame:SetPos(g.settings.frame_X, g.settings.frame_Y)
    frame:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_channelframe_move")

    local title = frame:CreateOrGetControl("richtext", "title", 5, 0)
    title:SetText("{ol}{s12}channel info")

    local zoneInsts = session.serverState.GetMap();
    if zoneInsts ~= nil then
        local cnt = zoneInsts:GetZoneInstCount();
        for i = 0, cnt - 1 do
            local zoneInst = zoneInsts:GetZoneInstByIndex(i);
            -- local str, gaugeString = GET_CHANNEL_STRING(zoneInst, true);
            local String = zoneInst.pcCount
            local btn = frame:CreateOrGetControl("button", "slot" .. i, i * 50 + 5, 15, 50, 40)
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
                btn:SetText(text)
            else
                local text = "{ol}{s12}ch" .. tonumber(i + 1) .. "{nl}{s16}{#FFCC33}" .. String
                btn:SetText(text)
            end
        end
        frame:Resize(cnt * 50 + 20, 60)
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

function MINI_ADDONS_PCNAME_REPLACE()
    local frame = ui.GetFrame("headsupdisplay")
    local LoginName = session.GetMySession():GetPCApc():GetName()
    local name_text = GET_CHILD_RECURSIVELY(frame, "name_text")
    -- name_text:SetText("")
    name_text:SetText("{@st41}" .. tostring(LoginName))
    return
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
    local frame = ui.GetFrame("restart_contents")

    local ItemBtn = GET_CHILD_RECURSIVELY(frame, "btn_restart_" .. 1);
    local itemWidth = ItemBtn:GetWidth();

    local x, y = GET_SCREEN_XY(ItemBtn, itemWidth / 2.5);
    mouse.SetPos(x, y);
    DialogSelect_index = 1;
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

    local sortedBuffIDs = {}
    for buffID, _ in pairs(g.buffs) do
        table.insert(sortedBuffIDs, tonumber(buffID))
    end
    table.sort(sortedBuffIDs)

    local bufflisttext = bufflistframe:CreateOrGetControl('richtext', 'bufflisttext', 90, 10, 200, 30)
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
end

function MINI_ADDONS_BUFFLIST_FRAME_CLOSE()
    local frame = ui.GetFrame("mini_addons_bufflist")
    frame:ShowWindow(0)
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
                        if cls ~= nil and IS_PARTY_INFO_SHOWICON(cls.ShowIcon) == true and cls.ClassName ~= "TeamLevel" then
                            local buffOver = partyMemberInfo:GetBuffOverByIndex(j);
                            local buffTime = partyMemberInfo:GetBuffTimeByIndex(j);
                            local slot = nil;
                            if cls.Group1 == 'Buff' then
                                MINI_ADDONS_BUFF_TABLE_INSERT(buffID)
                                if g.settings.party_buff == 1 then
                                    local excludedBuffIDs = g.buffid
                                    if MINI_ADDONS_IsBuffExcluded(cls.ClassID, excludedBuffIDs) then
                                        slot = buffListSlotSet:GetSlotByIndex(buffIndex);
                                        buffIndex = buffIndex + 1;
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
                                -- icon:SetEnable(1)

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

function MINI_ADDONS_BUFF_TABLE_INSERT(buffID)

    local buffIDStr = tostring(buffID)
    if g.buffs[buffIDStr] == nil then
        g.buffs[buffIDStr] = 0
        acutil.saveJSON(g.buffsFileLoc, g.buffs)
    end
end

function MINI_ADDONS_IsBuffExcluded(buffID, excludedBuffIDs)
    for _, id in ipairs(excludedBuffIDs) do
        if buffID == id then
            return true -- 除外リストに含まれる場合、trueを返す
        end
    end
    return false -- 除外リストに含まれない場合、falseを返す
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

--[[function MINI_ADDONS_SETTING_FRAME_INIT()

    local frame = ui.GetFrame("mini_addons")

    frame:SetSkinName("test_frame_midle_light")
    frame:SetLayerLevel(93) -- クイックスロットが91やから

    frame:ShowTitleBar(0);
    frame:EnableHittestFrame(1)
    frame:EnableHide(0)
    frame:EnableHitTest(1)
    frame:SetAlpha(100)
    frame:RemoveAllChild()

    frame:SetEventScript(ui.RBUTTONUP, "MINI_ADDONS_FRAME_CLOSE")

    local close = frame:CreateOrGetControl("button", "close", 615, 5, 30, 30)
    AUTO_CAST(close)
    close:SetGravity(ui.RIGHT, ui.TOP);
    close:SetSkinName("None")
    close:SetText("{img testclose_button 30 30}")
    close:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_FRAME_CLOSE")

    local x = 10
    local under_staff = frame:CreateOrGetControl("richtext", "under_staff", 40, x + 5)
    under_staff:SetText("{ol}{#FF4500}" .. MINI_ADDONS_LANG("Skip confirmation for admission of 4 or less people"))
    under_staff:SetTextTooltip("{ol}4인 이하 입장 시 확인 생략")

    local under_staff_checkbox = frame:CreateOrGetControl('checkbox', 'under_staff_checkbox', 10, x, 25, 25)
    AUTO_CAST(under_staff_checkbox)
    under_staff_checkbox:SetCheck(g.settings.under_staff)
    under_staff_checkbox:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_ISCHECK")
    under_staff_checkbox:SetTextTooltip(MINI_ADDONS_LANG("Check to enable"))

    x = x + 30

    local raid_record = frame:CreateOrGetControl("richtext", "raid_record", 40, x + 5)
    raid_record:SetText("{ol}{#FF4500}" .. MINI_ADDONS_LANG("Raid records movable and resizable"))
    raid_record:SetTextTooltip("레이드 레코드의 이동 및 크기 변경 가능")

    local raid_record_checkbox = frame:CreateOrGetControl('checkbox', 'raid_record_checkbox', 10, x, 25, 25)
    AUTO_CAST(raid_record_checkbox)
    raid_record_checkbox:SetCheck(g.settings.raid_record)
    raid_record_checkbox:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_ISCHECK")
    raid_record_checkbox:SetTextTooltip(MINI_ADDONS_LANG("Check to enable"))
    x = x + 30

    local party_buff = frame:CreateOrGetControl("richtext", "party_buff", 110, x + 5, 80, x + 5)
    party_buff:SetText("{ol}{#FF4500}" .. MINI_ADDONS_LANG("Hide buffs for party members"))
    party_buff:SetTextTooltip("파티원의 버프를 숨깁니다.")

    local party_buff_checkbox = frame:CreateOrGetControl('checkbox', 'party_buff_checkbox', 10, x, 25, 25)
    AUTO_CAST(party_buff_checkbox)
    party_buff_checkbox:SetCheck(g.settings.party_buff)
    party_buff_checkbox:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_ISCHECK")
    party_buff_checkbox:SetTextTooltip(MINI_ADDONS_LANG("Check to enable"))

    local party_buff_btn = frame:CreateOrGetControl("button", "party_buff_btn", 40, x, 40, 30)
    AUTO_CAST(party_buff_btn)
    party_buff_btn:SetText("{ol}{#FFFFFF}bufflist")
    party_buff_btn:SetTextTooltip(MINI_ADDONS_LANG("You can choose which buffs to display"))
    party_buff_btn:SetSkinName("test_red_button")
    party_buff_btn:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_BUFFLIST_FRAME_INIT")

    x = x + 30

    local chat_system = frame:CreateOrGetControl("richtext", "chat_system", 40, x + 5)
    chat_system:SetText("{ol}{#FF4500}" .. MINI_ADDONS_LANG("Perfect and Black Market notices not displayed in chat"))
    chat_system:SetTextTooltip("퍼펙트 및 블랙마켓 공지사항을 채팅에 표시하지 않습니다.")

    local chat_system_checkbox = frame:CreateOrGetControl('checkbox', 'chat_system_checkbox', 10, x, 25, 25)
    AUTO_CAST(chat_system_checkbox)
    chat_system_checkbox:SetCheck(g.settings.chat_system)
    chat_system_checkbox:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_ISCHECK")
    chat_system_checkbox:SetTextTooltip(MINI_ADDONS_LANG("Check to enable"))
    x = x + 30

    local channel_display = frame:CreateOrGetControl("richtext", "channel_display", 40, x + 5)
    channel_display:SetText("{ol}{#FF4500}" .. MINI_ADDONS_LANG("Fixed channel display misalignment"))
    channel_display:SetTextTooltip("채널 표시가 어긋나는 현상 수정")

    local channel_display_checkbox = frame:CreateOrGetControl('checkbox', 'channel_display_checkbox', 10, x, 25, 25)
    AUTO_CAST(channel_display_checkbox)
    channel_display_checkbox:SetCheck(g.settings.channel_display)
    channel_display_checkbox:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_ISCHECK")
    channel_display_checkbox:SetTextTooltip(MINI_ADDONS_LANG("Check to enable"))
    x = x + 30

    local mini_btn = frame:CreateOrGetControl("richtext", "mini_btn", 40, x + 5)
    mini_btn:SetText("{ol}{#FF4500}" .. MINI_ADDONS_LANG("Hide mini-button in upper right corner during raid"))
    mini_btn:SetTextTooltip("레이드 시 오른쪽 상단 미니 버튼 숨기기")

    local mini_btn_checkbox = frame:CreateOrGetControl('checkbox', 'mini_btn_checkbox', 10, x, 25, 25)
    AUTO_CAST(mini_btn_checkbox)
    mini_btn_checkbox:SetCheck(g.settings.mini_btn)
    mini_btn_checkbox:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_ISCHECK")
    mini_btn_checkbox:SetTextTooltip(MINI_ADDONS_LANG("Check to enable"))

    x = x + 30

    local market_display = frame:CreateOrGetControl("richtext", "market_display", 40, x + 5)
    market_display:SetText("{ol}{#FF4500}" ..
                               MINI_ADDONS_LANG(
            "When moving into town, the list of stores in the upper right corner should be open"))
    market_display:SetTextTooltip(
        "{거리로 이동할 때, 오른쪽 상단의 상점 목록이 열린 상태로 만듭니다.")

    local market_display_checkbox = frame:CreateOrGetControl('checkbox', 'market_display_checkbox', 10, x, 25, 25)
    AUTO_CAST(market_display_checkbox)
    market_display_checkbox:SetCheck(g.settings.market_display)
    market_display_checkbox:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_ISCHECK")
    market_display_checkbox:SetTextTooltip(MINI_ADDONS_LANG("Check to enable"))

    x = x + 30

    local restart_move = frame:CreateOrGetControl("richtext", "restart_move", 40, x + 5)
    restart_move:SetText("{ol}{#FF4500}" ..
                             MINI_ADDONS_LANG("Enable to move the choice frame at restart. For colony visits"))
    restart_move:SetTextTooltip(
        "재시작 시 선택 프레임을 움직일 수 있도록 합니다. 식민지 견학용.")

    local restart_move_checkbox = frame:CreateOrGetControl('checkbox', 'restart_move_checkbox', 10, x, 25, 25)
    AUTO_CAST(restart_move_checkbox)
    restart_move_checkbox:SetCheck(g.settings.restart_move)
    restart_move_checkbox:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_ISCHECK")
    restart_move_checkbox:SetTextTooltip(MINI_ADDONS_LANG("Check to enable"))

    x = x + 30

    local dialog_ctrl = frame:CreateOrGetControl("richtext", "dialog_ctrl", 40, x + 5)
    dialog_ctrl:SetText("{ol}{#FF4500}" .. MINI_ADDONS_LANG("Controls various dialogs"))
    dialog_ctrl:SetTextTooltip("각종 대화 상자를 제어합니다")

    local dialog_ctrl_checkbox = frame:CreateOrGetControl('checkbox', 'dialog_ctrl_checkbox', 10, x, 25, 25)
    AUTO_CAST(dialog_ctrl_checkbox)
    dialog_ctrl_checkbox:SetCheck(g.settings.dialog_ctrl)
    dialog_ctrl_checkbox:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_ISCHECK")
    dialog_ctrl_checkbox:SetTextTooltip(MINI_ADDONS_LANG("Check to enable"))

    x = x + 30

    local auto_cast = frame:CreateOrGetControl("richtext", "auto_cast", 40, x + 5)
    auto_cast:SetText("{ol}{#FF4500}" .. MINI_ADDONS_LANG("Autocasting is set up for each character"))
    auto_cast:SetTextTooltip("자동 캐스팅을 캐릭터별로 설정합니다.")

    local auto_cast_checkbox = frame:CreateOrGetControl('checkbox', 'auto_cast_checkbox', 10, x, 25, 25)
    AUTO_CAST(auto_cast_checkbox)
    auto_cast_checkbox:SetCheck(g.settings.auto_cast)
    auto_cast_checkbox:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_ISCHECK")
    auto_cast_checkbox:SetTextTooltip(MINI_ADDONS_LANG("Check to enable"))

    x = x + 30

    local coin_use = frame:CreateOrGetControl("richtext", "coin_use", 40, x + 5)
    coin_use:SetText("{ol}{#FF4500}" .. MINI_ADDONS_LANG("Automatically used when acquiring coin items"))
    coin_use:SetTextTooltip(
        "용병단 코인, 시즌 코인, 왕국 재건단 코인 획득 시 자동으로 사용됩니다")

    local coin_use_checkbox = frame:CreateOrGetControl('checkbox', 'coin_use_checkbox', 10, x, 25, 25)
    AUTO_CAST(coin_use_checkbox)
    coin_use_checkbox:SetCheck(g.settings.coin_use)
    coin_use_checkbox:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_ISCHECK")
    coin_use_checkbox:SetTextTooltip(MINI_ADDONS_LANG("Check to enable"))

    x = x + 30
    local equip_info = frame:CreateOrGetControl("richtext", "equip_info", 40, x + 5)
    equip_info:SetText("{ol}{#FF4500}" ..
                           MINI_ADDONS_LANG(
            "Notification of forgetting to equip ark and emblem upon entry to the hard raid"))
    equip_info:SetTextTooltip(
        "하드 레이드 입장 시 아크와 엠블럼을 잊어버린 것을 알려드립니다.")

    local equip_info_checkbox = frame:CreateOrGetControl('checkbox', 'equip_info_checkbox', 10, x, 25, 25)
    AUTO_CAST(equip_info_checkbox)
    equip_info_checkbox:SetCheck(g.settings.equip_info)
    equip_info_checkbox:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_ISCHECK")
    equip_info_checkbox:SetTextTooltip(MINI_ADDONS_LANG("Check to enable"))
    x = x + 30

    local automatch_layer = frame:CreateOrGetControl("richtext", "automatch_layer", 40, x + 5)
    automatch_layer:SetText("{ol}{#FF4500}" .. MINI_ADDONS_LANG("Lower the layer level of the frame when auto-matching"))
    automatch_layer:SetTextTooltip("오토매치 시 프레임의 레이어 레벨을 낮춥니다.")

    local automatch_layer_checkbox = frame:CreateOrGetControl('checkbox', 'automatch_layer_checkbox', 10, x, 25, 25)
    AUTO_CAST(automatch_layer_checkbox)

    automatch_layer_checkbox:SetCheck(g.settings.automatch_layer)
    automatch_layer_checkbox:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_ISCHECK")
    automatch_layer_checkbox:SetTextTooltip(MINI_ADDONS_LANG("Check to enable"))
    x = x + 30

    local quest_hide = frame:CreateOrGetControl("richtext", "quest_hide", 40, x + 5)
    quest_hide:SetText("{ol}{#FF4500}" .. MINI_ADDONS_LANG("Hide the quest list"))
    quest_hide:SetTextTooltip("퀘스트 목록을 숨깁니다.")

    local quest_hide_checkbox = frame:CreateOrGetControl('checkbox', 'quest_hide_checkbox', 10, x, 25, 25)
    AUTO_CAST(quest_hide_checkbox)

    quest_hide_checkbox:SetCheck(g.settings.quest_hide)
    quest_hide_checkbox:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_ISCHECK")
    quest_hide_checkbox:SetTextTooltip(MINI_ADDONS_LANG("Check to enable"))

    x = x + 30

    local pc_name = frame:CreateOrGetControl("richtext", "pc_name", 40, x + 5)
    pc_name:SetText("{ol}{#FF4500}" .. MINI_ADDONS_LANG("Change the upper left display to the character's name"))
    pc_name:SetTextTooltip("왼쪽 상단의 표시를 캐릭터 이름으로 변경합니다.")

    local pc_name_checkbox = frame:CreateOrGetControl('checkbox', 'pc_name_checkbox', 10, x, 25, 25)
    AUTO_CAST(pc_name_checkbox)

    pc_name_checkbox:SetCheck(g.settings.pc_name)
    pc_name_checkbox:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_ISCHECK")
    pc_name_checkbox:SetTextTooltip(MINI_ADDONS_LANG("Check to enable"))

    x = x + 30

    local channel_info = frame:CreateOrGetControl("richtext", "channel_info", 40, x + 5)
    channel_info:SetText("{ol}{#FF4500}" .. MINI_ADDONS_LANG("Displays the channel switching frame"))
    channel_info:SetTextTooltip("채널 전환 프레임을 표시합니다.")

    local channel_info_checkbox = frame:CreateOrGetControl('checkbox', 'channel_info_checkbox', 10, x, 25, 25)
    AUTO_CAST(channel_info_checkbox)
    channel_info_checkbox:SetCheck(g.settings.channel_info)
    channel_info_checkbox:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_ISCHECK")
    channel_info_checkbox:SetTextTooltip(MINI_ADDONS_LANG("Check to enable"))
    x = x + 30

    local other_effect = frame:CreateOrGetControl("richtext", "other_effect", 110, x + 5)
    other_effect:SetText("{ol}{#FF4500}" .. MINI_ADDONS_LANG("Adjusts the effect of others. 1~100, recommended 75"))
    other_effect:SetTextTooltip(
        "다른 사람의 효과를 1에서 100까지 조정할 수 있으며, 권장치는 75입니다.")

    local other_effect_checkbox = frame:CreateOrGetControl('checkbox', 'other_effect_checkbox', 10, x, 25, 25)
    AUTO_CAST(other_effect_checkbox)
    other_effect_checkbox:SetCheck(g.settings.other_effect)
    other_effect_checkbox:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_ISCHECK")
    other_effect_checkbox:SetTextTooltip(MINI_ADDONS_LANG("Check to enable"))

    local other_effect_edit = frame:CreateOrGetControl('edit', 'other_effect_edit', 40, x, 60, 25)
    AUTO_CAST(other_effect_edit)
    other_effect_edit:SetEventScript(ui.ENTERKEY, "MINI_ADDONS_OTHER_EFFECT_EDIT")
    other_effect_edit:SetTextTooltip("{@st59}1~100")
    other_effect_edit:SetFontName("white_16_ol")
    other_effect_edit:SetTextAlign("center", "center")
    local other_effect = config.GetOtherEffectTransparency()

    local num = math.floor(other_effect * 0.392156862745 + 0.5)
    other_effect_edit:SetText(num)

    x = x + 30

    local auto_gacha = frame:CreateOrGetControl("richtext", "auto_gacha", 100, x + 5)
    auto_gacha:SetText("{ol}{#FF4500}" .. MINI_ADDONS_LANG("Automate the display of the Goddess Protection gacha frame"))
    auto_gacha:SetTextTooltip("여신의 가호 가챠 프레임 표시를 자동화합니다")

    local auto_gacha_checkbox = frame:CreateOrGetControl('checkbox', 'auto_gacha_checkbox', 10, x, 25, 25)
    AUTO_CAST(auto_gacha_checkbox)
    auto_gacha_checkbox:SetCheck(g.settings.auto_gacha)
    auto_gacha_checkbox:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_ISCHECK")
    auto_gacha_checkbox:SetTextTooltip(MINI_ADDONS_LANG("Check to enable"))

    local auto_gacha_btn = frame:CreateOrGetControl('button', 'auto_gacha_btn', 40, x, 50, 30)
    AUTO_CAST(auto_gacha_btn)

    if g.settings.auto_gacha_start == 0 or g.settings.auto_gacha_start == nil then
        auto_gacha_btn:SetText("{ol}{#FFFFFF}OFF")
        auto_gacha_btn:SetSkinName("test_gray_button");
        g.settings.auto_gacha_start = 0

    else
        auto_gacha_btn:SetText("{ol}{#FFFFFF}ON")
        auto_gacha_btn:SetSkinName("test_red_button")

    end
    MINI_ADDONS_SAVE_SETTINGS()
    auto_gacha_btn:SetTextTooltip(MINI_ADDONS_LANG(
        "When turned on, the gacha starts automatically.CC required for switching"))

    auto_gacha_btn:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_GP_AUTOSTART_OPERATION")

    x = x + 30

    local skill_enchant = frame:CreateOrGetControl("richtext", "skill_enchant", 40, x + 5)
    skill_enchant:SetText("{ol}{#FF4500}" .. MINI_ADDONS_LANG("Automatically sets items for skill refining"))
    skill_enchant:SetTextTooltip("스킬 연성 아이템을 자동으로 설정합니다.")

    local skill_enchant_checkbox = frame:CreateOrGetControl('checkbox', 'skill_enchant_checkbox', 10, x, 25, 25)
    AUTO_CAST(skill_enchant_checkbox)
    skill_enchant_checkbox:SetCheck(g.settings.skill_enchant)
    skill_enchant_checkbox:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_ISCHECK")
    skill_enchant_checkbox:SetTextTooltip(MINI_ADDONS_LANG("Check to enable"))
    x = x + 30

    local relic_gauge = frame:CreateOrGetControl("richtext", "relic_gauge", 40, x + 5)
    relic_gauge:SetText("{ol}{#FF4500}" .. MINI_ADDONS_LANG("Add a Relic to the character's gauge"))
    relic_gauge:SetTextTooltip("캐릭터의 게이지에 유물을 추가합니다.")

    local relic_gauge_checkbox = frame:CreateOrGetControl('checkbox', 'relic_gauge_checkbox', 10, x, 25, 25)
    AUTO_CAST(relic_gauge_checkbox)
    relic_gauge_checkbox:SetCheck(g.settings.relic_gauge)
    relic_gauge_checkbox:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_ISCHECK")
    relic_gauge_checkbox:SetTextTooltip(MINI_ADDONS_LANG("Check to enable"))
    x = x + 30

    local raid_check = frame:CreateOrGetControl("richtext", "raid_check", 40, x + 5)
    raid_check:SetText("{ol}{#FF4500}" ..
                           MINI_ADDONS_LANG(
            "Prevents character change mistakes during the hard raid on the Dreamy& Abyss"))
    raid_check:SetTextTooltip("몽환 & 심연의 하드 레이드 시 캐릭터 변경 실수를 방지합니다.")

    local raid_check_checkbox = frame:CreateOrGetControl('checkbox', 'raid_check_checkbox', 10, x, 25, 25)
    AUTO_CAST(raid_check_checkbox)
    raid_check_checkbox:SetCheck(g.settings.raid_check)
    raid_check_checkbox:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_ISCHECK")
    raid_check_checkbox:SetTextTooltip(MINI_ADDONS_LANG("Check to enable"))
    x = x + 30
    -- !
    local party_info = frame:CreateOrGetControl("richtext", "party_info", 40, x + 5)
    party_info:SetText("{ol}{#FF4500}" ..
                           MINI_ADDONS_LANG(
            "Switching the display of the party info frame. For mouse mode.Party info right-click"))
    party_info:SetTextTooltip("파티 인포 프레임의 표시 전환. 마우스 모드용")

    local party_info_checkbox = frame:CreateOrGetControl('checkbox', 'party_info_checkbox', 10, x, 25, 25)
    AUTO_CAST(party_info_checkbox)
    party_info_checkbox:SetCheck(g.settings.party_info)
    party_info_checkbox:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_ISCHECK")
    party_info_checkbox:SetTextTooltip(MINI_ADDONS_LANG("Check to enable"))
    x = x + 30

    local coin_count = frame:CreateOrGetControl("richtext", "coin_count", 40, x + 5)
    coin_count:SetText("{ol}{#FF4500}" .. MINI_ADDONS_LANG("The maximum coin limit for each store is raised to 99999"))
    coin_count:SetTextTooltip("각 상점의 코인 한도를 99999로 상향 조정합니다")

    local coin_count_checkbox = frame:CreateOrGetControl('checkbox', 'coin_count_checkbox', 10, x, 25, 25)
    AUTO_CAST(coin_count_checkbox)
    coin_count_checkbox:SetCheck(g.settings.coin_count)
    coin_count_checkbox:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_ISCHECK")
    coin_count_checkbox:SetTextTooltip(MINI_ADDONS_LANG("Check to enable"))
    x = x + 30

    local bgm = frame:CreateOrGetControl("richtext", "bgm", 40, x + 5)
    bgm:SetText("{ol}{#FF4500}" .. MINI_ADDONS_LANG("Always move the BGM player in city"))
    bgm:SetTextTooltip("거리에서 배경음악 플레이어를 항상 움직인다")

    local bgm_checkbox = frame:CreateOrGetControl('checkbox', 'bgm_checkbox', 10, x, 25, 25)
    AUTO_CAST(bgm_checkbox)
    bgm_checkbox:SetCheck(g.settings.bgm)
    bgm_checkbox:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_ISCHECK")
    bgm_checkbox:SetTextTooltip(MINI_ADDONS_LANG("Check to enable"))
    x = x + 30

    local description = frame:CreateOrGetControl("richtext", "description", 40, x + 5)
    description:SetText("{ol}{#FFA500}" ..
                            MINI_ADDONS_LANG("※Character change is required to enable or disable some functions"))
    description:SetTextTooltip("일부 기능의 활성화, 비활성화 전환은 캐릭터 변경이 필요합니다")

    x = x + 30

    local langcode = option.GetCurrentCountry()

    if langcode ~= "Japanese" then
        frame:Resize(720, x)
        -- close:SetOffset(685, 5)
    else
        frame:Resize(650, x)
    end

    local screenWidth = ui.GetClientInitialWidth() -- 画面の幅
    local screenHeight = ui.GetClientInitialHeight() -- 画面の高さ
    local frameWidth = frame:GetWidth() -- フレームの幅
    local frameHeight = frame:GetHeight() -- フレームの高さ

    -- 画面の中央にフレームを配置する
    frame:SetPos((screenWidth - frameWidth) / 2, (screenHeight - frameHeight) / 2)

    frame:ShowWindow(1)

end]]

--[[function MINI_ADDONS_CLOSE_COMPANIONLIST()
    local frame = ui.GetFrame("companionlist");
    frame:ShowWindow(0);
end

]
--[[if not g.loaded then
    local loginCharID = info.GetCID(session.GetMyHandle())
    g.settings = {

        reword_x = 1100,
        reword_y = 100,

        allcall = 0,
        under_staff = 1,
        raid_record = 1,
        party_buff = 1,
        chat_system = 1,
        channel_display = 1,
        mini_btn = 1,
        market_display = 1,
        restart_move = 1,
        pet_init = 1,
        dialog_ctrl = 1,
        auto_cast = 1,
        auto_casting = {},
        buffid = {},
        coin_use = 1,
        equip_info = 1,
        automatch_layer = 1,
        quest_hide = 1,
        pc_name = 1,
        auto_gacha = 0,
        skill_enchant = 1,
        auto_gacha_start = 0,
        party_info = 1,
        relic_gauge = 1,
        raid_check = 1,
        coin_count = 0

        -- !
    }

end]]
--[[function MINI_ADDONS_UPDATE_CURRENT_CHANNEL_TRAFFIC(frame)
    local curchannel = frame:GetChild("curchannel");

    local channel = session.loginInfo.GetChannel();
    local zoneInst = session.serverState.GetZoneInst(channel);
    if g.settings.channel_display == 1 then

        if g.lang == "Japanese" then
            if zoneInst ~= nil then
                if GET_PRIVATE_CHANNEL_ACTIVE_STATE() == false then
                    local str, stateString = GET_CHANNEL_STRING(zoneInst);
                    curchannel:SetTextByKey("value", str .. "                      " .. stateString);
                else
                    local suffix = GET_SUFFIX_PRIVATE_CHANNEL(zoneInst.mapID, zoneInst.channel + 1)
                    local str, stateString = GET_CHANNEL_STRING(zoneInst, suffix);
                    curchannel:SetTextByKey("value", str .. "                      " .. stateString);
                end
            else
                curchannel:SetTextByKey("value", "");
            end
        else
            if zoneInst ~= nil then
                if GET_PRIVATE_CHANNEL_ACTIVE_STATE() == false then
                    local str, stateString = GET_CHANNEL_STRING(zoneInst);
                    curchannel:SetTextByKey("value", str .. "                                  " .. stateString);
                else
                    local suffix = GET_SUFFIX_PRIVATE_CHANNEL(zoneInst.mapID, zoneInst.channel + 1)
                    local str, stateString = GET_CHANNEL_STRING(zoneInst, suffix);
                    curchannel:SetTextByKey("value", str .. "                                  " .. stateString);
                end
            else
                curchannel:SetTextByKey("value", "");
            end

        end
    else
        if zoneInst ~= nil then
            if GET_PRIVATE_CHANNEL_ACTIVE_STATE() == false then
                local str, stateString = GET_CHANNEL_STRING(zoneInst);
                curchannel:SetTextByKey("value", str .. "                                  " .. stateString);
            else
                local suffix = GET_SUFFIX_PRIVATE_CHANNEL(zoneInst.mapID, zoneInst.channel + 1)
                local str, stateString = GET_CHANNEL_STRING(zoneInst, suffix);
                curchannel:SetTextByKey("value", str .. "                                  " .. stateString);
            end
        else
            curchannel:SetTextByKey("value", "");
        end
    end
end]]

--[[function MINI_ADDONS_BUFFLIST_UPDATE(frame)

    local frame = ui.GetFrame("partyinfo")
    frame:Resize(600, 320)
    local list = session.party.GetPartyMemberList();
    local count = list:Count();
    -- CHAT_SYSTEM(tostring(count))
    for i = 0, count - 1 do
        local partyMemberInfo = list:Element(i);
        local partyInfoCtrlSet = frame:GetChild('PTINFO_' .. partyMemberInfo:GetAID());
        AUTO_CAST(partyInfoCtrlSet)
        -- CHAT_SYSTEM(tostring(partyInfoCtrlSet))
        partyInfoCtrlSet:Resize(600, 62)
    end

end]]

--[[function MINI_ADDONS_PETINFO()

    local summonedPet = session.pet.GetSummonedPet();
    if g.settings.allcall == 1 then
        if summonedPet == nil then
            -- CHAT_SYSTEM("呼び出されていない")
            MINI_ADDONS_ON_OPEN_COMPANIONLIST()
            -- return;
        end
    elseif g.settings.allcall == 0 and g.check == 0 then
        if summonedPet == nil then
            -- CHAT_SYSTEM("呼び出されていない")
            MINI_ADDONS_ON_OPEN_COMPANIONLIST()
            -- return;
        end
    else
        return
    end

end

function MINI_ADDONS_PETLIST_FRAME_INIT()

    local frame = ui.GetFrame("companionlist");

    local title = GET_CHILD_RECURSIVELY(frame, "title")
    title:SetGravity(ui.LEFT, ui.TOP);
    title:SetOffset(10, 10);
    local checkbox = GET_CHILD_RECURSIVELY(frame, "checkbox")
    if checkbox ~= nil then

        frame:RemoveChild("checkbox")
    end

    checkbox = frame:CreateOrGetControl("checkbox", "checkbox", 240, 10, 20, 20)
    AUTO_CAST(checkbox)

    checkbox:SetTextTooltip(
        "{@st59}チェックを入れるとコンパニオンリスト呼び出し機能をオフにします(キャラクター毎に設定){nl}Checking the box turns off the companion list call function (set for each character).")

    checkbox:SetCheck(g.check)

    checkbox:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_CHECK_PET_AUTO")

    local allcall = GET_CHILD_RECURSIVELY(frame, "allcall")
    if allcall ~= nil then

        frame:RemoveChild("allcall")
    end

    allcall = frame:CreateOrGetControl("checkbox", "allcall", 215, 10, 20, 20)
    AUTO_CAST(allcall)

    allcall:SetTextTooltip(
        "{@st59}チェックを入れるとキャラ毎の設定を無視して{nl}コンパニオンリストを呼び出します(アカウント共通){nl}If checked, the companion list is called up,{nl} ignoring the settings for each character (common to all accounts).")

    allcall:SetCheck(g.settings.allcall)

    allcall:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_CHECK_PET_AUTO")

    -- UPDATE_COMPANIONLIST(frame);

end

function MINI_ADDONS_ON_OPEN_COMPANIONLIST()
    local frame = ui.GetFrame("companionlist");

    frame:SetOffset(800, 500)

    UPDATE_COMPANIONLIST(frame);
    frame:ShowWindow(1);

    ReserveScript("MINI_ADDONS_CLOSE_COMPANIONLIST()", 10.0)
end

function MINI_ADDONS_CHECK_PET_AUTO(frame)

    local checkbox = GET_CHILD_RECURSIVELY(frame, "checkbox")

    local loginCharID = info.GetCID(session.GetMyHandle())

    if checkbox:IsChecked() == 1 then
        g.settings.charid[loginCharID] = 1
        MINI_ADDONS_SAVE_SETTINGS()
        MINI_ADDONS_LOAD_SETTINGS()

    else

        g.settings.charid[loginCharID] = 0
        MINI_ADDONS_SAVE_SETTINGS()
        MINI_ADDONS_LOAD_SETTINGS()
    end

    local allcall = GET_CHILD_RECURSIVELY(frame, "allcall")
    if allcall:IsChecked() == 1 then
        g.settings.allcall = 1
        MINI_ADDONS_SAVE_SETTINGS()
        MINI_ADDONS_LOAD_SETTINGS()

    else

        g.settings.allcall = 0
        MINI_ADDONS_SAVE_SETTINGS()
        MINI_ADDONS_LOAD_SETTINGS()
    end
end]]

--[[ 激動の入り間違いを減らす
function MINI_ADDONS_INDUNINFO_DETAIL_BOSS_SELECT_LBTN_CLICK(ctrl_set, btn, clicked)

    if ctrl_set == nil or btn == nil then
        return;
    end
    local parent = ctrl_set:GetParent();
    if IS_INDUNINFO_DETAIL_BOSS_SELECT_LOCK_STATE(ctrl_set) == true then
        return;
    end
    INDUNINFO_DETAIL_BOSS_SELECT_CHECK_UPDATE(parent, ctrl_set);
    if clicked == "click" then
        imcSound.PlaySoundEvent("button_click_7");
    end
    local frame = parent:GetTopParentFrame();

    -- local framename = frame:GetClassName()
    -- print(framename)
    -- ここから追記
    local indunframe = ui.GetFrame("induninfo")
    local indun_cls_name_ffls = ctrl_set:GetName();
    local indun_cls_ffls = GetClass("Indun", indun_cls_name_ffls);
    if indun_cls_name_ffls == nil then
        return;
    end

    -- local group_id = TryGetProp(indun_cls_name_ffls, "GroupID", "None");
    -- local raid_type = TryGetProp(indun_cls_name_ffls, "RaidType", "None");

    -- print(group_id)
    -- print(raid_type)

    ---if group_id == "TurbulentCore" and raid_type == "AutoNormal" then
    -- print("test1")
    -- print("test1")
    -- 
    local indungbox = frame:CreateOrGetControl("groupbox", "textbox_1", 200, 100, 400, 200)
    indungbox:SetSkinName("None")
    indungbox:SetGravity(ui.CENTER_HORZ, ui.CENTER_VERT)
    local msgtexts = indungbox:CreateOrGetControl("richtext", "msgtexts_1", 0, 50, 295, 225)
    msgtexts:SetGravity(ui.CENTER_HORZ, ui.CENTER_VERT)
    msgtexts:SetText("{@st55_a}Spreader Select")
    local msgtexts2 = indungbox:CreateOrGetControl("richtext", "msgtexts_2", 0, 0, 295, 225)
    msgtexts2:SetGravity(ui.CENTER_HORZ, ui.CENTER_VERT)
    msgtexts2:SetText("{@st55_a}プロパゲ行くんか！？")
    local msgtextf = indungbox:CreateOrGetControl("richtext", "msgtextf_1", 0, 50, 295, 225)
    msgtextf:SetGravity(ui.CENTER_HORZ, ui.CENTER_VERT)
    msgtextf:SetText("{@st55_a}Falouros Select")
    local msgtextf2 = indungbox:CreateOrGetControl("richtext", "msgtextf_2", 0, 0, 295, 225)
    msgtextf2:SetGravity(ui.CENTER_HORZ, ui.CENTER_VERT)
    msgtextf2:SetText("{@st55_a}ファロ行くんか！？")
    if string.match(indun_cls_name_ffls, "Goddess_Raid_Spreader_Auto") then
        msgtextf:ShowWindow(0)
        msgtexts:ShowWindow(1)
        msgtextf2:ShowWindow(0)
        msgtexts2:ShowWindow(1)
        ReserveScript(string.format('MINI_ADDONS_TEXT_DELETE()'), 5.0)

    elseif string.match(indun_cls_name_ffls, "Goddess_Raid_Falouros_Auto") then
        msgtextf:ShowWindow(1)
        msgtexts:ShowWindow(0)
        msgtextf2:ShowWindow(1)
        msgtexts2:ShowWindow(0)
        ReserveScript(string]]
