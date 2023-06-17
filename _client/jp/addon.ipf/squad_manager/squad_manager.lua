-- squad_manager.lua
local g_curContentsNum = 0
local g_contentsNum = 2
local g_squadType = 0
local height = 0
local scrolledTime = 0
local curPage = 0

function SQUAD_MANAGER_ON_INIT(addon, frame)
    addon:RegisterMsg('RANK_SYSTEM_TIMETABLE', 'ON_SQUAD_SYSTEM_TIMETABLE')
	addon:RegisterMsg('RANK_SYSTEM_DATA', 'ON_SQUAD_SYSTEM_DATA')
    addon:RegisterMsg('RANK_SYSTEM_MY_DATA', 'ON_SQUAD_SYSTEM_MY_DATA')

	addon:RegisterMsg('SQUAD_CREATED','SQUAD_MANAGER_RELOAD')
	addon:RegisterMsg('SQUAD_DISBANDED', 'SQUAD_MANAGER_RELOAD')
    addon:RegisterMsg('SQUAD_MEMBER_REMOVE', 'SQUAD_MANAGER_RELOAD')
	addon:RegisterMsg('SQUAD_MEMBER_ADD', 'SQUAD_MANAGER_RELOAD')
    addon:RegisterMsg('ON_OTHER_PC_INFO_FOR_ACT', 'SQUAD_MANAGER_JOB_PORTRAIT')
	
end

function SQUAD_MANAGER_FRAME_OPEN(frame)
	help.RequestAddHelp('TUTO_PILGRIM_1')
	
	height = 0
	g_contentsNum = 3
	local contentsCls = GetClassByType("rank_system_contents_list", g_contentsNum)
	g_squadType = TryGetProp(contentsCls, "SquadType", 0)
	ui.CloseFrame("induninfo")

	local tab = GET_CHILD_RECURSIVELY(frame,"season_tab")
	tab:ChangeTab(0)
	SQUAD_MANAGER_SEASON_SELECT(frame, tab)

	SQUAD_MANAGER_INIT_SQUAD_NAME(frame)
	SQUAD_MANAGER_INIT_CONTENT_TEXT(frame)
	SQUAD_MANAGER_INIT_MEMBERLIST(frame)
	SQUAD_MANAGER_MY_RANK_UI_INIT(frame)
	SQUAD_MANAGER_RANKING_SEASON_SET(frame)
	SQUAD_MANAGER_SHOW_GROUP_UI()
end

function SQUAD_MANAGER_FRAME_OPEN_BTN(parent, self, argStr, argNum)
	g_squadType = argNum
	ui.OpenFrame("squad_manager")
	ui.CloseFrame("party")
end

function SQUAD_MANAGER_FRAME_CLOSE()
	ui.CloseFrame("contentslist")
	ui.CloseFrame("squad_manager")
end

function SQUAD_MANAGER_FRAME_INIT(frame)


end

function PARTY_SQUAD_CREATE(parent, self, argStr, argNum)
	OPEN_SQUAD_CREATE_UI(argNum)
end

function SQUAD_MANAGER_RELOAD(frame)
	SQUAD_MANAGER_INIT_MEMBERLIST(frame)
	SQUAD_MANAGER_INIT_SQUAD_NAME(frame)
	SQUAD_MANAGER_MY_RANK_UI_INIT(frame)
	SQUAD_MANAGER_SHOW_GROUP_UI()
end

function SQUAD_MANAGER_INIT_SQUAD_NAME(frame)
	local squadCurName = GET_CHILD_RECURSIVELY(frame, "squad_curName")
	local squadName = session.SquadSystem.GetSquadName(g_squadType)
	if squadName == "None" then
		squadName =  ScpArgMsg('SquadNumber{index}', 'index', g_squadType + 1)
	end
	squadCurName:SetTextByKey("name", squadName)
end

function SQUAD_MANAGER_INIT_CONTENT_TEXT(frame)
	local contentsText = GET_CHILD_RECURSIVELY(frame, "content_text")
	local currentContents = GetClassByType("rank_system_contents_list", g_contentsNum)
	local contentsName = TryGetProp(currentContents, "Name")
	contentsText:SetTextByKey("value", contentsName)
