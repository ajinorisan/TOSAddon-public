-- v0.0.4 フレームのコンテキストが上手く動かなかったの修正
-- v0.0.5 新規のチャットはTOTALフレームで処理されるらしいので、そこを排他しない様に。
-- v1.0.0 気になったところは直したから正式版
-- v1.0.1 ギアスコアランク作成、週ボスの所に表示、ヴェルニケ表も翻訳、ペット名翻訳
-- v1.0.2 ギアスコアランク初期化されるの直したハズ
-- v1.0.3 色々。一旦あげ
-- v1.0.4 ギアスコア取るところでnilが出てバグってたの修正
-- v1.0.5 チャットモード切替機能。名前とチャットを分離して軽くしたつもり。
-- v1.0.6 翻訳モード切替修正。/でバグってたらしいので修正
-- v1.0.7 個別翻訳
-- v1.0.8 滅茶苦茶速くなって軽くなった。
-- v1.0.9 自分の発言を翻訳
-- v1.1.0 deep_translator使ってAPIで軽く早くした
-- v1.1.1 英語版バグってたの修正
-- v1.1.2 名前の最後に半角入れたら削除しない様に変更。PT名翻訳
-- v1.1.3 コロニー周り強化。他バグ修正
-- v1.1.4 名前の最後の半角の所バグってたので修正。韓国語入力モード追加。
local addon_name = "NATIVE_LANG"
local addon_name_lower = string.lower(addon_name)
local author = "norisan"
local ver = "1.1.4"
local exe = "0.0.6"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addon_name] = _G["ADDONS"][author][addon_name] or {}
local g = _G["ADDONS"][author][addon_name]

local acutil = require("acutil")
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

    local folder = string.format("../addons/%s", addon_name_lower)
    local file_path = string.format("../addons/%s/mkdir.txt", addon_name_lower)
    create_folder(folder, file_path)

    g.active_id = session.loginInfo.GetAID()
    local user_folder = string.format("../addons/%s/%s", addon_name_lower, g.active_id)
    local user_file_path = string.format("../addons/%s/%s/mkdir.txt", addon_name_lower, g.active_id)
    create_folder(user_folder, user_file_path)

end
g.mkdir_new_folder()

g.settings_path = string.format("../addons/%s/%s/settings.json", addon_name_lower, g.active_id)
g.send_msg = string.format('../addons/%s/send_msg.dat', addon_name_lower)
g.recv_msg = string.format('../addons/%s/recv_msg.dat', addon_name_lower)
g.send_name = string.format('../addons/%s/send_name.dat', addon_name_lower)
g.recv_name = string.format('../addons/%s/recv_name.dat', addon_name_lower)
g.restart = string.format('../addons/%s/restart.dat', addon_name_lower)
g.gear_score = string.format('../addons/%s/gear_score.dat', addon_name_lower)
g.my_send_dat_path = "../addons/native_lang/my_send.dat"
g.my_recv_dat_path = "../addons/native_lang/my_recv.dat"

g.food_aids_path = string.format("../addons/%s/food_aids.json", addon_name_lower)

local base = {}

function g.SetupHook(func, baseFuncName)
    local addonUpper = string.upper(addon_name)
    local replacementName = addonUpper .. "_BASE_" .. baseFuncName
    if (_G[replacementName] == nil) then
        _G[replacementName] = _G[baseFuncName]
        _G[baseFuncName] = func
    end
    base[baseFuncName] = _G[replacementName]
end

local function WITH_HANGLE(str)
    for _, code in utf8.codes(str) do
        if code >= 0xAC00 and code <= 0xD7A3 then
            return true
        end
    end
    return false
end

local function WITH_JAPANESE(str)
    for _, code in utf8.codes(str) do
        if (code >= 0x3040 and code <= 0x309F) or -- ひらがな
        (code >= 0x30A0 and code <= 0x30FF) or -- カタカナ
        (code >= 0x4E00 and code <= 0x9FFF) or -- CJK統合漢字 (基本)
        (code >= 0x3400 and code <= 0x4DBF) or -- CJK統合漢字拡張A
        (code >= 0x20000 and code <= 0x2A6DF) or -- CJK統合漢字拡張B
        (code >= 0xF900 and code <= 0xFAFF) then -- CJK互換漢字

            return true
        end
    end
    return false
end

local function WITH_ENGLISH(str)
    for _, code in utf8.codes(str) do
        if (code >= 0x41 and code <= 0x5A) or -- 'A' ～ 'Z'
        (code >= 0x61 and code <= 0x7A) then -- 'a' ～ 'z'
            return true
        end
    end
    return false
end

function g.log_to_file(message)

    local file_path = string.format("../addons/%s/%s/log.txt", addon_name_lower, g.active_id)
    local file = io.open(file_path, "a")
    if file then
        local timestamp = os.date("[%Y-%m-%d %H:%M:%S] ")
        file:write(timestamp .. tostring(message) .. "\n")
        file:close()
    end
end

local function native_lang_is_translation(str)
    if g.lang == "ja" then
        return WITH_HANGLE(str)
    elseif g.lang == "ko" then
        return WITH_JAPANESE(str)
    elseif g.lang == "en" then
        return WITH_HANGLE(str) or WITH_JAPANESE(str)
    end
    return false
end

local function native_lang_is_translation_msg(msg)
    if g.lang == "ja" then
        return WITH_HANGLE(msg) or WITH_ENGLISH(msg)
    elseif g.lang == "ko" then
        return WITH_JAPANESE(msg) or WITH_ENGLISH(msg)
    elseif g.lang == "en" then
        return WITH_HANGLE(msg) or WITH_JAPANESE(msg)
    end
    return false
end

local function native_lang_process_name(clean_name)

    if string.find(clean_name, "PartyMemberMapNChannel", 1, true) then
        return clean_name
    elseif string.find(clean_name, "★★", 1, true) then
        return clean_name
    end

    if g.names[clean_name] then
        return g.names[clean_name]
    end

    if g.sent_names and g.sent_names[clean_name] then
        return clean_name
    end

    if native_lang_is_translation(clean_name) then

        local append_file = io.open(g.send_name, "a")
        if append_file then
            append_file:write(clean_name .. ":::" .. clean_name .. "\n")
            append_file:close()
            g.sent_names[clean_name] = true
        end
    end

    return clean_name
end

local function native_lang_format_chat_message(frame, msg_type, right_name, msg, org_msg, chat_id)

    local msg_type_map = {
        Normal = 1,
        Shout = 2,
        Party = 3,
        Guild = 4,
        System = 7,
        GuildNotice = 4
    }

    local font_size = tonumber(GET_CHAT_FONT_SIZE())
    local chat_type_id = msg_type_map[msg_type]
    if chat_type_id then
        local font_style = frame:GetUserConfig("TEXTCHAT_FONTSTYLE_" .. msg_type:upper())
        if font_style == "None" then
            font_style = "{#FF44FF}{b}{ol}"
        end
        local msg_front = ""
        msg_front = string.format("[%s]%s : %s", ScpArgMsg("ChatType_" .. chat_type_id), right_name, msg)
        return msg_front, font_style, font_size
    else
        local font_style = ""
        if msg_type == "" then
            msg_type = "Battle"
        end

        if msg_type == "GuildNotice" then
            font_style = "{#FF44FF}{b}{ol}"
        elseif msg_type == "Whisper" then
            local cluster_name = "cluster_" .. chat_id
            local cluster = GET_CHILD_RECURSIVELY(frame, cluster_name)
            if cluster then
                local text = GET_CHILD(cluster, "text")
                local room_id = text:GetUserValue("ROOM_ID")
                local color_type = session.chat.GetRoomConfigColorType(room_id)
                local color_cls = GetClassByType("ChatColorStyle", color_type)
                if color_cls then
                    font_style = "{#" .. color_cls.TextColor .. "}{ol}"
                else
                    font_style = "{#00FFFF}{b}{ol}"
                end
            end
        elseif msg_type == "guildmem" then
            font_style = "{#A566FF}{b}{ol}"
        elseif msg_type == "partymem" then
            font_style = "{#86E57F}{b}{ol}"
        end
        local msg_front
        if msg_type == "guildmem" or msg_type == "partymem" then
            msg_front = string.format(font_style .. "%s", msg)
        elseif msg_type == "GuildNotice" and string.find(org_msg, "GuildNotice{msg}") then
            local ex_msg = "!@#$GuildNotice{msg}$*$msg$*$" .. msg .. "#@!"
            msg_front = string.format("%s : %s", right_name, ex_msg)
        elseif msg_type == "Whisper" then
            local cluster_name = "cluster_" .. chat_id

            local cluster = GET_CHILD_RECURSIVELY(frame, cluster_name)
            if cluster then
                local text = GET_CHILD(cluster, "text")
                local room_id = text:GetUserValue("ROOM_ID")
                local info = session.chat.GetByStringID(room_id)
                local target_name = info:GetWhisperTargetName()
                local pattern = "^(.-)："
                local prefix = string.match(text:GetText(), pattern)
                if g.names[target_name] then
                    prefix = string.gsub(prefix, target_name, g.names[target_name])
                end
                msg_front = string.format("%s : %s", prefix, msg)
            end
        elseif msg_type == "Battle" then
            msg_front = string.format("%s", msg)
        else
            msg_front = string.format("%s : %s", right_name, msg)
        end
        return msg_front, font_style, font_size
    end
    return nil, nil, nil
end

local function native_lang_is_link_only(msg)
    if string.find(msg, "{img link_party 24 24}") then
        return false
    end
    if not msg:match("^{a%s+.*{/}$") then
        return false
    end
    if msg:match("{/}.+{a%s+") then
        return false
    end
    return true
end

function native_lang_write_to_recv_dat(chatframe)

    if not g.temp_msg or #g.temp_msg == 0 then
        return 0
    end

    local temp_tbl = {}
    local file = io.open(g.recv_msg, "a")
    if file then

        for i, data in ipairs(g.temp_msg) do
            local line_to_write = string.format("%s:::%s:::%s:::%s:::%s:::%s", data.chat_id, data.msg_type,
                data.trans_msg, "None", data.org_msg, data.name)

            if not g.last_written_line or g.last_written_line ~= line_to_write then
                file:write(line_to_write .. "\n")
                g.last_written_line = line_to_write
            end
            local data_to_queue = {
                chat_id = data.chat_id,
                frame_name = data.frame_name,
                gbox_name = data.gbox_name
            }
            if data.org_msg ~= " " then
                table.insert(g.ui_update_queue, data_to_queue)
            end
        end

        g.temp_msg = nil
        file:close()
        return 0
    end

    return 1
end

local function utf8_len(s)
    local _, count = s:gsub("[\128-\191]", "")
    return string.len(s) - count
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

function native_lang_load_settings()
    local settings = g.load_json(g.settings_path)
    local lang_map = {
        Japanese = "ja",
        kr = "ko"
    }
    local current_lang_key = option.GetCurrentCountry()
    g.lang = lang_map[current_lang_key] or "en"

    if not settings then
        settings = {
            use = 1,
            lang = g.lang,
            recv_lang = "en",
            chatmode = false
        }
    else
        if not settings.recv_lang then
            settings.recv_lang = "en"
        end
        if not settings.chatmode then
            settings.chatmode = false
        end
    end
    g.settings = settings
    native_lang_save_settings()

end

function native_lang_save_settings()
    g.save_json(g.settings_path, g.settings)
end

function NATIVE_LANG_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame
    g.REGISTER = {}
    g.language = option.GetCurrentCountry()

    g.name_len = 0
    g.chat_ids = {}
    g.ui_update_queue = {}
    g.names = {}
    g.sent_names = {}
    g.gear_scores = {}
    g.last_written_line = ""
    -- tos_google_translate無効化
    if type(_G["TOS_GOOGLE_TRANSLATE_ON_INIT"]) == "function" then
        _G["TOS_GOOGLE_TRANSLATE_ON_INIT"] = nil
    end
    -- koja_name_tarnslater無効化
    if type(_G["KOJA_NAME_TRANSLATER_ON_INIT"]) == "function" then
        _G["KOJA_NAME_TRANSLATER_ON_INIT"] = nil
    end
    -- WBREXTEND無効化
    if type(_G["WBREXTEND_ON_INIT"]) == "function" then
        _G["WBREXTEND_ON_INIT"] = nil
    end

    native_lang_load_settings()

    addon:RegisterMsg("GAME_START", "native_lang_GAME_START")
    addon:RegisterMsg("GAME_START_3SEC", "native_lang_GAME_START_3SEC")
    -- addon:RegisterMsg("FPS_UPDATE", "native_lang_PARTYINFO_UPDATE")
    addon:RegisterMsg("PARTY_UPDATE", "native_lang_PARTYINFO_UPDATE")
    addon:RegisterMsg("PARTY_BUFFLIST_UPDATE", "native_lang_PARTYINFO_UPDATE")
    addon:RegisterMsg("PARTY_INST_UPDATE", "native_lang_PARTYINFO_UPDATE")

end

function native_lang_GAME_START(frame)

    local chatframe = ui.GetFrame("chatframe")
    local tabgbox = GET_CHILD_RECURSIVELY(chatframe, "tabgbox")
    local trans_btn = tabgbox:CreateOrGetControl("button", "trans_btn", 270, -1, 30, 30)
    AUTO_CAST(trans_btn)
    if g.settings.use == 0 then
        trans_btn:SetSkinName('test_gray_button')
        trans_btn:SetTextTooltip(g.language == "Japanese" and "Native Lang 停止中{nl}左クリック: 設定" or
                                     "{ol}Native Lang is suspended{nl}Left click to setting")
    elseif g.settings.use == 1 then
        trans_btn:SetSkinName("test_red_button")
        trans_btn:SetTextTooltip(g.language == "Japanese" and "Native Lang 起動中{nl}左クリック: 設定" or
                                     "{ol}Native Lang in use{nl}Left click to setting")
    end

    trans_btn:SetText("{ol}{s14}{#FFFFFF}" .. g.lang)
    trans_btn:SetEventScript(ui.LBUTTONUP, "native_lang_context")

    if not g.start then
        local exe_path = "../addons/native_lang/native_lang-v" .. exe .. ".exe"

        local file = io.open(exe_path, "r")
        if file then

            file:close()
            local active_id = session.loginInfo.GetAID()
            local command = string.format('start "" /min "%s" %s', exe_path, tostring(active_id))
            os.execute(command)
            g.start = true
            print("Native Lang: 実行ファイルを起動しました。")

        else

            local tar_path = "../addons/native_lang/native_lang-v" .. exe .. ".tar"
            local tar_file = io.open(tar_path, "r")

            if tar_file then

                tar_file:close()
                print("実行ファイルが見つかりません。.tarファイルを解凍します...")

                local output_dir = "../addons/native_lang"
                local tar_command = string.format('tar -xf "%s" -C "%s"', tar_path, output_dir)
                local result = os.execute(tar_command)

                if result then

                    print("解凍に成功しました。実行ファイルを起動します。")
                    local command = string.format('start "" /min "%s"', exe_path)
                    os.execute(command)
                    g.start = true
                else

                    print("tarファイルの解凍に失敗しました。")
                    ui.SysMsg("[Native Lang] .tar file extraction failed.")
                end
            else
                local required_file_name = string.format("native_lang-v%s.exe (or .tar)", exe)

                local msg_jp = string.format(
                    "[Native Lang] 実行ファイルが見つかりません！{nl}addons/native_lang フォルダに、{nl}「%s」を配置してください。",
                    required_file_name)
                local msg_en = string.format(
                    "[Native Lang] Executable file not found!{nl}Please place '%s' in the addons/native_lang folder.",
                    required_file_name)
                ui.SysMsg(g.language == "Japanese" and msg_jp or msg_en)
            end
        end
    end
end

