function GUILDEVENTSELECT_ON_INIT(addon, frame)
	addon:RegisterMsg("GUILD_EVENT_START_REQUEST_MSG_BOX", "ON_GUILD_EVENT_START_REQUEST_MSG_BOX");
	addon:RegisterMsg("ACCEPT_GUILD_EVENT", "ON_ACCEPT_GUILD_EVENT");
end

function REQ_OPEN_GUILD_EVENT_PIP()
 	gGuileEventList = {"FBOSS", "MISSION"};
	GUILD_EVENT_OPEN(nil);
end

function GUILD_EVENT_OPEN(frame)
	if frame == nil then
		frame = ui.GetFrame("guildEventSelect")
	end

	ui.OpenFrame("guildEventSelect");

	local pcGuild = session.party.GetPartyInfo(PARTY_GUILD);
	if pcGuild == nil then
		return;
	end

	local guildObj = GetIES(pcGuild:GetObject());
	local lv = guildObj.Level;

	local lvText = GET_CHILD_RECURSIVELY(frame, "guildLevel");
	lvText:SetTextByKey("value", lv);

	CREATE_GUILD_EVENT_LIST_INIT(frame);
	CREATE_GUILD_EVENT_LIST(frame);
end

function CREATE_GUILD_EVENT_LIST(frame)
	local gbox = GET_CHILD(frame, "bg_title_key");
	DESTROY_CHILD_BY_USERVALUE(gbox, "GUILD_EVENT_CTRL", "YES");
	local droplist = GET_CHILD(frame, "droplist_1", "ui::CDropList");
	local clsList, cnt = GetClassList("GuildEvent");

	local pcGuild = session.party.GetPartyInfo(PARTY_GUILD);
	if pcGuild == nil then
	end
	local guildObj = GetIES(pcGuild:GetObject());
	local lv = guildObj.Level;

	for i = 0, cnt - 1 do	
		local cls = GetClassByIndexFromList(clsList, i);
		if cls.EventType == gGuileEventList[droplist:GetSelItemIndex()+1] then
		    local ticket_value = 1
		    if cls.ClassName == 'GM_BorutosKapas_1' or cls.ClassName == "GM_Giltine_1" or cls.ClassName == 'GM_Baubas_1' then
		        ticket_value = 3
		    end

			if cls.GuildLv > 0 and lv >= cls.GuildLv then
				local ctrlSet = gbox:CreateControlSet("guild_event", cls.ClassName, ui.LEFT, ui.TOP, 0, 0, 0, 0);
				ctrlSet:SetUserValue("GUILD_EVENT_CTRL", "YES");

				local eventName = GET_CHILD(ctrlSet, "EventName");
				eventName:SetTextByKey("value", cls.Name);

				local userCount = GET_CHILD(ctrlSet, "UserCount");
				userCount:SetTextByKey("value", cls.MaxPlayerCnt);

				local timeLimit = GET_CHILD(ctrlSet, "TimeLimit");	
				timeLimit:SetTextByKey("value", cls.TimeLimit/60);

				local detailInfo = GET_CHILD(ctrlSet, "detailInfo");	
				detailInfo:SetTextByKey("value", cls.DetailInfo);

				local ticketText = GET_CHILD(ctrlSet, "ticketText");	
				ticketText:SetTextByKey("value", ticket_value);

				local eventType = GET_CHILD_RECURSIVELY(ctrlSet, "EventType", "ui::CPicture");
				local imgName = frame:GetUserConfig("EVENT_TYPE_"..droplist:GetSelItemIndex())
				eventType:SetImage(imgName);
				ctrlSet:SetUserValue("CLSID", cls.ClassID);
			end
		end
	end
	GBOX_AUTO_ALIGN(gbox, 0, 0, 10, true, false);
end

function CREATE_GUILD_EVENT_LIST_INIT(frame)
	local droplist = GET_CHILD(frame, "droplist_1", "ui::CDropList");
	droplist:ClearItems();
	droplist:AddItem("0",  ClMsg("GuildIBossSummon"), 0);
	droplist:AddItem("1",  ClMsg("GuildMission"), 0);
end

function CREATE_GUILD_EVENT_LIST_CLICK(frame, ctrl)
	local list = tolua.cast(ctrl, "ui::CDropList");
	CREATE_GUILD_EVENT_LIST(frame)
end

function ACCEPT_GUILD_EVENT(parent, ctrl)
	-- 길드 이벤트 진행 여부 체크
	local clsID = parent:GetUserIValue("CLSID");
	control.CustomCommand("REQ_EXIST_GUILD_EVENT_CHECK", clsID);
