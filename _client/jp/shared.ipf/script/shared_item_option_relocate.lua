function GET_ITEM_AWAKE_OPTION_RELOCATE_COST(itemUseLv)
    return itemUseLv * 1000;
end

function GET_ITEM_ENCHANT_OPTION_RELOCATE_COST(destLV, srcLV)
	local cost = 999999999;

	if destLV == srcLV then
		cost = 100000;
	elseif srcLV < destLV then
		cost = (destLV - srcLV) * 3000000;
	end

    return cost;
end

-- dest_Obj : 이전 받을 아이템, src_Obj : 이전 할 아이템
-- 각성 이전 조건 확인
function IS_ENABLE_AWAKE_OPTION_RELOCATE(dest_Obj, src_Obj)
	-- 동일한 레벨, 동일한 부위, 동일한 등급
    local dest_guid = GetIESID(dest_Obj);
    local src_guid = GetIESID(src_Obj);

	if dest_guid == src_guid then
		return false, 'Same';
	end
	
	if TryGetProp(dest_Obj, "ClassType", 9999) ~= TryGetProp(src_Obj, "ClassType", 9999) then
		return false, 'Type';
	end

	if TryGetProp(dest_Obj, "UseLv", 9999) ~= TryGetProp(src_Obj, "UseLv", 9999) then
		return false, 'Level';
	end

	if TryGetProp(dest_Obj, "ItemGrade", 9999) ~= TryGetProp(src_Obj, "ItemGrade", 9999) then
		return false, 'Grade';
	end

	return true;
end

-- dest_Obj : 이전 받을 아이템, src_Obj : 이전 할 아이템
-- 인챈트 이전 조건 확인
function IS_ENABLE_ENCHANT_OPTION_RELOCATE(dest_Obj, src_Obj)	
    local dest_guid = GetIESID(dest_Obj);
    local src_guid = GetIESID(src_Obj);

	local src_grade = TryGetProp(src_Obj, 'ItemGrade', 1)
	local dest_grade = TryGetProp(dest_Obj, 'ItemGrade', 1)

	if dest_guid == src_guid then
		return false, 'Same';
	end

	if src_grade == 6 or dest_grade == 6 then
		if src_grade ~= dest_grade then
			return false, 'Grade'
		end

		if TryGetProp(dest_Obj, "UseLv", 9999) ~= TryGetProp(src_Obj, "UseLv", 9999) then
			return false, 'Level'
		end
	end

	-- dest의 레벨이 src의 레벨보다 낮은 경우에는 불가
	if TryGetProp(dest_Obj, "UseLv", 9999) < TryGetProp(src_Obj, "UseLv", 9999) then
		return false, 'Level';
	end

	if IS_OPTION_RELOCATE_ENABLE_MARKET_TRADE_ITEM(dest_Obj) ~= false and IS_OPTION_RELOCATE_ENABLE_MARKET_TRADE_ITEM(src_Obj) == false then
		return false, 'TradeOption';
	end	

	return true;
end

-- 마켓 거래 가능 여부 확인
function IS_OPTION_RELOCATE_ENABLE_MARKET_TRADE_ITEM(itemObj)
	if TryGetProp(itemObj, "BelongingCount", 1) == 1 then
		return false;
	end

	if TryGetProp(itemObj, "PR", 9999) <= 0 then
		return false;
	end

	if TryGetProp(itemObj, "MarketTrade", "NO") == "NO" then
		return false;
	end

	return true;
end

-- 각성 가능 아이템인지 확인
function IS_ENABLE_AWAKE_OPTION_RELOCATE_ITEM(itemObj)
	if TryGetProp(itemObj, 'ItemStar', -1) < 0 then
		return false, 'Type';
	end

	if 0 < TryGetProp(itemObj , 'LifeTime') or 0 < TryGetProp(itemObj , 'ItemLifeTimeOver') then
		return false, 'LimitTime';
	end

	if IS_NEED_APPRAISED_ITEM(itemObj) == true or IS_NEED_RANDOM_OPTION_ITEM(itemObj) == true then 
		return false, 'NeedRandomOption';
	end	

	return true;
end

