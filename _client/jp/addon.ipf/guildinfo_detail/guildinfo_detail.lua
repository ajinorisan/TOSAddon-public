--guildinfo_detail.lua
local json = require "json_imc"
local g_guildName = nil;
local g_guildIdx = nil;
local rowIndex = 1;
local curPage = 1;
local scrolledTime = 0;
local finishedLoading = false;

function GUILDINFO_DETAIL_ON_INIT(addon, frame)
    addon:RegisterMsg('RECEIVE_OTHER_GUILD_AGIT_INFO', 'SCR_OTHER_GUILD_AGIT_INFO');
    addon:RegisterMsg('SERVER_GUILD_OUT_DATE_CHECK', 'SERVER_GUILD_OUT_DATE_CHECK');
end

function GUILDINFO_DETAIL_INIT(guildData, emblemPath, info, guild_idx)
    local frame = ui.GetFrame("guildinfo_detail");
    local promoBox = GET_CHILD_RECURSIVELY(frame, "promoBox");
    promoBox:SetScrollPos(0)
    local memberList = GET_CHILD_RECURSIVELY(frame, "memberList");
    memberList:RemoveAllChild();
    local tabCtrl = GET_CHILD_RECURSIVELY(frame, "itembox");
    tabCtrl:SelectTab(0)
    if guild_idx ~= nil and guildData ~= nil then
        g_guildIdx = guild_idx;

		housing.RequestGuildAgitInfoByGuildID(g_guildIdx, "RECEIVE_OTHER_GUILD_AGIT_INFO");

        local name = guildData['name']
        local level = guildData['level']
        local introText = guildData['shortDesc']
        local avgLevel = info['avgLv']
        local createdDate = info['createdTime']
        local leaderName = info['leaderName']
        local memberCount = info['memberCount']

        local guildName = GET_CHILD_RECURSIVELY(frame, "name");
        guildName:SetText("{s18}" .. name);
        g_guildName = name;
        local guildlevel = GET_CHILD_RECURSIVELY(frame, "level")
        guildlevel:SetText("{s18}" .. level);

        local guildEmblem = GET_CHILD_RECURSIVELY(frame, "emblem")
        guildEmblem:SetImage("")


        if emblemPath == "None" then
            guildEmblem:SetImage('guildmark_slot')
        else
            guildEmblem:SetFileName(emblemPath);
        end

        local checkbox = GET_CHILD_RECURSIVELY(frame, "showMemberWithAccept")
        tolua.cast(checkbox, "ui::CCheckBox")
        checkbox:SetCheck(0)
        local guildDesc = GET_CHILD_RECURSIVELY(frame, "guildText")
        guildDesc:SetText(introText);
        
        local memberNum = GET_CHILD_RECURSIVELY(frame, "memberNumText")
        memberNum:SetText(memberCount);

        local avgTeamLv = GET_CHILD_RECURSIVELY(frame, "avgTeamLvlText")
        avgTeamLv:SetText(avgLevel);

        local date = GET_CHILD_RECURSIVELY(frame, "date")
        date:SetText(createdDate);

        local leader = GET_CHILD_RECURSIVELY(frame, "leader")
        leader:SetText(leaderName)

        local scrollPanel = GET_CHILD_RECURSIVELY(frame, "memberList")
        scrollPanel:SetEventScript(ui.SCROLL, "GUILDINFO_DETAIL_MEMBER_LIST_SCROLL");
        scrollPanel:SetEventScriptArgString(ui.SCROLL, guild_idx);
        rowIndex = 1;
        curPage = 1;
        scrolledTime = 0;
        finishedLoading = false;
        
        GetGuildMemberInfoList("GET_GUILDINFO_MEMBER_LIST", guild_idx, curPage);
        GetIntroductionImage("GET_INTRO_IMAGE", guild_idx);
		
		local agitLevelText = GET_CHILD_RECURSIVELY(frame, "agitLevelText");
		agitLevelText:SetTextByKey("level", "1");

		local btn_preview_housing = GET_CHILD_RECURSIVELY(frame, "btn_preview_housing");
		btn_preview_housing:SetEnable(0);

        frame:ShowWindow(1)
    end
end

