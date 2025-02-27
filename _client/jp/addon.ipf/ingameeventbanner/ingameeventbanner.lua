﻿-- ingameeventbanner.lua
local json = require "json_imc"

function INGAMEEVENTBANNER_ON_INIT(addon, frame)
--	addon:RegisterMsg("MSG_UPDATE_EVENTBANNER_UI", "EVENTBANNER_FRAME_OPEN");
	addon:RegisterMsg("DO_OPEN_EVENTBANNER_UI", "EVENTBANNER_FRAME_OPEN");
	addon:RegisterMsg("EVENTBANNER_SOLODUNGEON", "ON_EVENTBANNER_SOLODUNGEON");
	-- addon:RegisterMsg("EVENTBANNER_TEAMBATTLE", "ON_EVENTBANNER_TEAMBATTLE");
	-- addon:RegisterMsg('WORLDPVP_RANK_PAGE', 'ON_EVENTBANNER_TEAMBATTLE');    
	addon:RegisterMsg('EVENTBANNER_USERTYPE', 'ON_EVENTBANNER_USERTYPE');    
end

function EVENTBANNER_FRAME_OPEN(frame)
	ui.OpenFrame("ingameeventbanner")
	UPDATE_EVENTBANNER_UI(frame)
	UPDATE_EVENTBANNER_RANKINGS(frame)	
	
	--solodungeon & usertype
	control.CustomCommand("REQ_EVENTBANNER_INFO", 0);
	
	--teambattle
	local pvpCls = GET_TEAM_BATTLE_CLASS();
	worldPVP.RequestPVPRanking(pvpCls.ClassID, 0, 0, 1, 0, "");
end

function EVENTBANNER_FRAME_CLOSE(frame)
	
end

function SHOW_REMAIN_BANNER_TIME(ctrl)
	local curIndex = ctrl:GetUserIValue("curIndex")
	local banner = GetClassByIndex('event_banner', curIndex)
	local remainEndTime = CHECK_EVENTBANNER_REMAIN_TIME(TryGetProp(banner, 'EndTimeYYYYMM', 'None'), TryGetProp(banner,'EndTimeDDHHMM', 'None'))
	local remainExchangeTime = CHECK_EVENTBANNER_REMAIN_TIME(TryGetProp(banner,'ExchangeTimeYYYYMM', 'None'), TryGetProp(banner,'ExchangeTimeDDHHMM', 'None'))
	
	local end_date_time = TryGetProp(banner, 'EndDateTime', 'None')	
	local end_ret_time = nil
	if end_date_time ~= 'None' then				
		local lua_time = date_time.get_lua_datetime_from_str(end_date_time)
		end_ret_time = os.date('*t', lua_time)
		
		local tail = (string.format('%02d%02d%02d', end_ret_time['day'], end_ret_time['hour'], end_ret_time['min']))
		remainEndTime = CHECK_EVENTBANNER_REMAIN_TIME(string.format('%04d%02d', end_ret_time['year'], end_ret_time['month']), tail)
		remainExchangeTime = CHECK_EVENTBANNER_REMAIN_TIME(string.format('%04d%02d', end_ret_time['year'], end_ret_time['month']), tail)
	end

	local flag = 0;
	if remainEndTime == nil or 0 > remainEndTime then
		
		if remainExchangeTime == nil or 0 > remainExchangeTime then
			ctrl:SetTextByKey("remainTime", ScpArgMsg("ThisIsEndedEvent"));
			ctrl:SetFontName("red_18");
			ctrl: StopUpdateScript("SHOW_REMAIN_BANNER_TIME");
	
			return 0;
		end
		flag = 1
	end

	local timeTxt = '';	
	if flag == 0 then
		timeTxt = GET_TIME_TXT_DHM(remainEndTime);
	elseif flag == 1 then
		timeTxt = GET_TIME_TXT_DHM(remainExchangeTime);
	end

	ctrl:SetTextByKey("remainTime", timeTxt);

	return 1;
end

function ON_EVENTBANNER_DETAIL_BTN_SOLODUNGEON(ctrlset, btn)
	control.CustomCommand("REQ_SOLO_DUNGEON_RANK", 0);
