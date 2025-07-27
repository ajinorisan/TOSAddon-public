-- v1.0.1 skillnameがNoneの場合に表示バグってたの修正
-- v1.0.2 UI少し変更。CC時のカードやエンブレムの装備取り忘れ確認機能。
-- v1.0.3 読み込み早くしたつもり。自分では何も感じない。回線のせいか？
-- v1.0.4 3回目以降のCCはキャラクターリストを読み込まない様に変更
-- v1.0.5 書き直した。高速化したはず。
-- v1.0.6 instantcc使ってたら順番バグるの修正。フレーム開ける時に読み込みに変更。
-- v1.0.7 順番バグってたの再修正
-- v1.0.8 キャラの装備詳細見れる様にした。でも同一バラックじゃないと無理／(^o^)＼ 他の装備LVも可視化
-- v1.0.9 バグ修正
-- v1.1.0 高速化。ギアスコア表示。セーブデータは一旦消えます(´;ω;｀)
-- v1.1.1 セーブファイルの呼出修正
-- v1.1.2 新キャラ作った時に反映されなかったの修正
-- v1.1.3 キャラ削除した時に反映されなかったの修正。ロードを起動時のみに。セーブデータ持ち方修正。レイヤーの取り方修正
-- v1.1.4 バニラでセッティングバグってたの修正
-- v1.1.5 バグで色々どうしようもなくなったので仕切り直し。セーブファイル消えます。アドオンメニューに参加
-- v1.1.6 アドオンメニュー回り修正。
-- V1.1.7 バラックに戻るところバグってたの修正
-- v1.1.8 ICCと連携
-- v1.1.9 新キャラ登録出来なかったの修正。イアリング表示
local addon_name = "OTHER_CHARACTER_SKILL_LIST"
local addon_name_lower = string.lower(addon_name)
local author = "norisan"
local ver = "1.1.8"

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

    local addon_folder = string.format("../addons/%s", addon_name_lower)
    local addon_mkdir_file = string.format("../addons/%s/mkdir.txt", addon_name_lower)
    create_folder(addon_folder, addon_mkdir_file)

    g.active_id = session.loginInfo.GetAID()

    local user_folder = string.format("../addons/%s/%s", addon_name_lower, g.active_id)
    local user_mkdir_file = string.format("../addons/%s/%s/mkdir.txt", addon_name_lower, g.active_id)
    create_folder(user_folder, user_mkdir_file)

    g.settings_path = string.format("../addons/%s/%s/_2505_settings.json", addon_name_lower, g.active_id)

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

        if original_results then
            return table.unpack(original_results)
        else
            return
        end
    end

    _G[origin_func_name] = hooked_function

    if not g.REGISTER[origin_func_name .. my_func_name] then -- g.REGISTERはON_INIT内で都度初期化
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

function g.log_to_file(message)

    local file_path = string.format("../addons/%s/log.txt", addon_name_lower)
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

function other_character_skill_list_BARRACK_TO_GAME(...)

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

function other_character_skill_list_BARRACK_TO_GAME_hook()
    g.FUNCS = g.FUNCS or {}
    local origin_func_name = "BARRACK_TO_GAME"
    if _G[origin_func_name] then
        if not g.FUNCS[origin_func_name] then
            g.FUNCS[origin_func_name] = _G[origin_func_name]
        end
        _G[origin_func_name] = other_character_skill_list_BARRACK_TO_GAME
    end
end

function OTHER_CHARACTER_SKILL_LIST_ON_INIT(addon, frame)
    local start_time = os.clock() -- ★処理開始前の時刻を記録★
    g.addon = addon
    g.frame = frame

    g.name = session.GetMySession():GetPCApc():GetName()
    g.cid = session.GetMySession():GetCID()

    g.REGISTER = {}

    _G["norisan"] = _G["norisan"] or {}
    _G["norisan"]["HOOKS"] = _G["norisan"]["HOOKS"] or {}
    if not _G["norisan"]["HOOKS"]["BARRACK_TO_GAME"] then
        _G["norisan"]["HOOKS"]["BARRACK_TO_GAME"] = addon_name
        addon:RegisterMsg("GAME_START", "other_character_skill_list_BARRACK_TO_GAME_hook")
    end

    g.layer = _G["norisan"]["LAST_LAYER"] or g.layer or 1

    local menu_data = {
        name = "Other Character Skill List ",
        icon = "sysmenu_friend",
        func = "other_character_skill_list_frame_open",
        image = ""
    }
    if g.get_map_type() == "City" then
        _G["norisan"]["MENU"][addon_name] = menu_data
    else
        _G["norisan"]["MENU"][addon_name] = nil
    end
    if not _G["norisan"]["MENU"][addon_name_lower] or _G["norisan"]["MENU"].frame_name == addon_name_lower then
        _G["norisan"]["MENU"].frame_name = addon_name_lower
        addon:RegisterMsg("GAME_START", "norisan_menu_create_frame")
    end
    -- print(tostring(g.loaded))
    if not g.loaded then
        other_character_skill_list_load_settings()
    end

    if g.get_map_type() == "City" then

        addon:RegisterMsg("GAME_START_3SEC", "other_character_skill_list_save_enchant")
        g.setup_hook_and_event(addon, "INVENTORY_OPEN", "other_character_skill_list_INVENTORY_OPEN", true)
        g.setup_hook_and_event(addon, "INVENTORY_CLOSE", "other_character_skill_list_INVENTORY_CLOSE", true)
        g.setup_hook_and_event(addon, "APPS_TRY_MOVE_BARRACK", "other_character_APPS_TRY_MOVE_BARRACK", false)

        addon:RegisterMsg("GAME_START_3SEC", "other_character_skill_list_tableset")
    end
    local end_time = os.clock()
    local elapsed_time = end_time - start_time
    -- CHAT_SYSTEM(string.format("other_character_skill_list_ON_INIT: %.4f seconds", elapsed_time))
end

