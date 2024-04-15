function EVENT_STAMP_IS_VALID_WEEK(week)
	local startTime = imcTime.GetSysTime(2021,12,23,6)
	local week_startTime = imcTime.AddSec(startTime,(week-1)*7*24*60*60)

	local currentDate = nil
	if IsServerSection() == 1 then
		currentDate = GetDBTime()
	else
		currentDate = geTime.GetServerSystemTime()
	end
	if imcTime.GetDifSec(week_startTime,currentDate) < 0 then
		return true
	end
	return false
end

function EVENT_STAMP_IS_VALID_WEEK_SUMMER(week, time)
	local startTime = imcTime.GetSysTime(2020,7,9,6)
	local week_startTime = imcTime.AddSec(startTime,(week-1)*7*24*60*60)

	local currentDate = nil
	if IsServerSection() == 1 then
		currentDate = GetDBTime()
	else
		currentDate = geTime.GetServerSystemTime()
	end
	if time ~= nil then
		currentDate = time
	end
	if imcTime.GetDifSec(week_startTime,currentDate) <= 0 then
		return true
	end
	return false
end

function EVENT_STAMP_GET_INFO(num)
	local row = math.floor((num-1)/3)+1
	local col = math.floor(num%3)
	if col == 0 then
		col = 3
	end
	local cls = EVENT_STAMP_GET_CURRENT_MISSION("REGULAR_EVENT_STAMP_TOUR",row-1)
	local prop = TryGetProp(cls,"CheckProp"..col)
	local propName,count = unpack(StringSplit(prop,'/'))
	count = tonumber(count)
	local week = TryGetProp(cls,"ArgNum"..col)
	return propName,count,week
end

function EVENT_STAMP_GET_INFO_SUMMER(num)
	local row = math.floor((num-1)/3)+1
	local col = math.floor(num%3)
	if col == 0 then
		col = 3
	end
	local cls = EVENT_STAMP_GET_CURRENT_MISSION("EVENT_STAMP_TOUR_SUMMER",row-1)
	local prop = TryGetProp(cls,"CheckProp"..col)
	local propName,count = unpack(StringSplit(prop,'/'))
	count = tonumber(count)
	local week = TryGetProp(cls,"ArgNum"..col)
	return propName,count,week
end

function EVENT_STAMP_GET_INFO_BY_NAME(num, name)
	local row = math.floor((num-1)/3)+1
	local col = math.floor(num%3)
	if col == 0 then
		col = 3
	end
	local cls = EVENT_STAMP_GET_CURRENT_MISSION(name, row-1)
	local prop = TryGetProp(cls,"CheckProp"..col)
	local propName,count = unpack(StringSplit(prop,'/'))
	count = tonumber(count)
	local week = TryGetProp(cls,"ArgNum"..col)
	return propName,count,week
end

function EVENT_STAMP_GET_CURRENT_MISSION(groupName,currentpage)	
	local clsList, allmissionCnt = GetClassList('note_eventlist');
	local cnt = 0

	for i = 0, allmissionCnt-1 do
		local missionCls = GetClassByIndexFromList(clsList, i);
		if missionCls ~= nil then
			if missionCls.Group == groupName then
				if currentpage == cnt then
					return missionCls;
				end
				cnt = cnt  + 1
			end
		end
	end

	return nil;
end

--EVENT_2007_TOS_VACANCE
function EVENT_STAMP_IS_HIDDEN_SUMMER(aObj,num)
	if num <= 12 then
		return false
	end
	local start = num - 12 - (num-1)%3
	for i = start,start+2 do
		local propName,count,week = EVENT_STAMP_GET_INFO_SUMMER(i)
		local nowCount = tonumber(TryGetProp(aObj,propName))
		if nowCount==nil or nowCount<count then
			return true
		end
	end
	return false
end


function EVENT_STAMP_GET_RECEIVABLE_REWARD_COUNT(aObj)
	local clsList, cnt = GetClassListByProp('note_eventlist', 'Group', 'REGULAR_EVENT_STAMP_TOUR')
	local rewardCnt = 0
	for j = 1, cnt do
		local cls = clsList[j]
		for i = 1, 3 do
			local clearprop = TryGetProp(cls, "ClearProp"..i, 'None');
			local clear = TryGetProp(aObj, clearprop, 'false');
			local checkprop = TryGetProp(cls, "CheckProp"..i, 'None');
			local proplist = StringSplit(checkprop, "/");
			local propname = proplist[1];
			local goalcnt = proplist[2];
			local curcnt = TryGetProp(aObj, propname, 0);
			if clear ~= 'true' and tonumber(goalcnt) <= tonumber(curcnt) then
				rewardCnt = rewardCnt + 1
			end
		end
	end
	return rewardCnt
end

function EVENT_STAMP_GET_RECEIVABLE_REWARD_COUNT_POPOBOOST(aObj)
	local CurrentPage = 0;
	local maxpopoboostpage = 8;
	for i = 1, maxpopoboostpage do
		local res = EVENT_STAMP_TOUR_POPOBOOST_CLEAR_CHECK("POPO_EVENT_STAMP",i);
		if res == false then
			CurrentPage = i;
			break;
		end
	end


	local clsList, cnt = GetClassListByProp('note_eventlist', 'Group', 'POPO_EVENT_STAMP')
	local rewardCnt = 0
	if CurrentPage ~= maxpopoboostpage then
		cnt = CurrentPage;
	end
	for j = 1, cnt do
		local cls = clsList[j]
		for i = 1, 3 do
			local clearprop = TryGetProp(cls, "ClearProp"..i, 'None');
			local clear = TryGetProp(aObj, clearprop, 'false');
			local checkprop = TryGetProp(cls, "CheckProp"..i, 'None');
			local proplist = StringSplit(checkprop, "/");
			local propname = proplist[1];
			local goalcnt = proplist[2];
			local curcnt = TryGetProp(aObj, propname, 0);
			if clearprop ~= "None" then
				if clear ~= 'true' and tonumber(goalcnt) <= tonumber(curcnt) then
					rewardCnt = rewardCnt + 1
				end
			end
		end
	end
	return rewardCnt
end