function native_lang_GAME_START_3SEC()

    g.setup_hook_and_event(g.addon, "PARTY_OPEN", "native_lang_PARTY_OPEN", true)
    g.setup_hook_and_event(g.addon, "SET_PARTYINFO_ITEM", "native_lang_SET_PARTYINFO_ITEM", true)
    g.setup_hook_and_event(g.addon, "WEEKLY_BOSS_RANK_UPDATE", "native_lang_WEEKLY_BOSS_RANK_UPDATE", true)
    g.setup_hook_and_event(g.addon, "SHOW_PC_COMPARE", "native_lang_SHOW_PC_COMPARE", true)
    g.setup_hook_and_event(g.addon, "ON_EVENTBANNER_GEARSCORE", "native_lang_ON_EVENTBANNER_GEARSCORE", true)
    g.setup_hook_and_event(g.addon, "DRAW_CHAT_MSG", "native_lang_DRAW_CHAT_MSG", true)

    g.setup_hook_and_event(g.addon, "CHAT_CLOSE_SCP", "native_lang_CHAT_CLOSE_SCP", true)
    g.setup_hook_and_event(g.addon, "CHAT_OPEN_INIT", "native_lang_CHAT_OPEN_INIT", true)

    g.setup_hook_and_event(g.addon, "UI_CHAT", "native_lang_UI_CHAT", false)

    g.SetupHook(native_lang_ON_COLONYWAR_GUILD_KILL_MSG, "ON_COLONYWAR_GUILD_KILL_MSG")
    g.SetupHook(native_lang_DAMAGE_METER_GAUGE_SET, "DAMAGE_METER_GAUGE_SET")
    g.SetupHook(native_lang_UPDATE_COMPANION_TITLE, "UPDATE_COMPANION_TITLE")
    g.SetupHook(native_lang_GEAR_SCORE_RANKING_CREATE_INFO, "GEAR_SCORE_RANKING_CREATE_INFO")
    g.SetupHook(native_lang_SOLODUNGEON_RANKINGPAGE_FILL_RANK_CTRL, "SOLODUNGEON_RANKINGPAGE_FILL_RANK_CTRL")
    g.SetupHook(native_lang_GUILDINFO_MEMBER_LIST_CREATE, "GUILDINFO_MEMBER_LIST_CREATE")
    g.SetupHook(native_lang_GUILDNOTICE_GET, "GUILDNOTICE_GET")
    g.SetupHook(native_lang_GUILDINFO_INIT_PROFILE, "GUILDINFO_INIT_PROFILE")

    if not g.load then
        local files_to_reset = {g.send_name, g.send_msg, g.recv_msg}
        for _, file_path in ipairs(files_to_reset) do
            local file = io.open(file_path, "w")
            if file then
                file:close()
            end
        end
        g.load = true
    end
    local lines_to_keep = {}
    local name_file = io.open(g.recv_name, "r")
    if name_file then
        local content = name_file:read("*a")
        name_file:close()
        for line in string.gmatch(content, "[^\r\n]+") do
            local separator_count = 0
            for _ in string.gmatch(line, ":::") do
                separator_count = separator_count + 1
            end
            if separator_count == 1 then
                local org_name, trans_name = line:match("^(.-):::(.*)$")
                if org_name and trans_name then
                    local clean_trans_name = ""
                    if trans_name:find("{#FF0000}★{/}", 1, true) then
                        clean_trans_name = trans_name:gsub("{#FF0000}★{/}", "")
                    end
                    if clean_trans_name and not org_name:find("Party#", 1, true) and
                        not org_name:find("파티#", 1, true) then
                        if not native_lang_is_translation(clean_trans_name) or clean_trans_name:match("%s$") then
                            if clean_trans_name:match("%s$") then
                                table.insert(lines_to_keep, line)
                            else
                                g.names[org_name] = trans_name
                                table.insert(lines_to_keep, line)
                            end
                        end
                    else
                        table.insert(lines_to_keep, line)
                    end
                    -- separator_count != 1 の行もファイルに維持
                else
                    table.insert(lines_to_keep, line)
                end
            end
        end

        name_file = io.open(g.recv_name, "w")
        if name_file then
            local content_to_write = table.concat(lines_to_keep, "\n")
            if #lines_to_keep > 0 then
                content_to_write = content_to_write .. "\n"
            end
            name_file:write(content_to_write)
            name_file:close()
        end
    else
        name_file = io.open(g.recv_name, "w")
        if name_file then
            name_file:close()
        end
    end

    local sent_name_file = io.open(g.send_name, "r")
    if sent_name_file then
        local content = sent_name_file:read("*a")
        sent_name_file:close()
        for line in string.gmatch(content, "[^\r\n]+") do
            local key = line:match("^(.-):::")
            if key then
                g.sent_names[key] = true
            end
        end
    end

    local seen_keys = {}
    local gear_score_file = io.open(g.gear_score, "r")
    if gear_score_file then
        for line in gear_score_file:lines() do
            local org_name, teamName, guildIdx, value = line:match("([^:]+):::(%S+):::(%d+):::(%d+)")
            if org_name and teamName and guildIdx and value then
                if not seen_keys[org_name] then
                    if native_lang_is_translation(teamName) and not g.names[org_name] then
                        teamName = native_lang_process_name(org_name)
                    end
                    table.insert(g.gear_scores, {org_name, g.names[org_name] or teamName, guildIdx, tonumber(value)})
                    seen_keys[org_name] = true
                end
            end
        end
        gear_score_file:close()
    else
        gear_score_file = io.open(g.gear_score, "w")
        if gear_score_file then
            gear_score_file:close()
        end
    end

    local recv_msg_file = io.open(g.recv_msg, "r")
    if recv_msg_file then
        g.first_chatid = nil
        for line in recv_msg_file:lines() do

            local chat_id, msg_type, trans_msg, sep, org_msg, org_name = line:match(
                "^(.-):::(.-):::(.-):::(.-):::(.-):::(.*)$")

            if chat_id then
                if not g.first_chatid then
                    g.first_chatid = chat_id
                end
                g.chat_ids[chat_id] = {
                    msg_type = msg_type,
                    trans_msg = trans_msg,
                    org_msg = org_msg,
                    separate_msg = sep,
                    name = (g.names and g.names[org_name]) or org_name,
                    org_name = org_name
                }
            end
        end
        recv_msg_file:close()
    end

    local chatframe = ui.GetFrame("chatframe")

    chatframe:RunUpdateScript("native_lang_check_my_speech", 0.1)
    chatframe:RunUpdateScript("native_lang_name_update", 1.0)
    chatframe:RunUpdateScript("native_lang_periodic_update", 0.1)
    native_lang_force_full_redraw()
end

function native_lang_periodic_update(chatframe)

    native_lang_chat_recv()
    native_lang_replace()

    if g.retry_queue and next(g.retry_queue) then
        local remove = {}
        for chat_id, separate_msg in pairs(g.retry_queue) do

            local pattern = "{img link_party 24 24},%s*{(.-)}%s*,"

            local party_name = separate_msg:match(pattern)

            if native_lang_is_translation(party_name) then

                native_lang_process_name(party_name)

                if g.names[party_name] then

                    table.insert(remove, chat_id)
                    local trans_name = g.names[party_name]:gsub("{#FF0000}★{/}", "")

                    local parts = {}
                    for part in separate_msg:gmatch("([^,]+)") do

                        table.insert(parts, part)
                    end
                    for i, part in ipairs(parts) do
                        if part == "{" .. party_name .. "}" then
                            parts[i] = trans_name
                            break
                        end
                    end
                    local last_str = table.concat(parts, "")
                    last_str = string.gsub(last_str, "パーティー", "Party")
                    local trans_msg = g.chat_ids[chat_id].trans_msg .. last_str
                    local msg_type = g.chat_ids[chat_id].msg_type
                    local name = g.chat_ids[chat_id].name
                    local org_msg = g.chat_ids[chat_id].org_msg
                    local msg_front, font_style, font_size =
                        native_lang_format_chat_message(chatframe, msg_type, name, trans_msg, org_msg, chat_id)
                    if msg_front then
                        native_lang_chat_replace(chatframe, msg_front, font_style, font_size, chat_id)
                    end
                    g.temp_msg = g.temp_msg or {}
                    local data_to_write = {
                        chat_id = tostring(chat_id),
                        trans_msg = trans_msg,
                        org_msg = " ",
                        frame_name = "chatframe",
                        gbox_name = g.gbox_name,
                        msg_type = msg_type,
                        name = name
                    }
                    table.insert(g.temp_msg, data_to_write)
                    chatframe:StopUpdateScript("native_lang_write_to_recv_dat")
                    chatframe:RunUpdateScript("native_lang_write_to_recv_dat", 0.1)
                end
            else
                table.insert(remove, chat_id)
            end
        end

        for i, remove_id in ipairs(remove) do
            g.retry_queue[remove_id] = nil
        end
    end
    return 1
end

function native_lang_chat_recv(frame)

    local has_update = false
    local recv_file = io.open(g.recv_msg, "r")
    if not recv_file then
        return 1
    end

    local content = recv_file:read("*a")
    recv_file:close()

    if not content or content == "" then
        return 1
    end

    for line in string.gmatch(content, "[^\r\n]+") do
        local chat_id, msg_type, trans_msg, sep, org_msg, org_name = line:match(
            "^(.-):::(.-):::(.-):::(.-):::(.-):::(.*)$")

        if chat_id then
            local chat_id_str = tostring(chat_id)

            if g.chat_ids[chat_id_str] and g.chat_ids[chat_id_str].trans_msg == "" then
                g.chat_ids[chat_id_str].trans_msg = trans_msg
                g.chat_ids[chat_id_str].name = (g.names and g.names[org_name]) or org_name
                local data_to_queue = {
                    chat_id = tostring(chat_id),
                    frame_name = "chatframe",
                    gbox_name = g.gbox_name
                }
                table.insert(g.ui_update_queue, data_to_queue)
                has_update = true
            end
        end
    end
    return 1
end

function native_lang_replace_separate_msg(separate_msg, chat_id)

    if separate_msg:find("{img link_party 24 24}") then
        g.retry_queue = g.retry_queue or {}
        g.retry_queue[chat_id] = separate_msg
    end
    separate_msg = separate_msg:gsub("(}),({)", "%1%2")
    separate_msg = separate_msg:gsub("},%s*{", "}{")
    separate_msg = separate_msg:gsub("{%((%d+)}", "(%1")
    separate_msg = separate_msg:gsub("{%)}", ")")
    separate_msg = separate_msg:gsub("{@dicID_%^%*%$(.-)%$%*^}", "@dicID_^*$%1$*^")
    separate_msg = separate_msg:gsub("{img link_party 24 24}%{", "{img link_party 24 24}")
    separate_msg = separate_msg:gsub("%}%{/%}%{/}", "{/}{/}")
    separate_msg = separate_msg:gsub("{/{/}{/}", "{/}{/}{/}")

    return separate_msg

end

function native_lang_replace_cluster_set(chatframe, gbox, cluster, chat_info, chat_id)
    local text_ctrl = GET_CHILD(cluster, "text")
    local msg = chat_info.trans_msg or chat_info.org_msg
    local separate_msg = chat_info.separate_msg

    if separate_msg and separate_msg ~= "None" then
        separate_msg = native_lang_replace_separate_msg(separate_msg, chat_id)
        msg = msg .. separate_msg
    end

    local msg_type = chat_info.msg_type
    local name = chat_info.name
    local org_msg = g.chat_ids[chat_id].org_msg
    local msg_front, font_style, font_size = native_lang_format_chat_message(chatframe, msg_type, name, msg, org_msg,
        chat_id)

    if msg_front then
        text_ctrl:SetTextByKey("font", font_style)
        text_ctrl:SetTextByKey("size", font_size)
        text_ctrl:SetTextByKey("text", msg_front)
    else
        text_ctrl:SetTextByKey("text", msg)
    end

    gbox:Invalidate()
end

function native_lang_replace()

    if g.settings.use == 0 or not g.ui_update_queue or #g.ui_update_queue == 0 then
        return
    end

    local gboxes_to_redraw = {}
    for _, entry in ipairs(g.ui_update_queue) do
        local chat_id = entry.chat_id

        local chat_info = g.chat_ids[chat_id]
        if chat_info then
            local org_msg = chat_info.org_msg
            if string.find(org_msg, "BattleChat_Colony_GuildMember") then
                for gbox_name, chat_frame_name in pairs(g.chat_gboxs) do
                    local chatframe = ui.GetFrame(chat_frame_name)
                    if chatframe then
                        local gbox = GET_CHILD(chatframe, gbox_name)
                        if gbox then
                            local cluster = gbox:GetChild("cluster_" .. chat_id)
                            if cluster then
                                AUTO_CAST(cluster)
                                native_lang_replace_cluster_set(chatframe, gbox, cluster, chat_info, chat_id)
                                gboxes_to_redraw[gbox] = true
                            end
                        end
                    end
                end
            else
                local chatframe = ui.GetFrame("chatframe")
                if chatframe then
                    local gbox = GET_CHILD(chatframe, g.gbox_name)
                    if gbox then
                        local cluster = gbox:GetChild("cluster_" .. chat_id)
                        if cluster then
                            AUTO_CAST(cluster)
                            native_lang_replace_cluster_set(chatframe, gbox, cluster, chat_info, chat_id)
                            gboxes_to_redraw[gbox] = true
                        end
                    end
                end
            end
        end
    end

    for gbox, _ in pairs(gboxes_to_redraw) do
        AUTO_CAST(gbox)
        native_lang_redraw_gbox(gbox)
    end

    g.ui_update_queue = {}

end

function native_lang_redraw_gbox(gbox)

    if not gbox then
        return
    end

    local chatframe = gbox:GetParent()

    local ypos = 0
    local margin_left = 20
    local chat_width = gbox:GetWidth()
    local offset_x = chatframe:GetUserConfig("CTRLSET_OFFSETX")

    for i = 0, gbox:GetChildCount() - 1 do
        local cluster = gbox:GetChildByIndex(i)

        if cluster and cluster:GetName() ~= "_SCR" then
            local text_ctrl = GET_CHILD(cluster, "text")
            AUTO_CAST(text_ctrl)
            local label = cluster:GetChild('bg')
            if text_ctrl and label then

                label:Resize(chat_width - offset_x, text_ctrl:GetHeight())
                cluster:Resize(chat_width, label:GetHeight())
                cluster:SetOffset(margin_left, ypos)
                ypos = ypos + cluster:GetHeight()
                text_ctrl:Invalidate()
                if chatframe:GetName() == "chatframe" then
                    local time = GET_CHILD(cluster, "time")
                    AUTO_CAST(time)
                    local chat_id = string.gsub(cluster:GetName(), "cluster_", "")
                    -- native_lang_force_full_redraw
                    -- time:SetEventScript(ui.RBUTTONDOWN, "native_lang_manual_translation")
                    -- time:SetEventScriptArgString(ui.RBUTTONDOWN, chat_id)
                    time:SetEventScript(ui.RBUTTONDOWN, "native_lang_force_full_redraw")
                end
            end
        end
    end

    gbox:Invalidate()
    if gbox:GetLineCount() == gbox:GetCurLine() + gbox:GetVisibleLineCount() then
        gbox:SetScrollPos(99999)
    end

end