function other_character_APPS_TRY_MOVE_BARRACK()
    other_character_skill_list_save_enchant()

    if type(_G["INSTANTCC_APPS_TRY_MOVE_BARRACK"]) ~= "function" then
        APPS_TRY_LEAVE("Barrack");
    end

end

local equips = {"SHIRT", "PANTS", "GLOVES", "BOOTS", "LEG", "GOD", "SEAL", "ARK", "RELIC", "EARRING", "RH", "LH",
                "RH_SUB", "LH_SUB", "RING1", "RING2", "NECK"}

function g.shallow_copy(original_table)
    local new_table = {}
    for key, value in pairs(original_table) do
        new_table[key] = value
    end
    return new_table
end

function other_character_skill_list_load_settings()
    local settings = g.load_json(g.settings_path)

    if not settings or not settings.characters then
        settings = {
            characters = {}
        }
    end

    g.settings = settings

    local account_info = session.barrack.GetMyAccount()
    local all_pc_count = account_info:GetBarrackPCCount()
    if type(all_pc_count) ~= "number" or all_pc_count <= 0 then
        return
    end

    local default_blueprints = {}
    for _, equip_name in ipairs(equips) do
        if equip_name == "SHIRT" or equip_name == "PANTS" or equip_name == "GLOVES" or equip_name == "BOOTS" then
            default_blueprints[equip_name] = {
                clsid = 0,
                lv = 0,
                skill_name = "",
                skill_lv = 0
            }

        else
            default_blueprints[equip_name] = {
                clsid = 0,
                lv = 0
            }
        end
    end

    local barrack_characters = {}
    for i = 0, all_pc_count - 1 do
        local barrack_pc_info = account_info:GetBarrackPCByIndex(i)
        if barrack_pc_info then -- 念のため、これもチェック
            local barrack_pc_name = barrack_pc_info:GetName()
            barrack_characters[barrack_pc_name] = true

            settings.characters[barrack_pc_name] = settings.characters[barrack_pc_name] or {
                index = i,
                layer = 9,
                gear_score = 0,
                cid = "",
                equips = {}
            }

            local char_equips = settings.characters[barrack_pc_name].equips
            for _, equip_name in ipairs(equips) do

                if not char_equips[equip_name] then

                    char_equips[equip_name] = g.shallow_copy(default_blueprints[equip_name])
                end
            end
        end
    end

    local keys_to_delete = {}
    for character_name in pairs(settings.characters) do
        if not barrack_characters[character_name] then
            table.insert(keys_to_delete, character_name)
        end
    end

    if #keys_to_delete > 0 then
        for _, key_to_remove in ipairs(keys_to_delete) do
            settings.characters[key_to_remove] = nil
        end
    end

    g.settings = settings
    g.save_settings()
    g.loaded = true
end

function other_character_skill_list_sort()

    local function sort_layer_order(a, b)
        if a.layer ~= b.layer then
            return a.layer < b.layer
        else
            return a.index < b.index
        end
    end

    local char_list = {}

    for name, char_data in pairs(g.settings.characters) do

        local cid = g.settings.characters[name].cid

        char_data.name = name

        -- if cid ~= "" then

        table.insert(char_list, char_data)
        -- end
    end

    table.sort(char_list, sort_layer_order)
    g.characters = char_list
end

function other_character_skill_list_tableset()

    local account_info = session.barrack.GetMyAccount()

    local same_count = account_info:GetPCCount()

    for i = 0, same_count - 1 do

        local pc_info = account_info:GetPCByIndex(i)
        local active_pc = pc_info:GetApc()
        local pc_name = active_pc:GetName()

        local pc_cid = pc_info:GetCID()

        g.settings.characters[pc_name].cid = pc_cid
        g.settings.characters[pc_name].index = i

        if g.layer and g.layer ~= g.settings.characters[pc_name].layer then
            g.settings.characters[pc_name].layer = g.layer
        end
    end
    g.save_settings()
    g.layer = nil
    other_character_skill_list_sort()
end

function other_character_skill_list_frame_init()
    local frame = ui.GetFrame("other_character_skill_list")
    frame:SetSkinName("None")
    frame:SetTitleBarSkin("None")
    frame:Resize(35, 35)
    frame:SetPos(715, 0)

    frame:ShowWindow(1)

    local btn = frame:CreateOrGetControl('button', 'btn', 0, 0, 35, 35)
    AUTO_CAST(btn)
    btn:SetSkinName("None")
    btn:SetText("{img sysmenu_friend 35 35}")

    btn:SetEventScript(ui.LBUTTONDOWN, "other_character_skill_list_frame_open")
    btn:SetTextTooltip("{ol}Other Character Skill List")
    other_character_skill_list_tableset()
end

g.last_save_time = 0
function other_character_skill_list_save_enchant()

    local current_time = os.time()

    if current_time - g.last_save_time < 0.5 then
        return
    end
    g.last_save_time = current_time

    local inventory = ui.GetFrame("inventory")
    local pc_name = session.GetMySession():GetPCApc():GetName()
    local equip_item_list = session.GetEquipItemList()

    local count = equip_item_list:Count()
    local cid = session.GetMySession():GetCID()

    local data = g.settings.characters[pc_name].equips

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
                    skill_lv = skill_lv
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
        elseif spot_name == "EARRING" then
            local slot = GET_CHILD_RECURSIVELY(inventory, spot_name)
            local icon = slot:GetIcon()

            local option_texts = {}

            if icon then

                local max_option_count = shared_item_earring.get_max_special_option_count(TryGetProp(obj, 'UseLv', 1))

                for i = 1, max_option_count do
                    local option_name = 'EarringSpecialOption_' .. i
                    local job = TryGetProp(obj, option_name, 'None')
                    if job ~= 'None' then
                        local job_cls = GetClass('Job', job)
                        if job_cls ~= nil then
                            local item_name = dictionary.ReplaceDicIDInCompStr(job_cls.Name)
                            local rank = TryGetProp(obj, 'EarringSpecialOptionRankValue_' .. i, 0)
                            local skill_lv = TryGetProp(obj, 'EarringSpecialOptionLevelValue_' .. i, 0)

                            local temp_text = ScpArgMsg('EarringSpecialOption{ctrl}{rank}{lv}', 'ctrl', item_name,
                                'rank', rank, 'lv', skill_lv)

                            table.insert(option_texts, temp_text)
                        end
                    end
                end
            end

            local final_text = table.concat(option_texts, ":::")
            -- print("最終的なイヤリングオプション: " .. final_text)
            if icon then
                data[spot_name] = {
                    clsid = obj.ClassID,
                    lv = final_text

                }
            else
                data[spot_name] = {}
            end
        end
    end

    local info = equipcard.GetCardInfo(13)
    if info then
        g.settings.characters[pc_name].equips["LEG"].clsid = info:GetCardID()
        g.settings.characters[pc_name].equips["LEG"].lv = info.cardLv
    else
        g.settings.characters[pc_name].equips["LEG"] = {}
    end

    local info = equipcard.GetCardInfo(14)
    if info then
        g.settings.characters[pc_name].equips["GOD"].clsid = info:GetCardID()
        g.settings.characters[pc_name].equips["GOD"].lv = info.cardLv
    else
        g.settings.characters[pc_name].equips["GOD"] = {}
    end
    g.settings.characters[pc_name].gear_score = score

    g.save_settings()