end


function SQUAD_MANAGER_INIT_MEMBERLIST(frame)
	local memberInfogb = GET_CHILD_RECURSIVELY(frame, "memberinfo_box")
	local squadMemberList = session.SquadSystem.GetSquadMemberList(g_squadType)
	local count = squadMemberList:Count()

	memberInfogb:RemoveAllChild()

	for i = 0, count - 1 do
		local memberInfoCtrl = memberInfogb:CreateOrGetControlSet("squad_member_info", "member_info_"..i, 2, i * 102);
		local nameText = GET_CHILD(memberInfoCtrl, "name_text")
		local positionText = GET_CHILD(memberInfoCtrl, "position_text")
		local leaderImg = GET_CHILD(memberInfoCtrl, "leader_img");

		local memberName = squadMemberList:Element(i)

		if i ~= 0 then
			leaderImg:ShowWindow(0);
			nameText:SetOffset(leaderImg:GetX(), 9);
		end

		memberInfoCtrl:SetEventScript(ui.RBUTTONUP, "CONTEXT_SQUAD");
		memberInfoCtrl:SetEventScriptArgString(ui.RBUTTONUP, memberName);

		nameText:SetTextByKey("name", memberName);
		SQUAD_MANAGER_SET_PORTRAIT(memberInfoCtrl, memberName)
	end

	local isMySquad = session.SquadSystem.IsMySquad(g_squadType)
	if count < 5 and isMySquad == true then
		memberInfogb:CreateOrGetControlSet("squad_member_add", "member_add", 2, count * 102);
	end
end

function SQUAD_MANAGER_SHOW_CONTENTS(frame)
	local contentsListGb = GET_CHILD(frame, "gb_contentslist")
	
	contentsListGb:RemoveAllChild()
	local list, cnt = GetClassList("rank_system_contents_list");
	local num = 0
	for i = 0, cnt - 1 do
		local cls = GetClassByIndexFromList(list, i);
		local category = TryGetProp(cls, "Category")
		if category == "Tribuation" then
			local contentCtrl = contentsListGb:CreateOrGetControlSet("contentslist_ctrl", "squad_content_"..num, 0, num * 32);
			local nameText = GET_CHILD(contentCtrl, "contents_name")
			local btn = GET_CHILD(contentCtrl, "btn")
			local name = TryGetProp(cls, "Name")
			local contentsNum = TryGetProp(cls, "ClassID")
			btn:SetEventScriptArgNumber(ui.LBUTTONUP, contentsNum)
			nameText:SetTextByKey("value", name)
			num = num + 1
		end
	end
end

function SQUAD_MANAGER_CONTENTS_SELECT_BTN(parent, self, argStr, argNum)
	local frame = parent:GetTopParentFrame()
	local squadFrame = ui.GetFrame("squad_manager")
	local rankInfoBox = GET_CHILD_RECURSIVELY(squadFrame, "rank_info_box")
	rankInfoBox:RemoveAllChild();
	height = 0
	g_contentsNum = argNum

	local contentsCls = GetClassByType("rank_system_contents_list", g_contentsNum)
	g_squadType = TryGetProp(contentsCls, "SquadType", 0)


	SQUAD_MANAGER_INIT_CONTENT_TEXT(squadFrame)
	SQUAD_MANAGER_INIT_SQUAD_NAME(squadFrame)
	SQUAD_MANAGER_INIT_MEMBERLIST(squadFrame)
	SQUAD_MANAGER_RANKING_SEASON_SET(squadFrame)
	SQUAD_MANAGER_SHOW_GROUP_UI()
	frame:ShowWindow(0);

	local tab = GET_CHILD_RECURSIVELY(squadFrame,"season_tab")
	tab:ChangeTab(0)
	SQUAD_MANAGER_SEASON_SELECT(squadFrame, tab)
end

function SQUAD_MANAGER_INVITE_MEMBER()
	local frame = ui.GetFrame("squad_manager");
	INPUT_STRING_BOX_CB(frame, ScpArgMsg("PlzInputInviteName"), "SQUAD_MANAGER_INVITE_EXEC", "",nil,nil,20);
end

function SQUAD_MANAGER_SQUAD_SELECT(parent, self)
	g_squadType = self:GetSelItemKey()

