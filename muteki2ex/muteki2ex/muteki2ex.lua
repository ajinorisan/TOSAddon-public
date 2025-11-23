-- v2.0.1 アイコンモード追加。
-- v2.0.2 オバロ火の権能対応したか？
-- v2.0.3 ゲージの色設定やりやすくなったけどアイコンモードで使うという自己矛盾
-- v2.0.4 アイコン回転モード追加
-- v2.0.5 with effect機能復活
-- v2.0.6 PTチャットでDICデータバグってたの修正
-- v2.0.7 ニコチャット機能追加。PTチャットうるさいので出来ればアプデして欲しい
-- v3.0.0 作り直した
-- v3.0.0.9 読込遅い問題修正、クラッシュする要因かも知れない部分修正
-- v3.0.1 公開
-- v3.0.2 設定フレームが開かなかったバグ修正
local addon_name = "muteki2ex"
local addon_name_lower = string.lower(addon_name)
local org_ver = "1.2.7"
local ver = "3.0.2"

local author = "WRIT"
local maintainer = "norisan"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addon_name_lower] = _G["ADDONS"][author][addon_name_lower] or {}
local g = _G["ADDONS"][author][addon_name_lower]

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
end
g.mkdir_new_folder()

-- 設定ファイル保存先
g.settings_old_path = string.format("../addons/%s/settings.json", addon_name_lower)
g.settings_path = string.format("../addons/%s/settings_2510.json", addon_name_lower)

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
        if bool == true and original_results ~= nil then
            return table.unpack(original_results)
        else
            return
        end
    end
    _G[origin_func_name] = hooked_function
    if not g.REGISTER[origin_func_name] then -- g.RAGISTERはON_INIT内で都度初期化
        g.REGISTER[origin_func_name] = true
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
    if file then
        local content = file:read("*all")
        file:close()
        local table = json.decode(content)
        return table
    else
        return nil
    end
end

function g.save_json(path, tbl)

    local file = io.open(path, "w")
    local str = json.encode(tbl)
    file:write(str)
    file:close()
end

function g.debug_print_table(tbl, indent)

    if not next(tbl) then
        print("中身ない")
        return
    end

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

function muteki2ex_save_settings()
    g.save_json(g.settings_path, g.settings)
end

function muteki2ex_load_settings()

    local DEFAULTS = {
        settings = {
            mode = "fixed",
            layer_lv = 80,
            hide_time = 300,
            rotate = 0,
            pos = {
                lock = false,
                y = 640,
                x = 480
            },
            buff_list = {}
        },
        buff_data = {
            color = "FFCCCC22",
            pt_chat = false,
            circle_icon = false,
            nico_chat = 0,
            not_notify = {},
            effect_check = 0,
            count_display = false,
            end_sound = 0,
            debuff_manage = {},
            buff_manage = {}
        }
    }

    local unwanted_keys = {
        ["version"] = true,
        ["enable"] = true,
        ["isNoTimeBuff"] = true,
        ["isNotNotify"] = true
    }

    local rename_keys_map = {
        ["circleIcon"] = "circle_icon",
        ["layerLvl"] = "layer_lv",
        ["rotate_check"] = "rotate",
        ["hiddenBuffTime"] = "hide_time",
        ["position"] = "pos",
        ["buffList"] = "buff_list",
        ["isEffect"] = "pt_chat"
    }

    local function convert_old_settings(old_tbl)
        local new_tbl = {}
        for old_key, old_value in pairs(old_tbl) do
            if unwanted_keys[old_key] then
            elseif rename_keys_map[old_key] then
                local new_key = rename_keys_map[old_key]
                if type(old_value) == "table" then
                    new_tbl[new_key] = convert_old_settings(old_value)
                else
                    new_tbl[new_key] = old_value
                end
            else
                if type(old_value) == "table" then
                    new_tbl[old_key] = convert_old_settings(old_value)
                else
                    new_tbl[old_key] = old_value
                end
            end
        end

        return new_tbl
    end

    local settings = g.load_json(g.settings_path)
    local old_settings = g.load_json(g.settings_old_path)
    local changed = false

    if not settings then
        if old_settings then
            settings = convert_old_settings(old_settings)
            changed = true
        else
            settings = DEFAULTS.settings
            changed = true
        end
    end

    for key, default_value in pairs(DEFAULTS.settings) do
        if settings[key] == nil then
            settings[key] = default_value
            changed = true
        end
    end

    if settings.buff_list and type(settings.buff_list) == "table" then
        for buff_id, buff_data in pairs(settings.buff_list) do
            for key, default_value in pairs(DEFAULTS.buff_data) do
                if buff_data[key] == nil then
                    buff_data[key] = (type(default_value) == "table") and {} or default_value
                    changed = true
                end
            end
            if buff_data.debuff_manage and type(buff_data.debuff_manage) == "table" then
                if not buff_data.debuff_manage[g.cid] then
                    buff_data.debuff_manage[g.cid] = {}
                    changed = true
                end
            end
            if buff_data.buff_manage and type(buff_data.buff_manage) == "table" then
                if not buff_data.buff_manage[g.cid] then
                    buff_data.buff_manage[g.cid] = {}
                    changed = true
                end
            end
        end
    end

    g.settings = settings
    if changed then
        muteki2ex_save_settings()
    end
end

g.trans_tbl = {
    etc = {
        buff_time = '{#000000}Hide until Buff duration (sec){/}',
        position_mode = '{#000000}Toggle Mode{/}',
        mode_desc = "{ol}ON: Follow Mode{nl}OFF: Fixed Mode",
        frame_lock = '{#000000}Frame Lock{/}',
        layer_lv = '{#000000}Layer Level{/}',
        layer_notice = 'MUTEKI Changed frame layer to %d',
        icon_mode = '{#000000}Display in icon mode{/}',
        color_tone = '{#FFFFFF}{ol}Current Color{/}',
        hide_sec = 'MUTEKI Hide gauge with remaining time more than %d seconds',
        not_notify = "{#000000}Hidden for this character{/}",
        pt_chat = "{#000000}Notify buffs via PT chat{/}",
        function_notice = "{#FFFFFF}{ol}Register by leftclick on the buff slot{nl}in the upper left corner of the screen{/}",
        icon_rotate = "{#000000}Rotate icon{/}",
        with_effect = "{#000000}With effect{/}",
        nico_chat = "{#000000}Nico Chat Display{/}",
        delete_notice = "{#FFFFFF}{ol}Right-click the icon to unregister{/}",
        color_notice = "{#FFFFFF}{ol}The first two characters are for shade/density (AA = Light - FF = Dark)" ..
            "{nl}The following six characters are the hexadecimal color code.{/}",
        count_display = "{#000000}Display Buff Stacks{/}",
        end_sound = "{#000000}Buff End Sound{/}",
        add_check = 'Add %s to MUTEKI?',
        add_buff = 'MUTEKI Added %s in settings',
        delete_buff = 'MUTEKI Removed %s in settings',
        add_new = '{#FFFFFF}{ol}Add Buff',
        add_buffid = "{#FFFFFF}{ol}Add by Buff ID{/}",
        lock_notice = "{#FFFFFF}{ol}Follow Mode is always locked",
        debuff_time = "{#000000}Manual DeBuff Duration",
        debuff_notice = "{#FFFFFF}{ol}Adjustment is required{nl}based on each character's skill level",
        debuff_manage_set = "{#FFFFFF}{ol}Set duration to %s seconds",
        auto_time = "{#FFFFFF}{ol}Turning ON automatically retrieves the debuff duration{nl}Note: This may not work correctly with some debuffs{nl}In that case, please turn it OFF and enter the value manually",
        buff_time_cid = "{#000000}Manual Buff Duration",
        buff_notice_cid = "{#FFFFFF}{ol}Manually input the duration for some buffs, such as magic circles{nl}whose time cannot be automatically retrieved{nl}Note: Values may vary depending on skill level and other factors",
        skill_text = "{#000000}Skill ID",
        skill_notice = "{#FFFFFF}{ol}If the duration is entered{nl}linking a buff to a skill enables time measurement",
        skill_set = "{#FFFFFF}{ol}Linked to %s skill",
        add_new_skill = '{#FFFFFF}{ol}Add Skill'
    },
    Japanese = {
        buff_time = '{#000000}指定されたバフの残り時間まで非表示(秒){/}',
        position_mode = '{#000000}モード切替{/}',
        mode_desc = "{ol}ON: 追従モード{nl}OFF: 固定モード",
        frame_lock = '{#000000}フレームロック{/}',
        layer_lv = '{#000000}レイヤーレベル{/}',
        layer_notice = 'MUTEKI フレームレイヤーを %d に変更しました',
        icon_mode = '{#000000}アイコンモードで表示{/}',
        color_tone = '{#FFFFFF}{ol}現在の色{/}',
        hide_sec = 'MUTEKI %d 秒以上のバフは非表示になります',
        not_notify = "{#000000}このキャラクターでは非表示{/}",
        pt_chat = "{#000000}バフをPTチャットでお知らせ{/}",
        function_notice = "{#FFFFFF}{ol}画面左上バフスロットを{nl}左クリックでも登録出来ます{/}",
        icon_rotate = "{#000000}アイコン回転{/}",
        with_effect = "{#000000}エフェクト付与{/}",
        nico_chat = "{#000000}ニコチャット表示{/}",
        delete_notice = "{#FFFFFF}{ol}アイコン右クリックで登録解除します{/}",
        color_notice = "{#FFFFFF}{ol}先頭2文字は濃淡 (AA=薄い～FF=濃い)" ..
            "{nl}続く6文字は16進数のカラーコード{/}",
        count_display = "{#000000}バフ重複を表示{/}",
        end_sound = "{#000000}バフ終了時に音でお知らせ{/}",
        add_check = 'MUTEKIに%sを追加しますか？',
        add_buff = 'MUTEKIに%sを追加しました.',
        delete_buff = "MUTEKIから %s を削除しました.",
        add_new = '{#FFFFFF}{ol}バフ追加',
        add_buffid = "{#FFFFFF}{ol}バフIDで直接追加{/}",
        lock_notice = "{#FFFFFF}{ol}追従モードでは常にロックされます",
        debuff_time = "{#000000}デバフ継続時間を入力",
        debuff_notice = "{#FFFFFF}{ol}キャラクター毎のスキルレベルなどで調整必要です",
        debuff_manage_set = "{#FFFFFF}{ol}継続時間を %s 秒で設定しました",
        auto_time = "{#FFFFFF}{ol}ONにするとデバフ継続時間を自動取得します{nl}一部のデバフでは機能しない場合があります{nl}その際はOFFにして手動で入力してください",
        buff_time_cid = "{#000000}バフ継続時間を手動入力",
        buff_notice_cid = "{#FFFFFF}{ol}魔法陣など一部の時間取得出来ないバフの継続時間を手動入力します{nl}値はスキルレベルなどで異なる場合があります",
        skill_text = "{#000000}スキルID",
        skill_notice = "{#FFFFFF}{ol}継続時間を入力した場合{nl}バフとスキルを紐づけることで時間計測が可能になります",
        skill_set = "{#FFFFFF}{ol}%s スキルと紐づけました",
        add_new_skill = '{#FFFFFF}{ol}スキル追加'
    },
    kr = {
        buff_time = "{#000000}지정된 버프 잔여 시간까지 숨기기 (초){/}",
        position_mode = "{#000000}모드 전환{/}",
        mode_desc = "{ol}ON: 추종 모드{nl}OFF: 고정 모드",
        frame_lock = "{#000000}프레임 잠금{/}",
        layer_lv = "{#000000}레이어 레벨{/}",
        layer_notice = 'MUTEKI 프레임 레이어를 %d 로 변경했습니다',
        icon_mode = "{#000000}아이콘 모드로 표시{/}",
        color_tone = "{#FFFFFF}{ol}현재 색상{/}",
        hide_sec = "MUTEKI - %d초 이상 남은 버프는 표시하지 않습니다.",
        not_notify = "{#000000}이 캐릭터에서는 숨김{/}",
        pt_chat = "{#000000}PT 채팅으로 버프를 알려드립니다{/}",
        function_notice = "{#FFFFFF}{ol}화면 왼쪽 상단의 버프 슬롯을{nl}왼쪽 클릭으로도 등록할 수 있습니다{/}",
        icon_rotate = "{#000000}아이콘 회전{/}",
        with_effect = "{#000000}효과 적용{/}",
        nico_chat = "{#000000}니코 채팅 표시{/}",
        delete_notice = "{#FFFFFF}{ol}아이콘을 마우스 오른쪽 버튼으로 클릭하여 등록 해제{/}",
        color_notice = "{#FFFFFF}{ol}앞의 두 문자는 농도를 나타냅니다 (AA = 옅음 - FF = 진함)" ..
            "{nl}이어지는 6개의 문자는 16진수 컬러 코드입니다{/}",
        count_display = "{#000000}버프 중첩 표시{/}",
        end_sound = "{#000000}버프 종료 시 소리로 알림{/}",
        add_check = 'MUTEKI - 에 %s를 추가하시겠습니까?',
        add_buff = "MUTEKI - %s 버프를 추가했습니다",
        delete_buff = "MUTEKI - %s 버프를 삭제했습니다",
        add_new = '{#FFFFFF}{ol}버프 추가',
        add_buffid = "{#FFFFFF}{ol}버프ID로 직접 추가{/}",
        lock_notice = "{#FFFFFF}{ol}추종 모드에서는 항상 잠금됩니다",
        debuff_time = "{#000000}디버프 지속 시간 입력",
        debuff_notice = "{#FFFFFF}{ol}캐릭터별 스킬 레벨에 따라 조정이 필요합니다",
        debuff_manage_set = "{#FFFFFF}{ol}지속 시간을 %s 초로 설정했습니다",
        auto_time = "{#FFFFFF}{ol}ON으로 설정 시 디버프 지속 시간을 자동으로 가져옵니다{nl}주의: 일부 디버프에서는 제대로 작동하지 않을 수 있습니다{nl}그럴 경우, 해당 기능을 OFF로 끄고 수동으로 입력해 주십시오",
        buff_time_cid = "{#000000}버프 지속 시간 수동 입력",
        buff_notice_cid = "{#FFFFFF}{ol}마법진 등 일부 시간 획득이 불가능한 버프의 지속 시간을 수동으로 입력합니다{nl}참고: 값은 스킬 레벨 등에 따라 달라질 수 있습니다",
        skill_text = "{#000000}스킬 ID",
        skill_notice = "{#FFFFFF}{ol}지속 시간을 입력한 경우{nl}버프와 스킬을 연동하면 시간 측정이 가능해집니다",
        skill_set = "{#FFFFFF}{ol}%s 스킬과 연동했습니다",
        add_new_skill = '{#FFFFFF}{ol}스킬 추가'
    }
}
local function trans(text)
    local trans_text = g.trans_tbl["etc"][text]
    if g.lang == "Japanese" or g.lang == "kr" then
        trans_text = g.trans_tbl[g.lang][text]
    end
    return trans_text
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