end

function other_character_skill_list_INVENTORY_OPEN()
    local frame = ui.GetFrame("other_character_skill_list")
    frame:ShowWindow(0)
    other_character_skill_list_save_enchant()
end

function other_character_skill_list_INVENTORY_CLOSE()
    local frame = ui.GetFrame("other_character_skill_list")
    frame:ShowWindow(1)
    other_character_skill_list_save_enchant()
end

function other_character_skill_list_char_report_close(frame, ctrl, str, num)

    local parent = frame:GetParent()
    parent = parent:GetParent()

    parent:ShowWindow(0)

    other_character_skill_list_frame_open()
end

function other_character_skill_list_char_report(frame, ctrl, char_name_str, num)

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
        other_character_skill_list_frame_open()
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
    indun_btn:SetEventScript(ui.LBUTTONUP, "other_character_skill_list_char_report_close")

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

function other_character_skill_list_split_earring_options(earring_data_string)

    if not earring_data_string or earring_data_string == "" then
        return {}
    end

    local options_list = {}

    for option_part in earring_data_string:gmatch("([^:]+)") do
        table.insert(options_list, option_part)
    end

    return options_list
end

function other_character_skill_list_frame_open(frame, ctrl, str, num)

    other_character_skill_list_save_enchant()

    local main_frame = ui.CreateNewFrame("notice_on_pc", addon_name_lower .. "new_frame", 0, 0, 70, 30)
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
    close_btn:SetEventScript(ui.LBUTTONUP, "other_character_skill_list_frame_close")

    local help_btn = title_box:CreateOrGetControl('button', "help", 40, 0, 35, 35)
    AUTO_CAST(help_btn)
    help_btn:SetText("{ol}{img question_mark 20 20}")
    help_btn:SetSkinName("test_pvp_btn")

    local ccbtn = title_box:CreateOrGetControl('button', 'ccbtn', 75, 0, 35, 35)
    AUTO_CAST(ccbtn)
    ccbtn:SetSkinName("None")
    ccbtn:SetText("{ol}{img barrack_button_normal 35 35}")
    ccbtn:SetEventScript(ui.LBUTTONUP, "APPS_TRY_MOVE_BARRACK")
    ccbtn:SetTextTooltip(g.lang == "Japanese" and "{ol}バラックに戻ります" or "{ol}Return to Barracks")

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

    local acc_lbl = title_box:CreateOrGetControl("richtext", "Accessory", 290, 10, 100, 20)
    acc_lbl:SetText(current_lang == "Japanese" and "{ol}" .. "アクセ" or "{ol}" .. "Accessory")

    local equip_x = 390
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
    -- main_gbox:SetSkinName("test_frame_midle_light")
    main_gbox:SetSkinName("chat_window_2")

    local trans_tbl = current_lang == "Japanese" and jatbl or entbl

    local all_skills = GetClassList("Skill")

    local y_pos = 10
    local equip_grp_x = 385
    local etc_x_offset = 0

    local char_count = 0

    for i, char_info in ipairs(g.characters) do

        local char_settings = g.settings.characters[char_info.name]

        local char_equips = char_settings.equips

        local gear_score = char_settings.gear_score

        local job_list, level, last_job_id = GetJobListFromAdventureBookCharData(char_info.name)
        local last_job_class = GetClassByType("Job", last_job_id)
        local last_job_icon = TryGetProp(last_job_class, "Icon")

        local job_slot = main_gbox:CreateOrGetControl("slot", "jobslot" .. i, 0, y_pos - 3, 25, 25)
        AUTO_CAST(job_slot)
        job_slot:SetSkinName("None")
        job_slot:EnableHitTest(1)
        job_slot:EnablePop(0)

        local job_icon = CreateIcon(job_slot)
        job_icon:SetImage(last_job_icon)

        local name_lbl = main_gbox:CreateOrGetControl("richtext", "name_text" .. i, 25, y_pos, 195, 20)
        AUTO_CAST(name_lbl)
        name_lbl:SetText("{ol}" .. char_info.name)
        name_lbl:AdjustFontSizeByWidth(195)
        name_lbl:SetEventScript(ui.RBUTTONUP, "other_character_skill_list_char_report")
        name_lbl:SetEventScriptArgString(ui.RBUTTONUP, char_info.name)
        local gs_str = gear_score ~= 0 and tostring(gear_score) or "NoData" -- tostring 追加

        local functionName = "INSTANTCC_ON_INIT"
        if type(_G[functionName]) == "function" then

            function other_character_skill_list_INSTANTCC_DO_CC(frame, ctrl, cid, layer)

                INSTANTCC_DO_CC(cid, layer)
            end

            local cid = char_info.cid
            local layer = char_info.layer

            name_lbl:SetEventScript(ui.LBUTTONDOWN, "other_character_skill_list_INSTANTCC_DO_CC")
            name_lbl:SetEventScriptArgString(ui.LBUTTONDOWN, cid)
            name_lbl:SetEventScriptArgNumber(ui.LBUTTONDOWN, layer)
            name_lbl:SetTextTooltip(current_lang == "Japanese" and "{ol}GearScore: " .. gs_str .. "{nl} {nl}" ..
                                        "右クリック: 各キャラ装備詳細{nl}左クリック：キャラクターチェンジ" or
                                        "{ol}GearScore: " .. gs_str .. "{nl} {nl}" ..
                                        "Right click: Details of each character's equipment{nl}Left click: Character change")
        else
            name_lbl:SetTextTooltip(current_lang == "Japanese" and "{ol}GearScore: " .. gs_str .. "{nl} {nl}" ..
                                        "右クリック: 各キャラ装備詳細" or "{ol}GearScore: " .. gs_str ..
                                        "{nl} {nl}" .. "Right-click: Details of each character's equipment")
        end

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
                        equip_grp_x + 60 + (225 * (j - 1)), y_pos, 140, 20) -- skill_name を skill_name_lbl に

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

            elseif j >= 5 and j <= 10 then
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
                        if j ~= 10 then
                            icon:SetTextTooltip(item_cls.Name)
                            etc_slot:SetText(text_prefix .. equip_data_entry.lv, 'count', ui.RIGHT, ui.BOTTOM, 0, 0)
                        else
                            local tooltip = item_cls.Name
                            local earring_str = other_character_skill_list_split_earring_options(equip_data_entry.lv)
                            for i, option_str in ipairs(earring_str) do
                                tooltip = tooltip .. "{nl}" .. option_str

                            end
                            icon:SetTextTooltip(tooltip)
                        end
                    end

                end
                etc_x_offset = etc_x_offset + 30
            elseif j >= 11 then
                local weapon_slot_x = 155 + 30 * (j - 11)
                if j >= 15 then
                    weapon_slot_x = 155 + 30 * (j - 11) + 10
                end
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
    main_frame:Resize(1480, frame_height + 60)
    title_box:Resize(1470, 40)
    main_gbox:Resize(1470, frame_height + 20)

    local current_frame_w = main_frame:GetWidth()
    local map_frame = ui.GetFrame("map")

    local map_width = map_frame:GetWidth()
    main_frame:SetPos((map_width - current_frame_w) / 2, 0)

    main_frame:ShowWindow(1)
