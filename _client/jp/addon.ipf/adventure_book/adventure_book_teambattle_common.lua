function ADVENTURE_BOOK_TEAM_BATTLE_COMMON_INIT(adventureBookFrame, teamBattleRankingPage)
    local ret = worldPVP.RequestPVPInfo();
	if ret == false then -- 이미 데이타가 있음
		ADVENTURE_BOOK_TEAM_BATTLE_COMMON_UPDATE(adventureBookFrame);
	end

    -- ranking
    local rankingBox = teamBattleRankingPage:GetChild('teamBattleRankingBox');
    ADVENTURE_BOOK_TEAM_BATTLE_RANK(teamBattleRankingPage, rankingBox);
	
	local join = GET_CHILD_RECURSIVELY(teamBattleRankingPage, 'teamBattleMatchingBtn');
	join:SetEnable(IS_TEAM_BATTLE_ENABLE());

	local reward = GET_CHILD_RECURSIVELY(teamBattleRankingPage, 'teamBattleRewardBtn');
	local cid = session.GetMySession():GetCID();
	local myRank = session.worldPVP.GetPrevRankInfoByCID(cid);
	if myRank ~= nil and myRank.ranking < 3 then
		reward:SetEnable(1)
	else
		reward:SetEnable(0)
	end
end

function IS_TEAM_BATTLE_ENABLE()
	-- 트오세 W - 팀 배틀리그
	if CHECK_TOSW_TEAM_BATTLE_LEAGUE_RESTRICT_TIME()==true then 
		ui.SysMsg(ScpArgMsg('ContentsAlert_RestrictTime'));
		return 0
	end
    if session.colonywar.GetIsColonyWarMap() == false then
		local cnt = session.worldPVP.GetPlayTypeCount();
		if cnt > 0 then
			local isGuildBattle  = 0;
			for i = 1, cnt do
				local type = session.worldPVP.GetPlayTypeByIndex(i);
				if type == 210 then
					isGuildBattle = 1;
					break;
				end
			end

			if isGuildBattle == 0 then
				return 1
			end
		end
	end
	return 0
end

function GET_TEAM_BATTLE_CLASS()
	local pvp_cls = GetClass("WorldPVPType", "Three");
	return pvp_cls;
end

function ADVENTURE_BOOK_TEAM_BATTLE_COMMON_UPDATE(adventureBookFrame, msg, argStr, argNum)
	local pvp_cls = GET_TEAM_BATTLE_CLASS();
	if pvp_cls == nil then return; end
	
	local aid = session.loginInfo.GetAID();
	local pvp_obj = session.worldPVP.GetTeamBattlePVPObject(aid);
	if pvp_obj == nil then return; end
	
	local pvp_class_name = TryGetProp(pvp_cls, "ClassName", "None");
    local win_value = pvp_obj:GetPropValue(pvp_class_name.."_WIN");
	local lose_value = pvp_obj:GetPropValue(pvp_class_name.."_LOSE");
	local total_value = win_value + lose_value;
    local battle_history_value_text = GET_CHILD_RECURSIVELY(adventureBookFrame, "battleHistoryValueText");    
    battle_history_value_text:SetTextByKey("total", total_value);
    battle_history_value_text:SetTextByKey("win", win_value);
	battle_history_value_text:SetTextByKey("lose", lose_value);
	
	local point_info = session.worldPVP.GetTeamBattleRankInfoByAID(aid);
	local point_value = pvp_obj:GetPropValue(pvp_class_name.."_RP", 1000);
	if point_info ~= nil then
		point_value = point_info.point;
	end

	local battle_point_value_text = GET_CHILD_RECURSIVELY(adventureBookFrame, "battlePointValueText");
	battle_point_value_text:SetTextByKey("point", point_value);
end

