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
local addonName = "NATIVE_LANG"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.0.8"
local exe = "0.0.3"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

local acutil = require("acutil")
local json = require('json')
local os = require("os")

--[[local folder_path = string.format("../addons/%s", addonNameLower)
os.execute('mkdir "' .. folder_path .. '"')]]

g.settings_location = string.format('../addons/%s/settings.json', addonNameLower)
g.send_msg = string.format('../addons/%s/send_msg.dat', addonNameLower)
g.recv_msg = string.format('../addons/%s/recv_msg.dat', addonNameLower)
g.send_name = string.format('../addons/%s/send_name.dat', addonNameLower)
g.recv_name = string.format('../addons/%s/recv_name.dat', addonNameLower)
g.restart = string.format('../addons/%s/restart.dat', addonNameLower)
g.gear_score = string.format('../addons/%s/gear_score.dat', addonNameLower)

local base = {}

function g.SetupHook(func, baseFuncName)
    local addonUpper = string.upper(addonName)
    local replacementName = addonUpper .. "_BASE_" .. baseFuncName
    if (_G[replacementName] == nil) then
        _G[replacementName] = _G[baseFuncName];
        _G[baseFuncName] = func
    end
    base[baseFuncName] = _G[replacementName]
end

function g.split(str, sep)
    local parts = {}
    for part in str:gmatch("([^" .. sep .. "]+)") do
        table.insert(parts, part)
    end
    return parts
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
        (code >= 0x4E00 and code <= 0x9FFF) then -- 漢字
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

function native_lang_is_translation(str)
    if g.lang == "ja" then
        return WITH_HANGLE(str)
    elseif g.lang == "ko" then
        return WITH_JAPANESE(str)
    elseif g.lang == "en" then
        return WITH_HANGLE(str) or WITH_JAPANESE(str)
    end
    return false
end

function native_lang_save_settings()
    acutil.saveJSON(g.settings_location, g.settings)
end

function native_lang_load_settings()

    local settings = acutil.loadJSON(g.settings_location, g.settings)

    local lang = option.GetCurrentCountry()
    if lang == "Japanese" then
        g.lang = "ja"
    elseif lang == "kr" then
        g.lang = "ko"
    else
        g.lang = "en"
    end

    if not settings then

        settings = {
            use = 1,
            lang = g.lang
        }
    end
    g.settings = settings

    local function native_lang_open_or_create_file(file_path)
        local file = io.open(file_path, "r")
        if not file then
            file = io.open(file_path, "w")
            if file then
                file:close()
            end
        else
            file:close()
        end
    end

    native_lang_open_or_create_file(g.recv_name)

    local files = {g.send_name, g.send_msg, g.recv_msg}

    if not g.load then
        for _, file in ipairs(files) do
            os.remove(file)
            native_lang_open_or_create_file(file)
        end
        g.load = true
    end

    if not g.settings.chatmode then
        g.settings.chatmode = false
    end

    native_lang_save_settings()

    local function native_lang_name_table_create()

        g.names = {}
        local name_file = io.open(g.recv_name, "r")

        if name_file then
            for line in name_file:lines() do
                local left_name, right_name = line:match("^(.-):::(.*)$")
                if left_name and right_name then
                    g.names[left_name] = right_name
                end
            end
            name_file:close()
        end
    end
    native_lang_name_table_create()

    g.gear_scores = {}
    local seen_keys = {} -- 追加したorg_nameを記録するためのテーブル
    local file = io.open(g.gear_score, "r")

    if file then
        for line in file:lines() do

            local org_name, teamName, guildIdx, value = line:match("([^:]+):::(%S+):::(%d+):::(%d+)")

            if org_name and teamName and guildIdx and value then

                if not seen_keys[org_name] then
                    if native_lang_is_translation(teamName) and not g.names[org_name] then
                        teamName = native_lang_process_name(org_name)
                    end

                    table.insert(g.gear_scores, {org_name, g.names[org_name] or teamName, guildIdx, tonumber(value)})
                    seen_keys[org_name] = true -- org_nameを記録
                end
            end
        end
        file:close()
    else

        file = io.open(g.gear_score, "w")
        file:close()
    end

    local function trim_chat_log_file(filepath, num_lines_to_keep)
        local file_in = io.open(filepath, "r")
        if not file_in then
            return false
        end

        local lines_to_keep = {}
        for line in file_in:lines() do
            table.insert(lines_to_keep, line)
            if #lines_to_keep > num_lines_to_keep then
                table.remove(lines_to_keep, 1)
            end
        end
        file_in:close()

        local file_out = io.open(filepath, "w")
        if not file_out then
            return false
        end

        for _, line in ipairs(lines_to_keep) do
            file_out:write(line .. "\n")
        end
        file_out:close()
        return true
    end

    if g.recv_msg then

        local perform_trim = false
        local current_size = 0
        local file_check = io.open(g.recv_msg, "r")
        if file_check then
            current_size = file_check:seek("end")
            file_check:close()
            if current_size and current_size > (5 * 1024) then
                perform_trim = true
            end
        end

        if perform_trim then
            local success = trim_chat_log_file(g.recv_msg, 30)
            if success then
                g.msg_len = nil
            end
        end
    end

end

function native_lang_TOS_GOOGLE_TRANSLATE_ON_INIT(addon, frame)
    return
end

function native_lang_KOJA_NAME_TRANSLATER_ON_INIT(addon, frame)
    return
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

function native_lang_PARTYINFO_UPDATE(frame, msg, argStr, argNum)

    if g.settings.use == 0 then
        return
    end

    local list = session.party.GetPartyMemberList(PARTY_NORMAL);

    local count = list:Count();
    if count == 1 then
        return
    end
    local frame = ui.GetFrame("partyinfo")
    for i = 0, count - 1 do
        local partyMemberInfo = list:Element(i);

        local partyInfoCtrlSet = frame:GetChild('PTINFO_' .. partyMemberInfo:GetAID());
        if partyInfoCtrlSet ~= nil then
            local nameObj = partyInfoCtrlSet:GetChild('name_text');
            local nameRichText = tolua.cast(nameObj, "ui::CRichText");
            local name = nameRichText:GetTextByKey("name");

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
    if not ispipui then
        return
    end
    --[[local list = session.party.GetPartyMemberList(PARTY_NORMAL);
    local count = list:Count();

   

    for i = 0, count - 1 do
        local partyMemberInfo = list:Element(i);]]
    local party = ui.GetFrame("party")
    local memberlist = GET_CHILD_RECURSIVELY(party, "memberlist")
    local partyInfoCtrlSet = GET_CHILD(memberlist, 'PTINFO_' .. partyMemberInfo:GetAID())
    if partyInfoCtrlSet ~= nil then
        AUTO_CAST(partyInfoCtrlSet)
        local name_text = GET_CHILD(partyInfoCtrlSet, "name_text")
        AUTO_CAST(name_text)
        local original_string = name_text:GetText()
        -- name_text:SetText("")
        local left_tag_length = string.len("{@st43b}{s14}{#FFFFFF}")
        local name_part, space_and_right_part = string.match(original_string,
            "^" .. string.rep('.', left_tag_length) .. "(.-)(%s+%b())")

        if native_lang_is_translation(name_part) then

            name_part = native_lang_process_name(name_part)
        end

        if name_part then
            local map_cls = GetClassByType("Map", partyMemberInfo:GetMapID())
            if map_cls then

                local combined_string = ScpArgMsg("PartyMemberMapNChannel", "Name", name_part, "Mapname", map_cls.Name,
                    "ChNo", partyMemberInfo:GetChannel() + 1)

                local x = name_text:GetX()
                name_text:ShowWindow(0)
                local new_name_text = partyInfoCtrlSet:CreateOrGetControl('richtext', 'new_name_text', x, 55, 120, 20)
                AUTO_CAST(new_name_text)
                new_name_text:SetText("{@st43b}{s14}" .. combined_string)
            end
        end

    end
    -- end
end

