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
local addonName = "indun_panel"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.2.1"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)

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
    local langcode = option.GetCurrentCountry()

    if langcode == "Japanese" then
        if str == tostring("{s20}Challenge") then
            str = "{s20}チャレンジ"
        end
        if str == tostring("{s20}Singularity") then
            str = "{s20}分裂特異点"
        end
        if str == tostring("{s20}Slogutis") then
            str = "{s16}スローガティス"
        end
        if str == tostring("{s20}Upinis") then
            str = "{s20}ウピニス"
        end
        if str == tostring("{s20}Roze") then
            str = "{s20}ロゼ"
        end
        if str == tostring("{s20}Falouros") then
            str = "{s18}ファロウロス"
        end
        if str == tostring("{s20}Spreader") then
            str = "{s16}プロパゲーター"
        end
        if str == tostring("{s20}Jellyzele") then
            str = "{s16}ジェリージェル"
        end
        if str == tostring("{s20}Delmore") then
            str = "{s20}デルムーア"
        end
        if str == tostring("{s20}TelHarsha") then
            str = "{s18}テルハルシャ"
        end
        if str == tostring("{s20}Velnice") then
            str = "{s20}ヴェルニケ"
        end
        if str == tostring("{s20}Giltine") then
            str = "{s20}ギルティネ"
        end
        if str == tostring("{s20}Earring") then
            str = "{s20}焔の記憶"
        end
        if str == tostring("{s20}Wailing") then
            str = "{s20}嘆きの墓地"
        end
        if str == tostring("ACLEAR") then
            str = "ACLEAR"
        end
        if str == tostring(
            "Priority{nl}1. tickets due within 24 hours {nl}2. mercenary coin store tickets (buy and use) {nl}3. tickets due") then
            str =
                "優先順位{nl}1.24時間以内の期限付きチケット{nl}2.傭兵団コインチケット(コインで買って使います){nl}3.期限付きチケット"
        end
        return str
    end

    local LangCode = config.GetServiceNation()
    if LangCode == "TAIWAN" then

        if str == tostring("{s20}Challenge") then
            str = "{s20}挑戰"
        end
        if str == tostring("{s20}Singularity") then
            str = "{s20}分裂"
        end
        if str == tostring("{s20}Slogutis") then
            str = "{s18}深淵的觀察者"
        end
        if str == tostring("{s20}Upinis") then
            str = "{s20}夢幻森林"
        end
        if str == tostring("{s20}Roze") then
            str = "{s20}救贖的香爐"
        end
        if str == tostring("{s20}Falouros") then
            str = "{s20}帕盧烏羅斯"
        end
        if str == tostring("{s20}Spreader") then
            str = "{s18}變質的傳播者"
        end
        if str == tostring("{s20}Jellyzele") then
            str = "{s18}沉没的海盜船"
        end
        if str == tostring("{s20}Delmore") then
            str = "{s18}德慕爾激戰地"
        end
        if str == tostring("{s20}TelHarsha") then
            str = "{s20}泰哈爾沙"
        end
        if str == tostring("{s20}Velnice") then
            str = "{s20}貝勒尼凱"
        end
        if str == tostring("{s20}Giltine") then
            str = "{s20}魔神的聖所"
        end
        if str == tostring("{s20}Earring") then
            str = "{s20}煙火的記憶"
        end
        if str == tostring("{s20}Wailing") then
            str = "{s20}痛哭墓地"
        end
        if str == tostring("ACLEAR") then
            str = "掃蕩"
        end
        return str
    end

    return str
end

function INDUN_PANEL_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame
    g.framename = addonName

    -- indun_panel_load_settings()
    -- local loginCharID = info.GetCID(session.GetMyHandle())
    -- print(tostring(g.settings.loginCID))
    --[[local sweepbuff_table = {80015, 80016, 80017, 80030, 80031}

    for i = 1, #sweepbuff_table do
        indun_panel_sweep_count_get(sweepbuff_table[i])
    end]]

    indun_panel_load_settings()

    local pc = GetMyPCObject();
    local curMap = GetZoneName(pc)
    local mapCls = GetClass("Map", curMap)
    if mapCls.MapType == "City" then
        local ipframe = ui.GetFrame("indun_panel")
        ipframe:RemoveAllChild()
        addon:RegisterMsg('GAME_START_3SEC', "indun_panel_get_sweep_count")
        if g.settings.ischecked == 1 then
            indun_panel_frame_init()
            -- local ipframe = ui.GetFrame(g.framename)
            indun_panel_init(ipframe)

        else
            indun_panel_frame_init()
        end
        if g.ex == 0 and INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_41") == 0 then

            indunpanel_minimized_pvpmine_shop_init()

        end
    else
        indun_panel_autozoom_init()

    end

    if _G.ADDONS.norisan.AUTOMAPCHANGE ~= nil then
        acutil.setupHook(indun_panel_autozoom, "AUTOMAPCHANGE_CAMERA_ZOOM")

        addon:RegisterMsg('GAME_START', "indun_panel_autozoom")

    end

    addon:RegisterMsg('GAME_START', "indun_panel_autozoom")

    -- g.SetupHook(indun_panel_EARTH_TOWER_SHOP_OPEN, "EARTH_TOWER_SHOP_OPEN")
end

g.settings = {
    ischecked = 0,
    zoom = 336,
    challenge_checkbox = 1,
    challengeex_checkbox = 1,
    Slogutis_checkbox = 1,
    Upinis_checkbox = 1,
    roze_checkbox = 1,
    falouros_checkbox = 1,
    spreader_checkbox = 1,
    jellyzele_checkbox = 1,
    delmore_checkbox = 1,
    telharsha_checkbox = 1,
    velnice_checkbox = 1,
    giltine_checkbox = 1,
    earring_checkbox = 1,
    cemetery_checkbox = 1

}