end

--[[function other_character_skill_list_frame_open(frame, ctrl, str, num)

    other_character_skill_list_save_enchant()

    local main_frame = ui.CreateNewFrame("notice_on_pc", addon_name_lower .. "new_frame", 0, 0, 70, 30)
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
    close_btn:SetEventScript(ui.LBUTTONUP, "other_character_skill_list_frame_close")

    local help_btn = title_box:CreateOrGetControl('button', "help", 40, 0, 35, 35)
    AUTO_CAST(help_btn)
    help_btn:SetText("{ol}{img question_mark 20 20}")
    help_btn:SetSkinName("test_pvp_btn")

    local ccbtn = title_box:CreateOrGetControl('button', 'ccbtn', 75, 0, 35, 35)
    AUTO_CAST(ccbtn)
    ccbtn:SetSkinName("None")
    ccbtn:SetText("{ol}{img barrack_button_normal 35 35}")
    ccbtn:SetEventScript(ui.LBUTTONUP, "APPS_TRY_MOVE_BARRACK")
    ccbtn:SetTextTooltip(g.lang == "Japanese" and "{ol}バラックに戻ります" or "{ol}Return to Barracks")

    local current_lang = option.GetCurrentCountry()
    help_btn:SetTextTooltip(current_lang == "Japanese" and
                                "{ol}順番に並ばない場合は一度バラックに戻ってバラック1､2､3毎にログインしてください。{nl}" ..
                                "InstantCCアドオンを使用している場合は「Return To Barrack」で戻ってください。{nl} {nl}" ..
                                "{ol}名前部分を押すと、ログインキャラと同一バラックの各キャラの装備詳細が見れます。" or
                                "{ol}If you do not line up in order,{nl}" ..
                                "please return to the barracks once and log in for each barracks 1,2,3.{nl}" ..
                                "If you are using the InstantCC add-on, please return with [Return To Barrack].{nl} {nl}" ..
                                "{ol}Press the name section to see the equipment details of each character{nl}in the same barrack as the login character.")

    -- 変更点1：ヘッダーの描画順を、あなたの理想通りに書き換えます
    local header_x = 160
    title_box:CreateOrGetControl("richtext", "weapon_header", header_x, 10, 100, 20):SetText(
        current_lang == "Japanese" and "{ol}武器" or "{ol}weapons")
    header_x = header_x + 230 -- X座標をずらす

    local armor_headers = {ClMsg("Shirt"), ClMsg("Pants"), ClMsg("GLOVES"), ClMsg("BOOTS")}
    for i, text in ipairs(armor_headers) do
        title_box:CreateOrGetControl("richtext", "armor_header" .. i, header_x, 10, 100, 20):SetText("{ol}" .. text)
            :AdjustFontSizeByWidth(100)
        header_x = header_x + 225
    end

    title_box:CreateOrGetControl("richtext", "etc_header", header_x, 10, 100, 20):SetText(
        current_lang == "Japanese" and "{ol}その他" or "{ol}etc.")

    local main_gbox = main_frame:CreateOrGetControl("groupbox", "gbox", 5, 35, 1070, 280)
    AUTO_CAST(main_gbox)
    main_gbox:RemoveAllChild()
    main_gbox:SetSkinName("chat_window_2")

    local trans_tbl = current_lang == "Japanese" and jatbl or entbl
    local all_skills = GetClassList("Skill")
    local y_pos = 10
    local char_count = 0

    for i, char_info in ipairs(g.characters) do
        local char_settings = g.settings.characters[char_info.name]
        local char_equips = char_settings.equips
        local gear_score = char_settings.gear_score

        -- (名前やジョブアイコンの描画部分は、あなたの元のコードのままです)
        local _, _, last_job_id = GetJobListFromAdventureBookCharData(char_info.name)
        local last_job_class = GetClassByType("Job", last_job_id)
        local last_job_icon = TryGetProp(last_job_class, "Icon")
        local job_slot = main_gbox:CreateOrGetControl("slot", "jobslot" .. i, 0, y_pos - 3, 25, 25)
        AUTO_CAST(job_slot);
        job_slot:SetSkinName("None");
        job_slot:EnableHitTest(1);
        job_slot:EnablePop(0)
        CreateIcon(job_slot):SetImage(last_job_icon)
        local name_lbl = main_gbox:CreateOrGetControl("richtext", "name_text" .. i, 25, y_pos, 195, 20)
        AUTO_CAST(name_lbl);
        name_lbl:SetText("{ol}" .. char_info.name);
        name_lbl:AdjustFontSizeByWidth(195)
        name_lbl:SetEventScript(ui.RBUTTONUP, "other_character_skill_list_char_report")
        name_lbl:SetEventScriptArgString(ui.RBUTTONUP, char_info.name)
        local gs_str = gear_score ~= 0 and tostring(gear_score) or "NoData"
        if type(_G["INSTANTCC_ON_INIT"]) == "function" then
            function other_character_skill_list_INSTANTCC_DO_CC(frame, ctrl, cid, layer)
                INSTANTCC_DO_CC(cid, layer)
            end
            name_lbl:SetEventScript(ui.LBUTTONDOWN, "other_character_skill_list_INSTANTCC_DO_CC")
            name_lbl:SetEventScriptArgString(ui.LBUTTONDOWN, char_info.cid)
            name_lbl:SetEventScriptArgNumber(ui.LBUTTONDOWN, char_info.layer)
            name_lbl:SetTextTooltip(current_lang == "Japanese" and "{ol}GearScore: " .. gs_str ..
                                        "{nl} {nl}右クリック: 各キャラ装備詳細{nl}左クリック：キャラクターチェンジ" or
                                        "{ol}GearScore: " .. gs_str ..
                                        "{nl} {nl}Right click: Details of each character's equipment{nl}Left click: Character change")
        else
            name_lbl:SetTextTooltip(current_lang == "Japanese" and "{ol}GearScore: " .. gs_str ..
                                        "{nl} {nl}右クリック: 各キャラ装備詳細" or "{ol}GearScore: " ..
                                        gs_str .. "{nl} {nl}Right-click: Details of each character's equipment")
        end

        -- 変更点2：UIの見た目通りに、装備リストをここで定義します
        local equip_order = { -- 1. 武器
        "RH", "LH", "RH_SUB", "LH_SUB", -- 2. 防具
        "SHIRT", "PANTS", "GLOVES", "BOOTS", -- 3. その他
        "NECK", "RING1", "RING2", "EARRING", "SEAL", "ARK", "RELIC", "LEG", "GOD"}

        local current_x = 155 -- 描画開始X座標

        -- 変更点3：この一つのループで、全ての装備を描画します
        for j, equip_type in ipairs(equip_order) do
            if char_equips[equip_type] == nil then
                char_equips[equip_type] = {}
            end
            local equip_data = char_equips[equip_type]

            if equip_type == "RH" or equip_type == "LH" or equip_type == "RH_SUB" or equip_type == "LH_SUB" or
                equip_type == "NECK" or equip_type == "RING1" or equip_type == "RING2" then
                -- 【武器・アクセの描画】
                local slot = AUTO_CAST(main_gbox:CreateOrGetControl("slot", "slot" .. equip_type .. i, current_x, y_pos,
                    25, 24))
                slot:SetSkinName('invenslot2')
                if equip_data.clsid and equip_data.clsid ~= 0 then
                    local item_cls = GetClassByType("Item", equip_data.clsid)
                    if item_cls then
                        SET_SLOT_ICON(slot, item_cls.Icon)
                        SET_SLOT_BG_BY_ITEMGRADE(slot, item_cls)
                        slot:SetText('{s12}{ol}{#FFFF00}+' .. equip_data.lv, 'count', ui.RIGHT, ui.BOTTOM, 0, 0)
                        local icon = slot:GetIcon();
                        if icon then
                            icon:SetTextTooltip(item_cls.Name)
                        end
                    end
                end
                current_x = current_x + 30
                if equip_type == "LH_SUB" then
                    current_x = current_x + 10
                end -- アクセとの間に少しスペース

            elseif equip_type == "SHIRT" or equip_type == "PANTS" or equip_type == "GLOVES" or equip_type == "BOOTS" then
                -- 【防具の描画】
                local item_slot = AUTO_CAST(main_gbox:CreateOrGetControl("slot", "equip" .. equip_type .. i, current_x,
                    y_pos, 25, 24))
                item_slot:SetSkinName('invenslot2')
                if equip_data.clsid and equip_data.clsid ~= 0 then
                    local item_cls = GetClassByType("Item", equip_data.clsid)
                    if item_cls then
                        SET_SLOT_ICON(item_slot, item_cls.Icon)
                        SET_SLOT_BG_BY_ITEMGRADE(item_slot, item_cls)
                        item_slot:SetText('{s12}{ol}{#FFFF00}+' .. equip_data.lv, 'count', ui.RIGHT, ui.BOTTOM, 0, 0)
                        local icon = item_slot:GetIcon();
                        if icon then
                            icon:SetTextTooltip(item_cls.Name)
                        end
                    end
                end
                local skill_slot = AUTO_CAST(main_gbox:CreateOrGetControl("slot", "slot" .. equip_type .. i,
                    current_x + 30, y_pos, 25, 24))
                skill_slot:SetSkinName('invenslot2')
                if equip_data.skill_name and equip_data.skill_name ~= "" then
                    local skill = GetClassByNameFromList(all_skills, equip_data.skill_name)
                    if skill then
                        SET_SLOT_ICON(skill_slot, 'icon_' .. skill.Icon)
                        skill_slot:SetText('{s14}{ol}{#FFFF00}' .. equip_data.skill_lv, 'count', ui.RIGHT, ui.BOTTOM,
                            -2, -2)
                        local icon = skill_slot:GetIcon()
                        if icon then
                            icon:SetTooltipType('skill');
                            icon:SetTooltipArg("Level", skill.ClassID, equip_data.skill_lv)
                        end
                        local skill_name_lbl = AUTO_CAST(main_gbox:CreateOrGetControl("richtext",
                            "skill_name" .. equip_type .. i, current_x + 60, y_pos, 140, 20))
                        if trans_tbl[equip_data.skill_name] then
                            skill_name_lbl:SetText("{ol}{s16}" .. trans_tbl[equip_data.skill_name])
                                :AdjustFontSizeByWidth(160)
                        end
                    end
                end
                current_x = current_x + 225

            elseif equip_type == "SEAL" or equip_type == "ARK" or equip_type == "RELIC" or equip_type == "LEG" or
                equip_type == "GOD" or equip_type == "EARRING" then
                -- 【その他の描画】
                local slot = AUTO_CAST(main_gbox:CreateOrGetControl("slot", "etc_slot" .. equip_type .. i, current_x,
                    y_pos, 25, 24))
                slot:SetSkinName('invenslot2')
                if equip_data.clsid and equip_data.clsid ~= 0 then
                    local item_cls = GetClassByType("Item", equip_data.clsid)
                    if item_cls then
                        local text_prefix = (equip_type == "LEG" or equip_type == "GOD") and
                                                "{s12}{ol}{#FFFF00}{img mon_legendstar 10 10}{nl}" or
                                                "{s12}{ol}{#FFFF00}+"
                        SET_SLOT_ICON(slot, item_cls.Icon)
                        slot:SetText(text_prefix .. equip_data.lv, 'count', ui.RIGHT, ui.BOTTOM, 0, 0)
                        local icon = slot:GetIcon();
                        if icon then
                            icon:SetTextTooltip(item_cls.Name)
                        end
                    end
                end
                current_x = current_x + 30
            end
        end

        y_pos = y_pos + 25
        char_count = char_count + 1
    end

    local frame_height = char_count * 25
    main_frame:Resize(1450, frame_height + 60)
    title_box:Resize(1440, 40)
    main_gbox:Resize(1440, frame_height + 20)

    local map_frame = ui.GetFrame("map")
    main_frame:SetPos((map_frame:GetWidth() - main_frame:GetWidth()) / 2, 0)
    main_frame:ShowWindow(1)
end]]