function native_lang_PARTY_OPEN(my_frame, my_msg)

    local party = ui.GetFrame("party")
    local memberlist = GET_CHILD_RECURSIVELY(party, "memberlist")
    local list = session.party.GetPartyMemberList(PARTY_NORMAL);
    local count = list:Count();

    for i = 0, count - 1 do
        local partyMemberInfo = list:Element(i);
        local partyInfoCtrlSet = GET_CHILD(memberlist, 'PTINFO_' .. partyMemberInfo:GetAID())
        if partyInfoCtrlSet ~= nil then
            AUTO_CAST(partyInfoCtrlSet)
            local name_text = GET_CHILD(partyInfoCtrlSet, "name_text")
            AUTO_CAST(name_text)
            -- name_text:SetText("")
            local original_string = name_text:GetText()

            local left_tag_length = string.len("{@st43b}{s14}{#FFFFFF}")
            local name_part = string.match(original_string, "^" .. string.rep('.', left_tag_length) .. "(.-)%s+%b()")

            if native_lang_is_translation(name_part) then

                name_part = native_lang_process_name(name_part)

            end

            if name_part then
                local map_cls = GetClassByType("Map", partyMemberInfo:GetMapID())
                if map_cls then

                    local combined_string = ScpArgMsg("PartyMemberMapNChannel", "Name", name_part, "Mapname",
                        map_cls.Name, "ChNo", partyMemberInfo:GetChannel() + 1)

                    local x = name_text:GetX()
                    name_text:ShowWindow(0)
                    local new_name_text = partyInfoCtrlSet:CreateOrGetControl('richtext', 'new_name_text', x, 55, 120,
                        20)
                    AUTO_CAST(new_name_text)
                    new_name_text:SetText("{@st43b}{s14}" .. combined_string)
                end
            end

        end
    end
end

function NATIVE_LANG_ON_INIT(addon, frame)
    local start_time = os.clock() -- ★処理開始前の時刻を記録★

    g.addon = addon
    g.frame = frame
    g.chat_ids = g.chat_ids or {}
    g.name_len = 0
    g.msg_len = 0

    g.language = option.GetCurrentCountry()

    g.REGISTER = {}

    -- tos_google_translate無効化
    g.SetupHook(native_lang_TOS_GOOGLE_TRANSLATE_ON_INIT, "TOS_GOOGLE_TRANSLATE_ON_INIT")
    -- koja_name_tarnslater無効化
    g.SetupHook(native_lang_KOJA_NAME_TRANSLATER_ON_INIT, "KOJA_NAME_TRANSLATER_ON_INIT")

    native_lang_load_settings()

    -- g.SetupHook(native_lang_UPDATE_PARTYINFO_HP, "UPDATE_PARTYINFO_HP")
    g.setup_hook_and_event(addon, "PARTY_OPEN", "native_lang_PARTY_OPEN", true)
    g.setup_hook_and_event(addon, "SET_PARTYINFO_ITEM", "native_lang_SET_PARTYINFO_ITEM", true)
    addon:RegisterMsg("PARTY_UPDATE", "native_lang_PARTYINFO_UPDATE");
    g.SetupHook(native_lang_DAMAGE_METER_GAUGE_SET, "DAMAGE_METER_GAUGE_SET")
    g.SetupHook(native_lang_UPDATE_COMPANION_TITLE, "UPDATE_COMPANION_TITLE")
    g.SetupHook(native_lang_GEAR_SCORE_RANKING_CREATE_INFO, "GEAR_SCORE_RANKING_CREATE_INFO")
    g.SetupHook(native_lang_SOLODUNGEON_RANKINGPAGE_FILL_RANK_CTRL, "SOLODUNGEON_RANKINGPAGE_FILL_RANK_CTRL")
    g.SetupHook(native_lang_GUILDINFO_MEMBER_LIST_CREATE, "GUILDINFO_MEMBER_LIST_CREATE")
    g.SetupHook(native_lang_GUILDNOTICE_GET, "GUILDNOTICE_GET")
    g.SetupHook(native_lang_GUILDINFO_INIT_PROFILE, "GUILDINFO_INIT_PROFILE")
    -- g.setup_hook_and_event(addon, "CHAT_RBTN_POPUP", "native_lang_CHAT_RBTN_POPUP", true)
    -- g.SetupHook(native_lang_CHAT_RBTN_POPUP, "CHAT_RBTN_POPUP");

    acutil.setupEvent(addon, "WEEKLY_BOSS_RANK_UPDATE", "native_lang_WEEKLY_BOSS_RANK_UPDATE");
    acutil.setupEvent(addon, "SHOW_PC_COMPARE", "native_lang_SHOW_PC_COMPARE");

    acutil.setupEvent(addon, "ON_EVENTBANNER_GEARSCORE", "native_lang_ON_EVENTBANNER_GEARSCORE");

    addon:RegisterMsg("GAME_START", "native_lang_GAME_START");
    addon:RegisterMsg("GAME_START_3SEC", "native_lang_GAME_START_3SEC");

    local end_time = os.clock() -- ★処理終了後の時刻を記録★
    local elapsed_time = end_time - start_time
    -- CHAT_SYSTEM(string.format("%s: %.4f seconds", addonName, elapsed_time))

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

function native_lang_restart()
    local file = io.open(g.restart, "w")
    file:write("restart")
    file:close()
    g.start = false
    g.load = false
    g.chat_ids = {}
    g.name_len = 0
    g.msg_len = 0

    -- g.recv_count = 0
    ui.SysMsg("[Native Lang] restarted.{nl}" .. "Please return to the barracks once.")
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

function native_lang_GAME_START()

    local function native_lang_frame_init()
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
    end
    native_lang_frame_init()

    local function native_lang_translate_exe_start()
        --[[if g.settings.use == 0 then
            return
        end]]

        if not g.start then

            local exe_path = "../addons/native_lang/native_lang-v" .. exe .. ".exe"
            local file = io.open(exe_path, "r")
            if file then
                file:close()
                local command = string.format('start "" /min "%s"', exe_path)
                os.execute(command)
            else
                local tar_path = "../addons/native_lang/native_lang-v" .. exe .. ".tar"
                -- print(tar_path)
                local output_dir = "../addons/native_lang"

                -- tarコマンドの生成
                local tar_command = string.format('tar -xf "%s" -C "%s"', tar_path, output_dir)

                local result = os.execute(tar_command)

                if result then
                    local command = string.format('start "" /min "%s"', exe_path)
                    os.execute(command)
                end

            end

            g.start = true
        end

    end

    native_lang_translate_exe_start()

end

function native_lang_GAME_START_3SEC()
    g.setup_hook_and_event(g.addon, "DRAW_CHAT_MSG", "native_lang_DRAW_CHAT_MSG", true)

    -- acutil.setupEvent(g.addon, "DRAW_CHAT_MSG", "native_lang_DRAW_CHAT_MSG");
    -- g.addon:RegisterMsg("FPS_UPDATE", "native_lang_FPS_UPDATE");
    local chatframe = ui.GetFrame("chatframe")
    if not g.settings.chatmode then
        chatframe:RunUpdateScript("native_lang_run_UPDATE", 3.0)
        native_lang_run_UPDATE()
    else
        chatframe:StopUpdateScript("native_lang_run_UPDATE")
    end
    -- g.msg_len = 0
    -- native_lang_chat_recv()
    native_lang_replace()
end

function native_lang_chat_recv(frame)

    local recv_file = io.open(g.recv_msg, "r")
    if not recv_file then
        return 1
    end

    local current_msg_len = recv_file:seek("end")

    if g.msg_len == current_msg_len then
        recv_file:close()
        return 1
    end

    local new_chat_content = ""
    if (g.msg_len or 0) < current_msg_len then
        recv_file:seek("set", g.msg_len or 0)
        new_chat_content = recv_file:read("*all")
    end

    if new_chat_content ~= "" then
        for line in string.gmatch(new_chat_content, "[^\r\n]+") do
            local chat_id, msg_type, msg, separate_msg, org_msg, org_name = line:match(
                "^(.-):::(.-):::(.-):::(.-):::(.-):::(.*)$")
            if chat_id then
                local chat_id_str = tostring(chat_id)
                if g.chat_ids and g.chat_ids[chat_id_str] then
                    if string.find(msg, "{#FF0000}★{/}", 1, true) then
                        g.chat_ids[chat_id_str].trans_msg = msg
                        g.chat_ids[chat_id_str].name = (g.names and g.names[org_name]) or org_name
                    end
                end
            end
        end

    end

    g.msg_len = current_msg_len
    recv_file:close()

    if g.individual then
        if g.chat_ids and g.chat_ids[tostring(g.individual)] then
            local msg_ind = g.chat_ids[tostring(g.individual)].trans_msg
            if msg_ind and string.find(msg_ind, "{#FF0000}★{/}") == nil and msg_ind ~= "" then
                return 1
            end

        end
    end
    native_lang_replace()
    return 1
