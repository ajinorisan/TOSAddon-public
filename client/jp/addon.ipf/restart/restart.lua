function RESTART_ON_INIT(addon, frame)
    addon:RegisterMsg('RESTART_WAIT', 'RESTART_ON_MSG');
    addon:RegisterMsg('RESTART_WAIT_END', 'RESTART_ON_MSG');
 	addon:RegisterMsg('RESTART_HERE', 'RESTART_ON_MSG');
	addon:RegisterMsg('RESTARTSELECT_UP', 'RESTART_ON_MSG');
	addon:RegisterMsg('RESTARTSELECT_DOWN', 'RESTART_ON_MSG');
	addon:RegisterMsg('RESTARTSELECT_SELECT', 'RESTART_ON_MSG');
end

function RESTART_ON_RESSURECT_SAVE_POINT(frame)
	local fsmActor = GetMyActor();
	if fsmActor:IsDead() == 0 then
		return
	end
	restart.SendRestartSavePointMsg();
end

function RESTART_ON_RESSURECT_HERE(frame)
	if frame == nil or frame:IsVisible() == 0 then 
		return; 
	end

	local cristal = GetClass("Item", "RestartCristal");
	local cristal_14d = GetClass("Item", "RestartCristal_14d");
	local cristal_recycle = GetClass("Item", "RestartCristal_Recycle");
	local item = session.GetInvItemByName(cristal.ClassName);

	local item_14d = nil
	if cristal_14d ~= nil then
		item_14d = session.GetInvItemByName(cristal_14d.ClassName);
	end
	
	local item_recycle = nil
	if cristal_recycle ~= nil then
		item_recycle = session.GetInvItemByName(cristal_recycle.ClassName);
	end
   
	if (item == nil) and (item_14d == nil) and (item_recycle == nil) then
		ui.SysMsg(ScpArgMsg("NotEnough{ItemName}Item","ItemName", cristal.Name));
		return;
	end
	restart.SendRestartHereMsg();
end

function RESTART_ON_RESSURECT_HERE_MYSTIC(frame)
end

function RESTART_ON_RESSURECT_MAINLAYER(frame)
	restart.SendRestartMainLayerMsg();
end

function RESTART_ON_RESSURECT_BORUTA_RVRRAID(frame)
	restart.SendRestartBorutaRaid();
end

function RESTART_ON_RESSURECT_ABANDON(frame)
	restart.SendRestartRetry();
	frame:ShowWindow(0);
end

function RESTART_ON_RESSURECT_RETRY(frame)
	restart.Send(5);
	frame:ShowWindow(0);
end

function RESTART_ON_COLONY_WAR_RETURN_CITY(frame)
	restart.Send(12);
	frame:ShowWindow(0);
end

function RESTART_ON_RAID_RETURN(frame)
	restart.ReqReturn();
	frame:ShowWindow(0);
end

function MOVE_TO_CAMP_WHEN_DED(frame, control, aid)
	local fsmActor = GetMyActor();
	if fsmActor:IsDead() == 0 then
		return
	end
	restart.SendRestartCampMsg(aid);
end