end

function GET_ACCEPT_GUILD_EVENT_COMPARE_GUILD_EVENT_NAME(evnet_id)
	if evnet_id == nil then return ""; end
	local compare_evnet_id = {};
	if evnet_id == 500 then compare_evnet_id = { 501, 502 };
	elseif evnet_id == 501 then compare_evnet_id = { 500, 502 };	
	elseif evnet_id == 502 then compare_evnet_id = { 500, 501 }; end
	local compare_guild_evnet_name = "";
	for i = 1, #compare_evnet_id do
		local id = compare_evnet_id[i];
		local cls = GetClassByType("GuildEvent", id);
		if cls ~= nil then
			local name = TryGetProp(cls, "Name", "None");
			compare_guild_evnet_name = compare_guild_evnet_name..name;
			if i ~= #compare_evnet_id then
				compare_guild_evnet_name = compare_guild_evnet_name..", ";
			end
		end
	end
	return compare_guild_evnet_name;
end

function ON_ACCEPT_GUILD_EVENT(clsID)
	local cls = GetClassByType("GuildEvent", clsID);
	if cls ~= nil then
		local msg = ScpArgMsg("DoYouWant{GuildEvent}Start?", "GuildEvent", cls.Name);
		local compare_cls_name = GET_ACCEPT_GUILD_EVENT_COMPARE_GUILD_EVENT_NAME(clsID);
		if compare_cls_name ~= nil and compare_cls_name ~= "" then
			msg = ScpArgMsg("guild_event_start{guildEvent}{compareEvent}", "guildEvent", cls.Name, "compareEvent", compare_cls_name);
		end
		local yesScp = string.format("EXEC_GUILD_EVENT(%d)", clsID);
		ui.MsgBox(msg, yesScp, "None");
	end
end

function EXEC_GUILD_EVENT(clsID)
    local cls = GetClassByType("GuildEvent", clsID)
    local special_mission = false;
    if cls.ClassName == 'GM_BorutosKapas_1' or cls.ClassName == "GM_Giltine_1" or cls.ClassName == 'GM_Baubas_1' then
        special_mission = true;
    end

	local pcGuild = session.party.GetPartyInfo(PARTY_GUILD);
	if pcGuild == nil then
		return;
	end

	local guildObj = GetIES(pcGuild:GetObject());
	local haveTicket = GET_REMAIN_TICKET_COUNT(guildObj)
	if haveTicket <= 0 then
		ui.SysMsg(ScpArgMsg("NotEnoughTicketPossibleCount"));
		return;
	end
	
	if special_mission == true then
	    if haveTicket < 3 then
    		ui.SysMsg(ScpArgMsg("NotEnoughTicketPossibleCount"));
    		return;
		end
	end
	
	ui.CloseFrame('guildEventSelect');
	control.CustomCommand("GUILD_EVENT_START_REQUEST", clsID);
end

function ON_GUILD_EVENT_START_REQUEST_MSG_BOX(frame, msg, argStr, argNum)
	if frame ~= nil then 
		local eventID = tonumber(argStr);
		EXEC_GUILD_EVENT_START_REQUEST_MSG_BOX(eventID);
	end
end

function EXEC_GUILD_EVENT_START_REQUEST_MSG_BOX(eventID)
	if eventID ~= nil then
		local class = GetClassByType("GuildEvent", eventID);
		if class ~= nil then
			control.CustomCommand("GUILD_EVENT_START", eventID);
		end
	end
end

-- Dev #97866 길드 퀘스트 바로가기 기능 추가
function MOVE_GUILD_EVENT(parent, ctrl)
	local clsID = parent:GetUserIValue("CLSID")
	-- 맵 이름
	local cls = GetClassByType("GuildEvent", clsID)
	if cls == nil then return end
	local mapClsName = TryGetProp(cls, "StartMap", "None")
	if mapClsName == "None" then return end
	local mapCls = GetClassByStrProp("Map", "ClassName", mapClsName);
	if mapCls == nil then return end
	local mapName = TryGetProp(mapCls, "Name", "None")
	if mapName == "None" then return end
	-- 메세지 박스
	local msg = ScpArgMsg("{StartMap}DoYouWantMove", "StartMap", mapName)
	local yesScp = string.format("MOVE_GUILD_EVENT_RUN(%d)", clsID);
	ui.MsgBox(msg, yesScp, "None");
end

function MOVE_GUILD_EVENT_RUN(clsID)
	control.CustomCommand("GUILD_EVENT_MOVE_MAP", clsID)
end

