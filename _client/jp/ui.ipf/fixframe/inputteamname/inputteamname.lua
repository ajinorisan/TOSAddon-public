
function INPUTTEAMNAME_ON_INIT(addon, frame)
	addon:RegisterMsg("INPUT_TEAMNAME_EXEC_RESULT", "INPUT_TEAMNAME_EXEC_RESULT");
end

function INPUT_TEAMNAME_OPEN(frame)
	local move = GET_CHILD_RECURSIVELY(frame, "move")
	if config.GetServiceNation() ~= "GLOBAL_KOR" then
		move:ShowWindow(0)
	elseif barrack.GetMoveAccountDataResult() == 100 then
		move:SetEnable(0)
	end
end

function INPUT_TEAMNAME_EXEC(parent, ctrl)
	local frame = parent:GetTopParentFrame();
	local bg = frame:GetChild("bg");
	local input = GET_CHILD(bg, "input", "ui::CEditControl");	
	local btn = bg:GetChild("btn");

	barrack.ChangeBarrackNameCheck(input:GetText(), "INPUT_TEAMNAME_EXEC_RESULT");
	input:SetEnable(0);
	btn:SetEnable(0);

	frame:SetUserValue("BeforName", "");
end

function INPUT_TEAMNAME_EXEC_RESULT(frame, msg, argStr, result)
	if result ~= 0 then		
        if result == -1 or result == -12 or result == -14 or result == -15 or result == -21 or result == -11 or result == -13 or result == -2 then
			ui.SysMsg(ClMsg("AlreadyorImpossibleName"));
		elseif result == -99 then
			-- 아무 메세지도 출력 안함
	    else
			ui.SysMsg(ClMsg("TeamNameChangeFailed"));
		end

		ReserveScript("INPUT_TEAMNAME_EXEC_UNFREEZE()", 2);
        return;
	end
	
	local frame = ui.GetFrame("inputteamname");
	local input = GET_CHILD_RECURSIVELY(frame, "input");
	local teamName = input:GetText();

	local msg = ScpArgMsg("PossibleChangeName_2{Name}", "Name", teamName).." {nl}"..ScpArgMsg("ReallCreate?");
	local msgBox = ui.MsgBox(msg, "CREATE_TEAM()", "INPUT_TEAMNAME_EXEC_UNFREEZE()");	
end

function CREATE_TEAM()
	local frame = ui.GetFrame("inputteamname");
	local input = GET_CHILD_RECURSIVELY(frame, "input");
	local teamName = input:GetText();

	barrack.ChangeBarrackName(input:GetText());
end

function INPUT_TEAMNAME_EXEC_UNFREEZE()
	local frame = ui.GetFrame("inputteamname");
	local ctrl = GET_CHILD_RECURSIVELY(frame, "btn");
	ctrl:SetEnable(1);

	local input = GET_CHILD_RECURSIVELY(frame, "input");
	input:SetEnable(1);
end
