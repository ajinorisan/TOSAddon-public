--  worldpvp_result_deatil.lua
function WROLDPVP_RESULT_DETAIL_ON_INIT(addon, frame)
end

function WROLDPVP_RESULT_DETAIL_OPEN()
	ui.OpenFrame("worldpvp_result_detail");
	local frame = ui.GetFrame("worldpvp_result_detail");
	if frame ~= nil then
		WROLDPVP_RESULT_DETAIL_CREATE_LIST(frame);
	end
end

function WROLDPVP_RESULT_DETAIL_CREATE_LIST(frame)
	if frame == nil then return; end
	local my_team_id = session.teambattleleauge.GetTeamBattleLeagueResultMyTeamID();
	if my_team_id ~= 0 then
		WROLDPVP_RESULT_DETAIL_MY_TEAM_CREATE_LIST(frame, my_team_id);
		WORLDPVP_RESULT_DETAIL_OTHER_TEAM_CREATE_LIST(frame, my_team_id);
	elseif my_team_id == 0 then
		WROLDPVP_RESULT_DETAIL_MY_TEAM_CREATE_LIST(frame, 1);
		WORLDPVP_RESULT_DETAIL_OTHER_TEAM_CREATE_LIST(frame, 1);
	end

	-- mvp
	local mvp_aid = session.teambattleleauge.GetTeamBattleLeaugeResultMVPAID();
	local mvp_team_id = session.teambattleleauge.GetTeamBattleLeaugeResultMVPTeamID();
	local mvp_deal = session.teambattleleauge.GetTeamBattleLeaugeResultMVPDealAmount();
	local gbox = GET_CHILD_RECURSIVELY(frame, "gbox_team"..mvp_team_id);
	if gbox ~= nil then
		local ctrl_set = GET_CHILD_RECURSIVELY(gbox, "DETAIL_"..mvp_aid);
		if ctrl_set ~= nil then
			local achieve = GET_CHILD_RECURSIVELY(ctrl_set, "achieve");
			achieve:ShowWindow(1);
			local achieve_text = GET_CHILD_RECURSIVELY(ctrl_set, "txt_achieve");
			achieve_text:SetTextByKey("value", "MVP");
		end
	end

	-- align
	for i = 1, 2 do
		local gbox = GET_CHILD_RECURSIVELY(frame, "gbox_team"..i);
		if gbox ~= nil then
			GBOX_AUTO_ALIGN(gbox, 0, 0, 0, true, false);
			gbox:UpdateData();
		end
	end
end

function WROLDPVP_RESULT_DETAIL_MY_TEAM_CREATE_LIST(frame, my_team_id)
	if frame == nil then return; end
	local count = session.teambattleleauge.GetTeamBattleLeagueResultCount();
	for i = 0, count - 1 do
		local aid, team_id, reamin_point, connected, icon_str, family_name, character_name = GetTeamBattleLeagueResultInfoByIndex(i);
		if team_id == my_team_id then
			local gbox = GET_CHILD_RECURSIVELY(frame, "gbox_team1");
			if gbox ~= nil then
				WORLDPVP_RESULT_DETAIL_SET_TITLE(frame, 1, my_team_id);
				local ctrl_set = gbox:CreateOrGetControlSet("pvp_result_detail", "DETAIL_"..aid, ui.LEFT, ui.TOP, 0, 0, 0, 0);
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
	
					local attack_damage = session.teambattleleauge.GetResultDetailDamage(aid, "AttackDamage");
					attack_damage = GET_COMMAED_STRING(attack_damage);
					local txt_attack_deal = GET_CHILD_RECURSIVELY(ctrl_set, "txt_attack_deal");
					txt_attack_deal:SetText(attack_damage);
	
					local take_damage = session.teambattleleauge.GetResultDetailDamage(aid, "DefenceDamage");
					take_damage = GET_COMMAED_STRING(take_damage);
					local txt_take_deal = GET_CHILD_RECURSIVELY(ctrl_set, "txt_take_deal");
					txt_take_deal:SetText(take_damage);
					
					local give_heal = session.teambattleleauge.GetResultDetailHeal(aid, "GiveHeal");
					give_heal = GET_COMMAED_STRING(give_heal);
					local txt_give_heal = GET_CHILD_RECURSIVELY(ctrl_set, "txt_give_heal");
					txt_give_heal:SetText(give_heal);
	
					local take_heal = session.teambattleleauge.GetResultDetailHeal(aid, "TakeHeal");
					take_heal = GET_COMMAED_STRING(take_heal);
					local txt_take_heal = GET_CHILD_RECURSIVELY(ctrl_set, "txt_take_heal");
					txt_take_heal:SetText(take_heal);
				end
			end
		end
	end
end

function WORLDPVP_RESULT_DETAIL_OTHER_TEAM_CREATE_LIST(frame, my_team_id)
	if frame == nil then return; end
	local count = session.teambattleleauge.GetTeamBattleLeagueResultCount();
	for i = 0, count - 1 do
		local aid, team_id, reamin_point, connected, icon_str, family_name, character_name = GetTeamBattleLeagueResultInfoByIndex(i);
		if team_id ~= my_team_id then
			local gbox = GET_CHILD_RECURSIVELY(frame, "gbox_team2");
			if gbox ~= nil then
				WORLDPVP_RESULT_DETAIL_SET_TITLE(frame, 2, team_id);
				local ctrl_set = gbox:CreateOrGetControlSet("pvp_result_detail", "DETAIL_"..aid, ui.LEFT, ui.TOP, 0, 0, 0, 0);
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
	
					local attack_damage = session.teambattleleauge.GetResultDetailDamage(aid, "AttackDamage");
					attack_damage = GET_COMMAED_STRING(attack_damage);
					local txt_attack_deal = GET_CHILD_RECURSIVELY(ctrl_set, "txt_attack_deal");
					txt_attack_deal:SetText(attack_damage);
	
					local take_damage = session.teambattleleauge.GetResultDetailDamage(aid, "DefenceDamage");
					take_damage = GET_COMMAED_STRING(take_damage);
					local txt_take_deal = GET_CHILD_RECURSIVELY(ctrl_set, "txt_take_deal");
					txt_take_deal:SetText(take_damage);
					
					local give_heal = session.teambattleleauge.GetResultDetailHeal(aid, "GiveHeal");
					give_heal = GET_COMMAED_STRING(give_heal);
					local txt_give_heal = GET_CHILD_RECURSIVELY(ctrl_set, "txt_give_heal");
					txt_give_heal:SetText(give_heal);
	
					local take_heal = session.teambattleleauge.GetResultDetailHeal(aid, "TakeHeal");
					take_heal = GET_COMMAED_STRING(take_heal);
					local txt_take_heal = GET_CHILD_RECURSIVELY(ctrl_set, "txt_take_heal");
					txt_take_heal:SetText(take_heal);
				end
			end
		end
	end
end

function WORLDPVP_RESULT_DETAIL_SET_TITLE(frame, gbox_id, team_id)
	local team_id_text = GET_CHILD_RECURSIVELY(frame, "team_id_text"..gbox_id);
	if team_id_text ~= nil then
		local text = ScpArgMsg("WorldPVPResultDeatilTeamTitle", "TeamID", team_id);
		team_id_text:SetTextByKey("value", text);
	end
end