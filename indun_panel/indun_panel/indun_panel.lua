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
local addonName = "indun_panel"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.2.8"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

g.settingsFileLoc = string.format('../addons/%s/new_settings.json', addonNameLower)

--[[function indun_panel_get_indunid()
    --新ダンジョン追加時に重宝。セッティングボタン右クリでも良さそう。
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
        -- if str == tostring("{s20}Wailing") then
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
        if str == tostring(
            "Priority{nl}1. tickets due within 24 hours {nl}2. mercenary coin store tickets (buy and use) {nl}3. tickets due") then
            str =
                "優先順位{nl}1.24時間以内の期限付きチケット{nl}2.傭兵団コインチケット(コインで買って使います){nl}3.期限付きチケット"
        end
        return "{s18}" .. str
    end

    local LangCode = config.GetServiceNation()
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
    end

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
        local ipframe = ui.GetFrame("indun_panel")
        ipframe:RemoveAllChild()
        if g.settings.jsr_checkbox == 1 then

            addon:RegisterMsg('GAME_START_3SEC', "indun_panel_FIELD_BOSS_TIME_TAB_SETTING")
        end

        if g.settings.checkbox == 1 then
            indun_panel_frame_init()

            indun_panel_init(ipframe)

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

    local ipframe = ui.GetFrame(g.framename)
    ipframe:SetSkinName('None')
    ipframe:SetLayerLevel(30)
    ipframe:Resize(140, 40)
    ipframe:SetPos(1640, 0)
    ipframe:SetTitleBarSkin("None")
    ipframe:EnableHittestFrame(1)
    ipframe:EnableHide(0)
    ipframe:EnableHitTest(1)
    ipframe:RemoveAllChild()

    local zoomedit = ipframe:CreateOrGetControl('edit', 'zoomedit', 80, 0, 60, 30)
    AUTO_CAST(zoomedit)
    zoomedit:SetText("{ol}" .. g.settings.zoom)
    zoomedit:SetFontName("white_16_ol")
    zoomedit:SetTextAlign("center", "center")
    zoomedit:SetEventScript(ui.ENTERKEY, "indun_panel_autozoom_save")
    zoomedit:SetTextTooltip("Auto Zoom Setting{nl}" ..
                                "1～700の値で入力。標準は336。マップ切り替え時に入力の値までZoomします。0入力で機能無効化。{nl}Input a value from 0 to 700. Standard is 336. Zoom to the input value when switching maps.{nl}Disable function by inputting 0.")
    ipframe:ShowWindow(1)
end

-- 画面上の小さいボタンとCCボタンを配置
function indun_panel_frame_init()

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

    local ccbtn = ipframe:CreateOrGetControl('button', 'ccbtn', 95, 5, 30, 35)
    AUTO_CAST(ccbtn)
    ccbtn:SetSkinName("None")
    ccbtn:SetText("{img barrack_button_normal 35 35}")
    ccbtn:SetEventScript(ui.LBUTTONUP, "APPS_TRY_MOVE_BARRACK")

    ipframe:ShowWindow(1)
    ipframe:RunUpdateScript("indun_panel_time_update", 300)

end

-- オートズーム機能の数字監視
function indun_panel_autozoom_save(frame, ctrl)
    local value = tonumber(ctrl:GetText())

    if value == 0 then
        g.settings.zoom = 0
        indun_panel_save_settings()

        return
    end

    if value < tonumber(1) or value > tonumber(700) then
        ui.SysMsg(
            "Invalid value please set between 1 and 700{nl}無効な値です。1から700の間で設定してください。")
        local text = GET_CHILD_RECURSIVELY(frame, "zoomedit")
        text:SetText("336")
        frame:Invalidate()
        g.settings.zoom = 336
        indun_panel_save_settings()

        ReserveScript("indun_panel_autozoom()", 1.0)
        return
    end

    if tonumber(value) ~= tonumber(g.settings.zoom) then
        ui.SysMsg("Auto Zoom setting set to" .. value)
        g.settings.zoom = value
        indun_panel_save_settings()

        ReserveScript("indun_panel_autozoom()", 1.0)
    else
        return
    end
end

function indun_panel_frame_close(ipframe)
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

    local ccbtn = ipframe:CreateOrGetControl('button', 'ccbtn', 95, 5, 30, 35)
    AUTO_CAST(ccbtn)
    ccbtn:SetSkinName("None")
    ccbtn:SetText("{img barrack_button_normal 35 35}")
    ccbtn:SetEventScript(ui.LBUTTONUP, "APPS_TRY_MOVE_BARRACK")

    ipframe:ShowWindow(1)
    ipframe:RunUpdateScript("indun_panel_time_update", 300)

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

function indun_panel_FIELD_BOSS_TIME_TAB_SETTING(frame)
    local frame = ui.GetFrame("induninfo")
    local ctrlSet = GET_CHILD_RECURSIVELY(frame, "field_boss_ranking_control")
    local now_time = geTime.GetServerSystemTime()
    local sub_tab = GET_CHILD_RECURSIVELY(ctrlSet, "sub_tab")

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
    -- print("test1")
    if (time12_5 - currentTime) > 0 then

        sub_tab:SelectTab(0)
    else

        sub_tab:SelectTab(1)
    end

end

function indun_panel_FIELD_BOSS_ENTER_TIMER_SETTING(ctrl_set)
    if ctrl_set == nil then
        return;
    end

    local frame = ctrl_set:GetTopParentFrame();
    if frame == nil then
        return;
    end

    local gauge = GET_CHILD_RECURSIVELY(ctrl_set, "gauge");
    if gauge == nil then
        return;
    end
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
    local diff = 0
    local difftime = 0
    local am
    local pm
    if (time12_5 - currentTime) > 0 then
        am = 1
        pm = 0
        diff = time12_5 - currentTime
        difftime = time12_5
    else
        am = 0
        pm = 1
        diff = time22_5 - currentTime
        difftime = time22_5
    end

    -- print(tostring(diff))

    local textstr;
    local battle_info_time_text = GET_CHILD_RECURSIVELY(ctrl_set, "battle_info_time_text");

    if diff < 0 and pm == 1 then

        if g.settings.en_ver == 1 then
            textstr = "NotAddmittableDay";
        else
            textstr = ClMsg("NotAddmittableDay");
        end
    elseif diff - 300 > 0 then

        if g.settings.en_ver == 1 then
            textstr = GET_TIME_TXT_NO_LANG(diff - 300) .. " " .. "After Start";
        else
            textstr = GET_TIME_TXT(diff - 300) .. " " .. ClMsg("After_Start");
        end
    elseif difftime > 0 then

        if g.settings.en_ver == 1 then
            textstr = GET_TIME_TXT_NO_LANGT(difftime - currentTime) .. " " .. "After Exit";
        else
            textstr = GET_TIME_TXT(difftime - currentTime) .. " " .. ClMsg("After_Exit");
        end

    elseif difftime < 0 then

        if g.settings.en_ver == 1 then
            textstr = "Already Exit";
        else
            textstr = ClMsg("Already_Exit");
        end

    end

    battle_info_time_text:SetTextByKey("value", textstr);

    return textstr
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
        merregina = {
            s = 696,
            a = 695,
            -- h = 695,
            ac = 80032
        }
    },
    [4] = {
        slogutis = {
            s = 689,
            a = 688,
            h = 690,
            ac = 80031
        }
    },
    [5] = {
        upinis = {
            s = 686,
            a = 685,
            h = 687,
            ac = 80030
        }
    },
    [6] = {
        roze = {
            s = 680,
            a = 679,
            h = 681,
            ac = 80015
        }
    },
    [7] = {
        falouros = {
            s = 677,
            a = 676,
            h = 678,
            ac = 80017
        }
    },
    [8] = {
        spreader = {
            s = 674,
            a = 673,
            h = 675,
            ac = 80016
        }
    },
    [9] = {
        jellyzele = {
            s = 672,
            a = 671,
            h = 670
        }
    },
    [10] = {
        delmore = {
            s = 667,
            a = 666,
            h = 665
        }
    },
    [11] = {
        telharsha = 623
    },
    [12] = {
        velnice = 201
    },
    [13] = {
        giltine = {
            s = 669,
            a = 635,
            h = 628
        }
    },
    [14] = {
        earring = {
            s = 661,
            a = 662,
            h = 663
        }
    },
    [15] = {
        cemetery = {
            c490 = 684,
            c500 = 693
        }
    },
    [16] = {
        jsr = 0
    }
}

-- パネル展開
function indun_panel_init(ipframe)

    ipframe:RemoveAllChild()

    local button = ipframe:CreateOrGetControl("button", "indun_panel_open", 5, 5, 80, 30)
    AUTO_CAST(button)
    button:SetText("{ol}{s11}INDUNPANEL")

    local ccbtn = ipframe:CreateOrGetControl('button', 'ccbtn', 95, 5, 30, 35)
    AUTO_CAST(ccbtn)
    ccbtn:SetSkinName("None")
    ccbtn:SetText("{img barrack_button_normal 35 35}")
    ccbtn:SetEventScript(ui.LBUTTONUP, "APPS_TRY_MOVE_BARRACK")
    ccbtn:SetTextTooltip("バラックに戻ります。{nl}Return to Barracks.")

    --[[local invbtn = ipframe:CreateOrGetControl('button', 'invbtn', 195, 5, 35, 35)
    AUTO_CAST(invbtn)
    invbtn:SetSkinName("None")
    invbtn:SetText("{img sysmenu_inv 35 35}")
    invbtn:SetEventScript(ui.LBUTTONUP, "UI_TOGGLE_INVENTORY")
    invbtn:SetSkinName("test_pvp_btn")
    invbtn:SetTextTooltip("{@st59}インベントリを開きます。{nl}Open inventory.")]]

    local tosshop = ipframe:CreateOrGetControl("button", "tosshop", 170, 10, 25, 25);
    AUTO_CAST(tosshop)
    tosshop:SetSkinName("None")

    tosshop:SetText("{img icon_item_Tos_Event_Coin 25 25}")
    tosshop:SetTextTooltip("TOSイベントショップ{nl}TOS Event Shop")
    tosshop:SetEventScript(ui.LBUTTONUP, "indun_panel_event_tos_whole_shop_open")

    --[[local minebtn = ipframe:CreateOrGetControl('button', 'minebtn', 130, 5, 35, 35)
    AUTO_CAST(minebtn)
    minebtn:SetSkinName("None")
    minebtn:SetText("{img pvpmine_shop_btn_total 35 35}")
    minebtn:SetEventScript(ui.LBUTTONUP, "INDUN_PANEL_MINIMIZED_PVPMINE_SHOP_BUTTON_CLICK")
    minebtn:SetTextTooltip("{@st59}傭兵団のコイン商店。{nl}Mercenary Coin Shop.")]]

    local configbtn = ipframe:CreateOrGetControl('button', 'configbtn', 130, 5, 30, 35)
    AUTO_CAST(configbtn)
    configbtn:SetSkinName("None")
    configbtn:SetText("{img config_button_normal 35 35}")
    -- configbtn:SetImage("config_button_normal")
    configbtn:SetEventScript(ui.LBUTTONUP, "indun_panel_config_gb_open")
    configbtn:SetTextTooltip("レイド表示設定{nl}Raid Display Settings")

    if configbtn:IsVisible() == 1 then
        button:SetEventScript(ui.LBUTTONUP, "indun_panel_frame_init")

    end
    -- print(g.settings.checkbox)
    local checkbox = ipframe:CreateOrGetControl('checkbox', 'checkbox', 565, 5, 30, 30)
    tolua.cast(checkbox, 'ui::CCheckBox')
    checkbox:SetCheck(g.settings.checkbox)
    checkbox:SetEventScript(ui.LBUTTONUP, "indun_panel_ischecked")
    checkbox:SetTextTooltip("チェックすると常時展開{nl}IsCheck AlwaysOpen")

    local pvpmine = ipframe:CreateOrGetControl("richtext", "pvpmine", 420, 10)
    pvpmine:SetText("{img pvpmine_shop_btn_total 25 25}")
    pvpmine:SetTextTooltip("傭兵団コイン数量 Mercenary Badge count")

    local pvpminecount = ipframe:CreateOrGetControl("richtext", "pvpminecount", 450, 10)
    pvpminecount:SetText(string.format("{ol}{#FFD900}{s20}%s", GET_COMMAED_STRING(indun_panel_pvpmaine_count())))

    local y = 45

    local count = #induntype
    --[[for i = 1, count do
        local entry = induntype[i]
        for key, value in pairs(entry) do
            print("Key:", key)
            for subkey, subvalue in pairs(value) do
                print("\tSubkey:", subkey, "Subvalue:", subvalue)
            end
        end
    end]]
    local count = #induntype
    for i = 1, count do

        local entry = induntype[i]
        for key, value in pairs(entry) do

            if g.settings[key .. "_checkbox"] == 1 then
                if type(value) == "table" then
                    if key == "slogutis" or key == "upinis" or key == "roze" or key == "falouros" or key == "spreader" then
                        for subKey, subValue in pairs(value) do
                            indun_panel_create_frame_onsweep(ipframe, key, subKey, subValue, y)
                        end
                    elseif key == "merregina" then
                        -- print(tostring(key))
                        for subKey, subValue in pairs(value) do

                            indun_panel_merregina_frame_onsweep(ipframe, key, subKey, subValue, y)
                        end
                    elseif key == "jellyzele" or key == "delmore" or key == "giltine" or key == "earring" then
                        for subKey, subValue in pairs(value) do
                            indun_panel_create_frame(ipframe, key, subKey, subValue, y)
                        end

                    elseif key == "challenge" then
                        -- for subKey, subValue in pairs(value) do
                        indun_panel_challenge_frame(ipframe, key, y)
                        -- end
                    elseif key == "singularity" then
                        -- for subKey, subValue in pairs(value) do
                        indun_panel_singularity_frame(ipframe, key, y)
                        -- end
                    elseif key == "cemetery" then
                        -- for subKey, subValue in pairs(value) do
                        indun_panel_cemetery_frame(ipframe, key, y)
                        -- end
                    end

                else
                    if key == "telharsha" then
                        indun_panel_telharsha_frame(ipframe, key, y)
                    elseif key == "velnice" then
                        indun_panel_velnice_frame(ipframe, key, y)
                    elseif key == "jsr" then
                        indun_panel_jsr_frame(ipframe, key, y)
                    end
                end
                y = y + 35
            end
        end
    end
    ipframe:SetLayerLevel(32)
    ipframe:Resize(600, y + 5)
    ipframe:SetSkinName("bg")
    ipframe:EnableHitTest(1);
    ipframe:SetAlpha(20)
    ipframe:RunUpdateScript("indun_panel_update_frame", 1.0)

    return
