ADVENTURE_BOOK_ACHIEVE_CONTENT = {}

function ADVENTURE_BOOK_ACHIEVE_CONTENT.LIST_ALL(category, subCategory, isCheckCompleteOption)
	local RewardList, ChaseList, ExistHistoryList, ExceptHistoryList, FinishList = ADVENTURE_BOOK_ACHIEVE_CONTENT.LIST_SPLIT(1)
	
	-- filter
	local filter_func = ADVENTURE_BOOK_ACHIEVE_CONTENT["FILTER_LIST"]

	local frame = ui.GetFrame('adventure_book');
	local gb_achieve = GET_CHILD(frame, "gb_achieve")

	local searchText = nil
	if category == "search" then
		local page = GET_CHILD(gb_achieve, "page_achieve_list_search", "ui::CGroupBox");
		local page_left = GET_CHILD(page, "page_achieve_list_search_left", "ui::CGroupBox");
		local gb_achieve_search_input = GET_CHILD(page_left, "gb_achieve_search_input", "ui::CGroupBox")
		local search_editbox = GET_CHILD(gb_achieve_search_input, "search_editbox", "ui::CEditControl")
		searchText = search_editbox:GetText()
	end

	-- 보상 받을 수 있는 목록
	RewardList = filter_func(RewardList, category, subCategory, searchText)
	table.sort(RewardList)

	-- 추적중인 업적
	ChaseList = filter_func(ChaseList, category, subCategory, searchText)
	table.sort(ChaseList)

	-- 이력이 있는 업적
	ExistHistoryList = filter_func(ExistHistoryList, category, subCategory, searchText)
	table.sort(ExistHistoryList, ADVENTURE_BOOK_ACHIEVE_CONTENT['SORT_BY_PROGRESS_DES'])

	-- 이력이 없는 업적
	ExceptHistoryList = filter_func(ExceptHistoryList, category, subCategory, searchText)
	table.sort(ExceptHistoryList)

	-- 완료된 업적
	-- 완료된 업적 표시하지 않기 체크 확인
	-- search에서는 확인하지 않음
	local frame = ui.GetFrame("adventure_book")
	local gb_achieve = GET_CHILD(frame, "gb_achieve")
	local page_achieve_list_search = GET_CHILD(gb_achieve, "page_achieve_list_search")
	local page_achieve_list_search_left = GET_CHILD(page_achieve_list_search, "page_achieve_list_search_left")
	local droplist_option_maincategory = GET_CHILD(page_achieve_list_search_left, "droplist_option_maincategory", "ui::CDropList")
	local droplist_option_subcategory = GET_CHILD(page_achieve_list_search_left, "droplist_option_subcategory", "ui::CDropList")
	
	if ADVENTURE_BOOK_ACHIEVE_CONTENT.VAILD_MAIN_CATEGORY(category) == 1 then
		if isCheckCompleteOption == 1 then
			local page_achieve_list = GET_CHILD(gb_achieve, "page_achieve_list_"..category)
			local page_achieve_list_left = GET_CHILD(page_achieve_list, "page_achieve_list_"..category.."_left")
			local check_option_invisible_complete = GET_CHILD(page_achieve_list_left, "check_option_invisible_complete", "ui::CCheckBox")

			if check_option_invisible_complete:IsChecked() == 1 then
				FinishList = {}
			end
		end
	end
	if #FinishList > 0 then
		FinishList = filter_func(FinishList, category, subCategory, searchText)
		table.sort(FinishList)
	end

	-- combine list
	local newRet = {};

	for i=1, #RewardList do
		newRet[#newRet+1] = RewardList[i]
	end

	for i=1, #ChaseList do
		newRet[#newRet+1] = ChaseList[i]
	end

	for i=1, #ExistHistoryList do
		newRet[#newRet+1] = ExistHistoryList[i]
	end

	for i=1, #ExceptHistoryList do
		newRet[#newRet+1] = ExceptHistoryList[i]
	end
	
	for i=1, #FinishList do
		newRet[#newRet+1] = FinishList[i]
	end

	return newRet;
end

function ADVENTURE_BOOK_ACHIEVE_CONTENT.IS_VISIBLE(clsID)
	local cls = GetClassByType("Achieve", clsID);
	if cls == nil then return 0 end

	local mainCategory = TryGetProp(cls, "MainCategory")
	if mainCategory == nil then return 0 end
	if mainCategory == "None" then return 0 end

	return 1;
end

function ADVENTURE_BOOK_ACHIEVE_CONTENT.IS_PREVIEW(clsID)
	local cls = GetClassByType("Achieve", clsID);
	if cls == nil then return 0 end

	local hidden = TryGetProp(cls, "Hidden", "NO")
	if hidden == "YES" then return 0 end
	
	return 1;
end

function ADVENTURE_BOOK_ACHIEVE_CONTENT.IS_COMPLETE(clsID) -- 성공 여부
	if clsID == nil then
		return 0
	end
	if HAVE_ACHIEVE_FIND(clsID) == 0 then
		return 0
	end
	
	local cls = GetClassByType("Achieve", clsID);
	if cls == nil then return 0 end

	local needCount = TryGetProp(cls, "NeedCount");
	local point = GetAchievePoint(GetMyPCObject(), cls.NeedPoint)
	if point < needCount then
		return 0
	end

	return 1
end

function ADVENTURE_BOOK_ACHIEVE_CONTENT.IS_HAVE_REWARD(clsID) -- 받아야 할 보상이 있는지 여부
	local cls = GetClassByType("Achieve", clsID);
	if cls == nil then return nil end
	
	local RewardItem = TryGetProp(cls, "RewardItem", "None")
	local GainScript = TryGetProp(cls, "GainScript", "None")

	if RewardItem == "None" and GainScript == "None" then
		return 0
	end

	local accObj = GetMyAccountObj();
	local value = TryGetProp(accObj, "AchieveReward_"..cls.ClassName)
	local oldReward = TryGetProp(cls, "OldReward", "NO")
	if oldReward == "YES" then
		if value == 3 then
			return 0
		else
			return 1
		end
	else
		if value ~= nil and value == 0 then
			return 1
		end
	end

	return 0
end

function ADVENTURE_BOOK_ACHIEVE_CONTENT.IS_TIME_START(clsID) -- 기간이 시작된 경우
	local cls = GetClassByType("Achieve", clsID)
	if cls == nil then return 0 end
	
	local NeedPoint = TryGetProp(cls, "NeedPoint", "None")
	if NeedPoint == "None" then return 0, "None" end

	local clsPoint = GetClassByStrProp("AchievePoint", "ClassName", NeedPoint)
	if clsPoint == nil then return 0, "None" end

	local StartTime = TryGetProp(clsPoint, "StartTime", "None")
	if StartTime == "None" then
		return 1
	end
	
	local getnow = geTime.GetServerSystemTime()
	local nowstr = string.format("%04d-%02d-%02d %02d:%02d:%02d", getnow.wYear, getnow.wMonth, getnow.wDay, getnow.wHour, getnow.wMinute, getnow.wSecond)
	
	local remainsec = date_time.get_lua_datetime_from_str(StartTime) - date_time.get_lua_datetime_from_str(nowstr)
	if remainsec < 0 then return 1 end

	return 0
end

function ADVENTURE_BOOK_ACHIEVE_CONTENT.IS_TIME_END(clsID) -- 기간이 경과한 경우
	local isEnableTime, remainsec = ADVENTURE_BOOK_ACHIEVE_CONTENT.GET_REMAIN_TIME(clsID)
	if isEnableTime == 0 then return 0 end
	
	if remainsec < 0 then return 1 end

	return 0
end

function ADVENTURE_BOOK_ACHIEVE_CONTENT.IS_CHASE(clsID) -- 추적중인 업적
	if achieve.IsChaseAchieve(clsID) == true then
		return 1
	end
	
	return 0
end

function ADVENTURE_BOOK_ACHIEVE_CONTENT.EXIST_IN_HISTORY(clsID) -- 신규 업적
	local cls = GetClassByType("Achieve", clsID);
	if cls == nil then return 0 end

	local point = GetAchievePoint(GetMyPCObject(), cls.NeedPoint)
	if point >= 1 then
		return 1
	end

	return 0
end

function ADVENTURE_BOOK_ACHIEVE_CONTENT.IS_NEW_ACHIEVE(clsID)
	local cls = GetClassByType("Achieve", clsID);
	if cls == nil then return 0 end

	if TryGetProp(cls, "NewAchieve", "None") == "YES" then
		return 1
	end

	return 0
end

function ADVENTURE_BOOK_ACHIEVE_CONTENT.CHECK_COUNTRY(clsID) -- 국가 체크
	local cls = GetClassByType("Achieve", clsID)
	if cls == nil then return 0 end
	
	local NeedPoint = TryGetProp(cls, "NeedPoint", "None")
	if NeedPoint == "None" then return 0, "None" end

	local clsPoint = GetClassByStrProp("AchievePoint", "ClassName", NeedPoint)
	if clsPoint == nil then return 0, "None" end

	local Country = TryGetProp(clsPoint, "Country", "None")
	if Country == "None" then
		return 1
	end

	local CountryList = StringSplit(Country, '/')
	local CurCountry = config.GetServiceNation()
	for i = 1, #CountryList do
		if CountryList[i] == CurCountry then
			return 1
		end
	end

	return 0
end

function ADVENTURE_BOOK_ACHIEVE_CONTENT.LIST_SPLIT(checkChase)
	local RewardList = {} -- 보상이 있는 업적
	local ChaseList = {} -- 추적중인 업적
	local ExistHistoryList = {} -- 이력이 있는 업적
	local ExceptHistoryList = {} -- 이력이 없는 업적
	local FinishList = {} -- 완료된 업적 & 기간이 끝난 업적

	local list, cnt = GetClassList("Achieve");
	for i = 0, cnt - 1 do
		local cls = GetClassByIndexFromList(list, i);
		local clsID = TryGetProp(cls, "ClassID");
		if ADVENTURE_BOOK_ACHIEVE_CONTENT.IS_VISIBLE(clsID) == 1 then
			if ADVENTURE_BOOK_ACHIEVE_CONTENT.CHECK_COUNTRY(clsID) == 1 then
				if ADVENTURE_BOOK_ACHIEVE_CONTENT.IS_COMPLETE(clsID) == 1 then  -- 성공 여부
					if ADVENTURE_BOOK_ACHIEVE_CONTENT.IS_HAVE_REWARD(clsID) == 1 then -- 보상받을것 여부
						RewardList[#RewardList + 1] = clsID; -- 성공O 보상받을것O
					else
						FinishList[#FinishList + 1] = clsID;  -- 성공O 보상받을것X
					end
				elseif checkChase == 1 and ADVENTURE_BOOK_ACHIEVE_CONTENT.IS_CHASE(clsID) == 1 then-- 추적중인 업적
					ChaseList[#ChaseList + 1] = clsID; -- 추적중(성공 시 추적 끝)
				else
					if ADVENTURE_BOOK_ACHIEVE_CONTENT.IS_TIME_START(clsID) == 1 then -- 기간 시작 여부
						if ADVENTURE_BOOK_ACHIEVE_CONTENT.IS_TIME_END(clsID) == 1 then -- 기간 경과 여부
							FinishList[#FinishList + 1] = clsID; -- 성공X 기간경과O
						else
							if ADVENTURE_BOOK_ACHIEVE_CONTENT.IS_PREVIEW(clsID) == 1 then -- 히든 여부
								if ADVENTURE_BOOK_ACHIEVE_CONTENT.EXIST_IN_HISTORY(clsID) == 1 then
									ExistHistoryList[#ExistHistoryList + 1] = clsID; -- 성공X 히든X 이력O
								else
									ExceptHistoryList[#ExceptHistoryList + 1] = clsID; -- 성공X 히든X 이력X
								end
							end
						end
					end
				end
			end
		end
	end
	
	return RewardList, ChaseList, ExistHistoryList, ExceptHistoryList, FinishList
end

function ADVENTURE_BOOK_ACHIEVE_CONTENT.LIST_COMPLETE() -- 완료된 업적 (기간이 끝난 업적은 포함되지 않음)
	local list, cnt = GetClassList("Achieve");
	local retTable = {};
	
	for i = 0, cnt - 1 do
		local cls = GetClassByIndexFromList(list, i);
		local clsID = TryGetProp(cls, "ClassID");
		if ADVENTURE_BOOK_ACHIEVE_CONTENT.IS_VISIBLE(clsID) == 1 and
		   ADVENTURE_BOOK_ACHIEVE_CONTENT.CHECK_COUNTRY(clsID) == 1 and
	   	   ADVENTURE_BOOK_ACHIEVE_CONTENT.IS_COMPLETE(clsID) == 1 then
			retTable[#retTable + 1] = clsID
		end
	end
	
	return retTable;
end

function ADVENTURE_BOOK_ACHIEVE_CONTENT.FILTER_COMPLETE(list)
	local retTable = {}

	for i = 1, #list do
		local clsID = list[i]
		if ADVENTURE_BOOK_ACHIEVE_CONTENT.IS_VISIBLE(clsID) == 1 and
		   ADVENTURE_BOOK_ACHIEVE_CONTENT.CHECK_COUNTRY(clsID) == 1 and
	   	   ADVENTURE_BOOK_ACHIEVE_CONTENT.IS_COMPLETE(clsID) == 1 then
			retTable[#retTable + 1] = clsID
		end
	end

	return retTable
end

function ADVENTURE_BOOK_ACHIEVE_CONTENT.FILTER_REWARD(list)
	local retTable = {}

	for i = 1, #list do
		local clsID = list[i]
		if ADVENTURE_BOOK_ACHIEVE_CONTENT.IS_VISIBLE(clsID) == 1 and
		   ADVENTURE_BOOK_ACHIEVE_CONTENT.CHECK_COUNTRY(clsID) == 1 and
		   ADVENTURE_BOOK_ACHIEVE_CONTENT.IS_COMPLETE(clsID) == 1 and
		   ADVENTURE_BOOK_ACHIEVE_CONTENT.IS_HAVE_REWARD(clsID) == 1 then
			retTable[#retTable + 1] = clsID
		end
	end

	return retTable
end

function ADVENTURE_BOOK_ACHIEVE_CONTENT.LIST_REWARD() -- 보상을 받을 수 있는 업적 리스트 가져오기
	local RewardList, ChaseList, ExistHistoryList, ExceptHistoryList, FinishList = ADVENTURE_BOOK_ACHIEVE_CONTENT.LIST_SPLIT()
	return RewardList;
end

function ADVENTURE_BOOK_ACHIEVE_CONTENT.LIST_CHASE() -- 추적중인 리스트 가져오기
	local RewardList, ChaseList, ExistHistoryList, ExceptHistoryList, FinishList = ADVENTURE_BOOK_ACHIEVE_CONTENT.LIST_SPLIT()
	return ChaseList;
end

function ADVENTURE_BOOK_ACHIEVE_CONTENT.LIST_EXIST_HISTORY() -- 이력이 있는 업적 리스트 가져오기
	local RewardList, ChaseList, ExistHistoryList, ExceptHistoryList, FinishList = ADVENTURE_BOOK_ACHIEVE_CONTENT.LIST_SPLIT()
	return ExistHistoryList;
end

function ADVENTURE_BOOK_ACHIEVE_CONTENT.LIST_EXCEPT_HISTORY() -- 이력이 없는 업적 리스트 가져오기
	local RewardList, ChaseList, ExistHistoryList, ExceptHistoryList, FinishList = ADVENTURE_BOOK_ACHIEVE_CONTENT.LIST_SPLIT()
	return ExceptHistoryList;
end

function ADVENTURE_BOOK_ACHIEVE_CONTENT.LIST_NEW_ACHIEVE() -- 신규 업적 리스트 가져오기
	local retTable = {}

	local list, cnt = GetClassList("Achieve");	
	for i = 0, cnt - 1 do
		local cls = GetClassByIndexFromList(list, i);
		local clsID = TryGetProp(cls, "ClassID");

		if ADVENTURE_BOOK_ACHIEVE_CONTENT.IS_VISIBLE(clsID) == 1 and
		   ADVENTURE_BOOK_ACHIEVE_CONTENT.IS_PREVIEW(clsID) == 1 and
		   TryGetProp(cls, "NewAchieve", "None") == "YES" then
				retTable[#retTable + 1] = clsID
		end
	end

	return retTable;
end

function ADVENTURE_BOOK_ACHIEVE_CONTENT.LIST_MATCH_NEEDPOINT(clsID)
	local retTable = {}

	local clsPoint = GetClassByType("AchievePoint", clsID)
	if clsPoint == nil then return retTable end

	local NeedPointName = TryGetProp(clsPoint, "ClassName", "None")
	if NeedPointName == "None" then return retTable end

	local list, cnt = GetClassList("Achieve");	
	for i = 0, cnt - 1 do
		local cls = GetClassByIndexFromList(list, i);
		local achieveClsID = cls.ClassID
		local NeedPoint = TryGetProp(cls, "NeedPoint", "None");
		if ADVENTURE_BOOK_ACHIEVE_CONTENT.IS_VISIBLE(achieveClsID) == 1 and
		   ADVENTURE_BOOK_ACHIEVE_CONTENT.IS_PREVIEW(achieveClsID) == 1 then
			if NeedPointName == NeedPoint then
				retTable[#retTable + 1] = cls.ClassID
			end
		end
	end

	return retTable
end

function ADVENTURE_BOOK_ACHIEVE_CONTENT.LIST_NOT_TIME_START() -- START TIME이 지나지 않은 업적
	local retTable = {}

	local list, cnt = GetClassList("Achieve");	
	for i = 0, cnt - 1 do
		local cls = GetClassByIndexFromList(list, i);
		local clsID = TryGetProp(cls, "ClassID");

		if ADVENTURE_BOOK_ACHIEVE_CONTENT.IS_VISIBLE(clsID) == 1 and
		   ADVENTURE_BOOK_ACHIEVE_CONTENT.IS_TIME_START(clsID) == 0 then
			retTable[#retTable + 1] = clsID
		end
	end

	return retTable;
end

function ADVENTURE_BOOK_ACHIEVE_CONTENT.ACHIEVE_INFO(clsID)
	clsID = tonumber(clsID)

	local cls = GetClassByType("Achieve", clsID);
	if cls == nil then return nil end

	local retTable = {}

	retTable['clsID'] = clsID

	local main_category = TryGetProp(cls, "MainCategory", "None")
	if (main_category == nil or main_category == "" or main_category == "None") == false then
		if ADVENTURE_BOOK_ACHIEVE_CONTENT.VAILD_MAIN_CATEGORY(main_category) == 1 then
			retTable['main_category'] = main_category
			
			local clsMainCategory = GetClassByStrProp("AchieveInfo", "ClassName", main_category)
			retTable['main_category_icon'] = TryGetProp(clsMainCategory, "Icon", "")
			retTable['main_category_name'] = TryGetProp(clsMainCategory, "Name", "")
		end
	end

	local sub_category = TryGetProp(cls, "SubCategory", "None")
	if (sub_category == nil or sub_category == "" or sub_category == "None") == false then
		if ADVENTURE_BOOK_ACHIEVE_CONTENT.VAILD_SUB_CATEGORY(main_category, sub_category) == 1 then
			retTable['sub_category'] = sub_category
			
			local clsSubCategory = GetClassByStrProp("AchieveInfo", "ClassName", sub_category)
			retTable['sub_category_name'] = TryGetProp(clsSubCategory, "Name", "")
		else
			retTable['sub_category'] = "etc"
			retTable['sub_category_name'] = "adventure_book_achieve_subcategory_etc"
		end
	end
	
	local name = TryGetProp(cls, "Name");
	if (name == nil or name == "" or name == "None") == false then
		retTable['name'] = name
	end

	retTable['desc'] = TryGetProp(cls, "Desc");
	retTable['title'] = TryGetProp(cls, "DescTitle");
	retTable['reward'] = TryGetProp(cls, "Reward");

	retTable['need_count'] = TryGetProp(cls, "NeedCount");
	local point = GetAchievePoint(GetMyPCObject(), cls.NeedPoint)
	if point > retTable['need_count'] then
		point = retTable['need_count']
	end
	retTable['point'] = point

	local exp = TryGetProp(cls, "AchieveExp");
	if exp == nil then
		retTable['exp'] = 1
	else
		retTable['exp'] = exp
	end

	-- 구보상 예외 처리
	-- "HairColor"인 경우 받아온 이름, 아이콘을 그대로 띄움
	local reward = TryGetProp(cls, "Reward")
	if reward ~= nil and reward ~= "None" then
		retTable['reward'] = reward
		retTable['reward_type'] = TryGetProp(cls, "RewardType")
		if retTable['reward_type'] == "HairColor" then
			retTable['reward_icon'] = TryGetProp(cls, "RewardIcon")
		end
	end

	-- 신보상
	local rewardList = GET_REWARD_LIST(clsID)
	if rewardList ~= nil and #rewardList > 0 then
		local idx = 1
		for i = 1, #rewardList do
			local cls = GetClassByStrProp("Item", "ClassName", rewardList[i][1])
			if cls ~= nil then
				retTable['reward_item'..idx] = rewardList[i][1]
				retTable['reward_count'..idx] = rewardList[i][2]
				idx = idx + 1
			end
		end
		retTable['reward_count'] = idx - 1
	end

	-- 그룹
	local LevelGroup = TryGetProp(cls, "LevelGroup", "None")
	if LevelGroup ~= "None" then
		local LevelGroupSplit  = StringSplit(LevelGroup, '/')
		retTable['level_group_name'] = LevelGroupSplit[1]
		retTable['group_level'] = LevelGroupSplit[2]
	end

	retTable['is_chase'] = ADVENTURE_BOOK_ACHIEVE_CONTENT.IS_CHASE(clsID)
	retTable['is_reward'] = ADVENTURE_BOOK_ACHIEVE_CONTENT.IS_HAVE_REWARD(clsID)
	retTable['is_complete'] = ADVENTURE_BOOK_ACHIEVE_CONTENT.IS_COMPLETE(clsID)
	retTable['is_timeend'] = ADVENTURE_BOOK_ACHIEVE_CONTENT.IS_TIME_END(clsID)
	
	return retTable;
end

function ADVENTURE_BOOK_ACHIEVE_CONTENT.GET_MAIN_CATEGORY(clsID)
	local cls = GetClassByType("Achieve", clsID);
	if cls == nil then return nil end

	local main_category = TryGetProp(cls, "MainCategory", "None")
	if (main_category == nil or main_category == "" or main_category == "None") == false then
		if ADVENTURE_BOOK_ACHIEVE_CONTENT.VAILD_MAIN_CATEGORY(main_category) == 1 then
			return main_category
		end
	end

	return nil
end

function ADVENTURE_BOOK_ACHIEVE_CONTENT.GET_SUB_CATEGORY(clsID)
	local cls = GetClassByType("Achieve", clsID);
	if cls == nil then return nil end

	local main_category = TryGetProp(cls, "MainCategory", "None")
	if main_category == "None" then return nil end
	
	local sub_category = TryGetProp(cls, "SubCategory", "None")
	if (sub_category == nil or sub_category == "" or sub_category == "None") == false then
		if ADVENTURE_BOOK_ACHIEVE_CONTENT.VAILD_SUB_CATEGORY(main_category, sub_category) == 1 then
			return sub_category
		else
			return "etc"
		end
	end
	return nil
end

-- Class ID 오름차순 정렬
function ADVENTURE_BOOK_ACHIEVE_CONTENT.SORT_BY_CLASSID_ASC(a, b)
	return ADVENTURE_BOOK_SORT_PROP_BY_CLASSID_ASC('Achieve', 'classID', a, b)
end

-- Class ID 내림차순 정렬
function ADVENTURE_BOOK_ACHIEVE_CONTENT.SORT_BY_CLASSID_DES(a, b)
	return ADVENTURE_BOOK_SORT_PROP_BY_CLASSID_ASC('Achieve', 'classID', b, a)
end

-- 업적 진행도 내림차순 정렬
function ADVENTURE_BOOK_ACHIEVE_CONTENT.SORT_BY_PROGRESS_DES(a, b)
	return ADVENTURE_BOOK_SORT_PROP_BY_PROGRESS_ASC(b, a)
end

function ADVENTURE_BOOK_SORT_PROP_BY_PROGRESS_ASC(a, b)
	local clsA = GetClassByType("Achieve", a);
	local clsB = GetClassByType("Achieve", b);
	local needA = TryGetProp(clsA, "NeedCount")
	local needB = TryGetProp(clsB, "NeedCount")
	if needA == 0 then needA = 1 end
	if needB == 0 then needB = 1 end
	local pointA = GetAchievePoint(GetMyPCObject(), clsA.NeedPoint)
	local pointB = GetAchievePoint(GetMyPCObject(), clsB.NeedPoint)
	if TryGetProp(clsA, "LevelGroup", "None") ~= "None" then
		pointA = pointA - GetPrevLevelAchieveNeedCount(clsA.ClassID)
		needA = needA - GetPrevLevelAchieveNeedCount(clsA.ClassID)
	end
	if TryGetProp(clsB, "LevelGroup", "None") ~= "None" then
		pointB = pointB - GetPrevLevelAchieveNeedCount(clsB.ClassID)
		needB = needB - GetPrevLevelAchieveNeedCount(clsB.ClassID)
	end

	local progressA = tonumber(pointA) / tonumber(needA)
	local progressB = tonumber(pointB) / tonumber(needB)

	return progressA < progressB
end

-- AddDate 내림차순 정렬
function ADVENTURE_BOOK_ACHIEVE_CONTENT.SORT_BY_ADDDATE_DES(list)
    local dateList = {}
    local dateListSort = {}
    local retTable = {}

    -- 날짜순 정렬
    for i = 1, #list do
        local cls = GetClassByType("Achieve", list[i])
        local addDate = TryGetProp(cls, "AddDate", "None")
        local date = date_time.get_lua_datetime_from_str(addDate)
        if dateList[date] == nil then
            dateList[date] = {}
            dateListSort[#dateListSort + 1] = date
        end
        table.insert(dateList[date], cls.ClassID)
    end

    table.sort(dateListSort)
    
    local idx = #dateListSort
    while idx > 0 do
        for i = 1, #dateList[dateListSort[idx]] do
            retTable[#retTable + 1] = dateList[dateListSort[idx]][i]
        end
        idx = idx - 1
    end

    return retTable
end

function ADVENTURE_BOOK_ACHIEVE_CONTENT.FILTER_CATEGORY(list, category)
	local retTable = {}
	if ADVENTURE_BOOK_ACHIEVE_CONTENT.VAILD_MAIN_CATEGORY(category) == 1 then
		retTable = ADVENTURE_BOOK_SEARCH_PROP_BY_CLASSID_FROM_LIST(list, "Achieve", {"MainCategory"}, category)
	end

	return retTable
end

function ADVENTURE_BOOK_ACHIEVE_CONTENT.FILTER_SEARCH(list, searchText)
	if searchText == "" or searchText == nil then
		list = {}
		return list
	else
		return ADVENTURE_BOOK_FILTER_ITEM(list, ADVENTURE_BOOK_ACHIEVE_SEARCH_FUNC, "Achieve", {"Name", "DescTitle", "Reward"}, searchText)
	end
end

function ADVENTURE_BOOK_ACHIEVE_SEARCH_FUNC(clsID, idSpace, propName, searchText)
	if propName == "Name" or propName == "DescTitle" then
		if ADVENTURE_BOOK_SEARCH_PROP_BY_CLASSID_FUNC(clsID, idSpace, propName, searchText) == true then
			return true
		end
		return false
	elseif propName == "Reward" then
		-- 보상 아이템에서 찾기
		local rewardList = GET_REWARD_LIST(clsID)
		if rewardList ~= nil and #rewardList > 0 then
			for i = 1, #rewardList do
				local cls = GetClassByStrProp("Item", "ClassName", rewardList[i][1])
				if cls ~= nil then
					if ADVENTURE_BOOK_SEARCH_PROP_BY_CLASSID_FUNC(cls.ClassID, "Item", "Name", searchText) == true then
						return true
					end
				end
			end
		end

		-- 예외 보상에서 찾기 (아이템, 머리)
		searchText = string.lower(searchText);
		local cls = GetClassByType("Achieve", clsID)
		if cls ~= nil then
			local RewardType = TryGetProp(cls, "RewardType", "None")
			local Reward = TryGetProp(cls, "Reward", "None")
			if RewardType == "Item" and Reward ~= "None" then
				local RewardList = StringSplit(Reward, "/")
				local itemCls = GetClassByStrProp("Item", "ClassName", RewardList[1])
				if itemCls ~= nil then
					if ADVENTURE_BOOK_SEARCH_PROP_BY_CLASSID_FUNC(itemCls.ClassID, "Item", "Name", searchText) == true then
						return true
					end
				end
			elseif RewardType == "HairColor" then
				local prop = Reward
				if config.GetServiceNation() ~= "KOR" then
					prop = dic.getTranslatedStr(prop);
				end
				prop = string.lower(prop)
				if string.find(prop, searchText) ~= nil then
					return true
				end
			end
		end
	end
	
	return false
end

function ADVENTURE_BOOK_ACHIEVE_CONTENT.FILTER_PERIOD(list, checkCurTime)
	local retList = {}

	for i = 1, #list do
		local cls = GetClassByType("Achieve", list[i])
		if cls ~= nil then
			local clsPoint = GetClassByStrProp("AchievePoint", "ClassName", cls.NeedPoint)
			if clsPoint ~= nil then
				local EndTime = TryGetProp(clsPoint, "EndTime", "None")
				if EndTime ~= "None" then
					if checkCurTime == 1 then
						local success, second = ADVENTURE_BOOK_ACHIEVE_CONTENT.GET_REMAIN_TIME(cls.ClassID)
						if success == 0 then
							retList[#retList + 1] = list[i]
						else
							if second > 0 then
								retList[#retList + 1] = list[i]
							end
						end
					else
						retList[#retList + 1] = list[i]
					end
				end
			end
		end
	end

	return retList
end

function ADVENTURE_BOOK_ACHIEVE_CONTENT.FILTER_NON_PERIOD(list)
	local retList = {}

	for i = 1, #list do
		local cls = GetClassByType("Achieve", list[i])
		if cls ~= nil then
			local clsPoint = GetClassByStrProp("AchievePoint", "ClassName", cls.NeedPoint)
			if clsPoint ~= nil then
				local EndTime = TryGetProp(clsPoint, "EndTime", "None")
				if EndTime == "None" then
					retList[#retList + 1] = list[i]
				end
			end
		end
	end

	return retList
end


function ADVENTURE_BOOK_ACHIEVE_CONTENT.FILTER_ONLYETC(list, mainCategory)
	local retList = {}

	for i = 1, #list do
		local cls = GetClassByType("Achieve", list[i])
		if cls ~= nil then
			if ADVENTURE_BOOK_ACHIEVE_CONTENT.VAILD_SUB_CATEGORY(mainCategory, TryGetProp(cls, "SubCategory")) == 0 then
				retList[#retList + 1] = list[i]
			end
		end
	end

	return retList
end

function ADVENTURE_BOOK_ACHIEVE_CONTENT.FILTER_LIST(list, mainCategory, subCategory, searchText)
	if mainCategory == "search" then
		local frame = ui.GetFrame("adventure_book")
		local gb_achieve = GET_CHILD(frame, "gb_achieve")
		local page_achieve_list_search = GET_CHILD(gb_achieve, "page_achieve_list_search")
		local page_achieve_list_search_left = GET_CHILD(page_achieve_list_search, "page_achieve_list_search_left")
		local droplist_option_maincategory = GET_CHILD(page_achieve_list_search_left, "droplist_option_maincategory", "ui::CDropList")
		local droplist_option_subcategory = GET_CHILD(page_achieve_list_search_left, "droplist_option_subcategory", "ui::CDropList")

		local listMain = ADVENTURE_BOOK_ACHIEVE_CONTENT.GET_SEARCH_FILTER_OPTION_LIST_MAINCATEGORY()
		local selMainCategory = listMain[droplist_option_maincategory:GetSelItemIndex() + 1][1]
		if selMainCategory ~= "All" then
			list = ADVENTURE_BOOK_EQUAL_PROP_BY_CLASSID_FROM_LIST(list, "Achieve", {"MainCategory"}, selMainCategory)
		end
		
		local listSub = ADVENTURE_BOOK_ACHIEVE_CONTENT.GET_SEARCH_FILTER_OPTION_LIST_SUBCATEGORY(selMainCategory)
		local selSubCategory = listSub[droplist_option_subcategory:GetSelItemIndex() + 1][1]
		if selSubCategory ~= "All" then
			list = ADVENTURE_BOOK_EQUAL_PROP_BY_CLASSID_FROM_LIST(list, "Achieve", {"SubCategory"}, selSubCategory)
		end

		list = ADVENTURE_BOOK_ACHIEVE_CONTENT.FILTER_SEARCH(list, searchText)

		local check_option_reward = GET_CHILD(page_achieve_list_search_left, "check_option_reward", "ui::CCheckBox")
		if check_option_reward:IsChecked() == 1 then
			list = ADVENTURE_BOOK_SEARCH_PROP_BY_CLASSID_FROM_LIST(list, "Achieve", {"RewardItem", "GainScript"}, "")
		end

		local check_option_name = GET_CHILD(page_achieve_list_search_left, "check_option_name", "ui::CCheckBox")
		if check_option_name:IsChecked() == 1 then
			list = ADVENTURE_BOOK_SEARCH_PROP_BY_CLASSID_FROM_LIST(list, "Achieve", {"Name"}, "")
		end

		local check_option_period = GET_CHILD(page_achieve_list_search_left, "check_option_period", "ui::CCheckBox")
		if check_option_period:IsChecked() == 1 then
			list = ADVENTURE_BOOK_ACHIEVE_CONTENT.FILTER_PERIOD(list)
		end
	else
		if ADVENTURE_BOOK_ACHIEVE_CONTENT.VAILD_MAIN_CATEGORY(mainCategory) == 1 then
			list = ADVENTURE_BOOK_ACHIEVE_CONTENT.FILTER_CATEGORY(list, mainCategory)

			list = ADVENTURE_BOOK_EQUAL_PROP_BY_CLASSID_FROM_LIST(list, "Achieve", {"MainCategory"}, mainCategory)
			local clsEtc = ADVENTURE_BOOK_ACHIEVE_CONTENT.GET_SUB_CATEGORY_ETC_CLASS()
			if subCategory ~= nil then
				if subCategory == clsEtc.ClassName then
					list = ADVENTURE_BOOK_ACHIEVE_CONTENT.FILTER_ONLYETC(list, mainCategory)
				else
					list = ADVENTURE_BOOK_EQUAL_PROP_BY_CLASSID_FROM_LIST(list, "Achieve", {"SubCategory"}, subCategory)
				end
			end
		elseif mainCategory ~= nil then
			list = {}
		end
	end
	
	return list;
end

function ADVENTURE_BOOK_ACHIEVE_CONTENT.GET_COUNT_MAX(category)
	local list = ADVENTURE_BOOK_ACHIEVE_CONTENT.LIST_ALL(category)
	if category == "Event" then
		list = ADVENTURE_BOOK_ACHIEVE_CONTENT.FILTER_PERIOD(list)
	else
		list = ADVENTURE_BOOK_ACHIEVE_CONTENT.FILTER_NON_PERIOD(list)
	end
	
	return #list
end

function ADVENTURE_BOOK_ACHIEVE_CONTENT.GET_COUNT_COMPLETE(category)
	local list = ADVENTURE_BOOK_ACHIEVE_CONTENT.LIST_COMPLETE()
	list = ADVENTURE_BOOK_ACHIEVE_CONTENT.FILTER_CATEGORY(list, category)
	if category == "Event" then
		list = ADVENTURE_BOOK_ACHIEVE_CONTENT.FILTER_PERIOD(list)
	else
		list = ADVENTURE_BOOK_ACHIEVE_CONTENT.FILTER_NON_PERIOD(list)
	end
	
	return #list
end

function ADVENTURE_BOOK_ACHIEVE_CONTENT.GET_COUNT_REWARD(category)
	local list = ADVENTURE_BOOK_ACHIEVE_CONTENT.LIST_REWARD()
	list = ADVENTURE_BOOK_ACHIEVE_CONTENT.FILTER_CATEGORY(list, category)

	return #list
end

function ADVENTURE_BOOK_ACHIEVE_CONTENT.GET_ACHIEVE_EXP()

end

function ADVENTURE_BOOK_ACHIEVE_CONTENT.GET_END_TIME(clsID)
	local cls = GetClassByType("Achieve", clsID)
	if cls == nil then return 0, "None" end
	
	local NeedPoint = TryGetProp(cls, "NeedPoint", "None")
	if NeedPoint == "None" then return 0, "None" end

	local clsPoint = GetClassByStrProp("AchievePoint", "ClassName", NeedPoint)
	if clsPoint == nil then return 0, "None" end

	local EndTime = TryGetProp(clsPoint, "EndTime", "None")
	return EndTime
end

function ADVENTURE_BOOK_ACHIEVE_CONTENT.GET_REMAIN_TIME(clsID)
	local cls = GetClassByType("Achieve", clsID)
	if cls == nil then return 0, "None" end
	
	local NeedPoint = TryGetProp(cls, "NeedPoint", "None")
	if NeedPoint == "None" then return 0, "None" end

	local clsPoint = GetClassByStrProp("AchievePoint", "ClassName", NeedPoint)
	if clsPoint == nil then return 0, "None" end

	local EndTime = TryGetProp(clsPoint, "EndTime", "None")
	if EndTime == "None" then
		return 0, "None"
	end
	
	local getnow = geTime.GetServerSystemTime()
	local nowstr = string.format("%04d-%02d-%02d %02d:%02d:%02d", getnow.wYear, getnow.wMonth, getnow.wDay, getnow.wHour, getnow.wMinute, getnow.wSecond)
	
	local remainsec = date_time.get_lua_datetime_from_str(EndTime) - date_time.get_lua_datetime_from_str(nowstr)

	return 1, remainsec
end


function ADVENTURE_BOOK_ACHIEVE_CONTENT.GET_SEARCH_FILTER_OPTION_LIST_MAINCATEGORY()
	local list = {}

	-- 전체
	list[1] = { "All", "adventure_book_achieve_search_option_all_list" }

	-- 카테고리
	local mainCategoryList = ADVENTURE_BOOK_ACHIEVE_CONTENT.GET_MAIN_CATEGORY_CLASS_LIST()
	for i = 1, #mainCategoryList do
		local cls = mainCategoryList[i]
		list[#list + 1 ] = { TryGetProp(cls, "ClassName", ""), TryGetProp(cls, "Name", "") }
	end

	return list
end

function ADVENTURE_BOOK_ACHIEVE_CONTENT.GET_SEARCH_FILTER_OPTION_LIST_SUBCATEGORY(category)
	local list = {}

	-- 전체
	list[1] = { "All", "adventure_book_achieve_search_option_all_list" }

	-- 카테고리
	local subCategoryList = ADVENTURE_BOOK_ACHIEVE_CONTENT.GET_SUB_CATEGORY_CLASS_LIST(category)
	for i = 1, #subCategoryList do
		local cls = subCategoryList[i]
		list[#list + 1 ] = { TryGetProp(cls, "ClassName", ""), TryGetProp(cls, "Name", "") }
	end

	-- 기타
	if category ~= "All" then
		list[#list + 1] = { "etc", "adventure_book_achieve_subcategory_etc" }
	end

	return list
end

-- 메인 카테고리 클래스 리스트 가져오기
function ADVENTURE_BOOK_ACHIEVE_CONTENT.GET_MAIN_CATEGORY_CLASS_LIST()
	local list = {}
	local clsList, cnt = GetClassList("AchieveInfo")
	for i = 0, cnt - 1 do
		local cls = GetClassByIndexFromList(clsList, i)
		local GroupName = TryGetProp(cls, "GroupName")
		if GroupName == "MainCategory" then
			list[#list + 1] = cls
		end
	end
	return list
end

-- 메인 카테고리에 해당하는 서브 카테고리 클래스 리스트 가져오기
function ADVENTURE_BOOK_ACHIEVE_CONTENT.GET_SUB_CATEGORY_CLASS_LIST(mainCategory)
	-- ETC를 포함하여 리턴함
	local list = {}
	local clsList, cnt = GetClassList("AchieveInfo")
	for i = 0, cnt - 1 do
		local cls = GetClassByIndexFromList(clsList, i)
		local GroupName = TryGetProp(cls, "GroupName")
		if GroupName == mainCategory then
			list[#list + 1] = cls
		end
	end
	if mainCategory ~= "All" then
		list[#list + 1] = GetClassByStrProp("AchieveInfo", "ClassName", "etc")
	end
	return list
end

function ADVENTURE_BOOK_ACHIEVE_CONTENT.GET_SUB_CATEGORY_ETC_CLASS()
	
	return GetClassByStrProp("AchieveInfo", "ClassName", "etc")
end

function ADVENTURE_BOOK_ACHIEVE_CONTENT.VAILD_MAIN_CATEGORY(category)
	local list = ADVENTURE_BOOK_ACHIEVE_CONTENT.GET_MAIN_CATEGORY_CLASS_LIST()
	for i = 1, #list do
		local name = TryGetProp(list[i], "ClassName")
		if name ==category then
			return 1
		end
	end
	return 0
end

function ADVENTURE_BOOK_ACHIEVE_CONTENT.VAILD_SUB_CATEGORY(mainCategory, subCategory)
	local list = ADVENTURE_BOOK_ACHIEVE_CONTENT.GET_SUB_CATEGORY_CLASS_LIST(mainCategory)
	for i = 1, #list do
		local name = TryGetProp(list[i], "ClassName")
		if name == subCategory then
			return 1
		end
	end
	return 0
end