function ADVENTURE_BOOK_TEAM_BATTLE_RANK(parent, teamBattleRankingBox)
	ADVENTURE_BOOK_RANKING_PAGE_SELECT(parent, teamBattleRankingBox, 'TeamBattle', 1);

	local topFrame = parent:GetTopParentFrame();
	local teamBattleRankSet = GET_CHILD_RECURSIVELY(topFrame, 'teamBattleRankSet');
	local pageCtrl = GET_CHILD(teamBattleRankSet, 'control');
	local prevBtn = GET_CHILD_RECURSIVELY(pageCtrl, 'prev');
	local nextBtn = GET_CHILD_RECURSIVELY(pageCtrl, 'next');
	prevBtn:SetEventScript(ui.LBUTTONUP, 'ADVENTURE_BOOK_RANKING_PAGE_SELECT_PREV');
	nextBtn:SetEventScript(ui.LBUTTONUP, 'ADVENTURE_BOOK_RANKING_PAGE_SELECT_NEXT');
end

function ADVENTURE_BOOK_TEAM_BATTLE_RANK_UPDATE(frame, msg, argStr, argNum)
	local rank_type = session.worldPVP.GetRankProp("Type");
	if rank_type == 210 then return; end

	local pvp_cls = GET_TEAM_BATTLE_CLASS();
	local pvp_type = TryGetProp(pvp_cls, "ClassID", 0);
	local type = rank_type;
	local league = session.worldPVP.GetRankProp("League");
	local page = session.worldPVP.GetRankProp("Page");
	local total_count = session.worldPVP.GetRankProp("TotalCount");
	
	local team_battle_rank_set = GET_CHILD_RECURSIVELY(frame, "teamBattleRankSet");
	local each_rank_set_height_for_tb = tonumber(team_battle_rank_set:GetUserConfig("EACH_RANK_SET_HEIGHT_FOR_TB"));

	local ranking_box = GET_CHILD_RECURSIVELY(team_battle_rank_set, "rankingBox");
	ranking_box:RemoveAllChild();

	local count = session.worldPVP.GetTeamBattleRankInfoCount();
	for i = 0, count - 1 do
		local info = session.worldPVP.GetTeamBattleRankInfoByIndex(i);
		if info ~= nil then
			local ctrl_set = ranking_box:CreateControlSet("pvp_rank_ctrl", "CTRLSET_"..i, ui.CENTER_HORZ, ui.TOP, 0, 0, 0, 0);
			if ctrl_set ~= nil then
				UPDATE_PVP_RANK_CTRLSET(ctrl_set, info);
				ctrl_set:Resize(ranking_box:GetWidth(), each_rank_set_height_for_tb);
			end
		end
	end
	GBOX_AUTO_ALIGN(ranking_box, 0, 0, 0, true, false);

	local total_page = math.floor((total_count + WORLDPVP_RANK_PER_PAGE) / WORLDPVP_RANK_PER_PAGE);
	local control = GET_CHILD(team_battle_rank_set, 'control', 'ui::CPageController')
	control:SetMaxPage(total_page);
	control:SetCurPage(page - 1);

	local reward = GET_CHILD_RECURSIVELY(frame, 'teamBattleRewardBtn');
	local aid = session.loginInfo.GetAID();
	local my_rank = session.worldPVP.GetTeamBattlePrevRankInfoByAID(aid);
	if my_rank ~= nil and my_rank.ranking < 3 then
		reward:SetEnable(1);
	else
		reward:SetEnable(0);		
	end
end

