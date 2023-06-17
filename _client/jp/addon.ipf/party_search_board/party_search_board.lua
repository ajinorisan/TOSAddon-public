local json = require "json_imc";

local partyBoardCategory = "raid";
local curPage = 1;
local prevPage = 1;
local selected_post = "None";
local isRegistered = false;
local deleted = false;
g_partyName = "";
g_partyCategory = "";
g_abilCondtion = 0;
g_gearCondition = 0;
g_relicCondition = 0;


function PARTY_SEARCH_BOARD_ON_INIT(addon, frame)
	addon:RegisterMsg('PARTY_SEARCH_PARTICIPANT_UPDATE', 'PARTY_SEARCH_BOARD_SHOW_PARTICIPANT');
	addon:RegisterMsg("SUCCESS_ADD_PARTY_INFO", 'PARTY_BOARD_PARTY_UPDATE');
	addon:RegisterMsg("SUCCESS_UPDATE_PARTY_INFO", "PARTY_BOARD_PARTY_UPDATE");
end

function PARTY_SEARCH_BOARD_OPEN(frame)
	local categoryListBox = GET_CHILD_RECURSIVELY(frame, "categoryListBox");
	local raidBtn = GET_CHILD(categoryListBox, "raid_button");
	local searchMenuBtn = GET_CHILD(frame, "searchMenuBtn");
	local categoryList = GET_CHILD_RECURSIVELY(frame, "categoryList");
	local categoryList2 = GET_CHILD_RECURSIVELY(frame, "categoryList2");
	local input_name_text = GET_CHILD_RECURSIVELY(frame, "input_text");
	input_name_text:SetTextByKey("value", ClMsg("InputPartyName"));

	categoryList:AddItem("raid", "{@ps1_1}{s16}"..ClMsg("IndunRaid"));
	categoryList:AddItem("quest", "{@ps1_1}{s16}"..ClMsg("Quest"));
	categoryList:AddItem("etc", "{@ps1_1}{s16}"..ClMsg("Etc"));
	categoryList2:AddItem("raid", "{@ps1_1}{s16}"..ClMsg("IndunRaid"));
	categoryList2:AddItem("quest", "{@ps1_1}{s16}"..ClMsg("Quest"));
	categoryList2:AddItem("etc", "{@ps1_1}{s16}"..ClMsg("Etc"));

	
	PARTY_SEARCH_BOARD_CATEGORY_INIT(categoryListBox);
	partyBoardCategory = "raid";
	raidBtn:SetForceClicked(true);
	curPage = 1;
	PARTY_SEARCH_BOARD_MENU_SEARCH_BTN(frame, searchMenuBtn);
end

function PARTY_SEARCH_BOARD_REFRESH(parent, self)
	curPage = 1;
	local page = tostring(curPage);
	local searchEdit = GET_CHILD_RECURSIVELY(parent, "searchEdit");
	local conditionListBox = GET_CHILD_RECURSIVELY(parent, "conditionListBox");
	local partyNameText = GET_CHILD_RECURSIVELY(parent, "partyNameText");
	local partyCntText = GET_CHILD_RECURSIVELY(parent, "partyCntText");

	conditionListBox:ShowWindow(0);
	partyNameText:ShowWindow(0);
	partyCntText:ShowWindow(0);
;
	if searchEdit:GetText() == "" then
    	GetPartyInfoList('callback_get_party_info', partyBoardCategory, page);
	else
		GetPartyInfoListWithSearchWord('callback_get_party_info', searchEdit:GetText(), partyBoardCategory, page);
	end
end

function PARTY_SEARCH_BOARD_SELECT_CATEGORY(categoryListBox, tab, strArg)
	PARTY_SEARCH_BOARD_CATEGORY_INIT(categoryListBox);
	partyBoardCategory = strArg;
	tab:SetForceClicked(true);
	curPage = 1;
	local frame = ui.GetFrame("party_search_board");
	PARTY_SEARCH_BOARD_SELECT_SEARCH_TAB(frame);
end

