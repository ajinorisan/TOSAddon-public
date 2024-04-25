-- v2.0.0 別フレームにてチャット表示に変更。
-- ******************************************************
-- zchatextendより遅くに読み込む必要あるのでz始まり
-- ******************************************************
-- アドオン名（大文字）
local addonName = "ZCHATKONYAKU";
local addonNameLower = string.lower(addonName);
-- 作者名
local author = "mamao";

local originalVer = "0.0.1"
local Ver = "2.0.0"
-- アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G["ADDONS"] = _G["ADDONS"] or {};
_G["ADDONS"][author] = _G["ADDONS"][author] or {};
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {};
local g = _G["ADDONS"][author][addonName];

g.MSG_PATTERN = {}; -- チャットタイプ判定用パターン

g.pipe = true; -- パイプ通信するしない
g.P1 = nil;
g.P2 = nil;

g.chat_id = '';
g.SAVE_DIR = "../release/screenshot";

-- 設定ファイル保存先
g.settingsFileLoc = string.format("../addons/%s/settings.json", addonNameLower);

-- ライブラリ読み込み
local acutil = require('acutil');
-- Lua 5.2+ migration
if not _G['unpack'] and (table and table.unpack) then
    _G['unpack'] = table.unpack
end

-- 読み込みフラグ
g.loaded = false

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

-- lua読み込み時のメッセージ
-- CHAT_SYSTEM(string.format("%s.lua is loaded", addonName));