function indun_panel_raid_count()
    local icframe = ui.CreateNewFrame("notice_on_pc", "icframe", 0, 0, 10, 10)
    AUTO_CAST(icframe)
    icframe:RemoveAllChild()
    icframe:SetSkinName("None")
    icframe:SetLayerLevel(107);

    local gb = icframe:CreateOrGetControl("groupbox", "gb", 0, 0, 10, 10)
    AUTO_CAST(gb)
    gb:SetSkinName("bg")
    -- gb:SetSkinName("test_frame_midle_light")
    gb:SetColorTone("FF000000");

    local charname = gb:CreateOrGetControl("richtext", "charname", 10, 35)
    AUTO_CAST(charname)
    charname:SetText("{ol}CharacterName")

    local loginCharID = info.GetCID(session.GetMyHandle())

    local icon_table = {"icon_item_misc_boss_Slogutis", "icon_item_misc_boss_Upinis", "icon_item_misc_boss_Roze",
                        "icon_item_misc_high_falouros", "icon_item_misc_high_transmutationSpreader",
                        "icon_item_misc_falouros", "icon_item_misc_transmutationSpreader"}

    local y = 175
    for i = 1, 7 do
        local slot = gb:CreateOrGetControl("slot", "slot" .. i, y, 5, 25, 25)
        AUTO_CAST(slot)

        slot:SetSkinName("None");

        local icon = CreateIcon(slot);
        local iconName = icon_table[i]

        icon:SetImage(iconName)
        local text = gb:CreateOrGetControl("richtext", "text" .. i, y + 30, 10)
        local hard_text = gb:CreateOrGetControl("richtext", "hard_text" .. i, y, 35)
        local auto_text = gb:CreateOrGetControl("richtext", "auto_text" .. i, y + 45, 35)
        local buff_text = gb:CreateOrGetControl("richtext", "buff_text" .. i, y + 90, 35)
        if i == 1 then
            hard_text:SetText("{ol}Hard")
            auto_text:SetText("{ol}Auto")
            buff_text:SetText("{ol}AClear")
            text:SetText("{ol}Abyss")
            y = y + 160
        elseif i == 2 then
            hard_text:SetText("{ol}Hard")
            auto_text:SetText("{ol}Auto")
            buff_text:SetText("{ol}AClear")
            text:SetText("{ol}Dreamy")
            y = y + 160
        elseif i == 3 then
            hard_text:SetText("{ol}Hard")
            auto_text:SetText("{ol}Auto")
            buff_text:SetText("{ol}AClear")
            text:SetText("{ol}Roze")
            y = y + 160
        elseif i == 4 then
            hard_text:SetText("{ol}Hard")
            auto_text:SetText("{ol}Auto")
            buff_text:SetText("{ol}AClear")
            y = y + 30
        elseif i == 5 then
            y = y + 30
        elseif i == 6 then

            y = y + 30
        elseif i == 7 then
            -- text:SetText("{ol}Turbulent")
            y = y + 30
        end
    end

    local indunClsList, indunCount = GetClassList('Indun')
    local accountInfo = session.barrack.GetMyAccount();
    local cnt = accountInfo:GetBarrackPCCount();

    local x = 60

    for i = 0, cnt - 1 do

        local pcInfo = accountInfo:GetBarrackPCByIndex(i);

        local pcName = pcInfo:GetName()

        local jobList, level, lastJobID = GetJobListFromAdventureBookCharData(pcName);
        local lastJobCls = GetClassByType("Job", lastJobID);
        local lastJobIcon = TryGetProp(lastJobCls, "Icon");
        local jobslot = gb:CreateOrGetControl("slot", "jobslot" .. i, 5, x - 4, 25, 25)
        AUTO_CAST(jobslot)
        jobslot:SetSkinName("None");

        local jobicon = CreateIcon(jobslot);
        jobicon:SetImage(lastJobIcon)
        -- local iconName = icon_table[i]
        local name = gb:CreateOrGetControl("richtext", pcName, 35, x)
        AUTO_CAST(name)

        name:SetText("{ol}" .. pcName)

        local line = gb:CreateOrGetControl("labelline", "line" .. i, 30, x - 7, 750, 2)
        line:SetSkinName("labelline_def_3")
        -- local temp_table = {690, 688, 687, 685, 681, 679, 678, 676, 675, 673}

        for j = 0, indunCount - 1 do
            local indunCls = GetClassByIndexFromList(indunClsList, j)

            if indunCls ~= nil and indunCls.Category ~= 'None' then

                local LoginPcName = session.GetMySession():GetPCApc():GetName()

                local entranceCount = BARRACK_GET_CHAR_INDUN_ENTRANCE_COUNT(pcInfo.cid, indunCls.PlayPerResetType)

                -- print(pcName .. ":" .. tostring(indunCls.Category) .. tostring(indunCls.PlayPerResetType) .. ":" ..
                -- entranceCount)
                -- ウピニスハード687オート685 スロガH690A688 プロパゲH675A673 ファロH678A676 ロゼH681A679
                if indunCls.PlayPerResetType == 836 then
                    local Slogutis_hard = gb:CreateOrGetControl("richtext", "Slogutis_hard" .. i, 175, x)
                    if pcName ~= LoginPcName then
                        Slogutis_hard:SetText("{ol}{s14}(" .. entranceCount .. " / 1)")
                    else
                        Slogutis_hard:SetText("{ol}{s14}(" ..
                                                  GET_CURRENT_ENTERANCE_COUNT(
                                GetClassByType("Indun", 690).PlayPerResetType) .. " / 1)")
                    end
                    if Slogutis_hard:GetText() == "{ol}{s14}(1 / 1)" then
                        Slogutis_hard:SetColorTone("FF990000");
                    end
                end
                if indunCls.PlayPerResetType == 835 then
                    local Slogutis_auto = gb:CreateOrGetControl("richtext", "Slogutis_auto" .. i, 220, x)
                    if pcName ~= LoginPcName then
                        Slogutis_auto:SetText("{ol}{s14}(" .. entranceCount .. " / 2)")
                    else
                        Slogutis_auto:SetText("{ol}{s14}(" ..
                                                  GET_CURRENT_ENTERANCE_COUNT(
                                GetClassByType("Indun", 688).PlayPerResetType) .. " / 2)")
                    end
                    -- print(tostring(Slogutis_auto:GetText()))
                    if Slogutis_auto:GetText() == "{ol}{s14}(2 / 2)" then
                        Slogutis_auto:SetColorTone("FF990000");
                    elseif Slogutis_auto:GetText() == "{ol}{s14}(1 / 2)" then
                        Slogutis_auto:SetColorTone("FF999900");
                    end
                end
                local Slogutis_buff = gb:CreateOrGetControl("richtext", "Slogutis_buff" .. i, 270, x)
                local Slogutis_buff_count = "?"

                -- 各キャラクターごとにデータを検索
                for _, entry in ipairs(g.settings.loginCID[pcName] or {}) do
                    if entry.buffid == 80031 then
                        Slogutis_buff_count = tostring(entry.sweepcount)
                        break
                    end
                end

                if Slogutis_buff_count ~= "?" then
                    Slogutis_buff:SetText("{ol}{s14}(" .. Slogutis_buff_count .. ")")
                end
                if tonumber(Slogutis_buff_count) ~= 0 then
                    Slogutis_buff:SetColorTone("FF999900")
                end

                -- 80017ファロ掃討　/80015ロゼ掃討　/80016プロパ掃討
                if indunCls.PlayPerResetType == 834 then
                    local Upinis_hard = gb:CreateOrGetControl("richtext", "Upinis_hard" .. i, 335, x)
                    if pcName ~= LoginPcName then
                        Upinis_hard:SetText("{ol}{s14}(" .. entranceCount .. " / 1)")
                    else
                        Upinis_hard:SetText("{ol}{s14}(" ..
                                                GET_CURRENT_ENTERANCE_COUNT(
                                GetClassByType("Indun", 687).PlayPerResetType) .. " / 1)")
                    end
                    if Upinis_hard:GetText() == "{ol}{s14}(1 / 1)" then
                        Upinis_hard:SetColorTone("FF990000");
                    end
                end
                if indunCls.PlayPerResetType == 833 then
                    local Upinis_auto = gb:CreateOrGetControl("richtext", "Upinis_auto" .. i, 380, x)
                    if pcName ~= LoginPcName then
                        Upinis_auto:SetText("{ol}{s14}(" .. entranceCount .. " / 2)")

                    else
                        Upinis_auto:SetText("{ol}{s14}(" ..
                                                GET_CURRENT_ENTERANCE_COUNT(
                                GetClassByType("Indun", 685).PlayPerResetType) .. " / 2)")
                    end
                    if Upinis_auto:GetText() == "{ol}{s14}(2 / 2)" then
                        Upinis_auto:SetColorTone("FF990000");
                    elseif Upinis_auto:GetText() == "{ol}{s14}(1 / 2)" then
                        Upinis_auto:SetColorTone("FF999900");
                    end
                end
                local Upinis_buff = gb:CreateOrGetControl("richtext", "Upinis_buff" .. i, 430, x)
                local Upinis_buff_count = "?"
                -- 各キャラクターごとにデータを検索
                for _, entry in ipairs(g.settings.loginCID[pcName] or {}) do
                    if entry.buffid == 80030 then
                        Upinis_buff_count = tostring(entry.sweepcount)
                        break
                    end
                end

                if Upinis_buff_count ~= "?" then
                    Upinis_buff:SetText("{ol}{s14}(" .. Upinis_buff_count .. ")")
                end
                if tonumber(Upinis_buff_count) ~= 0 then
                    Upinis_buff:SetColorTone("FF999900")
                end

                if indunCls.PlayPerResetType == 829 then
                    local Roze_hard = gb:CreateOrGetControl("richtext", "Roze_hard" .. i, 495, x)
                    if pcName ~= LoginPcName then
                        Roze_hard:SetText("{ol}{s14}(" .. entranceCount .. " / 1)")
                    else
                        Roze_hard:SetText("{ol}{s14}(" ..
                                              GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 681).PlayPerResetType) ..
                                              " / 1)")
                    end
                    if Roze_hard:GetText() == "{ol}{s14}(1 / 1)" then
                        Roze_hard:SetColorTone("FF990000");
                    end
                end
                if indunCls.PlayPerResetType == 828 then
                    local Roze_auto = gb:CreateOrGetControl("richtext", "Roze_auto" .. i, 540, x)
                    if pcName ~= LoginPcName then
                        Roze_auto:SetText("{ol}{s14}(" .. entranceCount .. " / 2)")
                    else
                        Roze_auto:SetText("{ol}{s14}(" ..
                                              GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 679).PlayPerResetType) ..
                                              " / 2)")
                    end
                    if Roze_auto:GetText() == "{ol}{s14}(2 / 2)" then
                        Roze_auto:SetColorTone("FF990000");
                    elseif Roze_auto:GetText() == "{ol}{s14}(1 / 2)" then
                        Roze_auto:SetColorTone("FF999900");
                    end
                end
                local Roze_buff = gb:CreateOrGetControl("richtext", "Roze_buff" .. i, 590, x)
                local Roze_buff_count = "?"
                -- 各キャラクターごとにデータを検索
                for _, entry in ipairs(g.settings.loginCID[pcName] or {}) do
                    if entry.buffid == 80015 then
                        Roze_buff_count = tostring(entry.sweepcount)
                        break
                    end
                end

                if Roze_buff_count ~= "?" then
                    Roze_buff:SetText("{ol}{s14}(" .. Roze_buff_count .. ")")
                end
                if tonumber(Roze_buff_count) ~= 0 then
                    Roze_buff:SetColorTone("FF999900")
                end

                if indunCls.PlayPerResetType == 827 then
                    local Turbulent_hard = gb:CreateOrGetControl("richtext", "Turbulent_hard" .. i, 655, x)
                    if pcName ~= LoginPcName then
                        Turbulent_hard:SetText("{ol}{s14}(" .. entranceCount .. " / 2)")
                    else
                        Turbulent_hard:SetText("{ol}{s14}(" ..
                                                   GET_CURRENT_ENTERANCE_COUNT(
                                GetClassByType("Indun", 678).PlayPerResetType) .. " / 2)")
                    end
                    if Turbulent_hard:GetText() == "{ol}{s14}(2 / 2)" then
                        Turbulent_hard:SetColorTone("FF990000");
                    end
                end
                if indunCls.PlayPerResetType == 826 then
                    local Turbulent_auto = gb:CreateOrGetControl("richtext", "Turbulent_auto" .. i, 700, x)
                    if pcName ~= LoginPcName then
                        Turbulent_auto:SetText("{ol}{s14}(" .. entranceCount .. " / 4)")
                    else
                        Turbulent_auto:SetText("{ol}{s14}(" ..
                                                   GET_CURRENT_ENTERANCE_COUNT(
                                GetClassByType("Indun", 676).PlayPerResetType) .. " / 4)")
                    end
                    if Turbulent_auto:GetText() == "{ol}{s14}(4 / 4)" then
                        Turbulent_auto:SetColorTone("FF990000");
                    elseif Turbulent_auto:GetText() == "{ol}{s14}(3 / 4)" or Turbulent_auto:GetText() ==
                        "{ol}{s14}(2 / 4)" or Turbulent_auto:GetText() == "{ol}{s14}(1 / 4)" then
                        Turbulent_auto:SetColorTone("FF999900");
                    end
                end
                local Turbulent_buff = gb:CreateOrGetControl("richtext", "Turbulent_buff" .. i, 750, x)
                local Turbulent_buff_count = "?"

                -- 各キャラクターごとにデータを検索
                for _, entry in ipairs(g.settings.loginCID[pcName] or {}) do
                    if entry.buffid == 80016 then
                        Turbulent_buff_count = tonumber(entry.sweepcount)
                        break
                    end
                end
                for _, entry in ipairs(g.settings.loginCID[pcName] or {}) do
                    if entry.buffid == 80017 then
                        Turbulent_buff_count = Turbulent_buff_count + tonumber(entry.sweepcount)
                        break
                    end
                end

                if Turbulent_buff_count ~= "?" then
                    Turbulent_buff:SetText("{ol}{s14}(" .. Turbulent_buff_count .. ")")
                end
                if tonumber(Turbulent_buff_count) ~= 0 then
                    Turbulent_buff:SetColorTone("FF999900")
                end
            end
        end
        x = x + 25

    end
    local framex = cnt * 25
    local mapframe = ui.GetFrame('worldmap2_mainmap')
    local screenWidth = mapframe:GetWidth()
    local frameWidth = 805
    local x = (screenWidth - frameWidth) / 2
    -- print(tostring(screenWidth))
    icframe:SetPos(x, 10)
    icframe:Resize(805, framex + 100)
    gb:Resize(805, framex + 65)
    gb:SetEventScript(ui.RBUTTONUP, "indun_panel_raid_count_close_btn")
    gb:SetEventScript(ui.LBUTTONUP, "indun_panel_raid_count_close_btn")
    local close = gb:CreateOrGetControl("button", "close", 0, 0, 20, 20)
    AUTO_CAST(close)
    close:SetImage("testclose_button")
    close:SetGravity(ui.LEFT, ui.TOP)
    close:SetEventScript(ui.LBUTTONUP, "indun_panel_raid_count_close_btn")
    icframe:ShowWindow(1)
end

function indun_panel_get_sweep_count()
    -- print("test")
    local sweepbuff_table = {80015, 80016, 80017, 80030, 80031}

    for i = 1, #sweepbuff_table do
        ReserveScript(string.format("indun_panel_sweep_count_get(%d)", sweepbuff_table[i]), 0.1)
    end

    return

end

function indun_panel_sweep_count_get(buffid)

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

    local accountInfo = session.barrack.GetMyAccount()
    local cnt = accountInfo:GetBarrackPCCount()
    local pcName = session.GetMySession():GetPCApc():GetName()

    -- print(tostring(g.settings.loginCID))

    if g.settings.loginCID == nil then
        g.settings.loginCID = {}
        indun_panel_save_settings()
    end

    if g.settings.loginCID[pcName] == nil then
        g.settings.loginCID[pcName] = {}
    end

    local buffidExists = false

    for i, entry in ipairs(g.settings.loginCID[pcName]) do
        if entry.buffid == buffid then
            -- 既存の buffid がある場合、更新
            entry.sweepcount = sweepcount
            buffidExists = true
            break
        end
    end

    if not buffidExists then
        -- 既存の buffid がない場合、新しいエントリを追加
        table.insert(g.settings.loginCID[pcName], {
            buffid = buffid,
            sweepcount = sweepcount
        })
    end

    -- 保存処理を最後にまとめて実行
    indun_panel_save_settings()
    indun_panel_load_settings()

end

function indun_panel_raid_count_close_btn(frame)
    local topframe = frame:GetTopParentFrame();
    topframe:ShowWindow(0)

end

function indun_panel_autozoom_init()
    -- CHAT_SYSTEM("test")
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

    -- local zoomtext = ipframe:CreateOrGetControl("richtext", "zoomtext", 0, 10)
    -- zoomtext:SetText("{ol}{#FFFFFF}{s14}Auto Zoom")

    local zoomedit = ipframe:CreateOrGetControl('edit', 'zoomedit', 80, 0, 60, 30)
    AUTO_CAST(zoomedit)
    zoomedit:SetText("{ol}" .. g.settings.zoom)
    zoomedit:SetFontName("white_16_ol")
    zoomedit:SetTextAlign("center", "center")
    zoomedit:SetEventScript(ui.ENTERKEY, "indun_panel_autozoom_save")
    zoomedit:SetTextTooltip("{@st59}Auto Zoom Setting{nl}" ..
                                "{@st59}1～700の値で入力。標準は336。マップ切り替え時に入力の値までZoomします。0入力で機能無効化。{nl}Input a value from 0 to 700. Standard is 336. Zoom to the input value when switching maps.{nl}Disable function by inputting 0.")
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

    local ccbtn = ipframe:CreateOrGetControl('button', 'ccbtn', 95, 5, 35, 35)
    AUTO_CAST(ccbtn)
    ccbtn:SetSkinName("None")
    ccbtn:SetText("{img barrack_button_normal 35 35}")
    ccbtn:SetEventScript(ui.LBUTTONUP, "APPS_TRY_MOVE_BARRACK")

    ipframe:ShowWindow(1)

    ipframe:RunUpdateScript("indun_panel_time_update", 300)
    -- ipframe:RunUpdateScript("indun_panel_get_sweep_count", 2.0)
    -- indun_panel_judge(ipframe)
end

-- チェックボックスで常時展開かどうかを制御
function indun_panel_judge(ipframe)

    local button = GET_CHILD_RECURSIVELY(ipframe, "indun_panel_open")

    if g.settings.ischecked == 0 then

        ipframe:SetSkinName('None')
        ipframe:SetLayerLevel(30)
        ipframe:Resize(140, 40)
        ipframe:SetPos(665, 30)
        ipframe:SetTitleBarSkin("None")
        ipframe:EnableHittestFrame(1)
        ipframe:EnableHide(0)
        ipframe:EnableHitTest(1)

        local ccbtn = ipframe:CreateOrGetControl('button', 'ccbtn', 95, 5, 35, 35)
        AUTO_CAST(ccbtn)
        ccbtn:SetSkinName("None")
        ccbtn:SetText("{img barrack_button_normal 35 35}")
        ccbtn:SetEventScript(ui.LBUTTONUP, "APPS_TRY_MOVE_BARRACK")

    elseif g.settings.ischecked == 1 then

        indun_panel_init(ipframe)
    else
        return;
    end
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

