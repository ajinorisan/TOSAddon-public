local addonName = "YOUR_NAME"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "0.0.1"
local exe = "0.0.1"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

g.settings_location = string.format('../addons/%s/settings.json', addonNameLower)
g.send_location = string.format('../addons/%s/send.dat', addonNameLower)
g.receive_location = string.format('../addons/%s/receive.dat', addonNameLower)
g.name_location = string.format('../addons/%s/name.dat', addonNameLower)

local acutil = require("acutil")
local json = require('json')
local os = require("os")

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
            -- ハングルの範囲内
            return true
        end
    end
    return false
end

local function WITH_JAPANESE(str)
    for _, code in utf8.codes(str) do
        -- ひらがな、カタカナ、漢字のいずれかに該当
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
        -- 英語のアルファベット (大文字・小文字)
        if (code >= 0x41 and code <= 0x5A) or -- 'A' ～ 'Z'
        (code >= 0x61 and code <= 0x7A) then -- 'a' ～ 'z'
            return true
        end
    end
    return false
end

function your_name_is_translation(str)
    if g.lang == "ja" then
        return WITH_HANGLE(str)
    elseif g.lang == "ko" then
        return WITH_JAPANESE(str)
    elseif g.lang == "en" then
        return WITH_HANGLE(str) and WITH_JAPANESE(str)
    end
    return false
end

function your_name_not_found_name(str)

    local name_file = io.open(g.name_location, "a")
    if name_file then
        name_file:write(str .. ":::" .. str .. "\n")
        name_file:flush()
        name_file:close()
    end
end

function your_name_save_settings()
    acutil.saveJSON(g.settings_location, g.settings)
end

function your_name_load_settings()

    local settings = acutil.loadJSON(g.settings_location, g.settings)

    if not settings then

        settings = {
            use = 1
        }

    end
    g.settings = settings

    local name_file = io.open(g.name_location, "r")
    if not name_file then
        name_file = io.open(g.name_location, "w")
        if name_file then
            name_file:close()
        end
    else
        name_file:close()
    end

    local send_file = io.open(g.send_location, "r")
    if not send_file then
        send_file = io.open(g.send_location, "w")
        if send_file then
            send_file:close()
        end
    else
        send_file:close()
    end

    local receive_file = io.open(g.receive_location, "r")
    if not receive_file then
        receive_file = io.open(g.receive_location, "w")
        if receive_file then
            receive_file:close()
        end
    else
        receive_file:close()
    end

    if not g.chat_ids then
        g.chat_ids = {}
    end

    if not g.separate then
        g.separate = {}
    end

    your_name_save_settings()
end

function YOUR_NAME_ON_INIT(addon, frame)
    g.addon = addon
    g.frame = frame

    your_name_load_settings()

    local lang = option.GetCurrentCountry()
    if lang == "Japanese" then
        g.lang = "ja"
    elseif lang == "kr" then
        g.lang = "ko"
    else
        g.lang = "en"
    end

    addon:RegisterMsg("GAME_START_3SEC", "your_name_3SEC");
end

function your_name_3SEC(frame, msg, str, num)
    acutil.setupEvent(g.addon, "DRAW_CHAT_MSG", "your_name_DRAW_CHAT_MSG");
    g.addon:RegisterMsg("FPS_UPDATE", "your_name_name_trans");

    local frame = ui.GetFrame("chatframe")
    local timer = frame:CreateOrGetControl("timer", "addontimer2", 0, 0);
    AUTO_CAST(timer)
    timer:SetUpdateScript("your_name_chat_update");
    timer:Start(5.0);
end

function format_chat_message(frame, msg_type, right_name, msg)
    local msg_type_map = {
        Normal = 1,
        Shout = 2,
        Party = 3,
        Guild = 4,
        System = 7
    }
    local chat_type_id = msg_type_map[msg_type]
    if chat_type_id then
        local font_size = GET_CHAT_FONT_SIZE()
        local font_style = frame:GetUserConfig("TEXTCHAT_FONTSTYLE_" .. msg_type:upper())
        return string.format("[%s]%s : %s", ScpArgMsg("ChatType_" .. chat_type_id), right_name, msg), font_style,
               font_size
    end
    return nil, nil, nil -- msg_typeが無効な場合
end

