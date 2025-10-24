local addonName = "NATIVE_LANG"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "0.0.2"
local exe = "0.0.2"

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

    native_lang_save_settings()

    local function open_or_create_file(file_path)
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

    open_or_create_file(g.recv_name)

    if not g.load then

        os.remove(g.send_name)
        os.remove(g.send_msg)
        os.remove(g.recv_msg)

        open_or_create_file(g.send_name)
        open_or_create_file(g.send_msg)
        open_or_create_file(g.recv_msg)

        g.load = true
    end

    native_lang_name_table_create()
    native_lang_msg_table_create()

end

function native_lang_msg_table_create()
    g.msgs = {}
    local msg_file = io.open(g.recv_msg, "r")

    if msg_file then
        for line in msg_file:lines() do
            local parts = g.split(line, ":::") -- 分割結果を取得
            if #parts > 0 then
                if parts[4] ~= "None" then
                    local separate_msg = parts[4]
                    separate_msg = separate_msg:gsub("},%s*{", "}{")
                    separate_msg = separate_msg:gsub("{%((%d+)}", "(%1")
                    separate_msg = separate_msg:gsub("{%)}", ")")
                    separate_msg = separate_msg:gsub("{@dicID_%^%*%$(.-)%$%*^}", "@dicID_^*$%1$*^")
                    separate_msg = separate_msg:gsub("{img link_party 24 24}{(.-)}{/}", "{img link_party 24 24}%1{/}")
                    parts[4] = separate_msg
                else
                    parts[4] = ""
                end
                local org_msg = parts[5]:match("^%s*(.-)%s*$") -- 前後の空白を削除parts[5]
                g.msgs[org_msg] = {
                    chat_id = parts[1],
                    msg_type = parts[2],
                    trans_msg = parts[3],
                    separate_msg = parts[4],
                    org_name = parts[6]
                }
            end
        end
        msg_file:close()
    end

end

function native_lang_name_table_create()

    g.names = {}
    local name_file = io.open(g.recv_name, "r")

    if name_file then
        for line in name_file:lines() do
            local left_name, right_name = line:match("^(.-):::(.*)$")
            if left_name and right_name then -- マッチが成功した場合のみ追加
                g.names[left_name] = right_name
            end
        end
        name_file:close()
    end
end

