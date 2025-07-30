-- v2.0.1 アイコンモード追加。
-- v2.0.2 オバロ火の権能対応したか？
-- v2.0.3 ゲージの色設定やりやすくなったけどアイコンモードで使うという自己矛盾
-- v2.0.4 アイコン回転モード追加
-- v2.0.5 with effect機能復活
-- v2.0.6 PTチャットでDICデータバグってたの修正
local addon_name = "Muteki2ex_rebuild"
local addon_name_upper = string.upper(addon_name)
local addon_name_lower = string.lower(addon_name)
local org_ver = "1.2.7"
local ver = "2.0.6"

local author = "WRIT"
local maintainer = "norisan"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addon_name_upper] = _G["ADDONS"][author][addon_name_upper] or {}
local g = _G["ADDONS"][author][addon_name_upper]

local json = require("json")
local acutil = require('acutil')

local OVERLOAD_BUFF_IDS = {
    [4483] = true,
    [4757] = true
}
local DEFAULT_COLOR = "FFCCCC22"
g.translations = {
    etc = {
        gaugeDescription = '{#000000}Show gauges below specific buff time (in seconds){/}',
        positionMode = '{#000000}Position Mode{/}',
        lockText = '{#000000}Lock{/}',
        layerLvlText = '{#000000}Layer{nl}Level{/}',
        rotateIcons = '{#000000}Display in icon mode{/}',
        addBuff = 'MUTEKI2 - Added %s in settings',
        deleteBuff = 'MUTEKI2 - Removed %s in settings',
        colorTone = '{#000000}Color Tone{/}',
        hideGauge = 'MUTEKI2 - Hide gauge with remaining time more than %d seconds',
        isNotNotify = "{#000000}Hide with this character{/}",
        pt_chat = "{#000000}Notify buffs via PT chat{/}",
        functionNotice = "{#FFFFFF}{ol}Register by leftclick on the buff slot{nl}in the upper left corner of the screen.{/}",
        iconrotate = "{#000000}Icon Rotate{/}",
        effect = "{#000000}With effect{/}"
    },
    Japanese = {
        gaugeDescription = '{#000000}指定されたバフの時間を超えている場合は隠されています(秒){/}',
        positionMode = '{#000000}ポジションモード{/}',
        lockText = '{#000000}ロック{/}',
        layerLvlText = '{#000000}{s14}レイヤー{nl}レベル{/}',
        rotateIcons = '{#000000}アイコンモードで表示{/}',
        addBuff = 'MUTEKI2に%sを追加しました.',
        deleteBuff = "MUTEKI2の%sを削除しました.",
        colorTone = '{#000000}カラートーン{/}',
        hideGauge = 'MUTEKI2 - %d秒以上のバフは非表示になります',
        isNotNotify = "{#000000}このキャラクターでは表示しない{/}",
        pt_chat = "{#000000}バフをPTチャットでお知らせ{/}",
        functionNotice = "{#FFFFFF}{ol}画面左上バフスロットを{nl}左クリックでも登録出来ます。{/}",
        iconrotate = "{#000000}アイコン回転{/}",
        effect = "{#000000}エフェクト付与{/}"
    },
    kr = {
        gaugeDescription = "{#000000}설정된 초 이상 남은 버프 숨기기{/}",
        positionMode = "{#000000}버프 표시 모드{/}",
        lockText = "{#000000}잠금{/}",
        layerLvlText = "{#000000}레이어{nl}레벨{/}",
        rotateIcons = "{#000000}아이콘 모드로 표시{/}",
        addBuff = "MUTEKI2 - %s 버프를 추가했습니다.",
        deleteBuff = "MUTEKI2 - %s 버프를 삭제했습니다.",
        colorTone = "{#000000}색상{/}",
        hideGauge = "MUTEKI2 - %d초 이상 남은 버프는 표시하지 않습니다.",
        isNotNotify = "{#000000}이 캐릭터에서 숨기기{/}",
        pt_chat = "{#000000}PT 채팅으로 버프를 알려드립니다{/}",
        functionNotice = "{#FFFFFF}{ol}화면 왼쪽 상단의 버프 슬롯을{nl}왼쪽 클릭으로도 등록할 수 있습니다.{/}",
        iconrotate = "{#000000}아이콘 회전{/}",
        effect = "{#000000}효과 적용{/}"
    }
}

local color_tbl = {
    [1] = 'FFFFFF00', -- 黄色
    [2] = 'FFFFD700', -- ゴールド
    [3] = 'FFFF4500', -- オレンジ
    [4] = 'FF00FF00', -- ライムグリーン
    [5] = 'FF008000', -- 緑
    [6] = 'FF00BFFF', -- スカイブルー
    [7] = 'FF0000FF', -- 青
    [8] = 'FF800080', -- 紫
    [9] = "FFFF1493", -- ピンク
    [10] = "FFFF0000" -- 赤
}

local lang_code = option.GetCurrentCountry()
local function _translate(key)
    local localization = g.translations[lang_code] or g.translations["etc"]
    return localization[key] or "Translation not provided"
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

    -- g.settings_path = string.format("../addons/%s/%s/settings.json", addon_name_lower, g.active_id)

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
        return nil, "Error opening file: " .. path
    end

    local content = file:read("*all")
    file:close()

    if not content or content == "" then
        return nil, "File content is empty or could not be read: " .. path
    end

    local decoded_table, decode_err = json.decode(content)

    if not decoded_table then
        return nil, decode_err
    end

    return decoded_table, nil
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

g.mkdir_new_folder()

g.settings_path = string.format("../addons/%s/settings.json", addon_name_lower)

if not g.loaded then
    local settings = g.load_json(g.settings_path)
    -- local settings = acutil.loadJSON(g.settings_path)
    if not settings then
        settings = {
            enable = true,
            mode = "fixed",
            pos = {
                lock = false,
                x = 640,
                y = 480
            },
            buff_list = {},
            hidden_buff_time = 300,
            layer_level = 80
        }
        g.save_json(g.settings_path, g.settings)
    end
    g.settings = settings
    g.loaded = true

end