function your_name_chat_update(frame)

    local name_file_read = io.open(g.name_location, "r")
    if name_file_read then
        for line in name_file_read:lines() do
            local left_name, right_name = line:match("^(.-):::(.*)$")
            if left_name and right_name then
                g.names[left_name] = right_name

                if g.chat_ids[left_name] ~= nil then

                    local chat_id = g.chat_ids[left_name].chat_id
                    local msg_type = g.chat_ids[left_name].msg_type

                    if msg_type == "Normal" or msg_type == "Shout" or msg_type == "Party" or msg_type == "Guild" then
                        local frame = ui.GetFrame("chatframe")
                        local clustername = "cluster_" .. chat_id
                        local cluster = GET_CHILD_RECURSIVELY(frame, clustername)
                        if cluster:IsVisible() == 1 and cluster ~= nil then

                            local text = GET_CHILD_RECURSIVELY(cluster, "text")
                            if text ~= nil then
                                local chat_text = text:GetText()
                                local name, msg = string.match(chat_text, "(.+) : (.+)")
                                if your_name_is_translation(name) then
                                    local name_and_text = right_name .. " : " .. msg

                                    local font_size = GET_CHAT_FONT_SIZE()
                                    local msg_front = ""
                                    local font_style = ""

                                    if msg_type == "Normal" then
                                        font_style = frame:GetUserConfig("TEXTCHAT_FONTSTYLE_NORMAL")
                                        msg_front = string.format("[%s]%s", ScpArgMsg("ChatType_1"), name_and_text)
                                    elseif msg_type == "Shout" then
                                        font_style = frame:GetUserConfig("TEXTCHAT_FONTSTYLE_SHOUT")
                                        msg_front = string.format("[%s]%s", ScpArgMsg("ChatType_2"), name_and_text)
                                    elseif msg_type == "Party" then
                                        font_style = frame:GetUserConfig("TEXTCHAT_FONTSTYLE_PARTY")
                                        msg_front = string.format("[%s]%s", ScpArgMsg("ChatType_3"), name_and_text)
                                    elseif msg_type == "Guild" then
                                        font_style = frame:GetUserConfig("TEXTCHAT_FONTSTYLE_GUILD")
                                        msg_front = string.format("[%s]%s", ScpArgMsg("ChatType_4"), name_and_text)
                                    elseif msg_type == "System" then
                                        font_style = frame:GetUserConfig("TEXTCHAT_FONTSTYLE_SYSTEM")
                                        msg_front = string.format("[%s]%s", ScpArgMsg("ChatType_7"), name_and_text)
                                    end

                                    text:SetTextByKey("font", font_style)
                                    text:SetTextByKey("size", font_size)
                                    text:SetTextByKey("text", msg_front)
                                end

                            end
                        end
                    end
                end
            end
        end
        name_file_read:close()
    end

end

function your_name_name_replace(frame, msg_type, msg, name, chat_id)

    local name_file_read = io.open(g.name_location, "r")

    if name_file_read then
        for line in name_file_read:lines() do
            local left_name, right_name = line:match("^(.-):::(.*)$")
            if left_name and right_name then
                g.names[left_name] = right_name
                if left_name == name then
                    break
                end
            end
        end
        name_file_read:close()
    end

    local name_file_write = io.open(g.name_location, "a")
    if name_file_write then
        if not g.names[name] then
            g.names[name] = name
            name:gsub("{", "")
            name_file_write:write(name .. ":::" .. name .. "\n")
            name_file_write:flush()
            g.chat_ids[name] = {
                chat_id = chat_id,
                msg_type = msg_type
            }
        end
        name_file_write:close()
    end

    local right_name = g.names[name]
    if right_name ~= nil then
        local clustername = "cluster_" .. chat_id
        if clustername ~= nil then
            local cluster = GET_CHILD_RECURSIVELY(frame, clustername)
            local text = GET_CHILD_RECURSIVELY(cluster, "text")
            if text ~= nil then

                local name_and_text = right_name .. " : " .. msg

                local font_size = GET_CHAT_FONT_SIZE()
                local msg_front = ""
                local font_style = ""

                if msg_type == "Normal" then
                    font_style = frame:GetUserConfig("TEXTCHAT_FONTSTYLE_NORMAL")
                    msg_front = string.format("[%s]%s", ScpArgMsg("ChatType_1"), name_and_text)
                elseif msg_type == "Shout" then
                    font_style = frame:GetUserConfig("TEXTCHAT_FONTSTYLE_SHOUT")
                    msg_front = string.format("[%s]%s", ScpArgMsg("ChatType_2"), name_and_text)
                elseif msg_type == "Party" then
                    font_style = frame:GetUserConfig("TEXTCHAT_FONTSTYLE_PARTY")
                    msg_front = string.format("[%s]%s", ScpArgMsg("ChatType_3"), name_and_text)
                elseif msg_type == "Guild" then
                    font_style = frame:GetUserConfig("TEXTCHAT_FONTSTYLE_GUILD")
                    msg_front = string.format("[%s]%s", ScpArgMsg("ChatType_4"), name_and_text)
                elseif msg_type == "System" then
                    font_style = frame:GetUserConfig("TEXTCHAT_FONTSTYLE_SYSTEM")
                    msg_front = string.format("[%s]%s", ScpArgMsg("ChatType_7"), name_and_text)
                end

                text:SetTextByKey("font", font_style)
                text:SetTextByKey("size", font_size)
                text:SetTextByKey("text", msg_front)

            end
        end
    end