function other_character_skill_list_frame_close(frame, ctrl, str, num)
    local frame = ui.GetFrame(addon_name_lower .. "new_frame")
    frame:ShowWindow(0)

end

-- アドオンメニューボタン
local norisan_menu_addons = string.format("../%s", "addons")
local norisan_menu_addons_mkfile = string.format("../%s/mkdir.txt", "addons")
local norisan_menu_settings = string.format("../addons/%s/settings.json", "norisan_menu")
local norisan_menu_folder = string.format("../addons/%s", "norisan_menu")
local norisan_menu_mkfile = string.format("../addons/%s/mkdir.txt", "norisan_menu")
_G["norisan"] = _G["norisan"] or {}
_G["norisan"]["MENU"] = _G["norisan"]["MENU"] or {}

local json = require("json")

local function norisan_menu_create_folder_file()

    local addons_file = io.open(norisan_menu_addons_mkfile, "r")
    if not addons_file then
        os.execute('mkdir "' .. norisan_menu_addons .. '"')
        addons_file = io.open(norisan_menu_addons_mkfile, "w")
        if addons_file then
            addons_file:write("created");
            addons_file:close()
        end
    else
        addons_file:close()
    end

    local file = io.open(norisan_menu_mkfile, "r")
    if not file then
        os.execute('mkdir "' .. norisan_menu_folder .. '"')
        file = io.open(norisan_menu_mkfile, "w")
        if file then
            file:write("created");
            file:close()
        end
    else
        file:close()
    end
