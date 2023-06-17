
function INPUTMOVECODE_ON_INIT(addon, frame)
	addon:RegisterMsg("MOVE_ACCOUNT_DATA_FAILED", "INPUTMOVECODE_ON_MSG")
	addon:RegisterMsg("MOVE_ACCOUNT_DATA_SUCCESS", "INPUTMOVECODE_ON_MSG")
end

function INPUTMOVECODE_OPEN(frame)
	if config.GetServiceNation() ~= "GLOBAL_KOR" then
		frame:ShowWindow(0)
		return
	end

	local input = GET_CHILD_RECURSIVELY(frame, "input")
	input:SetText('')

	local close = GET_CHILD_RECURSIVELY(frame, "close")
	close:SetEnable(1)
end

function CANCEL_INPUT_MOVECODE()
	ui.CloseFrame("inputmovecode")	
	ui.OpenFrame("inputteamname")
end

function _UPDATE_INPUTMOVECODE(ctrl, elapsedTime)
	local cnt = ctrl:GetUserIValue("UPDATE_COUNT")
	local sec = math.modf(elapsedTime)
	if sec == cnt then
		ui.MsgBox(ClMsg("DoingMoveAccountData"))
		ctrl:SetUserValue("UPDATE_COUNT", cnt + 1)
	end
end

function MOVE_ACCOUNT_DATA_END()
	ui.CloseFrame("inputmovecode")
end

function REQ_MOVE_ACCOUNT_DATA(btn, parent, argStr, argNum)
	local str = ClMsg("ReallyMoveAccountData")
    local msgbox = ui.MsgBox(str, "_REQ_MOVE_ACCOUNT_DATA", "None")
    SET_MODAL_MSGBOX(msgbox)
end

function _REQ_MOVE_ACCOUNT_DATA()
	local frame = ui.GetFrame("inputmovecode")
	if frame == nil then return end

	local input = GET_CHILD_RECURSIVELY(frame, "input")
	if input == nil then return end

	local close = GET_CHILD_RECURSIVELY(frame, "close")
	local btn = GET_CHILD_RECURSIVELY(frame, "btn")

	close:SetEnable(0)
	btn:SetEnable(0)

	frame:RunUpdateScript("_UPDATE_INPUTMOVECODE", 0, 0, 0, 1)

	barrack.ReqMoveAccountData(input:GetText())
end

function INPUTMOVECODE_ON_MSG(frame, msg, argStr, argNum)
	if msg == "MOVE_ACCOUNT_DATA_FAILED" then
		FAILED_MOVE_ACCOUNT_DATA(frame, msg, argStr, argNum)
	elseif msg == "MOVE_ACCOUNT_DATA_SUCCESS" then
		SUCCESS_MOVE_ACCOUNT_DATA(frame, msg, argStr, argNum)
	end
end

function FAILED_MOVE_ACCOUNT_DATA(frame, msg, argStr, argNum)
	frame:StopUpdateScript("_UPDATE_INPUTMOVECODE")

	local frame = ui.GetFrame("inputmovecode")
	local close = GET_CHILD_RECURSIVELY(frame, "close")
	local btn = GET_CHILD_RECURSIVELY(frame, "btn")

	close:SetEnable(1)
	btn:SetEnable(1)

	local failCount = argNum
	local timeDiff = tonumber(argStr)
	if failCount > 0 and timeDiff > 0 then
		ui.MsgBox(ScpArgMsg("CannotUseCodeCuzSpentAllCount{Count}{TimeLeft}", "Count", tostring(failCount), "TimeLeft", GET_TIME_TXT(timeDiff)))
	elseif failCount > 0 then
		ui.MsgBox(ScpArgMsg("IncorrectMoveDataCode{Count}", "Count", tostring(5 - failCount)))
	end
end

function SUCCESS_MOVE_ACCOUNT_DATA(frame, msg, argStr, argNum)
	frame:StopUpdateScript("_UPDATE_INPUTMOVECODE")

	ui.MsgBox(ClMsg("SuccessMoveAccountData"))

	ReserveScript("MOVE_ACCOUNT_DATA_END()", 1)
end