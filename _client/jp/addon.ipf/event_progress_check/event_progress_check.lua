function EVENT_PROGRESS_CHECK_ON_INIT(addon, frame)
	addon:RegisterMsg("EVENT_PROGRESS_CHECK_OPEN_COMMAND", "EVENT_PROGRESS_CHECK_OPEN_COMMAND");
	addon:RegisterMsg("EVENT_PROGRESS_CHECK_DAILY_PLAY_TIME_UPDATE", "EVENT_PROGRESS_CHECK_DAILY_PLAY_TIME_UPDATE");

	addon:RegisterMsg("EVENT_YOUR_MASTER_OPEN", "EVENT_YOUR_MASTER_OPEN");
end

function EVENT_PROGRESS_CHECK_OPEN_COMMAND(frame, msg, argStr, type)
	EVENT_PROGRESS_CHECK_OPEN(type);
end

local your_master_type = 4;
local event_5th_type = 6;
function EVENT_PROGRESS_CHECK_OPEN(type)
	local frame = ui.GetFrame("event_progress_check");

	if type == your_master_type then
		control.CustomCommand("REQ_EVENT_YOUR_MASTER_OPEN", 0);
		return;
	end

	EVENT_PROGRESS_CHECK_INIT(frame, type);
	EVENT_PROGRESS_CHECK_TAB_CLICK(frame, nil, "", type);

	frame:ShowWindow(1);
end

function EVENT_PROGRESS_CHECK_CLOSE(frame)
	frame:ShowWindow(0);
end

function EVENT_PROGRESS_CHECK_INIT(frame, type)
	local title = GET_CHILD_RECURSIVELY(frame, "title");
	title:SetTextByKey("value", ClMsg(GET_EVENT_PROGRESS_CHECK_TITLE(type)));

	local tab = GET_CHILD(frame, "tab");
	tab:SelectTab(0);
	tab:SetEventScript(ui.LBUTTONUP, "EVENT_PROGRESS_CHECK_TAB_CLICK");
	tab:SetEventScriptArgNumber(ui.LBUTTONUP, type);

	local tabtitlelist = GET_EVENT_PROGRESS_CHECK_TAB_TITLE(type);
	for i = 1, #tabtitlelist do
		tab:ChangeCaption(i - 1, "{@st66b}{s18}"..ClMsg(tabtitlelist[i]), false);
	end
	tab:SetItemsAdjustFontSizeByWidth(152);

	EVENT_PROGRESS_TAB_TOGGLE(frame, 1);

	local notebtn = GET_CHILD_RECURSIVELY(frame, "notebtn");
	notebtn:SetTextByKey("value", ClMsg(GET_EVENT_PROGRESS_CHECK_NOTE_NAME(type)));
	notebtn:SetEventScript(ui.LBUTTONUP, GET_EVENT_PROGRESS_CHECK_NOTE_BTN(type));

	local titlegb = GET_CHILD(frame, "titlegb");
	titlegb:SetSkinName(GET_EVENT_PROGRESS_CHECK_TITLE_SKIN(type));

	local title_deco = GET_CHILD(frame, "title_deco");
	title_deco:SetImage(GET_EVENT_PROGRESS_CHECK_TITLE_DECO(type));
	
	local loadingtext = GET_CHILD_RECURSIVELY(frame, "loadingtext");
    loadingtext:ShowWindow(0);
    
    frame:SetUserValue("TYPE", type)
end

function EVENT_PROGRESS_CHECK_TAB_CLICK(parent, ctrl, argStr, type)
	local frame = parent:GetTopParentFrame();
	local tab = GET_CHILD(frame, "tab");
	local index = tab:GetSelectItemIndex();

	local listgb = GET_CHILD(frame, "listgb");
    listgb:SetScrollPos(0);
	listgb:RemoveAllChild();
	
	local notebtn = GET_CHILD_RECURSIVELY(frame, "notebtn");
	notebtn:ShowWindow(0);
	notebtn:Resize(100, 36);

	local overtext = GET_CHILD(frame, "overtext");
	overtext:ShowWindow(0);

	local tiptext = GET_CHILD(frame, "tiptext");
	tiptext:ShowWindow(0);

	local comming_soon_pic = GET_CHILD_RECURSIVELY(frame, "comming_soon_pic");
	comming_soon_pic:ShowWindow(0);

	if index == 0 then
		EVENT_PROGRESS_CHECK_ACQUIRE_STATE_OPEN(frame, type);
	elseif index == 1 then
        EVENT_PROGRESS_CHECK_STAMP_TOUR_STATE_OPEN(frame, type);
    elseif index == 2 then
        EVENT_PROGRESS_CHECK_CONTENTS_STATE_OPEN(parent:GetTopParentFrame(), type);
	end
end

function EVENT_PROGRESS_TAB_TOGGLE(frame, toggle)
	local tab = GET_CHILD(frame, "tab");
	local tab2 = GET_CHILD(frame, "tab2");

	local listgb = GET_CHILD(frame, "listgb");
	local tab2_listgb1 = GET_CHILD(frame, "tab2_listgb1");
	local tab2_listgb2 = GET_CHILD(frame, "tab2_listgb2");
	local tab2_listgb3 = GET_CHILD(frame, "tab2_listgb3");

	tab:ShowWindow(toggle);
	tab2:ShowWindow(1-toggle);
	
	listgb:ShowWindow(toggle);
	tab2_listgb1:ShowWindow(1-toggle);
	tab2_listgb2:ShowWindow(1-toggle);
	tab2_listgb3:ShowWindow(1-toggle);
end

