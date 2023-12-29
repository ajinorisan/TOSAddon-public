function SCR_PRECHECK_QUEST_CLEAR_SCROLL(self, EpisodeTag)
	if EpisodeTag == "None" or EpisodeTag == nil then return 0 end
    if OnKnockDown(self) == 'YES' then
        return 0;
	end
	
	local currentZone = GetZoneName(self)
	if currentZone ~= "c_Klaipe" and currentZone ~= "c_orsha" and currentZone ~= "c_fedimian" then
		SendAddOnMsg(self, "NOTICE_Dm_!", ScpArgMsg("AllowedInTown"), 3);
		return 0;
	end

	if IsMyPCFriendlyFighting(self) == 1 then
		SendAddOnMsg(self, "NOTICE_Dm_!", ScpArgMsg("Card_Summon_check_PVP"), 3);
		return 0;
	end

	local sObj = GetSessionObject(self, 'ssn_klapeda')
	if sObj == nil then
		return 0;
	end

	local classList, classCount = GetClassList("Episode_Quest");
    if classList == nil or classCount == 0 then
        return 0;
	end


	local ClearQuest = 0
	local remainQuest = 0

	for i = 0, classCount - 1 do
		local EpisodeList = GetClassByIndexFromList(classList, i);
		local EpisodeTag_ID = TryGetProp(EpisodeList, 'EpisodeTag', "None")
		local QuestID = TryGetProp(EpisodeList, 'QuestID', 0)
		if EpisodeTag_ID == EpisodeTag then
			local Questclass = GetClassByType("QuestProgressCheck", QuestID)
			local QuestClassName = TryGetProp(Questclass, "ClassName", "None")
			local QuestResult = TryGetProp(sObj, QuestClassName, 0)
			if QuestResult == 300 then -- Clear : 300
				ClearQuest = ClearQuest + 1
			else
				remainQuest = remainQuest + 1
			end
		end
	end
	
	if remainQuest <= 0 then
		SendAddOnMsg(self, "NOTICE_Dm_!", ScpArgMsg("QuestCleared_ALL_msg_1"), 10);
		return 0;
	end

	return 1;
end