-- マップ読み込み時処理（1度だけ）
function ZCHATKONYAKU_ON_INIT(addon, frame)

    g.addon = addon;
    g.frame = frame;
    g.settings = g.settings or {}
    KONYAKU_LOAD_SETTINGS()
    -- 初期設定項目は1度だけ行う
    if not g.loaded then

        frame:Resize(0, 0)
        frame:SetPos(0, 0)

        g.MSG_PATTERN = {};
        g.MSG_PATTERN[#g.MSG_PATTERN + 1] = "一般";
        g.MSG_PATTERN[#g.MSG_PATTERN + 1] = "シャウト";
        g.MSG_PATTERN[#g.MSG_PATTERN + 1] = "PT";
        g.MSG_PATTERN[#g.MSG_PATTERN + 1] = "ギルド";
        g.MSG_PATTERN[#g.MSG_PATTERN + 1] = "ささやき";
        g.MSG_PATTERN[#g.MSG_PATTERN + 1] = "グループ";
        g.MSG_PATTERN[#g.MSG_PATTERN + 1] = "システム";
        g.MSG_PATTERN[#g.MSG_PATTERN + 1] = "お知らせ";
        g.MSG_PATTERN[#g.MSG_PATTERN + 1] = "強調";

        g.loaded = true;
        g.childCount = 0
        g.settings = {}
        KONYAKU_SAVE_SETTINGS()
    end

    local frame = ui.GetFrame("zchatkonyaku")
    frame:RunUpdateScript("KONYAKU_TRANSLATE_RECV", 0.1)
    acutil.setupEvent(addon, "DRAW_CHAT_MSG", "KONYAKU_CHAT_HOOK");
    addon:RegisterMsg('ESCAPE_PRESSED', 'KONYAKU_FRAME_CLOSE');
    addon:RegisterMsg("GAME_START_3SEC", "KONYAKU_FRAME_INIT")
    g.lastPrintedMsg = ""
    -- g.childCount = 0

    g.pipe = true;
    -- KONYAKU_TRANSLATE_START();

end

function KONYAKU_CHAT_FORMAT(str, msgString)

    local res = msgString:gsub("{.-}", "")

    if res == " " then

        return
    end

    local result = str:gsub("{.-}", "") -- {}に囲まれた部分を削除する
    result = dictionary.ReplaceDicIDInCompStr(result)

    if result == " " then
        return
    end
    local maxLength = 45 -- 一行の最大半角文字数
    local strTable = {} -- 文字列を格納するテーブル

    -- 文字列を60文字ごとに分割してテーブルに格納する
    for i = 0, #result, maxLength do
        table.insert(strTable, result:sub(i, i + maxLength - 1))
    end

    return strTable
    -- テーブルを出力
    --[[for _, str in ipairs(strTable) do
        print(str)
    end]]
end

function KONYAKU_LOAD_SETTINGS()
    local settings, err = acutil.loadJSON(g.settingsFileLoc, g.settings)
    if err then
        -- 設定ファイル読み込み失敗時処理
        CHAT_SYSTEM(string.format("[%s] cannot load setting files", addonNameLower))
    end

    -- settingsがnilまたは空の場合は初期設定を使用する
    if not settings then
        settings = {}
    end
    g.settings = settings
    KONYAKU_SAVE_SETTINGS()
end

function KONYAKU_SAVE_SETTINGS()
    acutil.saveJSON(g.settingsFileLoc, g.settings);
end

function KONYAKU_CHAT_SYSTEM(groupboxname, msg)

    local mainchatFrame = ui.GetFrame("chatframe")
    local groupbox = GET_CHILD(mainchatFrame, groupboxname)
    local size = session.ui.GetMsgInfoSize(groupboxname)
    local lastmsginfo = session.ui.GetChatMsgInfo(groupboxname, size - 1)

    -- local msgString = lastmsginfo:GetMsg()
    local msgString = tostring(msg)

    if msgString == g.lastPrintedMsg then
        return
    end
    local chat_id = lastmsginfo:GetMsgInfoID();
    local timestr = lastmsginfo:GetTimeStr()
    local cmdName = lastmsginfo:GetCommanderName();
    local msgtype = lastmsginfo:GetMsgType()

    local typetbl = {

        Shout = "[シャウト]",
        Normal = "[一般]",
        Party = "[PT]",
        Guild = "[ギルド]",
        System = "[システム]"
    }

    local frame = ui.GetFrame("zchatkonyaku")
    local gbox = GET_CHILD(frame, "gbox")
    local string = ""
    local childcount = (gbox:GetChildCount() - 1) / 2

    if msgString ~= g.lastPrintedMsg then

        g.lastPrintedMsg = msgString -- 前回プリントしたメッセージを更新
        local count = 1

        -- print(msg)

        for key, str in pairs(typetbl) do
            if tostring(key) == msgtype then
                msgtype = str
                break
            end
        end

        -- local strTable = removeBrackets(cmdName .. ":" .. msgString, msgString)
        local strTable = KONYAKU_CHAT_FORMAT(msgString, msgString)

        for _, str in ipairs(strTable) do

            local text = gbox:CreateOrGetControl("richtext", "text" .. g.chat_id .. count, 25, childcount * 20,
                frame:GetWidth() - 90, 20)

            local time = gbox:CreateOrGetControl("richtext", "time" .. g.chat_id .. count, frame:GetWidth() - 85,
                childcount * 20, 80, 20)

            time:SetText("{ol}{s14}" .. timestr)
            if count == 1 and msgtype == "[PT]" then
                text:SetText("{ol}{#86E57F}" .. msgtype .. str)

            elseif count ~= 1 and msgtype == "[PT]" then
                text:SetText("{ol}{#86E57F}" .. str)

            elseif count == 1 and msgtype == "[シャウト]" then
                text:SetText("{ol}{#da6e0f}" .. msgtype .. str)

            elseif count ~= 1 and msgtype == "[シャウト]" then
                text:SetText("{ol}{#da6e0f}" .. str)

            elseif count == 1 and msgtype == "[一般]" then
                text:SetText("{ol}{#FFFFFF}" .. msgtype .. str)

            elseif count ~= 1 and msgtype == "[一般]" then
                text:SetText("{ol}{#FFFFFF}" .. str)

            elseif count == 1 and msgtype == "[ギルド]" then
                text:SetText("{ol}{#A566FF}" .. msgtype .. str)

            elseif count ~= 1 and msgtype == "[ギルド]" then
                text:SetText("{ol}{#A566FF}" .. str)

            elseif count == 1 and msgtype == "[システム]" then
                text:SetText("{ol}{#FFE400}" .. msgtype .. string.gsub(str, "System", ""))

            elseif count ~= 1 and msgtype == "[システム]" then
                text:SetText("{ol}{#FFE400}" .. str)

            elseif count == 1 then
                text:SetText("{ol}{#FFFFFF}" .. msgtype .. str)

            elseif count ~= 1 then
                text:SetText("{ol}{#FFFFFF}" .. str)

            end

            local chat_id = g.chat_id
            local gettext = text:GetText()
            local gettime = time:GetText()

            g.settings[tostring(g.childCount)] = {
                text = gettext,
                time = gettime

            }

            -- print(tostring(g.chat_tbl[chat_id][count]))
            childcount = childcount + 1
            count = count + 1
            g.childCount = g.childCount + 1

        end
    end

    gbox:SetScrollPos(99999)

    KONYAKU_SAVE_SETTINGS()

    return

end

function KONYAKU_TRANSLATE_GBOX()
    local frame = ui.GetFrame("zchatkonyaku")
    local gbox = GET_CHILD(frame, "gbox")
    AUTO_CAST(gbox)
    local count = 0
    for _ in pairs(g.settings) do
        count = count + 1
    end

    for i = 0, count - 1 do
        local text_frame = gbox:CreateOrGetControl("richtext", "text_frame" .. i, 25, i * 20, frame:GetWidth() - 90, 20)
        AUTO_CAST(text_frame)
        text_frame:SetText(g.settings[tostring(i)].text)
        local time_frame = gbox:CreateOrGetControl("richtext", "time_frame" .. i, frame:GetWidth() - 85, i * 20, 80, 20)
        AUTO_CAST(time_frame)
        time_frame:SetText(g.settings[tostring(i)].time)
        -- g.childCount = g.childCount + 1

    end
    gbox:SetScrollPos(99999)
    KONYAKU_TRANSLATE_START();
    -- ui.Chat("/p 오늘 챌 잡몹 피가 1이에요 여러분 챌도세요")
end

function KONYAKU_FRAME_OPEN(frame, ctrl, argStr, argNum)
    local frame = ui.GetFrame("zchatkonyaku")
    if frame:IsVisible() == 0 then
        frame:ShowWindow(1)
    else
        KONYAKU_FRAME_CLOSE(frame, ctrl, argStr, argNum)
    end
end

function KONYAKU_FRAME_CLOSE(frame, ctrl, argStr, argNum)
    local frame = ui.GetFrame("zchatkonyaku")
    frame:ShowWindow(0)
end

function KONYAKU_FRAME_INIT(frame, ctrl, argStr, argNum)
    local chatframe = ui.GetFrame("chatframe")
    local tabgbox = GET_CHILD_RECURSIVELY(chatframe, "tabgbox")
    local trans = tabgbox:CreateOrGetControl("button", "trans", 270, -3, 30, 30)
    AUTO_CAST(trans)
    trans:SetSkinName("test_red_button")
    trans:SetText("{ol}{s14}{#FFFFFF}翻")
    trans:SetEventScript(ui.LBUTTONUP, "KONYAKU_FRAME_OPEN")
    trans:SetTextTooltip("翻訳チャットウインドウを開閉します。")
    local chatframeWidth, chatframeHeight = chatframe:GetWidth(), chatframe:GetHeight()

    frame:SetSkinName("chat_window_2")
    frame:Resize(chatframeWidth, chatframeHeight / 2) -- 幅は chatframe と同じに設定

    local clientWidth, clientHeight = option.GetClientWidth(), option.GetClientHeight()
    local frameY = clientHeight - chatframeHeight

    frame:SetPos(0, frameY + chatframeHeight / 2 - 70)

    frame:ShowWindow(1)
    local gbox = frame:CreateOrGetControl("groupbox", "gbox", 0, 0, frame:GetWidth(), frame:GetHeight())
    AUTO_CAST(gbox)

    KONYAKU_TRANSLATE_GBOX()

end

-- =================================
-- 翻訳準備（Timer&Pipe）
-- =================================
function KONYAKU_TRANSLATE_START()
    local ret = true;

    if g.pipe == false then
        return;
    end

    if g.P1 == nil then
        -- 送信用
        g.P1 = io.open('\\\\.\\pipe\\tos_pipe1', 'w+');
        if g.P1 ~= nil then
            -- CHAT_SYSTEM("送信－接続OK");
        else
            -- CHAT_SYSTEM("送信－接続できません");
            ret = false;
        end
    else
        -- CHAT_SYSTEM("送信－接続中");
    end
    if g.P2 == nil then
        -- 受信用
        g.P2 = io.open('\\\\.\\pipe\\tos_pipe2', 'r');
        if g.P2 ~= nil then
            -- CHAT_SYSTEM("受信－接続OK");
        else
            -- CHAT_SYSTEM("受信－接続できません");
            ret = false;
        end
    else
        -- CHAT_SYSTEM("受信－接続中");
    end

    if ret then
        CHAT_SYSTEM("翻訳通信準備 完了");
    else
        -- CHAT_SYSTEM("翻訳しません");
        -- 一度失敗したらマップロードのタイミングまで翻訳フラグはoff
        if g.P1 ~= nil then
            g.P1:close();
        end
        if g.P2 ~= nil then
            g.P2:close();
        end
        g.pipe = false;
    end
    return ret;
end

-- =================================
-- チャットDRAWフック
-- =================================
function KONYAKU_CHAT_HOOK(frame, msg)

    local groupboxname, startindex, chatframe = acutil.getEventArgs(msg);
    -- print(tostring(startindex))
    if startindex <= 0 then
        return;
    end

    if chatframe ~= ui.GetFrame("chatframe") then
        return;
    end

    if groupboxname ~= "chatgbox_TOTAL" then
        return;
    end

    local groupbox = GET_CHILD(chatframe, groupboxname);
    if groupbox == nil then
        return;
    end
    local size = session.ui.GetMsgInfoSize(groupboxname);
    -- 対象メッセージを処理
    for i = startindex, size - 1 do
        local msg = session.ui.GetChatMsgInfo(groupboxname, i);
        if msg == nil then
            return;
        end

        g.chat_id = msg:GetMsgInfoID();
        local tempMsg = msg:GetMsg();
        local cmdName = msg:GetCommanderName();
        g.msgtype = msg:GetMsgType()

        if g.msgtype ~= "System" then
            KONYAKU_TRANSLATE_SEND(cmdName, tempMsg, g.chat_id);
            break
        end

    end

    return;
end

-- =================================
-- 翻訳送信
-- =================================
function KONYAKU_TRANSLATE_SEND(cmd_nm, msg, chat_id)

    if msg == "" then
        return;
    end

    if io.type(g.P1) == "closed file" or io.type(g.P1) == nil then
        g.P1 = nil;
        KONYAKU_TRANSLATE_START();
    end

    if g.P1 == nil or g.P2 == nil then
        return;
    end

    local ch = WITH_HANGLE(cmd_nm);
    local mh = WITH_HANGLE(msg);
    if mh or ch then

        msg = cmd_nm .. "\t" .. msg;

        local bt = string.format("%04d", #msg + 0);

        bt = bt .. acutil.leftPad(chat_id, 8, ' ');

        bt = bt .. msg;

        g.P1:write(bt);
        g.P1:flush();
        return
    end

    --[[local en_chat = HAS_ENGLISH_CHARS(cmd_nm)
    local en_msg = HAS_ENGLISH_CHARS(msg)

    if en_chat or en_msg then

        msg = cmd_nm .. "\t" .. msg;

        local bt = string.format("%04d", #msg + 0);

        bt = bt .. acutil.leftPad(chat_id, 8, ' ');
        print(tostring(bt))
        bt = bt .. msg;
        print(tostring(bt))
        g.P1:write(bt);
        g.P1:flush();
        return
    end]]
end

-- =================================
-- 翻訳受信
-- =================================
function KONYAKU_TRANSLATE_RECV(frame)

    local chatframe = ui.GetFrame("chatframe");
    local groupboxname = "chatgbox_TOTAL";
    if chatframe == nil then

        return 1;
    end

    local groupbox = GET_CHILD(chatframe, groupboxname);
    if groupbox == nil then

        return 1;
    end

    if io.type(g.P2) == "closed file" or io.type(g.P2) == nil then
        g.P2 = nil;
        KONYAKU_TRANSLATE_START();
    end

    if g.P1 == nil or g.P2 == nil then
        return 1;
    end

    local cnt = 0;

    -- while cnt < 10 do

    local len = g.P2:seek("end");

    if len <= 1 then

        return 1
    else

        local ms = g.P2:read(1) + 0;

        local len = g.P2:read(4) + 0;

        local chat_id = g.P2:read(8);
        chat_id = TRIM(chat_id);

        local cmd_nm = "";
        local msg = g.P2:read(len);

        local msga = SPLIT(msg, "\t");

        if #msga > 1 then

            cmd_nm = msga[1];
            msg = msga[2];

            if cmd_nm == "System" then
                cmd_nm = "";
            end

            local delaytime = 20
            -- /r グループ　/yシャウト　/pパーティー /gギルド　/s一般
            if g.msgtype ~= "System" or g.msgtype ~= "Partymem" or g.msgtype ~= "guildmem" then
                msg = cmd_nm .. ":" .. msg
                KONYAKU_CHAT_SYSTEM(groupboxname, msg)
                ui.ReDrawAllChatMsg();
                --[[if g.msgtype == "Shout" then
                    NICO_CHAT("{@st64}{#da6e0f}{ol}" .. "[" .. g.msgtype .. "]" .. cmd_nm .. ":" .. msg)

                elseif g.msgtype == "Normal" then
                    NICO_CHAT("{@st64}{#FFFFFF}{ol}" .. "[" .. g.msgtype .. "]" .. cmd_nm .. ":" .. msg)

                elseif g.msgtype == "Party" then
                    NICO_CHAT("{@st64}{#86E57F}{ol}" .. "[" .. g.msgtype .. "]" .. cmd_nm .. ":" .. msg)

                elseif g.msgtype == "Guild" then
                    NICO_CHAT("{@st64}{#A566FF}{ol}" .. "[" .. g.msgtype .. "]" .. cmd_nm .. ":" .. msg)

                else
                    NICO_CHAT("{@st64}{#FFFFFF}{ol}" .. "[" .. g.msgtype .. "]" .. cmd_nm .. ":" .. msg)
                end]]

                return 1

            end
            return 1

        end
        return 1;

    end
    return 1;

end

function temp_file(msg, file)
    -- ファイル書き込みモード
    local time = geTime.GetServerSystemTime();
    local year = string.format("%04d", time.wYear);
    local month = string.format("%02d", time.wMonth);
    local day = string.format("%02d", time.wDay);
    local logfile = string.format("temp_log" .. file .. "_%s%s%s.txt", year, month, day);
    local file, err = io.open(g.SAVE_DIR .. "/" .. logfile, "a")
    if err then
        CHAT_SYSTEM("チャットの保存に失敗しました(フォルダがない？)");
    else
        file:write(msg .. "\n");
        file:close();
    end
end

-- *********************************
-- ここから先はツール関数類
-- *********************************

function utf8len(str)
    local len = 0
    local pos = 1
    local size = #str
    while pos <= size do
        local byte = string.byte(str, pos)
        if byte < 128 then
            len = len + 1
            pos = pos + 1
        elseif byte >= 192 and byte < 224 then
            len = len + 1
            pos = pos + 2
        elseif byte >= 224 and byte < 240 then
            len = len + 1
            pos = pos + 3
        elseif byte >= 240 and byte < 248 then
            len = len + 1
            pos = pos + 4
        elseif byte >= 248 and byte < 252 then
            len = len + 1
            pos = pos + 5
        elseif byte >= 252 and byte < 254 then
            len = len + 1
            pos = pos + 6
        else
            -- 不正なバイト列があった場合、エラーとして終了
            return -1
        end
    end
    return len
end

-- 両端のブランクを取り除く
-- 引数１：文字列
-- 戻り値：文字列
--
function TRIM(s)
    return (string.gsub(s, "^%s*(.-)%s*$", "%1"));
end

-- 指定文字で分解
-- 引数１：対象文字列
-- 引数２：分解指定文字
-- 戻り値：配列
--
function SPLIT(str, ts)
    -- 引数がないときは空tableを返す
    if ts == nil then
        return {}
    end

    local t = {};
    local i = 1
    for s in string.gmatch(str, "([^" .. ts .. "]+)") do
        t[i] = s
        i = i + 1
    end
    return t
end

-- 文字にハングルを含むか判定
-- 引数１：文字列
-- 戻り値：true/false
--
function WITH_HANGLE(str)
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
        -- print("inc:" .. inc .. '.' .. string.format("%x",byt));

        for j = 1, inc do
            code = code + (byt * (256 ^ (inc - j)));
            -- print("code:" .. j .. '.' .. string.format("%x",code));
            i = i + 1;
            byt = string.byte(str, i);
        end
        -- print(string.format("%x",code));

        if code >= 0xEAB080 and code <= 0xED9EA3 then
            -- ハングル
            return true;
        end
        code = 0;
    end
    return false;
end

function HAS_ENGLISH_CHARS(str)
    local size = #str;
    for i = 1, size do
        local charCode = string.byte(str, i);
        if (charCode >= 65 and charCode <= 90) or (charCode >= 97 and charCode <= 122) then
            return true; -- English character found
        end
    end
    return false; -- No English characters found
end