------------------------- 획득 현황 -------------------------
function EVENT_PROGRESS_CHECK_ACQUIRE_STATE_OPEN(frame, type)
	local desclist = GET_EVENT_PROGRESS_CHECK_DESC(type);
	local nametext = GET_CHILD_RECURSIVELY(frame, "nametext");
	nametext:SetTextByKey('value', ClMsg(desclist[1]));

	local tiptext = GET_CHILD(frame, "tiptext");
	local tiptextlist = GET_EVENT_PROGRESS_CHECK_TIP_TEXT(type);
	if tiptextlist[1] ~= "None" then
		tiptext:SetTextByKey("value", ClMsg(tiptextlist[1]));
		tiptext:ShowWindow(1);
	end

	local accObj = GetMyAccountObj();
	if accObj == nil then return; end

	local listgb = GET_CHILD(frame, "listgb");
	local curlist = GET_EVENT_PROGRESS_CHECK_CUR_VALUE(type, accObj);
	local eventstatelist = GET_EVENT_PROGRESS_CHECK_EVENT_STATE(type);
	local iconlist = GET_EVENT_PROGRESS_CHECK_ACQUIRE_STATE_ICON(type);    
	local textlist = GET_EVENT_PROGRESS_CHECK_ACQUIRE_STATE_TEXT(type);
	local tooltiplist = GET_EVENT_PROGRESS_CHECK_ACQUIRE_STATE_TOOLTIP(type);
	local maxlist = GET_EVENT_PROGRESS_CHECK_ACQUIRE_STATE_MAX_VALUE(type, accObj);
	local npclist = GET_EVENT_PROGRESS_CHECK_ACQUIRE_STATE_NPC(type);
    local clearlist = GET_EVENT_PROGRESS_CHECK_ACQUIRE_STATE_CLEAR_TEXT(type);

	local y = 0;
	local listCnt = GET_EVENT_PROGRESS_CHECK_LIST_COUNT(type);
    for i = 1, listCnt do
		local ctrlSet = listgb:CreateControlSet('icon_with_current_state', "CTRLSET_" .. i,  ui.LEFT, ui.TOP, 0, y, 0, 0);
		if 5 < listCnt then
			ctrlSet:Resize(500, 99);
		end

		local iconpic = GET_CHILD(ctrlSet, "iconpic");
		iconpic:SetImage(iconlist[i]);

		local clear_text = GET_CHILD(ctrlSet, "clear_text");
		
		local npc_pos_btn = GET_CHILD(ctrlSet, "btn");
		if npclist[i] ~= "None" and npclist[i] ~= nil then
			npc_pos_btn:ShowWindow(1);
			npc_pos_btn:SetEventScript(ui.LBUTTONUP, "EVENT_PROGRESS_NPC_POS_BTN_CLICK");
			npc_pos_btn:SetEventScriptArgString(ui.LBUTTONUP, npclist[i]);
			npc_pos_btn:SetTextTooltip(ClMsg("EVENT_2007_FLEX_BOX_CHECK_TOOLTIP_6"));
		else
			npc_pos_btn:ShowWindow(0);	
		end

		local blackbg = GET_CHILD(ctrlSet, "blackbg");
		blackbg:ShowWindow(0);

		local text = GET_CHILD(ctrlSet, "text");
		text:SetTextByKey('value', textlist[i]);

		local gb = GET_CHILD(ctrlSet, "gb");
		if tooltiplist[i] ~= "None" then
			gb:SetTextTooltip(tooltiplist[i]);
		end

		local comming_soon_pic = GET_CHILD(ctrlSet, "comming_soon_pic");
		comming_soon_pic:ShowWindow(0);
		local state = GET_CHILD(ctrlSet, "state");
		
		local curvalue = 0;
		local maxvalue = 0;
		
		local curStrlist = StringSplit(curlist[i], "/");
		if 1 < #curStrlist then
			curvalue = curStrlist[1];
			maxvalue = curStrlist[2];
		else
			curvalue = curlist[i];
			maxvalue = maxlist[i];
		end

		if #curStrlist == 1 and maxvalue <= curvalue and maxvalue ~= 0 then
			blackbg:ShowWindow(1);
			blackbg:SetAlpha(90);

			if clearlist[i] ~= "None" then
				clear_text:SetTextByKey("value", ClMsg(clearlist[i]));
			end
		end

		if eventstatelist[i] == "pre" then
			blackbg:ShowWindow(1);
			blackbg:SetAlpha(90);

			comming_soon_pic:ShowWindow(1);
		elseif eventstatelist[i] == "end" then
			blackbg:ShowWindow(1);
			blackbg:SetAlpha(90);

			clear_text:SetTextByKey("value", ClMsg("EndEventMessage"));
		end
		
		if maxvalue ~= 0 and GET_EVENT_PROGRESS_DAILY_PLAY_TIME_INDEX(type) == i then
			local timetype = GET_EVENT_PROGRESS_DAILY_PLAY_TIME_TYPE(type);
			if timetype == "min" then
				maxvalue = ScpArgMsg("{Min}", "Min", maxvalue);	
			end
		end

		if type == event_5th_type then
			if i == 1 then
				curvalue = curvalue .." ".. ClMsg("POINT");
				maxvalue = maxvalue .." ".. ClMsg("Level");
			elseif i == 6 then
				curvalue = ScpArgMsg("{Min}", "Min", curvalue);
			end
		end
		
		state:SetTextByKey('cur', curvalue);
		state:SetTextByKey('max', " / "..maxvalue);
		if maxvalue == 0 then
			state:SetTextByKey('max', "");
        end

        -- -- EVENT_2009_FULLMOON
        -- if type == 5 then
        --     -- 단계
        --     if i == 1 then
        --         state:SetTextByKey('max', " "..ClMsg("Step"));
        --     end

        --     -- 포인트
        --     if i == 2 then
        --         state:SetTextByKey('max', " "..ClMsg("POINT"));
        --     end
        -- end

		y = y + ctrlSet:GetHeight();
    end
end

function EVENT_PROGRESS_CHECK_DAILY_PLAY_TIME_UPDATE(frame, msg, time)
	local frame = ui.GetFrame("event_progress_check");	
	if frame:IsVisible() == 0 then
		return;
	end

	local tab = GET_CHILD(frame, "tab");
	local index = tab:GetSelectItemIndex();
	if index ~= 0 then
		return;
	end

	local type = frame:GetUserIValue("TYPE");
	local ctrlIndex = GET_EVENT_PROGRESS_DAILY_PLAY_TIME_INDEX(type);
	local listgb = GET_CHILD(frame, "listgb");
	local ctrlSet = GET_CHILD_RECURSIVELY(listgb, "CTRLSET_"..ctrlIndex);
	if ctrlSet == nil then
		return;
	end
	
	local countType = GET_EVENT_PROGRESS_DAILY_PLAY_TIME_TYPE(type);
	local state = GET_CHILD(ctrlSet, "state");
	if countType == "min" then
		state:SetTextByKey("cur",ScpArgMsg("{Min}", "Min", time));
	else
		state:SetTextByKey("cur", time);
	end
	
    -- -- EVENT_2009_FULLMOON
    -- if frame:GetUserValue("TYPE") == 5 then
    --     return;
	-- end

	local accObj = GetMyAccountObj();
    local clearlist = GET_EVENT_PROGRESS_CHECK_ACQUIRE_STATE_CLEAR_TEXT(type);
	local maxlist = GET_EVENT_PROGRESS_CHECK_ACQUIRE_STATE_MAX_VALUE(type, accObj);
	local maxvalue = tonumber(maxlist[ctrlIndex]);

	if maxvalue ~= 0 and maxvalue <= time then
		blackbg:ShowWindow(1);
		blackbg:SetAlpha(90);

		if clearlist[ctrlIndex] ~= "None" then
			clear_text:SetTextByKey("value", ClMsg(clearlist[ctrlIndex]));
		end
	end
