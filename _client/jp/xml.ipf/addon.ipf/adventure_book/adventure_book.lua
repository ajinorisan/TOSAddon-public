ADVENTURE_BOOK_ACHIEVE_SUBCATEGORY_SELECT = {} -- 선택중인 서브 카테고리 이름(achieve_info)
ADVENTURE_BOOK_ACHIEVE_NOT_TIME_START = {}
ADVENTURE_BOOK_ACHIEVE_GUIDEQUEST_CATEGORY = {}
ADVENTURE_BOOK_ACHIEVE_GUIDEQUEST_SELECT = nil

function ADVENTURE_BOOK_ON_INIT(addon, frame)
	-- 모험일지
	addon:RegisterOpenOnlyMsg("UPDATE_ADVENTURE_BOOK", "ADVENTURE_BOOK_ON_MSG");   
         
    addon:RegisterMsg('ADVENTURE_BOOK_MAIN_RANKING', 'ON_ADVENTURE_BOOK_MAIN_RANKING');
    addon:RegisterMsg('ADVENTURE_BOOK_ITEM_RANKING', 'ADVENTURE_BOOK_ITEM_CONSUME_RANKING');
    addon:RegisterMsg('ADVENTURE_BOOK_RANKING_PAGE', 'ON_ADVENTURE_BOOK_RANKING_PAGE');
    addon:RegisterMsg('ADVENTURE_BOOK_MY_RANK_UPDATE', 'ADVENTURE_BOOK_RANK_PAGE_INIT');
    addon:RegisterMsg('ADVENTURE_BOOK_RANK_SEARCH', 'ON_ADVENTURE_BOOK_RANK_SEARCH');
    addon:RegisterMsg('UPHILL_RANK_PAGE', 'ON_UPHILL_RANK_PAGE');
    addon:RegisterMsg('ADVENTURE_BOOK_UPHILL_RANK_SEARCH', 'ON_ADVENTURE_BOOK_RANK_SEARCH');
    addon:RegisterMsg('PVP_PC_INFO', 'ADVENTURE_BOOK_TEAM_BATTLE_COMMON_UPDATE');
    addon:RegisterMsg('WORLDPVP_RANK_PAGE', 'ADVENTURE_BOOK_TEAM_BATTLE_RANK_UPDATE');    
	addon:RegisterMsg("PVP_STATE_CHANGE", "ADVENTURE_BOOK_TEAM_BATTLE_STATE_CHANGE");
	addon:RegisterMsg("PVP_PROPERTY_UPDATE", "ADVENTURE_BOOK_UPDATE_PVP_PROPERTY");	
    addon:RegisterMsg('UPDATE_ADVENTURE_BOOK_REWARD', 'ADVENTURE_BOOK_MAIN_REWARD');
    addon:RegisterMsg('UPDATE_ADVENTURE_BOOK_CONTENTS_POINT', 'ADVENTURE_BOOK_QUEST_ACHIEVE_INIT_POINT');
	addon:RegisterMsg('UPDATE_WORLDPVP_GAME_LIST', 'WORLDPVP_PUBLIC_GAME_LIST');
	addon:RegisterMsg("SHOP_POINT_UPDATE", "ADVENTURE_BOOK_UPDATE_PVP_PROPERTY");
	addon:RegisterMsg('UPDATE_WORLDPVP_GAME_LIST', 'WORLDPVP_PUBLIC_GAME_LIST');

	-- 업적
	addon:RegisterMsg('UPDATE_ACHIEVE_EXCHANGE_EVENT', "ON_UPDATE_ACHIEVE_EXCHANGE_EVENT")
	addon:RegisterOpenOnlyMsg('RESET_ACHIEVE_EXCHANGE_EVENT', "ON_RESET_ACHIEVE_EXCHANGE_EVENT")
	addon:RegisterOpenOnlyMsg('ACHIEVE_POINT', "ON_UPDATE_GET_ACHIEVE_POINT")
	addon:RegisterOpenOnlyMsg('ACHIEVE_REWARD', "ON_UPDATE_GET_ACHIEVE_REWARD")
	addon:RegisterOpenOnlyMsg('ACHIEVE_REWARD_ALL', "ON_UPDATE_GET_ACHIEVE_REWARD_ALL")
	addon:RegisterOpenOnlyMsg('UPDATE_ACHIEVE_LEVEL_REWARD', "ADVENTURE_BOOK_ACHIEVE_INIT_LEVEL_REWARD")
	
	ADVENTURE_BOOK_ACHIEVE_CREATE_SUBCATEGORY()
	ADVENTURE_BOOK_INIT_TIMER_ACHIEVE()
	ADVENTURE_BOOK_ACHIEVE_CREATE_GUIDEQUEST_CHAPTER()
end

function ADVENTURE_BOOK_BTN_CLOSE(ctrl , btn)
   CLOSE_ADVENTURE_BOOK();
end

function ADVENTURE_BOOK_ACHIEVE_CREATE_SUBCATEGORY()
	local frame = ui.GetFrame("adventure_book")
	local gb_achieve = GET_CHILD(frame, "gb_achieve")

	local max_view = 4 -- 한 화면에 보이는 최대 아이콘 갯수
	local icon_width = 94 -- 아이콘 크기 넓이
	local icon_height = 114 -- 아이콘 크기 높이
	local icon_space = 10 -- 아이콘 간격

	local mainCategory = ADVENTURE_BOOK_ACHIEVE_CONTENT.GET_MAIN_CATEGORY_CLASS_LIST()
	for i = 1, #mainCategory do
		local category = mainCategory[i].ClassName
		local page_achieve_list = GET_CHILD(gb_achieve, "page_achieve_list_"..category)
		local page_achieve_list_left = GET_CHILD(page_achieve_list, "page_achieve_list_"..category.."_left")
		local list_achieve_subcategory = GET_CHILD(page_achieve_list_left, "list_achieve_"..category.."_subcategory")
		local list_achieve_subcategory_scroll = GET_CHILD(list_achieve_subcategory, "list_achieve_"..category.."_subcategory_scroll")
		list_achieve_subcategory_scroll:RemoveAllChild()
		local maxWidth = list_achieve_subcategory:GetWidth()

		-- 서브 카테고리 생성
		local subCategory  = ADVENTURE_BOOK_ACHIEVE_CONTENT.GET_SUB_CATEGORY_CLASS_LIST(category)
		ADVENTURE_BOOK_ACHIEVE_SUBCATEGORY_SELECT[i] = subCategory[1].ClassName
		list_achieve_subcategory_scroll:SetUserValue("pos", 1)
		list_achieve_subcategory_scroll:SetUserValue("max_view", max_view)
		list_achieve_subcategory_scroll:SetUserValue("icon_width", icon_width)
		list_achieve_subcategory_scroll:SetUserValue("icon_space", icon_space)

		local x = 0
		local num = #subCategory
		local max = max_view
		local icon_size = icon_width

		for j = 1, num do
			-- icon
			local icon_btn = list_achieve_subcategory_scroll:CreateOrGetControl('button', "subcategorysel_"..j, icon_width, icon_height, ui.LEFT, ui.CENTER_VERT, x, 0, 0, 0)
			AUTO_CAST(icon_btn)
			icon_btn:SetImage(subCategory[j].Icon)
			local tooltipTxt = ClMsg(subCategory[j].Name)
			if subCategory[j].ClassName == 'GuideQuest' then
				tooltipTxt = tooltipTxt .. ClMsg('adventure_book_achieve_subcategory_maincont_grewup_sub')
			end
			icon_btn:SetTextTooltip(tooltipTxt)
			icon_btn:SetEventScript(ui.LBUTTONUP, "ADVENTURE_BOOK_ACHIEVE_SELECT_SUBCATEGORY")
			icon_btn:SetEventScriptArgNumber(ui.LBUTTONUP, i)
			icon_btn:SetEventScriptArgString(ui.LBUTTONUP, subCategory[j].ClassName)
			if subCategory[j].ClassName == "GuideQuest" then
				icon_btn:SetEventScript(ui.RBUTTONUP, "ADVENTURE_BOOK_RBTNUP_SUBCATEGORY_GUIDEQUEST")
			end
			x = x + icon_btn:GetWidth() + icon_space
		end

		-- max의 최대는 max_view
		if num < max then
			max = num
		end

		list_achieve_subcategory:Resize((max * icon_width) + ((max - 1) * icon_space) , list_achieve_subcategory:GetHeight())
		list_achieve_subcategory_scroll:Resize((num * icon_width) + ((num - 1) * icon_space) , list_achieve_subcategory_scroll:GetHeight())

		-- 버튼 설정
		local btn_left = GET_CHILD(page_achieve_list_left, "btn_left_"..category.."_subcategory", "ui::CButton")
		local btn_right = GET_CHILD(page_achieve_list_left, "btn_right_"..category.."_subcategory", "ui::CButton")
		btn_left:SetUserValue("categoryIndex", i)
		btn_right:SetUserValue("categoryIndex", i)

		btn_left:SetEnable(0)
		if num <= max then
			btn_right:SetEnable(0)
		end
	end
end

function ADVENTURE_BOOK_ACHIEVE_CREATE_GUIDEQUEST_CHAPTER()
	-- 성장 퀘스트 챕터 목록
	local ind = 1
	local clsList, cnt = GetClassListByProp('Achieve', 'SubCategory', 'GuideQuest')
	for i = 1, cnt do
		local cls = clsList[i]
		if cls ~= nil and TryGetProp(cls, 'IsTitle', 'None') == 'YES' then
			if ADVENTURE_BOOK_ACHIEVE_GUIDEQUEST_CATEGORY == nil then
				ADVENTURE_BOOK_ACHIEVE_GUIDEQUEST_CATEGORY = {}
			end
	
			local chapterName = TryGetProp(cls, 'DescTitle', 'None')
			local isComplete = ADVENTURE_BOOK_ACHIEVE_CONTENT.IS_COMPLETE(TryGetProp(cls, 'ClassID', 0))
			local chapterInfo = { Name = chapterName, Complete = isComplete }
			ADVENTURE_BOOK_ACHIEVE_GUIDEQUEST_CATEGORY[ind] = chapterInfo

			ind = ind + 1
		end
	end
end

function ADVENTURE_BOOK_RENEW_SELECTED_TAB_ACHIEVE()
	local frame = ui.GetFrame('adventure_book')
    local gb_achieve = GET_CHILD(frame, 'gb_achieve');
    local achieveTab = GET_CHILD(gb_achieve, 'achieveTab');
	local selectedTabName = achieveTab:GetSelectItemName();
	
	if selectedTabName == "tab_achieve_main" then
		ADVENTURE_BOOK_ACHIEVE_MAIN_INIT()
	elseif selectedTabName == "tab_achieve_search" then
		ADVENTURE_BOOK_RENEW_ACHIEVE_SEARCH()
	elseif selectedTabName == "tab_achieve_list_Main" then
		ADVENTURE_BOOK_RENEW_ACHIEVE_MAINCONT()
	elseif selectedTabName == "tab_achieve_list_Sub" then
		ADVENTURE_BOOK_RENEW_ACHIEVE_SUBCONT()
	elseif selectedTabName == "tab_achieve_list_Special" then
		ADVENTURE_BOOK_RENEW_ACHIEVE_SPECIAL()
	elseif selectedTabName == "tab_achieve_list_Event" then
		ADVENTURE_BOOK_RENEW_ACHIEVE_EVENT()
	end
end

function ADVENTURE_BOOK_RENEW_SELECTED_TAB_ADVENTURE()
	local frame = ui.GetFrame('adventure_book')
    local gb_adventure = GET_CHILD(frame, 'gb_adventure');
    local bookmark = GET_CHILD(gb_adventure, 'bookmark');
	local selectedTabName = bookmark:GetSelectItemName();
	
	if selectedTabName == "tab_main" then
		ADVENTURE_BOOK_MAIN_INIT()
	elseif selectedTabName == "tab_monster" then
		ADVENTURE_BOOK_RENEW_MONSTER()
	elseif selectedTabName == "tab_item" then
		ADVENTURE_BOOK_RENEW_ITEM()
	elseif selectedTabName == "tab_craft" then
		ADVENTURE_BOOK_RENEW_CRAFT()
	elseif selectedTabName == "tab_living" then
		ADVENTURE_BOOK_LIVING_INIT()
	elseif selectedTabName == "tab_indun" then
		ADVENTURE_BOOK_RENEW_INDUN()
	elseif selectedTabName == "tab_grow" then
		ADVENTURE_BOOK_RENEW_GROW()
	elseif selectedTabName == "tab_explore" then
		ADVENTURE_BOOK_RENEW_QUEST_ACHIEVE()
	end