function PARTY_SEARCH_BOARD_CATEGORY_INIT(categoryListBox)
	local childCount = categoryListBox:GetChildCount();
    for i = 1, childCount - 1 do
		local child = categoryListBox:GetChildByIndex(i);
		if child ~= nil then
			tolua.cast(child, child:GetClassString());
			child:SetForceClicked(false);
		end
	end
	partyBoardCategory = "None";
end


function PARTY_SEARCH_BOARD_SELECT_SEARCH_TAB(frame)
	local frame = frame:GetTopParentFrame();
	local reqBtn = GET_CHILD_RECURSIVELY(frame, "requestBtn");
	local conditionListBox = GET_CHILD_RECURSIVELY(frame, "conditionListBox");
	local searchEdit = GET_CHILD_RECURSIVELY(frame, "searchEdit");
	local partyNameText = GET_CHILD_RECURSIVELY(frame, "partyNameText");
	local partyCntText = GET_CHILD_RECURSIVELY(frame, "partyCntText");

	local page = tostring(curPage);
	reqBtn:SetEnable(0);
	conditionListBox:ShowWindow(0);
	partyNameText:ShowWindow(0);
	partyCntText:ShowWindow(0);

	searchEdit:SetText("");
    GetPartyInfoList('callback_get_party_info', partyBoardCategory, page);
end


