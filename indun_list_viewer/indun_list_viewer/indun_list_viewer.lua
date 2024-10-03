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
local addonName = "indun_list_viewer"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.1.8"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)
local function unicode_to_codepoint(char)
    local codepoint = utf8.codepoint(char)
    return string.format("%X", codepoint)
end

local function convert_to_ascii(input)
    local result = ""
    for char in input:gmatch(utf8.charpattern) do
        result = result .. unicode_to_codepoint(char)
    end
    return result
end
-- テスト
local input = GETMYFAMILYNAME()
local output = convert_to_ascii(input)
g.new_settingsFileLoc = string.format('../addons/%s/%s.json', addonNameLower, output)

g.logpath = string.format('../addons/%s/log.txt', addonNameLower)

local acutil = require("acutil")
local os = require("os")
local json = require("json")
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

function indun_list_viewer_save_settings()
    acutil.saveJSON(g.new_settingsFileLoc, g.settings)
end

function indun_list_viewer_load_settings()
    local file = io.open(g.new_settingsFileLoc, "r")
    if file then
        local content = file:read("*all")
        file:close()

        g.settings = json.decode(content)
    else
        g.settings = {
            time = 1702846800,
            reset = false,
            mode = 0
        }
        indun_list_viewer_save_settings()
    end

    local accountInfo = session.barrack.GetMyAccount()
    local barrackPCCount = accountInfo:GetBarrackPCCount()

    for i = 0, barrackPCCount - 1 do
        local barrackPCInfo = accountInfo:GetBarrackPCByIndex(i)
        local barrackPCName = barrackPCInfo:GetName()

        local cnt = accountInfo:GetPCCount()
        for j = 0, cnt - 1 do
            local pcInfo = accountInfo:GetPCByIndex(j)
            local pcApc = pcInfo:GetApc()
            local pcName = pcApc:GetName()
            local pccid = pcInfo:GetCID()

            if barrackPCName == pcName then

                g.change[pcName] = pccid
                local changeFileLoc = string.format('../addons/%s/change.json', addonNameLower)
                acutil.saveJSON(changeFileLoc, g.change)

                if not g.settings[pccid] then
                    g.settings[pccid] = {
                        name = pcName,
                        layer = 9,
                        order = j,
                        hide = false,
                        memo = "",
                        president_jobid = "",
                        jobid = "",
                        count = {
                            S_H = "-",
                            S_N = "-",
                            U_H = "-",
                            U_N = "-",
                            R_H = "-",
                            R_N = "-",
                            T_H = "-",
                            T_N = "-",
                            M_H = "-",
                            M_N = "-",
                            R_S = "-",
                            T_S = "-",
                            U_S = "-",
                            S_S = "-",
                            M_S = "-"
                        }
                    }
                end

                if g.layer ~= nil and g.layer ~= g.settings[pccid].layer then
                    g.settings[pccid].layer = g.layer
                end

            end
        end
    end
    g.layer = nil

    indun_list_viewer_save_settings()

    g.sortedSettings = {}
    for pccid, data in pairs(g.settings) do
        if type(data) == "table" and data.layer and data.order then
            data.cid = pccid
            table.insert(g.sortedSettings, data)
        end
    end

    local function sortByLayerAndOrder(a, b)
        if a.layer ~= b.layer then
            return a.layer < b.layer
        else
            return a.order < b.order
        end
    end

    table.sort(g.sortedSettings, sortByLayerAndOrder)

    -- indun_list_viewer_get_raid_count()
    indun_list_viewer_frame_init()
    -- 並べ替え後の結果を表示（デバッグ用）
    --[[for _, data in ipairs(g.sortedSettings) do
        print(string.format("Name: %s, Order: %d, Layer: %d", data.name, data.order, data.layer))
    end]]

end

g.loaded = false
function INDUN_LIST_VIEWER_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame
    g.settings = g.settings or {}
    g.change = g.change or {}
    g.cid = session.GetMySession():GetCID();
    g.lang = option.GetCurrentCountry()

    local pc = GetMyPCObject();
    local curMap = GetZoneName(pc)
    local mapCls = GetClass("Map", curMap)
    if mapCls.MapType == "City" then

        addon:RegisterMsg('GAME_START', "indun_list_viewer_load_settings")
        g.SetupHook(indun_list_viewer_BARRACK_TO_GAME, "BARRACK_TO_GAME")
        acutil.setupEvent(addon, "STATUS_SELET_REPRESENTATION_CLASS",
            "indun_list_viewer_STATUS_SELET_REPRESENTATION_CLASS")
        -- addon:RegisterMsg('FPS_UPDATE', "indun_list_viewer_get_raid_count")
        acutil.setupEvent(addon, "APPS_TRY_LEAVE", "indun_list_viewer_get_raid_count")
        addon:RegisterMsg('GAME_START_3SEC', "indun_list_viewer_get_raid_count")
        if g.loaded == true then
            addon:RegisterMsg('GAME_START', "indun_list_viewer_raid_reset_time")
        end
        if g.loaded == false then
            g.loaded = true
        end
    end
