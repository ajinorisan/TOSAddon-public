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
local addonName = "indun_list_viewer"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.1.7"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)
g.new_settingsFileLoc = string.format('../addons/%s/new_settings.json', addonNameLower)

g.logpath = string.format('../addons/%s/log.txt', addonNameLower)

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
            hide = false,
            layer = 9,
            order = 99
        }
        acutil.saveJSON(g.new_settingsFileLoc, g.settings)
    end

    --[[local settings, err = acutil.loadJSON(g.settingsFileLoc, g.settings)

    if err then
        -- 設定ファイル読み込み失敗時処理
        -- CHAT_SYSTEM(string.format("[%s] cannot load setting files", addonNameLower))
    end

    if not settings then
        settings = {
            raid_reset_time = 1702846800,
            charactors = {} -- 初期化として空のテーブルを設定
        }

        local accountInfo = session.barrack.GetMyAccount()
        local cnt = accountInfo:GetBarrackPCCount()

        for i = 0, cnt - 1 do
            local pcInfo = accountInfo:GetBarrackPCByIndex(i)
            local pcName = pcInfo:GetName()

            -- 新しいキャラのデータを一時的な変数に作成
            local newCharData = {
                name = pcName,
                raid_count = {
                    SlogutisH = "-",
                    SlogutisN = "-",
                    UpinisH = "-",
                    UpinisN = "-",
                    RozeH = "-",
                    RozeN = "-",
                    TurbulentH = "-",
                    TurbulentN = "-",
                    MerreginaN = "-"
                },
                buffid = {},
                memo = "",
                check = 0,
                layer = 9,
                order = 0
            }

            -- 一時的な変数を settings.charactors に挿入
            table.insert(settings.charactors, newCharData)
        end
    else
        -- settings.charactors が存在する場合、名前が一致するか確認して追加
        local accountInfo = session.barrack.GetMyAccount()
        local cnt = accountInfo:GetBarrackPCCount()

        for i = 0, cnt - 1 do
            local pcInfo = accountInfo:GetBarrackPCByIndex(i)
            local pcName = pcInfo:GetName()

            local found = false
            for _, charData in ipairs(settings.charactors) do
                if charData.name == pcName then
                    found = true
                    break
                end
            end

            if not found then
                -- 新しいキャラのデータを一時的な変数に作成
                local newCharData = {
                    name = pcName,
                    raid_count = {
                        SlogutisH = "-",
                        SlogutisN = "-",
                        UpinisH = "-",
                        UpinisN = "-",
                        RozeH = "-",
                        RozeN = "-",
                        TurbulentH = "-",
                        TurbulentN = "-",
                        MerreginaN = "-"
                    },
                    buffid = {},
                    memo = "",
                    check = 0,
                    layer = 9,
                    order = 0
                }

                -- 一時的な変数を settings.charactors に挿入
                table.insert(settings.charactors, newCharData)
            end

            for _, charData in ipairs(settings.charactors) do
                -- 既存のキーが存在するかどうかをチェック
                if not charData.raid_count.MerreginaN then
                    -- 既存のキーが存在しない場合のみ新しいキーを追加
                    charData.raid_count.MerreginaN = "-" -- 新しいキーを追加
                end
            end

        end
    end

    g.settings = settings

    indun_list_viewer_save_settings()]]
end

g.first = 0
function INDUN_LIST_VIEWER_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame
    g.settings = g.settings or {}
    -- g.personal = g.personal or {}
    g.lang = option.GetCurrentCountry()
    g.first = g.first + 1

    local pc = GetMyPCObject();
    local curMap = GetZoneName(pc)
    local mapCls = GetClass("Map", curMap)
    if mapCls.MapType == "City" then

        addon:RegisterMsg('GAME_START', "indun_list_viewer_load_settings")
        addon:RegisterMsg('GAME_START', "indun_list_viewer_frame_init")
        addon:RegisterMsg('GAME_START', "indun_list_viewer_raid_reset_time")
        addon:RegisterMsg('GAME_START', "indun_list_viewer_get_raid_count")
        addon:RegisterMsg('GAME_START_3SEC', "indun_list_viewer_get_count_loginname")
        addon:RegisterMsg('FPS_UPDATE', "indun_list_viewer_get_raid_count")
        g.SetupHook(indun_list_viewer_STATUS_SELET_REPRESENTATION_CLASS, "STATUS_SELET_REPRESENTATION_CLASS")
        g.SetupHook(indun_list_viewer_BARRACK_TO_GAME, "BARRACK_TO_GAME")
    end
end

function indun_list_viewer_raid_reset_time()
    local currentTime = os.time()
    -- 今日の曜日を取得 (0: 日曜日, 1: 月曜日, ..., 6: 土曜日)
    local currentWeekday = tonumber(os.date("%w", currentTime))
    -- 月曜日からの日数を計算
    local daysUntilMonday = (currentWeekday + 7 - 1) % 7
    -- 月曜日の朝6時の日時を計算
    local mondayAM6 = os.time({
        year = os.date("%Y", currentTime),
        month = os.date("%m", currentTime),
        day = os.date("%d", currentTime) - daysUntilMonday,
        hour = 6,
        min = 0,
        sec = 0
    })

    local elapsed_time = currentTime - g.settings.time
    local nextreset = 604800 -- 次の月曜日の6時までの秒数
    if elapsed_time > nextreset and g.first >= 2 then
        g.settings.time = mondayAM6
        acutil.saveJSON(g.new_settingsFileLoc, g.settings)
        indun_list_viewer_raid_reset()
        return
    end

    indun_list_viewer_get_raid_count()
