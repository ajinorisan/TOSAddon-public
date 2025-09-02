local s_liberation_material_ctrl_name_list = {
	{ "liberation_material_text_bg", "liberation_material_list_bg" },
	{ "liberation_material_detail_bg", "liberation_material_detail_left_bg", "liberation_material_detail_left_item_info_bg", "liberation_material_detail_right_bg", "liberation_material_detail_right_text_bg", "liberation_material_detail_right_list_bg" }
}
local s_liberation_ctrl_name_list = { "liberation_bg", "liberation_list_bg", "liberation_list_text_bg", "liberation_list_detail_bg", "liberation_value_bg", "liberation_gauge_bg" }
local s_decompoisiton_ctrl_name_list = { "decomposition_bg", "decomposition_exec_bg", "decomposition_exec_text_gb", "decomposition_exec_notice_gb", "decomposition_ret_bg", "decomposition_ret_list_bg", "decomposition_ret_list_title_bg", "decomposition_ret_list_detail_bg" }

function TEMPEST_CORE_MANAGER_ON_INIT(addon, frame)
	addon:RegisterMsg("OPEN_DLG_TEMPEST_CORE_MANAGER", "ON_OPEN_DLG_TEMPEST_CORE_MANAGER")
	addon:RegisterMsg("TEMPEST_CORE_LIBERATION_SUCCESS", "ON_TEMPEST_CORE_LIBERATION_SUCCESS")
	addon:RegisterMsg("TEMPEST_CORE_DECOMPOSE_SUCCESS", "ON_TEMPEST_CORE_DECOMPOSE_SUCCESS")	
	addon:RegisterMsg("MAKE_UNSEALING_ITEM_SUCCESS", "ON_MAKE_TEMPEST_CORE_UNSEALING_ITEM_SUCCESS")
end

local function get_remain_option_point(slot)
	local item_guid = slot:GetUserValue("ItemGuid")
	if item_guid == 'None' then
		return 0
	end

	local inv_item = session.GetInvItemByGuid(item_guid)
	if inv_item == nil then
		return 0
	end

	local item_obj = GetIES(inv_item:GetObject())
	local item_name = TryGetProp(item_obj, "ClassName", "None")
	local max_point = GetClass('tempest_core_item_list', item_name).RequirePoint 
	local max = max_point * item_tempest_core.get_remain_option_count(item_obj)

	return max
end

local function reset_current_material_point(frame)
	local list = item_tempest_core.get_unsealing_material_list()
	if list ~= nil and #list > 0 then
		for i = 1, #list do
			local id = list[i][1]
			frame:SetUserValue("Smelting"..id, 0)			
		end
	end
end

local function reset_current_liberation_point(frame)
	local list = item_tempest_core.get_unsealing_item_list()
	if list ~= nil and #list > 0 then
		for i = 1, #list do
			local id = list[i][1]			
			frame:SetUserValue("Liberation"..id, 0)
		end
	end
end

-- ** addon msg ** --
function ON_OPEN_DLG_TEMPEST_CORE_MANAGER(frame, msg, arg_str, arg_num)
	ui.OpenFrame("tempest_core_manager")
end

function ON_TEMPEST_CORE_LIBERATION_SUCCESS(frame, msg, arg_str, arg_num)
	local inv_item = session.GetInvItemByGuid(arg_str)
	if inv_item ~= nil then
		local item_obj = GetIES(inv_item:GetObject())
		if item_obj ~= nil then
			local item_class_name = TryGetProp(item_obj, "ClassName", "None")
			TEMPEST_CORE_MANAGER_LIBERATION_VIEW_RESET(frame, item_class_name)
		end
	end
	reset_current_liberation_point(frame)
end

function ON_TEMPEST_CORE_DECOMPOSE_SUCCESS(frame, msg, arg_str, arg_num)
	TEMPEST_CORE_MANAGER_DECOMPOSITION_VIEW_RESET(frame)
end

function TEMPEST_CORE_MANAGER_OPEN(frame)
	frame:SetUserValue("on_liberation_material_detail", 0)
	local main_tab = GET_CHILD_RECURSIVELY(frame, "main_tab")
	main_tab:SelectTab(0)
	TEMPEST_CORE_MANAGER_ALL_CLEAR(frame)
	TEMPEST_CORE_MANAGER_TAB_LIBERATION_MATERIAL(frame)
	INVENTORY_SET_CUSTOM_RBTNDOWN("TEMPEST_CORE_INV_RBTN")
end

function DO_TEMPEST_CORE_MANAGER_OPEN(parent, btn)
	ui.OpenFrame("tempest_core_manager")
end

function TEMPEST_CORE_MANAGER_CLOSE(frame)
	ui.CloseFrame("tempest_core_manager")
	INVENTORY_SET_CUSTOM_RBTNDOWN("None")
end

-- ** clear ** --
---- clear - all
function TEMPEST_CORE_MANAGER_ALL_CLEAR(frame)
	TEMPEST_CORE_MANAGER_LIBERATION_MATERIAL_CLEAR(frame)
	TEMPEST_CORE_MANAGER_LIBERATION_CLEAR(frame)
	TEMPEST_CORE_MANAGER_DECOMPOSITION(frame)
end

---- clear - liberation_material
function TEMPEST_CORE_MANAGER_LIBERATION_MATERIAL_CLEAR(frame)
	local ctrl_name_list = {
		"liberation_material_bg",
		"liberation_material_text_bg",
		"liberation_material_list_bg",
		"liberation_material_detail_left_bg",
		"liberation_material_detail_left_item_info_bg",
		"liberation_material_detail_left_item_point_bg",
		"liberation_material_detail_left_item_point_bg",
		"liberation_material_detail_right_bg",
		"liberation_material_detail_right_list_bg"
	}
	for i = 1, #ctrl_name_list do
		local ctrl_name = ctrl_name_list[i]
		local ctrl = GET_CHILD_RECURSIVELY(frame, ctrl_name)
		if ctrl ~= nil then
			ctrl:ShowWindow(0)
		end
	end
end

---- clear - liberation_material : list
function TEMPEST_CORE_MANAGER_LIBERATION_MATERIAL_LIST_CLEAR(frame)
	local ctrl_name_list = s_liberation_material_ctrl_name_list[1]
	for i = 1, #ctrl_name_list do
		local ctrl_name = ctrl_name_list[i]
		local ctrl = GET_CHILD_RECURSIVELY(frame, ctrl_name)
		if ctrl ~= nil then
			ctrl:ShowWindow(0)
		end
	end
end

---- clear - liberation_material : detail
function TEMPEST_CORE_MANAGER_LIBERATION_MATERIAL_DETAIL_CLEAR(frame)
	local ctrl_name_list = s_liberation_material_ctrl_name_list[2]
	for i = 1, #ctrl_name_list do
		local ctrl_name = ctrl_name_list[i]
		local ctrl = GET_CHILD_RECURSIVELY(frame, ctrl_name)
		if ctrl ~= nil then
			ctrl:ShowWindow(0)
		end
	end
end

---- clear - liberation
function TEMPEST_CORE_MANAGER_LIBERATION_CLEAR(frame)
	for i = 1, #s_liberation_ctrl_name_list do
		local ctrl_name = s_liberation_ctrl_name_list[i]
		local ctrl = GET_CHILD_RECURSIVELY(frame, ctrl_name)
		if ctrl ~= nil then
			ctrl:ShowWindow(0)
		end
	end
end

---- clear - decomposition 
function TEMPEST_CORE_MANAGER_DECOMPOSITION(frame)
	for i = 1, #s_decompoisiton_ctrl_name_list do
		local ctrl_name = s_decompoisiton_ctrl_name_list[i]
		local ctrl = GET_CHILD_RECURSIVELY(frame, ctrl_name)
		if ctrl ~= nil then
			ctrl:ShowWindow(0)
		end
	end
end

-- ** show ** --
---- show - liberation_material : main
function TEMPEST_CORE_MANAGER_LIBERATION_MATERIAL_MAIN_SHOW(frame)
	local liberation_material_bg = GET_CHILD_RECURSIVELY(frame, "liberation_material_bg")
	liberation_material_bg:ShowWindow(1)
end

---- show - liberation_material : list
function TEMPEST_CORE_MANAGER_LIBERATION_MATERIAL_LIST_SHOW(frame)
	TEMPEST_CORE_MANAGER_LIBERATION_MATERIAL_MAIN_SHOW(frame)
	local ctrl_name_list = s_liberation_material_ctrl_name_list[1]
	for i = 1, #ctrl_name_list do
		local ctrl_name = ctrl_name_list[i]
		local ctrl = GET_CHILD_RECURSIVELY(frame, ctrl_name)
		if ctrl ~= nil then
			ctrl:ShowWindow(1)
		end
	end
end

---- show - liberation_material : detail
function TEMPEST_CORE_MANAGER_LIBERATION_MATERIAL_DETAIL_SHOW(frame)
	TEMPEST_CORE_MANAGER_LIBERATION_MATERIAL_MAIN_SHOW(frame)
	local ctrl_name_list = s_liberation_material_ctrl_name_list[2]
	for i = 1, #ctrl_name_list do
		local ctrl_name = ctrl_name_list[i]
		local ctrl = GET_CHILD_RECURSIVELY(frame, ctrl_name)
		if ctrl ~= nil then
			ctrl:ShowWindow(1)
		end
	end
