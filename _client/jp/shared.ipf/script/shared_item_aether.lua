-- shared_item_aether.lua
function get_solo_dungeon_clear_stage(self)
    local clear_stage = nil;
    if IsServerSection() == 0 then
        local account_obj = GetMyAccountObj();
        if account_obj ~= nil then
            clear_stage = TryGetProp(account_obj, "SOLO_DUNGEON_MINI_CLEAR_STAGE");
        end
    else
        local account_obj = GetAccountObj(self);
        if account_obj ~= nil then
            clear_stage = TryGetProp(account_obj, "SOLO_DUNGEON_MINI_CLEAR_STAGE");
        end
    end
    return clear_stage;
end

function get_solo_dungeon_etc_clear_stage(self)
    local clear_stage = nil;
    if IsServerSection() == 0 then
        local etc_object = GetMyEtcObject();
        if etc_object ~= nil then
            clear_stage = TryGetProp(etc_object, "BerniceShard_Dungeon_Save_Stage");
        end
    else
        local etc_object = GetETCObject(self);
        if etc_object ~= nil then
            clear_stage = TryGetProp(etc_object, "BerniceShard_Dungeon_Save_Stage");
        end
    end
    return clear_stage;
end

-- by gem item
function get_ratio_success_aether_gem(self, item)
    if item ~= nil then
        local value = 0;
        if IsServerSection() == 0 then
            local level = TryGetProp(item, "AetherGemLevel");
            local clear_stage = get_solo_dungeon_etc_clear_stage();
            if level ~= nil and clear_stage ~= nil then
                value = clear_stage - level; 
            end
        else
            local level = TryGetProp(item, "AetherGemLevel");
            local clear_stage = get_solo_dungeon_etc_clear_stage(self);
            if level ~= nil and clear_stage ~= nil then
                value = clear_stage - level;
            end
        end

        if value >= 10 then -- 100%
            return 100;
        elseif value == 9 then -- 90%
            return 90;
        elseif value == 8 then -- 80%
            return 80;
        elseif value == 7 then -- 70%
            return 70;
        elseif value == 6 then -- 60%
            return 60;
        elseif value <= 5 and value >= 0 then -- 50%
            return 50;
        elseif value == -1 then -- 25%
            return 25;
        elseif value == -2 then -- 12%
            return 12;
        elseif value == -3 then -- 6%
            return 6;
        elseif value == -4 then -- 3%
            return 3;
        elseif value == -5 then -- 2%
            return 2;
        elseif value <= -6 and value >= -10 then -- 1%
            return 1;
        elseif value <= -11 then -- 0%
            return 0;
        end
    end
    return 0;
end

-- by gem level
function get_ratio_success_aether_gem_equip(self, level)
    local value = 0;
    if IsServerSection() == 0 then
        local clear_stage = get_solo_dungeon_etc_clear_stage();
        if level ~= nil and clear_stage ~= nil then
            value = clear_stage - level; 
        end
    else
        local clear_stage = get_solo_dungeon_etc_clear_stage(self);
        if level ~= nil and clear_stage ~= nil then
            value = clear_stage - level;
        end
    end

    if value >= 10 then -- 100%
        return 100;
    elseif value == 9 then -- 90%
        return 90;
    elseif value == 8 then -- 80%
        return 80;
    elseif value == 7 then -- 70%
        return 70;
    elseif value == 6 then -- 60%
        return 60;
    elseif value <= 5 and value >= 0 then -- 50%
        return 50;
    elseif value == -1 then -- 25%
        return 25;
    elseif value == -2 then -- 12%
        return 12;
    elseif value == -3 then -- 6%
        return 6;
    elseif value == -4 then -- 3%
        return 3;
    elseif value == -5 then -- 2%
        return 2;
    elseif value <= -6 and value >= -10 then -- 1%
        return 1;
    elseif value <= -11 then -- 0%
        return 0;
    end
    return 0;
end

function get_aether_gem_max_level(item)
    if TryGetProp(item, 'GroupName', 'None') ~= 'Gem_High_Color' then
        return 0
    end

    local use_level = TryGetProp(item, "NumberArg1",0);
    local pivot = 460    
    local diff = (use_level - pivot) / 20
    local max_level = 120
    max_level = max_level + (30 * diff)
    return math.floor(max_level)
end

-- by gem item
function is_max_aether_gem_level(item)
    if item == nil then return false; end
    local max_level = get_aether_gem_max_level(item);    
    local use_level = TryGetProp(item, "NumberArg1",0);
    local cur_level = TryGetProp(item, "AetherGemLevel", 1);
    if cur_level >= max_level then return true;
    else return false; end
    return false;
end


function is_max_aether_gem_level_equip_new(item, level)
    local max_level = get_aether_gem_max_level(item);

    if level >= max_level then return true;
    else return false; end
    return false;
end


function get_current_aether_gem_level(item)
    if item == nil then return 0; end
    local cur_level = TryGetProp(item, "AetherGemLevel", 1);
    return cur_level;
end

-- 에테르 젬 강화 Count 설정
function tx_set_aether_gem_reinforce_count(self, count)
    if self == nil then return; end
    if IsServerSection() == 1 then
        local tx = TxBegin(self);
        if tx ~= nil then
            local etc_object = GetETCObject(self);
            if etc_object ~= nil then
                TxSetIESProp(tx, etc_object, "AetherGemReinforceCount", count);
            end
            local ret = TxCommit(tx);
            return ret;
        end
    end
    return "FAIL";
end

-- 에테르 젬 강화 Base Count 가져오기
function get_aether_gem_reinforce_count(self)
    local reinforce_count = 0;
    local etc_object = nil

    if IsServerSection() == 0 then
        etc_object = GetMyEtcObject();        
    else
        if self ~= nil then
            etc_object = GetETCObject(self);            
        end
    end

    if etc_object ~= nil then
        reinforce_count = TryGetProp(etc_object, "AetherGemReinforceCount", 0);
    end

    return reinforce_count;