end

function your_name_msg_send(frame, send_msg)
    local send_file = io.open(g.send_location, "a")

    if send_file then
        send_file = io.open(g.send_location, "a")
        send_file:write(send_msg .. "\n")
        send_file:flush()
        send_file:close()
    end
end

function your_name_DRAW_CHAT_MSG(frame, msg)

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
        elseif cluster:IsVisible() == 1 then

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
            local name = chat:GetCommanderName()

            if your_name_is_translation(name) then

                your_name_name_replace(frame, msg_type, msg, name, chat_id)
            end

            if string.find(msg, "{spine ") then
                return
            end

            local send_msg = chat_id .. ":::" .. msg_type .. ":::" .. groupboxname .. ":::" .. msg

            if your_name_is_translation(msg) then
                local separate_msg = string.match(msg, "(%b{})%{/}{/}")
                if separate_msg then
                    msg = msg:gsub(separate_msg, "")
                    send_msg = chat_id .. ":::" .. msg_type .. ":::" .. groupboxname .. ":::" .. msg .. ":::" ..
                                   separate_msg
                end

                your_name_msg_send(frame, send_msg)
            end
        end
        break
    end
end

function your_name_given_name(frame_given_name, pc_txt_frame)
    local given_name = frame_given_name:GetText()
    local clean_name = given_name:gsub("{.-}", ""):gsub("__+", "_"):match("^%s*(.-)%s*$")

    if your_name_is_translation(clean_name) then
        local right_name = your_name_process_name(frame_given_name, clean_name)
        if right_name ~= nil then
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

function your_name_family_name(frame_family_name)
    local family_name = frame_family_name:GetText()
    local clean_name = family_name:gsub("{.-}", ""):gsub("__+", "_"):match("^%s*(.-)%s*$")

    if your_name_is_translation(clean_name) then
        local right_name = your_name_process_name(frame_family_name, clean_name)
        if right_name ~= nil then
            local original_part = family_name:sub(1, 9)
            local new_family_name = original_part .. right_name
            frame_family_name:SetText(new_family_name)
        end

    end
end

function your_name_guild_name(frame_guild_name)

    local guild_name = frame_guild_name:GetText()

    if string.find(guild_name, "{img guild_master_mark 20 20}") then
        guild_name = string.gsub(guild_name, "{img guild_master_mark 20 20}", "")
    end

    if your_name_is_translation(guild_name) then
        local new_guild_name = your_name_process_name(frame_guild_name, guild_name)
        if new_guild_name ~= nil then
            frame_guild_name:SetText(new_guild_name)
        end
    end
end

function your_name_shop_name(shop_frame)
    local shop_text = GET_CHILD(shop_frame, "text");
    AUTO_CAST(shop_text)
    if shop_text ~= nil then
        local text = shop_text:GetText():gsub("{.-}", ""):gsub("__+", "_"):match("^%s*(.-)%s*$")
        if your_name_is_translation(text) then

            local new_shop_name = your_name_process_name(shop_text, text)
            if new_shop_name ~= nil then
                shop_text:SetTextByKey("value", new_shop_name);
            end
        end
    end
    local frame_lv_box = GET_CHILD(shop_frame, "withLvBox");
    if frame_lv_box ~= nil then
        local frame_shop_name = GET_CHILD(frame_lv_box, "lv_title");
        if frame_shop_name ~= nil then
            local shop_name = frame_shop_name:GetText():gsub("{.-}", ""):gsub("__+", "_"):match("^%s*(.-)%s*$")

            if your_name_is_translation(shop_name) then
                local new_shop_name = your_name_process_name(frame_shop_name, shop_name)
                if new_shop_name ~= nil then
                    frame_shop_name:SetTextByKey("value", new_shop_name);
                end
            end
        end
    end
end

function your_name_process_name(frame, clean_name)
    local name_file = io.open(g.name_location, "r")
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
            your_name_not_found_name(clean_name)
        end
    end
    return nil
