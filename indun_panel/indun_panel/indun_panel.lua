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
-- v1.5.0 ヴェルニケチケット周り再修正。チャレと分裂のチケット使用時のコード見直し。
-- v1.5.1 装備加工とか付けた。ヴェルニケバグってたクヤシイTOSイベコイン表示とか。レティワープ付けた。
-- v1.5.2 バグ修正
-- v1.5.3 傭兵団コインのチャレンジ券変換をMAXまで出来る様に。そんなヤツおるんか？バグ修正
-- v1.5.4 レダニア足したけどまだテスト出来てない
-- v1.5.5 チャレンジ系をいじった
-- v1.5.6 フレーム移動出来るように
-- v1.5.7 移動後フレーム固定
-- v1.5.8 フレーム固定を設定に変更。墓チケットを使える様に。その他コード見直しacutilやめた。
-- v1.5.9 傭兵団コインの1日分裂券バグってたの修正。でもIMCが勝手に仕様変更したのもアカンと思うんです。
-- v1.6.0 ヴェルニケBUYUSEで入れる様に。マーケットボタン。テスト的にフィールドでも表示出来る様に。
-- v1.6.1 閉じてる時に出すアイコン選べる様に。ilvと一部統合。
-- v1.6.2 チャレ券4枚で分裂券作って入場まで。アイコンバグ修正。
-- v1.6.3 傭兵団チャレ券オーバーバイの場合にUIおかしかったの修正。フィールドの仕様も修正。チャレンジ券の切替時分かりやすく
local addonName = "indun_panel"
local addon_name_lower = string.lower(addonName)
local author = "norisan"
local ver = "1.6.3"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}

local g = _G["ADDONS"][author][addonName]
local json = require('json')

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

        return table.unpack(original_results)

    end

    _G[origin_func_name] = hooked_function

    if not g.REGISTER[origin_func_name] then -- g.REGISTERはON_INIT内で都度初期化
        g.REGISTER[origin_func_name] = true
        my_addon:RegisterMsg(origin_func_name, my_func_name)
    end
end

function g.mkdir_new_folder()
    local function create_folder(folder_path, file_path)
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

    local folder = string.format("../addons/%s", addon_name_lower)
    local file_path = string.format("../addons/%s/mkdir.txt", addon_name_lower)
    create_folder(folder, file_path)

    g.active_id = session.loginInfo.GetAID()
    local user_folder = string.format("../addons/%s/%s", addon_name_lower, g.active_id)
    local user_file_path = string.format("../addons/%s/%s/mkdir.txt", addon_name_lower, g.active_id)
    create_folder(user_folder, user_file_path)

    g.settingsFileLoc = string.format("../addons/%s/%s/settings.json", addon_name_lower, g.active_id)
    g.settings_path = g.settingsFileLoc
end
g.mkdir_new_folder()

function indun_panel_autozoom_init()

    local frame = ui.GetFrame("indun_panel")
    frame:SetSkinName('None')
    frame:SetLayerLevel(30)
    frame:Resize(140, 40)
    local rect = frame:GetMargin()
    frame:SetGravity(ui.RIGHT, ui.TOP)
    frame:SetMargin(rect.left, rect.top, rect.right + 140, rect.bottom)
    frame:SetTitleBarSkin("None")
    frame:EnableHittestFrame(1)
    frame:RemoveAllChild()

    local zoomedit = frame:CreateOrGetControl('edit', 'zoomedit', 80, 0, 60, 30)
    AUTO_CAST(zoomedit)
    zoomedit:SetText("{ol}" .. g.settings.zoom)
    zoomedit:SetFontName("white_16_ol")
    zoomedit:SetTextAlign("center", "center")
    zoomedit:SetEventScript(ui.ENTERKEY, "indun_panel_autozoom_save")
    zoomedit:SetTextTooltip(g.lang == "Japanese" and
                                "{ol}Auto Zoom Setting{nl}1～700の値で入力。標準は336。マップ切り替え時に入力の値までZoomします。0入力で機能無効化。" or
                                "{ol}Auto Zoom Setting{nl}Input a value from 0 to 700. Standard is 336. Zoom to the input value when switching maps.{nl}Disable function by inputting 0.")
    frame:ShowWindow(1)
end

function indun_panel_autozoom()
    if g.settings.zoom ~= 0 then
        camera.CustomZoom(tonumber(g.settings.zoom))
    end
end

function indun_panel_challenge(frame)

    if not g.challenge_start_time then
        frame:StopUpdateScript("indun_panel_challenge")
        return 0
    end

    local now = imcTime.GetAppTimeMS()
    if (now - g.challenge_start_time) >= 3000 then
        frame:StopUpdateScript("indun_panel_challenge")
        g.challenge_start_time = nil
        return 0
    end

    local isAutoChallengeMap = session.IsAutoChallengeMap()
    local isSoloChallengeMap = session.IsSoloChallengeMap()

    if isAutoChallengeMap == true or isSoloChallengeMap == true then
        frame:ShowWindow(0)
        frame:StopUpdateScript("indun_panel_challenge")
        g.challenge_start_time = nil
        return 0
    end
    return 1
end

function indun_panel_GAME_START_3SEC()

    indun_panel_autozoom()

    local frame = ui.GetFrame("indun_panel")

    g.challenge_start_time = imcTime.GetAppTimeMS()

    frame:StopUpdateScript("indun_panel_challenge")
    frame:RunUpdateScript("indun_panel_challenge", 0.1)
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

    g.save_settings()
    ReserveScript("indun_panel_autozoom()", 1.0)
end

function indun_panel_frame_drag(frame, ctrl, str, num)
    g.settings.x = frame:GetX()
    g.settings.y = frame:GetY()
    g.save_settings()

    --[[frame:SetSkinName('None')
    frame:SetTitleBarSkin("None")
    frame:Resize(140, 40)

    local button = GET_CHILD(frame, "indun_panel_open")
    AUTO_CAST(button)
    button:SetText("{ol}{s10}INDUNPANEL")]]
    indun_panel_frame_init()
end

function indun_panel_always_init(frame, ctrl, str)

    if str == "OPEN" then

        g.settings.checkbox = 1
        indun_panel_init(frame)

    else
        g.settings.checkbox = 0
        indun_panel_frame_init()
    end
    g.save_settings()
end

function indun_panel_frame_init()

    local frame = ui.GetFrame("indun_panel")

    frame:SetSkinName('None')
    frame:SetLayerLevel(30)

    frame:EnableHittestFrame(1)
    frame:EnableMove(g.settings.move or 0)
    frame:SetEventScript(ui.LBUTTONUP, "indun_panel_frame_drag")
    -- frame:SetPos(665, 30)
    local map_frame = ui.GetFrame("map")
    local width = map_frame:GetWidth()

    if not g.settings.x then
        g.settings.x = 665
        g.settings.y = 30
        g.save_settings()
    end

    local x = g.settings.x
    if width <= 1920 and x > 1920 then
        x = g.settings.x / 21 * 16
    end

    frame:SetPos(x, g.settings.y)
    frame:SetTitleBarSkin("None")
    frame:EnableHittestFrame(1)
    frame:RemoveAllChild()

    local button = frame:CreateOrGetControl("button", "indun_panel_open", 5, 5, 80, 30)
    AUTO_CAST(button)
    button:SetText("{ol}{s10}INDUNPANEL")
    button:SetEventScript(ui.LBUTTONUP, "indun_panel_init")
    button:SetEventScript(ui.RBUTTONUP, "indun_panel_always_init")
    button:SetEventScriptArgString(ui.RBUTTONUP, "OPEN")
    button:SetTextTooltip(g.lang == "Japanese" and "{ol}右クリック: 常時展開で開く" or
                              "{ol}Right click: Open in Always Expand")

    local ccbtn = frame:CreateOrGetControl('button', 'ccbtn', 85, 5, 30, 30)
    AUTO_CAST(ccbtn)
    ccbtn:SetSkinName("None")
    ccbtn:SetText("{img barrack_button_normal 30 30}")
    if type(_G["indun_list_viewer_title_frame_open"]) ~= "function" or type(_G["INSTANTCC_APPS_TRY_MOVE_BARRACK"]) ~=
        "function" then
        ccbtn:SetEventScript(ui.LBUTTONUP, "APPS_TRY_MOVE_BARRACK")
        ccbtn:SetTextTooltip(g.lang == "Japanese" and "{ol}バラックに戻ります" or "{ol}Return to Barracks")
    else
        ccbtn:SetEventScript(ui.LBUTTONUP, "indun_list_viewer_title_frame_open")
        ccbtn:SetTextTooltip("{ol}[ILV]open")
        local indun_list_viewer = ui.GetFrame("indun_list_viewer")
        if indun_list_viewer:IsVisible() == 1 then
            indun_list_viewer:ShowWindow(0)
        end
    end

    local x = 115

    local temp_tbl = {"tos", "gabija", "vakarine", "rada", "jurate", "pvp_mine", "market", "craft", "leticia"}

    if not g.settings.cols then
        g.settings.cols = {}
        for _, key_name in ipairs(temp_tbl) do
            if key_name == "leticia" then
                g.settings.cols[key_name] = 1
            else
                g.settings.cols[key_name] = 0
            end
        end

        g.save_settings()
    end

    local account_obj = GetMyAccountObj()
    local coin_count = 0

    for _, key_name in ipairs(temp_tbl) do
        if g.settings.cols[key_name] == 1 then
            local tooltip_msg = ""
            if key_name == "tos" then
                if g.get_map_type() == "City" then
                    local tosshop = frame:CreateOrGetControl("button", "tosshop", x, 8, 25, 25);
                    AUTO_CAST(tosshop)
                    tosshop:SetSkinName("None")
                    tosshop:SetText("{img icon_item_Tos_Event_Coin 25 25}")
                    coin_count = GET_COMMAED_STRING(TryGetProp(account_obj, "EVENT_TOS_WHOLE_TOTAL_COIN", "0"))
                    tooltip_msg = g.lang == "Japanese" and "{ol}TOSイベントショップ" or "{ol}TOS Event Shop"
                    tosshop:SetTextTooltip(tooltip_msg)
                    tosshop:SetEventScript(ui.LBUTTONDOWN, "INDUN_PANEL_EARTHTOWERSHOP_CLOSE_RESTART")
                    tosshop:SetEventScript(ui.LBUTTONUP, "indun_panel_event_tos_whole_shop_open")
                end
            elseif key_name == "gabija" then
                if g.get_map_type() == "City" then
                    local gabija = frame:CreateOrGetControl("button", "gabija", x, 7, 29, 29);
                    AUTO_CAST(gabija)
                    gabija:SetSkinName("None")
                    gabija:SetText("{img goddess_shop_btn 29 29}")
                    coin_count = GET_COMMAED_STRING(TryGetProp(account_obj, "GabijaCertificate", "0"))
                    tooltip_msg =
                        g.lang == "Japanese" and "{ol}ガビヤショップ{nl}" .. "{#FFFF00}" .. coin_count or
                            "{ol}Gabija Shop{nl}" .. "{#FFFF00}" .. coin_count
                    gabija:SetTextTooltip(tooltip_msg)
                    gabija:SetEventScript(ui.LBUTTONDOWN, "INDUN_PANEL_EARTHTOWERSHOP_CLOSE_RESTART")
                    gabija:SetEventScript(ui.LBUTTONUP, "REQ_GabijaCertificate_SHOP_OPEN")
                end
            elseif key_name == "vakarine" then
                if g.get_map_type() == "City" then
                    local vakarine = frame:CreateOrGetControl("button", "vakarine", x, 7, 29, 29);
                    AUTO_CAST(vakarine)
                    vakarine:SetSkinName("None")
                    vakarine:SetText("{img goddess2_shop_btn 29 29}")
                    coin_count = GET_COMMAED_STRING(TryGetProp(account_obj, "VakarineCertificate", "0"))
                    tooltip_msg = g.lang == "Japanese" and "{ol}ヴァカリネショップ{nl}" .. "{#FFFF00}" ..
                                      coin_count or "{ol}Vakarine Shop{nl}" .. "{#FFFF00}" .. coin_count
                    vakarine:SetTextTooltip(tooltip_msg)
                    vakarine:SetEventScript(ui.LBUTTONDOWN, "INDUN_PANEL_EARTHTOWERSHOP_CLOSE_RESTART")
                    vakarine:SetEventScript(ui.LBUTTONUP, "REQ_VakarineCertificate_SHOP_OPEN")
                end
            elseif key_name == "rada" then
                if g.get_map_type() == "City" then
                    local rada = frame:CreateOrGetControl("button", "rada", x, 8, 29, 29);
                    AUTO_CAST(rada)
                    rada:SetSkinName("None")
                    rada:SetText("{img goddess3_shop_btn 29 29}")
                    coin_count = GET_COMMAED_STRING(TryGetProp(account_obj, "RadaCertificate", "0"))
                    tooltip_msg = g.lang == "Japanese" and "{ol}ラダショップ{nl}" .. "{#FFFF00}" .. coin_count or
                                      "{ol}Rada Shop{nl}" .. "{#FFFF00}" .. coin_count
                    rada:SetTextTooltip(tooltip_msg)
                    rada:SetEventScript(ui.LBUTTONDOWN, "INDUN_PANEL_EARTHTOWERSHOP_CLOSE_RESTART")
                    rada:SetEventScript(ui.LBUTTONUP, "REQ_RadaCertificate_SHOP_OPEN")
                end
            elseif key_name == "jurate" then
                local jurate = frame:CreateOrGetControl("button", "jurate", x, 7, 29, 29);
                AUTO_CAST(jurate)
                if g.get_map_type() ~= "City" then
                    jurate:SetOffset(115, 7)
                end
                jurate:SetSkinName("None")
                jurate:SetText("{img goddess4_shop_btn 29 29}")
                coin_count = GET_COMMAED_STRING(TryGetProp(account_obj, "JurateCertificate", "0"))
                tooltip_msg = g.lang == "Japanese" and "{ol}ユラテショップ{nl}" .. "{#FFFF00}" .. coin_count or
                                  "{ol}Jurate Shop{nl}" .. "{#FFFF00}" .. coin_count
                jurate:SetTextTooltip(tooltip_msg)
                jurate:SetEventScript(ui.LBUTTONDOWN, "INDUN_PANEL_EARTHTOWERSHOP_CLOSE_RESTART")
                jurate:SetEventScript(ui.LBUTTONUP, "REQ_JurateCertificate_SHOP_OPEN")
            elseif key_name == "pvp_mine" then
                local pvp_mine = frame:CreateOrGetControl("button", "pvp_mine", x, 7, 29, 29);
                AUTO_CAST(pvp_mine)
                if g.get_map_type() ~= "City" then
                    pvp_mine:SetOffset(145, 7)
                end
                pvp_mine:SetSkinName("None")
                pvp_mine:SetText("{img pvpmine_shop_btn_total 29 29}")
                pvp_mine:SetTextTooltip(g.lang == "Japanese" and "{ol}傭兵団ショップ" or "{ol}Mercenary Shop")
                pvp_mine:SetEventScript(ui.LBUTTONDOWN, "INDUN_PANEL_EARTHTOWERSHOP_CLOSE_RESTART")
                pvp_mine:SetEventScript(ui.LBUTTONUP, "REQ_PVP_MINE_SHOP_OPEN")
            elseif key_name == "market" then
                if g.get_map_type() == "City" then
                    local market = frame:CreateOrGetControl("button", "market", x, 5, 29, 29);
                    AUTO_CAST(market)
                    market:SetSkinName("None")
                    market:SetText("{img market_shortcut_btn02 29 29}")
                    market:SetTextTooltip(g.lang == "Japanese" and "{ol}マーケット" or "{ol}Market")
                    market:SetEventScript(ui.LBUTTONUP, "MINIMIZED_MARKET_BUTTON_CLICK")
                end
            elseif key_name == "craft" then
                if g.get_map_type() == "City" then
                    local craft = frame:CreateOrGetControl("button", "craft", x, 5, 29, 29);
                    AUTO_CAST(craft)
                    craft:SetSkinName("None")
                    craft:SetText("{img icon_fullscreen_menu_equipment_processing 28 28}")
                    craft:SetTextTooltip(g.lang == "Japanese" and "{ol}装備加工" or "{ol}Equipment Processing")
                    craft:SetEventScript(ui.LBUTTONUP, "FULLSCREEN_NAVIGATION_MENU_DEATIL_EQUIPMENT_PROCESSING_NPC")
                end
            elseif key_name == "leticia" then
                if g.get_map_type() == "City" then
                    local leticia = frame:CreateOrGetControl("button", "leticia", x, 5, 29, 29);
                    AUTO_CAST(leticia)
                    leticia:SetSkinName("None")
                    leticia:SetText("{img icon_fullscreen_menu_letica 28 28}")
                    leticia:SetTextTooltip(g.lang == "Japanese" and "{ol}レティーシャへ移動" or
                                               "{ol}Leticia Move")
                    leticia:SetEventScript(ui.LBUTTONUP, "indun_panel_FULLSCREEN_NAVIGATION_MENU_DETAIL_MOVE_NPC")
                    leticia:SetEventScriptArgNumber(ui.LBUTTONUP, 309)
                end
            end
            x = x + 30
        end
    end

    --[[local leticia = frame:CreateOrGetControl("button", "leticia", 115, 5, 30, 30);
        AUTO_CAST(leticia)
        leticia:SetSkinName("Cube_skin2")
        leticia:SetText("{img icon_fullscreen_menu_letica 30 30}")
        leticia:SetTextTooltip(g.lang == "Japanese" and "{ol}レティーシャへ移動" or "{ol}Leticia Move")
        leticia:SetEventScript(ui.LBUTTONUP, "indun_panel_FULLSCREEN_NAVIGATION_MENU_DETAIL_MOVE_NPC")
        leticia:SetEventScriptArgNumber(ui.LBUTTONUP, 309)]]

    frame:Resize(x, 40)
    frame:ShowWindow(1)

    frame:RunUpdateScript("indun_panel_time_update", 60)

