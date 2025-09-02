--dailyTimeEvent.lua

function DAILY_TIME_EVENT_RESET(pc, tx)
	local etcObj = GetETCObject(pc);
	if etcObj == nil then
		return;
	end
	
	local aObj = GetAccountObj(pc);
	if aObj == nil then
		return;
	end

	local curDate, nextRestTime = GetCurDateAndNextData(INDUN_RESET_TIME);
	if curDate < aObj.DailyTime_ResetTime then
		return;
	end

	-- �ѹ� ���õȰŸ� 
	if aObj.DailyTime_ResetTime == nextRestTime then
		return;
	end 
	
	local zoneEnterUseTx = true;
	if tx == nil then
		tx = TxBegin(pc);
		TxEnableInIntegrate(tx);
		zoneEnterUseTx = false;
	end

	if nil == tx then
		return;
	end

	TxSetIESProp(tx, aObj, "DailyTime_ResetTime", nextRestTime);

	TxSetIESProp(tx, aObj, "DailyTimePoint", 0);

	for i = 0, 23 do
		TxSetIESProp(tx, aObj, "DailyTimeReward_"..i, 0);
	end

	etcObj.TempDailyTimePoint = 0

	if zoneEnterUseTx == true then
		return;
	end

	local ret = TxCommit(tx);
	if ret == "SUCCESS" then
	end
end

function TX_DAILY_TIME_SAVE(pc, etcDailyPoint)
	local etcObj = GetETCObject(pc);
	if etcObj == nil then
		return;
	end

	local aObj = GetAccountObj(pc);
	if aObj == nil then
		return;
	end


	--6�ð� ������ ���½��������
	local curTime, nextTime = GetCurDateAndNextData(INDUN_RESET_TIME);
	
	if curTime >= aObj.DailyTime_ResetTime then
		if aObj.DailyTime_ResetTime ~= nextTime then
			DAILY_TIME_EVENT_RESET(pc, nil)
			return;
		end	
	end

	local curDailyTimePoint = aObj.DailyTimePoint;

	local addPoint = curDailyTimePoint + etcDailyPoint

	local list, cnt = GetClassList('dailyEventReward');

	local sendMsg = false;

	local tx = TxBegin(pc);
	TxEnableInIntegrate(tx);

	for i = 0, cnt do
		local cls = GetClassByIndexFromList(list, i);
		if cls ~= nil then
			local rewardStartTime = cls.RewardStartTime;
			local rewardEndTime = cls.RewardEndTime;
			
			local curDate, nextRestTime = GetCurDateAndNextData(INDUN_RESET_TIME);
			if curDate >= rewardStartTime and curDate <= rewardEndTime then
				if addPoint >= cls.RewardPoint then
					local accountProp = "DailyTimeReward_"..cls.RewardIndex
					if aObj[accountProp] == 0 then
						--������ �ش�.
						local itemCls = GetClass("Item", cls.ItemName)
						if itemCls ~= nil then
							for i = 1, cls.ItemCount do
								TxGiveItemToPostBox(tx, pc, itemCls.ClassID, 1, ClMsg(cls.FromName), cls.Msg, cls.AddDestroyTime)
							end
							sendMsg = true;
							TxSetIESProp(tx, aObj, accountProp, 1);
						end
					end
				end
			end
		end
	end

	TxSetIESProp(tx, aObj, "DailyTimePoint", addPoint);

	local ret = TxCommit(tx);
	if ret == "SUCCESS" then
		if sendMsg == true then
			SendSysMsg(pc, "ArborDayEventRewardGet");
		end
	end
end

function TEST_DAILY_EVENT_RESET(pc)
	local etcObj = GetETCObject(pc);
	if etcObj == nil then
		return;
	end
	local aObj = GetAccountObj(pc);
	if aObj == nil then
		return;
	end
	local tx = TxBegin(pc);
	TxEnableInIntegrate(tx);
	
	for i = 0, 23 do
		local aaaaaa = "DailyTimeReward_"..i
		TxSetIESProp(tx, aObj, aaaaaa, 0);
	end
	etcObj.TempDailyTimePoint = 0
	TxSetIESProp(tx, aObj, "DailyTime_ResetTime", 0);
	TxSetIESProp(tx, aObj, "DailyTimePoint", 0);

	local ret = TxCommit(tx);
	if ret == "SUCCESS" then
	end
end

function TEST_DAILY_POINT(pc)
	local etcObj = GetETCObject(pc);
	if etcObj == nil then
		return;
	end
	local aObj = GetAccountObj(pc);
	if aObj == nil then
		return;
	end

	local addTime = etcObj.TempDailyTimePoint + aObj.DailyTimePoint
	Chat(pc, addTime);
end

function TEST_TX_POST_TEST(pc)
	local tx = TxBegin(pc);
	TxEnableInIntegrate(tx);
	
	TxGiveItemToPostBox(tx, pc, 640054, 1, ClMsg("ArborDayEvent"), "ArborDayOneHourReward", 6800)
    local ret = TxCommit(tx);
end

--SCROLL_POSTBOX_GBOX  <- lua �Լ� 
--SendPostBoxMessages
--�޽����� ������ ��