end

--[[function indun_list_viewer_APPS_TRY_MOVE_BARRACK(frame, msg)

    frame:RunUpdateScript("indun_list_viewer_get_raid_count", 0.01)
end]]

function indun_list_viewer_BARRACK_TO_GAME()
    local frame = ui.GetFrame("barrack_charlist")
    local layer = tonumber(frame:GetUserValue("SelectBarrackLayer"))
    g.layer = layer
    local gsframe = ui.GetFrame("barrack_gamestart")
    local checkbtn = gsframe:GetChildRecursively("hidelogin")
    AUTO_CAST(checkbtn)
    checkbtn:SetCheck(1)
    barrack.SetHideLogin(1);
    base["BARRACK_TO_GAME"]()
end

function indun_list_viewer_STATUS_SELET_REPRESENTATION_CLASS(frame, msg)
    local selectedIndex, selectedKey = acutil.getEventArgs(msg)
    local mainSession = session.GetMainSession();
    local pcJobInfo = mainSession:GetPCJobInfo();
    local jobCount = pcJobInfo:GetJobCount();

    for i = 0, jobCount - 1 do
        local jobInfo = pcJobInfo:GetJobInfoByIndex(i);
        g.settings[g.cid].jobid = g.settings[g.cid].jobid .. "/" .. jobInfo.jobID
    end
    g.settings[g.cid].president_jobid = selectedKey
    indun_list_viewer_save_settings()
end

function indun_list_viewer_raid_reset_time()
    local currentTime = os.time()
    -- 今日の曜日を取得 (0: 日曜日, 1: 月曜日, ..., 6: 土曜日)
    local currentWeekday = tonumber(os.date("%w", currentTime))
    -- 月曜日からの日数を計算
    local daysUntilMonday = (currentWeekday + 7 - 1) % 7
    -- 今日の日付から daysUntilMonday を引く
    local targetDate = os.date("*t", currentTime - (daysUntilMonday * 24 * 60 * 60))
    targetDate.hour = 6
    targetDate.min = 0
    targetDate.sec = 0
    -- 月曜日の朝6時の日時を計算
    local mondayAM6 = os.time(targetDate)
    -- 月曜日が未来の日付の場合、前週の月曜日に変更
    if mondayAM6 > currentTime then
        targetDate = os.date("*t", mondayAM6 - (7 * 24 * 60 * 60))
        mondayAM6 = os.time(targetDate)
    end
    -- 経過時間を計算
    local elapsed_time = currentTime - g.settings.time
    local nextreset = 604800 -- 次の月曜日の6時までの秒数（1週間）

    if elapsed_time > nextreset then
        g.settings.time = mondayAM6

        indun_list_viewer_save_settings()
        indun_list_viewer_raid_reset()
        return
    end
end

function indun_list_viewer_raid_reset()
    local accountInfo = session.barrack.GetMyAccount()
    local barrackPCCount = accountInfo:GetBarrackPCCount()

    for i = 0, barrackPCCount - 1 do
        local barrackPCInfo = accountInfo:GetBarrackPCByIndex(i)
        local barrackPCName = barrackPCInfo:GetName()
        local cid = g.change[barrackPCName]

        if cid ~= nil then
            g.settings[cid]["count"] = {
                S_H = "-",
                S_N = "-",
                U_H = "-",
                U_N = "-",
                R_H = "-",
                R_N = "-",
                T_H = "-",
                T_N = "-",
                M_H = "-",
                M_N = "-",
                S_S = g.settings[cid]["count"].S_S or 0,
                U_S = g.settings[cid]["count"].U_S or 0,
                R_S = g.settings[cid]["count"].R_S or 0,
                T_S = g.settings[cid]["count"].T_S or 0,
                M_S = g.settings[cid]["count"].M_S or 0
            }
        end
        indun_list_viewer_save_settings()
    end

    if g.lang == "Japanese" then
        ui.SysMsg("[ILV]レイドの回数を初期化しました。")
    else
        ui.SysMsg("[ILV]Raid counts were initialized.")
    end
    -- indun_list_viewer_get_raid_count()
end