-- オートズーム機能の数字監視
function indun_panel_autozoom_save(frame, ctrl)
    local value = tonumber(ctrl:GetText())

    if value == 0 then
        g.settings.zoom = 0
        indun_panel_save_settings()
        indun_panel_load_settings()
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
        indun_panel_load_settings()
        ReserveScript("indun_panel_autozoom()", 1.0)
        return
    end

    if tonumber(value) ~= tonumber(g.settings.zoom) then
        ui.SysMsg("Auto Zoom setting set to" .. value)
        g.settings.zoom = value
        indun_panel_save_settings()
        indun_panel_load_settings()
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

    local ccbtn = ipframe:CreateOrGetControl('button', 'ccbtn', 95, 5, 35, 35)
    AUTO_CAST(ccbtn)
    ccbtn:SetSkinName("None")
    ccbtn:SetText("{img barrack_button_normal 35 35}")
    ccbtn:SetEventScript(ui.LBUTTONUP, "APPS_TRY_MOVE_BARRACK")

    ipframe:ShowWindow(1)

    ipframe:RunUpdateScript("indun_panel_time_update", 300)

end

function indun_panel_config_gb_open(frame, ctrl, argStr, argNum)
    local ipframe = ui.GetFrame(g.framename)
    ipframe:SetSkinName("test_frame_low")
    ipframe:SetLayerLevel(97)
    ipframe:Resize(190, 600)
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

    local challenge = ipframe:CreateOrGetControl("richtext", "challenge", 15, 45)
    -- challenge:SetAlign("center", "center") -- テキストを中央寄せに設定
    challenge:SetText("{ol}{#FFFFFF}" .. INDUN_PANEL_LANG("{s20}Challenge"))
    local challenge_checkbox = ipframe:CreateOrGetControl('checkbox', 'challenge_checkbox', 150, 45, 25, 25)
    AUTO_CAST(challenge_checkbox)
    challenge_checkbox:SetCheck(g.settings.challenge_checkbox)
    challenge_checkbox:SetEventScript(ui.LBUTTONUP, "indun_panel_ischecked")
    challenge_checkbox:SetTextTooltip("{@st59}チェックすると表示{nl}Check to show")

    local challengeex = ipframe:CreateOrGetControl("richtext", "challengeex", 15, 85)
    challengeex:SetText("{ol}{#FFFFFF}" .. INDUN_PANEL_LANG("{s20}Singularity"))
    local challengeex_checkbox = ipframe:CreateOrGetControl('checkbox', 'challengeex_checkbox', 150, 85, 25, 25)
    AUTO_CAST(challengeex_checkbox)
    challengeex_checkbox:SetCheck(g.settings.challengeex_checkbox)
    challengeex_checkbox:SetEventScript(ui.LBUTTONUP, "indun_panel_ischecked")
    challengeex_checkbox:SetTextTooltip("{@st59}チェックすると表示{nl}Check to show")

    local Slogutis = ipframe:CreateOrGetControl("richtext", "Slogutis", 15, 125)
    Slogutis:SetText("{ol}{#FFFFFF}" .. INDUN_PANEL_LANG("{s20}Slogutis"))
    local Slogutis_checkbox = ipframe:CreateOrGetControl('checkbox', 'Slogutis_checkbox', 150, 125, 25, 25)
    AUTO_CAST(Slogutis_checkbox)
    Slogutis_checkbox:SetCheck(g.settings.Slogutis_checkbox)
    Slogutis_checkbox:SetEventScript(ui.LBUTTONUP, "indun_panel_ischecked")
    Slogutis_checkbox:SetTextTooltip("{@st59}チェックすると表示{nl}Check to show")

    local Upinis = ipframe:CreateOrGetControl("richtext", "Upinis", 15, 165)
    Upinis:SetText("{ol}{#FFFFFF}" .. INDUN_PANEL_LANG("{s20}Upinis"))
    local Upinis_checkbox = ipframe:CreateOrGetControl('checkbox', 'Upinis_checkbox', 150, 165, 25, 25)
    AUTO_CAST(Upinis_checkbox)
    Upinis_checkbox:SetCheck(g.settings.Upinis_checkbox)
    Upinis_checkbox:SetEventScript(ui.LBUTTONUP, "indun_panel_ischecked")
    Upinis_checkbox:SetTextTooltip("{@st59}チェックすると表示{nl}Check to show")

    local roze = ipframe:CreateOrGetControl("richtext", "roze", 15, 205)
    roze:SetText("{ol}{#FFFFFF}" .. INDUN_PANEL_LANG("{s20}Roze"))
    local roze_checkbox = ipframe:CreateOrGetControl('checkbox', 'roze_checkbox', 150, 205, 25, 25)
    AUTO_CAST(roze_checkbox)
    roze_checkbox:SetCheck(g.settings.roze_checkbox)
    roze_checkbox:SetEventScript(ui.LBUTTONUP, "indun_panel_ischecked")
    roze_checkbox:SetTextTooltip("{@st59}チェックすると表示{nl}Check to show")

    local falouros = ipframe:CreateOrGetControl("richtext", "falouros", 15, 245)
    falouros:SetText("{ol}{#FFFFFF}" .. INDUN_PANEL_LANG("{s20}Falouros"))
    local falouros_checkbox = ipframe:CreateOrGetControl('checkbox', 'falouros_checkbox', 150, 245, 25, 25)
    AUTO_CAST(falouros_checkbox)
    falouros_checkbox:SetCheck(g.settings.falouros_checkbox)
    falouros_checkbox:SetEventScript(ui.LBUTTONUP, "indun_panel_ischecked")
    falouros_checkbox:SetTextTooltip("{@st59}チェックすると表示{nl}Check to show")

    local spreader = ipframe:CreateOrGetControl("richtext", "spreader", 15, 285)
    spreader:SetText("{ol}{#FFFFFF}" .. INDUN_PANEL_LANG("{s20}Spreader"))
    local spreader_checkbox = ipframe:CreateOrGetControl('checkbox', 'spreader_checkbox', 150, 285, 25, 25)
    AUTO_CAST(spreader_checkbox)
    spreader_checkbox:SetCheck(g.settings.spreader_checkbox)
    spreader_checkbox:SetEventScript(ui.LBUTTONUP, "indun_panel_ischecked")
    spreader_checkbox:SetTextTooltip("{@st59}チェックすると表示{nl}Check to show")

    local jellyzele = ipframe:CreateOrGetControl("richtext", "jellyzele", 15, 325)
    jellyzele:SetText("{ol}{#FFFFFF}" .. INDUN_PANEL_LANG("{s20}Jellyzele"))
    local jellyzele_checkbox = ipframe:CreateOrGetControl('checkbox', 'jellyzele_checkbox', 150, 325, 25, 25)
    AUTO_CAST(jellyzele_checkbox)
    jellyzele_checkbox:SetCheck(g.settings.jellyzele_checkbox)
    jellyzele_checkbox:SetEventScript(ui.LBUTTONUP, "indun_panel_ischecked")
    jellyzele_checkbox:SetTextTooltip("{@st59}チェックすると表示{nl}Check to show")

    local delmore = ipframe:CreateOrGetControl("richtext", "delmore", 15, 365)
    delmore:SetText("{ol}{#FFFFFF}" .. INDUN_PANEL_LANG("{s20}Delmore"))
    local delmore_checkbox = ipframe:CreateOrGetControl('checkbox', 'delmore_checkbox', 150, 365, 25, 25)
    AUTO_CAST(delmore_checkbox)
    delmore_checkbox:SetCheck(g.settings.delmore_checkbox)
    delmore_checkbox:SetEventScript(ui.LBUTTONUP, "indun_panel_ischecked")
    delmore_checkbox:SetTextTooltip("{@st59}チェックすると表示{nl}Check to show")

    local telharsha = ipframe:CreateOrGetControl("richtext", "telharsha", 15, 405)
    telharsha:SetText("{ol}{#FFFFFF}" .. INDUN_PANEL_LANG("{s20}TelHarsha"))
    local telharsha_checkbox = ipframe:CreateOrGetControl('checkbox', 'telharsha_checkbox', 150, 405, 25, 25)
    AUTO_CAST(telharsha_checkbox)
    telharsha_checkbox:SetCheck(g.settings.telharsha_checkbox)
    telharsha_checkbox:SetEventScript(ui.LBUTTONUP, "indun_panel_ischecked")
    telharsha_checkbox:SetTextTooltip("{@st59}チェックすると表示{nl}Check to show")

    local velnice = ipframe:CreateOrGetControl("richtext", "velnice", 15, 445)
    velnice:SetText("{ol}{#FFFFFF}" .. INDUN_PANEL_LANG("{s20}Velnice"))
    local velnice_checkbox = ipframe:CreateOrGetControl('checkbox', 'velnice_checkbox', 150, 445, 25, 25)
    AUTO_CAST(velnice_checkbox)
    velnice_checkbox:SetCheck(g.settings.velnice_checkbox)
    velnice_checkbox:SetEventScript(ui.LBUTTONUP, "indun_panel_ischecked")
    velnice_checkbox:SetTextTooltip("{@st59}チェックすると表示{nl}Check to show")

    local giltine = ipframe:CreateOrGetControl("richtext", "giltine", 15, 485)
    giltine:SetText("{ol}{#FFFFFF}" .. INDUN_PANEL_LANG("{s20}Giltine"))
    local giltine_checkbox = ipframe:CreateOrGetControl('checkbox', 'giltine_checkbox', 150, 485, 25, 25)
    AUTO_CAST(giltine_checkbox)
    giltine_checkbox:SetCheck(g.settings.giltine_checkbox)
    giltine_checkbox:SetEventScript(ui.LBUTTONUP, "indun_panel_ischecked")
    giltine_checkbox:SetTextTooltip("{@st59}チェックすると表示{nl}Check to show")

    local earring = ipframe:CreateOrGetControl("richtext", "earring", 15, 525)
    earring:SetText("{ol}{#FFFFFF}" .. INDUN_PANEL_LANG("{s20}Earring"))
    local earring_checkbox = ipframe:CreateOrGetControl('checkbox', 'earring_checkbox', 150, 525, 25, 25)
    AUTO_CAST(earring_checkbox)
    earring_checkbox:SetCheck(g.settings.earring_checkbox)
    earring_checkbox:SetEventScript(ui.LBUTTONUP, "indun_panel_ischecked")
    earring_checkbox:SetTextTooltip("{@st59}チェックすると表示{nl}Check to show")

    local cemetery = ipframe:CreateOrGetControl("richtext", "cemetery", 15, 565)
    cemetery:SetText("{ol}{#FFFFFF}" .. INDUN_PANEL_LANG("{s20}Wailing"))
    local cemetery_checkbox = ipframe:CreateOrGetControl('checkbox', 'cemetery_checkbox', 150, 565, 25, 25)
    AUTO_CAST(cemetery_checkbox)
    cemetery_checkbox:SetCheck(g.settings.cemetery_checkbox)
    cemetery_checkbox:SetEventScript(ui.LBUTTONUP, "indun_panel_ischecked")
    cemetery_checkbox:SetTextTooltip("{@st59}チェックすると表示{nl}Check to show")

end

function indun_panel_ischecked(frame, ctrl, argStr, argNum)

    local ischeck = ctrl:IsChecked();
    local ctrlname = ctrl:GetName()

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

end

function indun_panel_event_tos_whole_shop_open()

    local frame = ui.GetFrame("earthtowershop");
    frame:SetUserValue("SHOP_TYPE", 'EVENT_TOS_WHOLE_SHOP');
    ui.OpenFrame('earthtowershop');

