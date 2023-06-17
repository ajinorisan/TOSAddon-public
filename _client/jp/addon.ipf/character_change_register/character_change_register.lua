-- character_change_register.lua
function CHARACTER_CHANGE_REGISTER_ON_INIT(addon, frame)
	addon:RegisterMsg("REGISTER_SUCCESS", "ON_REGISTER_SUCCESS_UPDATE");
	addon:RegisterMsg("DEREGISTER_SUCCESS", "ON_DEREGISTER_SUCCESS_UPDATE");
end

function CHARACTER_CHANGE_REGISTER_OPEN()
	ui.OpenFrame("character_change_register");
	local frame = ui.GetFrame("character_change_register");
	if frame ~= nil then
		CHARACTER_CHANGE_REGISTER_CREATE_SLOT_LIST(frame);
	end
end

function CHARACTER_CHANGE_REGISTER_REMOVE_LIST(frame, gbox)
	if gbox ~= nil then
		local count = gbox:GetChildCount();
		for i = 0, count - 1 do
			local child = gbox:GetChildByIndex(i);
			if child ~= nil and string.find(child:GetName(), "register_slot_") ~= nil then
				gbox:RemoveChildByIndex(i);
			end
		end
		frame:Invalidate();
	end
end

function CHARACTER_CHANGE_REGISTER_CREATE_SLOT_LIST(frame)
	local list_gbox = GET_CHILD_RECURSIVELY(frame, "slot_list_gbox");
	if list_gbox == nil then return; end
	CHARACTER_CHANGE_REGISTER_REMOVE_LIST(frame, list_gbox);
	local slot_count = GET_CHARACTER_CHANGE_SLOT_COUNT();
	for i = 1, slot_count do
		local height = 160;
		local ctrl_set = list_gbox:CreateOrGetControlSet("character_change_regist_info", "register_slot_"..i, 0, (i - 1) * height);
		local character_name = character_change.GetRegisteredPcName(i);
		if character_name ~= "None" then
			CHARACTER_CHANGE_REGISTER_FILL_INFO_EXIST(ctrl_set, i);
			CHARACTER_CAHNGE_REGISTER_VISIBLE_CTRL(ctrl_set, true);
		else
			CHARACTER_CHANGE_REGISTER_FILL_INFO_NOT_EXIST(ctrl_set, i);
			CHARACTER_CAHNGE_REGISTER_VISIBLE_CTRL(ctrl_set, false);
		end
		ctrl_set:Invalidate();
	end
	frame:Invalidate();
end

function CHARACTER_CHANGE_REGISTER_FILL_INFO_EXIST(ctrl_set, index)	
	if ctrl_set ~= nil then
		local selected_index = character_change.GetRegisteredPcIndexFromCandidateList(index);
		ctrl_set:SetUserValue("selected_index", selected_index);
		ctrl_set:SetUserValue("guid", character_change.GetRegisteredPcGuid(index));
		ctrl_set:SetUserValue("slot_index", index - 1);
		ctrl_set:SetGravity(ui.CENTER_HORZ, ui.TOP);
		local name = GET_CHILD_RECURSIVELY(ctrl_set, "name");
		if name ~= nil then
			name:SetText(character_change.GetRegisteredPcName(index));
		end

		for j = 0, 3 do
			local entry_icon_name = "entry_icon_"..j;
			local entry_icon = GET_CHILD_RECURSIVELY(ctrl_set, entry_icon_name);
			if entry_icon ~= nil then
				local job_id = character_change.GetRegisteredPcJobID(index, j);
				if job_id ~= nil and job_id ~= 0 then
					local job_cls = GetClassByType("Job", job_id);
					if job_cls ~= nil then
						local job_icon = TryGetProp(job_cls, "Icon", "None");
						if job_icon ~= nil and job_icon ~= "None" then
							entry_icon:SetImage(job_icon);
						end

						if j ~= 0 then
							local entry_class_name = "entry_class_name_"..j;
							local entry_class_text = GET_CHILD_RECURSIVELY(ctrl_set, entry_class_name);
							if entry_class_text ~= nil then
								local job_name = TryGetProp(job_cls, "Name", "None");
								if job_name ~= nil and job_name ~= "None" then
									entry_class_text:SetText(job_name);
								end
							end
						end
					end
				else
					if j ~= 0 then
						local entry_class_name = "entry_class_name_"..j;
						local entry_class_text = GET_CHILD_RECURSIVELY(ctrl_set, entry_class_name);
						entry_class_text:SetText("");
						entry_class_text:ShowWindow(0);
						entry_icon:ShowWindow(0);
					end
				end
			end
		end
	end
end

function CHARACTER_CHANGE_REGISTER_FILL_INFO_NOT_EXIST(ctrl_set, index)
	if ctrl_set ~= nil then
		ctrl_set:SetGravity(ui.CENTER_HORZ, ui.TOP);
		ctrl_set:SetUserValue("slot_index", index - 1);
		ctrl_set:SetUserValue("guid", "None");
		ctrl_set:SetSkinName("test_frame_midle_light");
		local main_gb = GET_CHILD_RECURSIVELY(ctrl_set, "main_gb");
		if main_gb ~= nil then
			main_gb:SetEventScript(ui.LBUTTONDOWN, "CHARACTER_CHANGE_REGISTER_SELECT_ITEM");
		end
	end