end

function indun_panel_time_update(frame)

    local time = os.date("*t")
    local hour = time.hour

    if hour >= 6 and hour <= 7 and g.loaded then
        g.loaded = false
        return 0
    else
        return 1
    end
end

local induntype = {{
    challenge = {
        low = 1000,
        hight = 1001,
        pt = 1002
    }
}, {
    singularity = 2000
}, {
    redania = {
        h = 718,
        s = 717,
        a = 716,
        ac = 80039
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
    cemetery = 684
}, {
    jsr = 0
}}

local buffIDs = {
    [716] = 80039, -- レダニア
    [707] = 80035, -- ネリンガ
    [710] = 80037, -- ゴーレム
    [673] = 80016, -- スプレッダー
    [676] = 80017, -- ファロウス
    [679] = 80015, -- ロゼ
    [685] = 80030, -- 蝶々
    [688] = 80031, -- スロガ
    [695] = 80032 -- メレジ
}
local raidTable = {
    [716] = {11210044, 11210043, 11210042},
    [707] = {11210024, 11210023, 11210022},
    [710] = {11210028, 11210027, 11210026},
    [695] = {11200356, 11200355, 11200354},
    [688] = {11200290, 10820036, 11200289, 11200288},
    [685] = {11200281, 10820035, 11200280, 11200279}
}

function indun_panel_FULLSCREEN_NAVIGATION_MENU_DETAIL_MOVE_NPC(frame, ctrl, str, guid)
    if g.get_map_type() ~= "City" then
        return
    end
    if guid == nil then
        return;
    end
    local cls = GetClassByType("full_screen_navigation_menu", guid);
    if cls ~= nil then
        local name = TryGetProp(cls, "Name", "None");
        local move_zone_select = TryGetProp(cls, "MoveZoneSelect", "NO");
        local move_zone = TryGetProp(cls, "MoveZone", "None");
        local move_npc_dialog = TryGetProp(cls, "MoveNpcDialog", "None");
        local move_zone_select_msg = TryGetProp(cls, "MoveZoneSelectMsg", "None");
        local move_only_in_town = TryGetProp(cls, "MoveOnlyInTown", "None");
        if move_zone ~= "None" and move_npc_dialog ~= "None" then
            -- 매칭 던전중이거나 pvp존이면 이용 불가
            local pc = GetMyPCObject();
            if session.world.IsIntegrateServer() == true or IsPVPField(pc) == 1 or IsPVPServer(pc) == 1 then
                ui.SysMsg(ScpArgMsg("ThisLocalUseNot"));
                return;
            end
            -- 퀘스트나 챌린지 모드로 인해 레이어 변경되면 이용 불가
            if world.GetLayer() ~= 0 then
                ui.SysMsg(ScpArgMsg("ThisLocalUseNot"));
                return;
            end
            -- 프리던전 맵에서 이용 불가
            local cur_map = GetClass("Map", session.GetMapName());
            local map_type = TryGetProp(cur_map, "MapType");
            if map_type == "Dungeon" then
                ui.SysMsg(ScpArgMsg("ThisLocalUseNot"));
                return;
            end
            -- 레이드 지역에서 이용 불가
            local zoneKeyword = TryGetProp(cur_map, 'Keyword', 'None')
            local keywordTable = StringSplit(zoneKeyword, ';')
            if table.find(keywordTable, 'IsRaidField') > 0 or table.find(keywordTable, 'WeeklyBossMap') > 0 then
                ui.SysMsg(ScpArgMsg('ThisLocalUseNot'))
                return
            end
            FullScreenMenuMoveNpc(name, move_zone_select, move_zone, move_npc_dialog, move_zone_select_msg,
                move_only_in_town);
            ui.CloseFrame("fullscreen_navigation_menu");
        end
    end
end

function indun_panel_init(frame)

    local map_frame = ui.GetFrame("map")
    local width = map_frame:GetWidth()

    if not g.settings.x then
        g.settings.x = 665
        g.settings.y = 30
        g.save_settings()
    end

    local x = g.settings.x
    if width <= 1920 and x > 1920 then
        x = g.settings.x / 21 * 16
    end

    local frame = ui.GetFrame("indun_panel")

    frame:SetPos(x, g.settings.y)
    frame:SetTitleBarSkin("None")
    frame:EnableHittestFrame(1)
    if not g.settings.move then
        g.settings.move = 0
    end
    frame:EnableMove(g.settings.move)
    if g.settings.move == 1 then
        frame:SetEventScript(ui.LBUTTONUP, "indun_panel_frame_drag")
    else
        frame:SetEventScript(ui.LBUTTONUP, "None")
    end
    frame:RemoveAllChild()

    local button = frame:CreateOrGetControl("button", "indun_panel_open", 5, 5, 80, 30)
    AUTO_CAST(button)
    button:SetText("{ol}{s10}INDUNPANEL")
    button:SetEventScript(ui.RBUTTONUP, "indun_panel_always_init")
    button:SetTextTooltip(g.lang == "Japanese" and "{ol}右クリック: 常時展開解除で閉じる" or
                              "{ol}Right click: Close with permanent unexpand")

    local ccbtn = frame:CreateOrGetControl('button', 'ccbtn', 85, 5, 30, 30)
    AUTO_CAST(ccbtn)
    ccbtn:SetSkinName("None")
    ccbtn:SetText("{img barrack_button_normal 30 30}")
    if type(_G["indun_list_viewer_title_frame_open"]) ~= "function" or type(_G["INSTANTCC_APPS_TRY_MOVE_BARRACK"]) ~=
        "function" then
        ccbtn:SetEventScript(ui.LBUTTONUP, "APPS_TRY_MOVE_BARRACK")
        ccbtn:SetTextTooltip(g.lang == "Japanese" and "{ol}バラックに戻ります" or "{ol}Return to Barracks")
    else
        ccbtn:SetEventScript(ui.LBUTTONUP, "indun_list_viewer_title_frame_open")
        ccbtn:SetTextTooltip("{ol}[ILV]open")
        local indun_list_viewer = ui.GetFrame("indun_list_viewer")
        if indun_list_viewer:IsVisible() == 1 then
            indun_list_viewer:ShowWindow(0)
        end
    end

    function indun_panel_frame_base_position(frame, ctrl, str, num)
        frame:SetPos(665, 30)
        g.settings.x = 665
        g.settings.y = 30
        g.save_settings()
        indun_panel_frame_init()
    end

    function indun_panel_config_gb_open(frame, ctrl, argStr, argNum)

        local frame = ui.GetFrame("indun_panel")
        frame:SetSkinName("test_frame_low")
        frame:SetLayerLevel(90)

        frame:EnableHittestFrame(1)
        -- frame:SetAlpha(100)
        frame:RemoveAllChild()
        frame:ShowWindow(1)

        local closeBtn = frame:CreateOrGetControl('button', 'closeBtn', 0, 0, 30, 30)
        AUTO_CAST(closeBtn)
        closeBtn:SetImage("testclose_button")
        closeBtn:SetGravity(ui.RIGHT, ui.TOP)
        closeBtn:SetEventScript(ui.LBUTTONUP, "indun_panel_frame_init");

        local button = frame:CreateOrGetControl("button", "indun_panel_open", 5, 5, 80, 30)
        AUTO_CAST(button)
        button:SetText("{ol}{s10}INDUNPANEL")
        button:SetEventScript(ui.LBUTTONUP, "indun_panel_frame_init")

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

        local position = frame:CreateOrGetControl("button", "position", 160, 5, 60, 30)
        AUTO_CAST(position)
        position:SetText("{ol}{s10}BASE POS MOVE")
        position:SetEventScript(ui.LBUTTONUP, "indun_panel_frame_base_position")

        ---ここから

        local config_x = 15
        local tosshop = frame:CreateOrGetControl("checkbox", "tosshop", config_x, 47, 25, 25);
        AUTO_CAST(tosshop)
        tosshop:SetText("{img icon_item_Tos_Event_Coin 25 25}")
        tosshop:SetEventScript(ui.LBUTTONUP, "indun_panel_ischecked")
        tosshop:SetEventScriptArgString(ui.LBUTTONUP, "config")
        tosshop:SetTextTooltip(g.lang == "Japanese" and "{ol}チェックすると常に表示" or
                                   "{ol}Always visible when checked")
        tosshop:SetCheck(g.settings.cols.tos)
        config_x = config_x + tosshop:GetWidth() + 10

        local gabija = frame:CreateOrGetControl("checkbox", "gabija", config_x, 47, 29, 29);
        AUTO_CAST(gabija)
        gabija:SetText("{img goddess_shop_btn 29 29}")
        gabija:SetEventScript(ui.LBUTTONUP, "indun_panel_ischecked")
        gabija:SetEventScriptArgString(ui.LBUTTONUP, "config")
        gabija:SetTextTooltip(g.lang == "Japanese" and "{ol}チェックすると常に表示" or
                                  "{ol}Always visible when checked")
        gabija:SetCheck(g.settings.cols.gabija)
        config_x = config_x + gabija:GetWidth() + 10

        local vakarine = frame:CreateOrGetControl("checkbox", "vakarine", config_x, 47, 29, 29);
        AUTO_CAST(vakarine)
        vakarine:SetText("{img goddess2_shop_btn 29 29}")
        vakarine:SetEventScript(ui.LBUTTONUP, "indun_panel_ischecked")
        vakarine:SetEventScriptArgString(ui.LBUTTONUP, "config")
        vakarine:SetTextTooltip(g.lang == "Japanese" and "{ol}チェックすると常に表示" or
                                    "{ol}Always visible when checked")
        vakarine:SetCheck(g.settings.cols.vakarine)
        config_x = config_x + vakarine:GetWidth() + 10

        local rada = frame:CreateOrGetControl("checkbox", "rada", config_x, 47, 29, 29);
        AUTO_CAST(rada)
        rada:SetText("{img goddess3_shop_btn 29 29}")
        rada:SetEventScript(ui.LBUTTONUP, "indun_panel_ischecked")
        rada:SetEventScriptArgString(ui.LBUTTONUP, "config")
        rada:SetTextTooltip(g.lang == "Japanese" and "{ol}チェックすると常に表示" or
                                "{ol}Always visible when checked")
        rada:SetCheck(g.settings.cols.rada)
        config_x = config_x + rada:GetWidth() + 10

        local jurate = frame:CreateOrGetControl("checkbox", "jurate", config_x, 47, 29, 29);
        AUTO_CAST(jurate)
        jurate:SetText("{img goddess4_shop_btn 29 29}")
        jurate:SetEventScript(ui.LBUTTONUP, "indun_panel_ischecked")
        jurate:SetEventScriptArgString(ui.LBUTTONUP, "config")
        jurate:SetTextTooltip(g.lang == "Japanese" and "{ol}チェックすると常に表示" or
                                  "{ol}Always visible when checked")
        jurate:SetCheck(g.settings.cols.jurate)
        config_x = config_x + jurate:GetWidth() + 10

        local pvp_mine = frame:CreateOrGetControl("checkbox", "pvp_mine", config_x, 47, 29, 29);
        AUTO_CAST(pvp_mine)
        pvp_mine:SetText("{img pvpmine_shop_btn_total 29 29}")
        pvp_mine:SetEventScript(ui.LBUTTONUP, "indun_panel_ischecked")
        pvp_mine:SetEventScriptArgString(ui.LBUTTONUP, "config")
        pvp_mine:SetTextTooltip(g.lang == "Japanese" and "{ol}チェックすると常に表示" or
                                    "{ol}Always visible when checked")
        pvp_mine:SetCheck(g.settings.cols.pvp_mine)
        config_x = config_x + pvp_mine:GetWidth() + 10

        local market = frame:CreateOrGetControl("checkbox", "market", config_x, 47, 29, 29);
        AUTO_CAST(market)
        market:SetText("{img market_shortcut_btn02 29 29}")
        market:SetEventScript(ui.LBUTTONUP, "indun_panel_ischecked")
        market:SetEventScriptArgString(ui.LBUTTONUP, "config")
        market:SetTextTooltip(g.lang == "Japanese" and "{ol}チェックすると常に表示" or
                                  "{ol}Always visible when checked")
        market:SetCheck(g.settings.cols.market)
        config_x = config_x + market:GetWidth() + 10

        local craft = frame:CreateOrGetControl("checkbox", "craft", config_x, 47, 29, 29);
        AUTO_CAST(craft)
        craft:SetText("{img icon_fullscreen_menu_equipment_processing 28 28}")
        craft:SetEventScript(ui.LBUTTONUP, "indun_panel_ischecked")
        craft:SetEventScriptArgString(ui.LBUTTONUP, "config")
        craft:SetTextTooltip(g.lang == "Japanese" and "{ol}チェックすると常に表示" or
                                 "{ol}Always visible when checked")
        craft:SetCheck(g.settings.cols.craft)
        config_x = config_x + craft:GetWidth() + 10

        local leticia = frame:CreateOrGetControl("checkbox", "leticia", config_x, 47, 29, 29);
        AUTO_CAST(leticia)
        leticia:SetText("{img icon_fullscreen_menu_letica 28 28}")
        leticia:SetEventScript(ui.LBUTTONUP, "indun_panel_ischecked")
        leticia:SetEventScriptArgString(ui.LBUTTONUP, "config")
        leticia:SetTextTooltip(g.lang == "Japanese" and "{ol}チェックすると常に表示" or
                                   "{ol}Always visible when checked")
        leticia:SetCheck(g.settings.cols.leticia)
        config_x = config_x + leticia:GetWidth() + 10

        local label_line2 = frame:CreateControl('labelline', 'label_line2', 10, 77, config_x, 5);
        AUTO_CAST(label_line2)
        label_line2:SetSkinName("labelline2")

        local en_ver = frame:CreateOrGetControl('checkbox', 'en_ver', 25, 85, 25, 25)
        AUTO_CAST(en_ver)
        if g.settings.en_ver == nil then
            g.settings.en_ver = 0
            g.save_settings()
        end
        en_ver:SetCheck(g.settings.en_ver)
        en_ver:SetEventScript(ui.LBUTTONUP, "indun_panel_ischecked")
        en_ver:SetText(g.lang == "Japanese" and "{ol}チェックすると英語表示に変更します" or
                           "{ol}Check to display to English")

        local move = frame:CreateOrGetControl('checkbox', 'move', 25, 120, 25, 25)
        AUTO_CAST(move)
        if g.settings.move == nil then
            g.settings.move = 0
            g.save_settings()
        end
        move:SetCheck(g.settings.move)
        move:SetEventScript(ui.LBUTTONUP, "indun_panel_ischecked")
        move:SetText(g.lang == "Japanese" and "{ol}チェックするとフレームを動かせます" or
                         "{ol}Check to move the frame")

        local field_mode = frame:CreateOrGetControl('checkbox', 'field_mode', 25, 155, 25, 25)
        AUTO_CAST(field_mode)
        if g.settings.field_mode == nil then
            g.settings.field_mode = 0
            g.save_settings()
        end
        field_mode:SetCheck(g.settings.field_mode)
        field_mode:SetEventScript(ui.LBUTTONUP, "indun_panel_ischecked")
        field_mode:SetText(g.lang == "Japanese" and "{ol}チェックするとフィールドで表示" or
                               "{ol}Check to display in field")

        local label_line = frame:CreateControl('labelline', 'label_line', 10, 180, config_x, 5);
        AUTO_CAST(label_line)
        label_line:SetSkinName("labelline2")

        local posY = 185
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
        -- frame:Resize(360, posY + 5)
        frame:Resize(660, posY + 5)
    end

    local configbtn = frame:CreateOrGetControl('button', 'configbtn', 115, 5, 30, 30)
    AUTO_CAST(configbtn)
    configbtn:SetSkinName("None")
    configbtn:SetText("{img config_button_normal 30 30}")
    configbtn:SetEventScript(ui.LBUTTONUP, "indun_panel_config_gb_open")
    configbtn:SetTextTooltip(g.lang == "Japanese" and "{ol}Indun Panel 設定" or "{ol}Indun Panel Config")

    if configbtn:IsVisible() == 1 then
        button:SetEventScript(ui.LBUTTONUP, "indun_panel_frame_init")
    end

    function indun_panel_event_tos_whole_shop_open()
        local frame = ui.GetFrame("earthtowershop");
        frame:SetUserValue("SHOP_TYPE", 'EVENT_TOS_WHOLE_SHOP');
        ui.OpenFrame('earthtowershop');
    end

    local account_obj = GetMyAccountObj()
    local tooltip_msg = ""
    local coin_count = 0

    if g.get_map_type() == "City" then

        local market = frame:CreateOrGetControl("button", "market", 330, 5, 29, 29);
        AUTO_CAST(market)
        market:SetSkinName("None")
        market:SetText("{img market_shortcut_btn02 29 29}")
        market:SetTextTooltip(g.lang == "Japanese" and "{ol}マーケット" or "{ol}Market")
        market:SetEventScript(ui.LBUTTONUP, "MINIMIZED_MARKET_BUTTON_CLICK")

        local leticia = frame:CreateOrGetControl("button", "leticia", 390, 5, 29, 29);
        AUTO_CAST(leticia)
        leticia:SetSkinName("None")
        leticia:SetText("{img icon_fullscreen_menu_letica 28 28}")
        leticia:SetTextTooltip(g.lang == "Japanese" and "{ol}レティーシャへ移動" or "{ol}Leticia Move")
        leticia:SetEventScript(ui.LBUTTONUP, "indun_panel_FULLSCREEN_NAVIGATION_MENU_DETAIL_MOVE_NPC")
        leticia:SetEventScriptArgNumber(ui.LBUTTONUP, 309)

        local tosshop = frame:CreateOrGetControl("button", "tosshop", 150, 8, 25, 25);
        AUTO_CAST(tosshop)
        tosshop:SetSkinName("None")
        tosshop:SetText("{img icon_item_Tos_Event_Coin 25 25}")
        coin_count = GET_COMMAED_STRING(TryGetProp(account_obj, "EVENT_TOS_WHOLE_TOTAL_COIN", "0"))
        tooltip_msg = g.lang == "Japanese" and "{ol}TOSイベントショップ" or "{ol}TOS Event Shop"
        tosshop:SetTextTooltip(tooltip_msg)
        -- INDUN_PANEL_EARTHTOWERSHOP_CLOSE_RESTART
        tosshop:SetEventScript(ui.LBUTTONDOWN, "INDUN_PANEL_EARTHTOWERSHOP_CLOSE_RESTART")
        tosshop:SetEventScript(ui.LBUTTONUP, "indun_panel_event_tos_whole_shop_open")

        local gabija = frame:CreateOrGetControl("button", "gabija", 180, 7, 29, 29);
        AUTO_CAST(gabija)
        gabija:SetSkinName("None")
        gabija:SetText("{img goddess_shop_btn 29 29}")
        coin_count = GET_COMMAED_STRING(TryGetProp(account_obj, "GabijaCertificate", "0"))
        tooltip_msg = g.lang == "Japanese" and "{ol}ガビヤショップ{nl}" .. "{#FFFF00}" .. coin_count or
                          "{ol}Gabija Shop{nl}" .. "{#FFFF00}" .. coin_count
        gabija:SetTextTooltip(tooltip_msg)
        gabija:SetEventScript(ui.LBUTTONDOWN, "INDUN_PANEL_EARTHTOWERSHOP_CLOSE_RESTART")
        gabija:SetEventScript(ui.LBUTTONUP, "REQ_GabijaCertificate_SHOP_OPEN")

        local vakarine = frame:CreateOrGetControl("button", "vakarine", 210, 7, 29, 29);
        AUTO_CAST(vakarine)
        vakarine:SetSkinName("None")
        vakarine:SetText("{img goddess2_shop_btn 29 29}")
        coin_count = GET_COMMAED_STRING(TryGetProp(account_obj, "VakarineCertificate", "0"))
        tooltip_msg = g.lang == "Japanese" and "{ol}ヴァカリネショップ{nl}" .. "{#FFFF00}" .. coin_count or
                          "{ol}Vakarine Shop{nl}" .. "{#FFFF00}" .. coin_count
        vakarine:SetTextTooltip(tooltip_msg)
        vakarine:SetEventScript(ui.LBUTTONDOWN, "INDUN_PANEL_EARTHTOWERSHOP_CLOSE_RESTART")
        vakarine:SetEventScript(ui.LBUTTONUP, "REQ_VakarineCertificate_SHOP_OPEN")

        local rada = frame:CreateOrGetControl("button", "rada", 240, 8, 29, 29);
        AUTO_CAST(rada)
        rada:SetSkinName("None")
        rada:SetText("{img goddess3_shop_btn 29 29}")
        coin_count = GET_COMMAED_STRING(TryGetProp(account_obj, "RadaCertificate", "0"))
        tooltip_msg = g.lang == "Japanese" and "{ol}ラダショップ{nl}" .. "{#FFFF00}" .. coin_count or
                          "{ol}Rada Shop{nl}" .. "{#FFFF00}" .. coin_count
        rada:SetTextTooltip(tooltip_msg)
        rada:SetEventScript(ui.LBUTTONDOWN, "INDUN_PANEL_EARTHTOWERSHOP_CLOSE_RESTART")
        rada:SetEventScript(ui.LBUTTONUP, "REQ_RadaCertificate_SHOP_OPEN")
    end

    local jurate = frame:CreateOrGetControl("button", "jurate", 270, 7, 29, 29);
    AUTO_CAST(jurate)
    if g.get_map_type() ~= "City" then
        jurate:SetOffset(150, 7)
    end
    jurate:SetSkinName("None")
    jurate:SetText("{img goddess4_shop_btn 29 29}")
    coin_count = GET_COMMAED_STRING(TryGetProp(account_obj, "JurateCertificate", "0"))
    tooltip_msg = g.lang == "Japanese" and "{ol}ユラテショップ{nl}" .. "{#FFFF00}" .. coin_count or
                      "{ol}Jurate Shop{nl}" .. "{#FFFF00}" .. coin_count
    jurate:SetTextTooltip(tooltip_msg)
    jurate:SetEventScript(ui.LBUTTONDOWN, "INDUN_PANEL_EARTHTOWERSHOP_CLOSE_RESTART")
    jurate:SetEventScript(ui.LBUTTONUP, "REQ_JurateCertificate_SHOP_OPEN")

    local pvp_mine = frame:CreateOrGetControl("button", "pvp_mine", 300, 7, 29, 29);
    AUTO_CAST(pvp_mine)
    if g.get_map_type() ~= "City" then
        pvp_mine:SetOffset(180, 7)
    end
    pvp_mine:SetSkinName("None")
    pvp_mine:SetText("{img pvpmine_shop_btn_total 29 29}")
    pvp_mine:SetTextTooltip(g.lang == "Japanese" and "{ol}傭兵団ショップ" or "{ol}Mercenary Shop")
    pvp_mine:SetEventScript(ui.LBUTTONDOWN, "INDUN_PANEL_EARTHTOWERSHOP_CLOSE_RESTART")
    pvp_mine:SetEventScript(ui.LBUTTONUP, "REQ_PVP_MINE_SHOP_OPEN")
    if g.get_map_type() == "City" then
        local craft = frame:CreateOrGetControl("button", "craft", 360, 5, 29, 29);
        AUTO_CAST(craft)
        craft:SetSkinName("None")
        craft:SetText("{img icon_fullscreen_menu_equipment_processing 28 28}")
        craft:SetTextTooltip(g.lang == "Japanese" and "{ol}装備加工" or "{ol}Equipment Processing")
        craft:SetEventScript(ui.LBUTTONUP, "FULLSCREEN_NAVIGATION_MENU_DEATIL_EQUIPMENT_PROCESSING_NPC")
    end

    -- icon_fullscreen_menu_craft

    local checkbox = frame:CreateOrGetControl('checkbox', 'checkbox', 710, 5, 30, 30)
    AUTO_CAST(checkbox)
    checkbox:SetCheck(g.settings.checkbox)
    checkbox:SetEventScript(ui.LBUTTONUP, "indun_panel_ischecked")
    checkbox:SetTextTooltip(g.lang == "Japanese" and "{ol}チェックすると常時展開" or "{ol}IsCheck AlwaysOpen")

    local tos_coin = frame:CreateOrGetControl("richtext", "tos_coin", 480, 12)
    tos_coin:SetText("{img icon_item_Tos_Event_Coin 21 21}")

    local tos_coin_count = frame:CreateOrGetControl("richtext", "tos_coin_count", 505, 10)
    coin_count = GET_COMMAED_STRING(TryGetProp(account_obj, "EVENT_TOS_WHOLE_TOTAL_COIN", "0"))
    tos_coin_count:SetText(string.format("{ol}{#FFD900}{s18}%s", coin_count))

    local pvpmine = frame:CreateOrGetControl("richtext", "pvpmine", 575, 10)
    pvpmine:SetText("{img pvpmine_shop_btn_total 25 25}")

    local pvpminecount = frame:CreateOrGetControl("richtext", "pvpminecount", 600, 10)
    coin_count = GET_COMMAED_STRING(TryGetProp(account_obj, "MISC_PVP_MINE2", "0"))
    pvpminecount:SetText(string.format("{ol}{#FFD900}{s18}%s", coin_count))

    if g.settings.season_checkbox == nil then
        g.settings.season_checkbox = 1
        g.save_settings()
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

    if g.settings.jsr_checkbox == 1 then
        indun_panel_FIELD_BOSS_TIME_TAB_SETTING(frame)
    end

    indun_panel_frame_contents(frame)
    configbtn:RunUpdateScript("indun_panel_frame_contents", 1.0)
    frame:SetLayerLevel(80)
    frame:Resize(g.x + 615, g.y + 5)
    g.x = nil
    g.y = nil
    frame:SetSkinName("chat_window_2")
    frame:EnableHitTest(1);
    frame:SetAlpha(100)

end

function indun_panel_ischecked(frame, ctrl, argStr, argNum)

    local ischeck = ctrl:IsChecked()

    local ctrlname = ctrl:GetName()
    if ctrlname == "tosshop" then
        ctrlname = "tos"
    end
    if string.find(ctrl:GetName(), "auto_check") then
        ctrlname = "singularity_check"
    end

    if g.settings[ctrlname] then
        g.settings[ctrlname] = ischeck
    elseif g.settings.cols[ctrlname] then
        g.settings.cols[ctrlname] = ischeck
    end

    g.save_settings()

    if ctrlname == "move" then
        frame:EnableMove(g.settings.move)

    end

end

function indun_panel_get_entrance_count(indun_type, index)

    local return_str = ""
    if index == 2 then
        return_str = string.format("{ol}{#FFFFFF}{s16}(%d/%d)",
            GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", indun_type).PlayPerResetType),
            GET_INDUN_MAX_ENTERANCE_COUNT(GetClassByType("Indun", indun_type).PlayPerResetType))
    elseif index == 1 then
        return_str = string.format("{ol}{#FFFFFF}{s16}(%d)",
            GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", indun_type).PlayPerResetType))
    end
    return return_str
end

function indun_panel_frame_contents(frame)

    local frame = ui.GetFrame("indun_panel")
    local account_obj = GetMyAccountObj()
    local tos_coin_count = GET_CHILD_RECURSIVELY(frame, "tos_coin_count")
    if tos_coin_count ~= nil then
        local coin_count = GET_COMMAED_STRING(TryGetProp(account_obj, "EVENT_TOS_WHOLE_TOTAL_COIN", "0"))
        tos_coin_count:SetText(string.format("{ol}{#FFD900}{s18}%s", coin_count))
    end
    local pvpminecount = GET_CHILD_RECURSIVELY(frame, "pvpminecount")
    if pvpminecount ~= nil then
        local coin_count = GET_COMMAED_STRING(TryGetProp(account_obj, "MISC_PVP_MINE2", "0"))
        pvpminecount:SetText(string.format("{ol}{#FFD900}{s18}%s", coin_count))
    end

    local gabija = GET_CHILD_RECURSIVELY(frame, "gabija")
    if gabija then
        AUTO_CAST(gabija)
        local coin_count = GET_COMMAED_STRING(TryGetProp(account_obj, "GabijaCertificate", "0"))
        local tooltip_msg = g.lang == "Japanese" and "{ol}ガビヤショップ{nl}" .. "{#FFFF00}" .. coin_count or
                                "{ol}Gabija Shop{nl}" .. "{#FFFF00}" .. coin_count
        gabija:SetTextTooltip(tooltip_msg)
    end

    local vakarine = GET_CHILD_RECURSIVELY(frame, "vakarine")
    if vakarine then
        AUTO_CAST(vakarine)
        local coin_count = GET_COMMAED_STRING(TryGetProp(account_obj, "VakarineCertificate", "0"))
        local tooltip_msg =
            g.lang == "Japanese" and "{ol}ヴァカリネショップ{nl}" .. "{#FFFF00}" .. coin_count or
                "{ol}Vakarine Shop{nl}" .. "{#FFFF00}" .. coin_count
        vakarine:SetTextTooltip(tooltip_msg)
    end

    local rada = GET_CHILD_RECURSIVELY(frame, "rada")
    if rada then
        AUTO_CAST(rada)
        local coin_count = GET_COMMAED_STRING(TryGetProp(account_obj, "RadaCertificate", "0"))
        local tooltip_msg = g.lang == "Japanese" and "{ol}ラダショップ{nl}" .. "{#FFFF00}" .. coin_count or
                                "{ol}Rada Shop{nl}" .. "{#FFFF00}" .. coin_count
        rada:SetTextTooltip(tooltip_msg)
    end

    local jurate = GET_CHILD_RECURSIVELY(frame, "jurate")
    if jurate then
        AUTO_CAST(jurate)
        local coin_count = GET_COMMAED_STRING(TryGetProp(account_obj, "JurateCertificate", "0"))
        local tooltip_msg = g.lang == "Japanese" and "{ol}ユラテショップ{nl}" .. "{#FFFF00}" .. coin_count or
                                "{ol}Jurate Shop{nl}" .. "{#FFFF00}" .. coin_count
        jurate:SetTextTooltip(tooltip_msg)
    end

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
                        key == "merregina" or key == "neringa" or key == "golem" or key == "redania" then

                        function indun_panel_create_frame_onsweep(frame, key, subKey, subValue, y, x)

                            -- session.ResetItemList()

                            function indun_panel_autosweep(frame, ctrl, argStr, induntype)

                                local buffID = buffIDs[induntype]

                                local sweepcount = indun_panel_sweep_count(buffID)
                                if sweepcount >= 1 then
                                    ReqUseRaidAutoSweep(induntype)
                                else
                                    if not string.find(argStr, "use") then
                                        ui.SysMsg(g.lang == "Japanese" and "掃討バフがありません。" or
                                                      "There is no autoclear buff.")
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

                            local invItemList = session.GetInvItemList()
                            local guidList = invItemList:GetGuidList()
                            local cnt = guidList:Count()

                            if raidTable[subValue] then

                                local use = frame:CreateOrGetControl('button', key .. "use", x + 490, y, 80, 30)

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
                                local text = g.lang == "Japanese" and
                                                 string.format("{ol}{img %s 25 25 } %d個持っています。", icon,
                                        count) or
                                                 string.format("{ol}{img %s 25 25 } Quantity in Inventory", icon, count)

                                function indun_panel_raid_itemuse(frame, ctrl, argStr, induntype)

                                    session.ResetItemList()
                                    local invItemList = session.GetInvItemList()
                                    local guidList = invItemList:GetGuidList()
                                    local cnt = guidList:Count()
                                    local targetItems = raidTable[induntype]
                                    local enter_count = GET_CURRENT_ENTERANCE_COUNT(
                                        GetClassByType("Indun", induntype).PlayPerResetType)
                                    local buffID = buffIDs[induntype]
                                    local sweep_count = indun_panel_sweep_count(buffID)

                                    if targetItems then
                                        for _, targetClassID in ipairs(targetItems) do
                                            for i = 0, cnt - 1 do
                                                local itemobj = GetIES(
                                                    invItemList:GetItemByGuid(guidList:Get(i)):GetObject())
                                                local classid = itemobj.ClassID

                                                if classid == targetClassID then

                                                    if enter_count == 2 and sweep_count >= 1 then
                                                        INV_ICON_USE(session.GetInvItemByType(tonumber(classid)))
                                                        ReserveScript(string.format(
                                                            "indun_panel_autosweep(nil,nil,'%s',%d)", ctrl:GetName(),
                                                            induntype), 0.2)
                                                        return
                                                    elseif enter_count == 2 and sweep_count == 0 then
                                                        INV_ICON_USE(session.GetInvItemByType(tonumber(classid)))
                                                        return
                                                    elseif enter_count <= 1 and sweep_count >= 1 then
                                                        ReserveScript(string.format(
                                                            "indun_panel_autosweep(nil,nil,'%s',%d)", ctrl:GetName(),
                                                            induntype), 0.2)
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

                                use:SetTextTooltip(text)
                                use:SetEventScript(ui.LBUTTONUP, "indun_panel_raid_itemuse")
                                use:SetEventScriptArgNumber(ui.LBUTTONUP, subValue)
                            end

                            local solo = frame:CreateOrGetControl('button', key .. "solo", x, y, 80, 30)
                            local auto = frame:CreateOrGetControl('button', key .. "auto", x + 85, y, 80, 30)
                            local count = frame:CreateOrGetControl("richtext", key .. "count", x + 170, y + 5, 50, 30)
                            local hard = frame:CreateOrGetControl('button', key .. "hard", x + 215, y, 80, 30)
                            local counthard = frame:CreateOrGetControl("richtext", key .. "counthard", x + 300, y + 5,
                                50, 30)
                            local sweep = frame:CreateOrGetControl('button', key .. "sweep", x + 355, y, 80, 30)
                            local sweepcount = frame:CreateOrGetControl("richtext", key .. "sweepcount", x + 440, y + 5,
                                50, 30)

                            solo:SetText("{ol}SOLO")
                            auto:SetText("{ol}{#FFD900}AUTO")
                            hard:SetText("{ol}{#FF0000}HARD")
                            sweep:SetText("{ol}{#00FF00}" .. "ACLEAR")

                            if subKey == "s" then
                                count:SetText(indun_panel_get_entrance_count(subValue, 2))
                                solo:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_solo")
                                solo:SetEventScriptArgNumber(ui.LBUTTONUP, subValue)
                            elseif subKey == "a" then
                                auto:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_auto")
                                auto:SetEventScriptArgNumber(ui.LBUTTONUP, subValue)
                                sweep:SetEventScript(ui.LBUTTONUP, "indun_panel_autosweep")
                                sweep:SetEventScriptArgNumber(ui.LBUTTONUP, subValue)
                            elseif subKey == "h" then
                                counthard:SetText(indun_panel_get_entrance_count(subValue, 2))
                                hard:SetEventScript(ui.LBUTTONDOWN, "indun_panel_enter_hard")
                                hard:SetEventScriptArgNumber(ui.LBUTTONDOWN, subValue)
                                hard:SetEventScriptArgString(ui.LBUTTONDOWN, "false")
                            elseif subKey == "ac" then

                                sweepcount:SetText("{ol}{#FFFFFF}{s16}(" .. indun_panel_sweep_count(subValue) .. ")")
                            end
                        end

                        for subKey, subValue in pairs(value) do
                            indun_panel_create_frame_onsweep(frame, key, subKey, subValue, y, x)
                        end
                    elseif key == "jellyzele" or key == "delmore" or key == "giltine" or key == "earring" then

                        function indun_panel_create_frame(frame, key, subKey, subValue, y)

                            local solo = frame:CreateOrGetControl('button', key .. "solo", 135, y, 80, 30)
                            local auto = frame:CreateOrGetControl('button', key .. "auto", 220, y, 80, 30)
                            local hard = frame:CreateOrGetControl('button', key .. "hard", 350, y, 80, 30)
                            local count = frame:CreateOrGetControl("richtext", key .. "count", 305, y + 5, 50, 30)
                            local counthard = frame:CreateOrGetControl("richtext", key .. "counthard", 435, y + 5, 50,
                                30)

                            solo:SetText("{ol}SOLO")
                            auto:SetText(key == "earring" and "{ol}{#FFD900}NORMAL" or "{ol}{#FFD900}AUTO")
                            hard:SetText("{ol}{#FF0000}HARD")

                            if subKey == "s" then
                                if key == "earring" then
                                    count:SetText(indun_panel_get_entrance_count(subValue, 1))
                                    solo:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_solo")
                                    solo:SetEventScriptArgNumber(ui.LBUTTONUP, subValue)
                                else
                                    count:SetText(indun_panel_get_entrance_count(subValue, 2))
                                    solo:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_solo")
                                    solo:SetEventScriptArgNumber(ui.LBUTTONUP, subValue)
                                end
                            elseif subKey == "a" then
                                auto:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_auto")
                                auto:SetEventScriptArgNumber(ui.LBUTTONUP, subValue)

                            elseif subKey == "h" then
                                if key == "giltine" then
                                    counthard:SetText(indun_panel_get_entrance_count(subValue, 1))
                                    hard:SetEventScript(ui.LBUTTONDOWN, "indun_panel_enter_hard")
                                    hard:SetEventScriptArgNumber(ui.LBUTTONDOWN, subValue)
                                    hard:SetEventScriptArgString(ui.LBUTTONDOWN, "false")
                                elseif key == "earring" then
                                    hard:SetEventScript(ui.LBUTTONDOWN, "indun_panel_enter_hard")
                                    hard:SetEventScriptArgNumber(ui.LBUTTONDOWN, subValue)
                                    hard:SetEventScriptArgString(ui.LBUTTONDOWN, "false")
                                else
                                    counthard:SetText(indun_panel_get_entrance_count(subValue, 2))
                                    hard:SetEventScript(ui.LBUTTONDOWN, "indun_panel_enter_hard")
                                    hard:SetEventScriptArgNumber(ui.LBUTTONDOWN, subValue)
                                    hard:SetEventScriptArgString(ui.LBUTTONDOWN, "false")
                                end
                            end

                        end
                        for subKey, subValue in pairs(value) do
                            indun_panel_create_frame(frame, key, subKey, subValue, y)
                        end
                    elseif key == "challenge" then
                        function indun_panel_challenge_frame(frame, key, y)

                            local low_btn = frame:CreateOrGetControl('button', key .. 'low_btn', 135, y, 80, 30)
                            AUTO_CAST(low_btn)
                            low_btn:SetText("{ol}500")
                            low_btn:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_challenge")
                            low_btn:SetEventScriptArgString(ui.LBUTTONUP, "1")
                            low_btn:SetEventScriptArgNumber(ui.LBUTTONUP, value.low)

                            local hight_btn = frame:CreateOrGetControl('button', key .. 'hight_btn', 220, y, 80, 30)
                            AUTO_CAST(hight_btn)
                            hight_btn:SetText("{ol}520")
                            hight_btn:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_challenge")
                            hight_btn:SetEventScriptArgString(ui.LBUTTONUP, "1")
                            hight_btn:SetEventScriptArgNumber(ui.LBUTTONUP, value.hight)

                            local pt_btn = frame:CreateOrGetControl('button', key .. 'pt_btn', 305, y, 80, 30)
                            AUTO_CAST(pt_btn)
                            pt_btn:SetText("{ol}{#FFD900}PT")
                            pt_btn:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_challenge")
                            pt_btn:SetEventScriptArgString(ui.LBUTTONUP, "2")
                            pt_btn:SetEventScriptArgNumber(ui.LBUTTONUP, value.pt)

                            local count = frame:CreateOrGetControl("richtext", key .. "count", 390, y + 5, 40, 30)
                            count:SetText(indun_panel_get_entrance_count(value.pt, 2))

                            function indun_panel_item_use_change()
                                if not g.settings.challenge_ticket then
                                    g.settings.challenge_ticket = "week"
                                    local msg = g.lang == "Japanese" and
                                                    "{ol}傭兵団コイン優先に切替えました" or
                                                    "{ol}Switched to Mercenary coin priority"
                                    ui.SysMsg(msg)
                                elseif g.settings.challenge_ticket == "month" then
                                    g.settings.challenge_ticket = "week"
                                    local msg = g.lang == "Japanese" and
                                                    "{ol}傭兵団コイン優先に切替えました" or
                                                    "{ol}Switched to Mercenary coin priority"
                                    ui.SysMsg(msg)
                                elseif g.settings.challenge_ticket == "week" then
                                    g.settings.challenge_ticket = "month"
                                    local msg =
                                        g.lang == "Japanese" and "{ol}TOSコイン優先に切替えました" or
                                            "{ol}Switched to TOS coin priority"
                                    ui.SysMsg(msg)
                                end
                                g.save_settings()
                            end

                            local ticket_btn = frame:CreateOrGetControl('button', key .. 'ticket_btn', 435, y, 80, 30)
                            AUTO_CAST(ticket_btn)
                            --  tosshop:SetText("{img icon_item_Tos_Event_Coin 25 25}")
                            -- pvp_mine:SetText("{img pvpmine_shop_btn_total 29 29}")
                            local text = g.settings.challenge_ticket == "month" and
                                             "{img icon_item_Tos_Event_Coin 14 14}{ol}{#EE7800}{s14}BUYUSE" or
                                             "{img pvpmine_shop_btn_total 14 14}{ol}{#EE7800}{s14}BUYUSE"
                            -- ticket_btn:SetText("{ol}{#EE7800}{s14}BUYUSE")
                            ticket_btn:SetText(text)
                            ticket_btn:SetTextTooltip("{ol}" ..
                                                          INDUN_PANEL_LANG(
                                    "priority{nl}1.Tickets due within 24 hours{nl}2.Tickets with expiration date{nl}" ..
                                        "3.Event tickets with no expiration date{nl}4.{img icon_item_Tos_Event_Coin 20 20} tickets (buy and use){nl}" ..
                                        "5.{img pvpmine_shop_btn_total 20 20} tickets (buy and use){nl} {nl}" ..
                                        "{#FFFF00}Right-click to switch priority"))

                            ticket_btn:SetEventScript(ui.LBUTTONUP, "indun_panel_item_use")
                            ticket_btn:SetEventScriptArgNumber(ui.LBUTTONUP, value.low)
                            ticket_btn:SetEventScript(ui.RBUTTONUP, "indun_panel_item_use_change")

                            local a_ticket_btn = frame:CreateOrGetControl('button', key .. 'a_ticket_btn', 625, y, 80,
                                30)
                            AUTO_CAST(a_ticket_btn)

                            local invItemList = session.GetInvItemList()
                            local guidList = invItemList:GetGuidList()
                            local cnt = guidList:Count()

                            local count = 0

                            for i = 0, cnt - 1 do
                                local itemobj = GetIES(invItemList:GetItemByGuid(guidList:Get(i)):GetObject())
                                local invItem = invItemList:GetItemByGuid(guidList:Get(i))
                                if itemobj.ClassID == 641987 or itemobj.ClassID == 641963 then
                                    count = count + invItem.count
                                end
                            end

                            a_ticket_btn:SetText("{ol}{#EE7800}{s14}A USE")
                            local item_class1 = GetClassByType('Item', 641987)
                            local icon1 = item_class1.Icon

                            local ticket_notice = g.lang == "Japanese" and
                                                      string.format("{ol}{img %s 25 25 } %d個持っています。",
                                    icon1, count) or
                                                      string.format("{ol}{img %s 25 25 } Quantity in Inventory", icon1,
                                    count)
                            -- 641987 641963

                            a_ticket_btn:SetTextTooltip(ticket_notice)
                            a_ticket_btn:SetEventScript(ui.LBUTTONUP, "indun_panel_item_use")
                            a_ticket_btn:SetEventScriptArgNumber(ui.LBUTTONUP, value.low)
                            a_ticket_btn:SetEventScriptArgString(ui.LBUTTONUP, "A")

                            local ticket_count = frame:CreateOrGetControl("richtext", key .. "ticket_count", 520, y + 5,
                                40, 30)

                            local recipe_trade_count = INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_40")

                            if recipe_trade_count < 0 then
                                recipe_trade_count = "({img pvpmine_shop_btn_total 20 20}" .. "{ol}{#FF0000}{s16}" ..
                                                         math.abs(recipe_trade_count) .. "{/}{/}" -- 絶対値を取得
                            else
                                recipe_trade_count = "({img pvpmine_shop_btn_total 20 20}" .. "{ol}{#FFFFFF}{s16}" ..
                                                         math.abs(recipe_trade_count) .. "{/}{/}" -- 絶対値を取得
                            end

                            ticket_count:SetText(recipe_trade_count .. " {img icon_item_Tos_Event_Coin 20 20}" ..
                                                     INDUN_PANEL_GET_RECIPE_TRADE_COUNT("EVENT_TOS_WHOLE_SHOP_315") ..
                                                     ")")

                            local auto_challenge =
                                frame:CreateOrGetControl("checkbox", "auto_challenge", 710, y, 25, 25)
                            AUTO_CAST(auto_challenge)
                            auto_challenge:SetEventScript(ui.LBUTTONUP, "indun_panel_ischecked")
                            auto_challenge:SetTextTooltip(g.lang == "Japanese" and
                                                              "{ol}チェックをすると自動でPTマッチングします" or
                                                              "{ol}Check the box for automatic PT matching")
                            if not g.settings.auto_challenge then
                                g.settings.auto_challenge = 0
                                g.save_settings()

                            end
                            auto_challenge:SetCheck(g.settings.auto_challenge)

                        end
                        indun_panel_challenge_frame(frame, key, y)
                    end
                else

                    if key == "singularity" then
                        function indun_panel_singularity_frame(frame, key, y)

                            local btn = frame:CreateOrGetControl('button', key .. 'btn', 135, y, 80, 30)
                            AUTO_CAST(btn)
                            btn:SetText("{ol}{#FFD900}520")
                            btn:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_singularity")
                            btn:SetEventScriptArgNumber(ui.LBUTTONUP, value)

                            local count = frame:CreateOrGetControl("richtext", key .. "count", 220, y + 5, 30, 30)
                            count:SetText(indun_panel_get_entrance_count(value, 1))

                            local ticket_btn = frame:CreateOrGetControl('button', key .. 'ticket_btn', 250, y, 80, 30)
                            AUTO_CAST(ticket_btn)
                            ticket_btn:SetText("{ol}{#EE7800}{s14}BUYUSE")
                            ticket_btn:SetTextTooltip("{ol}" ..
                                                          INDUN_PANEL_LANG(
                                    "priority{nl}1.Tickets due within 24 hours{nl}2.Tickets with expiration date{nl}" ..
                                        "3.{img pvpmine_shop_btn_total 20 20} tickets (buy and use){nl}4.{img icon_item_Tos_Event_Coin 20 20} tickets (buy and use))"))
                            ticket_btn:SetEventScript(ui.LBUTTONUP, "indun_panel_item_use")
                            ticket_btn:SetEventScriptArgNumber(ui.LBUTTONUP, value)

                            local ticket_count = frame:CreateOrGetControl("richtext", key .. "ticket_count", 335, y + 5,
                                40, 30)
                            ticket_count:SetText("{ol}{#FFFFFF}{s16}({img pvpmine_shop_btn_total 20 20}d:" ..
                                                     INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_41") .. " w:" ..
                                                     INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_42") ..
                                                     " {img icon_item_Tos_Event_Coin 20 20}" ..
                                                     INDUN_PANEL_GET_RECIPE_TRADE_COUNT("EVENT_TOS_WHOLE_SHOP_314") ..
                                                     ")")

                            local auto_check = frame:CreateOrGetControl("checkbox", key .. "auto_check", 475, y, 25, 25)
                            AUTO_CAST(auto_check)
                            auto_check:SetEventScript(ui.LBUTTONUP, "indun_panel_ischecked")
                            auto_check:SetTextTooltip(g.lang == "Japanese" and
                                                          "{ol}チェックをすると自動マッチングボタンを押しません。" or
                                                          "{ol}If checked, the automatic matching button will not be pressed.")
                            auto_check:SetCheck(g.settings.singularity_check)

                            local buy_craft = frame:CreateOrGetControl('button', key .. 'buy_craft', 510, y, 80, 30)
                            AUTO_CAST(buy_craft)
                            buy_craft:SetText("{ol}{#EE7800}{s14}BUYCRAFT")
                            buy_craft:SetTextTooltip("{ol}" ..
                                                         INDUN_PANEL_LANG(
                                    "I'll buy 4 Challenge Vouchers{nl}craft a Singularity Voucher, and use it"))
                            buy_craft:SetEventScript(ui.LBUTTONUP, "indun_panel_singularity_ticket_craft")

                        end
                        indun_panel_singularity_frame(frame, key, y)
                    elseif key == "telharsha" then
                        function indun_panel_telharsha_frame(frame, key, y)

                            local btn = frame:CreateOrGetControl('button', key .. 'btn', 135, y, 80, 30)
                            btn:SetText("{ol}IN")
                            btn:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_solo")
                            btn:SetEventScriptArgNumber(ui.LBUTTONUP, value)

                            local count = frame:CreateOrGetControl("richtext", key .. "count", 220, y + 5)
                            count:SetText(indun_panel_get_entrance_count(value, 2))
                        end
                        indun_panel_telharsha_frame(frame, key, y)
                    elseif key == "velnice" then
                        function indun_panel_velnice_frame(frame, key, y)

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

                            local btn = frame:CreateOrGetControl('button', key .. 'btn', 135, y, 80, 30)
                            AUTO_CAST(btn)
                            btn:SetText("{ol}IN")
                            btn:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_velnice_solo")

                            local count = frame:CreateOrGetControl("richtext", key .. "count", 220, y + 5, 50, 30)
                            count:SetText(indun_panel_get_entrance_count(value, 2))

                            local recipe_name = "PVP_MINE_52"
                            local change_count = INDUN_PANEL_GET_RECIPE_TRADE_COUNT(recipe_name)
                            if change_count < 0 then
                                change_count = 0
                            end

                            function indun_panel_buyuse_vel(frame, ctrl, recipename, indun_type)

                                local count = GET_CURRENT_ENTERANCE_COUNT(
                                    GetClassByType("Indun", indun_type).PlayPerResetType)

                                local trade_count = INDUN_PANEL_GET_RECIPE_TRADE_COUNT(recipename)

                                local vel_oneday_ticket = 11030169 -- Ticket_Bernice_Enter_1d
                                local vel_ticket = 11030257

                                session.ResetItemList()
                                local invItemList = session.GetInvItemList()

                                if count == 1 then

                                    local use_item = session.GetInvItemByType(vel_oneday_ticket)
                                    if use_item ~= nil then
                                        INV_ICON_USE(use_item)
                                        ReserveScript("indun_panel_enter_velnice_solo()", 2.0)
                                        return
                                    end
                                    local use_item = session.GetInvItemByType(vel_ticket)
                                    if use_item ~= nil then
                                        INV_ICON_USE(use_item)
                                        ReserveScript("indun_panel_enter_velnice_solo()", 2.0)
                                        return
                                    end

                                    local vel_recipecls = GetClass('ItemTradeShop', recipename)
                                    local vel_overbuy_max = TryGetProp(vel_recipecls, 'MaxOverBuyCount', 0)
                                    local remain_count = vel_overbuy_max + trade_count

                                    if remain_count >= 1 then
                                        INDUN_PANEL_ITEM_BUY_USE(recipename, indun_type)
                                        ReserveScript("indun_panel_enter_velnice_solo()", 2.0)
                                        return
                                    else
                                        ui.SysMsg(g.lang == "Japanese" and "トレード回数が足りません。" or
                                                      "No trade count.")
                                        return
                                    end
                                else
                                    ReserveScript("indun_panel_enter_velnice_solo()", 1.0)
                                    return
                                end
                            end

                            local ticket_btn = frame:CreateOrGetControl('button', key .. 'ticket_btn', 265, y, 80, 30)
                            AUTO_CAST(ticket_btn)
                            ticket_btn:SetText("{ol}{#EE7800}{s14}BUYUSE")
                            ticket_btn:SetEventScript(ui.LBUTTONUP, "indun_panel_buyuse_vel")
                            ticket_btn:SetEventScriptArgString(ui.LBUTTONUP, recipe_name)
                            ticket_btn:SetEventScriptArgNumber(ui.LBUTTONUP, value)

                            function indun_panel_overbuy_count(recipe_name)
                                local aObj = GetMyAccountObj()
                                local recipecls = GetClass('ItemTradeShop', recipe_name)
                                local overbuy_max = TryGetProp(recipecls, 'MaxOverBuyCount', 0)
                                local overbuy_prop = TryGetProp(recipecls, 'OverBuyProperty', 'None')
                                local overbuy_count = TryGetProp(aObj, overbuy_prop, 0)
                                return tonumber(overbuy_max) - tonumber(overbuy_count)
                            end

                            local change_text = frame:CreateOrGetControl("richtext", key .. "change_text", 350, y + 5,
                                60, 30)
                            change_text:SetText(string.format("{ol}{#FFFFFF}(%d/%d)", change_count,
                                indun_panel_overbuy_count(recipe_name)))

                            local amount = frame:CreateOrGetControl("richtext", key .. "amount", 415, y + 5, 50, 30)
                            local amount_text = "{ol}{#FFFFFF}(" .. "{img pvpmine_shop_btn_total 20 20}"

                            function indun_panel_overbuy_amount(recipe_name)
                                local aObj = GetMyAccountObj()
                                local recipecls = GetClass('ItemTradeShop', recipe_name)
                                local overbuy_prop = TryGetProp(recipecls, 'OverBuyProperty', 'None')
                                local overbuy_count = TryGetProp(aObj, overbuy_prop, 0)

                                if INDUN_PANEL_GET_RECIPE_TRADE_COUNT(recipe_name) == 1 and overbuy_count == 0 then
                                    return 1000
                                elseif overbuy_count >= 0 then
                                    return overbuy_count * 50 + 1050
                                end
                                return 0
                            end

                            if tonumber(change_count) == 1 then
                                amount_text = amount_text .. "1,000)"
                            else
                                amount_text = amount_text ..
                                                  string.format("{ol}{#FF0000}%s", GET_COMMAED_STRING(
                                        indun_panel_overbuy_amount(recipe_name))) .. "{ol}{#FFFFFF})"
                            end
                            amount:SetText(amount_text)

                        end
                        indun_panel_velnice_frame(frame, key, y)
                    elseif key == "cemetery" then
                        function indun_panel_cemetery_frame(frame, key, y)
                            local btn = frame:CreateOrGetControl('button', key .. 'btn', 135, y, 80, 30)
                            btn:SetText("{ol}490")
                            btn:SetEventScript(ui.LBUTTONUP, "indun_panel_enter_solo")
                            btn:SetEventScriptArgNumber(ui.LBUTTONUP, value)

                            local count = frame:CreateOrGetControl("richtext", key .. "count", 220, y + 5)
                            count:SetText(indun_panel_get_entrance_count(value, 1))

                            local ticket_btn = frame:CreateOrGetControl('button', key .. 'ticket_btn', 250, y, 80, 30)
                            AUTO_CAST(ticket_btn)
                            ticket_btn:SetText("{ol}{#EE7800}{s14}USE")

                            local invItemList = session.GetInvItemList()
                            local guidList = invItemList:GetGuidList()
                            local cnt = guidList:Count()

                            local inv_count = 0
                            for i = 0, cnt - 1 do
                                local itemobj = GetIES(invItemList:GetItemByGuid(guidList:Get(i)):GetObject())
                                local invItem = invItemList:GetItemByGuid(guidList:Get(i))
                                if itemobj.ClassID == 11200276 or itemobj.ClassID == 11200275 or itemobj.ClassID ==
                                    11200274 then
                                    inv_count = inv_count + invItem.count
                                end
                            end

                            local item_class1 = GetClassByType('Item', 11200276)

                            local icon1 = item_class1.Icon

                            local ticket_notice = g.lang == "Japanese" and
                                                      string.format("{ol}{img %s 25 25 } %d個持っています。",
                                    icon1, inv_count) or
                                                      string.format("{ol}{img %s 25 25 } Quantity in Inventory", icon1,
                                    inv_count)

                            ticket_btn:SetTextTooltip(ticket_notice)
                            ticket_btn:SetEventScript(ui.LBUTTONUP, "indun_panel_item_use")
                            ticket_btn:SetEventScriptArgNumber(ui.LBUTTONUP, value)

                        end
                        indun_panel_cemetery_frame(frame, key, y)
                    elseif key == "jsr" then

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
                                textstr = g.settings.en_ver == 1 and english .. " After Start" or japanese ..
                                              ClMsg("After_Start");
                            elseif utilsec12 >= -300 then
                                local japanese, english = format_time(300 + utilsec12)
                                textstr = g.settings.en_ver == 1 and english .. " After Exit" or japanese ..
                                              ClMsg("After_Exit");
                            elseif utilsec22 >= 0 then
                                local japanese, english = format_time(utilsec22)
                                textstr = g.settings.en_ver == 1 and english .. " After Start" or japanese ..
                                              ClMsg("After_Start");
                            elseif utilsec22 >= -300 then
                                local japanese, english = format_time(300 + utilsec22)
                                textstr = g.settings.en_ver == 1 and english .. " After Exit" or japanese ..
                                              ClMsg("After_Exit");
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

                        function indun_panel_jsr_frame(frame, key, y)

                            local jsrbtn = frame:CreateOrGetControl('button', 'jsrbtn', 135, y, 80, 30)
                            jsrbtn:SetText("{ol}JSR")
                            jsrbtn:SetEventScript(ui.LBUTTONUP, "FIELD_BOSS_JOIN_ENTER_CLICK")
                            jsrbtn:SetUserValue("Y", y)
                            indun_panel_FIELD_BOSS_ENTER_TIMER_SETTING(frame)
                            jsrbtn:RunUpdateScript("indun_panel_FIELD_BOSS_ENTER_TIMER_SETTING", 1.0)

                        end
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

function indun_panel_singularity_ticket_craft(frame, ctrl, str_arg, step)

    local notice_msg
    if g.lang == "Japanese" then
        notice_msg = "{ol}[IDP]分裂券作成中{nl}バグ防止のため操作をしないでください"
    else
        notice_msg = "{ol}[IDP]Creating Singularity Voucher{nl}Please do not perform any actions to prevent bugs"
    end
    imcAddOn.BroadMsg("NOTICE_Dm_GetItem", notice_msg, 2.0)

    if step == 0 then
        local recipe_name = "PVP_MINE_40"
        if INDUN_PANEL_GET_RECIPE_TRADE_COUNT(recipe_name) >= 4 then
            local recipe_cls = GetClass("ItemTradeShop", recipe_name)
            session.ResetItemList()
            session.AddItemID(tostring(0), 1)
            local item_list = session.GetItemIDList()
            local cnt_text = string.format("%s %s", tostring(recipe_cls.ClassID), tostring(4))

            item.DialogTransaction("PVP_MINE_SHOP", item_list, cnt_text)
            ReserveScript(string.format("indun_panel_singularity_ticket_craft(nil,nil,nil,%d)", 1), 0.5)
            return
        else
            local msg
            if g.lang == "Japanese" then
                msg = "{ol}チャレンジ券が4枚未満です"
            else
                msg = "{ol}Less than 4 challenge tickets"
            end
            ui.SysMsg(msg)
            return
        end

    elseif step == 1 then
        local recipe_name = "PVP_MINE_122"
        local recipe_cls = GetClass("ItemTradeShop", recipe_name)
        session.ResetItemList()
        session.AddItemID(tostring(0), 1)
        local item_list = session.GetItemIDList()
        local cnt_text = string.format("%s %s", tostring(recipe_cls.ClassID), tostring(1))

        item.DialogTransaction("PVP_MINE_SHOP", item_list, cnt_text)
        ReserveScript(string.format("indun_panel_singularity_ticket_craft(nil,nil,nil,%d)", 2), 0.5)
        return
    elseif step == 2 then
        local recipe_name = "PVP_MINE_122"
        local recipe_cls = GetClass("ItemTradeShop", recipe_name)
        local item_cls = GetClass("Item", recipe_cls.TargetItem)

        local inv_item = session.GetInvItemByType(item_cls.ClassID)
        if inv_item then
            INV_ICON_USE(inv_item)
        else
            return
        end
        ReserveScript(string.format("indun_panel_singularity_ticket_craft(nil,nil,nil,%d)", 3), 0.5)
        return
    elseif step == 3 then
        local input_frame = ui.GetFrame("inputstring")
        if input_frame and input_frame:IsVisible() == 1 then
            INPUT_STRING_EXEC(input_frame)
        end
        ReserveScript(string.format("indun_panel_singularity_ticket_craft(nil,nil,nil,%d)", 4), 0.5)
        return
    elseif step == 4 then
        local item_id_ticket = 11030067 -- チャレンジモード：[Lv.520] 分裂特異点1回入場券(1日)
        local inv_item = session.GetInvItemByType(item_id_ticket)
        if inv_item then
            INV_ICON_USE(inv_item)
        else
            return
        end

        ReserveScript(string.format("indun_panel_enter_singularity(nil,nil,nil, %d)", 2000), 0.5)
        return
    end
end

function indun_panel_enter_challenge(frame, ctrl, str_index, indun_type)

    local index = tonumber(str_index)
    ReqChallengeAutoUIOpen(indun_type)
    ReserveScript(string.format("ReqMoveToIndun(%d,%d)", index, 0), 0.3)
    return
end

function indun_panel_enter_solo(frame, ctrl, str, induntype)

    ReqRaidAutoUIOpen(induntype)
    ReqMoveToIndun(1, 0)
end

function indun_panel_enter_auto(frame, ctrl, str, induntype)
    ReqRaidAutoUIOpen(induntype)

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

function indun_panel_enter_hard(frame, ctrl, str, induntype)

    local indunCls = GetClassByType("Indun", induntype)
    if str == "false" then
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

function indun_panel_enter_singularity(frame, ctrl, str, indun_type)

    ReqChallengeAutoUIOpen(indun_type)
    local indunCls = GetClassByType('Indun', indun_type);
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
    if indunType == "1002" or indunType == "2000" then -- 1002＝チャレPT 2000＝分裂
        indunType = tonumber(indunType)
        AnsGiveUpPrevPlayingIndun(1)
        ui.CloseFrame("indunenter")
        ReserveScript(string.format("indun_panel_enter_singularity('%s','%s','%s', %d)", _, _, _, indunType), 0.5)
        return
    else
        local yesScp = string.format("AnsGiveUpPrevPlayingIndun(%d)", 1);
        local noScp = string.format("AnsGiveUpPrevPlayingIndun(%d)", 0);
        ui.MsgBox(ClMsg("IndunAlreadyPlaying_AreYouGiveUp"), yesScp, noScp);
    end
end

function indun_panel_item_use(frame, ctrl, argStr, indun_type)

    local function indun_panel_enter_challenge_reserve()
        if g.settings.auto_challenge ~= 1 then
            return
        else
            ReserveScript(string.format("indun_panel_enter_challenge('%s','%s','%s', %d)", _, _, 2, 1002), 2.0)
            return
        end
    end

    if indun_type == 684 then
        local ticket_table = {11200276, 11200275, 11200274}
        session.ResetItemList()
        local invItemList = session.GetInvItemList()

        for _, classid in ipairs(ticket_table) do
            local use_item = session.GetInvItemByType(classid)
            if use_item then
                INV_ICON_USE(use_item)
                return
            end
        end
    end

    if argStr == "A" then
        local ticket_table = {641987, 641963}
        session.ResetItemList()
        local invItemList = session.GetInvItemList()

        for _, classid in ipairs(ticket_table) do
            local use_item = session.GetInvItemByType(classid)
            if use_item then
                INV_ICON_USE(use_item)
                indun_panel_enter_challenge_reserve()
                return
            end
        end
    end

    local enterance_count = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", indun_type).PlayPerResetType)

    if indun_type == 2000 then
        function indun_panel_item_use_sin(indun_type, enterance_count)

            local ticket_table = {10820018, 11030067}

            session.ResetItemList()
            local invItemList = session.GetInvItemList()
            local use_item = nil
            for _, classid in ipairs(ticket_table) do
                use_item = session.GetInvItemByType(classid)
                if use_item ~= nil then
                    local life_time = tonumber(GET_REMAIN_ITEM_LIFE_TIME(GetIES(use_item:GetObject())))
                    if life_time ~= nil and life_time < 86400 then
                        INV_ICON_USE(use_item)
                        ReserveScript(string.format("indun_panel_enter_singularity('%s','%s','%s', %d)", _, _, _,
                            indun_type), 1.0)
                        return
                    end
                end
            end

            for _, classid in ipairs(ticket_table) do
                use_item = session.GetInvItemByType(classid)
                if use_item ~= nil then
                    local life_time = tonumber(GET_REMAIN_ITEM_LIFE_TIME(GetIES(use_item:GetObject())))
                    if life_time ~= nil then
                        INV_ICON_USE(use_item)
                        ReserveScript(string.format("indun_panel_enter_singularity('%s','%s','%s', %d)", _, _, _,
                            indun_type), 1.0)
                        return
                    else
                        INV_ICON_USE(use_item)
                        ReserveScript(string.format("indun_panel_enter_singularity('%s','%s','%s', %d)", _, _, _,
                            indun_type), 1.0)
                        return
                    end
                end
            end

            if enterance_count == 0 then
                local dcount = INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_41")
                if dcount == 1 then
                    INDUN_PANEL_ITEM_BUY_USE("PVP_MINE_41", indun_type)

                    return
                end

                local wcount = INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_42")
                if wcount >= 1 then
                    INDUN_PANEL_ITEM_BUY_USE("PVP_MINE_42", indun_type)
                    return
                end

                local mcount = INDUN_PANEL_GET_RECIPE_TRADE_COUNT("EVENT_TOS_WHOLE_SHOP_314")
                if mcount >= 1 then
                    INDUN_PANEL_ITEM_BUY_USE("EVENT_TOS_WHOLE_SHOP_314", indun_type)
                    return
                end
            end

            function indun_panel_INV_ICON_USE(classid, indun_type)
                INV_ICON_USE(session.GetInvItemByType(classid))
                ReserveScript(string.format("indun_panel_enter_singularity('%s','%s','%s', %d)", _, _, _, indun_type),
                    1.0)
                return
            end

            local targetItems = {10000470, 11030021, 11030017}
            for i = 1, #targetItems do
                local classid = targetItems[i] -- インデックスを使ってアイテムを取得
                local use_item = session.GetInvItemByType(classid)
                if use_item ~= nil and enterance_count == 0 then
                    -- local obj = GetIES(use_item:GetObject());
                    --[[local msg = g.lang == "Japanese" and "期限はありません。使用しますか？" or
                                    "It has no expiration date.{nl}Do you want to use it?"
                    local yesscp = string.format("indun_panel_INV_ICON_USE(%d,%d)", classid, indun_type)
                    local msgbox = ui.MsgBox(msg, yesscp, '')
                    return]]
                    local msg = g.lang == "Japanese" and "{#FFFF00}期限がないチケットを使用しました" or
                                    "{#FFFF00}Used a ticket that did not expire"
                    ui.SysMsg(msg)
                    indun_panel_INV_ICON_USE(classid, indun_type)
                    return
                end
            end
        end

        indun_panel_item_use_sin(indun_type, enterance_count)
    elseif indun_type == 1000 then

        function indun_panel_item_use_cha(indun_type, enterance_count)

            local ticket_table = {10820019, 11030080, 641954, 641969, 641955, 10000073}

            session.ResetItemList()
            local invItemList = session.GetInvItemList()
            local use_item = nil
            for _, classid in ipairs(ticket_table) do
                use_item = session.GetInvItemByType(classid)
                if use_item ~= nil then
                    local life_time = tonumber(GET_REMAIN_ITEM_LIFE_TIME(GetIES(use_item:GetObject())))
                    if life_time ~= nil and life_time < 86400 then
                        INV_ICON_USE(use_item)
                        indun_panel_enter_challenge_reserve()
                        return
                    end
                end
            end

            for _, classid in ipairs(ticket_table) do
                use_item = session.GetInvItemByType(classid)
                if use_item ~= nil then
                    local life_time = tonumber(GET_REMAIN_ITEM_LIFE_TIME(GetIES(use_item:GetObject())))
                    if life_time ~= nil then
                        INV_ICON_USE(use_item)
                        indun_panel_enter_challenge_reserve()
                        return
                    else
                        INV_ICON_USE(use_item)
                        indun_panel_enter_challenge_reserve()
                        return
                    end
                end
            end

            if enterance_count == 1 then
                if g.settings.challenge_ticket == "month" then
                    local event_trade_count = INDUN_PANEL_GET_RECIPE_TRADE_COUNT("EVENT_TOS_WHOLE_SHOP_315")
                    if event_trade_count >= 1 then
                        INDUN_PANEL_ITEM_BUY_USE("EVENT_TOS_WHOLE_SHOP_315", indun_type)
                        indun_panel_enter_challenge_reserve()
                        return
                    end

                    local trade_count = INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_40")
                    if trade_count >= 1 then
                        INDUN_PANEL_ITEM_BUY_USE("PVP_MINE_40", indun_type)
                        indun_panel_enter_challenge_reserve()
                        return
                    elseif trade_count <= 0 then
                        local account_obj = GetMyAccountObj()
                        local recipe_cls = GetClass('ItemTradeShop', "PVP_MINE_40")
                        local over_max = TryGetProp(recipe_cls, 'MaxOverBuyCount', 0)
                        local over_prop = TryGetProp(recipe_cls, 'OverBuyProperty', 'None')
                        local over_count = TryGetProp(account_obj, over_prop, 0)
                        local overbuy_count = tonumber(over_max) - tonumber(over_count)

                        if overbuy_count > 0 then
                            local msg = g.lang == "Japanese" and "{img pvpmine_shop_btn_total 29 29} " ..
                                            (1100 + over_count * 100) .. " 使用しました" or
                                            "{img pvpmine_shop_btn_total 29 29} " .. (1100 + over_count * 100) ..
                                            " Used"
                            ui.SysMsg(msg)
                            INDUN_PANEL_ITEM_BUY_USE("PVP_MINE_40", indun_type)
                            indun_panel_enter_challenge_reserve()
                            return
                        end
                    end
                else

                    local trade_count = INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_40")
                    if trade_count >= 1 then
                        INDUN_PANEL_ITEM_BUY_USE("PVP_MINE_40", indun_type)
                        indun_panel_enter_challenge_reserve()
                        return
                    elseif trade_count <= 0 then
                        local account_obj = GetMyAccountObj()
                        local recipe_cls = GetClass('ItemTradeShop', "PVP_MINE_40")
                        local over_max = TryGetProp(recipe_cls, 'MaxOverBuyCount', 0)
                        local over_prop = TryGetProp(recipe_cls, 'OverBuyProperty', 'None')
                        local over_count = TryGetProp(account_obj, over_prop, 0)
                        local overbuy_count = tonumber(over_max) - tonumber(over_count)

                        if overbuy_count > 0 then
                            local msg = g.lang == "Japanese" and "{img pvpmine_shop_btn_total 29 29} " ..
                                            (1100 + over_count * 100) .. " 使用しました" or
                                            "{img pvpmine_shop_btn_total 29 29} " .. (1100 + over_count * 100) ..
                                            " Used"
                            ui.SysMsg(msg)
                            INDUN_PANEL_ITEM_BUY_USE("PVP_MINE_40", indun_type)
                            indun_panel_enter_challenge_reserve()
                            return
                        end
                    end

                    local event_trade_count = INDUN_PANEL_GET_RECIPE_TRADE_COUNT("EVENT_TOS_WHOLE_SHOP_315")
                    if event_trade_count >= 1 then
                        INDUN_PANEL_ITEM_BUY_USE("EVENT_TOS_WHOLE_SHOP_315", indun_type)
                        indun_panel_enter_challenge_reserve()
                        return
                    end
                end
            end
        end
        indun_panel_item_use_cha(indun_type, enterance_count)
    end
end

function INDUN_PANEL_ITEM_BUY_USE(recipe_name, indun_type)
    local recipeCls = GetClass("ItemTradeShop", recipe_name)
    session.ResetItemList()
    session.AddItemID(tostring(0), 1)
    local itemlist = session.GetItemIDList()
    local cntText = string.format("%s %s", tostring(recipeCls.ClassID), tostring(1))
    if string.find(recipe_name, "EVENT_TOS") then
        item.DialogTransaction("EVENT_TOS_WHOLE_SHOP", itemlist, cntText)
    else
        item.DialogTransaction("PVP_MINE_SHOP", itemlist, cntText)
    end
    local itemCls = GetClass("Item", recipeCls.TargetItem)
    ReserveScript(string.format("INV_ICON_USE(session.GetInvItemByType(%d));", itemCls.ClassID), 1)

    if indun_type == 2000 then
        ReserveScript(string.format("indun_panel_enter_singularity('%s','%s','%s', %d)", _, _, _, indun_type), 2.0)
        return
    end
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

function indun_panel_FPS_UPDATE(frame, msg)
    if frame:IsVisible() == 1 then
        return
    else
        indun_panel_frame_init()
    end
end

function g.save_settings()
    local function save_json(path, tbl)
        local file = io.open(path, "w")
        local str = json.encode(tbl)
        file:write(str)
        file:close()
    end
    save_json(g.settings_path, g.settings)
end

function g.load_settings()

    local function load_json(path)

        local file = io.open(path, "r")
        if file then
            local content = file:read("*all")
            file:close()
            local table = json.decode(content)
            return table
        else
            return nil
        end
    end

    local settings = load_json(g.settings_path)

    if not settings then
        settings = {}
    end

    g.settings = settings
    g.save_settings()
end

function g.settings_make()
    if next(g.settings) then
        return
    end

    g.settings = {
        checkbox = 0,
        zoom = 336,
        challenge_checkbox = 1,
        singularity_checkbox = 1,
        redania_checkbox = 1,
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
        season_checkbox = 1,
        x = 665,
        y = 30,
        move = 0
    }

    g.save_settings()
end

function g.get_map_type()
    local map_name = session.GetMapName()
    local map_cls = GetClass("Map", map_name)
    local map_type = map_cls.MapType
    return map_type
end

g.loaded = false
g.sing = false
function INDUN_PANEL_ON_INIT(addon, frame)

    local start_time = os.clock() -- ★処理開始前の時刻を記録★

    g.addon = addon
    g.frame = frame
    g.framename = addonName
    g.lang = option.GetCurrentCountry()

    g.REGISTER = {}

    local map_id = session.GetMapID()

    if map_id ~= 8022 then

        if g.get_map_type() == "City" or (g.settings.field_mode == 1 and g.get_map_type() ~= "Instance") then

            if not g.loaded then
                g.load_settings()
                g.settings_make()
                g.loaded = true
            end

            if g.settings.checkbox == 1 then
                addon:RegisterMsg('GAME_START', "indun_panel_init")
            else
                addon:RegisterMsg('GAME_START', "indun_panel_frame_init")
            end

            if not g.sing and INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_41") == 0 then

                local earthtowershop = ui.GetFrame('earthtowershop')
                if earthtowershop then
                    earthtowershop:Resize(0, 0)
                    indun_panel_minimized_pvpmine_shop_init()
                    g.sing = true
                end
            end

            g.setup_hook_and_event(addon, "INDUN_ALREADY_PLAYING", "indun_panel_INDUN_ALREADY_PLAYING", false)
            addon:RegisterMsg('FPS_UPDATE', "indun_panel_FPS_UPDATE")
        else
            indun_panel_autozoom_init()
        end
    end

    addon:RegisterMsg('GAME_START_3SEC', "indun_panel_GAME_START_3SEC")

    local functionName = "AUTOMAPCHANGE_CAMERA_ZOOM"
    if _G[functionName] and type(_G[functionName]) == "function" then
        _G[functionName] = nil
    end

    local end_time = os.clock() -- ★処理終了後の時刻を記録★
    local elapsed_time = end_time - start_time
    -- CHAT_SYSTEM(string.format("indun_panel_ON_INIT: %.4f seconds", elapsed_time))
end

function indun_panel_minimized_pvpmine_shop_init()
    local shopframe = ui.GetFrame('earthtowershop')
    pc.ReqExecuteTx_NumArgs("SCR_PVP_MINE_SHOP_OPEN", 0);
    shopframe:RunUpdateScript("INDUN_PANEL_EARTHTOWERSHOP_CLOSE_RESTART", 0.2)
end

function INDUN_PANEL_EARTHTOWERSHOP_CLOSE_RESTART(frame)
    local shopframe = ui.GetFrame('earthtowershop')
    if shopframe:IsVisible() == 1 then
        shopframe:Resize(580, 1920)
        ui.CloseFrame("earthtowershop")
        return 0
    else
        return 1
    end
end

function INDUN_PANEL_LANG(str)

    if g.settings.en_ver == 1 then
        if str == tostring("cemetery") then
            str = "wailing"
        end
        return "{s20}" .. str
    end

    if g.lang == "Japanese" then
        if str == tostring("redania") then
            str = "レダニア"
        end
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
        -- "I'll buy 4 Challenge Vouchers and craft a singularity Voucher"
        if str == "I'll buy 4 Challenge Vouchers{nl}craft a Singularity Voucher, and use it" then
            str = "チャレンジチケットを4枚買って{nl}分裂特異点チケットを作って使います"

        end

        if str == tostring("priority{nl}1.Tickets due within 24 hours{nl}2.Tickets with expiration date{nl}" ..
                               "3.{img pvpmine_shop_btn_total 20 20} tickets (buy and use){nl}4.{img icon_item_Tos_Event_Coin 20 20} tickets (buy and use))") then
            str = "優先順位{nl}1.24時間以内の期限付きチケット{nl}2.期限付きチケット{nl}" ..
                      "3.{img pvpmine_shop_btn_total 20 20}チケット(買って使います){nl}4.{img icon_item_Tos_Event_Coin 20 20}チケット(買って使います)"
        end
        if str == tostring("priority{nl}1.Tickets due within 24 hours{nl}2.Tickets with expiration date{nl}" ..
                               "3.Event tickets with no expiration date{nl}4.{img icon_item_Tos_Event_Coin 20 20} tickets (buy and use){nl}" ..
                               "5.{img pvpmine_shop_btn_total 20 20} tickets (buy and use){nl} {nl}" ..
                               "{#FFFF00}Right-click to switch priority") then
            str = "優先順位{nl}1.24時間以内の期限付きチケット{nl}2.期限付きチケット{nl}" ..
                      "3.期限のないイベントチケット{nl}4.{img icon_item_Tos_Event_Coin 20 20}チケット(買って使います){nl}" ..
                      "5.{img pvpmine_shop_btn_total 20 20}チケット(買って使います){nl}" ..
                      "{img pvpmine_shop_btn_total 20 20}このチケットで分裂券作れるで!{nl} {nl}" ..
                      "{#FFFF00}右クリックで優先順位切替"
        end
        -- "There are no ticket items in inventory."
        if str == tostring("There are no ticket items in inventory.") then
            str = "(自動マッチング/1人)入場券を持っていません。"
        end
        return "{s16}" .. str
    end

    return "{s20}" .. str
end