local cacheCommandBtnList = nil
function AUTORESIZE_RESTART(frame)
	
	cacheCommandBtnList = nil
	local maxy = 0;
	local cnt = frame:GetChildCount();
	local ctrly = 100;
	local ctrlHight = 0;
	local ctrloffsetY = 0;
	for i = 0 , cnt - 2 do
		local ctrl = frame:GetChildByIndex(i);
		local ctrlname = ctrl:GetName();
		if ctrl:IsVisible() == 1 and string.find(ctrlname, "btn") ~= nil then
			ctrl:SetOffset(ctrl:GetOffsetX(), ctrly);			
			ctrly = ctrly + ctrl:GetHeight() + 5;

			if 0 == ctrlHight then
				ctrlHight = ctrl:GetHeight();
				ctrloffsetY = ctrl:GetOffsetY();
			end

			local y = ctrl:GetOffsetY() + ctrl:GetHeight();
			if y > maxy then
				maxy = y;
			end
		end
	end

	local list = session.party.GetPartyMemberList(PARTY_NORMAL);
	local count = list:Count();
	local campGroup = frame:GetChild("campGroup");
	if nil == campGroup then
		return;
	end
	campGroup:RemoveAllChild();	
	campGroup:SetOffset(campGroup:GetX(), ctrly);

	if GetExProp(GetMyPCObject(), 'BOUNTYHUNT_PLAYING') == 1 then
		frame:Resize(frame:GetWidth(), maxy + 40);
		return;
	end

	-- 파티원이 존재 할 때
	if 0 < count then
		local groupBoxHeight = campGroup:GetHeight()
		local y = 0;
		for i = 0 , count - 1 do
			local partyMemberInfo = list:Element(i);
			if partyMemberInfo.campMapID ~= 0 then
				local map = GetClassByType("Map", partyMemberInfo.campMapID);
				if nil ~= map then
					
					local str = string.format("%s %s", map.Name,ClMsg("MoveToCamp"));
					local shareBtn = campGroup:CreateControl("button", "party"..i, 0, y, campGroup:GetWidth(), ctrlHight);
					y = y + ctrlHight;
					maxy = maxy + ctrlHight;
					groupBoxHeight = groupBoxHeight + ctrlHight
					shareBtn = tolua.cast(shareBtn, "ui::CButton");
					shareBtn:SetText("{@st66b}".. str);
					shareBtn:SetEventScript(ui.LBUTTONUP, "MOVE_TO_CAMP_WHEN_DED");
					shareBtn:SetEventScriptArgString(ui.LBUTTONUP, partyMemberInfo:GetAID());
					shareBtn:SetSkinName("test_pvp_btn");
				end
			end
		end
		campGroup:Resize(campGroup:GetWidth(),groupBoxHeight )
		frame:Resize(frame:GetWidth(), maxy + 40);
		return;
	end
	
	local mapID = session.loginInfo.GetSquireMapID();
	local map = GetClassByType("Map", mapID);
	if nil == map then
		frame:Resize(frame:GetWidth(), maxy + 40);
		return;
	end

	local str = string.format("%s %s", map.Name,ClMsg("MoveToCamp"));
	local shareBtn = campGroup:CreateControl("button", "myCamp", 0, 0, campGroup:GetWidth(), ctrlHight);
	shareBtn = tolua.cast(shareBtn, "ui::CButton");
	shareBtn:SetEventScript(ui.LBUTTONUP, "MOVE_TO_CAMP_WHEN_DED");
	shareBtn:SetText("{@st66b}".. str);
	shareBtn:SetEventScriptArgString(ui.LBUTTONUP, session.loginInfo.GetAID());
	shareBtn:SetSkinName("test_pvp_btn");

	maxy = maxy + ctrlHight;
	frame:Resize(frame:GetWidth(), maxy + 40);
end


function RESTART_GET_COMMAND_LIST(frame)

	if cacheCommandBtnList == nil then
		cacheCommandBtnList={}
		-- 목록 만들기
		local cacheCnt =0 
		local index =1
		while 1 do
			local btnName = "restart" .. index .. "btn";
			local child = frame:GetChild(btnName);
			if child == nil then
				break;
			end
			--활성화 상태인 것만 넣기
			if child:IsVisible() == 1 then 
				cacheCommandBtnList[cacheCnt] = btnName
				cacheCnt = cacheCnt + 1
			end
			index = index +1
		end

	
		local campGroup = frame:GetChild("campGroup");
		if nil ~= campGroup then
			local cnt = campGroup:GetChildCount();
			for i = 0, cnt - 1 do
				local btn = campGroup:GetChildByIndex(i);
				local btnName = btn:GetName()
				if btnName ~= "_SCR" then
					cacheCommandBtnList[cacheCnt] = btnName
					cacheCnt = cacheCnt + 1
				end
			end
		end
	end
	return cacheCommandBtnList
end


function RESTART_MOVE_INDEX(frame, isDown)
	local list = RESTART_GET_COMMAND_LIST(frame)
	local restartSelect_index = frame:GetValue();

	
	restartSelect_index = restartSelect_index + isDown;
	local ItemBtn = frame:GetChildRecursively(list[restartSelect_index]);
	if ItemBtn == nil then
		return
	end

	frame:SetValue(restartSelect_index);
end