function muteki2_rebuild_ON_INIT(addon, frame)
    g.addon = addon
    g.frame = frame
    g.gauge = {}
    g.circle = {}
    g.cid = session.GetMySession():GetCID()
    g.REGISTER = {}

    frame:ShowWindow(0)

    addon:RegisterMsg("BUFF_ADD", "muteki2_rebuild_UPDATE_BUFF")
    addon:RegisterMsg("BUFF_UPDATE", "muteki2_rebuild_UPDATE_BUFF")
    addon:RegisterMsg("BUFF_REMOVE", "muteki2_rebuild_UPDATE_BUFF")

    frame:SetEventScript(ui.RBUTTONDOWN, "muteki2_rebuild_CONTEXT_MENU")
    frame:SetEventScript(ui.LBUTTONUP, "muteki2_rebuild_END_DRAG")

    muteki2_rebuild_CHANGE_MODE()
    muteki2_rebuild_INIT_FRAME(frame)

    if g.settings.enable then
        frame:ShowWindow(1)
        frame:Resize(300, 200)
    else
        frame:ShowWindow(0)
    end

    frame:Move(0, 0)
    frame:SetOffset(g.settings.pos.x, g.settings.pos.y)

end

-- メインロジック (イベントハンドラ)
local over_cd = 0
function muteki2_rebuild_UPDATE_BUFF(frame, msg, str, buff_id)
    local buff_setting, buff_obj, buff = muteki2_rebuild_GET_BUFFS(buff_id)
    if not (buff_setting and not buff_setting.no_notify[g.cid]) then
        return
    end

    local control = muteki2_rebuild_GET_CONTROL(buff_id)
    if not control then
        return
    end

    local buff_name = dictionary.ReplaceDicIDInCompStr(buff_obj.Name)

    if buff_setting.is_circle then
        if msg == 'BUFF_REMOVE' then
            if buff_setting.pt_chat then
                ui.Chat(string.format("/p %s end", buff_name))
            end
            muteki2_rebuild_REMOVE_CIRCLE_BUFF(buff, control)
        else
            if msg == 'BUFF_ADD' then
                if buff_setting.pt_chat then
                    ui.Chat(string.format("/p %s start", buff_name))
                end
                if buff_setting.play_effect then
                    local actor = world.GetActor(session.GetMyHandle())
                    pcall(effect.PlayActorEffect, actor, "F_sys_TPBOX_great_300", "None", 1.0, 6.0)
                end
            end
            muteki2_rebuild_ADD_CIRCLE_BUFF(buff, control)
        end
    else -- Gauge
        if msg == 'BUFF_REMOVE' then
            if buff_setting.pt_chat then
                ui.Chat(string.format("/p %s end", buff_name))
            end
            if OVERLOAD_BUFF_IDS[buff_id] then
                muteki2_rebuild_OVERLOAD_COOLDOWN(buff_id, control)
                over_cd = 1
            else
                muteki2_rebuild_REMOVE_GAUGE_BUFF(buff, control)
            end
        else -- BUFF_ADD or BUFF_UPDATE
            if msg == 'BUFF_ADD' then
                if buff_setting.pt_chat then
                    ui.Chat(string.format("/p %s start", buff_name))
                end
                if buff_setting.play_effect then
                    local actor = world.GetActor(session.GetMyHandle())
                    pcall(effect.PlayActorEffect, actor, "F_sys_TPBOX_great_300", "None", 1.0, 6.0)
                end
            end
            if OVERLOAD_BUFF_IDS[buff_id] then
                muteki2_rebuild_OVERLOAD_START(buff_id, control, buff)
                over_cd = 0
            else
                muteki2_rebuild_ADD_GAUGE_BUFF(buff, control)
            end
        end
    end
    muteki2_rebuild_UPDATE_POSITIONS()
end

function muteki2_rebuild_CONTEXT_MENU(frame, msg, clicked_group_name, num)
    local context = ui.CreateContextMenu("muteki2_rebuild_RBTN", addon_name, 0, 0, 150, 100)

    ui.AddContextMenuItem(context, g.settings.pos.lock and "Release Lock" or "Lock Position",
                          "muteki2_rebuild_TOGGLE_LOCK()")

    context:Resize(150, context:GetHeight())
    ui.OpenContextMenu(context)
end

function muteki2_rebuild_END_DRAG()
    g.settings.pos.x = g.frame:GetX()
    g.settings.pos.y = g.frame:GetY()
    muteki2_rebuild_SAVE_SETTINGS()
end

