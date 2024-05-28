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
local addonName = "indun_panel"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.3.5"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

g.settingsFileLoc = string.format('../addons/%s/new_settings.json', addonNameLower)

--[[function indun_panel_get_indunid()
    -- 新ダンジョン追加時に重宝。セッティングボタン右クリでも良さそう。
    -- ダンジョンフレームの新ダンジョンを選択して実行すれば調べられる。なんかボタンにセットして使おう
    local frame = ui.GetFrame("induninfo")
    local redButton = GET_CHILD_RECURSIVELY(frame, 'RedButton')
    local indun_classid = redButton:GetUserValue('MOVE_INDUN_CLASSID')
    print(indun_classid)
end]]

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

g.ex = 0 -- 関数の外に定義
function INDUN_PANEL_LANG(str)

    if g.settings.en_ver == 1 then
        if str == tostring("cemetery") then
            str = "wailing"
        end
        return "{s20}" .. str
    end
    local langcode = option.GetCurrentCountry()

    if langcode == "Japanese" then
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
        if str == "Auto Zoom Setting{nl}" ..
            "Input a value from 0 to 700. Standard is 336. Zoom to the input value when switching maps.{nl}" ..
            "Disable function by inputting 0." then
            str = "自動ズーム設定{nl}" ..
                      "1～700の値で入力。標準は336。マップ切り替え時に入力の値までZoomします。0入力で機能無効化。"
        end
        if str == "Invalid value please set between 1 and 700" then
            str = "無効な値です。1から700の間で設定してください。"
        end

        if str == "Auto zoom is set. " then
            str = "オートズームを設定しました。"
        end

        -- "Auto zoom is set. "
        --[["Auto Zoom Setting{nl}" ..
                         "1～700の値で入力。標準は336。マップ切り替え時に入力の値までZoomします。0入力で機能無効化。{nl}" ..
                         "Input a value from 0 to 700. Standard is 336. Zoom to the input value when switching maps.{nl}" ..
                         "Disable function by inputting 0."]]

        -- "Invalid value please set between 1 and 700{nl}無効な値です。1から700の間で設定してください。"
        return "{s16}" .. str
    end

    --[[local LangCode = config.GetServiceNation()
    if LangCode == "TAIWAN" then

        if str == tostring("challenge") then
            str = "挑戰"
        end
        if str == tostring("singularity") then
            str = "分裂"
        end
        if str == tostring("slogutis") then
            str = "深淵的觀察者"
        end
        if str == tostring("upinis") then
            str = "夢幻森林"
        end
        if str == tostring("roze") then
            str = "救贖的香爐"
        end
        if str == tostring("falouros") then
            str = "帕盧烏羅斯"
        end
        if str == tostring("spreader") then
            str = "變質的傳播者"
        end
        if str == tostring("jellyzele") then
            str = "沉没的海盜船"
        end
        if str == tostring("delmore") then
            str = "德慕爾激戰地"
        end
        if str == tostring("telharsha") then
            str = "泰哈爾沙"
        end
        if str == tostring("velnice") then
            str = "貝勒尼凱"
        end
        if str == tostring("giltine") then
            str = "魔神的聖所"
        end
        if str == tostring("earring") then
            str = "煙火的記憶"
        end
        if str == tostring("cemetery") then
            str = "痛哭墓地"
        end
        if str == tostring("ACLEAR") then
            str = "掃蕩"
        end
        return "{s20}" .. str
    end]]

    return "{s20}" .. str
end

function INDUN_PANEL_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame
    g.framename = addonName

    indun_panel_load_settings()
    local pc = GetMyPCObject();
    local curMap = GetZoneName(pc)
    local mapCls = GetClass("Map", curMap)
    if mapCls.MapType == "City" then
        local frame = ui.GetFrame("indun_panel")
        frame:RemoveAllChild()
        if g.settings.jsr_checkbox == 1 then
            addon:RegisterMsg('GAME_START_3SEC', "indun_panel_FIELD_BOSS_TIME_TAB_SETTING")
        end
        if g.settings.checkbox == 1 then
            indun_panel_frame_init()
            indun_panel_init(frame)
        else
            indun_panel_frame_init()
        end
        if g.ex == 0 and INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_41") == 0 then
            g.ex = 1
            indunpanel_minimized_pvpmine_shop_init()
        end
        g.SetupHook(indun_panel_INDUN_ALREADY_PLAYING, "INDUN_ALREADY_PLAYING")
    else
        indun_panel_autozoom_init()
    end

    if _G.ADDONS.norisan.AUTOMAPCHANGE ~= nil then
        acutil.setupHook(indun_panel_autozoom, "AUTOMAPCHANGE_CAMERA_ZOOM")
        addon:RegisterMsg('GAME_START', "indun_panel_autozoom")
    end
    addon:RegisterMsg('GAME_START', "indun_panel_autozoom")
end

function indun_panel_autozoom_init()

    local frame = ui.GetFrame(g.framename)

    frame:SetSkinName('None')
    frame:SetLayerLevel(30)
    frame:Resize(140, 40)
    frame:SetPos(1640, 0)
    frame:SetTitleBarSkin("None")
    frame:EnableHittestFrame(1)
    frame:EnableHide(0)
    frame:EnableHitTest(1)
    frame:RemoveAllChild()

    local zoom = frame:CreateOrGetControl('edit', 'zoom', 80, 0, 60, 30)
    AUTO_CAST(zoom)
    zoom:SetText("{ol}" .. g.settings.zoom)
    zoom:SetFontName("white_16_ol")
    zoom:SetTextAlign("center", "center")
    zoom:SetEventScript(ui.ENTERKEY, "indun_panel_autozoom_save")
    zoom:SetTextTooltip(INDUN_PANEL_LANG("Auto Zoom Setting{nl}" ..
                                             "Input a value from 0 to 700. Standard is 336. Zoom to the input value when switching maps.{nl}"))
    frame:ShowWindow(1)

end

-- 画面上の小さいボタンとCCボタンを配置
function indun_panel_frame_init()

    local frame = ui.GetFrame(g.framename)
    frame:SetSkinName('None')
    frame:SetLayerLevel(30)
    frame:Resize(140, 40)
    frame:SetPos(665, 30)
    frame:SetTitleBarSkin("None")
    frame:EnableHittestFrame(1)
    frame:EnableHide(0)
    frame:EnableHitTest(1)

    frame:RemoveAllChild()

    local open = frame:CreateOrGetControl("button", "indun_panel_open", 5, 5, 80, 30)
    AUTO_CAST(open)
    open:SetText("{ol}{s11}INDUNPANEL")
    open:SetEventScript(ui.LBUTTONUP, "indun_panel_init")

    local cc = frame:CreateOrGetControl('button', 'cc', 90, 5, 30, 35)
    AUTO_CAST(cc)
    cc:SetSkinName("None")
    cc:SetText("{img barrack_button_normal 30 30}")
    cc:SetEventScript(ui.LBUTTONUP, "APPS_TRY_MOVE_BARRACK")

    frame:ShowWindow(1)
    frame:RunUpdateScript("indun_panel_time_update", 300)
end

-- オートズーム機能の数字監視
function indun_panel_autozoom_save(frame, ctrl)

    local inputValue = tonumber(ctrl:GetText())

    if inputValue == 0 then
        g.settings.zoom = 0
        indun_panel_save_settings()
        return
    end

    if inputValue < 1 or inputValue > 700 then
        ui.SysMsg(INDUN_PANEL_LANG("Invalid value please set between 1 and 700"))

        local zoomEditControl = GET_CHILD_RECURSIVELY(frame, "zoom")
        zoomEditControl:SetText("336")
        frame:Invalidate()

        g.settings.zoom = 336
        indun_panel_save_settings()

        ReserveScript("indun_panel_autozoom()", 1.0)
        return
    end

    if inputValue ~= g.settings.zoom then
        ui.SysMsg(INDUN_PANEL_LANG("Auto zoom is set. " .. inputValue))
        g.settings.zoom = inputValue
        indun_panel_save_settings()

        ReserveScript("indun_panel_autozoom()", 1.0)
        return
    end

end

function indun_panel_ischecked(frame, ctrl, argStr, argNum)

    local ctrlname = ctrl:GetName()
    local ischeck = ctrl:IsChecked()

    if g.settings[ctrlname] ~= nil then
        g.settings[ctrlname] = ischeck
        indun_panel_save_settings()
    end
end

function indun_panel_event_tos_whole_shop_open()

    local frame = ui.GetFrame("earthtowershop");
    frame:SetUserValue("SHOP_TYPE", 'EVENT_TOS_WHOLE_SHOP');
    ui.OpenFrame('earthtowershop');

end

function indun_panel_FIELD_BOSS_TIME_TAB_SETTING()
    local frame = ui.GetFrame("induninfo")
    local ctrlSet = GET_CHILD_RECURSIVELY(frame, "field_boss_ranking_control")
    local subTab = GET_CHILD_RECURSIVELY(ctrlSet, "sub_tab")

    local currentTime = os.time()
    local today = os.date("*t", currentTime)

    -- 今日の12時5分
    local noonTime = os.time({
        year = today.year,
        month = today.month,
        day = today.day,
        hour = 12,
        min = 5,
        sec = 0
    })

    -- 今日の22時5分
    local nightTime = os.time({
        year = today.year,
        month = today.month,
        day = today.day,
        hour = 22,
        min = 5,
        sec = 0
    })

    -- 時間に応じてタブを選択
    if (noonTime - currentTime) > 0 then
        subTab:SelectTab(0)
    else
        subTab:SelectTab(1)
    end
end

