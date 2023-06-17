function EVENT_STAMP_TOUR_ON_INIT(addon, frame)
	addon:RegisterMsg("EVENT_STAMP_TOUR_UI_OPEN_COMMAND", "ON_EVENT_STAMP_TOUR_UI_OPEN_COMMAND");
	addon:RegisterMsg("EVENT_STAMP_TOUR_REWARD_GET", "ON_EVENT_STAMP_TOUR_REWARD_GET");

end

function OPEN_EVENT_STAMP_TOUR(frame)
	EVENT_STAMP_TOUR_CREATE_PAGE(frame);
	EVENT_STAMP_TOUR_SET_PAGE(frame);
end

function CLOSE_EVENT_STAMP_TOUR(frame)

end

function ON_EVENT_STAMP_TOUR_UI_OPEN_COMMAND()
	local frame = ui.GetFrame("event_stamp_tour")
	frame:SetUserValue("GROUP_NAME","REGULAR_EVENT_STAMP_TOUR")
	frame:ShowWindow(1)
end

-- controlset 초기화
function EVENT_STAMP_TOUR_CREATE_PAGE(frame)
	local groupName = frame:GetUserValue("GROUP_NAME")
	local clsList, allmissionCnt = GetClassList('note_eventlist');

	-- 띠지 control 생성
	local LABEL_OFFSET_Y = frame:GetUserConfig('LABEL_OFFSET_Y');
	local label_tab = GET_CHILD_RECURSIVELY(frame, 'label_tab');
	label_tab:ClearItemAll();	
	label_tab:EnableHitTest(1);
	
	for i = 0, allmissionCnt - 1 do
		local cls = GetClassByIndexFromList(clsList, i);
		if cls.Group == groupName then
			local image = cls.TypeIcon;
			label_tab:AddItem("", true, "EVENT_STAMP_TOUR_SET_PAGE", image, image.."_cursoron", image.."_clicked", cls.TypeName, false);
		end
	end
	
	-- 미션 내용 control 생성
	local misson_gb = GET_CHILD_RECURSIVELY(frame, 'misson_gb');
	local DESC_OFFSET_Y = frame:GetUserConfig('DESC_OFFSET_Y');
	misson_gb:RemoveAllChild();
	local misson_gb_y = 0;

	for i = 1, 3 do
		local controlsetName = 'event_stamp_tour_mission_block'
		if groupName == "EVENT_STAMP_TOUR_SUMMER" then
			controlsetName = 'event_stamp_tour_mission_block_summer'
		elseif groupName == "EVENT_STAMP_TOUR_CHRISTMAS" then
			controlsetName = 'event_stamp_tour_mission_block_christmas'
		end
		local ctrlSet = misson_gb:CreateOrGetControlSet(controlsetName, 'MISSIONBLOCK_'..i, 0, misson_gb_y);
		ctrlSet = tolua.cast(ctrlSet, 'ui::CControlSet');	
		ctrlSet:ShowWindow(1);
		ctrlSet:SetGravity(ui.CENTER_HORZ, ui.TOP);

		local reward_bg = GET_CHILD_RECURSIVELY(ctrlSet, 'reward_bg');
		reward_bg:RemoveAllChild();
		
		misson_gb_y = misson_gb_y + ctrlSet:GetHeight() + DESC_OFFSET_Y;
	end

end

