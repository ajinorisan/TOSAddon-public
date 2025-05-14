-- v1.0.1 skillnameがNoneの場合に表示バグってたの修正
-- v1.0.2 UI少し変更。CC時のカードやエンブレムの装備取り忘れ確認機能。
-- v1.0.3 読み込み早くしたつもり。自分では何も感じない。回線のせいか？
-- v1.0.4 3回目以降のCCはキャラクターリストを読み込まない様に変更
-- v1.0.5 書き直した。高速化したはず。
-- v1.0.6 instantcc使ってたら順番バグるの修正。フレーム開ける時に読み込みに変更。
-- v1.0.7 順番バグってたの再修正
-- v1.0.8 キャラの装備詳細見れる様にした。でも同一バラックじゃないと無理／(^o^)＼ 他の装備LVも可視化
-- v1.0.9 バグ修正
-- v1.1.0 高速化。ギアスコア表示。セーブデータは一旦消えます(´ω｀)
-- v1.1.1 セーブファイルの呼出修正
-- v1.1.2 新キャラ作った時に反映されなかったの修正
-- v1.1.3 キャラ削除した時に反映されなかったの修正。ロードを起動時のみに。セーブデータ持ち方修正。レイヤーの取り方修正
-- v1.1.4 バニラでセッティングバグってたの修正
local addon_name = "other_char_equips"
local author = "norisan"
local ver = "1.1.4"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addon_name] = _G["ADDONS"][author][addon_name] or {}
local g = _G["ADDONS"][author][addon_name]