function indun_panel_FIELD_BOSS_ENTER_TIMER_SETTING(ctrlSet)
    if ctrlSet == nil then
        return
    end

    local frame = ctrlSet:GetTopParentFrame()
    if frame == nil then
        return
    end

    local gauge = GET_CHILD_RECURSIVELY(ctrlSet, "gauge")
    if gauge == nil then
        return
    end

    local currentTime = os.time()
    local today = os.date("*t", currentTime)

    -- 今日の12時5分
    local noonTime = os.time({
        year = today.year,
        month = today.month,
        day = today.day,
        hour = 12,
        min = 5,
        sec = 0
    })

    -- 今日の22時5分
    local nightTime = os.time({
        year = today.year,
        month = today.month,
        day = today.day,
        hour = 22,
        min = 5,
        sec = 0
    })

    local diff = 0
    local diffTime = 0
    local isAM = false
    local isPM = false

    if (noonTime - currentTime) > 0 then
        isAM = true
        diff = noonTime - currentTime
        diffTime = noonTime
    else
        isPM = true
        diff = nightTime - currentTime
        diffTime = nightTime
    end

    local textStr = ""
    local battleInfoTimeText = GET_CHILD_RECURSIVELY(ctrlSet, "battle_info_time_text")

    if diff < 0 and isPM then
        if g.settings.en_ver == 1 then
            textStr = "NotAddmittableDay"
        else
            textStr = ClMsg("NotAddmittableDay")
        end
    elseif diff - 300 > 0 then
        if g.settings.en_ver == 1 then
            textStr = GET_TIME_TXT_NO_LANG(diff - 300) .. " After Start"
        else
            textStr = GET_TIME_TXT(diff - 300) .. " " .. ClMsg("After_Start")
        end
    elseif diffTime > 0 then
        if g.settings.en_ver == 1 then
            textStr = GET_TIME_TXT_NO_LANG(diffTime - currentTime) .. " After Exit"
        else
            textStr = GET_TIME_TXT(diffTime - currentTime) .. " " .. ClMsg("After_Exit")
        end
    elseif diffTime < 0 then
        if g.settings.en_ver == 1 then
            textStr = "Already Exit"
        else
            textStr = ClMsg("Already_Exit")
        end
    end

    battleInfoTimeText:SetTextByKey("value", textStr)

    return textStr
end

local induntype = {
    [1] = {
        challenge = {
            s460 = 644,
            s480 = 645,
            pt = 646
        }
    },
    [2] = {
        singularity = {
            normal = 647,
            ex = 691
        }
    },
    [3] = {
        season = {
            [1] = 699, -- radaseasonchallenge 699~703
            [2] = 700,
            [3] = 701,
            [4] = 702,
            [5] = 703
        }
    },
    [4] = {
        merregina = {
            s = 696,
            a = 695,
            h = 697,
            ac = 80032
        }
    },
    [5] = {
        slogutis = {
            s = 689,
            a = 688,
            h = 690,
            ac = 80031
        }
    },
    [6] = {
        upinis = {
            s = 686,
            a = 685,
            h = 687,
            ac = 80030
        }
    },
    [7] = {
        roze = {
            s = 680,
            a = 679,
            h = 681,
            ac = 80015
        }
    },
    [8] = {
        falouros = {
            s = 677,
            a = 676,
            h = 678,
            ac = 80017
        }
    },
    [9] = {
        spreader = {
            s = 674,
            a = 673,
            h = 675,
            ac = 80016
        }
    },
    [10] = {
        jellyzele = {
            s = 672,
            a = 671,
            h = 670
        }
    },
    [11] = {
        delmore = {
            s = 667,
            a = 666,
            h = 665
        }
    },
    [12] = {
        telharsha = 623
    },
    [13] = {
        velnice = 201
    },
    [14] = {
        giltine = {
            s = 669,
            a = 635,
            h = 628
        }
    },
    [15] = {
        earring = {
            s = 661,
            a = 662,
            h = 663
        }
    },
    [16] = {
        cemetery = {
            c490 = 684,
            c500 = 693
        }
    },

    [17] = {
        jsr = 0
    }
}

-- パネル展開
function indun_panel_init(frame)
    frame:RemoveAllChild()

    local open = frame:CreateOrGetControl("button", "open", 5, 5, 80, 30)
    AUTO_CAST(open)
    open:SetText("{ol}{s11}INDUNPANEL")
    open:SetEventScript(ui.LBUTTONUP, "indun_panel_frame_init")

    local function create_control(frame, type, name, x, y, width, height, skin, text, event, tooltip)
        local control = frame:CreateOrGetControl(type, name, x, y, width, height)
        AUTO_CAST(control)
        control:SetSkinName(skin)
        control:SetText(text)
        control:SetEventScript(ui.LBUTTONUP, event)
        control:SetTextTooltip(tooltip)
    end

    create_control(frame, "button", "cc", 90, 5, 30, 35, "None", "{img barrack_button_normal 30 30}",
                   "APPS_TRY_MOVE_BARRACK", "バラックに戻ります。{nl}Return to Barracks.")
    create_control(frame, "button", "shop", 155, 10, 25, 25, "None", "{img icon_item_Tos_Event_Coin 23 23}",
                   "indun_panel_event_tos_whole_shop_open", "TOSイベントショップ{nl}TOS Event Shop")
    create_control(frame, "button", "config", 120, 5, 30, 35, "None", "{img config_button_normal 30 30}",
                   "indun_panel_config_gb_open", "レイド表示設定{nl}Raid Display Settings")

    local checkbox = frame:CreateOrGetControl('checkbox', 'checkbox', 665, 5, 30, 30)
    AUTO_CAST(checkbox)
    checkbox:SetCheck(g.settings.checkbox)
    checkbox:SetEventScript(ui.LBUTTONUP, "indun_panel_ischecked")
    checkbox:SetTextTooltip("チェックすると常時展開{nl}IsCheck AlwaysOpen")

    local badgeText = frame:CreateOrGetControl("richtext", "badge_text", 520, 10)
    badgeText:SetText("{img pvpmine_shop_btn_total 25 25}")
    badgeText:SetTextTooltip("傭兵団コイン数量 Mercenary Badge count")

    local badgeCount = frame:CreateOrGetControl("richtext", "badge_count", 550, 10)
    badgeCount:SetText(string.format("{ol}{#FFD900}{s20}%s", GET_COMMAED_STRING(indun_panel_pvpmaine_count())))

    local y = 45
    local x = 135

    if g.settings.season_checkbox == nil then
        g.settings.season_checkbox = 1
        indun_panel_save_settings()
    end

    local function create_button(frame, name, x, y, width, height, text, event, argNum, tooltip)
        local button = frame:CreateOrGetControl('button', name, x, y, width, height)
        AUTO_CAST(button)
        button:SetText(text)
        button:SetEventScript(ui.LBUTTONUP, event)
        button:SetEventScriptArgNumber(ui.LBUTTONUP, argNum)
        if tooltip then
            button:SetTextTooltip(tooltip)
        end
        return button
    end

    local function create_text(frame, name, x, y, text)
        local richtext = frame:CreateOrGetControl("richtext", name, x, y, 50, 30)
        richtext:SetText(text)
        return richtext
    end

    local function indun_panel_cemetery_frame(frame, key, y, x)
        create_button(frame, 'cem_button_490', x, y, 80, 30, "{ol}490", "indun_panel_enter_solo", 684)
        create_text(frame, 'cem_count_490', x + 85, y + 5, string.format("{ol}{#FFFFFF}{s16}(%d)",
                                                                         GET_CURRENT_ENTERANCE_COUNT(
                                                                             GetClassByType("Indun", 684).PlayPerResetType)))

        create_button(frame, 'cem_button_500', x + 115, y, 80, 30, "{ol}500", "indun_panel_enter_solo", 693)
        create_text(frame, 'cem_count_500', x + 200, y + 5, string.format("{ol}{#FFFFFF}{s16}(%d)",
                                                                          GET_CURRENT_ENTERANCE_COUNT(
                                                                              GetClassByType("Indun", 693).PlayPerResetType)))
    end

    local function indun_panel_singularity_frame(frame, key, y, x)
        create_button(frame, 'sin_normal', x, y, 80, 30, "{ol}{#FFD900}AUTO", "indun_panel_enter_challenge_pt", 647)
        create_button(frame, 'sin_ex', x + 85, y, 80, 30, "{ol}{#FF0000}EX", "indun_panel_enter_challenge_pt", 691)
        create_text(frame, 'sin_normal_count', x + 170, y + 5, string.format("{ol}{#FFFFFF}{s16}(%d)",
                                                                             GET_CURRENT_ENTERANCE_COUNT(
                                                                                 GetClassByType("Indun", 647).PlayPerResetType)))

        create_button(frame, 'sin_ticket', x + 200, y, 80, 30, "{ol}{#EE7800}{s14}BUYUSE", "indun_panel_item_use", 647,
                      "{ol}" .. INDUN_PANEL_LANG(
                          "priority{nl}1.Tickets due within 24 hours{nl}2.Tickets with expiration date{nl}3.{img pvpmine_shop_btn_total 20 20} tickets (buy and use){nl}4.{img icon_item_Tos_Event_Coin 20 20} tickets (buy and use))"))
        create_text(frame, 'sin_ticket_count', x + 285, y + 5,
                    string.format(
                        "{ol}{#FFFFFF}{s16}({img pvpmine_shop_btn_total 20 20}d:%d w:%d {img icon_item_Tos_Event_Coin 20 20}%d)",
                        INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_41"),
                        INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_42"),
                        INDUN_PANEL_GET_RECIPE_TRADE_COUNT("EVENT_TOS_WHOLE_SHOP_27")))

        local sin_check = frame:CreateOrGetControl("checkbox", "singularity_check", x + 425, y, 25, 25)
        AUTO_CAST(sin_check)
        sin_check:SetEventScript(ui.LBUTTONUP, "indun_panel_ischecked")
        sin_check:SetTextTooltip(
            "{ol}{チェックをすると自動マッチングボタンを押しません。{nl}}If checked, the automatic matching button will not be pressed.")
        sin_check:SetCheck(g.settings.singularity_check)
    end

    local function indun_panel_challenge_frame(frame, key, y, x)
        create_button(frame, 'cha_460', x, y, 80, 30, "{ol}480", "indun_panel_enter_challenge_solo", 644)
        create_button(frame, 'cha_480', x + 85, y, 80, 30, "{ol}500", "indun_panel_enter_challenge_solo", 645)
        create_button(frame, 'cha_pt', x + 170, y, 80, 30, "{ol}{#FFD900}PT", "indun_panel_enter_challenge_pt", 646)
        create_text(frame, 'cha_count', x + 255, y + 5,
                    string.format("{ol}{#FFFFFF}{s16}(%d/%d)",
                                  GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 646).PlayPerResetType),
                                  GET_INDUN_MAX_ENTERANCE_COUNT(GetClassByType("Indun", 646).PlayPerResetType)))

        create_button(frame, 'cha_ticket', x + 300, y, 80, 30, "{ol}{#EE7800}{s14}BUYUSE", "indun_panel_item_use", 644,
                      "{ol}" .. INDUN_PANEL_LANG(
                          "priority{nl}1.Tickets due within 24 hours{nl}2.Tickets with expiration date{nl}3.Event tickets with no expiration date{nl}4.{img icon_item_Tos_Event_Coin 20 20} tickets (buy and use){nl}5.{img pvpmine_shop_btn_total 20 20} tickets (buy and use))"))
        create_text(frame, 'cha_ticket_count', x + 385, y + 5,
                    string.format(
                        "{ol}{#FFFFFF}{s16}({img pvpmine_shop_btn_total 20 20}%d {img icon_item_Tos_Event_Coin 20 20}%d)",
                        INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_40"),
                        INDUN_PANEL_GET_RECIPE_TRADE_COUNT("EVENT_TOS_WHOLE_SHOP_28")))
    end

    local function create_indun_panel(frame, key, value, y, x)
        if type(value) == "table" then
            for subKey, subValue in pairs(value) do
                if key == "slogutis" or key == "upinis" or key == "roze" or key == "falouros" or key == "spreader" or
                    key == "merregina" then
                    indun_panel_create_frame_onsweep(frame, key, subKey, subValue, y, x)
                elseif key == "jellyzele" or key == "delmore" or key == "giltine" or key == "earring" then
                    indun_panel_create_frame(frame, key, subKey, subValue, y, x)
                elseif key == "challenge" then
                    indun_panel_challenge_frame(frame, key, y, x)
                elseif key == "singularity" then
                    indun_panel_singularity_frame(frame, key, y, x)
                elseif key == "cemetery" then
                    indun_panel_cemetery_frame(frame, key, y, x)
                elseif key == "season" then
                    for subKey, subValue in ipairs(value) do
                        indun_panel_season_frame(frame, key, subKey, subValue, y, x)
                    end
                elseif key == "jsr" then
                    indun_panel_jsr_frame(frame, key, y, x)
                end
            end
        else
            if key == "telharsha" then
                indun_panel_telharsha_frame(frame, key, value, y, x)
            elseif key == "velnice" then
                indun_panel_velnice_frame(frame, key, value, y, x)
            end
        end
    end

    for key, value in pairs(induntype) do
        if g.settings[key .. "_checkbox"] == 1 then
            local indun_text = frame:CreateOrGetControl("richtext", key, x - 125, y + 5)
            indun_text:SetText("{ol}{#FFFFFF}" .. INDUN_PANEL_LANG(key))
            indun_text:AdjustFontSizeByWidth(120)
            create_indun_panel(frame, key, value, y, x)
            y = y + 35
        end
    end

    frame:SetLayerLevel(80)
    frame:Resize(x + 570, y + 5)
    frame:SetSkinName("chat_window_2")
    frame:EnableHitTest(1)
    frame:SetAlpha(100)
    frame:RunUpdateScript("indun_panel_update_frame", 1.0)

    return
