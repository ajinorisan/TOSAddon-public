function EVENT_NEW_SEASON_SERVER_COIN_CHECK_ON_INIT(addon, frame)
	addon:RegisterMsg("EVENT_NEW_SEASON_SERVER_COIN_CHECK_OPEN_COMMAND", "EVENT_NEW_SEASON_SERVER_COIN_CHECK_OPEN_COMMAND");
	addon:RegisterMsg("EVENT_NEW_SEASON_SERVER_DAILY_PLAY_TIME_UPDATE", "EVENT_NEW_SEASON_SERVER_DAILY_PLAY_TIME_UPDATE");
end

function EVENT_NEW_SEASON_SERVER_COIN_CHECK_OPEN_COMMAND()
	ui.OpenFrame("event_new_season_server_coin_check");
end

function EVENT_NEW_SEASON_SERVER_COIN_CHECK_OPEN(frame)
	local tab = GET_CHILD(frame, "tab");
	tab:SelectTab(0);

	EVENT_NEW_SEASON_SERVER_COIN_CHECK_TAB_CLICK(frame, tab)

	local tiptext = GET_CHILD(frame, "tiptext");
	tiptext:SetTextByKey("value", ClMsg("EVENT_NEW_SEASON_SERVER_stamp_tour_tip_text"));
end

function EVENT_NEW_SEASON_SERVER_COIN_CHECK_TAB_CLICK(parent, ctrl)
	local index = ctrl:GetSelectItemIndex();

	if index == 0 then
		COIN_ACQUIRE_STATE_OPEN(parent:GetTopParentFrame());
	elseif index == 1 then
        STAMP_TOUR_STATE_OPEN(parent:GetTopParentFrame());
    elseif index == 2 then
        CONTENTS_MISSION_STATE_OPEN(parent:GetTopParentFrame());
	end

end

