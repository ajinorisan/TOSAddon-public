-- character change
function CHARACTER_CHANGE_ON_INIT(addon, frame)
	addon:RegisterMsg("RELOAD_CHARACTER_CHANGE_LIST", "CHARACTER_CHANGE_RELOAD_LIST");
end

function CHARACTER_CHANGE_OPEN()
	ui.OpenFrame("character_change");
	local frame = ui.GetFrame("character_change");
	if frame ~= nil then
		CHARACTER_CHANGE_CREATE_LIST(frame);
	end
end

function CHARACTER_CHANGE_RELOAD_LIST(frame)
	CHARACTER_CHANGE_CREATE_LIST(frame);
end

function CHARACTER_CHANGE_REMOVE_LIST(frame, gbox)
	local count = gbox:GetChildCount();
	for i = 0, count - 1 do
		local child = gbox:GetChildByIndex(i);
		if child ~= nil and string.find(child:GetName(), "candidate_char_") ~= nil then
			gbox:RemoveChildByIndex(i);
		end
	end
	frame:Invalidate();
end

function CHARACTER_CHANGE_CREATE_LIST(frame)
	local gbox = GET_CHILD_RECURSIVELY(frame, "gbox");
	if gbox == nil then return; end
	CHARACTER_CHANGE_REMOVE_LIST(frame, gbox);
	local add_height = 0;
	local change_list_count = character_change.GetCurrentRegisteredCharacterCount();
	for i = 0, change_list_count do
		local character_name = character_change.GetRegisteredPcName(i);
		if character_name ~= "None" then
			local start_y = 50;
			local height = 150 + add_height;
			local ctrl_set = gbox:CreateOrGetControlSet("character_change_info", "candidate_char_"..i, 25, start_y + (i * height));
			if ctrl_set ~= nil then
				local main_char_gb = GET_CHILD_RECURSIVELY(ctrl_set, "main_char_gb");
				if i == 0 then
					ctrl_set:SetSkinName("None");
					main_char_gb:ShowWindow(1);
					add_height = 35;
				else
					ctrl_set:SetSkinName("monster_card_list");
					main_char_gb:ShowWindow(0);
					add_height = 25;
				end

				ctrl_set:SetUserValue("slot_index", i);
				ctrl_set:SetUserValue("select", 0);
				local main_gb = GET_CHILD_RECURSIVELY(ctrl_set, "main_gb");
				if main_gb ~= nil then
					main_gb:SetEventScript(ui.LBUTTONDOWN, "CHARACTER_CHANGE_SELECT_ITEM");
					main_gb:SetEventScriptArgNumber(ui.LBUTTONDOWN, -1);
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
						local job_id = character_change.GetRegisteredPcJobID(i, j);
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
				end
			end
		end
	end
end

-- select
function CHARACTER_CHANGE_SELECT_ITEM(ctrl_set, gb, arg_str, arg_num)
	local frame = ctrl_set:GetTopParentFrame();
	local select = ctrl_set:GetUserIValue("select");
	if select == 0 then
		frame:SetUserValue("select_slot_index", ctrl_set:GetUserIValue("slot_index"));
		CHARACTER_CHANGE_SELECT_ITEM_SKIN_VISIBLE(ctrl_set, 1);
		ctrl_set:SetUserValue("select", 1);
	elseif select == 1 then
		CHARACTER_CHANGE_SELECT_ITEM_SKIN_VISIBLE(ctrl_set, 0);
		ctrl_set:SetUserValue("select", 0);		
	end
end

-- skin visible
function CHARACTER_CHANGE_SELECT_ITEM_SKIN_VISIBLE(ctrl_set, visible)
	local select_gb = GET_CHILD_RECURSIVELY(ctrl_set, "select_gb");
	if select_gb ~= nil then 
		select_gb:ShowWindow(visible);
	end
	CHARACTER_CHANGE_SELECTED_ITEM_RESET();
end

-- selected item reset
function CHARACTER_CHANGE_SELECTED_ITEM_RESET()
	local frame = ui.GetFrame("character_change");
	if frame == nil then return; end
	local gbox = GET_CHILD_RECURSIVELY(frame, "gbox");
	if gbox == nil then return; end
	local child_count = gbox:GetChildCount();
	for i = 0, child_count - 1 do
		local ctrl_set = gbox:GetChildByIndex(i);
		if ctrl_set ~= nil and string.find(ctrl_set:GetName(), "candidate_char_") ~= nil then
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

-- change
function DO_CHARACTER_CHANGE(parent, ctrl)
	local frame = parent:GetTopParentFrame();
	if frame ~= nil then
		local select_slot_index = frame:GetUserIValue("select_slot_index");
		character_change.RequestCharacterChange(select_slot_index);
		ui.CloseFrame("character_change");
	end
end