end

function indun_panel_create_frame(frame, key, subKey, subValue, y, x)
    local buttons = {
        solo = {
            text = "SOLO",
            x_offset = 0
        },
        auto = {
            text = "{#FFD900}AUTO",
            x_offset = 85
        },
        hard = {
            text = "{#FF0000}HARD",
            x_offset = 215
        }
    }

    local texts = {
        count = {
            x_offset = 170
        },
        counthard = {
            x_offset = 300
        }
    }

    local function set_button_event(button, name, subKey, subValue)
        if name == "solo" and subKey == "s" then
            button:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_solo")
            button:SetEventScriptArgNumber(ui.LBUTTONUP, subValue)
        elseif name == "auto" and subKey == "a" then
            button:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_auto")
            button:SetEventScriptArgNumber(ui.LBUTTONUP, subValue)
        elseif name == "hard" and subKey == "h" then
            button:SetEventScript(ui.LBUTTONDOWN, "indun_panel_enter_hard")
            button:SetEventScriptArgNumber(ui.LBUTTONDOWN, subValue)
            button:SetEventScriptArgString(ui.LBUTTONDOWN, "false")
        end
    end

    local function set_text_value(text, name, subKey, subValue)
        if name == "count" and subKey == "s" then
            text:SetText(string.format("{ol}{#FFFFFF}{s16}(%d/%d)",
                                       GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", subValue).PlayPerResetType),
                                       GET_INDUN_MAX_ENTERANCE_COUNT(GetClassByType("Indun", subValue).PlayPerResetType)))
        elseif name == "counthard" and subKey == "h" then
            text:SetText(string.format("{ol}{#FFFFFF}{s16}(%d/%d)",
                                       GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", subValue).PlayPerResetType),
                                       GET_INDUN_MAX_ENTERANCE_COUNT(GetClassByType("Indun", subValue).PlayPerResetType)))
        end
    end

    for name, params in pairs(buttons) do
        local button = frame:CreateOrGetControl('button', key .. name, x + params.x_offset, y, 80, 30)
        button:SetText(string.format("{ol}%s", params.text))
        set_button_event(button, name, subKey, subValue)
    end

    for name, params in pairs(texts) do
        local text = frame:CreateOrGetControl("richtext", key .. name, x + params.x_offset, y + 5, 50, 30)
        set_text_value(text, name, subKey, subValue)
    end
end

function indun_panel_create_frame_onsweep(frame, key, subKey, subValue, y, x)

    local buttons = {
        solo = {
            text = "SOLO",
            x_offset = 0
        },
        auto = {
            text = "{#FFD900}AUTO",
            x_offset = 85
        },
        hard = {
            text = "{#FF0000}HARD",
            x_offset = 215
        },
        sweep = {
            text = "{#00FF00}ACLEAR",
            x_offset = 355
        }
    }

    local texts = {
        count = {
            x_offset = 170
        },
        counthard = {
            x_offset = 300
        },
        sweepcount = {
            x_offset = 440
        }
    }

    local function set_button_event(button, name, subKey, subValue)
        if name == "solo" and subKey == "s" then
            button:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_solo")
            button:SetEventScriptArgNumber(ui.LBUTTONUP, subValue)
        elseif name == "auto" and subKey == "a" then
            button:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_auto")
            button:SetEventScriptArgNumber(ui.LBUTTONUP, subValue)
        elseif name == "hard" and subKey == "h" then
            button:SetEventScript(ui.LBUTTONDOWN, "indun_panel_enter_hard")
            button:SetEventScriptArgNumber(ui.LBUTTONDOWN, subValue)
            button:SetEventScriptArgString(ui.LBUTTONDOWN, "false")
        elseif name == "sweep" and subKey == "a" then
            button:SetEventScript(ui.LBUTTONUP, "indun_panel_autosweep")
            button:SetEventScriptArgNumber(ui.LBUTTONUP, subValue)
        end
    end

    local function set_text_value(text, name, subKey, subValue)
        if name == "count" and subKey == "s" then
            text:SetText(string.format("{ol}{#FFFFFF}{s16}(%d/%d)",
                                       GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", subValue).PlayPerResetType),
                                       GET_INDUN_MAX_ENTERANCE_COUNT(GetClassByType("Indun", subValue).PlayPerResetType)))
        elseif name == "counthard" and subKey == "h" then
            text:SetText(string.format("{ol}{#FFFFFF}{s16}(%d/%d)",
                                       GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", subValue).PlayPerResetType),
                                       GET_INDUN_MAX_ENTERANCE_COUNT(GetClassByType("Indun", subValue).PlayPerResetType)))
        elseif name == "sweepcount" and subKey == "ac" then
            text:SetText(string.format("{ol}{#FFFFFF}{s16}(%d)", indun_panel_sweep_count(subValue)))
        end
    end

    local function create_use_button(frame, key, subValue, y, x)
        local raidTable = {
            [695] = {11200356, 11200355, 11200354},
            [688] = {11200290, 10820036, 11200289, 11200288},
            [685] = {11200281, 10820035, 11200280, 11200279}
        }
        local use_button = frame:CreateOrGetControl('button', key .. "use", x + 480, y, 80, 30)
        AUTO_CAST(use_button)
        use_button:SetText("{ol}{#EE7800}USE")

        session.ResetItemList()
        local invItemList = session.GetInvItemList()
        local guidList = invItemList:GetGuidList()
        local cnt = guidList:Count()
        local targetItems = raidTable[subValue]
        local count = 0
        if targetItems then
            for _, targetClassID in ipairs(targetItems) do
                for i = 0, cnt - 1 do
                    local itemobj = GetIES(invItemList:GetItemByGuid(guidList:Get(i)):GetObject())
                    local invItem = invItemList:GetItemByGuid(guidList:Get(i))
                    if itemobj.ClassID == targetClassID then
                        count = count + invItem.count
                    end
                end
            end
        end

        local itemClass = GetClassByType('Item', raidTable[subValue][2])
        local icon = itemClass.Icon

        use_button:SetTextTooltip(
            string.format("{ol}{img %s 25 25 } Use it?{nl} Quantity in Inventory(%d)", icon, count))
        use_button:SetEventScript(ui.LBUTTONUP, "indun_panel_raid_itemuse")
        use_button:SetEventScriptArgNumber(ui.LBUTTONUP, subValue)
    end

    for name, params in pairs(buttons) do
        local button = frame:CreateOrGetControl('button', key .. name, x + params.x_offset, y, 80, 30)
        button:SetText(string.format("{ol}%s", params.text))
        set_button_event(button, name, subKey, subValue)
    end

    for name, params in pairs(texts) do
        local text = frame:CreateOrGetControl("richtext", key .. name, x + params.x_offset, y + 5, 50, 30)
        set_text_value(text, name, subKey, subValue)
    end

    if subValue == 695 or subValue == 688 or subValue == 685 then
        create_use_button(frame, key, subValue, y, x)
    end
end

