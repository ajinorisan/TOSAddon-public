function EVENT_STAMP_TOUR_CHRISTMAS_ON_INIT(addon, frame)
	addon:RegisterMsg("EVENT_STAMP_TOUR_UI_OPEN_COMMAND_CHRISTMAS", "ON_EVENT_STAMP_TOUR_UI_OPEN_COMMAND_CHRISTMAS");
	addon:RegisterMsg("EVENT_STAMP_TOUR_REWARD_GET", "ON_EVENT_STAMP_TOUR_REWARD_GET");
end

function ON_EVENT_STAMP_TOUR_UI_OPEN_COMMAND_CHRISTMAS(_,msg,argStr,argNum)
	--EVENT_2112
	local frame = ui.GetFrame("event_stamp_tour_christmas")
	frame:SetUserValue("GROUP_NAME","EVENT_STAMP_TOUR_CHRISTMAS")
	frame:SetUserValue("OPEN_TIME",argStr)
	ui.OpenFrame("event_stamp_tour_christmas");
end