end

---- show - liberation
function TEMPEST_CORE_MANAGER_LIBERATION_SHOW(frame)
	for i = 1, #s_liberation_ctrl_name_list do
		local ctrl_name = s_liberation_ctrl_name_list[i]
		local ctrl = GET_CHILD_RECURSIVELY(frame, ctrl_name)
		if ctrl ~= nil then
			ctrl:ShowWindow(1)
		end
	end
end

---- show - decompoition
function TEMPEST_CORE_MANAGER_DECOMPOSITION_SHOW(frame)
	for i = 1, #s_decompoisiton_ctrl_name_list do
		local ctrl_name = s_decompoisiton_ctrl_name_list[i]
		local ctrl = GET_CHILD_RECURSIVELY(frame, ctrl_name)
		if ctrl ~= nil then
			ctrl:ShowWindow(1)
		end
	end
end

-- ** tab ** --
function TEMPEST_CORE_MANAGER_TAB_CHANGE(parent, tab)		
	local frame = parent:GetTopParentFrame()
	TEMPEST_CORE_MANAGER_ALL_CLEAR(frame)

	local index = tab:GetSelectItemIndex()
	if index == 0 then
		TEMPEST_CORE_MANAGER_TAB_LIBERATION_MATERIAL(frame)
	elseif index == 1 then
		TEMPEST_CORE_MANAGER_TAB_LIBERATION(frame)
	elseif index == 2 then
		TEMPEST_CORE_MANAGER_TAB_DECOMPOSITION(frame)
	end
end

---- tab - liberation material
function TEMPEST_CORE_MANAGER_TAB_LIBERATION_MATERIAL(frame)
	local on_detail = frame:GetUserIValue("on_liberation_material_detail")
	if on_detail == 0 then
		TEMPEST_CORE_MANAGER_TAB_LIBERATION_MATERIAL_LIST(frame)
	elseif on_detail == 1 then
		TEMPEST_CORE_MANAGER_TAB_LIBERATION_MATERIAL_DETAIL(frame)
	end
end

---- tab - liberation material : list
function TEMPEST_CORE_MANAGER_TAB_LIBERATION_MATERIAL_LIST(frame)
	TEMPEST_CORE_MANAGER_LIBERATION_MATERIAL_LIST_SHOW(frame) -- list show
	TEMPEST_CORE_MANAGER_LIBERATION_MATERIAL_DETAIL_CLEAR(frame) -- detail clear
	REMOVE_TEMPEST_CORE_MANAGER_LIBERATION_MATERIAL_LIST(frame) -- remove liberation material list
	CREATE_TEMPEST_CORE_MANAGER_LIBERATION_MATERIAL_LIST(frame) -- create liberation material list
end

---- tab - liberation material : detail
function TEMPEST_CORE_MANAGER_TAB_LIBERATION_MATERIAL_DETAIL(frame)
	TEMPEST_CORE_MANAGER_LIBERATION_MATERIAL_DETAIL_SHOW(frame) -- detail show
	TEMPEST_CORE_MANAGER_LIBERATION_MATERIAL_LIST_CLEAR(frame) -- list clear
end

---- tab - liberation
function TEMPEST_CORE_MANAGER_TAB_LIBERATION(frame)
	TEMPEST_CORE_MANAGER_LIBERATION_SHOW(frame)	
	CREATE_TEMPEST_CORE_MANAGER_LIBERATION_LIST(frame) -- create
	TEMPEST_CORE_MANAGER_LIBERATION_ITEM_VIEW_INIT(frame)
	TEMPEST_CORE_MANAGER_LIBERATION_ITEM_RBTN()
end

---- tab - decomposition
function TEMPEST_CORE_MANAGER_TAB_DECOMPOSITION(frame)
	TEMPEST_CORE_MANAGER_DECOMPOSITION_SHOW(frame)
	TEMPEST_CORE_MANAGER_DECOMPOSITION_ITEM_RBTN()
end

-- ** ctrl set ** --
---- liberation material list : create
function CREATE_TEMPEST_CORE_MANAGER_LIBERATION_MATERIAL_LIST(frame)
	local gbox = GET_CHILD_RECURSIVELY(frame, "liberation_material_list_bg")
	if gbox ~= nil then
		local list, cnt = GetClassList("tempest_core_unsealing_item_list")
		if list ~= nil and cnt > 0 then
			local x, y = 0, 0
			local ctrlset_height = ui.GetControlSetAttribute("tempest_core_liberation_material_info", "height")
			for i = 0, cnt - 1 do
				local cls = GetClassByIndexFromList(list, i)
				if cls ~= nil then
					local cls_name = TryGetProp(cls, "ClassName", "None")
					local item_cls = GetClass("Item", cls_name)
					if item_cls ~= nil then
						local make_point = TryGetProp(cls, "MakePoint", 0)
						local inv_item_count = 0
						local inv_item = session.GetInvItemByName(cls_name)
						if inv_item ~= nil then
							inv_item_count = inv_item.count
						end
						y = ctrlset_height * i
						local ctrlset = gbox:CreateOrGetControlSet("tempest_core_liberation_material_info", "TempestCoreLiberationMaterial_"..(i + 1), x, y)
						if ctrlset ~= nil then
							MAKE_TEMPEST_CORE_MANAGER_LIBERATION_MATERIAL_INFO(ctrlset, item_cls, inv_item_count, make_point)
						end
					end
				end
			end
		end
	end
end

---- liberation material list : make in ctrlset
function MAKE_TEMPEST_CORE_MANAGER_LIBERATION_MATERIAL_INFO(ctrlset, item_cls, inv_item_count, make_point)
	if item_cls ~= nil then
		local class_name = TryGetProp(item_cls, "ClassName", "None")
		ctrlset:SetUserValue("ItemName", class_name)

		local slot = GET_CHILD_RECURSIVELY(ctrlset, "slot")
		if slot ~= nil then
			local icon = TryGetProp(item_cls, "Icon", "None")
			SET_SLOT_IMG(slot, icon)
		end
		local name_text = GET_CHILD_RECURSIVELY(ctrlset, "name")
		if name_text ~= nil then
			local name = TryGetProp(item_cls, "Name", "None")
			local dic_name = dic.getTranslatedStr(name)
			name_text:SetTextByKey("name", dic_name)
		end
		local point_text = GET_CHILD_RECURSIVELY(ctrlset, "point")
		if point_text ~= nil then
			point_text:SetTextByKey("point", make_point)
		end
		local amount_text = GET_CHILD_RECURSIVELY(ctrlset, "amount")
		if amount_text ~= nil then
			amount_text:SetTextByKey("amount", inv_item_count)
		end
	end
end

---- liberation material list : remove
function REMOVE_TEMPEST_CORE_MANAGER_LIBERATION_MATERIAL_LIST(frame)
	local gbox = GET_CHILD_RECURSIVELY(frame, "liberation_material_list_bg")
	if gbox ~= nil then
		local count = gbox:GetChildCount();
		for i = 0, count - 1 do
			local child = gbox:GetChildByIndex(i);
			if child ~= nil and string.find(child:GetName(), "TempestCoreLiberationMaterial_") ~= nil then
				gbox:RemoveChild(child:GetName())
			end
		end
	end
end

---- liberation material info Lbtnup scp
function LBUTNUP_SCP_TEMPEST_CORE_LIBERATION_MATERIAL(ctrlset, gbox)
	-- deatil change
	local frame = ctrlset:GetTopParentFrame()
	if frame ~= nil then
		frame:SetUserValue("on_liberation_material_detail", 1)
		TEMPEST_CORE_MANAGER_TAB_LIBERATION_MATERIAL(frame) -- detail material show
	end
	-- detail view
	local item_name = ctrlset:GetUserValue("ItemName")
	local make_point = item_tempest_core.get_unsealing_item_make_point(item_name)
	TEMPEST_CORE_MANAGER_LIBERATION_MATERIAL_DETAIL_VIEW(frame, item_name, make_point)
end

---- liberation material info deatil view
function TEMPEST_CORE_MANAGER_LIBERATION_MATERIAL_DETAIL_VIEW(frame, item_class_name, make_point)	
	-- left
	local item_cls = GetClass("Item", item_class_name)
	if item_cls ~= nil then
		local detail_left_item_info_text = GET_CHILD_RECURSIVELY(frame, "liberation_material_detail_left_item_info_text")
		if detail_left_item_info_text ~= nil then
			local item_name = TryGetProp(item_cls, "Name", "None")
			detail_left_item_info_text:SetTextByKey("item_name", item_name)
			detail_left_item_info_text:SetTextByKey("item_count", 0)
		end

		local detail_left_item_slot =  GET_CHILD_RECURSIVELY(frame, "liberation_material_detail_left_item_slot")
		if detail_left_item_slot ~= nil then
			detail_left_item_slot:SetUserValue("ItemName", item_class_name)
			local icon = TryGetProp(item_cls, "Icon", "None")
			SET_SLOT_IMG(detail_left_item_slot, icon)
		end

		local liberation_material_gauge = GET_CHILD_RECURSIVELY(frame, "liberation_material_gauge")
		local detail_left_item_gauge_text = GET_CHILD_RECURSIVELY(frame, "liberation_material_detail_left_item_gauge_text")
		if liberation_material_gauge ~= nil and detail_left_item_gauge_text ~= nil then
			liberation_material_gauge:SetPoint(0, make_point); -- 게이지바 설정
			detail_left_item_gauge_text:SetTextByKey("cur_point", 0)
			detail_left_item_gauge_text:SetTextByKey("max_point", make_point)
		end
	end
	-- right
	REMOVE_TEMPEST_CORE_MANAGER_LIBERATION_MATERIAL_DETAIL_INFO_LIST(frame) -- remove
	CREATE_TEMPEST_CORE_MANAGER_LIBERATION_MATERIAL_DETAIL_INFO_LIST(frame) -- create
