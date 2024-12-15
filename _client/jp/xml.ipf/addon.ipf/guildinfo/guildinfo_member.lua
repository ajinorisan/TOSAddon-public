-- 한글
local curPage = 1;
local onlinecurPage = 1;
local scrolledTime = 0;
function GUILDINFO_INIT_MEMBER_TAB(frame, msg)    
    _GUILDINFO_INIT_MEMBER_TAB(frame, msg);
end

function _GUILDINFO_INIT_MEMBER_TAB(frame, msg)
    local maintab = GET_CHILD_RECURSIVELY(frame, "maintab");
    if frame:IsVisible() ~= 1 or maintab:GetSelectItemIndex() ~= 0 then
        return;
    end

    local guild = GET_MY_GUILD_INFO();
    if guild == nil then
        return;
    end
    
    local pc = GetMyPCObject();
    if IsPVPField(pc) == 1 or IsPVPServer(pc) == 1 then
        return;
    end

    GUILDINFO_MEMBER_INIT_ONLINE_CHECKBOX(frame);

    local leaderAID = guild.info:GetLeaderAID();
    GUILDINFO_MEMBER_LIST_UPDATE(frame, guild, leaderAID);
end

function GUILDINFO_MEMBER_ONLINE_CLICK(parent, checkBox)
    local pc = GetMyPCObject();
    if IsPVPField(pc) == 1 or IsPVPServer(pc) == 1 then
        return;
    end

    local topFrame = parent:GetTopParentFrame();
    local memberCtrlBox = GET_CHILD_RECURSIVELY(topFrame, 'memberCtrlBox');
    if checkBox == nil then
        checkBox = GET_CHILD_RECURSIVELY(topFrame, 'memberFilterCheck');
    end

    local showOnlyOnline = checkBox:IsChecked();
    config.ChangeXMLConfig('OnlyOnlineGuildMember', showOnlyOnline);    

    _GUILDINFO_MEMBER_LIST_UPDATE(topFrame);
    ui.CloseFrame('guild_authority_popup');
end

function POPUP_GUILD_MEMBER(parent, ctrl)
	local aid = parent:GetUserValue("AID");
	if aid == "None" then
		aid = ctrl:GetUserValue("AID");
	end
	
	local memberInfo = session.party.GetPartyMemberInfoByAID(PARTY_GUILD, aid);
	local isLeader = AM_I_LEADER(PARTY_GUILD);
	local myAid = session.loginInfo.GetAID();

	local name = memberInfo:GetName();

	local contextMenuCtrlName = string.format("{@st41}%s{/}", name);
    local context = ui.CreateContextMenu("PC_CONTEXT_MENU", name, 0, 0, 170, 100);
    
    if isLeader == 1 or HAS_KICK_CLAIM() then
        ui.AddContextMenuItem(context, ScpArgMsg("Ban"), string.format("GUILD_BAN('%s')", aid));        
    end

	if isLeader == 1 and aid ~= myAid then
		local mapName = session.GetMapName();
		if mapName == 'guild_agit_1' or mapName == 'guild_agit_extension' then
			ui.AddContextMenuItem(context, ScpArgMsg("GiveGuildLeaderPermission"), string.format("SEND_REQ_GUILD_MASTER('%s')", name));
		end
	end

	if isLeader == 1 then
        local count = session.party.GetAllMemberCount(PARTY_GUILD);
		if count == 1 then
			ui.AddContextMenuItem(context, ScpArgMsg("Disband"), "DESTROY_GUILD()");            
		end
	else
		if aid == myAid then
			ui.AddContextMenuItem(context, ScpArgMsg("GULID_OUT"), "OUT_GUILD_CHECK()");
		end
    end
    
    if isLeader == 1 and aid ~= myAid then
        local summonSkl = GetClass('Skill', 'Templer_SummonGuildMember');
        ui.AddContextMenuItem(context, summonSkl.Name, string.format("SUMMON_GUILD_MEMBER('%s')", aid));
    end

    if isLeader == 1 and aid ~= myAid then
        local goSkl = GetClass('Skill', 'Templer_WarpToGuildMember');
        ui.AddContextMenuItem(context, goSkl.Name, string.format("WARP_GUILD_MEMBER('%s')", aid));
    end

	ui.AddContextMenuItem(context, ScpArgMsg("WHISPER"), string.format("ui.WhisperTo('%s')", name));
	ui.AddContextMenuItem(context, ScpArgMsg("Cancel"), "None");
	ui.OpenContextMenu(context);

