--@fragmentation
--@desc : This script is a UI that controls all items subject to fragmentation.
--@fragmentation target : Earring / Belt / ...

local BELT_TYPE = 11100043;
local MAX_CHECKBOX_CNT_EAR = 4;
local MAX_CHECKBOX_CNT_BELT = 3;
local MAX_CHECKBOX_CNT_ICOR = 2;
local MAX_CHECKBOX_CNT_SHOULDER = 2;
local MAX_BASE_JOB_CNT = 5;
local MAX_SEARCH_CNT = 4;
local icor_list = {}
table.insert(icor_list, '11201007')
table.insert(icor_list, '11201008')
local shoulder_list ={}
table.insert(shoulder_list, '11100047')
table.insert(shoulder_list, '11100048')


function FRAGMENTATION_ON_INIT(addon,frame)
	addon:RegisterMsg('FRAGMENTATION_END', 'ON_FRAGMENTATION_END');
	addon:RegisterMsg('FRAGMENTATION_BUNDLE_ITEMS_FAILED', 'ON_FRAGMENTATION_BUNDLE_ITEMS_FAILED');
end

function FRAGMENTATION_OPEN(frame)
	ui.OpenFrame("fragmentation")
	SetCraftState(1);
	ui.EnableSlotMultiSelect(1)
    inventory = ui.GetFrame("inventory")
    if inventory:IsVisible()==0 then ui.OpenFrame("inventory") end
	FRAGMENTATION_REFRESH_ALL(frame)
end 

function FRAGMENTATION_CLOSE(frame)
	frame:ShowWindow(0)
	SetCraftState(0);
	ui.EnableSlotMultiSelect(0)
	INVENTORY_SET_CUSTOM_RBTNDOWN('None')
    inventory  = ui.GetFrame("inventory")
    if inventory:IsVisible()==1 then ui.CloseFrame("inventory") end
end

function FRAGMENTATION_INIT_FILTER(ctrl)
	local frame = ui.GetFrame("fragmentation")
	if frame==nil then return end
	local tabindex = ctrl:GetSelectItemIndex();
	if tabindex==0 then 
		for i=1,MAX_CHECKBOX_CNT_EAR do 
			local checkbox = GET_CHILD_RECURSIVELY(frame,"earring_grade_"..tostring(i))
			if checkbox:IsChecked()== 1 then checkbox:SetCheck(0) end
		end
	elseif  tabindex==1 then
		for i=1,MAX_CHECKBOX_CNT_BELT do 
			local checkbox = GET_CHILD_RECURSIVELY(frame,"belt_grade_"..tostring(i))
			if checkbox:IsChecked()== 1 then checkbox:SetCheck(0) end
		end
	elseif  tabindex==2 then
		DROPBOX_FRAGMENTATION_SELECT_JOB(0,"None")
		DROPBOX_FRAGMENTATION_SELECT_OPTION(0,"None")
	elseif tabindex == 3 then
		for i = 1, MAX_CHECKBOX_CNT_ICOR do
			local check_box = GET_CHILD_RECURSIVELY(frame, "icor_grade_"..i);
			if check_box ~= nil and check_box:IsChecked() == 1 then check_box:SetCheck(0); end
		end
	end
end

function CHECKBOX_FRAGMENTATION(parent,self)
	local frame = parent:GetTopParentFrame();
	FRAGMENTATION_REFRESH_ALL(frame)
end

function FRAGMENTATION_TAB_CHANGE(parent, self)
	FRAGMENTATION_INIT_FILTER(self)
	local topParent = parent:GetTopParentFrame();
	FRAGMENTATION_REFRESH_ALL(topParent)
end

function FRAGMENTATION_CLEAR_ALL_SLOTS(frame)
	local slotSet = GET_CHILD_RECURSIVELY(frame,"fragmentation_slotset","ui::CSlotSet")
	if slotSet==nil then return end
	slotSet:ClearIconAll()
	local slot_cnt =slotSet:GetSlotCount();
	for i=0, slot_cnt-1 do
		local slot = slotSet:GetSlotByIndex(i)
		slot:SetUserValue("FRAGMENTATION_GUID","None")
		SET_SLOT_STAR_TEXT(slot,nil) 
	end
	return slotSet
