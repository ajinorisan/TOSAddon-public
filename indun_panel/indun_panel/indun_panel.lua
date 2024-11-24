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
local addonName = "indun_panel"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.4.8"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

g.settingsFileLoc = string.format('../addons/%s/new_settings.json', addonNameLower)

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

function indun_panel_autozoom_init()

    local frame = ui.GetFrame("indun_panel")
    frame:SetSkinName('None')
    frame:SetLayerLevel(30)
    frame:Resize(140, 40)
    frame:SetPos(1640, 0)
    frame:SetTitleBarSkin("None")
    frame:EnableHittestFrame(1)
    frame:EnableHide(0)
    frame:EnableHitTest(1)
    frame:RemoveAllChild()

    local zoomedit = frame:CreateOrGetControl('edit', 'zoomedit', 80, 0, 60, 30)
    AUTO_CAST(zoomedit)
    zoomedit:SetText("{ol}" .. g.settings.zoom)
    zoomedit:SetFontName("white_16_ol")
    zoomedit:SetTextAlign("center", "center")
    zoomedit:SetEventScript(ui.ENTERKEY, "indun_panel_autozoom_save")
    zoomedit:SetTextTooltip(g.lang == "Japanese" and
                                "Auto Zoom Setting{nl}1～700の値で入力。標準は336。マップ切り替え時に入力の値までZoomします。0入力で機能無効化。" or
                                "Auto Zoom Setting{nl}Input a value from 0 to 700. Standard is 336. Zoom to the input value when switching maps.{nl}Disable function by inputting 0.")
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

    indun_panel_save_settings()
    ReserveScript("indun_panel_autozoom()", 1.0)

end

function indun_panel_frame_init()

    local frame = ui.GetFrame("indun_panel")

    frame:SetSkinName('None')
    frame:SetLayerLevel(30)
    -- frame:Resize(110, 50)
    frame:Resize(140, 40)
    frame:SetPos(665, 30)
    frame:SetTitleBarSkin("None")
    frame:EnableHittestFrame(1)
    frame:EnableHide(0)
    frame:EnableHitTest(1)

    frame:RemoveAllChild()

    -- local button = frame:CreateOrGetControl("button", "indun_panel_open", 0, 0, 50, 50)
    local button = frame:CreateOrGetControl("button", "indun_panel_open", 5, 5, 80, 30)
    AUTO_CAST(button)

    -- button:SetSkinName("None")
    -- sysmenu_instantDungeon
    --[[button:SetText("{img sysmenu_instantDungeon 50 50}")
    button:SetTextTooltip("{ol}Indun Panel " .. ver)
    button:SetEventScript(ui.LBUTTONUP, "indun_panel_init")]]
    button:SetText("{ol}{s11}INDUNPANEL")
    button:SetEventScript(ui.LBUTTONUP, "indun_panel_init")

    local ccbtn = frame:CreateOrGetControl('button', 'ccbtn', 90, 5, 30, 35)
    AUTO_CAST(ccbtn)
    ccbtn:SetSkinName("None")
    ccbtn:SetText("{img barrack_button_normal 30 30}")
    ccbtn:SetEventScript(ui.LBUTTONUP, "APPS_TRY_MOVE_BARRACK")

    --[[local ccbtn = frame:CreateOrGetControl('button', 'ccbtn', 60, 10, 30, 30)
    AUTO_CAST(ccbtn)
    ccbtn:SetSkinName("None")
    ccbtn:SetText("{img barrack_button_normal 30 30}")
    ccbtn:SetEventScript(ui.LBUTTONUP, "APPS_TRY_MOVE_BARRACK")]]

    frame:ShowWindow(1)
    frame:RunUpdateScript("indun_panel_time_update", 300)
end

function indun_panel_time_update(frame)

    local time = os.date("*t")
    local hour = time.hour

    if hour >= 5 and hour <= 6 and g.ex == 1 then
        pc.ReqExecuteTx_NumArgs("SCR_PVP_MINE_SHOP_OPEN", 0);
        local etsframe = ui.GetFrame('earthtowershop')
        etsframe:RunUpdateScript("INDUN_PANEL_EARTHTOWERSHOP_CLOSE_RESTART", 0.2)
        g.ex = 2
        return 0
    end
    return 1
end

function indunpanel_minimized_pvpmine_shop_init()
    local frame = ui.GetFrame('earthtowershop')
    frame:Resize(0, 0)
    pc.ReqExecuteTx_NumArgs("SCR_PVP_MINE_SHOP_OPEN", 0);
    g.ex = 1
    frame:RunUpdateScript("INDUN_PANEL_EARTHTOWERSHOP_CLOSE_RESTART", 0.2)

end

function INDUN_PANEL_EARTHTOWERSHOP_CLOSE_RESTART()
    local shopframe = ui.GetFrame('earthtowershop')
    if shopframe:IsVisible() == 1 then

        ui.CloseFrame("earthtowershop")
        shopframe:Resize(580, 1920)
        return 0
    else
        return 1
    end
end