end

function GUILDINFO_MEMBER_INVITE(parent, ctrl)
	local frame = parent:GetTopParentFrame();
	INPUT_STRING_BOX_CB(frame, ScpArgMsg("InputTeamNameForGuildInvite"), "GUILDINFO_INVITE_GUILD", "", nil, nil, 20);
end

function GUILDINFO_INVITE_GUILD(frame, teamName)
    if teamName == nil or teamName == '' then
        return;
    end
    ui.Chat('/guild '..teamName);
end

function GUILDINFO_MEMBER_SORT_NAME(parent, ctrl)    
    local topFrame = parent:GetTopParentFrame();
    local sortFuncNameTail = GUILDINFO_MEMBER_SET_SORT_IMG(topFrame, ctrl);

    -- sort
    local sortFunc = _G['SORT_GUILDINFO_MEMBER_NAME'..sortFuncNameTail];
    local memberCtrlBox = GET_CHILD_RECURSIVELY(topFrame, 'memberCtrlBox');
    local childNameTable = GET_MEMBER_CTRLSET_NAME_TABLE(memberCtrlBox);
    table.sort(childNameTable, sortFunc);

    -- realign 
    GUILDINFO_MEMBER_REALIGN(topFrame, memberCtrlBox, childNameTable);
end

function GUILDINFO_MEMBER_REALIGN(topFrame, memberCtrlBox, childNameTable)
    local isShowOnlyOnline = IS_SHOW_ONLY_ONLINE_GUILD_MEMBER(topFrame);    
    local yPos = 0;
    for i = 1, #childNameTable do
        local child = memberCtrlBox:GetChild(childNameTable[i]);
        if isShowOnlyOnline == 0 or child:IsVisible() == 1 then
            child:SetOffset(child:GetX(), yPos);
            yPos = yPos + child:GetHeight();
        end
    end    
    ui.CloseFrame('guild_authority_popup');
end

function GUILDINFO_MEMBER_SET_SORT_IMG(topFrame, selectedSortCtrl)
    local MEMBER_SORT_IMG_ON = topFrame:GetUserConfig('MEMBER_SORT_IMG_ON');
    local MEMBER_SORT_IMG_OFF = topFrame:GetUserConfig('MEMBER_SORT_IMG_OFF');
    local prevSort = topFrame:GetUserValue('MEMBER_SORT_CRITERIA');    
    if prevSort ~= 'None' then
        local prevChild = GET_CHILD_RECURSIVELY(topFrame, prevSort);
        prevChild:SetTextByKey('arrow', MEMBER_SORT_IMG_OFF);
    end

    if prevSort == selectedSortCtrl:GetName() then
        topFrame:SetUserValue('MEMBER_SORT_CRITERIA', 'None');
        return '_REVERSE';
    end
    topFrame:SetUserValue('MEMBER_SORT_CRITERIA', selectedSortCtrl:GetName());    
    selectedSortCtrl:SetTextByKey('arrow', MEMBER_SORT_IMG_ON);
    return '';
end

function IS_SHOW_ONLY_ONLINE_GUILD_MEMBER(frame)
    local memberFilterCheck = GET_CHILD_RECURSIVELY(frame, 'memberFilterCheck');
    return memberFilterCheck:IsChecked();
end

