-- v1.0.0 ebisukeさんのstatview_ex_rがバグってたので新たに作った。
-- v1.0.1 表示が永遠に増えていくバグ直したつもり
-- v1.0.2 loadがバグってたのを修正
-- v1.0.3 更にバグ修正。くるしい。
-- v1.0.4 もうバグに疲れた。
-- v1.0.5 キャラ毎に表示非表示切替機能追加。
-- v1.0.6 再度バグ発生したので修正。セットフレームをちょっとズラした。
-- v1.0.7 やっぱりバグってた。くるしい。
-- v1.0.8 多分直った。
-- v1.0.9 めちゃ簡単なトコでハマった。これで大丈夫のはず。
-- v1.1.0 JSONファイル同時保存はエラーになるという学びを得た。
-- v1.1.1 リロード画面の効果音消去、爆速表示に変更
-- v1.1.2 リロードでバグった場合に効果音が消去されたままだったのを修正
-- v1.1.3 ギルメンの要望に応えて日本鯖だけ別処理
-- v1.1.4 まれに効果音が0のままで固定される不具合修正
-- v1.1.5 効果音のバグ再修正。
-- v1.1.6 色選べる様に。コード書き直した。もちろん設定ファイルは初期化される。
-- v1.1.7 ギアスコアの反映を見直し。フレーム表示のタイミングも見直し
-- v1.1.8 海外で数字が切れるらしいところ修正。
-- v1.1.9 フォルダ作るコードをアドオン導入時のみに。
-- v1.2.0 ウルトラワイド対応
-- v1.2.1 読込早くした
-- v1.2.2 桁区切り無しに
-- v1.2.3 読み込み時バグってたの修正
local addon_name = "always_status"
local addon_name_lower = string.lower(addon_name)
local author = "norisan"
local ver = "1.2.3"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addon_name] = _G["ADDONS"][author][addon_name] or {}
local g = _G["ADDONS"][author][addon_name]

g.settings_file_loc = string.format('../addons/%s/settings.json', addon_name_lower)

-- local acutil = require("acutil")
-- local os = require("os")
local json = require("json")

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

local status_list = {"STR", "INT", "CON", "MNA", "DEX", "gear_score", "ability_point_score", "PATK", "MATK", "HEAL_PWR",
                     "SR", "HR", "BLK_BREAK", "CRTATK", "CRTMATK", "CRTHR", "DEF", "MDEF", "SDR", "DR", "BLK", "CRTDR",
                     "MSPD", "CastingSpeed", "Add_Damage_Atk", "ResAdd_Damage", "Aries_Atk", "Slash_Atk", "Strike_Atk",
                     "Arrow_Atk", "Cannon_Atk", "Gun_Atk", "Magic_Melee_Atk", "Magic_Fire_Atk", "Magic_Ice_Atk",
                     "Magic_Lightning_Atk", "Magic_Earth_Atk", "Magic_Poison_Atk", "Magic_Dark_Atk", "Magic_Holy_Atk",
                     "Magic_Soul_Atk", "BOSS_ATK", "Cloth_Atk", "Leather_Atk", "Iron_Atk", "Ghost_Atk",
                     "MiddleSize_Def", "Cloth_Def", "Leather_Def", "Iron_Def", "stun_res", "high_fire_res",
                     "high_freezing_res", "high_lighting_res", "high_poison_res", "high_laceration_res",
                     "portion_expansion", "Forester_Atk", "Widling_Atk", "Klaida_Atk", "Paramune_Atk", "Velnias_Atk",
                     "perfection", "revenge"}