end

------------------------- 스탬프 -------------------------
function EVENT_PROGRESS_CHECK_STAMP_TOUR_STATE_OPEN(frame, type)
	local desclist = GET_EVENT_PROGRESS_CHECK_DESC(type);
	local nametext = GET_CHILD_RECURSIVELY(frame, "nametext");
	nametext:SetTextByKey('value', ClMsg(desclist[2]));
    
	local tiptext = GET_CHILD(frame, "tiptext");
	local tiptextlist = GET_EVENT_PROGRESS_CHECK_TIP_TEXT(type);
	if tiptextlist[2] ~= "None" then
		tiptext:SetTextByKey("value", ClMsg(tiptextlist[2]));
		tiptext:ShowWindow(1);
	end
	
	local listgb = GET_CHILD(frame, "listgb");
	if type == event_5th_type then
		local accObj = GetMyAccountObj();
		local maxlist = GET_EVENT_PROGRESS_CHECK_ACQUIRE_STATE_MAX_VALUE(type, accObj);
		local curlist = GET_EVENT_PROGRESS_CHECK_CUR_VALUE(type, accObj);
	
		if maxlist[2] <= curlist[2] then
			local overtext = GET_CHILD(frame, "overtext");
			overtext:ShowWindow(1);
			return;
		end
	
		CREATE_EVENT_PROGRESS_CHECK_CONTENTS_LIST_DAILY(type, listgb, "Event_2011_TOS_Coin");
		EVENT_2011_5TH_COIN_TOS_LIST(frame);
		return;
	end

	local eventstatelist = GET_EVENT_PROGRESS_CHECK_EVENT_STATE(type);
	if eventstatelist[3] == "pre" then
		local comming_soon_pic = GET_CHILD_RECURSIVELY(frame, "comming_soon_pic");
		comming_soon_pic:ShowWindow(1);
	elseif eventstatelist[3] == "end" then
		local ctrl = listgb:CreateControl("richtext", "tos_vacance_tip_text", 500, 100, ui.CENTER_HORZ, ui.CENTER_VERT, 0, 0, 0, 0);
		ctrl:SetTextFixWidth(1);
		ctrl:SetTextAlign("center", "top");
		ctrl:SetFontName("black_24");
		ctrl:SetText(ClMsg("EndEventMessage"));	
	else
		local accObj = GetMyAccountObj();
		local stampTourCheck = TryGetProp(accObj, "REGULAR_EVENT_STAMP_TOUR");
		if stampTourCheck == 1 then
			local notebtn = GET_CHILD_RECURSIVELY(frame, "notebtn");
			notebtn:ShowWindow(1);
	
			local y = 0;
			y = CREATE_EVENT_PROGRESS_CHECK_STAMP_TOUR_LIST(type, y, listgb, false);	-- 완료 되지 않은 목표 우선 표시
			y = CREATE_EVENT_PROGRESS_CHECK_STAMP_TOUR_LIST(type, y, listgb, true);
		else
			local ctrl = listgb:CreateControl("richtext", "tos_vacance_tip_text", 500, 100, ui.CENTER_HORZ, ui.CENTER_VERT, 0, 0, 0, 0);
			ctrl:SetTextFixWidth(1);
			ctrl:SetTextAlign("center", "top");
			ctrl:SetFontName("black_24");
			ctrl:SetText(ClMsg("EVENT_2007_FLEX_BOX_CHECK_TIP_TEXT_2"));
		end
	end

end

function CREATE_EVENT_PROGRESS_CHECK_STAMP_TOUR_LIST(type, starty, listgb, isClear)	
	local accObj = GetMyAccountObj();
	if accObj == nil then return; end

	local rewardCls = GetClass("Item", GET_EVENT_PROGRESS_CHECK_ITEM(type));
	local y = starty;

	local group = GET_EVENT_PROGRESS_CHECK_STAMP_GROUP(type);
	local itemNmae = GET_EVENT_PROGRESS_CHECK_ITEM(type);
	local clsList, clsCnt = GetClassList("note_eventlist");
	for i = 0, clsCnt do
		local missionCls = EVENT_STAMP_GET_CURRENT_MISSION(group, i);
		if missionCls == nil then
			break
		end

		for j = 1, 3 do
			local clearprop = TryGetProp(missionCls, "ClearProp"..j, 'None');
			local clear = TryGetProp(accObj, clearprop, 'false');
			if clear == tostring(isClear) and ENABLE_CREATE_EVENT_PROGRESS_CHECK_STAMP_TOUR_LIST(missionCls, i, j) == true then
				local missionStr = TryGetProp(missionCls, "Desc"..j, "");
				local missionlist = StringSplit(missionStr, ":");
				
				local rewardStr = TryGetProp(missionCls, "Reward"..j, "");	
				if missionStr ~= "None" and missionStr ~= "" and string.find(rewardStr, rewardCls.ClassName) ~= nil then 
					local ctrlSet = listgb:CreateControlSet('check_to_do_list', "CTRLSET_" ..i.."_"..j,  ui.CENTER_HORZ, ui.TOP, -10, y, 0, 0);
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
				
					local rewardicon = GET_CHILD(ctrlSet, "rewardicon");
					rewardicon:SetImage(rewardCls.Icon);
				
					local rewardcnt = GET_CHILD(ctrlSet, "rewardcnt");
					rewardcnt:SetTextByKey('value', 10);
				
					local checkbox = GET_CHILD(ctrlSet, "checkbox");
					local completion = GET_CHILD(ctrlSet, "completion");
					local checkline = GET_CHILD(ctrlSet, "checkline");
				
					if clear == 'true' then
						completion:ShowWindow(1);
						checkline:ShowWindow(1);
					else
						completion:ShowWindow(0);
						checkline:ShowWindow(0);
					end
				
					y = y + ctrlSet:GetHeight();				
				end			
			end
		end
	end

	return y;
end

