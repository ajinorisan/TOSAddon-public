function AETHER_GEM_REINFORCE_ON_INIT(addon, frame)
	addon:RegisterMsg("AETHER_GEM_REINFORCE_MAX_COUNT", "ON_SET_AETHER_GEM_REINFORCE_MAX_COUNT");
	addon:RegisterMsg("OPEN_DLG_ARTHER_GEM_REINFORCE", "ON_OPEN_DLG_AETHER_GEM_REINFORCE");
	addon:RegisterMsg("AETHER_GEM_REINFORCE_RESULT", "ON_AETHER_GEM_REINFORCE_RESULT");
	addon:RegisterMsg("AETHER_GEM_REINFORCE_TX_FAIL_THEN_RESET_UI","ON_AETHER_GEM_REINFORCE_TX_FAIL_THEN_RESET_UI")
end

function ON_OPEN_DLG_AETHER_GEM_REINFORCE(frame)
	frame:ShowWindow(1);
	AETHER_GEM_REINFORCE_INIT_VISIBLE(frame);
end

function AETHER_GEM_REINFORCE_OPEN(frame)
	frame:ShowWindow(1);
	AETHER_GEM_REINFORCE_INIT_VISIBLE(frame);
end

function AETHER_GEM_REINFORCE_CLOSE(frame)
	frame:ShowWindow(0);
end

-- visible
-- init
function AETHER_GEM_REINFORCE_INIT_VISIBLE(frame)
	if frame == nil then return; end
	AEHTER_GEM_REINFORCE_SET_VISIBLE_BY_TOP_GROUPBOX(frame, 0);
	AETHER_GEM_REINFORCE_SET_VISIBLE_BY_RESULT_BOX(frame, 0);
	AETHER_GEM_REINFORCE_SET_VISIBLE_BY_SELECT_GEM(frame, 0);
	AETHER_GEM_REINFORCE_SET_VISIBLE_BY_CLEARSTAGE(frame, 0);
	AETHER_GEM_REINFORCE_SET_VISIBLE_BY_RATIO(frame, 0);
	AETHER_GEM_REINFORCE_SET_VISIBLE_BY_REINFORCE_BUTTON(frame, 0);
	AETHER_GEM_REINFORCE_SET_VISIBLE_BY_SUMMIT_BUTTON(frame, 0);
	AETHER_GEM_REINFORCE_SET_HITTEST_SELECT_GEM(frame, 1);
	AETHER_GEM_REINFORCE_TAB_INIT(frame);
end

-- reinforce slot 
function AEHTER_GEM_REINFORCE_SET_VISIBLE_BY_TOP_GROUPBOX(frame, visible)
	if frame == nil then return; end
	local gem_slot_bg = GET_CHILD_RECURSIVELY(frame, "gem_slot_bg");
	gem_slot_bg:ShowWindow(visible);
	local gem_slot = GET_CHILD_RECURSIVELY(frame, "gem_slot");
	gem_slot:ShowWindow(visible);
end

-- result bg
function AETHER_GEM_REINFORCE_SET_VISIBLE_BY_RESULT_BOX(frame, visible)
	if frame == nil then return; end
	local reinforce_result_gb = GET_CHILD_RECURSIVELY(frame, "reinforce_result_gb");
	reinforce_result_gb:ShowWindow(visible);
end

-- result success
function AETHER_GEM_REINFORCE_SET_VISIBLE_BY_SUCCESS_RESULT(frame, visible)
	if frame == nil then return; end
	local success_effect_bg = GET_CHILD_RECURSIVELY(frame, "success_effect_bg");
	success_effect_bg:ShowWindow(visible);
	local success_skin = GET_CHILD_RECURSIVELY(frame, "success_skin");
	success_skin:ShowWindow(visible);
	local success_text = GET_CHILD_RECURSIVELY(frame, "text_success");
	success_text:ShowWindow(visible);
end

-- result failed
function AETHER_GEM_REINFORCE_SET_VISIBLE_BY_FAILED_RESULT(frame, visible)
	if frame == nil then return; end
	local fail_effect_bg = GET_CHILD_RECURSIVELY(frame, "fail_effect_bg");
	fail_effect_bg:ShowWindow(visible);
	local fail_skin = GET_CHILD_RECURSIVELY(frame, "fail_skin");
	fail_skin:ShowWindow(visible);
	local text_fail = GET_CHILD_RECURSIVELY(frame, "text_fail");
	text_fail:ShowWindow(visible);
end

-- select gem info
function AETHER_GEM_REINFORCE_SET_VISIBLE_BY_SELECT_GEM(frame, visible)
	if frame == nil then return; end
	local select_gem_text = GET_CHILD_RECURSIVELY(frame, "select_gem_text");
	if visible == 0 then
		select_gem_text:ShowWindow(1);
	else
		select_gem_text:ShowWindow(0);
	end
	local select_gem_name_text = GET_CHILD_RECURSIVELY(frame, "select_gem_name_text");
	select_gem_name_text:ShowWindow(visible);
	local select_gem_level_text = GET_CHILD_RECURSIVELY(frame, "select_gem_level_text");
	select_gem_level_text:ShowWindow(visible);
end

-- clear stage info
function AETHER_GEM_REINFORCE_SET_VISIBLE_BY_CLEARSTAGE(frame, visible)
	if frame == nil then return; end
	local clear_stage_gb = GET_CHILD_RECURSIVELY(frame, "clear_stage_gb");
	clear_stage_gb:ShowWindow(visible);
	local clearstage_text = GET_CHILD_RECURSIVELY(frame, "clearstage_text");
	clearstage_text:ShowWindow(visible);
end

-- success ratio info
function AETHER_GEM_REINFORCE_SET_VISIBLE_BY_RATIO(frame, visible)
	if frame == nil then return; end
	local reinforce_ratio_gb = GET_CHILD_RECURSIVELY(frame, "reinforce_ratio_gb");
	reinforce_ratio_gb:ShowWindow(visible);
end