end

function ON_EVENTBANNER_DETAIL_BTN_TEAMBATTLE(ctrlset, btn)
	local advFrame = ui.GetFrame("adventure_book")
	local mainTab = GET_CHILD(advFrame, "mainTab")
	local mainIndex = mainTab:GetIndexByName("tab_main_adventure")
	
	local gb_adventure = GET_CHILD(advFrame, "gb_adventure")
	local rankingTab = GET_CHILD(gb_adventure, "rankingTab")
	local subIndex = rankingTab:GetIndexByName("teamBattleRankingTab")

	mainTab:SelectTab(mainIndex)
	rankingTab:SelectTab(subIndex)
	
	advFrame:ShowWindow(1)
end

function ON_EVENTBANNER_DETAIL_BTN_GEARSCORE_RANKING(ctrlset, btn)
	ui.OpenFrame("gear_score_ranking")
end

function ON_EVENTBANNER_SOLODUNGEON(frame)
	local ranking_solo_dungeon = GET_CHILD_RECURSIVELY(frame, "ranking_solo_dungeon");
	local indunName = TryGetProp(GetClass("Indun", "Solo_dungeon"), "Name");
	local detail_btn = GET_CHILD(ranking_solo_dungeon, "detail_btn");
	detail_btn:SetEventScript(ui.LBUTTONUP, "ON_EVENTBANNER_DETAIL_BTN_SOLODUNGEON");
	detail_btn:ShowWindow(1);
	UPDATE_EVENTBANNER_RANKING(ranking_solo_dungeon, indunName, "UPDATE_EVENTBANNER_RANKING_SOLODUNGEON")
end

function ON_EVENTBANNER_TEAMBATTLE(frame, msg, strarg, numarg)
	local ranking_team_battle = GET_CHILD_RECURSIVELY(frame, "ranking_team_battle");
	local name = ClMsg("TeamBattleLeagueText");
	local detail_btn = GET_CHILD(ranking_team_battle, "detail_btn");
	detail_btn:SetEventScript(ui.LBUTTONUP, "ON_EVENTBANNER_DETAIL_BTN_TEAMBATTLE");
	detail_btn:ShowWindow(1);
	UPDATE_EVENTBANNER_RANKING(ranking_team_battle, name, "UPDATE_EVENTBANNER_RANKING_TEAMBATTLE")
end

function ON_EVENTBANNER_GEARSCORE(code, ret_json)
	local frame = ui.GetFrame("ingameeventbanner")
	local ranking_gear_score = GET_CHILD_RECURSIVELY(frame, "ranking_gear_score");
	local name = ClMsg("EquipedItemGearScore");
	local detail_btn = GET_CHILD(ranking_gear_score, "detail_btn");
	detail_btn:SetEventScript(ui.LBUTTONUP, "ON_EVENTBANNER_DETAIL_BTN_GEARSCORE_RANKING");
	detail_btn:ShowWindow(1);

	local title_text = GET_CHILD_RECURSIVELY(ranking_gear_score, "title_text");
	title_text:SetTextByKey("value", name);
	
	local rankcount = 0;
	local x = tonumber(ranking_gear_score:GetUserConfig("OffsetX"));
	local y = tonumber(ranking_gear_score:GetUserConfig("OffsetY"));
	local eachHeight = ui.GetControlSetAttribute("gearscore_ranking_each_rank", "height");
	local list_bg = GET_CHILD_RECURSIVELY(ranking_gear_score, "list_bg");

	if IS_SEASON_SERVER() == "YES" then
		local detail_btn = GET_CHILD(ranking_gear_score, "detail_btn");
		detail_btn:ShowWindow(0);
		local listbg = GET_CHILD(ranking_gear_score, "list_bg");
		listbg:RemoveAllChild();
		local text = listbg:CreateControl('richtext', 'text', 0, 0, 0, 0);	
		text:SetText("");
		return
	end

	if code == 200 then
		local dic = json.decode(ret_json)
		local rankList = dic["list"]

		for i = 1, 3 do 
			local eachctrl = list_bg:CreateOrGetControlSet("gearscore_ranking_each_rank", "gearscore_ranking_each_rank_"..i, x, y+(i-1)*eachHeight);
			AUTO_CAST(eachctrl);
			local picName = eachctrl:GetUserConfig("RankingPic_"..i);
			local skinName = eachctrl:GetUserConfig("RankingSkin_"..i);
			local bg = GET_CHILD_RECURSIVELY(eachctrl, "bg");
			bg:SetSkinName(skinName);
			local ranking_pic = GET_CHILD_RECURSIVELY(eachctrl, "ranking_pic");
			ranking_pic:SetImage(picName);

			local func = _G["UPDATE_EVENTBANNER_RANKING_GEARSCORE"];
			local result = func(eachctrl, name, rankList[i]);
			if result == true then
				rankcount = rankcount + 1;
			end
		end
	end

	if rankcount == 0 then
		local sysTime = geTime.GetServerSystemTime();
		if code ~= 200 then
			local detail_btn = GET_CHILD(ranking_gear_score, "detail_btn");
			detail_btn:ShowWindow(0);

			local listbg = GET_CHILD(ranking_gear_score, "list_bg");
			listbg:RemoveAllChild();
	
			local topFrame = ranking_gear_score:GetTopParentFrame();
			local RANK_GUID_FONT_NAME = topFrame:GetUserConfig('RANK_GUID_FONT_NAME');		
			
			local text = listbg:CreateControl('richtext', 'text', 0, 0, 0, 0);	
			text:SetGravity(ui.CENTER_HORZ, ui.CENTER_VERT);
			text:SetFontName(RANK_GUID_FONT_NAME);
			text:SetText(ClMsg("news_ranking_guide_msg"));
		end
	end