end


function get_aether_gem_reinforce_count_total(self)
    local reinforce_count_total = 0;
    local etc_object = nil
    if IsServerSection() == 0 then
        etc_object = GetMyEtcObject();        
    else
        if self ~= nil then
            etc_object = GetETCObject(self);            
        end
    end

    if etc_object ~= nil then
        local reinforce_count = TryGetProp(etc_object, "AetherGemReinforceCount", 0);
        reinforce_count_total = reinforce_count_total + reinforce_count
        for i = 460, PC_MAX_LEVEL, 20 do
            reinforce_count_total = reinforce_count_total + TryGetProp(etc_object, "AetherGemReinforceCount_" .. i, 0);
        end
    end

    return reinforce_count_total;
end

function get_aether_gem_reinforce_count_by_level(self, level)
    local reinforce_count = 0;
    if IsServerSection() == 0 then
        local etc_object = GetMyEtcObject();
        if etc_object ~= nil then
            reinforce_count = TryGetProp(etc_object, "AetherGemReinforceCount_" .. level, 0);
        end
    else
        if self ~= nil then
            local etc_object = GetETCObject(self);
            if etc_object ~= nil then
                reinforce_count = TryGetProp(etc_object, "AetherGemReinforceCount_" .. level, 0);
            end
        end
    end
    return reinforce_count;
end

function is_valid_transfer_aether_gem(left, right)
    if TryGetProp(left, 'GroupName', 'None') ~= 'Gem_High_Color' 
    or TryGetProp(right, 'GroupName', 'None') ~= 'Gem_High_Color' then
        return false, 'None'
    end

    local left_grade = TryGetProp(left, 'NumberArg1', 0)
    local right_grade = TryGetProp(right, 'NumberArg1', 0)

    if left_grade == PC_MAX_LEVEL then
        return false, 'None'
    end

    if left_grade >= right_grade then
        return false, 'RequireNextGradeAetherGem'
    end

    if right_grade - left_grade ~= 20 then
        return false, 'RequireNextGradeAetherGem'
    end

    local left_lv = get_current_aether_gem_level(left)
    local right_lv = get_current_aether_gem_level(right)

    if right_lv >= left_lv then
        return false, 'aleadyHighLevel'
    end

    if is_max_aether_gem_level(left) == false then
        return false, 'None'
    end

    return true, 'None'
end

-- 에테르 젬 강화 MaxCount 설정
function exprop_set_aether_gem_reinforce_max_count(self, count)
    if self == nil then return; end
    if IsServerSection() == 1 then
        SetExProp(self, "aether_gem_reinforce_max_count", count);
    end
end

-- 에테르 젬 강화 MaxCount 가져오기
function exprop_get_aether_gem_reinforce_max_count(self)
    if self == nil then return; end
    if IsServerSection() == 1 then
        return GetExProp(self, "aether_gem_reinforce_max_count");
    end
    return 0;
end

-- 에테르 젬(힘) --
function get_aether_gem_STR_prop(level)
    return "STR", level * 2, true; -- prop_name, prop_value, use_operator   
end

-- 에테르 젬(지능) --
function get_aether_gem_INT_prop(level)
    return "INT", level * 2, true; -- prop_name, prop_value, use_operator   
end

-- 에테르 젬(민첩) --
function get_aether_gem_DEX_prop(level)
    return "DEX", level * 2, true; -- prop_name, prop_value, use_operator   
end

-- 에테르 젬(정신) --
function get_aether_gem_MNA_prop(level)
    return "MNA", level * 2, true; -- prop_name, prop_value, use_operator   
end

-- 에테르 젬(체력) --
function get_aether_gem_CON_prop(level)
    return "CON", level * 2, true; -- prop_name, prop_value, use_operator   
end


-- lv480_aether_lvup_scroll_lv100
function IS_ABLE_TO_USE_AETHER_LVUP_SCROLL(item, scroll)
    if TryGetProp(item, 'GroupName', 'None') ~= 'Gem_High_Color' then
        return false, 'NotValidItem'
    end

    if TryGetProp(scroll, 'StringArg', 'None') ~= 'aether_reinforce_scroll' then
        return false, 'DontUseItem'
    end 

    local gem_level = get_current_aether_gem_level(item);    
	if gem_level >= TryGetProp(scroll, 'NumberArg2', 0) then
		return false, 'cant_use_more_than_lvup_point'
	end

    if TryGetProp(item, 'NumberArg1', 0) == TryGetProp(scroll, 'NumberArg1', 0) then
        return true
    end

	return false, 'DontUseItem'
end


function IS_ABLE_TO_CONVERT_AETHER_GEM(aether, scroll)
    if TryGetProp(aether, 'NumberArg1', 0) ~= TryGetProp(scroll, 'NumberArg1', 0) then
        return false, 'NotValidItem'
    end
    
    if TryGetProp(aether, 'GroupName', 'None') ~= 'Gem_High_Color' then
        return false, 'NotValidItem'
    end

    if TryGetProp(scroll, 'StringArg', 'None') ~= 'AetherConvertScroll' then
        return false, 'NotValidItem'
    end

    return true, 'None'
end


-- 테스트
function test_reset_aether_gem_reinforce_count(self)
    exprop_set_aether_gem_reinforce_max_count(self, 5);
    SendAddOnMsg(self, "AETHER_GEM_REINFORCE_MAX_COUNT", "", 5);
    if IsRunningScript(self, "tx_set_aether_gem_reinforce_count") ~= 1 then
        RunScript("tx_set_aether_gem_reinforce_count", self, 5);
    end
end
