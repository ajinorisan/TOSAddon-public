function REQ_OPEN_FRIEND_INVITE(code)	
	ui.OpenFrame("friendinvite");
	
	local frame = ui.GetFrame('friendinvite')
	local edit = GET_CHILD(frame, 'numberEdit')
	edit:SetText(code)
	edit:SetEventScriptArgNumber(ui.ENTERKEY, 1)
	SET_INVITE_FRIEND_TEXT(frame, true)
end

function REQ_OPEN_FREIND_INVITER()
	ui.OpenFrame("friendinvite");
	local frame = ui.GetFrame('friendinvite')
	local edit = GET_CHILD(frame, 'numberEdit')
	edit:SetEventScriptArgNumber(ui.ENTERKEY, 0)
	SET_INVITE_FRIEND_TEXT(frame, false)
end

function CLOSE_FRIEND_INVITE()
	ui.CloseFrame("friendinvite");
end

function SET_INVITE_FRIEND_TEXT(frame, IsInviter)
	local numberHelp = GET_CHILD(frame, "numberHelp");
	local invitestate = GET_CHILD(frame, "invitestate");

	local text = nil;
	local state = nil;
	if IsInviter == true then
		text = "InviteFriend"
		state = "InviteFruit"
	else
		text = "InputInviteFriend"
		state = "InviteSeed"
	end
	numberHelp:SetTextByKey("text", ClMsg(text));
	invitestate:SetTextByKey("text", ClMsg(state));
end

--이미 참여한 경우에 대한 컨트롤은?
function FRIEND_INVITE_ENTER(frame, ctrl, argStr, IsInviter)
	--초대자면 그냥 return
	if IsInviter == 1 then
		return;
	end
	--피초대자일 경우에 진행
	WARNINGMSGBOX_FRAME_OPEN(ClMsg('FriendInviteCautionMessage'), 'FRIEND_INVITE_START', 'FRIEND_INVITE_NONE');
end

function FRIEND_INVITE_START()
	local frame = ui.GetFrame('friendinvite')
	local edit = GET_CHILD(frame, 'numberEdit')
	local CodeText = edit:GetText();
	RequestUseInviteEventCode(CodeText);
end

function FRIEND_INVITE_NONE()
end