function RESTART_ON_MSG(frame, msg, argStr, argNum)
	local minigameover = ui.GetFrame('minigameover');	
	if minigameover:IsVisible() == 1 then
		return;
	end

    if msg == 'RESTART_HERE' then
		for i = 1 , 5 do
			local btnName = "restart" .. i .. "btn";
			local resButtonObj	= GET_CHILD(frame, btnName, 'ui::CButton');
			local isBit = BitGet(argNum, i);
			resButtonObj:ShowWindow(isBit);
		end

		-- 보루타 부활용
		local returnCityBtn = GET_CHILD(frame, "restart9btn", "ui::CButton");
		returnCityBtn:ShowWindow(0);
		if BitGet(argNum, 16) == 1 then
			frame:RunUpdateScript("BORUTA_RVRRAID_RESTART_UPDATE", 1, 0, 0, 1);
			frame:SetUserValue("COUNT", 30);
			returnCityBtn:ShowWindow(1);
		end

		--콜로니전 부활용
		local resButtonObj	= GET_CHILD(frame, "restart6btn", 'ui::CButton');
		resButtonObj:ShowWindow(0);
		if 1 == BitGet(argNum, 12) then
			local btnName = "restart6btn";
			local resButtonObj	= GET_CHILD(frame, btnName, 'ui::CButton');
			resButtonObj:ShowWindow(1);
		end

		local resButtonObj	= GET_CHILD(frame, "restart8btn", 'ui::CButton');
		resButtonObj:ShowWindow(0);
		if 1 == BitGet(argNum, 14) then
			resButtonObj:ShowWindow(1);
			COLONY_WAR_RESTART_BY_MYSTIC_UPDATE(frame);
		end

		if 1 == BitGet(argNum, 12) or 1 == BitGet(argNum, 14) then
			frame:RunUpdateScript("COLONY_WAR_RESTART_UPDATE",1,0,0,1);
			frame:SetUserValue("COUNT", 30);
		end

		-- 길드 타워
		local resButtonObj	= GET_CHILD(frame, "restart7btn", 'ui::CButton');
		resButtonObj:ShowWindow(0);
		if 1 == BitGet(argNum, 13) then
			local btnName = 'restart7btn';
			local resButtonObj	= GET_CHILD(frame, btnName, 'ui::CButton');
			if IS_EXIST_GUILD_TOWER() == true then
				resButtonObj:ShowWindow(1);			
			end
		end

		-- 레이드 부활
		local map = GetClass('Map', session.GetMapName());
		local keyword = TryGetProp(map, 'Keyword', 'None');
		local keyword_table = StringSplit(keyword, ';');
		if table.find(keyword_table, 'MythicMap') > 0 then
			local restart10btn = GET_CHILD(frame, "restart10btn", "ui::CButton");
			if restart10btn ~= nil then
				restart10btn:ShowWindow(0);
			end
		elseif IsRaidField() == 1 or IsRaidMap() == 1 then
			if argNum == 6 then
				local restart1btn = GET_CHILD(frame, "restart1btn", "ui::CButton");
				if restart1btn ~= nil then
					restart1btn:ShowWindow(0);
				end

				-- start point restart
				local use_start_point = 1;
				if argStr ~= "" then
					local restart_class = GetClass("resurrect_return_control", argStr);
					if restart_class ~= nil then
						use_start_point = TryGetProp(restart_class, "StartPoint", 1);
					end
				end

				local restart10btn = GET_CHILD(frame, "restart10btn", "ui::CButton");
				if restart10btn ~= nil then
					if use_start_point == 1 then
						restart10btn:ShowWindow(1);
					else
						restart10btn:ShowWindow(0);
					end
				end

				-- return city restart
				local use_save_point = 0;
				if argStr ~= "" then
					local restart_class = GetClass("resurrect_return_control", argStr);
					if restart_class ~= nil then
						use_save_point = TryGetProp(restart_class, "SavePoint", 0);
					end
				end

				local restart1btn = GET_CHILD(frame, "restart1btn", "ui::CButton");
				if restart1btn ~= nil then
					if use_save_point == 1 then
						restart1btn:ShowWindow(1);
					else
						restart1btn:ShowWindow(0);
					end
				end
			end
		else
			local restart10btn = GET_CHILD(frame, "restart10btn", "ui::CButton");
			if restart10btn ~= nil then
				restart10btn:ShowWindow(0);
			end
		end

        AUTORESIZE_RESTART(frame);
        RESTART_WAIT_STOP();
		frame:ShowWindow(1);
	elseif msg == 'RESTARTSELECT_UP' then
		RESTART_MOVE_INDEX(frame, -1);
		RESTARTSELECT_ITEM_SELECT(frame)
	elseif msg == 'RESTARTSELECT_DOWN' then
		RESTART_MOVE_INDEX(frame, 1);
		RESTARTSELECT_ITEM_SELECT(frame)
	elseif msg == 'RESTARTSELECT_SELECT' then
		local list = RESTART_GET_COMMAND_LIST(frame)
		local restartSelect_index = frame:GetValue();
		local ItemBtn = frame:GetChildRecursively(list[restartSelect_index]);
		local scp = ItemBtn:GetEventScript(ui.LBUTTONUP);
		local argString = ItemBtn:GetEventScriptArgString(ui.LBUTTONUP);
		scp = _G[scp];
        scp(frame, ItemBtn,argString );
    elseif msg == 'RESTART_WAIT' then
		for i = 1, 10 do
			local btn = GET_CHILD(frame, "restart"..i.."btn", 'ui::CButton');
            btn:ShowWindow(0);
        end
        local text = GET_CHILD(frame, "restart_wait", 'ui::CRichText');
        text:ShowWindow(1);
        text:SetTextByKey("sec", argNum);
        AddUniqueTimerFunccWithLimitCount("RESTART_WAIT_UPDATE", 1000, argNum);
    elseif msg == 'RESTART_WAIT_END' then
        RemoveLuaTimerFunc("RESTART_WAIT_UPDATE")
	end
