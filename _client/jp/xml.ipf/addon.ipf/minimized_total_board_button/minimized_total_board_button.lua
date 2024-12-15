function MINIMIZED_TOTAL_BOARD_BUTTON_ON_INIT(addon, frame)
	addon:RegisterMsg('GAME_START', 'MINIMIZED_TOTAL_BOARD_BUTTON_OPEN_CHECK')
end

function MINIMIZED_TOTAL_BOARD_BUTTON_OPEN_CHECK(frame, msg, argStr, argNum)
	local mapprop = session.GetCurrentMapProp()
	if mapprop == nil then
		frame:ShowWindow(0)
		return
	end

	local mapCls = GetClassByType("Map", mapprop.type)
    if IS_TOWN_MAP(mapCls) == false then
        frame:ShowWindow(0)
    else
    	frame:ShowWindow(1)
	end
end

local function SHOW_MINIMIZED_BUTTON(frame)
	local news_button = ui.GetFrame('minimizedeventbanner')
	local housing_button = ui.GetFrame('minimized_housing_promote_board')

	if frame ~= nil and frame:IsVisible() == 1 then
		frame:ShowWindow(0)
		news_button:ShowWindow(0)
		housing_button:ShowWindow(0)
	else
		frame:ShowWindow(1)
		news_button:ShowWindow(1)
		housing_button:ShowWindow(1)
	end

end

function MINIMIZED_TOTAL_BOARD_BUTTON_CLICK(parent, ctrl)
	local frame = ui.GetFrame('minimized_folding_board')
	SHOW_MINIMIZED_BUTTON(frame)
end