end

---- liberation material info deatil list : create
function CREATE_TEMPEST_CORE_MANAGER_LIBERATION_MATERIAL_DETAIL_INFO_LIST(frame)	
	local gbox = GET_CHILD_RECURSIVELY(frame, "liberation_material_detail_right_list_bg")
	if gbox ~= nil then
		local x, y = 0, 0
		local ctrlset_height = ui.GetControlSetAttribute("tempest_core_liberation_material_detail_info", "height")
		local list = item_tempest_core.get_unsealing_material_list()
		if #list > 0 then
			for i = 1, #list do
				local id = list[i][1]
				local cls_name = list[i][2]
				local point = list[i][3]
				
				y = ctrlset_height * (i - 1)
				local ctrlset = gbox:CreateOrGetControlSet("tempest_core_liberation_material_detail_info", "TempestCoreLiberationDeatilMaterial_"..i, x, y)
				if ctrlset ~= nil then
					MAKE_TEMPEST_CORE_MANAGER_LIBERATION_MATERIAL_DETAIL_INFO(ctrlset, id, cls_name, point)
				end
			end
		end
	end
end

---- liberation material info deatil list : make in ctrlset
function MAKE_TEMPEST_CORE_MANAGER_LIBERATION_MATERIAL_DETAIL_INFO(ctrlset, id, item_class_name, point)
	local item_cls = GetClass("Item", item_class_name)
	if item_cls ~= nil then
		local inv_item_count = 0
		local inv_item = session.GetInvItemByName(item_class_name)
		if inv_item ~= nil and inv_item.isLockState == false then
			inv_item_count = inv_item.count
		end

		ctrlset:SetUserValue("Id", id)
		ctrlset:SetUserValue("ItemName", item_class_name)
		ctrlset:SetUserValue("ItemCount", inv_item_count)
		ctrlset:SetUserValue("ItemPoint", point)

		local slot = GET_CHILD_RECURSIVELY(ctrlset, "slot")
		if slot ~= nil then
			local icon = TryGetProp(item_cls, "Icon", "None")
			SET_SLOT_IMG(slot, icon)
		end
		local name_text = GET_CHILD_RECURSIVELY(ctrlset, "name")
		if name_text ~= nil then
			local name = TryGetProp(item_cls, "Name", "None")
			local dic_name = dic.getTranslatedStr(name)
			name_text:SetTextByKey("name", dic_name)
		end
		local point_text = GET_CHILD_RECURSIVELY(ctrlset, "point")
		if point_text ~= nil then
			point_text:SetTextByKey("point", point)
		end
		local amount_text = GET_CHILD_RECURSIVELY(ctrlset, "amount")
		if amount_text ~= nil then
			amount_text:SetTextByKey("amount", inv_item_count)
		end
	end
end

---- liberation material info deatil list : remove
function REMOVE_TEMPEST_CORE_MANAGER_LIBERATION_MATERIAL_DETAIL_INFO_LIST(frame)
	local gbox = GET_CHILD_RECURSIVELY(frame, "liberation_material_detail_right_list_bg")
	if gbox ~= nil then
		local count = gbox:GetChildCount();
		for i = 0, count - 1 do
			local child = gbox:GetChildByIndex(i);
			if child ~= nil and string.find(child:GetName(), "TempestCoreLiberationDeatilMaterial_") ~= nil then
				gbox:RemoveChild(child:GetName())
			end
		end
	end
end

---- liberation item view
function TEMPEST_CORE_MANAGER_LIBERATION_ITEM_VIEW_INIT(frame)	
	local item_name_text = GET_CHILD_RECURSIVELY(frame, "liberation_item_name_text")
	if item_name_text ~= nil then
		item_name_text:SetTextByKey("value", ScpArgMsg("TempestCoreMgrLiberation_Slot"))
	end

	local step_text = GET_CHILD_RECURSIVELY(frame, "liberation_item_liberation_step_text")
	if step_text ~= nil then
		step_text:SetTextByKey("step", 0)
		step_text:SetTextByKey("max_step", item_tempest_core.get_max_option_count())
	end

	local gauge = GET_CHILD_RECURSIVELY(frame, "liberation_need_point_gauge")
	local gauge_text = GET_CHILD_RECURSIVELY(frame, "liberation_need_point_gauge_text")
	if gauge ~= nil and gauge_text ~= nil then
		gauge:SetPoint(0, 0)
		gauge_text:SetTextByKey("cur_point", 0)
		gauge_text:SetTextByKey("max_point", 0)
		gauge_text:SetTextByKey("option_count", 0)
	end
end

---- liberation view reset
function TEMPEST_CORE_MANAGER_LIBERATION_VIEW_RESET(frame, item_class_name)
	if frame ~= nil then
		REMOVE_TEMPEST_CORE_MANAGER_LIBERATION_LIST(frame)
		CREATE_TEMPEST_CORE_MANAGER_LIBERATION_LIST(frame)

		local slot =  GET_CHILD_RECURSIVELY(frame, "liberation_item_slot")
		if slot ~= nil then
			local item_guid = slot:GetUserValue("ItemGuid")
			if item_guid ~= nil and item_guid ~= "" and item_guid ~= "None" then
				local inv_item = session.GetInvItemByGuid(item_guid)
				if inv_item ~= nil then
					local item_obj = GetIES(inv_item:GetObject())
					if item_obj ~= nil then
						REMOVE_TEMPEST_CORE_MANAGER_LIBERATION_OPTION_LIST(frame) -- option remove
						CREATE_TEMPEST_CORE_MANAGER_LIBERATION_OPTION_LIST(frame, item_obj) -- option craete
					end
				end
			end
		end

		local step_text = GET_CHILD_RECURSIVELY(frame, "liberation_item_liberation_step_text")
		if step_text ~= nil then
			local step_count = 0
			local gbox = GET_CHILD_RECURSIVELY(frame, "liberation_value_bg")
			if gbox ~= nil then
				local count = gbox:GetChildCount();
				for i = 0, count - 1 do
					local ctrlset = gbox:GetChildByIndex(i);
					if ctrlset ~= nil and string.find(ctrlset:GetName(), "TempestCoreLiberationOption_") ~= nil then
						local is_liberation = ctrlset:GetUserIValue("TempestCoreLiberationOption_"..(i + 1))
						step_count = step_count + is_liberation
					end
				end
			end
			step_text:SetTextByKey("step", step_count)
			step_text:SetTextByKey("max_step", item_tempest_core.get_max_option_count())
		end
		
		SET_GAUGE_POINT_TEMPEST_CORE_MANAGER_LIBERATION(frame, 0)
		local gauge_text = GET_CHILD_RECURSIVELY(frame, "liberation_need_point_gauge_text")
		if gauge_text ~= nil then
			local require_point = item_tempest_core.get_tempest_core_require_point(item_class_name)
			gauge_text:SetTextByKey("max_point", require_point)
		end
	end
end

---- liberation list : create
function CREATE_TEMPEST_CORE_MANAGER_LIBERATION_LIST(frame)
	local gbox = GET_CHILD_RECURSIVELY(frame, "liberation_list_detail_bg")
	if gbox ~= nil then
		local x, y = 0, 0
		local ctrlset_height = ui.GetControlSetAttribute("tempest_core_liberation_info", "height")
		local list = item_tempest_core.get_unsealing_item_list()
		for i = 1, #list do
			local id = list[i][1]
			local name = list[i][2]
			local point = list[i][3]
			local item_cls = GetClass("Item", name)
			if item_cls ~= nil then
				y = ctrlset_height * (i - 1)
				local ctrlset = gbox:CreateOrGetControlSet("tempest_core_liberation_info", "TempestCoreLiberation_"..i, x, y)
				if ctrlset ~= nil then
					MAKE_TEMPEST_CORE_MANAGER_LIBERATION_INFO(ctrlset, id, item_cls, point)
				end
			end
		end
	end
end