end
-- パネル展開
function indun_panel_init(ipframe)

    ipframe:RemoveAllChild()

    local button = ipframe:CreateOrGetControl("button", "indun_panel_open", 5, 5, 80, 30)
    AUTO_CAST(button)
    button:SetText("{ol}{s11}INDUNPANEL")

    --[[if g.settings.ischecked ~= 1 then
        button:SetEventScript(ui.LBUTTONUP, "indun_panel_frame_init")
    else
        button:SetEventScript(ui.LBUTTONUP, "indun_panel_frame_close")
    end]]
    -- button:SetEventScript(ui.LBUTTONUP, "indun_panel_init")
    -- local button = GET_CHILD_RECURSIVELY(ipframe, "indun_panel_open")

    -- local zoomtext = ipframe:CreateOrGetControl("richtext", "zoomtext", 280, 15)
    -- zoomtext:SetText("{ol}{#FFFFFF}{s14}Auto Zoom")

    local zoomedit = ipframe:CreateOrGetControl('edit', 'zoomedit', 355, 5, 60, 35)
    AUTO_CAST(zoomedit)
    zoomedit:SetText("{ol}" .. g.settings.zoom)
    zoomedit:SetFontName("white_16_ol")
    zoomedit:SetTextAlign("center", "center")
    zoomedit:SetEventScript(ui.ENTERKEY, "indun_panel_autozoom_save")
    zoomedit:SetTextTooltip("{@st59}Auto Zoom Setting{nl}" ..
                                "{@st59}1～700の値で入力。標準は336。マップ切り替え時に入力の値までZoomします。0入力で機能無効化。{nl}Input a value from 0 to 700. Standard is 336. Zoom to the input value when switching maps.{nl}Disable function by inputting 0.")

    local ccbtn = ipframe:CreateOrGetControl('button', 'ccbtn', 95, 5, 35, 35)
    AUTO_CAST(ccbtn)
    ccbtn:SetSkinName("None")
    ccbtn:SetText("{img barrack_button_normal 35 35}")
    ccbtn:SetEventScript(ui.LBUTTONUP, "APPS_TRY_MOVE_BARRACK")
    ccbtn:SetTextTooltip("{@st59}バラックに戻ります。{nl}Return to Barracks.")

    local invbtn = ipframe:CreateOrGetControl('button', 'invbtn', 195, 5, 35, 35)
    AUTO_CAST(invbtn)
    invbtn:SetSkinName("None")
    invbtn:SetText("{img sysmenu_inv 35 35}")
    invbtn:SetEventScript(ui.LBUTTONUP, "INDUN_PANEL_INVENTORY_OPEN")
    invbtn:SetSkinName("test_pvp_btn")
    invbtn:SetTextTooltip("{@st59}インベントリを開きます。{nl}Open inventory.")
    -- invbtn:SetEventScript(ui.LBUTTONUP, "OPEN_DLG_ACCOUNTWAREHOUSE")

    --[[local petbtn = ipframe:CreateOrGetControl('button', 'petbtn', 200, 5, 35, 35)
    AUTO_CAST(petbtn)
    petbtn:SetSkinName("None")
    petbtn:SetText("{img sysmenu_pet 35 35}")
    -- petbtn:SetText("{img Tos_Event_Coin 35 35}")
    petbtn:SetEventScript(ui.LBUTTONUP, "UI_TOGGLE_PETLIST")]]

    local tosshop = ipframe:CreateOrGetControl("button", "tosshop", 165, 5, 35, 35);
    AUTO_CAST(tosshop)
    tosshop:SetSkinName("None")
    -- tosshop:SetText("{img mon_legendstar 30 30}")
    -- icon_item_Tos_Event_Coin
    tosshop:SetText("{img icon_item_Tos_Event_Coin 25 25}")
    tosshop:SetTextTooltip("{@st59}TOSイベントショップ{nl}TOS Event Shop")
    -- tosshop:SetImage("goddess3_shop_btn")
    -- tosshop:SetColorTone("FFFF00FF")
    -- tosshop:SetText("{img Tos_Event_Coin 35 35}")
    -- local itemcls = GetClass("Item", "Tos_Event_Coin")
    -- tosshop:SetImage(itemcls)
    tosshop:SetEventScript(ui.LBUTTONUP, "indun_panel_event_tos_whole_shop_open")

    local minebtn = ipframe:CreateOrGetControl('button', 'minebtn', 130, 5, 35, 35)
    AUTO_CAST(minebtn)
    minebtn:SetSkinName("None")
    minebtn:SetText("{img pvpmine_shop_btn_total 35 35}")
    minebtn:SetEventScript(ui.LBUTTONUP, "INDUN_PANEL_MINIMIZED_PVPMINE_SHOP_BUTTON_CLICK")
    minebtn:SetTextTooltip("{@st59}傭兵団のコイン商店。{nl}Mercenary Coin Shop.")

    local raid_count = ipframe:CreateOrGetControl('button', 'raid_count', 230, 5, 35, 35)
    AUTO_CAST(raid_count)
    raid_count:SetSkinName("None")
    raid_count:SetText("{img sysmenu_skill 35 35}")
    raid_count:SetSkinName("test_pvp_btn")
    raid_count:SetEventScript(ui.LBUTTONUP, "indun_panel_raid_count")
    raid_count:SetTextTooltip("{@st59}キャラ毎のレイド回数表示{nl}Raid count display per character{nl}" ..
                                  "{@st45r14}※掃討はキャラ毎の最終ログイン時の値なので、期限切れなどで実際とは異なる場合があります。{nl}" ..
                                  "{@st45r14}※The AutoClear is the value at the last login for each character and may differ{nl}from the actual value due to expiration or other reasons.")

    local configbtn = ipframe:CreateOrGetControl('button', 'configbtn', 315, 5, 35, 35)
    AUTO_CAST(configbtn)
    configbtn:SetSkinName("None")
    configbtn:SetText("{img config_button_normal 35 35}")
    -- configbtn:SetImage("config_button_normal")
    configbtn:SetEventScript(ui.LBUTTONUP, "indun_panel_config_gb_open")
    configbtn:SetTextTooltip("{@st59}レイド表示設定{nl}Raid Display Settings")

    if configbtn:IsVisible() == 1 then
        button:SetEventScript(ui.LBUTTONUP, "indun_panel_frame_init")

    end

    local checkbox = ipframe:CreateOrGetControl('checkbox', 'checkbox', 565, 5, 30, 30)
    tolua.cast(checkbox, 'ui::CCheckBox')
    checkbox:SetCheck(g.settings.ischecked)
    checkbox:SetEventScript(ui.LBUTTONUP, "indun_panel_checkbox_toggle")
    checkbox:SetTextTooltip("{@st59}チェックすると常時展開{nl}IsCheck AlwaysOpen")

    local pvpmine = ipframe:CreateOrGetControl("richtext", "pvpmine", 420, 10)
    pvpmine:SetText("{img pvpmine_shop_btn_total 25 25}")
    pvpmine:SetTextTooltip("{@st59}傭兵団コイン数量 Mercenary Badge count")

    local pvpminecount = ipframe:CreateOrGetControl("richtext", "pvpminecount", 445, 10)
    pvpminecount:SetText(string.format("{ol}{#FFD900}{s20}%s", GET_COMMAED_STRING(indun_panel_pvpmaine_count())))

    g.panelY = 45

    if g.settings.challenge_checkbox == 1 then
        indun_panel_challenge_frame(ipframe)
        g.panelY = g.panelY + 40
    end

    if g.settings.challengeex_checkbox == 1 then
        indun_panel_challengeex_frame(ipframe)
        g.panelY = g.panelY + 40
    end
    -- !

    if g.settings.Slogutis_checkbox == 1 then
        indun_panel_slogutis_frame(ipframe)
        g.panelY = g.panelY + 40
    end

    if g.settings.Upinis_checkbox == 1 then
        indun_panel_upinis_frame(ipframe)
        g.panelY = g.panelY + 40
    end
    -- !

    if g.settings.roze_checkbox == 1 then
        indun_panel_roze_frame(ipframe)
        g.panelY = g.panelY + 40
    end

    if g.settings.falouros_checkbox == 1 then
        indun_panel_falo_frame(ipframe)
        g.panelY = g.panelY + 40
    end

    if g.settings.spreader_checkbox == 1 then
        indun_panel_spreader_frame(ipframe)
        g.panelY = g.panelY + 40
    end

    if g.settings.jellyzele_checkbox == 1 then
        indun_panel_jellyzele_frame(ipframe)
        g.panelY = g.panelY + 40
    end

    if g.settings.delmore_checkbox == 1 then
        indun_panel_Delmore_frame(ipframe)
        g.panelY = g.panelY + 40
    end

    if g.settings.telharsha_checkbox == 1 then
        indun_panel_telharsha_frame(ipframe)
        g.panelY = g.panelY + 40
    end

    if g.settings.velnice_checkbox == 1 then
        indun_panel_velnice_frame(ipframe)
        g.panelY = g.panelY + 40
    end

    if g.settings.giltine_checkbox == 1 then
        indun_panel_giltine_frame(ipframe)
        g.panelY = g.panelY + 40
    end

    if g.settings.earring_checkbox == 1 then
        indun_panel_earring_frame(ipframe)
        g.panelY = g.panelY + 40
    end

    if g.settings.cemetery_checkbox == 1 then
        indun_panel_cemetery_frame(ipframe)
        g.panelY = g.panelY + 40
    end

    ipframe:SetLayerLevel(97)
    -- ipframe:SetLayerLevel(10)
    ipframe:Resize(600, g.panelY + 5)
    -- ipframe:SetSkinName("test_Item_tooltip_equip")
    -- ipframe:SetSkinName("test_frame_low")
    -- ipframe:SetSkinName("market_listbase")
    ipframe:SetSkinName("bg")
    ipframe:EnableHitTest(1);
    -- ipframe:SetColorTone("FF000000");
    ipframe:SetAlpha(20)

    ipframe:RunUpdateScript("indun_panel_update_frame", 1.0)

    return
end

function indun_panel_cemetery_frame(ipframe)
    local cemetery = ipframe:CreateOrGetControl("richtext", "cemetery", 15, g.panelY)
    cemetery:SetText("{ol}{#FFFFFF}" .. INDUN_PANEL_LANG("{s20}Wailing"))
    local cemeterybutton = ipframe:CreateOrGetControl('button', 'cemeterybutton', 135, g.panelY, 80, 30)
    cemeterybutton:SetText("{ol}490")
    cemeterybutton:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_solo")
    cemeterybutton:SetEventScriptArgNumber(ui.LBUTTONUP, 684)
    local cemeterycount = ipframe:CreateOrGetControl("richtext", "cemeterycount", 220, g.panelY + 5)
    cemeterycount:SetText("{ol}{#FFFFFF}{s16}(" ..
                              GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 684).PlayPerResetType) .. ")")
    -- wailing,
    local cemeterybutton_500 = ipframe:CreateOrGetControl('button', 'cemeterybutton_500', 250, g.panelY, 80, 30)
    cemeterybutton_500:SetText("{ol}500")
    cemeterybutton_500:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_solo")
    cemeterybutton_500:SetEventScriptArgNumber(ui.LBUTTONUP, 693)
    local cemeterycount_500 = ipframe:CreateOrGetControl("richtext", "cemeterycount_500", 335, g.panelY + 5)
    cemeterycount_500:SetText("{ol}{#FFFFFF}{s16}(" ..
                                  GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 693).PlayPerResetType) .. ")")
end

function indun_panel_velnice_frame(ipframe)
    local velnice = ipframe:CreateOrGetControl("richtext", "velnice", 15, g.panelY)
    velnice:SetText("{ol}{#FFFFFF}" .. INDUN_PANEL_LANG("{s20}Velnice"))
    local velnicebutton = ipframe:CreateOrGetControl('button', 'velnicebutton', 135, g.panelY, 80, 30)
    velnicebutton:SetText("{ol}IN")
    local velnicecount = ipframe:CreateOrGetControl("richtext", "velnicecount", 220, g.panelY + 5, 50, 30)
    velnicecount:SetText(
        "{ol}{#FFFFFF}(" .. GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 201).PlayPerResetType) .. "/" ..
            GET_INDUN_MAX_ENTERANCE_COUNT(GetClassByType("Indun", 201).PlayPerResetType) .. ")")
    velnicebutton:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_velnice_solo")

    local vrecipecls = GetClass('ItemTradeShop', "PVP_MINE_52");
    local voverbuy_max = TryGetProp(vrecipecls, 'MaxOverBuyCount', 0)

    local velnicebuyuse = ipframe:CreateOrGetControl('button', 'velnicebuyuse', 265, g.panelY, 80, 30)
    AUTO_CAST(velnicebuyuse)
    velnicebuyuse:SetText("{ol}{#EE7800}{s14}BUYUSE")
    velnicebuyuse:SetEventScript(ui.LBUTTONUP, "indun_panel_velnice_buyuse")
    local velniceexchangecount = ipframe:CreateOrGetControl("richtext", "velniceexchangecount", 350, g.panelY + 5, 60,
        30)

    local vexchangecount = INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_52")
    if vexchangecount < 0 then
        vexchangecount = 0
    end
    velniceexchangecount:SetText(string.format("{ol}{#FFFFFF}(%d", vexchangecount) .. "/" ..
                                     string.format("{ol}{#FF0000}%d", indun_panel_overbuy_count()) .. "{ol}{#FFFFFF})")

    local velniceamount = ipframe:CreateOrGetControl("richtext", " velniceamount", 415, g.panelY + 5, 50, 30)
    if tonumber(vexchangecount) == 1 then
        velniceamount:SetText("{ol}{#FFFFFF}(" .. "{img pvpmine_shop_btn_total 20 20}" .. "1,000)")

    else
        velniceamount:SetText("{ol}{#FFFFFF}(" .. "{img pvpmine_shop_btn_total 20 20}" ..
                                  string.format("{ol}{#FF0000}%s", GET_COMMAED_STRING(indun_panel_overbuy_amount())) ..
                                  "{ol}{#FFFFFF})")
    end
