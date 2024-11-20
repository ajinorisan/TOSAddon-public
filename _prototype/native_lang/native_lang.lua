local addonName = "NATIVE_LANG"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "0.0.1"
local exe = "0.0.1"

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

    native_lang_save_settings()
    native_lang_chat_all_replace_init()
end

function native_lang_TOS_GOOGLE_TRANSLATE_ON_INIT(addon, frame)
    return
end

function native_lang_translate_exe_start()
    if not g.start then
        local exe_path = "../addons/native_lang/native_lang_python/native_lang-v0.0.1.exe"
        local command = string.format('start "" /min "%s"', exe_path)
        os.execute(command)
        g.start = true
    end

end

function NATIVE_LANG_ON_INIT(addon, frame)
    g.addon = addon
    g.frame = frame
    g.chat_ids = g.chat_ids or {}
    g.chat_count = 0
    g.child_names = {}
    -- tos_google_translate無効化
    g.SetupHook(native_lang_TOS_GOOGLE_TRANSLATE_ON_INIT, "TOS_GOOGLE_TRANSLATE_ON_INIT")

    native_lang_load_settings()

    addon:RegisterMsg("GAME_START_3SEC", "native_lang_3SEC");
    -- addon:RegisterMsg("GAME_START", "native_lang_translate_exe_start");
end

function native_lang_3SEC(frame, msg, str, num)
    acutil.setupEvent(g.addon, "DRAW_CHAT_MSG", "native_lang_DRAW_CHAT_MSG");
    g.addon:RegisterMsg("FPS_UPDATE", "native_lang_name_trans");
    -- g.addon:RegisterMsg("FPS_UPDATE", "native_lang_chat_all_replace");
    frame:RunUpdateScript("native_lang_async_msg_send", 10.0)

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
    else
        local frame = ui.GetFrame("chatframe")
        frame:RunUpdateScript("native_lang_chat_name_replace_update", 5.0)
    end
end

function native_lang_chat_name_replace_update(frame)

    for key_chat_id, chat in pairs(g.chat_ids) do
        if chat.name_trans == "Yes" then
            local name = chat.name
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
                    local separate_msgs = {}
                    for msg_item in separate_msg:gmatch("[^,]+") do
                        table.insert(separate_msgs, msg_item)
                    end

                    for _, msg_item in ipairs(separate_msgs) do

                        local pattern1 = "{@dicID_(.-)}"
                        msg_item = msg_item:gsub(pattern1, "@dicID_%1")

                        local pattern2 = "{img link_party 24 24}{(.-)}"
                        msg_item = msg_item:gsub(pattern2, "{img link_party 24 24}%1")

                        msg_front = msg_front .. msg_item
                    end
                end

                msg_front = msg_front .. "{#FF0000}★{/}"
                native_lang_chat_replace(frame, msg_front, font_style, font_size, chat_id)
            end
        end
        native_lang_chat_all_replace()
        recv_file:close()
    end
end

function native_lang_async_msg_send(frame)
    -- recvに存在するchat_idを取得する
    local existing_chat_ids = {}

    local f = io.open(g.recv_msg, 'r')
    if f then
        for line in f:lines() do
            local parts = line:split(":::") -- ここでsplit関数が必要
            if #parts >= 1 then
                existing_chat_ids[parts[1]] = true -- chat_idをキーにして存在することを保持
            end
        end
        f:close()
    end

    -- sendに存在するchat_idを取得する
    local sent_chat_ids = {}

    local f = io.open(g.send_msg, 'r')
    if f then
        for line in f:lines() do
            local parts = line:split(":::") -- ここでsplit関数が必要
            if #parts >= 1 then
                sent_chat_ids[parts[1]] = true -- chat_idをキーにして存在することを保持
            end
        end
        f:close()
    end

    for chat_id, chat_info in pairs(g.chat_ids) do
        local msg_trans = chat_info.msg_trans
        print(chat_id)
        if msg_trans == "Yes" then
            -- recvにもsendにも存在しない場合のみ送信
            if not existing_chat_ids[tostring(chat_id)] and not sent_chat_ids[tostring(chat_id)] then
                local msg_type = chat_info.msg_type
                local send_msg_content =
                    chat_id .. ":::" .. msg_type .. ":::" .. g.chat_ids[tostring(chat_id)].proc_msg .. ":::" ..
                        g.chat_ids[tostring(chat_id)].separate_msg .. ":::" .. g.chat_ids[tostring(chat_id)].org_msg
                native_lang_msg_send(frame, send_msg_content)
            end
        end
    end
    return 1
end

function native_lang_msg_send(frame, send_msg)
    local send_file = io.open(g.send_msg, "a")

    if send_file then
        send_file:write(send_msg .. "\n")
        send_file:flush()
        send_file:close()

        local frame = ui.GetFrame("chatframe")
        frame:RunUpdateScript("native_lang_msg_replace", 5.5)
    end
end

function native_lang_msg_processing(msg)

    local function modify_string(msg)

        local pattern = "{img link_party 24 24}(.-){/}{/}"
        msg = msg:gsub(pattern, "{img link_party 24 24}{%1}{/}{/}")

        pattern = "@dicID_%^%*%$(.-)%$%*%^"
        msg = msg:gsub(pattern, "{@dicID_%1}")

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
        local patterns = {",", "&", "?", "!", ":", ";", "%(", "%)", "%[", "%]", "%{", "%}", "%'", "%\"", "/"}

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

function native_lang_chat_all_replace_init()
    local chatframe = ui.GetFrame("chatframe")
    local child_count = chatframe:GetChildCount()

    local recv_file = io.open(g.recv_msg, "r")
    if recv_file then
        for line in recv_file:lines() do
            local chat_id, msg_type, msg, separate_msg, org_msg = line:match("^(.-):::(.-):::(.-):::(.-):::(.*)$")
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

                            if g.chat_ids[tostring(chat_id)] then
                                local name = g.chat_ids[tostring(chat_id)].name
                                local msg = g.chat_ids[tostring(chat_id)].trans_msg ~= "" and org_msg or
                                                g.chat_ids[tostring(chat_id)].trans_msg
                                native_lang_chat_name_replace(chatframe, msg_type, msg, name, chat_id)
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
            end
        end
        recv_file:close()
    end

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
        local clustername = "cluster_" .. chat_id
        local cluster = GET_CHILD_RECURSIVELY(frame, clustername)

        if cluster == nil then
            return
        else
            g.chat_ids[tostring(chat_id)] = {}
            local msg_type = chat:GetMsgType()
            if msg_type ~= "Normal" and msg_type ~= "Shout" and msg_type ~= "Party" and msg_type ~= "Guild" then
                return
            end

            local index = tonumber(frame:GetUserValue("BTN_INDEX")) + 1
            local chat_option = ui.GetFrame("chat_option")
            local tabgbox = GET_CHILD_RECURSIVELY(chat_option, "tabgbox" .. index)
            local btn_general_pic = GET_CHILD_RECURSIVELY(tabgbox, "btn_general_pic")
            local btn_shout_pic = GET_CHILD_RECURSIVELY(tabgbox, "btn_shout_pic")
            local btn_party_pic = GET_CHILD_RECURSIVELY(tabgbox, "btn_party_pic")
            local btn_guild_pic = GET_CHILD_RECURSIVELY(tabgbox, "btn_guild_pic")
            if btn_general_pic:IsVisible() == 0 and msg_type == "Normal" then
                return
            elseif btn_shout_pic:IsVisible() == 0 and msg_type == "Shout" then
                return
            elseif btn_party_pic:IsVisible() == 0 and msg_type == "Party" then
                return
            elseif btn_guild_pic:IsVisible() == 0 and msg_type == "Guild" then
                return
            end

            local msg = chat:GetMsg()
            msg = msg:gsub("{#0000FF}", "{#FFFF00}")
            local name = chat:GetCommanderName()
            name = name:gsub(" %[(.-)%]", "")

            print(chat_id .. ":" .. name .. ":" .. msg)

            if native_lang_is_translation(name) then
                g.chat_ids[tostring(chat_id)] = {
                    msg_type = msg_type,
                    name = name,
                    org_msg = msg,
                    proc_msg = nil,
                    separate_msg = "None",
                    name_trans = "Yes",
                    msg_trans = "No",
                    trans_msg = ""
                }
                native_lang_chat_name_replace(frame, msg_type, msg, name, chat_id)
            end
            print(chat_id .. ":" .. name .. ":" .. msg)
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

            if native_lang_is_translation(msg) then

                local modified_msg, separate_msg = native_lang_msg_processing(msg)
                if modified_msg == nil then
                    return
                end

                print(chat_id .. ":" .. name .. ":" .. modified_msg)
                g.chat_ids[tostring(chat_id)] = {
                    msg_type = msg_type,
                    name = name,
                    org_msg = msg,
                    proc_msg = modified_msg,
                    separate_msg = #separate_msg == 0 and "None" or table.concat(separate_msg, ","),
                    name_trans = name_trans_value,
                    msg_trans = "Yes",
                    trans_msg = ""
                }

                local send_msg = chat_id .. ":::" .. msg_type .. ":::" .. g.chat_ids[tostring(chat_id)].proc_msg ..
                                     ":::" .. g.chat_ids[tostring(chat_id)].separate_msg .. ":::" ..
                                     g.chat_ids[tostring(chat_id)].org_msg
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
    local name_file = io.open(g.recv_name, "r")
    if name_file then
        local found = false
        for line in name_file:lines() do
            local left_name, right_name = line:match("^(.-):::(.*)$")
            if left_name == clean_name then
                found = true
                return right_name
            end
        end
        name_file:close()

        if not found then
            if native_lang_is_translation(clean_name) then
                native_lang_not_found_name(clean_name)
            end
        end
    end
    return clean_name
