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
-- v1.1.9 新キャラ登録出来なかったの修正。イヤリング表示
-- v1.1.9.1 非表示機能
-- v1.2.0 コア管理機能追加、ilvと連携(ジョブアイコン)
local addon_name = "OTHER_CHARACTER_SKILL_LIST"
local addon_name_lower = string.lower(addon_name)
local author = "norisan"
local ver = "1.2.0"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addon_name] = _G["ADDONS"][author][addon_name] or {}
local g = _G["ADDONS"][author][addon_name]

local json = require('json')

local function ts(...)
    local num_args = select('#', ...)
    if num_args == 0 then
        print("ts() -- 引数がありません")
        return
    end
    local string_parts = {}
    for i = 1, num_args do
        local arg = select(i, ...)
        local arg_type = type(arg)
        local is_success, value_str = pcall(tostring, arg)
        if not is_success then
            value_str = "[tostringでエラー発生]"
        end
        table.insert(string_parts, string.format("(%s) %s", arg_type, value_str))
    end
    print(table.concat(string_parts, "   |   "))
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

function OTHER_CHARACTER_SKILL_LIST_ON_INIT(addon, frame)
    local start_time = os.clock() -- ★処理開始前の時刻を記録★
    g.addon = addon
    g.frame = frame

    g.name = session.GetMySession():GetPCApc():GetName()
    g.cid = session.GetMySession():GetCID()
    g.lang = option.GetCurrentCountry()
    g.REGISTER = {}

    g.layer = 1
    if _G["BARRACK_CHARLIST_ON_INIT"] and _G["current_layer"] then
        g.layer = _G["current_layer"]
    end
    _G["norisan"] = _G["norisan"] or {}
    _G["norisan"]["MENU"] = _G["norisan"]["MENU"] or {}
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
    if not _G["norisan"]["MENU"].frame_name or _G["norisan"]["MENU"].frame_name ~= "norisan_menu_frame" then
        _G["norisan"]["MENU"].frame_name = "norisan_menu_frame"
        addon:RegisterMsg("GAME_START", "norisan_menu_create_frame")
    end
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
        APPS_TRY_LEAVE("Barrack")
    end
end

local equips = {"SHIRT", "PANTS", "GLOVES", "BOOTS", "LEG", "GOD", "SEAL", "ARK", "RELIC", "EARRING", "CORE", "RH",
                "LH", "RH_SUB", "LH_SUB", "RING1", "RING2", "NECK"}

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
        table.insert(char_list, char_data)
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
            if icon then
                data[spot_name] = {
                    clsid = obj.ClassID,
                    lv = final_text
                }
            else
                data[spot_name] = {}
            end
        elseif spot_name == "CORE" then -- ！
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
    local frame = ui.GetFrame(addon_name_lower .. "charlist")
    frame:ShowWindow(0)
end

function other_character_skill_list_char_report(frame, ctrl, char_name_str, num)
    local frame = ui.CreateNewFrame("notice_on_pc", addon_name_lower .. "charlist", 5, 40, 0, 0)
    AUTO_CAST(frame)
    frame:RemoveAllChild()
    frame:SetLayerLevel(104)
    frame:SetSkinName("None")
    frame:Resize(410, 480)
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
    local char_ctrl = frame:CreateOrGetControlSet('barrack_charlist', 'char_' .. cid, 10, 10)
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
    local map_frame = ui.GetFrame("map")
    local map_width = map_frame:GetWidth()
    frame:SetPos((map_width) / 2 - 410 * 1.5, 40)
    frame:ShowWindow(1)
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

function other_character_skill_list_create_weapon_slots(parent_gbox, char_equips, equips, i, y_pos)
    for j = 12, #equips do
        local equip_type = equips[j]
        local equip_data_entry = char_equips[equip_type]
        if equip_data_entry then
            local weapon_slot_x = 155 + 30 * (j - 12)
            if j >= 16 then
                weapon_slot_x = weapon_slot_x + 10
            end
            local weapon_slot = parent_gbox:CreateOrGetControl("slot", "slot" .. equip_type .. i, weapon_slot_x, y_pos,
                25, 24)
            AUTO_CAST(weapon_slot)
            weapon_slot:SetSkinName('invenslot2')
            local clsid = equip_data_entry.clsid
            if clsid and clsid ~= 0 then
                local lv = equip_data_entry.lv
                local item_cls = GetClassByType("Item", clsid)
                if item_cls then
                    SET_SLOT_ICON(weapon_slot, item_cls.Icon)
                    SET_SLOT_BG_BY_ITEMGRADE(weapon_slot, item_cls)
                    weapon_slot:SetText('{s12}{ol}{#FFFF00}+' .. lv, 'count', ui.RIGHT, ui.BOTTOM, 0, 0)
                    local icon = weapon_slot:GetIcon()
                    if icon then
                        icon:SetTextTooltip("{ol}" .. item_cls.Name)
                    end
                end
            end
        end
    end