function native_lang_force_full_redraw()

    if g.settings.use == 0 then
        return
    end
    g.chat_gbox = g.chat_gbox or {}
    for gbox_name, chat_frame_name in pairs(g.chat_gboxs) do

        local chatframe = ui.GetFrame(chat_frame_name)
        if chatframe then
            local gbox = GET_CHILD(chatframe, gbox_name)
            if gbox then
                local ypos = 0
                local margin_left = 20
                local chat_width = gbox:GetWidth()
                local offset_x = chatframe:GetUserConfig("CTRLSET_OFFSETX")

                for i = 0, gbox:GetChildCount() - 1 do

                    local cluster = gbox:GetChildByIndex(i)
                    if cluster and cluster:GetName() ~= "_SCR" then
                        AUTO_CAST(cluster)
                        local text_ctrl = GET_CHILD(cluster, "text")
                        local chat_id_str = cluster:GetName():gsub("cluster_", "")
                        local chat_info = g.chat_ids[chat_id_str]

                        if chat_info then

                            local msg = chat_info.trans_msg or chat_info.org_msg
                            local separate_msg = chat_info.separate_msg
                            if separate_msg and separate_msg ~= "None" then

                                local full_link, party_name = separate_msg:match("({img link_party 24 24}(.-){/})")
                                if full_link and party_name then
                                    local translated_name = g.names[party_name] or party_name
                                    translated_name = translated_name:gsub("{#FF0000}★{/}", "")
                                    local new_link = "{img link_party 24 24}" .. translated_name .. "{/}"
                                    separate_msg = separate_msg:gsub(full_link, new_link, 1)
                                end

                                separate_msg = separate_msg:gsub("(}),({)", "%1%2")
                                separate_msg = separate_msg:gsub("},%s*{", "}{")
                                separate_msg = separate_msg:gsub("{%((%d+)}", "(%1")
                                separate_msg = separate_msg:gsub("{%)}", ")")
                                separate_msg = separate_msg:gsub("{@dicID_%^%*%$(.-)%$%*^}", "@dicID_^*$%1$*^")
                                separate_msg = separate_msg:gsub("{img link_party 24 24}%{", "{img link_party 24 24}")
                                separate_msg = separate_msg:gsub("%}%{/%}%{/}", "{/}{/}")
                                separate_msg = separate_msg:gsub("{/{/}{/}", "{/}{/}{/}")
                                msg = msg .. separate_msg
                            end

                            local msg_type = chat_info.msg_type
                            local name = chat_info.name
                            local org_msg = chat_info.org_msg
                            local msg_front, font_style, font_size =
                                native_lang_format_chat_message(chatframe, msg_type, name, msg, org_msg, chat_id_str)

                            if msg_front then
                                text_ctrl:SetTextByKey("font", font_style)
                                text_ctrl:SetTextByKey("size", font_size)
                                text_ctrl:SetTextByKey("text", msg_front)
                            else
                                text_ctrl:SetTextByKey("text", msg)
                            end
                            if chatframe:GetName() == "chatframe" then
                                local time = GET_CHILD(cluster, "time");
                                AUTO_CAST(time)
                                -- time:SetEventScript(ui.RBUTTONDOWN, "native_lang_manual_translation")
                                -- time:SetEventScriptArgString(ui.RBUTTONDOWN, chat_id_str)
                                time:SetEventScript(ui.RBUTTONDOWN, "native_lang_force_full_redraw")
                            end
                        else
                            if chatframe:GetName() == "chatframe" then

                                if gbox:GetName() == g.gbox_name then

                                    if tonumber(g.first_chatid) <= tonumber(chat_id_str) then

                                        local original_text = text_ctrl:GetText()
                                        local size = session.ui.GetMsgInfoSize(g.gbox_name)

                                        for j = 0, size - 1 do
                                            local chat = session.ui.GetChatMsgInfo(g.gbox_name, j)

                                            if tostring(chat:GetMsgInfoID()) == chat_id_str then
                                                local msg_type = chat:GetMsgType()
                                                if msg_type ~= "System" then
                                                    local msg = chat:GetMsg()
                                                    local name = chat:GetCommanderName()
                                                    name = name:gsub("%s*%[(.-)%]", "")
                                                    local original_name = name
                                                    local msg_needs_trans = native_lang_is_translation_msg(msg)
                                                    local name_needs_trans = native_lang_is_translation(name)

                                                    if msg_needs_trans or name_needs_trans then
                                                        if native_lang_is_translation(name) then
                                                            name = g.names[name] or native_lang_process_name(name)
                                                        end
                                                        local org_msg = msg
                                                        msg = msg:gsub("{#0000FF}", "{#FFFF00}")
                                                        native_lang_draw_chat_msg_next(chatframe, gbox, g.gbox_name,
                                                            chat_id_str, msg, org_msg, msg_type, name, original_name)

                                                    end
                                                    break
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                        local label = cluster:GetChild('bg')
                        if label then
                            label:Resize(chat_width - offset_x, text_ctrl:GetHeight())
                            cluster:Resize(chat_width, label:GetHeight())
                            cluster:SetOffset(margin_left, ypos)
                            ypos = ypos + cluster:GetHeight()
                        end
                    end
                end

                gbox:Invalidate()
                if gbox:GetLineCount() == gbox:GetCurLine() + gbox:GetVisibleLineCount() then
                    gbox:SetScrollPos(99999)
                end
            end
        end
    end
    -- g.first_chatid = nil
end

function native_lang_chat_replace(frame, msg_front, font_style, font_size, chat_id)

    local clustername = "cluster_" .. chat_id
    local gbox = GET_CHILD(frame, g.gbox_name)
    if gbox then
        local cluster = GET_CHILD(gbox, clustername)
        local text = GET_CHILD(cluster, "text")

        text:SetTextByKey("font", font_style)
        text:SetTextByKey("size", font_size)
        text:SetTextByKey("text", msg_front)
    end

end

function native_lang_system_msg_to_chat_ids(chat_id, msg, msg_type, name, org_msg, updated_msg)
    g.chat_ids[tostring(chat_id)] = {
        msg_type = msg_type,
        name = g.names[name] or name,
        org_name = name,
        org_msg = org_msg,
        proc_msg = msg,
        separate_msg = "None",
        trans_msg = updated_msg
    }
    local data_to_queue = {
        chat_id = tostring(chat_id),
        frame_name = "chatframe",
        gbox_name = g.gbox_name
    }
    table.insert(g.ui_update_queue, data_to_queue)
    native_lang_replace()
    return
end

