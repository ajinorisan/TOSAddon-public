-- item_cabinet.lua 
g_selectedItem = {}
g_materialItem = {}

function ITEM_CABINET_ON_INIT(addon, frame)
	addon:RegisterMsg('UPDATE_ITEM_CABINET_LIST', 'ITEM_CABINET_CREATE_LIST');
	addon:RegisterMsg('ITEM_CABINET_SUCCESS_ENCHANT', 'ITEM_CABINET_SUCCESS_GODDESS_ENCHANT');
	addon:RegisterMsg('ON_UI_TUTORIAL_NEXT_STEP', 'ITEM_CABINET_UI_TUTORIAL_CHECK')
	addon:RegisterMsg('MSG_END_CABINET_RELIC_GEM_REINFORCE', 'END_CABINET_RELIC_GEM_REINFORCE')
	addon:RegisterMsg('START_OPEN_ALL_CABINET', 'START_OPEN_ALL_CABINET')	
	addon:RegisterMsg('END_OPEN_ALL_CABINET', 'END_OPEN_ALL_CABINET')	
end

function ITEM_CABINET_OPEN(frame)
	if TUTORIAL_CLEAR_CHECK(GetMyPCObject()) == false then
		ui.SysMsg(ClMsg('CanUseAfterTutorialClear'))
		frame:ShowWindow(0)
		return
	end

	ui.CloseFrame('goddess_equip_manager')
	
	for i = 1, #revertrandomitemlist do
		local revert_name = revertrandomitemlist[i]
		local revert_frame = ui.GetFrame(revert_name)
		if revert_frame ~= nil and revert_frame:IsVisible() == 1 then
			ui.CloseFrame(revert_name)
		end
	end

	GET_CHILD_RECURSIVELY(frame, "cabinet_tab"):SelectTab(0);
	GET_CHILD_RECURSIVELY(frame, "upgrade_tab"):SelectTab(0);
	GET_CHILD_RECURSIVELY(frame, "equipment_tab"):SelectTab(0);
	GET_CHILD_RECURSIVELY(frame, "job_tab"):SelectTab(0);
	GET_CHILD_RECURSIVELY(frame, "relic_tab"):SelectTab(0);
	GET_CHILD_RECURSIVELY(frame, "upgrade_relicgem_tab"):SelectTab(0);	
	local edit = GET_CHILD_RECURSIVELY(frame,"ItemSearch")
	edit:SetEventScript(ui.LBUTTONUP,"EDIT_CLEAR_TEXT");

	ITEM_CABINET_CREATE_LIST(frame);
	help.RequestAddHelp('TUTO_SHARD_CABINET_1')
end


function ITEM_CABINET_CLOSE(frame)
	ITEM_CABINET_SELECTED_ITEM_CLEAR();
	local edit = GET_CHILD_RECURSIVELY(frame, "ItemSearch");
	edit:SetText("");
	INVENTORY_SET_CUSTOM_RBTNDOWN("None");
	TUTORIAL_TEXT_CLOSE(frame)

	local relicgem_scroll = ui.GetFrame("relicgem_lvup_scroll")
	if relicgem_scroll:IsVisible() == 1 then
		RELICGEM_LVUP_SCROLL_CANCEL()
		RELICGEM_LVUP_SCROLL_UI_RESET()
		ui.RemoveGuideMsg('NOT_A_RELIC_GEM')
		ui.GuideMsg('DropItemPlz')
	end
end

function ITEM_CABINET_VIBORA_TUTORIAL_OPEN(frame, open_flag)
	local acc = GetMyAccountObj()
	if acc == nil then return end

	local prop_name = "UITUTO_EQUIPCACABINET1"
	frame:SetUserValue('TUTO_PROP', prop_name)
	local tuto_step = GetUITutoProg(prop_name)
	if tuto_step >= 100 then return end

	local tuto_cls = GetClass('UITutorial', prop_name .. '_' .. tuto_step + 1)
	if tuto_cls == nil then
		tuto_cls = GetClass('UITutorial', prop_name .. '_100')
		if tuto_cls == nil then return end
	end

	local ctrl_name = TryGetProp(tuto_cls, 'ControlName', 'None')
	local title = dic.getTranslatedStr(TryGetProp(tuto_cls, 'Title', 'None'))
	local text = dic.getTranslatedStr(TryGetProp(tuto_cls, 'Note', 'None'))
	local ctrl = GET_CHILD_RECURSIVELY(frame, ctrl_name)
	if ctrl == nil then return end

	if open_flag == true then
		local category = ITEM_CABINET_GET_CATEGORY(frame)
		local id_space = 'cabinet_' .. string.lower(category)
		local itemList, itemListCnt = GetClassList(id_space)
		local itemgbox = GET_CHILD_RECURSIVELY(frame, 'itemgbox')
		local upgrade_tab = GET_CHILD_RECURSIVELY(frame, 'upgrade_tab')
		if tuto_step < 6 then
			if tuto_step >= 1 then
				local ctrlset = nil
				for i = 0, itemListCnt - 1 do
					local _ctrlset = GET_CHILD_RECURSIVELY(itemgbox, 'ITEM_TAB_CTRL_' .. i)
					if _ctrlset ~= nil then
						local available = _ctrlset:GetUserIValue('AVAILABLE')
						if available == 0 then
							ctrlset = _ctrlset
							break
						end
					end
				end
		
				if ctrlset ~= nil then
					local btn = GET_CHILD_RECURSIVELY(ctrlset, 'itemBtn')
					ITEM_CABINET_SELECT_ITEM(ctrlset, btn)
				end
			end
		
			if tuto_step >= 2 then
				upgrade_tab:SelectTab(1)
				ITEM_CABINET_UPGRADE_TAB(frame)
			end
		else
			if tuto_step >= 6 then
				local ctrlset = GET_CHILD_RECURSIVELY(itemgbox, 'ITEM_TAB_CTRL_0')
				for i = 0, itemListCnt - 1 do
					local _ctrlset = GET_CHILD_RECURSIVELY(itemgbox, 'ITEM_TAB_CTRL_' .. i)
					if _ctrlset ~= nil then
						local available = _ctrlset:GetUserIValue('AVAILABLE')
						if available == 1 then
							ctrlset = _ctrlset
							break
						end
					else
						break
					end
				end
		
				if ctrlset ~= nil then
					local btn = GET_CHILD_RECURSIVELY(ctrlset, 'itemBtn')
					ITEM_CABINET_SELECT_ITEM(ctrlset, btn)
				end
			end
		
			if tuto_step >= 7 then
				upgrade_tab:SelectTab(0)
				ITEM_CABINET_UPGRADE_TAB(frame)
			end
		end
	end

	TUTORIAL_TEXT_OPEN(ctrl, title, text, prop_name)
end

function ITEM_CABINET_ETC_ARMOR_TUTORIAL_OPEN(frame, open_flag)
	local prop_name = "UITUTO_EQUIPCACABINET2"
	frame:SetUserValue('TUTO_PROP', prop_name)
	local tuto_step = GetUITutoProg(prop_name)
	if tuto_step >= 100 then return end

	local tuto_cls = GetClass('UITutorial', prop_name .. '_' .. tuto_step + 1)
	if tuto_cls == nil then
		tuto_cls = GetClass('UITutorial', prop_name .. '_100')
		if tuto_cls == nil then return end
	end

	local ctrl_name = TryGetProp(tuto_cls, 'ControlName', 'None')
	local title = dic.getTranslatedStr(TryGetProp(tuto_cls, 'Title', 'None'))
	local text = dic.getTranslatedStr(TryGetProp(tuto_cls, 'Note', 'None'))
	local ctrl = GET_CHILD_RECURSIVELY(frame, ctrl_name)
	if ctrl == nil then return end

	if open_flag == true then
		local category = ITEM_CABINET_GET_CATEGORY(frame)
		local id_space = 'cabinet_' .. string.lower(category)
		local itemList, itemListCnt = GetClassList(id_space)
		local itemgbox = GET_CHILD_RECURSIVELY(frame, 'itemgbox')
		local upgrade_tab = GET_CHILD_RECURSIVELY(frame, 'upgrade_tab')
		if tuto_step >= 1 then
			local ctrlset = nil
			for i = 0, itemListCnt - 1 do
				local _ctrlset = GET_CHILD_RECURSIVELY(itemgbox, 'ITEM_TAB_CTRL_' .. i)
				if _ctrlset ~= nil then
					local available = _ctrlset:GetUserIValue('AVAILABLE')
					if available == 1 then
						ctrlset = _ctrlset
						break
					end
				end
			end
	
			if ctrlset ~= nil then
				local btn = GET_CHILD_RECURSIVELY(ctrlset, 'itemBtn')
				ITEM_CABINET_SELECT_ITEM(ctrlset, btn)
			end
		end
		
		if tuto_step >= 2 then
			upgrade_tab:SelectTab(0)
			ITEM_CABINET_UPGRADE_TAB(frame)
		end
	end

	TUTORIAL_TEXT_OPEN(ctrl, title, text, prop_name)
end

function ITEM_CABINET_ETC_WEAPON_TUTORIAL_OPEN(frame, open_flag)
	local prop_name = "UITUTO_EQUIPCACABINET3"
	frame:SetUserValue('TUTO_PROP', prop_name)
	local tuto_step = GetUITutoProg(prop_name)
	if tuto_step >= 100 then return end

	local tuto_cls = GetClass('UITutorial', prop_name .. '_' .. tuto_step + 1)
	if tuto_cls == nil then
		tuto_cls = GetClass('UITutorial', prop_name .. '_100')
		if tuto_cls == nil then return end
	end

	local ctrl_name = TryGetProp(tuto_cls, 'ControlName', 'None')
	local title = dic.getTranslatedStr(TryGetProp(tuto_cls, 'Title', 'None'))
	local text = dic.getTranslatedStr(TryGetProp(tuto_cls, 'Note', 'None'))
	local ctrl = GET_CHILD_RECURSIVELY(frame, ctrl_name)
	if ctrl == nil then return end

	if open_flag == true then
		local category = ITEM_CABINET_GET_CATEGORY(frame)
		local id_space = 'cabinet_' .. string.lower(category)
		local itemList, itemListCnt = GetClassList(id_space)
		local itemgbox = GET_CHILD_RECURSIVELY(frame, 'itemgbox')
		local upgrade_tab = GET_CHILD_RECURSIVELY(frame, 'upgrade_tab')
		if tuto_step >= 1 then
			local ctrlset = nil
			for i = 0, itemListCnt - 1 do
				local _ctrlset = GET_CHILD_RECURSIVELY(itemgbox, 'ITEM_TAB_CTRL_' .. i)
				if _ctrlset ~= nil then
					local available = _ctrlset:GetUserIValue('AVAILABLE')
					if available == 1 then
						ctrlset = _ctrlset
						break
					end
				end
			end
	
			if ctrlset ~= nil then
				local btn = GET_CHILD_RECURSIVELY(ctrlset, 'itemBtn')
				ITEM_CABINET_SELECT_ITEM(ctrlset, btn)
			end
		end
	
		if tuto_step >= 2 then
			upgrade_tab:SelectTab(0)
			ITEM_CABINET_UPGRADE_TAB(frame)
		end
	end

	TUTORIAL_TEXT_OPEN(ctrl, title, text, prop_name)
end

function ITEM_CABINET_UI_TUTORIAL_CHECK(frame, msg, arg_str, arg_num)
	if frame == nil or frame:IsVisible() == 0 then return end

	if session.shop.GetEventUserType() == 0 then return end

	if arg_num == 100 then
		if arg_str == 'UITUTO_EQUIPCACABINET1' then
			local tuto_icon_1 = GET_CHILD_RECURSIVELY(frame, "UITUTO_ICON_1")
			tuto_icon_1:ShowWindow(0)
		elseif arg_str == 'UITUTO_EQUIPCACABINET2' or arg_str == 'UITUTO_EQUIPCACABINET3' then
			local tuto_icon_2 = GET_CHILD_RECURSIVELY(frame, "UITUTO_ICON_2")
			tuto_icon_2:ShowWindow(0)
		end

		TUTORIAL_TEXT_CLOSE(frame)
		return
	end

	local open_flag = false
	if msg == nil then
		open_flag = true
	end

	local cabinet_tab = GET_CHILD_RECURSIVELY(frame, "cabinet_tab")
	local cabinet_index = cabinet_tab:GetSelectItemIndex()
	local equipment_tab = GET_CHILD_RECURSIVELY(frame, "equipment_tab")
	local equipment_index = equipment_tab:GetSelectItemIndex()
	if cabinet_index == 0 then
		if equipment_index == 0 then
			ITEM_CABINET_VIBORA_TUTORIAL_OPEN(frame, open_flag)
		elseif equipment_index == 1 then
			ITEM_CABINET_ETC_WEAPON_TUTORIAL_OPEN(frame, open_flag)
		else
			TUTORIAL_TEXT_CLOSE(frame)
		end
	elseif cabinet_index == 1 then
		if equipment_index == 1 then
			ITEM_CABINET_ETC_ARMOR_TUTORIAL_OPEN(frame, open_flag)
		else
			TUTORIAL_TEXT_CLOSE(frame)
		end
	else
		TUTORIAL_TEXT_CLOSE(frame)
	end
end

function ITEM_CABINET_UI_TUTO_ACTION_CHECK(frame, ctrl)

end

--Run Everytime when you change the CabinetTab Category
function ITEM_CABINET_CHANGE_TAB(frame)
	ITEM_CABINET_SET_EDIT_TOOLTIP_BY_CATEGORY(frame)
	local edit = GET_CHILD_RECURSIVELY(frame,"ItemSearch")
	edit:SetEventScript(ui.LBUTTONUP,"EDIT_CLEAR_TEXT");
	ITEM_CABINET_CREATE_LIST(frame);
end

--Run Everytime when you click Searching Box
function EDIT_CLEAR_TEXT(frame)
	local edit = GET_CHILD_RECURSIVELY(frame, "ItemSearch");
	edit:ClearText();
	edit:SetText("");
	local tooltipText = GET_CHILD_RECURSIVELY(frame,"editTooltip")
	tooltipText:ShowWindow(0);
end

--Searching Box Tooltip Customizing Function
function ITEM_CABINET_SET_EDIT_TOOLTIP_BY_CATEGORY(frame)
	local cabinet_tab = GET_CHILD_RECURSIVELY(frame,"cabinet_tab")	
	local category_Index = cabinet_tab:GetSelectItemIndex()
	local edit = GET_CHILD_RECURSIVELY(frame, "ItemSearch");
	edit:ClearText()
	
	local edit_tooltip = GET_CHILD_RECURSIVELY(frame,"editTooltip")
	edit_tooltip:ShowWindow(0)

	local skillgem_userVal = frame:GetUserValue("SKILLGEM_TEXT")
	if skillgem_userVal~="None" then
		edit:SetText(skillgem_userVal);
		frame:SetUserValue("SKILLGEM_TEXT","None")
		return
	end
	
	local firstKeywords = 
		{
			"", "", "", "", 
			ClMsg("ItemCabinetFirstKeyWord1"), 
			ClMsg("ItemCabinetFirstKeyWord2"),
			""
		}
	local lastKeywords = 
		{
			ClMsg("ItemCabinetLastKeyWord1"), 
			ClMsg("ItemCabinetLastKeyWord2"), 
			ClMsg("ItemCabinetLastKeyWord3"), 
			ClMsg("ItemCabinetLastKeyWord4"), 
			ClMsg("ItemCabinetLastKeyWord5"), 
			ClMsg("ItemCabinetLastKeyWord6"),
			ClMsg("ItemCabinetLastKeyWord7")
		}

	edit_tooltip:SetTextByKey("front",firstKeywords[category_Index + 1]);
	edit_tooltip:SetTextByKey("back", lastKeywords[category_Index + 1]);
	edit_tooltip:ShowWindow(1)
end

local currJobTab_index = -1;
--Resetting When you click another job icon in skillgem category
function ITEM_CABINET_CHANGE_JOBTAB(frame)
	local cabinet_tab = GET_CHILD_RECURSIVELY(frame,"cabinet_tab")
	local jobbox = GET_CHILD_RECURSIVELY(frame,"jobbox")
	local job_tab = GET_CHILD_RECURSIVELY(frame,"job_tab")
	local job_tab_index = job_tab:GetSelectItemIndex()
	local jobname = GET_CHILD_RECURSIVELY(frame,"jobname")
	
	if currJobTab_index ~= job_tab_index then 
		currJobTab_index = job_tab_index 
	end

	jobname:SetText(ClMsg("AlltargetClasses"))
	if(jobbox:GetUserValue("job_name")~=nil) then
		jobbox:SetUserValue("job_name","None")
	end
	cabinet_tab:SelectTab(4)
	ITEM_CABINET_CHANGE_TAB(frame)
end

--**setting UserValue("job_name") for Creating Ctrlset & Display jobname to korean
function CABINET_SELECT_REPRESENTATION_CLASS(selectedIndex, selectedKey)
	local frame = ui.GetFrame("item_cabinet")
	local jobbox = GET_CHILD_RECURSIVELY(frame,"jobbox")
	local text = GET_CHILD_RECURSIVELY(frame,"jobname")
	local userInput = selectedKey;
	local jobcls =GetClassByStrProp("Job","JobName",userInput);
	local jobname = TryGetProp(jobcls,"Name","None");
	
	if userInput=="ALL" then
		jobbox:SetUserValue("job_name", "ALL")
		text:SetText(ClMsg("AlltargetClasses"))
	else
		jobbox:SetUserValue("job_name", userInput)
		text:SetText(jobname)	
	end
	ITEM_CABINET_CREATE_LIST(frame);
end

function ITEM_CABINET_OPEN_CLASS_DROPLIST(parent, ctrl)
	local topframe = parent:GetTopParentFrame()
	local job_tab = GET_CHILD_RECURSIVELY(topframe,"job_tab")
	local jobtab_sel_idx = job_tab:GetSelectItemIndex();
	local job_list = {"Warrior", "Wizard", "Archer", "Cleric", "Scout"}

	local itemList, itemListCnt = GetClassList("Job");--xml 파일 cabinet_weapon, ..ark,..armor등 classId 입력값
	local jobcnt = 0;
	local selectedJobList = {} 
	local jobKeyList = {}
	for	i=0, itemListCnt-1 do
		local cls = GetClassByIndexFromList(itemList,i)
		local ctrltype = TryGetProp(cls,"CtrlType","None")
		local name = TryGetProp(cls,"Name","None") --한글 이름명
		local jobname = TryGetProp(cls,"JobName","None") --영어 이름명
		local rank = TryGetProp(cls,"Rank",200)
		if rank <= JOB_CHANGE_MAX_RANK and job_list[jobtab_sel_idx + 1] == ctrltype then			
			jobcnt = jobcnt +1	 
			table.insert(selectedJobList,name)
			table.insert(jobKeyList,jobname)															
		end	
	end
	local droplistframe = ui.MakeDropListFrame(ctrl,0,0,490,32*jobcnt,jobcnt,ui.CENTER_HORZ,'CABINET_SELECT_REPRESENTATION_CLASS',nil,nil)
	ui.AddDropListItem(ClMsg("AlltargetClasses"),nil,"ALL")
	
	ClMsg("AlltargetClasses")
	for i=1, #selectedJobList do
		ui.AddDropListItem(selectedJobList[i],nil,jobKeyList[i])
	end
