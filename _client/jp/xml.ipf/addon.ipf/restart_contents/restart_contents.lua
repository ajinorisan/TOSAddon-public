-- restart contents
local cache_command_btn_list = nil;
function RESTART_CONTENTS_ON_INIT(addon, frame)
	addon:RegisterMsg("RESTART_CONTENTS_HERE", "RESTART_CONTENTS_ON_MSG");
end

function RESTART_CONTENTS_VISIBLE_RESET(frame)
	if frame ~= nil then
		for i = 1, 5 do
			local btn = GET_CHILD_RECURSIVELY(frame, "btn_restart_"..i);
			if btn ~= nil then
				btn:ShowWindow(0);
			end 
		end
		local text_raid_death_count = GET_CHILD_RECURSIVELY(frame, "text_raid_death_count");
		if text_raid_death_count ~= nil then
			text_raid_death_count:ShowWindow(0);
		end
	end
end

function RESTART_CONTENTS_AUTO_RESIZE(frame)
	if frame ~= nil then
		cache_command_btn_list = nil;
		local max_y = 0;
		local ctrl_y = 100;
		local ctrl_height = 0;
		local cnt = frame:GetChildCount();
		for i = 0, cnt - 1 do
			local ctrl = frame:GetChildByIndex(i);
			if ctrl ~= nil and ctrl:IsVisible() == 1 and string.find(ctrl:GetName(), "btn_restart_") ~= nil then
				ctrl:SetOffset(ctrl:GetOffsetX(), ctrl_y);
				ctrl_y = ctrl_y + ctrl:GetHeight() + 5;
				if ctrl_height == 0 then
					ctrl_height = ctrl:GetHeight();
				end
				local y = ctrl:GetOffsetY() + ctrl:GetHeight();
				if y > max_y then
					max_y = y;
				end
			end
		end
		max_y = max_y + ctrl_height;
		if max_y ~= 0 then
			frame:Resize(frame:GetWidth(), max_y);
		end
	end
end

