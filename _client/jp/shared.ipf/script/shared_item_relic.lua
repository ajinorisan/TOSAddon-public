-- shared_item_relic.lua

item_relic_reinforce = {}  -- namespace

shared_item_relic = {}

max_relic_option_count = 10 -- 옵션이 최대 10개 있다고 가정함
max_relic_gem_socket_count = 3 -- 젬 3개(마젠타, 시안, 블랙)
relic_gem_type = {
    Gem_Relic_Cyan = 0,
    Gem_Relic_Magenta = 1,
    Gem_Relic_Black = 2,
}

relic_gem_list = { {'Gem_Relic_Cyan', 0} , {'Gem_Relic_Magenta', 1} , {'Gem_Relic_Black', 2} }

local relic_parameter_list = nil
function make_relic_parameter_list()
	if relic_parameter_list ~= nil then
		return
	end

	relic_parameter_list = {}

    relic_parameter_list = {} -- 
    
    relic_parameter_list['BASE_REINFORCE_FAIL_REVISION_RATIO'] = 5  -- 기본 강화 실패 보정 비율(아이템 없이)
	relic_parameter_list['REINFORCE_FAIL_REVISION_RATIO'] = 5 -- 5% , 보조제에 의한 강화 실패 보정 비율
	relic_parameter_list['MAX_SUB_REVISION_COUNT'] = 3 -- 강화 보조제 최대 적용 가능 개수
	relic_parameter_list['SUB_REVISION_RATIO'] = 20  -- 20%, 보조제 1개당 강화 실패 보정 비율에서 보정할 비율 , reinforce_percentUp
	relic_parameter_list['MAX_PREMIUM_SUB_REVISION_COUNT'] = 2 -- 프리미엄 강화 보조제 최대 적용 가능 개수
	relic_parameter_list['PREMIUM_SUB_REVISION_RATIO'] = 20  -- 20%, 프리미엄 보조제 1개당 강화 실패 보정 비율에서 보정할 비율 , reinforce_premium_percentUp	
end
make_relic_parameter_list()

-- 강화 실패시 보정되는 퍼센트(추가 아이템)
function GET_RELIC_REINFORCE_FAIL_REVISION_RATIO()
	if relic_parameter_list == nil then
		return 5
	end

	if relic_parameter_list['REINFORCE_FAIL_REVISION_RATIO'] == nil then
		return 5
	else
		return relic_parameter_list['REINFORCE_FAIL_REVISION_RATIO'] -- 5%
	end
end

function GET_RELIC_BASE_REINFORCE_FAIL_REVISION_RATIO()
	if relic_parameter_list == nil then
		return 10
	end

	if relic_parameter_list['BASE_REINFORCE_FAIL_REVISION_RATIO'] == nil then
		return 10
	else
		return relic_parameter_list['BASE_REINFORCE_FAIL_REVISION_RATIO'] -- 5%
	end
end

-- 강화 보조제 최대 적용 가능 개수
function GET_RELIC_MAX_SUB_REVISION_COUNT()
	if relic_parameter_list == nil then
		return 3
	end

	if relic_parameter_list['MAX_SUB_REVISION_COUNT'] == nil then
		return 3
	else
		return relic_parameter_list['MAX_SUB_REVISION_COUNT']
	end
end

-- 강화 보조제로 보정되는 비율
function GET_RELIC_SUB_REVISION_RATIO()
	if relic_parameter_list == nil then
		return 10
	end

	if relic_parameter_list['SUB_REVISION_RATIO'] == nil then
		return 10
	else
		return relic_parameter_list['SUB_REVISION_RATIO']
	end
end

-- 프리미엄 강화 보조제 최대 적용 가능 개수
function GET_RELIC_MAX_PREMIUM_SUB_REVISION_COUNT()
	if relic_parameter_list == nil then
		return 2
	end

	if relic_parameter_list['MAX_PREMIUM_SUB_REVISION_COUNT'] == nil then
		return 2
	else
		return relic_parameter_list['MAX_PREMIUM_SUB_REVISION_COUNT']
	end
end