end

function UPDATE_EVENTBANNER_RANKING_SOLODUNGEON(eachctrl, name, i)
	local noranker_text = GET_CHILD_RECURSIVELY(eachctrl, "noranker_text");
	local name_text = GET_CHILD_RECURSIVELY(eachctrl, "name_text");
	local score_text = GET_CHILD_RECURSIVELY(eachctrl, "score_text");
	local job_pic = GET_CHILD_RECURSIVELY(eachctrl, "job_pic");
	
	local scoreInfo = session.soloDungeon.GetRankingByIndex(soloDungeonShared.ThisWeek, 0, i-1);
	if scoreInfo == nil then
		noranker_text:SetVisible(1);
		name_text:SetVisible(0);
		job_pic:SetVisible(0);
		score_text:SetTextByKey("value", "-");
		return false;
	end
	
	noranker_text:SetVisible(0);
	name_text:SetVisible(1);
	job_pic:SetVisible(1);

	local jobIcon = TryGetProp(GetClassByType("Job", scoreInfo:GetJobHistoryByIndex(scoreInfo:GetJobHistoryCount()-1)), "Icon");
	job_pic:SetImage(jobIcon);
	name_text:SetTextByKey("lv", scoreInfo.level);
	name_text:SetTextByKey("name", scoreInfo.familyName);
	score_text:SetTextByKey("value", scoreInfo.stage);

	return true;
end

function UPDATE_EVENTBANNER_RANKING_GEARSCORE(eachctrl, name, info)
	local noranker_text = GET_CHILD_RECURSIVELY(eachctrl, "noranker_text");
	local job_pic = GET_CHILD_RECURSIVELY(eachctrl, "job_pic");
	local name_text = GET_CHILD_RECURSIVELY(eachctrl, "name_text");
	local score_text = GET_CHILD_RECURSIVELY(eachctrl, "score_text");

	noranker_text:SetVisible(1);
	name_text:SetVisible(0);
	job_pic:SetVisible(0);
	score_text:SetTextByKey("value", "-");
	
	noranker_text:SetVisible(0);
	name_text:SetVisible(1);

	name_text:SetTextByKey("team", info["team_name"]);
	name_text:SetTextByKey("char", info["char_name"]);
	score_text:SetTextByKey("value", info["value"]);
	return true;
end

