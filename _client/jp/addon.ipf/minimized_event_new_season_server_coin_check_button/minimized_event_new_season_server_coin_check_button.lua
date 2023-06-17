function MINIMIZED_EVENT_NEW_SEASON_SERVER_COIN_CHECK_BUTTON_ON_INIT(addon, frame)
	addon:RegisterMsg("GAME_START", "MINIMIZED_EVENT_NEW_SEASON_SERVER_COIN_CHECK_BUTTON_OPEN_CHECK");
end

function MINIMIZED_EVENT_NEW_SEASON_SERVER_COIN_CHECK_BUTTON_OPEN_CHECK(frame)
	local curmapname = session.GetMapName();
	local mapprop = geMapTable.GetMapProp(curmapname);
	local mapname = mapprop:GetClassName();

	if mapname == "c_klaipe_castle" then
		frame:ShowWindow(0);
		return 
	end

	local accObj = GetMyAccountObj();
	if IS_SEASON_SERVER() == "YES" then
		local ctrl = GET_CHILD(frame, "openBtn");
		ctrl:SetEventScript(ui.LBUTTONUP, "MINIMIZED_EVENT_NEW_SEASON_SERVER_COIN_CHECK_BUTTON_CLICK");
		frame:ShowWindow(1);
	else
		GODDESS_ROULETTE_COIN_BUTTON_OPEN_CHECK(frame);
		frame:ShowWindow(0);
	end
end

function MINIMIZED_EVENT_NEW_SEASON_SERVER_COIN_CHECK_BUTTON_CLICK()
	EVENT_NEW_SEASON_SERVER_COIN_CHECK_OPEN_COMMAND();
end

function GODDESS_ROULETTE_COIN_BUTTON_OPEN_CHECK(frame)
	frame:ShowWindow(0);
	local ctrl = GET_CHILD(frame, "openBtn");
	ctrl:SetEventScript(ui.LBUTTONUP, "GODDESS_ROULETTE_COIN_BUTTON_OPEN_CHECK_CLICK");
	frame:ShowWindow(1);
end

function GODDESS_ROULETTE_COIN_BUTTON_OPEN_CHECK_CLICK()
	local frame = ui.GetFrame("goddess_roulette_coin");
	frame:ShowWindow(1);
end
