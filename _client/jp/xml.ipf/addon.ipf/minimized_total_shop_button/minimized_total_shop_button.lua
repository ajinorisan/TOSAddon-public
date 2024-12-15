function MINIMIZED_TOTAL_SHOP_BUTTON_ON_INIT(addon, frame)
	addon:RegisterMsg('GAME_START', 'MINIMIZED_TOTAL_SHOP_BUTTON_OPEN_CHECK');
end

function MINIMIZED_TOTAL_SHOP_BUTTON_OPEN_CHECK(frame, msg, argStr, argNum)
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

local function SHOW_MINIMIZED_BUTTON(frame)
	local pvp_button = ui.GetFrame('minimized_pvpmine_shop_button')
	local certificate_button = ui.GetFrame('minimized_certificate_shop_button')
	local market_button = ui.GetFrame('minimized_market_button')

	if frame ~= nil and frame:IsVisible() == 1 then
		frame:ShowWindow(0)	
		pvp_button:ShowWindow(0)
		certificate_button:ShowWindow(0)
		market_button:ShowWindow(0)
	else
		frame:ShowWindow(1)
		pvp_button:ShowWindow(1)
		certificate_button:ShowWindow(1)
		market_button:ShowWindow(1)
		
		local frame_margin = frame:GetMargin()
		local pvp_margin = pvp_button:GetMargin()
		local certificate_margin = certificate_button:GetMargin()
		local market_margin = market_button:GetMargin()
		
		local mapprop = session.GetCurrentMapProp()
		local mapCls = GetClassByType("Map", mapprop.type)
		
		local housingPlaceClass = GetClass("Housing_Place", mapCls.ClassName)
		if housingPlaceClass ~= nil then
			frame:SetMargin(frame_margin.left, 177, frame_margin.right, frame_margin.bottom)
			pvp_button:SetMargin(pvp_margin.left, 183, pvp_margin.right, pvp_margin.bottom)
			certificate_button:SetMargin(certificate_margin.left, 183, certificate_margin.right, certificate_margin.bottom)
			market_button:SetMargin(market_margin.left, 183, market_margin.right, market_margin.bottom)
		else
			frame:SetMargin(frame_margin.left, 71, frame_margin.right, frame_margin.bottom)
			pvp_button:SetMargin(pvp_margin.left, 76, pvp_margin.right, pvp_margin.bottom)
			certificate_button:SetMargin(certificate_margin.left, 76, certificate_margin.right, certificate_margin.bottom)
			market_button:SetMargin(market_margin.left, 76, market_margin.right, market_margin.bottom)
		end
	end

end

function MINIMIZED_TOTAL_SHOP_BUTTON_CLICK(parent, ctrl)
	local frame = ui.GetFrame('minimized_folding_button')
	SHOW_MINIMIZED_BUTTON(frame)
end