end

function other_character_skill_list_create_armor_slots(parent_gbox, char_equips, equips, all_skills, i, y_pos)
    local equip_grp_x = 385
    for j = 1, 4 do
        local equip_type = equips[j]
        local equip_data_entry = char_equips[equip_type]
        if equip_data_entry then
            local skill_slot = parent_gbox:CreateOrGetControl("slot", "slot" .. equip_type .. i,
                equip_grp_x + (225 * (j - 1)) + 30, y_pos, 25, 24)
            AUTO_CAST(skill_slot)
            skill_slot:SetSkinName('invenslot2')

            local item_slot = parent_gbox:CreateOrGetControl("slot", "equip" .. equip_type .. i,
                equip_grp_x + (225 * (j - 1)), y_pos, 25, 24)
            AUTO_CAST(item_slot)
            item_slot:SetSkinName('invenslot2')

            local clsid = equip_data_entry.clsid
            local item_cls = GetClassByType("Item", clsid)
            if item_cls then
                SET_SLOT_ICON(item_slot, item_cls.Icon)
                SET_SLOT_BG_BY_ITEMGRADE(item_slot, item_cls)
                item_slot:SetText('{s12}{ol}{#FFFF00}+' .. equip_data_entry.lv, 'count', ui.RIGHT, ui.BOTTOM, 0, 0)
                local icon = item_slot:GetIcon()
                if icon then
                    icon:SetTextTooltip("{ol}" .. item_cls.Name)
                end
            end

            local skill = GetClassByNameFromList(all_skills, equip_data_entry.skill_name)
            if skill then
                SET_SLOT_ICON(skill_slot, 'icon_' .. skill.Icon)
                skill_slot:SetText('{s14}{ol}{#FFFF00}' .. equip_data_entry.skill_lv, 'count', ui.RIGHT, ui.BOTTOM, -2,
                    -2)
                local icon = skill_slot:GetIcon()
                if icon then
                    icon:SetTooltipType('skill')
                    icon:SetTooltipArg("Level", skill.ClassID, equip_data_entry.skill_lv)
                end
                local skill_name_lbl = parent_gbox:CreateOrGetControl("richtext", "skill_name" .. equip_type .. i,
                    equip_grp_x + 60 + (225 * (j - 1)), y_pos, 140, 20)
                skill_name_lbl:SetText("{ol}{s16}" .. skill.Name)
                skill_name_lbl:AdjustFontSizeByWidth(160)
            end
        end
    end
end

function other_character_skill_list_create_etc_slots(parent_gbox, char_equips, equips, i, y_pos)
    local etc_x_offset = 0
    local equip_grp_x = 385
    local last_x = equip_grp_x + 225 * 4
    for j = 5, 11 do
        local equip_type = equips[j]
        local equip_data_entry = char_equips[equip_type]
        if equip_data_entry then
            local current_x = equip_grp_x + 225 * 4 + etc_x_offset
            local etc_slot = parent_gbox:CreateOrGetControl("slot", "etc_slot" .. equip_type .. i, current_x, y_pos, 25,
                24)
            AUTO_CAST(etc_slot)
            etc_slot:SetSkinName('invenslot2')

            local text_prefix = (j >= 5 and j <= 6) and "{s12}{ol}{#FFFF00}{img mon_legendstar 10 10}{nl}" or
                                    "{s12}{ol}{#FFFF00}+"
            local item_cls = GetClassByType("Item", equip_data_entry.clsid)
            if item_cls then
                SET_SLOT_ICON(etc_slot, item_cls.Icon)
                local icon = etc_slot:GetIcon()
                if icon then
                    local tooltip = item_cls.Name
                    if j == 10 then -- Earring
                        local earring_str = other_character_skill_list_split_earring_options(equip_data_entry.lv)
                        for _, option_str in ipairs(earring_str) do
                            tooltip = "{ol}" .. tooltip .. "{nl}" .. option_str
                        end
                    elseif j ~= 11 then -- Ark
                        etc_slot:SetText(text_prefix .. equip_data_entry.lv, 'count', ui.RIGHT, ui.BOTTOM, 0, 0)
                    end
                    icon:SetTextTooltip(tooltip)
                end
            end
            etc_x_offset = etc_x_offset + 30
            last_x = current_x
        end
    end
    return last_x + 30
