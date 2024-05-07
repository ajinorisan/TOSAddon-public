local addonName = "TOS_GOOGLE_TRANSLATE"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "0.0.1"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)
g.namesFileLoc = string.format('../addons/%s/names.json', addonNameLower)
g.outputFileLoc = string.format('../addons/%s/output.json', addonNameLower)
g.tempFileLoc = string.format('../addons/%s/temp.json', addonNameLower)
g.ttempFileLoc = string.format('../addons/%s/ttemp.json', addonNameLower)

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

g.loaded = false

function TOS_GOOGLE_TRANSLATE_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame
    g.lastmsg = ""
    g.ypos = 0
    g.gbox = true

    if not g.loaded then
        g.output = {}
        acutil.saveJSON(g.outputFileLoc, g.output)
        -- g.settings = {}
        -- tos_google_translate_save_settings()
    end

    tos_google_translate_load_settings()
    acutil.slashCommand("/tos_google_translate", tos_google_translate_restart);
    acutil.slashCommand("/tgt", tos_google_translate_restart);
end

function tos_google_translate_lang(str)
    local langCode = option.GetCurrentCountry()
    if langCode == "Japanese" then
        if str ==
            "Please run the restart.bat file in the Tree Of Savior'-'addons'-'tos_google_translate' folder with administrator privileges and then go back to the barracks once" then
            str =
                "Tree Of Savior'-'addons'-'tos_google_translateフォルダにあるrestart.batを管理者権限で実行してからバラックに一度戻ってください。"
        end
        return str
    elseif langCode == "Korean" then
        if str ==
            "Please run the restart.bat file in the Tree Of Savior'-'addons'-'tos_google_translate' folder with administrator privileges and then go back to the barracks once" then
            str =
                "Tree Of Savior'-'addons'-'tos_google_translate 폴더에 있는 restart.bat를 관리자 권한으로 실행한 후, 다시 한번 Barracks로 돌아와주세요."
        end
        return str
    else
        return str
    end

end

function tos_google_translate_restart()
    ui.SysMsg(tos_google_translate_lang(
        "Please run the restart.bat file in the Tree Of Savior'-'addons'-'tos_google_translate' folder with administrator privileges and then go back to the barracks once"))
    --[[local batch_file = "../addons/tos_google_translate/restart.bat"
    os.execute(batch_file)]]

    g.loaded = false
end

