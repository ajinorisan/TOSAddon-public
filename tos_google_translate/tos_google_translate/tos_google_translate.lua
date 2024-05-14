-- v0.9.0 とりあえず公開
-- v0.9.1 重すぎたので手動更新を付けた。
-- v0.9.2 重すぎるの直した。パーティーインフォも翻訳後の名前になる様に変更
-- v0.9.3 時間経過と共に重くなっていく原因わかった。20チャット制限で過去は消していくようにした。
local addonName = "TOS_GOOGLE_TRANSLATE"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "0.9.3"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)
g.namesFileLoc = string.format('../addons/%s/%s/names.json', addonNameLower, addonNameLower)
g.outputFileLoc = string.format('../addons/%s/%s/output.json', addonNameLower, addonNameLower)
g.tempFileLoc = string.format('../addons/%s/%s/temp.json', addonNameLower, addonNameLower)
g.sendFileLoc = string.format('../addons/%s/%s/send.json', addonNameLower, addonNameLower)
g.noticeFileLoc = string.format('../addons/%s/%s/notice.json', addonNameLower, addonNameLower)
g.restartFileLoc = string.format('../addons/%s/restart.bat', addonNameLower)

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
    g.extractedTexts = g.extractedTexts or {} -- 抽出したテキストを格納するテーブル

    tos_google_translate_load_settings()
    acutil.slashCommand("/tos_google_translate", tos_google_translate_restart);
    acutil.slashCommand("/tgt", tos_google_translate_restart);
    g.SetupHook(tos_google_translate_REQ_TRANSLATE_TEXT, "REQ_TRANSLATE_TEXT")
    g.SetupHook(tos_google_translate_SET_PARTYINFO_ITEM, "SET_PARTYINFO_ITEM")

    --[[local functionName = _G['ADDONS']['TOUKIBI']['KoJa_Name_Translater'].Switch_NamePlate
    if functionName ~= nil and type(functionName) == "function" then

        local pc = GetMyPCObject();
        local curMap = GetZoneName(pc)
        local mapCls = GetClass("Map", curMap)
        if mapCls.MapType ~= "City" then
            _G['ADDONS']['TOUKIBI']['KoJa_Name_Translater'].Switch_NamePlate()
        else
            _G['ADDONS']['TOUKIBI']['KoJa_Name_Translater'].Restore_NamePlate()
        end

    end]]

end

function tos_google_translate_koja()

    local kojaFileLoc = string.format('../addons/%s/MemoriseData.dat', "koja_name_translater")
    local koja = io.open(kojaFileLoc, "r")
    local content = koja:read("*all")
    koja:close()
    tos_google_translate_load_names()
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

end

function tos_google_translate_REQ_TRANSLATE_TEXT(frameName, gbName, ctrlName)
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
        ui.SysMsg(tos_google_translate_lang("Tos Google Translate frame must be closed before you can translate."))
        return
    end
end

