

function MYTHIC_DUNGEON_HUD_ON_INIT(addon, frame)
	addon:RegisterMsg('MYTHIC_DUNGEON_HUD_INFO_INIT', 'ON_MYTHIC_DUNGEON_HUD_INFO_INIT')
	addon:RegisterMsg('MYTHIC_DUNGEON_HUD_TIMER_INIT', 'ON_MYTHIC_DUNGEON_HUD_TIMER_INIT')
	addon:RegisterMsg('MYTHIC_DUNGEON_HUD_PATTERN_INIT', 'ON_MYTHIC_DUNGEON_HUD_PATTERN_INIT')
	addon:RegisterMsg('REFRESH_MYTHIC_DUNGEON_HUD', 'ON_MYTHIC_DUNGEON_HUD_PROGRESS_UPDATE')
	addon:RegisterMsg('MYTHIC_DUNGEON_HUD_TIMER_UPDATE', 'ON_MYTHIC_DUNGEON_HUD_TIMER_UPDATE')
	
end

function MYTHIC_UI_OPEN()
	mythic_dungeon.RequestCurrentSeason();
end
function ON_MYTHIC_DUNGEON_HUD_INFO_INIT(frame,msg,argStr,argNum)	
	local indun_cls = GetClass("Indun",argStr)
	MYTHIC_DUNGEON_HUD_TITLE_INIT(frame,indun_cls)
	MYTHIC_DUNGEON_HUD_PROGRESS_INIT(frame)
	frame:ShowWindow(1)
end

function MYTHIC_DUNGEON_HUD_TITLE_INIT(frame,indun_cls)
	local title_text = GET_CHILD_RECURSIVELY(frame,"title_text")
	title_text:SetTextByKey("stage",indun_cls.Name)
end

function MYTHIC_DUNGEON_HUD_PROGRESS_INIT(frame)
	local progress_box = GET_CHILD_RECURSIVELY(frame,"progress_box")
	local progress_percent = GET_CHILD_RECURSIVELY(progress_box,"progress_percent")
	local progress_gauge = GET_CHILD_RECURSIVELY(progress_box,"progress_gauge")
	progress_percent:SetTextByKey("percent",0)
	progress_gauge:SetPoint(0,100)
end

function ON_MYTHIC_DUNGEON_HUD_TIMER_INIT(frame,msg,now_time,total_time)
	now_time = tonumber(now_time)
	local end_time = now_time + total_time

	local remaintime_box = GET_CHILD_RECURSIVELY(frame,"remaintime_box")
	local remaintime_value = GET_CHILD_RECURSIVELY(remaintime_box,"remaintime_value")
    local remaintime_gauge = GET_CHILD_RECURSIVELY(remaintime_box,"remaintime_gauge")
	
	local min = string.format("%02d",total_time/60)
	local sec = string.format("%02d",total_time%60)

    remaintime_value:SetTextByKey('min',min)
    remaintime_value:SetTextByKey('sec',sec)
	remaintime_gauge:SetPoint(total_time, total_time);
	
	remaintime_box:SetUserValue("NOW_TIME",now_time)
	remaintime_box:SetUserValue("END_TIME",end_time)
	
	
    remaintime_box:RunUpdateScript("MYTHIC_DUNGEON_HUD_TIMER_UPDATE", 0.1);
end

function MYTHIC_DUNGEON_HUD_TIMER_UPDATE(ctrl,totalTime,elapsedTime)
	local now_time = ctrl:GetUserValue("NOW_TIME") + elapsedTime

	local end_time = ctrl:GetUserValue("END_TIME")
	local remain_time = math.max(end_time - now_time,0)

	local remaintime_value = GET_CHILD_RECURSIVELY(ctrl,"remaintime_value")
	local remaintime_gauge = GET_CHILD_RECURSIVELY(ctrl,"remaintime_gauge")

	local min = string.format("%02d",remain_time/60)
	local sec = string.format("%02d",remain_time%60)

	remaintime_value:SetTextByKey('min',min)
	remaintime_value:SetTextByKey('sec',sec)

	remaintime_gauge:SetPoint(math.floor(remain_time), remaintime_gauge:GetMaxPoint());
	ctrl:SetUserValue("NOW_TIME",now_time)

	return 1 + BoolToNumber(remain_time == 0)
end

function ON_MYTHIC_DUNGEON_HUD_TIMER_UPDATE(frame,msg,now_time,end_time)
	local remaintime_box = GET_CHILD_RECURSIVELY(frame,"remaintime_box")
	remaintime_box:SetUserValue("END_TIME",end_time)
	remaintime_box:SetUserValue("NOW_TIME",tonumber(now_time))
end

function ON_MYTHIC_DUNGEON_HUD_PATTERN_INIT(frame,msg,argStr,argNum)
	local pattern_box = GET_CHILD_RECURSIVELY(frame,"pattern_icon_box")
	local patternID_list = StringSplit(argStr,'/')
	local size = 30
	pattern_box:RemoveAllChild()
	for i = 1,#patternID_list do
		local pattern = GetClassByType("boss_pattern",patternID_list[i])
		local x = 33*((i-1)%5) + 7
		local y = 33*math.floor((i-1)/5) + 6
		local pic = pattern_box:CreateControl("picture","name"..i,x,y,size,size)
		AUTO_CAST(pic)
		pic:SetTextTooltip(pattern.ToolTip)
		pic:SetEnableStretch(1)
		pic:SetImage("icon_"..pattern.Icon)
	end
	local height_resize = math.floor((#patternID_list-1)/5) * 33
	pattern_box:Resize(pattern_box:GetWidth(),pattern_box:GetOriginalHeight()+height_resize)

	local parent = pattern_box
	while parent ~= nil do
		parent:Resize(parent:GetWidth(),parent:GetOriginalHeight()+height_resize)
		parent = parent:GetParent()
	end
end

function ON_MYTHIC_DUNGEON_HUD_PROGRESS_UPDATE(frame,msg,argStr,argNum)
	local progress_box = GET_CHILD_RECURSIVELY(frame,"progress_box")
	local progress_percent = GET_CHILD_RECURSIVELY(progress_box,"progress_percent")
	local progress_gauge = GET_CHILD_RECURSIVELY(progress_box,"progress_gauge")

	progress_percent:SetTextByKey("percent",argNum)
	progress_gauge:SetPoint(argNum,100)
end