function EVENT_STAMP_TOUR_SET_PAGE(frame)

	local REWARD_TEXT_FONT = frame:GetUserConfig('REWARD_TEXT_FONT');
	local REWARD_CLEAR_BG_ALPHA = frame:GetUserConfig('REWARD_CLEAR_BG_ALPHA');
	local REWARD_CHECK_BG_ALPHA = frame:GetUserConfig('REWARD_CHECK_BG_ALPHA');
	local REWARD_DESC_OFFSET_Y = frame:GetUserConfig('REWARD_DESC_OFFSET_Y');

	local misson_gb = GET_CHILD_RECURSIVELY(frame, 'misson_gb');
	local label_tab = GET_CHILD_RECURSIVELY(frame, 'label_tab');

	local currentpage = label_tab:GetSelectItemIndex();
	local groupName = frame:GetUserValue("GROUP_NAME")
	local missionCls = EVENT_STAMP_GET_CURRENT_MISSION(groupName,currentpage)
	
	local typename_text = GET_CHILD_RECURSIVELY(frame, 'typename_text');
	typename_text:SetTextByKey('value', missionCls.NoteName);

	local accObj = GetMyAccountObj();

	for i = 1, 3 do
		local clearprop = TryGetProp(missionCls, "ClearProp"..i, 'None');
		local clear = TryGetProp(accObj, clearprop, 'false');

		local ctrlSet = GET_CHILD_RECURSIVELY(misson_gb, 'MISSIONBLOCK_'..i);
		ctrlSet = tolua.cast(ctrlSet, 'ui::CControlSet');
		if TryGetProp(missionCls,"Desc"..i,'None') == 'None' then
			for j = i,3 do
				ctrlSet:ShowWindow(0)
			end
			break
		end
		ctrlSet:ShowWindow(1)
		-- 난이도
		local missionName = TryGetProp(missionCls,"Name"..i,'None')
		local levet_text = GET_CHILD_RECURSIVELY(ctrlSet, 'levet_text');
		levet_text:SetTextByKey('value', ClMsg("EventStampTourLevel_"..i));

	

		-- if groupName == "EVENT_STAMP_TOUR_SUMMER" then
			levet_text:SetTextByKey('value', ScpArgMsg("EventStampTourSummerLevel","Level",i));
		-- end
		-- 미션 내용
		local desc = GET_CHILD_RECURSIVELY(ctrlSet, 'desc');
		local missiontext = dic.getTranslatedStr(TryGetProp(missionCls, "Desc"..i, ""));
		local delimeter = string.find(missiontext,'::')

		-- 툴팁으로 자세한 미션 내용 출력
		if delimeter ~= nil then
			local mainText = string.sub(missiontext,1,delimeter-1)
			desc:SetTextByKey('value', mainText);
			local subText = string.sub(missiontext,delimeter+2)
			local tooltipText = string.format( "%s", subText);
			desc:SetTextTooltip(tooltipText);
			desc:EnableHitTest(1);
		else
			desc:SetTextByKey('value', missiontext);
			desc:SetTextTooltip("");
			desc:EnableHitTest(0);
		end
		
		if missionName ~= "None" then
			desc:SetTextByKey('value', missionName);
		end

		-- 진행상황		
		local checkprop = TryGetProp(missionCls, "CheckProp"..i, 'None');
		local proplist = StringSplit(checkprop, "/");
		local propname = proplist[1];
		local goalcnt = proplist[2];
		local curcnt = TryGetProp(accObj, propname, 0);

		local gauge = GET_CHILD_RECURSIVELY(ctrlSet, 'gauge');
		gauge:SetPoint(curcnt, goalcnt);
		
		-- 보상 text
		local reward = TryGetProp(missionCls, "Reward"..i, "None")
		local rewardliststr = StringSplit(reward, '/');
		local rewardcnt = #rewardliststr;

		local reward_bg = GET_CHILD_RECURSIVELY(ctrlSet, 'reward_bg');
		reward_bg:RemoveAllChild();
		local gravity_horz = reward_bg:GetHorzGravity()
		local gravity_vert = reward_bg:GetVertGravity()

		local reward = GET_CHILD_RECURSIVELY(ctrlSet, 'reward');			
		reward:ShowWindow(0);
		if rewardcnt > 0 then
			reward:ShowWindow(1);
		end
		
		local reward_Y = 0;
		for j = 1, rewardcnt - 1, 2 do
			local itemcls = GetClass('Item', rewardliststr[j]);
			local itemname = TryGetProp(itemcls, 'Name', 'None');

			local rewardtext = reward_bg:CreateOrGetControl('richtext', 'REWARD_TEXT_'..(math.floor(j/2)), 0, reward_Y, 100, 10);
			if GetServerNation() == "GLOBAL" then
				rewardtext:SetText(itemname.." "..ClMsg("Piece")..rewardliststr[j+1]);
			else
				rewardtext:SetText(itemname.." "..rewardliststr[j+1]..ClMsg("Piece"));
			end
			rewardtext:SetFontName(REWARD_TEXT_FONT)
			rewardtext:SetGravity(gravity_horz, gravity_vert);

			reward_Y = reward_Y + REWARD_DESC_OFFSET_Y;
		end
		
		-- 목표 수치 달성
		local check_bg = GET_CHILD_RECURSIVELY(ctrlSet, 'check_bg');
		check_bg:ShowWindow(0);
		check_bg:EnableHitTest(0);
		if clear ~= 'true' and tonumber(goalcnt) <= tonumber(curcnt) then
			check_bg:ShowWindow(1);
			check_bg:SetAlpha(REWARD_CHECK_BG_ALPHA);
			check_bg:EnableHitTest(1);

			check_bg:SetEventScript(ui.LBUTTONUP, 'EVENT_STAMP_TOUR_MISSION_CLEAR_CHECK')
			check_bg:SetEventScriptArgNumber(ui.LBUTTONUP, i);
		end
		
		-- 보상 획득
		local clear_bg = GET_CHILD_RECURSIVELY(ctrlSet, 'clear_bg');
		local clear_Pic = GET_CHILD_RECURSIVELY(ctrlSet, 'clear_Pic');
		clear_bg:ShowWindow(0);
		clear_Pic:ShowWindow(0);
		local go_btn = GET_CHILD_RECURSIVELY(ctrlSet,'go_btn')
		local shortCut = TryGetProp(missionCls,'ShortCut'..i)
		if shortCut == nil or shortCut == 'None' then
			go_btn:SetEnable(0)
		else
			go_btn:SetEventScriptArgString(ui.LBUTTONUP, shortCut);
			go_btn:SetEventScriptArgNumber(ui.LBUTTONUP, (3 * currentpage) + i);
			go_btn:SetEnable(1)
		end
		local helpBtn = GET_CHILD_RECURSIVELY(ctrlSet,'question')
		local helpType = TryGetProp(missionCls,'HelpType'..i)
		local helpDesc = TryGetProp(missionCls,'Desc'..i, "None")
		local helpText = TryGetProp(missionCls,'HelpText'..i, "None")
		helpBtn:SetEventScriptArgNumber(ui.LBUTTONUP, helpType);
		helpBtn:SetEnable(1)
		if helpType == nil or helpType == 0 then
			if helpType == 0 and helpText ~="None" then
				helpBtn:SetEventScript(ui.LBUTTONUP, "None");
				helpBtn:SetTextTooltip(helpDesc.."{nl} {nl}"..helpText)
			else
				helpBtn:SetEnable(0)
			end
		end
		if clear == 'true' then
			clear_bg:ShowWindow(1);
			clear_bg:SetAlpha(REWARD_CLEAR_BG_ALPHA);
			clear_Pic:ShowWindow(1);

			if config.GetServiceNation() ~= 'KOR' then
				clear_Pic:SetImage("very_nice_stamp_eng");
			end
			local go_btn = GET_CHILD_RECURSIVELY(ctrlSet,'go_btn')
			go_btn:SetEnable(0)
			helpBtn:SetEnable(0)
		end
		local weekNum = TryGetProp(missionCls, "ArgNum"..i, 0);
		local comingsoon_Pic = GET_CHILD_RECURSIVELY(ctrlSet, 'comingsoon_Pic');
		comingsoon_Pic:ShowWindow(0);
		if weekNum ~= 0 then
			local isHidden = true
			if groupName == "REGULAR_EVENT_STAMP_TOUR" then
				isHidden = EVENT_STAMP_IS_VALID_WEEK(weekNum) == false
			elseif groupName == "EVENT_STAMP_TOUR_SUMMER" then
				local time = frame:GetUserValue("OPEN_TIME")
				if time == "" then
					isHidden = EVENT_STAMP_IS_VALID_WEEK_SUMMER(weekNum) == false or EVENT_STAMP_IS_HIDDEN_SUMMER(accObj,(3 * currentpage) + i) == true
				else
					time = imcTime.GetSysTimeByStr(time)
					isHidden = EVENT_STAMP_IS_VALID_WEEK_SUMMER(weekNum, time) == false or EVENT_STAMP_IS_HIDDEN_SUMMER(accObj,(3 * currentpage) + i) == true
				end				
			elseif groupName == "EVENT_STAMP_TOUR_CHRISTMAS" then
				isHidden = EVENT_STAMP_IS_VALID_CHRISTMAS(weekNum) == false
			end
			
			if isHidden == true then
				clear_bg:ShowWindow(1);
				clear_bg:SetAlpha(REWARD_CLEAR_BG_ALPHA);
				comingsoon_Pic:ShowWindow(1);
				go_btn:SetEnable(0)
				helpBtn:SetEnable(0)
				desc:SetTextByKey('value', ScpArgMsg("STAMP_TOUR_WEEK_MSG","week",weekNum));
				desc:EnableHitTest(0);
			end
			if EVENT_STAMP_IS_HIDDEN_SUMMER(accObj,(3 * currentpage) + i) == true then
				desc:SetTextByKey('value', ScpArgMsg("STAMP_TOUR_WEEK_HIDDEN_MSG","week",weekNum));
			end
		end
	end