end

function indun_list_viewer_raid_reset()
    local accountInfo = session.barrack.GetMyAccount();
    local cnt = accountInfo:GetPCCount();
    for i = 0, cnt - 1 do
        local pcInfo = accountInfo:GetPCByIndex(i);
        local pcApc = pcInfo:GetApc();
        local pcName = pcApc:GetName()
        local pcCid = pcInfo:GetCID();

        local path = string.format('../addons/%s/%s.json', addonNameLower, pcCid)
        local file = io.open(path, "r")
        if file then
            file:close()
            local personal = {
                S_H = "-",
                S_N = "-",
                U_H = "-",
                U_N = "-",
                R_H = "-",
                R_N = "-",
                T_H = "-",
                T_N = "-",
                M_H = "-",
                M_N = "-"
            }
            acutil.saveJSON(path, personal)
        end

    end

    if g.lang == "Japanese" then
        ui.SysMsg("レイドの回数を初期化しました。")
    else
        ui.SysMsg("Raid counts were initialized.")
    end

    indun_list_viewer_get_raid_count()
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

local function sortByLayerAndOrder(a, b)
    if a.layer ~= b.layer then
        return a.layer < b.layer
    else
        return a.order < b.order
    end
end

function indun_list_viewer_STATUS_SELET_REPRESENTATION_CLASS(selectedIndex, selectedKey)
    -- print(tostring(selectedKey))

    local LoginName = session.GetMySession():GetPCApc():GetName()
    -- print(LoginName)
    for _, charData in ipairs(g.settings.charactors) do
        if charData.name == LoginName then
            local mainSession = session.GetMainSession();
            local pcJobInfo = mainSession:GetPCJobInfo();
            local jobCount = pcJobInfo:GetJobCount();
            charData.jobid = ""
            for i = 0, jobCount - 1 do
                local jobInfo = pcJobInfo:GetJobInfoByIndex(i);
                charData.jobid = charData.jobid .. "/" .. tonumber(jobInfo.jobID)
                -- local jobCls = GetClassByType('Job', jobInfo.jobID);
                -- ui.AddDropListItem(jobCls.Name, nil, jobCls.ClassID);
            end
            charData.president_jobid = tonumber(selectedKey)

            indun_list_viewer_save_settings()
            break
        end
    end

    ChangeRepresentationClass(selectedKey);
    -- base["STATUS_SELET_REPRESENTATION_CLASS"](selectedIndex, selectedKey)
end

function indun_list_viewer_removing_character()
    local accountInfo = session.barrack.GetMyAccount()
    local cnt = accountInfo:GetBarrackPCCount()
    local currentCharacters = {}

    for i = 0, cnt - 1 do
        local pcInfo = accountInfo:GetBarrackPCByIndex(i)
        local pcName = pcInfo:GetName()
        -- print(pcName)
        currentCharacters[pcName] = true
    end

    -- settings.charactors から存在しないキャラクターを削除
    for i = #g.settings.charactors, 1, -1 do
        local charData = g.settings.charactors[i]
        if not currentCharacters[charData.name] then
            -- print(string.format("[%s] Removing character: %s", addonNameLower, charData.name))
            table.remove(g.settings.charactors, i)
        end
    end
    indun_list_viewer_save_settings()
end

function indun_list_viewer_BARRACK_TO_GAME()
    local frame = ui.GetFrame("barrack_charlist")
    local layer = tonumber(frame:GetUserValue("SelectBarrackLayer"))
    g.layer = layer

    local gsframe = ui.GetFrame("barrack_gamestart")
    local checkbtn = gsframe:GetChildRecursively("hidelogin")
    AUTO_CAST(checkbtn)
    checkbtn:SetCheck(1)
    barrack.SetHideLogin(1);

    -- BARRACK_TO_GAME_OLD()
    base["BARRACK_TO_GAME"]()
end

function indun_list_viewer_get_count_loginname()

    local LoginName = session.GetMySession():GetPCApc():GetName()

    for _, charData in pairs(g.settings.charactors) do
        if charData.name == LoginName then
            charData.raid_count = {
                SlogutisH = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 690).PlayPerResetType),
                SlogutisN = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 688).PlayPerResetType),
                UpinisH = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 687).PlayPerResetType),
                UpinisN = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 685).PlayPerResetType),
                RozeH = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 681).PlayPerResetType),
                RozeN = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 679).PlayPerResetType),
                TurbulentH = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 678).PlayPerResetType),
                TurbulentN = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 676).PlayPerResetType),
                MerreginaN = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 695).PlayPerResetType)
            }

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

            local sweepbuff_table = {80015, 80016, 80017, 80030, 80031, 80032}

            for _, buffid in ipairs(sweepbuff_table) do
                local found = false

                for i = 0, iconcount - 1 do
                    local child = buffslotset:GetChildByIndex(i)
                    local icon = child:GetIcon()
                    local iconinfo = icon:GetInfo()
                    local buff = info.GetBuff(handle, iconinfo.type)

                    if tostring(buff.buffID) == tostring(buffid) then
                        charData.buffid[tostring(buffid)] = buff.over
                        found = true
                        break
                    end
                end

                if not found then
                    charData.buffid[tostring(buffid)] = 0
                end
            end

            indun_list_viewer_save_settings()
        end
    end

