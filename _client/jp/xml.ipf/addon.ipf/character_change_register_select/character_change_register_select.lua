-- character_change_register_select.lua
function CHARACTER_CHANGE_REGISTER_SELECT_ON_INIT(addon, frame)
	addon:RegisterMsg("REGISTER_SUCCESS", "ON_REGISTER_SUCCESS_UPDATE");
	addon:RegisterMsg("DEREGISTER_SUCCESS", "ON_DEREGISTER_SUCCESS_UPDATE");
end

function CHARACTER_CHANGE_REGISTER_SELECT_OPEN(x, y, slot_index)
	ui.OpenFrame("character_change_register_select");
	local frame = ui.GetFrame("character_change_register_select");
	if frame ~= nil then
		frame:SetOffset(x, y);
		frame:SetUserValue("reg_slot_index", slot_index);
		CHARACTER_CHANGE_REGISTER_SELECT_CREATE_LIST(frame);
	end
end

function CHARACTER_CHANGE_REGISTER_SELECT_REMOVE_LIST(frame, gbox)
	local count = gbox:GetChildCount();
	for i = 0, count - 1 do
		local child = gbox:GetChildByIndex(i);
		if child ~= nil and string.find(child:GetName(), "candidate_regist_char_") ~= nil then
			gbox:RemoveChildByIndex(i);
		end
	end
	frame:Invalidate();
end

function CHARACTER_CHANGE_REGISTER_SELECT_CREATE_LIST(frame)
	local list_gbox = GET_CHILD_RECURSIVELY(frame, "character_list_gbox");
	if list_gbox == nil then return; end
	CHARACTER_CHANGE_REGISTER_SELECT_REMOVE_LIST(frame, list_gbox);
	local change_list_count = character_change.GetCandidatePcCount();
	local index_list = 0;
	for i = 0, change_list_count - 1 do
		local character_name = character_change.GetCandidatePcName(i);
		if character_name ~= "None" then
			local height = 150;
			local start_x = 35;
			if character_change.IsRegistedCharacterByIndex(i) == false then
				local ctrl_set = list_gbox:CreateOrGetControlSet("character_change_info", "candidate_regist_char_"..index_list, start_x, index_list * height);
				if ctrl_set ~= nil then
					ctrl_set:SetUserValue("slot_index", i);
					ctrl_set:SetUserValue("select", 0);
					ctrl_set:SetUserValue("guid", character_change.GetCandidatePcGuid(i));
					local main_gb = GET_CHILD_RECURSIVELY(ctrl_set, "main_gb");
					if main_gb ~= nil then
						main_gb:SetEventScript(ui.LBUTTONDOWN, "CHARACTER_CHANGE_REGISTER_SELECT_CLICK_ITEM");
					end
		
					local select_gb = GET_CHILD_RECURSIVELY(ctrl_set, "select_gb");
					if select_gb ~= nil then
						select_gb:ShowWindow(0);
					end
	
					local name = GET_CHILD_RECURSIVELY(ctrl_set, "name");
					if name ~= nil then
						name:SetText(character_name);
					end
	
					for j = 0, 3 do
						local entry_icon_name = "entry_icon_"..j;
						local entry_icon = GET_CHILD_RECURSIVELY(ctrl_set, entry_icon_name);
						if entry_icon ~= nil then
							local job_id = character_change.GetCandidatePcJobID(i, j);
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
									entry_class_text:ShowWindow(0);
									entry_icon:ShowWindow(0);
								end
							end
						end
						ctrl_set:Invalidate();
					end
				end
				index_list = index_list + 1;
			end
		end
	end
end

-- select
function CHARACTER_CHANGE_REGISTER_SELECT_CLICK_ITEM(ctrl_set, gb, arg_str, arg_num)
	local frame = ctrl_set:GetTopParentFrame();
	local select = ctrl_set:GetUserIValue("select");
	if select == 0 then
		local add_index = frame:GetUserIValue("reg_slot_index");
		local reg_char_index = ctrl_set:GetUserValue("slot_index");
		local guid = ctrl_set:GetUserValue("guid");
		CHARACTER_CHANGE_REGISTER_ADD_ITEM(add_index, reg_char_index, guid);
		CHARACTER_CHANGE_REGISTER_SELECT_CLICK_ITEM_SKIN_VISIBLE(ctrl_set, 1);
		ctrl_set:SetUserValue("select", 1);
	elseif select == 1 then
		CHARACTER_CHANGE_REGISTER_SELECT_CLICK_ITEM_SKIN_VISIBLE(ctrl_set, 0);
		ctrl_set:SetUserValue("select", 0);		
	end
end

-- skin visible
function CHARACTER_CHANGE_REGISTER_SELECT_CLICK_ITEM_SKIN_VISIBLE_BY_INDEX(index, visible)
	local frame = ui.GetFrame("character_change_register_select");
	if frame ~= nil then
		local gbox = GET_CHILD_RECURSIVELY(frame, "character_list_gbox");
		local count = gbox:GetChildCount();
		for i = 0, count - 1 do
			local child = gbox:GetChildByIndex(i);
			if child ~= nil and string.find(child:GetName(), "candidate_regist_char_") ~= nil then
				if child:GetUserIValue("slot_index") == index then
					CHARACTER_CHANGE_REGISTER_SELECT_CLICK_ITEM_SKIN_VISIBLE(child, visible);
				end
			end
		end
	end
end

function CHARACTER_CHANGE_REGISTER_SELECT_CLICK_ITEM_SKIN_VISIBLE(ctrl_set, visible)
	local select_gb = GET_CHILD_RECURSIVELY(ctrl_set, "select_gb");
	if select_gb ~= nil then 
		select_gb:ShowWindow(visible);
	end
	CHARACTER_CHANGE_REGISTER_CLICK_ITEM_RESET();
end

-- selected item reset
function CHARACTER_CHANGE_REGISTER_CLICK_ITEM_RESET()
	local frame = ui.GetFrame("character_change_register_select");
	if frame == nil then return; end
	local gbox = GET_CHILD_RECURSIVELY(frame, "character_list_gbox");
	if gbox == nil then return; end
	local child_count = gbox:GetChildCount();
	for i = 0, child_count - 1 do
		local ctrl_set = gbox:GetChildByIndex(i);
		if ctrl_set ~= nil and string.find(ctrl_set:GetName(), "candidate_regist_char_") ~= nil then
			local selected = ctrl_set:GetUserIValue("select");
			if selected == 1 then
				local select_gb = GET_CHILD_RECURSIVELY(ctrl_set, "select_gb");
				if select_gb ~= nil then
					select_gb:ShowWindow(0);
					ctrl_set:SetUserValue("select", 0);
				end
			end
		end
	end
end