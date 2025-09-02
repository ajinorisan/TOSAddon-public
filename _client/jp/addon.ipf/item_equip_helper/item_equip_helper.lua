local _spot_list_without_sub = {
	{"RH",{"RH"}},
	{"LH",{"LH","TRINKET"}},
	{"Shirt",{"SHIRT"}},
	{"Pants",{"PANTS"}},
	{"GLOVES",{"GLOVES"}},
	{"BOOTS",{"BOOTS"}},
	{"NECK",{"NECK"}},
	{"Ring1",{"RING1"}},
	{"Ring2",{"RING2"}},
	{"Seal",{"SEAL"}},
	{"Ark",{"ARK"}},
	{"Earring",{"EARRING"}},
	{"BELT",{"BELT"}},
	{"SHOULDER",{"SHOULDER"}},
	{"CORE",{"CORE"}},
}
local _spot_list_with_sub = {
	{"RH",{"RH"}},
	{"LH",{"LH","TRINKET"}},
	{"RH_SUB",{"RH_SUB"}},
	{"LH_SUB",{"LH_SUB"}},
	{"Shirt",{"SHIRT"}},
	{"Pants",{"PANTS"}},
	{"GLOVES",{"GLOVES"}},
	{"BOOTS",{"BOOTS"}},
	{"NECK",{"NECK"}},
	{"Ring1",{"RING1"}},
	{"Ring2",{"RING2"}},
	{"Seal",{"SEAL"}},
	{"Ark",{"ARK"}},
	{"Earring",{"EARRING"}},
	{"BELT",{"BELT"}},
	{"SHOULDER",{"SHOULDER"}},
	{"CORE",{"CORE"}},
}

function ITEM_EQUIP_HELPER_ON_INIT(addon, frame)
end
function ITEM_EQUIP_HELPER_OPEN()
	local frame = ui.GetFrame('item_equip_helper')
	if frame:IsVisible() == 1 then
		frame:ShowWindow(0)
	else
		frame:ShowWindow(1)
		INIT_ITEM_EQUIP_HELPER(frame)
	end
end

function INIT_ITEM_EQUIP_HELPER(frame)
	local pc = GetMyPCObject()
	local bg = GET_CHILD_RECURSIVELY(frame,"bg")
	bg:RemoveAllChild()
	local spot_count = item.GetEquipSpotCount() - 1;
	local no_show_item_list = {"NoWeapon","NoOuter","NoShirt"}
	local spot_list = _spot_list_without_sub
	if tonumber(USE_SUBWEAPON_SLOT) == 1 then
		spot_list = _spot_list_with_sub
	end
	for i = 1,#spot_list do
		local key = spot_list[i][1]
		local spots = spot_list[i][2]
		local helper_ctrl = bg:CreateOrGetControlSet('item_equip_helper_ctrl', 'ITEM_HELPER_'..key, 0, 0);
		AUTO_CAST(helper_ctrl)
		local equip_spot = GET_CHILD_RECURSIVELY(helper_ctrl,"equip_spot")
		equip_spot:SetTextByKey("spot",ClMsg(key))		
		local equip_weapon = nil
		local equip_spot = 'None'
		for i = 1,#spots do
			local tmp = GetEquipItem(pc,spots[i])
			if IS_NO_EQUIPITEM(tmp) == 0 then
				equip_weapon = tmp
				equip_spot = spots[i]				
				break
			end
		end
		SET_ITEM_EQUIP_HELPER_CTRL(helper_ctrl,equip_weapon, equip_spot)
	end
	ITEM_EQUIP_HELPER_RESIZE(frame)
end

function SET_ITEM_EQUIP_HELPER_CTRL(ctrl,item, equip_spot)
	local item_name = GET_CHILD_RECURSIVELY(ctrl,"item_name")
	if item ~= nil then
		local grade_font = ctrl:GetUserConfig("FONT_GRADE_"..item.ItemGrade)
		local item_text = string.format("%s%s",grade_font,item.Name)		
		item_name:SetTextByKey("name", item_text)
	else
		local grade_font = ctrl:GetUserConfig("FONT_NOT_EQUIP")
		local item_text = string.format("%s%s",grade_font,ClMsg("None"))
		item_name:SetTextByKey("name",item_text)
	end

	local warning_text = GET_ITEM_EQUIP_HELPER_WARNING_TEXT(item, equip_spot)
	local pic = GET_CHILD_RECURSIVELY(ctrl,"waring_pic")
	if warning_text == "" then
		pic:ShowWindow(0)
	else
		pic:SetTextTooltip("{s20}"..warning_text)
	end
end

dic_awaken_slot = { 'RH', 'LH', 'TRINKET', 'SHIRT', 'PANTS', 'GLOVES', 'BOOTS', 'NECK', 'RING1', 'RING2' }
dic_set_slot = {'RH', 'LH', 'TRINKET', 'SHIRT', 'PANTS', 'GLOVES', 'BOOTS'}
local function is_awaken_spot(spot)
	for k, v in pairs(dic_awaken_slot) do
		if v == spot then
			return true
		end
	end
	return false
