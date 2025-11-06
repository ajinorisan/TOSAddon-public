---- chat.lua


function WHISPER_CHAT(commname)

	local	setText = string.format('\"%s ', commname);
	
	SET_CHAT_TEXT(setText);

end

function GET_CHAT_TEXT()

	local chatFrame = ui.GetFrame('chat');
	local edit = chatFrame:GetChild('mainchat');

	return edit:GetText();

end

function GET_CHATFRAME()

	local chatFrame = ui.GetFrame("chat");
	if chatFrame == nil then
		return nil;
	end

	return chatFrame;
end

function CHAT_MAXLEN_MSG(frame, ctrl, maxLen)
	ui.SysMsg( ScpArgMsg("ChatMsgLimitedBy{Max}Byte_EmoticonCanTakeLotsOfByte","Max", maxLen));
end

function SET_CHAT_TEXT_TO_CHATFRAME(txt)
	local chatFrame = GET_CHATFRAME();
	local edit = chatFrame:GetChild('mainchat');

	chatFrame:ShowWindow(1);
	edit:ShowWindow(1);

	local editCtrl 	= tolua.cast(edit, "ui::CEditControl");
	edit:SetText(txt);
	editCtrl:AcquireFocus();
end

g_uiChatHandler = nil;
function UI_CHAT(msg)
	local findStart, findEnd = string.find(msg, "/gn ");	
	if findStart == 1 and findEnd == 4 then
		local aidx = session.loginInfo.GetAID();
		GetPlayerClaims("GUILD_NOTICE_CHECK", aidx, msg);
		return;
	end

	_UI_CHAT(msg);
end

function _UI_CHAT(msg)
	ui.Chat(msg);

	if g_uiChatHandler ~= nil then
		local func = _G[g_uiChatHandler];
		if func ~= nil then
			func(msg);
		end
	end
end

local json = require "json_imc"
function GUILD_NOTICE_CHECK(code, ret_json, msg)
	if code ~= 200 then
		return;
	end
	
	local guild = GET_MY_GUILD_INFO();
	if guild == nil then
		ui.SysMsg(ClMsg("EVENT_1805_GUILD_MSG1"));
		return;
	end
	
	local ret = false;
    local parsed_json = json.decode(ret_json)
	for k, v in pairs(parsed_json) do
		if v == 208 then -- 메시지 강조 권한
			ret = true;
			break;
		end
	end
	
	local isLeader = AM_I_LEADER(PARTY_GUILD);
	if isLeader == 1 then
		ret = true;
	end

	if ret == false then 
		ui.SysMsg(ClMsg("HaveNoPermissions"));
		return;
	end

	_UI_CHAT(msg);
end


