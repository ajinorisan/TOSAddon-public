function GET_EXHIBITION_GOAL_EXP(pc)
    local aObj;
    if IsServerSection() == 1 then
        aObj = GetAccountObj(pc)
    else
        aObj = GetMyAccountObj()
    end

	local total_exp = TryGetProp(aObj, "ARCHEOLOGY_EXP", 0)
	local max_level = 5;
	local remain_exp = 0;
	for i = 1, max_level do
		local cls = GetClass('archeology_exhibition_exp', tostring(i))        
		local _exp = TryGetProp(cls, 'Exp', 0)        
		if total_exp < _exp then  
			return _exp;
		end
	end

end
function EXHIBITION_EXP_TO_LEVEL(pc, exp)
    local total_exp = exp
    local max_level = 5;
    for i = 1, max_level do
        local cls = GetClassByType('archeology_exhibition_exp', tostring(i))        
        local _exp = TryGetProp(cls, 'Exp', 0)        
        if total_exp <= _exp then            
            return i , cls.MaxCost
        end
    end
    local cls = GetClassByType('archeology_exhibition_exp', max_level)        

    return max_level, cls.MaxCost
end

function GET_ARCHEOLOGY_EXHIBITION_INFO(pc)
    local expfunc = function(aObj)
        if not aObj then
            return 0, 0;
        end
        local total_exp = TryGetProp(aObj, "ARCHEOLOGY_EXP", 0)
        local max_level = 5;
        for i = 1, max_level do
            local cls = GetClassByType('archeology_exhibition_exp', tostring(i))        
            local _exp = TryGetProp(cls, 'Exp', 0)        
            if total_exp < _exp then            
                return i - 1, cls.MaxCost - 1
            end
        end

            local cls = GetClassByType('archeology_exhibition_exp', max_level)       
            return max_level, cls.MaxCost
        end
    local aObj;

    if IsServerSection() == 1 then
        aObj = GetAccountObj(pc)
    else
        aObj = GetMyAccountObj()
    end

    return expfunc(aObj)
end

function GET_CURRENT_AREX_COST(pc)
    local aObj;
    if IsServerSection() == 1 then
        aObj = GetAccountObj(pc)
    else
        aObj = GetMyAccountObj()
    end

    if not aObj then
        return 0;
    end

    local cost = TryGetProp(aObj, "ARCHEOLOGY_COST", 0)
    return cost;
end

function CHECK_EXHIBITION_COST(pc, cost)
    local curCost = GET_CURRENT_AREX_COST(pc)
    local lv, maxCost = GET_ARCHEOLOGY_EXHIBITION_INFO(pc)

    if maxCost < curCost + cost then
        return false;
    end
    return true;
end

function GET_ARCEX_SLOT_ITEMS(pc)
    local aObj;
    if IsServerSection() == 1 then
        aObj = GetAccountObj(pc)
    else
        aObj = GetMyAccountObj()
    end
    local ARCHEOLOGY_EQUIP = TryGetProp(aObj, "ARCHEOLOGY_EQUIP", 0)
    local slot1, slot2, slot3 = UnpackSlots(ARCHEOLOGY_EQUIP)
    return slot1, slot2, slot3;
end

function GET_ARCEX_SLOT_ITEM_IDX(pc, index)
    local slot1, slot2, slot3 = GET_ARCEX_SLOT_ITEMS(pc)
    if index == 1 then
        return slot1
    end
    if index == 2 then
        return slot2
    end
    if index == 3 then
        return slot3
    end

    return 0;
end

function GET_ARCEX_ITEM_BY_CLSID(clsid)
    local cls = GetClassByType('archeology_exhibition_item', clsid)      
    return cls
end


--버프 리스트 가져오기
--key = 태그
--value - 값
function GET_CURRENT_APPLY_EFFECT_LIST(pc)
    local aObj;
    if IsServerSection() == 1 then
        aObj = GetAccountObj(pc)
    else
        aObj = GetMyAccountObj()
    end

    local slots = {GET_ARCEX_SLOT_ITEMS(pc)}

    local apply_buff_list = {}
    for _,item_idx in pairs(slots) do
        local item_cls = GET_ARCEX_ITEM_BY_CLSID(item_idx)
        if item_cls then
            local EffecTags = TryGetProp(item_cls, "EffectTags", "None")
            local EffectValue = TryGetProp(item_cls, "EffectValues", "0")
            local TagList = StringSplit(EffecTags, ";");
            local ValueList = StringSplit(EffectValue, ";");
            --버프 태그를 모아 수치를 합산 한 후, 한번에 버프를 적용시킨다.
            for i = 1, #TagList do
                local Effect_Tag = TagList[i];
                local Effect_Value = tonumber(ValueList[i]);
                if apply_buff_list[Effect_Tag] == nil then
                    apply_buff_list[Effect_Tag] = Effect_Value
                else
                    apply_buff_list[Effect_Tag] = apply_buff_list[Effect_Tag] + Effect_Value
                end
            end
        end
    end
    return apply_buff_list;
end