function tos_google_translate_lang(str)

    local langCode = option.GetCurrentCountry()
    if langCode == "Japanese" then

        if str == "Left click: Opens and closes the translation chat window.{nl}" ..
            "Automatic translation stops while it is not open.{nl}" ..
            "Right click: Force reload of the translation chat window." then
            str = "左クリック：翻訳チャットウィンドウを開いたり閉じたりします。{nl}" ..
                      "開いてない間は自動翻訳停止します。{nl}" ..
                      "右クリック：強制的に翻訳チャットウィンドウを再読み込みします。"
        end

        if str == "[Tos Google Translate]{nl}" ..
            "/addons/tos_google_translate/tos_google_translate/tos_google_translate.exe{nl}" .. "cannot be found. Exit." then
            str = "[Tos Google Translate]{nl}" ..
                      "/addons/tos_google_translate/tos_google_translate/tos_google_translate.exe{nl}" ..
                      "が見つけられません。終了します。"
        end

        if str ==
            "Please run the restart.bat file in the Tree Of Savior'-'addons'-'tos_google_translate' folder with administrator privileges and then go back to the barracks once" then
            str =
                "Tree Of Savior'-'addons'-'tos_google_translateフォルダにあるrestart.batを管理者権限で実行してからバラックに一度戻ってください。"
        end

        if str == "Tos Google Translate frame must be closed before you can translate." then
            str = "Tos Google Translate フレームを閉じてから翻訳してください。"
        end
        return str
    elseif langCode == "Korean" then

        if str == "Left click: Opens and closes the translation chat window.{nl}" ..
            "Automatic translation stops while it is not open.{nl}" ..
            "Right click: Force reload of the translation chat window." then
            str = "왼쪽 클릭: 번역 채팅 창을 열거나 닫습니다.{nl}" ..
                      " 열려있지 않은 상태에서는 자동 번역이 중지됩니다.{nl}" ..
                      "오른쪽 클릭: 번역 채팅창을 강제로 다시 불러옵니다."
        end

        if str == "[Tos Google Translate]{nl}" ..
            "/addons/tos_google_translate/tos_google_translate/tos_google_translate.exe{nl}" .. "cannot be found. Exit." then
            str = "[Tos Google Translate]{nl}" ..
                      "/addons/tos_google_translate/tos_google_translate/tos_google_translate/tos_google_translate.exe{nl}" ..
                      "를 찾을 수 없습니다. 종료합니다."
        end

        if str ==
            "Please run the restart.bat file in the Tree Of Savior'-'addons'-'tos_google_translate' folder with administrator privileges and then go back to the barracks once" then
            str =
                "Tree Of Savior'-'addons'-'tos_google_translate 폴더에 있는 restart.bat를 관리자 권한으로 실행한 후, 다시 한번 Barracks로 돌아와주세요."
        end
        if str == "Tos Google Translate frame must be closed before you can translate." then
            str = "Tos Google Translate 프레임을 닫은 후 번역하세요."
        end
        return str
    else
        return str
    end

end

function tos_google_translate_restart()
    ui.SysMsg(tos_google_translate_lang(
        "Please run the restart.bat file in the Tree Of Savior'-'addons'-'tos_google_translate' folder with administrator privileges and then go back to the barracks once"))
    local batch_script = [[
                @echo off
                :: コマンドを管理者権限で実行するためのバッチファイル
                
                taskkill /F /IM tos_google_translate-v1.0.0.exe
                ]]

    -- バッチファイルを作成する
    local file = io.open(g.restartFileLoc, "w")
    file:write(batch_script)
    file:close()
    g.extractedTexts = {}
    g.loaded = false
end

function tos_google_translate_extractAndCleanText(text, id)

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

function tos_google_translate_msg_del()
    -- 元のsend_file内の内容を読み込む
    local send_data = {}
    local send_file = io.open(g.sendFileLoc, "r")
    local send_json = send_file:read("*a")
    send_data = json.decode(send_json)
    send_file:close()

    -- g.settings["chat"]と元のsend_file内の内容を組み合わせて1つの配列にする
    local combined_data = {}
    for _, entry in ipairs(send_data) do
        table.insert(combined_data, entry)
    end

    for _, entry in ipairs(g.settings["chat"]) do
        table.insert(combined_data, entry)
    end
    -- エンコードされたJSONデータをファイルに書き込む
    local combined_json = json.encode(combined_data)
    -- g.settings["chat"]を空にする
    g.settings["chat"] = {}
    tos_google_translate_save_settings()

    -- エンコードされたJSONデータをファイルに書き込む
    local send_file = io.open(g.sendFileLoc, "w")
    send_file:write(combined_json)
    send_file:close() -- ファイルを閉じる

end

function tos_google_translate_DRAW_CHAT_MSG(frame, msg)

    if g.settings.use == 0 then
        return
    end

    local groupboxname, startindex, chatframe = acutil.getEventArgs(msg);
    local size = session.ui.GetMsgInfoSize(groupboxname);
    local msg = session.ui.GetChatMsgInfo(groupboxname, size - 1)

    local MsgType = msg:GetMsgType()
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

    local cmdName = msg:GetCommanderName();
    local tempMsg = msg:GetMsg();
    local lastmsg = cmdName .. ":" .. tempMsg
    if g.lastmsg == lastmsg then

        return
    else

        g.lastmsg = lastmsg
    end
    for i = startindex, size - 1 do
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

        local time = msg:GetTimeStr()
        cmdName = msg:GetCommanderName();
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
        tos_google_translate_msg_del()
        local output = io.open(g.outputFileLoc, "r")
        local content = output:read("*all")
        output:close()
        g.output = json.decode(content)
        g.count = #g.output

        -- local frame = ui.GetFrame("tos_google_translate")
        -- frame:RunUpdateScript("tos_google_translate_receive", 2.0);
    end