-- 프리미움 강화 보조제로 보정되는 비율
function GET_RELIC_PREMIUM_SUB_REVISION_RATIO()
	if relic_parameter_list == nil then
		return 10
	end

	if relic_parameter_list['PREMIUM_SUB_REVISION_RATIO'] == nil then
		return 10
	else
		return relic_parameter_list['PREMIUM_SUB_REVISION_RATIO']
	end
end

-- 강화 보조제 인가? (노멀, 프리미엄)
item_relic_reinforce.is_reinforce_percentUp = function(misc_item)
	if TryGetProp(misc_item, 'StringArg', 'None') == 'reinforce_premium_percentUp' then
		return 'premium'
	end

	if TryGetProp(misc_item, 'StringArg', 'None') == 'reinforce_percentUp' then
		return 'normal'
	end

	return 'NO'
end

-- 저장된 추가 수치
item_relic_reinforce.get_additional_ratio = function(gem_item)    
    return TryGetProp(gem_item, 'ReinforceRevision', 0)
end
-- 강화 실패시 보정할 수치
item_relic_reinforce.get_revision_ratio = function(base_success_ratio, sub_revision_count, sub_premium_revision_count)
    local sub_revision_ratio = GET_RELIC_SUB_REVISION_RATIO() * sub_revision_count
    local sub_premium_revision_ratio = GET_RELIC_PREMIUM_SUB_REVISION_RATIO() * sub_premium_revision_count    

    local add_rate = GET_RELIC_REINFORCE_FAIL_REVISION_RATIO() -- 강화 실패시에 보정할 비율    
    local base = GET_RELIC_BASE_REINFORCE_FAIL_REVISION_RATIO() 
    add_rate = add_rate * (sub_revision_ratio + sub_premium_revision_ratio) * 0.01
    add_rate = base + add_rate
    return math.ceil(base_success_ratio * add_rate * 0.01) -- 강화 실패시 보정할 수치
end

--- end of 확률 관련 -----------------------------------------------------


-- 성물 젬 강화 확률, 재료
shared_item_relic.get_gem_reinforce_mat_name = function(lv)
    local cls = GetClass('relic_gem_info', 'RelicGem_Upgrade_Lv' .. lv)
    if cls == nil then
        return 'None', 'None'
    end

    local mat_1 = TryGetProp(cls, 'Material_1', 'None')
    local mat_2 = TryGetProp(cls, 'Material_2', 'None')

    return mat_1, mat_2
end

shared_item_relic.get_gem_reinforce_ratio = function(lv)
    local cls = GetClass('relic_gem_table', 'RelicGem_Upgrade_Lv' .. lv)
    if cls == nil then
        return 0
    end

    local ratio = TryGetProp(cls, 'Ratio', 0)
    
    return ratio
end

shared_item_relic.get_gem_reinforce_mat_misc = function(lv)
    local cls = GetClass('relic_gem_info', 'RelicGem_Upgrade_Lv' .. lv)
    if cls == nil then
        return 0
    end

    local value = TryGetProp(cls, 'MaterialCnt_1', 0)
    
    return value
end

shared_item_relic.get_gem_reinforce_mat_stone = function(lv)
    local cls = GetClass('relic_gem_info', 'RelicGem_Upgrade_Lv' .. lv)
    if cls == nil then
        return 0
    end

    local value = TryGetProp(cls, 'MaterialCnt_2', 0)
    
    return value
end

shared_item_relic.get_gem_reinforce_silver = function(lv)
    local cls = GetClass('relic_gem_info', 'RelicGem_Upgrade_Lv' .. lv)
    if cls == nil then
        return 0
    end

    local silver = tonumber(TryGetProp(cls, 'SilverCost', '0'))
    
    return silver
end

-- 성물 젬 합성
shared_item_relic.get_gem_compose_mat_name = function()
    local cls = GetClass('relic_gem_info', 'CompositionCost')
    if cls == nil then
        return 'None'
    end

    local mat_1 = TryGetProp(cls, 'Material_1', 'None')

    return mat_1
end

