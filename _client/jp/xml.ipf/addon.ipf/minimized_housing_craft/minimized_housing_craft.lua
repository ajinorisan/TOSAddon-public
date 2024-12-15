function MINIMIZED_HOUSING_CRAFT_ON_INIT(addon, frame)
	addon:RegisterMsg('GAME_START', 'MINIMIZED_HOUSING_CRAFT_OPEN_EDIT_MODE');
	addon:RegisterMsg('HOUSINGCRAFT_UPDATE_ENDTIME', 'MINIMIZED_HOUSING_CRAFT_UPDATE_ENDTIME');
	addon:RegisterMsg('ENTER_PERSONAL_HOUSE', 'MINIMIZED_HOUSING_CRAFT_OPEN_EDIT_MODE');
end

function MINIMIZED_HOUSING_CRAFT_OPEN_EDIT_MODE(frame, msg, argStr, argNum)
	local mapprop = session.GetCurrentMapProp();
	local mapCls = GetClassByType("Map", mapprop.type);

	local housingPlaceClass = GetClass("Housing_Place", mapCls.ClassName);
	if housingPlaceClass == nil then
		frame:ShowWindow(0);
		return
	end
	
	if argStr == "YES" then
		frame:ShowWindow(1);
	else
		frame:ShowWindow(0);
	end
end

function MINIMIZED_HOUSING_CRAFT_UPDATE_ENDTIME(frame, msg)
	frame:RunUpdateScript("UPDATE_HOUSING_CRAFT_WHEN_END_TIME", 60);
end
function BTN_MINIMIZED_HOUSING_CRAFT_OPEN_EDIT_MODE(parent, btn)
	local mapprop = session.GetCurrentMapProp();
	local mapCls = GetClassByType("Map", mapprop.type);
	local housingPlaceClass = GetClass("Housing_Place", mapCls.ClassName);
	if housingPlaceClass == nil then
		return;
	end
	local housingPlaceType = TryGetProp(housingPlaceClass, "Type");
	local isGuild = false;
	if housingPlaceType == "Guild" then
		isGuild = true;
	end
	local frame = ui.GetFrame("housing_craft")
	HOUSING_CRAFT_OPEN(frame)
end

function RESET_MINIMIZED_GUILD_HOUSING_BUTTON()
	local frame = ui.GetFrame("minimized_guild_housing");
	local button = GET_CHILD_RECURSIVELY(frame, "openGuildHousingEditMode");
	button:SetEnable(1);
end

function UPDATE_HOUSING_CRAFT_WHEN_END_TIME(ctrl, elapsedTime)
	local aObj = GetMyAccountObj();
	local endtime = imcTime.GetSysTimeByYYMMDDHHMMSS(TryGetProp(aObj,"HOUSINGCRAFT_END_TIME"));
	local remainsec = imcTime.GetDifSec(endtime, geTime.GetServerSystemTime());
	if remainsec < 0 then
		if TryGetProp(aObj,"HOUSINGCRAFT_NEED_RECEIVE",0) == 0 and TryGetProp(aObj,"HOUSINGCRAFT_RECEIVED",0) == 0 then
			control.CustomCommand('REQ_CALC_HOUSINGCRAFT_GOODS',0);
		end
		return 0;
	end
    return 1;
end