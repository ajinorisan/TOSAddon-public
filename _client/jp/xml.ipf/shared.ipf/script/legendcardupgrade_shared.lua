
goddess_card_reinforce = {}
local base_goddess_card_reinfoce_mat = nil
local base_goddess_card_mat = nil

function make_base_goddess_card_reinfoce_mat()
    if base_goddess_card_reinfoce_mat ~= nil then
        return
    end

    base_goddess_card_reinfoce_mat = {}
    for i = 1, 10 do
        base_goddess_card_reinfoce_mat[i] = {}
    end
    
    local index = 1
    base_goddess_card_reinfoce_mat[index]['Goddess_card_Reinforce_2'] = 1

    -- 1 -> 2
    index = index + 1
    base_goddess_card_reinfoce_mat[index]['Goddess_card_Reinforce_2'] = 1
    base_goddess_card_reinfoce_mat[index]['goddess_reinforce_misc'] = 2

    -- 2 -> 3
    index = index + 1
    base_goddess_card_reinfoce_mat[index]['Goddess_card_Reinforce_2'] = 2
    base_goddess_card_reinfoce_mat[index]['goddess_reinforce_misc'] = 3

    -- 3 -> 4
    index = index + 1
    base_goddess_card_reinfoce_mat[index]['Goddess_card_Reinforce_2'] = 4
    base_goddess_card_reinfoce_mat[index]['goddess_reinforce_misc'] = 4

    -- 4 -> 5
    index = index + 1
    base_goddess_card_reinfoce_mat[index]['Goddess_card_Reinforce_2'] = 5
    base_goddess_card_reinfoce_mat[index]['goddess_reinforce_misc'] = 7

    -- 5 -> 6
    index = index + 1
    base_goddess_card_reinfoce_mat[index]['Goddess_card_Reinforce_2'] = 7
    base_goddess_card_reinfoce_mat[index]['goddess_reinforce_misc'] = 12
    
    -- 6 -> 7
    index = index + 1
    base_goddess_card_reinfoce_mat[index]['Goddess_card_Reinforce_2'] = 10
    base_goddess_card_reinfoce_mat[index]['goddess_reinforce_misc'] = 18
    
    -- 7 -> 8
    index = index + 1
    base_goddess_card_reinfoce_mat[index]['Goddess_card_Reinforce_2'] = 16
    base_goddess_card_reinfoce_mat[index]['goddess_reinforce_misc'] = 28
    
    -- 8 -> 9
    index = index + 1
    base_goddess_card_reinfoce_mat[index]['Goddess_card_Reinforce_2'] = 24
    base_goddess_card_reinfoce_mat[index]['goddess_reinforce_misc'] = 37
    
    -- 9 -> 10
    index = index + 1
    base_goddess_card_reinfoce_mat[index]['Goddess_card_Reinforce_2'] = 37
    base_goddess_card_reinfoce_mat[index]['goddess_reinforce_misc'] = 43    


	-- 여신 카드 레벨업
	base_goddess_card_mat = {}
    for i = 1, 10 do
        base_goddess_card_mat[i] = {}
    end
    
    index = 1
    base_goddess_card_mat[index]['Goddess_card_Reinforce_2'] = 1

    -- 1 -> 2
    index = index + 1
    base_goddess_card_mat[index]['Goddess_card_Reinforce_2'] = 2

    -- 2 -> 3
    index = index + 1
    base_goddess_card_mat[index]['Goddess_card_Reinforce_2'] = 4

    -- 3 -> 4
    index = index + 1
    base_goddess_card_mat[index]['Goddess_card_Reinforce_2'] = 7
    base_goddess_card_mat[index]['goddess_reinforce_misc'] = 6

    -- 4 -> 5
    index = index + 1
    base_goddess_card_mat[index]['Goddess_card_Reinforce_2'] = 12
    base_goddess_card_mat[index]['goddess_reinforce_misc'] = 14

    -- 5 -> 6
    index = index + 1
    base_goddess_card_mat[index]['Goddess_card_Reinforce_2'] = 24
    base_goddess_card_mat[index]['goddess_reinforce_misc'] = 28
    
    -- 6 -> 7
    index = index + 1
    base_goddess_card_mat[index]['Goddess_card_Reinforce_2'] = 42
    base_goddess_card_mat[index]['goddess_reinforce_misc'] = 50
    
    -- 7 -> 8
    index = index + 1
    base_goddess_card_mat[index]['Goddess_card_Reinforce_2'] = 73
    base_goddess_card_mat[index]['goddess_reinforce_misc'] = 100
    
    -- 8 -> 9
    index = index + 1
    base_goddess_card_mat[index]['Goddess_card_Reinforce_2'] = 120
    base_goddess_card_mat[index]['goddess_reinforce_misc'] = 184
    
    -- 9 -> 10
    index = index + 1
    base_goddess_card_mat[index]['Goddess_card_Reinforce_2'] = 232
    base_goddess_card_mat[index]['goddess_reinforce_misc'] = 370
end

make_base_goddess_card_reinfoce_mat()