end

local function is_set_option_spot(spot)
	for k, v in pairs(dic_set_slot) do
		if v == spot then
			return true
		end
	end
	return false
end


function GET_ITEM_EQUIP_HELPER_WARNING_TEXT(item, spot)
	if item == nil then
		return ClMsg("TP_EquipItem")
	end
	
	local item_cls = GetClass("Item", item.ClassName)
	local equip_item = session.GetEquipItemByType(item.ClassID)
	local tooltip = ""
	local function concat_string(key)
		tooltip = tooltip .. ClMsg(key) .. "{nl}"
	end

	if TryGetProp(item, 'ItemGrade', 0) < 5 then -- 레전드 이하는 체크하지 않음
		return tooltip
	end

	local awaken_flag = 0;	
	if IS_ENABLE_GIVE_HIDDEN_PROP_ITEM(item) == false then
		awaken_flag = 1;
	end
	
	local enchant_flag = 0
	if IS_ENABLE_APPLY_JEWELL_TOOLTIPTEXT(item) == false then
	    enchant_flag = 1
	end

	--초월
	if IS_TRANSCEND_ABLE_ITEM(item) == 1 and TryGetProp(item, "Transcend") == 0 then
		concat_string("Transcend")
	end
	--강화	
	if REINFORCE_ABLE_131014(item) == 1 and TryGetProp(item, "Reinforce_2") == 0 then
		concat_string("Reinforce_2")
	end
	-- 가디스 강화 체크
	if TryGetProp(item, 'Reinforce_Type', 'None') == 'goddess' and TryGetProp(item, "Reinforce_2") == 0 then
		concat_string("Reinforce_2")
	end

	--인챈트
	if enchant_flag ~= 1 and IS_ENABLE_APPLY_JEWELL_TOOLTIPTEXT(item) ~= false and TryGetProp(item,"RandomOptionRare") == 'None' then
		concat_string("Jewel")
	end
	
	local icor_random_flag = 0
	local icor_fix_flag = 0
	
	if TryGetProp(item, 'LegendGroup', 'None') ~= 'None' then
		--랜덤 아이커
		if TryGetProp(item,"RandomOption_1","None") == "None" then
			concat_string("Random_Icor")
		end
		--고정 아이커
		if TryGetProp(item,"InheritanceItemName","None") == "None" then
			concat_string("FixedIcor")
		end
	end

	if is_set_option_spot(spot) == true then
		if TryGetProp(item, 'LegendPrefix', 'None') == 'None' and ENABLE_EQUIP_SETOPTION(item) == true then
			concat_string("Set_option")
		end
	end

	--젬 장착
	local socket_cnt = TryGetProp(item,"MaxSocket",0)
	if socket_cnt > 0 and equip_item:GetEquipGemID(0) == 0 then
		concat_string("Gem")
	end

	if awaken_flag ~= 1 and is_awaken_spot(spot) == true then
		if TryGetProp(item, 'IsAwaken', 0) == 0 then
			concat_string('ItemDecomposeWarningProp_Awaken')
		end
	end
	
	return tooltip
end

function ITEM_EQUIP_HELPER_RESIZE(frame)
	local bg = GET_CHILD_RECURSIVELY(frame,"bg")
	GBOX_AUTO_ALIGN(bg, 0, 0, 0, false, true);
	local child_count = bg:GetChildCount()
	local width_diff = 0
	local function ResizeWidth(ctrl,x)
		ctrl:Resize(ctrl:GetOriginalWidth()+x,ctrl:GetHeight()) 
	end
	for i = 0,child_count-1 do
		local helper_ctrl = bg:GetChildByIndex(i);
		if string.find(helper_ctrl:GetName(),"ITEM_HELPER_") ~= nil then
			local item_name = GET_CHILD_RECURSIVELY(helper_ctrl,"item_name")
			width_diff = math.max(width_diff,item_name:GetWidth() - 200)
		end
	end
	
	for i = 0,child_count-1 do
		local helper_ctrl = bg:GetChildByIndex(i);
		if string.find(helper_ctrl:GetName(),"ITEM_HELPER_") ~= nil then
			ResizeWidth(helper_ctrl,width_diff)
			local helper_ctrl_bg = GET_CHILD(helper_ctrl,"equip_helper_bg")
			ResizeWidth(helper_ctrl_bg,width_diff)
		end
	end
	ResizeWidth(bg,width_diff)
	local default_height_diff = frame:GetOriginalHeight() - bg:GetOriginalHeight()
	frame:Resize(frame:GetOriginalWidth()+width_diff,bg:GetHeight()+default_height_diff)
end