function native_lang_system_msg_replace(chat_id, msg, msg_type, name, org_msg)

    local chatframe = ui.GetFrame("chatframe")
    if string.find(msg, "https:") then
        native_lang_system_msg_to_chat_ids(chat_id, msg, msg_type, name, org_msg, msg)
        return
    elseif (msg_type == "guildmem" and
        (string.find(msg, "Login") or string.find(msg, "Logout") or string.find(msg, "ChatJoin") or
            string.find(msg, "ChatOut"))) or
        (msg_type == "partymem" and (string.find(msg, "ChatJoin") or string.find(msg, "ChatOut"))) then
        -- !@#${WHO}{TYPE}Login$*$WHO$*$핑크냥냥펀치$*$TYPE$*$!@#$Guild#@!#@!
        name = msg:match("%$%*%$WHO%$%*%$(.-)%s*%$%*%$")
        if name then
            local trans_name = g.names[name] or name
            local trans_msg = string.gsub(msg, name, trans_name, 1)
            local msg_front, font_style, font_size = native_lang_format_chat_message(chatframe, msg_type, "", trans_msg,
                org_msg, chat_id)
            if msg_front then
                native_lang_chat_replace(chatframe, msg_front, font_style, font_size, chat_id)
            end
            g.temp_msg = g.temp_msg or {}
            local data_to_write = {
                chat_id = tostring(chat_id),
                trans_msg = trans_msg,
                org_msg = org_msg,
                frame_name = "chatframe",
                gbox_name = g.gbox_name,
                msg_type = msg_type,
                name = name
            }
            table.insert(g.temp_msg, data_to_write)
            chatframe:StopUpdateScript("native_lang_write_to_recv_dat")
            chatframe:RunUpdateScript("native_lang_write_to_recv_dat", 0.1)
        end
        return
    elseif msg_type == "Battle" and (string.find(msg, "Dead") or string.find(msg, "Resurrect")) then -- Battle

        name = msg:match("%$%*%$MEMBER%$%*%$(.-)%s*#@!")
        if name then
            local trans_name = g.names[name] or name
            local trans_msg = string.gsub(msg, name, trans_name, 1)
            local msg_front, font_style, font_size = native_lang_format_chat_message(chatframe, msg_type, "", trans_msg,
                chat_id)
            if msg_front then
                native_lang_chat_replace(chatframe, msg_front, font_style, font_size, chat_id, org_msg)
            end
            g.temp_msg = g.temp_msg or {}
            local data_to_write = {
                chat_id = tostring(chat_id),
                trans_msg = trans_msg,
                org_msg = org_msg,
                frame_name = "chatframe",
                gbox_name = g.gbox_name,
                msg_type = msg_type,
                name = name
            }
            table.insert(g.temp_msg, data_to_write)
            chatframe:StopUpdateScript("native_lang_write_to_recv_dat")
            chatframe:RunUpdateScript("native_lang_write_to_recv_dat", 0.1)
        end
        return
    elseif string.find(msg, "Guild_Colony_End_WorldMessage") then
        name = msg:match("%$%*%$partyName%$%*%$(.-)%s*#@!")
        -- {#DD0000}!@#$Guild_Colony_End_WorldMessage_4$*$partyName$*$고양이젤리#@!
        -- {#DD0000}!@#$Guild_Colony_Occupation_WorldMessage$*$partyName$*$고양이젤리$*$mapName$*$|$#게나르 평원#$|#@!
        if name then
            local trans_name = g.names[name] or name
            local trans_msg = string.gsub(msg, name, trans_name, 1)
            local msg_front, font_style, font_size = native_lang_format_chat_message(chatframe, msg_type, "", trans_msg,
                chat_id)
            if msg_front then
                msg_front = string.gsub(msg_front, "#@!] : {#", "#@!]{#")
                native_lang_chat_replace(chatframe, msg_front, font_style, font_size, chat_id, org_msg)
            end
            g.temp_msg = g.temp_msg or {}
            local data_to_write = {
                chat_id = tostring(chat_id),
                trans_msg = trans_msg,
                org_msg = org_msg,
                frame_name = "chatframe",
                gbox_name = g.gbox_name,
                msg_type = msg_type,
                name = name
            }
            table.insert(g.temp_msg, data_to_write)
            chatframe:StopUpdateScript("native_lang_write_to_recv_dat")
            chatframe:RunUpdateScript("native_lang_write_to_recv_dat", 0.1)
        end
        return
    elseif string.find(msg, "Guild_Colony_Occupation_WorldMessage") then
        name = msg:match("%$%*%$partyName%$%*%$(.-)%s*%$%*%$")
        -- {#DD0000}!@#$Guild_Colony_Occupation_WorldMessage$*$partyName$*$고양이젤리$*$mapName$*$|$#게나르 평원#$|#@!
        if name then
            local trans_name = g.names[name] or name
            local trans_msg = string.gsub(msg, name, trans_name, 1)
            local msg_front, font_style, font_size = native_lang_format_chat_message(chatframe, msg_type, "", trans_msg,
                chat_id)
            if msg_front then
                msg_front = string.gsub(msg_front, "#@!] : {#", "#@!]{#")
                native_lang_chat_replace(chatframe, msg_front, font_style, font_size, chat_id, org_msg)
            end
            g.temp_msg = g.temp_msg or {}
            local data_to_write = {
                chat_id = tostring(chat_id),
                trans_msg = trans_msg,
                org_msg = org_msg,
                frame_name = "chatframe",
                gbox_name = g.gbox_name,
                msg_type = msg_type,
                name = name
            }
            table.insert(g.temp_msg, data_to_write)
            chatframe:StopUpdateScript("native_lang_write_to_recv_dat")
            chatframe:RunUpdateScript("native_lang_write_to_recv_dat", 0.1)
        end
        return
    elseif string.find(msg, "NOTICE_FIELDBOSS_RANK") and string.find(msg, "{rank}{name}") then
        -- {#DD0000}!@#$NOTICE_FIELDBOSS_RANK{rank}{name}$*$rank$*$1$*$name$*$kubis19, 테르, 사랑, 새욱이, 사탕#@!
        name = msg:match("%$%*%$name%$%*%$(.-)%s*#@!")
        if name then
            local replaced_names = {}
            for name_str in name:gmatch("([^,]+)") do
                local trim_name = name_str:match("^%s*(.-)%s*$")
                if g.names[trim_name] then
                    table.insert(replaced_names, g.names[trim_name])
                else
                    table.insert(replaced_names, trim_name)
                end
            end
            local new_names_str = table.concat(replaced_names, ", ")
            local trans_msg = string.gsub(msg, name, new_names_str, 1)
            local msg_front, font_style, font_size = native_lang_format_chat_message(chatframe, msg_type, "", trans_msg,
                chat_id)
            if msg_front then
                msg_front = string.gsub(msg_front, "#@!] : {#", "#@!]{#")
                native_lang_chat_replace(chatframe, msg_front, font_style, font_size, chat_id, org_msg)
            end
            g.temp_msg = g.temp_msg or {}
            local data_to_write = {
                chat_id = tostring(chat_id),
                trans_msg = trans_msg,
                org_msg = org_msg,
                frame_name = "chatframe",
                gbox_name = g.gbox_name,
                msg_type = msg_type,
                name = ""
            }
            table.insert(g.temp_msg, data_to_write)
            chatframe:StopUpdateScript("native_lang_write_to_recv_dat")
            chatframe:RunUpdateScript("native_lang_write_to_recv_dat", 0.1)
        end
        return
    elseif string.find(msg, "FIELDBOSS_WORLD_EVENT_WIN_MSG") then
        name = msg:match("%$%*%$PC%$%*%$(.-)%s*%$%*%$")
        -- {#DD0000}!@#$FIELDBOSS_WORLD_EVENT_WIN_MSG{PC}{ITEM}$*$PC$*$테르$*$ITEM$*$|$#아우스테야의 첫 번째 권능#$|#@!
        if name then
            local trans_name = g.names[name] or name
            local trans_msg = string.gsub(msg, name, trans_name, 1)
            local msg_front, font_style, font_size = native_lang_format_chat_message(chatframe, msg_type, "", trans_msg,
                chat_id)
            if msg_front then
                msg_front = string.gsub(msg_front, "#@!] : {#", "#@!]{#")
                native_lang_chat_replace(chatframe, msg_front, font_style, font_size, chat_id, org_msg)
            end
            g.temp_msg = g.temp_msg or {}
            local data_to_write = {
                chat_id = tostring(chat_id),
                trans_msg = trans_msg,
                org_msg = org_msg,
                frame_name = "chatframe",
                gbox_name = g.gbox_name,
                msg_type = msg_type,
                name = ""
            }
            table.insert(g.temp_msg, data_to_write)
            chatframe:StopUpdateScript("native_lang_write_to_recv_dat")
            chatframe:RunUpdateScript("native_lang_write_to_recv_dat", 0.1)
        end
        return

        --[[elseif string.find(msg, "GUILD_SYSTEM_MSG3") then
        msg = string.gsub(msg, "guildmem:", "")
        msg = string.reverse(msg)
        local start_pos = string.find(msg, "$*$FLES$*$", 1, true)
        local end_pos = string.find(msg, "$*$CP$*$", 1, true)
        end_pos = end_pos + 8
        local team_name = string.reverse(string.sub(msg, end_pos, start_pos - 1))
        local trimmed_name = team_name:match("^%s*(.-)%s*$")
        local trans_team_name = ""
        if g.names[trimmed_name] then
            trans_team_name = g.names[trimmed_name]
        else
            if native_lang_is_translation(trimmed_name) then
                trans_team_name = native_lang_process_name(trimmed_name)
            end
        end
        if trans_team_name == "" then
            trans_team_name = trimmed_name
        end
        local updated_msg = string.sub(msg, 1, end_pos - 1) .. string.reverse(trans_team_name) ..
                                string.sub(msg, start_pos)
        updated_msg = string.reverse(updated_msg)
        -- print(updated_msg)
        native_lang_system_msg_to_chat_ids(chat_id, msg, msg_type, "", org_msg, updated_msg)
        return]]

    end
end
-- CHAT_SYSTEM(
-- "{#DD0000}!@#$Guild_Colony_Occupation_WorldMessage$*$partyName$*$오레오$*$mapName$*$|$#아렐르노 남작령#$|#@!")
-- native_lang_system_msg_replace(266778, "!@#${WHO}{TYPE}Logout$*$WHO$*$밍구링$*$TYPE$*$!@#$Guild#@!#@!", "guildmem",
-- "밍구링", "!@#${WHO}{TYPE}Logout$*$WHO$*$밍구링$*$TYPE$*$!@#$Guild#@!#@!")
-- CHAT_SYSTEM("!@#$Resurrect{MEMBER}$*$MEMBER$*$쟝삐에르#@!")
function native_lang_modify_string(msg)

    local pattern = "{img link_party 24 24}([^%{%}]+){/}{/}"
    if string.find(msg, pattern) then
        local party_name = msg:match(pattern)
        native_lang_process_name(party_name)
        if g.names[party_name] then
            local translated_name = g.names[party_name]:gsub("{#FF0000}★{/}", "")
            msg = msg:gsub(pattern, "{img link_party 24 24}{" .. translated_name .. "}{/}{/}")
        else
            msg = msg:gsub(pattern, "{img link_party 24 24}{%1}{/}{/}")
        end
    end
    local pattern2 = "(@dicID_%^%*%$.-%$%*%^)"
    if string.find(msg, pattern2) then
        msg = msg:gsub(pattern2, "{%1}")
    end
    local pattern3 = "!@#%$(.-)#@!"
    if string.find(msg, pattern3) then
        msg = msg:gsub(pattern3, "{%1}")
    end
    if string.find(msg, "Earring 30 30") then
        msg = msg:gsub("%((%d+)", "{(%1}")
        msg = msg:gsub("%)", "{)}")
    end
    return msg
end

function native_lang_wrapped_contents(msg)
    local pattern = "{(.-)}"
    local separate_msg = {}
    for match in msg:gmatch(pattern) do
        table.insert(separate_msg, "{" .. match .. "}")
    end
    msg = msg:gsub(pattern, "")
    return msg, separate_msg
end

function native_lang_anti_pattern(proc_msg)
    local patterns = {",", "'", "’", "`", "~~", "&", "!", ":", "/", "", "%[", "%]", "%{", "%}", "//", "%.", "%+",
                      "%*", "%-", "%^", "%$"} -- %?

    for _, pattern_str in ipairs(patterns) do
        proc_msg = proc_msg:gsub(pattern_str .. "+", " ")
    end
    proc_msg = proc_msg:gsub("%%", " percent ")
    return proc_msg
end

function native_lang_msg_processing(msg)
    msg = native_lang_modify_string(msg)
    local proc_msg, separate_msg = native_lang_wrapped_contents(msg)
    proc_msg = native_lang_anti_pattern(proc_msg)
    proc_msg = proc_msg:gsub(" +", " ")
    return proc_msg, separate_msg
end

function native_lang_manual_translation(parent, cluster, chat_id_str)

    if not cluster then
        return
    end
    local chat_frame = cluster:GetTopParentFrame()
    local gbox_name = parent:GetParent():GetName()
    local size = session.ui.GetMsgInfoSize(gbox_name)
    for i = 0, size - 1 do
        local cluster_info = session.ui.GetChatMsgInfo(gbox_name, i)
        if chat_id_str == tostring(cluster_info:GetMsgInfoID()) then
            local chat = session.ui.GetChatMsgInfo(gbox_name, i)
            local msg = chat:GetMsg()
            local msg_type = chat:GetMsgType()
            local name = chat:GetCommanderName()
            name = name:gsub("%s*%[(.-)%]", "")
            local original_name = name
            if native_lang_is_translation(name) then
                name = g.names[name] or native_lang_process_name(name)
            end
            local org_msg = msg
            msg = msg:gsub("{#0000FF}", "{#FFFF00}")
            native_lang_draw_chat_msg_next(chat_frame, parent, gbox_name, chat_id_str, msg, org_msg, msg_type, name,
                original_name)
        end
    end
end

function native_lang_draw_chat_msg_next(frame, gbox, gbox_name, chat_id, msg, org_msg, msg_type, name, original_name)

    local logmsg = chat_id .. ":" .. msg_type .. ":" .. name .. ":" .. original_name .. ":" .. msg .. ":" .. org_msg
    if not g.org_msg then
        g.log_to_file(logmsg)
    elseif g.org_msg ~= org_msg then
        g.log_to_file(logmsg)
    end
    g.org_msg = org_msg

    if string.find(msg, "{spine") then
        local msg_front, font_style, font_size = native_lang_format_chat_message(frame, msg_type, name, msg, org_msg,
            chat_id)
        if msg_front then
            native_lang_chat_replace(frame, msg_front, font_style, font_size, chat_id)
        end
        return
    end

    if string.find(msg, "https:") then
        native_lang_system_msg_replace(chat_id, msg, msg_type, name, org_msg)
        return
    end

    if name == "System" or name == "guildmem" or name == "partymem" or name == "Battle" then
        local sys_msg_find = native_lang_system_msg_replace(chat_id, msg, msg_type, name, org_msg)
        return
    end

    if msg_type == "GuildNotice" and string.find(msg, "GuildNotice{msg}") then
        local extract_pattern = "!@#%$GuildNotice{msg}%$%*%$msg%$%*%$(.-)#@!"
        local extracted_msg = msg:match(extract_pattern)
        if extracted_msg then
            msg = extracted_msg
        end
    end

    if msg_type ~= "System" then

        local need_trans_msg = native_lang_is_translation_msg(msg)
        local need_trans_name = native_lang_is_translation(original_name)
        local is_link_only = native_lang_is_link_only(msg)
        if is_link_only or not need_trans_msg then
            if need_trans_name then
                local translated_name = g.names[name] or native_lang_process_name(name) or original_name
                org_msg = msg:gsub("{#0000FF}", "{#FFFF00}")
                local msg_front, font_style, font_size = native_lang_format_chat_message(frame, msg_type,
                    translated_name, org_msg, org_msg, chat_id)
                if msg_front then
                    native_lang_chat_replace(frame, msg_front, font_style, font_size, chat_id)
                end
                g.chat_ids[tostring(chat_id)] = {
                    msg_type = msg_type,
                    name = name,
                    org_name = original_name,
                    org_msg = msg,
                    proc_msg = msg,
                    separate_msg = "None",
                    trans_msg = msg
                }
                g.temp_msg = g.temp_msg or {}
                local data_to_write = {
                    chat_id = tostring(chat_id),
                    trans_msg = org_msg,
                    org_msg = org_msg,
                    frame_name = "chatframe",
                    gbox_name = g.gbox_name,
                    msg_type = msg_type,
                    name = name
                }
                table.insert(g.temp_msg, data_to_write)
                frame:StopUpdateScript("native_lang_write_to_recv_dat")
                frame:RunUpdateScript("native_lang_write_to_recv_dat", 0.1)
            end
            return
        end
    end

    if msg_type ~= "Normal" and msg_type ~= "Shout" and msg_type ~= "Party" and msg_type ~= "Guild" and msg_type ~=
        "System" and msg_type ~= "GuildComm" and msg_type ~= "guildmem" and msg_type ~= "GuildNotice" and msg_type ~=
        "Whisper" then
        return
    end
    local proc_msg, separate_msg = native_lang_msg_processing(msg)
    native_lang_post_processing(frame, msg, org_msg, proc_msg, separate_msg, msg_type, name, original_name, chat_id)
end

function native_lang_post_processing(frame, msg, org_msg, proc_msg, separate_msg, msg_type, name, original_name, chat_id)

    g.chat_ids[tostring(chat_id)] = {
        msg_type = msg_type,
        name = g.names[name] or name,
        org_name = original_name,
        org_msg = org_msg,
        proc_msg = proc_msg,
        separate_msg = #separate_msg == 0 and "None" or table.concat(separate_msg, ","),
        trans_msg = ""
    }

    local send_msg = string.format("%s:::%s:::%s:::%s:::%s:::%s", chat_id, msg_type, proc_msg,
        g.chat_ids[tostring(chat_id)].separate_msg, org_msg, original_name)
    local send_file = io.open(g.send_msg, "a")
    if send_file then
        send_file:write(send_msg .. "\n")
        send_file:close()
    end

end

function native_lang_DRAW_CHAT_MSG(my_frame, my_msg)

    local groupboxname, startindex, chatframe = g.get_event_args(my_msg)

    if not chatframe then
        return
    end

    local gbox = GET_CHILD(chatframe, groupboxname)
    if not gbox then
        return
    end

    g.chat_gboxs = g.chat_gboxs or {}
    if not g.chat_gboxs[groupboxname] then
        g.chat_gboxs[groupboxname] = chatframe:GetName()
    end

    if g.settings.use == 0 then
        return
    end

    local size = session.ui.GetMsgInfoSize(groupboxname)
    local chat = session.ui.GetChatMsgInfo(groupboxname, size - 1)
    local chat_id = chat:GetMsgInfoID()
    local msg_type = chat:GetMsgType()

    g.chat_check = g.chat_check or {}
    if g.chat_check[tostring(chat_id)] then
        return
    end

    if not g.chat_check[tostring(chat_id)] then
        g.chat_check[tostring(chat_id)] = true
    end

    local name = chat:GetCommanderName()
    name = name:gsub("%s*%[(.-)%]", "")
    local original_name = name
    if native_lang_is_translation(name) then
        name = g.names[name] or native_lang_process_name(name)
    end

    local my_name = GETMYFAMILYNAME()
    if original_name == my_name then
        return
    end

    local msg = chat:GetMsg()
    local org_msg = msg
    msg = msg:gsub("{#0000FF}", "{#FFFF00}")

    local keyword = "!@#$ItemGet{name}{count}$*$"
    if string.find(msg, keyword, 1, true) then
        return
    end

    -- これだけはpopupchatにも表示出来る様にchatframeを使う
    if string.find(msg, "BattleChat_Colony_GuildMember") then
        native_lang_draw_colony_msg(chatframe, gbox, msg, chat_id)
        return
    end

    local frame = ui.GetFrame("chatframe")
    local cluster = GET_CHILD_RECURSIVELY(frame, "cluster_" .. chat_id)
    if cluster then
        g.gbox_name = groupboxname
        native_lang_draw_chat_msg_next(frame, gbox, groupboxname, chat_id, msg, org_msg, msg_type, name, original_name)
    end

end

-- g.debug_print_table(g.chat_gboxs)
--[[CHAT_SYSTEM(
    "!@#$BattleChat_Colony_GuildMember{Name}HasKilledBy{From}OfGuild{FromGuild}$*$Name$*${#99CC00}방상시{/}$*$From$*${#FF5500}一級河川{/}$*$FromGuild$*${#FF5500}UnNamedPlanet{/}#@!")
CHAT_SYSTEM(
    "!@#$BattleChat_Colony_GuildMember{Name}HasKilledBy{From}OfGuild{FromGuild}$*$Name$*${#99CC00}뜨거워요{/}$*$From$*${#FF5500}Awewe{/}$*$FromGuild$*${#FF5500}비나리{/}#@!")]]
-- ui.Chat("/p {a SLP 1568693855192710}{#0000FF}{img link_party 24 24}이해요엘로나{/}{/} ")
-- ui.Chat("/p test")

-- アドオン再起動
function native_lang_restart()

    local file = io.open(g.restart, "w")
    file:write("restart")
    file:close()
    g.start = false
    g.load = false
    g.chat_ids = {}
    g.ui_update_queue = {}
    g.last_written_line = ""
    g.name_len = 0

    local chatframe = ui.GetFrame("chatframe")
    chatframe:RunUpdateScript("native_lang_GAME_START", 1.0)
    local text = g.language == "Japanese" and "{ol}翻訳プログラムを再起動します" or
                     "{ol}Restart the transrate program."
    ui.SysMsg("[Native Lang]" .. text)
end

-- 設定ボタン
function native_lang_context()

    if not g.settings.chatmode then
        g.settings.chatmode = false
        native_lang_save_settings()
    end
    local context = ui.CreateContextMenu("native_lang_context", "{ol}Native Lang", 0, 0, 50, 0)
    ui.AddContextMenuItem(context, "-----")
    local str_scp
    if not g.settings.chatmode then
        str_scp = string.format("native_lang_mode_switching()")
        ui.AddContextMenuItem(context, g.language == "Japanese" and "{ol}チャットモードへ切替" or
            "{ol}Switch to chat mode", str_scp)
    else
        str_scp = string.format("native_lang_mode_switching()")
        ui.AddContextMenuItem(context, g.language == "Japanese" and "{ol}フル翻訳モードへ切替" or
            "{ol}Switch to full translation mode", str_scp)
    end
    local msg = ""
    local language = ""
    if g.settings.recv_lang ~= "None" then
        if g.settings.recv_lang == "en" then
            language = "English"
        elseif g.settings.recv_lang == "ko" then
            language = "Korean"
        elseif g.settings.recv_lang == "ja" then
            language = "Japanese"
        elseif g.settings.recv_lang == "ko_only" then
            language = "Korean Only"
        elseif g.settings.recv_lang == "jp_only" then
            language = "Japanese Input"
        end
        msg = g.language == "Japanese" and "{ol}自分の発言翻訳" .. " to {#FFFF00}" .. language or
                  "{ol}Translation of my speech to {#FFFF00}" .. language
    else
        language = "Off"
        msg = g.language == "Japanese" and "{ol}自分の発言翻訳" .. " {#FFFF00}" .. language or
                  "{ol}Translation of my speech {#FFFF00}" .. language
    end
    str_scp = string.format("native_lang_speech_select()")
    ui.AddContextMenuItem(context, msg, str_scp)
    if g.settings.use == 1 then
        str_scp = string.format("native_lang_switching()")
        ui.AddContextMenuItem(context, g.language == "Japanese" and "{ol}アドオンストップ" or "{ol}addon Stop",
            str_scp)
    else
        str_scp = string.format("native_lang_switching()")
        ui.AddContextMenuItem(context, g.language == "Japanese" and "{ol}アドオン起動" or "{ol}addon Activation",
            str_scp)
    end
    str_scp = string.format("native_lang_restart()")
    ui.AddContextMenuItem(context, g.language == "Japanese" and "{ol}アドオン再起動" or "{ol}addon Reboot",
        str_scp)

    ui.OpenContextMenu(context)
end

function native_lang_switching()
    local chatframe = ui.GetFrame("chatframe")
    local trans_btn = GET_CHILD_RECURSIVELY(chatframe, "trans_btn")
    AUTO_CAST(trans_btn)

    if g.settings.use == 1 then
        g.settings.use = 0
        trans_btn:SetSkinName('test_gray_button')
        trans_btn:SetTextTooltip(g.language == "Japanese" and "Native Lang 停止中{nl}左クリック: 設定" or
                                     "{ol}Native Lang is suspended{nl}Left click to setting")
    else
        g.settings.use = 1
        trans_btn:SetSkinName("test_red_button")
        trans_btn:SetTextTooltip(g.language == "Japanese" and "Native Lang 起動中{nl}左クリック: 設定" or
                                     "{ol}Native Lang in use{nl}Left click to setting")
    end
    native_lang_save_settings()
end

function native_lang_mode_switching()
    if not g.settings.chatmode then
        g.settings.chatmode = true
    else
        g.settings.chatmode = false
    end
    native_lang_save_settings()
    native_lang_GAME_START_3SEC()
end

function native_lang_speech_switching(lang)
    g.settings.recv_lang = lang
    native_lang_save_settings()
    local lang_map = {
        ja = "Japanese",
        ko = "Korean",
        en = "English",
        ko_only = "Korean Only",
        jp_only = "Japanese Only",
        None = "Off"
    }
    local display_lang = lang_map[lang] or "Off"
    local text
    if g.language == "Japanese" then
        text = string.format("発言の翻訳先を %s に変更しました", display_lang)
    else
        text = string.format("Speech translation target changed to %s", display_lang)
    end
    ui.SysMsg("[Native Lang] " .. text)
end

function native_lang_speech_select()
    local context = ui.CreateContextMenu("native_lang_lang_select_context", "{ol}Speech Select", 0, 0, 0, 0)
    ui.AddContextMenuItem(context, "-----")
    local lang_tbl = {{
        short = "ja",
        long = "Japanese",
        display = "日本語"
    }, {
        short = "ko",
        long = "Korean",
        display = "韓国語"
    }, {
        short = "en",
        long = "English",
        display = "英語"
    }, {
        short = "ko_only",
        long = "Korean Only",
        display = "韓国語のみ"
    }, {
        short = "jp_only",
        long = "Japanese Input",
        display = "日本語入力"
    }, {
        short = "None",
        long = "Off",
        display = "OFF"
    }}

    for _, data in ipairs(lang_tbl) do
        local short = data.short
        local long = data.long
        local display_name = data.display
        local menu_text
        if g.language == "Japanese" then
            menu_text = string.format("{ol}自分の発言翻訳 to {#FFFF00}%s", display_name)
        else
            menu_text = string.format("{ol}Translation of my speech to {#FFFF00}%s", long)
        end
        local str_scp = string.format("native_lang_speech_switching('%s')", short)
        ui.AddContextMenuItem(context, menu_text, str_scp)
    end
    ui.OpenContextMenu(context)
end

-- キャラ名、店舗名翻訳
function native_lang_name_dat_check()

    local recv_name_file = io.open(g.recv_name, "r")
    if not recv_name_file then
        return
    end

    local current_len = recv_name_file:seek("end")
    if g.name_len and g.name_len == current_len then
        recv_name_file:close()
        return
    end

    recv_name_file:seek("set", g.name_len or 0)
    local new_content = recv_name_file:read("*a")
    recv_name_file:close()

    if new_content and new_content ~= "" then
        for line in string.gmatch(new_content, "[^\r\n]+") do
            local org_name, trans_name = line:match("^(.-):::(.*)$")
            if org_name and trans_name then
                if not trans_name:match("%s$") then
                    g.names[org_name] = trans_name
                end
            end
        end
    end

    g.name_len = current_len
    return
end

function native_lang_name_update(frame)

    native_lang_name_dat_check()
    if not g.settings.chatmode then
        native_lang_name_trans()
    end
    return 1
end

function native_lang_name_trans()
    if g.settings.use == 0 then
        return
    end

    local myframe = ui.GetFrame("charbaseinfo1_my")
    local guildName = GET_CHILD_RECURSIVELY(myframe, "guildName")
    local origin_name = guildName:GetText()
    if not string.find(origin_name, "{#FF0000}★{/}") then
        if native_lang_is_translation(origin_name) then
            if string.find(origin_name, "{img guild_master_mark 20 20}") ~= nil then
                origin_name = string.gsub(origin_name, "{img guild_master_mark 20 20}", "")
            end
            local clean_name = origin_name:gsub("{.-}", ""):gsub("__+", "_"):match("^%s*(.-)%s*$")
            local trans_name = native_lang_process_name(clean_name)
            if trans_name ~= clean_name then
                guildName:SetText(trans_name)
            end
        end
    end
    local selected_objects, selected_objects_count = SelectObject(GetMyPCObject(), 500, "ALL")
    local view_pcs = {}

    for i = 1, selected_objects_count do

        local handle = GetHandle(selected_objects[i])

        if handle and info.IsPC(handle) == 1 then
            view_pcs[handle] = true

            local pc_txt_frame = ui.GetFrame("charbaseinfo1_" .. handle)
            if pc_txt_frame ~= nil then

                local given_name = GET_CHILD(pc_txt_frame, "givenName")
                if given_name ~= nil then
                    native_lang_name_replace(given_name)
                end

                local family_name = GET_CHILD(pc_txt_frame, "familyName")
                if family_name ~= nil then
                    native_lang_name_replace(family_name, handle)
                end

                local frame_name = GET_CHILD(pc_txt_frame, "name")
                if frame_name ~= nil then
                    native_lang_name_replace(frame_name)
                end

                local guild_name = GET_CHILD(pc_txt_frame, "guildName")
                if guild_name ~= nil then
                    native_lang_name_replace(guild_name)
                end
            end

            local shop_frame = ui.GetFrame("SELL_BALLOON_" .. handle)
            if shop_frame ~= nil then
                local shop_text = GET_CHILD(shop_frame, "text")
                if shop_text ~= nil then
                    native_lang_name_replace(shop_text)
                end
                local lv_box = GET_CHILD(shop_frame, "withLvBox")
                local lv_title = GET_CHILD(lv_box, "lv_title")
                if shop_frame:GetUserIValue("SELL_TYPE") == 5 then
                    g.food_aids = g.food_aids or {}
                    local actor = world.GetActor(handle)
                    local apc = actor:GetPCApc()
                    local aid = apc:GetAID()
                    local info = session.autoSeller.GetByIndex("FoodTable", 0)
                    if info then
                        if not g.food_aids[aid] or g.food_aids[aid] ~= info.level then
                            g.food_aids[aid] = info.level
                            g.save_json(g.food_aids_path, g.food_aids)
                        end
                    end
                    local lv_text = GET_CHILD(lv_box, "lv_text")
                    if g.food_aids[aid] then
                        lv_text:SetTextByKey("value", "{#FFFF00}" .. g.food_aids[aid])
                        lv_title:SetTextByKey("value", "")
                        lv_box:ShowWindow(1)
                    else
                        lv_box:ShowWindow(0)
                    end
                else
                    native_lang_name_replace(lv_title)
                end
            end
        end
    end
end

function native_lang_name_replace(ctrl, handle)

    local origin_name = ctrl:GetText()

    if not string.find(origin_name, "{#FF0000}★{/}") then
        if native_lang_is_translation(origin_name) then

            if string.find(origin_name, "{img guild_master_mark 20 20}") ~= nil then
                origin_name = string.gsub(origin_name, "{img guild_master_mark 20 20}", "")
            end
            local clean_name = origin_name:gsub("{.-}", ""):gsub("__+", "_"):match("^%s*(.-)%s*$")

            if native_lang_is_translation(clean_name) then

                local trans_name = native_lang_process_name(clean_name)
                if trans_name ~= clean_name then

                    if ctrl:GetName() == "guildName" then
                        ctrl:SetText(trans_name)
                    elseif ctrl:GetName() == "text" then
                        ctrl:SetTextByKey("value", trans_name)
                    elseif ctrl:GetName() == "lv_title" then
                        ctrl:SetTextByKey("value", trans_name)
                    end
                    if ctrl:GetName() == "name" and ctrl:IsVisible() == 1 then
                        local original_part = origin_name:sub(1, 9)
                        original_part = original_part:gsub("}{", "}")
                        trans_name = original_part .. trans_name
                        ctrl:SetText(trans_name)
                    elseif ctrl:GetName() == "givenName" and ctrl:IsVisible() == 1 then
                        local original_part = origin_name:sub(1, 9)
                        trans_name = original_part .. trans_name
                        ctrl:SetText(trans_name)
                    elseif ctrl:GetName() == "familyName" and ctrl:IsVisible() == 1 then

                        local original_part = origin_name:sub(1, 9)
                        original_part = original_part:gsub("}{", "}")
                        trans_name = original_part .. trans_name
                        ctrl:SetText(trans_name)

                        local pc_txt_frame = ui.GetFrame("charbaseinfo1_" .. handle)
                        local givenName = GET_CHILD(pc_txt_frame, "givenName")
                        local len = utf8_len(givenName:GetText():match("{/}(.*)")) + 1

                        local givenName_height = givenName:GetHeight()
                        local givenName_width = givenName:GetWidth()
                        local givenName_margin = givenName:GetMargin()

                        local familyName_margin = ctrl:GetMargin()
                        ctrl:SetMargin(givenName_margin.left + len * 20, familyName_margin.top, familyName_margin.right,
                            familyName_margin.bottom)
                    end
                end
            end
        end
    end
end

-- ペット名翻訳
function native_lang_UPDATE_COMPANION_TITLE(frame, handle)
    if g.settings.use == 0 or g.settings.chatmode then
        base["UPDATE_COMPANION_TITLE"](frame, handle)
    else
        native_lang_UPDATE_COMPANION_TITLE_(frame, handle)
    end
end

function native_lang_UPDATE_COMPANION_TITLE_(frame, handle)

    frame = tolua.cast(frame, "ui::CObject")
    local petguid = session.pet.GetPetGuidByHandle(handle)
    local mycompinfoBox = GET_CHILD_RECURSIVELY(frame, "mycompinfo")
    if mycompinfoBox == nil then
        return
    end

    local otherscompinfo = GET_CHILD_RECURSIVELY(frame, "otherscompinfo")
    if petguid == 'None' then
        mycompinfoBox:ShowWindow(0)
        otherscompinfo:ShowWindow(1)

        local targetinfo = info.GetTargetInfo(handle)
        if targetinfo == nil then
            return
        end
        local othernameTxt = GET_CHILD_RECURSIVELY(frame, "othername")
        local origin_name = targetinfo.name
        local clean_name = origin_name:gsub("{.-}", ""):gsub("__+", "_"):match("^%s*(.-)%s*$")
        local trans_name = g.names[clean_name] or targetinfo.name
        if native_lang_is_translation(clean_name) then
            trans_name = native_lang_process_name(clean_name)
            othernameTxt:SetText(trans_name)
        else
            othernameTxt:SetText(trans_name)
        end

    else
        local myActor = GetMyPCObject()
        if myActor ~= nil and IsBuffApplied(myActor, "RidingCompanion") == "YES" then
            mycompinfoBox:ShowWindow(0)
        else
            mycompinfoBox:ShowWindow(1)
        end
        otherscompinfo:ShowWindow(0)

        local mynameRtext = GET_CHILD_RECURSIVELY(frame, "myname")
        local gauge_stamina = GET_CHILD_RECURSIVELY(frame, "StGauge")
        local gauge_HP = GET_CHILD_RECURSIVELY(frame, "HpGauge")

        local pet = session.pet.GetPetByGUID(petguid)
        mynameRtext:SetText(pet:GetName())

        local petObj = GetIES(pet:GetObject())
        gauge_stamina:SetPoint(petObj.Stamina, petObj.MaxStamina)

        local petInfo = info.GetStat(handle)
        gauge_HP:SetPoint(petInfo.HP, petInfo.maxHP)
    end
    frame:Invalidate()
end

-- ギアスコアランキング関連
function native_lang_GEAR_SCORE_RANKING_CREATE_INFO(ctrl, rank, guildIdx, teamName, charName, value)
    if g.settings.use == 0 or g.settings.chatmode then
        base["GEAR_SCORE_RANKING_CREATE_INFO"](ctrl, rank, guildIdx, teamName, charName, value)
    else
        native_lang_GEAR_SCORE_RANKING_CREATE_INFO_(ctrl, rank, guildIdx, teamName, charName, value)
    end
end

function native_lang_GEAR_SCORE_RANKING_CREATE_INFO_(ctrl, rank, guildIdx, teamName, charName, value)
    local guildPic = GET_CHILD(ctrl, "emblem_pic")
    local rankText = GET_CHILD(ctrl, "rank_text")
    local teamNameText = GET_CHILD(ctrl, "team_name_text")
    local charNameText = GET_CHILD(ctrl, "char_name_text")
    local valueText = GET_CHILD(ctrl, "value_text")

    local org_name = teamName:gsub("{#0000FF}", "")

    teamName = teamName:gsub("{#0000FF}", "")
    if native_lang_is_translation(teamName) then
        teamName = native_lang_process_name(teamName)
    end
    if native_lang_is_translation(charName) then
        charName = native_lang_process_name(charName)
    end
    rankText:SetTextByKey("value", rank)
    if teamName == GETMYFAMILYNAME() then
        teamName = "{#0000FF}" .. teamName
    end
    teamNameText:SetTextByKey("value", teamName)
    charNameText:SetTextByKey("value", charName)
    valueText:SetTextByKey("value", value)

    local frame = guildPic:GetTopParentFrame()
    local close_btn = GET_CHILD_RECURSIVELY(frame, "closeBtn")
    AUTO_CAST(close_btn)
    close_btn:SetEventScript(ui.LBUTTONDOWN, "native_lang_real_rank_save")

    local found = false

    for i = 1, #g.gear_scores do
        local gs_org_name = g.gear_scores[i][1]
        if org_name == gs_org_name then
            found = true
            local gs_value = g.gear_scores[i][4]
            if tonumber(value) > tonumber(gs_value) then
                g.gear_scores[i][4] = tonumber(value)
            end
            local save_guild_index = g.gear_scores[i][3]
            if tonumber(save_guild_index) ~= tonumber(guildIdx) then
                g.gear_scores[i][3] = guildIdx
            end
            break
        end
    end

    if not found then
        table.insert(g.gear_scores, {org_name, teamName, guildIdx, value})
    end

    if guildIdx ~= "0" then
        local worldID = session.party.GetMyWorldIDStr()
        local emblemImgName = guild.GetEmblemImageName(guildIdx, worldID)

        if emblemImgName ~= 'None' then
            guildPic:SetFileName(emblemImgName)
        end
    end
end

function native_lang_real_rank_save(frame, ctrl, str, num)

    table.sort(g.gear_scores, function(a, b)
        return a[4] > b[4]
    end)

    local file_path = g.gear_score

    local file = io.open(file_path, "w")
    if file then
        for _, score in ipairs(g.gear_scores) do
            local line = string.format("%s:::%s:::%s:::%d\n", score[1], score[2], score[3], score[4])
            file:write(line)
            -- file:flush()
        end
        file:close()
    end

end

function native_lang_ON_EVENTBANNER_GEARSCORE()
    local frame = ui.GetFrame("ingameeventbanner")
    if g.settings.use == 0 or g.settings.chatmode then
        local real_rank = GET_CHILD_RECURSIVELY(frame, "real_rank")
        if real_rank ~= nil then
            real_rank:ShowWindow(0)
        end
        return
    end
    ReserveScript("native_lang_ON_EVENTBANNER_GEARSCORE_()", 0.5)
end

function native_lang_ON_EVENTBANNER_GEARSCORE_()

    local frame = ui.GetFrame("ingameeventbanner")
    local ranking_gear_score = GET_CHILD_RECURSIVELY(frame, "ranking_gear_score")
    AUTO_CAST(ranking_gear_score)
    local detail_btn = GET_CHILD(ranking_gear_score, "detail_btn")
    local detail_x, detail_y = detail_btn:GetX(), detail_btn:GetY()
    local real_rank = ranking_gear_score:CreateOrGetControl('button', "real_rank", detail_x - 180, detail_y, 100, 30)
    AUTO_CAST(real_rank)
    real_rank:SetSkinName("None")
    real_rank:SetEventScript(ui.LBUTTONUP, "native_lang_real_rank_frame")

    real_rank:SetText("{ol}{s20}Maximum Rank>>")
    real_rank:ShowWindow(1)
end

function native_lang_real_rank_frame_close(frame, ctrl, str, num)
    local frame = ui.GetFrame(addon_name_lower .. "gear_score_info")
    frame:ShowWindow(0)
end

function native_lang_real_rank_frame(frame, ctrl, str, num)
    local frame = ui.CreateNewFrame("notice_on_pc", addon_name_lower .. "gear_score_info", 0, 0, 0, 0)
    AUTO_CAST(frame)
    frame:SetPos(1000, 30)
    frame:SetSkinName("test_frame_low")
    frame:SetLayerLevel(1000)
    frame:RemoveAllChild()
    -- frame:SetTitleBarSkin("mainframe_03")

    local close_button = frame:CreateOrGetControl("button", "close_button", 0, 0, 30, 30)
    AUTO_CAST(close_button)
    close_button:SetImage("testclose_button")
    close_button:SetGravity(ui.RIGHT, ui.TOP)
    close_button:SetEventScript(ui.LBUTTONUP, "native_lang_real_rank_frame_close")
    close_button:SetMargin(0, 55, 0, 0)

    local rank_title = frame:CreateOrGetControl('richtext', 'rank_title', 15, 60, 60, 30)
    AUTO_CAST(rank_title)
    rank_title:SetFontName("white_20_ol_ds")
    rank_title:SetText("Rank")

    local name_title = frame:CreateOrGetControl('richtext', 'name_title', 120, 60, 200, 30)
    AUTO_CAST(name_title)
    name_title:SetFontName("white_20_ol_ds")
    name_title:SetText("Team Name")

    local score_title = frame:CreateOrGetControl('richtext', 'score_title', 330, 60, 80, 30)
    AUTO_CAST(score_title)
    score_title:SetFontName("white_20_ol_ds")
    score_title:SetText("Gear Score")

    local info_gbox = frame:CreateOrGetControl("groupbox", "info_gbox", 10, 95, frame:GetWidth() - 20,
        frame:GetHeight() - 55)
    AUTO_CAST(info_gbox)

    info_gbox:SetSkinName("bg")

    local y = 0
    local x = 480
    local worldID = session.party.GetMyWorldIDStr()
    for i, entry in ipairs(g.gear_scores) do
        local rank_text = info_gbox:CreateOrGetControl('richtext', 'rank_text' .. i, 10, y + 5, 60, 30)
        AUTO_CAST(rank_text)
        rank_text:SetFontName("white_20_ol_ds")
        rank_text:SetText(i)

        local pic = info_gbox:CreateOrGetControl('picture', "pic" .. i, 70, y, 30, 30)
        AUTO_CAST(pic)

        if tostring(entry[3]) ~= "0" then

            local emblemImgName = guild.GetEmblemImageName(tostring(entry[3]), worldID)

            if emblemImgName ~= 'None' then
                pic:SetFileName(emblemImgName)
                pic:SetEnableStretch(1)
            end
        end

        local name_text = info_gbox:CreateOrGetControl('richtext', 'name_text' .. i, 110, y + 5, 240, 30)
        AUTO_CAST(name_text)

        local name = entry[2] or entry[1]
        name_text:SetText("{ol}{s18}" .. name)
        name_text:AdjustFontSizeByWidth(240)

        local score_text = info_gbox:CreateOrGetControl('richtext', 'score_text' .. i, 360, y + 5, 80, 30)
        AUTO_CAST(score_text)
        -- score_text:SetFontName("white_20_ol_ds")
        score_text:SetText("{ol}{s18}" .. entry[4])

        y = y + 35

    end

    frame:Resize(x, 800)
    local title_gb = frame:CreateOrGetControl("groupbox", "title_gb", 0, 0, frame:GetWidth(), 55)
    title_gb:SetSkinName("test_frame_top")
    AUTO_CAST(title_gb)
    local title_text = title_gb:CreateOrGetControl("richtext", "title_text", 0, 0, ui.CENTER_HORZ, ui.TOP, 0, 15, 0, 0)
    AUTO_CAST(title_text)
    title_text:SetText('{ol}{s20}Maximum Gear Score Ranking')
    info_gbox:Resize(frame:GetWidth() - 20, frame:GetHeight() - 105)
    info_gbox:SetScrollPos(0)
    frame:ShowWindow(1)
end

-- ヴェルニケランキング関連
function native_lang_SOLODUNGEON_RANKINGPAGE_FILL_RANK_CTRL(rankGbox, ctrlType, rank, week)

    if g.settings.use == 0 or g.settings.chatmode then
        base["SOLODUNGEON_RANKINGPAGE_FILL_RANK_CTRL"](rankGbox, ctrlType, rank, week)
    else
        native_lang_SOLODUNGEON_RANKINGPAGE_FILL_RANK_CTRL_(rankGbox, ctrlType, rank, week)
    end
end

function native_lang_SOLODUNGEON_RANKINGPAGE_FILL_RANK_CTRL_(rankGbox, ctrlType, rank, week)
    AUTO_CAST(rankGbox)
    local emblemSlotImageName = rankGbox:GetUserConfig("GUILD_EMBLEM_SLOT")
    local scoreInfo = session.soloDungeon.GetRankingByIndex(week, ctrlType, rank)
    if scoreInfo == nil then
        return
    end

    local rankText = GET_CHILD_RECURSIVELY(rankGbox, "rankText")
    rankText:SetTextByKey("rank", rank + 1)

    local familyName = g.names[scoreInfo.familyName] or scoreInfo.familyName
    if native_lang_is_translation(familyName) and not g.names[familyName] then
        familyName = native_lang_process_name(familyName)
    end

    local teamNameText = GET_CHILD_RECURSIVELY(rankGbox, "teamNameText")
    teamNameText:SetTextByKey("teamname", familyName)

    local charLevelText = GET_CHILD_RECURSIVELY(rankGbox, "charLevelText")
    charLevelText:SetTextByKey("charlevel", scoreInfo.level)

    local guildName = g.names[scoreInfo.guildName] or scoreInfo.guildName
    if native_lang_is_translation(guildName) and not g.names[guildName] then
        guildName = native_lang_process_name(guildName)
    end

    local guildNameText = GET_CHILD_RECURSIVELY(rankGbox, "guildNameText")
    guildNameText:SetTextByKey("guildname", guildName)

    local emblemCtrl = GET_CHILD_RECURSIVELY(rankGbox, "guildEmblem")
    if emblemCtrl ~= nil then
        local worldID = session.party.GetMyWorldIDStr()
        local emblemImgName = guild.GetEmblemImageName(scoreInfo:GetGuildIDStr(), worldID)
        emblemCtrl:SetImage(emblemSlotImageName)
        if emblemImgName ~= 'None' then
            emblemCtrl:SetFileName(emblemImgName)
            emblemCtrl:Invalidate()
        else
            if scoreInfo:GetGuildIDStr() ~= "0" then
                GetGuildEmblemImage("SOLODUNGEON_UPDATE_GUILD_EMBLEM_IMAGE", scoreInfo:GetGuildIDStr())
            end
        end
    end

    local cnt = scoreInfo:GetJobHistoryCount()
    local jobTreeList = {}
    local jobTreeGbox = GET_CHILD_RECURSIVELY(rankGbox, "jobTreeGbox")
    for i = 0, cnt - 1 do
        local jobID = scoreInfo:GetJobHistoryByIndex(i)
        local jobCls = GetClassByType("Job", jobID)
        if jobCls ~= nil then
            local icon = jobCls.Icon
            if icon ~= nil then
                local rankImage = jobTreeGbox:CreateOrGetControl("picture", "rankImage_" .. i + 1, 35 * i, 0, 35, 35)
                rankImage = tolua.cast(rankImage, "ui::CPicture")
                rankImage:SetImage(icon)
                rankImage:SetEnableStretch(1)
                rankImage:EnableHitTest(0)

                if jobTreeList[jobID] == nil then
                    jobTreeList[jobID] = 1
                else
                    jobTreeList[jobID] = jobTreeList[jobID] + 1
                end
            end
        end
    end

    local jobtext = ""
    for jobid, grade in pairs(jobTreeList) do
        -- 클래스 이름{@st41}
        local jobCls = GetClassByType("Job", jobid)

        local jobName = TryGetProp(jobCls, "Name")
        jobtext = jobtext .. ("{@st41}") .. jobName

        jobtext = jobtext .. ('{nl}')
    end
    jobTreeGbox:SetTextTooltip(jobtext)

    local maxStageText = GET_CHILD_RECURSIVELY(rankGbox, "maxStageText")
    maxStageText:SetTextByKey("maxstage", scoreInfo.stage)

    local clear_time = scoreInfo.clear_time
    if clear_time ~= 0 then
        clear_time = session.soloDungeon.GetClearTimeConvert(tonumber(clear_time))
    else
        clear_time = "03:00"
    end

    local killMonsterText = GET_CHILD_RECURSIVELY(rankGbox, "killMonsterText")
    killMonsterText:SetTextByKey("killmonster", clear_time)
end

-- キャラクター情報関連
function native_lang_SHOW_PC_COMPARE(frame, msg)
    local cid = acutil.getEventArgs(msg)
    local frame = ui.GetFrame("compare")
    frame:SetLayerLevel(102)

    if g.settings.use == 0 or g.settings.chatmode then
        return
    end
    local charNameRTxt = GET_CHILD_RECURSIVELY(frame, "charName", "ui::CRichText")
    local teamName = charNameRTxt:GetTextByKey("teamName")
    teamName = native_lang_process_name(teamName)

    local charName = charNameRTxt:GetTextByKey("charName")
    charName = native_lang_process_name(charName)

    charNameRTxt:SetTextByKey("teamName", teamName)
    charNameRTxt:SetTextByKey("charName", charName)
end

-- 週間ボスレイド関連
function native_lang_WEEKLY_BOSS_RANK_UPDATE()

    if g.settings.use == 0 or g.settings.chatmode then
        base["WEEKLY_BOSS_RANK_UPDATE"]()
    else
        native_lang_WEEKLY_BOSS_RANK_UPDATE_()
    end
end

function native_lang_WEEKLY_BOSS_RANK_UPDATE_()

    local frame = ui.GetFrame("induninfo")
    local rankListBox = GET_CHILD_RECURSIVELY(frame, "rankListBox", "ui::CGroupBox")
    local cnt = session.weeklyboss.GetRankInfoListSize()

    if cnt == 0 then
        return
    end
    for i = 1, cnt do
        local ctrlSet = GET_CHILD_RECURSIVELY(rankListBox, "CTRLSET_" .. i)
        local teamname = session.weeklyboss.GetRankInfoTeamName(i - 1)
        local org_name = teamname

        teamname = g.names[teamname] or teamname
        if native_lang_is_translation(teamname) then
            native_lang_process_name(teamname)
        end
        local name = GET_CHILD(ctrlSet, "attr_name_text", "ui::CRichText")
        name:SetTextByKey("value", teamname)

        if g.gear_scores then
            for _, score in ipairs(g.gear_scores) do
                if score[1] == org_name then
                    local text_gs = rankListBox:CreateOrGetControl('button', "text_gs" .. i, 215, (i - 1) * 73 + 50,
                        100, 25)
                    AUTO_CAST(text_gs)
                    text_gs:SetSkinName("None")
                    local score_text = "{@st66b}{s16}Max Gear Score : " .. score[4]
                    text_gs:SetText(score_text)
                    text_gs:SetEventScript(ui.LBUTTONDOWN, "native_lang_real_rank_frame")
                    text_gs:SetTextTooltip("{ol}Left click{nl}" .. " Open the Maximum Gear Score Ranking frame")
                    break
                end
            end
        end

        local btn = rankListBox:CreateOrGetControl('button', "BTN_" .. i, 225, (i - 1) * 73 + 5, 100, 25)
        tolua.cast(btn, "ui::CButton")
        btn:SetEventScript(ui.LBUTTONUP, "native_lang_MEMBERINFO_ONCLICK")
        btn:SetEventScriptArgString(ui.LBUTTONUP, org_name)
        btn:Resize(50, 25)
        btn:SetText("{ol}Info")
        btn:SetGravity(ui.RIGHT, ui.TOP)
        local rect = btn:GetMargin()
        btn:SetMargin(rect.left, rect.top + 45, rect.right + 25, rect.bottom)
    end
end

function native_lang_MEMBERINFO_ONCLICK(frame, ctrl, str, num)
    ui.Chat('/memberinfo ' .. str)
    local compare = ui.GetFrame("compare")
    compare:SetLayerLevel(102)
end

-- ギルド表示処理
function native_lang_GUILDINFO_INIT_PROFILE(frame)
    if g.settings.use == 0 or g.settings.chatmode then
        base["GUILDINFO_INIT_PROFILE"](frame)
    else
        native_lang_GUILDINFO_INIT_PROFILE_(frame)
    end
end

function native_lang_GUILDINFO_INIT_PROFILE_(frame)
    local guild = session.party.GetPartyInfo(PARTY_GUILD)
    if guild == nil then
        GUILDINFO_FORCE_CLOSE_UI()
        return
    end

    local guildObj = GET_MY_GUILD_OBJECT()
    local guildInfoTab = GET_CHILD_RECURSIVELY(frame, "guildinfo_")
    local guildName = GET_CHILD_RECURSIVELY(frame, "guildname")
    guildName:SetTextByKey("name", guild.info.name)

    local guildLvl = GET_CHILD_RECURSIVELY(guildInfoTab, "guildLvl")
    guildLvl:SetTextByKey('level', guildObj.Level)

    -- leader name
    local masterText = GET_CHILD_RECURSIVELY(guildInfoTab, 'guildMasterName')
    local leaderAID = guild.info:GetLeaderAID()
    local memberInfo = session.party.GetPartyMemberInfoByAID(PARTY_GUILD, leaderAID)

    if memberInfo ~= nil then
        local name = g.names[memberInfo:GetName()] or memberInfo:GetName()
        if native_lang_is_translation(memberInfo:GetName()) then
            name = native_lang_process_name(memberInfo:GetName())
        end
        masterText:SetText("{@st66b}" .. name .. "{/}")
    end

    -- opening date
    local openText = GET_CHILD_RECURSIVELY(guildInfoTab, 'foundtxt')
    local openDate = imcTime.ImcTimeToSysTime(guild.info.createTime)
    local openDateStr = string.format('%04d.%02d.%02d', openDate.wYear, openDate.wMonth, openDate.wDay) -- yyyy.mm.dd
    openText:SetTextByKey('date', openDateStr)

    -- member
    local count = session.party.GetAllMemberCount(PARTY_GUILD)
    local memberText = GET_CHILD_RECURSIVELY(guildInfoTab, 'memberNum')
    memberText:SetTextByKey('current', count)
    memberText:SetTextByKey('max', guild:GetMaxGuildMemberCount())

    -- asset
    GUILDINFO_PROFILE_INIT_ASSET(guildInfoTab)

    -- emblem
    GUILDINFO_PROFILE_INIT_EMBLEM(frame)
end

function native_lang_GUILDNOTICE_GET(code, ret_json)
    if g.settings.use == 0 or g.settings.chatmode then
        base["GUILDNOTICE_GET"](code, ret_json)
    else
        native_lang_GUILDNOTICE_GET_(code, ret_json)
    end
end

function native_lang_GUILDNOTICE_GET_(code, ret_json)
    if code ~= 200 then
        SHOW_GUILD_HTTP_ERROR(code, ret_json, "GUILDNOTICE_GET")
    end

    local frame = ui.GetFrame("guildinfo")
    local notifyText = GET_CHILD_RECURSIVELY(frame, 'noticeEdit')
    if notifyText:IsHaveFocus() == 0 then
        -- print(tostring(ret_json))
        ret_json = g.names[ret_json] or ret_json
        if native_lang_is_translation(ret_json) then
            ret_json = native_lang_process_name(ret_json)
        end
        notifyText:SetText(ret_json)
        notifyText:Invalidate()
    end
end

function native_lang_GUILDINFO_MEMBER_LIST_CREATE(memberCtrlBox, partyMemberInfo)
    if g.settings.use == 0 or g.settings.chatmode then
        base["GUILDINFO_MEMBER_LIST_CREATE"](memberCtrlBox, partyMemberInfo)
    else
        native_lang_GUILDINFO_MEMBER_LIST_CREATE_(memberCtrlBox, partyMemberInfo)
    end
end

function native_lang_GUILDINFO_MEMBER_LIST_CREATE_(memberCtrlBox, partyMemberInfo)
    if partyMemberInfo == nil then
        return
    end

    local aid = partyMemberInfo:GetAID()
    local memberCtrlSet = memberCtrlBox:CreateOrGetControlSet('guild_memberinfo', 'MEMBER_' .. aid, 0, 0)
    memberCtrlSet = AUTO_CAST(memberCtrlSet)
    memberCtrlSet:SetUserValue('AID', aid)

    local isOnline = true
    local pic_online = GET_CHILD_RECURSIVELY(memberCtrlSet, 'pic_online')
    local txt_location = GET_CHILD_RECURSIVELY(memberCtrlSet, 'txt_location')
    local ONLINE_IMG = memberCtrlSet:GetUserConfig('ONLINE_IMG')
    local OFFLINE_IMG = memberCtrlSet:GetUserConfig('OFFLINE_IMG')
    local MY_CHAR_BG_SKIN = memberCtrlSet:GetUserConfig('MY_CHAR_BG_SKIN')

    -- bg
    if aid == session.loginInfo.GetAID() then
        local bg = GET_CHILD_RECURSIVELY(memberCtrlSet, 'bg')
        bg:SetSkinName(MY_CHAR_BG_SKIN)
    end

    -- on/off & location
    local locationText = ""
    if partyMemberInfo:GetMapID() > 0 then
        local mapCls = GetClassByType("Map", partyMemberInfo:GetMapID())
        if mapCls ~= nil then
            pic_online:SetImage(ONLINE_IMG)
            locationText = string.format("[%s%d] %s", ScpArgMsg("Channel"), partyMemberInfo:GetChannel() + 1,
                mapCls.Name)
        end
    else
        isOnline = false
        pic_online:SetImage(OFFLINE_IMG)
        local logoutSec = partyMemberInfo:GetLogoutSec()
        if logoutSec >= 0 then
            locationText = GET_DIFF_TIME_TXT(logoutSec)
        else
            locationText = ScpArgMsg("LogoutLongTime")
        end
    end
    txt_location:SetTextByKey("value", locationText)
    txt_location:SetTextTooltip(locationText)

    -- name
    local txt_teamname = GET_CHILD_RECURSIVELY(memberCtrlSet, 'txt_teamname')
    local name = g.names[partyMemberInfo:GetName()] or partyMemberInfo:GetName()
    if native_lang_is_translation(name) then
        name = native_lang_process_name(name)
    end
    txt_teamname:SetTextByKey('value', name)
    txt_teamname:SetTextTooltip(partyMemberInfo:GetName())

    -- job
    local jobID = partyMemberInfo:GetIconInfo().repre_job
    local jobCls = GetClassByType('Job', jobID)
    local jobName = GET_JOB_NAME(jobCls, partyMemberInfo:GetIconInfo().gender)
    if jobName ~= nil then
        local jobText = GET_CHILD_RECURSIVELY(memberCtrlSet, 'jobText')
        jobText:SetTextByKey('job', jobName)
    end

    -- level
    if isOnline == true then
        local levelText = GET_CHILD_RECURSIVELY(memberCtrlSet, 'levelText')
        levelText:SetTextByKey('level', partyMemberInfo:GetLevel())
    end
    -- claim
    local txt_duty = GET_CHILD_RECURSIVELY(memberCtrlSet, 'txt_duty')
    local grade = partyMemberInfo.grade

    local guild = GET_MY_GUILD_INFO()
    local leaderAID = guild.info:GetLeaderAID()
    if leaderAID == aid then
        local dutyName = "{ol}{#FFFF00}" .. ScpArgMsg("GuildMaster") .. "{/}{/}"
        dutyName = dutyName .. " " .. guild:GetDutyName(grade)
        txt_duty:SetTextByKey("value", dutyName)
    else
        local claimName = GET_CLAIM_NAME_BY_AIDX(aid)
        if claimName == nil then
            claimName = ""
            GetPlayerMemberTitle("ON_GUILDINFO_MEMBER_TITLE_GET", aid)
        else
            claimName = g.names[claimName] or claimName
            if native_lang_is_translation(claimName) then
                claimName = native_lang_process_name(claimName)
            end
        end
        txt_duty:SetTextByKey("value", claimName)
    end

    -- contribution
    local memberObj = GetIES(partyMemberInfo:GetObject())
    local contributionText = GET_CHILD_RECURSIVELY(memberCtrlSet, 'contributionText')
    contributionText:SetTextByKey('contribution', memberObj.Contribution)

    memberCtrlSet:SetEventScript(ui.RBUTTONDOWN, 'POPUP_GUILD_MEMBER')
end

-- ダメージメーター処理
function native_lang_DAMAGE_METER_GAUGE_SET(ctrl, leftStr, point, rightStr, skin)

    if g.settings.use == 0 or g.settings.chatmode then
        base["DAMAGE_METER_GAUGE_SET"](ctrl, leftStr, point, rightStr, skin)
    else
        native_lang_DAMAGE_METER_GAUGE_SET_(ctrl, leftStr, point, rightStr, skin)
    end
end

function native_lang_DAMAGE_METER_GAUGE_SET_(ctrl, leftStr, point, rightStr, skin)

    local font = "{@st42b}{ds}{s12}"
    leftStr = leftStr:gsub("{@st42b}{ds}{s12}", ""):match("^%s*(.-)%s*$")
    leftStr = g.names[leftStr] or leftStr
    leftStr = font .. leftStr

    local leftText = GET_CHILD_RECURSIVELY(ctrl, 'leftText')
    leftText:SetTextByKey('value', leftStr)

    local rightText = GET_CHILD_RECURSIVELY(ctrl, 'rightText')
    rightText:SetTextByKey('value', rightStr)

    local guage = GET_CHILD_RECURSIVELY(ctrl, 'gauge')
    guage:SetPoint(point, 100)
    guage:SetSkinName(skin)

end

-- 自分の発言翻訳
local CHO = {
    r = "ㄱ",
    R = "ㄲ",
    s = "ㄴ",
    e = "ㄷ",
    E = "ㄸ",
    f = "ㄹ",
    a = "ㅁ",
    q = "ㅂ",
    Q = "ㅃ",
    t = "ㅅ",
    T = "ㅆ",
    d = "ㅇ",
    w = "ㅈ",
    W = "ㅉ",
    c = "ㅊ",
    z = "ㅋ",
    x = "ㅌ",
    v = "ㅍ",
    g = "ㅎ"
}
local JUNG = {
    k = "ㅏ",
    o = "ㅐ",
    i = "ㅑ",
    O = "ㅒ",
    j = "ㅓ",
    p = "ㅔ",
    u = "ㅕ",
    P = "ㅖ",
    h = "ㅗ",
    hk = "ㅘ",
    ho = "ㅙ",
    hl = "ㅚ",
    y = "ㅛ",
    n = "ㅜ",
    nj = "ㅝ",
    np = "ㅞ",
    nl = "ㅟ",
    b = "ㅠ",
    m = "ㅡ",
    ml = "ㅢ",
    l = "ㅣ"
}
local JONG = {
    r = "ㄱ",
    R = "ㄲ",
    rt = "ㄳ",
    s = "ㄴ",
    sw = "ㄵ",
    sg = "ㄶ",
    e = "ㄷ",
    f = "ㄹ",
    fr = "ㄺ",
    fa = "ㄻ",
    fq = "ㄼ",
    ft = "ㄽ",
    fx = "ㄾ",
    fv = "ㄿ",
    fg = "ㅀ",
    a = "ㅁ",
    q = "ㅂ",
    qt = "ㅄ",
    t = "ㅅ",
    T = "ㅆ",
    d = "ㅇ",
    w = "ㅈ",
    c = "ㅊ",
    z = "ㅋ",
    x = "ㅌ",
    v = "ㅍ",
    g = "ㅎ"
}
local CHO_IDX = {
    ["ㄱ"] = 0,
    ["ㄲ"] = 1,
    ["ㄴ"] = 2,
    ["ㄷ"] = 3,
    ["ㄸ"] = 4,
    ["ㄹ"] = 5,
    ["ㅁ"] = 6,
    ["ㅂ"] = 7,
    ["ㅃ"] = 8,
    ["ㅅ"] = 9,
    ["ㅆ"] = 10,
    ["ㅇ"] = 11,
    ["ㅈ"] = 12,
    ["ㅉ"] = 13,
    ["ㅊ"] = 14,
    ["ㅋ"] = 15,
    ["ㅌ"] = 16,
    ["ㅍ"] = 17,
    ["ㅎ"] = 18
}
local JUNG_IDX = {
    ["ㅏ"] = 0,
    ["ㅐ"] = 1,
    ["ㅑ"] = 2,
    ["ㅒ"] = 3,
    ["ㅓ"] = 4,
    ["ㅔ"] = 5,
    ["ㅕ"] = 6,
    ["ㅖ"] = 7,
    ["ㅗ"] = 8,
    ["ㅘ"] = 9,
    ["ㅙ"] = 10,
    ["ㅚ"] = 11,
    ["ㅛ"] = 12,
    ["ㅜ"] = 13,
    ["ㅝ"] = 14,
    ["ㅞ"] = 15,
    ["ㅟ"] = 16,
    ["ㅠ"] = 17,
    ["ㅡ"] = 18,
    ["ㅢ"] = 19,
    ["ㅣ"] = 20
}
local JONG_IDX = {
    [""] = 0,
    ["ㄱ"] = 1,
    ["ㄲ"] = 2,
    ["ㄳ"] = 3,
    ["ㄴ"] = 4,
    ["ㄵ"] = 5,
    ["ㄶ"] = 6,
    ["ㄷ"] = 7,
    ["ㄹ"] = 8,
    ["ㄺ"] = 9,
    ["ㄻ"] = 10,
    ["ㄼ"] = 11,
    ["ㄽ"] = 12,
    ["ㄾ"] = 13,
    ["ㄿ"] = 14,
    ["ㅀ"] = 15,
    ["ㅁ"] = 16,
    ["ㅂ"] = 17,
    ["ㅄ"] = 18,
    ["ㅅ"] = 19,
    ["ㅆ"] = 20,
    ["ㅇ"] = 21,
    ["ㅈ"] = 22,
    ["ㅊ"] = 23,
    ["ㅋ"] = 24,
    ["ㅌ"] = 25,
    ["ㅍ"] = 26,
    ["ㅎ"] = 27
}
function ConvertEngToHangul(input)
    local res = ""
    local len = string.len(input)
    local i = 1
    while i <= len do
        local c1 = string.sub(input, i, i)
        local c2 = string.sub(input, i + 1, i + 1)
        local c3 = string.sub(input, i + 2, i + 2)
        -- 初声(Cho)があるかチェック
        if CHO[c1] then
            local cho = CHO[c1]
            local jung = nil
            local jong = nil
            local consumed = 1
            -- 中声(Jung)チェック (2文字合成含む)
            if i + 1 <= len and JUNG[c2] then
                -- 複合母音チェック (hk, ho 等)
                if i + 2 <= len and JUNG[c2 .. c3] then
                    jung = JUNG[c2 .. c3]
                    consumed = 3
                else
                    jung = JUNG[c2]
                    consumed = 2
                end
                -- 終声(Jong)チェック
                if i + consumed <= len then
                    local next_c = string.sub(input, i + consumed, i + consumed)
                    local next_c2 = string.sub(input, i + consumed + 1, i + consumed + 1)
                    -- ここで最も重要なのは、「次の文字の打鍵が、次の音節の中声（母音）ではないこと」
                    if CHO[next_c] and not JUNG[next_c] then
                        -- 複合終声チェック (rt, sw 等)
                        if i + consumed + 1 <= len and JONG[next_c .. next_c2] and
                            -- 次の次の文字が母音ではないことを確認 (貪欲防止)
                            not JUNG[string.sub(input, i + consumed + 2, i + consumed + 2)] then
                            jong = JONG[next_c .. next_c2]
                            consumed = consumed + 2
                            -- 単独終声チェック
                        elseif JONG[next_c] and -- 次の次の文字が母音ではないことを確認 (貪欲防止)
                        not JUNG[next_c2] then
                            -- ただし、次の文字が「初声として利用され、次の音節の中声と続く」ケースを除外する必要があるが、
                            -- 既存のロジックではこれを完全に分離するのは困難。ここでは貪欲な終声読み込みを少し緩和する
                            jong = JONG[next_c]
                            consumed = consumed + 1
                        end
                    end
                end
            end
            if cho and jung then
                -- Unicode結合: 0xAC00 + (初声*588) + (中声*28) + 終声
                local code = 0xAC00 + (CHO_IDX[cho] * 588) + (JUNG_IDX[jung] * 28) + (JONG_IDX[jong or ""] or 0)
                -- Lua 5.1でのUnicode文字生成 (UTF-8エンコード)
                local char = ""
                if code <= 0x7FF then
                    char = string.char(math.floor(code / 64) + 192, code % 64 + 128)
                elseif code <= 0xFFFF then
                    char = string.char(math.floor(code / 4096) + 224, math.floor((code % 4096) / 64) + 128,
                        code % 64 + 128)
                end
                local used_input = string.sub(input, i, i + consumed - 1)
                --[[ts(string.format("[IME DEBUG] Result: %s (Used: '%s' | Cho:%s, Jung:%s, Jong:%s)", char, used_input,
                    cho, jung, jong or "None"))]]
                res = res .. char
                i = i + consumed
            else
                res = res .. c1
                i = i + 1
            end
        else
            res = res .. c1
            i = i + 1
        end
    end
    return res
end

function Hangul_keymap_frame_open()

    local frame = ui.CreateNewFrame("notice_on_pc", "hangul_keymap", 0, 0, 0, 0)
    AUTO_CAST(frame)
    frame:SetSkinName("bg2")
    frame:Resize(360, 200) -- ★ コンパクト化

    frame:SetLayerLevel(999)

    frame:EnableHittestFrame(1)
    frame:EnableHitTest(1)
    frame:EnableMove(1)
    frame:RemoveAllChild()
    local close_button = frame:CreateOrGetControl("button", "close_button", 0, 0, 30, 30)
    AUTO_CAST(close_button)
    close_button:SetImage("testclose_button")
    close_button:SetGravity(ui.RIGHT, ui.TOP)
    close_button:SetEventScript(ui.LBUTTONUP, "Hangul_keymap_frame_close")

    local gbox = frame:CreateOrGetControl("groupbox", "gbox", 10, 35, 340, 170)
    AUTO_CAST(gbox)

    -- gbox:EnableScrollBar(1)

    local y = 0
    y = Hangul_keymap_draw_section_3col(gbox, "■ 初声", CHO, y)
    y = Hangul_keymap_draw_section_3col(gbox, "■ 中声", JUNG, y)
    y = Hangul_keymap_draw_section_3col(gbox, "■ 終声", JONG, y)
    local chat_frame = ui.GetFrame("chat")
    frame:SetPos(chat_frame:GetX() + 320, chat_frame:GetY() - 210) -- ★ 画面中央
    frame:ShowWindow(1)
end

function Hangul_keymap_draw_section_3col(gbox, title, tbl, y)
    local title_ctrl = gbox:CreateOrGetControl("richtext", "t_" .. y, 0, y)
    AUTO_CAST(title_ctrl)
    title_ctrl:SetText("{ol}{s13}" .. title)
    y = y + 22

    local x_list = {0, 115, 230} -- ★ 3列
    local col = 1
    local row_y = y

    for k, v in pairs(tbl) do
        local txt = gbox:CreateOrGetControl("richtext", "c_" .. row_y .. "_" .. col, x_list[col], row_y)
        AUTO_CAST(txt)
        txt:SetText(string.format("{ol}{s18}%s→%s", k, v))

        col = col + 1
        if col > 3 then
            col = 1
            row_y = row_y + 18
        end
    end

    return row_y + 24
end

function Hangul_keymap_frame_close(parent, ctrl)
    ui.DestroyFrame(parent:GetName())
end

function native_lang_CHAT_OPEN_INIT()
    if g.settings.recv_lang ~= "ko_only" then
        return
    end
    Hangul_keymap_frame_open()
end

function native_lang_CHAT_CLOSE_SCP()
    if g.settings.recv_lang ~= "ko_only" then
        return
    end
    local frame = ui.GetFrame("hangul_keymap")
    Hangul_keymap_frame_close(frame)
end

function native_lang_check_my_speech(frame)
    local recv_file_handle = io.open(g.my_recv_dat_path, "r")
    if recv_file_handle then
        local new_chat_content = recv_file_handle:read("*all")
        recv_file_handle:close()
        os.remove(g.my_recv_dat_path)
        if new_chat_content and new_chat_content ~= "" then
            if g.language == "kr" and g.settings.recv_lang == "jp_only" then
                native_lang_create_confirm_frame(new_chat_content)
            else
                ui.Chat(new_chat_content)
            end
        end
    end
    return 1
end

function native_lang_msg_processing_send(input_text)
    local text_to_process = input_text
    text_to_process = text_to_process:gsub("(@dicID_%^%*%$.-%$%*%^)", "{%1}")
    local separated_parts = {}
    for m in text_to_process:gmatch("({(.-)})") do
        table.insert(separated_parts, m)
    end
    local processed_text = text_to_process:gsub("{(.-)}", " ")
    local anti_patterns = {",", "`", "~~", "&", "!", ":", "/", "%[", "%]", "%{", "%}", "%'", "%\"", "//"}

    for _, p in ipairs(anti_patterns) do
        processed_text = processed_text:gsub(p, " ")
    end
    processed_text = processed_text:gsub("%%", " percent ")
    processed_text = processed_text:gsub("%s+", " "):match("^%s*(.-)%s*$")
    return processed_text
end

function native_lang_pass_through_chat(chat_content, msg)
    local content_to_send = chat_content or msg
    ui.Chat(content_to_send)
    if g_uiChatHandler ~= nil then
        local func = _G[g_uiChatHandler]
        if func ~= nil then
            func(content_to_send)
        end
    end
end

function native_lang_create_confirm_frame(msg)
    g.confirm_msg = msg
    local chat_frame = ui.GetFrame("chat")
    if not chat_frame or chat_frame:IsVisible() == 0 then
        return
    end
    local mainchat = chat_frame:GetChild("mainchat")
    if not mainchat then
        return
    end
    local frame = ui.CreateNewFrame("notice_on_pc", "native_lang_confirm", 0, 0, 0, 0)
    AUTO_CAST(frame)
    frame:SetSkinName("none")
    frame:SetTitleBarSkin("None")
    frame:SetLayerLevel(chat_frame:GetLayerLevel() + 1)
    frame:EnableHittestFrame(0)
    frame:EnableMove(0)
    local mainchat_width = mainchat:GetWidth()
    local mainchat_x = chat_frame:GetX() + mainchat:GetX()
    local mainchat_y = chat_frame:GetY() + mainchat:GetY()
    local height = 50 -- 確認メッセージの高さ
    frame:Resize(mainchat_width + 10, height)
    frame:SetPos(mainchat_x + 310, mainchat_y)
    frame:RemoveAllChild()
    local trans_msg = frame:CreateOrGetControl('edit', 'trans_msg', 5, 0, mainchat_width - 60, 35)
    AUTO_CAST(trans_msg)
    local clean_msg_body = msg
    local command, body = string.match(msg, "^(/%S+)%s*(.*)")
    if command then
        -- /w Name や /f Name の形式にも対応
        if string.lower(command) == "/w" or string.lower(command) == "/f" then
            local target, actual_body = string.match(body, "^(%S+)%s*(.*)")
            if actual_body then
                clean_msg_body = actual_body -- /w Name の後のメッセージ本文
            else
                clean_msg_body = "" -- /w Name のみの場合
            end
        else
            clean_msg_body = body or "" -- /p や /g の後のメッセージ本文
        end
    end
    trans_msg:SetText(clean_msg_body)
    trans_msg:SetFontName("white_18_ol")
    trans_msg:SetEventScript(ui.ENTERKEY, "native_lang_confirm_send_via_frame")
    local cancel = frame:CreateOrGetControl('button', 'cancel', 0, 0, 60, height - 15)
    AUTO_CAST(cancel)
    cancel:SetGravity(ui.RIGHT, ui.TOP)
    cancel:SetSkinName("test_red_button")
    cancel:SetText("{ol}Cancel")
    cancel:SetEventScript(ui.LBUTTONUP, "native_lang_hide_confirm_frame")

    frame:ShowWindow(1)
end

function native_lang_hide_confirm_frame(frame)
    ui.DestroyFrame(frame:GetName())
    local frame = ui.GetFrame("hangul_keymap")
    Hangul_keymap_frame_close(frame)
end

function native_lang_confirm_send_via_frame(frame, ctrl)
    native_lang_pass_through_chat(g.confirm_msg)
    g.confirm_msg = ""
    native_lang_hide_confirm_frame(frame)
end

function native_lang_convert_and_confirm(content_to_convert, prefix)
    local hangul_text = ConvertEngToHangul(content_to_convert)
    local full_text = prefix .. hangul_text
    local final_text = string.gsub(full_text, "/kr%s*", "")
    local chat = ui.GetFrame("chat")
    chat:ShowWindow(1)
    native_lang_create_confirm_frame(final_text)
    return
end

function native_lang_UI_CHAT(my_frame, my_msg)
    local msg = g.get_event_args(my_msg)
    native_lang_UI_CHAT_(msg)
end

function native_lang_UI_CHAT_(msg)
    if not msg then
        return
    end

    local translatable_types = {
        ["/p "] = true,
        ["/g "] = true,
        ["/y "] = true,
        ["/f "] = true,
        ["/gn "] = true,
        ["/w "] = true
    }
    local msg_type = nil
    local msg_body = msg
    if g.settings.recv_lang == "ko_only" then
        local content = msg
        local prefix = ""
        local is_command = false
        if string.sub(msg, 1, 1) == "/" then
            is_command = true
            local command, body = string.match(msg, "^(/%S+)%s*(.*)")
            if string.sub(msg, 1, 3) == "/kr" then
                content = string.match(msg, "^/kr%s*(.*)") or ""
                prefix = ""
            elseif command and translatable_types[string.lower(command) .. " "] then
                prefix = string.lower(command) .. " "
                if prefix == "/w " or prefix == "/f " then
                    local target, actual_body = string.match(body, "^(%S+)%s*(.*)")
                    if target then
                        prefix = prefix .. target .. " "
                        content = actual_body or ""
                    else
                        content = body or ""
                    end
                else
                    content = body or ""
                end
                prefix = prefix .. "/kr "
            else
                native_lang_pass_through_chat(msg, msg)
                return
            end
        end
        if not is_command then
            prefix = "/kr "
        end
        native_lang_convert_and_confirm(content, prefix)
        return
    end
    if string.sub(msg, 1, 1) == "/" and string.len(msg) >= 4 and string.sub(msg, 4, 4) == "/" then
        local new_msg = string.sub(msg, 4)
        native_lang_pass_through_chat(new_msg, msg)
        return
    end

    local translatable_types = {
        ["/p "] = true,
        ["/g "] = true,
        ["/y "] = true,
        ["/f "] = true,
        ["/gn "] = true,
        ["/w "] = true
    }

    local msg_type = nil
    local msg_body = msg

    if string.sub(msg, 1, 1) == "/" then

        local command, body = string.match(msg, "^(/%S+)%s*(.*)")

        if not command or not translatable_types[string.lower(command) .. " "] then

            native_lang_pass_through_chat(msg, msg)
            return
        end

        msg_type = string.lower(command) .. " "
        msg_body = body or ""
    else

        msg_type = " "
    end

    if msg_type == "/w " or msg_type == "/f " then
        local target, actual_body = string.match(msg_body, "^(%S+)%s*(.*)")
        if target then
            msg_type = msg_type .. target .. " "
            msg_body = (actual_body or "")
        end
    end

    if string.sub(string.gsub(msg_body, "^%s*", ""), 1, 1) == "/" then
        native_lang_pass_through_chat(msg, msg)
        return
    end

    local org_msg_return = msg_body
    local processed_body = native_lang_msg_processing_send(msg_body)
    processed_body = string.gsub(processed_body, "Party#", "")

    if processed_body == "" then
        native_lang_pass_through_chat(msg, msg)
        return
    end

    if msg_type == " " then
        msg_type = ""
    end

    local line_to_send = string.format("%s:::%s:::%s", msg_type, org_msg_return, processed_body)

    local recv_file_handle = io.open(g.my_recv_dat_path, "r")
    if recv_file_handle then
        recv_file_handle:close()
        os.remove(g.my_recv_dat_path)
    end

    local tmp_send_path = g.my_send_dat_path .. ".tmp"
    local send_file, err = io.open(tmp_send_path, "w")
    if send_file then
        send_file:write(line_to_send)
        send_file:close()
        os.rename(tmp_send_path, g.my_send_dat_path)
    else
        print(string.format("Error opening %s for writing: %s", tmp_send_path, tostring(err)))
    end

end

-- コロニー関連
function native_lang_draw_colony_msg(chatframe, gbox, msg, chat_id)

    local name1, name2, guild_name, trans_str = "", "", "", ""
    if string.find(msg, "BattleChat_Colony_GuildMember{Name}HasKilledBy{From}OfGuild{FromGuild}") then
        name1 = msg:match("{#99CC00}(.-){/}")
        name2 = msg:match("{#FF5500}(.-){/}")
        guild_name = msg:match("%$%*%$FromGuild%$%*%${#FF5500}(.-){/}")
        trans_str = msg
        trans_str = trans_str:gsub("({#99CC00})(.-)({/})", "%1" .. (g.names[name1] or name1) .. "%3")
        trans_str = trans_str:gsub("(%$%*%$From%$%*%${#FF5500})(.-)({/})", "%1" .. (g.names[name2] or name2) .. "%3")
        trans_str = trans_str:gsub("(%$%*%$FromGuild%$%*%${#FF5500})(.-)({/})",
            "%1" .. (g.names[guild_name] or guild_name) .. "%3")
        chatframe:SetUserValue("CHAT_ID", chat_id)
    elseif string.find(msg, "BattleChat_Colony_GuildMember{Name}Killed{Target}OfGuild{TargetGuild}") then
        name1 = msg:match("{#99CC00}(.-){/}")
        name2 = msg:match("%$%*%$Target%$%*%${#FF5500}(.-){/}")
        guild_name = msg:match("%$%*%$TargetGuild%$%*%${#FF5500}(.-){/}")
        trans_str = msg
        trans_str = trans_str:gsub("({#99CC00})(.-)({/})", "%1" .. (g.names[name1] or name1) .. "%3")
        trans_str = trans_str:gsub("(%$%*%$Target%$%*%${#FF5500})(.-)({/})", "%1" .. (g.names[name2] or name2) .. "%3")
        trans_str = trans_str:gsub("(%$%*%$TargetGuild%$%*%${#FF5500})(.-)({/})",
            "%1" .. (g.names[guild_name] or guild_name) .. "%3")
        chatframe:SetUserValue("CHAT_ID", chat_id)
    end
    g.chat_ids[tostring(chat_id)] = {
        msg_type = "",
        name = "",
        org_name = "",
        org_msg = msg,
        proc_msg = trans_str,
        separate_msg = "None",
        trans_msg = trans_str
    }

    g.temp_msg = g.temp_msg or {}
    local data_to_write = {
        chat_id = tostring(chat_id),
        trans_msg = trans_str,
        org_msg = msg,
        frame_name = chatframe:GetName(),
        gbox_name = gbox:GetName(),
        msg_type = "Battle",
        name = " "
    }
    table.insert(g.temp_msg, data_to_write)
    chatframe:StopUpdateScript("native_lang_write_to_recv_dat")
    chatframe:RunUpdateScript("native_lang_write_to_recv_dat", 0.1)
    return
end

function native_lang_ON_COLONYWAR_GUILD_KILL_MSG(frame, msg, argstr, argnum)
    native_lang_ON_COLONYWAR_GUILD_KILL_MSG_(frame, msg, argstr, argnum)
end

function native_lang_ON_COLONYWAR_GUILD_KILL_MSG_(frame, msg, argstr, argnum)

    local COLONYWAR_OFFSET_Y = 240
    local splitedString = StringSplit(argstr, "#")
    local killerIcon = splitedString[1]
    local selfIcon = splitedString[2]
    local killerName = splitedString[3]
    killerName = g.names[killerName] or killerName
    local selfName = splitedString[4]
    selfName = g.names[selfName] or selfName
    local targetGuildName = splitedString[5]
    targetGuildName = g.names[targetGuildName] or targetGuildName

    local isKilled = splitedString[6]
    local isMyGuildKilled = isKilled == "KILL"
    frame:SetOffset(frame:GetGlobalX(), COLONYWAR_OFFSET_Y)
    frame:ShowWindow(1)
    frame:SetDuration(3)

    local text = frame:GetChild("text")
    if isMyGuildKilled then
        local msgString = ScpArgMsg("Colony_GuildMember{Name}Killed{Target}OfGuild{TargetGuild}", "Name",
            "{#99CC00}" .. killerName .. "{/}", "Target", "{#FF5500}" .. selfName .. "{/}", "TargetGuild",
            "{#FF5500}" .. targetGuildName .. "{/}")
        text:SetTextByKey("value", msgString)

    else
        local msgString = ScpArgMsg("Colony_GuildMember{Name}HasKilledBy{From}OfGuild{FromGuild}", "Name",
            "{#99CC00}" .. selfName .. "{/}", "From", "{#FF5500}" .. killerName .. "{/}", "FromGuild",
            "{#FF5500}" .. targetGuildName .. "{/}")
        text:SetTextByKey("value", "{#FFFFFF}" .. msgString)

    end
end

-- パーティー関連
function native_lang_PARTYINFO_UPDATE(frame, msg, argStr, argNum)

    if g.settings.use == 0 or g.settings.chatmode then
        return
    end
    local list = session.party.GetPartyMemberList(PARTY_NORMAL)
    local count = list:Count()
    if count == 1 then
        return
    end
    local frame = ui.GetFrame("partyinfo")
    for i = 0, count - 1 do
        local partyMemberInfo = list:Element(i)
        local partyInfoCtrlSet = frame:GetChild('PTINFO_' .. partyMemberInfo:GetAID())
        if partyInfoCtrlSet ~= nil then
            local nameObj = partyInfoCtrlSet:GetChild('name_text')
            local nameRichText = tolua.cast(nameObj, "ui::CRichText")
            local name = nameRichText:GetTextByKey("name")
            if native_lang_is_translation(name) then
                local font = name:match("({.-})")
                name = name:gsub("{.-}", ""):match("^%s*(.-)%s*$")
                name = native_lang_process_name(name)
                if font then
                    name = font .. name
                end
                nameRichText:SetTextByKey("name", name)
            end
        end
    end
end

function native_lang_SET_PARTYINFO_ITEM(my_frame, my_msg)

    local frame, msg, partyMemberInfo, count, makeLogoutPC, leaderFID, isCorsairType, ispipui, partyID =
        g.get_event_args(my_msg)

    local party = ui.GetFrame("party")
    local gbox = party:GetChild("gbox")
    AUTO_CAST(gbox)
    local memberlist = gbox:GetChild("memberlist")
    AUTO_CAST(memberlist)
    local name = partyMemberInfo:GetName()
    local partyInfoCtrlSet = GET_CHILD(memberlist, 'PTINFO_' .. partyMemberInfo:GetAID())
    if partyInfoCtrlSet ~= nil then
        AUTO_CAST(partyInfoCtrlSet)
        local lvbox = partyInfoCtrlSet:GetChild("lvbox")
        AUTO_CAST(lvbox)
        local name_x = lvbox:GetX() + lvbox:GetWidth()
        local name_y = lvbox:GetY() + 5
        local name_text = partyInfoCtrlSet:GetChild("name_text")
        if name_text then
            partyInfoCtrlSet:RemoveChild("name_text")
        end
        name_text = partyInfoCtrlSet:CreateOrGetControl('richtext', 'name_text', name_x, name_y, 120, 20)
        AUTO_CAST(name_text)
        if native_lang_is_translation(name) then
            name = native_lang_process_name(name)
        end
        name_text:SetText("{@st43b}{s14}" .. name)
        local map_cls = GetClassByType("Map", partyMemberInfo:GetMapID())
        if map_cls then
            local combined_string = ScpArgMsg("PartyMemberMapNChannel", "Name", name, "Mapname", map_cls.Name, "ChNo",
                partyMemberInfo:GetChannel() + 1)
            name_text:SetText("{@st43b}{s14}" .. combined_string)
        end
    end
end

function native_lang_PARTY_OPEN(my_frame, my_msg)

    local party = ui.GetFrame("party")
    local memberlist = GET_CHILD_RECURSIVELY(party, "memberlist")
    local list = session.party.GetPartyMemberList(PARTY_NORMAL)
    local count = list:Count()
    for i = 0, count - 1 do
        local partyMemberInfo = list:Element(i)
        local partyInfoCtrlSet = GET_CHILD(memberlist, 'PTINFO_' .. partyMemberInfo:GetAID())
        local name = partyMemberInfo:GetName()
        if partyInfoCtrlSet ~= nil then
            AUTO_CAST(partyInfoCtrlSet)
            local lvbox = partyInfoCtrlSet:GetChild("lvbox")
            AUTO_CAST(lvbox)
            local name_x = lvbox:GetX() + lvbox:GetWidth()
            local name_y = lvbox:GetY() + 5
            local name_text = GET_CHILD(partyInfoCtrlSet, "name_text")
            if name_text then
                partyInfoCtrlSet:RemoveChild("name_text")
            end
            name_text = partyInfoCtrlSet:CreateOrGetControl('richtext', 'name_text', name_x, name_y, 120, 20)
            AUTO_CAST(name_text)
            if native_lang_is_translation(name) then
                name = native_lang_process_name(name)
            end
            name_text:SetText("{@st43b}{s14}" .. name)
            local map_cls = GetClassByType("Map", partyMemberInfo:GetMapID())
            if map_cls then
                local combined_string = ScpArgMsg("PartyMemberMapNChannel", "Name", name, "Mapname", map_cls.Name,
                    "ChNo", partyMemberInfo:GetChannel() + 1)
                name_text:SetText("{@st43b}{s14}" .. combined_string)
            end

        end
    end
end

--[[local text_needs_trans = native_lang_is_translation_msg(proc_msg)
    local name_needs_trans = native_lang_is_translation(original_name)
    local has_item_link = (g.chat_ids[tostring(chat_id)].separate_msg ~= "None")
    if text_needs_trans or name_needs_trans or has_item_link then
        local should_translate = true

        if g.lang == "ja" then
            if WITH_JAPANESE(org_msg) and not WITH_HANGLE(org_msg) then
                if WITH_JAPANESE(original_name) and not WITH_HANGLE(original_name) then
                    should_translate = false
                end
            end
        elseif g.lang == "ko" then
            if WITH_HANGLE(org_msg) and not WITH_JAPANESE(org_msg) then
                if WITH_HANGLE(original_name) and not WITH_JAPANESE(original_name) then
                    should_translate = false
                end
            end
        end
        if should_translate or has_item_link then

        end
    end]]