end
norisan_menu_create_folder_file()

local function norisan_menu_save_json(path, tbl)

    local data_to_save = {
        x = tbl.x,
        y = tbl.y,
        move = tbl.move,
        open = tbl.open,
        layer = tbl.layer
    }
    local file = io.open(path, "w")
    if file then
        local str = json.encode(data_to_save)
        file:write(str)
        file:close()
    end
end

local function norisan_menu_load_json(path)

    local file = io.open(path, "r")
    if file then
        local content = file:read("*all")
        file:close()
        if content and content ~= "" then
            local decoded, err = json.decode(content)
            if decoded then
                return decoded
            end
        end
    end
    return nil
end

function _G.norisan_menu_move_drag(frame, ctrl)
    if not frame then
        return
    end

    local current_frame_y = frame:GetY()
    local current_frame_h = frame:GetHeight()
    local base_button_h = 40

    local y_to_save = current_frame_y

    if current_frame_h > base_button_h and (_G["norisan"]["MENU"].open == 1) then
        local items_area_h_calculated = current_frame_h - base_button_h
        y_to_save = current_frame_y + items_area_h_calculated

    end

    _G["norisan"]["MENU"].x = frame:GetX()
    _G["norisan"]["MENU"].y = y_to_save

    norisan_menu_save_json(norisan_menu_settings, _G["norisan"]["MENU"])
end