function UPDATE_EVENTBANNER_RANKING(ctrlset, name, set_func)
	local title_text = GET_CHILD_RECURSIVELY(ctrlset, "title_text");
	title_text:SetTextByKey("value", name);
	
	local rankcount = 0;
	local x = tonumber(ctrlset:GetUserConfig("OffsetX"));
	local y = tonumber(ctrlset:GetUserConfig("OffsetY"));
	local eachHeight = ui.GetControlSetAttribute("news_ranking_each_rank", "height");
	local list_bg = GET_CHILD_RECURSIVELY(ctrlset, "list_bg");
	for i = 1, 3 do 
		local eachctrl = list_bg:CreateOrGetControlSet("news_ranking_each_rank", "news_ranking_each_rank_"..i, x, y+(i-1)*eachHeight);
		AUTO_CAST(eachctrl);
		local picName = eachctrl:GetUserConfig("RankingPic_"..i);
		local skinName = eachctrl:GetUserConfig("RankingSkin_"..i);
		local bg = GET_CHILD_RECURSIVELY(eachctrl, "bg");
		bg:SetSkinName(skinName);
		local ranking_pic = GET_CHILD_RECURSIVELY(eachctrl, "ranking_pic");
		ranking_pic:SetImage(picName);
		
		local func = _G[set_func];
		local result = func(eachctrl, name, i);
		if result == true then
			rankcount = rankcount + 1;
		end
	end

	if rankcount == 0 then
		local sysTime = geTime.GetServerSystemTime();
		if sysTime.wDayOfWeek == 1 or sysTime.wDayOfWeek == 2 then
			-- 월요일이거나 화요일이고 랭킹 정보가 하나도 없을 때 안내 문구 출력
			local detail_btn = GET_CHILD(ctrlset, "detail_btn");
			detail_btn:ShowWindow(0);

			local listbg = GET_CHILD(ctrlset, "list_bg");
			listbg:RemoveAllChild();
	
			local topFrame = ctrlset:GetTopParentFrame();
			local RANK_GUID_FONT_NAME = topFrame:GetUserConfig('RANK_GUID_FONT_NAME');		
			
			local text = listbg:CreateControl('richtext', 'text', 0, 0, 0, 0);	
			text:SetGravity(ui.CENTER_HORZ, ui.CENTER_VERT);
			text:SetFontName(RANK_GUID_FONT_NAME);
			text:SetText(ClMsg("news_ranking_guide_msg"));
		end
	end

end

function UPDATE_EVENTBANNER_RANKINGS(frame)
	ON_EVENTBANNER_SOLODUNGEON(frame);
	-- ON_EVENTBANNER_TEAMBATTLE(frame);
	GetStatusRanking('ON_EVENTBANNER_GEARSCORE', 'pc_gear_score', 0)
end