end

function FRAGMENTATION_SELECT_ALL(parent,ctrl)
	local frame = parent:GetTopParentFrame()
	local user_config =frame:GetUserConfig("CHECK_IS_SELECT_ALL_BEFORE") 

	local slotset = GET_CHILD_RECURSIVELY(frame,"fragmentation_slotset")
	local slot_cnt =slotset:GetSlotCount();
	if user_config =="TRUE" then
		frame:SetUserConfig("CHECK_IS_SELECT_ALL_BEFORE","FALSE") 
		for i=0, slot_cnt-1 do
			local slot = slotset:GetSlotByIndex(i)
			local userVal = slot:GetUserValue("FRAGMENTATION_GUID")
			if userVal ~="None" then
				slot:Select(0)
				
			end
		end
	else
		frame:SetUserConfig("CHECK_IS_SELECT_ALL_BEFORE","TRUE") 
		for i=0, slot_cnt-1 do
			local slot = slotset:GetSlotByIndex(i)
			local userVal = slot:GetUserValue("FRAGMENTATION_GUID")
			if userVal ~="None" then
				slot:Select(1)
				
			end
		end
	end
end

function FRAGMENTATION_REFRESH_ALL(frame)
	frame:SetUserConfig("CHECK_IS_SELECT_ALL_BEFORE","FALSE")
	
	local tab = GET_CHILD_RECURSIVELY(frame,"item_tab")
	local tab_index = tab:GetSelectItemIndex();
	GET_CHILD_RECURSIVELY(frame, "filter_group_earring"):ShowWindow(0)
	GET_CHILD_RECURSIVELY(frame, "filter_group_belt"):ShowWindow(0)
	GET_CHILD_RECURSIVELY(frame, "filter_group_skillgem"):ShowWindow(0)
	GET_CHILD_RECURSIVELY(frame, "filter_group_icor"):ShowWindow(0);
	GET_CHILD_RECURSIVELY(frame, "filter_group_shoulder"):ShowWindow(0);
	
	local argList = FRAGMENTATION_SET_FILTER_SECTION(frame,tab_index)
	FRAGMENTATION_SHOW_TARGETS_FROM_INV(frame,tab_index,argList)
end

function FRAGMENTATION_SET_FILTER_SECTION(frame,tabindex)
	local argList = {}
	if tabindex==0 then
		GET_CHILD_RECURSIVELY(frame,"filter_group_earring"):ShowWindow(1)
		GET_CHILD_RECURSIVELY(frame,"filter_title_text"):SetTextByKey("value1",ClMsg("Earring"));
		for i=1,MAX_CHECKBOX_CNT_EAR do 
			local checkbox = GET_CHILD_RECURSIVELY(frame,"earring_grade_"..tostring(i))
			if checkbox:IsChecked()== 1 then
				table.insert(argList,i)
			end
		end
	elseif tabindex==1 then
		GET_CHILD_RECURSIVELY(frame,"filter_group_belt"):ShowWindow(1)
		GET_CHILD_RECURSIVELY(frame,"filter_title_text"):SetTextByKey("value1",ClMsg("Belt"));
		for i=1,MAX_CHECKBOX_CNT_BELT do 
			local checkbox = GET_CHILD_RECURSIVELY(frame,"belt_grade_"..tostring(i))
			if checkbox:IsChecked()== 1 then
				local ies 	 = GetClassByType("Item",tostring(BELT_TYPE+i))
				local numArg = TryGetProp(ies,"NumberArg1",0) 
				table.insert(argList,numArg)
			end
		end
	elseif tabindex==2 then
		GET_CHILD_RECURSIVELY(frame,"filter_group_skillgem"):ShowWindow(1)
		GET_CHILD_RECURSIVELY(frame,"filter_title_text"):SetTextByKey("value1",ClMsg("GemSkill"));
		local user_val_1 = GET_CHILD_RECURSIVELY(frame,"skillgem_filter_1"):GetUserValue("FILTER_KEY")
		if user_val_1 ~= "None" then  table.insert(argList,user_val_1) end
		local user_val_2 = GET_CHILD_RECURSIVELY(frame,"skillgem_filter_2"):GetUserValue("FILTER_KEY")
		if user_val_2 ~= "None" then  table.insert(argList,user_val_2) end
	elseif tabindex == 3 then
		GET_CHILD_RECURSIVELY(frame, "filter_group_icor"):ShowWindow(1);
		GET_CHILD_RECURSIVELY(frame,"filter_title_text"):SetTextByKey("value1",ClMsg("Icor"));
		for i = 1, MAX_CHECKBOX_CNT_ICOR do
			local check_box = GET_CHILD_RECURSIVELY(frame, "icor_grade_"..i);
			if check_box ~= nil and check_box:IsChecked() == 1 then
				local icor = icor_list[i];
				local ies = GetClassByType("Item", tostring(icor))
				local numArg = TryGetProp(ies, "NumberArg1", 0)  
				table.insert(argList, numArg);

			end
		end
	elseif tabindex == 4 then
		GET_CHILD_RECURSIVELY(frame, "filter_group_shoulder"):ShowWindow(1);
		GET_CHILD_RECURSIVELY(frame,"filter_title_text"):SetTextByKey("value1",ClMsg("Shoulder"));
		for i = 1, MAX_CHECKBOX_CNT_SHOULDER do
			local check_box = GET_CHILD_RECURSIVELY(frame, "shoulder_grade_"..i);
			if check_box ~= nil and check_box:IsChecked() == 1 then
				local shoulder = shoulder_list[i]
				local ies = GetClassByType("Item",tostring(shoulder))
				local numArg = TryGetProp(ies, "NumberArg1", 0)  
				table.insert(argList, numArg);
			end
		end
	end
	return argList