function indun_panel_create_frame_simple(frame, key, value, y, enterEventScript, recipeName)
    local indunClass = GetClassByType("Indun", value)
    local tradeShopClass = nil

    if recipeName then
        tradeShopClass = GetClass('ItemTradeShop', recipeName)
    end

    local btn = frame:CreateOrGetControl('button', key .. "btn", 135, y, 80, 30)
    btn:SetText("{ol}IN")
    btn:SetEventScript(ui.LBUTTONUP, enterEventScript)
    btn:SetEventScriptArgNumber(ui.LBUTTONUP, value)

    local count = frame:CreateOrGetControl("richtext", key .. "count", 220, y + 5, 50, 30)
    count:SetText(string.format("{ol}{#FFFFFF}(%d/%d)", GET_CURRENT_ENTERANCE_COUNT(indunClass.PlayPerResetType),
                                GET_INDUN_MAX_ENTERANCE_COUNT(indunClass.PlayPerResetType)))

    if tradeShopClass then
        local buyUse = frame:CreateOrGetControl('button', key .. 'buyuse', 265, y, 80, 30)
        AUTO_CAST(buyUse)
        buyUse:SetText("{ol}{#EE7800}{s14}BUYUSE")
        buyUse:SetEventScript(ui.LBUTTONUP, "indun_panel_buyuse")
        buyUse:SetEventScriptArgString(ui.LBUTTONUP, recipeName)
        buyUse:SetEventScriptArgNumber(ui.LBUTTONUP, value)

        local exchange = frame:CreateOrGetControl("richtext", key .. "exchange", 350, y + 5, 60, 30)
        local changeCount = INDUN_PANEL_GET_RECIPE_TRADE_COUNT(recipeName)
        if changeCount < 0 then
            changeCount = 0
        end
        exchange:SetText(string.format("{ol}{#FFFFFF}(%d/%d)", changeCount, indun_panel_overbuy_count()))

        local amount = frame:CreateOrGetControl("richtext", key .. "amount", 415, y + 5, 50, 30)
        if tonumber(changeCount) == 1 then
            amount:SetText("{ol}{#FFFFFF}({img pvpmine_shop_btn_total 20 20}1,000)")
        else
            amount:SetText(string.format(
                               "{ol}{#FFFFFF}({img pvpmine_shop_btn_total 20 20}{ol}{#FF0000}%s{ol}{#FFFFFF})",
                               GET_COMMAED_STRING(indun_panel_overbuy_amount())))
        end
    end
end

-- Usage for Velcoffer
function indun_panel_velnice_frame(frame, key, value, y)
    local recipeName = "PVP_MINE_52"
    indun_panel_create_frame_simple(frame, key, value, y, "indun_panel_enter_velnice_solo", recipeName)
end

-- Usage for Telharsha
function indun_panel_telharsha_frame(frame, key, value, y)
    indun_panel_create_frame_simple(frame, key, value, y, "indun_panel_enter_solo", nil)
end

--[[function indun_panel_cemetery_frame(ipframe, key, y)

    local cembutton = ipframe:CreateOrGetControl('button', 'cembutton', 135, y, 80, 30)
    cembutton:SetText("{ol}490")
    cembutton:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_solo")
    cembutton:SetEventScriptArgNumber(ui.LBUTTONUP, 684)
    local cemcount = ipframe:CreateOrGetControl("richtext", "cemcount", 220, y + 5)
    cemcount:SetText(
        "{ol}{#FFFFFF}{s16}(" .. GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 684).PlayPerResetType) .. ")")

    local cembutton_500 = ipframe:CreateOrGetControl('button', 'cembutton_500', 250, y, 80, 30)
    cembutton_500:SetText("{ol}500")
    cembutton_500:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_solo")
    cembutton_500:SetEventScriptArgNumber(ui.LBUTTONUP, 693)
    local cemcount_500 = ipframe:CreateOrGetControl("richtext", "cemcount_500", 335, y + 5)
    cemcount_500:SetText("{ol}{#FFFFFF}{s16}(" ..
                             GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 693).PlayPerResetType) .. ")")
end