---- liberation list : make ctrlset
function MAKE_TEMPEST_CORE_MANAGER_LIBERATION_INFO(ctrlset, id, item_cls, point)
	local class_name = TryGetProp(item_cls, "ClassName", "None")
	local inv_item_count = 0
	local inv_item = session.GetInvItemByName(class_name)
	if inv_item ~= nil and inv_item.isLockState == false then
		inv_item_count = inv_item.count
	end

	ctrlset:SetUserValue("Id", id)
	ctrlset:SetUserValue("ItemName", class_name)
	ctrlset:SetUserValue("ItemCount", inv_item_count)
	ctrlset:SetUserValue("ItemPoint", point)

	local slot = GET_CHILD_RECURSIVELY(ctrlset, "slot")
	if slot ~= nil then
		local icon = TryGetProp(item_cls, "Icon", "None")
		SET_SLOT_IMG(slot, icon)
	end
	local name_text = GET_CHILD_RECURSIVELY(ctrlset, "name")
	if name_text ~= nil then
		local name = TryGetProp(item_cls, "Name", "None")
		local dic_name = dic.getTranslatedStr(name)
		name_text:SetTextByKey("name", dic_name)
	end
	local point_text = GET_CHILD_RECURSIVELY(ctrlset, "point")
	if point_text ~= nil then
		point_text:SetTextByKey("point", point)
	end
	local amount_text = GET_CHILD_RECURSIVELY(ctrlset, "amount")
	if amount_text ~= nil then
		amount_text:SetTextByKey("amount", inv_item_count)
	end
end

---- liberation list : remove
function REMOVE_TEMPEST_CORE_MANAGER_LIBERATION_LIST(frame)	
	local gbox = GET_CHILD_RECURSIVELY(frame, "liberation_list_detail_bg")
	if gbox ~= nil then
		local count = gbox:GetChildCount();
		for i = 0, count - 1 do
			local child = gbox:GetChildByIndex(i);
			if child ~= nil and string.find(child:GetName(), "TempestCoreLiberation_") ~= nil then
				gbox:RemoveChild(child:GetName())
			end
		end
	end	
end

---- liberation option list : create
function CREATE_TEMPEST_CORE_MANAGER_LIBERATION_OPTION_LIST(frame, item_obj)
	local gbox = GET_CHILD_RECURSIVELY(frame, "liberation_value_bg")
	if gbox ~= nil then
		local x, y = 0, 0
		local ctrlset_height = ui.GetControlSetAttribute("tempest_core_liberation_option_info", "height")
		local max_option_count = item_tempest_core.get_max_option_count()
		for i = 1, max_option_count do
			y = ctrlset_height * (i - 1)
			local ctrlset = gbox:CreateOrGetControlSet("tempest_core_liberation_option_info", "TempestCoreLiberationOption_"..i, x, y)
			if ctrlset ~= nil then
				MAKE_TEMPEST_CORE_MANAGER_LIBERATION_OPTION_INFO(ctrlset, item_obj, i)
			end
		end
	end
end

---- liberation option list : make
function MAKE_TEMPEST_CORE_MANAGER_LIBERATION_OPTION_INFO(ctrlset, item_obj, index)
	local prop_group_name = "RandomOptionGroup_"..index
	local prop_name = "RandomOption_"..index
	local prop_value = "RandomOptionValue_"..index

	local clmsg = "None"
	if item_obj[prop_group_name] == 'ATK' then
		clmsg = 'ItemRandomOptionGroupATK'
	elseif item_obj[prop_group_name] == 'DEF' then
		clmsg = 'ItemRandomOptionGroupDEF'
	elseif item_obj[prop_group_name] == 'UTIL_WEAPON' then
		clmsg = 'ItemRandomOptionGroupUTIL'
	elseif item_obj[prop_group_name] == 'UTIL_ARMOR' then
		clmsg = 'ItemRandomOptionGroupUTIL'
	elseif item_obj[prop_group_name] == 'UTIL_SHILED' then
		clmsg = 'ItemRandomOptionGroupUTIL'
	elseif item_obj[prop_group_name] == 'STAT' then
		clmsg = 'ItemRandomOptionGroupSTAT'		
	elseif item_obj[prop_group_name] == 'SPECIAL' then
		clmsg = 'ItemRandomOptionGroupSPECIAL'		
	end

	local text = nil
	local img = nil
	local is_liberation = 0
	if item_obj[prop_value] ~= 0 and item_obj[prop_name] ~= "None" then
		local cls_msg = ScpArgMsg(item_obj[prop_name])
		local option_name = string.format("%s %s", ClMsg(clmsg), cls_msg)
		local cur_value = item_obj[prop_value]
		text = ABILITY_DESC_NO_PLUS2(option_name, cur_value, 0)
		is_liberation = 1
	else
		text = ""
		img = "core_option_sealed_"..index
	end
	ctrlset:SetUserValue("TempestCoreLiberationOption_"..index, is_liberation)

	if text ~= nil then
		local option_text = GET_CHILD_RECURSIVELY(ctrlset, "option")
		option_text:SetTextByKey("option", text)
	end
	
	if img ~= nil then
		local pic = GET_CHILD_RECURSIVELY(ctrlset, "pic")
		pic:SetImage(img)
	end
end

---- liberation option list : remove
function REMOVE_TEMPEST_CORE_MANAGER_LIBERATION_OPTION_LIST(frame)
	local gbox = GET_CHILD_RECURSIVELY(frame, "liberation_value_bg")
	if gbox ~= nil then
		gbox:RemoveAllChild()
	end
end

---- decomposition ret list : create
function CREATE_TEMPEST_CORE_MANAGER_DECOMPOSITION_RET_LIST(frame, item_obj)
	local gbox = GET_CHILD_RECURSIVELY(frame, "decomposition_ret_list_detail_bg")
	if gbox ~= nil then
		local x, y = 0, 0
		local ctrlset = gbox:CreateOrGetControlSet("tempest_core_decomposition_info", "TempestCoreDecompoisitonResult", x, y)
		if ctrlset ~= nil then
			local return_item_name, return_item_count = item_tempest_core.get_decomposed_item(item_obj)
			MAKE_TEMPEST_CORE_MANAGER_DECOMPOSITION_RET_INFO(ctrlset, return_item_name, return_item_count)
		end
	end
end

---- decomposition ret list : make
function MAKE_TEMPEST_CORE_MANAGER_DECOMPOSITION_RET_INFO(ctrlset, item_name, item_count)
	local item_cls = GetClass("Item", item_name)
	if item_cls ~= nil then
		local slot = GET_CHILD_RECURSIVELY(ctrlset, "slot")
		if slot ~= nil then
			local icon = TryGetProp(item_cls, "Icon", "None")
			SET_SLOT_IMG(slot, icon)
		end
		local name_text = GET_CHILD_RECURSIVELY(ctrlset, "name")
		if name_text ~= nil then
			local name = TryGetProp(item_cls, "Name", "None")
			local dic_name = dic.getTranslatedStr(name)
			name_text:SetTextByKey("name", dic_name)
		end
		local count_text = GET_CHILD_RECURSIVELY(ctrlset, "count")
		if count_text ~= nil then
			count_text:SetTextByKey("count", item_count)
		end
	end
end

---- decomposition ret list : remove
function REMOVE_TEMPEST_CORE_MANAGER_DECOMPOSITION_RET_LIST(frame)
	local gbox = GET_CHILD_RECURSIVELY(frame, "decomposition_ret_list_detail_bg")
	if gbox ~= nil then
		gbox:RemoveAllChild()
	end
end

---- decomposition view reset
function TEMPEST_CORE_MANAGER_DECOMPOSITION_VIEW_RESET(frame)
	local slot = GET_CHILD_RECURSIVELY(frame, "decomposition_exec_slot")
	if slot ~= nil then
		slot:ClearIcon()
		slot:SetUserValue("ItemName", "None")
		slot:SetUserValue("ItemGuid", "None")
	end

	local slot_image = GET_CHILD_RECURSIVELY(frame, "decomposition_exec_slot_bg_image")
	if slot_image ~= nil then
		slot_image:ShowWindow(1)
	end

	local item_name_text = GET_CHILD_RECURSIVELY(frame, "decomposition_exec_item_text")
	if item_name_text ~= nil then
		item_name_text:SetTextByKey("value", ScpArgMsg("TempestCoreMgrLiberation_Slot"))
	end

	local step_text = GET_CHILD_RECURSIVELY(frame, "decomposition_exec_step_text")
	if step_text ~= nil then
		step_text:SetTextByKey("step", 0)
	end

	REMOVE_TEMPEST_CORE_MANAGER_DECOMPOSITION_RET_LIST(frame) -- ret remove
end

local function get_current_material_point(frame)
	local total = 0
	local list = item_tempest_core.get_unsealing_material_list()
	if list ~= nil and #list > 0 then
		for i = 1, #list do
			local id = list[i][1]
			local use_count = frame:GetUserIValue("Smelting"..id)
			total = total + (use_count  * list[i][3])
		end
	end
	
	return total
end

-- ** gauge ** --
---- gauge - liberation material detail
function SET_GAUGE_POINT_TEMPEST_CORE_MANAGER_LIBERATION_MATERIAL_DETAIL(frame)
	local cur_point = get_current_material_point(frame)

	local gauge = GET_CHILD_RECURSIVELY(frame, "liberation_material_gauge")
	local gauge_text = GET_CHILD_RECURSIVELY(frame, "liberation_material_detail_left_item_gauge_text")
	if gauge ~= nil and gauge_text ~= nil then
		local max_point = gauge:GetMaxPoint()
		local mod = math.fmod(cur_point, max_point)
		
		if mod == 0 and cur_point > 0 then
			gauge:SetCurPoint(max_point)
			gauge_text:SetTextByKey("cur_point", max_point)	
		else
			gauge:SetCurPoint(mod)
			gauge_text:SetTextByKey("cur_point", mod)
		end
		

		local item_info_text = GET_CHILD_RECURSIVELY(frame, "liberation_material_detail_left_item_info_text")
		if item_info_text ~= nil then
			local div = math.floor(cur_point / max_point)
			item_info_text:SetTextByKey("item_count", div)			
		end
	end
