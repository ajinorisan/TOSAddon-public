--  worldpvp_result.lua
function GET_SKILL_DEAL_TOOLTIP(skillDeals)
	local strList = StringSplit(skillDeals, "#");
	if #strList <= 1 then return ""; end
	local retStr = "";
	local skillCnt = #strList / 2;
	for i = 0 , skillCnt - 1 do
		local clsName = strList[2 * i + 1];
		local skillDeal = strList[2 * i + 2];
		local skillName;
		local sklCls = geSkillTable.Get(clsName);
		if sklCls == nil or true == sklCls.IsNormalAttack then
			skillName = ClMsg("NormalAttack");
		else
			skillName = GetClass("Skill", clsName).Name;
		end

		if i > 0 then
			retStr = retStr.."{nl}";
		end
		retStr = retStr..string.format("[%s] : %d", skillName, skillDeal);
	end
	return retStr;
end

function WORLDPVP_RESULT_UPDATE_EXITTIME(ctrl)
	local endTime = ctrl:GetUserValue("END_TIME");
	local curTime = imcTime.GetAppTime();
	local remainTime = math.floor(endTime - curTime);
	if remainTime < 0 then
		remainTime = 0;
	end

	local curValue = ctrl:GetTextByKey("value");
	if tonumber(curValue) ~= remainTime then
		ctrl:SetTextByKey("value", remainTime);
	end
	return 1;
end