function indun_panel_singularity_frame(ipframe, key, y)

    local sin_normal = ipframe:CreateOrGetControl('button', 'sin_normal', 135, y, 80, 30)
    sin_normal:SetText("{ol}{#FFD900}AUTO")

    sin_normal:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_challenge_pt")
    sin_normal:SetEventScriptArgNumber(ui.LBUTTONUP, 647)

    local sin_ex = ipframe:CreateOrGetControl('button', 'sin_ex', 220, y, 80, 30)
    sin_ex:SetText("{ol}{#FF0000}EX")
    sin_ex:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_challenge_pt")
    sin_ex:SetEventScriptArgNumber(ui.LBUTTONUP, 691)

    local sin_normal_count = ipframe:CreateOrGetControl("richtext", "sin_normal_count", 305, y + 5, 30, 30)
    sin_normal_count:SetText("{ol}{#FFFFFF}{s16}(" ..
                                 GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 647).PlayPerResetType) .. "" .. ")")

    local sin_ticket = ipframe:CreateOrGetControl('button', 'sin_ticket', 335, y, 80, 30)
    sin_ticket:SetText("{ol}{#EE7800}{s14}BUYUSE")
    --[[sin_ticket:SetTextTooltip("{ol}" .. INDUN_PANEL_LANG(
        "priority{nl}1.Tickets due within 24 hours{nl}2.Tickets with expiration date{nl}3.{img pvpmine_shop_btn_total 20 20} tickets (buy and use){nl}4.{img icon_item_Tos_Event_Coin 20 20} tickets (buy and use))"))
    sin_ticket:SetTextTooltip("{ol}" ..
                                  INDUN_PANEL_LANG(
                                      "priority{nl}1.Tickets due within 24 hours{nl}2.Tickets with expiration date{nl}" ..
                                          "3.{img pvpmine_shop_btn_total 20 20} tickets (buy and use){nl}4.{img icon_item_Tos_Event_Coin 20 20} tickets (buy and use))"))
    sin_ticket:SetEventScript(ui.LBUTTONUP, "indun_panel_item_use")
    sin_ticket:SetEventScriptArgNumber(ui.LBUTTONUP, 647)

    local sin_ticketcount = ipframe:CreateOrGetControl("richtext", "sin_ticketcount", 420, y + 5, 40, 30)
    --[[sin_ticketcount:SetText("{ol}{#FFFFFF}{s16}(d:" .. INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_41") .. "/w:" ..
                                INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_42") .. "/max:" ..
                                (INDUN_PANEL_GET_MAX_RECIPE_TRADE_COUNT("PVP_MINE_41") +
                                    INDUN_PANEL_GET_MAX_RECIPE_TRADE_COUNT("PVP_MINE_42")) .. ")")
    sin_ticketcount:SetText("{ol}{#FFFFFF}{s16}({img pvpmine_shop_btn_total 20 20}d:" ..
                                INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_41") .. " w:" ..
                                INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_42") ..
                                " {img icon_item_Tos_Event_Coin 20 20}" ..
                                INDUN_PANEL_GET_RECIPE_TRADE_COUNT("EVENT_TOS_WHOLE_SHOP_27") .. ")")

    local sin_check = ipframe:CreateOrGetControl("checkbox", "singularity_check", 560, y, 25, 25)
    AUTO_CAST(sin_check)
    sin_check:SetEventScript(ui.LBUTTONUP, "indun_panel_ischecked")
    sin_check:SetTextTooltip("{ol}{チェックをすると自動マッチングボタンを押しません。{nl}}" ..
                                 "If checked, the automatic matching button will not be pressed.")

    sin_check:SetCheck(g.settings.singularity_check)

end

function indun_panel_challenge_frame(ipframe, key, y)

    local cha460 = ipframe:CreateOrGetControl('button', 'cha460', 135, y, 80, 30)
    cha460:SetText("{ol}480")

    cha460:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_challenge_solo")
    cha460:SetEventScriptArgNumber(ui.LBUTTONUP, 644)

    local cha480 = ipframe:CreateOrGetControl('button', 'cha480', 220, y, 80, 30)
    cha480:SetText("{ol}500")

    cha480:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_challenge_solo")
    cha480:SetEventScriptArgNumber(ui.LBUTTONUP, 645)

    local chapt = ipframe:CreateOrGetControl('button', 'chapt', 305, y, 80, 30)
    chapt:SetText("{ol}{#FFD900}PT")

    chapt:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_challenge_pt")
    chapt:SetEventScriptArgNumber(ui.LBUTTONUP, 646)

    local cha_count = ipframe:CreateOrGetControl("richtext", "cha_count", 390, y + 5, 40, 30)

    cha_count:SetText("{ol}{#FFFFFF}{s16}(" ..
                          GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 646).PlayPerResetType) .. "/" ..
                          GET_INDUN_MAX_ENTERANCE_COUNT(GetClassByType("Indun", 646).PlayPerResetType) .. ")")

    local cha_ticket = ipframe:CreateOrGetControl('button', 'cha_ticket', 435, y, 80, 30)
    cha_ticket:SetText("{ol}{#EE7800}{s14}BUYUSE")
    cha_ticket:SetTextTooltip("{ol}" ..
                                  INDUN_PANEL_LANG(
                                      "priority{nl}1.Tickets due within 24 hours{nl}2.Tickets with expiration date{nl}" ..
                                          "3.Event tickets with no expiration date{nl}4.{img icon_item_Tos_Event_Coin 20 20} tickets (buy and use){nl}" ..
                                          "5.{img pvpmine_shop_btn_total 20 20} tickets (buy and use))"))
    cha_ticket:SetEventScript(ui.LBUTTONUP, "indun_panel_item_use")
    cha_ticket:SetEventScriptArgNumber(ui.LBUTTONUP, 644)

    local cha_ticketcount = ipframe:CreateOrGetControl("richtext", "cha_ticketcount", 520, y + 5, 40, 30)
    cha_ticketcount:SetText("{ol}{#FFFFFF}{s16}({img pvpmine_shop_btn_total 20 20}" ..
                                INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_40") ..
                                " {img icon_item_Tos_Event_Coin 20 20}" ..
                                INDUN_PANEL_GET_RECIPE_TRADE_COUNT("EVENT_TOS_WHOLE_SHOP_28") .. ")")
    --[[cha_ticketcount:SetText("{ol}{#FFFFFF}{s16}({img pvpmine_shop_btn_total 20 20}" ..
                                INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_40") .. "/" ..
                                INDUN_PANEL_GET_MAX_RECIPE_TRADE_COUNT("PVP_MINE_40") .. ")")

end]]

function indun_panel_jsr_frame(frame, key, y)

    local jsr = frame:CreateOrGetControl('button', key .. 'jsr', 135, y, 80, 30)
    jsr:SetText("{ol}JSR")

    jsr:SetEventScript(ui.LBUTTONUP, "FIELD_BOSS_JOIN_ENTER_CLICK")

    local jsrtime_start = frame:CreateOrGetControl("richtext", "jsrtime_start", 220, y + 5)

end

function indun_panel_raid_itemuse_sweep(argNum)
    local buffIDs = {
        [673] = 80016, -- スプレッダー
        [676] = 80017, -- ファロウス
        [679] = 80015, -- ロゼ
        [685] = 80030, -- 蝶々
        [688] = 80031, -- スロガ
        [695] = 80032 -- メレジ
    }

    local buffID = buffIDs[argNum]

    if buffID then
        local sweepcount = indun_panel_sweep_count(buffID)
        if sweepcount >= 1 then
            ReqUseRaidAutoSweep(argNum)
            local ipframe = ui.GetFrame(g.framename)
            indun_panel_init(ipframe)
            return
        else
            local ipframe = ui.GetFrame(g.framename)
            indun_panel_init(ipframe)
            return
        end

    end

end

function indun_panel_season_enter(frame, ctrl, argStr, argNum)
    ReqChallengeAutoUIOpen(argNum)
    -- ReqMoveToIndun(1, 0)
end

function indun_panel_season_frame(frame, key, subKey, subValue, y, x)

    local season = frame:CreateOrGetControl('button', "button" .. subValue, (subKey - 1) * 90 + 135, y, 50, 30)
    season:SetText("{ol}" .. subKey)
    season:SetEventScript(ui.LBUTTONUP, "indun_panel_season_enter")
    season:SetEventScriptArgNumber(ui.LBUTTONUP, subValue)
    local count = frame:CreateOrGetControl("richtext", "count" .. subValue, (subKey - 1) * 90 + 190, y + 5, 50, 30)
    count:SetText("{ol}{#FFFFFF}{s16}(" ..
                      GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", subValue).PlayPerResetType) .. ")")

end

function indun_panel_config_gb_open(frame, ctrl, argStr, argNum)
    local configFrame = ui.GetFrame(g.framename)
    configFrame:SetSkinName("test_frame_low")
    configFrame:SetLayerLevel(90)
    configFrame:Resize(200, 640)
    configFrame:SetPos(665, 30)
    configFrame:EnableHittestFrame(1)
    configFrame:EnableHide(0)
    configFrame:EnableHitTest(1)
    configFrame:SetAlpha(100)
    configFrame:RemoveAllChild()
    configFrame:ShowWindow(1)

    local open = configFrame:CreateOrGetControl("button", "open", 5, 5, 80, 30)
    AUTO_CAST(open)
    open:SetText("{ol}{s11}INDUNPANEL")
    open:SetEventScript(ui.LBUTTONUP, "indun_panel_frame_init")

    local enVer = configFrame:CreateOrGetControl('checkbox', 'enVer', 165, 10, 25, 25)
    AUTO_CAST(enVer)
    if g.settings.en_ver == nil then
        g.settings.en_ver = 0
        indun_panel_save_settings()
    end
    enVer:SetCheck(g.settings.en_ver)
    enVer:SetEventScript(ui.LBUTTONUP, "indun_panel_ischecked")
    enVer:SetTextTooltip(
        "チェックすると英語表示に変更します。{nl}Checking the box changes the display to English.")

    local zoom = configFrame:CreateOrGetControl('edit', 'zoom', 100, 5, 50, 30)
    AUTO_CAST(zoom)
    zoom:SetText("{ol}" .. g.settings.zoom)
    zoom:SetFontName("white_16_ol")
    zoom:SetTextAlign("center", "center")
    zoom:SetEventScript(ui.ENTERKEY, "indun_panel_autozoom_save")
    zoom:SetTextTooltip("Auto Zoom Setting{nl}" ..
                            "1～700の値で入力。標準は336。マップ切り替え時に入力の値までZoomします。0入力で機能無効化。{nl}" ..
                            "Input a value from 0 to 700. Standard is 336. Zoom to the input value when switching maps.{nl}Disable function by inputting 0.")

    local posY = 45
    local count = #induntype
    for i = 1, count do
        local entry = induntype[i]
        for key, value in pairs(entry) do
            local indunText = configFrame:CreateOrGetControl("richtext", key, 15, posY)
            indunText:SetText("{ol}{#FFFFFF}" .. INDUN_PANEL_LANG(key))
            indunText:AdjustFontSizeByWidth(140)

            local checkbox = configFrame:CreateOrGetControl('checkbox', key .. '_checkbox', 165, posY, 25, 25)
            AUTO_CAST(checkbox)
            checkbox:SetCheck(g.settings[key .. '_checkbox'])
            checkbox:SetEventScript(ui.LBUTTONUP, "indun_panel_ischecked")
            checkbox:SetTextTooltip("チェックすると表示{nl}Check to show")

            posY = posY + 35
        end
    end

    configFrame:Resize(200, posY + 5)
end

-- 表示更新
function indun_panel_update_frame(frame)

    local frame = ui.GetFrame(g.framename)
    local configbtn = GET_CHILD_RECURSIVELY(frame, "configbtn")

    if configbtn:IsVisible() == 1 then
        if g.settings.velnice_checkbox == 1 then
            local velcount = GET_CHILD_RECURSIVELY(frame, "velcount")
            velcount:SetText("{ol}{#FFFFFF}(" ..
                                 GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 201).PlayPerResetType) .. "/" ..
                                 GET_INDUN_MAX_ENTERANCE_COUNT(GetClassByType("Indun", 201).PlayPerResetType) .. ")")

            local vrecipecls = GetClass('ItemTradeShop', "PVP_MINE_52");
            local voverbuy_max = TryGetProp(recipecls, 'MaxOverBuyCount', 0)

            local pvpminecount = GET_CHILD_RECURSIVELY(frame, "pvpminecount")
            pvpminecount:SetText(string.format("{ol}{#FFD900}{s20}%s", GET_COMMAED_STRING(indun_panel_pvpmaine_count())))

            local velexchangecount = GET_CHILD_RECURSIVELY(frame, "velexchangecount")
            local vexchangecount = INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_52")
            -- 
            if vexchangecount < 0 then
                vexchangecount = 0
            end
            velexchangecount:SetText(string.format("{ol}{#FFFFFF}(%d", vexchangecount) .. "/" ..
                                         string.format("{ol}{#FFFFFF}%d", indun_panel_overbuy_count()) ..
                                         "{ol}{#FFFFFF})")

            local velamount = GET_CHILD_RECURSIVELY(frame, "velamount")

            if tonumber(vexchangecount) == 1 then
                velamount:SetText("{ol}{#FFFFFF}(" .. "{img pvpmine_shop_btn_total 20 20}" .. "1,000)")

            else
                velamount:SetText("{ol}{#FFFFFF}(" .. "{img pvpmine_shop_btn_total 20 20}" ..
                                      string.format("{ol}{#FF0000}%s", GET_COMMAED_STRING(indun_panel_overbuy_amount())) ..
                                      "{ol}{#FFFFFF})")

            end

        end

        if g.settings.cemetery_checkbox == 1 then
            local cemcount = GET_CHILD_RECURSIVELY(frame, "cemcount")
            cemcount:SetText("{ol}{#FFFFFF}{s16}(" ..
                                 GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 684).PlayPerResetType) .. ")")
            local cemcount_500 = GET_CHILD_RECURSIVELY(frame, "cemcount_500")
            cemcount_500:SetText("{ol}{#FFFFFF}{s16}(" ..
                                     GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 693).PlayPerResetType) .. ")")
        end

        if g.settings.challenge_checkbox == 1 then
            local cha_ticketcount = GET_CHILD_RECURSIVELY(frame, "cha_ticketcount")
            local cha_count = GET_CHILD_RECURSIVELY(frame, "cha_count")

            --[[cha_ticketcount:SetText("{ol}{#FFFFFF}{s16}({img pvpmine_shop_btn_total 20 20}" ..
                                        INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_40") .. "/" ..
                                        INDUN_PANEL_GET_MAX_RECIPE_TRADE_COUNT("PVP_MINE_40") .. ")")]]
            cha_ticketcount:SetText("{ol}{#FFFFFF}{s16}({img pvpmine_shop_btn_total 20 20}" ..
                                        INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_40") ..
                                        " {img icon_item_Tos_Event_Coin 20 20}" ..
                                        INDUN_PANEL_GET_RECIPE_TRADE_COUNT("EVENT_TOS_WHOLE_SHOP_28") .. ")")
            cha_count:SetText("{ol}{#FFFFFF}{s16}(" ..
                                  GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 646).PlayPerResetType) .. "/" ..
                                  GET_INDUN_MAX_ENTERANCE_COUNT(GetClassByType("Indun", 646).PlayPerResetType) .. ")")

        end

        if g.settings.singularity_checkbox == 1 then

            local sin_ticketcount = GET_CHILD_RECURSIVELY(frame, "sin_ticketcount")
            local sin_normal_count = GET_CHILD_RECURSIVELY(frame, "sin_normal_count")
            --[[sin_ticketcount:SetText("{ol}{#FFFFFF}{s16}(d:" .. INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_41") ..
                                        "/w:" .. INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_42") .. ")")]]

            sin_ticketcount:SetText("{ol}{#FFFFFF}{s16}({img pvpmine_shop_btn_total 20 20}d:" ..
                                        INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_41") .. " w:" ..
                                        INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_42") ..
                                        " {img icon_item_Tos_Event_Coin 20 20}" ..
                                        INDUN_PANEL_GET_RECIPE_TRADE_COUNT("EVENT_TOS_WHOLE_SHOP_27") .. ")")
            sin_normal_count:SetText("{ol}{#FFFFFF}{s16}(" ..
                                         GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 647).PlayPerResetType) ..
                                         "" .. ")")

        end

        if g.settings.jsr_checkbox == 1 then
            local jsrframe = ui.GetFrame("induninfo")
            local jsrtime_start = GET_CHILD_RECURSIVELY(frame, "jsrtime_start")
            local msg = indun_panel_FIELD_BOSS_ENTER_TIMER_SETTING(jsrframe)
            jsrtime_start:SetText("")
            jsrtime_start:SetText("{ol}" .. msg)
        end

        local count = #induntype

        for i = 1, count do
            local entry = induntype[i]
            for key, value in pairs(entry) do

                if g.settings[key .. "_checkbox"] == 1 then

                    if type(value) == "table" then
                        if key == "slogutis" or key == "upinis" or key == "roze" or key == "falouros" or key ==
                            "spreader" or key == "merregina" then
                            local sweepcount = GET_CHILD_RECURSIVELY(frame, key .. "sweepcount")
                            local count = GET_CHILD_RECURSIVELY(frame, key .. "count")
                            local counthard = GET_CHILD_RECURSIVELY(frame, key .. "counthard")
                            for subKey, subValue in pairs(value) do
                                if subKey == "ac" then
                                    sweepcount:SetText("{ol}{#FFFFFF}{s16}(" .. indun_panel_sweep_count(subValue) .. ")")

                                elseif subKey == "s" then
                                    count:SetText("{ol}{#FFFFFF}{s16}(" ..
                                                      GET_CURRENT_ENTERANCE_COUNT(
                                                          GetClassByType("Indun", subValue).PlayPerResetType) .. "/" ..
                                                      GET_INDUN_MAX_ENTERANCE_COUNT(
                                                          GetClassByType("Indun", subValue).PlayPerResetType) .. ")")
                                elseif subKey == "h" then
                                    counthard:SetText("{ol}{#FFFFFF}{s16}(" ..
                                                          GET_CURRENT_ENTERANCE_COUNT(
                                                              GetClassByType("Indun", subValue).PlayPerResetType) .. "/" ..
                                                          GET_INDUN_MAX_ENTERANCE_COUNT(
                                                              GetClassByType("Indun", subValue).PlayPerResetType) .. ")")
                                end
                            end
                        elseif key == "season" then
                            for subKey, subValue in pairs(value) do
                                local count = GET_CHILD_RECURSIVELY(frame, "count" .. subValue)
                                count:SetText("{ol}{#FFFFFF}{s16}(" ..
                                                  GET_CURRENT_ENTERANCE_COUNT(
                                                      GetClassByType("Indun", subValue).PlayPerResetType) .. "" .. ")")
                            end
                        elseif key == "jellyzele" or key == "delmore" then

                            local count = GET_CHILD_RECURSIVELY(frame, key .. "count")
                            local counthard = GET_CHILD_RECURSIVELY(frame, key .. "counthard")
                            for subKey, subValue in pairs(value) do

                                if subKey == "s" then
                                    count:SetText("{ol}{#FFFFFF}{s16}(" ..
                                                      GET_CURRENT_ENTERANCE_COUNT(
                                                          GetClassByType("Indun", subValue).PlayPerResetType) .. "/" ..
                                                      GET_INDUN_MAX_ENTERANCE_COUNT(
                                                          GetClassByType("Indun", subValue).PlayPerResetType) .. ")")
                                elseif subKey == "h" then
                                    counthard:SetText("{ol}{#FFFFFF}{s16}(" ..
                                                          GET_CURRENT_ENTERANCE_COUNT(
                                                              GetClassByType("Indun", subValue).PlayPerResetType) .. "/" ..
                                                          GET_INDUN_MAX_ENTERANCE_COUNT(
                                                              GetClassByType("Indun", subValue).PlayPerResetType) .. ")")
                                end
                            end
                        elseif key == "giltine" then

                            local count = GET_CHILD_RECURSIVELY(frame, key .. "count")
                            local counthard = GET_CHILD_RECURSIVELY(frame, key .. "counthard")
                            for subKey, subValue in pairs(value) do

                                if subKey == "s" then
                                    count:SetText("{ol}{#FFFFFF}{s16}(" ..
                                                      GET_CURRENT_ENTERANCE_COUNT(
                                                          GetClassByType("Indun", subValue).PlayPerResetType) .. "/" ..
                                                      GET_INDUN_MAX_ENTERANCE_COUNT(
                                                          GetClassByType("Indun", subValue).PlayPerResetType) .. ")")
                                elseif subKey == "h" then
                                    counthard:SetText("{ol}{#FFFFFF}{s16}(" ..
                                                          GET_CURRENT_ENTERANCE_COUNT(
                                                              GetClassByType("Indun", subValue).PlayPerResetType) .. ")")
                                end
                            end
                        elseif key == "earring" then

                            local count = GET_CHILD_RECURSIVELY(frame, key .. "count")
                            local counthard = GET_CHILD_RECURSIVELY(frame, key .. "counthard")
                            for subKey, subValue in pairs(value) do

                                if subKey == "s" then
                                    count:SetText("{ol}{#FFFFFF}{s16}(" ..
                                                      GET_CURRENT_ENTERANCE_COUNT(
                                                          GetClassByType("Indun", subValue).PlayPerResetType) .. ")")
                                elseif subKey == "h" then
                                    counthard:SetText("{ol}{#FFFFFF}{s16}(" ..
                                                          GET_CURRENT_ENTERANCE_COUNT(
                                                              GetClassByType("Indun", subValue).PlayPerResetType) .. ")")
                                end
                            end

                        end
                    end
                end
            end
        end
        frame:Invalidate()
        return 1
    else
        return 0
    end
