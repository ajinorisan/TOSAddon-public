function MINIMIZED_EVENT_PROGRESS_CHECK_BUTTON_ON_INIT(addon, frame)
	addon:RegisterMsg("GAME_START", "MINIMIZED_EVENT_PROGRESS_CHECK_BUTTON_INIT");
	addon:RegisterMsg("EVENT_STAMP_TOUR_REWARD_GET", "MINIMIZED_EVENT_PROGRESS_CHECK_BUTTON_INIT");
end

function MINIMIZED_EVENT_PROGRESS_CHECK_BUTTON_INIT(frame, msg)
	local btn1_gb = GET_CHILD(frame, "btn1_gb");
	btn1_gb:ShowWindow(0);
	local btn2_gb = GET_CHILD(frame, "btn2_gb");
	btn2_gb:ShowWindow(0);

	local mapprop = session.GetCurrentMapProp();
	local mapCls = GetClassByType("Map", mapprop.type);
	local housingPlaceClass = GetClass("Housing_Place", mapCls.ClassName);
	if housingPlaceClass ~= nil then
		local margin = frame:GetMargin()
		frame:SetMargin(margin.left, 225, margin.right, margin.bottom)
	end

	MINIMIZED_EVENT_PROGRESS_CHECK_BUTTON1(frame, btn1_gb);
	MINIMIZED_EVENT_PROGRESS_CHECK_BUTTON2(frame, btn2_gb, msg);
end

function MINIMIZED_EVENT_PROGRESS_CHECK_BUTTON1(frame, gb)
	local btn = GET_CHILD(gb, "openBtn");
	local title = GET_CHILD(gb, "title");
	-- SEASON_SERVER
	local curmapname = session.GetMapName();
	local mapprop = geMapTable.GetMapProp(curmapname);
	local mapname = mapprop:GetClassName();

	if mapname == "c_klaipe_castle" then
		return 
	end

	if IS_SEASON_SERVER() == "YES" then
		btn:ShowWindow(1)
		btn:SetImage("stamptour_btn");
		btn:SetEventScript(ui.LBUTTONUP, "ON_EVENT_STAMP_TOUR_UI_OPEN_COMMAND");
		-- title:SetTextByKey("value", ClMsg("STAMP_TOUR"));
		MINIMIZED_EVENT_PROGRESS_CHECK_NOTICE_BUTTON(btn)
		gb:ShowWindow(1);
		return;
	end

	-- FLEX_BOX
	-- if IS_SEASON_SERVER() == "NO"  then
	-- 	btn:SetImage("flex_box_btn");
	-- 	btn:SetEventScript(ui.LBUTTONUP, "MINIMIZED_EVENT_PROGRESS_CHECK_BUTTON_CLICK");
	-- 	btn:SetEventScriptArgNumber(ui.LBUTTONUP, 3);
		
	-- 	title:SetTextByKey("value", ClMsg("FLEX!"));
	-- 	gb:ShowWindow(1);
	-- 	return;
	-- end

	-- EVENT_2011_5TH
	-- btn:SetImage("5thevent_btn");
	-- btn:SetEventScript(ui.LBUTTONUP, "MINIMIZED_EVENT_PROGRESS_CHECK_BUTTON_CLICK");
	-- btn:SetEventScriptArgNumber(ui.LBUTTONUP, 6);
	
	-- title:SetTextByKey("value", ClMsg("EVENT_2011_5TH_TITLE"));
	-- gb:ShowWindow(1);
end

function MINIMIZED_EVENT_PROGRESS_CHECK_BUTTON2(frame, gb, msg)
	local btn = GET_CHILD(gb, "openBtn2");
	local title = GET_CHILD(gb, "title2");
	
	-- YOUR_MASTER
	-- btn:SetImage("your_master_activity_btn");
	-- btn:SetEventScript(ui.LBUTTONUP, "MINIMIZED_EVENT_PROGRESS_CHECK_BUTTON_CLICK");
	-- btn:SetEventScriptArgNumber(ui.LBUTTONUP, 4);
	-- title:SetTextByKey("value", ClMsg("EVENT_YOUR_MASTER_TITLE"));
    -- gb:ShowWindow(1);

    -- -- EVENT_2009_FULLMOON
    -- btn:SetImage("2009Chursok_btn")
    -- btn:SetEventScript(ui.LBUTTONUP, "MINIMIZED_EVENT_PROGRESS_CHECK_BUTTON_CLICK");
	-- btn:SetEventScriptArgNumber(ui.LBUTTONUP, 5);
	-- title:SetTextByKey("value", ClMsg("EVENT_2009_FULLMOON_TITLE"));
	-- gb:ShowWindow(1);
	
	-- EVENT_2112_CHRISTMAS
	-- local aObj = GetMyAccountObj()
	-- local stampTourCheck = TryGetProp(aObj, "REGULAR_EVENT_STAMP_TOUR", 0);
	-- if stampTourCheck == 1 or msg == "ACCEPT_STAMPTOUR" then
	-- 	btn:SetImage("event_btn");
	-- 	btn:SetEventScript(ui.LBUTTONUP, "ON_EVENT_STAMP_TOUR_UI_OPEN_COMMAND_CHRISTMAS");
	-- 	btn:SetEventScriptArgString(ui.LBUTTONUP, "EVENT_STAMP_TOUR_UI_OPEN_COMMAND_CHRISTMAS");
	-- 	title:SetTextByKey("value", "");
	-- 	gb:ShowWindow(1);
	-- end
end

function MINIMIZED_EVENT_PROGRESS_CHECK_BUTTON_CLICK(parent, ctrl, argStr, type)	
	local frame = ui.GetFrame("event_progress_check");
	if frame:IsVisible() == 1 then
		frame:ShowWindow(0);
		return;
	end

	EVENT_PROGRESS_CHECK_OPEN_COMMAND("", "", "", type);
end

function MINIMIZED_EVENT_PROGRESS_CHECK_NOTICE_BUTTON(frame)
	local point = EVENT_STAMP_GET_RECEIVABLE_REWARD_COUNT(GetMyAccountObj())

	local notice = GET_CHILD_RECURSIVELY(frame, 'notice_bg')    
	local noticeText = GET_CHILD(notice, 'notice_text')

	if point > 0 then
		notice:ShowWindow(1)
		noticeText:ShowWindow(1)
		noticeText:SetTextByKey('value',tostring(point))
        SYSMENU_NOTICE_TEXT_RESIZE(notice, point)
	elseif point == 0 then
		notice:ShowWindow(0)
		noticeText:ShowWindow(0)
	end
end