end

function ADVENTURE_BOOK_ON_MSG(frame, msg, argStr, argNum)
	local frame = ui.GetFrame('adventure_book')
    local mainTab = GET_CHILD(frame, 'mainTab');
	local selectedMainTabName = mainTab:GetSelectItemName();
	
	if msg == "UPDATE_ADVENTURE_BOOK" then  
		if selectedMainTabName == "tab_main_achieve" then
			ADVENTURE_BOOK_ACHIEVE_MAIN_INIT()
			
			local gb_achieve = GET_CHILD(frame, 'gb_achieve');
			local achieveTab = GET_CHILD(gb_achieve, 'achieveTab');
			local selectedTabName = achieveTab:GetSelectItemName();
			-- 업데이트 추가 필요
			-- if argNum == ABT_INDUN then
			-- 	if selectedTabName == "tab_achieve_main" then
			-- 		-- ADVENTURE_BOOK_RENEW_SELECTED_TAB_ACHIEVE()
			-- 	end
			-- elseif argNum == ABT_INDUN then
			-- 	if selectedTabName == "tab_achieve_search" then
			-- 		-- ADVENTURE_BOOK_RENEW_SELECTED_TAB_ACHIEVE()
			-- 	end
			-- elseif argNum == ABT_INDUN then
			-- 	if selectedTabName == "tab_achieve_list_Main" then
			-- 		-- ADVENTURE_BOOK_RENEW_SELECTED_TAB_ACHIEVE()
			-- 	end
			-- elseif argNum == ABT_INDUN then
			-- 	if selectedTabName == "tab_achieve_list_Sub" then
			-- 		-- ADVENTURE_BOOK_RENEW_SELECTED_TAB_ACHIEVE()
			-- 	end
			-- elseif argNum == ABT_INDUN then
			-- 	if selectedTabName == "tab_achieve_list_Special" then
			-- 		-- ADVENTURE_BOOK_RENEW_SELECTED_TAB_ACHIEVE()
			-- 	end
			-- elseif argNum == ABT_INDUN then
			-- 	if selectedTabName == "tab_achieve_list_Event" then
			-- 		-- ADVENTURE_BOOK_RENEW_SELECTED_TAB_ACHIEVE()
			-- 	end
			-- end
		elseif selectedMainTabName == "tab_main_adventure" then
			ADVENTURE_BOOK_MAIN_INIT()

			local gb_adventure = GET_CHILD(frame, 'gb_adventure');
			local bookmark = GET_CHILD(gb_adventure, 'bookmark');
			local selectedTabName = bookmark:GetSelectItemName();
			
			if argNum == ABT_MON_KILL_COUNT then
				if selectedTabName == "tab_monster" then
					ADVENTURE_BOOK_RENEW_SELECTED_TAB_ADVENTURE()
				end
			elseif argNum == ABT_INDUN then
				if selectedTabName == "tab_indun" then
					ADVENTURE_BOOK_RENEW_SELECTED_TAB_ADVENTURE()
				end
			elseif argNum == ABT_CRAFT then
				if selectedTabName == "tab_craft" then
					ADVENTURE_BOOK_RENEW_SELECTED_TAB_ADVENTURE()
				end
			elseif argNum == ABT_FISHING then
				if selectedTabName == "tab_living" then
					ADVENTURE_BOOK_RENEW_SELECTED_TAB_ADVENTURE()
				end
			elseif argNum == ABT_MON_DROP_ITEM then
				if selectedTabName == "tab_monster" or  selectedTabName == "tab_item" then
					ADVENTURE_BOOK_RENEW_SELECTED_TAB_ADVENTURE()
				end
			elseif argNum == ABT_ITEM_COUNTABLE then
				if selectedTabName == "tab_item" then
					ADVENTURE_BOOK_RENEW_SELECTED_TAB_ADVENTURE()
				end
			elseif argNum == ABT_ITEM_PERMANENT then
				if selectedTabName == "tab_item" then
					ADVENTURE_BOOK_RENEW_SELECTED_TAB_ADVENTURE()
				end
			elseif argNum == ABT_ACHIEVE then
				if selectedTabName == "tab_explore" then
					ADVENTURE_BOOK_RENEW_SELECTED_TAB_ADVENTURE()
				end
			elseif argNum == ABT_AUTOSELLER then
				if selectedTabName == "tab_living" then
					ADVENTURE_BOOK_RENEW_SELECTED_TAB_ADVENTURE()
				end
			elseif argNum == ABT_CHARACTER then
				if selectedTabName == "tab_grow" then
					ADVENTURE_BOOK_RENEW_SELECTED_TAB_ADVENTURE()
				end
			end
		end
	end
end

function ADVENTURE_BOOK_BTN_SELECT_REGION(ctrl , btn)
	local value = GET_USER_VALUE(ctrl, "BtnArg");
	ADVENTURE_BOOK_MAP.SELECTED_REGION = value;
	ADVENTURE_BOOK_MAP.FILL_DATA()
end

function ADVENTURE_BOOK_RENEW_GROW()
	ADVENTURE_BOOK_GROW.RENEW();
end

function ADVENTURE_BOOK_RENEW_MONSTER()
	ADVENTURE_BOOK_MONSTER.RENEW();
end

function ADVENTURE_BOOK_RENEW_ITEM_CATEGORY()
	ADVENTURE_BOOK_ITEM.DROPDOWN_LIST_UPDATE_SUB()
	ADVENTURE_BOOK_ITEM.RENEW();
end

function ADVENTURE_BOOK_RENEW_ITEM()
	ADVENTURE_BOOK_ITEM.RENEW();
end

function ADVENTURE_BOOK_RENEW_CRAFT_CATEGORY()
	ADVENTURE_BOOK_CRAFT.DROPDOWN_LIST_UPDATE_SUB()
	ADVENTURE_BOOK_CRAFT.RENEW();
end

function ADVENTURE_BOOK_RENEW_CRAFT()
	ADVENTURE_BOOK_CRAFT.RENEW();
end

function ADVENTURE_BOOK_RENEW_SELLER()
	ADVENTURE_BOOK_SELLER.RENEW();
end

function ADVENTURE_BOOK_RENEW_FISHING()
	ADVENTURE_BOOK_FISHING.RENEW();
end

function ADVENTURE_BOOK_RENEW_INDUN()
	ADVENTURE_BOOK_INDUN.RENEW();
end

function ADVENTURE_BOOK_RENEW_MAP()
    ADVENTURE_BOOK_RENEW_QUEST_ACHIEVE();
end

function ADVENTURE_BOOK_RENEW_ACHIEVE_SEARCH()
	ADVENTURE_BOOK_ACHIEVE.RENEW("search", 1);
	
	-- checkbox pos
	local frame = ui.GetFrame("adventure_book")
	local gb_achieve = GET_CHILD(frame, "gb_achieve")
	local page_achieve_list_search = GET_CHILD(gb_achieve, "page_achieve_list_search")
	local page_achieve_list_search_left = GET_CHILD(page_achieve_list_search, "page_achieve_list_search_left")
	local checklist = {
		GET_CHILD(page_achieve_list_search_left, "check_option_reward"),
		GET_CHILD(page_achieve_list_search_left, "check_option_name"),
		GET_CHILD(page_achieve_list_search_left, "check_option_period")
	}
	local x = 0
	for i = 2, #checklist do
		x = checklist[i - 1]:GetMargin().left + checklist[i - 1]:GetWidth() + 10
		checklist[i]:SetMargin(x, checklist[i]:GetMargin().top, 0, 0)
	end
end

function ADVENTURE_BOOK_RENEW_ACHIEVE_MAINCONT()
    ADVENTURE_BOOK_ACHIEVE.RENEW("Main", 1);
end

function ADVENTURE_BOOK_RENEW_ACHIEVE_SUBCONT()
    ADVENTURE_BOOK_ACHIEVE.RENEW("Sub", 1);
end

function ADVENTURE_BOOK_RENEW_ACHIEVE_SPECIAL()
    ADVENTURE_BOOK_ACHIEVE.RENEW("Special", 1);
end

function ADVENTURE_BOOK_RENEW_ACHIEVE_EVENT()
    ADVENTURE_BOOK_ACHIEVE.RENEW("Event", 1);
end

function ADVENTURE_BOOK_RENEW_QUEST_ACHIEVE()
    local frame = ui.GetFrame('adventure_book');
    local bookmark_explore = GET_CHILD_RECURSIVELY(frame, 'bookmark_explore');
    local curTabName = bookmark_explore:GetSelectItemName();
    if curTabName == 'tab_explore_quest' then
	    ADVENTURE_BOOK_QUEST_ACHIEVE.RENEW();
    elseif curTabName == 'tab_explore_map' then
        ADVENTURE_BOOK_MAP.RENEW();
    elseif curTabName == 'tab_explore_collection' then        
        ADVENTURE_BOOK_COLLECTION_TAB(frame, frame);
    end
end

function ADVENTURE_BOOK_TOOLTIP_GROW_JOB(frame, jobType)
	ADVENTURE_BOOK_GROW.TOOLTIP_JOB(frame, jobType);
end

function ON_ADVENTURE_BOOK_RANKING_PAGE(frame, msg, argStr, argNum)
    if argStr == 'Initialization_point' then
        ADVENTURE_BOOK_RANKING_SHOW_PAGE(frame, argNum);
    elseif argStr == 'Item_Consume_point' then

    end
end

function ADVENTURE_BOOK_BTN_SELECT_MONSTER(ctrl , btn)
	local value = ctrl:GetUserValue("BtnArg");
	ADVENTURE_BOOK_MONSTER.SELECTED_MONSTER = value;
	ADVENTURE_BOOK_MONSTER.FILL_MONSTER_INFO()
end

function ADVENTURE_BOOK_BTN_SELECT_ITEM(ctrl , btn)
	local value = ctrl:GetUserValue("BtnArg");
	ADVENTURE_BOOK_ITEM.SELECTED_ITEM = value;
	ADVENTURE_BOOK_ITEM.FILL_ITEM_INFO()
end

function ADVENTURE_BOOK_BTN_SELECT_CRAFT(ctrl , btn)
	local value = ctrl:GetUserValue("BtnArg");
	if ADVENTURE_BOOK_CRAFT.SELECTED_ITEM == value then
		ADVENTURE_BOOK_CRAFT.SELECTED_ITEM = "";
		ADVENTURE_BOOK_CRAFT.SELECTED_CTRL = "";
	else
		ADVENTURE_BOOK_CRAFT.SELECTED_ITEM = value;
		ADVENTURE_BOOK_CRAFT.SELECTED_CTRL = ctrl:GetName();
	end
	ADVENTURE_BOOK_CRAFT.FILL_CRAFT_LIST();
	ADVENTURE_BOOK_CRAFT.FILL_CRAFT_INFO()
end

function ADVENTURE_BOOK_BTN_SELECT_SELLER(ctrl , btn)
	local value = ctrl:GetUserValue("BtnArg");
	ADVENTURE_BOOK_SELLER.SELECTED_SKILL = value;
	ADVENTURE_BOOK_SELLER.FILL_SKILL_INFO()
	ADVENTURE_BOOK_SELLER.FILL_ABILITY_INFO()
end

function ADVENTURE_BOOK_BTN_SELECT_FISH(ctrl , btn)
	local value = ctrl:GetUserValue("BtnArg");
	ADVENTURE_BOOK_FISHING.SELECTED_FISH = value;
	ADVENTURE_BOOK_FISHING.FILL_FISH_INFO()
end