end

function FRAGMENTATION_SHOW_TARGETS_FROM_INV(frame,tabindex,argList)
	local target=""
	if tabindex==0 then
		target = "Earring"
	elseif tabindex==1 then
		target = "BELT"
	elseif tabindex==2 then
		target = "Gem"
	elseif tabindex == 3 then
		target = "Icor";
	elseif tabindex == 4 then
		target = "SHOULDER"
	end

	local slotSet = FRAGMENTATION_CLEAR_ALL_SLOTS(frame)
	if slotSet==nil then return end
	slotSet:ClearIconAll()
	local list_size = #argList
	if list_size > 0 then 
		FRAGMENTATION_SHOW_TARGETS_APPLY_FILTER(slotSet, target, argList)
	else
		FRAGMENTATION_SHOW_TARGETS_NO_APPLY_FILTER(slotSet,target)
	end
end

function FRAGMENTATION_SHOW_TARGETS_APPLY_FILTER(slotSet, target, argList)
	local number_of_slot_placed = 0
	local slot_capacity = slotSet:GetSlotCount()
	local invItemList 	= session.GetInvItemList()
	FOR_EACH_INVENTORY(invItemList, function(invItemList,invItem,slotSet)
		if number_of_slot_placed >= slot_capacity then return end
		--arg func start
		local obj = GetIES(invItem:GetObject())
		local group_name = TryGetProp(obj, 'GroupName', 'None')
		local stringArg = TryGetProp(obj, 'StringArg', 'None')
		local item_guid = invItem:GetIESID()
	
		if true == invItem.isLockState then
			return;
		end

		if shared_item_earring.is_able_to_fragmetation(obj) == false then
			return;
		end
		
		if group_name == target and stringArg~="None" then
			if target =="Earring" then
				local arg = shared_item_earring.get_fragmentation_count(obj)
				for i=1,#argList do 
					local slotindex = imcSlot:GetEmptySlotIndex(slotSet)
					local slot = slotSet:GetSlotByIndex(slotindex)
					if arg == argList[i] and tonumber(argList[i])~=4 then 
						slot:SetUserValue('FRAGMENTATION_GUID', invItem:GetIESID())
						SET_SLOT_ITEM(slot,invItem)					
						slot:SetMaxSelectCount(1)
						number_of_slot_placed = number_of_slot_placed + 1
					elseif tonumber(argList[i])==4 and tonumber(arg) >= 4 then
						slot:SetUserValue('FRAGMENTATION_GUID', invItem:GetIESID())
						SET_SLOT_ITEM(slot,invItem)			
						slot:SetMaxSelectCount(1)
						number_of_slot_placed = number_of_slot_placed + 1
					end
				end
			elseif target == "BELT" then
				for i=1,#argList do 
					local slotindex = imcSlot:GetEmptySlotIndex(slotSet)
					local slot = slotSet:GetSlotByIndex(slotindex)
					local arg = TryGetProp(obj,"NumberArg1",0)
					if arg == argList[i] then 
						slot:SetUserValue('FRAGMENTATION_GUID', invItem:GetIESID())
						SET_SLOT_ITEM(slot,invItem)
						slot:SetMaxSelectCount(1)
						number_of_slot_placed = number_of_slot_placed + 1
					end
				end
			elseif target =="Gem" then
				local isHit_filterTarget =false; 
				for i=1,#argList do
					isHit_filterTarget = FRAGMENTATION_IS_HIT_FILTER_TARGET(obj,argList[i])
					if isHit_filterTarget==false then return end
				end
				if isHit_filterTarget==true then
					local slotindex = imcSlot:GetEmptySlotIndex(slotSet)
					local slot 		= slotSet:GetSlotByIndex(slotindex)	
					slot:SetUserValue('FRAGMENTATION_GUID', invItem:GetIESID())
					SET_SLOT_ITEM(slot,invItem)
					SET_SLOT_STAR_TEXT(slot,obj) 
					slot:SetMaxSelectCount(1)	
					number_of_slot_placed = number_of_slot_placed+1
				end
			elseif target == "Icor" then 
				if shared_item_earring.is_able_to_fragmetation(obj) then
					local arg = shared_item_earring.get_fragmentation_count(obj)
					for i=1,#argList do 
						local slotindex = imcSlot:GetEmptySlotIndex(slotSet)
						local slot = slotSet:GetSlotByIndex(slotindex)
						if arg == argList[i] and tonumber(argList[i]) == 1 then 
							slot:SetUserValue('FRAGMENTATION_GUID', invItem:GetIESID())
							SET_SLOT_ITEM(slot,invItem)
							slot:SetMaxSelectCount(1)
							number_of_slot_placed = number_of_slot_placed + 1
						elseif arg == argList[i] and tonumber(argList[i]) == 20 then
							slot:SetUserValue('FRAGMENTATION_GUID', invItem:GetIESID())
							SET_SLOT_ITEM(slot,invItem)
							slot:SetMaxSelectCount(1)
							number_of_slot_placed = number_of_slot_placed + 1
						end
					end
				end
			elseif target == "SHOULDER" then
				if shared_item_earring.is_able_to_fragmetation(obj) then
					local arg = shared_item_earring.get_fragmentation_count(obj)
					for i=1,#argList do 
						local slotindex = imcSlot:GetEmptySlotIndex(slotSet)
						local slot = slotSet:GetSlotByIndex(slotindex)
						if arg == argList[i] then 
							slot:SetUserValue('FRAGMENTATION_GUID', invItem:GetIESID())
							SET_SLOT_ITEM(slot,invItem)
							slot:SetMaxSelectCount(1)
							number_of_slot_placed = number_of_slot_placed + 1
						end
					end		
				end
			end	
		end
	end,false,slotSet,materialItemList)
