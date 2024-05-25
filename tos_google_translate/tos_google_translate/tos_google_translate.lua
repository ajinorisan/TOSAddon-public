-- v0.9.0 とりあえず公開
-- v0.9.1 重すぎたので手動更新を付けた。
-- v0.9.2 重すぎるの直した。パーティーインフォも翻訳後の名前になる様に変更
-- v0.9.3 時間経過と共に重くなっていく原因わかった。20チャット制限で過去は消していくようにした。
-- v0.9.4 韓国鯖の判定"Korean"だったのを"kr"に変更。マジか。
-- v0.9.5 チャットオプションの表示非表示を切り替えたら激重になるのを修正
-- v0.9.6 多分出来た。一旦安定版
-- v0.9.7 再起動系のところバグってたの修正
-- v0.9.8 フレーム消えてたの修正
-- v0.9.9 置き換えモード追加
-- v1.0.0 パーティーメンバーの翻訳が上手くいかなかったのを修正
local addonName = "TOS_GOOGLE_TRANSLATE"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.0.0"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)
g.namesFileLoc = string.format('../addons/%s/%s/names.dat', addonNameLower, addonNameLower)
g.sendFileLoc = string.format('../addons/%s/%s/send.json', addonNameLower, addonNameLower)
g.noticeFileLoc = string.format('../addons/%s/%s/notice.dat', addonNameLower, addonNameLower)
g.restartFileLoc = string.format('../addons/%s/%s/restart.dat', addonNameLower, addonNameLower)

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

    g.extractedTexts = g.extractedTexts or {} -- 抽出したテキストを格納するテーブル

    tos_google_translate_load_settings()

    acutil.slashCommand("/tos_google_translate", tos_google_translate_restart);
    acutil.slashCommand("/tgt", tos_google_translate_restart);
    g.SetupHook(tos_google_translate_REQ_TRANSLATE_TEXT, "REQ_TRANSLATE_TEXT")
    g.SetupHook(tos_google_translate_SET_PARTYINFO_ITEM, "SET_PARTYINFO_ITEM")
    g.SetupHook(tos_google_translate_CHAT_TAB_BTN_CLICK, "CHAT_TAB_BTN_CLICK")
    g.SetupHook(tos_google_translate_DAMAGE_METER_GAUGE_SET, "DAMAGE_METER_GAUGE_SET")
    addon:RegisterMsg("GAME_START", "tos_google_translate_koja");
    addon:RegisterMsg("GAME_START_3SEC", "tos_google_translate_name_trans");

end

function tos_google_translate_koja()

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
                        print("重複したキーをスキップ: " .. key)
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
                print("ファイルの書き込みに失敗しました。")
            end
        else
            print("ファイルを開くことができませんでした。")
        end

    end
end

function tos_google_translate_DAMAGE_METER_GAUGE_SET(ctrl, leftStr, point, rightStr, skin)
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
function tos_google_translate_CHAT_TAB_BTN_CLICK(parent, ctrl)
    if g.settings.use ~= 0 then

        ui.SysMsg(tos_google_translate_lang("Tos Google Translate must be stopped before switching."))
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

function tos_google_translate_name_trans()
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
        print("tempname.datファイルの作成に失敗しました。")
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
        ui.SysMsg(tos_google_translate_lang("Tos Google Translate must be stopped before translating."))
        return
    end
end

function tos_google_translate_lang(str)
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

function tos_google_translate_DRAW_CHAT_MSG(frame, msg)

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

    local MsgType = chat:GetMsgType()
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

        local cleanedText, extractedTexts = tos_google_translate_extractAndCleanText(modifiedString, chat_id)
        -- print(cleanedText)
        local time = chat:GetTimeStr()
        cmdName = chat:GetCommanderName();
        -- local input = "あじのり [W サーバー]"
        cmdName = cmdName:gsub("%[.*%]", ""):gsub("^%s*(.-)%s*$", "%1")

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
        -- frame:RunUpdateScript("tos_google_translate_receive", 1)
    end

end