end

function your_name_name_trans()
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
                        your_name_given_name(frame_given_name, pc_txt_frame)
                    end

                    local frame_family_name = GET_CHILD(pc_txt_frame, "familyName")
                    if frame_family_name ~= nil then
                        your_name_family_name(frame_family_name)
                    end

                    local frame_name = GET_CHILD(pc_txt_frame, "name")
                    if frame_name ~= nil then
                        your_name_family_name(frame_name)
                    end

                    local frame_guild_name = GET_CHILD(pc_txt_frame, "guildName")
                    if frame_guild_name ~= nil then
                        your_name_guild_name(frame_guild_name)
                    end

                    local shop_frame = ui.GetFrame("SELL_BALLOON_" .. handle);
                    if shop_frame ~= nil then
                        your_name_shop_name(shop_frame)
                    end

                end
            end
        end
    end
end

-- ui.Chat("/p 감자조와")
--[==[g.loaded = false

function your_name_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame
    g.lastmsg = ""
    g.ypos = 0

    g.extractedTexts = g.extractedTexts or {} -- 抽出したテキストを格納するテーブル

    your_name_load_settings()

    acutil.slashCommand("/tos_google_translate", your_name_restart);
    acutil.slashCommand("/tgt", your_name_restart);
    -- g.SetupHook(your_name_REQ_TRANSLATE_TEXT, "REQ_TRANSLATE_TEXT")
    g.SetupHook(your_name_SET_PARTYINFO_ITEM, "SET_PARTYINFO_ITEM")
    -- g.SetupHook(your_name_CHAT_TAB_BTN_CLICK, "CHAT_TAB_BTN_CLICK")
    g.SetupHook(your_name_DAMAGE_METER_GAUGE_SET, "DAMAGE_METER_GAUGE_SET")
    addon:RegisterMsg("GAME_START", "your_name_koja");
    addon:RegisterMsg("GAME_START_3SEC", "your_name_name_trans");

end

function your_name_koja()

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

function your_name_DAMAGE_METER_GAUGE_SET(ctrl, leftStr, point, rightStr, skin)
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
function your_name_CHAT_TAB_BTN_CLICK(parent, ctrl)
    if g.settings.use ~= 0 then

        ui.SysMsg(your_name_lang("Tos Google Translate must be stopped before switching."))
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

function your_name_name_trans()
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

function your_name_REQ_TRANSLATE_TEXT(frameName, gbName, ctrlName)
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
        ui.SysMsg(your_name_lang("Tos Google Translate must be stopped before translating."))
        return
    end
end

function your_name_lang(str)
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

function your_name_extractAndCleanText(text, id)

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

function your_name_ReplaceMSG(MSG)

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

function your_name_DRAW_CHAT_MSG(frame, msg)

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
            MSG = your_name_ReplaceMSG(MSG)

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

        local cleanedText, extractedTexts = your_name_extractAndCleanText(modifiedString, chat_id)
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
        -- frame:RunUpdateScript("your_name_receive", 1)
    end

end

function your_name_receive()

    if g.settings.use == 0 then
        return 0
    end
    local tempnameFileLoc = string.format('../addons/%s/%s/tempname.dat', addonNameLower, addonNameLower)
    local file = io.open(tempnameFileLoc, "r")
    if not file then
        if g.tempname_tame == 1 then
            your_name_load_names_table()
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
        your_name_gbox(output)
        --[[local tgtframe = ui.GetFrame("tos_google_translate")
        local groupbox = GET_CHILD(tgtframe, "gbox")
        g.curLine = groupbox:GetCurLine()]]

        return
    else
        return
    end
end

function your_name_context()
    local context = ui.CreateContextMenu("your_name_context", "Tos Google Translate", 0, 0, 200, 0)
    local strScp = string.format("your_name_restart()")
    ui.AddContextMenuItem(context, "Restart", strScp)
    strScp = string.format("your_name_replacement()")
    ui.AddContextMenuItem(context, "Replace Mode", strScp)
    strScp = string.format("your_name_frame_open()")
    ui.AddContextMenuItem(context, "Frame Open & Start", strScp)
    strScp = string.format("your_name_frame_close()")
    ui.AddContextMenuItem(context, "Frame Close & Stop", strScp)
    ui.OpenContextMenu(context)
end

function your_name_restart()
    ui.SysMsg(your_name_lang("Tos Google Translate initialize. Please return to the barracks."))
    local frame = ui.GetFrame("tos_google_translate")

    local file = io.open(g.restartFileLoc, "w")
    file:write("restart")
    file:close()

    -- g.extractedTexts = {}

    g.loaded = false
    g.size = 0
    frame:RemoveAllChild()
    your_name_frame_init()
    local file = io.open(g.noticeFileLoc, "w")
    if file then
        file:write("")
        file:close()
    end

end

function your_name_replacement()

    g.settings.use = 2
    your_name_save_settings()
    local frame = ui.GetFrame("tos_google_translate")

    frame:ShowWindow(0)

    your_name_frame_init()

end

function your_name_frame_open()

    g.settings.use = 1

    your_name_frame_init()

    your_name_save_settings()
end

function your_name_frame_close()
    local frame = ui.GetFrame("tos_google_translate")
    frame:ShowWindow(0)

    g.settings.use = 0
    your_name_save_settings()

    your_name_frame_init()

end

function your_name_frame_init(frame, ctrl, argStr, argNum)

    acutil.setupEvent(g.addon, "DRAW_CHAT_MSG", "your_name_DRAW_CHAT_MSG");
    g.addon:RegisterMsg("FPS_UPDATE", "your_name_receive");
    local chatframe = ui.GetFrame("chatframe")
    local tabgbox = GET_CHILD_RECURSIVELY(chatframe, "tabgbox")
    local trans = tabgbox:CreateOrGetControl("button", "trans", 270, -3, 30, 30)
    AUTO_CAST(trans)
    if g.settings.use == 0 then
        trans:SetSkinName('test_gray_button')
        trans:SetTextTooltip("[Tos Google Translate]{nl}" .. "Translation mode off{nl}" ..
                                 your_name_lang("Left click:Setting menu display"))
    elseif g.settings.use == 1 then
        trans:SetSkinName("test_red_button")
        trans:SetTextTooltip("[Tos Google Translate]{nl}" .. "Translation mode on{nl}" ..
                                 your_name_lang("Left click:Setting menu display"))
    elseif g.settings.use == 2 then
        trans:SetSkinName("baseyellow_btn")
        trans:SetTextTooltip("[Tos Google Translate]{nl}" .. "Replace mode in operation.{nl}" ..
                                 your_name_lang("Left click:Setting menu display"))
    end

    trans:SetText("{ol}{s14}{#FFFFFF}" .. g.settings["lang"])
    -- trans:SetEventScript(ui.LBUTTONUP, "your_name_frame_open")
    trans:SetEventScript(ui.LBUTTONUP, "your_name_context")
    -- trans:SetEventScript(ui.RBUTTONUP, "your_name_restart")

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
        your_name_gbox(output)

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
        your_name_gbox(output)
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

function your_name_gbox(output)
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
            your_name_chat_ctrl(gbox, chatCtrl, label, txt, timeCtrl, offsetX)

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

end

function your_name_get_curline()
    local frame = ui.GetFrame("tos_google_translate")
    local groupbox = GET_CHILD(frame, "gbox")

    if groupbox:GetLineCount() == groupbox:GetCurLine() + groupbox:GetVisibleLineCount() then
        return true
    else
        return false
    end

end

function your_name_chat_ctrl(groupbox, chatCtrl, label, txt, timeCtrl, offsetX)

    local chatWidth = groupbox:GetWidth()
    txt:SetTextMaxWidth(groupbox:GetWidth() - 100)
    txt:SetText(txt:GetText())
    label:Resize(chatWidth - offsetX, txt:GetHeight())
    chatCtrl:Resize(chatWidth, label:GetHeight())
    g.ypos = g.ypos + label:GetHeight()
    local scrollend = your_name_get_curline()
    if scrollend then
        groupbox:SetScrollPos(99999)
    end

end

function your_name_start()

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

        DebounceScript("your_name_exe_start", 1.0)

    end
    your_name_frame_init()

end

function your_name_copy_exe_file()
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

function your_name_exe_start()
    your_name_copy_exe_file()

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
    -- your_name_frame_init()
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

function your_name_load_names()

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

    ReserveScript("your_name_start()", 0.2)

end

function your_name_load_names_table()
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
function your_name_save_settings()
    acutil.saveJSON(g.settingsFileLoc, g.settings)
end

function your_name_SET_PARTYINFO_ITEM(frame, msg, partyMemberInfo, count, makeLogoutPC, leaderFID,
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

    your_name_load_names_table()
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
--[[function your_name_koja()

    local kojaFileLoc = string.format('../addons/%s/MemoriseData.dat', "koja_name_translater")
    local koja = io.open(kojaFileLoc, "r")
    if koja then
        local content = koja:read("*all")
        koja:close()
    end
    your_name_load_names()

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