-- reinforce button
function AETHER_GEM_REINFORCE_SET_VISIBLE_BY_REINFORCE_BUTTON(frame, visible)
	if frame == nil then return; end
	local do_reinforce = GET_CHILD_RECURSIVELY(frame, "do_reinforce");
	do_reinforce:ShowWindow(visible);
end

-- summit button
function AETHER_GEM_REINFORCE_SET_VISIBLE_BY_SUMMIT_BUTTON(frame, visible)
	if frame == nil then return; end
	local send_ok_reinforce = GET_CHILD_RECURSIVELY(frame, "send_ok_reinforce");
	send_ok_reinforce:ShowWindow(visible);	
end

-- tab
function AETHER_GEM_REINFORCE_TAB_INIT(frame)
	if frame == nil then return; end
	local tab = GET_CHILD_RECURSIVELY(frame, "tab");
	if tab ~= nil then
		local init_index = 0;
		tab:SelectTab(init_index);
		AETHER_GEM_REINFORCE_CREATE_GEM_LIST(frame, init_index);
	end
end

function AETHER_GEM_REINFORCE_TAB_CHANGE(parent, ctrl)
	if parent == nil then return; end
	local frame = parent:GetTopParentFrame();
	if frame ~= nil then
		local tab = GET_CHILD_RECURSIVELY(frame, "tab");
		if tab ~= nil then
			local slot = GET_CHILD_RECURSIVELY(frame, "gem_slot");
			AETHER_GEM_REINFORCE_SELECT_GEM_REMOVE(frame, slot);
			local index = tab:GetSelectItemIndex();
			AETHER_GEM_REINFORCE_CREATE_GEM_LIST(frame, index);
		end
	end
end

-- gem list
function AETHER_GEM_REINFORCE_CREATE_GEM_LIST(frame, index)
	if frame == nil then return; end
	local gemlist_gb = GET_CHILD_RECURSIVELY(frame, "gemlist_gb", "ui::CGroupBox");
	local gem_slot_list = GET_CHILD_RECURSIVELY(frame, "gem_slot_list", "ui::CSlotSet");
	local gem_slot_list_inven = GET_CHILD_RECURSIVELY(frame, "gem_slot_list_inven", "ui::CSlotSet");
	gem_slot_list:ClearIconAll();
	gem_slot_list_inven:ClearIconAll();
	if index == 0 then
		gem_slot_list:ShowWindow(1);
		gem_slot_list_inven:ShowWindow(0);
		gem_slot_list:SetMaxSelectionCount(1);
		AETHER_GEM_REINFORCE_CREATE_GEM_LIST_BY_EQUIPMENT(gem_slot_list);	
	else
		gem_slot_list:ShowWindow(0);
		gem_slot_list_inven:ShowWindow(1);
		gem_slot_list_inven:SetMaxSelectionCount(1);
		AETHER_GEM_REINFORCE_CREATE_GEM_LIST_BY_INVENTORY(gem_slot_list_inven);
	end
end

-- gem list equip 
function SORT_BY_AETHER_GEM_LEVEL_BY_EQUIP(a, b)
	local gem_level_a = a[2];
	local gem_level_b = b[2];
	return gem_level_a > gem_level_b;
end

