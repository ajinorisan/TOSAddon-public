function SELECT_MGAME_BUFF_PARTY_ON_INIT(addon, frame)
	addon:RegisterMsg("SELECT_MGAME_BUFF_PARTY", "ON_SELECT_MGAME_BUFF_PARTY_OPEN");
	addon:RegisterMsg("SELECT_MGAME_BUFF_PARTY_END", "ON_SELECT_MGAME_BUFF_PARTY_END");
	addon:RegisterMsg("SELECT_MGAME_BUFF_PARTY_SELECT", "ON_SELECT_MGAME_BUFF_PARTY");
	addon:RegisterMsg("SELECT_MGAME_BUFF_PARTY_UPDATE", "ON_SELECT_MGAME_BUFF_PARTY_UPDATE");
end

function SELECT_MGAME_BUFF_PARTY_OPEN(frame)
end

function SELECT_MGAME_BUFF_PARTY_CLOSE(frame)
end
---------------common------------------------
function INIT_SELECT_MGAME_BUFF(frame, buffList, time)
	SELECT_MGAME_BUFF_LIST_SET(frame, buffList)
	local gauge = GET_CHILD_RECURSIVELY(frame, "time_gauge")
	gauge:SetPoint(100, 100)
	gauge:RunUpdateScript("SELECT_MGAME_BUFF_UPDATE_TIME", 0.01, time + 1);
	gauge:SetUserValue("TOTAL_TIME",time)
	local select = GET_CHILD_RECURSIVELY(frame,"select")
	select:SetEnable(0)
	frame:SetEnable(1)
end

function INIT_SELECT_MGAME_BUFF_OPTION(frame, buffList, time)
	SELECT_MGAME_BUFF_OPTION_LIST_SET(frame, buffList);
	local gauge = GET_CHILD_RECURSIVELY(frame, "time_gauge");
	gauge:SetPoint(100, 100);
	gauge:RunUpdateScript("SELECT_MGAME_BUFF_UPDATE_TIME", 0.01, time + 1);
	gauge:SetUserValue("TOTAL_TIME", time);
	local select = GET_CHILD_RECURSIVELY(frame, "select");
	select:SetEnable(0);
	frame:SetEnable(1);
end

function SELECT_MGAME_BUFF_UPDATE_TIME(gauge, total_elapsed_time, elapsed_time)
	AUTO_CAST(gauge);
	local total_time = gauge:GetUserIValue("TOTAL_TIME");
	local remain_time = math.max(0, total_time - total_elapsed_time);
	gauge:SetPoint(remain_time, total_time)
	if tonumber(remain_time) <= 2 then
		local top_frame = gauge:GetTopParentFrame();
		if top_frame ~= nil then
			top_frame:ShowWindow(0);
		end
		return 2;
	end
	return 1;
end

function SELECT_MGAME_BUFF_LIST_SET(frame,buffList)
	local buff_list = GET_CHILD_RECURSIVELY(frame,"buff_list")
	buff_list:RemoveAllChild()
	for i = 1,5 do
		local ctrlSet = buff_list:CreateOrGetControlSet('select_mgame_buff_ctrl', 'BUFF_CTRL_'..i, (i-1)*85, 0);
		local click_pic = GET_CHILD_RECURSIVELY(ctrlSet,"buff_select_on")
		local buff_icon = GET_CHILD_RECURSIVELY(ctrlSet,"buff_icon")
		local buffCls = GetClassByType("Buff",buffList[i])
		if buffCls ~= nil then
			local buffIcon = string.format("icon_%s",TryGetProp(buffCls,"Icon"))
			buff_icon:SetImage(buffIcon)
			local buff_select_btn = GET_CHILD_RECURSIVELY(ctrlSet,"buff_select_btn")
			buff_select_btn:SetEventScriptArgNumber(ui.LBUTTONUP,buffCls.ClassID)
			buff_select_btn:SetTooltipType('buff');
			buff_select_btn:SetTooltipArg(session.GetMyHandle(), buffCls.ClassID,0);
			click_pic:SetTooltipType('buff');
			click_pic:SetTooltipArg(session.GetMyHandle(), buffCls.ClassID,0);
		end
		click_pic:EnableHitTest(0)
		click_pic:SetVisible(0)
	end
end

function SELECT_MGAME_BUFF_OPTION_LIST_SET(frame, list)
	if frame == nil or list == nil then return; end
	frame:SetUserValue("use_buff_lock_option", 1);
	local buff_list = GET_CHILD_RECURSIVELY(frame, "buff_list");
	if buff_list ~= nil then
		buff_list:RemoveAllChild();
		for i = 1, 5 do
			local elem = list[i];
			if elem ~= nil then
				local buff_option_list = StringSplit(elem, ';');
				if buff_option_list ~= nil and #buff_option_list >= 2 then
					local ctrl =  buff_list:CreateOrGetControlSet('select_mgame_buff_ctrl', 'BUFF_CTRL_'..i, (i - 1) * 85, 0);
					ctrl:SetUserValue("buff_lock_option", buff_option_list[2]);

					local click_pic = GET_CHILD_RECURSIVELY(ctrl, "buff_select_on");
					local buff_icon = GET_CHILD_RECURSIVELY(ctrl, "buff_icon");
					local buff_cls = GetClassByType("Buff", buff_option_list[1]);
					if buff_cls ~= nil then
						ctrl:SetUserValue("type", buff_cls.ClassID);

						local icon = string.format("icon_%s", TryGetProp(buff_cls, "Icon"));
						buff_icon:SetImage(icon);

						local buff_select_btn = GET_CHILD_RECURSIVELY(ctrl, "buff_select_btn");
						buff_select_btn:SetEventScriptArgNumber(ui.LBUTTONUP, buff_cls.ClassID);
						buff_select_btn:SetTooltipType("buff");
						buff_select_btn:SetTooltipArg(session.GetMyHandle(), buff_cls.ClassID);

						click_pic:SetTooltipType("buff");
						click_pic:SetTooltipArg(session.GetMyHandle(), buff_cls.ClassID);
					end
					click_pic:EnableHitTest(0);
					click_pic:SetVisible(0);
				end
			end
		end
	end