function GET_INTRO_IMAGE(code, ret_json)
    if ret_json ~= "" and ret_json ~= g_guildIdx then
        return -- 이전 길드 페이지 요청하자마자 페이지 닫고
    end        -- 다른 길드를 보는중에 응답이 와서 배경에 깔리는 일이 있음.
    local frame = ui.GetFrame("guildinfo_detail");
    local tabCtrl = GET_CHILD_RECURSIVELY(frame, "itembox");
    local promoPic = GET_CHILD_RECURSIVELY(frame, "promoPicture");
    promoPic:SetImage("")
    if code ~= 200 then
        if code == 400 then
            tabCtrl:SetTabVisible(1, false);
            tabCtrl:SelectTab(0)
        else
            SHOW_GUILD_HTTP_ERROR(code, ret_json, "GET_INTRO_IMAGE")
        end
        return
    end 
    tabCtrl:SetTabVisible(1, true);
    tabCtrl:SelectTab(1);
    GUILDINFO_DETAIL_TAB_CLICK();

    local introPath = filefind.GetBinPath("GuildIntroImage"):c_str()
    introPath = introPath .. "\\" .. ret_json .. ".png"
    promoPic:SetFileName(introPath)
    promoPic:Resize(promoPic:GetImageWidth(), promoPic:GetImageHeight())

end

function GUILDINFO_DETAIL_OPEN(addon, frame)
    local parentFrame = ui.GetFrame("guild_rank_info")
    if parentFrame:IsVisible() == 0 then
        return;
    end
    local detail = ui.GetFrame("guildinfo_detail");
  
    local tabCtrl = GET_CHILD_RECURSIVELY(detail, "itembox")
    tabCtrl:SelectTab(0);
    GUILDINFO_DETAIL_TAB_CLICK();

    local intro = GET_CHILD_RECURSIVELY(detail, "intro");
    intro:ShowWindow(1)
end

function OPEN_REQUEST_GUILDJOIN_CHECK()
    local guildidx = GET_GUILD_MEMBER_JOIN_AUTO_GUILD_IDX();    

    if guildidx ~= "0" then
        if guildidx ~= g_guildIdx then
            OPEN_REQUEST_GUILDJOIN();
        else
            local aObj = GetMyAccountObj();
            local lastGuildOutDay = TryGetProp(aObj, "LastServerGuildOutDay", "None");
            if lastGuildOutDay ~= "None" then
                local addTime = 10080; -- 7일
                local lastTime = imcTime.GetSysTimeByStr(lastGuildOutDay);
                local enterEnableTime = imcTime.AddSec(lastTime, (addTime * 60));
                local nowTime = geTime.GetServerSystemTime()
                local difSec = imcTime.GetDifSec(enterEnableTime, nowTime);
                if difSec > 0 then
                    local remainDay = math.floor((((difSec / 60) / 60) / 24));
                    local remainHour = math.floor(((difSec / 60) / 60) % 24);
                    local remainMin = math.floor((difSec / 60) % 60);
                    local remainSec = math.floor(difSec % 60);                
                    addon.BroadMsg('NOTICE_Dm_scroll', ScpArgMsg("CantJoinServerGuild{days}{day}{hour}{min}{sec}", "days", math.floor(((addTime / 60) / 24)), "day", remainDay, "hour", remainHour, "min", remainMin, "sec", remainSec), 5);                
                    return;
                end
            end
            packet.ReqSelfInviteNewbieGuild()
        end        
    else
        OPEN_REQUEST_GUILDJOIN();
    end
end

function SERVER_GUILD_OUT_DATE_CHECK()
    OPEN_REQUEST_GUILDJOIN();
end

function OPEN_REQUEST_GUILDJOIN()
    local appliedGuildList = GET_GUILD_APPLICATION_LIST_JSONDATA();
    local resume = appliedGuildList[g_guildIdx];
    if resume ~= nil and resume == 1 then
        ui.MsgBox(ClMsg("GuildDeclined"))
        return;
    end

    local joinFrame = ui.GetFrame("guild_join");
    joinFrame:ShowWindow(1);
    local txtCtrl = GET_CHILD_RECURSIVELY(joinFrame, "input");
    txtCtrl:SetText("")
    local btn = GET_CHILD_RECURSIVELY(joinFrame, "sendBtn");
    local guildLabel =  GET_CHILD_RECURSIVELY(joinFrame, "guildText");
    guildLabel:SetText(g_guildName);
    btn:SetEventScript(ui.LBUTTONUP, "SEND_JOIN_REQ")