------------------------- 획득 현황 -------------------------
function COIN_ACQUIRE_STATE_OPEN(frame)
	local nametext = GET_CHILD_RECURSIVELY(frame, "nametext");
	nametext:SetTextByKey('value', frame:GetUserConfig("COIN_ACQUIRE_TITLE"));
	
	local listgb = GET_CHILD(frame, "listgb");
	listgb:RemoveAllChild();
	
	local notebtn = GET_CHILD_RECURSIVELY(frame, "notebtn");
	notebtn:ShowWindow(0);
	
	local tiptext = GET_CHILD(frame, "tiptext");
	tiptext:ShowWindow(1);
	tiptext:SetTextByKey("value", ClMsg("EVENT_NEW_SEASON_SERVER_stamp_tour_tip_text"));

	local accObj = GetMyAccountObj();
	if accObj == nil then return; end
	local type = GET_USE_ROULETTE_TYPE(1);

	local hide = false
	local y = 0;
	for i = 1, 5 do
		local ctrlSet = listgb:CreateControlSet('icon_with_current_state', "CTRLSET_" .. i,  ui.CENTER_HORZ, ui.TOP, 0, y, 0, 0);
		local iconpic = GET_CHILD(ctrlSet, "iconpic");
		local iconname = frame:GetUserConfig("COIN_ACQUIRE_STAT_ICON_"..i);
		iconpic:SetImage(iconname);
		
		local npc_pos_btn = GET_CHILD(ctrlSet, "btn");
		npc_pos_btn:ShowWindow(0);

		local blackbg = GET_CHILD(ctrlSet, "blackbg");
		blackbg:ShowWindow(0);
		
		local text = GET_CHILD(ctrlSet, "text");
		text:SetTextByKey('value', ClMsg('EVENT_NEW_SEASON_SERVER_COIN_CHECK_STATE_'..i));
		
		local gb = GET_CHILD(ctrlSet, "gb");
		-- gb:SetTextTooltip(ClMsg("NEW_SEASON_SERVER_COIN_CHECK_TOOLTIP_"..i));

		local comming_soon_pic = GET_CHILD(ctrlSet, "comming_soon_pic");
		comming_soon_pic:ShowWindow(0);

		local state = GET_CHILD(ctrlSet, "state");
		local curvalue = 0;
		local maxvalue = 9999999;
		if i == 1 then
			-- 총 코인 획득량
			text:SetTextByKey('value', ClMsg('EVENT_NEW_SEASON_SERVER_COIN_CHECK_STATE_'..i));

			local stampCoin = TryGetProp(accObj, "GODDESS_ROULETTE_STAMP_COIN_ACQUIRE_COUNT", 0);
			local totalDailyCoin = TryGetProp(accObj, "GODDESS_ROULETTE_COIN_ACQUIRE_COUNT", 0);
			
			curvalue = stampCoin + totalDailyCoin
			maxvalue = GODDESS_ROULETTE_COIN_MAX_COUNT;
			if maxvalue <= curvalue then
				hide = true
			end
		elseif i == 2 then
			-- (누적) 스탬프 코인 획득량
			text:SetTextByKey('value', ClMsg('EVENT_NEW_SEASON_SERVER_COIN_CHECK_STATE_'..i));
			curvalue = TryGetProp(accObj, "GODDESS_ROULETTE_STAMP_COIN_ACQUIRE_COUNT", 0);
			maxvalue = GODDESS_ROULETTE_STAMP_COIN_MAX_COUNT;
	
		elseif i == 3 then
			-- (누적) 일일 코인 획득량
			text:SetTextByKey('value', ClMsg('EVENT_NEW_SEASON_SERVER_COIN_CHECK_STATE_'..i));

			curvalue = TryGetProp(accObj, "GODDESS_ROULETTE_COIN_ACQUIRE_COUNT", 0);
			maxvalue = GODDESS_ROULETTE_COIN_DAY_MAX_COUNT;
			
			if maxvalue <= curvalue then
				hide = true
			end
		elseif i == 4 then
			-- (오늘) 일일 코인 획득량
			text:SetTextByKey('value', ClMsg('EVENT_NEW_SEASON_SERVER_COIN_CHECK_STATE_'..i));

			curvalue = TryGetProp(accObj, "GODDESS_ROULETTE_DAILY_CONTENTS_ACQUIRE_COUNT", 0);
			maxvalue = GODDESS_ROULETTE_DAILY_CONTENTS_MAX_COIN_COUNT;
		elseif i == 5 then
			-- 여신의 룰렛 이용 횟수
			text:SetTextByKey('value', ClMsg('EVENT_NEW_SEASON_SERVER_COIN_CHECK_STATE_'..i));

			curvalue = GET_USE_ROULETTE_COUNT('GODDESS_ROULETTE', accObj);
			maxvalue = GODDESS_ROULETTE_MAX_COUNT;
			if maxvalue > curvalue then
				hide = false
			end
		end
		
		-- 진행도 완료시 음영처리
		if maxvalue <= curvalue or hide == true then
			blackbg:ShowWindow(1);
			blackbg:SetAlpha(90);
		end

		state:SetTextByKey('cur', curvalue);
		state:SetTextByKey('max', maxvalue);

		y = y + ctrlSet:GetHeight();
	end

end

function GET_STAMP_TOUR_CLEAR_COUNT()
	local accObj = GetMyAccountObj();
	if accObj == nil then return 0;	end

	local curCount = 0;
	for i = 1, EVENT_NEW_SEASON_SERVER_STAMP_TOUR_MAX_COUNT do
		local propname = "None";
		if i < 10 then
			propname = "REGULAR_EVENT_STAMP_TOUR_CHECK0"..i;
		else
			propname = "REGULAR_EVENT_STAMP_TOUR_CHECK"..i;
		end

		local curvalue = TryGetProp(accObj, propname);
		
		if curvalue == "true" then
			curCount = curCount + 1;
		end
	end

	return curCount;
end

function GET_CONTENT_MISSION_CLEAR_COUNT()
	local accObj = GetMyAccountObj();
	if accObj == nil then return 0;	end

	local curCount = 0;
	for i = 1, EVENT_NEW_SEASON_SERVER_CONTENT_MISSION_MAX_COUNT do
		local propname = "EVENT_NEW_SEASON_SERVER_CONTENT_FIRST_CLEAR_CHECK_"..i;
		local curvalue = TryGetProp(accObj, propname);
		
		if curvalue == 1 then
			curCount = curCount + 1;
		end

	end

	return curCount;