function callback_get_party_info(code, ret_json)    
	local frame = ui.GetFrame("party_search_board");
	local partyListBox = GET_CHILD_RECURSIVELY(frame, "partyListBox");
	local memberListBox = GET_CHILD_RECURSIVELY(frame, "memberListBox");
	local pageText = GET_CHILD_RECURSIVELY(frame, "pageText");
	

	if code ~= 200 then
		curPage = prevPage; -- 페이지 변경에 실패
		SHOW_GUILD_HTTP_ERROR(code, ret_json, "callback_get_party_info");
		return;
	end



	local dic = json.decode(ret_json);
    local total_cnt = dic["total_cnt"];
	local party_list = dic["party_list"];
	if #party_list == 0 and curPage ~= 1 then
		curPage = prevPage;
		ui.SysMsg(ClMsg("ShowBookItemLastPage"));
		return;
	end
	
	partyListBox:RemoveAllChild();
	memberListBox:RemoveAllChild();
	memberListBox:SetUserValue("SELECTED_POST", "None");
	pageText:SetTextByKey("page", curPage);

	for k,v in pairs(party_list) do 
		local type = v["type"];
		local msg = v["msg"];
        local limit = v["limitation"];
		local abilPoint = limit["ability_point"];
		local gearScore = limit["gear_score_limit"];
		local relicLv = limit["relic_level"];
		local memList = v["member_list"];
		local memInfo = StringSplit(memList[1], '/');


		local partyPostCtrl = partyListBox:CreateOrGetControlSet('party_board_post', 'PARTY_BOARD_POST_'..k, 0, (k-1) * 76);
		local nameText = GET_CHILD(partyPostCtrl, "name_text");
		local partyText = GET_CHILD(partyPostCtrl, "party_text");
		local memberNum = GET_CHILD(partyPostCtrl, "member_num");

		nameText:SetTextByKey("name", memInfo[1]);
		partyText:SetTextByKey("name", msg);
		memberNum:SetTextByKey("value", #memList);


		if partyText:IsTextOmitted() == true then
			partyText:SetTextTooltip(msg);
		else
			partyText:EnableHitTest(0);
		end

		partyPostCtrl:SetUserValue("abilPoint", abilPoint);
		partyPostCtrl:SetUserValue("gearScore", gearScore);
		partyPostCtrl:SetUserValue("relicLv", relicLv);
		partyPostCtrl:SetUserValue("memberCnt", #memList);
		for i = 1, #memList do
			partyPostCtrl:SetUserValue("memberInfo"..i, memList[i]);
		end
	end
end


function PARTY_SEARCH_BOARD_SELECT_POST(frame, post)
	local mainFrame = frame:GetParent();
	local prevBtnName = mainFrame:GetUserValue("SELECTED_POST");
	if prevBtnName ~= "None" then
		local prevPost = GET_CHILD_RECURSIVELY(mainFrame, prevBtnName);
		if prevPost ~= nul then
			local prevBtn = GET_CHILD(prevPost, "partyinfo");
			prevBtn:SetForceClicked(false);
		end
	end
	selected_post = GET_CHILD(frame, "name_text"):GetTextByKey("name");
	post:SetForceClicked(true);
	mainFrame:SetUserValue("SELECTED_POST", frame:GetName());
	PARTY_SEARCH_BOARD_DRAW_POST_INFO(frame);
end

function PARTY_SEARCH_BOARD_DRAW_POST_INFO(post)
	local frame = post:GetTopParentFrame();
	local memberListBox = GET_CHILD_RECURSIVELY(frame, "memberListBox");
	local reqBtn = GET_CHILD_RECURSIVELY(frame, "requestBtn");
	local conditionListBox = GET_CHILD_RECURSIVELY(frame, "conditionListBox");
	local abilText = GET_CHILD_RECURSIVELY(frame, "abilText");
	local gearText = GET_CHILD_RECURSIVELY(frame, "gearText");
	local relicText = GET_CHILD_RECURSIVELY(frame, "relicText");
	local partyNameText = GET_CHILD_RECURSIVELY(frame, "partyNameText");
	local partyCntText = GET_CHILD_RECURSIVELY(frame, "partyCntText");

	local memberNum = post:GetUserIValue("memberCnt");

	partyNameText:SetTextByKey("value", GET_CHILD(post, "party_text"):GetTextByKey("name"));
	partyCntText:SetTextByKey("value", memberNum);

	abilText:SetTextByKey("value", post:GetUserIValue("abilPoint"));
	gearText:SetTextByKey("value", post:GetUserIValue("gearScore"));
	relicText:SetTextByKey("value", post:GetUserIValue("relicLv"));
	reqBtn:SetEnable(1);
	conditionListBox:ShowWindow(1);
	partyNameText:ShowWindow(1);
	partyCntText:ShowWindow(1);

	memberListBox:RemoveAllChild();

	for i = 1, memberNum do
		local memberInfo = post:GetUserValue("memberInfo"..i);
		local infoTable = StringSplit(memberInfo,'/');
		local name = infoTable[1];
		local classBuild = { infoTable[3], infoTable[4], infoTable[5] };
		table.sort(classBuild);

		local partyMemberCtrl = memberListBox:CreateOrGetControlSet('party_board_member', 'PARTY_BOARD_MEMBER_'..(i - 1), 0, (i - 1) * 86);
		local leaderImg = GET_CHILD(partyMemberCtrl, "leader_img");
		local nameText = GET_CHILD(partyMemberCtrl, "name_text");

		if i ~= 1 then
			leaderImg:ShowWindow(0);
			nameText:SetOffset(leaderImg:GetX(), 0);
		end

		nameText:SetTextByKey("name", name);

		local classCnt = 1
		for j = 1, #classBuild do
			local jobPortrait = GET_CHILD_RECURSIVELY(partyMemberCtrl, "jobportrait"..classCnt);
			local jobCls  = GetClassByType("Job", classBuild[j]);
			if nil ~= jobCls then
				jobPortrait:SetImage(jobCls.Icon);
				jobPortrait:SetTooltipType('texthelp');
				jobPortrait:SetTooltipArg(jobCls.Name);
				classCnt = classCnt + 1;
			end		
		end
	end
end

function PARTY_SEARCH_BOARD_REQ_PARTICIPATE(parent, self)
	local abilCondition = tonumber(GET_CHILD_RECURSIVELY(parent, "abilText"):GetTextByKey("value"));
	local gearCondition = tonumber(GET_CHILD_RECURSIVELY(parent, "gearText"):GetTextByKey("value"));
	local relicCondition = tonumber(GET_CHILD_RECURSIVELY(parent, "relicText"):GetTextByKey("value"));
	local myAbil = tonumber(GET_MY_ABILITY_POINT());
	local myGear = tonumber(GET_MY_GEAR_SCORE());
	local myRelic = tonumber(GET_MY_RELIC_LEVEL());

	if myAbil < abilCondition or myGear < gearCondition or myRelic < relicCondition then
		ui.SysMsg(ClMsg("PartyBoard_Cant_Participate"));
		return
	end
	

	RequestFindPartyJoin(selected_post);
end

function PARTY_SEARCH_BOARD_SEARCH_BTN(parent, self)
	local frame = parent:GetTopParentFrame();
	local conditionListBox = GET_CHILD_RECURSIVELY(frame, "conditionListBox");
	local partyNameText = GET_CHILD_RECURSIVELY(frame, "partyNameText");
	local partyCntText = GET_CHILD_RECURSIVELY(frame, "partyCntText");
	conditionListBox:ShowWindow(0);
	partyNameText:ShowWindow(0);
	partyCntText:ShowWindow(0);
	curPage = 1;
	local page = tostring(curPage);
	PARTY_SEARCH_BOARD_SEARCH(parent, page);
end

function PARTY_SEARCH_BOARD_SEARCH(frame, page)
	local searchEdit = GET_CHILD_RECURSIVELY(frame, "searchEdit");
	if searchEdit:GetText() == "" then
		GetPartyInfoList('callback_get_party_info', partyBoardCategory, page);
		return;
	end
    GetPartyInfoListWithSearchWord('callback_get_party_info', searchEdit:GetText(), partyBoardCategory, page);
end	

function PARTY_SEARCH_BOARD_SELECT_REGISTER_TAB()
	local frame = ui.GetFrame("ingamealert");
	local ctrlset = GET_CHILD_RECURSIVELY(frame, "elem_PartyParticipant");
	local closeBtn = GET_CHILD(ctrlset, "closeBtn");
	ON_INGAMEALERT_ELEM_CLOSE(ctrlset,closeBtn);
	PARTY_BOARD_PARTY_UPDATE();
end


function callback_get_my_party_info(code, ret_json)
    if code ~= 200 then
		SHOW_GUILD_HTTP_ERROR(code, ret_json, "callback_get_my_party_info");
		return
    end
	local frame = ui.GetFrame("party_search_board");
	local manageGb = GET_CHILD_RECURSIVELY(frame, "manage_gb");
	local registerGb = GET_CHILD_RECURSIVELY(frame, "register_gb");
	local registerBtn = GET_CHILD_RECURSIVELY(frame, "registerBtn");
	local memberListBox2 = GET_CHILD_RECURSIVELY(frame, "memberListBox2");
	local partyCntText2 = GET_CHILD_RECURSIVELY(frame, "partyCntText2");
	local timer_text = GET_CHILD_RECURSIVELY(frame, "timer_text");
	local requestBox = GET_CHILD_RECURSIVELY(frame,"requestListBox");

	memberListBox2:RemoveAllChild();

    if ret_json == "None" then
		-- 등록된 정보 없음
		isRegistered = false;
		requestBox:RemoveAllChild();
		registerBtn:SetTextByKey("text", ClMsg('Register'));
		partyCntText2:ShowWindow(0);
		timer_text:ShowWindow(0);
		registerGb:ShowWindow(1);
		g_partyCategory = "";
		PARTY_SEARCH_BOARD_REGISTER_SET_INFO(registerGb, "", g_abilCondtion, g_gearCondition, g_relicCondition);
        return;
	end

	isRegistered = true;
	registerBtn:SetTextByKey("text", ClMsg('Update').." {img ps_icon_refresh 25 25}");
	local dic = json.decode(ret_json);


	local type = dic["type"];
	local categoryList = GET_CHILD_RECURSIVELY(frame, "categoryList");
	categoryList:SelectItemByKey(type);
	partyBoardCategory = type;
	g_partyCategory = type;

	local title = dic["msg"];
	local limit = dic["limitation"];
	local abilPoint = limit["ability_point"];
	local gearScore = limit["gear_score_limit"];
	local relicLv = limit["relic_level"];
	local memList = dic["member_list"];
	local expireTime = dic["expire_time"];

	local year = tonumber(string.sub(expireTime,1,4));
	local month = tonumber(string.sub(expireTime,6,7));
	local day = tonumber(string.sub(expireTime,9,10));
	local hour = tonumber(string.sub(expireTime,12,13));
	local min = tonumber(string.sub(expireTime,15,16));
	local sec = tonumber(string.sub(expireTime,18,19));
	local ret = string.format("%04d-%02d-%02d %02d:%02d:%02d", year, month, day, hour, min, sec);
	PARTY_SEARCH_BOARD_REMAIN_TIME(frame, ret);;

	registerGb:ShowWindow(0);
	manageGb:ShowWindow(1);
	timer_text:ShowWindow(1);
	partyCntText2:ShowWindow(1);
	partyCntText2:SetTextByKey("value", #memList);

	for i = 1, #memList do
		local memberInfo = memList[i];
		local infoTable = StringSplit(memberInfo,'/');
		local name = infoTable[1];
		local classBuild = { infoTable[3], infoTable[4], infoTable[5] };
		table.sort(classBuild);

		local partyMemberCtrl = memberListBox2:CreateOrGetControlSet('party_board_member', 'PARTY_BOARD_MEMBER_'..(i - 1), 0, (i - 1) * 86);
		local leaderImg = GET_CHILD(partyMemberCtrl, "leader_img");
		local nameText = GET_CHILD(partyMemberCtrl, "name_text");

		if i ~= 1 then
			leaderImg:ShowWindow(0);
			nameText:SetOffset(leaderImg:GetX(), 0);;
		end

		nameText:SetTextByKey("name", name);

		local classCnt = 1;
		for j = 1, #classBuild do
			local jobPortrait = GET_CHILD_RECURSIVELY(partyMemberCtrl, "jobportrait"..classCnt);
			local jobCls  = GetClassByType("Job", classBuild[j]);
			if nil ~= jobCls then
				jobPortrait:SetImage(jobCls.Icon);
				jobPortrait:SetTooltipType('texthelp');
				jobPortrait:SetTooltipArg(jobCls.Name);
				classCnt = classCnt + 1;
			end		
		end
	end

	PARTY_SEARCH_BOARD_REGISTER_SET_INFO(manageGb, title, abilPoint, gearScore, relicLv);
end


function PARTY_SEARCH_BOARD_REGISTER_SET_INFO(frame, title, abil, gearScore, relicLv)
	local titleEdit = GET_CHILD_RECURSIVELY(frame, "title_edit");
	local abilEdit = GET_CHILD_RECURSIVELY(frame, "abil_edit");
	local gearEdit = GET_CHILD_RECURSIVELY(frame, "gear_edit");
	local relicEdit = GET_CHILD_RECURSIVELY(frame, "relic_edit");

	g_partyName = title;;
	g_abilCondtion = abil;;
	g_gearCondition = gearScore;;
	g_relicCondition = relicLv;

	titleEdit:SetText(title);
	abilEdit:SetText(abil);
	gearEdit:SetText(gearScore);
	relicEdit:SetText(relicLv);
end

function PARTY_SEARCH_BOARD_REGISTER_POST(frame, self)
	local pcparty = session.party.GetPartyInfo();
	if pcparty == nil then
		ui.SysMsg(ClMsg("NeedToCreateParty"));
		return;
	end

	if PARTY_SEARCH_BOARD_CHECK_PARTY_FULL() == true then
		-- 파티가 전부 참
		return
	end

	local title = GET_CHILD_RECURSIVELY(frame, "title_edit"):GetText();
	local abil = GET_CHILD_RECURSIVELY(frame, "abil_edit"):GetNumber();
	local gear = GET_CHILD_RECURSIVELY(frame, "gear_edit"):GetNumber();
	local relic = GET_CHILD_RECURSIVELY(frame, "relic_edit"):GetNumber();

	if isRegistered == true then
		if PARTY_SEARCH_BOARD_IS_CHANGED(title, partyBoardCategory, abil, gear, relic) then
			local yesscp = string.format('UpdateFindPartyInfo("%s", "%s", %d, %d, %d)', partyBoardCategory, title, gear, abil, relic);
			ui.MsgBox(ClMsg('ApplyChangedData'), yesscp, 'None');
		else
			ui.SysMsg(ClMsg('ThereIsNoChangedData'));
		end
	else
		AddFindPartyInfo(partyBoardCategory, title, gear, abil, relic);
	end
end


function PARTY_SEARCH_BOARD_SHOW_PARTICIPANT(frame)		
	local frame = frame:GetTopParentFrame();
	PARTY_SEARCH_BOARD_UPDATE_PARTICIPANT(frame);
	PARTY_SEARCH_BOARD_SET_TIMER(frame);
	ON_PARTY_BOARD_PARTICIPANT_NOTICE(frame)
end


function PARTY_SEARCH_BOARD_SET_TIMER(frame)
	local timer = GET_CHILD(frame, "addontimer", "ui::CAddOnTimer");
	timer:SetUpdateScript("PARTY_SEARCH_BOARD_CHECK_PARTICIPANT");
	timer:Start(0.1, 0);
end

function PARTY_SEARCH_BOARD_STOP_TIMER(frame)
	local timer = GET_CHILD(frame, "addontimer", "ui::CAddOnTimer");	
	timer:Stop();
end

function PARTY_SEARCH_BOARD_UPDATE_PARTICIPANT(frame)
	local requestBox = GET_CHILD_RECURSIVELY(frame,"requestListBox");

	local participantList = session.party.GetParticipantList();
	local count = participantList:Count();
	
	requestBox:RemoveAllChild();

    for i = 0, count - 1 do
		local participantInfo = participantList:Element(i);

		local name = participantInfo:GetParticipantName();
		local abil = participantInfo:GetParticipantAbil();
		local gear = participantInfo:GetParticipantGearScore();
		local relic = participantInfo:GetParticipantRelicLv();
		local remainTime = participantInfo:GetParticipantRemainTime();		

		local participantCtrl = requestBox:CreateOrGetControlSet('party_board_participant', 'PARTY_BOARD_PARTICIPANT_'..name, 10, i * 135);
		local nameText = GET_CHILD(participantCtrl, "name_text");
		local gauage = GET_CHILD(participantCtrl, "duration_gauge");
		local infoPic = GET_CHILD(participantCtrl, "infoPic");
		
		infoPic:SetTextTooltip(ScpArgMsg("PartyBoard_Participant_Info", "ABIL", abil, "GEAR", gear, "RELIC", relic));
		nameText:SetTextByKey("name", name);
		gauage:SetPoint(remainTime, 60);
		participantCtrl:SetUserValue("REMAIN_TIME", remainTime);
	end
end


function PARTY_SEARCH_BOARD_CHECK_PARTICIPANT(frame, timer, str, num, totalTime)
	local manage_gb = GET_CHILD(frame, "manage_gb");
	local register_gb = GET_CHILD(frame, "register_gb");
	local requestBox = GET_CHILD(manage_gb,"requestListBox");

	local count = requestBox:GetChildCount();
	if count < 2 then
		timer:Stop();
		return 1;
	end

	if PARTY_SEARCH_BOARD_CHECK_PARTY_FULL() == true then
		local registerBtn = GET_CHILD_RECURSIVELY(frame, "registerBtn");
		registerBtn:SetTextByKey("text", ClMsg('Register'));
		RemoveFindPartyInfo();
		PARTY_SEARCH_BOARD_REGISTER_SET_INFO(register_gb, "", g_abilCondtion, g_gearCondition, g_relicCondition);
		PARTY_SEARCH_BOARD_REGISTER_SET_INFO(manage_gb, "", g_abilCondtion, g_gearCondition, g_relicCondition);
		PARTY_SEARCH_BOARD_STOP_TIMER(frame);
		PARTY_BOARD_PARTY_UPDATE();
		return 1;
	end

	if deleted == true then
		GBOX_AUTO_ALIGN(requestBox, 0, 0, 0, true, false);
		deleted = false;
	end

	local patricipant = requestBox:GetChildByIndex(1);
	local gauage = GET_CHILD(patricipant, "duration_gauge");
	local curPoint = gauage:GetCurPoint();
	if curPoint == 0 then
		requestBox:RemoveChildByIndex(1);
		deleted = true;
		return 1;
	end

	for i = 1, count - 1 do
		local patricipant = requestBox:GetChildByIndex(i);
		local gauage = GET_CHILD(patricipant, "duration_gauge");
		local remainTime = patricipant:GetUserValue("REMAIN_TIME");
		gauage:SetPoint(remainTime - totalTime, 60);
	end

	return 1;
end

function PARTY_SEARCH_BOARD_ACCEPT_OR_REJECT_PARTICIPANT(ctrl, btn, str, isAccept)
	local name = GET_CHILD(ctrl,"name_text"):GetTextByKey("name");
	session.party.RejectParticipant(name);
	ConfirmFindPartyJoin(name, isAccept) ;
	ctrl:GetParent():RemoveChild(ctrl:GetName());
	deleted = true;
	local compare = ui.GetFrame("compare");
	compare:ShowWindow(0);
end


function PARTY_SEARCH_BOARD_CHECK_PARTY_FULL()
	local pcparty = session.party.GetPartyInfo();
	if pcparty == nil then
		return false;
	end

	local list = session.party.GetPartyMemberList(0);
	local count = list:Count();
	if count == 5 then
		return true;
	end
	return false;
end

function PARTY_SEARCH_BOARD_PAGE_PREV_BUTTON(parent, self)
	if curPage == 1 then
		return;
	end
	prevPage = curPage ;
	curPage = curPage - 1;
	local page = tostring(curPage);
	PARTY_SEARCH_BOARD_SEARCH(parent, page);
end

function PARTY_SEARCH_BOARD_PAGE_NEXT_BUTTON(parent, self)
	prevPage = curPage ;
	curPage = curPage + 1;
	local page = tostring(curPage);
	PARTY_SEARCH_BOARD_SEARCH(parent, page);
end

function PARTY_BOARD_PARTY_UPDATE()
	local frame = ui.GetFrame("party_search_board")
	local search_gb = GET_CHILD_RECURSIVELY(frame, "search_gb")
	if search_gb:IsVisible() == 0 then
		GetMyPartyInfo('callback_get_my_party_info');
	end
end

function GET_MY_GEAR_SCORE()
	return GET_PLAYER_GEAR_SCORE(GetMyPCObject());
end

function GET_MY_ABILITY_POINT()
	return GET_PLAYER_ABILITY_SCORE(GetMyPCObject());
end

function GET_MY_RELIC_LEVEL()
	local item = session.GetEquipItemBySpot(ES_RELIC);
	if item == nil then
		return 0
	else
		local item_obj = GetIES(item:GetObject());
		return TryGetProp(item_obj, 'Relic_LV', 1);
	end
end

function SUCCESS_ADD_PARTY_INFO(frame)
	local registerBtn = GET_CHILD_RECURSIVELY(frame, "registerBtn");
	isRegistered = true;
	registerBtn:SetTextByKey("text", ClMsg('Update').." {img ps_icon_refresh 25 25}");
end

function GET_PARTICIPANT_INFO(parent, self)
	local nameText = GET_CHILD(parent, "name_text");
	local name = nameText:GetTextByKey("name");
	party.ReqMemberDetailInfo(name);
end

-- 남은 시간 설정 
function PARTY_SEARCH_BOARD_REMAIN_TIME(frame, endtime)
	local endSystime = imcTime.GetSysTimeByYYMMDDHHMMSS(endtime);
	local remainsec = imcTime.GetDifSec(endSystime, geTime.GetServerSystemTime());
	if remainsec < 0 then
		return 0;
	end
	local timer_gb = GET_CHILD_RECURSIVELY(frame, "timer_gb");
	timer_gb:SetUserValue("END_TIME", endtime);
	timer_gb:RunUpdateScript("PARTY_SEARCH_BOARD_REMAIN_TIME_UPDATE", 0.1);;
    PARTY_SEARCH_BOARD_REMAIN_TIME_UPDATE(timer_gb);
end

function PARTY_SEARCH_BOARD_REMAIN_TIME_UPDATE(ctrl)
	local timerText = GET_CHILD(ctrl, "timer_text");
	local endtime = ctrl:GetUserValue("END_TIME");
	local endSystime = imcTime.GetSysTimeByYYMMDDHHMMSS(endtime);
    local remainsec = imcTime.GetDifSec(endSystime, geTime.GetServerSystemTime());
	if remainsec < 0 then
		PARTY_BOARD_PARTY_UPDATE();
		return 0;
    end
    
	local min = string.format("%02d", math.floor(remainsec/60));
	local sec = string.format("%02d", math.floor(remainsec%60));

	local msg = ScpArgMsg("RemainTimeToDelete{min}{sec}", "min", min, "sec", sec);

	timerText:SetTextByKey('value', msg);

	return 1;
end



function PARTY_SEARCH_BOARD_MENU_SEARCH_BTN(parent, self)
	self:SetForceClicked(true);

	local searchGb = GET_CHILD_RECURSIVELY(parent, "search_gb");
	local manageGb = GET_CHILD_RECURSIVELY(parent, "manage_gb");
	local registerGb = GET_CHILD_RECURSIVELY(parent, "register_gb");
	local registerMenuBtn = GET_CHILD_RECURSIVELY(parent, "registerMenuBtn");
	local categoryListBox = GET_CHILD_RECURSIVELY(parent, "categoryListBox");
	local raidBtn = GET_CHILD(categoryListBox, "raid_button");

	registerMenuBtn:SetForceClicked(false);

	categoryListBox:ShowWindow(1);
	searchGb:ShowWindow(1);
	manageGb:ShowWindow(0);
	registerGb:ShowWindow(0);

	PARTY_SEARCH_BOARD_SELECT_CATEGORY(categoryListBox, raidBtn, "raid");
end

function PARTY_SEARCH_BOARD_MENU_REGISTER_BTN(parent, self)
	self:SetForceClicked(true);

	local searchGb = GET_CHILD_RECURSIVELY(parent, "search_gb");
	local manageGb = GET_CHILD_RECURSIVELY(parent, "manage_gb");
	local searchMenuBtn = GET_CHILD_RECURSIVELY(parent, "searchMenuBtn");
	local categoryListBox = GET_CHILD_RECURSIVELY(parent, "categoryListBox");

	searchMenuBtn:SetForceClicked(false);
	
	categoryListBox:ShowWindow(0);
	searchGb:ShowWindow(0);
	manageGb:ShowWindow(0);

	PARTY_SEARCH_BOARD_SELECT_REGISTER_TAB();
end

function PARTY_SEARCH_BOARD_SELECT_CATEGORY_DROP(parent, self)
	local page = self:GetSelItemKey();
	partyBoardCategory = page;
end

function PARTY_SEARCH_BOARD_INPUT_NAME_KEY(frame, edit)
	if frame == nil then return; end
	if edit == nil then return; end

	local input_name_text = GET_CHILD_RECURSIVELY(frame, "input_text");
	local input_text = edit:GetText();
	if input_text ~= "" then
		if input_name_text ~= nil then
			input_name_text:SetTextByKey("value", "");
		end
	else
		if input_name_text ~= nil then
			input_name_text:SetTextByKey("value", ClMsg("InputPartyName"));
		end
	end
end

function PARTY_SEARCH_BOARD_IS_CHANGED(title, category, abil, gear, relic)
	if title ~= g_partyName or 
		abil ~= g_abilCondtion or 
		gear ~= g_gearCondition or 
		relic ~= g_relicCondition or 
		category ~= g_partyCategory then
		return true;
	end

	return false;
end