end

function FRAGMENTATION_IS_HIT_FILTER_TARGET(obj,keyword)
	local frame = ui.GetFrame('fragmentation');
	local arg1 = GET_CHILD_RECURSIVELY(frame,"skillgem_filter_1"):GetUserValue('FILTER_KEY')
	local arg2 = GET_CHILD_RECURSIVELY(frame,"skillgem_filter_2"):GetUserValue('FILTER_KEY')
	
	if keyword==arg1 then
		local gemName = TryGetProp(obj,"ClassName","None")
		local cabinet_cls = GetClassByStrProp("cabinet_skillgem", "ClassName", gemName)
		local ctrltype = TryGetProp(cabinet_cls,"CtrlType","None") 
		if ctrltype==keyword and IS_RANDOM_OPTION_SKILL_GEM(obj)==true then return true end
	elseif keyword==arg2 then
		for i=1,MAX_SEARCH_CNT do
			if keyword==TryGetProp(obj,"RandomOption_"..i,"None") then return true end
		end
	end
	return false 
end

function FRAGMENTATION_SHOW_TARGETS_NO_APPLY_FILTER(slotSet, target)
	local number_of_slot_placed = 0
	local slot_capacity = slotSet:GetSlotCount()
	local invItemList = session.GetInvItemList()

	FOR_EACH_INVENTORY(invItemList, function(invItemList,invItem,slotSet)
		if number_of_slot_placed >= slot_capacity then return end
			
		--arg func start
		local obj = GetIES(invItem:GetObject())
		local group_name = TryGetProp(obj, 'GroupName', 'None')
		local stringArg = TryGetProp(obj, 'StringArg', 'None')
		local item_guid = invItem:GetIESID()
		if true == invItem.isLockState then
			return;
		end

		if shared_item_earring.is_able_to_fragmetation(obj) == false then
			return;
		end

		if group_name=="SHOULDER" and TryGetProp(obj,"NumberArg1",0)==200 then
			return
		end
		if group_name == target and stringArg~="None" then
			local slotindex = imcSlot:GetEmptySlotIndex(slotSet)
			local slot = slotSet:GetSlotByIndex(slotindex)
			slot:SetUserValue('FRAGMENTATION_GUID', invItem:GetIESID())
			SET_SLOT_ITEM(slot,invItem)
			if stringArg=="SkillGem" then 	
				SET_SLOT_STAR_TEXT(slot,obj) 
			end
			slot:SetMaxSelectCount(1)
			
			number_of_slot_placed = number_of_slot_placed+1
		end
	end,false,slotSet,materialItemList)