end

function EVENT_STAMP_TOUR_MISSION_CLEAR_CHECK(frame, ctrl, nameSpace, argNum)
	if ui.CheckHoldedUI() == true then
		return;
	end
	local zoneName = GetZoneName()
	local mapCls = GetClass("Map",zoneName)
	if mapCls == nil or TryGetProp(mapCls,"MapType","None") ~= "City" then
		ui.SysMsg(ClMsg("AllowedInTown1"))
		return
	end
	for i = 0, AUTO_SELL_COUNT-1 do
		-- 뭐하나라도 true면 
		if session.autoSeller.GetMyAutoSellerShopState(i) == true then
			ui.SysMsg(ClMsg("StateOpenAutoSeller"))
			return
		end
	end
	frame = frame:GetTopParentFrame();
	local label_tab = GET_CHILD_RECURSIVELY(frame, 'label_tab');
	local currentpage = label_tab:GetSelectItemIndex();

	local groupName = frame:GetUserValue("GROUP_NAME")
	local missionCls = EVENT_STAMP_GET_CURRENT_MISSION(groupName,currentpage)
	local reward = TryGetProp(missionCls, "Reward"..argNum, "None")
	local rewardliststr = StringSplit(reward, '/');
	local checkProp = {'ShopTrade','TeamTrade','UserTrade','MarketTrade'}
	local isTradable = true
	local itemName = "None"
	for i = 1,#rewardliststr,2 do
		local itemTradable = false
		local item = GetClass("Item",rewardliststr[i])
		for j = 1,#checkProp do
			if TryGetProp(item,checkProp[j]) == "YES" then
				itemTradable = true
				break
			end
		end
		if itemTradable == false then
			itemName = item.Name
			isTradable = false
		end
	end
	local numvalue = ((3 * currentpage) + argNum);

	local maxCnt = false;
	local accObj = GetMyAccountObj();
	local nowCount = TryGetProp(accObj, "GODDESS_ROULETTE_COIN_ACQUIRE_COUNT");
	if GODDESS_ROULETTE_COIN_MAX_COUNT <= nowCount then
		maxCnt = true;
	end
	
	if isTradable == true and maxCnt == false then
		EVENT_STAMP_TOUR_MISSION_CLEAR(groupName, numvalue)
	else
		local msg = "";
		if maxCnt == true then
			msg = msg.."{nl}"..ScpArgMsg("AlreadyMaxEventCoinMsg");
		end

		if isTradable == false then
			msg = msg.."{nl} {nl}"..ScpArgMsg("STAMP_TOUR_TRADE_WARNING","item",itemName);
		end

		local yesScp = string.format("EVENT_STAMP_TOUR_MISSION_CLEAR(\"%s\",\"%d\")", groupName, numvalue);
		local msgBox = ui.MsgBox(msg, yesScp, "None");
		local yesBtn = GET_CHILD_RECURSIVELY(msgBox,"YES")
	end