-- UI更新・描画ロジック
function muteki2_rebuild_UPDATE_POSITIONS()
    local circle_list, gauge_list, no_time_buffs = {}, {}, {}
    local offset_y, circle_icon_height = 25, 50

    for buff_id, ctrl in pairs(g.circle) do
        local buff_setting = muteki2_rebuild_GET_BUFF_SETTING(buff_id)
        if ctrl:IsVisible() == 1 and buff_setting and not buff_setting.no_notify[g.cid] then
            table.insert(circle_list, ctrl)
        end
    end

    for buff_id, ctrl in pairs(g.gauge) do
        local buff_setting = muteki2_rebuild_GET_BUFF_SETTING(buff_id)

        if ctrl:IsVisible() == 1 and buff_setting and not buff_setting.no_notify[g.cid] then
            local buff = muteki2_rebuild_GET_BUFF(tonumber(buff_id))
            if buff then
                if buff_setting.is_no_time then
                    table.insert(no_time_buffs, ctrl)
                else
                    table.insert(gauge_list, {
                        gauge = ctrl,
                        time = buff.time
                    })
                end
            end
        end
    end

    local max_len = #circle_list
    if #circle_list > 0 then
        for i, circle in ipairs(circle_list) do
            circle:SetOffset(-25 * (max_len - 1) + (i - 1) * 50, 0)
        end
    end
    if #gauge_list > 0 then
        table.sort(gauge_list, function(a, b)
            return (a.time < b.time)
        end)
        for i, obj in ipairs(gauge_list) do
            obj.gauge:SetGravity(ui.CENTER_HORZ, ui.TOP)
            obj.gauge:SetOffset(0, (i - 1 + over_cd) * offset_y + circle_icon_height)
        end
    end

    if #no_time_buffs > 0 then
        local default_offset_y = #gauge_list * offset_y + circle_icon_height
        for i, ctrl in ipairs(no_time_buffs) do
            ctrl:SetGravity(0, 0)
            ctrl:SetOffset(19 + (i - 1) % 2 * 131, math.floor((i - 1) / 2 + over_cd) * (offset_y - 5) + default_offset_y)
            ctrl:SetPoint(60, 60)
        end
    end
    local height = circle_icon_height + (#gauge_list + math.floor(#no_time_buffs / 2)) * offset_y + 20
    g.frame:Resize(300, (height < 200) and 200 or height + 20)
end

function muteki2_rebuild_ADD_GAUGE_BUFF(buff, frame)
    local gauge = frame
    local time = math.floor(buff.time / 1000)
    local buff_setting = muteki2_rebuild_GET_BUFF_SETTING(buff.buffID)
    if time == 0 then
        buff_setting.is_no_time = true
    else
        buff_setting.is_no_time = false
        muteki2_rebuild_START_GAUGE_DOWN(gauge, time, time + 1)
    end
    gauge:ShowWindow(1)
    muteki2_rebuild_UPDATE_POSITIONS()
end

function muteki2_rebuild_REMOVE_GAUGE_BUFF(buff, frame)
    local gauge = frame
    gauge:ShowWindow(0)
    gauge:StopUpdateScript("muteki2_rebuild_UPDATE_GAUGE_DOWN")
    muteki2_rebuild_UPDATE_POSITIONS()
end

function muteki2_rebuild_ADD_CIRCLE_BUFF(buff, frame)
    local image = frame
    image:ShowWindow(1)
    if g.settings.use_rotate == 1 then
        image:SetAngleLoop(5)
    end
    muteki2_rebuild_ADD_CIRCLE_BUFF_TIMEUPDATE(buff, image)

    muteki2_rebuild_UPDATE_POSITIONS()
end

function muteki2_rebuild_REMOVE_CIRCLE_BUFF(buff, frame)
    local image = frame
    image:ShowWindow(0)

    muteki2_rebuild_UPDATE_POSITIONS()
end

function muteki2_rebuild_START_GAUGE_DOWN(gauge, cur_point, max_point)

    gauge:ShowWindow(1)

    if not cur_point or not max_point then
        cur_point = gauge:GetCurPoint()
        max_point = gauge:GetMaxPoint()
    end

    local elapsed_ms = (max_point - cur_point) * 1000
    local start_time = imcTime.GetAppTimeMS() - elapsed_ms
    gauge:SetUserValue("STARTTIME", start_time)
    gauge:SetUserValue("PAUSE", 0)
    gauge:SetTotalTime(max_point)

    gauge:SetPoint(max_point - cur_point, max_point)
    gauge:StopTimeProcess()

    gauge:RunUpdateScript("muteki2_rebuild_UPDATE_GAUGE_DOWN")
end

function muteki2_rebuild_UPDATE_GAUGE_DOWN(gauge)

    local elapsed_ms = imcTime.GetAppTimeMS() - gauge:GetUserIValue("STARTTIME")
    local pause = gauge:GetUserIValue("PAUSE")
    local max_point = gauge:GetMaxPoint()
    local cur_point = elapsed_ms ~= 0 and max_point - elapsed_ms / 1000 or max_point
    gauge:SetPoint(cur_point, max_point)

    local sec = math.floor(cur_point)
    local m_sec = math.floor((cur_point - sec) * 100)

    if sec < 0 then
        gauge:ShowWindow(0)
        return 0
    end

    local text = "{@st48}00.00{/}"

    if sec >= 0 then
        text = pause ~= 1 and string.format("{@st48}%02d.%02d{/}", sec, m_sec) or
                   string.format("{@st48}{#00FF00}%02d.%02d{/}{/}", sec, m_sec)
    end

    gauge:SetTextStat(0, text)

    if pause == 1 then
        return 0
    end
    local should_show = sec <= g.settings.hidden_buff_time
    if gauge:IsVisible() ~= should_show then
        gauge:ShowWindow(should_show)
        muteki2_rebuild_UPDATE_POSITIONS()
    end

    return 1
end

function _muteki2_rebuild_ADD_CIRCLE_BUFF_TIMEUPDATE(time)
    local buff_id = time:GetUserIValue("BUFF_ID")
    local buff = muteki2_rebuild_GET_BUFF(buff_id)

    if buff == nil then
        return 0
    end

    local cur_time = buff.time
    local setting_time = g.settings.hidden_buff_time * 1000

    if cur_time <= 0 or cur_time >= setting_time then
        time:ShowWindow(0)
        return 0
    end

    time:ShowWindow(1)
    if cur_time <= 60000 and cur_time >= 10000 then
        time:SetText(string.format('{@st43}%.1f', cur_time / 1000))
    elseif cur_time < 10000 and cur_time >= 5000 then
        time:SetText(string.format('{@st43}{#FF4500}%.1f', cur_time / 1000))
    elseif cur_time <= 5000 then
        time:SetText(string.format('{@st43}{#FF0000}%.1f', cur_time / 1000))
    else
        local minutes = math.floor(cur_time / 60000)
        time:SetText(string.format("{@st43}%d%s", minutes, "min"))
    end
    time:AdjustFontSizeByWidth(45)
    return 1
end

function muteki2_rebuild_ADD_CIRCLE_BUFF_TIMEUPDATE(buff, frame)

    local time = frame:CreateOrGetControl("richtext", "time", 0, 0, 50, 50)
    AUTO_CAST(time)
    time:SetGravity(ui.CENTER_HORZ, ui.CENTER_VERT)
    frame:ShowWindow(1)

    time:SetUserValue("BUFF_ID", buff.buffID)

    time:RunUpdateScript("_muteki2_rebuild_ADD_CIRCLE_BUFF_TIMEUPDATE", 0.1)

end

function muteki2_rebuild_OVERLOAD_START(buff_id, frame, buff)
    local gauge = frame
    local time = math.floor(buff.time / 1000)
    local buff_setting = muteki2_rebuild_GET_BUFF_SETTING(buff_id)
    gauge:SetColorTone(buff_setting.color)
    buff_setting.is_no_time = false
    muteki2_rebuild_START_GAUGE_DOWN(gauge, time, time + 1)

    gauge:ShowWindow(1)
    muteki2_rebuild_UPDATE_POSITIONS()
end

function muteki2_rebuild_OVERLOAD_COOLDOWN(buff_id, frame)
    local gauge = frame
    local time = math.floor(20)
    local buff_setting = muteki2_rebuild_GET_BUFF_SETTING(buff_id)

    gauge:SetColorTone('FFFFFFFF')

    buff_setting.is_no_time = false
    muteki2_rebuild_START_GAUGE_DOWN(gauge, time, time + 1)

    gauge:ShowWindow(1)
    muteki2_rebuild_UPDATE_POSITIONS()
end

-- UI生成ロジック
function muteki2_rebuild_INIT_FRAME(frame)

    frame:RemoveAllChild()
    frame:CreateOrGetControl('richtext', 'disableAutoHide', 0, 0, 1, 1):SetText('   ')
    g.circle = {}
    g.gauge = {}

    frame:SetLayerLevel(g.settings.layer_level)

    for buff_id, buff_setting in pairs(g.settings.buff_list) do
        local buff_obj = GetClassByType('Buff', tonumber(buff_id))
        if buff_obj then

            muteki2_rebuild_CREATE_CONTROL(buff_id, buff_obj, buff_setting)
        end
    end
end

function muteki2_rebuild_CREATE_CONTROL(buff_id, buff_obj, buff_setting)
    if buff_setting.is_circle then
        g.circle[tostring(buff_id)] = muteki2_rebuild_INIT_CIRCLE(g.frame, buff_obj)
    else
        g.gauge[tostring(buff_id)] = muteki2_rebuild_INIT_GAUGE(g.frame, buff_obj, buff_setting.color)
    end
end

function muteki2_rebuild_INIT_CIRCLE(frame, buff_obj)
    local image = frame:CreateOrGetControl("picture", "circle_" .. buff_obj.ClassName, 0, 0, 50, 50)
    AUTO_CAST(image)

    image:ShowWindow(0)
    image:SetGravity(ui.CENTER_HORZ, ui.TOP)
    image:SetImage('icon_' .. buff_obj.Icon)
    image:SetEnableStretch(1)
    image:EnableHitTest(0)
    return image
end

function muteki2_rebuild_INIT_GAUGE(frame, buff_obj, color_tone)
    local gauge = frame:CreateOrGetControl("gauge", "gauge_" .. buff_obj.ClassName, 0, 0, 262, 20)
    AUTO_CAST(gauge)

    gauge:SetSkinName('muteki2_gauge_white')
    gauge:SetColorTone(color_tone or 'FFFF0000')
    gauge:ShowWindow(0)
    gauge:SetGravity(ui.CENTER_HORZ, ui.TOP)
    gauge:SetUserValue("PAUSE", 1)
    gauge:EnableHitTest(0)

    gauge:AddStat("")
    gauge:SetStatOffset(0, 60, 0)

    gauge:SetStatAlign(0, ui.RIGHT, ui.CENTER_HORZ)

    gauge:AddStat("{@st62}" .. buff_obj.Name .. "{/}")

    gauge:SetStatAlign(1, ui.CENTER_HORZ, ui.CENTER_HORZ)
    gauge:SetStatOffset(1, 0, -2)

    return gauge
end

-- 設定フレーム初期化 (muteki2_rebuild_setting_ON_INITから呼ばれる)
function muteki2_rebuild_INIT_SETTING_UI()
    g.setup_hook_and_event(g.addon, 'SET_BUFF_SLOT', "muteki2_rebuild_SET_BUFFICON_LBTNCLICK", true)
    -- acutil.setupEvent(g.addon, 'SET_BUFF_SLOT', "muteki2_rebuild_SET_BUFFICON_LBTNCLICK")
    acutil.addSysIcon("muteki2ex", "sysmenu_skill", "muteki2ex", "muteki2_rebuild_FRAME_OPEN")
    g.is_setting_ui_created = false
end

function muteki2_rebuild_FRAME_OPEN(cmd)
    if g.setting_frame:IsVisible() == 0 then
        g.setting_frame:ShowWindow(1)

        if not g.is_setting_ui_created then
            muteki2_rebuild_CREATE_SETTING_FRAME()
            g.is_setting_ui_created = true
        end
    else
        g.setting_frame:ShowWindow(0)
    end
end

function muteki2_rebuild_UPDATE_CONTROL(buff_id)
    buff_id = tostring(buff_id)
    local frame = g.frame
    local buff_setting, buff_obj, buff = muteki2_rebuild_GET_BUFFS(buff_id)

    local old_control = muteki2_rebuild_GET_CONTROL(buff_id)
    if old_control then
        frame:RemoveChild(old_control:GetName())
        g.gauge[buff_id] = nil
        g.circle[buff_id] = nil
    end

    if buff_obj == nil then
        return
    end

    muteki2_rebuild_CREATE_CONTROL(buff_id, buff_obj, buff_setting)

    local new_control = muteki2_rebuild_GET_CONTROL(buff_id)
    if new_control and buff and not buff_setting.no_notify[g.cid] then
        if buff_setting.is_circle then
            muteki2_rebuild_ADD_CIRCLE_BUFF(buff, new_control)
        else
            muteki2_rebuild_ADD_GAUGE_BUFF(buff, new_control)
        end
    end
    muteki2_rebuild_UPDATE_POSITIONS()
end

function muteki2_rebuild_CREATE_SETTING_FRAME()

    local frame = g.setting_frame
    local buff_time_txt = AUTO_CAST(frame:GetChild('buffTimeText'))
    buff_time_txt:SetMargin(20, -20, 0, 0)
    buff_time_txt:SetText(_translate('gaugeDescription'))

    local mode_txt = AUTO_CAST(frame:GetChild('modeText'))
    mode_txt:SetText(_translate('positionMode'))
    frame:GetChild(g.settings.mode .. 'modeBtn'):SetSkinName('test_red_button')

    local is_lock = g.settings.pos.lock
    local lock_mode_btn = frame:GetChild('lockmodeBtn')
    lock_mode_btn:SetSkinName(is_lock and 'test_cardtext_btn' or 'textbutton')
    lock_mode_btn:SetText(is_lock and '{s20}ON{/}' or '{s20}OFF{/}')

    local lock_txt = AUTO_CAST(frame:GetChild('lockText'))
    lock_txt:SetText(_translate('lockText'))

    local buff_time_edit = frame:CreateOrGetControl('edit', 'buffTimeEdit', 495, -10, 70, 25)
    AUTO_CAST(buff_time_edit)

    buff_time_edit:SetNumberMode(1)
    buff_time_edit:SetOffsetYForDraw(-5)
    buff_time_edit:SetOffsetXForDraw(10)
    buff_time_edit:SetText(g.settings.hidden_buff_time or 0)
    buff_time_edit:SetEventScript(ui.ENTERKEY, 'muteki2_rebuild_SET_HIDDEN_BUFF_TIME')
    buff_time_edit:SetMargin(495, -20, 0, 0)

    local layer_lvl_txt = AUTO_CAST(frame:GetChild('layerLvlText'))
    layer_lvl_txt:SetText(_translate('layerLvlText'))

    local layer_lvl_edit = frame:CreateOrGetControl('edit', 'layerLvlEdit', 515, 30, 50, 25)
    AUTO_CAST(layer_lvl_edit)

    layer_lvl_edit:SetNumberMode(1)
    layer_lvl_edit:SetOffsetYForDraw(-5)
    layer_lvl_edit:SetOffsetXForDraw(10)
    layer_lvl_edit:SetText(g.settings.layer_level or 80)
    layer_lvl_edit:SetEventScript(ui.ENTERKEY, 'muteki2_rebuild_SET_LAYER_LAVEL')

    local icon_rotate = frame:CreateOrGetControl('richtext', 'icon_rotate', 20, 10, 0, 0)
    AUTO_CAST(icon_rotate)
    icon_rotate:SetText(_translate('iconrotate'))

    local rotate = frame:CreateOrGetControl('checkbox', 'rotate', 130, 8, 20, 20)
    AUTO_CAST(rotate)
    rotate:SetCheck(g.settings.use_rotate or 0)
    rotate:SetEventScript(ui.LBUTTONUP, "muteki2_rebuild_ROTATE_SET")

    local gbox = frame:GetChild('settingGbox')
    gbox:RemoveAllChild()
    local i = 1
    for buff_id, buff_setting in pairs(g.settings.buff_list) do
        buff_setting.no_notify = buff_setting.no_notify or {}
        muteki2_rebuild_CREATE_SETTING_LIST(frame, gbox, i, tonumber(buff_id), buff_setting)
        i = i + 1
    end
    muteki2_rebuild_CREATE_SETTING_LIST(frame, gbox, i, 0, {})
end

function muteki2_rebuild_CREATE_SETTING_LIST(frame, gbox, index, buff_id, buff_setting)
    local height = 155
    local buff = GetClassByType('Buff', buff_id)
    local list = gbox:CreateOrGetControl('groupbox', 'List' .. index, 15, 20 + (height + 5) * (index - 1), 515, height)
    list:SetSkinName("market_listbase")
    list:SetUserValue('buffid', buff_id)
    list:SetUserValue('index', index)

    local close_btn = list:CreateOrGetControl('button', 'closeBtn', 10, 20, 35, 35)
    close_btn:SetSkinName("test_red_button")
    close_btn:SetText("{s25}×")
    close_btn:SetEventScript(ui.LBUTTONUP, "muteki2_rebuild_DELETE_BUFFID")
    close_btn:SetEventScriptArgString(ui.LBUTTONUP, buff_id)

    local buff_pic = list:CreateOrGetControl('picture', 'buffPic', 60, 10, 55, 55)
    AUTO_CAST(buff_pic)

    buff_pic:SetEnableStretch(1)
    if buff and buff.Icon then
        buff_pic:SetImage('icon_' .. buff.Icon)
        buff_pic:SetTextTooltip(buff.Name)

        local buff_name_txt = list:CreateOrGetControl('richtext', 'buffnameTxt', 120, 10, 60, 30)
        buff_name_txt:SetText('{#000000}' .. buff.Name)
    end

    local buff_id_edit = list:CreateOrGetControl('edit', 'buffidEdit', 120, 35, 70, 30)
    AUTO_CAST(buff_id_edit)

    buff_id_edit:SetNumberMode(1)
    buff_id_edit:SetUserValue('index', index)
    buff_id_edit:SetOffsetYForDraw(-10)
    buff_id_edit:SetTextTooltip(_translate('functionNotice'))
    buff_id_edit:SetTextAlign("center", "center")
    buff_id_edit:SetText("{ol}" .. buff_id or '')
    buff_id_edit:SetLostFocusingScp('muteki2_rebuild_CHANGE_BUFFID')
    buff_id_edit:SetEventScript(ui.ENTERKEY, 'muteki2_rebuild_CHANGE_BUFFID')
    buff_id_edit:SetEventScriptArgString(ui.ENTERKEY, buff_id)

    local color_tone_pic = list:CreateOrGetControl('picture', 'colorTonePic', 320, 35, 50, 30)
    AUTO_CAST(color_tone_pic)
    color_tone_pic:SetEnableStretch(1)
    color_tone_pic:SetImage("chat_color")
    color_tone_pic:SetColorTone(buff_setting.color or DEFAULT_COLOR)

    local color_box = list:CreateOrGetControl('groupbox', "colorbox" .. index, 300, 70, 210, 30)
    AUTO_CAST(color_box)
    for i = 0, #color_tbl do
        local color_cls = color_tbl[i + 1]
        if color_cls ~= nil then
            local color = color_box:CreateOrGetControl("picture", "color" .. index .. "_" .. i, 20 * i, 0, 20, 20)
            AUTO_CAST(color)
            color:SetImage("chat_color")
            color:SetColorTone(color_cls)
            color:SetEventScript(ui.LBUTTONUP, "muteki2_rebuild_COLOR_SETTING_SAVE")
            color:SetEventScriptArgString(ui.LBUTTONUP, color_cls)
            color:SetEventScriptArgNumber(ui.LBUTTONUP, buff_id)

        end
    end

    local color_tone_edit = list:CreateOrGetControl('edit', 'colorToneEdit', 380, 35, 100, 30)
    AUTO_CAST(color_tone_edit)

    color_tone_edit:SetUserValue('index', index)
    color_tone_edit:SetOffsetYForDraw(-10)
    color_tone_edit:SetTextAlign("center", "center")
    color_tone_edit:SetMaxLen(8)
    color_tone_edit:SetText("{ol}{s16}" .. buff_setting.color and buff_setting.color or DEFAULT_COLOR)
    color_tone_edit:SetLostFocusingScp('muteki2_rebuild_CHANGE_COLORTONE')
    color_tone_edit:SetEventScriptArgString(15, buff_id)
    color_tone_edit:SetEventScript(ui.ENTERKEY, 'muteki2_rebuild_CHANGE_COLORTONE')
    color_tone_edit:SetEventScriptArgString(ui.ENTERKEY, buff_id)

    local color_tone_txt = list:CreateOrGetControl('richtext', 'colorToneTxt', 380, 10, 60, 30)
    color_tone_txt:SetText(_translate('colorTone'))

    local is_circle = list:CreateOrGetControl('checkbox', 'isCircle', 10, 65, 200, 35)
    AUTO_CAST(is_circle)

    is_circle:SetCheck(buff_setting.is_circle and 1 or 0)
    is_circle:SetEventScript(ui.LBUTTONDOWN, 'muteki2_rebuild_CHANGE_CIRCLE_MODE')
    is_circle:SetEventScriptArgNumber(ui.LBUTTONDOWN, buff_id)
    is_circle:SetText(_translate('rotateIcons'))

    buff_setting.no_notify = buff_setting.no_notify or {}
    local no_notify = list:CreateOrGetControl('checkbox', 'isNotNotify', 10, 90, 200, 35)
    AUTO_CAST(no_notify)

    no_notify:SetCheck(buff_setting.no_notify[g.cid] and 1 or 0)
    no_notify:SetEventScript(ui.LBUTTONDOWN, 'muteki2_rebuild_CHANGE_NOTIFY')
    no_notify:SetEventScriptArgNumber(ui.LBUTTONDOWN, buff_id)
    no_notify:SetText(_translate('isNotNotify'))

    local pt_chat = list:CreateOrGetControl('checkbox', 'pt_chat', 10, 115, 200, 35)
    AUTO_CAST(pt_chat)

    pt_chat:SetCheck(buff_setting.pt_chat and 1 or 0)
    pt_chat:SetEventScript(ui.LBUTTONDOWN, 'muteki2_rebuild_CHANGE_EFFECT')
    pt_chat:SetEventScriptArgNumber(ui.LBUTTONDOWN, buff_id)
    pt_chat:SetText(_translate('pt_chat'))

    local play_effect = list:CreateOrGetControl('checkbox', 'effect_check', 300, 115, 35, 35)
    AUTO_CAST(play_effect)
    play_effect:SetCheck(buff_setting.play_effect)
    play_effect:SetEventScript(ui.LBUTTONDOWN, 'muteki2_rebuild_CHANGE_EFFECT')
    play_effect:SetEventScriptArgNumber(ui.LBUTTONDOWN, buff_id)
    play_effect:SetText(_translate('effect'))
end

function muteki2_rebuild_ADD_BUFFID(frame, control, str, buff_id)
    if muteki2_rebuild_GET_BUFF_SETTING(buff_id) == nil then
        local buff_obj = GetClassByType('Buff', buff_id)
        g.settings.buff_list[tostring(buff_id)] = {
            color = DEFAULT_COLOR,
            no_notify = {}
        }

        local msg = string.format(_translate('addBuff'), buff_obj.Name)
        ui.SysMsg(msg)
        muteki2_rebuild_UPDATE_POSITIONS()
        muteki2_rebuild_UPDATE_CONTROL(buff_id)
        muteki2_rebuild_CREATE_SETTING_FRAME()
    end
end

function muteki2_rebuild_DELETE_BUFFID(list, control, buff_id, num)
    g.settings.buff_list[tostring(buff_id)] = nil

    ui.SysMsg(string.format(_translate('deleteBuff'), GetClassByType('Buff', buff_id).Name))

    local old_control = muteki2_rebuild_GET_CONTROL(buff_id)
    if old_control then
        g.frame:RemoveChild(old_control:GetName())
    end

    g.gauge[tostring(buff_id)] = nil
    g.circle[tostring(buff_id)] = nil

    muteki2_rebuild_CREATE_SETTING_FRAME()
end

function muteki2_rebuild_CHANGE_BUFFID(list, control, old_id, num)
    local new_id = tostring(control:GetText())
    local index = control:GetUserIValue('index')
    local buff = GetClassByType('Buff', tonumber(new_id))
    if old_id == new_id or not buff then
        return
    end

    local old_setting = muteki2_rebuild_GET_BUFF_SETTING(old_id)
    if old_id and old_setting then

        g.settings.buff_list[new_id] = {}
        for key, value in pairs(old_setting) do
            g.settings.buff_list[new_id][key] = value
        end

        g.settings.buff_list[tostring(old_id)] = nil

        local old_gauge = muteki2_rebuild_GET_CONTROL(old_id)
        if old_gauge then
            g.frame:RemoveChild(old_gauge:GetName())
            g.gauge[tostring(old_id)] = nil
        end
    else
        g.settings.buff_list[new_id] = {
            color = DEFAULT_COLOR
        }
    end
    muteki2_rebuild_CREATE_SETTING_FRAME()

    local new_buff_setting = muteki2_rebuild_GET_BUFF_SETTING(new_id)
    if new_buff_setting and not muteki2_rebuild_GET_CONTROL(new_id) then
        g.gauge[tostring(new_id)] = muteki2_rebuild_INIT_GAUGE(g.frame, buff, new_buff_setting.color)
    end

    local gauge = muteki2_rebuild_GET_CONTROL(new_id)
    if gauge then
        muteki2_rebuild_ADD_GAUGE_BUFF(muteki2_rebuild_GET_BUFF(new_id), gauge)
    end
end

function muteki2_rebuild_CHANGE_NOTIFY(list, control, is_checked, buff_id)
    local buff_setting = muteki2_rebuild_GET_BUFF_SETTING(buff_id)
    if buff_setting then
        buff_setting.no_notify = buff_setting.no_notify or {}
        buff_setting.no_notify[g.cid] = (control:IsChecked() == 1)
    end
    muteki2_rebuild_UPDATE_CONTROL(buff_id)
    muteki2_rebuild_SAVE_SETTINGS()
end

function muteki2_rebuild_CHANGE_EFFECT(list, control, is_checked, buff_id)
    local buff_setting = muteki2_rebuild_GET_BUFF_SETTING(buff_id)
    if buff_setting then
        if control:GetName() == "pt_chat" then
            buff_setting.pt_chat = (control:IsChecked() == 1)
        elseif control:GetName() == "effect_check" then
            buff_setting.play_effect = control:IsChecked()
        end
    end
    muteki2_rebuild_SAVE_SETTINGS()
end

function muteki2_rebuild_CHANGE_CIRCLE_MODE(list, control, is_checked, buff_id)
    local buff_setting = muteki2_rebuild_GET_BUFF_SETTING(buff_id)
    if buff_setting then
        buff_setting.is_circle = (control:IsChecked() == 1)
    end
    muteki2_rebuild_UPDATE_CONTROL(buff_id)
    muteki2_rebuild_SAVE_SETTINGS()
end

function muteki2_rebuild_CHANGE_COLORTONE(list, control, buff_id, num)
    local buff_setting = muteki2_rebuild_GET_BUFF_SETTING(buff_id)
    local new_color = tostring(control:GetText())
    local old_color = buff_setting.color
    if #new_color ~= 8 or new_color == old_color then
        return
    end
    buff_setting.color = new_color
    if not buff_setting.is_circle then
        local gauge = muteki2_rebuild_GET_CONTROL(buff_id)
        if gauge then
            gauge:SetSkinName('muteki2_gauge_white')
            gauge:SetColorTone(new_color)
        end
    end
    list:GetChild('colorTonePic'):SetColorTone(new_color)
    muteki2_rebuild_SAVE_SETTINGS()
end

function muteki2_rebuild_COLOR_SETTING_SAVE(frame, ctrl, str, num)
    local buff_setting = muteki2_rebuild_GET_BUFF_SETTING(num)
    if buff_setting then
        buff_setting.color = str
    end
    muteki2_rebuild_CREATE_SETTING_FRAME()
end

function muteki2_rebuild_SET_HIDDEN_BUFF_TIME(frame, control, str, num)
    local buff_time = tonumber(control:GetText())
    if buff_time > 0 and buff_time ~= g.settings.hidden_buff_time then
        g.settings.hidden_buff_time = buff_time
        ui.SysMsg(string.format(_translate('hideGauge'), buff_time))
        muteki2_rebuild_UPDATE_POSITIONS()
    end
end

function muteki2_rebuild_SET_LAYER_LAVEL(frame, control, str, num)
    local layer_lvl = tonumber(control:GetText())
    g.settings.layer_level = layer_lvl
    g.frame:SetLayerLevel(layer_lvl)
    muteki2_rebuild_SAVE_SETTINGS()
end

function muteki2_rebuild_ROTATE_SET(frame, ctrl, str, num)
    local is_check = ctrl:IsChecked()
    g.settings.use_rotate = is_check
    muteki2_rebuild_SAVE_SETTINGS()

end

function muteki2_rebuild_SET_BUFFICON_LBTNCLICK(my_frame, my_msg)
    -- local slot, capt, class, buff_type = acutil.getEventArgs(eventMsg)
    local slot, capt, class, buff_type = g.get_event_args(my_msg)
    AUTO_CAST(slot)

    slot:SetEventScript(ui.LBUTTONUP, 'muteki2_rebuild_ADD_BUFFID')
    slot:SetEventScriptArgNumber(ui.LBUTTONUP, buff_type)
    slot:SetEventScriptArgString(ui.LBUTTONUP, class.Name)
end

function muteki2_rebuild_CHANGE_MODE_BTN(frame, control, mode, num)
    local this_mode = g.settings.mode
    local before_mode_btn = frame:GetChild(this_mode .. 'modeBtn')
    before_mode_btn:SetSkinName('textbutton')
    control:SetSkinName('test_red_button')
    muteki2_rebuild_CHANGE_MODE(mode)
    local is_lock = g.settings.pos.lock
    local lock_mode_btn = frame:GetChild('lockmodeBtn')
    lock_mode_btn:SetSkinName(is_lock and 'test_cardtext_btn' or 'textbutton')
    lock_mode_btn:SetText(is_lock and '{s20}ON{/}' or '{s20}OFF{/}')
end

function muteki2_rebuild_CHANGE_LOCK_BTN(frame, control, str, num)
    muteki2_rebuild_TOGGLE_LOCK()
    local is_lock = g.settings.pos.lock
    local lock_mode_btn = frame:GetChild('lockmodeBtn')
    control:SetSkinName(is_lock and 'test_cardtext_btn' or 'textbutton')
    control:SetText(is_lock and '{s20}ON{/}' or '{s20}OFF{/}')
end

-- モード変更・表示切替
function muteki2_rebuild_CHANGE_MODE(mode)
    local frame = g.frame
    if not mode then
        mode = g.settings.mode
    end

    mode = string.lower(mode)
    if mode == "trace" then
        local handle = session.GetMyHandle()
        local actor = world.GetActor(handle)
        FRAME_AUTO_POS_TO_OBJ(frame, handle, -frame:GetWidth() / 2, -100, 3, 1)
        g.settings.pos.lock = true
    else
        frame:Move(0, 0)
        frame:SetOffset(g.settings.pos.x, g.settings.pos.y)
        frame:StopUpdateScript("_FRAME_AUTOPOS")
        mode = "fixed"
    end

    local txt = frame:CreateOrGetControl('richtext', 'disableAutoHide', 0, 0, 1, 1)
    if g.settings.pos.lock then
        g.frame:SetSkinName("none")
        g.frame:EnableHittestFrame(0)
        txt:SetText(' ')
    else
        g.frame:SetSkinName("shadow_box")
        g.frame:EnableHittestFrame(1)
        g.frame:EnableMove(1)
        txt:SetText('  ')
    end

    g.settings.mode = mode
    muteki2_rebuild_SAVE_SETTINGS()
    muteki2_rebuild_UPDATE_POSITIONS()
end

function muteki2_rebuild_TOGGLE_LOCK()
    local txt = g.frame:CreateOrGetControl('richtext', 'disableAutoHide', 0, 0, 1, 1)
    g.settings.pos.lock = not g.settings.pos.lock
    if g.settings.pos.lock then
        -- ロック
        g.frame:SetSkinName("none")
        g.frame:EnableHittestFrame(0)
        txt:SetText(' ')
        for k, gauge in pairs(g.gauge) do
            gauge:ShowWindow(0)
        end
    else
        -- ロック解除（移動モード）
        g.frame:SetSkinName("shadow_box")
        g.frame:EnableHittestFrame(1)
        g.frame:EnableMove(1)
        txt:SetText('  ')

    end

    muteki2_rebuild_SAVE_SETTINGS()

    if g.settings.pos.lock then
        CHAT_SYSTEM(string.format("[%s] save position", addon_name))
    end
end

function muteki2_rebuild_TOGGLE_FRAME()
    if g.frame:IsVisible() == 0 then

        g.frame:ShowWindow(1)
        g.settings.enable = true
    else

        g.frame:ShowWindow(0)
        g.settings.enable = false
    end

    muteki2_rebuild_SAVE_SETTINGS()
end

-- ヘルパー・共通関数
function muteki2_rebuild_SAVE_SETTINGS()
    g.save_json(g.settings_path, g.settings)
    -- acutil.saveJSON(g.settings_path, g.settings)
end

function muteki2_rebuild_GET_BUFFS(buff_id)
    buff_id = tonumber(buff_id)
    local buff_setting = g.settings.buff_list[tostring(buff_id)]
    local buff_obj = GetClassByType('Buff', buff_id)
    local handle = session.GetMyHandle()
    local buff = buff_id and info.GetBuff(handle, buff_id) or nil
    return buff_setting, buff_obj, buff
end

function muteki2_rebuild_GET_BUFF(id)
    local handle = session.GetMyHandle()
    local buff = info.GetBuff(handle, id)
    return buff
end

function muteki2_rebuild_GET_BUFF_SETTING(buff_id)

    if g.settings.buff_list == nil then
        return nil
    end
    return g.settings.buff_list[tostring(buff_id)]
end

function muteki2_rebuild_GET_CONTROL(buff_id)
    local buff_setting = muteki2_rebuild_GET_BUFF_SETTING(buff_id)
    if buff_setting == nil then
        return nil
    end

    if buff_setting.is_circle then
        return g.circle[tostring(buff_id)]
    else
        return g.gauge[tostring(buff_id)]
    end
end

--[[function muteki2_rebuild_CHANGE_COLORTONE(list, control, buff_id, num)
    local buff_setting = muteki2_rebuild_GET_BUFF_SETTING(buff_id)
    local new_color = tostring(control:GetText())
    local old_color = buff_setting.color
    if #new_color ~= 8 or new_color == old_color then
        return
    end
    buff_setting.color = new_color
    if not buff_setting.is_circle then
        local gauge = muteki2_rebuild_GET_CONTROL(buff_id)
        if gauge then
            gauge:SetSkinName('muteki2_gauge_white')
            gauge:SetColorTone(new_color)
        end
    end
    list:GetChild('colorTonePic'):SetColorTone(new_color)
    muteki2_rebuild_SAVE_SETTINGS()
end]]
--[[

-- チャットコマンド処理（acutil使用時）
function MUTEKI2_PROCESS_COMMAND(command)
    command = command or ''
    local cmd = ""

    if #command > 0 then
        cmd = string.lower(table.remove(command, 1))
    else
        local msg = "Muteki2 説明{nl}"
        msg = msg .. "/muteki2 lock{nl}"
        msg = msg .. "位置のロック{nl}"
        msg = msg .. "/muteki2 trace{nl}"
        msg = msg .. "自キャラ追従モード{nl}"
        msg = msg .. "/muteki2 fixed{nl}"
        msg = msg .. "固定表示モード{nl}"
        CHAT_SYSTEM(msg)
        return
    end

    if cmd == "lock" then
        MUTEKI2_CHANGE_MODE("fixed")
        MUTEKI2_TOGGLE_LOCK()
        return
    elseif cmd == "trace" then
        MUTEKI2_CHANGE_MODE("trace")
        CHAT_SYSTEM(string.format("[%s] trace mode", addon_name))
        return
    elseif cmd == "fixed" then
        MUTEKI2_CHANGE_MODE("fixed")
        CHAT_SYSTEM(string.format("[%s] fixed mode", addon_name))
        return
    end

    CHAT_SYSTEM(string.format("[%s] Invalid Command", addon_name))
end
function MUTEKI2_EXEC_EFFECT(buff, status)
    local handle = session.GetMyHandle()
    local actor = world.GetActor(handle)
    local buff_cls = GetClassByType('Buff', buff.buffID) -- beef -> buff_cls
    if status == 1 then
        -- ui.Chat(string.format("/p I got %s", buff_cls.Name))
    else
        ui.Chat(string.format("/p My %s done", buff_cls.Name)) -- beef -> buff_cls
    end
end]]
--[[function MUTEKI2_SET_POINT(gauge, cur_point, play) -- curPoint -> cur_point
    local max_point = gauge:GetMaxPoint() -- maxPoint -> max_point
    gauge:SetPoint(cur_point, max_point) -- curPoint -> cur_point, maxPoint -> max_point

    if play then
        gauge:SetPointWithTime(max_point, max_point - cur_point, 1) -- maxPoint -> max_point, curPoint -> cur_point
    else
        gauge:StopTimeProcess()
    end
end]]