end

function BTN_FRAGMENTATION_FILTER_JOB(parent,self)
	local topframe = parent:GetTopParentFrame()
	local names   = {};
	local keyType = {};
	
	for i=1, MAX_BASE_JOB_CNT do
		local cls = GetClassByStrProp("Job","ClassName","Char"..tostring(i).."_1")
		table.insert(names,dic.getTranslatedStr(TryGetProp(cls,"Name","None")))
		table.insert(keyType,TryGetProp(cls,"CtrlType","None"))
	end
	local droplistframe = ui.MakeDropListFrame(self,0,0,self:GetWidth(),MAX_BASE_JOB_CNT*self:GetHeight(),MAX_BASE_JOB_CNT+1,ui.CENTER_HORZ,
	"DROPBOX_FRAGMENTATION_SELECT_JOB",nil,nil)
	ui.AddDropListItem(ClMsg("TotalTabName"),nil,"None")
	for i=1, MAX_BASE_JOB_CNT do
		ui.AddDropListItem(names[i],nil,keyType[i])
	end
end

function DROPBOX_FRAGMENTATION_SELECT_JOB(index,keyword)
	local frame = ui.GetFrame("fragmentation")
	if frame==nil then return end
	local filter_btn = GET_CHILD_RECURSIVELY(frame,"skillgem_filter_1")
	if filter_btn==nil then return end
	
	local name;
	if keyword=="None" then
		name = ClMsg("USEJOB_END")
	else
		local cls =GetClassByStrProp("Job","EngName",keyword)
		if cls==nil then return end
		name = dic.getTranslatedStr(TryGetProp(cls,"Name","None"))
	end
	filter_btn:SetTextByKey("value",name)

	GET_CHILD_RECURSIVELY(frame,"skillgem_filter_1"):SetUserValue("FILTER_KEY",keyword)
	FRAGMENTATION_REFRESH_ALL(frame)
end

function BTN_FRAGMENTATION_FILTER_OPTION(parent,self)
	local topframe = parent:GetTopParentFrame()
	local argList = shared_skill_gem_random_option.get_option_list()
	local argnum = #argList
	if argList==nil then return end
	local nameList = {}
	for i=1, #argList do
		table.insert(nameList,ClMsg(argList[i]))
	end
	local droplistframe = ui.MakeDropListFrame(self,0,0,self:GetWidth(),argnum*self:GetHeight(),6,ui.LEFT,
	"DROPBOX_FRAGMENTATION_SELECT_OPTION",nil,nil)
	ui.AddDropListItem(ClMsg("TotalTabName"),nil,"None")
	for i=1, argnum do
		ui.AddDropListItem(nameList[i],nil,argList[i])
	end