function ADVENTURE_BOOK_BTN_SELECT_INDUN(ctrl , btn)
	local value = ctrl:GetUserValue("BtnArg");
	ADVENTURE_BOOK_INDUN.SELECTED_INDUN = value;
	ADVENTURE_BOOK_INDUN.FILL_INDUN_INFO()
end
function ADVENTURE_BOOK_BTN_SELECT_REGION(ctrl , btn)
	local value = ctrl:GetUserValue("BtnArg");
	
	if ADVENTURE_BOOK_MAP.SELECTED_REGION == value then
		ADVENTURE_BOOK_MAP.SELECTED_REGION = "";
	else
		ADVENTURE_BOOK_MAP.SELECTED_REGION = value;
	end
	ADVENTURE_BOOK_MAP.FILL_REGION_LIST()
end
function ADVENTURE_BOOK_BTN_SELECT_MAP(ctrl , btn)
	local value = ctrl:GetUserValue("BtnArg");
	ADVENTURE_BOOK_MAP.SELECTED_MAP = value;
	ADVENTURE_BOOK_MAP.FILL_MAP_INFO();
    ADVENTURE_BOOK_MAP.DRAW_MINIMAP(ADVENTURE_BOOK_MAP.SELECTED_MAP);
end
function ADVENTURE_BOOK_BTN_MORE_CRAFT(ctrl , btn)
	local maxIndex = ADVENTURE_BOOK_CRAFT.MAX_GROUP_INDEX()
	if ADVENTURE_BOOK_CRAFT.SHOW_GROUP_INDEX < maxIndex then
		ADVENTURE_BOOK_CRAFT.SHOW_GROUP_INDEX = ADVENTURE_BOOK_CRAFT.SHOW_GROUP_INDEX + 1;
		ADVENTURE_BOOK_CRAFT.FILL_CRAFT_LIST();
	end
end

function ADVENTURE_BOOK_BTN_MORE_ITEM(ctrl , btn)
	local maxIndex = ADVENTURE_BOOK_ITEM.MAX_GROUP_INDEX()
	if ADVENTURE_BOOK_ITEM.SHOW_GROUP_INDEX < maxIndex then
		ADVENTURE_BOOK_ITEM.SHOW_GROUP_INDEX = ADVENTURE_BOOK_ITEM.SHOW_GROUP_INDEX + 1;
		ADVENTURE_BOOK_ITEM.FILL_ITEM_LIST();
	end
end

function ADVENTURE_BOOK_BTN_MORE_MONSTER(ctrl , btn)
	local maxIndex = ADVENTURE_BOOK_MONSTER.MAX_GROUP_INDEX()
	if ADVENTURE_BOOK_MONSTER.SHOW_GROUP_INDEX < maxIndex then
		ADVENTURE_BOOK_MONSTER.SHOW_GROUP_INDEX = ADVENTURE_BOOK_MONSTER.SHOW_GROUP_INDEX + 1;
		ADVENTURE_BOOK_MONSTER.FILL_MONSTER_LIST();
	end
end

function ADVENTURE_BOOK_BTN_SLOT_LEFT(ctrl, btn, argStr, argNum)
	if argStr == "Monster" then
		ADVENTURE_BOOK_MONSTER['INFO_SLOT_INDEX'] = ADVENTURE_BOOK_MONSTER['INFO_SLOT_INDEX'] - 1
		ADVENTURE_BOOK_MONSTER['ADJUST_SLOT_INDEX']()
		ADVENTURE_BOOK_MONSTER['FILL_MONSTER_INFO_SLOT'](ctrl, ADVENTURE_BOOK_MONSTER.SELECTED_MONSTER)
	elseif argStr == "Item" then
		ADVENTURE_BOOK_ITEM['INFO_SLOT_INDEX'] = ADVENTURE_BOOK_ITEM['INFO_SLOT_INDEX'] - 1
		ADVENTURE_BOOK_ITEM['ADJUST_SLOT_INDEX'](ctrl, ADVENTURE_BOOK_ITEM.SELECTED_ITEM)
		ADVENTURE_BOOK_ITEM['FILL_ITEM_INFO_SLOT'](ctrl, ADVENTURE_BOOK_ITEM.SELECTED_ITEM)
	elseif argStr == "Craft" then

	end	
end

function ADVENTURE_BOOK_BTN_SLOT_RIGHT(ctrl, btn, argStr, argNum)
	if argStr == "Monster" then
		ADVENTURE_BOOK_MONSTER['INFO_SLOT_INDEX'] = ADVENTURE_BOOK_MONSTER['INFO_SLOT_INDEX'] + 1
		ADVENTURE_BOOK_MONSTER['ADJUST_SLOT_INDEX']()
		ADVENTURE_BOOK_MONSTER['FILL_MONSTER_INFO_SLOT'](ctrl, ADVENTURE_BOOK_MONSTER.SELECTED_MONSTER)
	elseif argStr == "Item" then
		ADVENTURE_BOOK_ITEM['INFO_SLOT_INDEX'] = ADVENTURE_BOOK_ITEM['INFO_SLOT_INDEX'] + 1
		ADVENTURE_BOOK_ITEM['ADJUST_SLOT_INDEX'](ctrl, ADVENTURE_BOOK_ITEM.SELECTED_ITEM)
		ADVENTURE_BOOK_ITEM['FILL_ITEM_INFO_SLOT'](ctrl, ADVENTURE_BOOK_ITEM.SELECTED_ITEM)
	elseif argStr == "Craft" then

	end
end

function ON_ADVENTURE_BOOK_SLOT_MONSTER_TO_ITEM(frame, msg, argStr, argNum)
	local frame = ui.GetFrame('adventure_book');
	gb_adventure = GET_CHILD(frame, "gb_adventure")
	bookmark = GET_CHILD(gb_adventure, "bookmark")
	ADVENTURE_BOOK_ITEM['SELECTED_ITEM'] = argNum
	bookmark:SelectTab(2);
end

function ON_ADVENTURE_BOOK_SLOT_ITEM_TO_MONSTER(frame, msg, argStr, argNum)
	local frame = ui.GetFrame('adventure_book');
	gb_adventure = GET_CHILD(frame, "gb_adventure")
	bookmark = GET_CHILD(gb_adventure, "bookmark")
	ADVENTURE_BOOK_MONSTER['SELECTED_MONSTER'] = argNum
	bookmark:SelectTab(1);
end

function ADVENTURE_BOOK_SORT_ASC(a, b)
	return a < b
end

function ADVENTURE_BOOK_SORT_PROP_BY_CLASSID_ASC(idSpace, propName, a, b)
	local clsA = GetClassByType(idSpace, a)
	local clsB = GetClassByType(idSpace, b)
	local nameA = TryGetProp(clsA, propName)
	local nameB = TryGetProp(clsB, propName)

	if nameA == nil then
		return true;
	end
	if nameB == nil then
		return false;
	end

	return nameA < nameB
end

