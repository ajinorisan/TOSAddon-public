function BOUNTYHUNT_MILESTONE_ON_INIT(addon, frame)
	addon:RegisterMsg('BOUNTYHUNT_MILESTONE_OPEN', 'BOUNTYHUNT_MILESTONE_OPEN');
	addon:RegisterMsg('BOUNTYHUNT_MILESTONE_CLOSE', 'BOUNTYHUNT_YESSCP_EXITMSGBOX');
end

function BOUNTYHUNT_MILESTONE_OPEN(frame, msg, strarg, numarg)
	if numarg == 0 then return end

	local mapId = tonumber(numarg)

    ui.OpenFrame("bountyhunt_milestone");

    local frame = ui.GetFrame("bountyhunt_milestone");
    if frame == nil then return end

	CHASEINFO_CLOSE_FRAME()

    local frame = ui.GetFrame("bountyhunt_milestone");
    if frame ~= nil then

		local time = GET_CHILD_RECURSIVELY(frame, 'quest_object_text')
		BOUNTYHUNT_MILSTONE_FILL_QUEST_INFO(frame, mapId)
    end

    frame:Invalidate()

end

function BOUNTYHUNT_MILSTONE_FILL_QUEST_INFO(frame, mapId)
    if frame == nil then return end

	local pc = GetMyPCObject()
	local etcObj = GetMyEtcObject(pc)
	if etcObj == nil then return end

    local limitTime = 1800000

    local gbox_questInfo = GET_CHILD_RECURSIVELY(frame, "gbox_quest_info");
    if gbox_questInfo ~= nil then
        local ctrlSet = gbox_questInfo:CreateOrGetControlSet("suddenquest_info", "CTRLSET_SUDDENQUEST_INFO", 0, 0);
           
        if ctrlSet ~= nil then
            local gbox_questDetailed = GET_CHILD_RECURSIVELY(ctrlSet, "gbox_quest_detailed");
            if gbox_questDetailed ~= nil then
                local detailedText =  GET_CHILD_RECURSIVELY(gbox_questDetailed, "quest_detailed_text");

                local mapName = '{@st70_m_16}{s19}'..GET_MAP_NAME(mapId)..'{/}{/}'
                local questText = ClMsg("BountyHuntStart");
                local missionText = "";

                detailedText:SetTextByKey("mapName", mapName);
                detailedText:SetTextByKey("quest_text", questText);
                detailedText:SetTextByKey("quest_mission", missionText);
                detailedText:SetTextAlign("center", "center");
                
                local deatiledText_Notice = GET_CHILD_RECURSIVELY(gbox_questDetailed, "quest_notice_text");
                local noticeText_1 = ClMsg("BountyHuntNotice1");
                deatiledText_Notice:SetTextByKey("quest_notice1", noticeText_1);
                deatiledText_Notice:SetTextAlign("center", "center");
            end
        end
    end

    local gbox_questtimer = GET_CHILD_RECURSIVELY(frame, "gbox_quest_timer");
    if gbox_questtimer ~= nil then
        local textTimer = GET_CHILD_RECURSIVELY(gbox_questtimer, "bountyhunt_milestone_timer");
        textTimer:SetUserValue("BOUNTY_LIMIT_TIME", limitTime);
		textTimer:SetUserValue("BOUNTY_REMAIN_TIME", 0);
    end

	BOUNTYHUNT_TIME_UPDATE()

    frame:Invalidate();
end

function BOUNTYHUNT_TIME_UPDATE(ctrl)

    local frame = ui.GetFrame("bountyhunt_milestone");
    if frame == nil then return; end

    local gbox_questtimer = GET_CHILD_RECURSIVELY(frame, "gbox_quest_timer");
    if gbox_questtimer ~= nil then
        local textTimer = GET_CHILD_RECURSIVELY(gbox_questtimer, "bountyhunt_milestone_timer");
        if textTimer ~= nil then
            local limitTime = tonumber(textTimer:GetUserValue("BOUNTY_LIMIT_TIME"));

            if limitTime == nil then return; end

			local buff = info.GetBuff(session.GetMyHandle(), 17082)
			if buff == nil then return end 

			local curTime = buff.time / 1000

            if curTime < 0 then
                BOUNTYHUNT_YESSCP_EXITMSGBOX();
                return;
            end

            local min = math.floor(curTime / 60);
            local sec = curTime % 60;
            local timeStr = string.format("%d:%02d", min, sec);
            textTimer:SetTextByKey("time", timeStr);

            local timeGauge = GET_CHILD_RECURSIVELY(frame, "bountyhunt_milestone_timegauge");
            if timeGauge ~= nil then
                timeGauge:SetMaxPointWithTime(curTime, limitTime / 1000, 0.1, 1);
            end

        end
    end
end

function BOUNTYHUNT_MILESTONE_CLOSE_BTN(frame)
    local yesScp = string.format("BOUNTYHUNT_YESSCP_EXITMSGBOX()");
    ui.MsgBox(ScpArgMsg("BountyHuntExit"), yesScp, "None");
end

function BOUNTYHUNT_YESSCP_EXITMSGBOX()
    local frame = ui.GetFrame("bountyhunt_milestone");
    if frame ~= nil then
	    
	    BOUNTYHUNT_MILESTONE_RESET();
	
		packet.ReqRemoveBuff(17082)
	
	    ui.CloseFrame("bountyhunt_milestone")
	
		CHASEINFO_OPEN_FRAME()
	end
end

function BOUNTYHUNT_MILESTONE_RESET()
    local frame = ui.GetFrame("bountyhunt_milestone");
    if frame == nil then return end

    local gbox_questInfo = GET_CHILD_RECURSIVELY(frame, "gbox_quest_info");
    if gbox_questInfo ~= nil then
        local cnt = gbox_questInfo:GetChildCount();
        for i = 0, cnt - 1 do
            local child = gbox_questInfo:GetChildByIndex(i);
            if child ~= nil and string.find(child:GetName(), "CTRLSET_") then
                frame:RemoveChild(child:GetName());
                frame:Invalidate();
            end
        end
    end 

    frame:SetVisible(0);

    local timeGauge = GET_CHILD_RECURSIVELY(frame, "bountyhunt_milestone_timegauge");
    timeGauge:SetMaxPointWithTime(0,0,0.1,0.5)

    ui.CloseFrame("bountyhunt_milestone");
end

function UPDATE_BOUNTYHUNT_MON_MARK(monhandle, x, y, z, isAlive, MonRank)
    if isAlive == 1 and MonRank == 'Normal' then
        session.minimap.AddIconInfo(monhandle, "trasuremapmark", x, y, z, ClMsg('BountyMonMark'), true, nil, 1);
    elseif isAlive == 1 and MonRank == 'Boss' then
        session.minimap.AddIconInfo(monhandle, "trasuremapmark", x, y, z, ClMsg('BountyBossMark'), true, nil, 2);
	else
		session.minimap.RemoveIconInfo(monhandle);
	end
end