function indun_list_viewer_get_raid_count()

    local function createData()
        local data = {
            S_H = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 690).PlayPerResetType),
            S_N = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 688).PlayPerResetType),
            U_H = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 687).PlayPerResetType),
            U_N = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 685).PlayPerResetType),
            R_H = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 681).PlayPerResetType),
            R_N = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 679).PlayPerResetType),
            T_H = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 678).PlayPerResetType),
            T_N = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 676).PlayPerResetType),
            M_H = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 697).PlayPerResetType),
            M_N = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 695).PlayPerResetType)
        }

        return data
    end

    local function insertbuff()
        local buffframe = ui.GetFrame("buff")
        local handle = session.GetMyHandle()
        local buffslotset = GET_CHILD_RECURSIVELY(buffframe, "buffslot")
        local buffslotcount = buffslotset:GetChildCount()

        local sweepbuff_table = {
            R_S = 80015,
            T_S = {80016, 80017},
            U_S = 80030,
            S_S = 80031,
            M_S = 80032
        }

        local buffs = {}

        for raid in pairs(sweepbuff_table) do
            buffs[raid] = 0
        end

        for i = 0, buffslotcount - 1 do
            local child = buffslotset:GetChildByIndex(i)
            local icon = child:GetIcon()
            local iconinfo = icon:GetInfo()
            local type = iconinfo.type
            local buff = info.GetBuff(handle, iconinfo.type)

            for raid, buffid in pairs(sweepbuff_table) do
                if type == buffid or (type == 80016 and raid == "T_S") or (type == 80017 and raid == "T_S") then
                    buffs[raid] = buff.over
                    break
                end
            end
        end

        return buffs
    end

    local data = createData()
    local buffs = insertbuff()

    for k, v in pairs(buffs) do
        data[k] = v
    end

    g.settings[g.cid]["count"] = data
    indun_list_viewer_save_settings()
end

function indun_list_viewer_frame_init()

    local frame = ui.GetFrame("indun_list_viewer")
    frame:SetSkinName('None')
    frame:SetTitleBarSkin("None")
    frame:Resize(35, 35)
    frame:SetPos(665, 0)

    local btn = frame:CreateOrGetControl('button', 'btn', 0, 0, 35, 35)
    btn:SetSkinName("None")
    btn:SetText("{img sysmenu_sys 35 35}")
    btn:SetEventScript(ui.LBUTTONDOWN, "indun_list_viewer_title_frame_open")

    if g.lang == "Japanese" then
        btn:SetTextTooltip("{ol}Indun List Viewer{nl}キャラ毎のレイド回数表示{nl}" ..
                               "{@st45r14}※掃討はキャラ毎の最終ログイン時の値なので、期限切れなどで実際とは異なる場合があります")
    else
        btn:SetTextTooltip("{ol}Indun List Viewer{nl}Raid count display per character{nl}" ..
                               "{@st45r14}※The AutoClear is the value at the last login for each character{nl}" ..
                               "and may differ from the actual value due to expiration or other reasons.")
    end
end