function tos_google_translate_msg_del()

    if #g.settings["chat"] == 0 then
        -- print("nai")
        return
    else

        local newtable = {}
        --[[local recv_file_path = string.format('../addons/%s/recv.json', addonNameLower)
        local file = io.open(recv_file_path, "r")

        if file then
            -- JSONデータをテーブルに変換
            local file_data = file:read("*all") -- ファイルの内容を変数に保存
            file:close() -- ファイルを閉じる
            local data = json.decode(file_data)
            if #data ~= 0 then
                -- JSONデータをテーブルに変換

                for j, entry in ipairs(g.settings["chat"]) do
                    for i, e in ipairs(data) do
                        if e.chat_id ~= entry.chat_id then
                            table.insert(newtable, entry)
                            print(e.chat_id)

                            break
                        end
                    end

                end
                g.settings["chat"] = {}
                tos_google_translate_save_settings()
            else
                for i, entry in ipairs(g.settings["chat"]) do
                    table.insert(newtable, entry)
                    print(i)
                end

            end
        else
            for i, entry in ipairs(g.settings["chat"]) do

                table.insert(newtable, entry)

            end

        end]]
        local newtable = {}
        local send_file_path = string.format('../addons/%s/send.json', addonNameLower)
        local file = io.open(send_file_path, "r")

        if file then
            -- JSONデータをテーブルに変換
            local file_data = file:read("*all")
            file:close() -- ファイルを閉じる
            local data = json.decode(file_data)
            print(#data)
            for i, e in ipairs(data) do
                print(e.chat_id)
            end

        end

        for i, entry in ipairs(g.settings["chat"]) do

            table.insert(newtable, entry)

        end
        local send_table = {} -- 新しいテーブルを作成
        for key, value in ipairs(newtable) do
            local chat_id = value.chat_id -- 値を直接取得して代入
            local trans_text = value.trans_text -- 値を直接取得して代入
            local name = value.name -- 値を直接取得して代入
            local lang = value.lang -- 値を直接取得して代入
            local msgtype = value.msgtype
            local time = value.time

            -- 新しいテーブルに値を追加
            table.insert(send_table, {
                chat_id = chat_id,
                trans_text = trans_text,
                name = name,
                lang = lang,
                msgtype = msgtype,
                time = time
            })
        end

        local send_json = json.encode(send_table)
        print(send_json)
        local send_file_path = string.format('../addons/%s/send.json', addonNameLower)

        local send_file = io.open(send_file_path, "w")
        if send_file then
            send_file:write(send_json) -- エンコードされたJSONデータをファイルに書き込む
            send_file:close() -- ファイルを閉じる
        end

        local success, message = os.remove(recv_file_path)
        if success then
            print("recvファイルが削除されました。")
        else
            -- print("recvファイルの削除中にエラーが発生しました:" .. message)
        end
        --[[ print(tostring(send_table))
        -- 新しいテーブルをJSON形式に変換して出力
        local send_json = json.encode({
            send = send_table
        })
        -- print(send_json)

        local file = io.open(g.ttempFileLoc, "r")
        local existingContent = ""

        existingContent = file:read("*all")
        file:close()
        -- print(existingContent)
        -- print(next(g.ttemp["send"]) .. "next")

        -- local pattern = tostring('"send":[]')
        existingContent = string.gsub('"send":[]', '"send":' .. newtable)
        local file = io.open(g.ttempFileLoc, "r")

        local file = io.open(g.ttempFileLoc, "r")
        local existingContent = ""

        local notice_file_path = string.format('../addons/%s/notice.txt', addonNameLower)
        if not file_exists(notice_file_path) then
            local notice_file = io.open(notice_file_path, "w")
            if notice_file then
                notice_file:close()
            end
        end

        --[[if existingContent == "[]" then
            local file = io.open(g.ttempFileLoc, "w")
            existingContent = json.encode(newtable)
            file:write(existingContent) -- 新しいテーブルを書き込む
            file:close()
        else
            local file = io.open(g.temptFileLoc, "w")
            existingContent = existingContent:gsub("]", ",")

            newtable = json.encode(newtable)
            newtable = newtable:gsub("^%[", "")

            existingContent = existingContent .. newtable
            print(tostring(existingContent))
            file:write(existingContent) -- 新しいテーブルを書き込む
            file:close()
        end]]

        --[[local file = io.open(g.tempFileLoc, "a") -- 追記モードでファイルを開く
        if file then

            if existingContent ~= "[]" then
                -- 既存の内容がある場合、末尾の "]" を削除してから新しいテーブルを追記
                existingContent = existingContent:gsub("]", "") -- 末尾の "]" を削除

                file:write(existingContent .. ",") -- 既存の内容を書き込む

                -- file:write(",") -- 既存の内容がある場合、カンマで区切る
            else
                print("[]")
                existingContent = existingContent:gsub("[]", "")
                existingContent = json.encode(newtable)
            end
            print(tostring(existingContent))
            -- local newtable_str = json.encode(newtable):sub(2)
            file:write(existingContent) -- 新しいテーブルを書き込む
            file:close()
        end]]

        -- 元のテーブルを空にする
        -- g.settings["chat"] = {}

        -- 設定を保存する
        -- tos_google_translate_save_settings()
    end
end

function tos_google_translate_frame_init(frame, ctrl, argStr, argNum)

    acutil.setupEvent(g.addon, "DRAW_CHAT_MSG", "tos_google_translate_DRAW_CHAT_MSG");
    g.addon:RegisterMsg("FPS_UPDATE", "tos_google_translate_msg_del")

    local chatframe = ui.GetFrame("chatframe")
    local tabgbox = GET_CHILD_RECURSIVELY(chatframe, "tabgbox")
    local trans = tabgbox:CreateOrGetControl("button", "trans", 270, -3, 30, 30)
    AUTO_CAST(trans)
    trans:SetSkinName("test_red_button")
    trans:SetText("{ol}{s14}{#FFFFFF}" .. g.settings["lang"])
    trans:SetEventScript(ui.LBUTTONUP, "tos_google_translate_frame_open")
    trans:SetTextTooltip("Open and close the translation chat window.")
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
        local gbox = frame:CreateOrGetControl("groupbox", "gbox", 0, 0, frame:GetWidth(), frame:GetHeight())
        AUTO_CAST(gbox)

        gbox:SetLeftScroll(1)

    else
        return
    end
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

function tos_google_translate_gbox()

    local mainchatFrame = ui.GetFrame("chatframe")

    local frame = ui.GetFrame("tos_google_translate")
    local gbox = GET_CHILD(frame, "gbox")
    AUTO_CAST(gbox)

    local trans_name = ""
    local translate_text = ""
    local org_name = ""
    local trans_text = ""
    local msgtype = ""
    local time = ""
    local chat_id = ""

    g.ypos = 0
    for i, entry in ipairs(g.output) do
        -- print("Entry " .. i .. ":")
        for key, value in pairs(entry) do
            -- print(key .. ":" .. value)
            org_name = entry.org_name
            trans_text = entry.trans_text
            msgtype = entry.msgtype
            time = entry.time
            chat_id = entry.chat_id
            local replaced_name = g.names[org_name] or org_name

            local clustername = "cluster_" .. chat_id
            local marginLeft = 20
            local marginRight = 0

            local commnderNameUIText = replaced_name .. " : " .. trans_text
            local tblid = tonumber(g.extractedTexts[1])
            local tblcount = #g.extractedTexts

            if tblcount ~= 1 and chat_id == tblid then
                for i = 2, tblcount do
                    commnderNameUIText = commnderNameUIText .. g.extractedTexts[i]
                    g.output["trans_text"] = g.output["trans_text"] .. g.extractedTexts[i]

                end
                acutil.saveJSON(g.outputFileLoc, g.output)
                g.extractedTexts = {}
            end
            print(commnderNameUIText)

            local chatCtrl = gbox:CreateOrGetControlSet('chatTextVer', clustername, ui.LEFT, ui.TOP, marginLeft, g.ypos,
                marginRight, 1)
            local label = chatCtrl:GetChild('bg')
            local txt = GET_CHILD(chatCtrl, "text")
            local timeCtrl = GET_CHILD(chatCtrl, "time")

            local msgFront = ""
            local msgString = ""
            local fontStyle = nil

            label:SetAlpha(0)

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
                msgFront = string.format("[%s]%s", ScpArgMsg("ChatType_7"), trans_text)
            end
            local fontSize = GET_CHAT_FONT_SIZE()
            txt:SetTextByKey("font", fontStyle)
            txt:SetTextByKey("size", fontSize)
            txt:SetTextByKey("text", msgFront)
            timeCtrl:SetTextByKey("time", time)

            local offsetX = mainchatFrame:GetUserConfig("CTRLSET_OFFSETX")
            -- print(commnderNameUIText)
            tos_google_translate_chat_ctrl(gbox, chatCtrl, label, txt, timeCtrl, offsetX)
            break
        end
    end

end

function tos_google_translate_chat_ctrl(groupbox, chatCtrl, label, txt, timeCtrl, offsetX)

    local chatWidth = groupbox:GetWidth()
    txt:SetTextMaxWidth(groupbox:GetWidth() - 100)
    txt:SetText(txt:GetText())
    label:Resize(chatWidth - offsetX, txt:GetHeight())
    chatCtrl:Resize(chatWidth, label:GetHeight())
    g.ypos = g.ypos + label:GetHeight()

    groupbox:SetScrollPos(99999)

    return 1
end

function tos_google_translate_DRAW_CHAT_MSG(frame, msg)
    tos_google_translate_save_settings()
    local groupboxname, startindex, chatframe = acutil.getEventArgs(msg);
    local size = session.ui.GetMsgInfoSize(groupboxname);
    local msg = session.ui.GetChatMsgInfo(groupboxname, size - 1)

    if g.settings.use == 0 then
        return
    end

    local tempMsg = msg:GetMsg();
    if g.lastmsg == tempMsg then

        return
    else

        g.lastmsg = tempMsg
    end

    local MsgType = msg:GetMsgType()

    if MsgType ~= "Normal" and MsgType ~= "Shout" and MsgType ~= "Party" and MsgType ~= "Guild" then
        return
    end

    local chat_id = msg:GetMsgInfoID();
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

    local cleanedText, extractedTexts = tos_google_translate_extractAndCleanText(modifiedString, chat_id)
    print("clean:" .. cleanedText)
    --[[if cleanedText == " " then
        return
    elseif cleanedText == "" then
        return
    end]]

    local time = msg:GetTimeStr()
    local cmdName = msg:GetCommanderName();
    -- local input = "あじのり [W サーバー]"
    cmdName = cmdName:gsub("%[.*%]", ""):gsub("^%s*(.-)%s*$", "%1")

    tos_google_translate_save_settings()
    local count = #g.settings.chat + 1

    g.settings.chat[count] = {
        chat_id = tostring(chat_id),
        msgtype = MsgType,
        trans_text = cleanedText, -- これは後で翻訳されたテキストに置き換えられる可能性があります
        time = time,
        name = cmdName,
        lang = g.settings.lang

    }
    tos_google_translate_save_settings()
    tos_google_translate_load_output()
    local count = #g.output
    g.size = count

    local frame = ui.GetFrame("tos_google_translate")
    -- tos_google_translate_receive()
    frame:RunUpdateScript("tos_google_translate_receive", 1.0)
    return
end

function tos_google_translate_receive()

    g.gbox = false
    tos_google_translate_load_output()
    local count = #g.output
    local size = count

    if g.size == size then
        -- ReserveScript("tos_google_translate_receive()", 5.0)
        -- print("test")
        return 1
    else
        -- print(size .. ":" .. g.size)
        if next(g.settings.chat) == nil then
            table.remove(g.settings.chat, 1)
            -- 要素を削除した後、テーブルの要素を1から振り直す
            for i, v in ipairs(g.settings.chat) do
                g.settings.chat[i] = v
            end
        end
        tos_google_translate_load_names()
        tos_google_translate_gbox()

    end

end

function tos_google_translate_extractAndCleanText(text, id)

    g.extractedTexts = {
        [1] = id
    } -- 抽出したテキストを格納するテーブル

    local front = string.find(text, "{") -- マッチした文字列の直前の位置を取得
    while front do
        local back = string.find(text, "}", front) + 1 -- マッチした文字列の直後の位置を取得し、追加の5文字分を加える
        local extractedText = string.sub(text, front, back - 1) -- マッチした部分の文字列を抽出
        table.insert(g.extractedTexts, extractedText)

        text = string.sub(text, 1, front - 1) .. string.sub(text, back) -- 不要な部分を削除した文字列を更新

        front = string.find(text, "({)") -- 次のマッチを探す
    end

    --[[for i, extractedText in ipairs(g.extractedTexts) do
        print("抽出したテキスト[" .. i .. "]:" .. extractedText)
    end]]

    return text, g.extractedTexts -- 抽出したテキストを含むテーブルを返す
end

function tos_google_translate_frame_open(frame, ctrl, argStr, argNum)
    local frame = ui.GetFrame("tos_google_translate")
    if frame:IsVisible() == 0 then
        tos_google_translate_frame_init(frame, ctrl, argStr, argNum)
        g.settings.use = 1
    else
        tos_google_translate_frame_close(frame, ctrl, argStr, argNum)
        g.settings.use = 0
    end
    tos_google_translate_save_settings()
end

function tos_google_translate_frame_close(frame, ctrl, argStr, argNum)
    local frame = ui.GetFrame("tos_google_translate")
    frame:ShowWindow(0)
end

function tos_google_translate_start(frame, msg, argStr, argNum)
    -- local exe_path = "../addons/tos_google_translate/tos_google_translate.exe" -- 実行したいPythonスクリプトのパス
    -- local exe_path = "../addons/tos_google_translate/tos_google_translate.py" -- 実行したいPythonスクリプトのパス
    -- os.remove(exe_path)
    if not g.loaded then
        local command = string.format('start "" "%s"', exe_path)
        -- os.execute(command)
        g.loaded = true

    end

    tos_google_translate_frame_init()

end

function tos_google_translate_load_settings()

    local settings, err = acutil.loadJSON(g.settingsFileLoc, g.settings)

    if err then
        -- 設定ファイル読み込み失敗時処理
        CHAT_SYSTEM(string.format("[%s] cannot load setting files", addonNameLower))
    end
    local mySession = session.GetMyHandle();
    local myTeamName = info.GetFamilyName(mySession);

    local langCode = option.GetCurrentCountry()
    if langCode == "Japanese" then
        langCode = "ja"
        -- langCode = "ko"
    elseif langCode == "Korean" then
        langCode = "ko"
    else
        langCode = "en"
    end

    if not settings then
        -- 設定ファイルが存在しない場合、デフォルトの設定を作成
        g.settings = {
            chat = {},
            use = 1,
            lang = langCode
        }
        g.settings.chat[1] = {
            chat_id = "1",
            lang = langCode,
            name = myTeamName,
            trans_text = "Tos Google Translate Start",
            msgtype = "System",
            time = " "
        }
    elseif g.loaded == false then
        local use = settings.use
        g.settings = {
            chat = {},
            use = use,
            lang = langCode
        }
        g.settings.chat[1] = {
            chat_id = "1",
            lang = langCode,
            name = myTeamName,
            trans_text = "Tos Google Translate Start",
            msgtype = "System",
            time = " "
        }

    else
        -- 設定ファイルが存在する場合、その内容を使用
        g.settings = settings
    end

    -- 設定を保存
    tos_google_translate_save_settings()

    ReserveScript("tos_google_translate_load_names()", 0.5)

    return

end

function tos_google_translate_load_names()

    local names, err = acutil.loadJSON(g.namesFileLoc, g.names)

    if err then
        -- 設定ファイル読み込み失敗時処理
        -- CHAT_SYSTEM(string.format("[%s] cannot load setting files", addonNameLower))
    end
    local mySession = session.GetMyHandle();
    local myTeamName = info.GetFamilyName(mySession);
    if not names then
        -- 設定ファイルが存在しない場合、デフォルトの設定を作成
        g.names = {
            myTeamName = myTeamName
        }
    else
        -- 設定ファイルが存在する場合、その内容を使用
        g.names = names
    end

    if g.gbox then
        for org_name, ts_name in pairs(g.names) do

            if ts_name == "" then
                g.names[org_name] = nil -- キーを削除する
            end
            if ts_name == "---" then

                g.names[org_name] = nil -- キーを削除する
            end
            if WITH_HANGLE(org_name) then
                if ts_name == org_name then
                    g.names[org_name] = nil -- キーを削除する
                end

            end
            if WITH_HANGLE(ts_name) then

                g.names[org_name] = nil -- キーを削除する

            end
        end
        acutil.saveJSON(g.namesFileLoc, g.names)
        ReserveScript("tos_google_translate_load_output()", 0.5)
    end
end

function tos_google_translate_load_output()

    local output, err = acutil.loadJSON(g.outputFileLoc, g.output)

    if err then
        -- 設定ファイル読み込み失敗時処理
        -- CHAT_SYSTEM(string.format("[%s] cannot load setting files", addonNameLower))
    end
    local mySession = session.GetMyHandle();
    local myTeamName = info.GetFamilyName(mySession);
    if not output or next(output) == nil then
        g.output = {}
        -- 設定ファイルが存在しない場合、デフォルトの設定を作成
        --[[g.output["1"] = {
            org_name = myTeamName,
            trans_text = "Tos Google Translate Start",
            msgtype = "System",
            time = " "
        }]]
    else
        -- 設定ファイルが存在する場合、その内容を使用
        g.output = output
    end
    acutil.saveJSON(g.outputFileLoc, g.output)
    if g.gbox then
        ReserveScript("tos_google_translate_load_temp()", 0.5)
    end
    return
end

function tos_google_translate_load_temp()

    local temp, err = acutil.loadJSON(g.tempFileLoc, g.temp)

    if err then
        -- 設定ファイル読み込み失敗時処理
        -- CHAT_SYSTEM(string.format("[%s] cannot load setting files", addonNameLower))
    end

    if not temp then
        g.temp = {}
    end
    acutil.saveJSON(g.tempFileLoc, g.temp)
    ReserveScript("tos_google_translate_load_ttemp()", 0.5)
end

function tos_google_translate_load_ttemp()

    local ttemp, err = acutil.loadJSON(g.ttempFileLoc, g.ttemp)

    if err then
        -- 設定ファイル読み込み失敗時処理
        -- CHAT_SYSTEM(string.format("[%s] cannot load setting files", addonNameLower))
    end

    if not ttemp or next(ttemp) == nil then
        g.ttemp = {
            send = {},
            recv = {},
            name = {}
        }
    end
    acutil.saveJSON(g.ttempFileLoc, g.ttemp)

    ReserveScript("tos_google_translate_start()", 0.5)
end

function tos_google_translate_save_settings()
    acutil.saveJSON(g.settingsFileLoc, g.settings)
end
--[[local function WITH_HANGLE(str)
    local size = #str
    local i = 1

    while i <= size do
        local byt = string.byte(str, i)
        local inc = 1

        if (byt & 0x80) == 0x00 then
            inc = 1
        elseif (byt & 0xE0) == 0xC0 then
            inc = 2
        elseif (byt & 0xF0) == 0xE0 then
            inc = 3
        elseif (byt & 0xF8) == 0xF0 then
            inc = 4
        elseif (byt & 0xFC) == 0xF8 then
            inc = 5
        elseif (byt & 0xFE) == 0xFC then
            inc = 6
        end

        local code = byt & (0xFF >> (inc + 1)) -- コードポイントの計算

        if inc > 1 then
            for j = 2, inc do
                byt = string.byte(str, i + j - 1)
                code = (code << 6) | (byt & 0x3F)
            end
        end

        if code >= 0xAC00 and code <= 0xD7A3 then
            return true -- ハングルの範囲に含まれる
        end

        i = i + inc
    end

    return false -- ハングルの文字が含まれない
end]]