end

--job Ctrltype Filtering when click job icon 
function ITEM_CABINET_LARGE_FILTER_JOB(frame,itemList,itemListCnt)
	local result_List = {};
	local topframe = frame:GetTopParentFrame()
	local job_tab = GET_CHILD_RECURSIVELY(topframe,"job_tab")
	local jobtab_sel_idx = job_tab:GetSelectItemIndex();
	local job_list = {"Warrior", "Wizard", "Archer", "Cleric", "Scout"}

	for i=0, itemListCnt-1 do
		local cls = GetClassByIndexFromList(itemList,i)
		local basejob_name = TryGetProp(cls,"CtrlType","None")
		if basejob_name == job_list[jobtab_sel_idx + 1] then
			table.insert(result_List,cls)
		end
	end
	return result_List
end


-- detailed job filtering 
function ITEM_CABINET_DETAILED_FILTER_JOB(frame,itemList,itemListcnt)
	local result_List={};
	local jobbox = GET_CHILD_RECURSIVELY(frame,"jobbox")
	local jobboxUserval = jobbox:GetUserValue("job_name") --from set: CABINET_SELECT_REPRESENTATION_CLASS
	if jobboxUserval=="ALL" then
		return itemList
	else
		for i=1,itemListcnt do
			local clsName = TryGetProp(itemList[i],"ClassName")
			local jobName = TryGetProp(itemList[i],"JobName")
			if jobName==jobboxUserval then 
				table.insert(result_List,itemList[i])		
			end
		end
	end
	return result_List
end

function ITEM_CABINET_FILTER_RELICGEM(frame,itemList,itemListCnt)
	local result_List = {};
	local topframe = frame:GetTopParentFrame();
	local relic_tab = GET_CHILD_RECURSIVELY(topframe,"relic_tab");
	local relictab_index = relic_tab:GetSelectItemIndex();
	local selectedGem = ""

	if relictab_index== 0 then
		selectedGem = "Gem_Relic_Cyan"
	elseif relictab_index==1 then
		selectedGem = "Gem_Relic_Magenta"
	elseif relictab_index==2 then
		selectedGem = "Gem_Relic_Black"
	end

	for i=0, itemListCnt-1 do
		local cls = GetClassByIndexFromList(itemList,i)
		local gemtype = TryGetProp(cls,"GemType","None")
		if gemtype==selectedGem then
			table.insert(result_List,cls)
		end
	end
	return result_List
end

function ITEM_CABINET_SHOW_ACHIEVEMENTRATE_RATE(itemGbox,category)
	local frame  = itemGbox:GetTopParentFrame();
	local jobbox = GET_CHILD_RECURSIVELY(frame,"jobbox")
	local achievementBox = GET_CHILD_RECURSIVELY(frame,"achievementBox")
	
	if category=='Skillgem' or category=='Relicgem'then
		itemGbox:Resize(itemGbox:GetOriginalWidth(),itemGbox:GetOriginalHeight()-40)
		achievementBox:ShowWindow(1)
	else
		itemGbox:Resize(itemGbox:GetOriginalWidth(),itemGbox:GetOriginalHeight())
		achievementBox:ShowWindow(0)
	end
end

local achievement_table = {}
function ITEM_CABINET_UPDATE_GEM_COLLECTION_ACHIEVEMENT(frame,achievement_table)
	if #achievement_table<4 then return end
	local achievementTextRight = GET_CHILD_RECURSIVELY(frame,'achievementTextRight')
	achievementTextRight:SetTextByKey('value1',achievement_table[1])
	achievementTextRight:SetTextByKey('value2',achievement_table[2])
	local achievementTextMid = GET_CHILD_RECURSIVELY(frame,'achievementTextMid')
	achievementTextMid:SetTextByKey('value1',achievement_table[3])
	achievementTextMid:SetTextByKey('value2',achievement_table[4])
end


function ITEM_CABINET_SKILLGEM_REGISTRATION_SUPPORT(frame,category)
	INVENTORY_SET_CUSTOM_RBTNDOWN("None")
	if category=="Skillgem" then
		INVENTORY_SET_CUSTOM_RBTNDOWN('ITEM_CABINET_SKILLGEM_REGISTER_RBTN')
	end
end

function ITEM_CABINET_SKILLGEM_REGISTER_RBTN(item_obj, slot)
	local frame 	  = ui.GetFrame('item_cabinet')
	local cabinet_tab = GET_CHILD_RECURSIVELY(frame,"cabinet_tab")
	local itemgbox = GET_CHILD_RECURSIVELY(frame,"itemgbox")
	local upgrade_tab = GET_CHILD_RECURSIVELY(frame,"upgrade_tab")
	local tab_index   = cabinet_tab:GetSelectItemIndex()
	if ui.IsFrameVisible("item_cabinet") ~= 1 or tab_index~=4 then return end
	if TryGetProp(item_obj,"StringArg","None") ~= "SkillGem" then return end
	if TryGetProp(item_obj,"CharacterBelonging",-1)==1 then 
		ui.SysMsg(ClMsg('CantUseCabinetCuzCopiedGem'))
		return 		
	end

	if IS_RANDOM_OPTION_SKILL_GEM(item_obj) then 
		ui.SysMsg(ClMsg('CantUseCabinetCuzRandomOption'))
		return 
	end



	local clsName	 = TryGetProp(item_obj,"ClassName","None")
	if clsName == "None" then return end
	local cabinetCls = GetClassByStrProp("cabinet_skillgem", "ClassName", clsName)
	if cabinetCls == nil then return end
	local gemName 	 = TryGetProp(cabinetCls,"Name","None")
	local ctrlType 	 = TryGetProp(cabinetCls,"CtrlType","None")
	local job_tab 	 = GET_CHILD_RECURSIVELY(frame,"job_tab")
	local edit 	= GET_CHILD_RECURSIVELY(frame, "ItemSearch");
	if ctrlType=="Warrior" then
		job_tab:SelectTab(0)
	elseif ctrlType=="Wizard" then
		job_tab:SelectTab(1)
	elseif ctrlType=="Archer" then
		job_tab:SelectTab(2)
	elseif ctrlType=="Cleric" then
		job_tab:SelectTab(3)
	elseif ctrlType=="Scout" then
		job_tab:SelectTab(4)
	else
		return
	end
	frame:SetUserValue("SKILLGEM_TEXT",gemName)
	ITEM_CABINET_CHANGE_JOBTAB(frame)
	local acc = GetMyAccountObj()
	local cabinet_accPropName = TryGetProp(cabinetCls,"AccountProperty","None")
	local accountProp = TryGetProp(acc,cabinet_accPropName,0)
	if accountProp == 1 then
		edit:SetText(""); --기 등록
	else
		local controlCnt = itemgbox:GetChildCount() -1 
		for i=1, controlCnt do
			local ctrlset = itemgbox:GetChildByIndex(i)
			if  ctrlset==nil then return end
			local ctrlTextName = GET_CHILD(ctrlset,"itemName")
			if dictionary.ReplaceDicIDInCompStr(gemName) == ctrlTextName:GetText() then
				
				local button = 	GET_CHILD(ctrlset,"itemBtn")
				ITEM_CABINET_SELECT_ITEM(ctrlset,button)
				ITEM_CABINET_MATERIAL_INV_BTN(item_obj,slot)
				upgrade_tab:SelectTab(1)
				ITEM_CABINET_UPGRADE_TAB(upgrade_tab:GetParent(),upgrade_tab)
			end
		end
	end
end