end

function SEND_JOIN_REQ(frame, control)
    local joinFrame = ui.GetFrame("guild_join");
    local txtCtrl = GET_CHILD_RECURSIVELY(joinFrame, "input");

	local account = session.barrack.GetCurrentAccount();
    local teamLvl = account:GetTeamLevel();
    local charList = GetCharacterNameList();
    local charCount = #charList;
    local mylevel = info.GetLevel(session.GetMyHandle());
    local badword = IsBadString(txtCtrl:GetText());
    if badword ~= nil then
		ui.MsgBox(ScpArgMsg('{Word}_FobiddenWord','Word',badword, "None", "None"));
		return;
    end
    
    PutGuildApplicationRequest('ON_GUILDJOIN_REQUEST_SUCCESS', g_guildIdx,tostring(teamLvl), tostring(charCount), tostring(GetAdventureBookMyRank()), tostring(mylevel), txtCtrl:GetText())
    joinFrame:ShowWindow(0)
end

function ON_GUILDJOIN_REQUEST_SUCCESS(code, ret_json)
    if code ~= 200 then
        SHOW_GUILD_HTTP_ERROR(code, ret_json, "ON_GUILDJOIN_REQUEST_SUCCESS")
        return
    end
    SendNoticeGuildApplication(tostring(g_guildIdx))
    ui.MsgBox(ClMsg("GuildJoined"))
end

function GUILDINFO_DETAIL_CLOSE(frame)
    local frame = ui.GetFrame("guildinfo_detail");
    local promoPic = GET_CHILD_RECURSIVELY(frame, "promoPicture");
    promoPic:SetImage("")
    
    local tabCtrl = GET_CHILD_RECURSIVELY(frame, "itembox")
    tabCtrl:SelectTab(0);
    
    local guildEmblem = GET_CHILD_RECURSIVELY(frame, "emblem")
    guildEmblem:SetImage("")

    ui.CloseFrame("guild_join")
end

function SHOW_GUILD_MEMBER_WITH_ACCEPT_AUTH(parent, control)
    if g_guildIdx == nil then
        return
    end
    local frame = ui.GetFrame("guildinfo_detail");
    local scrollPanel = GET_CHILD_RECURSIVELY(frame, "memberList")
    local rowIndex = scrollPanel:GetChildCount();
    tolua.cast(control, "ui::CCheckBox")
    if control:IsChecked() == 1 then
        GetOnlineInvitationClaimMembers("ON_ONLINE_GUILDMEMBER_GET", g_guildIdx);
    else
        for i=1, rowIndex do
            local row = scrollPanel:GetControlSet("guild_member_row", tostring(i));
            if row ~= nil then
                SET_ENABLE_GUILDINFO_DETAIL_ROW(row, 1, 0)
                SET_ENABLE_GUILDINFO_DETAIL_ROW(row, 2, 0)
            end
        end
    end
end

function ON_ONLINE_GUILDMEMBER_GET(code, ret_json)
    if code ~= 200 then
        SHOW_GUILD_HTTP_ERROR(code, ret_json, "ON_ONLINE_GUILDMEMBER_GET")
        return
    end
    
    local frame = ui.GetFrame("guildinfo_detail");
    local parsedJson = json.decode(ret_json)
    local jsonIndex=1
    local i=1
    local guildMemberAuthTable ={}
    for i=1, #parsedJson do
        guildMemberAuthTable[tostring(parsedJson[i]["aid"])] = true
    end


    local scrollPanel = GET_CHILD_RECURSIVELY(frame, "memberList")
    local rowIndex = scrollPanel:GetChildCount();
    for i=1, rowIndex do
        local row = scrollPanel:GetControlSet("guild_member_row", tostring(i));
        if row ~= nil then
            local teamName1 = GET_CHILD_RECURSIVELY(row, "teamName1")
            if guildMemberAuthTable[tostring(teamName1:GetUserValue("aid"))] == true then
                SET_ENABLE_GUILDINFO_DETAIL_ROW(row, 1, 1)

            else
                SET_ENABLE_GUILDINFO_DETAIL_ROW(row, 1, 0)
            end

            local teamName2 = GET_CHILD_RECURSIVELY(row, "teamName2")
            if guildMemberAuthTable[tostring(teamName2:GetUserValue("aid"))] == true then
                SET_ENABLE_GUILDINFO_DETAIL_ROW(row, 2, 1)
            else
                SET_ENABLE_GUILDINFO_DETAIL_ROW(row, 2, 0)
            end
        end
    end
    
    local checkBox = GET_CHILD_RECURSIVELY(frame, "showMemberWithAccept")
    checkBox = AUTO_CAST(checkBox)

    if checkBox:IsChecked() == 1 and #parsedJson == 0 then
        ui.MsgBox(ClMsg("NoOneIsOnline"))
        checkBox:SetCheck(0)