end

function indun_panel_raid_itemuse(frame, ctrl, argStr, argNum)
    -- print(argNum)
    local raidTable = {
        [695] = {11200356, 11200355, 11200354},
        [688] = {11200290, 10820036, 11200289, 11200288},
        [685] = {11200281, 10820035, 11200280, 11200279}
    }

    session.ResetItemList()
    local invItemList = session.GetInvItemList()
    local guidList = invItemList:GetGuidList()
    local cnt = guidList:Count()
    local targetItems = raidTable[argNum]

    if targetItems then
        for _, targetClassID in ipairs(targetItems) do
            for i = 0, cnt - 1 do
                local itemobj = GetIES(invItemList:GetItemByGuid(guidList:Get(i)):GetObject())
                local classid = itemobj.ClassID

                if classid == targetClassID then
                    INV_ICON_USE(session.GetInvItemByType(tonumber(classid)))
                    ReserveScript(string.format("indun_panel_raid_itemuse_sweep(%d)", argNum), 0.2)
                    return
                end
            end
        end
    end
    ui.SysMsg(INDUN_PANEL_LANG("There are no ticket items in inventory."))
end

function INDUN_PANEL_SET_BUTTONS_FIND_CLASS(indunCls, subTypeCompare)
    local btnInfoCls = nil;
    if indunCls ~= nil then
        local dungeonType = TryGetProp(indunCls, "DungeonType", "None");
        local subType = TryGetProp(indunCls, "SubType", "None");
        if dungeonType == nil or subType == nil then
            return nil;
        end

        local list, cnt = GetClassList("IndunInfoButton");
        if list ~= nil then
            for i = 0, cnt - 1 do
                local cls = GetClassByIndexFromList(list, i);
                if cls ~= nil then
                    local dungeon_type = TryGetProp(cls, "DungeonType", "None");
                    if dungeon_type == "MoveEnterNPC" and dungeon_type == "Raid_MoveEnterNPC" then
                        dungeon_type = "Raid";
                    end

                    if dungeon_type ~= nil and dungeon_type ~= "None" and
                        (dungeon_type == dungeonType or subType == "MoveEnterNPC" or dungeonType == "GTower") then
                        local sub_type = TryGetProp(cls, "SubType", "None");
                        if sub_type ~= nil and sub_type ~= "None" and sub_type == subType then
                            btnInfoCls = cls;
                            break
                        end
                    end

                    if subTypeCompare == true then
                        local sub_type = TryGetProp(cls, "SubType", "None");
                        if dungeon_type == dungeonType and sub_type == subType then
                            btnInfoCls = cls;
                            break
                        end
                    end
                end
            end
        end
    end
    return btnInfoCls;
end

function INDUN_PANEL_INDUNINFO_SET_BUTTONS(indunType)
    -- print(tostring(indunType))
    local frame = ui.GetFrame("indun_panel")
    local indunCls = GetClassByType('Indun', indunType)
    local dungeonType = TryGetProp(indunCls, "DungeonType", "None")
    local btnInfoCls = GetClassByStrProp("IndunInfoButton", "DungeonType", dungeonType)

    if dungeonType == "Raid" then
        btnInfoCls = INDUNINFO_SET_BUTTONS_FIND_CLASS(indunCls)
    end

    local redButtonScp = TryGetProp(btnInfoCls, "RedButtonScp")

    if redButtonScp ~= 'None' then
        local buttonMap = {
            [665] = "delmorehard",
            [670] = "jellyzelehard",
            [675] = "spreaderhard",
            [678] = "falouroshard",
            [681] = "rozehard",
            [628] = "giltinehard",
            [687] = "upinishard",
            [690] = "slogutishard",
            [663] = "earringhard"
        }

        local buttonName = buttonMap[indunType]

        if buttonName then
            local redButton = GET_CHILD_RECURSIVELY(frame, buttonName)

            if redButton then
                redButton:SetUserValue('MOVE_INDUN_CLASSID', indunCls.ClassID)
                redButton:SetEventScript(ui.LBUTTONUP, redButtonScp)
            end
        end
    end
end

-- ヴェルニケ処理
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

-- チャレンジ関係処理
function indun_panel_enter_challenge_pt(frame, ctrl, argStr, argNum)
    local topFrame = ui.GetFrame("indunenter")

    ReqChallengeAutoUIOpen(argNum)

    local useCount = tonumber(topFrame:GetUserValue("multipleCount"));
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

    if argNum == 646 then
        ReserveScript(string.format("ReqMoveToIndun(%d,%d)", 2, 0), 0.3)
        return
    end
    if g.settings.singularity_check == 0 then
        ReserveScript(string.format("ReqMoveToIndun(%d,%d)", 2, 0), 0.3)
        return
    end

end

function indun_panel_enter_challenge_solo(frame, ctrl, argStr, argNum)

    ReqChallengeAutoUIOpen(argNum)
    ReqMoveToIndun(1, 0)
end

function indun_panel_enter_solo(frame, ctrl, argStr, argNum)

    ReqRaidAutoUIOpen(argNum)
    ReqMoveToIndun(1, 0)
end

function indun_panel_enter_auto(frame, ctrl, argStr, argNum)

    ReqRaidAutoUIOpen(argNum)
    local topFrame = ui.GetFrame("indunenter")
    local useCount = tonumber(topFrame:GetUserValue("multipleCount"));
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

