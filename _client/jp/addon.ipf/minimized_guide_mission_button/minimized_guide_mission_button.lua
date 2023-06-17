function MINIMIZED_GUIDE_MISSION_BUTTON_ON_INIT(addon, frame)
	frame:ShowWindow(0)
	-- addon:RegisterMsg('GAME_START', 'MINIMIZED_GUIDE_MISSION_BUTTON_INIT')
end

function MINIMIZED_GUIDE_MISSION_BUTTON_INIT(frame, msg, arg_str, arg_num)
	MINIMIZED_GUIDE_MISSION_ON_MSG(frame, msg, arg_str, arg_num)
	local aObj = GetMyAccountObj()
	local isStart = TryGetProp(aObj, "GUIDE_QUEST_START", 0)

	local curmapname = session.GetMapName();
	local mapprop = geMapTable.GetMapProp(curmapname);
	local mapname = mapprop:GetClassName();


	if isStart == 0 then
		frame:ShowWindow(1)
		local noticeBallon = MAKE_BALLOON_FRAME(ScpArgMsg("GuideQuestNotice"), 0, 0, nil, "GuideQuestNoticeBalloon", nil, nil, 0);
		local margin = frame:GetMargin();
		local x = margin.right;
		local y = margin.top;
		x = x + 70;
		y = y - 25;
		noticeBallon:SetGravity(ui.RIGHT, ui.TOP);
		noticeBallon:SetMargin(0, y, x, 0);
		noticeBallon:SetLayerLevel(60);
		noticeBallon:ShowWindow(1);
	else
		if GUIDE_QUEST_IS_ALL_CLEAR(aObj) == false then
			frame:ShowWindow(1)
		end
	end
end

function MINIMIZED_GUIDE_MISSION_ON_MSG(frame, msg, arg_str, arg_num)
	if frame:IsVisible() ~= 1 then return end

	if msg =='GAME_START' then
		MINIMIZED_GUIDE_MISSTION_NOTICE(frame)
	end
end

function MINIMIZED_GUIDE_MISSTION_NOTICE(frame)
	local reward = GUIDE_QUEST_CHECK_RECEIVABLE_REWARD(GetMyAccountObj())
	local notice = GET_CHILD_RECURSIVELY(frame, 'notice_bg')    

	if reward == true then
		notice:ShowWindow(1)
	else
		notice:ShowWindow(0)
	end
end


function MINIMIZED_GUIDE_MISSION_BUTTON_CLICK(parent, ctrl)
	ui.ToggleFrame('guide_quest')
	ui.CloseFrame("GuideQuestNoticeBalloon")
end