function GET_MEMBER_CTRLSET_NAME_TABLE(memberCtrlBox)
    local table = {};
    local childCount = memberCtrlBox:GetChildCount();
    for i = 0, childCount - 1 do
        local child = memberCtrlBox:GetChildByIndex(i);
        local name = child:GetName();
        if string.find(name, 'MEMBER_') ~= nil then
            table[#table + 1] = child:GetName();
        end
    end
    return table;
end

function SORT_GUILDINFO_MEMBER_NAME(a, b)
    local guildinfo = ui.GetFrame('guildinfo');
    local aChild = GET_CHILD_RECURSIVELY(guildinfo, a);
    local bChild = GET_CHILD_RECURSIVELY(guildinfo, b);
    local aNameCtrl = aChild:GetChild('txt_teamname');
    local bNameCtrl = bChild:GetChild('txt_teamname');
    
    return aNameCtrl:GetTextByKey('value') < bNameCtrl:GetTextByKey('value');
end

function SORT_GUILDINFO_MEMBER_NAME_REVERSE(a, b)
    local guildinfo = ui.GetFrame('guildinfo');
    local aChild = GET_CHILD_RECURSIVELY(guildinfo, a);
    local bChild = GET_CHILD_RECURSIVELY(guildinfo, b);
    local aNameCtrl = aChild:GetChild('txt_teamname');
    local bNameCtrl = bChild:GetChild('txt_teamname');
    
    return aNameCtrl:GetTextByKey('value') > bNameCtrl:GetTextByKey('value');
end

function GUILDINFO_MEMBER_SORT_LEVEL(parent, ctrl)
    local topFrame = parent:GetTopParentFrame();
    local sortFuncNameTail = GUILDINFO_MEMBER_SET_SORT_IMG(topFrame, ctrl);

    -- sort
    local sortFunc = _G['SORT_GUILDINFO_MEMBER_LEVEL'..sortFuncNameTail];
    local memberCtrlBox = GET_CHILD_RECURSIVELY(topFrame, 'memberCtrlBox');
    local childNameTable = GET_MEMBER_CTRLSET_NAME_TABLE(memberCtrlBox);
    table.sort(childNameTable, sortFunc);

    GUILDINFO_MEMBER_REALIGN(topFrame, memberCtrlBox, childNameTable);
end

function SORT_GUILDINFO_MEMBER_LEVEL(a, b)
    local guildinfo = ui.GetFrame('guildinfo');
    local aChild = GET_CHILD_RECURSIVELY(guildinfo, a);
    local bChild = GET_CHILD_RECURSIVELY(guildinfo, b);
    local aNameCtrl = aChild:GetChild('levelText');
    local bNameCtrl = bChild:GetChild('levelText');
    
    return aNameCtrl:GetTextByKey('level') < bNameCtrl:GetTextByKey('level');
end

function SORT_GUILDINFO_MEMBER_LEVEL_REVERSE(a, b)
    local guildinfo = ui.GetFrame('guildinfo');
    local aChild = GET_CHILD_RECURSIVELY(guildinfo, a);
    local bChild = GET_CHILD_RECURSIVELY(guildinfo, b);
    local aNameCtrl = aChild:GetChild('levelText');
    local bNameCtrl = bChild:GetChild('levelText');
    
    return aNameCtrl:GetTextByKey('level') > bNameCtrl:GetTextByKey('level');
end

function GUILDINFO_MEMBER_SORT_DUTY(parent, ctrl)
    local topFrame = parent:GetTopParentFrame();
    local sortFuncNameTail = GUILDINFO_MEMBER_SET_SORT_IMG(topFrame, ctrl);

    -- sort
    local sortFunc = _G['SORT_GUILDINFO_MEMBER_DUTY'..sortFuncNameTail];
    local memberCtrlBox = GET_CHILD_RECURSIVELY(topFrame, 'memberCtrlBox');
    local childNameTable = GET_MEMBER_CTRLSET_NAME_TABLE(memberCtrlBox);
    table.sort(childNameTable, sortFunc);

    GUILDINFO_MEMBER_REALIGN(topFrame, memberCtrlBox, childNameTable);
end

function SORT_GUILDINFO_MEMBER_DUTY(a, b)
    local guildinfo = ui.GetFrame('guildinfo');
    local aChild = GET_CHILD_RECURSIVELY(guildinfo, a);
    local bChild = GET_CHILD_RECURSIVELY(guildinfo, b);
    local aNameCtrl = aChild:GetChild('txt_duty');
    local bNameCtrl = bChild:GetChild('txt_duty');
    
    return aNameCtrl:GetTextByKey('value') < bNameCtrl:GetTextByKey('value');
end

function SORT_GUILDINFO_MEMBER_DUTY_REVERSE(a, b)
    local guildinfo = ui.GetFrame('guildinfo');
    local aChild = GET_CHILD_RECURSIVELY(guildinfo, a);
    local bChild = GET_CHILD_RECURSIVELY(guildinfo, b);
    local aNameCtrl = aChild:GetChild('txt_duty');
    local bNameCtrl = bChild:GetChild('txt_duty');
    
    return aNameCtrl:GetTextByKey('value') > bNameCtrl:GetTextByKey('value');
end

function SEND_REQ_GUILD_MASTER(name)
    local yesscp = string.format("_SEND_REQ_GUILD_MASTER('%s')", name);
    ui.MsgBox(ScpArgMsg('ReallyChangeLeader', 'NAME', name), yesscp, 'None');
end

function _SEND_REQ_GUILD_MASTER(name)
	ui.Chat("/guildleader " .. name);
end

function OUT_GUILD_CHECK()
    local yesScp = string.format("_OUT_GUILD_CHECK()");
	ui.MsgBox(ScpArgMsg('ReallyOutGuild'), yesScp, "None");
end

function _OUT_GUILD_CHECK()
	ui.Chat("/outguildcheck");
    ui.CloseFrame('guildinfo');
end

function SHOW_WARNING_OUT_GUILD(taxAmount)
    local yesscp = "OUT_GUILD()"
    taxAmount = GET_COMMAED_STRING(taxAmount)
    ui.MsgBox(ScpArgMsg('ColonyTax_GuildOut_RemainAsset_Warning{Tax}', 'Tax', taxAmount), yesscp, 'None');
end

function DESTROY_GUILD()
    local yesscp = "ui.Chat('/destroyguildbyweb')"
    ui.MsgBox(ScpArgMsg('ColonyTax_GuildDestroy_RemainAsset_Warning'), yesscp, 'None');
end

function OUT_GUILD()
	ui.Chat("/outguildbyweb");
    ui.CloseFrame('guildinfo');
end

function OUT_GUILD_BY_WEB()
    ui.Chat("/outguildbyweb");
    ui.CloseFrame('guildinfo');
end

function GUILD_BAN(aid)
    local memberInfo = session.party.GetPartyMemberInfoByAID(PARTY_GUILD, aid);
    local name = memberInfo:GetName();

    local yesScp = string.format("_GUILD_BAN(\"%s\")", aid);
	ui.MsgBox(ScpArgMsg('ReallyBanGuildMember', 'NAME', name), yesScp, "None");
end

function _GUILD_BAN(aid)
    ui.Chat("/guildbanByAID " .. aid);
end

function GUILD_BAN_BY_WEB(aid)
    ui.Chat("/guildbanByAID " .. aid);
end

function GUILDINFO_MEMBER_INIT_ONLINE_CHECKBOX(frame)
    local memberFilterCheck = GET_CHILD_RECURSIVELY(frame, 'memberFilterCheck');    
    memberFilterCheck:SetCheck(config.GetXMLConfig('OnlyOnlineGuildMember'));
end

function SUMMON_GUILD_MEMBER(aid)
    if IS_IN_EVENT_MAP() == true then
        ui.SysMsg(ClMsg('ImpossibleInCurrentMap'));
        return;
    end

    local memberInfo = session.party.GetPartyMemberInfoByAID(PARTY_GUILD, aid);
    if memberInfo == nil then
        return;
    end

    local yesScp = string.format("SUMMON_GUILD_MEMBER_EXEC(\"%s\")", aid);
	ui.MsgBox(ScpArgMsg('ReallySummonGuildMember', 'NAME', memberInfo:GetName()), yesScp, "None"); 
end

function SUMMON_GUILD_MEMBER_EXEC(aid)
    session.party.ClearSkillTargetList();
    session.party.AddSkillTarget(aid);
    local summonSkl = GetClass('Skill', 'Templer_SummonGuildMember');
	session.party.ReqUsePartyMemberSkill(PARTY_GUILD, summonSkl.ClassID);
end

function WARP_GUILD_MEMBER(aid)
    if IS_IN_EVENT_MAP() == true then
        ui.SysMsg(ClMsg('ImpossibleInCurrentMap'));
        return;
    end

    local memberInfo = session.party.GetPartyMemberInfoByAID(PARTY_GUILD, aid);
    if memberInfo == nil then
        return;
    end

    local yesScp = string.format("WARP_GUILD_MEMBER_EXEC(\"%s\")", aid);
	ui.MsgBox(ScpArgMsg('ReallyWarpGuildMember', 'NAME', memberInfo:GetName()), yesScp, "None"); 
end

function WARP_GUILD_MEMBER_EXEC(aid)
    if session.colonywar.GetProgressState() == true then
        local memberInfo = session.party.GetPartyMemberInfoByAID(PARTY_GUILD, aid);
        if memberInfo == nil then
            return;
        end
        local mapID = memberInfo:GetMapID()
        if mapID == 9993 or mapID == 9994 or mapID == 9995 or mapID == 9996 or mapID == 9997 or mapID == 9998 then
            local aObj = GetMyAccountObj();
            local lastGuildGIDX = TryGetProp(aObj, 'LastGuildOutGIDX');
            local lastGuildOutDay = TryGetProp(aObj, "LastGuildOutDay")
            if lastGuildOutDay ~= "None" then
                local lastTime = imcTime.GetSysTimeByStr(lastGuildOutDay)
                local addTime = AFTER_GUILD_OUT_COLONY_WAR_PARTICIPATE_PERIOD_DELAY

                -- 개척 길드 탈퇴 패널티 제거
                local guildidx = GET_GUILD_MEMBER_JOIN_AUTO_GUILD_IDX();
                if guildidx ~= "0" and guildidx == lastGuildGIDX then
                    return;
                end

                local enterEnableTime = imcTime.AddSec(lastTime, (addTime*60));
                local nowTime = session.GetDBSysTime();
                local difSec = imcTime.GetDifSec(enterEnableTime, nowTime);
                if difSec > 0 then
                    local remainDay = math.floor((((difSec/60)/60)/24))
                    local remainHour = math.floor(((difSec/60)/60)%24)
                    local remainMin = math.floor((difSec/60)%60)
                    local remainSec = math.floor(difSec%60)
                    local remainTimeStr = ScpArgMsg("GUILD_COLONY_ENTER_REMAIN_TIME{day}{hour}{min}{sec}", "day", remainDay, "hour", remainHour, "min", remainMin, "sec", remainSec)
                    addon.BroadMsg("NOTICE_Dm_scroll", ScpArgMsg("GUILD_COLONY_MSG_ENTER_FAIL5{day}{time}", "day", ((addTime/60)/24), "time", remainTimeStr), 5);
                    return
                end
            end
        end
    end
    session.party.ClearSkillTargetList();
    session.party.AddSkillTarget(aid);
    local summonSkl = GetClass('Skill', 'Templer_WarpToGuildMember');
	session.party.ReqUsePartyMemberSkill(PARTY_GUILD, summonSkl.ClassID);
end

function GUILDINFO_MEMBER_LIST_INIT()
    local allcount = session.party.GetAllMemberCount(PARTY_GUILD);

    curPage = 1;
    onlinecurPage = 1;
    scrolledTime = 0;

    local frame = ui.GetFrame("guildinfo");
    local memberCtrlBox = GET_CHILD_RECURSIVELY(frame, 'memberCtrlBox');
    memberCtrlBox:SetScrollPos(0);

    _GUILDINFO_INIT_MEMBER_TAB(frame);
end

function GUILDINFO_MEMBER_LIST_UPDATE(frame, guild, leaderAID)
    if leaderAID == nil then
        leaderAID = guild.info:GetLeaderAID();
    end

    _GUILDINFO_MEMBER_LIST_UPDATE(frame);

    -- on/off
    local allcount = session.party.GetAllMemberCount(PARTY_GUILD);
    local onlineCnt = session.party.GetOnlineMemberCount(PARTY_GUILD);
    local memberBox = GET_CHILD_RECURSIVELY(frame, 'guildinfo_');
    local memberCountText = GET_CHILD_RECURSIVELY(memberBox, 'memberCountText');
    memberCountText:SetTextByKey('online', onlineCnt);
    memberCountText:SetTextByKey('offline', allcount - onlineCnt);
end

function _GUILDINFO_MEMBER_LIST_UPDATE(frame)
    local memberCtrlBox = GET_CHILD_RECURSIVELY(frame, 'memberCtrlBox');
    DESTROY_CHILD_BYNAME(memberCtrlBox, 'MEMBER_');

    local guild = GET_MY_GUILD_INFO();
    local leaderAID = guild.info:GetLeaderAID();
    local leaderInfo = session.party.GetPartyMemberInfoByAID(PARTY_GUILD, leaderAID);

    local checkBox = GET_CHILD_RECURSIVELY(frame, 'memberFilterCheck');
    local showOnlyOnline = checkBox:IsChecked();
    if showOnlyOnline == 0 then
        -- 길드 마스터 먼저 추가
        local memberCtrlBox = GET_CHILD_RECURSIVELY(frame, 'memberCtrlBox');
        GUILDINFO_MEMBER_LIST_CREATE(memberCtrlBox, leaderInfo);

        for i = 1, curPage do 
            GUILDINFO_MEMBER_LIST(frame, i);
        end
    else
        if leaderInfo:GetMapID() > 0 then
            -- 길드 마스터 먼저 추가
            local memberCtrlBox = GET_CHILD_RECURSIVELY(frame, 'memberCtrlBox');
            GUILDINFO_MEMBER_LIST_CREATE(memberCtrlBox, leaderInfo);
        end

        for i = 1, onlinecurPage do
            GUILDINFO_ONLINE_MEMBER_LIST(frame, i);
        end
    end

    GBOX_AUTO_ALIGN(memberCtrlBox, 0, 0, 0, true, false, true);
end

function GUILDINFO_MEMBER_LIST(frame, page)
    local list = session.party.GetPartyMemberListbyPage(PARTY_GUILD, page);
    local cnt = list:Count();
    local memberCtrlBox = GET_CHILD_RECURSIVELY(frame, 'memberCtrlBox');
    for i = 0, cnt - 1 do
        local partyMemberInfo = list:Element(i);
        GUILDINFO_MEMBER_LIST_CREATE(memberCtrlBox, partyMemberInfo);
    end
end

function GUILDINFO_ONLINE_MEMBER_LIST(frame, page)
    local memberCtrlBox = GET_CHILD_RECURSIVELY(frame, 'memberCtrlBox');
    local list = session.party.GetOnlinePartyMemberListbyPage(PARTY_GUILD, page);
    local count = list:Count();
    for i = 0, count - 1 do
        local partyMemberInfo = list:Element(i);
        GUILDINFO_MEMBER_LIST_CREATE(memberCtrlBox, partyMemberInfo);
    end
end

function GUILDINFO_MEMBER_LIST_CREATE(memberCtrlBox, partyMemberInfo)
    if partyMemberInfo == nil then
        return;
    end

    local aid = partyMemberInfo:GetAID();
    local memberCtrlSet = memberCtrlBox:CreateOrGetControlSet('guild_memberinfo', 'MEMBER_'..aid, 0, 0);
    memberCtrlSet = AUTO_CAST(memberCtrlSet);
    memberCtrlSet:SetUserValue('AID', aid);

    local isOnline = true;
    local pic_online = GET_CHILD_RECURSIVELY(memberCtrlSet, 'pic_online');
    local txt_location = GET_CHILD_RECURSIVELY(memberCtrlSet, 'txt_location');
    local ONLINE_IMG = memberCtrlSet:GetUserConfig('ONLINE_IMG');
    local OFFLINE_IMG = memberCtrlSet:GetUserConfig('OFFLINE_IMG');
    local MY_CHAR_BG_SKIN = memberCtrlSet:GetUserConfig('MY_CHAR_BG_SKIN');

    -- bg
    if aid == session.loginInfo.GetAID() then
        local bg = GET_CHILD_RECURSIVELY(memberCtrlSet,'bg');
        bg:SetSkinName(MY_CHAR_BG_SKIN);
    end

    -- on/off & location
    local locationText = "";
    if partyMemberInfo:GetMapID() > 0 then
        local mapCls = GetClassByType("Map", partyMemberInfo:GetMapID());
        if mapCls ~= nil then
            pic_online:SetImage(ONLINE_IMG);
            locationText = string.format("[%s%d] %s", ScpArgMsg("Channel"), partyMemberInfo:GetChannel() + 1, mapCls.Name);
        end
    else
        isOnline = false;
        pic_online:SetImage(OFFLINE_IMG);
        local logoutSec = partyMemberInfo:GetLogoutSec();
        if logoutSec >= 0 then
            locationText = GET_DIFF_TIME_TXT(logoutSec);
        else				
            locationText = ScpArgMsg("LogoutLongTime");
        end
    end
    txt_location:SetTextByKey("value", locationText);
    txt_location:SetTextTooltip(locationText);

    -- name
    local txt_teamname = GET_CHILD_RECURSIVELY(memberCtrlSet, 'txt_teamname');
    local name = partyMemberInfo:GetName();
    txt_teamname:SetTextByKey('value', partyMemberInfo:GetName());
    txt_teamname:SetTextTooltip(partyMemberInfo:GetName());

    -- job
    local jobID = partyMemberInfo:GetIconInfo().repre_job;    
    local jobCls = GetClassByType('Job', jobID);
    local jobName = GET_JOB_NAME(jobCls, partyMemberInfo:GetIconInfo().gender);
    if jobName ~= nil then
        local jobText = GET_CHILD_RECURSIVELY(memberCtrlSet, 'jobText')
        jobText:SetTextByKey('job', jobName);
    end
                
    -- level
    if isOnline == true then
        local levelText = GET_CHILD_RECURSIVELY(memberCtrlSet, 'levelText');
        levelText:SetTextByKey('level', partyMemberInfo:GetLevel());
    end
    -- claim
    local txt_duty = GET_CHILD_RECURSIVELY(memberCtrlSet, 'txt_duty');        
    local grade = partyMemberInfo.grade;
    
    local guild = GET_MY_GUILD_INFO();
    local leaderAID = guild.info:GetLeaderAID();
    if leaderAID == aid then
        local dutyName = "{ol}{#FFFF00}" .. ScpArgMsg("GuildMaster") .. "{/}{/}";
        dutyName = dutyName .. " " .. guild:GetDutyName(grade);
        txt_duty:SetTextByKey("value", dutyName);
    else
        local claimName = GET_CLAIM_NAME_BY_AIDX(aid);
        if claimName == nil then
            claimName = "";
            GetPlayerMemberTitle("ON_GUILDINFO_MEMBER_TITLE_GET", aid);
        end
        txt_duty:SetTextByKey("value", claimName);
    end

    -- contribution
    local memberObj = GetIES(partyMemberInfo:GetObject());
    local contributionText =GET_CHILD_RECURSIVELY(memberCtrlSet, 'contributionText');
    contributionText:SetTextByKey('contribution', memberObj.Contribution);

    memberCtrlSet:SetEventScript(ui.RBUTTONDOWN, 'POPUP_GUILD_MEMBER');
end

function GUILDINFO_MEMBER_LIST_SCROLL(parent, ctrl)
    local frame = parent:GetTopParentFrame();
    if ctrl:IsScrollEnd() == true then
        local now = imcTime.GetAppTime();
        local dif = now - scrolledTime;

        if 1 < dif then
            scrolledTime = now;
            
            local checkBox = GET_CHILD_RECURSIVELY(frame, 'memberFilterCheck');
            local showOnlyOnline = checkBox:IsChecked();
            if showOnlyOnline == 0 then
                curPage = curPage + 1;
                GUILDINFO_MEMBER_LIST(frame, curPage);
            else
                onlinecurPage = onlinecurPage + 1;
                GUILDINFO_ONLINE_MEMBER_LIST(frame, onlinecurPage);
            end
        end
    end

    local memberCtrlBox = GET_CHILD_RECURSIVELY(frame, 'memberCtrlBox');
    GBOX_AUTO_ALIGN(memberCtrlBox, 0, 0, 0, true, false, true);
end