local jatbl = {
    ["Common_Peltasta_HardShield"] = "ハードシールド",
    ["Common_Swordman_PainBarrier"] = "ペインバリア",
    ["Common_Peltasta_Guardian"] = "ガーディアン",
    ["Common_Cataphract_Trot"] = "トロット",
    ["Common_Murmillo_Sprint"] = "スプリント",
    ["Common_BlossomBlader_StartUp"] = "起手式",
    ["Common_Rancer_Commence"] = "コメンス",
    ["Common_Rancer_Prevent"] = "プリベント",
    ["Common_Highlander_Defiance"] = "ディファイアンス",
    ["Common_Barbarian_Frenzy"] = "フレンジー",
    ["Common_Retiarii_DaggerGuard"] = "ダガーガード",
    ["Common_Archer_Jump"] = "後方跳躍",
    ["Common_PiedPiper_Marschierendeslied"] = "マシュレデスリート",
    ["Common_PiedPiper_LiedDerWeltbaum"] = "リートデスベルトバウム",
    ["Common_Arquebusier_DesperateDefense"] = "デスパレートデフェンス",
    ["Common_Appraiser_HighMagnifyingGlass"] = "高倍率拡大鏡",
    ["Common_QuarrelShooter_DeployPavise"] = "デプロイパヴィス",
    ["Common_Wizard_Teleportation"] = "テレポーテーション",
    ["Common_Cryomancer_SubzeroShield"] = "ザブゼロシールド",
    ["Common_Chronomancer_Pass"] = "パス",
    ["Common_Chronomancer_QuickCast"] = "クイックキャスト",
    ["Common_Shadowmancer_ShadowPool"] = "シャドウプール",
    ["Common_Sage_MissileHole"] = "ミサイルホール",
    ["Common_Oracle_Foretell"] = "フォアテル",
    ["Common_PlagueDoctor_Modafinil"] = "モダフィニル",
    ["Common_Appraiser_Devaluation"] = "デバリュエーション",
    ["Common_RuneCaster_Algiz"] = "保護のルーン",
    ["Common_Priest_Aspersion"] = "アスパーション",
    ["Common_Druid_Lycanthropy"] = "ライカンスロピー",
    ["Common_Pardoner_IncreaseMagicDEF"] = "インクリースMDEF",
    ["Common_Paladin_StoneSkin"] = "ストーンスキン",
    ["Common_Inquisitor_Judgment"] = "ジャッジメント",
    ["Common_Kabbalist_Ayin_sof"] = "アインソフ",
    ["Common_Zealot_Invulnerable"] = "インバナーブル",
    ["Common_Zealot_BeadyEyed"] = "ビーディアイズ",
    ["Common_Assassin_Hasisas"] = "ハシサス",
    ["Common_OutLaw_Bully"] = "ブリー",
    ["Common_Thaumaturge_SwellBody"] = "スウェルボディ",
    ["Common_Thaumaturge_SwellHands"] = "スウェルハンズ",
    ["Common_Enchanter_EnchantGlove"] = "エンチャントグローブ",
    ["Common_Enchanter_EnchantEarth"] = "エンチャントアース",
    ["Common_Enchanter_EnchantLightning"] = "エンチャントウェポン",
    ["Common_Linker_Physicallink"] = "フィジカルリンク",
    ["Common_Linker_UmbilicalCord"] = "アンビリカルコード",
    ["Common_Rogue_Evasion"] = "イヴェイジョン",
    ["Common_Schwarzereiter_EvasiveAction"] = "エヴァシブアクション",
    ["Common_Sheriff_Redemption"] = "リデンプション",
    ["Common_Recovery"] = "リカバリー"

}
local entbl = {
    ["Common_Peltasta_HardShield"] = "HardShield",
    ["Common_Swordman_PainBarrier"] = "PainBarrier",
    ["Common_Peltasta_Guardian"] = "Guardian",
    ["Common_Cataphract_Trot"] = "Trot",
    ["Common_Murmillo_Sprint"] = "Sprint",
    ["Common_BlossomBlader_StartUp"] = "StartUp",
    ["Common_Rancer_Commence"] = "Commence",
    ["Common_Rancer_Prevent"] = "Prevent",
    ["Common_Highlander_Defiance"] = "Defiance",
    ["Common_Barbarian_Frenzy"] = "Frenzy",
    ["Common_Retiarii_DaggerGuard"] = "DaggerGuard",
    ["Common_Archer_Jump"] = "Jump",
    ["Common_PiedPiper_Marschierendeslied"] = "Marschierendeslied",
    ["Common_PiedPiper_LiedDerWeltbaum"] = "LiedDerWeltbaum",
    ["Common_Arquebusier_DesperateDefense"] = "DesperateDefense",
    ["Common_Appraiser_HighMagnifyingGlass"] = "HighMagnifyingGlass",
    ["Common_QuarrelShooter_DeployPavise"] = "DeployPavise",
    ["Common_Wizard_Teleportation"] = "Teleportation",
    ["Common_Cryomancer_SubzeroShield"] = "SubzeroShield",
    ["Common_Chronomancer_Pass"] = "Pass",
    ["Common_Chronomancer_QuickCast"] = "QuickCast",
    ["Common_Shadowmancer_ShadowPool"] = "ShadowPool",
    ["Common_Sage_MissileHole"] = "MissileHole",
    ["Common_Oracle_Foretell"] = "Foretell",
    ["Common_PlagueDoctor_Modafinil"] = "Modafinil",
    ["Common_Appraiser_Devaluation"] = "Devaluation",
    ["Common_RuneCaster_Algiz"] = "Algiz",
    ["Common_Priest_Aspersion"] = "Aspersion",
    ["Common_Druid_Lycanthropy"] = "Lycanthropy",
    ["Common_Pardoner_IncreaseMagicDEF"] = "IncreaseMagicDEF",
    ["Common_Paladin_StoneSkin"] = "StoneSkin",
    ["Common_Inquisitor_Judgment"] = "Judgment",
    ["Common_Kabbalist_Ayin_sof"] = "Ayin_sof",
    ["Common_Zealot_Invulnerable"] = "Invulnerable",
    ["Common_Zealot_BeadyEyed"] = "BeadyEyed",
    ["Common_Assassin_Hasisas"] = "Hasisas",
    ["Common_OutLaw_Bully"] = "Bully",
    ["Common_Thaumaturge_SwellBody"] = "SwellBody",
    ["Common_Thaumaturge_SwellHands"] = "SwellHands",
    ["Common_Enchanter_EnchantGlove"] = "EnchantGlove",
    ["Common_Enchanter_EnchantEarth"] = "EnchantEarth",
    ["Common_Enchanter_EnchantLightning"] = "EnchantLightning",
    ["Common_Linker_Physicallink"] = "Physicallink",
    ["Common_Linker_UmbilicalCord"] = "UmbilicalCord",
    ["Common_Rogue_Evasion"] = "Evasion",
    ["Common_Schwarzereiter_EvasiveAction"] = "EvasiveAction",
    ["Common_Sheriff_Redemption"] = "Redemption",
    ["Common_Recovery"] = "Recovery"

}

local json = require('json')

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

    local addon_folder = string.format("../addons/%s", addon_name)
    local addon_mkdir_file = string.format("../addons/%s/mkdir.txt", addon_name)
    create_folder(addon_folder, addon_mkdir_file)

    g.active_id = session.loginInfo.GetAID()

    local user_folder = string.format("../addons/%s/%s", addon_name, g.active_id)
    local user_mkdir_file = string.format("../addons/%s/%s/mkdir.txt", addon_name, g.active_id)
    create_folder(user_folder, user_mkdir_file)

    g.settings_path = string.format("../addons/%s/%s/settings.json", addon_name, g.active_id)

end
g.mkdir_new_folder()

function g.get_map_type()
    local map_name = session.GetMapName()
    local map_cls = GetClass("Map", map_name)
    local map_type = map_cls.MapType
    return map_type
end

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

    if not g.RAGISTER[origin_func_name] then -- g.RAGISTERはON_INIT内で都度初期化
        g.RAGISTER[origin_func_name] = true
        my_addon:RegisterMsg(origin_func_name, my_func_name)
    end