function indun_panel_init(frame)

    frame:RemoveAllChild()

    local button = frame:CreateOrGetControl("button", "indun_panel_open", 5, 5, 80, 30)
    AUTO_CAST(button)
    button:SetText("{ol}{s11}INDUNPANEL")

    local ccbtn = frame:CreateOrGetControl('button', 'ccbtn', 90, 5, 30, 35)
    AUTO_CAST(ccbtn)
    ccbtn:SetSkinName("None")
    ccbtn:SetText("{img barrack_button_normal 30 30}")
    ccbtn:SetEventScript(ui.LBUTTONUP, "APPS_TRY_MOVE_BARRACK")
    ccbtn:SetTextTooltip(g.lang == "Japanese" and "{ol}バラックに戻ります。" or "{ol}Return to Barracks.")

    local tosshop = frame:CreateOrGetControl("button", "tosshop", 152, 8, 25, 25);
    AUTO_CAST(tosshop)
    tosshop:SetSkinName("None")
    tosshop:SetText("{img icon_item_Tos_Event_Coin 25 25}")
    tosshop:SetTextTooltip(g.lang == "Japanese" and "{ol}TOSイベントショップ" or "{ol}TOS Event Shop")
    tosshop:SetEventScript(ui.LBUTTONUP, "indun_panel_event_tos_whole_shop_open")

    -- goddess3_shop_btn
    local gabija = frame:CreateOrGetControl("button", "gabija", 180, 7, 29, 29);
    AUTO_CAST(gabija)
    gabija:SetSkinName("None")
    gabija:SetText("{img goddess_shop_btn 29 29}")
    gabija:SetTextTooltip(g.lang == "Japanese" and "{ol}ガビヤショップ" or "{ol}Gabija Shop")
    gabija:SetEventScript(ui.LBUTTONUP, "REQ_GabijaCertificate_SHOP_OPEN")

    local vakarine = frame:CreateOrGetControl("button", "vakarine", 210, 7, 29, 29);
    AUTO_CAST(vakarine)
    vakarine:SetSkinName("None")
    vakarine:SetText("{img goddess2_shop_btn 29 29}")
    vakarine:SetTextTooltip(g.lang == "Japanese" and "{ol}ヴァカリネショップ" or "{ol}Vakarine Shop")
    vakarine:SetEventScript(ui.LBUTTONUP, "REQ_VakarineCertificate_SHOP_OPEN")

    local rada = frame:CreateOrGetControl("button", "rada", 240, 7, 29, 29);
    AUTO_CAST(rada)
    rada:SetSkinName("None")
    rada:SetText("{img goddess3_shop_btn 29 29}")
    rada:SetTextTooltip(g.lang == "Japanese" and "{ol}ラダショップ" or "{ol}Rada Shop")
    rada:SetEventScript(ui.LBUTTONUP, "REQ_RadaCertificate_SHOP_OPEN")

    local configbtn = frame:CreateOrGetControl('button', 'configbtn', 120, 5, 30, 35)
    AUTO_CAST(configbtn)
    configbtn:SetSkinName("None")
    configbtn:SetText("{img config_button_normal 30 30}")
    configbtn:SetEventScript(ui.LBUTTONUP, "indun_panel_config_gb_open")
    configbtn:SetTextTooltip(g.lang == "Japanese" and "{ol}レイド表示設定" or "{ol}Raid Display Settings")

    --[[local button = frame:CreateOrGetControl("button", "indun_panel_open", 0, 0, 50, 50)
    AUTO_CAST(button)
    button:SetSkinName("None")
    -- sysmenu_instantDungeon
    button:SetText("{img sysmenu_instantDungeon 50 50}")
    -- button:SetText("{ol}{s11}INDUNPANEL")

    local ccbtn = frame:CreateOrGetControl('button', 'ccbtn', 60, 10, 30, 30)
    AUTO_CAST(ccbtn)
    ccbtn:SetSkinName("None")
    ccbtn:SetText("{img barrack_button_normal 30 30}")
    ccbtn:SetEventScript(ui.LBUTTONUP, "APPS_TRY_MOVE_BARRACK")
    ccbtn:SetTextTooltip(g.lang == "Japanese" and "{ol}バラックに戻ります。" or "{ol}Return to Barracks.")

    local configbtn = frame:CreateOrGetControl('button', 'configbtn', 100, 10, 30, 30)
    AUTO_CAST(configbtn)
    configbtn:SetSkinName("None")
    configbtn:SetText("{img config_button_normal 30 30}")
    configbtn:SetEventScript(ui.LBUTTONUP, "indun_panel_config_gb_open")
    configbtn:SetTextTooltip(g.lang == "Japanese" and "{ol}レイド表示設定" or "{ol}Raid Display Settings")

    local tosshop = frame:CreateOrGetControl("button", "tosshop", 132, 13, 25, 25);
    AUTO_CAST(tosshop)
    tosshop:SetSkinName("None")
    tosshop:SetText("{img icon_item_Tos_Event_Coin 25 25}")
    tosshop:SetTextTooltip(g.lang == "Japanese" and "{ol}TOSイベントショップ" or "{ol}TOS Event Shop")
    tosshop:SetEventScript(ui.LBUTTONUP, "indun_panel_event_tos_whole_shop_open")

    -- goddess3_shop_btn
    local gabija = frame:CreateOrGetControl("button", "gabija", 160, 12, 29, 29);
    AUTO_CAST(gabija)
    gabija:SetSkinName("None")
    gabija:SetText("{img goddess_shop_btn 29 29}")
    gabija:SetTextTooltip(g.lang == "Japanese" and "{ol}ガビヤショップ" or "{ol}Gabija Shop")
    gabija:SetEventScript(ui.LBUTTONUP, "REQ_GabijaCertificate_SHOP_OPEN")

    local vakarine = frame:CreateOrGetControl("button", "vakarine", 190, 12, 29, 29);
    AUTO_CAST(vakarine)
    vakarine:SetSkinName("None")
    vakarine:SetText("{img goddess2_shop_btn 29 29}")
    vakarine:SetTextTooltip(g.lang == "Japanese" and "{ol}ヴァカリネショップ" or "{ol}Vakarine Shop")
    vakarine:SetEventScript(ui.LBUTTONUP, "REQ_VakarineCertificate_SHOP_OPEN")

    local rada = frame:CreateOrGetControl("button", "rada", 220, 12, 29, 29);
    AUTO_CAST(rada)
    rada:SetSkinName("None")
    rada:SetText("{img goddess3_shop_btn 29 29}")
    rada:SetTextTooltip(g.lang == "Japanese" and "{ol}ラダショップ" or "{ol}Rada Shop")
    rada:SetEventScript(ui.LBUTTONUP, "REQ_RadaCertificate_SHOP_OPEN")]]

    if configbtn:IsVisible() == 1 then
        button:SetEventScript(ui.LBUTTONUP, "indun_panel_frame_init")

    end

    local checkbox = frame:CreateOrGetControl('checkbox', 'checkbox', 665, 5, 30, 30)
    AUTO_CAST(checkbox)
    checkbox:SetCheck(g.settings.checkbox)
    checkbox:SetEventScript(ui.LBUTTONUP, "indun_panel_ischecked")
    checkbox:SetTextTooltip(g.lang == "Japanese" and "{ol}チェックすると常時展開" or "{ol}IsCheck AlwaysOpen")

    local pvpmine = frame:CreateOrGetControl("richtext", "pvpmine", 520, 10)
    pvpmine:SetText("{img pvpmine_shop_btn_total 25 25}")
    pvpmine:SetTextTooltip(g.lang == "Japanese" and "{ol}傭兵団コイン数量" or "{ol}Mercenary Badge count")

    local pvpminecount = frame:CreateOrGetControl("richtext", "pvpminecount", 550, 10)
    pvpminecount:SetText(string.format("{ol}{#FFD900}{s20}%s", GET_COMMAED_STRING(indun_panel_pvpmaine_count())))

    if g.settings.season_checkbox == nil then
        g.settings.season_checkbox = 1
        indun_panel_save_settings()
    end
    if g.settings.jsr_checkbox == 1 then
        indun_panel_FIELD_BOSS_TIME_TAB_SETTING(frame)
    end

    indun_panel_frame_contents(frame)
    -- configbtn:RunUpdateScript("indun_panel_frame_update", 1.0)
    configbtn:RunUpdateScript("indun_panel_frame_contents", 1.0)
    frame:SetLayerLevel(80)
    frame:Resize(g.x + 570, g.y + 5)
    g.x = nil
    g.y = nil
    frame:SetSkinName("chat_window_2")
    frame:EnableHitTest(1);
    frame:SetAlpha(100)

end

function indun_panel_pvpmaine_count()
    local aObj = GetMyAccountObj()
    local coincount = TryGetProp(aObj, "MISC_PVP_MINE2", '0')
    if coincount == 'None' then
        coincount = '0'
    end
    return coincount
end