local str_table = {
    ["物理クリティカル攻撃力"] = "物理クリ攻撃",
    ["魔法クリティカル攻撃力"] = "魔法クリ攻撃",
    ["クリティカル発生"] = "クリ発生",
    ["クリティカル抵抗"] = "クリ抵抗",
    ["キャスティング時間比率"] = "キャス時間比率",
    ["追加ダメージ抵抗"] = "追加ダメ抵抗",
    ["突ダメージアップ"] = "突アップ",
    ["斬ダメージアップ"] = "斬アップ",
    ["打ダメージアップ"] = "打アップ",
    ["弓矢のダメージアップ"] = "弓アップ",
    ["キャノンダメージアップ"] = "キャノアップ",
    ["銃器ダメージアップ"] = "銃器アップ",
    ["無属性魔法ダメージアップ"] = "無属性アップ",
    ["炎属性追加ダメージアップ"] = "炎属性アップ",
    ["氷属性魔法ダメージアップ"] = "氷属性アップ",
    ["雷属性魔法ダメージアップ"] = "雷属性アップ",
    ["地属性魔法ダメージアップ"] = "地属性アップ",
    ["毒属性魔法ダメージアップ"] = "毒属性アップ",
    ["闇属性魔法ダメージアップ"] = "闇属性アップ",
    ["聖属性魔法ダメージアップ"] = "聖属性アップ",
    ["念属性魔法ダメージアップ"] = "念属性アップ",
    ["ボス対象攻撃力"] = "ボス対象攻撃力",
    ["クロース防御対象攻撃力"] = "クロース対象",
    ["レザー防御対象攻撃力"] = "レザー対象",
    ["プレート防御対象攻撃力"] = "プレート対象",
    ["アストラル防御対象攻撃力"] = "アストラル対象",
    ["中型対象攻撃力相殺"] = "中型相殺",
    ["クロース対象攻撃力相殺"] = "クロース相殺",
    ["レザー対象攻撃力相殺"] = "レザー相殺",
    ["プレート対象攻撃力相殺"] = "プレート相殺",
    ["極：強劇性の猛毒抵抗"] = "極：猛毒抵抗",
    ["HP回復のエリクサー広域化"] = "エリクサー広域",
    ["植物型対象攻撃力"] = "植物対象攻撃力",
    ["野獣型対象攻撃力"] = "野獣対象攻撃力",
    ["昆虫型対象攻撃力"] = "昆虫対象攻撃力",
    ["変異型対象攻撃力"] = "変異対象攻撃力",
    ["悪魔型対象攻撃力"] = "悪魔対象攻撃力",
    ["パーフェクト効果"] = "パーフェクト",
    ["復讐効果"] = "復讐"
}

local color_table = {
    [0] = "FFFFFF",
    [1] = "FF6600",
    [2] = "FF4040",
    [3] = '66B3FF',
    [4] = '00FF00',
    [5] = 'FF0000',
    [6] = 'FF00FF',
    [7] = 'FFFF00',
    [8] = "ADFF2F",
    [9] = "00FFFF"
}

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
        return nil
    end
    local content = file:read("*all")
    file:close()
    if not content or content == "" then
        return nil
    end
    local decoded_table = json.decode(content)
    return decoded_table
end

function ALWAYS_STATUS_ON_INIT(addon, frame)
    g.addon = addon
    g.frame = frame
    g.REGISTER = {}
    g.cid = info.GetCID(session.GetMyHandle())
    g.is_jp = (option.GetCurrentCountry() == "Japanese")

    if not g.settings then
        always_status_load_settings()
    else
        if not g.settings[g.cid] then
            always_status_load_settings()
        end
    end

    frame:RunUpdateScript("always_status_original_frame_reduction", 1.0)
    addon:RegisterMsg("GAME_START", "STATUS_INFO");
    addon:RegisterMsg("GAME_START_3SEC", "always_status_frame_init")
    g.setup_hook_and_event(addon, "STATUS_ONLOAD", "always_status_STATUS_ONLOAD", false);
end

function always_status_original_frame_reduction(frame)
    local frame = ui.GetFrame("status")
    frame:SetVisible(1);
    frame:Resize(0, 0)
end

function always_status_STATUS_ONLOAD(my_frame, my_msg)
    local frame, obj, argStr, argNum = g.get_event_args(my_msg)
    frame:Resize(500, 1080)
    if option.GetCurrentCountry() == 'German' then
        local tabObj = frame:GetChild('statusTab');
        local itembox_tab = tolua.cast(tabObj, "ui::CTabControl");
        itembox_tab:SetItemsFixWidth(150)
    end
    STAT_RESET(frame);
    ACHIEVE_RESET(frame);
    CHATBALLOON_INIT(frame);
    HUD_SKIN_INIT(frame);
    STATUS_REPUTATION_INIT();
    STATUS_TAB_CHANGE(frame);
    STATUS_INFO();
    STATUS_UPDATE_EXP_UP_BOX(frame);
    OPEN_DMGSELECTOR(frame);
    pc.ReqExecuteTx('GUIDE_QUEST_OPEN_UI', frame:GetName())
end

function always_status_save_settings()
    g.save_json(g.settings_file_loc, g.settings)