end

function indun_panel_merregina_frame_onsweep(ipframe, key, subKey, subValue, y)
    local text = ipframe:CreateOrGetControl("richtext", key, 15, y)
    text:SetText("{ol}{#FFFFFF}" .. INDUN_PANEL_LANG(key))
    text:AdjustFontSizeByWidth(120)
    local solo = ipframe:CreateOrGetControl('button', key .. "solo", 135, y, 80, 30)
    local auto = ipframe:CreateOrGetControl('button', key .. "auto", 220, y, 80, 30)
    -- local hard = ipframe:CreateOrGetControl('button', key .. "hard", 350, y, 80, 30)
    local count = ipframe:CreateOrGetControl("richtext", key .. "count", 305, y + 5, 50, 30)
    -- local counthard = ipframe:CreateOrGetControl("richtext", key .. "counthard", 435, y + 5, 50, 30)
    local sweep = ipframe:CreateOrGetControl('button', key .. "sweep", 480, y, 80, 30)
    local sweepcount = ipframe:CreateOrGetControl("richtext", key .. "sweepcount", 565, y + 5, 50, 30)

    solo:SetText("{ol}SOLO")
    auto:SetText("{ol}{#FFD900}AUTO")
    -- hard:SetText("{ol}{#FF0000}HARD")
    sweep:SetText("{ol}{#00FF00}" .. "ACLEAR")
    if subKey == "s" then

        solo:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_solo")
        solo:SetEventScriptArgNumber(ui.LBUTTONUP, subValue)
    elseif subKey == "a" then
        count:SetText("{ol}{#FFFFFF}{s16}(" ..
                          GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", subValue).PlayPerResetType) .. "/" ..
                          GET_INDUN_MAX_ENTERANCE_COUNT(GetClassByType("Indun", subValue).PlayPerResetType) .. ")")
        auto:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_auto")
        auto:SetEventScriptArgNumber(ui.LBUTTONUP, subValue)
        sweep:SetEventScript(ui.LBUTTONUP, "indun_panel_autosweep")
        sweep:SetEventScriptArgNumber(ui.LBUTTONUP, subValue)
        --[[elseif subKey == "h" then
        counthard:SetText("{ol}{#FFFFFF}{s16}(" ..
                              GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", subValue).PlayPerResetType) .. "/" ..
                              GET_INDUN_MAX_ENTERANCE_COUNT(GetClassByType("Indun", subValue).PlayPerResetType) .. ")")
        hard:SetEventScript(ui.LBUTTONDOWN, "indun_panel_enter_hard")
        hard:SetEventScriptArgNumber(ui.LBUTTONDOWN, subValue)
        hard:SetEventScriptArgString(ui.LBUTTONDOWN, "false")]]
    elseif subKey == "ac" then

        sweepcount:SetText("{ol}{#FFFFFF}{s16}(" .. indun_panel_sweep_count(subValue) .. ")")
    end

end

function indun_panel_config_gb_open(frame, ctrl, argStr, argNum)
    local ipframe = ui.GetFrame(g.framename)
    ipframe:SetSkinName("test_frame_low")
    ipframe:SetLayerLevel(90)
    ipframe:Resize(200, 640)
    ipframe:SetPos(665, 30)
    -- ipframe:SetTitleBarSkin("mainframe_03")
    -- ipframe:ShowTitleBar(1);
    ipframe:EnableHittestFrame(1)
    ipframe:EnableHide(0)
    ipframe:EnableHitTest(1)
    ipframe:SetAlpha(100)
    ipframe:RemoveAllChild()
    ipframe:ShowWindow(1)

    local button = ipframe:CreateOrGetControl("button", "indun_panel_open", 5, 5, 80, 30)
    AUTO_CAST(button)
    button:SetText("{ol}{s11}INDUNPANEL")
    button:SetEventScript(ui.LBUTTONUP, "indun_panel_frame_init")

    local en_ver = ipframe:CreateOrGetControl('checkbox', 'en_ver', 165, 10, 25, 25)
    AUTO_CAST(en_ver)
    if g.settings.en_ver == nil then
        g.settings.en_ver = 0
        indun_panel_save_settings()
    end
    en_ver:SetCheck(g.settings.en_ver)
    en_ver:SetEventScript(ui.LBUTTONUP, "indun_panel_ischecked")
    en_ver:SetTextTooltip(
        "チェックすると英語表示に変更します。{nl}Checking the box changes the display to English.")

    local zoomedit = ipframe:CreateOrGetControl('edit', 'zoomedit', 100, 5, 50, 30)
    AUTO_CAST(zoomedit)
    zoomedit:SetText("{ol}" .. g.settings.zoom)
    zoomedit:SetFontName("white_16_ol")
    zoomedit:SetTextAlign("center", "center")
    zoomedit:SetEventScript(ui.ENTERKEY, "indun_panel_autozoom_save")
    zoomedit:SetTextTooltip("Auto Zoom Setting{nl}" ..
                                "1～700の値で入力。標準は336。マップ切り替え時に入力の値までZoomします。0入力で機能無効化。{nl}" ..
                                "Input a value from 0 to 700. Standard is 336. Zoom to the input value when switching maps.{nl}Disable function by inputting 0.")

    local posY = 45
    local count = #induntype
    for i = 1, count do
        local entry = induntype[i]
        for key, value in pairs(entry) do

            local richtext = ipframe:CreateOrGetControl("richtext", key, 15, posY)
            richtext:SetText("{ol}{#FFFFFF}" .. INDUN_PANEL_LANG(key))
            richtext:AdjustFontSizeByWidth(140)

            local checkbox = ipframe:CreateOrGetControl('checkbox', key .. '_checkbox', 165, posY, 25, 25)
            AUTO_CAST(checkbox)
            checkbox:SetCheck(g.settings[key .. '_checkbox'])
            checkbox:SetEventScript(ui.LBUTTONUP, "indun_panel_ischecked")
            checkbox:SetTextTooltip("チェックすると表示{nl}Check to show")

        end
        posY = posY + 35
    end
    ipframe:Resize(200, posY + 5)
end

-- 表示更新
function indun_panel_update_frame(frame)

    local frame = ui.GetFrame(g.framename)
    local configbtn = GET_CHILD_RECURSIVELY(frame, "configbtn")

    if configbtn:IsVisible() == 1 then
        -- 
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

            cha_ticketcount:SetText("{ol}{#FFFFFF}{s16}(" .. INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_40") .. "/" ..
                                        INDUN_PANEL_GET_MAX_RECIPE_TRADE_COUNT("PVP_MINE_40") .. ")")
            cha_count:SetText("{ol}{#FFFFFF}{s16}(" ..
                                  GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 646).PlayPerResetType) .. "/" ..
                                  GET_INDUN_MAX_ENTERANCE_COUNT(GetClassByType("Indun", 646).PlayPerResetType) .. ")")

        end

        if g.settings.singularity_checkbox == 1 then

            local sin_ticketcount = GET_CHILD_RECURSIVELY(frame, "sin_ticketcount")
            local sin_normal_count = GET_CHILD_RECURSIVELY(frame, "sin_normal_count")

            sin_ticketcount:SetText("{ol}{#FFFFFF}{s16}(d:" .. INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_41") ..
                                        "/w:" .. INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_42") .. "/max:" ..
                                        (INDUN_PANEL_GET_MAX_RECIPE_TRADE_COUNT("PVP_MINE_41") +
                                            INDUN_PANEL_GET_MAX_RECIPE_TRADE_COUNT("PVP_MINE_42")) .. ")")

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

                -- print(tostring(key))
                if g.settings[key .. "_checkbox"] == 1 then

                    if type(value) == "table" then
                        if key == "slogutis" or key == "upinis" or key == "roze" or key == "falouros" or key ==
                            "spreader" then
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
                        elseif key == "merregina" then

                            local sweepcount = GET_CHILD_RECURSIVELY(frame, key .. "sweepcount")
                            local count = GET_CHILD_RECURSIVELY(frame, key .. "count")

                            -- local counthard = GET_CHILD_RECURSIVELY(frame, key .. "counthard")
                            for subKey, subValue in pairs(value) do
                                if subKey == "ac" then
                                    sweepcount:SetText("{ol}{#FFFFFF}{s16}(" .. indun_panel_sweep_count(subValue) .. ")")

                                elseif subKey == "a" then
                                    count:SetText("{ol}{#FFFFFF}{s16}(" ..
                                                      GET_CURRENT_ENTERANCE_COUNT(
                                            GetClassByType("Indun", subValue).PlayPerResetType) .. "/" ..
                                                      GET_INDUN_MAX_ENTERANCE_COUNT(
                                            GetClassByType("Indun", subValue).PlayPerResetType) .. ")")
                                    --[[elseif subKey == "h" then
                                counthard:SetText("{ol}{#FFFFFF}{s16}(" ..
                                                      GET_CURRENT_ENTERANCE_COUNT(
                                        GetClassByType("Indun", subValue).PlayPerResetType) .. "/" ..
                                                      GET_INDUN_MAX_ENTERANCE_COUNT(
                                        GetClassByType("Indun", subValue).PlayPerResetType) .. ")")]]
                                end
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
        -- print(tostring(velamount) .. "test")
        frame:Invalidate()

        return 1
    else

        return 0
    end