local induntype = {{
    challenge = {
        s460 = 1000,
        s480 = 1001,
        pt = 1002
    }
}, {
    singularity = {
        normal = 2000
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
    cemetery = {
        c490 = 684
    }
}, {
    jsr = 0
}}

function indun_panel_config_gb_open(frame, ctrl, argStr, argNum)

    local frame = ui.GetFrame("indun_panel")
    frame:SetSkinName("test_frame_low")
    frame:SetLayerLevel(90)
    frame:Resize(200, 640)
    frame:SetPos(665, 30)
    frame:EnableHittestFrame(1)
    frame:EnableHide(0)
    frame:EnableHitTest(1)
    frame:SetAlpha(100)
    frame:RemoveAllChild()
    frame:ShowWindow(1)

    local button = frame:CreateOrGetControl("button", "indun_panel_open", 5, 5, 80, 30)
    AUTO_CAST(button)
    button:SetText("{ol}{s11}INDUNPANEL")
    button:SetEventScript(ui.LBUTTONUP, "indun_panel_frame_init")

    local en_ver = frame:CreateOrGetControl('checkbox', 'en_ver', 165, 10, 25, 25)
    AUTO_CAST(en_ver)
    if g.settings.en_ver == nil then
        g.settings.en_ver = 0
        indun_panel_save_settings()
    end
    en_ver:SetCheck(g.settings.en_ver)
    en_ver:SetEventScript(ui.LBUTTONUP, "indun_panel_ischecked")
    en_ver:SetTextTooltip(g.lang == "Japanese" and "{ol}チェックすると英語表示に変更します。" or
                              "{ol}Checking the box changes the display to English.")

    local zoomedit = frame:CreateOrGetControl('edit', 'zoomedit', 100, 5, 50, 30)
    AUTO_CAST(zoomedit)
    zoomedit:SetText("{ol}" .. g.settings.zoom)
    zoomedit:SetFontName("white_16_ol")
    zoomedit:SetTextAlign("center", "center")
    zoomedit:SetEventScript(ui.ENTERKEY, "indun_panel_autozoom_save")
    local zoomtxt = g.lang == "Japanese" and
                        "{ol}1～700の値で入力。標準は336。マップ切り替え時に入力の値までZoomします。0入力で機能無効化。" or
                        "{ol}Input a value from 0 to 700. Standard is 336. Zoom to the input value when switching maps.{nl}Disable function by inputting 0."
    zoomedit:SetTextTooltip("Auto Zoom Setting{nl}" .. zoomtxt)

    local posY = 45
    local count = #induntype
    for i = 1, count do
        local entry = induntype[i]
        for key, value in pairs(entry) do

            local checkbox = frame:CreateOrGetControl('checkbox', key .. '_checkbox', 15, posY, 25, 25)
            AUTO_CAST(checkbox)
            checkbox:SetCheck(g.settings[key .. '_checkbox'])
            checkbox:SetEventScript(ui.LBUTTONUP, "indun_panel_ischecked")
            checkbox:SetText("{ol}{#FFFFFF}" .. INDUN_PANEL_LANG(key))
            checkbox:SetTextTooltip(g.lang == "Japanese" and "チェックすると表示" or "Check to show")
        end
        posY = posY + 35
    end
    frame:Resize(200, posY + 5)
end

function indun_panel_ischecked(frame, ctrl, argStr, argNum)

    local ctrlname = ctrl:GetName()
    local ischeck = ctrl:IsChecked()

    g.settings[ctrlname] = ischeck
    indun_panel_save_settings()
end

function indun_panel_event_tos_whole_shop_open()

    local frame = ui.GetFrame("earthtowershop");
    frame:SetUserValue("SHOP_TYPE", 'EVENT_TOS_WHOLE_SHOP');
    ui.OpenFrame('earthtowershop');
end

function indun_panel_FIELD_BOSS_TIME_TAB_SETTING(frame)
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

end

function indun_panel_frame_contents(frame)

    local frame = ui.GetFrame("indun_panel")
    local y = 45
    local x = 135
    local count = #induntype
    for i = 1, count do

        local entry = induntype[i]
        for key, value in pairs(entry) do

            if g.settings[key .. "_checkbox"] == 1 then
                local text = frame:CreateOrGetControl("richtext", key, x - 125, y + 5)
                text:SetText("{ol}{#FFFFFF}" .. INDUN_PANEL_LANG(key))
                text:AdjustFontSizeByWidth(120)
                if type(value) == "table" then
                    -- neringa golem
                    if key == "slogutis" or key == "upinis" or key == "roze" or key == "falouros" or key == "spreader" or
                        key == "merregina" or key == "neringa" or key == "golem" then

                        for subKey, subValue in pairs(value) do

                            indun_panel_create_frame_onsweep(frame, key, subKey, subValue, y, x)
                        end

                    elseif key == "jellyzele" or key == "delmore" or key == "giltine" or key == "earring" then

                        for subKey, subValue in pairs(value) do
                            indun_panel_create_frame(frame, key, subKey, subValue, y)
                        end
                    elseif key == "challenge" then

                        indun_panel_challenge_frame(frame, key, y)
                    elseif key == "singularity" then

                        indun_panel_singularity_frame(frame, key, y)
                    elseif key == "cemetery" then

                        indun_panel_cemetery_frame(frame, key, y)
                        --[[elseif key == "season" then

                        for subKey, subValue in ipairs(value) do
                            indun_panel_season_frame(frame, key, subKey, subValue, y)
                        end]]
                    end
                else
                    if key == "telharsha" then

                        indun_panel_telharsha_frame(frame, key, y)
                    elseif key == "velnice" then

                        indun_panel_velnice_frame(frame, y)
                    elseif key == "jsr" then

                        indun_panel_jsr_frame(frame, key, y)
                    end
                end
                y = y + 35
            end
        end
    end
    g.x = x
    g.y = y
    return 1
end

function indun_panel_GetEntranceCountText(indunID, index)
    if index == 2 then
        return string.format("{ol}{#FFFFFF}{s16}(%d/%d)",
            GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", indunID).PlayPerResetType),
            GET_INDUN_MAX_ENTERANCE_COUNT(GetClassByType("Indun", indunID).PlayPerResetType))
    elseif index == 1 then
        return string.format("{ol}{#FFFFFF}{s16}(%d)",
            GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", indunID).PlayPerResetType))
    end
end

function indun_panel_create_frame_onsweep(frame, key, subKey, subValue, y, x)

    -- 695 メレジナ -- 688 スロガ -- 685 ウピ
    local raidTable = {
        [707] = {11210024, 11210023, 11210022},
        [710] = {11210028, 11210027, 11210026},
        [695] = {11200356, 11200355, 11200354},
        [688] = {11200290, 10820036, 11200289, 11200288},
        [685] = {11200281, 10820035, 11200280, 11200279}
    }

    -- session.ResetItemList()
    local invItemList = session.GetInvItemList()
    local guidList = invItemList:GetGuidList()
    local cnt = guidList:Count()

    if raidTable[subValue] then

        local use = frame:CreateOrGetControl('button', key .. "use", x + 480, y, 80, 30)
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
        local text = g.lang and string.format("{ol}{img %s 25 25 } %d個持っています。", icon, count) or
                         string.format("{ol}{img %s 25 25 } Quantity in Inventory", icon, count)

        use:SetTextTooltip(text)
        use:SetEventScript(ui.LBUTTONUP, "indun_panel_raid_itemuse")
        use:SetEventScriptArgNumber(ui.LBUTTONUP, subValue)
    end

    local solo = frame:CreateOrGetControl('button', key .. "solo", x, y, 80, 30)
    local auto = frame:CreateOrGetControl('button', key .. "auto", x + 85, y, 80, 30)
    local count = frame:CreateOrGetControl("richtext", key .. "count", x + 170, y + 5, 50, 30)
    local hard = frame:CreateOrGetControl('button', key .. "hard", x + 215, y, 80, 30)
    local counthard = frame:CreateOrGetControl("richtext", key .. "counthard", x + 300, y + 5, 50, 30)
    local sweep = frame:CreateOrGetControl('button', key .. "sweep", x + 355, y, 80, 30)
    local sweepcount = frame:CreateOrGetControl("richtext", key .. "sweepcount", x + 440, y + 5, 50, 30)

    solo:SetText("{ol}SOLO")
    auto:SetText("{ol}{#FFD900}AUTO")
    hard:SetText("{ol}{#FF0000}HARD")
    sweep:SetText("{ol}{#00FF00}" .. "ACLEAR")

    if subKey == "s" then
        count:SetText(indun_panel_GetEntranceCountText(subValue, 2))
        solo:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_solo")
        solo:SetEventScriptArgNumber(ui.LBUTTONUP, subValue)
    elseif subKey == "a" then
        auto:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_auto")
        auto:SetEventScriptArgNumber(ui.LBUTTONUP, subValue)
        sweep:SetEventScript(ui.LBUTTONUP, "indun_panel_autosweep")
        sweep:SetEventScriptArgNumber(ui.LBUTTONUP, subValue)
    elseif subKey == "h" then
        counthard:SetText(indun_panel_GetEntranceCountText(subValue, 2))
        hard:SetEventScript(ui.LBUTTONDOWN, "indun_panel_enter_hard")
        hard:SetEventScriptArgNumber(ui.LBUTTONDOWN, subValue)
        hard:SetEventScriptArgString(ui.LBUTTONDOWN, "false")
    elseif subKey == "ac" then

        sweepcount:SetText("{ol}{#FFFFFF}{s16}(" .. indun_panel_sweep_count(subValue) .. ")")
    end
end

function indun_panel_enter_solo(frame, ctrl, str, induntype)

    ReqRaidAutoUIOpen(induntype)
    ReqMoveToIndun(1, 0)
end

function indun_panel_enter_auto(frame, ctrl, str, induntype)
    ReqRaidAutoUIOpen(induntype)
    -- local topFrame = ui.GetFrame("indunenter")
    -- local useCount = tonumber(topFrame:GetUserValue("multipleCount"));
    -- local indunType = topFrame:GetUserValue('INDUN_TYPE');
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

function indun_panel_enter_hard(frame, ctrl, str, induntype)

    local indunCls = GetClassByType("Indun", induntype)
    if str == "false" then
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

function indun_panel_raid_itemuse(frame, ctrl, argStr, induntype)

    local raidTable = {
        [707] = {11210024, 11210023, 11210022},
        [710] = {11210028, 11210027, 11210026},
        [695] = {11200356, 11200355, 11200354},
        [688] = {11200290, 10820036, 11200289, 11200288},
        [685] = {11200281, 10820035, 11200280, 11200279}
    }
    local buffIDs = {
        [707] = 80035, -- ネリンガ
        [710] = 80037, -- ゴーレム
        [685] = 80030, -- 蝶々
        [688] = 80031, -- スロガ
        [695] = 80032 -- メレジ
    }
    session.ResetItemList()
    local invItemList = session.GetInvItemList()
    local guidList = invItemList:GetGuidList()
    local cnt = guidList:Count()
    local targetItems = raidTable[induntype]
    local enter_count = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", induntype).PlayPerResetType)
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
    ui.SysMsg(INDUN_PANEL_LANG("There are no ticket items in inventory."))
end

function indun_panel_autosweep(frame, ctrl, argStr, induntype)

    local buffIDs = {
        [707] = 80035, -- ネリンガ
        [710] = 80037, -- ゴーレム
        [673] = 80016, -- スプレッダー
        [676] = 80017, -- ファロウス
        [679] = 80015, -- ロゼ
        [685] = 80030, -- 蝶々
        [688] = 80031, -- スロガ
        [695] = 80032 -- メレジ
    }
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

function indun_panel_create_frame(frame, key, subKey, subValue, y)

    local solo = frame:CreateOrGetControl('button', key .. "solo", 135, y, 80, 30)
    local auto = frame:CreateOrGetControl('button', key .. "auto", 220, y, 80, 30)
    local hard = frame:CreateOrGetControl('button', key .. "hard", 350, y, 80, 30)
    local count = frame:CreateOrGetControl("richtext", key .. "count", 305, y + 5, 50, 30)
    local counthard = frame:CreateOrGetControl("richtext", key .. "counthard", 435, y + 5, 50, 30)

    solo:SetText("{ol}SOLO")
    auto:SetText(key == "earring" and "{ol}{#FFD900}NORMAL" or "{ol}{#FFD900}AUTO")
    hard:SetText("{ol}{#FF0000}HARD")

    if subKey == "s" then
        if key == "earring" then
            count:SetText(indun_panel_GetEntranceCountText(subValue, 1))
            solo:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_solo")
            solo:SetEventScriptArgNumber(ui.LBUTTONUP, subValue)
        else
            count:SetText(indun_panel_GetEntranceCountText(subValue, 2))
            solo:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_solo")
            solo:SetEventScriptArgNumber(ui.LBUTTONUP, subValue)
        end
    elseif subKey == "a" then
        auto:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_auto")
        auto:SetEventScriptArgNumber(ui.LBUTTONUP, subValue)

    elseif subKey == "h" then
        if key == "giltine" then
            counthard:SetText(indun_panel_GetEntranceCountText(subValue, 1))
            hard:SetEventScript(ui.LBUTTONDOWN, "indun_panel_enter_hard")
            hard:SetEventScriptArgNumber(ui.LBUTTONDOWN, subValue)
            hard:SetEventScriptArgString(ui.LBUTTONDOWN, "false")
        elseif key == "earring" then
            hard:SetEventScript(ui.LBUTTONDOWN, "indun_panel_enter_hard")
            hard:SetEventScriptArgNumber(ui.LBUTTONDOWN, subValue)
            hard:SetEventScriptArgString(ui.LBUTTONDOWN, "false")
        else
            counthard:SetText(indun_panel_GetEntranceCountText(subValue, 2))
            hard:SetEventScript(ui.LBUTTONDOWN, "indun_panel_enter_hard")
            hard:SetEventScriptArgNumber(ui.LBUTTONDOWN, subValue)
            hard:SetEventScriptArgString(ui.LBUTTONDOWN, "false")
        end
    end

end

function indun_panel_enter_challenge_solo(frame, ctrl, str, indunType)
    ReqChallengeAutoUIOpen(indunType)
    ReqMoveToIndun(1, 0)
end

function indun_panel_challenge_frame(frame, key, y)

    local cha_460 = frame:CreateOrGetControl('button', 'cha_460', 135, y, 80, 30)
    cha_460:SetText("{ol}500")
    cha_460:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_challenge_solo")
    cha_460:SetEventScriptArgNumber(ui.LBUTTONUP, 1000)

    local cha_480 = frame:CreateOrGetControl('button', 'cha_480', 220, y, 80, 30)
    cha_480:SetText("{ol}520")
    cha_480:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_challenge_solo")
    cha_480:SetEventScriptArgNumber(ui.LBUTTONUP, 1001)

    local cha_pt = frame:CreateOrGetControl('button', 'cha_pt', 305, y, 80, 30)
    cha_pt:SetText("{ol}{#FFD900}PT")
    cha_pt:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_challenge_pt")
    cha_pt:SetEventScriptArgNumber(ui.LBUTTONUP, 1002)

    local cha_count = frame:CreateOrGetControl("richtext", "cha_count", 390, y + 5, 40, 30)
    cha_count:SetText(indun_panel_GetEntranceCountText(1002, 2))

    local cha_ticket = frame:CreateOrGetControl('button', 'cha_ticket', 435, y, 80, 30)
    cha_ticket:SetText("{ol}{#EE7800}{s14}BUYUSE")
    cha_ticket:SetTextTooltip("{ol}" ..
                                  INDUN_PANEL_LANG(
            "priority{nl}1.Tickets due within 24 hours{nl}2.Tickets with expiration date{nl}" ..
                "3.Event tickets with no expiration date{nl}4.{img icon_item_Tos_Event_Coin 20 20} tickets (buy and use){nl}" ..
                "5.{img pvpmine_shop_btn_total 20 20} tickets (buy and use))"))
    cha_ticket:SetEventScript(ui.LBUTTONUP, "indun_panel_item_use")
    cha_ticket:SetEventScriptArgNumber(ui.LBUTTONUP, 1000)

    local cha_ticketcount = frame:CreateOrGetControl("richtext", "cha_ticketcount", 520, y + 5, 40, 30)

    cha_ticketcount:SetText("{ol}{#FFFFFF}{s16}({img pvpmine_shop_btn_total 20 20}" ..
                                INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_40") ..
                                " {img icon_item_Tos_Event_Coin 20 20}" ..
                                INDUN_PANEL_GET_RECIPE_TRADE_COUNT("EVENT_TOS_WHOLE_SHOP_315") .. ")")

end

function indun_panel_singularity_frame(frame, key, y)

    local sin_n = frame:CreateOrGetControl('button', 'sin_n', 135, y, 80, 30)
    sin_n:SetText("{ol}{#FFD900}520")
    sin_n:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_challenge_pt")
    sin_n:SetEventScriptArgNumber(ui.LBUTTONUP, 2000)

    --[[local sin_ex = frame:CreateOrGetControl('button', 'sin_ex', 220, y, 80, 30)
    sin_ex:SetText("{ol}{#FF0000}EX")
    sin_ex:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_challenge_pt")
    sin_ex:SetEventScriptArgNumber(ui.LBUTTONUP, 691)]]

    local sin_count = frame:CreateOrGetControl("richtext", "sin_count", 220, y + 5, 30, 30)
    sin_count:SetText(indun_panel_GetEntranceCountText(2000, 1))

    local sin_ticket = frame:CreateOrGetControl('button', 'sin_ticket', 250, y, 80, 30)
    sin_ticket:SetText("{ol}{#EE7800}{s14}BUYUSE")
    sin_ticket:SetTextTooltip("{ol}" ..
                                  INDUN_PANEL_LANG(
            "priority{nl}1.Tickets due within 24 hours{nl}2.Tickets with expiration date{nl}" ..
                "3.{img pvpmine_shop_btn_total 20 20} tickets (buy and use){nl}4.{img icon_item_Tos_Event_Coin 20 20} tickets (buy and use))"))
    sin_ticket:SetEventScript(ui.LBUTTONUP, "indun_panel_item_use")
    sin_ticket:SetEventScriptArgNumber(ui.LBUTTONUP, 2000)

    local sin_ticketcount = frame:CreateOrGetControl("richtext", "sin_ticketcount", 335, y + 5, 40, 30)
    sin_ticketcount:SetText("{ol}{#FFFFFF}{s16}({img pvpmine_shop_btn_total 20 20}d:" ..
                                INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_41") .. " w:" ..
                                INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_42") ..
                                " {img icon_item_Tos_Event_Coin 20 20}" ..
                                INDUN_PANEL_GET_RECIPE_TRADE_COUNT("EVENT_TOS_WHOLE_SHOP_314") .. ")")

    local sin_check = frame:CreateOrGetControl("checkbox", "singularity_check", 475, y, 25, 25)
    AUTO_CAST(sin_check)
    sin_check:SetEventScript(ui.LBUTTONUP, "indun_panel_ischecked")
    sin_check:SetTextTooltip(g.lang == "Japanese" and
                                 "{ol}チェックをすると自動マッチングボタンを押しません。" or
                                 "{ol}If checked, the automatic matching button will not be pressed.")
    sin_check:SetCheck(g.settings.singularity_check)

end

function indun_panel_enter_challenge_pt(frame, ctrl, str, indunType)

    ReqChallengeAutoUIOpen(indunType)
    local indunCls = GetClassByType('Indun', indunType);
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

function indun_panel_INDUN_ALREADY_PLAYING()
    ReserveScript("indun_panel_INDUN_ALREADY_PLAYING_dilay()", 0.3)
end

function indun_panel_INDUN_ALREADY_PLAYING_dilay()

    local topFrame = ui.GetFrame("indunenter")
    local indunType = tostring(topFrame:GetUserValue('INDUN_TYPE'));
    if indunType == "646" or indunType == "647" or indunType == "691" then
        -- 646＝チャレPT 647＝分裂普通　691＝分裂EX
        indunType = tonumber(indunType)
        AnsGiveUpPrevPlayingIndun(1)
        ui.CloseFrame("indunenter")
        ReserveScript(string.format("indun_panel_enter_challenge_pt('%s','%s','%s', %d)", topFrame, _, _, indunType),
            0.5)
        return
    else
        local yesScp = string.format("AnsGiveUpPrevPlayingIndun(%d)", 1);
        local noScp = string.format("AnsGiveUpPrevPlayingIndun(%d)", 0);
        ui.MsgBox(ClMsg("IndunAlreadyPlaying_AreYouGiveUp"), yesScp, noScp);
    end
end

function indun_panel_cemetery_frame(frame, key, y)

    local btn_490 = frame:CreateOrGetControl('button', 'btn_490', 135, y, 80, 30)
    btn_490:SetText("{ol}490")
    btn_490:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_solo")
    btn_490:SetEventScriptArgNumber(ui.LBUTTONUP, 684)
    local count_490 = frame:CreateOrGetControl("richtext", "count_490", 220, y + 5)
    count_490:SetText(indun_panel_GetEntranceCountText(684, 1))

    --[[local btn_500 = frame:CreateOrGetControl('button', 'btn_500', 250, y, 80, 30)
    btn_500:SetText("{ol}500")
    btn_500:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_solo")
    btn_500:SetEventScriptArgNumber(ui.LBUTTONUP, 693)
    local count_500 = frame:CreateOrGetControl("richtext", "count_500", 335, y + 5)
    count_500:SetText(indun_panel_GetEntranceCountText(693, 1))]]
end

function indun_panel_season_enter(frame, ctrl, argStr, argNum)
    ReqChallengeAutoUIOpen(argNum)
end

function indun_panel_season_frame(frame, key, subKey, subValue, y, x)

    local season = frame:CreateOrGetControl('button', "button" .. subValue, (subKey - 1) * 90 + 135, y, 50, 30)
    season:SetText("{ol}" .. subKey)
    season:SetEventScript(ui.LBUTTONUP, "indun_panel_season_enter")
    season:SetEventScriptArgNumber(ui.LBUTTONUP, subValue)

    local count = frame:CreateOrGetControl("richtext", "count" .. subValue, (subKey - 1) * 90 + 190, y + 5, 50, 30)
    count:SetText(indun_panel_GetEntranceCountText(subValue, 1))
end

function indun_panel_telharsha_frame(frame, key, y)

    local telbtn = frame:CreateOrGetControl('button', 'telbtn', 135, y, 80, 30)
    telbtn:SetText("{ol}IN")
    telbtn:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_solo")
    telbtn:SetEventScriptArgNumber(ui.LBUTTONUP, 623)

    local telcnt = frame:CreateOrGetControl("richtext", "telcnt", 220, y + 5)
    telcnt:SetText(indun_panel_GetEntranceCountText(623, 2))
end

function indun_panel_overbuy_amount(recipename)
    local aObj = GetMyAccountObj()
    local recipecls = GetClass('ItemTradeShop', recipename)
    local overbuy_count = TryGetProp(aObj, TryGetProp(recipecls, 'OverBuyProperty', 'None'), 0)
    if INDUN_PANEL_GET_RECIPE_TRADE_COUNT(recipename) == 1 and overbuy_count == 0 then
        return 1000
    elseif overbuy_count >= 0 then
        return overbuy_count * 50 + 1050
    end
    return 0
end

function indun_panel_overbuy_count(recipename)
    local aObj = GetMyAccountObj()
    local recipecls = GetClass('ItemTradeShop', recipename)
    local overbuy_max = TryGetProp(recipecls, 'MaxOverBuyCount', 0)
    local overbuy_prop = TryGetProp(recipecls, 'OverBuyProperty', 'None')
    local overbuy_count = TryGetProp(aObj, overbuy_prop, 0)
    return tonumber(overbuy_max) - tonumber(overbuy_count)
end

function indun_panel_buyuse_vel(frame, ctrl, recipename, indunType)

    local count = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", indunType).PlayPerResetType)
    local trade_count = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", indunType).PlayPerResetType)

    local vel_oneday_ticket = 11030169 -- Ticket_Bernice_Enter_1d

    if count == 1 then
        session.ResetItemList()
        local invItemList = session.GetInvItemList()
        local guidList = invItemList:GetGuidList()
        local cnt = guidList:Count()

        for i = 0, cnt - 1 do

            local use_item = session.GetInvItemByType(vel_oneday_ticket)
            if use_item ~= nil then
                INV_ICON_USE(use_item)
                return
            end
        end

    elseif count == 1 and trade_count == 1 then
        INDUN_PANEL_ITEM_BUY_USE(recipename)
    elseif count == 1 and trade_count == 0 then
        local vel_recipecls = GetClass('ItemTradeShop', recipename)
        local vel_overbuy_max = TryGetProp(vel_recipecls, 'MaxOverBuyCount', 0)

        if vel_overbuy_max >= 1 then
            INDUN_PANEL_ITEM_BUY_USE(recipename)
            return
        else
            ui.SysMsg(g.lang == "Japanese" and "トレード回数が足りません。" or "No trade count.")
            return
        end
    end
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
        end
    end
    ReqMoveToIndun(1, 0)
end

function indun_panel_velnice_frame(frame, y)

    local velbtn = frame:CreateOrGetControl('button', 'velbtn', 135, y, 80, 30)
    velbtn:SetText("{ol}IN")
    velbtn:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_velnice_solo")

    local velcnt = frame:CreateOrGetControl("richtext", "velcnt", 220, y + 5, 50, 30)
    velcnt:SetText(indun_panel_GetEntranceCountText(201, 2))

    local velrecipename = "PVP_MINE_52"
    local velchangecnt = INDUN_PANEL_GET_RECIPE_TRADE_COUNT(velrecipename)
    if velchangecnt < 0 then
        velchangecnt = 0
    end

    local velbuyuse = frame:CreateOrGetControl('button', 'velbuyuse', 265, y, 80, 30)
    AUTO_CAST(velbuyuse)
    velbuyuse:SetText("{ol}{#EE7800}{s14}BUYUSE")
    velbuyuse:SetEventScript(ui.LBUTTONUP, "indun_panel_buyuse_vel")
    velbuyuse:SetEventScriptArgString(ui.LBUTTONUP, velrecipename)
    velbuyuse:SetEventScriptArgNumber(ui.LBUTTONUP, 201)

    local velchangetxt = frame:CreateOrGetControl("richtext", "velchangetxt", 350, y + 5, 60, 30)
    velchangetxt:SetText(string.format("{ol}{#FFFFFF}(%d/%d)", velchangecnt, indun_panel_overbuy_count(velrecipename)))

    local velamount = frame:CreateOrGetControl("richtext", "velamount", 415, y + 5, 50, 30)
    local velamount_text = "{ol}{#FFFFFF}(" .. "{img pvpmine_shop_btn_total 20 20}"
    if tonumber(velchangecnt) == 1 then
        velamount_text = velamount_text .. "1,000)"
    else
        velamount_text = velamount_text ..
                             string.format("{ol}{#FF0000}%s",
                GET_COMMAED_STRING(indun_panel_overbuy_amount(velrecipename))) .. "{ol}{#FFFFFF})"
    end
    velamount:SetText(velamount_text)

end

function indun_panel_jsr_frame(frame, key, y)

    local jsrbtn = frame:CreateOrGetControl('button', 'jsrbtn', 135, y, 80, 30)
    jsrbtn:SetText("{ol}JSR")
    jsrbtn:SetEventScript(ui.LBUTTONUP, "FIELD_BOSS_JOIN_ENTER_CLICK")
    jsrbtn:SetUserValue("Y", y)
    indun_panel_FIELD_BOSS_ENTER_TIMER_SETTING(frame)
    jsrbtn:RunUpdateScript("indun_panel_FIELD_BOSS_ENTER_TIMER_SETTING", 1.0)

end

function indun_panel_FIELD_BOSS_ENTER_TIMER_SETTING(frame)

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
    local jsrbtn = GET_CHILD_RECURSIVELY(frame, "jsrbtn")
    local y = jsrbtn:GetUserIValue("Y")
    local jsrtime = frame:CreateOrGetControl("richtext", "jsrtime", 220, y + 5, 10, 10)
    jsrtime:SetText("{ol}" .. textstr)
    return 1
end

function indun_panel_buyuse(recipeName)
    INDUN_PANEL_ITEM_BUY_USE(recipeName)
end
-- print(INDUN_PANEL_GET_RECIPE_TRADE_COUNT("EVENT_TOS_WHOLE_SHOP_314"))
function indun_panel_item_use_sin(indun_type, enterance_count)

    session.ResetItemList()
    local invItemList = session.GetInvItemList()
    local guidList = invItemList:GetGuidList()
    local cnt = guidList:Count()

    local first_use = nil
    local second_use = nil
    local third_use = nil

    for i = 0, cnt - 1 do
        local itemobj = GetIES(invItemList:GetItemByGuid(guidList:Get(i)):GetObject())
        local classid = tonumber(itemobj.ClassID)
        local life_time = tonumber(GET_REMAIN_ITEM_LIFE_TIME(itemobj))
        local use_item = session.GetInvItemByType(classid)

        -- 優先順位に従って使用するアイテムを設定
        if enterance_count == 0 then
            if classid == 10820018 and life_time ~= nil and life_time < 86400 then
                first_use = use_item -- 最優先: 10820018かつ寿命が24時間未満
            elseif classid == 11030067 then
                second_use = use_item -- 次優先: 11030067
            elseif classid == 10820018 then
                third_use = use_item -- 最後の優先: 10820018
            end
        end
    end

    -- 優先順位に基づいてアイテムを使用
    if first_use then
        INV_ICON_USE(first_use)
        return
    elseif second_use then
        INV_ICON_USE(second_use)
        return
    elseif third_use then
        INV_ICON_USE(third_use)
        return
    end

    local dcount = INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_41")
    if dcount == 1 and enterance_count == 0 then
        indun_panel_buyuse("PVP_MINE_41")
        return
    end

    local wcount = INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_42")
    if wcount >= 1 and enterance_count == 0 then
        indun_panel_buyuse("PVP_MINE_42")
        return
    end

    local mcount = INDUN_PANEL_GET_RECIPE_TRADE_COUNT("EVENT_TOS_WHOLE_SHOP_314")
    if mcount >= 1 and enterance_count == 0 then
        indun_panel_buyuse("EVENT_TOS_WHOLE_SHOP_314")
        return
    end

    local targetItems = {}
    -- アイテムの収集
    for i = 0, cnt - 1 do
        local itemobj = GetIES(invItemList:GetItemByGuid(guidList:Get(i)):GetObject())
        local classid = itemobj.ClassID

        if enterance_count == 0 and (classid == 10000470 or classid == 11030021 or classid == 11030017) then
            table.insert(targetItems, classid)
        end
    end

    -- 収集したアイテムの処理
    for _, classid in ipairs(targetItems) do
        local msg = g.lang == "Japanese" and "期限はありません。使用しますか？" or
                        "It has no expiration date.{nl}Do you want to use it?"
        local yesscp = string.format("indun_panel_INV_ICON_USE(%d)", classid)
        local msgbox = ui.MsgBox(msg, yesscp, '')
    end
end

function indun_panel_INV_ICON_USE(classid)
    INV_ICON_USE(session.GetInvItemByType(tonumber(classid)))

end

function indun_panel_item_use_cha(indun_type, enterance_count)

    session.ResetItemList()
    local invItemList = session.GetInvItemList()
    local guidList = invItemList:GetGuidList()
    local cnt = guidList:Count()

    local first_use = nil
    local second_use = nil
    local third_use = nil
    local fourth_use = nil
    local fifth_use = nil
    local six_use = nil

    for i = 0, cnt - 1 do
        local itemobj = GetIES(invItemList:GetItemByGuid(guidList:Get(i)):GetObject())
        local classid = tonumber(itemobj.ClassID)
        local life_time = tonumber(GET_REMAIN_ITEM_LIFE_TIME(itemobj))
        local use_item = session.GetInvItemByType(classid)

        -- 優先順位のチェック
        if enterance_count == 1 then
            if classid == 10820019 and life_time ~= nil and life_time < 86400 then
                first_use = use_item -- 優先度1: 10820019 (24時間未満)
            elseif classid == 11030080 and life_time ~= nil and life_time < 86400 then
                second_use = use_item -- 優先度2: 11030080 (24時間未満)
            elseif classid == 11030080 then
                third_use = use_item -- 優先度3: 11030080
            elseif classid == 641954 then
                fourth_use = use_item -- 優先度4: 641954
            elseif classid == 10820019 then
                fifth_use = use_item -- 優先度5: 10820019
            elseif classid == 10000073 then
                six_use = use_item -- 優先度6: 10000073
            end
        end
    end

    -- 優先順位に基づいてアイテムを使用
    if first_use then
        INV_ICON_USE(first_use)
        return
    elseif second_use then
        INV_ICON_USE(second_use)
        return
    elseif third_use then
        INV_ICON_USE(third_use)
        return
    elseif fourth_use then
        INV_ICON_USE(fourth_use)
        return
    elseif fifth_use then
        INV_ICON_USE(fifth_use)
        return
    elseif six_use then
        INV_ICON_USE(six_use)
        return
    end

    local event_trade_count = INDUN_PANEL_GET_RECIPE_TRADE_COUNT("EVENT_TOS_WHOLE_SHOP_315")
    if event_trade_count >= 1 and enterance_count == 1 then
        indun_panel_buyuse("EVENT_TOS_WHOLE_SHOP_315")
        return
    else
        local trade_count = INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_40")
        if trade_count >= 1 and enterance_count == 1 then
            indun_panel_buyuse("PVP_MINE_40")
            return
        end
    end

end

function indun_panel_item_use(frame, ctrl, argStr, indun_type)

    local enterance_count = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", indun_type).PlayPerResetType)

    if indun_type == 2000 then
        indun_panel_item_use_sin(indun_type, enterance_count)
    elseif indun_type == 1000 then
        indun_panel_item_use_cha(indun_type, enterance_count)
    end
end

function INDUN_PANEL_ITEM_BUY_USE(recipeName)
    local recipeCls = GetClass("ItemTradeShop", recipeName)
    session.ResetItemList()
    session.AddItemID(tostring(0), 1)
    local itemlist = session.GetItemIDList()
    local cntText = string.format("%s %s", tostring(recipeCls.ClassID), tostring(1))
    if string.find(recipeName, "EVENT_TOS") then
        item.DialogTransaction("EVENT_TOS_WHOLE_SHOP", itemlist, cntText)
    else
        item.DialogTransaction("PVP_MINE_SHOP", itemlist, cntText)
    end
    local itemCls = GetClass("Item", recipeCls.TargetItem)
    ReserveScript(string.format("INV_ICON_USE(session.GetInvItemByType(%d));", itemCls.ClassID), 1)
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

g.ex = 0 -- 関数の外に定義
function INDUN_PANEL_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame
    g.framename = addonName
    g.lang = option.GetCurrentCountry()

    indun_panel_load_settings()
    local pc = GetMyPCObject();
    local curMap = GetZoneName(pc)
    local mapCls = GetClass("Map", curMap)
    if mapCls.MapType == "City" then
        local frame = ui.GetFrame("indun_panel")
        frame:RemoveAllChild()

        if g.settings.checkbox == 1 then
            indun_panel_frame_init()
            indun_panel_init(frame)
        else
            indun_panel_frame_init()
        end
        if g.ex == 0 and INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_41") == 0 then
            addon:RegisterMsg('GAME_START', "indunpanel_minimized_pvpmine_shop_init")
            -- indunpanel_minimized_pvpmine_shop_init()
        end
        g.SetupHook(indun_panel_INDUN_ALREADY_PLAYING, "INDUN_ALREADY_PLAYING")
    else
        indun_panel_autozoom_init()
    end

    if _G.ADDONS.norisan.AUTOMAPCHANGE ~= nil then
        acutil.setupHook(indun_panel_autozoom, "AUTOMAPCHANGE_CAMERA_ZOOM")
    end
    addon:RegisterMsg('GAME_START', "indun_panel_autozoom")
end

function indun_panel_save_settings()
    acutil.saveJSON(g.settingsFileLoc, g.settings);
end

function indun_panel_load_settings()

    local settings, err = acutil.loadJSON(g.settingsFileLoc, g.settings)
    if err then
        -- 設定ファイル読み込み失敗時処理
        -- CHAT_SYSTEM(string.format("[%s] cannot load setting files", addonNameLower))
    end
    if not settings then
        g.settings = {
            checkbox = 0,
            zoom = 336,
            challenge_checkbox = 1,
            singularity_checkbox = 1,
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
            season_checkbox = 1
        }
        settings = g.settings
        indun_panel_save_settings()
    end

    g.settings = settings
end

function INDUN_PANEL_LANG(str)

    if g.settings.en_ver == 1 then
        if str == tostring("cemetery") then
            str = "wailing"
        end
        return "{s20}" .. str
    end
    local langcode = option.GetCurrentCountry()

    if langcode == "Japanese" then
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
        if str == tostring("jsr") then
            str = "ボス協同戦"
        end
        if str == tostring("season") then
            str = "シーズンチャレンジ"
        end
        if str == tostring("priority{nl}1.Tickets due within 24 hours{nl}2.Tickets with expiration date{nl}" ..
                               "3.{img pvpmine_shop_btn_total 20 20} tickets (buy and use){nl}4.{img icon_item_Tos_Event_Coin 20 20} tickets (buy and use))") then
            str = "優先順位{nl}1.24時間以内の期限付きチケット{nl}2.期限付きチケット{nl}" ..
                      "3.{img pvpmine_shop_btn_total 20 20}チケット(買って使います){nl}4.{img icon_item_Tos_Event_Coin 20 20}チケット(買って使います)"
        end
        if str == tostring("priority{nl}1.Tickets due within 24 hours{nl}2.Tickets with expiration date{nl}" ..
                               "3.Event tickets with no expiration date{nl}4.{img icon_item_Tos_Event_Coin 20 20} tickets (buy and use){nl}" ..
                               "5.{img pvpmine_shop_btn_total 20 20} tickets (buy and use))") then
            str = "優先順位{nl}1.24時間以内の期限付きチケット{nl}2.期限付きチケット{nl}" ..
                      "3.期限のないイベントチケット{nl}4.{img icon_item_Tos_Event_Coin 20 20}チケット(買って使います){nl}" ..
                      "5.{img pvpmine_shop_btn_total 20 20}チケット(買って使います){nl}{img pvpmine_shop_btn_total 20 20}このチケットで分裂券作れるで!"
        end
        -- "There are no ticket items in inventory."
        if str == tostring("There are no ticket items in inventory.") then
            str = "(自動マッチング/1人)入場券を持っていません。"
        end
        return "{s16}" .. str
    end

    return "{s20}" .. str
end
--[[function indun_panel_frame_update(frame)
    local frame = ui.GetFrame("indun_panel")
    local raid_table = {
        neringa = {707, 80035},
        golem = {710, 80037},
        merregina = {695, 80032},
        slogutis = {688, 80031},
        upinis = {685, 80030},
        roze = {679, 80015},
        falouros = {676, 80017},
        spreader = {673, 80016}
    }

    for key, value in pairs(raid_table) do

        local count = GET_CHILD_RECURSIVELY(frame, key .. "count")
        if count ~= nil then
            local sweep_count = GET_CHILD_RECURSIVELY(frame, key .. "sweepcount")

            for _, v in pairs(value) do

                if string.len(v) == 3 then

                    count:SetText(indun_panel_GetEntranceCountText(v, 2))

                    local raidTable = {
                        [707] = {11210024, 11210023, 11210022},
                        [710] = {11210028, 11210027, 11210026},
                        [695] = {11200356, 11200355, 11200354},
                        [688] = {11200290, 10820036, 11200289, 11200288},
                        [685] = {11200281, 10820035, 11200280, 11200279}
                    }
                    -- アイテム製造中にインベいじったらバグるので
                    -- session.ResetItemList()
                    local invItemList = session.GetInvItemList()
                    local guidList = invItemList:GetGuidList()
                    local cnt = guidList:Count()

                    if raidTable[v] then

                        local use = GET_CHILD_RECURSIVELY(frame, key .. "use")
                        local item_count = 0
                        for _, targetClassID in pairs(raidTable[v]) do
                            for i = 0, cnt - 1 do

                                local itemobj = GetIES(invItemList:GetItemByGuid(guidList:Get(i)):GetObject())
                                local invItem = invItemList:GetItemByGuid(guidList:Get(i))
                                if itemobj.ClassID == targetClassID then
                                    item_count = item_count + invItem.count
                                end
                            end
                        end

                        local itemClass = GetClassByType('Item', raidTable[v][2])

                        local icon = itemClass.Icon
                        local text = g.lang and
                                         string.format("{ol}{img %s 25 25 } %d個持っています。", icon,
                                item_count) or
                                         string.format("{ol}{img %s 25 25 } Quantity in Inventory", icon, item_count)

                        use:SetTextTooltip(text)

                    end
                else

                    sweep_count:SetText("{ol}{#FFFFFF}{s16}(" .. indun_panel_sweep_count(v) .. ")")
                end

            end
        end

    end

    local cha_count = GET_CHILD_RECURSIVELY(frame, "cha_count")
    if cha_count ~= nil then
        cha_count:SetText(indun_panel_GetEntranceCountText(646, 2))
        local cha_ticketcount = GET_CHILD_RECURSIVELY(frame, "cha_ticketcount")
        cha_ticketcount:SetText("{ol}{#FFFFFF}{s16}({img pvpmine_shop_btn_total 20 20}" ..
                                    INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_40") ..
                                    " {img icon_item_Tos_Event_Coin 20 20}" ..
                                    INDUN_PANEL_GET_RECIPE_TRADE_COUNT("EVENT_TOS_WHOLE_SHOP_315") .. ")")
    end

    local sin_count = GET_CHILD_RECURSIVELY(frame, "sin_count")
    if sin_count ~= nil then
        sin_count:SetText(indun_panel_GetEntranceCountText(647, 1))
        local sin_ticketcount = GET_CHILD_RECURSIVELY(frame, "sin_ticketcount")
        sin_ticketcount:SetText("{ol}{#FFFFFF}{s16}({img pvpmine_shop_btn_total 20 20}d:" ..
                                    INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_41") .. " w:" ..
                                    INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_42") ..
                                    " {img icon_item_Tos_Event_Coin 20 20}" ..
                                    INDUN_PANEL_GET_RECIPE_TRADE_COUNT("EVENT_TOS_WHOLE_SHOP_314") .. ")")
    end

    local velrecipename = "PVP_MINE_52"
    local velchangecnt = INDUN_PANEL_GET_RECIPE_TRADE_COUNT(velrecipename)
    if velchangecnt < 0 then
        velchangecnt = 0
    end
    local velchangetxt = GET_CHILD_RECURSIVELY(frame, "velchangetxt")
    if velchangetxt ~= nil then
        velchangetxt:SetText(string.format("{ol}{#FFFFFF}(%d/%d)", velchangecnt,
            indun_panel_overbuy_count(velrecipename)))
        local velamount = GET_CHILD_RECURSIVELY(frame, "velamount")
        local velamount_text = "{ol}{#FFFFFF}(" .. "{img pvpmine_shop_btn_total 20 20}"
        if tonumber(velchangecnt) == 1 then
            velamount_text = velamount_text .. "1,000)"
        else
            velamount_text = velamount_text ..
                                 string.format("{ol}{#FF0000}%s",
                    GET_COMMAED_STRING(indun_panel_overbuy_amount(velrecipename))) .. "{ol}{#FFFFFF})"
        end
        velamount:SetText(velamount_text)
    end

    return 1

end]]
--[[function INDUN_PANEL_GET_MAX_RECIPE_TRADE_COUNT(recipeName)
    local recipeCls = GetClass("ItemTradeShop", recipeName)
    local accountCls = GetClassByType("Account", 1)
    if recipeCls.NeedProperty ~= "None" and recipeCls.NeedProperty ~= "" then
        local sCount = TryGetProp(accountCls, recipeCls.NeedProperty)
        if sCount then
            return sCount
        end
    end
    if recipeCls.AccountNeedProperty ~= "None" and recipeCls.AccountNeedProperty ~= "" then
        local sCount = TryGetProp(accountCls, recipeCls.AccountNeedProperty)
        if sCount then
            return sCount
        end
    end
    return nil
end]]

--[[function indun_panel_item_use_cha(induntype, count)
    session.ResetItemList()
    local invItemList = session.GetInvItemList()
    local guidList = invItemList:GetGuidList()
    local cnt = guidList:Count()

    for i = 0, cnt - 1 do
        local itemobj = GetIES(invItemList:GetItemByGuid(guidList:Get(i)):GetObject())
        local classid = itemobj.ClassID
        local life_time = GET_REMAIN_ITEM_LIFE_TIME(itemobj)
        -- 11030080 フィールド狩りで落ちるヤツ。ライフタイム縛りやめる？

        if life_time ~= nil then
            if classid == 10820019 and count == 1 and tonumber(life_time) < 86400 then
                INV_ICON_USE(session.GetInvItemByType(tonumber(classid)))
                return
            elseif classid == 11030080 and count == 1 and tonumber(life_time) < 86400 then
                INV_ICON_USE(session.GetInvItemByType(tonumber(classid)))
                return
            elseif classid == 11030080 and count == 1 then
                INV_ICON_USE(session.GetInvItemByType(tonumber(classid)))
                return
            elseif classid == 641954 and count == 1 then
                INV_ICON_USE(session.GetInvItemByType(tonumber(classid)))
                return
            elseif classid == 10820019 and count == 1 then
                INV_ICON_USE(session.GetInvItemByType(tonumber(classid)))
                return
            end
        end
        if classid == 10000073 and count == 1 then
            INV_ICON_USE(session.GetInvItemByType(tonumber(classid)))
            return
        end
    end

    local event_trade_count = INDUN_PANEL_GET_RECIPE_TRADE_COUNT("EVENT_TOS_WHOLE_SHOP_28")
    if event_trade_count >= 1 and count == 1 then
        indun_panel_buyuse("EVENT_TOS_WHOLE_SHOP_28")
        return
    end

    local trade_count = INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_40")
    if trade_count >= 1 and count == 1 then
        indun_panel_buyuse("PVP_MINE_40")
        return
    end
end]]