end

function always_status_load_settings()
    local settings = g.load_json(g.settings_file_loc)
    local volume = config.GetSoundVolume()

    if not settings or settings["color"] == nil then
        settings = {}
        settings.frame_X = 1600
        settings.frame_Y = 500
        settings.enable = 1
        settings.volume = volume
        for i = 1, 10 do
            settings[tostring(i)] = {
                memo = "free memo " .. i,
                STR = 1,
                INT = 1,
                CON = 0,
                MNA = 0,
                DEX = 0,
                gear_score = 1,
                ability_point_score = 1,
                PATK = 1,
                MATK = 1,
                HEAL_PWR = 0,
                SR = 0,
                HR = 1,
                BLK_BREAK = 1,
                CRTATK = 1,
                CRTMATK = 1,
                CRTHR = 1,
                DEF = 0,
                MDEF = 0,
                SDR = 0,
                DR = 1,
                BLK = 0,
                CRTDR = 1,
                MSPD = 1,
                CastingSpeed = 1,
                Add_Damage_Atk = 0,
                ResAdd_Damage = 0,
                Aries_Atk = 0,
                Slash_Atk = 0,
                Strike_Atk = 0,
                Arrow_Atk = 0,
                Cannon_Atk = 0,
                Gun_Atk = 0,
                Magic_Melee_Atk = 0,
                Magic_Fire_Atk = 0,
                Magic_Ice_Atk = 0,
                Magic_Lightning_Atk = 0,
                Magic_Earth_Atk = 0,
                Magic_Poison_Atk = 0,
                Magic_Dark_Atk = 0,
                Magic_Holy_Atk = 0,
                Magic_Soul_Atk = 0,
                BOSS_ATK = 1,
                Cloth_Atk = 0,
                Leather_Atk = 0,
                Iron_Atk = 0,
                Ghost_Atk = 0,
                MiddleSize_Def = 1,
                Cloth_Def = 0,
                Leather_Def = 1,
                Iron_Def = 0,
                stun_res = 0,
                high_fire_res = 0,
                high_freezing_res = 0,
                high_lighting_res = 0,
                high_poison_res = 0,
                high_laceration_res = 0,
                portion_expansion = 0,
                Forester_Atk = 0,
                Widling_Atk = 0,
                Klaida_Atk = 0,
                Paramune_Atk = 0,
                Velnias_Atk = 0,
                perfection = 1,
                revenge = 0
            }
        end
        settings["color"] = {
            STR = "{#00FF00}",
            INT = "{#00FF00}",
            CON = "{#00FF00}",
            MNA = "{#00FF00}",
            DEX = "{#00FF00}",
            gear_score = "{#00FF00}",
            ability_point_score = "{#00FF00}",
            PATK = "{#FF6600}",
            MATK = "{#FF6600}",
            HEAL_PWR = "{#FF6600}",
            SR = "{#FF6600}",
            HR = "{#FF6600}",
            BLK_BREAK = "{#FF6600}",
            CRTATK = "{#FF6600}",
            CRTMATK = "{#FF6600}",
            CRTHR = "{#FF6600}",
            DEF = "{#FF6600}",
            MDEF = "{#FF6600}",
            SDR = "{#FF6600}",
            DR = "{#FF6600}",
            BLK = "{#FF6600}",
            CRTDR = "{#FF6600}",
            MSPD = "{#FF6600}",
            CastingSpeed = "{#FF6600}",
            Add_Damage_Atk = "{#FF4040}",
            ResAdd_Damage = "{#66B3FF}",
            Aries_Atk = "{#FF4040}",
            Slash_Atk = "{#FF4040}",
            Strike_Atk = "{#FF4040}",
            Arrow_Atk = "{#FF4040}",
            Cannon_Atk = "{#FF4040}",
            Gun_Atk = "{#FF4040}",
            Magic_Melee_Atk = "{#FF4040}",
            Magic_Fire_Atk = "{#FF4040}",
            Magic_Ice_Atk = "{#FF4040}",
            Magic_Lightning_Atk = "{#FF4040}",
            Magic_Earth_Atk = "{#FF4040}",
            Magic_Poison_Atk = "{#FF4040}",
            Magic_Dark_Atk = "{#FF4040}",
            Magic_Holy_Atk = "{#FF4040}",
            Magic_Soul_Atk = "{#FF4040}",
            BOSS_ATK = "{#FF4040}",
            Cloth_Atk = "{#FF4040}",
            Leather_Atk = "{#FF4040}",
            Iron_Atk = "{#FF4040}",
            Ghost_Atk = "{#FF4040}",
            MiddleSize_Def = "{#66B3FF}",
            Cloth_Def = "{#66B3FF}",
            Leather_Def = "{#66B3FF}",
            Iron_Def = "{#66B3FF}",
            stun_res = "{#66B3FF}",
            high_fire_res = "{#66B3FF}",
            high_freezing_res = "{#66B3FF}",
            high_lighting_res = "{#66B3FF}",
            high_poison_res = "{#66B3FF}",
            high_laceration_res = "{#66B3FF}",
            portion_expansion = "{#66B3FF}",
            Forester_Atk = "{#FF4040}",
            Widling_Atk = "{#FF4040}",
            Klaida_Atk = "{#FF4040}",
            Paramune_Atk = "{#FF4040}",
            Velnias_Atk = "{#FF4040}",
            perfection = "{#FF4040}",
            revenge = "{#FF4040}"
        }
    end

    g.settings = settings

    if g.settings[g.cid] == nil or type(g.settings[g.cid]) == "number" then
        g.settings[g.cid] = {
            key = 1,
            use = 1
        }
    end
    always_status_save_settings()