end

function RESTART_WAIT_UPDATE()
    local frame = ui.GetFrame("restart")
    if frame == nil then
        return
    end

    frame:ShowWindow(1)
    frame:Resize(frame:GetWidth(), 160)

    local text = GET_CHILD(frame, "restart_wait", 'ui::CRichText')
    if text == nil then
        return
    end

    local sec = tonumber(text:GetTextByKey("sec"))
    if sec == 0 then
        return
    end

    text:SetTextByKey("sec", sec - 1)
end

function RESTART_WAIT_STOP()
    local frame = ui.GetFrame("restart")
    if frame == nil then
        return
    end

    local text = GET_CHILD(frame, "restart_wait", 'ui::CRichText')
    if text == nil then
        return
    end

    RemoveLuaTimerFunc('RESTART_WAIT_UPDATE')
    text:ShowWindow(0)
end

function RESTARTSELECT_ITEM_SELECT(frame)
	if frame == nil then return; end
	if frame:IsVisible() == 0 then return; end

	local list = RESTART_GET_COMMAND_LIST(frame)
	local restartSelect_index = frame:GetValue();
	local ItemBtn = frame:GetChildRecursively(list[restartSelect_index]);
	if ItemBtn == nil then return; end
	
	local x, y = GET_SCREEN_XY(ItemBtn);
	mouse.SetPos(x,y);
	mouse.SetHidable(0);
end

function COLONY_WAR_RESTART_BY_MYSTIC_UPDATE(frame)
	local btn = GET_CHILD(frame, "restart8btn");
	AUTO_CAST(frame)

	local mysticItem = nil	
	if mysticItem == nil then
		btn:ShowWindow(0);
		AUTORESIZE_RESTART(frame);
		return;
	elseif mysticItem ~= nil and btn:IsVisible() ~= 1 then
		btn:ShowWindow(1);
		AUTORESIZE_RESTART(frame);
	end

	local isCoolTime = 0;
	local ms = item.GetCoolDown(mysticItem.type);
	if ms > 0 then
		isCoolTime = 1;
	end
	
	local style = frame:GetUserConfig("MysticCristalStyleOn");
	local text = "";
	local isEnable = 1;
	if isCoolTime == 1 then
		if ms > 60000 then
			text = ScpArgMsg("Min{n}", "n", math.floor(ms/60000));
		else
			text = ScpArgMsg("Sec{n}", "n", math.floor(ms/1000));
		end
		text = " ("..text..")";
		isEnable = 0;
		style = frame:GetUserConfig("MysticCristalStyleOff");
	end
	btn:SetTextByKey("style", style);
	btn:SetTextByKey("value", text);
	btn:SetEnable(isEnable)
	btn:EnableTextColorTone(false);
end

function COLONY_WAR_RESTART_UPDATE(frame)
	local btnName = "restart6btn";
	local resButtonObj	= GET_CHILD(frame, btnName, 'ui::CButton');
	local sec = frame:GetUserIValue("COUNT")
	frame:SetUserValue("COUNT",  sec - 1);
	local text = "{@st66b}"..ScpArgMsg("ReturnCity{SEC}", "SEC", sec).."{/}"
	resButtonObj:SetText(text);

	COLONY_WAR_RESTART_BY_MYSTIC_UPDATE(frame);
	return 1;
end

function BORUTA_RVRRAID_RESTART_UPDATE(frame)
	local btnName = "restart9btn";
	local resButtonObj	= GET_CHILD(frame, btnName, 'ui::CButton');
	local sec = frame:GetUserIValue("COUNT")
	frame:SetUserValue("COUNT",  sec - 1);
	local text = "{@st66b}"..ScpArgMsg("TableLand_ReturnCity{SEC}", "SEC", sec).."{/}"
	resButtonObj:SetText(text);
	return 1;
end

function RESTART_ON_GUILD_TOWER(frame)
	if IS_EXIST_GUILD_TOWER() == false then
		return;
	end
	restart.SendRestartGuildTower();
end