end

function CHARACTER_CAHNGE_REGISTER_VISIBLE_CTRL(ctrl_set, registered)
	local empty_visible = 1;
	if registered == true then empty_visible = 0; end
	local empty = GET_CHILD_RECURSIVELY(ctrl_set, "empty");
	empty:ShowWindow(empty_visible);

	local other_visible = 1;
	if registered == false then other_visible = 0; end
	local name = GET_CHILD_RECURSIVELY(ctrl_set, "name");
	name:ShowWindow(other_visible);

	local inner_line = GET_CHILD_RECURSIVELY(ctrl_set, "inner_line");
	inner_line:ShowWindow(other_visible);

	local entry_icon_bg = GET_CHILD_RECURSIVELY(ctrl_set, "entry_icon_bg");
	entry_icon_bg:ShowWindow(other_visible);

	local deregist_btn = GET_CHILD_RECURSIVELY(ctrl_set, "deregist_btn");
	deregist_btn:ShowWindow(other_visible);

	for i = 0, 3 do
		local pic_name = "entry_icon_"..i;
		local pic = GET_CHILD_RECURSIVELY(ctrl_set, pic_name);
		pic:ShowWindow(other_visible);
	end

	for i = 1, 3 do
		local class_name = "entry_class_name_"..i;
		local entry_name = GET_CHILD_RECURSIVELY(ctrl_set, class_name);
		entry_name:ShowWindow(other_visible);
	end
end

-- select
function CHARACTER_CHANGE_REGISTER_SELECT_ITEM(ctrl_set, gb, arg_str, arg_num)
	local frame = ctrl_set:GetTopParentFrame();
	if frame ~= nil then
		local x = frame:GetX() + frame:GetWidth();
		local y = frame:GetY();
		local slot_index = ctrl_set:GetUserIValue("slot_index");
		CHARACTER_CHANGE_REGISTER_SELECT_OPEN(x, y, slot_index);
	end
end

-- register & deregister
function CHARACTER_CHANGE_REGISTER_ADD_ITEM(add_index, reg_char_index, guid)
	local frame = ui.GetFrame("character_change_register");
	if frame == nil then return; end
	local gbox = GET_CHILD_RECURSIVELY(frame, "slot_list_gbox");
	if gbox == nil then return; end
	local count = gbox:GetChildCount();
	for i = 0, count - 1 do
		local child = gbox:GetChildByIndex(i);
		if child ~= nil and string.find(child:GetName(), "register_slot_") ~= nil then
			local slot_index = child:GetUserIValue("slot_index");
			if slot_index == add_index then
				local str = ScpArgMsg("AskCharacterRegist", "slot_index", slot_index + 1);
				local yes_scp = string.format("DO_CHARACTER_CHANGE_REGISTER(%s, %d)", guid, slot_index);
				local no_scp = string.format("CHARACTER_CHANGE_REGISTER_SELECT_CLICK_ITEM_SKIN_VISIBLE_BY_INDEX(%d, %d)", reg_char_index, 0);
				ui.MsgBox(str, yes_scp, no_scp);
				break;
			end
		end
	end
end

function DO_CHARACTER_CHANGE_REGISTER(guid, slot_index)
	if character_change.IsRegistedCharacterByGuid(guid) == false then
		character_change.RegisterMyCharacter(guid, slot_index);
		ui.CloseFrame("character_change_register_select");
	end
end

function CHARACTER_CHANGE_REGISTER_REMOVE_ITEM(parent, btn)
	local upper_parent = parent:GetParent();
	local ctrl_set = upper_parent:GetParent();
	if ctrl_set ~= nil then
		local slot_index = ctrl_set:GetUserIValue("slot_index");
		local str = ScpArgMsg("AskCharacterDeRegist", "slot_index", slot_index + 1);
		local guid = ctrl_set:GetUserValue("guid");
		local yes_scp = string.format("DO_CHARACTER_CHANGE_DEREGISTER(%s)", guid);
		ui.MsgBox(str, yes_scp, "None");
	end
end

function DO_CHARACTER_CHANGE_DEREGISTER(guid)
	if guid == "None" then return; end
	if character_change.IsRegistedCharacterByGuid(guid) == true then
		character_change.DeregisterByCharacter(guid);
	end
end

function ON_REGISTER_SUCCESS_UPDATE(frame, msg, arg_str, arg_num)
	if frame == nil then return; end
	local gbox = GET_CHILD_RECURSIVELY(frame, "slot_list_gbox");
	CHARACTER_CHANGE_REGISTER_REMOVE_LIST(frame, gbox);
	CHARACTER_CHANGE_REGISTER_CREATE_SLOT_LIST(frame);
end

function ON_DEREGISTER_SUCCESS_UPDATE(frame, msg, arg_str, arg_num)
	if frame == nil then return; end
	local gbox = GET_CHILD_RECURSIVELY(frame, "slot_list_gbox");
	CHARACTER_CHANGE_REGISTER_REMOVE_LIST(frame, gbox);
	CHARACTER_CHANGE_REGISTER_CREATE_SLOT_LIST(frame);
end