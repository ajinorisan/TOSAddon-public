--******************************************************
-- zchatextendより遅くに読み込む必要あるのでz始まり
--******************************************************
--アドオン名（大文字）
local addonName = "CHATKONYAKU";
local addonNameLower = string.lower(addonName);
--作者名
local author = "mamao";

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G["ADDONS"] = _G["ADDONS"] or {};
_G["ADDONS"][author] = _G["ADDONS"][author] or {};
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {};
local g = _G["ADDONS"][author][addonName];


g.MSG_PATTERN = {};	--チャットタイプ判定用パターン

g.pipe = true;	--パイプ通信するしない
g.P1 = nil;
g.P2 = nil;

g.chat_id = '';
g.SAVE_DIR = "../release/screenshot";



--設定ファイル保存先
g.settingsFileLoc = string.format("../addons/%s/settings.json", addonNameLower);

--ライブラリ読み込み
local acutil = require('acutil');
--Lua 5.2+ migration
if not _G['unpack'] and (table and table.unpack) then _G['unpack'] = table.unpack end

-- 読み込みフラグ
g.loaded=false


--lua読み込み時のメッセージ
CHAT_SYSTEM(string.format("%s.lua is loaded", addonName));



--マップ読み込み時処理（1度だけ）
function ZCHATKONYAKU_ON_INIT(addon, frame)
--https://github-wiki-see.page/m/meldavy/ipf-documentation/wiki/Async-Logic#fps_update
--ReserveScript("hookaleady()", 5);
--RunUpdateScript