function tos_google_translate_receive()

    if g.settings.use == 0 then
        return 0
    end
    local tempnameFileLoc = string.format('../addons/%s/%s/tempname.dat', addonNameLower, addonNameLower)
    local file = io.open(tempnameFileLoc, "r")
    if not file then
        if g.tempname_tame == 1 then
            tos_google_translate_load_names_table()
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
        tos_google_translate_gbox(output)
        --[[local tgtframe = ui.GetFrame("tos_google_translate")
        local groupbox = GET_CHILD(tgtframe, "gbox")
        g.curLine = groupbox:GetCurLine()]]

        return
    else
        return
    end
end

function tos_google_translate_context()
    local context = ui.CreateContextMenu("tos_google_translate_context", "Tos Google Translate", 0, 0, 200, 0)
    local strScp = string.format("tos_google_translate_restart()")
    ui.AddContextMenuItem(context, "Restart", strScp)
    strScp = string.format("tos_google_translate_replacement()")
    ui.AddContextMenuItem(context, "Replace Mode", strScp)
    strScp = string.format("tos_google_translate_frame_open()")
    ui.AddContextMenuItem(context, "Frame Open & Start", strScp)
    strScp = string.format("tos_google_translate_frame_close()")
    ui.AddContextMenuItem(context, "Frame Close & Stop", strScp)
    ui.OpenContextMenu(context)
end

function tos_google_translate_restart()
    ui.SysMsg(tos_google_translate_lang("Tos Google Translate initialize. Please return to the barracks."))
    local frame = ui.GetFrame("tos_google_translate")

    local file = io.open(g.restartFileLoc, "w")
    file:write("restart")
    file:close()

    -- g.extractedTexts = {}

    g.loaded = false
    g.size = 0
    frame:RemoveAllChild()
    tos_google_translate_frame_init()
    local file = io.open(g.noticeFileLoc, "w")
    if file then
        file:write("")
        file:close()
    end

end

function tos_google_translate_replacement()

    g.settings.use = 2
    tos_google_translate_save_settings()
    local frame = ui.GetFrame("tos_google_translate")

    frame:ShowWindow(0)

    tos_google_translate_frame_init()

end

function tos_google_translate_frame_open()

    g.settings.use = 1

    tos_google_translate_frame_init()

    tos_google_translate_save_settings()
end

function tos_google_translate_frame_close()
    local frame = ui.GetFrame("tos_google_translate")
    frame:ShowWindow(0)

    g.settings.use = 0
    tos_google_translate_save_settings()

    tos_google_translate_frame_init()

end

function tos_google_translate_frame_init(frame, ctrl, argStr, argNum)

    acutil.setupEvent(g.addon, "DRAW_CHAT_MSG", "tos_google_translate_DRAW_CHAT_MSG");
    g.addon:RegisterMsg("FPS_UPDATE", "tos_google_translate_receive");
    local chatframe = ui.GetFrame("chatframe")
    local tabgbox = GET_CHILD_RECURSIVELY(chatframe, "tabgbox")
    local trans = tabgbox:CreateOrGetControl("button", "trans", 270, -3, 30, 30)
    AUTO_CAST(trans)
    if g.settings.use == 0 then
        trans:SetSkinName('test_gray_button')
        trans:SetTextTooltip("[Tos Google Translate]{nl}" .. "Translation mode off{nl}" ..
                                 tos_google_translate_lang("Left click:Setting menu display"))
    elseif g.settings.use == 1 then
        trans:SetSkinName("test_red_button")
        trans:SetTextTooltip("[Tos Google Translate]{nl}" .. "Translation mode on{nl}" ..
                                 tos_google_translate_lang("Left click:Setting menu display"))
    elseif g.settings.use == 2 then
        trans:SetSkinName("baseyellow_btn")
        trans:SetTextTooltip("[Tos Google Translate]{nl}" .. "Replace mode in operation.{nl}" ..
                                 tos_google_translate_lang("Left click:Setting menu display"))
    end

    trans:SetText("{ol}{s14}{#FFFFFF}" .. g.settings["lang"])
    -- trans:SetEventScript(ui.LBUTTONUP, "tos_google_translate_frame_open")
    trans:SetEventScript(ui.LBUTTONUP, "tos_google_translate_context")
    -- trans:SetEventScript(ui.RBUTTONUP, "tos_google_translate_restart")

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
        tos_google_translate_gbox(output)

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
        tos_google_translate_gbox(output)
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