end

function other_character_skill_create_title_bar(parent_frame)
    local title_box = parent_frame:CreateOrGetControl("groupbox", "title", 0, 0, 1070, 40)
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

    local hide_check = title_box:CreateOrGetControl('checkbox', 'hide_check', 120, 0, 35, 35)
    AUTO_CAST(hide_check)
    hide_check:SetEventScript(ui.LBUTTONUP, 'other_character_skill_list_display_check')
    hide_check:SetTextTooltip(g.lang == "Japanese" and "{ol}チェックしたキャラを非表示" or
                                  "{ol}Hide Checked Characters")
    hide_check:SetCheck(g.settings.hide or 0)

    local current_lang = option.GetCurrentCountry()
    help_btn:SetTextTooltip(current_lang == "Japanese" and
                                "{ol}順番に並ばない場合は一度バラックに戻ってバラック1､2､3毎にログインしてください。{nl}" ..
                                "{ol}名前部分を押すと、ログインキャラと同一バラックの各キャラの装備詳細が見れます。" or
                                "{ol}If you do not line up in order,{nl}" ..
                                "please return to the barracks once and log in for each barracks 1,2,3.{nl}" ..
                                "{ol}Press the name section to see the equipment details of each character{nl}in the same barrack as the login character.")

    local weapon_lbl = title_box:CreateOrGetControl("richtext", "weapon", 160, 10, 100, 20)
    weapon_lbl:SetText(current_lang == "Japanese" and "{ol}" .. "武器" or "{ol}" .. "weapons")
    weapon_lbl:AdjustFontSizeByWidth(100)

    local acc_lbl = title_box:CreateOrGetControl("richtext", "Accessory", 290, 10, 100, 20)
    acc_lbl:SetText(current_lang == "Japanese" and "{ol}" .. "アクセ" or "{ol}" .. "Accessory")

    local equip_x = 390
    local equip_labels = {ClMsg("Shirt"), ClMsg("Pants"), ClMsg("GLOVES"), ClMsg("BOOTS"),
                          (current_lang == "Japanese" and "その他" or "etc.")}
    for i = 0, 4 do
        local equip_lbl = title_box:CreateOrGetControl("richtext", "equip_text" .. i, equip_x, 10, 100, 20)
        equip_lbl:SetText("{ol}" .. equip_labels[i + 1])
        equip_lbl:AdjustFontSizeByWidth(100)
        equip_x = equip_x + 225
    end

    return title_box
end