end

function indun_panel_jsr_frame(ipframe, key, y)
    local jsr = ipframe:CreateOrGetControl("richtext", "jsr", 15, y)
    jsr:SetText("{ol}{#FFFFFF}" .. INDUN_PANEL_LANG(key))
    jsr:AdjustFontSizeByWidth(120)
    local jsrbutton = ipframe:CreateOrGetControl('button', 'jsrbutton', 135, y, 80, 30)
    jsrbutton:SetText("{ol}JSR")

    jsrbutton:SetEventScript(ui.LBUTTONUP, "FIELD_BOSS_JOIN_ENTER_CLICK")

    local jsrtime_start = ipframe:CreateOrGetControl("richtext", "jsrtime_start", 220, y + 5)

end

function indun_panel_velnice_frame(ipframe, key, y)
    local vel = ipframe:CreateOrGetControl("richtext", "vel", 15, y)
    vel:SetText("{ol}{#FFFFFF}" .. INDUN_PANEL_LANG(key))
    vel:AdjustFontSizeByWidth(120)
    local velbutton = ipframe:CreateOrGetControl('button', 'velbutton', 135, y, 80, 30)
    velbutton:SetText("{ol}IN")
    velbutton:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_velnice_solo")

    local velcount = ipframe:CreateOrGetControl("richtext", "velcount", 220, y + 5, 50, 30)
    velcount:SetText("{ol}{#FFFFFF}(" .. GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 201).PlayPerResetType) ..
                         "/" .. GET_INDUN_MAX_ENTERANCE_COUNT(GetClassByType("Indun", 201).PlayPerResetType) .. ")")

    local vrecipecls = GetClass('ItemTradeShop', "PVP_MINE_52");
    local voverbuy_max = TryGetProp(vrecipecls, 'MaxOverBuyCount', 0)

    local velbuyuse = ipframe:CreateOrGetControl('button', 'velbuyuse', 265, y, 80, 30)
    AUTO_CAST(velbuyuse)
    velbuyuse:SetText("{ol}{#EE7800}{s14}BUYUSE")
    velbuyuse:SetEventScript(ui.LBUTTONUP, "indun_panel_buyuse")
    velbuyuse:SetEventScriptArgString(ui.LBUTTONUP, "PVP_MINE_52")
    velbuyuse:SetEventScriptArgNumber(ui.LBUTTONUP, 201)

    local velexchangecount = ipframe:CreateOrGetControl("richtext", "velexchangecount", 350, y + 5, 60, 30)

    local vexchangecount = INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_52")
    if vexchangecount < 0 then
        vexchangecount = 0
    end
    velexchangecount:SetText(string.format("{ol}{#FFFFFF}(%d", vexchangecount) .. "/" ..
                                 string.format("{ol}{#FFFFFF}%d", indun_panel_overbuy_count()) .. "{ol}{#FFFFFF})")

    local velamount = ipframe:CreateOrGetControl("richtext", "velamount", 415, y + 5, 50, 30)
    if tonumber(vexchangecount) == 1 then
        velamount:SetText("{ol}{#FFFFFF}(" .. "{img pvpmine_shop_btn_total 20 20}" .. "1,000)")

    else
        velamount:SetText("{ol}{#FFFFFF}(" .. "{img pvpmine_shop_btn_total 20 20}" ..
                              string.format("{ol}{#FF0000}%s", GET_COMMAED_STRING(indun_panel_overbuy_amount())) ..
                              "{ol}{#FFFFFF})")
    end
end

function indun_panel_telharsha_frame(ipframe, key, y)
    local tel = ipframe:CreateOrGetControl("richtext", "tel", 15, y)
    tel:SetText("{ol}{#FFFFFF}" .. INDUN_PANEL_LANG(key))
    tel:AdjustFontSizeByWidth(120)

    local telbutton = ipframe:CreateOrGetControl('button', 'telbutton', 135, y, 80, 30)
    telbutton:SetText("{ol}IN")
    local telcount = ipframe:CreateOrGetControl("richtext", "telcount", 220, y + 5)

    telbutton:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_solo")
    telbutton:SetEventScriptArgNumber(ui.LBUTTONUP, 623)

    telcount:SetText(
        "{ol}{#FFFFFF}{s16}(" .. GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 623).PlayPerResetType) .. "/" ..
            GET_INDUN_MAX_ENTERANCE_COUNT(GetClassByType("Indun", 623).PlayPerResetType) .. ")")

end

function indun_panel_cemetery_frame(ipframe, key, y)
    local cem = ipframe:CreateOrGetControl("richtext", "cem", 15, y)
    cem:SetText("{ol}{#FFFFFF}" .. INDUN_PANEL_LANG(key))
    cem:AdjustFontSizeByWidth(120)
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

    local sin = ipframe:CreateOrGetControl("richtext", "sin", 15, y)
    sin:SetText("{ol}{#FFFFFF}" .. INDUN_PANEL_LANG(key))
    sin:AdjustFontSizeByWidth(120)

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
    sin_ticket:SetTextTooltip("{ol}" .. INDUN_PANEL_LANG(
        "Priority{nl}1. tickets due within 24 hours {nl}2. mercenary coin store tickets (buy and use) {nl}3. tickets due"))
    sin_ticket:SetEventScript(ui.LBUTTONUP, "indun_panel_item_use")
    sin_ticket:SetEventScriptArgNumber(ui.LBUTTONUP, 647)

    local sin_ticketcount = ipframe:CreateOrGetControl("richtext", "sin_ticketcount", 420, y + 5, 40, 30)
    sin_ticketcount:SetText("{ol}{#FFFFFF}{s16}(d:" .. INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_41") .. "/w:" ..
                                INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_42") .. "/max:" ..
                                (INDUN_PANEL_GET_MAX_RECIPE_TRADE_COUNT("PVP_MINE_41") +
                                    INDUN_PANEL_GET_MAX_RECIPE_TRADE_COUNT("PVP_MINE_42")) .. ")")

    local sin_check = ipframe:CreateOrGetControl("checkbox", "singularity_check", 555, y, 25, 25)
    AUTO_CAST(sin_check)
    sin_check:SetEventScript(ui.LBUTTONUP, "indun_panel_ischecked")
    sin_check:SetTextTooltip("{ol}{チェックをすると自動マッチングボタンを押しません。{nl}}" ..
                                 "If checked, the automatic matching button will not be pressed.")

    sin_check:SetCheck(g.settings.singularity_check)

end

function indun_panel_challenge_frame(ipframe, key, y)
    local cha = ipframe:CreateOrGetControl("richtext", "cha", 15, y)
    cha:SetText("{ol}{#FFFFFF}" .. INDUN_PANEL_LANG(key))
    cha:AdjustFontSizeByWidth(120)

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
    cha_ticket:SetTextTooltip("{ol}" .. INDUN_PANEL_LANG(
        "Priority{nl}1. tickets due within 24 hours {nl}2. mercenary coin store tickets (buy and use) {nl}3. tickets due"))
    cha_ticket:SetEventScript(ui.LBUTTONUP, "indun_panel_item_use")
    cha_ticket:SetEventScriptArgNumber(ui.LBUTTONUP, 644)

    local cha_ticketcount = ipframe:CreateOrGetControl("richtext", "cha_ticketcount", 520, y + 5, 40, 30)
    cha_ticketcount:SetText("{ol}{#FFFFFF}{s16}(" .. INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_40") .. "/" ..
                                INDUN_PANEL_GET_MAX_RECIPE_TRADE_COUNT("PVP_MINE_40") .. ")")

end

function indun_panel_create_frame(ipframe, key, subKey, subValue, y)
    local text = ipframe:CreateOrGetControl("richtext", key, 15, y)
    text:SetText("{ol}{#FFFFFF}" .. INDUN_PANEL_LANG(key))
    text:AdjustFontSizeByWidth(120)

    local solo = ipframe:CreateOrGetControl('button', key .. "solo", 135, y, 80, 30)
    local auto = ipframe:CreateOrGetControl('button', key .. "auto", 220, y, 80, 30)
    local hard = ipframe:CreateOrGetControl('button', key .. "hard", 350, y, 80, 30)
    local count = ipframe:CreateOrGetControl("richtext", key .. "count", 305, y + 5, 50, 30)
    local counthard = ipframe:CreateOrGetControl("richtext", key .. "counthard", 435, y + 5, 50, 30)

    solo:SetText("{ol}SOLO")
    if key == "earring" then
        auto:SetText("{ol}{#FFD900}NORMAL")
    else
        auto:SetText("{ol}{#FFD900}AUTO")
    end
    hard:SetText("{ol}{#FF0000}HARD")

    if key == "giltine" or key == "earring" then
        if subKey == "s" then
            if key == "giltine" then
                count:SetText("{ol}{#FFFFFF}{s16}(" ..
                                  GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", subValue).PlayPerResetType) .. "/" ..
                                  GET_INDUN_MAX_ENTERANCE_COUNT(GetClassByType("Indun", subValue).PlayPerResetType) ..
                                  ")")
                solo:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_solo")
                solo:SetEventScriptArgNumber(ui.LBUTTONUP, subValue)
            else
                count:SetText("{ol}{#FFFFFF}{s16}(" ..
                                  GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", subValue).PlayPerResetType) .. ")")
                solo:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_solo")
                solo:SetEventScriptArgNumber(ui.LBUTTONUP, subValue)
            end
        elseif subKey == "a" then
            auto:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_auto")
            auto:SetEventScriptArgNumber(ui.LBUTTONUP, subValue)

        elseif subKey == "h" then
            counthard:SetText("{ol}{#FFFFFF}{s16}(" ..
                                  GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", subValue).PlayPerResetType) .. ")")
            hard:SetEventScript(ui.LBUTTONDOWN, "indun_panel_enter_hard")
            hard:SetEventScriptArgNumber(ui.LBUTTONDOWN, subValue)
            if key ~= "earring" then
                hard:SetEventScriptArgString(ui.LBUTTONDOWN, "false")
            end
        end

    else

        if subKey == "s" then
            count:SetText("{ol}{#FFFFFF}{s16}(" ..
                              GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", subValue).PlayPerResetType) .. "/" ..
                              GET_INDUN_MAX_ENTERANCE_COUNT(GetClassByType("Indun", subValue).PlayPerResetType) .. ")")
            solo:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_solo")
            solo:SetEventScriptArgNumber(ui.LBUTTONUP, subValue)
        elseif subKey == "a" then
            auto:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_auto")
            auto:SetEventScriptArgNumber(ui.LBUTTONUP, subValue)

        elseif subKey == "h" then
            counthard:SetText("{ol}{#FFFFFF}{s16}(" ..
                                  GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", subValue).PlayPerResetType) .. "/" ..
                                  GET_INDUN_MAX_ENTERANCE_COUNT(GetClassByType("Indun", subValue).PlayPerResetType) ..
                                  ")")
            hard:SetEventScript(ui.LBUTTONDOWN, "indun_panel_enter_hard")
            hard:SetEventScriptArgNumber(ui.LBUTTONDOWN, subValue)
            hard:SetEventScriptArgString(ui.LBUTTONDOWN, "false")

        end
    end
end

