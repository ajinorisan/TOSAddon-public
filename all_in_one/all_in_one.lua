local addon_name = "ALL_IN_ONE"
local addon_name_lower = string.lower(addon_name)
local author = "norisan"
local ver = "0.0.5"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addon_name] = _G["ADDONS"][author][addon_name] or {}
local g = _G["ADDONS"][author][addon_name]

local json = require("json")

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
    local folder = string.format("../addons/%s", addon_name_lower)
    local file_path = string.format("../addons/%s/mkdir.txt", addon_name_lower)
    create_folder(folder, file_path)
    local active_id = session.loginInfo.GetAID()
    local user_folder = string.format("../addons/%s/%s", addon_name_lower, active_id)
    local user_file_path = string.format("../addons/%s/%s/mkdir.txt", addon_name_lower, active_id)
    create_folder(user_folder, user_file_path)
end
g.mkdir_new_folder()

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

function g.setup_hook_before(origin_func_name, my_func_name)
    local previous_func = _G[origin_func_name]
    if not previous_func then
        return
    end
    _G[origin_func_name] = function(...)

        if _G[my_func_name] then
            _G[my_func_name](...)
        end
        return previous_func(...)
    end
end

function g.setup_hook_before_with_filter(origin_func_name, my_filter_func_name)
    local previous_func = _G[origin_func_name]
    if not previous_func then
        return
    end
    _G[origin_func_name] = function(...)
        if _G[my_filter_func_name] and _G[my_filter_func_name](...) then
            return
        end
        return previous_func(...)
    end
end

--[[function g.setup_hook_before(origin_func_name, my_func_name)
    g.FUNCS_BEFORE = g.FUNCS_BEFORE or {}
    if not g.FUNCS_BEFORE[origin_func_name] then
        g.FUNCS_BEFORE[origin_func_name] = _G[origin_func_name]
    end
    local previous_func = _G[origin_func_name]
    _G[origin_func_name] = function(...)
        if _G[my_func_name] then
            _G[my_func_name](...)
        end
        return previous_func(...)
    end
end

function g.setup_hook_before_with_filter(origin_func_name, my_filter_func_name)
    g.FUNCS_BEFORE = g.FUNCS_BEFORE or {}
    if not g.FUNCS_BEFORE[origin_func_name] then
        g.FUNCS_BEFORE[origin_func_name] = _G[origin_func_name]
    end
    local previous_func = _G[origin_func_name]
    if not previous_func then
        return
    end
    _G[origin_func_name] = function(...)

        if _G[my_filter_func_name] and _G[my_filter_func_name](...) then
            return
        end
        return previous_func(...)
    end
end]]

function g.load_json(path)
    local file = io.open(path, "r")
    if not file then
        return nil, "Error opening file: " .. path
    end
    local content = file:read("*all")
    file:close()
    if not content or content == "" then
        return nil, "File content is empty or could not be read: " .. path
    end
    if string.sub(content, 1, 3) == "\239\187\191" then
        content = string.sub(content, 4)
    end
    local success, result = pcall(json.decode, content)
    if success then
        return result, nil
    else
        return nil, result
    end
end

function g.save_json(path, tbl)
    local file = io.open(path, "w")
    local str = json.encode(tbl)
    file:write(str)
    file:close()
end

function g.get_map_type()
    local map_name = session.GetMapName()
    local map_cls = GetClass("Map", map_name)
    local map_type = map_cls.MapType
    return map_type
end

function g.debug_print_table(tbl, indent)
    indent = indent or ""
    for key, value in pairs(tbl) do
        local key_str = indent .. "[" .. tostring(key) .. "] ="
        if type(value) == "table" then
            print(key_str .. "{")
            g.debug_print_table(value, indent .. "  ")
            print(indent .. "}")
        else
            print(key_str .. tostring(value))
        end
    end
end

function g.log_to_file(message)
    local log_file_path = string.format('../addons/%s/debug_log.txt', addon_name_lower)
    local file, err = io.open(log_file_path, "a")
    if file then
        local timestamp = os.date("[%Y-%m-%d %H:%M:%S] ")
        file:write(timestamp .. tostring(message) .. "\n")
        file:close()
    end
end

g.active_id = session.loginInfo.GetAID()
g.settings_path = string.format("../addons/%s/%s/settings.json", addon_name_lower, g.active_id)
g.all_in_one = {{
    key = "bulk_sales",
    data = {
        use = 0,
        name = "Bulk Sales",
        frame_use = false,
        config_func = ""
    }
}, {
    key = "auto_map_change",
    data = {
        use = 0,
        name = "Auto Map Change",
        frame_use = false,
        config_func = ""
    }
}, {
    key = "ancient_auto_set",
    data = {
        use = 0,
        name = "Ancient Auto Set",
        frame_use = false,
        config_func = ""
    }
}, {
    key = "auto_pet_summon",
    data = {
        use = 0,
        name = "Auto Pet Summon",
        frame_use = false,
        config_func = ""
    }
}, {
    key = "acquire_relic_reward",
    data = {
        use = 0,
        name = "Acquire Relic Reward",
        frame_use = false,
        config_func = ""
    }
}, {
    key = "auto_repair",
    data = {
        use = 0,
        name = "Auto Repair",
        frame_use = true,
        config_func = "auto_repair_settings_frame_init"
    }
}, {
    key = "boss_direction",
    data = {
        use = 0,
        name = "Boss Direction",
        frame_use = true,
        config_func = "boss_direction_settings_frame_init"
    }
}, {
    key = "cupole_manager",
    data = {
        use = 0,
        name = "Cupole Manager",
        frame_use = false,
        config_func = ""
    }
}, {
    key = "dungeon_rp_charger",
    data = {
        use = 0,
        name = "Dungeon RP Charger",
        frame_use = false,
        config_func = ""
    }
}, {
    key = "guild_event_warp",
    data = {
        use = 0,
        name = "Guild Event Warp",
        frame_use = false,
        config_func = ""
    }
}, {
    key = "instant_cc",
    data = {
        use = 0,
        name = "Instant CC",
        frame_use = true,
        config_func = "instant_cc_settings_frame_init"
    }
}, {
    key = "job_change_helper",
    data = {
        use = 0,
        name = "Job Change Helper",
        frame_use = false,
        config_func = ""
    }
}, {
    key = "aethergem_manager",
    data = {
        use = 0,
        name = "Aethergem Manager",
        frame_use = false,
        config_func = ""
    }
}, {
    key = "party_marker",
    data = {
        use = 0,
        name = "Party Marker",
        frame_use = false,
        config_func = ""
    }
}, {
    key = "boss_gauge",
    data = {
        use = 0,
        name = "Boss Gauge",
        frame_use = false,
        config_func = ""
    }
}, {
    key = "always_status",
    data = {
        use = 0,
        name = "Always Status",
        frame_use = true,
        config_func = "always_status_info_setting"
    }
}, {
    key = "characters_item_serch",
    data = {
        use = 0,
        name = "Characters Item Serch",
        frame_use = true,
        config_func = "characters_item_serch_toggle_frame"
    }
}, {
    key = "continue_reinforce",
    data = {
        use = 0,
        name = "Continue Reinforce",
        frame_use = false,
        config_func = ""
    }
}, {
    key = "debuff_notice",
    data = {
        use = 0,
        name = "Debuff Notice",
        frame_use = false,
        config_func = ""
    }
}, {
    key = "easy_buff",
    data = {
        use = 0,
        name = "Easy Buff",
        frame_use = true,
        config_func = "easy_buff_config_frame"
    }
}, {
    key = "monster_kill_count",
    data = {
        use = 0,
        name = "Monster Kill Count",
        frame_use = true,
        config_func = "monster_kill_count_information_context"
    }
}, {
    key = "pick_item_tracker",
    data = {
        use = 0,
        name = "Pick Item Tracker",
        frame_use = false,
        config_func = ""
    }
}, {
    key = "lets_go_home",
    data = {
        use = 0,
        name = "Lets Go Home",
        frame_use = true,
        config_func = "lets_go_home_settings_frame"
    }
}, {
    key = "market_voucher",
    data = {
        use = 0,
        name = "Market Voucher",
        frame_use = false,
        config_func = ""
    }
}, {
    key = "monster_card_changer",
    data = {
        use = 0,
        name = "Monster Card Changer",
        frame_use = false,
        config_func = ""
    }
}, {
    key = "my_buffs_control",
    data = {
        use = 0,
        name = "My Buffs Control",
        frame_use = true,
        config_func = "my_buffs_control_setting_menu"
    }
}, {
    key = "quickslot_operate",
    data = {
        use = 0,
        name = "Quickslot Operate",
        frame_use = false,
        config_func = ""
    }
}, {
    key = "relic_change",
    data = {
        use = 0,
        name = "Relic Change",
        frame_use = false,
        config_func = ""
    }
}, {
    key = "revival_timer",
    data = {
        use = 0,
        name = "Revival Timer",
        frame_use = true,
        config_func = "revival_timer_setting"
    }
}}

g.all_in_one_trans = {
    ["bulk_sales"] = {
        ja = "{ol}雑貨屋で大量販売出来るスロットセットを提供",
        etc = "{ol}Provide a set of slots that can be sold in bulk{nl}at a grocery store"
    },
    ["auto_map_change"] = {
        ja = "{ol}マップ移動時のダイアログ選択を自動化",
        etc = "{ol}Automate Dialogue Selection during Map Movement"
    },
    ["ancient_auto_set"] = {
        ja = "{ol}アシスターセットをキャラ毎に自動で付け替えます{nl}事前にアシスター保管箱で設定必要",
        etc = "{ol}Automatically switch Ancient Sets per character{nl}Requires prior setup in the Ancient Storage"
    },
    ["auto_pet_summon"] = {
        ja = "{ol}キャラ毎に最後に連れていたペットを自動で召喚します",
        etc = "{ol}Automatically summon the last-used pet for each character"
    },
    ["acquire_relic_reward"] = {
        ja = "{ol}ebisukeさん作成{nl}自動でレリッククエスト報酬を受け取ります{nl}マップ切替時などにゲームがクラッシュするバグ修正済",
        etc = "{ol}Created by ebisuke{nl}Automatically accepts Relic Quest rewards{nl}Fixed a bug causing the game to crash during map transitions"
    },
    ["auto_repair"] = {
        ja = "{ol}装備の耐久を監視して30%未満になると緊急修理キットを使用して自動で修理します{nl}女神の証商店からの自動補充機能付き",
        etc = "{ol}Monitors equipment durability and automatically repairs it using an Emergency Repair Kit{nl}when durability drops below 30%{nl}Includes an automatic resupply function from the Goddess's Token Shop"
    },
    ["boss_direction"] = {
        ja = "{ol}ボスが向いている方向を矢印でお知らせ",
        etc = "{ol}Arrow indicates the direction the boss is facing"
    },
    ["cupole_manager"] = {
        ja = "{ol}クポル未登録キャラでも自動で呼び出します",
        etc = "{ol}Automatically summons the Cupole{nl}even for characters without a registered one"
    },
    ["dungeon_rp_charger"] = {
        ja = "{ol}meldavyさん作成{nl}聖域で自動でレリックポイントを補充します",
        etc = "{ol}Created by meldavy{nl}Automatically restocks Relic Points in Sanctuary"
    },
    ["guild_event_warp"] = {
        ja = "{ol}画面右上の小さいボタンから封鎖戦マップの1チャンネルにワープ",
        etc = "{ol}Warp to Channel 1 of the Blockade Battle Map{nl}from the button in the upper right corner of the screen"
    },
    ["instant_cc"] = {
        ja = "{ol}ebisukeさん作成{nl}キャラクターチェンジを簡易にします",
        etc = "{ol}Created by ebisuke{nl}Simplifies character changing"
    },
    ["job_change_helper"] = {
        ja = "{ol}装備解除など、転職を簡易にします",
        etc = "{ol}Simplifies job change, such as unequipping gear"
    },
    ["aethergem_manager"] = {
        ja = "{ol}エーテルジェムの付け替えを自動化{nl}キャラ毎の設定が必要です",
        etc = "{ol}Automate Aethergem equipping/swapping{nl}Settings are required for each character"
    },
    ["party_marker"] = {
        ja = "{ol}Charbonさん作成{nl}パーティーメンバーの頭上にアイコンを付けます",
        etc = "{ol}Created by Charbon{nl}Add an icon above the party members' heads"
    },
    ["boss_gauge"] = {
        ja = "{ol}ボスゲージにスタン値とシールド値を表示します",
        etc = "{ol}Display Stun value and Shield value on the boss gauge"
    },
    ["always_status"] = {
        ja = "{ol}ステータスを常に表示します",
        etc = "{ol}Always display status"
    },
    ["characters_item_serch"] = {
        ja = "{ol}各キャラクターのアイテム検索{nl}インベントリボタン右クリックでも作動",
        etc = "{ol}Item search for each character{nl}Also activates by right-clicking the Inventory button"
    },
    ["continue_reinforce"] = {
        ja = "{ol}ゴッデス装備連続強化",
        etc = "{ol}Goddes equipment continuous reinforcement"
    },
    ["debuff_notice"] = {
        ja = "{ol}自分が与えたデバフを見やすく表示",
        etc = "{ol}Clearly display the debuffs inflicted by oneself"
    },
    ["easy_buff"] = {
        ja = "{ol}Kiicchanさん作成{nl}各種商店でバフ自動付与",
        etc = "{olCreated by Kiicchan{nl}Automatic buff application at various shops"
    },
    ["monster_kill_count"] = {
        ja = "{ol}フィールド狩りで倒したモンスターをカウント{nl}アイテムドロップ情報取得",
        etc = "{ol}Count monsters defeated in field hunting{nl}Acquire item drop information"
    },
    ["pick_item_tracker"] = {
        ja = "{ol}アイテム取得情報表示",
        etc = "{ol}Display item acquisition information"
    },
    ["lets_go_home"] = {
        ja = "{ol}ホームタウンのホームチャンネルにワープします",
        etc = "{ol}Warp to the hometown's home channel"
    },
    ["market_voucher"] = {
        ja = "{ol}マーケットでの取引履歴表示",
        etc = "{olShow market trade history"
    },
    ["monster_card_changer"] = {
        ja = "{ol}モンスターカードプリセットを使いやすくします{nl}カード自動着脱、自動搬出入",
        etc = "{ol}Improve usability of monster card presets{nl}Automatic card equipping/unequipping, automatic transfer in/out"
    },
    ["my_buffs_control"] = {
        ja = "{ol}バフ欄を移動可能にして、選択したバフを非表示にします{nl}街では動作しません",
        etc = "{ol}buff panel movable and hide selected buffs{nl}Does not operate in town"
    },
    ["quickslot_operate"] = {
        ja = "{ol}クイックスロットの女神ポーションをレイド毎に付け替えます{nl}ストレートモード、保存、読込機能もあります",
        etc = "{ol}Change the Goddess Potion in the quick slot for each raid{nl}Straight mode, save, and load functions are also available"
    },
    ["relic_change"] = {
        ja = "{ol}レリックシアンジェム付替えを簡易に",
        etc = "{ol}Simplify relic Cyan Gem swapping"
    },
    ["revival_timer"] = {
        ja = "{ol}普通のタイマー",
        etc = "{ol}Normal timer"
    }
}

function all_in_one_save_settings()
    g.save_json(g.settings_path, g.settings)
end

function all_in_one_load_settings()
    local settings = g.load_json(g.settings_path)
    local changed = false
    if not settings then
        settings = {}
        changed = true
    end
    for _, entry in ipairs(g.all_in_one) do
        local key = entry.key
        local default_data = entry.data
        if not settings[key] then
            settings[key] = default_data
            changed = true
        elseif type(settings[key]) == "table" and type(default_data) == "table" then
            for sub_key, sub_default_value in pairs(default_data) do
                if settings[key][sub_key] == nil then
                    settings[key][sub_key] = sub_default_value
                    changed = true
                end
            end
        end
    end
    g.settings = settings
    if changed then
        all_in_one_save_settings()
    end
end

function ALL_IN_ONE_ON_INIT(addon, frame)
    g.addon = addon
    g.frame = frame
    g.lang = option.GetCurrentCountry()
    g.cid = session.GetMySession():GetCID()
    g.login_name = session.GetMySession():GetPCApc():GetName()
    g.map_name = session.GetMapName()
    g.map_id = session.GetMapID()
    g.current_channel = session.loginInfo.GetChannel() -- 0が1ch
    g.REGISTER = {}
    addon:RegisterMsg('GAME_START', 'all_in_one_GAME_START')
    addon:RegisterMsg('GAME_START_3SEC', 'all_in_one_GAME_START_3SEC')
end

function all_in_one_GAME_START(frame, msg)
    all_in_one_load_settings()
    _G["norisan"] = _G["norisan"] or {}
    _G["norisan"]["MENU"] = _G["norisan"]["MENU"] or {}
    local menu_data = {
        name = "All in one",
        icon = "sysmenu_coll",
        func = "all_in_one_frame_init",
        image = ""
    }
    _G["norisan"]["MENU"][addon_name] = menu_data
    local frame_name = _G["norisan"]["MENU"].frame_name
    local menu_frame = ui.GetFrame(frame_name)
    if menu_frame and frame_name ~= "norisan_menu_frame" then
        ui.DestroyFrame(frame_name)
    end
    frame_name = "norisan_menu_frame"
    menu_frame = ui.GetFrame(frame_name)
    if not menu_frame then
        _G["norisan"]["MENU"].frame_name = frame_name
        g.norisan_menu_create_frame()
    elseif menu_frame:IsVisible() == 0 then
        menu_frame:ShowWindow(1)
    end
    local all_in_one = ui.GetFrame("all_in_one")
    local update_frames_timer = all_in_one:CreateOrGetControl("timer", "update_frames_timer", 0, 0)
    AUTO_CAST(update_frames_timer)
    update_frames_timer:SetUpdateScript("all_in_one_update_frames")
    update_frames_timer:Start(0.5)
end

function all_in_one_update_frames(all_in_one)
    local always_status = ui.GetFrame(addon_name_lower .. "always_status")
    if always_status and always_status:IsVisible() == 0 then
        AUTO_CAST(always_status)
        always_status:ShowWindow(1)
    end
    local pick_item_tracker = ui.GetFrame(addon_name_lower .. "pick_item_tracker")
    if pick_item_tracker and pick_item_tracker:IsVisible() == 0 then
        if g.get_map_type() ~= "City" and g.get_map_type() ~= "Instance" then
            AUTO_CAST(pick_item_tracker)
            pick_item_tracker:ShowWindow(1)
        end
    end
    local monster_kill_count = ui.GetFrame(addon_name_lower .. "monster_kill_count")
    if monster_kill_count and monster_kill_count:IsVisible() == 0 then
        AUTO_CAST(monster_kill_count)
        monster_kill_count:ShowWindow(1)
    end
    local debuff_notice = ui.GetFrame(addon_name_lower .. "debuff_notice")
    if debuff_notice and debuff_notice:IsVisible() == 0 then
        AUTO_CAST(debuff_notice)
        debuff_notice:ShowWindow(1)
    end
    local guild_event_warp = ui.GetFrame(addon_name_lower .. "guild_event_warp")
    if guild_event_warp and guild_event_warp:IsVisible() == 0 then
        AUTO_CAST(guild_event_warp)
        guild_event_warp:ShowWindow(1)
    end
    local lets_go_home = ui.GetFrame(addon_name_lower .. "lets_go_home")
    if lets_go_home and lets_go_home:IsVisible() == 0 then
        AUTO_CAST(lets_go_home)
        lets_go_home:ShowWindow(1)
    end
    local relic_change = ui.GetFrame(addon_name_lower .. "relic_change")
    if relic_change and relic_change:IsVisible() == 0 then
        AUTO_CAST(relic_change)
        relic_change:ShowWindow(1)
    end
end

function all_in_one_list_close(frame)
    local frame_name = frame:GetName()
    ui.DestroyFrame(frame_name)
    local boss_direction_settings = ui.GetFrame("boss_direction_settings")
    if boss_direction_settings then
        ui.DestroyFrame("boss_direction_settings")
    end
    local auto_repair_settings = ui.GetFrame("auto_repair_settings")
    if auto_repair_settings then
        ui.DestroyFrame("auto_repair_settings")
    end
    local instant_cc_settings = ui.GetFrame("instant_cc_settings")
    if instant_cc_settings then
        ui.DestroyFrame("instant_cc_settings")
    end
    local my_buffs_control_setting = ui.GetFrame(addon_name_lower .. "my_buffs_control_setting")
    if my_buffs_control_setting then
        ui.DestroyFrame(addon_name_lower .. "my_buffs_control_setting")
    end
    local revival_timer_setting = ui.GetFrame(addon_name_lower .. "revival_timer_setting")
    if revival_timer_setting then
        ui.DestroyFrame(addon_name_lower .. "revival_timer_setting")
    end
end

function all_in_one_frame_init()
    local list_frame_name = addon_name_lower .. "list_frame"
    local list_frame = ui.CreateNewFrame("notice_on_pc", list_frame_name, 0, 0, 10, 10)
    AUTO_CAST(list_frame)
    list_frame:SetSkinName("test_frame_low")
    list_frame:SetTitleBarSkin("None")
    list_frame:SetLayerLevel(80)
    local title = list_frame:CreateOrGetControl('richtext', 'title', 20, 10, 10, 30)
    AUTO_CAST(title)
    title:SetText("{#000000}{s25}All in One")
    local close_button = list_frame:CreateOrGetControl('button', 'close_button', 0, 0, 20, 20)
    AUTO_CAST(close_button)
    close_button:SetImage("testclose_button")
    close_button:SetGravity(ui.RIGHT, ui.TOP)
    close_button:SetEventScript(ui.LBUTTONUP, "all_in_one_list_close")
    local list_gb = list_frame:CreateOrGetControl("groupbox", "list_gb", 10, 40, 0, 0)
    AUTO_CAST(list_gb)
    list_gb:SetSkinName("bg")
    list_gb:RemoveAllChild()
    list_frame:ShowWindow(1)
    local col1_x = 20
    local row_height = 40
    local max_width1 = 0
    local max_width2 = 0
    for i, entry in ipairs(g.all_in_one) do
        local name = entry.data.name
        local current_y = (i <= 15) and (i - 1) * row_height or (i - 16) * row_height
        local name_text = list_gb:CreateOrGetControl('richtext', 'name_text' .. i, col1_x, current_y + 10, 10, 30)
        AUTO_CAST(name_text)
        name_text:SetText("{ol}{s20}" .. name)
        if i <= 15 then
            max_width1 = math.max(max_width1, name_text:GetWidth())
        else
            max_width2 = math.max(max_width2, name_text:GetWidth())
        end
    end
    local col2_x = col1_x + max_width1 + 180
    for i, entry in ipairs(g.all_in_one) do
        local child_addon_name = entry.key
        local data = entry.data
        local use = g.settings[child_addon_name].use
        local buttons_x, current_y
        if i <= 15 then
            buttons_x = col1_x + max_width1 + 25
            current_y = (i - 1) * row_height
        else
            local name_text = GET_CHILD(list_gb, 'name_text' .. i)
            name_text:SetPos(col2_x, name_text:GetY())
            buttons_x = col2_x + max_width2 + 25
            current_y = (i - 16) * row_height
        end
        local use_toggle = list_gb:CreateOrGetControl('picture', "use_toggle" .. i, buttons_x, current_y + 10, 60, 25)
        AUTO_CAST(use_toggle)
        use_toggle:SetImage(use == 1 and "test_com_ability_on" or "test_com_ability_off")
        use_toggle:SetEnableStretch(1)
        use_toggle:EnableHitTest(1)
        use_toggle:SetTextTooltip("{ol}ON/OFF")
        use_toggle:SetEventScript(ui.LBUTTONUP, "all_in_one_toggle_addons")
        use_toggle:SetEventScriptArgString(ui.LBUTTONUP, child_addon_name)
        if data.frame_use then
            local config_btn = list_gb:CreateOrGetControl('button', 'config_btn' .. i, buttons_x + 65, current_y + 10,
                25, 25)
            AUTO_CAST(config_btn)
            config_btn:SetSkinName("None")
            config_btn:SetTextTooltip(g.lang == "Japanese" and "{ol}設定フレーム呼出し" or
                                          "Call Settings Frame")
            config_btn:SetText("{img config_button_normal 25 25}")
            if data.config_func and data.config_func ~= "" then
                config_btn:SetEventScript(ui.LBUTTONUP, data.config_func)
            end
        end
        local help_btn = list_gb:CreateOrGetControl('button', 'help_btn' .. i, buttons_x + 100, current_y + 5, 40, 30)
        AUTO_CAST(help_btn)
        help_btn:SetText("{ol}{img question_mark 20 15}")
        help_btn:SetTextTooltip(g.lang == "Japanese" and g.all_in_one_trans[child_addon_name].ja or
                                    g.all_in_one_trans[child_addon_name].etc)
        help_btn:SetSkinName("test_pvp_btn")
    end
    local total_width = col2_x + max_width2 + 200
    local total_rows = 15
    local total_height = total_rows * row_height + 70
    list_frame:Resize(total_width, total_height)
    list_gb:Resize(list_frame:GetWidth() - 20, list_frame:GetHeight() - 50)
    local map_frame = ui.GetFrame("map")
    local height = map_frame:GetHeight()
    list_frame:SetPos(310, (height / 2) - (list_frame:GetHeight() / 2))
end

function all_in_one_toggle_addons(list_gb, use_toggle, child_addon_name, num)
    if g.settings[child_addon_name].use == 1 then
        g.settings[child_addon_name].use = 0
        ui.SysMsg(g.lang == "Japanese" and g.settings[child_addon_name].name .. " 無効にしました" or
                      g.settings[child_addon_name].name .. " Disabled")
    else
        g.settings[child_addon_name].use = 1
        ui.SysMsg(g.lang == "Japanese" and g.settings[child_addon_name].name .. " 有効にしました" or
                      g.settings[child_addon_name].name .. " Enabled")
        if child_addon_name == "auto_pet_sumoon" then
            auto_pet_summon_on_init()
        end
    end
    if child_addon_name == "job_change_helper" then
        job_change_helper_on_init()
    elseif child_addon_name == "acquire_relic_reward" then
        acquire_relic_reward_on_init()
    elseif child_addon_name == "ancient_auto_set" then
        ancient_auto_set_on_init()
    elseif child_addon_name == "aethergem_manager" then -- 
        aethergem_manager_on_init()
    elseif child_addon_name == "party_marker" then
        party_marker_on_init()
    elseif child_addon_name == "always_status" then
        always_status_on_init() --
    elseif child_addon_name == "characters_item_serch" then
        characters_item_serch_on_init()
    elseif child_addon_name == "continue_reinforce" then
        continue_reinforce_on_init()
    elseif child_addon_name == "monster_kill_count" then
        monster_kill_count_on_init(true)
    elseif child_addon_name == "pick_item_tracker" then
        pick_item_tracker_on_init()
    elseif child_addon_name == "lets_go_home" then
        lets_go_home_on_init()
    elseif child_addon_name == "monster_card_changer" then
        monster_card_changer_on_init()
    elseif child_addon_name == "my_buffs_control" then
        my_buffs_control_on_init()
    elseif child_addon_name == "quickslot_operate" then
        quickslot_operate_on_init()
    elseif child_addon_name == "relic_change" then
        relic_change_on_init()
    elseif child_addon_name == "revival_timer" then
        revival_timer_on_init()
    end
    all_in_one_save_settings()
    all_in_one_frame_init()
end

function all_in_one_GAME_START_3SEC(frame, msg)
    local error_count = 0
    local function safe_call(func, name)
        if type(func) == "function" then
            local success, err = pcall(func)
            if not success then
                error_count = error_count + 1
                ts(string.format("Error during on_init of '%s': %s", name, tostring(err)))
            end
        else
            error_count = error_count + 1
            ts(string.format("Error: Function '%s_on_init' not found.", name))
        end
    end
    safe_call(bulk_sales_on_init, "bulk_sales")
    safe_call(auto_map_change_on_init, "auto_map_change")
    safe_call(ancient_auto_set_on_init, "ancient_auto_set")
    safe_call(auto_pet_summon_on_init, "auto_pet_summon")
    safe_call(acquire_relic_reward_on_init, "acquire_relic_reward")
    safe_call(auto_repair_on_init, "auto_repair")
    safe_call(boss_direction_on_init, "boss_direction")
    safe_call(cupole_manager_on_init, "cupole_manager")
    safe_call(dungeon_rp_charger_on_init, "dungeon_rp_charger")
    safe_call(guild_event_warp_on_init, "guild_event_warp")
    safe_call(instant_cc_on_init, "instant_cc")
    safe_call(job_change_helper_on_init, "job_change_helper")
    safe_call(aethergem_manager_on_init, "aethergem_manager")
    safe_call(party_marker_on_init, "party_marker")
    safe_call(boss_gauge_on_init, "boss_gauge")
    safe_call(always_status_on_init, "always_status")
    safe_call(characters_item_serch_on_init, "characters_item_serch")
    safe_call(continue_reinforce_on_init, "continue_reinforce")
    safe_call(debuff_notice_on_init, "debuff_notice")
    safe_call(easy_buff_on_init, "easy_buff")
    safe_call(monster_kill_count_on_init, "monster_kill_count")
    safe_call(pick_item_tracker_on_init, "pick_item_tracker")
    safe_call(lets_go_home_on_init, "lets_go_home")
    safe_call(market_voucher_on_init, "market_voucher")
    safe_call(monster_card_changer_on_init, "monster_card_changer")
    safe_call(my_buffs_control_on_init, "my_buffs_control")
    safe_call(quickslot_operate_on_init, "quickslot_operate")
    safe_call(relic_change_on_init, "relic_change")
    safe_call(revival_timer_on_init, "revival_timer")
    if error_count == 0 then
        ts("All add-ons initialized successfully.")
    else
        ts(string.format("%d add-on(s) failed to initialize. Please check the error messages above.", error_count))
    end
end
-- revival_timer ここから
g.revival_timer_path = string.format("../addons/%s/%s/revival_timer.json", addon_name_lower, g.active_id)
function revival_timer_save_settings()
    g.save_json(g.revival_timer_path, g.revival_timer_settings)
end

function revival_timer_load_settings()
    local settings = g.load_json(g.revival_timer_path)
    if not settings then
        settings = {
            x = 400,
            y = 300,
            set_second = 60,
            set_text = "",
            ptchat = false,
            nicochat = false,
            shortcut = false,
            shortcut_l = false
        }
    end
    g.revival_timer_settings = settings
    revival_timer_save_settings()
end

function revival_timer_on_init()
    -- if not g.revival_timer_settings then
    revival_timer_load_settings()
    -- end
    if g.settings.revival_timer.use == 1 then
        revival_timer_frame_init()
    else
        local all_in_one = ui.GetFrame("all_in_one")
        all_in_one:RemoveChild("revival_timer_keypress")
        local revival_timer = ui.GetFrame(addon_name_lower .. "revival_timer")
        revival_timer:ShowWindow(0)
    end
    g.setup_hook_and_event(g.addon, "EXEC_CHATMACRO", "revival_timer_EXEC_CHATMACRO", false)
end

function revival_timer_frame_init()
    local revival_timer = ui.CreateNewFrame("notice_on_pc", addon_name_lower .. "revival_timer", 0, 0, 0, 0)
    AUTO_CAST(revival_timer)
    revival_timer:RemoveAllChild()
    revival_timer:SetPos(g.revival_timer_settings.x, g.revival_timer_settings.y)
    revival_timer:SetSkinName("bg2")
    revival_timer:SetLayerLevel(61)
    revival_timer:Resize(160, 130)
    revival_timer:EnableHittestFrame(1)
    revival_timer:EnableMove(1)
    revival_timer:SetEventScript(ui.LBUTTONUP, "revival_timer_end_drag")
    local close = revival_timer:CreateOrGetControl("button", "close", 0, 0, 30, 30)
    AUTO_CAST(close)
    close:SetImage("testclose_button")
    close:SetGravity(ui.RIGHT, ui.TOP)
    close:SetEventScript(ui.LBUTTONUP, "revival_timer_frame_close")
    local info_text = revival_timer:CreateOrGetControl('richtext', 'info_text', 10, 10, 50, 20)
    AUTO_CAST(info_text)
    local timer_text = revival_timer:CreateOrGetControl('richtext', 'timer_text', 15, 30, 50, 20)
    AUTO_CAST(timer_text)
    local loop_text = revival_timer:CreateOrGetControl('richtext', 'loop_text', 10, 90, 50, 20)
    AUTO_CAST(loop_text)
    local all_in_one = ui.GetFrame("all_in_one")
    all_in_one:SetVisible(1)
    local revival_timer_keypress = all_in_one:CreateOrGetControl("timer", "revival_timer_keypress", 0, 0)
    AUTO_CAST(revival_timer_keypress)
    revival_timer_keypress:SetUpdateScript("revival_timer_keypress")
    revival_timer_keypress:Start(0.1)
    g.revival_timer_last_keypress = 0
end

function revival_timer_frame_close(frame)
    if frame:GetName() == addon_name_lower .. "revival_timer_setting" then
        ui.DestroyFrame(frame:GetName())
    else
        frame:ShowWindow(0)
        frame:SetPos(g.revival_timer_settings.x, g.revival_timer_settings.y)
    end
end

function revival_timer_setting()
    local list_frame = ui.GetFrame(addon_name_lower .. "list_frame")
    local setting = ui.CreateNewFrame("notice_on_pc", addon_name_lower .. "revival_timer_setting", 0, 0, 0, 0)
    AUTO_CAST(setting)
    setting:Resize(240, 420)
    setting:SetPos(list_frame:GetX() + list_frame:GetWidth(), list_frame:GetY())
    setting:SetSkinName("test_frame_low")
    setting:EnableHittestFrame(1)
    setting:EnableHitTest(1)
    setting:SetLayerLevel(999)
    setting:RemoveAllChild()
    local title_text = setting:CreateOrGetControl('richtext', 'title_text', 20, 15, 50, 30)
    AUTO_CAST(title_text)
    title_text:SetText("{ol}Lets Go Home Config")
    local close = setting:CreateOrGetControl("button", "close", 0, 0, 20, 20)
    AUTO_CAST(close)
    close:SetImage("testclose_button")
    close:SetGravity(ui.RIGHT, ui.TOP)
    close:SetEventScript(ui.LBUTTONUP, "revival_timer_frame_close")
    local gbox = setting:CreateOrGetControl("groupbox", "gbox", 10, 40, setting:GetWidth() - 20,
        setting:GetHeight() - 50)
    AUTO_CAST(gbox)
    gbox:SetSkinName("test_frame_midle_light")
    local info_text = gbox:CreateOrGetControl('richtext', 'info_text', 10, 10, 50, 20)
    AUTO_CAST(info_text)
    info_text:SetText(g.lang == "Japanese" and "{ol}お知らせメッセージ" or "{ol}Notice Text")
    local info_edit = gbox:CreateOrGetControl('edit', 'info_edit', 10, 30, 140, 30)
    AUTO_CAST(info_edit)
    info_edit:SetFontName("white_16_ol")
    info_edit:SetTextAlign("center", "center")
    info_edit:SetText("{ol}" .. g.revival_timer_settings.set_text)
    info_edit:SetEventScript(ui.ENTERKEY, "revival_timer_edit_save")
    local set_second = gbox:CreateOrGetControl('richtext', 'set_second', 10, 65, 50, 20)
    AUTO_CAST(set_second)
    set_second:SetText(g.lang == "Japanese" and "{ol}秒数設定" or "{ol}Set Seconds")
    local set_second_edit = gbox:CreateOrGetControl('edit', 'set_second_edit', 10, 85, 80, 30)
    AUTO_CAST(set_second_edit)
    set_second_edit:SetFontName("white_16_ol")
    set_second_edit:SetTextAlign("center", "center")
    set_second_edit:SetNumberMode(1)
    set_second_edit:SetText("{ol}" .. g.revival_timer_settings.set_second)
    set_second_edit:SetEventScript(ui.ENTERKEY, "revival_timer_edit_save")
    local with_ptchat = gbox:CreateOrGetControl('checkbox', "with_ptchat", 10, 120, 30, 30)
    AUTO_CAST(with_ptchat)
    with_ptchat:SetCheck(g.revival_timer_settings.ptchat and 1 or 0)
    with_ptchat:SetEventScript(ui.LBUTTONDOWN, 'revival_timer_checkbox_save')
    with_ptchat:SetText(g.lang == "Japanese" and "{ol}PTチャット表示" or "{ol}Show PT Chat")
    local nicochat = gbox:CreateOrGetControl('checkbox', "nicochat", 10, 150, 30, 30)
    AUTO_CAST(nicochat)
    nicochat:SetCheck(g.revival_timer_settings.nicochat and 1 or 0)
    nicochat:SetEventScript(ui.LBUTTONDOWN, 'revival_timer_checkbox_save')
    nicochat:SetText(g.lang == "Japanese" and "{ol}ニコチャット表示" or "{ol}Show Nico Chat")
    local short_cut = gbox:CreateOrGetControl('checkbox', "short_cut", 10, 180, 30, 30)
    AUTO_CAST(short_cut)
    short_cut:SetCheck(g.revival_timer_settings.shortcut and 1 or 0)
    short_cut:SetEventScript(ui.LBUTTONDOWN, 'revival_timer_checkbox_save')
    short_cut:SetText(g.lang == "Japanese" and "{ol}ショートカット使用" .. "{nl}{#FFD700}(Right ALT)" or
                          "{ol}Use shortcut" .. "{nl}{#FFD700}(Right ALT)")
    local short_cut_l = gbox:CreateOrGetControl('checkbox', "short_cut_l", 10, 220, 30, 30)
    AUTO_CAST(short_cut_l)
    short_cut_l:SetCheck(g.revival_timer_settings.shortcut_l and 1 or 0)
    short_cut_l:SetEventScript(ui.LBUTTONDOWN, 'revival_timer_checkbox_save')
    short_cut_l:SetText(g.lang == "Japanese" and "{ol}ショートカット使用" .. "{nl}{#FFD700}(Left ALT)" or
                            "{ol}Use shortcut" .. "{nl}{#FFD700}(Left ALT)")
    local show_timer = gbox:CreateOrGetControl("button", "show_timer", 50, 270, 100, 40)
    AUTO_CAST(show_timer)
    show_timer:SetText(g.lang == "Japanese" and "{ol}テスト表示" or "{ol}Test Show")
    show_timer:SetEventScript(ui.LBUTTONUP, "revival_timer_test_show")
    show_timer:SetEventScriptArgString(ui.LBUTTONUP, "test")
    local notice = gbox:CreateOrGetControl('richtext', 'notice', 10, 320, 100, 20)
    AUTO_CAST(notice)
    notice:SetText(g.lang == "Japanese" and
                       "{ol}スタートと非表示は{nl}チャットコマンド{#FFD700}'/rtimer'" or
                       "{ol}Start and hide with the{nl}chat command{#FFD700}'/rtimer'")
    setting:ShowWindow(1)
end

function revival_timer_edit_save(frame, ctrl)
    local ctrl_name = ctrl:GetName()
    if ctrl_name == "info_edit" then
        g.revival_timer_settings.set_text = ctrl:GetText()
    elseif ctrl_name == "set_second_edit" then
        g.revival_timer_settings.set_second = tonumber(ctrl:GetText())
    end
    revival_timer_save_settings()
    revival_timer_setting()
end

function revival_timer_checkbox_save(frame, ctrl)
    local ctrl_name = ctrl:GetName()
    local is_check = ctrl:IsChecked()
    if ctrl_name == "with_ptchat" then
        g.revival_timer_settings.ptchat = is_check == 1 and true or false
    elseif ctrl_name == "nicochat" then
        g.revival_timer_settings.nicochat = is_check == 1 and true or false
    elseif ctrl_name == "short_cut" then
        g.revival_timer_settings.shortcut = is_check == 1 and true or false
    elseif ctrl_name == "short_cut_l" then
        g.revival_timer_settings.shortcut_l = is_check == 1 and true or false
    end
    revival_timer_save_settings()
end

function revival_timer_test_show(frame)
    local revival_timer = ui.GetFrame(addon_name_lower .. "revival_timer")
    revival_timer:SetPos(1000, 30)
    g.revival_timer_start_time = imcTime.GetAppTimeMS()
    g.revival_timer_announced = 0
    local revival_timer_timer = revival_timer:CreateOrGetControl("timer", "revival_timer_timer", 0, 0)
    AUTO_CAST(revival_timer_timer)
    revival_timer_timer:SetUpdateScript("revival_timer_update")
    revival_timer_timer:Start(0.1)
    revival_timer:ShowWindow(1)
    revival_timer:RunUpdateScript("revival_timer_frame_close", 10.0)
end

function revival_timer_EXEC_CHATMACRO(my_frame, my_msg)
    local index = g.get_event_args(my_msg)
    if g.settings.revival_timer.use == 0 then
        g.FUNCS["EXEC_CHATMACRO"](index)
        return
    end
    local macro = GET_CHAT_MACRO(index)
    if not macro then
        return
    end
    local pose_cls = GetClassByType('Pose', macro.poseID)
    if pose_cls then
        control.Pose(poseCls.ClassName)
    end
    if macro.macro == "" then
        return
    end
    local msg = macro.macro
    if string.find(msg, "/rtimer", 1, true) then
        local revival_timer = ui.GetFrame(addon_name_lower .. "revival_timer")
        if revival_timer:IsVisible() == 1 then
            revival_timer:ShowWindow(0)
            return
        else
            g.revival_timer_start_time = imcTime.GetAppTimeMS()
            g.revival_timer_announced = 0
            local revival_timer_timer = revival_timer:CreateOrGetControl("timer", "revival_timer_timer", 0, 0)
            AUTO_CAST(revival_timer_timer)
            revival_timer_timer:SetUpdateScript("revival_timer_update")
            revival_timer_timer:Start(0.1)
            revival_timer:ShowWindow(1)
        end
    end
    ui.Chat(REPLACE_EMOTICON(macro.macro))
end

function revival_timer_keypress(all_in_one)
    if not g.revival_timer_settings.shortcut and not g.revival_timer_settings.shortcut_l then
        return
    end
    local cool_down = 200 -- 200ミリ秒
    local now = imcTime.GetAppTimeMS()
    if now - g.revival_timer_last_keypress < cool_down then
        return
    end
    if (1 == keyboard.IsKeyPressed("RALT") and g.revival_timer_settings.shortcut) or
        (1 == keyboard.IsKeyPressed("LALT") and g.revival_timer_settings.shortcut_l) then
        g.revival_timer_last_keypress = now
        local revival_timer = ui.GetFrame(addon_name_lower .. "revival_timer")
        if revival_timer:IsVisible() == 0 then
            g.revival_timer_start_time = imcTime.GetAppTimeMS()
            g.revival_timer_announced = 0
            local revival_timer_timer = revival_timer:CreateOrGetControl("timer", "revival_timer_timer", 0, 0)
            AUTO_CAST(revival_timer_timer)
            revival_timer_timer:SetUpdateScript("revival_timer_update")
            revival_timer_timer:Start(0.1)
            revival_timer:ShowWindow(1)
        else
            revival_timer:ShowWindow(0)
        end
    end
end

function revival_timer_update(revival_timer, revival_timer_timer)
    local elapsed_ms = imcTime.GetAppTimeMS() - g.revival_timer_start_time
    local remaining_s = g.revival_timer_settings.set_second - math.floor(elapsed_ms / 1000)
    if remaining_s < 0 then
        revival_timer_loop_timer()
        return
    end
    local info_text = GET_CHILD(revival_timer, "info_text")
    info_text:SetText("{ol}{#FF0000}{s20}" .. g.revival_timer_settings.set_text)
    local loop_text = GET_CHILD(revival_timer, "loop_text")
    local m = math.floor((g.revival_timer_settings.set_second / 60) % 60)
    local s = math.floor(g.revival_timer_settings.set_second % 60)
    loop_text:SetText("{ol}Set Time : " .. string.format("%02d:%02d{/}", m, s))
    local timer_text = GET_CHILD(revival_timer, "timer_text")
    local m = math.floor((remaining_s / 60) % 60)
    local s = math.floor(remaining_s % 60)
    timer_text:SetText(string.format("{ol}{s46}%02d:%02d{/}", m, s))
    local diff_time = g.revival_timer_start_time - imcTime.GetAppTimeMS()
    if remaining_s <= 10 and g.revival_timer_announced == 0 then
        g.revival_timer_announced = 1
        local suffix = g.lang == "Japanese" and " 10秒前" or " 10 sec rem."
        local msg = "/p " .. g.revival_timer_settings.set_text .. suffix
        if g.revival_timer_settings.ptchat then
            _UI_CHAT(msg)
        end
        if g.revival_timer_settings.nicochat then
            revival_timer_NICO_CHAT("{@st55_a}" .. g.revival_timer_settings.set_text .. suffix)
        end
    elseif remaining_s <= 5 and g.revival_timer_announced == 1 then
        g.revival_timer_announced = 2
        local suffix = g.lang == "Japanese" and " 5秒前" or " 5 sec rem."
        local msg = "/p " .. g.revival_timer_settings.set_text .. suffix
        if g.revival_timer_settings.ptchat then
            _UI_CHAT(msg)
        end
        if g.revival_timer_settings.nicochat then
            revival_timer_NICO_CHAT("{@st55_a}" .. g.revival_timer_settings.set_text .. suffix)
        end
    end
end

function revival_timer_loop_timer()
    g.revival_timer_start_time = imcTime.GetAppTimeMS()
    g.revival_timer_announced = 0
end

function revival_timer_NICO_CHAT(msg)
    local x = ui.GetClientInitialWidth()
    local y = ui.GetClientInitialHeight() * 0.6
    local nico_chat = ui.GetFrame("nico_chat")
    change_client_size(nico_chat)
    local name = UI_EFFECT_GET_NAME(nico_chat, "NICO_")
    local nico_text = nico_chat:CreateControl("richtext", name, x, y, 200, 20)
    AUTO_CAST(nico_text)
    nico_chat:SetLayerLevel(90)
    nico_chat:ShowWindow(1)
    nico_text:EnableResizeByText(1)
    nico_text:SetText(msg)
    nico_text:RunUpdateScript("NICO_MOVING")
    nico_text:SetUserValue("NICO_SPD", -150)
    nico_text:SetUserValue("NICO_START_X", x)
    nico_text:ShowWindow(1)
    nico_chat:RunUpdateScript("INVALIDATE_NICO")
end
-- revival_timer ここまで

-- relic_change ここから
g.relic_change_path = string.format("../addons/%s/%s/relic_change.json", addon_name_lower, g.active_id)
function relic_change_save_settings()
    g.save_json(g.relic_change_path, g.relic_change_settings)
end

function relic_change_load_settings()
    local settings = g.load_json(g.relic_change_path)
    if not settings then
        settings = {
            x = 0,
            y = 0,
            move = 0
        }
    end
    g.relic_change_settings = settings
    relic_change_save_settings()
end

function relic_change_on_init()
    if not g.relic_change_settings then
        relic_change_load_settings()
    end
    if g.settings.relic_change.use == 0 then
        local relic_change = ui.GetFrame(addon_name_lower .. "relic_change")
        if relic_change then
            ui.DestroyFrame(addon_name_lower .. "relic_change")
        end
        return
    end
    if g.get_map_type() == "City" then
        relic_change_frame_init()
    end
end

function relic_change_frame_init()
    local relic_change = ui.CreateNewFrame("notice_on_pc", addon_name_lower .. "relic_change", 0, 0, 0, 0)
    AUTO_CAST(relic_change)
    relic_change:SetSkinName('None')
    relic_change:SetTitleBarSkin("None")
    relic_change:Resize(40, 35)
    relic_change:SetGravity(ui.RIGHT, ui.TOP)
    relic_change:EnableHitTest(1)
    relic_change:EnableHittestFrame(1)
    relic_change:EnableMove(g.relic_change_settings.move)
    local rect = relic_change:GetMargin()
    relic_change:SetMargin(rect.left - rect.left, rect.top - rect.top + 300, rect.right + 50, rect.bottom)
    if g.relic_change_settings.x ~= 0 and g.relic_change_settings.y ~= 0 then
        relic_change:SetPos(g.relic_change_settings.x, g.relic_change_settings.y)
    end
    relic_change:SetEventScript(ui.LBUTTONUP, "relic_change_frame_move")
    local slot = relic_change:CreateOrGetControl("slot", "slot", 0, 0, 35, 35)
    AUTO_CAST(slot)
    slot:SetGravity(ui.LEFT, ui.TOP)
    slot:EnablePop(0)
    slot:EnableDrop(0)
    slot:EnableDrag(0)
    slot:SetSkinName('None')
    slot:SetEventScript(ui.LBUTTONUP, "relic_change_relicmanager_open")
    slot:SetEventScript(ui.RBUTTONUP, "relic_change_frame_context")
    local icon = CreateIcon(slot)
    AUTO_CAST(icon)
    local item_cls = GetClassByType('Item', 845000)
    icon:SetImage(item_cls.Icon)
    icon:SetTextTooltip(g.lang == "Japanese" and
                            "{ol}左クリック:シアンジェム入替え{nl}右クリック:フレーム設定" or
                            "{ol}Left Click: Cyan Gem swap{nl}Right Click: Frame settings")
    relic_change:ShowWindow(1)
end

function relic_change_frame_context(relic_change, slot)
    local context = ui.CreateContextMenu("CONTEXT", "{ol}Relic Change Setting", 0, 0, 0, 0)
    ui.AddContextMenuItem(context, "-----", "None")
    ui.AddContextMenuItem(context, g.lang == "Japanese" and "{ol}フレーム固定" or "{ol}Fix frame",
        "relic_change_gem_move_setting()")
    ui.AddContextMenuItem(context,
        g.lang == "Japanese" and "{ol}フレーム位置を戻す" or "{ol}Restore frame position",
        "relic_change_gem_move_restore()")
    ui.OpenContextMenu(context)
end

function relic_change_gem_move_setting()
    if g.relic_change_settings.move == 0 then
        g.relic_change_settings.move = 1
    else
        g.relic_change_settings.move = 0
    end
    relic_change_save_settings()
    ui.DestroyFrame(addon_name_lower .. "relic_change")
    ReserveScript("relic_change_frame_init()", 0.1)
end

function relic_change_gem_move_restore(relic_change)
    g.relic_change_settings.x = 0
    g.relic_change_settings.y = 0
    relic_change_save_settings()
    ui.DestroyFrame(addon_name_lower .. "relic_change")
    ReserveScript("relic_change_frame_init()", 0.1)
end

function relic_change_frame_move(relic_change)
    g.relic_change_settings.x = relic_change:GetX()
    g.relic_change_settings.y = relic_change:GetY()
    relic_change_save_settings()
end

function relic_change_relicmanager_open(relic_change, slot)
    local inventory = ui.GetFrame("inventory")
    if inventory:IsVisible() == 0 then
        UI_TOGGLE_INVENTORY()
        local inventype_Tab = GET_CHILD_RECURSIVELY(inventory, "inventype_Tab")
        inventype_Tab:SelectTab(6)
    end
    local relicmanager = ui.GetFrame("relicmanager")
    RELICMANAGER_OPEN(relicmanager)
    relicmanager:ShowWindow(1)
    local tab = GET_CHILD_RECURSIVELY(relicmanager, 'type_Tab')
    tab:SelectTab(2)
    relic_change_context()
end

function relic_change_context()
    local relic_gems = {}
    local inv_item_list = session.GetInvItemList()
    local guid_list = inv_item_list:GetGuidList()
    local cnt = guid_list:Count()
    for i = 0, cnt - 1 do
        local guid = guid_list:Get(i)
        local inv_item = inv_item_list:GetItemByGuid(guid)
        local item_obj = GetIES(inv_item:GetObject())
        local item_name = item_obj.Name
        if string.find(item_obj.ClassName, "Gem_Relic_Cyan") then
            local lv = TryGetProp(item_obj, 'GemLevel', 0)
            local existing_gem = relic_gems[item_obj.ClassID]
            if not existing_gem or lv > existing_gem.level then
                relic_gems[item_obj.ClassID] = {
                    level = lv,
                    guid = guid,
                    name = item_obj.Name
                }
            end
        end
    end
    local context = ui.CreateContextMenu("CONTEXT", "{ol}Relic Cyan Change", 0, 0, 0, 0)
    ui.AddContextMenuItem(context, "-----", "None")
    for gem_id, gem_data in pairs(relic_gems) do
        ui.AddContextMenuItem(context, dictionary.ReplaceDicIDInCompStr(gem_data.name) .. "Lv." .. gem_data.level,
            string.format("relic_change_gem_remove(%s)", gem_data.guid))
    end
    ui.OpenContextMenu(context)
end

function relic_change_gem_remove(guid)
    local arg_list = string.format('%d', 0)
    local relicmanager = ui.GetFrame('relicmanager')
    local relic_id = relicmanager:GetUserValue('RELIC_GUID')
    pc.ReqExecuteTx_Item('RELIC_SOCKET_GEM_REMOVE', relic_id, arg_list)
    relicmanager:SetUserValue("GEM_IESID", guid)
    relicmanager:RunUpdateScript("relic_change_gem_add", 1.0)
end

function relic_change_gem_add(relicmanager)
    local guid = relicmanager:GetUserValue("GEM_IESID")
    local relic_item = session.GetEquipItemBySpot(item.GetEquipSpotNum('RELIC'))
    local inv_item = session.GetInvItemByGuid(guid)
    if inv_item.isLockState == true then
        ui.SysMsg(ClMsg('MaterialItemIsLock'))
        return
    end
    session.ResetItemList()
    session.AddItemID(relic_item:GetIESID(), 1)
    session.AddItemID(inv_item:GetIESID(), 1)
    _RELICMANAGER_SOCKET_GEM_ADD()
    relicmanager:StopUpdateScript("relic_change_gem_add")
    relicmanager:RunUpdateScript("relic_change_end", 1.0)
end

function relic_change_end(relicmanager)
    relicmanager:StopUpdateScript("relic_change_end")
    RELICMANAGER_CLOSE(relicmanager)
    local inventory = ui.GetFrame("inventory")
    if inventory:IsVisible() == 1 then
        UI_TOGGLE_INVENTORY()
        local inventype_Tab = GET_CHILD_RECURSIVELY(inventory, "inventype_Tab")
        inventype_Tab:SelectTab(0)
    end
    ui.SysMsg("[RC]End of Operation")
end
-- relic_change ここまで

-- quickslot_operate ここから
g.quickslot_operate_path = string.format("../addons/%s/%s/quickslot_operate.json", addon_name_lower, g.active_id)
g.quickslot_operate_old_path = string.format("../addons/%s/%s/settings_250609.json", "quickslot_operate", g.active_id)
g.quickslot_operate_raid_list = {
    Paramune = {623, 667, 666, 665, 674, 673, 675, 680, 679, 681, 707, 708, 710, 711, 709, 712, 722, 723, 724, 725, 726,
                727},
    Klaida = {686, 685, 687, 716, 717, 718},
    Velnias = {689, 688, 690, 669, 635, 628, 696, 695, 697},
    Forester = {672, 671, 670},
    Widling = {677, 676, 678}
}
g.quickslot_operate_zone_list = {11208, 11230, 11250, 11252, 11256, 11257, 11261, 11263, 11266, 11267, 11270, 11276,
                                 11277, 11278, 11285, 11286}
-- 11267=ドラグーン 11257=バウバス 11290=アシャーク
g.quickslot_guild_eventmap = {11267, 11257, 11290, 11285, 11286}
g.quickslot_operate_atk_list = {
    Velnias = {640504, 640372},
    Klaida = {640503, 640370},
    Paramune = {640502, 640369},
    Widling = {640501, 640368},
    Forester = {640500, 640371}
}
g.quickslot_operate_def_list = {
    Velnias = 640373,
    Klaida = 640375,
    Paramune = 640374,
    Widling = 640377,
    Forester = 640376
}
function quickslot_operate_save_settings()
    g.save_json(g.quickslot_operate_path, g.quickslot_operate_settings)
end

function quickslot_operate_load_settings()
    local settings = g.load_json(g.quickslot_operate_path)
    if not settings then
        local old_settings = g.load_json(g.quickslot_operate_old_path)
        if old_settings then
            settings = old_settings
        else
            settings = {
                slotset = {},
                straight = false,
                rshift = false
            }
        end
    end
    g.quickslot_operate_settings = settings
    quickslot_operate_save_settings()
end

function quickslot_operate_on_init()
    if not g.quickslot_operate_settings then
        quickslot_operate_load_settings()
    end
    local all_in_one = ui.GetFrame("all_in_one")
    all_in_one:SetVisible(1)
    if g.settings.quickslot_operate.use == 0 then
        local quickslot_operate_map_timer = GET_CHILD(all_in_one, "quickslot_operate_map_timer")
        if quickslot_operate_map_timer then
            all_in_one:RemoveChild("quickslot_operate_map_timer")
        end
        local quickslot_operate_timer = GET_CHILD(all_in_one, "quickslot_operate_timer")
        if quickslot_operate_timer then
            all_in_one:RemoveChild("quickslot_operate_timer")
        end
        local quickslotnexpbar = ui.GetFrame("quickslotnexpbar")
        local setting = GET_CHILD(quickslotnexpbar, "setting")
        if setting then
            quickslotnexpbar:RemoveChild("setting")
        end
        quickslot_operate_set_script(quickslotnexpbar, false)
        if g.quickslot_operate_settings.straight then
            g.quickslot_operate_settings.straight = false
            quickslot_operate_redraw_slots()
        end
        return
    end
    g.setup_hook_and_event(g.addon, "SHOW_INDUNENTER_DIALOG", "quickslot_operate_SHOW_INDUNENTER_DIALOG", true)
    quickslot_operate_frame_init()
    -- quickslot_operate_switch_rshift(true)
    local quickslot_operate_map_timer = all_in_one:CreateOrGetControl("timer", "quickslot_operate_map_timer", 0, 0)
    AUTO_CAST(quickslot_operate_map_timer)
    quickslot_operate_map_timer:SetUpdateScript("quickslot_operate_map_change")
    quickslot_operate_map_timer:Stop()
    quickslot_operate_map_timer:Start(2.0)
end

function quickslot_operate_frame_init()
    local quickslotnexpbar = ui.GetFrame("quickslotnexpbar")
    local setting = quickslotnexpbar:CreateOrGetControl("button", "setting", 0, 0, 30, 20)
    AUTO_CAST(setting)
    setting:SetMargin(-260, 0, 0, 55)
    setting:SetText("{ol}{s11}QSO")
    setting:SetGravity(ui.CENTER_HORZ, ui.BOTTOM)
    setting:SetTextTooltip(g.lang == "Japanese" and
                               "{ol}左クリック: スロットセット読込{nl}右クリック: 各種設定" or
                               "{ol}Left-click: Load Slot Set{nl}Right-click: Settings")
    setting:SetEventScript(ui.RBUTTONUP, "quickslot_operate_context")
    setting:SetEventScript(ui.LBUTTONUP, "quickslot_operate_load_slotset_context")
    quickslot_operate_redraw_slots()
    quickslot_operate_set_script(quickslotnexpbar)
end

function quickslot_operate_context()
    local context = ui.CreateContextMenu("CONTEXT", "{ol}slotset context", 0, -300, 0, 0)
    ui.AddContextMenuItem(context, "-----", "None")
    ui.AddContextMenuItem(context,
        g.lang == "Japanese" and "{ol}スロットレイアウト保存" or "{ol}Save Slot layout",
        "quickslot_operate_save_slotset()")
    ui.AddContextMenuItem(context,
        g.lang == "Japanese" and "{ol}スロットレイアウト削除" or "{ol}Delete Slot layout",
        "quickslot_operate_delete_slotset()")
    ui.AddContextMenuItem(context, "------", "None")
    if g.quickslot_operate_settings.rshift then
        ui.AddContextMenuItem(context, g.lang == "Japanese" and "{ol}RSHIFT {#FF0000}ON {#FFFF00}OFFにする" or
            "{ol}RSHIFT {#FF0000}ON {#FFFF00}Turn OFF", "quickslot_operate_switch_rshift()")
    else
        ui.AddContextMenuItem(context, g.lang == "Japanese" and "{ol}RSHIFT {#FF0000}OFF {#FFFF00}ONにする" or
            "{ol}RSHIFT {#FF0000}OFF {#FFFF00}Turn ON", "quickslot_operate_switch_rshift()")
    end
    ui.AddContextMenuItem(context, "-------", "None")
    ui.AddContextMenuItem(context,
        g.lang == "Japanese" and "{ol}ストレートモード切替" or "{ol}Switch straight mode",
        "quickslot_operate_straight()")
    ui.OpenContextMenu(context)
end

function quickslot_operate_redraw_slots()
    local qso_settings = g.quickslot_operate_settings
    local quickslotnexpbar = ui.GetFrame("quickslotnexpbar")
    local margin, margin_2, margin_3
    if qso_settings.straight then
        margin, margin_2, margin_3 = -200, -200, -200
    else
        margin, margin_2, margin_3 = -225, -250, -225
    end
    for i = 11, MAX_QUICKSLOT_CNT do
        local slot = GET_CHILD_RECURSIVELY(quickslotnexpbar, "slot" .. i)
        AUTO_CAST(slot)
        if i <= 20 then
            slot:SetMargin(margin, 230, 0, 0)
            margin = margin + 50
        elseif i <= 30 then
            slot:SetMargin(margin_2, 180, 0, 0)
            margin_2 = margin_2 + 50
        elseif i <= 40 then
            slot:SetMargin(margin_3, 130, 0, 0)
            margin_3 = margin_3 + 50
        end
    end
    quickslotnexpbar:Invalidate()
    DebounceScript("QUICKSLOTNEXTBAR_UPDATE_ALL_SLOT", 0.1)
end

function quickslot_operate_straight()
    g.quickslot_operate_settings.straight = not g.quickslot_operate_settings.straight
    quickslot_operate_save_settings()
    quickslot_operate_redraw_slots()
end

function quickslot_operate_save_slotset()
    if not g.quickslot_operate_settings.slotset[g.login_name] then
        g.quickslot_operate_settings.slotset[g.login_name] = {}
    end
    quickslot_operate_INPUT_STRING_BOX()
end

function quickslot_operate_INPUT_STRING_BOX()
    local inputstring = ui.GetFrame("inputstring")
    inputstring:Resize(500, 220)
    inputstring:SetLayerLevel(999)
    local edit = GET_CHILD(inputstring, 'input')
    AUTO_CAST(edit)
    edit:SetNumberMode(0)
    edit:SetMaxLen(99)
    edit:SetText("")
    inputstring:ShowWindow(1)
    inputstring:SetEnable(1)
    local title = inputstring:GetChild("title")
    AUTO_CAST(title)
    local text = g.lang == "Japanese" and "{ol}{#FFFFFF}セット名を入力" or "{ol}{#FFFFFF}Enter set name"
    title:SetText(text)
    local confirm = inputstring:GetChild("confirm")
    confirm:SetEventScript(ui.LBUTTONUP, "quickslot_operate_save_setname")
    edit:SetEventScript(ui.ENTERKEY, "quickslot_operate_save_setname")
    edit:AcquireFocus()
end

function quickslot_operate_save_setname(inputstring, ctrl, str, num)
    inputstring:ShowWindow(0)
    local edit = GET_CHILD(inputstring, 'input')
    local get_text = edit:GetText()
    if get_text == "" then
        local text = g.lang == "Japanese" and "{ol}文字を入力してください" or "{ol}Please enter text"
        ui.SysMsg(text)
        quickslot_operate_INPUT_STRING_BOX()
        return
    end
    g.quickslot_operate_settings.slotset[g.login_name][get_text] = {}
    local temp_data = g.quickslot_operate_settings.slotset[g.login_name][get_text]
    local main_session = session.GetMainSession()
    local pc_job_data = main_session:GetPCJobInfo()
    local job_count = pc_job_data:GetJobCount()
    for i = 0, job_count - 1 do
        local current_job_info = pc_job_data:GetJobInfoByIndex(i)
        if current_job_info then
            local job_key = "jobid_" .. i
            temp_data[job_key] = tonumber(current_job_info.jobID)
        end
    end
    local quickslotnexpbar = ui.GetFrame("quickslotnexpbar")
    for i = 1, 40 do
        local slot = GET_CHILD_RECURSIVELY(quickslotnexpbar, "slot" .. i)
        if slot then
            local icon = slot:GetIcon()
            if icon then
                local icon_info = icon:GetInfo()
                local category = icon_info:GetCategory()
                local item_type = icon_info.type
                local iesid = icon_info:GetIESID()
                temp_data[tostring(i)] = {
                    ["category"] = category,
                    ["type"] = item_type,
                    ["iesid"] = iesid
                }
            end
        end
    end
    ui.SysMsg(g.lang == "Japanese" and "{ol}スロットレイアウト保存" or "{ol}Save Slot layout")
    quickslot_operate_save_settings()
end

function quickslot_operate_load_slotset_context()
    local context = ui.CreateContextMenu("CONTEXT_LOAD", "{ol}Load Slotset", 0, -350, 0, 0)
    quickslot_operate_build_slotset_menu(context, "LOAD")
    ui.OpenContextMenu(context)
end

function quickslot_operate_delete_slotset()
    local context = ui.CreateContextMenu("CONTEXT", "{ol}Delete slotset", 0, -100, 0, 0)
    quickslot_operate_build_slotset_menu(context, "DELETE")
    ui.OpenContextMenu(context)
end

function quickslot_operate_delete_slotset_(name, title)
    g.quickslot_operate_settings.slotset[name][title] = nil
    quickslot_operate_save_settings()
    local msg = name .. ":" .. title .. (g.lang == "Japanese" and " 削除しました" or " Deleted")
    ui.SysMsg(msg)
end

function quickslot_operate_load_all_slot(name, title)
    local quickslotnexpbar = ui.GetFrame('quickslotnexpbar')
    for i = 1, MAX_QUICKSLOT_CNT do
        local str_index = tostring(i)
        local slot = GET_CHILD_RECURSIVELY(quickslotnexpbar, "slot" .. str_index)
        AUTO_CAST(slot)
        local slot_info = g.quickslot_operate_settings.slotset[name][title][str_index]
        if slot_info then
            local category = slot_info.category
            local clsid = slot_info.type
            local iesid = slot_info.iesid
            SET_QUICK_SLOT(quickslotnexpbar, slot, category, clsid, iesid, 0, true, true)
        else
            slot:ClearText()
            CLEAR_QUICKSLOT_SLOT(slot, 0, true)
        end
        slot:Invalidate()
    end
    quickslot.RequestSave()
    QUICKSLOTNEXPBAR_UPDATE_HOTKEYNAME(quickslotnexpbar)
    DebounceScript("QUICKSLOTNEXTBAR_UPDATE_ALL_SLOT", 0.1)
end

function quickslot_operate_build_slotset_menu(context, mode)
    local slotset_data = g.quickslot_operate_settings.slotset
    if not slotset_data then
        return
    end
    ui.AddContextMenuItem(context, "-----", "None")
    for name, data in pairs(slotset_data) do
        for title, layout_data in pairs(data) do
            local display_name_parts = {}
            for i = 0, 3 do
                local job_key = "jobid_" .. i
                local saved_job_id = layout_data[job_key]
                if saved_job_id then
                    local job_cls = GetClassByType("Job", tonumber(saved_job_id))
                    if job_cls then
                        local job_name = dic.getTranslatedStr(TryGetProp(job_cls, "Name", "None"))
                        table.insert(display_name_parts, job_name)
                    end
                end
            end
            local display_str = table.concat(display_name_parts, ", ")
            local display_text, scp
            if mode == "DELETE" then
                display_text = string.format("%s : (%s)", tostring(title), tostring(display_str))
                scp = string.format("quickslot_operate_delete_slotset_('%s','%s')", name, title)
            elseif mode == "LOAD" then
                display_text = string.format("%s : (%s)", tostring(title), tostring(display_str))
                scp = string.format("quickslot_operate_load_all_slot('%s','%s')", name, title)
            end
            if display_text and scp then
                ui.AddContextMenuItem(context, display_text, scp)
            end
        end
    end
end

function quickslot_operate_set_script(quickslotnexpbar, is_use)
    g.qso_potion_map = {}
    for race, pots in pairs(g.quickslot_operate_atk_list) do
        for _, pot_id in ipairs(pots) do
            g.qso_potion_map[pot_id] = true
        end
    end
    for race, pot_id in pairs(g.quickslot_operate_def_list) do
        g.qso_potion_map[pot_id] = true
    end
    for i = 1, MAX_QUICKSLOT_CNT do
        local slot = quickslotnexpbar:GetChildRecursively("slot" .. i)
        AUTO_CAST(slot)
        local slot_info = quickslot.GetInfoByIndex(i - 1)
        if slot_info and slot_info.type ~= 0 then
            if slot_info and g.qso_potion_map[slot_info.type] then
                if is_use == false then
                    slot:SetEventScript(ui.MOUSEON, "None")
                else
                    slot:SetEventScript(ui.MOUSEON, "quickslot_operate_choice_potion")
                end
            end
        end
    end
end

function quickslot_operate_choice_potion(frame, slot, str, num)
    slot:RunUpdateScript("quickslot_operate_frame_close", 5.0)
    local joystickquickslot = ui.GetFrame('joystickquickslot')
    joystickquickslot:RunUpdateScript("quickslot_operate_frame_close", 5.0)
    local quickslot_operate = ui.CreateNewFrame("notice_on_pc", addon_name_lower .. "quickslot_operate", 0, 0, 0, 0)
    quickslot_operate:RemoveAllChild()
    quickslot_operate:Resize(150, 30)
    local map_frame = ui.GetFrame("map")
    local width = map_frame:GetWidth()
    quickslot_operate:SetPos(width / 2 - 75, 780)
    quickslot_operate:SetTitleBarSkin("None")
    quickslot_operate:SetSkinName("chat_window")
    quickslot_operate:SetLayerLevel(150)
    local slotset = quickslot_operate:CreateOrGetControl('slotset', 'slotset', 0, 0, 0, 0)
    AUTO_CAST(slotset)
    slotset:SetSlotSize(30, 30)
    slotset:EnablePop(0)
    slotset:EnableDrag(0)
    slotset:EnableDrop(0)
    slotset:SetColRow(5, 1)
    slotset:SetSpc(0, 0)
    slotset:SetSkinName('slot')
    slotset:CreateSlots()
    local slot_count = slotset:GetSlotCount()
    local atk_list = {640372, 640370, 640369, 640368, 640371}
    for i = 0, slot_count - 1 do
        local slot = slotset:GetSlotByIndex(i)
        slot:SetEventScript(ui.LBUTTONDOWN, "quickslot_operate_set_potion")
        slot:SetEventScriptArgNumber(ui.LBUTTONDOWN, atk_list[i + 1])
        local class = GetClassByType('Item', atk_list[i + 1])
        SET_SLOT_ITEM_CLS(slot, class)
    end
    quickslot_operate:ShowWindow(1)
end

function quickslot_operate_set_potion(parent, slot, str, pot_id)
    for race, data in pairs(g.quickslot_operate_atk_list) do
        for _, id in ipairs(data) do
            if id == pot_id then
                local down_potion_id = g.quickslot_operate_def_list[race]
                quickslot_operate_check_all_slots(race, down_potion_id)
            end
        end
    end
end

function quickslot_operate_check_all_slots(race, down_potion_id, atk_id, def_id)
    local quickslotnexpbar = ui.GetFrame("quickslotnexpbar")
    local joystickquickslot = ui.GetFrame('joystickquickslot')
    if IsJoyStickMode() == 1 then
        quickslotnexpbar:ShowWindow(1)
        joystickquickslot:ShowWindow(0)
    end
    local atk_list = g.quickslot_operate_atk_list
    for i = 1, MAX_QUICKSLOT_CNT do
        local slot = GET_CHILD_RECURSIVELY(quickslotnexpbar, "slot" .. i)
        AUTO_CAST(slot)
        local slot_info = quickslot.GetInfoByIndex(i - 1)
        if slot_info and g.qso_potion_map[slot_info.type] then
            local is_atk_potion = false
            for _, pot_ids in pairs(atk_list) do
                for _, pot_id in ipairs(pot_ids) do
                    if pot_id == slot_info.type then
                        is_atk_potion = true
                        break
                    end
                end
                if is_atk_potion then
                    break
                end
            end
            if is_atk_potion then
                local new_atk_id
                if not atk_id then
                    local inv_item = session.GetInvItemByType(atk_list[race][1]) or
                                         session.GetInvItemByType(atk_list[race][2])
                    if inv_item then
                        new_atk_id = inv_item.type
                    end
                else
                    new_atk_id = atk_id
                end
                if new_atk_id then
                    SET_QUICK_SLOT(quickslotnexpbar, slot, slot_info.category, new_atk_id, nil, 0, true, true)
                end
            else
                local new_def_id = not def_id and down_potion_id or def_id
                if new_def_id then
                    SET_QUICK_SLOT(quickslotnexpbar, slot, slot_info.category, new_def_id, nil, 0, true, true)
                end
            end
        end
    end
    quickslot.RequestSave()
    QUICKSLOTNEXPBAR_UPDATE_HOTKEYNAME(quickslotnexpbar)
    if IsJoyStickMode() == 1 then
        DebounceScript("JOYSTICK_QUICKSLOT_UPDATE_ALL_SLOT", 0.1)
        quickslotnexpbar:ShowWindow(0)
        joystickquickslot:ShowWindow(1)
    else
        DebounceScript("QUICKSLOTNEXTBAR_UPDATE_ALL_SLOT", 0.1)
    end
end

function quickslot_operate_frame_close()
    local quickslot_operate = ui.GetFrame(addon_name_lower .. "quickslot_operate")
    if quickslot_operate then
        ui.DestroyFrame(quickslot_operate:GetName())
    end
end

function quickslot_operate_map_change(all_in_one, quickslot_operate_map_timer)
    local quickslotnexpbar = ui.GetFrame("quickslotnexpbar")
    for _, zone_id in ipairs(g.quickslot_operate_zone_list) do
        if zone_id == g.map_id then
            local potion_type = quickslot_operate_get_potion_type(g.quickslot_operate_indun_type)
            if potion_type then
                quickslotnexpbar:SetUserValue("POT_TYPE", potion_type)
                quickslotnexpbar:RunUpdateScript("quickslot_operate_get_potion", 2.0)
                quickslot_operate_map_timer:Stop()
                return
            end
        end
    end -- 11285, 11286
    for _, eventmap_id in ipairs(g.quickslot_guild_eventmap) do
        if eventmap_id == g.map_id then
            if eventmap_id == 11285 or eventmap_id == 11286 then
                quickslotnexpbar:SetUserValue("POT_TYPE", "Velnias")
            else
                quickslotnexpbar:SetUserValue("POT_TYPE", "Paramune")
            end
            quickslotnexpbar:RunUpdateScript("quickslot_operate_get_potion", 2.0)
            quickslot_operate_map_timer:Stop()
            return
        end
    end
end

function quickslot_operate_SHOW_INDUNENTER_DIALOG()
    if g.settings.quickslot_operate.use == 0 then
        return
    end
    local indunenter = ui.GetFrame('indunenter')
    local indun_type = tonumber(indunenter:GetUserValue("INDUN_TYPE"))
    g.quickslot_operate_indun_type = indun_type
    local potion_type = quickslot_operate_get_potion_type(indun_type)
    if potion_type then
        local quickslotnexpbar = ui.GetFrame("quickslotnexpbar")
        quickslotnexpbar:SetUserValue("POT_TYPE", potion_type)
        quickslot_operate_get_potion(quickslotnexpbar)
    end
end

function quickslot_operate_get_potion_type(indun_type)
    for potion_type, indun_list in pairs(g.quickslot_operate_raid_list) do
        for _, indun_id in ipairs(indun_list) do
            if indun_id == indun_type then
                return potion_type
            end
        end
    end
    return nil
end

function quickslot_operate_get_potion(quickslotnexpbar)
    local potion_type = quickslotnexpbar:GetUserIValue("POT_TYPE")
    local atk_list = g.quickslot_operate_atk_list
    local def_list = g.quickslot_operate_def_list
    local atk_id = atk_list[potion_type][1]
    local inv_item = session.GetInvItemByType(atk_id)
    if not inv_item then
        atk_id = atk_list[potion_type][2]
        inv_item = session.GetInvItemByType(atk_id)
        if not inv_item then
            atk_id = false
        end
    end
    local def_id = def_list[potion_type]
    inv_item = session.GetInvItemByType(def_id)
    if not inv_item then
        def_id = false
    end
    if atk_id or def_id then
        quickslot_operate_check_all_slots(nil, nil, atk_id, def_id)
    end
end

function quickslot_operate_switch_rshift(is_first)
    local all_in_one = ui.GetFrame("all_in_one")
    all_in_one:SetVisible(1)
    if g.quickslot_operate_settings.rshift == true then
        g.quickslot_operate_settings.rshift = false
        local quickslot_operate_timer = GET_CHILD(all_in_one, "quickslot_operate_timer")
        if quickslot_operate_timer then
            all_in_one:RemoveChild("quickslot_operate_timer")
        end
    else
        g.quickslot_operate_settings.rshift = true
        local quickslot_operate_timer = all_in_one:CreateOrGetControl("timer", "quickslot_operate_timer", 0, 0)
        AUTO_CAST(quickslot_operate_timer)
        quickslot_operate_timer:SetUpdateScript("quickslot_operate_set_rshift_script")
        quickslot_operate_timer:Start(0.15)
    end
    quickslot_operate_save_settings()
    if not is_first then

        -- quickslot_operate_context()
    end
end

function quickslot_operate_set_rshift_script()
    if keyboard.IsKeyPressed("RSHIFT") == 0 then
        return
    end
    local chat = ui.GetFrame('chat')
    local mainchat = chat:GetChild('mainchat')
    if mainchat:IsVisible() == 1 then
        return
    end
    local quickslotnexpbar = ui.GetFrame("quickslotnexpbar")
    local joystickquickslot = ui.GetFrame('joystickquickslot')
    if IsJoyStickMode() == 1 then
        quickslotnexpbar:ShowWindow(1)
        joystickquickslot:ShowWindow(0)
    end
    local current_potion_type = nil
    for i = 1, MAX_QUICKSLOT_CNT do
        local slot_info = quickslot.GetInfoByIndex(i - 1)
        if slot_info and slot_info.type ~= 0 then
            for race, pot_ids in pairs(g.quickslot_operate_atk_list) do
                for _, pot_id in ipairs(pot_ids) do
                    if pot_id == slot_info.type then
                        current_potion_type = race
                        break
                    end
                end
                if current_potion_type then
                    break
                end
            end
            if current_potion_type then
                break
            end
            for race, pot_id in pairs(g.quickslot_operate_def_list) do
                if pot_id == slot_info.type then
                    current_potion_type = race
                    break
                end
            end
        end
        if current_potion_type then
            break
        end
    end
    if not current_potion_type then
        return
    end
    local potion_type_order = {"Velnias", "Klaida", "Paramune", "Widling", "Forester"}
    local next_potion_type = nil
    for i, p_type in ipairs(potion_type_order) do
        if p_type == current_potion_type then
            local next_index = (i % #potion_type_order) + 1
            next_potion_type = potion_type_order[next_index]
            break
        end
    end
    if not next_potion_type then
        return
    end
    local atk_list = g.quickslot_operate_atk_list
    local new_atk_id = nil
    local inv_item = session.GetInvItemByType(atk_list[next_potion_type][1]) or
                         session.GetInvItemByType(atk_list[next_potion_type][2])
    if inv_item then
        new_atk_id = inv_item.type
    end
    local new_def_id = g.quickslot_operate_def_list[next_potion_type]
    if new_atk_id or new_def_id then
        quickslot_operate_check_all_slots(nil, nil, new_atk_id, new_def_id)
    end
    quickslot.RequestSave()
    if IsJoyStickMode() == 1 then
        quickslotnexpbar:ShowWindow(0)
        joystickquickslot:ShowWindow(1)
    end
end
-- quickslot_operate ここまで

-- my_buffs_control ここから
g.my_buffs_control_path = string.format("../addons/%s/%s/my_buffs_control.json", addon_name_lower, g.active_id)
g.my_buffs_control_old_path = string.format("../addons/%s/settings_2503.json", "my_buffs")
function my_buffs_control_save_settings()
    g.save_json(g.my_buffs_control_path, g.my_buffs_control_settings)
end

function my_buffs_control_load_settings()
    local settings = g.load_json(g.my_buffs_control_path)
    if not settings then
        local old_settings = g.load_json(g.my_buffs_control_old_path)
        if old_settings then
            settings = old_settings
        else
            settings = {
                buffs = {},
                lock = true,
                default_x = 20,
                default_y = 130,
                custom_x = 20,
                custom_y = 130
            }
        end
    end
    g.my_buffs_control_settings = settings
    my_buffs_control_save_settings()
end

function my_buffs_control_on_init()
    if not g.my_buffs_control_settings then
        my_buffs_control_load_settings()
    end
    g.addon:RegisterMsg("BUFF_ADD", "my_buffs_control_BUFF_ADD")
    if g.settings.my_buffs_control.use == 1 then
        my_buffs_control_frame()
        g.setup_hook_before_with_filter("BUFF_ON_MSG", "my_buffs_control_buff_filter")
    else
        my_buffs_control_reset_ui()
        _G.BUFF_ON_MSG = g.FUNCS_BEFORE["BUFF_ON_MSG"]
    end
end

function my_buffs_control_buff_filter(frame, msg, str, num)
    if g.get_map_type() ~= 'City' then
        local str_buff_id = tostring(num)
        if g.my_buffs_control_settings.buffs[str_buff_id] == false then
            return true
        end
    end
    return false
end

function my_buffs_control_reset_ui()
    local buff = ui.GetFrame("buff")
    if buff then
        AUTO_CAST(buff)
        buff:SetPos(g.my_buffs_control_settings.default_x, g.my_buffs_control_settings.default_y)
        buff:RemoveChild("lock_slot")
        g.my_buffs_control_settings.lock = true
        buff:EnableHittestFrame(0)
        buff:EnableMove(0)
        buff:SetEventScript(ui.LBUTTONUP, "None")
    end
end

function my_buffs_control_frame()
    if g.settings.my_buffs_control.use == 0 then
        my_buffs_control_reset_ui()
        return
    end
    local buff = ui.GetFrame("buff")
    AUTO_CAST(buff)
    buff:SetEventScript(ui.LBUTTONUP, "my_buffs_control_end_drag")
    if g.get_map_type() ~= 'City' then
        buff:SetPos(g.my_buffs_control_settings.custom_x, g.my_buffs_control_settings.custom_y)
    else
        buff:SetPos(g.my_buffs_control_settings.default_x, g.my_buffs_control_settings.default_y)
    end
    buff:SetLayerLevel(61)
    buff:RemoveChild("lock_slot")
    local lock_slot = buff:CreateOrGetControl('slot', "lock_slot", 0, 0, 20, 30)
    AUTO_CAST(lock_slot)
    lock_slot:SetTextTooltip(g.lang == "Japanese" and
                                 "{ol}[MBC]{nl}左クリック:フレームを動かせる様に{nl} {nl}{#FF0000}街では全て表示します" or
                                 "{ol}[MBC]{nl}Left Click: Make frame movable{nl} {nl}{#FF0000}Show all in town")
    lock_slot:SetEventScript(ui.LBUTTONUP, "my_buffs_control_frame_lock")
    local lock = lock_slot:CreateOrGetControlSet('inv_itemlock', "lock", 0, 0)
    AUTO_CAST(lock)
    lock:SetGravity(ui.LEFT, ui.TOP)
    if g.my_buffs_control_settings.lock then
        lock:SetGrayStyle(0)
    else
        lock:SetGrayStyle(1)
    end
end

function my_buffs_control_end_drag(buff, ctrl, str, num)
    g.my_buffs_control_settings.custom_x = buff:GetX()
    g.my_buffs_control_settings.custom_y = buff:GetY()
    my_buffs_control_save_settings()
end

function my_buffs_control_frame_lock(buff, lock_slot)
    local lock = GET_CHILD(lock_slot, "lock")
    if g.my_buffs_control_settings.lock then
        g.my_buffs_control_settings.lock = false
        lock:SetGrayStyle(1)
        buff:EnableHittestFrame(1)
        buff:EnableMove(1)
    else
        g.my_buffs_control_settings.lock = true
        lock:SetGrayStyle(0)
        buff:EnableHittestFrame(0)
        buff:EnableMove(0)
    end
    my_buffs_control_save_settings()
end

function my_buffs_control_setting_menu()
    local list_frame_name = addon_name_lower .. "list_frame"
    local list_frame = ui.GetFrame(addon_name_lower .. "list_frame")
    local my_buffs_control_setting = ui.CreateNewFrame("notice_on_pc", addon_name_lower .. "my_buffs_control_setting",
        0, 0, 0, 0)
    my_buffs_control_setting:Resize(250, 180)
    my_buffs_control_setting:SetPos(list_frame:GetX() + list_frame:GetWidth(), list_frame:GetY())
    my_buffs_control_setting:SetSkinName("test_frame_low")
    my_buffs_control_setting:EnableHittestFrame(1)
    my_buffs_control_setting:EnableHitTest(1)
    my_buffs_control_setting:ShowWindow(1)
    local title_text = my_buffs_control_setting:CreateOrGetControl('richtext', 'title_text', 20, 15, 50, 30)
    AUTO_CAST(title_text)
    title_text:SetText("{ol}My Buffs Control Config")
    local close = my_buffs_control_setting:CreateOrGetControl("button", "close", 0, 0, 20, 20)
    AUTO_CAST(close)
    close:SetImage("testclose_button")
    close:SetGravity(ui.RIGHT, ui.TOP)
    close:SetEventScript(ui.LBUTTONUP, "my_buffs_control_frame_close")
    local gbox = my_buffs_control_setting:CreateOrGetControl("groupbox", "gbox", 10, 40,
        my_buffs_control_setting:GetWidth() - 20, my_buffs_control_setting:GetHeight() - 50)
    AUTO_CAST(gbox)
    gbox:SetSkinName("test_frame_midle_light")
    local list_open_btn = gbox:CreateOrGetControl('button', 'list_open_btn', 10, 10, 130, 30)
    AUTO_CAST(list_open_btn)
    list_open_btn:SetText("{ol}Buff list")
    list_open_btn:SetTextTooltip(g.lang == "Japanese" and "{ol}バフリスト表示" or "{ol}Buff list Open")
    list_open_btn:SetEventScript(ui.LBUTTONUP, "my_buffs_control_buff_list_open")
    local org_pos = gbox:CreateOrGetControl('button', 'org_pos', 10, 50, 130, 30)
    AUTO_CAST(org_pos)
    org_pos:SetText("Default Pos")
    org_pos:SetTextTooltip(g.lang == "Japanese" and "{ol}バフ欄の位置を元に戻します" or
                               "{ol}Restore the buff frame position to default")
    org_pos:SetEventScript(ui.LBUTTONUP, "my_buffs_control_original_position")
    local text = gbox:CreateOrGetControl('richtext', 'text', 10, 100, 150, 30)
    AUTO_CAST(text)
    text:SetText(g.lang == "Japanese" and "{ol}{#FF0000}※街では全て表示します" or
                     "{ol}{#FF0000}※Show all in town")
end

function my_buffs_control_original_position()
    local buff = ui.GetFrame("buff")
    buff:SetPos(g.my_buffs_control_settings.default_x, g.my_buffs_control_settings.default_y)
    g.my_buffs_control_settings.custom_x = g.my_buffs_control_settings.default_x
    g.my_buffs_control_settings.custom_y = g.my_buffs_control_settings.default_y
    my_buffs_control_save_settings()
end

function my_buffs_control_frame_close(frame, ctrl, str, num)
    ui.DestroyFrame(frame:GetName())
end

function my_buffs_control_buff_list_search(my_buffs_control, ctrl, ctrl_text, num)
    local search_edit = GET_CHILD_RECURSIVELY(my_buffs_control, "search_edit")
    local ctrl_text = search_edit:GetText()
    if ctrl_text ~= "" then
        my_buffs_control_buff_list_open(my_buffs_control, ctrl, ctrl_text)
    else
        my_buffs_control_buff_list_open(my_buffs_control, ctrl, "")
    end
end

function my_buffs_control_buff_list_open(frame, ctrl, ctrl_text, num)
    local my_buffs_control = ui.GetFrame(addon_name_lower .. "my_buffs_control")
    if not my_buffs_control then
        my_buffs_control = ui.CreateNewFrame("notice_on_pc", addon_name_lower .. "my_buffs_control", 0, 0, 0, 0)
        AUTO_CAST(my_buffs_control)
        my_buffs_control:SetSkinName("test_frame_low")
        my_buffs_control:Resize(500, 1060)
        my_buffs_control:SetPos(150, 10)
        my_buffs_control:SetLayerLevel(121)
        local search_edit = my_buffs_control:CreateOrGetControl("edit", "search_edit", 40, 10, 305, 38)
        AUTO_CAST(search_edit)
        search_edit:SetFontName("white_18_ol")
        search_edit:SetTextAlign("left", "center")
        search_edit:SetSkinName("inventory_serch")
        search_edit:SetEventScript(ui.ENTERKEY, "my_buffs_control_buff_list_search")
        local search_btn = search_edit:CreateOrGetControl("button", "search_btn", 0, 0, 40, 38)
        AUTO_CAST(search_btn)
        search_btn:SetImage("inven_s")
        search_btn:SetGravity(ui.RIGHT, ui.TOP)
        search_btn:SetEventScript(ui.LBUTTONUP, "my_buffs_control_buff_list_search")
        local close = my_buffs_control:CreateOrGetControl('button', 'close', 0, 0, 20, 20)
        AUTO_CAST(close)
        close:SetImage("testclose_button")
        close:SetGravity(ui.RIGHT, ui.TOP)
        close:SetEventScript(ui.LBUTTONUP, "my_buffs_control_frame_close")
    end
    local buff_list_gb = my_buffs_control:CreateOrGetControl("groupbox", "buff_list_gb", 10, 50, 480,
        my_buffs_control:GetHeight() - 60)
    AUTO_CAST(buff_list_gb)
    buff_list_gb:SetSkinName("bg")
    buff_list_gb:RemoveAllChild()
    local cls_list, count = GetClassList("Buff")
    local all_buffs = {}
    for i = 0, count - 1 do
        local buff_cls = GetClassByIndexFromList(cls_list, i)
        if buff_cls then
            if buff_cls.Group1 ~= 'Debuff' and buff_cls.Group1 ~= 'Deuff' then
                local buff_name = dictionary.ReplaceDicIDInCompStr(buff_cls.Name)
                if not ctrl_text or ctrl_text == "" or string.find(buff_name, ctrl_text) then
                    local image_name = GET_BUFF_ICON_NAME(buff_cls)
                    if image_name ~= "icon_None" and buff_name ~= "None" then
                        local is_checked = g.my_buffs_control_settings["buffs"][tostring(buff_cls.ClassID)] == true
                        table.insert(all_buffs, {
                            cls = buff_cls,
                            name = buff_name,
                            image = image_name,
                            is_checked = is_checked
                        })
                    end
                end
            else
                local buff_id = buff_cls.ClassID
                g.my_buffs_control_settings.buffs[tostring(buff_id)] = true
            end
        end
    end
    my_buffs_control_save_settings()
    table.sort(all_buffs, function(a, b)
        if a.is_checked and not b.is_checked then
            return true
        elseif not a.is_checked and b.is_checked then
            return false
        else
            return a.cls.ClassID < b.cls.ClassID
        end
    end)
    local y = 0
    for _, buff_data in ipairs(all_buffs) do
        local buff_cls = buff_data.cls
        local buff_id = buff_cls.ClassID
        local buff_slot = buff_list_gb:CreateOrGetControl('slot', 'buffslot' .. buff_id, 10, y + 5, 30, 30)
        AUTO_CAST(buff_slot)
        SET_SLOT_IMG(buff_slot, buff_data.image)
        local icon = CreateIcon(buff_slot)
        AUTO_CAST(icon)
        icon:SetTooltipType('buff')
        icon:SetTooltipArg(buff_data.name, buff_id, 0)
        local buff_check = buff_list_gb:CreateOrGetControl('checkbox', 'buff_check' .. buff_id, 50, y + 10, 200, 30)
        AUTO_CAST(buff_check)
        buff_check:SetText("{ol}" .. buff_id .. " : " .. buff_data.name)
        buff_check:SetTextTooltip(g.lang == "Japanese" and "チェックを外すとバフを非表示にします" or
                                      "Unchecking hides the buff")
        buff_check:SetCheck(buff_data.is_checked and 1 or 0)
        buff_check:SetEventScript(ui.LBUTTONUP, "my_buffs_control_buff_toggle")
        buff_check:SetEventScriptArgString(ui.LBUTTONUP, buff_id)
        y = y + 35
    end
    my_buffs_control:ShowWindow(1)
end

function my_buffs_control_buff_toggle(frame, ctrl, str_buff_id, num)
    local is_check = ctrl:IsChecked()
    if is_check == 1 then
        g.my_buffs_control_settings.buffs[str_buff_id] = true
    else
        g.my_buffs_control_settings.buffs[str_buff_id] = false
    end
    my_buffs_control_save_settings()
end

function my_buffs_control_BUFF_ADD(frame, ctrl, str, buff_id)
    local cls = GetClassByType("Buff", buff_id)
    if cls.Group1 ~= 'Debuff' and cls.Group1 ~= 'Deuff' then
        local str_buff_id = tostring(buff_id)
        if g.my_buffs_control_settings.buffs[str_buff_id] == nil then
            g.my_buffs_control_settings.buffs[str_buff_id] = true
            my_buffs_control_save_settings()
        end
    end
end
-- my_buffs_control ここまで

-- monster_card_changer ここから
g.monster_card_changer_path = string.format("../addons/%s/%s/monster_card_changer.json", addon_name_lower, g.active_id)
function monster_card_changer_save_settings()
    g.save_json(g.monster_card_changer_path, g.monster_card_changer_settings)
end

function monster_card_changer_load_settings()
    local settings = g.load_json(g.monster_card_changer_path)
    if not settings then
        settings = {
            presets = {}
        }
    end
    local changed = false
    for i = 1, 10 do
        if not settings.presets[i] then
            local title = ScpArgMsg('CardPresetNumber{index}', 'index', i)
            settings.presets[i] = {
                name = title,
                slots = {}
            }
            changed = true
        end
        if not settings.presets[i].slots or #settings.presets[i].slots < 12 then
            local slots = settings.presets[i].slots or {}
            for j = 1, 12 do
                if not slots[j] then
                    slots[j] = {
                        card_id = 0,
                        card_exp = 0,
                        card_lv = 0
                    }
                end
            end
            settings.presets[i].slots = slots
            changed = true
        end
    end
    g.monster_card_changer_settings = settings
    if changed then
        monster_card_changer_save_settings()
    end
end

function monster_card_changer_on_init()
    if not g.monster_card_changer_settings then
        monster_card_changer_load_settings()
    end
    if g.settings.monster_card_changer.use == 0 then
        monster_card_changer_not_use()
        return
    end
    if g.get_map_type() == "City" then
        monster_card_changer_inventory_frame_init()
        g.setup_hook_and_event(g.addon, "CARD_PRESET_CHANGE_NAME_EXEC",
            "monster_card_changer_CARD_PRESET_CHANGE_NAME_EXEC", false)
    end
end

function monster_card_changer_not_use()
    local inventory = ui.GetFrame('inventory')
    local mcc = GET_CHILD(inventory, "mcc")
    if mcc then
        DESTROY_CHILD_BYNAME(inventory, "mcc")
    end
    local monster_card_changer = ui.GetFrame(addon_name_lower .. "monster_card_changer")
    if monster_card_changer then
        ui.DestroyFrame(monster_card_changer:GetName())
    end
    local monstercardslot = ui.GetFrame("monstercardslot")
    local applyBtn = GET_CHILD(monstercardslot, "applyBtn")
    if applyBtn then
        applyBtn:SetEventScript(ui.LBUTTONUP, "MONSTERCARDPRESET_FRAME_OPEN")
    end
    local monstercardpreset = ui.GetFrame('monstercardpreset')
    local preset_list = GET_CHILD_RECURSIVELY(monstercardpreset, "preset_list")
    preset_list:ShowWindow(1)
    local saveBtn = GET_CHILD_RECURSIVELY(monstercardpreset, "saveBtn")
    saveBtn:ShowWindow(1)
    local applyBtn = GET_CHILD_RECURSIVELY(monstercardpreset, "applyBtn")
    applyBtn:ShowWindow(1)
    local drop_list = GET_CHILD(monstercardpreset, 'drop_list')
    if drop_list then
        monstercardpreset:RemoveChild("drop_list")
    end
    local save_btn = GET_CHILD(monstercardpreset, 'save_btn')
    if save_btn then
        monstercardpreset:RemoveChild("save_btn")
    end
    local unequip = GET_CHILD(monstercardpreset, 'unequip')
    if unequip then
        monstercardpreset:RemoveChild("unequip")
    end
    local equip = GET_CHILD(monstercardpreset, 'equip')
    if equip then
        monstercardpreset:RemoveChild("equip")
    end
    local monstercardslot = ui.GetFrame('monstercardslot')
    local card_colors = {"red", "blue", "purple", "green"}
    for _, color in ipairs(card_colors) do
        local check_box = GET_CHILD(monstercardslot, color)
        if check_box then
            monstercardslot:RemoveChild(color)
        end
    end
end

function monster_card_changer_CARD_PRESET_CHANGE_NAME_EXEC(my_frame, my_msg)
    local input_frame, ctrl = g.get_event_args(my_msg)
    if g.settings.monster_card_changer.use == 0 then
        g.FUNCS["CARD_PRESET_CHANGE_NAME_EXEC"](input_frame, ctrl)
        return
    end
    local new_name = GET_INPUT_STRING_TXT(input_frame)
    local name_str = TRIM_STRING_WITH_SPACING(new_name)
    if name_str == '' then
        ui.SysMsg(ClMsg('InvalidStringOrUnderMinLen'))
        return
    end
    local monstercardpreset = ui.GetFrame('monstercardpreset')
    local drop_list = GET_CHILD(monstercardpreset, 'drop_list')
    AUTO_CAST(drop_list)
    local page = tonumber(drop_list:GetSelItemKey())
    g.monster_card_changer_settings.presets[page + 1].name = name_str
    monster_card_changer_save_settings()
    _DISABLE_CARD_PRESET_CHANGE_NAME_BTN()
    input_frame:ShowWindow(0)
    local monster_card_changer = ui.GetFrame(addon_name_lower .. "monster_card_changer")
    AUTO_CAST(monster_card_changer)
    monster_card_changer:SetUserValue("PAGE", page)
    monster_card_changer_preset_open(monster_card_changer)
end

function monster_card_changer_inventory_frame_init()
    local inventory = ui.GetFrame('inventory')
    local mcc = inventory:CreateOrGetControl("button", "mcc", 3, 345, 30, 30)
    AUTO_CAST(mcc)
    mcc:SetSkinName("test_red_button")
    mcc:SetTextAlign("right", "center")
    mcc:SetText("{img monsterbtn_image 28 23}{/}")
    mcc:SetTextTooltip(g.lang == "Japanese" and "{ol}カード自動搬出入、自動着脱{/}" or
                           "{ol}Automatic card loading/unloading, automatic insertion/removal{nl}")
    mcc:SetEventScript(ui.LBUTTONUP, "monster_card_changer_monstercardpreset_open")
    local monstercardslot = ui.GetFrame("monstercardslot")
    local applyBtn = GET_CHILD(monstercardslot, "applyBtn")
    AUTO_CAST(applyBtn)
    applyBtn:SetEventScript(ui.LBUTTONUP, "monster_card_changer_monstercardpreset_open")
end

function monster_card_changer_monstercardpreset_open()
    local monstercardpreset = ui.GetFrame('monstercardpreset')
    if monstercardpreset:IsVisible() == 1 then
        MONSTERCARDSLOT_CLOSE()
        return
    end
    MONSTERCARDSLOT_FRAME_OPEN()
    local preset_list = GET_CHILD_RECURSIVELY(monstercardpreset, "preset_list")
    AUTO_CAST(preset_list)
    preset_list:SelectItemByKey(4)
    local monster_card_changer = ui.CreateNewFrame("notice_on_pc", addon_name_lower .. "monster_card_changer", 0, 0, 0,
        0)
    AUTO_CAST(monster_card_changer)
    monster_card_changer:SetSkinName("None")
    monster_card_changer:SetVisible(1)
    monster_card_changer_preset_open(monster_card_changer)
end

function monster_card_changer_preset_open(monster_card_changer)
    local monstercardpreset = ui.GetFrame('monstercardpreset')
    CARD_PRESET_CLEAR_SLOT(monstercardpreset)
    local preset_list = GET_CHILD_RECURSIVELY(monstercardpreset, "preset_list")
    AUTO_CAST(preset_list)
    preset_list:SelectItemByKey(4)
    SetCardPreset(4, {}, {})
    monstercardpreset:RemoveChild("drop_list")
    local drop_list = monstercardpreset:CreateOrGetControl('droplist', 'drop_list', 45, 66, 178, 20)
    AUTO_CAST(drop_list)
    drop_list:SetSkinName('droplist_normal')
    drop_list:EnableHitTest(1)
    drop_list:SetTextAlign("center", "center")
    for i, preset_data in ipairs(g.monster_card_changer_settings.presets) do
        local preset_name = "{ol}" .. preset_data.name
        local scp = string.format("monster_card_changer_select_preset(%d)", i - 1)
        drop_list:AddItem(i - 1, preset_name, 0, scp)
    end
    local item_num = monster_card_changer:GetUserIValue("PAGE")
    drop_list:SelectItem(item_num)
    preset_list:ShowWindow(0)
    local saveBtn = GET_CHILD_RECURSIVELY(monstercardpreset, "saveBtn")
    saveBtn:ShowWindow(0)
    local save_btn = monstercardpreset:CreateOrGetControl("button", "save_btn", 340, 57, 70, 38)
    AUTO_CAST(save_btn)
    save_btn:SetText("{@st66b}SAVE")
    save_btn:SetSkinName("test_pvp_btn")
    save_btn:SetTextTooltip(g.lang == "Japanese" and
                                "{ol}現在装備中のカード情報を、現在のプリセットに呼び出します" or
                                "{ol}Load currently equipped card information{nl}into the current preset")
    save_btn:SetEventScript(ui.LBUTTONUP, "monster_card_changer_msgbox")
    local unequip = monstercardpreset:CreateOrGetControl("button", "unequip", 480, 57, 70, 38)
    AUTO_CAST(unequip)
    unequip:SetText("{@st66b}REMOVE")
    unequip:SetSkinName("test_pvp_btn")
    local accountwarehouse = ui.GetFrame("accountwarehouse")
    if accountwarehouse:IsVisible() == 1 then
        unequip:SetTextTooltip(g.lang == "Japanese" and
                                   "{ol}現在装備中のカードを取り外し、倉庫へ搬入します" or
                                   "{ol}Unequip currently equipped cards{nl}and transfer them to the warehouse")
    else
        unequip:SetTextTooltip(g.lang == "Japanese" and "{ol}現在装備中のカードを取り外します" or
                                   "{ol}Unequip currently equipped cards")
    end
    unequip:SetEventScript(ui.LBUTTONUP, "monster_card_changer_remove")
    local applyBtn = GET_CHILD_RECURSIVELY(monstercardpreset, "applyBtn")
    applyBtn:ShowWindow(0)
    local equip = monstercardpreset:CreateOrGetControl("button", "equip", 410, 57, 70, 38)
    AUTO_CAST(equip)
    equip:SetText("{@st66b}EQUIP")
    equip:SetSkinName("test_pvp_btn")
    equip:SetTextTooltip(
        g.lang == "Japanese" and "{ol}現在のプリセットへ、装備カードを変更します" or
            "{ol}Change equipped cards to the current preset")
    equip:SetEventScript(ui.LBUTTONUP, "monster_card_changer_equip_get_presetinfo")
    local monstercardslot = ui.GetFrame('monstercardslot')
    local mcc_settings = g.monster_card_changer_settings
    if not mcc_settings[g.login_name] then
        mcc_settings[g.login_name] = {}
    end
    local card_colors = {{
        name = "red",
        x = 50,
        y = 70
    }, {
        name = "blue",
        x = 365,
        y = 70
    }, {
        name = "purple",
        x = 50,
        y = 210
    }, {
        name = "green",
        x = 365,
        y = 210
    }}
    for _, color_info in ipairs(card_colors) do
        local color_name = color_info.name
        if not mcc_settings[g.login_name][color_name] then
            mcc_settings[g.login_name][color_name] = 0
        end
        local checkbox = monstercardslot:CreateOrGetControl('checkbox', color_name, color_info.x, color_info.y, 25, 25)
        AUTO_CAST(checkbox)
        checkbox:SetEventScript(ui.LBUTTONUP, "monster_card_changer_color_save")
        checkbox:SetEventScriptArgString(ui.LBUTTONUP, color_name)
        checkbox:SetCheck(mcc_settings[g.login_name][color_name])
        checkbox:SetTextTooltip(g.lang == "Japanese" and
                                    "{ol}チェックを入れると該当の色のカードを外しません" or
                                    "{ol}checked, cards of the specified color will not be unequipped")
    end
    monster_card_changer_save_settings()
    monster_card_changer:RunUpdateScript("monster_card_changer_preset_card_set", 1.0)
    return 0
end

function monster_card_changer_preset_card_set(monster_card_changer)
    local card_list = {}
    local exp_list = {}
    local monstercardpreset = ui.GetFrame("monstercardpreset")
    monstercardpreset:ShowWindow(1)
    local drop_list = GET_CHILD(monstercardpreset, "drop_list")
    local page = tonumber(drop_list:GetSelItemKey())
    local preset_data = g.monster_card_changer_settings.presets[page + 1].slots
    if not preset_data then
        return 0
    end
    for i, slot_data in ipairs(preset_data) do
        local card_id = slot_data.card_id
        if card_id and card_id ~= 0 then
            local card_exp = slot_data.card_exp or 0
            local card_lv = slot_data.card_lv or 0
            table.insert(card_list, card_id)
            table.insert(exp_list, card_exp)
        end
    end
    SetCardPreset(0, card_list, exp_list)
    MONSTERCARDPRESET_FRAME_OPEN()
    return 0
end

function monster_card_changer_select_preset(page)
    local monster_card_changer = ui.GetFrame(addon_name_lower .. "monster_card_changer")
    AUTO_CAST(monster_card_changer)
    monster_card_changer:SetUserValue("PAGE", page)
    monster_card_changer:RunUpdateScript("monster_card_changer_preset_card_set", 1.0)
end

function monster_card_changer_msgbox()
    local msg = g.lang == "Japanese" and
                    "現在装備中のカード情報を、プリセットに登録しますか？" or
                    "Do you want to save the currently equipped cards to the preset?"
    local yes_scp = string.format("monster_card_changer_save_preset()")
    ui.MsgBox(msg, yes_scp, "None")
end

function monster_card_changer_save_preset()
    local monstercardslot = ui.GetFrame("monstercardslot")
    local monstercardpreset = ui.GetFrame("monstercardpreset")
    local drop_list = GET_CHILD(monstercardpreset, "drop_list")
    local page = tonumber(drop_list:GetSelItemKey())
    if not g.monster_card_changer_settings.presets[page + 1] then
        return
    end
    local slots_settings = g.monster_card_changer_settings.presets[page + 1].slots
    for i = 1, 12 do
        local card_id, card_lv, card_exp = GETMYCARD_INFO(i - 1)
        if slots_settings[i] then
            slots_settings[i].card_id = card_id
            slots_settings[i].card_exp = card_exp
            slots_settings[i].card_lv = card_lv
        end
        _CARD_PRESET_SLOT_EQUIP(i, card_id, card_lv, card_exp)
    end
    monster_card_changer_save_settings()
end

function monster_card_changer_color_save(monstercardslot, checkbox, check_name)
    local is_check = checkbox:IsChecked()
    g.monster_card_changer_settings[g.login_name][check_name] = is_check
    monster_card_changer_save_settings()
end

function monster_card_changer_remove(monstercardpreset)
    g.monster_card_changer_cardlist = {}
    local mcc_settings = g.monster_card_changer_settings[g.login_name]
    local slot_to_color = {"red", "red", "red", "blue", "blue", "blue", "purple", "purple", "purple", "green", "green",
                           "green"}
    for i = 1, 12 do
        local group_name = CARD_SLOT_GET_GROUP_NAME(i - 1)
        local card_cls_id, card_lv, card_exp = GETMYCARD_INFO(i - 1)
        local color = slot_to_color[i]
        if color and mcc_settings[color] ~= 1 and card_cls_id ~= 0 then
            table.insert(g.monster_card_changer_cardlist, {card_cls_id, card_lv, group_name, nil})
        end
    end
    local preset_list = GET_CHILD_RECURSIVELY(monstercardpreset, "preset_list")
    AUTO_CAST(preset_list)
    local monster_card_changer = ui.GetFrame(addon_name_lower .. "monster_card_changer")
    AUTO_CAST(monster_card_changer)
    local page = tonumber(preset_list:GetSelItemKey())
    monster_card_changer:SetUserValue("PAGE", page)
    preset_list:SelectItemByKey(4)
    local page = 4
    pc.ReqExecuteTx_NumArgs("SCR_TX_APPLY_CARD_PRESET", page)
    local accountwarehouse = ui.GetFrame("accountwarehouse")
    if accountwarehouse:IsVisible() == 1 then
        local monster_card_changer = ui.GetFrame(addon_name_lower .. "monster_card_changer")
        AUTO_CAST(monster_card_changer)
        monster_card_changer:RunUpdateScript("monster_card_changer_get_guid", 1.0)
    end
end

function monster_card_changer_get_guid(monster_card_changer)
    local msg = g.lang == "Japanese" and
                    "{ol}{#CCCC22}[MCC]動作中。バグ防止の為他の動作は行わないでください" or
                    "{ol}{#CCCC22}[MCC]Operating. Please do not perform other operations to prevent bugs"
    imcAddOn.BroadMsg("NOTICE_Dm_Bell", msg, 2.5)
    local inventory = ui.GetFrame("inventory")
    local inventype_Tab = GET_CHILD_RECURSIVELY(inventory, "inventype_Tab")
    inventype_Tab:SelectTab(4)
    local inv_item_list = session.GetInvItemList()
    local guid_list = inv_item_list:GetGuidList()
    local cnt = guid_list:Count()
    g.monster_card_changer_group_counts = {
        ATK = 0,
        DEF = 0,
        UTIL = 0,
        STAT = 0
    }
    for i = 0, cnt - 1 do
        local guid = guid_list:Get(i)
        local inv_item = inv_item_list:GetItemByGuid(guid)
        local item_obj = GetIES(inv_item:GetObject())
        local item_lv = TryGetProp(item_obj, "Level", 0)
        for i, data in ipairs(g.monster_card_changer_cardlist) do
            if not data[4] then
                local cls_id = data[1]
                local card_lv = data[2]
                local group_name = data[3]
                if item_obj.ClassID == cls_id and card_lv == item_lv then
                    if g.monster_card_changer_group_counts[group_name] < 3 then
                        g.monster_card_changer_group_counts[group_name] =
                            g.monster_card_changer_group_counts[group_name] + 1
                        data[4] = guid
                        break
                    end
                end
            end
        end
    end
    local take = monster_card_changer:GetUserValue("TAKE")
    if take ~= "take" then
        monster_card_changer:RunUpdateScript("monster_card_changer_put_inv_to_warehouse", 0.1)
        return 0
    else
        return g.monster_card_changer_cardlist
    end
end

function monster_card_changer_put_inv_to_warehouse(monster_card_changer)
    if #g.monster_card_changer_cardlist == 0 then
        monster_card_changer_end_of_operation(monster_card_changer)
        return 0
    end
    local data = g.monster_card_changer_cardlist[1]
    local guid = data[4]
    local accountwarehouse = ui.GetFrame("accountwarehouse")
    local inventory = ui.GetFrame("inventory")
    if accountwarehouse:IsVisible() ~= 1 and inventory:IsVisible() ~= 1 then
        return 0
    end
    local inv_item = session.GetInvItemList():GetItemByGuid(guid)
    if inv_item then
        item.PutItemToWarehouse(IT_ACCOUNT_WAREHOUSE, guid, 1, accountwarehouse:GetUserIValue("HANDLE"), nil)
    else
        table.remove(g.monster_card_changer_cardlist, 1)
    end
    return 1
end

function monster_card_changer_equip_get_presetinfo()
    g.monster_card_changer_cardlist = {}
    local mcc_settings = g.monster_card_changer_settings[g.login_name]
    local slot_to_color = {"red", "red", "red", "blue", "blue", "blue", "purple", "purple", "purple", "green", "green",
                           "green"}
    for i = 0, 11 do
        local group_name = CARD_SLOT_GET_GROUP_NAME(i)
        local card_id, card_lv, card_exp = _GETMYCARD_INFO(i)
        local color = slot_to_color[i + 1]
        if mcc_settings[color] == 0 and card_id ~= 0 then
            table.insert(g.monster_card_changer_cardlist, {card_id, card_lv, group_name, nil})
        end
    end
    local accountwarehouse = ui.GetFrame("accountwarehouse")
    if accountwarehouse:IsVisible() == 1 then
        monster_card_changer_warehouse(accountwarehouse)
    else
        monster_card_changer_apply_card_preset()
    end
end

function monster_card_changer_warehouse(accountwarehouse)
    local monster_card_changer = ui.GetFrame(addon_name_lower .. "monster_card_changer")
    AUTO_CAST(monster_card_changer)
    monster_card_changer:SetUserValue("TAKE", "take")
    g.monster_card_changer_cardlist = monster_card_changer_get_guid(monster_card_changer)
    local item_list = session.GetEtcItemList(IT_ACCOUNT_WAREHOUSE)
    local guid_list = item_list:GetGuidList()
    local cnt = guid_list:Count()
    local take_list = {}
    for i = 0, cnt - 1 do
        local guid = guid_list:Get(i)
        local acw_item = item_list:GetItemByGuid(guid)
        local type = acw_item.type
        local item_obj = GetIES(acw_item:GetObject())
        local item_lv = TryGetProp(item_obj, "Level", 0)
        local group_counts = {
            ATK = 0,
            DEF = 0,
            UTIL = 0,
            STAT = 0
        }
        for i, data in ipairs(g.monster_card_changer_cardlist) do
            if not data[4] then
                local cls_id = data[1]
                local card_lv = data[2]
                local group_name = data[3]
                if type == cls_id and card_lv == item_lv then
                    if g.monster_card_changer_group_counts[group_name] < 3 then
                        g.monster_card_changer_group_counts[group_name] =
                            g.monster_card_changer_group_counts[group_name] + 1
                        data[4] = guid
                        take_list[guid] = 1
                        break
                    end
                end
            end
        end
    end
    session.ResetItemList()
    for guid, count in pairs(take_list) do
        session.AddItemID(tonumber(guid), count)
    end
    item.TakeItemFromWarehouse_List(IT_ACCOUNT_WAREHOUSE, session.GetItemIDList(),
        accountwarehouse:GetUserIValue("HANDLE"))
    monster_card_changer:RunUpdateScript("monster_card_changer_apply_card_preset", 1.0)
end

function monster_card_changer_apply_card_preset(monster_card_changer)
    pc.ReqExecuteTx_NumArgs("SCR_TX_APPLY_CARD_PRESET", 0)
    monster_card_changer_end_of_operation(monster_card_changer)
end

function monster_card_changer_end_of_operation(monster_card_changer)
    local take
    if monster_card_changer then
        take = monster_card_changer:GetUserValue("TAKE")
        monster_card_changer:SetUserValue("TAKE", "None")
    end
    g.monster_card_changer_cardlist = nil
    ui.SysMsg("[MCC]End of Operation")
    monster_card_changer:RunUpdateScript("monster_card_changer_preset_card_set", 1.0)
    if take == "take" then
        monster_card_changer:RunUpdateScript("MONSTERCARDSLOT_CLOSE", 1.5)
    end
end
-- monster_card_changer ここまで

-- market_voucher ここから
g.market_voucher_path = string.format("../addons/%s/%s/market_voucher.json", addon_name_lower, g.active_id)
g.market_voucher_old_path = string.format("../addons/%s/%s/settings_2507.json", "market_voucher", g.active_id)
g.market_voucher_log_path = string.format("../addons/%s/%s/market_voucher_log.txt", addon_name_lower, g.active_id)
g.market_voucher_old_log_path = string.format('../addons/%s/log_2507.txt', "market_voucher")
g.market_voucher_trans = {
    Japanese = {
        ["Sale Date/Time:"] = "販売日時 : ",
        ["Purchase Date/Time:"] = "購入日時 : ",
        ["name:"] = "名前 : ",
        ["item:"] = "アイテム: ",
        ["quantity:"] = "数量 : ",
        ["unit price:"] = "単価 : ",
        ["total amount:"] = "合計金額 : ",
        ["Total Sales:"] = "売上合計 : ",
        ["Period:"] = "集計期間 : ",
        ["Sales Slip"] = "売上伝票",
        ["Clear Log"] = "ログ削除",
        ["ClearedMsg"] = "販売履歴を削除しました。logtextには残っています。",
        ["CloseFrameTooltip"] = "左クリックでフレームを閉じます。",
        ["ClearLogTooltip"] = "販売履歴を削除します",
        ["sell"] = "販売",
        ["buy"] = "購入"
    },
    Default = {
        ["Sale Date/Time:"] = "Sale Date : ",
        ["Purchase Date/Time:"] = "Purch. Date : ",
        ["name:"] = "Name : ",
        ["item:"] = "Item : ",
        ["quantity:"] = "Qty : ",
        ["unit price:"] = "Unit Price : ",
        ["total amount:"] = "Total : ",
        ["Total Sales:"] = "Total Sales : ",
        ["Period:"] = "Period : ",
        ["Sales Slip"] = "Sales Slip",
        ["Clear Log"] = "Clear Log",
        ["ClearedMsg"] = "The sales history has been deleted. It remains in the log text.",
        ["CloseFrameTooltip"] = "Left-click to close the frame.",
        ["ClearLogTooltip"] = "Clear the sales history",
        ["sell"] = "Sell",
        ["buy"] = "Buy"
    }
}
function market_voucher_save_settings()
    g.save_json(g.market_voucher_path, g.market_voucher_settings)
end

function market_voucher_load_settings()
    local settings = g.load_json(g.market_voucher_path)
    if not settings then
        local old_settings = g.load_json(g.market_voucher_old_path)
        if old_settings then
            settings = old_settings
            local old_log_file = io.open(g.market_voucher_old_log_path, "r")
            if old_log_file then
                local content = old_log_file:read("*a")
                old_log_file:close()
                local new_log_file = io.open(g.market_voucher_log_path, "w")
                if new_log_file then
                    new_log_file:write(content)
                    new_log_file:close()
                end
            end
        else
            settings = {}
        end
    end
    g.market_voucher_settings = settings
    market_voucher_save_settings()
end

function market_voucher_on_init()
    if not g.market_voucher_settings then
        market_voucher_load_settings()
    end
    g.setup_hook_and_event(g.addon, "CABINET_GET_ALL_LIST", "market_voucher_CABINET_GET_ALL_LIST", false)
    g.setup_hook_and_event(g.addon, "_BUY_MARKET_ITEM", "market_voucher__BUY_MARKET_ITEM", false)
    g.setup_hook_and_event(g.addon, "_CABINET_ITEM_BUY", "market_voucher__CABINET_ITEM_BUY", false)
    g.addon:RegisterMsg("CABINET_ITEM_LIST", "market_voucher_init_frame")
end

function market_voucher_lang_trans(key)
    if g.market_voucher_trans[g.lang] and g.market_voucher_trans[g.lang][key] then
        return g.market_voucher_trans[g.lang][key]
    end
    return g.market_voucher_trans.Default[key] or key
end

function market_voucher_ui_text(key)
    return "{ol}" .. market_voucher_lang_trans(key)
end

function market_voucher_CABINET_GET_ALL_LIST(my_frame, my_msg)
    local fmarket_cabinet, control, strarg, now = g.get_event_args(my_msg)
    local item_count = session.market.GetCabinetItemCount()
    if item_count == 0 then
        return
    end
    local my_char_name = GETMYPCNAME()
    local results_table = {}
    for i = 0, item_count - 1 do
        local cabinet_item = session.market.GetCabinetItemByIndex(i)
        if cabinet_item then
            local where_from = cabinet_item:GetWhereFrom()
            if where_from == "market_sell" then
                local item_obj = GetIES(cabinet_item:GetObject())
                local item_name = dictionary.ReplaceDicIDInCompStr(item_obj.Name)
                local sanitized_item_name = string.gsub(item_name, "-", "?")
                local reg_time = cabinet_item:GetRegSysTime()
                local formatted_time = string.format("%04d-%02d-%02d %02d:%02d:%02d", reg_time.wYear, reg_time.wMonth,
                    reg_time.wDay, reg_time.wHour, reg_time.wMinute, reg_time.wSecond)
                local quantity = tonumber(cabinet_item.sellItemAmount)
                local total_amount = tonumber(cabinet_item:GetCount())
                local unit_price = 0
                if quantity > 0 then
                    unit_price = total_amount / quantity
                end
                local result_string = string.format("%s/%s/%s/%d/%d/%d/%s", formatted_time, my_char_name,
                    sanitized_item_name, quantity, unit_price, total_amount, "sell")
                table.insert(results_table, result_string)
            end
        end
    end
    for i, result_string in ipairs(results_table) do
        table.insert(g.market_voucher_settings, result_string)
    end
    market_voucher_save_settings()
    if #results_table > 0 then
        local all_results = table.concat(results_table, "\n")
        local file_handle = io.open(g.market_voucher_log_path, "a")
        if file_handle then
            file_handle:write(all_results .. "\n")
            file_handle:close()
        end
    end
    local count = session.market.GetCabinetItemCount()
    AddLuaTimerFuncWithLimitCount("CABINET_GET_ITEM", 200, count * 5)
    local market_cabinet_soldlist = ui.GetFrame("market_cabinet_soldlist")
    if market_cabinet_soldlist then
        ui.CloseFrame("market_cabinet_soldlist")
    end
end

function market_voucher__BUY_MARKET_ITEM(my_frame, my_msg)
    local row, is_recipe_search_box = g.get_event_args(my_msg)
    local frame = ui.GetFrame("market")
    local total_price = 0
    market.ClearBuyInfo()
    local market_item = nil
    local buy_count = nil
    if is_recipe_search_box and is_recipe_search_box == 1 then
        local recipeSearchGbox = GET_CHILD_RECURSIVELY(frame, "recipeSearchGbox")
        local child = recipeSearchGbox:GetChildByIndex(row - 1)
        local count = GET_CHILD_RECURSIVELY(child, "count")
        if count == nil then
            market_item = session.market.GetRecipeSearchByIndex(row - 1)
            market.AddBuyInfo(market_item:GetMarketGuid(), 1)
            total_price = SumForBigNumber(total_price, market_item:GetSellPrice())
        else
            buy_count = count:GetText()
            if tonumber(buy_count) > 0 then
                market_item = session.market.GetRecipeSearchByIndex(row - 1)
                market.AddBuyInfo(market_item:GetMarketGuid(), buy_count)
                total_price = SumForBigNumber(total_price, math.mul_int_for_lua(buy_count, market_item:GetSellPrice()))
            else
                ui.SysMsg(ScpArgMsg("YouCantBuyZeroItem"))
            end
        end
    else
        local itemListGbox = GET_CHILD_RECURSIVELY(frame, "itemListGbox")
        local child = itemListGbox:GetChildByIndex(row - 1)
        if child == nil then
            market_item = session.market.GetItemByIndex(row - 1)
            market.AddBuyInfo(market_item:GetMarketGuid(), 1)
            total_price = SumForBigNumber(total_price, market_item:GetSellPrice())
        else
            local count = GET_CHILD_RECURSIVELY(child, "count")
            buy_count = 1
            if count then
                buy_count = count:GetText()
            end
            if tonumber(buy_count) > 0 then
                market_item = session.market.GetItemByIndex(row - 1)
                market.AddBuyInfo(market_item:GetMarketGuid(), buy_count)
                total_price = SumForBigNumber(total_price, math.mul_int_for_lua(buy_count, market_item:GetSellPrice()))
            else
                ui.SysMsg(ScpArgMsg("YouCantBuyZeroItem"))
            end
        end
    end
    if total_price == 0 then
        return
    end
    if IsGreaterThanForBigNumber(total_price, GET_TOTAL_MONEY_STR()) == 1 then
        ui.SysMsg(ClMsg("NotEnoughMoney"))
        return
    end
    local limit_trade_str = GET_REMAIN_MARKET_TRADE_AMOUNT_STR()
    if limit_trade_str then
        if IsGreaterThanForBigNumber(total_price, limit_trade_str) == 1 then
            ui.SysMsg(ScpArgMsg('MarketMaxSilverLimit{LIMIT}Over', 'LIMIT', GET_COMMAED_STRING(limit_trade_str)))
            return
        end
    end
    local my_char_name = GETMYPCNAME()
    local item_obj = GetIES(market_item:GetObject())
    local item_name = dictionary.ReplaceDicIDInCompStr(item_obj.Name)
    local sanitized_item_name = string.gsub(item_name, "-", "?")
    local time = geTime.GetServerSystemTime()
    local formatted_time = string.format("%04d-%02d-%02d %02d:%02d:%02d", time.wYear, time.wMonth, time.wDay,
        time.wHour, time.wMinute, time.wSecond)
    local quantity = tonumber(buy_count)
    local total_amount = tonumber(total_price)
    local unit_price = 0
    if quantity > 0 then
        unit_price = total_amount / quantity
    end
    local result_string = string.format("%s/%s/%s/%d/%d/%d/%s", formatted_time, my_char_name, sanitized_item_name,
        quantity, unit_price, total_amount, "buy")
    table.insert(g.market_voucher_settings, result_string)
    local file_handle = io.open(g.market_voucher_log_path, "a")
    if file_handle then
        file_handle:write(result_string .. "\n")
        file_handle:close()
    end
    market_voucher_save_settings()
    market.ReqBuyItems()
end

function market_voucher__CABINET_ITEM_BUY(my_frame, my_msg)
    local frame, ctrl, guid = g.get_event_args(my_msg)
    local cabinet_item = session.market.GetCabinetItemByItemID(guid)
    local item_obj = GetIES(cabinet_item:GetObject())
    local item_name = dictionary.ReplaceDicIDInCompStr(item_obj.Name)
    local sanitized_item_name = string.gsub(item_name, "-", "?")
    local reg_time = cabinet_item:GetRegSysTime()
    local formatted_time = string.format("%04d-%02d-%02d %02d:%02d:%02d", reg_time.wYear, reg_time.wMonth,
        reg_time.wDay, reg_time.wHour, reg_time.wMinute, reg_time.wSecond)
    local quantity = tonumber(cabinet_item.sellItemAmount)
    local total_amount = tonumber(cabinet_item:GetCount())
    local unit_price = 0
    if quantity > 0 then
        unit_price = total_amount / quantity
    end
    local my_char_name = GETMYPCNAME()
    local result_string = string.format("%s/%s/%s/%d/%d/%d/%s", formatted_time, my_char_name, sanitized_item_name,
        quantity, unit_price, total_amount, "sell")
    table.insert(g.market_voucher_settings, result_string)
    local file_handle = io.open(g.market_voucher_log_path, "a")
    if file_handle then
        file_handle:write(result_string .. "\n")
        file_handle:close()
    end
    market_voucher_save_settings()
    market.ReqGetCabinetItem(guid)
    local market_cabinet_popup = ui.GetFrame("market_cabinet_popup")
    if market_cabinet_popup then
        ui.CloseFrame("market_cabinet_popup")
    end
end

function market_voucher_init_frame()
    local market_cabinet = ui.GetFrame("market_cabinet")
    if g.settings.market_voucher.use == 0 then
        local log_btn = GET_CHILD(market_cabinet, "log_btn")
        if log_btn then
            DESTROY_CHILD_BYNAME(market_cabinet, "log_btn")
        end
        return
    end
    local log_btn = market_cabinet:CreateOrGetControl("button", "log_btn", 610, 120, 100, 30)
    AUTO_CAST(log_btn)
    log_btn:SetSkinName("tab2_btn")
    local text = "{@st66b18}" .. market_voucher_lang_trans("Sales Slip")
    log_btn:SetText(text)
    log_btn:SetEventScript(ui.LBUTTONUP, "market_voucher_print")
    log_btn:ShowWindow(1)
end

function market_voucher_print()
    if #g.market_voucher_settings == 0 then
        return
    end
    local market_voucher = ui.CreateNewFrame("notice_on_pc", addon_name_lower .. "market_voucher", 0, 0, 0, 0)
    AUTO_CAST(market_voucher)
    market_voucher:SetSkinName("downbox")
    market_voucher:ShowTitleBar(0)
    market_voucher:SetOffset(15, 175)
    market_voucher:Resize(1280, 770)
    market_voucher:EnableHitTest(1)
    market_voucher:SetLayerLevel(100)
    local bg = market_voucher:CreateOrGetControl("groupbox", "bg", 5, 5, 1270, 720)
    AUTO_CAST(bg)
    bg:SetSkinName("chat_window")
    bg:SetTextTooltip(market_voucher_ui_text("CloseFrameTooltip"))
    bg:SetEventScript(ui.LBUTTONUP, "market_voucher_print_close")
    local log_delete_button = market_voucher:CreateOrGetControl("button", "logdelete", 1180, 735, 80, 30)
    AUTO_CAST(log_delete_button)
    log_delete_button:SetTextTooltip(market_voucher_ui_text("ClearLogTooltip"))
    log_delete_button:SetText(market_voucher_ui_text("Clear Log"))
    log_delete_button:SetEventScript(ui.LBUTTONUP, "market_voucher_clear")
    local close_button = market_voucher:CreateOrGetControl("button", "close", 1245, 0, 30, 30)
    AUTO_CAST(close_button)
    close_button:SetImage("testclose_button")
    close_button:SetEventScript(ui.LBUTTONUP, "market_voucher_print_close")
    local sumtotal_amount = 0
    table.sort(g.market_voucher_settings, function(a, b)
        return a > b
    end)
    local item_count = #g.market_voucher_settings
    local y_pos = 5
    for i = 1, item_count do
        local tokens = StringSplit(g.market_voucher_settings[i], '/')
        local date_str = tokens[1]
        local name_str = tokens[2]
        local item_str = string.gsub(tokens[3], "?", "-")
        local quantity_str = tokens[4]
        local unit_price_val = tonumber(tokens[5])
        local total_amount_val = tonumber(tokens[6])
        local status = tokens[7]
        local line_text = ""
        if status == "sell" then
            status = market_voucher_ui_text(status)
            sumtotal_amount = sumtotal_amount + total_amount_val
            unit_price_val = unit_price_val / 0.9
            line_text = string.format("%s%s ･ %s ･ %s ･ %s%s ･ %s%s ･ %s%s ･ %s",
                market_voucher_lang_trans("Sale Date/Time:"), date_str, name_str, item_str,
                market_voucher_lang_trans("quantity:"), quantity_str, market_voucher_lang_trans("unit price:"),
                GET_COMMAED_STRING(unit_price_val), market_voucher_lang_trans("total amount:"),
                GET_COMMAED_STRING(total_amount_val), status)
        elseif status == "buy" then
            status = market_voucher_ui_text(status)
            sumtotal_amount = sumtotal_amount - total_amount_val
            line_text = "{#DAA520}" .. string.format("%s%s ･ %s ･ %s ･ %s%s ･ %s%s ･ %s△%s ･ %s",
                market_voucher_lang_trans("Purchase Date/Time:"), date_str, name_str, item_str,
                market_voucher_lang_trans("quantity:"), quantity_str, market_voucher_lang_trans("unit price:"),
                GET_COMMAED_STRING(unit_price_val), market_voucher_lang_trans("total amount:"),
                GET_COMMAED_STRING(total_amount_val), status)
        end
        local text_view = bg:CreateOrGetControl("richtext", "textview" .. i, 5, y_pos)
        AUTO_CAST(text_view)
        text_view:SetText("{ol}" .. line_text)
        y_pos = y_pos + 20
    end
    local date_pattern = "^(%d%d%d%d%-%d%d%-%d%d)"
    local latest_date_str = string.match(g.market_voucher_settings[1], date_pattern)
    local earliest_date_str = string.match(g.market_voucher_settings[item_count], date_pattern)
    local sum_total_amount_text = market_voucher:CreateOrGetControl("richtext", "sumtotal_amount_text", 900, 740, 100,
        30)
    local rounded_number = math.floor(sumtotal_amount / 1000000 + 0.5)
    sum_total_amount_text:SetText("{#FF0000}" .. market_voucher_ui_text("Total Sales:") ..
                                      GET_COMMAED_STRING(sumtotal_amount) .. "(" .. GET_COMMAED_STRING(rounded_number) ..
                                      "M)")
    sum_total_amount_text:ShowWindow(1)
    local period_text = market_voucher:CreateOrGetControl("richtext", "date_text", 620, 740, 100, 30)
    period_text:SetText(market_voucher_ui_text("Period:") .. earliest_date_str .. "～" .. latest_date_str)
    market_voucher:ShowWindow(1)
    market_voucher:RunUpdateScript("market_voucher_auto_close", 0.3)
end

function market_voucher_auto_close(market_voucher)
    local market_cabinet = ui.GetFrame("market_cabinet")
    if market_cabinet:IsVisible() == 1 then
        return 1
    else
        ui.DestroyFrame(market_voucher:GetName())
        market_cabinet:RemoveChild("log_btn")
        return 0
    end
end

function market_voucher_clear()
    g.market_voucher_settings = {}
    ui.SysMsg(market_voucher_ui_text("ClearedMsg"))
    market_voucher_save_settings()
end

function market_voucher_print_close()
    local market_voucher = ui.GetFrame(addon_name_lower .. "market_voucher")
    ui.DestroyFrame(market_voucher:GetName())
end
-- market_voucher ここまで

-- lets_go_home　ここから
g.lets_go_home_path = string.format("../addons/%s/%s/lets_go_home.json", addon_name_lower, g.active_id)
function lets_go_home_save_settings()
    g.save_json(g.lets_go_home_path, g.lets_go_home_settings)
end

function lets_go_home_load_settings()
    local settings = g.load_json(g.lets_go_home_path)
    if not settings then
        settings = {
            map = "",
            ch = 1,
            leticia = 0,
            x = 0,
            y = 0,
            move = 1,
            display = 1,
            short_cut = 1
        }
    end
    g.lets_go_home_settings = settings
    lets_go_home_save_settings()
end

function lets_go_home_on_init()
    if not g.lets_go_home_settings then
        lets_go_home_load_settings()
    end
    if g.settings.lets_go_home.use == 0 then
        local lets_go_home = ui.GetFrame(addon_name_lower .. "lets_go_home")
        if lets_go_home then
            ui.DestroyFrame(lets_go_home:GetName())
        end
        local all_in_one = ui.GetFrame("all_in_one")
        all_in_one:SetVisible(1)
        local lets_go_home_timer = GET_CHILD(all_in_one, "lets_go_home_timer")
        if lets_go_home_timer then
            AUTO_CAST(lets_go_home_timer)
            lets_go_home_timer:Stop()
        end
        return
    end
    lets_go_home_frame_init()
    if g.lets_go_home_warp_state == 1 then
        lets_go_home_change_move()
    end
end

function lets_go_home_frame_init()
    local all_in_one = ui.GetFrame("all_in_one")
    all_in_one:SetVisible(1)
    local lets_go_home_timer = all_in_one:CreateOrGetControl("timer", "lets_go_home_timer", 0, 0)
    AUTO_CAST(lets_go_home_timer)
    lets_go_home_timer:SetUpdateScript("lets_go_home_key_press")
    lets_go_home_timer:Start(0.2)
    if g.lets_go_home_settings.display == 0 then
        return
    end
    local lets_go_home = ui.CreateNewFrame("notice_on_pc", addon_name_lower .. "lets_go_home", 0, 0, 0, 0)
    AUTO_CAST(lets_go_home)
    lets_go_home:SetSkinName('None')
    lets_go_home:SetTitleBarSkin("None")
    lets_go_home:Resize(40, 30)
    lets_go_home:SetGravity(ui.RIGHT, ui.TOP)
    lets_go_home:EnableHitTest(1)
    lets_go_home:EnableHittestFrame(1)
    lets_go_home:EnableMove(g.lets_go_home_settings.move)
    local rect = lets_go_home:GetMargin()
    lets_go_home:SetMargin(rect.left - rect.left, rect.top - rect.top + 305, rect.right + 305, rect.bottom)
    if g.lets_go_home_settings.x ~= 0 and g.lets_go_home_settings.y ~= 0 then
        lets_go_home:SetPos(g.lets_go_home_settings.x, g.lets_go_home_settings.y)
    end
    local btn = lets_go_home:CreateOrGetControl('button', 'home', 0, 0, 30, 30)
    AUTO_CAST(btn)
    btn:SetGravity(ui.LEFT, ui.TOP)
    btn:SetSkinName("None")
    btn:SetText("{img btn_housing_editmode_small_resize 30 30}")
    btn:SetTextTooltip(g.lang == "Japanese" and
                           "{ol}右クリック:ホーム設定{nl}左クリック:ワープ{nl}ショートカット:BackSlash+RSHIFT" or
                           "{ol}Rightclick:Home Setting{nl}Leftclick:Warp{nl}Shortcut:BackSlash+RSHIFT")
    btn:SetEventScript(ui.RBUTTONUP, "lets_go_home_settings")
    btn:SetEventScript(ui.LBUTTONDOWN, "lets_go_home_warp_do")
    lets_go_home:ShowWindow(1)
    btn:SetEventScript(ui.LBUTTONUP, "lets_go_home_frame_move_save")
    lets_go_home:RunUpdateScript("lets_go_home_update_frame", 1.0)
end

function lets_go_home_frame_move_save(lets_go_home)
    g.lets_go_home_settings.x = lets_go_home:GetX()
    g.lets_go_home_settings.y = lets_go_home:GetY()
    lets_go_home_save_settings()
end

function lets_go_home_settings_frame_close(list_frame)
    ui.DestroyFrame(list_frame:GetName())
end

function lets_go_home_settings_frame()
    local list_frame_name = addon_name_lower .. "list_frame"
    local list_frame = ui.GetFrame(addon_name_lower .. "list_frame")
    local lets_go_home_setting = ui.CreateNewFrame("notice_on_pc", addon_name_lower .. "lets_go_home_setting", 0, 0, 0,
        0)
    lets_go_home_setting:Resize(370, 250)
    lets_go_home_setting:SetPos(list_frame:GetX() + list_frame:GetWidth(), list_frame:GetY())
    lets_go_home_setting:SetSkinName("test_frame_low")
    lets_go_home_setting:EnableHittestFrame(1)
    lets_go_home_setting:EnableHitTest(1)
    lets_go_home_setting:ShowWindow(1)
    local title_text = lets_go_home_setting:CreateOrGetControl('richtext', 'title_text', 20, 15, 50, 30)
    AUTO_CAST(title_text)
    title_text:SetText("{ol}Lets Go Home Config")
    local close = lets_go_home_setting:CreateOrGetControl("button", "close", 0, 0, 20, 20)
    AUTO_CAST(close)
    close:SetImage("testclose_button")
    close:SetGravity(ui.RIGHT, ui.TOP)
    close:SetEventScript(ui.LBUTTONUP, "lets_go_home_settings_frame_close")
    local gbox = lets_go_home_setting:CreateOrGetControl("groupbox", "gbox", 10, 40,
        lets_go_home_setting:GetWidth() - 20, lets_go_home_setting:GetHeight() - 50)
    AUTO_CAST(gbox)
    gbox:SetSkinName("test_frame_midle_light")
    local map_text = gbox:CreateOrGetControl('richtext', 'map_text', 10, 10, 150, 30)
    AUTO_CAST(map_text)
    map_text:SetText(g.lang == "Japanese" and "{ol}ホームタウン" or "{ol}Hometown")
    local map_drop_list = gbox:CreateOrGetControl('droplist', 'map_drop_list', 150, 10, 180, 20)
    AUTO_CAST(map_drop_list)
    map_drop_list:SetSkinName('droplist_normal')
    map_drop_list:EnableHitTest(1)
    map_drop_list:SetTextAlign("center", "center")
    local citys = {"c_Klaipe", "c_orsha", "c_fedimian"}
    local selected_index = 0
    map_drop_list:AddItem(0, g.lang == "Japanese" and "{ol}未設定" or "{ol}None", 0, "lets_go_home_map_settings('')")
    for i, city_class_name in ipairs(citys) do
        local map_cls = GetClass("Map", city_class_name)
        if map_cls then
            local scp = string.format("lets_go_home_map_settings('%s')", city_class_name)
            map_drop_list:AddItem(i, "{ol}" .. map_cls.Name, 0, scp)
            if g.lets_go_home_settings.map == city_class_name then
                selected_index = i
            end
        end
    end
    map_drop_list:SelectItem(selected_index)
    local ch_text = gbox:CreateOrGetControl('richtext', 'ch_text', 10, 40, 150, 30)
    AUTO_CAST(ch_text)
    ch_text:SetText(g.lang == "Japanese" and "{ol}チャンネル" or "{ol}Channel")
    local ch_drop_list = gbox:CreateOrGetControl('droplist', 'ch_drop_list', 150, 40, 180, 20)
    AUTO_CAST(ch_drop_list)
    ch_drop_list:SetSkinName('droplist_normal')
    ch_drop_list:EnableHitTest(1)
    ch_drop_list:SetTextAlign("center", "center")
    for i = 1, 10 do
        local scp = string.format("lets_go_home_ch_settings(%d)", i)
        ch_drop_list:AddItem(i - 1, "{ol}" .. tostring(i) .. " ch", 0, scp)
        if g.lets_go_home_settings.ch == i then
            selected_index = i - 1
        end
    end
    ch_drop_list:SelectItem(selected_index)
    local btn_move = gbox:CreateOrGetControl('checkbox', "btn_move", 10, 70, 30, 30)
    AUTO_CAST(btn_move)
    btn_move:SetText(g.lang == "Japanese" and "{ol}ボタン位置固定" or "{ol}Fix button position")
    btn_move:SetTextTooltip(g.lang == "Japanese" and "{ol}チェックするとボタン固定" or
                                "{ol}Checked: the button is fixed")
    btn_move:SetEventScript(ui.LBUTTONUP, "lets_go_home_check_toggle")
    btn_move:SetCheck(g.lets_go_home_settings.move)
    local btn = gbox:CreateOrGetControl('button', 'home', 210, 70, 80, 30)
    AUTO_CAST(btn)
    btn:SetText(g.lang == "Japanese" and "{ol}ボタン初期位置" or "{ol}Btn Init Pos")
    btn:SetEventScript(ui.LBUTTONUP, "lets_go_home_init_pos")
    local btn_display = gbox:CreateOrGetControl('checkbox', "btn_display", 10, 100, 30, 30)
    AUTO_CAST(btn_display)
    btn_display:SetText(g.lang == "Japanese" and "{ol}ボタン表示設定" or "{ol}Button display settings")
    btn_display:SetTextTooltip(g.lang == "Japanese" and "{ol}チェックするとボタン表示" or
                                   "{ol}Checked: the button is shown")
    btn_display:SetEventScript(ui.LBUTTONUP, "lets_go_home_check_toggle")
    btn_display:SetCheck(g.lets_go_home_settings.display)
    local short_cut = gbox:CreateOrGetControl('checkbox', "short_cut", 10, 130, 30, 30)
    AUTO_CAST(short_cut)
    short_cut:SetText(g.lang == "Japanese" and "{ol}ショートカット設定(BackSlash+RSHIFT)" or
                          "{ol}Shortcut Setting(BackSlash+RSHIFT)")
    short_cut:SetTextTooltip(g.lang == "Japanese" and "{ol}チェックするとショートカット有効化" or
                                 "{ol}Checked: enables the shortcut")
    short_cut:SetEventScript(ui.LBUTTONUP, "lets_go_home_check_toggle")
    short_cut:SetCheck(g.lets_go_home_settings.short_cut)
    local leticia = gbox:CreateOrGetControl('checkbox', "leticia", 10, 160, 30, 30)
    AUTO_CAST(leticia)
    leticia:SetText(g.lang == "Japanese" and "{ol}レティーシア移動設定" or "{ol}Leticia Move Settings")
    leticia:SetTextTooltip(g.lang == "Japanese" and "{ol}チェックするとレティーシア移動有効化" or
                               "{ol}Checked: enables the Leticia Move")
    leticia:SetEventScript(ui.LBUTTONUP, "lets_go_home_check_toggle")
    leticia:SetCheck(g.lets_go_home_settings.leticia)
end

function lets_go_home_map_settings(city_class_name)
    g.lets_go_home_settings.map = city_class_name
    lets_go_home_save_settings()
end

function lets_go_home_ch_settings(channel)
    g.lets_go_home_settings.ch = channel
    lets_go_home_save_settings()
end

function lets_go_home_check_toggle(parent, ctrl)
    local ctrl_name = ctrl:GetName()
    local is_check = ctrl:IsChecked()
    if ctrl_name == "btn_move" then
        g.lets_go_home_settings.move = is_check
    elseif ctrl_name == "btn_display" then
        g.lets_go_home_settings.display = is_check
        if is_check == 0 then
            local lets_go_home = ui.GetFrame(addon_name_lower .. "lets_go_home")
            if lets_go_home then
                ui.DestroyFrame(lets_go_home:GetName())
            end
        else
            lets_go_home_frame_init()
        end
    elseif ctrl_name == "short_cut" then
        g.lets_go_home_settings.short_cut = is_check
    elseif ctrl_name == "leticia" then
        g.lets_go_home_settings.leticia = is_check
    end
    lets_go_home_save_settings()
end

function lets_go_home_init_pos()
    g.lets_go_home_settings.x = 0
    g.lets_go_home_settings.y = 0
    lets_go_home_save_settings()
    local lets_go_home = ui.GetFrame(addon_name_lower .. "lets_go_home")
    if lets_go_home then
        ui.DestroyFrame(lets_go_home:GetName())
    end
    ReserveScript("lets_go_home_frame_init()", 0.1)
end

function lets_go_home_settings()
    if g.get_map_type() == "City" then
        local msg = g.lang == "Japanese" and "現在のマップとチャンネルをホームにしますか？" or
                        "Do you want to home in on the current map and channel?"
        local yes_scp = string.format("lets_go_home_settings_reg()")
        ui.MsgBox(msg, yes_scp, "None")
    else
        ui.SysMsg(g.lang == "Japanese" and "このマップは設定できません" or "This map cannot be set up")
    end
end

function lets_go_home_settings_reg()
    local channel = session.loginInfo.GetChannel() + 1
    local map_cls = GetClass("Map", g.map_name)
    local map_clas_name = map_cls.ClassName
    local map_name = map_cls.Name
    g.lets_go_home_settings.ch = channel
    g.lets_go_home_settings.map = map_clas_name
    g.lets_go_home_settings.leticia = 0
    ui.SysMsg(g.lang == "Japanese" and "マップ名: " .. map_name .. " チャンネル: " .. channel ..
                  "を登録{nl}レティーシャへの移動を無効にしました" or "MapName: " .. map_name ..
                  " Channel: " .. channel .. "Registered{nl}Move to Leticia disabled")
    lets_go_home_save_settings()
    local msg = g.lang == "Japanese" and "レティーシャへ移動は使用しますか？" or
                    "Do you use Move to Leticia?"
    local yes_scp = string.format("lets_go_home_settings_reg_()")
    ui.MsgBox(msg, yes_scp, "None")
end

function lets_go_home_settings_reg_()
    ui.SysMsg(g.lang == "Japanese" and "レティーシャへの移動を有効にしました" or
                  "Move to Leticia enabled")
    g.lets_go_home_settings.leticia = 1
    lets_go_home_save_settings()
end

function lets_go_home_update_frame(lets_go_home)
    local home = GET_CHILD(lets_go_home, "home")
    local cd_text = home:CreateOrGetControl('richtext', 'cd_text', 5, 10)
    AUTO_CAST(cd_text)
    local cd = GET_TOKEN_WARP_COOLDOWN()
    cd_text:SetText("{ol}{#FFFFFF}{s13}" .. cd)
    if cd >= 100 then
        cd_text:ShowWindow(1)
        return 1
    elseif cd < 100 and cd >= 10 then
        cd_text:SetOffset(9, 10)
        return 1
    elseif cd < 10 and cd >= 1 then
        cd_text:SetOffset(13, 10)
        return 1
    else
        cd_text:ShowWindow(0)
        return 0
    end
end

function lets_go_home_warp_do()
    local all_in_one = ui.GetFrame("all_in_one")
    g.lets_go_home_warp_state = 1
    lets_go_home_change_move(all_in_one)
end

function lets_go_home_key_press()
    if g.lets_go_home_settings.short_cut == 0 then
        return
    end
    if 1 == keyboard.IsKeyPressed("BACKSLASH") and 1 == keyboard.IsKeyPressed("RSHIFT") then
        g.lets_go_home_warp_state = 1
        lets_go_home_change_move()
    end
end

function lets_go_home_change_move()
    if ENABLE_WARP_CHECK(GetMyPCObject()) == false then
        ui.SysMsg(ScpArgMsg("WarpBanBountyHunt"))
        g.lets_go_home_warp_state = 0
        return
    end
    local save_map = g.lets_go_home_settings.map
    if save_map == "" then
        ui.MsgBox(g.lang == "Japanese" and "マップ未設定です" or "Not Map setting")
        g.lets_go_home_warp_state = 0
        return
    end
    local quests = {
        ["c_Klaipe"] = {{
            quest_id = 91055,
            result = "POSSIBLE",
            state = "Start"
        }, {
            quest_id = 72165,
            result = "SUCCESS",
            state = "End"
        }},
        ["c_orsha"] = {{
            quest_id = 90170,
            result = "SUCCESS",
            state = "End"
        }, {
            quest_id = 90171,
            result = "SUCCESS",
            state = "End"
        }},
        ["c_fedimian"] = {{
            quest_id = 60400,
            result = "POSSIBLE",
            state = "Start"
        }}
    }
    if save_map ~= g.map_name then
        local pc = GetMyPCObject()
        local quest_id = nil
        for key, value in pairs(quests) do
            if key == save_map then
                for key2, value2 in pairs(value) do
                    local questIES = GetClassByType('QuestProgressCheck', value2.quest_id)
                    local result = SCR_QUEST_CHECK_C(pc, questIES.ClassName)
                    local questState = GET_QUEST_NPC_STATE(questIES, result)
                    if result == value2.result and questState == value2.state then
                        quest_id = value2.quest_id
                        break
                    end
                end
            end
        end
        if quest_id then
            QUESTION_QUEST_WARP(nil, nil, nil, quest_id)
        else
            lets_go_home_not_quest_warp(save_map)
        end
        return
    end
    local save_ch = g.lets_go_home_settings.ch
    local channel = session.loginInfo.GetChannel() + 1
    if channel ~= save_ch then
        RUN_GAMEEXIT_TIMER("Channel", save_ch - 1)
        return
    end
    g.lets_go_home_warp_state = 0
    local leticia_warp = g.lets_go_home_settings.leticia
    if leticia_warp == 1 then
        lets_go_home_leticia_move()
    end
end

function lets_go_home_not_quest_warp(save_map)
    local cd = GET_TOKEN_WARP_COOLDOWN()
    if cd == 0 then
        g.lets_go_home_warp_state = 1
        WORLDMAP2_TOKEN_WARP_REQUEST(save_map)
        return
    end
    local warp_items = {
        ["c_Klaipe"] = 640073,
        ["c_orsha"] = 640156,
        ["c_fedimian"] = 640182
    }
    session.ResetItemList()
    local inv_item_list = session.GetInvItemList()
    local guid_list = inv_item_list:GetGuidList()
    local cnt = guid_list:Count()
    for i = 0, cnt - 1 do
        local guid = guid_list:Get(i)
        local inv_item = inv_item_list:GetItemByGuid(guid)
        local item_obj = GetIES(inv_item:GetObject())
        local target_id = warp_items[save_map]
        if item_obj.ClassID == target_id and g.map_name ~= save_map then
            if TRY_TO_USE_WARP_ITEM(inv_item, item_obj) ~= 1 then
                g.lets_go_home_warp_state = 1
                INV_ICON_USE(inv_item)
                return
            end
        end
    end
    ui.MsgBox(g.lang == "Japanese" and "ワープする方法がありません" or "There is no way to warp")
    g.lets_go_home_warp_state = 0
end

function lets_go_home_leticia_move()
    local guid = 309
    local cls = GetClassByType("full_screen_navigation_menu", guid)
    if cls ~= nil then
        local name = TryGetProp(cls, "Name", "None")
        local move_zone_select = TryGetProp(cls, "MoveZoneSelect", "NO")
        local move_zone = TryGetProp(cls, "MoveZone", "None")
        local move_npc_dialog = TryGetProp(cls, "MoveNpcDialog", "None")
        local move_zone_select_msg = TryGetProp(cls, "MoveZoneSelectMsg", "None")
        local move_only_in_town = TryGetProp(cls, "MoveOnlyInTown", "None")
        if move_zone ~= "None" and move_npc_dialog ~= "None" then
            local pc = GetMyPCObject()
            if session.world.IsIntegrateServer() == true or IsPVPField(pc) == 1 or IsPVPServer(pc) == 1 then
                ui.SysMsg(ScpArgMsg("ThisLocalUseNot"))
                return
            end
            if world.GetLayer() ~= 0 then
                ui.SysMsg(ScpArgMsg("ThisLocalUseNot"))
                return
            end
            if g.get_map_type() == "Dungeon" then
                ui.SysMsg(ScpArgMsg("ThisLocalUseNot"))
                return
            end
            local cur_map = GetClass("Map", session.GetMapName())
            local zoneKeyword = TryGetProp(cur_map, 'Keyword', 'None')
            local keywordTable = StringSplit(zoneKeyword, '')
            if table.find(keywordTable, 'IsRaidField') > 0 or table.find(keywordTable, 'WeeklyBossMap') > 0 then
                ui.SysMsg(ScpArgMsg('ThisLocalUseNot'))
                return
            end
            FullScreenMenuMoveNpc(name, move_zone_select, move_zone, move_npc_dialog, move_zone_select_msg,
                move_only_in_town)
            ui.CloseFrame("fullscreen_navigation_menu")
        end
    end
end
-- lets_go_home　ここまで

-- pick_item_tracker ここから
g.pick_item_tracker_path = string.format("../addons/%s/%s/pick_item_tracker.json", addon_name_lower, g.active_id)
g.pick_item_tracker_grade_colors = {
    [0] = "#FFBF33", -- Unique
    [1] = "#FFFFFF", -- Normal
    [2] = "#108CFF", -- Magic
    [3] = "#9F30FF", -- Rare
    [4] = "#FF4F00", -- Legend
    [5] = "#FFFF53" -- Goddess
}
function pick_item_tracker_save_settings()
    g.save_json(g.pick_item_tracker_path, g.pick_item_tracker_settings)
end

function pick_item_tracker_load_settings()
    local settings = g.load_json(g.pick_item_tracker_path)
    if not settings then
        settings = {
            move = 1,
            x = 330,
            y = 330
        }
    end
    g.pick_item_tracker_settings = settings
    pick_item_tracker_save_settings()
end

function pick_item_tracker_on_init()
    if not g.pick_item_tracker_settings then
        pick_item_tracker_load_settings()
    end
    if g.get_map_type() ~= "City" and g.get_map_type() ~= "Instance" then
        if not g.pick_item_tracker_map_id or g.map_id ~= g.pick_item_tracker_map_id then
            g.pick_item_tracker_map_id = g.map_id
            g.pick_item_tracker_start_time = imcTime.GetAppTimeMS() - 3000
            g.pick_item_tracker_items = {}
            g.pick_item_tracker_y = 45
            g.pick_item_tracker_x = 120
        end
        g.addon:RegisterMsg('ITEM_PICK', 'pick_item_tracker_ITEMMSG_ITEM_COUNT')
        pick_item_tracker_frame_init()
    else
        g.pick_item_tracker_items = {}
        g.pick_item_tracker_y = 45
        g.pick_item_tracker_x = 120
        pick_item_tracker_frame_init("is_city")
    end
end

function pick_item_tracker_frame_init(msg)
    local pick_item_tracker = ui.CreateNewFrame("chat_memberlist", addon_name_lower .. "pick_item_tracker", 0, 0, 0, 0)
    AUTO_CAST(pick_item_tracker)
    pick_item_tracker:EnableHitTest(1)
    pick_item_tracker:EnableHittestFrame(1)
    pick_item_tracker:EnableMove(g.pick_item_tracker_settings.move)
    pick_item_tracker:SetPos(g.pick_item_tracker_settings.x, g.pick_item_tracker_settings.y)
    pick_item_tracker:SetTitleBarSkin("None")
    pick_item_tracker:SetSkinName("None")
    pick_item_tracker:SetLayerLevel(61)
    pick_item_tracker:SetEventScript(ui.LBUTTONUP, "pick_item_tracker_frame_move")
    pick_item_tracker:SetEventScript(ui.RBUTTONUP, "pick_item_tracker_frame_lock")
    local title_text = pick_item_tracker:CreateOrGetControl("richtext", "title_text", 20, 10)
    AUTO_CAST(title_text)
    title_text:SetText("{ol}{S10}Pick Item Tracker")
    title_text:SetTextTooltip("{ol}Right click to position lock")
    title_text:SetEventScript(ui.LBUTTONUP, "pick_item_tracker_frame_move")
    title_text:SetEventScript(ui.RBUTTONUP, "pick_item_tracker_frame_lock")
    local itemlock = pick_item_tracker:CreateOrGetControlSet('inv_itemlock', "itemlock", 0, 0)
    AUTO_CAST(itemlock)
    itemlock:SetGravity(ui.LEFT, ui.TOP)
    if g.pick_item_tracker_settings.move == 1 then
        itemlock:SetGrayStyle(1)
    else
        itemlock:SetGrayStyle(0)
    end
    pick_item_tracker:Resize(120, g.pick_item_tracker_y or 25)
    local gb = pick_item_tracker:CreateOrGetControl("groupbox", "gb", 0, 45, 90, pick_item_tracker:GetHeight() - 45)
    gb:SetSkinName("None")
    AUTO_CAST(gb)
    pick_item_tracker_redraw_item_list(pick_item_tracker)
    local time_text = pick_item_tracker:CreateOrGetControl("richtext", "time_text", 25, 25)
    AUTO_CAST(time_text)
    if msg == "is_city" then
        pick_item_tracker:ShowWindow(0)
    else
        local pick_item_tracker_timer = pick_item_tracker:CreateOrGetControl("timer", "pick_item_tracker_timer", 0, 0)
        AUTO_CAST(pick_item_tracker_timer)
        pick_item_tracker_timer:SetUpdateScript("pick_item_tracker_timer_update")
        pick_item_tracker_timer:Start(1.0)
        pick_item_tracker:ShowWindow(1)
    end
end

function pick_item_tracker_frame_move(pick_item_tracker)
    g.pick_item_tracker_settings.x = pick_item_tracker:GetX()
    g.pick_item_tracker_settings.y = pick_item_tracker:GetY()
    pick_item_tracker_save_settings()
end

function pick_item_tracker_frame_lock(pick_item_tracker)
    local itemlock = GET_CHILD(pick_item_tracker, "itemlock")
    if g.pick_item_tracker_settings.move == 1 then
        g.pick_item_tracker_settings.move = 0
        itemlock:SetGrayStyle(0)
    else
        g.pick_item_tracker_settings.move = 1
        itemlock:SetGrayStyle(1)
    end
    pick_item_tracker:EnableMove(g.pick_item_tracker_settings.move)
    pick_item_tracker_save_settings()
end

function pick_item_tracker_redraw_item_list(pick_item_tracker)
    local gb = GET_CHILD(pick_item_tracker, "gb")
    gb:RemoveAllChild()
    local count = 0
    local keys = {}
    for k in pairs(g.pick_item_tracker_items) do
        table.insert(keys, k)
    end
    table.sort(keys)
    for i, k in ipairs(keys) do
        local v = g.pick_item_tracker_items[k]
        local item_text = gb:CreateOrGetControl("richtext", "item_text" .. k, 5, count * 25)
        AUTO_CAST(item_text)
        count = count + 1
        local item_cls = GetClassByType("Item", v.cls_id)
        local color = g.pick_item_tracker_grade_colors[item_cls.ItemGrade] or "#FFFFFF"
        item_text:SetText("{img " .. item_cls.Icon .. " 20 20}" .. "{ol}{s15}{" .. color .. "}" ..
                              dictionary.ReplaceDicIDInCompStr(k) .. "{/}{ol}{s14}{#00FF00}( + " .. v.item_count .. " )")
        if g.pick_item_tracker_x < item_text:GetWidth() then
            g.pick_item_tracker_x = item_text:GetWidth()
        end
    end
    g.pick_item_tracker_y = count * 25 + 50
    pick_item_tracker:Resize(g.pick_item_tracker_x + 15, g.pick_item_tracker_y)
    gb:Resize(pick_item_tracker:GetWidth(), pick_item_tracker:GetHeight() - 45)
end

function pick_item_tracker_timer_update(pick_item_tracker, timer)
    g.pick_item_tracker_diff_time = imcTime.GetAppTimeMS() - g.pick_item_tracker_start_time
    local h = math.floor(g.pick_item_tracker_diff_time / (60 * 60 * 1000))
    local m = math.floor((g.pick_item_tracker_diff_time / (60 * 1000)) % 60)
    local s = math.floor((g.pick_item_tracker_diff_time / 1000) % 60)
    local time_text = GET_CHILD(pick_item_tracker, "time_text")
    time_text:SetText(string.format("{ol}{s14}%02d:%02d:%02d{/}", h, m, s))
    if g.settings.pick_item_tracker.use == 1 then
        pick_item_tracker:ShowWindow(1)
    else
        pick_item_tracker:ShowWindow(0)
    end
end

function pick_item_tracker_ITEMMSG_ITEM_COUNT(frame, msg, cls_id, item_count)
    local num = tonumber(cls_id)
    if num then
        cls_id = math.floor(num)
    end
    local item_cls = GetClassByType("Item", cls_id)
    local item_name = item_cls.Name
    local items = g.pick_item_tracker_items
    if not items[item_name] then
        items[item_name] = {
            cls_id = cls_id,
            item_count = item_count
        }
        pick_item_tracker_frame_update(item_name, item_count, cls_id, "new")
    else
        items[item_name].cls_id = cls_id
        items[item_name].item_count = items[item_name].item_count + item_count
        pick_item_tracker_frame_update(item_name, items[item_name].item_count, items[item_name].cls_id)
    end
end

function pick_item_tracker_frame_update(item_name, item_count, cls_id, new)
    local pick_item_tracker = ui.GetFrame(addon_name_lower .. "pick_item_tracker")
    if new == "new" then
        pick_item_tracker_redraw_item_list(pick_item_tracker)
    else
        local gb = GET_CHILD(pick_item_tracker, "gb")
        local item_text = GET_CHILD(gb, "item_text" .. item_name)
        local item_cls = GetClassByType("Item", cls_id)
        local color = g.pick_item_tracker_grade_colors[item_cls.ItemGrade] or "#FFFFFF"
        item_text:SetText("{img " .. item_cls.Icon .. " 20 20}" .. "{ol}{s15}{" .. color .. "}" ..
                              dictionary.ReplaceDicIDInCompStr(item_name) .. "{/}{ol}{s14}{#00FF00}( + " .. item_count ..
                              " )")
        pick_item_tracker:Resize(g.pick_item_tracker_x + 15, g.pick_item_tracker_y)
        gb:Resize(pick_item_tracker:GetWidth(), pick_item_tracker:GetHeight() - 45)
    end
end
-- pick_item_tracker ここまで

-- monster_kill_count ここから 
g.monster_kill_count_path = string.format("../addons/%s/%s/monster_kill_count.json", addon_name_lower, g.active_id)
g.monster_kill_count_old_path = string.format("../addons/%s/%s/settings.json", "klcount", g.active_id)
function monster_kill_count_save_settings()
    g.save_json(g.monster_kill_count_path, g.monster_kill_count_settings)
end

function monster_kill_count_load_settings()
    local settings = g.load_json(g.monster_kill_count_path)
    if not settings then
        local old_settings = g.load_json(g.monster_kill_count_old_path)
        if old_settings then
            settings = {
                frame_x = old_settings.frame_x or 1340,
                frame_y = old_settings.frame_y or 20,
                map_ids = old_settings.map_ids or {}
            }
            local new_folder_path = string.format("../addons/%s/%s/%s", addon_name_lower, g.active_id,
                "monster_kill_count")
            local new_txt_path = string.format("../addons/%s/%s/%s/mkdir.txt", addon_name_lower, g.active_id,
                "monster_kill_count")
            local file = io.open(new_txt_path, "r")
            if not file then
                os.execute('mkdir "' .. new_folder_path .. '"')
                file = io.open(new_txt_path, "w")
                if file then
                    file:write("A new file has been created")
                    file:close()
                end
            else
                file:close()
            end
            if old_settings.map_ids and #old_settings.map_ids > 0 then
                local old_dir = string.format("../addons/%s/%s/", "klcount", g.active_id)
                for _, map_id in ipairs(old_settings.map_ids) do
                    local old_file_path = old_dir .. map_id .. ".json"
                    local new_file_path = new_folder_path .. "/" .. map_id .. ".json"
                    local old_file = io.open(old_file_path, "r")
                    if old_file then
                        local content = old_file:read("*a")
                        old_file:close()
                        local new_file = io.open(new_file_path, "w")
                        if new_file then
                            new_file:write(content)
                            new_file:close()
                        end
                    end
                end
            end
        else
            settings = {
                frame_x = 1340,
                frame_y = 20,
                map_ids = {}
            }
        end
    end
    g.monster_kill_count_settings = settings
    monster_kill_count_save_settings()
end

function monster_kill_count_on_init(is_change)
    if not g.monster_kill_count_settings then
        monster_kill_count_load_settings()
    end
    g.monster_kill_count_challenge_mode = false
    g.addon:RegisterMsg("UI_CHALLENGE_MODE_TOTAL_KILL_COUNT", "monster_kill_count_ON_CHALLENGE_MODE_TOTAL_KILL_COUNT")
    monster_kill_count_handle_map_change(is_change)
end

function monster_kill_count_get_map_filepath(map_id)
    return string.format("../addons/%s/%s/%s/%s.json", addon_name_lower, g.active_id, "monster_kill_count", map_id)
end

function monster_kill_count_handle_map_change(is_change)
    if g.monster_kill_count_map_id and g.monster_kill_count_map_id ~= g.map_id then
        if g.monster_kill_count_map_data and g.monster_kill_count_diff_ms then
            local map_file_path = monster_kill_count_get_map_filepath(g.monster_kill_count_map_id)
            g.monster_kill_count_map_data.stay_time = (g.monster_kill_count_map_data.stay_time or 0) +
                                                          g.monster_kill_count_diff_ms
            g.save_json(map_file_path, g.monster_kill_count_map_data)
        end
    end
    local map_cls = GetClass("Map", g.map_name)
    local map_level = map_cls.QuestLevel
    local my_level = info.GetLevel(session.GetMyHandle())
    if my_level - map_level > 50 then
        return
    end
    if g.get_map_type() == "Field" or g.get_map_type() == "Dungeon" then
        g.setup_hook_before('ON_GAMEEXIT_TIMER_END', 'monster_kill_count_ON_GAMEEXIT_TIMER_END')
        g.addon:RegisterMsg("EXP_UPDATE", "monster_kill_count_EXP_UPDATE")
        g.addon:RegisterMsg('ITEM_PICK', 'monster_kill_count_ITEM_PICK')
        g.monster_kill_count_autosave_counter = 0
        local all_in_one = ui.GetFrame("all_in_one")
        if not g.monster_kill_count_map_id or g.monster_kill_count_map_id ~= g.map_id then
            g.monster_kill_count_map_id = g.map_id
            g.monster_kill_count_start_time = imcTime.GetAppTimeMS() - 3000
            all_in_one:SetUserValue("MKC_COUNT", 0)
            g.monster_kill_count_diff_ms = 0
        end
        local map_file_path = monster_kill_count_get_map_filepath(g.map_id)
        local map_data = g.load_json(map_file_path)
        if not map_data then
            map_data = {
                map_name = g.map_name,
                stay_time = 3000,
                kill_count = 0,
                get_items = {}
            }
            g.save_json(map_file_path, map_data)
        end
        g.monster_kill_count_map_data = map_data
        if is_change then
            monster_kill_count_frame_init()
        else
            local monster_kill_count_timer = all_in_one:CreateOrGetControl("timer", "monster_kill_count_timer", 0, 0)
            AUTO_CAST(monster_kill_count_timer)
            monster_kill_count_timer:Stop()
            monster_kill_count_timer:SetUpdateScript("monster_kill_count_frame_init")
            monster_kill_count_timer:Start(7.0)
        end
    else
        g.monster_kill_count_map_id = nil
        g.monster_kill_count_map_data = nil
    end
end

function monster_kill_count_ON_GAMEEXIT_TIMER_END(frame)
    local type = frame:GetUserValue("EXIT_TYPE")
    if type == "Exit" or type == "Logout" or type == "Barrack" or type == "Channel" then
        if g.monster_kill_count_map_id and g.monster_kill_count_map_data then
            local map_file_path = string.format("../addons/%s/%s/%s/%s.json", addon_name_lower, g.active_id,
                "monster_kill_count", g.monster_kill_count_map_id)
            if not g.monster_kill_count_diff_ms then
                g.monster_kill_count_diff_ms = imcTime.GetAppTimeMS() - g.monster_kill_count_start_time
            end
            g.monster_kill_count_map_data.stay_time = g.monster_kill_count_map_data.stay_time +
                                                          g.monster_kill_count_diff_ms
            g.save_json(map_file_path, g.monster_kill_count_map_data)
        end
    end
end

function monster_kill_count_ON_CHALLENGE_MODE_TOTAL_KILL_COUNT(frame, msg, str, arg)
    g.monster_kill_count_challenge_mode = true
end

function monster_kill_count_frame_init(all_in_one, monster_kill_count_timer)
    if not g.monster_kill_count_challenge_mode then
        local monster_kill_count = ui.CreateNewFrame("chat_memberlist", addon_name_lower .. "monster_kill_count", 0, 0,
            0, 0)
        AUTO_CAST(monster_kill_count)
        monster_kill_count:SetSkinName("shadow_box")
        monster_kill_count:SetTitleBarSkin("None")
        monster_kill_count:EnableHitTest(1)
        monster_kill_count:EnableMove(1)
        monster_kill_count:SetAlpha(80)
        monster_kill_count:SetLayerLevel(31)
        monster_kill_count:SetEventScript(ui.LBUTTONUP, "monster_kill_count_pos")
        local map_frame = ui.GetFrame("map")
        local width = map_frame:GetWidth()
        if g.monster_kill_count_settings.frame_x > 1920 and width <= 1920 then
            local x = width / g.monster_kill_count_settings.frame_x
            g.monster_kill_count_settings.frame_x = x
        end
        monster_kill_count:SetPos(g.monster_kill_count_settings.frame_x, g.monster_kill_count_settings.frame_y)
        local count_text = monster_kill_count:CreateOrGetControl("richtext", "count_text", 10, 10, 170, 30)
        AUTO_CAST(count_text)
        count_text:SetText(string.format("{ol}{s16}Count : %d{/}", 0))
        local map_name = GetClassByType("Map", g.map_id).Name
        local map_text = monster_kill_count:CreateOrGetControl("richtext", "map_text", 10, 35, 170, 30)
        AUTO_CAST(map_text)
        map_text:SetText(string.format("{ol}{s16}%s{/}", map_name))
        local w = 170
        if map_text:GetWidth() + 15 > 170 then
            w = map_text:GetWidth() + 15
        end
        local timer_text = monster_kill_count:CreateOrGetControl("richtext", "timer_text", 90, 60, 200, 30)
        AUTO_CAST(timer_text)
        timer_text:SetGravity(ui.RIGHT, ui.BOTTOM)
        local rect = timer_text:GetMargin()
        timer_text:SetMargin(rect.left, rect.top, rect.right + 15, rect.bottom + 15)
        monster_kill_count:Resize(w, 95)
        if g.settings.monster_kill_count.use == 1 then
            monster_kill_count:ShowWindow(1)
        else
            monster_kill_count:ShowWindow(0)
        end
        monster_kill_count:RunUpdateScript("monster_kill_count_time_update", 1.0)
        if monster_kill_count_timer then
            AUTO_CAST(monster_kill_count_timer)
            monster_kill_count_timer:Stop()
        end
    end
end

function monster_kill_count_pos(monster_kill_count)
    g.monster_kill_count_settings.frame_x = monster_kill_count:GetX()
    g.monster_kill_count_settings.frame_y = monster_kill_count:GetY()
    monster_kill_count_save_settings()
end

function monster_kill_count_time_update(monster_kill_count)
    local now_ms = imcTime.GetAppTimeMS()
    g.monster_kill_count_diff_ms = now_ms - g.monster_kill_count_start_time
    local total_sec = math.floor(g.monster_kill_count_diff_ms / 1000)
    local h = math.floor(total_sec / 3600)
    local m = math.floor((total_sec % 3600) / 60)
    local s = (total_sec % 60)
    local timer_text = GET_CHILD(monster_kill_count, "timer_text")
    AUTO_CAST(timer_text)
    timer_text:SetText(string.format("{ol}{s16}%02d:%02d:%02d{/}", h, m, s))
    g.monster_kill_count_autosave_counter = g.monster_kill_count_autosave_counter + 1
    if g.monster_kill_count_autosave_counter >= 60 then
        local temp_map_data = g.monster_kill_count_map_data
        temp_map_data.stay_time = temp_map_data.stay_time + g.monster_kill_count_diff_ms
        local map_file_path = string.format("../addons/%s/%s/%s/%s.json", addon_name_lower, g.active_id,
            "monster_kill_count", g.monster_kill_count_map_id)
        g.save_json(map_file_path, temp_map_data)
        g.monster_kill_count_autosave_counter = 0
        g.monster_kill_count_start_time = imcTime.GetAppTimeMS()
        g.monster_kill_count_map_data.stay_time = temp_map_data.stay_time
    end
    return 1
end

function monster_kill_count_ITEM_PICK(frame, msg, class_id, item_count)
    local num = tonumber(class_id)
    if num then
        class_id = math.floor(num)
        local map_data = g.monster_kill_count_map_data
        if not map_data.get_items[class_id] then
            map_data.get_items[class_id] = item_count
        else
            map_data.get_items[class_id] = map_data.get_items[class_id] + item_count
        end
    end
end

function monster_kill_count_EXP_UPDATE(all_in_one, msg)
    local count = all_in_one:GetUserValue("MKC_COUNT")
    local monster_kill_count = ui.GetFrame(addon_name_lower .. "monster_kill_count")
    local count_text = GET_CHILD(monster_kill_count, "count_text")
    if count_text then
        AUTO_CAST(count_text)
        count_text:SetText(string.format("{ol}{s16}Count : %d{/}", count + 1))
    end
    all_in_one:SetUserValue("MKC_COUNT", count + 1)
    local map_data = g.monster_kill_count_map_data
    map_data.kill_count = map_data.kill_count + 1
end

function monster_kill_count_information_context()
    local context = ui.CreateContextMenu("monster_kill_count_context", "{ol}Map Info", 0, 0, 200, 0)
    for i = 1, #g.monster_kill_count_settings.map_ids do
        local map_id = g.monster_kill_count_settings.map_ids[i]
        local map_file_path = monster_kill_count_get_map_filepath(map_id)
        local map_data = g.load_json(map_file_path)
        if not map_data or not next(map_data.get_items) then
            local map_cls = GetClassByType("Map", map_id)
            map_data = {
                map_name = map_cls and map_cls.ClassName,
                stay_time = 0,
                kill_count = 0,
                get_items = {}
            }
            g.save_json(map_file_path, map_data)
        else
            local display_text = map_id .. " " .. GetClassByType("Map", map_id).Name
            ui.AddContextMenuItem(context, display_text, string.format("monster_kill_count_map_information(%d)", map_id))
        end
    end
    ui.OpenContextMenu(context)
end

function monster_kill_count_map_information_close(map_info)
    if map_info then
        ui.DestroyFrame(map_info:GetName())
    end
end

function monster_kill_count_map_information(map_id)
    local map_file_path = monster_kill_count_get_map_filepath(map_id)
    local map_data = g.load_json(map_file_path)
    local frame_name = addon_name_lower .. "map_info"
    local map_info = ui.CreateNewFrame("notice_on_pc", frame_name, 0, 0, 0, 0)
    AUTO_CAST(map_info)
    map_info:SetPos(1000, 30)
    map_info:SetSkinName("test_frame_low")
    local close_btn = map_info:CreateOrGetControl("button", "close_button", 0, 0, 30, 30)
    AUTO_CAST(close_btn)
    close_btn:SetImage("testclose_button")
    close_btn:SetGravity(ui.RIGHT, ui.TOP)
    close_btn:SetEventScript(ui.LBUTTONUP, "monster_kill_count_map_information_close")
    local map_name_label = map_info:CreateOrGetControl('richtext', 'map_name_text', 20, 10, 50, 20)
    AUTO_CAST(map_name_label)
    map_name_label:SetText("{ol}" .. GetClassByType("Map", map_id).Name)
    local info_box = map_info:CreateOrGetControl("groupbox", "info_gbox", 10, 40, 0, 0)
    AUTO_CAST(info_box)
    info_box:RemoveAllChild()
    info_box:SetSkinName("bg")
    local total_sec = (map_data.stay_time or 0) / 1000
    local h = math.floor(total_sec / 3600)
    local m = math.floor((total_sec % 3600) / 60)
    local s = math.floor(total_sec % 60)
    local kill_count_val = map_data.kill_count or 0
    local stay_label = info_box:CreateOrGetControl('richtext', 'stay_time', 10, 10, 50, 20)
    AUTO_CAST(stay_label)
    stay_label:SetText(string.format("{ol}%s : %02d:%02d:%02d", g.lang == "Japanese" and "滞在時間" or "Stay Time",
        h, m, s))
    local kill_label = info_box:CreateOrGetControl('richtext', 'kill_count', 10, 35, 50, 20)
    AUTO_CAST(kill_label)
    kill_label:SetText(
        string.format("{ol}%s : %d", g.lang == "Japanese" and "討伐数" or "Kill Count", kill_count_val))
    local kill_per_hour_label = info_box:CreateOrGetControl('richtext', 'kill_count_hour', kill_label:GetWidth() + 20,
        35, 50, 20)
    AUTO_CAST(kill_per_hour_label)
    if total_sec > 0 then
        local kills_ph_val = math.floor(kill_count_val / total_sec * 3600)
        kill_per_hour_label:SetText(string.format("{ol}(%s %d %s)", total_sec >= 3600 and "実績" or "予測",
            kills_ph_val, "体/時"))
    else
        kill_per_hour_label:SetText("{ol}(N/A)")
    end
    local item_keys = {}
    local total_item_num = 0
    if map_data.get_items then
        for item_id_str, count_val in pairs(map_data.get_items) do
            table.insert(item_keys, tonumber(item_id_str))
            total_item_num = total_item_num + count_val
        end
    end
    table.sort(item_keys)
    local total_items_label = info_box:CreateOrGetControl('richtext', 'total_items_text', 10, 60, 50, 20)
    AUTO_CAST(total_items_label)
    total_items_label:SetText(string.format("{ol}%s : %d",
        g.lang == "Japanese" and "総獲得アイテム数" or "Total Items", total_item_num))

    local current_y = 0
    local max_x = 0
    for _, item_id_num in ipairs(item_keys) do
        local item_id_str_key = tostring(item_id_num)
        local item_cls = GetClassByType('Item', item_id_num)
        if item_cls and map_data.get_items[item_id_str_key] then
            local item_get_count = map_data.get_items[item_id_str_key]
            local item_disp_str1 = string.format("{ol}{img %s 24 24}  %s : %d %s", item_cls.Icon, item_cls.Name,
                item_get_count, g.lang == "Japanese" and "個" or "pcs")
            local item_label1 = info_box:CreateOrGetControl('richtext', 'display_text' .. item_id_str_key, 10,
                95 + current_y, 50, 20)
            AUTO_CAST(item_label1)
            item_label1:SetText(item_disp_str1)
            max_x = math.max(max_x, item_label1:GetWidth() + 10)
            local kc_percent = kill_count_val > 0 and item_get_count / kill_count_val * 100 or 0
            local ti_percent = total_item_num > 0 and item_get_count / total_item_num * 100 or 0
            local sec_per_item = item_get_count > 0 and total_sec / item_get_count or 0
            local item_disp_str2 = string.format("        %.1f%% (%s)   %.1f%% (%s)   %.1f %s", kc_percent, "対討伐",
                ti_percent, "対総数", sec_per_item, "秒/個")
            local item_label2 = info_box:CreateOrGetControl('richtext', 'display_text2' .. item_id_str_key, 10,
                120 + current_y, 50, 20)
            AUTO_CAST(item_label2)
            item_label2:SetText("{ol}" .. item_disp_str2)
            max_x = math.max(max_x, item_label2:GetWidth() + 10)
            current_y = current_y + 55
        end
    end
    local reset_btn = map_info:CreateOrGetControl("button", "reset_button", map_name_label:GetWidth() + 30, 5, 80, 30)
    AUTO_CAST(reset_btn)
    reset_btn:SetSkinName("test_red_button")
    reset_btn:SetText("{ol}Map Reset")
    reset_btn:SetEventScript(ui.LBUTTONUP, "monster_kill_count_map_reset_reserve")
    reset_btn:SetEventScriptArgNumber(ui.LBUTTONUP, map_id)
    map_info:Resize(math.max(max_x + 40, 250), math.min(160 + current_y, 1000))
    info_box:Resize(map_info:GetWidth() - 20, map_info:GetHeight() - 55)
    map_info:SetLayerLevel(999)
    map_info:ShowWindow(1)
end

function monster_kill_count_map_reset_reserve(frame, ctrl, str, map_id)
    ui.MsgBox("Map Reset?", string.format("monster_kill_count_map_reset(%d)", map_id), "None")
end

function monster_kill_count_map_reset(map_id)
    local map_file_path = monster_kill_count_get_map_filepath(map_id)
    local map_name = GetClassByType("Map", map_id).ClassName
    local map_data = {
        map_name = map_name,
        stay_time = 0,
        kill_count = 0,
        get_items = {}
    }
    g.save_json(map_file_path, map_data)
    local map_info = ui.GetFrame(addon_name_lower .. "map_info")
    monster_kill_count_map_information_close(map_info)
end
-- monster_kill_count ここまで

-- easy_buff ここから
g.easy_buff_path = string.format("../addons/%s/%s/easy_buff.json", addon_name_lower, g.active_id)
function easy_buff_save_settings()
    g.save_json(g.easy_buff_path, g.easy_buff_settings)
end

function easy_buff_load_settings()
    local settings = g.load_json(g.easy_buff_path)
    if not settings then
        settings = {}
    end
    local defaults = {
        food_presets_name = {},
        food_presets_check = {},
        food_check = 0,
        confirm_check = 0,
        repair_check = 0
    }
    for k, v in pairs(defaults) do
        if settings[k] == nil then
            settings[k] = v
        end
    end
    local changed = false
    for i = 1, 4 do
        local str_i = tostring(i)
        if not settings.food_presets_name[str_i] then
            settings.food_presets_name[str_i] = "preset " .. i
            changed = true
        end
        if not settings.food_presets_check[str_i] then
            settings.food_presets_check[str_i] = {}
            changed = true
        end
        for check_index = 1, 6 do
            local str_index = tostring(check_index)
            if not settings.food_presets_check[str_i][str_index] then
                settings.food_presets_check[str_i][str_index] = 1
                changed = true
            end
        end
    end
    g.easy_buff_settings = settings
    if changed then
        easy_buff_save_settings()
    end
end

function easy_buff_on_init()
    if not g.easy_buff_settings then
        easy_buff_load_settings()
    end
    g.setup_hook_and_event(g.addon, "OPEN_FOOD_TABLE_UI", "easy_buff_OPEN_FOOD_TABLE_UI", true)
    g.setup_hook_and_event(g.addon, "ITEMBUFF_REPAIR_UI_COMMON", "easy_buff_ITEMBUFF_REPAIR_UI_COMMON", true)
    g.setup_hook_and_event(g.addon, "SQUIRE_BUFF_EQUIP_CTRL", "easy_buff_SQUIRE_BUFF_EQUIP_CTRL", true)
    g.setup_hook_and_event(g.addon, "TARGET_BUFF_AUTOSELL_LIST", "easy_buff_TARGET_BUFF_AUTOSELL_LIST", true)
    g.easy_buff_first = true
end
-- 設定フレーム
function easy_buff_config_frame()
    local frame_name = addon_name_lower .. "easy_buff"
    local easy_buff = ui.CreateNewFrame("notice_on_pc", frame_name, 0, 0, 0, 0)
    easy_buff:RemoveAllChild()
    easy_buff:SetSkinName("test_frame_low")
    easy_buff:SetLayerLevel(80)
    easy_buff:Resize(490, 410)
    local list_frame_name = addon_name_lower .. "list_frame"
    local list_frame = ui.GetFrame(addon_name_lower .. "list_frame")
    easy_buff:SetPos(list_frame:GetX() + list_frame:GetWidth(), list_frame:GetY())
    easy_buff:SetTitleBarSkin("None")
    easy_buff:EnableHittestFrame(1)
    easy_buff:EnableHitTest(1)
    easy_buff:ShowWindow(1)
    local title_text = easy_buff:CreateOrGetControl('richtext', 'title_text', 20, 15, 50, 30)
    AUTO_CAST(title_text)
    title_text:SetText("{ol}Easy Buff Config")
    local close = easy_buff:CreateOrGetControl("button", "close", 0, 0, 20, 20)
    AUTO_CAST(close)
    close:SetImage("testclose_button")
    close:SetGravity(ui.RIGHT, ui.TOP)
    close:SetEventScript(ui.LBUTTONUP, "easy_buff_config_frame_close")
    local gbox = easy_buff:CreateOrGetControl("groupbox", "gbox", 10, 40, easy_buff:GetWidth() - 20,
        easy_buff:GetHeight() - 50)
    AUTO_CAST(gbox)
    gbox:SetSkinName("test_frame_midle_light")
    local icons = {"icon_item_sandwich", "icon_item_soup", "icon_item_yogurt", "icon_item_salad", "icon_item_BBQ",
                   "icon_item_champagne"}
    local x_offsets = {5, 75, 145, 215, 285, 355}
    local y = 0
    for i = 1, 4 do
        local str_i = tostring(i)
        local title_edit = gbox:CreateOrGetControl('edit', "preset_title_" .. i, 10, y + 5, 80, 20)
        AUTO_CAST(title_edit)
        title_edit:SetFontName('white_14_ol')
        title_edit:SetSkinName('test_weight_skin')
        title_edit:SetTextAlign('center', 'center')
        title_edit:SetText("{ol}" .. g.easy_buff_settings.food_presets_name[str_i])
        if str_i == "1" then
            title_edit:Focus()
        end
        title_edit:SetEventScript(ui.ENTERKEY, "easy_buff_config_presetname_change")
        local food_check = gbox:CreateOrGetControl('checkbox', "food_check" .. i, 10, y + 35, 30, 30)
        AUTO_CAST(food_check)
        food_check:SetTextTooltip(g.lang == "Japanese" and "{ol}チェックすると食事バフ自動化" or
                                      "{ol}Checked: Automate food buff")
        food_check:SetEventScript(ui.LBUTTONUP, "easy_buff_config_check_toggle")
        food_check:SetEventScriptArgNumber(ui.LBUTTONUP, i)
        food_check:SetCheck(i == g.easy_buff_settings.food_check and 1 or 0)
        local preset_gbox = gbox:CreateOrGetControl("groupbox", "preset_gbox_" .. i, 40, y + 30, gbox:GetWidth() - 50,
            40)
        AUTO_CAST(preset_gbox)
        preset_gbox:SetSkinName("test_frame_midle_light")
        for check_index = 1, #icons do
            local str_index = tostring(check_index)
            local icon_name = icons[check_index]
            local checkbox_x = x_offsets[check_index]
            local checkbox_name = "check_" .. i .. "_" .. check_index
            local checkbox_ctrl = preset_gbox:CreateOrGetControl('checkbox', checkbox_name, checkbox_x, 5, 30, 30)
            AUTO_CAST(checkbox_ctrl)
            checkbox_ctrl:SetText("{img " .. icon_name .. " 30 30}")
            checkbox_ctrl:SetCheck(g.easy_buff_settings.food_presets_check[str_i][str_index])
            checkbox_ctrl:SetEventScript(ui.LBUTTONUP, "easy_buff_config_check_toggle")
        end
        y = y + 70
    end
    local confirm_check = gbox:CreateOrGetControl('checkbox', "confirm_check", 10, y + 10, 30, 30)
    AUTO_CAST(confirm_check)
    confirm_check:SetText(g.lang == "Japanese" and
                              "{ol}チェックするとバフ掛け直し確認(残り1時間以上)" or
                              "{ol}Check to Confirm Re-buffing (remaining over 1h)")
    confirm_check:SetEventScript(ui.LBUTTONUP, "easy_buff_config_check_toggle")
    confirm_check:SetCheck(g.easy_buff_settings.confirm_check)
    -- repair_check
    local repair_check = gbox:CreateOrGetControl('checkbox', "repair_check", 10, y + 45, 30, 30)
    AUTO_CAST(repair_check)
    repair_check:SetText(g.lang == "Japanese" and
                             "{ol}チェックすると修理屋フレームを自動で閉じます" or
                             "{ol}Check to Auto-close Repair Shop Frame")
    repair_check:SetEventScript(ui.LBUTTONUP, "easy_buff_config_check_toggle")
    repair_check:SetCheck(g.easy_buff_settings.repair_check)
end

function easy_buff_config_frame_close(frame)
    ui.DestroyFrame(frame:GetName())
end

function easy_buff_config_presetname_change(frame, ctrl)
    local ctrl_name = ctrl:GetName()
    local last_char = string.sub(ctrl_name, -1)
    local text = ctrl:GetText()
    local msg = g.lang == "Japanese" and text .. "{ol} 設定しました" or "{ol} Set up"
    ui.SysMsg(msg)
    g.easy_buff_settings.food_presets_name[last_char] = text
    easy_buff_save_settings()
    easy_buff_config_frame()
end

function easy_buff_config_check_toggle(parent, ctrl, str, num)
    local ctrl_name = ctrl:GetName()
    local is_check = ctrl:IsChecked()
    if string.find(ctrl_name, "food_check") then
        if is_check == 1 then
            g.easy_buff_settings.food_check = num
        else
            g.easy_buff_settings.food_check = 0
        end
    elseif ctrl_name == "confirm_check" then
        g.easy_buff_settings.confirm_check = is_check
    elseif ctrl_name == "repair_check" then
        g.easy_buff_settings.repair_check = is_check
    else
        local preset_str, check_str = string.match(ctrl_name, "^check_(%d)_(%d)$")
        g.easy_buff_settings.food_presets_check[preset_str][check_str] = is_check
    end
    easy_buff_save_settings()
    easy_buff_config_frame()
end
-- メシ屋
function easy_buff_OPEN_FOOD_TABLE_UI(my_frame, my_msg)
    if g.settings.easy_buff.use == 0 then
        return
    end
    local group_name, sell_type, handle, seller_cid, shared = g.get_event_args(my_msg)
    local foodtable_ui = ui.GetFrame("foodtable_ui")
    local actor = world.GetActor(handle)
    local apc = actor:GetPCApc()
    local aid = apc:GetAID()
    local info = session.party.GetPartyMemberInfoByAID(PARTY_GUILD, aid)
    if not info and shared == 1 then
        local msg = g.lang == "Japanese" and "ギルドメンバーのみに食事提供のお店です" or
                        "This shop provides food exclusively to guild members"
        ui.SysMsg(msg)
        foodtable_ui:ShowWindow(0)
        return
    end
    local x = 300
    local y = 60
    local btn
    for i = 1, 4 do
        local str_i = tostring(i)
        btn = foodtable_ui:CreateOrGetControl("button", "btn" .. i, x, y, 85, 30)
        AUTO_CAST(btn)
        btn:SetSkinName(i == g.easy_buff_settings.food_check and "test_red_button" or "test_gray_button")
        local text = g.easy_buff_settings.food_presets_name[str_i] or "{ol}preset " .. i
        btn:SetText("{ol}" .. text)
        btn:SetEventScript(ui.LBUTTONUP, "easy_buff_clear_food_buff_timer")
        if btn:GetWidth() >= 85 then
            btn:Resize(85, 30)
        end
        if i == 1 then
            x = x + 80
        elseif i == 2 then
            x = 300
            y = 90
        elseif i == 3 then
            x = x + 80
        end
    end
    if g.easy_buff_settings.food_check ~= 0 and g.easy_buff_first then
        easy_buff_clear_food_buff_timer(nil, btn)
        g.easy_buff_first = false
    end
end

function easy_buff_clear_food_buff_timer(frame, btn)
    btn:RunUpdateScript("easy_buff_clear_food_buff", 0.1)
end

function easy_buff_clear_food_buff(btn)
    local food_buffs = {4021, 4022, 4023, 4024, 4087, 4136}
    local my_handle = session.GetMyHandle()
    for _, buff_id in ipairs(food_buffs) do
        local buff = info.GetBuff(my_handle, buff_id)
        if buff then
            packet.ReqRemoveBuff(buff_id)
            return 1
        end
    end
    btn:StopUpdateScript("easy_buff_clear_food_buff")
    easy_buff_set_food_buff(btn)
    return 0
end

function easy_buff_set_food_buff(btn)
    local preset_index_str
    if g.easy_buff_settings.food_check ~= 0 then
        preset_index_str = tostring(g.easy_buff_settings.food_check)
    elseif btn then
        preset_index_str = string.sub(btn:GetName(), -1)
    else
        return
    end
    g.easy_buff_temp_food = {}
    for key, value in pairs(g.easy_buff_settings.food_presets_check[preset_index_str]) do
        if value == 1 then
            local num_key = tonumber(key)
            if num_key then
                table.insert(g.easy_buff_temp_food, num_key - 1)
            end
        end
    end
    table.sort(g.easy_buff_temp_food, function(a, b)
        return a > b
    end)
    if #g.easy_buff_temp_food > 0 then
        easy_buff_eat_food(btn)
        btn:RunUpdateScript("easy_buff_eat_food", 0.6)
    end
end

function easy_buff_eat_food(btn)
    local foodtable_ui = ui.GetFrame("foodtable_ui")
    if foodtable_ui:IsVisible() == 0 then
        g.easy_buff_first = true
        return 0
    end
    local handle = foodtable_ui:GetUserIValue("HANDLE")
    local sell_type = foodtable_ui:GetUserIValue("SELLTYPE")
    if #g.easy_buff_temp_food > 0 then
        session.autoSeller.Buy(handle, g.easy_buff_temp_food[#g.easy_buff_temp_food], 1, sell_type)
        table.remove(g.easy_buff_temp_food, #g.easy_buff_temp_food)
        imcSound.PlaySoundEvent('system_craft_potion_succes')
        return 1
    else
        g.easy_buff_first = true
        foodtable_ui:ShowWindow(0)
        return 0
    end
end
-- バフ屋
function easy_buff_TARGET_BUFF_AUTOSELL_LIST(my_frame, my_msg)
    if g.settings.easy_buff.use == 0 then
        return
    end
    local group_name, sell_type, handle = g.get_event_args(my_msg)
    if sell_type ~= 0 then
        return
    end
    local item_count = session.autoSeller.GetCount(group_name)
    for i = 0, item_count - 1 do
        local item_info = session.autoSeller.GetByIndex(group_name, i)
        if not item_info then
            ui.SysMsg(g.lang == "Japanese" and "お店のバフアイテムが足りません" or
                          "Insufficient buff items at the shop")
            return
        end
    end
    if not g.easy_buff_first then
        return
    end
    g.easy_buff_first = false
    local my_handle = session.GetMyHandle()
    local buff_ids_to_check = {358, 359, 360, 370}
    local needs_rebuff = false
    for _, buff_id in ipairs(buff_ids_to_check) do
        local buff = info.GetBuff(my_handle, buff_id)
        if not buff then
            needs_rebuff = true
            break
        end
        local buff_time = buff.time
        if buff_time <= 3600000 then
            needs_rebuff = true
            break
        end
    end
    if needs_rebuff then
        easy_buff_buy_buffs(handle)
        return
    else
        if g.easy_buff_settings.confirm_check == 1 then
            local msg_text = g.lang == "Japanese" and "{#FFFFFF}{ol}バフをかけ直しますか？" or
                                 "{#FFFFFF}{ol}Do you want to reapply the buff?"
            local yes_script = string.format("easy_buff_buy_buffs(%d)", handle)
            local no_script = "easy_buff_end_process()"
            ui.MsgBox(msg_text, yes_script, no_script)
        else
            easy_buff_buy_buffs(handle)
            return
        end
    end
end

function easy_buff_buy_buffs(handle)
    local buffseller_target = ui.GetFrame("buffseller_target")
    buffseller_target:SetUserValue("HANDLE", handle)
    buffseller_target:SetUserValue("BUFF_INDEX", 0)
    buffseller_target:RunUpdateScript("easy_buff_buy_buffs_update", 0.6)
end

function easy_buff_buy_buffs_update(buffseller_target)
    local buff_index = buffseller_target:GetUserIValue("BUFF_INDEX")
    if buff_index <= 3 then
        local handle = buffseller_target:GetUserIValue("HANDLE")
        session.autoSeller.Buy(handle, buff_index, 1, 0)
        buffseller_target:SetUserValue("BUFF_INDEX", buff_index + 1)
        return 1
    else
        buffseller_target:RunUpdateScript("easy_buff_end_process", 0.6)
        return 0
    end
end

function easy_buff_end_process(buffseller_target)
    local my_handle = session.GetMyHandle()
    local buff_check = {358, 359, 360, 370}
    for i, buff_id in ipairs(buff_check) do
        local buff = info.GetBuff(my_handle, buff_id)
        if not buff or buff.time <= 3540000 then
            local handle = buffseller_target:GetUserIValue("HANDLE")
            session.autoSeller.Buy(handle, i - 1, 1, 0)
            buffseller_target:RunUpdateScript("easy_buff_end_process", 0.6)
            return 0
        end
    end
    local buffseller_target = ui.GetFrame("buffseller_target")
    buffseller_target:ShowWindow(0)
    g.easy_buff_first = true
    return 0
end
-- 修理
function easy_buff_ITEMBUFF_REPAIR_UI_COMMON(my_frame, my_msg)
    if g.settings.easy_buff.use == 0 then
        return
    end
    local itembuffrepair = ui.GetFrame("itembuffrepair")
    session.ResetItemList()
    local handle = itembuffrepair:GetUserValue("HANDLE")
    local skill_name = itembuffrepair:GetUserValue("SKILLNAME")
    local slot_set = GET_CHILD_RECURSIVELY(itembuffrepair, "slotlist", "ui::CSlotSet")
    local slot_count = slot_set:GetSlotCount()
    local cheapest = nil
    local price = 0
    local iesid = ""
    for i = 0, slot_count - 1 do
        local slot = slot_set:GetSlotByIndex(i)
        if slot:GetIcon() then
            local icon = slot:GetIcon()
            local icon_info = icon:GetInfo()
            local inv_item = GET_ITEM_BY_GUID(icon_info:GetIESID())
            if inv_item then
                local item_obj = GetIES(inv_item:GetObject())
                local need_item, need_count = ITEMBUFF_NEEDITEM_Squire_Repair(GetMyPCObject(), item_obj)
                if need_count < price or price == 0 then
                    cheapest = slot
                    price = need_count
                    iesid = icon_info:GetIESID()
                end
            end
        end
    end
    if cheapest then
        session.AddItemID(iesid)
        local auto_sell_index = 2 -- 元コードのAUTO_SELL_SQUIRE_BUFFが2
        session.autoSeller.BuyItems(handle, auto_sell_index, session.GetItemIDList(), skill_name)
        imcSound.PlaySoundEvent('system_craft_potion_succes')
    end
    itembuffrepair:RunUpdateScript("easy_buff_repair_msg", 1.5)
end

function easy_buff_repair_msg(itembuffrepair)
    local repair_buffs = {3127, 3128, 3129} -- 3127魔法 3128機敏 3129防御
    local my_handle = session.GetMyHandle()
    for _, buff_id in ipairs(repair_buffs) do
        local buff = info.GetBuff(my_handle, buff_id)
        if buff then
            local format_string
            if g.lang == "Japanese" then
                format_string = "%s バフを有効化"
            else
                format_string = "%s Activate Buff"
            end
            local buff_cls = GetClassByType("Buff", buff_id)
            local msg = string.format(format_string, buff_cls.Name)
            imcAddOn.BroadMsg("NOTICE_Dm_Bell", msg, 2.5)
            CHAT_SYSTEM(msg)
        end
    end
    if g.easy_buff_settings.repair_check == 1 then
        itembuffrepair:ShowWindow(0)
        local inventory = ui.GetFrame("inventory")
        if inventory:IsVisible() == 1 then
            ui.ToggleFrame('inventory')
        end
    end
end
-- メンテ処理
function easy_buff_SQUIRE_BUFF_EQUIP_CTRL(my_frame, my_msg)
    if g.settings.easy_buff.use == 0 then
        return
    end
    local itembuffopen = ui.GetFrame("itembuffopen")
    itembuffopen:StopUpdateScript("easy_buff_squire_frame_close")
    itembuffopen:RunUpdateScript("easy_buff_squire_buff_equip_ctrl_update", 0.5)
    return
end

function easy_buff_squire_buff_equip_ctrl_update(itembuffopen)
    if session.GetMyHandle() == itembuffopen:GetUserIValue("HANDLE") then
        return
    end
    local close = GET_CHILD_RECURSIVELY(itembuffopen, 'close')
    AUTO_CAST(close)
    close:SetEventScript(ui.LBUTTONUP, "easy_buff_squire_timestop_frame_close")
    local checkall = GET_CHILD_RECURSIVELY(itembuffopen, 'checkall')
    AUTO_CAST(checkall)
    checkall:SetCheck(1)
    SQUIRE_BUFF_EQUIP_SELECT_ALL(itembuffopen, checkall)
    local btn_excute = GET_CHILD_RECURSIVELY(itembuffopen, "btn_excute")
    SQUIRE_BUFF_EXCUTE(itembuffopen, btn_excute)
    local str = g.lang == "Japanese" and
                    "{ol}装備メンテナンス自動付与中{nl}フレームを閉じればキャンセルします" or
                    "{ol}Equipment maintenance automatic grant is in progress{nl}Canceled when frame is closed"
    ui.SysMsg(str)
    itembuffopen:StopUpdateScript("easy_buff_squire_buff_equip_ctrl_update")
    itembuffopen:RunUpdateScript("easy_buff_squire_frame_close", 5.5)
end

function easy_buff_squire_timestop_frame_close()
    packet.StopTimeAction(1)
    ui.CloseFrame("itembuffopen")
end

function easy_buff_squire_frame_close(itembuffopen)
    itembuffopen:ShowWindow(0)
    return 0
end
-- easy_buff ここまで

-- debuff_notice ここから
function debuff_notice_on_init()
    g.debuff_notice = {
        slot_table = {},
        highlander = false
    }
    local map_name = session.GetMapName()
    if map_name == "c_highlander" then
        g.debuff_notice.highlander = true
    end
    if type(_G["COMMON_BUFF_MSG_OLD"]) == "function" then
        g.setup_hook_and_event(g.addon, "COMMON_BUFF_MSG_OLD", "debuff_notice_COMMON_BUFF_MSG", true)
    else
        g.setup_hook_and_event(g.addon, "COMMON_BUFF_MSG", "debuff_notice_COMMON_BUFF_MSG", true)
    end
    if g.get_map_type() ~= "City" or g.debuff_notice.highlander then
        debuff_notice_frame_init()
    end
end

function debuff_notice_COMMON_BUFF_MSG(my_frame, my_msg)
    if g.settings.debuff_notice.use == 0 then
        return
    end
    if g.get_map_type() == "City" and not g.debuff_notice.highlander then
        return
    end
    local frame, msg, buff_id, handle, buff_ui, buff_index = g.get_event_args(my_msg)
    local debuff_notice = ui.GetFrame(addon_name_lower .. "debuff_notice")
    if not debuff_notice then
        return
    end
    if msg == "CLEAR" then
        if g.debuff_notice.slot_table[handle] then
            g.debuff_notice.slot_table[handle] = nil
            debuff_notice_frame_redraw(debuff_notice, handle)
        end
        return
    end
    if msg == "SET" then
        return
    end
    buff_id = tonumber(buff_id)
    local buff_cls = GetClassByType('Buff', buff_id)
    if not buff_cls or (buff_cls.Group1 ~= "Debuff" and buff_cls.Group1 ~= "Deuff") or buff_cls.ShowIcon == "FALSE" then
        return
    end
    local image_name = GET_BUFF_ICON_NAME(buff_cls)
    if image_name == "icon_None" then
        return
    end
    if msg ~= 'REMOVE' then
        local buff = info.GetBuff(handle, buff_id, buff_index)
        if not buff or buff:GetHandle() ~= session.GetMyHandle() then
            return
        end
    end
    local actor = world.GetActor(handle)
    if not actor then
        return
    end
    local mon_cls = GetClassByType("Monster", actor:GetType())
    if TryGetProp(mon_cls, "MonRank", "None") ~= "Boss" and not g.debuff_notice.highlander then
        return
    end
    if not g.debuff_notice.slot_table[handle] then
        g.debuff_notice.slot_table[handle] = {}
    end
    if msg == 'ADD' or msg == "UPDATE" then
        g.debuff_notice.slot_table[handle][buff_id] = {
            buff_index = buff_index,
            image_name = image_name
        }
    elseif msg == 'REMOVE' then
        g.debuff_notice.slot_table[handle][buff_id] = nil
    end
    debuff_notice_frame_redraw(debuff_notice, handle)
end

function debuff_notice_frame_init()
    local targetbuff = ui.GetFrame("targetbuff")
    local frame_name = addon_name_lower .. "debuff_notice"
    local debuff_notice = ui.CreateNewFrame("notice_on_pc", frame_name, 0, 0, 0, 0)
    debuff_notice:SetSkinName("None")
    debuff_notice:SetTitleBarSkin("None")
    debuff_notice:Resize(0, 0)
    debuff_notice:SetPos(targetbuff:GetX() + 100, targetbuff:GetY() + targetbuff:GetHeight() + 50)
    local debuff_slotset = debuff_notice:CreateOrGetControl("slotset", "debuff_slotset", 0, 0, 415, 50)
    AUTO_CAST(debuff_slotset)
    debuff_slotset:SetColRow(8, 1)
    debuff_slotset:SetSlotSize(50, 50)
    debuff_slotset:SetSpc(0, 0)
    debuff_slotset:EnablePop(0)
    debuff_slotset:EnableDrag(0)
    debuff_slotset:EnableDrop(0)
    debuff_slotset:CreateSlots()
    debuff_notice:ShowWindow(1)
    debuff_notice:RunUpdateScript("debuff_notice_update_and_cleanup", 0.1)
    return debuff_notice
end

function debuff_notice_frame_redraw(debuff_notice, handle)
    local debuff_slotset = GET_CHILD(debuff_notice, "debuff_slotset")
    AUTO_CAST(debuff_slotset)
    debuff_notice:SetUserValue("HANDLE", handle)
    local buffs_to_display = {}
    if g.debuff_notice.slot_table[handle] then
        for buff_id, buff_data in pairs(g.debuff_notice.slot_table[handle]) do
            table.insert(buffs_to_display, {
                id = buff_id,
                index = buff_data.buff_index,
                image = buff_data.image_name
            })
        end
    end
    table.sort(buffs_to_display, function(a, b)
        return tonumber(a.index) < tonumber(b.index)
    end)
    if #buffs_to_display > 0 then
        debuff_notice:Resize(#buffs_to_display * 50, 50)
    else
        debuff_notice:Resize(0, 0)
    end
    for i = 1, debuff_slotset:GetSlotCount() do
        local slot = GET_CHILD(debuff_slotset, "slot" .. i)
        AUTO_CAST(slot)
        local buff_data = buffs_to_display[i]
        if buff_data then
            local icon = slot:GetIcon()
            if not icon then
                icon = CreateIcon(slot)
            end
            AUTO_CAST(icon)
            icon:Set(buff_data.image, 'BUFF', buff_data.id, 0)
            icon:SetTooltipType('buff')
            icon:SetTooltipArg(handle, buff_data.id, buff_data.index)
            icon:SetUserValue("BuffIndex", buff_data.index)
            slot:CreateOrGetControl('richtext', "time_text", 10, 35, 20, 20)
            slot:CreateOrGetControl('richtext', "count_text", 5, 0, 40, 35)
        else
            slot:ClearIcon()
        end
    end
end

function debuff_notice_update_and_cleanup(debuff_notice)
    local handle = debuff_notice:GetUserIValue("HANDLE")
    if not handle or handle == 0 then
        debuff_notice:Resize(0, 0)
        return 1
    end
    local actor = world.GetActor(handle)
    if not actor then
        debuff_notice:Resize(0, 0)
        return 1
    end
    local debuff_slotset = GET_CHILD(debuff_notice, "debuff_slotset")
    for i = 1, debuff_slotset:GetSlotCount() do
        local slot = GET_CHILD(debuff_slotset, "slot" .. i)
        local icon = slot:GetIcon()
        if icon then
            local icon_info = icon:GetInfo()
            local buff_id = icon_info.type
            local buff_index = icon:GetUserIValue("BuffIndex")
            local buff = info.GetBuff(handle, buff_id, buff_index)
            if buff then
                local time_text = GET_CHILD(slot, "time_text")
                local count_text = GET_CHILD(slot, "count_text")
                time_text:SetText(buff.time > 0 and "{ol}{s15}{#FFFF00}" .. string.format("%.1fs", buff.time / 1000) or
                                      "")
                count_text:SetText(buff.over > 0 and "{ol}{s35}{#FFFF00}" .. tostring(buff.over) or "")
            else
                if g.debuff_notice.slot_table[handle] and g.debuff_notice.slot_table[handle][buff_id] then
                    g.debuff_notice.slot_table[handle][buff_id] = nil
                    debuff_notice_frame_redraw(debuff_notice, handle)
                end
            end
        end
    end
    return 1
end
-- debuff_notice ここまで

-- continue_reinforce ここから
g.continue_reinforce = {
    use = true,
    rf_count = 0,
    limit_clear = false,
    is_first = false,
    delay = 0.1,
    count = 0,
    premium_mat = false,
    normal_mat = false,
    inv_tbl = {}
}
function continue_reinforce_on_init()
    if g.settings.continue_reinforce.use == 0 then
        return
    end
    g.setup_hook_and_event(g.addon, "GODDESS_MGR_TAB_CHANGE", "continue_reinforce_GODDESS_MGR_TAB_CHANGE", true)
    g.setup_hook_and_event(g.addon, "GODDESS_EQUIP_MANAGER_OPEN", "continue_reinforce_GODDESS_EQUIP_MANAGER_OPEN", true)
    g.setup_hook_and_event(g.addon, "GODDESS_MGR_REFORGE_REG_ITEM", "continue_reinforce_GODDESS_MGR_REFORGE_REG_ITEM",
        true)
    g.setup_hook_and_event(g.addon, "_END_REFORGE_REINFORCE_EXEC", "continue_reinforce__END_REFORGE_REINFORCE_EXEC",
        true)
    g.setup_hook_and_event(g.addon, "GODDESS_MGR_REFORGE_ITEM_REMOVE",
        "continue_reinforce_GODDESS_MGR_REFORGE_ITEM_REMOVE", true)
    g.setup_hook_and_event(g.addon, "GODDESS_MGR_REFORGE_TAB_CHANGE",
        "continue_reinforce_GODDESS_MGR_REFORGE_TAB_CHANGE", true)
end

function continue_reinforce_GODDESS_MGR_TAB_CHANGE()
    local goddess_equip_manager = ui.GetFrame('goddess_equip_manager')
    local main_tab = GET_CHILD_RECURSIVELY(goddess_equip_manager, 'main_tab')
    local tab_index = main_tab:GetSelectItemIndex()
    if tab_index == 0 then
        continue_reinforce_GODDESS_EQUIP_MANAGER_OPEN()
    else
        goddess_equip_manager:RemoveChild("gbox")
    end
end

function continue_reinforce_GODDESS_EQUIP_MANAGER_OPEN()
    local goddess_equip_manager = ui.GetFrame('goddess_equip_manager')
    local reinf_left_bg = GET_CHILD_RECURSIVELY(goddess_equip_manager, 'reinf_left_bg')
    local reinf_no_msgbox = GET_CHILD_RECURSIVELY(reinf_left_bg, 'reinf_no_msgbox')
    AUTO_CAST(reinf_no_msgbox)
    if g.continue_reinforce.use and g.settings.continue_reinforce.use == 1 then
        reinf_no_msgbox:SetCheck(1)
        reinf_no_msgbox:SetMargin(-30, 0, 0, 110)
    else
        reinf_no_msgbox:SetCheck(0)
        reinf_no_msgbox:SetMargin(0, 0, 0, 110)
    end
    local ref_ok_reinforce = GET_CHILD_RECURSIVELY(goddess_equip_manager, 'ref_ok_reinforce')
    AUTO_CAST(ref_ok_reinforce)
    ref_ok_reinforce:SetSkinName("baseyellow_btn")
    if g.continue_reinforce.use and g.settings.continue_reinforce.use == 1 then
        ref_ok_reinforce:Resize(100, 70)
        local ref_ok_text = ref_ok_reinforce:GetTextByKey("value")
        ref_ok_reinforce:SetText(ref_ok_text)
        local rect = ref_ok_reinforce:GetMargin()
        ref_ok_reinforce:SetPos(-30, rect.bottom)
    else
        ref_ok_reinforce:Resize(160, 70)
        local ref_do_text = ref_ok_reinforce:GetTextByKey("value")
        ref_ok_reinforce:SetText(ref_do_text)
        local rect = ref_ok_reinforce:GetMargin()
        ref_ok_reinforce:SetPos(0, rect.bottom)
    end
    local ref_do_reinforce = GET_CHILD_RECURSIVELY(goddess_equip_manager, 'ref_do_reinforce')
    AUTO_CAST(ref_do_reinforce)
    if g.continue_reinforce.use and g.settings.continue_reinforce.use == 1 then
        ref_do_reinforce:Resize(100, 70)
        local ref_do_text = ref_do_reinforce:GetTextByKey("value")
        ref_do_reinforce:SetText(ref_do_text)
        local rect = ref_do_reinforce:GetMargin()
        ref_do_reinforce:SetPos(-30, rect.bottom)
    else
        ref_do_reinforce:Resize(160, 70)
        local ref_do_text = ref_do_reinforce:GetTextByKey("value")
        ref_do_reinforce:SetText(ref_do_text)
        local rect = ref_do_reinforce:GetMargin()
        ref_do_reinforce:SetPos(0, rect.bottom)
    end
    reinf_left_bg:RemoveChild("cancel")
    if g.continue_reinforce.use and g.settings.continue_reinforce.use == 1 then
        local cancel = reinf_left_bg:CreateOrGetControl("button", "cancel", 0, 647, 100, 70)
        AUTO_CAST(cancel)
        cancel:SetEventScript(ui.LBUTTONDOWN, "continue_reinforce_stop_script")
        cancel:SetSkinName("test_red_button")
        cancel:SetText("{@st41b}{s18}Cancel")
    end
    local use_toggle =
        reinf_left_bg:CreateOrGetControl('picture', "use_toggle", 315, reinf_no_msgbox:GetY() - 5, 60, 30)
    AUTO_CAST(use_toggle)
    local icon_name = "test_com_ability_on"
    if g.continue_reinforce.use == false then
        icon_name = "test_com_ability_off"
    end
    use_toggle:SetImage(icon_name)
    use_toggle:SetEnableStretch(1)
    use_toggle:EnableHitTest(1)
    use_toggle:SetTextTooltip(g.lang == "Japanese" and "{ol}ON/Continue Reinfoceを使用" or
                                  "{ol}ON/Use Continue Reinforce")
    use_toggle:SetEventScript(ui.LBUTTONUP, "continue_reinforce_setting_change")
    goddess_equip_manager:RemoveChild("gbox")
    if g.continue_reinforce.use and g.settings.continue_reinforce.use == 1 then
        local gbox = goddess_equip_manager:CreateOrGetControl("groupbox", "gbox", 1035, 755, 180, 110)
        AUTO_CAST(gbox)
        gbox:SetSkinName("None")
        gbox:RunUpdateScript("continue_reinforce_run_update_script", 0.5)
        g.continue_reinforce.inv_tbl = {}
        gbox:SetUserValue("IESID", "None")
        local clear = gbox:CreateOrGetControl("button", "clear", 0, 0, 60, 30)
        AUTO_CAST(clear)
        clear:SetText("{ol}clear")
        clear:SetSkinName("test_red_button")
        clear:SetTextTooltip(g.lang == "Japanese" and "{ol}強化回数制限をクリアーします" or
                                 "{ol}Clear the reinforcement count limit")
        clear:SetEventScript(ui.LBUTTONUP, "continue_reinforce_setting_change")
        local normal = gbox:CreateOrGetControl("button", "normal", 60, 0, 60, 30)
        AUTO_CAST(normal)
        normal:SetText("{ol}{s13}normal") -- relic_btn_purple
        normal:SetSkinName("relic_btn_purple")
        normal:SetTextTooltip(g.lang == "Japanese" and "{ol}強化補助剤をセットします" or
                                  "{ol}Set the reinforcement aid")
        normal:SetEventScript(ui.LBUTTONUP, "continue_reinforce_mat_select")
        local premium = gbox:CreateOrGetControl("button", "premium", 120, -4, 60, 36)
        AUTO_CAST(premium)
        premium:SetText("{ol}{s10}Premium")
        premium:SetSkinName("baseyellow_btn")
        premium:SetTextTooltip(g.lang == "Japanese" and "{ol}プレミアム強化補助剤をセットします" or
                                   "{ol}Set the Premium Reinforcement Aid")
        premium:SetEventScript(ui.LBUTTONUP, "continue_reinforce_mat_select")
        local x = 30
        local y = 30
        local text = 1
        for i = 0, 9 do
            local number = gbox:CreateOrGetControl("button", "number" .. i, x + 30 * i, y, 30, 25)
            AUTO_CAST(number)
            number:SetEventScript(ui.LBUTTONDOWN, "continue_reinforce_count_input")
            number:SetEventScriptArgNumber(ui.LBUTTONDOWN, text)
            number:SetText("{ol}" .. text)
            if i == 4 then
                x = 30 - 5 * 30
                y = 55
                text = text + 5
            elseif i >= 5 then
                text = text + 5
            else
                text = text + 1
            end
        end
        local clear_toggle = gbox:CreateOrGetControl('picture', "clear_toggle", 30, 80, 60, 30)
        AUTO_CAST(clear_toggle)
        local icon_name = "test_com_ability_on"
        if g.continue_reinforce.limit_clear == false then
            icon_name = "test_com_ability_off"
        end
        clear_toggle:SetImage(icon_name)
        clear_toggle:SetEnableStretch(1)
        clear_toggle:EnableHitTest(1)
        clear_toggle:SetTextTooltip(g.lang == "Japanese" and
                                        "{ol}ON/回数制限到達時に制限をクリアーします" or
                                        "{ol}upon reaching the limit")
        clear_toggle:SetEventScript(ui.LBUTTONUP, "continue_reinforce_setting_change")
        local count_edit = gbox:CreateOrGetControl('edit', 'count_edit', 95, 80, 55, 30)
        AUTO_CAST(count_edit)
        count_edit:SetFontName("white_16_ol")
        count_edit:SetTextAlign("center", "center")
        count_edit:SetText(g.continue_reinforce.rf_count ~= 0 and "{ol}" .. g.continue_reinforce.rf_count or "")
        count_edit:SetNumberMode(0)
        count_edit:SetMaxLen(2)
        count_edit:SetTypingScp("continue_reinforce_count_input")
        count_edit:SetTextTooltip(g.lang == "Japanese" and "{ol}強化回数制限" or
                                      "{ol}Continuous Reinforcement Limit")
        --[[local setting = gbox:CreateOrGetControl("button", "setting", 150, 80, 30, 30)
        AUTO_CAST(setting)
        setting:SetSkinName("None")
        setting:SetText("{img config_button_normal 30 30}")
        setting:SetTextTooltip("{ol}}Left-click delay setting")
        setting:SetEventScript(ui.LBUTTONUP, "continue_reinforce_setting_context")]]
    end
end

function continue_reinforce_setting_change(frame, ctrl)
    local ctrl_name = ctrl:GetName()
    if ctrl_name == "use_toggle" then
        if g.continue_reinforce.use == true then
            g.continue_reinforce.use = false
            ctrl:SetImage("test_com_ability_off")
        else
            g.continue_reinforce.use = true
            ctrl:SetImage("test_com_ability_on")
        end
    elseif ctrl_name == "clear" then
        g.continue_reinforce.rf_count = 0
        local format_string
        local limit_text
        if g.lang == "Japanese" then
            format_string = "強化制限回数を %s に設定しました"
            limit_text = "無制限"
        else
            format_string = "Continuous Reinforcement Limit set to %s"
            limit_text = "Unlimited"
        end
        local msg = string.format(format_string, limit_text)
        imcAddOn.BroadMsg("NOTICE_Dm_Bell", msg, 2.5)
    elseif ctrl_name == "clear_toggle" then
        if g.continue_reinforce.limit_clear == true then
            g.continue_reinforce.limit_clear = false
            ctrl:SetImage("test_com_ability_off")
        else
            g.continue_reinforce.limit_clear = true
            ctrl:SetImage("test_com_ability_on")
        end
    end
    continue_reinforce_GODDESS_EQUIP_MANAGER_OPEN()
end

function continue_reinforce_count_input(parent, ctrl, str, num)
    if ctrl:GetName() ~= "count_edit" then
        local count_edit = GET_CHILD(parent, "count_edit")
        count_edit:SetText("{ol}" .. num)
        g.continue_reinforce.rf_count = num
    else
        local number_text = string.gsub(ctrl:GetText(), "%D", "")
        number_text = tonumber(number_text)
        if number_text then
            g.continue_reinforce.rf_count = number_text
        else
            g.continue_reinforce.rf_count = 0
        end
    end
    g.continue_reinforce.is_first = false
    ctrl:StopUpdateScript("continue_reinforce_save_settings_reserve")
    ctrl:RunUpdateScript("continue_reinforce_save_settings_reserve", 0.5)
end

function continue_reinforce_save_settings_reserve(ctrl)
    continue_reinforce_GODDESS_EQUIP_MANAGER_OPEN()
    local count_text
    if g.continue_reinforce.rf_count == 0 then
        count_text = g.lang == "Japanese" and "無制限" or "Unlimited"
    else
        count_text = g.continue_reinforce.rf_count
    end
    local format_string
    if g.lang == "Japanese" then
        format_string = "強化制限回数を %s に設定しました"
    else
        format_string = "Continuous Reinforcement Limit set to %s"
    end
    local msg = string.format(format_string, count_text)
    imcAddOn.BroadMsg("NOTICE_Dm_Bell", msg, 2.5)
end

--[[function continue_reinforce_setting_context()
    local context = ui.CreateContextMenu("SET_DELAY", "{ol}SET DELAY", 50, -200, 100, 100)
    for i = 1, 5 do
        local delay = i / 10
        local text =
            string.format(g.lang == "Japanese" and "{ol}ディレイ設定 %.1f" or "{ol}Set Delay %.1f", delay)
        ui.AddContextMenuItem(context, text, string.format("continue_reinforce_delay_save(%.1f)", delay))
    end
    ui.OpenContextMenu(context)
end

function continue_reinforce_delay_save(delay)
    local msg = string.format(g.lang == "Japanese" and "{ol}ディレイを %.1f 秒に設定しました" or
                                  "{ol}Delay is set to %.1f sec", delay)
    ui.SysMsg(msg)
    g.continue_reinforce.delay = tonumber(delay)
end]]

function continue_reinforce_stop_process(goddess_equip_manager)
    goddess_equip_manager:StopUpdateScript("continue_reinforce_GODDESS_MGR_REFORGE_REINFORCE_EXEC")
    g.continue_reinforce.is_first = false
    continue_reinforce_next_mat_set(goddess_equip_manager, false)
    if g.continue_reinforce.limit_clear then
        g.continue_reinforce.rf_count = 0
        continue_reinforce_GODDESS_EQUIP_MANAGER_OPEN()
        return true
    end
    return false
end

function continue_reinforce__END_REFORGE_REINFORCE_EXEC()
    if not g.continue_reinforce.use or g.settings.continue_reinforce.use == 0 then
        return
    end
    local goddess_equip_manager = ui.GetFrame('goddess_equip_manager')
    local reinf_left_bg = GET_CHILD_RECURSIVELY(goddess_equip_manager, "reinf_left_bg")
    local ref_ok_reinforce = GET_CHILD_RECURSIVELY(goddess_equip_manager, 'ref_ok_reinforce')
    ref_ok_reinforce:ShowWindow(0)
    local ref_do_reinforce = GET_CHILD_RECURSIVELY(goddess_equip_manager, "ref_do_reinforce")
    AUTO_CAST(ref_do_reinforce)
    ref_do_reinforce:ShowWindow(1)
    ref_do_reinforce:SetEnable(1)
    if not g.continue_reinforce.is_first then
        g.continue_reinforce.is_first = true
        g.continue_reinforce.count = g.continue_reinforce.rf_count
    end
    local result_str = goddess_equip_manager:GetUserValue('REINFORCE_RESULT')
    if result_str == 'SUCCESS' then
        goddess_equip_manager:SetUserValue('REINFORCE_RESULT', "None")
        GODDESS_MGR_REFORGE_REINFORCE_CLEAR(goddess_equip_manager, true)
        if not continue_reinforce_stop_process(goddess_equip_manager) then
            goddess_equip_manager:RunUpdateScript("continue_reinforce_next_mat_set", 0.2)
        end
        local ref_item_reinf_text = GET_CHILD_RECURSIVELY(goddess_equip_manager, 'ref_item_reinf_text')
        local ref_slot = GET_CHILD_RECURSIVELY(goddess_equip_manager, 'ref_slot')
        local ref_slot_guid = ref_slot:GetUserValue('ITEM_GUID')
        local inv_item = session.GetInvItemByGuid(ref_slot_guid)
        if inv_item then
            local item_obj = GetIES(inv_item:GetObject())
            if item_obj then
                ref_item_reinf_text:SetTextByKey('value', TryGetProp(item_obj, 'Reinforce_2', 0))
            end
        end
        return
    end
    local is_material_shortage = false
    local mat_bg = GET_CHILD_RECURSIVELY(goddess_equip_manager, 'reinf_main_mat_bg')
    for i = 0, mat_bg:GetChildCount() - 1 do
        local ctrlset = GET_CHILD(mat_bg, 'GODDESS_REINF_MAT_' .. i)
        if ctrlset then
            local slot = GET_CHILD(ctrlset, 'slot')
            local mat_name = ctrlset:GetUserValue('ITEM_NAME')
            local cur_count_str = '0'
            if IS_ACCOUNT_COIN(mat_name) then
                cur_count_str = TryGetProp(GetMyAccountObj(), mat_name, '0')
            else
                local mat_item = session.GetInvItemByName(mat_name)
                if mat_item then
                    cur_count_str = tostring(mat_item.count)
                end
            end
            local need_count_str = slot:GetEventScriptArgString(ui.DROP)
            local inv_count = GET_CHILD_RECURSIVELY(ctrlset, 'invcount')
            inv_count:SetTextByKey('have', cur_count_str)
            inv_count:SetTextByKey('need', need_count_str)
            if tonumber(cur_count_str) < tonumber(need_count_str) then
                is_material_shortage = true
                break
            end
        end
    end
    if is_material_shortage or (g.continue_reinforce.rf_count > 0 and g.continue_reinforce.count <= 1) then
        if not continue_reinforce_stop_process(goddess_equip_manager) then
            goddess_equip_manager:RunUpdateScript("continue_reinforce_GODDESS_MGR_REFORGE_REG_ITEM", 0.2)
            GODDESS_MGR_REINFORCE_CLEAR_BTN(reinf_left_bg, ref_ok_reinforce)
        end
        return
    end
    if g.continue_reinforce.rf_count > 0 then
        g.continue_reinforce.count = g.continue_reinforce.count - 1
    end
    goddess_equip_manager:RunUpdateScript("continue_reinforce_GODDESS_MGR_REFORGE_REINFORCE_EXEC",
        g.continue_reinforce.delay)
end

function continue_reinforce_GODDESS_MGR_REFORGE_REINFORCE_EXEC(goddess_equip_manager)
    local reinf_left_bg = GET_CHILD_RECURSIVELY(goddess_equip_manager, "reinf_left_bg")
    local ref_do_reinforce = GET_CHILD(reinf_left_bg, "ref_do_reinforce")
    GODDESS_MGR_REFORGE_REINFORCE_EXEC(reinf_left_bg, ref_do_reinforce)
    local ref_ok_reinforce = GET_CHILD_RECURSIVELY(goddess_equip_manager, 'ref_ok_reinforce')
    GODDESS_MGR_REINFORCE_CLEAR_BTN(reinf_left_bg, ref_ok_reinforce)
    return 0
end

function continue_reinforce_stop_script()
    local goddess_equip_manager = ui.GetFrame('goddess_equip_manager')
    goddess_equip_manager:StopUpdateScript("continue_reinforce_GODDESS_MGR_REFORGE_REINFORCE_EXEC")
    goddess_equip_manager:SetUserValue('REINFORCE_RESULT', "SUCCESS")
    GODDESS_MGR_REFORGE_REINFORCE_CLEAR(goddess_equip_manager, true)
    g.continue_reinforce.is_first = false
    g.continue_reinforce.count = 0
    continue_reinforce_next_mat_set(goddess_equip_manager, false)
    ui.SysMsg("{ol}Continuous Reinforcement Cancelled")
end

function continue_reinforce_mat_select(parent, ctrl)
    local goddess_equip_manager = ctrl:GetTopParentFrame()
    ui.EnableSlotMultiSelect(1)
    local ref_slot = GET_CHILD_RECURSIVELY(goddess_equip_manager, 'ref_slot')
    local use_lv = ref_slot:GetUserIValue('ITEM_USE_LEVEL')
    if use_lv == 0 then
        return
    end
    local ctrl_name = ctrl:GetName()
    if ctrl_name == "normal" then
        local normal_max = GET_MAX_SUB_REVISION_COUNT(use_lv)
        continue_reinforce_mat_select_(goddess_equip_manager, use_lv, "normal", normal_max)
    elseif ctrl_name == "premium" then
        local premium_max = GET_MAX_PREMIUM_SUB_REVISION_COUNT(use_lv)
        continue_reinforce_mat_select_(goddess_equip_manager, use_lv, "premium", premium_max)
    end
end

function continue_reinforce_mat_select_(goddess_equip_manager, use_lv, mat_type, need_count)
    local reinf_extra_mat_list = GET_CHILD_RECURSIVELY(goddess_equip_manager, "reinf_extra_mat_list")
    if mat_type == "premium" then
        for i = 0, reinf_extra_mat_list:GetSlotCount() - 1 do
            local slot = reinf_extra_mat_list:GetSlotByIndex(i)
            if slot:GetUserValue('MAT_TYPE') == mat_type then
                local icon = slot:GetIcon()
                if icon then
                    if slot:GetSelectCount() > 0 then
                        slot:SetSelectCount(0)
                        slot:Select(0)
                        g.continue_reinforce.premium_mat = false
                    else
                        local inv_item = session.GetInvItemByType(slot:GetIcon():GetInfo().type)
                        local select_count = math.min(inv_item.count, need_count)
                        slot:SetSelectCount(select_count)
                        slot:Select(1)
                    end
                    g.continue_reinforce.premium_mat = true
                    SCR_LBTNDOWN_GODDESS_REINFORCE_EXTRA_MAT(reinf_extra_mat_list, slot)
                    return
                end
            end
        end
        return
    end
    local available_mats = {}
    local release = false
    for i = 0, reinf_extra_mat_list:GetSlotCount() - 1 do
        local slot = reinf_extra_mat_list:GetSlotByIndex(i)
        if slot:GetUserValue('MAT_TYPE') == "normal" then
            local icon = slot:GetIcon()
            if icon then
                local icon_info = icon:GetInfo()
                local item_cls = GetClassByType('Item', icon_info.type)
                local inv_item = session.GetInvItemByType(icon_info.type)
                if slot:GetSelectCount() > 0 then
                    release = true
                    g.continue_reinforce.normal_mat = false
                end
                local item_lv_str = item_cls.ClassName:match("_([%d]+)_")
                local item_lv = tonumber(item_lv_str)
                if inv_item and item_lv then
                    table.insert(available_mats, {
                        level = item_lv,
                        count = inv_item.count,
                        slot = slot
                    })
                end
            end
        end
    end
    if release == true then
        for _, mat_info in ipairs(available_mats) do
            if mat_info.slot:GetSelectCount() > 0 then
                mat_info.slot:SetSelectCount(0)
                mat_info.slot:Select(0)
            end
        end
        SCR_LBTNDOWN_GODDESS_REINFORCE_EXTRA_MAT(reinf_extra_mat_list, nil)
        return
    end
    table.sort(available_mats, function(a, b)
        return a.level < b.level
    end)
    local selected_count = 0
    local selection_plan = {}
    for _, mat_info in ipairs(available_mats) do
        if selected_count >= need_count then
            break
        end
        local amount_to_select = math.min(mat_info.count, need_count - selected_count)
        if amount_to_select > 0 then
            table.insert(selection_plan, {
                slot = mat_info.slot,
                count = amount_to_select,
                level = mat_info.level
            })
            selected_count = selected_count + amount_to_select
        end
    end
    local used_higher_level = false
    for _, plan in ipairs(selection_plan) do
        plan.slot:SetSelectCount(plan.count)
        plan.slot:Select(1)
        local item_level = plan.level
        if item_level and item_level > use_lv then
            used_higher_level = true
        end
        g.continue_reinforce.normal_mat = true
        SCR_LBTNDOWN_GODDESS_REINFORCE_EXTRA_MAT(reinf_extra_mat_list, plan.slot)
    end
    if used_higher_level then
        local msg = g.lang == "Japanese" and
                        "同レベルの補助材がありません{nl}上位レベルの補助剤を使用します" or
                        "No same-level aid available{nl}Using a higher-level aid"
        imcAddOn.BroadMsg("NOTICE_Dm_!", msg, 2.5)
    end
end

function continue_reinforce_next_mat_set(goddess_equip_manager, do_set)
    local gbox = GET_CHILD_RECURSIVELY(goddess_equip_manager, "gbox")
    if g.continue_reinforce.normal_mat then
        local normal_btn = GET_CHILD(gbox, "normal")
        if do_set == false then
            g.continue_reinforce.normal_mat = false
        end
        continue_reinforce_mat_select(gbox, normal_btn)
    end
    if g.continue_reinforce.premium_mat then
        local premium_btn = GET_CHILD(gbox, "premium")
        if do_set == false then
            g.continue_reinforce.premium_mat = false
        end
        continue_reinforce_mat_select(gbox, premium_btn)
    end
end

function continue_reinforce_run_update_script(gbox)
    if g.continue_reinforce.inv_tbl["first"] == nil then
        g.continue_reinforce.inv_tbl["first"] = true
    end
    if g.continue_reinforce.inv_tbl["first"] then
        local inv_item_list = session.GetInvItemList()
        local inv_guid_list = inv_item_list:GetGuidList()
        local count = inv_guid_list:Count()
        for i = 0, count - 1 do
            local guid = inv_guid_list:Get(i)
            local inv_item = inv_item_list:GetItemByGuid(guid)
            local inv_obj = GetIES(inv_item:GetObject())
            local inv_clsname = inv_obj.ClassName
            if (string.find(inv_clsname, "misc_reinforce_percentUp_") and
                (not string.find(inv_clsname, "_NoTrade") or string.find(inv_clsname, "ea_"))) or
                (string.find(inv_clsname, "misc_Premium_reinforce_percentUp_") and string.find(inv_clsname, "plus")) then
                local inv_item_count = inv_item.count
                g.continue_reinforce.inv_tbl[inv_clsname] = inv_item_count
                g.continue_reinforce.inv_tbl["first"] = false
            end
        end
    end
    for cls_name, count in pairs(g.continue_reinforce.inv_tbl) do
        local inv_item = nil
        local item_count = 0
        if cls_name ~= "first" and cls_name ~= "remove" then
            inv_item = session.GetInvItemByName(cls_name)
            if inv_item then
                item_count = inv_item.count
            end
            if count ~= item_count then
                local frame = gbox:GetTopParentFrame()
                if not g.continue_reinforce.inv_tbl["remove"] then
                    local ref_slot_bg = GET_CHILD_RECURSIVELY(frame, "ref_slot_bg")
                    local ref_slot = GET_CHILD(ref_slot_bg, "ref_slot")
                    GODDESS_MGR_REFORGE_ITEM_REMOVE(ref_slot_bg, ref_slot)
                    g.continue_reinforce.inv_tbl["remove"] = true
                    return 1
                else
                    local iesid = gbox:GetUserValue("IESID")
                    local inv_item_ = session.GetInvItemByGuid(iesid)
                    if inv_item_ then
                        local item_obj = GetIES(inv_item_:GetObject())
                        GODDESS_MGR_REFORGE_REG_ITEM(frame, inv_item_, item_obj)
                    end
                    g.continue_reinforce.inv_tbl["remove"] = false
                    g.continue_reinforce.inv_tbl["first"] = true
                    return 1
                end
            end
        end
    end
    return 1
end

function continue_reinforce_GODDESS_MGR_REFORGE_INV_RBTN(item_obj, slot, guid)
    local frame = ui.GetFrame('goddess_equip_manager')
    local inv_item = session.GetInvItemByGuid(guid)
    if inv_item then
        local item_cls = GetClassByType("Item", inv_item.type)
        if string.find(item_cls.MarketCategory, "Weapon_") or string.find(item_cls.MarketCategory, "Armor_") or
            string.find(item_cls.MarketCategory, "Accessory_") then
            GODDESS_MGR_REFORGE_REG_ITEM(frame, inv_item, item_obj)
        else
            INV_ICON_USE(inv_item)
            continue_reinforce_GODDESS_MGR_REFORGE_REG_ITEM()
            frame:RunUpdateScript("continue_reinforce_GODDESS_MGR_REFORGE_REG_ITEM_reserve", 0.2)
        end
    end
end

function continue_reinforce_GODDESS_MGR_REFORGE_REG_ITEM_reserve(frame)
    local warningmsgbox = ui.GetFrame("warningmsgbox")
    if warningmsgbox:IsVisible() == 1 then
        return 1
    end
    local inputstring = ui.GetFrame("inputstring")
    if inputstring:IsVisible() == 1 then
        return 1
    end
    continue_reinforce_GODDESS_MGR_REFORGE_REG_ITEM()
    return 0
end

function continue_reinforce_GODDESS_MGR_REFORGE_REG_ITEM()
    if not g.continue_reinforce.use or g.settings.continue_reinforce.use == 0 then
        return
    end
    INVENTORY_SET_CUSTOM_RBTNDOWN('GODDESS_MGR_REFORGE_INV_RBTN')
    local frame = ui.GetFrame('goddess_equip_manager')
    local main_tab = GET_CHILD_RECURSIVELY(frame, 'main_tab')
    if main_tab:GetSelectItemIndex() ~= 0 then
        return
    end
    local reforge_tab = GET_CHILD_RECURSIVELY(frame, 'reforge_tab')
    if reforge_tab:GetSelectItemIndex() ~= 0 then
        return
    end
    INVENTORY_SET_CUSTOM_RBTNDOWN('continue_reinforce_GODDESS_MGR_REFORGE_INV_RBTN')
    local ref_slot = GET_CHILD_RECURSIVELY(frame, 'ref_slot')
    local iesid = ref_slot:GetUserValue("ITEM_GUID")
    local gbox = GET_CHILD_RECURSIVELY(frame, 'gbox')
    gbox:SetUserValue("IESID", iesid)
    g.continue_reinforce.is_first = false
    local reinf_main_mat_bg = GET_CHILD_RECURSIVELY(frame, 'reinf_main_mat_bg')
    local child_count = reinf_main_mat_bg:GetChildCount()
    local stop = false
    for i = 0, child_count - 1 do
        local child = reinf_main_mat_bg:GetChildByIndex(i)
        if child and string.find(child:GetName(), "GODDESS_REINF_MAT_") then
            local btn = GET_CHILD_RECURSIVELY(child, "btn")
            GODDESS_MGR_REFORGE_REINFORCE_REG_MAT(child, btn)
            local slot = GET_CHILD(child, 'slot')
            local mat_name = child:GetUserValue('ITEM_NAME')
            local cur_count = '0'
            if IS_ACCOUNT_COIN(mat_name) == true then
                local acc = GetMyAccountObj()
                cur_count = TryGetProp(acc, mat_name, '0')
                if cur_count == 'None' then
                    cur_count = '0'
                end
            else
                local mat_item = session.GetInvItemByName(mat_name)
                if mat_item == nil then
                    cur_count = '0'
                else
                    cur_count = tostring(mat_item.count)
                end
            end
            local need_count = slot:GetEventScriptArgString(ui.DROP)
            local inv_count = GET_CHILD_RECURSIVELY(child, 'invcount')
            inv_count:SetTextByKey('have', cur_count)
            inv_count:SetTextByKey('need', need_count)
            if tonumber(need_count) > tonumber(cur_count) then
                stop = true
            end
        end
    end
    if stop then
        frame:StopUpdateScript("continue_reinforce_GODDESS_MGR_REFORGE_REG_ITEM_reserve")
    end
end

function continue_reinforce_GODDESS_MGR_REFORGE_ITEM_REMOVE()
    INVENTORY_SET_CUSTOM_RBTNDOWN('GODDESS_MGR_REFORGE_INV_RBTN')
end

function continue_reinforce_GODDESS_MGR_REFORGE_TAB_CHANGE()
    INVENTORY_SET_CUSTOM_RBTNDOWN('GODDESS_MGR_REFORGE_INV_RBTN')
    local goddess_equip_manager = ui.GetFrame('goddess_equip_manager')
    local reforge_tab = GET_CHILD_RECURSIVELY(goddess_equip_manager, 'reforge_tab')
    local tab_index = reforge_tab:GetSelectItemIndex()
    if tab_index == 0 then
        continue_reinforce_GODDESS_EQUIP_MANAGER_OPEN()
    else
        goddess_equip_manager:RemoveChild("gbox")
    end
end
-- continue_reinforce ここまで

-- characters_item_serch ここから
g.characters_item_serch_path =
    string.format("../addons/%s/%s/characters_item_serch.json", addon_name_lower, g.active_id)
g.characters_item_serch = g.characters_item_serch or {}
g.characters_item_serch_dat_tbl = {string.format("../addons/%s/%s/characters_item_serch_warehouse.dat",
    addon_name_lower, g.active_id),
                                   string.format("../addons/%s/%s/characters_item_serch_inventory.dat",
    addon_name_lower, g.active_id),
                                   string.format("../addons/%s/%s/characters_item_serch_equips.dat", addon_name_lower,
    g.active_id),
                                   string.format("../addons/%s/%s/characters_item_serch_accountwarehouse.dat",
    addon_name_lower, g.active_id)}
g.characters_item_serch_old_dat_tbl = {string.format("../addons/%s/%s/warehouse.dat", "characters_item_serch",
    g.active_id), string.format("../addons/%s/%s/inventory.dat", "characters_item_serch", g.active_id),
                                       string.format("../addons/%s/%s/equips.dat", "characters_item_serch", g.active_id)}

function characters_item_serch_save_settings()
    g.save_json(g.characters_item_serch_path, g.characters_item_serch_settings)
end

function characters_item_serch_load_settings()
    local settings = g.load_json(g.characters_item_serch_path)
    if not settings then
        settings = {
            chars = {}
        }
    end
    g.characters_item_serch_settings = settings
    characters_item_serch_save_settings()
    for i = 1, #g.characters_item_serch_dat_tbl - 1 do
        local new_path = g.characters_item_serch_dat_tbl[i]
        local old_path = g.characters_item_serch_old_dat_tbl[i]
        local new_file = io.open(new_path, "r")
        if not new_file then
            local content_to_write = ""
            if old_path then
                local old_file = io.open(old_path, "r")
                if old_file then
                    content_to_write = old_file:read("*all")
                    old_file:close()
                end
            end
            local file_to_write = io.open(new_path, "w")
            if file_to_write then
                file_to_write:write(content_to_write)
                file_to_write:close()
            end
        else
            new_file:close()
        end
    end
end

function characters_item_serch_on_init()
    if _G["BARRACK_CHARLIST_ON_INIT"] and _G["current_layer"] then
        g.characters_item_serch.layer = _G["current_layer"] or 1
    end
    if not g.characters_item_serch_settings then
        characters_item_serch_load_settings()
    end
    g.setup_hook_before('ON_GAMEEXIT_TIMER_END', 'characters_item_serch_ON_GAMEEXIT_TIMER_END')
    g.setup_hook_before("INVENTORY_CLOSE", "characters_item_serch_INVENTORY_CLOSE")
    g.setup_hook_before('ACCOUNTWAREHOUSE_CLOSE', "characters_item_serch_ACCOUNTWAREHOUSE_CLOSE")
    g.setup_hook_before('WAREHOUSE_CLOSE', 'characters_item_serch_WAREHOUSE_CLOSE')
    local sysmenu = ui.GetFrame("sysmenu")
    local inven = GET_CHILD(sysmenu, "inven")
    AUTO_CAST(inven)
    inven:SetEventScript(ui.RBUTTONUP, "characters_item_serch_toggle_frame")
    local function get_localized_tooltip(lang)
        if lang == "Japanese" then
            return "{@st59}インベントリ (F2){nl}右クリック: Characters Item Serch"
        elseif lang == "kr" then
            return "{@st59}인벤토리 (F2){nl}Right click: Characters Item Serch"
        else
            return "{@st59}Inventory (F2){nl}Right click: Characters Item Serch"
        end
    end
    local tooltip = get_localized_tooltip(g.lang)
    inven:SetTextTooltip(tooltip)
    characters_item_serch_char_data()
end

function characters_item_serch_toggle_frame()
    if g.settings.characters_item_serch.use == 0 then
        return
    end
    local characters_item_serch = ui.GetFrame(addon_name_lower .. "characters_item_serch")
    if not characters_item_serch then
        characters_item_frame_init(nil, nil, g.login_name, 0)
    elseif characters_item_serch:IsVisible() == 1 then
        characters_item_serch_close(characters_item_serch)
    end
end

function characters_item_serch_char_data()
    local chars = g.characters_item_serch_settings["chars"]
    local acc_info = session.barrack.GetMyAccount()
    local pc_count = acc_info:GetPCCount()
    for i = 0, pc_count - 1 do
        local pc_info = acc_info:GetPCByIndex(i)
        if pc_info then
            local pc_cid = pc_info:GetCID()
            local pc_apc = pc_info:GetApc()
            if pc_apc then
                local pc_name = pc_apc:GetName()
                chars[pc_name] = {
                    name = pc_name,
                    layer = g.characters_item_serch.layer,
                    order = i,
                    cid = pc_cid
                }
            end
        end
    end
    local barrack_all = acc_info:GetBarrackPCCount()
    if barrack_all > 0 then
        local barrack_chars = {}
        for i = 0, barrack_all - 1 do
            local pc_info = acc_info:GetBarrackPCByIndex(i)
            if pc_info then
                barrack_chars[pc_info:GetName()] = true
            end
        end
        local chars_to_delete = {}
        for char_name, _ in pairs(chars) do
            if not barrack_chars[char_name] then
                table.insert(chars_to_delete, char_name)
            end
        end
        if #chars_to_delete > 0 then
            for _, char_name in ipairs(chars_to_delete) do
                chars[char_name] = nil
            end
        end
    end
    characters_item_serch_save_settings()
end

function characters_item_serch_ON_GAMEEXIT_TIMER_END(frame)
    local type = frame:GetUserValue("EXIT_TYPE")
    if type == "Exit" or type == "Logout" or type == "Barrack" then
        characters_item_serch_inventory_save_list()
    end
end

function characters_item_serch_INVENTORY_CLOSE()
    characters_item_serch_inventory_save_list()
end

function characters_item_serch_ACCOUNTWAREHOUSE_CLOSE(frame)
    local item_list = session.GetEtcItemList(IT_ACCOUNT_WAREHOUSE)
    local sorted_guid_list = item_list:GetSortedGuidList()
    local count = sorted_guid_list:Count()
    local items_to_save = {}
    for i = 0, count - 1 do
        local guid = sorted_guid_list:Get(i)
        local aw_item = item_list:GetItemByGuid(guid)
        if aw_item then
            local clsid = aw_item.type
            local iesid = aw_item:GetIESID()
            local obj = GetObjectByGuid(iesid)
            if obj then
                local item_name = string.lower(dictionary.ReplaceDicIDInCompStr(obj.Name))
                local item_count = aw_item.count
                local item_cls = GetClassByType('Item', clsid)
                local category = "false"
                if item_cls and item_cls.MarketCategory ~= "None" then
                    category = item_cls.MarketCategory:match("^(.-)_")
                end
                table.insert(items_to_save,
                    {g.lang == "Japanese" and "チーム倉庫" or "Account Warehouse", iesid, clsid, item_count,
                     item_name, "accountwarehouse", category})
            end
        end
    end
    --[[local another_warehouse = ui.GetFrame("another_warehouse")
    if another_warehouse then
        another_warehouse:ShowWindow(0)
    end]]
    local dat_file_path = g.characters_item_serch_dat_tbl[4]
    characters_item_serch_save_item_list_to_dat(dat_file_path, items_to_save, true)
end

function characters_item_serch_save_item_list_to_dat(dat_path, items_to_save, is_overwrite)
    local lines = {}
    if not is_overwrite then
        local file_read = io.open(dat_path, "r")
        if file_read then
            for line in file_read:lines() do
                if line:match("^(.-):::") ~= g.login_name then
                    table.insert(lines, line)
                end
            end
            file_read:close()
        end
    end
    for _, item in ipairs(items_to_save) do
        table.insert(lines, table.concat(item, ":::"))
    end
    local file = io.open(dat_path, "w")
    if file then
        file:write(table.concat(lines, "\n"))
        file:close()
    end
end

function characters_item_serch_inventory_save_list()
    local inv_item_list = session.GetInvItemList()
    local inv_guid_list = inv_item_list:GetGuidList()
    local cnt = inv_guid_list:Count()
    -- inventory save
    local items = {}
    for i = 0, cnt - 1 do
        local guid = inv_guid_list:Get(i)
        local inv_Item = inv_item_list:GetItemByGuid(guid)
        local inv_obj = GetIES(inv_Item:GetObject())
        local inv_clsid = inv_obj.ClassID
        local inv_count = inv_Item.count
        local item_cls = GetClassByType('Item', inv_clsid)
        local category = "false"
        if item_cls ~= nil and item_cls.MarketCategory ~= "None" then
            category = item_cls.MarketCategory:match("^(.-)_")
        end
        local item_name = string.lower(dictionary.ReplaceDicIDInCompStr(inv_obj.Name))
        table.insert(items, {g.login_name, guid, inv_clsid, inv_count, item_name, "inventory", category})
    end
    local inventory_dat = g.characters_item_serch_dat_tbl[2]
    characters_item_serch_save_item_list_to_dat(inventory_dat, items)
    -- equips save
    local items = {}
    local equiplist = session.GetEquipItemList()
    for i = 0, equiplist:Count() - 1 do
        local equip_item = equiplist:GetEquipItemByIndex(i)
        local obj = GetIES(equip_item:GetObject())
        if obj ~= nil then
            local iesid = equip_item:GetIESID()
            if iesid ~= "0" then
                local clsid = obj.ClassID
                local item_cls = GetClassByType('Item', clsid)
                local category = "false"
                if item_cls ~= nil and item_cls.MarketCategory ~= "None" then
                    category = item_cls.MarketCategory:match("^(.-)_")
                end
                local item_name = string.lower(dictionary.ReplaceDicIDInCompStr(obj.Name))
                table.insert(items, {g.login_name, iesid, clsid, 1, item_name, "equips", category})
            end
        end
    end
    local mc_frame = ui.GetFrame("monstercardslot")
    for i = 1, 14 do
        local card_info = equipcard.GetCardInfo(i)
        if card_info then
            local clsid = card_info:GetCardID()
            local item_cls = GetClassByType("Item", clsid)
            local item_name = string.lower(dictionary.ReplaceDicIDInCompStr(item_cls.Name))
            local category = "false"
            if item_cls ~= nil and item_cls.MarketCategory ~= "None" then
                category = item_cls.MarketCategory:match("^(.-)_")
            end
            table.insert(items, {g.login_name, "None" .. i, clsid, 1, item_name, "equips", category})
        end
    end
    local equips_dat = g.characters_item_serch_dat_tbl[3]
    characters_item_serch_save_item_list_to_dat(equips_dat, items)
end

function characters_item_serch_WAREHOUSE_CLOSE(frame)
    local warehouse = ui.GetFrame('warehouse')
    local gbox = warehouse:GetChild("gbox")
    local slotset = gbox:GetChild("slotset")
    AUTO_CAST(slotset)
    local items = {}
    for i = 0, slotset:GetSlotCount() - 1 do
        local slot = slotset:GetSlotByIndex(i)
        local icon = slot:GetIcon()
        if icon then
            local icon_info = icon:GetInfo()
            local iesid = icon_info:GetIESID()
            local obj = GetObjectByGuid(iesid)
            local clsid = obj.ClassID
            local item_cls = GetClassByType('Item', clsid)
            local category = "false"
            if item_cls and item_cls.MarketCategory ~= "None" then
                category = item_cls.MarketCategory:match("^(.-)_")
            end
            local item_name = string.lower(dictionary.ReplaceDicIDInCompStr(obj.Name))
            table.insert(items, {g.login_name, iesid, clsid, icon_info.count, item_name, "warehouse", category})
        end
    end
    local warehouse_dat = g.characters_item_serch_dat_tbl[1]
    characters_item_serch_save_item_list_to_dat(warehouse_dat, items)
end

function characters_item_serch_load_data(select_name, search_mode, search_text)
    local dat_tbl = {}
    for i = 1, #g.characters_item_serch_dat_tbl - 1 do
        table.insert(dat_tbl, g.characters_item_serch_dat_tbl[i])
    end
    local items = {}
    local target_name = (select_name == "") and g.login_name or select_name
    if search_mode == "ITEM_SEARCH" then
        table.insert(dat_tbl, g.characters_item_serch_dat_tbl[4])
    end
    for _, dat_file_path in ipairs(dat_tbl) do
        local file = io.open(dat_file_path, "r")
        if file then
            local content = file:read("*all")
            file:close()
            for line in content:gmatch("([^\n]+)") do
                local is_match = false
                if search_mode == "ITEM_SEARCH" then
                    if string.find(string.lower(line), string.lower(search_text)) then
                        is_match = true
                    end
                else
                    if line:find(target_name, 1, true) == 1 then
                        is_match = true
                    end
                end
                if is_match then
                    local parts = {}
                    for part in (line .. ":::"):gmatch("(.-):::") do
                        table.insert(parts, part)
                    end
                    if #parts > 0 and parts[#parts] == "" then
                        table.remove(parts)
                    end
                    if search_mode == "ITEM_SEARCH" then
                        parts[3] = tonumber(parts[3]) or 0
                    else
                        table.remove(parts, 1)
                        if #parts > 0 then
                            parts[2] = tonumber(parts[2]) or 0
                        end
                    end
                    if #parts > 0 then
                        table.insert(items, parts)
                    end
                end
            end
        end
    end
    if search_mode == "ITEM_SEARCH" then
        table.sort(items, function(a, b)
            local a_is_warehouse = (a[1] == "チーム倉庫" or a[1] == "Account Warehouse")
            local b_is_warehouse = (b[1] == "チーム倉庫" or b[1] == "Account Warehouse")
            if a_is_warehouse and not b_is_warehouse then
                return false
            elseif not a_is_warehouse and b_is_warehouse then
                return true
            else
                return a[3] < b[3]
            end
        end)
    else
        table.sort(items, function(a, b)
            return a[2] < b[2]
        end)
    end
    return items
end

function characters_item_serch_item_search(my_frame, ctrl, str, num)
    local characters_item_serch = ctrl:GetTopParentFrame()
    local search_edit = GET_CHILD(characters_item_serch, "search_edit")
    AUTO_CAST(search_edit)
    local search_text = search_edit:GetText()
    if search_text == "" then
        characters_item_frame_init(nil, nil, g.login_name, 0)
        return
    end
    local gb = GET_CHILD(characters_item_serch, "gb")
    gb:RemoveAllChild()
    local tree = gb:CreateOrGetControl("tree", 'name_tree', 0, 0, 0, 0)
    AUTO_CAST(tree)
    tree:Clear()
    tree:EnableDrawFrame(false)
    tree:SetFitToChild(true, 10)
    tree:SetFontName("white_16_ol")
    local items = characters_item_serch_load_data("", "ITEM_SEARCH", search_text)
    local names = {}
    for i = 1, #items do
        local item = items[i]
        local name = item[1]
        if not names[name] then
            names[name] = true
            local slot_set = characters_item_serch_make_inven_slotset(tree, name)
            tree:Add(name)
            tree:Add(slot_set, name)
        end
    end
    for i = 1, #items do
        local item = items[i]
        local name = item[1]
        local clsid = item[3]
        local item_count = item[4]
        local slot_set = GET_CHILD(tree, name)
        characters_item_serch_insert_item_to_tree(slot_set, clsid, item_count)
    end
    tree:Resize(characters_item_serch:GetWidth() - 40, characters_item_serch:GetHeight() - 135)
    tree:OpenNodeAll()
end

function characters_item_serch_get_sorted_sub_categories(items)
    local subcategories = {}
    local subcategory_list = {}
    local subcategory_order = {
        ["false"] = 1,
        ["equips"] = 2,
        ["warehouse"] = 3,
        ["Weapon"] = 4,
        ["Armor"] = 5,
        ["HairAcc"] = 6,
        ["Accessory"] = 7,
        ["nil"] = 8,
        ["Premium"] = 9,
        ["Look"] = 10,
        ["ChangeEquip"] = 11,
        ["Misc"] = 12,
        ["Consume"] = 13,
        ["Recipe"] = 14,
        ["Card"] = 15,
        ["Gem"] = 16,
        ["Ancient"] = 17,
        ["OPTMisc"] = 18,
        ["PHousing"] = 19
    }
    local function get_order(name)
        return subcategory_order[name] or 100
    end
    for i = 1, #items do
        local item = items[i]
        local category = item[5]
        local sub_category = item[6]
        local target_category = (category == "inventory") and sub_category or category
        if not subcategories[target_category] then
            subcategories[target_category] = true
            table.insert(subcategory_list, target_category)
        end
    end
    table.sort(subcategory_list, function(a, b)
        return get_order(a) < get_order(b)
    end)
    return subcategory_list
end

function characters_item_frame_init(frame, ctrl, select_name, num)
    local characters_item_serch = ui.CreateNewFrame("notice_on_pc", addon_name_lower .. "characters_item_serch", 0, 0,
        70, 30)
    AUTO_CAST(characters_item_serch)
    characters_item_serch:SetSkinName("test_frame_low")
    characters_item_serch:Resize(670, 1080)
    characters_item_serch:SetPos(0, 0)
    characters_item_serch:EnableMove(0)
    characters_item_serch:SetLayerLevel(100)
    characters_item_serch:SetTitleBarSkin("None")
    characters_item_serch:RemoveAllChild()
    characters_item_serch:ShowWindow(1)
    local title_gb = characters_item_serch:CreateOrGetControl("groupbox", "title_gb", 0, 0,
        characters_item_serch:GetWidth(), 55)
    title_gb:SetSkinName("test_frame_top")
    AUTO_CAST(title_gb)
    local title_text = title_gb:CreateOrGetControl("richtext", "title_text", 0, 0, ui.CENTER_HORZ, ui.TOP, 0, 15, 0, 0)
    AUTO_CAST(title_text)
    title_text:SetText('{ol}{s26}Characters Item Serch')
    local close = characters_item_serch:CreateOrGetControl("button", "close", 0, 0, 25, 25)
    AUTO_CAST(close)
    close:SetImage("testclose_button")
    close:SetGravity(ui.RIGHT, ui.TOP)
    close:SetEventScript(ui.LBUTTONUP, "characters_item_serch_close")
    local login_name = characters_item_serch:CreateOrGetControl("richtext", "login_name", 20, 60, 0, 0)
    AUTO_CAST(login_name)
    login_name:SetText(select_name == "" and '{ol}{s18}' .. g.login_name or '{ol}{s18}' .. select_name)
    local char_switch = characters_item_serch:CreateOrGetControl("button", "char_switch", 20, 85, 150, 30)
    AUTO_CAST(char_switch)
    char_switch:SetText(g.lang == "Japanese" and "{ol}キャラクター切替" or "{ol}character switch")
    char_switch:SetSkinName("test_pvp_btn")
    char_switch:SetEventScript(ui.LBUTTONUP, "characters_item_serch_context")
    local search_edit = characters_item_serch:CreateOrGetControl("edit", "search_edit", 200, 80, 250, 40)
    AUTO_CAST(search_edit)
    search_edit:SetFontName("white_18_ol")
    search_edit:SetTextAlign("left", "center")
    search_edit:SetSkinName("inventory_serch")
    search_edit:SetEventScript(ui.ENTERKEY, "characters_item_serch_item_search")
    local search_btn = search_edit:CreateOrGetControl("button", "search_btn", 0, 0, 60, 38)
    AUTO_CAST(search_btn)
    search_btn:SetImage("inven_s")
    search_btn:SetGravity(ui.RIGHT, ui.TOP)
    search_btn:SetEventScript(ui.LBUTTONUP, "characters_item_serch_item_search")
    local gb = characters_item_serch:CreateOrGetControl("groupbox", "gb", 20, 120,
        characters_item_serch:GetWidth() - 40, characters_item_serch:GetHeight() - 135)
    gb:SetSkinName("test_frame_midle")
    AUTO_CAST(gb)
    gb:RemoveAllChild()
    local tree = gb:CreateOrGetControl("tree", 'tree', 0, 0, 0, 0)
    AUTO_CAST(tree)
    tree:Clear()
    tree:EnableDrawFrame(false)
    tree:SetFitToChild(true, 10)
    tree:SetFontName("white_16_ol")
    -- tree:SetTabWidth(80)
    characters_item_serch_build_tree(characters_item_serch, tree, select_name)
end

function characters_item_serch_close(characters_item_serch)
    ui.DestroyFrame(characters_item_serch:GetName())
end

function characters_item_serch_context()
    local chars = g.characters_item_serch_settings["chars"]
    local sorted_chars = {}
    for name, data in pairs(chars) do
        table.insert(sorted_chars, {
            name = name,
            data = data
        })
    end
    table.sort(sorted_chars, function(a, b)
        return a.data.layer < b.data.layer or (a.data.layer == b.data.layer and a.data.order < b.data.order)
    end)
    local context = ui.CreateContextMenu("characters_item_serch_context", "{ol}Characters", 0, 0, 120, 0)
    ui.AddContextMenuItem(context, "-----")
    for _, char_data in ipairs(sorted_chars) do
        local char_name = char_data.name
        local escaped_name = string.gsub(char_name, "'", "\\'")
        local str_scp = string.format("characters_item_frame_init(nil,nil,'%s', 0)", escaped_name)
        ui.AddContextMenuItem(context, char_name, str_scp)
    end
    ui.OpenContextMenu(context)
end

function characters_item_serch_build_tree(characters_item_serch, tree, select_name)
    local items = characters_item_serch_load_data(select_name)
    local sub_category_list = characters_item_serch_get_sorted_sub_categories(items)
    local category_display_names = {
        warehouse = g.lang == "Japanese" and "倉庫" or "Warehouse",
        equips = g.lang == "Japanese" and "装備中" or "Equips",
        Ancient = g.lang == "Japanese" and "アシスター" or "Ancient",
        ["nil"] = g.lang == "Japanese" and "レリック" or "Relic",
        PHousing = g.lang == "Japanese" and "家具" or "Housing"
    }
    local silver = 0
    for i = 1, #items do
        if items[i][1] == "0" then
            silver = items[i][3]
            break
        end
    end
    local categorized_items = {}
    for _, item in ipairs(items) do
        local category = item[5]
        local sub_category = item[6]
        local target_category = (category == "inventory") and sub_category or category
        if not categorized_items[target_category] then
            categorized_items[target_category] = {}
        end
        table.insert(categorized_items[target_category], item)
    end
    local iesids = {}
    for i = 1, #sub_category_list do
        local category = sub_category_list[i]
        local disp_category
        if category == "false" then
            disp_category = "     " .. "{img icon_item_silver 20 20}" .. " " .. GET_COMMAED_STRING(tonumber(silver))
            tree:Add(disp_category)
        else
            disp_category = category_display_names[category] or ClMsg(category)
            local new_slots = characters_item_serch_make_inven_slotset(tree, category)
            tree:Add(disp_category)
            tree:Add(new_slots, category)
            local items_in_category = categorized_items[category] or {}
            for _, item in ipairs(items_in_category) do
                local iesid, clsid, item_count = item[1], item[2], item[3]
                if not iesids[iesid] then
                    iesids[iesid] = true
                    characters_item_serch_insert_item_to_tree(new_slots, clsid, item_count)
                end
            end
        end
    end
    tree:Resize(characters_item_serch:GetWidth() - 40, characters_item_serch:GetHeight() - 135)
    tree:OpenNodeAll()
end

function characters_item_serch_make_inven_slotset(tree, name)
    local slotset = tree:CreateOrGetControl('slotset', name, 20, 0, 0, 0)
    AUTO_CAST(slotset)
    slotset:EnablePop(0)
    slotset:EnableDrag(0)
    slotset:EnableDrop(0)
    slotset:SetMaxSelectionCount(999)
    slotset:SetSlotSize(40, 40)
    slotset:SetColRow(15, 1)
    slotset:SetSpc(0, 0)
    slotset:SetSkinName('invenslot')
    slotset:EnableSelection(0)
    slotset:CreateSlots()
    return slotset
end

function characters_item_serch_insert_item_to_tree(new_slots, clsid, item_count)
    local slot_count = new_slots:GetSlotCount()
    local count = new_slots:GetUserIValue("SLOT_ITEM_COUNT") or 0
    while slot_count <= count do
        new_slots:ExpandRow()
        slot_count = new_slots:GetSlotCount()
    end
    local slot = new_slots:GetSlotByIndex(count)
    count = count + 1
    new_slots:SetUserValue("SLOT_ITEM_COUNT", count)
    slot:ShowWindow(1)
    local item_cls = GetClassByType('Item', clsid)
    if item_cls then
        slot:SetSkinName('invenslot2')
        SET_SLOT_ITEM_CLS(slot, item_cls)
        SET_SLOT_BG_BY_ITEMGRADE(slot, item_cls)
        if tonumber(item_count) > 1 then
            SET_SLOT_COUNT_TEXT(slot, item_count, "{ol}{s14}")
        end
    end
end
-- characters_item_serch ここまで

-- always_status ここから
g.always_status_path = string.format("../addons/%s/%s/always_status.json", addon_name_lower, g.active_id)
local always_status_group_colors = {
    base = "{#00FF00}",
    atk1 = "{#FF6600}",
    atk2 = "{#FF4040}",
    def = "{#66B3FF}"
}

local always_status_master_list =
    { -- { key = "プログラム上の名前", group = "色グループ", on = デフォルト表示(1=ON), jp = "日本語短縮名" }
    -- 基本ステータス
    {
        key = "STR",
        group = "base",
        on = 1
    }, {
        key = "INT",
        group = "base",
        on = 1
    }, {
        key = "CON",
        group = "base",
        on = 0
    }, {
        key = "MNA",
        group = "base",
        on = 0
    }, {
        key = "DEX",
        group = "base",
        on = 0
    }, {
        key = "gear_score",
        group = "base",
        on = 1
    }, {
        key = "ability_point_score",
        group = "base",
        on = 1
    }, {
        key = "PATK",
        group = "atk1",
        on = 1
    }, {
        key = "MATK",
        group = "atk1",
        on = 1
    }, {
        key = "HEAL_PWR",
        group = "atk1",
        on = 0
    }, {
        key = "SR",
        group = "atk1",
        on = 0
    }, {
        key = "HR",
        group = "atk1",
        on = 1
    }, {
        key = "BLK_BREAK",
        group = "atk1",
        on = 1
    }, {
        key = "CRTATK",
        group = "atk1",
        on = 1,
        jp = "物理クリ攻撃"
    }, {
        key = "CRTMATK",
        group = "atk1",
        on = 1,
        jp = "魔法クリ攻撃"
    }, {
        key = "CRTHR",
        group = "atk1",
        on = 1,
        jp = "クリ発生"
    }, {
        key = "DEF",
        group = "def",
        on = 0
    }, {
        key = "MDEF",
        group = "def",
        on = 0
    }, {
        key = "SDR",
        group = "def",
        on = 0
    }, {
        key = "DR",
        group = "def",
        on = 1
    }, {
        key = "BLK",
        group = "def",
        on = 0
    }, {
        key = "CRTDR",
        group = "def",
        on = 1,
        jp = "クリ抵抗"
    }, {
        key = "MSPD",
        group = "atk1",
        on = 1
    }, {
        key = "CastingSpeed",
        group = "atk1",
        on = 1,
        jp = "キャス時間比率"
    }, {
        key = "Add_Damage_Atk",
        group = "atk2",
        on = 0
    }, {
        key = "ResAdd_Damage",
        group = "def",
        on = 0,
        jp = "追加ダメ抵抗"
    }, {
        key = "Aries_Atk",
        group = "atk2",
        on = 0,
        jp = "突アップ"
    }, {
        key = "Slash_Atk",
        group = "atk2",
        on = 0,
        jp = "斬アップ"
    }, {
        key = "Strike_Atk",
        group = "atk2",
        on = 0,
        jp = "打アップ"
    }, {
        key = "Arrow_Atk",
        group = "atk2",
        on = 0,
        jp = "弓アップ"
    }, {
        key = "Cannon_Atk",
        group = "atk2",
        on = 0,
        jp = "キャノンアップ"
    }, {
        key = "Gun_Atk",
        group = "atk2",
        on = 0,
        jp = "銃器アップ"
    }, {
        key = "Magic_Melee_Atk",
        group = "atk2",
        on = 0,
        jp = "無属性アップ"
    }, {
        key = "Magic_Fire_Atk",
        group = "atk2",
        on = 0,
        jp = "炎属性アップ"
    }, {
        key = "Magic_Ice_Atk",
        group = "atk2",
        on = 0,
        jp = "氷属性アップ"
    }, {
        key = "Magic_Lightning_Atk",
        group = "atk2",
        on = 0,
        jp = "雷属性アップ"
    }, {
        key = "Magic_Earth_Atk",
        group = "atk2",
        on = 0,
        jp = "地属性アップ"
    }, {
        key = "Magic_Poison_Atk",
        group = "atk2",
        on = 0,
        jp = "毒属性アップ"
    }, {
        key = "Magic_Dark_Atk",
        group = "atk2",
        on = 0,
        jp = "闇属性アップ"
    }, {
        key = "Magic_Holy_Atk",
        group = "atk2",
        on = 0,
        jp = "聖属性アップ"
    }, {
        key = "Magic_Soul_Atk",
        group = "atk2",
        on = 0,
        jp = "念属性アップ"
    }, {
        key = "BOSS_ATK",
        group = "atk2",
        on = 1,
        jp = "ボス対象攻撃力"
    }, {
        key = "Cloth_Atk",
        group = "atk2",
        on = 0,
        jp = "クロース対象"
    }, {
        key = "Leather_Atk",
        group = "atk2",
        on = 0,
        jp = "レザー対象"
    }, {
        key = "Iron_Atk",
        group = "atk2",
        on = 0,
        jp = "プレート対象"
    }, {
        key = "Ghost_Atk",
        group = "atk2",
        on = 0,
        jp = "アストラル対象"
    }, {
        key = "MiddleSize_Def",
        group = "def",
        on = 1,
        jp = "中型相殺"
    }, {
        key = "Cloth_Def",
        group = "def",
        on = 0,
        jp = "クロース相殺"
    }, {
        key = "Leather_Def",
        group = "def",
        on = 1,
        jp = "レザー相殺"
    }, {
        key = "Iron_Def",
        group = "def",
        on = 0,
        jp = "プレート相殺"
    }, {
        key = "stun_res",
        group = "def",
        on = 0
    }, {
        key = "high_fire_res",
        group = "def",
        on = 0
    }, {
        key = "high_freezing_res",
        group = "def",
        on = 0
    }, {
        key = "high_lighting_res",
        group = "def",
        on = 0
    }, {
        key = "high_poison_res",
        group = "def",
        on = 0,
        jp = "極：猛毒抵抗"
    }, {
        key = "high_laceration_res",
        group = "def",
        on = 0
    }, {
        key = "portion_expansion",
        group = "def",
        on = 0,
        jp = "エリクサー広域"
    }, {
        key = "Forester_Atk",
        group = "atk2",
        on = 0,
        jp = "植物対象攻撃力"
    }, {
        key = "Widling_Atk",
        group = "atk2",
        on = 0,
        jp = "野獣対象攻撃力"
    }, {
        key = "Klaida_Atk",
        group = "atk2",
        on = 0,
        jp = "昆虫対象攻撃力"
    }, {
        key = "Paramune_Atk",
        group = "atk2",
        on = 0,
        jp = "変異対象攻撃力"
    }, {
        key = "Velnias_Atk",
        group = "atk2",
        on = 0,
        jp = "悪魔対象攻撃力"
    }, {
        key = "perfection",
        group = "atk2",
        on = 1,
        jp = "パーフェクト"
    }, {
        key = "revenge",
        group = "atk2",
        on = 0,
        jp = "復讐"
    }}

function always_status_save_settings()
    g.save_json(g.always_status_path, g.always_status_settings)
end

function always_status_load_settings()
    local settings = g.load_json(g.always_status_path)
    local volume = config.GetSoundVolume()
    if not settings then
        settings = {}
        settings["base"] = {
            frame_X = 1600,
            frame_Y = 500,
            enable = 1,
            volume = volume,
            color = {}
        }
        for _, status_info in ipairs(always_status_master_list) do
            local key = status_info.key
            local group = status_info.group
            settings.base.color[key] = always_status_group_colors[group] or "{#FFFFFF}"
        end
        for i = 1, 10 do
            local set_num = tostring(i)
            settings[set_num] = {
                memo = "free memo " .. i
            }
            for _, status_info in ipairs(always_status_master_list) do
                local key = status_info.key
                settings[set_num][key] = status_info.on or 0
            end
        end
    end
    g.always_status_settings = settings
    if not g.always_status_settings["chars"] then
        g.always_status_settings["chars"] = {}
    end
    if not g.always_status_settings["chars"][g.cid] then
        g.always_status_settings["chars"][g.cid] = {
            use_set = 1,
            on = 1
        }
    end
    always_status_save_settings()
end

function always_status_on_init()
    if g.settings.always_status.use == 0 then
        local always_status = ui.GetFrame(addon_name_lower .. "always_status")
        if always_status then
            ui.DestroyFrame(always_status:GetName())
        end
        local settings_frame = ui.GetFrame(addon_name_lower .. "always_status_settings")
        if settings_frame then
            ui.DestroyFrame(settings_frame:GetName())
        end
        return
    end
    if not g.always_status_settings then
        always_status_load_settings()
    elseif g.always_status_settings["chars"] and not g.always_status_settings["chars"][g.cid] then
        always_status_load_settings()
    end
    always_status_original_frame_reduction()
    always_status_frame_init()
    g.setup_hook_and_event(g.addon, "STATUS_ONLOAD", "always_status_STATUS_ONLOAD", true)
end

function always_status_original_frame_reduction()
    local status = ui.GetFrame("status")
    status:Resize(0, 0)
    status:ShowWindow(1)
    status:SetVisible(1)
    STATUS_INFO()
end

function always_status_STATUS_ONLOAD(my_frame, my_msg)
    local status = ui.GetFrame("status")
    status:Resize(500, 1080)
end

function always_status_frame_init()
    local always_status = ui.CreateNewFrame("notice_on_pc", addon_name_lower .. "always_status", 0, 0, 70, 30)
    AUTO_CAST(always_status)
    local base = g.always_status_settings["base"]
    always_status:RemoveAllChild()
    always_status:EnableHittestFrame(base.enable)
    always_status:EnableMove(base.enable)
    local map_frame = ui.GetFrame("map")
    local width = map_frame:GetWidth()
    if base.frame_X > 1920 and width <= 1920 then
        base.frame_X = 1600
        base.frame_Y = 500
    end
    always_status:SetPos(base.frame_X, base.frame_Y)
    always_status:SetTitleBarSkin("None")
    always_status:SetSkinName("None")
    always_status:SetLayerLevel(11)
    always_status:SetEventScript(ui.LBUTTONUP, "always_status_frame_move")
    always_status:SetEventScript(ui.RBUTTONDOWN, "always_status_info_setting")
    local as_text = always_status:CreateOrGetControl("richtext", "as_text", 20, 5)
    AUTO_CAST(as_text)
    as_text:SetText("{ol}{S10}Always Status")
    as_text:SetEventScript(ui.RBUTTONDOWN, "always_status_info_setting")
    local tooltip = g.lang == "Japanese" and "{ol}右クリックで表示設定" or "{ol}Right-click to set display"
    as_text:SetTextTooltip(tooltip)
    local char = g.always_status_settings["chars"][g.cid]
    tooltip = g.lang == "Japanese" and "{ol}キャラクター毎に表示非表示を切り替えます" or
                  "{ol}Display and hide for each character"
    if char.on ~= 1 then
        local plus_pic = always_status:CreateOrGetControl("picture", "plus_pic", 0, 3, 15, 15)
        AUTO_CAST(plus_pic)
        plus_pic:SetEventScript(ui.LBUTTONUP, "always_status_frame_toggle")
        plus_pic:SetImage("btn_plus")
        plus_pic:SetTextTooltip(tooltip)
        plus_pic:SetEnableStretch(1)
        always_status:Resize(150, 20)
        always_status:ShowWindow(1)
        return
    else
        local minus_pic = always_status:CreateOrGetControl("picture", "minus_pic", 0, 3, 15, 15)
        AUTO_CAST(minus_pic)
        minus_pic:SetEventScript(ui.LBUTTONUP, "always_status_frame_toggle")
        minus_pic:SetImage("btn_minus")
        minus_pic:SetTextTooltip(tooltip)
        minus_pic:SetEnableStretch(1)
        local y = 20
        local pc = GetMyPCObject()
        local statframe = ui.GetFrame("status")
        local box = GET_CHILD_RECURSIVELY(statframe, "internalstatusBox")
        local use_set_str = tostring(char.use_set)
        for _, data in ipairs(always_status_master_list) do
            local status = data.key
            local display = g.always_status_settings[use_set_str]
            if display and display[status] == 1 then
                local color = g.always_status_settings["base"]["color"][status]
                local title = always_status:CreateOrGetControl("richtext", "title" .. status, 10, y)
                AUTO_CAST(title)
                local stat = always_status:CreateOrGetControl("richtext", "stat" .. status, 165, y)
                AUTO_CAST(stat)
                if status == "STR" or status == "INT" or status == "CON" or status == "MNA" or status == "DEX" then
                    for i = 0, 4 do
                        local type_str = GetStatTypeStr(i)
                        if status == type_str then
                            title:SetText("{ol}{s16}" .. color .. ClMsg(status))
                            local total_value = pc[type_str] + session.GetUserConfig(type_str .. "_UP")
                            local stat_text = string.gsub(tostring(total_value), ",", "")
                            stat:SetText(color .. "{ol}{s16}: " .. stat_text)
                            if g.lang == "Japanese" then
                                stat:SetPos(125, y)
                            end
                            break
                        end
                    end
                    y = y + 20
                else
                    local control_set = GET_CHILD_RECURSIVELY(box, status)
                    if control_set then
                        local original_status = GET_CHILD_RECURSIVELY(control_set, "stat")
                        if status == "gear_score" then
                            title:SetText("{ol}{s16}" .. color .. ScpArgMsg("EquipedItemGearScore"))
                            local text = string.gsub(original_status:GetText(), "{@sti8}", "")
                            text = string.gsub(text, ",", "")
                            stat:SetText(color .. "{ol}{s16}: " .. text)
                        elseif status == "ability_point_score" then
                            title:SetText("{ol}{s16}" .. color .. ScpArgMsg("AbilityPointScore"))
                            local text = string.gsub(original_status:GetText(), "{@sti8}", "")
                            text = string.gsub(text, ",", "")
                            stat:SetText(color .. "{ol}{s16}: " .. text)
                        else
                            title:SetText("{ol}{s16}" .. color .. ScpArgMsg(status))
                            local text = string.gsub(original_status:GetText(), "{#ff4040}", "")
                            text = string.gsub(text, "{#66b3ff}", "")
                            text = string.gsub(text, ",", "")
                            if text == "" then
                                text = "0"
                            end
                            stat:SetText(color .. "{ol}{s16}: " .. text)
                        end
                        if g.lang == "Japanese" then
                            local text = string.gsub(title:GetText(), "{.-}", "")
                            local jp_name = data.jp or text
                            title:SetText("{ol}{s16}" .. color .. jp_name)
                            stat:SetPos(125, y)
                        end
                        title:AdjustFontSizeByWidth(150)
                        if g.lang ~= "Japanese" then
                            stat:AdjustFontSizeByWidth(135)
                        end
                        y = y + 20
                    end
                end
            end
        end
        if g.lang == "Japanese" then
            always_status:Resize(260, y + 10)
        else
            always_status:Resize(310, y + 10)
        end
        always_status:ShowWindow(1)
        always_status:RunUpdateScript("always_status_update", 0.1)
    end
end

function always_status_update(always_status)
    local status = ui.GetFrame("status")
    local box = GET_CHILD_RECURSIVELY(status, "internalstatusBox")
    local pc = GetMyPCObject()
    for _, data in ipairs(always_status_master_list) do
        local status = data.key
        local always_status_stat = GET_CHILD_RECURSIVELY(always_status, "stat" .. status)
        if always_status_stat then
            local control_set = GET_CHILD_RECURSIVELY(box, status)
            local color = g.always_status_settings["base"]["color"][status]
            if not control_set then
                if status == "STR" or status == "INT" or status == "CON" or status == "MNA" or status == "DEX" then
                    local total_value = pc[status] + session.GetUserConfig(status .. "_UP")
                    always_status_stat:SetText(color .. "{ol}{s16}: " .. total_value)
                end
            else
                local original_status = GET_CHILD_RECURSIVELY(control_set, "stat")
                if original_status then
                    if status == "gear_score" then
                        local score = GET_PLAYER_GEAR_SCORE(pc)
                        always_status_stat:SetText(color .. "{ol}{s16}: " .. score)
                    else
                        local text = original_status:GetText()
                        text = text:gsub("{.-}", ""):gsub(",", "")
                        if text == "" then
                            text = "0"
                        end
                        always_status_stat:SetText(color .. "{ol}{s16}: " .. text)
                    end
                end
            end
        end
    end
    return 1
end

function always_status_frame_move(always_status)
    g.always_status_settings["base"].frame_X = always_status:GetX()
    g.always_status_settings["base"].frame_Y = always_status:GetY()
    always_status_save_settings()
end

function always_status_info_setting()
    local settings_frame = ui.CreateNewFrame("notice_on_pc", addon_name_lower .. "always_status_settings", 0, 0, 70, 30)
    AUTO_CAST(settings_frame)
    settings_frame:EnableHittestFrame(1)
    settings_frame:EnableHitTest(1)
    settings_frame:Resize(555, 900)
    settings_frame:SetPos(510, 10)
    settings_frame:RemoveAllChild()
    local gb = settings_frame:CreateOrGetControl("groupbox", "gb", 10, 10, settings_frame:GetWidth() - 10,
        settings_frame:GetHeight() - 10)
    AUTO_CAST(gb)
    gb:SetSkinName("test_frame_low")
    local title = gb:CreateOrGetControl("richtext", "title", 30, 40)
    AUTO_CAST(title)
    local text = g.lang == "Japanese" and "{ol}表示設定" or "{ol}Display Setting"
    title:SetText("{s18}{ol}{#FFFFFF}" .. text)
    local close = gb:CreateOrGetControl("button", "close", 0, 0, 20, 20)
    AUTO_CAST(close)
    close:SetImage("testclose_button")
    close:SetGravity(ui.RIGHT, ui.TOP)
    close:SetEventScript(ui.LBUTTONUP, "always_status_frame_close")
    local drop_list = gb:CreateOrGetControl('droplist', 'setting_DropList', 165, 10, 200, 20)
    AUTO_CAST(drop_list)
    drop_list:SetSkinName('droplist_normal')
    drop_list:EnableHitTest(1)
    drop_list:SetTextAlign("center", "center")
    for i = 1, 10 do
        local display = g.always_status_settings[tostring(i)]
        local scp = "always_status_info_setting_load(" .. i .. ")"
        if display.memo == "free memo " .. i then
            drop_list:AddItem(i - 1, tostring("Data ") .. i, 0, scp)
        else
            drop_list:AddItem(i - 1, display.memo, 0, scp)
        end
    end
    local use_set = tonumber(g.always_status_settings["chars"][g.cid].use_set)
    drop_list:SelectItem(use_set - 1)
    local memo = gb:CreateOrGetControl('edit', 'memo', 215, 35, 200, 30)
    AUTO_CAST(memo)
    memo:SetEventScript(ui.ENTERKEY, "always_status_memo_save")
    memo:SetEventScriptArgNumber(ui.ENTERKEY, use_set)
    memo:SetFontName("white_16_ol")
    memo:SetTextAlign("center", "center")
    local enable_check = gb:CreateOrGetControl("checkbox", "enablecheck", 510, 40, 20, 20)
    AUTO_CAST(enable_check)
    enable_check:SetEventScript(ui.LBUTTONUP, "always_status_checkbox")
    text = g.lang == "Japanese" and "{ol}チェックするとフレームが固定されます" or
               "{ol}If checked, the frame is fixed"
    enable_check:SetTextTooltip(text)
    local base = g.always_status_settings["base"]
    if base.enable == 0 then
        enable_check:SetCheck(1)
    else
        enable_check:SetCheck(0)
    end
    settings_frame:ShowWindow(1)
    always_status_info_setting_load(use_set)
end

function always_status_info_setting_load(use_set)
    local settings_frame = ui.GetFrame(addon_name_lower .. "always_status_settings")
    local gb = GET_CHILD_RECURSIVELY(settings_frame, "gb")
    AUTO_CAST(gb)
    local setting_gb = gb:CreateOrGetControl("groupbox", "setting_gb", 10, 70, gb:GetWidth() - 20, gb:GetHeight() - 80)
    AUTO_CAST(setting_gb)
    setting_gb:SetSkinName("test_frame_midle_light")
    local display = g.always_status_settings[tostring(use_set)]
    local memo = GET_CHILD_RECURSIVELY(settings_frame, "memo")
    AUTO_CAST(memo)
    memo:SetText(display.memo)
    settings_frame:SetLayerLevel(150)
    local y = 10
    for _, data in ipairs(always_status_master_list) do
        local status = data.key
        local check = setting_gb:CreateOrGetControl("checkbox", "check" .. status, 470, y, 20, 20)
        AUTO_CAST(check)
        check:SetEventScript(ui.LBUTTONUP, "always_status_checkbox")
        check:SetEventScriptArgString(ui.LBUTTONUP, status)
        check:SetEventScriptArgNumber(ui.LBUTTONUP, use_set)
        check:SetCheck(display[status])
        local color_box = setting_gb:CreateOrGetControl('groupbox', "colorbox" .. status, 255, y, 200, 20)
        AUTO_CAST(color_box)
        local color_table = {"FFFFFF", "FF6600", "FF4040", '66B3FF', '00FF00', 'FF0000', 'FF00FF', 'FFFF00', "ADFF2F",
                             "00FFFF"}
        for j = 1, 10 do
            local color_str = color_table[j]
            local color_pic = color_box:CreateOrGetControl("picture", "color" .. j, 20 * j, 0, 20, 20)
            AUTO_CAST(color_pic)
            color_pic:SetImage("chat_color")
            color_pic:SetColorTone("FF" .. color_str)
            color_pic:SetEventScript(ui.LBUTTONUP, "always_status_color_select")
            color_pic:SetEventScriptArgString(ui.LBUTTONUP, color_str)
        end
        local control = setting_gb:CreateOrGetControl("richtext", status, 20, y)
        AUTO_CAST(control)
        local color = g.always_status_settings["base"]["color"][status]
        if status == "STR" or status == "INT" or status == "CON" or status == "MNA" or status == "DEX" then
            control:SetText(color .. "{s16}{ol}" .. ClMsg(status))
        elseif status == "gear_score" then
            control:SetText(color .. "{s16}{ol}" .. ScpArgMsg("EquipedItemGearScore"))
        elseif status == "ability_point_score" then
            control:SetText(color .. "{s16}{ol}" .. ScpArgMsg("AbilityPointScore"))
        else
            control:SetText(color .. "{s16}{ol}" .. ScpArgMsg(status))
        end
        control:AdjustFontSizeByWidth(250)
        y = y + 25
    end
    g.always_status_settings["chars"][g.cid].use_set = use_set
    always_status_save_settings()
    always_status_frame_init()
end

function always_status_frame_toggle(frame, ctrl)
    if g.always_status_settings["chars"][g.cid].on == 1 then
        g.always_status_settings["chars"][g.cid].on = 0
    else
        g.always_status_settings["chars"][g.cid].on = 1
    end
    always_status_save_settings()
    always_status_frame_init()
end

function always_status_frame_close()
    local settings_frame = ui.GetFrame(addon_name_lower .. "always_status_settings")
    if settings_frame then
        ui.DestroyFrame(settings_frame:GetName())
    end
end

function always_status_memo_save(frame, ctrl, str, use_set)
    local text = ctrl:GetText()
    g.always_status_settings[tostring(use_set)].memo = text
    ui.SysMsg(g.lang == "Japanese" and "タイトルを変更しました" or "The title has been changed")
    always_status_save_settings()
    always_status_info_setting()
end

function always_status_checkbox(frame, ctrl, status, use_set)
    local is_check = ctrl:IsChecked()
    local name = ctrl:GetName()
    if name == "enablecheck" then
        local always_status = ui.GetFrame(addon_name_lower .. "always_status")
        if is_check == 1 then
            g.always_status_settings["base"].enable = 0
            always_status:EnableMove(0)
        else
            g.always_status_settings["base"].enable = 1
            always_status:EnableMove(1)
        end
    else
        g.always_status_settings[tostring(use_set)][status] = is_check
    end
    always_status_save_settings()
    always_status_frame_init()
    -- always_status_info_setting_load(use_set)
end

function always_status_color_select(parent, ctrl, color_str, num)
    local status_name = string.gsub(parent:GetName(), "colorbox", "")
    g.always_status_settings["base"]["color"][status_name] = "{#" .. color_str .. "}"
    always_status_save_settings()
    always_status_info_setting()
    always_status_frame_init()
end
-- always_status ここまで

-- Boss Gauge ここから
function boss_gauge_on_init()
    g.addon:RegisterMsg('TARGET_BUFF_UPDATE', 'boss_gauge_TARGETINFOTOBOSS_ON_MSG')
    g.addon:RegisterMsg('TARGET_UPDATE', 'boss_gauge_TARGETINFOTOBOSS_ON_MSG')
    g.addon:RegisterMsg("TARGET_SET_BOSS", "boss_gauge_TARGETINFOTOBOSS_ON_MSG")
    g.setup_hook_and_event(g.addon, "TARGETINFOTOBOSS_UPDATE_SHIELD", "boss_gauge_TARGETINFOTOBOSS_UPDATE_SHIELD", true)
end

function boss_gauge_frame_position()
    local targetinfotoboss = ui.GetFrame("targetinfotoboss")
    local name = GET_CHILD_RECURSIVELY(targetinfotoboss, "name")
    AUTO_CAST(name)
    if name then
        local x = name:GetX()
        local width = name:GetWidth()
        if width > 190 then
            width = 190
        end
        local height = name:GetHeight()
        return targetinfotoboss, x, width, height
    end
end

function boss_gauge_TARGETINFOTOBOSS_ON_MSG(frame, msg)
    if g.settings.boss_gauge.use == 0 then
        return
    end
    local stat = info.GetStat(session.GetTargetBossHandle())
    if stat then
        local cur_faint = stat.cur_faint
        local max_faint = stat.max_faint
        local targetinfotoboss, x, width, height = boss_gauge_frame_position()
        if cur_faint and max_faint and cur_faint >= 0 and max_faint > 0 then
            local faint = GET_CHILD_RECURSIVELY(targetinfotoboss, "faint")
            if faint then
                AUTO_CAST(faint)
                local diff_faint = max_faint - cur_faint
                if diff_faint < 0 then
                    diff_faint = 0
                end
                local stun = targetinfotoboss:CreateOrGetControl("richtext", "stun", x + width + 35, 66, 120, height)
                AUTO_CAST(stun)
                local stun_text = "STUN:" .. string.format("(%.2f%%)", (diff_faint / max_faint) * 100)
                stun:SetText(stun_text)
                stun:SetFontName("yellow_16_ol")
                local name = GET_CHILD_RECURSIVELY(targetinfotoboss, "name")
                AUTO_CAST(name)
                name:AdjustFontSizeByWidth(220)
            end
        end
        local shield = GET_CHILD_RECURSIVELY(targetinfotoboss, "shield", "ui::CGauge")
        if shield:IsVisible() == 0 then
            local shield_text = GET_CHILD_RECURSIVELY(targetinfotoboss, "shield_text")
            AUTO_CAST(shield_text)
            shield_text:ShowWindow(0)
        end
    end
end

function boss_gauge_TARGETINFOTOBOSS_UPDATE_SHIELD(my_frame, my_msg)
    if g.settings.boss_gauge.use == 0 then
        return
    end
    local data = g.get_event_args(my_msg)
    local data_list = StringSplit(data, '/')
    if #data_list > 0 then
        local shield = data_list[1]
        if shield then
            local shield_num = tonumber(data_list[1])
            local max_hp = tonumber(data_list[2])
            if shield_num and max_hp and max_hp > 0 then
                local targetinfotoboss, x, width, height = boss_gauge_frame_position()
                local shield_text = targetinfotoboss:CreateOrGetControl("richtext", "shield_text", x + width + 165, 66,
                    120, height)
                AUTO_CAST(shield_text)
                local text = "SHIELD:" .. string.format("(%.2f%%)", (shield_num / max_hp) * 100)
                shield_text:SetText(text)
                shield_text:SetFontName("yellow_16_ol")
            end
        end
    end
end
-- Boss Gauge ここまで

-- Party Marker　ここから
function party_marker_on_init()
    local all_in_one = ui.GetFrame("all_in_one")
    if all_in_one then
        all_in_one:SetVisible(1)
        local party_marker_timer = all_in_one:CreateOrGetControl("timer", "party_marker_timer", 0, 0)
        AUTO_CAST(party_marker_timer)
        party_marker_timer:SetUpdateScript("party_marker_set")
        party_marker_timer:Start(0.5)
    end
end

function party_marker_cleanup()
    if g.party_marker and next(g.party_marker) then
        for handle_str, _ in pairs(g.party_marker) do
            local party_marker = ui.GetFrame("party_marker" .. handle_str)
            if party_marker then
                ui.DestroyFrame(party_marker:GetName())
            end
        end
        g.party_marker = {}
    end
end

function party_marker_set(all_in_one, party_marker_timer)
    if g.settings.party_marker.use == 0 then
        party_marker_cleanup()
        return
    end
    local party_list = session.party.GetPartyMemberList(PARTY_NORMAL)
    -- テスト用ギルドメンバー
    -- local party_list = session.party.GetPartyMemberList(PARTY_GUILD)
    if not party_list or party_list:Count() <= 1 then
        party_marker_cleanup()
        return
    end
    local current_party = {}
    for i = 0, party_list:Count() - 1 do
        local member = party_list:Element(i)
        if member then
            local handle = member:GetHandle()
            if handle ~= 0 then
                current_party[tostring(handle)] = handle
            end
        end
    end
    g.party_marker = {}
    local list, count = SelectObject(GetMyPCObject(), 1000, 'ALL')
    for i = 1, count do
        if list[i] then
            local handle = GetHandle(list[i])
            if info.IsPC(handle) == 1 then
                local handle_str = tostring(handle)
                if current_party[handle_str] then
                    g.party_marker[handle_str] = handle
                    local party_marker = ui.GetFrame("party_marker" .. handle_str)
                    if not party_marker then
                        party_marker = ui.CreateNewFrame("notice_on_pc", "party_marker" .. handle_str, 0, 0, 50, 50)
                        party_marker:SetSkinName("None")
                        party_marker:SetLayerLevel(80)
                        local pic = party_marker:CreateOrGetControl('picture', 'marker', 0, 0, 50, 50)
                        AUTO_CAST(pic)
                        pic:SetImage("friend_party")
                        pic:SetEnableStretch(1)
                    end
                    FRAME_AUTO_POS_TO_OBJ(party_marker, handle, 25, -70, 3, 1, 1)
                    party_marker:ShowWindow(1)
                end
            end
        end
    end
    for handle_str, _ in pairs(current_party) do
        if not g.party_marker[handle_str] then
            local party_marker = ui.GetFrame("party_marker" .. handle_str)
            if party_marker then
                ui.DestroyFrame(party_marker:GetName())
            end
        end
    end
end
-- Party Marker　ここまで

-- Aethergem Manager　ここから
g.aethergem_manager_path = string.format("../addons/%s/%s/aethergem_manager.json", addon_name_lower, g.active_id)
g.aethergem_manager_old_path = string.format("../addons/%s/%s.json", "aethergem_mgr", g.active_id)
function aethergem_manager_load_settings()
    local changed = false
    local settings = g.load_json(g.aethergem_manager_path)
    if not settings then
        local old_settings = g.load_json(g.aethergem_manager_old_path)
        if old_settings then
            if old_settings then
                settings = {}
                for key, value in pairs(old_settings) do
                    if key ~= "delay" then
                        if tonumber(key) and string.len(key) < 3 then
                            if not settings.set then
                                settings.set = {}
                            end
                            settings.set[key] = value
                        else
                            if type(value) == "table" and value.use_index and type(value.use_index) == "string" then
                                value.use_index = value.use_index
                            end
                            settings[key] = value
                        end
                    end
                end
                changed = true
            end
        else
            settings = {
                set = {}
            }
            changed = true
        end
    end
    for i = 1, 6 do
        local i_str = tostring(i)
        if not settings.set[i_str] then
            settings.set[i_str] = {}
            changed = true
        end
        for j = 1, 4 do
            local j_str = tostring(j)
            if not settings.set[i_str][j_str] then
                settings.set[i_str][j_str] = 0
                changed = true
            end
        end
    end
    if not g.aethergem_manager then
        g.aethergem_manager = {}
    end
    g.aethergem_manager.settings = settings
    if changed then
        aethergem_manager_save_settings()
    end
end

function aethergem_manager_save_settings()
    g.save_json(g.aethergem_manager_path, g.aethergem_manager.settings)
end

function aethergem_manager_on_init()
    aethergem_manager_load_settings()
    aethergem_manager_frame_init()
end

function aethergem_manager_frame_init()
    local inventory = ui.GetFrame('inventory')
    local item_cls = GetClassByType('Item', 850006)
    local icon_img = GET_ITEM_ICON_IMAGE(item_cls, 'Icon')
    local btn_pic = inventory:CreateOrGetControl('picture', "btn_pic", 470, 345, 30, 30)
    AUTO_CAST(btn_pic)
    btn_pic:SetImage(icon_img)
    btn_pic:SetEnableStretch(1)
    btn_pic:Resize(30, 30)
    btn_pic:SetTextTooltip(g.lang == "Japanese" and "{ol}右クリック：設定{nl}左クリック：作動" or
                               "{ol}Aethegem Manager{nl}Right click:Setup{nl}Left click:activation")
    btn_pic:SetEventScript(ui.RBUTTONUP, "aethergem_manager_gem_setting")
    btn_pic:SetEventScript(ui.LBUTTONUP, "aethergem_manager_operation")
    if g.settings.aethergem_manager.use == 0 then
        btn_pic:ShowWindow(0)
    else
        btn_pic:ShowWindow(1)
    end
end

function aethergem_manager_gem_setting_close(setting_frame, close, str, num)
    ui.DestroyFrame(setting_frame:GetName())
end

function aethergem_manager_gem_setting_rbtn(slotset, slot, i_str, j)
    local j_str = tostring(j)
    g.aethergem_manager.settings.set[i_str][j_str] = 0
    aethergem_manager_save_settings()
    local inventory = ui.GetFrame('inventory')
    aethergem_manager_gem_setting(inventory)
end

function aethergem_manager_gem_setting_drop(slotset, slot, i_str, j)
    local lift_icon = ui.GetLiftIcon()
    local info = lift_icon:GetInfo()
    local clsid = info.type
    local item_cls = GetClassByType("Item", clsid)
    local name = item_cls.ClassName
    local j_str = tostring(j)
    local image = info:GetImageName()
    if string.find(image, "highcolorgem") then
        CreateIcon(slot)
        SET_SLOT_ITEM_CLS(slot, item_cls)
        local levels = {"520", "500", "480", "460"}
        local lv_text = slot:CreateOrGetControl('richtext', 'lv_text', 0, 25, 25, 25)
        AUTO_CAST(lv_text)
        for _, lv in ipairs(levels) do
            if string.find(name, lv) then
                lv_text:SetText("{ol}{s14}LV" .. lv)
                break
            end
        end
        g.aethergem_manager.settings.set[i_str][j_str] = clsid
        aethergem_manager_save_settings()
    end
end

function aethergem_manager_gem_setting_lbtn(gb, use_btn, i_str, num)
    if not next(g.aethergem_manager.settings.set[i_str]) then
        return
    end
    g.aethergem_manager.settings[g.cid].use_index = i_str
    aethergem_manager_save_settings()
    local inventory = ui.GetFrame('inventory')
    aethergem_manager_gem_setting(inventory)
end

function aethergem_manager_gem_setting(inventory, btn_pic, str, num)
    local setting_frame = ui.CreateNewFrame("chat_memberlist", "aethergem_manager_setting_frame", 0, 0, 0, 0)
    AUTO_CAST(setting_frame)
    -- 2560,1920
    setting_frame:SetSkinName("test_frame_low")
    local map_frame = ui.GetFrame("map")
    local map_width = map_frame:GetWidth()
    local x = map_width - inventory:GetWidth()
    setting_frame:Resize(300, 360)
    setting_frame:SetPos(x - setting_frame:GetWidth(), 500)
    setting_frame:SetLayerLevel(121)
    setting_frame:RemoveAllChild()
    local gb = setting_frame:CreateOrGetControl("groupbox", "gb", 10, 35, setting_frame:GetWidth() - 20,
        setting_frame:GetHeight() - 45)
    AUTO_CAST(gb)
    gb:SetSkinName("bg")
    local close = setting_frame:CreateOrGetControl('button', 'close', 0, 0, 20, 20)
    AUTO_CAST(close)
    close:SetImage("testclose_button")
    close:SetGravity(ui.RIGHT, ui.TOP)
    close:SetEventScript(ui.LBUTTONUP, "aethergem_manager_gem_setting_close")
    local title = setting_frame:CreateOrGetControl('richtext', 'title', 10, 10, 200, 30)
    AUTO_CAST(title)
    title:SetText("{ol}Aether Gem Setting")
    for i = 1, 6 do
        local slotset = gb:CreateOrGetControl('slotset', 'slotset' .. i, 85, 10 + (i - 1) * 50, 0, 0)
        AUTO_CAST(slotset)
        slotset:EnablePop(1)
        slotset:EnableDrag(1)
        slotset:EnableDrop(1)
        slotset:EnableHitTest(1)
        slotset:SetColRow(4, 1)
        slotset:SetSlotSize(45, 45)
        slotset:SetSpc(2, 2)
        slotset:SetSkinName('invenslot2')
        slotset:CreateSlots()
        local i_str = tostring(i)
        local slot_count = slotset:GetSlotCount()
        for j = 1, slot_count do
            local slot = GET_CHILD(slotset, "slot" .. j)
            AUTO_CAST(slot)
            slot:EnableDrop(1)
            local j_str = tostring(j)
            local clsid = g.aethergem_manager.settings.set[i_str][j_str]
            if clsid and clsid ~= 0 then
                local item_cls = GetClassByType("Item", clsid)
                if item_cls then
                    local name = item_cls.ClassName
                    CreateIcon(slot)
                    SET_SLOT_ITEM_CLS(slot, item_cls)
                    local levels = {"540", "520", "500", "480", "460"}
                    local skins = {"invenslot_pic_goddess", "invenslot_legend", "invenslot_unique", "invenslot_rare",
                                   "invenslot_nomal"}
                    local lv_text = slot:CreateOrGetControl('richtext', 'lv_text', 0, 25, 25, 25)
                    AUTO_CAST(lv_text)
                    for i, lv in ipairs(levels) do
                        if string.find(name, lv) then
                            lv_text:SetText("{ol}{s14}LV" .. lv)
                            slot:SetSkinName(skins[i])
                            break
                        end
                    end
                end
            end
            slot:SetEventScript(ui.RBUTTONUP, 'aethergem_manager_gem_setting_rbtn')
            slot:SetEventScriptArgString(ui.RBUTTONUP, i_str)
            slot:SetEventScriptArgNumber(ui.RBUTTONUP, j)
            slot:SetEventScript(ui.DROP, 'aethergem_manager_gem_setting_drop')
            slot:SetEventScriptArgString(ui.DROP, i_str)
            slot:SetEventScriptArgNumber(ui.DROP, j)
        end
        local use_btn = gb:CreateOrGetControl('button', "use_btn" .. i, 5, (i - 1) * 50 + 15, 75, 30)
        AUTO_CAST(use_btn)
        if not g.aethergem_manager.settings[g.cid] then
            g.aethergem_manager.settings[g.cid] = {
                use_index = "-1"
            }
        end
        if g.aethergem_manager.settings[g.cid].use_index == i_str then
            use_btn:SetSkinName("test_red_button")
            use_btn:SetText("{ol}use")
        else
            use_btn:SetSkinName("test_gray_button")
            use_btn:SetText("{ol}not use")
        end
        use_btn:SetEventScript(ui.LBUTTONUP, 'aethergem_manager_gem_setting_lbtn')
        use_btn:SetEventScriptArgString(ui.LBUTTONUP, i_str)
    end
    aethergem_manager_save_settings()
    INVENTORY_SET_CUSTOM_RBTNDOWN('aethergem_manager_INV_RBTN')
    setting_frame:ShowWindow(1)
end

function aethergem_manager_INV_RBTN(item_obj, slot, guid)
    for i = 1, 6 do
        local setting_frame = ui.GetFrame("aethergem_manager_setting_frame")
        local slotset = GET_CHILD_RECURSIVELY(setting_frame, 'slotset' .. i)
        AUTO_CAST(slotset)
        local i_str = tostring(i)
        local slot_count = slotset:GetSlotCount()
        for j = 1, slot_count do
            local slot = GET_CHILD(slotset, "slot" .. j)
            AUTO_CAST(slot)
            local j_str = tostring(j)
            local clsid = g.aethergem_manager.settings.set[i_str][j_str]
            if clsid == 0 then
                local gem_clsid = item_obj.ClassID
                local item_cls = GetClassByType("Item", gem_clsid)
                if item_cls then
                    local name = item_cls.ClassName
                    CreateIcon(slot)
                    SET_SLOT_ITEM_CLS(slot, item_cls)
                    local levels = {"540", "520", "500", "480", "460"}
                    local skins = {"invenslot_pic_goddess", "invenslot_legend", "invenslot_unique", "invenslot_rare",
                                   "invenslot_nomal"}
                    local lv_text = slot:CreateOrGetControl('richtext', 'lv_text', 0, 25, 25, 25)
                    AUTO_CAST(lv_text)
                    for i, lv in ipairs(levels) do
                        if string.find(name, lv) then
                            lv_text:SetText("{ol}{s14}LV" .. lv)
                            slot:SetSkinName(skins[i])
                            g.aethergem_manager.settings.set[i_str][j_str] = gem_clsid
                            aethergem_manager_save_settings()
                            return
                        end
                    end
                end
            end
        end
    end
end

function aethergem_manager_equip(btn_pic)
    local inventory = btn_pic:GetTopParentFrame()
    if inventory:IsVisible() == 0 then
        btn_pic:StopUpdateScript("aethergem_manager_equip")
    end
    local step = btn_pic:GetUserIValue("STEP")
    local goddess_equip_manager = ui.GetFrame("goddess_equip_manager")
    local spot_nums = {8, 9, 30}
    local equips = {"RH", "LH", "RH_SUB", "LH_SUB"}
    if step <= 3 then
        local guid = g.aethergem_manager.guids[equips[step]]
        local equip_item = session.GetEquipItemByGuid(guid)
        if step == 3 then
            DO_WEAPON_SLOT_CHANGE(inventory, 2)
        end
        if not equip_item then
            btn_pic:SetUserValue("STEP", step + 1)
        else
            item.UnEquip(spot_nums[step])
        end
        return 1
    end
    local msg = g.lang == "Japanese" and "エーテルジェムソケットが空いていません" or
                    "The Aether Gem socket is unavailable"
    if step >= 4 and step <= 7 then
        local guid = g.aethergem_manager.guids[equips[step - 3]]
        local gem_guid = g.aethergem_manager.gems[step - 3].iesid
        local inv_item = session.GetInvItemByGuid(guid)
        if inv_item then
            local item_obj = GetIES(inv_item:GetObject())
            local aether_available = item_goddess_socket.enable_aether_socket_add(item_obj)
            if aether_available == false then
                GODDESS_MGR_SOCKET_REG_ITEM(goddess_equip_manager, inv_item, item_obj)
            else
                GODDESS_EQUIP_MANAGER_CLOSE(goddess_equip_manager)
                ui.SysMsg(msg)
                return 0
            end
            local gem_item = session.GetInvItemByGuid(gem_guid)
            if gem_item then
                local gem_obj = GetIES(gem_item:GetObject())
                local ctrl_set = GET_CHILD_RECURSIVELY(goddess_equip_manager, 'AETHER_CSET_0')
                local gem_id = ctrl_set:GetUserIValue('GEM_ID')
                if gem_id == 0 then
                    local gem_slot = GET_CHILD(ctrl_set, 'gem_slot')
                    GODDESS_MGR_SOCKET_AETHER_GEM_EQUIP(ctrl_set, gem_slot, gem_item, gem_obj)
                end
                return 1
            else
                local spot_name = equips[step - 3]
                if step == 4 then
                    DO_WEAPON_SLOT_CHANGE(inventory, 1)
                elseif step == 6 then
                    DO_WEAPON_SLOT_CHANGE(inventory, 2)
                end
                ITEM_EQUIP(inv_item.invIndex, spot_name)
                return 1
            end
        else
            btn_pic:SetUserValue("STEP", step + 1)
            return 1
        end
    end
    aethergem_manager_end_operation(goddess_equip_manager, inventory)
    return 0
end

function aethergem_manager_unequip(btn_pic)
    local inventory = btn_pic:GetTopParentFrame()
    if inventory:IsVisible() == 0 then
        btn_pic:StopUpdateScript("aethergem_manager_unequip")
    end
    local step = btn_pic:GetUserIValue("STEP")
    local goddess_equip_manager = ui.GetFrame("goddess_equip_manager")
    local spot_nums = {8, 9, 30}
    local equips = {"RH", "LH", "RH_SUB", "LH_SUB"}
    if step <= 3 then
        local guid = g.aethergem_manager.guids[equips[step]]
        local equip_item = session.GetEquipItemByGuid(guid)
        if step == 3 then
            DO_WEAPON_SLOT_CHANGE(inventory, 2)
        end
        if not equip_item then
            btn_pic:SetUserValue("STEP", step + 1)
        else
            item.UnEquip(spot_nums[step])
        end
        return 1
    end
    if step >= 4 and step <= 7 then
        local gem_index = 2 -- エーテルジェムは2
        local guid = g.aethergem_manager.guids[equips[step - 3]]
        local inv_item = session.GetInvItemByGuid(guid)
        if inv_item then
            local item_obj = GetIES(inv_item:GetObject())
            GODDESS_MGR_SOCKET_REG_ITEM(goddess_equip_manager, inv_item, item_obj)
            local gem_id = inv_item:GetEquipGemID(gem_index)
            if not gem_id or gem_id ~= 0 then
                _GODDESS_MGR_SOCKET_REQ_GEM_REMOVE(gem_index)
            else
                local spot_name = equips[step - 3]
                if step == 4 then
                    DO_WEAPON_SLOT_CHANGE(inventory, 1)
                elseif step == 6 then
                    DO_WEAPON_SLOT_CHANGE(inventory, 2)
                end
                ITEM_EQUIP(inv_item.invIndex, spot_name)
            end
            return 1
        else
            btn_pic:SetUserValue("STEP", step + 1)
        end
        return 1
    end
    aethergem_manager_end_operation(goddess_equip_manager, inventory)
    return 0
end

function aethergem_manager_operation_start(is_equip, btn_pic)
    local goddess_equip_manager = ui.GetFrame("goddess_equip_manager")
    if goddess_equip_manager:IsVisible() == 0 then
        help.RequestAddHelp('TUTO_GODDESSEQUIP_1')
        goddess_equip_manager:ShowWindow(1)
        local main_tab = GET_CHILD_RECURSIVELY(goddess_equip_manager, 'main_tab')
        main_tab:SelectTab(2)
        GODDESS_MGR_SOCKET_OPEN(goddess_equip_manager)
        GODDESS_EQUIP_UI_TUTORIAL_CHECK(goddess_equip_manager)
    end
    item.UnEquip(8)
    btn_pic:SetUserValue("STEP", 1)
    if is_equip then
        btn_pic:RunUpdateScript("aethergem_manager_equip", 0.1)
    else
        btn_pic:RunUpdateScript("aethergem_manager_unequip", 0.1)
    end
end

function aethergem_manager_end_operation(goddess_equip_manager, inventory)
    DO_WEAPON_SLOT_CHANGE(inventory, 1)
    GODDESS_MGR_SOCKET_CLEAR(goddess_equip_manager)
    goddess_equip_manager:ShowWindow(0)
    ui.SysMsg("[AGM]End of Operation")
end

function aethergem_manager_operation(inventory, btn_pic)
    local setting_frame = ui.GetFrame("aethergem_manager_setting_frame")
    if setting_frame then
        aethergem_manager_gem_setting_close(setting_frame)
    end
    if TUTORIAL_CLEAR_CHECK(GetMyPCObject()) == false then
        ui.SysMsg(ClMsg('CanUseAfterTutorialClear'))
        return
    end
    g.aethergem_manager.guids = {}
    local equips = {"RH", "LH", "RH_SUB", "LH_SUB"}
    local count = 0
    local is_equip = true
    for _, slot_name in ipairs(equips) do
        local equip_slot = GET_CHILD_RECURSIVELY(inventory, slot_name)
        local icon = equip_slot:GetIcon()
        if icon then
            local icon_info = icon:GetInfo()
            local guid = icon_info:GetIESID()
            local equip_item = session.GetEquipItemByGuid(guid)
            local available = equip_item:IsAvailableSocket(2)
            if available then
                count = count + 1
                local gem_id = equip_item:GetEquipGemID(2)
                if gem_id ~= 0 then
                    is_equip = false
                end
                g.aethergem_manager.guids[slot_name] = guid
            end
        end
    end
    if count < 4 then
        ui.SysMsg(g.lang == "Japanese" and
                      "エーテルジェムソケットが開いた武器を4ケ所装備して使用してください" or
                      "Please equip 4 weapons with open Aether Gem sockets and use the feature")
        return
    end
    if is_equip then
        g.aethergem_manager.gems = {}
        local use_index = g.aethergem_manager.settings[g.cid].use_index
        session.ResetItemList()
        local inv_list = session.GetInvItemList()
        local inv_guid_list = inv_list:GetGuidList()
        local cnt = inv_guid_list:Count()
        local gem_count = 0
        for i = 0, cnt - 1 do
            local guid = inv_guid_list:Get(i)
            local inv_item = inv_list:GetItemByGuid(guid)
            local inv_obj = GetIES(inv_item:GetObject())
            local inv_clsid = inv_obj.ClassID
            for index, clsid in pairs(g.aethergem_manager.settings.set[use_index]) do
                if clsid == inv_clsid then
                    local level = get_current_aether_gem_level(inv_obj)
                    table.insert(g.aethergem_manager.gems, {
                        level = level,
                        iesid = guid,
                        clsid = clsid
                    })
                    gem_count = gem_count + 1
                    break
                end
            end
        end
        if gem_count < 4 then
            ui.SysMsg(g.lang == "Japanese" and "インベントリにエーテルジェムが4個ありません" or
                          "There are not 4 Aether Gem in the inventory")
            return
        end
        table.sort(g.aethergem_manager.gems, function(a, b)
            return a.level > b.level
        end)
        aethergem_manager_operation_start(is_equip, btn_pic)
    else
        aethergem_manager_operation_start(is_equip, btn_pic)
    end
end
-- Aethergem Manager　ここまで

-- Job Change Helper ここから
function job_change_helper_on_init()
    if g.get_map_type() == "City" then
        job_change_helper_frame_init()
    end
end

function job_change_helper_frame_init()
    if g.settings.job_change_helper.use == 0 then
        local inventory = ui.GetFrame('inventory')
        local toggle = GET_CHILD(inventory, "job_change_helper_toggle")
        if toggle then
            DESTROY_CHILD_BYNAME(inventory, "job_change_helper_toggle")
        end
        local changejob = ui.GetFrame("changejob")
        local jobTreeBox = GET_CHILD_RECURSIVELY(changejob, "jobTreeBox")
        local job_change = GET_CHILD(jobTreeBox, "job_change_helper_job_change")
        if job_change then
            DESTROY_CHILD_BYNAME(jobTreeBox, "job_change_helper_job_change")
        end
        return
    end
    local inventory = ui.GetFrame('inventory')
    DO_WEAPON_SLOT_CHANGE(inventory, 1)
    local toggle = inventory:CreateOrGetControl("button", "job_change_helper_toggle", 388, 345, 25, 30)
    AUTO_CAST(toggle)
    if not g.job_change_helper_mode then
        toggle:SetSkinName("test_red_button")
        toggle:Resize(30, 30)
        toggle:SetPos(388, 345)
        toggle:SetText("{img equipment_info_btn_mark2 30 25}")
        toggle:SetEventScript(ui.LBUTTONUP, "job_change_helper_unequip")
        toggle:SetTextTooltip(g.lang == "Japanese" and "{ol}装備を全部外します" or "{ol}Remove all equipment")
    else
        toggle:SetSkinName("baseyellow_btn")
        toggle:Resize(35, 35)
        toggle:SetPos(388, 342)
        toggle:SetText("{ol}{img equipment_info_btn_mark2 30 25}")
        toggle:SetEventScript(ui.LBUTTONUP, "job_change_helper_equip")
        toggle:SetEventScript(ui.RBUTTONUP, "job_change_helper_modechange")
        toggle:SetTextTooltip(g.lang == "Japanese" and
                                  "{ol}直前に脱いだ装備を全部着けます。{nl}右クリックでモードを強制クリア" or
                                  "{ol}Equip all gear that was just unequipped{nl}Right-click to force-clear the mode")
    end
    local changejob = ui.GetFrame("changejob")
    if changejob then
        local jobTreeBox = GET_CHILD_RECURSIVELY(changejob, "jobTreeBox")
        AUTO_CAST(jobTreeBox)
        local job_change = jobTreeBox:CreateOrGetControl("button", "job_change_helper_job_change", 70, 110, 226, 78)
        AUTO_CAST(job_change)
        job_change:SetPos(70, 110)
        job_change:SetSkinName("None")
        job_change:SetImage("btn_lv3")
        job_change:SetText("{ol}Job Change Helper")
        job_change:EnableHitTest(1)
        job_change:SetAnimation('MouseOnAnim', 'btn_mouseover')
        job_change:SetAnimation('MouseOffAnim', 'btn_mouseoff')
        job_change:SetEventScript(ui.LBUTTONDOWN, "OUT_PARTY")
        job_change:SetEventScript(ui.LBUTTONUP, "job_change_helper_unequip")
    end
end

function job_change_helper_modechange()
    g.job_change_helper_mode = false
    job_change_helper_frame_init()
end

function job_change_helper_unequip(frame, ctrl)
    local equip_list = {}
    local need_run = false
    local equip_item_list = session.GetEquipItemList()
    local cnt = equip_item_list:Count()
    for i = 0, cnt - 1 do
        local equip_item = equip_item_list:GetEquipItemByIndex(i)
        local spot_name = item.GetEquipSpotName(equip_item.equipSpot)
        local iesid = tostring(equip_item:GetIESID())
        local cls_id = equip_item.type
        if iesid ~= "0" then
            equip_list[spot_name] = {
                iesid = iesid,
                cls_id = cls_id,
                index = i
            }
            if spot_name == "HELMET" then
                need_run = true
            elseif spot_name == "CORE" then
                need_run = true
            end
        end
    end
    session.job.ReqUnEquipItemAll()
    g.job_change_helper_sorted_equip_list = {}
    for spot_name, data in pairs(equip_list) do
        data.spot_name = spot_name
        table.insert(g.job_change_helper_sorted_equip_list, data)
    end
    table.sort(g.job_change_helper_sorted_equip_list, function(a, b)
        return a.index < b.index
    end)
    if need_run then
        ctrl:RunUpdateScript("job_change_helper_unequip_", 0.2)
    else
        local changejob = ui.GetFrame("changejob")
        if changejob and changejob:IsVisible() == 1 then
            ctrl:RunUpdateScript("job_change_helper_post_unequip", 0.3)
        else
            job_change_helper_end("unequip")
        end
    end
end

function job_change_helper_unequip_(ctrl)
    local equip_item_list = session.GetEquipItemList()
    local pc = GetMyPCObject()
    for _, equip_data in ipairs(g.job_change_helper_sorted_equip_list) do
        local spot_name = equip_data.spot_name
        local iesid = equip_data.iesid
        if spot_name == "HELMET" or spot_name == "CORE" then

            local inv_item = session.GetInvItemByGuid(iesid)
            if not inv_item then
                local current_equip = equip_item_list:GetEquipItem(pc, spot_name)
                if current_equip then
                    local index = equip_data.index
                    item.UnEquip(index)
                    return 1
                end
            end
        end
    end
    local changejob = ui.GetFrame("changejob")
    if changejob and changejob:IsVisible() == 1 then
        ctrl:RunUpdateScript("job_change_helper_post_unequip", 0.3)
    else
        job_change_helper_end("unequip")
    end
    return 0
end

function job_change_helper_post_unequip(ctrl)
    local changejob = ui.GetFrame("changejob")
    if changejob and changejob:IsVisible() == 1 then
        local pet = GET_SUMMONED_PET()
        if pet then
            control.SummonPet(0, 0, 0)
            return 1
        end
        local hawk = GET_SUMMONED_PET_HAWK()
        if hawk then
            ui.SysMsg(g.lang == "Japanese" and "鷹を連れているのでバラックへ戻ります" or
                          "Will return to the barracks due to the hawk")
            GAME_TO_BARRACK()
            return 0
        end
        local multiple_class_change = ui.GetFrame("multiple_class_change")
        MULTIPLE_CLASS_CHANGE_OPEN(multiple_class_change)
        multiple_class_change:ShowWindow(1)
    end
    job_change_helper_end("unequip")
    return 0
end

function job_change_helper_equip(inventory, ctrl)
    inventory:RunUpdateScript("job_change_helper_equip_", 0.3)
end

function job_change_helper_equip_(inventory)
    if #g.job_change_helper_sorted_equip_list > 0 then
        for i, equip_data in ipairs(g.job_change_helper_sorted_equip_list) do
            local spot_name = equip_data.spot_name
            local iesid = equip_data.iesid
            local cls_id = equip_data.cls_id
            local ret = CHECK_EQUIPABLE(cls_id)
            if ret ~= "OK" then
                table.remove(g.job_change_helper_sorted_equip_list, i)
                return 1
            end
            local inv_item = session.GetInvItemByGuid(iesid)
            if inv_item then
                ITEM_EQUIP(inv_item.invIndex, spot_name)
                return 1
            else
                if i >= 9 then
                    DO_WEAPON_SLOT_CHANGE(inventory, 2)
                end
                table.remove(g.job_change_helper_sorted_equip_list, i)
                return 1
            end
        end
    end
    job_change_helper_end("equip")
    return 0
end

function job_change_helper_end(str)
    if str == "equip" then
        g.job_change_helper_mode = false
    else
        g.job_change_helper_mode = true
    end
    local inventory = ui.GetFrame('inventory')
    inventory:RunUpdateScript("job_change_helper_frame_init", 0.5)
    ui.SysMsg("[JCH]End of Operation")
end
-- Job Change Helper ここまで

-- Instant CC ここから
g.instant_cc_path = string.format("../addons/%s/%s/instant_cc.json", addon_name_lower, g.active_id)
g.instant_cc = {
    retry = nil,
    do_cc = nil,
    layer = 1
}
function instant_cc_load_settings()
    local changed = false
    local settings = g.load_json(g.instant_cc_path)
    if not settings then
        settings = {
            characters = {},
            per_barracks = false
        }
        changed = true
    end
    g.instant_cc_settings = settings
    if changed then
        instant_cc_save_settings()
    end
end

function instant_cc_save_settings()
    g.save_json(g.instant_cc_path, g.instant_cc_settings)
end

function instant_cc_on_init()
    if not g.instant_cc_settings then
        instant_cc_load_settings()
    end
    g.instant_cc.do_cc = nil
    g.instant_cc.retry = nil
    _G["norisan"] = _G["norisan"] or {}
    _G["norisan"]["HOOKS"] = _G["norisan"]["HOOKS"] or {}
    if not _G["norisan"]["HOOKS"]["BARRACK_START_FRAME_OPEN"] then
        _G["norisan"]["HOOKS"]["BARRACK_START_FRAME_OPEN"] = addon_name
        instant_cc_hook_BARRACK_START_FRAME_OPEN()
    end
    if _G["BARRACK_CHARLIST_ON_INIT"] and _G["current_layer"] then
        g.instant_cc.layer = _G["current_layer"]
    end
    g.setup_hook_and_event(g.addon, "APPS_TRY_MOVE_BARRACK", "instant_cc_APPS_TRY_MOVE_BARRACK", false)
    local acc_info = session.barrack.GetMyAccount()
    local barrack_count = acc_info:GetBarrackPCCount() -- ゲーム起動直後はtonumber(0)
    instant_cc_save_char_data(acc_info, barrack_count)
end

function instant_cc_settings_frame_init()
    local settings = ui.CreateNewFrame("chat_memberlist", "instant_cc_settings")
    AUTO_CAST(settings)
    local list_frame = ui.GetFrame(addon_name_lower .. "list_frame")
    settings:SetPos(list_frame:GetX() + list_frame:GetWidth(), list_frame:GetY() + list_frame:GetHeight() / 2)
    settings:EnableHitTest(1)
    settings:SetSkinName("test_frame_low")
    local width = 0
    local title = settings:CreateOrGetControl('richtext', 'title', 20, 10, 10, 30)
    AUTO_CAST(title)
    title:SetText("{#000000}{s20}instant CC Settings")
    width = width + 20 + title:GetWidth() + 40
    local close = settings:CreateOrGetControl('button', 'close', 0, 0, 20, 20)
    AUTO_CAST(close)
    close:SetImage("testclose_button")
    close:SetGravity(ui.RIGHT, ui.TOP)
    close:SetEventScript(ui.LBUTTONUP, "instant_cc_settings_frame_close")
    local gb = settings:CreateOrGetControl("groupbox", "gb", 10, 40, 100, 100)
    AUTO_CAST(gb)
    gb:SetSkinName("bg")
    gb:RemoveAllChild()
    local per_barracks = gb:CreateOrGetControl('checkbox', "per_barracks", 10, 5, 100, 30)
    AUTO_CAST(per_barracks)
    per_barracks:SetText(g.lang == "Japanese" and "{ol}チェックするとバラックごとに表示" or
                             "{ol}Check to display per barracks")
    per_barracks:SetCheck(g.instant_cc_settings.per_barracks and 1 or 0)
    per_barracks:SetEventScript(ui.LBUTTONUP, "instant_cc_setting")
    width = per_barracks:GetWidth() + 40
    settings:Resize(width, 90)
    gb:Resize(settings:GetWidth() - 20, 40)
    settings:ShowWindow(1)
end

function instant_cc_settings_frame_close(frame)
    local frame_name = "instant_cc_settings"
    ui.DestroyFrame(frame_name)
end

function instant_cc_setting(frame, ctrl)
    local is_check = ctrl:IsChecked()
    if is_check == 1 then
        g.instant_cc_settings.per_barracks = true
    else
        g.instant_cc_settings.per_barracks = false
    end
    instant_cc_save_settings()
end

function instant_cc_save_char_data(acc_info, barrack_count)
    local characters = g.instant_cc_settings.characters
    -- 毎回同じレイヤーのキャラは順番を取得
    local pc_count = acc_info:GetPCCount()
    for i = 0, pc_count - 1 do
        local pc_info = acc_info:GetPCByIndex(i)
        if pc_info then
            local pc_cid = pc_info:GetCID()
            local pc_apc = pc_info:GetApc()
            if pc_apc then
                local pc_name = pc_apc:GetName()
                characters[pc_name] = {
                    name = pc_name,
                    layer = g.instant_cc.layer,
                    order = i,
                    jobid = (acc_info:GetByStrCID(pc_cid) and acc_info:GetByStrCID(pc_cid):GetRepID()) or
                        pc_apc:GetJob(),
                    gender = pc_apc:GetGender(),
                    level = pc_apc:GetLv(),
                    cid = pc_cid
                }
            end
        end
    end
    -- ゲーム起動直後はカウント0なので、2回目以降動かす
    if barrack_count > 0 then
        local barrack_chars = {}
        for i = 0, barrack_count - 1 do
            local pc_info = acc_info:GetBarrackPCByIndex(i)
            if pc_info then
                barrack_chars[pc_info:GetName()] = true
            end
        end
        local chars_to_delete = {}
        for char_name, _ in pairs(characters) do
            if not barrack_chars[char_name] then
                table.insert(chars_to_delete, char_name)
            end
        end
        if #chars_to_delete > 0 then
            for _, char_name in ipairs(chars_to_delete) do
                characters[char_name] = nil
            end
        end
    end
    instant_cc_save_settings()
    instant_cc_sort_char_data()
end

function instant_cc_sort_char_data()
    g.instant_cc_sorted_list = {}
    for _, char_data in pairs(g.instant_cc_settings.characters) do
        table.insert(g.instant_cc_sorted_list, char_data)
    end
    local function dabble_sort(a, b)
        if a.layer == b.layer then
            return a.order < b.order
        else
            return a.layer < b.layer
        end
    end
    table.sort(g.instant_cc_sorted_list, dabble_sort)
end

function instant_cc_hook_BARRACK_START_FRAME_OPEN()
    g.FUNCS = g.FUNCS or {}
    local origin_func_name = "BARRACK_START_FRAME_OPEN"
    if _G[origin_func_name] then
        if not g.FUNCS[origin_func_name] then
            g.FUNCS[origin_func_name] = _G[origin_func_name]
        end
        _G[origin_func_name] = instant_cc_BARRACK_START_FRAME_OPEN
    end
end

function instant_cc_BARRACK_START_FRAME_OPEN(...)
    local frame = select(1, ...)
    if not frame then
        return
    end
    local original_func = g.FUNCS["BARRACK_START_FRAME_OPEN"]
    local result
    if original_func then
        result = original_func(...)
    end
    local barrack_gamestart = ui.GetFrame("barrack_gamestart")
    local hidelogin = GET_CHILD_RECURSIVELY(barrack_gamestart, "hidelogin")
    hidelogin:SetCheck(1)
    if g.instant_cc.do_cc and not g.instant_cc.retry then
        g.instant_cc.retry = 0
        barrack_gamestart:RunUpdateScript("instant_cc_start", 0.2)
    end
    return result
end

function instant_cc_APPS_TRY_MOVE_BARRACK(frame, msg, str, barrack_layer)
    if g.settings.instant_cc.use == 0 then
        RUN_GAMEEXIT_TIMER("Barrack")
        return
    end
    if barrack_layer == 0 then
        barrack_layer = g.instant_cc.layer
    end
    local context = ui.CreateContextMenu("instant_cc_select_character", "{ol}Barrack Charactor List", 0, 0, 0, 0)
    ui.AddContextMenuItem(context, "Return To Barrack", "instant_cc_do_cc()")
    if not g.instant_cc_settings.per_barracks then
        for i = 1, #g.instant_cc_sorted_list do
            local info = g.instant_cc_sorted_list[i]
            local pc_name = info.name
            local job_cls = GetClassByType("Job", info.jobid)
            local job_name = GET_JOB_NAME(job_cls, info.gender)
            job_name = string.gsub(dic.getTranslatedStr(job_name), "{s18}", "")
            local str = "Lv" .. info.level .. " " .. pc_name .. " (" .. job_name .. ")          "
            ui.AddContextMenuItem(context, str, string.format("instant_cc_do_cc('%s',%d)", info.cid, info.layer))
        end
    else
        ui.AddContextMenuItem(context, "Barrack 1",
            string.format("instant_cc_APPS_TRY_MOVE_BARRACK(nil, nil, nil, %d)", 1))
        ui.AddContextMenuItem(context, "Barrack 2",
            string.format("instant_cc_APPS_TRY_MOVE_BARRACK(nil, nil, nil, %d)", 2))
        ui.AddContextMenuItem(context, "Barrack 3",
            string.format("instant_cc_APPS_TRY_MOVE_BARRACK(nil, nil, nil, %d)", 3))
        for i = 1, #g.instant_cc_sorted_list do
            local info = g.instant_cc_sorted_list[i]
            local layer = info.layer
            if barrack_layer == layer then
                local pc_name = info.name
                local job_cls = GetClassByType("Job", info.jobid)
                local job_name = GET_JOB_NAME(job_cls, info.gender)
                job_name = string.gsub(dic.getTranslatedStr(job_name), "{s18}", "")
                local str = "Lv" .. info.level .. " " .. pc_name .. " (" .. job_name .. ")          "
                ui.AddContextMenuItem(context, str, string.format("instant_cc_do_cc('%s',%d)", info.cid, info.layer))
            end
        end
    end
    ui.OpenContextMenu(context)
end

function instant_cc_do_cc(cid, layer)
    if cid then
        g.instant_cc.do_cc = {
            cid = cid,
            layer = layer
        }
    end
    RUN_GAMEEXIT_TIMER("Barrack")
end

function instant_cc_start()
    barrack.SelectBarrackLayer(g.instant_cc.do_cc.layer)
    barrack.SelectCharacterByCID(g.instant_cc.do_cc.cid)
    local barrack_gamestart = ui.GetFrame("barrack_gamestart")
    barrack_gamestart:StopUpdateScript("instant_cc_to_game")
    barrack_gamestart:RunUpdateScript("instant_cc_to_game", 0.2)
end

function instant_cc_retry()
    g.instant_cc.retry = g.instant_cc.retry + 1
    if g.instant_cc.retry > #g.instant_cc_sorted_list then
        app.BarrackToLogin()
        ui.SysMsg(g.lang == "Japanese" and
                      "キャラクターの自動取得に失敗しました{nl}手動で選択してください" or
                      "Failed to automatically retrieve the character{nl}Please select manually")
        return
    end
    instant_cc_start()
end

function instant_cc_to_game(barrack_gamestart)
    local barrack_pc_info = barrack.GetBarrackPCInfoByCID(g.instant_cc.do_cc.cid)
    if not barrack_pc_info then
        instant_cc_retry()
        return
    end
    local barrack_start_char = barrack.GetGameStartAccount()
    if not barrack_start_char or barrack_start_char:GetCID() ~= g.instant_cc.do_cc.cid then
        instant_cc_retry()
        return
    end
    BARRACK_TO_GAME()
    return 0
end

if not _G["INSTANTCC_DO_CC"] then
    _G["INSTANTCC_DO_CC"] = instant_cc_do_cc
end

if not _G["INSTANTCC_APPS_TRY_MOVE_BARRACK"] then
    _G["INSTANTCC_APPS_TRY_MOVE_BARRACK"] = instant_cc_APPS_TRY_MOVE_BARRACK
end

if not _G["INSTANTCC_ON_INIT"] then
    _G["INSTANTCC_ON_INIT"] = instant_cc_on_init
end
-- Instant CC ここまで

--  Guild Event Warp ここから
g.guild_event_warp_path = string.format("../addons/%s/%s/guild_event_warp.json", addon_name_lower, g.active_id)
g.guild_event_warp_info = {{
    name = "dragoon",
    event_id = 500,
    monster = "guild_boss_dragoon_ex",
    tooltip = g.lang == "Japanese" and "{ol}ギルドイベント、ドラグーンのマップに移動します" or
        "{ol}Guild event move to the Dragoon map"
}, {
    name = "veliora",
    monster = "boss_Veliora_GMission",
    event_id = 501,
    tooltip = g.lang == "Japanese" and "{ol}ギルドイベント、アラクネ姉妹のマップに移動します" or
        "{ol}Guild event move to the Arachne Sisters map"
}, {
    name = "baubas",
    monster = "GuildEvent_npc_baubas2",
    event_id = 502,
    tooltip = g.lang == "Japanese" and "{ol}ギルドイベント、バウバスのマップに移動します" or
        "{ol}Guild event move to the Baubus map"
}}
function guild_event_warp_load_settings()
    local changed = false
    local settings = g.load_json(g.guild_event_warp_path)
    if not settings then
        settings = {
            open = true
        }
        changed = true
    end
    g.guild_event_warp_settings = settings
    if changed then
        guild_event_warp_save_settings()
    end
end

function guild_event_warp_save_settings()
    g.save_json(g.guild_event_warp_path, g.guild_event_warp_settings)
end

function guild_event_warp_on_init()
    if not g.guild_event_warp_settings then
        guild_event_warp_load_settings()
    end
    guild_event_warp_frame_init()
    if g.guild_event_warp_channnel_change then
        guild_event_warp_channel_change()
    end
end

function guild_event_warp_frame_init()
    local guild_event_warp = ui.CreateNewFrame("notice_on_pc", addon_name_lower .. "guild_event_warp", 0, 0, 0, 0)
    AUTO_CAST(guild_event_warp)
    guild_event_warp:SetSkinName("None")
    guild_event_warp:SetTitleBarSkin("None")
    guild_event_warp:SetGravity(ui.RIGHT, ui.TOP)
    local rect = guild_event_warp:GetMargin()
    guild_event_warp:SetMargin(rect.left - rect.left, rect.top - rect.top + 4, rect.right, rect.bottom)
    local icon_size = 28
    local icon_space = 33
    local x = 0
    for _, info in ipairs(g.guild_event_warp_info) do
        local slot_name = info.name .. "_slot"
        local slot = guild_event_warp:CreateOrGetControl("slot", slot_name, x, 0, icon_size, icon_size)
        AUTO_CAST(slot)
        slot:EnablePop(0)
        slot:EnableDrop(0)
        slot:EnableDrag(0)
        slot:SetEventScript(ui.LBUTTONUP, "guild_event_warp_move_to_guild_event")
        slot:SetEventScriptArgString(ui.LBUTTONUP, tostring(info.event_id))
        local mon_cls = GetClass("Monster", info.monster)
        if mon_cls then
            local icon = CreateIcon(slot)
            AUTO_CAST(icon)
            icon:SetImage(mon_cls.Icon)
            icon:SetTextTooltip(info.tooltip)
        end
        if g.guild_event_warp_settings.open == true then
            slot:ShowWindow(1)
        else
            slot:ShowWindow(0)
        end
        x = x + icon_space
    end
    local open = guild_event_warp:CreateOrGetControl('picture', "open", x, 0, 20, 20)
    AUTO_CAST(open)
    if g.guild_event_warp_settings.open == true then
        open:SetImage("quest_arrow_r_btn")
    else
        open:SetImage("quest_arrow_l_btn")
    end
    open:SetEnableStretch(1)
    open:SetEventScript(ui.LBUTTONUP, "guild_event_warp_toggle_frame")
    x = x + icon_space
    guild_event_warp:Resize(x - (icon_space - icon_size), icon_size)
    guild_event_warp:ShowWindow(1)
end

function guild_event_warp_toggle_frame(frame, ctrl, str, num)
    local show_window
    local new_image_name
    local new_open_state
    if g.guild_event_warp_settings.open == true then
        show_window = 0
        new_image_name = "quest_arrow_l_btn"
        new_open_state = false
    else
        show_window = 1
        new_image_name = "quest_arrow_r_btn"
        new_open_state = true
    end
    for _, info in ipairs(g.guild_event_warp_info) do
        local slot_name = info.name .. "_slot"
        local slot = GET_CHILD(frame, slot_name)
        AUTO_CAST(slot)
        slot:ShowWindow(show_window)
    end
    ctrl:SetImage(new_image_name)
    g.guild_event_warp_settings.open = new_open_state
    guild_event_warp_save_settings()
end

function guild_event_warp_move_to_guild_event(_, _, event_id)
    g.guild_event_warp_channnel_change = true
    _BORUTA_ZONE_MOVE_CLICK(event_id)
end

function guild_event_warp_channel_change()
    if g.current_channel ~= 0 then
        RUN_GAMEEXIT_TIMER("Channel", 0)
    end
    g.guild_event_warp_channnel_change = false
end
--  Guild Event Warp ここまで

-- Dungeon RP charger ここから
function dungeon_rp_charger_on_init()
    -- 11244 未知の聖域3F
    -- 40049 レリックバフ
    -- 11030036 エクトナイト(マケ売り可) misc_Ectonite
    -- 11030451 エクトナイト misc_Ectonite_Care
    if g.map_id == 11244 then
        g.addon:RegisterMsg('BUFF_ADD', 'dungeon_rp_charger_BUFF_ADD')
    end
end

function dungeon_rp_charger_BUFF_ADD(frame, msg, str, buff_id)
    if g.settings.dungeon_rp_charger.use == 0 then
        return
    end
    if buff_id == 40049 then
        local all_in_one = ui.GetFrame("all_in_one")
        if all_in_one then
            all_in_one:SetVisible(1)
            local dungeon_rp_charger_timer = all_in_one:CreateOrGetControl("timer", "dungeon_rp_charger_timer", 0, 0)
            AUTO_CAST(dungeon_rp_charger_timer)
            dungeon_rp_charger_timer:SetUpdateScript("dungeon_rp_charger_auto_charge")
            dungeon_rp_charger_timer:Start(1.0)
        end
    end
end

function dungeon_rp_charger_auto_charge(all_in_one, dungeon_rp_charger_timer)
    local my_handle = session.GetMyHandle()
    local relic_buff = info.GetBuff(my_handle, 40049)
    local pc = GetMyPCObject()
    local cur_rp, max_rp = shared_item_relic.get_rp(pc)
    if relic_buff and cur_rp > 150 then
        return
    end
    session.ResetItemList()
    local mat_item = session.GetInvItemByType(11030451)
    if not mat_item then
        mat_item = session.GetInvItemByType(11030036)
        if not mat_item then
            return
        end
    end
    if mat_item.isLockState then
        return
    end
    local item_index = mat_item:GetIESID()
    local cur_count = mat_item.count
    if cur_count and cur_count > 0 then
        local recharge_count = math.floor((max_rp - cur_rp) / 10)
        if recharge_count > cur_count then
            recharge_count = cur_count
        end
        if recharge_count > 0 then
            session.AddItemID(item_index, recharge_count)
            local result_list = session.GetItemIDList()
            item.DialogTransaction('RELIC_CHARGE_RP', result_list)
        end
    end
end
-- Dungeon RP charger ここまで

-- Cupole Manager ここから
g.cupole_manager_path = string.format("../addons/%s/%s/cupole_manager.json", addon_name_lower, g.active_id)
g.cupole_manager_old_path = string.format("../addons/%s/%s/settings.json", "cupole_manager", g.active_id)
function cupole_manager_load_settings()
    local changed = false
    local settings = g.load_json(g.cupole_manager_path)
    if not settings then
        local old_settings = g.load_json(g.cupole_manager_old_path)
        settings = {}
        if old_settings then
            for key, value in pairs(old_settings) do
                if tonumber(key) and string.len(key) > 3 then
                    settings[key] = value
                end
            end
        end
        changed = true
    end
    if not settings["default"] then
        settings["default"] = {}
        changed = true
    end
    if not settings[tostring(g.cid)] then
        settings[tostring(g.cid)] = {}
        changed = true
    end
    g.cupole_manager_settings = settings
    if changed then
        cupole_manager_save_settings()
    end
end

function cupole_manager_save_settings()
    g.save_json(g.cupole_manager_path, g.cupole_manager_settings)
end

function cupole_manager_on_init()
    if g.get_map_type() == "City" then
        if not g.cupole_manager_settings then
            cupole_manager_load_settings()
        end
        local equip_cupole_list = GET_EQUIP_CUPOLE_LIST()
        for i = 1, 3 do
            if equip_cupole_list[i] == "-1" then
                cupole_manager_SET_CUPOLE_SLOTS()
                break
            end
        end
        g.setup_hook_and_event(g.addon, "CLOSE_CUPOLE_ITEM", "cupole_manager_CLOSE_CUPOLE_ITEM", true)
        g.setup_hook_and_event(g.addon, "OPEN_CUPOLE_ITEM", "cupole_manager_OPEN_CUPOLE_ITEM", true)
    end
end

function cupole_manager_OPEN_CUPOLE_ITEM()
    if g.settings.cupole_manager.use == 0 then
        return
    end
    local cupole_item = ui.GetFrame("cupole_item")
    if not cupole_item then
        return
    end
    local manageBG = GET_CHILD_RECURSIVELY(cupole_item, "manageBG")
    local save_btn = manageBG:CreateOrGetControl("button", "save_btn", 1400, 730, 135, 45)
    AUTO_CAST(save_btn)
    save_btn:SetSkinName("cupole_border_btn")
    save_btn:SetText(g.lang == "Japanese" and "{ol}{s15}デフォルト変更" or "{ol}{s15}Change Default")
    save_btn:SetTextTooltip(g.lang == "Japanese" and "{ol}現在のセットをデフォルトに変更します" or
                                "{ol}Change the current set to the default")
    save_btn:SetEventScript(ui.LBUTTONUP, "cupole_manager_save_default_settings")
end

function cupole_manager_CLOSE_CUPOLE_ITEM(parent, ctrl)
    if g.settings.cupole_manager.use == 0 then
        return
    end
    local equip_cupole_list = GET_EQUIP_CUPOLE_LIST()
    for i = 1, 3 do
        local cupole_cls = GET_CUPOLE_BY_INDEX_IN_CLASSLIST(equip_cupole_list[i])
        local cupole_class_name = TryGetProp(cupole_cls, "ClassName", "None")
        if equip_cupole_list[i] ~= "-1" then
            g.cupole_manager_settings[g.cid][tostring(i)] = {
                id = equip_cupole_list[i],
                name = cupole_class_name
            }
            if not g.cupole_manager_settings["default"][tostring(i)] then
                g.cupole_manager_settings["default"][tostring(i)] = {
                    id = equip_cupole_list[i],
                    name = cupole_class_name
                }
            end
        end
    end
    cupole_manager_save_settings()
end

function cupole_manager_save_default_settings()
    local equip_cupole_list = GET_EQUIP_CUPOLE_LIST()
    for i = 1, 3 do
        if equip_cupole_list[i] == "-1" then
            ui.SysMsg(g.lang == "Japanese" and "クポルが3体登録されていません" or
                          "3 Cupoles are not registered")
            return
        end
    end
    for i = 1, 3 do
        local cupole_cls = GET_CUPOLE_BY_INDEX_IN_CLASSLIST(equip_cupole_list[i])
        local cupole_class_name = TryGetProp(cupole_cls, "ClassName", "None")
        g.cupole_manager_settings["default"][tostring(i)] = {
            id = equip_cupole_list[i],
            name = cupole_class_name
        }
    end
    cupole_manager_save_settings()
    ui.SysMsg(g.lang == "Japanese" and "現在のセットをデフォルトとして保存しました" or
                  "Saved the current set as default")
end

function cupole_manager_SET_CUPOLE_SLOTS(frame)
    if g.settings.cupole_manager.use == 0 then
        return
    end
    local frame = ui.GetFrame("cupole_item")
    local bg = GET_CHILD_RECURSIVELY_NAME(frame, "managerTab/manageBG/bg")
    local function is_valid_set(settings)
        if not settings or not settings["1"] or not settings["2"] or not settings["3"] then
            return false
        end
        if settings["1"].id == "-1" or settings["2"].id == "-1" or settings["3"].id == "-1" then
            return false
        end
        return true
    end
    local cid_settings = g.cupole_manager_settings[g.cid]
    local default_settings = g.cupole_manager_settings["default"]
    if is_valid_set(cid_settings) then
        g.cupole_manager_tbl = cid_settings
    else
        if is_valid_set(default_settings) then
            if next(cid_settings) then
                ui.SysMsg(g.lang == "Japanese" and "デフォルトのクポルセットを適用します" or
                              "Applying the default Cupole set")
            end
            g.cupole_manager_tbl = default_settings
        else
            ui.SysMsg(g.lang == "Japanese" and "デフォルトのクポルセット未登録" or
                          "Default Cupole set is not registered")
            return
        end
    end
    local all_in_one = ui.GetFrame("all_in_one")
    if all_in_one then
        all_in_one:SetVisible(1)
        local cupole_manager_timer = all_in_one:CreateOrGetControl("timer", "cupole_manager_timer", 0, 0)
        AUTO_CAST(cupole_manager_timer)
        cupole_manager_timer:SetUpdateScript("cupole_manager_summon_cupole")
        cupole_manager_timer:Start(1.0)
        g.cupole_manager_num = 0
    end
end

function cupole_manager_summon_cupole(all_in_one, cupole_manager_timer)
    if g.cupole_manager_num == 3 then
        return
    end
    SummonCupole(tonumber(g.cupole_manager_tbl[tostring(g.cupole_manager_num + 1)].id), g.cupole_manager_num)
    g.cupole_manager_num = g.cupole_manager_num + 1
    return
end
-- Cupole Manager ここまで

-- Boss Direction ここから
g.boss_direction_path = string.format("../addons/%s/%s/boss_direction.json", addon_name_lower, g.active_id)
function boss_direction_load_settings()
    local changed = false
    local settings = g.load_json(g.boss_direction_path)
    if not settings then
        settings = {
            layer = 29
        }
        changed = true
    end
    g.boss_direction_settings = settings
    if changed then
        boss_direction_save_settings()
    end
end

function boss_direction_save_settings()
    g.save_json(g.boss_direction_path, g.boss_direction_settings)
end

function boss_direction_on_init()
    if not g.boss_direction_settings then
        boss_direction_load_settings()
    end
    g.boss_direction_handls = {}
    if g.get_map_type() ~= "City" then
        boss_direction_handle_check_reserve()
    end
end

function boss_direction_settings_frame_init()
    local boss_direction_settings = ui.CreateNewFrame("chat_memberlist", addon_name_lower .. "boss_direction_settings")
    AUTO_CAST(boss_direction_settings)
    local list_frame = ui.GetFrame(addon_name_lower .. "list_frame")
    boss_direction_settings:SetPos(list_frame:GetX() + list_frame:GetWidth(),
        list_frame:GetY() + list_frame:GetHeight() / 2)
    boss_direction_settings:EnableHitTest(1)
    boss_direction_settings:SetSkinName("test_frame_low")
    local width = 0
    local title = boss_direction_settings:CreateOrGetControl('richtext', 'title', 20, 10, 10, 30)
    AUTO_CAST(title)
    title:SetText("{#000000}{s20}Boss Direction Settings")
    width = width + 20 + title:GetWidth() + 40
    local close = boss_direction_settings:CreateOrGetControl('button', 'close', 0, 0, 20, 20)
    AUTO_CAST(close)
    close:SetImage("testclose_button")
    close:SetGravity(ui.RIGHT, ui.TOP)
    close:SetEventScript(ui.LBUTTONUP, "boss_direction_setting_frame_close")
    local boss_direction_gb = boss_direction_settings:CreateOrGetControl("groupbox", "boss_direction_gb", 10, 40, 100,
        100)
    AUTO_CAST(boss_direction_gb)
    boss_direction_gb:SetSkinName("bg")
    boss_direction_gb:RemoveAllChild()
    local layer = boss_direction_gb:CreateOrGetControl('richtext', 'layer', 10, 10)
    AUTO_CAST(layer)
    layer:SetText(g.lang ~= "Japanese" and "{ol}フレームレイヤー設定" or "{ol}Frame Layer Settings")
    local layer_edit = boss_direction_gb:CreateOrGetControl('edit', 'layer_edit', layer:GetWidth() + 20, 5, 60, 30)
    AUTO_CAST(layer_edit)
    layer_edit:SetText("{ol}" .. g.boss_direction_settings.layer)
    layer_edit:SetFontName("white_16_ol")
    layer_edit:SetTextAlign("center", "center")
    layer_edit:SetNumberMode(1)
    layer_edit:SetEventScript(ui.ENTERKEY, "boss_direction_setting")
    layer_edit:SetTextTooltip(g.lang == "Japanese" and "{ol}エンターキー押下で登録" or
                                  "{ol}Register by pressing enter key")
    boss_direction_settings:Resize(width, 90)
    boss_direction_gb:Resize(boss_direction_settings:GetWidth() - 20, 40)
    boss_direction_settings:ShowWindow(1)
end

function boss_direction_setting_frame_close(frame)
    local frame_name = addon_name_lower .. "boss_direction_settings"
    ui.DestroyFrame(frame_name)
end

function boss_direction_setting(frame, ctrl)
    local ctrl_name = ctrl:GetName()
    local layer = tonumber(ctrl:GetText())
    if not layer then
        return
    end
    if tonumber(layer) ~= tonumber(g.boss_direction_settings.layer) then
        ui.SysMsg(g.lang == "Japanese" and "フレームレイヤーを " .. layer .. " に設定しました" or
                      "Frame Layer set to " .. layer)
        g.boss_direction_settings.layer = layer
    end
    boss_direction_save_settings()
end

function boss_direction_handle_check_reserve()
    local all_in_one = ui.GetFrame("all_in_one")
    if all_in_one then
        all_in_one:SetVisible(1)
        local boss_direction_timer = all_in_one:CreateOrGetControl("timer", "boss_direction_timer", 0, 0)
        AUTO_CAST(boss_direction_timer)
        boss_direction_timer:SetUpdateScript("boss_direction_handle_check")
        boss_direction_timer:Start(0.5)
    end
end

function boss_direction_handle_check(all_in_one, boss_direction_timer)
    if g.settings.boss_direction.use == 0 then
        return
    end
    local visible_bosses = {}
    local selected_objects, selected_objects_count = SelectObject(GetMyPCObject(), 500, "ENEMY")
    for i = 1, selected_objects_count do
        local handle = GetHandle(selected_objects[i])
        local target_info = info.GetTargetInfo(handle)
        if target_info.isBoss == 1 then
            local cls_name = info.GetMonsterClassName(handle)
            local mon_cls = GetClass("Monster", cls_name)
            local icon_name = mon_cls.Icon
            if icon_name ~= "icon_item_nothing" then
                visible_bosses[handle] = true
                local frame = ui.GetFrame("boss_direction" .. "_" .. handle)
                if not frame then
                    frame = ui.CreateNewFrame("notice_on_pc", "boss_direction_" .. handle, 0, 0, 0, 0)
                    frame:SetSkinName("None")
                    frame:SetTitleBarSkin("None")
                    frame:Resize(120, 120)
                    frame:SetLayerLevel(g.boss_direction_settings.layer or 29)
                    local arrow = frame:CreateOrGetControl("picture", "arrow", 0, 0, 70, 70)
                    AUTO_CAST(arrow)
                    arrow:SetImage("class_tree_arrow")
                    arrow:SetEnableStretch(1)
                    arrow:EnableHitTest(0)
                    arrow:SetGravity(ui.CENTER_HORZ, ui.CENTER_VERT)
                    arrow:Resize(60, 60)
                    arrow:SetColorTone("FFFF0000")
                end
                AUTO_CAST(frame)
                if not g.boss_direction_handls[handle] then
                    g.boss_direction_handls[handle] = frame:GetName()
                end
                local arrow = GET_CHILD(frame, "arrow")
                arrow:SetAngle(info.GetAngle(handle) - 23)
                FRAME_AUTO_POS_TO_OBJ(frame, handle, -frame:GetWidth() / 2, -frame:GetHeight() / 2, 0, 0)
                local stat = target_info.stat
                if stat.HP == 0 then
                    frame:ShowWindow(0)
                else
                    frame:ShowWindow(1)
                end
                if string.find(g.map_name, "Raid_Redania") and not string.find(string.upper(cls_name), "ILLUSION") then
                    arrow:SetColorTone("FFFFFF00")
                end
            end
        end
    end
    for handle, frame_name in pairs(g.boss_direction_handls) do
        if not visible_bosses[handle] then
            ui.DestroyFrame(frame_name)
            g.boss_direction_handls[handle] = nil
        end
    end
end
-- Boss Direction ここまで

-- Auto Repaire ここから
g.auto_repair_path = string.format("../addons/%s/%s/auto_repair.json", addon_name_lower, g.active_id)
g.auto_repair = {
    item_cls_id = 11202000,
    repair_item = "AustejaCertificate_14",
    shop_type = "AustejaCertificate"
}
function auto_repair_save_settings()
    g.save_json(g.auto_repair_path, g.auto_repair_settings)
end

function auto_repair_load_settings()
    local settings = g.load_json(g.auto_repair_path)
    local changed = false
    if not settings then
        settings = {
            buy_qty = 50,
            msg_qty = 20,
            setting_x = 800,
            setting_y = 700,
            auto_buy = false
        }
        changed = true
    end
    g.auto_repair_settings = settings
    if changed then
        auto_repair_save_settings()
    end
end

function auto_repair_on_init()
    if not g.auto_repair_settings then
        auto_repair_load_settings()
    end
    g.setup_hook_and_event(g.addon, "DURNOTIFY_UPDATE", "auto_repair_DURNOTIFY_UPDATE", false)
    if g.get_map_type() == "City" then
        local auto_repair_item = session.GetInvItemByType(g.auto_repair.item_cls_id)
        if not auto_repair_item or (auto_repair_item and auto_repair_item.count < g.auto_repair_settings.msg_qty) then
            auto_repair_msg_box_init()
        end
    end
end

function auto_repair_msg_box_init()
    if g.settings.auto_repair.use == 0 then
        return
    end
    if g.auto_repair_settings.auto_buy then
        local text = g.lang == "Japanese" and "{ol}[Auto Repair] 自動補充します" or
                         "{ol}[Auto Repair] Auto Replenish"
        ui.SysMsg(text)
        auto_repair_buy_item()
        return
    end
    local yes_scp = string.format("auto_repair_buy_item()")
    local msg = g.lang == "Japanese" and
                    "{ol}{#FFFFFF}[Auto Repair]修理キットの残りが少ないですが補充しますか？" or
                    "{ol}{#FFFFFF}[Auto Repair]{nl}Your repair kits are low{ol}Would you like to resupply them?"
    ui.MsgBox(msg, yes_scp, "None")
end

function auto_repair_buy_item()
    local auto_repair_item = session.GetInvItemByType(g.auto_repair.item_cls_id)
    local recipe_cls = GetClass("ItemTradeShop", g.auto_repair.repair_item)
    local count = 0
    if auto_repair_item ~= nil then
        local repair_count = auto_repair_item.count
        count = g.auto_repair_settings.buy_qty - repair_count
    else
        count = g.auto_repair_settings.buy_qty
    end
    session.ResetItemList()
    session.AddItemID(tostring(0), 1)
    local item_list = session.GetItemIDList()
    local count_text = string.format("%s %s", tostring(recipe_cls.ClassID), tostring(count))
    local str_list = NewStringList()
    str_list:Add(g.auto_repair.shop_type)
    item.DialogTransaction("Certificate_SHOP", item_list, count_text, str_list)
end

function auto_repair_setting_frame_close(frame)
    local frame_name = addon_name_lower .. "auto_repair_settings"
    ui.DestroyFrame(frame_name)
end

function auto_repair_end_drag(auto_repair_settings)
    g.auto_repair_settings.setting_x = auto_repair_settings:GetX()
    g.auto_repair_settings.setting_y = auto_repair_settings:GetY()
    auto_repair_save_settings()
end

function auto_repair_settings_frame_init()
    local auto_repair_settings = ui.CreateNewFrame("chat_memberlist", addon_name_lower .. "auto_repair_settings")
    AUTO_CAST(auto_repair_settings)
    auto_repair_settings:SetPos(g.auto_repair_settings.setting_x, g.auto_repair_settings.setting_y)
    auto_repair_settings:EnableHitTest(1)
    auto_repair_settings:SetSkinName("test_frame_low")
    auto_repair_settings:SetEventScript(ui.LBUTTONUP, "auto_repair_end_drag")
    auto_repair_settings:SetLayerLevel(81)
    local title = auto_repair_settings:CreateOrGetControl('richtext', 'title', 20, 10, 10, 30)
    AUTO_CAST(title)
    title:SetText("{#000000}{s20}Auto Repair Settings")
    local close_button = auto_repair_settings:CreateOrGetControl('button', 'close_button', 0, 0, 20, 20)
    AUTO_CAST(close_button)
    close_button:SetImage("testclose_button")
    close_button:SetGravity(ui.RIGHT, ui.TOP)
    close_button:SetEventScript(ui.LBUTTONUP, "auto_repair_setting_frame_close")
    local auto_repair_gb = auto_repair_settings:CreateOrGetControl("groupbox", "auto_repair_gb", 10, 40, 100, 100)
    AUTO_CAST(auto_repair_gb)
    auto_repair_gb:SetSkinName("bg")
    auto_repair_gb:RemoveAllChild()
    local buy_qty = auto_repair_gb:CreateOrGetControl('richtext', 'buy_qty', 10, 10)
    AUTO_CAST(buy_qty)
    buy_qty:SetText(g.lang == "Japanese" and "{ol}自動購入数入力" or "{ol}Number of automatic purchases")
    local msg_qty = auto_repair_gb:CreateOrGetControl('richtext', 'msg_qty', 10, 40)
    AUTO_CAST(msg_qty)
    msg_qty:SetText(g.lang == "Japanese" and "{ol}入力数以下で補充メッセージ" or
                        "{ol}Message with less than input quantit")
    local auto_purchase = auto_repair_gb:CreateOrGetControl('checkbox', "auto_purchase", 10, 70, 100, 25)
    AUTO_CAST(auto_purchase)
    auto_purchase:SetText(g.lang == "Japanese" and "{ol}自動補充有効化" or "{ol}Auto Replenishment Enable")
    auto_purchase:SetTextTooltip(g.lang == "Japanese" and "{ol}チェックすると自動で購入" or
                                     "{ol}Automatic purchase when checked")
    auto_purchase:SetCheck(g.auto_repair_settings.auto_buy and 1 or 0)
    auto_purchase:SetEventScript(ui.LBUTTONUP, "auto_repair_setting")
    local width = math.max(buy_qty:GetWidth(), msg_qty:GetWidth())
    local buy_edit = auto_repair_gb:CreateOrGetControl('edit', 'buy_edit', width + 20, 15, 60, 30)
    AUTO_CAST(buy_edit)
    buy_edit:SetText("{ol}" .. g.auto_repair_settings.buy_qty)
    buy_edit:SetFontName("white_16_ol")
    buy_edit:SetTextAlign("center", "center")
    buy_edit:SetNumberMode(1)
    buy_edit:SetEventScript(ui.ENTERKEY, "auto_repair_setting")
    buy_edit:SetTextTooltip(g.lang == "Japanese" and "{ol}エンターキー押下で登録" or
                                "{ol}Register by pressing enter key")
    local msg_edit = auto_repair_gb:CreateOrGetControl('edit', 'msg_edit', width + 20, 45, 60, 30)
    AUTO_CAST(msg_edit)
    msg_edit:SetText("{ol}" .. g.auto_repair_settings.msg_qty)
    msg_edit:SetFontName("white_16_ol")
    msg_edit:SetTextAlign("center", "center")
    msg_edit:SetNumberMode(1)
    msg_edit:SetEventScript(ui.ENTERKEY, "auto_repair_setting")
    msg_edit:SetTextTooltip(g.lang == "Japanese" and "{ol}エンターキー押下で登録" or
                                "{ol}Register by pressing enter key")
    auto_repair_settings:Resize(width + 100, 150)
    auto_repair_gb:Resize(width + 80, 100)
    auto_repair_settings:ShowWindow(1)
end

function auto_repair_setting(frame, ctrl)
    local ctrl_name = ctrl:GetName()
    if ctrl_name ~= "auto_purchase" then
        local value = tonumber(ctrl:GetText())
        if not value then
            return
        end
        if tonumber(value) ~= tonumber(g.auto_repair_settings.buy_qty) and ctrl_name == "buy_edit" then
            ui.SysMsg(g.lang == "Japanese" and "購入数量を " .. value .. " 個に設定しました" or
                          "Buy quantity set to " .. value)
            g.auto_repair_settings.buy_qty = value

        elseif tonumber(value) ~= tonumber(g.auto_repair_settings.msg_qty) and ctrl_name == "msg_edit" then
            ui.SysMsg(g.lang == "Japanese" and "お知らせ数量を " .. value .. " 個に設定しました" or
                          "Msg quantity set to " .. value)
            g.auto_repair_settings.msg_qty = value
        end
    elseif ctrl_name == "auto_purchase" then
        local is_check = ctrl:IsChecked()
        g.auto_repair_settings.auto_buy = is_check == 1 and true or false
    end
    auto_repair_save_settings()
end

function auto_repair_DURNOTIFY_UPDATE(my_frame, my_msg)
    local frame, notOpenFrame = g.get_event_args(my_msg)
    if g.settings.auto_repair.use == 0 then
        g.FUNCS["DURNOTIFY_UPDATE"](frame, notOpenFrame)
        return
    end
    if frame:IsVisible() == 0 then
        frame:ShowWindow(1)
    end
    local slot_set = GET_CHILD_RECURSIVELY(frame, 'slotlist', 'ui::CSlotSet')
    slot_set:ClearIconAll()
    for i = 0, slot_set:GetSlotCount() - 1 do
        local slot = slot_set:GetSlotByIndex(i)
        slot:ShowWindow(0)
    end
    local reverse_index = slot_set:GetSlotCount() - 1
    local equip_list = session.GetEquipItemList()
    local some_flag = 1
    for i = 0, equip_list:Count() - 1 do
        local equip_item = equip_list:GetEquipItemByIndex(i)
        local spot = item.GetEquipSpotName(equip_item.equipSpot)
        local slot_cnt = imcSlot:GetFilledSlotCount(slot_set)
        local temp_obj = equip_item:GetObject()
        if temp_obj ~= nil then
            local obj = GetIES(temp_obj)
            if IS_DUR_UNDER_10PER(obj) == true then
                local color_tone = "FF999900"
                if some_flag < 2 then
                    some_flag = 2
                    local type = equip_item.type
                    auto_repair_item_use(obj, spot)
                end
                if IS_DUR_ZERO(obj) == true then
                    color_tone = "FF990000"
                    if some_flag < 3 then
                        some_flag = 3
                    end
                end
                local slot = slot_set:GetSlotByIndex(reverse_index - slot_cnt)
                local icon = CreateIcon(slot)
                local icon_img = obj.Icon
                local briquetting_id = TryGetProp(obj, 'BriquettingIndex', 0)
                if briquetting_id > 0 then
                    local briquetting_item_cls = GetClassByType('Item', briquetting_id)
                    icon_img = briquetting_item_cls.Icon
                end
                icon:Set(icon_img, 'Item', equip_item.type, reverse_index - slot_cnt, equip_item:GetIESID())
                icon:SetColorTone(color_tone)
                slot:ShowWindow(1)
            end
        end
    end
    local now_value = frame:GetValue()
    if some_flag == 1 then
        frame:SetValue(1)
    elseif some_flag == 2 and now_value < some_flag then
        frame:SetValue(2)
        ui.SysMsg(ScpArgMsg('DurUnder30'))
    elseif some_flag == 3 and now_value < some_flag then
        frame:SetValue(3)
        ui.SysMsg(ScpArgMsg('DurUnder0'))
    end
end

function auto_repair_item_use(obj, spot)
    session.ResetItemList()
    local repair_kit = session.GetInvItemByType(g.auto_repair.item_cls_id)
    if repair_kit ~= nil and not repair_kit.isLockState then
        local repeat_count = math.min(repair_kit.count, 4)
        for i = 0, repeat_count - 1 do
            if obj.Dur / obj.MaxDur < 0.9 then
                item.UseByGUID(repair_kit:GetIESID())
            else
                break
            end
        end
    end
end
-- Auto Repaire ここまで

-- Acquire relic reward ここから
function acquire_relic_reward_on_init()
    if g.settings.acquire_relic_reward.use == 0 then
        return
    end
    if g.map_name == "c_Klaipe" or g.map_name == "c_fedimian" or g.map_name == "c_orsha" then
        local all_in_one = ui.GetFrame("all_in_one")
        if all_in_one then
            all_in_one:SetVisible(1)
            local acquire_relic_reward_timer =
                all_in_one:CreateOrGetControl("timer", "acquire_relic_reward_timer", 0, 0)
            AUTO_CAST(acquire_relic_reward_timer)
            acquire_relic_reward_timer:SetUpdateScript("acquire_relic_reward_process")
            acquire_relic_reward_timer:Start(1.0)
        end
    end
end

function acquire_relic_reward_process(all_in_one, acquire_relic_reward_timer)
    local acc = GetMyAccountObj()
    if not acc then
        return
    end
    local cls_list, cnt = GetClassList("Relic_Quest")
    for i = 0, cnt - 1 do
        local relic_cls = GetClassByIndexFromList(cls_list, i)
        local quest_type = TryGetProp(relic_cls, 'QuestType', 'None')
        if quest_type ~= 'None' then
            local pc_obj = GetMyPCObject()
            local result = SCR_RELIC_QUEST_CHECK(pc_obj, relic_cls.ClassName)
            if result == "Reward" then
                acquire_relic_reward_acquire_reward(relic_cls.ClassName)
                return
            end
        end
    end
end

function acquire_relic_reward_acquire_reward(cls_name)
    local pc_obj = GetMyPCObject()
    local result = SCR_RELIC_QUEST_CHECK(pc_obj, cls_name)
    if result == "Reward" then
        pc.ReqExecuteTx("SCR_TX_RELIC_QUEST_REWARD", cls_name)
    end
end
-- Acquire relic reward ここまで

-- Auto Pet Summon ここから
g.auto_pet_summon_path = string.format("../addons/%s/%s/auto_pet_summon.json", addon_name_lower, g.active_id)
function auto_pet_summon_save_settings()
    g.save_json(g.auto_pet_summon_path, g.auto_pet_summon_settings)
end

function auto_pet_summon_load_settings()
    local settings = g.load_json(g.auto_pet_summon_path)
    local changed = false
    if not settings then
        settings = {}
        changed = true
    end
    if not settings[g.cid] then
        settings[g.cid] = {
            iesid = "",
            clsid = 0
        }
        changed = true
    end
    g.auto_pet_summon_settings = settings
    if changed then
        auto_pet_summon_save_settings()
    end
end

function auto_pet_summon_on_init()
    if g.settings.auto_pet_summon.use == 0 then
        return
    end
    local cid = session.GetMySession():GetCID()
    if g.get_map_type() == "City" and (not g.auto_pet_summon_cid or cid ~= g.auto_pet_summon_cid) then
        g.auto_pet_summon_cid = cid
        if not g.auto_pet_summon then
            auto_pet_summon_load_settings()
        end
        auto_pet_summon_companion()
    end
end

function auto_pet_summon_companion()
    if g.auto_pet_summon_settings[g.cid].clsid ~= 0 then
        control.SummonPet(g.auto_pet_summon_settings[g.cid].clsid, g.auto_pet_summon_settings[g.cid].iesid, 0)
    else
        local text = g.lang == "Japanese" and "{ol}[APS]{#FFFFFF} " .. g.login_name .. " {/}ペット未登録" or
                         "{ol}[APS]{#FFFFFF} " .. g.login_name .. " {/}is not registered pet"
        ui.SysMsg(text)
    end
    local all_in_one = ui.GetFrame("all_in_one")
    if all_in_one then
        all_in_one:SetVisible(1)
        local auto_pet_summon_timer = all_in_one:CreateOrGetControl("timer", "auto_pet_summon_timer", 0, 0)
        AUTO_CAST(auto_pet_summon_timer)
        auto_pet_summon_timer:SetUpdateScript("auto_pet_summon_save_reserve")
        auto_pet_summon_timer:Start(1.0)
    end
end

function auto_pet_summon_save_reserve(all_in_one, auto_pet_summon_timer)
    local summoned_pet = session.pet.GetSummonedPet()
    local pet_is_summoned = (summoned_pet ~= nil)
    local pet_is_saved = (g.auto_pet_summon_settings[g.cid].clsid ~= 0)
    if pet_is_summoned == pet_is_saved then
        return
    end
    if pet_is_summoned then
        local iesid = tostring(summoned_pet:GetStrGuid())
        local pet_obj = summoned_pet:GetObject()
        local clsid = GetIES(pet_obj).ClassID
        g.auto_pet_summon_settings[g.cid].iesid = iesid
        g.auto_pet_summon_settings[g.cid].clsid = clsid
    else
        g.auto_pet_summon_settings[g.cid].iesid = ""
        g.auto_pet_summon_settings[g.cid].clsid = 0
    end
    auto_pet_summon_save_settings()
end
-- Auto Pet Summon ここまで

-- Ancient Auto Set ここから
g.ancient_auto_set_path = string.format("../addons/%s/%s/ancient_auto_set.json", addon_name_lower, g.active_id)
function ancient_auto_set_save_settings()
    g.save_json(g.ancient_auto_set_path, g.ancient_auto_set)
end

function ancient_auto_set_load_settings()
    local settings = g.load_json(g.ancient_auto_set_path)
    local changed = false
    if not settings then
        settings = {}
        changed = true
    end
    if not settings[g.cid] then
        settings[g.cid] = {}
    end
    g.ancient_auto_set = settings
    if changed then
        ancient_auto_set_save_settings()
    end
end

function ancient_auto_set_on_init()
    if not g.ancient_auto_set then
        ancient_auto_set_load_settings()
    end
    if g.get_map_type() == "City" then
        ancient_auto_set_change_set_reserve()
    end
    ancient_auto_set_frame_init()
    g.setup_hook_and_event(g.addon, "ANCIENT_CARD_LIST_OPEN", "ancient_auto_set_ANCIENT_CARD_LIST_OPEN", true)
    g.setup_hook_and_event(g.addon, "ANCIENT_CARD_LIST_CLOSE", "ancient_auto_set_ANCIENT_CARD_LIST_CLOSE", true)
end

function ancient_auto_set_ANCIENT_CARD_LIST_OPEN()
    if g.settings.ancient_auto_set.use == 0 then
        return
    end
    local ancient_card_list = ui.GetFrame("ancient_card_list")
    local frame_name = addon_name_lower .. "_ancient_auto_set_priset_frame"
    local priset_frame = ui.CreateNewFrame("notice_on_pc", frame_name, 0, 0, 0, 0)
    AUTO_CAST(priset_frame)
    priset_frame:RemoveAllChild()
    priset_frame:SetLayerLevel(92)
    priset_frame:SetSkinName('None')
    priset_frame:SetTitleBarSkin("None")
    priset_frame:SetPos(ancient_card_list:GetX() + 710, ancient_card_list:GetY() + 322)
    priset_frame:Resize(707, 400)
    priset_frame:ShowWindow(1)
    priset_frame:SetAnimation("frameOpenAnim", "chat_balloon_start")
    priset_frame:SetAnimation("frameCloseAnim", "chat_balloon_end")
    local bg = priset_frame:CreateOrGetControl("groupbox", "bg", 705, 360, ui.LEFT, ui.TOP, 0, 40, 0, 0)
    AUTO_CAST(bg)
    bg:SetSkinName("test_frame_low")
    bg:EnableHittestGroupBox(false)
    local title_bg = priset_frame:CreateOrGetControl("groupbox", "title_bg", 705, 61, ui.LEFT, ui.TOP, 0, 0, 0, 0)
    AUTO_CAST(title_bg)
    title_bg:SetSkinName("test_frame_top")
    title_bg:EnableHittestGroupBox(false)
    local title = priset_frame:CreateOrGetControl("richtext", "title", 100, 30, ui.CENTER_HORZ, ui.TOP, 0, 18, 0, 0)
    title:SetText("{@st43}{s22}Assister Preset Setting{/}")
    title:EnableHitTest(false)
    local close = priset_frame:CreateOrGetControl("button", "close", 44, 44, ui.RIGHT, ui.TOP, 0, 20, 17, 0)
    AUTO_CAST(close)
    close:SetImage("testclose_button")
    -- close:SetTextTooltip("{ol}Close the Assister Preset window")
    close:SetEventScript(ui.LBUTTONUP, "ancient_auto_set_ANCIENT_CARD_LIST_CLOSE")
    local topbg = priset_frame:CreateOrGetControl("groupbox", "topbg", 665, 315, ui.LEFT, ui.TOP, 20, 100, 0, 0)
    AUTO_CAST(topbg)
    topbg:EnableHittestGroupBox(false)
    local ancient_card_slot_gbox = topbg:CreateOrGetControl("groupbox", "ancient_card_slot_gbox", 665, 275, ui.LEFT,
        ui.TOP, 0, 0, 0, 0)
    AUTO_CAST(ancient_card_slot_gbox)
    ancient_card_slot_gbox:EnableHittestGroupBox(false)
    ancient_card_slot_gbox:SetSkinName("test_frame_midle")
    local tab = priset_frame:CreateOrGetControl("tab", "tab", 664, 40, ui.LEFT, ui.TOP, 22, 65, 0, 0)
    AUTO_CAST(tab)
    tab:SetEventScript(ui.LBUTTONUP, "ancient_auto_set_tab_change")
    tab:SetSkinName("tab2")
    for i = 1, 10 do
        tab:AddItem("{@st66b}{s16}Set " .. i, true, "", "", "", "", "", false)
    end
    tab:SetItemsFixWidth(66)
    tab:SetItemsAdjustFontSizeByWidth(66)
    local swap = priset_frame:CreateOrGetControl("button", "swap", 100, 45, ui.RIGHT, ui.TOP, 0, 325, 30, 0)
    swap:SetSkinName("test_pvp_btn")
    swap:SetText("{@st42}{s18}Change")
    swap:SetEventScript(ui.LBUTTONUP, "ancient_auto_set_card_change")
    local name_edit = priset_frame:CreateOrGetControl("edit", "name_edit", 420, 330, 150, 36)
    AUTO_CAST(name_edit)
    name_edit:SetFontName("white_16_ol")
    name_edit:SetTextAlign("left", "center")
    name_edit:SetSkinName("inventory_serch")
    name_edit:SetTextTooltip(g.lang == "Japanese" and "{ol}セット名入力" or "{ol}Set Name Input")
    name_edit:SetEventScript(ui.ENTERKEY, "ancient_auto_set_tab_name_save")
    priset_frame:ShowWindow(1)
    ancient_auto_set_tab_change(priset_frame)
end

function ancient_auto_set_ANCIENT_CARD_LIST_CLOSE()
    local frame_name = addon_name_lower .. "_ancient_auto_set_priset_frame"
    local priset_frame = ui.GetFrame(frame_name)
    if priset_frame then
        priset_frame:ShowWindow(0)
    end
end

function ancient_auto_set_tab_change(priset_frame)
    local tab = GET_CHILD(priset_frame, "tab")
    AUTO_CAST(tab)
    local tab_index = tab:GetSelectItemIndex()
    local set_name = priset_frame:CreateOrGetControl("richtext", "set_name", 50, 340, 320, 30)
    AUTO_CAST(set_name)
    set_name:SetFontName("white_18_ol")
    if g.ancient_auto_set.priset and g.ancient_auto_set.priset[tostring(tab_index)] then
        local current_set_name = g.ancient_auto_set.priset[tostring(tab_index)].name
        if current_set_name and current_set_name ~= "" then
            set_name:SetText("{ol}Set Name: " .. current_set_name)
        else
            set_name:SetText("{ol}Set Name:")
        end
    else
        set_name:SetText("{ol}Set Name:")
    end
    ancient_auto_set_load_slots(priset_frame, tab_index)
end

function ancient_auto_set_load_slots(priset_frame, tab_index)
    local gbox = GET_CHILD_RECURSIVELY(priset_frame, 'ancient_card_slot_gbox')
    gbox:RemoveAllChild()
    local width = 4
    for index = 0, 3 do
        local ctrlSet = gbox:CreateControlSet("ancient_card_item_slot", "SLOT_" .. index, width, 4)
        width = width + ctrlSet:GetWidth() + 2
        local ancient_card_gbox = GET_CHILD(ctrlSet, "ancient_card_gbox")
        ancient_card_gbox:SetVisible(0)
        ctrlSet:SetUserValue("INDEX", index)
        ctrlSet:EnableHitTest(1)
        local slot = GET_CHILD_RECURSIVELY(ctrlSet, "ancient_card_slot")
        AUTO_CAST(slot)
        local icon = CreateIcon(slot)
        slot:EnableHitTest(1)
        ctrlSet:SetEventScript(ui.DROP, 'ancient_auto_set_frame_drop')
        ctrlSet:SetEventScript(ui.RBUTTONDOWN, 'ancient_auto_set_delete_data')
        if index == 0 then
            local gold_border = GET_CHILD_RECURSIVELY(ctrlSet, "gold_border")
            AUTO_CAST(gold_border)
            gold_border:SetImage('monster_card_g_frame_02')
        end
        if g.ancient_auto_set and g.ancient_auto_set.priset and g.ancient_auto_set.priset[tostring(tab_index)] then
            local preset_data = g.ancient_auto_set.priset[tostring(tab_index)]
            if preset_data[tostring(index)] then
                local guid = preset_data[tostring(index)]
                if guid then
                    local card = session.ancient.GetAncientCardByGuid(guid)

                    if card then
                        SET_ANCIENT_CARD_SLOT(ctrlSet, card)
                    end
                end
            end
        end
        local default_image = GET_CHILD_RECURSIVELY(ctrlSet, "default_image")
        AUTO_CAST(default_image)
        default_image:SetImage("socket_slot_bg")
    end
end

function ancient_auto_set_card_change(priset_frame, ctrl)
    if IS_ANCIENT_ENABLE_MAP() == "YES" then
        imcAddOn.BroadMsg("NOTICE_Dm_!", ClMsg("ImpossibleInCurrentMap"), 3)
        return
    end
    local tab = GET_CHILD(priset_frame, "tab")
    AUTO_CAST(tab)
    local tab_index = tab:GetSelectItemIndex()
    if not g.ancient_auto_set.priset[tostring(tab_index)] then
        return
    end
    priset_frame:SetUserValue("TAB_INDEX", tab_index)
    priset_frame:SetUserValue("SLOT_INDEX", 0)
    priset_frame:RunUpdateScript("ancient_auto_set_put_card_slot", 0.3)
end

function ancient_auto_set_put_card_slot(priset_frame)
    local tab_index = priset_frame:GetUserIValue("TAB_INDEX")
    local slot_index = priset_frame:GetUserIValue("SLOT_INDEX")
    local target_guid = g.ancient_auto_set.priset[tostring(tab_index)][tostring(slot_index)]
    if slot_index <= 3 then
        if target_guid then
            local card = session.ancient.GetAncientCardBySlot(g.slot_index)
            if card then
                local guid = card:GetGuid()
                if target_guid ~= guid then
                    ReqSwapAncientCard(target_guid, slot_index)
                    imcSound.PlaySoundEvent("sys_card_battle_rival_slot_show")
                end
            else
                ReqSwapAncientCard(target_guid, slot_index)
                imcSound.PlaySoundEvent("sys_card_battle_rival_slot_show")
            end
        end
        priset_frame:SetUserValue("SLOT_INDEX", slot_index + 1)
        return 1
    end
    priset_frame:SetUserValue("TAB_INDEX", "None")
    priset_frame:SetUserValue("SLOT_INDEX", "None")
    return 0
end

function ancient_auto_set_tab_name_save(priset_frame, ctrl)
    local set_name = ctrl:GetText()
    local tab = GET_CHILD(priset_frame, "tab")
    AUTO_CAST(tab)
    local tab_index = tab:GetSelectItemIndex()
    if not g.ancient_auto_set.priset then
        g.ancient_auto_set.priset = {}
    end
    g.ancient_auto_set.priset[tostring(tab_index)].name = set_name
    ancient_auto_set_save_settings()
    priset_frame:RunUpdateScript("ancient_auto_set_ANCIENT_CARD_LIST_OPEN", 0.1)
end

function ancient_auto_set_frame_drop(parent, ctrl, str, num)
    local to_index = ctrl:GetUserIValue("INDEX")
    local ancient_card_list = ui.GetFrame("ancient_card_list")
    local priset_frame = parent:GetTopParentFrame()
    local tab = GET_CHILD(priset_frame, "tab")
    AUTO_CAST(tab)
    local tab_index = tab:GetSelectItemIndex()
    if not g.ancient_auto_set.priset then
        g.ancient_auto_set.priset = {}
    end
    if not g.ancient_auto_set.priset[tostring(tab_index)] then
        g.ancient_auto_set.priset[tostring(tab_index)] = {}
    end
    local lifted_guid = ancient_card_list:GetUserValue("LIFTED_GUID")
    g.ancient_auto_set.priset[tostring(tab_index)][tostring(to_index)] = lifted_guid
    ancient_auto_set_save_settings()
    ancient_auto_set_tab_change(priset_frame)
    ancient_card_list:SetUserValue("LIFTED_GUID", "None")
end

function ancient_auto_set_delete_data(parent, ctrl, str, num)
    local to_index = ctrl:GetUserIValue("INDEX")
    local priset_frame = parent:GetTopParentFrame()
    local tab = GET_CHILD(frame, "tab")
    AUTO_CAST(tab)
    local tab_index = tab:GetSelectItemIndex()
    if not (g.ancient_auto_set.priset and g.ancient_auto_set.priset[tostring(tab_index)]) then
        return
    end
    g.ancient_auto_set.priset[tostring(tab_index)][tostring(to_index)] = "None"
    ancient_auto_set_save_settings()
    ancient_auto_set_tab_change(priset_frame)
end

function ancient_auto_set_frame_init()
    local ancient_card_list = ui.GetFrame("ancient_card_list")
    local topbg = GET_CHILD_RECURSIVELY(ancient_card_list, "topbg")
    if g.settings.ancient_auto_set.use == 0 then
        local btn_aas = GET_CHILD(topbg, "btn_aas")
        if btn_aas then
            DESTROY_CHILD_BYNAME(topbg, "btn_aas")
        end
        return
    end
    local btn_aas = topbg:CreateOrGetControl("button", "btn_aas", 465, 285, 30, 30)
    AUTO_CAST(btn_aas)
    btn_aas:SetSkinName("None")
    btn_aas:SetImage("config_button_normal")
    btn_aas:Resize(30, 30)
    btn_aas:SetEventScript(ui.LBUTTONUP, "ancient_auto_set_reg")
    btn_aas:SetEventScript(ui.RBUTTONUP, "ancient_auto_set_release")
    btn_aas:SetTextTooltip(g.lang == "Japanese" and
                               "{ol}[AAS]{nl}左クリック: 登録{nl}右クリック: 登録解除" or
                               "{ol}[AAS]{nl}Left-click: Setting Register{nl}Right-click: Setting Release")
end

function ancient_auto_set_release(frame, ctrl)
    local ancient_card_list = ui.GetFrame("ancient_card_list")
    local tab = ancient_card_list:GetChild("tab")
    AUTO_CAST(tab)
    tab:SelectTab(0)
    g.ancient_auto_set[g.cid].guids = {}
    local msg = g.lang == "Japanese" and "[AAS]登録解除しました" or "[AAS]Setting released"
    ui.SysMsg(msg)
    ancient_auto_set_save_settings()
end

function ancient_auto_set_reg(frame, ctrl)
    local ancient_card_list = ui.GetFrame("ancient_card_list")
    local tab = ancient_card_list:GetChild("tab")
    AUTO_CAST(tab)
    tab:SelectTab(0)
    g.ancient_auto_set[g.cid] = {
        name = g.login_name,
        guids = {}
    }
    for index = 0, 3 do
        local card = session.ancient.GetAncientCardBySlot(index)
        if card then
            local guid = card:GetGuid()
            table.insert(g.ancient_auto_set[g.cid].guids, {guid, card:GetClassName()})
        end
    end
    local msg = g.lang == "Japanese" and "[AAS]登録しました" or "[AAS]Setting Registered"
    ui.SysMsg(msg)
    ancient_auto_set_save_settings()
end

function ancient_auto_set_change_set_reserve()
    if g.settings.ancient_auto_set.use == 0 then
        return
    end
    if not (g.ancient_auto_set[g.cid] and g.ancient_auto_set[g.cid].guids and next(g.ancient_auto_set[g.cid].guids)) then
        local text = g.lang == "Japanese" and "{ol}[AAS]{#FFFFFF} " .. g.login_name .. " {/}アシスター未登録" or
                         "{ol}[APS]{#FFFFFF} " .. g.login_name .. " {/}is not registered assister"
        ui.SysMsg(text)
        return
    end
    local all_in_one = ui.GetFrame("all_in_one")
    local ancient_auto_set_timer = all_in_one:CreateOrGetControl("timer", "ancient_auto_set_timer", 0, 0)
    AUTO_CAST(ancient_auto_set_timer)
    ancient_auto_set_timer:Stop()
    local needs_change = false
    for i, row_data in ipairs(g.ancient_auto_set[g.cid].guids) do
        local save_guid = row_data[1]
        local card = session.ancient.GetAncientCardBySlot(i - 1)
        local current_guid = card and card:GetGuid() or nil
        if save_guid ~= current_guid then
            needs_change = true
            break
        end
    end
    if needs_change then
        all_in_one:SetUserValue("ANCIENT_INDEX", 0)
        ancient_auto_set_timer:SetUpdateScript("ancient_auto_set_change_set")
        ancient_auto_set_timer:Start(0.3)
    end
end

function ancient_auto_set_change_set(all_in_one, ancient_auto_set_timer)
    local index = all_in_one:GetUserIValue("ANCIENT_INDEX")
    if index <= 3 then
        local card_guid = g.ancient_auto_set[g.cid].guids[index + 1][1]
        if card_guid then
            local card = session.ancient.GetAncientCardBySlot(index)
            local current_guid = card and card:GetGuid() or nil
            if card_guid ~= current_guid then
                ReqSwapAncientCard(card_guid, index)
            end
        end
        all_in_one:SetUserValue("ANCIENT_INDEX", index + 1)
        return 1
    end
    return 0
end
-- Ancient Auto Set ここまで

-- Auto Map Change ここから
function auto_map_change_on_init()
    g.addon:RegisterMsg("DIALOG_CHANGE_SELECT", "auto_map_change_DIALOG_ON_MSG")
end

function auto_map_change_DIALOG_ON_MSG(frame, msg, str, num)
    if g.settings.auto_map_change.use == 0 then
        return
    end
    if string.find(str, "HighLvZoneEnterMsgCustom") ~= nil then
        control.DialogItemSelect(1)
        control.DialogOk()
    end
end
-- Auto Map Change ここまで

-- Bulk Sales ここから
g.bulk_sales = {
    amount = 0,
    tbl = {},
    time = 0
}

function bulk_sales_on_init(frame, addon)
    g.addon:RegisterMsg('DIALOG_CLOSE', 'bulk_sales_SHOP_ON_MSG')
end

function bulk_sales_SHOP_ON_MSG(frame, msg, str, num)
    if g.settings.bulk_sales.use == 0 then
        return
    end
    g.bulk_sales.time = g.bulk_sales.time or 0
    local current_time = os.clock()
    if (current_time - g.bulk_sales.time) < 0.5 then
        return
    end
    if str ~= "Klapeda_Misc" and str ~= "Orsha_Misc" and str ~= "Fedimian_Misc" and
        not string.find(str, "CertificateCoin_Shop") then
        return
    else
        g.setup_hook_and_event(g.addon, "SHOP_UI_CLOSE", "bulk_sales_frame_close", true)
        bulk_sales_slotset()
    end
end

function bulk_sales_slotset()
    local bulk_sales = ui.CreateNewFrame("notice_on_pc", addon_name_lower .. "bulk_sales", 0, 0, 0, 0)
    AUTO_CAST(bulk_sales)
    bulk_sales:SetSkinName("test_frame_low")
    bulk_sales:SetLayerLevel(80)
    bulk_sales:SetTitleBarSkin("None")
    bulk_sales:RemoveAllChild()
    local gbox = bulk_sales:CreateOrGetControl("groupbox", 'gbox', 10, 35, 0, 0)
    AUTO_CAST(gbox)
    gbox:SetSkinName("None")
    local slotset = gbox:CreateOrGetControl('slotset', 'slotset', 0, 0, 0, 0)
    AUTO_CAST(slotset)
    slotset:EnablePop(1)
    slotset:EnableDrag(1)
    slotset:EnableDrop(1)
    slotset:EnableHitTest(1)
    slotset:SetColRow(15, 33)
    slotset:SetSlotSize(35, 35)
    slotset:SetSpc(1, 1)
    slotset:SetSkinName('invenslot2')
    slotset:CreateSlots()
    local title = bulk_sales:CreateOrGetControl("richtext", "title", 40, 10, 120, 30)
    AUTO_CAST(title)
    title:SetText("{@st66b18}Balk Sales")
    local close = bulk_sales:CreateOrGetControl("button", "close", 0, 0, 25, 25)
    AUTO_CAST(close)
    close:SetImage("testclose_button")
    close:SetGravity(ui.LEFT, ui.TOP)
    close:SetEventScript(ui.LBUTTONUP, "bulk_sales_frame_close")
    local sell_btn = bulk_sales:CreateOrGetControl("button", "sell_btn", 0, 0, 120, 50)
    AUTO_CAST(sell_btn)
    sell_btn:SetSkinName("test_red_button")
    sell_btn:SetEventScript(ui.LBUTTONDOWN, "bulk_sales_sell_execution_reserve")
    sell_btn:SetPos(slotset:GetWidth() - 115, 790)
    sell_btn:SetText("{@st41b}SELL{/}")
    local amount = bulk_sales:CreateOrGetControl("richtext", "amount", 0, 0, 120, 50)
    AUTO_CAST(amount)
    amount:SetPos(30, 800)
    amount:SetText("{@st41b}Sales Amount ▶{/}")
    local sales_amount = bulk_sales:CreateOrGetControl("richtext", "sales_amount", 0, 0, 120, 50)
    AUTO_CAST(sales_amount)
    sales_amount:SetPos(200, 800)
    sales_amount:SetText("{@st41b}{#FFA500}0{/}")
    bulk_sales:Resize(slotset:GetWidth() + 40, 850)
    gbox:Resize(bulk_sales:GetWidth() - 15, bulk_sales:GetHeight() - 100)
    gbox:SetScrollPos(0)
    local shop_frame = ui.GetFrame('shop')
    bulk_sales:SetPos(shop_frame:GetWidth() + 5, 5)
    bulk_sales:ShowWindow(1)
    INVENTORY_SET_CUSTOM_RBTNDOWN("bulk_sales_inv_rbtn")
end

function bulk_sales_frame_close()
    local bulk_sales = ui.GetFrame(addon_name_lower .. "bulk_sales")
    if bulk_sales then
        ui.DestroyFrame(addon_name_lower .. "bulk_sales")
    end
    INVENTORY_CLEAR_SELECT(nil)
    INVENTORY_SET_CUSTOM_RBTNDOWN("None")
    g.bulk_sales.time = os.clock()
    g.bulk_sales.amount = 0
    g.bulk_sales.tbl = {}
end

function bulk_sales_inv_invalidate(frame)
    frame:Invalidate()
    return 0
end

function bulk_sales_inv_rbtn(item_obj, slot)
    local icon = slot:GetIcon()
    local icon_info = icon:GetInfo()
    local clsid = icon_info.type
    local inv_item = session.GetInvItemByType(clsid)
    local item_obj = GetIES(inv_item:GetObject())
    local itemProp = geItemTable.GetPropByName(item_obj.ClassName)
    if itemProp:IsEnableShopTrade() == false then
        ui.SysMsg(ClMsg("CannoTradeToNPC"))
        return
    end
    if item_obj.MarketCategory == "Housing_Furniture" or item_obj.MarketCategory == "PHousing_Furniture" or
        item_obj.MarketCategory == "PHousing_Wall" or item_obj.MarketCategory == "PHousing_Carpet" then
        ui.SysMsg(ClMsg("Housing_Cant_Sell_This_Item"))
        return
    end
    local inv_item_list = session.GetInvItemList()
    local inv_guid_list = inv_item_list:GetGuidList()
    local count = inv_guid_list:Count()
    local bulk_sales = ui.GetFrame(addon_name_lower .. "bulk_sales")
    for i = 0, count - 1 do
        local guid = inv_guid_list:Get(i)
        local inv_item = inv_item_list:GetItemByGuid(guid)
        if true ~= inv_item.isLockState then
            local inv_obj = GetIES(inv_item:GetObject())
            local inv_clsid = inv_obj.ClassID
            local inv_item_count = inv_item.count
            if clsid == inv_clsid and not g.bulk_sales.tbl[tostring(guid)] then
                g.bulk_sales.tbl[tostring(guid)] = inv_item_count
                local slot_set = GET_CHILD_RECURSIVELY(bulk_sales, "slotset")
                local slot_count = slot_set:GetSlotCount()
                for j = 1, slot_count do
                    local new_slot = GET_CHILD_RECURSIVELY(slot_set, "slot" .. j)
                    local new_icon = new_slot:GetIcon()
                    if not new_icon then
                        local item_cls = GetClassByType("Item", clsid)
                        local item_prop = geItemTable.GetPropByName(item_cls.ClassName)
                        local item_price = geItemTable.GetSellPrice(item_prop) * inv_item_count
                        g.bulk_sales.amount = g.bulk_sales.amount + item_price
                        new_slot:SetEventScript(ui.RBUTTONDOWN, "bulk_sales_slot_cancel")
                        new_slot:SetEventScriptArgString(ui.RBUTTONDOWN, guid)
                        new_slot:SetEventScriptArgNumber(ui.RBUTTONDOWN, item_price)
                        SET_SLOT_ITEM_CLS(new_slot, item_cls)
                        SET_SLOT_ITEM_TEXT(new_slot, inv_item, item_cls)
                        local item_slot = INV_GET_SLOT_BY_ITEMGUID(guid)
                        if item_slot then
                            AUTO_CAST(item_slot)
                            item_slot:SetSelectedImage('socket_slot_check')
                            item_slot:Select(1)
                            item_slot:RunUpdateScript("bulk_sales_inv_invalidate", 0.2)
                            item_slot:Invalidate()
                        end
                        break
                    end
                end
            end
        end
    end
    local sales_amount = GET_CHILD_RECURSIVELY(bulk_sales, "sales_amount")
    AUTO_CAST(sales_amount)
    sales_amount:SetText("{@st41b}{#FFA500}" .. GET_COMMAED_STRING(g.bulk_sales.amount))
end

function bulk_sales_slot_cancel(frame, ctrl, guid, item_price)
    local inventory = ui.GetFrame("inventory")
    local item_slot = INV_GET_SLOT_BY_ITEMGUID(guid)
    if item_slot then
        item_slot:Select(0)
        item_slot:RunUpdateScript("bulk_sales_inv_invalidate", 0.1)
        item_slot:Invalidate()
    end
    local bulk_sales = ui.GetFrame(addon_name_lower .. "bulk_sales")
    g.bulk_sales.tbl[tostring(guid)] = false
    g.bulk_sales.amount = g.bulk_sales.amount - item_price
    local sales_amount = GET_CHILD_RECURSIVELY(bulk_sales, "sales_amount")
    AUTO_CAST(sales_amount)
    sales_amount:SetText("{@st41b}{#FFA500}" .. GET_COMMAED_STRING(g.bulk_sales.amount))
    ctrl:ClearText()
    ctrl:ClearIcon()
end

function bulk_sales_sell_execution_reserve(frame, ctrl, str, num)
    local yes_scp = string.format("bulk_sales_sell_execution()")
    local msg = g.lang == "Japanese" and "アイテムを販売しますか?" or "Do you want to sell this items?"
    ui.MsgBox(msg, yes_scp, "None")
end

function bulk_sales_sell_execution()
    local bulk_sales = ui.GetFrame(addon_name_lower .. "bulk_sales")
    local slot_set = GET_CHILD_RECURSIVELY(bulk_sales, "slotset")
    AUTO_CAST(slot_set)
    local slot_count = slot_set:GetSlotCount()
    for guid, count in pairs(g.bulk_sales.tbl) do
        item.AddToSellList(guid, count)
    end
    item.SellList()
    slot_set:ClearIconAll()
    bulk_sales_frame_close()
end
-- Bulk Sales　ここまで

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
            addons_file:write("created")
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
            file:write("created")
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
    close:SetEventScript(ui.LBUTTONUP, "norisan_menu_setting_frame_ctrl")
    local def_setting = setting:CreateOrGetControl("button", "def_setting", 10, 5, 150, 30)
    AUTO_CAST(def_setting)
    local notice = _G["norisan"]["MENU"].lang == "Japanese" and "{ol}デフォルトに戻す" or "{ol}Reset to default"
    def_setting:SetText(notice)
    def_setting:SetEventScript(ui.LBUTTONUP, "norisan_menu_setting_frame_ctrl")
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
            AUTO_CAST(item_elem)
            item_elem:SetSkinName("None")
            item_elem:SetText(data.image)
        else
            item_elem = frame:CreateOrGetControl('picture', ctrl_name, x, y, item_w, item_h)
            AUTO_CAST(item_elem)
            item_elem:SetImage(data.icon)
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

function g.norisan_menu_create_frame()
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
    local frame = ui.CreateNewFrame("chat_memberlist", "norisan_menu_frame", 0, 0, 0, 0)
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