end

---- gauge - liberation
function SET_GAUGE_POINT_TEMPEST_CORE_MANAGER_LIBERATION(frame, cur_point)	
	local slot =  GET_CHILD_RECURSIVELY(frame, "liberation_item_slot")
	if slot == nil then
		return
	end
		
	local item_guid = slot:GetUserValue("ItemGuid")
	if item_guid == 'None' then
		return
	end

	local inv_item = session.GetInvItemByGuid(item_guid)
	if inv_item == nil then
		return
	end

	local item_obj = GetIES(inv_item:GetObject())
	local item_name = TryGetProp(item_obj, "ClassName", "None")
	local max_point = GetClass('tempest_core_item_list', item_name).RequirePoint 
	
	local gauge = GET_CHILD_RECURSIVELY(frame, "liberation_need_point_gauge")
	local gauge_text = GET_CHILD_RECURSIVELY(frame, "liberation_need_point_gauge_text")
	gauge:SetPoint(0, max_point)	
	gauge_text:SetTextByKey("max_point", max_point)
	local max = max_point * item_tempest_core.get_remain_option_count(item_obj)

	if cur_point > max then
		cur_point = max
	end

	if gauge ~= nil and gauge_text ~= nil then
		gauge:SetCurPoint(math.fmod(cur_point, max_point))
		if math.fmod(cur_point, max_point) == 0 and cur_point > 0 then
			gauge:SetCurPoint(max_point)
			gauge_text:SetTextByKey("cur_point", max_point)
		else
			gauge:SetCurPoint(math.fmod(cur_point, max_point))
			gauge_text:SetTextByKey("cur_point", math.fmod(cur_point, max_point))
		end

		local option_count = math.floor(cur_point / max_point)
		gauge_text:SetTextByKey("option_count", option_count)

		-- option slot effect
		MAKE_EFFECT_TEMPEST_CORE_LIBERATION_OPTION_SLOT(frame, option_count) 
	end
end

-- ** edit ** --
---- edit - liberation material detail
function TEMPEST_CORE_MANAGER_LIBERATION_MATERIAL_DETAIL_EDIT_TYPINGSCP(gbox, edit)
	local frame = gbox:GetTopParentFrame()	
	local ctrlset = gbox:GetParent():GetParent()
	local use_count = tonumber(edit:GetText());
	if frame ~= nil and ctrlset ~= nil then
		local id = ctrlset:GetUserIValue("Id")
		local item_point = ctrlset:GetUserIValue("ItemPoint")
		local item_count = ctrlset:GetUserIValue("ItemCount")
		if use_count ~= nil then
			if use_count > item_count then
				use_count = item_count
			end
			edit:SetText(use_count)
			ctrlset:SetUserValue("UseCount", use_count)
		else
			ctrlset:SetUserValue("UseCount", 0)
		end
		frame:SetUserValue("Smelting"..id, ctrlset:GetUserIValue("UseCount"))
		SET_GAUGE_POINT_TEMPEST_CORE_MANAGER_LIBERATION_MATERIAL_DETAIL(frame)
	end
end

---- edit - liberation
function TEMPEST_CORE_MANAGER_LIBERATION_EDIT_TYPINGSCP(gbox, edit)	
	local frame = gbox:GetTopParentFrame()	
	local ctrlset = gbox:GetParent():GetParent()
	local use_count = tonumber(edit:GetText()); 
	if frame ~= nil and ctrlset ~= nil then
		local id = ctrlset:GetUserIValue("Id")
		local item_point = ctrlset:GetUserIValue("ItemPoint")
		local item_count = ctrlset:GetUserIValue("ItemCount")
		if item_point <= 0 then
			return

		end
		if use_count ~= nil then
			if use_count > item_count then
				use_count = item_count
			end

			local slot = GET_CHILD_RECURSIVELY(frame, "liberation_item_slot")
			local max = get_remain_option_point(slot)
			max = math.floor(max / item_point)

			if use_count > max then
				use_count = max
			end

			edit:SetText(use_count)
			ctrlset:SetUserValue("UseCount", use_count)			
			SET_GAUGE_POINT_TEMPEST_CORE_MANAGER_LIBERATION(frame, use_count * item_point)
		else
			ctrlset:SetUserValue("UseCount", 0)			
			SET_GAUGE_POINT_TEMPEST_CORE_MANAGER_LIBERATION(frame, 0)
		end
		
		frame:SetUserValue("Liberation"..id, ctrlset:GetUserIValue("UseCount"))
	end
end

-- ** button ** --
---- button - liberation material prev
function TEMPEST_CORE_MANAGER_LIBERATION_MATERIAL_DETAIL_PREV_BTN(parent, btn)
	local frame = parent:GetTopParentFrame()
	frame:SetUserValue("on_liberation_material_detail", 0)
	TEMPEST_CORE_MANAGER_TAB_LIBERATION_MATERIAL(frame) -- prev state
end

---- button - liberation material deatil info upbtn
function SCP_TEMPEST_CORE_LIBERATION_MATERIAL_DETAIL_UP_BTN(gbox, btn)	
	local frame = gbox:GetTopParentFrame()
	local ctrlset = gbox:GetParent():GetParent()
	if frame ~= nil and ctrlset ~= nil then
		local id = ctrlset:GetUserIValue("Id")
		local item_count = ctrlset:GetUserIValue("ItemCount") -- 현재 보유량		
		local item_point = ctrlset:GetUserIValue("ItemPoint")
		local use_count = ctrlset:GetUserIValue("UseCount")		
		if use_count > item_count then
			return
		end

		local add = 1
		if 1 == keyboard.IsKeyPressed("LCTRL") then
			add = 10
		end

		local set_point = use_count + add
		if set_point > item_count then
			set_point = item_count 
		end

		local use_count_text = GET_CHILD_RECURSIVELY(ctrlset, "use_count")
		if use_count_text ~= nil then
			use_count_text:SetText(set_point)			
			ctrlset:SetUserValue("UseCount", set_point)
		end
		frame:SetUserValue("Smelting"..id, ctrlset:GetUserIValue("UseCount"))
		SET_GAUGE_POINT_TEMPEST_CORE_MANAGER_LIBERATION_MATERIAL_DETAIL(frame)
	end
end

---- button - liberation material deatil info downbtn
function SCP_TEMPEST_CORE_LIBERATION_MATERIAL_DETAIL_DOWN_BTN(gbox, btn)	
	local frame = gbox:GetTopParentFrame()
	local ctrlset = gbox:GetParent():GetParent()
	if frame ~= nil and ctrlset ~= nil then
		local id = ctrlset:GetUserIValue("Id")
		local item_count = ctrlset:GetUserIValue("ItemCount")
		local item_point = ctrlset:GetUserIValue("ItemPoint")
		local use_count = ctrlset:GetUserIValue("UseCount")
		if use_count < 0 then
			return
		end

		local add = 1
		if 1 == keyboard.IsKeyPressed("LCTRL") then
			add = 10
		end

		local set_point = use_count - add
		if set_point < 0 then
			set_point = 0 
		end

		local use_count_text = GET_CHILD_RECURSIVELY(ctrlset, "use_count")
		if use_count_text ~= nil then
			use_count_text:SetText(set_point)
			ctrlset:SetUserValue("UseCount", set_point)
		end

		frame:SetUserValue("Smelting"..id, ctrlset:GetUserIValue("UseCount"))
		SET_GAUGE_POINT_TEMPEST_CORE_MANAGER_LIBERATION_MATERIAL_DETAIL(frame)
	end
end

--- button - smelting
function TEMPEST_CORE_MANAGER_SMELTING_BTN(parent, btn)
	local frame = parent:GetTopParentFrame()
	if frame ~= nil then
		local slot = GET_CHILD_RECURSIVELY(frame, "liberation_material_detail_left_item_slot")
		local item_class_name = slot:GetUserValue("ItemName")
		if item_class_name ~= nil and item_class_name ~= "" and item_class_name ~= "None" then
			local str = MAKE_TEMPEST_CORE_SMELTING_STR(frame, item_class_name)
			local total_point = item_tempest_core.get_total_point_from_material(str)
			local max_point = item_tempest_core.get_unsealing_item_make_point(item_class_name)

			local item_name = ""
			local item_cls = GetClass("Item", item_class_name)
			if item_cls ~= nil then
				item_name = TryGetProp(item_cls, "Name", "None")
				item_name = dic.getTranslatedStr(item_name)
			end

			-- use count msg
			if total_point <= 0 then
				ui.SysMsg(ScpArgMsg("TempestCoreMgrSmelting_UseCount"))
				return
			end

			-- need point msg
			if total_point < max_point then
				ui.SysMsg(ScpArgMsg("TempestCoreMgrSmelting_NeedPoint", "name", item_name))
				return
			end

			-- msg box
			local unsealing_item_name, unsealing_item_count = item_tempest_core.get_unsealing_item(str)
			local yes_scp = string.format('TEMPEST_CORE_MANAGER_SMELTING_MSG_BOX(\'%s\', \'%s\')', str, item_class_name)
			local msg_box = ui.MsgBox(ScpArgMsg("TempestCoreMgrSmelting_Request", "name", item_name, "count", unsealing_item_count), yes_scp, '')
			SET_MODAL_MSGBOX(msg_box)
		end
	end