end

function native_lang_run_UPDATE(frame)

    native_lang_name_trans()

    function native_lang_name_dat_check()

        local recv_name_file = io.open(g.recv_name, "r")
        if not recv_name_file then

            return 1
        end

        local current_file_len = recv_name_file:seek("end")

        if (g.name_len or 0) < current_file_len then
            recv_name_file:seek("set", g.name_len or 0)
            local new_name_content = recv_name_file:read("*all")

            if new_name_content and new_name_content ~= "" then
                for line_content in string.gmatch(new_name_content, "[^\r\n]+") do
                    local org_name, trans_name = line_content:match("^(.-):::(.*)$")
                    if org_name and trans_name then
                        g.names[org_name] = trans_name
                    end
                end
            end
            g.name_len = current_file_len
        end
        recv_name_file:close()
    end
    native_lang_name_dat_check()
    return 1
end

--[[function native_lang_run_UPDATE(frame)

    native_lang_name_trans()

    function native_lang_name_dat_check()

        local recv_name_file = io.open(g.recv_name, "r")
        if recv_name_file then
            local name_len = recv_name_file:seek("end")
            if g.name_len ~= name_len then
                recv_name_file:seek("set", 0)

                for line in recv_name_file:lines() do
                    local org_name, trans_name = line:match("^(.-):::(.*)$")
                    if org_name and trans_name then
                        g.names[org_name] = trans_name
                    end
                end
                g.name_len = name_len
            end
            recv_name_file:close()
        end
    end
    native_lang_name_dat_check()
    return 1
end]]
-- !
function native_lang_format_chat_message(frame, msg_type, right_name, msg)

    local msg_type_map = {
        Normal = 1,
        Shout = 2,
        Party = 3,
        Guild = 4,
        System = 7,
        GuildNotice = 4,
        guildmem = 4,
        Whisper = 5
    }

    local chat_type_id = msg_type_map[msg_type]
    if chat_type_id then

        local font_size = tonumber(GET_CHAT_FONT_SIZE())
        local font_style
        if msg_type == "GuildNotice" then
            font_style = "{#FF44FF}{b}{ol}"
        elseif msg_type == "guildmem" then
            font_style = "{#A566FF}{b}{ol}"
        elseif msg_type == "Whisper" then
            font_style = "{#00FFFF}{b}{ol}"
        else
            font_style = frame:GetUserConfig("TEXTCHAT_FONTSTYLE_" .. msg_type:upper())
        end
        -- local font_style = frame:GetUserConfig("TEXTCHAT_FONTSTYLE_" .. msg_type:upper())
        local msg_front = string.format("[%s]%s : %s", ScpArgMsg("ChatType_" .. chat_type_id), right_name, msg)
        return msg_front, font_style, font_size
    end
    return nil, nil, nil
end

function native_lang_chat_replace(frame, msg_front, font_style, font_size, chat_id)

    local clustername = "cluster_" .. chat_id
    local cluster = GET_CHILD_RECURSIVELY(frame, clustername)
    local text = GET_CHILD(cluster, "text")

    text:SetTextByKey("font", font_style)
    text:SetTextByKey("size", font_size)
    text:SetTextByKey("text", msg_front)

end
-- g.gbox_name