--[[ テスト
local test_str = -- "{a SLI 1537409313462701|# 11200289}{#FFFF00}{img icon_item_Boss_Slogutis_Auto_Enter 30 30}{深淵の観測者(自動マッチング/1人)1回入場券(取引不可)}{/}{/}"
"{a SLP 1537984839025915}{#FFFF00}{img link_party 24 24}{夢幻深淵ハード}{/}{/}"
print(remove_unwanted_braces(test_str))]]

function tos_google_translate_gbox(output)

    local mainchatFrame = ui.GetFrame("chatframe")
    local frame = ui.GetFrame("tos_google_translate")
    local gbox = frame:CreateOrGetControl("groupbox", "gbox", 0, 0, frame:GetWidth(), frame:GetHeight())
    AUTO_CAST(gbox)
    gbox:SetLeftScroll(1)

    local ypos = 0
    local max_chat_id = nil -- 最大の chat_id を格納する変数

    local chat_id = ""
    local name = ""
    local trans_text = ""
    local msgtype = ""
    local time = ""

    g.ypos = 0

    for i, entry in ipairs(output) do
        chat_id = entry.chat_id
        name = entry.name
        trans_text = entry.trans_text
        msgtype = entry.msgtype
        time = entry.time

        -- デバッグメッセージを追加して、各エントリの内容を確認
        --[[print(string.format("Entry %d: chat_id = %s, name = %s, trans_text = %s, msgtype = %s, time = %s", i,
            tostring(chat_id), tostring(name), tostring(trans_text), tostring(msgtype), tostring(time)))]]

        local clustername = "cluster_" .. chat_id
        local marginLeft = 20
        local marginRight = 0

        local commnderNameUIText = name .. " : " .. trans_text
        if g.settings.use == 2 then
            commnderNameUIText = "{#FF0000}(" .. g.settings.lang .. "){/}" .. name .. " : " .. trans_text
        end
        for i, extractedTexts in pairs(g.extractedTexts) do
            if chat_id == i then
                for j, extractedText in ipairs(extractedTexts) do
                    extractedText = remove_unwanted_braces(extractedText)

                    commnderNameUIText = commnderNameUIText .. extractedText
                end
            end
        end
        if g.settings.use == 1 then
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
            -- txt:SetEventScript(ui.MOUSEMOVE, "tos_google_translate_get_curline")
            timeCtrl:SetTextByKey("time", time)

            local offsetX = mainchatFrame:GetUserConfig("CTRLSET_OFFSETX")

            tos_google_translate_chat_ctrl(gbox, chatCtrl, label, txt, timeCtrl, offsetX)

        elseif g.settings.use == 2 then

            local childCount = mainchatFrame:GetChildCount()
            local chatCtrl = GET_CHILD_RECURSIVELY(mainchatFrame, clustername)

            local groupboxname

            for i = 0, childCount - 1 do
                if chat_id ~= 1 then

                    if chatCtrl ~= nil then
                        groupboxname = chatCtrl:GetParent():GetName()
                        local groupbox = GET_CHILD_RECURSIVELY(mainchatFrame, groupboxname)

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
                        local chatWidth = groupbox:GetWidth()
                        txt:SetTextMaxWidth(groupbox:GetWidth() - 100)
                        txt:SetText(txt:GetText())
                        label:Resize(chatWidth - offsetX, txt:GetHeight())
                        chatCtrl:Resize(chatWidth, label:GetHeight())

                        for i, entry in ipairs(output) do
                            local chat_id = tonumber(entry.chat_id) -- chat_id を数値に変換
                            if chat_id then -- chat_id が数値に変換できた場合
                                if max_chat_id == nil or chat_id > max_chat_id then
                                    max_chat_id = chat_id -- 現在の最大値を更新
                                end
                            end
                        end
                        local ctrl = GET_CHILD_RECURSIVELY(mainchatFrame, "cluster_" .. max_chat_id)
                        ypos = ctrl:GetY() + chatCtrl:GetHeight()
                        if chat_id == max_chat_id then
                            chatCtrl:SetOffset(marginLeft, ypos)
                        end

                        if groupbox:GetLineCount() == groupbox:GetCurLine() + groupbox:GetVisibleLineCount() then
                            groupbox:SetScrollPos(99999)

                        end

                    end

                end
            end

            mainchatFrame:Invalidate();

        end

    end