local cannot_join_buff_list = {
	TeamBattleLeague_Penalty_Lv1 = 'HasTeamBattleLeaguePenalty',
	TeamBattleLeague_Penalty_Lv2 = 'HasTeamBattleLeaguePenalty',
	secret_medicine_str_470 = 'CantJoinPVPCuzSecretMedicine',
	secret_medicine_int_470 = 'CantJoinPVPCuzSecretMedicine',
	secret_medicine_con_470 = 'CantJoinPVPCuzSecretMedicine',
	secret_medicine_str_500 = 'CantJoinPVPCuzSecretMedicine',
	secret_medicine_int_500 = 'CantJoinPVPCuzSecretMedicine',
	secret_medicine_con_500 = 'CantJoinPVPCuzSecretMedicine',
	secret_medicine_mspd_470 = 'CantJoinPVPCuzSecretMedicine',
	secret_medicine_mspd2_470 = 'CantJoinPVPCuzSecretMedicine',
	secret_medicine_rsp_470 = 'CantJoinPVPCuzSecretMedicine',
}
function ADVENTURE_BOOK_JOIN_WORLDPVP(parent, ctrl)
    if IS_IN_EVENT_MAP() == true then
        ui.SysMsg(ClMSg('ImpossibleInCurrentMap'));
        return;
    end 

	local accObj = GetMyAccountObj();
	for _name, _clmsg in pairs(cannot_join_buff_list) do
		if IsBuffApplied(GetMyPCObject(), _name) == "YES" then
			ui.SysMsg(ClMsg(_clmsg));
			return;
		end
	end
	
	local cls = GET_TEAM_BATTLE_CLASS();
	if nil == cls then
		ui.SysMsg(ScpArgMsg("DonotOpenPVP"))
		return;
	end	

    local pvpType = cls.ClassID;
	if IsBuffApplied(GetMyPCObject(), "UNKNOWN_SANTUARY_PC") == "YES" then 
	local state = session.worldPVP.GetState();
	if state == PVP_STATE_NONE then
			local top_frame_name = parent:GetTopParentFrame():GetName();
			local parent_name = parent:GetName();
			local yes_scp = string.format("ADVENTURE_BOOK_JOIN_WORLDPVP_UNKNOWN_SANTUARTY_PC_BUFF_YES_SCP(\"%s\",\"%s\",\"%d\")", top_frame_name, parent_name, pvpType);
			ui.MsgBox(ClMsg("WorldPVP_JoinCheck_UnknownSantuaryPCBuff"), yes_scp, "None");
				 return;
			end
			end
	JOIN_WORLDPVP_BY_TYPE(parent, pvpType);
				return;
			end
		
function ADVENTURE_BOOK_JOIN_WORLDPVP_UNKNOWN_SANTUARTY_PC_BUFF_YES_SCP(frame_name, parent_name, pvp_type)
	local frame = ui.GetFrame(frame_name);
	local parent = GET_CHILD_RECURSIVELY(frame, parent_name);
	if parent ~= nil then
		JOIN_WORLDPVP_BY_TYPE(parent, pvp_type);
		end
end

function ADVENTURE_BOOK_TEAM_BATTLE_STATE_CHANGE(frame, msg, argStr, argNum)
	local state = session.worldPVP.GetState();
	local stateText = GetPVPStateText(state);
	local viewText = ClMsg( "PVP_State_".. stateText );
	local join = GET_CHILD_RECURSIVELY(frame, 'teamBattleMatchingBtn');
	join:SetTextByKey("text", viewText);

	if state == PVP_STATE_FINDING then
        ADVENTURE_BOOK_TEAM_BATTLE_COMMON_UPDATE(frame);
	elseif state == PVP_STATE_READY then
		local cls = GET_TEAM_BATTLE_CLASS();
		if cls.MatchType ~= "Guild" then
			return;
		end
		local isLeader = AM_I_LEADER(PARTY_GUILD);
		if 1 ~= isLeader then
			return;
		end
		ui.Chat("/sendMasterEnter");
	end
	if 1 == ui.IsFrameVisible("worldpvp_ready") then
		WORLDPVP_READY_STATE_CHANGE(state, pvpType);
	end
end

function ADVENTURE_BOOK_TEAM_BATTLE_HISTORY_UPDATE(frame, msg, argStr, argNum)
end