end

end

function SET_ENABLE_GUILDINFO_DETAIL_ROW(row, index, enable)
    --local labelText =

    local teamName = GET_CHILD_RECURSIVELY(row, "teamName" .. index);
   -- teamName:SetEnable(enable)

    local team_lv = GET_CHILD_RECURSIVELY(row, "team_lv" .. index)
    --team_lv:SetEnable(enable)
        
    local lv = GET_CHILD_RECURSIVELY(row, "lv" .. index)
    --lv:SetEnable(enable)
    if teamName:GetUserValue("name") == "None" then
        return
    end
    local teamNameLabel = teamName:GetUserValue("name");
    local team_lvLabel = team_lv:GetUserValue("team_lv");
    local lvLabel = lv:GetUserValue("lv")
    if enable == 1 then
        team_lv:SetText("{@st66d_y}" .. team_lv:GetUserValue("team_lv"));

        teamNameLabel = "{@st66d_y}" .. teamNameLabel;
        team_lvLabel = "{@st66d_y}" .. team_lvLabel;
        lvLabel =  "{@st66d_y}" .. lvLabel;

    end
    teamName:SetText(teamNameLabel)
    team_lv:SetText(team_lvLabel)
    lv:SetText(lvLabel)
end

function BTN_PREVIEW_HOUSING(gbox, btn)
	local mapClassName = session.GetMapName();
	if mapClassName == "c_Klaipe" or mapClassName == "c_orsha" or mapClassName == "c_fedimian" then
		housing.PreviewGuild(g_guildIdx)
		
		local guildinfo_detail = ui.GetFrame("guildinfo_detail");
		if guildinfo_detail ~= nil then
			guildinfo_detail:SetUserValue("IsOpened", "YES");
			local promoBox = GET_CHILD_RECURSIVELY(guildinfo_detail, "promoBox");
			if promoBox:IsScrollBarVisible() == true then
				promoBox:SetUserValue("IsScrollBarVisible", 1);
			else
				promoBox:SetUserValue("IsScrollBarVisible", 0);
			end
			guildinfo_detail:ShowWindow(0);
		end
		
		local guild_rank_info = ui.GetFrame("guild_rank_info");
		if guild_rank_info ~= nil then
			guild_rank_info:SetUserValue("IsOpened", "YES");
			guild_rank_info:ShowWindow(0);
		end
	else
		ui.SysMsg(ClMsg('AllowedInTown1'));
	end
end

function SCR_OTHER_GUILD_AGIT_INFO(frame, msg, argStr, argNum)
	if argStr ~= g_guildIdx then
		return;
	end

	local guildAgit = housing.GetGuildAgitInfoByGuildID(g_guildIdx);
	if guildAgit == nil then
		return;
	end

	if guildAgit.extensionLevel <= 1 then
		return;
	end

	local agitLevelText = GET_CHILD_RECURSIVELY(frame, "agitLevelText");
	agitLevelText:SetTextByKey("level", tostring(guildAgit.extensionLevel));

	local btn_preview_housing = GET_CHILD_RECURSIVELY(frame, "btn_preview_housing");
	btn_preview_housing:SetEnable(1);
end