end

function tos_google_translate_receive(frame)

    if g.settings.use == 0 then
        return 0
    end

    local output = io.open(g.outputFileLoc, "r")
    local content = output:read("*all")
    output:close()
    local json = json.decode(content)
    local count = #json

    if g.count ~= count then
        -- g.count = g.count + 1
        -- print("g.count:" .. g.count .. ":" .. "count:" .. count)
        g.gbox = false
        g.output = json
        -- tos_google_translate_load_names()
        tos_google_translate_gbox(frame)

        -- テーブルの要素数が30以上の場合、最初の1個目を削除する
        if #g.output >= 20 then
            table.remove(g.output, 1)
        else
            g.count = g.count + 1
        end
        acutil.saveJSON(g.outputFileLoc, g.output)
        -- tos_google_translate_save_settings()
        return 0

    else
        return 1
    end

end

function tos_google_translate_frame_init(frame, ctrl, argStr, argNum)

    acutil.setupEvent(g.addon, "DRAW_CHAT_MSG", "tos_google_translate_DRAW_CHAT_MSG");
    g.addon:RegisterMsg("FPS_UPDATE", "tos_google_translate_receive");
    local chatframe = ui.GetFrame("chatframe")
    local tabgbox = GET_CHILD_RECURSIVELY(chatframe, "tabgbox")
    local trans = tabgbox:CreateOrGetControl("button", "trans", 270, -3, 30, 30)
    AUTO_CAST(trans)
    trans:SetSkinName("test_red_button")

    trans:SetText("{ol}{s14}{#FFFFFF}" .. g.settings["lang"])
    trans:SetEventScript(ui.LBUTTONUP, "tos_google_translate_frame_open")
    trans:SetEventScript(ui.RBUTTONUP, "tos_google_translate_gbox")
    trans:SetTextTooltip(tos_google_translate_lang("Left click: Opens and closes the translation chat window.{nl}" ..
                                                       "Automatic translation stops while it is not open.{nl}" ..
                                                       "Right click: Force reload of the translation chat window."))
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
        tos_google_translate_gbox(frame)
    else
        return
    end

end

function tos_google_translate_rbtn()
    local file = io.open(g.noticeFileLoc, "r")
    if file then
        -- ファイルが存在する場合の処理
        file:close()

    else
        -- ファイルが存在しない場合の処理
        local newFile = io.open(g.noticeFileLoc, "w")
        if newFile then
            newFile:close()
            local frame = ui.GetFrame("tos_google_translate")
            tos_google_translate_receive(frame)

        end
    end
end

function tos_google_translate_gbox(frame)

    local mainchatFrame = ui.GetFrame("chatframe")

    local tgtframe = ui.GetFrame("tos_google_translate")
    local gbox = GET_CHILD(tgtframe, "gbox")
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
            for i, extractedTexts in pairs(g.extractedTexts) do
                if chat_id == i then
                    for j, extractedText in ipairs(extractedTexts) do
                        -- print("抽出したテキスト[" .. i .. "][" .. j .. "]:" .. extractedText)
                        commnderNameUIText = commnderNameUIText .. extractedText
                    end
                end
            end

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

            tos_google_translate_chat_ctrl(frame, gbox, chatCtrl, label, txt, timeCtrl, offsetX)
            break
        end
    end

end

function tos_google_translate_chat_ctrl(frame, groupbox, chatCtrl, label, txt, timeCtrl, offsetX)

    local chatWidth = groupbox:GetWidth()
    txt:SetTextMaxWidth(groupbox:GetWidth() - 100)
    txt:SetText(txt:GetText())
    label:Resize(chatWidth - offsetX, txt:GetHeight())
    chatCtrl:Resize(chatWidth, label:GetHeight())
    g.ypos = g.ypos + label:GetHeight()

    groupbox:SetScrollPos(99999)
    -- g.count = g.count + 1
    os.remove(g.noticeFileLoc)
    return