function indun_panel_create_frame_onsweep(ipframe, key, subKey, subValue, y)
    local text = ipframe:CreateOrGetControl("richtext", key, 15, y)
    text:SetText("{ol}{#FFFFFF}" .. INDUN_PANEL_LANG(key))
    text:AdjustFontSizeByWidth(120)
    local solo = ipframe:CreateOrGetControl('button', key .. "solo", 135, y, 80, 30)
    local auto = ipframe:CreateOrGetControl('button', key .. "auto", 220, y, 80, 30)
    local hard = ipframe:CreateOrGetControl('button', key .. "hard", 350, y, 80, 30)
    local count = ipframe:CreateOrGetControl("richtext", key .. "count", 305, y + 5, 50, 30)
    local counthard = ipframe:CreateOrGetControl("richtext", key .. "counthard", 435, y + 5, 50, 30)
    local sweep = ipframe:CreateOrGetControl('button', key .. "sweep", 480, y, 80, 30)
    local sweepcount = ipframe:CreateOrGetControl("richtext", key .. "sweepcount", 565, y + 5, 50, 30)

    solo:SetText("{ol}SOLO")
    auto:SetText("{ol}{#FFD900}AUTO")
    hard:SetText("{ol}{#FF0000}HARD")
    sweep:SetText("{ol}{#00FF00}" .. "ACLEAR")
    if subKey == "s" then
        count:SetText("{ol}{#FFFFFF}{s16}(" ..
                          GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", subValue).PlayPerResetType) .. "/" ..
                          GET_INDUN_MAX_ENTERANCE_COUNT(GetClassByType("Indun", subValue).PlayPerResetType) .. ")")
        solo:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_solo")
        solo:SetEventScriptArgNumber(ui.LBUTTONUP, subValue)
    elseif subKey == "a" then
        auto:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_auto")
        auto:SetEventScriptArgNumber(ui.LBUTTONUP, subValue)
        sweep:SetEventScript(ui.LBUTTONUP, "indun_panel_autosweep")
        sweep:SetEventScriptArgNumber(ui.LBUTTONUP, subValue)
    elseif subKey == "h" then
        counthard:SetText("{ol}{#FFFFFF}{s16}(" ..
                              GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", subValue).PlayPerResetType) .. "/" ..
                              GET_INDUN_MAX_ENTERANCE_COUNT(GetClassByType("Indun", subValue).PlayPerResetType) .. ")")
        hard:SetEventScript(ui.LBUTTONDOWN, "indun_panel_enter_hard")
        hard:SetEventScriptArgNumber(ui.LBUTTONDOWN, subValue)
        hard:SetEventScriptArgString(ui.LBUTTONDOWN, "false")
    elseif subKey == "ac" then

        sweepcount:SetText("{ol}{#FFFFFF}{s16}(" .. indun_panel_sweep_count(subValue) .. ")")
    end

end

function INDUN_PANEL_INDUNINFO_SET_BUTTONS(indunType)
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
            [678] = "falohard",
            [681] = "rozehard",
            [628] = "giltinehard",
            [687] = "upinishard",
            [690] = "slogutishard"
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

function indun_panel_item_use(frame, ctrl, argStr, argNum)

    session.ResetItemList()
    local invItemList = session.GetInvItemList()
    local guidList = invItemList:GetGuidList();
    local cnt = guidList:Count();

    local count = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", argNum).PlayPerResetType)

    if argNum == 647 then

        for i = 0, cnt - 1 do
            local guid = guidList:Get(i);
            local invItem = invItemList:GetItemByGuid(guid)
            local itemobj = GetIES(invItem:GetObject())
            local classid = itemobj.ClassID
            local life_time = GET_REMAIN_ITEM_LIFE_TIME(itemobj)

            if life_time ~= nil then

                if classid == 10820018 and count == 0 and tonumber(life_time) < 86400 then

                    INV_ICON_USE(session.GetInvItemByType(tonumber(classid)))
                    return
                end

                if classid == 11030067 and count == 0 then

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

        for i = 0, cnt - 1 do
            local guid = guidList:Get(i);
            local invItem = invItemList:GetItemByGuid(guid)
            local itemobj = GetIES(invItem:GetObject())
            local classid = itemobj.ClassID

            if classid == 10820018 and count == 0 then
                INV_ICON_USE(session.GetInvItemByType(tonumber(classid)))
                return
            end

        end

    elseif argNum == 644 then

        for i = 0, cnt - 1 do
            local guid = guidList:Get(i);
            local invItem = invItemList:GetItemByGuid(guid)
            local itemobj = GetIES(invItem:GetObject())
            local classid = itemobj.ClassID
            local life_time = GET_REMAIN_ITEM_LIFE_TIME(itemobj)

            if life_time ~= nil then
                if classid == 10820019 and count == 1 and tonumber(life_time) < 86400 then

                    INV_ICON_USE(session.GetInvItemByType(tonumber(classid)))
                    return
                end

                if classid == 641954 and count == 1 then

                    INV_ICON_USE(session.GetInvItemByType(tonumber(classid)))
                    return
                end
            end
            if classid == 10000073 and count == 1 then
                INV_ICON_USE(session.GetInvItemByType(tonumber(classid)))
                return
            end
        end

        local trade_count = INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_40")
        if trade_count >= 1 and count == 1 then
            -- print(tostring(argNum))
            indun_panel_buyuse(frame, ctrl, "PVP_MINE_40", argNum)
            return
        end

        for i = 0, cnt - 1 do
            local guid = guidList:Get(i);
            local invItem = invItemList:GetItemByGuid(guid)
            local itemobj = GetIES(invItem:GetObject())
            local classid = itemobj.ClassID
            if classid == 10820019 and count == 1 then
                INV_ICON_USE(session.GetInvItemByType(tonumber(classid)))
                return
            end
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
            en_ver = 0

        }
        settings = g.settings
        indun_panel_save_settings()
    end

    g.settings = settings

end