function UPDATE_EVENTBANNER_UI(frame)
	if frame == nil then
		frame = ui.GetFrame('ingameeventbanner');
	end	

	local bannerBox = GET_CHILD_RECURSIVELY(frame, 'bannerGbox');
	bannerBox = tolua.cast(bannerBox, "ui::CGroupBox");
	DESTROY_CHILD_BYNAME(bannerBox, "event_banner_");

	local eventUserBannerHeight = 0
	-- 최상단에 신규/복귀 유저 배너
	local eventUserType = frame:GetUserValue('EVENT_USER_TYPE');	
	if eventUserType ~= nil and eventUserType ~= 0 and config.GetServiceNation() ~= 'PAPAYA' then
		-- event banner 만들기.
		local name = "event_banner_user"
		eventUserBannerHeight = EVENTBANNER_MAKE_USERTYPE(bannerBox, eventUserType, frame:GetUserValue('EVENT_USER_END_TIMESTAMP') )
	end

	-- 일반 배너.
	local bannerCtrlIndex = 0
	local bannerList, bannerCnt = GetClassList("event_banner")
	local bannerUserCommandIndex = 0

	for i = 0, bannerCnt - 1 do
		local banner = GetClassByIndex('event_banner', i)
		local banner_nation = TryGetProp(banner, 'Nation', 'None')
		if banner_nation == 'None' or banner_nation == config.GetServiceNation() then
			local showtype = TryGetProp(banner, "ShowType", "None");
			if GET_ENABLE_SHOW_BANNER(showtype) == true then
				local bannerCtrl = bannerBox:CreateOrGetControlSet('ingame_event_banner', 'event_banner_' .. bannerCtrlIndex, 0, eventUserBannerHeight + (185 * bannerCtrlIndex + bannerUserCommandIndex * 30));
				bannerCtrl:SetUserValue("bannerIndex", i)

				local bannerImage = GET_CHILD_RECURSIVELY(bannerCtrl, 'banner');
				bannerImage = tolua.cast(bannerImage, "ui::CPicture");
				bannerImage:SetImage(banner.ImagePath)
				bannerImage:SetTextTooltip(banner.Name)
				
				local time_limited_bg = GET_CHILD_RECURSIVELY(bannerCtrl, "time_limited_bg");
				local time_limited_text = GET_CHILD_RECURSIVELY(bannerCtrl, "time_limited_text");
				time_limited_text:SetUserValue("curIndex", i)
				time_limited_text:RunUpdateScript("SHOW_REMAIN_BANNER_TIME");
				
				local new_ribbon = GET_CHILD_RECURSIVELY(bannerCtrl, "new_ribbon");
				local deadline_ribbon = GET_CHILD_RECURSIVELY(bannerCtrl, "deadline_ribbon");
				local exchange_ribbon = GET_CHILD_RECURSIVELY(bannerCtrl, "exchange_ribbon");
				new_ribbon:SetVisible(0);
				deadline_ribbon:SetVisible(0);
				exchange_ribbon:SetVisible(0);
		
				local bannerFlag = 0
				--endTime 이 있어야 exchange 부르고, endtime 있는데 exchange없으면 endtime 만 지나도 안보이게하고
				
				local use_start_date_time = false

				local remainStartTime = CHECK_EVENTBANNER_REMAIN_TIME(TryGetProp(banner, 'StartTimeYYYYMM', 'None'), TryGetProp(banner, 'StartTimeDDHHMM', 'None'))				
				local start_date_time = TryGetProp(banner, 'StartDateTime', 'None')
				local end_date_time = TryGetProp(banner, 'EndDateTime', 'None')
				
				local start_ret_time = nil
				local end_ret_time = nil
				if start_date_time ~= 'None' and end_date_time ~= 'None' then
					use_start_date_time = true
					local lua_time = date_time.get_lua_datetime_from_str(start_date_time)
					start_ret_time = os.date('*t', lua_time)
					lua_time = date_time.get_lua_datetime_from_str(end_date_time)
					end_ret_time = os.date('*t', lua_time)
					
					local tail = (string.format('%02d%02d%02d', start_ret_time['day'], start_ret_time['hour'], start_ret_time['min']))
					remainStartTime = CHECK_EVENTBANNER_REMAIN_TIME(string.format('%04d%02d', start_ret_time['year'], start_ret_time['month']), tail)					
				end
				
				--남은 날짜 삭제 기능
				if TryGetProp(banner, 'UserCommand1', 'None')  == "time_del" then
					time_limited_bg:SetVisible(0);
					time_limited_text:SetVisible(0);
				end
				
				if remainStartTime ~= nil and remainStartTime < 0 then
					local remainNewTime = nil
					local remainDeadlineTime = nil
					local remainEndTime = nil
					local remainExchangeTime = nil

					if use_start_date_time == false then
						remainNewTime = CHECK_EVENTBANNER_REMAIN_TIME(TryGetProp(banner,'NewTimeYYYYMM', 'None'), TryGetProp(banner, 'NewTimeDDHHMM', 'None'))
						remainDeadlineTime = CHECK_EVENTBANNER_REMAIN_TIME(TryGetProp(banner, 'DeadlineTimeYYYYMM', 'None'), TryGetProp(banner, 'DeadlineTimeDDHHMM', 'None'))
						remainEndTime = CHECK_EVENTBANNER_REMAIN_TIME(TryGetProp(banner, 'EndTimeYYYYMM', 'None'), TryGetProp(banner, 'EndTimeDDHHMM', 'None'))
						remainExchangeTime = CHECK_EVENTBANNER_REMAIN_TIME(TryGetProp(banner,'ExchangeTimeYYYYMM', 'None'), TryGetProp(banner, 'ExchangeTimeDDHHMM', 'None'))
					else
						remainNewTime = CHECK_EVENTBANNER_REMAIN_TIME(string.format('%04d%02d', start_ret_time['year'], start_ret_time['month']), 
						string.format('%02d%02d%02d', start_ret_time['day'], start_ret_time['hour'], start_ret_time['min']))
						remainDeadlineTime = CHECK_EVENTBANNER_REMAIN_TIME(string.format('%04d%02d', end_ret_time['year'], end_ret_time['month']), 
						string.format('%02d%02d%02d', end_ret_time['day'], end_ret_time['hour'], end_ret_time['min']))
						remainEndTime = CHECK_EVENTBANNER_REMAIN_TIME(string.format('%04d%02d', end_ret_time['year'], end_ret_time['month']), 
						string.format('%02d%02d%02d', end_ret_time['day'], end_ret_time['hour'], end_ret_time['min']))
						remainExchangeTime = CHECK_EVENTBANNER_REMAIN_TIME(0, 0)
					end
		
					if remainNewTime ~= nil and remainNewTime >= 0 then
						new_ribbon : SetVisible(1);
					else
						new_ribbon : SetVisible(0);
					end
		
					if remainDeadlineTime ~= nil and remainDeadlineTime <= 0 then
						deadline_ribbon : SetVisible(1);
					else
						deadline_ribbon : SetVisible(0);
					end
					if remainEndTime ~= nil and remainEndTime >= 0 then
						bannerCtrl:ShowWindow(1)
						--endtime ribbon, timer 넣자
						bannerCtrlIndex = bannerCtrlIndex + 1
						bannerFlag = 1
					elseif remainEndTime ~= nil and remainEndTime < 0 then
						if remainExchangeTime ~= nil and remainExchangeTime >= 0 then
							bannerCtrl:ShowWindow(1)
							--exchangetime ribbon 넣자
							exchange_ribbon : SetVisible(1);
							bannerCtrlIndex = bannerCtrlIndex + 1
							bannerFlag = 1
						else
							bannerCtrl:ShowWindow(0)
							bannerBox: RemoveChild('event_banner_' ..bannerCtrlIndex)
						end
					else
						bannerCtrl:ShowWindow(0)
						bannerBox: RemoveChild('event_banner_' ..bannerCtrlIndex)
					end
				else
					bannerCtrl:ShowWindow(0)
					bannerBox: RemoveChild('event_banner_' ..bannerCtrlIndex)
				end

				local userCommandFlag = 0
				if bannerFlag == 1 then
					local imgList = {'notice_red_btn','notice_blue_btn','notice_green_btn','notice_yellow_btn','notice_purple_btn'}
					for i2 = 1, 3 do
						if GetPropType(banner,'UserCommand'..i2) ~= nil and  banner['UserCommand'..i2] == 'YES' then
							bannerUserCommandIndex = bannerUserCommandIndex + 1
							userCommandFlag = 1
							break
						end
					end
					if userCommandFlag == 1 then
						for i2 = 1, 3 do
							if GetPropType(banner,'UserCommand'..i2) ~= nil and banner['UserCommand'..i2] == 'YES' then
								local imgBtn = bannerBox:CreateControl('button', 'userCommand_'..bannerCtrlIndex..'_'..i2, 10 + 30*(i2-1), 180 * bannerCtrlIndex + (bannerUserCommandIndex-1) * 30 + 5, 30, 30)
								tolua.cast(imgBtn, 'ui::CButton');
								imgBtn:SetImage(imgList[i2])

								-- imgBtn:SetSkinName(imgList[i2])
								-- imgBtn:SetSkinName("test_gray_button");
								-- local curquest = session.GetUserConfig("CUR_QUEST", 0);
								-- local StrScript = string.format("EXEC_ABANDON_QUEST(%d)", curquest);

								imgBtn:SetEventScript(ui.LBUTTONUP, string.format("EVENT_BANNER_USERCOMMAND_BTN(%d)", banner.ClassID + i2), true);
								imgBtn:SetOverSound('button_over');
								imgBtn:SetClickSound('button_click_big');
							end
						end 
					end
				end
			end		
		end
	end