end

function indun_panel_telharsha_frame(ipframe)
    local telharsha = ipframe:CreateOrGetControl("richtext", "telharsha", 15, g.panelY)
    telharsha:SetText("{ol}{#FFFFFF}" .. INDUN_PANEL_LANG("{s20}TelHarsha"))
    local telharshabutton = ipframe:CreateOrGetControl('button', 'telharshabutton', 135, g.panelY, 80, 30)
    telharshabutton:SetText("{ol}IN")
    local telharshacount = ipframe:CreateOrGetControl("richtext", "telharshacount", 220, g.panelY + 5)
    -- telharshabutton:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_telharsha_solo")
    telharshabutton:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_solo")
    telharshabutton:SetEventScriptArgNumber(ui.LBUTTONUP, 623)

    telharshacount:SetText("{ol}{#FFFFFF}{s16}(" ..
                               GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 623).PlayPerResetType) .. "/" ..
                               GET_INDUN_MAX_ENTERANCE_COUNT(GetClassByType("Indun", 623).PlayPerResetType) .. ")")

end

function indun_panel_upinis_frame(ipframe)
    local Upinis = ipframe:CreateOrGetControl("richtext", "Upinis", 15, g.panelY)
    Upinis:SetText("{ol}{#FFFFFF}" .. INDUN_PANEL_LANG("{s20}Upinis"))
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
                                  GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 628).PlayPerResetType) .. ")")]]

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

    -- g.upinis_hard_flag = false
    -- upinishard:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_upinis_hard")
    -- upinishard:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_hard")
    -- upinishard:SetEventScriptArgNumber(ui.LBUTTONUP, 628)
    -- upinishard:SetEventScriptArgString(ui.LBUTTONUP, "false")

    upinishard:SetEventScript(ui.LBUTTONDOWN, "indun_panel_enter_hard")
    upinishard:SetEventScriptArgNumber(ui.LBUTTONDOWN, 687)
    upinishard:SetEventScriptArgString(ui.LBUTTONDOWN, "false")

end

function indun_panel_slogutis_frame(ipframe)
    local Slogutis = ipframe:CreateOrGetControl("richtext", "Slogutis", 15, g.panelY)
    Slogutis:SetText("{ol}{#FFFFFF}" .. INDUN_PANEL_LANG("{s20}Slogutis"))
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
    --[[ slogutiscounthard:SetText("{ol}{#FFFFFF}{s16}(" ..
                                  GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 628).PlayPerResetType) .. ")")]]

    -- slogutissolo:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_slogutis_solo")
    slogutissolo:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_solo")
    slogutissolo:SetEventScriptArgNumber(ui.LBUTTONUP, 689)

    -- slogutisauto:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_slogutis_auto")
    slogutisauto:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_auto")
    slogutisauto:SetEventScriptArgNumber(ui.LBUTTONUP, 688)

    slogutissweep:SetEventScript(ui.LBUTTONUP, "indun_panel_autosweep")
    slogutissweep:SetEventScriptArgNumber(ui.LBUTTONUP, 688)

    local slogutissweepcount = ipframe:CreateOrGetControl("richtext", "slogutissweepcount", 565, g.panelY + 5, 50, 30)
    slogutissweepcount:SetText("{ol}{#FFFFFF}{s16}(" .. indun_panel_sweep_count(80031) .. ")")

    -- g.slogutis_hard_flag = false
    -- slogutishard:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_slogutis_hard")
    -- slogutishard:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_hard")
    -- slogutishard:SetEventScriptArgNumber(ui.LBUTTONUP, 628)
    -- slogutishard:SetEventScriptArgString(ui.LBUTTONUP, "false")
    slogutishard:SetEventScript(ui.LBUTTONDOWN, "indun_panel_enter_hard")
    slogutishard:SetEventScriptArgNumber(ui.LBUTTONDOWN, 690)
    slogutishard:SetEventScriptArgString(ui.LBUTTONDOWN, "false")

end

-- 表示更新
function indun_panel_update_frame(frame)
    local ipframe = ui.GetFrame(g.framename)

    local invbtn = GET_CHILD_RECURSIVELY(ipframe, "invbtn")
    --[[challenge_checkbox = 1,
    challengeex_checkbox = 1,
    Slogutis_checkbox = 1,
    Upinis_checkbox = 1,
    roze_checkbox = 1,
    falouros_checkbox = 1,
    spreader_checkbox = 1,
    jellyzele_checkbox = 1,
    delmore_checkbox = 1,
    telharsha_checkbox = 1,
    velnice_checkbox = 1,
    giltine_checkbox = 1,
    earring_checkbox = 1,
    cemetery_checkbox = 1]]

    if invbtn:IsVisible() == 1 then

        if g.settings.velnice_checkbox == 1 then
            local velnicecount = GET_CHILD_RECURSIVELY(ipframe, "velnicecount")
            velnicecount:SetText("{ol}{#FFFFFF}(" ..
                                     GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 201).PlayPerResetType) .. "/" ..
                                     GET_INDUN_MAX_ENTERANCE_COUNT(GetClassByType("Indun", 201).PlayPerResetType) .. ")")

            local vrecipecls = GetClass('ItemTradeShop', "PVP_MINE_52");
            local voverbuy_max = TryGetProp(recipecls, 'MaxOverBuyCount', 0)

            local pvpminecount = GET_CHILD_RECURSIVELY(ipframe, "pvpminecount")
            pvpminecount:SetText(string.format("{ol}{#FFD900}{s20}%s", GET_COMMAED_STRING(indun_panel_pvpmaine_count())))

            local velniceexchangecount = GET_CHILD_RECURSIVELY(ipframe, "velniceexchangecount")
            local vexchangecount = INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_52")

            if vexchangecount < 0 then
                vexchangecount = 0
            end
            velniceexchangecount:SetText(string.format("{ol}{#FFFFFF}(%d", vexchangecount) .. "/" ..
                                             string.format("{ol}{#FF0000}%d", indun_panel_overbuy_count()) ..
                                             "{ol}{#FFFFFF})")

            local velniceamount = GET_CHILD_RECURSIVELY(ipframe, " velniceamount")

            local vexchangecount = INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_52")

            if tonumber(vexchangecount) == 1 then
                velniceamount:SetText("{ol}{#FFFFFF}(" .. "{img pvpmine_shop_btn_total 20 20}" .. "1,000)")

            else
                velniceamount:SetText("{ol}{#FFFFFF}(" .. "{img pvpmine_shop_btn_total 20 20}" ..
                                          string.format("{ol}{#FF0000}%s",
                        GET_COMMAED_STRING(indun_panel_overbuy_amount())) .. "{ol}{#FFFFFF})")
            end

        end
        --[[velniceamount:SetText("{ol}{#FFFFFF}(" .. "{img pvpmine_shop_btn_total 20 20}" ..
                                  string.format("{ol}{#FF0000}%s", GET_COMMAED_STRING(indun_panel_overbuy_amount())) ..
                                  "{ol}{#FFFFFF})")]]

        if g.settings.challenge_checkbox == 1 then
            local challengeticketcount = GET_CHILD_RECURSIVELY(ipframe, "challengeticketcount")
            local challengecount = GET_CHILD_RECURSIVELY(ipframe, "challengecount")

            challengeticketcount:SetText("{ol}{#FFFFFF}{s16}(" .. INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_40") ..
                                             "/" .. INDUN_PANEL_GET_MAX_RECIPE_TRADE_COUNT("PVP_MINE_40") .. ")")
            challengecount:SetText("{ol}{#FFFFFF}{s16}(" ..
                                       GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 646).PlayPerResetType) .. "/" ..
                                       GET_INDUN_MAX_ENTERANCE_COUNT(GetClassByType("Indun", 646).PlayPerResetType) ..
                                       ")")

        end

        if g.settings.challengeex_checkbox == 1 then

            local challengeexpertticketcount = GET_CHILD_RECURSIVELY(ipframe, "challengeexpertticketcount")
            local challengeexpertcount = GET_CHILD_RECURSIVELY(ipframe, "challengeexpertcount")

            challengeexpertticketcount:SetText("{ol}{#FFFFFF}{s16}(d" ..
                                                   INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_41") .. "/w" ..
                                                   INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_42") .. "/" ..
                                                   (INDUN_PANEL_GET_MAX_RECIPE_TRADE_COUNT("PVP_MINE_41") +
                                                       INDUN_PANEL_GET_MAX_RECIPE_TRADE_COUNT("PVP_MINE_42")) .. ")")

            challengeexpertcount:SetText("{ol}{#FFFFFF}{s16}(" ..
                                             GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 647).PlayPerResetType) ..
                                             "" .. ")")

        end

        -- 80017ファロ掃討　/80015ロゼ掃討　/80016プロパ掃討
        if g.settings.spreader_checkbox == 1 then
            local spreadersweepcount = GET_CHILD_RECURSIVELY(ipframe, "spreadersweepcount")
            spreadersweepcount:SetText("{ol}{#FFFFFF}{s16}(" .. indun_panel_sweep_count(80016) .. ")")
            local spreadercount = GET_CHILD_RECURSIVELY(ipframe, "spreadercount")
            spreadercount:SetText("{ol}{#FFFFFF}{s16}(" ..
                                      GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 676).PlayPerResetType) .. "/" ..
                                      GET_INDUN_MAX_ENTERANCE_COUNT(GetClassByType("Indun", 676).PlayPerResetType) ..
                                      ")")
        end

        if g.settings.falouros_checkbox == 1 then
            local falosweepcount = GET_CHILD_RECURSIVELY(ipframe, "falosweepcount")
            falosweepcount:SetText("{ol}{#FFFFFF}{s16}(" .. indun_panel_sweep_count(80017) .. ")")
            local falocount = GET_CHILD_RECURSIVELY(ipframe, "falocount")
            falocount:SetText("{ol}{#FFFFFF}{s16}(" ..
                                  GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 676).PlayPerResetType) .. "/" ..
                                  GET_INDUN_MAX_ENTERANCE_COUNT(GetClassByType("Indun", 676).PlayPerResetType) .. ")")
        end

        if g.settings.roze_checkbox == 1 then
            local rozesweepcount = GET_CHILD_RECURSIVELY(ipframe, "rozesweepcount")
            rozesweepcount:SetText("{ol}{#FFFFFF}{s16}(" .. indun_panel_sweep_count(80015) .. ")")
            local rozecount = GET_CHILD_RECURSIVELY(ipframe, "rozecount")
            rozecount:SetText("{ol}{#FFFFFF}{s16}(" ..
                                  GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 679).PlayPerResetType) .. "/" ..
                                  GET_INDUN_MAX_ENTERANCE_COUNT(GetClassByType("Indun", 679).PlayPerResetType) .. ")")
        end

        if g.settings.Upinis_checkbox == 1 then
            local upiniscount = GET_CHILD_RECURSIVELY(ipframe, "upiniscount")
            upiniscount:SetText("{ol}{#FFFFFF}{s16}(" ..
                                    GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 686).PlayPerResetType) .. "/" ..
                                    GET_INDUN_MAX_ENTERANCE_COUNT(GetClassByType("Indun", 686).PlayPerResetType) .. ")")

            local upinissweepcount = GET_CHILD_RECURSIVELY(ipframe, "upinissweepcount")
            upinissweepcount:SetText("{ol}{#FFFFFF}{s16}(" .. indun_panel_sweep_count(80030) .. ")")
        end

        if g.settings.Slogutis_checkbox == 1 then
            local slogutiscount = GET_CHILD_RECURSIVELY(ipframe, "slogutiscount")
            slogutiscount:SetText("{ol}{#FFFFFF}{s16}(" ..
                                      GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 689).PlayPerResetType) .. "/" ..
                                      GET_INDUN_MAX_ENTERANCE_COUNT(GetClassByType("Indun", 689).PlayPerResetType) ..
                                      ")")

            local slogutissweepcount = GET_CHILD_RECURSIVELY(ipframe, "slogutissweepcount")
            slogutissweepcount:SetText("{ol}{#FFFFFF}{s16}(" .. indun_panel_sweep_count(80031) .. ")")
        end

        if g.settings.earring_checkbox == 1 then
            local earringcounthard = GET_CHILD_RECURSIVELY(ipframe, "earringcounthard")
            earringcounthard:SetText("{ol}{#FFFFFF}{s16}(" ..
                                         GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 663).PlayPerResetType) ..
                                         ")")
        end

        if g.settings.giltine_checkbox == 1 then
            local giltinecounthard = GET_CHILD_RECURSIVELY(ipframe, "giltinecounthard")
            giltinecounthard:SetText("{ol}{#FFFFFF}{s16}(" ..
                                         GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 628).PlayPerResetType) ..
                                         ")")
        end
        ipframe:Invalidate()

        return 1
    else

        return 0
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
            redButton = GET_CHILD_RECURSIVELY(frame, "Delmorehard")
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