-- 인챈트 쥬얼 가능 아이템인지 확인
-- IS_ENABLE_APPLY_JEWELL() 참고
function IS_ENABLE_ENCHANT_OPTION_RELOCATE_ITEM(itemObj)
	if TryGetProp(itemObj, 'ItemStar', -1) < 0 then
		return false, 'Type';
	end

	if 0 < TryGetProp(itemObj , 'LifeTime') or 0 < TryGetProp(itemObj , 'ItemLifeTimeOver') then
		return false, 'LimitTime';
	end
	
	if CHECK_JEWELL_COMMON_CONSTRAINT(itemObj) == false then		
		return false, 'Type';
	end

	if IS_NEED_APPRAISED_ITEM(itemObj) == true or IS_NEED_RANDOM_OPTION_ITEM(itemObj) == true then 
		return false, 'NeedRandomOption';
	end	

	local woodCarvingCheck = TryGetProp(itemObj , 'StringArg')
	if woodCarvingCheck == 'WoodCarving' then
	    return false, 'WoodCarving';
	end
	
	if TryGetProp(itemObj , 'UseLv') < 100 then
		return false, 'minLv';
	end

	return true;
end


function IS_ABLE_TO_USE_RADA_OPTION_RESCALE_SCROLL(item, scroll)
	if TryGetProp(scroll, 'StringArg', 'None') ~= 'rada_option_rescale_scroll' then
        return false, 'DontUseItem'
    end 

	if IS_RADA_OPTION_EQUIPMENT(item) == false then
		return false, 'DontUseItem'
	end

    if TryGetProp(item, 'UseLv', 0) == TryGetProp(scroll, 'NumberArg1', 0) then
        return true
    end

	return false, 'DontUseItem'
end


function IS_RADA_OPTION_EQUIPMENT(item)
	local item_list = {
        'EP15_RAID_CLOTH_TOP', 'EP15_RAID_CLOTH_LEG', 'EP15_RAID_CLOTH_FOOT', 'EP15_RAID_CLOTH_HAND',
        'EP15_RAID_LEATHER_TOP', 'EP15_RAID_LEATHER_LEG', 'EP15_RAID_LEATHER_FOOT', 'EP15_RAID_LEATHER_HAND',
        'EP15_RAID_PLATE_TOP', 'EP15_RAID_PLATE_LEG', 'EP15_RAID_PLATE_FOOT', 'EP15_RAID_PLATE_HAND',
	}
	
	local exist = false

	for i = 1, #item_list do
		if item_list[i] == TryGetProp(item, 'ClassName', 'None') then
			if TryGetProp(item, 'RadaOption', 'None') ~= 'None' then
				return true
			end
		end
	end

	return exist
end

function IS_ABLE_TO_USE_JURATE_OPTION_RESET_SCROLL(item, scroll)
	if TryGetProp(scroll, 'StringArg', 'None') ~= 'jurate_option_reset_scroll' then
        return false, 'DontUseItem'
    end 

	if IS_JURATE_OPTION_EQUIPMENT(item) == false then
		return false, 'DontUseItem'
	end

    if TryGetProp(item, 'UseLv', 0) == TryGetProp(scroll, 'NumberArg1', 0) then
        return true
    end

	return false, 'DontUseItem'
end


function IS_JURATE_OPTION_EQUIPMENT(item)
	local item_list = {
        'EP16_RAID_CLOTH_TOP', 'EP16_RAID_CLOTH_LEG', 'EP16_RAID_CLOTH_FOOT', 'EP16_RAID_CLOTH_HAND',
        'EP16_RAID_LEATHER_TOP', 'EP16_RAID_LEATHER_LEG', 'EP16_RAID_LEATHER_FOOT', 'EP16_RAID_LEATHER_HAND',
        'EP16_RAID_PLATE_TOP', 'EP16_RAID_PLATE_LEG', 'EP16_RAID_PLATE_FOOT', 'EP16_RAID_PLATE_HAND',
	}
	
	local exist = false

	for i = 1, #item_list do
		if item_list[i] == TryGetProp(item, 'ClassName', 'None') then
			if TryGetProp(item, 'JurateOption', 'None') ~= 'None' then
				return true
			end
		end
	end

	return exist
end