end

function always_status_language(str)
    if g.is_jp then
        if str == "Right-click to set display" then
            return "右クリックで表示設定"
        end
        if str == "Display and hide for each character" then
            return "キャラクター毎に表示非表示を切り替えます"
        end
        if str == "If checked, the frame is fixed" then
            return "チェックするとフレームが固定されます"
        end
        if str == "Display Setting" then
            return "表示設定"
        end
    end
    return str
end

function always_status_checkbox(frame, ctrl, str, num)
    local number = num
    local is_check = ctrl:IsChecked()
    local name = ctrl:GetName()
    if name == "enablecheck" then
        if is_check == 1 then
            g.settings.enable = 0
            ui.GetFrame(addon_name_lower):EnableMove(0)
        else
            g.settings.enable = 1
            ui.GetFrame(addon_name_lower):EnableMove(1)
        end
    end

    for _, status in ipairs(status_list) do
        if tostring("check" .. status) == ctrl:GetName() then
            g.settings[tostring(number)][status] = is_check
            break
        end
    end
    always_status_save_settings()
    always_status_info_setting_load(number)
    always_status_frame_init()
end

function always_status_color_select(frame, ctrl, str, num)
    local parent = ctrl:GetParent()
    local status_name = string.gsub(parent:GetName(), "colorbox", "")
    g.settings["color"][status_name] = "{#" .. str .. "}"
    always_status_save_settings()
    always_status_info_setting(frame, ctrl, str, num)
    always_status_frame_init()
end

function always_status_info_setting_load(number)
    local frame = ui.GetFrame(addon_name_lower .. "new_frame")
    local gb = GET_CHILD_RECURSIVELY(frame, "gb")
    local setting_gb = gb:CreateOrGetControl("groupbox", "setting_gb", 10, 70, gb:GetWidth() - 20, gb:GetHeight() - 80)
    AUTO_CAST(setting_gb)
    local memo = GET_CHILD_RECURSIVELY(frame, "memo")
    memo:SetText(g.settings[tostring(number)].memo)

    frame:SetLayerLevel(150)
    setting_gb:SetSkinName("test_frame_midle_light")

    local y = 10
    for _, status in ipairs(status_list) do
        local check = setting_gb:CreateOrGetControl("checkbox", "check" .. status, 470, y, 20, 20)
        AUTO_CAST(check)
        check:SetEventScript(ui.LBUTTONUP, "always_status_checkbox")
        check:SetEventScriptArgNumber(ui.LBUTTONUP, number);
        check:SetCheck(g.settings[tostring(number)][status])

        local color_box = setting_gb:CreateOrGetControl('groupbox', "colorbox" .. status, 255, y, 200, 20);
        AUTO_CAST(color_box)
        for j = 0, 9 do
            local color_cls = color_table[j]
            local color_pic = color_box:CreateOrGetControl("picture", "color" .. j, 20 * j, 0, 20, 20);
            AUTO_CAST(color_pic)
            color_pic:SetImage("chat_color");
            color_pic:SetColorTone("FF" .. color_cls)
            color_pic:SetEventScript(ui.LBUTTONUP, "always_status_color_select")
            color_pic:SetEventScriptArgString(ui.LBUTTONUP, color_cls)
        end

        local control = setting_gb:CreateOrGetControl("richtext", status, 20, y)
        AUTO_CAST(control)
        if status == "STR" or status == "INT" or status == "CON" or status == "MNA" or status == "DEX" then
            control:SetText(g.settings["color"][status] .. "{s16}{ol}" .. ClMsg(status))
        elseif status == "gear_score" then
            control:SetText(g.settings["color"][status] .. "{s16}{ol}" .. ScpArgMsg("EquipedItemGearScore"))
        elseif status == "ability_point_score" then
            control:SetText(g.settings["color"][status] .. "{s16}{ol}" .. ScpArgMsg("AbilityPointScore"))
        else
            control:SetText(g.settings["color"][status] .. "{s16}{ol}" .. ScpArgMsg(status))
        end
        control:AdjustFontSizeByWidth(250)
        y = y + 25
    end

    g.settings[g.cid].key = number
    always_status_save_settings()
    always_status_frame_init()
