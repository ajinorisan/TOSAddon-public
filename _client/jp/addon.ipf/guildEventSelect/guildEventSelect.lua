function GUILDEVENTSELECT_ON_INIT(addon, frame)
	addon:RegisterMsg("GUILD_EVENT_START_REQUEST_MSG_BOX", "ON_GUILD_EVENT_START_REQUEST_MSG_BOX");
	addon:RegisterMsg("ACCEPT_GUILD_EVENT", "ON_ACCEPT_GUILD_EVENT");
end

function REQ_OPEN_GUILD_EVENT_PIP()
	local frame = ui.GetFrame("guildEventSelect");
	if frame ~= nil then
		GUILD_EVENT_OPEN(frame);
	end
end

function GUILD_EVENT_OPEN(frame)
	if frame ~= nil then
		ui.OpenFrame("guildEventSelect");
		local guild = session.party.GetPartyInfo(PARTY_GUILD);
		if guild == nil then 
			return; 
		end
		local guild_obj = GetIES(guild:GetObject());
		if guild_obj ~= nil then
			local level = guild_obj.Level;
			local text_title = GET_CHILD_RECURSIVELY(frame, "text_title");
			if text_title ~= nil then
				text_title:SetTextByKey("level", level);
			end
		end
		CREATE_GUILD_EVENT_LIST_INIT(frame);
		CREATE_GUILD_EVENT_LIST(frame);
	end
end

function GUILDEVENT_SELECT_TAB_CAHNGE(parent, ctrl)
	local frame = parent:GetTopParentFrame();
	local gbox = GET_CHILD_RECURSIVELY(frame, "gbox");
	if gbox ~= nil then DESTROY_CHILD_BY_USERVALUE(gbox, "GUILD_EVENT_CTRL", "YES"); end
	CREATE_GUILD_EVENT_LIST(frame);
end

function CREATE_GUILD_EVENT_LIST_INIT(frame)
	local tab = GET_CHILD_RECURSIVELY(frame, "tab");
	tab:SelectTab(0);
end

function CREATE_GUILD_EVENT_LIST(frame)	
	if frame == nil then return; end
	local gbox = GET_CHILD_RECURSIVELY(frame, "gbox");
	local tab = GET_CHILD_RECURSIVELY(frame, "tab");
	if gbox == nil or tab == nil then return; end
	local guild = session.party.GetPartyInfo(PARTY_GUILD);
	if guild == nil then return; end
	local guild_obj = GetIES(guild:GetObject());
	if guild_obj == nil then return; end
	local lv = guild_obj.Level;
	local index = tab:GetSelectItemIndex();
	local list, cnt = GetClassList("GuildEvent");
	for i = 0, cnt - 1 do	
		local cls = GetClassByIndexFromList(list, i);
		if cls ~= nil then
			local guild_lv = TryGetProp(cls, "GuildLv", 0);
			local tab_index = TryGetProp(cls, "TabIndex", 0);
			local event_type = TryGetProp(cls, "EventType", "None");
			if tab_index == index then
				local ticket_value = TryGetProp(cls, "TicketCount", 0);
				local block_mission = TryGetProp(cls, "BlockMission", "None");
				
				local start = '2023-05-29 00:00:00'
				local finish = '2023-07-26 00:00:00'
				if block_mission == "YES" and config.GetServiceNation() == 'PAPAYA' and date_time.is_between_time(start, finish) == true then
					-- #124856 , #124857
				else
					if block_mission == "YES" then ticket_value = 3; end
					-- create list
					if guild_lv > 0 and lv >= guild_lv then
						local class_name = TryGetProp(cls, "ClassName", "None");
						local ctrlset = gbox:CreateOrGetControlSet("guild_event", class_name, ui.LEFT, ui.TOP, 0, 0, 0, 0);
						if ctrlset ~= nil then
							ctrlset:SetUserValue("GUILD_EVENT_CTRL", "YES");
	
							local name = TryGetProp(cls, "Name", "None");
							local event_name = GET_CHILD_RECURSIVELY(ctrlset, "EventName");
							event_name:SetTextByKey("value", name);
	
							local max_player_count = TryGetProp(cls, "MaxPlayerCnt", 0);
							local user_count = GET_CHILD_RECURSIVELY(ctrlset, "UserCount");
							user_count:SetTextByKey("value", tostring(max_player_count));
	
							local time_limit_prop = TryGetProp(cls, "TimeLimit", 0);
							local time_limit = GET_CHILD_RECURSIVELY(ctrlset, "TimeLimit");	
							time_limit:SetTextByKey("value", tostring(time_limit_prop / 60));
	
							local detail = TryGetProp(cls, "DetailInfo", "None");
							local detail_info = GET_CHILD_RECURSIVELY(ctrlset, "detailInfo");	
							detail_info:SetTextByKey("value", detail);
	
							local ticketText = GET_CHILD_RECURSIVELY(ctrlset, "ticketText");	
							ticketText:SetTextByKey("value", tostring(ticket_value));
	
							local event_type = GET_CHILD_RECURSIVELY(ctrlset, "EventType", "ui::CPicture");
							local img = frame:GetUserConfig("EVENT_TYPE_"..index);
							event_type:SetImage(img);
	
							local class_id = TryGetProp(cls, "ClassID", 0);
							ctrlset:SetUserValue("CLSID", class_id);
						end
					end
				end
			end
		end
	end
	GBOX_AUTO_ALIGN(gbox, 0, 0, 10, true, false);