end

function tos_google_translate_get_curline()
    local frame = ui.GetFrame("tos_google_translate")
    local groupbox = GET_CHILD(frame, "gbox")

    if groupbox:GetLineCount() == groupbox:GetCurLine() + groupbox:GetVisibleLineCount() then
        return true
    else
        return false
    end

end

function tos_google_translate_chat_ctrl(groupbox, chatCtrl, label, txt, timeCtrl, offsetX)

    local chatWidth = groupbox:GetWidth()
    txt:SetTextMaxWidth(groupbox:GetWidth() - 100)
    txt:SetText(txt:GetText())
    label:Resize(chatWidth - offsetX, txt:GetHeight())
    chatCtrl:Resize(chatWidth, label:GetHeight())
    -- g.ypos = g.ypos + label:GetHeight()
    local scrollend = tos_google_translate_get_curline()
    if scrollend then
        groupbox:SetScrollPos(99999)
    end

end

function tos_google_translate_start()

    if not g.loaded then
        local restart = io.open(g.restartFileLoc, "r")
        if restart then
            restart:close() -- ファイルを閉じる
            os.remove(g.restartFileLoc) -- ファイルを削除する

        end
        local new_entry = string.format(
            '{"chat_id":"%s","msgtype":"%s","trans_text":"%s","time":"%s","name":"%s","lang":"%s"}', "1", "System",
            "Tos Google Translate Version " .. ver .. " Startup Test", "", "", "en")

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

        DebounceScript("tos_google_translate_exe_start", 1.0)

    end
    tos_google_translate_frame_init()

end

function tos_google_translate_exe_start()
    local exe_path = "../addons/tos_google_translate/tos_google_translate/tos_google_translate-v1.0.1.exe" -- 実行したいPythonスクリプトのパス

    local file = io.open(exe_path, "r")
    if file then
        file:close()
        local command = string.format('start "" "%s"', exe_path)
        os.execute(command)

        g.loaded = true
        -- tos_google_translate_frame_init()

    else
        ui.SysMsg(tos_google_translate_lang("[Tos Google Translate]{nl}" ..
                                                "/addons/tos_google_translate/tos_google_translate/tos_google_translate-v1.0.1.exe{nl}" ..
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
    elseif langCode == "kr" then
        langCode = "ko"
    else
        langCode = "en"
    end

    if not settings then
        -- 設定ファイルが存在しない場合、デフォルトの設定を作成
        settings = {
            use = 1,
            lang = langCode
        }
    else
        g.settings = settings

    end
    if g.loaded == false then
        local file = io.open(g.noticeFileLoc, "w")
        file:write("")
        file:close()
        -- g.loaded = true
    end

    tos_google_translate_save_settings()
    ReserveScript("tos_google_translate_load_names()", 0.2)

    return
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

    ReserveScript("tos_google_translate_start()", 0.2)

end

function tos_google_translate_load_names_table()
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
    local partyMemberName = partyMemberInfo:GetName()

    tos_google_translate_load_names_table()
    if g.names[partyMemberName] then
        partyMemberName = g.names[partyMemberName]
    end

    -- g.tempparty の中身を表示（デバッグ用）

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

--[[function tos_google_translate_koja()

    local kojaFileLoc = string.format('../addons/%s/MemoriseData.dat', "koja_name_translater")
    local koja = io.open(kojaFileLoc, "r")
    if koja then
        local content = koja:read("*all")
        koja:close()
    end
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

end]]