function RESTART_CONTENTS_GET_COMMAND_LIST(frame)
	if cache_command_btn_list == nil then 
		cache_command_btn_list = {};
		local index = 1;
		while 1 do
			local btn_name = "btn_restart_"..index;
			local btn = GET_CHILD_RECURSIVELY(frame, btn_name);
			if btn == nil then break; end
			if btn:IsVisible() == 1 then
				cache_command_btn_list[#cache_command_btn_list + 1] = btn_name;
			end
			index = index + 1;
		end
	end
	return cache_command_btn_list;
end

-- msg
function RESTART_CONTENTS_ON_MSG(frame, msg, arg_str, arg_num)
	if frame == nil then return; end
	if msg == "RESTART_CONTENTS_HERE" then
		RESTART_CONTENTS_ON_HERE(frame, arg_str, arg_num);
	end
end

function RESTART_CONTENTS_ON_HERE(frame, arg_str, arg_num)
	if frame == nil or arg_num == nil then return; end
	if frame:IsVisible() == 1 then return; end
	session.RaidResurrectDialog(arg_num);
	frame:ShowWindow(1);
	local text_raid_death_count = GET_CHILD_RECURSIVELY(frame, "text_raid_death_count");
	if text_raid_death_count ~= nil then
		text_raid_death_count:ShowWindow(0);
	end
	RESTART_CONTENTS_AUTO_RESIZE(frame);
end

function RESTART_CONTENTS_ON_HERE_VISIBLE(num, is_bit)
	local frame = ui.GetFrame("restart_contents");
	if frame ~= nil then
		local btn = GET_CHILD_RECURSIVELY(frame, "btn_restart_"..num);
		if btn ~= nil then
			btn:ShowWindow(is_bit);
			if num == 5 then
				local map_name = session.GetMapName();
				if map_name == "Content_Bridge_of_Wailing" then
					btn:SetText(ClMsg("RESTART_CONTENTS_HERE_TEXT"));
				else
					btn:SetText(ClMsg("RESTART_CONTENTS_START_POINT_TEXT"));
				end
			end
		end
	end
end

function RESTART_CONTENTS_INDEX(frame, is_down)
	if frame == nil then return; end
	local list = RESTART_CONTENTS_GET_COMMAND_LIST(frame);
	if list ~= nil and #list > 0 then
		local select_index = frame:GetValue();
		select_index = select_index + is_down;
		local btn_name = list[select_index];
		local btn = GET_CHILD_RECURSIVELY(frame, btn_name);
		if btn == nil then return; end
		frame:SetValue(select_index);
	end
end

function RESTART_CONTENTS_SELECT(frame)
	if frame == nil then return; end
	local list = RESTART_CONTENTS_GET_COMMAND_LIST(frame);
	if list ~= nil and #list > 0 then
		local select_index = frame:GetValue();
		local btn_name = list[select_index];
		local btn = GET_CHILD_RECURSIVELY(frame, btn_name);
		if btn == nil then return; end
		local x, y = GET_SCREEN_XY(btn);
		mouse.SetPos(x, y);
		mouse.SetHidable(0);
	end
end

function RESTART_CONTENTS_ON_SELECT(frame)
	if frame == nil then return; end
	local list = RESTART_CONTENTS_GET_COMMAND_LIST(frame);
	if list ~= nil and #list > 0 then
		local select_index = frame:GetValue();
		local btn_name = list[select_index];
		local btn = GET_CHILD_RECURSIVELY(frame, btn_name);
		if btn ~= nil then
			local scp = btn:GetEventScript(ui.LBUTTONUP);
			local arg_str = btn:GetEventScriptArgString(ui.LBUTTONUP);
			local func = _G[scp];
			func(frame, btn, arg_str);
		end
	end
end

function RESTART_CONTENTS_ON_RESURRECT_SAVE_POINT(frame)
	if frame == nil or frame:IsVisible() == 0 then return; end
	local actor = GetMyActor();
	if actor:IsDead() == 0 then return; end
	restart.SendRestartSavePointMsg();
	frame:ShowWindow(0);
end

function RESTART_CONTENTS_ON_RESURRECT_HERE(frame)
	if frame == nil or frame:IsVisible() == 0 then return; end
	local cristal = GetClass("Item", "RestartCristal");
	local cristal_14d = GetClass("Item", "RestartCristal_14d");
	local cristal_recycle = GetClass("Item", "RestartCristal_Recycle");
	local item = nil;
	if cristal ~= nil then
		local class_name = TryGetProp(cristal, "ClassName", "None");
		item = session.GetInvItemByName(class_name);
	end
	local item_14d = nil;
	if cristal_14d ~= nil then
		local class_name = TryGetProp(cristal_14d, "ClassName", "None");
		item_14d = session.GetInvItemByName(class_name);
	end
	local item_recycle = nil;
	if cristal_recycle ~= nil then
		local class_name = TryGetProp(cristal_recycle, "ClassName", "None");
		item_recycle = session.GetInvItemByName(class_name);
	end
	if item == nil and item_14d == nil and item_recycle == nil then
		local name = TryGetProp(cristal, "Name");
		ui.SysMsg(ScpArgMsg("NotEnough{ItemName}Item","ItemName", name));
		return;
	end
	restart.SendRestartHereMsg();
	frame:ShowWindow(0);
end

function RESTART_CONTENTS_ON_RESSURECT_MAINLAYER(frame)
	if frame == nil or frame:IsVisible() == 0 then return; end
	restart.SendRestartMainLayerMsg();
	frame:ShowWindow(0);
end

function RESTART_CONTENTS_ON_GUILD_TOWER(frame)
	if frame == nil or frame:IsVisible() == 0 then return; end
	if IS_EXIST_GUILD_TOWER() == false then return; end
	restart.SendRestartGuildTower();
	frame:ShowWindow(0);
end

function RESTART_CONTENTS_ON_RAID_RETURN(frame)
	if frame == nil or frame:IsVisible() == 0 then return; end
	restart.ReqReturn();
	frame:ShowWindow(0);
end