function indun_panel_enter_hard(frame, ctrl, argStr, argNum)

    local indunType = argNum
    local indunCls = GetClassByType("Indun", indunType)

    if argStr == "false" then
        local frame = ui.GetFrame("induninfo")
        INDUN_PANEL_INDUNINFO_SET_BUTTONS(indunType)
        argStr = "true"
        ReserveScript(string.format("indun_panel_enter_hard('%s','%s','%s',%d)", frame, ctrl, argStr, argNum), 0.3)
        return
    else
        ReserveScript(string.format("SHOW_INDUNENTER_DIALOG(%d)", indunType), 0.1)
        return
    end
end

function indun_panel_autosweep(frame, ctrl, argStr, argNum)
    local indun_classid = tonumber(argNum)

    local buffIDs = {
        [673] = 80016, -- スプレッダー
        [676] = 80017, -- ファロウス
        [679] = 80015, -- ロゼ
        [685] = 80030, -- 蝶々
        [688] = 80031, -- スロガ
        [695] = 80032 -- メレジ
    }

    local buffID = buffIDs[indun_classid]

    if buffID then
        local sweepcount = indun_panel_sweep_count(buffID)
        if sweepcount >= 1 then
            ReqUseRaidAutoSweep(indun_classid)
        else
            ui.SysMsg("Does not have a sweeping buff")
        end
    else
        ui.SysMsg("No corresponding buff ID found")
    end
end

function indun_panel_sweep_count(buffid)

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

    local sweepcount = 0

    for i = 0, iconcount - 1 do
        local child = buffslotset:GetChildByIndex(i)
        local icon = child:GetIcon()
        local iconinfo = icon:GetInfo()
        local buff = info.GetBuff(handle, iconinfo.type)

        if tostring(buff.buffID) == tostring(buffid) then

            sweepcount = buff.over

        end

    end

    return sweepcount

end

-- MAP切り替え時オートズーム
function indun_panel_autozoom()
    if g.settings.zoom ~= 0 then
        camera.CustomZoom(tonumber(g.settings.zoom))
    end
end

-- 起動時に当日分裂チケットが0の場合一度だけ作動
function indunpanel_minimized_pvpmine_shop_init()

    pc.ReqExecuteTx_NumArgs("SCR_PVP_MINE_SHOP_OPEN", 0);
    g.ex = 1

    local frame = ui.GetFrame('earthtowershop')
    frame:RunUpdateScript("INDUN_PANEL_EARTHTOWERSHOP_CLOSE_RESTART", 0.5)

end

-- 当日分の分裂チケット更新のため、一度開く必要があるのでAM5時から6時の間で作動
function indun_panel_time_update(frame)

    local time = os.date("*t")
    local hour = time.hour
    local min = time.min

    if hour >= 5 and hour <= 6 and g.ex == 1 then
        pc.ReqExecuteTx_NumArgs("SCR_PVP_MINE_SHOP_OPEN", 0);

        ReserveScript("INDUN_PANEL_EARTHTOWERSHOP_CLOSE_RESTART()", 1.5)
        g.ex = 2

        return 0
    end
    return 1
end

function INDUN_PANEL_EARTHTOWERSHOP_CLOSE_RESTART()
    local shopframe = ui.GetFrame('earthtowershop')
    if shopframe:IsVisible() == 1 then
        ui.CloseFrame("earthtowershop")
        return 0
    else
        return 1
    end
end

function indun_panel_save_settings()

    acutil.saveJSON(g.settingsFileLoc, g.settings);

end