function indun_list_viewer_title_frame_open()

    indun_list_viewer_get_raid_count()
    local frame = ui.CreateNewFrame("notice_on_pc", addonNameLower .. "list_frame", 0, 0, 10, 10)
    AUTO_CAST(frame)
    frame:RemoveAllChild()
    frame:SetLayerLevel(99);
    frame:SetSkinName("bg")

    local titlegb = frame:CreateOrGetControl("groupbox", "titlegb", 0, 0, 10, 10)
    AUTO_CAST(titlegb)
    -- titlegb:SetSkinName("bg")
    titlegb:SetColorTone("FF000000");

    local charname_text = ""
    local hc_text = ""
    local ac_text = ""
    local titlegb_text = ""
    local mode_text = ""
    local displaytext = ""
    local memo = ""
    local display = ""

    if g.lang == "Japanese" then
        charname_text = "キャラクター名"
        hc_text = "ハード"
        ac_text = "オート ソロ / オート掃討"
        titlegb_text = "右クリックで閉じます"
        mode_text = "チェックを入れるとスクロールモードに切替"
        displaytext = "チェックしたキャラはレイド回数非表示"
        memo = "メモ"
        display = "表示切替"
    else
        charname_text = "CharacterName"
        hc_text = "Hard Count"
        ac_text = "Auto or Solo Count/ AutoClearBuff Count"
        titlegb_text = "Right-click to close"
        mode_text = "Switch to scroll mode when checked"
        displaytext = "Checked characters hide raid count"
        memo = "Memo"
        display = "Display"
    end

    local charname = titlegb:CreateOrGetControl("richtext", "charname", 20, 35)
    AUTO_CAST(charname)
    charname:SetText("{ol}" .. charname_text)

    local hard_text = titlegb:CreateOrGetControl("richtext", "hard_text", 200, 5)
    AUTO_CAST(hard_text)
    hard_text:SetText("{ol}" .. hc_text)

    local auto_text = titlegb:CreateOrGetControl("richtext", "auto_text", 410, 5)
    AUTO_CAST(auto_text)
    auto_text:SetText("{ol}" .. ac_text)

    -- ゴーレムH712 A710 S711 ネリンガH709 A707 S708 
    local icon_table = {
        [1] = {
            iconName = "icon_item_misc_merregina_blackpearl",
            hard = 697
        },
        [2] = {
            iconName = "icon_item_misc_boss_Slogutis",
            hard = 690
        },
        [3] = {
            iconName = "icon_item_misc_boss_Upinis",
            hard = 687
        },
        [4] = {
            iconName = "icon_item_misc_boss_Roze",
            hard = 681
        },
        [5] = {
            iconName = "icon_item_misc_high_falouros",
            hard = 678
        },
        [6] = {
            iconName = "icon_item_misc_high_transmutationSpreader",
            hard = 675
        },
        [7] = {
            iconName = "icon_item_misc_merregina_blackpearl",
            solo = 696,
            auto = 695
        },
        [8] = {
            iconName = "icon_item_misc_boss_Slogutis",
            solo = 689,
            auto = 688
        },
        [9] = {
            iconName = "icon_item_misc_boss_Upinis",
            solo = 686,
            auto = 685
        },
        [10] = {
            iconName = "icon_item_misc_boss_Roze",
            solo = 680,
            auto = 679
        },
        [11] = {
            iconName = "icon_item_misc_falouros",
            solo = 677,
            auto = 676
        },
        [12] = {
            iconName = "icon_item_misc_transmutationSpreader",
            solo = 674,
            auto = 673
        }
    }

    local y = 175
    for i = 1, 6 do

        local picture = titlegb:CreateOrGetControl('picture', "picture" .. i, y, 30, 25, 25);
        AUTO_CAST(picture)
        local iconName = icon_table[i].iconName
        picture:SetImage(iconName)
        picture:SetEnableStretch(1)
        -- picture:SetAngleLoop(5)
        picture:EnableHitTest(1)
        picture:SetEventScript(ui.LBUTTONDOWN, "indun_list_viewer_enter_hard")
        picture:SetEventScriptArgNumber(ui.LBUTTONDOWN, icon_table[i].hard)
        picture:SetEventScriptArgString(ui.LBUTTONDOWN, "false")
        picture:SetTextTooltip(g.lang == "Japanese" and "左クリックでレイド画面表示" or
                                   "Left click to display raid screen")

        y = y + 30
    end
    y = y + 40
    for i = 7, 12 do

        local picture = titlegb:CreateOrGetControl('picture', "picture" .. i, y, 30, 25, 25);
        AUTO_CAST(picture)
        local iconName = icon_table[i].iconName
        picture:SetImage(iconName)
        picture:SetEnableStretch(1)
        -- picture:SetAngleLoop(5)
        picture:EnableHitTest(1)
        picture:SetUserValue("SOLO", icon_table[i].solo)
        picture:SetUserValue("AUTO", icon_table[i].auto)
        picture:SetEventScript(ui.LBUTTONUP, "indun_list_viewer_enter_context")
        picture:SetTextTooltip(g.lang == "Japanese" and "左クリックでレイド画面表示" or
                                   "Left click to display raid screen")
        if i <= 9 then
            y = y + 70
        elseif i == 10 then
            y = y + 55
        else
            y = y + 30
        end

    end

    if g.settings.mode == 1 then
        frame:SetPos(665, 35)
    else
        frame:SetPos(665, 35)
    end

    titlegb:SetEventScript(ui.RBUTTONUP, "indun_list_viewer_close")
    titlegb:SetTextTooltip("{ol}" .. titlegb_text)

    local close = titlegb:CreateOrGetControl("button", "close", 0, 0, 20, 20)
    AUTO_CAST(close)
    close:SetImage("testclose_button")
    close:SetGravity(ui.RIGHT, ui.TOP)
    close:SetEventScript(ui.LBUTTONUP, "indun_list_viewer_close")

    local ccbtn = titlegb:CreateOrGetControl('button', 'ccbtn', 40, 5, 30, 30)
    AUTO_CAST(ccbtn)
    ccbtn:SetSkinName("None")
    ccbtn:SetText("{img barrack_button_normal 30 30}")
    ccbtn:SetEventScript(ui.LBUTTONUP, "APPS_TRY_MOVE_BARRACK")

    local mode_check = titlegb:CreateOrGetControl('checkbox', 'mode_check', 80, 5, 30, 30)
    AUTO_CAST(mode_check)

    mode_check:SetCheck(g.settings.mode)
    mode_check:SetEventScript(ui.LBUTTONUP, "indun_list_viewer_modechange")
    mode_check:SetTextTooltip("{ol}" .. mode_text)

    local memo_text = titlegb:CreateOrGetControl("richtext", "memo_text", 700 + 100, 35)
    AUTO_CAST(memo_text)
    memo_text:SetText("{ol}" .. memo)

    local display_text = titlegb:CreateOrGetControl("richtext", "display_text", 820 + 100, 35)
    AUTO_CAST(display_text)
    display_text:SetText("{ol}" .. display)
    display_text:SetTextTooltip("{ol}" .. displaytext)

    titlegb:Resize(900 + 70, 55)
    frame:Resize(900 + 70, 55)
    frame:ShowWindow(1)

    indun_list_viewer_frame_open(frame)