end

function SQUAD_MANAGER_CREATE_SQUAD()
	OPEN_SQUAD_CREATE_UI(g_squadType)
end

function SQUAD_MANAGER_DISBAND_SQUAD()
	local yesscp = string.format('squad_system.DisbandSquad(%d)', g_squadType);
	ui.MsgBox_NonNested(ClMsg("YouAreLeader_ReallyDestoryParty?"), "DisbandSquad", yesscp, 'None');
end

function SQUAD_MANAGER_LEAVE_SQUAD()
	local yesscp = string.format('squad_system.LeaveSquad(%d)', g_squadType);
	local contentsCls = GetClassByType("rank_system_contents_list", g_contentsNum)
	local contetnsName = TryGetProp(contentsCls, "Name", "None")
	local msg = ScpArgMsg("ReallyLeaveFromGroup?", "Contents", contetnsName)
	ui.MsgBox_NonNested(msg, "LeaveSquad", yesscp, 'None');
end

function SQUAD_MANAGER_INVITE_EXEC(parent, name)
	squad_system.InviteSquadMember(g_squadType, name)
end

function SQUAD_MANAGER_ACCEPT_INVITE(partyName)
	squad_system.ResponseInvitedSquad(partyName, 1)
end

function SQUAD_MANAGER_DECLINE_INVITE(partyName)
	squad_system.ResponseInvitedSquad(partyName, 0)
end


function SQUAD_MANAGER_KICK_MEMBER(targetName)
	local yesscp = string.format('squad_system.KickSquadMember(%d, \"%s\")', g_squadType, targetName);
	local contentsCls = GetClassByType("rank_system_contents_list", g_contentsNum)
	local contetnsName = TryGetProp(contentsCls, "Name", "None")
	local msg = ScpArgMsg("ReallyKickFromGroup?", "Contents", contetnsName, "Team", targetName)
	ui.MsgBox_NonNested(msg, "KickSquadMember", yesscp, 'None');
end


function SQUAD_MANAGER_REQUEST_RANK(prev)
	local frame = ui.GetFrame("squad_manager");

	frame:SetUserValue("PREV", prev)

	RequestRankSystemTimeTable(g_contentsNum)
end

function SQUAD_MANAGER_REQUEST_REWARD()
	local frame = ui.GetFrame("squad_manager");
    local prev = frame:GetUserIValue("PREV")
	RANKSYSTEMREWARD_SHOW(4, prev, g_contentsNum)
end

function SQUAD_MANAGER_SHOW_GROUP_UI()
	local squadExist = session.SquadSystem.GetSquadName(g_squadType) ~= "None"

	local frame = ui.GetFrame("squad_manager");

	local memberinfoBox = GET_CHILD_RECURSIVELY(frame, "memberinfo_box")
	local disbandBtn = GET_CHILD_RECURSIVELY(frame, "disband_btn")
	local leaveBtn = GET_CHILD_RECURSIVELY(frame, "leave_btn")
	local createBtn = GET_CHILD_RECURSIVELY(frame, "create_btn")

	local show = 0
	local notshow = 0
	
	if squadExist == true then
		show = 1
		notshow = 0
	else
		show = 0
		notshow = 1
	end

	memberinfoBox:ShowWindow(show)
	disbandBtn:ShowWindow(show)
	leaveBtn:ShowWindow(show)
	createBtn:ShowWindow(notshow)
end

function ON_SQUAD_SYSTEM_TIMETABLE(parent, ctrl, argStr, argNum)
	g_curContentsNum = argNum
	if g_curContentsNum ~= g_contentsNum then
        return
	end

	
	
    local prev = parent:GetUserIValue("PREV")
	season_id = session.rank.GetPrevSeason(g_contentsNum, prev)
	RequestRankSystemRankList(0, g_contentsNum, season_id)

	local myAid = session.loginInfo.GetAID();

	if squad_system.IsValidPlayHistory(g_squadType, myAid, season_id, g_contentsNum) == true then
		RequestRankSystemSquadData(g_contentsNum, season_id, 1, g_squadType)
	end
end