end

function always_status_frame_close(frame)
    ui.GetFrame(addon_name_lower .. "new_frame"):ShowWindow(0)
end

function always_status_info_setting(frame, ctrl, str, num)
    local frame = ui.CreateNewFrame("notice_on_pc", addon_name_lower .. "new_frame", 0, 0, 70, 30)
    AUTO_CAST(frame)
    frame:EnableHittestFrame(1);
    frame:EnableHitTest(1)
    frame:Resize(555, 900)
    frame:SetPos(250, 10)
    frame:RemoveAllChild()
    frame:ShowWindow(1)
    local gb = frame:CreateOrGetControl("groupbox", "gb", 10, 10, frame:GetWidth() - 10, frame:GetHeight() - 10)
    AUTO_CAST(gb)
    gb:SetSkinName("test_frame_low")

    local title = gb:CreateOrGetControl("richtext", "title", 30, 40)
    title:SetText("{s18}{ol}{#FFFFFF}" .. always_status_language("Display Setting"))

    local close = gb:CreateOrGetControl("button", "close", 0, 0, 20, 20)
    AUTO_CAST(close)
    close:SetImage("testclose_button")
    close:SetGravity(ui.RIGHT, ui.TOP)
    close:SetEventScript(ui.LBUTTONUP, "always_status_frame_close")

    local drop_list = gb:CreateOrGetControl('droplist', 'setting_DropList', 165, 10, 200, 20)
    AUTO_CAST(drop_list)
    drop_list:SetSkinName('droplist_normal');
    drop_list:EnableHitTest(1);
    drop_list:SetTextAlign("center", "center");
    for i = 1, 10 do
        if g.settings[tostring(i)].memo == "free memo " .. i then
            drop_list:AddItem(i - 1, tostring("Data ") .. i, 0, "always_status_info_setting_load(" .. i .. ")");
        else
            drop_list:AddItem(i - 1, g.settings[tostring(i)].memo, 0, "always_status_info_setting_load(" .. i .. ")");
        end
    end
    drop_list:SelectItem(tonumber(g.settings[g.cid].key) - 1)
    local memo = gb:CreateOrGetControl('edit', 'memo', 215, 35, 200, 30)
    AUTO_CAST(memo)
    memo:SetEventScript(ui.ENTERKEY, "always_status_memo_save")
    memo:SetFontName("white_16_ol")
    memo:SetTextAlign("center", "center")

    local enable_check = gb:CreateOrGetControl("checkbox", "enablecheck", 510, 40, 20, 20)
    AUTO_CAST(enable_check)
    enable_check:SetEventScript(ui.LBUTTONUP, "always_status_checkbox")
    enable_check:SetTextTooltip(always_status_language("If checked, the frame is fixed"))
    if g.settings.enable == 0 then
        enable_check:SetCheck(1)
    else
        enable_check:SetCheck(0)
    end
    always_status_info_setting_load(tonumber(g.settings[g.cid].key))
end

function always_status_memo_save(frame, ctrl, str, num)
    local text = ctrl:GetText()
    g.settings[tostring(g.settings[g.cid].key)].memo = text
    ui.SysMsg("MEMO registered.")
    always_status_save_settings()
    always_status_info_setting(frame, ctrl, str, num)