--[[function indun_panel_config_gb_open(frame, ctrl, argStr, argNum)
    local ipframe = ui.GetFrame(g.framename)
    ipframe:SetSkinName("test_frame_low")
    ipframe:SetLayerLevel(90)
    ipframe:Resize(190, 640)
    ipframe:SetPos(665, 30)
    -- ipframe:SetTitleBarSkin("mainframe_03")
    ipframe:ShowTitleBar(1);
    ipframe:EnableHittestFrame(1)
    ipframe:EnableHide(0)
    ipframe:EnableHitTest(1)
    ipframe:SetAlpha(100)
    ipframe:RemoveAllChild()
    ipframe:ShowWindow(1)

    local button = ipframe:CreateOrGetControl("button", "indun_panel_open", 5, 5, 80, 30)
    AUTO_CAST(button)
    button:SetText("{ol}{s11}INDUNPANEL")
    button:SetEventScript(ui.LBUTTONUP, "indun_panel_frame_init")

    local en_ver = ipframe:CreateOrGetControl('checkbox', 'en_ver', 150, 5, 25, 25)
    AUTO_CAST(en_ver)
    if g.settings.en_ver == nil then
        g.settings.en_ver = 0
        indun_panel_save_settings()
    end
    en_ver:SetCheck(g.settings.en_ver)
    en_ver:SetEventScript(ui.LBUTTONUP, "indun_panel_ischecked")
    en_ver:SetTextTooltip(
        "チェックすると英語表示に変更します。{nl}Checking the box changes the display to English.")

    local challenge = ipframe:CreateOrGetControl("richtext", "challenge", 15, 45)

    challenge:SetText("{ol}{#FFFFFF}" .. INDUN_PANEL_LANG("{s20}Challenge"))
    challenge:AdjustFontSizeByWidth(140)

    local challenge_checkbox = ipframe:CreateOrGetControl('checkbox', 'challenge_checkbox', 150, 45, 25, 25)
    AUTO_CAST(challenge_checkbox)
    challenge_checkbox:SetCheck(g.settings.challenge_checkbox)
    challenge_checkbox:SetEventScript(ui.LBUTTONUP, "indun_panel_ischecked")
    challenge_checkbox:SetTextTooltip("{@st59}チェックすると表示{nl}Check to show")

    local challengeex = ipframe:CreateOrGetControl("richtext", "challengeex", 15, 85)
    challengeex:SetText("{ol}{#FFFFFF}" .. INDUN_PANEL_LANG("{s20}Singularity"))
    challengeex:AdjustFontSizeByWidth(140)
    local challengeex_checkbox = ipframe:CreateOrGetControl('checkbox', 'challengeex_checkbox', 150, 85, 25, 25)
    AUTO_CAST(challengeex_checkbox)
    challengeex_checkbox:SetCheck(g.settings.challengeex_checkbox)
    challengeex_checkbox:SetEventScript(ui.LBUTTONUP, "indun_panel_ischecked")
    challengeex_checkbox:SetTextTooltip("{@st59}チェックすると表示{nl}Check to show")

    local Slogutis = ipframe:CreateOrGetControl("richtext", "Slogutis", 15, 125)
    Slogutis:SetText("{ol}{#FFFFFF}" .. INDUN_PANEL_LANG("{s20}Slogutis"))
    Slogutis:AdjustFontSizeByWidth(140)
    local Slogutis_checkbox = ipframe:CreateOrGetControl('checkbox', 'Slogutis_checkbox', 150, 125, 25, 25)
    AUTO_CAST(Slogutis_checkbox)
    Slogutis_checkbox:SetCheck(g.settings.Slogutis_checkbox)
    Slogutis_checkbox:SetEventScript(ui.LBUTTONUP, "indun_panel_ischecked")
    Slogutis_checkbox:SetTextTooltip("{@st59}チェックすると表示{nl}Check to show")

    local Upinis = ipframe:CreateOrGetControl("richtext", "Upinis", 15, 165)
    Upinis:SetText("{ol}{#FFFFFF}" .. INDUN_PANEL_LANG("{s20}Upinis"))
    Upinis:AdjustFontSizeByWidth(140)
    local Upinis_checkbox = ipframe:CreateOrGetControl('checkbox', 'Upinis_checkbox', 150, 165, 25, 25)
    AUTO_CAST(Upinis_checkbox)
    Upinis_checkbox:SetCheck(g.settings.Upinis_checkbox)
    Upinis_checkbox:SetEventScript(ui.LBUTTONUP, "indun_panel_ischecked")
    Upinis_checkbox:SetTextTooltip("{@st59}チェックすると表示{nl}Check to show")

    local roze = ipframe:CreateOrGetControl("richtext", "roze", 15, 205)
    roze:SetText("{ol}{#FFFFFF}" .. INDUN_PANEL_LANG("{s20}Roze"))
    roze:AdjustFontSizeByWidth(140)
    local roze_checkbox = ipframe:CreateOrGetControl('checkbox', 'roze_checkbox', 150, 205, 25, 25)
    AUTO_CAST(roze_checkbox)
    roze_checkbox:SetCheck(g.settings.roze_checkbox)
    roze_checkbox:SetEventScript(ui.LBUTTONUP, "indun_panel_ischecked")
    roze_checkbox:SetTextTooltip("{@st59}チェックすると表示{nl}Check to show")

    local falouros = ipframe:CreateOrGetControl("richtext", "falouros", 15, 245)
    falouros:SetText("{ol}{#FFFFFF}" .. INDUN_PANEL_LANG("{s20}Falouros"))
    falouros:AdjustFontSizeByWidth(140)
    local falouros_checkbox = ipframe:CreateOrGetControl('checkbox', 'falouros_checkbox', 150, 245, 25, 25)
    AUTO_CAST(falouros_checkbox)
    falouros_checkbox:SetCheck(g.settings.falouros_checkbox)
    falouros_checkbox:SetEventScript(ui.LBUTTONUP, "indun_panel_ischecked")
    falouros_checkbox:SetTextTooltip("{@st59}チェックすると表示{nl}Check to show")

    local spreader = ipframe:CreateOrGetControl("richtext", "spreader", 15, 285)
    spreader:SetText("{ol}{#FFFFFF}" .. INDUN_PANEL_LANG("{s20}Spreader"))
    spreader:AdjustFontSizeByWidth(140)
    local spreader_checkbox = ipframe:CreateOrGetControl('checkbox', 'spreader_checkbox', 150, 285, 25, 25)
    AUTO_CAST(spreader_checkbox)
    spreader_checkbox:SetCheck(g.settings.spreader_checkbox)
    spreader_checkbox:SetEventScript(ui.LBUTTONUP, "indun_panel_ischecked")
    spreader_checkbox:SetTextTooltip("{@st59}チェックすると表示{nl}Check to show")

    local jellyzele = ipframe:CreateOrGetControl("richtext", "jellyzele", 15, 325)
    jellyzele:SetText("{ol}{#FFFFFF}" .. INDUN_PANEL_LANG("{s20}Jellyzele"))
    jellyzele:AdjustFontSizeByWidth(140)
    local jellyzele_checkbox = ipframe:CreateOrGetControl('checkbox', 'jellyzele_checkbox', 150, 325, 25, 25)
    AUTO_CAST(jellyzele_checkbox)
    jellyzele_checkbox:SetCheck(g.settings.jellyzele_checkbox)
    jellyzele_checkbox:SetEventScript(ui.LBUTTONUP, "indun_panel_ischecked")
    jellyzele_checkbox:SetTextTooltip("{@st59}チェックすると表示{nl}Check to show")

    local delmore = ipframe:CreateOrGetControl("richtext", "delmore", 15, 365)
    delmore:SetText("{ol}{#FFFFFF}" .. INDUN_PANEL_LANG("{s20}Delmore"))
    delmore:AdjustFontSizeByWidth(140)
    local delmore_checkbox = ipframe:CreateOrGetControl('checkbox', 'delmore_checkbox', 150, 365, 25, 25)
    AUTO_CAST(delmore_checkbox)
    delmore_checkbox:SetCheck(g.settings.delmore_checkbox)
    delmore_checkbox:SetEventScript(ui.LBUTTONUP, "indun_panel_ischecked")
    delmore_checkbox:SetTextTooltip("{@st59}チェックすると表示{nl}Check to show")

    local telharsha = ipframe:CreateOrGetControl("richtext", "telharsha", 15, 405)
    telharsha:SetText("{ol}{#FFFFFF}" .. INDUN_PANEL_LANG("{s20}TelHarsha"))
    telharsha:AdjustFontSizeByWidth(140)
    local telharsha_checkbox = ipframe:CreateOrGetControl('checkbox', 'telharsha_checkbox', 150, 405, 25, 25)
    AUTO_CAST(telharsha_checkbox)
    telharsha_checkbox:SetCheck(g.settings.telharsha_checkbox)
    telharsha_checkbox:SetEventScript(ui.LBUTTONUP, "indun_panel_ischecked")
    telharsha_checkbox:SetTextTooltip("{@st59}チェックすると表示{nl}Check to show")

    local velnice = ipframe:CreateOrGetControl("richtext", "velnice", 15, 445)
    velnice:SetText("{ol}{#FFFFFF}" .. INDUN_PANEL_LANG("{s20}Velnice"))
    velnice:AdjustFontSizeByWidth(140)
    local velnice_checkbox = ipframe:CreateOrGetControl('checkbox', 'velnice_checkbox', 150, 445, 25, 25)
    AUTO_CAST(velnice_checkbox)
    velnice_checkbox:SetCheck(g.settings.velnice_checkbox)
    velnice_checkbox:SetEventScript(ui.LBUTTONUP, "indun_panel_ischecked")
    velnice_checkbox:SetTextTooltip("{@st59}チェックすると表示{nl}Check to show")

    local giltine = ipframe:CreateOrGetControl("richtext", "giltine", 15, 485)
    giltine:SetText("{ol}{#FFFFFF}" .. INDUN_PANEL_LANG("{s20}Giltine"))
    giltine:AdjustFontSizeByWidth(140)
    local giltine_checkbox = ipframe:CreateOrGetControl('checkbox', 'giltine_checkbox', 150, 485, 25, 25)
    AUTO_CAST(giltine_checkbox)
    giltine_checkbox:SetCheck(g.settings.giltine_checkbox)
    giltine_checkbox:SetEventScript(ui.LBUTTONUP, "indun_panel_ischecked")
    giltine_checkbox:SetTextTooltip("{@st59}チェックすると表示{nl}Check to show")

    local earring = ipframe:CreateOrGetControl("richtext", "earring", 15, 525)
    earring:SetText("{ol}{#FFFFFF}" .. INDUN_PANEL_LANG("{s20}Earring"))
    earring:AdjustFontSizeByWidth(140)
    local earring_checkbox = ipframe:CreateOrGetControl('checkbox', 'earring_checkbox', 150, 525, 25, 25)
    AUTO_CAST(earring_checkbox)
    earring_checkbox:SetCheck(g.settings.earring_checkbox)
    earring_checkbox:SetEventScript(ui.LBUTTONUP, "indun_panel_ischecked")
    earring_checkbox:SetTextTooltip("{@st59}チェックすると表示{nl}Check to show")

    local cemetery = ipframe:CreateOrGetControl("richtext", "cemetery", 15, 565)
    cemetery:SetText("{ol}{#FFFFFF}" .. INDUN_PANEL_LANG("{s20}Wailing"))
    cemetery:AdjustFontSizeByWidth(140)
    local cemetery_checkbox = ipframe:CreateOrGetControl('checkbox', 'cemetery_checkbox', 150, 565, 25, 25)
    AUTO_CAST(cemetery_checkbox)
    cemetery_checkbox:SetCheck(g.settings.cemetery_checkbox)
    cemetery_checkbox:SetEventScript(ui.LBUTTONUP, "indun_panel_ischecked")
    cemetery_checkbox:SetTextTooltip("{@st59}チェックすると表示{nl}Check to show")

    local jsr = ipframe:CreateOrGetControl("richtext", "jsr", 15, 605)

    jsr:SetText("{ol}{#FFFFFF}" .. INDUN_PANEL_LANG("{s20}JS Raid"))
    jsr:AdjustFontSizeByWidth(140)
    local jsr_checkbox = ipframe:CreateOrGetControl('checkbox', 'jsr_checkbox', 150, 605, 25, 25)
    AUTO_CAST(jsr_checkbox)
    jsr_checkbox:SetCheck(g.settings.jsr_checkbox)
    jsr_checkbox:SetEventScript(ui.LBUTTONUP, "indun_panel_ischecked")
    jsr_checkbox:SetTextTooltip("{@st59}チェックすると表示{nl}Check to show")

end

function indun_panel_ischecked(frame, ctrl, argStr, argNum)

    local ischeck = ctrl:IsChecked();
    local ctrlname = ctrl:GetName()

    if ischeck == 1 and ctrlname == "Singularity_check" then
        g.settings.Singularity_check = 1
        indun_panel_save_settings()
    elseif ischeck == 0 and ctrlname == "Singularity_check" then
        g.settings.Singularity_check = 0
        indun_panel_save_settings()
    end

    if ischeck == 1 and ctrlname == "en_ver" then
        g.settings.en_ver = 1
        indun_panel_save_settings()
    elseif ischeck == 0 and ctrlname == "en_ver" then
        g.settings.en_ver = 0
        indun_panel_save_settings()
    end

    if ischeck == 1 and ctrlname == "cemetery_checkbox" then
        g.settings.cemetery_checkbox = 1
        indun_panel_save_settings()
    elseif ischeck == 0 and ctrlname == "cemetery_checkbox" then
        g.settings.cemetery_checkbox = 0
        indun_panel_save_settings()
    end

    if ischeck == 1 and ctrlname == "earring_checkbox" then
        g.settings.earring_checkbox = 1
        indun_panel_save_settings()
    elseif ischeck == 0 and ctrlname == "earring_checkbox" then
        g.settings.earring_checkbox = 0
        indun_panel_save_settings()
    end

    if ischeck == 1 and ctrlname == "giltine_checkbox" then
        g.settings.giltine_checkbox = 1
        indun_panel_save_settings()
    elseif ischeck == 0 and ctrlname == "giltine_checkbox" then
        g.settings.giltine_checkbox = 0
        indun_panel_save_settings()
    end

    if ischeck == 1 and ctrlname == "velnice_checkbox" then
        g.settings.velnice_checkbox = 1
        indun_panel_save_settings()
    elseif ischeck == 0 and ctrlname == "velnice_checkbox" then
        g.settings.velnice_checkbox = 0
        indun_panel_save_settings()
    end

    if ischeck == 1 and ctrlname == "telharsha_checkbox" then
        g.settings.telharsha_checkbox = 1
        indun_panel_save_settings()
    elseif ischeck == 0 and ctrlname == "telharsha_checkbox" then
        g.settings.telharsha_checkbox = 0
        indun_panel_save_settings()
    end

    if ischeck == 1 and ctrlname == "delmore_checkbox" then
        g.settings.delmore_checkbox = 1
        indun_panel_save_settings()
    elseif ischeck == 0 and ctrlname == "delmore_checkbox" then
        g.settings.delmore_checkbox = 0
        indun_panel_save_settings()
    end

    if ischeck == 1 and ctrlname == "jellyzele_checkbox" then
        g.settings.jellyzele_checkbox = 1
        indun_panel_save_settings()
    elseif ischeck == 0 and ctrlname == "jellyzele_checkbox" then
        g.settings.jellyzele_checkbox = 0
        indun_panel_save_settings()
    end

    if ischeck == 1 and ctrlname == "spreader_checkbox" then
        g.settings.spreader_checkbox = 1
        indun_panel_save_settings()
    elseif ischeck == 0 and ctrlname == "spreader_checkbox" then
        g.settings.spreader_checkbox = 0
        indun_panel_save_settings()
    end

    if ischeck == 1 and ctrlname == "falouros_checkbox" then
        g.settings.falouros_checkbox = 1
        indun_panel_save_settings()
    elseif ischeck == 0 and ctrlname == "falouros_checkbox" then
        g.settings.falouros_checkbox = 0
        indun_panel_save_settings()
    end

    if ischeck == 1 and ctrlname == "roze_checkbox" then
        g.settings.roze_checkbox = 1
        indun_panel_save_settings()
    elseif ischeck == 0 and ctrlname == "roze_checkbox" then
        g.settings.roze_checkbox = 0
        indun_panel_save_settings()
    end

    if ischeck == 1 and ctrlname == "Upinis_checkbox" then
        g.settings.Upinis_checkbox = 1
        indun_panel_save_settings()
    elseif ischeck == 0 and ctrlname == "Upinis_checkbox" then
        g.settings.Upinis_checkbox = 0
        indun_panel_save_settings()
    end

    if ischeck == 1 and ctrlname == "Slogutis_checkbox" then
        g.settings.Slogutis_checkbox = 1
        indun_panel_save_settings()
    elseif ischeck == 0 and ctrlname == "Slogutis_checkbox" then
        g.settings.Slogutis_checkbox = 0
        indun_panel_save_settings()
    end

    if ischeck == 1 and ctrlname == "challengeex_checkbox" then
        g.settings.challengeex_checkbox = 1
        indun_panel_save_settings()
    elseif ischeck == 0 and ctrlname == "challengeex_checkbox" then
        g.settings.challengeex_checkbox = 0
        indun_panel_save_settings()
    end

    if ischeck == 1 and ctrlname == "challenge_checkbox" then
        g.settings.challenge_checkbox = 1
        indun_panel_save_settings()
    elseif ischeck == 0 and ctrlname == "challenge_checkbox" then
        g.settings.challenge_checkbox = 0
        indun_panel_save_settings()
    end

    if ischeck == 1 and ctrlname == "jsr_checkbox" then
        g.settings.jsr_checkbox = 1
        indun_panel_save_settings()
    elseif ischeck == 0 and ctrlname == "jsr_checkbox" then
        g.settings.jsr_checkbox = 0
        indun_panel_save_settings()
    end
    indun_panel_load_settings()
end
function indun_panel_upinis_frame(ipframe)
    local Upinis = ipframe:CreateOrGetControl("richtext", "Upinis", 15, g.panelY)
    Upinis:SetText("{ol}{#FFFFFF}" .. INDUN_PANEL_LANG("{s20}Upinis"))
    Upinis:AdjustFontSizeByWidth(120)
    local upinissolo = ipframe:CreateOrGetControl('button', 'upinissolo', 135, g.panelY, 80, 30)
    local upinisauto = ipframe:CreateOrGetControl('button', 'upinisauto', 220, g.panelY, 80, 30)
    local upinishard = ipframe:CreateOrGetControl('button', 'upinishard', 350, g.panelY, 80, 30)
    local upiniscount = ipframe:CreateOrGetControl("richtext", "upiniscount", 305, g.panelY + 5, 50, 30)
    local upiniscounthard = ipframe:CreateOrGetControl("richtext", "upiniscounthard", 435, g.panelY + 5, 50, 30)
    local upinissweep = ipframe:CreateOrGetControl('button', 'upinissweep', 480, g.panelY, 80, 30)

    upinissolo:SetText("{ol}SOLO")
    upinisauto:SetText("{ol}{#FFD900}AUTO")
    upinishard:SetText("{ol}{#FF0000}HARD")
    upinissweep:SetText("{ol}{#00FF00}" .. INDUN_PANEL_LANG("ACLEAR")) -- 掃蕩
    -- upinissweep:SetText("{ol}{#00FF00}{s10}AUTOCLEAR")

    upiniscount:SetText("{ol}{#FFFFFF}{s16}(" ..
                            GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 686).PlayPerResetType) .. "/" ..
                            GET_INDUN_MAX_ENTERANCE_COUNT(GetClassByType("Indun", 686).PlayPerResetType) .. ")")
    upiniscounthard:SetText("{ol}{#FFFFFF}{s16}(" ..
                                GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 687).PlayPerResetType) .. "/" ..
                                GET_INDUN_MAX_ENTERANCE_COUNT(GetClassByType("Indun", 687).PlayPerResetType) .. ")")
    --[[ upiniscounthard:SetText("{ol}{#FFFFFF}{s16}(" ..
                                  GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 628).PlayPerResetType) .. ")")

    -- upinissolo:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_upinis_solo")
    upinissolo:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_solo")
    upinissolo:SetEventScriptArgNumber(ui.LBUTTONUP, 686)

    -- upinisauto:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_upinis_auto")
    upinisauto:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_auto")
    upinisauto:SetEventScriptArgNumber(ui.LBUTTONUP, 685)

    upinissweep:SetEventScript(ui.LBUTTONUP, "indun_panel_autosweep")
    upinissweep:SetEventScriptArgNumber(ui.LBUTTONUP, 685)

    local upinissweepcount = ipframe:CreateOrGetControl("richtext", "upinissweepcount", 565, g.panelY + 5, 50, 30)
    upinissweepcount:SetText("{ol}{#FFFFFF}{s16}(" .. indun_panel_sweep_count(80030) .. ")")

    upinishard:SetEventScript(ui.LBUTTONDOWN, "indun_panel_enter_hard")
    upinishard:SetEventScriptArgNumber(ui.LBUTTONDOWN, 687)
    upinishard:SetEventScriptArgString(ui.LBUTTONDOWN, "false")