end

function GET_ACCEPT_GUILD_EVENT_COMPARE_GUILD_EVENT_NAME(evnet_id)
	if evnet_id == nil then return ""; end
	local compare_evnet_id = {};
	if evnet_id == 503 then compare_evnet_id = { 504, 505 };
	elseif evnet_id == 504 then compare_evnet_id = { 503, 505 };	
	elseif evnet_id == 505 then compare_evnet_id = { 503, 504 }; end
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

function ACCEPT_GUILD_EVENT(parent, ctrl)
	-- 길드 이벤트 진행 여부 체크
	local cls_id = parent:GetUserIValue("CLSID");
	control.CustomCommand("REQ_EXIST_GUILD_EVENT_CHECK", cls_id);
end

function ON_ACCEPT_GUILD_EVENT(cls_id)
	local cls = GetClassByType("GuildEvent", cls_id);
	if cls ~= nil then
		local msg = ScpArgMsg("DoYouWant{GuildEvent}Start?", "GuildEvent", cls.Name);
		local compare_cls_name = GET_ACCEPT_GUILD_EVENT_COMPARE_GUILD_EVENT_NAME(cls_id);
		if compare_cls_name ~= nil and compare_cls_name ~= "" then
			msg = ScpArgMsg("guild_event_start{guildEvent}{compareEvent}", "guildEvent", cls.Name, "compareEvent", compare_cls_name);
		end
		local yesScp = string.format("EXEC_GUILD_EVENT(%d)", cls_id);
		ui.MsgBox(msg, yesScp, "None");
	end
end

function EXEC_GUILD_EVENT(cls_id)
	local cls = GetClassByType("GuildEvent", cls_id);
	if cls == nil then return; end

	local special_mission = false;
	local block_mission = TryGetProp(cls, "BlockMission", "None");
    if block_mission == "YES" then
        special_mission = true;
    end

	local guild = session.party.GetPartyInfo(PARTY_GUILD);
	if guild == nil then
		return;
	end

	local guild_obj = GetIES(guild:GetObject());
	local have_ticket = GET_REMAIN_TICKET_COUNT(guild_obj)
	if have_ticket <= 0 then
		ui.SysMsg(ScpArgMsg("NotEnoughTicketPossibleCount"));
		return;
	end
	
	if special_mission == true then
	    if have_ticket < 3 then
    		ui.SysMsg(ScpArgMsg("NotEnoughTicketPossibleCount"));
    		return;
		end
	end
	
	ui.CloseFrame("guildEventSelect");
	control.CustomCommand("GUILD_EVENT_START_REQUEST", cls_id);
end

function ON_GUILD_EVENT_START_REQUEST_MSG_BOX(frame, msg, argStr, argNum)
	if frame ~= nil then 
		local event_id = tonumber(argStr);
		EXEC_GUILD_EVENT_START_REQUEST_MSG_BOX(event_id);
	end
end

function EXEC_GUILD_EVENT_START_REQUEST_MSG_BOX(event_id)
	if event_id ~= nil then
		local class = GetClassByType("GuildEvent", event_id);
		if class ~= nil then
			control.CustomCommand("GUILD_EVENT_START", event_id);
		end
	end
end

-- Dev #97866 길드 퀘스트 바로가기 기능 추가
function MOVE_GUILD_EVENT(parent, ctrl)
	local cls_id = parent:GetUserIValue("CLSID");
	-- 맵 이름
	local cls = GetClassByType("GuildEvent", cls_id)
	if cls == nil then return end
	local map_cls_name = TryGetProp(cls, "StartMap", "None")
	if map_cls_name == "None" then return end
	local map_cls = GetClassByStrProp("Map", "ClassName", map_cls_name);
	if map_cls == nil then return end
	local map_name = TryGetProp(map_cls, "Name", "None")
	if map_name == "None" then return end
	-- 메세지 박스
	local msg = ScpArgMsg("{StartMap}DoYouWantMove", "StartMap", map_name)
	local yes_scp = string.format("MOVE_GUILD_EVENT_RUN(%d)", cls_id);
	ui.MsgBox(msg, yes_scp, "None");
end

function MOVE_GUILD_EVENT_RUN(cls_id)
	control.CustomCommand("GUILD_EVENT_MOVE_MAP", cls_id)
end