end

function g.log_to_file(message)

    local file_path = string.format("../addons/%s/log.txt", addon_name)
    local file = io.open(file_path, "a")

    if file then
        local timestamp = os.date("[%Y-%m-%d %H:%M:%S] ")
        file:write(timestamp .. tostring(message) .. "\n")
        file:close()
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

function g.load_json(path)

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

function other_char_equips_BARRACK_TO_GAME(...)

    local bc_frame = ui.GetFrame("barrack_charlist")
    if bc_frame then
        g.layer = tonumber(bc_frame:GetUserValue("SelectBarrackLayer"))
        _G["norisan"] = _G["norisan"] or {}
        _G["norisan"]["LAST_LAYER"] = tonumber(bc_frame:GetUserValue("SelectBarrackLayer"))
    end

    local original_func = g.FUNCS["BARRACK_TO_GAME"]
    local result

    if original_func then
        original_func(...)
    end

    return result
end

function other_char_equips_BARRACK_TO_GAME_hook()
    local origin_func_name = "BARRACK_TO_GAME"
    if _G[origin_func_name] then
        if not g.FUNCS[origin_func_name] then
            g.FUNCS[origin_func_name] = _G[origin_func_name]
        end
        _G[origin_func_name] = other_char_equips_BARRACK_TO_GAME
    end
end

g.first = true
function OTHER_CHAR_EQUIPS_ON_INIT(addon, frame)
    local start_time = os.clock() -- ★処理開始前の時刻を記録★
    g.addon = addon
    g.frame = frame

    g.name = session.GetMySession():GetPCApc():GetName()
    g.cid = session.GetMySession():GetCID()

    g.layer = g.layer or _G["norisan"]["LAST_LAYER"] or 1

    g.RAGISTER = {}

    _G["norisan"] = _G["norisan"] or {}
    _G["norisan"]["HOOKS"] = _G["norisan"]["HOOKS"] or {}
    if not _G["norisan"]["HOOKS"]["BARRACK_TO_GAME"] then
        _G["norisan"]["HOOKS"]["BARRACK_TO_GAME"] = addon_name
        addon:RegisterMsg("GAME_START", "other_char_equips_BARRACK_TO_GAME_hook")
    end

    -- 初回ログイン時はバラックPCカウント取れないのでreturn
    if g.first then
        g.first = false
        return
    end

    if g.get_map_type() == "City" then
        if not g.settings then
            addon:RegisterMsg("GAME_START", "other_char_equips_load_settings")
        else
            if not g.settings[g.name] then
                addon:RegisterMsg("GAME_START", "other_char_equips_load_settings")
            end
        end

        g.setup_hook_and_event(addon, "INVENTORY_OPEN", "other_char_equips_INVENTORY_OPEN", true)
        g.setup_hook_and_event(addon, "INVENTORY_CLOSE", "other_char_equips_INVENTORY_CLOSE", true)
        addon:RegisterMsg("GAME_START_3SEC", "other_char_equips_frame_init")
    end
    local end_time = os.clock()
    local elapsed_time = end_time - start_time
    -- CHAT_SYSTEM(string.format("other_char_equips_ON_INIT: %.4f seconds", elapsed_time))
end

local equips = {"SHIRT", "PANTS", "GLOVES", "BOOTS", "LEG", "GOD", "SEAL", "ARK", "RELIC", "RH", "LH", "RH_SUB",
                "LH_SUB", "RING1", "RING2", "NECK"}

function other_char_equips_load_settings()

    local settings = g.load_json(g.settings_path)

    local account_info = session.barrack.GetMyAccount()
    local all_pc_count = account_info:GetBarrackPCCount()

    if not settings then

        settings = {
            characters = {}
        }

        for i = 0, all_pc_count - 1 do
            local barrack_pc_info = account_info:GetBarrackPCByIndex(i)
            local barrack_pc_name = barrack_pc_info:GetName()

            settings.characters[barrack_pc_name] = {
                index = i,
                layer = 9,
                gear_score = 0,
                cid = "",
                equips = {}
            }
            for i, key in ipairs(equips) do
                if i <= 4 then
                    settings.character[barrack_pc_name].equips[key] = {
                        clsid = 0,
                        lv = 0,
                        skill_name = "",
                        skill_lv = 0
                    }
                else
                    settings.character[barrack_pc_name].equips[key] = {
                        clsid = 0,
                        lv = 0
                    }
                end
            end

        end
    end

    local temp_name = {}
    for i = 0, all_pc_count - 1 do
        local barrack_pc_info = account_info:GetBarrackPCByIndex(i)
        local barrack_pc_name = barrack_pc_info:GetName()
        if barrack_pc_name then
            table.insert(temp_name, barrack_pc_name)
        end
    end

    local keys_to_delete = {}
    for character_name, char_data in pairs(settings.characters) do
        local found_in_barrack = false

        for _, barrack_name in ipairs(temp_name) do
            if character_name == barrack_name then
                found_in_barrack = true
                break
            end
        end

        if not found_in_barrack then
            table.insert(keys_to_delete, character_name)
        end
    end

    for _, key_to_remove in ipairs(keys_to_delete) do
        settings.characters[key_to_remove] = nil
    end

    g.settings = settings
    g.save_settings()