end

function indun_panel_slogutis_frame(ipframe)
    local Slogutis = ipframe:CreateOrGetControl("richtext", "Slogutis", 15, g.panelY)
    Slogutis:SetText("{ol}{#FFFFFF}" .. INDUN_PANEL_LANG("{s20}Slogutis"))
    Slogutis:AdjustFontSizeByWidth(120)

    local slogutissolo = ipframe:CreateOrGetControl('button', 'slogutissolo', 135, g.panelY, 80, 30)
    local slogutisauto = ipframe:CreateOrGetControl('button', 'slogutisauto', 220, g.panelY, 80, 30)
    local slogutishard = ipframe:CreateOrGetControl('button', 'slogutishard', 350, g.panelY, 80, 30)
    local slogutiscount = ipframe:CreateOrGetControl("richtext", "slogutiscount", 305, g.panelY + 5, 50, 30)
    local slogutiscounthard = ipframe:CreateOrGetControl("richtext", "slogutiscounthard", 435, g.panelY + 5, 50, 30)
    local slogutissweep = ipframe:CreateOrGetControl('button', 'slogutissweep', 480, g.panelY, 80, 30)

    slogutissolo:SetText("{ol}SOLO")
    slogutisauto:SetText("{ol}{#FFD900}AUTO")
    slogutishard:SetText("{ol}{#FF0000}HARD")
    slogutissweep:SetText("{ol}{#00FF00}" .. INDUN_PANEL_LANG("ACLEAR"))

    slogutiscount:SetText("{ol}{#FFFFFF}{s16}(" ..
                              GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 689).PlayPerResetType) .. "/" ..
                              GET_INDUN_MAX_ENTERANCE_COUNT(GetClassByType("Indun", 689).PlayPerResetType) .. ")")
    slogutiscounthard:SetText("{ol}{#FFFFFF}{s16}(" ..
                                  GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 690).PlayPerResetType) .. "/" ..
                                  GET_INDUN_MAX_ENTERANCE_COUNT(GetClassByType("Indun", 690).PlayPerResetType) .. ")")

    slogutissolo:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_solo")
    slogutissolo:SetEventScriptArgNumber(ui.LBUTTONUP, 689)

    slogutisauto:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_auto")
    slogutisauto:SetEventScriptArgNumber(ui.LBUTTONUP, 688)

    slogutissweep:SetEventScript(ui.LBUTTONUP, "indun_panel_autosweep")
    slogutissweep:SetEventScriptArgNumber(ui.LBUTTONUP, 688)

    local slogutissweepcount = ipframe:CreateOrGetControl("richtext", "slogutissweepcount", 565, g.panelY + 5, 50, 30)
    slogutissweepcount:SetText("{ol}{#FFFFFF}{s16}(" .. indun_panel_sweep_count(80031) .. ")")

    slogutishard:SetEventScript(ui.LBUTTONDOWN, "indun_panel_enter_hard")
    slogutishard:SetEventScriptArgNumber(ui.LBUTTONDOWN, 690)
    slogutishard:SetEventScriptArgString(ui.LBUTTONDOWN, "false")

end
function indun_panel_spreader_frame(ipframe)
    local spreader = ipframe:CreateOrGetControl("richtext", "spreader", 15, g.panelY)
    spreader:SetText("{ol}{#FFFFFF}" .. INDUN_PANEL_LANG("{s20}Spreader"))
    spreader:AdjustFontSizeByWidth(120)

    local spreadersolo = ipframe:CreateOrGetControl('button', 'spreadersolo', 135, g.panelY, 80, 30)
    local spreaderauto = ipframe:CreateOrGetControl('button', 'spreaderauto', 220, g.panelY, 80, 30)
    local spreaderhard = ipframe:CreateOrGetControl('button', 'spreaderhard', 350, g.panelY, 80, 30)
    local spreadercount = ipframe:CreateOrGetControl("richtext", "spreadercount", 305, g.panelY + 5, 50, 30)
    local spreadercounthard = ipframe:CreateOrGetControl("richtext", "spreadercounthard", 435, g.panelY + 5, 50, 30)
    local spreadersweep = ipframe:CreateOrGetControl('button', 'spreadersweep', 480, g.panelY, 80, 30)

    spreadersolo:SetText("{ol}SOLO")
    spreaderauto:SetText("{ol}{#FFD900}AUTO")
    spreaderhard:SetText("{ol}{#FF0000}HARD")
    spreadersweep:SetText("{ol}{#00FF00}" .. INDUN_PANEL_LANG("ACLEAR"))

    spreadercount:SetText("{ol}{#FFFFFF}{s16}(" ..
                              GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 676).PlayPerResetType) .. "/" ..
                              GET_INDUN_MAX_ENTERANCE_COUNT(GetClassByType("Indun", 676).PlayPerResetType) .. ")")
    spreadercounthard:SetText("{ol}{#FFFFFF}{s16}(" ..
                                  GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 678).PlayPerResetType) .. "/" ..
                                  GET_INDUN_MAX_ENTERANCE_COUNT(GetClassByType("Indun", 678).PlayPerResetType) .. ")")

    spreadersolo:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_solo")
    spreadersolo:SetEventScriptArgNumber(ui.LBUTTONUP, 674)

    spreaderauto:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_auto")
    spreaderauto:SetEventScriptArgNumber(ui.LBUTTONUP, 673)

    spreaderhard:SetEventScript(ui.LBUTTONDOWN, "indun_panel_enter_hard")
    spreaderhard:SetEventScriptArgNumber(ui.LBUTTONDOWN, 675)
    spreaderhard:SetEventScriptArgString(ui.LBUTTONDOWN, "false")

    spreadersweep:SetEventScript(ui.LBUTTONUP, "indun_panel_autosweep")
    spreadersweep:SetEventScriptArgNumber(ui.LBUTTONUP, 673)

    local spreadersweepcount = ipframe:CreateOrGetControl("richtext", "spreadersweepcount", 565, g.panelY + 5, 50, 30)
    spreadersweepcount:SetText("{ol}{#FFFFFF}{s16}(" .. indun_panel_sweep_count(80016) .. ")")

end

-- ファロウロス処理
function indun_panel_falo_frame(ipframe)
    local falouros = ipframe:CreateOrGetControl("richtext", "falouros", 15, g.panelY)
    falouros:SetText("{ol}{#FFFFFF}" .. INDUN_PANEL_LANG("{s20}Falouros"))
    falouros:AdjustFontSizeByWidth(120)

    local falosolo = ipframe:CreateOrGetControl('button', 'falosolo', 135, g.panelY, 80, 30)
    local faloauto = ipframe:CreateOrGetControl('button', 'faloauto', 220, g.panelY, 80, 30)
    local falohard = ipframe:CreateOrGetControl('button', 'falohard', 350, g.panelY, 80, 30)
    local falocount = ipframe:CreateOrGetControl("richtext", "falocount", 305, g.panelY + 5, 50, 30)
    local falocounthard = ipframe:CreateOrGetControl("richtext", "falocounthard", 435, g.panelY + 5, 50, 30)
    local falosweep = ipframe:CreateOrGetControl('button', 'falosweep', 480, g.panelY, 80, 30)

    falosolo:SetText("{ol}SOLO")
    faloauto:SetText("{ol}{#FFD900}AUTO")
    falohard:SetText("{ol}{#FF0000}HARD")
    falosweep:SetText("{ol}{#00FF00}" .. INDUN_PANEL_LANG("ACLEAR"))

    falocount:SetText("{ol}{#FFFFFF}{s16}(" ..
                          GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 676).PlayPerResetType) .. "/" ..
                          GET_INDUN_MAX_ENTERANCE_COUNT(GetClassByType("Indun", 676).PlayPerResetType) .. ")")
    falocounthard:SetText("{ol}{#FFFFFF}{s16}(" ..
                              GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 678).PlayPerResetType) .. "/" ..
                              GET_INDUN_MAX_ENTERANCE_COUNT(GetClassByType("Indun", 678).PlayPerResetType) .. ")")

    falosolo:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_solo")
    falosolo:SetEventScriptArgNumber(ui.LBUTTONUP, 677)

    faloauto:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_auto")
    faloauto:SetEventScriptArgNumber(ui.LBUTTONUP, 676)

    falohard:SetEventScript(ui.LBUTTONDOWN, "indun_panel_enter_hard")
    falohard:SetEventScriptArgNumber(ui.LBUTTONDOWN, 678)
    falohard:SetEventScriptArgString(ui.LBUTTONDOWN, "false")

    falosweep:SetEventScript(ui.LBUTTONUP, "indun_panel_autosweep")
    falosweep:SetEventScriptArgNumber(ui.LBUTTONUP, 676)

    local falosweepcount = ipframe:CreateOrGetControl("richtext", "falosweepcount", 565, g.panelY + 5, 50, 30)
    falosweepcount:SetText("{ol}{#FFFFFF}{s16}(" .. indun_panel_sweep_count(80017) .. ")")

end