function ADVENTURE_BOOK_FILTER_ITEM(list, func, arg1, arg2, arg3)
	local retTable = {}
	for i = 1, #list do
		for j = 1, #arg2 do
			if func(list[i], arg1, arg2[j], arg3) == true then
				retTable[#retTable + 1] = list[i]
				break
			end
		end
	end
	return retTable;
end

function ADVENTURE_BOOK_SEARCH_PROP_BY_CLASSID_FUNC(clsID, idSpace, propName, searchText)
	local cls = GetClassByType(idSpace, clsID)
	local prop = TryGetProp(cls, propName);

	if prop == nil then
		return false;
	end

	if prop == "None" then
		return false;
	end

    if searchText == nil or searchText == '' then
		return true;
	end

	if propName == "Name" then
		if config.GetServiceNation() ~= "KOR" and config.GetServiceNation() ~= "GLOBAL_KOR" then
			prop = dic.getTranslatedStr(prop);				
		end
	end

	prop = string.lower(prop);
	searchText = string.lower(searchText);
	
	if string.find(prop, searchText) == nil then
		return false;
	else
		return true;
	end
end

function ADVENTURE_BOOK_EQUAL_PROP_BY_CLASSID_FUNC(clsID, idSpace, propName, targetPropValue)
	if idSpace == "Achieve" and propName == "SubCategory" and targetPropValue == "GuideQuest" then
		propName = "SubGroup"
		if ADVENTURE_BOOK_ACHIEVE_GUIDEQUEST_SELECT == nil or ADVENTURE_BOOK_ACHIEVE_GUIDEQUEST_SELECT <= 0 then
			ADVENTURE_BOOK_ACHIEVE_GUIDEQUEST_SELECT = 1
		end
		targetPropValue = targetPropValue .. "_" .. ADVENTURE_BOOK_ACHIEVE_GUIDEQUEST_SELECT
	end
	
	local cls = GetClassByType(idSpace, clsID)
	local prop = TryGetProp(cls, propName);
	
	if TryGetProp(cls, "ClassType", "None") == 'Shield' and propName == 'GroupName' then
		prop = 'SubWeapon'
	end

	if prop == targetPropValue then
		return true
	else
		return false
	end
end

function ADVENTURE_BOOK_SEARCH_PROP_BY_CLASSID_FROM_LIST(list, idSpace, propName, searchText)
	return ADVENTURE_BOOK_FILTER_ITEM(list, ADVENTURE_BOOK_SEARCH_PROP_BY_CLASSID_FUNC, idSpace, propName, searchText)
end

function ADVENTURE_BOOK_EQUAL_PROP_BY_CLASSID_FROM_LIST(list, idSpace, propName, targetPropValue)
	return ADVENTURE_BOOK_FILTER_ITEM(list, ADVENTURE_BOOK_EQUAL_PROP_BY_CLASSID_FUNC, idSpace, propName, targetPropValue)
end

function UI_TOGGLE_JOURNAL()
	if app.IsBarrackMode() == true then
		return;
	end
	
	ui.ToggleFrame('adventure_book')
end

function OPEN_DO_JOURNAL(frame)	
	if nil == frame then
		frame = ui.GetFrame("adventure_book");
	end

	frame:SetUserValue("IS_OPEN_BY_NPC", "YES");
	OPEN_ADVENTURE_BOOK(frame, "YES");
	REGISTERR_LASTUIOPEN_POS(frame);
end

function OPEN_ADVENTURE_BOOK(frame, isopenbynpc)
    if frame == nil then
        frame = ui.GetFrame('adventure_book');
	end

	if config.GetServiceNation() == "GLOBAL" then
		local bookmark_explore = GET_CHILD_RECURSIVELY(frame, 'bookmark_explore')
		bookmark_explore:SetSkinSpace('tab_explore_quest', 10)
		bookmark_explore:SetSkinSpace('tab_explore_collection', 10)
	end
	
	if isopenbynpc == "YES" then
		ui.OpenFrame("adventure_book");
    else
        isopenbynpc = 'NO';
	end
	ADVENTURE_BOOK_ISOPENBYNPC(isopenbynpc)

	ADVENTURE_BOOK_ACHIEVE.INIT_SEARCH_FILTER_OPTION()
	
	if isopenbynpc == "YES" then
		ADVENTURE_BOOK_MAIN_SELECT(frame); -- 탭 변경하면서 ADVENTURE_BOOK_MAIN_INIT 호출함
	else
		local mainTab = GET_CHILD(frame, 'mainTab');
		local selectedTabName = mainTab:GetSelectItemName();
		if selectedTabName == "tab_main_achieve" then
			ADVENTURE_BOOK_ACHIEVE_INIT()
		elseif selectedTabName == "tab_main_adventure" then
			ADVENTURE_BOOK_ADVENTURE_INIT()
		end
	end
	
	local gb_achieve = GET_CHILD(frame, "gb_achieve")
	local page_achieve_main = GET_CHILD(gb_achieve, "page_achieve_main")
	local achieve_main_level_reward_bg = GET_CHILD(page_achieve_main, "achieve_main_level_reward_bg")
	achieve_main_level_reward_bg:ShowWindow(0)
end

function CLOSE_ADVENTURE_BOOK(frame)
    if frame == nil then
        frame = ui.GetFrame('adventure_book');
    end
    ui.CloseFrame("adventure_book");
    ui.CloseFrame('adventure_book_reward');
	frame:SetUserValue("IS_OPEN_BY_NPC","NO");
	UNREGISTERR_LASTUIOPEN_POS(frame);
end

-- 업적탭 눌렀을 때 호출
function ADVENTURE_BOOK_ACHIEVE_INIT(parent) 
	-- 메인 타이틀 변경
	ADVENTURE_BOOK_SET_TITLETEXT("achieve")
	-- 서브탭 기준 업데이트
	ADVENTURE_BOOK_RENEW_SELECTED_TAB_ACHIEVE()
end

-- 모험일지탭 눌렀을 때 호출
function ADVENTURE_BOOK_ADVENTURE_INIT(parent)
	-- 메인 타이틀 변경
	ADVENTURE_BOOK_SET_TITLETEXT("adventure")
	-- 서브탭 기준 업데이트
	ADVENTURE_BOOK_RENEW_SELECTED_TAB_ADVENTURE()
end

function ADVENTURE_BOOK_SET_TITLETEXT(category)
	local adventure_book = ui.GetFrame("adventure_book")
	local title_text = adventure_book:GetChild("title_text")
	title_text:SetText("{@st43b}"..ClMsg("adventure_book_maintitle_"..category).."{/}")
end

function ADVENTURE_BOOK_UPDATE_PVP_PROPERTY(frame, msg, argStr, argNum)
	ADVENTURE_BOOK_TEAM_BATTLE_COMMON_UPDATE(frame, msg, argStr, argNum);
	ADVENTURE_BOOK_UPHILL_UPDATE_POINT(frame);
end

function ADVENTURE_BOOK_ACHIEVE_SELECT_TAB_CATEGORY(mainCategory, subCategory)
	local frame = ui.GetFrame('adventure_book')
	local mainTab = GET_CHILD(frame, "mainTab")
	local mainTabIndex = mainTab:GetIndexByName("tab_main_achieve")
	if mainTab:GetSelectItemIndex() ~= mainTabIndex then
		mainTab:SelectTab(mainTabIndex)
	end

    local gb_achieve = GET_CHILD(frame, 'gb_achieve');
	local achieveTab = GET_CHILD(gb_achieve, 'achieveTab');
	local selectedTabName = achieveTab:GetSelectItemName()
	
	-- 메인 카테고리 선택
	local MainCategoryIndex = 0
	if ADVENTURE_BOOK_ACHIEVE_CONTENT.VAILD_MAIN_CATEGORY(mainCategory) == 1 then
		local list = ADVENTURE_BOOK_ACHIEVE_CONTENT.GET_MAIN_CATEGORY_CLASS_LIST()

		if mainCategory == list[1].ClassName then
			if selectedTabName ~= "tab_achieve_list_Main" then
				achieveTab:SelectTab(2)
				MainCategoryIndex = 1
			end
		elseif mainCategory == list[2].ClassName then
			if selectedTabName ~= "tab_achieve_list_Sub" then
				achieveTab:SelectTab(3)
				MainCategoryIndex = 2
			end
		elseif mainCategory == list[3].ClassName then
			if selectedTabName ~= "tab_achieve_list_Special" then
				achieveTab:SelectTab(4)
				MainCategoryIndex = 3
			end
		elseif mainCategory == list[4].ClassName then
			if selectedTabName ~= "tab_achieve_list_Event" then
				achieveTab:SelectTab(5)
				MainCategoryIndex = 4
			end
		end
	end 

	-- 서브 카테고리 선택
	if subCategory ~= nil and MainCategoryIndex ~= 0 then
		ADVENTURE_BOOK_ACHIEVE_SELECT_SUBCATEGORY(nil, nil, subCategory, MainCategoryIndex)
	end
end

-- 업적 요약 클릭 시 호출
-- 메인에서 눌렀을 때에는 메인 카테고리 탭으로 이동함
-- argStr: 클릭한 곳
-- ㄴ"Chase": 업적 추적 돋보기 버튼
-- ㄴ"SearchLink": 검색 링크
-- argNum: Achieve Class ID
function ADVENTURE_BOOK_ACHIEVE_SELECT(parent, ctrl, argStr, argNum)
	local clsID = argNum
	local cls = GetClassByType("Achieve", clsID);
	if cls == nil then return end
	
	local category = nil
	local frame = ui.GetFrame('adventure_book')
    local gb_achieve = GET_CHILD(frame, 'gb_achieve');
	local achieveTab = GET_CHILD(gb_achieve, 'achieveTab');
	local selectedTabName = achieveTab:GetSelectItemName();
	
	if frame:IsVisible() == 0 then
		ui.OpenFrame("adventure_book")
	end

	local selectMain = false
	local selectSearch = false
	if selectedTabName == "tab_achieve_main" then
		selectMain = true
	end

	-- 해당 카테고리로 강제 이동
	-- 1. 메인에서 선택한 경우
	-- 2. Chase에서 돋보기 버튼을 누른 경우
	if selectMain == true or argStr == "Chase" or argStr == "SearchLink" then
		ADVENTURE_BOOK_ACHIEVE_SELECT_TAB_CATEGORY(TryGetProp(cls, "MainCategory"), TryGetProp(cls, "SubCategory"))
	end
	
	selectedTabName = achieveTab:GetSelectItemName();
	if selectedTabName == "tab_achieve_search" then
		category = "search"
	elseif selectedTabName == "tab_achieve_list_Main" then
		category = "Main"
	elseif selectedTabName == "tab_achieve_list_Sub" then
		category = "Sub"
	elseif selectedTabName == "tab_achieve_list_Special" then
		category = "Special"
	elseif selectedTabName == "tab_achieve_list_Event" then
		category = "Event"
	end
	
	ADVENTURE_BOOK_ACHIEVE.FILL_INFO(category, clsID)

	-- 위치 설정
	-- 1. 메인에서 선택한 경우
	-- 2. Chase에서 돋보기 버튼을 누른 경우
	if selectMain == true or argStr == "Chase" or argStr == "SearchLink" then
		ADVENTURE_BOOK_ACHIEVE.SET_SCROLL_POS(category, clsID)
	end
end

function ADVENTURE_BOOK_ACHIEVE_LINK(frame, ctrl, argstr, argnum)
	frame = ui.GetFrame("adventure_book")
	local gb_achieve = GET_CHILD(frame, "gb_achieve")
	local achieveTab = GET_CHILD(gb_achieve, "achieveTab")

    if argstr == "Main" then
        achieveTab:SelectTab(2)
    elseif argstr == "Sub" then
		achieveTab:SelectTab(3)
    elseif argstr == "Special" then
		achieveTab:SelectTab(4)
    elseif argstr == "Event" then
		achieveTab:SelectTab(5)
	else
		return
	end
	ADVENTURE_BOOK_ACHIEVE.INIT_SCROLL_POS(argstr)
end

function ADVENTURE_BOOK_ACHIEVE_CLICK_SEARCH_BUTTON()
	local frame = ui.GetFrame("adventure_book")
	local gb_achieve = GET_CHILD(frame, "gb_achieve")
	local page = GET_CHILD(gb_achieve, "page_achieve_list_search")
	local page_left = GET_CHILD(page, "page_achieve_list_search_left")
	page_left:SetUserValue("CHANGE_SEARCH_OPTION", "1")

	ADVENTURE_BOOK_RENEW_ACHIEVE_SEARCH()
end

function ADVENTURE_BOOK_ACHIEVE_SELECT_SEARCH_OPTION_MAINCATEGORY()
	local frame = ui.GetFrame("adventure_book")
	local gb_achieve = GET_CHILD(frame, "gb_achieve")
	local page = GET_CHILD(gb_achieve, "page_achieve_list_search")
	local page_left = GET_CHILD(page, "page_achieve_list_search_left")
	local droplist_option_maincategory = GET_CHILD(page_left, "droplist_option_maincategory", "ui::CDropList")
	local droplist_option_subcategory = GET_CHILD(page_left, "droplist_option_subcategory", "ui::CDropList")
	droplist_option_subcategory:ClearItems()

	local listMain = ADVENTURE_BOOK_ACHIEVE_CONTENT.GET_SEARCH_FILTER_OPTION_LIST_MAINCATEGORY()
	local listSub = ADVENTURE_BOOK_ACHIEVE_CONTENT.GET_SEARCH_FILTER_OPTION_LIST_SUBCATEGORY(listMain[droplist_option_maincategory:GetSelItemIndex() + 1][1])

	for i = 1, #listSub do
		droplist_option_subcategory:AddItem(listSub[i][1], ClMsg(listSub[i][2]))
	end

	page_left:SetUserValue("CHANGE_SEARCH_OPTION", "1")

	ADVENTURE_BOOK_RENEW_ACHIEVE_SEARCH()
end

function ADVENTURE_BOOK_ACHIEVE_SELECT_SEARCH_OPTION_SUBCATEGORY()
	local frame = ui.GetFrame("adventure_book")
	local gb_achieve = GET_CHILD(frame, "gb_achieve")
	local page = GET_CHILD(gb_achieve, "page_achieve_list_search")
	local page_left = GET_CHILD(page, "page_achieve_list_search_left")
	page_left:SetUserValue("CHANGE_SEARCH_OPTION", "1")

	ADVENTURE_BOOK_RENEW_ACHIEVE_SEARCH()
end

function ADVENTURE_BOOK_ACHIEVE_SELECT_CHECK_OPTION_REWARD()
	local frame = ui.GetFrame("adventure_book")
	local gb_achieve = GET_CHILD(frame, "gb_achieve")
	local page = GET_CHILD(gb_achieve, "page_achieve_list_search")
	local page_left = GET_CHILD(page, "page_achieve_list_search_left")
	page_left:SetUserValue("CHANGE_SEARCH_OPTION", "1")

	ADVENTURE_BOOK_RENEW_ACHIEVE_SEARCH()
end

function ADVENTURE_BOOK_ACHIEVE_SELECT_CHECK_OPTION_NAME()
	local frame = ui.GetFrame("adventure_book")
	local gb_achieve = GET_CHILD(frame, "gb_achieve")
	local page = GET_CHILD(gb_achieve, "page_achieve_list_search")
	local page_left = GET_CHILD(page, "page_achieve_list_search_left")
	page_left:SetUserValue("CHANGE_SEARCH_OPTION", "1")

	ADVENTURE_BOOK_RENEW_ACHIEVE_SEARCH()
end

function ADVENTURE_BOOK_ACHIEVE_SELECT_CHECK_OPTION_PERIOD()
	local frame = ui.GetFrame("adventure_book")
	local gb_achieve = GET_CHILD(frame, "gb_achieve")
	local page = GET_CHILD(gb_achieve, "page_achieve_list_search")
	local page_left = GET_CHILD(page, "page_achieve_list_search_left")
	page_left:SetUserValue("CHANGE_SEARCH_OPTION", "1")

	ADVENTURE_BOOK_RENEW_ACHIEVE_SEARCH()
end

-- 보상 받기 요청
function ADVENTURE_BOOK_REQ_ACHIEVE_REWARD(parent, ctrl)
	local clsID = ctrl:GetUserIValue("BtnArg")
	session.ReqAchieveReward(clsID, false);
end

-- 서브 카테고리 리스트 왼쪽 클릭
function ADVENTURE_BOOK_ACHIEVE_LIST_SUBCATEGORY_LEFT(parent, ctrl)
	local categoryIdx = tonumber(ctrl:GetUserValue("categoryIndex"))
	local listMainCategory = ADVENTURE_BOOK_ACHIEVE_CONTENT.GET_MAIN_CATEGORY_CLASS_LIST()
	local category = TryGetProp(listMainCategory[categoryIdx], "ClassName")
	if category == nil then return end
	local listSubCategory = ADVENTURE_BOOK_ACHIEVE_CONTENT.GET_SUB_CATEGORY_CLASS_LIST(category)

	local frame = ui.GetFrame("adventure_book")
	local gb_achieve = GET_CHILD(frame, "gb_achieve")
	local page_achieve_list = GET_CHILD(gb_achieve, "page_achieve_list_"..category)
	local page_achieve_list_left = GET_CHILD(page_achieve_list, "page_achieve_list_"..category.."_left")
	local list_achieve_subcategory = GET_CHILD(page_achieve_list_left, "list_achieve_"..category.."_subcategory")
	local list_achieve_subcategory_scroll = GET_CHILD(list_achieve_subcategory, "list_achieve_"..category.."_subcategory_scroll")
	
	local btn_left = GET_CHILD(page_achieve_list_left, "btn_left_"..category.."_subcategory", "ui::CButton")
	local btn_right = GET_CHILD(page_achieve_list_left, "btn_right_"..category.."_subcategory", "ui::CButton")

	local pos = tonumber(list_achieve_subcategory_scroll:GetUserValue("pos"))
	local max_view = tonumber(list_achieve_subcategory_scroll:GetUserValue("max_view"))
	local icon_width = tonumber(list_achieve_subcategory_scroll:GetUserValue("icon_width"))
	local icon_space = tonumber(list_achieve_subcategory_scroll:GetUserValue("icon_space"))
	local num = #listSubCategory

	pos = pos - 1

	if pos < 1 then
		pos = 1
	end

	list_achieve_subcategory_scroll:SetUserValue("pos", pos)

	if pos == 1 then
		btn_left:SetEnable(0)
	end

	if max_view < num then
		if num - max_view >= pos then
			btn_right:SetEnable(1)
		end
	end

	list_achieve_subcategory_scroll:SetMargin(-((pos - 1) * (icon_width + icon_space)), 0, 0, 0)

end

-- 서브 카테고리 리스트 오른쪽 클릭
function ADVENTURE_BOOK_ACHIEVE_LIST_SUBCATEGORY_RIGHT(parent, ctrl)
	local categoryIdx = tonumber(ctrl:GetUserValue("categoryIndex"))
	local listMainCategory = ADVENTURE_BOOK_ACHIEVE_CONTENT.GET_MAIN_CATEGORY_CLASS_LIST()
	local category = TryGetProp(listMainCategory[categoryIdx], "ClassName")
	if category == nil then return end
	local listSubCategory = ADVENTURE_BOOK_ACHIEVE_CONTENT.GET_SUB_CATEGORY_CLASS_LIST(category)

	local frame = ui.GetFrame("adventure_book")
	local gb_achieve = GET_CHILD(frame, "gb_achieve")
	local page_achieve_list = GET_CHILD(gb_achieve, "page_achieve_list_"..category)
	local page_achieve_list_left = GET_CHILD(page_achieve_list, "page_achieve_list_"..category.."_left")
	local list_achieve_subcategory = GET_CHILD(page_achieve_list_left, "list_achieve_"..category.."_subcategory")
	local list_achieve_subcategory_scroll = GET_CHILD(list_achieve_subcategory, "list_achieve_"..category.."_subcategory_scroll")

	local btn_left = GET_CHILD(page_achieve_list_left, "btn_left_"..category.."_subcategory", "ui::CButton")
	local btn_right = GET_CHILD(page_achieve_list_left, "btn_right_"..category.."_subcategory", "ui::CButton")

	local pos = tonumber(list_achieve_subcategory_scroll:GetUserValue("pos"))
	local max_view = tonumber(list_achieve_subcategory_scroll:GetUserValue("max_view"))
	local icon_width = tonumber(list_achieve_subcategory_scroll:GetUserValue("icon_width"))
	local icon_space = tonumber(list_achieve_subcategory_scroll:GetUserValue("icon_space"))
	local num = #listSubCategory

	pos = pos + 1

	if pos > num - max_view + 1 then
		pos = num - max_view + 1
	end
	
	list_achieve_subcategory_scroll:SetUserValue("pos", pos)

	if pos == num - max_view + 1 then
		btn_right:SetEnable(0)
	end

	if max_view < num then
		if pos > 1 then
			btn_left:SetEnable(1)
		end
	end

	list_achieve_subcategory_scroll:SetMargin(-((pos - 1) * (icon_width + icon_space)), 0, 0, 0)
end

-- 서브 카테고리 선택
-- argstr: Sub Category Name
-- argnum: Main Category Index
function ADVENTURE_BOOK_ACHIEVE_SELECT_SUBCATEGORY(parent, ctrl, argstr, argnum)
	local MainCategoryList = ADVENTURE_BOOK_ACHIEVE_CONTENT.GET_MAIN_CATEGORY_CLASS_LIST()
	local MainCategory = TryGetProp(MainCategoryList[argnum], "ClassName", "None")
	if MainCategory == "None" then return end

	local frame = ui.GetFrame("adventure_book")
	local gb_achieve = frame:GetChild('gb_achieve')

	local page = gb_achieve:GetChild("page_achieve_list_"..MainCategory)
	if page == nil then return end

	page:SetUserValue("SubCategory", argstr)
	
	ADVENTURE_BOOK_ACHIEVE_SUBCATEGORY_SELECT[argnum] = argstr
	ADVENTURE_BOOK_RENEW_SELECTED_TAB_ACHIEVE()
end

-- 현재 선택하고 있는 서브 카테고리 가져오기
function ADVENTURE_BOOK_ACHIEVE_GET_SELECT_SUBCATEGORY(mainCategory)
	local list = ADVENTURE_BOOK_ACHIEVE_CONTENT.GET_MAIN_CATEGORY_CLASS_LIST()
	for i = 1, #list do
		if list[i].ClassName == mainCategory then
			return ADVENTURE_BOOK_ACHIEVE_SUBCATEGORY_SELECT[i]
		end
	end
	return nil
end

function ADVENTURE_BOOK_ACHIEVE_SEARCH_SHORTCUT()
	local frame = ui.GetFrame('adventure_book')
    local gb_achieve = GET_CHILD(frame, 'gb_achieve');
	local achieveTab = GET_CHILD(gb_achieve, 'achieveTab');
	
	achieveTab:SelectTab(1)
end

function ADVENTURE_BOOK_ACHIEVE_ADD_CHASE(clsID, ctrl)
	if clsID == 0 or clsID == nil then return end
	if ctrl == nil then return end

	local btn = GET_CHILD(ctrl, "chase")
	if btn == nil then return end

	if achieve.AddCheckAchieve(clsID) == true then
		ADVENTURE_BOOK_ACHIEVE_CHECK_CHASE_B(btn, 1)
	else
		achieve.RemoveCheckAchieve(clsID)
		ADVENTURE_BOOK_ACHIEVE_CHECK_CHASE_B(btn, 0)
	end
end

function ADVENTURE_BOOK_ACHIEVE_REMOVE_CHASE(clsID)
	if clsID == 0 or clsID == nil then return end

	achieve.RemoveCheckAchieve(clsID)
end

-- 추적 버튼 클릭
-- argNum: Achieve ClassID
function ADVENTURE_BOOK_ACHIEVE_CLICK_CHASE_BTN(ctrl, btn, argStr, argNum)
	local on = btn:GetUserValue("ON")

	if ADVENTURE_BOOK_ACHIEVE_CONTENT.IS_COMPLETE(argNum) == 1 then return end -- 업적 완료 시 X
	if ADVENTURE_BOOK_ACHIEVE_CONTENT.IS_TIME_END(argNum) == 1 then return end -- 시간 종료 시 X
	if ADVENTURE_BOOK_ACHIEVE_CONTENT.GET_MAIN_CATEGORY(argNum) == "Event" and
	   ADVENTURE_BOOK_ACHIEVE_CONTENT.GET_SUB_CATEGORY(argNum) == "End" then return end -- 끝난 이벤트 X

	if on == "true" then
		achieve.RemoveCheckAchieve(argNum)
		ADVENTURE_BOOK_ACHIEVE_CHECK_CHASE_B(btn, 0)
	else
		if achieve.AddCheckAchieve(argNum) == true then
			ADVENTURE_BOOK_ACHIEVE_CHECK_CHASE_B(btn, 1)
		else
			achieve.RemoveCheckAchieve(argNum)
			ADVENTURE_BOOK_ACHIEVE_CHECK_CHASE_B(btn, 0)
		end
	end

	ON_UPDATE_ACHIEVEINFOSET()
end


function ADVENTURE_BOOK_ACHIEVE_EXCHANGE_EVENT_CLICK_LEFT()
    local frame = ui.GetFrame("adventure_book")
    local gb_achieve = GET_CHILD(frame, "gb_achieve")
    local page_achieve_main = GET_CHILD(gb_achieve, "page_achieve_main")
    local page_achieve_main_left = GET_CHILD(page_achieve_main, "page_achieve_main_left")
    local gb_achieve_main_exchangeevent_list = GET_CHILD(page_achieve_main_left, "gb_achieve_main_exchangeevent_list")
    local gb_achieve_main_exchangeevent_list_scroll = GET_CHILD(gb_achieve_main_exchangeevent_list, "gb_achieve_main_exchangeevent_list_scroll")
    
	local btn_left = GET_CHILD(page_achieve_main_left, "left_btn", "ui::CButton")
	local btn_right = GET_CHILD(page_achieve_main_left, "right_btn", "ui::CButton")

	local pos = tonumber(gb_achieve_main_exchangeevent_list_scroll:GetUserValue("pos"))
	local max_view = tonumber(gb_achieve_main_exchangeevent_list_scroll:GetUserValue("max_view"))
	local icon_width = tonumber(gb_achieve_main_exchangeevent_list_scroll:GetUserValue("icon_width"))
	local icon_space = tonumber(gb_achieve_main_exchangeevent_list_scroll:GetUserValue("icon_space"))
	local num = gb_achieve_main_exchangeevent_list_scroll:GetChildCount() - 1

	pos = pos - 1

	if pos < 1 then
		pos = 1
	end

	gb_achieve_main_exchangeevent_list_scroll:SetUserValue("pos", pos)

	if pos == 1 then
		btn_left:SetEnable(0)
	end

	if max_view < num then
		if num - max_view >= pos then
			btn_right:SetEnable(1)
		end
	end

	gb_achieve_main_exchangeevent_list_scroll:SetMargin(-((pos - 1) * (icon_width + icon_space)), 0, 0, 0)

end

function ADVENTURE_BOOK_ACHIEVE_EXCHANGE_EVENT_CLICK_RIGHT()
    local frame = ui.GetFrame("adventure_book")
	local gb_achieve = GET_CHILD(frame, "gb_achieve")
    local page_achieve_main = GET_CHILD(gb_achieve, "page_achieve_main")
    local page_achieve_main_left = GET_CHILD(page_achieve_main, "page_achieve_main_left")
    local gb_achieve_main_exchangeevent_list = GET_CHILD(page_achieve_main_left, "gb_achieve_main_exchangeevent_list")
    local gb_achieve_main_exchangeevent_list_scroll = GET_CHILD(gb_achieve_main_exchangeevent_list, "gb_achieve_main_exchangeevent_list_scroll")

	local btn_left = GET_CHILD(page_achieve_main_left, "left_btn", "ui::CButton")
	local btn_right = GET_CHILD(page_achieve_main_left, "right_btn", "ui::CButton")

	local pos = tonumber(gb_achieve_main_exchangeevent_list_scroll:GetUserValue("pos"))
	local max_view = tonumber(gb_achieve_main_exchangeevent_list_scroll:GetUserValue("max_view"))
	local icon_width = tonumber(gb_achieve_main_exchangeevent_list_scroll:GetUserValue("icon_width"))
	local icon_space = tonumber(gb_achieve_main_exchangeevent_list_scroll:GetUserValue("icon_space"))
	local num = gb_achieve_main_exchangeevent_list_scroll:GetChildCount() - 1

	pos = pos + 1

	if pos > num - max_view + 1 then
		pos = num - max_view + 1
	end
	
	gb_achieve_main_exchangeevent_list_scroll:SetUserValue("pos", pos)

	if pos == num - max_view + 1 then
		btn_right:SetEnable(0)
	end

	if max_view < num then
		if pos > 1 then
			btn_left:SetEnable(1)
		end
	end

	gb_achieve_main_exchangeevent_list_scroll:SetMargin(-((pos - 1) * (icon_width + icon_space)), 0, 0, 0)
end

function ADVENTURE_BOOK_ACHIEVE_INFO_REWARD_CLICK_LEFT()
    local frame = ui.GetFrame("adventure_book")
	local gb_achieve = GET_CHILD(frame, "gb_achieve")
	local achieveTab = GET_CHILD(gb_achieve, "achieveTab")
	local selectedTabName = achieveTab:GetSelectItemName();
	local category = ""
	if selectedTabName == "tab_achieve_search" then
		category = "search"
	elseif selectedTabName == "tab_achieve_list_Main" then
		category = "Main"
	elseif selectedTabName == "tab_achieve_list_Sub" then
		category = "Sub"
	elseif selectedTabName == "tab_achieve_list_Special" then
		category = "Special"
	elseif selectedTabName == "tab_achieve_list_Event" then
		category = "Event"
	else
		return
	end

	local page = gb_achieve:GetChild("page_achieve_list_"..category)
	local page_right = page:GetChild("page_achieve_list_"..category.."_right")
	local achieve_info = page_right:GetChild("achieve_info")
	if achieve_info == nil then return end

	local gb_reward = GET_CHILD(achieve_info, "gb_reward")
	local gb_reward_item = GET_CHILD(gb_reward, "gb_reward_item")
	local gb_reward_item_content_bg = GET_CHILD(gb_reward_item, "gb_reward_item_content_bg")
	local gb_reward_item_content_slot_bg = GET_CHILD(gb_reward_item_content_bg, "gb_reward_item_content_slot_bg")
	local slotset_list_reward = GET_CHILD(gb_reward_item_content_slot_bg, "slotset_list_reward")

	local left_btn = GET_CHILD(gb_reward_item_content_bg, "left_btn")
	local right_btn = GET_CHILD(gb_reward_item_content_bg, "right_btn")

	local pos = gb_reward_item_content_slot_bg:GetUserIValue("pos")
	local max_view = gb_reward_item_content_slot_bg:GetUserIValue("max_view")
	local icon_width = slotset_list_reward:GetSlotWidth()
	local icon_space = slotset_list_reward:GetSpcX()
	local num = slotset_list_reward:GetSlotCount()

	pos = pos - 1

	if pos < 1 then
		pos = 1
	end

	gb_reward_item_content_slot_bg:SetUserValue("pos", pos)

	if pos == 1 then
		left_btn:SetEnable(0)
	end

	if max_view < num then
		if num - max_view >= pos then
			right_btn:SetEnable(1)
		end
	end

	slotset_list_reward:SetMargin(-((pos - 1) * (icon_width + icon_space)), 0, 0, 0)

end

function ADVENTURE_BOOK_ACHIEVE_INFO_REWARD_CLICK_RIGHT()
    local frame = ui.GetFrame("adventure_book")
	local gb_achieve = GET_CHILD(frame, "gb_achieve")
	local achieveTab = GET_CHILD(gb_achieve, "achieveTab")
	local selectedTabName = achieveTab:GetSelectItemName();
	local category = ""
	if selectedTabName == "tab_achieve_search" then
		category = "search"
	elseif selectedTabName == "tab_achieve_list_Main" then
		category = "Main"
	elseif selectedTabName == "tab_achieve_list_Sub" then
		category = "Sub"
	elseif selectedTabName == "tab_achieve_list_Special" then
		category = "Special"
	elseif selectedTabName == "tab_achieve_list_Event" then
		category = "Event"
	else
		return
	end

	local page = gb_achieve:GetChild("page_achieve_list_"..category)
	local page_right = page:GetChild("page_achieve_list_"..category.."_right")
	local achieve_info = page_right:GetChild("achieve_info")
	if achieve_info == nil then return end

	local gb_reward = GET_CHILD(achieve_info, "gb_reward")
	local gb_reward_item = GET_CHILD(gb_reward, "gb_reward_item")
	local gb_reward_item_content_bg = GET_CHILD(gb_reward_item, "gb_reward_item_content_bg")
	local gb_reward_item_content_slot_bg = GET_CHILD(gb_reward_item_content_bg, "gb_reward_item_content_slot_bg")
	local slotset_list_reward = GET_CHILD(gb_reward_item_content_slot_bg, "slotset_list_reward")

	local left_btn = GET_CHILD(gb_reward_item_content_bg, "left_btn")
	local right_btn = GET_CHILD(gb_reward_item_content_bg, "right_btn")

	local pos = gb_reward_item_content_slot_bg:GetUserIValue("pos")
	local max_view = gb_reward_item_content_slot_bg:GetUserIValue("max_view")
	local icon_width = slotset_list_reward:GetSlotWidth()
	local icon_space = slotset_list_reward:GetSpcX()
	local num = slotset_list_reward:GetSlotCount()

	pos = pos + 1
	
	if pos > num - max_view + 1 then
		pos = num - max_view + 1
	end
	
	gb_reward_item_content_slot_bg:SetUserValue("pos", pos)

	if pos == num - max_view + 1 then
		right_btn:SetEnable(0)
	end

	if max_view < num then
		if pos > 1 then
			left_btn:SetEnable(1)
		end
	end

	slotset_list_reward:SetMargin(-((pos - 1) * (icon_width + icon_space)), 0, 0, 0)
end

-- argNum: ClassID
function ON_UPDATE_ACHIEVE_EXCHANGE_EVENT(frame, msg, argStr, argNum)
    local frame = ui.GetFrame("adventure_book")
    local gb_achieve = frame:GetChild('gb_achieve')
    mainPage = gb_achieve:GetChild('page_achieve_main')

	ADVENTURE_BOOK_ACHIEVE_MAIN_INIT_EXCHANGE_EVENT(mainPage)	
end

function ON_RESET_ACHIEVE_EXCHANGE_EVENT(frame)
	ADVENTURE_BOOK_ACHIEVE_MAIN_UPDATE("EXCHANGE_EVENT")
end

function ADVENTURE_BOOK_INIT_TIMER_ACHIEVE()
	local frame = ui.GetFrame("adventure_book")
	local gb_achieve = GET_CHILD(frame, "gb_achieve")
	local page_achieve_main = GET_CHILD(gb_achieve, "page_achieve_main")
	local page_achieve_main_left = GET_CHILD(page_achieve_main, "page_achieve_main_left")
	
	-- 업적 교환 이벤트 다음 갱신일
	local achieve_main_exchangeevent_nextrenewal_text = GET_CHILD(page_achieve_main_left, "achieve_main_exchangeevent_nextrenewal_text")
	local exchange_event_timer = GET_CHILD(achieve_main_exchangeevent_nextrenewal_text, "exchange_event_timer", "ui::CAddOnTimer");
	exchange_event_timer:SetUpdateScript("ADVENTURE_BOOK_ACHIEVE_UPDATE_TIMER_EXCHANGE_EVENT")
	exchange_event_timer:Start(1)

	-- StartTime이 이전인 업적
	ADVENTURE_BOOK_ACHIEVE_NOT_TIME_START = ADVENTURE_BOOK_ACHIEVE_CONTENT.LIST_NOT_TIME_START()
	if #ADVENTURE_BOOK_ACHIEVE_NOT_TIME_START > 0 then
		local update_achieve_not_time_start_timer = frame:CreateOrGetControl('timer', "update_achieve_not_time_start_timer", 1, 1, ui.LEFT, ui.TOP, 0, 0, 0, 0);
		AUTO_CAST(update_achieve_not_time_start_timer)
		update_achieve_not_time_start_timer:SetUpdateScript("ADVENTURE_BOOK_ACHIEVE_UPDATE_TIMER_START_TIME")
		update_achieve_not_time_start_timer:Start(1)
	end
end


function ADVENTURE_BOOK_ACHIEVE_UPDATE_TIMER_EXCHANGE_EVENT(exchange_event_timer_text)
	local remainsec = ADVENTURE_BOOK_ACHIEVE_MAIN_GET_EXCHANGE_EVENT_REMAIN_SEC()
	if remainsec < 0 then
		remainsec = 0
	end

    local day =  math.floor(remainsec/86400)
    local hour = math.floor(remainsec/3600) - (day * 24)
    local min = math.floor(remainsec/60) - (day * 24 * 60) - (hour * 60)
    local sec = math.floor(remainsec%60)

    exchange_event_timer_text:SetTextByKey('day', day);
    exchange_event_timer_text:SetTextByKey('hour', hour);
    exchange_event_timer_text:SetTextByKey('minute', min);
    exchange_event_timer_text:SetTextByKey('second', sec);
end

function ADVENTURE_BOOK_ACHIEVE_UPDATE_TIMER_START_TIME(frame)
	local update_achieve_not_time_start_timer = GET_CHILD(frame, "update_achieve_not_time_start_timer", "ui::CAddOnTimer")
	local getnow = geTime.GetServerSystemTime()

	if getnow.wSecond > 1 then return end
	local newAchieve = {}
	
	local nowstr = string.format("%04d-%02d-%02d %02d:%02d:%02d", getnow.wYear, getnow.wMonth, getnow.wDay, getnow.wHour, getnow.wMinute, getnow.wSecond)
	for i = 1, #ADVENTURE_BOOK_ACHIEVE_NOT_TIME_START do
		local cls = GetClassByType("Achieve", ADVENTURE_BOOK_ACHIEVE_NOT_TIME_START[i])
		if cls ~= nil then
			local NeedPoint = TryGetProp(cls, "NeedPoint", "None")
			if NeedPoint ~= "None" then
				local clsPoint = GetClassByStrProp("AchievePoint", "ClassName", NeedPoint)
				if clsPoint ~= nil then
					local StartTime = TryGetProp(clsPoint, "StartTime", "None")
					if StartTime ~= "None" then
						local remainsec = date_time.get_lua_datetime_from_str(StartTime) - date_time.get_lua_datetime_from_str(nowstr)
						if remainsec < 0 then
							newAchieve[#newAchieve + 1] = cls
							break
						end
					end
				end
			end
		end
	end
	
	if #newAchieve > 0 then
	 	ADVENTURE_BOOK_ACHIEVE_NOT_TIME_START = ADVENTURE_BOOK_ACHIEVE_CONTENT.LIST_NOT_TIME_START()
	 	ON_UPDATE_NEW_ACHIEVE(newAchieve)
	end

	if #ADVENTURE_BOOK_ACHIEVE_NOT_TIME_START <= 0 then
		update_achieve_not_time_start_timer:Stop()
	end
end

function ON_UPDATE_NEW_ACHIEVE(newAchieve) -- StartTime이 지나서
    local frame = ui.GetFrame("adventure_book")
	local gb_achieve = GET_CHILD(frame, "gb_achieve")
	local achieveTab = GET_CHILD(gb_achieve, "achieveTab")
	local selectedTabName = achieveTab:GetSelectItemName();
	local category = ""
	local categoryIndex;
	local renewfunc;
	
	if selectedTabName == "tab_achieve_main" then
		ADVENTURE_BOOK_ACHIEVE_MAIN_UPDATE("CUR_STATUS")
		ADVENTURE_BOOK_ACHIEVE_MAIN_UPDATE("NEW_ACHIEVE")
		return
	elseif selectedTabName == "tab_achieve_search" then
		ADVENTURE_BOOK_RENEW_ACHIEVE_SEARCH()
		return
	elseif selectedTabName == "tab_achieve_list_Main" then
		category = "Main"
		categoryIndex = 1
		renewfunc = ADVENTURE_BOOK_RENEW_ACHIEVE_MAINCONT
	elseif selectedTabName == "tab_achieve_list_Sub" then
		category = "Sub"
		categoryIndex = 2
		renewfunc = ADVENTURE_BOOK_RENEW_ACHIEVE_SUBCONT
	elseif selectedTabName == "tab_achieve_list_Special" then
		category = "Special"
		categoryIndex = 3
		renewfunc = ADVENTURE_BOOK_RENEW_ACHIEVE_SPECIAL
	elseif selectedTabName == "tab_achieve_list_Event" then
		category = "Event"
		categoryIndex = 4
		renewfunc = ADVENTURE_BOOK_RENEW_ACHIEVE_EVENT
	else
		return
	end

	for i = 1, #newAchieve do
		local cls = newAchieve[i]
		local mainCategory = TryGetProp(cls, "MainCategory", "None")
		local subCategory = TryGetProp(cls, "SubCategory", "None")
		if mainCategory ~= "None" and subCategory ~= "None" then
			if mainCategory == category and ADVENTURE_BOOK_ACHIEVE_SUBCATEGORY_SELECT[categoryIndex] == subCategory then
				renewfunc()
				return
			end
		end
	end
end

-- argNum: AchievePoint ClassID
function ON_UPDATE_GET_ACHIEVE_POINT(frame, msg, argStr, argNum) -- 포인트 갱신, 리스트 갱신
	if argNum == 0 then return end
    local frame = ui.GetFrame("adventure_book")
	local gb_achieve = GET_CHILD(frame, "gb_achieve")
	local achieveTab = GET_CHILD(gb_achieve, "achieveTab")
	local selectedTabName = achieveTab:GetSelectItemName();
	local category = ""
	local categoryIndex;
	
	if selectedTabName == "tab_achieve_search" then
		ADVENTURE_BOOK_RENEW_ACHIEVE_SEARCH()
	elseif selectedTabName == "tab_achieve_list_Main" then
		category = "Main"
		categoryIndex = 1
	elseif selectedTabName == "tab_achieve_list_Sub" then
		category = "Sub"
		categoryIndex = 2
	elseif selectedTabName == "tab_achieve_list_Special" then
		category = "Special"
		categoryIndex = 3
	elseif selectedTabName == "tab_achieve_list_Event" then
		category = "Event"
		categoryIndex = 4
	else
		return
	end

	local list = ADVENTURE_BOOK_ACHIEVE_CONTENT.LIST_MATCH_NEEDPOINT(argNum)
	for i = 1, #list do
		local cls = GetClassByType("Achieve", list[i])
		local mainCategory = TryGetProp(cls, "MainCategory", "None")
		local subCategory = TryGetProp(cls, "SubCategory", "None")
		if mainCategory ~= "None" and subCategory ~= "None" then
			if mainCategory == category and
			   subCategory == ADVENTURE_BOOK_ACHIEVE_SUBCATEGORY_SELECT[categoryIndex] then
				ADVENTURE_BOOK_ACHIEVE.RENEW(mainCategory)
				ADVENTURE_BOOK_ACHIEVE.FILL_INFO_RENEW(mainCategory)
				return
			end
		end
	end
end

-- argNum: Achieve ClassID
function ON_UPDATE_GET_ACHIEVE_REWARD(frame, msg, argStr, argNum) -- 보상 수령, 리스트 갱신
    local frame = ui.GetFrame("adventure_book")
	local gb_achieve = GET_CHILD(frame, "gb_achieve")
	local achieveTab = GET_CHILD(gb_achieve, "achieveTab")
	local selectedTabName = achieveTab:GetSelectItemName();
	local category = ""
	local categoryIndex;
	
	if selectedTabName == "tab_achieve_search" then
		ADVENTURE_BOOK_ACHIEVE.RENEW("search")
		ADVENTURE_BOOK_ACHIEVE.FILL_INFO_RENEW("search")
	else
		local MainCategory = ADVENTURE_BOOK_ACHIEVE_CONTENT.GET_MAIN_CATEGORY(argNum)
		local SubCategory = ADVENTURE_BOOK_ACHIEVE_CONTENT.GET_SUB_CATEGORY(argNum)
	
		if ADVENTURE_BOOK_ACHIEVE_CONTENT.VAILD_MAIN_CATEGORY(MainCategory) == 1 then
			ADVENTURE_BOOK_ACHIEVE.RENEW(MainCategory)
			ADVENTURE_BOOK_ACHIEVE.FILL_INFO_RENEW(MainCategory)
		end
	end

end

function ON_UPDATE_GET_ACHIEVE_REWARD_ALL(frame, msg, argStr, argNum)
	local MainCategory = ADVENTURE_BOOK_ACHIEVE_CONTENT.GET_MAIN_CATEGORY(argNum)
	local SubCategory = ADVENTURE_BOOK_ACHIEVE_CONTENT.GET_SUB_CATEGORY(argNum)

	if ACHIEVE_BOOK_ACHIEVE_GET_REWARD_ALL(MainCategory, SubCategory) == 1 then
		return
	end

	if ADVENTURE_BOOK_ACHIEVE_CONTENT.VAILD_MAIN_CATEGORY(MainCategory) == 1 then
		ADVENTURE_BOOK_ACHIEVE.RENEW(MainCategory)
		ADVENTURE_BOOK_ACHIEVE.FILL_INFO_RENEW(MainCategory)
	end
end

function ACHIEVE_BOOK_ACHIEVE_CLICK_GET_REWARD_ALL(parent, ctrl)
	local MainCategory = ctrl:GetUserValue("MainCategory")
	local SubCategory = ctrl:GetUserValue("SubCategory")
	
	ACHIEVE_BOOK_ACHIEVE_GET_REWARD_ALL(MainCategory, SubCategory)
	
	ctrl:SetEnable(0)
end

function ACHIEVE_BOOK_ACHIEVE_GET_REWARD_ALL(MainCategory, SubCategory)
	local list = ADVENTURE_BOOK_ACHIEVE_CONTENT.LIST_ALL(MainCategory, SubCategory)
	for i = 1, #list do
		local clsID = list[i]
		if ADVENTURE_BOOK_ACHIEVE_CONTENT.IS_HAVE_REWARD(clsID) == 1 and
		   ADVENTURE_BOOK_ACHIEVE_CONTENT.IS_COMPLETE(clsID) == 1 then
			session.ReqAchieveReward(clsID, true);
			return 1;
		end
	end

	return 0;
end

function ADVENTURE_BOOK_ACHIEVE_INIT_LEVEL_REWARD()
	local frame = ui.GetFrame("adventure_book")
	local gb_achieve = GET_CHILD(frame, "gb_achieve")
	local page_achieve_main = GET_CHILD(gb_achieve, "page_achieve_main")
	local achieve_main_level_reward_bg = GET_CHILD(page_achieve_main, "achieve_main_level_reward_bg")
	local level_reward_body_bg = GET_CHILD(achieve_main_level_reward_bg, "level_reward_body_bg")
	local level_reward_body = GET_CHILD(level_reward_body_bg, "level_reward_body")
	local level_reward_body_scroll = GET_CHILD(level_reward_body, "level_reward_body_scroll")
	local left_btn = GET_CHILD(level_reward_body_bg, "level_reward_left_btn")
	local right_btn = GET_CHILD(level_reward_body_bg, "level_reward_right_btn")
	local page_achieve_main_left = GET_CHILD(page_achieve_main, "page_achieve_main_left")
	local page_achieve_main_info = GET_CHILD(page_achieve_main_left, "page_achieve_main_info")
	local newreward = GET_CHILD(page_achieve_main_info, "newreward")

	local isNewReward = 0
	local list, cnt = GetClassList("AchieveLevelReward")
	local CurAchieveLevel = GetAchieveLevel()

	local isShow = achieve_main_level_reward_bg:IsVisible()

	-- 외부 상자 버튼 업데이트
	if isShow == 0 then
		for i = 0, cnt - 1 do
			local cls = GetClassByIndexFromList(list, i);
			if isNewReward == 0 and IS_GET_REWARD_ACHIEVE_LEVEL(cls.ClassID) == 0 then
				local NeedAchieveLevel = TryGetProp(cls, "AchieveLevel")
				if NeedAchieveLevel <= CurAchieveLevel then
					isNewReward = 1
					break
				end
			end
		end
		newreward:ShowWindow(isNewReward)
		return
	end

	-- 내부 리스트 업데이트
	level_reward_body_scroll:RemoveAllChild()

	for i = 0, cnt - 1 do
		local cls = GetClassByIndexFromList(list, i);
		ADVENTURE_BOOK_ACHIEVE_LEVEL_REWARD_CTRL(level_reward_body_scroll, i, cls)
		
		if isNewReward == 0 and IS_GET_REWARD_ACHIEVE_LEVEL(cls.ClassID) == 0 then
			local NeedAchieveLevel = TryGetProp(cls, "AchieveLevel")
			if NeedAchieveLevel <= CurAchieveLevel then
				isNewReward = 1
			end
		end
	end

	local max_view = 3
	local ctrl_width = 120
	local ctrl_space = 5
	if cnt < max_view then
		level_reward_body:Resize(ctrl_width * cnt + ctrl_space * (cnt - 1), level_reward_body:GetHeight())
	else
		level_reward_body:Resize(ctrl_width * max_view + ctrl_space * (max_view - 1), level_reward_body:GetHeight())
	end
	level_reward_body_scroll:Resize(ctrl_width * cnt + ctrl_space * (cnt - 1), level_reward_body_scroll:GetHeight())
	
	if level_reward_body_scroll:GetUserValue("pos") == "None" then
		level_reward_body_scroll:SetUserValue("pos", 1)
	end
    level_reward_body_scroll:SetUserValue("max_view", max_view)
    level_reward_body_scroll:SetUserValue("ctrl_width", ctrl_width)
	level_reward_body_scroll:SetUserValue("ctrl_space", ctrl_space)
	
	local pos = level_reward_body_scroll:GetUserIValue("pos")
	
	if pos == 1 then
		left_btn:SetEnable(0)
	else
		left_btn:SetEnable(1)
	end
	
    if (max_view < cnt) and (cnt - max_view + 1 >= pos) then
        right_btn:SetEnable(1)
    else
        right_btn:SetEnable(0)
	end
end

function ADVENTURE_BOOK_ACHIEVE_LEVEL_REWARD_CTRL(gbox, idx, cls)
	if cls == nil then return end

	local ctrl_width = 120
	local ctrl_space = 5
	local x = (ctrl_width * idx) + (ctrl_space * idx)

	local clsID = TryGetProp(cls, "ClassID")
	if clsID == nil then return end
	
	local ctrlset = gbox:CreateOrGetControlSet("adventure_book_achieve_level_reward", "achieve_level_reward_"..clsID, ui.LEFT, ui.TOP, x, 0, 0, 0)
	ADVENTURE_BOOK_ACHIEVE_UPDATE_LEVEL_REWARD(clsID, ctrlset)
end 

function ADVENTURE_BOOK_ACHIEVE_UPDATE_LEVEL_REWARD(clsID, ctrlset)	
	if ctrlset == nil then
		local frame = ui.GetFrame("adventure_book")
		local gb_achieve = GET_CHILD(frame, "gb_achieve")
		local page_achieve_main = GET_CHILD(gb_achieve, "page_achieve_main")
		local achieve_main_level_reward_bg = GET_CHILD(page_achieve_main, "achieve_main_level_reward_bg")
		local level_reward_body_bg = GET_CHILD(achieve_main_level_reward_bg, "level_reward_body_bg")
		local level_reward_body = GET_CHILD(level_reward_body_bg, "level_reward_body")
		local level_reward_body_scroll = GET_CHILD(level_reward_body, "level_reward_body_scroll")
		ctrlset = GET_CHILD(level_reward_body_scroll, "achieve_level_reward_"..clsID)
	end
	if ctrlset == nil then return end

	local clsRewardList, clsRewardListCnt = GetClassList("AchieveLevelReward")
	if clsRewardList == nil or clsRewardListCnt == 0 then return end

	local cls = GetClassByType("AchieveLevelReward", clsID)
	if cls == nil then return end

	local gb = GET_CHILD(ctrlset, "gb")
	local gb_level = GET_CHILD(ctrlset, "gb_level")
	local level_text = GET_CHILD(gb_level, "level_text", "ui::CRichText")
	local gb_slot = GET_CHILD(ctrlset, "gb_slot")
	local slot_reward = GET_CHILD(gb_slot, "slot_reward", "ui::CSlot")
	local disable_shadow = GET_CHILD(ctrlset, "disable_shadow")
	local icon_receive_complete = GET_CHILD(ctrlset, "icon_receive_complete")
	local icon_gettable = GET_CHILD(ctrlset, "icon_gettable")

	-- 보상 여부
	local isGetReward = IS_GET_REWARD_ACHIEVE_LEVEL(clsID)
	local isNextReward = 0

	if isGetReward == 0 then
		for i = 0, clsRewardListCnt - 1 do
			local clsLevelReward = GetClassByIndexFromList(clsRewardList, i);
			local clsIDReward = TryGetProp(clsLevelReward, "ClassID");
			
			if IS_GET_REWARD_ACHIEVE_LEVEL(clsIDReward) == 0 then
				if clsIDReward == clsID then
					isNextReward = 1
				end
				break
			end
		end
	end

	if isGetReward == 1 then
		disable_shadow:SetVisible(1)
		icon_receive_complete:SetVisible(1)
	else
		if isNextReward == 1 then
			disable_shadow:SetVisible(0)
		else
			disable_shadow:SetVisible(1)
		end
		icon_receive_complete:SetVisible(0)
	end

	if GetServerNation() ~= "KOR" and GetServerNation() ~= "GLOBAL_KOR" then
		icon_receive_complete:SetImage('receive_complete_eng')
	end

	local NeedAchieveLevel = TryGetProp(cls, "AchieveLevel")

	-- 수령 가능 여부
	local CurAchieveLevel = GetAchieveLevel()
	if isGetReward == 0 then
		if NeedAchieveLevel <= CurAchieveLevel then
			icon_gettable:SetVisible(1)
		else
			icon_gettable:SetVisible(0)
		end
	else
		icon_gettable:SetVisible(0)
	end

	-- 보상 스크립트
	gb:SetEventScript(ui.LBUTTONUP, "ADVENTURE_BOOK_ACHIEVE_LEVEL_REWARD_REQUEST_REWARD")
	gb:SetEventScriptArgNumber(ui.LBUTTONUP, cls.ClassID)
	
	slot_reward:SetEventScript(ui.LBUTTONUP, "ADVENTURE_BOOK_ACHIEVE_LEVEL_REWARD_REQUEST_REWARD")
	slot_reward:SetEventScriptArgNumber(ui.LBUTTONUP, cls.ClassID)

	-- 레벨
	level_text:SetTextByKey("value", NeedAchieveLevel)
	
	-- 보상 아이템
	local ItemClassName = TryGetProp(cls, "ItemName")
	local ItemCount = TryGetProp(cls, "Count")
	local ItemCls = GetClassByStrProp("Item", "ClassName", ItemClassName)
	if ItemClassName ~= nil and ItemCount ~= nil and ItemCls ~= nil then		
		local icon = CreateIcon(slot_reward)
		iconName = TryGetProp(ItemCls, "Icon", "None")
		if iconName ~= "None" then
			icon:SetImage(iconName) -- 아이콘
			SET_SLOT_COUNT_TEXT(slot_reward, ItemCount) -- 갯수
			SET_ITEM_TOOLTIP_BY_NAME(icon, ItemCls.ClassName); -- 툴팁
			icon:SetTooltipOverlap(1);
		end
	end
end

function ADVENTURE_BOOK_ACHIEVE_CLICK_LEVEL_REWARD(parent, ctrl)
	local frame = ui.GetFrame("adventure_book")
	local gb_achieve = GET_CHILD(frame, "gb_achieve")
	local page_achieve_main = GET_CHILD(gb_achieve, "page_achieve_main")
	local achieve_main_level_reward_bg = GET_CHILD(page_achieve_main, "achieve_main_level_reward_bg")

	if achieve_main_level_reward_bg:IsVisible() == 1 then	
		achieve_main_level_reward_bg:ShowWindow(0)
	else
		achieve_main_level_reward_bg:ShowWindow(1)
		ADVENTURE_BOOK_ACHIEVE_INIT_LEVEL_REWARD()
	end
end

function ADVENTURE_BOOK_ACHIEVE_LEVEL_REWARD_CLOSE(parent, ctrl)
	parent:GetParent():ShowWindow(0)
end

function ADVENTURE_BOOK_ACHIEVE_LEVEL_REWARD_LEFT_BTN(parent, ctrl)
	local frame = ui.GetFrame("adventure_book")
	local gb_achieve = GET_CHILD(frame, "gb_achieve")
	local page_achieve_main = GET_CHILD(gb_achieve, "page_achieve_main")
	local achieve_main_level_reward_bg = GET_CHILD(page_achieve_main, "achieve_main_level_reward_bg")
	local level_reward_body_bg = GET_CHILD(achieve_main_level_reward_bg, "level_reward_body_bg")
	local level_reward_body = GET_CHILD(level_reward_body_bg, "level_reward_body")
	local level_reward_body_scroll = GET_CHILD(level_reward_body, "level_reward_body_scroll")
	local btn_left = GET_CHILD(level_reward_body_bg, "level_reward_left_btn")
	local btn_right = GET_CHILD(level_reward_body_bg, "level_reward_right_btn")

	local pos = tonumber(level_reward_body_scroll:GetUserValue("pos"))
	local max_view = tonumber(level_reward_body_scroll:GetUserValue("max_view"))
	local ctrl_width = tonumber(level_reward_body_scroll:GetUserValue("ctrl_width"))
	local ctrl_space = tonumber(level_reward_body_scroll:GetUserValue("ctrl_space"))
	local list, num = GetClassList("AchieveLevelReward")
	
	pos = pos - 1

	if pos < 1 then
		pos = 1
	end

	level_reward_body_scroll:SetUserValue("pos", pos)

	if pos == 1 then
		btn_left:SetEnable(0)
	end

	if max_view < num then
		if num - max_view + 1 >= pos then
			btn_right:SetEnable(1)
		end
	end

	level_reward_body_scroll:SetMargin(-((pos - 1) * (ctrl_width + ctrl_space)), 0, 0, 0)

end

function ADVENTURE_BOOK_ACHIEVE_LEVEL_REWARD_RIGHT_BTN(parent, ctrl)
	local frame = ui.GetFrame("adventure_book")
	local gb_achieve = GET_CHILD(frame, "gb_achieve")
	local page_achieve_main = GET_CHILD(gb_achieve, "page_achieve_main")
	local achieve_main_level_reward_bg = GET_CHILD(page_achieve_main, "achieve_main_level_reward_bg")
	local level_reward_body_bg = GET_CHILD(achieve_main_level_reward_bg, "level_reward_body_bg")
	local level_reward_body = GET_CHILD(level_reward_body_bg, "level_reward_body")
	local level_reward_body_scroll = GET_CHILD(level_reward_body, "level_reward_body_scroll")
	local btn_left = GET_CHILD(level_reward_body_bg, "level_reward_left_btn")
	local btn_right = GET_CHILD(level_reward_body_bg, "level_reward_right_btn")

	local pos = tonumber(level_reward_body_scroll:GetUserValue("pos"))
	local max_view = tonumber(level_reward_body_scroll:GetUserValue("max_view"))
	local ctrl_width = tonumber(level_reward_body_scroll:GetUserValue("ctrl_width"))
	local ctrl_space = tonumber(level_reward_body_scroll:GetUserValue("ctrl_space"))
	local list, num = GetClassList("AchieveLevelReward")
	
	pos = pos + 1

	if pos > num - max_view + 1 then
		pos = num - max_view + 1
	end
	
	level_reward_body_scroll:SetUserValue("pos", pos)

	if pos == num - max_view + 1 then
		btn_right:SetEnable(0)
	end

	if max_view < num then
		if pos > 1 then
			btn_left:SetEnable(1)
		end
	end

	level_reward_body_scroll:SetMargin(-((pos - 1) * (ctrl_width + ctrl_space)), 0, 0, 0)
end


-- argnum: Achieve Exchange Reward Class ID
function ADVENTURE_BOOK_ACHIEVE_LEVEL_REWARD_REQUEST_REWARD(parent, ctrl, argStr, argNum)
    local cls = GetClassByType("AchieveLevelReward", argNum)
    if cls == nil then return end

    local ItemName = TryGetProp(cls, "ItemName")
    if ItemName == nil then return end

    local itemCls = GetClassByStrProp("Item", "ClassName", ItemName)
    if itemCls == nil then return end

	local NeedAchieveLevel = TryGetProp(cls, "AchieveLevel")
	if NeedAchieveLevel == nil then return end

	-- 보상 수령 여부 확인
	if IS_GET_REWARD_ACHIEVE_LEVEL(argNum) == 1 then
		return
	end

	-- 업적 레벨 확인 필요
    local account = session.barrack.GetMyAccount()
    local CurAchieveLevel = GetAchieveLevel()

	if NeedAchieveLevel > CurAchieveLevel then
		ui.MsgBox(ClMsg("achieve_level_reward_not_enough_achieve_level"))
		return
	end

	local msg = ClMsg("achieve_level_reward_confirm")

    ui.MsgBox(msg, "ADVENTURE_BOOK_ACHIEVE_LEVEL_REWARD_REQUEST_REWARD_ACCEPT("..argNum..")", "None")
end

function ADVENTURE_BOOK_ACHIEVE_LEVEL_REWARD_REQUEST_REWARD_ACCEPT(classID)
    session.ReqAchieveLevelReward(classID)
end

-- 성장 업적
function ADVENTURE_BOOK_GUIDEQUEST_CHAPTER_SELECT(select, argNum, argStr)
	local MainCategoryList = ADVENTURE_BOOK_ACHIEVE_CONTENT.GET_MAIN_CATEGORY_CLASS_LIST()
	local MainCategory = TryGetProp(MainCategoryList[argNum], "ClassName", "None")
	if MainCategory == "None" then return end

	local frame = ui.GetFrame("adventure_book")
	local gb_achieve = frame:GetChild('gb_achieve')
	local page = gb_achieve:GetChild("page_achieve_list_"..MainCategory)
	if page == nil then return end

	page:SetUserValue("SubCategory", argStr)
	
	ADVENTURE_BOOK_ACHIEVE_SUBCATEGORY_SELECT[argNum] = argStr
	ADVENTURE_BOOK_ACHIEVE_GUIDEQUEST_SELECT = tonumber(select)
	ADVENTURE_BOOK_RENEW_SELECTED_TAB_ACHIEVE()
end

function ADVENTURE_BOOK_RBTNUP_SUBCATEGORY_GUIDEQUEST(parent, ctrl)
	if ADVENTURE_BOOK_ACHIEVE_GUIDEQUEST_CATEGORY == nil or #ADVENTURE_BOOK_ACHIEVE_GUIDEQUEST_CATEGORY == 0 then
		ADVENTURE_BOOK_ACHIEVE_CREATE_GUIDEQUEST_CHAPTER()
	end

	local incompleteList = {}
	local completeList = {}
	for i = 1, #ADVENTURE_BOOK_ACHIEVE_GUIDEQUEST_CATEGORY do
		local chapterInfo = ADVENTURE_BOOK_ACHIEVE_GUIDEQUEST_CATEGORY[i]
		if chapterInfo.Complete == 0 then
			table.insert(incompleteList, { Name = dic.getTranslatedStr(chapterInfo.Name), Index = i })
		else
			table.insert(completeList, { Name = dic.getTranslatedStr(chapterInfo.Name), Index = i })
		end
	end

	local argNum = ctrl:GetEventScriptArgNumber(ui.LBUTTONUP)
	local argStr = ctrl:GetEventScriptArgString(ui.LBUTTONUP)

	local context = ui.CreateContextMenu("GUIDEQUEST_CONTEXT_MENU", '', 0, 0, 100, 100)
	for i = 1, #incompleteList do
		local index = incompleteList[i].Index
		local name = incompleteList[i].Name
		local strscp = string.format('ADVENTURE_BOOK_GUIDEQUEST_CHAPTER_SELECT(%d, %d, \'%s\')', index, argNum, argStr)
		ui.AddContextMenuItem(context, name, strscp)
	end
	for i = 1, #completeList do
		local index = completeList[i].Index
		local name = completeList[i].Name
		local strscp = string.format('ADVENTURE_BOOK_GUIDEQUEST_CHAPTER_SELECT(%d, %d, \'%s\')', index, argNum, argStr)
		ui.AddContextMenuItem(context, '[' .. ClMsg('COMPLETE') .. ']' .. name, strscp)
	end
	ui.OpenContextMenu(context)
end