end

function indun_list_viewer_get_raid_count()

    local LoginName = session.GetMySession():GetPCApc():GetName()

    for _, charData in pairs(g.settings.charactors) do
        if charData.name == LoginName then
            charData.raid_count = {
                SlogutisH = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 690).PlayPerResetType),
                SlogutisN = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 688).PlayPerResetType),
                UpinisH = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 687).PlayPerResetType),
                UpinisN = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 685).PlayPerResetType),
                RozeH = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 681).PlayPerResetType),
                RozeN = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 679).PlayPerResetType),
                TurbulentH = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 678).PlayPerResetType),
                TurbulentN = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 676).PlayPerResetType),
                MerreginaN = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 695).PlayPerResetType)
            }
        end
    end
    indun_list_viewer_save_settings()
    -- indun_list_viewer_load_settings()

    indun_list_viewer_get_sweep_count()

end

function indun_list_viewer_get_sweep_count()
    local accountInfo = session.barrack.GetMyAccount()
    local cnt = accountInfo:GetBarrackPCCount()

    for i = 0, cnt - 1 do
        local pcInfo = accountInfo:GetBarrackPCByIndex(i)
        local pcName = pcInfo:GetName()
        local LoginName = session.GetMySession():GetPCApc():GetName()

        local sweepbuff_table = {80015, 80016, 80017, 80030, 80031, 80032}

        for _, charData in pairs(g.settings.charactors) do
            if charData.name == LoginName then
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

                for _, buffid in ipairs(sweepbuff_table) do
                    local found = false

                    for i = 0, iconcount - 1 do
                        local child = buffslotset:GetChildByIndex(i)
                        local icon = child:GetIcon()
                        local iconinfo = icon:GetInfo()
                        local buff = info.GetBuff(handle, iconinfo.type)

                        if tostring(buff.buffID) == tostring(buffid) then
                            charData.buffid[tostring(buffid)] = buff.over
                            found = true
                            break
                        end
                    end

                    if not found then
                        charData.buffid[tostring(buffid)] = 0
                    end
                end
            elseif charData.name == pcName then

                -- charData.name が pcName と一致する場合の処理
                for _, buffid in ipairs(sweepbuff_table) do
                    local Value = charData.buffid[tostring(buffid)]

                    if Value == nil or type(Value) ~= "number" then
                        charData.buffid[tostring(buffid)] = "-"
                    end
                end
            end
        end
    end

    indun_list_viewer_save_settings()
    -- indun_list_viewer_load_settings()
end