-- ロゼ処理
function indun_panel_roze_frame(ipframe)
    local roze = ipframe:CreateOrGetControl("richtext", "roze", 15, g.panelY)
    roze:SetText("{ol}{#FFFFFF}" .. INDUN_PANEL_LANG("{s20}Roze"))
    roze:AdjustFontSizeByWidth(120)

    local rozesolo = ipframe:CreateOrGetControl('button', 'rozesolo', 135, g.panelY, 80, 30)
    local rozeauto = ipframe:CreateOrGetControl('button', 'rozeauto', 220, g.panelY, 80, 30)
    local rozehard = ipframe:CreateOrGetControl('button', 'rozehard', 350, g.panelY, 80, 30)
    local rozecount = ipframe:CreateOrGetControl("richtext", "rozecount", 305, g.panelY + 5, 50, 30)
    local rozecounthard = ipframe:CreateOrGetControl("richtext", "rozecounthard", 435, g.panelY + 5, 50, 30)
    local rozesweep = ipframe:CreateOrGetControl('button', 'rozesweep', 480, g.panelY, 80, 30)

    rozesolo:SetText("{ol}SOLO")
    rozeauto:SetText("{ol}{#FFD900}AUTO")
    rozehard:SetText("{ol}{#FF0000}HARD")
    rozesweep:SetText("{ol}{#00FF00}" .. INDUN_PANEL_LANG("ACLEAR"))

    rozecount:SetText("{ol}{#FFFFFF}{s16}(" ..
                          GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 679).PlayPerResetType) .. "/" ..
                          GET_INDUN_MAX_ENTERANCE_COUNT(GetClassByType("Indun", 679).PlayPerResetType) .. ")")
    rozecounthard:SetText("{ol}{#FFFFFF}{s16}(" ..
                              GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 681).PlayPerResetType) .. "/" ..
                              GET_INDUN_MAX_ENTERANCE_COUNT(GetClassByType("Indun", 681).PlayPerResetType) .. ")")

    rozesolo:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_solo")
    rozesolo:SetEventScriptArgNumber(ui.LBUTTONUP, 680)

    rozeauto:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_auto")
    rozeauto:SetEventScriptArgNumber(ui.LBUTTONUP, 679)

    rozehard:SetEventScript(ui.LBUTTONDOWN, "indun_panel_enter_hard")
    rozehard:SetEventScriptArgNumber(ui.LBUTTONDOWN, 681)
    rozehard:SetEventScriptArgString(ui.LBUTTONDOWN, "false")

    rozesweep:SetEventScript(ui.LBUTTONUP, "indun_panel_autosweep")
    rozesweep:SetEventScriptArgNumber(ui.LBUTTONUP, 679)

    local rozesweepcount = ipframe:CreateOrGetControl("richtext", "rozesweepcount", 565, g.panelY + 5, 50, 30)
    rozesweepcount:SetText("{ol}{#FFFFFF}{s16}(" .. indun_panel_sweep_count(80015) .. ")")

end
-- イヤリングレイド処理
function indun_panel_earring_frame(ipframe)
    local earring = ipframe:CreateOrGetControl("richtext", "earring", 15, g.panelY)
    earring:SetText("{ol}{#FFFFFF}" .. INDUN_PANEL_LANG("{s20}Earring"))
    earring:AdjustFontSizeByWidth(120)

    local earringsolo = ipframe:CreateOrGetControl('button', 'earringsolo', 135, g.panelY, 80, 30)
    local earringnormal = ipframe:CreateOrGetControl('button', 'earringauto', 220, g.panelY, 80, 30)
    local earringhard = ipframe:CreateOrGetControl('button', 'earringhard', 305, g.panelY, 80, 30)
    local earringcounthard = ipframe:CreateOrGetControl("richtext", "earringcounthard", 390, g.panelY + 5, 50, 30)

    earringsolo:SetText("{ol}SOLO")
    earringnormal:SetText("{ol}{s14}NORMAL")
    earringhard:SetText("{ol}{#FF0000}HARD")

    earringcounthard:SetText("{ol}{#FFFFFF}{s16}(" ..
                                 GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 663).PlayPerResetType) .. ")")

    earringsolo:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_solo")
    earringsolo:SetEventScriptArgNumber(ui.LBUTTONUP, 661)

    earringnormal:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_solo")
    earringnormal:SetEventScriptArgNumber(ui.LBUTTONUP, 662)

    earringhard:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_solo")
    earringhard:SetEventScriptArgNumber(ui.LBUTTONUP, 663)
    ipframe:ShowWindow(1)

end

-- ギルティネレイド処理
function indun_panel_giltine_frame(ipframe)
    local giltine = ipframe:CreateOrGetControl("richtext", "giltine", 15, g.panelY)
    giltine:SetText("{ol}{#FFFFFF}" .. INDUN_PANEL_LANG("{s20}Giltine"))
    giltine:AdjustFontSizeByWidth(120)

    local giltinesolo = ipframe:CreateOrGetControl('button', 'giltinesolo', 135, g.panelY, 80, 30)
    local giltineauto = ipframe:CreateOrGetControl('button', 'giltineauto', 220, g.panelY, 80, 30)
    local giltinehard = ipframe:CreateOrGetControl('button', 'giltinehard', 350, g.panelY, 80, 30)
    local giltinecount = ipframe:CreateOrGetControl("richtext", "giltinecount", 305, g.panelY + 5, 50, 30)
    local giltinecounthard = ipframe:CreateOrGetControl("richtext", "giltinecounthard", 435, g.panelY + 5, 50, 30)

    giltinesolo:SetText("{ol}SOLO")
    giltineauto:SetText("{ol}{#FFD900}AUTO")
    giltinehard:SetText("{ol}{#FF0000}HARD")

    giltinecount:SetText("{ol}{#FFFFFF}{s16}(" ..
                             GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 635).PlayPerResetType) .. "/" ..
                             GET_INDUN_MAX_ENTERANCE_COUNT(GetClassByType("Indun", 635).PlayPerResetType) .. ")")
    giltinecounthard:SetText("{ol}{#FFFFFF}{s16}(" ..
                                 GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 628).PlayPerResetType) .. ")")

    giltinesolo:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_solo")
    giltinesolo:SetEventScriptArgNumber(ui.LBUTTONUP, 669)

    giltineauto:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_auto")
    giltineauto:SetEventScriptArgNumber(ui.LBUTTONUP, 635)

    giltinehard:SetEventScript(ui.LBUTTONDOWN, "indun_panel_enter_hard")
    giltinehard:SetEventScriptArgNumber(ui.LBUTTONDOWN, 628)
    giltinehard:SetEventScriptArgString(ui.LBUTTONDOWN, "false")
end

-- デルムーア処理
function indun_panel_Delmore_frame(ipframe)
    local delmore = ipframe:CreateOrGetControl("richtext", "delmore", 15, g.panelY)
    delmore:SetText("{ol}{#FFFFFF}" .. INDUN_PANEL_LANG("{s20}Delmore"))
    delmore:AdjustFontSizeByWidth(120)

    local Delmoresolo = ipframe:CreateOrGetControl('button', 'Delmoresolo', 135, g.panelY, 80, 30)
    local Delmoreauto = ipframe:CreateOrGetControl('button', 'Delmoreauto', 220, g.panelY, 80, 30)
    local Delmorehard = ipframe:CreateOrGetControl('button', 'Delmorehard', 350, g.panelY, 80, 30)
    local Delmorecount = ipframe:CreateOrGetControl("richtext", "Delmorecount", 305, g.panelY + 5, 50, 30)
    local Delmorecounthard = ipframe:CreateOrGetControl("richtext", "Delmorecounthard", 435, g.panelY + 5, 50, 30)

    Delmoresolo:SetText("{ol}SOLO")
    Delmoreauto:SetText("{ol}{#FFD900}AUTO")
    Delmorehard:SetText("{ol}{#FF0000}HARD")

    Delmorecount:SetText("{ol}{#FFFFFF}{s16}(" ..
                             GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 667).PlayPerResetType) .. "/" ..
                             GET_INDUN_MAX_ENTERANCE_COUNT(GetClassByType("Indun", 667).PlayPerResetType) .. ")")
    Delmorecounthard:SetText("{ol}{#FFFFFF}{s16}(" ..
                                 GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 665).PlayPerResetType) .. "/" ..
                                 GET_INDUN_MAX_ENTERANCE_COUNT(GetClassByType("Indun", 665).PlayPerResetType) .. ")")

    Delmoresolo:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_solo")
    Delmoresolo:SetEventScriptArgNumber(ui.LBUTTONUP, 667)

    Delmoreauto:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_auto")
    Delmoreauto:SetEventScriptArgNumber(ui.LBUTTONUP, 666)

    Delmorehard:SetEventScript(ui.LBUTTONDOWN, "indun_panel_enter_hard")
    Delmorehard:SetEventScriptArgNumber(ui.LBUTTONDOWN, 665)
    Delmorehard:SetEventScriptArgString(ui.LBUTTONDOWN, "false")

end

-- クラゲ処理
function indun_panel_jellyzele_frame(ipframe)
    local jellyzele = ipframe:CreateOrGetControl("richtext", "jellyzele", 15, g.panelY)
    jellyzele:SetText("{ol}{#FFFFFF}" .. INDUN_PANEL_LANG("{s20}Jellyzele"))
    jellyzele:AdjustFontSizeByWidth(120)

    local jellyzelesolo = ipframe:CreateOrGetControl('button', 'jellyzelesolo', 135, g.panelY, 80, 30)
    local jellyzeleauto = ipframe:CreateOrGetControl('button', 'jellyzeleauto', 220, g.panelY, 80, 30)
    local jellyzelehard = ipframe:CreateOrGetControl('button', 'jellyzelehard', 350, g.panelY, 80, 30)
    local jellyzelecount = ipframe:CreateOrGetControl("richtext", "jellyzelecount", 305, g.panelY + 5, 50, 30)
    local jellyzelecounthard = ipframe:CreateOrGetControl("richtext", "jellyzelecounthard", 435, g.panelY + 5, 50, 30)

    jellyzelesolo:SetText("{ol}SOLO")
    jellyzeleauto:SetText("{ol}{#FFD900}AUTO")
    jellyzelehard:SetText("{ol}{#FF0000}HARD")

    jellyzelecount:SetText("{ol}{#FFFFFF}{s16}(" ..
                               GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 672).PlayPerResetType) .. "/" ..
                               GET_INDUN_MAX_ENTERANCE_COUNT(GetClassByType("Indun", 672).PlayPerResetType) .. ")")
    jellyzelecounthard:SetText("{ol}{#FFFFFF}{s16}(" ..
                                   GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 670).PlayPerResetType) .. "/" ..
                                   GET_INDUN_MAX_ENTERANCE_COUNT(GetClassByType("Indun", 670).PlayPerResetType) .. ")")

    jellyzelesolo:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_solo")
    jellyzelesolo:SetEventScriptArgNumber(ui.LBUTTONUP, 672)

    jellyzeleauto:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_auto")
    jellyzeleauto:SetEventScriptArgNumber(ui.LBUTTONUP, 671)

    jellyzelehard:SetEventScript(ui.LBUTTONDOWN, "indun_panel_enter_hard")
    jellyzelehard:SetEventScriptArgNumber(ui.LBUTTONDOWN, 670)
    jellyzelehard:SetEventScriptArgString(ui.LBUTTONDOWN, "false")

end

-- プロパゲ処理
function indun_panel_jsr_update()
    local jsrframe = ui.GetFrame("induninfo")

    local frame = ui.GetFrame(addonNameLower)

    local jsrtime_start = GET_CHILD_RECURSIVELY(frame, "jsrtime_start")
    local msg = indun_panel_FIELD_BOSS_ENTER_TIMER_SETTING(jsrframe)
    jsrtime_start:SetText("{ol}" .. msg)

    return 1

end

-- チェックボックスの状況監視
function indun_panel_checkbox_toggle()
    local ipframe = ui.GetFrame(g.framename)
    local checkbox = GET_CHILD_RECURSIVELY(ipframe, "checkbox")
    tolua.cast(checkbox, 'ui::CCheckBox')
    local ischeck = checkbox:IsChecked();

    if ischeck == 1 then
        g.settings.ischecked = 1
        indun_panel_save_settings()
    elseif ischeck == 0 then
        g.settings.ischecked = 0
        indun_panel_save_settings()
    end