function ON_SQUAD_SYSTEM_DATA(parent, ctrl, argStr, argNum)
	if g_curContentsNum ~= g_contentsNum then
        return
	end

    local max_page = 1
    local now_page = 1
    if argStr ~= "NO_DATA" then
        curPage = argNum
    end

	SQUAD_MANAGER_RANK_UI_INIT(parent, argStr)
end

local function GET_RANK_ICON(rank)
    if rank == 1 then
        return "hero_icon_gradeHigh"
    elseif rank == 2 then
        return "hero_icon_gradeMiddle"
    elseif rank == 3 then
        return "hero_icon_gradeLow"
    else
        return ""
    end
end

function ON_SQUAD_SYSTEM_MY_DATA(parent, ctrl, argStr, argNum)
	if g_curContentsNum ~= g_contentsNum then
        return
	end

	local myAid = session.loginInfo.GetAID();
    local prev = parent:GetUserIValue("PREV")
	local season_id = session.rank.GetPrevSeason(g_contentsNum, prev)

	if squad_system.IsValidPlayHistory(g_squadType, myAid, season_id, g_contentsNum) == false then
		return
	end

	local rank = session.rank.GetMyRank()
	local tribulation = 100 - session.rank.GetMyTime()
	local time = session.rank.GetMyDamage()

	local rankMyInfoBox = GET_CHILD_RECURSIVELY(parent, "rank_my_info_box")
	local rankIcon = GET_CHILD(rankMyInfoBox, "rank_icon") 
	local rankText = GET_CHILD(rankIcon, "rank_text")
	local rankTime = GET_CHILD(rankMyInfoBox, "rank_time_text")
	local rankScore = GET_CHILD(rankMyInfoBox, "rank_score_text")

	if rank == 0 or argStr == "NO_DATA" then
		rankIcon:SetImage("")
		rankText:SetTextByKey("rank", '-')
		rankTime:SetTextByKey("time", "-- : -- : --")
		rankScore:SetTextByKey("score", '-')
		return
	end

	local clear_time_ms = 36000000 - time
	local clear_hour = math.floor(clear_time_ms / (60 * 60 * 1000))
	local clear_min = math.floor(clear_time_ms / (60 * 1000)) - (clear_hour * 60)
	local clear_sec = math.floor(clear_time_ms / 1000) - ((clear_hour * 60 + clear_min) * 60)
	local clear_ms = math.fmod(clear_time_ms, 1000)
	if clear_ms < 0 then
		clear_ms = 0
	end
	local time_txt = "-- : -- : --"
	if clear_hour > 0 then
		time_txt = string.format("%d:%02d:%02d.%03d", clear_hour, clear_min, clear_sec, clear_ms)
	else
		time_txt = string.format("%02d:%02d.%03d", clear_min, clear_sec, clear_ms)
	end

	rankIcon:SetImage(GET_RANK_ICON(rank))
	rankText:SetTextByKey("rank", rank)
	rankTime:SetTextByKey("time", time_txt)
	rankScore:SetTextByKey("score", tribulation)
end

function SQUAD_MANAGER_MY_RANK_UI_INIT(frame)
	frame = frame:GetTopParentFrame()
	local myInfoBox = GET_CHILD_RECURSIVELY(frame, "rank_my_info_box")
	local rankGroupText = GET_CHILD_RECURSIVELY(myInfoBox, "rank_group_text")
	local rankIcon = GET_CHILD_RECURSIVELY(myInfoBox, "rank_icon")
	local rankText = GET_CHILD_RECURSIVELY(myInfoBox, "rank_text")
	local timeText = GET_CHILD_RECURSIVELY(myInfoBox, "rank_time_text")
	local scoreText = GET_CHILD_RECURSIVELY(myInfoBox, "rank_score_text")

	-- 스쿼드가 존재하지 않으면 초기화
	rankIcon:SetImage("")
	rankText:SetTextByKey("rank", "-")
	timeText:SetTextByKey("time", "-- : -- : --")
	scoreText:SetTextByKey("score", "-")


	local squadName = session.SquadSystem.GetSquadName(g_squadType)
	if squadName == "None" then
		squadName =  ScpArgMsg('SquadNumber{index}', 'index', g_squadType + 1)
	end

	rankGroupText:SetTextByKey("name", squadName)