-- イヤリングレイド処理
function indun_panel_earring_frame(ipframe)
    local earring = ipframe:CreateOrGetControl("richtext", "earring", 15, g.panelY)
    earring:SetText("{ol}{#FFFFFF}" .. INDUN_PANEL_LANG("{s20}Earring"))
    local earringsolo = ipframe:CreateOrGetControl('button', 'earringsolo', 135, g.panelY, 80, 30)
    local earringnormal = ipframe:CreateOrGetControl('button', 'earringauto', 220, g.panelY, 80, 30)
    local earringhard = ipframe:CreateOrGetControl('button', 'earringhard', 305, g.panelY, 80, 30)
    local earringcounthard = ipframe:CreateOrGetControl("richtext", "earringcounthard", 390, g.panelY + 5, 50, 30)

    earringsolo:SetText("{ol}SOLO")
    earringnormal:SetText("{ol}{s14}NORMAL")
    earringhard:SetText("{ol}{#FF0000}HARD")

    earringcounthard:SetText("{ol}{#FFFFFF}{s16}(" ..
                                 GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 663).PlayPerResetType) .. ")")

    -- earringsolo:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_earringsolo")
    earringsolo:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_solo")
    earringsolo:SetEventScriptArgNumber(ui.LBUTTONUP, 661)
    -- earringnormal:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_earringnormal")
    earringnormal:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_solo")
    earringnormal:SetEventScriptArgNumber(ui.LBUTTONUP, 662)
    -- earringhard:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_earringhard")
    earringhard:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_solo")
    earringhard:SetEventScriptArgNumber(ui.LBUTTONUP, 663)
    ipframe:ShowWindow(1)

end

-- ギルティネレイド処理
function indun_panel_giltine_frame(ipframe)
    local giltine = ipframe:CreateOrGetControl("richtext", "giltine", 15, g.panelY)
    giltine:SetText("{ol}{#FFFFFF}" .. INDUN_PANEL_LANG("{s20}Giltine"))
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

    -- giltinesolo:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_giltine_solo")
    giltinesolo:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_solo")
    giltinesolo:SetEventScriptArgNumber(ui.LBUTTONUP, 669)

    -- giltineauto:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_giltine_auto")
    giltineauto:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_auto")
    giltineauto:SetEventScriptArgNumber(ui.LBUTTONUP, 635)

    -- g.giltine_hard_flag = false
    -- giltinehard:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_giltine_hard")
    giltinehard:SetEventScript(ui.LBUTTONDOWN, "indun_panel_enter_hard")
    giltinehard:SetEventScriptArgNumber(ui.LBUTTONDOWN, 628)
    giltinehard:SetEventScriptArgString(ui.LBUTTONDOWN, "false")
end

-- デルムーア処理
function indun_panel_Delmore_frame(ipframe)
    local delmore = ipframe:CreateOrGetControl("richtext", "delmore", 15, g.panelY)
    delmore:SetText("{ol}{#FFFFFF}" .. INDUN_PANEL_LANG("{s20}Delmore"))
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

    -- Delmoresolo:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_Delmore_solo")
    Delmoresolo:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_solo")
    Delmoresolo:SetEventScriptArgNumber(ui.LBUTTONUP, 667)

    -- Delmoreauto:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_Delmore_auto")
    Delmoreauto:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_auto")
    Delmoreauto:SetEventScriptArgNumber(ui.LBUTTONUP, 666)

    -- g.Delmore_hard_flag = false
    -- Delmorehard:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_Delmore_hard")
    Delmorehard:SetEventScript(ui.LBUTTONDOWN, "indun_panel_enter_hard")
    Delmorehard:SetEventScriptArgNumber(ui.LBUTTONDOWN, 665)
    Delmorehard:SetEventScriptArgString(ui.LBUTTONDOWN, "false")

end

-- クラゲ処理
function indun_panel_jellyzele_frame(ipframe)
    local jellyzele = ipframe:CreateOrGetControl("richtext", "jellyzele", 15, g.panelY)
    jellyzele:SetText("{ol}{#FFFFFF}" .. INDUN_PANEL_LANG("{s20}Jellyzele"))
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

    -- jellyzelesolo:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_jellyzele_solo")
    jellyzelesolo:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_solo")
    jellyzelesolo:SetEventScriptArgNumber(ui.LBUTTONUP, 672)

    -- jellyzeleauto:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_jellyzele_auto")
    jellyzeleauto:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_auto")
    jellyzeleauto:SetEventScriptArgNumber(ui.LBUTTONUP, 671)

    -- g.jellyzele_hard_flag = false
    -- jellyzelehard:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_jellyzele_hard")
    jellyzelehard:SetEventScript(ui.LBUTTONDOWN, "indun_panel_enter_hard")
    jellyzelehard:SetEventScriptArgNumber(ui.LBUTTONDOWN, 670)
    jellyzelehard:SetEventScriptArgString(ui.LBUTTONDOWN, "false")

end

-- プロパゲ処理
function indun_panel_spreader_frame(ipframe)
    local spreader = ipframe:CreateOrGetControl("richtext", "spreader", 15, g.panelY)
    spreader:SetText("{ol}{#FFFFFF}" .. INDUN_PANEL_LANG("{s20}Spreader"))
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

    -- spreadersolo:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_spreader_solo")
    spreadersolo:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_solo")
    spreadersolo:SetEventScriptArgNumber(ui.LBUTTONUP, 674)

    -- spreaderauto:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_spreader_auto")
    spreaderauto:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_auto")
    spreaderauto:SetEventScriptArgNumber(ui.LBUTTONUP, 673)

    -- g.spreader_hard_flag = false
    -- spreaderhard:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_spreader_hard")
    spreaderhard:SetEventScript(ui.LBUTTONDOWN, "indun_panel_enter_hard")
    spreaderhard:SetEventScriptArgNumber(ui.LBUTTONDOWN, 675)
    spreaderhard:SetEventScriptArgString(ui.LBUTTONDOWN, "false")

    -- spreadersweep:SetEventScript(ui.LBUTTONUP, "indun_panel_autosweep_spreader")
    spreadersweep:SetEventScript(ui.LBUTTONUP, "indun_panel_autosweep")
    spreadersweep:SetEventScriptArgNumber(ui.LBUTTONUP, 673)

    local spreadersweepcount = ipframe:CreateOrGetControl("richtext", "spreadersweepcount", 565, g.panelY + 5, 50, 30)
    spreadersweepcount:SetText("{ol}{#FFFFFF}{s16}(" .. indun_panel_sweep_count(80016) .. ")")

end

-- ファロウロス処理
function indun_panel_falo_frame(ipframe)
    local falouros = ipframe:CreateOrGetControl("richtext", "falouros", 15, g.panelY)
    falouros:SetText("{ol}{#FFFFFF}" .. INDUN_PANEL_LANG("{s20}Falouros"))
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

    -- falosolo:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_falo_solo")
    falosolo:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_solo")
    falosolo:SetEventScriptArgNumber(ui.LBUTTONUP, 677)

    -- faloauto:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_falo_auto")
    faloauto:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_auto")
    faloauto:SetEventScriptArgNumber(ui.LBUTTONUP, 676)

    -- g.falo_hard_flag = false
    -- falohard:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_falo_hard")
    falohard:SetEventScript(ui.LBUTTONDOWN, "indun_panel_enter_hard")
    falohard:SetEventScriptArgNumber(ui.LBUTTONDOWN, 678)
    falohard:SetEventScriptArgString(ui.LBUTTONDOWN, "false")

    -- falosweep:SetEventScript(ui.LBUTTONUP, "indun_panel_autosweep_falo")
    falosweep:SetEventScript(ui.LBUTTONUP, "indun_panel_autosweep")
    falosweep:SetEventScriptArgNumber(ui.LBUTTONUP, 676)

    local falosweepcount = ipframe:CreateOrGetControl("richtext", "falosweepcount", 565, g.panelY + 5, 50, 30)
    falosweepcount:SetText("{ol}{#FFFFFF}{s16}(" .. indun_panel_sweep_count(80017) .. ")")

end

-- ロゼ処理
function indun_panel_roze_frame(ipframe)
    local roze = ipframe:CreateOrGetControl("richtext", "roze", 15, g.panelY)
    roze:SetText("{ol}{#FFFFFF}" .. INDUN_PANEL_LANG("{s20}Roze"))
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

    -- rozesolo:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_roze_solo")
    rozesolo:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_solo")
    rozesolo:SetEventScriptArgNumber(ui.LBUTTONUP, 680)

    -- rozeauto:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_roze_auto")
    rozeauto:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_auto")
    rozeauto:SetEventScriptArgNumber(ui.LBUTTONUP, 679)

    -- g.roze_hard_flag = false
    -- rozehard:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_roze_hard")
    rozehard:SetEventScript(ui.LBUTTONDOWN, "indun_panel_enter_hard")
    rozehard:SetEventScriptArgNumber(ui.LBUTTONDOWN, 681)
    rozehard:SetEventScriptArgString(ui.LBUTTONDOWN, "false")

    -- rozesweep:SetEventScript(ui.LBUTTONUP, "indun_panel_autosweep_roze")
    rozesweep:SetEventScript(ui.LBUTTONUP, "indun_panel_autosweep")
    rozesweep:SetEventScriptArgNumber(ui.LBUTTONUP, 679)

    local rozesweepcount = ipframe:CreateOrGetControl("richtext", "rozesweepcount", 565, g.panelY + 5, 50, 30)
    rozesweepcount:SetText("{ol}{#FFFFFF}{s16}(" .. indun_panel_sweep_count(80015) .. ")")

end

-- チャレンジ処理
function indun_panel_challenge_frame(ipframe)
    local challenge = ipframe:CreateOrGetControl("richtext", "challenge", 15, g.panelY)
    challenge:SetText("{ol}{#FFFFFF}" .. INDUN_PANEL_LANG("{s20}Challenge"))

    -- local challengeex = ipframe:CreateOrGetControl("richtext", "challengeex", 15, 85)
    -- challengeex:SetText("{ol}{#FFFFFF}{s16}Singularity")
    local challenge460 = ipframe:CreateOrGetControl('button', 'challenge460', 135, g.panelY, 80, 30)
    challenge460:SetText("{ol}480")
    -- challenge460:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_challenge460")
    challenge460:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_challenge_solo")
    challenge460:SetEventScriptArgNumber(ui.LBUTTONUP, 644)

    local challenge480 = ipframe:CreateOrGetControl('button', 'challenge480', 220, g.panelY, 80, 30)
    challenge480:SetText("{ol}500")
    -- challenge480:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_challenge480")
    challenge480:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_challenge_solo")
    challenge480:SetEventScriptArgNumber(ui.LBUTTONUP, 645)

    local challengept = ipframe:CreateOrGetControl('button', 'challengept', 305, g.panelY, 80, 30)
    challengept:SetText("{ol}{#FFD900}PT")
    -- challengept:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_challengept")
    challengept:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_challenge_pt")
    challengept:SetEventScriptArgNumber(ui.LBUTTONUP, 646)

    local challengecount = ipframe:CreateOrGetControl("richtext", "challengecount", 390, g.panelY + 5, 40, 30)
    challengecount:SetText("{ol}{#FFFFFF}{s16}(" ..
                               GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 646).PlayPerResetType) .. "/" ..
                               GET_INDUN_MAX_ENTERANCE_COUNT(GetClassByType("Indun", 646).PlayPerResetType) .. ")")

    local challengeticket = ipframe:CreateOrGetControl('button', 'challengeticket', 435, g.panelY, 80, 30)
    challengeticket:SetText("{ol}{#EE7800}{s14}BUYUSE")
    challengeticket:SetTextTooltip("{@st59}" .. INDUN_PANEL_LANG(
        "Priority{nl}1. tickets due within 24 hours {nl}2. mercenary coin store tickets (buy and use) {nl}3. tickets due"))
    challengeticket:SetEventScript(ui.LBUTTONUP, "indun_panel_item_use")
    challengeticket:SetEventScriptArgNumber(ui.LBUTTONUP, 644)

    local challengeticketcount = ipframe:CreateOrGetControl("richtext", "challengeticketcount", 520, g.panelY + 5, 40,
        30)
    challengeticketcount:SetText("{ol}{#FFFFFF}{s16}(" .. INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_40") .. "/" ..
                                     INDUN_PANEL_GET_MAX_RECIPE_TRADE_COUNT("PVP_MINE_40") .. ")")

    --  local challengeexpert = ipframe:CreateOrGetControl('button', 'challengeexpert', 135, 85, 80, 30)
    -- challengeexpert:SetText("{ol}{#FFD900}AUTO")
    -- challengeexpert:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_challengeexpert")
    --  challengeexpert:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_challenge_pt")
    -- challengeexpert:SetEventScriptArgNumber(ui.LBUTTONUP, 647)

    -- ! この下のボタンはまた今度
    --  local challengeexpert2 = ipframe:CreateOrGetControl('button', 'challengeexpert2', 220, 85, 80, 30)
    --  challengeexpert2:SetText("{ol}{#FF0000}EX")
    --  challengeexpert2:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_challenge_pt")
    --  challengeexpert2:SetEventScriptArgNumber(ui.LBUTTONUP, 691)
    -- !

    --  local challengeexpertcount = ipframe:CreateOrGetControl("richtext", "challengeexpertcount", 305, 90, 30, 30)
    --  challengeexpertcount:SetText("{ol}{#FFFFFF}{s16}(" ..
    --                                   GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 647).PlayPerResetType) .. "" ..
    --                                   ")")

    --  local challengeexpertticket = ipframe:CreateOrGetControl('button', 'challengeexpertticket', 335, 85, 80, 30)
    -- challengeexpertticket:SetText("{ol}{#EE7800}{s14}BUYUSE")
    --  challengeexpertticket:SetEventScript(ui.LBUTTONUP, "indun_panel_item_use")
    -- challengeexpertticket:SetEventScriptArgNumber(ui.LBUTTONUP, 647)

    --  local challengeexpertticketcount = ipframe:CreateOrGetControl("richtext", "challengeexpertticketcount", 420, 90, 40,
    --      30)
    --  challengeexpertticketcount:SetText("{ol}{#FFFFFF}{s16}(d" .. INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_41") ..
    --                                         "/w" .. INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_42") .. "/" ..
    --                                         (INDUN_PANEL_GET_MAX_RECIPE_TRADE_COUNT("PVP_MINE_41") +
    --                                             INDUN_PANEL_GET_MAX_RECIPE_TRADE_COUNT("PVP_MINE_42")) .. ")")