function _G.norisan_menu_setting_frame_ctrl(setting, ctrl)
    local ctrl_name = ctrl:GetName()

    local frame_name = _G["norisan"]["MENU"].frame_name
    local frame = ui.GetFrame(frame_name)

    if ctrl_name == "layer_edit" then
        local layer = tonumber(ctrl:GetText())
        if layer then
            _G["norisan"]["MENU"].layer = layer
            frame:SetLayerLevel(layer)
            norisan_menu_save_json(norisan_menu_settings, _G["norisan"]["MENU"])

            local notice = _G["norisan"]["MENU"].lang == "Japanese" and "{ol}レイヤーを変更" or
                               "{ol}Change Layer"
            ui.SysMsg(notice)
            _G.norisan_menu_create_frame()
            setting:ShowWindow(0)
            return
        end
    end

    if ctrl_name == "def_setting" then

        _G["norisan"]["MENU"].x = 1190
        _G["norisan"]["MENU"].y = 30
        _G["norisan"]["MENU"].move = true
        _G["norisan"]["MENU"].open = 0
        _G["norisan"]["MENU"].layer = 79
        norisan_menu_save_json(norisan_menu_settings, _G["norisan"]["MENU"])
        _G.norisan_menu_create_frame()
        setting:ShowWindow(0)
        return
    end
    if ctrl_name == "close" then
        setting:ShowWindow(0)
        return
    end

    local is_check = ctrl:IsChecked()
    if ctrl_name == "move_toggle" then
        if is_check == 1 then
            _G["norisan"]["MENU"].move = false
        else
            _G["norisan"]["MENU"].move = true
        end
        frame:EnableMove(_G["norisan"]["MENU"].move == true and 1 or 0)
        norisan_menu_save_json(norisan_menu_settings, _G["norisan"]["MENU"])
        return
    elseif ctrl_name == "open_toggle" then
        _G["norisan"]["MENU"].open = is_check
        norisan_menu_save_json(norisan_menu_settings, _G["norisan"]["MENU"])
        _G.norisan_menu_create_frame()
        return
    end

end

function _G.norisan_menu_setting_frame(frame, ctrl)
    local setting = ui.CreateNewFrame("chat_memberlist", "norisan_menu_setting", 0, 0, 0, 0)
    AUTO_CAST(setting)

    setting:SetTitleBarSkin("None")
    setting:SetSkinName("chat_window")
    setting:Resize(260, 135)
    setting:SetLayerLevel(999)
    setting:EnableHitTest(1)
    setting:EnableMove(1)

    setting:SetPos(frame:GetX() + 200, frame:GetY())
    setting:ShowWindow(1)

    local close = setting:CreateOrGetControl("button", "close", 0, 0, 30, 30)
    AUTO_CAST(close)
    close:SetImage("testclose_button")
    close:SetGravity(ui.RIGHT, ui.TOP)
    close:SetEventScript(ui.LBUTTONUP, "norisan_menu_setting_frame_ctrl");

    local def_setting = setting:CreateOrGetControl("button", "def_setting", 10, 5, 150, 30)
    AUTO_CAST(def_setting)
    local notice = _G["norisan"]["MENU"].lang == "Japanese" and "{ol}デフォルトに戻す" or "{ol}Reset to default"
    def_setting:SetText(notice)
    def_setting:SetEventScript(ui.LBUTTONUP, "norisan_menu_setting_frame_ctrl");

    local move_toggle = setting:CreateOrGetControl('checkbox', "move_toggle", 10, 35, 30, 30)
    AUTO_CAST(move_toggle)
    move_toggle:SetCheck(_G["norisan"]["MENU"].move == true and 0 or 1)
    move_toggle:SetEventScript(ui.LBUTTONDOWN, 'norisan_menu_setting_frame_ctrl')
    local notice = _G["norisan"]["MENU"].lang == "Japanese" and "{ol}チェックするとフレーム固定" or
                       "{ol}Check to fix frame"
    move_toggle:SetText(notice)

    local open_toggle = setting:CreateOrGetControl('checkbox', "open_toggle", 10, 70, 30, 30)
    AUTO_CAST(open_toggle)
    open_toggle:SetCheck(_G["norisan"]["MENU"].open)
    open_toggle:SetEventScript(ui.LBUTTONDOWN, 'norisan_menu_setting_frame_ctrl')
    local notice = _G["norisan"]["MENU"].lang == "Japanese" and "{ol}チェックすると上開き" or
                       "{ol}Check to open upward"
    open_toggle:SetText(notice)

    local layer_text = setting:CreateOrGetControl('richtext', 'layer_text', 10, 105, 50, 20)
    AUTO_CAST(layer_text)
    local notice = _G["norisan"]["MENU"].lang == "Japanese" and "{ol}レイヤー設定" or "{ol}Set Layer"
    layer_text:SetText(notice)

    local layer_edit = setting:CreateOrGetControl('edit', 'layer_edit', 130, 105, 70, 20)
    AUTO_CAST(layer_edit)
    layer_edit:SetFontName("white_16_ol")
    layer_edit:SetTextAlign("center", "center")
    layer_edit:SetText(_G["norisan"]["MENU"].layer or 79)
    layer_edit:SetEventScript(ui.ENTERKEY, "norisan_menu_setting_frame_ctrl")
end