end

---- button - smelting : msg box
function TEMPEST_CORE_MANAGER_SMELTING_MSG_BOX(str, item_class_name)
	-- smelting
	pc.ReqExecuteTx_Item_String("MAKE_TEMPEST_CORE_UNSEALING_MATERIAL", str)
	-- init detail view
	local frame = ui.GetFrame("tempest_core_manager")
	if frame ~= nil then
		local make_point = item_tempest_core.get_unsealing_item_make_point(item_class_name)
		TEMPEST_CORE_MANAGER_LIBERATION_MATERIAL_DETAIL_VIEW(frame, item_class_name, make_point)
	end
end

---- button - liberation info upbtn
function SCP_TEMPEST_CORE_LIBERATION_UP_BTN(gbox, btn)	
	local frame = gbox:GetTopParentFrame()
	local ctrlset = gbox:GetParent():GetParent()
	
	if frame ~= nil and ctrlset ~= nil then
		local slot = GET_CHILD_RECURSIVELY(frame, "liberation_item_slot")
		if slot == nil then
			return
		end
			
		local item_guid = slot:GetUserValue("ItemGuid")
		if item_guid == 'None' then
			return
		end

		local inv_item = session.GetInvItemByGuid(item_guid)
		if inv_item == nil then
			return
		end

		local item_obj = GetIES(inv_item:GetObject())
		local id = ctrlset:GetUserIValue("Id")
		local item_count = ctrlset:GetUserIValue("ItemCount")
		local item_point = ctrlset:GetUserIValue("ItemPoint")
		local use_count = ctrlset:GetUserIValue("UseCount")
		if use_count > item_count then
			return
		end

		local add = 1
		if 1 == keyboard.IsKeyPressed("LCTRL") then
			add = 10
		end

		local set_point = use_count + add
		if set_point > item_count then
			set_point = item_count 
		end

		local gauge = GET_CHILD_RECURSIVELY(frame, "liberation_need_point_gauge")	
		local max_point = gauge:GetMaxPoint()
		local max = max_point * item_tempest_core.get_remain_option_count(item_obj)

		if set_point * item_point > max then
			set_point = max / item_point
		end

		local use_count_text = GET_CHILD_RECURSIVELY(ctrlset, "use_count")
		if use_count_text ~= nil then
			use_count_text:SetText(set_point)
			ctrlset:SetUserValue("UseCount", set_point)
		end
		SET_GAUGE_POINT_TEMPEST_CORE_MANAGER_LIBERATION(frame, set_point * item_point)
		frame:SetUserValue("Liberation"..id, ctrlset:GetUserIValue("UseCount"))
	end
end

---- button - liberation info downbtn
function SCP_TEMPEST_CORE_LIBERATION_DOWN_BTN(gbox, btn)
	local frame = gbox:GetTopParentFrame()
	local ctrlset = gbox:GetParent():GetParent()
	if frame ~= nil and ctrlset ~= nil then

		local slot = GET_CHILD_RECURSIVELY(frame, "liberation_item_slot")
		if slot == nil then
			return
		end
			
		local item_guid = slot:GetUserValue("ItemGuid")
		if item_guid == 'None' then
			return
		end

		local id = ctrlset:GetUserIValue("Id")
		local item_count = ctrlset:GetUserIValue("ItemCount")
		local item_point = ctrlset:GetUserIValue("ItemPoint")
		local use_count = ctrlset:GetUserIValue("UseCount")
		if use_count < 0 then
			return
		end

		local add = 1
		if 1 == keyboard.IsKeyPressed("LCTRL") then
			add = 10
		end

		local set_point = use_count - add
		if set_point < 0 then
			set_point = 0 
		end

		local use_count_text = GET_CHILD_RECURSIVELY(ctrlset, "use_count")
		if use_count_text ~= nil then
			use_count_text:SetText(set_point)
			ctrlset:SetUserValue("UseCount", set_point)
		end
	
		SET_GAUGE_POINT_TEMPEST_CORE_MANAGER_LIBERATION(frame, set_point * item_point)
		frame:SetUserValue("Liberation"..id, ctrlset:GetUserIValue("UseCount"))
	end
end

---- button - liberation option
function TEMPEST_CORE_MANAGER_LIBERATION_OPTION_BTN(parent, btn)	
	local frame = parent:GetTopParentFrame()
	if frame ~= nil then
		local slot = GET_CHILD_RECURSIVELY(frame, "liberation_item_slot")
		if slot ~= nil then
			local item_idx = slot:GetUserValue("ItemGuid")
			local item_class_name = slot:GetUserValue("ItemName")
			if item_class_name ~= nil and item_class_name ~= "" and item_class_name ~= "None" then
				local str = MAKE_TEMPEST_CORE_LIBERATION_STR(frame, item_idx)
				local total_point = item_tempest_core.get_total_point_from_unsealing(str)
				local require_point = item_tempest_core.get_tempest_core_require_point(item_class_name)
				
				local item_name = ""
				local item_cls = GetClass("Item", item_class_name)
				if item_cls ~= nil then
					item_name = TryGetProp(item_cls, "Name", "None")
					item_name = dic.getTranslatedStr(item_name)
				end

				-- use count msg
				if total_point <= 0 then
					ui.SysMsg(ScpArgMsg("TempestCoreMgrSmelting_UseCount"))
					return
				end

				-- need point msg
				if total_point < require_point then
					ui.SysMsg(ScpArgMsg("TempestCoreMgrLiberation_NeedPoint"))
					return
				end
				
				if total_point % require_point ~= 0 then
					ui.SysMsg(ScpArgMsg("TempestCoreMgrLiberation_NeedPoint2"))
					return
				end

				-- msg box
				local yes_scp = string.format('TEMPEST_CORE_MANAGER_LIBERATION_OPTION_MSG_BOX(\'%s\', \'%s\')', str, item_class_name)
				local msg_box = ui.MsgBox(ScpArgMsg("TempestCoreMgrLiberation_Request"), yes_scp, '')
				SET_MODAL_MSGBOX(msg_box)
			else
				ui.SysMsg(ScpArgMsg("TempestCoreMgrLiberation_Slot"))
			end
		end
	end
end

---- button - liberation option : msg box
function TEMPEST_CORE_MANAGER_LIBERATION_OPTION_MSG_BOX(str, item_class_name)
	MAKE_EFFECT_TEMPEST_CORE_LIBERATION_OPTION_SLOT_RESULT(str)
end

---- button - decomposition
function TEMPEST_CORE_MANAGER_DECOMPOSITION_BTN(parent, btn)
	local frame = parent:GetTopParentFrame()
	if frame ~= nil then
		local slot = GET_CHILD_RECURSIVELY(frame, "decomposition_exec_slot")
		if slot ~= nil then
			local item_idx = slot:GetUserValue("ItemGuid")
			if item_idx == nil or item_idx == "" or item_idx == "None" then
				ui.SysMsg(ScpArgMsg("TempestCoreMgrLiberation_Slot"))
				return
			end
			-- msg box
			local yes_scp = string.format("TEMPEST_CORE_MANAGER_DECOMPOSITION_MSG_BOX(\'%s\')", item_idx)
			local msg_box = ui.MsgBox(ScpArgMsg("TempestCoreMgrDecompose_Request"), yes_scp, '')
			SET_MODAL_MSGBOX(msg_box)
		end
	end
end

---- button - decomposition : msg box
function TEMPEST_CORE_MANAGER_DECOMPOSITION_MSG_BOX(guid)
	MAKE_EFFECT_TEMPEST_CORE_DECOMPOSITION_RESULT(guid)
end

-- ** slot ** --
---- slot - liberation item slot : drop
function TEMPEST_CORE_MANAGER_LIBERATION_ITEM_DROP(parent, slot)
	local frame = parent:GetTopParentFrame()
	local lift_icon = ui.GetLiftIcon()
	if lift_icon ~= nil then
		local from_frame = lift_icon:GetTopParentFrame()
		if from_frame ~= nil and from_frame:GetName() == "inventory" then
			local icon_info = lift_icon:GetInfo()
			local guid = icon_info:GetIESID()
			local inv_item = session.GetInvItemByGuid(guid)
			if inv_item ~= nil then
				TEMPEST_CORE_MANAGER_LIBERATION_ITEM_REG(frame, slot, inv_item)
			end
		end
	end
end