end

function tos_google_translate_frame_open(frame, ctrl, argStr, argNum)
    local frame = ui.GetFrame("tos_google_translate")
    if frame:IsVisible() == 0 then
        frame:ShowWindow(1)
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
    local exe_path = "../addons/tos_google_translate/tos_google_translate/tos_google_translate-v1.0.0.exe" -- 実行したいPythonスクリプトのパス

    local file = io.open(exe_path, "r")
    if file then
        if not g.loaded then
            local command = string.format('start "" "%s"', exe_path)
            os.execute(command)
            g.loaded = true

        end
        file:close()
        tos_google_translate_frame_init()
    else
        ui.SysMsg(tos_google_translate_lang("[Tos Google Translate]{nl}" ..
                                                "/addons/tos_google_translate/tos_google_translate/tos_google_translate.exe{nl}" ..
                                                "cannot be found. Exit."))
        return
    end

end

function tos_google_translate_load_settings()

    local settings = acutil.loadJSON(g.settingsFileLoc, g.settings)

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
        settings = {
            chat = {},
            use = 1,
            lang = langCode
        }

        local file = io.open(g.settingsFileLoc, "w")
        local s = json.encode(settings)
        file:write(s)
        file:close()
    end

    if not g.loaded then
        local use = settings.use
        -- 設定ファイルが存在しない場合、デフォルトの設定を作成
        settings = {
            chat = {},
            use = use,
            lang = langCode
        }

        local file = io.open(g.settingsFileLoc, "w")
        local s = json.encode(settings)
        file:write(s)
        file:close()

    end

    if settings then
        local file = io.open(g.settingsFileLoc, "w")
        local s = json.encode(settings)
        file:write(s)
        file:close()
    end
    g.settings = settings
    ReserveScript("tos_google_translate_load_output()", 0.2)

    return
end

function tos_google_translate_load_output()
    local output = acutil.loadJSON(g.outputFileLoc, g.output)

    if not output then

        output = {}

        local file = io.open(g.outputFileLoc, "w")
        local s = json.encode(output)
        file:write(s)
        file:close()

    elseif not g.loaded then
        output = {}

        local file = io.open(g.outputFileLoc, "w")
        local s = json.encode(output)
        file:write(s)
        file:close()

    end
    g.output = output
    if g.gbox then
        ReserveScript("tos_google_translate_load_temp()", 0.2)
    end
end

function tos_google_translate_load_temp()
    local temp = acutil.loadJSON(g.tempFileLoc, g.temp)

    if not temp then
        -- 設定ファイルが存在しない場合、デフォルトの設定を作成
        temp = {}

        local file = io.open(g.tempFileLoc, "w")
        local s = json.encode(temp)
        file:write(s)
        file:close()

    elseif not g.loaded then
        temp = {}

        local file = io.open(g.tempFileLoc, "w")
        local s = json.encode(temp)
        file:write(s)
        file:close()
    elseif temp then
        local file = io.open(g.tempFileLoc, "w")
        local s = json.encode(temp)
        file:write(s)
        file:close()
    end
    ReserveScript("tos_google_translate_load_send()", 0.2)
end

function tos_google_translate_load_send()
    local send = acutil.loadJSON(g.sendFileLoc, g.send)

    if not send then
        -- 設定ファイルが存在しない場合、デフォルトの設定を作成
        send = {}

        local file = io.open(g.sendFileLoc, "w")
        local s = json.encode(send)
        file:write(s)
        file:close()

    elseif not g.loaded then
        send = {}

        local file = io.open(g.sendFileLoc, "w")
        local s = json.encode(send)
        file:write(s)
        file:close()
    elseif send then
        local file = io.open(g.sendFileLoc, "w")
        local s = json.encode(send)
        file:write(s)
        file:close()
    end
    ReserveScript("tos_google_translate_load_names()", 0.2)
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

function tos_google_translate_load_names()

    local names = acutil.loadJSON(g.namesFileLoc, g.names)

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
            if string.match(org_name, "[%a%d]+") then
                g.names[org_name] = org_name
            end
        end
        acutil.saveJSON(g.namesFileLoc, g.names)

        ReserveScript("tos_google_translate_start()", 0.2)
    end
end