--	acutil.slashCommand("/mos", KONYAKU_PROCESS_COMMAND);

	CHAT_SYSTEM("Chat Konyaku init");

	-- 初期設定項目は1度だけ行う
	if not g.loaded then
		g.addon = addon;
		g.frame = frame;

		--ScpArgMsg("ChatType_1")を使うと文字になってくれない…
		--だからchatextendsも自前で変換してたのかな
		g.MSG_PATTERN = {};
		g.MSG_PATTERN[ #g.MSG_PATTERN + 1 ] = "一般";
		g.MSG_PATTERN[ #g.MSG_PATTERN + 1 ] = "シャウト";
		g.MSG_PATTERN[ #g.MSG_PATTERN + 1 ] = "PT";
		g.MSG_PATTERN[ #g.MSG_PATTERN + 1 ] = "ギルド";
		g.MSG_PATTERN[ #g.MSG_PATTERN + 1 ] = "ささやき";
		g.MSG_PATTERN[ #g.MSG_PATTERN + 1 ] = "グループ";
		g.MSG_PATTERN[ #g.MSG_PATTERN + 1 ] = "システム";
		g.MSG_PATTERN[ #g.MSG_PATTERN + 1 ] = "お知らせ";
		g.MSG_PATTERN[ #g.MSG_PATTERN + 1 ] = "強調";

		g.loaded = true;
	end

	--翻訳準備（マップロードの度にコールすれば翻訳切断時にリログで復帰できる）
	g.pipe = true;
	KONYAKU_TRANSLATE_START();


	--タイマー準備
--	local __timer = frame:CreateOrGetControl("timer", "addontimer2", 10, 10);
--	AUTO_CAST(timer);
    local timer_frame = frame:GetChild("addontimer");
    local timer = tolua.cast(timer_frame, "ui::CAddOnTimer");

	if timer ~= nil then
	    timer:Stop();
		timer:SetUpdateScript("KONYAKU_TRANSLATE_RECV");
		timer:Start(1.0);
		CHAT_SYSTEM("翻訳受信タイマー起動完了");
	else
		CHAT_SYSTEM("翻訳受信タイマー無効");
	end

	--drawイベントを拾って翻訳
	acutil.setupEvent(addon, "DRAW_CHAT_MSG", "KONYAKU_CHAT_HOOK");

	--CHAT_SYSTEM("発言フックOK");

end

-- =================================
-- 翻訳準備（Timer&Pipe）
-- =================================
function KONYAKU_TRANSLATE_START()
	local ret = true;

	if g.pipe == false then
		return;
	end

	CHAT_SYSTEM("翻訳通信準備 開始");

	--翻訳通信パイプを用意する
	if g.P1 == nil then
		--送信用
		g.P1 = io.open( '\\\\.\\pipe\\tos_pipe1', 'w+' );
		if g.P1 ~= nil then
			CHAT_SYSTEM("送信－接続OK");
		else
			CHAT_SYSTEM("送信－接続できません");
			ret = false;
		end
	else
		CHAT_SYSTEM("送信－接続中");
	end
	if g.P2 == nil then
		--受信用
		g.P2 = io.open( '\\\\.\\pipe\\tos_pipe2', 'r' );
		if g.P2 ~= nil then
			CHAT_SYSTEM("受信－接続OK");
		else
			CHAT_SYSTEM("受信－接続できません");
			ret = false;
		end
	else
		CHAT_SYSTEM("受信－接続中");
	end

	if ret then
		CHAT_SYSTEM("翻訳通信準備 完了");
	else
		CHAT_SYSTEM("翻訳しません");
		--一度失敗したらマップロードのタイミングまで翻訳フラグはoff
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
	local size = session.ui.GetMsgInfoSize(groupboxname);

	-- 再描画とかで開始インデックスが0以下なら終了
	if startindex <= 0 then
		return;
	end

	-- メインのチャットフレームの文言のみ
	if chatframe ~= ui.GetFrame("chatframe") then
		return;
	end

	-- メインの全体発言のみ
	if groupboxname ~= "chatgbox_TOTAL" then
		return;
	end

	--グループボックスが取れなかったら処理しない
	local groupbox = GET_CHILD(chatframe,groupboxname);
	if groupbox == nil then
		return;
	end

	--対象メッセージを処理
	for i = startindex, size - 1 do
		local msg = session.ui.GetChatMsgInfo(groupboxname, i);
		if msg == nil then
			return;
		end

		local chat_id = msg:GetMsgInfoID();
		local tempMsg = msg:GetMsg();
		local cmdName = msg:GetCommanderName();

		--print("msg7 " .. g.chat_id .. '/' .. tempMsg);
		--翻訳アプリへ送信
		KONYAKU_TRANSLATE_SEND(cmdName, tempMsg, chat_id);
		
		--[[
		--temp_file(tempMsg, "1");

		local clustername = "cluster_" .. chat_id;
		local chatCtrl = GET_CHILD(groupbox, clustername);
		--とらハムさんのchatextends判定
		if ADDONS.torahamu ~= nil then
			if ADDONS.torahamu.CHATEXTENDS ~= nil then
				if ADDONS.torahamu.CHATEXTENDS.settings.BALLON_FLG then
					--吹き出しモードだとgroupboxが間に入る
					chatCtrl = GET_CHILD(chatCtrl, "bg", "ui::CGroupBox");
				end
			end
		end
		--]]
		--local txt = GET_CHILD(chatCtrl, "text", "ui::CRichText");
		--local text = txt:GetText();
		--temp_file(text, "2");
	end

	return;
end


-- =================================
-- 翻訳送信
-- =================================
function KONYAKU_TRANSLATE_SEND(cmd_nm, msg, chat_id)

	--メッセージなしはなにもしない
	if msg == "" then
		return;
	end

	--翻訳通信パイプ（念のため切断されていたら接続）
	if io.type(g.P1)=="closed file" or io.type(g.P1)==nil then
		g.P1 = nil;
		KONYAKU_TRANSLATE_START();
	end

	--翻訳できない時はなにもしない
	if g.P1 == nil or g.P2 == nil then
		return;
	end

	local ch = WITH_HANGLE(cmd_nm);
	local mh = WITH_HANGLE(msg);
	if mh or ch then
		--名前かメッセージどちらかがハングルなら送信
		msg = cmd_nm .. "\t" .. msg;

		--文字数
		bt = string.format("%04d", #msg+0);
		--chat_id
		bt = bt .. acutil.leftPad(chat_id, 8, ' ');
		--文字列
		bt = bt .. msg;

		--送信
		--CHAT_SYSTEM( bt );
		g.P1:write( bt );
		g.P1:flush();
	end
end


-- =================================
-- 翻訳受信
-- =================================
function KONYAKU_TRANSLATE_RECV(frame)

	--print("recv");

	--メッセージ置き換え準備
	local chatframe = ui.GetFrame("chatframe");
	local groupboxname = "chatgbox_TOTAL";
	if chatframe == nil then
		--print("frame is null");
		return;
	end
	local groupbox = GET_CHILD(chatframe, groupboxname);
	if groupbox == nil then
		--print("groupbox is null");
		return;
	end

	--翻訳通信パイプチェック（念のため切断されていたら接続）
	if io.type(g.P2)=="closed file" or io.type(g.P2)==nil then
		g.P2 = nil;
		KONYAKU_TRANSLATE_START();
	end

	--翻訳できない時はなにもしない
	if g.P1 == nil or g.P2 == nil then
		return;
	end

	local cnt = 0;
	--１回につき最大１０件まで処理
	while cnt < 10 do

		--print("recv loop");

		--luaのパイプioはseekするとバッファ残数が取れるようだ
		len = g.P2:seek("end");
		--print("end:" .. len);

		if len <= 13 then
			--長さ13以下なら翻訳メッセージなしとみなす
			break;
		else
			--翻訳メッセージあり

			--メッセージ表現スタイル取り出し
			local ms = g.P2:read( 1 )+0;
			--print("ms:" .. ms);

			--文字数取り出し
			local len = g.P2:read( 4 )+0;
			--print("length:" .. len);

			--chat_id（これは数値変換不要）
			local chat_id = g.P2:read( 8 );
			chat_id = TRIM(chat_id);
			--print ( chat_id );

			--文字列取り出し
			local cmd_nm = "";
			local msg = g.P2:read( len );
			--print ( msg );

			local msga = SPLIT(msg, "\t");
			--print ( "array:" .. #msga );
			if #msga>1 then
				--１行目＝名前
				--２行目＝メッセージ
				cmd_nm = msga[1];
				msg = msga[2];
				--print("cmd_nm " .. cmd_nm);
				--print("msg " .. msg);

				--システムメッセージでは名前は省略
				if cmd_nm == "System" then
					cmd_nm = "";
				end
			end

			--翻訳先のメッセージを探す
			local clustername = "cluster_" .. chat_id;
			--print("debug:" .. clustername);

			--発言者枠（吹き出しモード時使用）
			local cmdn = nil;

			local chatCtrl = GET_CHILD(groupbox, clustername);
			--枠が見つかり翻訳文字があるならば処理
			if chatCtrl ~= nil and msg ~= ' ' then
				--print("chatCtrl found");

				local is_baloon = false;

				--とらハムさんのchatextends判定
				if ADDONS.torahamu ~= nil then
					--print("torahamu found.");
					if ADDONS.torahamu.CHATEXTENDS ~= nil then
						--print("chatextends found.");
						if ADDONS.torahamu.CHATEXTENDS.settings.BALLON_FLG then
							--print("chatextends ballon mode.");
							--名前枠取得
							cmdn = GET_CHILD(chatCtrl, "name", "ui::CRichText");
							--吹き出しモードだとgroupboxが間に入る
							chatCtrl = GET_CHILD(chatCtrl, "bg", "ui::CGroupBox");
							is_baloon = true;
						end
					end
				end

				local txt = GET_CHILD(chatCtrl, "text", "ui::CRichText");
				if txt ~= nil then
					--print("txt is null");

					--翻訳先発見
					local text = txt:GetText();
					--print("text:" .. text);
					--temp_file(text, "2");

					--吹き出しモードでないなら色変え
					if not is_baloon then
						msg = msg:gsub("{#0000FF}{img ","{#FFFF00}{img ");
					end

					if ms == 0 then
						--APPEND

						--追記
						if is_baloon then

							if cmd_nm ~= "" and cmdn ~= nil then
								local cmt = cmdn:GetText();
								cmt = cmt:gsub('^(.*)({/})$', '%1（' .. cmd_nm  .. '）%2');
								cmdn:SetText(cmt);
							end
							--吹き出しモードならnlを含まない
							text = text:gsub('^(.*)({/}{/})$', '%1（' .. msg  .. '）%2');

						else
							if cmd_nm ~= "" then
								msg = cmd_nm .. ' : ' .. msg;
							end

							--通常チャットならnl含む
							text = text:gsub('^(.*)({nl}{/}{/}{nl}{/})$', '%1{#999999}（' .. msg  .. '）{/}%2');
							text = text:gsub('^(.*)({nl}{/}{/}{nl})$', '%1{#999999}（' .. msg  .. '）{/}%2');
							text = text:gsub('^(.*)({nl}{/}{/})$', '%1{#999999}（' .. msg  .. '）{/}%2');
						end
						txt:SetTextByKey("text", text);

					else
						--REPLACE

						--print("text:" .. text);
						--temp_file(text, "2");

						if is_baloon then

							if cmd_nm ~= "" and cmdn ~= nil then
								cmdn:SetText('{@st61}'..cmd_nm..'{/}');
							end
							text = text:gsub('^({.-}{.-}{.-})(.*)({/}{/})$', '%1 {#FF0000}◆{/}(' .. msg  .. ')%3');

						else

							if cmd_nm ~= "" then
								msg = cmd_nm .. ' : ' .. msg;
							end

							--書き換え
							for i = 1, #g.MSG_PATTERN do
								local type_pat = "%[" .. g.MSG_PATTERN[i] .. "%]";
								--print(type_pat);

								if text:match( type_pat ) then
									--print("match " .. i);

									if is_baloon then
										--吹き出しモードならnlを含まない
										text = text:gsub('^(.*)(' .. type_pat .. ')(.*)({/}{/})$', '%1%2 {#FF0000}◆{/}(' .. msg  .. ')%4');
									else
										text = text:gsub('^(.*)(' .. type_pat .. ')(.*)({nl}{/}{/}{nl}{/})$', '%1%2 {#FF0000}◆{/}(' .. msg  .. ')%4');
										text = text:gsub('^(.*)(' .. type_pat .. ')(.*)({nl}{/}{/}{nl})$', '%1%2 {#FF0000}◆{/}(' .. msg  .. ')%4');
										text = text:gsub('^(.*)(' .. type_pat .. ')(.*)({nl}{/}{/})$', '%1%2 {#FF0000}◆{/}(' .. msg  .. ')%4');
									end

									break;
								end
							end

						end
						txt:SetTextByKey("text", text);

					end

					--できたかな？
					--text = txt:GetText();
					--print("chat update " .. text);
				else
					--print("target text nil");
				end
			else
				--print("target chat nil");
			end
		end
		cnt = cnt + 1;
	end

--できれば対象のグループだけredrawしたいが引数がわからん
--[RedrawGroupChat] = cfunc(?)
--	ui.RedrawGroupChat(groupbox);
--	ui.RedrawGroupChat(groupboxname);

--これで更新できるようだが全部redrawは効率悪そう
	if cnt > 0 then
		ui.ReDrawAllChatMsg();
	end

end


--チャットコマンド処理（acutil使用時）
function KONYAKU_PROCESS_COMMAND(command)
end


function temp_file(msg, file)
	-- ファイル書き込みモード
	local time = geTime.GetServerSystemTime();
	local year = string.format("%04d",time.wYear);
	local month = string.format("%02d",time.wMonth);
	local day = string.format("%02d",time.wDay);
	local logfile=string.format("temp_log" .. file .. "_%s%s%s.txt", year,month,day);
	local file,err = io.open(g.SAVE_DIR.."/"..logfile, "a")
	if err then
		CHAT_SYSTEM("チャットの保存に失敗しました(フォルダがない？)");
	else
		file:write( msg .. "\n" );
		file:close();
	end
end



-- *********************************
-- ここから先はツール関数類
-- *********************************

--両端のブランクを取り除く
--引数１：文字列
--戻り値：文字列
--
function TRIM(s)
	return (string.gsub(s, "^%s*(.-)%s*$", "%1"));
end


--指定文字で分解
--引数１：対象文字列
--引数２：分解指定文字
--戻り値：配列
--
function SPLIT(str, ts)
	--引数がないときは空tableを返す
	if ts == nil then return {} end

	local t = {};
	i=1
	for s in string.gmatch(str, "([^"..ts.."]+)") do
		t[i] = s
		i = i + 1
	end
	return t
end


--文字にハングルを含むか判定
--引数１：文字列
--戻り値：true/false
--
function WITH_HANGLE(str)
	local size = #str;
	local byt = 0;	--byt
	local code = 0;	--文字コード
	local inc = 1;	--1文字のバイト数
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
		--print("inc:" .. inc .. '.' .. string.format("%x",byt));

		for j = 1, inc do
			code = code + (byt * (256 ^ (inc - j)));
			--print("code:" .. j .. '.' .. string.format("%x",code));
			i = i + 1;
			byt = string.byte(str, i);
		end
		--print(string.format("%x",code));

		if code >= 0xEAB080 and code <= 0xED9EA3 then
			--ハングル
			return true;
		end
		code = 0;
	end
	return false;
end