function indun_list_viewer_title_frame_open()

    local accountInfo = session.barrack.GetMyAccount();
    local cnt = accountInfo:GetPCCount();
    for i = 0, cnt - 1 do
        local pcInfo = accountInfo:GetPCByIndex(i);
        local pcApc = pcInfo:GetApc();
        local pcName = pcApc:GetName()
        local pcCid = pcInfo:GetCID();
        for index, charData in ipairs(g.settings.charactors) do

            if charData.name == pcName then
                g.settings.charactors[index].cid = pcCid
                -- print(pcName .. ":" .. charData.layer .. ":" .. charData.order)
                g.settings.charactors[index].order = i
                if g.layer ~= nil and g.layer ~= g.settings.charactors[index].layer then
                    g.settings.charactors[index].layer = g.layer
                end
            end
        end
    end

    table.sort(g.settings.charactors, sortByLayerAndOrder)

    indun_list_viewer_removing_character()
    indun_list_viewer_save_settings()

    indun_list_viewer_get_count_loginname()

    local icframe = ui.CreateNewFrame("notice_on_pc", "icframe", 0, 0, 10, 10)
    AUTO_CAST(icframe)
    icframe:RemoveAllChild()

    icframe:SetLayerLevel(99);

    local titlegb = icframe:CreateOrGetControl("groupbox", "titlegb", 0, 0, 10, 10)
    AUTO_CAST(titlegb)
    titlegb:SetSkinName("bg")
    titlegb:SetColorTone("FF000000");

    local charname = titlegb:CreateOrGetControl("richtext", "charname", 20, 35)
    AUTO_CAST(charname)
    charname:SetText("{ol}CharacterName")

    local hard_text = titlegb:CreateOrGetControl("richtext", "hard_text", 200, 5)
    AUTO_CAST(hard_text)
    hard_text:SetText("{ol}Hard Count")

    local auto_text = titlegb:CreateOrGetControl("richtext", "auto_text", 360, 5)
    AUTO_CAST(auto_text)
    auto_text:SetText("{ol}Auto or Solo Count/ AutoClearBuff Count")

    local icon_table = {"icon_item_misc_boss_Slogutis", "icon_item_misc_boss_Upinis", "icon_item_misc_boss_Roze",
                        "icon_item_misc_high_falouros", "icon_item_misc_high_transmutationSpreader",
                        "icon_item_misc_merregina_blackpearl", "icon_item_misc_boss_Slogutis",
                        "icon_item_misc_boss_Upinis", "icon_item_misc_boss_Roze", "icon_item_misc_falouros",
                        "icon_item_misc_transmutationSpreader"}

    local y = 175
    for i = 1, 5 do
        local slot = titlegb:CreateOrGetControl("slot", "slot" .. i, y, 30, 25, 25)
        AUTO_CAST(slot)

        slot:SetSkinName("None");
        slot:EnablePop(0)
        slot:EnableDrop(0)
        slot:EnableDrag(0)

        local icon = CreateIcon(slot);
        local iconName = icon_table[i]

        icon:SetImage(iconName)

        y = y + 30
    end
    y = 350
    for i = 6, 11 do
        if i <= 9 then
            local slot = titlegb:CreateOrGetControl("slot", "slot" .. i, y + 10, 30, 25, 25)
            AUTO_CAST(slot)

            slot:SetSkinName("None");
            slot:EnablePop(0)
            slot:EnableDrop(0)
            slot:EnableDrag(0)

            local icon = CreateIcon(slot);
            local iconName = icon_table[i]

            icon:SetImage(iconName)

            y = y + 70
        else
            local slot = titlegb:CreateOrGetControl("slot", "slot" .. i, y, 30, 25, 25)
            AUTO_CAST(slot)

            slot:SetSkinName("None");
            slot:EnablePop(0)
            slot:EnableDrop(0)
            slot:EnableDrag(0)

            local icon = CreateIcon(slot);
            local iconName = icon_table[i]
            icon:SetImage(iconName)

            y = y + 30
        end
    end

    local mapframe = ui.GetFrame('worldmap2_mainmap')
    local screenWidth = mapframe:GetWidth()
    local frameWidth = 900 + 70
    -- local x = (screenWidth - frameWidth) / 2

    icframe:SetSkinName("bg")
    if g.settings.mode == nil then
        g.settings.mode = 0
    end
    -- icframe:SetSkinName("chat_window")
    if g.settings.mode == 1 then
        icframe:SetPos(665, 35)
    else
        icframe:SetPos(665, 5)
    end
    titlegb:Resize(900 + 70, 55)

    titlegb:SetEventScript(ui.RBUTTONUP, "indun_list_viewer_close")
    titlegb:SetTextTooltip("右クリックで閉じます。{nl}Right-click to close.")

    local close = titlegb:CreateOrGetControl("button", "close", 0, 0, 20, 20)
    AUTO_CAST(close)
    close:SetImage("testclose_button")
    close:SetGravity(ui.RIGHT, ui.TOP)
    close:SetEventScript(ui.LBUTTONUP, "indun_list_viewer_close")

    local ccbtn = titlegb:CreateOrGetControl('button', 'ccbtn', 40, 5, 30, 30)
    AUTO_CAST(ccbtn)
    ccbtn:SetSkinName("None")
    -- ccbtn:SetGravity(ui.LEFTT, ui.TOP)
    ccbtn:SetText("{img barrack_button_normal 30 30}")
    ccbtn:SetEventScript(ui.LBUTTONUP, "APPS_TRY_MOVE_BARRACK")

    local mode_check = titlegb:CreateOrGetControl('checkbox', 'mode_check', 80, 5, 30, 30)
    AUTO_CAST(mode_check)

    mode_check:SetCheck(g.settings.mode)
    mode_check:SetEventScript(ui.LBUTTONUP, "indun_list_viewer_modechange")
    mode_check:SetTextTooltip(
        "チェックを入れるとスクロールモードに切替{nl}Switch to scroll mode when checked")

    local memo_text = titlegb:CreateOrGetControl("richtext", "memo_text", 700 + 70, 35)
    AUTO_CAST(memo_text)
    memo_text:SetText("{ol}Memo")

    local display_text = titlegb:CreateOrGetControl("richtext", "display_text", 820 + 70, 35)
    AUTO_CAST(display_text)
    display_text:SetText("{ol}Display")
    display_text:SetTextTooltip(
        "チェックしたキャラはレイド回数非表示{nl}Checked characters hide raid count")

    icframe:ShowWindow(1)

    indun_list_viewer_frame_open(icframe)
end

function indun_list_viewer_modechange(frame, ctrl, argStr, argNum)
    local ischeck = ctrl:IsChecked()
    g.settings.mode = ischeck

    indun_list_viewer_save_settings()
end

function indun_list_viewer_INSTANTCC_DO_CC(frame, ctrl, cid, layer)

    local frame = ui.GetFrame("indun_list_viewer")
    frame:ShowWindow(0)
    INSTANTCC_DO_CC(cid, layer)
    g.layer = nil
end