end

function EVENT_BANNER_USERCOMMAND_BTN(bannerClassID)
    control.CustomCommand("EVENT_BANNER_USERCOMMAND", bannerClassID)
end

function CLICKED_EVENTBANNER(parent, ctrl)
	local bannerIndex = parent:GetUserIValue("bannerIndex")			
	local banner = GetClassByIndex('event_banner', bannerIndex)

	if banner.url == "None" or banner.url == "" then
		return;
	end
	
	login.OpenURL(banner.url);
end

function CHECK_EVENTBANNER_REMAIN_TIME(timeYYYYMM, timeDDHHMM)

	if timeYYYYMM == nil or timeDDHHMM == nil then
		return nil;
	end

	if timeYYYYMM == "None" or timeDDHHMM == "None" then
		return nil;
	end

	if timeYYYYMM == 0 or timeDDHHMM == 0 then		
		return nil;
	end

	local targetTimeYYYYMM = tonumber(timeYYYYMM);
	local targetTimeDDHHMM = tonumber(timeDDHHMM);
	local targetTimeStr = string.format("%06d%01d%06d%02d", targetTimeYYYYMM, 0 , targetTimeDDHHMM, 00)
	local curTime = geTime.GetServerSystemTime();
--	local curTimeYYYYMM = tonumber(string.format("%04d%02d", curTime.wYear, curTime.wMonth))
--	local curTimeDDHHMM = tonumber(string.format("%02d%02d%02d", curTime.wDay, curTime.wHour, curTime.wMinute))
--	print('CCCCCC',curTimeYYYYMM,curTimeDDHHMM)
    
    local now_time = os.date('*t')
    local year = now_time['year']
    local month = now_time['month']
    local day = now_time['day']
    local hour = now_time['hour']
    local min = now_time['min']
    local sec = now_time['sec']
