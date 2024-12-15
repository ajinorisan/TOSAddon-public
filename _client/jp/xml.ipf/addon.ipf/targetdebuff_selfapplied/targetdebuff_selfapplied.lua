-- targetdebuff_selfapplied.lua
t_debuff_ui = {};
t_debuff_ui["buff_group_cnt"] = 1;
t_debuff_ui["slotsets"] = {};
t_debuff_ui["slotcount"] = {};
t_debuff_ui["slotlist"] = {};
t_debuff_ui["captionlist"] = {};
t_debuff_ui["txt_x_offset"] = 1;
t_debuff_ui["txt_y_offset"] = 1;
s_lsgmsg_selfapplied = "";
s_lasthandle_selfapplied = 0;

function TARGETDEBUFF_SELFAPPLIED_ON_INIT(addon, frame)
	--[[ addon:RegisterMsg('TARGET_BUFF_ADD', 'TARGETDEBUFF_SELFAPPLIED_ON_MSG');
	addon:RegisterMsg('TARGET_BUFF_REMOVE', 'TARGETDEBUFF_SELFAPPLIED_ON_MSG');
	addon:RegisterMsg('TARGET_BUFF_UPDATE', 'TARGETDEBUFF_SELFAPPLIED_ON_MSG');
	addon:RegisterMsg('TARGET_SET', 'TARGETDEBUFF_SELFAPPLIED_ON_MSG');
	addon:RegisterMsg('TARGET_CLEAR', 'TARGETDEBUFF_SELFAPPLIED_ON_MSG');
	INIT_BUFF_UI(frame, t_debuff_ui, "TARGETDEBUFF_SELFAPPLIED_UPDATE");
	INIT_TARGETDEBUFF_SELFAPPLIED(frame); ]]
end 

function INIT_TARGETDEBUFF_SELFAPPLIED(frame)
	--[[ if frame == nil then return; end
	local button = GET_CHILD_RECURSIVELY(frame, "debuffminimizebutton");
	if button ~= nil then
		button:Resize(0, 0);
		button:SetVisible(0);
		button:SetTextTooltip(ClMsg("TargetBuffButtonToolTipMin"));
	end

	local timer = GET_CHILD_RECURSIVELY(frame, "addontimer");
	tolua.cast(timer, "ui::CAddOnTimer");
	timer:SetUpdateScript("TARGETDEBUFF_SELFAPPLIED_UPDATE");
	timer:Start(0.45);

	local pos = ui.GetCatchMovePos(frame:GetName());
	if pos.x ~= 0 and pos.y ~= 0 then
		frame:MoveFrame(pos.x, pos.y);
	end

	local handle = session.GetMyHandle();
	local colLimit = tonumber(frame:GetUserConfig("DEBUFF_COL_LIMIT"));	
	ui.buff.SetTargetDebuffColLimitCount(frame:GetName(), handle, colLimit); ]]
end

function TARGETDEBUFF_SELFAPPLIED_UPDATE(frame, timer, argStr, argNum, passedTime)
	--[[ local handle = session.GetTargetHandle();
	BUFF_TIME_UPDATE(handle, t_debuff_ui); ]]
end