-- 분해 했을 때, 얻는 재료들
goddess_card_reinforce.get_goddess_card_reinfoce_mat_list = function(item)
    if TryGetProp(item, 'ClassName', 'None') ~= 'Goddess_card_Reinforce' then
        return nil
    end

    local now_lv = GET_ITEM_LEVEL(item)
    now_lv = math.max(1, now_lv)

    local mat_list = {}
    for i = now_lv, 1, -1 do
        for name, count in pairs(base_goddess_card_reinfoce_mat[i]) do
            if mat_list[name] == nil then
                mat_list[name] = count
            else
                mat_list[name] = mat_list[name] + count
            end
        end
    end

    return mat_list
end

-- 여신카드 레벨업을 위한 재료
goddess_card_reinforce.get_goddess_card_mat_list = function(item, goal_lv)
    if TryGetProp(item, 'Reinforce_Type', 'None') ~= 'GoddessCard' then
        return nil
    end

	local item_name = TryGetProp(item, 'StringArg', 'None')
	if item_name == 'None' or GetClass('Item', item_name) == nil then
		return nil
	end

    local now_lv = GET_ITEM_LEVEL(item)
    now_lv = math.max(1, now_lv)

	-- now_lv = 2
	-- goal_lv = 5
	if goal_lv <= now_lv then
		return nil
	end

    local mat_list = {}
	local item_count = 0
    for i = now_lv + 1, goal_lv do
		item_count = item_count + i		
        for name, count in pairs(base_goddess_card_mat[i]) do
            if mat_list[name] == nil then
                mat_list[name] = count
            else
                mat_list[name] = mat_list[name] + count
            end
        end
    end

	if item_count > 0 then
		mat_list[item_name] = item_count
	end

    return mat_list
end

goddess_card_reinforce.get_goddess_card_need_point = function(item, goal_lv)
	local reinforce_type = TryGetProp(item, 'Reinforce_Type', 'None')
	local namespace = LEGENDCARD_REINFORCE_GET_MAIN_CARD_NAMESPACE(item)
	local card_lv = GET_ITEM_LEVEL(item)
	local add_lv = goal_lv - card_lv
	if add_lv <= 0 then
		return 0
	end

	local total_point = 0
	for i = 0, add_lv - 1 do
		local reinforce_cls = LEGENDCARD_GET_REINFORCE_CLASS(card_lv + i, reinforce_type, namespace)
		local need_point = TryGetProp(reinforce_cls, "NeedPoint", 0)
		total_point = total_point + need_point
	end

	return total_point
end


function LEGENDCARD_GET_REINFORCE_CLASS(cardLv,reinforceType,namespace)
	local legendCardReinforceList, cnt = GetClassList(namespace)
	for i = 0, cnt - 1 do
		local cls = GetClassByIndexFromList(legendCardReinforceList,i);
		if cardLv == TryGetProp(cls, "CardLevel") and reinforceType == TryGetProp(cls, "ReinforceType") then
			return cls
		end
	end
	return nil
end

function LEGENDCARD_REINFORCE_GET_MAIN_CARD_NAMESPACE(obj)	
	if TryGetProp(obj, 'CardGroupName', 'None') == 'None' then
		return nil
	end
	if obj.CardGroupName == 'LEG' then
		return "legendCardReinforce"
	elseif obj.CardGroupName == 'GODDESS' then
		return "goddessCardReinforce"
	elseif obj.CardGroupName == 'REINFORCE_GODDESS_CARD' then
		return "goddessCardReinforce"
	end
	return nil
end

function LEGENDCARD_REINFORCE_GET_MATERIAL_CARD_NAMESPACE(mainObj,materialObj)
	if mainObj == nil or TryGetProp(mainObj, 'CardGroupName', 'None') == 'None' then
		return nil
	end
	if materialObj.CardGroupName == nil then
		return nil
	end
	if mainObj.CardGroupName == 'LEG' then
		local validTypeList = {"LegendCard","Card","ReinForceCard"}
		-- 레티샤의 강화용 보루타 카드
		for i = 1,8 do
			local reinforceType = string.format("ReinForceCard_Leticia_Lv%s",i)
			table.insert(validTypeList,reinforceType)
		end
		if table.find(validTypeList,materialObj.Reinforce_Type) ~= 0 then
			return "legendCardReinforce"
		end
	elseif mainObj.CardGroupName == 'GODDESS' then
		local validTypeList = {"GoddessReinForceCard"}
		if table.find(validTypeList,materialObj.Reinforce_Type) ~= 0 then
			return "goddessCardReinforce"
		end
	elseif mainObj.CardGroupName == 'REINFORCE_GODDESS_CARD' then
		local validTypeList = {"GoddessReinForceCard","LegendCard"}
		if table.find(validTypeList,materialObj.Reinforce_Type) ~= 0 then
			return "goddessCardReinforce"
		end
	end
	
	return nil
end