---- slot - liberation item slot : register item
function TEMPEST_CORE_MANAGER_LIBERATION_ITEM_REG(frame, slot, inv_item)	
	if frame == nil or slot == nil then
		return
	end

	local item_obj = GetIES(inv_item:GetObject())
	if item_obj == nil then
		return
	end

	local item_cls_name = TryGetProp(item_obj, "ClassName", "None")
	if item_tempest_core.is_tempest_core_item(item_cls_name) == false then
		ui.SysMsg(ScpArgMsg("TempestCoreMgrLiberation_NoReg"))
		return
	end

	SET_SLOT_ITEM(slot, inv_item)	
	slot:SetUserValue("ItemName", item_cls_name)
	slot:SetUserValue("ItemGuid", inv_item:GetIESID())
	
	local slot_image = GET_CHILD_RECURSIVELY(frame, "liberation_item_slot_bg_image")
	if slot_image ~= nil then
		slot_image:ShowWindow(0)
	end

	local item_name_text = GET_CHILD_RECURSIVELY(frame, "liberation_item_name_text")
	if item_name_text ~= nil then
		local item_name = TryGetProp(item_obj, "Name", "None")
		item_name = dic.getTranslatedStr(item_name)
		item_name_text:SetTextByKey("value", item_name)
	end

	REMOVE_TEMPEST_CORE_MANAGER_LIBERATION_OPTION_LIST(frame) -- option remove
	CREATE_TEMPEST_CORE_MANAGER_LIBERATION_OPTION_LIST(frame, item_obj) -- option craete

	local gauge_text = GET_CHILD_RECURSIVELY(frame, "liberation_need_point_gauge_text")
	if gauge_text ~= nil then		
		local require_point = item_tempest_core.get_tempest_core_require_point(item_cls_name)
		local gauge = GET_CHILD_RECURSIVELY(frame, "liberation_need_point_gauge")
		gauge:SetPoint(0, require_point)
		gauge_text:SetTextByKey("max_point", require_point)
	end

	local step_text = GET_CHILD_RECURSIVELY(frame, "liberation_item_liberation_step_text")
	if step_text ~= nil then
		local step_count = 0
		local gbox = GET_CHILD_RECURSIVELY(frame, "liberation_value_bg")
		if gbox ~= nil then
			local count = gbox:GetChildCount();
			for i = 0, count - 1 do
				local ctrlset = gbox:GetChildByIndex(i);
				if ctrlset ~= nil and string.find(ctrlset:GetName(), "TempestCoreLiberationOption_") ~= nil then
					local is_liberation = ctrlset:GetUserIValue("TempestCoreLiberationOption_"..(i + 1))
					step_count = step_count + is_liberation
				end
			end
		end
		step_text:SetTextByKey("step", step_count)
		step_text:SetTextByKey("max_step", item_tempest_core.get_max_option_count())
	end
end

---- slot - liberation item slot : rbtn
function TEMPEST_CORE_MANAGER_LIBERATION_ITEM_RBTN(parent, slot)
	local frame = nil
	if parent == nil then
		frame = ui.GetFrame("tempest_core_manager")
	else
		frame = parent:GetTopParentFrame()
	end
	
	if slot == nil then
		slot = GET_CHILD_RECURSIVELY(frame, "liberation_item_slot")
	end

	slot:ClearIcon()
	slot:SetUserValue("ItemName", "None")
	slot:SetUserValue("ItemGuid", "None")

	local slot_image = GET_CHILD_RECURSIVELY(frame, "liberation_item_slot_bg_image")
	if slot_image ~= nil then
		slot_image:ShowWindow(1)
	end

	local item_name_text = GET_CHILD_RECURSIVELY(frame, "liberation_item_name_text")
	if item_name_text ~= nil then
		item_name_text:SetTextByKey("value", ScpArgMsg("TempestCoreMgrLiberation_Slot"))
	end

	local step_text = GET_CHILD_RECURSIVELY(frame, "liberation_item_liberation_step_text")
	if step_text ~= nil then
		step_text:SetTextByKey("step", 0)
	end

	REMOVE_TEMPEST_CORE_MANAGER_LIBERATION_OPTION_LIST(frame) -- option remove
	reset_current_liberation_point(frame)
	REMOVE_TEMPEST_CORE_MANAGER_LIBERATION_LIST(frame)	
	CREATE_TEMPEST_CORE_MANAGER_LIBERATION_LIST(frame)
	TEMPEST_CORE_MANAGER_LIBERATION_ITEM_VIEW_INIT(frame)	
end

---- slot - decomposition item slot : drop
function TEMPEST_CORE_MANAGER_DECOMPOSITION_ITEM_DROP(parent, slot)
	local frame = parent:GetTopParentFrame()
	local lift_icon = ui.GetLiftIcon()
	if lift_icon ~= nil then
		local from_frame = lift_icon:GetTopParentFrame()
		if from_frame ~= nil and from_frame:GetName() == "inventory" then
			local icon_info = lift_icon:GetInfo()
			local guid = icon_info:GetIESID()
			local inv_item = session.GetInvItemByGuid(guid)
			if inv_item ~= nil then
				TEMPEST_CORE_MANAGER_DECOMPOSITION_ITEM_REG(frame, slot, inv_item)
			end
		end
	end
end

---- slot - decomposition item slot : register item
function TEMPEST_CORE_MANAGER_DECOMPOSITION_ITEM_REG(frame, slot, inv_item)
	if frame == nil or slot == nil then
		return
	end

	local item_obj = GetIES(inv_item:GetObject())
	if item_obj == nil then
		return
	end

	if item_tempest_core.is_able_to_decompose(item_obj) == false then
		return
	end

	local item_cls_name = TryGetProp(item_obj, "ClassName", "None")
	if item_tempest_core.is_tempest_core_item(item_cls_name) == false then
		ui.SysMsg(ScpArgMsg("TempestCoreMgrLiberation_NoReg"))
		return
	end

	SET_SLOT_ITEM(slot, inv_item)
	slot:SetUserValue("ItemName", item_cls_name)
	slot:SetUserValue("ItemGuid", inv_item:GetIESID())

	local slot_image = GET_CHILD_RECURSIVELY(frame, "decomposition_exec_slot_bg_image")
	if slot_image ~= nil then
		slot_image:ShowWindow(0)
	end

	local item_name_text = GET_CHILD_RECURSIVELY(frame, "decomposition_exec_item_text")
	if item_name_text ~= nil then
		local item_name = TryGetProp(item_obj, "Name", "None")
		item_name = dic.getTranslatedStr(item_name)
		item_name_text:SetTextByKey("value", item_name)
	end

	local step_text = GET_CHILD_RECURSIVELY(frame, "decomposition_exec_step_text")
	if step_text ~= nil then
		local step_count = item_tempest_core.get_tempest_core_unsealing_option_count(item_obj)
		step_text:SetTextByKey("step", step_count)
		step_text:SetTextByKey("max_step", item_tempest_core.get_max_option_count())
	end

	REMOVE_TEMPEST_CORE_MANAGER_DECOMPOSITION_RET_LIST(frame) -- ret remove
	CREATE_TEMPEST_CORE_MANAGER_DECOMPOSITION_RET_LIST(frame, item_obj) -- ret craete
end

---- slot - decomposition item slot : rbtn
function TEMPEST_CORE_MANAGER_DECOMPOSITION_ITEM_RBTN(parent, slot)
	local frame = nil
	if parent == nil then
		frame = ui.GetFrame("tempest_core_manager")
	else
		frame = parent:GetTopParentFrame()
	end

	if slot == nil then
		slot = GET_CHILD_RECURSIVELY(frame, "decomposition_exec_slot")
	end

	slot:ClearIcon()
	slot:SetUserValue("ItemName", "None")
	slot:SetUserValue("ItemGuid", "None")

	local slot_image = GET_CHILD_RECURSIVELY(frame, "decomposition_exec_slot_bg_image")
	if slot_image ~= nil then
		slot_image:ShowWindow(1)
	end

	local item_name_text = GET_CHILD_RECURSIVELY(frame, "decomposition_exec_item_text")
	if item_name_text ~= nil then
		item_name_text:SetTextByKey("value", ScpArgMsg("TempestCoreMgrLiberation_Slot"))
	end

	local step_text = GET_CHILD_RECURSIVELY(frame, "decomposition_exec_step_text")
	if step_text ~= nil then
		step_text:SetTextByKey("step", 0)
	end

	REMOVE_TEMPEST_CORE_MANAGER_DECOMPOSITION_RET_LIST(frame) -- ret remove
end

-- ** method ** --
-- make smelting str
function MAKE_TEMPEST_CORE_SMELTING_STR(frame, item_name)
	local str = ""
	local unsealing_item_cls = GetClass("tempest_core_unsealing_item_list", item_name)
	if unsealing_item_cls ~= nil then
		local unsealing_item_id = TryGetProp(unsealing_item_cls, "ClassID", 0)
		str = str..unsealing_item_id.."#"
	end

	local list = item_tempest_core.get_unsealing_material_list()
	if list ~= nil and #list > 0 then
		for i = 1, #list do
			local id = list[i][1]
			local use_count = frame:GetUserIValue("Smelting"..id)
			if use_count > 0 then
				str = str..id.."/"..use_count..";"
			end
		end
	end
	return str
end

-- make liberation str
function MAKE_TEMPEST_CORE_LIBERATION_STR(frame, item_idx)
	local str = item_idx.."#"
	local list = item_tempest_core.get_unsealing_item_list()
	if list ~= nil and #list > 0 then
		for i = 1, #list do
			local id = list[i][1]
			local use_count = frame:GetUserIValue("Liberation"..id)
			if use_count > 0 then
				str = str..id.."/"..use_count..";"
			end
		end
	end
	return str
end

function ON_MAKE_TEMPEST_CORE_UNSEALING_ITEM_SUCCESS(frame, msg, str, num)	
	reset_current_material_point(frame)
	TEMPEST_CORE_MANAGER_LIBERATION_MATERIAL_DETAIL_VIEW(frame, str, num)
