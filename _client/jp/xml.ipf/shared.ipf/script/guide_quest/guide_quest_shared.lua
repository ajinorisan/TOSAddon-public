

-- 가이드 퀘스트 진행 조건
function GUIDE_QUEST_PRECHECK(pc)
    -- local aObj
    -- if IsServerSection() == 1 then
    --     aObj = GetAccountObj(pc);
    -- else
    --     aObj = GetMyAccountObj();
    -- end

    -- local isStart = TryGetProp(aObj, "GUIDE_QUEST_START", 0)
    -- if isStart == 0 then
    --     return false
    -- end

	return false
end

function GUIDE_QUEST_IS_ALL_CLEAR(aObj)
    local clsList, cnt = GetClassList('guide_main');
    for i = 0, cnt - 1 do
        local cls = GetClassByIndexFromList(clsList, i);
        local accProp = TryGetProp(cls, "AccProp")
        local questCheck = TryGetProp(aObj, accProp)
        if questCheck ~= "Clear" then
            return false
        end
    end

    return true
end

function GUIDE_QUEST_GET_SUB_QUEST_INFO(subCategory)
    local subQuestCls = GetClass("guide_submission", subCategory)
    if subQuestCls == nil then
        return nil
    end

    local subQuestProp = TryGetProp(subQuestCls, "AccProp", 0)
    local conditionValue = TryGetProp(subQuestCls, "Condition_Value", 0)

    return subQuestProp, conditionValue
end


function GUIDE_QUEST_GET_MAIN_QUEST_INFO(aObj, missionGroup)
	local mainCls = GetClassByNumProp("guide_main", "Mission_Group", missionGroup);
    if mainCls == nil then
        return nil
    end

	local subClsList, cnt = GetClassListByProp('guide_submission', 'Mission_Group', missionGroup)
    local completeCnt = 0
    for i = 1, cnt do
        local subCls = subClsList[i]
        local subQuestProp = TryGetProp(subCls, "AccProp", 0)
        local conditionValue = TryGetProp(subCls, "Condition_Value", 0)
        if TryGetProp(aObj, subQuestProp, 0) == conditionValue then
            completeCnt = completeCnt + 1 
        end
    end

    return cnt, completeCnt
end

function GUIDE_QUEST_CHECK_RECEIVABLE_REWARD(aObj)
    local clsList, cnt = GetClassList('guide_main');
    for i = 0, cnt - 1 do
        local cls = GetClassByIndexFromList(clsList, i);
        local accProp = TryGetProp(cls, "AccProp")
        local questCheck = TryGetProp(aObj, accProp)
        if questCheck == "Reward" then
            return true
        end
    end

    return false
end

function GUIED_QUEST_PARSE_REWARD_STRING(argstring)
    local CutA = SCR_STRING_CUT(argstring, ';')
    if #CutA == 0 then
        return         
    end    

    local itemList = {}
    for i = 1, #CutA do
    	local CutB = CutA[i];
    	local CutC = SCR_STRING_CUT(CutB, '/');
        itemList[CutC[1]] = CutC[2]
    end

    return itemList
end

function GUIDE_QUEST_GET_REWARD_LIST(missionGroup)
	local cls = GetClassByNumProp("guide_main", "Mission_Group", missionGroup)
	local rewardItem = TryGetProp(cls, "Reward_Item")
    local rewardCoin = TryGetProp(cls, "Reward_Coin")
    
    local itemList = GUIED_QUEST_PARSE_REWARD_STRING(rewardItem)
    local coinList = GUIED_QUEST_PARSE_REWARD_STRING(rewardCoin)

    return itemList, coinList
end