function ITEM_CABINET_CREATE_LIST(frame)
	frame = frame:GetTopParentFrame();
	ITEM_CABINET_CLOSE_SUCCESS(frame)
	ITEM_CABINET_SHOW_UPGRADE_UI(frame, 0)
	ITEM_CABINET_SELECTED_ITEM_CLEAR();
	local category = ITEM_CABINET_GET_CATEGORY(frame);
	local itemgbox = GET_CHILD_RECURSIVELY(frame,"itemgbox");
	ITEM_CABINET_SHOW_ACHIEVEMENTRATE_RATE(itemgbox,category)
	local itemList, itemListCnt = GetClassList("cabinet_"..string.lower(category));
	local group = "None";
	
	local jobbox = GET_CHILD_RECURSIVELY(frame,"jobbox"); 
	local jobTab = GET_CHILD_RECURSIVELY(frame,"job_tab");
	
	local relicTab = GET_CHILD_RECURSIVELY(frame,"relic_tab")

	local equipTab = GET_CHILD_RECURSIVELY(frame, "equipment_tab");
	local edit = GET_CHILD_RECURSIVELY(frame, "ItemSearch");
	local cap = edit:GetText();
	local filtering_List ={}; --filtering list for skillgem 

	local aObj = GetMyAccountObj();
	
	achievement_table={}
	table.insert(achievement_table,itemListCnt)
	local available_Count = 0
	for i=0, itemListCnt-1 do
		local itemCls = GetClassByIndexFromList(itemList,i)
		local accProp = TryGetProp(itemCls,"AccountProperty",0)
		local isAvailable = TryGetProp(aObj,accProp,0)
		if isAvailable==1 then
			available_Count = available_Count+1	
		end	
	end
	table.insert(achievement_table,available_Count)
	-- filterling
	if category=="Skillgem" then 
		filtering_List = ITEM_CABINET_LARGE_FILTER_JOB(frame,itemList,itemListCnt)
		if jobbox:GetUserValue("job_name") ~= "None" then
			filtering_List = ITEM_CABINET_DETAILED_FILTER_JOB(frame,filtering_List,#filtering_List)
		end
	elseif category=="Relicgem" then
		filtering_List = ITEM_CABINET_FILTER_RELICGEM(frame,itemList,itemListCnt)
	end
	table.insert(achievement_table,#filtering_List)
	available_Count = 0
	for i=1, #filtering_List do
		local itemCls = filtering_List[i]
		local accProp = TryGetProp(itemCls,"AccountProperty",0)
		local isAvailable = TryGetProp(aObj,accProp,0)
		if isAvailable==1 then
			available_Count = available_Count+1
		end	
	end
	table.insert(achievement_table,available_Count)
	--삽입된 achievement_table UI 표기 갱신
	ITEM_CABINET_UPDATE_GEM_COLLECTION_ACHIEVEMENT(frame,achievement_table)

	if category == "Weapon" or category == "Armor" then
		equipTab:ShowWindow(1);
		jobTab:ShowWindow(0);
		jobbox:ShowWindow(0);
		relicTab:ShowWindow(0);
		local equipTabIndex = equipTab:GetSelectItemIndex();
		if category == "Weapon" then
			if equipTabIndex == 0 then		
				group = "VIBORA";
			end
			equipTab:ChangeCaptionOnly(0,"{@st66b}{s16}"..ClMsg("Vibora"),false)
			
			-- tutorial
			do
				local tuto_icon_1 = GET_CHILD_RECURSIVELY(frame, "UITUTO_ICON_1")
				local tuto_icon_2 = GET_CHILD_RECURSIVELY(frame, "UITUTO_ICON_2")
				local Is_UITUTO_Prog1 = GetUITutoProg("UITUTO_EQUIPCACABINET1")
				if Is_UITUTO_Prog1 == 100 then
					tuto_icon_1:ShowWindow(0);
				else
					tuto_icon_1:ShowWindow(1);
				end
				local Is_UITUTO_Prog3 = GetUITutoProg("UITUTO_EQUIPCACABINET3")
				if Is_UITUTO_Prog3 == 100 then
					tuto_icon_2:ShowWindow(0);
				else
					tuto_icon_2:ShowWindow(1);
				end
		 	end
		elseif category == "Armor" then
			if equipTabIndex == 0 then		
				group = "GODDESS_EVIL";
			end
			equipTab:ChangeCaptionOnly(0,"{@st66b}{s16}"..ClMsg("GoddessEvil"),false)

			-- tutorial
			do
				local tuto_icon_1 = GET_CHILD_RECURSIVELY(frame, "UITUTO_ICON_1")
				local tuto_icon_2 = GET_CHILD_RECURSIVELY(frame, "UITUTO_ICON_2")
				tuto_icon_1:ShowWindow(0);
				local Is_UITUTO_Prog2 = GetUITutoProg("UITUTO_EQUIPCACABINET2")
				if Is_UITUTO_Prog2 == 100 then
					tuto_icon_2:ShowWindow(0);
				else
					tuto_icon_2:ShowWindow(1);
				end
			end
		end
	elseif category=="Skillgem" then
		ITEM_CABINET_SKILLGEM_REGISTRATION_SUPPORT(frame,category)
		group = "SKILLGEM";
		equipTab:ShowWindow(0);
		jobTab:ShowWindow(1); 
		jobbox:ShowWindow(1);
		relicTab:ShowWindow(0);
	elseif category =="Relicgem" then

		group = "RELICGEM";
		equipTab:ShowWindow(0);
		jobTab:ShowWindow(0); 
		jobbox:ShowWindow(0);
		relicTab:ShowWindow(1);
	else
		equipTab:ShowWindow(0);
		jobTab:ShowWindow(0);
		jobbox:ShowWindow(0);
		relicTab:ShowWindow(0);
	end
	local unavailabeList = {};
	local ctrlIndex = 0;
	
	itemgbox:RemoveAllChild(); 
	
	if category=="Skillgem" or category=="Relicgem" then
		for i =1,#filtering_List do
			local listCls = filtering_List[i]
			local available = TryGetProp(aObj, listCls.AccountProperty, 0);
			local itemGroup = TryGetProp(listCls,"TabGroup","None"); 
			if group == itemGroup or (group == "None" and itemGroup == "None") then
				if ITEM_CABINET_MATCH_NAME(listCls, cap) then
					if available == 1 then
						local itemTabCtrl
						if category=="Skillgem" then 
							itemTabCtrl=itemgbox:CreateOrGetControlSet('item_cabinet_tab', 'ITEM_TAB_CTRL_'..ctrlIndex,0,30+ctrlIndex * 90);			
						elseif category=="Relicgem" then
							itemTabCtrl=itemgbox:CreateOrGetControlSet('item_cabinet_tab', 'ITEM_TAB_CTRL_'..ctrlIndex,0,ctrlIndex * 90);			
						end
						ITEM_CABINET_ITEM_TAB_INIT(listCls, itemTabCtrl);
						itemTabCtrl:SetUserValue('AVAILABLE', 1)
						GET_CHILD(itemTabCtrl, 'shadow'):ShowWindow(0);
						ctrlIndex = ctrlIndex + 1;
					else
						table.insert(unavailabeList, listCls);
					end
				end
			end
		end
	else
		for i = 0, itemListCnt - 1 do
		
			local listCls = GetClassByIndexFromList(itemList, i);
			local available = TryGetProp(aObj, listCls.AccountProperty, 0);
			local itemGroup = TryGetProp(listCls,"TabGroup","None"); --
						
			if group == itemGroup or (group == "None" and itemGroup == "None") then
				if ITEM_CABINET_MATCH_NAME(listCls, cap) then
					if available == 1 then
						local itemTabCtrl= itemgbox:CreateOrGetControlSet('item_cabinet_tab', 'ITEM_TAB_CTRL_'..ctrlIndex,0,ctrlIndex * 90);
						ITEM_CABINET_ITEM_TAB_INIT(listCls, itemTabCtrl);
						itemTabCtrl:SetUserValue('AVAILABLE', 1)
						GET_CHILD(itemTabCtrl, 'shadow'):ShowWindow(0);
						ctrlIndex = ctrlIndex + 1;
					else
						table.insert(unavailabeList, listCls);
					end
				end
			end
		end
	end

	for i = 1, #unavailabeList do
		local listCls = unavailabeList[i];
		local itemTabCtrl 
		if(category=="Skillgem") then
			itemTabCtrl=itemgbox:CreateOrGetControlSet('item_cabinet_tab', 'ITEM_TAB_CTRL_'..ctrlIndex,0,30+ctrlIndex * 90);
		else
			itemTabCtrl=itemgbox:CreateOrGetControlSet('item_cabinet_tab', 'ITEM_TAB_CTRL_'..ctrlIndex,0,ctrlIndex * 90);
		end
		GET_CHILD(itemTabCtrl, 'shadow'):ShowWindow(1);
		ITEM_CABINET_ITEM_TAB_INIT(listCls, itemTabCtrl);
		itemTabCtrl:SetUserValue('AVAILABLE', 0)
		ctrlIndex = ctrlIndex + 1;
	end

	ITEM_CABINET_UI_TUTORIAL_CHECK(frame)

end

function ITEM_CABINET_SHOW_UPGRADE_UI(frame, isShow)
	local frame = frame:GetTopParentFrame();
	local category = ITEM_CABINET_GET_CATEGORY(frame);
	
	if category=="Relicgem" then
		GET_CHILD_RECURSIVELY(frame,"upgrade_tab"):ShowWindow(0);
		GET_CHILD_RECURSIVELY(frame,"upgrade_relicgem_tab"):ShowWindow(isShow);
		GET_CHILD_RECURSIVELY(frame,"relic_upgradeBg"):ShowWindow(isShow);
	else
		GET_CHILD_RECURSIVELY(frame,"upgrade_tab"):ShowWindow(isShow);
		GET_CHILD_RECURSIVELY(frame,"upgrade_relicgem_tab"):ShowWindow(0);	
	end
	GET_CHILD_RECURSIVELY(frame,"upgradegbox"):ShowWindow(isShow);
	GET_CHILD_RECURSIVELY(frame,"slot"):ShowWindow(isShow);
	GET_CHILD_RECURSIVELY(frame,"slot2"):ShowWindow(isShow);
	GET_CHILD_RECURSIVELY(frame,"registerbtn"):ShowWindow(isShow);
	GET_CHILD_RECURSIVELY(frame,"enchantbtn"):ShowWindow(isShow);
	GET_CHILD_RECURSIVELY(frame,"infotxt"):ShowWindow(isShow);
	GET_CHILD_RECURSIVELY(frame,"acctxt"):ShowWindow(isShow);
	GET_CHILD_RECURSIVELY(frame,"pricetxt"):ShowWindow(isShow);
	GET_CHILD_RECURSIVELY(frame,"optionGbox"):ShowWindow(isShow);
	GET_CHILD_RECURSIVELY(frame,"belongingtxt"):ShowWindow(isShow);
	GET_CHILD_RECURSIVELY(frame,"next_item_gb"):ShowWindow(isShow);
	
	if isShow == 1 then
		if category=="Relicgem" then
			ITEM_CABINET_UPGRADE_RELICGEM_TAB(frame);
		else
			ITEM_CABINET_UPGRADE_TAB(frame);
		end
	else
		frame:SetUserValue("SELECTED_TAB", "None");
		INVENTORY_SET_CUSTOM_RBTNDOWN("None");
	end

end

function GET_ENABLE_EQUIP_JOB(listCls)	
	local ori_name = TryGetProp(listCls, 'ClassName', 'None')		
	local job_cls = GetClass('EliteEquipDrop', ori_name)		
	if job_cls ~= nil then
		local job_name = TryGetProp(job_cls, 'JobName', 'None')
		if job_name ~= 'All' then
			local _cls = GetClassByStrProp("Job", "JobName", job_name);
			if _cls ~= nil then
				return dictionary.ReplaceDicIDInCompStr(TryGetProp(_cls, 'Name', 'None'))
			end
		end
	end
	return ''
end

function ITEM_CABINET_ITEM_TAB_INIT(listCls, itemTabCtrl)
	local itemSlot = GET_CHILD(itemTabCtrl, "itemIcon");  
	local itemText = GET_CHILD(itemTabCtrl, "itemName");
	
	if TryGetProp(listCls, 'GetItemFunc', 'None') == 'None' then return; end
	local get_name_func = _G[TryGetProp(listCls, 'GetItemFunc', 'None')];
	
	if get_name_func == nil then return; end
	
	local itemClsName = get_name_func(listCls, GetMyAccountObj());	
	
	if itemClsName == 'None' then return; end
	local itemCls = GetClass('Item', itemClsName);
	if itemCls == nil then return; end
	
	local add_str = ''	
	local add_job = ''
	if TryGetProp(itemCls, 'AdditionalOption_1', 'None') ~= 'None' then		
		add_str = '(' ..  ClMsg('Unique1') .. ')'
		
		add_job = GET_ENABLE_EQUIP_JOB(listCls)

		if add_job ~= '' then
			add_job = ' - ' .. add_job
		end
	end

	SET_SLOT_BG_BY_ITEMGRADE(itemSlot, itemCls);
	itemText:SetTextByKey('name', TryGetProp(itemCls, 'Name') .. add_str .. add_job);
	
	local icon = CreateIcon(itemSlot);
	icon:SetImage(TryGetProp(itemCls, 'Icon'));
	icon:GetInfo().type = itemCls.ClassID;
	local topframe = itemTabCtrl:GetTopParentFrame()
	local category = ITEM_CABINET_GET_CATEGORY(topframe)
	if category=="Relicgem" then
		itemSlot:EnableHitTest(0)
		local curlv  = ITEM_CABINET_GET_RELICGEM_UPGRADE_ACC_PROP(topframe,itemCls)
		if curlv~=nil and curlv > 0 then
			itemSlot:SetText("Lv."..curlv,"quickiconfont",ui.RIGHT,ui.BOTTOM,-2,1)
		end	
	elseif category == "Artefact" then
		itemSlot:EnableHitTest(0)
	else
		icon:SetTooltipNumArg(itemCls.ClassID);
		icon:SetTooltipStrArg('char_belonging');
		icon:SetTooltipType('wholeitem')
	end
		
	GET_CHILD(itemTabCtrl, 'select'):ShowWindow(0);
	itemTabCtrl:SetUserValue("ITEM_TYPE", listCls.ClassID);
end

function SEARCH_ITEM_CABINET_KEY()
	local frame = ui.GetFrame('item_cabinet')
	frame:CancelReserveScript("SEARCH_ITEM_CABINET");
	frame:ReserveScript("SEARCH_ITEM_CABINET", 0.3, 1);
end

function SEARCH_ITEM_CABINET(frame)
	ITEM_CABINET_CREATE_LIST(frame);
end

function ITEM_CABINET_MATCH_NAME(listCls, cap)
	if cap == "" then
		return true
	end

	if TryGetProp(listCls, 'GetItemFunc', 'None') == 'None' then return; end
	
	local get_name_func = _G[TryGetProp(listCls, 'GetItemFunc', 'None')];
	if get_name_func == nil then return; end

	local itemClsName = get_name_func(listCls, GetMyAccountObj());
	if itemClsName == 'None' then return; end
	
	local itemCls = GetClass('Item', itemClsName);
	if itemCls == nil then return; end

	local itemname = string.lower(dictionary.ReplaceDicIDInCompStr(TryGetProp(itemCls, 'Name')));	
	
	local prefixClassName = TryGetProp(itemCls, "LegendPrefix")
	if prefixClassName ~= nil and prefixClassName ~= "None" then
		local prefixCls = GetClass('LegendSetItem', prefixClassName)
		local prefixName = string.lower(dictionary.ReplaceDicIDInCompStr(prefixCls.Name));			
		itemname = prefixName .. " " .. itemname;
	end

	local tempcap = string.lower(dictionary.ReplaceDicIDInCompStr(cap));
	if string.find(itemname, tempcap) ~= nil then
		return true;
	end

	local noBarOrigin = string.gsub(itemname, '-', '')
	local noBartemp = string.gsub(tempcap, '-', '')

	if string.find(noBarOrigin, noBartemp) ~= nil then
		return true;
	end

	local enable_name = GET_ENABLE_EQUIP_JOB(listCls)
	if string.find(enable_name, tempcap) ~= nil then
		return true;
	end

	return false;
end

function ITEM_CABINET_EXCUTE_CREATE(parent, self)	
	local category = ITEM_CABINET_GET_CATEGORY(parent);
	local itemType = parent:GetUserIValue("ITEM_TYPE");
	local resultlist = session.GetItemIDList();
	if category == 'Accessory' then
		category = 1;
	elseif category == 'Ark' then
		category = 2;
	elseif category =="Skillgem" then 
		category = 3;
	elseif category =='Relicgem' then
		category = 4;
	else
		return;
	end
	
	pc.ReqExecuteTx_Item('MAKE_CABINET_ITEM', category, itemType);
end

function ITEM_CABINET_REINFORCE_IS_AVAILABLE(frame,cabinetItemCls)
	frame:SetUserValue("REINFORCE","true") 
	local curLv		  = ITEM_CABINET_GET_RELICGEM_UPGRADE_ACC_PROP(frame,cabinetItemCls)
	local isRegister  = ITEM_CABINET_GET_RELICGEM_ACC_PROP(frame,cabinetItemCls)
	local maxLv 	  = TryGetProp(cabinetItemCls,"MaxUpgrade",0)

	if maxLv<=curLv or maxLv==0 or isRegister==0 then 
		frame:SetUserValue("REINFORCE","false")
		return false
	end
	return true
end

local function ITEM_CABINET_MAT_CTRL_UPDATE(frame,index,mat_name,mat_cnt,is_discount)
	if is_discount == nil then
		is_discount = 0
	end
	local ctrlset = GET_CHILD_RECURSIVELY(frame, 'rmat_' .. index)
	if mat_name ~= nil then
		local mat_cls = GetClass('Item', mat_name)
		if mat_cls ~= nil then
			local mat_slot = GET_CHILD(ctrlset, 'mat_slot', 'ui::CSlot')
			mat_slot:SetUserValue('NEED_COUNT', mat_cnt)

			if mat_cnt > 0 then
				ctrlset:ShowWindow(1)
				mat_slot:SetEventScript(ui.DROP, 'ITEM_CABINET_REINFORCE_MAT_DROP')
				mat_slot:SetEventScriptArgString(ui.DROP, mat_name)
				mat_slot:SetEventScriptArgNumber(ui.DROP, mat_cnt)

	
				mat_slot:SetEventScript(ui.RBUTTONUP, 'ITEM_CABINET_REMOVE_REINFORCE_MAT')
				mat_slot:SetEventScriptArgString(ui.RBUTTONUP, mat_name)
				mat_slot:SetEventScriptArgNumber(ui.RBUTTONUP, mat_cnt)
				
				if is_discount ~= 1 then
					mat_slot:SetUserValue('ITEM_GUID', 'None')
					local icon = imcSlot:SetImage(mat_slot, mat_cls.Icon)
					icon:SetColorTone('FFFF0000')
				end

				local cntText = string.format('{s16}{ol}{b} %d', mat_cnt)
				mat_slot:SetText(cntText, 'count', ui.RIGHT, ui.BOTTOM, -5, -5)

				local mat_name = GET_CHILD(ctrlset, 'mat_name', 'ui::CRichText')
				mat_name:SetTextByKey('value', dic.getTranslatedStr(TryGetProp(mat_cls, 'Name', 'None')))
			else
				ctrlset:ShowWindow(0)
			end
		end
	end
end

function ITEM_CABINET_REINFORCE_MAT_DROP(frame, icon, argStr, argNum)
	if ui.CheckHoldedUI() == true then return end

	frame = ui.GetFrame('item_cabinet')
	if frame == nil then return end

	local tab = GET_CHILD_RECURSIVELY(frame, 'upgrade_relicgem_tab')
	if tab == nil then return end
	local index = tab:GetSelectItemIndex()
	if index ~= 1 then return end

	local lift_icon = ui.GetLiftIcon()
	local from_frame = lift_icon:GetTopParentFrame()

    if from_frame:GetName() == 'inventory' then
        local icon_info = lift_icon:GetInfo()
        local guid = icon_info:GetIESID()
        local inv_item = session.GetInvItemByGuid(guid)
		if inv_item == nil then return end
		
		local item_obj = GetIES(inv_item:GetObject())
		if item_obj == nil then return end
		
		local item_name = TryGetProp(item_obj, 'ClassName', 'None')
		local gem_lv = frame:GetUserIValue('GEM_LV')
		local misc_name, stone_name = shared_item_relic.get_gem_reinforce_mat_name(gem_lv)
	
		if item_name == misc_name then
			local ctrlset = GET_CHILD_RECURSIVELY(frame, 'rmat_1')
			ITEM_CABINET_REG_REINFORCE_MATERIAL(frame, ctrlset, inv_item, item_obj)
		elseif item_name == stone_name then
			local ctrlset = GET_CHILD_RECURSIVELY(frame, 'rmat_2')
			ITEM_CABINET_REG_REINFORCE_MATERIAL(frame, ctrlset, inv_item, item_obj)
		else
			ui.SysMsg(ClMsg('IMPOSSIBLE_ITEM'))
		end
	end
end

function ITEM_CABINET_REMOVE_REINFORCE_MAT(frame, slot)
	if ui.CheckHoldedUI() == true then return end
	frame = ui.GetFrame('item_cabinet')
	if frame == nil then return end

	slot:SetUserValue('ITEM_GUID', 'None')

	local icon = CreateIcon(slot)
	icon:SetColorTone('FFFF0000')
	
	ITEM_CABINET_REINFORCE_EXEC_BTN_UPDATE(frame)
end

local function ITEM_CABINET_REINFORCE_PRICE_UPDATE(frame,discountStone)
	if discountStone == nil then
		discountStone = 0
	end

	local r_price_gauge = GET_CHILD_RECURSIVELY(frame, 'r_price_gauge')
	local check_no_msgbox = GET_CHILD_RECURSIVELY(frame, 'check_no_msgbox')

	local price = frame:GetUserValue('REINFORCE_CUR_PRICE')
	if price == nil or price == 'None' then
		price = '0'
	end

	local totalPrice = frame:GetUserValue('REINFORCE_PRICE')
	if totalPrice == nil or totalPrice == 'None' then
		totalPrice = '0'
	end

	price = math.max(tonumber(DivForBigNumberInt64(price, '100000')), 0)
	totalPrice = math.max(tonumber(DivForBigNumberInt64(totalPrice, '100000')), 0)
	r_price_gauge:SetPoint(price, totalPrice)
	local gem_lv = tonumber(frame:GetUserValue('GEM_LV'))

	if gem_lv ~= nil then
		local _, stone_name = shared_item_relic.get_gem_reinforce_mat_name(gem_lv)
		local stone_cnt = shared_item_relic.get_gem_reinforce_mat_stone(gem_lv)

		if discountStone == stone_cnt and check_no_msgbox:IsChecked() ~= 1 then
			local textmsg = string.format("[ %s ]{nl}%s", ClMsg('RELIC_GEM_UPGRADE_TITLE_MSG'), ScpArgMsg("Enough_Relic_Gem_DiscountStone"))
			ui.MsgBox(textmsg)
		end

		if discountStone > 0 then
			stone_cnt = stone_cnt - discountStone
			if stone_cnt < 0 then
				stone_cnt = 0
			end
		end
		ITEM_CABINET_MAT_CTRL_UPDATE(frame, 2, stone_name, stone_cnt, 1)
	end
end


function SCR_LBTNDOWN_RELIC_GEM_CABINET_REINF_EXTRA_MAT(slotset,slot)
	if ui.CheckHoldedUI() == true then return end
	local frame = slotset:GetTopParentFrame()
	ui.EnableSlotMultiSelect(1)

	local normal_max = GET_RELIC_MAX_SUB_REVISION_COUNT()
	local premium_max = GET_RELIC_MAX_PREMIUM_SUB_REVISION_COUNT()
	local normal_cnt = 0
	local premium_cnt = 0

	for i = 0, slotset:GetSlotCount() - 1 do
		local _slot = slotset:GetSlotByIndex(i)
		if _slot ~= slot then
			local cnt = _slot:GetSelectCount()
			if cnt > 0 then
				local arg_str = _slot:GetUserValue('MAT_TYPE')
				if arg_str == 'normal' then
					normal_cnt = normal_cnt + cnt
				elseif arg_str == 'premium' then
					premium_cnt = premium_cnt + cnt
				end
			end
			
			if cnt == 0 then
				_slot:Select(0)
			end
		end
	end

	local select_cnt = slot:GetSelectCount()
	local arg_str = slot:GetUserValue('MAT_TYPE')
	if arg_str == 'normal' then
		if normal_cnt + select_cnt > normal_max then
			local adjust_cnt = normal_max - normal_cnt
			if adjust_cnt < 0 then
				adjust_cnt = 0
			end

			select_cnt = adjust_cnt
		end
		normal_cnt = normal_cnt + select_cnt
	elseif arg_str == 'premium' then
		if premium_cnt + select_cnt > premium_max then
			local adjust_cnt = premium_max - premium_cnt
			if adjust_cnt < 0 then
				adjust_cnt = 0
			end
			
			select_cnt = adjust_cnt
		end
		premium_cnt = premium_cnt + select_cnt
	end

	slot:SetSelectCount(select_cnt)
	if select_cnt == 0 then
		slot:Select(0)
	end

	frame:SetUserValue('EXTRA_MAT_' .. slot:GetSlotIndex(), select_cnt)

	slotset:SetUserValue('NORMAL_MAT_COUNT', normal_cnt)
	slotset:SetUserValue('PREMIUM_MAT_COUNT', premium_cnt)
	ITEM_CABINET_RELIC_GEM_REINF_RATE_UPDATE(frame)
end

function ITEM_CABINET_UPDATE_RELIC_GEM_REINF_EXTRA_MAT(frame)
	local slotset = GET_CHILD_RECURSIVELY(frame, 'rslotlist_extra_mat','ui::CSlotSet')
	slotset:ClearIconAll()
	for i = 0, slotset:GetSlotCount() - 1 do
		local slot = slotset:GetSlotByIndex(i)
		slot:RemoveChild('lv_txt')
	end
	slotset:SetUserValue('NORMAL_MAT_COUNT', 0)
	slotset:SetUserValue('PREMIUM_MAT_COUNT', 0)
	
	local inv_item_list = session.GetInvItemList()
			
	FOR_EACH_INVENTORY(inv_item_list, function(inv_item_list, inv_item, slotset)
		local obj = GetIES(inv_item:GetObject())
		local arg_str = item_relic_reinforce.is_reinforce_percentUp(obj) --강화 보조제(프리미엄, 일반) 확인 함수
		if arg_str ~= 'NO' then --강화 보조제 일경우
			local slotindex = imcSlot:GetEmptySlotIndex(slotset) --빈슬롯 인덱스 리턴
			local slot = slotset:GetSlotByIndex(slotindex)   
			local icon = CreateIcon(slot)
			icon:Set(obj.Icon, 'Item', inv_item.type, slotindex, inv_item:GetIESID(), inv_item.count)
			slot:SetUserValue('ITEM_GUID', inv_item:GetIESID()) --
			slot:SetUserValue('MAT_TYPE', arg_str) --강화보조제 타입 nomalpr
			slot:SetMaxSelectCount(inv_item.count)
			local class = GetClassByType('Item', inv_item.type)
			SET_SLOT_ITEM_TEXT_USE_INVCOUNT(slot, inv_item, obj, inv_item.count)
			ICON_SET_INVENTORY_TOOLTIP(icon, inv_item, 'poisonpot', class)
			if arg_str == 'normal' then --일반 강화 보조제
				local lv_txt = slot:CreateOrGetControl('richtext', 'lv_txt', 0, 0, slot:GetWidth(), slot:GetHeight() * 0.3)
				local lv_str = string.format('{@sti1c}{s16}Lv.%d', TryGetProp(obj, 'NumberArg1', 0))
				lv_txt:SetText(lv_str)
			end
			
			local prevSelectedCount = frame:GetUserIValue('EXTRA_MAT_' .. slotindex)
			if prevSelectedCount <= inv_item.count then
				slot:Select(1)
				slot:SetSelectCount(prevSelectedCount)
				SCR_LBTNDOWN_RELIC_GEM_CABINET_REINF_EXTRA_MAT(slotset, slot)
			else
				slot:SetSelectCount(0)
				slot:Select(0)
				frame:SetUserValue('EXTRA_MAT_' .. slotindex, 0)
			end
		end
	end, false, slotset)
	slotset:MakeSelectionList()
end

function ITEM_CABINET_RELIC_GEM_REINF_RATE_UPDATE(frame)
	local gem_lv = frame:GetUserIValue('GEM_LV')

	local def_rate = shared_item_relic.get_gem_reinforce_ratio(gem_lv)
	local rdef_rate_value = GET_CHILD_RECURSIVELY(frame, 'rdef_rate_value')
	rdef_rate_value:SetTextByKey('value', string.format('%.2f', def_rate * 0.0001))
	

	local acc = GetMyAccountObj()
	local item_type = frame:GetUserIValue("ITEM_TYPE")
	local cabinet_class = GetClassByType("cabinet_relicgem",item_type)
	local reif_acc_prop = TryGetProp(cabinet_class,"ReinforceAccProp")
	local add_rate_by_failure = TryGetProp(acc,reif_acc_prop,"None") 
	local radd_rate_value = GET_CHILD_RECURSIVELY(frame, 'radd_rate_value')
	radd_rate_value:SetTextByKey('value', string.format('%.3f', add_rate_by_failure * 0.0001))

	local final_rate = def_rate + add_rate_by_failure
	local rtotal_rate_value = GET_CHILD_RECURSIVELY(frame, 'rtotal_rate_value')
	rtotal_rate_value:SetTextByKey('value', string.format('%.3f', final_rate * 0.0001))

	local slotset = GET_CHILD_RECURSIVELY(frame, 'rslotlist_extra_mat')
	local normal_cnt = slotset:GetUserIValue('NORMAL_MAT_COUNT')
	local premium_cnt = slotset:GetUserIValue('PREMIUM_MAT_COUNT')
	local add_rate_when_failed = item_relic_reinforce.get_revision_ratio(def_rate, normal_cnt, premium_cnt)	
	local rextra_mat_text = GET_CHILD_RECURSIVELY(frame, 'rextra_mat_text')
	rextra_mat_text:SetTextByKey('value', string.format('%.3f', add_rate_when_failed * 0.0001))
end


function ITEM_CABINET_RESET_RELIC_GEM_REINF_MAT_CNT(frame)
	local send_ok_reinforce = GET_CHILD_RECURSIVELY(frame, 'send_ok_reinforce')
	send_ok_reinforce:ShowWindow(0)
	
	local slotset_extra_mat = GET_CHILD_RECURSIVELY(frame, 'rslotlist_extra_mat','ui::CSlotSet')
	slotset_extra_mat:ClearIconAll()
	for i = 0, slotset_extra_mat:GetSlotCount() - 1 do
		local slot = slotset_extra_mat:GetSlotByIndex(i)
		slot:RemoveChild('lv_txt')
		slot:SetSelectCount(0)
		slot:Select(0)
		frame:SetUserValue('EXTRA_MAT_' .. i, 0)
	end
	slotset_extra_mat:SetUserValue('NORMAL_MAT_COUNT', 0)
	slotset_extra_mat:SetUserValue('PREMIUM_MAT_COUNT', 0)

	local slotset_discount = GET_CHILD_RECURSIVELY(frame, 'rslotlist_discount','ui::CSlotSet')
	for i = 0, slotset_discount:GetSlotCount() - 1 do
		local slot = slotset_discount:GetSlotByIndex(i)
		slot:SetSelectCount(0)
		slot:Select(0)
		frame:SetUserValue('DISCOUNT_MAT_' .. i, 0)
		slot:SetMaxSelectCount(1)
		slot:SetUserValue('DISCOUNT_POINT', 0)
		slot:SetUserValue('DISCOUNT_STONE', 0)
		slot:SetUserValue('DISCOUNT_TYPE', "")
	end
end

function ITEM_CABINET_REINFORCE_TOTAL_DISCOUNT_PRICE()
	local frame = ui.GetFrame('item_cabinet')
    if frame == nil then
        return
    end

    local slotSet = GET_CHILD_RECURSIVELY(frame, "rslotlist_discount")
	local totalDiscount = 0
	local stoneDiscount = 0

	for i = 0, slotSet:GetSlotCount() - 1 do
		local slot = slotSet:GetSlotByIndex(i)
		local point = tonumber(slot:GetUserValue("DISCOUNT_POINT"))
		local stone = tonumber(slot:GetUserValue("DISCOUNT_STONE"))
		if point == nil then 
			break
		end

		totalDiscount = SumForBigNumberInt64(totalDiscount, MultForBigNumberInt64(slot:GetSelectCount(), point))
		stoneDiscount = stoneDiscount + (slot:GetSelectCount() * stone)
    end
    
    return totalDiscount, stoneDiscount
end

function ITEM_CABINET_REINFORCE_EXEC_BTN_UPDATE(frame)
	local do_reinforce = GET_CHILD_RECURSIVELY(frame, 'do_reinforce')

	local price = frame:GetUserValue('REINFORCE_CUR_PRICE')
	if price == nil or price == 'None' then
		price = '0'
	end

	local total_price = frame:GetUserValue('REINFORCE_PRICE')
	if total_price == nil or total_price == 'None' then
		total_price = '0'
	end

	local rmat_1 = GET_CHILD_RECURSIVELY(frame, 'rmat_1')
	local rmat_1_slot = GET_CHILD(rmat_1, 'mat_slot', 'ui::CSlot')
	local rmat_1_guid = rmat_1_slot:GetUserValue('ITEM_GUID')
	
	local rmat_2 = GET_CHILD_RECURSIVELY(frame, 'rmat_2')
	local rmat_2_slot = GET_CHILD(rmat_2, 'mat_slot', 'ui::CSlot')
	local rmat_2_guid = rmat_2_slot:GetUserValue('ITEM_GUID')
	local rmat_2_need = rmat_2_slot:GetUserIValue('NEED_COUNT')
	

	if IsGreaterThanForBigNumber(total_price, price) == 0 and rmat_1_guid ~= 'None' and (rmat_2_guid ~= 'None' or rmat_2_need <= 0) then
		do_reinforce:SetEnable(1)
	else
		do_reinforce:SetEnable(0)
	end
end


function ITEM_CABINET_REINFORCE_DISCOUNT_CLICK(slotSet, slot)
	local frame = ui.GetFrame('item_cabinet')
	if frame == nil then
        return
	end
	
	local gem_lv = tonumber(frame:GetUserValue('GEM_LV'))
	if gem_lv == nil then
		return
	end

	local totalPrice = frame:GetUserValue('REINFORCE_PRICE')
	local totalStone = shared_item_relic.get_gem_reinforce_mat_stone(gem_lv)
	local discountPrice, discountStone = ITEM_CABINET_REINFORCE_TOTAL_DISCOUNT_PRICE()

    local adjustValue = SumForBigNumberInt64(totalPrice, tostring(tonumber(discountPrice) * -1))
	local adjustStone = totalStone - discountStone
	if IsGreaterThanForBigNumber(0, adjustValue) == 1 then
		local stone = tonumber(slot:GetUserValue("DISCOUNT_STONE"))
		if stone ~= nil and stone > 0 then
			local point = tonumber(slot:GetUserValue("DISCOUNT_POINT"))
			if point == nil or point == 0 then
				return
			end
	
			local nowCount = slot:GetSelectCount()
			local adjustByPoint = math.floor(tonumber(DivForBigNumberInt64(adjustValue, point)))
			local adjustByStone = math.floor(adjustStone / stone)
			if adjustByPoint <= 0 and adjustByStone < 0 then
				local adjustCount = math.max(adjustByPoint, adjustByStone)
				local adjustedCount = math.max(nowCount + adjustCount, 0)
				slot:SetSelectCount(adjustedCount)
				adjustValue = SumForBigNumberInt64(adjustValue, tostring(adjustCount * point * -1))
			end

			local _adjustValue = adjustValue
			for i = 0, slotSet:GetSelectedSlotCount() - 1 do
				local _slot = slotSet:GetSelectedSlot(i)
				local _point = tonumber(_slot:GetUserValue("DISCOUNT_POINT"))
				local _stone = tonumber(_slot:GetUserValue("DISCOUNT_STONE"))
				if _stone == 0 then
					local _nowCount = _slot:GetSelectCount()
					local _adjustCount = math.floor(tonumber(DivForBigNumberInt64(_adjustValue, _point)))
					local _adjustedCount = math.max(_nowCount + _adjustCount, 0)
					_slot:SetSelectCount(_adjustedCount)
					frame:SetUserValue('DISCOUNT_MAT_' .. _slot:GetSlotIndex(), _adjustedCount)

					if _adjustedCount == 0 then
						_slot:Select(0)
					end

					_adjustValue = _adjustValue - (_adjustedCount * _point)
					if _adjustValue >= 0 then
						break
					end
				end
			end
		else
			local point = tonumber(slot:GetUserValue("DISCOUNT_POINT"))
			if point == nil or point == 0 then
				return
			end
	
			local nowCount = slot:GetSelectCount()
			local adjustCount = math.floor(tonumber(DivForBigNumberInt64(adjustValue, point)))
			adjustCount = math.max(nowCount + adjustCount, 0)
			slot:SetSelectCount(adjustCount)
		end
	end

	local selectedCount = slot:GetSelectCount()
	if selectedCount == 0 then
		slot:Select(0)
	end

	local mat_type = slot:GetUserValue('DISCOUNT_TYPE')
	frame:SetUserValue('DISCOUNT_MAT_' .. slot:GetSlotIndex(), selectedCount)
	ui.EnableSlotMultiSelect(1)
	
	local totalPrice = frame:GetUserValue('REINFORCE_PRICE')
	local discountPrice, discountStone = ITEM_CABINET_REINFORCE_TOTAL_DISCOUNT_PRICE()
	frame:SetUserValue('REINFORCE_CUR_PRICE', discountPrice)
	
	
	ITEM_CABINET_REINFORCE_PRICE_UPDATE(frame, discountStone)
	ITEM_CABINET_REINFORCE_EXEC_BTN_UPDATE(frame)
end

function ITEM_CABINET_UPDATE_REINFORCE_DISCOUNT(frame)
    local discountSet = GET_CHILD_RECURSIVELY(frame, 'rslotlist_discount', 'ui::CSlotSet')
    discountSet:ClearIconAll()

	local invItemList = session.GetInvItemList()
	local discountItemList = SCR_RELIC_GEM_REINFORCE_COUPON()
	
	FOR_EACH_INVENTORY(invItemList, 
    function(invItemList, invItem, discountSet, materialItemList, discountItemList)
		local obj = GetIES(invItem:GetObject())
        local itemName = TryGetProp(obj, 'ClassName', 'None')
        
        if table.find(discountItemList, itemName) > 0 then
			if imcSlot:GetFilledSlotCount(discountSet) == discountSet:GetSlotCount() then
				return
            end

            local slotindex = imcSlot:GetEmptySlotIndex(discountSet)
            local slot = discountSet:GetSlotByIndex(slotindex)
			slot:SetMaxSelectCount(invItem.count)
			slot:SetSelectCountPerCtrlClick(1000)
			slot:SetUserValue('DISCOUNT_POINT', obj.NumberArg1)
			slot:SetUserValue('DISCOUNT_STONE', obj.NumberArg2)
			slot:SetUserValue('DISCOUNT_TYPE', invItem.type)

			local icon = CreateIcon(slot)
            icon:Set(obj.Icon, 'Item', invItem.type, slotindex, invItem:GetIESID(), invItem.count)
            
			local class = GetClassByType('Item', invItem.type)
			SET_SLOT_ITEM_TEXT_USE_INVCOUNT(slot, invItem, obj, invItem.count)
			ICON_SET_INVENTORY_TOOLTIP(icon, invItem, 'poisonpot', class)

			local prevSelectedCount = frame:GetUserIValue('DISCOUNT_MAT_' .. slotindex)
			if prevSelectedCount <= invItem.count then
				slot:Select(1)
				slot:SetSelectCount(prevSelectedCount)
				ITEM_CABINET_REINFORCE_DISCOUNT_CLICK(discountSet, slot)
			else
				slot:SetSelectCount(0)
				slot:Select(0)
				frame:SetUserValue('DISCOUNT_MAT_' .. slotindex, 0)
			end
        end

	end, false, discountSet, materialItemList, discountItemList)

	discountSet:MakeSelectionList()
end

function ITEM_CABINET_REG_REINFORCE_MATERIAL(frame, ctrlset, inv_item, item_obj)
	if ctrlset == nil then return end
	local slot = GET_CHILD(ctrlset, 'mat_slot', 'ui::CSlot')
	if slot == nil then return end

	local need_cnt = slot:GetUserIValue('NEED_COUNT')
	local cur_cnt = GET_INV_ITEM_COUNT_BY_PROPERTY({
		{ Name = 'ClassName', Value = item_obj.ClassName }
	}, false)

	if cur_cnt < need_cnt then
		ui.SysMsg(ClMsg('NotEnoughRecipe'))
		return
	end

	local icon = CreateIcon(slot)
	icon:SetColorTone('FFFFFFFF')

	local guid = GetIESID(item_obj)
	slot:SetUserValue('ITEM_GUID', guid)

	ITEM_CABINET_REINFORCE_EXEC_BTN_UPDATE(frame)
end

--It is executed only when you click item in inventory.
function ITEM_CABINET_REINFORCE_INV_RBTN(item_obj,slot)
	local frame = ui.GetFrame('item_cabinet')
	if frame == nil then return end

	local icon = CreateIcon(slot)
    local icon_info = icon:GetInfo()
	local guid = icon_info:GetIESID()
	
    local inv_item = session.GetInvItemByGuid(guid)
	if inv_item == nil then return end

	local item_obj = GetIES(inv_item:GetObject())
	if item_obj == nil then return end
	
	if inv_item.isLockState == true then
		ui.SysMsg(ClMsg('MaterialItemIsLock'))
		return
	end

	local item_name = TryGetProp(item_obj, 'ClassName', 'None')
	local gem_lv = frame:GetUserIValue('GEM_LV')
	local misc_name, stone_name = shared_item_relic.get_gem_reinforce_mat_name(gem_lv)
	if item_name == misc_name then
		local ctrlset = GET_CHILD_RECURSIVELY(frame, 'rmat_1')
		ITEM_CABINET_REG_REINFORCE_MATERIAL(frame, ctrlset, inv_item, item_obj)
	elseif item_name == stone_name then
		local ctrlset = GET_CHILD_RECURSIVELY(frame, 'rmat_2')		
		ITEM_CABINET_REG_REINFORCE_MATERIAL(frame, ctrlset, inv_item, item_obj)
	else
		ui.SysMsg(ClMsg('IMPOSSIBLE_ITEM'))
	end

	ITEM_CABINET_REINFORCE_EXEC_BTN_UPDATE(frame)
end

local function _CHECK_MAT_BEFORE_REINFORCE(ctrlset)
	local mat_slot = GET_CHILD(ctrlset, 'mat_slot', 'ui::CSlot')
	local guid = mat_slot:GetUserValue('ITEM_GUID')
	local inv_item = session.GetInvItemByGuid(guid)
	if inv_item == nil then
		return false, 'None'
	end
	local item_obj = GetIES(inv_item:GetObject())
	if item_obj == nil then
		return false, 'None'
	end

	local need_cnt = mat_slot:GetUserIValue('NEED_COUNT')
	local cur_cnt =GET_INV_ITEM_COUNT_BY_PROPERTY({
        { Name = 'ClassName', Value = item_obj.ClassName }
	}, false)
	
	if cur_cnt < need_cnt then
		return false, 'NotEnoughRecipe'
	end

	if inv_item.isLockState == true then
		return false, 'MaterialItemIsLock'
	end

	return true
end

function ITEM_CABINET_REINFORCE_EXEC(parent)
	local frame = parent:GetTopParentFrame()
	if frame == nil then return end
	
	local rmat_1 = GET_CHILD_RECURSIVELY(frame,'rmat_1') 
	if rmat_1:IsVisible() ==1 then
		local check1, msg1 = _CHECK_MAT_BEFORE_REINFORCE(rmat_1)
		if check1 == false then
			if msg1 ~= nil and msg1 ~= 'None' then
				ui.SysMsg(ClMsg(msg1))	
			end
			return 
		end
	end
	
	local rmat_2 = GET_CHILD_RECURSIVELY(frame, 'rmat_2')
	if rmat_2:IsVisible() == 1 then
		local check2, msg2 = _CHECK_MAT_BEFORE_REINFORCE(rmat_2)
		if check2 == false then
			if msg2 ~= nil and msg2 ~= 'None' then
				ui.SysMsg(ClMsg(msg2))
			end
			return
		end
	end

	local original = frame:GetUserValue('REINFORCE_PRICE')
    local discount = ITEM_CABINET_REINFORCE_TOTAL_DISCOUNT_PRICE()
	
	local silver_cnt = SumForBigNumberInt64(original, tostring(tonumber(discount) * -1))
	silver_cnt = math.max(tonumber(silver_cnt), 0)
	session.ResetItemList()
    
	local discountSet = GET_CHILD_RECURSIVELY(frame, 'rslotlist_discount', 'ui::CSlotSet')
	for i = 0, discountSet:GetSelectedSlotCount() -1 do
        local slot = discountSet:GetSelectedSlot(i)
        local Icon = CreateIcon(slot)
        local iconInfo = Icon:GetInfo()
		local cnt = slot:GetSelectCount()
		local dis_item = session.GetInvItemByGuid(iconInfo:GetIESID())
        session.AddItemID(iconInfo:GetIESID(), cnt)
    end
	
	local extraMatSet = GET_CHILD_RECURSIVELY(frame, 'rslotlist_extra_mat')
	for i = 0, extraMatSet:GetSelectedSlotCount() - 1 do
		local slot = extraMatSet:GetSelectedSlot(i)
		local _guid = slot:GetUserValue('ITEM_GUID')
		local cnt = slot:GetSelectCount()
		session.AddItemID(_guid, cnt)
	end
	
	local check_no_msgbox = GET_CHILD_RECURSIVELY(frame, 'check_no_msgbox')
	if check_no_msgbox:IsChecked() == 1 then
		_ITEM_CABINET_REINFORCE_EXEC()
	else 
		local gem_name = dic.getTranslatedStr(TryGetProp(gem_obj, 'Name', 'None'))
		local msg = ScpArgMsg('REALLY_DO_RELIC_GEM_REINFORCE_IN_CABINET')
		local yesScp = '_ITEM_CABINET_REINFORCE_EXEC()'
		local msgbox = ui.MsgBox(msg, yesScp, 'None')
		SET_MODAL_MSGBOX(msgbox)
	end
	
end

function _ITEM_CABINET_REINFORCE_EXEC()
	local frame = ui.GetFrame('item_cabinet')
	if frame == nil then return end
	
	local gem_type = frame:GetUserValue('GEM_TYPE')

	local do_reinforce = GET_CHILD_RECURSIVELY(frame, 'do_reinforce')
	local result_list = session.GetItemIDList()
	local argStrList = NewStringList();
	argStrList:Add(gem_type);	
	item.DialogTransaction("RELIC_GEM_REINFORCE_FOR_CABINET", result_list, '', argStrList);
end

function END_CABINET_RELIC_GEM_REINFORCE(frame,msg,arg_str,arg_num)
	local do_reinforce = GET_CHILD_RECURSIVELY(frame, 'do_reinforce')
	if do_reinforce ~= nil then
		do_reinforce:ShowWindow(0)
	end
	frame:SetUserValue('END_RELIC_GEM_REINFORCE', arg_str)
	if arg_str == 'SUCCESS' then
		ReserveScript('_RUN_CABINET_RELIC_GEM_REINFORCE_SUCCESS()', 0)
	elseif arg_str == 'FAILED' then
		ReserveScript('_RUN_CABINET_RELIC_GEM_REINFORCE_FAILED()', 0)
	end
	
end

function _RUN_CABINET_RELIC_GEM_REINFORCE_SUCCESS()
	local frame = ui.GetFrame('item_cabinet')
	if frame:IsVisible() == 0 then return end
	local relic_top_gb = GET_CHILD_RECURSIVELY(frame, 'relic_top_gb')
	if relic_top_gb == nil then return end

	relic_top_gb:ShowWindow(0)

	local send_ok_reinforce = GET_CHILD_RECURSIVELY(frame, 'send_ok_reinforce')
	send_ok_reinforce:ShowWindow(1)

	local rresult_gb = GET_CHILD_RECURSIVELY(frame, 'rresult_gb')
	rresult_gb:ShowWindow(1)

	local r_success_effect_bg = GET_CHILD_RECURSIVELY(frame, 'r_success_effect_bg')
	local r_success_skin = GET_CHILD_RECURSIVELY(frame, 'r_success_skin')
	local r_text_success = GET_CHILD_RECURSIVELY(frame, 'r_text_success')
	r_success_effect_bg:ShowWindow(1)
	r_success_skin:ShowWindow(1)
	r_text_success:ShowWindow(1)

	local r_fail_effect_bg = GET_CHILD_RECURSIVELY(frame, 'r_fail_effect_bg')
	local r_fail_skin = GET_CHILD_RECURSIVELY(frame, 'r_fail_skin')
	local r_text_fail = GET_CHILD_RECURSIVELY(frame, 'r_text_fail')
	r_fail_effect_bg:ShowWindow(0)
	r_fail_skin:ShowWindow(0)
	r_text_fail:ShowWindow(0)

	local r_result_item_img = GET_CHILD_RECURSIVELY(frame, 'r_result_item_img')
	r_result_item_img:ShowWindow(1)

	local type = frame:GetUserIValue('ITEM_TYPE')
	local itemCls = GetClassByType("Item",type)
	r_result_item_img:SetImage(TryGetProp(itemCls, 'Icon', 'None'))
	
	CABINET_RELIC_GEM_REINFORCE_SUCCESS_EFFECT(frame)
end

function CABINET_RELIC_GEM_REINFORCE_SUCCESS_EFFECT(frame)
	local frame = ui.GetFrame('item_cabinet')
	local SUCCESS_EFFECT_NAME = frame:GetUserConfig('DO_SUCCESS_EFFECT')
	local SUCCESS_EFFECT_SCALE = tonumber(frame:GetUserConfig('SUCCESS_EFFECT_SCALE'))
	local SUCCESS_EFFECT_DURATION = tonumber(frame:GetUserConfig('SUCCESS_EFFECT_DURATION'))
	local r_success_effect_bg = GET_CHILD_RECURSIVELY(frame, 'r_success_effect_bg')
	if r_success_effect_bg == nil then return end

	local relic_top_gb = GET_CHILD_RECURSIVELY(frame, 'relic_top_gb')
	if relic_top_gb == nil then return end

	relic_top_gb:ShowWindow(0)

	r_success_effect_bg:PlayUIEffect(SUCCESS_EFFECT_NAME, SUCCESS_EFFECT_SCALE, 'DO_SUCCESS_EFFECT')

	ReserveScript('_CABINET_RELIC_GEM_REINFORCE_SUCCESS_EFFECT()', SUCCESS_EFFECT_DURATION)
end

function _CABINET_RELIC_GEM_REINFORCE_SUCCESS_EFFECT(frame)
	local frame = ui.GetFrame('item_cabinet')
	if frame:IsVisible() == 0 then return end

	local r_success_effect_bg = GET_CHILD_RECURSIVELY(frame, 'r_success_effect_bg')
	if r_success_effect_bg == nil then return end

	r_success_effect_bg:StopUIEffect('DO_SUCCESS_EFFECT', true, 0.5)

	ui.SetHoldUI(false)
end

function _RUN_CABINET_RELIC_GEM_REINFORCE_FAILED()
	local frame = ui.GetFrame('item_cabinet')
	if frame:IsVisible() == 0 then return end
	local relic_top_gb = GET_CHILD_RECURSIVELY(frame, 'relic_top_gb')
	if relic_top_gb == nil then return end

	relic_top_gb:StopUIEffect('DO_RESULT_EFFECT', true, 0.5)
	relic_top_gb:ShowWindow(1)

	local send_ok_reinforce = GET_CHILD_RECURSIVELY(frame, 'send_ok_reinforce')
	if send_ok_reinforce ~= nil then
		send_ok_reinforce:ShowWindow(1)
	end

	local rresult_gb = GET_CHILD_RECURSIVELY(frame, 'rresult_gb')
	rresult_gb:ShowWindow(1)
	local r_success_effect_bg = GET_CHILD_RECURSIVELY(frame, 'r_success_effect_bg')
	local r_success_skin = GET_CHILD_RECURSIVELY(frame, 'r_success_skin')
	local r_text_success = GET_CHILD_RECURSIVELY(frame, 'r_text_success')
	r_success_effect_bg:ShowWindow(0)
	r_success_skin:ShowWindow(0)
	r_text_success:ShowWindow(0)

	local r_fail_skin = GET_CHILD_RECURSIVELY(frame, 'r_fail_skin')
	local r_text_fail = GET_CHILD_RECURSIVELY(frame, 'r_text_fail')
	r_fail_skin:ShowWindow(1)
	r_text_fail:ShowWindow(1)

	CABINET_RELIC_GEM_REINFORCE_FAIL_EFFECT(frame)
end

function CABINET_RELIC_GEM_REINFORCE_FAIL_EFFECT(frame)
	local frame = ui.GetFrame('item_cabinet')
	local FAIL_EFFECT_NAME = frame:GetUserConfig('DO_FAIL_EFFECT')
	local FAIL_EFFECT_SCALE = tonumber(frame:GetUserConfig('FAIL_EFFECT_SCALE'))
	local FAIL_EFFECT_DURATION = tonumber(frame:GetUserConfig('FAIL_EFFECT_DURATION'))
	local r_fail_effect_bg = GET_CHILD_RECURSIVELY(frame, 'r_fail_effect_bg')
	if r_fail_effect_bg == nil then return end

	local r_result_item_img = GET_CHILD_RECURSIVELY(frame, 'r_result_item_img')
	r_result_item_img:ShowWindow(0)

	r_fail_effect_bg:PlayUIEffect(FAIL_EFFECT_NAME, FAIL_EFFECT_SCALE, 'DO_FAIL_EFFECT')

	ReserveScript('_CABINET_RELIC_GEM_REINFORCE_FAIL_EFFECT()', FAIL_EFFECT_DURATION)
end

function _CABINET_RELIC_GEM_REINFORCE_FAIL_EFFECT(frame)
	local frame = ui.GetFrame('item_cabinet')
	if frame:IsVisible() == 0 then return end

	local r_fail_effect_bg = GET_CHILD_RECURSIVELY(frame, 'r_fail_effect_bg')
	if r_fail_effect_bg == nil then return end

	r_fail_effect_bg:StopUIEffect('DO_FAIL_EFFECT', true, 0.5)
	ui.SetHoldUI(false)
end

function CONFIRM_ITEM_CABINET_REINFORCE()
	local frame = ui.GetFrame('item_cabinet')
	if frame == nil then return end
	local result = frame:GetUserValue('END_RELIC_GEM_REINFORCE')
	frame:SetUserValue('END_RELIC_GEM_REINFORCE', "None")

	local relic_top_gb = GET_CHILD_RECURSIVELY(frame, 'relic_top_gb')
	if relic_top_gb == nil then return end
	relic_top_gb:ShowWindow(1)
	
	if result == "SUCCESS" then
		CLEAR_ITEM_CABINET_REINFORCE()
		ITEM_CABINET_CREATE_LIST(frame)
	elseif result == "FAILED" then
		UPDATE_ITEM_CABINET_REINFORCE(frame)
	end
	
end

function CLEAR_ITEM_CABINET_REINFORCE()
	local frame = ui.GetFrame('item_cabinet')
	if frame == nil then return end

	local rresult_gb = GET_CHILD_RECURSIVELY(frame, 'rresult_gb')
	rresult_gb:ShowWindow(0)

	local send_ok_reinforce = GET_CHILD_RECURSIVELY(frame, 'send_ok_reinforce')
	send_ok_reinforce:ShowWindow(0)

	local do_reinforce = GET_CHILD_RECURSIVELY(frame, 'do_reinforce')
	do_reinforce:ShowWindow(1)
	do_reinforce:SetEnable(0)
	
	frame:SetUserValue('GEM_TYPE', 0)

	local discountSet = GET_CHILD_RECURSIVELY(frame, 'rslotlist_discount', 'ui::CSlotSet')
	for i = 0, discountSet:GetSlotCount() - 1 do
		frame:SetUserValue('DISCOUNT_MAT_' .. i, 0)
	end

	local extraMatSet = GET_CHILD_RECURSIVELY(frame, 'rslotlist_extra_mat', 'ui::CSlotSet')
	for i = 0, extraMatSet:GetSlotCount() - 1 do
		frame:SetUserValue('EXTRA_MAT_' .. i, 0)
	end
end

function UPDATE_ITEM_CABINET_REINFORCE(frame)
	if frame == nil then return end

	local rresult_gb = GET_CHILD_RECURSIVELY(frame, 'rresult_gb')
	rresult_gb:ShowWindow(0)
	

	local send_ok_reinforce = GET_CHILD_RECURSIVELY(frame, 'send_ok_reinforce')
	send_ok_reinforce:ShowWindow(0)

	local do_reinforce = GET_CHILD_RECURSIVELY(frame, 'do_reinforce')
	do_reinforce:ShowWindow(1)
	
	ITEM_CABINET_REINFORCE_PRICE_UPDATE(frame,0)	

	local clear_flag = false
	
	local itemType = frame:GetUserIValue("ITEM_TYPE");
	
	if itemType=="None" then return end

	local cabinet_item_cls = GetClassByType("cabinet_relicgem",itemType)
	local gem_lv = ITEM_CABINET_GET_RELICGEM_UPGRADE_ACC_PROP(frame,cabinet_item_cls)
	local misc_name, stone_name = shared_item_relic.get_gem_reinforce_mat_name(tonumber(gem_lv))
	
	local inv_misc = session.GetInvItemByName(misc_name)
	local inv_stone = session.GetInvItemByName(stone_name)

	local stone_discount = 0
	local slotSet = GET_CHILD_RECURSIVELY(frame, 'rslotlist_discount')

	for i = 0, slotSet:GetSelectedSlotCount() - 1 do
		local slot = slotSet:GetSelectedSlot(i)
		local icon = CreateIcon(slot)
		local iconInfo = icon:GetInfo()
		local coupon_item = session.GetInvItemByGuid(iconInfo:GetIESID())
		local prevCnt = frame:GetUserIValue('DISCOUNT_MAT_' .. slot:GetSlotIndex())

		if coupon_item == nil or coupon_item.count < prevCnt then
			clear_flag = true
			break
		end

		local stone = tonumber(slot:GetUserValue("DISCOUNT_STONE"))
		stone_discount = stone_discount + (prevCnt * stone)
	end

	local extraMatSet = GET_CHILD_RECURSIVELY(frame, 'rslotlist_extra_mat')
	for i = 0, extraMatSet:GetSelectedSlotCount() - 1 do
		local slot = extraMatSet:GetSelectedSlot(i)
		local _guid = slot:GetUserValue('ITEM_GUID')
		local mat_item = session.GetInvItemByGuid(_guid)
		local prevCnt = frame:GetUserIValue('EXTRA_MAT_' .. slot:GetSlotIndex())
		if mat_item == nil or mat_item.count < prevCnt then
			clear_flag = true
			break
		end
	end

	local rmat_1 = GET_CHILD_RECURSIVELY(frame, 'rmat_1')
	local rmat_1_slot = GET_CHILD(rmat_1, 'mat_slot', 'ui::CSlot')
	local misc_cnt = rmat_1_slot:GetUserIValue('NEED_COUNT')
	if misc_cnt > 0 and (inv_misc == nil or inv_misc.count < misc_cnt) then
		clear_flag = true
	end
	
	local rmat_2 = GET_CHILD_RECURSIVELY(frame, 'rmat_2')
	local rmat_2_slot = GET_CHILD(rmat_2, 'mat_slot', 'ui::CSlot')
	local stone_cnt = rmat_2_slot:GetUserIValue('NEED_COUNT')
	local inv_cnt = 0

	if inv_stone ~= nil then
		inv_cnt = inv_stone.count
	end

	if stone_cnt > 0 and inv_cnt < stone_cnt - stone_discount then
		clear_flag = true
	end

	if clear_flag == true then		
		ITEM_CABINET_REMOVE_REINFORCE_MAT(frame, rmat_1_slot)
		ITEM_CABINET_REMOVE_REINFORCE_MAT(frame, rmat_2_slot)
	
		local discountSet = GET_CHILD_RECURSIVELY(frame, 'rslotlist_discount', 'ui::CSlotSet')
		for i = 0, discountSet:GetSlotCount() - 1 do
			frame:SetUserValue('DISCOUNT_MAT_' .. i, 0)
		end
	
		local extraMatSet = GET_CHILD_RECURSIVELY(frame, 'rslotlist_extra_mat')
		for i = 0, extraMatSet:GetSlotCount() - 1 do
			frame:SetUserValue('EXTRA_MAT_' .. i, 0)
		end
	end

	ITEM_CABINET_UPDATE_RELIC_GEM_REINF_EXTRA_MAT(frame)
	ITEM_CABINET_UPDATE_REINFORCE_DISCOUNT(frame)
	ITEM_CABINET_RELIC_GEM_REINF_RATE_UPDATE(frame)

end

function ITEM_CABINET_REINFORCE_SECTION(frame,self,cabinetItemCls)
	local curSelected_ClsName = TryGetProp(cabinetItemCls,"ClassName","None")
	local preSelected_ClsName = frame:GetUserValue('PRE_NAME')
	local rresult_gb = GET_CHILD_RECURSIVELY(frame,"rresult_gb")
	rresult_gb:ShowWindow(0)
	
	if curSelected_ClsName ~= preSelected_ClsName then
		ITEM_CABINET_RESET_RELIC_GEM_REINF_MAT_CNT(frame)
	end
	
	if ITEM_CABINET_REINFORCE_IS_AVAILABLE(frame,cabinetItemCls) == false then 
		return 
	end
	
	local curLv		  = ITEM_CABINET_GET_RELICGEM_UPGRADE_ACC_PROP(frame,cabinetItemCls)
	local selectedSlot= GET_CHILD_RECURSIVELY(self:GetParent(),"itemIcon") 
	local iconinfo 	  = selectedSlot:GetIcon():GetInfo()
	local itemCls 	  = GetClassByType('Item',iconinfo.type)
	local relic_top_Left_slot = GET_CHILD_RECURSIVELY(frame,"relic_top_Left_slot")
	local inputIcon   = CreateIcon(relic_top_Left_slot)
	--ICON SET BEGIN--
	inputIcon:SetImage(TryGetProp(itemCls,'Icon'))
	inputIcon:SetTooltipArg('char_belonging',curLv,itemCls.ClassID)
	inputIcon:SetTooltipType('wholeitem_cabinet')
	local relic_top_Left_name = GET_CHILD_RECURSIVELY(frame,"relic_top_Left_name")
	local slotText =  GET_RELIC_GEM_NAME_WITH_FONT(itemCls)
	relic_top_Left_name:SetTextByKey('value',slotText)
	--ICON SET END--
	local gem_id = TryGetProp(itemCls, 'ClassID', 0)
	frame:SetUserValue('GEM_TYPE', gem_id)
	frame:SetUserValue('GEM_LV', curLv)

	local rmat_info = GET_CHILD_RECURSIVELY(frame,"rmat_info")
	local misc_name, stone_name = shared_item_relic.get_gem_reinforce_mat_name(curLv)
	local misc_cnt = shared_item_relic.get_gem_reinforce_mat_misc(curLv)
	local stone_cnt = shared_item_relic.get_gem_reinforce_mat_stone(curLv)
	ITEM_CABINET_MAT_CTRL_UPDATE(frame, 1, misc_name, misc_cnt)
	ITEM_CABINET_MAT_CTRL_UPDATE(frame, 2, stone_name, stone_cnt)

	local silver_cnt  = shared_item_relic.get_gem_reinforce_silver(curLv)
	frame:SetUserValue('REINFORCE_PRICE',silver_cnt)
	ITEM_CABINET_REINFORCE_PRICE_UPDATE(frame,0)	
	ITEM_CABINET_UPDATE_RELIC_GEM_REINF_EXTRA_MAT(frame)
	ITEM_CABINET_UPDATE_REINFORCE_DISCOUNT(frame)
	ITEM_CABINET_RELIC_GEM_REINF_RATE_UPDATE(frame)
	ITEM_CABINET_REINFORCE_EXEC_BTN_UPDATE(frame)
end

function ITEM_CABINET_SELECT_ITEM(parent, self)	
	local frame = parent:GetTopParentFrame();
	local tab = GET_CHILD_RECURSIVELY(frame, "upgrade_tab"); 
	local category = ITEM_CABINET_GET_CATEGORY(parent);

	if category == 'Relicgem' then
		local lvup_scroll = ui.GetFrame('relicgem_lvup_scroll');
		if lvup_scroll ~= nil and lvup_scroll:IsVisible() == 1 then
			RELICGEM_LVUP_SCROLL_SET_TARGET_ITEM_CABINET(cabinetframe, parent:GetUserIValue("ITEM_TYPE"));
			return
		else
			tab = GET_CHILD_RECURSIVELY(frame, "upgrade_relicgem_tab"); 
		end
	end

	local aObj = GetMyAccountObj();							
	local index = tab:GetSelectItemIndex();
	local itemType = parent:GetUserIValue("ITEM_TYPE"); 
	local itemCls = GetClassByType("cabinet_"..string.lower(category), itemType);
	local itemName = itemCls.ClassName; 
	local curLv = TryGetProp(aObj, itemCls.UpgradeAccountProperty, 0);

	frame:SetUserValue("CATEGORY", category);  
	frame:SetUserValue("ITEM_TYPE", itemType); 
	frame:SetUserValue("TARGET_LV", curLv + 1); -- 최초 등록은 0Lv->1Lv

	ITEM_CABINET_CLOSE_SUCCESS(frame);
	ITEM_CABINET_SELECT_TAB(frame, parent); --item_cabinet, parent: ITEM_TAB_CTRL_X
	ITEM_CABINET_REGISTER_SECTION(frame, category, itemType, curLv); --
	ITEM_CABINET_ENCHANT_TEXT_SETTING(frame, category, index);
	ITEM_CABINET_SELECTED_ITEM_CLEAR();
	if category =="Relicgem" then
		ITEM_CABINET_REINFORCE_SECTION(frame,self, itemCls);
		local clsName= TryGetProp(itemCls,"ClassName","None")
		frame:SetUserValue('PRE_NAME',clsName)
		local checkVal = frame:GetUserValue('END_RELIC_GEM_REINFORCE')
		if checkVal ~= "None" then CONFIRM_ITEM_CABINET_REINFORCE() end
	end
	ITEM_CABINET_SHOW_UPGRADE_UI(frame, 1);
	ITEM_CABINET_ICOR_SECTION(frame, self, itemCls);


	local tuto_prop = frame:GetUserValue('TUTO_PROP')
	if tuto_prop ~= 'None' then
		local tuto_flag = false
		local tuto_value = GetUITutoProg(tuto_prop)
		if tuto_value == 0 then
			tuto_flag = true
		elseif tuto_prop == 'UITUTO_EQUIPCACABINET1' and tuto_value == 5 then
			tuto_flag = true
		end
		if tuto_flag == true then
			pc.ReqExecuteTx('SCR_UI_TUTORIAL_NEXT_STEP', tuto_prop)
		end
	end
end

function ITEM_CABINET_ICOR_SECTION(frame, self, entry_cls)
	local topframe = frame:GetTopParentFrame()
	local category = frame:GetUserValue("CATEGORY")
	local itemslot = GET_CHILD_RECURSIVELY(self:GetParent(), "itemIcon");
	local iconinfo = itemslot:GetIcon():GetInfo();
	
	local itemCls = GetClassByType('Item', iconinfo.type); 
	itemslot = GET_CHILD_RECURSIVELY(frame,"slot2");
	local icon = CreateIcon(itemslot);
	icon:SetImage(TryGetProp(itemCls, 'Icon'));
	icon:ClearText()
	if category=="Relicgem" then
		local curlv   = ITEM_CABINET_GET_RELICGEM_UPGRADE_ACC_PROP(topframe,itemCls)
		itemslot:EnableHitTest(0)	
		icon:SetTooltipArg('char_belonging',curlv,itemCls.ClassID)
		icon:SetTooltipType('wholeitem_cabinet'); -- at tooltipset.xml 		
		if curlv~=nil and curlv > 0 then
			icon:SetText("Lv."..curlv,"quickiconfont",ui.RIGHT,ui.BOTTOM,-2,1)
		else
			icon:SetText(ClMsg("IsNotRegistered"),"quickiconfont",ui.RIGHT,ui.BOTTOM,-2,1)
		end	
	else
		icon:SetTooltipNumArg(itemCls.ClassID);
		icon:SetTooltipStrArg('char_belonging')		
		icon:SetTooltipType('wholeitem');
	end

	local optionGbox = GET_CHILD_RECURSIVELY(frame, "optionGbox_1")
	optionGbox:RemoveChild('tooltip_equip_property_narrow')
	optionGbox:RemoveChild('item_tooltip_ark')
	optionGbox:RemoveChild('tooltip_ark_lv')

	local silverText = GET_CHILD_RECURSIVELY(frame,"pricetxt");
	
	local cost = tonumber(entry_cls.MakeCostSilver)
	if category == 'Accessory' then		
		cost = GET_ACC_CABINET_COST(entry_cls, GetMyAccountObj())
	end

	if IS_SEASON_SERVER() == 'YES' then
		cost = cost * 0.01
	end
	local price = cost
	if cost > 100 then
		price = GET_COMMA_SEPARATED_STRING_FOR_HIGH_VALUE(cost);	
	end
	
	silverText:SetTextByKey("price", price);
	
	ITEM_CABINET_OPTION_INFO(optionGbox, itemCls)
end

function ITEM_CABINET_SELECT_TAB(frame, tab)
	local prevTabName = frame:GetUserValue("SELECTED_TAB");
	if prevTabName ~= "None" then
		local prevTab = GET_CHILD_RECURSIVELY(frame, prevTabName);
		local select = GET_CHILD_RECURSIVELY(prevTab, "select");
		select:ShowWindow(0);
	end
	local select = GET_CHILD_RECURSIVELY(tab, "select");
	select:ShowWindow(1);
	frame:SetUserValue("SELECTED_TAB", tab:GetName());
end


--컨트롤셋 생성 및 인챈트 탭 환경 구성하기
function ITEM_CABINET_ENCHANT_TEXT_SETTING(frame, category, index)
	if category == "Relicgem" then
		local enchantbtn =GET_CHILD_RECURSIVELY(frame,"enchantbtn");
		local upgrade_relicgem_tab = GET_CHILD_RECURSIVELY(frame,"upgrade_relicgem_tab")
		enchantbtn:SetTextByKey("name",ClMsg("Create"));
		upgrade_relicgem_tab:ChangeCaptionOnly(0,"{@st66b}{s16}"..ClMsg("Create"),false)
		upgrade_relicgem_tab:ChangeCaptionOnly(1,"{@st66b}{s16}"..ClMsg("Reinforce_2"),false)
		if index == 0 then
			GET_CHILD_RECURSIVELY(frame,"slot"):ShowWindow(0);
			enchantbtn:SetEventScript(ui.LBUTTONUP, "ITEM_CABINET_EXCUTE_CREATE");
		end
	else
		local enchantbtn = GET_CHILD_RECURSIVELY(frame,"enchantbtn");
		local upgrade_tab = GET_CHILD_RECURSIVELY(frame, 'upgrade_tab');
		if category == "Weapon" or category == "Armor" or category == "Artefact" then
			enchantbtn:SetTextByKey("name", ClMsg("Enchant"));
			
			local tab_name = "None"
			if category == "Artefact" then
				tab_name = ClMsg("Briquetting")
			else
				tab_name = ClMsg("IcorEnchant")
			end
			upgrade_tab:ChangeCaptionOnly(0,"{@st66b}{s16}"..tab_name,false)
			
			if index == 0 then
				GET_CHILD_RECURSIVELY(frame,"slot"):ShowWindow(1);
				enchantbtn:SetEventScript(ui.LBUTTONUP, "ITEM_CABINET_EXCUTE_ENCHANT");
			end
		else
			enchantbtn:SetTextByKey("name", ClMsg("Create"));
			upgrade_tab:ChangeCaptionOnly(0,"{@st66b}{s16}"..ClMsg("Create"),false)
			if index == 0 then
				GET_CHILD_RECURSIVELY(frame,"slot"):ShowWindow(0);
				enchantbtn:SetEventScript(ui.LBUTTONUP, "ITEM_CABINET_EXCUTE_CREATE");
			end
		end
	end
end

function ITEM_CABINET_GET_CATEGORY(frame)
	local frame = frame:GetTopParentFrame();
	local tab = GET_CHILD_RECURSIVELY(frame, "cabinet_tab");
	local index = tab:GetSelectItemIndex();
	local category_list = { "Weapon", "Armor", "Accessory", "Ark", "Skillgem", "Relicgem", "Artefact"} 

	return category_list[index + 1];
end


function ITEM_CABINET_UPGRADE_RELICGEM_TAB(parent,ctrl)
	local frame = parent:GetTopParentFrame();
	local tab = GET_CHILD_RECURSIVELY(frame, "upgrade_relicgem_tab");
	local index = tab:GetSelectItemIndex();
	local category = frame:GetUserValue("CATEGORY");
	local isAvailableReinforce = frame:GetUserValue("REINFORCE");
	GET_CHILD_RECURSIVELY(frame,"upgradegbox"):ShowWindow(0); 
	GET_CHILD_RECURSIVELY(frame,"registerbtn"):ShowWindow(0); 
	GET_CHILD_RECURSIVELY(frame,"infotxt"):ShowWindow(0);
	GET_CHILD_RECURSIVELY(frame,"next_item_gb"):ShowWindow(0);
	GET_CHILD_RECURSIVELY(frame,"acctxt"):ShowWindow(0);
	GET_CHILD_RECURSIVELY(frame,"belongingtxt"):ShowWindow(0);
	GET_CHILD_RECURSIVELY(frame,"slot"):ShowWindow(0);
	GET_CHILD_RECURSIVELY(frame,"slot2"):ShowWindow(0);
	GET_CHILD_RECURSIVELY(frame,"relic_upgradeBg"):ShowWindow(0);
	
	if index ==0 then
		GET_CHILD_RECURSIVELY(frame,"enchantbtn"):ShowWindow(1);
		GET_CHILD_RECURSIVELY(frame,"pricetxt"):ShowWindow(1);
		GET_CHILD_RECURSIVELY(frame,"optionGbox"):ShowWindow(1);
		ITEM_CABINET_ENCHANT_TEXT_SETTING(frame, category, index);

		GET_CHILD_RECURSIVELY(frame,"slot2"):ShowWindow(1);
		GET_CHILD_RECURSIVELY(frame,"belongingtxt"):ShowWindow(1);

		INVENTORY_SET_CUSTOM_RBTNDOWN("None");

		ITEM_CABINET_SELECTED_ITEM_CLEAR();
	elseif index==1 then
		GET_CHILD_RECURSIVELY(frame,"enchantbtn"):ShowWindow(0); 
		GET_CHILD_RECURSIVELY(frame,"pricetxt"):ShowWindow(0); 
		GET_CHILD_RECURSIVELY(frame,"optionGbox"):ShowWindow(0);
		if isAvailableReinforce=="true" then
			INVENTORY_SET_CUSTOM_RBTNDOWN('ITEM_CABINET_REINFORCE_INV_RBTN')
			GET_CHILD_RECURSIVELY(frame,"relic_upgradeBg"):ShowWindow(1);
		end	
	elseif index==2 then
		GET_CHILD_RECURSIVELY(frame,"upgradegbox"):ShowWindow(1); 
		GET_CHILD_RECURSIVELY(frame,"registerbtn"):ShowWindow(1); 
		GET_CHILD_RECURSIVELY(frame,"infotxt"):ShowWindow(1);
		GET_CHILD_RECURSIVELY(frame,"next_item_gb"):ShowWindow(1);

		GET_CHILD_RECURSIVELY(frame,"enchantbtn"):ShowWindow(0); 
		GET_CHILD_RECURSIVELY(frame,"pricetxt"):ShowWindow(0); 
		GET_CHILD_RECURSIVELY(frame,"optionGbox"):ShowWindow(0);
	
		local max = GET_CHILD_RECURSIVELY(frame, 'registerbtn'):GetTextByKey("name");		
		if max == "MAX" then
			GET_CHILD_RECURSIVELY(frame,"next_item_gb"):ShowWindow(0);
			INVENTORY_SET_CUSTOM_RBTNDOWN("None");
		else
			INVENTORY_SET_CUSTOM_RBTNDOWN("ITEM_CABINET_MATERIAL_INV_BTN");
		end
	end
	ITEM_CABINET_CLEAR_SLOT();

end


function ITEM_CABINET_UPGRADE_TAB(parent, ctrl)
	local frame = parent:GetTopParentFrame();
	local tab = GET_CHILD_RECURSIVELY(frame, "upgrade_tab");
	local index = tab:GetSelectItemIndex();
	local category = frame:GetUserValue("CATEGORY");
	GET_CHILD_RECURSIVELY(frame,"upgradegbox"):ShowWindow(index); --생성 아닌 곳
	GET_CHILD_RECURSIVELY(frame,"registerbtn"):ShowWindow(index); 
	GET_CHILD_RECURSIVELY(frame,"infotxt"):ShowWindow(index);
	GET_CHILD_RECURSIVELY(frame,"next_item_gb"):ShowWindow(index);
	GET_CHILD_RECURSIVELY(frame,"acctxt"):ShowWindow(0);
	GET_CHILD_RECURSIVELY(frame,"belongingtxt"):ShowWindow(0);
	GET_CHILD_RECURSIVELY(frame,"slot"):ShowWindow(0);
	GET_CHILD_RECURSIVELY(frame,"slot2"):ShowWindow(0);

	if index == 1 then 
		GET_CHILD_RECURSIVELY(frame,"enchantbtn"):ShowWindow(0); --생성
		GET_CHILD_RECURSIVELY(frame,"pricetxt"):ShowWindow(0); --생성
		GET_CHILD_RECURSIVELY(frame,"optionGbox"):ShowWindow(0); --생성

		if category == "Accessory" then
			GET_CHILD_RECURSIVELY(frame,"acctxt"):ShowWindow(1);
		end

		local max = GET_CHILD_RECURSIVELY(frame, 'registerbtn'):GetTextByKey("name");		
		if max == "MAX" then
			GET_CHILD_RECURSIVELY(frame,"next_item_gb"):ShowWindow(0);
			INVENTORY_SET_CUSTOM_RBTNDOWN("None");
		else
			INVENTORY_SET_CUSTOM_RBTNDOWN("ITEM_CABINET_MATERIAL_INV_BTN");
		end

	elseif index == 0 then 
		GET_CHILD_RECURSIVELY(frame,"enchantbtn"):ShowWindow(1);
		GET_CHILD_RECURSIVELY(frame,"pricetxt"):ShowWindow(1);
		GET_CHILD_RECURSIVELY(frame,"optionGbox"):ShowWindow(1);

		ITEM_CABINET_ENCHANT_TEXT_SETTING(frame, category, index);

		if category == "Weapon" or category == "Armor" or category == "Artefact" then
			local inven = ui.GetFrame('inventory');
			if inven:IsVisible() == 0 then inven:ShowWindow(1); end

			GET_CHILD_RECURSIVELY(frame,"slot"):ShowWindow(1);		
			INVENTORY_SET_CUSTOM_RBTNDOWN("ITEM_CABINET_INV_BTN");
		else
			GET_CHILD_RECURSIVELY(frame,"slot2"):ShowWindow(1);
			GET_CHILD_RECURSIVELY(frame,"belongingtxt"):ShowWindow(1);
			INVENTORY_SET_CUSTOM_RBTNDOWN("None");
		end

		ITEM_CABINET_SELECTED_ITEM_CLEAR();
	end
	ITEM_CABINET_CLEAR_SLOT();

	if ctrl ~= nil then
		local tuto_prop = frame:GetUserValue('TUTO_PROP')
		if tuto_prop ~= 'None' then
			local tuto_flag = false
			local tuto_value = GetUITutoProg(tuto_prop)
			if tuto_value == 1 then
				tuto_flag = true
			elseif tuto_prop == 'UITUTO_EQUIPCACABINET1' and tuto_value == 6 then
				tuto_flag = true
			end

			if tuto_flag == true then
				pc.ReqExecuteTx('SCR_UI_TUTORIAL_NEXT_STEP', tuto_prop)
			end
		end
	end
end

function ITEM_CABINET_REGISTER_SECTION(frame, category, itemType, curLv)
	local aObj = GetMyAccountObj();
	local itemCls = GetClassByType("cabinet_"..string.lower(category), itemType);
	local itemName = itemCls.ClassName;
	local isRegister = TryGetProp(aObj, itemCls.AccountProperty, 0); 
	local maxLv = itemCls.MaxUpgrade;
	local registerBtn = GET_CHILD_RECURSIVELY(frame, 'registerbtn');
	local upgradeTab = GET_CHILD_RECURSIVELY(frame, 'upgrade_tab');
	local upgrade_relicgem_tab = GET_CHILD_RECURSIVELY(frame,'upgrade_relicgem_tab');
	registerBtn:SetTextByKey("name", "MAX");
	registerBtn:SetEnable(0);	
	GET_CHILD_RECURSIVELY(frame, "upgradegbox"):RemoveAllChild(); 
	if (category == "Weapon" or category == "Armor" or category == 'Accessory') and maxLv ~= 1 then		
		if curLv == maxLv and isRegister == 1 then 
			upgradeTab:ChangeCaptionOnly(1,"{@st66b}{s16}"..ClMsg("Upgrade"),false)
			return;
		end
	elseif category =="Relicgem" then
		upgrade_relicgem_tab:ChangeCaptionOnly(2,"{@st66b}{s16}"..ClMsg("Register"),false)
		if curLv== maxLv and isRegister == 1 then
			return;
		end
	else
		if isRegister == 1 then
			upgradeTab:ChangeCaptionOnly(1,"{@st66b}{s16}"..ClMsg("Register"),false)
			return;
		end
	end
	
	registerBtn:SetEnable(1);
	
	
	local materialTable = GET_REGISTER_MATERIAL(category, itemName, curLv+1);
	
	ITEM_CABINET_DRAW_MATERIAL(frame, materialTable, curLv+1, maxLv);
end


function ITEM_CABINET_EXCUTE_REGISTER(parent, self)
	
	local frame = parent:GetTopParentFrame()
	local cabinet_tab = GET_CHILD_RECURSIVELY(frame,"cabinet_tab")
	local cabinet_tabItem_index = cabinet_tab:GetSelectItemIndex() 
	local selectIndex = 0
	for k,v in pairs(g_selectedItem) do
		selectIndex = selectIndex + 1
	end
	
	local mat_count = 0 
	for _, v in pairs(g_materialItem) do
		for k, v1 in pairs(v) do 
			if k == 'name' then
				if v1 ~= 'Vis' and IS_ACCOUNT_COIN(v1) == false then
					mat_count = mat_count +1
				end
			end
		end
	end

	if selectIndex ~= mat_count then
		ui.SysMsg(ClMsg('Auto_JaeLyoKa_BuJogHapNiDa.'))
		return
	end
	local clmsg;
	if cabinet_tabItem_index==4 then
		clmsg = ClMsg('ReallyRegisterForCabinet_Skillgem')
	elseif cabinet_tabItem_index==5 then
		clmsg = ClMsg('ReallyRegisterForCabinet_Relicgem')
	elseif cabinet_tabItem_index==6 then
		clmsg = ClMsg('ReallyRegisterForCabinet_Artefact')
	else 
		clmsg = ClMsg('ReallyRegisterForCabinet')
	end
	local msgbox = ui.MsgBox(clmsg, '_ITEM_CABINET_EXCUTE_REGISTER()', 'None')
	SET_MODAL_MSGBOX(msgbox)
end

--
function _ITEM_CABINET_EXCUTE_REGISTER()
	local frame = ui.GetFrame('item_cabinet')
	session.ResetItemList();
	local selectIndex = 0
	for k,v in pairs(g_selectedItem) do
		session.AddItemID(k, v);
		selectIndex = selectIndex + 1;
	end
	local category = frame:GetUserValue("CATEGORY");
	local itemType = frame:GetUserIValue("ITEM_TYPE");
	local targetLv = frame:GetUserIValue("TARGET_LV");
	local itemCls = GetClassByType("cabinet_"..string.lower(category), itemType);
	local itemGuid = frame:GetUserValue("ITEM_REG_GUID");
	local itemName = itemCls.ClassName;
	local mat_count = 0
	for _, v in pairs(g_materialItem) do
		for k, v1 in pairs(v) do
			if k == 'name' then
				if v1 ~= 'Vis' and IS_ACCOUNT_COIN(v1) == false then
					mat_count = mat_count +1
				end
			end
		end
	end
	
	if selectIndex ~= mat_count then
		ui.SysMsg(ClMsg('Auto_JaeLyoKa_BuJogHapNiDa.'))
		return;
	end

	local argStrList = NewStringList();
    argStrList:Add(category);
	argStrList:Add(itemType);
	argStrList:Add(targetLv);
	argStrList:Add(itemGuid);
	
	local resultlist = session.GetItemIDList();
	item.DialogTransaction("REGISTER_CABINET_ITEM", resultlist, '', argStrList);
	
end

local function SORT_BY_NAME(a, b)
	return a.name < b.name;
end

function ITEM_CABINET_DRAW_MATERIAL(frame, materialTable, targetLV, maxLv)	
	local gbox = GET_CHILD_RECURSIVELY(frame, "upgradegbox");
	local registerBtn = GET_CHILD_RECURSIVELY(frame, "registerbtn");
	local registerTxt = GET_CHILD_RECURSIVELY(frame, "registertxt");
	local upgrade_tab = GET_CHILD_RECURSIVELY(frame, 'upgrade_tab');
	local next_item_txt = GET_CHILD_RECURSIVELY(frame, 'next_item_txt');

	local pc = GetMyPCObject();
	local aObj = GetMyAccountObj();

	local clMsg = "" 
	if targetLV > 1 and maxLv ~= 1 then
		clMsg = ClMsg("Upgrade")
	else
		clMsg = ClMsg("Register")
	end

	registerBtn:SetTextByKey("name", clMsg);
	next_item_txt:SetTextByKey("name", clMsg);
	upgrade_tab:ChangeCaptionOnly(1,"{@st66b}{s16}"..clMsg,false)

	local category = frame:GetUserValue("CATEGORY");
	local itemType = frame:GetUserIValue("ITEM_TYPE");
	local targetItemCls = GetClassByType("cabinet_"..string.lower(category), itemType);
	local itemClsName = ""

	local get_name_func = _G[TryGetProp(targetItemCls, 'GetUpgradeItemFunc', 'None')];
	if get_name_func ~= nil then 
		itemClsName = get_name_func(targetItemCls, targetLV); --Relicgem GET_UPGRADE_CABINET_ITEM_NAME
	else
		itemClsName = targetItemCls.ClassName
	end

	local next_item_cls = GetClass("Item", itemClsName)
	local next_item_txt = GET_CHILD_RECURSIVELY(frame, 'next_item_name');
	
	local slot = GET_CHILD_RECURSIVELY(frame, 'slot_reg');
	local icon = CreateIcon(slot);
	icon:SetImage(next_item_cls.Icon);
	
	if category=="Relicgem" then
		next_item_txt:SetTextByKey("name", next_item_cls.Name.." (".. ClMsg("LevelOfRegisterGem") ..")")
		slot:EnableHitTest(0)
	elseif category == "Artefact" then
		next_item_txt:SetTextByKey("name", next_item_cls.Name)
		slot:EnableHitTest(0)
	else
		slot:EnableHitTest(1)
		next_item_txt:SetTextByKey("name", next_item_cls.Name)
		icon:SetTooltipNumArg(next_item_cls.ClassID);
		icon:SetTooltipStrArg('char_belonging');
		icon:SetTooltipType('wholeitem')
	end

	g_materialItem = {}
	if materialTable==nil then
		return
	end
	for k,v in pairs(materialTable) do
		
		local sortedMaterial = {}
		sortedMaterial.name = k;
		sortedMaterial.count = v;
		table.insert(g_materialItem, sortedMaterial);
	end
	table.sort(g_materialItem, SORT_BY_NAME)

	local index = 1;
	for i = 1, #g_materialItem do
		local ctrlSet = gbox:CreateOrGetControlSet("eachmaterial_in_item_cabinet", "ITEM_CABINET_MAT"..index, 0, (index - 1) * 40);
		if ctrlSet ~= nil then
			local icon = GET_CHILD_RECURSIVELY(ctrlSet, "material_icon", "ui::CPicture");
			local questionmark = GET_CHILD_RECURSIVELY(ctrlSet, "material_questionmark", "ui::CPicture");
			local name = GET_CHILD_RECURSIVELY(ctrlSet, "material_name", "ui::CRichText");
			local count = GET_CHILD_RECURSIVELY(ctrlSet, "material_count", "ui::CRichText");
			local grade = GET_CHILD_RECURSIVELY(ctrlSet, "grade", "ui::CRichText");
			icon:ShowWindow(1);
			count:ShowWindow(1);
			questionmark:ShowWindow(0);

			local _name = g_materialItem[i].name
			local real_name = StringSplit(_name, '__')[1]
			if real_name ~= nil then
				_name = real_name
			end
			local materialCls = GetClass("Item", _name);
			if materialCls ~= nil and g_materialItem[i].count > 0 then
				count:SetTextByKey("color", "{#EE0000}");
				count:SetTextByKey("curCount", 0);
				count:SetTextByKey("needCount", g_materialItem[i].count);

				local add_str = ''
				if TryGetProp(materialCls, 'AdditionalOption_1', 'None') ~= 'None' then					
					add_str = '(' ..  ClMsg('Unique1') .. ')'
				end

				name:SetText(materialCls.Name .. add_str);
				icon:SetImage(materialCls.Icon);
			elseif materialCls == nil and g_materialItem[i].count > 0 then
				local curCoinCount = TryGetProp(aObj, _name, '0');
				if curCoinCount == "None" then
					curCoinCount = '0'
				end
				if math.is_larger_than(g_materialItem[i].count, curCoinCount) == 1 then
					count:SetTextByKey("color", "{#EE0000}");
				else
					count:SetTextByKey("color", nil);							
				end
				count:SetTextByKey("curCount", curCoinCount);
				count:SetTextByKey("needCount", g_materialItem[i].count);

				local coinCls = GetClass("accountprop_inventory_list", _name);
				name:SetText(ClMsg(_name));
				icon:SetImage(coinCls.Icon);
			end
			index = index + 1;
	 	end
	end
	local inven = ui.GetFrame('inventory');
	if inven:IsVisible() == 0 then inven:ShowWindow(1); end
end

function ITEM_CABINET_MATERIAL_INV_BTN(itemObj, slot)	
	
	if slot:IsSelected() == 1 then
		ITEM_CABINET_SET_SLOT_ITEM(slot, 0);
		ITEM_CABINET_RESET_SLOT_TOOLTIP(itemObj)
	else		
		local frame = ui.GetFrame("item_cabinet");
		if frame == nil then
			return;
		end		
		ITEM_CABINET_REG_MATERIAL(frame, slot);
	end
end

function ITEM_CABINET_RESET_SLOT_TOOLTIP(itemObj)
	local frame = ui.GetFrame("item_cabinet");
	local slot = GET_CHILD_RECURSIVELY(frame, 'slot_reg');
	if slot~=nil then
		local target_icon = slot:GetIcon() 
		target_icon:SetTooltipArg('char_belonging',0,itemObj.ClassID)
	end
end

function ITEM_CABINET_REG_MATERIAL(frame, slot)	
	local icon = slot:GetIcon();
	local iconInfo = icon:GetInfo();
	local itemID = iconInfo:GetIESID();

	if ui.CheckHoldedUI() == true then
		return;
	end

	local invItem = session.GetInvItemByGuid(itemID);
	if invItem == nil then
		return;
	end

	local itemObj = GetIES(invItem:GetObject());

	local itemCls = GetClassByType('Item', itemObj.ClassID);
	local aObj = GetMyPCObject();
	
	if GetMyPCObject() == nil then
		return;
	end

	local invframe = ui.GetFrame("inventory");
	if true == invItem.isLockState or true == IS_TEMP_LOCK(invframe, invItem) then
		ui.SysMsg(ClMsg("MaterialItemIsLock"));
		return;
	end

	local category = frame:GetUserValue("CATEGORY");
	local itemType = frame:GetUserIValue("ITEM_TYPE");
	local targetLv = frame:GetUserIValue("TARGET_LV");
	local targetItemCls = GetClassByType("cabinet_"..string.lower(category), itemType);
	local itemName = targetItemCls.ClassName
	if category=="Skillgem" or category=="Relicgem" then
		if IS_RANDOM_OPTION_SKILL_GEM(itemObj) then 
			ui.SysMsg(ClMsg('CantUseCabinetCuzRandomOption'))
			return 
		end
		local belonging = TryGetProp(itemObj,"CharacterBelonging",-1)
		if belonging==1 then 
			ui.SysMsg(ClMsg('CantUseCabinetCuzCopiedGem'))
			return 		
		end
		frame:SetUserValue("ITEM_REG_GUID",itemID)
	end

	if category=="Relicgem" and itemName==TryGetProp(itemObj,"ClassName","None") then
		local gemLv	 = TryGetProp(itemObj,"GemLevel",0)
		targetLv = ITEM_CABINET_GET_RELICGEM_UPGRADE_ACC_PROP(frame,itemObj)
		if TryGetProp(itemObj,"CharacterBelonging",0)==1 then
			ui.SysMsg(ClMsg("CantUseCabinetCuzCopiedGem"))
			return
		end
		if gemLv<=targetLv then
			ui.SysMsg(ClMsg("InvalidGemNeedUpperLevel"))
			return
		end		
		frame:SetUserValue("TARGET_LV",gemLv)
		local slot = GET_CHILD_RECURSIVELY(frame, 'slot_reg');
		local nextgem_icon = slot:GetIcon() 
		nextgem_icon:SetTooltipArg('char_belonging',gemLv,itemObj.ClassID)
	end

	for index = 1, #g_materialItem do
		local _name = g_materialItem[index].name
		local real_name = StringSplit(_name, '__')[1]
		if real_name ~= nil then
			_name = real_name
		end
		local materialCls = GetClass("Item", _name);
		local item_name = itemCls.ClassName
		if TryGetProp(itemObj, 'GroupName', 'None')	== 'Icor' then
			item_name = TryGetProp(itemObj, 'InheritanceItemName', 'None')
		end
		
		if TryGetProp(materialCls ,'ClassName', 'None') == item_name then 			
			if g_materialItem[index].count > 1 then				
				ITEM_CABINET_INPUT_MATERIAL_CNT_BOX(invItem, index, itemID, slot);
				return;
			else
				local materialCtrl = GET_CHILD_RECURSIVELY(ui.GetFrame("item_cabinet"), "ITEM_CABINET_MAT"..index);
				local materialCount = GET_CHILD_RECURSIVELY(materialCtrl, "material_count");
				local curCount = tonumber(materialCount:GetTextByKey("curCount"));
				if curCount == 0 then
					ITEM_CABINET_MATERIAL_CNT_UPDATE(index, 1, itemID);				
					ITEM_CABINET_SET_SLOT_ITEM(slot, 1, index);
					local tuto_prop = frame:GetUserValue('TUTO_PROP')
					if tuto_prop ~= 'None' then
						local tuto_value = GetUITutoProg(tuto_prop)
						if tuto_prop == 'UITUTO_EQUIPCACABINET1' and tuto_value == 2 then
							pc.ReqExecuteTx('SCR_UI_TUTORIAL_NEXT_STEP', tuto_prop)
						end
					end
					return
				end
			end			
		end
		index = index + 1
	end
end

function ITEM_CABINET_INPUT_MATERIAL_CNT_BOX(invItem, index, guid, slot)
    local titleText = ScpArgMsg("INPUT_CNT_D_D", "Auto_1", 1, "Auto_2", invItem.count);
    local inputstringframe = ui.GetFrame("inputstring");
	inputstringframe:SetUserValue("CTRL_INDEX", index);
	inputstringframe:SetUserValue("GUID", guid);
	inputstringframe:SetUserValue("SLOT_CATE", slot:GetParent():GetName());
	inputstringframe:SetUserValue("SLOT_NAME", slot:GetName());

	INPUT_NUMBER_BOX(inputstringframe, titleText, "ITEM_CABINET_INPUT_MATERIAL_CONFIRM", 1, 1, invItem.count, 1);	
end

function ITEM_CABINET_INPUT_MATERIAL_CONFIRM(parent, count)
	local index = parent:GetUserValue("CTRL_INDEX");
	local guid = parent:GetUserValue("GUID"); 
	local slotCate = parent:GetUserValue("SLOT_CATE")
	local slotName = parent:GetUserValue("SLOT_NAME"); 
	ITEM_CABINET_MATERIAL_CNT_UPDATE(index, count, guid);
	
	local frame = ui.GetFrame("inventory")
	local slotParent = GET_CHILD_RECURSIVELY(frame, slotCate)
	local slot = GET_CHILD_RECURSIVELY(slotParent, slotName)

	if slot ~= nil then
		ITEM_CABINET_SET_SLOT_ITEM(slot, 1, index);		
	end
end

function ITEM_CABINET_MATERIAL_CNT_UPDATE(index, count, guid)
	local frame = ui.GetFrame("item_cabinet")
	local materialCtrl = GET_CHILD_RECURSIVELY(frame, "ITEM_CABINET_MAT"..index);
	local materialCount = GET_CHILD_RECURSIVELY(materialCtrl, "material_count");
	local curCount = tonumber(materialCount:GetTextByKey("curCount"));
	local needCount = tonumber(materialCount:GetTextByKey("needCount"));
	count = tonumber(count);

	if curCount + count < needCount then
		curCount = curCount + count
		materialCount:SetTextByKey("color", "{#EE0000}");
	else
		curCount = needCount
		materialCount:SetTextByKey("color", nil);
		g_selectedItem[guid] = curCount;
	end
	materialCount:SetTextByKey("curCount",curCount);
end

function ITEM_CABINET_CLEAR_SLOT()
	if ui.CheckHoldedUI() == true then
		return;
	end
	local frame = ui.GetFrame("item_cabinet");
	local slot = GET_CHILD_RECURSIVELY(frame, "slot");
	slot:ClearIcon();
end

function ITEM_CABINET_INV_BTN(itemObj, slot)
	local frame = ui.GetFrame("item_cabinet");
	if frame == nil then
		return;
	end
	local icon = slot:GetIcon();
	local iconInfo = icon:GetInfo();
	ITEM_CABINET_REG_ADD_ITEM(frame, iconInfo:GetIESID());
end


function ITEM_CABINET_ADD_ITEM_DROP(parent, self, argStr, argNum)
	if ui.CheckHoldedUI() == true then
		return;
	end
	local liftIcon = ui.GetLiftIcon();
	local FromFrame = liftIcon:GetTopParentFrame();
	if FromFrame:GetName() == 'inventory' then
		local iconInfo = liftIcon:GetInfo();
		ITEM_CABINET_REG_ADD_ITEM(parent, iconInfo:GetIESID(), self:GetName());
	end
end

function ITEM_CABINET_SET_SLOT_ITEM(slot, isSelect, index)	
	slot = AUTO_CAST(slot);
	if isSelect == 1 then
		slot:SetSelectedImage('socket_slot_check');
		slot:Select(1);
		slot:SetUserValue("INDEX", index);
	else
		local icon = slot:GetIcon();
		local iconInfo = icon:GetInfo();
		local itemID = iconInfo:GetIESID();

		slot:Select(0);
		index = slot:GetUserValue("INDEX");
		if index == "None" then
			return;
		end
		local frame = ui.GetFrame("item_cabinet");
		local materialCtrl = GET_CHILD_RECURSIVELY(frame, "ITEM_CABINET_MAT"..index);
		local materialCount = GET_CHILD_RECURSIVELY(materialCtrl, "material_count");
		materialCount:SetTextByKey("color", "{#EE0000}");
		materialCount:SetTextByKey("curCount", 0);	
		CANCEL_CABINET_SET_SLOT_ITEM(itemID)		
	end
end

function table.removeKey(table, key)
    local element = table[key]
    table[key] = nil
    return element
end

function CANCEL_CABINET_SET_SLOT_ITEM(itemID)
	table.removeKey(g_selectedItem, itemID)
	SELECT_INV_SLOT_BY_GUID(itemID, 0);
end

function ITEM_CABINET_SELECTED_ITEM_CLEAR()
	for k,v in pairs(g_selectedItem) do
		SELECT_INV_SLOT_BY_GUID(k, 0);
	end
	g_selectedItem = {}
end

function ITEM_CABINET_REG_ADD_ITEM(frame, itemID)
	if ui.CheckHoldedUI() == true then
		return;
	end

	local invItem = session.GetInvItemByGuid(itemID);
	if invItem == nil then
		return;
	end

	local itemObj = GetIES(invItem:GetObject());
	local itemCls = GetClassByType('Item', itemObj.ClassID);
	local aObj = GetMyAccountObj();
	
	if GetMyPCObject() == nil then
		return;
	end

	local category = frame:GetUserValue("CATEGORY");
	local itemType = frame:GetUserIValue("ITEM_TYPE");
	local ret, clmsg, msg = CHECK_ENCHANT_VALIDATION(itemObj, category, itemType, aObj);
	if ret == false then
		if msg ~= nil then
			ui.SysMsg(msg);
		else
			ui.SysMsg(ClMsg(clmsg));
		end
		return;
	end

	local invframe = ui.GetFrame("inventory");
	if true == invItem.isLockState or true == IS_TEMP_LOCK(invframe, invItem) then
		ui.SysMsg(ClMsg("MaterialItemIsLock"));
		return;
	end

	local slot = GET_CHILD_RECURSIVELY(frame, 'slot');
	local icon = slot:GetIcon();
	if icon ~= nil then
		icon:SetColorTone("FFFFFFFF");
	end
	SET_SLOT_ITEM(slot, invItem);
	session.ResetItemList();
	session.AddItemID(itemID, 1);

	local tuto_prop = frame:GetUserValue('TUTO_PROP')
	if tuto_prop ~= 'None' then
		local tuto_flag = false
		local tuto_value = GetUITutoProg(tuto_prop)
		if tuto_prop == 'UITUTO_EQUIPCACABINET1' and tuto_value == 7 then
			tuto_flag = true
		elseif (tuto_prop == 'UITUTO_EQUIPCACABINET2' or tuto_prop == 'UITUTO_EQUIPCACABINET3') and tuto_value == 2 then
			tuto_flag = true
		end

		if tuto_flag == true then
			pc.ReqExecuteTx('SCR_UI_TUTORIAL_NEXT_STEP', tuto_prop)
		end
	end
end


function ITEM_CABINET_EXCUTE_ENCHANT(parent, self)
	local frame = parent:GetTopParentFrame();
    local argStrList = NewStringList();
	local category = frame:GetUserValue("CATEGORY");
	local itemType = frame:GetUserIValue("ITEM_TYPE");
	argStrList:Add(category);
	argStrList:Add(itemType);
  	local resultlist = session.GetItemIDList(); 
    item.DialogTransaction("ENCHANT_GODDESS_ITEM", resultlist, '', argStrList);	 
end


function ITEM_CABINET_SUCCESS_GODDESS_ENCHANT(frame, msg, argStr, argNum)
	ITEM_CABINET_SHOW_UPGRADE_UI(frame, 0);
	ITEM_CABINET_CREATE_LIST(frame);
	ITEM_CABINET_SELECTED_ITEM_CLEAR();
	INVENTORY_SET_CUSTOM_RBTNDOWN("None");
	session.ResetItemList();
	imcSound.ReleaseSoundEvent("sys_transcend_success");
	imcSound.PlaySoundEvent("sys_transcend_success");
	GET_CHILD_RECURSIVELY(frame,"successBgBox"):ShowWindow(1);

	local tuto_prop = frame:GetUserValue('TUTO_PROP')
	if tuto_prop ~= 'None' then
		local tuto_flag = false
		local tuto_value = GetUITutoProg(tuto_prop)
		if tuto_value == 3 then
			tuto_flag = true
		elseif tuto_prop == 'UITUTO_EQUIPCACABINET1' and tuto_value == 8 then
			tuto_flag = true
		end

		if tuto_flag == true then
			pc.ReqExecuteTx('SCR_UI_TUTORIAL_NEXT_STEP', tuto_prop)
		end
	end
end

function ITEM_CABINET_CLOSE_SUCCESS(frame)
	local frame = frame:GetTopParentFrame();	
	if GET_CHILD_RECURSIVELY(frame, "successBgBox"):IsVisible() == 1 then
		local category = frame:GetUserValue("CATEGORY")
		if category == "Skillgem" then
			INVENTORY_SET_CUSTOM_RBTNDOWN('ITEM_CABINET_SKILLGEM_REGISTER_RBTN')
		end
	end

	GET_CHILD_RECURSIVELY(frame, "successBgBox"):ShowWindow(0);

	local tuto_prop = frame:GetUserValue('TUTO_PROP')
	if tuto_prop ~= 'None' then
		local tuto_flag = false
		local tuto_value = GetUITutoProg(tuto_prop)
		if tuto_value == 4 then
			tuto_flag = true
		elseif tuto_prop == 'UITUTO_EQUIPCACABINET1' and tuto_value == 9 then
			tuto_flag = true
		end

		if tuto_flag == true then
			pc.ReqExecuteTx('SCR_UI_TUTORIAL_NEXT_STEP', tuto_prop)
		end
	end
end

local function ITEM_CABINET_CREATE_ARK_LV(gBox, ypos, step, class_name, curlv)
	local margin = 5;
	class_name = replace(class_name, 'PVP_', '')
	
	local func_str = string.format('get_tooltip_%s_arg%d', class_name, step)
	local tooltip_func = _G[func_str]  -- get_tooltip_Ark_str_arg1 시리즈
	if tooltip_func ~= nil then
		local tooltip_type, status, interval, add_value, summon_atk, client_msg, unit = tooltip_func();		
		local option_active_lv = nil
		local option_active_func_str = string.format('get_%s_option_active_lv', class_name)
		local option_active_func = _G[option_active_func_str]
		if option_active_func ~= nil then
			option_active_lv = option_active_func();			
		end

		local option = status        
		local grade_count = math.floor(curlv / interval);
		if tooltip_type == 3 then
			add_value = add_value * grade_count
		else
			add_value = math.floor(add_value * grade_count);		
		end
		
		if add_value <= 0 and (option_active_lv == nil or curlv < option_active_lv)then			
			return ypos;
		end
		
		local strInfo = ABILITY_DESC_PLUS(ScpArgMsg(option), add_value)
		
		if tooltip_type == 2 then
			local add_msg =  string.format(", %s "..ScpArgMsg("PropUp").."%.1f", ScpArgMsg('SUMMON_ATK'), math.abs(add_value / 200)) .. '%'
			strInfo = strInfo .. ' ' .. add_msg
		elseif tooltip_type == 3 then
			if unit == nil then				
				strInfo = string.format(" - %s "..ScpArgMsg("PropUp").."%d", ScpArgMsg(option), add_value + summon_atk) .. '%'								
			else
				strInfo = string.format(" - %s "..ScpArgMsg("PropUp").."%d", ScpArgMsg(option), add_value + summon_atk) .. unit				
			end
		elseif tooltip_type == 4 then
			if unit == nil then
				strInfo = string.format(" - %s "..ScpArgMsg("PropUp").."%d", ScpArgMsg(option), add_value + summon_atk) .. '%'
			else
				strInfo = string.format(" - %s "..ScpArgMsg("PropUp").."%d", ScpArgMsg(option), add_value + summon_atk) .. unit				
			end
		end		
		
		local infoText = gBox:CreateControl('richtext', 'infoText'..step, 15, ypos, gBox:GetWidth(), 30);
		infoText:SetText(strInfo);		
		infoText:SetFontName("brown_16");
		gBox:Resize(gBox:GetWidth(),gBox:GetHeight() + infoText:GetHeight())

		ypos = ypos + infoText:GetHeight() + margin;
	end

	return ypos;
end

local function ITEM_CABINET_CREATE_ARK_OPTION(gBox, ypos, step, class_name)
	local margin = 5;

	class_name = replace(class_name, 'PVP_', '')

	local func_str = string.format('get_tooltip_%s_arg%d', class_name, step)
    local tooltip_func = _G[func_str]  -- get_tooltip_Ark_str_arg1 시리즈
	if tooltip_func ~= nil then
		local tooltip_type, status, interval, add_value, summon_atk, client_msg, unit = tooltip_func();
		local option = status
		local infoText = gBox:CreateControl('richtext', 'optionText'..step, 15, ypos, gBox:GetWidth()-50, 30);
		infoText:SetTextFixWidth(1);

		local text = ''
		if tooltip_type == 1 then
			text = ScpArgMsg("ArkOptionText{Option}{interval}{addvalue}", "Option", ClMsg(option), "interval", interval, "addvalue", add_value)
		elseif tooltip_type == 2 then
			text = ScpArgMsg("ArkOptionText{Option}{interval}{addvalue}{option2}{addvalue2}", "Option", ClMsg(option), "interval", interval, "addvalue", add_value, 'option2', ClMsg(summon_atk), 'addvalue2', string.format('%.1f', add_value / 200))
		elseif tooltip_type == 3 then			
			if client_msg == nil then
				text = ScpArgMsg("ArkOptionText3{Option}{interval}{addvalue}", "Option", ClMsg(option), "interval", interval, "addvalue", add_value)				
			else
				text = ScpArgMsg(client_msg, "Option", ClMsg(option), "interval", interval, "addvalue", add_value)				
			end
		elseif tooltip_type == 4 then			
			text = ScpArgMsg("ArkOptionText4{Option}{interval}{addvalue}", "Option", ClMsg(option), "interval", interval, "addvalue", add_value)
		end
		
		infoText:SetText(text);
		infoText:SetFontName("brown_16_b");
		gBox:Resize(gBox:GetWidth(),gBox:GetHeight() + infoText:GetHeight())
		ypos = ypos + infoText:GetHeight() + margin;
	end

	return ypos;
end


function ITEM_CABINET_OPTION_INFO(gBox, targetItem)
	local yPos = 0		
	
	--Only SKIllGEM & RELICGEM start--
	local grouptype = TryGetProp(targetItem,"GroupName",'None')
	if grouptype=="Gem" then
		local tooltip_equip_property_CSet = gBox:CreateOrGetControlSet('tooltip_equip_property_narrow', 'tooltip_equip_property_narrow', 0, yPos)
		local labelline = GET_CHILD_RECURSIVELY(tooltip_equip_property_CSet, "labelline")
		labelline:ShowWindow(0) 
		
		local property_gbox = GET_CHILD(tooltip_equip_property_CSet,'property_gbox','ui::CGroupBox')
		tooltip_equip_property_CSet:Resize(gBox:GetWidth(),tooltip_equip_property_CSet:GetHeight())
		property_gbox:Resize(gBox:GetWidth(),property_gbox:GetHeight())

		local inner_yPos = 0
		inner_yPos = DRAW_GEM_PROPERTYS_TOOLTIP(tooltip_equip_property_CSet,targetItem,inner_yPos,'property_gbox')
		inner_yPos = DRAW_GEM_DESC_TOOLTIP(tooltip_equip_property_CSet,targetItem,inner_yPos,'property_gbox')

		tooltip_equip_property_CSet:Resize(tooltip_equip_property_CSet:GetWidth(),tooltip_equip_property_CSet:GetHeight() + property_gbox:GetHeight() + property_gbox:GetY() + 40)
		gBox:Resize(gBox:GetWidth(), tooltip_equip_property_CSet:GetHeight()+10)

		return
	elseif grouptype=="Gem_Relic" then
		local inner_yPos = yPos
		local tooltip_equip_property_CSet = gBox:CreateOrGetControlSet('tooltip_equip_property_narrow', 'tooltip_equip_property_narrow', 0, yPos)
		local labelline = GET_CHILD_RECURSIVELY(tooltip_equip_property_CSet, "labelline")
		labelline:ShowWindow(0)
		
		local property_gbox = GET_CHILD(tooltip_equip_property_CSet,'property_gbox','ui::CGroupBox')
		tooltip_equip_property_CSet:Resize(gBox:GetWidth(),tooltip_equip_property_CSet:GetHeight())
		property_gbox:Resize(gBox:GetWidth(),property_gbox:GetHeight())
		local cls_type= TryGetProp(targetItem,"ClassID")
		local cabinetCls = GetClassByType("cabinet_relicgem",cls_type)
		local acc = GetMyAccountObj()
		local upgradeProperty = TryGetProp(cabinetCls,"UpgradeAccountProperty","None")
		local lv = TryGetProp(acc,upgradeProperty,0)
		ITEM_TOOLTIP_GEM_RELIC_ONLY_FOR_CABINET(tooltip_equip_property_CSet,targetItem,'property_gbox','CharacterBelonging',lv)
		
		tooltip_equip_property_CSet:Resize(tooltip_equip_property_CSet:GetWidth(),tooltip_equip_property_CSet:GetHeight() + property_gbox:GetHeight() + property_gbox:GetY() + 40)
		gBox:Resize(gBox:GetWidth(), tooltip_equip_property_CSet:GetHeight()+10)
		return
	end
	--Only SKIllGEM & RELICGEM End--
	local basicList = GET_EQUIP_TOOLTIP_PROP_LIST(targetItem)
	local list = {}
    local basicTooltipPropList = StringSplit(targetItem.BasicTooltipProp, ';')
	for i = 1, #basicTooltipPropList do
        local basicTooltipProp = basicTooltipPropList[i]
		list = GET_CHECK_OVERLAP_EQUIPPROP_LIST(basicList, basicTooltipProp, list)
		
    end
	

	local cnt = 0
	for i = 1 , #list do
		local propName = list[i]
		local propValue = TryGetProp(targetItem, propName, 0)
		if propValue ~= 0 then
            local checkPropName = propName
            if propName == 'MINATK' or propName == 'MAXATK' then
                checkPropName = 'ATK'
            end
            if EXIST_ITEM(basicTooltipPropList, checkPropName) == false then
                cnt = cnt + 1
            end
		end
	end
	
	for i = 1 , 3 do
		local propName = "HatPropName_"..i
		local propValue = "HatPropValue_"..i
	

		if targetItem[propValue] ~= 0 and targetItem[propName] ~= "None" then
			cnt = cnt + 1
		end
	end
	local tooltip_equip_property_CSet = gBox:CreateOrGetControlSet('tooltip_equip_property_narrow', 'tooltip_equip_property_narrow', 0, yPos)
	local labelline = GET_CHILD_RECURSIVELY(tooltip_equip_property_CSet, "labelline")
	labelline:ShowWindow(0)
	local property_gbox = GET_CHILD(tooltip_equip_property_CSet,'property_gbox','ui::CGroupBox')

	tooltip_equip_property_CSet:Resize(gBox:GetWidth(),tooltip_equip_property_CSet:GetHeight())
	property_gbox:Resize(gBox:GetWidth(),property_gbox:GetHeight())

	local class = GetClassByType("Item", targetItem.ClassID)

	local inner_yPos = 0
	
	for i = 1 , #list do
		local propName = list[i]
		local propValue = TryGetProp(targetItem, propName, 0)
		local needToShow = true

		for j = 1, #basicTooltipPropList do
			if basicTooltipPropList[j] == propName then
				needToShow = false
			end
		end

		if needToShow == true and propValue ~= 0 then -- 랜덤 옵션이랑 겹치는 프로퍼티는 여기서 출력하지 않음
			if  targetItem.GroupName == 'Weapon' then
				if propName ~= "MINATK" and propName ~= 'MAXATK' then
					local strInfo = ABILITY_DESC_PLUS(ScpArgMsg(propName), propValue)
					inner_yPos = ADD_ITEM_PROPERTY_TEXT_NARROW(property_gbox, strInfo, 0, inner_yPos)
				end
			elseif  targetItem.GroupName == 'Armor' then
				if targetItem.ClassType == 'Gloves' then
					if propName ~= "HR" then
						local strInfo = ABILITY_DESC_PLUS(ScpArgMsg(propName), propValue)
						inner_yPos = ADD_ITEM_PROPERTY_TEXT_NARROW(property_gbox, strInfo, 0, inner_yPos)
					end
				elseif targetItem.ClassType == 'Boots' then
					if propName ~= "DR" then
						local strInfo = ABILITY_DESC_PLUS(ScpArgMsg(propName), propValue)
						inner_yPos = ADD_ITEM_PROPERTY_TEXT_NARROW(property_gbox, strInfo, 0, inner_yPos)
					end
				else
					if propName ~= "DEF" then
						local strInfo = ABILITY_DESC_PLUS(ScpArgMsg(propName), propValue)
						inner_yPos = ADD_ITEM_PROPERTY_TEXT_NARROW(property_gbox, strInfo, 0, inner_yPos)
					end
				end
			else
				local strInfo = ABILITY_DESC_PLUS(ScpArgMsg(propName), propValue)
				inner_yPos = ADD_ITEM_PROPERTY_TEXT_NARROW(property_gbox, strInfo, 0, inner_yPos)
			end
		end
	end
	if targetItem.ClassType == 'Ark' then
		inner_yPos = 10
		for i = 1, max_ark_option_count do 	-- 옵션이 최대 10개 있다고 가정함		
			inner_yPos = ITEM_CABINET_CREATE_ARK_LV(tooltip_equip_property_CSet, inner_yPos, i, targetItem.ClassName, 1);
		end

		for i = 1, max_ark_option_count do 	-- 옵션이 최대 10개 있다고 가정함		
			inner_yPos = ITEM_CABINET_CREATE_ARK_OPTION(tooltip_equip_property_CSet, inner_yPos, i, targetItem.ClassName);
		end

		local desc = EQUIP_ARK_DESC(targetItem.ClassName);
		if desc ~= "" then
			inner_yPos = ADD_ITEM_PROPERTY_TEXT_NARROW(tooltip_equip_property_CSet, desc, 0, inner_yPos)
		end
	end

	local briquetCls = GetClass("cabinet_artefact", targetItem.ClassName)
	if briquetCls ~= nil then
		local desc = ClMsg("BriquetDesc")
		inner_yPos = ADD_ITEM_PROPERTY_TEXT_NARROW(tooltip_equip_property_CSet, desc, 0, 10)
	end

	for i = 1 , 3 do
		local propName = "HatPropName_"..i
		local propValue = "HatPropValue_"..i

		if targetItem[propValue] ~= 0 and targetItem[propName] ~= "None" then
			local opName = string.format("[%s] %s", ClMsg("EnchantOption"), ScpArgMsg(targetItem[propName]))
			local strInfo = ABILITY_DESC_PLUS(opName, targetItem[propValue])
			inner_yPos = ADD_ITEM_PROPERTY_TEXT_NARROW(property_gbox, strInfo, 0, inner_yPos)
		end
	end
	if targetItem.OptDesc ~= nil and targetItem.OptDesc ~= 'None' then
		inner_yPos = ADD_ITEM_PROPERTY_TEXT_NARROW(property_gbox, targetItem.OptDesc, 0, inner_yPos)
	end

	if targetItem.OptDesc ~= nil and (targetItem.OptDesc == 'None' or targetItem.OptDesc == '') and TryGetProp(targetItem, 'StringArg', 'None') == 'Vibora' then
		local opt_desc = targetItem.OptDesc
		if opt_desc == 'None' then
			opt_desc = ''
		end
		
		for idx = 1, MAX_VIBORA_OPTION_COUNT do			
			local additional_option = TryGetProp(targetItem, 'AdditionalOption_' .. tostring(idx), 'None')			
			if additional_option ~= 'None' then
				local tooltip_str = 'tooltip_' .. additional_option					
				local cls_message = GetClass('ClientMessage', tooltip_str)
				if cls_message ~= nil then
					opt_desc = opt_desc .. ClMsg(tooltip_str)
				end
			end
		end
		inner_yPos = ADD_ITEM_PROPERTY_TEXT_NARROW(property_gbox, opt_desc, 0, inner_yPos);
	end

	tooltip_equip_property_CSet:Resize(tooltip_equip_property_CSet:GetWidth(),tooltip_equip_property_CSet:GetHeight() + property_gbox:GetHeight() + property_gbox:GetY() + 40)
	gBox:Resize(gBox:GetWidth(), tooltip_equip_property_CSet:GetHeight()+10)
end

function START_OPEN_ALL_CABINET(frame)
	ui.MsgBox(ScpArgMsg("StartOpenAllCabinet"));
	ui.SetHoldUI(true);
	ReserveScript('END_OPEN_ALL_CABINET', 3)
end

function END_OPEN_ALL_CABINET()
	ui.SetHoldUI(false);
	ui.MsgBox(ScpArgMsg("EndOpenAllCabinet"));
	ui.OpenFrame('item_cabinet')
end

function OPEN_ITEM_CABINET_TO_RELICGEM_LVUP()
	ui.OpenFrame('item_cabinet')

	local cabinet_frame = ui.GetFrame('item_cabinet')
	local cabinet_tab = GET_CHILD_RECURSIVELY(cabinet_frame, 'cabinet_tab')
	cabinet_tab:SelectTab(5)
	ITEM_CABINET_CHANGE_TAB(cabinet_frame)

	ui.RemoveGuideMsg('DropItemPlz')
	ui.GuideMsg('NOT_A_RELIC_GEM')
end