function ENABLE_CREATE_EVENT_PROGRESS_CHECK_STAMP_TOUR_LIST(missionCls, i, j)
	local weekNum = TryGetProp(missionCls, "ArgNum"..j, 0);
	if weekNum == 0 then
		return true;
	end

	if EVENT_STAMP_IS_VALID_WEEK_SUMMER(weekNum) == false then
		return false;
	end

	local accObj = GetMyAccountObj();
	local isHidden = EVENT_STAMP_IS_VALID_WEEK_SUMMER(weekNum) == false or EVENT_STAMP_IS_HIDDEN_SUMMER(accObj, (3 * i) + j) == true;
	if isHidden == false then
		return true;
	end

	return false;
end

------------------------- 콘텐츠 -------------------------
function EVENT_PROGRESS_CHECK_CONTENTS_STATE_OPEN(frame, type)
	local desclist = GET_EVENT_PROGRESS_CHECK_DESC(type);
	local nametext = GET_CHILD_RECURSIVELY(frame, "nametext");
	nametext:SetTextByKey('value', ClMsg(desclist[3]));
    
	local tiptext = GET_CHILD(frame, "tiptext");
	local tiptextlist = GET_EVENT_PROGRESS_CHECK_TIP_TEXT(type);
	if tiptextlist[3] ~= "None" then
		tiptext:SetTextByKey("value", ClMsg(tiptextlist[3]));
		tiptext:ShowWindow(1);
	end
	
	local listgb = GET_CHILD(frame, "listgb");
	if type == event_5th_type then	
		CREATE_EVENT_PROGRESS_CHECK_CONTENTS_LIST_DAILY(type, listgb, "Event_2011_5th_Coin");
		EVENT_2011_5TH_COIN_LIST(frame);
		return;
	end

	local eventstatelist = GET_EVENT_PROGRESS_CHECK_EVENT_STATE(type);
	if eventstatelist[4] == "pre" then
		local comming_soon_pic = GET_CHILD_RECURSIVELY(frame, "comming_soon_pic");
		comming_soon_pic:ShowWindow(1);
	elseif eventstatelist[4] == "end" then
		local listgb = GET_CHILD(frame, "listgb");
		local ctrl = listgb:CreateControl("richtext", "contents_tip_text", 500, 100, ui.CENTER_HORZ, ui.CENTER_VERT, 0, 0, 0, 0);
		ctrl:SetTextFixWidth(1);
		ctrl:SetTextAlign("center", "top");
		ctrl:SetFontName("black_24");
		ctrl:SetText(ClMsg("EndEventMessage"));	
	else
		local listgb = GET_CHILD(frame, "listgb");
		local accObj = GetMyAccountObj();
		local maxlist = GET_EVENT_PROGRESS_CHECK_ACQUIRE_STATE_MAX_VALUE(type, accObj);
		local curlist = GET_EVENT_PROGRESS_CHECK_CUR_VALUE(type, accObj);
		local contentslist = GET_EVENT_PROGRESS_CONTENTS_MAX_CONSUME_COUNT(type);
		if contentslist == "daily" then
			if maxlist[4] <= curlist[4] then
				overtext:ShowWindow(1);
				return;
			end
			CREATE_EVENT_PROGRESS_CHECK_CONTENTS_LIST_DAILY(type, listgb);
		elseif contentslist == "first" then
			local y = 0;
			y = CREATE_EVENT_PROGRESS_CHECK_CONTENTS_LIST_FIRST(type, y, listgb, false);	-- 완료 되지 않은 목표 우선 표시
			y = CREATE_EVENT_PROGRESS_CHECK_CONTENTS_LIST_FIRST(type, y, listgb, true);
		end
	end
end

function CREATE_EVENT_PROGRESS_CHECK_CONTENTS_LIST_DAILY(type, listgb, coinName)
	local accObj = GetMyAccountObj();
	if accObj == nil then return; end

	if coinName == nil then
		coinName = GET_EVENT_PROGRESS_CHECK_ITEM(type);
	end

	local rewardCls = GetClass("Item", coinName);
	local y = 0;
	local clsList, clscnt  = GetClassList("event_coin");
	for i = 0, clscnt - 1 do
		local missionCls = GetClassByIndexFromList(clsList, i);
		local ret, count = ENABLE_EVENT_PROGRESS_CONTENTS_DAILY(missionCls, rewardCls.ClassName);
		if ret == true and count ~= 0 then
			local desc = TryGetProp(missionCls, "Desc", "None");
			if desc ~= "None" then
				local ctrlSet = listgb:CreateControlSet("simple_to_do_list", "CTRLSET_" ..missionCls.ClassName,  ui.CENTER_HORZ, ui.TOP, -10, y, 0, 0);
				local rewardicon = GET_CHILD(ctrlSet, "rewardicon");
				rewardicon:SetImage(rewardCls.Icon);
			
				local rewardtext = GET_CHILD(ctrlSet, "rewardtext");
				rewardtext:SetTextByKey('value', desc);
		
				local rewardcnt = GET_CHILD(ctrlSet, "rewardcnt");
				rewardcnt:SetTextByKey('value', count);
	
				y = y + ctrlSet:GetHeight();
			end			
		end
	end
end

function CREATE_EVENT_PROGRESS_CHECK_CONTENTS_LIST_FIRST(type, starty, listgb, isClear)
	local accObj = GetMyAccountObj();
	if accObj == nil then return; end

	local y = starty;
	local clsList, clscnt  = GetClassList("event_new_season_server_content_clear_coin_reward");
	for i = 0, clscnt - 1 do
		local missionCls = GetClassByIndexFromList(clsList, i);

		local clearprop = string.format( "%s_%s", 'EVENT_NEW_SEASON_SERVER_CONTENT_FIRST_CLEAR_CHECK', missionCls.ClassID);
		local clear = TryGetProp(accObj, clearprop, 0);

		if (clear == 1 and isClear == true) or (clear == 0 and isClear == false) then
			local ctrlSet = listgb:CreateControlSet('check_to_do_list', "CTRLSET_" ..i,  ui.CENTER_HORZ, ui.TOP, -10, y, 0, 0);
			local rewardtext = GET_CHILD(ctrlSet, "rewardtext");
			rewardtext:SetTextByKey('value', missionCls.ContentsName);
	
			local rewardcnt = GET_CHILD(ctrlSet, "rewardcnt");
			rewardcnt:SetTextByKey('value', missionCls.FirstCoin);
	
			local checkbox = GET_CHILD(ctrlSet, "checkbox");
			local completion = GET_CHILD(ctrlSet, "completion");
			local checkline = GET_CHILD(ctrlSet, "checkline");
				
			if clear == 1 then
				completion:ShowWindow(1);
				checkline:ShowWindow(1);
			else
				completion:ShowWindow(0);
				checkline:ShowWindow(0);
			end
			
			y = y + ctrlSet:GetHeight();
		end
	end

	return y;
