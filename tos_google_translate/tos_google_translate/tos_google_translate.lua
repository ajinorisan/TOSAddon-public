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

    end

    tos_google_translate_load_settings()

end

function tos_google_translate_frame_init(frame, ctrl, argStr, argNum)
    acutil.setupEvent(g.addon, "DRAW_CHAT_MSG", "tos_google_translate_DRAW_CHAT_MSG");
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
        tos_google_translate_gbox()
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
    end
    acutil.saveJSON(g.namesFileLoc, g.names)

    local sorted_keys = {}

    for k in pairs(g.output) do
        table.insert(sorted_keys, tonumber(k))

    end
    table.sort(sorted_keys)

    local trans_name = ""
    local translate_text = ""

    g.ypos = 0
    for _, k in ipairs(sorted_keys) do

        if k == 0 then
            return
        end
        local v = g.output[tostring(k)]

        local org_name = v.org_name
        local trans_text = v.trans_text
        local msgtype = v.msgtype

        local time = v.time

        local replaced_name = g.names[org_name] or org_name

        local clustername = "cluster_" .. k
        local marginLeft = 20
        local marginRight = 0
        local commnderNameUIText = replaced_name .. " : " .. trans_text
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
        end
        local fontSize = GET_CHAT_FONT_SIZE()
        txt:SetTextByKey("font", fontStyle)
        txt:SetTextByKey("size", fontSize)
        txt:SetTextByKey("text", msgFront)
        timeCtrl:SetTextByKey("time", time)

        local offsetX = mainchatFrame:GetUserConfig("CTRLSET_OFFSETX")
        -- print(commnderNameUIText)
        tos_google_translate_chat_ctrl(gbox, chatCtrl, label, txt, timeCtrl, offsetX)
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
    local childCount = groupbox:GetChildCount() - 1

    return 0
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

function tos_google_translate_extractAndCleanText(text)
    local extractedTexts = {} -- 抽出したテキストを格納するテーブル

    local front = string.find(text, "{") -- マッチした文字列の直前の位置を取得
    while front do
        local back = string.find(text, "}", front) + 1 -- マッチした文字列の直後の位置を取得し、追加の5文字分を加える
        local extractedText = string.sub(text, front, back - 1) -- マッチした部分の文字列を抽出
        table.insert(extractedTexts, extractedText)

        text = string.sub(text, 1, front - 1) .. string.sub(text, back) -- 不要な部分を削除した文字列を更新

        front = string.find(text, "({)") -- 次のマッチを探す
    end
    --[[for i, extractedText in ipairs(extractedTexts) do
        print("抽出したテキスト[" .. i .. "]:" .. extractedText)
    end]]

    return text, extractedTexts -- 抽出したテキストを含むテーブルを返す
end

function tos_google_translate_DRAW_CHAT_MSG(frame, msg)

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

    local cleanedText, extractedTexts = tos_google_translate_extractAndCleanText(tempMsg)
    if cleanedText == " " then
        return
    end

    local chat_id = msg:GetMsgInfoID();
    local time = msg:GetTimeStr()
    local cmdName = msg:GetCommanderName();

    local langCode = option.GetCurrentCountry()
    if langCode == "Japanese" then
        langCode = "ja"
    elseif langCode == "Korean" then
        langCode = "ko"
    else
        langCode = "en"
    end
    local use = g.settings.use

    g.settings = {
        chat_id = tostring(chat_id),
        msgtype = MsgType,
        trans_text = cleanedText, -- これは後で翻訳されたテキストに置き換えられる可能性があります
        time = time,
        name = cmdName,
        lang = langCode,
        use = use

    }
    tos_google_translate_save_settings()

    tos_google_translate_load_output()
    local keys = {}

    for k in pairs(g.output) do
        if k ~= "0" then
            table.insert(keys, tonumber(k))
        end
    end
    g.size = #keys
    local frame = ui.GetFrame("tos_google_translate")
    frame:RunUpdateScript("tos_google_translate_receive", 1.0)
    return
end

function tos_google_translate_receive()

    g.gbox = false
    tos_google_translate_load_output()
    local keys = {}

    for k in pairs(g.output) do
        if k ~= "0" then
            table.insert(keys, tonumber(k))
        end
    end
    local size = #keys

    if size == 1 then
        if g.output["0"] ~= nil then
            g.output["0"] = nil
            acutil.saveJSON(g.outputFileLoc, g.output)

            -- ReserveScript("tos_google_translate_receive()", 5.0)
            return 1
        end
    end
    if g.size == size then
        -- ReserveScript("tos_google_translate_receive()", 5.0)
        return 1
    else
        tos_google_translate_load_names()
        tos_google_translate_gbox()

    end
    -- tos_google_translate_load_names()
    -- tos_google_translate_gbox()

end

function tos_google_translate_start(frame, msg, argStr, argNum)
    local exe_path = "../addons/tos_google_translate/tos_google_translate.exe" -- 実行したいPythonスクリプトのパス
    -- local exe_path = "../addons/tos_google_translate/tos_google_translate.py" -- 実行したいPythonスクリプトのパス
    -- os.remove(exe_path)
    if not g.loaded then
        local command = string.format('start "" "%s"', exe_path)
        os.execute(command)
        g.loaded = true
        print("start")
    end
    tos_google_translate_frame_init()

end

function tos_google_translate_load_settings()

    local settings, err = acutil.loadJSON(g.settingsFileLoc, g.settings)

    if err then
        -- 設定ファイル読み込み失敗時処理
        CHAT_SYSTEM(string.format("[%s] cannot load setting files", addonNameLower))
    end
    if not settings then
        -- 設定ファイルが存在しない場合、デフォルトの設定を作成
        g.settings = {
            lang = "ja",
            chat_id = "0",
            name = "",
            trans_text = "",
            msgtype = "",
            time = "",
            use = 1
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
    acutil.saveJSON(g.namesFileLoc, g.names)
    if g.gbox then
        ReserveScript("tos_google_translate_load_output()", 0.5)
    end
end

function tos_google_translate_load_output()

    local output, err = acutil.loadJSON(g.outputFileLoc, g.output)

    if err then
        -- 設定ファイル読み込み失敗時処理
        -- CHAT_SYSTEM(string.format("[%s] cannot load setting files", addonNameLower))
    end
    if not output or next(output) == nil then
        g.output = {}
        -- 設定ファイルが存在しない場合、デフォルトの設定を作成
        g.output["0"] = {
            name = "",
            trans_text = "",
            msgtype = "",
            time = ""
        }
    else
        -- 設定ファイルが存在する場合、その内容を使用
        g.output = output
    end
    acutil.saveJSON(g.outputFileLoc, g.output)
    if g.gbox then
        ReserveScript("tos_google_translate_start()", 0.5)
    end
    return
end

function tos_google_translate_save_settings()
    acutil.saveJSON(g.settingsFileLoc, g.settings)
end