shared_item_relic.get_gem_compose_mat_cnt = function()
    local cls = GetClass('relic_gem_info', 'CompositionCost')
    if cls == nil then
        return 0
    end

    local cnt_1 = TryGetProp(cls, 'MaterialCnt_1', 0)

    return cnt_1
end

shared_item_relic.get_gem_compose_silver = function()
    local cls = GetClass('relic_gem_info', 'CompositionCost')
    if cls == nil then
        return 0
    end

    local value = TryGetProp(cls, 'SilverCost', 0)

    return 0
end

-- 성물 젬 분해
shared_item_relic.get_gem_decompose_mat_name = function()
    local cls = GetClass('relic_gem_info', 'DecomposeResult')
    if cls == nil then
        return 'None'
    end

    local mat_name = TryGetProp(cls, 'Material_1', 'None')

    return mat_name
end

shared_item_relic.get_gem_decompose_mat_cnt = function()
    local cls = GetClass('relic_gem_info', 'DecomposeResult')
    if cls == nil then
        return 0
    end

    local min = TryGetProp(cls, 'MaterialCnt_1', 0)
    local max = TryGetProp(cls, 'MaterialCnt_2', 0)

    return min, max
end

shared_item_relic.get_gem_decompose_silver = function()
    local cls = GetClass('relic_gem_info', 'DecomposeResult')
    if cls == nil then
        return 0
    end

    local value = TryGetProp(cls, 'SilverCost', 0)

    return value
end

-- 권능의 숨결 정화 재료 리스트
shared_item_relic.get_refine_material_list = function()
    local list = {}
    local cls_list, cnt = GetClassList('PointExtractItem')
    for i = 0, cnt - 1 do
        local cls = GetClassByIndexFromList(cls_list, i)
        if cls ~= nil and TryGetProp(cls, 'PointName', 'None') == 'Relic_EXP' then
            local item_name = TryGetProp(cls, 'ItemClassName', 'None')
            local point = TryGetProp(cls, 'Point', 0)
            list[item_name] = point
        end
    end

    return list
end

-- 정화된 권능의 숨결 1개 변환에 필요한 실버
shared_item_relic.get_require_money_for_refine = function()
    local money_require = 1000000
    return money_require
end

-- 경험치 재료
shared_item_relic.get_exp_material_name = function()
    local name_list = { 'Relic_exp_token_refine', 'Relic_exp_token_refine_Trade', 'Relic_exp_token_refine_event' }
    return name_list
end

shared_item_relic.get_exp_material_value = function()
    local value = 50
    return value
end

-- 현재 레벨
shared_item_relic.get_current_lv = function(item)
    if item == nil then
        return 0
    end

    local current_lv = TryGetProp(item, 'Relic_LV', 1)

    return current_lv
end

-- 현재 누적 경험치
shared_item_relic.get_current_exp = function(item)
    if item == nil then
        return 0
    end

    local class_type = TryGetProp(item, 'ClassType', 'None')
    if class_type ~= 'Relic' then
        return 0
    end

    local current_exp = TryGetProp(item, 'Relic_EXP', '0')

    return tonumber(current_exp)
end

-- RP
shared_item_relic.get_rp_material_name_list = function()
    local name_list = { 'misc_Ectonite', 'misc_Ectonite_NoTrade', 'misc_Ectonite_Care', }
    return name_list
end

shared_item_relic.get_rp_material_value_list = function()
    local value_list = { 10, 1000, 10, }
    return value_list
end

shared_item_relic.get_rp = function(pc)
    if pc == nil then
        return 0, 0
    end

    local acc = nil
    if IsServerSection() == 1 then
        acc = GetAccountObj(pc)
    else
        acc = GetMyAccountObj()
    end

    if acc == nil then
        return 0, 0
    end

    local current_rp = TryGetProp(acc, 'RP', 0)
    local max_rp = tonumber(RELIC_MAX_RP)

    return current_rp, max_rp
end

-- 최대렙 확인
shared_item_relic.is_max_lv = function(item)
    if item == nil then
        return "YES"
    end

    local max = tonumber(RELIC_MAX_LEVEL)
    local cur = shared_item_relic.get_current_lv(item)
    
    if cur >= max then
        return "YES"
    else
        return "NO"
    end