end

function ENABLE_EVENT_PROGRESS_CONTENTS_DAILY(missionCls, itemClassName)
	for i = 1, 4 do
		local coinName = TryGetProp(missionCls, "CoinName_"..i)
		if coinName == itemClassName then
			return true, TryGetProp(missionCls, "CoinCount_"..i);
		end
	end

	return false;
end

------------------------- NPC -------------------------
function EVENT_PROGRESS_NPC_POS_BTN_CLICK(frame, msg, argStr)
	local context = ui.CreateContextMenu("flex_box_npc_pos", "", 0, 0, 120, 120);

	local npclist = StringSplit(argStr, ";");
	for i = 1, #npclist do
		local npcStr = StringSplit(npclist[i], "/");

		scpScp = string.format("EVENT_PROGRESS_NPC_POS_MINIMAP(\"%s\", %d, %d)", npcStr[2], npcStr[3], npcStr[4]);
		ui.AddContextMenuItem(context, ClMsg(npcStr[1]), scpScp);
	end

    ui.OpenContextMenu(context);
end

function EVENT_PROGRESS_NPC_POS_MINIMAP(mapname, x, z)	
	SCR_SHOW_LOCAL_MAP(mapname, true, x, z)	;
end

------------------------- YOUR_MASTER -------------------------
local json = require "json_imc";
local curPage = 1;
local infolistY = 0;
local scrolledTime = 0;
local finishedLoading = false;
local all_ranking_score_sum = 0;
function EVENT_YOUR_MASTER_OPEN(frame, msg, argStr)
	local strList = StringSplit(argStr, "/");
    local state = strList[1];
    local week = tonumber(strList[2]);
	local curcnt = strList[3];
	local nextcnt = strList[4];

	EVENT_YOUR_MASTER_INIT(frame, state, week, curcnt, nextcnt);
	EVENT_YOUR_MATER_TAB_CLICK(frame, nil, state, week);
	frame:ShowWindow(1);
end

function EVENT_YOUR_MASTER_INIT(frame, state, week, curcnt, nextcnt)
	local title = GET_CHILD_RECURSIVELY(frame, "title");
	title:SetTextByKey("value", ClMsg(GET_EVENT_PROGRESS_CHECK_TITLE(your_master_type)));

	local tab2 = GET_CHILD(frame, "tab2");	
	tab2:SelectTab(0);	
	tab2:SetEventScript(ui.LBUTTONUP, "EVENT_YOUR_MATER_TAB_CLICK");

	local tab2_listgb1 = GET_CHILD(frame, "tab2_listgb1");
	tab2_listgb1:SetUserValue("STATE", state);
	tab2_listgb1:SetUserValue("WEEK", week);
	tab2_listgb1:SetUserValue("CUR_COUNT", curcnt);
	tab2_listgb1:SetUserValue("NEXT_COUNT", nextcnt);

	local tab2_listgb2 = GET_CHILD(frame, "tab2_listgb2");
	tab2_listgb2:SetUserValue("WEEK", week - 1);

	local tabtitlelist = GET_EVENT_PROGRESS_CHECK_TAB_TITLE(your_master_type);
	for i = 1, #tabtitlelist do
		tab2:ChangeCaption(i - 1, "{@st66b}{s18}"..ClMsg(tabtitlelist[i]), false);
	end
	tab2:SetItemsAdjustFontSizeByWidth(152);

	EVENT_PROGRESS_TAB_TOGGLE(frame, 0);

	local notebtn = GET_CHILD_RECURSIVELY(frame, "notebtn");
	notebtn:SetTextByKey("value", ClMsg(GET_EVENT_PROGRESS_CHECK_NOTE_NAME(your_master_type)));
	notebtn:SetEventScript(ui.LBUTTONUP, GET_EVENT_PROGRESS_CHECK_NOTE_BTN(your_master_type));

	local titlegb = GET_CHILD(frame, "titlegb");
	titlegb:SetSkinName(GET_EVENT_PROGRESS_CHECK_TITLE_SKIN(your_master_type));

	local title_deco = GET_CHILD(frame, "title_deco");
	title_deco:SetImage(GET_EVENT_PROGRESS_CHECK_TITLE_DECO(your_master_type));	

	local loadingtext = GET_CHILD(frame, "loadingtext");
	loadingtext:ShowWindow(0);
end

function EVENT_PROGRESS_TAB_UNFREEZE()
	local frame = ui.GetFrame("event_progress_check");
	local tab2 = GET_CHILD(frame, "tab2");
	tab2:EnableHitTest(1);
	finishedLoading = true;
end

function EVENT_YOUR_MASTER_TAB_INIT(index)
	local frame = ui.GetFrame("event_progress_check");

	local tab2 = GET_CHILD(frame, "tab2");
	if index == nil then
		index = tab2:GetSelectItemIndex();
	end
		
	local tab2_listgb1 = GET_CHILD(frame, "tab2_listgb1");
	local tab2_listgb2 = GET_CHILD(frame, "tab2_listgb2");
	local tab2_listgb3 = GET_CHILD(frame, "tab2_listgb3");
	if index == 0 then
		tab2_listgb1:ShowWindow(1);
		tab2_listgb2:ShowWindow(0);
		tab2_listgb3:ShowWindow(0);

		tab2_listgb1:SetEventScript(ui.SCROLL, "None");
		tab2_listgb1:SetScrollPos(0);
		tab2_listgb1:RemoveAllChild();
	elseif index == 1 then
		tab2_listgb1:ShowWindow(0);
		tab2_listgb2:ShowWindow(1);
		tab2_listgb3:ShowWindow(0);

		tab2_listgb2:SetEventScript(ui.SCROLL, "None");
		tab2_listgb2:SetScrollPos(0);
		tab2_listgb2:RemoveAllChild();
	else
		tab2_listgb1:ShowWindow(0);
		tab2_listgb2:ShowWindow(0);
		tab2_listgb3:ShowWindow(1);

		tab2_listgb3:SetEventScript(ui.SCROLL, "None");
		tab2_listgb3:SetScrollPos(0);
		tab2_listgb3:RemoveAllChild();
	end

    infolistY = 0;
    curPage = 1;
	scrolledTime = imcTime.GetAppTime();
	finishedLoading = false;
	all_ranking_score_sum = 0;
