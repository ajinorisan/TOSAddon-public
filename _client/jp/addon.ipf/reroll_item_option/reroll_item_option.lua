function REROLL_ITEM_OPTION_ON_INIT(addon, frame)
end

local function _MAKE_PROPERTY_MIN_MAX_DESC(desc, min, max)
	return string.format(" %s "..ScpArgMsg("PropUp").."%d"..' ~ '..ScpArgMsg("PropUp").."%d", desc, math.abs(min), math.abs(max))
end

function OPEN_REROLL_ITEM_OPTION(parent, ctrl)
	local frame = ui.GetFrame('reroll_item_option')
	local reroll_frame = parent:GetTopParentFrame()
	local cur_index = reroll_frame:GetUserValue('CURRENT_INDEX')
	local property_name = GET_CHILD_RECURSIVELY(parent, 'property_name')
	local ctrl_index = property_name:GetEventScriptArgNumber(ui.LBUTTONUP)
	if cur_index == nil or cur_index == 'None' or tonumber(cur_index) ~= ctrl_index then
		-- 토글 버튼 클릭 시 무조건 해당 옵션이 선택되도록 함
		REROLL_ITEM_SELECT_OPTION(reroll_frame, parent, ctrl_index)
		if frame:IsVisible() == 0 then
			ui.OpenFrame('reroll_item_option')
		else
			REROLL_ITEM_OPTION_LIST(frame)
		end
	else
		-- 이미 선택된 옵션의 토글버튼 클릭 시에는 토글
		ui.ToggleFrame('reroll_item_option')
	end
end

function REROLL_ITEM_OPTION_OPEN(frame)
	REROLL_ITEM_OPTION_LIST(frame)
end

function REROLL_ITEM_OPTION_CLOSE(frame)
end