end

function indun_list_viewer_enter_context(frame, ctrl, str, num)
    local solo = g.lang == "Japanese" and "ソロ" or "SOLO"
    local auto = g.lang == "Japanese" and "自動" or "AUTO"
    local context = ui.CreateContextMenu("context", "", 0, 0, 0, 0);

    local strScp = string.format("indun_list_viewer_enter_solo(%d)", ctrl:GetUserIValue("SOLO"))
    ui.AddContextMenuItem(context, solo, strScp)
    strScp = string.format("indun_list_viewer_enter_auto(%d)", ctrl:GetUserIValue("AUTO"))
    ui.AddContextMenuItem(context, auto, strScp)
    ui.OpenContextMenu(context);
end

function indun_list_viewer_enter_solo(induntype)
    local frame = ui.GetFrame(addonNameLower .. "list_frame")
    frame:ShowWindow(0)

    ReqRaidAutoUIOpen(induntype)
    ReserveScript(string.format("ReqMoveToIndun(%d,%d)", 1, 0), 0.3)
end

function indun_list_viewer_enter_auto(induntype)
    local frame = ui.GetFrame(addonNameLower .. "list_frame")
    frame:ShowWindow(0)

    ReqRaidAutoUIOpen(induntype)
    local topFrame = ui.GetFrame("indunenter")
    -- local useCount = tonumber(topFrame:GetUserValue("multipleCount"));
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

function indun_list_viewer_INDUNINFO_SET_BUTTONS(induntype, ctrl)
    local frame = ui.GetFrame(addonNameLower .. "list_frame")
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

function indun_list_viewer_enter_hard(frame, ctrl, str, induntype)
    local frame = ui.GetFrame(addonNameLower .. "list_frame")
    local indunCls = GetClassByType("Indun", induntype)
    if str == "false" then
        indun_list_viewer_INDUNINFO_SET_BUTTONS(induntype, ctrl)
        str = "true"
        ReserveScript(string.format("indun_list_viewer_enter_hard('%s','%s','%s',%d)", frame, ctrl, str, induntype), 0.5)
        return
    else
        SHOW_INDUNENTER_DIALOG(induntype)
        frame:ShowWindow(0)
        return
    end
end

function indun_list_viewer_close(frame)

    local frame = ui.GetFrame(addonNameLower .. "list_frame")
    frame:ShowWindow(0)
end