function WORLDPVP_RESULT_UI(argStr)
	local frame = ui.GetFrame("worldpvp_result");
	if frame == nil then return; end

	local stringList = StringSplit(argStr, "\\");
	local winTeam = tonumber(stringList[1]);
	local autoExitTime = tonumber(stringList[2]);
	local autoexittext = frame:GetChild("autoexittext");
	autoexittext:SetTextByKey("value", math.floor(autoExitTime));
	autoexittext:SetUserValue("END_TIME", imcTime.GetAppTime() + math.floor(autoExitTime));
	autoexittext:RunUpdateScript("WORLDPVP_RESULT_UPDATE_EXITTIME", 0, 0, 0, 1);

	for i = 1 , 2 do
		local gbox = frame:GetChild("gbox_" .. i);
		local gbox_char = gbox:GetChild("gbox_char");
		gbox_char:RemoveAllChild();
		local result = GET_CHILD(frame, "result_" ..i);
		if winTeam > 0 then
			if winTeam == i then
				result:SetImage("test_pvp_win");
				gbox:SetSkinName('test_com_winbg');
			else
				result:SetImage("test_pvp_lose");
				gbox:SetSkinName('test_com_losebg');
			end
		else
			gbox:SetSkinName('test_com_winbg');
			result:SetImage("test_pvp_draw");
		end
	end

	local mvpChar = nil;
	local mvpTeam = nil;
	local maxScore = -1;
	local tokenPerChar = 13;
	local startIndex = 2;
	local charCount = (#stringList - startIndex) / tokenPerChar;
	local lastTeam = -1;
	for i = 0 , charCount - 1 do
		local indexBase = i * tokenPerChar + startIndex;
		local aid = stringList[indexBase + 1];
		local teamID = stringList[indexBase + 2];
		local remainPoint = tonumber(stringList[indexBase + 3]);
		local isConnected = stringList[indexBase + 4];
		local iconStr = stringList[indexBase + 5];
		local famName = stringList[indexBase + 6];
		local charName = stringList[indexBase + 7];
		local winPoint = stringList[indexBase + 8];
		local losePoint = stringList[indexBase + 9];
		local killCnt = stringList[indexBase + 10];
		local deathCnt = stringList[indexBase + 11];
		local dealAmount = tonumber(stringList[indexBase + 12]);
		local skillDeals = stringList[indexBase + 13];
		
		local iconInfo = ui.GetPCIconInfoByString(iconStr);
		local iconName = ui.CaptureModelHeadImage_IconInfo(iconInfo);

		local gbox = frame:GetChild("gbox_"..teamID);
		local gbox_char = gbox:GetChild("gbox_char");
		local ctrlSet = gbox_char:CreateControlSet("pvp_result_set", "RESULT_"..aid, ui.LEFT, ui.TOP, 0, 0, 0, 0);
		local pic = GET_CHILD(ctrlSet, "pic");
		pic:SetImage(iconName);
		local achieve = ctrlSet:GetChild("achieve");
		achieve:ShowWindow(0);

		local txt_name = GET_CHILD(ctrlSet, "txt_name");
		txt_name:SetTextByKey("value", famName);
		local txt_kill = GET_CHILD(ctrlSet, "txt_kill");
		txt_kill:SetTextByKey("value", killCnt);
		local txt_death = GET_CHILD(ctrlSet, "txt_death");
		txt_death:SetTextByKey("value", deathCnt);
		local txt_getpoint = GET_CHILD(ctrlSet, "txt_getpoint");
		if isConnected == "0" then
			txt_getpoint:SetTextByKey("value", 0);
		else
			if winTeam == tonumber(teamID) then
				txt_getpoint:SetTextByKey("value", winPoint);
			else
				txt_getpoint:SetTextByKey("value", losePoint);
			end
		end

		local txt_dealmount = GET_CHILD(ctrlSet, "txt_dealmount");
		txt_dealmount:SetTextByKey("value", "{#FF1111}" .. dealAmount);

		local tooltipStr = GET_SKILL_DEAL_TOOLTIP(skillDeals);
		if tooltipStr ~= "" then
			txt_dealmount:SetTextTooltip(tooltipStr);
		end

		if dealAmount > maxScore then
			mvpChar = aid;
			maxScore = dealAmount;
			mvpTeam = teamID;
		end
	end

	if mvpChar ~= nil then
		local gbox = frame:GetChild("gbox_" .. mvpTeam);
		local gbox_char = gbox:GetChild("gbox_char");
		local ctrlSet = gbox_char:GetChild("RESULT_" .. mvpChar);
		local achieve = ctrlSet:GetChild("achieve");
		achieve:ShowWindow(1);
		local txt_achieve = ctrlSet:GetChild("txt_achieve");
		txt_achieve:SetTextByKey("value", "MVP");
	end

	for i = 1 , 2 do
		local gbox = frame:GetChild("gbox_" .. i);
		local gbox_char = gbox:GetChild("gbox_char");
		GBOX_AUTO_ALIGN(gbox_char, 0, 0, 0, true, false);
		gbox_char:UpdateData();
	end

	frame:ShowWindow(1);
end

function TEAM_BATTLE_LEAGUE_RESULT_UI(win_team, auto_exit_time)
	local frame = ui.GetFrame("worldpvp_result");
	if frame == nil then return; end

	local auto_exit_text = GET_CHILD_RECURSIVELY(frame, "autoexittext");
	if auto_exit_text ~= nil then
		auto_exit_text:SetTextByKey("value", math.floor(auto_exit_time));
		auto_exit_text:SetUserValue("END_TIME", imcTime.GetAppTime() + math.floor(auto_exit_time));
		auto_exit_text:RunUpdateScript("WORLDPVP_RESULT_UPDATE_EXITTIME", 0, 0, 0, 1);
	end

	for i = 1, 2 do
		local gbox = GET_CHILD_RECURSIVELY(frame, "gbox_"..i);
		local result = GET_CHILD_RECURSIVELY(frame, "result_"..i);
		local gbox_char = GET_CHILD_RECURSIVELY(gbox, "gbox_char");
		gbox_char:RemoveAllChild();
		if win_team > 0 then
			if win_team == i then
				result:SetImage("test_pvp_win");
				gbox:SetSkinName('test_com_winbg');
			else
				result:SetImage("test_pvp_lose");
				gbox:SetSkinName('test_com_losebg');
			end
		else
			result:SetImage("test_pvp_draw");
			gbox:SetSkinName('test_com_winbg');
		end
	end

	local count = session.teambattleleauge.GetTeamBattleLeagueResultCount();
	for i = 0, count - 1 do
		local aid, team_id, remain_point, connected, icon_str, family_name, character_name, win_point, lose_point, kill_count, death_count, deal, skill_deals = GetTeamBattleLeagueResultInfoByIndex(i);
		local gbox = GET_CHILD_RECURSIVELY(frame, "gbox_"..team_id);
		if gbox ~= nil then
			local gbox_char = GET_CHILD_RECURSIVELY(gbox, "gbox_char");
			local ctrl_set = gbox_char:CreateControlSet("pvp_result_set", "RESULT_"..aid, ui.LEFT, ui.TOP, 0, 0, 0, 0);
			if ctrl_set ~= nil then
				local pic = GET_CHILD_RECURSIVELY(ctrl_set, "pic");
				if icon_str ~= "" and icon_str ~= "None" then
					local icon_info = ui.GetPCIconInfoByString(icon_str);
					local job_id = icon_info.job;
					local job_cls = GetClassByType("Job", job_id);
					if job_cls ~= nil then
						local icon_name = TryGetProp(job_cls, "Icon", "None");
						pic:SetImage(icon_name);
					end
				end

				local achieve = GET_CHILD_RECURSIVELY(ctrl_set, "achieve");
				achieve:ShowWindow(0);

				local name = GET_CHILD_RECURSIVELY(ctrl_set, "txt_name");
				name:SetTextByKey("value", family_name);

				local kill = GET_CHILD_RECURSIVELY(ctrl_set, "txt_kill");
				kill:SetTextByKey("value", kill_count);

				local death = GET_CHILD_RECURSIVELY(ctrl_set, "txt_death");
				death:SetTextByKey("value", death_count);

				local get_point = GET_CHILD_RECURSIVELY(ctrl_set, "txt_getpoint");
				if connected == false then
					get_point:SetTextByKey("value", 0);
				else
					if win_team == team_id then
						get_point:SetTextByKey("value", win_point);
					else
						get_point:SetTextByKey("value", lose_point);
					end
				end

				local deal_amount = GET_CHILD_RECURSIVELY(ctrl_set, "txt_dealmount");
				deal_amount:SetTextByKey("value", "{#FF1111}"..deal);

				local tooltip_str = GET_SKILL_DEAL_TOOLTIP(skill_deals);
				if tooltip_str ~= "" then
					deal_amount:SetTextTooltip(tooltip_str);
				end
			end
		end
	end

	local mvp_aid = session.teambattleleauge.GetTeamBattleLeaugeResultMVPAID();
	local mvp_team_id = session.teambattleleauge.GetTeamBattleLeaugeResultMVPTeamID();
	local mvp_deal = session.teambattleleauge.GetTeamBattleLeaugeResultMVPDealAmount();
	local gbox = GET_CHILD_RECURSIVELY(frame, "gbox_"..mvp_team_id);
	if gbox ~= nil then
		local gbox_char = GET_CHILD_RECURSIVELY(gbox, "gbox_char");
		local ctrl_set = GET_CHILD_RECURSIVELY(gbox_char, "RESULT_"..mvp_aid);
		if ctrl_set ~= nil then
			local achieve = GET_CHILD_RECURSIVELY(ctrl_set, "achieve");
			achieve:ShowWindow(1);
			local achieve_text = GET_CHILD_RECURSIVELY(ctrl_set, "txt_achieve");
			achieve_text:SetTextByKey("value", "MVP");
		end
	end

	for i = 1, 2 do
		local gbox = GET_CHILD_RECURSIVELY(frame, "gbox_"..i);
		local gbox_char = GET_CHILD_RECURSIVELY(gbox, "gbox_char");
		if gbox_char ~= nil then
			GBOX_AUTO_ALIGN(gbox_char, 0, 0, 0, true, false);
			gbox_char:UpdateData();
		end
	end
	frame:ShowWindow(1);
end

function WORLDPVP_RESULT_ENTER_CHAT(parent, ctrl)
	local text = ctrl:GetText();
	if text ~= "" then
		worldPVP.RequestChat(text, false);
		ctrl:SetText("");
	end
end

function ON_RECV_PVP_CHAT(from, chatText)
	local frame = ui.GetFrame("worldpvp_result");
	local gbox_chat = GET_CHILD(frame, "gbox_chat");
	local idx  = frame:GetUserIValue("TEXT_IDX");

	local title = gbox_chat:CreateControl('richtext', "TXT_"..idx, 10, 0, gbox_chat:GetWidth() - 30, 10);
	title:EnableHitTest(0);
	AUTO_CAST(title);

	local resultStr = string.format("{@st41}[%s] : %s", from, chatText);
	title:SetText(resultStr);

	idx = idx + 1;
	frame:SetUserValue("TEXT_IDX", idx);
	GBOX_AUTO_ALIGN(gbox_chat, 0, 10, 0, true, false);
	gbox_chat:UpdateData();
	gbox_chat:SetScrollPos(gbox_chat:GetLineCount() + gbox_chat:GetVisibleLineCount());
end

function WORLDPVP_RETURN_TO_ZONE()
	worldPVP.ReturnToOriginalServer();
end

function WROLDPVP_RESULT_DETAIL_OPEN()
	print("WROLDPVP_RESULT_DETAIL_OPEN");
	WROLDPVP_RESULT_DETAIL_OPEN();
end