end

-- 해당 레벨에 필요한 누적 경험치(레벨)
shared_item_relic.get_require_exp_sum = function(lv)
    local max_lv = tonumber(RELIC_MAX_LEVEL)
    if lv > max_lv then
        return 0
    end

    local exp_cls = GetClass('relic_exp', tostring(lv))
    local exp_sum = TryGetProp(exp_cls, 'Total_Exp', '0')

    return tonumber(exp_sum)
end

-- 현재 레벨에 필요한 누적 경험치(아이템)
shared_item_relic.get_current_lv_exp = function(item)
    local current_lv = shared_item_relic.get_current_lv(item)
    local exp_sum = shared_item_relic.get_require_exp_sum(current_lv)
    
    return exp_sum
end

shared_item_relic.get_current_lv_exp_interval = function(item)
    local current_lv = shared_item_relic.get_current_lv(item)
    local max_lv = tonumber(RELIC_MAX_LEVEL)
    if current_lv >= max_lv then
        current_lv = max_lv - 1
    end
    local cur_exp_sum = shared_item_relic.get_require_exp_sum(current_lv)
    local next_exp_sum = shared_item_relic.get_require_exp_sum(current_lv + 1)

    return next_exp_sum - cur_exp_sum
end

-- 렙업 요구 경험치
shared_item_relic.get_require_exp_for_lv_up = function(item, goal_lv)
    if goal_lv <= 1 then
        return '0'
    end

    if goal_lv > tonumber(RELIC_MAX_LEVEL) then
        return '0'
    end

    local current_lv = shared_item_relic.get_current_lv(item)
    if goal_lv <= current_lv then
        return '0'
    end

    local goal_exp = shared_item_relic.get_require_exp_sum(goal_lv)
    local cur_exp = shared_item_relic.get_current_exp(item)
    if cur_exp > goal_exp then
        return '0'
    end

    local require_exp = goal_exp - cur_exp
    
    return tostring(require_exp)
end

-- 경험치 먹일 때 레벨 증가량(최대 레벨 도달 시 경험치 증가량 조정)
shared_item_relic.get_lvup_value_by_expup = function(item, exp)
    local current_lv = shared_item_relic.get_current_lv(item)
    local max_lv = tonumber(RELIC_MAX_LEVEL)
    if current_lv >= max_lv then
        return 0, 0
    end
    
    local lvup = 0
    local exp_adjust = exp
    local current_exp = shared_item_relic.get_current_exp(item)
    for i = current_lv + 1, max_lv do
        local next_exp = shared_item_relic.get_require_exp_sum(i)
        if next_exp <= current_exp + exp then
            lvup = lvup + 1
            if i == max_lv then
                exp_adjust = next_exp - current_exp
            end
        else
            break
        end
    end

    return lvup, exp_adjust
end

shared_item_relic.get_current_lv_by_exp = function(item)
    if item == nil then
        return 0
    end

    local max_lv = tonumber(RELIC_MAX_LEVEL)
    local current_exp = shared_item_relic.get_current_exp(item)
    for i = 2, max_lv do
        local require_exp = shared_item_relic.get_require_exp_sum(i)
        if require_exp > current_exp then
            return i - 1
        elseif require_exp == current_exp then
            return i
        end
    end

    return max_lv
end

shared_item_relic.is_max_gem_lv = function(item)
    local max_lv = 10
    local cur_lv = TryGetProp(item, 'GemLevel', 1)
    if cur_lv >= max_lv then
        return true
    else
        return false
    end
end

dummy_item_guilty_name = {
    Sword = "Dummy_Sword_Guilty",
    THSword = "Dummy_Thsword_Guilty",
    Spear = "Dummy_Spear_Guilty",
    THSpear = "Dummy_Thspear_Guilty",
    Mace = "Dummy_Mace_Guilty",
    THMace = "Dummy_Thmace_Guilty",
    THBow = "Dummy_Bow_Guilty",
    Cannon = "Dummy_Cannon_Guilty",
    Rapier = "Dummy_Rapier_Guilty",
    Musket = "Dummy_Musket_Guilty",
    Staff = "Dummy_Rod_Guilty",
    THStaff = "Dummy_Staff_Guilty",
    Bow = "Dummy_Crossbow_Guilty",
    Shield = "Dummy_Shield_Guilty",
    Dagger = "Dummy_Dagger_Guilty",
    Pistol = "Dummy_Pistol_Guilty",
}