function native_lang_chat_all_replace_init()

    if g.settings.use == 0 then
        return
    end
    local file = io.open(g.recv_msg, "r")
    local size = file:seek("end") -- ファイルの末尾に移動してサイズを取得
    file:close()
    if g.recv_msg_size == size then
        return
    else
        -- native_lang_msg_table_create()
    end
    local chatframe = ui.GetFrame("chatframe")
    local child_count = chatframe:GetChildCount()

    for i = 0, child_count - 1 do
        local child = chatframe:GetChildByIndex(i)

        if child:GetName() ~= "chatgbox_TOTAL" and string.find(child:GetName(), "chatgbox_") then
            local chat_gbox = child:GetName()

            local gbox = GET_CHILD_RECURSIVELY(chatframe, chat_gbox)
            local gbox_child_count = gbox:GetChildCount()
            local ypos = 0
            for j = 0, gbox_child_count - 1 do
                local gbox_child = gbox:GetChildByIndex(j)
                local child_name = gbox_child:GetName()
                if tostring(child_name) ~= "_SCR" then
                    local margin_left = 20
                    local cluster = GET_CHILD(gbox, child_name)

                    local label = cluster:GetChild('bg')
                    local offsetX = chatframe:GetUserConfig("CTRLSET_OFFSETX")
                    local chat_Width = gbox:GetWidth()
                    local text = GET_CHILD_RECURSIVELY(cluster, "text")
                    -- print(tostring(text:GetText()))
                    local frame_chat_id = tostring(string.gsub(child_name, "cluster_", ""))

                    local font_style = text:GetTextByKey("font")
                    local font_size = text:GetTextByKey("size")

                    local get_text = text:GetText()
                    get_text:gsub("{#FF0000}★{/}", "")

                    local colon_index = string.find(get_text, ":")
                    local end_index = string.find(get_text, "{/}", colon_index)
                    local org_msg = ""
                    if colon_index and end_index then

                        org_msg = string.sub(get_text, colon_index + 1, end_index - 1):gsub("{nl}", ""):match(
                            "^%s*(.-)%s*$") -- 前後の空白を削除

                        -- org_msg = string.sub(get_text, colon_index + 1, end_index - 1):gsub("{nl}", "")
                    end
                    local bracket_index = string.find(get_text, "]")
                    colon_index = string.find(get_text, ":", bracket_index)
                    local org_name = ""
                    if bracket_index and colon_index then
                        org_name = string.sub(get_text, bracket_index + 1, colon_index - 1):match("^%s*(.-)%s*$") -- 前後の空白を削除

                        org_name = g.names[org_name] or org_name
                        -- print(org_name .. get_text)
                    end

                    local type = get_text:match("(%b[])")
                    if type == nil then
                        type = "System"
                    end

                    if g.msgs[org_msg] ~= nil then

                        local msg = g.msgs[org_msg].trans_msg .. g.msgs[org_msg].separate_msg
                        local msg_type = g.msgs[org_msg].msg_type
                        local name = g.names[org_name] or org_name
                        local msg_front, font_style, font_size =
                            native_lang_format_chat_message(chatframe, msg_type, name, msg)
                        if msg_front ~= nil then
                            native_lang_chat_replace(chatframe, msg_front, font_style, font_size, frame_chat_id)
                        end
                    else
                        local msg = org_msg
                        local msg_type = type
                        local name = org_name

                        local msg_front = string.format("%s%s : %s", msg_type, name, msg)

                        native_lang_chat_replace(chatframe, msg_front, font_style, font_size, frame_chat_id)

                    end

                    --[[local clustername = "cluster_" .. chat_id
                    local cluster = GET_CHILD_RECURSIVELY(frame, clustername)
                    local text = GET_CHILD_RECURSIVELY(cluster, "text")
                    text:SetTextByKey("font", font_style)
                    text:SetTextByKey("size", font_size)
                    text:SetTextByKey("text", msg_front)
                    if g.chat_ids[frame_chat_id] ~= nil then
                        local name = g.names[g.chat_ids[frame_chat_id].org_name] or g.chat_ids[frame_chat_id].org_name
                        local org_msg = g.chat_ids[frame_chat_id].org_msg
                        local separate_msg = g.chat_ids[frame_chat_id].separate_msg
                        if g.chat_ids[frame_chat_id].separate_msg ~= "None" then
                            separate_msg = separate_msg:gsub("},%s*{", "}{")
                            separate_msg = separate_msg:gsub("{%((%d+)}", "(%1") -- {(5 の部分を (5 に戻す
                            separate_msg = separate_msg:gsub("{%)}", ")")

                            separate_msg = separate_msg:gsub("{@dicID_%^%*%$(.-)%$%*^}", "@dicID_^*$%1$*^")

                            local pattern2 = "{img link_party 24 24}{(.-)}{/}"
                            separate_msg = separate_msg:gsub(pattern2, "{img link_party 24 24}%1{/}")
                        else
                            separate_msg = ""
                        end

                        local msg = g.chat_ids[frame_chat_id].trans_msg == "" and org_msg or
                                        g.chat_ids[frame_chat_id].trans_msg .. separate_msg
                        local msg_type = g.chat_ids[frame_chat_id].msg_type
                        local msg_front, font_style, font_size =
                            native_lang_format_chat_message(chatframe, msg_type, name, msg)
                        if msg_front ~= nil then

                            -- msg_front = msg_front .. "{#FF0000}★{/}"
                            native_lang_chat_replace(chatframe, msg_front, font_style, font_size, frame_chat_id)
                        end
                    end]]

                    label:Resize(chat_Width - offsetX, text:GetHeight())
                    cluster:Resize(chat_Width, label:GetHeight())
                    cluster:SetOffset(margin_left, ypos)
                    ypos = ypos + cluster:GetHeight()
                    --[[if g.chat_ids[frame_chat_id].name_trans == "No" and g.chat_ids[frame_chat_id].name_trans == "No" then
                        g.chat_child = child_count
                    end]]
                end
            end
            if gbox:GetLineCount() == gbox:GetCurLine() + gbox:GetVisibleLineCount() then
                gbox:SetScrollPos(99999)
            end
        end
    end

    -- g.recv_msg_size = size
end
-- native_lang_chat_all_replace_init()
function native_lang_TOS_GOOGLE_TRANSLATE_ON_INIT(addon, frame)
    return
end

function native_lang_KOJA_NAME_TRANSLATER_ON_INIT(addon, frame)
    return
end

function native_lang_translate_exe_start()
    if g.settings.use == 0 then
        return
    end
    if not g.start then
        local exe_path = "../addons/native_lang/native_lang_python/native_lang-v" .. exe .. ".exe"
        local command = string.format('start "" /min "%s"', exe_path)
        os.execute(command)
        g.start = true
    end

end

function native_lang_UPDATE_PARTYINFO_HP(partyInfoCtrlSet, partyMemberInfo)
    _native_lang_UPDATE_PARTYINFO_HP(partyInfoCtrlSet, partyMemberInfo)
end

function _native_lang_UPDATE_PARTYINFO_HP(partyInfoCtrlSet, partyMemberInfo)

    if g.settings.use == 0 then
        base["UPDATE_PARTYINFO_HP"](partyInfoCtrlSet, partyMemberInfo)
    else
        local nameObj = partyInfoCtrlSet:GetChild('name_text');
        local nameRichText = tolua.cast(nameObj, "ui::CRichText");
        local name = nameRichText:GetTextByKey("name");

        if native_lang_is_translation(name) then
            local font = name:match("({.-})")

            name = name:gsub("{.-}", ""):match("^%s*(.-)%s*$")

            name = native_lang_process_name(nil, name)

            if font then
                name = font .. name
            end

            nameRichText:SetTextByKey("name", name)
        end
        base["UPDATE_PARTYINFO_HP"](partyInfoCtrlSet, partyMemberInfo)
    end
end

function native_lang_DAMAGE_METER_GAUGE_SET(ctrl, leftStr, point, rightStr, skin)
    _native_lang_DAMAGE_METER_GAUGE_SET(ctrl, leftStr, point, rightStr, skin)
end

function _native_lang_DAMAGE_METER_GAUGE_SET(ctrl, leftStr, point, rightStr, skin)
    if g.settings.use == 0 then
        base["DAMAGE_METER_GAUGE_SET"](ctrl, leftStr, point, rightStr, skin)
    else
        local font = "{@st42b}{ds}{s12}"
        leftStr = leftStr:gsub("{@st42b}{ds}{s12}", ""):match("^%s*(.-)%s*$")
        leftStr = g.names[leftStr] or leftStr
        leftStr = font .. leftStr

        base["DAMAGE_METER_GAUGE_SET"](ctrl, leftStr, point, rightStr, skin)
    end
end

function NATIVE_LANG_ON_INIT(addon, frame)
    g.addon = addon
    g.frame = frame
    g.chat_ids = g.chat_ids or {}
    g.recv_msg_size = 0
    g.name_len = 0
    g.msg_len = 0

    -- tos_google_translate無効化
    g.SetupHook(native_lang_TOS_GOOGLE_TRANSLATE_ON_INIT, "TOS_GOOGLE_TRANSLATE_ON_INIT")
    -- koja_name_tarnslater無効化
    g.SetupHook(native_lang_KOJA_NAME_TRANSLATER_ON_INIT, "KOJA_NAME_TRANSLATER_ON_INIT")

    native_lang_load_settings()

    g.SetupHook(native_lang_UPDATE_PARTYINFO_HP, "UPDATE_PARTYINFO_HP")
    g.SetupHook(native_lang_DAMAGE_METER_GAUGE_SET, "DAMAGE_METER_GAUGE_SET")

    addon:RegisterMsg("GAME_START_3SEC", "native_lang_3SEC");
    addon:RegisterMsg("GAME_START", "native_lang_frame_init");
    -- addon:RegisterMsg("GAME_START", "native_lang_translate_exe_start");
end

function native_lang_3SEC(frame, msg, str, num)
    acutil.setupEvent(g.addon, "DRAW_CHAT_MSG", "native_lang_DRAW_CHAT_MSG");
    g.addon:RegisterMsg("FPS_UPDATE", "native_lang_name_trans");
    -- frame:RunUpdateScript("native_lang_async_msg_send", 2.0)
    g.addon:RegisterMsg("FPS_UPDATE", "native_lang_chat_all_replace_init");
    -- native_lang_chat_all_replace_init()
end

function native_lang_switching()
    local chatframe = ui.GetFrame("chatframe")
    local trans_btn = GET_CHILD_RECURSIVELY(chatframe, "trans_btn")
    AUTO_CAST(trans_btn)

    if g.settings.use == 1 then
        g.settings.use = 0
        trans_btn:SetSkinName('test_gray_button')
        trans_btn:SetTextTooltip("Native Lang is suspended")
    else
        g.settings.use = 1
        trans_btn:SetSkinName("test_red_button")
        trans_btn:SetTextTooltip("Native Lang in use")
    end
    native_lang_save_settings()
end

function native_lang_restart()
    local file = io.open(g.restart, "w")
    file:write("restart")
    file:close()
    g.start = false
    g.load = false
    ui.SysMsg("[Native Lang] restarted.{nl}" .. "Please return to the barracks once.")
end

function native_lang_context()
    local context = ui.CreateContextMenu("native_lang_context", "Native Lang", 0, 0, 50, 0)
    ui.AddContextMenuItem(context, "-----")
    local str_scp
    if g.settings.use == 1 then
        str_scp = string.format("native_lang_switching()")
        ui.AddContextMenuItem(context, "Native Lang stop", str_scp)
    else
        str_scp = string.format("native_lang_switching()")
        ui.AddContextMenuItem(context, "Native Lang operation", str_scp)
    end
    ui.OpenContextMenu(context)
    str_scp = string.format("native_lang_restart()")
    ui.AddContextMenuItem(context, "Restart", str_scp)
end

function native_lang_frame_init(frame, ctrl, argStr, argNum)
    local chatframe = ui.GetFrame("chatframe")
    local tabgbox = GET_CHILD_RECURSIVELY(chatframe, "tabgbox")
    local trans_btn = tabgbox:CreateOrGetControl("button", "trans_btn", 270, -1, 30, 30)
    AUTO_CAST(trans_btn)
    if g.settings.use == 0 then
        trans_btn:SetSkinName('test_gray_button')
        trans_btn:SetTextTooltip("Native Lang is suspended")
    elseif g.settings.use == 1 then
        trans_btn:SetSkinName("test_red_button")
        trans_btn:SetTextTooltip("Native Lang in use")
    end
    trans_btn:SetText("{ol}{s14}{#FFFFFF}" .. g.lang)
    trans_btn:SetEventScript(ui.LBUTTONUP, "native_lang_context")
end

function native_lang_chat_name_replace(frame, msg_type, msg, name, chat_id)

    name = name:gsub("{+", "")

    local right_name = native_lang_process_name(frame, name)

    if right_name ~= name then
        local msg_front, font_style, font_size = native_lang_format_chat_message(frame, msg_type, right_name, msg)
        if msg_front ~= nil then

            native_lang_chat_replace(frame, msg_front, font_style, font_size, chat_id)
            g.chat_ids[tostring(chat_id)].name = right_name
            g.chat_ids[tostring(chat_id)].name_trans = "No"
        end
        --[[else
        local frame = ui.GetFrame("chatframe")
        frame:RunUpdateScript("native_lang_chat_name_replace_update", 1.0)]]
    end
end

function native_lang_chat_name_replace_update(frame)

    local recv_file = io.open(g.recv_name, "r")
    if recv_file then
        local name_len = recv_file:seek("end")
        if g.name_len == name_len then
            recv_file:close() -- ファイルを閉じる
            return 1
        else
            recv_file:seek("set", 0)
            g.name_len = name_len

        end
    end

    for key_chat_id, chat in pairs(g.chat_ids) do
        if chat.name_trans == "Yes" then
            local name = chat.org_name
            local right_name = native_lang_process_name(frame, name)
            local org_msg = chat.org_msg
            local msg_tyep = chat.msg_type
            local msg_front, font_style, font_size = native_lang_format_chat_message(frame, msg_tyep, right_name,
                org_msg)
            if msg_front ~= nil then
                native_lang_chat_replace(frame, msg_front, font_style, font_size, tonumber(key_chat_id))
                chat.name = right_name
                chat.name_trans = "No"
            end
        end
    end
end

function native_lang_chat_replace(frame, msg_front, font_style, font_size, chat_id)

    local clustername = "cluster_" .. chat_id
    local cluster = GET_CHILD_RECURSIVELY(frame, clustername)
    local text = GET_CHILD_RECURSIVELY(cluster, "text")
    text:SetTextByKey("font", font_style)
    text:SetTextByKey("size", font_size)
    text:SetTextByKey("text", msg_front)
end

-- ui.Chat("/p 쌀먹징징충박멸?????")
function native_lang_format_chat_message(frame, msg_type, right_name, msg)
    local msg_type_map = {
        Normal = 1,
        Shout = 2,
        Party = 3,
        Guild = 4,
        System = 7
    }

    local chat_type_id = msg_type_map[msg_type]
    if chat_type_id then
        local font_size = tonumber(GET_CHAT_FONT_SIZE())
        local font_style = frame:GetUserConfig("TEXTCHAT_FONTSTYLE_" .. msg_type:upper())
        local msg_front = string.format("[%s]%s : %s", ScpArgMsg("ChatType_" .. chat_type_id), right_name, msg)
        return msg_front, font_style, font_size
    end
    return nil, nil, nil
end

function native_lang_msg_replace(frame)

    local recv_file = io.open(g.recv_msg, "r")
    if recv_file then
        local msg_len = recv_file:seek("end")
        if g.msg_len == msg_len then
            recv_file:close() -- ファイルを閉じる
            return 1
        else
            recv_file:seek("set", 0)
            g.msg_len = msg_len
        end
        -- print("ファイルの長さ: " .. g.msg_len .. ":" .. msg_len .. " バイト")
        for line in recv_file:lines() do
            local chat_id, msg_type, msg, separate_msg, org_msg = line:match("^(.-):::(.-):::(.-):::(.-):::(.*)$")

            if g.chat_ids[tostring(chat_id)].msg_trans == "Yes" then
                g.chat_ids[tostring(chat_id)].trans_msg = msg
                g.chat_ids[tostring(chat_id)].separate_msg = separate_msg
                g.chat_ids[tostring(chat_id)].msg_trans = "No"
                local msg_type = g.chat_ids[tostring(chat_id)].msg_type
                local name = g.chat_ids[tostring(chat_id)].name
                local right_name = native_lang_process_name(frame, name)
                local msg_front, font_style, font_size = native_lang_format_chat_message(frame, msg_type, right_name,
                    msg)

                if separate_msg and separate_msg ~= "None" then
                    separate_msg = separate_msg:gsub("},%s*{", "}{")
                    separate_msg = separate_msg:gsub("{%((%d+)}", "(%1") -- {(5 の部分を (5 に戻す
                    separate_msg = separate_msg:gsub("{%)}", ")")
                    -- if not separate_msg:find("Earring") then
                    separate_msg = separate_msg:gsub("{@dicID_%^%*%$(.-)%$%*^}", "@dicID_^*$%1$*^")

                    local pattern2 = "{img link_party 24 24}{(.-)}{/}"
                    separate_msg = separate_msg:gsub(pattern2, "{img link_party 24 24}%1{/}")

                    msg_front = msg_front .. separate_msg

                end

                native_lang_chat_replace(frame, msg_front, font_style, font_size, chat_id)
            end
        end
        native_lang_chat_all_replace()
        recv_file:close()
    end
end

--[[function native_lang_async_msg_send(frame)
    if g.settings.use == 0 then
        return 1
    end
    local recv_ids = {}
    local send_ids = {}

    local function load_chat_ids(file_name, ids_table)
        local file = io.open(file_name, 'r')
        if file then
            for line in file:lines() do
                local parts = line:split(":::") -- split関数を最適化
                if #parts >= 1 then
                    ids_table[parts[1] = true -- chat_idをキーにして存在することを保持
                end
            end
            file:close()
        end
    end

    load_chat_ids(g.recv_msg, recv_ids)
    load_chat_ids(g.send_msg, send_ids)

    local messages_to_send = {}

    for chat_id, chat_info in pairs(g.chat_ids) do
        local msg_trans = chat_info.msg_trans

        if msg_trans == "Yes" then

            if not recv_ids[tostring(chat_id)] and not send_ids[tostring(chat_id)] then
                local msg_type = chat_info.msg_type
                local send_msg_content =
                    chat_id .. ":::" .. msg_type .. ":::" .. g.chat_ids[tostring(chat_id)].proc_msg .. ":::" ..
                        g.chat_ids[tostring(chat_id)].separate_msg .. ":::" .. g.chat_ids[tostring(chat_id)].org_msg
                table.insert(messages_to_send, send_msg_content)

            end
        end
    end

    if #messages_to_send > 0 then
        local send_file = io.open(g.send_msg, "a")
        if send_file then
            for _, msg in ipairs(messages_to_send) do
                send_file:write(msg .. "\n")
            end
            send_file:flush()
            send_file:close()
        end
    end

    --[[local frame = ui.GetFrame("chatframe")
    frame:RunUpdateScript("native_lang_msg_replace", 1.5)]

    return 1
end]]

function native_lang_msg_send(frame, send_msg)

    local send_file = io.open(g.send_msg, "a")
    if send_file then
        send_file:write(send_msg .. "\n")
        send_file:flush()
        send_file:close()
    end

end

function native_lang_msg_processing(msg)

    local function modify_string(msg)

        local pattern = "{img link_party 24 24}(.-){/}"
        msg = msg:gsub(pattern, "{img link_party 24 24}{" .. "%1" .. "}{/}")

        msg = msg:gsub("(@dicID_%^%*%$.-%$%*%^)", "{%1}")

        msg = msg:gsub("%((%d+)", "{(%1}") -- (5 の部分を {(5 に
        msg = msg:gsub("%)", "{)}")

        local pattern3 = "!@#%$(.-)#@!"
        msg = msg:gsub(pattern3, "{!@#%$(.-)#@!}")
        return msg
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

    local function anti_pattern(modified_msg)
        -- 特殊文字を含むリスト
        local patterns = {",", "&", "!", ":", ";", "%(", "%)", "%[", "%]", "%{", "%}", "%'", "%\"", "/"}

        for _, pattern in ipairs(patterns) do
            modified_msg = modified_msg:gsub(pattern .. "+", " ")

        end
        return modified_msg
    end

    msg = modify_string(msg)

    local modified_msg, separate_msg = wrapped_contents(msg)

    if modified_msg:match("^%s*$") then
        return nil, nil
    end

    modified_msg = anti_pattern(modified_msg)

    modified_msg = modified_msg:gsub(" +", " ")
    return modified_msg, separate_msg

end

function native_lang_chat_all_replace()

    local chatframe = ui.GetFrame("chatframe")
    local child_count = chatframe:GetChildCount()

    for i = 0, child_count - 1 do
        local child = chatframe:GetChildByIndex(i)
        if child:GetName() ~= "chatgbox_TOTAL" and string.find(child:GetName(), "chatgbox_") then
            local chat_gbox = child:GetName()
            local gbox = GET_CHILD_RECURSIVELY(chatframe, chat_gbox)
            local gbox_child_count = gbox:GetChildCount()
            local ypos = 0
            for j = 0, gbox_child_count - 1 do
                local gbox_child = gbox:GetChildByIndex(j)
                local child_name = gbox_child:GetName()

                if tostring(child_name) ~= "_SCR" then
                    local margin_left = 20
                    local cluster = GET_CHILD(gbox, child_name)
                    local label = cluster:GetChild('bg')
                    local offsetX = chatframe:GetUserConfig("CTRLSET_OFFSETX")
                    local chat_Width = gbox:GetWidth()
                    local text = GET_CHILD_RECURSIVELY(cluster, "text")

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
    end
end
-- ui.Chat("/p 쌀먹징징충박멸?????")

function native_lang_DRAW_CHAT_MSG(frame, msg)
    if g.settings.use == 0 then
        return
    end
    local groupboxname, startindex, chatframe = acutil.getEventArgs(msg);

    if chatframe == nil then
        return;
    end

    local frame = ui.GetFrame("chatframe")
    local size = session.ui.GetMsgInfoSize(groupboxname)
    local chat = session.ui.GetChatMsgInfo(groupboxname, size - 1)

    for i = startindex, size - 1 do
        local clusterinfo = session.ui.GetChatMsgInfo(groupboxname, i)
        local chat_id = clusterinfo:GetMsgInfoID()
        if g.chat_ids[tostring(chat_id)] then
            return
        end
        local clustername = "cluster_" .. chat_id
        local cluster = GET_CHILD_RECURSIVELY(frame, clustername)

        if cluster == nil then
            return
        else

            local msg_type = chat:GetMsgType()
            if msg_type ~= "Normal" and msg_type ~= "Shout" and msg_type ~= "Party" and msg_type ~= "Guild" and msg_type ~=
                "System" then
                return
            end

            local index = tonumber(frame:GetUserValue("BTN_INDEX")) + 1
            local chat_option = ui.GetFrame("chat_option")
            local tabgbox = GET_CHILD_RECURSIVELY(chat_option, "tabgbox" .. index)
            local btn_general_pic = GET_CHILD_RECURSIVELY(tabgbox, "btn_general_pic")
            local btn_shout_pic = GET_CHILD_RECURSIVELY(tabgbox, "btn_shout_pic")
            local btn_party_pic = GET_CHILD_RECURSIVELY(tabgbox, "btn_party_pic")
            local btn_guild_pic = GET_CHILD_RECURSIVELY(tabgbox, "btn_guild_pic")
            local btn_system_pic = GET_CHILD_RECURSIVELY(tabgbox, "btn_system_pic")
            if btn_general_pic:IsVisible() == 0 and msg_type == "Normal" then
                return
            elseif btn_shout_pic:IsVisible() == 0 and msg_type == "Shout" then
                return
            elseif btn_party_pic:IsVisible() == 0 and msg_type == "Party" then
                return
            elseif btn_guild_pic:IsVisible() == 0 and msg_type == "Guild" then
                return
            elseif btn_system_pic:IsVisible() == 0 and msg_type == "System" then
                return
            end

            local msg = chat:GetMsg()
            local org_msg = msg
            msg = msg:gsub("{#0000FF}", "{#FFFF00}")

            local name = chat:GetCommanderName()
            local org_name = name
            name = name:gsub(" %[(.-)%]", "")

            if msg_type == "System" and string.find(msg, "Guild_Colony_Occupation_WorldMessage") then
                local text = msg:match("%$%*%$partyName%$%*%$([^%$]+)%$")

                if text then
                    text = g.names[text]
                    print("取得した文字:" .. text) -- 結果を表示
                    msg = msg:gsub("%$%*%$partyName%$%*%$([^%$]+)%$", "%$%*%$partyName%$%*%$" .. text .. "%$")

                end

            end

            print(chat_id .. ":" .. org_name .. ":" .. org_msg)

            if native_lang_is_translation(name) then
                g.chat_ids[tostring(chat_id)] = {
                    msg_type = msg_type,
                    name = name,
                    org_name = org_name,
                    org_msg = org_msg,
                    proc_msg = nil,
                    separate_msg = "None",
                    name_trans = "Yes",
                    msg_trans = "No",
                    trans_msg = ""
                }
                native_lang_chat_name_replace(frame, msg_type, msg, name, chat_id)
            end

            if string.find(msg, "{spine ") then
                return
            end
            local name_trans_value = ""
            if g.chat_ids[tostring(chat_id)] then
                name_trans_value = g.chat_ids[tostring(chat_id)].name_trans
            end
            if name_trans_value == "" then
                name_trans_value = "No"
            end

            local proc_msg, separate_msg = native_lang_msg_processing(msg)
            if proc_msg == nil then
                return
            end

            if native_lang_is_translation_msg(proc_msg) then

                if name == "System" then

                    name = ""
                end

                print(chat_id .. ":" .. name .. ":" .. proc_msg)
                g.chat_ids[tostring(chat_id)] = {
                    msg_type = msg_type,
                    name = name,
                    org_name = org_name,
                    org_msg = org_msg,
                    proc_msg = proc_msg,
                    separate_msg = #separate_msg == 0 and "None" or table.concat(separate_msg, ","),
                    name_trans = name_trans_value,
                    msg_trans = "Yes",
                    trans_msg = ""
                }

                local send_msg = chat_id .. ":::" .. msg_type .. ":::" .. proc_msg .. ":::" ..
                                     g.chat_ids[tostring(chat_id)].separate_msg .. ":::" .. org_msg .. ":::" .. org_name
                native_lang_msg_send(frame, send_msg)
            end
            break
        end
    end
end

function native_lang_given_name(frame_given_name, pc_txt_frame)
    local given_name = frame_given_name:GetText()
    local clean_name = given_name:gsub("{.-}", ""):gsub("__+", "_"):match("^%s*(.-)%s*$")

    if native_lang_is_translation(clean_name) then
        local right_name = native_lang_process_name(frame_given_name, clean_name)
        if right_name ~= clean_name then
            local original_part = given_name:sub(1, 9)
            local new_given_name = original_part .. right_name

            local frame_given_name_Width_ = frame_given_name:GetWidth()
            frame_given_name:SetText(new_given_name)
            local frame_given_name_Width = frame_given_name:GetWidth()
            local x = frame_given_name:GetX();

            local frame_family_name = GET_CHILD(pc_txt_frame, "familyName")
            if frame_family_name ~= nil then
                local frame_family_name_margin = frame_family_name:GetMargin()
                frame_family_name:SetMargin(x + frame_given_name_Width + 5, frame_family_name_margin.top,
                    frame_family_name_margin.right, frame_family_name_margin.bottom);
            end
        end
    end
end

function native_lang_family_name(frame_family_name)
    local family_name = frame_family_name:GetText()
    local clean_name = family_name:gsub("{.-}", ""):gsub("__+", "_"):match("^%s*(.-)%s*$")

    if native_lang_is_translation(clean_name) then
        local right_name = native_lang_process_name(frame_family_name, clean_name)
        if right_name ~= clean_name then
            local original_part = family_name:sub(1, 9)
            local new_family_name = original_part .. right_name
            frame_family_name:SetText(new_family_name)
        end

    end
end

function native_lang_guild_name(frame_guild_name)

    local guild_name = frame_guild_name:GetText()

    if string.find(guild_name, "{img guild_master_mark 20 20}") then
        guild_name = string.gsub(guild_name, "{img guild_master_mark 20 20}", "")
    end

    if native_lang_is_translation(guild_name) then
        local new_guild_name = native_lang_process_name(frame_guild_name, guild_name)
        if new_guild_name ~= guild_name then
            frame_guild_name:SetText(new_guild_name)
        end
    end
end

function native_lang_shop_name(shop_frame)
    local shop_text = GET_CHILD(shop_frame, "text");
    AUTO_CAST(shop_text)
    if shop_text ~= nil then
        local text = shop_text:GetText():gsub("{.-}", ""):gsub("__+", "_"):match("^%s*(.-)%s*$")
        if native_lang_is_translation(text) then

            local new_shop_name = native_lang_process_name(shop_text, text)
            if new_shop_name ~= text then
                shop_text:SetTextByKey("value", new_shop_name);
            end
        end
    end
    local frame_lv_box = GET_CHILD(shop_frame, "withLvBox");
    if frame_lv_box ~= nil then
        local frame_shop_name = GET_CHILD(frame_lv_box, "lv_title");
        if frame_shop_name ~= nil then
            local shop_name = frame_shop_name:GetText():gsub("{.-}", ""):gsub("__+", "_"):match("^%s*(.-)%s*$")

            if native_lang_is_translation(shop_name) then
                local new_shop_name = native_lang_process_name(frame_shop_name, shop_name)
                if new_shop_name ~= shop_name then
                    frame_shop_name:SetTextByKey("value", new_shop_name);
                end
            end
        end
    end
end

function native_lang_process_name(frame, clean_name)

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
                        -- 既に存在するキーをテーブルに追加
                        existing_keys[key] = true
                        -- 特定の条件を満たす場合は処理を終了
                        if string.find(key, "★") then
                            existing_keys[key] = true
                        elseif string.find(key, "PartyMemberMapNChannel") then
                            existing_keys[key] = true
                        end
                    end
                end
                read_file:close()
            end

            -- 重複がない場合に書き込む
            if not existing_keys[clean_name] then
                local append_file = io.open(g.send_name, "a")
                if append_file then
                    append_file:write(clean_name .. ":::" .. clean_name .. "\n")
                    append_file:flush()
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

    local selected_objects, selected_objects_count = SelectObject(GetMyPCObject(), 1000, "ALL")

    for i = 1, selected_objects_count do
        local handle = GetHandle(selected_objects[i])
        if handle ~= nil then
            if info.IsPC(handle) == 1 then
                local frame_name = "charbaseinfo1_" .. handle
                local pc_txt_frame = ui.GetFrame(frame_name)
                if pc_txt_frame ~= nil then
                    local frame_given_name = GET_CHILD(pc_txt_frame, "givenName")
                    if frame_given_name ~= nil then
                        native_lang_given_name(frame_given_name, pc_txt_frame)
                    end

                    local frame_family_name = GET_CHILD(pc_txt_frame, "familyName")
                    if frame_family_name ~= nil then
                        native_lang_family_name(frame_family_name)
                    end

                    local frame_name = GET_CHILD(pc_txt_frame, "name")
                    if frame_name ~= nil then
                        native_lang_family_name(frame_name)
                    end

                    local frame_guild_name = GET_CHILD(pc_txt_frame, "guildName")
                    if frame_guild_name ~= nil then
                        native_lang_guild_name(frame_guild_name)
                    end

                    local shop_frame = ui.GetFrame("SELL_BALLOON_" .. handle);
                    if shop_frame ~= nil then
                        native_lang_shop_name(shop_frame)
                    end

                end
            end
        end
    end
end

--[[function native_lang_UPDATE_PARTYINFO_HP(frame, msg)

    local party_info_ctrlSet, party_member_info = acutil.getEventArgs(msg);

    local party_info_frame = ui.GetFrame('partyinfo')
    local FAR_MEMBER_NAME_FONT_COLORTAG = party_info_frame:GetUserConfig("FAR_MEMBER_NAME_FONT_COLORTAG")
    local NEAR_MEMBER_NAME_FONT_COLORTAG = party_info_frame:GetUserConfig("NEAR_MEMBER_NAME_FONT_COLORTAG")

    local stat = party_member_info:GetInst();
    local pos = stat:GetPos();
    local my_handle = session.GetMyHandle();
    local distance = info.GetDestPosDistance(pos.x, pos.y, pos.z, my_handle);
    local shared_cls = GetClass("SharedConst", 'PARTY_SHARE_RANGE');
    local my_mapname = session.GetMapName();
    local party_member_mapname = GetClassByType("Map", party_member_info:GetMapID()).ClassName;

    local party_member_name = party_member_info:GetName();
    party_member_name:gsub(FAR_MEMBER_NAME_FONT_COLORTAG, "")
    party_member_name:gsub(FAR_MEMBER_NAME_FONT_COLORTAG, "")
    party_member_name = native_lang_process_name(nil, party_member_name)

    local name_obj = party_info_ctrlSet:GetChild('name_text');
    local name_text = tolua.cast(name_obj, "ui::CRichText");

    if distance < shared_cls.Value and my_mapname == party_member_mapname then

        party_member_name = NEAR_MEMBER_NAME_FONT_COLORTAG .. party_member_name;
        name_text:SetTextByKey("name", party_member_name);
    else

        party_member_name = FAR_MEMBER_NAME_FONT_COLORTAG .. party_member_name;
        name_text:SetTextByKey("name", party_member_name);
    end
end]]