end

function other_char_equips_sort()

    local function sort_layer_order(a, b)
        if a.layer ~= b.layer then
            return a.layer < b.layer
        else
            return a.index < b.index
        end
    end

    local char_list = {}
    for name, char_data in pairs(g.settings.characters) do
        local cid = char_data[name].cid
        if cid ~= "" then
            table.insert(char_list, char_data)
        end
    end

    table.sort(char_list, sort_layer_order)
    g.characters = char_list
end

function other_char_equips_tableset()

    local account_info = session.barrack.GetMyAccount()
    local same_count = account_info:GetPCCount()

    for i = 0, same_count - 1 do

        local pc_info = account_info:GetPCByIndex(i)
        local active_pc = pc_info:GetApc()
        local pc_name = active_pc:GetName()
        local pc_cid = pc_info:GetCID()

        for name, charData in pairs(g.settings.characters) do

            if name == pc_name then
                g.settings.character[name].cid = pc_cid
                g.settings.character[name].index = i
                if g.layer and g.layer ~= g.settings.character[name].layer then
                    g.settings.character[name].layer = g.layer
                end
            end
        end
    end
    g.save_settings()
    other_char_equips_sort()
end

function other_char_equips_frame_init()
    local frame = ui.GetFrame(addon_name)
    frame:SetSkinName("None")
    frame:SetTitleBarSkin("None")
    frame:Resize(35, 35)
    frame:SetPos(715, 0)

    frame:ShowWindow(1)

    local btn = frame:CreateOrGetControl('button', 'btn', 0, 0, 35, 35)
    AUTO_CAST(btn)
    btn:SetSkinName("None")
    btn:SetText("{img sysmenu_friend 35 35}")

    btn:SetEventScript(ui.LBUTTONDOWN, "other_char_equips_frame_open")
    btn:SetTextTooltip("{ol}[Other Char Equips]")
    other_char_equips_tableset()
end

function other_char_equips_save_enchant()

    local inventory = ui.GetFrame("inventory")
    local pc_name = session.GetMySession():GetPCApc():GetName()
    local equip_item_list = session.GetEquipItemList()
    local count = equip_item_list:Count()
    local cid = session.GetMySession():GetCID()

    local data = g.settings.character[pc_name].equips

    local score = 0
    for i = 0, count - 1 do
        local equip_item = equip_item_list:GetEquipItemByIndex(i)
        local spot_name = item.GetEquipSpotName(equip_item.equipSpot)
        local spot_item = session.GetEquipItemBySpot(item.GetEquipSpotNum(spot_name))
        local obj = GetIES(spot_item:GetObject())
        if obj.ClassName ~= "NoRing" then
            score = GET_GEAR_SCORE(obj) + score
        end

        local lv = TryGetProp(obj, "Reinforce_2", 0)

        if spot_name == "SHIRT" or spot_name == "PANTS" or spot_name == "GLOVES" or spot_name == "BOOTS" then
            local slot = GET_CHILD_RECURSIVELY(inventory, spot_name)
            local icon = slot:GetIcon()

            if icon then
                local name, skill_lv = shared_skill_enchant.get_enchanted_skill(obj, 1)
                data[spot_name] = {
                    clsid = obj.ClassID,
                    lv = lv,
                    skill_name = name,
                    skill_Lv = skill_lv
                }
            else
                data[spot_name] = {}
            end
        elseif spot_name == "RH" or spot_name == "LH" or spot_name == "RH_SUB" or spot_name == "LH_SUB" or spot_name ==
            "RING1" or spot_name == "RING2" or spot_name == "NECK" then
            local slot = GET_CHILD_RECURSIVELY(inventory, spot_name)
            local icon = slot:GetIcon()

            if icon then

                data[spot_name] = {
                    clsid = obj.ClassID,
                    lv = lv
                }
            else
                data[spot_name] = {}
            end

        elseif spot_name == "SEAL" or spot_name == "ARK" or spot_name == "RELIC" then
            local slot = GET_CHILD_RECURSIVELY(inventory, spot_name)
            local icon = slot:GetIcon()

            if spot_name == "SEAL" then
                lv = GET_CURRENT_SEAL_LEVEL(obj)
            elseif spot_name == "ARK" then
                lv = TryGetProp(obj, 'ArkLevel', 1)
            elseif spot_name == "RELIC" then
                lv = TryGetProp(obj, 'Relic_LV', 1)
            end
            if icon then
                data[spot_name] = {
                    clsid = obj.ClassID,
                    lv = lv

                }
            else
                data[spot_name] = {}
            end
        end
    end

    local info = equipcard.GetCardInfo(13)
    if info then
        data["LEG"].clsid = info:GetCardID()
        data["LEG"].lv = info.cardLv
    else
        data["LEG"] = {}
    end

    local info = equipcard.GetCardInfo(14)
    if info then
        data["GOD"].clsid = info:GetCardID()
        data["GOD"].lv = info.cardLv
    else
        data["GOD"] = {}
    end
    g.settings.character[pc_name].gear_score = score

    g.save_settings()