end

function EVENT_STAMP_TOUR_MISSION_CLEAR(groupName,numvalue)
	ui.SetHoldUI(true);
	ReserveScript("ui.SetHoldUI(false)", 3);
	numvalue = string.format("%s %d",groupName,numvalue)
	pc.ReqExecuteTx("SCR_EVENT_STAMP_TOUR_CHECK", numvalue);
end

-- 보상 획득한 level 미션 블럭 UI 변경
function ON_EVENT_STAMP_TOUR_REWARD_GET(frame, msg, argstr, argnum)
	if frame:IsVisible() ~= 1 then
		return
	end
	local misson_gb = GET_CHILD_RECURSIVELY(frame, 'misson_gb');
	local label_tab = GET_CHILD_RECURSIVELY(frame, 'label_tab');
	local currentpage = label_tab:GetSelectItemIndex();

	local level = argnum;
	if currentpage >= 1 then
		level = argnum % (3 * currentpage);

		if level == 0 then
			level = 3;
		end
	end

	local misson_gb = GET_CHILD_RECURSIVELY(frame, 'misson_gb');
	local ctrlSet = GET_CHILD_RECURSIVELY(misson_gb, 'MISSIONBLOCK_'..level);
	ctrlSet = tolua.cast(ctrlSet, 'ui::CControlSet');

	local REWARD_CLEAR_BG_ALPHA = frame:GetUserConfig('REWARD_CLEAR_BG_ALPHA');
	
	local check_bg = GET_CHILD_RECURSIVELY(ctrlSet, 'check_bg');
	check_bg:ShowWindow(0);
	check_bg:EnableHitTest(0);

	-- 보상 획득
	local clear_bg = GET_CHILD_RECURSIVELY(ctrlSet, 'clear_bg');
	local clear_Pic = GET_CHILD_RECURSIVELY(ctrlSet, 'clear_Pic');
	clear_bg:ShowWindow(0);
	clear_Pic:ShowWindow(0);
	
	if config.GetServiceNation() ~= 'KOR' then
		clear_Pic:SetImage("very_nice_stamp_eng");
	end

	UI_PLAYFORCE(clear_Pic, "sizeUpAndDown");
	clear_bg:ShowWindow(1);
	clear_bg:SetAlpha(REWARD_CLEAR_BG_ALPHA);
	clear_Pic:ShowWindow(1);
	local go_btn = GET_CHILD_RECURSIVELY(ctrlSet,'go_btn')
	go_btn:SetEnable(0)

	label_tab:EnableHitTest(0);
	local funcName = string.format("HOLDTABUI_UNFREEZE('%s')",frame:GetName())
	ReserveScript(funcName, 2.5);