function ADVENTURE_BOOK_TEAM_BATTLE_SEARCH(parent, ctrl)
    local topFrame = parent:GetTopParentFrame();
    local teamBattleRankSet = GET_CHILD_RECURSIVELY(topFrame, 'teamBattleRankSet');
    local control = GET_CHILD(teamBattleRankSet, 'control');
    local page = control:GetCurPage();
    local adventureBookRankSearchEdit = GET_CHILD_RECURSIVELY(teamBattleRankSet, 'adventureBookRankSearchEdit');
    local teamBattleCls = GET_TEAM_BATTLE_CLASS();
	local searchText = adventureBookRankSearchEdit:GetText();
    if searchText == nil or searchText == '' then
		worldPVP.RequestPVPRanking(teamBattleCls.ClassID, 0, -1, 1, 0, '');
	else		
		worldPVP.RequestPVPRanking(teamBattleCls.ClassID, 0, -1, page, 0, adventureBookRankSearchEdit:GetText());
	end
	ui.DisableForTime(control, 0.5);
end

function WORLDPVP_PUBLIC_GAME_LIST(frame, msg, argStr, argNum)
	local is_guild_pvp = 0;
	if frame:IsVisible() == 0 then is_guild_pvp = 1; end

	local bg_observer = GET_CHILD_RECURSIVELY(frame, "bg_observer");
	local CTRLSET_OFFSET = bg_observer:GetUserConfig('CTRLSET_OFFSET');

	local gbox = bg_observer:GetChild("gbox");
	gbox:RemoveAllChild();

	local world_pvp_frame = ui.GetFrame("worldpvp");
	local game_index_list = WORLDPVP_PUBLIC_GAME_LIST_BY_TYPE(is_guild_pvp);

	local ctrl_set_y = 0;
	--local max_count = 3;
	--local cnt = math.min(#game_index_list, max_count);
	local cnt = #game_index_list;
	for i = 1, cnt do
		local index = game_index_list[i];
		if index ~= nil then
			local info = session.worldPVP.GetPublicGameByIndex(index);
			local ctrl_set = gbox:CreateControlSet("pvp_observe_ctrlset", "CTRLSET_"..i, 0, ctrl_set_y);
			if ctrl_set ~= nil then
				ctrl_set:SetUserValue("GAME_ID", info.guid);
				local gbox_pc = ctrl_set:GetChild("gbox_pc");
				local gbox_ctrl_set = ctrl_set:GetChild("gbox");
				local gbox_whole = ctrl_set:GetChild("gbox_whole");

				local gbox_1 = ctrl_set:GetChild("gbox_1");
				local teamVec1 = info:CreateTeamInfo(1);
				WORLDPVP_PUBLIC_GAME_SET_PCTEAM(frame, gbox_1, teamVec1, 1);
				SET_VS_NAMES(world_pvp_frame, ctrl_set, 1, WORLDPVP_PUBLIC_GAME_SET_PCTEAM(frame, gbox_1, teamVec1, 1));

				local gbox_2 = ctrl_set:GetChild("gbox_2");
				local teamVec2 = info:CreateTeamInfo(2);
				SET_VS_NAMES(world_pvp_frame, ctrl_set, 2, WORLDPVP_PUBLIC_GAME_SET_PCTEAM(frame, gbox_2, teamVec2, 2));		

				local height_add_value = 7;
				local height = math.max(gbox_1:GetHeight(), gbox_2:GetHeight()) + height_add_value;
				gbox_ctrl_set:Resize(gbox_ctrl_set:GetWidth(), height);
				
				local btn = ctrl_set:GetChild("btn");
				ctrl_set:Resize(ctrl_set:GetWidth(), height + btn:GetHeight() + height_add_value + 45);
				gbox_whole:Resize(ctrl_set:GetWidth(), height + btn:GetHeight() + height_add_value +50);

				ctrl_set_y = ctrl_set_y + ctrl_set:GetHeight() + CTRLSET_OFFSET;
			end
		end
	end
end