function other_character_skill_list_frame_open(frame, ctrl, str, num)
    other_character_skill_list_save_enchant()
    local main_frame = ui.CreateNewFrame("notice_on_pc", addon_name_lower .. "new_frame", 0, 0, 70, 30)
    AUTO_CAST(main_frame)
    main_frame:SetSkinName("test_frame_midle_light")
    main_frame:SetLayerLevel(103)

    local title_box = other_character_skill_create_title_bar(main_frame)

    local main_gbox = main_frame:CreateOrGetControl("groupbox", "gbox", 5, 35, 1070, 280)
    AUTO_CAST(main_gbox)
    main_gbox:RemoveAllChild()
    main_gbox:SetSkinName("bg2")

    local current_lang = option.GetCurrentCountry()
    local all_skills = GetClassList("Skill")
    local y_pos = 10
    local char_count = 0
    local last_etc_x = 0
    for i, char_info in ipairs(g.characters) do
        local char_settings = g.settings.characters[char_info.name]
        if char_settings.hide ~= 1 or g.settings.hide == 0 then
            local job_list, level, last_job_id = GetJobListFromAdventureBookCharData(char_info.name)
            if type(_G["INDUN_LIST_VIEWER_ON_INIT"]) == "function" then
                local ilv_settings = _G["ADDONS"]["norisan"]["indun_list_viewer"].settings
                if ilv_settings[char_info.name] then
                    if ilv_settings[char_info.name].president_jobid ~= "" then
                        last_job_id = ilv_settings[char_info.name].president_jobid
                        ts(char_info.name, last_job_id)
                    end
                end
            end
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

            local gs_str = char_settings.gear_score ~= 0 and tostring(char_settings.gear_score) or "NoData"

            if type(_G["INSTANTCC_ON_INIT"]) == "function" then
                function other_character_skill_list_INSTANTCC_DO_CC(frame, ctrl, cid, layer)
                    INSTANTCC_DO_CC(cid, layer)
                end
                name_lbl:SetEventScript(ui.LBUTTONDOWN, "other_character_skill_list_INSTANTCC_DO_CC")
                name_lbl:SetEventScriptArgString(ui.LBUTTONDOWN, char_info.cid)
                name_lbl:SetEventScriptArgNumber(ui.LBUTTONDOWN, char_info.layer)
                name_lbl:SetTextTooltip(current_lang == "Japanese" and "{ol}GearScore: " .. gs_str .. "{nl} {nl}" ..
                                            "右クリック: 各キャラ装備詳細{nl}左クリック：キャラクターチェンジ" or
                                            "{ol}GearScore: " .. gs_str .. "{nl} {nl}" ..
                                            "Right click: Details of each character's equipment{nl}Left click: Character change")
            else
                name_lbl:SetTextTooltip(current_lang == "Japanese" and "{ol}GearScore: " .. gs_str .. "{nl} {nl}" ..
                                            "右クリック: 各キャラ装備詳細" or "{ol}GearScore: " .. gs_str ..
                                            "{nl} {nl}" .. "Right-click: Details of each character's equipment")
            end
            other_character_skill_list_create_weapon_slots(main_gbox, char_settings.equips, equips, i, y_pos)
            other_character_skill_list_create_armor_slots(main_gbox, char_settings.equips, equips, all_skills, i, y_pos)
            last_etc_x = other_character_skill_list_create_etc_slots(main_gbox, char_settings.equips, equips, i, y_pos)
            local hide_check_char = main_gbox:CreateOrGetControl('checkbox', "hide_check" .. i, last_etc_x, y_pos, 25,
                25)
            AUTO_CAST(hide_check_char)
            hide_check_char:SetCheck(char_settings.hide or 0)
            hide_check_char:SetEventScript(ui.LBUTTONDOWN, 'other_character_skill_list_display_check')
            hide_check_char:SetEventScriptArgString(ui.LBUTTONDOWN, char_info.name)
            hide_check_char:SetTextTooltip(current_lang == "Japanese" and "{ol}チェックすると非表示" or
                                               "{ol}Check to hide")

            y_pos = y_pos + 25
            char_count = char_count + 1
        end
    end

    local frame_height = char_count * 25
    main_frame:Resize(last_etc_x + 40, frame_height + 60)
    title_box:Resize(last_etc_x + 30, 40)
    main_gbox:Resize(last_etc_x + 30, frame_height + 20)

    local current_frame_w = main_frame:GetWidth()
    local map_frame = ui.GetFrame("map")
    local map_width = map_frame:GetWidth()
    main_frame:SetPos((map_width - current_frame_w) / 2, 0)
    main_frame:ShowWindow(1)
end

function other_character_skill_list_display_check(frame, ctrl, char_name, num)
    local ischeck = ctrl:IsChecked()
    if char_name == "" then
        g.settings.hide = ischeck
    else
        g.settings.characters[char_name].hide = ischeck
    end
    g.save_settings()
    other_character_skill_list_frame_open(frame, ctrl, "", num)
end

function other_character_skill_list_frame_close(frame, ctrl, str, num)
    local frame = ui.GetFrame(addon_name_lower .. "new_frame")
    frame:ShowWindow(0)
    other_character_skill_list_char_report_close()
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
--[[local title_box = main_frame:CreateOrGetControl("groupbox", "title", 0, 0, 1070, 40)
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

    local hide_check = title_box:CreateOrGetControl('checkbox', 'hide_check', 120, 0, 35, 35)
    AUTO_CAST(hide_check)
    hide_check:SetEventScript(ui.LBUTTONUP, 'other_character_skill_list_display_check')
    hide_check:SetTextTooltip(g.lang == "Japanese" and "{ol}チェックしたキャラを非表示" or
                                  "{ol}Hide Checked Characters")
    hide_check:SetCheck(g.settings.hide or 0)

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
    local equip_labels = {ClMsg("Shirt"), ClMsg("Pants"), ClMsg("GLOVES"), ClMsg("BOOTS"),
                          (current_lang == "Japanese" and "その他" or "etc.")}
    for i = 0, 4 do
        local equip_lbl = title_box:CreateOrGetControl("richtext", "equip_text" .. i, equip_x, 10, 100, 20)
        equip_lbl:SetText("{ol}" .. equip_labels[i + 1])
        equip_lbl:AdjustFontSizeByWidth(100)
        equip_x = equip_x + 225
    end]]