end

function indun_panel_challengeex_frame(ipframe)
    -- local challenge = ipframe:CreateOrGetControl("richtext", "challenge", 15, 45)
    -- challenge:SetText("{ol}{#FFFFFF}{s16}Challenge")

    local challengeex = ipframe:CreateOrGetControl("richtext", "challengeex", 15, g.panelY)
    challengeex:SetText("{ol}{#FFFFFF}" .. INDUN_PANEL_LANG("{s20}Singularity"))
    -- local challenge460 = ipframe:CreateOrGetControl('button', 'challenge460', 135, 45, 80, 30)
    -- challenge460:SetText("{ol}480")
    -- challenge460:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_challenge460")
    -- challenge460:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_challenge_solo")
    -- challenge460:SetEventScriptArgNumber(ui.LBUTTONUP, 644)

    -- local challenge480 = ipframe:CreateOrGetControl('button', 'challenge480', 220, 45, 80, 30)
    -- challenge480:SetText("{ol}500")
    -- challenge480:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_challenge480")
    -- challenge480:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_challenge_solo")
    -- challenge480:SetEventScriptArgNumber(ui.LBUTTONUP, 645)

    -- local challengept = ipframe:CreateOrGetControl('button', 'challengept', 305, 45, 80, 30)
    -- challengept:SetText("{ol}{#FFD900}PT")
    -- challengept:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_challengept")
    --  challengept:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_challenge_pt")
    --  challengept:SetEventScriptArgNumber(ui.LBUTTONUP, 646)

    -- local challengecount = ipframe:CreateOrGetControl("richtext", "challengecount", 390, 50, 40, 30)
    -- challengecount:SetText("{ol}{#FFFFFF}{s16}(" ..
    --  GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 646).PlayPerResetType) .. "/" ..
    --  GET_INDUN_MAX_ENTERANCE_COUNT(GetClassByType("Indun", 646).PlayPerResetType) .. ")")

    --  local challengeticket = ipframe:CreateOrGetControl('button', 'challengeticket', 435, 45, 80, 30)
    -- challengeticket:SetText("{ol}{#EE7800}{s14}BUYUSE")
    -- challengeticket:SetEventScript(ui.LBUTTONUP, "indun_panel_item_use")
    --  challengeticket:SetEventScriptArgNumber(ui.LBUTTONUP, 644)

    -- local challengeticketcount = ipframe:CreateOrGetControl("richtext", "challengeticketcount", 520, 50, 40, 30)
    --  challengeticketcount:SetText("{ol}{#FFFFFF}{s16}(" .. INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_40") .. "/" ..
    --                                  INDUN_PANEL_GET_MAX_RECIPE_TRADE_COUNT("PVP_MINE_40") .. ")")

    local challengeexpert = ipframe:CreateOrGetControl('button', 'challengeexpert', 135, g.panelY, 80, 30)
    challengeexpert:SetText("{ol}{#FFD900}AUTO")
    -- challengeexpert:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_challengeexpert")
    challengeexpert:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_challenge_pt")
    challengeexpert:SetEventScriptArgNumber(ui.LBUTTONUP, 647)

    -- ! この下のボタンはまた今度
    local challengeexpert2 = ipframe:CreateOrGetControl('button', 'challengeexpert2', 220, g.panelY, 80, 30)
    challengeexpert2:SetText("{ol}{#FF0000}EX")
    challengeexpert2:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_challenge_pt")
    challengeexpert2:SetEventScriptArgNumber(ui.LBUTTONUP, 691)
    -- !

    local challengeexpertcount = ipframe:CreateOrGetControl("richtext", "challengeexpertcount", 305, g.panelY + 5, 30,
        30)
    challengeexpertcount:SetText("{ol}{#FFFFFF}{s16}(" ..
                                     GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 647).PlayPerResetType) .. "" ..
                                     ")")

    local challengeexpertticket = ipframe:CreateOrGetControl('button', 'challengeexpertticket', 335, g.panelY, 80, 30)
    challengeexpertticket:SetText("{ol}{#EE7800}{s14}BUYUSE")
    challengeexpertticket:SetTextTooltip("{@st59}" .. INDUN_PANEL_LANG(
        "Priority{nl}1. tickets due within 24 hours {nl}2. mercenary coin store tickets (buy and use) {nl}3. tickets due"))
    challengeexpertticket:SetEventScript(ui.LBUTTONUP, "indun_panel_item_use")
    challengeexpertticket:SetEventScriptArgNumber(ui.LBUTTONUP, 647)

    local challengeexpertticketcount = ipframe:CreateOrGetControl("richtext", "challengeexpertticketcount", 420,
        g.panelY + 5, 40, 30)
    challengeexpertticketcount:SetText("{ol}{#FFFFFF}{s16}(d" .. INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_41") ..
                                           "/w" .. INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_42") .. "/" ..
                                           (INDUN_PANEL_GET_MAX_RECIPE_TRADE_COUNT("PVP_MINE_41") +
                                               INDUN_PANEL_GET_MAX_RECIPE_TRADE_COUNT("PVP_MINE_42")) .. ")")

end

-- チャレンジ関係処理
function indun_panel_enter_challenge_pt(frame, ctrl, argStr, argNum)
    ReqChallengeAutoUIOpen(argNum)
    local topFrame = ui.GetFrame("indunenter")
    -- CHAT_SYSTEM(tostring(topFrame:GetName()))
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

function indun_panel_enter_challenge_solo(frame, ctrl, argStr, argNum)
    -- print(argNum)
    ReqChallengeAutoUIOpen(argNum)
    ReqMoveToIndun(1, 0)
end

function indun_panel_enter_solo(frame, ctrl, argStr, argNum)
    -- rint(argNum)
    ReqRaidAutoUIOpen(argNum)
    ReqMoveToIndun(1, 0)
end

function indun_panel_enter_auto(frame, ctrl, argStr, argNum)
    -- print(argNum)

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
    -- print(argNum)
    -- print(tostring(argStr))

    local indunType = argNum
    local indunCls = GetClassByType("Indun", indunType)

    if argStr == "false" then
        local frame = ui.GetFrame("induninfo")
        INDUN_PANEL_INDUNINFO_SET_BUTTONS(indunType)
        argStr = "true"
        ReserveScript(string.format("indun_panel_enter_hard('%s','%s','%s',%d)", frame, ctrl, argStr, argNum), 0.3)
        return
    else
        SHOW_INDUNENTER_DIALOG(indunType, isAlreadyPlaying, enableAutoMatch, enableEnterRight, enablePartyMatch)
        return
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

        -- return
    else
        ui.SysMsg("Does not have a sweeping buff")
        -- return
    end
    ReserveScript("indun_panel_get_sweep_count()", 1.5)
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

function indun_panel_item_use(frame, ctrl, argStr, argNum)

    session.ResetItemList()
    local invItemList = session.GetInvItemList()
    local guidList = invItemList:GetGuidList();
    local cnt = guidList:Count();
    -- local classid = 0
    -- TOSコイン分裂券＝10820018
    -- 1日券＝11030067
    -- トレード不可＝11030021
    -- トレード可＝11030017
    if argNum == 647 then
        -- print(tostring(argNum) .. "ex")
        for i = 0, cnt - 1 do
            local guid = guidList:Get(i);
            local invItem = invItemList:GetItemByGuid(guid)
            local itemobj = GetIES(invItem:GetObject())
            local classid = itemobj.ClassID
            local life_time = GET_REMAIN_ITEM_LIFE_TIME(itemobj)
            -- print(tostring(life_time))
            if life_time ~= nil then
                -- print(classid)
                if classid == 10820018 and GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 647).PlayPerResetType) ==
                    0 and tonumber(life_time) < 86400 then
                    -- print(tostring(classid))
                    INV_ICON_USE(session.GetInvItemByType(tonumber(classid)))
                    return
                end

                if classid == 11030067 and GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 647).PlayPerResetType) ==
                    0 then
                    -- print(tostring(classid) .. 11030067)
                    INV_ICON_USE(session.GetInvItemByType(tonumber(classid)))
                    return
                end
            end
        end

        local dcount = INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_41")
        if dcount == 1 and GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 647).PlayPerResetType) == 0 then
            indun_panel_challengeex_buyuse()
            return
        end

        local wcount = INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_42")
        if wcount >= 1 and GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 647).PlayPerResetType) == 0 then
            indun_panel_challengeex_buyuse()
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
        -- print(tostring(argNum) .. "ch")
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
            -- print(tostring(classid))
            if life_time ~= nil then
                if classid == 10820019 and GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 644).PlayPerResetType) ==
                    1 and tonumber(life_time) < 86400 then
                    -- print(tostring(classid))
                    INV_ICON_USE(session.GetInvItemByType(tonumber(classid)))
                    return
                end

                if classid == 641954 and GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 644).PlayPerResetType) == 1 then
                    -- print(tostring(classid))
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

    --[[for i = 0, cnt - 1 do
            local guid = guidList:Get(i);
            local invItem = invItemList:GetItemByGuid(guid)
            local itemobj = GetIES(invItem:GetObject())
            local classid = itemobj.ClassID
            -- print(tostring(classid))

            if classid == 641953 and GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 644).PlayPerResetType) == 1 then
                print(tostring(classid))
                INV_ICON_USE(session.GetInvItemByType(tonumber(classid)))
                return
            end
        end

        for i = 0, cnt - 1 do
            local guid = guidList:Get(i);
            local invItem = invItemList:GetItemByGuid(guid)
            local itemobj = GetIES(invItem:GetObject())
            local classid = itemobj.ClassID
            -- print(tostring(classid))

            if classid == 641987 and GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 644).PlayPerResetType) == 1 then
                print(tostring(classid))
                INV_ICON_USE(session.GetInvItemByType(tonumber(classid)))
                return
            end
        end]]

    --[[for i = 0, cnt - 1 do
            local guid = guidList:Get(i);
            local invItem = invItemList:GetItemByGuid(guid)
            local itemobj = GetIES(invItem:GetObject())
            local classid = itemobj.ClassID
            print(tostring(classid))

            if classid == 641963 and GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 644).PlayPerResetType) == 1 then
                print(tostring(classid))
                local msg = itemobj.ClassName .. "Do you use premium tickets that can be sold on the market?"
                local yesscp = string.format("INV_ICON_USE(session.GetInvItemByType(tonumber(classid)))")
                local noscp = string.format("indun_panel_challenge_buyuse()")
                ui.MsgBox(msg, yesscp, noscp)

                return
            end
            -- 

        end]]

end

function indun_panel_challengeex_buyuse()

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