end

function always_status_frame_toggle(frame, ctrl)
    if g.settings[g.cid].use == 1 then
        g.settings[g.cid].use = 0
    else
        g.settings[g.cid].use = 1
    end
    always_status_save_settings()
    always_status_frame_init()
end

function always_status_frame_init()
    local frame = ui.GetFrame(addon_name_lower)
    frame:RemoveAllChild()
    frame:EnableHitTest(1)
    frame:EnableMove(g.settings.enable)
    local map_frame = ui.GetFrame("map")
    local width = map_frame:GetWidth()

    if g.settings.frame_X > 1920 and width <= 1920 then
        g.settings.frame_X = 1600
        g.settings.frame_Y = 500
    end

    frame:SetPos(g.settings.frame_X, g.settings.frame_Y)
    frame:SetTitleBarSkin("None")
    frame:SetSkinName("None")
    frame:SetLayerLevel(11)
    frame:SetEventScript(ui.LBUTTONUP, "always_status_frame_move")
    frame:SetEventScript(ui.RBUTTONDOWN, "always_status_info_setting")

    local as_text = frame:CreateOrGetControl("richtext", "as_text", 20, 5)
    as_text:SetText("{ol}{S10}Always Status")
    as_text:SetEventScript(ui.RBUTTONDOWN, "always_status_info_setting")
    as_text:SetTextTooltip(always_status_language("Right-click to set display"))

    local char_settings = g.settings[g.cid]

    if char_settings.use ~= 1 then
        local plus_slot = frame:CreateOrGetControl("slot", "plus_slot", 0, 3, 15, 15)
        AUTO_CAST(plus_slot)
        plus_slot:SetSkinName("None")
        plus_slot:EnablePop(0);
        plus_slot:EnableDrop(0);
        plus_slot:EnableDrag(0);
        plus_slot:SetEventScript(ui.LBUTTONUP, "always_status_frame_toggle")
        local icon = CreateIcon(plus_slot);
        AUTO_CAST(icon)
        icon:SetImage("btn_plus");
        icon:SetTextTooltip(always_status_language("Display and hide for each character"))
        frame:Resize(150, 20)
        frame:ShowWindow(1)
        return
    else
        local minus_slot = frame:CreateOrGetControl("slot", "minus_slot", 0, 3, 15, 15)
        AUTO_CAST(minus_slot)
        minus_slot:SetSkinName("None")
        minus_slot:EnablePop(0);
        minus_slot:EnableDrop(0);
        minus_slot:EnableDrag(0);
        minus_slot:SetEventScript(ui.LBUTTONUP, "always_status_frame_toggle")
        local icon = CreateIcon(minus_slot);
        AUTO_CAST(icon)
        icon:SetImage("btn_minus");
        icon:SetTextTooltip(always_status_language("Display and hide for each character"))

        local y = 20
        local pc = GetMyPCObject();
        local statframe = ui.GetFrame("status")
        local box = GET_CHILD_RECURSIVELY(statframe, "internalstatusBox")

        local key = char_settings.key

        for _, status in ipairs(status_list) do

            local display_settings = g.settings[tostring(key)]

            if display_settings[status] and display_settings[status] == 1 then
                local title = frame:CreateOrGetControl("richtext", "title" .. status, 10, y)
                AUTO_CAST(title)
                local stat = frame:CreateOrGetControl("richtext", "stat" .. status, 165, y)
                AUTO_CAST(stat)

                if status == "STR" or status == "INT" or status == "CON" or status == "MNA" or status == "DEX" then
                    for i = 0, 4 do
                        local type_str = GetStatTypeStr(i);
                        if status == type_str then
                            title:SetText("{ol}{s16}" .. g.settings["color"][status] .. ClMsg(status))
                            local total_value = pc[type_str] + session.GetUserConfig(type_str .. "_UP");
                            local stat_text = string.gsub(tostring(total_value), ",", "")
                            stat:SetText(g.settings["color"][status] .. "{ol}{s16}: " .. stat_text)
                            if g.is_jp then
                                stat:SetPos(125, y)
                            end
                            break
                        end
                    end
                    y = y + 20
                else
                    local control_set = GET_CHILD_RECURSIVELY(box, status)

                    if control_set then -- 変更：control_setがnilの場合のエラーを避ける

                        local original_status = GET_CHILD_RECURSIVELY(control_set, "stat")
                        if status == "gear_score" then
                            title:SetText("{ol}{s16}" .. g.settings["color"][status] ..
                                              ScpArgMsg("EquipedItemGearScore"))
                            local text = string.gsub(original_status:GetText(), "{@sti8}", "")
                            text = string.gsub(text, ",", "")
                            stat:SetText(g.settings["color"][status] .. "{ol}{s16}: " .. text)
                        elseif status == "ability_point_score" then
                            title:SetText("{ol}{s16}" .. g.settings["color"][status] .. ScpArgMsg("AbilityPointScore"))
                            local text = string.gsub(original_status:GetText(), "{@sti8}", "")
                            text = string.gsub(text, ",", "")
                            stat:SetText(g.settings["color"][status] .. "{ol}{s16}: " .. text)
                        else
                            title:SetText("{ol}{s16}" .. g.settings["color"][status] .. ScpArgMsg(status))
                            local text = string.gsub(original_status:GetText(), "{#ff4040}", "")
                            text = string.gsub(text, "{#66b3ff}", "")
                            text = string.gsub(text, ",", "")
                            stat:SetText(g.settings["color"][status] .. "{ol}{s16}: " .. text)
                        end

                        if g.is_jp then
                            local text = string.gsub(title:GetText(), "{.-}", "")
                            title:SetText("{ol}{s16}" .. g.settings["color"][status] .. always_status_lang(text))
                            stat:SetPos(125, y)
                        end
                        y = y + 20
                        title:AdjustFontSizeByWidth(150)
                        if not g.is_jp then
                            stat:AdjustFontSizeByWidth(135)
                        end
                    end
                end
            end
        end

        if g.is_jp then
            frame:Resize(260, y + 10)
        else
            frame:Resize(310, y + 10)
        end
        frame:ShowWindow(1)
        frame:RunUpdateScript("always_status_update", 0.1);
    end