function indun_list_viewer_job_slot(frame, pcname, jobid, president, x, layer, cid)

    local lastJobCls
    local jobList, level, lastJobID = GetJobListFromAdventureBookCharData(pcname)
    if jobid == "" then
        lastJobCls = GetClassByType("Job", lastJobID)
    else
        lastJobCls = GetClassByType("Job", president)
    end

    local lastJobIcon = TryGetProp(lastJobCls, "Icon")

    local gb = GET_CHILD_RECURSIVELY(frame, "gb")
    local jobslot = gb:CreateOrGetControl("slot", "jobslot" .. cid, 5, x - 4, 25, 25)
    AUTO_CAST(jobslot)
    jobslot:SetSkinName("None")
    jobslot:EnableHitTest(1)
    jobslot:EnablePop(0)

    local jobicon = CreateIcon(jobslot)
    jobicon:SetImage(lastJobIcon)

    local cc_text = ""
    if g.lang == "Japanese" then
        cc_text = "クリックするとキャラクターチェンジします。"
    else
        cc_text = "Click to change characters."
    end

    local text = ""
    local id1, id2, id3, id4 = nil, nil, nil, nil
    local jobName1, jobName2, jobName3, jobName4

    if jobid ~= "" then

        local ids = {}

        for part in string.gmatch(jobid, "[^/]+") do
            table.insert(ids, part)
        end

        id1, id2, id3, id4 = ids[1], ids[2], ids[3], ids[4]

        local function get_job_name(id)
            if not id then
                return nil
            end
            local jobClass = GetClassByType("Job", tonumber(id))
            if jobClass then
                return TryGetProp(jobClass, "Name", nil)
            end
            return nil
        end

        jobName1 = get_job_name(id1)
        jobName2 = get_job_name(id2)
        jobName3 = get_job_name(id3)
        jobName4 = get_job_name(id4)

        local highlight_color = "{#FF0000}" -- 一致した場合の色
        local function color_if_match(jobName, jobId)
            if jobId and tonumber(jobId) == tonumber(president) then
                return highlight_color .. jobName .. "{/}"
            else
                return jobName
            end
        end

        local tooltipText = "{ol}"
        if jobName1 then
            tooltipText =
                tooltipText .. color_if_match(string.gsub(dic.getTranslatedStr(jobName1), "{s18}", ""), id1) .. "{nl}"
        end
        if jobName2 then
            tooltipText =
                tooltipText .. color_if_match(string.gsub(dic.getTranslatedStr(jobName2), "{s18}", ""), id2) .. "{nl}"
        end
        if jobName3 then
            tooltipText =
                tooltipText .. color_if_match(string.gsub(dic.getTranslatedStr(jobName3), "{s18}", ""), id3) .. "{nl}"
        end
        if jobName4 then
            tooltipText =
                tooltipText .. color_if_match(string.gsub(dic.getTranslatedStr(jobName4), "{s18}", ""), id4) .. "{nl}"
        end

        text = tooltipText

    else
        local jobname = TryGetProp(lastJobCls, "Name")
        text = "{ol}" .. string.gsub(dic.getTranslatedStr(jobname), "{s18}", "")

    end

    local functionName = "INSTANTCC_ON_INIT"
    if type(_G[functionName]) == "function" then

        jobicon:SetTextTooltip(text .. "{nl} {nl}{#FF4500}" .. cc_text)
        jobslot:SetEventScript(ui.LBUTTONDOWN, "indun_list_viewer_INSTANTCC_DO_CC")
        jobslot:SetEventScriptArgString(ui.LBUTTONDOWN, cid)
        jobslot:SetEventScriptArgNumber(ui.LBUTTONDOWN, layer)

        local name_text = GET_CHILD_RECURSIVELY(gb, cid)
        name_text:SetEventScript(ui.LBUTTONDOWN, "indun_list_viewer_INSTANTCC_DO_CC")
        name_text:SetEventScriptArgString(ui.LBUTTONDOWN, cid)
        name_text:SetEventScriptArgNumber(ui.LBUTTONDOWN, layer)
        name_text:SetTextTooltip(text .. "{nl} {nl}{#FF4500}" .. cc_text)
    else
        jobicon:SetTextTooltip(text)
    end
end

function indun_list_viewer_INSTANTCC_DO_CC(frame, ctrl, cid, layer)

    g.layer = nil
    INSTANTCC_DO_CC(cid, layer)
end