function TARGETDEBUFF_SELFAPPLIED_ON_MSG(frame, msg, argStr, argNum)
	--[[ local handle = session.GetTargetHandle();
	if msg == "TARGET_BUFF_ADD" then
		if TARGETDEBUFF_SELFAPPLIED_CHECK(handle, argNum) == false then return; end
		if TARGETDEBUFF_SELFAPPLIED_LIMIT(frame, handle, argNum) == false then 
			COMMON_BUFF_MSG(frame, "ADD", argNum, handle, t_debuff_ui, argStr);
		end
		TARGETDEBUFF_SELFAPPLIED_VISIBLE(frame, 1);
	elseif msg == "TARGET_BUFF_REMOVE" then
		COMMON_BUFF_MSG(frame, "REMOVE", argNum, handle, t_debuff_ui, argStr);
	elseif msg == "TARGET_BUFF_UPDATE" then
		COMMON_BUFF_MSG(frame, "UPDATE", argNum, handle, t_debuff_ui, argStr);
	elseif msg == "TARGET_SET" then
		if s_lsgmsg_selfapplied == msg and s_lasthandle_selfapplied == handle then
			return;
		end
		s_lsgmsg_selfapplied = msg;
		s_lasthandle_selfapplied = handle;
		COMMON_BUFF_MSG(frame, "CLEAR", argNum, handle, t_debuff_ui);	
		local isLimitDebuff = tonumber(frame:GetUserValue("IS_LIMIT_DEBUFF"));
		if isLimitDebuff == 1 then
			ui.TargetDebuffMinimizeAddonMsg(frame:GetName(), "SET", handle);
		else
			COMMON_BUFF_MSG(frame, "SET", argNum, handle, t_debuff_ui);
		end
		TARGETDEBUFF_SELFAPPLIED_VISIBLE(frame, 1);
	elseif msg == "TARGET_CLEAR" then
		if s_lsgmsg_selfapplied == msg then
			return;
		end
		s_lsgmsg_selfapplied = msg;
		COMMON_BUFF_MSG(frame, "CLEAR", argNum, handle, t_debuff_ui);
		TARGETDEBUFF_SELFAPPLIED_VISIBLE(frame, 0);		
	end

	TARGETDEBUFF_SELFAPPLIED_UPDATE(frame);
	TARGETDEBUFF_SELFAPPLIED_RESIZE(frame, t_debuff_ui); ]]
end 

function TARGETDEBUFF_SELFAPPLIED_RESIZE(frame, buff_ui)
	--[[ if frame == nil or buff_ui == nil then return; end
	local defaultHeight = tonumber(frame:GetUserConfig("DEFAULT_HEIGHT"));
	local defaultSlotY = tonumber(frame:GetUserConfig("DEFAULT_SLOT_Y_OFFSET"));
	local colLimit = tonumber(frame:GetUserConfig("DEBUFF_COL_LIMIT"));

	local slotlist = buff_ui["slotlist"][0];
	local slotcount = buff_ui["slotcount"][0];
	if slotlist ~= nil and slotcount ~= nil then
		if slotcount <= colLimit then
			frame:Resize(frame:GetWidth(), defaultHeight);
			local gbox = GET_CHILD_RECURSIVELY(frame, "gbox");
			if gbox ~= nil then
				gbox:Resize(frame:GetWidth(), defaultHeight);
			end
		else
			local realCount = 0;
			for i = 0, slotcount - 1 do
				local slot = slotlist[i];
				if slot ~= nil and slot:IsVisible() == 1 then
					realCount = realCount + 1;
				end
			end

			local row = math.floor(realCount / colLimit);
			local height = row * defaultSlotY;

			frame:Resize(frame:GetWidth(), height + defaultSlotY + 10);
			local gbox = GET_CHILD_RECURSIVELY(frame, "gbox");
			if gbox ~= nil then
				gbox:Resize(frame:GetWidth(), height + defaultSlotY + 10);
			end
		end
	end ]]
end

function TARGETDEBUFF_SELFAPPLIED_VISIBLE(frame, isVisible)
	--[[ if frame == nil then return; end
	frame:ShowWindow(isVisible);

	local button = GET_CHILD_RECURSIVELY(frame, "debuffminimizebutton");
	if button ~= nil then
		button:SetVisible(isVisible);
	end ]]
end

function TARGETDEBUFF_SELFAPPLIED_BTN_TOGGLE(frame, button)
	--[[ local option = config.GetShowTargetDebuffSelfAppliedMinimize();
	if option == nil or option == 0 then
		config.SetShowTargetDebuffSelfAppliedMinimize(1);
	elseif option == 1 then
		config.SetShowTargetDebuffSelfAppliedMinimize(0);
	end ]]
end

