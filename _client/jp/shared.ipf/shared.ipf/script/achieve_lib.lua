-- achieve의 clsID로 보상 아이템 목록을 가져오는 함수
-- achieve.xml의 RewardItem

function GET_REWARD_LIST(clsID)
    local cls = GetClassByType("Achieve", clsID);
    if cls == nil then return nil end

    local RewardItem = TryGetProp(cls, "RewardItem", "None")
    if RewardItem == "None" then return nil end

    local reward_list = {}

    local RewardItemList = StringSplit(RewardItem, ';')
    for i = 1, #RewardItemList do
        local ItemInfo = StringSplit(RewardItemList[i], '/')
        table.insert(reward_list, {ItemInfo[1], ItemInfo[2]})
    end
    
    return reward_list
end

function IS_GET_REWARD_ACHIEVE_EXCHANGE_EVENT(clsID)
    local cls = GetClassByType('AchieveExchangeEventItem', clsID)
    if cls == nil then return 0 end

    local aObj = GetMyAccountObj()
    if aObj == nil then return 0 end

    local prop_name = 'AchieveExchangeEventReward_'..clsID
    local prop_value = aObj[prop_name]
    if prop_value == 1 then
        return 1
    end
    
    return 0
end

function IS_GET_REWARD_ACHIEVE_LEVEL(clsID)
    local cls = GetClassByType('AchieveLevelReward', clsID)
    if cls == nil then return 0 end

    local aObj = GetMyAccountObj()
    if aObj == nil then return 0 end

    local prop_name = 'AchieveLevelReward_'..clsID
    local prop_value = aObj[prop_name]
    if prop_value == 1 then
        return 1
    end
    
    return 0
end