end

function other_char_equips_INVENTORY_OPEN()
    local newframe = ui.GetFrame(addon_name .. "new_frame")
    newframe:ShowWindow(0)
    other_char_equips_save_enchant()
end

function other_char_equips_INVENTORY_CLOSE()
    other_char_equips_save_enchant()
end

function other_char_equips_save_settings()

    acutil.saveJSON(g.settings_path, g.settings)
end

function other_char_equips_char_report_close(frame, ctrl, str, num)

    local parent = frame:GetParent()
    parent = parent:GetParent()

    parent:ShowWindow(0)

    other_char_equips_frame_open()
end

function other_char_equips_char_report(frame, ctrl, char_name_str, num)

    local cid = g.settings.characters[char_name_str].cid
    local current_cid = frame:GetUserValue("CID")

    if current_cid ~= "None" and current_cid ~= cid then
        DESTROY_CHILD_BYNAME(frame, "char_" .. current_cid)
    else
        local char_frame = GET_CHILD_RECURSIVELY(frame, "char_" .. current_cid)
        if char_frame then
            char_frame:ShowWindow(1)
        end
    end

    local bpc_info = barrack.GetBarrackPCInfoByCID(cid)

    if not bpc_info then
        local language = option.GetCurrentCountry()
        ui.SysMsg(language == "Japanese" and
                      "{ol}詳細表示は、ログイン中のキャラと同一バラックのキャラのみ対応しています (´;ω;｀))" or
                      "{ol}Detailed view is supported only for characters in the same barracks as the currently logged-in character.")
        other_char_equips_frame_open()
        return
    end

    local char_ctrl = frame:CreateOrGetControlSet('barrack_charlist', 'char_' .. cid, 150, 10)
    AUTO_CAST(char_ctrl)
    frame:SetUserValue("CID", cid)
    local main_box = GET_CHILD(char_ctrl, 'mainBox', 'ui::CGroupBox')
    local btn = main_box:GetChild("btn")
    btn:SetSkinName('character_off')
    btn:SetSValue(char_name_str)
    btn:SetOverSound('button_over')
    btn:SetClickSound('button_click_2')

    local indun_btn = main_box:GetChild("indunBtn")
    AUTO_CAST(indun_btn)

    indun_btn:SetImage("testclose_button")
    indun_btn:SetEventScript(ui.LBUTTONUP, "other_char_equips_char_report_close")

    btn:ShowWindow(1)
    local apc = bpc_info:GetApc()

    local gender = apc:GetGender()
    local job_id = apc:GetJob()
    local level = apc:GetLv()
    local pic = GET_CHILD(main_box, "char_icon", "ui::CPicture")
    local head_icon = ui.CaptureModelHeadImageByApperance(apc)
    pic:SetImage(head_icon)

    local name_label = GET_CHILD(main_box, "name", "ui::CRichText")
    name_label:SetText("{@st42b}{b}" .. char_name_str)

    local barrack_pc = session.barrack.GetMyAccount():GetByStrCID(cid)
    if barrack_pc ~= nil and barrack_pc:GetRepID() ~= 0 then
        job_id = barrack_pc:GetRepID()
    end

    local job_cls = GetClassByType("Job", job_id)
    local job_label = GET_CHILD(main_box, "job", "ui::CRichText")
    job_label:SetText("{@st42b}" .. GET_JOB_NAME(job_cls, gender))
    local level_label = GET_CHILD(main_box, "level", "ui::CRichText")
    level_label:SetText("{@st42b}Lv." .. level)

    local detail_box = GET_CHILD(char_ctrl, 'detailBox', 'ui::CGroupBox')
    local rh_sub_slot = detail_box:CreateOrGetControl("slot", "RH_SUB", 138, 214, 55, 55)
    local lh_sub_slot = detail_box:CreateOrGetControl("slot", "LH_SUB", 198, 214, 55, 55)
    local map_label = GET_CHILD(detail_box, 'mapName', 'ui::CRichText')

    local map_cls = GetClassByType("Map", apc.mapID)
    if map_cls ~= nil then
        local map_name = map_cls.Name
        map_label:SetText("{@st66b}" .. map_name)
    end

    local spot_count = item.GetEquipSpotCount() - 1

    local skin_list = {}
    for i = 0, spot_count do
        local equip_obj = bpc_info:GetEquipObj(i)
        local spot_name = item.GetEquipSpotName(i)

        if equip_obj then
            local ies_obj = GetIES(equip_obj)
            local equip_type = TryGet_Str(ies_obj, "EqpType")
            if equip_type == "HELMET" then
                if item.IsNoneItem(ies_obj.ClassID) == 0 then
                    spot_name = "HAIR"
                end
            end

            if spot_name == "TRINKET" and item.IsNoneItem(ies_obj.ClassID) == 0 then
                spot_name = "LH"
            end
        end

        local slot_ctrl = GET_CHILD(detail_box, spot_name, "ui::CSlot")

        if slot_ctrl then
            if slot_ctrl:GetName() == "SHIRT" then
                slot_ctrl:SetMargin(-120, 150, 0, 0)
            elseif slot_ctrl:GetName() == "PANTS" then
                slot_ctrl:SetMargin(-60, 150, 0, 0)
            elseif slot_ctrl:GetName() == "GLOVES" then
                slot_ctrl:SetMargin(0, 150, 0, 0)
            elseif slot_ctrl:GetName() == "BOOTS" then
                slot_ctrl:SetMargin(60, 150, 0, 0)
            elseif slot_ctrl:GetName() == "RH" then
                slot_ctrl:SetMargin(-120, 214, 0, 0)
            elseif slot_ctrl:GetName() == "LH" then
                slot_ctrl:SetMargin(-60, 214, 0, 0)
            elseif slot_ctrl:GetName() == "ARK" then
                slot_ctrl:SetMargin(120, 150, 0, 0)
            elseif slot_ctrl:GetName() == "RELIC" then
                slot_ctrl:SetMargin(120, 214, 0, 0)
            end
            if skin_list[spot_name] == nil then
                skin_list[spot_name] = slot_ctrl:GetSkinName()
            end

            slot_ctrl:EnableDrag(0)
            if not equip_obj then
                CLEAR_SLOT_ITEM_INFO(slot_ctrl)
            else
                local ies_item = GetIES(equip_obj)

                local refresh_scp = ies_item.RefreshScp
                if refresh_scp ~= "None" then
                    local scp_func = _G[refresh_scp]
                    scp_func(ies_item)
                end

                if 0 == item.IsNoneItem(ies_item.ClassID) then
                    CLEAR_SLOT_ITEM_INFO(slot_ctrl)
                    SET_SLOT_ITEM_OBJ(slot_ctrl, ies_item, gender, 1)
                else
                    local current_skin = skin_list[spot_name]
                    if current_skin ~= nil then
                        slot_ctrl:SetSkinName(current_skin)
                    end
                    SET_SLOT_TRANSCEND_LEVEL(slot_ctrl, 0)
                    SET_SLOT_REINFORCE_LEVEL(slot_ctrl, 0)
                    CLEAR_SLOT_ITEM_INFO(slot_ctrl)
                end
            end
        end
    end
    char_ctrl:Resize(400, 430)
    local top_frame = frame:GetTopParentFrame()
    if top_frame:GetHeight() < 490 then
        top_frame:Resize(top_frame:GetWidth(), 540 - 60)
        local gbox = GET_CHILD(top_frame, "gbox")
        gbox:Resize(gbox:GetWidth(), top_frame:GetHeight() - 40)
    end
