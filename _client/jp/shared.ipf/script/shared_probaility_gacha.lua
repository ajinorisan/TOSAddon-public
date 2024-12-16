function GET_STEP_GACHA_CLS_LIST(pc, acc)
    local gacha_step = TryGetProp(acc ,"EVENT_SANTA_GACHA_STEP", 0)
    return GET_STEP_GACHA_CLS(pc, gacha_step), GET_STEP_GACHA_RATIO_GRADE(pc, gacha_step), gacha_step;
end

function GET_STEP_GACHA_CLS_LIST_BY_INDEX(pc, index)
    return GET_STEP_GACHA_CLS(pc, index), GET_STEP_GACHA_RATIO_GRADE(pc, index), index;
end



--
function GET_STEP_GACHA_CLS(pc, Gacha_Step)
    local IsInCity = false;
    if IsServerSection() == 1 then
        if IS_IN_CITY_SERVER(pc) == true then
            IsInCity = true;
        end
    else
        if IS_IN_CITY() == 1 then
            IsInCity = true;
        end
    end

    local CurrnetGachaSteplist = {}
    local gambleclslist, cnt = GetClassList("event_gamble_list")
	if not gambleclslist then
		return;
	end
	local GachaStepGroup = "SANTA_EVENT_GACHA"..Gacha_Step	
    if IsInCity then
        GachaStepGroup = GachaStepGroup.."_city";
    end
	local CurrnetGahcaSteplist = {};
	for i = 0, cnt - 1 do
        local gambelcls = GetClassByIndexFromList(gambleclslist, i);
        local GroupName = TryGetProp(gambelcls, "Group", "None")
		if GachaStepGroup == GroupName then
			table.insert(CurrnetGachaSteplist, gambelcls);
		end
	end
    return CurrnetGachaSteplist;

end

function GET_STEP_GACHA_RATIO_GRADE(pc, Gacha_Step)
    local GachaList = GET_STEP_GACHA_CLS(pc, Gacha_Step)
    local Ratio_list = {}

    for  i,cls in pairs(GachaList) do
        local Ratio = TryGetProp(cls, "Ratio", 0)
        local Rank = TryGetProp(cls, "Rank", 0)
        
        local TotalRatio = table.find(Ratio_list, Rank);
        if table.find(Ratio_list, Rank) == 0 then
            Ratio_list[Rank] = Ratio    
        else
            Ratio_list[Rank] = Ratio_list[Rank] + Ratio;
        end
    end

    return Ratio_list;
end


-- 레티샤 확률을 보기 위해 다른 타입의 테이블을 넘기는 방식
function GET_STEP_GACHA_PROBABILITY_TABLE(Gacha_Step)
    local CurrnetGachaSteplist = {}
    local gambleclslist, cnt = GetClassList("event_gamble_list")
	if not gambleclslist then
		return;
	end
	local GachaStepGroup = "SANTA_EVENT_GACHA"..Gacha_Step	
    if IS_IN_CITY() == 1 then
        GachaStepGroup = GachaStepGroup..'_city';
    end
	local CurrnetGahcaSteplist = {};
	for i = 0, cnt - 1 do
        local gambelcls = GetClassByIndexFromList(gambleclslist, i);
        local GroupName = TryGetProp(gambelcls, "Group", "None")
		if GachaStepGroup == GroupName then
            local ratio = gambelcls.Ratio / 1000;
            ratio = string.format("%.4f", ratio)
			table.insert(CurrnetGachaSteplist, {gambelcls.ItemName, gambelcls.Count, ratio, gambelcls.Rank});
		end
	end

    return CurrnetGachaSteplist;

end

function GET_RANDOM_SORT_LIST(max)
    local list = {}
    for i = 1, max do
        list[i] = i
    end
    
    -- Fisher-Yates 알고리즘을 사용하여 리스트 섞기
    for i = #list, 2, -1 do
        local j = IMCRandom(1,i);
        list[i], list[j] = list[j], list[i]
    end
    
    return list
end


function GET_GACHA_ITEM_STEP(mat_item_name)
    local gambleclslist, cnt = GetClassList("event_gamble_list")
	for i = 0, cnt - 1 do
        local gambelcls = GetClassByIndexFromList(gambleclslist, i);
        local ItemName = TryGetProp(gambelcls, "ItemName", "None")
        local Rank = TryGetProp(gambelcls, "Rank", "None")
        local Count = TryGetProp(gambelcls, "Count", "None")

        
        if ItemName == mat_item_name then
            return Rank, Count;
        end
	end

    return 1, 0;
end


function IS_IN_CITY_SERVER(pc)
    local s_checkZoneList;
	if s_checkZoneList == nil then
		s_checkZoneList = {'c_Klaipe', 'c_orsha', 'c_fedimian' };
	end

	local pcZone = GetZoneName(pc);
	local isCity = false;
	for k,v in pairs(s_checkZoneList) do
		if pcZone == v then
			return true;
		end
	end

    return false;
end