end

function EVENT_YOUR_MATER_TAB_CLICK(parent, ctrl)
	local frame = parent:GetTopParentFrame();
	local tab2 = GET_CHILD(frame, "tab2");
	tab2:EnableHitTest(0);
	ReserveScript("EVENT_PROGRESS_TAB_UNFREEZE()", 1.5);

	local index = tab2:GetSelectItemIndex();

	local notebtn = GET_CHILD_RECURSIVELY(frame, "notebtn");
	notebtn:ShowWindow(0);
	notebtn:Resize(100, 36);

	local overtext = GET_CHILD(frame, "overtext");
	overtext:ShowWindow(0);

	local tiptext = GET_CHILD(frame, "tiptext");
	tiptext:ShowWindow(0);

	local comming_soon_pic = GET_CHILD_RECURSIVELY(frame, "comming_soon_pic");
	comming_soon_pic:ShowWindow(0);

	local desclist = GET_EVENT_PROGRESS_CHECK_DESC(your_master_type);
	local nametext = GET_CHILD_RECURSIVELY(frame, "nametext");
	nametext:SetTextByKey('value', ClMsg(desclist[index + 1]));
	
	EVENT_YOUR_MASTER_TAB_INIT(index);

	if index < 2 then
		local gbname = "tab2_listgb"..(index+1);
		local listgb = GET_CHILD(frame, gbname);
		listgb:SetEventScript(ui.SCROLL, "EVENT_YOUR_MASTER_RANKING_SCROLL");
		local week = listgb:GetUserIValue("WEEK");
		if week < 1 then
			comming_soon_pic:ShowWindow(1)
			return;
		end

		local tiptext = GET_CHILD(frame, "tiptext");
		local tiptextlist = GET_EVENT_PROGRESS_CHECK_TIP_TEXT(your_master_type);
		if tiptextlist[index + 1] ~= "None" then
			if index == 0 then
				tiptext:SetTextByKey("value", ClMsg(tiptextlist[index + 1]..week)..ClMsg("RankingUpdateTime10Min"));
			else
				tiptext:SetTextByKey("value", ClMsg(tiptextlist[index + 1]..week));
			end
			tiptext:ShowWindow(1);
		end

		local state = listgb:GetUserValue("STATE");
		if state == "prev" then
			comming_soon_pic:ShowWindow(1);
			return;
		end

		local loadingtext = GET_CHILD(frame, "loadingtext");
		loadingtext:ShowWindow(1);
		
		local sort = GET_RANKING_SORT_TYPE(index, state);
		GetRaidRankingSumScore("EVENT_YOUR_MASTER_SUM_SCORE_UPDATE", "EVENT_2008_YOUR_MASTER:EVENT_2008_YOUR_MASTER_"..week, sort);
	elseif index == 2 then
		EVENT_YOUR_MASTER_ACCRUE_REWARD_INIT(frame);
	end
end

function EVENT_YOUR_MASTER_SUM_SCORE_UPDATE(code, retValue)
    if code ~= 200 then
        if code == 500 then
            ui.SysMsg(ScpArgMsg('CantExecInThisArea'));
        end

		ui.SysMsg(ScpArgMsg("GuildJointInvTryLater"));
		EVENT_YOUR_MASTER_TAB_INIT();
        return;
    end
	
	all_ranking_score_sum = retValue;

	ReserveScript("EVENT_YOUR_MASTER_UPDATE()", 1);
end

function EVENT_YOUR_MASTER_UPDATE()
	local frame = ui.GetFrame("event_progress_check");	
	local tab2 = GET_CHILD(frame, "tab2");
	local tabindex = tab2:GetSelectItemIndex();

	local gbname = "tab2_listgb"..(tabindex + 1);
	local listgb = GET_CHILD(frame, gbname);
	local week = listgb:GetUserIValue("WEEK");
	local state = listgb:GetUserValue("STATE");

	local sort = GET_RANKING_SORT_TYPE(tabindex, state);
	GetRaidRanking("_EVENT_YOUR_MASTER_UPDATE", "EVENT_2008_YOUR_MASTER:EVENT_2008_YOUR_MASTER_"..week, curPage, sort);
end

function _EVENT_YOUR_MASTER_UPDATE(code, ret_json)
	finishedLoading = true;
    if code ~= 200 then
        if code == 500 then
            ui.SysMsg(ScpArgMsg('CantExecInThisArea'));
        end

		ui.SysMsg(ScpArgMsg("GuildJointInvTryLater"));
		EVENT_YOUR_MASTER_TAB_INIT();
        return;
    end

    local parsed = json.decode(ret_json);
    local count = parsed['count'];
    if tonumber(count) == 0 then
        return;
    end
	
	local frame = ui.GetFrame("event_progress_check");

	local loadingtext = GET_CHILD(frame, "loadingtext");
	loadingtext:ShowWindow(0);

	local tab2 = GET_CHILD(frame, "tab2");
	local tabindex = tab2:GetSelectItemIndex();

	local gbname = "tab2_listgb"..(tabindex+1);
	local listgb = GET_CHILD(frame, gbname);
	
	local state = listgb:GetUserValue("STATE");
	local curCnt = listgb:GetUserValue("CUR_COUNT");

	local sort = GET_RANKING_SORT_TYPE(tabindex, state);
	local npclist = {};
	local list = parsed['list'];
	for k, v in pairs(list) do
		local member = v["member"];
		local score = v["score"];
		local rank = v["rank"]
		if sort == "asc" then
			rank = curCnt - rank + 1;
		end

		local npc_cls = GetClass("event_ranking_data", member);
		if npc_cls ~= nil then
			infolistY = EVENT_YOUR_MASTER_LIST_CREATE(listgb, infolistY, rank, member, score, tabindex);
		end
	end   
end