function indun_list_viewer_frame_open(frame)

    local gb = frame:CreateOrGetControl("groupbox", "gb", 0, 55, 10, 10)
    AUTO_CAST(gb)
    -- gb:SetSkinName("bg")
    gb:SetColorTone("FF000000")

    local myHandle = session.GetMyHandle()
    local myCharName = info.GetName(myHandle)
    local x = 6
    local cnt = 0

    local y = 0
    local frameY = 0

    for _, data in ipairs(g.sortedSettings) do
        local pcname = data.name
        local cid = data.cid
        local layer = data.layer
        local count = data["count"]

        local jobid = data.jobid
        local president = data.president_jobid

        y = 175

        cnt = cnt + 1
        local name = gb:CreateOrGetControl("richtext", cid, 35, x)
        AUTO_CAST(name)
        indun_list_viewer_job_slot(frame, pcname, jobid, president, x, layer, cid)

        if myCharName == pcname then
            name:SetText("{ol}{#FF4500}" .. pcname)
        else
            name:SetText("{ol}" .. pcname)
        end

        local line = gb:CreateOrGetControl("labelline", "line" .. cid, 30, x - 7, 850 + 60, 2)
        line:SetSkinName("labelline_def_3")

        local memo = gb:CreateOrGetControl('edit', 'memo' .. cid, 735, x - 5, 200, 25)
        AUTO_CAST(memo)
        memo:SetFontName("white_14_ol")
        memo:SetTextAlign("left", "center")
        memo:SetSkinName("inventory_serch"); -- test_edit_skin--test_weight_skin--inventory_serch
        memo:SetEventScript(ui.ENTERKEY, "indun_list_viewer_memo_save")
        memo:SetEventScriptArgString(ui.ENTERKEY, cid)
        local memoData = data.memo
        memo:SetText(memoData)

        local display = gb:CreateOrGetControl('checkbox', 'display' .. cid, 940, x - 5, 25, 25)
        AUTO_CAST(display)
        display:SetEventScript(ui.LBUTTONUP, "indun_list_viewer_display_save")
        display:SetEventScriptArgString(ui.LBUTTONUP, cid)
        local check = 1
        if not data.hide then
            check = 0
        end
        display:SetCheck(check)

        if not data.hide then

            local M_H = gb:CreateOrGetControl("richtext", "M_H" .. cid, y, x)
            M_H:SetText("{ol}{s14}( " .. count.M_H .. " )")
            -- if count.M_H == 1 then
            if count.M_H ~= "-" and tonumber(count.M_H) and tonumber(count.M_H) == 1 then
                M_H:SetColorTone("FF990000");
            else
                M_H:SetColorTone("FFFFFFFF");
            end

            y = y + 30
            local S_H = gb:CreateOrGetControl("richtext", "S_H" .. cid, y, x)
            S_H:SetText("{ol}{s14}( " .. count.S_H .. " )")
            -- if count.S_H == 1 then
            if count.S_H ~= "-" and tonumber(count.S_H) and tonumber(count.S_H) == 1 then
                S_H:SetColorTone("FF990000");
            else
                S_H:SetColorTone("FFFFFFFF");
            end

            y = y + 30
            local U_H = gb:CreateOrGetControl("richtext", "U_H" .. cid, y, x)
            U_H:SetText("{ol}{s14}( " .. count.U_H .. " )")
            -- if count.U_H == 1 then
            if count.U_H ~= "-" and tonumber(count.U_H) and tonumber(count.U_H) == 1 then
                U_H:SetColorTone("FF990000");
            else
                U_H:SetColorTone("FFFFFFFF");
            end

            y = y + 30
            local R_H = gb:CreateOrGetControl("richtext", "R_H" .. cid, y, x)
            R_H:SetText("{ol}{s14}( " .. count.R_H .. " )")
            -- if count.R_H == 1 then
            if count.R_H ~= "-" and tonumber(count.R_H) and tonumber(count.R_H) == 1 then
                R_H:SetColorTone("FF990000");
            else
                R_H:SetColorTone("FFFFFFFF");
            end

            y = y + 50
            local T_H = gb:CreateOrGetControl("richtext", "T_H" .. cid, y, x)
            T_H:SetText("{ol}{s14}( " .. count.T_H .. " )")
            -- if count.T_H == 2 then
            if count.T_H ~= "-" and tonumber(count.T_H) and tonumber(count.T_H) == 2 then
                T_H:SetColorTone("FF990000");
            else
                T_H:SetColorTone("FFFFFFFF");
            end

            y = y + 65
            local M_N = gb:CreateOrGetControl("richtext", "M_N" .. cid, y, x)
            -- if count.M_N == 2 then
            if count.M_N ~= "-" and tonumber(count.M_N) and tonumber(count.M_N) == 2 then
                M_N:SetText("{ol}{s14}{#990000}( " .. count.M_N .. " ){/}" .. "{ol}{s14}/")
            else
                M_N:SetText("{ol}{s14}{#FFFFFF}( " .. count.M_N .. " ){/}" .. "{ol}{s14}/")
            end

            y = y + 35
            local M_S = gb:CreateOrGetControl("richtext", "M_S" .. cid, y, x)
            M_S:SetText("{ol}{s14}( " .. count.M_S .. " )")
            if count.M_S ~= "-" and tonumber(count.M_S) and tonumber(count.M_S) >= 1 then
                M_S:SetColorTone("FFFFFF00")
            else
                M_S:SetColorTone("FFFFFFFF")
            end

            y = y + 35
            local S_N = gb:CreateOrGetControl("richtext", "S_N" .. cid, y, x)
            -- if count.S_N == 2 then
            if count.S_N ~= "-" and tonumber(count.S_N) and tonumber(count.S_N) == 2 then
                S_N:SetText("{ol}{s14}{#990000}( " .. count.S_N .. " ){/}" .. "{ol}{s14}/")
            else
                S_N:SetText("{ol}{s14}{#FFFFFF}( " .. count.S_N .. " ){/}" .. "{ol}{s14}/")
            end

            y = y + 35
            local S_S = gb:CreateOrGetControl("richtext", "S_S" .. cid, y, x)
            S_S:SetText("{ol}{s14}( " .. count.S_S .. " )")
            if count.S_S ~= "-" and tonumber(count.S_S) and tonumber(count.S_S) >= 1 then
                S_S:SetColorTone("FFFFFF00")
            else
                S_S:SetColorTone("FFFFFFFF")
            end

            y = y + 35
            local U_N = gb:CreateOrGetControl("richtext", "U_N" .. cid, y, x)
            -- if count.U_N == 2 then
            if count.U_N ~= "-" and tonumber(count.U_N) and tonumber(count.U_N) == 2 then
                U_N:SetText("{ol}{s14}{#990000}( " .. count.U_N .. " ){/}" .. "{ol}{s14}/")
            else
                U_N:SetText("{ol}{s14}{#FFFFFF}( " .. count.U_N .. " ){/}" .. "{ol}{s14}/")
            end

            y = y + 35
            local U_S = gb:CreateOrGetControl("richtext", "U_S" .. cid, y, x)
            U_S:SetText("{ol}{s14}( " .. count.U_S .. " )")
            if count.U_S ~= "-" and tonumber(count.U_S) and tonumber(count.U_S) >= 1 then
                U_S:SetColorTone("FFFFFF00")
            else
                U_S:SetColorTone("FFFFFFFF")
            end

            y = y + 35
            local R_N = gb:CreateOrGetControl("richtext", "R_N" .. cid, y, x)
            -- if count.R_N == 2 then
            if count.R_N ~= "-" and tonumber(count.R_N) and tonumber(count.R_N) == 2 then
                R_N:SetText("{ol}{s14}{#990000}( " .. count.R_N .. " ){/}" .. "{ol}{s14}/")
            else
                R_N:SetText("{ol}{s14}{#FFFFFF}( " .. count.R_N .. " ){/}" .. "{ol}{s14}/")
            end

            y = y + 35
            local R_S = gb:CreateOrGetControl("richtext", "R_S" .. cid, y, x)
            R_S:SetText("{ol}{s14}( " .. count.R_S .. " )")
            if count.R_S ~= "-" and tonumber(count.R_S) and tonumber(count.R_S) >= 1 then
                R_S:SetColorTone("FFFFFF00")
            else
                R_S:SetColorTone("FFFFFFFF")
            end

            y = y + 35
            local T_N = gb:CreateOrGetControl("richtext", "T_N" .. cid, y, x)
            -- if count.T_N == 4 then
            if count.T_N ~= "-" and tonumber(count.T_N) and tonumber(count.T_N) == 4 then
                T_N:SetText("{ol}{s14}{#990000}( " .. count.T_N .. " ){/}" .. "{ol}{s14}/")
            else
                T_N:SetText("{ol}{s14}{#FFFFFF}( " .. count.T_N .. " ){/}" .. "{ol}{s14}/")
            end

            y = y + 35
            local T_S = gb:CreateOrGetControl("richtext", "T_S" .. cid, y, x)
            T_S:SetText("{ol}{s14}( " .. count.T_S .. " )")
            if count.T_S ~= "-" and tonumber(count.T_S) and tonumber(count.T_S) >= 1 then
                T_S:SetColorTone("FFFFFF00")
            else
                T_S:SetColorTone("FFFFFFFF")
            end

            frameY = y + 245

        end
        x = x + 25
    end

    local framex = cnt * 25

    frameY = frameY + 60

    frame:Resize(frameY, framex + 70)
    local titlegb = GET_CHILD_RECURSIVELY(frame, "titlegb")
    titlegb:Resize(frameY, 55)
    gb:Resize(frameY, framex + 15)
    gb:SetEventScript(ui.RBUTTONUP, "indun_list_viewer_close")
    if g.settings.mode == 1 then
        frame:Resize(frameY, framex / 2 + 70 + 185)
        gb:Resize(frameY, framex / 2 + 15 + 175)
    else
        gb:Resize(frameY, framex + 15)
    end
    frame:ShowWindow(1)
end

function indun_list_viewer_modechange(frame, ctrl, argStr, argNum)

    local ischeck = ctrl:IsChecked()
    g.settings.mode = ischeck
    indun_list_viewer_save_settings()
end

function indun_list_viewer_display_save(frame, ctrl, argStr, argNum)

    local ischeck = ctrl:IsChecked()
    local tf = true
    for _, data in ipairs(g.sortedSettings) do
        local cid = data.cid
        if cid == argStr then
            if ischeck == 1 then
                g.settings[cid].hide = true
            else
                g.settings[cid].hide = false
            end
            indun_list_viewer_save_settings()
            break
        end
    end
end

function indun_list_viewer_memo_save(frame, ctrl, argStr, argNum)

    local text = ctrl:GetText()
    for _, data in ipairs(g.sortedSettings) do
        local cid = data.cid
        if cid == argStr then
            g.settings[cid].memo = text
            indun_list_viewer_save_settings()
            break
        end
    end
    if g.lang == "Japanese" then
        ui.SysMsg("メモを登録しました。")
    else
        ui.SysMsg("MEMO registered.")
    end
end