function TARGETDEBUFF_SELFAPPLIED_LIMIT(frame, handle, buffType)
	--[[ if handle == nil then
		return false;
	end

	if buffType == nil or buffType == 0 then
		return false;
	end

	local option = config.GetShowTargetDebuffSelfAppliedMinimize();
	local isLimitDebuff = tonumber(frame:GetUserValue("IS_LIMIT_DEBUFF"));
	if isLimitDebuff == 1 and option == 1 then
		local buffCls = GetClassByType('Buff', buffType);
		if buffCls ~= nil and buffCls.Group1 == "Debuff" then
			return true;
		end
	end
	
	return false; ]]
end

function TARGETDEBUFF_SELFAPPLIED_MINIMIZE_CHECK(isLimitDebuff)
	--[[ local frame = ui.GetFrame("targetdebuff_selfapplied");
	if frame ~= nil then
		frame:SetUserValue("IS_LIMIT_DEBUFF", isLimitDebuff);
	end ]]
end

function TARGETDEBUFF_SELFAPPLIED_MINIMIZE_ON_MSG(msg, argStr, argNum)
	--[[ local frame = ui.GetFrame("targetdebuff_selfapplied");
	if frame ~= nil then
		local handle = session.GetTargetHandle();
		if handle ~= nil then
			if msg == "ADD" then
				COMMON_BUFF_MSG(frame, msg, argNum, handle, t_debuff_ui, argStr);
				TARGET_BUFF_UPDATE(frame);
				TARGETBUFF_RESIZE(frame, t_debuff_ui);
			end
		end
	end ]]
end

function TARGETDEBUFF_SELFAPPLIED_BUTTON_UPDATE()
	--[[ local handle = session.GetTargetHandle();
	if handle ~= nil then
		local frame = ui.GetFrame("targetdebuff_selfapplied");
		if frame ~= nil then 
			local button = GET_CHILD_RECURSIVELY(frame, "debuffminimizebutton");
			if button ~= nil then
				local option = config.GetShowTargetDebuffSelfAppliedMinimize();
				if option == 1 then
					local maxImageName = frame:GetUserConfig("DEBUFF_MAX_BTN_IMAGE_NAME");
					button:SetImage(maxImageName);
					button:SetTextTooltipByTargetBuff(ClMsg("TargetBuffButtonToolTipMax"));
					ui.ChangeTooltipTextByTargetBuff(ClMsg("TargetBuffButtonToolTipMax"));
				elseif option == 0 then
					local minImageName = frame:GetUserConfig("DEBUFF_MIN_BTN_IMAGE_NAME");
					button:SetImage(minImageName);
					button:SetTextTooltipByTargetBuff(ClMsg("TargetBuffButtonToolTipMin"));
					ui.ChangeTooltipTextByTargetBuff(ClMsg("TargetBuffButtonToolTipMin"));
				end
				button:Resize(26, 26);
				button:Invalidate();
			end
		end
	end ]]
end

function TARGETDEBUFF_SELFAPPLIED_SLOTSET_MINIMIZE()
	--[[ local frame = ui.GetFrame("targetdebuff_selfapplied");
	if frame ~= nil then
		if t_debuff_ui ~= nil then
			local row = 2;
			local col = t_debuff_ui["slotsets"][0]:GetCol();
			t_debuff_ui["slotsets"][0]:SetColRow(col, row);
			t_debuff_ui["slotsets"][0]:AutoCheckDecreaseRow();
			t_debuff_ui["slotsets"][0]:Invalidate();
			frame:Invalidate();
		end
	end ]]
end

function TARGETDEBUFF_SELFAPPLIED_CHECK(handle, buffID)
	--[[ if handle == nil or buffID == 0 then
		return false;
	end

	if ui.buff.IsTargetDebuffSelfApplied(handle, buffID) == 1 then
		return true;
	end ]]
	return false;
end

function TARGETDEBUFF_SELFAPPLIED_SET_ADDON_MSG_CHECK(frameName, handle, buffID)
	--[[ if frameName == nil or handle == nil or buffID == nil then
		return false;
	end

	if frameName == "targetbuff" and ui.buff.IsTargetDebuffSelfApplied(handle, buffID) == 1 then
		return true;
	end

	if frameName == "targetdebuff_selfapplied" and ui.buff.IsTargetDebuffSelfApplied(handle, buffID) ~= 1 then
		return true;
	end ]]
	return false;
end