end
-- ハード入場時の二度押し回避
function INDUN_PANEL_INDUNINFO_SET_BUTTONS(indunType)

    local frame = ui.GetFrame("indun_panel")
    local indunCls = GetClassByType('Indun', indunType)
    local dungeonType = TryGetProp(indunCls, "DungeonType", "None");
    local btnInfoCls = GetClassByStrProp("IndunInfoButton", "DungeonType", dungeonType);

    if dungeonType == "Raid" then

        btnInfoCls = INDUNINFO_SET_BUTTONS_FIND_CLASS(indunCls);

    end

    local redButtonScp = TryGetProp(btnInfoCls, "RedButtonScp")
    local redButton -- 変数の宣言を条件分岐の外に移動

    if redButtonScp ~= 'None' then

        if indunType == 665 then
            redButton = GET_CHILD_RECURSIVELY(frame, "delmorehard")
            redButton:SetUserValue('MOVE_INDUN_CLASSID', indunCls.ClassID);
            redButton:SetEventScript(ui.LBUTTONUP, redButtonScp)

        elseif indunType == 670 then
            redButton = GET_CHILD_RECURSIVELY(frame, "jellyzelehard")
            redButton:SetUserValue('MOVE_INDUN_CLASSID', indunCls.ClassID);
            redButton:SetEventScript(ui.LBUTTONUP, redButtonScp)
        elseif indunType == 675 then
            redButton = GET_CHILD_RECURSIVELY(frame, "spreaderhard")
            redButton:SetUserValue('MOVE_INDUN_CLASSID', indunCls.ClassID);
            redButton:SetEventScript(ui.LBUTTONUP, redButtonScp)
        elseif indunType == 678 then
            redButton = GET_CHILD_RECURSIVELY(frame, "falohard")
            redButton:SetUserValue('MOVE_INDUN_CLASSID', indunCls.ClassID);
            redButton:SetEventScript(ui.LBUTTONUP, redButtonScp)
        elseif indunType == 681 then
            redButton = GET_CHILD_RECURSIVELY(frame, "rozehard")
            redButton:SetUserValue('MOVE_INDUN_CLASSID', indunCls.ClassID);
            redButton:SetEventScript(ui.LBUTTONUP, redButtonScp)
        elseif indunType == 628 then
            redButton = GET_CHILD_RECURSIVELY(frame, "giltinehard")
            redButton:SetUserValue('MOVE_INDUN_CLASSID', indunCls.ClassID);
            redButton:SetEventScript(ui.LBUTTONUP, redButtonScp)
        elseif indunType == 687 then
            redButton = GET_CHILD_RECURSIVELY(frame, "upinishard")
            redButton:SetUserValue('MOVE_INDUN_CLASSID', indunCls.ClassID);
            redButton:SetEventScript(ui.LBUTTONUP, redButtonScp)
        elseif indunType == 690 then
            redButton = GET_CHILD_RECURSIVELY(frame, "slogutishard")
            redButton:SetUserValue('MOVE_INDUN_CLASSID', indunCls.ClassID);
            redButton:SetEventScript(ui.LBUTTONUP, redButtonScp)
        else
            return;
        end

    end

end
function indun_panel_autosweep(frame, ctrl, argStr, argNum)
    local indun_classid = tonumber(argNum);
    local BuffID = 0

    if argNum == 673 then -- プロパゲオート
        BuffID = 80016
    elseif argNum == 676 then -- ファロオート
        BuffID = 80017
    elseif argNum == 679 then -- ロゼオート
        BuffID = 80015
    elseif argNum == 685 then -- 蝶々
        BuffID = 80030
    elseif argNum == 688 then -- スロガ
        BuffID = 80031

    end

    local sweepcount = 0
    sweepcount = indun_panel_sweep_count(BuffID)
    if sweepcount >= 1 then
        ReqUseRaidAutoSweep(indun_classid);

    else
        ui.SysMsg("Does not have a sweeping buff")

    end

end
function indun_panel_item_use(frame, ctrl, argStr, argNum)

    session.ResetItemList()
    local invItemList = session.GetInvItemList()
    local guidList = invItemList:GetGuidList();
    local cnt = guidList:Count();

    -- TOSコイン分裂券＝10820018
    -- 1日券＝11030067
    -- トレード不可＝11030021
    -- トレード可＝11030017
    if argNum == 647 then

        for i = 0, cnt - 1 do
            local guid = guidList:Get(i);
            local invItem = invItemList:GetItemByGuid(guid)
            local itemobj = GetIES(invItem:GetObject())
            local classid = itemobj.ClassID
            local life_time = GET_REMAIN_ITEM_LIFE_TIME(itemobj)

            if life_time ~= nil then

                if classid == 10820018 and GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 647).PlayPerResetType) ==
                    0 and tonumber(life_time) < 86400 then

                    INV_ICON_USE(session.GetInvItemByType(tonumber(classid)))
                    return
                end

                if classid == 11030067 and GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 647).PlayPerResetType) ==
                    0 then

                    INV_ICON_USE(session.GetInvItemByType(tonumber(classid)))
                    return
                end
            end
        end

        local dcount = INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_41")
        if dcount == 1 and GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 647).PlayPerResetType) == 0 then
            indun_panel_singularity_buyuse()
            return
        end

        local wcount = INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_42")
        if wcount >= 1 and GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 647).PlayPerResetType) == 0 then
            indun_panel_singularity_buyuse()
            return
        end

        for i = 0, cnt - 1 do
            local guid = guidList:Get(i);
            local invItem = invItemList:GetItemByGuid(guid)
            local itemobj = GetIES(invItem:GetObject())
            local classid = itemobj.ClassID

            if classid == 10820018 and GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 647).PlayPerResetType) == 0 then
                INV_ICON_USE(session.GetInvItemByType(tonumber(classid)))
                return
            end

        end

        return

    elseif argNum == 644 then

        -- TOSコイン＝10820019
        -- 【A】チャレンジモード入場券(1回)＝641963　売れるヤツ
        -- 【B】チャレンジモード入場券(1回) (1日)＝641954　傭兵団のヤツ
        -- 【A】チャレンジモード入場券(1回)＝641987　多分売れへんヤツ
        -- 【A】チャレンジモード入場券(1回)＝641953　多分売れへんヤツ
        for i = 0, cnt - 1 do
            local guid = guidList:Get(i);
            local invItem = invItemList:GetItemByGuid(guid)
            local itemobj = GetIES(invItem:GetObject())
            local classid = itemobj.ClassID
            local life_time = GET_REMAIN_ITEM_LIFE_TIME(itemobj)

            if life_time ~= nil then
                if classid == 10820019 and GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 644).PlayPerResetType) ==
                    1 and tonumber(life_time) < 86400 then

                    INV_ICON_USE(session.GetInvItemByType(tonumber(classid)))
                    return
                end

                if classid == 641954 and GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 644).PlayPerResetType) == 1 then

                    INV_ICON_USE(session.GetInvItemByType(tonumber(classid)))
                    return
                end
            end
        end

        local count = INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_40")
        if count >= 1 and GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 644).PlayPerResetType) == 1 then
            indun_panel_challenge_buyuse()
            return
        end

        for i = 0, cnt - 1 do
            local guid = guidList:Get(i);
            local invItem = invItemList:GetItemByGuid(guid)
            local itemobj = GetIES(invItem:GetObject())
            local classid = itemobj.ClassID
            if classid == 10820019 and GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 644).PlayPerResetType) == 1 then
                INV_ICON_USE(session.GetInvItemByType(tonumber(classid)))
                return
            end
        end

        return
    end

end

function indun_panel_velnice_buyuse()

    if GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 201).PlayPerResetType) == 1 then
        local recipeName = "PVP_MINE_52"
        INDUN_PANEL_ITEM_BUY_USE(recipeName)
    else
        ui.SysMsg("The number of remains")
        return
    end

end

function indun_panel_singularity_buyuse()

    local dcount = INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_41")
    local wcount = INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_42")
    if GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 647).PlayPerResetType) == 0 then
        if dcount == 0 then
            local recipeName = "PVP_MINE_42"
            INDUN_PANEL_ITEM_BUY_USE(recipeName)
        else
            g.ex = 1
            local recipeName = "PVP_MINE_41"
            INDUN_PANEL_ITEM_BUY_USE(recipeName)

        end
    else
        ui.SysMsg("The number Challenge EX remains")
    end
end

function indun_panel_challenge_buyuse()

    if GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 646).PlayPerResetType) == 1 then
        local recipeName = "PVP_MINE_40"
        INDUN_PANEL_ITEM_BUY_USE(recipeName)
    else
        ui.SysMsg("The number of challenge remains")
    end
end

function INDUN_PANEL_ITEM_BUY_USE(recipeName)

    local vrecipecls = GetClass('ItemTradeShop', "PVP_MINE_52");
    local voverbuy_max = TryGetProp(vrecipecls, 'MaxOverBuyCount', 0)

    local count = INDUN_PANEL_GET_RECIPE_TRADE_COUNT(recipeName)
    if voverbuy_max >= 1 and recipeName == "PVP_MINE_52" then
        indun_panel_item_overbuy_use(vrecipecls)
        return

    elseif count <= 0 then
        ui.SysMsg("No trade count.")
        return
    end

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

function indun_panel_item_overbuy_use(recipeCls)

    session.ResetItemList()
    session.AddItemID(tostring(0), 1)
    local itemlist = session.GetItemIDList()
    local cntText = string.format("%s %s", tostring(recipeCls.ClassID), tostring(1))
    item.DialogTransaction("PVP_MINE_SHOP", itemlist, cntText)

    local itemCls = GetClass("Item", recipeCls.TargetItem)
    ReserveScript(string.format("INV_ICON_USE(session.GetInvItemByType(%d));", itemCls.ClassID), 1)
    return
end

-- インベントリをパネル上から開く
function INDUN_PANEL_INVENTORY_OPEN(frame)

    local frame = ui.GetFrame("inventory")
    frame:ShowWindow(1)
    frame:SetUserValue("MONCARDLIST_OPENED", 0);

    ui.Chat("/requpdateequip"); -- 내구도 회복 유료템 때문에 정확한 값을 지금 알아야 함.
    session.inventory.ReqTrustPoint();

    local savedPos = frame:GetUserValue("INVENTORY_CUR_SCROLL_POS");
    if savedPos == 'None' then
        savedPos = '0'
    end

    local tree_box = GET_CHILD_RECURSIVELY(frame, 'treeGbox_All')
    tree_box:SetScrollPos(tonumber(savedPos));

    session.CheckOpenInvCnt();
    ui.CloseFrame('layerscore');
    MAKE_WEAPON_SWAP_BUTTON();
    local questInfoSetFrame = ui.GetFrame('questinfoset_2');
    if questInfoSetFrame:IsVisible() == 1 then
        questInfoSetFrame:ShowWindow(0);
    end

    INV_HAT_VISIBLE_STATE(frame);
    INV_HAIR_WIG_VISIBLE_STATE(frame);

    local minimapFrame = ui.GetFrame('minimap');
    minimapFrame:ShowWindow(0);
end
-- 傭兵コインショップをパネル上から開く
function INDUN_PANEL_MINIMIZED_PVPMINE_SHOP_BUTTON_CLICK(parent, ctrl)
    local frame = ui.GetFrame('earthtowershop')
    if frame:IsVisible() == 1 then
        ui.CloseFrame('earthtowershop')
    end
    local invframe = ui.GetFrame('inventory')
    INDUN_PANEL_INVENTORY_OPEN(invframe)

    pc.ReqExecuteTx_NumArgs("SCR_PVP_MINE_SHOP_OPEN", 0);
    local strArg = "Entrance_Ticket"

    ReserveScript(string.format("DRAW_EXCHANGE_SHOP_IETMS('%s')", strArg), 0.2)
    return

end

-- 傭兵団コインショップ閉める
function INDUN_PANEL_EARTHTOWERSHOP_CLOSE(shopframe)
    local shopframe = ui.GetFrame('earthtowershop')
    ui.CloseFrame('earthtowershop')

end
]]