function MUTEKI2EX_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame
    g.REGISTER = {}
    g.lang = option.GetCurrentCountry()
    g.default_color = "FFCCCC22"
    g.buffs = {}
    g.time_buffs = {}
    addon:RegisterMsg("GAME_START", "muteki2ex_GAME_START")
    addon:RegisterMsg("GAME_START_3SEC", "muteki2ex_GAME_START_3SEC")
end

function muteki2ex_GAME_START(frame, msg, str, num)

    g.cid = info.GetCID(session.GetMyHandle())
    g.login_name = session.GetMySession():GetPCApc():GetName()
    g.highlander = false
    local map_name = session.GetMapName()
    if map_name == "c_highlander" then
        g.highlander = true
    end
    if not g.settings then
        muteki2ex_load_settings()
    end
    muteki2ex_buff_frame_init()

    _G["norisan"] = _G["norisan"] or {}
    _G["norisan"]["MENU"] = _G["norisan"]["MENU"] or {}
    local menu_data = {
        name = "Muteki",
        icon = "sysmenu_skill",
        func = "muteki2ex_setting_frame_init",
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

    g.addon:RegisterMsg("BUFF_ADD", "muteki2ex_BUFF_ON_MSG")
    g.addon:RegisterMsg("BUFF_UPDATE", "muteki2ex_BUFF_ON_MSG")
    g.addon:RegisterMsg("BUFF_REMOVE", "muteki2ex_BUFF_ON_MSG")
    g.addon:RegisterMsg("FPS_UPDATE", "muteki2ex_FPS_UPDATE")

    -- オバロ
    if g.overload and g.overload.cid == g.cid then
        g.overload.is_cool = 0
        muteki2ex_BUFF_ON_MSG(nil, "BUFF_REMOVE_START", "", g.overload.buff_id)
    end
end

function muteki2ex_GAME_START_3SEC(frame, msg)

    if s_buff_ui and s_buff_ui.slotlist then
        for i = 0, s_buff_ui["buff_group_cnt"] do
            local slotlist = s_buff_ui["slotlist"][i]
            local slotcount = s_buff_ui["slotcount"][i]
            local captionlist = s_buff_ui["captionlist"][i]
            if slotcount ~= nil and slotcount >= 0 then
                for i = 0, slotcount - 1 do
                    local slot = slotlist[i]
                    AUTO_CAST(slot)
                    local icon = slot:GetIcon()
                    local icon_info = icon:GetInfo()
                    local buff_id = icon_info.type
                    if buff_id ~= 0 then
                        local buff_cls = GetClassByType("Buff", buff_id)
                        slot:SetEventScript(ui.LBUTTONDOWN, 'muteki2ex_add_buff_msg')
                        slot:SetEventScriptArgString(ui.LBUTTONDOWN, buff_cls.Name)
                        slot:SetEventScriptArgNumber(ui.LBUTTONDOWN, buff_id)
                    end
                end
            end
        end
        g.setup_hook_and_event(g.addon, 'SET_BUFF_SLOT', "muteki2ex_SET_BUFF_SLOT", true)
    end
    g.setup_hook_and_event(g.addon, "ICON_USE", "muteki2ex_ICON_USE", true)
    muteki2ex_skill_list()
end

function muteki2ex_FPS_UPDATE()
    local notice_frame = ui.GetFrame(addon_name_lower .. "_notice_frame")
    if notice_frame and notice_frame:IsVisible() == 0 then
        notice_frame:ShowWindow(1)
    end
end

function muteki2ex_process_management_data(management_table, time_key, buff_id)
    if not management_table then
        return
    end
    for cid, info in pairs(management_table) do
        if type(info) == "table" and info.skill_id and info[time_key] then
            if cid == g.cid and info[time_key] > 0 then
                local skill_id = info.skill_id
                g.skills[tostring(skill_id)] = {
                    time = info[time_key],
                    buff_id = buff_id
                }
                -- print(string.format("Skill ID: %s, Buff ID: %s, Time: %s", skill_id, buff_id, info[time_key]))
            end
        end
    end
end

function muteki2ex_skill_list()
    g.skills = {}
    local buff_list = g.settings.buff_list
    for buff_id, buff_data in pairs(buff_list) do
        muteki2ex_process_management_data(buff_data.debuff_manage, "debuff_time", buff_id)
        muteki2ex_process_management_data(buff_data.buff_manage, "buff_time", buff_id)
    end
end

function muteki2ex_ICON_USE(my_frame, my_msg)
    local icon, reAction = g.get_event_args(my_msg)
    if icon then
        AUTO_CAST(icon)
        local cur_time = ICON_UPDATE_SKILL_COOLDOWN(icon)
        if cur_time > 0 then
            return
        end
        local icon_info = icon:GetInfo()
        if icon_info:GetCategory() == 'Skill' then
            local skill_id = icon_info.type
            local skill_id_str = tostring(skill_id)
            if g.buffs[g.skills[skill_id_str].buff_id] then
                return
            end
            local skill_list = g.skills[skill_id_str]
            if skill_list then
                g.time_buffs[skill_list.buff_id] = {
                    show = false,
                    effect = false,
                    start_time = imcTime.GetAppTime(),
                    set_time = skill_list.time,
                    notify = 0
                }
                -- ts(3, skill_list.buff_id, skill_list.time)
                muteki2ex_BUFF_ON_MSG("", 'BUFF_ADD', "", tonumber(skill_list.buff_id))
            end
        end
    end

end

function muteki2ex_BUFF_ON_MSG(frame, msg, is_dummy, buff_id)

    local buff_id_str = tostring(buff_id)
    local buff_data = g.settings.buff_list[buff_id_str]
    local notice_frame = ui.GetFrame(addon_name_lower .. "_notice_frame")

    if (buff_data and not buff_data["not_notify"][g.cid]) or is_dummy == "dummy" then

        local now = imcTime.GetAppTime()

        if g.buffs[buff_id_str] and g.buffs[buff_id_str].start_time then
            if now - g.buffs[buff_id_str].start_time < 0.5 then
                return
            end
        end

        local is_circle = false
        if buff_data.circle_icon then
            is_circle = true
        end
        local buff_cls = GetClassByType('Buff', buff_id)
        local buff_name = buff_cls.Name

        -- オバロ
        local overload_tbl = {4483, 4757}
        if buff_id == overload_tbl[1] or buff_id == overload_tbl[2] then
            local my_handle = session.GetMyHandle()
            local info_buff = info.GetBuff(my_handle, buff_id)
            if info_buff then
                g.overload = {
                    start_time = now,
                    buff_id = buff_id,
                    is_cool = 0,
                    cid = g.cid
                }
                g.buffs[buff_id_str] = nil
            else
                if g.overload.is_cool == 0 and msg == "BUFF_REMOVE" or msg == "BUFF_REMOVE_START" then
                    if msg == "BUFF_REMOVE" then
                        g.time_buffs[buff_id_str] = {
                            show = false,
                            effect = false,
                            start_time = now,
                            set_time = 20,
                            notify = 1
                        }
                    elseif msg == "BUFF_REMOVE_START" then
                        g.time_buffs[buff_id_str] = {
                            show = false,
                            effect = false,
                            start_time = now,
                            set_time = 50 - (now - g.overload.start_time),
                            notify = 1
                        }
                    end
                    g.overload = {
                        start_time = g.overload.start_time,
                        buff_id = buff_id,
                        is_cool = 1,
                        cid = g.cid
                    }
                    msg = 'BUFF_ADD'
                else
                    g.overload = nil
                end
            end
        end

        if msg == 'BUFF_ADD' then

            g.remove_notice = g.remove_notice or {}
            g.remove_notice[buff_id_str] = 0
            g.buff_count = g.buff_count or {}
            g.buff_count[buff_id_str] = (g.buff_count[buff_id_str] or 0) + 1

            if g.time_buffs and g.time_buffs[buff_id_str] then
                g.buffs[buff_id_str] = g.time_buffs[buff_id_str]
                g.time_buffs[buff_id_str] = nil
            elseif not g.buffs[buff_id_str] then
                g.buffs[buff_id_str] = {
                    show = false,
                    effect = false,
                    start_time = now,
                    set_time = nil,
                    notify = 0
                }
            end

            g.buffs.circle = g.buffs.circle or {}
            g.buffs.gauge = g.buffs.gauge or {}
            if is_circle then
                muteki2ex_insert_if_not_exists(g.buffs.circle, buff_id)
            else
                muteki2ex_insert_if_not_exists(g.buffs.gauge, buff_id)
            end

            if g.buffs[buff_id_str] and g.buffs[buff_id_str].notify == 0 then
                if buff_data.pt_chat then
                    if not string.find(buff_cls.Name, "NoData") then
                        ui.Chat(string.format("/p %s start", buff_cls.Name))
                    end
                end
                if buff_data.nico_chat == 1 then
                    NICO_CHAT(string.format("{@st55_a}%s start", buff_name))
                end
                if buff_data.effect_check == 1 then
                    local my_handle = session.GetMyHandle()
                    local actor = world.GetActor(my_handle)
                    effect.PlayActorEffect(actor, "F_sys_TPBOX_great_300", "None", 1.0, 6.0)
                end
                g.buffs[buff_id_str].notify = 1
            end
            if g.buff_count[buff_id_str] > 0 then
                muteki2ex_child_set_pos(notice_frame)
            end

            muteki2ex_buff_frame(notice_frame, msg, buff_id, buff_cls, buff_data, is_circle)
        elseif msg == 'BUFF_REMOVE' then

            if g.buffs[buff_id_str] and g.buffs[buff_id_str].set_time then
                local now = imcTime.GetAppTime()
                if g.buffs[buff_id_str].set_time - (now - g.buffs[buff_id_str].start_time) > 0 then
                    return
                end
            end
            if is_dummy ~= "dummy" then
                muteki2ex_handle_buff_end(notice_frame, buff_id)
            end
            muteki2ex_child_set_pos(notice_frame)
        elseif msg == 'BUFF_UPDATE' then

            if not g.buffs[buff_id_str] then
                g.buffs[buff_id_str] = {
                    show = false,
                    effect = false,
                    start_time = imcTime.GetAppTime(),
                    set_time = nil,
                    notify = 0
                }
            end
            muteki2ex_buff_frame(notice_frame, msg, buff_id, buff_cls, buff_data, is_circle)
        end
    end
end

function muteki2ex_handle_buff_end(notice_frame, buff_id)
    local buff_id_str = tostring(buff_id)
    local buff_data = g.settings.buff_list[buff_id_str]
    local buff_cls = GetClassByType('Buff', buff_id)

    local notice = false
    if g.remove_notice and g.remove_notice[buff_id_str] == 0 then
        notice = true
        g.remove_notice[buff_id_str] = 1
    end
    if notice then
        if buff_data.pt_chat then
            if not string.find(buff_cls.Name, "NoData") then
                ui.Chat(string.format("/p %s end", buff_cls.Name))
            end
        end
        if buff_data.nico_chat == 1 then
            NICO_CHAT(string.format("{@st55_a}%s end", buff_cls.Name))
        end
        if buff_data.end_sound == 1 then
            imcSound.PlaySoundEvent("sys_transcend_cast")
        end
    end
    if g.buffs[buff_id_str] then
        g.buffs[buff_id_str] = nil
    end

    if g.buff_count[buff_id_str] then
        g.buff_count[buff_id_str] = nil
    end

    local ui_types = {"circle", "gauge"}
    for _, ui_type in ipairs(ui_types) do
        local child_name = ui_type .. "_" .. buff_id
        local child = GET_CHILD(notice_frame, child_name)
        if child then
            local target_list = g.buffs[ui_type]
            if target_list then
                for i = #target_list, 1, -1 do
                    if target_list[i] == buff_id then
                        table.remove(target_list, i)
                        break
                    end
                end
            end
            DESTROY_CHILD_BYNAME(notice_frame, child_name)
        end
    end

end

function muteki2ex_insert_if_not_exists(list, value)

    for _, existing_value in ipairs(list) do
        if existing_value == value then
            return
        end
    end
    table.insert(list, value)
end

function muteki2ex_buff_frame(notice_frame, msg, buff_id, buff_cls, buff_data, is_circle)

    local buff_id_str = tostring(buff_id)
    local my_handle = session.GetMyHandle()
    local info_buff = info.GetBuff(my_handle, buff_id) or (g.buffs[buff_id_str] and g.buffs[buff_id_str].set_time)

    if not info_buff then
        return
    end
    local image_name = GET_BUFF_ICON_NAME(buff_cls)
    if image_name == "icon_None" then
        image_name = "icon_item_nothing"
    end
    if msg == "BUFF_ADD" then

        -- オバロ
        local is_cool = false
        if g.overload and g.overload.is_cool == 1 and g.overload.buff_id == buff_id then
            is_cool = true
        end

        local child
        local start_time_sec = 0

        if is_circle then
            child = notice_frame:CreateOrGetControl("picture", "circle_" .. buff_id, 50, 5, 50, 50)
            AUTO_CAST(child)

            child:SetImage(image_name)
            if g.settings.rotate == 1 then
                child:SetAngleLoop(3)
            end
            if is_cool then
                child:SetColorTone("FF696969")
            end
            child:SetEnableStretch(1)
            child:EnableHitTest(0)
        else -- gauge
            child = notice_frame:CreateOrGetControl("picture", "gauge_" .. buff_id, 0, 60, 250, 20)
            AUTO_CAST(child)
            child:SetEnableStretch(1)
            child:EnableHitTest(0)
            local gauge_back = child:CreateOrGetControl("picture", "gauge_back", 0, 10, 250, 10)
            AUTO_CAST(gauge_back)
            gauge_back:SetImage("fullblack")
            gauge_back:SetEnableStretch(1)
            gauge_back:EnableHitTest(0)
            local gauge_front = child:CreateOrGetControl("picture", "gauge_front", 0, 10, 250, 10)
            AUTO_CAST(gauge_front)
            gauge_front:SetImage("fullwhite")
            gauge_front:SetEnableStretch(1)
            gauge_front:EnableHitTest(0)
            if is_cool then
                gauge_front:SetColorTone("FFFFFFFF")
            else
                gauge_front:SetColorTone(buff_data.color)
            end

            local buff_name_ctrl = child:CreateOrGetControl("richtext", "buff_name", 0, 0, 10, 20)
            buff_name_ctrl:SetText(string.format("{ol}{s12}{img %s 15 15}%s", image_name, buff_cls.Name))
            buff_name_ctrl:AdjustFontSizeByWidth(170)
        end

        child:SetUserValue("BUFF_ID", buff_id)
        child:SetEnableStretch(1)
        child:EnableHitTest(0)

        if type(info_buff) == "number" then
            start_time_sec = info_buff
        elseif g.buffs[buff_id_str] and g.buffs[buff_id_str].set_time then
            local now = imcTime.GetAppTime()
            start_time_sec = g.buffs[buff_id_str].set_time - (g.buffs[buff_id_str].start_time - now)
        else
            start_time_sec = info_buff.time / 1000
        end

        child:SetUserValue("START_TIME", start_time_sec)

        local buff_time_ctrl = child:CreateOrGetControl("richtext", "buff_time", 0, 0, 50, 30)
        AUTO_CAST(buff_time_ctrl)
        --[[if not is_circle then
            buff_time_ctrl:SetOffset(180, 0);
            buff_time_ctrl:Resize(30, 20)
            buff_time_ctrl:SetGravity(ui.RIGHT, ui.TOP);
            local r = buff_time_ctrl:GetMargin();
            buff_time_ctrl:SetMargin(r.left, r.top, r.right + 40, r.bottom)
        elseif is_circle then
            buff_time_ctrl:SetGravity(ui.RIGHT, ui.TOP);
            local r = buff_time_ctrl:GetMargin();
            buff_time_ctrl:SetMargin(r.left, r.top + 10, r.right, r.bottom)
        end]]

        if buff_data.count_display and type(info_buff) ~= "number" then
            local buff_over_ctrl = child:CreateOrGetControl("richtext", "buff_over", 0, 0, 0, 0)
            AUTO_CAST(buff_over_ctrl)
            if is_circle then
                buff_over_ctrl:Resize(20, 20)
                buff_over_ctrl:SetGravity(ui.RIGHT, ui.BOTTOM)
                if start_time_sec > 0 then
                    buff_over_ctrl:SetText(string.format("{ol}{s22}%d", info_buff.over))
                    buff_time_ctrl:SetGravity(ui.LEFT, ui.TOP)
                else
                    buff_over_ctrl:SetText(string.format("{ol}{s35}%d", info_buff.over))
                    local rect = buff_over_ctrl:GetMargin();
                    buff_over_ctrl:SetMargin(rect.left, rect.top, rect.right + 12, rect.bottom + 5)
                end
            else -- gauge
                buff_over_ctrl:Resize(30, 20)
                buff_over_ctrl:SetOffset(220, 0)
                buff_over_ctrl:SetGravity(ui.RIGHT, ui.CENTER_VERT)
                buff_over_ctrl:SetText(string.format("{ol}{s20}%d", info_buff.over))
            end
            buff_over_ctrl:SetColorTone("FFFFFF00")
        elseif not is_circle then
            buff_time_ctrl:SetOffset(180, 0);
            buff_time_ctrl:Resize(30, 20)
            buff_time_ctrl:SetGravity(ui.RIGHT, ui.TOP);
            local r = buff_time_ctrl:GetMargin();
            buff_time_ctrl:SetMargin(r.left, r.top, r.right + 40, r.bottom)

        elseif is_circle then
            buff_time_ctrl:SetGravity(ui.RIGHT, ui.TOP);
            local r = buff_time_ctrl:GetMargin();
            buff_time_ctrl:SetMargin(r.left, r.top + 10, r.right, r.bottom)
        end

        muteki2ex_notice_update(child)
        child:RunUpdateScript("muteki2ex_notice_update", 0.1)

    elseif msg == "BUFF_UPDATE" then

        local ui_type = is_circle and "circle" or "gauge"
        local child = GET_CHILD(notice_frame, ui_type .. "_" .. buff_id)
        if child then
            local buff_over_ctrl = GET_CHILD(child, "buff_over")
            if buff_over_ctrl and type(info_buff) ~= "number" then
                local stat
                if is_circle then

                    stat = (info_buff.time <= 0) and string.format("{ol}{s35}%d", info_buff.over) or
                               string.format("{ol}{s22}%d", info_buff.over)
                else -- gauge
                    stat = string.format("{ol}{s20}%d", info_buff.over)
                end
                buff_over_ctrl:SetText(stat)
                buff_over_ctrl:SetColorTone("FFFFFF00")

                if buff_cls.OverBuff <= info_buff.over then
                    if not g.buffs[buff_id_str].effect then
                        local my_handle = session.GetMyHandle()
                        local actor = world.GetActor(my_handle)
                        effect.PlayActorEffect(actor, 'F_pattern025_loop', 'None', 1.0, 1.5)
                        imcSound.PlaySoundEvent("sys_cube_open_jackpot")
                        g.buffs[buff_id_str].effect = true
                    end
                    buff_over_ctrl:SetColorTone("FFFF0000")
                end
            end

            child:StopUpdateScript("muteki2ex_notice_update")
            muteki2ex_notice_update(child)
            child:RunUpdateScript("muteki2ex_notice_update", 0.1)
        end
    end

end

function muteki2ex_get_remaining_time(buff_id)
    local buff_id_str = tostring(buff_id)
    local my_handle = session.GetMyHandle()

    if g.buffs[buff_id_str] and g.buffs[buff_id_str].set_time then
        local elapsed_time = imcTime.GetAppTime() - g.buffs[buff_id_str].start_time
        return g.buffs[buff_id_str].set_time - elapsed_time
    end

    local info_buff = info.GetBuff(my_handle, buff_id)
    if info_buff then
        if info_buff.time > 0 then
            return info_buff.time / 1000
        elseif info_buff.time == 0 and info_buff.over > 0 then

            return math.huge
        end
    end

    return 0
end

function muteki2ex_notice_update(child)

    local child_name = child:GetName()

    local notice_frame = child:GetParent()
    local buff_id = child:GetUserIValue("BUFF_ID")
    local buff_id_str = tostring(buff_id)
    local my_handle = session.GetMyHandle()

    local cur_time = muteki2ex_get_remaining_time(buff_id)

    local ui_type = string.find(child:GetName(), "circle_") and "circle" or "gauge"

    if cur_time <= 0 then
        muteki2ex_BUFF_ON_MSG(nil, "BUFF_REMOVE", "", buff_id)
        return 0
    end

    if (cur_time <= g.settings.hide_time) or (cur_time == math.huge) then
        child:ShowWindow(1)
        g.buffs[buff_id_str].show = true
    else
        child:ShowWindow(0)
        g.buffs[buff_id_str].show = false
    end
    muteki2ex_child_set_pos(notice_frame)

    if g.buffs[buff_id_str].show == false then
        return 1
    end

    if ui_type == "circle" then
        if cur_time == math.huge then
            local buff_over_ctrl = GET_CHILD(child, "buff_over")
            buff_over_ctrl:ShowWindow(1)
        elseif cur_time > 0 then
            local stat = string.format("{ol}{s22}%.1f", cur_time)

            if cur_time >= 60 then
                local min = math.floor(cur_time / 60)
                stat = string.format("{ol}{s22}%d{s10}%s", min, "min")
            elseif cur_time <= 10 and cur_time > 5 then
                stat = string.format("{ol}{s22}{#FF4500}%.1f", cur_time)
            elseif cur_time <= 5 then
                stat = string.format("{ol}{s22}{#FF0000}%.1f", cur_time)
            end

            local buff_time_ctrl = GET_CHILD(child, "buff_time")
            if buff_time_ctrl then
                buff_time_ctrl:SetText(stat)
            end
        end

    elseif ui_type == "gauge" then

        local buff_time_ctrl = GET_CHILD(child, "buff_time")
        if cur_time > 0 and cur_time ~= math.huge then
            buff_time_ctrl:ShowWindow(1)
            buff_time_ctrl:SetText(string.format("{ol}{s18}%.1f", cur_time))
            buff_time_ctrl:SetColorTone(g.settings.buff_list[buff_id_str].color)
        else
            buff_time_ctrl:ShowWindow(0)
        end

        local start_time = tonumber(child:GetUserValue("START_TIME"))
        local ratio = 0
        if cur_time == math.huge then
            ratio = 1.0
        elseif start_time > 0 then
            ratio = cur_time / start_time
        end

        local gauge_front = GET_CHILD(child, "gauge_front")
        AUTO_CAST(gauge_front)
        if gauge_front then

            gauge_front:Resize(250 * ratio, 10)

        end

        local gauge_front = GET_CHILD(child, "gauge_front")
        AUTO_CAST(gauge_front)

        -- ts(ratio, child:IsVisible(), child:GetHeight(), gauge_back:GetHeight(), gauge_front:GetHeight())
    end

    return 1
end

function muteki2ex_reorder_ui_elements(notice_frame, ui_type)

    local sorted_list = {}
    local source_list = g.buffs[ui_type]

    if source_list and type(source_list) == "table" then
        for _, buff_id in ipairs(source_list) do
            local cur_time = muteki2ex_get_remaining_time(buff_id)

            if cur_time > 0 then
                table.insert(sorted_list, {
                    buff_id = buff_id,
                    time = cur_time
                })
            end
        end
    end

    table.sort(sorted_list, function(a, b)
        return a.time < b.time
    end)

    local visible_count = 0
    for _, entry in ipairs(sorted_list) do
        local child = GET_CHILD(notice_frame, ui_type .. "_" .. entry.buff_id)
        if child and child:IsVisible() == 1 then
            if ui_type == "circle" then
                child:SetOffset((visible_count + 1) * 50, 5)
            else -- gauge
                child:SetOffset(0, visible_count * 25 + 60)
            end
            visible_count = visible_count + 1

            if not child:HaveUpdateScript("muteki2ex_notice_update") then
                child:RunUpdateScript("muteki2ex_notice_update", 0.1)
            end
        end
    end
    return visible_count
end

function muteki2ex_child_set_pos(notice_frame)

    local circle_count = muteki2ex_reorder_ui_elements(notice_frame, "circle")
    local gauge_count = muteki2ex_reorder_ui_elements(notice_frame, "gauge")
    local x = circle_count * 50 + 50
    if x < 250 then
        x = 250
    end

    local y = gauge_count * 25 + 60
    if y < 60 then
        y = 60
    end

    notice_frame:Resize(x, y)
end

function muteki2ex_buff_frame_init()

    local frame_name = addon_name_lower .. "_notice_frame"
    local notice_frame = ui.CreateNewFrame("notice_on_pc", frame_name, 0, 0, 0, 0)
    AUTO_CAST(notice_frame)

    if g.settings.pos.lock == false then
        notice_frame:SetSkinName("chat_window")
        notice_frame:SetAlpha(100)
    else
        notice_frame:SetSkinName("None")
    end
    notice_frame:Resize(250, 210)

    if g.settings.mode == "fixed" then
        notice_frame:SetOffset(g.settings.pos.x, g.settings.pos.y)
        notice_frame:StopUpdateScript("_FRAME_AUTOPOS")
    else
        local handle = session.GetMyHandle()

        FRAME_AUTO_POS_TO_OBJ(notice_frame, handle, notice_frame:GetWidth() - 175, 50, 3, 1)
        g.settings.pos.lock = true
        muteki2ex_save_settings()
        local setting_frame = ui.GetFrame(addon_name_lower .. "_setting_frame")
        if setting_frame then
            AUTO_CAST(setting_frame)
            local move_toggle = GET_CHILD_RECURSIVELY(setting_frame, "move_toggle")
            AUTO_CAST(move_toggle)
            local icon_name = "test_com_ability_on"
            move_toggle:SetImage(icon_name)
        end
    end

    notice_frame:SetLayerLevel(g.settings.layer_lv or 80)

    notice_frame:EnableHittestFrame(g.settings.pos.lock == true and 0 or 1)
    notice_frame:EnableMove(g.settings.pos.lock == true and 0 or 1)
    notice_frame:ShowWindow(1)
    notice_frame:SetEventScript(ui.LBUTTONUP, "muteki2ex_notic_frame_end_drag")

end

function muteki2ex_notic_frame_end_drag(notice_frame)
    g.settings.pos.x = notice_frame:GetX()
    g.settings.pos.y = notice_frame:GetY()
    muteki2ex_save_settings()
end

function muteki2ex_SET_BUFF_SLOT(my_frame, my_msg)

    local slot, capt, class, buff_type = g.get_event_args(my_msg)
    AUTO_CAST(slot)

    slot:SetEventScript(ui.LBUTTONDOWN, 'muteki2ex_add_buff_msg')
    slot:SetEventScriptArgString(ui.LBUTTONDOWN, class.Name)
    slot:SetEventScriptArgNumber(ui.LBUTTONDOWN, buff_type)
end

function muteki2ex_add_buff_msg(frame, ctrl, cls_name, buff_id)

    local yes_scp = string.format("muteki2ex_add_buff('','%s','%s','')", ctrl:GetName(), buff_id)
    local msg = string.format(trans('add_check'), cls_name)
    ui.MsgBox(msg, yes_scp, "None");
end

function muteki2ex_setting_frame_init()

    local setting_frame = ui.CreateNewFrame("notice_on_pc", addon_name_lower .. "_setting_frame", 0, 50, 0, 0)
    AUTO_CAST(setting_frame)
    setting_frame:SetSkinName("test_frame_low")
    setting_frame:Resize(600, 1005)
    setting_frame:SetGravity(ui.LEFT, ui.TOP)
    setting_frame:SetOffset(0, 30)
    setting_frame:SetLayerLevel(80)

    local title_gb = setting_frame:CreateOrGetControl("groupbox", "title_gb", 0, 0, 600, 110)
    AUTO_CAST(title_gb)
    title_gb:SetSkinName("test_frame_top")

    local title_text = title_gb:CreateOrGetControl("richtext", "title_text", 0, 0, ui.CENTER_HORZ, ui.TOP, 0, 15, 0, 0)
    AUTO_CAST(title_text);
    title_text:SetText('{ol}{s28}MUTEKI Settings')

    local x = 0

    local buff_time = title_gb:CreateOrGetControl('richtext', 'buff_time', 15, 60, 100, 30)
    AUTO_CAST(buff_time)
    buff_time:SetText(trans('buff_time'))

    x = buff_time:GetWidth() + 15

    local buff_time_edit = title_gb:CreateOrGetControl('edit', 'buff_time_edit', x, 60, 60, 20)
    AUTO_CAST(buff_time_edit)
    buff_time_edit:SetNumberMode(1)
    buff_time_edit:SetFontName("white_16_ol")
    buff_time_edit:SetText(g.settings.hide_time or 0)
    buff_time_edit:SetTextAlign("center", "top")
    buff_time_edit:SetEventScript(ui.ENTERKEY, 'muteki2ex_change_settings')

    x = x + buff_time_edit:GetWidth() + 20

    local layer = title_gb:CreateOrGetControl('richtext', 'layer', x, 60, 10, 30)
    AUTO_CAST(layer)
    layer:SetText(trans('layer_lv'))

    x = x + layer:GetWidth()

    local layer_edit = title_gb:CreateOrGetControl('edit', 'layer_edit', x, 60, 50, 20)
    AUTO_CAST(layer_edit)
    layer_edit:SetNumberMode(1)
    layer_edit:SetFontName("white_16_ol")
    layer_edit:SetText(g.settings.layer_lv or 80)
    layer_edit:SetTextAlign("center", "top")
    layer_edit:SetEventScript(ui.ENTERKEY, 'muteki2ex_change_settings')

    x = 0

    local mode = title_gb:CreateOrGetControl('richtext', 'mode', 15, 85, 10, 30)
    AUTO_CAST(mode)
    mode:SetText(trans('position_mode'))

    x = mode:GetWidth() + 15

    local mode_toggle = title_gb:CreateOrGetControl('picture', "mode_toggle", x, 80, 60, 25);
    AUTO_CAST(mode_toggle)
    local icon_name = "test_com_ability_on"
    if g.settings.mode == "fixed" then
        icon_name = "test_com_ability_off"
    end
    mode_toggle:SetImage(icon_name)
    mode_toggle:SetEnableStretch(1)
    mode_toggle:EnableHitTest(1)
    mode_toggle:SetTextTooltip(trans("mode_desc"))
    mode_toggle:SetEventScript(ui.LBUTTONUP, "muteki2ex_change_settings")

    x = x + mode_toggle:GetWidth() + 10

    local move = title_gb:CreateOrGetControl('richtext', 'move', x, 85, 10, 30)
    AUTO_CAST(move)
    move:SetText(trans('frame_lock'))

    x = x + move:GetWidth()

    local move_toggle = title_gb:CreateOrGetControl('picture', "move_toggle", x, 80, 60, 25);
    AUTO_CAST(move_toggle)
    local icon_name = "test_com_ability_on"
    if not g.settings.pos.lock then
        icon_name = "test_com_ability_off"
    end
    move_toggle:SetImage(icon_name)
    move_toggle:SetEnableStretch(1)
    move_toggle:EnableHitTest(1)
    move_toggle:SetTextTooltip(trans("lock_notice"))
    move_toggle:SetEventScript(ui.LBUTTONUP, "muteki2ex_change_settings")

    x = x + move_toggle:GetWidth() + 10

    local rotate = title_gb:CreateOrGetControl('richtext', 'rotate', x, 85, 10, 30)
    AUTO_CAST(rotate)
    rotate:SetText(trans("icon_rotate"))

    x = x + rotate:GetWidth()

    local rotate_toggle = title_gb:CreateOrGetControl('picture', "rotate_toggle", x, 80, 60, 25);
    AUTO_CAST(rotate_toggle)
    local icon_name = "test_com_ability_on"
    if g.settings.rotate ~= 1 then
        icon_name = "test_com_ability_off"
    end
    rotate_toggle:SetImage(icon_name)
    rotate_toggle:SetEnableStretch(1)
    rotate_toggle:EnableHitTest(1)
    rotate_toggle:SetEventScript(ui.LBUTTONUP, "muteki2ex_change_settings")

    local add = title_gb:CreateOrGetControl("button", "add", 530, 80, 50, 30)
    AUTO_CAST(add)
    add:SetSkinName("test_cardtext_btn")
    add:SetText("{ol}" .. "Add")
    add:SetTextTooltip(trans("add_new"))
    add:SetEventScript(ui.LBUTTONUP, "muteki2ex_buff_list_open")

    local close = title_gb:CreateOrGetControl("button", "close", 0, 0, 25, 25)
    AUTO_CAST(close)
    close:SetImage("testclose_button")
    close:SetGravity(ui.RIGHT, ui.TOP)
    close:SetEventScript(ui.LBUTTONUP, "muteki2ex_setting_frame_close")
    local gb = setting_frame:CreateOrGetControl("groupbox", "gb", 10, 110, 580, setting_frame:GetHeight() - 120)
    AUTO_CAST(gb)
    gb:SetSkinName("bg")
    gb:RemoveAllChild()
    muteki2ex_setting_gbox_init(setting_frame, gb)

    setting_frame:ShowWindow(1)
end

function muteki2ex_setting_frame_close(parent, ctrl)
    local setting_frame = parent:GetTopParentFrame()
    setting_frame:ShowWindow(0)

    local buff_list_frame_name = addon_name_lower .. "buff_list_frame"
    local buff_list_frame = ui.GetFrame(buff_list_frame_name)
    if buff_list_frame then
        muteki2ex_buff_list_close(buff_list_frame, "", "", "")
    end

    local buff_list_frame_name = addon_name_lower .. "buff_list_frame"
    local buff_list_frame = ui.GetFrame(buff_list_frame_name)
    if buff_list_frame then
        muteki2ex_buff_list_close(buff_list_frame, "", "", "")
    end
    local skill_list_frame_name = addon_name_lower .. "skill_list_frame"
    local skill_list_frame = ui.GetFrame(skill_list_frame_name)
    if skill_list_frame then
        muteki2ex_skill_list_close(skill_list_frame, "", "", "")
    end
end

function muteki2ex_change_settings(frame, ctrl, str, num)

    local ctrl_name = ctrl:GetName()

    if ctrl_name == "buff_time_edit" then
        local get_number = tonumber(ctrl:GetText())
        if get_number then
            g.settings.hide_time = get_number
            ui.SysMsg(string.format(trans("hide_sec"), get_number))
        else
            g.settings.hide_time = 0
        end
    elseif ctrl_name == "layer_edit" then
        local get_number = tonumber(ctrl:GetText())
        if get_number then
            g.settings.layer_lv = get_number
            ui.SysMsg(string.format(trans("layer_notice"), get_number))
        else
            g.settings.layer_lv = 0
        end
    elseif ctrl_name == "mode_toggle" then
        if g.settings.mode == "fixed" then
            g.settings.mode = "trace"
        else
            g.settings.mode = "fixed"
        end
    elseif ctrl_name == "move_toggle" then
        if g.settings.pos.lock then
            g.settings.pos.lock = false
        else
            g.settings.pos.lock = true
        end
    elseif ctrl_name == "rotate_toggle" then
        if g.settings.rotate == 1 then
            g.settings.rotate = 0
        else
            g.settings.rotate = 1
        end
    end
    muteki2ex_save_settings()
    muteki2ex_setting_frame_init()
    muteki2ex_buff_frame_init()

    local my_handle = session.GetMyHandle()
    if g.settings.buff_list and type(g.settings.buff_list) == "table" then
        for buff_id_str, buff_data in pairs(g.settings.buff_list) do
            local buff_id = tonumber(buff_id_str)
            local info_buff = info.GetBuff(my_handle, buff_id)
            if info_buff then
                muteki2ex_BUFF_ON_MSG("", "BUFF_REMOVE", "", buff_id)
                muteki2ex_BUFF_ON_MSG("", "BUFF_ADD", "", buff_id)
                muteki2ex_BUFF_ON_MSG("", "BUFF_UPDATE", "", buff_id)
            end
        end
    end

end

function muteki2ex_setting_gbox_init(setting_frame, gb)

    local sorted_buff_list = {}
    if g.settings.buff_list and type(g.settings.buff_list) == "table" then
        for buff_id_str, buff_data in pairs(g.settings.buff_list) do
            table.insert(sorted_buff_list, {
                buff_id = tonumber(buff_id_str),
                data = buff_data
            })
        end
    end

    table.sort(sorted_buff_list, function(a, b)
        return a.buff_id < b.buff_id
    end)

    local index = 1
    for i, entry in ipairs(sorted_buff_list) do
        index = index + 1

        local buff_id = entry.buff_id

        local buff_data = entry.data
        local buff_cls = GetClassByType('Buff', buff_id)
        local list = gb:CreateOrGetControl('groupbox', 'list' .. buff_id, 5, 5 + 175 * (i - 1), 555, 175)
        list:SetSkinName("market_listbase")

        local buff_pic = list:CreateOrGetControl('picture', 'buff_pic', 95, 10, 30, 30)
        AUTO_CAST(buff_pic)
        buff_pic:SetEnableStretch(1)
        if buff_cls and buff_cls.Icon then
            local icon_name = 'icon_' .. buff_cls.Icon
            if buff_cls.Icon == "None" then
                icon_name = "icon_item_nothing"
            end
            buff_pic:SetImage(icon_name)
            buff_pic:SetTextTooltip(trans('delete_notice'))
            buff_pic:SetEventScript(ui.RBUTTONUP, 'muteki2ex_delete_buff')
            buff_pic:SetEventScriptArgString(ui.RBUTTONUP, buff_cls.Name)
            buff_pic:SetEventScriptArgNumber(ui.RBUTTONUP, buff_id)

            local buff_name = list:CreateOrGetControl('richtext', 'buff_name', 130, 15, 60, 30)
            AUTO_CAST(buff_name)
            buff_name:SetText('{#000000}' .. buff_cls.Name)
            buff_name:SetTooltipType('buff');
            buff_name:SetTooltipArg(buff_name, buff_id, 0);

            local buff_edit = list:CreateOrGetControl('edit', 'buff_edit', 10, 10, 80, 30)
            AUTO_CAST(buff_edit)
            buff_edit:SetNumberMode(1)
            buff_edit:SetFontName("white_16_ol")
            buff_edit:SetText(buff_cls.ClassID)
            buff_edit:SetTextAlign("center", "center")
            buff_edit:SetTextTooltip(trans('function_notice'))
            buff_edit:SetEventScript(ui.ENTERKEY, 'muteki2ex_add_buff')
            buff_edit:SetEventScriptArgString(ui.ENTERKEY, buff_id)

        end

        local circle = list:CreateOrGetControl('checkbox', 'circle', 10, 45, 200, 25)
        AUTO_CAST(circle)
        local circle_icon = buff_data.circle_icon
        circle:SetCheck(circle_icon and 1 or 0)
        circle:SetText(trans('icon_mode'))
        circle:SetEventScript(ui.LBUTTONUP, 'muteki2ex_setting_change')
        circle:SetEventScriptArgString(ui.LBUTTONUP, buff_id)

        local not_notify = list:CreateOrGetControl('checkbox', 'not_notify', 10, 70, 200, 25)
        AUTO_CAST(not_notify)
        not_notify:SetCheck(buff_data.not_notify[g.cid] and 1 or 0)
        not_notify:SetText(trans('not_notify'))
        not_notify:SetEventScript(ui.LBUTTONUP, 'muteki2ex_setting_change')
        not_notify:SetEventScriptArgString(ui.LBUTTONUP, buff_id)

        local pt_chat = list:CreateOrGetControl('checkbox', 'pt_chat', 10, 95, 200, 25)
        AUTO_CAST(pt_chat)
        pt_chat:SetCheck(buff_data.pt_chat and 1 or 0)
        pt_chat:SetText(trans('pt_chat'))
        pt_chat:SetEventScript(ui.LBUTTONUP, 'muteki2ex_setting_change')
        pt_chat:SetEventScriptArgString(ui.LBUTTONUP, buff_id)

        local nico_chat = list:CreateOrGetControl('checkbox', 'nico_chat', 10, 120, 200, 25)
        AUTO_CAST(nico_chat)
        nico_chat:SetCheck(buff_data.nico_chat)
        nico_chat:SetText(trans('nico_chat'))
        nico_chat:SetEventScript(ui.LBUTTONUP, 'muteki2ex_setting_change')
        nico_chat:SetEventScriptArgString(ui.LBUTTONUP, buff_id)

        local effect = list:CreateOrGetControl('checkbox', 'effect', 270, 70, 200, 25)
        AUTO_CAST(effect)
        effect:SetCheck(buff_data.effect_check)
        effect:SetText(trans('with_effect'))
        effect:SetEventScript(ui.LBUTTONUP, 'muteki2ex_setting_change')
        effect:SetEventScriptArgString(ui.LBUTTONUP, buff_id)

        local color_pic = list:CreateOrGetControl('picture', 'color_pic', 510, 10, 30, 25)
        AUTO_CAST(color_pic)
        color_pic:SetEnableStretch(1)
        color_pic:SetImage("chat_color");
        color_pic:SetColorTone(buff_data.color or g.default_color)
        color_pic:SetTextTooltip(trans('color_tone'))

        local color_tbl = {'FFFFFF00', -- [1] 黄色
        'FFFFD700', -- [2] ゴールド
        'FFFF4500', -- [3] オレンジ
        'FF00FF00', -- [4] ライムグリーン
        'FF008000', -- [5] 緑
        'FF00BFFF', -- [6] スカイブルー
        'FF0000FF', -- [7] 青
        'FF800080', -- [8] 紫
        "FFFF1493", -- [9] ピンク
        "FFFF0000" -- [10] 赤
        }

        local color_box = list:CreateOrGetControl('groupbox', "color_box", 315, 45, 220, 25);
        AUTO_CAST(color_box)
        for i = 1, #color_tbl do
            local color_value = color_tbl[i]
            local color = color_box:CreateOrGetControl("picture", "color_" .. i, 20 * i, 0, 20, 25);
            AUTO_CAST(color)
            color:SetImage("chat_color")
            color:SetColorTone(color_value)
            color:SetEventScript(ui.LBUTTONUP, 'muteki2ex_setting_change')
            color:SetEventScriptArgString(ui.LBUTTONUP, color_value)
            color:SetEventScriptArgNumber(ui.LBUTTONUP, buff_id)
        end

        local color_edit = list:CreateOrGetControl('edit', 'color_edit', 405, 10, 100, 30)
        AUTO_CAST(color_edit)
        color_edit:SetFontName("white_16_ol")
        color_edit:SetText("{ol}" .. buff_data.color or g.default_color)
        color_edit:SetTextAlign("center", "center")
        color_edit:SetTextTooltip(trans('color_notice'))
        color_edit:SetNumberMode(0)
        color_edit:SetEventScript(ui.ENTERKEY, 'muteki2ex_setting_change')
        color_edit:SetEventScriptArgString(ui.ENTERKEY, buff_data.color or g.default_color)
        color_edit:SetEventScriptArgNumber(ui.ENTERKEY, buff_id)

        if buff_cls.OverBuff > 1 then
            local count_display = list:CreateOrGetControl('checkbox', 'count_display', 270, 95, 200, 25)
            AUTO_CAST(count_display)
            count_display:SetCheck(buff_data.count_display and 1 or 0)
            count_display:SetText(trans('count_display'))
            count_display:SetEventScript(ui.LBUTTONUP, 'muteki2ex_setting_change')
            count_display:SetEventScriptArgString(ui.LBUTTONUP, buff_id)
        end

        local x = 0
        local xx = 0
        local time_edit = list:CreateOrGetControl('edit', 'time_edit', 10, 145, 80, 25)
        AUTO_CAST(time_edit)
        time_edit:SetFontName("white_16_ol")
        time_edit:SetTextAlign("center", "center")
        time_edit:SetNumberMode(0)
        local debuff_time = ""
        local buff_time = ""
        if buff_cls.Group1 == "Debuff" or buff_cls.Group1 == "Deuff" then

            local debuff_manage = g.settings.buff_list[tostring(buff_id)].debuff_manage[g.cid]

            if debuff_manage and debuff_manage.debuff_time and debuff_manage.debuff_time > 0 then
                debuff_time = debuff_manage.debuff_time
            end

            time_edit:SetText("{ol}" .. debuff_time or "")
            time_edit:SetTextTooltip(trans('debuff_notice'))
            time_edit:SetUserValue("SWITCH", "debuff")
            time_edit:SetEventScript(ui.ENTERKEY, 'muteki2ex_setting_change')
            time_edit:SetEventScriptArgString(ui.ENTERKEY, "debuff")
            time_edit:SetEventScriptArgNumber(ui.ENTERKEY, buff_id)

            x = x + time_edit:GetWidth() + 15

            local time = list:CreateOrGetControl('richtext', 'time', x, 147, 100, 25)
            AUTO_CAST(time)
            time:SetText(trans('debuff_time'))

            x = x + time:GetWidth() + 10

            --[[local time_toggle = list:CreateOrGetControl('picture', "time_toggle", x, 145, 60, 25);
            AUTO_CAST(time_toggle)
            local icon_name = "test_com_ability_on"
            if not debuff_manage.auto_time then
                icon_name = "test_com_ability_off"
            end
            time_toggle:SetImage(icon_name)
            time_toggle:SetEnableStretch(1)
            time_toggle:EnableHitTest(1)
            time_toggle:SetTextTooltip(trans('auto_time'))
            time_toggle:SetEventScript(ui.LBUTTONUP, 'muteki2ex_setting_change')
            time_toggle:SetEventScriptArgString(ui.LBUTTONUP, buff_id)
            time_toggle:SetEventScriptArgNumber(ui.LBUTTONUP, buff_id)

            x = x + time_toggle:GetWidth() + 10]]

        else

            local buff_manage = g.settings.buff_list[tostring(buff_id)].buff_manage[g.cid]

            if buff_manage and buff_manage.buff_time and buff_manage.buff_time > 0 then
                buff_time = buff_manage.buff_time
            end

            time_edit:SetText("{ol}" .. buff_time)
            time_edit:SetTextTooltip(trans('buff_notice_cid'))
            time_edit:SetUserValue("SWITCH", "buff")
            time_edit:SetEventScript(ui.ENTERKEY, 'muteki2ex_setting_change')
            time_edit:SetEventScriptArgString(ui.ENTERKEY, "buff")
            time_edit:SetEventScriptArgNumber(ui.ENTERKEY, buff_id)

            xx = xx + time_edit:GetWidth() + 15

            local time = list:CreateOrGetControl('richtext', 'time', xx, 147, 100, 25)
            AUTO_CAST(time)
            time:SetText(trans('buff_time_cid'))

            xx = xx + time:GetWidth() + 10
        end

        x = x >= xx and x or xx

        if buff_time ~= "" or debuff_time ~= "" then

            local skill_edit = list:CreateOrGetControl('edit', 'skill_edit', x, 145, 80, 25)
            AUTO_CAST(skill_edit)
            skill_edit:SetFontName("white_16_ol")

            local skill_id = ""
            local buff_entry = g.settings.buff_list[tostring(buff_id)]
            if buff_entry then
                local buff_manage = buff_entry.buff_manage[g.cid]
                if buff_manage and buff_manage.skill_id and buff_manage.skill_id > 0 then
                    skill_id = buff_manage.skill_id
                end
                local debuff_manage = buff_entry.debuff_manage[g.cid]
                if debuff_manage and debuff_manage.skill_id and debuff_manage.skill_id > 0 then
                    skill_id = debuff_manage.skill_id
                end
            end

            skill_edit:SetTextTooltip(trans('skill_notice'))
            skill_edit:SetTextAlign("center", "center")
            skill_edit:SetNumberMode(1)
            skill_edit:SetText("{ol}" .. skill_id)
            skill_edit:SetEventScript(ui.ENTERKEY, 'muteki2ex_setting_change')
            skill_edit:SetEventScriptArgNumber(ui.ENTERKEY, buff_id)
            skill_edit:SetEventScriptArgString(ui.ENTERKEY, time_edit:GetUserValue("SWITCH"))
            skill_edit:SetUserValue("SWITCH", time_edit:GetUserValue("SWITCH"))

            x = x + skill_edit:GetWidth() + 5

            local skill_text = list:CreateOrGetControl('richtext', 'skill_text', x, 147, 100, 25)
            AUTO_CAST(skill_text)
            skill_text:SetText(trans('skill_text'))

            x = x + skill_text:GetWidth() + 5

            local add = list:CreateOrGetControl("button", "add", x, 140, 40, 30)
            AUTO_CAST(add)
            add:SetSkinName("test_cardtext_btn")
            add:SetText("{ol}{s13}" .. "Add")
            add:SetTextTooltip(trans("add_new_skill"))
            add:SetEventScript(ui.LBUTTONUP, "muteki2ex_skill_list_open")
            add:SetEventScriptArgNumber(ui.LBUTTONUP, tonumber(buff_id))
        end

        local end_sound = list:CreateOrGetControl('checkbox', 'end_sound', 270, 120, 200, 25)
        AUTO_CAST(end_sound)
        end_sound:SetCheck(buff_data.end_sound)
        end_sound:SetText(trans('end_sound'))
        end_sound:SetEventScript(ui.LBUTTONUP, 'muteki2ex_setting_change')
        end_sound:SetEventScriptArgString(ui.LBUTTONUP, buff_id)

        -- local sound_config = list:CreateOrGetControl("button", "sound_config", 270 + end_sound:GetWidth(), 120, 25, 25)
        -- AUTO_CAST(sound_config)
        -- sound_config:SetSkinName("None")
        -- sound_config:SetText("{img config_button_normal 25 25}")
        -- sound_config:SetEventScript(ui.LBUTTONUP, "skill_notice_free_sound_select")
        ---sound_config:SetEventScriptArgNumber(ui.LBUTTONUP, buff_id)

    end

    local list = gb:CreateOrGetControl('groupbox', 'list' .. index, 5, 5 + 175 * (index - 1), 555, 175)
    list:SetSkinName("market_listbase")

    local buff_edit = list:CreateOrGetControl('edit', 'buff_edit', 10, 10, 80, 30)
    AUTO_CAST(buff_edit)
    buff_edit:SetNumberMode(1)
    buff_edit:SetFontName("white_16_ol")
    buff_edit:SetTextAlign("center", "center")
    buff_edit:SetTextTooltip(trans('function_notice'))
    buff_edit:SetEventScript(ui.ENTERKEY, 'muteki2ex_add_buff')

    for i, entry in ipairs(sorted_buff_list) do
        local buff_id = entry.buff_id

        if g.cur_pos and tostring(buff_id) == g.cur_pos then
            gb:SetScrollPos(155 * (i - 3))
            local list = GET_CHILD(gb, "list" .. buff_id)
            list:SetSkinName("test_skin_01") -- monster_card_list
            g.cur_pos = nil
        end
    end

end

function muteki2ex_setting_change(frame, ctrl, buff_id_str, buff_id)

    local ctrl_name = ctrl:GetName()
    local is_boolean = nil
    local is_check = nil
    local not_notify = {}

    if buff_id == 0 then
        is_boolean = ctrl:IsChecked() == 1 and true or false
        is_check = ctrl:IsChecked()
    end
    if ctrl_name == "circle" then
        g.settings.buff_list[buff_id_str].circle_icon = is_boolean
    elseif ctrl_name == "not_notify" then
        g.settings.buff_list[buff_id_str].not_notify[g.cid] = is_boolean
        not_notify[buff_id_str] = true
    elseif ctrl_name == "pt_chat" then
        g.settings.buff_list[buff_id_str].pt_chat = is_boolean
    elseif ctrl_name == "nico_chat" then
        g.settings.buff_list[buff_id_str].nico_chat = is_check
    elseif ctrl_name == "effect" then
        g.settings.buff_list[buff_id_str].effect_check = is_check
    elseif ctrl_name == "count_display" then
        g.settings.buff_list[buff_id_str].count_display = is_boolean
    elseif ctrl_name == "end_sound" then
        g.settings.buff_list[buff_id_str].end_sound = is_check
    elseif ctrl_name == "color_edit" then
        local color_text = ctrl:GetText()
        local color = buff_id_str
        local buff_id_str = tostring(buff_id)
        if string.len(color_text) ~= 8 then
            ctrl:SetText(color)
            ui.SysMsg(trans("color_notice"))
            return
        end
        g.settings.buff_list[buff_id_str].color = color_text

    elseif string.find(ctrl_name, "color_") then
        local color = buff_id_str
        local buff_id_str = tostring(buff_id)
        g.settings.buff_list[buff_id_str].color = color

    elseif ctrl_name == "time_edit" then
        if buff_id_str ~= "buff" then
            local debuff_manage = g.settings.buff_list[tostring(buff_id)].debuff_manage[g.cid]
            if tonumber(ctrl:GetText()) then
                debuff_manage.debuff_time = tonumber(ctrl:GetText())
            else
                ctrl:SetText("")
                debuff_manage.debuff_time = 0
            end
            ui.SysMsg(string.format(trans("debuff_manage_set"), debuff_manage.debuff_time))

        else
            local buff_manage = g.settings.buff_list[tostring(buff_id)].buff_manage[g.cid]

            if tonumber(ctrl:GetText()) then
                buff_manage.buff_time = tonumber(ctrl:GetText())
            else
                buff_manage.buff_time = 0
                ctrl:SetText("")
            end
            ui.SysMsg(string.format(trans("debuff_manage_set"), buff_manage.buff_time))
        end
        muteki2ex_skill_list()
        --[[elseif ctrl_name == "time_toggle" then
        local debuff_manage = g.settings.buff_list[tostring(buff_id)].debuff_manage[g.cid]
        if debuff_manage.auto_time then
            debuff_manage.auto_time = false
            debuff_manage.get_debuff_time = false
        else
            debuff_manage.auto_time = true
            debuff_manage.get_debuff_time = true
        end
        muteki2ex_setting_frame_init()]]
    elseif ctrl_name == "skill_edit" then

        if buff_id_str ~= "buff" then
            local debuff_manage = g.settings.buff_list[tostring(buff_id)].debuff_manage[g.cid]
            local skill_cls = nil
            if tonumber(ctrl:GetText()) then
                skill_cls = GetClassByType("Skill", tonumber(ctrl:GetText()))
                debuff_manage.skill_id = tonumber(ctrl:GetText())
                ui.SysMsg(string.format(trans("skill_set"), skill_cls.Name))
            else
                ctrl:SetText("")
                debuff_manage.skill_id = 0
            end
        else
            local buff_manage = g.settings.buff_list[tostring(buff_id)].buff_manage[g.cid]
            local skill_cls = nil
            if tonumber(ctrl:GetText()) then
                skill_cls = GetClassByType("Skill", tonumber(ctrl:GetText()))
                buff_manage.skill_id = tonumber(ctrl:GetText())
                ui.SysMsg(string.format(trans("skill_set"), skill_cls.Name))
            else
                ctrl:SetText("")
                buff_manage.skill_id = 0
            end
        end

        muteki2ex_skill_list()
    end
    muteki2ex_setting_frame_init()
    muteki2ex_save_settings()

    local my_handle = session.GetMyHandle()
    if g.settings.buff_list and type(g.settings.buff_list) == "table" then
        for buff_id_str, buff_data in pairs(g.settings.buff_list) do
            local buff_id = tonumber(buff_id_str)
            local info_buff = info.GetBuff(my_handle, buff_id)
            if info_buff then

                if not_notify[buff_id_str] and g.settings.buff_list[buff_id_str].not_notify[g.cid] then

                    muteki2ex_BUFF_ON_MSG("", "BUFF_REMOVE", "dummy", buff_id)
                else
                    muteki2ex_BUFF_ON_MSG("", "BUFF_REMOVE", "", buff_id)
                    muteki2ex_BUFF_ON_MSG("", "BUFF_ADD", "", buff_id)
                    muteki2ex_BUFF_ON_MSG("", "BUFF_UPDATE", "", buff_id)
                end
            end
        end
    end
end

function muteki2ex_delete_buff(frame, ctrl, buff_name, buff_id)

    local ctrl_name = ctrl:GetName()
    if ctrl_name == "buff_pic" then
        g.settings.buff_list[tostring(buff_id)] = nil
        ui.SysMsg(string.format(trans("delete_buff"), buff_name))
    end
    muteki2ex_save_settings()
    muteki2ex_setting_frame_init()
    muteki2ex_BUFF_ON_MSG("", "BUFF_REMOVE", "dummy", buff_id)
end

function muteki2ex_skill_list_close(frame, ctrl, str, num)
    -- frame:ShowWindow(0)
    ui.DestroyFrame(frame:GetName())
end
-- 最中

function muteki2ex_skill_list_search(frame, ctrl, str, buff_id)

    local search_edit = GET_CHILD_RECURSIVELY(frame, "search_edit")
    local ctrl_text = search_edit:GetText()
    if ctrl_text ~= "" then
        muteki2ex_skill_list_open(frame, ctrl, ctrl_text, buff_id)
    else
        muteki2ex_skill_list_open(frame, ctrl, "", buff_id)
    end
end

function muteki2ex_skill_list_open(frame, add, ctrl_text, buff_id)

    local skill_list_frame_name = addon_name_lower .. "skill_list_frame"
    local skill_list_frame = ui.GetFrame(skill_list_frame_name)

    if not skill_list_frame then

        skill_list_frame = ui.CreateNewFrame("notice_on_pc", skill_list_frame_name, 0, 0, 10, 10)
        AUTO_CAST(skill_list_frame)
        skill_list_frame:SetSkinName("test_frame_low")
        skill_list_frame:Resize(500, 1005)
        skill_list_frame:SetPos(610, 30)
        skill_list_frame:SetLayerLevel(121)

        --[[local id_edit = skill_list_frame:CreateOrGetControl('edit', 'id_edit', 20, 15, 80, 30)
        AUTO_CAST(id_edit)
        id_edit:SetNumberMode(1)
        id_edit:SetFontName("white_16_ol")
        id_edit:SetTextAlign("center", "center")
        id_edit:SetText("")
        id_edit:SetEventScript(ui.ENTERKEY, 'muteki2ex_add_skill')
        id_edit:SetEventScriptArgString(ui.ENTERKEY, ctrl:GetUserValue("SWITCH"))
        -- id_edit:SetTextTooltip(trans("add_buffid"))]]

        local title_text = skill_list_frame:CreateOrGetControl('richtext', 'itle_text', 15, 15, 10, 30)
        AUTO_CAST(title_text)
        title_text:SetText("{#000000}{s20}Skill List")

        local search_edit = skill_list_frame:CreateOrGetControl("edit", "search_edit", title_text:GetWidth() + 30, 10,
            305, 38)
        AUTO_CAST(search_edit)
        search_edit:SetFontName("white_18_ol")
        search_edit:SetTextAlign("left", "center")
        search_edit:SetSkinName("inventory_serch")
        search_edit:SetEventScript(ui.ENTERKEY, "muteki2ex_skill_list_search")
        search_edit:SetEventScriptArgNumber(ui.ENTERKEY, buff_id)

        local search_btn = search_edit:CreateOrGetControl("button", "search_btn", 0, 0, 40, 38)
        AUTO_CAST(search_btn)
        search_btn:SetImage("inven_s")
        search_btn:SetGravity(ui.RIGHT, ui.TOP)
        search_btn:SetEventScript(ui.LBUTTONUP, "muteki2ex_skill_list_search")

        local close_button = skill_list_frame:CreateOrGetControl('button', 'close_button', 0, 0, 20, 20)
        AUTO_CAST(close_button)
        close_button:SetImage("testclose_button")
        close_button:SetGravity(ui.RIGHT, ui.TOP)
        close_button:SetEventScript(ui.LBUTTONUP, "muteki2ex_skill_list_close");
    end

    local skill_list_gb = skill_list_frame:CreateOrGetControl("groupbox", "skill_list_gb", 10, 50, 480,
        skill_list_frame:GetHeight() - 60)
    AUTO_CAST(skill_list_gb)
    skill_list_gb:SetSkinName("bg")
    skill_list_gb:RemoveAllChild()

    local cls_list, count = GetClassList("Skill")

    local y = 0
    for i = 0, count - 1 do
        local skill_cls = GetClassByIndexFromList(cls_list, i)
        if skill_cls then
            local skill_id = skill_cls.ClassID
            local skill_cls_name = skill_cls.ClassName
            local skill_engname = skill_cls.EngName
            local skill_caption = skill_cls.Caption
            local skill_name = dictionary.ReplaceDicIDInCompStr(skill_cls.Name)
            if ctrl_text == "" or (ctrl_text ~= "" and string.find(skill_name, ctrl_text)) then
                local skill_slot = skill_list_gb:CreateOrGetControl('slot', 'skill_slot' .. i, 10, y + 5, 30, 30)
                AUTO_CAST(skill_slot)
                local image_name = "icon_" .. skill_cls.Icon

                if skill_id > 10000 then

                    if not string.find(skill_cls_name, "^Mon_") and not string.find(skill_engname, "plzInputEngName") and
                        not string.find(skill_name, "_") and not string.find(skill_name, "TEST") then
                        if ctrl_text == "" or (ctrl_text ~= "" and string.find(skill_name, ctrl_text)) then
                            SET_SLOT_IMG(skill_slot, image_name)
                            local icon = CreateIcon(skill_slot)
                            AUTO_CAST(icon)
                            SET_SKILL_TOOLTIP_BY_TYPE(icon, skill_id)
                            local skill_set = skill_list_gb:CreateOrGetControl('button', 'skill_set' .. skill_id, 45,
                                y + 5, 40, 30)
                            AUTO_CAST(skill_set)
                            skill_set:SetText("{ol}Add")
                            skill_set:SetSkinName("test_cardtext_btn")
                            skill_set:SetTextTooltip(trans("add_new_skill"))
                            skill_set:SetEventScript(ui.LBUTTONUP, "muteki2ex_add_skill")
                            skill_set:SetEventScriptArgNumber(ui.LBUTTONUP, skill_id)
                            skill_set:SetEventScriptArgString(ui.LBUTTONUP, tostring(buff_id))

                            local skill_text = skill_list_gb:CreateOrGetControl('richtext', 'skill_text' .. skill_id,
                                90, y + 10, 200, 30)
                            AUTO_CAST(skill_text)
                            skill_text:SetText("{ol}" .. skill_id .. " : " .. skill_name)
                            skill_text:AdjustFontSizeByWidth(380)
                            y = y + 35
                        end
                    end
                end
            end
        end

    end
    skill_list_frame:ShowWindow(1)
end

function muteki2ex_add_skill(frame, ctrl, buff_id_str, skill_id)

    local ctrl_name = ctrl:GetName()
    if ctrl_name == "id_edit" then
        skill_id = tonumber(ctrl:GetText()) or ""
    end
    local setting_frame = ui.GetFrame(addon_name_lower .. "_setting_frame")
    local list = GET_CHILD_RECURSIVELY(setting_frame, 'list' .. buff_id_str)
    local skill_edit = GET_CHILD(list, "skill_edit")
    skill_edit:SetText(skill_id)
    local switch = skill_edit:GetUserValue("SWITCH")

    muteki2ex_setting_change(frame, skill_edit, switch, tonumber(buff_id_str))

end

function muteki2ex_buff_list_close(frame, ctrl, str, num)
    -- frame:ShowWindow(0)
    ui.DestroyFrame(frame:GetName())
end

function muteki2ex_buff_list_search(frame, ctrl, str, num)

    local search_edit = GET_CHILD_RECURSIVELY(frame, "search_edit")
    local ctrl_text = search_edit:GetText()
    if ctrl_text ~= "" then
        muteki2ex_buff_list_open(frame, ctrl, ctrl_text)
    else
        muteki2ex_buff_list_open(frame, ctrl, "")
    end
end

function muteki2ex_buff_list_open(frame, ctrl, ctrl_text, num)

    local buff_list_frame_name = addon_name_lower .. "buff_list_frame"
    local buff_list_frame = ui.GetFrame(buff_list_frame_name)

    if not buff_list_frame then

        buff_list_frame = ui.CreateNewFrame("notice_on_pc", buff_list_frame_name, 0, 0, 10, 10)
        AUTO_CAST(buff_list_frame)
        buff_list_frame:SetSkinName("test_frame_low")
        buff_list_frame:Resize(500, 1005)
        buff_list_frame:SetPos(610, 30)
        buff_list_frame:SetLayerLevel(121)

        local id_edit = buff_list_frame:CreateOrGetControl('edit', 'id_edit', 20, 15, 80, 30)
        AUTO_CAST(id_edit)
        id_edit:SetNumberMode(1)
        id_edit:SetFontName("white_16_ol")
        id_edit:SetTextAlign("center", "center")
        id_edit:SetText("")
        id_edit:SetEventScript(ui.ENTERKEY, 'muteki2ex_add_buff')
        id_edit:SetTextTooltip(trans("add_buffid"))

        local search_edit = buff_list_frame:CreateOrGetControl("edit", "search_edit", id_edit:GetWidth() + 40, 10, 305,
            38)
        AUTO_CAST(search_edit)
        search_edit:SetFontName("white_18_ol")
        search_edit:SetTextAlign("left", "center")
        search_edit:SetSkinName("inventory_serch")
        search_edit:SetEventScript(ui.ENTERKEY, "muteki2ex_buff_list_search")

        local search_btn = search_edit:CreateOrGetControl("button", "search_btn", 0, 0, 40, 38)
        AUTO_CAST(search_btn)
        search_btn:SetImage("inven_s")
        search_btn:SetGravity(ui.RIGHT, ui.TOP)
        search_btn:SetEventScript(ui.LBUTTONUP, "muteki2ex_buff_list_search")

        local close_button = buff_list_frame:CreateOrGetControl('button', 'close_button', 0, 0, 20, 20)
        AUTO_CAST(close_button)
        close_button:SetImage("testclose_button")
        close_button:SetGravity(ui.RIGHT, ui.TOP)
        close_button:SetEventScript(ui.LBUTTONUP, "muteki2ex_buff_list_close");
    end

    local buff_list_gb = buff_list_frame:CreateOrGetControl("groupbox", "buff_list_gb", 10, 50, 480,
        buff_list_frame:GetHeight() - 60)
    AUTO_CAST(buff_list_gb)
    buff_list_gb:SetSkinName("bg")
    buff_list_gb:RemoveAllChild()

    local cls_list, count = GetClassList("Buff")

    local y = 0
    for i = 0, count - 1 do
        local buff_cls = GetClassByIndexFromList(cls_list, i)
        if buff_cls then
            local buff_id = buff_cls.ClassID
            local buff_name = dictionary.ReplaceDicIDInCompStr(buff_cls.Name)
            if ctrl_text == "" or (ctrl_text ~= "" and string.find(buff_name, ctrl_text)) then
                local buff_slot = buff_list_gb:CreateOrGetControl('slot', 'buffslot' .. i, 10, y + 5, 30, 30)
                AUTO_CAST(buff_slot)

                local image_name = GET_BUFF_ICON_NAME(buff_cls)
                if image_name == "icon_None" then
                    image_name = "icon_item_nothing"
                end

                if buff_name ~= "None" then

                    SET_SLOT_IMG(buff_slot, image_name)

                    local icon = CreateIcon(buff_slot)
                    AUTO_CAST(icon)
                    icon:SetTooltipType('buff');
                    icon:SetTooltipArg(buff_name, buff_id, 0);

                    local buff_set = buff_list_gb:CreateOrGetControl('button', 'buff_set' .. buff_id, 45, y + 5, 40, 30)
                    AUTO_CAST(buff_set)
                    buff_set:SetText("{ol}Add")
                    buff_set:SetSkinName("test_cardtext_btn")
                    buff_set:SetTextTooltip(trans("add_new"))
                    buff_set:SetEventScript(ui.LBUTTONUP, "muteki2ex_add_buff")
                    buff_set:SetEventScriptArgString(ui.LBUTTONUP, buff_id)

                    local buff_text = buff_list_gb:CreateOrGetControl('richtext', 'buff_text' .. buff_id, 90, y + 10,
                        200, 30)
                    AUTO_CAST(buff_text)
                    buff_text:SetText("{ol}" .. buff_id .. " : " .. buff_name)
                    buff_text:AdjustFontSizeByWidth(380)
                    y = y + 35
                end
            end
        end

    end
    buff_list_frame:ShowWindow(1)
end

function muteki2ex_add_buff(frame, ctrl, buff_id_str, num)

    local ctrl_name = ""
    if type(ctrl) == "string" then
        ctrl_name = ctrl
    else
        ctrl_name = ctrl:GetName()
    end
    local buff_id_process = nil
    if ctrl_name == "id_edit" then
        buff_id_process = ctrl:GetText()
        ctrl:SetText("")
    elseif string.find(ctrl_name, "buff_set") then
        buff_id_process = buff_id_str
    elseif ctrl_name == "buff_edit" then
        buff_id_process = ctrl:GetText()
    elseif string.find(ctrl_name, "slot") then
        buff_id_process = buff_id_str
    end

    if buff_id_process and buff_id_process ~= "" then
        local buff_id_num = tonumber(buff_id_process)
        local buff_cls = GetClassByType("Buff", buff_id_num)
        if buff_cls then
            g.settings.buff_list[buff_id_process] = {
                ["circle_icon"] = false,
                ["effect_check"] = 0,
                ["not_notify"] = {},
                ["count_display"] = false,
                ["pt_chat"] = false,
                ["nico_chat"] = 0,
                ["end_sound"] = "None",
                ["color"] = "FFCCCC22"
            }
            ui.SysMsg(string.format(trans("add_buff"), buff_cls.Name))
        else
            return
        end
    end

    if ctrl_name == "buff_edit" and buff_id_str ~= "" then
        g.settings.buff_list[tostring(buff_id_str)] = nil
        local buff_cls = GetClassByType("Buff", tonumber(buff_id_str))
        if buff_cls then
            ui.SysMsg(string.format(trans("delete_buff"), buff_cls.Name))
        end
    end

    muteki2ex_save_settings()
    muteki2ex_load_settings()
    if not string.find(ctrl_name, "slot") then
        g.cur_pos = buff_id_process
        muteki2ex_setting_frame_init()
    end
end

--[[function muteki2ex_test(sorted_buff_list)
    if not sorted_buff_list or #sorted_buff_list == 0 then
        print("  (リストは空です)")
    else
        for i, entry in ipairs(sorted_buff_list) do
            print(string.format("\n[%d] buff_id = %d, data = {", i, entry.buff_id))
            if entry.data and type(entry.data) == "table" then
                for key, value in pairs(entry.data) do
                    if type(value) == "table" then
                        print(string.format("    [%s] = %s", tostring(key), json.encode(value)))
                    else
                        print(string.format("    [%s] = %s", tostring(key), tostring(value)))
                    end
                end
            end
            print("  }")
        end
    end
end]]

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