function indun_list_viewer_frame_open(icframe)

    local gb = icframe:CreateOrGetControl("groupbox", "gb", 0, 55, 10, 10)
    AUTO_CAST(gb)
    gb:SetSkinName("bg")
    gb:SetColorTone("FF000000");
    -- gb:SetSkinName("chat_window")

    local myHandle = session.GetMyHandle();
    local myCharName = info.GetName(myHandle)
    local x = 6

    for _, charData in ipairs(g.settings.charactors) do
        local pcName = charData.name
        local cid = charData.cid

        local lastJobCls
        -- 初期のジョブ情報を取得
        local jobList, level, lastJobID = GetJobListFromAdventureBookCharData(pcName)
        if charData.jobid == nil then
            lastJobCls = GetClassByType("Job", lastJobID)
        else
            lastJobCls = GetClassByType("Job", charData.president_jobid)
        end

        local lastJobIcon = TryGetProp(lastJobCls, "Icon")

        local jobslot = gb:CreateOrGetControl("slot", "jobslot" .. pcName, 5, x - 4, 25, 25)
        AUTO_CAST(jobslot)
        jobslot:SetSkinName("None")
        jobslot:EnableHitTest(1)
        jobslot:EnablePop(0)

        -- jobslotにアイコンを設定
        local jobicon = CreateIcon(jobslot)
        jobicon:SetImage(lastJobIcon)

        local id1, id2, id3, id4
        local jobName1, jobName2, jobName3, jobName4

        if charData.jobid ~= nil then
            -- jobid をスラッシュでスプリット
            local index = 1
            for part in charData.jobid:gmatch("[^/]+") do
                if index == 1 then
                    id1 = part
                elseif index == 2 then
                    id2 = part
                elseif index == 3 then
                    id3 = part
                elseif index == 4 then
                    id4 = part
                else
                    break
                end
                index = index + 1
            end

            local function get_job_name(id)
                if id then
                    local jobClass = GetClassByType("Job", tonumber(id))
                    if jobClass then
                        return TryGetProp(jobClass, "Name", "Unknown Job")
                    end
                end
                return nil
            end

            -- ジョブ名を取得
            jobName1 = get_job_name(id1)
            jobName2 = get_job_name(id2)
            jobName3 = get_job_name(id3)
            jobName4 = get_job_name(id4)

            -- ジョブIDが一致するか確認
            local highlight_color = "{#FF0000}" -- 一致した場合の色
            local function color_if_match(jobName, jobId)
                if jobId and tonumber(jobId) == tonumber(charData.president_jobid) then
                    return highlight_color .. jobName .. "{/}"
                else
                    return jobName
                end
            end

            -- ツールチップテキストを作成
            local tooltipText = "{ol}"
            if jobName1 then
                tooltipText = tooltipText .. color_if_match(jobName1, id1) .. "{nl}"
            end
            if jobName2 then
                tooltipText = tooltipText .. color_if_match(jobName2, id2) .. "{nl}"
            end
            if jobName3 then
                tooltipText = tooltipText .. color_if_match(jobName3, id3) .. "{nl}"
            end
            if jobName4 then
                tooltipText = tooltipText .. color_if_match(jobName4, id4) .. "{nl}"
            end

            local functionName = "INSTANTCC_ON_INIT" -- チェックしたい関数の名前を文字列として指定
            if type(_G[functionName]) == "function" then
                if charData.name == pcName then
                    jobicon:SetTextTooltip(tooltipText .. "{nl} {nl}{#FF4500}" ..
                                               "Click on the icon to change the character.")
                    jobslot:SetEventScript(ui.LBUTTONDOWN, "indun_list_viewer_INSTANTCC_DO_CC")
                    jobslot:SetEventScriptArgString(ui.LBUTTONDOWN, charData.cid)
                    jobslot:SetEventScriptArgNumber(ui.LBUTTONDOWN, charData.layer)
                end
            else
                jobicon:SetTextTooltip(tooltipText)
            end
        else
            local jobname = TryGetProp(lastJobCls, "Name")
            -- print(jobname)
            local functionName = "INSTANTCC_ON_INIT" -- チェックしたい関数の名前を文字列として指定します
            if type(_G[functionName]) == "function" then
                if charData.name == pcName then
                    jobicon:SetTextTooltip("{ol}" .. jobname .. "{nl} {nl}{#FF4500}" ..
                                               "Click on the icon to change the character.")
                    jobslot:SetEventScript(ui.LBUTTONDOWN, "indun_list_viewer_INSTANTCC_DO_CC")
                    jobslot:SetEventScriptArgString(ui.LBUTTONDOWN, charData.cid)
                    jobslot:SetEventScriptArgNumber(ui.LBUTTONDOWN, charData.layer)
                end
            else
                jobicon:SetTextTooltip("{ol}" .. jobname)
            end
        end
        local name = gb:CreateOrGetControl("richtext", charData.name, 35, x)
        AUTO_CAST(name)

        if myCharName == pcName then
            name:SetText("{ol}{#FF4500}" .. pcName)
        else
            name:SetText("{ol}" .. pcName)
        end

        local line = gb:CreateOrGetControl("labelline", "line" .. pcName, 30, x - 7, 850 + 60, 2)
        line:SetSkinName("labelline_def_3")
        if charData.check == 0 then
            local Slogutis_hard = gb:CreateOrGetControl("richtext", "Slogutis_hard" .. pcName, 175, x)
            Slogutis_hard:SetText("{ol}{s14}( " .. charData.raid_count.SlogutisH .. " )")
            Slogutis_hard:SetTextTooltip("Hard Raid Weekly Entry Count 1 times per character{nl}" ..
                                             "ハードレイド週間入場回数1キャラ1回")
            if type(charData.raid_count.SlogutisH) == "number" then
                if tonumber(charData.raid_count.SlogutisH) == 1 then
                    Slogutis_hard:SetColorTone("FF990000");
                else
                    Slogutis_hard:SetColorTone("FFFFFFFF");
                end
            end

            local Upinis_hard = gb:CreateOrGetControl("richtext", "Upinis_hard" .. pcName, 205, x)
            Upinis_hard:SetText("{ol}{s14}( " .. charData.raid_count.UpinisH .. " )")
            Upinis_hard:SetTextTooltip("Hard Raid Weekly Entry Count 1 times per character{nl}" ..
                                           "ハードレイド週間入場回数1キャラ1回")
            if type(charData.raid_count.UpinisH) == "number" then
                if tonumber(charData.raid_count.UpinisH) == 1 then
                    Upinis_hard:SetColorTone("FF990000");
                else
                    Upinis_hard:SetColorTone("FFFFFFFF");
                end
            end

            local Roze_hard = gb:CreateOrGetControl("richtext", "Roze_hard" .. pcName, 235, x)
            Roze_hard:SetText("{ol}{s14}( " .. charData.raid_count.RozeH .. " )")
            Roze_hard:SetTextTooltip("Hard Raid Weekly Entry Count 1 times per character{nl}" ..
                                         "ハードレイド週間入場回数1キャラ1回")
            if type(charData.raid_count.RozeH) == "number" then
                if tonumber(charData.raid_count.RozeH) == 1 then
                    Roze_hard:SetColorTone("FF990000");
                else
                    Roze_hard:SetColorTone("FFFFFFFF");
                end
            end

            local Turbulent_hard = gb:CreateOrGetControl("richtext", "Turbulent_hard" .. pcName, 280, x)
            Turbulent_hard:SetText("{ol}{s14}( " .. charData.raid_count.TurbulentH .. " )")
            Turbulent_hard:SetTextTooltip("Hard Raid Weekly Entry Count 2 times per character{nl}" ..
                                              "ハードレイド週間入場回数1キャラ2回")
            if type(charData.raid_count.TurbulentH) == "number" then
                if tonumber(charData.raid_count.TurbulentH) == 2 then
                    Turbulent_hard:SetColorTone("FF990000");
                elseif tonumber(charData.raid_count.TurbulentH) == 1 then
                    Turbulent_hard:SetColorTone("FF999900");
                else
                    Turbulent_hard:SetColorTone("FFFFFFFF");
                end
            else
                Turbulent_hard:SetColorTone("FFFFFFFF");
            end

            local Merregina_auto = gb:CreateOrGetControl("richtext", "Merregina" .. pcName, 350, x)
            Merregina_auto:SetText("{ol}{s14}( " .. charData.raid_count.MerreginaN .. " ) /")
            Merregina_auto:SetTextTooltip("Auto Raid Weekly Entry Count 2 times per character{nl}" ..
                                              "自動レイド週間入場回数1キャラ2回")
            if type(charData.raid_count.MerreginaN) == "number" then
                if tonumber(charData.raid_count.MerreginaN) == 2 then
                    Merregina_auto:SetColorTone("FF990000");
                elseif tonumber(charData.raid_count.MerreginaN) == 1 then
                    Merregina_auto:SetColorTone("FF999900");
                else
                    Merregina_auto:SetColorTone("FFFFFFFF");
                end
            else
                Merregina_auto:SetColorTone("FFFFFFFF");
            end

            local Merregina_buff = gb:CreateOrGetControl("richtext", "Merregina_buff" .. pcName, 385, x)
            local Merregina_buff_count = 0
            for buffid, v in pairs(charData.buffid) do
                if buffid == tostring(80032) then
                    -- print(tostring(type(Merregina_buff_count)))
                    Merregina_buff_count = v

                end
            end

            Merregina_buff:SetText("{ol}{s14}( " .. Merregina_buff_count .. " )")
            Merregina_buff:SetTextTooltip("Number of Auto Clear Buff remaining{nl}" .. "自動掃討残り回数")
            if type(Merregina_buff_count) == "number" then
                if tonumber(Merregina_buff_count) >= 1 then -- or type(Slogutis_buff_count) ~= "string"
                    Merregina_buff:SetColorTone("FF999900")
                end
            end

            local Slogutis_auto = gb:CreateOrGetControl("richtext", "Slogutis_auto" .. pcName, 350 + 70, x)
            Slogutis_auto:SetText("{ol}{s14}( " .. charData.raid_count.SlogutisN .. " ) /")
            Slogutis_auto:SetTextTooltip("Auto Raid Weekly Entry Count 2 times per character{nl}" ..
                                             "自動レイド週間入場回数1キャラ2回")
            if type(charData.raid_count.SlogutisN) == "number" then
                if tonumber(charData.raid_count.SlogutisN) == 2 then
                    Slogutis_auto:SetColorTone("FF990000");
                elseif tonumber(charData.raid_count.SlogutisN) == 1 then
                    Slogutis_auto:SetColorTone("FF999900");
                else
                    Slogutis_auto:SetColorTone("FFFFFFFF");
                end
            else
                Slogutis_auto:SetColorTone("FFFFFFFF");
            end

            local Slogutis_buff = gb:CreateOrGetControl("richtext", "Slogutis_buff" .. pcName, 385 + 70, x)
            local Slogutis_buff_count = 0
            for buffid, v in pairs(charData.buffid) do
                if buffid == tostring(80031) then
                    Slogutis_buff_count = v

                end
            end

            Slogutis_buff:SetText("{ol}{s14}( " .. Slogutis_buff_count .. " )")
            Slogutis_buff:SetTextTooltip("Number of Auto Clear Buff remaining{nl}" .. "自動掃討残り回数")
            if type(Slogutis_buff_count) == "number" then
                if tonumber(Slogutis_buff_count) >= 1 then -- or type(Slogutis_buff_count) ~= "string"
                    Slogutis_buff:SetColorTone("FF999900")
                end
            end

            local Upinis_auto = gb:CreateOrGetControl("richtext", "Upinis_auto" .. pcName, 420 + 70, x)
            Upinis_auto:SetText("{ol}{s14}( " .. charData.raid_count.UpinisN .. " ) /")
            Upinis_auto:SetTextTooltip("Auto Raid Weekly Entry Count 2 times per character{nl}" ..
                                           "自動レイド週間入場回数1キャラ2回")
            if type(charData.raid_count.UpinisN) == "number" then
                if tonumber(charData.raid_count.UpinisN) == 2 then
                    Upinis_auto:SetColorTone("FF990000");
                elseif tonumber(charData.raid_count.UpinisN) == 1 then
                    Upinis_auto:SetColorTone("FF999900");
                else
                    Upinis_auto:SetColorTone("FFFFFFFF");
                end
            else
                Upinis_auto:SetColorTone("FFFFFFFF");
            end

            local Upinis_buff = gb:CreateOrGetControl("richtext", "Upinis_buff" .. pcName, 455 + 70, x)
            local Upinis_buff_count = 0
            for buffid, v in pairs(charData.buffid) do
                if buffid == tostring(80030) then
                    Upinis_buff_count = v

                end
            end

            Upinis_buff:SetText("{ol}{s14}( " .. Upinis_buff_count .. " )")
            Upinis_buff:SetTextTooltip("Number of Auto Clear Buff remaining{nl}" .. "自動掃討残り回数")
            if type(Upinis_buff_count) == "number" then
                if tonumber(Upinis_buff_count) >= 1 then -- or type(Upinis_buff_count) ~= "string"
                    Upinis_buff:SetColorTone("FF999900")
                end
            end

            local Roze_auto = gb:CreateOrGetControl("richtext", "Roze_auto" .. pcName, 490 + 70, x)
            Roze_auto:SetText("{ol}{s14}( " .. charData.raid_count.RozeN .. " ) /")
            Roze_auto:SetTextTooltip("Auto Raid Weekly Entry Count 2 times per character{nl}" ..
                                         "自動レイド週間入場回数1キャラ2回")
            if type(charData.raid_count.RozeN) == "number" then
                if tonumber(charData.raid_count.RozeN) == 2 then
                    Roze_auto:SetColorTone("FF990000");
                elseif tonumber(charData.raid_count.RozeN) == 1 then
                    Roze_auto:SetColorTone("FF999900");
                else
                    Roze_auto:SetColorTone("FFFFFFFF");
                end
            else
                Roze_auto:SetColorTone("FFFFFFFF");
            end

            local Roze_buff = gb:CreateOrGetControl("richtext", "Roze_buff" .. pcName, 525 + 70, x)
            local Roze_buff_count = 0
            for buffid, v in pairs(charData.buffid) do
                if buffid == tostring(80015) then
                    Roze_buff_count = v

                end
            end

            Roze_buff:SetText("{ol}{s14}( " .. Roze_buff_count .. " )")
            Roze_buff:SetTextTooltip("Number of Auto Clear Buff remaining{nl}" .. "自動掃討残り回数")
            if type(Roze_buff_count) == "number" then
                if tonumber(Roze_buff_count) >= 1 then -- or type(Roze_buff_count) ~= "string"
                    Roze_buff:SetColorTone("FF999900")
                end
            end

            local Turbulent_auto = gb:CreateOrGetControl("richtext", "Turbulent_auto" .. pcName, 560 + 70, x)
            Turbulent_auto:SetText("{ol}{s14}( " .. charData.raid_count.TurbulentN .. " ) /")
            Turbulent_auto:SetTextTooltip("Auto Raid Weekly Entry Count 4 times per character{nl}" ..
                                              "自動レイド週間入場回数1キャラ4回")
            if type(charData.raid_count.TurbulentN) == "number" then

                if tonumber(charData.raid_count.TurbulentN) == 4 then
                    Turbulent_auto:SetColorTone("FF990000");
                elseif tonumber(charData.raid_count.TurbulentN) > 1 and tonumber(charData.raid_count.TurbulentN) < 4 then
                    Turbulent_auto:SetColorTone("FF999900");
                else
                    Turbulent_auto:SetColorTone("FFFFFFFF");
                end
            else
                Turbulent_auto:SetColorTone("FFFFFFFF");
            end

            local Turbulent_buff = gb:CreateOrGetControl("richtext", "Turbulent_buff" .. pcName, 595 + 70, x)
            local Falouros_buff_count = 0
            for buffid, v in pairs(charData.buffid) do
                if buffid == tostring(80017) then
                    Falouros_buff_count = v

                end
            end
            local Spreader_buff_count = 0
            for buffid, v in pairs(charData.buffid) do
                if buffid == tostring(80016) then
                    Spreader_buff_count = v

                end
            end

            local Turbulent_buff_count
            if type(Falouros_buff_count) == "number" and type(Spreader_buff_count) == "number" then
                Turbulent_buff_count = Falouros_buff_count + Spreader_buff_count
            elseif type(Falouros_buff_count) == "number" and type(Spreader_buff_count) == "string" then
                Turbulent_buff_count = Falouros_buff_count
            elseif type(Falouros_buff_count) == "string" and type(Spreader_buff_count) == "number" then
                Turbulent_buff_count = Spreader_buff_count
            else
                Turbulent_buff_count = "-"
            end

            Turbulent_buff:SetText("{ol}{s14}( " .. Turbulent_buff_count .. " )")
            Turbulent_buff:SetTextTooltip("Number of Auto Clear Buff remaining{nl}" .. "自動掃討残り回数")
            if type(Turbulent_buff_count) == "number" then
                if tonumber(Turbulent_buff_count) >= 1 then -- or type(Turbulent_buff_count) ~= "string"
                    Turbulent_buff:SetColorTone("FF999900")
                end
            end
        end
        local memo = gb:CreateOrGetControl('edit', 'memo' .. pcName, 630 + 70 + 5, x - 5, 200, 25)
        AUTO_CAST(memo)
        memo:SetFontName("white_14_ol")
        memo:SetTextAlign("left", "center")
        -- memo:SetOffsetXForDraw(20);
        -- memo:SetOffsetYForDraw(0);
        memo:SetSkinName("inventory_serch"); -- test_edit_skin--test_weight_skin--inventory_serch
        -- memo:SetColorTone("#FFFFFF")
        memo:SetEventScript(ui.ENTERKEY, "indun_list_viewer_memo_save")
        memo:SetEventScriptArgString(ui.ENTERKEY, pcName)

        local memoData = charData.memo

        memo:SetText(memoData)

        local display = gb:CreateOrGetControl('checkbox', 'display' .. pcName, 840 + 70, x - 5, 25, 25)
        AUTO_CAST(display)
        display:SetEventScript(ui.LBUTTONUP, "indun_list_viewer_display_save")
        display:SetEventScriptArgString(ui.LBUTTONUP, pcName)

        local check = charData.check

        display:SetCheck(check)

        x = x + 25
    end
    local cnt = #g.settings.charactors
    local framex = cnt * 25

    -- icframe:Resize(900 + 70, framex + 70)
    icframe:Resize(900 + 70, framex + 70)
    gb:Resize(900 + 70, framex + 15)
    gb:SetEventScript(ui.RBUTTONUP, "indun_list_viewer_close")
    gb:SetEventScript(ui.LBUTTONUP, "indun_list_viewer_close")
    if g.settings.mode == 1 then
        icframe:Resize(900 + 70, framex / 2 + 70 + 185)
        gb:Resize(900 + 70, framex / 2 + 15 + 175)
    else
        gb:Resize(900 + 70, framex + 15)
    end
    icframe:ShowWindow(1)

end

function indun_list_viewer_close(frame)
    -- local icframe = ui.GetFrame("icframe")
    local topframe = ui.GetFrame("icframe")
    topframe:ShowWindow(0)

end

function indun_list_viewer_display_save(frame, ctrl, argStr, argNum)
    local ischeck = ctrl:IsChecked()
    for _, charData in ipairs(g.settings.charactors) do
        local pcName = charData.name
        if pcName == argStr then
            charData.check = ischeck
        end
    end

    indun_list_viewer_save_settings()
    -- indun_list_viewer_load_settings()
end

function indun_list_viewer_memo_save(frame, ctrl, argStr, argNum)
    local text = ctrl:GetText()

    for _, charData in ipairs(g.settings.charactors) do
        local pcName = charData.name
        if pcName == argStr then
            charData.memo = text
        end
    end
    ui.SysMsg("MEMO registered.")

    indun_list_viewer_save_settings()
    -- indun_list_viewer_load_settings()

end