function EVENT_YOUR_MASTER_LIST_CREATE(gb, y, rank, member, score, tabindex)
	local npc_cls = GetClass("event_ranking_data", member);
	if npc_cls == nil or gb == nil then
		return y; 
	end

	local ctrlSet = gb:CreateOrGetControlSet("event_ranking_list", "LIST"..rank, 0, y);	
	if ctrlSet == nil then
		return y; 
	end
	
	local btn = GET_CHILD(ctrlSet, "btn");
	local btn_text = GET_CHILD(ctrlSet, "btn_text");
	local blackbg = GET_CHILD(ctrlSet, "blackbg");
    local text_ctrl = GET_CHILD(ctrlSet, "text");
    text_ctrl:SetTextByKey("value", npc_cls.Name);

    local rank_ctrl = GET_CHILD(ctrlSet, "rank");
	rank_ctrl:SetTextByKey("value", rank);
	
    local rankingimg = GET_CHILD(ctrlSet, "rankingimg");
	if rank <= 3 then
		rankingimg:SetImage("your_master_ranking0"..rank);
	end
	
	local percent = "0.00";
	all_ranking_score_sum = tonumber(all_ranking_score_sum)
	if all_ranking_score_sum ~= 0 then
		percent = string.format("%.2f", math.floor(score/all_ranking_score_sum*10000)/100);
	end

	local percent_ctrl = GET_CHILD(ctrlSet, "percent");
	percent_ctrl:SetTextByKey("value", percent);
	
    local gauge_ctrl = GET_CHILD(ctrlSet, "gauge");
	gauge_ctrl:SetPoint(score, all_ranking_score_sum);

	if tabindex == 1 then
		btn:SetEnable(0);
		btn_text:SetEnable(0);

		blackbg:ShowWindow(1);
		blackbg:SetAlpha(60);
		
		y = y + ctrlSet:GetHeight();
		return y;
	end
	
	local state = gb:GetUserValue("STATE");
	local cnt = gb:GetUserIValue("NEXT_COUNT");
	blackbg:ShowWindow(0);

	if state == "end" then
		btn:SetEnable(0);
		btn_text:SetEnable(0);
		
		if score == 0 or (cnt < rank) then
			local prev_ctrl_name = "LIST"..(rank-1);
			local prev_ctrl = GET_CHILD_RECURSIVELY(gb, prev_ctrl_name);
			local prev_percent = GET_CHILD(prev_ctrl, "percent");
			local prev_blackbg = GET_CHILD(prev_ctrl, "blackbg");
			local prev_percentText = prev_percent:GetTextByKey("value");

			if prev_percentText ~= percent or prev_blackbg:IsVisible() == 1 then
				blackbg:ShowWindow(1);
				blackbg:SetAlpha(60);
			end
		end
	else		
		btn:SetEventScript(ui.LBUTTONUP, "EVENT_YOUR_MASTER_LIST_CLICK");
		btn:SetEventScriptArgString(ui.LBUTTONUP, npc_cls.ClassID);
		btn:ShowWindow(1);
		btn_text:ShowWindow(1);
	end

    y = y + ctrlSet:GetHeight();
    return y;
end

function EVENT_YOUR_MASTER_RANKING_SCROLL(parent, ctrl)
	local week = ctrl:GetUserValue("WEEK");
	if week == "None" then
		return;
	end

	local frame = ui.GetFrame("event_progress_check");
	
	local tab2 = GET_CHILD(frame, "tab2");
	if tab2 == nil then
		return;
	end

	local index = tab2:GetSelectItemIndex();

    if ctrl:IsScrollEnd() == true and finishedLoading == true then
        local now = imcTime.GetAppTime();
        local dif = now - scrolledTime;

		if 2 < dif then
			curPage = curPage + 1;

			local state = ctrl:GetUserValue("STATE")
			local sort = GET_RANKING_SORT_TYPE(index, state);
			GetRaidRanking("_EVENT_YOUR_MASTER_UPDATE", "EVENT_2008_YOUR_MASTER:EVENT_2008_YOUR_MASTER_"..week, curPage, sort);
			
            scrolledTime = now;
			finishedLoading = false;
			
			local tab2 = GET_CHILD(frame, "tab2");
			tab2:EnableHitTest(0);
			ReserveScript("EVENT_PROGRESS_TAB_UNFREEZE()", 1.5);
        end
    end

end

function EVENT_YOUR_MASTER_LIST_CLICK(parent, ctrl, npcClassID)
    if ui.CheckHoldedUI() == true then
        return;
    end

	local npc_cls = GetClassByType("event_ranking_data", npcClassID);
    if npc_cls == nil then
        return;
	end
	
	local mapprop = session.GetCurrentMapProp();
	local mapCls = GetClassByType("Map", mapprop.type);	
	if IS_TOWN_MAP(mapCls) == false then
		ui.SysMsg(ClMsg("OnlyVoteInTown"));
        return;
    end

	local mat_ClassName = GET_EVENT_YOUR_MASTER_VOTE_MATERIAL();
    local curCnt = GET_INV_ITEM_COUNT_BY_PROPERTY({{Name = "ClassName", Value = mat_ClassName}}, false);
    if curCnt <= 0 then
		ui.SysMsg(ClMsg("NotEnoughVoteMaterial"));
        return;
    end

    control.CustomCommand("REQ_EVENT_YOUR_MASTER_VOTE_CLICK", npcClassID);
end

function EVENT_YOUR_MASTER_ACCRUE_REWARD_INIT(frame)
	local listgb = GET_CHILD(frame, gbname);

	local tab2_listgb3 = GET_CHILD_RECURSIVELY(frame, "tab2_listgb3");
	tab2_listgb3:RemoveAllChild();
	
	local table = GET_EVENT_YOUR_MASTER_ACCRUE_REWARD_TABLE();

    for i = 1, #table do
        local tablelist = StringSplit(table[i], ";");

		local rewardText = "";
		local accCount = tablelist[1];
		for i = 2, #tablelist do
			local rewradStrlist = StringSplit(tablelist[i], "/");
			local itemClassName = rewradStrlist[1];
			local itemCount = rewradStrlist[2];

			local itemCls = GetClass("Item", itemClassName);
			if itemCls ~= nil then
				local str = string.format("%s %d%s {nl}", itemCls.Name, itemCount, ClMsg("Piece"));
				if config.GetServiceNation() == "GLOBAL" then
					str = string.format("%s %s %d{nl}", itemCls.Name, ClMsg("Piece"), itemCount);
				end

				rewardText = rewardText..str;
			end
		end

		local ctrl = tab2_listgb3:CreateOrGetControlSet("reward_item_list", "LIST_"..i, 0, 0);
		ctrl:Resize(500, 90)
		local icon = GET_CHILD(ctrl, "icon");
		icon:ShowWindow(0);
		
        local listtext = GET_CHILD(ctrl, "listtext");
		listtext:SetTextByKey("value", rewardText);
		
        local count = GET_CHILD(ctrl, "count");
		count:ShowWindow(0);

        local text = GET_CHILD(ctrl, "text");
		text:SetTextByKey("value", accCount..ClMsg("Piece2"));
		
		local accObj = GetMyAccountObj();
		local curAccCnt = TryGetProp(accObj, "EVENT_YOUR_MASTER_TOTAL_VOTE_COUNT", 0);
		if tonumber(accCount) <= curAccCnt then
			local blackbg = ctrl:CreateOrGetControl("picture", "blackbg", 0, 0, 488, 80);
			AUTO_CAST(blackbg);			
			blackbg:SetGravity(ui.CENTER_HORZ, ui.CENTER_VERT);
			blackbg:SetImage("fullblack");
			blackbg:SetEnableStretch(1);
			blackbg:SetAlpha(90);

			local acquire_text = ctrl:CreateOrGetControl("richtext", "acquire_text", 0, 0, 488, 80);
			AUTO_CAST(acquire_text);
			acquire_text:SetGravity(ui.CENTER_HORZ, ui.CENTER_VERT);					
			acquire_text:SetText("{@st43b}{s20}"..ClMsg("AcquireRewardMessage"));
		end
    end
    
    GBOX_AUTO_ALIGN(tab2_listgb3, 0, -5, 0, true, false);