end

function ON_SELECT_MGAME_BUFF_ICON_CLICK(parent, ctrl, argStr, argNum)
	local frame = parent:GetTopParentFrame();
	for i = 1, 5 do
		local ctrlSet = GET_CHILD_RECURSIVELY(frame, "BUFF_CTRL_"..i);
		if ctrlSet ~= nil then
			local click_pic = GET_CHILD_RECURSIVELY(ctrlSet, "buff_select_on");
			click_pic:EnableHitTest(0);
			click_pic:SetVisible(0);
		end
	end

	if argNum == nil or argNum <= 0 then
		return;
	end

	do
		local click_pic = GET_CHILD(parent, "buff_select_on");
		click_pic:EnableHitTest(1);
		click_pic:SetVisible(1);
		frame:SetUserValue("SELECT_MGAME_BUFF", argNum);

		local select_btn = GET_CHILD_RECURSIVELY(frame, "select");
		select_btn:SetEnable(1);
	end
end
---------------------------------------------

--------------------party--------------------
function ON_SELECT_MGAME_BUFF_PARTY_OPEN(frame,msg,argStr,argNum)
	local buffList = StringSplit(argStr,'/')
	INIT_SELECT_MGAME_BUFF(frame,buffList,argNum)
	frame:ShowWindow(1)
end

function ON_SELECT_MGAME_BUFF_PARTY_END(frame,msg,argStr,argNum)
	frame:ShowWindow(0)
end

function ON_SELECT_MGAME_BUFF_PARTY_SELECT_BTN(parent,ctrl)
	local frame = parent:GetTopParentFrame()
	local buffType = frame:GetUserIValue("SELECT_MGAME_BUFF")
	SelectPartyBuff(buffType)
	frame:SetEnable(0)
	frame:ReserveScript("ENABLE_FRAME", 0.5,1);
end

function ON_SELECT_MGAME_BUFF_PARTY(frame,msg,argStr,argNum)
	local buff_list = GET_CHILD_RECURSIVELY(frame,"buff_list")
	for i = 1,5 do
		local ctrlSet = GET_CHILD(buff_list,'BUFF_CTRL_'..i)
		local buff_select_btn = GET_CHILD_RECURSIVELY(ctrlSet,"buff_select_btn")
		if buff_select_btn:GetEventScriptArgNumber(ui.LBUTTONUP) == argNum then
			local buff_member_count = ctrlSet:GetUserIValue("SELECT_COUNT") + 1
			SELECT_MGAME_BUFF_SET_MEMBER_ICON(ctrlSet,buff_member_count)
		end
	end

	local handle = tonumber(argStr)
	if handle == session.GetMyHandle() then
		for i = 1,5 do
			local ctrlSet = GET_CHILD(buff_list,'BUFF_CTRL_'..i)
			local buff_icon = GET_CHILD_RECURSIVELY(ctrlSet,"buff_icon")
			local buff_select_btn = GET_CHILD_RECURSIVELY(ctrlSet,"buff_select_btn")
			local buff_select_on = GET_CHILD_RECURSIVELY(ctrlSet,"buff_select_on")
			buff_select_btn:SetEnable(0)
			buff_icon:SetEnable(0)
			if buff_select_on:IsVisible() == 0 then
				buff_select_on:SetImage(nil)
			end
			buff_select_on:EnableHitTest(1)
			buff_select_on:SetVisible(1)
		end
		local select = GET_CHILD_RECURSIVELY(frame,"select")
		select:SetEnable(0)
	end
end

function ON_SELECT_MGAME_BUFF_PARTY_UPDATE(frame,msg,argStr,argNum)
	local argList = StringSplit(argStr,';')
	local buffCountTable = {}
	for i = 1,#argList do
		local buffInfo = StringSplit(argList[i],'/')
		buffCountTable[tonumber(buffInfo[1])] = tonumber(buffInfo[2])
	end

	local buff_list = GET_CHILD_RECURSIVELY(frame,"buff_list")
	for i = 1,5 do
		local ctrlSet = GET_CHILD(buff_list,'BUFF_CTRL_'..i)
		local buff_select_btn = GET_CHILD_RECURSIVELY(ctrlSet,"buff_select_btn")
		local buffType = buff_select_btn:GetEventScriptArgNumber(ui.LBUTTONUP)
		SELECT_MGAME_BUFF_SET_MEMBER_ICON(ctrlSet,buffCountTable[buffType])
	end
end

function SELECT_MGAME_BUFF_SET_MEMBER_ICON(ctrlSet,buff_member_count)
	for i = 1,5 do
		local buff_member_icon = GET_CHILD_RECURSIVELY(ctrlSet,"buff_member_icon_"..i)
		if i <= buff_member_count then
			buff_member_icon:SetImage("buffselect_count_icon")
		else
			buff_member_icon:SetImage("None")
		end
	end
	ctrlSet:SetUserValue("SELECT_COUNT",buff_member_count)
end
---------------------------------------------