--	local curTimeStr = string.format("%04d%02d%01d%02d%02d%02d%02d", curTime.wYear, curTime.wMonth, '0', curTime.wDay, curTime.wHour, curTime.wMinute, curTime.wSecond)
    local curTimeStr = string.format("%04d%02d%01d%02d%02d%02d%02d", year, month, '0', day, hour, min, sec)

	-- target time 에 startTime 를 넣으면 difSec(남은시간)이 음수, endTime, exchangeTime 을 넣으면 difSec 가 양수일것이다
	local targetSysTime = imcTime.GetSysTimeByStr(targetTimeStr)
	local curSysTime = imcTime.GetSysTimeByStr(curTimeStr)
	
	local difSec = imcTime.GetDifSec(targetSysTime, curSysTime);

	return difSec;
	
end


function TEST_OPEN_URLLL(parent, ctrl)
	local slot = tolua.cast(ctrl, 'ui::CSlot');
	local clickedIndex = slot:GetSlotIndex() + 1
	local clickedEventBanner = GetClassByIndex('event_banner', clickedIndex)

	login.OpenURL(clickedEventBanner.url);
end

function SCP_LBTDOWN_EVENTBANNER(frame, ctrl)
	
	ui.EnableSlotMultiSelect(1);

end

function EXECUTE_EVENTBANNER(frame)

	session.ResetItemList();

	local totalprice = 0;

	local slotSet = GET_CHILD_RECURSIVELY(frame, "slotlist", "ui::CSlotSet")
	
	if slotSet:GetSelectedSlotCount() < 1 then
		ui.MsgBox(ScpArgMsg("SelectSomeItemPlz"))
		return;
	end

	for i = 0, slotSet:GetSelectedSlotCount() -1 do
		local slot = slotSet:GetSelectedSlot(i)
		local Icon = slot:GetIcon();
		local iconInfo = Icon:GetInfo();
		
		local  cnt = slot:GetSelectCount();
		session.AddItemID(iconInfo:GetIESID(), cnt );
	end

	local msg = ScpArgMsg('AreYouSerious')
	ui.MsgBox(msg, 'EXECUTE_EVENTBANNER_COMMIT', "None");