function REROLL_ITEM_OPTION_LIST(frame)
	local reroll_frame = ui.GetFrame('reroll_item')
	if reroll_frame == nil or reroll_frame:IsVisible() ~= 1 then
		ui.CloseFrame('reroll_item_option')
		return
	end

	local slot = GET_CHILD_RECURSIVELY(reroll_frame, 'slot')
	local inv_item = GET_SLOT_ITEM(slot)
	if inv_item == nil then
		ui.CloseFrame('reroll_item_option')
		return
	end

	local item_obj = GetIES(inv_item:GetObject())
	local cur_index = reroll_frame:GetUserValue('CURRENT_INDEX')
	if cur_index == nil or cur_index == 'None' then return end

	local reroll_index = TryGetProp(item_obj, 'RerollIndex', 0)
	if reroll_index <= 0 then
		reroll_index = tonumber(cur_index)
	end

	local candidate_option_list = nil

	local group_name = TryGetProp(item_obj, 'GroupName', 'None')	
	if group_name == 'BELT' then
		candidate_option_list = shared_item_belt.get_option_list_by_index(item_obj, reroll_index)
	elseif group_name == 'SHOULDER' then
		candidate_option_list = shared_item_shoulder.get_option_list_by_index(item_obj, reroll_index)
	elseif group_name == 'Icor' then
		candidate_option_list = shared_item_goddess_icor.get_random_option_list(item_obj, false)
	end

	if candidate_option_list == nil or #candidate_option_list == 0 then
		return
	end

	local max_random_option_count = 0

	if group_name == 'BELT' then
		max_random_option_count = shared_item_belt.get_max_random_option_count(item_obj)
	elseif group_name == 'SHOULDER' then
		max_random_option_count = shared_item_shoulder.get_max_random_option_count(item_obj)
	elseif group_name == 'Icor' then
		max_random_option_count = shared_item_goddess_icor.get_max_option_count()
	end
	if max_random_option_count == nil then
		return
	end

	local optionGbox = GET_CHILD_RECURSIVELY(frame, 'optionGbox')
	optionGbox:RemoveAllChild()
	local op_count = 0
	for i = 1, #candidate_option_list do
		local prop_name = candidate_option_list[i]
		if group_name == 'BELT' then
			if shared_item_belt.is_valid_reroll_option(item_obj, reroll_index, prop_name, max_random_option_count) == true then
				op_count = op_count + 1
				local group_name = shared_item_belt.get_option_group_name(prop_name)
				local clmsg = GET_CLMSG_BY_OPTION_GROUP(group_name)
				local min, max = shared_item_belt.get_option_value_range_equip(item_obj, prop_name)
				local op_name = string.format('%s %s', ClMsg(clmsg), ScpArgMsg(prop_name))
				local info_str = _MAKE_PROPERTY_MIN_MAX_DESC(op_name, min, max)
				local option_ctrlset = optionGbox:CreateOrGetControlSet('eachproperty_in_reroll_item', 'PROPERTY_CSET_' .. op_count, 0, 0)
				option_ctrlset = AUTO_CAST(option_ctrlset)
				local pos_y = option_ctrlset:GetUserConfig('POS_Y')
				option_ctrlset:Move(0, (op_count - 1) * pos_y)
				-- local bg = GET_CHILD_RECURSIVELY(option_ctrlset, 'bg')
				-- bg:ShowWindow(0)
				local property_name = GET_CHILD_RECURSIVELY(option_ctrlset, 'property_name', 'ui::CRichText')
				property_name:SetEventScript(ui.LBUTTONUP, 'None')
				property_name:SetText(info_str)
				local help_pic = GET_CHILD_RECURSIVELY(option_ctrlset, 'help_pic')
				help_pic:ShowWindow(0)
			end
		elseif group_name == 'SHOULDER' then
			if shared_item_shoulder.is_valid_reroll_option(item_obj, reroll_index, prop_name, max_random_option_count) == true then
				op_count = op_count + 1
				local group_name = shared_item_shoulder.get_option_group_name(prop_name)
				local clmsg = GET_CLMSG_BY_OPTION_GROUP(group_name)				
				local min, max = shared_item_shoulder.get_option_value_range_equip(item_obj, prop_name)
				local op_name = string.format('%s %s', ClMsg(clmsg), ScpArgMsg(prop_name))
				local info_str = _MAKE_PROPERTY_MIN_MAX_DESC(op_name, min, max)
				local option_ctrlset = optionGbox:CreateOrGetControlSet('eachproperty_in_reroll_item', 'PROPERTY_CSET_' .. op_count, 0, 0)
				option_ctrlset = AUTO_CAST(option_ctrlset)
				local pos_y = option_ctrlset:GetUserConfig('POS_Y')
				option_ctrlset:Move(0, (op_count - 1) * pos_y)
				-- local bg = GET_CHILD_RECURSIVELY(option_ctrlset, 'bg')
				-- bg:ShowWindow(0)
				local property_name = GET_CHILD_RECURSIVELY(option_ctrlset, 'property_name', 'ui::CRichText')
				property_name:SetEventScript(ui.LBUTTONUP, 'None')
				property_name:SetText(info_str)
				local help_pic = GET_CHILD_RECURSIVELY(option_ctrlset, 'help_pic')
				help_pic:ShowWindow(0)
			end
		elseif group_name == 'Icor' then		
			if shared_item_goddess_icor.is_valid_reroll_option(item_obj, reroll_index, prop_name) == true then
				op_count = op_count + 1
				local group_name = shared_item_goddess_icor.get_option_group_name(prop_name)			
				local clmsg = GET_CLMSG_BY_OPTION_GROUP(group_name)
				local min, max = shared_item_goddess_icor.get_option_value_range_icor(item_obj, prop_name)
				local op_name = string.format('%s %s', ClMsg(clmsg), ScpArgMsg(prop_name))
				local info_str = _MAKE_PROPERTY_MIN_MAX_DESC(op_name, min, max)
				local option_ctrlset = optionGbox:CreateOrGetControlSet('eachproperty_in_reroll_item', 'PROPERTY_CSET_' .. op_count, 0, 0)
				option_ctrlset = AUTO_CAST(option_ctrlset)
				local pos_y = option_ctrlset:GetUserConfig('POS_Y')
				option_ctrlset:Move(0, (op_count - 1) * pos_y)			
				local property_name = GET_CHILD_RECURSIVELY(option_ctrlset, 'property_name', 'ui::CRichText')
				property_name:SetEventScript(ui.LBUTTONUP, 'None')
				property_name:SetText(info_str)
				local help_pic = GET_CHILD_RECURSIVELY(option_ctrlset, 'help_pic')
				help_pic:ShowWindow(0)
			end
		end
	end
end