end

function other_char_equips_frame_open(frame, ctrl, str, num) -- 関数名はそのまま

    local main_frame = ui.CreateNewFrame("notice_on_pc", addon_name .. "new_frame", 0, 0, 70, 30)
    AUTO_CAST(main_frame)

    main_frame:SetSkinName("test_frame_midle")
    main_frame:SetLayerLevel(103)

    local title_box = main_frame:CreateOrGetControl("groupbox", "title", 0, 0, 1070, 40)
    AUTO_CAST(title_box)
    title_box:SetSkinName("None")

    local close_btn = title_box:CreateOrGetControl("button", "close", 0, 0, 20, 20)
    AUTO_CAST(close_btn)
    close_btn:SetImage("testclose_button")
    close_btn:SetGravity(ui.LEFT, ui.TOP)
    close_btn:SetEventScript(ui.LBUTTONUP, "other_char_equips_frame_close")

    local help_btn = title_box:CreateOrGetControl('button', "help", 40, 0, 35, 35)
    AUTO_CAST(help_btn)
    help_btn:SetText("{ol}{img question_mark 20 20}")
    help_btn:SetSkinName("test_pvp_btn")

    local current_lang = option.GetCurrentCountry()
    help_btn:SetTextTooltip(current_lang == "Japanese" and
                                "{ol}順番に並ばない場合は一度バラックに戻ってバラック1､2､3毎にログインしてください。{nl}" ..
                                "InstantCCアドオンを使用している場合は「Return To Barrack」で戻ってください。{nl} {nl}" ..
                                "{ol}名前部分を押すと、ログインキャラと同一バラックの各キャラの装備詳細が見れます。" or
                                "{ol}If you do not line up in order,{nl}" ..
                                "please return to the barracks once and log in for each barracks 1,2,3.{nl}" ..
                                "If you are using the InstantCC add-on, please return with [Return To Barrack].{nl} {nl}" ..
                                "{ol}Press the name section to see the equipment details of each character{nl}in the same barrack as the login character.")

    local weapon_lbl = title_box:CreateOrGetControl("richtext", "weapon", 160, 10, 100, 20)
    weapon_lbl:SetText(current_lang == "Japanese" and "{ol}" .. "武器" or "{ol}" .. "weapons")
    weapon_lbl:AdjustFontSizeByWidth(100)

    local acc_lbl = title_box:CreateOrGetControl("richtext", "Accessory", 280, 10, 100, 20)
    acc_lbl:SetText(current_lang == "Japanese" and "{ol}" .. "アクセ" or "{ol}" .. "Accessory")

    local equip_x = 370
    for i = 0, 4 do
        local equip_lbl = title_box:CreateOrGetControl("richtext", "equip_text" .. i, equip_x, 10, 100, 20) -- equip_text を eq_text_lbl に

        if i == 0 then
            equip_lbl:SetText("{ol}" .. ClMsg("Shirt"))
        elseif i == 1 then
            equip_lbl:SetText("{ol}" .. ClMsg("Pants"))
        elseif i == 2 then
            equip_lbl:SetText("{ol}" .. ClMsg("GLOVES"))
        elseif i == 3 then
            equip_lbl:SetText("{ol}" .. ClMsg("BOOTS"))
        elseif i == 4 then
            equip_lbl:SetText(current_lang == "Japanese" and "{ol}その他" or "{ol}etc.")
        end

        equip_lbl:AdjustFontSizeByWidth(100)

        equip_x = equip_x + 225
    end

    local main_gbox = main_frame:CreateOrGetControl("groupbox", "gbox", 5, 35, 1070, 280)
    AUTO_CAST(main_gbox)
    main_gbox:RemoveAllChild()
    main_gbox:SetSkinName("test_frame_midle_light")

    local trans_tbl = current_lang == "Japanese" and jatbl or entbl
    local all_skills = GetClassList("Skill")

    local y_pos = 10
    local equip_grp_x = 370
    local etc_x_offset = 0

    local char_count = 0
    for i, char_info in ipairs(g.characters) do

        local char_settings = g.settings.characters[char_info.name]
        local char_equips = char_settings.equips
        local gear_score = char_settings.gear_score

        local name_lbl = main_gbox:CreateOrGetControl("richtext", "name_text" .. i, 10, y_pos, 145, 20)
        AUTO_CAST(name_lbl)
        name_lbl:SetText("{ol}" .. char_info.name)
        name_lbl:AdjustFontSizeByWidth(150)
        name_lbl:SetEventScript(ui.LBUTTONUP, "other_char_equips_char_report")
        name_lbl:SetEventScriptArgString(ui.LBUTTONUP, char_info.name)
        local gs_str = gear_score ~= 0 and tostring(gear_score) or "NoData" -- tostring 追加

        name_lbl:SetTextTooltip(current_lang == "Japanese" and "{ol}GearScore: " .. gs_str .. "{nl} {nl}" ..
                                    "名前部分を押すと各キャラの装備詳細が見れます。" or
                                    "{ol}GearScore: " .. gs_str .. "{nl} {nl}" ..
                                    "Press the name part to see the{nl}equipment details of each character.")

        for j, equip_type in ipairs(equips) do

            local equip_data_entry = char_equips[equip_type]

            if j <= 4 then
                local skill_slot = main_gbox:CreateOrGetControl("slot", "slot" .. equip_type .. i,
                                                                equip_grp_x + (225 * (j - 1)) + 30, y_pos, 25, 24)
                AUTO_CAST(skill_slot)
                skill_slot:EnablePop(0);
                skill_slot:EnableDrop(0);
                skill_slot:EnableDrag(0);
                skill_slot:SetSkinName('invenslot2')

                local item_slot = main_gbox:CreateOrGetControl("slot", "equip" .. equip_type .. i,
                                                               equip_grp_x + (225 * (j - 1)), y_pos, 25, 24)
                AUTO_CAST(item_slot)
                item_slot:EnablePop(0);
                item_slot:EnableDrop(0);
                item_slot:EnableDrag(0);
                item_slot:SetSkinName('invenslot2')

                local clsid = equip_data_entry.clsid
                local item_cls = GetClassByType("Item", clsid)
                if item_cls then
                    local lv = equip_data_entry.lv

                    local image_name = item_cls.Icon
                    SET_SLOT_ICON(item_slot, image_name)

                    SET_SLOT_BG_BY_ITEMGRADE(item_slot, item_cls)
                    item_slot:SetText('{s12}{ol}{#FFFF00}+' .. lv, 'count', ui.RIGHT, ui.BOTTOM, 0, 0)
                    local icon = item_slot:GetIcon()
                    if icon then
                        icon:SetTextTooltip(item_cls.Name)
                    end
                end

                local skill = GetClassByNameFromList(all_skills, equip_data_entry.skill_name)

                if skill then
                    local skill_icon_name = 'icon_' .. skill.Icon
                    SET_SLOT_ICON(skill_slot, skill_icon_name)

                    local skill_name_lbl = main_gbox:CreateOrGetControl("richtext", "skill_name" .. equip_type .. i,
                                                                        equip_grp_x + 60 + (225 * (j - 1)), y_pos, 140,
                                                                        20) -- skill_name を skill_name_lbl に

                    skill_slot:SetText('{s14}{ol}{#FFFF00}' .. equip_data_entry.skill_lv, 'count', ui.RIGHT, ui.BOTTOM,
                                       -2, -2)

                    local icon = skill_slot:GetIcon()
                    if icon then
                        icon:SetTooltipType('skill')
                        icon:SetTooltipArg("Level", skill.ClassID, equip_data_entry.skill_lv)
                    end

                    for k, v in pairs(trans_tbl) do
                        if tostring(k) == tostring(equip_data_entry.skill_name) then
                            skill_name_lbl:SetText("{ol}{s16}" .. v)
                            skill_name_lbl:AdjustFontSizeByWidth(160)
                        end
                    end
                end
            elseif j >= 5 and j <= 9 then
                local etc_slot = main_gbox:CreateOrGetControl("slot", "etc_slot" .. equip_type .. i,
                                                              equip_grp_x + 225 * 4 + etc_x_offset, y_pos, 25, 24)
                AUTO_CAST(etc_slot)
                etc_slot:EnablePop(0);
                etc_slot:EnableDrop(0);
                etc_slot:EnableDrag(0);
                etc_slot:SetSkinName('invenslot2')

                local text_prefix = (j >= 5 and j <= 6) and "{s12}{ol}{#FFFF00}{img mon_legendstar 10 10}{nl}" or
                                        "{s12}{ol}{#FFFF00}+"
                local item_cls = GetClassByType("Item", equip_data_entry.clsid)
                if item_cls then
                    local image_name = item_cls.Icon
                    SET_SLOT_ICON(etc_slot, image_name)
                    local icon = etc_slot:GetIcon()
                    if icon then
                        icon:SetTextTooltip(item_cls.Name)
                    end
                    etc_slot:SetText(text_prefix .. equip_data_entry.lv, 'count', ui.RIGHT, ui.BOTTOM, 0, 0)
                end
                etc_x_offset = etc_x_offset + 30
            elseif j >= 10 then
                local weapon_slot_x = 155 + 30 * (j - 10)
                local weapon_slot = main_gbox:CreateOrGetControl("slot", "slot" .. equip_type .. i, weapon_slot_x,
                                                                 y_pos, 25, 24)
                AUTO_CAST(weapon_slot)
                weapon_slot:EnablePop(0);
                weapon_slot:EnableDrop(0);
                weapon_slot:EnableDrag(0);
                weapon_slot:SetSkinName('invenslot2')

                local clsid = equip_data_entry.clsid

                if clsid and clsid ~= 0 then
                    local lv = equip_data_entry.lv
                    local item_cls = GetClassByType("Item", clsid)
                    local image_name = item_cls.Icon
                    SET_SLOT_ICON(weapon_slot, image_name)

                    SET_SLOT_BG_BY_ITEMGRADE(weapon_slot, item_cls)
                    weapon_slot:SetText('{s12}{ol}{#FFFF00}+' .. lv, 'count', ui.RIGHT, ui.BOTTOM, 0, 0)
                    local icon = weapon_slot:GetIcon()
                    if icon then
                        icon:SetTextTooltip(item_cls.Name)
                    end
                end
            end
        end

        etc_x_offset = 0
        y_pos = y_pos + 25
        char_count = char_count + 1
    end

    local frame_height = char_count * 25
    main_frame:Resize(1435, frame_height + 60)
    title_box:Resize(1425, 40)
    main_gbox:Resize(1425, frame_height + 20)

    local current_frame_w = main_frame:GetWidth()
    local map_frame = ui.GetFrame("map")

    local map_width = map_frame:GetWidth()
    main_frame:SetPos((map_width - current_frame_w) / 2, 0)

    main_frame:ShowWindow(1)
end

function other_char_equips_frame_close(frame, ctrl, str, num)
    local frame = ui.GetFrame(addon_name .. "new_frame")
    frame:ShowWindow(0)

end