end

function DROPBOX_FRAGMENTATION_SELECT_OPTION(index,keyword)
	local frame = ui.GetFrame("fragmentation")
	if frame==nil then return end
	local filter_btn = GET_CHILD_RECURSIVELY(frame,"skillgem_filter_2")
	if filter_btn==nil then return end
	
	local name = ClMsg("RandomOption");
	if keyword =="None" then
		filter_btn:SetTextByKey("value",name)
	else
		name = dic.getTranslatedStr(keyword)
		filter_btn:SetTextByKey("value",ClMsg(name))
	end
	
	GET_CHILD_RECURSIVELY(frame,"skillgem_filter_2"):SetUserValue("FILTER_KEY",keyword)
	FRAGMENTATION_REFRESH_ALL(frame)
end

function FRAGMENTATION_EXECUTE(parent,ctrl)
	local frame = parent:GetTopParentFrame();
	local tab   = GET_CHILD_RECURSIVELY(frame,"item_tab")
	local tab_index = tab:GetSelectItemIndex();
	local slotSet = GET_CHILD_RECURSIVELY(frame,"fragmentation_slotset","ui::CSlotSet")
	local slotCnt = slotSet:GetSlotCount();
	if slotCnt > shared_item_earring.MAX_SLOT_CNT then return end

	session.ResetItemList()

	local check_ductility = false;
	for i=0, shared_item_earring.MAX_SLOT_CNT-1 do
		local slot = slotSet:GetSlotByIndex(i)
		if slot:IsSelected()==1 then
			local icon = slot:GetIcon();
			local iconInfo = icon:GetInfo()
			local iesId = iconInfo:GetIESID()
			if icon == nil or iconInfo == nil then
				ui.SysMsg(ClMsg('NotExistTargetItem'));
				return;
			end
			local guid = slot:GetUserValue("FRAGMENTATION_GUID")
			
			local targetinvitem = session.GetInvItemByGuid(guid)
			local targetitemobj = GetIES(targetinvitem:GetObject());
			local ductilityCnt = TryGetProp(targetitemobj,"Ductility_Count",0)
			local rerollCnt = TryGetProp(targetitemobj,"RerollCount",0)
			local gem_name = dic.getTranslatedStr(TryGetProp(gem_obj, 'Name', 'None'))


		
			if ductilityCnt>0 or rerollCnt>0 then check_ductility=true end
			if guid  =="None" then return end
			if iesId =="None" then return end
			if guid==iesId and targetinvitem.isLockState == false then 
				session.AddItemID(iesId, 1)
			end	
		end
	end
	if check_ductility ==true then
		local yesScp = string.format('_FRAGMENTATION_EXECUTE(%d)', tab_index);
		local msg = ScpArgMsg('ReallyDoFragmentationItem')
		local msgbox = ui.MsgBox(msg, yesScp, 'None')
		SET_MODAL_MSGBOX(msgbox)
	else
		_FRAGMENTATION_EXECUTE(tab_index)
	end

end

function _FRAGMENTATION_EXECUTE(tab_index)
	local argStrList = NewStringList();
	if tab_index == 0 then
		argStrList:Add("Earring")
	elseif tab_index==1 then
		argStrList:Add("BELT")
	elseif tab_index==2 then
		argStrList:Add("Gem")
	elseif tab_index == 3 then
		argStrList:Add("Icor");
	elseif tab_index == 4 then
		argStrList:Add("SHOULDER")
	end
	local selected_list = session.GetItemIDList()
	item.DialogTransaction("FRAGMENTATION_BUNDLE_ITEMS", selected_list, '', argStrList);
end

function ON_FRAGMENTATION_END(frame)
	FRAGMENTATION_REFRESH_ALL(frame)
end

function ON_FRAGMENTATION_BUNDLE_ITEMS_FAILED(frame)
	FRAGMENTATION_REFRESH_ALL(frame)
end