end

function always_status_update()
    local frame = ui.GetFrame(addon_name_lower)
    local statframe = ui.GetFrame("status")
    local box = GET_CHILD_RECURSIVELY(statframe, "internalstatusBox")
    local pc = GetMyPCObject();
    for _, status in ipairs(status_list) do
        local always_status_stat = GET_CHILD_RECURSIVELY(frame, "stat" .. status)
        if always_status_stat then -- 変更：nilチェックをシンプルに
            local control_set = GET_CHILD_RECURSIVELY(box, status)
            if control_set == nil then
                if status == "STR" or status == "INT" or status == "CON" or status == "MNA" or status == "DEX" then
                    local total_value = pc[status] + session.GetUserConfig(status .. "_UP");
                    always_status_stat:SetText(g.settings["color"][status] .. "{ol}{s16}: " .. total_value)
                end
            else
                local original_status = GET_CHILD_RECURSIVELY(control_set, "stat")
                if original_status then -- 変更：original_statusのnilチェックを追加
                    if status == "gear_score" then
                        local score = GET_PLAYER_GEAR_SCORE(pc)
                        always_status_stat:SetText(g.settings["color"][status] .. "{ol}{s16}: " .. score)
                    else
                        local text = original_status:GetText()
                        text = text:gsub("{.-}", ""):gsub(",", "")
                        always_status_stat:SetText(g.settings["color"][status] .. "{ol}{s16}: " .. text)
                    end
                end
            end
        end
    end
    return 1
end

function always_status_frame_move(frame)
    if g.settings.frame_X ~= frame:GetX() or g.settings.frame_Y ~= frame:GetY() then
        g.settings.frame_X = frame:GetX()
        g.settings.frame_Y = frame:GetY()
        always_status_save_settings()
    end
end

function always_status_lang(str)
    for key, value in pairs(str_table) do
        if tostring(key) == tostring(str) then
            return value
        end
    end
    return str
end

-- 変更：この2つの関数は、現在どこからも呼び出されていないデッドコードの可能性が高いわ
-- もし、他のファイルから呼び出していたら、このコメントアウトは外してちょうだいね！
--[[
function always_status_original_frame_sound_config()
    config.SetSoundVolume(g.settings.volume)
end

function always_status_CONFIG_SOUNDVOL(frame, msg)
    local frame, ctrl, str, num = acutil.getEventArgs(msg)
    AUTO_CAST(ctrl)
    local volume = tonumber(num)
    g.settings.volume = volume
    always_status_save_settings()
end
]]