function native_lang_replace()

    if g.settings.use == 0 and not g.individual then
        return
    end
    if g.individual then

        g.individual = false
        ui.SysMsg("Please wait while translating")

        local frame = ui.GetFrame("chatframe")
        frame:StopUpdateScript("native_lang_chat_recv")
        frame:RunUpdateScript("native_lang_chat_recv", 0.5) -- ！
    end

    local chatframe = ui.GetFrame("chatframe")
    local gbox = GET_CHILD(chatframe, g.gbox_name)

    local gbox_child_count = gbox:GetChildCount()
    local ypos = 0

    for i = 0, gbox_child_count - 1 do
        local gbox_child = gbox:GetChildByIndex(i)
        local child_name = gbox_child:GetName()

        if tostring(child_name) ~= "_SCR" then

            local margin_left = 20
            local cluster = GET_CHILD(gbox, child_name)
            local label = cluster:GetChild('bg')
            local offsetX = chatframe:GetUserConfig("CTRLSET_OFFSETX")
            local chat_Width = gbox:GetWidth()
            local text = GET_CHILD(cluster, "text")
            local time = GET_CHILD(cluster, "time");
            AUTO_CAST(time)

            time:SetEventScript(ui.RBUTTONDOWN, "native_lang_individual_translation")
            local chatctrlname = cluster:GetName()
            time:SetEventScriptArgString(ui.RBUTTONDOWN, chatctrlname)

            local chat_id = tostring(string.gsub(child_name, "cluster_", ""))

            if g.chat_ids[chat_id] ~= nil then
                local msg = ""
                if g.chat_ids[tostring(chat_id)].trans_msg ~= "" then
                    msg = g.chat_ids[tostring(chat_id)].trans_msg
                else
                    msg = g.chat_ids[tostring(chat_id)].proc_msg
                end

                local separate_msg = g.chat_ids[tostring(chat_id)].separate_msg

                if separate_msg and separate_msg ~= "None" then
                    separate_msg = separate_msg:gsub("},%s*{", "}{")
                    separate_msg = separate_msg:gsub("{%((%d+)}", "(%1") -- {(5 の部分を (5 に戻す
                    separate_msg = separate_msg:gsub("{%)}", ")")
                    separate_msg = separate_msg:gsub("{@dicID_%^%*%$(.-)%$%*^}", "@dicID_^*$%1$*^")
                    separate_msg = separate_msg:gsub("{img link_party 24 24}{(.-)}{/}", "{img link_party 24 24}%1{/}")

                    msg = msg .. separate_msg
                end

                local msg_type = g.chat_ids[tostring(chat_id)].msg_type
                local name = g.chat_ids[tostring(chat_id)].name

                local msg_front, font_style, font_size = native_lang_format_chat_message(chatframe, msg_type, name, msg)

                if msg_front ~= nil then
                    native_lang_chat_replace(chatframe, msg_front, font_style, font_size, chat_id)
                end

            end

            label:Resize(chat_Width - offsetX, text:GetHeight())
            cluster:Resize(chat_Width, label:GetHeight())
            cluster:SetOffset(margin_left, ypos)
            ypos = ypos + cluster:GetHeight()

        end
    end
    if gbox:GetLineCount() == gbox:GetCurLine() + gbox:GetVisibleLineCount() then
        gbox:SetScrollPos(99999)
    end

end

function native_lang_system_msg_replace(chat_id, msg, msg_type, name, org_msg)

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
        native_lang_replace()
        return
    end

    if string.find(msg, "https:") then

        native_lang_system_msg_to_chat_ids(chat_id, msg, msg_type, name, org_msg, msg)
        return
    elseif string.find(msg, "ChatJoin") and msg_type == "guildmem" then
        -- elseif string.find(msg, "ChatJoin") ~= nil then
        msg = string.gsub(msg, "guildmem:", "")
        local start_pos = string.find(msg, "$*$WHO$*$", 1, true)
        start_pos = start_pos + 9
        local end_pos = string.find(msg, "$*$TYPE$*$", 1, true)
        local team_name = string.sub(msg, start_pos, end_pos - 1)
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
        local updated_msg = string.sub(msg, 1, start_pos - 1) .. trans_team_name .. string.sub(msg, end_pos)
        native_lang_system_msg_to_chat_ids(chat_id, msg, msg_type, "", org_msg, updated_msg)
        return
    elseif string.find(msg, "GUILD_SYSTEM_MSG3") then
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
        return
    elseif string.find(msg, "Guild_Colony_End_WorldMessage") then
        local start_pos = string.find(msg, "$*$partyName$*$", 1, true)
        start_pos = start_pos + 15
        local end_pos = string.find(msg, "#@!", start_pos, true)
        local guild_name = string.sub(msg, start_pos, end_pos - 1)
        local trimmed_name = guild_name:match("^%s*(.-)%s*$")
        local trans_guild_name = ""
        if g.names[trimmed_name] then
            trans_guild_name = g.names[guild_name]
        else
            trans_guild_name = guild_name
        end
        local updated_msg = string.sub(msg, 1, start_pos - 1) .. trans_guild_name .. string.sub(msg, end_pos)
        updated_msg = "{#DD0000}" .. updated_msg
        native_lang_system_msg_to_chat_ids(chat_id, msg, msg_type, "", org_msg, updated_msg)

        return
    elseif string.find(msg, "Guild_Colony_Occupation_WorldMessage") then
        local start_pos = string.find(msg, "$*$partyName$*$", 1, true)
        start_pos = start_pos + 15
        local end_pos = string.find(msg, "$*$mapName$*$", start_pos, true)
        local final_pos = string.find(msg, "|#@!", start_pos, true)
        local guild_name = string.sub(msg, start_pos, end_pos - 1)
        local trimmed_name = guild_name:match("^%s*(.-)%s*$")
        local trans_guild_name = ""
        if g.names[trimmed_name] then
            trans_guild_name = g.names[guild_name]
        else
            trans_guild_name = guild_name
        end
        local updated_msg = string.sub(msg, 1, start_pos - 1) .. trans_guild_name .. string.sub(msg, end_pos, final_pos)
        updated_msg = "{#DD0000}" .. updated_msg
        native_lang_system_msg_to_chat_ids(chat_id, msg, msg_type, "", org_msg, updated_msg)

        return
    elseif string.find(msg, "NOTICE_FIELDBOSS_RANK") then
        local start_pos = string.find(msg, "$*$name$*$", 1, true)
        start_pos = start_pos + 10
        local end_pos = string.find(msg, "#@!", start_pos, true)
        local names_str = string.sub(msg, start_pos, end_pos - 1)

        local replaced_names = {}
        for name_str in names_str:gmatch("([^,]+)") do -- カンマで分割
            local trimmed_name = name_str:match("^%s*(.-)%s*$") -- 前後の空白を削除

            if g.names[trimmed_name] then
                table.insert(replaced_names, g.names[trimmed_name]) -- 置き換え
            else
                table.insert(replaced_names, trimmed_name) -- 置き換えが無い場合はそのまま
            end
        end

        local new_names_str = table.concat(replaced_names, ", ")
        local updated_msg = string.sub(msg, 1, start_pos - 1) .. new_names_str .. string.sub(msg, end_pos)
        native_lang_system_msg_to_chat_ids(chat_id, msg, msg_type, "", org_msg, updated_msg)
        return
    elseif string.find(msg, "FIELDBOSS_WORLD_EVENT_WIN_MSG") then
        local start_pos = string.find(msg, "$*$PC$*$", 1, true)
        start_pos = start_pos + 8
        local end_pos = string.find(msg, "$*$ITEM$*$", start_pos, true)
        local final_pos = string.find(msg, "|#@!", start_pos, true)
        local name = string.sub(msg, start_pos, end_pos - 1)
        local trimmed_name = name:match("^%s*(.-)%s*$")
        local trans_name = ""
        if g.names[trimmed_name] then
            trans_name = g.names[name]
        else
            trans_name = name
        end
        local updated_msg = string.sub(msg, 1, start_pos - 1) .. trans_name .. string.sub(msg, end_pos, final_pos)
        updated_msg = "{#DD0000}" .. updated_msg
        native_lang_system_msg_to_chat_ids(chat_id, msg, msg_type, "", org_msg, updated_msg)
        return

    end
end
-- CHAT_SYSTEM("guildmem:!@#${WHO}{TYPE}ChatJoin$*$WHO$*$s4y0$*$TYPE$*$@dicID_^*$UI_20150317_000220$*^#@!")
-- CHAT_SYSTEM("@dicID_^*$UI_20150317_000220$*^")

function native_lang_individual_translation(parent, chatctrl, chatctrlname, num)

    local groupboxname = parent:GetParent():GetName()
    g.gbox_name = groupboxname
    local frame = ui.GetFrame("chatframe")
    local chat_id = string.gsub(chatctrlname, "cluster_", "")
    local gbox = GET_CHILD(frame, groupboxname)
    local cluster = GET_CHILD(gbox, chatctrlname)
    if not cluster then
        return
    end
    local chat
    local size = session.ui.GetMsgInfoSize(groupboxname)
    for i = 0, size - 1 do
        local clusterinfo = session.ui.GetChatMsgInfo(groupboxname, i)
        if tostring(chat_id) == tostring(clusterinfo:GetMsgInfoID()) then
            chat = session.ui.GetChatMsgInfo(groupboxname, i)
        end
    end

    local msg = chat:GetMsg()
    local org_msg = msg
    msg = msg:gsub("{#0000FF}", "{#FFFF00}")

    local msg_type = chat:GetMsgType()

    local name = chat:GetCommanderName()
    name = name:gsub(" %[(.-)%]", "")

    if name == "System" then
        local sys_msg_find = native_lang_system_msg_replace(chat_id, msg, msg_type, name, org_msg)
        return
    end

    name = g.names[name] or name

    if not native_lang_is_translation(name) and msg_type ~= "System" then
        local msg_front, font_style, font_size = native_lang_format_chat_message(frame, msg_type, name, msg)
        native_lang_chat_replace(frame, msg_front, font_style, font_size, chat_id)
    end

    if string.find(msg, "{spine") then
        return
    end
    print(chat_id .. ":" .. msg_type .. ":" .. name .. ":" .. msg)

    local function native_lang_msg_processing(msg)

        local function modify_string(msg)

            local pattern1 = "{img link_party 24 24}(.-){/}"
            if string.find(msg, pattern1) then
                msg = msg:gsub(pattern1, "{img link_party 24 24}{" .. "%1" .. "}{/}")
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

            --[[ocal pattern = "{img link_party 24 24}(.-){/}"
            msg = msg:gsub(pattern, "{img link_party 24 24}{" .. "%1" .. "}{/}")

            msg = msg:gsub("(@dicID_%^%*%$.-%$%*%^)", "{%1}")

            if string.find(msg, "Earring 30 30") then

                msg = msg:gsub("%((%d+)", "{(%1}")
                msg = msg:gsub("%)", "{)}")
            end
            local pattern3 = "!@#%$(.-)#@!"
            msg = msg:gsub(pattern3, "{!@#%$(.-)#@!}")
            return msg]]
        end

        local function wrapped_contents(msg)
            local pattern = "{(.-)}"
            local separate_msg = {}

            for match in msg:gmatch(pattern) do
                table.insert(separate_msg, "{" .. match .. "}")
            end

            msg = msg:gsub(pattern, "")
            return msg, separate_msg
        end

        local function anti_pattern(proc_msg)
            -- 特殊文字を含むリスト
            local patterns = {",", "`", "~~", "&", "!", ":", "/", ";", "%(", "%)", "%[", "%]", "%{", "%}", "%'", "%\"",
                              "//"}

            for _, pattern in ipairs(patterns) do
                proc_msg = proc_msg:gsub(pattern .. "+", " ")

            end
            proc_msg = proc_msg:gsub("%%", " percent ")
            return proc_msg
        end

        msg = modify_string(msg)
        local proc_msg, separate_msg = wrapped_contents(msg)
        proc_msg = anti_pattern(proc_msg)
        proc_msg = proc_msg:gsub(" +", " ")
        return proc_msg, separate_msg

    end
    local proc_msg, separate_msg = native_lang_msg_processing(msg)

    g.chat_ids[tostring(chat_id)] = {
        msg_type = msg_type,
        name = g.names[name] or name,
        org_name = name,
        org_msg = org_msg,
        proc_msg = proc_msg,
        separate_msg = #separate_msg == 0 and "None" or table.concat(separate_msg, ","),
        trans_msg = ""
    }

    function native_lang_msg_send(send_msg, chat_id)

        local send_file = io.open(g.send_msg, "a")

        if send_file then
            send_file:write(send_msg .. "\n")
            -- send_file:flush()
            send_file:close()
        end
    end

    function native_lang_is_translation_msg(msg)
        if g.lang == "ja" then
            return WITH_HANGLE(msg) or WITH_ENGLISH(msg)
        elseif g.lang == "ko" then
            return WITH_JAPANESE(msg) or WITH_ENGLISH(msg)
        elseif g.lang == "en" then
            return WITH_HANGLE(msg) or WITH_JAPANESE(msg)
        end
        return false
    end

    if native_lang_is_translation_msg(proc_msg) then
        g.individual = chat_id
        local send_msg = chat_id .. ":::" .. msg_type .. ":::" .. proc_msg .. ":::" ..
                             g.chat_ids[tostring(chat_id)].separate_msg .. ":::" .. msg .. ":::" .. name
        native_lang_msg_send(send_msg, chat_id)
        frame:StopUpdateScript("native_lang_chat_recv")
        frame:RunUpdateScript("native_lang_chat_recv", 0.5)
    end

end

function native_lang_DRAW_CHAT_MSG(my_frame, my_msg)

    if g.settings.use == 0 then
        return
    end
    local groupboxname, startindex, chatframe = g.get_event_args(my_msg)

    if chatframe == nil then
        return;
    end

    local frame = ui.GetFrame("chatframe")
    local size = session.ui.GetMsgInfoSize(groupboxname)
    local chat = session.ui.GetChatMsgInfo(groupboxname, size - 1)

    local keyword = "!@#$ItemGet{name}{count}$*$"
    if string.find(chat:GetMsg(), keyword, 1, true) then
        return
    end

    local chat_id = chat:GetMsgInfoID()

    local clustername = "cluster_" .. chat_id
    local cluster = GET_CHILD_RECURSIVELY(frame, clustername)

    if cluster == nil then
        return
    end
    g.gbox_name = tostring(cluster:GetParent():GetName())

    local now = imcTime.GetAppTimeMS()

    if g.last_msg and g.last_msg == chat:GetMsg() then
        if g.last_name and g.last_name == chat:GetCommanderName() then
            if g.get_msg_time and (now - g.get_msg_time) < 200 then
                return
            end
        end
    end
    g.get_msg_time = imcTime.GetAppTimeMS()
    g.last_msg = chat:GetMsg()
    g.last_name = chat:GetCommanderName()

    g.chat_check = g.chat_check or {}
    if g.chat_check[tostring(chat_id)] then
        return
    end

    if not g.chat_check[tostring(chat_id)] then
        g.chat_check[tostring(chat_id)] = true
    end

    local msg = chat:GetMsg()
    local org_msg = msg
    msg = msg:gsub("{#0000FF}", "{#FFFF00}")

    local msg_type = chat:GetMsgType()

    if msg_type ~= "Normal" and msg_type ~= "Shout" and msg_type ~= "Party" and msg_type ~= "Guild" and msg_type ~=
        "System" and msg_type ~= "GuildComm" and msg_type ~= "GuildNotice" and msg_type ~= "guildmem" and msg_type ~=
        "Whisper" then
        return
    end

    local name = chat:GetCommanderName()
    name = name:gsub(" %[(.-)%]", "")

    if name == "System" then
        print(name)
        local sys_msg_find = native_lang_system_msg_replace(chat_id, msg, msg_type, name, org_msg)
        return
    end

    name = g.names[name] or name

    if not native_lang_is_translation(name) and msg_type ~= "System" then
        local msg_front, font_style, font_size = native_lang_format_chat_message(frame, msg_type, name, msg)
        native_lang_chat_replace(frame, msg_front, font_style, font_size, chat_id)
    end

    if string.find(msg, "{spine") then
        return
    end
    print(chat_id .. ":" .. msg_type .. ":" .. name .. ":" .. msg)

    local function native_lang_msg_processing(msg)

        local function modify_string(msg)

            local pattern1 = "{img link_party 24 24}(.-){/}"
            if string.find(msg, pattern1) then
                msg = msg:gsub(pattern1, "{img link_party 24 24}{" .. "%1" .. "}{/}")
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

            --[[local pattern = "{img link_party 24 24}(.-){/}"
            msg = msg:gsub(pattern, "{img link_party 24 24}{" .. "%1" .. "}{/}")

            msg = msg:gsub("(@dicID_%^%*%$.-%$%*%^)", "{%1}")

            if string.find(msg, "Earring 30 30") then

                msg = msg:gsub("%((%d+)", "{(%1}")
                msg = msg:gsub("%)", "{)}")
            end
            local pattern3 = "!@#%$(.-)#@!"
            msg = msg:gsub(pattern3, "{!@#%$(.-)#@!}")
            return msg]]
        end

        local function wrapped_contents(msg)
            local pattern = "{(.-)}"
            local separate_msg = {}

            for match in msg:gmatch(pattern) do
                table.insert(separate_msg, "{" .. match .. "}")
            end

            msg = msg:gsub(pattern, "")
            return msg, separate_msg
        end

        local function anti_pattern(proc_msg)
            -- 特殊文字を含むリスト
            local patterns = {",", "`", "~~", "&", "!", ":", "/", ";", "%(", "%)", "%[", "%]", "%{", "%}", "%'", "%\"",
                              "//"}

            for _, pattern in ipairs(patterns) do
                proc_msg = proc_msg:gsub(pattern .. "+", " ")

            end
            proc_msg = proc_msg:gsub("%%", " percent ")
            return proc_msg
        end

        msg = modify_string(msg)
        local proc_msg, separate_msg = wrapped_contents(msg)
        proc_msg = anti_pattern(proc_msg)
        proc_msg = proc_msg:gsub(" +", " ")
        return proc_msg, separate_msg

    end
    local proc_msg, separate_msg = native_lang_msg_processing(msg)

    g.chat_ids[tostring(chat_id)] = {
        msg_type = msg_type,
        name = g.names[name] or name,
        org_name = name,
        org_msg = org_msg,
        proc_msg = proc_msg,
        separate_msg = #separate_msg == 0 and "None" or table.concat(separate_msg, ","),
        trans_msg = ""
    }

    function native_lang_msg_send(send_msg, chat_id)

        local send_file = io.open(g.send_msg, "a")

        if send_file then
            send_file:write(send_msg .. "\n")
            -- send_file:flush()
            send_file:close()
        end
    end

    function native_lang_is_translation_msg(msg)
        if g.lang == "ja" then
            return WITH_HANGLE(msg) or WITH_ENGLISH(msg)
        elseif g.lang == "ko" then
            return WITH_JAPANESE(msg) or WITH_ENGLISH(msg)
        elseif g.lang == "en" then
            return WITH_HANGLE(msg) or WITH_JAPANESE(msg)
        end
        return false
    end

    if native_lang_is_translation_msg(proc_msg) then
        local send_msg = chat_id .. ":::" .. msg_type .. ":::" .. proc_msg .. ":::" ..
                             g.chat_ids[tostring(chat_id)].separate_msg .. ":::" .. msg .. ":::" .. name
        native_lang_msg_send(send_msg, chat_id)
        -- frame:StopUpdateScript("native_lang_chat_recv")
        frame:RunUpdateScript("native_lang_chat_recv", 0.5)

    end

end

--[[CHAT_SYSTEM(
    "{#DD0000}!@#$Guild_Colony_Occupation_WorldMessage$*$partyName$*$바이보라$*$mapName$*$|$#수로교 지역#$|#@!")]]
function native_lang_process_name(clean_name)

    if string.find(clean_name, "PartyMemberMapNChannel", 1, true) then
        return clean_name
    elseif string.find(clean_name, "★★", 1, true) then
        return clean_name
    end

    if g.names[clean_name] then
        local right_name = g.names[clean_name]
        return right_name
    end

    local name_file = io.open(g.recv_name, "r")
    local found = false

    if name_file then
        for line in name_file:lines() do
            local left_name, right_name = line:match("^(.-):::(.*)$")
            if left_name == clean_name then
                found = true
                g.names[left_name] = right_name
                name_file:close()
                return right_name
            end
        end
        name_file:close()
    end

    if not found then

        if native_lang_is_translation(clean_name) then

            local existing_keys = {}
            local read_file = io.open(g.send_name, "r")
            if read_file then
                for line in read_file:lines() do
                    local key = line:match("^(.-):::")

                    if key then
                        existing_keys[key] = true

                    end

                end
                read_file:close()
            end
            -- print(tostring(existing_keys[clean_name]))
            -- 重複がない場合に書き込む
            if not existing_keys[clean_name] then
                local append_file = io.open(g.send_name, "a")
                if append_file then
                    append_file:write(clean_name .. ":::" .. clean_name .. "\n")
                    -- append_file:flush()
                    append_file:close()
                end
            end
        end
    end
    return clean_name
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

    for i = 1, selected_objects_count do

        local handle = GetHandle(selected_objects[i])

        if handle ~= nil then
            if info.IsPC(handle) == 1 then
                local frame_name = "charbaseinfo1_" .. handle
                local pc_txt_frame = ui.GetFrame(frame_name)
                local shop_frame = ui.GetFrame("SELL_BALLOON_" .. handle)

                function native_lang_name_replace(ctrl)

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

                                    if ctrl:GetName() == "givenName" then
                                        local original_part = origin_name:sub(1, 9)
                                        trans_name = original_part .. trans_name
                                        ctrl:SetText(trans_name)
                                        local ctrl_Width = ctrl:GetWidth()
                                        local x = ctrl:GetX()
                                        local family_name = GET_CHILD(pc_txt_frame, "familyName")
                                        if family_name ~= nil then
                                            local frame_family_name_margin = family_name:GetMargin()
                                            family_name:SetMargin(x + ctrl_Width + 5, frame_family_name_margin.top,
                                                frame_family_name_margin.right, frame_family_name_margin.bottom)
                                        end
                                    elseif ctrl:GetName() == "familyName" or ctrl:GetName() == "name" then
                                        local original_part = origin_name:sub(1, 9)
                                        original_part = original_part:gsub("}{", "}")
                                        trans_name = original_part .. trans_name
                                        ctrl:SetText(trans_name)
                                    elseif ctrl:GetName() == "guildName" then
                                        ctrl:SetText(trans_name)
                                    elseif ctrl:GetName() == "text" then
                                        ctrl:SetTextByKey("value", trans_name)
                                    elseif ctrl:GetName() == "lv_title" then
                                        ctrl:SetTextByKey("value", trans_name)
                                    end

                                end
                            end
                        end
                    end
                end
                if pc_txt_frame ~= nil then

                    local given_name = GET_CHILD(pc_txt_frame, "givenName")
                    if given_name ~= nil then
                        native_lang_name_replace(given_name)
                    end

                    local family_name = GET_CHILD(pc_txt_frame, "familyName")
                    if family_name ~= nil then
                        native_lang_name_replace(family_name)
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

                if shop_frame ~= nil then

                    local shop_text = GET_CHILD(shop_frame, "text")
                    if shop_text ~= nil then
                        native_lang_name_replace(shop_text)
                    end
                    local lv_box = GET_CHILD(shop_frame, "withLvBox");
                    if lv_box ~= nil then
                        local lv_title = GET_CHILD(lv_box, "lv_title");
                        if lv_title ~= nil then
                            native_lang_name_replace(lv_title)
                        end
                    end
                end

            end
        end
    end
end

function native_lang_DAMAGE_METER_GAUGE_SET(ctrl, leftStr, point, rightStr, skin)
    if g.settings.use == 0 then
        base["DAMAGE_METER_GAUGE_SET"](ctrl, leftStr, point, rightStr, skin)
    else
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

        -- base["DAMAGE_METER_GAUGE_SET"](ctrl, leftStr, point, rightStr, skin)
    end
end
function native_lang_GUILDINFO_INIT_PROFILE(frame)
    if g.settings.use == 0 then
        base["GUILDINFO_INIT_PROFILE"](frame)
    else
        native_lang_GUILDINFO_INIT_PROFILE_(frame)
    end
end

function native_lang_GUILDINFO_INIT_PROFILE_(frame)
    local guild = session.party.GetPartyInfo(PARTY_GUILD);
    if guild == nil then
        GUILDINFO_FORCE_CLOSE_UI()
        return
    end

    local guildObj = GET_MY_GUILD_OBJECT();
    local guildInfoTab = GET_CHILD_RECURSIVELY(frame, "guildinfo_");
    local guildName = GET_CHILD_RECURSIVELY(frame, "guildname");
    guildName:SetTextByKey("name", guild.info.name);

    local guildLvl = GET_CHILD_RECURSIVELY(guildInfoTab, "guildLvl");
    guildLvl:SetTextByKey('level', guildObj.Level);

    -- leader name
    local masterText = GET_CHILD_RECURSIVELY(guildInfoTab, 'guildMasterName');
    local leaderAID = guild.info:GetLeaderAID();
    local memberInfo = session.party.GetPartyMemberInfoByAID(PARTY_GUILD, leaderAID);

    if memberInfo ~= nil then
        local name = g.names[memberInfo:GetName()] or memberInfo:GetName()
        if native_lang_is_translation(memberInfo:GetName()) then
            name = native_lang_process_name(memberInfo:GetName())
        end
        masterText:SetText("{@st66b}" .. name .. "{/}");
    end

    -- opening date
    local openText = GET_CHILD_RECURSIVELY(guildInfoTab, 'foundtxt');
    local openDate = imcTime.ImcTimeToSysTime(guild.info.createTime);
    local openDateStr = string.format('%04d.%02d.%02d', openDate.wYear, openDate.wMonth, openDate.wDay); -- yyyy.mm.dd
    openText:SetTextByKey('date', openDateStr);

    -- member
    local count = session.party.GetAllMemberCount(PARTY_GUILD);
    local memberText = GET_CHILD_RECURSIVELY(guildInfoTab, 'memberNum');
    memberText:SetTextByKey('current', count);
    memberText:SetTextByKey('max', guild:GetMaxGuildMemberCount());

    -- asset
    GUILDINFO_PROFILE_INIT_ASSET(guildInfoTab);

    -- emblem
    GUILDINFO_PROFILE_INIT_EMBLEM(frame);
end

function native_lang_GUILDNOTICE_GET(code, ret_json)
    if g.settings.use == 0 then
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
    local notifyText = GET_CHILD_RECURSIVELY(frame, 'noticeEdit');
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
    if g.settings.use == 0 then
        base["GUILDINFO_MEMBER_LIST_CREATE"](memberCtrlBox, partyMemberInfo)
    else
        native_lang_GUILDINFO_MEMBER_LIST_CREATE_(memberCtrlBox, partyMemberInfo)
    end
end

function native_lang_GUILDINFO_MEMBER_LIST_CREATE_(memberCtrlBox, partyMemberInfo)
    if partyMemberInfo == nil then
        return;
    end

    local aid = partyMemberInfo:GetAID();
    local memberCtrlSet = memberCtrlBox:CreateOrGetControlSet('guild_memberinfo', 'MEMBER_' .. aid, 0, 0);
    memberCtrlSet = AUTO_CAST(memberCtrlSet);
    memberCtrlSet:SetUserValue('AID', aid);

    local isOnline = true;
    local pic_online = GET_CHILD_RECURSIVELY(memberCtrlSet, 'pic_online');
    local txt_location = GET_CHILD_RECURSIVELY(memberCtrlSet, 'txt_location');
    local ONLINE_IMG = memberCtrlSet:GetUserConfig('ONLINE_IMG');
    local OFFLINE_IMG = memberCtrlSet:GetUserConfig('OFFLINE_IMG');
    local MY_CHAR_BG_SKIN = memberCtrlSet:GetUserConfig('MY_CHAR_BG_SKIN');

    -- bg
    if aid == session.loginInfo.GetAID() then
        local bg = GET_CHILD_RECURSIVELY(memberCtrlSet, 'bg');
        bg:SetSkinName(MY_CHAR_BG_SKIN);
    end

    -- on/off & location
    local locationText = "";
    if partyMemberInfo:GetMapID() > 0 then
        local mapCls = GetClassByType("Map", partyMemberInfo:GetMapID());
        if mapCls ~= nil then
            pic_online:SetImage(ONLINE_IMG);
            locationText = string.format("[%s%d] %s", ScpArgMsg("Channel"), partyMemberInfo:GetChannel() + 1,
                mapCls.Name);
        end
    else
        isOnline = false;
        pic_online:SetImage(OFFLINE_IMG);
        local logoutSec = partyMemberInfo:GetLogoutSec();
        if logoutSec >= 0 then
            locationText = GET_DIFF_TIME_TXT(logoutSec);
        else
            locationText = ScpArgMsg("LogoutLongTime");
        end
    end
    txt_location:SetTextByKey("value", locationText);
    txt_location:SetTextTooltip(locationText);

    -- name
    local txt_teamname = GET_CHILD_RECURSIVELY(memberCtrlSet, 'txt_teamname');
    local name = g.names[partyMemberInfo:GetName()] or partyMemberInfo:GetName()
    if native_lang_is_translation(name) then
        name = native_lang_process_name(name)
    end
    txt_teamname:SetTextByKey('value', name);
    txt_teamname:SetTextTooltip(partyMemberInfo:GetName());

    -- job
    local jobID = partyMemberInfo:GetIconInfo().repre_job;
    local jobCls = GetClassByType('Job', jobID);
    local jobName = GET_JOB_NAME(jobCls, partyMemberInfo:GetIconInfo().gender);
    if jobName ~= nil then
        local jobText = GET_CHILD_RECURSIVELY(memberCtrlSet, 'jobText')
        jobText:SetTextByKey('job', jobName);
    end

    -- level
    if isOnline == true then
        local levelText = GET_CHILD_RECURSIVELY(memberCtrlSet, 'levelText');
        levelText:SetTextByKey('level', partyMemberInfo:GetLevel());
    end
    -- claim
    local txt_duty = GET_CHILD_RECURSIVELY(memberCtrlSet, 'txt_duty');
    local grade = partyMemberInfo.grade;

    local guild = GET_MY_GUILD_INFO();
    local leaderAID = guild.info:GetLeaderAID();
    if leaderAID == aid then
        local dutyName = "{ol}{#FFFF00}" .. ScpArgMsg("GuildMaster") .. "{/}{/}";
        dutyName = dutyName .. " " .. guild:GetDutyName(grade);
        txt_duty:SetTextByKey("value", dutyName);
    else
        local claimName = GET_CLAIM_NAME_BY_AIDX(aid);
        if claimName == nil then
            claimName = "";
            GetPlayerMemberTitle("ON_GUILDINFO_MEMBER_TITLE_GET", aid);
        else
            claimName = g.names[claimName] or claimName
            if native_lang_is_translation(claimName) then
                claimName = native_lang_process_name(claimName)
            end
        end
        txt_duty:SetTextByKey("value", claimName);
    end

    -- contribution
    local memberObj = GetIES(partyMemberInfo:GetObject());
    local contributionText = GET_CHILD_RECURSIVELY(memberCtrlSet, 'contributionText');
    contributionText:SetTextByKey('contribution', memberObj.Contribution);

    memberCtrlSet:SetEventScript(ui.RBUTTONDOWN, 'POPUP_GUILD_MEMBER');
end

function native_lang_GEAR_SCORE_RANKING_CREATE_INFO(ctrl, rank, guildIdx, teamName, charName, value)
    if g.settings.use == 0 then
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
        return a[4] > b[4] -- 4番目の要素がvalue
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
    if g.settings.use == 0 then
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
    local ranking_gear_score = GET_CHILD_RECURSIVELY(frame, "ranking_gear_score");
    AUTO_CAST(ranking_gear_score)
    local detail_btn = GET_CHILD(ranking_gear_score, "detail_btn");
    local detail_x, detail_y = detail_btn:GetX(), detail_btn:GetY()
    local real_rank = ranking_gear_score:CreateOrGetControl('button', "real_rank", detail_x - 180, detail_y, 100, 30);
    AUTO_CAST(real_rank)
    real_rank:SetSkinName("None")
    real_rank:SetEventScript(ui.LBUTTONUP, "native_lang_real_rank_frame")

    real_rank:SetText("{ol}{s20}Maximum Rank>>")
    real_rank:ShowWindow(1)
end

function native_lang_real_rank_frame_close(frame, ctrl, str, num)
    local frame = ui.GetFrame(addonNameLower .. "gear_score_info")
    frame:ShowWindow(0)
end

function native_lang_real_rank_frame(frame, ctrl, str, num)
    local frame = ui.CreateNewFrame("notice_on_pc", addonNameLower .. "gear_score_info", 0, 0, 0, 0)
    AUTO_CAST(frame)
    frame:SetPos(1000, 30)
    frame:SetSkinName("test_frame_low")
    frame:SetLayerLevel(1000);
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
    rank_title:SetFontName("white_20_ol_ds");
    rank_title:SetText("Rank")

    local name_title = frame:CreateOrGetControl('richtext', 'name_title', 120, 60, 200, 30)
    AUTO_CAST(name_title)
    name_title:SetFontName("white_20_ol_ds");
    name_title:SetText("Team Name")

    local score_title = frame:CreateOrGetControl('richtext', 'score_title', 330, 60, 80, 30)
    AUTO_CAST(score_title)
    score_title:SetFontName("white_20_ol_ds");
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
        rank_text:SetFontName("white_20_ol_ds");
        rank_text:SetText(i)

        local pic = info_gbox:CreateOrGetControl('picture', "pic" .. i, 70, y, 30, 30);
        AUTO_CAST(pic)

        if tostring(entry[3]) ~= "0" then

            local emblemImgName = guild.GetEmblemImageName(tostring(entry[3]), worldID)

            if emblemImgName ~= 'None' then
                pic:SetFileName(emblemImgName)
                pic:SetEnableStretch(1);
            end
        end

        local name_text = info_gbox:CreateOrGetControl('richtext', 'name_text' .. i, 110, y + 5, 240, 30)
        AUTO_CAST(name_text)

        local name = entry[2] or entry[1]
        name_text:SetText("{ol}{s18}" .. name)
        name_text:AdjustFontSizeByWidth(240)

        local score_text = info_gbox:CreateOrGetControl('richtext', 'score_text' .. i, 360, y + 5, 80, 30)
        AUTO_CAST(score_text)
        -- score_text:SetFontName("white_20_ol_ds");
        score_text:SetText("{ol}{s18}" .. entry[4])

        y = y + 35

    end

    frame:Resize(x, 800)
    local title_gb = frame:CreateOrGetControl("groupbox", "title_gb", 0, 0, frame:GetWidth(), 55)
    title_gb:SetSkinName("test_frame_top")
    AUTO_CAST(title_gb)
    local title_text = title_gb:CreateOrGetControl("richtext", "title_text", 0, 0, ui.CENTER_HORZ, ui.TOP, 0, 15, 0, 0)
    AUTO_CAST(title_text);
    title_text:SetText('{ol}{s20}Maximum Gear Score Ranking')
    info_gbox:Resize(frame:GetWidth() - 20, frame:GetHeight() - 105)
    info_gbox:SetScrollPos(0)
    frame:ShowWindow(1)
end

function native_lang_SOLODUNGEON_RANKINGPAGE_FILL_RANK_CTRL(rankGbox, ctrlType, rank, week)

    if g.settings.use == 0 then
        base["SOLODUNGEON_RANKINGPAGE_FILL_RANK_CTRL"](rankGbox, ctrlType, rank, week)
    else
        native_lang_SOLODUNGEON_RANKINGPAGE_FILL_RANK_CTRL_(rankGbox, ctrlType, rank, week)
    end
end

function native_lang_SOLODUNGEON_RANKINGPAGE_FILL_RANK_CTRL_(rankGbox, ctrlType, rank, week)
    AUTO_CAST(rankGbox)
    local emblemSlotImageName = rankGbox:GetUserConfig("GUILD_EMBLEM_SLOT");
    local scoreInfo = session.soloDungeon.GetRankingByIndex(week, ctrlType, rank)
    if scoreInfo == nil then
        return;
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
    guildNameText:SetTextByKey("guildname", guildName);

    local emblemCtrl = GET_CHILD_RECURSIVELY(rankGbox, "guildEmblem")
    if emblemCtrl ~= nil then
        local worldID = session.party.GetMyWorldIDStr();
        local emblemImgName = guild.GetEmblemImageName(scoreInfo:GetGuildIDStr(), worldID);
        emblemCtrl:SetImage(emblemSlotImageName);
        if emblemImgName ~= 'None' then
            emblemCtrl:SetFileName(emblemImgName);
            emblemCtrl:Invalidate();
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
                rankImage:SetEnableStretch(1);
                rankImage:EnableHitTest(0)

                if jobTreeList[jobID] == nil then
                    jobTreeList[jobID] = 1
                else
                    jobTreeList[jobID] = jobTreeList[jobID] + 1
                end
            end
        end
    end

    local jobtext = "";
    for jobid, grade in pairs(jobTreeList) do
        -- 클래스 이름{@st41}
        local jobCls = GetClassByType("Job", jobid)

        local jobName = TryGetProp(jobCls, "Name")
        jobtext = jobtext .. ("{@st41}") .. jobName

        jobtext = jobtext .. ('{nl}');
    end
    jobTreeGbox:SetTextTooltip(jobtext);

    local maxStageText = GET_CHILD_RECURSIVELY(rankGbox, "maxStageText")
    maxStageText:SetTextByKey("maxstage", scoreInfo.stage);

    local clear_time = scoreInfo.clear_time;
    if clear_time ~= 0 then
        clear_time = session.soloDungeon.GetClearTimeConvert(tonumber(clear_time));
    else
        clear_time = "03:00";
    end

    local killMonsterText = GET_CHILD_RECURSIVELY(rankGbox, "killMonsterText")
    killMonsterText:SetTextByKey("killmonster", clear_time)
end

function native_lang_UPDATE_COMPANION_TITLE(frame, handle)
    if g.settings.use == 0 then
        base["UPDATE_COMPANION_TITLE"](frame, handle)
    else
        native_lang_UPDATE_COMPANION_TITLE_(frame, handle)
    end
end

function native_lang_UPDATE_COMPANION_TITLE_(frame, handle)
    -- print(tostring(handle))
    frame = tolua.cast(frame, "ui::CObject");
    local petguid = session.pet.GetPetGuidByHandle(handle);
    local mycompinfoBox = GET_CHILD_RECURSIVELY(frame, "mycompinfo");
    if mycompinfoBox == nil then
        return;
    end

    local otherscompinfo = GET_CHILD_RECURSIVELY(frame, "otherscompinfo");
    if petguid == 'None' then
        mycompinfoBox:ShowWindow(0)
        otherscompinfo:ShowWindow(1)

        local targetinfo = info.GetTargetInfo(handle);
        if targetinfo == nil then
            return;
        end
        local othernameTxt = GET_CHILD_RECURSIVELY(frame, "othername");
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
        local myActor = GetMyPCObject();
        if myActor ~= nil and IsBuffApplied(myActor, "RidingCompanion") == "YES" then
            mycompinfoBox:ShowWindow(0);
        else
            mycompinfoBox:ShowWindow(1);
        end
        otherscompinfo:ShowWindow(0);

        local mynameRtext = GET_CHILD_RECURSIVELY(frame, "myname");
        local gauge_stamina = GET_CHILD_RECURSIVELY(frame, "StGauge");
        local gauge_HP = GET_CHILD_RECURSIVELY(frame, "HpGauge");

        local pet = session.pet.GetPetByGUID(petguid);
        mynameRtext:SetText(pet:GetName())

        local petObj = GetIES(pet:GetObject());
        gauge_stamina:SetPoint(petObj.Stamina, petObj.MaxStamina);

        local petInfo = info.GetStat(handle);
        gauge_HP:SetPoint(petInfo.HP, petInfo.maxHP);
    end
    frame:Invalidate()
end

function native_lang_SHOW_PC_COMPARE(frame, msg)
    local cid = acutil.getEventArgs(msg)
    local frame = ui.GetFrame("compare");
    frame:SetLayerLevel(102);

    if g.settings.use == 0 then
        return
    end
    local charNameRTxt = GET_CHILD_RECURSIVELY(frame, "charName", "ui::CRichText")
    local teamName = charNameRTxt:GetTextByKey("teamName")
    teamName = native_lang_process_name(teamName)

    local charName = charNameRTxt:GetTextByKey("charName")
    charName = native_lang_process_name(charName)

    charNameRTxt:SetTextByKey("teamName", teamName);
    charNameRTxt:SetTextByKey("charName", charName);
end

function native_lang_WEEKLY_BOSS_RANK_UPDATE()

    local wbrextend = nil
    local functionName = "WBREXTEND_ON_INIT" -- チェックしたい関数の名前を文字列として指定します
    if type(_G[functionName]) == "function" then
        wbrextend = true
    end

    local frame = ui.GetFrame("induninfo")
    local rankListBox = GET_CHILD_RECURSIVELY(frame, "rankListBox", "ui::CGroupBox");
    local cnt = session.weeklyboss.GetRankInfoListSize();

    if cnt == 0 then
        return;
    end
    for i = 1, cnt do
        local ctrlSet = GET_CHILD_RECURSIVELY(rankListBox, "CTRLSET_" .. i)
        local teamname = session.weeklyboss.GetRankInfoTeamName(i - 1);
        local org_name = teamname
        if g.settings.use == 0 then
            local name = GET_CHILD(ctrlSet, "attr_name_text", "ui::CRichText");
            name:SetTextByKey("value", teamname);
        else
            teamname = g.names[teamname] or teamname
            if native_lang_is_translation(teamname) then
                native_lang_process_name(teamname)
            end
            local name = GET_CHILD(ctrlSet, "attr_name_text", "ui::CRichText");
            name:SetTextByKey("value", teamname);

            if g.gear_scores then
                for _, score in ipairs(g.gear_scores) do
                    if score[1] == org_name then
                        local text_gs = rankListBox:CreateOrGetControl('button', "text_gs" .. i, 215, (i - 1) * 73 + 50,
                            100, 25);
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
        end

        function native_lang_MEMBERINFO_ONCLICK(frame, ctrl, str, num)
            ui.Chat('/memberinfo ' .. str);
            local compare = ui.GetFrame("compare")
            compare:SetLayerLevel(102);
        end

        local btn = rankListBox:CreateOrGetControl('button', "BTN_" .. i, 225, (i - 1) * 73 + 5, 100, 25);
        tolua.cast(btn, "ui::CButton");
        btn:SetEventScript(ui.LBUTTONUP, "native_lang_MEMBERINFO_ONCLICK");
        btn:SetEventScriptArgString(ui.LBUTTONUP, org_name);

        if wbrextend then
            btn:SetText("Memberinfo");

            if _G["WBREXTEND"][org_name] ~= nil then
                local txtGs = rankListBox:CreateOrGetControl('button', "txtGs_" .. i, 225, (i - 1) * 73 + 50, 100, 25);
                tolua.cast(txtGs, "ui::CButton");
                txtGs:SetText("GS: " .. _G["WBREXTEND"][org_name]);
                txtGs:SetEventScript(ui.LBUTTONUP, "GS_ONCLICK");
            end
        else
            btn:Resize(50, 25)
            btn:SetText("{ol}Info");
            btn:SetGravity(ui.RIGHT, ui.TOP)
            local rect = btn:GetMargin();
            btn:SetMargin(rect.left, rect.top + 45, rect.right + 25, rect.bottom);
        end
    end

end

--[[function native_lang_chat_recv(frame)

    local function read_last_lines_limited(file, num_lines)
        local lines = {}
        for line in file:lines() do
            table.insert(lines, line)
            if #lines > num_lines then
                table.remove(lines, 1)
            end
        end
        return lines
    end

    local recv_file = io.open(g.recv_msg, "r")
    if recv_file then
        local msg_len = recv_file:seek("end")
        if g.msg_len == msg_len and not g.individual and not g.first then

            recv_file:close()
            return 1
        else

            recv_file:seek("set", 0)
            local latest_lines = read_last_lines_limited(recv_file, 30)
            for i = 1, #latest_lines do
                local line = latest_lines[i]
                local chat_id, msg_type, msg, separate_msg, org_msg, org_name = line:match(
                    "^(.-):::(.-):::(.-):::(.-):::(.-):::(.*)$")
                if chat_id and g.chat_ids[tostring(chat_id)] and string.find(msg, "{#FF0000}★{/}", 1, true) then
                    g.chat_ids[tostring(chat_id)].trans_msg = msg
                    g.chat_ids[tostring(chat_id)].name = g.names[org_name] or org_name
                end
            end
            g.msg_len = msg_len

            recv_file:close()

            if g.individual then

                local msg = g.chat_ids[tostring(g.individual)].trans_msg

                if string.find(msg, "{#FF0000}★{/}") == nil and msg ~= "" then
                    return 1
                end

            end
            native_lang_replace()
            return 1
        end
    end
end]]