function _G.norisan_menu_toggle_items_display(frame, ctrl, open_dir)

    local open_up = (open_dir == 1)

    local menu_src = _G["norisan"]["MENU"]
    local max_cols = 5
    local item_w = 35
    local item_h = 35
    local y_off_down = 35

    local items = {}
    if menu_src then
        for key, data in pairs(menu_src) do
            if type(data) == "table" then
                if key ~= "x" and key ~= "y" and key ~= "open" and key ~= "move" and data.name and data.func and
                    ((data.image and data.image ~= "") or (data.icon and data.icon ~= "")) then
                    table.insert(items, {
                        key = key,
                        data = data
                    })
                end
            end
        end
    end

    local num_items = #items

    local num_rows = math.ceil(num_items / max_cols)

    local items_h = num_rows * item_h
    local frame_h_new = 40 + items_h
    local frame_y_new = _G["norisan"]["MENU"].y or 30

    if open_up then
        frame_y_new = frame_y_new - items_h
    end

    local frame_w_new
    if num_rows == 1 then
        frame_w_new = math.max(40, num_items * item_w)
    else
        frame_w_new = math.max(40, max_cols * item_w)
    end

    frame:SetPos(frame:GetX(), frame_y_new)
    frame:Resize(frame_w_new, frame_h_new)

    for idx, entry in ipairs(items) do
        local item_sidx = idx - 1
        local data = entry.data
        local key = entry.key
        local col = item_sidx % max_cols
        local x = col * item_w
        local y = 0

        if open_up then

            local logical_row_from_bottom = math.floor(item_sidx / max_cols)

            y = (frame_h_new - 40) - ((logical_row_from_bottom + 1) * item_h)
        else

            local row_down = math.floor(item_sidx / max_cols)
            y = y_off_down + (row_down * item_h)
        end

        local ctrl_name = "menu_item_" .. key
        local item_elem

        if data.image and data.image ~= "" then
            item_elem = frame:CreateOrGetControl('button', ctrl_name, x, y, item_w, item_h)
            AUTO_CAST(item_elem);
            item_elem:SetSkinName("None");
            item_elem:SetText(data.image)
        else
            item_elem = frame:CreateOrGetControl('picture', ctrl_name, x, y, item_w, item_h)
            AUTO_CAST(item_elem);
            item_elem:SetImage(data.icon);
            item_elem:SetEnableStretch(1)
        end

        if item_elem then
            item_elem:SetTextTooltip("{ol}" .. data.name)
            item_elem:SetEventScript(ui.LBUTTONUP, data.func)
            item_elem:ShowWindow(1)
        end
    end

    local main_btn = GET_CHILD(frame, "norisan_menu_pic")
    if main_btn then
        if open_up then
            main_btn:SetPos(0, frame_h_new - 40)
        else
            main_btn:SetPos(0, 0)
        end
    end
end

function _G.norisan_menu_frame_open(frame, ctrl)
    if not frame then
        return
    end

    if frame:GetHeight() > 40 then

        local children = {}
        for i = 0, frame:GetChildCount() - 1 do
            local child_obj = frame:GetChildByIndex(i)
            if child_obj then
                table.insert(children, child_obj)
            end
        end

        for _, child_obj in ipairs(children) do
            if child_obj:GetName() ~= "norisan_menu_pic" then

                frame:RemoveChild(child_obj:GetName())
            end
        end

        frame:Resize(40, 40)
        frame:SetPos(frame:GetX(), _G["norisan"]["MENU"].y or 30)
        local main_pic = GET_CHILD(frame, "norisan_menu_pic")
        if main_pic then
            main_pic:SetPos(0, 0)
        end
        return
    end

    local open_dir_val = _G["norisan"]["MENU"].open or 0
    _G.norisan_menu_toggle_items_display(frame, ctrl, open_dir_val)
end

function _G.norisan_menu_create_frame()

    _G["norisan"]["MENU"].lang = option.GetCurrentCountry()

    local loaded_cfg = norisan_menu_load_json(norisan_menu_settings)

    if loaded_cfg and loaded_cfg.layer ~= nil then
        _G["norisan"]["MENU"].layer = loaded_cfg.layer
    elseif _G["norisan"]["MENU"].layer == nil then
        _G["norisan"]["MENU"].layer = 79
    end

    if loaded_cfg and loaded_cfg.move ~= nil then
        _G["norisan"]["MENU"].move = loaded_cfg.move
    elseif _G["norisan"]["MENU"].move == nil then
        _G["norisan"]["MENU"].move = true
    end

    if loaded_cfg and loaded_cfg.open ~= nil then
        _G["norisan"]["MENU"].open = loaded_cfg.open
    elseif _G["norisan"]["MENU"].open == nil then
        _G["norisan"]["MENU"].open = 0
    end

    local default_x = 1190
    local default_y = 30

    local final_x = default_x
    local final_y = default_y

    if _G["norisan"]["MENU"].x ~= nil then
        final_x = _G["norisan"]["MENU"].x
    end
    if _G["norisan"]["MENU"].y ~= nil then
        final_y = _G["norisan"]["MENU"].y
    end

    if loaded_cfg and type(loaded_cfg.x) == "number" then
        final_x = loaded_cfg.x
    end
    if loaded_cfg and type(loaded_cfg.y) == "number" then
        final_y = loaded_cfg.y
    end

    local map_ui = ui.GetFrame("map")
    local screen_w = 1920
    if map_ui and map_ui:IsVisible() then
        screen_w = map_ui:GetWidth()
    end

    if final_x > 1920 and screen_w <= 1920 then
        final_x = default_x
        final_y = default_y
    end

    _G["norisan"]["MENU"].x = final_x
    _G["norisan"]["MENU"].y = final_y

    norisan_menu_save_json(norisan_menu_settings, _G["norisan"]["MENU"])

    local frame_name = _G["norisan"]["MENU"].frame_name
    local frame = ui.GetFrame(frame_name)

    if frame then
        AUTO_CAST(frame)
        frame:RemoveAllChild()
        frame:SetSkinName("None")
        frame:SetTitleBarSkin("None")
        frame:Resize(40, 40)
        frame:SetLayerLevel(_G["norisan"]["MENU"].layer)
        frame:EnableMove(_G["norisan"]["MENU"].move == true and 1 or 0)
        frame:SetPos(_G["norisan"]["MENU"].x, _G["norisan"]["MENU"].y)
        frame:SetEventScript(ui.LBUTTONUP, "norisan_menu_move_drag")

        local norisan_menu_pic = frame:CreateOrGetControl('picture', "norisan_menu_pic", 0, 0, 35, 40)
        AUTO_CAST(norisan_menu_pic)
        norisan_menu_pic:SetImage("sysmenu_sys")
        norisan_menu_pic:SetEnableStretch(1)
        local notice = _G["norisan"]["MENU"].lang == "Japanese" and "{nl}{ol}右クリック: 設定" or
                           "{nl}{ol}Right click: Settings"
        norisan_menu_pic:SetTextTooltip("{ol}Addons Menu" .. notice)
        norisan_menu_pic:SetEventScript(ui.LBUTTONUP, "norisan_menu_frame_open")
        norisan_menu_pic:SetEventScript(ui.RBUTTONUP, "norisan_menu_setting_frame")

        frame:ShowWindow(1)
    end

end
