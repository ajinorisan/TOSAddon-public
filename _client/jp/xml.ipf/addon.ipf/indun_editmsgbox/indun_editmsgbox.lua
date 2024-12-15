function INDUN_EDITMSGBOX_ON_INIT(addon, frame)
end

function INDUN_EDITMSGBOX_FRAME_OPEN(type, clmsg, desc, yesScp, noScp, min_number, max_number, default_number)
	ui.OpenFrame("indun_editmsgbox")

	local frame = ui.GetFrame('indun_editmsgbox');
	frame:EnableHide(1);
	frame:SetUserValue("user_value", type);
	
	local text = GET_CHILD_RECURSIVELY(frame, "text");
	text:SetText(clmsg);
	
	local text_desc = GET_CHILD_RECURSIVELY(frame, "text_desc");
	text_desc:SetText(desc);

	local edit = GET_CHILD_RECURSIVELY(frame, "edit");
	edit:SetText(default_number);
	edit:SetNumberMode(1);
	edit:SetMaxNumber(max_number);
	edit:SetMinNumber(min_number);
	edit:AcquireFocus();
    
	local yesBtn = GET_CHILD_RECURSIVELY(frame, "yesBtn", "ui::CButton")
	yesBtn:SetEventScript(ui.LBUTTONUP, '_INDUN_EDITMSGBOX_FRAME_OPEN_YES');
	yesBtn:SetEventScriptArgString(ui.LBUTTONUP, yesScp);

	local noBtn = GET_CHILD_RECURSIVELY(frame, "noBtn", "ui::CButton")
	noBtn:SetEventScript(ui.LBUTTONUP, '_INDUN_EDITMSGBOX_FRAME_OPEN_NO');
	noBtn:SetEventScriptArgString(ui.LBUTTONUP, noScp);

	yesBtn:ShowWindow(1);
    noBtn:ShowWindow(1);
end

function _INDUN_EDITMSGBOX_FRAME_OPEN_YES(parent, ctrl, argStr, argNum)
    local edit = GET_CHILD_RECURSIVELY(parent, "edit")
    local text = edit:GetText();
	local scp = _G[argStr]
	if scp ~= nil then
		local user_value = tonumber(parent:GetUserValue("user_value"));
		scp(user_value, text)
    end
	ui.CloseFrame("indun_editmsgbox");
end

function _INDUN_EDITMSGBOX_FRAME_OPEN_NO(parent, ctrl, argStr, argNum)
	local scp = _G[argStr]
	if scp ~= nil then
		scp()
    end
	ui.CloseFrame("indun_editmsgbox");
end