function IS_ABLE_TO_USE_520_JURATE_OPTION_SCROLL(item, scroll)
	local item_list = {
        'EP16_RAID_CLOTH_TOP', 'EP16_RAID_CLOTH_LEG', 'EP16_RAID_CLOTH_FOOT', 'EP16_RAID_CLOTH_HAND',
        'EP16_RAID_LEATHER_TOP', 'EP16_RAID_LEATHER_LEG', 'EP16_RAID_LEATHER_FOOT', 'EP16_RAID_LEATHER_HAND',
        'EP16_RAID_PLATE_TOP', 'EP16_RAID_PLATE_LEG', 'EP16_RAID_PLATE_FOOT', 'EP16_RAID_PLATE_HAND',
	}

    if TryGetProp(scroll, 'StringArg', 'None') ~= 'jurate_option_scroll' then
        return false, 'DontUseItem'
    end

    if TryGetProp(item, 'JurateOption', 'None') ~= 'None' then
        return false, 'DontUseItem'
    end
    
	local name = TryGetProp(item, 'ClassName', 'None')
	if table.find(item_list, name) == 0 then
		return false, 'DontUseItem'
	end

    if TryGetProp(scroll, 'NumberArg1', 0) ~= TryGetProp(item, 'UseLv', 0) then
        return false, 'DontUseItem'
    end

    return true
end


function IS_ABLE_TO_USE_AUSTEJA_OPTION_RESET_SCROLL(item, scroll)
	if TryGetProp(scroll, 'StringArg', 'None') ~= 'austeja_option_reset_scroll' then
        return false, 'DontUseItem'
    end 

	if IS_AUSTEJA_OPTION_EQUIPMENT(item) == false then
		return false, 'DontUseItem'
	end

    if TryGetProp(item, 'UseLv', 0) == TryGetProp(scroll, 'NumberArg1', 0) then
        return true
    end

	return false, 'DontUseItem'
end

function IS_AUSTEJA_OPTION_EQUIPMENT(item)
	local item_list = {
        'EP17_RAID_CLOTH_TOP', 'EP17_RAID_CLOTH_LEG', 'EP17_RAID_CLOTH_FOOT', 'EP17_RAID_CLOTH_HAND',
        'EP17_RAID_LEATHER_TOP', 'EP17_RAID_LEATHER_LEG', 'EP17_RAID_LEATHER_FOOT', 'EP17_RAID_LEATHER_HAND',
        'EP17_RAID_PLATE_TOP', 'EP17_RAID_PLATE_LEG', 'EP17_RAID_PLATE_FOOT', 'EP17_RAID_PLATE_HAND',
	}
	
	local exist = false

	for i = 1, #item_list do
		if item_list[i] == TryGetProp(item, 'ClassName', 'None') then
			if TryGetProp(item, 'AustejaOption', 'None') ~= 'None' then
				return true
			end
		end
	end

	return exist
end


function IS_ABLE_TO_USE_540_AUSTEJA_OPTION_SCROLL(item, scroll)
	local item_list = {
        'EP17_RAID_CLOTH_TOP', 'EP17_RAID_CLOTH_LEG', 'EP17_RAID_CLOTH_FOOT', 'EP17_RAID_CLOTH_HAND',
        'EP17_RAID_LEATHER_TOP', 'EP17_RAID_LEATHER_LEG', 'EP17_RAID_LEATHER_FOOT', 'EP17_RAID_LEATHER_HAND',
        'EP17_RAID_PLATE_TOP', 'EP17_RAID_PLATE_LEG', 'EP17_RAID_PLATE_FOOT', 'EP17_RAID_PLATE_HAND',
	}

    if TryGetProp(scroll, 'StringArg', 'None') ~= 'austeja_option_scroll' then
        return false, 'DontUseItem'
    end

    if TryGetProp(item, 'AustejaOption', 'None') ~= 'None' then
        return false, 'DontUseItem'
    end
    
	local name = TryGetProp(item, 'ClassName', 'None')
	if table.find(item_list, name) == 0 then
		return false, 'DontUseItem'
	end

    if TryGetProp(scroll, 'NumberArg1', 0) ~= TryGetProp(item, 'UseLv', 0) then
        return false, 'DontUseItem'
    end

    return true
end
