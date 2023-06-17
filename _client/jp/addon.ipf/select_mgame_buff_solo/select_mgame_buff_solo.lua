function SELECT_MGAME_BUFF_SOLO_ON_INIT(addon, frame)
	addon:RegisterMsg("SELECT_MGAME_BUFF_SOLO", "ON_SELECT_MGAME_BUFF_SOLO_OPEN");
	addon:RegisterMsg("SELECT_MGAME_BUFF_SOLO_END", "ON_SELECT_MGAME_BUFF_SOLO_END");
	addon:RegisterMsg("SELECT_MGAME_BUFF_SOLO_OPTION", "ON_SELECT_MGAME_BUFF_SOLO_OPTION_OPEN");
	addon:RegisterMsg("SELECT_MGAME_BUFF_SOLO_OPTION_SELECT_UPDATE", "ON_SELECT_MGAME_BUFF_SOLO_OPTION_UPDATE");
	addon:RegisterMsg("SELECT_MGAME_BUFF_SOLO_SELECT_BTN_UPDATE", "ON_SELECT_MGAME_BUFF_SOLO_SELECT_BTN_UPDATE");
	addon:RegisterMsg("SELECT_MGAME_BUFF_SOLO_OPTION_END", "ON_SELECT_MGAME_BUFF_SOLO_END");
end

function SELECT_MGAME_BUFF_SOLO_OPEN(frame)
end

function SELECT_MGAME_BUFF_SOLO_CLOSE(frame)
end

function ON_SELECT_MGAME_BUFF_SOLO_OPEN(frame, msg, argStr, argNum)
	local buffList = StringSplit(argStr, '/');
	INIT_SELECT_MGAME_BUFF(frame, buffList, argNum);
	frame:ShowWindow(1);
end

function ON_SELECT_MGAME_BUFF_SOLO_OPTION_OPEN(frame, msg, argStr, argNum)
	local list = StringSplit(argStr, '/');
	INIT_SELECT_MGAME_BUFF_OPTION(frame, list, argNum);
	frame:ShowWindow(1);
	local my_session = session.GetMySession();
	my_session:SetBuffSelectSoloByOptionIconTime(argNum);
end

function ON_SELECT_MGAME_BUFF_SOLO_END(frame, msg, argStr, argNum)
	frame:ShowWindow(0);
end

function ON_SELECT_MGAME_BUFF_SOLO_OPTION_UPDATE(frame, msg, argStr, argNum)
	if frame == nil then return; end
	for i = 1, 5 do
		local ctrlset = GET_CHILD_RECURSIVELY(frame, "BUFF_CTRL_"..i);
		if ctrlset ~= nil then
			local type = ctrlset:GetUserIValue("type");
			if type == argNum then
				local click_pic = GET_CHILD_RECURSIVELY(ctrlset, "buff_select_on");
				local buff_icon = GET_CHILD_RECURSIVELY(ctrlset, "buff_icon");
				if click_pic ~= nil and buff_icon ~= nil then
					if argStr == "YES" then
						click_pic:EnableHitTest(0);
						click_pic:SetVisible(0);
						buff_icon:SetEnable(0);
						ctrlset:SetEnable(0);
						ctrlset:SetUserValue("buff_selected", 1);
						break;
					else
						click_pic:EnableHitTest(1);
						click_pic:SetVisible(0);
						buff_icon:SetEnable(1);
						ctrlset:SetEnable(1);
						ctrlset:SetUserValue("buff_selected", 0);
						break;
					end
				end
			end
		end
	end
	frame:Invalidate();
end

function ON_SELECT_MGAME_BUFF_SOLO_SELECT_BTN_UPDATE(frame, msg, argStr, argNum)
	if frame == nil then return; end
	local select = GET_CHILD_RECURSIVELY(frame, "select")
	select:SetEnable(argNum);
end

function ON_SELECT_MGAME_BUFF_SOLO_SELECT_BTN(parent, ctrl)
	local frame = parent:GetTopParentFrame();
	local use_buff_lock_option = frame:GetUserIValue("use_buff_lock_option");
	if use_buff_lock_option == nil then use_buff_lock_option = 0; end

	if use_buff_lock_option == 1 then
		if parent:GetUserIValue("buff_selected") == 1 then
			return;
		end
		
		local select = GET_CHILD_RECURSIVELY(frame, "select")
		select:SetEnable(0);
	end

	local buffType = frame:GetUserIValue("SELECT_MGAME_BUFF");
	SelectSoloBuff(buffType, use_buff_lock_option);
	frame:SetEnable(0);
	frame:ReserveScript("ENABLE_FRAME", 0.5, 1);
end