function AETHER_GEM_REINFORCE_CREATE_GEM_LIST_BY_EQUIPMENT(gem_slot_list)
	if gem_slot_list ~= nil then
		local sorted_list = {};
		local equip_item_list = session.GetEquipItemList();
		local equip_guid_list = equip_item_list:GetGuidList();
		local count = equip_guid_list:Count();
		for i = 0, count - 1 do
			local guid = equip_guid_list:Get(i);
			local equip_item = equip_item_list:GetItemByGuid(guid);
			if equip_item ~= nil and equip_item:GetObject() ~= nil then
				local gem_class, gem_level, index, guid = GET_AETHER_GEM_REINFORCE_EQUIP_GEM_INFO(equip_item);
				if gem_class ~= nil and gem_level ~= 0 then
					local gem_info = { gem_class, gem_level, index, guid };
					sorted_list[#sorted_list + 1] = gem_info;
				end
			end
		end
		table.sort(sorted_list, SORT_BY_AETHER_GEM_LEVEL_BY_EQUIP);

		if #sorted_list > 0 then
			for i = 1, #sorted_list do
				local gem_info = sorted_list[i];
				if gem_info ~= nil then
					local slot = gem_slot_list:GetSlotByIndex(i - 1);
					if slot ~= nil then
						slot:SetUserValue("is_gem_equip", 1);
						slot:SetUserValue("gem_class_id", gem_info[1].ClassID);
						slot:SetUserValue("gem_name", gem_info[1].Name);
						slot:SetUserValue("gem_level", gem_info[2]);
						slot:SetUserValue("gem_socket_index", gem_info[3]);
						slot:SetUserValue("gem_parent_guid", gem_info[4]);
						slot:SetMaxSelectCount(1);
						slot:SetText("{s14}{ol}{#FFFFFF}{b}Lv."..gem_info[2], "count", ui.LEFT, ui.TOP, 3, 2);
						SET_SLOT_ITEM_CLS(slot, gem_info[1]);
						SET_SLOT_BG_BY_ITEMGRADE(slot,gem_info[1]);
		
						local icon = slot:GetIcon();
						if icon ~= nil then
							icon:SetTooltipArg(gem_info[4], gem_info[1].ClassID, 0);
						end
					end
				end
			end
		end
	end
end

-- get gem equip info
function GET_AETHER_GEM_REINFORCE_EQUIP_GEM_INFO(equip_item)
	if equip_item == nil then return nil, 0; end
	local item_object = GetIES(equip_item:GetObject());
	local item_grade = TryGetProp(item_object, "ItemGrade", 0);
	if item_grade == 6 then
		local start_index, end_index = GET_AETHER_GEM_INDEX_RANGE(TryGetProp(item_object, 'UseLv', 0))	
		for i = start_index, end_index do
			if equip_item:IsAvailableSocket(i) == true then
				local gem_class_id = equip_item:GetEquipGemID(i);
				if gem_class_id ~= 0 then
					local gem_class = GetClassByType("Item", gem_class_id);
					if gem_class ~= nil then
						local group_name = TryGetProp(gem_class, "GroupName", "None");
						if group_name == "Gem_High_Color" then
							local target_item_guid = equip_item:GetIESID();
							local gem_level = equip_item:GetEquipGemLv(i);
							return gem_class, gem_level, i, target_item_guid; -- class, level, index, target_item_guid
						end
					end
				end
			end
		end
	end
	return nil, 0, 0, "None";
end

-- gem list inven
function SORT_BY_AETHER_GEM_LEVEL(a, b)
	local gem_level_a = 0;
	local gem_level_b = 0;
	local object_a = GetIES(a:GetObject());
	local object_b = GetIES(b:GetObject());
	if TryGetProp(object_a, "GemType", "None") == "Gem_High_Color" then
		gem_level_a = get_current_aether_gem_level(object_a);
	end
	if TryGetProp(object_b, "GemType", "None") == "Gem_High_Color" then
		gem_level_b = get_current_aether_gem_level(object_b);
	end
	return gem_level_a > gem_level_b;
end

function AETHER_GEM_REINFORCE_CREATE_GEM_LIST_BY_INVENTORY(gem_slot_list)
	if gem_slot_list ~= nil then
		local sorted_list = {};
		local inv_item_list = session.GetInvItemList();
		local inv_guid_list = inv_item_list:GetGuidList();
		local count = inv_guid_list:Count();
		for i = 0, count - 1 do
			local guid = inv_guid_list:Get(i);
			local inv_item = inv_item_list:GetItemByGuid(guid);
			if inv_item ~= nil and inv_item:GetObject() ~= nil then
				local inv_item_object = GetIES(inv_item:GetObject());
				local group_name = TryGetProp(inv_item_object, "GroupName", "None");
				if group_name == "Gem_High_Color" then
					sorted_list[#sorted_list + 1] = inv_item;
				end
			end
		end
		table.sort(sorted_list, SORT_BY_AETHER_GEM_LEVEL);

		if #sorted_list > 0 then
			for i = 1, #sorted_list do
				local item = sorted_list[i];
				if item ~= nil then
					local object = GetIES(item:GetObject());
					local gem_level = get_current_aether_gem_level(object);
					local slot = gem_slot_list:GetSlotByIndex(i - 1);
					if slot ~= nil then
						slot:SetUserValue("is_gem_equip", 0);
						slot:SetUserValue("gem_guid", item:GetIESID());
						slot:SetMaxSelectCount(item.count);
						SET_SLOT_ITEM(slot, item);
						SET_SLOT_BG_BY_ITEMGRADE(slot,object);
						SET_SLOT_ITEM_TEXT_USE_INVCOUNT(slot, item, object, item.count);
					end
				end
			end
		end
	end
end

-- select gem
function AETHER_GEM_REINFORCE_SELECT_GEM(frame, slot)
	if frame == nil or slot == nil then return; end
	ui.EnableSlotMultiSelect(0);
	local is_gem_equip = slot:GetUserIValue("is_gem_equip");
	AETHER_GEM_REINFORCE_SELECT_GEM_PRE_SETTING(frame, slot);
	AETHER_GEM_REINFORCE_SELECT_GEM_UPDATE(frame, slot, is_gem_equip);
end

function AETHER_GEM_REINFORCE_SELECT_GEM_PRE_SETTING(frame, slot)
	local top_frame = frame:GetTopParentFrame();
	if top_frame == nil then return; end
	AEHTER_GEM_REINFORCE_SET_VISIBLE_BY_TOP_GROUPBOX(top_frame, 1);
	AETHER_GEM_REINFORCE_SET_VISIBLE_BY_SELECT_GEM(top_frame, 1);
	AETHER_GEM_REINFORCE_SET_VISIBLE_BY_CLEARSTAGE(top_frame, 1);
	AETHER_GEM_REINFORCE_SET_VISIBLE_BY_RATIO(top_frame, 1);
	AETHER_GEM_REINFORCE_SET_VISIBLE_BY_REINFORCE_BUTTON(top_frame, 1);
end

function AETHER_GEM_REINFORCE_SELECT_GEM_UPDATE(frame, slot, is_equip)
	if slot == nil then return; end
	local top_frame = frame:GetTopParentFrame();
	if top_frame == nil then return; end
	if is_equip == 0 then
		local guid = slot:GetUserValue("gem_guid");
		if guid ~= nil and guid ~= "None" then
			local inv_item = session.GetInvItemByGuid(guid);
			if inv_item ~= nil then
				AETHER_GEM_REINFORCE_CREATE_GEM_INFO(top_frame, inv_item, is_equip);
			end
		end
	else
		AETHER_GEM_REINFORCE_CREATE_GEM_INFO_BY_EQUIP(top_frame, slot, is_equip);
	end
end

-- select gem info : inven
function AETHER_GEM_REINFORCE_CREATE_GEM_INFO(frame, inv_item, is_equip)
	if frame == nil or inv_item == nil then return; end
	local item_object = GetIES(inv_item:GetObject());
	local item_class = GetClassByType("Item", inv_item.type);
	if item_object ~= nil and item_class ~= nil then
		if TryGetProp(item_object, "GemType", "None") ~= "Gem_High_Color" then
			ui.SysMsg(ClMsg("IsNotAetherGem"));
			return;
		end

		-- slot
		local gem_slot = GET_CHILD_RECURSIVELY(frame, "gem_slot");
		if gem_slot ~= nil then
			gem_slot:SetUserValue("select_gem_is_equip", is_equip);
			gem_slot:SetUserValue("select_gem_guid", inv_item:GetIESID());
			SET_SLOT_ITEM_CLS(gem_slot, item_class);
		end

		-- name
		local gem_name_text = GET_CHILD_RECURSIVELY(frame, "select_gem_name_text");
		if gem_name_text ~= nil then
			local name = dic.getTranslatedStr(TryGetProp(item_class, "Name", "None"));
			local name_str = string.format("{@st204_purple}{s18}%s{/}{/}", name);
			gem_name_text:SetTextByKey("value", name_str);
		end

		-- level
		local gem_level_text = GET_CHILD_RECURSIVELY(frame, "select_gem_level_text");
		if gem_level_text ~= nil then
			local level = get_current_aether_gem_level(item_object);
			local level_str = string.format("{@st204_purple}{s18}%s{/}{/}", level);
			gem_level_text:SetTextByKey("value", level_str);
		end

		-- ratio
		AETHER_GEM_REINFORCE_SUCCESS_RATIO_UPDATE(frame, item_object, is_equip);

		-- clear stage
		AETHER_GEM_REINFORCE_CLEAR_STAGE_UPDATE(frame);

		-- reinforce count
		AETHER_GEM_REINFORCE_DO_REINFORCE_BTN_UPDATE(frame);
	end
end

-- select gem info : equip
function AETHER_GEM_REINFORCE_CREATE_GEM_INFO_BY_EQUIP(frame, slot, is_equip)
	if frame == nil or slot == nil then return; end
	local gem_class_id = slot:GetUserIValue("gem_class_id");
	local item_class = GetClassByType("Item", gem_class_id);
	if item_class ~= nil then
		if TryGetProp(item_class, "GemType", "None") ~= "Gem_High_Color" then
			ui.SysMsg(ClMsg("IsNotAetherGem"));
			return;
		end

		-- slot
		local gem_slot = GET_CHILD_RECURSIVELY(frame, "gem_slot");
		if gem_slot ~= nil then
			local socket_index = slot:GetUserIValue("gem_socket_index");
			gem_slot:SetUserValue("select_gem_socket_index", socket_index);
			gem_slot:SetUserValue("select_gem_is_equip", is_equip);
			gem_slot:SetUserValue("select_gem_name", slot:GetUserValue("gem_name"));
			gem_slot:SetUserValue("select_gem_parent_guid", slot:GetUserValue("gem_parent_guid"));
			SET_SLOT_ITEM_CLS(gem_slot, item_class);
		end

		-- name
		local gem_name_text = GET_CHILD_RECURSIVELY(frame, "select_gem_name_text");
		if gem_name_text ~= nil then
			local name = dic.getTranslatedStr(slot:GetUserValue("gem_name"));
			local name_str = string.format("{@st204_purple}{s18}%s{/}{/}", name);
			gem_name_text:SetTextByKey("value", name_str);
		end

		-- level
		local gem_level_text = GET_CHILD_RECURSIVELY(frame, "select_gem_level_text");
		if gem_level_text ~= nil then
			local level = slot:GetUserIValue("gem_level");
			local level_str = string.format("{@st204_purple}{s18}%s{/}{/}", level);
			gem_level_text:SetTextByKey("value", level_str);
		end

		-- ratio
		AETHER_GEM_REINFORCE_SUCCESS_RATIO_UPDATE(frame, item_class, is_equip);

		-- clear stage
		AETHER_GEM_REINFORCE_CLEAR_STAGE_UPDATE(frame);

		-- reinforce count
		AETHER_GEM_REINFORCE_DO_REINFORCE_BTN_UPDATE(frame);
	end
end

-- clear stage
function AETHER_GEM_REINFORCE_CLEAR_STAGE_UPDATE(frame)
	if frame == nil then return; end
	local clear_stage = get_solo_dungeon_etc_clear_stage();
	if clear_stage ~= nil then
		local clearstage_text = GET_CHILD_RECURSIVELY(frame, "clearstage_text");
		local text = ClMsg("clear_stage")..clear_stage;
		clearstage_text:SetTextByKey("value", text);
	end
end

-- do reinforce button
function AETHER_GEM_REINFORCE_DO_REINFORCE_BTN_UPDATE(frame)
	if frame == nil then return; end
	local do_reinforce = GET_CHILD_RECURSIVELY(frame, "do_reinforce");
	local reinforce_Cnt_Remain = GET_CHILD_RECURSIVELY(frame, "reinforce_Cnt_Remain");
	if do_reinforce ~= nil and reinforce_Cnt_Remain ~= nil then
		local cur_count = get_aether_gem_reinforce_count_total();
		do_reinforce:SetTextByKey("enable_count", cur_count);
		local max_count = frame:GetUserIValue("gem_reinforce_max_count");
		do_reinforce:SetTextByKey("max_count", max_count);
		-- reinforce_Cnt_Remain set -- 
		local base_cnt = get_aether_gem_reinforce_count();
		local reinforce_cnt_480 = get_aether_gem_reinforce_count_480();
		local reinforce_cnt_460 = get_aether_gem_reinforce_count_460();
		reinforce_Cnt_Remain:SetTextByKey("value1",base_cnt);
		reinforce_Cnt_Remain:SetTextByKey("value2",reinforce_cnt_480);
		reinforce_Cnt_Remain:SetTextByKey("value3",reinforce_cnt_460);
	end
end

-- success ratio
function AETHER_GEM_REINFORCE_SUCCESS_RATIO_FONT_COLOR(ratio)
	local color_sour, color_dest = 0xFF0000, 0xFFBB00;
	if ratio < 20 then
		color_sour = 0x00D8FF; color_dest = 0x0054FF;
	elseif ratio < 30 then
		color_sour = 0x0054FF; color_dest = 0x22741C;
	elseif ratio < 50 then
		color_sour = 0x1DDB16; color_dest = 0x5CD1E5;
	elseif ratio < 70 then
		color_sour = 0x9FC93C; color_dest = 0x998A00;
	elseif ratio < 90 then
		color_sour = 0xFFE08C; color_dest = 0xF15F5F;
	end
	return color_sour, color_dest;
end

function AETHER_GEM_REINFORCE_SUCCESS_RATIO_UPDATE(frame, item, is_equip)
	if frame == nil then return; end
	local pc = GetMyPCObject();
	if pc ~= nil then
		local ratio = nil;
		if is_equip == 1 then
			local gem_slot = GET_CHILD_RECURSIVELY(frame, "gem_slot");
			if gem_slot ~= nil then
				local guid = gem_slot:GetUserValue("select_gem_parent_guid");
				local index = gem_slot:GetUserIValue("select_gem_socket_index");
				local equip_item = session.GetEquipItemByGuid(guid);
				if equip_item ~= nil then
					local equip_item_lv = equip_item:GetEquipGemLv(index);
					ratio = get_ratio_success_aether_gem_equip(pc, equip_item_lv);
				end
			end
		else
			ratio = get_ratio_success_aether_gem(pc, item);
		end

		if ratio ~= nil then
			local select_gem_success_ratio_text = GET_CHILD_RECURSIVELY(frame, "select_gem_success_ratio_text");
			local text = ScpArgMsg("success_ratio", "ratio", ratio);
			local color_sour, color_dest = AETHER_GEM_REINFORCE_SUCCESS_RATIO_FONT_COLOR(ratio);
			select_gem_success_ratio_text:SetTextByKey("value", text);
			select_gem_success_ratio_text:StopColorBlend();
			select_gem_success_ratio_text:SetColorBlend(2, color_sour, color_dest, true);
		end
	end
end

-- reinforce slot drop & remove
function AETHER_GEM_REINFORCE_SELECT_GEM_DROP(frame, slot, arg_str, arg_num)
	if frame == nil then return; end
	local top_frame = frame:GetTopParentFrame();
	if top_frame ~= nil then
		local tab = GET_CHILD_RECURSIVELY(top_frame, "tab");
		if tab ~= nil then
			local index = tab:GetSelectItemIndex();
			if index == 0 then return; end
		end

		local lift_icon = ui.GetLiftIcon();
		local from_frame = lift_icon:GetTopParentFrame();
		if from_frame:GetName() == 'inventory' then
			local icon_info = lift_icon:GetInfo();
			local guid = icon_info:GetIESID();
			if guid ~= nil then
				local inv_item = session.GetInvItemByGuid(guid);
				if inv_item ~= nil then
					AETHER_GEM_REINFORCE_SELECT_GEM_PRE_SETTING(top_frame, slot);
					AETHER_GEM_REINFORCE_CREATE_GEM_INFO(top_frame, inv_item);
				end
			end
		end
	end
end

function AETHER_GEM_REINFORCE_SELECT_GEM_REMOVE(frame, slot)
	if frame == nil or slot == nil then return; end
	local top_frame = frame:GetTopParentFrame();
	if top_frame ~= nil then
		slot:ClearIcon();
		slot:SetUserValue("select_gem_is_equip", 0);
		slot:SetUserValue("select_gem_name", "");
		slot:SetUserValue("select_gem_socket_index", -1);
		slot:SetUserValue("select_gem_parent_guid", "None");
		slot:SetUserValue("select_gem_guid", "None");
		AETHER_GEM_REINFORCE_SET_VISIBLE_BY_SELECT_GEM(top_frame, 0);
		AETHER_GEM_REINFORCE_SET_VISIBLE_BY_CLEARSTAGE(top_frame, 0);
		AETHER_GEM_REINFORCE_SET_VISIBLE_BY_RATIO(top_frame, 0);
		AETHER_GEM_REINFORCE_SET_VISIBLE_BY_REINFORCE_BUTTON(top_frame, 0);
	end
end

-- reinforce
function AETHER_GEM_REINFORCE_EXEC(frame)
	if frame == nil then return; end
	local top_frame = frame:GetTopParentFrame();
	if top_frame == nil then return; end

	local cur_count = get_aether_gem_reinforce_count_total(); 
	if cur_count <= 0 then
		ui.SysMsg(ClMsg("CanNotEnchantMore"));
		return; 
	end

	local reinforce_slot = GET_CHILD_RECURSIVELY(top_frame, "gem_slot");

	if reinforce_slot ~= nil then
		local is_equip = reinforce_slot:GetUserIValue("select_gem_is_equip");
		if is_equip == 0 then
			local guid = reinforce_slot:GetUserValue("select_gem_guid");

			if guid ~= nil and guid ~= "None" then
				local gem_item = session.GetInvItemByGuid(guid);
				if gem_item == nil then return; end
				local gem_object = GetIES(gem_item:GetObject());
				if gem_object == nil then return; end
				_AETHER_GEM_REINFORCE_EXEC(guid);
			end
		else
			local parent_guid = reinforce_slot:GetUserValue("select_gem_parent_guid");
			local socket_index = reinforce_slot:GetUserIValue("select_gem_socket_index");
			if socket_index ~= nil and socket_index ~= -1 and parent_guid ~= nil and parent_guid ~= "None" then
				_AETHER_GEM_REINFORCE_EXEC_BY_EQUIP(tostring(socket_index), parent_guid);
			end
		end
	end
end

function _AETHER_GEM_REINFORCE_EXEC(guid)
	if guid ~= nil and guid ~= "None" then
		item.RequestAetherGemReinforce(guid);
		local frame = ui.GetFrame("aether_gem_reinforce");
		if frame ~= nil then
			AETHER_GEM_REINFORCE_EFFECT(frame);
			AETHER_GEM_REINFORCE_SET_HITTEST_SELECT_GEM(frame, 0);
			AETHER_GEM_REINFORCE_SET_VISIBLE_BY_REINFORCE_BUTTON(frame, 0);
		end
	end
end

function _AETHER_GEM_REINFORCE_EXEC_BY_EQUIP(index, guid)
	if index ~= nil and guid ~= nil and guid ~= "None"then
		index = tonumber(index);
		if index ~= -1 then
			item.RequestAetherGemReinforceByEquip(index, guid);
			local frame = ui.GetFrame("aether_gem_reinforce");
			if frame ~= nil then
				AETHER_GEM_REINFORCE_EFFECT(frame);
				AETHER_GEM_REINFORCE_SET_HITTEST_SELECT_GEM(frame, 0);
				AETHER_GEM_REINFORCE_SET_VISIBLE_BY_REINFORCE_BUTTON(frame, 0);
			end
		end
	end
end

function AETHER_GEM_REINFORCE_EFFECT(frame)
	if frame ~= nil then
		local effect_name = frame:GetUserConfig("DO_SUCCESS_EFFECT");
		local effect_scale = tonumber(frame:GetUserConfig("SUCCESS_EFFECT_SCALE"));
		local effect_duration = tonumber(frame:GetUserConfig("SUCCESS_EFFECT_DURATION"));
		local gem_slot_bg = GET_CHILD_RECURSIVELY(frame, "gem_slot_bg");
		if gem_slot_bg ~= nil then
			gem_slot_bg:PlayUIEffect(effect_name, effect_scale, "DoReinforceEffect");
			ReserveScript("_AETHER_GEM_REINFORCE_EFFECT()", effect_duration);
		end
	end
end

function _AETHER_GEM_REINFORCE_EFFECT()
	local frame = ui.GetFrame("aether_gem_reinforce");
	if frame == nil then return; end
	if frame:IsVisible() == 0 then return; end
	local gem_slot_bg = GET_CHILD_RECURSIVELY(frame, "gem_slot_bg");
	if gem_slot_bg ~= nil then
		gem_slot_bg:StopUIEffect("DoReinforceEffect", true, 0.5);
		ui.SetHoldUI(false);
	end
end

-- reinfroce result
function ON_AETHER_GEM_REINFORCE_RESULT(frame, msg, arg_str, arg_num)
	if frame == nil then return; end
	if arg_str == "SUCCESS" then
		ReserveScript("AETHER_GEM_REINFORCE_SUCCESS()", 1.0);
	elseif arg_str == "FAILED" then
		ReserveScript("AETHER_GEM_REINFORCE_FAILED()", 1.0);
	end
end

function AETHER_GEM_REINFORCE_RESET_UI()
	local frame = ui.GetFrame("aether_gem_reinforce");
	if frame == nil then return; end
	AETHER_GEM_REINFORCE_SET_HITTEST_SELECT_GEM(frame, 1);
	AETHER_GEM_REINFORCE_SET_VISIBLE_BY_REINFORCE_BUTTON(frame, 1);
end

function ON_AETHER_GEM_REINFORCE_TX_FAIL_THEN_RESET_UI(frame,msg,arg_str,arg_num)
	if frame == nil then return; end
	if arg_str == "MAXLEVEL" or arg_str == "INVALID" then
		ReserveScript("AETHER_GEM_REINFORCE_RESET_UI()", 1.0);
	end
end

function AETHER_GEM_REINFORCE_SUCCESS()
	local frame = ui.GetFrame("aether_gem_reinforce");
	if frame == nil then return; end
	if frame:IsVisible() == 0 then return; end
	-- unvisible
	AEHTER_GEM_REINFORCE_SET_VISIBLE_BY_TOP_GROUPBOX(frame, 0);
	AETHER_GEM_REINFORCE_SET_VISIBLE_BY_CLEARSTAGE(frame, 0);
	AETHER_GEM_REINFORCE_SET_VISIBLE_BY_REINFORCE_BUTTON(frame, 0);
	AETHER_GEM_REINFORCE_SET_VISIBLE_BY_SELECT_GEM(frame, 0);
	local select_gem_text = GET_CHILD_RECURSIVELY(frame, "select_gem_text");
	select_gem_text:ShowWindow(0);

	-- visible
	AETHER_GEM_REINFORCE_SET_VISIBLE_BY_SUMMIT_BUTTON(frame, 1);
	AETHER_GEM_REINFORCE_SET_VISIBLE_BY_RESULT_BOX(frame, 1);

	-- result control
	AETHER_GEM_REINFORCE_SET_VISIBLE_BY_SUCCESS_RESULT(frame, 1);
	AETHER_GEM_REINFORCE_SET_VISIBLE_BY_FAILED_RESULT(frame, 0);

	-- result img
	local result_item_img = GET_CHILD_RECURSIVELY(frame, "result_item_img");
	result_item_img:ShowWindow(1);
	local gem_slot = GET_CHILD_RECURSIVELY(frame, "gem_slot");
	if gem_slot ~= nil then
		local is_equip = gem_slot:GetUserIValue("select_gem_is_equip");
		if is_equip == 0 then
			local guid = gem_slot:GetUserValue("select_gem_guid");
			local item = session.GetInvItemByGuid(guid);
			if item ~= nil then
				local object = GetIES(item:GetObject());
				if object ~= nil then
					result_item_img:SetImage(TryGetProp(object, "Icon", "None"));	
				end
			end
		else
			local guid = gem_slot:GetUserValue("select_gem_parent_guid");
			local euqip_item = session.GetEquipItemByGuid(guid);
			if euqip_item ~= nil then
				local index = gem_slot:GetUserIValue("select_gem_socket_index");
				local gem_id = euqip_item:GetEquipGemID(index);
				if gem_id ~= nil then
					local gem_class = GetClassByType("Item", gem_id);
					if gem_class ~= nil then
						result_item_img:SetImage(TryGetProp(gem_class, "Icon", "None"));
					end
				end
			end
		end
	end

	-- reinforce count
	AETHER_GEM_REINFORCE_DO_REINFORCE_BTN_UPDATE(frame);
end

function AETHER_GEM_REINFORCE_SUCCESS_EFFECT(frame)
	if frame ~= nil then
		local effect_name = frame:GetUserConfig("DO_SUCCESS_EFFECT");
		local effect_scale = tonumber(frame:GetUserConfig("SUCCESS_EFFECT_SCALE"));
		local effect_duration = tonumber(frame:GetUserConfig("SUCCESS_EFFECT_DURATION"));
		local effect_bg = GET_CHILD_RECURSIVELY(frame, "success_effect_bg");
		if effect_bg ~= nil then
			effect_bg:PlayUIEffect(effect_name, effect_scale, "DoSuccessEffect");
			ReserveScript("_AETHER_GEM_REINFORCE_SUCCESS_EFFECT()", effect_duration);
		end
	end
end

function _AETHER_GEM_REINFORCE_SUCCESS_EFFECT()
	local frame = ui.GetFrame("aether_gem_reinforce");
	if frame == nil then return; end
	if frame:IsVisible() == 0 then return; end
	local effect_bg = GET_CHILD_RECURSIVELY(frame, "success_effect_bg");
	if effect_bg ~= nil then
		effect_bg:StopUIEffect("DoSuccessEffect", true, 0.5);
		ui.SetHoldUI(false);
	end
end

function AETHER_GEM_REINFORCE_FAILED()
	local frame = ui.GetFrame("aether_gem_reinforce");
	if frame == nil then return; end
	if frame:IsVisible() == 0 then return; end
	-- unvisible
	AEHTER_GEM_REINFORCE_SET_VISIBLE_BY_TOP_GROUPBOX(frame, 0);
	AETHER_GEM_REINFORCE_SET_VISIBLE_BY_CLEARSTAGE(frame, 0);
	AETHER_GEM_REINFORCE_SET_VISIBLE_BY_REINFORCE_BUTTON(frame, 0);
	AETHER_GEM_REINFORCE_SET_VISIBLE_BY_SELECT_GEM(frame, 0);
	local select_gem_text = GET_CHILD_RECURSIVELY(frame, "select_gem_text");
	select_gem_text:ShowWindow(0);

	-- visible
	AETHER_GEM_REINFORCE_SET_VISIBLE_BY_SUMMIT_BUTTON(frame, 1);
	AETHER_GEM_REINFORCE_SET_VISIBLE_BY_RESULT_BOX(frame, 1);

	-- result control
	AETHER_GEM_REINFORCE_SET_VISIBLE_BY_SUCCESS_RESULT(frame, 0);
	AETHER_GEM_REINFORCE_SET_VISIBLE_BY_FAILED_RESULT(frame, 1);

	-- result img
	local result_item_img = GET_CHILD_RECURSIVELY(frame, "result_item_img");
	result_item_img:ShowWindow(1);
	local gem_slot = GET_CHILD_RECURSIVELY(frame, "gem_slot");
	if gem_slot ~= nil then
		local is_equip = gem_slot:GetUserIValue("select_gem_is_equip");
		if is_equip == 0 then
			local guid = gem_slot:GetUserValue("select_gem_guid");
			local item = session.GetInvItemByGuid(guid);
			if item ~= nil then
				local object = GetIES(item:GetObject());
				if object ~= nil then
					result_item_img:SetImage(TryGetProp(object, "Icon", "None"));	
				end
			end
		else
			local guid = gem_slot:GetUserValue("select_gem_parent_guid");
			local euqip_item = session.GetEquipItemByGuid(guid);
			if euqip_item ~= nil then
				local index = gem_slot:GetUserIValue("select_gem_socket_index");
				local gem_id = euqip_item:GetEquipGemID(index);
				if gem_id ~= nil then
					local gem_class = GetClassByType("Item", gem_id);
					if gem_class ~= nil then
						result_item_img:SetImage(TryGetProp(gem_class, "Icon", "None"));
					end
				end
			end
		end
	end

	-- reinforce count
	AETHER_GEM_REINFORCE_DO_REINFORCE_BTN_UPDATE(frame);
end

function AETHER_GEM_REINFORCE_FAILED_EFFECT(frame)
	if frame ~= nil then
		local effect_name = frame:GetUserConfig("DO_FAIL_EFFECT");
		local effect_scale = tonumber(frame:GetUserConfig("FAIL_EFFECT_SCALE"));
		local effect_duration = tonumber(frame:GetUserConfig("FAIL_EFFECT_DURATION"));
		local effect_bg = GET_CHILD_RECURSIVELY(frame, "fail_effect_bg");
		if effect_bg ~= nil then
			effect_bg:PlayUIEffect(effect_name, effect_scale, "DoFaildEffect");
			ReserveScript("_AETHER_GEM_REINFORCE_FAILED_EFFECT()", effect_duration);
		end
	end
end

function _AETHER_GEM_REINFORCE_FAILED_EFFECT()
	local frame = ui.GetFrame("aether_gem_reinforce");
	if frame == nil then return; end
	if frame:IsVisible() == 0 then return; end
	local effect_bg = GET_CHILD_RECURSIVELY(frame, "fail_effect_bg");
	if effect_bg ~= nil then
		effect_bg:StopUIEffect("DoFaildEffect", true, 0.5);
		ui.SetHoldUI(false);
	end
end

-- summit
function AETHER_GEM_REINFORCE_COMMIT()
	local frame = ui.GetFrame("aether_gem_reinforce");
	if frame == nil then return; end
	AETHER_GEM_REINFORCE_CLEAR();
	AETHER_GEM_REINFORCE_SET_HITTEST_SELECT_GEM(frame, 1);
	AETHER_GEM_REINFORCE_SET_VISIBLE_BY_REINFORCE_BUTTON(frame, 1);
	AETHER_GEM_REINFORCE_RESULT_SUCCESS_RATIO_UPDATE(frame);
	local tab = GET_CHILD_RECURSIVELY(frame, "tab");
	if tab ~= nil then
		local tab_index = tab:GetSelectItemIndex();
		AETHER_GEM_REINFORCE_RESULT_GEM_LIST_UPDATE(frame, tab_index);
	end
	frame:Invalidate();
end

-- gem list update by commit
function AETHER_GEM_REINFORCE_RESULT_GEM_LIST_UPDATE(frame, index)
	if frame == nil then return; end
	if index == 0 then
		local gem_slot_list = GET_CHILD_RECURSIVELY(frame, "gem_slot_list", "ui::CSlotSet");
		AETHER_GEM_REINFORCE_RESULT_GEM_LIST_BY_EQUIPMENT_UPDATE(gem_slot_list);	
	else
		local gem_slot_list_inven = GET_CHILD_RECURSIVELY(frame, "gem_slot_list_inven", "ui::CSlotSet");
		AETHER_GEM_REINFORCE_RESULT_GEM_LIST_BY_INVEN_UPDATE(gem_slot_list_inven);
	end
end

-- gem equip list update by commit
function AETHER_GEM_REINFORCE_RESULT_GEM_LIST_BY_EQUIPMENT_UPDATE(gem_slot_list)
	if gem_slot_list ~= nil then
		local frame = gem_slot_list:GetTopParentFrame();
		local count = gem_slot_list:GetChildCount();
		for i = 1, count - 1 do
			local slot = gem_slot_list:GetSlotByIndex(i - 1);
			if slot ~= nil and slot:IsSelected() == 1 then
				local class_id = slot:GetUserIValue("gem_class_id");
				local gem_class = GetClassByType("Item", class_id);
				if gem_class ~= nil then
					local parent_guid = slot:GetUserValue("gem_parent_guid");
					local index = slot:GetUserIValue("gem_socket_index");
					local euqip_item = session.GetEquipItemByGuid(parent_guid);
					if euqip_item ~= nil then
						equip_item_lv = euqip_item:GetEquipGemLv(index);
						slot:SetUserValue("gem_level", equip_item_lv);
						slot:SetText("{s14}{ol}{#FFFFFF}{b}Lv."..equip_item_lv, "count", ui.LEFT, ui.TOP, 3, 2);
					end

					SET_SLOT_ITEM_CLS(slot, gem_class);
					local icon = slot:GetIcon();
					if icon ~= nil then
						icon:SetTooltipArg(parent_guid, class_id, 0);
					end

					local is_gem_equip = slot:GetUserIValue("is_gem_equip");
					AETHER_GEM_REINFORCE_SELECT_GEM_PRE_SETTING(frame, slot);
					AETHER_GEM_REINFORCE_SELECT_GEM_UPDATE(frame, slot, is_gem_equip);
				end
			end
		end
	end
end

-- gem inven list update by commit
function AETHER_GEM_REINFORCE_RESULT_GEM_LIST_BY_INVEN_UPDATE(gem_slot_list)
	if gem_slot_list ~= nil then
		local frame = gem_slot_list:GetTopParentFrame();
		local count = gem_slot_list:GetChildCount();
		for i = 1, count - 1 do
			local slot = gem_slot_list:GetSlotByIndex(i - 1);
			if slot ~= nil and slot:IsSelected() == 1 then
				local guid = slot:GetUserValue("gem_guid");
				local inv_item = session.GetInvItemByGuid(guid);
				if inv_item ~= nil then
					local object = GetIES(inv_item:GetObject());
					if object ~= nil then
						SET_SLOT_ITEM(slot, inv_item);
						SET_SLOT_ITEM_TEXT_USE_INVCOUNT(slot, inv_item, object, inv_item.count);
					end
					local is_gem_equip = slot:GetUserIValue("is_gem_equip");
					AETHER_GEM_REINFORCE_SELECT_GEM_PRE_SETTING(frame, slot);
					AETHER_GEM_REINFORCE_SELECT_GEM_UPDATE(frame, slot, is_gem_equip);
				end
			end
		end
	end
end

-- ratio update by commit
function AETHER_GEM_REINFORCE_RESULT_SUCCESS_RATIO_UPDATE(frame)
	if frame == nil then return; end
	local gem_slot = GET_CHILD_RECURSIVELY(frame, "gem_slot");
	if gem_slot ~= nil then
		local is_equip = gem_slot:GetUserIValue("select_gem_is_equip");
		if is_equip == 0 then
			local guid = gem_slot:GetUserValue("select_gem_guid");
			if guid ~= nil and guid ~= "None" then
				local gem = session.GetInvItemByGuid(guid);
				if gem ~= nil then
					local gem_class = GetIES(gem:GetObject());
					AETHER_GEM_REINFORCE_SUCCESS_RATIO_UPDATE(frame, gem_class, is_equip);
				end
			end
		else
			local guid = gem_slot:GetUserValue("select_gem_parent_guid");
			if guid ~= nil and guid ~= "None" then
				local euqip_item = session.GetEquipItemByGuid(guid);
				local index = gem_slot:GetUserIValue("select_gem_socket_index");
				local gem_id = euqip_item:GetEquipGemID(index);
				if gem_id ~= nil then
					local gem_class = GetClassByType("Item", gem_id);
					AETHER_GEM_REINFORCE_SUCCESS_RATIO_UPDATE(frame, gem_class, is_equip);
				end
			end
		end
	end
end

function AETHER_GEM_REINFORCE_CLEAR()
	local frame = ui.GetFrame("aether_gem_reinforce");
	if frame ~= nil then
		AETHER_GEM_REINFORCE_SET_VISIBLE_BY_RESULT_BOX(frame, 0);
		AETHER_GEM_REINFORCE_SET_VISIBLE_BY_SUMMIT_BUTTON(frame, 0);
		AETHER_GEM_REINFORCE_SET_VISIBLE_BY_SUCCESS_RESULT(frame, 0);
		AETHER_GEM_REINFORCE_SET_VISIBLE_BY_FAILED_RESULT(frame, 0);
		frame:Invalidate();
	end
end

function AETHER_GEM_REINFORCE_SET_HITTEST_SELECT_GEM(frame, enable)
	if frame ~= nil then 
		local gem_slot_list = GET_CHILD_RECURSIVELY(frame, "gem_slot_list");
		if gem_slot_list ~= nil then
			gem_slot_list:EnableHitTest(enable);
			gem_slot_list = tolua.cast(gem_slot_list, "ui::CSlotSet");
			gem_slot_list:EnableSelection(enable);
		end

		local gem_slot_list_inven = GET_CHILD_RECURSIVELY(frame, "gem_slot_list_inven");
		if gem_slot_list_inven ~= nil then
			gem_slot_list_inven:EnableHitTest(enable);
			gem_slot_list_inven = tolua.cast(gem_slot_list_inven, "ui::CSlotSet");
			gem_slot_list_inven:EnableSelection(enable);
		end
	end
end

-- reinforce count
function ON_SET_AETHER_GEM_REINFORCE_MAX_COUNT(frame, msg, arg_str, arg_num)
	if frame == nil then return; end
	frame:SetUserValue("gem_reinforce_max_count", arg_num);

	AETHER_GEM_REINFORCE_DO_REINFORCE_BTN_UPDATE(frame);
end