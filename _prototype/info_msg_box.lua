function INFO_MSG_BOX_ON_INIT(addon, frame)
	addon:RegisterMsg('INFO_MSG_BOX_SHOW_TXT', 'ON_INFO_MSG_BOX_SHOW_TXT')
end

function INFO_MSG_BOX_SET_TXT(info_txt)
	local frame = ui.GetFrame('info_msg_box')
	if frame:IsVisible() ~= 1 then
		frame:ShowWindow(1)
	end

	local infoTxt = GET_CHILD_RECURSIVELY(frame, 'infoTxt')
	infoTxt:SetTextByKey('value', info_txt)

	local def_height = tonumber(frame:GetUserConfig('DEF_HEIGHT'))
	local margin = tonumber(frame:GetUserConfig('MARGIN_TOP_BOTTOM'))
	local txt_height = infoTxt:GetHeight()
	local height_sum = txt_height + (margin * 2)
	if height_sum > def_height then
		frame:Resize(frame:GetWidth(), height_sum)
	else
		frame:Resize(frame:GetWidth(), def_height)
	end
end

function INFO_MSG_BOX_CLOSE()
	ui.CloseFrame('info_msg_box')
end

function ON_INFO_MSG_BOX_SHOW_TXT(frame, msg, argStr, argNum)
	INFO_MSG_BOX_SET_TXT(ClMsg(argStr))
end