end

function EXECUTE_EVENTBANNER_COMMIT()

	local resultlist = session.GetItemIDList();

	item.DialogTransaction("EVENTBANNER", resultlist);
end

function SET_EVENTBANNER_CARD_COMMIT(slotname, type)

	local resultlist = session.GetItemIDList();

	local iType = 1;
	if "UnEquip" == type then
		iType = 0;
	end

	local argStr = string.format("%s %s", slotname, iType);
--	item.DialogTransaction("SET_POISON_CARD", resultlist, argStr); 

end

function EVENTBANNER_HUD_CONFIG_CHANGE(frame)
    EVENTBANNER_HUD_CHECK_VISIBLE();
end

function EVENTBANNER_CHECK_OPEN(propname, propvalue)

end

function ON_EVENTBANNER_USERTYPE(frame, msg, strarg, numarg)
	frame = ui.GetFrame("ingameeventbanner")
	frame:SetUserValue("EVENT_USER_TYPE",numarg)
	frame:SetUserValue("EVENT_USER_END_TIMESTAMP",strarg)
	UPDATE_EVENTBANNER_UI(frame)
end

function CLICKED_EVENTBANNER_USER(parent, ctrl)
	control.CustomCommand("REQ_EVENTBANNER_USERTYPE_CLICK", 0);
end

function EVENTBANNER_MAKE_USERTYPE(bgCtrl, userType, eventEndTimeStampStr)
	if userType == nil or eventEndTimeStampStr == nil or eventEndTimeStampStr == 'None' then
		return 0
	end

	local bannerBox = tolua.cast(bgCtrl, "ui::CGroupBox"); 
	local ctrlName = "event_banner_user"
	local bannerCtrl = bannerBox:CreateOrGetControlSet('ingame_event_banner', ctrlName, 0, 0); -- 최상단.
	
	-- 이미지 설정
	local bannerImage = GET_CHILD_RECURSIVELY(bannerCtrl, 'banner');
	bannerImage = tolua.cast(bannerImage, "ui::CPicture");
	bannerImage:SetImage("news_event_banner")
	bannerImage:SetTextTooltip(""); -- 툴팁 제거
	---- 클릭 이벤트 변경
	bannerImage:SetEventScript(ui.LBUTTONUP, 'CLICKED_EVENTBANNER_USER');

	-- 종료시간 설정
	local time_limited_bg = GET_CHILD_RECURSIVELY(bannerCtrl, "time_limited_bg");
	local time_limited_text = GET_CHILD_RECURSIVELY(bannerCtrl, "time_limited_text");
	time_limited_bg:SetVisible(1);   -- 검은색 그라데이션 배경
	time_limited_text:SetVisible(1); -- 일시분 텍스트

	local endTimeStamp = tonumber(eventEndTimeStampStr)
	local elapsedSeconds = endTimeStamp - os.time(os.date('*t'));
	local remainTimeText = GET_TIMESTAMP_TO_COUNTDOWN_DATESTR(elapsedSeconds, {noSec = true});
	time_limited_text:SetTextByKey('remainTime', remainTimeText)

	-- 기타 컨트롤 설정
	local new_ribbon = GET_CHILD_RECURSIVELY(bannerCtrl, "new_ribbon");
	local deadline_ribbon = GET_CHILD_RECURSIVELY(bannerCtrl, "deadline_ribbon");
	local exchange_ribbon = GET_CHILD_RECURSIVELY(bannerCtrl, "exchange_ribbon");

	new_ribbon:SetVisible(0);		-- 신규 표시
	deadline_ribbon:SetVisible(0);  -- 종료 임박 표시
	exchange_ribbon:SetVisible(0);  -- 교환 표시

	bannerCtrl:Invalidate()
	return bannerCtrl:GetHeight();
end

function GET_ENABLE_SHOW_BANNER(type)
	if type == "None" then
		return true;
	end

	if type == "Normal" and IS_SEASON_SERVER() == "NO" then
		return true;
	end

	if type == "Season" and IS_SEASON_SERVER() == "YES" then
		return true;
	end

	return false;
end