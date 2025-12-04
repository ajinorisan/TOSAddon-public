-- 0.0.2 アシスターオートセット修正、クイックスロットオペレート修正、フレームをalwaysVisible="true"に
-- リバイバルタイマーバグ修正、always_statusバグ修正、separate_buff_custom追加
-- 0.0.3 vakarine_equipのボタンクリックで設定開かなかったの修正、always_statusがどっかに行ってたの修正、old_funcの処理間違ってたの修正
-- 0.0.4 skill_gem_tooltip作り直して移植、save_quest移植、off時のバグ修正、
-- sub_mapミニマップモードを作成、status_point_checkとsilent_velnice_ranking移植
-- 0.0.5 always_statusバグ修正、another_warehouse追加、色々バグ修正
-- 0.0.6 GAMEEXIT_TIMER_ENDを取るのやめた、load_settingsの時に、新しいデフォルトを設定。
-- info.GetBuff(my_handle, 70002)これでトークン有る無し判断する様にこっちの方が早い
-- 0.0.7 instantCCがOFFの場合に、バラックに戻れなかったの修正
local addon_name = "_NEXUS_ADDONS"
local addon_name_lower = string.lower(addon_name)
local author = "norisan"
local ver = "0.0.7"

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

local function print_all_child(ctrl, prefix)
    prefix = prefix or ""
    local count = ctrl:GetChildCount()
    for i = 0, count - 1 do
        local child = ctrl:GetChildByIndex(i)
        local name = child:GetName()
        local class_name = child:GetClassName()
        local w = child:GetWidth()
        local h = child:GetHeight()
        print(string.format("%sName: %s | Class: %s | Size: %dx%d", prefix, name, class_name, w, h))
        if child:GetChildCount() > 0 then
            print_all_child(child, prefix .. "  ")
        end
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
    local user_folder = string.format("../addons/%s/%s", addon_name_lower, g.active_id)
    local user_file_path = string.format("../addons/%s/%s/mkdir.txt", addon_name_lower, g.active_id)
    create_folder(user_folder, user_file_path)
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
    local file, err = io.open(path, "w")
    if not file then
        print(string.format("[g.save_json] Error opening file for write: %s (Error: %s)", tostring(path), tostring(err)))
        return false
    end
    local success, str = pcall(json.encode, tbl)
    if success then
        file:write(str)
        file:close()
        return true
    else
        file:close()
        print(string.format("[g.save_json] JSON Encode Error in '%s': %s", tostring(path), tostring(str)))
        return false
    end
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

g._nexus_addons = {{
    key = "aethergem_manager",
    data = {
        use = 0,
        name = "Aethergem Manager",
        frame_use = false,
        config_func = "",
        old_init_func = "KLCOUNT_ON_INIT"
    }
}, {
    key = "acquire_relic_reward",
    data = {
        use = 0,
        name = "Acquire Relic Reward",
        frame_use = false,
        config_func = "",
        old_init_func = "ACQUIRERELICREWARD_ON_INIT"
    }
}, {
    key = "ancient_auto_set",
    data = {
        use = 0,
        name = "Ancient Auto Set",
        frame_use = false,
        config_func = "",
        old_init_func = "ANCIENT_AUTOSET_ON_INIT"
    }
}, {
    key = "another_warehouse",
    data = {
        use = 0,
        name = "Another Warehouse",
        frame_use = true,
        config_func = "another_warehouse_setting_frame_init",
        old_init_func = "ANOTHER_WAREHOUSE_ON_INIT"
    }
}, {
    key = "always_status",
    data = {
        use = 0,
        name = "Always Status",
        frame_use = true,
        config_func = "always_status_info_setting",
        old_init_func = "ALWAYS_STATUS_ON_INIT"
    }
}, {
    key = "auto_map_change", --
    data = {
        use = 0,
        name = "Auto Map Change",
        frame_use = false,
        config_func = "",
        old_init_func = "AUTOMAPCHANGE_ON_INIT"
    }
}, {
    key = "auto_pet_summon",
    data = {
        use = 0,
        name = "Auto Pet Summon",
        frame_use = false,
        config_func = "",
        old_init_func = "AUTO_PET_SUMMON_ON_INIT"
    }
}, {
    key = "auto_repair",
    data = {
        use = 0,
        name = "Auto Repair",
        frame_use = true,
        config_func = "auto_repair_settings_frame_init",
        old_init_func = "AUTO_REPAIR_ON_INIT"
    }
}, {
    key = "boss_direction",
    data = {
        use = 0,
        name = "Boss Direction",
        frame_use = true,
        config_func = "boss_direction_settings_frame_init",
        old_init_func = "BOSS_DIRECTION_ON_INIT"
    }
}, {
    key = "boss_gauge",
    data = {
        use = 0,
        name = "Boss Gauge",
        frame_use = false,
        config_func = "",
        old_init_func = "BOSS_GAUGE_ON_INIT"
    }
}, {
    key = "bulk_sales",
    data = {
        use = 0,
        name = "Bulk Sales",
        frame_use = false,
        config_func = "",
        old_init_func = "BULK_SALES_ON_INIT"
    }
}, {
    key = "characters_item_serch",
    data = {
        use = 0,
        name = "Characters Item Serch",
        frame_use = true,
        config_func = "characters_item_serch_toggle_frame",
        old_init_func = "CHARACTERS_ITEM_SERCH_ON_INIT"
    }
}, {
    key = "continue_reinforce",
    data = {
        use = 0,
        name = "Continue Reinforce",
        frame_use = false,
        config_func = "",
        old_init_func = "CONTINUERF_ON_INIT"
    }
}, {
    key = "cupole_manager",
    data = {
        use = 0,
        name = "Cupole Manager",
        frame_use = false,
        config_func = "",
        old_init_func = "CUPOLE_MANAGER_ON_INIT"
    }
}, {
    key = "debuff_notice",
    data = {
        use = 0,
        name = "Debuff Notice",
        frame_use = false,
        config_func = "",
        old_init_func = "DEBUFF_NOTICE_ON_INIT"
    }
}, {
    key = "dungeon_rp_charger",
    data = {
        use = 0,
        name = "Dungeon RP Charger",
        frame_use = false,
        config_func = "",
        old_init_func = "DUNGEONRPCHARGER_ON_INIT"
    }
}, {
    key = "easy_buff",
    data = {
        use = 0,
        name = "Easy Buff",
        frame_use = true,
        config_func = "easy_buff_config_frame",
        old_init_func = "EASYBUFF_ON_INIT"
    }
}, {
    key = "guild_event_warp",
    data = {
        use = 0,
        name = "Guild Event Warp",
        frame_use = false,
        config_func = "",
        old_init_func = "GUILDEVENTWARP_ON_INIT"
    }
}, {
    key = "instant_cc",
    data = {
        use = 0,
        name = "Instant CC",
        frame_use = true,
        config_func = "instant_cc_settings_frame_init",
        old_init_func = "INSTANTCC_ON_INIT"
    }
}, {
    key = "job_change_helper",
    data = {
        use = 0,
        name = "Job Change Helper",
        frame_use = false,
        config_func = "",
        old_init_func = "JOB_CHANGE_HELPER_ON_INIT"
    }
}, {
    key = "lets_go_home",
    data = {
        use = 0,
        name = "Lets Go Home",
        frame_use = true,
        config_func = "lets_go_home_settings_frame",
        old_init_func = "LETS_GO_HOME_ON_INIT"
    }
}, {
    key = "market_voucher",
    data = {
        use = 0,
        name = "Market Voucher",
        frame_use = false,
        config_func = "",
        old_init_func = "MARKET_VOUCHER_ON_INIT"
    }
}, {
    key = "monster_card_changer",
    data = {
        use = 0,
        name = "Monster Card Changer",
        frame_use = false,
        config_func = "",
        old_init_func = "MONSTERCARD_CHANGE_ON_INIT"
    }
}, {
    key = "monster_kill_count",
    data = {
        use = 0,
        name = "Monster Kill Count",
        frame_use = true,
        config_func = "monster_kill_count_information_context",
        old_init_func = "KLCOUNT_ON_INIT"
    }
}, {
    key = "my_buffs_control",
    data = {
        use = 0,
        name = "My Buffs Control",
        frame_use = true,
        config_func = "my_buffs_control_setting_menu",
        old_init_func = "MY_BUFFS_ON_INIT"
    }
}, {
    key = "no_check",
    data = {
        use = 0,
        name = "No Check",
        frame_use = false,
        config_func = "",
        old_init_func = "NOCHECK_ON_INIT"
    }
}, {
    key = "party_marker",
    data = {
        use = 0,
        name = "Party Marker",
        frame_use = false,
        config_func = "",
        old_init_func = "PARTYMARKER_ON_INIT"
    }
}, {
    key = "pick_item_tracker",
    data = {
        use = 0,
        name = "Pick Item Tracker",
        frame_use = false,
        config_func = "",
        old_init_func = "PICK_ITEM_TRACKER_ON_INIT"
    }
}, {
    key = "quickslot_operate",
    data = {
        use = 0,
        name = "Quickslot Operate",
        frame_use = false,
        config_func = "",
        old_init_func = "QUICKSLOT_OPERATE_ON_INIT"
    }
}, {
    key = "relic_change",
    data = {
        use = 0,
        name = "Relic Change",
        frame_use = false,
        config_func = "",
        old_init_func = "RELIC_CHANGE_ON_INIT"
    }
}, {
    key = "revival_timer",
    data = {
        use = 0,
        name = "Revival Timer",
        frame_use = true,
        config_func = "revival_timer_setting",
        old_init_func = "REVIVAL_TIMER_ON_INIT"
    }
}, {
    key = "save_quest",
    data = {
        use = 0,
        name = "Save Quest",
        frame_use = true,
        config_func = "save_quest_settings",
        old_init_func = "SAVEQUEST_ON_INIT"
    }
}, {
    key = "separate_buff_custom",
    data = {
        use = 0,
        name = "Separate Buff Custom",
        frame_use = true,
        config_func = "separate_buff_custom_settings",
        old_init_func = "SUB_MAP_ON_INIT"
    }
}, {
    key = "silent_velnice_ranking",
    data = {
        use = 0,
        name = "Silent Velnice Ranking",
        frame_use = false,
        config_func = "",
        old_init_func = "SILENTVELNICERANKING_ON_INIT"
    }
}, {
    key = "skill_gem_tooltip",
    data = {
        use = 0,
        name = "Skill Gem Tooltip",
        frame_use = false,
        config_func = "",
        old_init_func = "SKILLGEMTOOLTIP_ON_INIT"
    }
}, {
    key = "status_point_check",
    data = {
        use = 0,
        name = "Status Point Check",
        frame_use = true,
        config_func = "status_point_check_frame",
        old_init_func = "STATUSPOINTCHECK_ON_INIT"
    }
}, {
    key = "sub_map",
    data = {
        use = 0,
        name = "Sub Map",
        frame_use = true,
        config_func = "sub_map_settings",
        old_init_func = "SUB_MAP_ON_INIT"
    }
}, {
    key = "vakarine_equip",
    data = {
        use = 0,
        name = "Vakarine Equip",
        frame_use = true,
        config_func = "vakarine_equip_config_frame_open",
        old_init_func = "VAKARINE_EQUIP_ON_INIT"
    }
}}

g._nexus_addons_trans = {
    ["bulk_sales"] = {
        ja = "{ol}雑貨屋で大量販売出来るスロットセットを提供",
        etc = "{ol}Provide a set of slots that can be sold in bulk{nl}at a grocery store",
        kr = "{ol}잡화점에서 대량으로 판매 가능한 슬롯 세트 제공"
    },
    ["auto_map_change"] = {
        ja = "{ol}マップ移動時のダイアログ選択を自動化",
        etc = "{ol}Automate Dialogue Selection during Map Movement",
        kr = "{ol}맵 이동 시 다이얼로그 선택 자동화"
    },
    ["ancient_auto_set"] = {
        ja = "{ol}アシスターセットをキャラ毎に自動で付け替えます{nl}事前にアシスター保管箱で設定必要",
        etc = "{ol}Automatically switch Ancient Sets per character{nl}Requires prior setup in the Ancient Storage",
        kr = "{ol}어시스터 세트를 캐릭터별로 자동으로 교체{nl}미리 어시스터 보관함에서 설정 필요"
    },
    ["auto_pet_summon"] = {
        ja = "{ol}キャラ毎に最後に連れていたペットを自動で召喚します",
        etc = "{ol}Automatically summon the last-used pet for each character",
        kr = "{ol}캐릭터별로 마지막에 데리고 있던 펫을 자동으로 소환"
    },
    ["acquire_relic_reward"] = {
        ja = "{ol}ebisukeさん作成{nl}自動でレリッククエスト報酬を受け取ります{nl}マップ切替時などにゲームがクラッシュするバグ修正済",
        etc = "{ol}Created by ebisuke{nl}Automatically accepts Relic Quest rewards{nl}Fixed a bug causing the game to crash during map transitions",
        kr = "{ol}ebisuke님 제작{nl}레릭 퀘스트 보상을 자동으로 수령{nl}맵 전환 시 게임이 충돌하는 버그 수정 완료"
    },
    ["auto_repair"] = {
        ja = "{ol}装備の耐久を監視して30%未満になると緊急修理キットを使用して自動で修理します{nl}女神の証商店からの自動補充機能付き",
        etc = "{ol}Monitors equipment durability and automatically repairs it using an Emergency Repair Kit{nl}when durability drops below 30%{nl}Includes an automatic resupply function from the Goddess's Token Shop",
        kr = "{ol}장비 내구도를 감시하여 30% 미만 시 긴급 수리 키트로 자동 수리{nl}여신의 증표 상점 자동 보충 기능 포함"
    },
    ["boss_direction"] = {
        ja = "{ol}ボスが向いている方向を矢印でお知らせ",
        etc = "{ol}Arrow indicates the direction the boss is facing",
        kr = "{ol}보스가 향하는 방향을 화살표로 표시"
    },
    ["cupole_manager"] = {
        ja = "{ol}クポル未登録キャラでも自動で呼び出します",
        etc = "{ol}Automatically summons the Cupole{nl}even for characters without a registered one",
        kr = "{ol}쿠폴 미등록 캐릭터라도 자동으로 소환"
    },
    ["dungeon_rp_charger"] = {
        ja = "{ol}meldavyさん作成{nl}聖域で自動でレリックポイントを補充します",
        etc = "{ol}Created by meldavy{nl}Automatically restocks Relic Points in Sanctuary",
        kr = "{ol}meldavy님 제작{nl}성역에서 레릭 포인트를 자동으로 보충"
    },
    ["guild_event_warp"] = {
        ja = "{ol}画面右上の小さいボタンから封鎖戦マップの1チャンネルにワープ",
        etc = "{ol}Warp to Channel 1 of the Blockade Battle Map{nl}from the button in the upper right corner of the screen",
        kr = "{ol}화면 오른쪽 상단의 작은 버튼으로 봉쇄전 맵의 1채널로 워프"
    },
    ["instant_cc"] = {
        ja = "{ol}ebisukeさん作成{nl}キャラクターチェンジを簡易にします",
        etc = "{ol}Created by ebisuke{nl}Simplifies character changing",
        kr = "{ol}ebisuke님 제작{nl}캐릭터 변경을 간소화"
    },
    ["job_change_helper"] = {
        ja = "{ol}装備解除など、転職を簡易にします",
        etc = "{ol}Simplifies job change, such as unequipping gear",
        kr = "{ol}장비 해제 등, 전직을 간소화"
    },
    ["aethergem_manager"] = {
        ja = "{ol}エーテルジェムの付け替えを自動化{nl}キャラ毎の設定が必要です",
        etc = "{ol}Automate Aethergem equipping/swapping{nl}Settings are required for each character",
        kr = "{ol}에테르 젬 교체 자동화{nl}캐릭터별 설정이 필요합니다"
    },
    ["party_marker"] = {
        ja = "{ol}Charbonさん作成{nl}パーティーメンバーの頭上にアイコンを付けます",
        etc = "{ol}Created by Charbon{nl}Add an icon above the party members' heads",
        kr = "{ol}Charbon님 제작{nl}파티 멤버의 머리 위에 아이콘을 표시"
    },
    ["boss_gauge"] = {
        ja = "{ol}ボスゲージにスタン値とシールド値を表示します",
        etc = "{ol}Display Stun value and Shield value on the boss gauge",
        kr = "{ol}보스 게이지에 스턴 수치와 쉴드 수치 표시"
    },
    ["always_status"] = {
        ja = "{ol}ステータスを常に表示します",
        etc = "{ol}Always display status",
        kr = "{ol}스테이터스를 항상 표시"
    },
    ["characters_item_serch"] = {
        ja = "{ol}各キャラクターのアイテム検索{nl}インベントリボタン右クリックでも作動",
        etc = "{ol}Item search for each character{nl}Also activates by right-clicking the Inventory button",
        kr = "{ol}각 캐릭터의 아이템 검색{nl}인벤토리 버튼 오른쪽 클릭으로도 작동"
    },
    ["continue_reinforce"] = {
        ja = "{ol}ゴッデス装備連続強化",
        etc = "{ol}Goddes equipment continuous reinforcement",
        kr = "{ol}갓데스 장비 연속 강화"
    },
    ["debuff_notice"] = {
        ja = "{ol}自分が与えたデバフを見やすく表示",
        etc = "{ol}Clearly display the debuffs inflicted by oneself",
        kr = "{ol}자신이 부여한 디버프를 보기 쉽게 표시"
    },
    ["easy_buff"] = {
        ja = "{ol}Kiicchanさん作成{nl}各種商店でバフ自動付与",
        etc = "{ol}Created by Kiicchan{nl}Automatic buff application at various shops",
        kr = "{ol}Kiicchan님 제작{nl}각종 상점에서 버프 자동 부여"
    },
    ["monster_kill_count"] = {
        ja = "{ol}フィールド狩りで倒したモンスターをカウント{nl}アイテムドロップ情報取得",
        etc = "{ol}Count monsters defeated in field hunting{nl}Acquire item drop information",
        kr = "{ol}필드 사냥으로 처치한 몬스터 카운트{nl}아이템 드롭 정보 획득"
    },
    ["pick_item_tracker"] = {
        ja = "{ol}アイテム取得情報表示",
        etc = "{ol}Display item acquisition information",
        kr = "{ol}아이템 획득 정보 표시"
    },
    ["lets_go_home"] = {
        ja = "{ol}ホームタウンのホームチャンネルにワープします",
        etc = "{ol}Warp to the hometown's home channel",
        kr = "{ol}홈타운의 홈 채널로 워프"
    },
    ["market_voucher"] = {
        ja = "{ol}マーケットでの取引履歴表示",
        etc = "{ol}Show market trade history",
        kr = "{ol}마켓에서의 거래 내역 표시"
    },
    ["monster_card_changer"] = {
        ja = "{ol}モンスターカードプリセットを使いやすくします{nl}カード自動着脱、自動搬出入",
        etc = "{ol}Improve usability of monster card presets{nl}Automatic card equipping/unequipping, automatic transfer in/out",
        kr = "{ol}몬스터 카드 프리셋을 사용하기 쉽게 개선{nl}카드 자동 장착/해제, 자동 반출입"
    },
    ["my_buffs_control"] = {
        ja = "{ol}バフ欄を移動可能にして、選択したバフを非表示にします{nl}街では動作しません",
        etc = "{ol}buff panel movable and hide selected buffs{nl}Does not operate in town",
        kr = "{ol}버프 목록을 이동 가능하게 하고, 선택한 버프를 숨깁니다{nl}마을에서는 동작하지 않습니다"
    },
    ["quickslot_operate"] = {
        ja = "{ol}クイックスロットの女神ポーションをレイド毎に付け替えます{nl}ストレートモード、保存、読込機能もあります",
        etc = "{ol}Change the Goddess Potion in the quick slot for each raid{nl}Straight mode, save, and load functions are also available",
        kr = "{ol}퀵슬롯의 여신 포션을 레이드마다 교체{nl}스트레이트 모드, 저장, 불러오기 기능도 제공"
    },
    ["relic_change"] = {
        ja = "{ol}レリックシアンジェム付替えを簡易に",
        etc = "{ol}Simplify relic Cyan Gem swapping",
        kr = "{ol}레릭 시안 젬 교체를 간소화"
    },
    ["revival_timer"] = {
        ja = "{ol}普通のタイマー{nl}チャットコマンド'/timer'で作動",
        etc = "{ol}Normal timer{nl}Operates with the chat command '/timer'",
        kr = "{ol}일반 타이머{nl}채팅 명령어 '/timer'로 작동"
    },
    ["vakarine_equip"] = {
        ja = "{ol}ヴァカリネの恩恵を5箇所装着している場合{nl}レイドなどで装備を脱着します",
        etc = "{ol}If you have 5 Vakarine's Blessings equipped{nl}you will equip/unequip the gear",
        kr = "{ol}바카리네의 은총 5부위 장착 시{nl}레이드 등에서 장비를 장착/해제"
    },
    ["no_check"] = {
        ja = "{ol}各種確認を消します{nl}インベントリ検索窓横にボタンあります",
        etc = "{ol}Disable various confirmations{nl}Button is next to the inventory search window",
        kr = "{ol}각종 확인 창을 끕니다{nl}인벤토리 검색창 옆에 버튼 위치"
    },
    ["sub_map"] = {
        ja = "{ol}小さなマップを表示します",
        etc = "{ol}Show small map",
        kr = "{ol}미니맵을 표시"
    },
    ["separate_buff_custom"] = {
        ja = "{ol}セパレートバフフレームを改造します",
        etc = "{ol}Customize the separated buff frame",
        kr = "{ol}분리된 버프 프레임을 개조합니다"
    },
    ["skill_gem_tooltip"] = {
        ja = "{ol}ebisukeさん作成{nl}スキルジェムにツールチップを表示",
        etc = "{ol}Created by ebisuke{nl}Display tooltip on skill gems",
        kr = "{ol}ebisuke님 제작{nl}스킬 젬에 툴팁 표시"
    },
    ["save_quest"] = {
        ja = "{ol}weizlogyさん作成{nl}ワープ用のクエスト誤完了防止",
        etc = "{ol}Created by weizlogy{nl}Prevent accidental completion of warp quests",
        kr = "{ol}weizlogy님 제작{nl}워프용 퀘스트 오완료 방지"
    },
    ["silent_velnice_ranking"] = {
        ja = "{ol}ebisukeさん作成{nl}ヴェルニケのランキングを非表示にします{nl}TABキー押下でランキング表示",
        etc = "{ol}Created by ebisuke{nl}Hides the Velnice Ranking{nl}Press TAB key to show rankings",
        kr = "{ol}ebisuke님 제작{nl}벨니스 랭킹을 숨깁니다{nl}TAB 키를 누르면 랭킹 표시"
    },
    ["status_point_check"] = {
        ja = "{ol}torahamuさん作成{nl}ステータスポイントがもらえるクエストのクリア状況表示",
        etc = "{ol}Created by torahamu{nl}Display the clear status of quests that grant status points",
        kr = "{ol}torahamu님 제작{nl}스탯 포인트 획득 퀘스트의 클리어 상황 표시"
    },
    ["another_warehouse"] = {
        ja = "{ol}ebisukeさん作成{nl}チーム倉庫改造アドオンの保守改造版",
        etc = "{ol}Created by ebisuke{nl}Maintenance and modification version of the Team Storage Modification addon",
        kr = "{ol}ebisuke님 제작{nl}팀 창고 개조 애드온의 유지보수 및 개량 버전"
    } -- another_warehouse
}
function _nexus_addons_save_settings()
    g.save_json(g.settings_path, g.settings)
end

function _nexus_addons_load_settings()
    local settings, err = g.load_json(g.settings_path)
    if not settings then
        settings = {}
    end
    local changed = false
    for _, entry in ipairs(g._nexus_addons) do
        local key = entry.key
        local default_data = entry.data
        if not settings[key] then
            settings[key] = {}
            for k, v in pairs(default_data) do
                settings[key][k] = v
            end
            changed = true
        elseif type(settings[key]) == "table" then
            for k, v in pairs(default_data) do
                if settings[key][k] == nil then
                    settings[key][k] = v
                    changed = true
                end
            end
            for k, v in pairs(settings[key]) do
                if default_data[k] == nil then
                    settings[key][k] = nil
                    changed = true
                end
            end
        end
    end
    g.settings = settings
    if changed then
        _nexus_addons_save_settings()
    end
end

function _NEXUS_ADDONS_ON_INIT(addon, frame)
    g.addon = addon
    g.frame = frame
    g.lang = option.GetCurrentCountry()
    g.cid = session.GetMySession():GetCID()
    g.active_id = session.loginInfo.GetAID()
    g.settings_path = string.format("../addons/%s/%s/settings.json", addon_name_lower, g.active_id)
    if not g.folders_created then
        g.mkdir_new_folder()
        g.folders_created = true
    end
    _nexus_addons_load_settings()
    -- ここは開発時のみ使用
    --[[local function load_split_file(filename)
        local path = string.format("../data/addon_d/%s/%s", addon_name_lower, filename)
        local p, err = pcall(dofile, path)
        if not p then
            ts(string.format("[%s] Load Error: %s", addon_name, err))
        end
    end
    load_split_file("_nexus_addons_conclude.lua")]]
    -- ここまで
    g.login_name = session.GetMySession():GetPCApc():GetName()
    g.map_name = session.GetMapName()
    g.map_id = session.GetMapID()
    g.current_channel = session.loginInfo.GetChannel() -- 0が1ch
    g.pc = GetMyPCObject()
    g.REGISTER = {}
    addon:RegisterMsg('GAME_START', '_nexus_addons_GAME_START')
    addon:RegisterMsg('GAME_START_3SEC', '_nexus_addons_GAME_START_3SEC')
    addon:RegisterMsg('FPS_UPDATE', '_nexus_addons_update_frames')
end

function _nexus_addons_GAME_START(_nexus_addons, msg)
    _G["norisan"] = _G["norisan"] or {}
    _G["norisan"]["MENU"] = _G["norisan"]["MENU"] or {}
    local menu_data = {
        name = "Nexus Addons",
        icon = "sysmenu_coll",
        func = "_nexus_addons_frame_init",
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
    _nexus_addons_fast_faunc()
end

function _nexus_addons_fast_faunc(_nexus_addons)
    if g.separate_buff_custom_settings and g.settings.separate_buff_custom.use == 1 and
        g.separate_buff_custom_settings.tracking == 1 then
        separate_buff_custom_frame_move()
    end
    if g.quickslot_operate_settings and g.quickslot_operate_settings.straight then
        quickslot_operate_redraw_slots()
    end
end

function _nexus_addons_update_frames(_nexus_addons)
    local _nexus_addons = ui.GetFrame("_nexus_addons")
    if _nexus_addons and _nexus_addons:IsVisible() == 0 then
        _nexus_addons:ShowWindow(1)
    end
    local frames_to_check = {"always_status", "pick_item_tracker", "monster_kill_count", "debuff_notice",
                             "guild_event_warp", "lets_go_home", "relic_change", "vakarine_equip", "sub_map",
                             "save_quest"}
    for _, frame_key in ipairs(frames_to_check) do
        local frame_name = addon_name_lower .. frame_key
        local frame = ui.GetFrame(frame_name)
        if frame and frame:IsVisible() == 0 then
            if frame_key == "pick_item_tracker" then
                if g.get_map_type() ~= "City" and g.get_map_type() ~= "Instance" then
                    AUTO_CAST(frame)
                    frame:ShowWindow(1)
                end
            else
                AUTO_CAST(frame)
                frame:ShowWindow(1)
            end
        end
    end
end

function _nexus_addons_list_close(frame)
    local frame_to_close = {"boss_direction_settings", "auto_repair_settings", "instant_cc_settings",
                            "my_buffs_control_setting", "revival_timer_setting", "vakarine_equip_config_frame",
                            "easy_buff", "always_status_settings", "lets_go_home_setting", "characters_item_serch",
                            "sub_map_setting_frame", "separate_buff_custom_buff_list", "save_quest_setting"}
    for _, suffix in ipairs(frame_to_close) do
        local frame_name = addon_name_lower .. suffix
        local frame_to_close = ui.GetFrame(frame_name)
        if frame_to_close then
            ui.DestroyFrame(frame_name)
        end
    end
    ui.DestroyFrame(frame:GetName())
end

function _nexus_addons_frame_init()
    local list_frame_name = addon_name_lower .. "list_frame"
    local list_frame = ui.CreateNewFrame("notice_on_pc", list_frame_name, 0, 0, 10, 10)
    AUTO_CAST(list_frame)
    list_frame:RemoveAllChild()
    list_frame:SetSkinName("test_frame_low")
    list_frame:SetTitleBarSkin("None")
    list_frame:SetLayerLevel(92)
    local title = list_frame:CreateOrGetControl('richtext', 'title', 20, 10, 10, 30)
    AUTO_CAST(title)
    title:SetText("{#000000}{s25}Nexus Addons")
    local close_button = list_frame:CreateOrGetControl('button', 'close_button', 0, 0, 20, 20)
    AUTO_CAST(close_button)
    close_button:SetImage("testclose_button")
    close_button:SetGravity(ui.RIGHT, ui.TOP)
    close_button:SetEventScript(ui.LBUTTONUP, "_nexus_addons_list_close")
    local list_gb = list_frame:CreateOrGetControl("groupbox", "list_gb", 10, 40, 0, 0)
    AUTO_CAST(list_gb)
    list_gb:SetSkinName("bg")
    list_gb:RemoveAllChild()
    list_frame:ShowWindow(1)
    local base_num = 20
    local col1_x = 20
    local row_height = 40
    local max_width1 = 0
    local max_width2 = 0
    for i, entry in ipairs(g._nexus_addons) do
        local name = entry.data.name
        local current_y = (i <= base_num) and (i - 1) * row_height or (i - (base_num + 1)) * row_height
        local name_text = list_gb:CreateOrGetControl('richtext', 'name_text' .. i, col1_x, current_y + 10, 10, 30)
        AUTO_CAST(name_text)
        name_text:SetText("{ol}{s20}" .. name)
        if i <= base_num then
            max_width1 = math.max(max_width1, name_text:GetWidth())
        else
            max_width2 = math.max(max_width2, name_text:GetWidth())
        end
    end
    local col2_x = col1_x + max_width1 + 180
    for i, entry in ipairs(g._nexus_addons) do
        local child_addon_name = entry.key
        local data = entry.data
        local use = g.settings[child_addon_name].use
        local buttons_x, current_y
        if i <= base_num then
            buttons_x = col1_x + max_width1 + 25
            current_y = (i - 1) * row_height
        else
            local name_text = GET_CHILD(list_gb, 'name_text' .. i)
            name_text:SetPos(col2_x, name_text:GetY())
            buttons_x = col2_x + max_width2 + 25
            current_y = (i - (base_num + 1)) * row_height
        end
        local use_toggle = list_gb:CreateOrGetControl('picture', "use_toggle" .. i, buttons_x, current_y + 10, 60, 25)
        AUTO_CAST(use_toggle)
        use_toggle:SetImage(use == 1 and "test_com_ability_on" or "test_com_ability_off")
        use_toggle:SetEnableStretch(1)
        use_toggle:EnableHitTest(1)
        use_toggle:SetTextTooltip("{ol}ON/OFF")
        use_toggle:SetEventScript(ui.LBUTTONUP, "_nexus_addons_toggle_addons")
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
        local tooltip_text
        if g.lang == "Japanese" then
            tooltip_text = g._nexus_addons_trans[child_addon_name].ja
        elseif g.lang == "kr" then
            tooltip_text = g._nexus_addons_trans[child_addon_name].kr
        else
            tooltip_text = g._nexus_addons_trans[child_addon_name].etc
        end
        help_btn:SetTextTooltip(tooltip_text)
        help_btn:SetSkinName("test_pvp_btn")
    end
    local total_width = col2_x + max_width2 + 200
    local total_height = base_num * row_height + 70
    list_frame:Resize(total_width, total_height)
    list_gb:Resize(list_frame:GetWidth() - 20, list_frame:GetHeight() - 50)
    local map_frame = ui.GetFrame("map")
    local height = map_frame:GetHeight()
    list_frame:SetPos(310, (height / 2) - (list_frame:GetHeight() / 2))
    return list_frame
end

function _nexus_addons_toggle_addons(list_gb, use_toggle, child_addon_name, num)
    local old_init_func_name = nil
    for _, entry in ipairs(g._nexus_addons) do
        if entry.key == child_addon_name then
            old_init_func_name = entry.data.old_init_func
            break
        end
    end
    if old_init_func_name and old_init_func_name ~= "" and _G[old_init_func_name] and
        not (old_init_func_name == "INSTANTCC_ON_INIT" and _G["instant_cc_on_init"]) then
        local message
        old_init_func_name = string.lower(string.gsub(old_init_func_name, "_ON_INIT", ""))
        old_init_func_name = string.gsub(old_init_func_name, "_", " ")
        if g.lang == "Japanese" then
            message = string.format(
                "[Nexus Addons] 競合する古いアドオン '%s' が検出されました{nl}'%s' を有効化できません{nl}dataフォルダから、古いアドオンのipfファイルを削除してください",
                old_init_func_name, child_addon_name)
        else
            message = string.format(
                "[Nexus Addons] Conflicting old addon '%s' detected{nl}Cannot enable '%s'{nl}Please remove the old addon's ipf file from your data folders",
                old_init_func_name, child_addon_name)
        end
        ui.SysMsg(message)
        return
    end
    if g.settings[child_addon_name].use == 1 then
        g.settings[child_addon_name].use = 0
        ui.SysMsg(g.lang == "Japanese" and g.settings[child_addon_name].name .. " 無効にしました" or
                      g.settings[child_addon_name].name .. " Disabled")
    else
        g.settings[child_addon_name].use = 1
        ui.SysMsg(g.lang == "Japanese" and g.settings[child_addon_name].name .. " 有効にしました" or
                      g.settings[child_addon_name].name .. " Enabled")
    end
    _nexus_addons_init_addons(true, child_addon_name)
    _nexus_addons_save_settings()
    _nexus_addons_frame_init()
end

function _nexus_addons_init_addons(is_toggle, toggled_addon_name, _nexus_addons)
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
    g.pending_messages = {}
    for _, entry in ipairs(g._nexus_addons) do
        local key = entry.key
        local old_init_func_name = entry.data.old_init_func
        if old_init_func_name and old_init_func_name ~= "" and _G[old_init_func_name] and
            not (old_init_func_name == "INSTANTCC_ON_INIT" and _G["instant_cc_on_init"]) then
            local message
            old_init_func_name = string.lower(string.gsub(old_init_func_name, "_ON_INIT", ""))
            old_init_func_name = string.gsub(old_init_func_name, "_", " ")
            if g.lang == "Japanese" then
                message = string.format(
                    "{ol}{#FF6347}[Nexus Addons] 競合する古いアドオン '%s' が検出されました{nl}'%s' を無効化しました{nl}dataフォルダから、古いアドオンのipfファイルを削除してください",
                    old_init_func_name, key)
            else
                message = string.format(
                    "{ol}{#FF6347}[Nexus Addons] Conflicting old addon '%s' detected{nl}Disabled '%s'{nl}Please remove the old addon's ipf file from your data folders",
                    old_init_func_name, key)
            end
            table.insert(g.pending_messages, message)
            if g.settings[key] then
                if g.settings[key].use == 1 then
                    g.settings[key].use = 0
                    _nexus_addons_save_settings()
                end
            else
                ts(string.format("[Nexus Addons] Error: Settings for '%s' not found.", key))
            end
        else
            local on_init_func = _G[key .. "_on_init"]
            if g.settings[key].use == 1 then
                if is_toggle and key == toggled_addon_name then
                    safe_call(on_init_func, key)
                elseif not is_toggle then
                    safe_call(on_init_func, key)
                end
            else
                if is_toggle and key == toggled_addon_name then
                    safe_call(on_init_func, key)
                elseif not is_toggle and key == "instant_cc" then
                    safe_call(on_init_func, key)
                end
            end
        end
    end
    if #g.pending_messages > 0 and not g.loaded then
        if _nexus_addons then
            _nexus_addons:RunUpdateScript("_nexus_addons_chat_system", 0.5)
        end
        g.loaded = true
    end
    if not is_toggle then
        if error_count == 0 then
            ts("All add-ons initialized successfully.")
        else
            ts(string.format("%d add-on(s) failed to initialize...", error_count))
        end
    end
end

function _nexus_addons_chat_system(_nexus_addons)
    if #g.pending_messages > 0 then
        local msg = table.remove(g.pending_messages, 1)
        CHAT_SYSTEM(msg)
        return 1
    end
    return 0
end

function _nexus_addons_GAME_START_3SEC(_nexus_addons, msg)
    _nexus_addons_init_addons(false, nil, _nexus_addons)
end

-- always_status ここから
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
        key = "RHP",
        group = "atk1",
        on = 1
    }, {
        key = "RSP",
        group = "atk1",
        on = 0
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

function Always_status_save_settings()
    g.save_json(g.always_status_path, g.always_status_settings)
end

function Always_status_load_settings()
    g.always_status_path = string.format("../addons/%s/%s/always_status.json", addon_name_lower, g.active_id)
    g.always_status_old_path = string.format("../addons/%s/settings.json", "always_status")
    local settings = g.load_json(g.always_status_path)
    if not settings then
        settings = g.load_json(g.always_status_old_path)
    end
    if not settings then
        settings = {
            base = {
                frame_X = 0,
                frame_Y = 0,
                enable = 1,
                color = {}
            },
            chars = {}
        }
        for _, status_info in ipairs(always_status_master_list) do
            settings.base.color[status_info.key] = always_status_group_colors[status_info.group] or "{#FFFFFF}"
        end
        for i = 1, 10 do
            local set_num = tostring(i)
            settings[set_num] = {
                memo = "free memo " .. i
            }
            for _, status_info in ipairs(always_status_master_list) do
                settings[set_num][status_info.key] = status_info.on or 0
            end
        end
    elseif not settings.base then
        local new_settings = {
            base = {
                frame_X = 0,
                frame_Y = 0,
                enable = settings.enable or 0,
                color = settings.color or {}
            },
            chars = {}
        }
        for k, v in pairs(settings) do
            local num = tonumber(k)
            if num then
                if num >= 1 and num <= 10 then
                    local set_key = tostring(k)
                    new_settings[set_key] = v
                    for _, status_info in ipairs(always_status_master_list) do
                        if new_settings[set_key][status_info.key] == nil then
                            new_settings[set_key][status_info.key] = status_info.on or 0
                        end
                    end
                elseif num > 100 then
                    new_settings.chars[tostring(k)] = {
                        on = v.use or 1,
                        use_set = v.key or 1
                    }
                end
            end
        end
        settings = new_settings
    end
    if not settings.base.color then
        settings.base.color = {}
    end
    for _, status_info in ipairs(always_status_master_list) do
        if not settings.base.color[status_info.key] then
            settings.base.color[status_info.key] = always_status_group_colors[status_info.group] or "{#FFFFFF}"
        end
    end
    for i = 1, 10 do
        local set_num = tostring(i)
        if not settings[set_num] then
            settings[set_num] = {
                memo = "free memo " .. i
            }
        end
        for _, status_info in ipairs(always_status_master_list) do
            if settings[set_num][status_info.key] == nil then
                settings[set_num][status_info.key] = status_info.on or 0
            end
        end
    end
    g.always_status_settings = settings
    local cid_str = tostring(g.cid)
    if not g.always_status_settings.chars[cid_str] then
        g.always_status_settings.chars[cid_str] = {
            use_set = 1,
            on = 1
        }
    end
    Always_status_save_settings()
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
        Always_status_load_settings()
    elseif g.always_status_settings["chars"] and not g.always_status_settings["chars"][g.cid] then
        Always_status_load_settings()
    end
    Always_status_frame_init()
end

function Always_status_calc_all_atk_status(pc, attribute_name, value)
    if attribute_name == 'SmallSize_Atk' or attribute_name == 'MiddleSize_Atk' or attribute_name == 'LargeSize_Atk' then
        value = value + TryGetProp(pc, 'AllSize_Atk', 0)
    elseif attribute_name == 'Cloth_Atk' or attribute_name == 'Leather_Atk' or attribute_name == 'Iron_Atk' or
        attribute_name == 'Ghost_Atk' then
        value = value + TryGetProp(pc, 'AllMaterialType_Atk', 0)
    elseif attribute_name == 'Cloth_Def' or attribute_name == 'Leather_Def' or attribute_name == 'Iron_Def' then
        value = value + TryGetProp(pc, 'AllMaterialType_Def', 0)
    elseif attribute_name == 'Forester_Atk' or attribute_name == 'Widling_Atk' or attribute_name == 'Klaida_Atk' or
        attribute_name == 'Paramune_Atk' or attribute_name == 'Velnias_Atk' then
        value = value + TryGetProp(pc, 'AllRace_Atk', 0)
    end
    return value
end

function Always_status_calc_special_opt(pc, name)
    local value = 0
    local equip_item_list = session.GetEquipItemList();
    local equip_guid_list = equip_item_list:GetGuidList();
    local count = equip_guid_list:Count()
    for i = 0, count - 1 do
        local guid = equip_guid_list:Get(i)
        if guid ~= '0' then
            local equip_item = equip_item_list:GetItemByGuid(guid);
            if equip_item ~= nil and equip_item:GetObject() ~= nil then
                local item = GetIES(equip_item:GetObject())
                for j = 1, 6 do
                    local _name = 'RandomOption_' .. j
                    local _value = 'RandomOptionValue_' .. j
                    if TryGetProp(item, _name, 'None') == name then
                        value = value + TryGetProp(item, _value, 0)
                    end
                end
            end
        end
    end
    value = value + GetExProp(pc, name .. '_BM')
    return value
end

function Always_status_get_status_text(pc, status)
    local special_opts = {
        perfection = 1,
        revenge = 1,
        stun_res = 1,
        high_fire_res = 1,
        high_freezing_res = 1,
        high_lighting_res = 1,
        high_poison_res = 1,
        high_laceration_res = 1,
        portion_expansion = 1
    }
    if special_opts[status] then
        local val = Always_status_calc_special_opt(pc, status)
        return tostring(val)
    end
    if status == "STR" or status == "INT" or status == "CON" or status == "MNA" or status == "DEX" then
        local total_value = pc[status] + session.GetUserConfig(status .. "_UP")
        return tostring(total_value)
    end
    if status == "gear_score" then
        return tostring(GET_PLAYER_GEAR_SCORE(pc))
    end
    if status == "ability_point_score" then
        return tostring(GET_PLAYER_ABILITY_SCORE(pc)) .. "%"
    end
    if status == "PATK" or status == "MATK" then
        local min = pc["MIN" .. status]
        local max = pc["MAX" .. status]
        if GetExProp(pc, 'event_atk') > 0 then
            local event_atk = GetExProp(pc, 'event_atk')
            min = event_atk
            max = event_atk
        end
        return string.format("%d~%d", min, max)
    end
    if status == "HEAL_PWR" then
        return tostring(GET_SHOW_HEAL_PWR(pc, pc.HEAL_PWR))
    end
    if status == "CastingSpeed" then
        local val = TryGetProp(pc, status, 0)
        return tostring(val) .. "%"
    end
    local value = TryGetProp(pc, status, 0)
    value = Always_status_calc_all_atk_status(pc, status, value)
    return tostring(value)
end

function Always_status_frame_init()
    local function _logic()
        local always_status = ui.CreateNewFrame("notice_on_pc", addon_name_lower .. "always_status", 0, 0, 70, 30)
        AUTO_CAST(always_status)
        local base = g.always_status_settings["base"]
        always_status:RemoveAllChild()
        always_status:EnableHittestFrame(base.enable)
        always_status:EnableMove(base.enable)
        always_status:SetGravity(ui.RIGHT, ui.TOP)
        local rect = always_status:GetMargin()
        always_status:SetMargin(rect.left - rect.left, rect.top - rect.top + 500,
            rect.right == 0 and rect.right + 400 or rect.right, rect.bottom)
        if base.frame_X ~= 0 and base.frame_Y ~= 0 then
            always_status:SetPos(base.frame_X, base.frame_Y)
        end
        always_status:SetTitleBarSkin("None")
        always_status:SetSkinName("None")
        always_status:SetLayerLevel(11)
        always_status:SetEventScript(ui.LBUTTONUP, "Always_status_frame_move")
        always_status:SetEventScript(ui.RBUTTONDOWN, "Always_status_info_setting")
        local as_text = always_status:CreateOrGetControl("richtext", "as_text", 20, 5)
        AUTO_CAST(as_text)
        as_text:SetText("{ol}{S10}Always Status")
        as_text:SetEventScript(ui.RBUTTONDOWN, "Always_status_info_setting")
        local tooltip = g.lang == "Japanese" and "{ol}右クリックで表示設定" or
                            "{ol}Right-click to set display"
        as_text:SetTextTooltip(tooltip)
        local char = g.always_status_settings["chars"][g.cid]
        tooltip = g.lang == "Japanese" and "{ol}キャラクター毎に表示非表示を切り替えます" or
                      "{ol}Display and hide for each character"
        if char.on ~= 1 then
            local plus_pic = always_status:CreateOrGetControl("picture", "plus_pic", 0, 3, 15, 15)
            AUTO_CAST(plus_pic)
            plus_pic:SetEventScript(ui.LBUTTONUP, "Always_status_frame_toggle")
            plus_pic:SetImage("btn_plus")
            plus_pic:SetTextTooltip(tooltip)
            plus_pic:SetEnableStretch(1)
            always_status:Resize(150, 20)
            always_status:ShowWindow(1)
            return
        else
            local minus_pic = always_status:CreateOrGetControl("picture", "minus_pic", 0, 3, 15, 15)
            AUTO_CAST(minus_pic)
            minus_pic:SetEventScript(ui.LBUTTONUP, "Always_status_frame_toggle")
            minus_pic:SetImage("btn_minus")
            minus_pic:SetTextTooltip(tooltip)
            minus_pic:SetEnableStretch(1)
            local y = 20
            local pc = GetMyPCObject()
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
                    local title_text = ""
                    local message_id = ""
                    if status == "gear_score" then
                        message_id = "EquipedItemGearScore"
                        title_text = ScpArgMsg(message_id)
                    elseif status == "ability_point_score" then
                        message_id = "AbilityPointScore"
                        title_text = ScpArgMsg(message_id)
                    elseif status == "STR" or status == "INT" or status == "CON" or status == "MNA" or status == "DEX" then
                        title_text = ClMsg(status)
                    else
                        message_id = status
                        title_text = ScpArgMsg(message_id)
                    end
                    local match_result = string.match(title_text, "!@#%$([^#]+)")
                    if match_result then
                        title_text = dic.getTranslatedStr(ClMsg(match_result))
                    end
                    if g.lang == "Japanese" and data.jp then
                        title_text = data.jp
                    end
                    title:SetText("{ol}{s16}" .. color .. title_text)
                    local text = Always_status_get_status_text(pc, status)
                    if string.find(text, "~") == nil and string.find(text, "%%") == nil then
                        local pure_number_str = text:gsub("[^0-9]", "")
                        if #pure_number_str > 0 then
                            text = pure_number_str
                        else
                            text = "0"
                        end
                    end
                    stat:SetText(color .. "{ol}{s16}: " .. text)
                    if g.lang == "Japanese" then
                        stat:SetPos(125, y)
                    end
                    title:AdjustFontSizeByWidth(150)
                    if g.lang ~= "Japanese" then
                        stat:AdjustFontSizeByWidth(135)
                    end
                    y = y + 20
                end
            end
            if g.lang == "Japanese" then
                always_status:Resize(260, y + 10)
            else
                always_status:Resize(310, y + 10)
            end
            always_status:ShowWindow(1)
            always_status:RunUpdateScript("Always_status_update", 0.1)
        end
    end
    local result, err = pcall(_logic)
    if not result then
        local always_status = ui.GetFrame(addon_name_lower .. "always_status")
        always_status:RunUpdateScript("Always_status_frame_init", 0.5)
    end
end

function Always_status_update(always_status)
    local pc = GetMyPCObject()
    if pc == nil then
        return 1
    end
    for _, data in ipairs(always_status_master_list) do
        local status = data.key
        local always_status_stat = GET_CHILD_RECURSIVELY(always_status, "stat" .. status)
        if always_status_stat then
            local text = Always_status_get_status_text(pc, status)
            if string.find(text, "~") == nil and string.find(text, "%%") == nil then
                local pure_number_str = text:gsub("[^0-9]", "")
                if #pure_number_str > 0 then
                    text = pure_number_str
                else
                    text = "0"
                end
            end
            local color = g.always_status_settings["base"]["color"][status]
            always_status_stat:SetText(color .. "{ol}{s16}: " .. text)
        end
    end
    return 1
end

function Always_status_frame_move(always_status)
    g.always_status_settings["base"].frame_X = always_status:GetX()
    g.always_status_settings["base"].frame_Y = always_status:GetY()
    Always_status_save_settings()
end

function Always_status_info_setting()
    local list_frame = ui.GetFrame(addon_name_lower .. "list_frame")
    local settings_frame = ui.CreateNewFrame("notice_on_pc", addon_name_lower .. "Always_status_settings", 0, 0, 70, 30)
    AUTO_CAST(settings_frame)
    settings_frame:EnableHittestFrame(1)
    settings_frame:EnableHitTest(1)
    settings_frame:Resize(555, 900)
    settings_frame:SetPos(list_frame:GetX() + list_frame:GetWidth(), list_frame:GetY())
    settings_frame:SetLayerLevel(999)
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
    close:SetEventScript(ui.LBUTTONUP, "Always_status_frame_close")
    local drop_list = gb:CreateOrGetControl('droplist', 'setting_DropList', 100, 10, 200, 20)
    AUTO_CAST(drop_list)
    drop_list:SetSkinName('droplist_normal')
    drop_list:EnableHitTest(1)
    drop_list:SetTextAlign("center", "center")
    for i = 1, 10 do
        local display = g.always_status_settings[tostring(i)]
        local scp = "Always_status_info_setting_load(" .. i .. ")"
        if display.memo == "free memo " .. i then
            drop_list:AddItem(i - 1, tostring("Data ") .. i, 0, scp)
        else
            drop_list:AddItem(i - 1, display.memo, 0, scp)
        end
    end
    local use_set = tonumber(g.always_status_settings["chars"][g.cid].use_set)
    drop_list:SelectItem(use_set - 1)
    local base_pos = gb:CreateOrGetControl('button', 'base_pos', 350, 5, 120, 30)
    AUTO_CAST(base_pos)
    base_pos:SetText(g.lang == "Japanese" and "{ol}フレーム初期位置" or "{ol}Init frame pos")
    base_pos:SetEventScript(ui.LBUTTONUP, "Always_status_init_pos")
    local memo = gb:CreateOrGetControl('edit', 'memo', 215, 35, 200, 30)
    AUTO_CAST(memo)
    memo:SetEventScript(ui.ENTERKEY, "Always_status_memo_save")
    memo:SetEventScriptArgNumber(ui.ENTERKEY, use_set)
    memo:SetFontName("white_16_ol")
    memo:SetTextAlign("center", "center")
    local enable_check = gb:CreateOrGetControl("checkbox", "enablecheck", 510, 40, 20, 20)
    AUTO_CAST(enable_check)
    enable_check:SetEventScript(ui.LBUTTONUP, "Always_status_checkbox")
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
    Always_status_info_setting_load(use_set)
end

function Always_status_init_pos()
    g.always_status_settings["base"].frame_X = 0
    g.always_status_settings["base"].frame_Y = 0
    Always_status_save_settings()
    ui.DestroyFrame(addon_name_lower .. "always_status")
    ReserveScript("Always_status_frame_init()", 0.1)
end

function Always_status_info_setting_load(use_set)
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
    settings_frame:SetLayerLevel(999)
    local y = 10
    for _, data in ipairs(always_status_master_list) do
        local status = data.key
        local check = setting_gb:CreateOrGetControl("checkbox", "check" .. status, 475, y, 20, 20)
        AUTO_CAST(check)
        check:SetEventScript(ui.LBUTTONUP, "Always_status_checkbox")
        check:SetEventScriptArgString(ui.LBUTTONUP, status)
        check:SetEventScriptArgNumber(ui.LBUTTONUP, use_set)
        check:SetCheck(display[status])
        local color_box = setting_gb:CreateOrGetControl('groupbox', "colorbox" .. status, 250, y, 220, 20)
        AUTO_CAST(color_box)
        local color_table = {"FFFFFF", "FF6600", "FF4040", '66B3FF', "00FFFF", '00FF00', 'FF0000', 'FF00FF', "A566FF",
                             'FFFF00', "ADFF2F"}
        for j = 1, 11 do
            local color_str = color_table[j]
            local color_pic = color_box:CreateOrGetControl("picture", "color" .. j, 20 * (j - 1), 0, 20, 20)
            AUTO_CAST(color_pic)
            color_pic:SetImage("chat_color")
            color_pic:SetColorTone("FF" .. color_str)
            color_pic:SetEventScript(ui.LBUTTONUP, "Always_status_color_select")
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
    Always_status_save_settings()
    Always_status_frame_init()
end

function Always_status_frame_toggle(frame, ctrl)
    if g.always_status_settings["chars"][g.cid].on == 1 then
        g.always_status_settings["chars"][g.cid].on = 0
    else
        g.always_status_settings["chars"][g.cid].on = 1
    end
    Always_status_save_settings()
    Always_status_frame_init()
end

function Always_status_frame_close()
    local settings_frame = ui.GetFrame(addon_name_lower .. "always_status_settings")
    if settings_frame then
        ui.DestroyFrame(settings_frame:GetName())
    end
end

function Always_status_memo_save(frame, ctrl, str, use_set)
    local text = ctrl:GetText()
    g.always_status_settings[tostring(use_set)].memo = text
    ui.SysMsg(g.lang == "Japanese" and "タイトルを変更しました" or "The title has been changed")
    Always_status_save_settings()
    Always_status_info_setting()
end

function Always_status_checkbox(frame, ctrl, status, use_set)
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
    Always_status_save_settings()
    Always_status_frame_init()
    -- always_status_info_setting_load(use_set)
end

function Always_status_color_select(parent, ctrl, color_str, num)
    local status_name = string.gsub(parent:GetName(), "colorbox", "")
    g.always_status_settings["base"]["color"][status_name] = "{#" .. color_str .. "}"
    Always_status_save_settings()
    Always_status_info_setting()
    Always_status_frame_init()
end
-- always_status ここまで

-- another_warehouse ここから
function another_warehouse_save_settings()
    g.save_json(g.another_warehouse_path, g.awh_settings)
end

function another_warehouse_load_settings()
    g.another_warehouse_path = string.format("../addons/%s/%s/another_warehouse.json", addon_name_lower, g.active_id)
    g.another_warehouse_old_path = string.format("../addons/%s/%s/settings.json", "another_warehouse", g.active_id)
    local settings = g.load_json(g.another_warehouse_path)
    if not settings then
        local old_settings = g.load_json(g.another_warehouse_old_path)
        if old_settings then
            local new_take_set = {}
            local old_items_map = old_settings.setitems or {}
            local old_names_list = old_settings.handlelist or {}
            for i, name in ipairs(old_names_list) do
                local index_str = tostring(i)
                local items = old_items_map[index_str]
                if items then
                    table.insert(new_take_set, {
                        name = name,
                        items = items
                    })
                end
            end
            settings = {
                chars = {},
                etc = {
                    display_change = 0,
                    leave_item = 0,
                    auto_silver = 0
                },
                take_list = new_take_set,
                items = old_settings.items or {}
            }
        else
            local name_list = {"Take Items 1", "Take Items 2", "Take Items 3", "Take Items 4", "Take Items 5",
                               "Take Items 6", "Take Items 7", "Take Items 8", "Take Items 9", "Take Items 10"}
            local new_take_set = {}
            for i, name in ipairs(name_list) do
                table.insert(new_take_set, {
                    name = name,
                    items = {}
                })
            end
            settings = {
                chars = {},
                etc = {
                    display_change = 0,
                    leave_item = 0,
                    auto_silver = 0
                },
                take_list = new_take_set,
                items = {}
            }
        end
        g.awh_settings = settings
        another_warehouse_save_settings()
    else
        g.awh_settings = settings
    end
end

function another_warehouse_load_cid_settings()
    local old_settings = g.load_json(g.another_warehouse_old_path)
    if old_settings and old_settings[g.cid] then
        g.awh_settings.chars[g.cid] = old_settings[g.cid]
        if g.awh_settings.chars[g.cid].transfer then
            g.awh_settings.chars[g.cid].transfer = nil
        end
        if g.awh_settings.chars[g.cid].maney_check then
            g.awh_settings.chars[g.cid].money_check = g.awh_settings.chars[g.cid].maney_check
            g.awh_settings.chars[g.cid].maney_check = nil
        end
    else
        g.awh_settings.chars[g.cid] = {
            money_check = 0,
            name = g.login_name,
            item_check = 0,
            items = {}
        }
    end
    another_warehouse_save_settings()
end

function another_warehouse_on_init()
    if not g.awh_settings then
        another_warehouse_load_settings()
    end
    if not g.awh_settings.chars[g.cid] then
        another_warehouse_load_cid_settings()
    end
    g.setup_hook_and_event(g.addon, 'ACCOUNT_WAREHOUSE_UPDATE_VIS_LOG',
        "another_warehouse_ACCOUNT_WAREHOUSE_UPDATE_VIS_LOG", true)
    g.setup_hook_and_event(g.addon, 'ACCOUNTWAREHOUSE_CLOSE', "another_warehouse_ACCOUNTWAREHOUSE_CLOSE", true)
    if g.settings.another_warehouse.use == 0 then
        another_warehouse_frame_close()
        return
    end
    if g.get_map_type() == "City" then
        another_warehouse_accountwarehouse_init()
    end
end

function another_warehouse_accountwarehouse_init()
    if g.settings.another_warehouse.use == 0 then
        another_warehouse_frame_close()
        return
    end
    g.addon:RegisterMsg("OPEN_DLG_ACCOUNTWAREHOUSE", "another_warehouse_OPEN_DLG_ACCOUNTWAREHOUSE")
    g.addon:RegisterMsg("ACCOUNT_WAREHOUSE_ITEM_LIST", "another_warehouse_on_msg")
    g.addon:RegisterMsg("ACCOUNT_WAREHOUSE_ITEM_ADD", "another_warehouse_on_msg")
    g.addon:RegisterMsg("ACCOUNT_WAREHOUSE_ITEM_REMOVE", "another_warehouse_on_msg")
    g.addon:RegisterMsg("ACCOUNT_WAREHOUSE_ITEM_CHANGE_COUNT", "another_warehouse_on_msg")
    g.addon:RegisterMsg("ACCOUNT_WAREHOUSE_ITEM_IN", "another_warehouse_on_msg")
    if type(_G["YAACCOUNTINVENTORY_ON_INIT"]) == "function" then
        _G["YAACCOUNTINVENTORY_ON_INIT"] = nil
    end
    local functionName = "WAREHOUSEMANAGER_ON_INIT"
    if type(_G["WAREHOUSEMANAGER_ON_INIT"]) == "function" then
        _G["WAREHOUSEMANAGER_ON_INIT"] = nil
    end
    g.awh_new_stack_add_item = {}
end

function another_warehouse_on_msg(frame, msg, str, num)
    if g.settings.another_warehouse.use == 0 then
        return
    end
    local awh = ui.GetFrame(addon_name_lower .. "awh")
    local gb = GET_CHILD(awh, "gb")
    AUTO_CAST(gb)
    local cur_pos = gb:GetScrollCurPos()
    awh:SetUserValue("SCROLL_POS", cur_pos)
    if msg == 'ACCOUNT_WAREHOUSE_ITEM_REMOVE' then
        another_warehouse_remove_recurse_guid(awh, str)
        awh:RunUpdateScript("another_warehouse_frame_update_remove", 3.0)
        return
    end
    local index = awh:GetUserIValue("TAB_INDEX")
    another_warehouse_frame_update(awh, gb, "", index)
end

function another_warehouse_frame_update_remove(awh)
    awh:StopUpdateScript("another_warehouse_frame_update_remove")
    local gb = GET_CHILD(awh, "gb")
    AUTO_CAST(gb)
    local index = awh:GetUserIValue("TAB_INDEX")
    another_warehouse_frame_update(awh, gb, "", index)
    return 0
end

function another_warehouse_remove_recurse_guid(awh, guid)
    local slot = ui.GetFocusObject()
    if not slot then
        return
    end
    local icon = slot:GetIcon()
    if icon then
        local icon_info = icon:GetInfo()
        if icon_info:GetIESID() == guid then
            slot:ClearIcon()
            slot:SetSkinName("invenslot2")
            slot:SetText("")
            slot:RemoveAllChild()
        end
    end
end

function another_warehouse_ACCOUNT_WAREHOUSE_UPDATE_VIS_LOG(my_frame, my_msg)
    if g.settings.another_warehouse.use == 0 then
        another_warehouse_frame_close()
        return
    end
    local accountwarehouse = ui.GetFrame("accountwarehouse")
    local visgBox = GET_CHILD_RECURSIVELY(accountwarehouse, 'visgBox')
    local cnt = session.AccountWarehouse.GetCount()
    for i = cnt - 1, 0, -1 do
        local log = session.AccountWarehouse.GetByIndex(i)
        local ctrl_set = GET_CHILD(visgBox, "CTRLSET_" .. i)
        local inputVis = ctrl_set:GetChild('inputVis')
        inputVis:ShowWindow(0)
        local new_input = ctrl_set:CreateOrGetControl("richtext", " new_input", 220, i, 50, 24)
        AUTO_CAST(new_input)
        new_input:SetGravity(ui.RIGHT, ui.CENTER_VERT)
        new_input:SetMargin(0, 0, 330, 0)
        new_input:SetTextAlign("right", "center")
        if not string.find(inputVis:GetText(), "ZZZZZ") then
            new_input:SetText(inputVis:GetText())
        end
    end
end

function another_warehouse_ACCOUNTWAREHOUSE_CLOSE()
    if g.settings.another_warehouse.use == 0 then
        return
    end
    local monstercardslot = ui.GetFrame("monstercardslot")
    monstercardslot:SetLayerLevel(96)
    ui.DestroyFrame(addon_name_lower .. "awh")
    INVENTORY_SET_CUSTOM_RBTNDOWN("None")
    local inventory = ui.GetFrame("inventory")
    SET_INV_LBTN_FUNC(inventory, "None")
    ui.DestroyFrame(addon_name_lower .. "awh_setting")
    another_warehouse_set_item_close()
end

function another_warehouse_frame_close(parent, ctrl)
    another_warehouse_ACCOUNTWAREHOUSE_CLOSE()
    ui.DestroyFrame(addon_name_lower .. "awh")
    local accountwarehouse = ui.GetFrame("accountwarehouse")
    local accountwarehousefilter = GET_CHILD_RECURSIVELY(accountwarehouse, "accountwarehousefilter")
    accountwarehousefilter:ShowWindow(1)
    local accountwarehouse = ui.GetFrame("accountwarehouse")
    local accountwarehouse_tab = GET_CHILD_RECURSIVELY(accountwarehouse, "accountwarehouse_tab")
    accountwarehouse_tab:ShowWindow(1)
    local richtext_1 = GET_CHILD_RECURSIVELY(accountwarehouse, "richtext_1")
    richtext_1:ShowWindow(1)
    local itemcnt = GET_CHILD_RECURSIVELY(accountwarehouse, "itemcnt")
    itemcnt:ShowWindow(1)
    local slotgbox = GET_CHILD_RECURSIVELY(accountwarehouse, "slotgbox")
    slotgbox:ShowWindow(1)
    local richtext_3 = GET_CHILD_RECURSIVELY(accountwarehouse, "richtext_3")
    richtext_3:ShowWindow(1)
    local DepositSkin = accountwarehouse:GetChildRecursively("DepositSkin")
    AUTO_CAST(DepositSkin)
    DepositSkin:Resize(DepositSkin:GetWidth(), 35)
    local buttons = {"cancel", "m1", "m5", "m10", "m50", "m100", "allout", "allin"}
    for _, name in ipairs(buttons) do
        DepositSkin:RemoveChild(name)
    end
    local gbox = GET_CHILD_RECURSIVELY(accountwarehouse, "gbox")
    DESTROY_CHILD_BYNAME(gbox, "search_edit")
    DESTROY_CHILD_BYNAME(gbox, "awsetting")
    DESTROY_CHILD_BYNAME(gbox, "help")
    DESTROY_CHILD_BYNAME(gbox, "leave")
    DESTROY_CHILD_BYNAME(gbox, "display_change")
    DESTROY_CHILD_BYNAME(gbox, "take")
    DESTROY_CHILD_BYNAME(gbox, "count_text")
    DESTROY_CHILD_BYNAME(gbox, "awclose")
    DESTROY_CHILD_BYNAME(gbox, "name_text")
    INVENTORY_SET_CUSTOM_RBTNDOWN("ACCOUNT_WAREHOUSE_INV_RBTN")
end

function another_warehouse_OPEN_DLG_ACCOUNTWAREHOUSE()
    if g.settings.another_warehouse.use == 0 then
        return
    end
    local monstercardslot = ui.GetFrame("monstercardslot")
    monstercardslot:SetLayerLevel(98)
    local accountwarehouse = ui.GetFrame("accountwarehouse")
    local accountwarehousefilter = GET_CHILD_RECURSIVELY(accountwarehouse, "accountwarehousefilter")
    accountwarehousefilter:ShowWindow(0)
    local accountwarehouse = ui.GetFrame("accountwarehouse")
    local accountwarehouse_tab = GET_CHILD_RECURSIVELY(accountwarehouse, "accountwarehouse_tab")
    accountwarehouse_tab:ShowWindow(0)
    local richtext_1 = GET_CHILD_RECURSIVELY(accountwarehouse, "richtext_1")
    richtext_1:ShowWindow(0)
    local itemcnt = GET_CHILD_RECURSIVELY(accountwarehouse, "itemcnt")
    itemcnt:ShowWindow(0)
    local slotgbox = GET_CHILD_RECURSIVELY(accountwarehouse, "slotgbox")
    slotgbox:ShowWindow(0)
    local richtext_3 = GET_CHILD_RECURSIVELY(accountwarehouse, "richtext_3")
    richtext_3:ShowWindow(0)
    local gbox = GET_CHILD_RECURSIVELY(accountwarehouse, "gbox")
    gbox:RemoveChild("search_edit")
    local search_edit = gbox:CreateOrGetControl("edit", "search_edit", 0, 0, 295, 35)
    AUTO_CAST(search_edit)
    search_edit:SetFontName("white_18_ol")
    search_edit:SetTextAlign("left", "center")
    search_edit:SetSkinName("inventory_serch")
    local margin = search_edit:GetMargin()
    search_edit:SetMargin(margin.left + 115, margin.top + 20, margin.right, margin.bottom)
    search_edit:SetEventScript(ui.ENTERKEY, "another_warehouse_search")
    local search_btn = search_edit:CreateOrGetControl("button", "search_btn", 0, 0, 60, 38)
    AUTO_CAST(search_btn)
    search_btn:SetImage("inven_s")
    search_btn:SetGravity(ui.RIGHT, ui.TOP)
    search_btn:SetEventScript(ui.LBUTTONUP, "another_warehouse_search")
    local awsetting = gbox:CreateOrGetControl("button", "awsetting", 0, 0, 30, 43)
    AUTO_CAST(awsetting)
    awsetting:SetText("{img config_button_normal 27 27}")
    awsetting:SetEventScript(ui.LBUTTONUP, "another_warehouse_setting_frame_init")
    awsetting:SetMargin(145, 60, 0, 0)
    awsetting:SetSkinName("None")
    awsetting:SetTextTooltip(g.lang == "Japanese" and "{ol}[AWH]{nl}自動倉庫設定" or
                                 "{ol}[AWH]{nl}Automatic warehousing setup")
    local help = gbox:CreateOrGetControl('button', "help", 0, 0, 30, 30)
    AUTO_CAST(help);
    help:SetText("{ol}{img question_mark 20 20}")
    help:SetMargin(115, 67, 0, 0)
    help:SetTextTooltip("{ol}[AWH] HELP")
    help:SetSkinName("test_pvp_btn")
    help:SetEventScript(ui.LBUTTONUP, "another_warehouse_help")
    local leave = gbox:CreateOrGetControl('checkbox', "leave", 0, 0, 30, 30)
    AUTO_CAST(leave);
    leave:SetCheck(g.awh_settings.etc.leave_item)
    leave:SetMargin(180, 67, 0, 0)
    leave:SetEventScript(ui.LBUTTONUP, "another_warehouse_setting_check")
    local tooltip_text = g.lang == "Japanese" and "{ol}チェックすると倉庫に1個残します" or
                             "{ol}Check leaves one in the warehouse"
    leave:SetTextTooltip(tooltip_text)
    local display_change = gbox:CreateOrGetControl('checkbox', "display_change", 0, 0, 30, 30)
    AUTO_CAST(display_change);
    display_change:SetCheck(g.awh_settings.etc.display_change or 0)
    display_change:SetMargin(215, 67, 0, 0)
    display_change:SetEventScript(ui.LBUTTONUP, "another_warehouse_setting_check")
    local tooltip_text = g.lang == "Japanese" and "{ol}チェックすると表示切替" or
                             "{ol}Check to switch display"
    display_change:SetTextTooltip(tooltip_text)
    display_change:ShowWindow(1)
    local take = gbox:CreateOrGetControl("button", "take", 10, 0, 100, 43)
    AUTO_CAST(take)
    take:SetText("{@st66b}TAKE SET")
    take:SetEventScript(ui.LBUTTONUP, "another_warehouse_take_context")
    take:SetEventScript(ui.RBUTTONUP, "another_warehouse_setting_context")
    take:SetMargin(310, 60, 0, 0)
    take:SetSkinName("test_pvp_btn")
    take:SetTextTooltip(g.lang == "Japanese" and
                            "{ol}左クリック: 倉庫からセットで搬出します{nl}右クリック: セット設定を呼び出します" or
                            "{ol}left-click: Move set from warehouse{nl}Right-click: Call up set settings")
    local max_count = another_warehouse_get_maxcount()
    local item_count = another_warehouse_item_count()
    local count_text = gbox:CreateOrGetControl("richtext", "count_text", 0, 0, 200, 24)
    AUTO_CAST(count_text)
    count_text:SetMargin(420, 73, 0, 0)
    count_text:SetText("{@st42}" .. item_count .. "/" .. max_count .. "{/}")
    count_text:SetFontName("white_16_ol")
    local awclose = gbox:CreateOrGetControl("button", "awclose", 10, 0, 100, 43)
    AUTO_CAST(awclose)
    awclose:SetText("{@st66b}AW CLOSE")
    awclose:SetEventScript(ui.LBUTTONUP, "another_warehouse_frame_close")
    awclose:SetMargin(10, 60, 0, 0)
    awclose:SetSkinName("test_pvp_btn")
    local name_text = gbox:CreateOrGetControl("richtext", "name_text", 15, 0, 200, 24)
    AUTO_CAST(name_text)
    name_text:SetMargin(10, 10, 0, 0)
    name_text:SetText("{#000000}{s18}" .. g.login_name .. "{/}")
    another_warehouse_frame_over_lap()
    another_warehouse_money_input_btn(accountwarehouse)
end

function another_warehouse_money_input_btn(accountwarehouse)
    local DepositSkin = accountwarehouse:GetChildRecursively("DepositSkin")
    AUTO_CAST(DepositSkin)
    DepositSkin:Resize(DepositSkin:GetWidth(), 45)
    local moneyInput = accountwarehouse:GetChildRecursively("moneyInput")
    AUTO_CAST(moneyInput)
    moneyInput:SetText("0")
    local buttons = {{
        name = "cancel",
        text = "C",
        val = 0
    }, {
        name = "m1",
        text = "1M",
        val = 1000000
    }, {
        name = "m5",
        text = "5M",
        val = 5000000
    }, {
        name = "m10",
        text = "10M",
        val = 10000000
    }, {
        name = "m50",
        text = "50M",
        val = 50000000
    }, {
        name = "m100",
        text = "100M",
        val = 100000000
    }, {
        name = "allout",
        text = "{img chul_arrow 10 10}ALL",
        val = nil
    }, {
        name = "allin",
        text = "{img in_arrow 10 10}ALL",
        val = nil
    }}
    local text_style = "{@st66b}{s12}"
    for i, data in ipairs(buttons) do
        local x_offset = i * 50
        local btn = DepositSkin:CreateOrGetControl("button", data.name, DepositSkin:GetWidth() - x_offset,
            DepositSkin:GetHeight() - 23, 50, 25)
        AUTO_CAST(btn)
        btn:SetText(text_style .. data.text)
        btn:SetSkinName("test_pvp_btn")
        btn:SetEventScript(ui.LBUTTONUP, "another_warehouse_money_input_lbtn")
        if data.val ~= nil then
            btn:SetEventScriptArgNumber(ui.LBUTTONUP, data.val)
            btn:SetEventScript(ui.RBUTTONUP, "another_warehouse_money_input_rbtn")
            btn:SetEventScriptArgNumber(ui.RBUTTONUP, data.val)
        end
    end
end

function another_warehouse_money_input_lbtn(parent, ctrl, str, num)
    local accountwarehouse = ctrl:GetTopParentFrame()
    local moneyInput = accountwarehouse:GetChildRecursively("moneyInput")
    AUTO_CAST(moneyInput)
    local handle = accountwarehouse:GetUserIValue('HANDLE')
    if ctrl:GetName() == "allout" then
        local item_list = session.GetEtcItemList(IT_ACCOUNT_WAREHOUSE)
        local guid_list = item_list:GetGuidList()
        local sorted_guid_list = item_list:GetSortedGuidList()
        local sorted_cnt = sorted_guid_list:Count()
        local iesid
        for i = 0, sorted_cnt - 1 do
            local guid = sorted_guid_list:Get(i)
            local inv_item = item_list:GetItemByGuid(guid)
            local obj = GetIES(inv_item:GetObject());
            if obj.ClassName == MONEY_NAME then
                moneyInput:SetText(GET_COMMAED_STRING(inv_item:GetAmountStr()))
                return
            end
        end
        moneyInput:SetText("0")
    elseif ctrl:GetName() == "allin" then
        local silver = session.GetInvItemByName(MONEY_NAME)
        if silver then
            moneyInput:SetText(GET_COMMAED_STRING(silver:GetAmountStr()))
        else
            moneyInput:SetText("0")
        end
    elseif ctrl:GetName() == "cancel" then
        moneyInput:SetText("0")
    else
        local current_val_str = string.gsub(moneyInput:GetText(), ",", "")
        local current_val = tonumber(current_val_str) or 0
        moneyInput:SetText(GET_COMMAED_STRING(SumForBigNumberInt64(current_val, "+" .. num)))
    end
end

function another_warehouse_money_input_rbtn(parent, ctrl, str, num)
    local accountwarehouse = ctrl:GetTopParentFrame()
    local moneyInput = accountwarehouse:GetChildRecursively("moneyInput")
    AUTO_CAST(moneyInput)
    if ctrl:GetName() == "cancel" then
        moneyInput:SetText("0")
        return
    end
    local current_val_str = string.gsub(moneyInput:GetText(), ",", "")
    local current_val = tonumber(current_val_str) or 0
    if (current_val - num) > 0 then
        moneyInput:SetText(GET_COMMAED_STRING(SumForBigNumberInt64(current_val, "-" .. num)))
    else
        moneyInput:SetText("0")
    end
end

function another_warehouse_frame_over_lap()
    local awh = ui.CreateNewFrame("notice_on_pc", addon_name_lower .. "awh", 0, 0, 670, 570)
    AUTO_CAST(awh)
    awh:SetGravity(ui.LEFT, ui.TOP)
    awh:MoveFrame(0, 0)
    awh:SetOffset(0, 205)
    awh:SetSkinName("None")
    awh:EnableMove(0)
    awh:EnableHittestFrame(1)
    awh:SetLayerLevel(97)
    awh:RemoveAllChild()
    local gb = awh:CreateOrGetControl("groupbox", "gb", 45, 0, 0, 0)
    AUTO_CAST(gb)
    gb:EnableScrollBar(1)
    gb:SetSkinName("test_frame_midle")
    awh:Resize(670, 570)
    gb:Resize(613, 560)
    awh:ShowWindow(1)
    local inventory = ui.GetFrame("inventory")
    INVENTORY_SET_CUSTOM_RBTNDOWN("another_warehouse_inv_rbtn")
    SET_INV_LBTN_FUNC(inventory, "another_warehouse_inv_lbtn")
    another_warehouse_tab_change(awh, gb, "", 0)
    another_warehouse_auto_func_start(awh)
end

function another_warehouse_tab_change(awh, ctrl, search_text, index)
    local tab_index = awh:GetUserIValue("TAB_INDEX")
    if tab_index ~= index then
        local accountwarehouse = ui.GetFrame("accountwarehouse")
        local search_edit = GET_CHILD_RECURSIVELY(accountwarehouse, "search_edit")
        search_edit:SetText("")
    end
    local tab_tbl = {"inventory_main", "inventory_equip", "inventory_supplies", "inventory_recipe", "inventory_card",
                     "inventory_material", "inventory_gem", "inventory_premium", "inventory_housing", "alchemy_item_tab"}
    for i, image in ipairs(tab_tbl) do
        local tab = awh:CreateOrGetControl("picture", "tab" .. image, 5, (i - 1) * 55, 40, 60)
        AUTO_CAST(tab)
        tab:SetClickSound("inven_arrange")
        tab:SetEventScript(ui.LBUTTONDOWN, "another_warehouse_tab_change")
        tab:SetEventScriptArgNumber(ui.LBUTTONDOWN, i)
        if i == index then
            tab:SetImage(image .. "_clicked")
            awh:SetUserValue("TAB_INDEX", index)
        else
            tab:SetImage(image)
        end
        tab:SetEnableStretch(1)
    end
    if index == 0 then
        local tab = GET_CHILD(awh, "tab" .. tab_tbl[1])
        tab:SetImage(tab_tbl[1] .. "_clicked")
        awh:SetUserValue("TAB_INDEX", 1)
    end
    local gb = GET_CHILD(awh, "gb")
    AUTO_CAST(gb)
    gb:RemoveAllChild()
    another_warehouse_frame_update(awh, gb, search_text, index)
end

function another_warehouse_frame_update(awh, gb, search_text, index)
    local tree = gb:CreateOrGetControl("tree", "inventory_tree", 5, 10, 0, 0)
    AUTO_CAST(tree)
    tree:Clear()
    tree:InvalidateTree()
    tree:EnableDrawFrame(false)
    tree:EnableDrawTreeLine(false)
    tree:SetFitToChild(true, 20) -- 下の余白
    tree:SetFontName("white_20_ol")
    tree:SetTabWidth("15")
    tree:Resize(600, 0)
    local item_list = session.GetEtcItemList(IT_ACCOUNT_WAREHOUSE)
    local sorted_guid_list = item_list:GetSortedGuidList()
    local warehouse_item_list = {}
    local group_counts = {}
    local slotset_counts = {}
    local tab_filter_map = {nil, {
        ["EquipGroup"] = true
    }, {
        ["NonEquipGroup"] = true,
        ["Cube"] = true
    }, {
        ["Recipe"] = true
    }, {
        ["Card"] = true
    }, {
        ["Material"] = true
    }, {
        ["Gem"] = true
    }, {
        ["Premium"] = true
    }, {
        ["Housing"] = true
    }, {
        ["Ancient"] = true,
        ["HiiddenAbility"] = true
    }}
    local current_filter = tab_filter_map[index]
    for i = 0, sorted_guid_list:Count() - 1 do
        local warehouse_item = item_list:GetItemByGuid(sorted_guid_list:Get(i))
        if warehouse_item then
            local item_cls = GetIES(warehouse_item:GetObject())
            local baseid_cls = INV_GET_INVEN_BASEIDCLS_BY_ITEMGUID(warehouse_item:GetIESID())
            if baseid_cls then
                local type_str = GET_INVENTORY_TREEGROUP(baseid_cls)
                if type_str ~= 'Quest' and baseid_cls.ClassName ~= 'Unused' then
                    local make_slot = another_warehouse_check_search_and_filter(warehouse_item, item_cls, search_text)
                    if make_slot and warehouse_item.count > 0 then
                        local group_name = baseid_cls.TreeGroup
                        local is_visible = (current_filter == nil) or (current_filter[group_name] == true)
                        if is_visible then
                            table.insert(warehouse_item_list, warehouse_item)
                            local group_name = baseid_cls.TreeGroup
                            group_counts[group_name] = (group_counts[group_name] or 0) + 1
                            local className = baseid_cls.ClassName
                            if baseid_cls.MergedTreeTitle ~= "NO" then
                                className = baseid_cls.MergedTreeTitle
                            end
                            local slotset_name = 'sset_' .. className
                            slotset_counts[slotset_name] = (slotset_counts[slotset_name] or 0) + 1
                        end
                    end
                end
            end
        end
    end
    table.sort(warehouse_item_list, INVENTORY_SORT_BY_NAME)
    local created_groups = {}
    local created_slotsets = {}
    local group_order = {"Premium", "EquipGroup", "NonEquipGroup", "Cube", "Gem", "Card", "Recipe", "Material",
                         "HiiddenAbility", "Ancient"}
    local group_caption_map = {}
    local baseid_list, cnt = GetClassList("inven_baseid")
    for i = 0, cnt - 1 do
        local cls = GetClassByIndexFromList(baseid_list, i)
        if cls.TreeGroup ~= "None" then
            group_caption_map[cls.TreeGroup] = cls.TreeGroupCaption
        end
    end
    for _, group_name in ipairs(group_order) do
        local count = group_counts[group_name]
        local is_visible = (current_filter == nil) or (current_filter[group_name] == true)
        if is_visible and count and count > 0 then
            local caption = group_caption_map[group_name]
            if caption then
                local title_with_count = string.format("%s (%d)", caption, count)
                local tree_group = tree:Add(title_with_count, group_name)
                created_groups[group_name] = tree_group
            end
        end
    end
    for i = 0, cnt - 1 do
        local baseid_cls = GetClassByIndexFromList(baseid_list, i)
        local className = baseid_cls.ClassName
        if baseid_cls.MergedTreeTitle ~= "NO" then
            className = baseid_cls.MergedTreeTitle
        end
        local slotset_name = 'sset_' .. className
        local count = slotset_counts[slotset_name]
        local tree_group_name = baseid_cls.TreeGroup
        local is_visible = (current_filter == nil) or (current_filter[tree_group_name] == true)
        if is_visible and count and count > 0 and not created_slotsets[slotset_name] then
            local tree_group = created_groups[tree_group_name]
            if not tree_group then
                local caption = baseid_cls.TreeGroupCaption
                local group_count = group_counts[tree_group_name] or 0
                local title_with_count = string.format("%s (%d)", caption, group_count)
                tree_group = tree:Add(title_with_count, tree_group_name)
                created_groups[tree_group_name] = tree_group
            end
            local margin_height = 5
            local margin_name = "margin_top_" .. slotset_name
            local margin = tree:CreateOrGetControl('richtext', margin_name, 0, 0, 400, margin_height)
            AUTO_CAST(margin)
            margin:EnableResizeByText(0)
            margin:SetText("")
            tree:Add(tree_group, margin, margin_name)
            local slotset_title_value = slotset_name .. "_title"
            local title_with_count = string.format("{s18}%s (%d)", baseid_cls.TreeSSetTitle, count)
            local slotset_node = tree:Add(tree_group, title_with_count, slotset_title_value)
            local new_slot_set = another_warehouse_make_inven_slotset(tree, slotset_name)
            tree:Add(slotset_node, new_slot_set, slotset_name)
            created_slotsets[slotset_name] = new_slot_set

        end
    end
    for _, inv_item in ipairs(warehouse_item_list) do
        local item_cls = GetIES(inv_item:GetObject())
        local baseid_cls = INV_GET_INVEN_BASEIDCLS_BY_ITEMGUID(inv_item:GetIESID())
        local className = baseid_cls.ClassName
        if baseid_cls.MergedTreeTitle ~= "NO" then
            className = baseid_cls.MergedTreeTitle
        end
        local slotset_name = 'sset_' .. className
        local new_slot_set = created_slotsets[slotset_name]
        if new_slot_set then
            AUTO_CAST(new_slot_set)
            local slot_count = new_slot_set:GetSlotCount()
            local count = new_slot_set:GetUserIValue("SLOT_ITEM_COUNT")
            while slot_count <= count do
                new_slot_set:ExpandRow()
                slot_count = new_slot_set:GetSlotCount()
            end
            local slot = new_slot_set:GetSlotByIndex(count)
            count = count + 1
            new_slot_set:SetUserValue("SLOT_ITEM_COUNT", count)
            slot:ShowWindow(1)
            another_warehouse_insert_item_to_tree(gb, tree, slot, inv_item, item_cls, slotset_name, baseid_cls)
        end
    end
    for _, slotset in pairs(created_slotsets) do
        local row = math.ceil(slotset:GetSlotCount() / slotset:GetCol())
        local height = row * 54
        slotset:Resize(slotset:GetWidth(), height)
    end
    local bottom_margin = 10 -- 隙間の高
    for _, group_name in ipairs(group_order) do
        local tree_group = created_groups[group_name]
        if tree_group and tree:GetChildCount(tree_group) > 0 then
            local margin_name = 'margin_' .. group_name
            local margin = tree:CreateOrGetControl('richtext', margin_name, 0, 0, 400, bottom_margin)
            AUTO_CAST(margin)
            margin:EnableResizeByText(0)
            margin:SetText("")
            tree:Add(tree_group, margin, margin_name)
        end
    end
    tree:OpenNodeAll()
    local max_count = another_warehouse_get_maxcount()
    local item_count = another_warehouse_item_count()
    local accountwarehouse = ui.GetFrame("accountwarehouse")
    local count_text = GET_CHILD_RECURSIVELY(accountwarehouse, "count_text")
    AUTO_CAST(count_text)
    count_text:SetText("{@st42}" .. item_count .. "/" .. max_count .. "{/}")
    count_text:SetFontName("white_16_ol")
    awh:RunUpdateScript("another_warehouse_set_scroll_pos")
end

function another_warehouse_set_scroll_pos(awh)
    awh:StopUpdateScript("another_warehouse_set_scroll_pos")
    local saved_pos = awh:GetUserIValue("SCROLL_POS")
    local gb = GET_CHILD(awh, "gb")
    AUTO_CAST(gb)
    gb:SetScrollPos(saved_pos)
    gb:InvalidateScrollBar()
    return 0
end

function another_warehouse_make_inven_slotset(tree, name)
    local slotset = tree:CreateOrGetControl('slotset', name, 0, 0, 0, 0)
    AUTO_CAST(slotset)
    slotset:EnablePop(0)
    slotset:EnableDrag(0)
    slotset:EnableDrop(0)
    slotset:SetMaxSelectionCount(999)
    slotset:SetSlotSize(54, 54)
    slotset:SetColRow(10, 1)
    slotset:SetSpc(0, 0)
    slotset:SetSkinName('invenslot')
    slotset:EnableSelection(0)
    slotset:CreateSlots()
    return slotset
end

function another_warehouse_insert_item_to_tree(gb, tree, slot, inv_item, item_cls, slotset_name, baseid_cls)
    local slot_set = GET_CHILD_RECURSIVELY(gb, slotset_name)
    UPDATE_INVENTORY_SLOT(slot, inv_item, item_cls)
    slot:SetSkinName('invenslot2')
    local item_cls = GetIES(inv_item:GetObject())
    local iconImg = GET_ITEM_ICON_IMAGE(item_cls)
    if geItemTable.IsStack(item_cls.ClassID) == 1 and another_warehouse_is_stack_new_item(item_cls.ClassID) then
        slot:SetHeaderImage('new_inventory_icon')
    elseif geItemTable.IsStack(item_cls.ClassID) == 0 and
        another_warehouse_is_stack_new_item(item_cls.ClassID .. "_" .. inv_item:GetIESID()) then
        slot:SetHeaderImage('new_inventory_icon')
    else
        slot:SetHeaderImage('None')
    end
    SET_SLOT_IMG(slot, iconImg)
    SET_SLOT_COUNT(slot, inv_item.count)
    SET_SLOT_STYLESET(slot, item_cls)
    SET_SLOT_IESID(slot, inv_item:GetIESID())
    SET_SLOT_ITEM_TEXT_USE_INVCOUNT(slot, inv_item, item_cls, nil)
    slot:SetMaxSelectCount(inv_item.count);
    local icon = slot:GetIcon()
    icon:SetTooltipArg("accountwarehouse", inv_item.type, inv_item:GetIESID())
    SET_ITEM_TOOLTIP_TYPE(icon, item_cls.ClassID, item_cls, "accountwarehouse")
    SET_SLOT_ICOR_CATEGORY(slot, item_cls)
    if inv_item.hasLifeTime == true or TryGetProp(item_cls, 'ExpireDateTime', 'None') ~= 'None' then
        ICON_SET_ITEM_REMAIN_LIFETIME(icon, IT_ACCOUNT_WAREHOUSE)
        slot:SetFrontImage('clock_inven')
    else
        CLEAR_ICON_REMAIN_LIFETIME(slot, icon)
    end
    slot:SetEventScript(ui.LBUTTONUP, "another_warehouse_on_lbutton") -- inv_item:GetIESID()
    slot:SetEventScriptArgString(ui.LBUTTONUP, inv_item:GetIESID())
    slot:SetEventScript(ui.RBUTTONUP, "another_warehouse_on_rbutton")
    slot:SetEventScriptArgString(ui.RBUTTONUP, inv_item:GetIESID())
    if g.awh_settings.etc.display_change == 1 then
        if baseid_cls.TreeGroup == "Recipe" then
            local recipe_cls = GetClass('Recipe', item_cls.ClassName);
            if recipe_cls ~= nil then
                local taget_item = GetClass("Item", recipe_cls.TargetItem);
                if taget_item then
                    local image = GET_ITEM_ICON_IMAGE(taget_item)
                    local recipe_pic = slot:CreateOrGetControl('picture', 'recipe_pic' .. inv_item:GetIESID(), 0, 0, 25,
                        25)
                    AUTO_CAST(recipe_pic)
                    recipe_pic:SetEnableStretch(1)
                    recipe_pic:SetGravity(ui.LEFT, ui.TOP)
                    recipe_pic:SetImage(image)
                    recipe_pic:SetTooltipArg("accountwarehouse", inv_item.type, inv_item:GetIESID())
                    SET_ITEM_TOOLTIP_TYPE(recipe_pic, taget_item.ClassID, taget_item, "accountwarehouse")
                end
            end
        end
        if string.find(baseid_cls.ClassName, "Card") and not string.find(baseid_cls.ClassName, "Summon") and
            not string.find(baseid_cls.ClassName, "CardAddExp") then
            local image = TryGetProp(item_cls, "TooltipImage", "None")
            if image ~= "None" then
                icon:Set(image, 'Item', inv_item.type, inv_item.invIndex, inv_item:GetIESID(), inv_item.count)
            end
        end
        if baseid_cls.ClassName == "Gem_GemSkill" then
            for i = 1, 4 do
                if TryGetProp(item_cls, 'RandomOption_' .. i, 'None') ~= 'None' and
                    TryGetProp(item_cls, 'RandomOptionValue_' .. i, 0) > 0 then
                    local star_pic =
                        slot:CreateOrGetControl('richtext', 'star_pic' .. inv_item:GetIESID(), 0, 0, 18, 18)
                    star_pic:SetText("{img star_mark 18 18}")
                    star_pic:SetGravity(ui.RIGHT, ui.TOP);
                end
            end
            local skill_cls = GetClass("Skill", TryGetProp(item_cls, 'SkillName', 'None'))
            if skill_cls then
                local image = "icon_" .. GET_ITEM_ICON_IMAGE(skill_cls)
                icon:Set(image, 'Item', inv_item.type, inv_item.invIndex, inv_item:GetIESID(), inv_item.count)
                local skill_pic = slot:CreateOrGetControl('picture', 'skill_pic' .. inv_item:GetIESID(), 0, 0, 35, 35)
                AUTO_CAST(skill_pic)
                local image = GET_ITEM_ICON_IMAGE(item_cls)
                skill_pic:SetEnableStretch(1)
                skill_pic:SetGravity(ui.LEFT, ui.TOP)
                skill_pic:SetImage(image)
            end
        elseif baseid_cls.ClassName == "Gem_High_Color" then
            local cls_name = item_cls.ClassName
            if string.find(cls_name, "540") then
                slot:SetSkinName("invenslot_pic_goddess")
            elseif string.find(cls_name, "520") then
                slot:SetSkinName("invenslot_legend")
            elseif string.find(cls_name, "500") then
                slot:SetSkinName("invenslot_unique")
            elseif string.find(cls_name, "480") then
                slot:SetSkinName("invenslot_rare")
            else
                slot:SetSkinName("invenslot_nomal")
            end
        end
        if string.find(baseid_cls.ClassName, "OPTMisc_GoddessIcor") then
            local cls_name = item_cls.ClassName
            local is_special = string.find(cls_name, "EP17") or string.find(cls_name, "Weapon2") or
                                   string.find(cls_name, "Armor2")
            if not is_special then
                slot:SetSkinName("invenslot_rare")
            end
        elseif string.find(baseid_cls.ClassName, "Armor") then
            local cls_name = item_cls.ClassName
            local is_special = string.find(cls_name, "EP17") or
                                   (string.find(cls_name, "EP16") and string.find(cls_name, "high")) or
                                   (string.find(cls_name, "EP13") and string.find(cls_name, "high2"))
            if not is_special and (string.find(cls_name, "belt") or string.find(cls_name, "shoulder")) then
                slot:SetSkinName("invenslot_rare")
            end
        end
    end
end

function another_warehouse_is_stack_new_item(class_id)
    for k, v in pairs(g.awh_new_stack_add_item) do
        if v == class_id then
            return true
        end
    end
    return false
end

function another_warehouse_check_search_and_filter(inv_item, item_cls, search_text)
    if search_text == "" then
        return true
    end
    local temp_cap = string.lower(search_text)
    local item_name = string.lower(dictionary.ReplaceDicIDInCompStr(item_cls.Name))
    if string.find(item_name, temp_cap) then
        return true
    end
    local prefix_class_name = TryGetProp(item_cls, "LegendPrefix")
    if prefix_class_name and prefix_class_name ~= "None" then
        local prefix_cls = GetClass('LegendSetItem', prefix_class_name)
        if prefix_cls then
            local prefix_name = string.lower(dictionary.ReplaceDicIDInCompStr(prefix_cls.Name))
            if string.find(prefix_name .. " " .. item_name, temp_cap) then
                return true
            end
        end
    end
    if TryGetProp(item_cls, 'GroupName', 'None') == 'Earring' then
        local max_option_count = shared_item_earring.get_max_special_option_count(TryGetProp(item_cls, 'UseLv', 1))
        for i = 1, max_option_count do
            local option_name = 'EarringSpecialOption_' .. i
            local job_id = TryGetProp(item_cls, option_name, 'None')
            if job_id ~= 'None' then
                local job_cls = GetClass('Job', job_id)
                if job_cls and string.find(string.lower(dictionary.ReplaceDicIDInCompStr(job_cls.Name)), temp_cap) then
                    return true
                end
            end
        end
    end
    if TryGetProp(item_cls, 'GroupName', 'None') == 'Icor' then
        local item = GetIES(inv_item:GetObject())
        for i = 1, 5 do
            local option = TryGetProp(item, 'RandomOption_' .. i, 'None')
            if option and option ~= "None" and
                string.find(string.lower(dictionary.ReplaceDicIDInCompStr(ClMsg(option))), temp_cap) then
                return true
            end
        end
    end
    return false
end

function another_warehouse_get_maxcount()
    local acc_obj = GetMyAccountObj()
    local token_bonus = 0
    local my_handle = session.GetMyHandle()
    local buff = info.GetBuff(my_handle, 70002)
    if buff then
        token_bonus = ADDITIONAL_SLOT_COUNT_BY_TOKEN + 280
    end
    local max_cnt = acc_obj.BasicAccountWarehouseSlotCount + acc_obj.MaxAccountWarehouseCount +
                        acc_obj.AccountWareHouseExtend + acc_obj.AccountWareHouseExtendByItem + token_bonus
    return max_cnt
end
-- 900011
function another_warehouse_item_count()
    local item_list = session.GetEtcItemList(IT_ACCOUNT_WAREHOUSE)
    local guid_list = item_list:GetSortedGuidList()
    local cnt = item_list:Count()
    local return_cnt = 0
    for i = 0, cnt - 1 do
        local guid = guid_list:Get(i);
        local inv_item = item_list:GetItemByGuid(guid)
        if inv_item then
            local item_obj = GetIES(inv_item:GetObject())
            if item_obj.ClassID ~= 900011 then -- 900011 Vis シルバー
                return_cnt = return_cnt + 1
            end
        end
    end
    return return_cnt
end

function another_warehouse_get_goal_index()
    local acc_obj = GetMyAccountObj()
    local base_count = acc_obj.BasicAccountWarehouseSlotCount + acc_obj.MaxAccountWarehouseCount +
                           acc_obj.AccountWareHouseExtend + acc_obj.AccountWareHouseExtendByItem +
                           ADDITIONAL_SLOT_COUNT_BY_TOKEN
    local tab_index = {4, 3, 2, 1, 0}
    local accountwarehouse = ui.GetFrame('accountwarehouse')
    local itemcnt = GET_CHILD_RECURSIVELY(accountwarehouse, "itemcnt")
    local tab = GET_CHILD(accountwarehouse, "accountwarehouse_tab")
    local slotset = GET_CHILD_RECURSIVELY(accountwarehouse, "slotset")
    for index = 1, #tab_index do
        local i = tab_index[index]
        tab:SelectTab(i)
        if i > 0 then
            local num_str = string.match(itemcnt:GetText(), "{@st42}(%d+)/")
            local left = tonumber(num_str)
            if left < 70 then
                return ((i - 1) * 70) + base_count + left + 1
            end
        else
            for j = 1, base_count do
                local slot = slotset:GetSlotByIndex(j)
                AUTO_CAST(slot)
                if slot:GetIcon() == nil then
                    return j
                end
            end
        end
    end
end

function another_warehouse_check_valid(inv_item)
    local item_count = another_warehouse_item_count()
    local max_count = another_warehouse_get_maxcount()
    if max_count <= item_count then
        ui.SysMsg(ClMsg('CannotPutBecauseMaxSlot'))
        return false
    end
    if true == inv_item.isLockState then
        ui.SysMsg(ClMsg("MaterialItemIsLock"))
        return false
    end
    local obj = GetIES(inv_item:GetObject())
    local item_cls = GetClassByType("Item", obj.ClassID)
    if item_cls.ItemType == 'Quest' then
        ui.MsgBox(ScpArgMsg("IT_ISNT_REINFORCEABLE_ITEM"))
        return false
    end
    local enable_team_trade = TryGetProp(item_cls, "TeamTrade")
    if enable_team_trade and enable_team_trade == "NO" then
        ui.SysMsg(ClMsg("ItemIsNotTradable"))
        return false
    end
    return true
end

function another_warehouse_search(frame, ctrl, str, num)
    local awh = ui.GetFrame(addon_name_lower .. "awh")
    local gb = GET_CHILD(awh, "gb")
    AUTO_CAST(gb)
    local search_text = ctrl:GetText()
    local tab = GET_CHILD(awh, "tab" .. "inventory_main")
    another_warehouse_tab_change(awh, tab, search_text, 1)
end

function another_warehouse_inv_lbtn(frame, inv_item, dumm)
    local iesid = inv_item:GetIESID()
    if keyboard.IsKeyPressed("LSHIFT") == 1 then
        local count = math.min(10, inv_item.count)
        another_warehouse_putitem(inv_item, iesid, count)
    else
        another_warehouse_putitem(inv_item, iesid, 1)
    end
end

function another_warehouse_inv_rbtn(item_obj, slot)
    local icon = slot:GetIcon()
    local icon_info = icon:GetInfo()
    local iesid = icon_info:GetIESID()
    local inv_item = GET_PC_ITEM_BY_GUID(iesid)
    if not inv_item then
        return
    end
    if keyboard.IsKeyPressed("LSHIFT") == 1 then
        local accountwarehouse = ui.GetFrame("accountwarehouse")
        local obj = GetIES(inv_item:GetObject())
        local max_cnt = inv_item.count
        local belonging_count = TryGetProp(obj, 'BelongingCount', 0)
        if belonging_count > 0 then
            max_cnt = inv_item.count - obj.BelongingCount
            if max_cnt <= 0 then
                max_cnt = 0
            end
        end
        if inv_item.count > 1 or geItemTable.IsStack(obj.ClassID) == 1 then
            INPUT_NUMBER_BOX(accountwarehouse, ScpArgMsg("InputCount"), "EXEC_PUT_ITEM_TO_ACCOUNT_WAREHOUSE", max_cnt,
                1, max_cnt, nil, iesid)
        else
            another_warehouse_putitem(inv_item, iesid, inv_item.count)
        end
    else
        another_warehouse_putitem(inv_item, iesid, inv_item.count)
    end
end

function another_warehouse_on_lbutton(parent, slot, iesid, num)
    local accountwarehouse = ui.GetFrame("accountwarehouse")
    local inv_item = session.GetEtcItemByGuid(IT_ACCOUNT_WAREHOUSE, iesid)
    local obj = GetIES(inv_item:GetObject())
    if keyboard.IsKeyPressed("LSHIFT") == 1 then
        local count = math.min(10, inv_item.count)
        another_warehouse_takeitem(accountwarehouse, iesid, count)
    else
        another_warehouse_takeitem(accountwarehouse, iesid, 1)
    end
end

function another_warehouse_on_rbutton(frame, slot, iesid, argnum)
    local awh_setting = ui.GetFrame(addon_name_lower .. "awh_setting")
    if awh_setting and awh_setting:IsVisible() == 1 then
        AUTO_CAST(awh_setting)
        local inv_item = session.GetEtcItemByGuid(IT_ACCOUNT_WAREHOUSE, iesid)
        if not inv_item then
            return
        end
        local obj = GetIES(inv_item:GetObject())
        local cls_id = obj.ClassID
        local item_cls = GetClassByType("Item", cls_id)
        if inv_item.isLockState then
            ui.SysMsg(ClMsg("MaterialItemIsLock"))
            return
        end
        if item_cls.ItemType == 'Quest' then
            ui.MsgBox(ScpArgMsg("IT_ISNT_REINFORCEABLE_ITEM"));
            return
        end
        local enable_team_trade = TryGetProp(item_cls, "TeamTrade")
        if enable_team_trade and enable_team_trade == "NO" then
            ui.SysMsg(ClMsg("ItemIsNotTradable"))
            return
        end
        local belonging_count = TryGetProp(obj, 'BelongingCount', 0)
        if belonging_count > 0 and belonging_count >= inv_item.count then
            ui.SysMsg(ClMsg("ItemIsNotTradable"))
            return
        end
        if TryGetProp(obj, 'CharacterBelonging', 0) == 1 then
            ui.SysMsg(ClMsg("ItemIsNotTradable"))
            return
        end
        local items = {} -- 'team_slotset'
        if keyboard.IsKeyPressed("LSHIFT") == 1 then
            items = g.awh_settings.chars[g.cid].items
        else
            items = g.awh_settings.items
        end
        for key, value in pairs(items) do
            for k, v in pairs(value) do
                if cls_id == v then
                    ui.SysMsg(g.lang == "Japanese" and "既に登録済です" or "Already registered")
                    return
                end
            end
        end
        local awh_setting = ui.GetFrame(addon_name_lower .. "awh_setting")
        local char_slotset = GET_CHILD_RECURSIVELY(awh_setting, "char_slotset")
        local slotcount = char_slotset:GetSlotCount()
        local index = 1
        for i = 1, slotcount do
            local awslot = GET_CHILD_RECURSIVELY(char_slotset, "slot" .. i)
            local slot_icon = awslot:GetIcon()
            if slot_icon == nil then
                index = i
                break
            end
        end
        local ctrl = GET_CHILD_RECURSIVELY(char_slotset, "slot" .. index)
        if tonumber(item_cls.MaxStack) > 1 then
            awh_setting:SetUserValue("SLOT_NAME", ctrl:GetParent():GetName())
            local msg = g.lang == "Japanese" and "インベントリに残す数を入力" or
                            "Enter the number to be left in the inventory"
            INPUT_NUMBER_BOX(awh_setting, msg, "another_warehouse_setting_item_count", 0, 0,
                tonumber(item_cls.MaxStack), cls_id, tostring(index), nil)
        else
            if items == nil then
                items[tostring(index)] = {
                    clsid = cls_id,
                    count = 0
                }
            end
            SET_SLOT_ITEM_CLS(ctrl, item_cls)
            another_warehouse_save_settings()
        end
        return
    end
    local awh_set_items = ui.GetFrame(addon_name_lower .. "awh_set_items")
    if awh_set_items and awh_set_items:IsVisible() == 1 then
        AUTO_CAST(awh_set_items)
        local name_edit = GET_CHILD(awh_set_items, "name_edit")
        local name_text = string.gsub(name_edit:GetText(), "{ol}", "")
        local index = 0
        for i, data in ipairs(g.awh_settings.take_list) do
            local name = data.name
            if name == name_text then
                index = i
            end
        end
        local set_slotset = GET_CHILD_RECURSIVELY(awh_set_items, 'set_slotset')
        AUTO_CAST(set_slotset)
        local slotcount = set_slotset:GetSlotCount()
        for i = 1, slotcount do
            local slot = GET_CHILD(set_slotset, "slot" .. i)
            AUTO_CAST(slot)
            local slot_index = string.gsub(slot:GetName(), "slot", "")
            local icon = slot:GetIcon()
            if not icon then
                local inv_item = session.GetEtcItemByGuid(IT_ACCOUNT_WAREHOUSE, iesid)
                local obj = GetIES(inv_item:GetObject())
                g.awh_settings.take_list[index].items[slot_index] = obj.ClassID
                break
            end
        end
        another_warehouse_set_items_setting(index, name_text)
        return
    end
    local accountwarehouse = ui.GetFrame("accountwarehouse")
    local inv_item = session.GetEtcItemByGuid(IT_ACCOUNT_WAREHOUSE, iesid)
    local obj = GetIES(inv_item:GetObject())
    local count = inv_item.count
    if keyboard.IsKeyPressed("LSHIFT") == 1 then
        local belonging_count = TryGetProp(obj, 'BelongingCount', 0)
        local max_cnt = inv_item.count
        if belonging_count > 0 then
            max_cnt = count - obj.BelongingCount
            if max_cnt <= 0 then
                max_cnt = 0
            end
        end
        if count > 1 or geItemTable.IsStack(obj.ClassID) == 1 then
            INPUT_NUMBER_BOX(accountwarehouse, ScpArgMsg("InputCount"), "another_warehouse_take_item_from_warehouse",
                max_cnt, 1, max_cnt, nil, iesid)
        else
            another_warehouse_takeitem(accountwarehouse, iesid, 1)
        end
    else
        if count > 1 or geItemTable.IsStack(obj.ClassID) == 1 then
            if g.awh_settings.etc.leave_item == 1 then
                count = count - 1
            end
            another_warehouse_takeitem(accountwarehouse, iesid, count)
        else
            another_warehouse_takeitem(accountwarehouse, iesid, 1)
        end
    end
end

function another_warehouse_take_item_from_warehouse(accountwarehouse, count, input_frame)
    input_frame:ShowWindow(0)
    local iesid = input_frame:GetUserValue("ArgString")
    session.ResetItemList()
    session.AddItemID(iesid, count)
    local handle = accountwarehouse:GetUserIValue("HANDLE")
    item.TakeItemFromWarehouse_List(IT_ACCOUNT_WAREHOUSE, session.GetItemIDList(), handle)
end

function another_warehouse_putitem(inv_item, iesid, count)
    local item_obj = GetIES(inv_item:GetObject())
    local goal_index = another_warehouse_get_goal_index()
    if another_warehouse_check_valid(inv_item) then
        local accountwarehouse = ui.GetFrame("accountwarehouse")
        local handle = accountwarehouse:GetUserIValue("HANDLE")
        item.PutItemToWarehouse(IT_ACCOUNT_WAREHOUSE, iesid, tostring(count), handle, goal_index)
        local awh = ui.GetFrame(addon_name_lower .. "awh")
        AUTO_CAST(awh)
        awh:SetUserValue("TOOLTIP_COUNT", 0)
        another_warehouse_item_put_to(awh, iesid, count, item_obj.ClassID)
        if geItemTable.IsStack(item_obj.ClassID) == 1 then
            table.insert(g.awh_new_stack_add_item, item_obj.ClassID)
        elseif geItemTable.IsStack(item_obj.ClassID) == 0 then
            table.insert(g.awh_new_stack_add_item, item_obj.ClassID .. "_" .. iesid)
        end
        local gbox_warehouse = GET_CHILD_RECURSIVELY(accountwarehouse, "gbox_warehouse")
        if gbox_warehouse then
            gbox_warehouse:UpdateData()
            accountwarehouse:Invalidate()
        end
    end
end

function another_warehouse_takeitem(accountwarehouse, iesid, count)
    session.ResetItemList()
    session.AddItemID(iesid, count)
    local handle = accountwarehouse:GetUserIValue("HANDLE")
    item.TakeItemFromWarehouse_List(IT_ACCOUNT_WAREHOUSE, session.GetItemIDList(), handle)
end

function another_warehouse_auto_func_start(awh)
    local auto_money = g.awh_settings.chars[g.cid].money_check
    local my_handle = session.GetMyHandle()
    local buff = info.GetBuff(my_handle, 70002)
    if not buff then
        if auto_money == 1 then
            another_warehouse_silver(awh)
        end
        ui.SysMsg(g.lang == "Japanese" and "[AWH]トークンがないため自動処理を停止します" or
                      "[AWH]Auto function stopped due to no token")
        return
    end
    local auto_item = g.awh_settings.chars[g.cid].item_check
    if auto_item == 0 and auto_money == 0 then
        return
    end
    if auto_item == 1 then
        another_warehouse_auto_item_start(awh)
        return
    end
    if auto_money == 1 then
        another_warehouse_silver(awh)
        return
    end
    another_warehouse_end(awh)
end

function another_warehouse_retry(frame)
    another_warehouse_auto_item_start(frame, true)
    return 0
end

function another_warehouse_auto_item_start(awh, is_retry)
    if not is_retry then
        g.awh_retry_count = 0
    end
    local accountwarehouse = ui.GetFrame('accountwarehouse')
    local item_list = session.GetEtcItemList(IT_ACCOUNT_WAREHOUSE)
    local sorted_guid_list = item_list:GetSortedGuidList()
    local sorted_cnt = sorted_guid_list:Count()
    if sorted_cnt == 0 then
        if accountwarehouse:IsVisible() == 1 then
            if g.awh_retry_count < 5 then
                g.awh_retry_count = g.awh_retry_count + 1
                accountwarehouse:StopUpdateScript("another_warehouse_retry")
                accountwarehouse:RunUpdateScript("another_warehouse_retry", 0.1)
                return
            else
                local msg = g.lang == "Japanese" and
                                "倉庫情報の取得に失敗しました{nl}アイテム自動取得をスキップします" or
                                "Failed to retrieve warehouse info{nl}Auto-take skipped"
                ui.SysMsg(msg)
            end
        end
    end
    g.awh_take_items = {}
    g.awh_put_items = {}
    for i = 0, sorted_cnt - 1 do
        local guid = sorted_guid_list:Get(i)
        local inv_item = item_list:GetItemByGuid(guid)
        local cls_id = inv_item.type
        local inv_count = g.awh_settings.etc.leave_item == 1 and inv_item.count - 1 or inv_item.count
        local is_match = false
        local char_items = g.awh_settings.chars[g.cid].items
        for str_index, item in pairs(char_items) do
            local char_clsid = item.clsid
            local char_clsid_str = tostring(char_clsid)
            local char_count = item.count
            if cls_id == char_clsid and cls_id ~= 900011 then
                if inv_count > 0 then
                    g.awh_take_items[char_clsid_str] = {
                        iesid = guid,
                        count = char_count
                    }
                end
                is_match = true
                break
            end
        end
        if not is_match then
            local common_items = g.awh_settings.items
            for str_index, item in pairs(common_items) do
                local common_clsid = item.clsid
                local common_clsid_str = tostring(common_clsid)
                local common_count = item.count
                if cls_id == common_clsid and cls_id ~= 900011 then
                    if inv_count > 0 then
                        g.awh_take_items[common_clsid_str] = {
                            iesid = guid,
                            count = common_count
                        }
                    end
                    break
                end
            end
        end
    end
    local inv_item_list = session.GetInvItemList()
    local inv_guid_list = inv_item_list:GetGuidList()
    local inv_cnt = inv_guid_list:Count()
    for i = 0, inv_cnt - 1 do
        local guid = inv_guid_list:Get(i)
        local inv_item = inv_item_list:GetItemByGuid(guid)
        local inv_obj = GetIES(inv_item:GetObject())
        local inv_clsid = inv_obj.ClassID
        local inv_clsid_str = tostring(inv_clsid)
        if inv_clsid ~= 900011 then
            if g.awh_take_items[inv_clsid_str] then
                local take_data = g.awh_take_items[inv_clsid_str]
                local old_need = take_data.count
                local take_count = take_data.count - inv_item.count
                if take_count <= 0 then
                    g.awh_take_items[inv_clsid_str] = nil
                else
                    take_data.count = take_count
                end
            end
            local target_count = 0
            local is_target = false
            for _, item in pairs(g.awh_settings.chars[g.cid].items) do
                if item.clsid == inv_clsid then
                    target_count = item.count
                    is_target = true
                    break
                end
            end
            if not is_target then
                for _, item in pairs(g.awh_settings.items) do
                    if item.clsid == inv_clsid then
                        target_count = item.count
                        is_target = true
                        break
                    end
                end
            end
            if is_target then
                local put_count = inv_item.count - target_count
                if put_count > 0 then
                    g.awh_put_items[inv_clsid_str] = {
                        iesid = guid,
                        count = put_count,
                        invcount = inv_item.count,
                        initial_count = inv_item.count
                    }
                end
            end
        end
    end
    for cls_id, _ in pairs(g.awh_take_items) do
        if g.awh_put_items[cls_id] then
            g.awh_put_items[cls_id] = nil
        end
    end
    another_warehouse_item_take(awh)
end

function another_warehouse_item_take(awh)
    if awh:GetUserIValue("IS_TAKING") == 0 then
        local item_list = session.GetEtcItemList(IT_ACCOUNT_WAREHOUSE)
        local sorted_guid_list = item_list:GetSortedGuidList()
        local sorted_cnt = sorted_guid_list:Count()
        session.ResetItemList()
        local take_count_total = 0
        for cls_id, items in pairs(g.awh_take_items) do
            for i = 0, sorted_cnt - 1 do
                local guid = sorted_guid_list:Get(i)
                local inv_item = item_list:GetItemByGuid(guid)
                if guid == items.iesid then
                    local count = math.min(items.count, inv_item.count)
                    if count > 0 then
                        session.AddItemID(guid, count)
                        take_count_total = take_count_total + 1
                    end
                    break
                end
            end
        end
        if take_count_total == 0 then
            awh:RunUpdateScript("another_warehouse_item_put", 0.1)
            return 0
        end
        local accountwarehouse = ui.GetFrame('accountwarehouse')
        local handle = accountwarehouse:GetUserIValue('HANDLE')
        item.TakeItemFromWarehouse_List(IT_ACCOUNT_WAREHOUSE, session.GetItemIDList(), handle)
        awh:SetUserValue("IS_TAKING", 1)
        awh:SetUserValue("TAKE_START_TIME", imcTime.GetAppTimeMS())
        awh:StopUpdateScript("another_warehouse_item_take")
        awh:RunUpdateScript("another_warehouse_item_take", 0.1)
        return 1
    end
    local all_arrived = true
    for cls_id, items in pairs(g.awh_take_items) do
        local inv_item = session.GetInvItemByGuid(items.iesid)
        if not inv_item then
            all_arrived = false
            break
        end
    end
    local start_time = awh:GetUserIValue("TAKE_START_TIME")
    local now = imcTime.GetAppTimeMS()
    if all_arrived or (now - start_time > 1000) then
        awh:SetUserValue("IS_TAKING", 0)
        awh:SetUserValue("TOOLTIP_COUNT", 0)
        awh:RunUpdateScript("another_warehouse_item_put", 0.1)
        return 0
    end
    return 1
end

function another_warehouse_item_put(awh)
    local accountwarehouse = ui.GetFrame('accountwarehouse')
    if accountwarehouse:IsVisible() == 0 then
        awh:StopUpdateScript("another_warehouse_item_put")
        return 0
    end
    local next_cls_id, item_data = next(g.awh_put_items)
    if not next_cls_id then
        if g.awh_settings.chars[g.cid].money_check == 1 then
            another_warehouse_silver(awh)
        else
            another_warehouse_end(awh)
        end
        return 0
    end
    local is_finished = false
    local inv_item = session.GetInvItemByGuid(item_data.iesid)
    if not inv_item then
        is_finished = true
    elseif item_data.is_putting then
        if inv_item.count < item_data.initial_count then
            is_finished = true
        else
            return 1
        end
    end
    if is_finished then
        local count = item_data.real_put_count or item_data.count
        another_warehouse_item_put_to(awh, item_data.iesid, count, next_cls_id)
        if geItemTable.IsStack(next_cls_id) == 1 then
            table.insert(g.awh_new_stack_add_item, next_cls_id)
        elseif geItemTable.IsStack(next_cls_id) == 0 then
            table.insert(g.awh_new_stack_add_item, next_cls_id .. "_" .. item_data.iesid)
        end
        g.awh_put_items[tostring(next_cls_id)] = nil
        if not next(g.awh_put_items) then
            if g.awh_settings.chars[g.cid].money_check == 1 then
                another_warehouse_silver(awh)
            else
                another_warehouse_end(awh)
            end
            return 0
        end
        return 1
    end
    if not another_warehouse_check_valid(inv_item) then
        awh:StopUpdateScript("another_warehouse_item_put")
        return 0
    end
    local handle = accountwarehouse:GetUserIValue("HANDLE")
    local goal_index = another_warehouse_get_goal_index()
    local put_count = item_data.count
    if put_count > inv_item.count then
        put_count = inv_item.count
    end
    item_data.initial_count = inv_item.count
    item.PutItemToWarehouse(IT_ACCOUNT_WAREHOUSE, item_data.iesid, tostring(put_count), handle, goal_index)
    item_data.is_putting = true
    item_data.real_put_count = put_count
    return 1
end

function another_warehouse_item_put_to(awh, guid, count, cls_id)
    local item_cls = GetClassByType('Item', cls_id)
    local icon_name = GET_ITEM_ICON_IMAGE(item_cls)
    local item_name = item_cls.Name
    local tooltip_count = awh:GetUserIValue("TOOLTIP_COUNT")
    if tooltip_count >= 4 then
        awh:SetUserValue("TOOLTIP_COUNT", 0)
    else
        awh:SetUserValue("TOOLTIP_COUNT", tooltip_count + 1)
    end
    another_warehouse_item_tooltip(item_name, icon_name, count, tooltip_count)
    local msg = g.lang == "Japanese" and "倉庫に格納しました" .. "：[" .. "{#EE82EE}" .. item_name ..
                    "{#FFFF00}]×" .. "{#EE82EE}" .. count or "Item to warehousing" .. "：[" .. "{#EE82EE}" ..
                    item_name .. "{#FFFF00}]×" .. "{#EE82EE}" .. count
    CHAT_SYSTEM(msg)
end

function another_warehouse_item_tooltip(item_name, icon_name, count, tooltip_count)
    local awh_tooltip =
        ui.CreateNewFrame("notice_on_pc", addon_name_lower .. "awh_tooltip" .. tooltip_count, 0, 0, 0, 0)
    AUTO_CAST(awh_tooltip)
    awh_tooltip:SetSkinName("None")
    awh_tooltip:SetPos(680, 300 + tooltip_count * 55)
    awh_tooltip:SetLayerLevel(100)
    awh_tooltip:Resize(350, 64)
    local tooltip_gb = awh_tooltip:CreateOrGetControl("groupbox", "tooltip_gb", 0, 0, 350, 64)
    AUTO_CAST(tooltip_gb)
    tooltip_gb:SetSkinName("item_show_tootip")
    tooltip_gb:Resize(350, 64)
    local tooltip_slot = tooltip_gb:CreateOrGetControl("slot", "tooltip_slot", 20, 10, 45, 45)
    AUTO_CAST(tooltip_slot)
    local tooltip_text = tooltip_gb:CreateOrGetControl("richtext", "tooltip_text", 75, 15, 265, 22)
    AUTO_CAST(tooltip_text)
    tooltip_text:Resize(265, 22)
    tooltip_text:SetText("{ol}" .. item_name)
    local tooltip_count = tooltip_gb:CreateOrGetControl("richtext", "tooltip_count", 75, 37, 265, 22)
    AUTO_CAST(tooltip_count)
    tooltip_count:Resize(265, 22)
    local msg = g.lang == "Japanese" and count .. " 個搬入しました" or count .. " Pieces in warehouse"
    tooltip_count:SetText("{ol}" .. msg)
    SET_SLOT_ICON(tooltip_slot, icon_name)
    awh_tooltip:ShowWindow(1)
    awh_tooltip:RunUpdateScript("another_warehouse_item_tooltip_close", 2.0)
end

function another_warehouse_item_tooltip_close(awh_tooltip)
    ui.DestroyFrame(awh_tooltip:GetName())
end

function another_warehouse_silver(awh)
    local silver = session.GetInvItemByType(900011)
    local accountwarehouse = ui.GetFrame('accountwarehouse')
    local handle = accountwarehouse:GetUserIValue('HANDLE')
    local char_silver = 0
    if silver then
        char_silver = tonumber(silver:GetAmountStr())
    end
    char_silver = char_silver - g.awh_settings.etc.auto_silver
    if char_silver > 0 then
        item.PutItemToWarehouse(IT_ACCOUNT_WAREHOUSE, silver:GetIESID(), tostring(char_silver), handle)
    elseif char_silver <= 0 then
        session.ResetItemList()
        session.AddItemIDWithAmount("0", tostring(-char_silver))
        item.TakeItemFromWarehouse_List(IT_ACCOUNT_WAREHOUSE, session.GetItemIDList(), handle)
    end
    another_warehouse_end(awh)
end

function another_warehouse_end(awh)
    ui.SysMsg("[AWH]End of Operation")
    imcSound.PlaySoundEvent('sys_cube_open_normal')
end

function another_warehouse_setting_frame_init(frame, ctrl, str, num)
    local inventory = ui.GetFrame('inventory')
    inventory:ShowWindow(1)
    INVENTORY_SET_CUSTOM_RBTNDOWN("None")
    INVENTORY_SET_CUSTOM_RBTNDOWN("another_warehouse_setting_rbtn")
    local setting = ui.CreateNewFrame("notice_on_pc", addon_name_lower .. "awh_setting", 0, 0, 0, 0)
    AUTO_CAST(setting)
    setting:RemoveAllChild()
    setting:SetPos(670, 10)
    setting:Resize(740, 1060)
    setting:SetLayerLevel(96)
    setting:SetSkinName("test_frame_low")
    local title_gb = setting:CreateOrGetControl("groupbox", "title_gb", 0, 0, setting:GetWidth(), 55)
    title_gb:SetSkinName("test_frame_top")
    AUTO_CAST(title_gb)
    local title_text = title_gb:CreateOrGetControl("richtext", "title_text", 0, 0, ui.CENTER_HORZ, ui.TOP, 0, 15, 0, 0)
    AUTO_CAST(title_text)
    title_text:SetText('{ol}{s26}Another Warehouse Setting')
    local close = setting:CreateOrGetControl("button", "close", 0, 0, 25, 25)
    AUTO_CAST(close)
    close:SetImage("testclose_button")
    close:SetOffset(680, 15)
    close:SetEventScript(ui.LBUTTONUP, "another_warehouse_setting_close")
    local money_check = setting:CreateOrGetControl('checkbox', 'money_check', 25, 65, 25, 25)
    AUTO_CAST(money_check)
    money_check:SetEventScript(ui.LBUTTONUP, "another_warehouse_setting_check")
    money_check:SetCheck(g.awh_settings.chars[g.cid].money_check)
    money_check:SetText(g.lang == "Japanese" and "{ol}自動入出金" or "{ol}automatic deposit and withdrawal")
    money_check:SetTextTooltip(g.lang == "Japanese" and
                                   "{ol}チェックをすると、自動入出金有効化 各キャラクター毎に設定" or
                                   "{ol}If checked, activate silver auto-deposit/withdrawal{nl}configured per character")
    local item_check = setting:CreateOrGetControl('checkbox', 'item_check', 25, 95, 25, 25)
    AUTO_CAST(item_check)
    item_check:SetEventScript(ui.LBUTTONUP, "another_warehouse_setting_check")
    item_check:SetCheck(g.awh_settings.chars[g.cid].item_check)
    item_check:SetText(g.lang == "Japanese" and "{ol}自動搬出入" or "{ol}Automatic item receipt and dispatch")
    item_check:SetTextTooltip(g.lang == "Japanese" and
                                  "{ol}チェックをすると、自動搬出入有効化 各キャラクター毎に設定" or
                                  "{ol}If checked, activate item auto-deposit/withdrawal{nl}configured per character")
    local help = setting:CreateOrGetControl('button', "help", 695, 65, 25, 25)
    AUTO_CAST(help)
    help:SetText("{img question_mark 15 15}")
    help:SetTextTooltip("HELP")
    help:SetEventScript(ui.LBUTTONUP, "another_warehouse_setting_help")
    local amount_text = setting:CreateOrGetControl("richtext", "amount_text", 400, 65, 0, 30)
    AUTO_CAST(amount_text)
    amount_text:SetText(g.lang == "Japanese" and "{ol}自動入出金 金額設定" or "{ol}Auto Transfer Amount Config")
    local amount_edit = setting:CreateOrGetControl('edit', 'amount_edit', 400, 90, 150, 35)
    AUTO_CAST(amount_edit)
    amount_edit:SetFontName("white_18_ol")
    amount_edit:SetTextAlign("center", "center")
    amount_edit:SetText(GET_COMMAED_STRING(g.awh_settings.etc.auto_silver or 0))
    amount_edit:SetNumberMode(1)
    amount_edit:SetEventScript(ui.ENTERKEY, 'another_warehouse_setting_edit')
    local team_text = setting:CreateOrGetControl("richtext", "team_text", 25, 125, 0, 0)
    AUTO_CAST(team_text);
    team_text:SetText(g.lang == "Japanese" and "{ol}チーム倉庫の共通設定" or
                          "{ol}Team Storage Common Settings")
    local char_text = setting:CreateOrGetControl("richtext", "char_text", 25, 695, 0, 0)
    AUTO_CAST(char_text)
    char_text:SetText(g.lang == "Japanese" and "{ol}チーム倉庫のキャラクター個別設定" or
                          "{ol}Team Storage Character Settings")
    local team_gb = setting:CreateOrGetControl("groupbox", "team_gb", 20, 145, setting:GetWidth() - 25, 540)
    team_gb:SetSkinName("test_frame_low")
    AUTO_CAST(team_gb)
    another_warehouse_setting_slot_set(team_gb, 'team_slotset')
    local char_gb = setting:CreateOrGetControl("groupbox", "char_gb", 20, 715, setting:GetWidth() - 25, 330)
    char_gb:SetSkinName("test_frame_low")
    AUTO_CAST(char_gb)
    another_warehouse_setting_slot_set(char_gb, 'char_slotset')
    setting:ShowWindow(1)
end

function another_warehouse_setting_close(setting)
    ui.DestroyFrame(setting:GetName())
    local accountwarehouse = ui.GetFrame("accountwarehouse")
    ACCOUNTWAREHOUSE_CLOSE(accountwarehouse)
end

function another_warehouse_setting_check(frame, ctrl)
    local ischeck = ctrl:IsChecked()
    local ctrl_name = ctrl:GetName()
    if ctrl_name == "leave" then -- 
        g.awh_settings.etc.leave_item = ischeck
    elseif ctrl_name == "display_change" then
        g.awh_settings.etc.display_change = ischeck
    elseif ctrl_name == "money_check" then
        g.awh_settings.chars[g.cid].money_check = ischeck
    elseif ctrl_name == "item_check" then
        g.awh_settings.chars[g.cid].item_check = ischeck
    end
    another_warehouse_save_settings()
    local awh = ui.GetFrame(addon_name_lower .. "awh")
    local gb = GET_CHILD(awh, "gb")
    AUTO_CAST(gb)
    local tab_index = awh:GetUserIValue("TAB_INDEX")
    another_warehouse_frame_update(awh, gb, "", tab_index)
end

function another_warehouse_setting_edit(frame, ctrl)
    local text = ctrl:GetText()
    local clean_text = string.gsub(text, ",", "") -- カンマを空文字に置換
    local ctrl_num = tonumber(clean_text) or 0
    if ctrl:GetName() == "amount_edit" then
        g.awh_settings.etc.auto_silver = ctrl_num
        ctrl:SetText(GET_COMMAED_STRING(g.awh_settings.etc.auto_silver))
    end
    another_warehouse_save_settings()
end

function another_warehouse_setting_help()
    local context = ui.CreateContextMenu("awh_setting_help_context", "{ol}[AWH] HELP", 30, 0, 100, 100)
    local msg =
        g.lang == "Japanese" and "インベントリ:マウス右クリックでチームのアイテム設定" or
            "Inventory: right mouse click to set team items"
    ui.AddContextMenuItem(context, "{ol}" .. msg, "None")
    msg = g.lang == "Japanese" and
              "インベントリ:左SHIFT+マウス右クリックで各キャラのアイテム設定" or
              "Inventory: left SHIFT+mouse right click to set items for each character"
    ui.AddContextMenuItem(context, "{ol}" .. msg, "None")
    msg = g.lang == "Japanese" and "設定スロット:左SHIFT+マウス右クリックで設定個数変更" or
              "Setting slot: left SHIFT+right mouse click to change the number of setting pieces"
    ui.AddContextMenuItem(context, "{ol}" .. msg, "None")
    msg = g.lang == "Japanese" and "設定スロット:マウス右クリックで設定消去" or
              "Setting slot: right mouse click to clear settings"
    ui.AddContextMenuItem(context, "{ol}" .. msg, "None")
    ui.OpenContextMenu(context)
end

function another_warehouse_setting_slot_set(parent, slot_set_name)
    local slotset = parent:CreateOrGetControl('slotset', slot_set_name, 10, 10, 0, 0)
    AUTO_CAST(slotset)
    slotset:SetSlotSize(40, 40)
    slotset:EnablePop(1)
    slotset:EnableDrag(1)
    slotset:EnableDrop(1)
    slotset:SetColRow(17, 58)
    slotset:SetSpc(0, 0)
    slotset:SetSkinName('slot')
    slotset:SetEventScript(ui.RBUTTONUP, "another_warehouse_setting_icon_clear")
    slotset:CreateSlots()
    local slotcount = slotset:GetSlotCount()
    local items = {}
    if slot_set_name == 'team_slotset' then
        items = g.awh_settings.items
    elseif slot_set_name == 'char_slotset' then
        items = g.awh_settings.chars[g.cid].items
    end
    for i = 1, slotcount do
        local slot = GET_CHILD(slotset, "slot" .. i)
        local str_index = tostring(i)
        for key, value in pairs(items) do
            if key == str_index then
                local clsid = value.clsid
                local count = value.count
                local itemcls = GetClassByType("Item", clsid)
                slot:SetUserValue("ITEM_CLSID", clsid)
                SET_SLOT_ITEM_CLS(slot, itemcls)
                if count ~= 0 then
                    SET_SLOT_COUNT_TEXT(slot, count)
                end
            end
        end
    end
end

function another_warehouse_setting_icon_clear(parent, ctrl, str, num)
    if keyboard.IsKeyPressed("LSHIFT") == 1 then
        another_warehouse_setting_count_change(parent, ctrl, str, num)
        return
    end
    local items = {}
    if parent:GetName() == 'team_slotset' then
        items = g.awh_settings.items
    elseif parent:GetName() == 'char_slotset' then
        items = g.awh_settings.chars[g.cid].items
    end
    local str_index = string.gsub(ctrl:GetName(), "slot", "")
    for key, value in pairs(items) do
        if key == str_index then
            ctrl:ClearIcon()
            items[str_index] = nil
            another_warehouse_save_settings()
            break
        end
    end
end

function another_warehouse_setting_count_change(frame, ctrl, strr, num)
    local slot_index = tonumber(string.gsub(ctrl:GetName(), "slot", ""))
    if slot_index then
        local cls_id = ctrl:GetUserIValue("ITEM_CLSID")
        local itemcls = GetClassByType("Item", cls_id)
        local awh_setting = ui.GetFrame(addon_name_lower .. "awh_setting")
        awh_setting:SetUserValue("SLOT_NAME", ctrl:GetParent():GetName())
        local msg = g.lang == "Japanese" and "インベントリに残す数を入力" or
                        "Enter the number to be left in the inventory"
        INPUT_NUMBER_BOX(awh_setting, msg, "another_warehouse_setting_item_count", 0, 0, tonumber(itemcls.MaxStack),
            cls_id, tostring(slot_index), nil)
    end
end

function another_warehouse_setting_item_count(awh_setting, count, input_frame)
    local clsid = input_frame:GetValue()
    local index = input_frame:GetUserValue("ArgString")
    local item_cls = GetClassByType("Item", clsid)
    local user_value = awh_setting:GetUserValue("SLOT_NAME")
    local items = {}
    if user_value == "char_slotset" then
        items = g.awh_settings.chars[g.cid].items
    else
        items = g.awh_settings.items
    end
    local slotset = GET_CHILD_RECURSIVELY(awh_setting, user_value)
    local slot = GET_CHILD_RECURSIVELY(slotset, "slot" .. index)
    items[tostring(index)] = {
        clsid = clsid,
        count = tonumber(count)
    }
    SET_SLOT_ITEM_CLS(slot, item_cls)
    another_warehouse_save_settings()
    input_frame:ShowWindow(0)
end

function another_warehouse_setting_rbtn(item_obj, slot)
    local icon = slot:GetIcon()
    local icon_info = icon:GetInfo()
    local iesid = icon_info:GetIESID()
    local inv_item = GET_PC_ITEM_BY_GUID(iesid)
    if not inv_item then
        return
    end
    local cls_id = icon_info.type
    local item_cls = GetClassByType("Item", cls_id)
    local obj = GetIES(inv_item:GetObject())
    if inv_item.isLockState then
        ui.SysMsg(ClMsg("MaterialItemIsLock"))
        return
    end
    if item_cls.ItemType == 'Quest' then
        ui.MsgBox(ScpArgMsg("IT_ISNT_REINFORCEABLE_ITEM"));
        return
    end
    local enable_team_trade = TryGetProp(item_cls, "TeamTrade")
    if enable_team_trade and enable_team_trade == "NO" then
        ui.SysMsg(ClMsg("ItemIsNotTradable"))
        return
    end
    local belonging_count = TryGetProp(obj, 'BelongingCount', 0)
    if belonging_count > 0 and belonging_count >= inv_item.count then
        ui.SysMsg(ClMsg("ItemIsNotTradable"))
        return
    end
    if TryGetProp(obj, 'CharacterBelonging', 0) == 1 then
        ui.SysMsg(ClMsg("ItemIsNotTradable"))
        return
    end
    local items = {}
    local slotset_name = ""
    if keyboard.IsKeyPressed("LSHIFT") == 1 then
        items = g.awh_settings.chars[g.cid].items
        slotset_name = "char_slotset"
    else
        items = g.awh_settings.items
        slotset_name = 'team_slotset'
    end
    for key, value in pairs(items) do
        for k, v in pairs(value) do
            if cls_id == v then
                ui.SysMsg(g.lang == "Japanese" and "既に登録済です" or "Already registered")
                return
            end
        end
    end
    local awh_setting = ui.GetFrame(addon_name_lower .. "awh_setting")
    local slotset = GET_CHILD_RECURSIVELY(awh_setting, slotset_name)
    local slotcount = slotset:GetSlotCount()
    local index = 1
    for i = 1, slotcount do
        local awslot = GET_CHILD_RECURSIVELY(slotset, "slot" .. i)
        local slot_icon = awslot:GetIcon()
        if slot_icon == nil then
            index = i
            break
        end
    end
    local ctrl = GET_CHILD_RECURSIVELY(slotset, "slot" .. index)
    if tonumber(item_cls.MaxStack) > 1 then
        awh_setting:SetUserValue("SLOT_NAME", ctrl:GetParent():GetName())
        local msg = g.lang == "Japanese" and "インベントリに残す数を入力" or
                        "Enter the number to be left in the inventory"
        INPUT_NUMBER_BOX(awh_setting, msg, "another_warehouse_setting_item_count", 0, 0, tonumber(item_cls.MaxStack),
            cls_id, tostring(index), nil)
    else
        if items == nil then
            items[tostring(index)] = {
                clsid = cls_id,
                count = 0
            }
        end
        SET_SLOT_ITEM_CLS(ctrl, item_cls)
        another_warehouse_save_settings()
    end
end

function another_warehouse_setting_context(frame, ctrl, str, num)
    local context = ui.CreateContextMenu("awh_TAKE_SETTING", "{ol}{#FF0000}Slot Setting", 0, 20, 100, 100)
    for i, data in ipairs(g.awh_settings.take_list) do
        local name = data.name
        local scp = string.format("another_warehouse_set_items_setting(%d,'%s')", i, name)
        ui.AddContextMenuItem(context, "{ol}{#FF0000}" .. name, scp)
    end
    ui.OpenContextMenu(context)
end

function another_warehouse_set_items_setting(index, name)
    local awh_set_items = ui.CreateNewFrame("notice_on_pc", addon_name_lower .. "awh_set_items", 0, 0, 0, 0)
    AUTO_CAST(awh_set_items)
    awh_set_items:SetSkinName("test_frame_low")
    awh_set_items:SetPos(680, 170)
    awh_set_items:SetLayerLevel(100)
    awh_set_items:Resize(320, 608)
    awh_set_items:RemoveAllChild()
    local close = awh_set_items:CreateOrGetControl("button", "close", 0, 0, 25, 25)
    AUTO_CAST(close)
    close:SetImage("testclose_button")
    close:SetGravity(ui.RIGHT, ui.TOP)
    close:SetEventScript(ui.LBUTTONUP, "another_warehouse_set_item_close")
    local set_gb = awh_set_items:CreateOrGetControl("groupbox", "set_gb", 10, 50, 380, 380)
    AUTO_CAST(set_gb)
    set_gb:SetSkinName("test_frame_midle_light")
    set_gb:Resize(300, 500)
    awh_set_items:ShowWindow(1)
    local name_edit = awh_set_items:CreateOrGetControl("edit", "name_edit", 10, 13, 210, 30)
    AUTO_CAST(name_edit)
    name_edit:SetFontName("white_16_ol")
    name_edit:SetTextAlign("center", "center")
    name_edit:SetText("{ol}" .. name)
    name_edit:SetEventScript(ui.ENTERKEY, "another_warehouse_set_name_edit")
    name_edit:SetEventScriptArgString(ui.ENTERKEY, name)
    name_edit:SetEventScriptArgNumber(ui.ENTERKEY, index)
    local set_slotset = set_gb:CreateOrGetControl('slotset', 'set_slotset', 0, 0, 0, 0)
    AUTO_CAST(set_slotset)
    set_slotset:SetSlotSize(50, 50)
    set_slotset:EnablePop(1)
    set_slotset:EnableDrag(1)
    set_slotset:EnableDrop(1)
    set_slotset:SetEventScript(ui.DROP, "another_warehouse_set_swap_item")
    set_slotset:SetEventScriptArgString(ui.DROP, name)
    set_slotset:SetEventScriptArgNumber(ui.DROP, index)
    set_slotset:SetColRow(6, 10)
    set_slotset:SetSpc(0, 0)
    set_slotset:SetSkinName('slot')
    set_slotset:CreateSlots()
    local target_set = g.awh_settings.take_list[index]
    local items_map = target_set.items
    local slotcount = set_slotset:GetSlotCount()
    for i = 1, slotcount do
        local slot = GET_CHILD(set_slotset, "slot" .. i)
        AUTO_CAST(slot)
        local icon = slot:GetIcon()
        if not icon then
            slot:SetTextTooltip(g.lang == "Japanese" and "{ol}倉庫アイテム右クリックで設定" or
                                    "{ol}Warehouse items right-click to setting")
        end
        local saved_clsid = items_map[tostring(i)]
        if saved_clsid then
            local item_cls = GetClassByType("Item", saved_clsid)
            if item_cls then
                SET_SLOT_ITEM_CLS(slot, item_cls)
                slot:SetEventScript(ui.RBUTTONUP, "another_warehouse_set_clear_item")
                slot:SetEventScriptArgNumber(ui.RBUTTONUP, index)
                slot:SetEventScriptArgString(ui.RBUTTONUP, name)
            end
        end
    end
    local init = awh_set_items:CreateOrGetControl("button", "init", 0, 0, 100, 43)
    AUTO_CAST(init)
    init:SetText(g.lang == "Japanese" and "{@st66b}初期化" or "{@st66b}Initialize")
    init:SetMargin(210, 555, 0, 0)
    init:SetSkinName("test_pvp_btn")
    init:SetEventScript(ui.LBUTTONUP, "another_warehouse_setslot_init")
    init:SetEventScriptArgString(ui.LBUTTONUP, name)
    init:SetEventScriptArgNumber(ui.LBUTTONUP, index)
    local take = awh_set_items:CreateOrGetControl("button", "take", 0, 0, 100, 43)
    AUTO_CAST(take)
    take:SetText(g.lang == "Japanese" and "{@st66b}取出し" or "{@st66b}Withdrawal")
    take:SetMargin(10, 555, 0, 0)
    take:SetSkinName("test_pvp_btn")
    take:SetEventScript(ui.LBUTTONUP, "another_warehouse_set_item_take_reserve")
    take:SetEventScriptArgString(ui.LBUTTONUP, name)
end

function another_warehouse_set_item_take_reserve(frame, ctrl, name)
    another_warehouse_set_item_take(name)
end

function another_warehouse_set_clear_item(frame, ctrl, name, index)
    local slot_index = string.gsub(ctrl:GetName(), "slot", "")
    g.awh_settings.take_list[index].items[slot_index] = nil
    another_warehouse_save_settings()
    another_warehouse_set_items_setting(index, name)
end

function another_warehouse_set_swap_item(parent, slot, name, index)
    if parent:GetTopParentFrame():GetName() ~= addon_name_lower .. "awh_set_items" then
        return
    end
    local lift_icon = ui.GetLiftIcon()
    local from_slot = lift_icon:GetParent()
    local from_index = string.gsub(from_slot:GetName(), "slot", "")
    local from_clsid = g.awh_settings.take_list[index].items[from_index]
    local to_index = string.gsub(slot:GetName(), "slot", "")
    local to_icon = slot:GetIcon()
    if not to_icon then
        g.awh_settings.take_list[index].items[from_index] = nil
        g.awh_settings.take_list[index].items[to_index] = from_clsid
    else
        local to_clsid = g.awh_settings.take_list[index].items[to_index]
        g.awh_settings.take_list[index].items[from_index] = to_clsid
        g.awh_settings.take_list[index].items[to_index] = from_clsid
    end
    another_warehouse_save_settings()
    another_warehouse_set_items_setting(index, name)
end

function another_warehouse_set_name_edit(frame, ctrl, name, index)
    local new_name = string.gsub(ctrl:GetText(), "{ol}", "")
    if new_name == "" then
        ui.SysMsg(g.lang == "Japanese" and "文字を入れてください" or "Please enter the text")
        return
    end
    for i, data in ipairs(g.awh_settings.take_list) do
        if new_name == data.name then
            ui.SysMsg(g.lang == "Japanese" and "既に登録済の名前です" or "Name already registered")
            return
        end
    end
    g.awh_settings.take_list[index].name = new_name
    another_warehouse_save_settings()
    another_warehouse_set_items_setting(index, new_name)
end

function another_warehouse_set_item_close(frame)
    ui.DestroyFrame(addon_name_lower .. "awh_set_items")
end

function another_warehouse_setslot_init(frame, init, name, index)
    local yes_scp = string.format("another_warehouse_setslot_init_ok('%s',%d)", name, index)
    local msg = g.lang == "Japanese" and "{ol}{#FFFFFF}セット初期化しますか？" or
                    "{ol}{#FFFFFF}Initialize this set?"
    local msgbox = ui.MsgBox(msg, yes_scp, 'None')
end

function another_warehouse_setslot_init_ok(name, index)
    g.awh_settings.take_list[index] = {
        name = "Take Items " .. index,
        items = {}
    }
    ui.SysMsg(g.lang == "Japanese" and "{ol}初期化しました" or "{ol}Initialized")
    another_warehouse_save_settings()
    local new_name = "Take Items " .. index
    another_warehouse_set_items_setting(index, new_name)
end

function another_warehouse_take_context(frame, ctrl, str, num)
    local context = ui.CreateContextMenu("TAKE_SETTING", "{ol}Take items", 0, 20, 100, 100)
    for i, data in ipairs(g.awh_settings.take_list) do
        local name = data.name
        local scp = string.format("another_warehouse_set_item_take('%s')", name)
        ui.AddContextMenuItem(context, name, scp)
    end
    ui.OpenContextMenu(context)
end

function another_warehouse_set_item_take(name)
    local accountwarehouse = ui.GetFrame('accountwarehouse')
    local handle = accountwarehouse:GetUserIValue("HANDLE")
    local item_list = session.GetEtcItemList(IT_ACCOUNT_WAREHOUSE)
    session.ResetItemList()
    local sorted_guid_list = item_list:GetSortedGuidList()
    local sorted_cnt = sorted_guid_list:Count()
    local take_count = 0
    local target_items_map = {}
    if g.awh_settings.take_list then
        for i, set_data in ipairs(g.awh_settings.take_list) do
            if set_data.name == name then
                for key, item_id in pairs(set_data.items) do
                    target_items_map[tonumber(item_id)] = true
                end
                break
            end
        end
    end
    for j = 0, sorted_cnt - 1 do
        local guid = sorted_guid_list:Get(j)
        local inv_item = item_list:GetItemByGuid(guid)
        local cls_id = inv_item.type
        if target_items_map[cls_id] then
            local count = inv_item.count
            if g.awh_settings.etc.leave_item == 1 then
                count = count - 1
            end
            if count > 0 then
                ts(guid, count)
                session.AddItemID(guid, count)
                take_count = take_count + 1
            end
        end
    end
    if take_count > 0 then
        item.TakeItemFromWarehouse_List(IT_ACCOUNT_WAREHOUSE, session.GetItemIDList(), handle)
    end
end

function another_warehouse_help()
    local context = ui.CreateContextMenu("awh_help_context", "{ol}[AWH] HELP", 30, 0, 100, 100)
    local msg = g.lang == "Japanese" and "インベントリ:アイコン右クリックで全数搬入" or
                    "Inventory: right mouse click to Carry in all items"
    ui.AddContextMenuItem(context, "{ol}" .. msg, "None")
    msg = g.lang == "Japanese" and "インベントリ:アイコン左クリックで1個搬入" or
              "Inventory: left mouse click to Carry in 1 items"
    ui.AddContextMenuItem(context, "{ol}" .. msg, "None")
    msg = g.lang == "Japanese" and "インベントリ:左SHIFT+アイコン右クリックで入力数量搬入" or
              "Inventory: left SHIFT+mouse right click to Carry in Input quantity items"
    ui.AddContextMenuItem(context, "{ol}" .. msg, "None")
    msg = g.lang == "Japanese" and "インベントリ:左SHIFT+アイコン左クリックで10個搬入" or
              "Inventory: left SHIFT+mouse left click to Carry in 10 items"
    ui.AddContextMenuItem(context, "{ol}" .. msg, "None")
    ui.AddContextMenuItem(context, "----------", "None")
    msg = g.lang == "Japanese" and "チーム倉庫:アイコン右クリックで全数搬出" or
              "Warehouse: right mouse click to Carry out all items"
    ui.AddContextMenuItem(context, "{ol}" .. msg, "None")
    msg = g.lang == "Japanese" and "チーム倉庫:アイコン左クリックで1個搬出" or
              "Warehouse: left mouse click to Carry out 1 items"
    ui.AddContextMenuItem(context, "{ol}" .. msg, "None")
    msg = g.lang == "Japanese" and "チーム倉庫:左SHIFT+アイコン右クリックで入力数量搬出" or
              "Warehouse: left SHIFT+mouse right click to Carry out Input quantity items"
    ui.AddContextMenuItem(context, "{ol}" .. msg, "None")
    msg = g.lang == "Japanese" and "チーム倉庫:左SHIFT+アイコン左クリックで10個搬出" or
              "Warehouse: left SHIFT+mouse left click to Carry out 10 items"
    ui.AddContextMenuItem(context, "{ol}" .. msg, "None")
    ui.OpenContextMenu(context)
end
-- another_warehouse ここまで

-- status_point_check ここから
function status_point_check_on_init()
    if g.settings.status_point_check.use == 0 then
        local status = ui.GetFrame("status")
        DESTROY_CHILD_BYNAME(status, "spc_btn")
        return
    end
    g.setup_hook_and_event(g.addon, "STATUS_TAB_CHANGE", "status_point_check_STATUS_TAB_CHANGE", true)
end

function status_point_check_frame()
    status_point_check_toggle_frame()
end

function status_point_check_STATUS_TAB_CHANGE(my_frame, my_msg)
    if g.settings.status_point_check.use == 0 then
        local status = ui.GetFrame("status")
        DESTROY_CHILD_BYNAME(status, "spc_btn")
        return
    end
    local status = g.get_event_args(my_msg)
    local statusTab = status:GetChild('statusTab')
    AUTO_CAST(statusTab)
    local index = statusTab:GetSelectItemIndex()
    if index == 0 then
        local spc_btn = status:CreateOrGetControl("button", "spc_btn", 350, 140, 120, 40) -- 350, 140, 120, 40
        AUTO_CAST(spc_btn)
        spc_btn:SetSkinName("test_pvp_btn")
        spc_btn:SetFontName("white_16_ol")
        spc_btn:SetText(g.lang == "Japanese" and "{@st66b}クエスト確認" or "{@st66b}Check Quest")
        spc_btn:SetTextTooltip(g.lang == "Japanese" and
                                   "{ol}ステータスポイントがもらえるクエストを{nl}クリアしているかどうか確認できます" or
                                   "{ol}Check whether you are clearing quests{nl}that receive status points")
        spc_btn:SetClickSound("button_click_big")
        spc_btn:SetOverSound("button_over")
        spc_btn:SetAnimation("MouseOnAnim", "btn_mouseover")
        spc_btn:SetAnimation("MouseOffAnim", "btn_mouseoff")
        spc_btn:SetEventScript(ui.LBUTTONDOWN, "status_point_check_toggle_frame")
    else
        DESTROY_CHILD_BYNAME(status, "spc_btn")
    end
end

function status_point_check_toggle_frame(frame, ctrl)
    local status_point_check = ui.GetFrame(addon_name_lower .. "status_point_check")
    if status_point_check and status_point_check:IsVisible() == 1 then
        ui.DestroyFrame(addon_name_lower .. "status_point_check")
        return
    end
    if not status_point_check then
        status_point_check = ui.CreateNewFrame("notice_on_pc", addon_name_lower .. "status_point_check", 0, 0, 0, 0)
        AUTO_CAST(status_point_check)
    end
    status_point_check:SetSkinName("collection_complete")
    status_point_check:SetPos(510, 100)
    status_point_check:Resize(950, 850)
    status_point_check:SetLayerLevel(99)
    status_point_check:SetTitleBarSkin("None")
    status_point_check:SetSkinName('None')
    local big_bg = status_point_check:CreateOrGetControl("groupbox", "big_bg", 950, 850, ui.LEFT, ui.TOP, 0, 0, 0, 0)
    AUTO_CAST(big_bg)
    big_bg:SetSkinName("test_frame_low")
    local title_bg = big_bg:CreateOrGetControl("groupbox", "title_bg", 950, 64, ui.LEFT, ui.TOP, 0, 0, 0, 0)
    AUTO_CAST(title_bg)
    title_bg:SetSkinName("test_frame_top")
    local title = big_bg:CreateOrGetControl("richtext", "title", 100, 30, ui.CENTER_HORZ, ui.TOP, 0, 18, 0, 0)
    title:SetText("{@st43}{s22}Status Point Check{/}")
    title:EnableHitTest(false)
    local close = title_bg:CreateOrGetControl("button", "close", 44, 44, ui.RIGHT, ui.TOP, 0, 20, 27, 0)
    AUTO_CAST(close)
    close:SetImage("testclose_button")
    close:SetClickSound("button_click_big")
    close:SetOverSound("button_over")
    close:SetAnimation("MouseOnAnim", "btn_mouseover")
    close:SetAnimation("MouseOffAnim", "btn_mouseoff")
    close:SetEventScript(ui.LBUTTONDOWN, "status_point_check_toggle_frame")
    local tab = big_bg:CreateOrGetControl("tab", "tab", 930, 40, ui.LEFT, ui.TOP, 22, 65, 0, 0)
    AUTO_CAST(tab)
    tab:SetEventScript(ui.LBUTTONUP, "status_point_check_tab_change")
    tab:SetSkinName("tab2")
    tab:AddItem("{@st66b}Status", true, "", "", "", "", "", false)
    tab:AddItem("{@st66b}Zemina", true, "", "", "", "", "", false)
    tab:AddItem("{@st66b}Master Quest", true, "", "", "", "", "", false)
    tab:SetItemsFixWidth(150)
    tab:SetItemsAdjustFontSizeByWidth(150)
    local bg = big_bg:CreateOrGetControl("groupbox", "bg", 910, 725, ui.LEFT, ui.TOP, 20, 105, 0, 0)
    AUTO_CAST(bg)
    bg:SetSkinName("test_frame_midle")
    status_point_check_tab_change(big_bg, tab)
    status_point_check:ShowWindow(1)
end

function status_point_check_tab_change(big_bg, tab, str, num)
    local bg = GET_CHILD(big_bg, "bg")
    AUTO_CAST(bg)
    bg:RemoveAllChild()
    local index = tab:GetSelectItemIndex()
    if index == 0 then
        status_point_check_quest_list(big_bg, bg)
    elseif index == 1 then
        status_point_check_zemina_list(big_bg, bg)
    elseif index == 2 then
        status_point_check_master_quest_list(big_bg, bg)
    end
end

function status_point_check_master_quest_list(big_bg, bg)
    local title = bg:CreateOrGetControl("richtext", "title", 15, 5, 0, 0)
    AUTO_CAST(title)
    title:SetFontName("white_18_ol")
    title:SetText("Quest List For Master Quest")
    local start_map = bg:CreateOrGetControl("richtext", "start_map", 545, 5, 0, 0)
    AUTO_CAST(start_map)
    start_map:SetFontName("white_18_ol")
    start_map:SetText("Quest Start Map")
    local y = 35
    local quests, quests_cnt = GetClassList("QuestProgressCheck_Auto")
    for i = 0, quests_cnt - 1 do
        local quest_cls = GetClassByIndexFromList(quests, i)
        if quest_cls.Success_ItemName1 == "Point_Stone_100_Q" then -- ts("{img quest_detail_pic2 24 24}")
            local script_btn = bg:CreateOrGetControl("button", "script_btn" .. i, 15, y, 20, 20)
            AUTO_CAST(script_btn)
            script_btn:SetSkinName("None")
            script_btn:SetText("{img quest_detail_pic2 20 20}")
            script_btn:SetTextTooltip(g.lang == "Japanese" and "{ol}クエスト詳細表示" or
                                          "{ol}Show quest information")
            script_btn:SetEventScript(ui.LBUTTONDOWN, "QUEST_CLICK_INFO")
            script_btn:SetEventScriptArgNumber(ui.LBUTTONDOWN, quest_cls.ClassID)
            local quest_name = bg:CreateOrGetControl("richtext", "quest_name" .. i, 40, y, 0, 20)
            AUTO_CAST(quest_name)
            local quest_result = bg:CreateOrGetControl("richtext", "quest_result" .. i, 400, y, 0, 20)
            AUTO_CAST(quest_result)
            local map_name = bg:CreateOrGetControl("richtext", "map_name" .. i, 550, y, 0, 20)
            AUTO_CAST(map_name)
            local color = ""
            local result = ""
            if status_point_check_quest_clear_check(quest_cls) then
                color = "{#FF3333}{ol}{b}{s16}"
                result = "OK"
            else
                color = "{#666666}{ol}{b}{s16}"
                result = "NO"
                local quest = GetClassByType('QuestProgressCheck', quest_cls.ClassID)
                local map_prop = geMapTable.GetMapProp(quest.StartMap)
                if map_prop then
                    local map_name_ = dictionary.ReplaceDicIDInCompStr(map_prop:GetName())
                    map_name:SetText(color .. map_name_ .. "[Level:" .. quest.Level .. "]")
                else
                    map_name:SetText(color .. "??[Level:" .. quest.Level .. "]")
                end
            end
            quest_name:SetText(color .. quest_cls.Name)
            quest_result:SetText(color .. result)
            y = y + 24
        end
    end
end

function status_point_check_quest_list(big_bg, bg)
    local y = status_point_check_quest_check(big_bg, bg)
    status_point_check_status_quest_check(big_bg, bg, y)
end

function status_point_check_zemina_list(big_bg, bg)
    local title = bg:CreateOrGetControl("richtext", "title", 15, 5, 0, 0)
    AUTO_CAST(title)
    title:SetFontName("white_18_ol")
    title:SetText("Zemina List")
    local y = 35
    local ui_index = 0
    local maps, maps_cnt = GetClassList("Map")
    for i = 0, maps_cnt - 1 do
        local map_cls = GetClassByIndexFromList(maps, i)
        local count = GetClassCount('GenType_' .. map_cls.ClassName)
        if count > 0 then
            for j = 0, count - 1 do
                local npc_cls = GetClassByIndex('GenType_' .. map_cls.ClassName, j)
                if npc_cls.ClassType == "statue_zemina" then
                    local map_name = bg:CreateOrGetControl("richtext", "map_name" .. ui_index, 20, y, 0, 20)
                    AUTO_CAST(map_name)
                    local zemina_result = bg:CreateOrGetControl("richtext", "zemina_result" .. ui_index, 400, y, 0, 20)
                    AUTO_CAST(zemina_result)
                    local color = ""
                    local result = ""
                    local state = GetNPCState(map_cls.ClassName, npc_cls.GenType)
                    if state == 20 or state == 1 then
                        color = "{#FF3333}{ol}{b}{s16}"
                        result = "OK"
                    else
                        color = "{#666666}{ol}{b}{s16}"
                        result = "NO"
                    end
                    map_name:SetText(color .. map_cls.Name)
                    zemina_result:SetText(color .. result)
                    y = y + 25
                    ui_index = ui_index + 1
                    break
                end
            end
        end
    end
end

function status_point_check_status_quest_check(big_bg, bg, y)
    local title_2 = bg:CreateOrGetControl("richtext", "title_2", 15, y + 10, 0, 0)
    AUTO_CAST(title_2)
    title_2:SetFontName("white_18_ol")
    title_2:SetText("Quest List For Status")
    local start_map_2 = bg:CreateOrGetControl("richtext", "start_map_2", 545, y + 10, 0, 0)
    AUTO_CAST(start_map_2)
    start_map_2:SetFontName("white_18_ol")
    start_map_2:SetText("Quest Start Map")
    local rewards, rewards_cnt = GetClassList("reward_property")
    local y = y + 40
    for i = 0, rewards_cnt - 1 do
        local reward_cls = GetClassByIndexFromList(rewards, i)
        if reward_cls.Property ~= "None" and reward_cls.Property ~= "AchievePoint" then
            local quest_cls = GetClass("QuestProgressCheck_Auto", reward_cls.ClassName)
            local script_btn = bg:CreateOrGetControl("button", "script_btn" .. i, 15, y, 20, 20)
            AUTO_CAST(script_btn)
            script_btn:SetSkinName("None")
            script_btn:SetText("{img quest_detail_pic2 20 20}")
            script_btn:SetTextTooltip(g.lang == "Japanese" and "{ol}クエスト詳細表示" or
                                          "{ol}Show quest information")
            script_btn:SetEventScript(ui.LBUTTONDOWN, "QUEST_CLICK_INFO")
            script_btn:SetEventScriptArgNumber(ui.LBUTTONDOWN, quest_cls.ClassID)
            local quest_name_2 = bg:CreateOrGetControl("richtext", "quest_name_2" .. i, 40, y, 0, 0)
            AUTO_CAST(quest_name_2)
            local quest_result_2 = bg:CreateOrGetControl("richtext", "quest_result_2" .. i, 400, y, 0, 0)
            AUTO_CAST(quest_result_2)
            local point_2 = bg:CreateOrGetControl("richtext", "point_2" .. i, 440, y, 0, 0)
            AUTO_CAST(point_2)
            local map_2 = bg:CreateOrGetControl("richtext", "map_2" .. i, 550, y, 0, 0)
            AUTO_CAST(map_2)
            local color = ""
            local result = "" -- ClMsg(reward_cls.Property)
            if status_point_check_quest_clear_check(quest_cls) then
                color = "{#FF3333}{ol}{b}{s16}"
                result = "OK"
            else
                color = "{#666666}{ol}{b}{s16}"
                result = "NO"
                local quest = GetClass("QuestProgressCheck", quest_cls.ClassName)
                local map_prop = geMapTable.GetMapProp(quest.StartMap)
                if map_prop then
                    local map_name = dictionary.ReplaceDicIDInCompStr(map_prop:GetName())
                    map_2:SetText(color .. map_name .. "[Level:" .. quest.Level .. "]")
                else
                    map_2:SetText(color .. "??[Level:" .. quest.Level .. "]")
                end
            end
            quest_name_2:SetText(color .. quest_cls.Name)
            quest_result_2:SetText(color .. result)
            if reward_cls.Property == "MaxWeight" then
                local suffix = g.lang == "Japanese" and "所持量" .. " + " .. reward_cls.Value or "Weight" .. " + " ..
                                   reward_cls.Value
                point_2:SetText(color .. suffix)
            else
                point_2:SetText(color .. ClMsg(reward_cls.Property) .. " + " .. reward_cls.Value)
            end
            y = y + 25
        end
    end
end

function status_point_check_quest_check(big_bg, bg)
    local title = bg:CreateOrGetControl("richtext", "title", 15, 5, 0, 0)
    AUTO_CAST(title)
    local start_map = bg:CreateOrGetControl("richtext", "start_map", 545, 5, 0, 0)
    AUTO_CAST(start_map)
    start_map:SetFontName("white_18_ol")
    start_map:SetText("Quest Start Map")
    local quests, quest_cnt = GetClassList("QuestProgressCheck_Auto")
    local sum_point = 0
    local get_point = 0
    local y = 35
    for i = 0, quest_cnt - 1 do
        local quest_cls = GetClassByIndexFromList(quests, i)
        if quest_cls.Success_StatByBonus and quest_cls.Success_StatByBonus > 0 then
            sum_point = sum_point + quest_cls.Success_StatByBonus
            local script_btn = bg:CreateOrGetControl("button", "script_btn" .. i, 15, y, 20, 20)
            AUTO_CAST(script_btn)
            script_btn:SetSkinName("None")
            script_btn:SetText("{img quest_detail_pic2 20 20}")
            script_btn:SetTextTooltip(g.lang == "Japanese" and "{ol}クエスト詳細表示" or
                                          "{ol}Show quest information")
            script_btn:SetEventScript(ui.LBUTTONDOWN, "QUEST_CLICK_INFO")
            script_btn:SetEventScriptArgNumber(ui.LBUTTONDOWN, quest_cls.ClassID)
            local quest_name = bg:CreateOrGetControl("richtext", "quest_name" .. i, 40, y, 0, 0)
            AUTO_CAST(quest_name)
            local quest_result = bg:CreateOrGetControl("richtext", "quest_result" .. i, 400, y, 0, 0)
            AUTO_CAST(quest_result)
            local point = bg:CreateOrGetControl("richtext", "point" .. i, 440, y, 0, 0)
            AUTO_CAST(point)
            local map = bg:CreateOrGetControl("richtext", "map" .. i, 550, y, 0, 0)
            AUTO_CAST(map)
            local color = ""
            local result = ""
            if status_point_check_quest_clear_check(quest_cls) then
                color = "{#FF3333}{ol}{b}{s16}"
                result = "OK"
                get_point = get_point + quest_cls.Success_StatByBonus
            else
                color = "{#666666}{ol}{b}{s16}"
                result = "NO"
                local quest = GetClassByType('QuestProgressCheck', quest_cls.ClassID)
                local map_prop = geMapTable.GetMapProp(quest.StartMap)
                if map_prop then
                    local map_name = dictionary.ReplaceDicIDInCompStr(map_prop:GetName())
                    map:SetText(color .. map_name .. "[Level:" .. quest.Level .. "]")
                else
                    map:SetText(color .. "??[Level:" .. quest.Level .. "]")
                end
            end
            quest_name:SetText(color .. quest_cls.Name)
            quest_result:SetText(color .. result)
            point:SetText(color .. quest_cls.Success_StatByBonus .. " Point")
            y = y + 25
        end
    end
    title:SetFontName("white_18_ol")
    title:SetText("Quest List For Status Point (" .. get_point .. "/" .. sum_point .. ")")
    return y
end

function status_point_check_quest_clear_check(quest_cls)
    local result = SCR_QUEST_CHECK(GetMyPCObject(), quest_cls.ClassName)
    if result == 'SUCCESS' or result == 'COMPLETE' then
        return true
    end
    return false
end
-- status_point_check ここまで

-- silent_velnice_ranking ここから
function silent_velnice_ranking_on_init()
    if g.settings.silent_velnice_ranking.use == 0 then
        return
    end
    if g.map_id == 8022 then
        g.addon:RegisterMsg("DO_SOLODUNGEON_SCOREBOARD_OPEN", "silent_velnice_ranking_SOLODUNGEON_SCOREBOARD_OPEN")
    end
end

function silent_velnice_ranking_SOLODUNGEON_SCOREBOARD_OPEN(frame, msg)
    local _nexus_addons = ui.GetFrame("_nexus_addons")
    _nexus_addons:SetVisible(1)
    local silent_velnice_ranking_timer = _nexus_addons:CreateOrGetControl("timer", "silent_velnice_ranking_timer", 0, 0)
    AUTO_CAST(silent_velnice_ranking_timer)
    silent_velnice_ranking_timer:SetUpdateScript("silent_velnice_ranking_keypress")
    silent_velnice_ranking_timer:Start(0.2)
end

function silent_velnice_ranking_keypress(_nexus_addons, silent_velnice_ranking_timer)
    local solodungeonscoreboard = ui.GetFrame("solodungeonscoreboard")
    if 1 == keyboard.IsKeyPressed("TAB") then
        SOLODUNGEON_SCOREBOARD_OPEN(nil, nil, nil, nil)
        silent_velnice_ranking_timer:Stop()
        return
    end
    if solodungeonscoreboard:IsVisible() == 1 then
        solodungeonscoreboard:ShowWindow(0)
    end
end
-- silent_velnice_ranking ここまで

-- save_quest ここから
function save_quest_save_settings()
    g.save_json(g.save_quest_path, g.save_quest_settings)
end

function save_quest_load_settings()
    g.save_quest_path = string.format("../addons/%s/%s/save_quest.json", addon_name_lower, g.active_id)
    local settings = g.load_json(g.save_quest_path)
    local changed = false
    if not settings then
        settings = {
            save_quests = {},
            short_cuts = {},
            frame = {
                move = 0,
                x = 0,
                y = 0
            }
        }
        changed = true
    end
    g.save_quest_settings = settings
    if changed then
        save_quest_save_settings()
    end
end

function save_quest_on_init()
    if not g.save_quest_settings then
        save_quest_load_settings()
    end
    if g.settings.save_quest.use == 0 then
        ui.DestroyFrame(addon_name_lower .. "save_quest")
        return
    end
    g.setup_hook_and_event(g.addon, "SET_QUEST_CTRL_MARK", "save_quest_SET_QUEST_CTRL_MARK", true)
    g.setup_hook_and_event(g.addon, "SCR_QUEST_SHARE_PARTY_MEMBER", "save_quest_SCR_QUEST_SHARE_PARTY_MEMBER", true)
    g.setup_hook_and_event(g.addon, "EXEC_ABANDON_QUEST", "save_quest_EXEC_ABANDON_QUEST", true)
    g.addon:RegisterMsg("TARGET_SET", "save_quest_ON_TARGET_SET")
    save_quest_npc_hide()
    save_quest_short_cut()
end

function save_quest_npc_hide()
    local objs, count = SelectObject(GetMyPCObject(), 1000, "ALL")
    local cnt = 0
    for i = 1, count do
        local handle = GetHandle(objs[i])
        if handle then
            if info.IsPC(handle) ~= 1 then
                cnt = cnt + 1
                local gen_type = world.GetActor(handle):GetNPCStateType()
                local pc = GetMyPCObject()
                local gen_list = SCR_GET_XML_IES('GenType_' .. GetZoneName(pc), 'GenType', gen_type)
                for j = 1, #gen_list do
                    local gen_obj = gen_list[j]
                    if g.save_quest_settings.save_quests[gen_obj.Dialog] == 1 then
                        world.Leave(handle, 0.0)
                        break
                    end
                end
            end
        end
    end
end

function save_quest_settings()
    local list_frame = ui.GetFrame(addon_name_lower .. "list_frame")
    local setting = ui.CreateNewFrame("notice_on_pc", addon_name_lower .. "save_quest_setting", 0, 0, 0, 0)
    AUTO_CAST(setting)
    setting:SetPos(list_frame:GetX() + list_frame:GetWidth(), list_frame:GetY())
    setting:SetSkinName("test_frame_low")
    setting:EnableHittestFrame(1)
    setting:EnableHitTest(1)
    setting:SetLayerLevel(999)
    setting:RemoveAllChild()
    local title_text = setting:CreateOrGetControl('richtext', 'title_text', 20, 15, 50, 30)
    AUTO_CAST(title_text)
    title_text:SetText("{ol}Save Quest Config")
    local close = setting:CreateOrGetControl("button", "close", 0, 0, 20, 20)
    AUTO_CAST(close)
    close:SetImage("testclose_button")
    close:SetGravity(ui.RIGHT, ui.TOP)
    close:SetEventScript(ui.LBUTTONUP, "save_quest_frame_close")
    local gbox = setting:CreateOrGetControl("groupbox", "gbox", 10, 40, 0, 0)
    AUTO_CAST(gbox)
    gbox:SetSkinName("test_frame_midle_light")
    local move_check = gbox:CreateOrGetControl('checkbox', "move_check", 10, 5, 30, 30)
    AUTO_CAST(move_check)
    move_check:SetCheck(g.save_quest_settings.frame.move)
    move_check:SetEventScript(ui.LBUTTONUP, "save_quest_check_switch")
    move_check:SetText(g.lang == "Japanese" and "{ol}チェックするとフレーム固定" or
                           "{ol}If checked, the frame is fixed")
    setting:Resize(300, 90)
    gbox:Resize(setting:GetWidth() - 20, setting:GetHeight() - 50)
    setting:ShowWindow(1)
end

function save_quest_frame_close(frame)
    ui.DestroyFrame(addon_name_lower .. "save_quest_setting")
end

function save_quest_check_switch(frame, move_check)
    g.save_quest_settings.frame.move = move_check:IsChecked()
    save_quest_save_settings()
    save_quest_short_cut()
end

function save_quest_EXEC_ABANDON_QUEST(my_frame, my_msg)
    if g.settings.save_quest.use == 0 then
        return
    end
    local quest_id = g.get_event_args(my_msg)
    save_quest_save(quest_id, "release")
    save_quest_short_cut_release(nil, nil, tostring(quest_id), nil)
end

function save_quest_SET_QUEST_CTRL_MARK(my_frame, my_msg)
    local ctrl, quest_cls, state = g.get_event_args(my_msg)
    if g.settings.save_quest.use == 0 then
        DESTROY_CHILD_BYNAME(ctrl, "save_text")
        DESTROY_CHILD_BYNAME(ctrl, "state_pic")
        return
    end
    local quest = ui.GetFrame("quest")
    local questBox = GET_CHILD(quest, "questBox")
    if questBox:GetSelectItemIndex() ~= 1 then
        return
    end
    AUTO_CAST(ctrl)
    local level = GET_CHILD(ctrl, "level")
    if level then
        AUTO_CAST(level)
        level:SetPos(0, 25)
    end
    local quest_id = quest_cls.ClassID
    local save_text = GET_CHILD(ctrl, "save_text")
    if save_text then
        DESTROY_CHILD_BYNAME(ctrl, "save_text")
    end

    local result = SCR_QUEST_CHECK_C(GetMyPCObject(), quest_cls.ClassName)
    local npc_state = quest_cls[CONVERT_STATE(result) .. 'NPC']
    if not npc_state then
        return
    end
    if not g.save_quest_settings.save_quests[npc_state] then
        g.save_quest_settings.save_quests[npc_state] = 0
    end
    if g.save_quest_settings.save_quests[npc_state] == 1 then
        local save_text = ctrl:CreateOrGetControl('richtext', "save_text", 0, 0, 20, 10)
        AUTO_CAST(save_text)
        save_text:SetText("{ol}saved")
        save_text:SetPos(330, 5)
    end
    if quest:IsVisible() == 1 then
        if save_quest_is_warp(quest_cls) == 1 then
            local quest = ui.GetFrame("quest")
            local quest_ctrl_set = GET_CHILD_RECURSIVELY(quest, ctrl:GetName())
            AUTO_CAST(quest_ctrl_set)
            quest_ctrl_set:SetEventScript(ui.RBUTTONDOWN, 'save_quest_menu')
            quest_ctrl_set:SetEventScriptArgString(ui.RBUTTONDOWN, quest_cls.Name)
            quest_ctrl_set:SetEventScriptArgNumber(ui.RBUTTONDOWN, quest_id)
            local state_pic = ctrl:CreateOrGetControl('picture', "state_pic", 0, 0, 20, 20)
            AUTO_CAST(state_pic)
            state_pic:SetEnableStretch(1)
            state_pic:SetImage("questinfo_return")
            state_pic:SetAngleLoop(-3)
            state_pic:EnableHitTest(1)
            state_pic:SetEventScript(ui.LBUTTONUP, "QUESTION_QUEST_WARP")
            state_pic:SetEventScriptArgNumber(ui.LBUTTONUP, quest_id)
            state_pic:SetEventScript(ui.RBUTTONUP, 'save_quest_menu')
            state_pic:SetEventScriptArgString(ui.RBUTTONUP, quest_cls.Name)
            state_pic:SetEventScriptArgNumber(ui.RBUTTONUP, quest_id)
            state_pic:SetTextTooltip(g.lang == "Japanese" and
                                         "{ol}[Save Quest]{nl}左クリック:ワープ{nl}右クリック:設定" or
                                         "{ol}[Save Quest]{nl}Left Click: Warp{nl}Right Click: Settings")
            state_pic:SetPos(380, 5)
        end
    end
end

function save_quest_menu(frame, ctrl, quest_name, quest_id)
    local menu_title = string.format("{ol}[%d] %s", quest_id, quest_name)
    local context = ui.CreateContextMenu("CONTEXT_save_quest", menu_title, 0, 0, string.len(menu_title) * 6, 100)
    ui.AddContextMenuItem(context, "Save", string.format("save_quest_save(%d,'%s')", quest_id, "save"))
    ui.AddContextMenuItem(context, "Release", string.format("save_quest_save(%d)", quest_id))
    ui.AddContextMenuItem(context, "ShortCut", string.format("save_quest_short_cut(%d)", quest_id))
    ui.AddContextMenuItem(context, "Cancel", "None")
    ui.OpenContextMenu(context)
end

function save_quest_save(quest_id, stat)
    local quest_cls = GetClassByType("QuestProgressCheck", quest_id)
    local result = SCR_QUEST_CHECK_C(GetMyPCObject(), quest_cls.ClassName)
    local npc_state = quest_cls[CONVERT_STATE(result) .. 'NPC']
    if stat == "save" then
        g.save_quest_settings.save_quests[npc_state] = 1
    else
        g.save_quest_settings.save_quests[npc_state] = nil
    end
    save_quest_save_settings()
    local quest = ui.GetFrame("quest")
    if quest:IsVisible() == 1 then
        local quest_ctrl_set = GET_CHILD_RECURSIVELY(quest, "_Q_" .. quest_id)
        AUTO_CAST(quest_ctrl_set)
        local quest_cls = GetClassByType("QuestProgressCheck", quest_id)
        SET_QUEST_CTRL_MARK(quest_ctrl_set, quest_cls)
    end
end

function save_quest_short_cut(quest_id)
    local save_quest = ui.GetFrame(addon_name_lower .. "save_quest")
    if not save_quest then
        save_quest = ui.CreateNewFrame("notice_on_pc", addon_name_lower .. "save_quest", 0, 0, 0, 0)
        AUTO_CAST(save_quest)
    end
    save_quest:SetSkinName("bg2")
    save_quest:EnableHittestFrame(1)
    save_quest:EnableMove(g.save_quest_settings.frame.move == 0 and 1 or 0)
    local x = g.save_quest_settings.frame.x
    local y = g.save_quest_settings.frame.y
    if x == 0 and y == 0 then
        x, y = 555, 200
    end
    save_quest:SetPos(x, y)
    save_quest:SetLayerLevel(81)
    save_quest:SetEventScript(ui.LBUTTONUP, "save_quest_frame_lbtn")
    if quest_id then
        local quest_cls = GetClassByType("QuestProgressCheck", quest_id)
        g.save_quest_settings.short_cuts[tostring(quest_id)] = 1
        save_quest_save_settings()
    end
    save_quest:ShowWindow(0)
    save_quest_short_cut_set(save_quest)
end

function save_quest_frame_lbtn(frame)
    g.save_quest_settings.frame.x = frame:GetX()
    g.save_quest_settings.frame.y = frame:GetY()
    save_quest_save_settings()
end

function save_quest_short_cut_set(save_quest)
    save_quest:RemoveAllChild()
    if not next(g.save_quest_settings.short_cuts) then
        return
    end
    local max_text_width = 0
    local y = 0
    local valid_quest_ids = {}
    for quest_id_str, _ in pairs(g.save_quest_settings.short_cuts) do
        local quest_id = tonumber(quest_id_str)
        local quest_cls = GetClassByType("QuestProgressCheck", quest_id)
        if quest_cls then
            if save_quest_is_warp(quest_cls) == 1 then
                local state_pic =
                    save_quest:CreateOrGetControl('picture', "state_pic" .. quest_id_str, 5, y + 5, 20, 20)
                AUTO_CAST(state_pic)
                state_pic:SetEnableStretch(1)
                state_pic:SetImage("questinfo_return")
                state_pic:SetAngleLoop(-3)
                state_pic:EnableHitTest(1)
                state_pic:SetEventScript(ui.LBUTTONUP, "QUESTION_QUEST_WARP")
                state_pic:SetEventScriptArgNumber(ui.LBUTTONUP, quest_id)
                state_pic:SetTooltipType('texthelp')
                state_pic:SetTooltipArg("{ol}" .. quest_cls.Name)
                state_pic:SetEventScript(ui.RBUTTONUP, "SAVEQUEST_OPEN_SHORTCUT_MENU")
                local map_info =
                    save_quest:CreateOrGetControl('richtext', "map_info" .. quest_id_str, 27, y + 10, 0, 30)
                AUTO_CAST(map_info)
                local result = SCR_QUEST_CHECK_Q(SCR_QUESTINFO_GET_PC(), quest_cls.ClassName)
                local map_name = quest_cls[CONVERT_STATE(result) .. 'Map']
                local zone_name = GetClassString('Map', map_name, 'Name')
                map_info:SetText(string.format("{s12}{ol}%s", zone_name))
                map_info:SetEventScript(ui.RBUTTONUP, "save_quest_short_cut_release")
                map_info:SetEventScriptArgString(ui.RBUTTONUP, quest_id_str)
                map_info:EnableHitTest(1)
                local text_w = map_info:GetWidth()
                if max_text_width < text_w then
                    max_text_width = text_w
                end
                local share_party = save_quest:CreateOrGetControl("picture", "share_party" .. quest_id_str, 0, y + 5,
                    20, 20)
                AUTO_CAST(share_party)
                share_party:SetEnableStretch(1)
                share_party:SetImage("btn_partyshare")
                share_party:EnableHitTest(1)
                share_party:SetTextTooltip(g.lang == "Japanese" and "{ol}クエストPTシェア切替" or
                                               "Quest PT Share Toggle")
                share_party:SetEventScript(ui.LBUTTONUP, "SCR_QUEST_SHARE_PARTY_MEMBER")
                share_party:SetEventScriptArgNumber(ui.LBUTTONUP, quest_id)
                if IS_SHARED_QUEST(quest_id) then
                    share_party:SetColorTone("FFFFFFFF")
                else
                    share_party:SetColorTone("FF696969")
                end
                table.insert(valid_quest_ids, quest_id_str)
                y = y + 30
            end
        end
    end
    local icon_align_x = 27 + max_text_width + 10
    for _, quest_id_str in ipairs(valid_quest_ids) do
        local share_party = save_quest:GetChild("share_party" .. quest_id_str)
        if share_party then
            share_party:SetOffset(icon_align_x, share_party:GetY())
        end
    end
    save_quest:Resize(icon_align_x + 30, y)
    save_quest:ShowWindow(1)
end

function save_quest_ON_TARGET_SET(frame, msg, str, num)
    local handle = session.GetTargetHandle()
    local gen_type = world.GetActor(handle):GetNPCStateType()
    local pc = GetMyPCObject()
    local gen_list = SCR_GET_XML_IES('GenType_' .. GetZoneName(pc), 'GenType', gen_type)
    for i = 1, #gen_list do
        local gen_obj = gen_list[i]
        if g.save_quest_settings.save_quests[gen_obj.Dialog] == 1 then
            world.Leave(handle, 0.0)
            break
        end
    end
end

function save_quest_SCR_QUEST_SHARE_PARTY_MEMBER()
    if g.settings.save_quest.use == 0 then
        ui.DestroyFrame(addon_name_lower .. "save_quest")
        return
    end
    local save_quest = ui.GetFrame(addon_name_lower .. "save_quest")
    if save_quest then
        save_quest_short_cut_set(save_quest)
    end
end

function save_quest_short_cut_release(frame, ctrl, quest_id_str, num)
    g.save_quest_settings.short_cuts[quest_id_str] = nil
    save_quest_save_settings()
    save_quest_short_cut()
end
-- ワープ可能か判定
function save_quest_is_warp(quest_cls)
    local result = SCR_QUEST_CHECK_C(GetMyPCObject(), quest_cls.ClassName)
    if not GET_QUEST_NPC_STATE(quest_cls, result) then
        return 0
    end
    if (result == 'POSSIBLE' and quest_cls.POSSI_WARP == 'YES') or
        (result == 'PROGRESS' and quest_cls.PROG_WARP == 'YES') or
        (result == 'SUCCESS' and quest_cls.SUCC_WARP == 'YES') then
        return 1
    end
    return 0
end
-- save_quest ここまで

-- skill_gem_tooltip ここから
function skill_gem_tooltip_on_init()
    g.setup_hook_and_event(g.addon, "UPDATE_ITEM_TOOLTIP", "skill_gem_tooltip_UPDATE_ITEM_TOOLTIP", true)
end

function skill_gem_tooltip_UPDATE_ITEM_TOOLTIP(my_frame, my_msg)
    if g.settings.skill_gem_tooltip == 0 then
        return
    end
    local tooltip_frame, str_arg, class_id, item_guid, user_data, arg_6, arg_7 = g.get_event_args(my_msg)
    local rect = tooltip_frame:GetMargin()
    local skill_name
    if str_arg == "inven" then
        local item_obj, is_read_obj = GET_TOOLTIP_ITEM_OBJECT(str_arg, item_guid, class_id)
        class_id = item_obj.ClassID
    end
    local item_cls = GetClassByType('Item', class_id)
    if not item_cls or TryGetProp(item_cls, 'StringArg', 'None') ~= 'SkillGem' then
        return
    end
    local skill_name = TryGetProp(item_cls, 'SkillName', 'None')
    if skill_name == 'None' then
        return
    end
    local skill_cls = GetClass('Skill', skill_name)
    if not skill_cls then
        return
    end
    local sub_frame_name = addon_name_lower .. "skill_gem_sub_tooltip"
    local sub_frame = ui.GetFrame(sub_frame_name)
    if not sub_frame then
        sub_frame = ui.CreateNewFrame("notice_on_pc", sub_frame_name, 0, 0, 0, 0)
        AUTO_CAST(sub_frame)
    end
    local template_frame = ui.GetTooltipFrame("skill")
    sub_frame:CloneFrom(template_frame)
    sub_frame:Resize(template_frame:GetWidth(), template_frame:GetHeight())
    sub_frame:RemoveAllChild()
    local function clone_child(src, dest)
        for i = 0, src:GetChildCount() - 1 do
            local child_src = src:GetChildByIndex(i)
            local child_dest = dest:CreateOrGetControl(child_src:GetClassName(), child_src:GetName(), child_src:GetX(),
                child_src:GetY(), child_src:GetWidth(), child_src:GetHeight())
            AUTO_CAST(child_dest)
            child_dest:CloneFrom(child_src)
            if child_src:GetChildCount() > 0 then
                clone_child(child_src, child_dest)
            end
        end
    end
    clone_child(template_frame, sub_frame)
    UPDATE_SKILL_TOOLTIP(sub_frame, str_arg, skill_cls.ClassID, 1, nil, nil)
    local skill_desc = sub_frame:GetChild("skill_desc")
    if skill_desc then
        AUTO_CAST(skill_desc)
        local skill_full_name = TryGetProp(item_cls, 'SkillName', 'None')
        local parts = StringSplit(skill_full_name, '_')
        local job_eng_name = parts[1]
        local suffix_key = parts[3]
        local job_suffix_map = {
            ["Archer"] = "[A]",
            ["Scout"] = "[T]",
            ["Cleric"] = "[C]",
            ["Swordman"] = "[S]",
            ["Wizard"] = "[W]"
        }
        local suffix = job_suffix_map[suffix_key] or ""
        local job_name_fix_map = {
            ["Outlaw"] = "OutLaw",
            ["FrostMage"] = "Cryomancer",
            ["Lancer"] = "Rancer",
            ["FireMage"] = "Pyromancer",
            ["Warrior"] = "Swordman",
            ["Templar"] = "Templer"
        }
        job_eng_name = job_name_fix_map[job_eng_name] or job_eng_name
        local list, cnt = GetClassList("Job")
        for i = 0, cnt - 1 do
            local job_cls = GetClassByIndexFromList(list, i)
            if job_cls then
                local eng_name = job_name_fix_map[job_cls.EngName] or job_cls.EngName
                if eng_name == job_eng_name then
                    local display_name = GET_JOB_NAME(job_cls, GETMYPCGENDER())
                    display_name = string.gsub(dic.getTranslatedStr(display_name), "%[.-%]", "") .. suffix
                    local mark_text = skill_desc:CreateOrGetControl("richtext", "mark_skillgem", 0, 0, 200, 20)
                    mark_text:SetText(string.format("{ol}{#999999}Skill Gem Tooltip{/}{nl}{s18}%s", display_name))
                    mark_text:SetOffset(20, 10)
                    mark_text:SetGravity(ui.LEFT, ui.TOP)
                    local rect = tooltip_frame:GetMargin()
                    if str_arg == "inven" then
                        sub_frame:SetGravity(ui.RIGHT, ui.TOP)
                        sub_frame:SetOffset(rect.right - 250 + tooltip_frame:GetWidth(), 190)
                    elseif str_arg == "char_belonging" then
                        sub_frame:SetGravity(ui.RIGHT, ui.TOP)
                        sub_frame:SetOffset(rect.right - 270 + tooltip_frame:GetWidth(), 255)
                    else
                        sub_frame:SetGravity(ui.LEFT, ui.TOP)
                        sub_frame:SetOffset(rect.left + tooltip_frame:GetWidth(), 255)
                    end
                    sub_frame:SetLayerLevel(tooltip_frame:GetLayerLevel() + 10)
                    sub_frame:RunUpdateScript("skill_gem_tooltip_close", 0.1)
                    sub_frame:SetUserValue("FLAME_NAME", tooltip_frame:GetName())
                    sub_frame:ShowWindow(1)
                    return
                end
            end
        end
    end
end

function skill_gem_tooltip_close(sub_frame)
    local obj = ui.GetFocusObject()
    if not obj then
        ui.DestroyFrame(addon_name_lower .. "skill_gem_sub_tooltip")
        return 0
    elseif obj:GetClassName() ~= "slot" then
        ui.DestroyFrame(addon_name_lower .. "skill_gem_sub_tooltip")
        return 0
    end
    return 1
end
-- skill_gem_tooltip ここまで

-- separate_buff_custom ここから
function separate_buff_custom_save_settings()
    g.save_json(g.separate_buff_custom_path, g.separate_buff_custom_settings)
end

function separate_buff_custom_load_settings()
    g.separate_buff_custom_path = string.format("../addons/%s/%s/separate_buff_custom.json", addon_name_lower,
        g.active_id)
    local settings = g.load_json(g.separate_buff_custom_path)
    if not settings then
        settings = {
            x = 0,
            y = 0,
            move = 1,
            sep_buffs = {},
            location_share = 0,
            tracking = 0
        }
    end
    g.separate_buff_custom_settings = settings
    separate_buff_custom_save_settings()
end

function separate_buff_custom_on_init()
    if not g.separate_buff_custom_settings then
        separate_buff_custom_load_settings()
    end
    g.setup_hook_and_event(g.addon, "BUFF_SEPARATEDLIST_CTRLSET_CREATE",
        "separate_buff_custom_BUFF_SEPARATEDLIST_CTRLSET_CREATE", true)
    g.setup_hook_and_event(g.addon, "BUFF_SEPARATEDLIST_CTRLSET_REMOVE",
        "separate_buff_custom_BUFF_SEPARATEDLIST_CTRLSET_REMOVE", true)
    g.setup_hook_and_event(g.addon, "BUFF_SEPARATEDLIST_ON_RELOAD", "separate_buff_custom_BUFF_SEPARATEDLIST_ON_RELOAD",
        true)
    g.setup_hook_and_event(g.addon, "BUFF_SEPARATED_TIME_UPDATE", "separate_buff_custom_BUFF_SEPARATED_TIME_UPDATE",
        false)
    g.separate_buff_custom_temp_buffs = {}
    separate_buff_custom_frame_move()
end

function separate_buff_custom_buff_separatedlist_save_pos(frame)
    local x = frame:GetX()
    local y = frame:GetY()
    local userID = session.loginInfo.GetUserID()
    local path = string.format('../release/addon_setting/buff_separatedlist/%s/settings.json', userID)
    local settings = g.load_json(path)
    if not settings then
        settings = {
            pc_id = {}
        }
    end
    if not settings.pc_id then
        settings.pc_id = {}
    end
    local cid = session.GetMySession():GetCID()
    if not settings.pc_id[g.cid] then
        settings.pc_id[cid] = {}
    end
    if not settings.pc_id[g.cid]["pos"] then
        settings.pc_id[g.cid]["pos"] = {}
    end
    local current_pos = settings.pc_id[cid].pos
    if current_pos.x ~= x or current_pos.y ~= y then
        current_pos.x = x
        current_pos.y = y
        g.save_json(path, settings)
    end
end

function separate_buff_custom_BUFF_SEPARATED_TIME_UPDATE(my_frame, my_msg)
    local frame, timer, argstr, argnum, passedtime = g.get_event_args(my_msg)
    local myhandle = session.GetMyHandle()
    local TOKEN_BUFF_ID = TryGetProp(GetClass("Buff", "Premium_Token"), "ClassID")
    local gbox = GET_CHILD_RECURSIVELY(frame, "buffGBox")
    if gbox == nil then
        return
    end
    local updated = 0
    local cnt = gbox:GetChildCount()
    for i = 1, cnt do
        local ctrlSet = gbox:GetChildByIndex(i - 1)
        if ctrlSet ~= nil then
            local slot = GET_CHILD_RECURSIVELY(ctrlSet, "slot")
            local text = GET_CHILD_RECURSIVELY(ctrlSet, "caption")
            if slot:IsVisible() == 1 then
                local icon = slot:GetIcon()
                local iconInfo = icon:GetInfo()
                local buffIndex = icon:GetUserIValue("BuffIndex")
                local buff = info.GetBuff(myhandle, iconInfo.type, buffIndex)
                if buff ~= nil then
                    text:SetText(GET_BUFF_TIME_TXT(buff.time, 0))
                    updated = 1
                    if buff.time < 5000 and buff.time ~= 0.0 then
                        if slot:IsBlinking() == 0 then
                            slot:SetBlink(600000, 1.0, "55FFFFFF", 1)
                        end
                    elseif buff.buffID == TOKEN_BUFF_ID and GET_REMAIN_TOKEN_SEC() < 3600 then
                        if slot:IsBlinking() == 0 then
                            slot:SetBlink(0, 1.0, "55FFFFFF", 1)
                        end
                    else
                        if slot:IsBlinking() == 1 then
                            slot:ReleaseBlink()
                        end
                    end
                end
            end
        end
    end
    if updated == 1 then
        ui.UpdateVisibleToolTips("buff")
    end
end

function separate_buff_custom_BUFF_SEPARATEDLIST_ON_RELOAD(my_frame, my_msg)
    local frame = g.get_event_args(my_msg)
    separate_buff_custom_frame_move()
    if g.settings.separate_buff_custom.use == 0 then
        INIT_BUFF_SEPARATEDLIST_UI(frame)
        frame:SetEventScript(ui.LBUTTONUP, "separate_buff_custom_buff_separatedlist_save_pos")
    end
end

function separate_buff_custom_restore_vanilla_position(frame)
    frame:EnableMove(1)
    frame:EnableHittestFrame(1)
    local path_format = string.format("../release/addon_setting/buff_separatedlist/%s/settings.json", g.active_id)
    local settings = g.load_json(path_format)
    if settings and settings.pc_id and settings.pc_id[g.cid] and settings.pc_id[g.cid].pos then
        local pos = settings.pc_id[g.cid].pos
        frame:MoveFrame(pos.x, pos.y)
    end
end

function separate_buff_custom_frame_move()
    local frame = ui.GetFrame("buff_separatedlist")
    frame:StopUpdateScript("_FRAME_AUTOPOS")
    frame:SetEventScript(ui.LBUTTONUP, "separate_buff_custom_end_drag")
    if g.settings.separate_buff_custom.use == 0 then
        separate_buff_custom_restore_vanilla_position(frame)
        return
    end
    if (g.separate_buff_custom_settings.location_share == 0 and g.separate_buff_custom_settings.tracking == 0) then
        separate_buff_custom_restore_vanilla_position(frame)
        return
    end
    if g.separate_buff_custom_settings.tracking == 1 then
        frame:EnableMove(0)
        frame:EnableHittestFrame(0)
        local my_handle = session.GetMyHandle()
        FRAME_AUTO_POS_TO_OBJ(frame, my_handle, 30, -40, 3, 1)
        return
    end
    if g.separate_buff_custom_settings.location_share == 1 then
        frame:EnableMove(g.separate_buff_custom_settings.move)
        frame:EnableHittestFrame(g.separate_buff_custom_settings.move)
        frame:MoveFrame(g.separate_buff_custom_settings.x, g.separate_buff_custom_settings.y)
        return
    end
end

function separate_buff_custom_end_drag(frame)
    if g.separate_buff_custom_settings.location_share == 1 then
        g.separate_buff_custom_settings.x = frame:GetX()
        g.separate_buff_custom_settings.y = frame:GetY()
        separate_buff_custom_save_settings()
    end
end

function separate_buff_custom_BUFF_SEPARATEDLIST_CTRLSET_CREATE(my_frame, my_msg)
    if g.settings.separate_buff_custom.use == 0 then
        return
    end
    local frame, my_handle, buff_index, buff_id = g.get_event_args(my_msg)
    if ui.buff.IsBuffSeparate(buff_id) == 1 then
        return
    end
    local setting = g.separate_buff_custom_settings.sep_buffs[tostring(buff_id)]
    if setting and setting.display == 1 then
        local buff = info.GetBuff(my_handle, buff_id)
        local buff_cls = GetClassByType("Buff", buff_id)
        CTRLSET_CREATE(frame, my_handle, buff, buff_cls, buff_index, buff_id)
        local gbox = GET_CHILD_RECURSIVELY(frame, "buffGBox")
        if gbox then
            local ctrl_set = GET_CHILD(gbox, "BUFFSLOT_buff" .. buff_id)
            if ctrl_set then
                local slot = GET_CHILD_RECURSIVELY(ctrl_set, "slot")
                if buff_cls.OverBuff <= buff.over then
                    if setting.with_effect == 1 and not g.separate_buff_custom_temp_buffs[tostring(buff_id)] then
                        local my_handle = session.GetMyHandle()
                        local actor = world.GetActor(my_handle)
                        effect.PlayActorEffect(actor, 'F_pattern025_loop', 'None', 1.0, 1.5)
                        imcSound.PlaySoundEvent("sys_cube_open_jackpot")
                        g.separate_buff_custom_temp_buffs[tostring(buff_id)] = true
                    end
                    slot:SetText('{s30}{ol}{#FF0000}' .. buff.over, 'count', ui.RIGHT, ui.BOTTOM, 0, 0)
                elseif buff.over > 1 then
                    slot:SetText('{s30}{ol}{b}' .. buff.over, 'count', ui.RIGHT, ui.BOTTOM, 0, 0)
                end
                slot:AdjustFontSizeByWidth(30)
            end
        end
    end
end

function separate_buff_custom_BUFF_SEPARATEDLIST_CTRLSET_REMOVE(my_frame, my_msg)
    if g.settings.separate_buff_custom.use == 0 then
        return
    end
    local frame, my_handle, buff_index, buff_id = g.get_event_args(my_msg)
    local buff_cls = GetClassByType("Buff", buff_id)
    if buff_cls then
        local setting = g.separate_buff_custom_settings.sep_buffs[tostring(buff_id)]
        if setting and setting.display == 1 then
            g.separate_buff_custom_temp_buffs[tostring(buff_id)] = false
            CTRLSET_REMOVE(frame, "buff", buff_id)
        end
    end
end

function separate_buff_custom_settings(buff_list, ctrl, ctrl_text)
    local buff_list = ui.GetFrame(addon_name_lower .. "separate_buff_custom_buff_list")
    local search_edit
    if not buff_list then
        buff_list = ui.CreateNewFrame("notice_on_pc", addon_name_lower .. "separate_buff_custom_buff_list", 0, 0, 0, 0)
        AUTO_CAST(buff_list)
        buff_list:SetSkinName("test_frame_low")
        buff_list:SetPos(150, 10)
        buff_list:SetLayerLevel(999)
        search_edit = buff_list:CreateOrGetControl("edit", "search_edit", 40, 10, 305, 38)
        AUTO_CAST(search_edit)
        search_edit:SetFontName("white_18_ol")
        search_edit:SetTextAlign("left", "center")
        search_edit:SetSkinName("inventory_serch")
        search_edit:SetEventScript(ui.ENTERKEY, "separate_buff_custom_buff_list_search")
        local search_btn = search_edit:CreateOrGetControl("button", "search_btn", 0, 0, 40, 38)
        AUTO_CAST(search_btn)
        search_btn:SetImage("inven_s")
        search_btn:SetGravity(ui.RIGHT, ui.TOP)
        search_btn:SetEventScript(ui.LBUTTONUP, "separate_buff_custom_buff_list_search")
        local location = buff_list:CreateOrGetControl('checkbox', 'location', 355, 10, 30, 30)
        AUTO_CAST(location)
        location:SetTextTooltip(g.lang == "Japanese" and
                                    "{ol}チェックすると{nl}セパレートバフフレームの位置を各キャラ共有" or
                                    "{ol}If checked{nl}location of the separated buff frame{nl}is shared by all characters")
        location:SetCheck(g.separate_buff_custom_settings.location_share or 0)
        location:SetEventScript(ui.LBUTTONUP, "separate_buff_custom_buff_toggle")
        local move = buff_list:CreateOrGetControl('checkbox', 'move', 390, 10, 30, 30)
        AUTO_CAST(move)
        move:SetTextTooltip(g.lang == "Japanese" and
                                "{ol}チェックすると{nl}セパレートバフフレームの位置を固定" or
                                "{ol}If checked{nl}{nl}fixes the position of the separate buff frame")
        move:SetCheck(g.separate_buff_custom_settings.move == 1 and 0 or 1)
        move:SetEventScript(ui.LBUTTONUP, "separate_buff_custom_buff_toggle")
        local tracking = buff_list:CreateOrGetControl('checkbox', 'tracking', 425, 10, 30, 30)
        AUTO_CAST(tracking)
        tracking:SetTextTooltip(g.lang == "Japanese" and
                                    "{ol}チェックすると{nl}セパレートバフフレーム追従モード" or
                                    "{ol}If checked{nl}{nl}Separate Buff Frame Tracking Mode")
        tracking:SetCheck(g.separate_buff_custom_settings.tracking or 0)
        tracking:SetEventScript(ui.LBUTTONUP, "separate_buff_custom_buff_toggle")
        local close = buff_list:CreateOrGetControl('button', 'close', 0, 0, 20, 20)
        AUTO_CAST(close)
        close:SetImage("testclose_button")
        close:SetGravity(ui.RIGHT, ui.TOP)
        close:SetEventScript(ui.LBUTTONUP, "separate_buff_custom_frame_close")
    else
        search_edit = GET_CHILD_RECURSIVELY(buff_list, "search_edit")
    end
    if ctrl_text then
        search_edit:SetText(ctrl_text)
    end
    local buff_list_gb = buff_list:CreateOrGetControl("groupbox", "buff_list_gb", 10, 50, 480,
        buff_list:GetHeight() - 60)
    AUTO_CAST(buff_list_gb)
    buff_list_gb:SetSkinName("bg")
    buff_list_gb:RemoveAllChild()
    local cls_list, count = GetClassList("Buff")
    local search_lower = (ctrl_text and ctrl_text ~= "") and string.lower(ctrl_text) or nil
    local all_buffs = {}
    for i = 0, count - 1 do
        local buff_cls = GetClassByIndexFromList(cls_list, i)
        if buff_cls then
            local buff_name = dictionary.ReplaceDicIDInCompStr(buff_cls.Name)
            if not search_lower or string.find(string.lower(buff_name), search_lower) then
                local image_name = GET_BUFF_ICON_NAME(buff_cls)
                if image_name ~= "icon_None" and buff_name ~= "None" then
                    local buff_id_str = tostring(buff_cls.ClassID)
                    local setting = g.separate_buff_custom_settings.sep_buffs[buff_id_str]
                    local display = 0
                    local with_effect = 0
                    if setting then
                        display = setting.display or 0
                        with_effect = setting.with_effect or 0
                    end
                    table.insert(all_buffs, {
                        cls = buff_cls,
                        name = buff_name,
                        image = image_name,
                        display = display,
                        with_effect = with_effect
                    })
                end
            end
        end
    end
    table.sort(all_buffs, function(a, b)
        if a.display == 1 and b.display ~= 1 then
            return true
        elseif a.display ~= 1 and b.display == 1 then
            return false
        else
            return a.cls.ClassID < b.cls.ClassID
        end
    end)
    g.separate_buff_custom_x = g.separate_buff_custom_x or 0
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
        local with_effect = buff_list_gb:CreateOrGetControl('checkbox', 'with_effect' .. buff_id, 50, y + 10, 30, 30)
        AUTO_CAST(with_effect)
        with_effect:SetTextTooltip(g.lang == "Japanese" and "{ol}チェックするとエフェクト表示" or
                                       "{ol}If checked, show effect")
        with_effect:SetCheck(buff_data.with_effect or 0)
        with_effect:SetEventScript(ui.LBUTTONUP, "separate_buff_custom_buff_toggle")
        with_effect:SetEventScriptArgNumber(ui.LBUTTONUP, buff_id)
        with_effect:SetEventScriptArgString(ui.LBUTTONUP, search_edit:GetText())
        local buff_check = buff_list_gb:CreateOrGetControl('checkbox', 'buff_check' .. buff_id, 80, y + 10, 200, 30)
        AUTO_CAST(buff_check)
        buff_check:SetText("{ol}" .. buff_id .. " : " .. buff_data.name)
        if g.separate_buff_custom_x < buff_check:GetWidth() then
            g.separate_buff_custom_x = buff_check:GetWidth()
        end
        buff_check:SetTextTooltip(g.lang == "Japanese" and
                                      "{ol}チェックするとセパレートバフフレームに表示" or
                                      "{ol}If checked, display on the separated buff frame")
        buff_check:SetCheck(buff_data.display or 0)
        buff_check:SetEventScript(ui.LBUTTONUP, "separate_buff_custom_buff_toggle")
        buff_check:SetEventScriptArgNumber(ui.LBUTTONUP, buff_id)
        buff_check:SetEventScriptArgString(ui.LBUTTONUP, search_edit:GetText())
        y = y + 35
    end
    buff_list:Resize(g.separate_buff_custom_x + 20, 1060)
    buff_list_gb:Resize(g.separate_buff_custom_x, buff_list:GetHeight() - 60)
    buff_list_gb:SetScrollPos(0)
    buff_list:ShowWindow(1)
end

function separate_buff_custom_buff_toggle(buff_list, ctrl, ctrl_text, buff_id)
    local str_id = tostring(buff_id)
    local changed = false
    if not g.separate_buff_custom_settings.sep_buffs[str_id] then
        g.separate_buff_custom_settings.sep_buffs[str_id] = {}
    end
    local setting = g.separate_buff_custom_settings.sep_buffs[str_id]
    if string.find(ctrl:GetName(), "buff_check") then
        if ctrl:IsChecked() == 1 then
            setting.display = 1
        else
            g.separate_buff_custom_settings.sep_buffs[str_id] = nil
            changed = true
        end
    elseif string.find(ctrl:GetName(), "with_effect") then
        setting.with_effect = ctrl:IsChecked()
    else
        if ctrl:GetName() == "location" then
            g.separate_buff_custom_settings.location_share = ctrl:IsChecked()
            local buff_separatedlist = ui.GetFrame("buff_separatedlist")
            g.separate_buff_custom_settings.x = buff_separatedlist:GetX()
            g.separate_buff_custom_settings.y = buff_separatedlist:GetY()
        elseif ctrl:GetName() == "move" then
            g.separate_buff_custom_settings.move = ctrl:IsChecked() == 1 and 0 or 1
        elseif ctrl:GetName() == "tracking" then
            g.separate_buff_custom_settings.tracking = ctrl:IsChecked()
        end
        separate_buff_custom_frame_move()
    end
    separate_buff_custom_save_settings()
    if changed then
        separate_buff_custom_settings(buff_list, ctrl, ctrl_text)
    end
end

function separate_buff_custom_buff_list_search(buff_list, ctrl, ctrl_text, num)
    local buff_list = ui.GetFrame(addon_name_lower .. "separate_buff_custom_buff_list")
    local search_edit = GET_CHILD_RECURSIVELY(buff_list, "search_edit")
    local ctrl_text = search_edit:GetText()
    if ctrl_text ~= "" then
        separate_buff_custom_settings(buff_list, ctrl, ctrl_text)
    else
        separate_buff_custom_settings(buff_list, ctrl, "")
    end
end

function separate_buff_custom_frame_close(buff_list)
    ui.DestroyFrame(buff_list:GetName())
end
-- separate_buff_custom ここまで

-- sub_map ここから
function sub_map_save_settings()
    g.save_json(g.sub_map_path, g.sub_map_settings)
end

function sub_map_load_settings()
    g.sub_map_path = string.format("../addons/%s/%s/sub_map.json", addon_name_lower, g.active_id)
    local settings = g.load_json(g.sub_map_path)
    if not settings then
        settings = {
            visible = 1,
            x = 0,
            y = 0,
            skin_name = "None",
            move = 1,
            size = 200,
            minimap = 0
        }
    end
    g.sub_map_settings = settings
    sub_map_save_settings()
end

function sub_map_on_init()
    if not g.sub_map_settings then
        sub_map_load_settings()
    end
    if g.settings.sub_map.use == 0 then
        ui.DestroyFrame(addon_name_lower .. "sub_map")
        return
    end
    g.sub_map_handles = {}
    g.addon:RegisterMsg("MAP_CHARACTER_UPDATE", "sub_map_MAP_CHARACTER_UPDATE")
    g.addon:RegisterMsg("MON_MINIMAP", "sub_map_MAP_MON_MINIMAP")
    g.addon:RegisterMsg('MON_MINIMAP_END', 'sub_map_ON_MON_MINIMAP_END')
    g.addon:RegisterMsg("PARTY_INST_UPDATE", "sub_map_MAP_UPDATE_PARTY_INST")
    g.addon:RegisterMsg("PARTY_UPDATE", "sub_map_update_party_or_guild")
    g.addon:RegisterMsg("GUILD_INFO_UPDATE", "sub_map_update_party_or_guild")
    local _nexus_addons = ui.GetFrame("_nexus_addons")
    _nexus_addons:SetVisible(1)
    local init_sub_map_timer = _nexus_addons:CreateOrGetControl("timer", "init_sub_map_timer", 0, 0)
    AUTO_CAST(init_sub_map_timer)
    init_sub_map_timer:SetUpdateScript("sub_map_frame_init")
    init_sub_map_timer:Stop()
    if g.get_map_type() ~= "Instance" then
        init_sub_map_timer:Start(2.0)
    end
    local colony_list, cnt = GetClassList('guild_colony')
    for i = 0, cnt - 1 do
        local colonyCls = GetClassByIndexFromList(colony_list, i)
        local check_word = "GuildColony_"
        if string.find(g.map_name, check_word) then
            init_sub_map_timer:Start(2.5)
            break
        end
    end
end

function sub_map_settings()
    local list_frame = ui.GetFrame(addon_name_lower .. "list_frame")
    local config = ui.CreateNewFrame("notice_on_pc", addon_name_lower .. "sub_map_setting_frame", 0, 0, 0, 0)
    AUTO_CAST(config)
    config:RemoveAllChild()
    config:SetLayerLevel(999)
    config:SetSkinName("test_frame_low")
    local title_text = config:CreateOrGetControl("richtext", "title_text", 10, 10)
    AUTO_CAST(title_text)
    title_text:SetText("{ol}Sub Map")
    local config_gb = config:CreateOrGetControl("groupbox", "config_gb", 10, 40, 0, 0)
    AUTO_CAST(config_gb)
    config_gb:SetSkinName("bg")
    config:SetPos(list_frame:GetX() + list_frame:GetWidth(), list_frame:GetY())
    local close = config:CreateOrGetControl("button", "close", 0, 0, 20, 20)
    AUTO_CAST(close)
    close:SetImage("testclose_button")
    close:SetGravity(ui.RIGHT, ui.TOP)
    close:SetEventScript(ui.LBUTTONUP, "sub_map_setting_close")
    local y = 10
    local info_text = config_gb:CreateOrGetControl('richtext', 'info_text', 10, y + 5, 0, 30)
    AUTO_CAST(info_text)
    info_text:SetText(g.lang == "Japanese" and "{ol}サイズ設定" or "{ol}Size setting")
    local size_edit = config_gb:CreateOrGetControl('edit', 'size_edit', info_text:GetWidth() + 20, y, 100, 30)
    AUTO_CAST(size_edit)
    size_edit:SetFontName("white_16_ol")
    size_edit:SetTextAlign("center", "center")
    size_edit:SetNumberMode(1)
    size_edit:SetText("{ol}" .. g.sub_map_settings.size)
    size_edit:SetTextTooltip(g.lang == "Japanese" and "{ol}150~350の間で設定" or "{ol}Setting range: 150 to 350")
    size_edit:SetEventScript(ui.ENTERKEY, "sub_map_setting_change")
    y = y + 40
    local move_check = config_gb:CreateOrGetControl('checkbox', "move_check", 10, y, 30, 30)
    AUTO_CAST(move_check)
    move_check:SetCheck(g.sub_map_settings.move == 1 and 0 or 1)
    move_check:SetText(g.lang == "Japanese" and "{ol}チェックするとフレーム固定" or
                           "{ol}If checked, the frame is fixed")
    move_check:SetEventScript(ui.LBUTTONUP, "sub_map_setting_change")
    y = y + 40
    local challenge_check = config_gb:CreateOrGetControl('checkbox', "challenge_check", 10, y, 30, 30)
    AUTO_CAST(challenge_check)
    challenge_check:SetCheck(g.sub_map_settings.move == 1 and 0 or 1)
    challenge_check:SetText(g.lang == "Japanese" and
                                "{ol}チェックするとチャレンジでミニマップモード" or
                                "{ol}If checked, mini-map mode is enabled during the Challenge")
    challenge_check:SetEventScript(ui.LBUTTONUP, "sub_map_setting_change")
    y = y + 40
    local default_btn = config_gb:CreateOrGetControl("button", "default_btn", 20, y, 120, 30)
    AUTO_CAST(default_btn)
    default_btn:SetText(g.lang == "Japanese" and "{ol}フレーム初期位置" or "{ol}Init frame pos")
    default_btn:SetEventScript(ui.LBUTTONUP, "sub_map_setting_change")
    y = y + 40
    local skin_change = config_gb:CreateOrGetControl("button", "skin_change", 20, y, 120, 30)
    AUTO_CAST(skin_change)
    skin_change:SetText(g.lang == "Japanese" and "{ol}フレームスキン変更" or "{ol}Change frame skin")
    skin_change:SetEventScript(ui.LBUTTONUP, "sub_map_skin_change_context")
    y = y + 30
    config:Resize(300, y + 60)
    config_gb:Resize(config:GetWidth() - 20, y + 10)
    config:ShowWindow(1)
end

function sub_map_setting_close(config)
    ui.DestroyFrame(config:GetName())
end

function sub_map_setting_change(parent, ctrl)
    local ctrl_name = ctrl:GetName()
    if ctrl_name == "size_edit" then
        local size = tonumber(ctrl:GetText())
        if size and size >= 150 and size <= 350 then
            g.sub_map_settings.size = size
        else
            ui.SysMsg(g.lang == "Japanese" and "{ol}範囲外です" or "{ol}Out of range")
            sub_map_settings()
            return
        end
    elseif ctrl_name == "move_check" then
        local is_check = ctrl:IsChecked()
        g.sub_map_settings.move = is_check == 1 and 0 or 1
    elseif ctrl_name == "default_btn" then
        g.sub_map_settings.x = 0
        g.sub_map_settings.y = 0
    end
    sub_map_save_settings()
    sub_map_frame_init()
end

function sub_map_skin_change_context(frame, ctrl)
    local context = ui.CreateContextMenu("sub_map_context", "{ol}Sub Map Change Skin", 0, 0, 0, 0)
    ui.AddContextMenuItem(context, "-----", "None")
    ui.AddContextMenuItem(context, g.lang == "Japanese" and "{ol}無し" or "{ol}None",
        string.format("sub_map_skin_change('%s')", "None"))
    ui.AddContextMenuItem(context, g.lang == "Japanese" and "{ol}薄め" or "{ol}Faint",
        string.format("sub_map_skin_change('%s')", "bg2"))
    ui.AddContextMenuItem(context, g.lang == "Japanese" and "{ol}濃いめ" or "{ol}Darker",
        string.format("sub_map_skin_change('%s')", "bg"))
    ui.OpenContextMenu(context)
end

function sub_map_skin_change(skin_name)
    g.sub_map_settings.skin_name = skin_name
    sub_map_save_settings()
    sub_map_frame_init()
end

function sub_map_frame_init(_nexus_addons, init_sub_map_timer)
    if init_sub_map_timer then
        init_sub_map_timer:Stop()
    end
    local sub_map = ui.CreateNewFrame("notice_on_pc", addon_name_lower .. "sub_map", 0, 0, 0, 0)
    AUTO_CAST(sub_map)
    sub_map:ShowWindow(0)
    local is_auto_challenge = session.IsAutoChallengeMap()
    local is_solo_challenge = session.IsSoloChallengeMap()
    local challenge = 0
    if is_auto_challenge or is_solo_challenge then
        challenge = 1
    end
    sub_map:SetUserValue("CHALLENGE", challenge)
    sub_map:StopUpdateScript("sub_map_frame_init")
    sub_map:RemoveAllChild()
    sub_map:EnableMove(g.sub_map_settings.move)
    sub_map:EnableHittestFrame(1)
    sub_map:SetTitleBarSkin("None")
    sub_map:SetGravity(ui.RIGHT, ui.TOP)
    sub_map:SetMargin(0, 0, 0, 0)
    if g.sub_map_settings.minimap == 0 then
        sub_map:SetSkinName(g.sub_map_settings.skin_name)
        sub_map:SetLayerLevel(12)
        local rect = sub_map:GetMargin()
        sub_map:SetMargin(rect.left - rect.left, rect.top - rect.top + 50,
            rect.right == 0 and rect.right + 550 or rect.right, rect.bottom)
        if g.sub_map_settings.x ~= 0 and g.sub_map_settings.y ~= 0 then
            sub_map:SetPos(g.sub_map_settings.x, g.sub_map_settings.y)
        end
    else
        sub_map:SetSkinName("bg")
        local rect = sub_map:GetMargin()
        sub_map:SetMargin(rect.left - rect.left, rect.top - rect.top + 70,
            rect.right == 0 and rect.right + 35 or rect.right, rect.bottom)
        sub_map:Resize(310, 350)
    end
    sub_map:SetEventScript(ui.LBUTTONUP, "sub_map_frame_end_drag")
    local title = sub_map:CreateOrGetControl("richtext", "title", 25, 2)
    AUTO_CAST(title)
    local map_real_name = GetClassByType("Map", g.map_id).Name
    title:SetText("{ol}{S12}" .. map_real_name)
    local display = sub_map:CreateOrGetControl("picture", "display", 5, 3, 15, 15)
    AUTO_CAST(display)
    display:SetEnableStretch(1)
    display:EnableHitTest(1)
    display:SetEventScript(ui.LBUTTONUP, "sub_map_frame_toggle")
    display:SetTextTooltip("{ol}Display / hide")
    display:ShowWindow(1)
    local size = g.sub_map_settings.size
    if g.sub_map_settings.minimap == 0 then
        if g.sub_map_settings.visible == 1 then
            display:SetImage("btn_minus")
            sub_map:Resize(size + 10, size + 40)
        else
            display:SetImage("btn_plus")
            sub_map:Resize(size + 10, 40)
            sub_map:ShowWindow(1)
            return
        end
    else
        size = 310
    end
    local gbox = sub_map:CreateOrGetControl("groupbox", "gbox", size + 10, size + 10, ui.LEFT, ui.BOTTOM, 0, 30, 0, 0)
    AUTO_CAST(gbox)
    if g.sub_map_settings.minimap == 0 then
        gbox:SetEventScript(ui.MOUSEON, "sub_map_frame_layer_change")
        gbox:SetEventScriptArgString(ui.MOUSEON, "mouse_on")
        gbox:SetEventScript(ui.MOUSEOFF, "sub_map_frame_layer_change")
        gbox:SetEventScriptArgString(ui.MOUSEOFF, "mouse_off")
    end
    gbox:SetEventScript(ui.LBUTTONDOWN, "sub_map_frame_map_link")
    gbox:SetEventScript(ui.RBUTTONDOWN, "sub_map_mini_map")
    gbox:SetTextTooltip(g.lang == "Japanese" and
                            "{ol}LCTRL+右クリック: ミニマップモード 切替{nl}LCTRL+左クリック: マップリンク" or
                            "{ol}LCTRL+Right click: Minimap Mode Toggle{nl}LCTRL+Left click: Map Link")
    local map_pic = gbox:CreateOrGetControl("picture", "map_pic", size, size, ui.LEFT, ui.TOP, 0, 0, 0, 0)
    AUTO_CAST(map_pic)
    map_pic:SetEnableStretch(1)
    map_pic:EnableHitTest(0)
    local icon_size = g.sub_map_settings.minimap == 0 and g.sub_map_settings.size * 0.08 or size * 0.08
    sub_map:SetUserValue("ICON_SIZE", icon_size)
    local my = gbox:CreateOrGetControl("picture", "my", icon_size * 2, icon_size * 2, ui.LEFT, ui.TOP, 0, 0, 0, 0)
    AUTO_CAST(my)
    my:ShowWindow(0)
    my:SetImage("minimap_leader")
    my:SetEnableStretch(1)
    map_pic:SetImage(g.map_name)
    sub_map:ShowWindow(1)
    sub_map_char_update(sub_map, my, map_pic)
    if challenge == 0 then
        sub_map_set_warp_point(sub_map, gbox, map_pic, g.map_name, icon_size, map_real_name)
        sub_map_mapicon_update(sub_map, map_pic)
    end
    local sub_map_timer = sub_map:CreateOrGetControl("timer", "sub_map_timer", 0, 0)
    AUTO_CAST(sub_map_timer)
    sub_map_timer:SetUpdateScript("sub_map_timer_update")
    sub_map_timer:Start(0.5)
end

function sub_map_frame_end_drag(sub_map)
    g.sub_map_settings.x = sub_map:GetX()
    g.sub_map_settings.y = sub_map:GetY()
    sub_map_save_settings()
end

function sub_map_frame_toggle(frame, ctrl)
    if g.sub_map_settings.visible == 1 then
        g.sub_map_settings.visible = 0
    else
        g.sub_map_settings.visible = 1
    end
    sub_map_save_settings()
    sub_map_frame_init()
end

function sub_map_frame_map_link(sub_map, gbox)
    if keyboard.IsKeyPressed("LCTRL") ~= 1 then
        return
    end
    local x, y = GET_LOCAL_MOUSE_POS(gbox)
    local map_prop = geMapTable.GetMapProp(g.map_name)
    local world_pos = map_prop:MinimapPosToWorldPos(x, y, gbox:GetWidth(), gbox:GetHeight())
    LINK_MAP_POS(g.map_name, world_pos.x, world_pos.y)
end

function sub_map_mini_map(sub_map, gbox)
    if keyboard.IsKeyPressed("LCTRL") ~= 1 then
        return
    end
    if g.sub_map_settings.minimap == 0 then
        g.sub_map_settings.minimap = 1
    else
        g.sub_map_settings.minimap = 0
    end
    sub_map_save_settings()
    sub_map_frame_init()
end

function sub_map_frame_layer_change(sub_map, gbox, str)
    if str == "mouse_on" then
        sub_map:SetLayerLevel(999)
    elseif str == "mouse_off" then
        sub_map:SetLayerLevel(12)
    end
end

function sub_map_char_update(sub_map, my, map_pic)
    local my_handle = session.GetMyHandle()
    local pos = info.GetPositionInMap(my_handle, map_pic:GetWidth(), map_pic:GetHeight())
    my:SetOffset(pos.x - my:GetWidth() / 2, pos.y - my:GetHeight() / 2)
    local map_prop = session.GetCurrentMapProp()
    local angle = info.GetAngle(my_handle) - map_prop.RotateAngle
    my:SetAngle(angle)
    my:ShowWindow(1)
    map_pic:Invalidate()
end

function sub_map_set_warp_point(sub_map, gbox, map_pic, map_name, icon_size, map_real_name)
    local map_prop = geMapTable.GetMapProp(map_name)
    local mongens = map_prop.mongens
    local count = mongens:Count()
    for i = 0, count - 1 do
        local mon_prop = mongens:Element(i)
        local icon_name = mon_prop:GetMinimapIcon()
        if icon_name == "minimap_portal" or icon_name == "minimap_erosion" then
            local gen_list = mon_prop.GenList
            local gen_count = gen_list:Count()
            for j = 0, gen_count - 1 do
                local dialog = mon_prop:GetDialog()
                local warp_cls = GetClass("Warp", mon_prop:GetDialog())
                if not warp_cls then
                    for match in dialog:gmatch("[a-zA-Z]+_(.*)") do
                        warp_cls = GetClass("Warp", match)
                    end
                end
                if warp_cls then
                    local pos = gen_list:Element(j)
                    local map_pos = map_prop:WorldPosToMinimapPos(pos.x, pos.z, map_pic:GetWidth(), map_pic:GetHeight())
                    local icon = gbox:CreateOrGetControl("picture", "icon_" .. i, icon_size, icon_size, ui.LEFT, ui.TOP,
                        0, 0, 0, 0)
                    AUTO_CAST(icon)
                    icon:SetTextTooltip("{ol}{s10}" .. map_real_name)
                    icon:SetImage(mon_prop:GetMinimapIcon())
                    icon:SetOffset(map_pos.x - icon:GetWidth() / 2, map_pos.y - icon:GetHeight() / 2)
                    icon:SetEnableStretch(1)
                end
            end
        end
    end
    gbox:Invalidate()
end

function sub_map_timer_update(sub_map, sub_map_timer)
    if g.sub_map_settings.minimap == 1 then
        sub_map_time_update_(sub_map, sub_map_timer)
        if sub_map:GetLayerLevel() ~= 94 then
            sub_map:SetLayerLevel(94)
        end
    end
    if MAP_USE_FOG(g.map_name) ~= 0 then
        sub_map_draw_fog(sub_map)
    end
    local challenge = sub_map:GetUserIValue("CHALLENGE")
    if challenge == 1 then
        sub_map_callenge_pcicon_update(sub_map)
        -- sub_map_update_monster(sub_map)
    end
    sub_map_update_remove_member(sub_map)
end

function sub_map_time_update_(sub_map, sub_map_timer)
    local server_time = geTime.GetServerSystemTime()
    local hour = server_time.wHour
    local min = server_time.wMinute
    local ampm = "AM"
    local display_hour = hour
    if hour == 0 then
        display_hour = 12
        ampm = "AM"
    elseif hour == 12 then
        display_hour = 12
        ampm = "PM"
    elseif hour > 12 then
        display_hour = hour - 12
        ampm = "PM"
    end
    local display_min = string.format("%02d", min)
    local clock_text = string.format("{ol}{s18}%s %d:%s", ampm, display_hour, display_min)
    local clock = GET_CHILD(sub_map, "clock")
    if not clock then
        clock = sub_map:CreateOrGetControl("richtext", "clock", 0, 0)
        AUTO_CAST(clock)
    end
    clock:SetGravity(ui.RIGHT, ui.BOTTOM)
    clock:SetMargin(0, 0, 10, 5)
    clock:SetText(clock_text)
end

function sub_map_draw_fog(sub_map)
    local map_pic = GET_CHILD_RECURSIVELY(sub_map, "map_pic")
    AUTO_CAST(map_pic)
    HIDE_CHILD_BYNAME(map_pic, "sub_map_fog_")
    local map_frame = ui.GetFrame('map')
    local map = GET_CHILD(map_frame, "map")
    AUTO_CAST(map)
    local map_zoom = math.abs(tonumber(map_pic:GetWidth()) / tonumber(map:GetWidth()))
    local list = session.GetMapFogList(g.map_name)
    local cnt = list:Count()
    for i = 0, cnt - 1 do
        local tile = list:PtrAt(i)
        if tile.revealed == 0 then
            local name = string.format("sub_map_fog_%d", i)
            local tile_X = (tile.x * map_zoom)
            local tile_Y = (tile.y * map_zoom)
            local tile_width = math.ceil(tile.w * map_zoom)
            local tile_height = math.ceil(tile.h * map_zoom)
            local pic = map_pic:CreateOrGetControl("picture", name, tile_X, tile_Y, tile_width, tile_height)
            AUTO_CAST(pic)
            pic:SetImage("fullred")
            pic:SetEnableStretch(1)
            pic:SetAlpha(40)
            pic:EnableHitTest(0)
            pic:ShowWindow(1)
        end
    end
    sub_map:Invalidate()
end
-- TryGetProp(mon_cls, "MonRank", "None") == "Boss"
function sub_map_callenge_pcicon_update(sub_map)
    local gbox = GET_CHILD(sub_map, "gbox")
    local names = {}
    for i = 0, gbox:GetChildCount() - 1 do
        local child = gbox:GetChildByIndex(i)
        if child and child:GetName() ~= "map_pic" and child:GetName() ~= "my" then
            local aid = tonumber(child:GetName())
            if aid then
                gbox:RemoveChild(child:GetName())
            end
            names[child:GetName()] = true
        end
    end
    local map_pic = GET_CHILD(gbox, "map_pic")
    local mapprop = session.GetCurrentMapProp()
    local party_list = session.party.GetPartyMemberList(PARTY_NORMAL)
    local party_count = party_list:Count()
    local my_info = session.party.GetMyPartyObj(PARTY_NORMAL)
    local my_handle = session.GetMyHandle()
    local icon_size = sub_map:GetUserIValue("ICON_SIZE")
    local selected_objects, selected_objects_count = SelectObject(GetMyPCObject(), 5000, "ALL")
    local icon_img_160063 = GetClassByType("Item", 870004).Icon
    local icon_img_160055 = GetClassByType("Item", 664039).Icon
    for i = 1, selected_objects_count do
        local handle = GetHandle(selected_objects[i])
        if not g.sub_map_handles[tostring(handle)] then
            local actor = world.GetActor(handle)
            if handle and actor then
                local clsid = actor:GetType()
                local mon_cls = GetClassByType("Monster", clsid)
                if clsid == 160063 or clsid == 160055 then
                    local icon_name = "mon_" .. handle
                    names[icon_name] = false
                    local world_pos = actor:GetPos()
                    local pos = mapprop:WorldPosToMinimapPos(world_pos, map_pic:GetWidth(), map_pic:GetHeight())
                    local x = (pos.x - icon_size / 4)
                    local y = (pos.y - icon_size / 4)
                    local icon = gbox:CreateOrGetControl("picture", icon_name, icon_size * 0.5, icon_size * 0.5,
                        ui.LEFT, ui.TOP, 0, 0, 0, 0)
                    AUTO_CAST(icon)
                    icon:SetPos(x, y)
                    if clsid == 160063 then
                        icon:SetImage(icon_img_160063)
                    elseif clsid == 160055 then
                        icon:SetImage(icon_img_160055)
                    end
                    icon:SetEnableStretch(1)
                    icon:ShowWindow(1)
                end

                if my_handle ~= handle and info.IsPC(handle) == 1 then
                    for j = 0, party_count - 1 do
                        local pc_info = party_list:Element(j)
                        local name = pc_info:GetName()
                        local apc = actor:GetPCApc()
                        if apc then
                            local actor_name = apc:GetFamilyName()
                            if my_info ~= pc_info and name == actor_name then
                                names[name] = false -- 削除対象から除外
                                local inst_info = pc_info:GetInst()
                                local world_pos = actor:GetPos()
                                local hp = inst_info.hp
                                local pc_icon = GET_CHILD(gbox, name)
                                if not pc_icon then
                                    pc_icon = gbox:CreateOrGetControl("picture", name, 0, 0, icon_size * 1.25,
                                        icon_size * 1.25)
                                end
                                AUTO_CAST(pc_icon)
                                pc_icon:SetTextTooltip("{ol}{s10}" .. name)
                                pc_icon:SetEnableStretch(1)
                                local pos = mapprop:WorldPosToMinimapPos(world_pos, map_pic:GetWidth(),
                                    map_pic:GetHeight())
                                local x = (pos.x - icon_size * 1.25 / 2)
                                local y = (pos.y - icon_size * 1.25 / 2)
                                pc_icon:SetPos(x, y)
                                pc_icon:ShowWindow(1)
                                local image_name = 'Archer_party'
                                if hp <= 0 then
                                    image_name = 'die_party'
                                end
                                pc_icon:SetImage(image_name)
                                break
                            end
                        end
                    end
                end
            end
        end
    end
    for check_name, bool in pairs(names) do
        if bool == true and not string.find(check_name, "_MONPOS_") and not string.find(check_name, "SCR") then
            local icon = GET_CHILD(gbox, check_name)
            if icon then
                gbox:RemoveChild(check_name)
            end
        end
    end
end

function sub_map_update_remove_member(sub_map)
    local gbox = GET_CHILD(sub_map, "gbox")
    local icons = {}
    for i = 0, gbox:GetChildCount() - 1 do
        local child = gbox:GetChildByIndex(i)
        if child then
            local aid = tonumber(child:GetName())
            if aid then
                icons[aid] = true
            end
        end
    end
    local function process_member_list(party_type)
        local list = session.party.GetPartyMemberList(party_type)
        local my_handle = session.GetMyHandle()
        local my_info = session.party.GetMyPartyObj(party_type)
        if my_info then
            for i = 0, list:Count() - 1 do
                local pc_info = list:Element(i)
                local aid = tonumber(pc_info:GetAID())
                local handle = pc_info:GetHandle()
                if handle ~= my_handle and pc_info:GetMapID() == my_info:GetMapID() and pc_info:GetChannel() ==
                    my_info:GetChannel() then
                    icons[aid] = false
                end
            end
        end
    end
    process_member_list(PARTY_NORMAL)
    process_member_list(PARTY_GUILD)
    for aid, remove in pairs(icons) do
        if remove == true then
            gbox:RemoveChild(tostring(aid))
        end
    end
end

--[[function sub_map_update_monster(sub_map) -- 雑魚は画面に映ってる分しか取れない。仕様っぽい
    local gbox = GET_CHILD(sub_map, "gbox")
    local icon_size = sub_map:GetUserIValue("ICON_SIZE")
    g.sub_map_handles = g.sub_map_handles or {}
    local selected_objects, selected_objects_count = SelectObject(GetMyPCObject(), 5000, 'ENEMY')
    for i = 1, selected_objects_count do
        local handle = GetHandle(selected_objects[i])
        if handle and info.IsMonster(handle) == 1 then
            local actor = world.GetActor(handle)
            if actor then
                local cls_name = info.GetMonsterClassName(handle)
                local mon_cls = GetClass("Monster", cls_name)
                if mon_cls and TryGetProp(mon_cls, "MonRank", "None") ~= "Boss" and
                    not g.sub_map_handles[tostring(handle)] then
                    g.sub_map_handles[tostring(handle)] = true
                    local mon_pic = GET_CHILD_RECURSIVELY(gbox, "_MONPOS_" .. handle)
                    if not mon_pic then
                        mon_pic = gbox:CreateOrGetControl("picture", "_MONPOS_" .. handle, 0, 0, icon_size / 2,
                            icon_size / 2)
                        AUTO_CAST(mon_pic)
                        mon_pic:SetUserValue("HANDLE", handle)
                        local img_name = "colonymonster"
                        mon_pic:SetImage(img_name)
                        mon_pic:SetEnableStretch(1)
                        local map_prop = session.GetCurrentMapProp()
                        local map_pic = GET_CHILD_RECURSIVELY(sub_map, "map_pic")
                        AUTO_CAST(map_pic)
                        if map_pic then
                            local world_pos = actor:GetPos()
                            local pos =
                                map_prop:WorldPosToMinimapPos(world_pos, map_pic:GetWidth(), map_pic:GetHeight())
                            local init_x = pos.x - mon_pic:GetWidth() / 2
                            local init_y = pos.y - mon_pic:GetHeight() / 2
                            mon_pic:SetOffset(init_x, init_y)
                        end
                        mon_pic:ShowWindow(1)
                        if not mon_pic:HaveUpdateScript("sub_map_monpic_auto_update") then
                            mon_pic:RunUpdateScript("sub_map_monpic_auto_update", 0.5)
                        end
                    end
                end
            end
        end
    end
end]]

function sub_map_MAP_CHARACTER_UPDATE()
    local sub_map = ui.GetFrame(addon_name_lower .. "sub_map")
    if not sub_map then
        return
    end
    AUTO_CAST(sub_map)
    local my_handle = session.GetMyHandle()
    local map_pic = GET_CHILD_RECURSIVELY(sub_map, "map_pic")
    AUTO_CAST(map_pic)
    local pos = info.GetPositionInMap(my_handle, map_pic:GetWidth(), map_pic:GetHeight())
    local my = GET_CHILD_RECURSIVELY(sub_map, "my")
    AUTO_CAST(my)
    my:ShowWindow(0)
    my:SetOffset(pos.x - my:GetWidth() / 2, pos.y - my:GetHeight() / 2)
    local mapprop = session.GetCurrentMapProp()
    local angle = info.GetAngle(my_handle) - mapprop.RotateAngle
    my:SetAngle(angle)
    my:ShowWindow(1)
    map_pic:Invalidate()
    local challenge = sub_map:GetUserIValue("CHALLENGE")
    if challenge == 0 then
        sub_map_mapicon_update(sub_map, map_pic)
    end
end

function sub_map_mapicon_update(sub_map, map_pic)
    local now = imcTime.GetAppTimeMS()
    if g.sub_map_last_update_time then
        if now - g.sub_map_last_update_time < 1000 then
            return
        end
    end
    g.sub_map_last_update_time = now
    local map_tbl = sub_map_get_mapinfo(sub_map, map_pic)
    local gbox = GET_CHILD(sub_map, "gbox")
    local function split(str, delim)
        local return_data = {}
        for match in string.gmatch(str, "[^" .. delim .. "]+") do
            table.insert(return_data, match)
        end
        return return_data
    end
    local icon_size = sub_map:GetUserIValue("ICON_SIZE")
    for i, data in ipairs(map_tbl) do
        if string.find(data.class_type, "treasure_box") then
            local item_split = split(data.argstr2, ":")
            local item_name = GetClass("Item", item_split[2]).Name
            local icon = GET_CHILD(gbox, "icon_" .. i)
            if not icon then
                icon = gbox:CreateOrGetControl("picture", "icon_" .. i, 0, 0, icon_size, icon_size)
                AUTO_CAST(icon)
                icon:SetOffset(data.map_pos.x - icon:GetWidth() / 2, data.map_pos.y - icon:GetHeight() / 2)
                icon:SetEnableStretch(1)
            end
            icon:SetTextTooltip("{ol}{s10}" .. data.argstr1 .. "{nl}" .. item_name)
            if data.state then
                icon:SetImage("icon_item_box")
            else
                icon:SetText("{ol}{s10}" .. data.argstr1)
                icon:SetImage("compen_btn")
            end
        end
        if string.find(data.class_type, "statue_vakarine") or string.find(data.class_type, "klaipeda_square_statue") or
            string.find(data.class_type, "npc_orsha_goddess") or string.find(data.class_type, "statue_zemina") then
            local icon = GET_CHILD(gbox, "icon_" .. i)
            if not icon then
                icon = gbox:CreateOrGetControl("picture", "icon_" .. i, 0, 0, icon_size, icon_size)
                AUTO_CAST(icon)
                icon:SetOffset(data.map_pos.x - icon:GetWidth() / 2, data.map_pos.y - icon:GetHeight() / 2)
                icon:SetEnableStretch(1)
                icon:SetTextTooltip("{ol}{s10}" .. data.name)
                icon:SetImage(data.icon_name)
            end
            if data.state then
                icon:SetColorTone("FFFFFFFF")
            else
                icon:SetColorTone("FF555555")
            end
        end
    end
    gbox:Invalidate()
end

function sub_map_get_mapinfo(sub_map, map_pic)
    if not g.map_name or g.map_name == "" or g.map_name == "None" then
        return
    end
    local property = geMapTable.GetMapProp(g.map_name)
    local class_list, class_count = GetClassList("GenType_" .. g.map_name)
    local mongens = property.mongens
    local map_tbl = {}
    local count = mongens:Count()
    for i = 0, count - 1 do
        local mon_prop = mongens:Element(i)
        local ies_data = GetClassByIndexFromList(class_list, i)
        local class_type = ies_data.ClassType
        local state = GetNPCState(g.map_name, ies_data.GenType)
        if not state then
            state = false
        end
        local gen_list = mon_prop.GenList
        local map_pos
        if gen_list:Count() > 0 then
            map_pos = property:WorldPosToMinimapPos(gen_list:Element(0), map_pic:GetWidth(), map_pic:GetHeight())
        end
        local icon_name = mon_prop:GetMinimapIcon()
        if string.find(class_type, "treasure_box") then
            if ies_data.ArgStr1 ~= "None" then
                local data = {
                    class_type = class_type,
                    state = state,
                    map_pos = map_pos,
                    icon_name = icon_name,
                    argstr1 = ies_data.ArgStr1,
                    argstr2 = ies_data.ArgStr2,
                    argstr3 = ies_data.ArgStr3,
                    name = ies_data.Name
                }
                table.insert(map_tbl, data)
            end
        elseif string.find(class_type, "statue_zemina") or string.find(class_type, "statue_vakarine") or
            string.find(class_type, "klaipeda_square_statue") or string.find(class_type, "npc_orsha_goddess") then
            local data = {
                class_type = class_type,
                state = state,
                map_pos = map_pos,
                icon_name = icon_name,
                argstr1 = ies_data.ArgStr1,
                argstr2 = ies_data.ArgStr2,
                argstr3 = ies_data.ArgStr3,
                name = ies_data.Name
            }
            table.insert(map_tbl, data)
        end
    end
    return map_tbl
end

function sub_map_MAP_MON_MINIMAP(frame, msg, str, num, info)
    local sub_map = ui.GetFrame(addon_name_lower .. "sub_map")
    if not sub_map then
        return
    end
    AUTO_CAST(sub_map)
    local gbox = GET_CHILD(sub_map, "gbox")
    local handle = info.handle
    local mon_cls = GetClassByType("Monster", info.type)
    g.sub_map_handles = g.sub_map_handles or {}
    local icon_size = sub_map:GetUserIValue("ICON_SIZE")
    if mon_cls and TryGetProp(mon_cls, "MonRank", "None") == "Boss" and not g.sub_map_handles[tostring(handle)] then
        g.sub_map_handles[tostring(handle)] = true
        local mon_pic = GET_CHILD_RECURSIVELY(gbox, "_MONPOS_" .. handle)
        if not mon_pic then
            mon_pic = gbox:CreateOrGetControl("picture", "_MONPOS_" .. handle, 0, 0, icon_size, icon_size)
            AUTO_CAST(mon_pic)
            mon_pic:SetUserValue("HANDLE", handle)
            local img_name = mon_cls.MinimapIcon
            mon_pic:SetImage(img_name)
            mon_pic:SetEnableStretch(1)
            local map_prop = session.GetCurrentMapProp()
            local map_pic = GET_CHILD_RECURSIVELY(sub_map, "map_pic")
            AUTO_CAST(map_pic)
            if map_pic then
                local pos = map_prop:WorldPosToMinimapPos(info.x, info.z, map_pic:GetWidth(), map_pic:GetHeight())
                local init_x = pos.x - mon_pic:GetWidth() / 2
                local init_y = pos.y - mon_pic:GetHeight() / 2
                mon_pic:SetOffset(init_x, init_y)
            end
            mon_pic:ShowWindow(1)
            if not mon_pic:HaveUpdateScript("sub_map_monpic_auto_update") then
                mon_pic:RunUpdateScript("sub_map_monpic_auto_update", 0.5)
            end
        end
    end
end

function sub_map_monpic_auto_update(mon_pic)
    local sub_map = mon_pic:GetTopParentFrame()
    local gbox = GET_CHILD(sub_map, "gbox")
    local handle = mon_pic:GetUserIValue("HANDLE")
    local actor = world.GetActor(handle)
    if actor then
        local map_prop = session.GetCurrentMapProp()
        local map_pic = GET_CHILD_RECURSIVELY(sub_map, "map_pic")
        AUTO_CAST(map_pic)
        local actor_pos = actor:GetPos()
        local mon_cls = GetClassByType("Monster", actor:GetType())
        if mon_cls and TryGetProp(mon_cls, "MonRank", "None") == "Boss" then
            local pos = map_prop:WorldPosToMinimapPos(actor_pos, map_pic:GetWidth(), map_pic:GetHeight())
            local x = pos.x - mon_pic:GetWidth() / 2
            local y = pos.y - mon_pic:GetHeight() / 2
            mon_pic:SetOffset(x, y)
        end
        return 1
    else
        --[[local gbox = mon_pic:GetParent()
        if gbox then
            gbox:RemoveChild(mon_pic:GetName())
        end
        if g.sub_map_handles then
            g.sub_map_handles[tostring(handle)] = nil
        end
        return 0]]
    end
    return 1
end

function sub_map_ON_MON_MINIMAP_END(frame, msg, str, handle)
    local sub_map = ui.GetFrame(addon_name_lower .. "sub_map")
    if not sub_map then
        return
    end
    AUTO_CAST(sub_map)
    local gbox = GET_CHILD(sub_map, "gbox")
    local mon_pic = GET_CHILD(gbox, "_MONPOS_" .. handle)
    if mon_pic then
        if g.sub_map_handles then
            g.sub_map_handles[tostring(handle)] = nil
        end
        gbox:RemoveChild("_MONPOS_" .. handle)
        gbox:Invalidate()
    end
end

function sub_map_MAP_UPDATE_PARTY_INST(frame, msg, str, party_type)
    local sub_map = ui.GetFrame(addon_name_lower .. "sub_map")
    if not sub_map then
        return
    end
    AUTO_CAST(sub_map)
    local gbox = GET_CHILD(sub_map, "gbox")
    local map_prop = session.GetCurrentMapProp()
    local my_info = session.party.GetMyPartyObj(party_type)
    local list = session.party.GetPartyMemberList(party_type)
    local count = list:Count()
    for i = 0, count - 1 do
        local pc_info = list:Element(i)
        if my_info ~= pc_info then
            local aid = pc_info:GetAID()
            local pc_icon = GET_CHILD(gbox, aid)
            if pc_icon then
                local inst_info = pc_info:GetInst()
                sub_map_SET_MINIMAP_ICON(pc_icon, inst_info.hp, aid)
                sub_map_SET_MAPPOS(sub_map, pc_icon, inst_info, map_prop)
            end
        end
    end
end

function sub_map_SET_MINIMAP_ICON(pc_icon, hp, aid)
    local image_name = 'die_party'
    if hp > 0 then
        if session.party.GetPartyMemberInfoByAID(PARTY_NORMAL, aid) then
            image_name = 'Archer_party'
        elseif session.party.GetPartyMemberInfoByAID(PARTY_GUILD, aid) then
            image_name = 'Wizard_party'
        end
    end
    pc_icon:SetImage(image_name)
end

function sub_map_SET_MAPPOS(sub_map, pc_icon, inst_info, map_prop, info)
    local world_pos = inst_info:GetPos()
    local map_pic = GET_CHILD_RECURSIVELY(sub_map, 'map_pic')
    local pos
    if info then
        pos = map_prop:WorldPosToMinimapPos(info.x, info.z, map_pic:GetWidth(), map_pic:GetHeight())
    else
        pos = map_prop:WorldPosToMinimapPos(world_pos, map_pic:GetWidth(), map_pic:GetHeight())
    end
    local icon_size = sub_map:GetUserIValue("ICON_SIZE")
    local x = (pos.x - icon_size / 2)
    local y = (pos.y - icon_size / 2)
    pc_icon:SetPos(x, y)
end

function sub_map_update_party_or_guild(frame, msg, arg, num, info)
    local sub_map = ui.GetFrame(addon_name_lower .. "sub_map")
    if not sub_map then
        return
    end
    AUTO_CAST(sub_map)
    local party_type = 0
    if msg == "GUILD_INFO_UPDATE" then
        party_type = 1
    end
    local list = session.party.GetPartyMemberList(party_type)
    local count = list:Count()
    if count == 1 then
        return
    end
    local my_info = session.party.GetMyPartyObj(party_type)
    if not my_info then
        return
    end
    local map_prop = session.GetCurrentMapProp()
    for i = 0, count - 1 do
        local pc_info = list:Element(i)
        if my_info ~= pc_info and my_info:GetMapID() == pc_info:GetMapID() and my_info:GetChannel() ==
            pc_info:GetChannel() then
            sub_map_CREATE_PICTURE(sub_map, pc_info, party_type, map_prop, info)
        end
    end
end

function sub_map_CREATE_PICTURE(sub_map, pc_info, party_type, mapprop, info)
    local aid = pc_info:GetAID()
    local gbox = GET_CHILD(sub_map, "gbox")
    local pc_icon = GET_CHILD(gbox, aid)
    if not pc_icon then
        local icon_size = sub_map:GetUserIValue("ICON_SIZE")
        pc_icon = gbox:CreateOrGetControl("picture", aid, 0, 0, icon_size, icon_size)
        AUTO_CAST(pc_icon)
    end
    pc_icon:SetEnableStretch(1)
    pc_icon:SetTooltipType("partymap")
    local name = ""
    --[[if type(_G["NATIVE_LANG_ON_INIT"]) == "function" then
        local ntr = _G["ADDONS"]["norisan"]["NATIVE_LANG"]
        name = ntr.names[pc_info:GetName()] or pc_info:GetName() -- {#FF0000}★
        name = string.gsub(name, "{#FF0000}★", "")
        name = string.gsub(name, "{/}", "")
        ts(name)
    end]]
    pc_icon:SetTooltipArg(pc_info:GetName(), party_type)
    pc_icon:ShowWindow(1)
    local inst_info = pc_info:GetInst()
    sub_map_SET_MINIMAP_ICON(pc_icon, inst_info.hp, aid)
    sub_map_SET_MAPPOS(sub_map, pc_icon, inst_info, mapprop, info)
end
-- sub_map ここまで

-- no_check ここから
function no_check_on_init()
    no_check_inventory_frame_init()
    g.setup_hook_and_event(g.addon, "BEFORE_APPLIED_YESSCP_OPEN_BASIC_MSG",
        "no_check_BEFORE_APPLIED_YESSCP_OPEN_BASIC_MSG", false)
    g.setup_hook_and_event(g.addon, "CARD_SLOT_EQUIP", "no_check_CARD_SLOT_EQUIP", false)
    g.setup_hook_and_event(g.addon, "EQUIP_CARDSLOT_INFO_OPEN", "no_check_EQUIP_CARDSLOT_INFO_OPEN", false)
    g.setup_hook_and_event(g.addon, "EQUIP_GODDESSCARDSLOT_INFO_OPEN", "no_check_EQUIP_GODDESSCARDSLOT_INFO_OPEN", false)
    g.setup_hook_and_event(g.addon, "GODDESS_MGR_SOCKET_REQ_GEM_REMOVE", "no_check_GODDESS_MGR_SOCKET_REQ_GEM_REMOVE",
        false)
    g.setup_hook_and_event(g.addon, "UNLOCK_TRANSMUTATIONSPREADER_BELONGING_SCROLL_EXEC_ASK_AGAIN",
        "no_check_UNLOCK_TRANSMUTATIONSPREADER_BELONGING_SCROLL_EXEC_ASK_AGAIN", false)
    g.setup_hook_and_event(g.addon, "UNLOCK_ACC_BELONGING_SCROLL_EXEC_ASK_AGAIN",
        "no_check_UNLOCK_ACC_BELONGING_SCROLL_EXEC_ASK_AGAIN", false)
    g.setup_hook_and_event(g.addon, "SELECT_ZONE_MOVE_CHANNEL", "no_check_SELECT_ZONE_MOVE_CHANNEL", false)
    g.setup_hook_and_event(g.addon, "BEFORE_APPLIED_NON_EQUIP_ITEM_OPEN", "no_check_BEFORE_APPLIED_NON_EQUIP_ITEM_OPEN",
        false)
    g.setup_hook_and_event(g.addon, "INVENTORY_CLOSE", "no_check_frame_close", true)
    g.setup_hook_and_event(g.addon, "MORU_LBTN_CLICK", "no_check_MORU_LBTN_CLICK", true)
    if g.get_map_type() == "City" then
        local _nexus_addons = ui.GetFrame("_nexus_addons")
        _nexus_addons:SetVisible(1)
        local no_check_timer = _nexus_addons:CreateOrGetControl("timer", "no_check_timer", 0, 0)
        AUTO_CAST(no_check_timer)
        no_check_timer:SetUpdateScript("no_check_timer")
        no_check_timer:Start(0.3)
    end
end

function no_check_inventory_frame_init()
    local inventory = ui.GetFrame("inventory")
    local searchSkin = GET_CHILD_RECURSIVELY(inventory, "searchSkin")
    if g.settings.no_check.use == 1 then -- !
        local searchGbox = GET_CHILD_RECURSIVELY(inventory, "searchGbox")
        local btn = searchGbox:CreateOrGetControl("button", "btn", 160, -3, 35, 38)
        AUTO_CAST(btn)
        searchSkin:Resize(284, 30)
        searchSkin:SetMargin(38, 0, 0, 5)
        btn:SetSkinName("test_pvp_btn")
        local tool_tip = g.lang == "Japanese" and
                             "{ol}[No Check]{nl}左クリック: アイテム連続フレーム表示{nl}右クリック: ゴミ箱フレーム表示" or
                             "{ol}[No Check]{nl}Left Click: Item continuous frame display{nl}Right Click: Trash frame display"
        btn:SetTextTooltip(tool_tip)
        btn:SetText("{img equipment_info_btn_mark2 32 32}")
        btn:SetEventScript(ui.LBUTTONUP, "no_check_continuous_use_frame")
        btn:SetEventScript(ui.RBUTTONUP, "no_check_delete_item_frame")
    else
        searchSkin:Resize(317, 30)
        searchSkin:SetMargin(5, 0, 0, 5)
        DESTROY_CHILD_BYNAME(inventory, "btn")
    end
end
-- アイテム連続使用
function no_check_continuous_use_frame(frame, ctrl, str, num)
    local inventory = ui.GetFrame("inventory")
    local no_check_use = ui.CreateNewFrame("notice_on_pc", addon_name_lower .. "no_check_use", 0, 0, 0, 0)
    AUTO_CAST(no_check_use)
    no_check_use:SetGravity(ui.RIGHT, ui.TOP)
    no_check_use:SetSkinName("test_win_lastpopup")
    local rect = no_check_use:GetMargin()
    no_check_use:SetMargin(rect.left - rect.left, rect.top - rect.top + 300,
        rect.right == 0 and rect.right + 310 + 200 or rect.right, rect.bottom)
    no_check_use:Resize(300, 300)
    no_check_use:RemoveAllChild()
    no_check_use:ShowWindow(1)
    local item_slot = no_check_use:CreateOrGetControl('slot', 'item_slot', 115, 100, 70, 70)
    AUTO_CAST(item_slot)
    item_slot:SetSkinName("slot")
    INVENTORY_SET_CUSTOM_RBTNDOWN("no_check_inv_rbtn")
    item_slot:SetEventScript(ui.RBUTTONUP, "no_check_use_icon_clear")
    local notice = no_check_use:CreateOrGetControl('richtext', 'notice', 30, 180, 0, 0)
    AUTO_CAST(notice)
    notice:SetText(g.lang == "Japanese" and "{ol}{s20}アイテムを連続使用します" or
                       "{ol}{s18}Use the item continuously")
    local continuous_use = no_check_use:CreateOrGetControl('button', 'continuous_use', 40, 220, 100, 50)
    AUTO_CAST(continuous_use)
    continuous_use:SetSkinName("test_red_button")
    continuous_use:SetText(g.lang == "Japanese" and "{ol}{s16}連続使用" or "{ol}{s16}Continu")
    continuous_use:SetEventScript(ui.LBUTTONUP, "no_check_continuous_use")
    local cancel = no_check_use:CreateOrGetControl('button', 'cancel', 155, 220, 100, 50)
    AUTO_CAST(cancel)
    cancel:SetSkinName("test_gray_button")
    cancel:SetText(g.lang == "Japanese" and "{ol}{s16}キャンセル" or "{ol}{s16}Cancel")
    cancel:SetEventScript(ui.LBUTTONUP, "no_check_frame_close")
end

function no_check_use_icon_clear(no_check_use, item_slot)
    CLEAR_SLOT_ITEM_INFO(item_slot)
end

function no_check_continuous_use(no_check_use, ctrl, str, num)
    local item_slot = GET_CHILD(no_check_use, "item_slot")
    AUTO_CAST(item_slot)
    local clsid = item_slot:GetUserIValue("CLASS_ID")
    if clsid == 0 then
        return
    end
    local inv_item = session.GetInvItemByType(clsid)
    if inv_item then
        no_check_use:RunUpdateScript("no_check_icontinuous_use_result", 0.5)
    end
end

function no_check_icontinuous_use_result(no_check_use)
    local item_slot = GET_CHILD(no_check_use, "item_slot")
    AUTO_CAST(item_slot)
    local clsid = item_slot:GetUserIValue("CLASS_ID")
    local inv_item = session.GetInvItemByType(clsid)
    if inv_item then
        INV_ICON_USE(inv_item)
        local item_cls = GetClassByType("Item", clsid)
        SET_SLOT_ITEM_CLS(item_slot, item_cls)
        SET_SLOT_ITEM_TEXT(item_slot, inv_item, item_cls)
        return 1
    else
        no_check_use_icon_clear(no_check_use, item_slot)
    end
end
-- ゴミ箱フレーム
function no_check_delete_item_frame()
    local no_check_delete = ui.CreateNewFrame("notice_on_pc", addon_name_lower .. "no_check_delete", 0, 0, 10, 10)
    AUTO_CAST(no_check_delete)
    no_check_delete:SetSkinName("test_frame_low")
    no_check_delete:SetGravity(ui.RIGHT, ui.TOP)
    local rect = no_check_delete:GetMargin()
    no_check_delete:SetMargin(rect.left - rect.left, rect.top - rect.top + 100,
        rect.right == 0 and rect.right + 310 + 200 or rect.right, rect.bottom)
    no_check_delete:SetLayerLevel(100)
    no_check_delete:Resize(300, 698)
    no_check_delete:RemoveAllChild()
    local title = no_check_delete:CreateOrGetControl('richtext', 'title', 10, 15, 0, 0)
    AUTO_CAST(title)
    title:SetText(g.lang == "Japanese" and "{ol}{s18}ゴミ箱スロット" or "{ol}{s18}Discard item Slots")
    local close = no_check_delete:CreateOrGetControl("button", "close", 0, 0, 25, 25)
    AUTO_CAST(close)
    close:SetImage("testclose_button")
    close:SetGravity(ui.RIGHT, ui.TOP)
    close:SetEventScript(ui.LBUTTONUP, "no_check_frame_close")
    close:SetEventScriptArgString(ui.LBUTTONUP, "true")
    local delete_gb = no_check_delete:CreateOrGetControl("groupbox", "delete_gb", 10, 40, 380, 380)
    AUTO_CAST(delete_gb)
    delete_gb:SetSkinName("test_frame_midle_light")
    delete_gb:Resize(280, 600)
    no_check_delete:ShowWindow(1)
    local delete_slotset = delete_gb:CreateOrGetControl('slotset', 'delete_slotset', 0, 0, 0, 0)
    AUTO_CAST(delete_slotset)
    delete_slotset:SetSlotSize(40, 40)
    delete_slotset:EnablePop(0)
    delete_slotset:EnableDrag(1)
    delete_slotset:EnableDrop(1)
    delete_slotset:SetColRow(7, 15)
    delete_slotset:SetSpc(0, 0)
    delete_slotset:SetSkinName('slot')
    delete_slotset:CreateSlots()
    local slot_count = delete_slotset:GetSlotCount()
    local go_func = no_check_delete:CreateOrGetControl("button", "go_func", 0, 0, 100, 43)
    AUTO_CAST(go_func)
    go_func:SetText(g.lang == "Japanese" and "{ol}{s16}スタート" or "{ol}{s16}START")
    go_func:SetMargin(190, 645, 100, 0)
    go_func:SetSkinName("test_red_button")
    go_func:SetEventScript(ui.LBUTTONUP, "no_check_delete_item_msgbox")
    local stop_func = no_check_delete:CreateOrGetControl("button", "stop_func", 0, 0, 100, 43)
    AUTO_CAST(stop_func)
    stop_func:SetText(g.lang == "Japanese" and "{ol}{s16}ストップ" or "{ol}{s16}STOP")
    stop_func:SetMargin(10, 645, 100, 0)
    stop_func:SetSkinName("test_gray_button")
    stop_func:SetEventScript(ui.LBUTTONUP, "no_check_delete_item")
    stop_func:SetEventScriptArgString(ui.LBUTTONUP, "true")
    INVENTORY_SET_CUSTOM_RBTNDOWN("no_check_inv_rbtn")
    g.no_check_iesids = {}
end

function no_check_delete_item_clear(parent, slot, iesid, num)
    CLEAR_SLOT_ITEM_INFO(slot)
    slot:SetUserValue("DELETE_IDSID", "None")
    slot:SetUserValue("DELETE_NAME", "None")
    slot:SetUserValue("DELETE_COUNT", 0)
    g.no_check_iesids[iesid] = nil
    local inventory = ui.GetFrame("inventory")
    local inv_slot = INV_GET_SLOT_BY_ITEMGUID(iesid)
    if inv_slot then
        AUTO_CAST(inv_slot)
        inv_slot:Select(0)
        inv_slot:RunUpdateScript("no_check_inv_invalidate", 0.1)
        inv_slot:Invalidate()
    end
end

function no_check_delete_check(iesid, cls_id)
    if GetCraftState() == 1 then
        return false
    end
    if true == BEING_TRADING_STATE() then
        return false
    end
    local inventory = ui.GetFrame("inventory")
    local inv_item = session.GetInvItemByGuid(iesid)
    if not inv_item then
        return false
    end
    if true == inv_item.isLockState or true == IS_TEMP_LOCK(inventory, inv_item) then
        ui.SysMsg(ClMsg("MaterialItemIsLock"))
        return false
    end
    local item_cls = GetClassByType("Item", cls_id)
    if not item_cls then
        return false
    end
    local item_prop = geItemTable.IsDestroyable(cls_id)
    if item_cls.Destroyable == 'NO' or item_prop == false then
        local item_obj = GetIES(inv_item:GetObject())
        if item_obj.ItemLifeTimeOver == 0 then
            ui.AlarmMsg("ItemIsNotDestroy")
            return false
        end
    end
    return true
end

function no_check_delete_item_msgbox()
    local yes_scp = string.format("no_check_delete_item_reserve()")
    local msg = g.lang == "Japanese" and
                    "{ol}{#FF0000}本当にゴミ捨てを開始しますか？{nl}(リカバリーサービス対象外かも)" or
                    "{ol}{#FF0000}Are you sure you want to start trashing?{nl}(might not be covered by the{nl} recovery service)"
    ui.MsgBox(msg, yes_scp, "None")
end

function no_check_delete_item_reserve()
    local no_check_delete = ui.GetFrame(addon_name_lower .. "no_check_delete")
    no_check_delete_item(no_check_delete)
    no_check_delete:RunUpdateScript("no_check_delete_item", 0.5)
end

function no_check_delete_item(no_check_delete, stop_func)
    if stop_func then
        return 0
    end
    if no_check_delete and no_check_delete:IsVisible() == 0 then
        return 0
    end
    local delete_slotset = GET_CHILD_RECURSIVELY(no_check_delete, "delete_slotset")
    AUTO_CAST(delete_slotset)
    local slot_count = delete_slotset:GetSlotCount()
    for i = 1, slot_count do
        local slot = GET_CHILD(delete_slotset, "slot" .. i)
        AUTO_CAST(slot)
        local icon = slot:GetIcon()
        if icon then
            local iesid = slot:GetUserValue("DELETE_IDSID")
            local name = slot:GetUserValue("DELETE_NAME")
            local count = slot:GetUserIValue("DELETE_COUNT")
            local trans_name = dic.getTranslatedStr(name)
            no_check_delete_item_execute(slot, iesid, trans_name, count)
            return 1
        end
    end
    no_check_frame_close(no_check_delete, delete_slotset)
    return 0
end

function no_check_delete_item_execute(slot, iesid, trans_name, count)
    IMC_LOG("INFO_NORMAL", "EXEC_DELETE_ITEMDROP")
    local pc = GetMyPCObject()
    local msg = g.lang == "Japanese" and "{ol}{#FFFF00}[" .. trans_name .. "]{/}{ol}{#FFFFFF}を" .. "{ol}{#FFFF00}[" ..
                    count .. "個]{/}" .. "{ol}{#FFFFFF}捨てました" or "{ol}{#FFFFFF}Discarded {/}" ..
                    "{ol}{#FFFF00}[" .. count .. "]{ol}{#FFFFFF} piece " .. "{ol}{#FFFF00}[" .. trans_name .. "]{/}"
    imcAddOn.BroadMsg("NOTICE_Dm_!", msg, 0.4)
    item.DropDelete(iesid, count)
    no_check_delete_item_clear(nil, slot, iesid, nil)
end
-- 連続使用とゴミ捨ての共通。インベントリマウス制御
function no_check_inv_rbtn(item_obj, slot)
    local icon = slot:GetIcon()
    local icon_info = icon:GetInfo()
    local no_check_use = ui.GetFrame(addon_name_lower .. "no_check_use")
    if no_check_use and no_check_use:IsVisible() == 1 then
        local clsid = icon_info.type
        local inv_item = session.GetInvItemByType(clsid)
        local item_slot = GET_CHILD(no_check_use, "item_slot")
        local item_cls = GetClassByType("Item", clsid)
        item_slot:SetUserValue("CLASS_ID", clsid)
        SET_SLOT_ITEM_CLS(item_slot, item_cls)
        SET_SLOT_ITEM_TEXT(item_slot, inv_item, item_cls)
        return
    end
    local no_check_delete = ui.GetFrame(addon_name_lower .. "no_check_delete")
    if no_check_delete and no_check_delete:IsVisible() == 1 then
        AUTO_CAST(no_check_delete)
        local iesid = icon_info:GetIESID()
        local inv_item = session.GetInvItemByGuid(iesid)
        local item_obj = GetIES(inv_item:GetObject())
        if g.no_check_iesids[iesid] then
            local msg = g.lang == "Japanese" and "{ol}既に登録されています" or "{ol}Already registered"
            ui.SysMsg(msg)
            return
        end
        if not no_check_delete_check(iesid, item_obj.ClassID) then
            return
        end
        local delete_slotset = GET_CHILD_RECURSIVELY(no_check_delete, "delete_slotset")
        AUTO_CAST(delete_slotset)
        local slot_count = delete_slotset:GetSlotCount()
        for i = 1, slot_count do
            local slot = GET_CHILD(delete_slotset, "slot" .. i)
            AUTO_CAST(slot)
            local icon = slot:GetIcon()
            if not icon then
                icon = CreateIcon(slot)
                slot:SetUserValue("DELETE_IDSID", iesid)
                slot:SetUserValue("DELETE_NAME", item_obj.Name)
                slot:SetUserValue("DELETE_COUNT", inv_item.count)
                g.no_check_iesids[iesid] = true
                SET_SLOT_ITEM_CLS(slot, item_obj)
                SET_SLOT_ITEM_TEXT(slot, inv_item, item_obj)
                SET_SLOT_STYLESET(slot, item_obj)
                SET_SLOT_IESID(slot, iesid)
                SET_SLOT_ICOR_CATEGORY(slot, item_obj)
                icon:SetTooltipArg("None", 0, iesid)
                SET_ITEM_TOOLTIP_TYPE(icon, item_obj.ClassID, item_obj, "None")
                SET_SLOT_ICOR_CATEGORY(slot, item_obj)
                slot:SetEventScript(ui.RBUTTONUP, "no_check_delete_item_clear")
                slot:SetEventScriptArgString(ui.RBUTTONUP, iesid)
                local inventory = ui.GetFrame("inventory")
                local inv_slot = INV_GET_SLOT_BY_ITEMGUID(iesid)
                if inv_slot then
                    AUTO_CAST(inv_slot)
                    inv_slot:SetSelectedImage('socket_slot_check')
                    inv_slot:Select(1)
                    inv_slot:RunUpdateScript("no_check_inv_invalidate", 0.1)
                    inv_slot:Invalidate()
                end
                return
            end
        end
    end
end

function no_check_frame_close(frame, ctrl)
    if frame:GetName() ~= "_nexus_addons" then
        ui.DestroyFrame(frame:GetName())
    end
    INVENTORY_SET_CUSTOM_RBTNDOWN('None')
    INVENTORY_CLEAR_SELECT(nil)
    if ctrl:GetName() == "delete_slotset" then
        ui.SysMsg("{ol}[No Check]End of Operation")
    end
end

function no_check_inv_invalidate(inv_slot)
    inv_slot:Invalidate()
end
-- 欠片アイテム他使用時のメッセージボックス非表示
function no_check_BEFORE_APPLIED_YESSCP_OPEN_BASIC_MSG(my_frame, my_msg)
    local inv_item = g.get_event_args(my_msg)
    if g.settings.no_check.use == 1 then
        if not inv_item then
            return
        end
        local item_obj = GetIES(inv_item:GetObject())
        if not item_obj then
            return
        end
        local inventory = ui.GetFrame("inventory")
        inventory:SetUserValue("REQ_USE_ITEM_GUID", inv_item:GetIESID())
        REQUEST_SUMMON_BOSS_TX()
    else
        g.FUNCS["BEFORE_APPLIED_YESSCP_OPEN_BASIC_MSG"](inv_item)
    end
end
-- レジェンドカード装着時のメッセージボックス非表示
function no_check_CARD_SLOT_EQUIP(my_frame, my_msg)
    local slot, item, group_name_str = g.get_event_args(my_msg)
    if g.settings.no_check.use == 1 then
        local item_obj = GetIES(item:GetObject())
        if item_obj.GroupName == "Card" then
            local slot_index = CARD_SLOT_GET_SLOT_INDEX(group_name_str, slot:GetSlotIndex())
            local card_info = equipcard.GetCardInfo(slot_index + 1)
            if card_info then
                ui.SysMsg(ClMsg("AlreadyEquippedThatCardSlot"))
                return
            end
            if item.isLockState == true then
                ui.SysMsg(ClMsg("MaterialItemIsLock"))
                return
            end
            local item_guid = item:GetIESID()
            local inventory = ui.GetFrame("inventory")
            inventory:SetUserValue("EQUIP_CARD_GUID", item_guid)
            inventory:SetUserValue("EQUIP_CARD_SLOTINDEX", slot_index)
            local pc_etc = GetMyEtcObject()
            if pc_etc.IS_LEGEND_CARD_OPEN ~= 1 and group_name_str == 'LEG' then
                ui.SysMsg(ClMsg("LegendCard_Slot_NotOpen"))
                return
            end
            REQUEST_EQUIP_CARD_TX()
        end
    else
        g.FUNCS["CARD_SLOT_EQUIP"](slot, item, group_name_str)
    end
end
-- レジェンドカード脱着時
function no_check_EQUIP_CARDSLOT_INFO_OPEN(my_frame, my_msg)
    local slot_index = g.get_event_args(my_msg)
    if g.settings.no_check.use == 1 then
        slot_index = slot_index .. " 1"
        pc.ReqExecuteTx_NumArgs("SCR_TX_UNEQUIP_CARD_SLOT", slot_index)
    else
        g.FUNCS["EQUIP_CARDSLOT_INFO_OPEN"](slot_index)
    end
end
-- ゴッデスカード脱着時
function no_check_EQUIP_GODDESSCARDSLOT_INFO_OPEN(my_frame, my_msg)
    local slot_index = g.get_event_args(my_msg)
    if g.settings.no_check.use == 1 then
        slot_index = slot_index .. " 1"
        pc.ReqExecuteTx_NumArgs("SCR_TX_UNEQUIP_CARD_SLOT", slot_index)
    else
        g.FUNCS["EQUIP_GODDESSCARDSLOT_INFO_OPEN"](slot_index)
    end
end
-- エーテルジェム着脱時のメッセージ非表示
function no_check_GODDESS_MGR_SOCKET_REQ_GEM_REMOVE(my_frame, my_msg)
    local parent, btn = g.get_event_args(my_msg)
    if g.settings.no_check.use == 1 then
        local frame = parent:GetTopParentFrame()
        local slot = GET_CHILD_RECURSIVELY(frame, 'socket_slot')
        local guid = slot:GetUserValue('ITEM_GUID')
        if guid ~= 'None' then
            local index = parent:GetUserValue('SLOT_INDEX')
            local inv_item = session.GetInvItemByGuid(guid)
            if not inv_item then
                return
            end
            local item_obj = GetIES(inv_item:GetObject())
            local item_name = dic.getTranslatedStr(TryGetProp(item_obj, 'Name', 'None'))
            local gem_id = inv_item:GetEquipGemID(index)
            local gem_cls = GetClassByType('Item', gem_id)
            local gem_numarg1 = TryGetProp(gem_cls, 'NumberArg1', 0)
            local price = gem_numarg1 * 100
            local clmsg = 'None'
            local msg_cls_name = ''
            if TryGetProp(gem_cls, 'GemType', 'None') == 'Gem_High_Color' then
                _GODDESS_MGR_SOCKET_REQ_GEM_REMOVE(index)
            else
                local pc = GetMyPCObject()
                local is_gem_remove_care = IS_GEM_EXTRACT_FREE_CHECK(pc)
                local free_gem = nil
                for optionIdx = 1, 4 do
                    free_gem = GET_GEM_PROPERTY_TEXT(item_obj, optionIdx, index)
                    if free_gem then
                        _GODDESS_MGR_SOCKET_REQ_GEM_REMOVE(index)
                        return
                    end
                end
                if is_gem_remove_care then
                    msg_cls_name = "ReallyRemoveGem_Care"
                else
                    msg_cls_name = "ReallyRemoveGem"
                end
                local clmsg = "'" .. item_name .. ScpArgMsg("Auto_'_SeonTaeg") .. ScpArgMsg(msg_cls_name)
                local yes_scp = string.format('_GODDESS_MGR_SOCKET_REQ_GEM_REMOVE(%s)', index)
                local msgbox = ui.MsgBox(clmsg, yes_scp, '')
                SET_MODAL_MSGBOX(msgbox)
            end
        end
    else
        g.FUNCS["GODDESS_MGR_SOCKET_REQ_GEM_REMOVE"](parent, btn)
    end
end
-- ゴッデス装備帰属解除時の簡易化
function no_check_UNLOCK_TRANSMUTATIONSPREADER_BELONGING_SCROLL_EXEC_ASK_AGAIN(my_frame, my_msg)
    local frame, btn = g.get_event_args(my_msg)
    if g.settings.no_check.use == 1 then
        local scroll_type = frame:GetUserValue("ScrollType")
        local clickable = frame:GetUserValue("EnableTranscendButton")
        if tonumber(clickable) ~= 1 then
            return
        end
        local slot = GET_CHILD(frame, "slot")
        local inv_item = GET_SLOT_ITEM(slot)
        if not inv_item then
            ui.MsgBox(ScpArgMsg("DropItemPlz"))
            imcSound.PlaySoundEvent(frame:GetUserConfig("TRANS_BTN_OVER_SOUND"))
            return
        end
        local item_obj = GetIES(inv_item:GetObject())
        local scroll_guid = frame:GetUserValue("ScrollGuid")
        local scroll_inv_item = session.GetInvItemByGuid(scroll_guid)
        if not scroll_inv_item then
            return
        end
        UNLOCK_TRANSMUTATIONSPREADER_BELONGING_SCROLL_EXEC()
    else
        g.FUNCS["UNLOCK_TRANSMUTATIONSPREADER_BELONGING_SCROLL_EXEC_ASK_AGAIN"](frame, btn)
    end
end
-- ゴッデスアクセ帰属解除時の簡易化
function no_check_UNLOCK_ACC_BELONGING_SCROLL_EXEC_ASK_AGAIN(my_frame, my_msg)
    local frame, btn = g.get_event_args(my_msg)
    if g.settings.no_check.use == 1 then
        local scroll_type = frame:GetUserValue("ScrollType")
        local clickable = frame:GetUserValue("EnableTranscendButton")
        if tonumber(clickable) ~= 1 then
            return
        end
        local slot = GET_CHILD(frame, "slot")
        local inv_item = GET_SLOT_ITEM(slot)
        if not inv_item then
            ui.MsgBox(ScpArgMsg("DropItemPlz"))
            imcSound.PlaySoundEvent(frame:GetUserConfig("TRANS_BTN_OVER_SOUND"))
            return
        end
        local item_obj = GetIES(invItem:GetObject())
        local scroll_guid = frame:GetUserValue("ScrollGuid")
        local scroll_inv_item = session.GetInvItemByGuid(scroll_guid)
        if not scroll_inv_item then
            return
        end
        UNLOCK_ACC_BELONGING_SCROLL_EXEC()
    else
        g.FUNCS["UNLOCK_ACC_BELONGING_SCROLL_EXEC_ASK_AGAIN"](frame, btn)
    end
end
-- チャンネル移動時の確認を削除
function no_check_SELECT_ZONE_MOVE_CHANNEL(my_frame, my_msg)
    local index, channel_id = g.get_event_args(my_msg)
    if g.settings.no_check.use == 1 then
        local zone_insts = session.serverState.GetMap()
        if not zone_insts or zone_insts.pcCount == -1 then
            ui.SysMsg(ClMsg("ChannelIsClosed"))
            return
        end
        local pc = GetMyPCObject()
        if IS_BOUNTY_BATTLE_BUFF_APPLIED(pc) == 1 then
            ui.SysMsg(ClMsg("DoingBountyBattle"))
            return
        end
        if IS_JUMP_MAP_BUFF_APPLIED(pc) == 1 then
            return
        end
        RUN_GAMEEXIT_TIMER("Channel", channel_id)
    else
        g.FUNCS["SELECT_ZONE_MOVE_CHANNEL"](index, channel_id)
    end
end
-- カードブック使用時の確認削除
function no_check_BEFORE_APPLIED_NON_EQUIP_ITEM_OPEN(my_frame, my_msg)
    local inv_item = g.get_event_args(my_msg)
    if g.settings.no_check.use == 1 then
        if not inv_item then
            return
        end
        local inventory = ui.GetFrame("inventory")
        local item_obj = GetIES(inv_item:GetObject())
        if not item_obj then
            return
        end
        inventory:SetUserValue("REQ_USE_ITEM_GUID", inv_item:GetIESID())
        if item_obj.Script == 'SCR_SUMMON_MONSTER_FROM_CARDBOOK' then
            REQUEST_SUMMON_BOSS_TX()
        elseif item_obj.Script == 'SCR_QUEST_CLEAR_LEGEND_CARD_LIFT' then
            local textmsg = string.format("[ %s ]{nl}%s", item_obj.Name, ScpArgMsg("Use_Item_LegendCard_Slot_Open2"))
            ui.MsgBox_NonNested(textmsg, item_obj.Name, "REQUEST_SUMMON_BOSS_TX", "None")
            return
        end
    else
        g.FUNCS["BEFORE_APPLIED_NON_EQUIP_ITEM_OPEN"](inv_item)
    end
end

function no_check_timer(_nexus_addons, no_check_timer)
    if g.settings.no_check.use == 0 then
        return
    end
    no_check_WARNINGMSGBOX_FRAME_OPEN()
    no_check_WARNINGMSGBOX_EX_FRAME_OPEN()
end
-- warning_boxs制御
function no_check_WARNINGMSGBOX_FRAME_OPEN()
    local warningmsgbox = ui.GetFrame("warningmsgbox")
    if warningmsgbox:IsVisible() == 0 then
        return
    end
    local warningtext = GET_CHILD_RECURSIVELY(warningmsgbox, "warningtext")
    local msg = ClMsg("destory_now")
    msg = dictionary.ReplaceDicIDInCompStr(msg)
    if string.find(warningtext:GetText(), msg) then
        local input = GET_CHILD_RECURSIVELY(warningmsgbox, "input")
        input:SetText(msg)
    end
end

function no_check_WARNINGMSGBOX_EX_FRAME_OPEN()
    local warningmsgbox_ex = ui.GetFrame('warningmsgbox_ex')
    if warningmsgbox_ex:IsVisible() == 0 then
        return
    end
    local compareText = GET_CHILD_RECURSIVELY(warningmsgbox_ex, "comparetext")
    local start, finish = string.find(compareText:GetText(), "nl%}%[")
    if start and finish then
        local next_sub_string = compareText:GetText():sub(finish + 1)
        local next_start, next_finish = string.find(next_sub_string, "%]")
        if next_start and next_finish then
            local desiredText = next_sub_string:sub(1, next_start - 1)
            local input = GET_CHILD_RECURSIVELY(warningmsgbox_ex, "input")
            input:SetText(desiredText)
        end
    end
end
-- 連続金床強化
function no_check_MORU_LBTN_CLICK(my_frame, my_msg)
    if g.settings.no_check.use == 0 then
        return
    end
    no_check_REINFORCE_131014_MSGBOX()
end

function no_check_REINFORCE_131014_MSGBOX()
    local reinforce_131014 = ui.GetFrame("reinforce_131014")
    local from_item, from_moru = GET_REINFORCE_TARGET_AND_MORU(reinforce_131014)
    local from_item_obj = GetIES(from_item:GetObject())
    local moru_obj = GetIES(from_moru:GetObject())
    local exec = GET_CHILD_RECURSIVELY(reinforce_131014, "exec")
    local skipOver5 = GET_CHILD_RECURSIVELY(reinforce_131014, "skipOver5")
    skipOver5:SetCheck(1)
    exec:ShowWindow(0)
    no_check_REINFORCE_131014_EXEC(reinforce_131014, from_item, from_moru)
end

function no_check_REINFORCE_131014_EXEC(reinforce_131014)
    if reinforce_131014:IsVisible() == 0 then
        reinforce_131014:StopUpdateScript("no_check_REINFORCE_131014_EXEC")
        return 0
    end
    local from_item, from_moru = GET_REINFORCE_TARGET_AND_MORU(reinforce_131014)
    if from_item and from_moru ~= nil and reinforce_131014:IsVisible() == 1 then
        session.ResetItemList()
        session.AddItemID(fromItem:GetIESID())
        session.AddItemID(fromMoru:GetIESID())
        local resultlist = session.GetItemIDList()
        item.DialogTransaction("ITEM_REINFORCE_131014", resultlist)
        reinforce_131014:RunUpdateScript("no_check_REINFORCE_131014_EXEC", 0.3)
    end
    REINFORCE_131014_UPDATE_MORU_COUNT(reinforce_131014)
    return 1
end
-- no_check ここまで

-- vakarine_equip ここから
function vakarine_equip_save_settings()
    g.save_json(g.vakarine_equip_path, g.vakarine_equip_settings)
end

function vakarine_equip_load_settings()
    g.vakarine_equip_path = string.format("../addons/%s/%s/vakarine_equip.json", addon_name_lower, g.active_id)
    local settings = g.load_json(g.vakarine_equip_path)
    if not settings then
        settings = {
            buffid = {},
            delay = 0.1,
            jsr = 0,
            x = 0,
            y = 0,
            move = 1,
            chars = {},
            auto_remove = 0
        }
    end
    g.vakarine_equip_settings = settings
    vakarine_equip_save_settings()
end

function vakarine_equip_on_init()
    ui.SetHoldUI(false)
    if not g.vakarine_equip_settings then
        vakarine_equip_load_settings()
    end
    if not g.vakarine_equip_settings.chars[g.cid] then
        vakarine_equip_chrs_settings()
    end
    if g.settings.vakarine_equip.use == 0 then
        ui.DestroyFrame(addon_name_lower .. "vakarine_equip")
        return
    end
    g.addon:RegisterMsg('STAT_UPDATE', 'vakarine_equip_stat_update')
    g.addon:RegisterMsg('TAKE_DAMAGE', 'vakarine_equip_stat_update')
    g.addon:RegisterMsg('TAKE_HEAL', 'vakarine_equip_stat_update')
    g.addon:RegisterMsg('BUFF_ADD', 'vakarine_equip_BUFF_ON_MSG')
    g.addon:RegisterMsg('BUFF_UPDATE', 'vakarine_equip_BUFF_ON_MSG')
    vakarine_equip_frame_init()
    if g.get_map_type() ~= "City" then
        vakarine_equip_start_operation()
    end
end

function vakarine_equip_chrs_settings()
    local equips = {"RH", "LH", "RH_SUB", "LH_SUB", "RING1", "RING2", "SHIRT", "PANTS", "GLOVES", "BOOTS", "SHOULDER",
                    "BELT", "NECK"}
    g.vakarine_equip_settings.chars[g.cid] = {
        use = 0
    }
    for _, equip in ipairs(equips) do
        g.vakarine_equip_settings.chars[g.cid][equip] = 0
    end
    vakarine_equip_save_settings()
end

function vakarine_equip_frame_init()
    local vakarine_equip = ui.CreateNewFrame("notice_on_pc", addon_name_lower .. "vakarine_equip", 0, 0, 0, 0)
    AUTO_CAST(vakarine_equip)
    vakarine_equip:SetSkinName("None")
    vakarine_equip:SetTitleBarSkin("None")
    vakarine_equip:Resize(40, 30)
    vakarine_equip:SetGravity(ui.RIGHT, ui.TOP)
    vakarine_equip:EnableMove(g.vakarine_equip_settings.move == 1 and 0 or 1)
    vakarine_equip:EnableHittestFrame(1)
    local rect = vakarine_equip:GetMargin()
    vakarine_equip:SetMargin(rect.left - rect.left, rect.top - rect.top + 300,
        rect.right == 0 and rect.right + 10 or rect.right, rect.bottom)
    if g.vakarine_equip_settings.x ~= 0 and g.vakarine_equip_settings.y ~= 0 then
        vakarine_equip:SetPos(g.vakarine_equip_settings.x, g.vakarine_equip_settings.y)
    end
    vakarine_equip:SetEventScript(ui.LBUTTONUP, "vakarine_equip_location_save")
    local vaka_pic = vakarine_equip:CreateOrGetControl("picture", "vaka_pic", 0, 0, 30, 30)
    AUTO_CAST(vaka_pic)
    vaka_pic:SetImage("bakarine_emotion68") -- vaka_pic:SetImage("bakarine_emotion61") vaka_pic:SetImage("emoticon_0024")
    vaka_pic:SetColorTone("FFFFFFFF")
    vaka_pic:SetEnableStretch(1)
    vaka_pic:EnableHitTest(1)
    vaka_pic:SetGravity(ui.LEFT, ui.TOP)
    vaka_pic:SetTextTooltip(g.lang == "Japanese" and
                                "{ol}Vakarine Equip{nl} {nl}左クリック{nl}街: 設定{nl}街以外: 手動起動{nl} {nl}右クリック{nl}自動起動ON/OFF" or
                                "{ol}Vakarine Equip{nl} {nl}Left click{nl}City: Setup{nl}Outside City: Manual activation{nl} {nl}Right click: Auto-activation ON/OFF")
    if g.vakarine_equip_settings.chars[g.cid].use == 0 then
        vaka_pic:SetColorTone("FF555555")
    else
        vaka_pic:SetColorTone("FFFFFFFF")
    end
    vaka_pic:SetEventScript(ui.RBUTTONUP, "vakarine_equip_onoff_switch")
    vaka_pic:SetEventScript(ui.LBUTTONUP, "vakarine_equip_config_or_startup")
    vakarine_equip:ShowWindow(1)
    if g.vakarine_equip_animas_iesid and g.get_map_type() == "City" then
        vakarine_equip:RunUpdateScript("vakarine_equip_animas_equip", 1.0)
    end
end

function vakarine_equip_location_save(frame, ctrl)
    if frame:GetName() == addon_name_lower .. "vakarine_equip" then
        g.vakarine_equip_settings.x = frame:GetX()
        g.vakarine_equip_settings.y = frame:GetY()
    elseif ctrl:GetName() == "default_btn" then
        g.vakarine_equip_settings.x = 0
        g.vakarine_equip_settings.y = 0
        ui.DestroyFrame(addon_name_lower .. "vakarine_equip")
        ReserveScript("vakarine_equip_frame_init()", 0.1)
    end
    vakarine_equip_save_settings()
end

function vakarine_equip_onoff_switch(vakarine_equip, vaka_pic)
    if keyboard.IsKeyPressed("LSHIFT") == 1 then
        vakarine_equip_buff_list(nil, nil, "")
        return
    end
    if g.vakarine_equip_settings.chars[g.cid].use == 0 then
        g.vakarine_equip_settings.chars[g.cid].use = 1
        vaka_pic:SetColorTone("FFFFFFFF")
    else
        vaka_pic:SetColorTone("FF555555")
        g.vakarine_equip_settings.chars[g.cid].use = 0
    end
    vakarine_equip_save_settings()
end

function vakarine_equip_animas_equip(vakarine_equip)
    local equip_item_list = session.GetEquipItemList()
    local equip_item = equip_item_list:GetEquipItemByIndex(19)
    if equip_item then
        local iesid = equip_item:GetIESID()
        local try = vakarine_equip:GetUserIValue("TRY")
        if iesid ~= g.vakarine_equip_animas_iesid and try < 3 then
            local equip_item = session.GetInvItemByGuid(g.vakarine_equip_animas_iesid)
            item.Equip(equip_item.invIndex)
            vakarine_equip:GetUserIValue("TRY", try + 1)
            return 1
        end
    end
    vakarine_equip:GetUserIValue("TRY", 0)
    g.vakarine_equip_animas_iesid = nil
    return 0
end

function vakarine_equip_config_or_startup(frame, ctrl)
    if g.get_map_type() == "City" then
        vakarine_equip_config_frame_open()
    else
        vakarine_equip_start_operation(true)
    end
end

function vakarine_equip_start_operation(is_manual)
    local is_vakarine = vakarine_equip_is_vakarine()
    if not is_vakarine and not is_manual then
        return
    end
    local vakarine_equip = ui.GetFrame(addon_name_lower .. "vakarine_equip") -- 11244 聖域3F 11227 分裂 8022 ヴェルニケ
    if (g.get_map_type() == "Instance" and g.map_id ~= 11227) or g.map_id == 8022 or g.map_id == 11244 or not is_manual or
        g.vakarine_equip_settings.jsr == 1 then
        g.vakarine_equip_field_boss = nil
        local inventory = ui.GetFrame("inventory")
        inventory:ShowWindow(1)
        DO_WEAPON_SLOT_CHANGE(inventory, 1)
        ui.SetHoldUI(true)
        local vakarine_equip = ui.GetFrame(addon_name_lower .. "vakarine_equip")
        vakarine_equip:RunUpdateScript("vakarine_equip_holdui_release", 10.0)
        local equip_map = {
            RH = 8,
            LH = 9,
            RH_SUB = 30,
            LH_SUB = 31,
            RING1 = 17,
            RING2 = 18,
            SHIRT = 3,
            PANTS = 14,
            GLOVES = 4,
            BOOTS = 5,
            SHOULDER = 34,
            BELT = 33,
            NECK = 19
        }
        g.vakarine_equip_queue = {}
        local char_settings = g.vakarine_equip_settings.chars[g.cid]
        local equip_item_list = session.GetEquipItemList()
        for spot_name, index in pairs(equip_map) do
            local current_item = equip_item_list:GetEquipItemByIndex(index)
            if char_settings[spot_name] == 1 and current_item then
                table.insert(g.vakarine_equip_queue, {
                    spot = spot_name,
                    index = index,
                    iesid = current_item:GetIESID()
                })
            end
        end
        local animas_item = session.GetInvItemByName("NECK04_103")
        g.vakarine_equip_animas_iesid = animas_item and animas_item:GetIESID() or nil
        if #g.vakarine_equip_queue == 0 then
            ui.SetHoldUI(false)
            return
        end
        for i, data in ipairs(g.vakarine_equip_queue) do
            if data.spot == "RH_SUB" then
                item.UnEquip(data.index)
                break
            end
        end
        g.vakarine_equip_process_step = "unequip"
        vakarine_equip:RunUpdateScript("vakarine_equip_main_loop", g.vakarine_equip_settings.delay)
    end
end

function vakarine_equip_main_loop(vakarine_equip)
    local equip_item_list = session.GetEquipItemList()
    if g.vakarine_equip_process_step == "unequip" then
        local all_unequipped = true
        for _, data in ipairs(g.vakarine_equip_queue) do
            local current_item = equip_item_list:GetEquipItemByIndex(data.index)
            if current_item and current_item:GetIESID() ~= "0" then
                item.UnEquip(data.index)
                return 1
            end
        end
        if all_unequipped then
            g.vakarine_equip_process_step = "equip"
        end
        return 1
    elseif g.vakarine_equip_process_step == "equip" then
        local weapon_order = {"RH", "LH", "RH_SUB", "LH_SUB"}
        for _, spot_name in ipairs(weapon_order) do
            for _, data in ipairs(g.vakarine_equip_queue) do
                if data.spot == spot_name then
                    local current_item = equip_item_list:GetEquipItemByIndex(data.index)
                    if not current_item or current_item:GetIESID() ~= data.iesid then
                        local inv_item = session.GetInvItemByGuid(data.iesid)
                        if inv_item then
                            ITEM_EQUIP(inv_item.invIndex, data.spot)
                            return 1
                        end
                    end
                    break
                end
            end
        end
        for _, data in ipairs(g.vakarine_equip_queue) do
            local spot_name = data.spot
            if spot_name ~= "RH" and spot_name ~= "LH" and spot_name ~= "RH_SUB" and spot_name ~= "LH_SUB" and spot_name ~=
                "NECK" then
                local current_item = equip_item_list:GetEquipItemByIndex(data.index)
                if not current_item or current_item:GetIESID() ~= data.iesid then
                    local inv_item = session.GetInvItemByGuid(data.iesid)
                    if inv_item then
                        ITEM_EQUIP(inv_item.invIndex, data.spot)
                        return 1
                    end
                end
            end
        end
        for _, data in ipairs(g.vakarine_equip_queue) do
            if data.spot == "NECK" then
                local iesid_to_equip = g.vakarine_equip_animas_iesid or data.iesid
                local current_item = equip_item_list:GetEquipItemByIndex(data.index)
                local current_iesid = current_item and current_item:GetIESID() or "0"
                if current_iesid ~= iesid_to_equip then
                    local inv_item = session.GetInvItemByGuid(iesid_to_equip)
                    if inv_item then
                        ITEM_EQUIP(inv_item.invIndex, data.spot)
                        return 1
                    end
                end
                break
            end
        end
        local inventory = ui.GetFrame("inventory")
        inventory:ShowWindow(0)
        imcAddOn.BroadMsg("NOTICE_Dm_stage_start", "[VE]End of Operation", 3)
        ui.SetHoldUI(false)
        return 0
    end
    return 1
end

function vakarine_equip_is_vakarine()
    local equip_item_list = session.GetEquipItemList()
    local equip_guid_list = equip_item_list:GetGuidList()
    local count = equip_guid_list:Count()
    local vakarine_count = 0
    for i = 0, count - 1 do
        local guid = equip_guid_list:Get(i)
        if guid ~= '0' then
            local equip_item = equip_item_list:GetItemByGuid(guid)
            local item = GetIES(equip_item:GetObject())
            for j = 1, MAX_OPTION_EXTRACT_COUNT do
                local prop_name = "RandomOption_" .. j
                local cls_msg = ScpArgMsg(item[prop_name])
                if string.find(cls_msg, "vakarine_bless") then
                    vakarine_count = vakarine_count + 1
                    break
                end
            end
        end
    end
    if vakarine_count >= 5 then
        return true
    elseif vakarine_count == 4 then
        return false
    else
        return false
    end
end

function vakarine_equip_holdui_release(frame)
    ui.SetHoldUI(false)
    return 0
end

function vakarine_equip_config_frame_open()
    local config = ui.CreateNewFrame("notice_on_pc", addon_name_lower .. "vakarine_equip_config_frame", 0, 0, 0, 0)
    AUTO_CAST(config)
    config:RemoveAllChild()
    config:SetLayerLevel(999)
    config:SetSkinName("test_frame_low")
    local title_text = config:CreateOrGetControl("richtext", "title_text", 10, 10)
    AUTO_CAST(title_text)
    title_text:SetText("{ol}Vakarine Equip")
    local config_gb = config:CreateOrGetControl("groupbox", "config_gb", 10, 40, 0, 0)
    AUTO_CAST(config_gb)
    config_gb:SetSkinName("bg")
    local close = config:CreateOrGetControl("button", "close", 0, 0, 20, 20)
    AUTO_CAST(close)
    close:SetImage("testclose_button")
    close:SetGravity(ui.RIGHT, ui.TOP)
    close:SetEventScript(ui.LBUTTONUP, "vakarine_equip_frame_close")
    local jsr_check = config_gb:CreateOrGetControl('checkbox', "jsr_check", 10, 5, 30, 30)
    AUTO_CAST(jsr_check)
    jsr_check:SetCheck(g.vakarine_equip_settings.jsr)
    local text = g.lang == "Japanese" and "チェックするとJSRで作動" or "Activated in JSR when checked"
    jsr_check:SetText("{ol}" .. text)
    jsr_check:SetEventScript(ui.LBUTTONUP, "vakarine_equip_check_switch")
    local x = 0
    local width = jsr_check:GetWidth()
    if x < width then
        x = width
    end
    local y = 40
    local equips = {"RH", "LH", "RH_SUB", "LH_SUB", "RING1", "RING2", "SHIRT", "PANTS", "GLOVES", "BOOTS", "SHOULDER",
                    "BELT", "NECK"}
    for i, equip_name in ipairs(equips) do
        local check_box = config_gb:CreateOrGetControl('checkbox', "check_box" .. i, 20, y, 30, 30)
        AUTO_CAST(check_box)
        check_box:SetCheck(g.vakarine_equip_settings.chars[g.cid][equip_name])
        check_box:SetTextTooltip(g.lang == "Japanese" and "{ol}チェックした装備を脱着します" or
                                     "{ol}Remove and detach checked equipment")
        check_box:SetEventScript(ui.LBUTTONUP, "vakarine_equip_check_switch")
        check_box:SetEventScriptArgString(ui.LBUTTONUP, equip_name)
        if equip_name == "RING1" then
            equip_name = "Ring1"
        elseif equip_name == "RING2" then
            equip_name = "Ring2"
        elseif equip_name == "SHIRT" then
            equip_name = "Shirt"
        elseif equip_name == "PANTS" then
            equip_name = "Pants"
        end
        check_box:SetText("{ol}" .. ClMsg(equip_name))
        y = y + 30
    end
    y = y + 10
    local move_check = config_gb:CreateOrGetControl('checkbox', "move_check", 10, y, 30, 30)
    AUTO_CAST(move_check)
    move_check:SetCheck(g.vakarine_equip_settings.move)
    move_check:SetText(g.lang == "Japanese" and "{ol}チェックするとフレーム固定" or
                           "{ol}If checked, the frame is fixed")
    move_check:SetEventScript(ui.LBUTTONUP, "vakarine_equip_check_switch")
    y = y + 40
    local default_btn = config_gb:CreateOrGetControl("button", "default_btn", 20, y, 120, 30)
    AUTO_CAST(default_btn)
    default_btn:SetText(g.lang == "Japanese" and "{ol}フレーム初期位置" or "{ol}Init frame pos")
    default_btn:SetEventScript(ui.LBUTTONUP, "vakarine_equip_location_save")
    y = y + 30
    config:Resize(x + 70, y + 60)
    config_gb:Resize(x + 50, y + 10)
    local list_frame = ui.GetFrame(addon_name_lower .. "list_frame")
    if list_frame then
        config:SetPos(list_frame:GetX() + list_frame:GetWidth(), list_frame:GetY())
    else
        local map_frame = ui.GetFrame("map")
        local width = map_frame:GetWidth()
        config:SetPos(width / 2 - config:GetWidth() / 2 or 1165, 105)
    end
    config:ShowWindow(1)
end

function vakarine_equip_check_switch(config, ctrl, equip_name, num)
    local ischeck = ctrl:IsChecked()
    if ctrl:GetName() == "jsr_check" then
        g.vakarine_equip_settings.jsr = ischeck
    elseif ctrl:GetName() == "move_check" then
        g.vakarine_equip_settings.move = ischeck
        vakarine_equip_frame_init()
    elseif string.find(ctrl:GetName(), "check_box") then
        g.vakarine_equip_settings.chars[g.cid][equip_name] = ischeck
        if equip_name == "RH_SUB" then
            g.vakarine_equip_settings.chars[g.cid]["LH_SUB"] = ischeck
        elseif equip_name == "LH_SUB" then
            g.vakarine_equip_settings.chars[g.cid]["RH_SUB"] = ischeck
        end
        vakarine_equip_config_frame_open()
    end
    vakarine_equip_save_settings()
end

function vakarine_equip_stat_update()
    if g.settings.vakarine_equip.use == 0 then
        return
    end
    local charbaseinfo1_my = ui.GetFrame("charbaseinfo1_my")
    if not charbaseinfo1_my then
        return
    end
    local hp = GET_CHILD(charbaseinfo1_my, "pcHpGauge")
    AUTO_CAST(hp)
    local handle = session.GetMyHandle()
    local stat = info.GetStat(handle)
    local hp_now = (stat.HP * 100) / stat.maxHP
    local status = ''
    local color = ""
    if (hp_now == 100) then
        color = '#00EC00'
        status = 'Perfect'
    elseif g.vakarine and (hp_now <= 45) then
        color = '#EA0000'
        status = 'Revenge'
    elseif not g.vakarine and (hp_now <= 35) then
        color = '#EA0000'
        status = 'Revenge'
    elseif hp_now == 0 then
        color = '#FFFFFF'
    else
        color = '#FFFFFF'
    end
    local effecttext =
        charbaseinfo1_my:CreateOrGetControl("richtext", "effecttext", 0, 0, hp:GetWidth(), hp:GetHeight())
    effecttext:SetText(string.format('{ol}{%s}{%s}%s', "s15", color, status))
    effecttext:SetGravity(ui.RIGHT, ui.TOP)
    effecttext:SetOffset(hp:GetX(), hp:GetY() - 25 - (15 - 15))
    local hptext = charbaseinfo1_my:CreateOrGetControl("richtext", "hptext", 0, 0, hp:GetWidth(), hp:GetHeight())
    hptext:SetText(string.format('{%s}{ol}{%s}%d%%', "s15", color, hp_now))
    hptext:SetGravity(ui.RIGHT, ui.TOP)
    hptext:SetOffset(hp:GetX(), hp:GetY() - 10 - (15 - 15))
end

function vakarine_equip_BUFF_ON_MSG(frame, msg, str, buff_id)
    if g.settings.vakarine_equip.use == 0 then
        return
    end
    if g.vakarine_equip_settings and g.vakarine_equip_settings["buffid"] then
        for id_str, val in pairs(g.vakarine_equip_settings["buffid"]) do
            if tonumber(id_str) == buff_id then
                if g.vakarine_equip_settings.auto_remove == 1 then
                    if val == 1 and g.vakarine then
                        REMOVE_BUF(nil, nil, nil, buff_id) -- 良くないね
                        return
                    end
                end
            end
        end
    end
end

function vakarine_equip_buff_list(buff_list, ctrl, ctrl_text)
    local buff_list = ui.GetFrame(addon_name_lower .. "vakarine_equip_buff_list")
    if not buff_list then
        buff_list = ui.CreateNewFrame("notice_on_pc", addon_name_lower .. "vakarine_equip_buff_list", 0, 0, 0, 0)
        AUTO_CAST(buff_list)
        buff_list:SetSkinName("test_frame_low")
        buff_list:Resize(500, 1060)
        buff_list:SetPos(150, 10)
        buff_list:SetLayerLevel(121)
        local search_edit = buff_list:CreateOrGetControl("edit", "search_edit", 40, 10, 305, 38)
        AUTO_CAST(search_edit)
        search_edit:SetFontName("white_18_ol")
        search_edit:SetTextAlign("left", "center")
        search_edit:SetSkinName("inventory_serch")
        search_edit:SetEventScript(ui.ENTERKEY, "vakarine_equip_buff_list_search")
        local search_btn = search_edit:CreateOrGetControl("button", "search_btn", 0, 0, 40, 38)
        AUTO_CAST(search_btn)
        search_btn:SetImage("inven_s")
        search_btn:SetGravity(ui.RIGHT, ui.TOP)
        search_btn:SetEventScript(ui.LBUTTONUP, "vakarine_equip_buff_list_search")
        local func_toggle = buff_list:CreateOrGetControl('checkbox', 'func_toggle', 415, 15, 25, 25)
        AUTO_CAST(func_toggle)
        func_toggle:SetTextTooltip(g.lang == "Japanese" and "{ol}チェックすると自動バフ削除有効化" or
                                       "{ol}Check to enable auto buff removal")
        func_toggle:SetEventScript(ui.LBUTTONUP, "vakarine_equip_buff_aoto_remove")
        func_toggle:SetCheck(g.vakarine_equip_settings.auto_remove or 0)
        local close = buff_list:CreateOrGetControl('button', 'close', 0, 0, 20, 20)
        AUTO_CAST(close)
        close:SetImage("testclose_button")
        close:SetGravity(ui.RIGHT, ui.TOP)
        close:SetEventScript(ui.LBUTTONUP, "vakarine_equip_frame_close")
    end
    local buff_list_gb = buff_list:CreateOrGetControl("groupbox", "buff_list_gb", 10, 50, 480,
        buff_list:GetHeight() - 60)
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
                        local is_checked = g.vakarine_equip_settings["buffid"][tostring(buff_cls.ClassID)] == true
                        table.insert(all_buffs, {
                            cls = buff_cls,
                            name = buff_name,
                            image = image_name,
                            is_checked = is_checked
                        })
                    end
                end
            end
        end
    end
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
        buff_check:SetTextTooltip(g.lang == "Japanese" and "{ol}チェックすると自動でバフ削除" or
                                      "{ol}Check to automatically remove buff")
        buff_check:SetCheck(buff_data.is_checked and 1 or 0)
        buff_check:SetEventScript(ui.LBUTTONUP, "vakarine_equip_buff_toggle")
        buff_check:SetEventScriptArgString(ui.LBUTTONUP, buff_id)
        y = y + 35
    end
    buff_list:ShowWindow(1)
end

function vakarine_equip_buff_list_search(buff_list, ctrl, ctrl_text, num)
    local search_edit = GET_CHILD_RECURSIVELY(buff_list, "search_edit")
    local ctrl_text = search_edit:GetText()
    if ctrl_text ~= "" then
        vakarine_equip_buff_list(buff_list, ctrl, ctrl_text)
    else
        vakarine_equip_buff_list(buff_list, ctrl, "")
    end
end

function vakarine_equip_buff_aoto_remove()
    if g.vakarine_equip_settings.auto_remove == 0 then
        g.vakarine_equip_settings.auto_remove = 1
    else
        g.vakarine_equip_settings.auto_remove = 0
    end
    vakarine_equip_save_settings()
end

function vakarine_equip_buff_toggle(frame, ctrl, str_buff_id, num)
    local is_check = ctrl:IsChecked()
    if is_check == 1 then
        g.vakarine_equip_settings["buffid"][str_buff_id] = true
    else
        g.vakarine_equip_settings["buffid"][str_buff_id] = false
    end
    vakarine_equip_save_settings()
end

function vakarine_equip_frame_close(frame, ctrl, str, num)
    ui.DestroyFrame(frame:GetName())
end
-- vakarine_equip ここまで

-- revival_timer ここから
function revival_timer_save_settings()
    g.save_json(g.revival_timer_path, g.revival_timer_settings)
end

function revival_timer_load_settings()
    g.revival_timer_path = string.format("../addons/%s/%s/revival_timer.json", addon_name_lower, g.active_id)
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
    if not g.revival_timer_settings then
        revival_timer_load_settings()
    end
    if g.settings.revival_timer.use == 1 then
        revival_timer_frame_init()
    else
        local _nexus_addons = ui.GetFrame("_nexus_addons")
        _nexus_addons:RemoveChild("revival_timer_keypress")
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
    local _nexus_addons = ui.GetFrame("_nexus_addons")
    _nexus_addons:SetVisible(1)
    local revival_timer_keypress = _nexus_addons:CreateOrGetControl("timer", "revival_timer_keypress", 0, 0)
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
        frame:SetVisible(1)
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
        control.Pose(pose_cls.ClassName)
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

function revival_timer_keypress(_nexus_addons)
    if not g.revival_timer_settings.shortcut and not g.revival_timer_settings.shortcut_l then
        return
    end
    local cool_down = 200 -- 200ミリ秒
    local now = imcTime.GetAppTimeMS()
    if now - g.revival_timer_last_keypress < cool_down then
        return
    end
    g.revival_timer_last_keypress = now
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
function relic_change_save_settings()
    g.save_json(g.relic_change_path, g.relic_change_settings)
end

function relic_change_load_settings()
    g.relic_change_path = string.format("../addons/%s/%s/relic_change.json", addon_name_lower, g.active_id)
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
    relicmanager:ShowWindow(1)
    local tab = GET_CHILD_RECURSIVELY(relicmanager, 'type_Tab')
    tab:SelectTab(2)
    RELICMANAGER_SOCKET_UPDATE(relicmanager)
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
    g.quickslot_operate_path = string.format("../addons/%s/%s/quickslot_operate.json", addon_name_lower, g.active_id)
    g.quickslot_operate_old_path = string.format("../addons/%s/%s/settings_250609.json", "quickslot_operate",
        g.active_id)
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
    local _nexus_addons = ui.GetFrame("_nexus_addons")
    _nexus_addons:SetVisible(1)
    if g.settings.quickslot_operate.use == 0 then
        local quickslot_operate_map_timer = GET_CHILD(_nexus_addons, "quickslot_operate_map_timer")
        if quickslot_operate_map_timer then
            _nexus_addons:RemoveChild("quickslot_operate_map_timer")
        end
        local quickslot_operate_timer = GET_CHILD(_nexus_addons, "quickslot_operate_timer")
        if quickslot_operate_timer then
            _nexus_addons:RemoveChild("quickslot_operate_timer")
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
    local quickslot_operate_map_timer = _nexus_addons:CreateOrGetControl("timer", "quickslot_operate_map_timer", 0, 0)
    AUTO_CAST(quickslot_operate_map_timer)
    quickslot_operate_map_timer:SetUpdateScript("quickslot_operate_map_change")
    quickslot_operate_map_timer:Stop()
    quickslot_operate_map_timer:Start(3.0)
    local quickslot_operate_timer = _nexus_addons:CreateOrGetControl("timer", "quickslot_operate_timer", 0, 0)
    AUTO_CAST(quickslot_operate_timer)
    quickslot_operate_timer:SetUpdateScript("quickslot_operate_set_rshift_script")
    quickslot_operate_timer:Start(0.15)
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
    local _nexus_addons = ui.GetFrame("_nexus_addons")
    local quickslot_operate_map_timer = _nexus_addons:CreateOrGetControl("timer", "quickslot_operate_map_timer", 0, 0)
    AUTO_CAST(quickslot_operate_map_timer)
    quickslot_operate_map_timer:Stop()
    quickslot.RequestSave()
    QUICKSLOTNEXPBAR_UPDATE_HOTKEYNAME(quickslotnexpbar)
    if IsJoyStickMode() == 1 then
        quickslotnexpbar:ShowWindow(0)
        joystickquickslot:ShowWindow(1)
    end
    DebounceScript("JOYSTICK_QUICKSLOT_UPDATE_ALL_SLOT", 0.1)
end

function quickslot_operate_frame_close()
    local quickslot_operate = ui.GetFrame(addon_name_lower .. "quickslot_operate")
    if quickslot_operate then
        ui.DestroyFrame(quickslot_operate:GetName())
    end
end

function quickslot_operate_map_change(_nexus_addons, quickslot_operate_map_timer)
    local quickslotnexpbar = ui.GetFrame("quickslotnexpbar")
    for _, zone_id in ipairs(g.quickslot_operate_zone_list) do
        if zone_id == g.map_id then
            local potion_type = quickslot_operate_get_potion_type(g.quickslot_operate_indun_type)
            if potion_type then
                quickslotnexpbar:SetUserValue("POT_TYPE", potion_type)
                quickslotnexpbar:RunUpdateScript("quickslot_operate_get_potion", 2.0)
                return
            end
        end
    end -- 11285, 11286
    for _, eventmap_id in ipairs(g.quickslot_guild_eventmap) do
        if eventmap_id == g.map_id then
            if eventmap_id == 11285 or eventmap_id == 11286 then
                quickslotnexpbar:SetUserValue("POT_TYPE", "Paramune")
            else
                quickslotnexpbar:SetUserValue("POT_TYPE", "Velnias")
            end
            quickslotnexpbar:RunUpdateScript("quickslot_operate_get_potion", 2.0)
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
    local potion_type = quickslotnexpbar:GetUserValue("POT_TYPE")
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
    local _nexus_addons = ui.GetFrame("_nexus_addons")
    _nexus_addons:SetVisible(1)
    if g.quickslot_operate_settings.rshift == true then
        g.quickslot_operate_settings.rshift = false
        local quickslot_operate_timer = GET_CHILD(_nexus_addons, "quickslot_operate_timer")
        if quickslot_operate_timer then
            _nexus_addons:RemoveChild("quickslot_operate_timer")
        end
    else
        g.quickslot_operate_settings.rshift = true
        local quickslot_operate_timer = _nexus_addons:CreateOrGetControl("timer", "quickslot_operate_timer", 0, 0)
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
function my_buffs_control_save_settings()
    g.save_json(g.my_buffs_control_path, g.my_buffs_control_settings)
end

function my_buffs_control_load_settings()
    g.my_buffs_control_path = string.format("../addons/%s/%s/my_buffs_control.json", addon_name_lower, g.active_id)
    g.my_buffs_control_old_path = string.format("../addons/%s/settings_2503.json", "my_buffs")
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
    g.setup_hook_and_event(g.addon, "BUFF_ON_MSG", "my_buffs_BUFF_ON_MSG", true)
    if g.settings.my_buffs_control.use == 1 then
        my_buffs_control_frame()
    else
        my_buffs_control_reset_ui()
    end
    my_buffs_common_buff_msg()
end

function my_buffs_common_buff_msg()
    if g.get_map_type() == 'City' then
        return
    end
    local buff_frame = ui.GetFrame("buff")
    local my_handle = session.GetMyHandle()
    local buff_count = info.GetBuffCount(my_handle)
    if g.settings.my_buffs_control.use == 0 then
        COMMON_BUFF_MSG(buff_frame, "CLEAR", 0, 0, s_buff_ui, 0)
        for i = 0, buff_count - 1 do
            local buff = info.GetBuffIndexed(my_handle, i)
            if buff then
                g.FUNCS["BUFF_ON_MSG"](buff_frame, "BUFF_ADD", tostring(buff.index), buff.buffID)
            end
        end
    else
        local displayed_buffs = {}
        for group_index = 0, s_buff_ui["buff_group_cnt"] do
            if s_buff_ui["slotlist"][group_index] and s_buff_ui["slotcount"][group_index] then
                for i = 0, s_buff_ui["slotcount"][group_index] - 1 do
                    local slot = s_buff_ui["slotlist"][group_index][i]
                    if slot:IsVisible() == 1 then
                        local icon = slot:GetIcon()
                        if icon then
                            local info = icon:GetInfo()
                            displayed_buffs[info.type] = {
                                index = tostring(icon:GetUserIValue("BuffIndex"))
                            }
                        end
                    end
                end
            end
        end
        local player_buffs = {}
        for i = 0, buff_count - 1 do
            local buff = info.GetBuffIndexed(my_handle, i)
            if buff and BUFF_CHECK_SEPARATELIST(buff.buffID) ~= true then
                player_buffs[buff.buffID] = {
                    index = buff.index
                }
            end
        end
        for buff_id, data in pairs(displayed_buffs) do
            local str_buff_id = tostring(buff_id)
            if not player_buffs[buff_id] or g.my_buffs_control_settings.buffs[str_buff_id] == false then
                COMMON_BUFF_MSG(buff_frame, "REMOVE", buff_id, my_handle, s_buff_ui, data.index)
            end
        end
        for buff_id, data in pairs(player_buffs) do
            local str_buff_id = tostring(buff_id)
            if g.my_buffs_control_settings.buffs[str_buff_id] ~= false and not displayed_buffs[buff_id] then
                COMMON_BUFF_MSG(buff_frame, "ADD", buff_id, my_handle, s_buff_ui, data.index)
            end
        end
    end
end

function my_buffs_BUFF_ON_MSG(my_frame, my_msg)
    local frame, msg, str, num = g.get_event_args(my_msg)
    if g.settings.my_buffs_control.use == 0 then
        return
    end
    if g.get_map_type() == 'City' then
        return
    end
    local buff = ui.GetFrame("buff")
    local handle = session.GetMyHandle()
    local str_buff_id = tostring(num)
    if g.my_buffs_control_settings.buffs[str_buff_id] == false then
        if BUFF_CHECK_SEPARATELIST(num) == true then
            return
        end
        if type(_G["COMMON_BUFF_MSG_OLD"]) == "function" then
            COMMON_BUFF_MSG_OLD(frame, "REMOVE", num, handle, s_buff_ui, str)
        else
            COMMON_BUFF_MSG(frame, "REMOVE", num, handle, s_buff_ui, str)
        end
        MY_BUFF_TIME_UPDATE(buff)
        BUFF_RESIZE(buff, s_buff_ui)
        return
    end
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
    my_buffs_control_setting:SetLayerLevel(999)
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
function monster_card_changer_save_settings()
    g.save_json(g.monster_card_changer_path, g.monster_card_changer_settings)
end

function monster_card_changer_load_settings()
    g.monster_card_changer_path = string.format("../addons/%s/%s/monster_card_changer.json", addon_name_lower,
        g.active_id)
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
    g.market_voucher_path = string.format("../addons/%s/%s/market_voucher.json", addon_name_lower, g.active_id)
    g.market_voucher_old_path = string.format("../addons/%s/%s/settings_2507.json", "market_voucher", g.active_id)
    g.market_voucher_log_path = string.format("../addons/%s/%s/market_voucher_log.txt", addon_name_lower, g.active_id)
    g.market_voucher_old_log_path = string.format('../addons/%s/log_2507.txt', "market_voucher")
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
function lets_go_home_save_settings()
    g.save_json(g.lets_go_home_path, g.lets_go_home_settings)
end

function lets_go_home_load_settings()
    g.lets_go_home_path = string.format("../addons/%s/%s/lets_go_home.json", addon_name_lower, g.active_id)
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
        local _nexus_addons = ui.GetFrame("_nexus_addons")
        _nexus_addons:SetVisible(1)
        local lets_go_home_timer = GET_CHILD(_nexus_addons, "lets_go_home_timer")
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
    local _nexus_addons = ui.GetFrame("_nexus_addons")
    _nexus_addons:SetVisible(1)
    local lets_go_home_timer = _nexus_addons:CreateOrGetControl("timer", "lets_go_home_timer", 0, 0)
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
    local list_frame = ui.GetFrame(addon_name_lower .. "list_frame")
    local lets_go_home_setting = ui.CreateNewFrame("notice_on_pc", addon_name_lower .. "lets_go_home_setting", 0, 0, 0,
        0)
    lets_go_home_setting:Resize(370, 250)
    lets_go_home_setting:SetPos(list_frame:GetX() + list_frame:GetWidth(), list_frame:GetY())
    lets_go_home_setting:SetSkinName("test_frame_low")
    lets_go_home_setting:EnableHittestFrame(1)
    lets_go_home_setting:EnableHitTest(1)
    lets_go_home_setting:SetLayerLevel(999)
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
    local _nexus_addons = ui.GetFrame("_nexus_addons")
    g.lets_go_home_warp_state = 1
    lets_go_home_change_move(_nexus_addons)
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
    g.pick_item_tracker_path = string.format("../addons/%s/%s/pick_item_tracker.json", addon_name_lower, g.active_id)
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
function monster_kill_count_save_settings()
    g.save_json(g.monster_kill_count_path, g.monster_kill_count_settings)
end

function monster_kill_count_load_settings()
    g.monster_kill_count_path = string.format("../addons/%s/%s/monster_kill_count.json", addon_name_lower, g.active_id)
    g.monster_kill_count_old_path = string.format("../addons/%s/%s/settings.json", "klcount", g.active_id)
    local settings = g.load_json(g.monster_kill_count_path)
    if not settings then
        local old_settings = g.load_json(g.monster_kill_count_old_path)
        if old_settings then
            settings = {
                frame_x = old_settings.frame_x or 1340,
                frame_y = old_settings.frame_y or 20,
                map_ids = {}
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
                        if content and content ~= "" then
                            local success, _ = pcall(json.decode, content)
                            if success then
                                local new_file = io.open(new_file_path, "w")
                                if new_file then
                                    new_file:write(content)
                                    new_file:close()
                                    table.insert(settings.map_ids, map_id)
                                end
                            end
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
    local folder_path = string.format("../addons/%s/%s/%s", addon_name_lower, g.active_id, "monster_kill_count")
    local win_folder_path = string.gsub(folder_path, "/", "\\")
    local list_file_path = folder_path .. "/filelist_temp.txt"
    local win_list_file_path = string.gsub(list_file_path, "/", "\\")
    os.execute('dir "' .. win_folder_path .. '\\*.json" /b > "' .. win_list_file_path .. '"')
    local list_file = io.open(list_file_path, "r")
    if list_file then
        for line in list_file:lines() do
            local map_id = string.match(line, "(%d+)%.json")
            if map_id then
                local exists = false
                if settings.map_ids then
                    for _, existing_id in pairs(settings.map_ids) do
                        if tostring(existing_id) == map_id then
                            exists = true
                            break
                        end
                    end
                else
                    settings.map_ids = {}
                end
                if not exists then
                    table.insert(settings.map_ids, map_id)
                    ts("Found orphan file, adding to list: " .. map_id)
                end
            end
        end
        list_file:close()
        os.remove(list_file_path) -- 一時ファイルを削除
    end
    if settings.map_ids and #settings.map_ids > 0 then
        local valid_map_ids = {}
        for _, map_id in pairs(settings.map_ids) do
            if type(map_id) == "number" or type(map_id) == "string" then
                local file_path = folder_path .. "/" .. map_id .. ".json"
                local file = io.open(file_path, "r")
                local is_valid = false
                if file then
                    local content = file:read("*a")
                    file:close()
                    if content and content ~= "" then
                        local success, _ = pcall(json.decode, content)
                        if success then
                            is_valid = true
                        else
                            ts("Broken JSON detected: " .. tostring(map_id))
                            os.remove(file_path)
                        end
                    else
                        ts("Empty file detected: " .. tostring(map_id))
                        local ret, err = os.remove(file_path)
                        if not ret then
                            ts("Delete Failed: " .. tostring(err))
                        end
                    end
                end
                if is_valid then
                    table.insert(valid_map_ids, map_id)
                end
            end
        end
        settings.map_ids = valid_map_ids
    else
        settings.map_ids = {}
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
            if g.monster_kill_count_map_data.get_items then
                local new_items = {}
                for k, v in pairs(g.monster_kill_count_map_data.get_items) do
                    new_items[tostring(k)] = v
                end
                g.monster_kill_count_map_data.get_items = new_items
            end
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
        -- g.addon:RegisterMsg("GAMEEXIT_TIMER_END", "monster_kill_count_ON_GAMEEXIT_TIMER_END")
        g.setup_hook_and_event(g.addon, "APPS_TRY_LEAVE", "monster_kill_count_APPS_TRY_LEAVE", true)
        g.addon:RegisterMsg("EXP_UPDATE", "monster_kill_count_EXP_UPDATE")
        g.addon:RegisterMsg('ITEM_PICK', 'monster_kill_count_ITEM_PICK')
        g.monster_kill_count_autosave_counter = 0
        local _nexus_addons = ui.GetFrame("_nexus_addons")
        if not g.monster_kill_count_map_id or g.monster_kill_count_map_id ~= g.map_id then
            g.monster_kill_count_map_id = g.map_id
            g.monster_kill_count_start_time = imcTime.GetAppTimeMS() - 3000
            _nexus_addons:SetUserValue("MKC_COUNT", 0)
            g.monster_kill_count_diff_ms = 0
        end
        local map_file_path = monster_kill_count_get_map_filepath(g.map_id)
        local map_data = g.load_json(map_file_path)
        if not map_data then
            local f = io.open(map_file_path, "r")
            if f then
                f:close()
                os.remove(map_file_path)
                ts("Removed corrupted/empty map file: " .. map_file_path)
            end
            map_data = {
                map_name = g.map_name,
                stay_time = 3000,
                kill_count = 0,
                get_items = {}
            }
            g.save_json(map_file_path, map_data)
        end
        if map_data.get_items then
            local new_items = {}
            for k, v in pairs(map_data.get_items) do
                new_items[tostring(k)] = v
            end
            map_data.get_items = new_items
        end
        if not g.monster_kill_count_settings then
            monster_kill_count_load_settings()
        end
        local is_exist = false
        for _, id in pairs(g.monster_kill_count_settings.map_ids) do
            if tostring(id) == tostring(g.map_id) then
                is_exist = true
                break
            end
        end
        if not is_exist then
            table.insert(g.monster_kill_count_settings.map_ids, g.map_id)
            monster_kill_count_save_settings()
            ts("Added missing map ID to settings: " .. tostring(g.map_id))
        end
        g.monster_kill_count_map_data = map_data
        if is_change then
            monster_kill_count_frame_init()
        else
            local monster_kill_count_timer = _nexus_addons:CreateOrGetControl("timer", "monster_kill_count_timer", 0, 0)
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

function monster_kill_count_APPS_TRY_LEAVE(my_frame, my_msg)
    local type = g.get_event_args(my_msg)
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

--[[function monster_kill_count_ON_GAMEEXIT_TIMER_END(frame)
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
end]]

function monster_kill_count_ON_CHALLENGE_MODE_TOTAL_KILL_COUNT(frame, msg, str, arg)
    g.monster_kill_count_challenge_mode = true
end

function monster_kill_count_frame_init(_nexus_addons, monster_kill_count_timer)
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

function monster_kill_count_EXP_UPDATE(_nexus_addons, msg)
    local count = _nexus_addons:GetUserValue("MKC_COUNT")
    local monster_kill_count = ui.GetFrame(addon_name_lower .. "monster_kill_count")
    local count_text = GET_CHILD(monster_kill_count, "count_text")
    if count_text then
        AUTO_CAST(count_text)
        count_text:SetText(string.format("{ol}{s16}Count : %d{/}", count + 1))
    end
    _nexus_addons:SetUserValue("MKC_COUNT", count + 1)
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
function easy_buff_save_settings()
    g.save_json(g.easy_buff_path, g.easy_buff_settings)
end

function easy_buff_load_settings()
    g.easy_buff_path = string.format("../addons/%s/%s/easy_buff.json", addon_name_lower, g.active_id)
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
    easy_buff:SetLayerLevel(999)
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

g.characters_item_serch = g.characters_item_serch or {}
function characters_item_serch_save_settings()
    g.save_json(g.characters_item_serch_path, g.characters_item_serch_settings)
end

function characters_item_serch_load_settings()
    g.characters_item_serch_path = string.format("../addons/%s/%s/characters_item_serch.json", addon_name_lower,
        g.active_id)
    g.characters_item_serch_dat_tbl = {string.format("../addons/%s/%s/characters_item_serch_warehouse.dat",
        addon_name_lower, g.active_id),
                                       string.format("../addons/%s/%s/characters_item_serch_inventory.dat",
        addon_name_lower, g.active_id),
                                       string.format("../addons/%s/%s/characters_item_serch_equips.dat",
        addon_name_lower, g.active_id),
                                       string.format("../addons/%s/%s/characters_item_serch_accountwarehouse.dat",
        addon_name_lower, g.active_id)}
    g.characters_item_serch_old_dat_tbl = {string.format("../addons/%s/%s/warehouse.dat", "characters_item_serch",
        g.active_id), string.format("../addons/%s/%s/inventory.dat", "characters_item_serch", g.active_id),
                                           string.format("../addons/%s/%s/equips.dat", "characters_item_serch",
        g.active_id)}

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
    -- g.addon:RegisterMsg("GAMEEXIT_TIMER_END", "characters_item_serch_ON_GAMEEXIT_TIMER_END")
    g.setup_hook_and_event(g.addon, "APPS_TRY_LEAVE", "characters_item_serch_APPS_TRY_LEAVE", true)
    g.setup_hook_and_event(g.addon, "INVENTORY_CLOSE", "characters_item_serch_INVENTORY_CLOSE", true)
    g.setup_hook_and_event(g.addon, "ACCOUNTWAREHOUSE_CLOSE", "characters_item_serch_ACCOUNTWAREHOUSE_CLOSE", true)
    g.setup_hook_and_event(g.addon, "'WAREHOUSE_CLOSE", "characters_item_serch_WAREHOUSE_CLOSE", true)
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
    elseif characters_item_serch and characters_item_serch:IsVisible() == 0 then
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

function characters_item_serch_APPS_TRY_LEAVE(my_frame, my_msg)
    local type = g.get_event_args(my_msg)
    if type == "Exit" or type == "Logout" or type == "Barrack" then
        characters_item_serch_inventory_save_list()
    end
end

--[[function characters_item_serch_ON_GAMEEXIT_TIMER_END()
    local gameexitpopup = ui.GetFrame("gameexitpopup")
    local type = gameexitpopup:GetUserValue("EXIT_TYPE")
    if type == "Exit" or type == "Logout" or type == "Barrack" then
        characters_item_serch_inventory_save_list()
    end
end]]

function characters_item_serch_INVENTORY_CLOSE()
    characters_item_serch_inventory_save_list()
end

function characters_item_serch_ACCOUNTWAREHOUSE_CLOSE()
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

function characters_item_serch_WAREHOUSE_CLOSE()
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
    local list_frame = ui.GetFrame(addon_name_lower .. "list_frame")
    if not list_frame then
        list_frame = _nexus_addons_frame_init()
        list_frame:ShowWindow(0)
    end
    local characters_item_serch = ui.CreateNewFrame("notice_on_pc", addon_name_lower .. "characters_item_serch", 0, 0,
        70, 30)
    AUTO_CAST(characters_item_serch)
    characters_item_serch:SetSkinName("test_frame_low")
    characters_item_serch:Resize(670, 1080)
    characters_item_serch:SetPos(list_frame:GetX() + list_frame:GetWidth(), 0)
    characters_item_serch:EnableMove(0)
    characters_item_serch:SetLayerLevel(999)
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
    local _nexus_addons = ui.GetFrame("_nexus_addons")
    if _nexus_addons then
        _nexus_addons:SetVisible(1)
        local party_marker_timer = _nexus_addons:CreateOrGetControl("timer", "party_marker_timer", 0, 0)
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

function party_marker_set(_nexus_addons, party_marker_timer)
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
function aethergem_manager_save_settings()
    g.save_json(g.aethergem_manager_path, g.aethergem_manager.settings)
end

function aethergem_manager_load_settings()
    g.aethergem_manager_path = string.format("../addons/%s/%s/aethergem_manager.json", addon_name_lower, g.active_id)
    g.aethergem_manager_old_path = string.format("../addons/%s/%s.json", "aethergem_mgr", g.active_id)
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
g.instant_cc = {
    retry = nil,
    do_cc = nil,
    layer = 1
}
function instant_cc_save_settings()
    g.save_json(g.instant_cc_path, g.instant_cc_settings)
end

function instant_cc_load_settings()
    g.instant_cc_path = string.format("../addons/%s/%s/instant_cc.json", addon_name_lower, g.active_id)
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
    if g.settings.instant_cc.use == 0 then
        return
    end
    local acc_info = session.barrack.GetMyAccount()
    local barrack_count = acc_info:GetBarrackPCCount() -- ゲーム起動直後はtonumber(0)
    instant_cc_save_char_data(acc_info, barrack_count)
end

function instant_cc_settings_frame_init()
    local list_frame = ui.GetFrame(addon_name_lower .. "list_frame")
    local settings = ui.CreateNewFrame("chat_memberlist", addon_name_lower .. "instant_cc_settings")
    AUTO_CAST(settings)
    settings:SetPos(list_frame:GetX() + list_frame:GetWidth(), list_frame:GetY())
    settings:EnableHitTest(1)
    settings:SetLayerLevel(999)
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
    local frame_name = addon_name_lower .. "instant_cc_settings"
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

function instant_cc_APPS_TRY_MOVE_BARRACK()
    if g.settings and g.settings.instant_cc and g.settings.instant_cc.use == 0 then
        APPS_TRY_LEAVE("Barrack")
        return
    end
    instant_cc_APPS_TRY_MOVE_BARRACK_(nil, nil, nil, 0)
end

function instant_cc_APPS_TRY_MOVE_BARRACK_(frame, msg, str, barrack_layer)
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
    APPS_TRY_LEAVE("Barrack")
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

function guild_event_warp_save_settings()
    g.save_json(g.guild_event_warp_path, g.guild_event_warp_settings)
end

function guild_event_warp_load_settings()
    g.guild_event_warp_path = string.format("../addons/%s/%s/guild_event_warp.json", addon_name_lower, g.active_id)
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
        local _nexus_addons = ui.GetFrame("_nexus_addons")
        if _nexus_addons then
            _nexus_addons:SetVisible(1)
            local dungeon_rp_charger_timer = _nexus_addons:CreateOrGetControl("timer", "dungeon_rp_charger_timer", 0, 0)
            AUTO_CAST(dungeon_rp_charger_timer)
            dungeon_rp_charger_timer:SetUpdateScript("dungeon_rp_charger_auto_charge")
            dungeon_rp_charger_timer:Start(1.0)
        end
    end
end

function dungeon_rp_charger_auto_charge(_nexus_addons, dungeon_rp_charger_timer)
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
function cupole_manager_save_settings()
    g.save_json(g.cupole_manager_path, g.cupole_manager_settings)
end

function cupole_manager_load_settings()
    g.cupole_manager_path = string.format("../addons/%s/%s/cupole_manager.json", addon_name_lower, g.active_id)
    g.cupole_manager_old_path = string.format("../addons/%s/%s/settings.json", "cupole_manager", g.active_id)
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

function cupole_manager_on_init()
    if not g.cupole_manager_settings then
        cupole_manager_load_settings()
    end
    if g.get_map_type() == "City" then
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
    local _nexus_addons = ui.GetFrame("_nexus_addons")
    if _nexus_addons then
        _nexus_addons:SetVisible(1)
        local cupole_manager_timer = _nexus_addons:CreateOrGetControl("timer", "cupole_manager_timer", 0, 0)
        AUTO_CAST(cupole_manager_timer)
        cupole_manager_timer:SetUpdateScript("cupole_manager_summon_cupole")
        cupole_manager_timer:Start(1.0)
        g.cupole_manager_num = 0
    end
end

function cupole_manager_summon_cupole(_nexus_addons, cupole_manager_timer)
    if g.cupole_manager_num == 3 then
        return
    end
    SummonCupole(tonumber(g.cupole_manager_tbl[tostring(g.cupole_manager_num + 1)].id), g.cupole_manager_num)
    g.cupole_manager_num = g.cupole_manager_num + 1
    return
end
-- Cupole Manager ここまで

-- Boss Direction ここから

function boss_direction_save_settings()
    g.save_json(g.boss_direction_path, g.boss_direction_settings)
end

function boss_direction_load_settings()
    g.boss_direction_path = string.format("../addons/%s/%s/boss_direction.json", addon_name_lower, g.active_id)
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
    boss_direction_settings:SetPos(list_frame:GetX() + list_frame:GetWidth(), list_frame:GetY())
    boss_direction_settings:EnableHitTest(1)
    boss_direction_settings:SetLayerLevel(999)
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
    local _nexus_addons = ui.GetFrame("_nexus_addons")
    if _nexus_addons then
        _nexus_addons:SetVisible(1)
        local boss_direction_timer = _nexus_addons:CreateOrGetControl("timer", "boss_direction_timer", 0, 0)
        AUTO_CAST(boss_direction_timer)
        boss_direction_timer:SetUpdateScript("boss_direction_handle_check")
        boss_direction_timer:Start(0.5)
    end
end

function boss_direction_handle_check(_nexus_addons, boss_direction_timer)
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
g.auto_repair = {
    item_cls_id = 11202000,
    repair_item = "AustejaCertificate_14",
    shop_type = "AustejaCertificate"
}
function auto_repair_save_settings()
    g.save_json(g.auto_repair_path, g.auto_repair_settings)
end

function auto_repair_load_settings()
    g.auto_repair_path = string.format("../addons/%s/%s/auto_repair.json", addon_name_lower, g.active_id)
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
    local list_frame = ui.GetFrame(addon_name_lower .. "list_frame")
    local auto_repair_settings = ui.CreateNewFrame("chat_memberlist", addon_name_lower .. "auto_repair_settings")
    AUTO_CAST(auto_repair_settings)
    auto_repair_settings:SetPos(list_frame:GetX() + list_frame:GetWidth(), list_frame:GetY())
    auto_repair_settings:EnableHitTest(1)
    auto_repair_settings:SetSkinName("test_frame_low")
    auto_repair_settings:SetEventScript(ui.LBUTTONUP, "auto_repair_end_drag")
    auto_repair_settings:SetLayerLevel(999)
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
        local _nexus_addons = ui.GetFrame("_nexus_addons")
        if _nexus_addons then
            _nexus_addons:SetVisible(1)
            local acquire_relic_reward_timer = _nexus_addons:CreateOrGetControl("timer", "acquire_relic_reward_timer",
                0, 0)
            AUTO_CAST(acquire_relic_reward_timer)
            acquire_relic_reward_timer:SetUpdateScript("acquire_relic_reward_process")
            acquire_relic_reward_timer:Start(1.0)
        end
    end
end

function acquire_relic_reward_process(_nexus_addons, acquire_relic_reward_timer)
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
function auto_pet_summon_save_settings()
    g.save_json(g.auto_pet_summon_path, g.auto_pet_summon_settings)
end

function auto_pet_summon_load_settings()
    g.auto_pet_summon_path = string.format("../addons/%s/%s/auto_pet_summon.json", addon_name_lower, g.active_id)
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
    local _nexus_addons = ui.GetFrame("_nexus_addons")
    if _nexus_addons then
        _nexus_addons:SetVisible(1)
        local auto_pet_summon_timer = _nexus_addons:CreateOrGetControl("timer", "auto_pet_summon_timer", 0, 0)
        AUTO_CAST(auto_pet_summon_timer)
        auto_pet_summon_timer:SetUpdateScript("auto_pet_summon_save_reserve")
        auto_pet_summon_timer:Start(1.0)
    end
end

function auto_pet_summon_save_reserve(_nexus_addons, auto_pet_summon_timer)
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
function ancient_auto_set_save_settings()
    g.save_json(g.ancient_auto_set_path, g.ancient_auto_set_settings)
end

function ancient_auto_set_load_settings()
    g.ancient_auto_set_path = string.format("../addons/%s/%s/ancient_auto_set.json", addon_name_lower, g.active_id)
    local settings = g.load_json(g.ancient_auto_set_path)
    local changed = false
    if not settings then
        settings = {
            priset = {}
        }
        changed = true
    end
    if not settings[g.cid] then
        settings[g.cid] = {}
    end
    g.ancient_auto_set_settings = settings
    if changed then
        ancient_auto_set_save_settings()
    end
end

function ancient_auto_set_on_init()
    if not g.ancient_auto_set_settings then
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
    if g.ancient_auto_set_settings.priset and g.ancient_auto_set_settings.priset[tostring(tab_index)] then
        local current_set_name = g.ancient_auto_set_settings.priset[tostring(tab_index)].name
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
        if g.ancient_auto_set_settings and g.ancient_auto_set_settings.priset and
            g.ancient_auto_set_settings.priset[tostring(tab_index)] then
            local preset_data = g.ancient_auto_set_settings.priset[tostring(tab_index)]
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
    if not g.ancient_auto_set_settings.priset[tostring(tab_index)] then
        return
    end
    priset_frame:SetUserValue("TAB_INDEX", tab_index)
    priset_frame:SetUserValue("SLOT_INDEX", 0)
    priset_frame:RunUpdateScript("ancient_auto_set_put_card_slot", 0.3)
end

function ancient_auto_set_put_card_slot(priset_frame)
    local tab_index = priset_frame:GetUserIValue("TAB_INDEX")
    local slot_index = priset_frame:GetUserIValue("SLOT_INDEX")
    local target_guid = g.ancient_auto_set_settings.priset[tostring(tab_index)][tostring(slot_index)]
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
    if not g.ancient_auto_set_settings.priset then
        g.ancient_auto_set_settings.priset = {}
    end
    g.ancient_auto_set_settings.priset[tostring(tab_index)].name = set_name
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
    if not g.ancient_auto_set_settings.priset then
        g.ancient_auto_set_settings.priset = {}
    end
    if not g.ancient_auto_set_settings.priset[tostring(tab_index)] then
        g.ancient_auto_set_settings.priset[tostring(tab_index)] = {}
    end
    local lifted_guid = ancient_card_list:GetUserValue("LIFTED_GUID")
    g.ancient_auto_set_settings.priset[tostring(tab_index)][tostring(to_index)] = lifted_guid
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
    if not (g.ancient_auto_set_settings.priset and g.ancient_auto_set_settings.priset[tostring(tab_index)]) then
        return
    end
    g.ancient_auto_set_settings.priset[tostring(tab_index)][tostring(to_index)] = "None"
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
    if not g.ancient_auto_set_settings[g.cid] then
        g.ancient_auto_set_settings[g.cid] = {}
        ancient_auto_set_save_settings()
    end
    g.ancient_auto_set_settings[g.cid].guids = {}
    local msg = g.lang == "Japanese" and "[AAS]登録解除しました" or "[AAS]Setting released"
    ui.SysMsg(msg)
    ancient_auto_set_save_settings()
end

function ancient_auto_set_reg(frame, ctrl)
    local ancient_card_list = ui.GetFrame("ancient_card_list")
    local tab = ancient_card_list:GetChild("tab")
    AUTO_CAST(tab)
    tab:SelectTab(0)
    g.ancient_auto_set_settings[g.cid] = {
        name = g.login_name,
        guids = {}
    }
    for index = 0, 3 do
        local card = session.ancient.GetAncientCardBySlot(index)
        if card then
            local guid = card:GetGuid()
            table.insert(g.ancient_auto_set_settings[g.cid].guids, {guid, card:GetClassName()})
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
    if not (g.ancient_auto_set_settings[g.cid] and g.ancient_auto_set_settings[g.cid].guids and
        next(g.ancient_auto_set_settings[g.cid].guids)) then
        local text = g.lang == "Japanese" and "{ol}[AAS]{#FFFFFF} " .. g.login_name .. " {/}アシスター未登録" or
                         "{ol}[APS]{#FFFFFF} " .. g.login_name .. " {/}is not registered assister"
        ui.SysMsg(text)
        return
    end
    local _nexus_addons = ui.GetFrame("_nexus_addons")
    local ancient_auto_set_timer = _nexus_addons:CreateOrGetControl("timer", "ancient_auto_set_timer", 0, 0)
    AUTO_CAST(ancient_auto_set_timer)
    ancient_auto_set_timer:Stop()
    local needs_change = false
    for i, row_data in ipairs(g.ancient_auto_set_settings[g.cid].guids) do
        local save_guid = row_data[1]
        local card = session.ancient.GetAncientCardBySlot(i - 1)
        local current_guid = card and card:GetGuid() or nil
        if save_guid ~= current_guid then
            needs_change = true
            break
        end
    end
    if needs_change then
        _nexus_addons:SetUserValue("ANCIENT_INDEX", 0)
        ancient_auto_set_timer:SetUpdateScript("ancient_auto_set_change_set")
        ancient_auto_set_timer:Start(0.3)
    end
end

function ancient_auto_set_change_set(_nexus_addons, ancient_auto_set_timer)
    local index = _nexus_addons:GetUserIValue("ANCIENT_INDEX")
    if index <= 3 then
        local card_guid = g.ancient_auto_set_settings[g.cid].guids[index + 1][1]
        if card_guid then
            local card = session.ancient.GetAncientCardBySlot(index)
            local current_guid = card and card:GetGuid() or nil
            if card_guid ~= current_guid then
                ReqSwapAncientCard(card_guid, index)
            end
        end
        _nexus_addons:SetUserValue("ANCIENT_INDEX", index + 1)
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
