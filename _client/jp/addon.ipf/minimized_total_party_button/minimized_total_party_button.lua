function MINIMIZED_TOTAL_PARTY_BUTTON_ON_INIT(addon, frame)
	addon:RegisterMsg('GAME_START', 'MINIMIZED_TOTAL_PARTY_BUTTON_OPEN_CHECK');
end

function MINIMIZED_TOTAL_PARTY_BUTTON_OPEN_CHECK(frame, msg, argStr, argNum)
	local mapprop = session.GetCurrentMapProp();
	if mapprop == nil then
		frame:ShowWindow(0);
		return;
	end

	local mapCls = GetClassByType("Map", mapprop.type);
	if mapCls == nil then
		frame:ShowWindow(0);
		return;
	end

	local housingPlaceClass = GetClass("Housing_Place", mapCls.ClassName);
    if session.world.IsIntegrateServer() == true or housingPlaceClass ~= nil then
        frame:ShowWindow(0);
	else
    	frame:ShowWindow(1);
	end
end

local function SHOW_MINIMIZED_TOTAL_PARTY_BUTTON(frame)
	local party_board_button = ui.GetFrame('minimized_party_board');
	local pilgrim_mode_button = ui.GetFrame("minimized_pilgrim_mode");
	if frame ~= nil and frame:IsVisible() == 1 then
		frame:ShowWindow(0)	
		party_board_button:ShowWindow(0)
		pilgrim_mode_button:ShowWindow(0)
	else
		frame:ShowWindow(1)
		party_board_button:ShowWindow(1)
		pilgrim_mode_button:ShowWindow(1)
		
		local frame_margin = frame:GetMargin()
		local party_board_margin = party_board_button:GetMargin()
		local pilgrim_mode_margin = pilgrim_mode_button:GetMargin()
		
		local mapprop = session.GetCurrentMapProp()
		local mapCls = GetClassByType("Map", mapprop.type)
		
		local housingPlaceClass = GetClass("Housing_Place", mapCls.ClassName)
		if housingPlaceClass ~= nil then
			frame:SetMargin(frame_margin.left, 225, frame_margin.right, frame_margin.bottom)
			party_board_button:SetMargin(party_board_margin.left, 225, party_board_margin.right, party_board_margin.bottom)
			pilgrim_mode_button:SetMargin(pilgrim_mode_margin.left, 225, pilgrim_mode_margin.right, pilgrim_mode_margin.bottom)
		else
			frame:SetMargin(frame_margin.left, 240, frame_margin.right, frame_margin.bottom)
			party_board_button:SetMargin(party_board_margin.left, 243, party_board_margin.right, party_board_margin.bottom)
			pilgrim_mode_button:SetMargin(pilgrim_mode_margin.left, 243, pilgrim_mode_margin.right, pilgrim_mode_margin.bottom)
		end
	end
end

function MINIMIZED_TOTAL_PARTY_BUTTON_CLICK(parent, ctrl)
	local frame = ui.GetFrame('minimized_folding_party');
	SHOW_MINIMIZED_TOTAL_PARTY_BUTTON(frame);
end