end

function SQUAD_MANAGER_RANK_UI_INIT(frame, argStr)
	local tab = GET_CHILD_RECURSIVELY(frame, "season_tab")
    local tabCnt = tab:GetItemCount()
    for idx = 1, tabCnt do
		local season = session.rank.GetPrevSeason(g_contentsNum, idx-1)
        if season == "None" then
			tab:SetTabVisible(idx - 1, false)
		else
			tab:SetTabVisible(idx - 1, true)
		end
	end
	
	local season_num = session.rank.GetSeasonNum()
	for idx = 0, tabCnt - 1 do
		tab:ChangeCaptionOnly(idx, "{s18}"..season_num - idx, false)
	end

	if argStr == "NO_DATA" then
        return;
	end

	local rankInfoBox = GET_CHILD_RECURSIVELY(frame, "rank_info_box")
	rankInfoBox:SetScrollBarOffset(2, 1)
	rankInfoBox:SetScrollBarBottomMargin(0)
	rankInfoBox:SetScrollBarSkinName("worldmap2_scrollbar")
	
	for idx = 0, 9 do
        local rank = session.rank.GetRank(idx)
        if rank == 0 then
            return
        end

        local tier = session.rank.GetTier(idx)
        local aid = session.rank.GetAID(idx)
        local tribulation = 100 - session.rank.GetTime(idx)
        local time = session.rank.GetDamage(idx)
        local teamName = session.rank.GetTeamName(idx)

        -- 기본값 처리
        if time == 0 then
            time = "--"
        end

        if damage == 0 then
            damage = "--"
        end

        if guildName == "" then
            guildName = "--"
        end

        -- 서체 처리
        local style = ""

        -- if myAID == aid then -- 이건 처리할지 생각좀
        --     style = frame:GetUserConfig("MY_STYLE")
        -- else
        --     style = frame:GetUserConfig("STYLE_NORMAL")
        -- end

		-- 컨트롤셋 세팅
        local controlset = rankInfoBox:CreateOrGetControlSet('squad_rank_info', 'rank_info_'..(curPage * 10) + idx, ui.LEFT, ui.TOP, 2, height * 81, 0 ,0)


		local clear_time_ms = 36000000 - time
        local clear_hour = math.floor(clear_time_ms / (60 * 60 * 1000))
        local clear_min = math.floor(clear_time_ms / (60 * 1000)) - (clear_hour * 60)
        local clear_sec = math.floor(clear_time_ms / 1000) - ((clear_hour * 60 + clear_min) * 60)
        local clear_ms = math.fmod(clear_time_ms, 1000)
        if clear_ms < 0 then
            clear_ms = 0
        end
        local time_txt = "-- : -- : --"
        if clear_hour > 0 then
            time_txt = string.format("%d:%02d:%02d.%03d", clear_hour, clear_min, clear_sec, clear_ms)
        else
            time_txt = string.format("%02d:%02d.%03d", clear_min, clear_sec, clear_ms)
		end
		
        GET_CHILD_RECURSIVELY(controlset, "rank_icon"):SetImage(GET_RANK_ICON(rank))
        GET_CHILD_RECURSIVELY(controlset, "rank_text"):SetTextByKey("rank", rank)
        GET_CHILD_RECURSIVELY(controlset, "rank_group_text"):SetTextByKey("name", teamName)
        GET_CHILD_RECURSIVELY(controlset, "rank_time_text"):SetTextByKey("time", time_txt)
        GET_CHILD_RECURSIVELY(controlset, "rank_score_text"):SetTextByKey("score", tribulation)

		if height % 2 ~= 0 then
			controlset:SetSkinName("None")
		end
		
        -- 높이 조정
        height = height + 1
    end
	
end

function SQUAD_MANAGER_SEASON_SELECT(parent, self)
	height = 0
	local squadFrame = parent:GetTopParentFrame()
	local rankInfoBox = GET_CHILD_RECURSIVELY(squadFrame, "rank_info_box")
	rankInfoBox:RemoveAllChild();
	local index = self:GetSelectItemIndex()
	SQUAD_MANAGER_MY_RANK_UI_INIT(squadFrame)
	SQUAD_MANAGER_REQUEST_RANK(index)