function indun_panel_load_settings()

    local settings, err = acutil.loadJSON(g.settingsFileLoc, g.settings)

    if err then
        -- 設定ファイル読み込み失敗時処理
        CHAT_SYSTEM(string.format("[%s] cannot load setting files", addonNameLower))
    end
    if not settings then
        g.settings = {
            checkbox = 0,
            zoom = 336,
            challenge_checkbox = 1,
            singularity_checkbox = 1,
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

function indun_panel_item_use(frame, ctrl, argStr, argNum)
    session.ResetItemList()
    local invItemList = session.GetInvItemList()
    local guidList = invItemList:GetGuidList()
    local cnt = guidList:Count()

    local count = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", argNum).PlayPerResetType)

    if argNum == 647 then
        indun_panel_handle_indun_647(invItemList, guidList, cnt, count, frame, ctrl, argNum)
    elseif argNum == 644 then
        indun_panel_handle_indun_644(invItemList, guidList, cnt, count, frame, ctrl, argNum)
    end
end

function indun_panel_handle_indun_647(invItemList, guidList, cnt, count, frame, ctrl, argNum)
    for i = 0, cnt - 1 do
        local itemobj = GetIES(invItemList:GetItemByGuid(guidList:Get(i)):GetObject())
        local classid = itemobj.ClassID
        local life_time = GET_REMAIN_ITEM_LIFE_TIME(itemobj)

        if life_time ~= nil then
            if classid == 10820018 and count == 0 and tonumber(life_time) < 86400 then
                INV_ICON_USE(session.GetInvItemByType(tonumber(classid)))
                return
            elseif classid == 11030067 and count == 0 then
                INV_ICON_USE(session.GetInvItemByType(tonumber(classid)))
                return
            elseif classid == 10820018 and count == 0 then
                INV_ICON_USE(session.GetInvItemByType(tonumber(classid)))
                return
            end
        end
    end

    local dcount = INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_41")
    if dcount == 1 and count == 0 then
        indun_panel_buyuse(frame, ctrl, "PVP_MINE_41", argNum)
        return
    end

    local wcount = INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_42")
    if wcount >= 1 and count == 0 then
        g.ex = 1
        indun_panel_buyuse(frame, ctrl, "PVP_MINE_42", argNum)
        return
    end

    local mcount = INDUN_PANEL_GET_RECIPE_TRADE_COUNT("EVENT_TOS_WHOLE_SHOP_28")
    if mcount >= 1 and count == 0 then

        indun_panel_buyuse(frame, ctrl, "EVENT_TOS_WHOLE_SHOP_28", argNum)
        return
    end

    for i = 0, cnt - 1 do
        local itemobj = GetIES(invItemList:GetItemByGuid(guidList:Get(i)):GetObject())
        local classid = itemobj.ClassID

        if classid == 10000470 and count == 0 then
            local msg = "It has no expiration date.{nl}Do you want to use it?"
            local yesscp = string.format("INV_ICON_USE(session.GetInvItemByType(%d))", classid)
            local msgbox = ui.MsgBox(msg, yesscp, '')

            return

        elseif classid == 11030021 and count == 0 then
            local msg = "It has no expiration date.{nl}Do you want to use it?"
            local yesscp = string.format("INV_ICON_USE(session.GetInvItemByType(%d))", classid)
            local msgbox = ui.MsgBox(msg, yesscp, '')

            return
        elseif classid == 11030017 and count == 0 then
            local msg = "It has no expiration date.{nl}Do you want to use it?"
            local yesscp = string.format("INV_ICON_USE(session.GetInvItemByType(%d))", classid)
            local msgbox = ui.MsgBox(msg, yesscp, '')

            return
        end
    end
end

function indun_panel_handle_indun_644(invItemList, guidList, cnt, count, frame, ctrl, argNum)
    for i = 0, cnt - 1 do
        local itemobj = GetIES(invItemList:GetItemByGuid(guidList:Get(i)):GetObject())
        local classid = itemobj.ClassID
        local life_time = GET_REMAIN_ITEM_LIFE_TIME(itemobj)

        if life_time ~= nil then
            if classid == 10820019 and count == 1 and tonumber(life_time) < 86400 then
                INV_ICON_USE(session.GetInvItemByType(tonumber(classid)))
                return
            elseif classid == 11030080 and count == 1 and tonumber(life_time) < 86400 then
                INV_ICON_USE(session.GetInvItemByType(tonumber(classid)))
                return
            elseif classid == 641954 and count == 1 then
                INV_ICON_USE(session.GetInvItemByType(tonumber(classid)))
                return
            elseif classid == 11030080 and count == 1 then
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
        indun_panel_buyuse(frame, ctrl, "EVENT_TOS_WHOLE_SHOP_28", argNum)
        return
    end

    local trade_count = INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_40")
    if trade_count >= 1 and count == 1 then
        indun_panel_buyuse(frame, ctrl, "PVP_MINE_40", argNum)
        return
    end
end

function indun_panel_buyuse(frame, ctrl, recipeName, indunType)
    local count = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", indunType).PlayPerResetType)
    local trade_count = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", indunType).PlayPerResetType)

    if indunType == 201 then
        if count == 1 and trade_count == 1 then
            INDUN_PANEL_ITEM_BUY_USE(recipeName)
        elseif count == 1 and trade_count == 0 then
            local vel_recipecls = GetClass('ItemTradeShop', recipeName)
            local vel_overbuy_max = TryGetProp(vel_recipecls, 'MaxOverBuyCount', 0)

            if vel_overbuy_max >= 1 then
                INDUN_PANEL_ITEM_BUY_USE(recipeName)
                return
            else
                ui.SysMsg("No trade count.")
                return
            end
        end
    elseif indunType == 647 or indunType == 644 then
        INDUN_PANEL_ITEM_BUY_USE(recipeName)
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

function indun_panel_pvpmaine_count()
    local aObj = GetMyAccountObj()
    local coincount = TryGetProp(aObj, "MISC_PVP_MINE2", '0')
    if coincount == 'None' then
        coincount = '0'
    end
    return coincount
end

function indun_panel_overbuy_count()
    local aObj = GetMyAccountObj()
    local recipecls = GetClass('ItemTradeShop', "PVP_MINE_52")
    local overbuy_max = TryGetProp(recipecls, 'MaxOverBuyCount', 0)
    local overbuy_prop = TryGetProp(recipecls, 'OverBuyProperty', 'None')
    local overbuy_count = TryGetProp(aObj, overbuy_prop, 0)
    return tonumber(overbuy_max) - tonumber(overbuy_count)
end

function indun_panel_overbuy_amount()
    local aObj = GetMyAccountObj()
    local recipecls = GetClass('ItemTradeShop', "PVP_MINE_52")
    local overbuy_count = TryGetProp(aObj, TryGetProp(recipecls, 'OverBuyProperty', 'None'), 0)
    if INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_52") == 1 and overbuy_count == 0 then
        return 1000
    elseif overbuy_count >= 0 then
        return overbuy_count * 50 + 1050
    end
    return 0
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

function INDUN_PANEL_GET_MAX_RECIPE_TRADE_COUNT(recipeName)
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
end

--[[function indun_panel_frame_close(ipframe)
    local ipframe = ui.GetFrame(g.framename)

    ipframe:SetSkinName('None')
    ipframe:SetLayerLevel(30)
    ipframe:Resize(140, 40)
    ipframe:SetPos(665, 30)
    ipframe:SetTitleBarSkin("None")
    ipframe:EnableHittestFrame(1)
    ipframe:EnableHide(0)
    ipframe:EnableHitTest(1)
    ipframe:RemoveAllChild()

    local button = ipframe:CreateOrGetControl("button", "indun_panel_open", 5, 5, 80, 30)
    AUTO_CAST(button)
    button:SetText("{ol}{s11}INDUNPANEL")
    button:SetEventScript(ui.LBUTTONUP, "indun_panel_init")

    local ccbtn = ipframe:CreateOrGetControl('button', 'ccbtn', 90, 5, 30, 35)
    AUTO_CAST(ccbtn)
    ccbtn:SetSkinName("None")
    ccbtn:SetText("{img barrack_button_normal 30 30}")
    ccbtn:SetEventScript(ui.LBUTTONUP, "APPS_TRY_MOVE_BARRACK")

    ipframe:ShowWindow(1)
    ipframe:RunUpdateScript("indun_panel_time_update", 300)

end
function indun_panel_item_use(frame, ctrl, argStr, argNum)

    session.ResetItemList()
    local invItemList = session.GetInvItemList()
    local guidList = invItemList:GetGuidList();
    local cnt = guidList:Count();

    local count = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", argNum).PlayPerResetType)

    if argNum == 647 then

        for i = 0, cnt - 1 do
        local itemobj = GetIES(invItemList:GetItemByGuid(guidList:Get(i)):GetObject())
        local classid = itemobj.ClassID
        local life_time = GET_REMAIN_ITEM_LIFE_TIME(itemobj)

        if life_time ~= nil then
            if classid == 10820018 and count == 0 and tonumber(life_time) < 86400 then
                INV_ICON_USE(session.GetInvItemByType(tonumber(classid)))
                return
            elseif classid == 11030067 and count == 0 then
                INV_ICON_USE(session.GetInvItemByType(tonumber(classid)))
                return
            elseif classid == 10820018 and count == 0 then
                INV_ICON_USE(session.GetInvItemByType(tonumber(classid)))
                return
            end
        end
    end

    local dcount = INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_41")
    if dcount == 1 and count == 0 then
        indun_panel_buyuse(frame, ctrl, "PVP_MINE_41", argNum)
        return
    end

    local wcount = INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_42")
    if wcount >= 1 and count == 0 then
        g.ex = 1
        indun_panel_buyuse(frame, ctrl, "PVP_MINE_42", argNum)
        return
    end

    local mcount = INDUN_PANEL_GET_RECIPE_TRADE_COUNT("EVENT_TOS_WHOLE_SHOP_28")
    if mcount >= 1 and count == 0 then

        indun_panel_buyuse(frame, ctrl, "EVENT_TOS_WHOLE_SHOP_28", argNum)
        return
    end

    for i = 0, cnt - 1 do
        local itemobj = GetIES(invItemList:GetItemByGuid(guidList:Get(i)):GetObject())
        local classid = itemobj.ClassID

        if classid == 10000470 and count == 0 then
            local msg = "It has no expiration date.{nl}Do you want to use it?"
            local yesscp = string.format("INV_ICON_USE(session.GetInvItemByType(%d))", classid)
            local msgbox = ui.MsgBox(msg, yesscp, '')

            return

        elseif classid == 11030021 and count == 0 then
            local msg = "It has no expiration date.{nl}Do you want to use it?"
            local yesscp = string.format("INV_ICON_USE(session.GetInvItemByType(%d))", classid)
            local msgbox = ui.MsgBox(msg, yesscp, '')

            return
        elseif classid == 11030017 and count == 0 then
            local msg = "It has no expiration date.{nl}Do you want to use it?"
            local yesscp = string.format("INV_ICON_USE(session.GetInvItemByType(%d))", classid)
            local msgbox = ui.MsgBox(msg, yesscp, '')

            return
        end
    end
    elseif argNum == 644 then

         for i = 0, cnt - 1 do
        local itemobj = GetIES(invItemList:GetItemByGuid(guidList:Get(i)):GetObject())
        local classid = itemobj.ClassID
        local life_time = GET_REMAIN_ITEM_LIFE_TIME(itemobj)

        if life_time ~= nil then
            if classid == 10820019 and count == 1 and tonumber(life_time) < 86400 then
                INV_ICON_USE(session.GetInvItemByType(tonumber(classid)))
                return
            elseif classid == 11030080 and count == 1 and tonumber(life_time) < 86400 then
                INV_ICON_USE(session.GetInvItemByType(tonumber(classid)))
                return
            elseif classid == 641954 and count == 1 then
                INV_ICON_USE(session.GetInvItemByType(tonumber(classid)))
                return
            elseif classid == 11030080 and count == 1 then
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
        indun_panel_buyuse(frame, ctrl, "EVENT_TOS_WHOLE_SHOP_28", argNum)
        return
    end

    local trade_count = INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_40")
    if trade_count >= 1 and count == 1 then
        indun_panel_buyuse(frame, ctrl, "PVP_MINE_40", argNum)
        return
    end
       
    end

end

function indun_panel_buyuse(frame, ctrl, recipeName, indunType)

    if indunType == 201 then
        local count = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", indunType).PlayPerResetType)
        local trade_count = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", indunType).PlayPerResetType)
        if count == 1 and trade_count == 1 then

            INDUN_PANEL_ITEM_BUY_USE(recipeName)

        elseif count == 1 and trade_count == 0 then
            local vel_recipecls = GetClass('ItemTradeShop', recipeName);
            local vel_overbuy_max = TryGetProp(vel_recipecls, 'MaxOverBuyCount', 0)

            if vel_overbuy_max >= 1 then
                INDUN_PANEL_ITEM_BUY_USE(recipeName)

                return
            else
                ui.SysMsg("No trade count.")
                return
            end
        end
    elseif indunType == 647 then

        INDUN_PANEL_ITEM_BUY_USE(recipeName)

    elseif indunType == 644 then

        INDUN_PANEL_ITEM_BUY_USE(recipeName)

    end

end

function INDUN_PANEL_ITEM_BUY_USE(recipeName)

    local recipeCls = GetClass("ItemTradeShop", recipeName)
    session.ResetItemList()
    session.AddItemID(tostring(0), 1)
    local itemlist = session.GetItemIDList()
    local cntText = string.format("%s %s", tostring(recipeCls.ClassID), tostring(1))
    item.DialogTransaction("PVP_MINE_SHOP", itemlist, cntText)

    local itemCls = GetClass("Item", recipeCls.TargetItem)
    ReserveScript(string.format("INV_ICON_USE(session.GetInvItemByType(%d));", itemCls.ClassID), 1)
    return

end

-- 傭兵団コインの数量を取得して返す
function indun_panel_pvpmaine_count()

    local aObj = GetMyAccountObj()
    local coincount = TryGetProp(aObj, "MISC_PVP_MINE2", '0')
    local itemCls = GetClass('Item', 'misc_pvp_mine2')

    if coincount == 'None' then
        coincount = '0'
    end

    return coincount

end

-- 傭兵コインショップの設定を超えて買う数量を返す
function indun_panel_overbuy_count()

    local aObj = GetMyAccountObj()
    local recipecls = GetClass('ItemTradeShop', "PVP_MINE_52");
    local overbuy_max = TryGetProp(recipecls, 'MaxOverBuyCount', 0)
    local overbuy_prop = TryGetProp(recipecls, 'OverBuyProperty', 'None')
    local overbuy_count = TryGetProp(aObj, overbuy_prop, 0)
    local overbuy = tonumber(overbuy_max) - tonumber(overbuy_count)

    return overbuy

end

-- 傭兵コインショップの設定を超えて買う場合のコイン必要数量を返す
function indun_panel_overbuy_amount()
    local aObj = GetMyAccountObj()
    local recipecls = GetClass('ItemTradeShop', "PVP_MINE_52");
    local overbuy_max = TryGetProp(recipecls, 'MaxOverBuyCount', 0)
    local overbuy_prop = TryGetProp(recipecls, 'OverBuyProperty', 'None')
    local overbuy_count = TryGetProp(aObj, overbuy_prop, 0)
    local overbuyamount = 0

    if INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_52") == 1 and overbuy_count == 0 then
        overbuyamount = 1000

    elseif overbuy_count >= 0 then
        overbuyamount = overbuy_count * 50 + 1050

    end

    return overbuyamount
end

-- 傭兵団コインで買えるアイテム数を返す
function INDUN_PANEL_GET_RECIPE_TRADE_COUNT(recipeName)
    local recipeCls = GetClass("ItemTradeShop", recipeName)
    -- DBGOUT("recipeCls: " .. recipeName)
    if recipeCls.NeedProperty ~= "None" and recipeCls.NeedProperty ~= "" then
        local sObj = GetSessionObject(GetMyPCObject(), "ssn_shop")
        local sCount = TryGetProp(sObj, recipeCls.NeedProperty)

        if sCount then
            return sCount
        end
    end

    if recipeCls.AccountNeedProperty ~= "None" and recipeCls.AccountNeedProperty ~= "" then

        local aObj = GetMyAccountObj()
        local sCount = TryGetProp(aObj, recipeCls.AccountNeedProperty)

        if sCount then
            return sCount
        end
    end

    return nil
end

-- 傭兵団コインで買えるMAXアイテム数を返す
function INDUN_PANEL_GET_MAX_RECIPE_TRADE_COUNT(recipeName)
    local recipeCls = GetClass("ItemTradeShop", recipeName)
    local accountCls = GetClassByType("Account", 1)
    if recipeCls.NeedProperty ~= "None" and recipeCls.NeedProperty ~= "" then
        local sObj = GetSessionObject(GetMyPCObject(), "ssn_shop")
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