end

function HOLDTABUI_UNFREEZE(frameName)
	local frame = ui.GetFrame(frameName);
	local label_tab = GET_CHILD_RECURSIVELY(frame, 'label_tab');
	label_tab:EnableHitTest(1);
end

function ON_EVENT_STAMP_TOUR_GO_BUTTON_CLICK(parent,ctrl,argStr,argNum)
	local zoneName = GetZoneName()
	local mapCls = GetClass("Map",zoneName)
	if mapCls == nil or TryGetProp(mapCls,"MapType","None") ~= "City" then
		ui.SysMsg(ClMsg("AllowedInTown1"))
		return
	end
	for i = 0, AUTO_SELL_COUNT-1 do
		-- 뭐하나라도 true면 
		if session.autoSeller.GetMyAutoSellerShopState(i) == true then
			ui.SysMsg(ClMsg("StateOpenAutoSeller"))
			return
		end
	end

	if argStr == nil or argStr == "None" then
		return
	end
	local argList = StringSplit(argStr,'/')
	local type = argList[1]
	if type == 'ui' then
		local frameName = argList[2]
		ui.OpenFrame(frameName)
	elseif type == 'warp' then
		local frame = parent:GetTopParentFrame()
		local groupName = frame:GetUserValue("GROUP_NAME")
		local argList = string.format("%s %d",groupName,argNum)
		pc.ReqExecuteTx("SCR_EVENT_STAMP_TOUR_SHORTCUT", argList);
	elseif type == 'scp' then
		local Script = _G[argList[2]]
		Script()
	end
end

function ON_EVENT_STAMP_TOUR_HELP_CLICK(parent,ctrl,argStr,argNum)
	if argNum == nil or argNum == 0 then
		return
	end
	local piphelp = ui.GetFrame("piphelp");
	PIPHELP_MSG(piphelp, "FORCE_OPEN", argStr, argNum)
end

function SCR_EVENT_STAMP_OPEN_WEEKLY_BOSS_UI()
	local frame = ui.GetFrame('induninfo')
	frame:ShowWindow(1)
	INDUNINFO_UI_OPEN(frame, 3)
	INDUNINFO_TAB_CHANGE(frame)
end

function SCR_EVENT_STAMP_OPEN_GODDESS_MANAGER_UI(index)
	local frame = ui.GetFrame('goddess_equip_manager')
	frame:ShowWindow(1)

	local tab = GET_CHILD_RECURSIVELY(frame, "main_tab");
	tab:SelectTab(index);
	GODDESS_MGR_TAB_CHANGE(frame, tab)