-- オート掃討の数をキャラのバフ欄から取得して返す
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

    --[[local loginCharID = info.GetCID(session.GetMyHandle())

    if g.settings.loginCID ~= nil then
        local foundMatch = false

        for i = 1, #g.settings.loginCID do
            local token = StringSplit(g.settings.loginCID[i], '/')
            print(tostring(token[1]))
            print(tostring(token[2]))

            if tostring(token[1]) == tostring(loginCharID) and tostring(token[2]) == tostring(buffid) and
                tostring(token[3]) == tostring(sweepcount) then
                foundMatch = true
                break
            end
        end

        if not foundMatch then
            -- マッチが見つからない場合、新しいエントリを追加
            table.insert(g.settings.loginCID, loginCharID .. "/" .. buffid .. "/" .. sweepcount)
            indun_panel_save_settings()
        end
    else
        -- g.settings.loginCIDがnilの場合、新しいテーブルを作成してエントリを追加
        g.settings.loginCID = {loginCharID .. "/" .. buffid .. "/" .. sweepcount}
        indun_panel_save_settings()
    end]]

    -- g.settings.loginCID = {loginCharID .. "/" .. buffid .. "/" .. sweepcount}

    return sweepcount

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
    -- CHAT_SYSTEM(overbuy_count)
    -- print(INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_52"))

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

        local frame = ui.GetFrame('earthtowershop')

        ReserveScript(string.format("INDUN_PANEL_EARTHTOWERSHOP_CLOSE('%s')", frame), 1.5)
        g.ex = 2

        return 0
    end
    return 1
end

-- 傭兵団コインショップ閉める
function INDUN_PANEL_EARTHTOWERSHOP_CLOSE(shopframe)
    local shopframe = ui.GetFrame('earthtowershop')
    ui.CloseFrame('earthtowershop')

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
        settings = g.settings
    end

    g.settings = settings
end

--[[倉庫を〆た時にインベントリーを開く
function INDUN_PANEL_ACCOUNTWAREHOUSE_CLOSE(frame, msg)
    local frame = ui.GetFrame("inventory")
    frame = acutil.getEventArgs(msg);

    ReserveScript(string.format("INDUN_PANEL_INVENTORY_OPEN('%s')", frame, 1.0))

end]]

--[[チーム倉庫開けようとしたけど無理やった
function INDUN_PANEL_ON_OPEN_ACCOUNTWAREHOUSE()

    new_add_item = {}
    new_stack_add_item = {}
    custom_title_name = {}

    ui.OpenFrame("accountwarehouse");
end]]

--[[多分当日分裂チケットの名残
function indun_panel_shop_open()
    -- if INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_41") == 1 then
    -- g.ex = 1
    -- end

    -- if g.ex ~= 1 then
    local shopframe = ui.GetFrame('earthtowershop')
    pc.ReqExecuteTx_NumArgs("SCR_PVP_MINE_SHOP_OPEN", 0);

    local ipframe = ui.GetFrame("indun_panel")
    local challengeexpertticketcount = GET_CHILD_RECURSIVELY(ipframe, 'challengeexpertticketcount')
    ipframe:RemoveChild(challengeexpertticketcount)
    challengeexpertticketcount:SetText("{ol}{#FFFFFF}{s16}(d" .. INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_41") ..
                                           "/w" .. INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_42") .. "/" ..
                                           (INDUN_PANEL_GET_MAX_RECIPE_TRADE_COUNT("PVP_MINE_41") +
                                               INDUN_PANEL_GET_MAX_RECIPE_TRADE_COUNT("PVP_MINE_42")) .. ")")
    ipframe:Invalidate()
    indun_panel_challengeex_buyuse()
    ReserveScript(string.format("INDUN_PANEL_EARTHTOWERSHOP_CLOSE('%s')", shopframe), 1.0)
    return
    -- else
    --      indun_panel_challengeex_buyuse()
    --  end

end]]

--[[ オート掃討の表示処理
function indun_panel_autosweep_get_count(ipframe)
    -- 80017ファロ掃討　/80015ロゼ掃討　/80016プロパ掃討

    local rBuffID = 80015 -- 対象のバフID
    local sweepcount = 0

    sweepcount = indun_panel_sweep_count(rBuffID)
    rozesweepcount:SetText("{ol}{#FFFFFF}{s16}(" .. sweepcount .. ")")

    local fBuffID = 80017 -- 対象のバフID
    sweepcount = indun_panel_sweep_count(fBuffID)
    falosweepcount:SetText("{ol}{#FFFFFF}{s16}(" .. sweepcount .. ")")

    local sBuffID = 80016 -- 対象のバフID
    sweepcount = indun_panel_sweep_count(sBuffID)
    spreadersweepcount:SetText("{ol}{#FFFFFF}{s16}(" .. sweepcount .. ")")

end]]

--[[function indun_panel_enter_earringsolo()
    ReqRaidAutoUIOpen(661)
    ReqMoveToIndun(1, 0)
end

function indun_panel_enter_earringnormal()
    ReqRaidAutoUIOpen(662)
    ReqMoveToIndun(1, 0)
end

function indun_panel_enter_earringhard()
    ReqRaidAutoUIOpen(663)
    ReqMoveToIndun(1, 0)
end]]

--[[function indun_panel_enter_giltine_hard()

    local indunType = 628
    local indunCls = GetClassByType("Indun", indunType)

    if g.giltine_hard_flag == false then

        local frame = ui.GetFrame("induninfo")

        INDUN_PANEL_INDUNINFO_SET_BUTTONS(indunType)

        g.giltine_hard_flag = true
        ReserveScript("indun_panel_enter_giltine_hard()", 0.5)

    elseif g.giltine_hard_flag == true then

        SHOW_INDUNENTER_DIALOG(indunType, isAlreadyPlaying, enableAutoMatch, enableEnterRight, enablePartyMatch)
        g.giltine_hard_flag = false
        return
    end
end

function indun_panel_enter_giltine_auto()

    ReqRaidAutoUIOpen(635)
    local topFrame = ui.GetFrame("indunenter")
    -- CHAT_SYSTEM(tostring(topFrame:GetName()))
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

function indun_panel_enter_giltine_solo()
    -- CHAT_SYSTEM("solo")
    ReqRaidSoloUIOpen(669)
    ReqMoveToIndun(1, 0)
end]]

--[[ テルハルシャ処理
function indun_panel_enter_telharsha_solo()
    ReqRaidSoloUIOpen(623)
    ReqMoveToIndun(1, 0)
end]]

--[[function indun_panel_enter_Delmore_hard()
    local indunType = 665

    if g.Delmore_hard_flag == false then
        INDUN_PANEL_INDUNINFO_SET_BUTTONS(indunType)
        g.Delmore_hard_flag = true
        ReserveScript("indun_panel_enter_Delmore_hard()", 0.5)
        -- else
    elseif g.Delmore_hard_flag == true then

        local frame = ui.GetFrame("indunenter")
        frame:ShwWindow(1)
        SHOW_INDUNENTER_DIALOG(indunType, isAlreadyPlaying, enableAutoMatch, enableEnterRight, enablePartyMatch)
        g.Delmore_hard_flag = false
        return
    end

end

function indun_panel_enter_Delmore_auto()

    ReqRaidAutoUIOpen(666)
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

function indun_panel_enter_Delmore_solo()

    ReqRaidSoloUIOpen(667)
    ReqMoveToIndun(1, 0)
end]]

--[[function indun_panel_enter_jellyzele_hard()

    local indunType = 670

    if g.jellyzele_hard_flag == false then
        INDUN_PANEL_INDUNINFO_SET_BUTTONS(indunType)
        g.jellyzele_hard_flag = true
        ReserveScript("indun_panel_enter_jellyzele_hard()", 0.5)
        -- else
    elseif g.jellyzele_hard_flag == true then

        local frame = ui.GetFrame("indunenter")
        frame:ShwWindow(1)
        SHOW_INDUNENTER_DIALOG(indunType, isAlreadyPlaying, enableAutoMatch, enableEnterRight, enablePartyMatch)
        g.jellyzele_hard_flag = false
        return
    end
end

function indun_panel_enter_jellyzele_auto()

    ReqRaidAutoUIOpen(671)
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

function indun_panel_enter_jellyzele_solo()

    ReqRaidSoloUIOpen(672)
    ReqMoveToIndun(1, 0)
end]]

--[[function indun_panel_autosweep_spreader()
    local indun_classid = tonumber(673);
    local sBuffID = 80016 -- 対象のバフID
    local sweepcount = 0
    sweepcount = indun_panel_sweep_count(sBuffID)
    if sweepcount >= 1 then
        ReqUseRaidAutoSweep(indun_classid);

        return
    else

        ui.SysMsg("Does not have a sweeping buff")
        return
    end
end

function indun_panel_enter_spreader_hard()

    local indunType = 675
    if g.spreader_hard_flag == false then
        INDUN_PANEL_INDUNINFO_SET_BUTTONS(indunType)
        g.spreader_hard_flag = true
        ReserveScript("indun_panel_enter_spreader_hard()", 0.5)
        -- else
    elseif g.spreader_hard_flag == true then

        local frame = ui.GetFrame("indunenter")
        frame:ShwWindow(1)
        SHOW_INDUNENTER_DIALOG(indunType, isAlreadyPlaying, enableAutoMatch, enableEnterRight, enablePartyMatch)
        g.spreader_hard_flag = false
        -- ReqMoveToIndun(1, 0)
        return
    end
end

function indun_panel_enter_spreader_auto()
    ReqRaidAutoUIOpen(673)
    local topFrame = ui.GetFrame("indunenter")
    -- CHAT_SYSTEM(tostring(topFrame:GetName()))
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

function indun_panel_enter_spreader_solo()
    ReqRaidSoloUIOpen(674)
    ReqMoveToIndun(1, 0)
end]]

--[[function indun_panel_enter_falo_hard()

    local indunType = 678
    if g.falo_hard_flag == false then
        INDUN_PANEL_INDUNINFO_SET_BUTTONS(indunType)
        g.falo_hard_flag = true
        ReserveScript("indun_panel_enter_falo_hard()", 0.5)
        -- else
    elseif g.falo_hard_flag == true then

        local frame = ui.GetFrame("indunenter")
        frame:ShwWindow(1)
        SHOW_INDUNENTER_DIALOG(indunType, isAlreadyPlaying, enableAutoMatch, enableEnterRight, enablePartyMatch)
        g.falo_hard_flag = false
        return
    end
end

function indun_panel_enter_falo_auto()
    ReqRaidAutoUIOpen(676)
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

function indun_panel_enter_falo_solo()
    ReqRaidSoloUIOpen(677)
    ReqMoveToIndun(1, 0)
end

function indun_panel_autosweep_falo()
    local indun_classid = tonumber(676);
    local fBuffID = 80017
    local sweepcount = 0
    sweepcount = indun_panel_sweep_count(fBuffID)
    if sweepcount >= 1 then
        ReqUseRaidAutoSweep(indun_classid);

        return
    else

        ui.SysMsg("Does not have a sweeping buff")
        return
    end

end]]

--[[function indun_panel_enter_roze_hard()

    local indunType = 681
    if g.roze_hard_flag == false then
        INDUN_PANEL_INDUNINFO_SET_BUTTONS(indunType)
        g.roze_hard_flag = true
        ReserveScript("indun_panel_enter_roze_hard()", 0.5)

    elseif g.roze_hard_flag == true then

        local frame = ui.GetFrame("indunenter")
        frame:ShwWindow(1)
        SHOW_INDUNENTER_DIALOG(indunType, isAlreadyPlaying, enableAutoMatch, enableEnterRight, enablePartyMatch)
        g.roze_hard_flag = false
        -- ReqMoveToIndun(3, 1)
        return
    end
end

function indun_panel_enter_roze_auto()
    ReqRaidAutoUIOpen(679)
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

function indun_panel_enter_roze_solo()
    ReqRaidSoloUIOpen(680)
    ReqMoveToIndun(1, 0)
end

function indun_panel_autosweep_roze()
    local indun_classid = tonumber(679);

    local rBuffID = 80015 -- 対象のバフID
    local sweepcount = 0
    sweepcount = indun_panel_sweep_count(rBuffID)
    if sweepcount >= 1 then
        ReqUseRaidAutoSweep(indun_classid);

        return
    else
        ui.SysMsg("Does not have a sweeping buff")
        return
    end

end]]

--[[function indun_panel_enter_challenge480()
    ReqChallengeAutoUIOpen(645)
    ReqMoveToIndun(1, 0)
end

function indun_panel_enter_challengept()
    ReqChallengeAutoUIOpen(646)
    local topFrame = ui.GetFrame("indunenter")
    -- CHAT_SYSTEM(tostring(topFrame:GetName()))
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

function indun_panel_enter_challengeexpert()
    ReqChallengeAutoUIOpen(647)
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

end]]

--[[function indun_panel_enter_challenge460()
    ReqChallengeAutoUIOpen(644)
    ReqMoveToIndun(1, 0)
end]]