function GUILDINFO_DETAIL_TAB_CLICK()
    local frame = ui.GetFrame("guildinfo_detail");
	local accObj = GetMyAccountObj();

    local tabCtrl = GET_CHILD_RECURSIVELY(frame, "itembox");    
    local joinballoongb = GET_CHILD_RECURSIVELY(frame, "joinballoongb");
    local joinText = GET_CHILD_RECURSIVELY(frame, "joinText");
    local btn = GET_CHILD_RECURSIVELY(frame, "joinBtn");

    local index = tabCtrl:GetSelectItemIndex();
	local pcparty = session.party.GetPartyInfo(PARTY_GUILD);
    if index == 0 and pcparty == nil then
        joinballoongb:ShowWindow(1);
        joinText:ShowWindow(1);
        
        btn:SetEnable(1);
    else
        joinballoongb:ShowWindow(0);
        joinText:ShowWindow(0);
        
        btn:SetEnable(0);
    end

    local guildidx = GET_GUILD_MEMBER_JOIN_AUTO_GUILD_IDX();
    if guildidx ~= "0" and guildidx == g_guildIdx then
        local limit = TryGetProp(accObj, "GUILD_MEMBER_JOIN_AUTO_LIMIT", 0);
        if limit ~= 0 then
            joinballoongb:ShowWindow(0);
            joinText:ShowWindow(0);
            
            btn:SetEnable(0);
        end
    end
end

function GUILDINFO_DETAIL_MEMBER_LIST_SCROLL(parent, ctrl, guild_idx, argNum)
    local frame = ui.GetFrame("guildinfo_detail");

    if ctrl:IsScrollEnd() == true and finishedLoading == true then
        local now = imcTime.GetAppTime();
        local dif = now - scrolledTime;

        if 1 < dif then
            curPage = curPage + 1;
            GetGuildMemberInfoList("GET_GUILDINFO_MEMBER_LIST", guild_idx, curPage);

            scrolledTime = now;
            finishedLoading = false;
        end
    end
end

function GET_GUILDINFO_MEMBER_LIST(code, ret_json)
    finishedLoading = true;
    if code ~= 200 then
        return;
    end 

    local parsed = json.decode(ret_json);
    local list = parsed['memberList'];
    local memberCount = #list;
    local memberIndex = 1;
    
    local frame = ui.GetFrame("guildinfo_detail");
    local scrollPanel = GET_CHILD_RECURSIVELY(frame, "memberList")
    for i = 1, math.floor((memberCount/2)+0.5) do
        local row = scrollPanel:CreateOrGetControlSet("guild_member_row", tostring(rowIndex), 0, 0);
        row:Resize(scrollPanel:GetWidth(), 50);

        local teamName1 = GET_CHILD_RECURSIVELY(row, "teamName1");
        teamName1:SetText(list[memberIndex]['teamname']);
        teamName1:SetUserValue("aid", list[memberIndex]['aid'])
        teamName1:SetUserValue("name",list[memberIndex]['teamname'])

        local level1 = GET_CHILD_RECURSIVELY(row, "team_lv1");
        level1:SetText(list[memberIndex]['team_lv']);
        level1:SetUserValue("team_lv", list[memberIndex]['team_lv']);

        local lv1 = GET_CHILD_RECURSIVELY(row, "lv1");
        lv1:SetText(list[memberIndex]['lv']);
        lv1:SetUserValue("lv", list[memberIndex]['lv'])
        memberIndex = memberIndex + 1;

        if memberIndex <= memberCount then
            local teamName2 = GET_CHILD_RECURSIVELY(row, "teamName2");
            teamName2:SetText(list[memberIndex]['teamname']);
            teamName2:SetUserValue("aid", list[memberIndex]['aid'])
            teamName2:SetUserValue("name", list[memberIndex]['teamname'])
            
            local level2 = GET_CHILD_RECURSIVELY(row, "team_lv2");
            level2:SetText(list[memberIndex]['team_lv']);
            level2:SetUserValue("team_lv", list[memberIndex]['team_lv']);
            
            local lv2 = GET_CHILD_RECURSIVELY(row, "lv2");
            lv2:SetText(list[memberIndex]['lv']);
            lv2:SetUserValue("lv", list[memberIndex]['lv'])
            memberIndex = memberIndex + 1;
        end

        rowIndex = rowIndex + 1;
        row:Invalidate();
    end
end