function tos_google_translate_save_settings()
    acutil.saveJSON(g.settingsFileLoc, g.settings)
end

function tos_google_translate_SET_PARTYINFO_ITEM(frame, msg, partyMemberInfo, count, makeLogoutPC, leaderFID,
    isCorsairType, ispipui, partyID)

    if partyID ~= nil and partyMemberInfo ~= nil and partyID ~= partyMemberInfo:GetPartyID() then
        return nil;
    end
    -- test()
    local partyinfoFrame = ui.GetFrame('partyinfo')
    local FAR_MEMBER_FACE_COLORTONE = partyinfoFrame:GetUserConfig("FAR_MEMBER_FACE_COLORTONE")
    local NEAR_MEMBER_FACE_COLORTONE = partyinfoFrame:GetUserConfig("NEAR_MEMBER_FACE_COLORTONE")
    local FAR_MEMBER_NAME_FONT_COLORTAG = partyinfoFrame:GetUserConfig("FAR_MEMBER_NAME_FONT_COLORTAG")
    local NEAR_MEMBER_NAME_FONT_COLORTAG = partyinfoFrame:GetUserConfig("NEAR_MEMBER_NAME_FONT_COLORTAG")

    local mapName = geMapTable.GetMapName(partyMemberInfo:GetMapID());
    local partyMemberName = partyMemberInfo:GetName();
    for key, value in pairs(g.names) do
        if key == partyMemberName then
            partyMemberName = value

            break
        end
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
--[[local langCode = option.GetCurrentCountry()
    -- if (option.GetCurrentCountry() == "Japanese") then
    if langCode ~= "Korean" then

        text = dictionary.ReplaceDicIDInCompStr(text)
        text = string.gsub(text, "{/}", "")

        local function replaceAll(text, pattern, replacement)
            local result = text
            local startPos, endPos = string.find(pattern)
            while startPos do
                result = result:sub(1, startPos - 1) .. replacement .. result:sub(endPos + 1)
                startPos, endPos = string.find(pattern, endPos + 1)
            end
            return result
        end

        local replacedText = replaceAll(text, "%(", "{")
        replacedText = replaceAll(replacedText, "%)", "}")
        --[[local start, finish = string.find(text, "%(")
        if start then
            text = text:sub(1, start - 1) .. "{" .. text:sub(start + 1)
            local next_brace_start = string.find(text, "%{", finish + 1)
            text = text:sub(1, next_brace_start - 1) .. text:sub(next_brace_start + 1)
            next_brace_start = string.find(text, "%)", finish + 1)
            text = text:sub(1, next_brace_start - 1) .. text:sub(next_brace_start + 1)
        else
            print("aru")
        end
    end]]

-- print(text)
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

--[[local function test()
    local selectedObjects, selectedObjectsCount = SelectObject(GetMyPCObject(), 1000, "ALL");
    for i = 1, selectedObjectsCount do
        local handle = GetHandle(selectedObjects[i]);
        if handle ~= nil then
            if info.IsPC(handle) == 1 then
                local FrameName = "charbaseinfo1_" .. handle;
                local pcTxtFrame = ui.GetFrame(FrameName);
                if pcTxtFrame ~= nil then
                    local frameFamilyName = pcTxtFrame:GetChild("familyName");
                    AUTO_CAST(frameFamilyName)
                    local fName = frameFamilyName:GetText()
                    local result = fName:gsub("{.-}", "") -- {}で囲まれた部分を削除

                    for key, value in pairs(g.names) do

                        if key == result then
                            local frameGivenName = pcTxtFrame:GetChild("givenName");
                            AUTO_CAST(frameGivenName)
                            if nil ~= frameGivenName then
                                frameGivenName:SetText("");

                            end
                            frameFamilyName:SetText(value)
                            local BeforeMargin = frameFamilyName:GetMargin();

                            frameFamilyName:SetMargin(150, BeforeMargin.top, 0, 0);
                            break
                        end
                    end
                end
            end
        end
    end

end]]
--[[function tos_google_translate_msg_del()

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

        end
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
        end

        -- 元のテーブルを空にする
        -- g.settings["chat"] = {}

        -- 設定を保存する
        -- tos_google_translate_save_settings()
    end
end]]
