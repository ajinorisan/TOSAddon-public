function MINIMIZED_TUTORIALNOTE_BUTTON_ON_INIT(addon, frame)
-- 	addon:RegisterMsg("GAME_START", "MINIMIZED_TUTORIALNOTE_BUTTON_INIT");	
-- 	addon:RegisterMsg("MINIMIZED_TUTORIALNOTE_EFFECT_CHECK", "MINIMIZED_TUTORIALNOTE_EFFECT_CHECK");
-- 	addon:RegisterMsg("MINIMIZED_TUTORIALNOTE_EFFECT_OFF", "MINIMIZED_TUTORIALNOTE_EFFECT_OFF");
end

-- function MINIMIZED_TUTORIALNOTE_BUTTON_INIT(frame)
-- 	local ShowTutorialnote = config.GetXMLConfig("ShowTutorialnote");
-- 	if ShowTutorialnote == 0 then
-- 		ui.CloseFrame("minimized_tutorialnote_button");
-- 		return;
-- 	end
-- 	local mapprop = session.GetCurrentMapProp();
-- 	local mapCls = GetClassByType("Map", mapprop.type);

-- 	local housingPlaceClass = GetClass("Housing_Place", mapCls.ClassName);
-- 	if housingPlaceClass ~= nil then
-- 		ui.CloseFrame("minimized_tutorialnote_button");
-- 		return
-- 	end
-- 	local point_ctrl = GET_CHILD_RECURSIVELY(frame, "point");
-- 	point_ctrl:ShowWindow(0);
-- 	MINIMIZED_TUTORIALNOTE_EFFECT_CHECK(frame);
-- end

-- function MINIMIZED_TUTORIALNOTE_EFFECT_CHECK(frame, msg, argStr, argNum)
-- 	local ShowTutorialnote = config.GetXMLConfig("ShowTutorialnote");
-- 	if ShowTutorialnote == 0 then
-- 		return;
-- 	end
	
-- 	local frame = ui.GetFrame("minimized_tutorialnote_button");
-- 	local aObj = GetMyAccountObj();
-- 	if aObj== nil then return; end

-- 	local ret1 = TUTORIALNOTE_MINIMIZED_POINT_PIC_CHECK(aObj, "guide");
-- 	local ret2 = TUTORIALNOTE_MINIMIZED_POINT_PIC_CHECK(aObj, "mission_1");
-- 	local ret3 = TUTORIALNOTE_MINIMIZED_POINT_PIC_CHECK(aObj, "mission_2");
-- 	local ret4 = TUTORIALNOTE_MINIMIZED_POINT_PIC_CHECK(aObj, "mission_3");

-- 	local result = ret1 or ret2 or ret3 or ret4;
-- 	local ctrl = GET_CHILD(frame, "openBtn");
-- 	local point_ctrl = GET_CHILD_RECURSIVELY(frame, "point");
-- 	if ctrl == nil or point_ctrl == nil then return; end

-- 	if result == true or (argStr ~= nil and argStr ~= "") then
-- 		point_ctrl:ShowWindow(1);
-- 		frame:SetUserValue("POINT_PIC_SHOW", 1);
-- 	else
-- 		point_ctrl:ShowWindow(0);
-- 		frame:SetUserValue("POINT_PIC_SHOW", 0);
-- 	end
-- end

-- function MINIMIZED_TUTORIALNOTE_EFFECT_OFF(frame)
-- 	local ShowTutorialnote = config.GetXMLConfig("ShowTutorialnote");
-- 	if ShowTutorialnote == 0 then
-- 		return;
-- 	end
	
-- 	local frame = ui.GetFrame("minimized_tutorialnote_button");
	
-- 	local point_ctrl = GET_CHILD_RECURSIVELY(frame, "point");
-- 	point_ctrl:ShowWindow(0);
	
-- 	frame:SetUserValue("POINT_PIC_SHOW", 0);
-- end

-- function MINIMIZED_TUTORIALNOTE_BUTTON_CLICK()
-- 	local frame = ui.GetFrame("tutorialnote");
-- 	if frame:IsVisible() == 0 then
-- 		ui.OpenFrame("tutorialnote");
-- 	else
-- 		ui.CloseFrame("tutorialnote");
-- 	end
-- end