end

function GET_RANKING_SORT_TYPE(tabindex, state)
	if tabindex == 0 and state == "cur" then
		return "asc";
	end

	return "des";
end



------------------------- EVENT_2011_5TH -------------------------
function EVENT_2011_5TH_COIN_TOS_LIST(frame)
	local rewardCls = GetClass("Item", "Event_2011_TOS_Coin");
	if rewardCls == nil then
		return;
	end

	local listgb = GET_CHILD(frame, "listgb");

	-- 1시간 접속 
	local ctrlSet1 = listgb:CreateControlSet("simple_to_do_list", "CTRLSET_DAILY_PLAY_TIEM",  ui.CENTER_HORZ, ui.TOP, -10, 0, 0, 0);
	local rewardicon1 = GET_CHILD(ctrlSet1, "rewardicon");
	rewardicon1:SetImage(rewardCls.Icon);
			
	local rewardtext1 = GET_CHILD(ctrlSet1, "rewardtext");
	rewardtext1:SetTextByKey('value', ClMsg("EVENT_2011_5TH_MSG_9"));

	local rewardcnt1 = GET_CHILD(ctrlSet1, "rewardcnt");
	rewardcnt1:SetTextByKey('value', 10);
	
	GBOX_AUTO_ALIGN(listgb, 0, 0, 0, true, false);
end

function EVENT_2011_5TH_COIN_LIST(frame)	
	local rewardCls = GetClass("Item", "Event_2011_5th_Coin");
	if rewardCls == nil then
		return;
	end

	local listgb = GET_CHILD(frame, "listgb");
	listgb:EnableHitTest(1);

	-- 일반 필드 몬스터 툴팁
	local ctrlset1 = GET_CHILD_RECURSIVELY(listgb, "CTRLSET_monKill_Field_Normal");
	local ctrl1 = GET_CHILD_RECURSIVELY(ctrlset1, "gb");
	ctrl1:EnableHitTest(1);
	ctrl1:SetTextTooltip(ClMsg("EVENT_2011_5TH_MSG_12").."{nl}"..ClMsg("EVENT_2011_5TH_MSG_7"));

	-- 엘리트 필드 몬스터 툴팁
	local ctrlset2 = GET_CHILD_RECURSIVELY(listgb, "CTRLSET_monKill_Field_Elite");
	local ctrl2 = GET_CHILD_RECURSIVELY(ctrlset2, "gb");
	ctrl2:EnableHitTest(1);
	ctrl2:SetTextTooltip(ClMsg("EVENT_2011_5TH_MSG_12").."{nl}"..ClMsg("EVENT_2011_5TH_MSG_8"));

	-- 1시간 접속 
	local ctrlSet3 = listgb:CreateControlSet("simple_to_do_list", "CTRLSET_DAILY_PLAY_TIEM",  ui.CENTER_HORZ, ui.TOP, -10, 0, 0, 0);
	local rewardicon3 = GET_CHILD(ctrlSet3, "rewardicon");
	rewardicon3:SetImage(rewardCls.Icon);
			
	local rewardtext3 = GET_CHILD(ctrlSet3, "rewardtext");
	rewardtext3:SetTextByKey('value', ClMsg("EVENT_2011_5TH_MSG_9"));
		
	local rewardcnt3 = GET_CHILD(ctrlSet3, "rewardcnt");
	rewardcnt3:SetTextByKey('value', 10);

	local ctrl3 = GET_CHILD_RECURSIVELY(ctrlSet3, "gb");
	ctrl3:EnableHitTest(1);
	ctrl3:SetTextTooltip(ClMsg("EVENT_2011_5TH_MSG_13"));

	-- TOS 주화 100개 획득
	local ctrlSet4 = listgb:CreateControlSet("simple_to_do_list", "CTRLSET_COIN_TOS_BONUS",  ui.CENTER_HORZ, ui.TOP, -10, 0, 0, 0);
	local rewardicon4 = GET_CHILD(ctrlSet4, "rewardicon");
	rewardicon4:SetImage(rewardCls.Icon);
			
	local rewardtext4 = GET_CHILD(ctrlSet4, "rewardtext");
	rewardtext4:SetTextByKey('value', ClMsg("EVENT_2011_5TH_MSG_10"));
		
	local rewardcnt4 = GET_CHILD(ctrlSet4, "rewardcnt");
	rewardcnt4:SetTextByKey('value', 10);

	-- TOS 주화 교환
	local ctrlSet5 = listgb:CreateControlSet("simple_to_do_list", "CTRLSET_COIN_TOS_EXCHANGE",  ui.CENTER_HORZ, ui.TOP, -10, 0, 0, 0);
	local rewardicon5 = GET_CHILD(ctrlSet5, "rewardicon");
	rewardicon5:SetImage(rewardCls.Icon);
			
	local rewardtext5 = GET_CHILD(ctrlSet5, "rewardtext");
	rewardtext5:SetTextByKey('value', ClMsg("EVENT_2011_5TH_MSG_11"));
		
	local rewardcnt5 = GET_CHILD(ctrlSet5, "rewardcnt");
	rewardcnt5:SetTextByKey('value', 1);

	GBOX_AUTO_ALIGN(listgb, 0, 0, 0, true, false);
end