end

-- make effect - liberation option slot
function MAKE_EFFECT_TEMPEST_CORE_LIBERATION_OPTION_SLOT(frame, option_count)
	local timer = GET_CHILD_RECURSIVELY(frame, "timer", "ui::CAddOnTimer")
	if timer ~= nil then
		if option_count <= 0 then
			frame:SetUserValue("LiberationOptionSlot", 0)
			-- stop timer
			timer:Stop()
			-- stop effect
			local gbox = GET_CHILD_RECURSIVELY(frame, "liberation_value_bg")
			if gbox ~= nil then
				local max_option_count = 4
				for i = 1, max_option_count do
					local ctrlset = gbox:GetControlSet("tempest_core_liberation_option_info", "TempestCoreLiberationOption_"..i)
					if ctrlset ~= nil then
						ctrlset:StopUIEffect("tempest_core_liberation_option_effect_"..i, true, 0.0)
						ctrlset:SetUserValue("is_ready_tempest_core_liberation", 0)
					end
				end
			end
		else
			frame:SetUserValue("LiberationOptionSlot", option_count)
			timer:SetUpdateScript("UPDATE_EFFECT_TEMPEST_CORE_LIBERATION_OPTION_SLOT")
			timer:Start(1)
		end
	end
end

-- make effect - liberation option slot update
function UPDATE_EFFECT_TEMPEST_CORE_LIBERATION_OPTION_SLOT(frame, ctrl, num_arg, str_arg, time)
	if frame == nil then
		return
	end

	if frame:IsVisible() == 0 then
		return
	end

	local main_tab = GET_CHILD_RECURSIVELY(frame, "main_tab")
	if main_tab == nil then
		return
	end

	local tab_idx = main_tab:GetSelectItemIndex()
	if tab_idx ~= 1 then
		return
	end

	local max_option_count = 4
	local step_count = 0
	local step_text = GET_CHILD_RECURSIVELY(frame, "liberation_item_liberation_step_text")
	if step_text ~= nil then
		step_count = tonumber(step_text:GetTextByKey("step"))
	end

	if step_count >= max_option_count then
		return
	end

	local option_count = frame:GetUserIValue("LiberationOptionSlot")
	if option_count > 0 then
		local gbox = GET_CHILD_RECURSIVELY(frame, "liberation_value_bg")
		if gbox ~= nil then
			option_count = option_count + step_count
			for i = 1, option_count do
				if i > step_count then
					local ctrlset = gbox:GetControlSet("tempest_core_liberation_option_info", "TempestCoreLiberationOption_"..i)
					if ctrlset ~= nil and ctrlset:IsVisibleRecursively() == true then
						local effect_name = "I_sys_tempest_core_option_slot"
						ctrlset:PlayUIEffect(effect_name, 5.2, "tempest_core_liberation_option_effect_"..i, true);
						ctrlset:SetUserValue("is_ready_tempest_core_liberation", 1)
					end
				end
			end
		end
	else
		for i = 1, max_option_count do
			local ctrlset = gbox:GetControlSet("tempest_core_liberation_option_info", "TempestCoreLiberationOption_"..i)
			if ctrlset ~= nil then
				ctrlset:StopUIEffect("tempest_core_liberation_option_effect_"..i, true, 0.0)
				ctrlset:SetUserValue("is_ready_tempest_core_liberation", 0)
			end
		end
	end
end

-- make effect - liberation option slot result
function MAKE_EFFECT_TEMPEST_CORE_LIBERATION_OPTION_SLOT_RESULT(str)
	local frame = ui.GetFrame("tempest_core_manager")
	if frame ~= nil then
		local timer = GET_CHILD_RECURSIVELY(frame, "timer", "ui::CAddOnTimer")
		local gbox = GET_CHILD_RECURSIVELY(frame, "liberation_value_bg")
		if gbox ~= nil and timer ~= nil then
			timer:Stop()
			local max_option_count = 4
			for i = 1, max_option_count do
				local ctrlset = gbox:GetControlSet("tempest_core_liberation_option_info", "TempestCoreLiberationOption_"..i)
				if ctrlset ~= nil and ctrlset:GetUserIValue("is_ready_tempest_core_liberation") == 1 then
					-- stop effect
					ctrlset:StopUIEffect("tempest_core_liberation_option_effect_"..i, true, 0.0)
					-- play effect
					local effect_name = "UI_tempest_core_option_liberation_"..i
					ctrlset:PlayUIEffect(effect_name, 5.2, "tempest_core_liberation_option_effect_"..i, true);
				end
			end
			timer:SetUpdateScript("UPDATE_EFFECT_TEMPEST_CORE_LIBERATION_OPTION_SLOT_RESULT")
			timer:SetArgString(str)
			timer:SetArgNum(2)
			timer:Start(1)
		end
	end
end

-- make effect - liberation option slot result
function UPDATE_EFFECT_TEMPEST_CORE_LIBERATION_OPTION_SLOT_RESULT(frame, ctrl, str_arg, num_arg, time)
	if frame == nil then
		return
	end

	if frame:IsVisible() == 0 then
		return
	end

	local main_tab = GET_CHILD_RECURSIVELY(frame, "main_tab")
	if main_tab == nil then
		return
	end

	local tab_idx = main_tab:GetSelectItemIndex()
	if tab_idx ~= 1 then
		return
	end

	if time > num_arg then
		ctrl:Stop();
		pc.ReqExecuteTx_Item_String("UNSEALING_TEMPEST_CORE_OPTION", str_arg) -- liberation option
		return
	end

	local gbox = GET_CHILD_RECURSIVELY(frame, "liberation_value_bg")
	if gbox ~= nil then
		local max_option_count = 4
		for i = 1, max_option_count do
			local ctrlset = gbox:GetControlSet("tempest_core_liberation_option_info", "TempestCoreLiberationOption_"..i)
			if ctrlset ~= nil and ctrlset:GetUserIValue("is_ready_tempest_core_liberation") == 1 then
				-- picture setting
				local pic = GET_CHILD_RECURSIVELY(ctrlset, "pic")
				pic:SetImage("")
				-- ready end
				ctrlset:SetUserValue("is_ready_tempest_core_liberation", 0)
			end
		end
	end
end

-- make effect - decomposition ret
function MAKE_EFFECT_TEMPEST_CORE_DECOMPOSITION_RESULT(str)
	local frame = ui.GetFrame("tempest_core_manager")
	if frame ~= nil then
		local effect_name = "UI_item_parts"
		local effect_scale = 5.0
		local effect_duration = 1.0
		local pic = GET_CHILD_RECURSIVELY(frame, "decomposition_exec_pic")
		if pic ~= nil then
			pic:PlayUIEffect(effect_name, effect_scale, "tempest_core_decomposition_effect")
			pic:SetUserValue("tempset_core_decomposition_str", str)
			ui.SetHoldUI(true)
			ReserveScript("SCP_RESERVE_TEMPEST_CORE_DECOMPOSITION_RESULT()", effect_duration)
		end
	end

end

-- make effect - decomposition ret reserve script
function SCP_RESERVE_TEMPEST_CORE_DECOMPOSITION_RESULT()
	local frame = ui.GetFrame("tempest_core_manager")
	if frame ~= nil then
		local pic = GET_CHILD_RECURSIVELY(frame, "decomposition_exec_pic")
		if pic ~= nil then
			pic:StopUIEffect("tempest_core_decomposition_effect", true, 0.5)
			local str = pic:GetUserValue("tempset_core_decomposition_str")
			pc.ReqExecuteTx_Item("DECOMPOSE_TEMPEST_CORE", str)
		end
		ui.SetHoldUI(false)
	end
end

-- rbtn - inventroy rbtn
function TEMPEST_CORE_INV_RBTN(item_obj, slot, guid)
	if item_obj == nil or guid == nil then
		return
	end

	local inv_item = session.GetInvItemByGuid(guid)
	if inv_item == nil then
		return
	end

	local item_cls_name = TryGetProp(item_obj, "ClassName", "None")
	if item_tempest_core.is_tempest_core_item(item_cls_name) == false then
		ui.SysMsg(ScpArgMsg("TempestCoreMgrLiberation_NoReg"))
		return
	end

	local frame = ui.GetFrame("tempest_core_manager")
	if frame ~= nil then
		local tab = GET_CHILD_RECURSIVELY(frame, "main_tab")
		if tab ~= nil then
			local index = tab:GetSelectItemIndex()
			if index == 1 then
				TEMPEST_CORE_MANAGER_LIBERATION_ITEM_RBTN()
				local slot = GET_CHILD_RECURSIVELY(frame, "liberation_item_slot")
				if slot ~= nil then
					TEMPEST_CORE_MANAGER_LIBERATION_ITEM_REG(frame, slot, inv_item)
				end
			elseif index == 2 then
				TEMPEST_CORE_MANAGER_DECOMPOSITION_ITEM_RBTN()
				local slot = GET_CHILD_RECURSIVELY(frame, "decomposition_exec_slot")
				if slot ~= nil then
					TEMPEST_CORE_MANAGER_DECOMPOSITION_ITEM_REG(frame, slot, inv_item)
				end
			end
		end
	end
end