end

function native_lang_not_found_name(str)
    local name_file = io.open(g.send_name, "r")
    local found = false

    if name_file then
        for line in name_file:lines() do
            local left_name, right_name = line:match("^(.-):::(.*)$")
            if left_name == str then
                found = true
                break
            end
        end
        name_file:close()
    end

    if not found then
        local append_file = io.open(g.send_name, "a") -- 追記モードで開く
        if append_file then
            append_file:write(str .. ":::" .. str .. "\n")
            append_file:flush() -- これはオプションですが、書き込みを確実にするために使います
            append_file:close()
        end
    end
end

function native_lang_name_trans()
    -- local frame = ui.GetFrame("chatframe")
    -- frame:Invalidate()
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

--[[function native_lang_gbox(output)
    local mainchatFrame = ui.GetFrame("chatframe")
    local frame = ui.GetFrame("tos_google_translate")
    local gbox = frame:CreateOrGetControl("groupbox", "gbox", 0, 0, frame:GetWidth(), frame:GetHeight())
    AUTO_CAST(gbox)
    gbox:SetLeftScroll(1)

    local ypos = 0
    local max_chat_id = nil -- 最大の chat_id を格納する変数

    g.ypos = 0

    -- 事前に最大の chat_id を算出
    for i, entry in ipairs(output) do
        local chat_id = tonumber(entry.chat_id)
        if chat_id and (max_chat_id == nil or chat_id > max_chat_id) then
            max_chat_id = chat_id
        end
    end

    for i, entry in ipairs(output) do
        local chat_id = entry.chat_id
        local name = entry.name
        local trans_text = entry.trans_text
        local msgtype = entry.msgtype
        local time = entry.time

        local clustername = "cluster_" .. chat_id
        local marginLeft = 20
        local marginRight = 0

        local commnderNameUIText = name .. " : " .. trans_text

        for i, extractedTexts in pairs(g.extractedTexts) do
            if chat_id == i then
                for j, extractedText in ipairs(extractedTexts) do
                    extractedText = remove_unwanted_braces(extractedText)

                    commnderNameUIText = commnderNameUIText .. extractedText
                end
            end
        end

        -- {img icon_item_GabijaEarring 30 30} の存在を確認
        local img_start, img_end = string.find(commnderNameUIText, "{img icon_item_GabijaEarring 30 30}")

        if img_start and img_end then
            -- すべての { の位置をリストアップ
            local positions = {}
            local current_pos = 1
            while true do
                local start_pos = string.find(commnderNameUIText, "{", current_pos, true)
                if not start_pos then
                    break
                end
                table.insert(positions, start_pos)
                current_pos = start_pos + 1
            end

            -- 後ろから3個目と2個目の { の位置を取得
            local third_last_pos = positions[#positions - 2]

            if third_last_pos then
                -- 後ろから3個目の { を ( に置き換え
                commnderNameUIText = string.sub(commnderNameUIText, 1, third_last_pos - 1) .. "" ..
                                         string.sub(commnderNameUIText, third_last_pos + 1)

            end
        end
        if g.settings.use == 2 then
            commnderNameUIText = commnderNameUIText .. "{#FF0000}_{/}"
        end

        commnderNameUIText = commnderNameUIText:gsub("{s18", "")
        commnderNameUIText = commnderNameUIText:gsub("}{a SLI", "{a SLI")
        commnderNameUIText = commnderNameUIText:gsub("{/}{/{", "{/}{/}{")
        -- print(commnderNameUIText)
        local msgFront = ""
        local fontStyle = nil
        if msgtype == "Normal" then
            fontStyle = mainchatFrame:GetUserConfig("TEXTCHAT_FONTSTYLE_NORMAL")
            msgFront = string.format("[%s]%s", ScpArgMsg("ChatType_1"), commnderNameUIText)
        elseif msgtype == "Shout" then
            fontStyle = mainchatFrame:GetUserConfig("TEXTCHAT_FONTSTYLE_SHOUT")
            msgFront = string.format("[%s]%s", ScpArgMsg("ChatType_2"), commnderNameUIText)
        elseif msgtype == "Party" then
            fontStyle = mainchatFrame:GetUserConfig("TEXTCHAT_FONTSTYLE_PARTY")
            msgFront = string.format("[%s]%s", ScpArgMsg("ChatType_3"), commnderNameUIText)
        elseif msgtype == "Guild" then
            fontStyle = mainchatFrame:GetUserConfig("TEXTCHAT_FONTSTYLE_GUILD")
            msgFront = string.format("[%s]%s", ScpArgMsg("ChatType_4"), commnderNameUIText)
        elseif msgtype == "System" then
            fontStyle = mainchatFrame:GetUserConfig("TEXTCHAT_FONTSTYLE_SYSTEM")
            msgFront = string.format("[%s]%s", ScpArgMsg("ChatType_7"), commnderNameUIText)
        end

        if g.settings.use == 1 then

            local chatCtrl = gbox:CreateOrGetControlSet('chatTextVer', clustername, ui.LEFT, ui.TOP, marginLeft, g.ypos,
                marginRight, 1)

            local label = chatCtrl:GetChild('bg')
            local txt = GET_CHILD(chatCtrl, "text")
            local timeCtrl = GET_CHILD(chatCtrl, "time")

            label:SetAlpha(0)

            local fontSize = GET_CHAT_FONT_SIZE()

            txt:SetTextByKey("font", fontStyle)
            txt:SetTextByKey("size", fontSize)
            txt:SetTextByKey("text", msgFront)
            timeCtrl:SetTextByKey("time", time)

            local offsetX = mainchatFrame:GetUserConfig("CTRLSET_OFFSETX")
            native_lang_chat_ctrl(gbox, chatCtrl, label, txt, timeCtrl, offsetX)

        elseif g.settings.use == 2 then
            local chatCtrl = GET_CHILD_RECURSIVELY(mainchatFrame, clustername)
            -- local chatCtrl = gbox:CreateOrGetControlSet('chatTextVer', clustername, ui.LEFT, ui.TOP, marginLeft, ypos,                marginRight, 1)
            if chatCtrl ~= nil then
                local groupboxname = chatCtrl:GetParent():GetName()
                local groupbox = GET_CHILD_RECURSIVELY(mainchatFrame, groupboxname)

                local label = chatCtrl:GetChild('bg')
                local txt = GET_CHILD(chatCtrl, "text")
                local timeCtrl = GET_CHILD(chatCtrl, "time")

                label:SetAlpha(0)

                local fontSize = GET_CHAT_FONT_SIZE()

                txt:SetTextByKey("font", fontStyle)
                txt:SetTextByKey("size", fontSize)
                txt:SetTextByKey("text", msgFront)
                timeCtrl:SetTextByKey("time", time)

                local offsetX = mainchatFrame:GetUserConfig("CTRLSET_OFFSETX")
                local chatWidth = groupbox:GetWidth()
                txt:SetTextMaxWidth(chatWidth - 100)
                txt:SetText(txt:GetText())
                label:Resize(chatWidth - offsetX, txt:GetHeight())
                chatCtrl:Resize(chatWidth, label:GetHeight())

                if chat_id == max_chat_id then
                    ypos = chatCtrl:GetY() + chatCtrl:GetHeight()
                    chatCtrl:SetOffset(marginLeft, ypos)
                end

                if groupbox:GetLineCount() == groupbox:GetCurLine() + groupbox:GetVisibleLineCount() then
                    groupbox:SetScrollPos(99999)
                end
            end

        end
    end

end]]
-- ui.Chat("/p 감자조와")
--[==[g.loaded = false

function native_lang_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame
    g.lastmsg = ""
    g.ypos = 0

    g.extractedTexts = g.extractedTexts or {} -- 抽出したテキストを格納するテーブル

    native_lang_load_settings()

    acutil.slashCommand("/tos_google_translate", native_lang_restart);
    acutil.slashCommand("/tgt", native_lang_restart);
    -- g.SetupHook(native_lang_REQ_TRANSLATE_TEXT, "REQ_TRANSLATE_TEXT")
    g.SetupHook(native_lang_SET_PARTYINFO_ITEM, "SET_PARTYINFO_ITEM")
    -- g.SetupHook(native_lang_CHAT_TAB_BTN_CLICK, "CHAT_TAB_BTN_CLICK")
    g.SetupHook(native_lang_DAMAGE_METER_GAUGE_SET, "DAMAGE_METER_GAUGE_SET")
    addon:RegisterMsg("GAME_START", "native_lang_koja");
    addon:RegisterMsg("GAME_START_3SEC", "native_lang_name_trans");

end

function native_lang_koja()

    local pattern = "^[a-zA-Z0-9%-_@#%$%%&%*]+$"

    if _G['ADDONS'] and _G['ADDONS']['TOUKIBI'] and _G['ADDONS']['TOUKIBI']['KoJa_Name_Translater'] and
        _G['ADDONS']['TOUKIBI']['KoJa_Name_Translater'].Switch_NamePlate then

        local dataFileLoc = "../addons/koja_name_translater/MemoriseData.dat"
        local updatedLines = {}
        local seenKeys = {}

        -- ファイルを読み込む
        local file = io.open(dataFileLoc, "r")
        if file then
            for line in file:lines() do
                local key, value = line:match("^(.-)\t(.-)$")
                if key and value then
                    -- キーが重複している場合、その行をスキップ
                    if seenKeys[key] then
                        -- print("重複したキーをスキップ: " .. key)
                    else
                        -- キーを追跡し、条件に基づいて値を更新
                        seenKeys[key] = true
                        if g.names[key] then
                            value = g.names[key]
                        end
                        -- パターンに一致する場合、右側の値をキーで上書き
                        if key:match(pattern) then
                            value = key
                        end
                        table.insert(updatedLines, key .. "\t" .. value)
                    end
                else
                    table.insert(updatedLines, line)
                end
            end
            file:close()

            -- ファイルに書き戻す
            file = io.open(dataFileLoc, "w")
            if file then
                for _, updatedLine in ipairs(updatedLines) do
                    file:write(updatedLine .. "\n")
                end
                file:close()
            else
                -- print("ファイルの書き込みに失敗しました。")
            end
        else
            -- print("ファイルを開くことができませんでした。")
        end

    end
end

function native_lang_DAMAGE_METER_GAUGE_SET(ctrl, leftStr, point, rightStr, skin)
    local leftText = GET_CHILD_RECURSIVELY(ctrl, 'leftText')

    local brackets_content = {}

    for content in leftStr:gmatch("{(.-)}") do
        table.insert(brackets_content, content)
    end

    local name_only = leftStr:gsub("{.-}", "")

    name_only = name_only:match("^%s*(.-)%s*$")

    local translated_name = g.names[name_only] or name_only

    local new_str = ""
    for _, content in ipairs(brackets_content) do
        new_str = new_str .. "{" .. content .. "}"
    end
    new_str = new_str .. translated_name

    leftText:SetTextByKey('value', new_str)

    local rightText = GET_CHILD_RECURSIVELY(ctrl, 'rightText')
    rightText:SetTextByKey('value', rightStr)

    local gauge = GET_CHILD_RECURSIVELY(ctrl, 'gauge')
    gauge:SetPoint(point, 100)
    gauge:SetSkinName(skin)
end
function native_lang_CHAT_TAB_BTN_CLICK(parent, ctrl)
    if g.settings.use ~= 0 then

        ui.SysMsg(native_lang_lang("Tos Google Translate must be stopped before switching."))
        return
    end
    local name = ctrl:GetName()
    if string.find(name, "_pic") ~= nil then
        ctrl:ShowWindow(0)
    else
        local pic = GET_CHILD_RECURSIVELY(parent, name .. "_pic")
        pic:ShowWindow(1)
    end

    local frame = parent:GetTopParentFrame()
    CHAT_TAB_OPTION_SAVE(frame)
end

function native_lang_name_trans()
    local temp_names = {}

    local selectedObjects, selectedObjectsCount = SelectObject(GetMyPCObject(), 1000, "ALL")
    for i = 1, selectedObjectsCount do

        local handle = GetHandle(selectedObjects[i])
        if handle ~= nil then

            if info.IsPC(handle) == 1 then

                local strHandle = tostring(handle)
                local FrameName = "charbaseinfo1_" .. strHandle
                local pcTxtFrame = ui.GetFrame(FrameName)
                if pcTxtFrame ~= nil then

                    local frameFamilyName = pcTxtFrame:GetChild("familyName")
                    if frameFamilyName ~= nil then

                        local familyName = frameFamilyName:GetText()

                        local cleanName = familyName:gsub("{.-}", ""):match("^%s*(.-)%s*$")

                        if g.names[cleanName] == nil then
                            -- print(tostring(cleanName))
                            table.insert(temp_names, cleanName)
                        end
                    end
                end

            end
        end
    end

    -- temp_namesをtempname.datに書き込む
    local tempnameFileLoc = string.format('../addons/%s/%s/tempname.dat', addonNameLower, addonNameLower)
    local file = io.open(tempnameFileLoc, "w")
    if file then
        local lang = g.settings.lang
        for _, name in ipairs(temp_names) do
            file:write(name .. " : " .. lang .. "\n")
        end
        file:close()
        g.tempname_tame = 1
    else
        -- print("tempname.datファイルの作成に失敗しました。")
    end
end

function native_lang_REQ_TRANSLATE_TEXT(frameName, gbName, ctrlName)
    local frame = ui.GetFrame(frameName)
    local gb = GET_CHILD_RECURSIVELY(frame, gbName)
    if frame == nil or gb == nil then
        return
    end

    if GET_PRIVATE_CHANNEL_ACTIVE_STATE() == false then
        return
    end

    local size = session.ui.GetMsgInfoSize(gbName)
    local cutting_table = SCR_STRING_CUT(ctrlName, '_')
    local MsgId = cutting_table[#cutting_table]
    local gb_index = -1;
    local pc = GetMyPCObject();
    local curr_lang_code = item_etc_shared.get_language_translate_code()

    if pc == nil then
        return
    end
    local inputStr = ""
    for i = 0, size - 1 do
        local clusterinfo = session.ui.GetChatMsgInfo(gbName, i)
        if clusterinfo == nil then
            return 0
        end
        if tostring(MsgId) == clusterinfo:GetMsgInfoID() then
            inputStr = clusterinfo:GetMsg()
            if pc.Name == clusterinfo:GetCommanderName() then
                ui.SysMsg(ClMsg('CanNotTranslateMyChat'))
                return
            end
            if string.len(inputStr) > MAX_CHAT_LEN_TRANSLATE then
                ui.SysMsg(ClMsg('TooLongTextToTranslate'))
                return
            end

            local isLinkItemTxt, replacedText = item_etc_shared.Is_Contain_LinkItem(inputStr)
            if isLinkItemTxt == true then
                ui.SysMsg(ClMsg('CannotTlsWithLinkItemText'))
                return
            end

            gb_index = i
            if "" ~= clusterinfo:GetTranslateMsg() then
                ui.SysMsg(ClMsg('AleadyTranslated'))
                return
            end
            local langCode = clusterinfo:GetLanguageCode()
            if curr_lang_code == langCode and langCode == "None" then
                ui.SysMsg(ClMsg('SrcAndTgtIsSame'))
                return
            end

            if replacedText ~= nil then
                item_etc_shared.SavePartyLinkFormat(inputStr)
            end
        end
    end
    if g.settings.use == 0 then
        if gb_index >= 0 then
            ui.ReqTranslateChat(frameName, gbName, gb_index, curr_lang_code)
        end
    else
        ui.SysMsg(native_lang_lang("Tos Google Translate must be stopped before translating."))
        return
    end
end

function native_lang_lang(str)
    -- "Tos Google Translate frame must be closed to switch."
    local langCode = option.GetCurrentCountry()
    if langCode == "Japanese" then

        if str == "Tos Google Translate must be stopped before switching." then
            str = "Tos Google Translate を停止してから切り替えしてください。"
        end

        if str == "Left click:Setting menu display" then
            str = "左クリック：設定メニュー表示。"
        end

        if str == "[Tos Google Translate]{nl}" ..
            "/addons/tos_google_translate/tos_google_translate/tos_google_translate.exe{nl}" .. "cannot be found. Exit." then
            str = "[Tos Google Translate]{nl}" ..
                      "/addons/tos_google_translate/tos_google_translate/tos_google_translate.exe{nl}" ..
                      "が見つけられません。終了します。"
        end

        if str == "Tos Google Translate must be stopped before translating." then
            str = "Tos Google Translate を停止してから翻訳してください。"
        end

        if str == "Tos Google Translate initialize. Please return to the barracks." then
            str = "Tos Google Translate 初期化します。一度バラックに戻ってください。"
        end
        return str
    elseif langCode == "kr" then

        if str == "Tos Google Translate must be stopped before switching." then
            str = "Tos Google Translate를 중지한 후 전환해 주세요."
        end

        if str == "Left click:Setting menu display" then
            str = "왼쪽 클릭: 설정 메뉴 표시"
        end

        if str == "[Tos Google Translate]{nl}" ..
            "/addons/tos_google_translate/tos_google_translate/tos_google_translate.exe{nl}" .. "cannot be found. Exit." then
            str = "[Tos Google Translate]{nl}" ..
                      "/addons/tos_google_translate/tos_google_translate/tos_google_translate/tos_google_translate.exe{nl}" ..
                      "를 찾을 수 없습니다. 종료합니다."
        end

        if str == "Tos Google Translate must be stopped before translating." then
            str = "Tos Google Translate를 중지한 후 번역해 주세요."
        end
        if str == "Tos Google Translate initialize. Please return to the barracks." then
            str = "Tos Google Translate 초기화합니다. 일단 막사로 돌아가십시오."
        end
        return str
    else
        return str
    end

end

function native_lang_extractAndCleanText(text, id)

    local front = string.find(text, "{") -- マッチした文字列の直前の位置を取得
    while front do
        local back = string.find(text, "}", front) + 1 -- マッチした文字列の直後の位置を取得し、追加の5文字分を加える
        local extractedText = string.sub(text, front, back - 1) -- マッチした部分の文字列を抽出
        g.extractedTexts[id] = g.extractedTexts[id] or {} -- 新しいテーブルを作成するか既存のテーブルを取得する
        table.insert(g.extractedTexts[id], extractedText)
        text = string.sub(text, 1, front - 1) .. string.sub(text, back) -- 不要な部分を削除した文字列を更新
        front = string.find(text, "{") -- 次のマッチを探す
    end

    --[[for i, extractedTexts in pairs(g.extractedTexts) do
        for j, extractedText in ipairs(extractedTexts) do
            print("抽出したテキスト[" .. i .. "][" .. j .. "]:" .. extractedText)
        end
    end]]

    return text, g.extractedTexts -- 抽出したテキストを含むテーブルを返す
end

function native_lang_ReplaceMSG(MSG)

    MSG = MSG:gsub("　", " ")
    MSG = MSG:gsub("%s+", " ")

    local replacements = {
        ["바이보라"] = "バイボラ",
        ["고양이젤리"] = "猫ゼリー",
        ["병아리"] = "ひよこ",
        ["전설"] = "伝説",
        ["마신"] = "魔神",
        ["오레오"] = "オレオ",
        ["비나리"] = "ビナリ",
        ["백두산"] = "白頭山",
        ["성역왕"] = "聖域王",
        ["티타임"] = "ティータイム",
        ["마신의 성소"] = "魔神の聖域",
        ["숨겨진 통로"] = "隠し通路",
        ["클라페다"] = "クラペダ",
        ["오르샤"] = "オルシャ",
        ["페디미안"] = "フェディミアン",
        ["바우바스 카드"] = "バウバスカード",
        -- 바우바스 카드

        ["%[라다%] 포텐티아"] = "[ラダ]ポテンティア",
        ["%[라다%] 템서스 플랑베르쥬"] = "[ラダ]タムサスフランベルジェ",
        ["%[라다%] 디델 콜로서스"] = "[ラダ]ディデルコロッサス",
        ["%[라다%] 멜리나스 스태프"] = "[ラダ]メリナススタッフ",
        ["%[라다%] 마기 스태프"] = "[ラダ]マギスタッフ",
        ["%[라다%] 루다스 스태프"] = "[ラダ]ルーダススタッフ",
        ["%[라다%] 파이브 해머"] = "[ラダ]フィフスハンマー",
        ["%[라다%] 스파이크 메이스"] = "[ラダ]スパイクメイス",
        ["%[라다%] 실드 브레이커"] = "[ラダ]シールドブレーカー",
        ["%[라다%] 블랙 우든 실드"] = "[ラダ]ブラックウッドシールド",
        ["%[라다%] 오크 실드"] = "[ラダ]オークシールド",
        ["%[라다%] 새비지 실드"] = "[ラダ]サベージシールド",
        ["%[라다%] 시커"] = "[ラダ]シーカー",
        ["%[라다%] 아이언 보우"] = "[ラダ]アイアンボウ",
        ["%[라다%] 호크 보우"] = "[ラ다]ホークボウ",
        ["%[라다%] 아이스 로드"] = "[ラダ]アイスロッド",
        ["%[라다%] 파이어 로드"] = "[ラダ]ファイアロッド",
        ["%[라다%] 바시아 로드"] = "[ラダ]バシアロッド",
        ["%[라다%] 매직 로드"] = "[ラダ]マジックロッド",
        ["%[라다%] 플로나스 사브르"] = "[ラダ]フロナスサーベル",
        ["%[라다%] 골든 폴쳔"] = "[ラダ]ゴールデンファルシオン",
        ["%[라다%] 스틸 폴쳔"] = "[ラダ]スチールファルシオン",
        ["%[라다%] 실버 폴쳔"] = "[ラダ]シルバーファルシオン",
        ["%[라다%] 테넷 체인 메일"] = "[ラダ]ターネットチェーンメイル",
        ["%[라다%] 인섹트 메일"] = "[ラダ]インセクトメイル",
        ["%[라다%] 라이트 플레이트 아머"] = "[ラダ]ライトプレートアーマー",
        ["%[라다%] 프로바 로브"] = "[ラダ]プロバローブ",
        ["%[라다%] 마그누스 로브"] = "[ラダ]マグナスローブ",
        ["%[라다%] 디오 로브"] = "[ラダ]ディオローブ",
        ["%[라다%] 트레시 로브"] = "[ラダ]トレシーローブ",
        ["%[라다%] 크림슨 레더 아머"] = "[ラダ]クリムソンレザーアーマー",
        ["%[라다%] 실버 플레이트 아머"] = "[ラダ]シルバープレートアーマー",
        ["%[라다%] 그리나스 로드"] = "[ラダ]グリナスロッド",
        ["%[라다%] 케미니스 로드"] = "[ラダ]ケミニスロッド",
        ["%[라다%] 아크 로드"] = "[ラダ]アークロッド",
        ["%[라다%] 스트링 네클리스"] = "[ラダ]ストリングネックレス",
        ["%[라다%] 판토 탈리스만"] = "[ラダ]パントタリスマン",
        ["%[라다%] 파이라이트 팬던트"] = "[ラダ]パイライトペンダント",
        ["%[라다%] 크리오라이트 팬던트"] = "[ラダ]クリオライトペンダント",
        ["%[라다%] 매직 탈리스만"] = "[ラダ]マジックタリスマン",
        ["%[라다%] 스트랭스 팬던트"] = "[ラダ]ストレングスペンダント",
        ["%[라다%] 레더 뱅글"] = "[ラダ]レザーバングル",
        ["%[라다%] 라이트 로네사 뱅글"] = "[ラダ]ライトロネッサバングル",
        ["%[라다%] 슈페리어 로네사 뱅글"] = "[ラダ]スーペリアロネッサバングル",
        ["%[라다%] 로네사 링 브레이슬릿"] = "[ラダ]ロネッサリングブレスレット",
        ["%[라다%] 로네사 노블 브레이슬릿"] = "[ラダ]ロネッサノーブルブレスレット",
        ["%[라다%] 아이언 뱅글"] = "[ラダ]アイアンバングル",
        ["%[라다%] 파이루마 체인"] = "[ラダ]パイルマチェーン",
        ["%[라다%] 아이스마 체인"] = "[ラダ]アイスマチェーン",
        ["%[라다%] 포이즈마 체인"] = "[ラダ]ポイズマチェーン",
        ["%[라다%] 크리스탈 뱅글"] = "[ラダ]クリスタルバングル",
        ["%[라다%] 샤인 브레이슬릿"] = "[ラダ]シャインブレスレット",
        ["%[라다%] 배틀 브레이슬릿"] = "[ラダ]バトルブレスレット",
        ["%[유라테%] 콜렉투르"] = "[ユラテ] コレクトゥール",
        ["%[유라테%] 호그마 그레이트 소드"] = "[ユラテ] ホグマグレートソード",
        ["%[유라테%] 케미니스 바스타드 소드"] = "[ユラテ] ケミニスバスタードソード",
        ["%[유라테%] 살타스 스태프"] = "[ユラテ] サルタススタッフ",
        ["%[유라테%] 케미니스 스태프"] = "[ユラテ] ケミニススタッフ",
        ["%[유라테%] 카르스토 스태프"] = "[ユラテ] カーストースタッフ",
        ["%[유라테%] 스컬 크래셔"] = "[ユラテ] スカルクラッシャー",
        ["%[유라테%] 케미니스 마울"] = "[ユラテ] ケミニスマウル",
        ["%[유라테%] 마우로스 클럽"] = "[ユラテ] マウロスクラブ",
        ["%[유라테%] 잘리아 카이트 실드"] = "[ユラテ] ザリアカイトシールド",
        ["%[유라테%] 슈페리어 카이트 실드"] = "[ユラテ] スーペリアカイトシールド",
        ["%[유라테%] 비드 실드"] = "[ユラテ] ビードシールド",
        ["%[유라테%] 케미니스 보우"] = "[ユラテ] ケミニスボウ",
        ["%[유라테%] 헌팅 보우"] = "[ユラテ] ハンティングボウ",
        ["%[유라테%] 메이커 보우"] = "[ユラテ] メーカーボウ",
        ["%[유라테%] 임페르니 로드"] = "[ユラテ] インフェルニーロッド",
        ["%[유라테%] 엑스펙타 스태프"] = "[ユラテ] エクスペクタースタッフ",
        ["%[유라테%] 병사의 롱 로드"] = "[ユラテ] 兵士のロングロッド",
        ["%[유라테%] 스미스 로드"] = "[ユラテ] スミスロッド",
        ["%[유라테%] 블랙 스태프"] = "[ユラテ] ブラックスタッフ",
        ["%[유라테%] 클라비스 로드"] = "[ユラテ] クラビスロッド",
        ["%[유라테%] 만드라픽"] = "[ユラテ] マンドラゴラピック",
        ["%[유라테%] 위저드 블레이드"] = "[ユラテ] ウィザードブレード",
        ["%[유라테%] 프리마루체"] = "[ユラテ] プリマルーチェ",
        ["%[유라테%] 케미니스 소드"] = "[ユラテ] ケミニスソード",
        ["%[유라테%] 아우스타스"] = "[ユラテ] アウスタス",
        ["%[유라테%] 킨드잘"] = "[ユラテ] キンジャール",
        ["%[유라테%] 스터디드 아머"] = "[ユラテ] スタッドアーマー",
        ["%[유라테%] 레드 베리스 튜닉"] = "[ユラテ] レッドヴェリスチュニック",
        ["%[유라테%] 포쿠본 레더 아머"] = "[ユラテ] ポクブーレザーアーマー",
        ["%[유라테%] 드레이크 레더 튜닉"] = "[ユラテ] ドレイクレザーチュニック",
        ["%[유라테%] 추종자의 레더 아머"] = "[ユラテ] 追従者のレザーアーマー",
        ["%[유라테%] 머미가스트 메일"] = "[ユラテ] マミーガストメイル",
        ["%[유라테%] 카프리선 아머"] = "[ユラテ] カフリサンアーマー",
        ["%[유라테%] 디오 레더 아머"] = "[ユラテ] ディオレザーアーマー",
        ["%[유라테%] 디오 체인 메일"] = "[ユラテ] ディオチェーンメイル",
        ["%[유라테%] 디오 로드"] = "[ユラテ] ディオロッド",
        ["%[유라테%] 트레시 로드"] = "[ユラテ] トレシーロッド",
        ["%[유라테%] 세스타스 로드"] = "[ユラテ] セスタスロッド",
        ["%[유라테%] 라이트나 체인"] = "[ユラテ] ライトナチェーン",
        ["%[유라테%] 헬스 스톤"] = "[ユラテ] ヘルスストーン",
        ["%[유라테%] 워리어 팬던트"] = "[ユラテ] ウォリアーペンダント",
        ["%[유라테%] 사이클롭스 아이"] = "[ユラテ] サイクロプスアイ",
        ["%[유라테%] 본 네클리스"] = "[ユラテ] ボーンネックレス",
        ["%[유라테%] 카너버 네클리스"] = "[ユラテ] カーニヴォアネックレス",
        ["%[유라테%] 헬스 슈페리어 뱅글"] = "[ユラテ] ヘルススーペリアバングル",
        ["%[유라테%] 마기 슈페리어 뱅글"] = "[ユラテ] マギスーペリアバングル",
        ["%[유라테%] 어큐러시 슈페리어 뱅글"] = "[ユラテ] アキュラシースーペリアバングル",
        ["%[유라테%] 라이트 슈페리어 뱅글"] = "[ユラテ] ライトスーペリアバングル",
        ["%[유라테%] 라이트 아이언 뱅글"] = "[ユラテ] ライトアイアンバングル",
        ["%[유라테%] 로네사 클라페다 브레이슬릿"] = "[ユラテ] ロネッサクラペダブレスレット",
        ["%[유라테%] 케파 팬던트"] = "[ユラテ] ケッピーペンダント",
        ["%[유라테%] 포 마인 네클리스"] = "[ユラテ] フォーマインネックレス",
        ["%[유라테%] 네밸랫 네클리스"] = "[ユラテ] ネバレットネックレス",
        ["%[유라테%] 우든 뱅글"] = "[ユラテ] ウッドバングル",
        ["%[유라테%] 부베 뱅글"] = "[ユラテ] ゴブリンバングル",
        ["%[유라테%] 슈페리어 뱅글"] = "[ユラテ] スーペリアバングル"
    }

    for k, v in pairs(replacements) do
        MSG = MSG:gsub(k, v)
    end

    return MSG

end

function native_lang_DRAW_CHAT_MSG(frame, msg)

    if g.settings.use == 0 then
        return
    end

    local groupboxname, startindex, chatframe = acutil.getEventArgs(msg);

    if chatframe == nil then

        return;
    end
    local size = session.ui.GetMsgInfoSize(groupboxname)
    local chat = session.ui.GetChatMsgInfo(groupboxname, size - 1)
    local chat_id = 0

    for i = startindex, size - 1 do
        local clusterinfo = session.ui.GetChatMsgInfo(groupboxname, i)
        local clustername = "cluster_" .. clusterinfo:GetMsgInfoID()
        local cluster = GET_CHILD_RECURSIVELY(chatframe, clustername)
        if cluster:IsVisible() == 1 then
            chat_id = clusterinfo:GetMsgInfoID()
            break
        end
    end
    -- print(tostring(chat:GetMsgType()) .. ":" .. tostring(chat:GetMsg()))
    if string.find(chat:GetMsg(), "{spine ") then
        return
    end
    local MsgType = chat:GetMsgType()
    local msgFront = ""
    local fontStyle = nil
    if MsgType == "System" or MsgType == "guildmem" then
        local mainchatFrame = ui.GetFrame("chatframe")
        fontStyle = mainchatFrame:GetUserConfig("TEXTCHAT_FONTSTYLE_SYSTEM")

        local langCode = option.GetCurrentCountry()
        if langCode == "Japanese" then
            local MSG = chat:GetMsg()
            MSG = native_lang_ReplaceMSG(MSG)

            -- print(tostring(MSG))
            local clustername = "cluster_" .. chat_id
            local chatCtrl = GET_CHILD_RECURSIVELY(mainchatFrame, clustername)

            if chatCtrl ~= nil then

                fontStyle = mainchatFrame:GetUserConfig("TEXTCHAT_FONTSTYLE_SYSTEM")
                if MsgType == "guildmem" then
                    -- msgFront = "#A566FF"
                    msgFront = string.format("%s", "{#A566FF}" .. MSG)
                elseif MsgType == "System" then
                    msgFront = string.format("[%s]%s", ScpArgMsg("ChatType_7"), MSG)
                end
                local txt = GET_CHILD(chatCtrl, "text")
                local fontSize = GET_CHAT_FONT_SIZE()
                txt:SetTextByKey("font", fontStyle)
                txt:SetTextByKey("size", fontSize)
                txt:SetTextByKey("text", msgFront)

            end
            -- end
        end

    end

    if MsgType ~= "Normal" and MsgType ~= "Shout" and MsgType ~= "Party" and MsgType ~= "Guild" then

        return

    end

    local frame = ui.GetFrame("chatframe")
    local index = tonumber(frame:GetUserValue("BTN_INDEX")) + 1

    local optionframe = ui.GetFrame("chat_option")
    local tabgbox = GET_CHILD_RECURSIVELY(optionframe, "tabgbox" .. index)
    local btn_general_pic = GET_CHILD_RECURSIVELY(tabgbox, "btn_general_pic")
    local btn_shout_pic = GET_CHILD_RECURSIVELY(tabgbox, "btn_shout_pic")
    local btn_party_pic = GET_CHILD_RECURSIVELY(tabgbox, "btn_party_pic")
    local btn_guild_pic = GET_CHILD_RECURSIVELY(tabgbox, "btn_guild_pic")

    if btn_general_pic:IsVisible() == 0 and MsgType == "Normal" then
        return
    end

    if btn_shout_pic:IsVisible() == 0 and MsgType == "Shout" then
        return
    end

    if btn_party_pic:IsVisible() == 0 and MsgType == "Party" then

        return
    end

    if btn_guild_pic:IsVisible() == 0 and MsgType == "Guild" then
        return
    end

    local cmdName = chat:GetCommanderName();
    local tempMsg = chat:GetMsg();

    local lastmsg = cmdName .. ":" .. tempMsg
    if g.lastmsg == lastmsg then

        return
    else

        g.lastmsg = lastmsg
    end

    for i = startindex, size - 1 do
        local clusterinfo = session.ui.GetChatMsgInfo(groupboxname, i)

        -- local chat_id = chat:GetMsgInfoID();
        -- print(chat_id)
        local color = "#FFFF00"
        local pattern = "(@dicID)"
        local modifiedString = tempMsg:gsub(pattern, "{%1"):gsub("%$%*%^", "%1}")

        local startIndex, endIndex = string.find(modifiedString, "{img link_party 24 24}")
        if startIndex and endIndex then

            modifiedString = modifiedString:sub(1, endIndex) .. "{" .. modifiedString:sub(endIndex + 1)

            local substring = modifiedString:sub(endIndex + 1) -- {img link_party 24 24} の後ろの文字列を取得
            local nextIndex = string.find(substring, "{%/%}{%/%}") -- 次の {/}{/} の位置を取得
            if nextIndex then

                modifiedString = modifiedString:sub(1, endIndex + nextIndex - 1) .. "}" ..
                                     modifiedString:sub(endIndex + nextIndex)

            end

        end
        modifiedString = modifiedString:gsub("{#0000FF}", "{#FFFF00}")
        modifiedString = string.gsub(modifiedString, "%(", "{")
        modifiedString = string.gsub(modifiedString, "%)", "")

        local cleanedText, extractedTexts = native_lang_extractAndCleanText(modifiedString, chat_id)
        -- print(cleanedText)
        local time = chat:GetTimeStr()
        cmdName = chat:GetCommanderName();
        -- local input = "あじのり [W サーバー]"
        cmdName = cmdName:gsub("%[.*%]", ""):gsub("^%s*(.-)%s*$", "%1")

        local function replace_special_chars(text)
            -- 特殊文字を含むリスト
            local patterns = {","}

            -- 各パターンに対して、連続する文字を置き換える
            for _, pattern in ipairs(patterns) do
                -- パターンが一つ以上連続する部分を置き換える
                text = text:gsub(pattern .. "+", " ")
            end

            return text
        end

        -- cleanedTextの置き換え処理
        cleanedText = replace_special_chars(cleanedText)
        -- print(tempMsg)
        local new_entry = string.format(
            '{"chat_id":"%s","msgtype":"%s","trans_text":"%s","time":"%s","name":"%s","lang":"%s"}', tostring(chat_id),
            MsgType, cleanedText, time, cmdName, g.settings.lang)

        local send_file = io.open(g.sendFileLoc, "r")
        local content = ""

        if send_file then
            content = send_file:read("*all")
            send_file:close()
        end

        if content == "" then
            -- ファイルが空または存在しない場合、新しいエントリだけを追加
            send_file = io.open(g.sendFileLoc, "w")
            send_file:write("[" .. new_entry .. "]")
        else
            -- ファイルが存在する場合、新しいエントリを追加
            -- 既存の内容が '[]' だけの場合を考慮
            if content == "[]" then
                content = "[" .. new_entry .. "]"
            else
                content = content:sub(1, -2) -- 最後の"]"を削除
                content = content .. "," .. new_entry .. "]"
            end
            send_file = io.open(g.sendFileLoc, "w")
            send_file:write(content)
        end

        send_file:close()
        local file = io.open(g.noticeFileLoc, "r")
        g.size = 0
        if file then
            for _ in file:lines() do
                g.size = g.size + 1
            end
            file:close()
        end

        -- local frame = ui.GetFrame("tos_google_translate")
        -- frame:RunUpdateScript("native_lang_receive", 1)
    end

end

function native_lang_receive()

    if g.settings.use == 0 then
        return 0
    end
    local tempnameFileLoc = string.format('../addons/%s/%s/tempname.dat', addonNameLower, addonNameLower)
    local file = io.open(tempnameFileLoc, "r")
    if not file then
        if g.tempname_tame == 1 then
            native_lang_load_names_table()
            g.tempname_tame = 0
        end
    else
        file:close() -- ファイルを閉じる
    end

    local file = io.open(g.noticeFileLoc, "r")
    local size = 0

    if file then
        for _ in file:lines() do
            size = size + 1
        end
        file:close()
    end

    local check = 0
    if g.size == nil then
        g.size = 0
    end
    if g.size ~= size then
        check = 1
        g.size = g.size + 1
        -- return
    end

    local output = {}

    if check == 1 then
        check = 0
        local file = io.open(g.noticeFileLoc, "r")
        if file then
            -- ファイルの内容を1行ずつ読み込む

            for line in file:lines() do
                local chat_id, org_name, trans_text, msgtype, time = line:match(
                    '^"(.-)"%s*:%s*"(.-)"%s*:%s*"(.-)"%s*:%s*"(.-)"%s*:%s*"(.-)"$')
                if chat_id and org_name and trans_text and msgtype and time then
                    -- g.output にインサート
                    table.insert(output, {
                        chat_id = chat_id,
                        name = org_name,
                        trans_text = trans_text,
                        msgtype = msgtype,
                        time = time
                    })
                end

            end
            file:close()

            -- g.output に格納

        end
        native_lang_gbox(output)
        --[[local tgtframe = ui.GetFrame("tos_google_translate")
        local groupbox = GET_CHILD(tgtframe, "gbox")
        g.curLine = groupbox:GetCurLine()]]

        return
    else
        return
    end
end

function native_lang_context()
    local context = ui.CreateContextMenu("native_lang_context", "Tos Google Translate", 0, 0, 200, 0)
    local strScp = string.format("native_lang_restart()")
    ui.AddContextMenuItem(context, "Restart", strScp)
    strScp = string.format("native_lang_replacement()")
    ui.AddContextMenuItem(context, "Replace Mode", strScp)
    strScp = string.format("native_lang_frame_open()")
    ui.AddContextMenuItem(context, "Frame Open & Start", strScp)
    strScp = string.format("native_lang_frame_close()")
    ui.AddContextMenuItem(context, "Frame Close & Stop", strScp)
    ui.OpenContextMenu(context)
end

function native_lang_restart()
    ui.SysMsg(native_lang_lang("Tos Google Translate initialize. Please return to the barracks."))
    local frame = ui.GetFrame("tos_google_translate")

    local file = io.open(g.restartFileLoc, "w")
    file:write("restart")
    file:close()

    -- g.extractedTexts = {}

    g.loaded = false
    g.size = 0
    frame:RemoveAllChild()
    native_lang_frame_init()
    local file = io.open(g.noticeFileLoc, "w")
    if file then
        file:write("")
        file:close()
    end

end

function native_lang_replacement()

    g.settings.use = 2
    native_lang_save_settings()
    local frame = ui.GetFrame("tos_google_translate")

    frame:ShowWindow(0)

    native_lang_frame_init()

end

function native_lang_frame_open()

    g.settings.use = 1

    native_lang_frame_init()

    native_lang_save_settings()
end

function native_lang_frame_close()
    local frame = ui.GetFrame("tos_google_translate")
    frame:ShowWindow(0)

    g.settings.use = 0
    native_lang_save_settings()

    native_lang_frame_init()

end

function native_lang_frame_init(frame, ctrl, argStr, argNum)

    acutil.setupEvent(g.addon, "DRAW_CHAT_MSG", "native_lang_DRAW_CHAT_MSG");
    g.addon:RegisterMsg("FPS_UPDATE", "native_lang_receive");
    local chatframe = ui.GetFrame("chatframe")
    local tabgbox = GET_CHILD_RECURSIVELY(chatframe, "tabgbox")
    local trans = tabgbox:CreateOrGetControl("button", "trans", 270, -3, 30, 30)
    AUTO_CAST(trans)
    if g.settings.use == 0 then
        trans:SetSkinName('test_gray_button')
        trans:SetTextTooltip("[Tos Google Translate]{nl}" .. "Translation mode off{nl}" ..
                                 native_lang_lang("Left click:Setting menu display"))
    elseif g.settings.use == 1 then
        trans:SetSkinName("test_red_button")
        trans:SetTextTooltip("[Tos Google Translate]{nl}" .. "Translation mode on{nl}" ..
                                 native_lang_lang("Left click:Setting menu display"))
    elseif g.settings.use == 2 then
        trans:SetSkinName("baseyellow_btn")
        trans:SetTextTooltip("[Tos Google Translate]{nl}" .. "Replace mode in operation.{nl}" ..
                                 native_lang_lang("Left click:Setting menu display"))
    end

    trans:SetText("{ol}{s14}{#FFFFFF}" .. g.settings["lang"])
    -- trans:SetEventScript(ui.LBUTTONUP, "native_lang_frame_open")
    trans:SetEventScript(ui.LBUTTONUP, "native_lang_context")
    -- trans:SetEventScript(ui.RBUTTONUP, "native_lang_restart")

    local chatframeWidth, chatframeHeight = chatframe:GetWidth(), chatframe:GetHeight()

    if g.settings.use == 1 then
        local frame = ui.GetFrame("tos_google_translate")
        frame:SetSkinName("chat_window_2")
        frame:SetTitleBarSkin("None")
        frame:SetLayerLevel(49);
        frame:Resize(chatframeWidth, chatframeHeight) -- 幅は chatframe と同じに設定

        local clientWidth, clientHeight = option.GetClientWidth(), option.GetClientHeight()
        local frameY = clientHeight - chatframeHeight

        frame:SetPos(0, frameY - 80)
        frame:RemoveAllChild();
        frame:ShowWindow(1)

        local output = {}
        local file = io.open(g.noticeFileLoc, "r")
        if file then

            for line in file:lines() do
                local chat_id, org_name, trans_text, msgtype, time = line:match(
                    '^"(.-)"%s*:%s*"(.-)"%s*:%s*"(.-)"%s*:%s*"(.-)"%s*:%s*"(.-)"$')
                if chat_id and org_name and trans_text and msgtype and time then

                    table.insert(output, {
                        chat_id = chat_id,
                        name = org_name,
                        trans_text = trans_text,
                        msgtype = msgtype,
                        time = time
                    })
                end

            end
            file:close()

        end
        native_lang_gbox(output)

    elseif g.settings.use == 2 then
        local output = {}
        local file = io.open(g.noticeFileLoc, "r")
        if file then

            for line in file:lines() do
                local chat_id, org_name, trans_text, msgtype, time = line:match(
                    '^"(.-)"%s*:%s*"(.-)"%s*:%s*"(.-)"%s*:%s*"(.-)"%s*:%s*"(.-)"$')
                if chat_id and org_name and trans_text and msgtype and time then
                    -- g.output にインサート
                    table.insert(output, {
                        chat_id = chat_id,
                        name = org_name,
                        trans_text = trans_text,
                        msgtype = msgtype,
                        time = time
                    })
                end

            end
            file:close()

        end
        native_lang_gbox(output)
    else
        return
    end

end

local function remove_unwanted_braces(input_str)
    local result = ""
    local i = 1
    while i <= #input_str do
        local char = input_str:sub(i, i)
        if char == "{" then
            local substr = input_str:sub(i)
            if substr:match("^%{a ") or substr:match("^%{%#") or substr:match("^%{img ") or substr:match("^%{%/") then
                -- 指定された形式に一致する場合、そのままコピー
                local end_index = substr:find("}") or #input_str
                result = result .. substr:sub(1, end_index)
                i = i + end_index
            else
                -- 指定された形式に一致しない場合、{}を削除
                local end_index = substr:find("}") or #input_str
                result = result .. substr:sub(2, end_index - 1)
                i = i + end_index
            end
        else
            result = result .. char
            i = i + 1
        end
    end

    return result
end



function native_lang_get_curline()
    local frame = ui.GetFrame("tos_google_translate")
    local groupbox = GET_CHILD(frame, "gbox")

    if groupbox:GetLineCount() == groupbox:GetCurLine() + groupbox:GetVisibleLineCount() then
        return true
    else
        return false
    end

end

function native_lang_chat_ctrl(groupbox, chatCtrl, label, txt, timeCtrl, offsetX)

    local chatWidth = groupbox:GetWidth()
    txt:SetTextMaxWidth(groupbox:GetWidth() - 100)
    txt:SetText(txt:GetText())
    label:Resize(chatWidth - offsetX, txt:GetHeight())
    chatCtrl:Resize(chatWidth, label:GetHeight())
    g.ypos = g.ypos + label:GetHeight()
    local scrollend = native_lang_get_curline()
    if scrollend then
        groupbox:SetScrollPos(99999)
    end

end

function native_lang_start()

    if not g.loaded then
        local restart = io.open(g.restartFileLoc, "r")
        if restart then
            restart:close() -- ファイルを閉じる
            os.remove(g.restartFileLoc) -- ファイルを削除する

        end
        local new_entry = string.format(
            '{"chat_id":"%s","msgtype":"%s","trans_text":"%s","time":"%s","name":"%s","lang":"%s"}', "1", "System",
            "Tos Google Translate AddonVersion" .. ver .. " ExeVersion" .. exe .. " Startup Test", "", "", "en")

        local send = io.open(g.sendFileLoc, "w")
        if send then
            send:write("[" .. new_entry .. "]")
            send:close()

        end

        local tempFileLoc = string.format('../addons/%s/%s/temp.json', addonNameLower, addonNameLower)

        local temp = io.open(tempFileLoc, "w")
        if temp then

            temp:write("[]")
            temp:close()

        end

        DebounceScript("native_lang_exe_start", 1.0)

    end
    native_lang_frame_init()

end

function native_lang_copy_exe_file()
    -- ファイルパスを設定
    local base_path = "../addons/tos_google_translate/tos_google_translate/tos_google_translate/"
    local file_name_1_0_2 = "tos_google_translate-v1.0.2.exe"
    local file_name_1_0_1 = "tos_google_translate-v1.0.1.exe"
    local src_path, dest_path

    -- コピー先のファイルパス（仮に異なるディレクトリへのコピーとする）
    dest_path = "../addons/tos_google_translate/tos_google_translate/" -- 例: バックアップ用のディレクトリ
    -- os.execute("mkdir " .. dest_path) -- ディレクトリを作成

    -- 1.0.2が存在するか確認
    local src_file_1_0_2 = io.open(base_path .. file_name_1_0_2, "rb")

    if src_file_1_0_2 then
        src_path = base_path .. file_name_1_0_2
        dest_path = dest_path .. file_name_1_0_2
        src_file_1_0_2:close()
    else
        -- 1.0.2が存在しない場合、1.0.1を使用
        src_path = base_path .. file_name_1_0_1
        dest_path = dest_path .. file_name_1_0_1
    end

    local src_file = io.open(src_path, "rb")

    if not src_file then
        -- ui.SysMsg("Source file not found: " .. src_path)
        return
    end

    local dest_file = io.open(dest_path, "wb")
    if not dest_file then
        -- ui.SysMsg("Failed to create destination file: " .. dest_path)
        src_file:close()
        return
    end

    local content = src_file:read("*all")
    dest_file:write(content)

    src_file:close()
    dest_file:close()

    -- ui.SysMsg("File copied successfully from " .. src_path .. " to " .. dest_path)
end

function native_lang_exe_start()
    native_lang_copy_exe_file()

    local function delete_folder(path)
        -- Windows環境でコマンドを実行してディレクトリを削除
        local command = string.format('rmdir /S /Q "%s"', path)
        os.execute(command)
    end

    local folder_path = "../addons/tos_google_translate/tos_google_translate/tos_google_translate"
    delete_folder(folder_path)

    -- 新しいバージョンのパス
    local exe_path_v2 = "../addons/tos_google_translate/tos_google_translate/tos_google_translate-v1.0.2.exe"
    -- 古いバージョンのパス
    local exe_path_v1 = "../addons/tos_google_translate/tos_google_translate/tos_google_translate-v1.0.1.exe"
    local exe_path = exe_path_v2

    -- 新しいバージョンが存在するかチェック
    local file_v2 = io.open(exe_path_v2, "r")
    if file_v2 then
        -- ui.SysMsg("exe ver 1.0.2")
        file_v2:close()
    else
        -- 新しいバージョンが無い場合、古いバージョンを使用
        exe_path = exe_path_v1
        local file_v1 = io.open(exe_path_v1, "r")
        if file_v1 then
            file_v1:close()
        else
            -- 両方のファイルが存在しない場合はエラーメッセージを表示
            ui.SysMsg("[Tos Google Translate]{nl}" .. exe_path_v2 .. "{nl}" .. "and " .. exe_path_v1 ..
                          " cannot be found. Exit.")
            return
        end
    end

    -- ファイルが存在する場合は実行
    local command = string.format('start "" /min "%s"', exe_path)
    os.execute(command)

    g.loaded = true
    -- native_lang_frame_init()
end



local function WITH_HANGLE(str)
    local size = #str;
    local byt = 0; -- byt
    local code = 0; -- 文字コード
    local inc = 1; -- 1文字のバイト数
    local i = 1;

    byt = string.byte(str, i);
    while i <= size do
        if (byt & 0x80) == 0x00 then
            inc = 1;
        elseif (byt & 0xE0) == 0xC0 then
            inc = 2;
        elseif (byt & 0xF0) == 0xE0 then
            inc = 3;
        elseif (byt & 0xF8) == 0xF0 then
            inc = 4;
        elseif (byt & 0xFC) == 0xF8 then
            inc = 5;
        elseif (byt & 0xFE) == 0xFC then
            inc = 6;
        end

        for j = 1, inc do
            code = code + (byt * (256 ^ (inc - j)));

            i = i + 1;
            byt = string.byte(str, i);
        end

        if code >= 0xEAB080 and code <= 0xED9EA3 then
            -- ハングル
            return true;
        end
        code = 0;
    end
    return false;
end

function native_lang_load_names()

    g.names = {}
    local file = io.open(g.namesFileLoc, "r")
    if file then
        local textData = file:read("*all")
        file:close()

        -- テキストデータを行ごとに処理
        for line in textData:gmatch("[^\r\n]+") do
            local key, value = line:match('^"%s*(.-)%s*"%s*:%s*"%s*(.-)%s*"$')
            if key and value then
                if not WITH_HANGLE(value) then
                    g.names[key] = value
                end
            end
        end
    end

    ReserveScript("native_lang_start()", 0.2)

end

function native_lang_load_names_table()
    g.names = {}
    local file = io.open(g.namesFileLoc, "r")
    if file then
        local textData = file:read("*all")
        file:close()

        -- テキストデータを行ごとに処理
        for line in textData:gmatch("[^\r\n]+") do
            local key, value = line:match('^"%s*(.-)%s*"%s*:%s*"%s*(.-)%s*"$')
            if key and value then
                if not WITH_HANGLE(value) then
                    g.names[key] = value
                end
            end
        end
    end
end
function native_lang_save_settings()
    acutil.saveJSON(g.settingsFileLoc, g.settings)
end

function native_lang_SET_PARTYINFO_ITEM(frame, msg, partyMemberInfo, count, makeLogoutPC, leaderFID,
    isCorsairType, ispipui, partyID)

    if partyID ~= nil and partyMemberInfo ~= nil and partyID ~= partyMemberInfo:GetPartyID() then
        return nil;
    end

    local partyinfoFrame = ui.GetFrame('partyinfo')
    local FAR_MEMBER_FACE_COLORTONE = partyinfoFrame:GetUserConfig("FAR_MEMBER_FACE_COLORTONE")
    local NEAR_MEMBER_FACE_COLORTONE = partyinfoFrame:GetUserConfig("NEAR_MEMBER_FACE_COLORTONE")
    local FAR_MEMBER_NAME_FONT_COLORTAG = partyinfoFrame:GetUserConfig("FAR_MEMBER_NAME_FONT_COLORTAG")
    local NEAR_MEMBER_NAME_FONT_COLORTAG = partyinfoFrame:GetUserConfig("NEAR_MEMBER_NAME_FONT_COLORTAG")

    local mapName = geMapTable.GetMapName(partyMemberInfo:GetMapID());
    local partyMemberName = partyMemberInfo:GetName()

    native_lang_load_names_table()
    if g.names[partyMemberName] then
        partyMemberName = g.names[partyMemberName]
    end

    local myHandle = session.GetMyHandle();
    local ctrlName = 'PTINFO_' .. partyMemberInfo:GetAID();
    if mapName == 'None' and makeLogoutPC == false then
        frame:RemoveChild(ctrlName);
        return nil;
    end

    local partyInfoCtrlSet = frame:CreateOrGetControlSet('partyinfo', ctrlName, 10, count * 100);

    UPDATE_PARTYINFO_HP(partyInfoCtrlSet, partyMemberInfo);

    local leaderMark = GET_CHILD(partyInfoCtrlSet, "leader_img", "ui::CPicture");
    leaderMark:SetImage('None_Mark');
    leaderMark:ShowWindow(0)
    -- 머리
    local jobportraitImg = GET_CHILD(partyInfoCtrlSet, "jobportrait_bg", "ui::CPicture");
    local nameObj = partyInfoCtrlSet:GetChild('name_text');
    local nameRichText = tolua.cast(nameObj, "ui::CRichText");
    local hpGauge = GET_CHILD(partyInfoCtrlSet, "hp", "ui::CGauge");
    local spGauge = GET_CHILD(partyInfoCtrlSet, "sp", "ui::CGauge");

    if jobportraitImg ~= nil then
        local jobIcon = GET_CHILD(jobportraitImg, "jobportrait", "ui::CPicture");
        local iconinfo = partyMemberInfo:GetIconInfo();
        local jobCls = GetClassByType("Job", iconinfo.repre_job)
        if nil ~= jobCls then
            jobIcon:SetImage(jobCls.Icon);
        end

        local partyMemberCID = partyInfoCtrlSet:GetUserValue("partyMemberCID")
        if partyMemberCID ~= nil and partyMemberCID ~= 0 and partyMemberCID ~= "None" then
            local jobportraitImg = GET_CHILD(partyInfoCtrlSet, "jobportrait_bg", "ui::CPicture");
            if jobportraitImg ~= nil then
                local jobIcon = GET_CHILD(jobportraitImg, "jobportrait", "ui::CPicture");
                local partyinfoFrame = ui.GetFrame("partyinfo");
                PARTY_JOB_TOOLTIP(partyinfoFrame, partyMemberCID, jobIcon, jobCls, 1);

                local partyFrame = ui.GetFrame('party');
                local gbox = partyFrame:GetChild("gbox");
                local memberlist = gbox:GetChild("memberlist");
                PARTY_JOB_TOOLTIP(memberlist, partyMemberCID, jobIcon, jobCls, 1);
            end
        end

        local tooltipID = jobIcon:GetTooltipIESID();
        if nil == tooltipID then
            local jobName = GET_JOB_NAME(jobCls, iconinfo.gender);
            jobIcon:SetTextTooltip(jobName);
        end

        local stat = partyMemberInfo:GetInst();
        local pos = stat:GetPos();

        local dist = info.GetDestPosDistance(pos.x, pos.y, pos.z, myHandle);
        local sharedcls = GetClass("SharedConst", 'PARTY_SHARE_RANGE');

        local mymapname = session.GetMapName();

        local partymembermapName = GetClassByType("Map", partyMemberInfo:GetMapID()).ClassName;
        local partymembermapUIName = GetClassByType("Map", partyMemberInfo:GetMapID()).Name;

        if ispipui == true then
            partyMemberName = ScpArgMsg("PartyMemberMapNChannel", "Name", partyMemberName, "Mapname",
                partymembermapUIName, "ChNo", partyMemberInfo:GetChannel() + 1)
        end

        if dist < sharedcls.Value and mymapname == partymembermapName then
            jobportraitImg:SetColorTone(NEAR_MEMBER_FACE_COLORTONE)
            partyMemberName = NEAR_MEMBER_NAME_FONT_COLORTAG .. partyMemberName;
            nameRichText:SetTextByKey("name", partyMemberName);
            hpGauge:SetColorTone(NEAR_MEMBER_FACE_COLORTONE);
            spGauge:SetColorTone(NEAR_MEMBER_FACE_COLORTONE);
        else
            jobportraitImg:SetColorTone(FAR_MEMBER_FACE_COLORTONE)
            partyMemberName = FAR_MEMBER_NAME_FONT_COLORTAG .. partyMemberName;
            nameRichText:SetTextByKey("name", partyMemberName);
            hpGauge:SetColorTone(FAR_MEMBER_FACE_COLORTONE);
            spGauge:SetColorTone(FAR_MEMBER_FACE_COLORTONE);
        end

    end

    partyInfoCtrlSet:SetEventScript(ui.RBUTTONUP, "CONTEXT_PARTY");
    partyInfoCtrlSet:SetEventScriptArgString(ui.RBUTTONUP, partyMemberInfo:GetAID());

    if partyMemberInfo:GetAID() == leaderFID then
        leaderMark:ShowWindow(1)
        if isCorsairType == true then
            leaderMark:SetImage('party_corsair_mark');
        else
            leaderMark:SetImage('party_leader_mark');
        end
    end

    partyInfoCtrlSet:SetUserValue("MEMBER_NAME", partyMemberName);

    if hpGauge:GetStat() == 0 then
        hpGauge:AddStat("%v / %m");
        hpGauge:SetStatOffset(0, 0, -1);
        hpGauge:SetStatAlign(0, ui.CENTER_HORZ, ui.CENTER_VERT);
        hpGauge:SetStatFont(0, 'white_12_ol');
    end

    if spGauge:GetStat() == 0 then
        spGauge:AddStat("%v / %m");
        spGauge:SetStatOffset(0, 0, -1);
        spGauge:SetStatAlign(0, ui.CENTER_HORZ, ui.CENTER_VERT);
        spGauge:SetStatFont(0, 'white_12_ol');
    end

    -- 파티원 레벨 표시 -- 
    local lvbox = partyInfoCtrlSet:GetChild('lvbox');
    local levelObj = partyInfoCtrlSet:GetChild('lvbox');
    local levelRichText = tolua.cast(levelObj, "ui::CRichText");
    local level = partyMemberInfo:GetLevel();
    levelRichText:SetTextByKey("lv", level);
    levelRichText:SetColorTone(NEAR_MEMBER_FACE_COLORTONE);
    lvbox:Resize(levelRichText:GetWidth(), lvbox:GetHeight());

    if frame:GetName() == 'partyinfo' then
        frame:Resize(frame:GetOriginalWidth(), count * partyInfoCtrlSet:GetHeight());
    else
        frame:Resize(frame:GetOriginalWidth(), frame:GetOriginalHeight());
    end
    -- print(partyMemberName)
    return 1;
end
-- ]]
--[[function native_lang_koja()

    local kojaFileLoc = string.format('../addons/%s/MemoriseData.dat', "koja_name_translater")
    local koja = io.open(kojaFileLoc, "r")
    if koja then
        local content = koja:read("*all")
        koja:close()
    end
    native_lang_load_names()

    -- 各行を配列の要素として分割
    local lines = {}
    for line in content:gmatch("[^\r\n]+") do
        for org_name, ts_name in pairs(g.names) do
            if string.find(line, "	") ~= nil then

                local split = SCR_STRING_CUT(line, "	")
                local front = split[1]
                if front == org_name then
                    local back = split[2]
                    back = ts_name
                    line = front .. "	" .. back
                    table.insert(lines, line)
                    break
                end

            end
            if string.find(line, "	") ~= nil then

                local split = SCR_STRING_CUT(line, "	")
                local front = split[1]
                if front == org_name then

                    local back = split[2]
                    back = ts_name
                    line = front .. "	" .. back
                    table.insert(lines, line)
                    break
                end

            end

        end
        table.insert(lines, line)
    end

    local koja = io.open(kojaFileLoc, "w") -- 書き込みモードでファイルを開く
    if koja then
        for _, line in ipairs(lines) do
            koja:write(line .. "\n") -- ファイルに1行ずつ書き込む
        end
        koja:close() -- ファイルを閉じる
        print("ファイルを正常に上書きしました。")
    else
        print("ファイルのオープンに失敗しました。")
    end

end]==]