end

function SCR_EVENT_STAMP_OPEN_GODDESS_REINFORCE_UI()
	SCR_EVENT_STAMP_OPEN_GODDESS_MANAGER_UI(0)
end

function SCR_EVENT_STAMP_OPEN_GODDESS_SOCKET_UI()
	SCR_EVENT_STAMP_OPEN_GODDESS_MANAGER_UI(2)
end

function SCR_EVENT_STAMP_OPEN_CABINET_UI(index)
	local frame = ui.GetFrame('item_cabinet')
	frame:ShowWindow(1)

	local tab = GET_CHILD_RECURSIVELY(frame, "cabinet_tab");
	tab:SelectTab(index);
	ITEM_CABINET_CHANGE_TAB(frame)
end

function SCR_EVENT_STAMP_OPEN_WEAPON_CABINET_UI()
	SCR_EVENT_STAMP_OPEN_CABINET_UI(0)
end

function SCR_EVENT_STAMP_OPEN_ARMOR_CABINET_UI()
	SCR_EVENT_STAMP_OPEN_CABINET_UI(1)
end

function SCR_EVENT_STAMP_OPEN_ACC_CABINET_UI()
	SCR_EVENT_STAMP_OPEN_CABINET_UI(3)
end

function SCR_EVENT_STAMP_OPEN_SKILL_GEM_CABINET_UI()
	SCR_EVENT_STAMP_OPEN_CABINET_UI(4)
end

function SCR_EVENT_STAMP_OPEN_ADVENTURE_BOOK_MAP()
	local frame = ui.GetFrame('adventure_book')
	frame:ShowWindow(1)
	local mainTab = GET_CHILD(frame, "mainTab")
	mainTab:SelectTab(0)
end

function SCR_EVENT_STAMP_OPEN_ADVENTURE_BOOK_ACHIEVE()
	local frame = ui.GetFrame('adventure_book')
	frame:ShowWindow(1)
	local mainTab = GET_CHILD(frame, "mainTab")
	mainTab:SelectTab(0)
	local gb_adventure = GET_CHILD(frame, "gb_adventure");
	local tab = GET_CHILD(gb_adventure, "bookmark");
	tab:SelectTab(7);
end

function SCR_EVENT_STAMP_OPEN_INDUNINFO_DIVISION()
	local frame = ui.GetFrame("induninfo")
	frame:ShowWindow(1)
	INDUNINFO_UI_OPEN(frame, 1, "Challenge_Division_Auto_1")
end

function SCR_EVENT_STAMP_OPEN_INDUNINFO_CHALLENGE()
	local frame = ui.GetFrame("induninfo")
	frame:ShowWindow(1)
	INDUNINFO_UI_OPEN(frame, 1, "Challenge_Auto_Hard_Party")
end

function SCR_EVENT_STAMP_OPEN_INDUNINFO_MYSTIC()
	local frame = ui.GetFrame("induninfo")
	frame:ShowWindow(1)
	local pattern_info = mythic_dungeon.GetPattern(mythic_dungeon.GetCurrentSeason())
	local mapCls = GetClassByType("Map",pattern_info.mapID)
	INDUNINFO_UI_OPEN(frame, 2, TryGetProp(mapCls,"ClassName"))
end

function SCR_EVENT_STAMP_OPEN_INDUNINFO_TOSHERO()
	local frame = ui.GetFrame("induninfo")
	frame:ShowWindow(1)
	INDUNINFO_UI_OPEN(frame, 1, "TOSHero")
end

function SCR_EVENT_STAMP_OPEN_INDUNINFO_BERNIKE()
	local frame = ui.GetFrame("induninfo")
	frame:ShowWindow(1)
	INDUNINFO_UI_OPEN(frame, 1, "Solo_dungeon")
end

function SCR_EVENT_STAMP_PVP()
	local frame = ui.GetFrame("induninfo")
	frame:ShowWindow(1)
	INDUNINFO_UI_OPEN(frame, 6)
	INDUNINFO_TAB_CHANGE(frame)
end

function SCR_EVENT_STAMP_OPEN_GEN_REINFORCE_UI()
	control.RestSit()
	local frame = ui.GetFrame("reinforce_by_mix")
	frame:ShowWindow(1)
end