-------------- 성물 해방 버프  ----------------
-- 성물 해방 버프에 대한 처리를 위해 DummyEquipItem 종류를 반환하는 함수.
function get_dummy_item_relic_buff(self, spot)
    if self == nil or spot == nil then 
        return "None"; 
    end

    local item_name = "None";
    local class_type = TryGetProp(GetEquipItem(self, spot), "ClassType", "None");
    if dummy_item_guilty_name[class_type] ~= nil then
        item_name = dummy_item_guilty_name[class_type];
    end

    return item_name;
end

-- 성물 해방 버프에 대한 처리를 위해 DummyEquipItem 종류를 반환하는 함수.
function get_dummy_item_relic_buff_by_object(self, item)
    if self == nil or item == nil then
        return "None";
    end

    local item_name = "None";
    local class_type = TryGetProp(item, "ClassType", "None");
    if dummy_item_guilty_name[class_type] ~= nil then
        item_name = dummy_item_guilty_name[class_type];
    end

    return item_name;
end

function SCR_RELIC_GEM_REINFORCE_COUPON()
    local list = {
        'Relic_gem_upgrade_token',
        'Event_Reinforce_100000coupon',
        'Event_Reinforce_100000coupon_Event',
        'Relic_Reinforce_100000coupon',
    }
    return list
end

function SCR_RELIC_REINFORCE_COUPON()
    local list = {
        'Event_Reinforce_100000coupon',
        'Event_Reinforce_100000coupon_Event',
        'Relic_Reinforce_100000coupon',
    }
    return list
end

function IS_VALID_RELICGEM_LVUP_BY_SCROLL(gem, scroll)
    if TryGetProp(gem, 'GroupName', 'None') ~= 'Gem_Relic' then
        return false, 'NotValidItem'
    end

    if TryGetProp(scroll, 'StringArg', 'None') ~= 'RelicGemLVUPScroll' then
        return false, 'NotValidItem'
    end

    if TryGetProp(gem, 'CharacterBelonging', 0) == 1 then
        return false, 'NotValidItem'
    end

    local now_lv = TryGetProp(gem, 'GemLevel', 1)
    local goal_lv = TryGetProp(scroll, 'NumberArg1', 0)
    if now_lv >= goal_lv then
        return false, 'ItemLevelIsGreaterThanMatItem'
    end

    return true
end

function IS_VALID_RELICGEM_LVUP_BY_SCROLL_CABINET(pc, gem_name, scroll)
    local acc = nil
    if IsServerSection() == 1 then
        acc = GetAccountObj(pc)
    else
        acc = GetMyAccountObj()
    end

    if acc == nil then
        return false, 'NotValidItem'
    end

    if TryGetProp(scroll, 'StringArg', 'None') ~= 'RelicGemLVUPScroll' then
        return false, 'NotValidItem'
    end

    local gem_cls = GetClass('Item', gem_name)
    local cabinet_cls = GetClass('cabinet_relicgem', gem_name)
    if gem_cls == nil or cabinet_cls == nil then
        return false, 'NotValidItem'
    end

    if TryGetProp(gem_cls, 'GroupName', 'None') ~= 'Gem_Relic' then
        return false, 'NotValidItem'
    end

    local open_name = TryGetProp(cabinet_cls, 'AccountProperty', 'None')
    if TryGetProp(acc, open_name, 0) ~= 1 then
        return false, 'NotValidItem'
    end

    local lv_name = TryGetProp(cabinet_cls, 'UpgradeAccountProperty', 'None')
    local now_lv = TryGetProp(acc, lv_name, 0)
    local goal_lv = TryGetProp(scroll, 'NumberArg1', 0)
    if now_lv >= goal_lv then
        return false, 'ItemLevelIsGreaterThanMatItem'
    end

    return true
end