end

function EVENT_NEW_SEASON_SERVER_DAILY_PLAY_TIME_UPDATE(frame, msg, time)
	local frame = ui.GetFrame("event_new_season_server_coin_check");	
	if frame:IsVisible() == 0 then
		return;
	end

	local tab = GET_CHILD(frame, "tab");
	local index = tab:GetSelectItemIndex();
	if index ~= 0 then
		return;
	end

	local listgb = GET_CHILD(frame, "listgb");
	local ctrlSet = GET_CHILD_RECURSIVELY(frame, "CTRLSET_2");
	if ctrlSet == nil then
		return;
	end
	
	local state = GET_CHILD(ctrlSet, "state");
	state:SetTextByKey("cur", time);

	if 60 <= tonumber(time) then
		local blackbg = GET_CHILD(ctrlSet, "blackbg");
		blackbg:ShowWindow(1);
		blackbg:SetAlpha(90);

		local clear_text = GET_CHILD(ctrlSet, "clear_text");
		clear_text:SetTextByKey("value", ClMsg("GoddessRouletteDailyPlayTimeClearText"));
		clear_text:ShowWindow(1);
	end
end

------------------------- 스탬프 투어 -------------------------
function STAMP_TOUR_STATE_OPEN(frame)
	local nametext = GET_CHILD_RECURSIVELY(frame, "nametext", "richtext");
	nametext:SetTextByKey('value', frame:GetUserConfig("STAMP_TOUR_TITLE"));

	local listgb = GET_CHILD(frame, "listgb");
	listgb:RemoveAllChild();

	local notebtn = GET_CHILD_RECURSIVELY(frame, "notebtn");
	notebtn:ShowWindow(0);

	local tiptext = GET_CHILD(frame, "tiptext");
	tiptext:ShowWindow(0);

	local accObj = GetMyAccountObj();
	if accObj == nil then return; end

	local stampTourCheck = 1--TryGetProp(accObj, "REGULAR_EVENT_STAMP_TOUR");
	if stampTourCheck == 1 then
		notebtn:ShowWindow(1);

		local y = 0;
		y = CREATE_STAMP_TOUR_STATE_LIST(y, listgb, false);	-- 완료 되지 않은 목표 우선 표시
		y = CREATE_STAMP_TOUR_STATE_LIST(y, listgb, true);
	else		
		local ctrl = listgb:CreateControl("richtext", "stamp_tour_tip_text", 500, 100, ui.CENTER_HORZ, ui.CENTER_VERT, 0, 0, 0, 0);
		ctrl:SetTextFixWidth(1);
		ctrl:SetTextAlign("center", "top");
		ctrl:SetFontName("black_24");
		ctrl:SetText(ClMsg("EVENT_NEW_SEASON_SERVER_stamp_tour_tip_text2"));		
	end

end