end

function GET_GROUP_TYPE()
	return g_squadType
end

function SQUAD_MANAGER_JOB_PORTRAIT(parent, self, argStr, argNum)
	local memberInfogb = GET_CHILD_RECURSIVELY(parent, "memberinfo_box")

	for i = 0, 4 do
		local memberInfoCtrl = GET_CHILD_RECURSIVELY(memberInfogb, "member_info_"..i)
		if memberInfoCtrl ~= nil then
			local nameText = GET_CHILD(memberInfoCtrl, "name_text")
			local teamName = nameText:GetTextByKey("name")
			if teamName == argStr then
				SQUAD_MANAGER_SET_PORTRAIT(memberInfoCtrl, teamName)
				return
			end
		else
			return
		end
	end
end

function SQUAD_MANAGER_SET_PORTRAIT(ctrl, teamName)
	local memberInfo = session.otherPC.GetByFamilyName(teamName)
	if memberInfo ~= nil then

		local classBuild = {}
		for i = 0, memberInfo:GetJobCount() - 1 do
			local tempjobinfo = memberInfo:GetJobInfoByIndex(i);
			table.insert(classBuild, tempjobinfo.jobID)
		end

		table.sort(classBuild);

		local classCnt = 1
		for j = 2, #classBuild do
			local jobPortrait = GET_CHILD_RECURSIVELY(ctrl, "jobportrait"..classCnt);
			local jobCls  = GetClassByType("Job", classBuild[j]);
			if nil ~= jobCls then
				jobPortrait:SetImage(jobCls.Icon);
				jobPortrait:SetTooltipType('texthelp');
				jobPortrait:SetTooltipArg(jobCls.Name);
				classCnt = classCnt + 1;
			end		
		end
	else
		party.ReqMemberDetailInfoForAct(teamName);
	end
end


function SQUAD_MANAGER_GET_RANK_LIST_BY_SCROLL(parent, ctrl)
    local frame = parent:GetTopParentFrame()
    if frame:IsVisible() == 0 then
        return
    end

    if ctrl:IsScrollEnd() == true and ctrl:IsScrollBarVisible() == true then
        local now = imcTime.GetAppTime()
        local dif = now - scrolledTime

        if 3 < dif then
			local prev = frame:GetUserIValue("PREV")
			season_id = session.rank.GetPrevSeason(g_contentsNum, prev)
			RequestRankSystemRankList(curPage + 1, g_contentsNum, season_id)
            scrolledTime = now
        end
    end
end

function SQUAD_MANAGER_RANKING_SEASON_SET(frame)
	local seasonText = GET_CHILD_RECURSIVELY(frame, "season_text")
	local clsList, cnt = GetClassList("tribulation_season_table")
	for i = 0, cnt - 1 do
		local cls = GetClassByIndexFromList(clsList, i)
		local contentsNum = TryGetProp(cls, "contents_num")
		local nation = TryGetProp(cls, "Nation")
		if config.GetServiceNation() == nation and contentsNum == g_contentsNum then
			local startDate = TryGetProp(cls, "start_date")
			local endDate = TryGetProp(cls, "end_date")
			seasonText:SetTextByKey("start", startDate)
			seasonText:SetTextByKey("end", endDate)
			return
		end
	end
end

function CONTEXT_SQUAD(frame, ctrl, teamName)	
	local isMySquad = session.SquadSystem.IsMySquad(g_squadType)
	local context = ui.CreateContextMenu("CONTEXT_PARTY", "", 0, 0, 170, 100);
	local myHandle = session.GetMyHandle();
	local myTeamName = info.GetFamilyName(myHandle)
	if isMySquad == true and myTeamName ~= teamName then
		-- 추방.
		ui.AddContextMenuItem(context, ScpArgMsg("Ban"), string.format("SQUAD_MANAGER_KICK_MEMBER(\"%s\")", teamName));	
		ui.AddContextMenuItem(context, ScpArgMsg("PARTY_INVITE"), string.format("PARTY_INVITE(\"%s\")", teamName));
		ui.AddContextMenuItem(context, ScpArgMsg("Cancel"), "None");
		ui.OpenContextMenu(context);
	end
end