function CALC_LEGENDCARD_REINFORCE_PERCENTS(legendCardObj,materialCardObjList)
	if legendCardObj == nil then
		return 0,0,0
	end

	local legendCardType = TryGetProp(legendCardObj, 'Reinforce_Type')
	local legendCardLv = GET_ITEM_LEVEL(legendCardObj)
	local namespace = LEGENDCARD_REINFORCE_GET_MAIN_CARD_NAMESPACE(legendCardObj)
	local legendCardCls = LEGENDCARD_GET_REINFORCE_CLASS(legendCardLv,legendCardType,namespace)
	local needPoint = TryGetProp(legendCardCls, "NeedPoint",0)
	local totalGivePoint = 0

	for i = 1,#materialCardObjList do
		local materialCardObj = materialCardObjList[i]
		local materialType = materialCardObj.Reinforce_Type
		local materialCardLv = GET_ITEM_LEVEL(materialCardObj)
		local matterialNamespace = LEGENDCARD_REINFORCE_GET_MATERIAL_CARD_NAMESPACE(legendCardObj,materialCardObj)
		local materialCls = LEGENDCARD_GET_REINFORCE_CLASS(materialCardLv,materialType,matterialNamespace)
		local givePoint = TryGetProp(materialCls, "GivePoint",0)
		if materialCls.ReinforceType == "LegendCard" and legendCardCls.ReinforceType == "GoddessCard" then
			givePoint = 0
		end
		totalGivePoint = totalGivePoint + givePoint
	end

	local givePerNeedPoint = 0
	if needPoint ~= 0 then
		givePerNeedPoint = totalGivePoint / needPoint
	end
	
	local successPercent = math.floor(givePerNeedPoint * 100 + 0.5)
	local failPercent = math.floor((1 - givePerNeedPoint) * 0.4 * 100 + 0.5)
	local brokenPercent = 100 - (successPercent + failPercent)

	if givePerNeedPoint >= 0.995 then
		successRatio = 100
	end
	

	successPercent = math.max(0,math.min(100,successPercent))
	failPercent = math.max(0,math.min(100,failPercent))
	brokenPercent = math.max(0,math.min(100,brokenPercent))

	return successPercent, failPercent, brokenPercent, needPoint, totalGivePoint
end

function GET_CARD_REINFORCE_NEED_ITEM_STRARG(cls,cardObj)
	return cardObj.StringArg
end

function GET_LEGEND_CARD_NEED_EXP(from_lv, to_lv)
	if from_lv == nil or to_lv == nil then
		return nil
	end

	local need_exp = 0
	for i = from_lv, to_lv - 1 do
		local cls = GetClassByType('legendCardReinforce', i)
		if cls ~= nil then
			local need_point = TryGetProp(cls, 'NeedPoint', 0)
			need_exp = need_exp + need_point
		end
	end

	return need_exp
end

-- 여신카드 경험치 복사
function IS_GODDESS_LEGEND_CARD(item)
	if item == nil then
		return false
	end

	if TryGetProp(item, 'EquipXpGroup', 'None') == 'Goddess_Card' then
		return true
	end

	return false
end

function IS_VALID_COND_LEGEND_GODDESS_CARD(src, target)
	if IS_GODDESS_LEGEND_CARD(src) == false or IS_GODDESS_LEGEND_CARD(target) == false then
		return false, 'NotGoddessCard'
	end

	if TryGetProp(src, 'ClassName', 'None') ~= TryGetProp(target, 'ClassName', 'None') then
		return false, 'OnlySameCardType'
	end

	local lv = GET_ITEM_LEVEL(src)

	if lv < 2 then
		return false, 'LessLevelofSourceCard'
	end

	local target_lv = GET_ITEM_LEVEL(target)
	if target_lv >= lv then
		return false, 'GreaterLevelofTargetCardThanSourceCard'
	end

	return true, 'None'
end

function GET_COPY_COST_LEGEND_GODDESS_CARD(src)
	if IS_GODDESS_LEGEND_CARD(src) == true then
		local lv = GET_ITEM_LEVEL(src)
		if lv > 1 then
			return 'REPUTATION_COIN_EP13', lv * 1000
		end
	end

	return 'None', 999999999
end
-- end of 여신카드 경험치 복사

function IS_LEGEND_CARD(item)
	if item == nil then
		return false
	end

	if TryGetProp(item, 'EquipXpGroup', 'None') == 'Legend_Card' then
		return true
	end

	return false
end

function IS_VALID_COND_LEGEND_CARD(src, target)
	if IS_LEGEND_CARD(src) == false or IS_LEGEND_CARD(target) == false then
		return false, 'LegendCardReinforce_OnlyLegCard'
	end

	if TryGetProp(src, 'ClassName', 'None') ~= "Legend_card_Falouros" then
		return false, 'CanNotRegCard'
	end

	if TryGetProp(target, 'ClassName', 'None') == "Legendcard_Guilty" then
		return false, 'CanNotRegCard'
	end

	if TryGetProp(target, 'ClassName', 'None') == "Legendcard_Leticia" then
		return false, 'CanNotRegCard'
	end

	local lv = GET_ITEM_LEVEL(src)

	if lv < 2 then
		return false, 'LessLevelofSourceCard'
	end

	local target_lv = GET_ITEM_LEVEL(target)
	if target_lv ~= 1 then
		return false, 'GreaterLevelofTargetCardThanSourceCard2'
	end

	return true, 'None'
end