function CREATE_STAMP_TOUR_STATE_LIST(starty, listgb, isClear)	
	local accObj = GetMyAccountObj();
	if accObj == nil then return; end

	local y = starty;
	local clsList, clsCnt = GetClassList("note_eventlist");
	for i = 0, clsCnt - 1 do
		local missionCls = EVENT_STAMP_GET_CURRENT_MISSION("REGULAR_EVENT_STAMP_TOUR",i);
		if missionCls == nil then
			break
		end
		for j = 1, 3 do
			local clearprop = TryGetProp(missionCls, "ClearProp"..j, 'None');
			local clear = TryGetProp(accObj, clearprop, 'false');

			if (clear == 'true' and isClear == true) or (clear == 'false' and isClear == false) then
				local missiontext = TryGetProp(missionCls, "Name"..j, "");
				local missionlist = StringSplit(missiontext, ":");
				
				if missiontext ~= "None" then
					local ctrlSet = listgb:CreateControlSet('check_to_do_list_season', "CTRLSET_" ..i.."_"..j,  ui.CENTER_HORZ, ui.TOP, -10, y, 0, 0);
					local rewardtext = GET_CHILD(ctrlSet, "rewardtext");
					rewardtext:SetTextByKey('value', missionlist[1]);
					if #missionlist > 1 then
						local tooltipText = string.format( "%s", missionlist[2]);
						rewardtext:SetTextTooltip(tooltipText);
						rewardtext:EnableHitTest(1);
					else
						rewardtext:SetTextTooltip("");
						rewardtext:EnableHitTest(0);
					end
		
					local rewardcnt = GET_CHILD(ctrlSet, "rewardcnt");
					rewardcnt:SetTextByKey('value', EVENT_NEW_SEASON_SERVER_STAMP_TOUR_CLEAR_COIN_COUNT);
		
					local checkbox = GET_CHILD(ctrlSet, "checkbox");
					local completion = GET_CHILD(ctrlSet, "completion");
	
					if clear == 'true' then
						completion:ShowWindow(1);
						completion:SetAlpha(90);
					else
						completion:ShowWindow(0);
					end
					y = y + ctrlSet:GetHeight();					
				end				
			end
		end
	end

	return y;
end

function STAMP_TOUR_NPC_POS_BTN_CLICK(frame, msg, argStr, argNum)
	local context = ui.CreateContextMenu("npc_pos", "", 0, 0, 120, 120);
    
    scpScp = string.format("EVENT_STAMP_TOUR_NPC_POS_MINIMAP(\"%s\")", "Klapeda");    
	ui.AddContextMenuItem(context, ClMsg("Klapeda"), scpScp);
	
    scpScp = string.format("EVENT_STAMP_TOUR_NPC_POS_MINIMAP(\"%s\")", "c_orsha");    
    ui.AddContextMenuItem(context, ClMsg("c_orsha"), scpScp);

    ui.OpenContextMenu(context);
end

function EVENT_STAMP_TOUR_NPC_POS_MINIMAP(mapname)
	
	if mapname == "Klapeda" then
		SCR_SHOW_LOCAL_MAP("c_Klaipe", true, -292, 291)
	elseif mapname == "c_orsha" then
		SCR_SHOW_LOCAL_MAP("c_orsha", true, -985, 415)
	end
end

------------------------- 콘텐츠 -------------------------
function CONTENTS_MISSION_STATE_OPEN(frame)
	local nametext = GET_CHILD_RECURSIVELY(frame, "nametext", "richtext");
	nametext:SetTextByKey('value', frame:GetUserConfig("CONTENTS_MISSION_TITLE"));

	local listgb = GET_CHILD(frame, "listgb");
	listgb:RemoveAllChild();
	
	local notebtn = GET_CHILD_RECURSIVELY(frame, "notebtn");
	notebtn:ShowWindow(0);

	local tiptext = GET_CHILD(frame, "tiptext");
	tiptext:ShowWindow(0);

	local y = 0;
	y = CREATE_MISSION_STATE_LIST(y, listgb, false);
end

function CREATE_MISSION_STATE_LIST(starty, listgb, isClear)
	local accObj = GetMyAccountObj();
	if accObj == nil then return; end

	local y = starty;
	local clsList, clscnt  = GetClassList("event_new_season_server_content_clear_coin_reward");
	for i = 0, clscnt - 1 do
		local missionCls = GetClassByIndexFromList(clsList, i);
			
		local ctrlSet = listgb:CreateControlSet('check_to_do_list_season', "CTRLSET_" ..i,  ui.CENTER_HORZ, ui.TOP, -10, y, 0, 0);
		local rewardtext = GET_CHILD(ctrlSet, "rewardtext");
		rewardtext:SetTextByKey('value', missionCls.ContentsName);

		local rewardcnt = GET_CHILD(ctrlSet, "rewardcnt");
		rewardcnt:SetTextByKey('value', missionCls.FirstCoin);

		local completion = GET_CHILD(ctrlSet, "completion");
		completion:ShowWindow(0);
		
		y = y + ctrlSet:GetHeight();
	end

	return y;
end
