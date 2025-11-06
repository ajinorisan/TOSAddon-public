-- shared_item_goddess_reinforce.lua, 가디스 장비 강화 관련 
-- item_goddess_reinforce.xml

local equip_end_lv = 540
local popoboost_item_lv = 520;

item_goddess_reinforce = {}  -- namespace

local item_goddess_reinforce_material_list = nil -- 가디스 등급 강화 재료 리스트
-- item_goddess_reinforce_material_list[item_UseLv][classtype][goal_reinforce_lv] - {재료이름 : 개수} 반환

local parameter_list = nil
function make_parameter_list()
	if parameter_list ~= nil then
		return
	end

	parameter_list = {}

	local start = 460
	while start <= equip_end_lv do
		parameter_list[start] = {} -- 460레벨용
		parameter_list[start]['REINFORCE_FAIL_REVISION_RATIO'] = 0.1 -- 10% , 강화 실패 보정 비율(시도한 최종 강화 확률의 10%)
		parameter_list[start]['MAX_FAIL_REVISION'] = 70000 -- 70%, 강화 실패로 인한 최대 보정확률(기본 확률 포함)
		parameter_list[start]['MAX_SUB_REVISION_COUNT'] = 3 -- 강화 보조제 최대 적용 가능 개수
		parameter_list[start]['SUB_REVISION_RATIO'] = 0.2  -- 20%, 강화 보조제로 보정되는 비율 , reinforce_percentUp
		parameter_list[start]['MAX_PREMIUM_SUB_REVISION_COUNT'] = 2 -- 프리미엄 강화 보조제 최대 적용 가능 개수
		parameter_list[start]['PREMIUM_SUB_REVISION_RATIO'] = 0.2  -- 20%, 프리미엄 보조제로 보정되는 비율 , reinforce_premium_percentUp
		parameter_list[start]['MAX_REINFORCE_POINT'] = 30 -- 최대 30강

		start = start + 10
	end
end
make_parameter_list()

-- 강화 실패시 보정되는 퍼센트
function GET_REINFORCE_FAIL_REVISION_RATIO(lv)
	if parameter_list[lv] == nil then
		return 0.1
	end

	if parameter_list[lv]['REINFORCE_FAIL_REVISION_RATIO'] == nil then
		return 0.1
	else
		return parameter_list[lv]['REINFORCE_FAIL_REVISION_RATIO'] -- 10%
	end
end

-- 최대 강화 보정 확률
function GET_MAX_FAIL_REVISION(lv)
	if parameter_list[lv] == nil then
		return 70000
	end

	if parameter_list[lv]['MAX_FAIL_REVISION'] == nil then
		return 70000
	else
		return parameter_list[lv]['MAX_FAIL_REVISION']
	end
end

-- 강화 보조제 최대 적용 가능 개수
function GET_MAX_SUB_REVISION_COUNT(lv)
	if parameter_list[lv] == nil then
		return 3
	end

	if parameter_list[lv]['MAX_SUB_REVISION_COUNT'] == nil then
		return 3
	else
		return parameter_list[lv]['MAX_SUB_REVISION_COUNT']
	end
end

-- 강화 보조제로 보정되는 비율
function GET_SUB_REVISION_RATIO(lv)
	if parameter_list[lv] == nil then
		return 0.2
	end

	if parameter_list[lv]['SUB_REVISION_RATIO'] == nil then
		return 0.2
	else
		return parameter_list[lv]['SUB_REVISION_RATIO']
	end
end

-- 프리미엄 강화 보조제 최대 적용 가능 개수
function GET_MAX_PREMIUM_SUB_REVISION_COUNT(lv)
	if parameter_list[lv] == nil then
		return 2
	end

	if parameter_list[lv]['MAX_PREMIUM_SUB_REVISION_COUNT'] == nil then
		return 2
	else
		return parameter_list[lv]['MAX_PREMIUM_SUB_REVISION_COUNT']
	end
end

-- 프리미움 강화 보조제로 보정되는 비율
function GET_PREMIUM_SUB_REVISION_RATIO(lv)
	if parameter_list[lv] == nil then
		return 0.2
	end

	if parameter_list[lv]['PREMIUM_SUB_REVISION_RATIO'] == nil then
		return 0.2
	else
		return parameter_list[lv]['PREMIUM_SUB_REVISION_RATIO']
	end
end

-- 최대 강화 수치
function GET_MAX_REINFORCE_POINT(lv)
	if parameter_list[lv] == nil then
		return 30
	end

	if parameter_list[lv]['MAX_REINFORCE_POINT'] == nil then
		return 30
	else
		return parameter_list[lv]['MAX_REINFORCE_POINT']
	end
end

local function IS_POPOBOOST_REINFORCE_ITEM(ItemPopoProp, useLv, checkLv, IsPopoboostClear)
	-- 포포부스트 아이템이고, 현재 시즌이며, 레벨 스코프가 맞으며, 포포부스트가 클리어 된 상태가 아니라면
	if ItemPopoProp > 0 and ItemPopoProp == GET_POPOBOOST_ITEMPROP() and useLv <= checkLv and (not IsPopoboostClear) then
		return true;
	end
	return false;
end

--- 확률 관련 -----------------------------------------------------

-- 100000단위로 관리한다.
-- 해당 강화로 가는데 필요한 기본 수치를 가져온다.
item_goddess_reinforce.get_basic_prop = function(use_lv, goal_lv)
	local cls = GetClassByType('item_goddess_reinforce_' .. use_lv, tonumber(goal_lv))
	if cls == nil then
		return 0
	else
		return TryGetProp(cls, 'BasicProp', 0)
	end
end

-- 100000단위로 관리한다.
-- 해당 강화로 가는데 필요한 기본확률의 퍼센트를 가져온다.
item_goddess_reinforce.get_basic_prop_percentage = function(use_lv, goal_lv)
	local ret = item_goddess_reinforce.get_basic_prop(use_lv, goal_lv);
	local value = string.format('%.2f', ret / 1000)
	return value
end

-- 100000 단위로 관리한다.
-- 모루에 따른 보정확률 비율을 가져온다. (파기함)
item_goddess_reinforce.get_moru_revision_prop = function(moru_item_obj)
	if TryGetProp(moru_item_obj, 'StringArg', 'None') == 'DIAMOND' then
		-- 다이아몬드 모루
		return 2000 -- 2%		
	elseif TryGetProp(moru_item_obj, 'StringArg', 'None') == 'unique_gold_Moru' and TryGetProp(moru_item_obj, 'StringArg2', 'None') == 'free_Moru' then
		-- 빛나는 루비 모루
		return 1700 -- 1.7%
	elseif TryGetProp(moru_item_obj, 'StringArg', 'None') == 'unique_gold_Moru' then
		-- 루비 모루
		return 1500 -- 1.5%
	elseif TryGetProp(moru_item_obj, 'StringArg', 'None') == 'gold_Moru' and TryGetProp(moru_item_obj, 'StringArg2', 'None') == 'free_Moru' then
		-- 빛나는 황금 모루
		return 1200 -- 1.2%
	elseif TryGetProp(moru_item_obj, 'StringArg', 'None') == 'gold_Moru' then
		-- 황금 모루
		return 1000 -- 1%
	elseif TryGetProp(moru_item_obj, 'StringArg', 'None') == 'SILVER' then
		-- 실버 모루(빛나는)
		return 1000 -- 1%
	end

	-- 일반 모루
	return 0
end

-- 해당 강화에서 실패한 횟수로 인한 현재 보정 수치를 가져온다, Fail_Goddess_Reinforce_Revision, 직접적으로 값을 누적한다
item_goddess_reinforce.get_current_fail_revision_prop = function(equip_item_obj)
	local prop = TryGetProp(equip_item_obj, 'Fail_Goddess_Reinforce_Revision', 0)	
	return prop
end
item_goddess_reinforce.get_current_fail_revision_prop_percent = function(equip_item_obj)
	local value = item_goddess_reinforce.get_current_fail_revision_prop(equip_item_obj) / 1000
	return string.format('%.2f', value)
end

-- 강화 보조제 적용 수치
item_goddess_reinforce.get_sub_revision_prop = function(goal_lv, count, use_lv)
	if count == nil or count == 0 then return 0 end

	if count > GET_MAX_SUB_REVISION_COUNT(use_lv) then
		count = GET_MAX_SUB_REVISION_COUNT(use_lv)
	end
	
	local base = item_goddess_reinforce.get_basic_prop(use_lv, goal_lv)		
	base = base * GET_SUB_REVISION_RATIO(use_lv)

	return math.ceil(base * count)
end
item_goddess_reinforce.get_sub_revision_prop_percent = function(goal_lv, count, use_lv)
	local value = item_goddess_reinforce.get_sub_revision_prop(goal_lv, count, use_lv)
	return string.format('%.2f', value)
end

-- 프리미엄 강화 보조제 적용 수치
item_goddess_reinforce.get_premium_sub_revision_prop = function(goal_lv, count, use_lv)
	if count == nil or count == 0 then return 0 end

	if count > GET_MAX_PREMIUM_SUB_REVISION_COUNT(use_lv) then
		count = GET_MAX_PREMIUM_SUB_REVISION_COUNT(use_lv)
	end
	
	local base = item_goddess_reinforce.get_basic_prop(use_lv, goal_lv)	
	base = base * GET_PREMIUM_SUB_REVISION_RATIO(use_lv)

	return math.ceil(base * count)
end
item_goddess_reinforce.get_premium_sub_revision_prop_percent = function(goal_lv, count, use_lv)
	local value = item_goddess_reinforce.get_premium_sub_revision_prop_percent(goal_lv, count, use_lv)
	return string.format('%.2f', value)
end

-- 최종 성공 수치
item_goddess_reinforce.get_final_reinforce_prop = function(target_item, add_percentUp_count, add_premium_percentUp_count, IsPopoboostClear)
	local goal_lv = TryGetProp(target_item, 'Reinforce_2', 0) + 1 -- 목표 강화 수치
	local use_lv = TryGetProp(target_item, 'UseLv', 1)

	if item_goddess_growth.is_goddess_growth_item(target_item) == true then
		if goal_lv <= 10 then
			return 100000, 0, 0
		elseif goal_lv <= 15 then
			return 90000, 0, 0
		elseif goal_lv <= 30 then
			return 80000, 0, 0
		else
			return 100000, 0, 0
		end
	end	

	if add_percentUp_count > GET_MAX_SUB_REVISION_COUNT(use_lv) then
		add_percentUp_count = GET_MAX_SUB_REVISION_COUNT(use_lv)
	end

	if add_premium_percentUp_count > GET_MAX_PREMIUM_SUB_REVISION_COUNT(use_lv) then
		add_premium_percentUp_count = GET_MAX_PREMIUM_SUB_REVISION_COUNT(use_lv)
	end

	local base = item_goddess_reinforce.get_basic_prop(use_lv, goal_lv)
	local fail_prop = item_goddess_reinforce.get_current_fail_revision_prop(target_item) -- 실패한 보정확률	

	-- 	포포부스트	포포부스트 아이템이고, 포포부스트 시즌이 맞으며, 500 레벨 이하의 장비(마신, 우피니스, 네빌티스)에만 적용, 목표 미달성 시에만 적용
	if 	IS_POPOBOOST_REINFORCE_ITEM(TryGetProp(target_item, 'popoboost', 0), use_lv, popoboost_item_lv, IsPopoboostClear)	then
		base = base * 2			
	end

	if fail_prop + base >= 100000 then		
		base = math.min(base, 100000)
		return base, 0, 0
	else		
		local ret_add = 0
		local ret_premium_add = 0

		local value = base + fail_prop		
		for i = 1, add_percentUp_count do
			if value >= 100000 then
				break
			end

			local add = item_goddess_reinforce.get_sub_revision_prop(goal_lv, 1, use_lv)
			value = value + add
			ret_add = i
		end

		for i = 1, add_premium_percentUp_count do
			if value >= 100000 then
				break
			end

			local add_premium = item_goddess_reinforce.get_premium_sub_revision_prop(goal_lv, 1, use_lv)
			value = value + add_premium
			ret_premium_add = i
		end
		
		return value - fail_prop, ret_add, ret_premium_add
	end
end
-- 최종 확률을 퍼센트 형태로 가져온다.
item_goddess_reinforce.get_final_reinforce_prop_percent = function(target_item, add_percentUp_count, add_premium_percentUp_count, IsPopoboostClear)
	local value, _, _ = item_goddess_reinforce.get_final_reinforce_prop(target_item, add_percentUp_count, add_premium_percentUp_count, IsPopoboostClear) / 1000
	return string.format('%.2f', value)
end

-- 실패시 보정할 수치를 가져온다.
item_goddess_reinforce.get_fail_revision_prop = function(final_prop, use_lv)
	local ratio = GET_REINFORCE_FAIL_REVISION_RATIO(use_lv)
	return math.ceil(final_prop * ratio)
end
item_goddess_reinforce.get_fail_revision_prop_percent = function(final_prop, use_lv)
	local value = item_goddess_reinforce.get_fail_revision_prop(final_prop, use_lv)
	return string.format('%.2f', value)
end

-- 강화 보조제 인가? (노멀, 프리미엄)
item_goddess_reinforce.is_reinforce_percentUp = function(misc_item, target_lv)
	local lv = TryGetProp(misc_item, 'NumberArg1', 0)
	
	if TryGetProp(misc_item, 'StringArg', 'None') == 'reinforce_premium_percentUp' then
		return 'premium'
	end

	if TryGetProp(misc_item, 'StringArg', 'None') == 'reinforce_percentUp' and target_lv <= lv then
		return 'normal'
	end

	return 'NO'
end

--- end of 확률 관련 -----------------------------------------------------

--- 재료 관련 ------------------------------------------------------------

-- 460 레벨 장비, 재료 세팅
function setting_lv460_material(mat_list_by_lv)
	local seasonCoin = "GabijaCertificate" -- 여신의 증표(가비야)
	local medusaReinforceMisc = "misc_vasilisa_NoTrade" -- 정제된 바실리사의 비늘

	-- 여기서 레벨별 재료를 세팅한다.
	mat_list_by_lv[460][1][seasonCoin] = 263
	mat_list_by_lv[460][1][medusaReinforceMisc] = 3

	mat_list_by_lv[460][2][seasonCoin] = 263
	mat_list_by_lv[460][2][medusaReinforceMisc] = 3

	mat_list_by_lv[460][3][seasonCoin] = 263
	mat_list_by_lv[460][3][medusaReinforceMisc] = 3
	
	mat_list_by_lv[460][4][seasonCoin] = 263
	mat_list_by_lv[460][4][medusaReinforceMisc] = 3

	mat_list_by_lv[460][5][seasonCoin] = 450
	mat_list_by_lv[460][5][medusaReinforceMisc] = 3

	mat_list_by_lv[460][6][seasonCoin] = 450
	mat_list_by_lv[460][6][medusaReinforceMisc] = 5
	
	mat_list_by_lv[460][7][seasonCoin] = 450
	mat_list_by_lv[460][7][medusaReinforceMisc] = 5

	mat_list_by_lv[460][8][seasonCoin] = 450
	mat_list_by_lv[460][8][medusaReinforceMisc] = 5

	mat_list_by_lv[460][9][seasonCoin] = 450
	mat_list_by_lv[460][9][medusaReinforceMisc] = 5
	
	mat_list_by_lv[460][10][seasonCoin] = 673
	mat_list_by_lv[460][10][medusaReinforceMisc] = 5

	mat_list_by_lv[460][11][seasonCoin] = 673
	mat_list_by_lv[460][11][medusaReinforceMisc] = 7

	mat_list_by_lv[460][12][seasonCoin] = 673
	mat_list_by_lv[460][12][medusaReinforceMisc] = 7

	mat_list_by_lv[460][13][seasonCoin] = 673
	mat_list_by_lv[460][13][medusaReinforceMisc] = 7

	mat_list_by_lv[460][14][seasonCoin] = 673
	mat_list_by_lv[460][14][medusaReinforceMisc] = 7

	mat_list_by_lv[460][15][seasonCoin] = 927
	mat_list_by_lv[460][15][medusaReinforceMisc] = 7

	mat_list_by_lv[460][16][seasonCoin] = 927
	mat_list_by_lv[460][16][medusaReinforceMisc] = 8

	mat_list_by_lv[460][17][seasonCoin] = 1212
	mat_list_by_lv[460][17][medusaReinforceMisc] = 8

	mat_list_by_lv[460][18][seasonCoin] = 1523
	mat_list_by_lv[460][18][medusaReinforceMisc] = 8
	
	mat_list_by_lv[460][19][seasonCoin] = 1861
	mat_list_by_lv[460][19][medusaReinforceMisc] = 8

	mat_list_by_lv[460][20][seasonCoin] = 2224
	mat_list_by_lv[460][20][medusaReinforceMisc] = 8

	mat_list_by_lv[460][21][seasonCoin] = 2586
	mat_list_by_lv[460][21][medusaReinforceMisc] = 10
	
	mat_list_by_lv[460][22][seasonCoin] = 2948
	mat_list_by_lv[460][22][medusaReinforceMisc] = 11

	mat_list_by_lv[460][23][seasonCoin] = 3311
	mat_list_by_lv[460][23][medusaReinforceMisc] = 12

	mat_list_by_lv[460][24][seasonCoin] = 3673
	mat_list_by_lv[460][24][medusaReinforceMisc] = 13
	
	mat_list_by_lv[460][25][seasonCoin] = 4036
	mat_list_by_lv[460][25][medusaReinforceMisc] = 14

	mat_list_by_lv[460][26][seasonCoin] = 4398
	mat_list_by_lv[460][26][medusaReinforceMisc] = 15

	mat_list_by_lv[460][27][seasonCoin] = 4760
	mat_list_by_lv[460][27][medusaReinforceMisc] = 16

	mat_list_by_lv[460][28][seasonCoin] = 5123
	mat_list_by_lv[460][28][medusaReinforceMisc] = 17

	mat_list_by_lv[460][29][seasonCoin] = 5485
	mat_list_by_lv[460][29][medusaReinforceMisc] = 18

	mat_list_by_lv[460][30][seasonCoin] = 5848
	mat_list_by_lv[460][30][medusaReinforceMisc] = 19
end

-- 480 이상 방어구 강화재료
function setting_lv_material_armor(mat_list_by_lv, lv)
	local seasonCoin = "GabijaCertificate" -- 다음 세대
	local misc_reinforce_1 = "misc_transmutationSpreader_NoTrade" -- 다음 세대 
	local misc_BlessedStone = 'misc_BlessedStone'
	local misc_reinforce_2 = 'misc_high_transmutationSpreader_NoTrade'

	-- 여기서 레벨별 재료를 세팅한다.

	if lv == 480 then
		seasonCoin = "VakarineCertificate" 
		misc_reinforce_1 = "misc_leatherFalouros_NoTrade" 
		misc_BlessedStone = 'misc_BlessedStone'
		misc_reinforce_2 = 'misc_hornFalouros_NoTrade'

		mat_list_by_lv[lv]['armor'][6][seasonCoin] = 450		
		mat_list_by_lv[lv]['armor'][6][misc_reinforce_1] = 5

		mat_list_by_lv[lv]['armor'][7][seasonCoin] = 450
		mat_list_by_lv[lv]['armor'][7][misc_reinforce_1] = 5

		mat_list_by_lv[lv]['armor'][8][seasonCoin] = 450
		mat_list_by_lv[lv]['armor'][8][misc_reinforce_1] = 5

		mat_list_by_lv[lv]['armor'][9][seasonCoin] = 450
		mat_list_by_lv[lv]['armor'][9][misc_reinforce_1] = 5

		mat_list_by_lv[lv]['armor'][10][seasonCoin] = 1200
		mat_list_by_lv[lv]['armor'][10][misc_reinforce_1] = 8

		mat_list_by_lv[lv]['armor'][11][seasonCoin] = 1200
		mat_list_by_lv[lv]['armor'][11][misc_reinforce_1] = 8

		mat_list_by_lv[lv]['armor'][12][seasonCoin] = 1200
		mat_list_by_lv[lv]['armor'][12][misc_reinforce_1] = 8

		mat_list_by_lv[lv]['armor'][13][seasonCoin] = 1200
		mat_list_by_lv[lv]['armor'][13][misc_reinforce_1] = 8

		mat_list_by_lv[lv]['armor'][14][seasonCoin] = 1200
		mat_list_by_lv[lv]['armor'][14][misc_reinforce_1] = 8

		mat_list_by_lv[lv]['armor'][15][seasonCoin] = 1200
		mat_list_by_lv[lv]['armor'][15][misc_reinforce_1] = 8

		mat_list_by_lv[lv]['armor'][16][seasonCoin] = 1200
		mat_list_by_lv[lv]['armor'][16][misc_reinforce_1] = 8

		mat_list_by_lv[lv]['armor'][17][seasonCoin] = 1200
		mat_list_by_lv[lv]['armor'][17][misc_reinforce_1] = 8

		mat_list_by_lv[lv]['armor'][18][seasonCoin] = 1523
		mat_list_by_lv[lv]['armor'][18][misc_reinforce_1] = 8

		mat_list_by_lv[lv]['armor'][19][seasonCoin] = 1861
		mat_list_by_lv[lv]['armor'][19][misc_reinforce_1] = 8

		mat_list_by_lv[lv]['armor'][20][seasonCoin] = 2224
		mat_list_by_lv[lv]['armor'][20][misc_reinforce_1] = 8

		mat_list_by_lv[lv]['armor'][21][seasonCoin] = 2586
		mat_list_by_lv[lv]['armor'][21][misc_reinforce_1] = 10

		mat_list_by_lv[lv]['armor'][22][seasonCoin] = 2948		
		mat_list_by_lv[lv]['armor'][22][misc_reinforce_1] = 15
		mat_list_by_lv[lv]['armor'][22][misc_reinforce_2] = 10
	
		mat_list_by_lv[lv]['armor'][23][seasonCoin] = 3311
		mat_list_by_lv[lv]['armor'][23][misc_reinforce_1] = 17
		mat_list_by_lv[lv]['armor'][23][misc_reinforce_2] = 11
	
		mat_list_by_lv[lv]['armor'][24][seasonCoin] = 3673
		mat_list_by_lv[lv]['armor'][24][misc_reinforce_1] = 19
		mat_list_by_lv[lv]['armor'][24][misc_reinforce_2] = 11
	
		mat_list_by_lv[lv]['armor'][25][seasonCoin] = 4036
		mat_list_by_lv[lv]['armor'][25][misc_reinforce_1] = 20
		mat_list_by_lv[lv]['armor'][25][misc_reinforce_2] = 12
	
		mat_list_by_lv[lv]['armor'][26][seasonCoin] = 4398
		mat_list_by_lv[lv]['armor'][26][misc_reinforce_1] = 20
		mat_list_by_lv[lv]['armor'][26][misc_reinforce_2] = 12
	
		mat_list_by_lv[lv]['armor'][27][seasonCoin] = 4760
		mat_list_by_lv[lv]['armor'][27][misc_reinforce_1] = 20
		mat_list_by_lv[lv]['armor'][27][misc_reinforce_2] = 13
	
		mat_list_by_lv[lv]['armor'][28][seasonCoin] = 5123
		mat_list_by_lv[lv]['armor'][28][misc_reinforce_1] = 20
		mat_list_by_lv[lv]['armor'][28][misc_reinforce_2] = 13
	
		mat_list_by_lv[lv]['armor'][29][seasonCoin] = 5485
		mat_list_by_lv[lv]['armor'][29][misc_reinforce_1] = 20
		mat_list_by_lv[lv]['armor'][29][misc_reinforce_2] = 14
	
		mat_list_by_lv[lv]['armor'][30][seasonCoin] = 5848
		mat_list_by_lv[lv]['armor'][30][misc_reinforce_1] = 20
		mat_list_by_lv[lv]['armor'][30][misc_reinforce_2] = 14
	elseif lv >= 500 then
		if lv == 500 then
			seasonCoin = "RadaCertificate" 
			misc_reinforce_1 = "misc_upinis_wing_NoTrade" 
			misc_BlessedStone = 'misc_BlessedStone_1'
		elseif lv == 520 then
			seasonCoin = "JurateCertificate" 
			misc_reinforce_1 = "misc_boss_CrystalGolem_NoTrade" 
			misc_BlessedStone = 'misc_BlessedStone_1'
		elseif lv == 540 then
			seasonCoin = "AustejaCertificate" 
			misc_reinforce_1 = "misc_boss_202509_armor_NoTrade" 
			misc_BlessedStone = 'misc_BlessedStone_2'
		end

		mat_list_by_lv[lv]['armor'][6][seasonCoin] = 450
		mat_list_by_lv[lv]['armor'][6][misc_BlessedStone] = 2
		mat_list_by_lv[lv]['armor'][6][misc_reinforce_1] = 5

		mat_list_by_lv[lv]['armor'][7][seasonCoin] = 450
		mat_list_by_lv[lv]['armor'][7][misc_BlessedStone] = 2
		mat_list_by_lv[lv]['armor'][7][misc_reinforce_1] = 5

		mat_list_by_lv[lv]['armor'][8][seasonCoin] = 450
		mat_list_by_lv[lv]['armor'][8][misc_BlessedStone] = 2
		mat_list_by_lv[lv]['armor'][8][misc_reinforce_1] = 5

		mat_list_by_lv[lv]['armor'][9][seasonCoin] = 450
		mat_list_by_lv[lv]['armor'][9][misc_BlessedStone] = 2
		mat_list_by_lv[lv]['armor'][9][misc_reinforce_1] = 5

		mat_list_by_lv[lv]['armor'][10][seasonCoin] = 1200
		mat_list_by_lv[lv]['armor'][10][misc_BlessedStone] = 4
		mat_list_by_lv[lv]['armor'][10][misc_reinforce_1] = 8

		mat_list_by_lv[lv]['armor'][11][seasonCoin] = 1200
		mat_list_by_lv[lv]['armor'][11][misc_BlessedStone] = 4
		mat_list_by_lv[lv]['armor'][11][misc_reinforce_1] = 8

		mat_list_by_lv[lv]['armor'][12][seasonCoin] = 1200
		mat_list_by_lv[lv]['armor'][12][misc_BlessedStone] = 4
		mat_list_by_lv[lv]['armor'][12][misc_reinforce_1] = 8

		mat_list_by_lv[lv]['armor'][13][seasonCoin] = 1200
		mat_list_by_lv[lv]['armor'][13][misc_BlessedStone] = 4
		mat_list_by_lv[lv]['armor'][13][misc_reinforce_1] = 8

		mat_list_by_lv[lv]['armor'][14][seasonCoin] = 1200
		mat_list_by_lv[lv]['armor'][14][misc_BlessedStone] = 4
		mat_list_by_lv[lv]['armor'][14][misc_reinforce_1] = 8

		mat_list_by_lv[lv]['armor'][15][seasonCoin] = 1200
		mat_list_by_lv[lv]['armor'][15][misc_BlessedStone] = 4
		mat_list_by_lv[lv]['armor'][15][misc_reinforce_1] = 8

		mat_list_by_lv[lv]['armor'][16][seasonCoin] = 1200
		mat_list_by_lv[lv]['armor'][16][misc_BlessedStone] = 4
		mat_list_by_lv[lv]['armor'][16][misc_reinforce_1] = 8

		mat_list_by_lv[lv]['armor'][17][seasonCoin] = 1200
		mat_list_by_lv[lv]['armor'][17][misc_BlessedStone] = 4
		mat_list_by_lv[lv]['armor'][17][misc_reinforce_1] = 8

		mat_list_by_lv[lv]['armor'][18][seasonCoin] = 1523
		mat_list_by_lv[lv]['armor'][18][misc_BlessedStone] = 4
		mat_list_by_lv[lv]['armor'][18][misc_reinforce_1] = 8

		mat_list_by_lv[lv]['armor'][19][seasonCoin] = 1861
		mat_list_by_lv[lv]['armor'][19][misc_BlessedStone] = 4
		mat_list_by_lv[lv]['armor'][19][misc_reinforce_1] = 8

		mat_list_by_lv[lv]['armor'][20][seasonCoin] = 2224
		mat_list_by_lv[lv]['armor'][20][misc_BlessedStone] = 4
		mat_list_by_lv[lv]['armor'][20][misc_reinforce_1] = 8

		mat_list_by_lv[lv]['armor'][21][seasonCoin] = 2586
		mat_list_by_lv[lv]['armor'][21][misc_BlessedStone] = 4
		mat_list_by_lv[lv]['armor'][21][misc_reinforce_1] = 10

		mat_list_by_lv[lv]['armor'][22][seasonCoin] = 2948
		mat_list_by_lv[lv]['armor'][22][misc_BlessedStone] = 4
		mat_list_by_lv[lv]['armor'][22][misc_reinforce_1] = 15 + 5
	
		mat_list_by_lv[lv]['armor'][23][seasonCoin] = 3311
		mat_list_by_lv[lv]['armor'][23][misc_BlessedStone] = 4
		mat_list_by_lv[lv]['armor'][23][misc_reinforce_1] = 17 + 5
	
		mat_list_by_lv[lv]['armor'][24][seasonCoin] = 3673
		mat_list_by_lv[lv]['armor'][24][misc_BlessedStone] = 4
		mat_list_by_lv[lv]['armor'][24][misc_reinforce_1] = 19 + 5
	
		mat_list_by_lv[lv]['armor'][25][seasonCoin] = 4036
		mat_list_by_lv[lv]['armor'][25][misc_BlessedStone] = 4
		mat_list_by_lv[lv]['armor'][25][misc_reinforce_1] = 20 + 5
	
		mat_list_by_lv[lv]['armor'][26][seasonCoin] = 4398
		mat_list_by_lv[lv]['armor'][26][misc_BlessedStone] = 4
		mat_list_by_lv[lv]['armor'][26][misc_reinforce_1] = 20 + 5
	
		mat_list_by_lv[lv]['armor'][27][seasonCoin] = 4760
		mat_list_by_lv[lv]['armor'][27][misc_BlessedStone] = 4
		mat_list_by_lv[lv]['armor'][27][misc_reinforce_1] = 20 + 5
	
		mat_list_by_lv[lv]['armor'][28][seasonCoin] = 5123
		mat_list_by_lv[lv]['armor'][28][misc_BlessedStone] = 4
		mat_list_by_lv[lv]['armor'][28][misc_reinforce_1] = 20 + 5
	
		mat_list_by_lv[lv]['armor'][29][seasonCoin] = 5485
		mat_list_by_lv[lv]['armor'][29][misc_BlessedStone] = 4
		mat_list_by_lv[lv]['armor'][29][misc_reinforce_1] = 20 + 5
	
		mat_list_by_lv[lv]['armor'][30][seasonCoin] = 5848
		mat_list_by_lv[lv]['armor'][30][misc_BlessedStone] = 4
		mat_list_by_lv[lv]['armor'][30][misc_reinforce_1] = 20 + 5
	end

	mat_list_by_lv[lv]['armor'][1][seasonCoin] = 263
	mat_list_by_lv[lv]['armor'][1][misc_reinforce_1] = 3

	mat_list_by_lv[lv]['armor'][2][seasonCoin] = 263
	mat_list_by_lv[lv]['armor'][2][misc_reinforce_1] = 3

	mat_list_by_lv[lv]['armor'][3][seasonCoin] = 263
	mat_list_by_lv[lv]['armor'][3][misc_reinforce_1] = 3
	
	mat_list_by_lv[lv]['armor'][4][seasonCoin] = 263
	mat_list_by_lv[lv]['armor'][4][misc_reinforce_1] = 3

	mat_list_by_lv[lv]['armor'][5][seasonCoin] = 450
	mat_list_by_lv[lv]['armor'][5][misc_reinforce_1] = 3	

	setting_lv_misc_material(mat_list_by_lv, lv, 'armor')
end

-- 480 이상 무기 강화 재료
function setting_lv_material_weapon(mat_list_by_lv, lv)
	local seasonCoin = "GabijaCertificate" -- 다음 세대
	local misc_reinforce_1 = "misc_transmutationSpreader_NoTrade" -- 다음 세대 
	local misc_BlessedStone = 'misc_BlessedStone'
	local misc_reinforce_2 = 'misc_high_transmutationSpreader_NoTrade'
	-- 여기서 레벨별 재료를 세팅한다.
	
	if lv == 480 then
		seasonCoin = "VakarineCertificate" -- 다음 세대
		misc_reinforce_1 = "misc_transmutationSpreader_NoTrade" -- 다음 세대 
		misc_BlessedStone = 'misc_BlessedStone'
		misc_reinforce_2 = 'misc_high_transmutationSpreader_NoTrade'

		mat_list_by_lv[lv]['weapon'][6][seasonCoin] = 450
		mat_list_by_lv[lv]['weapon'][6][misc_reinforce_1] = 5

		mat_list_by_lv[lv]['weapon'][7][seasonCoin] = 450
		mat_list_by_lv[lv]['weapon'][7][misc_reinforce_1] = 5

		mat_list_by_lv[lv]['weapon'][8][seasonCoin] = 450
		mat_list_by_lv[lv]['weapon'][8][misc_reinforce_1] = 5

		mat_list_by_lv[lv]['weapon'][9][seasonCoin] = 450
		mat_list_by_lv[lv]['weapon'][9][misc_reinforce_1] = 5

		mat_list_by_lv[lv]['weapon'][10][seasonCoin] = 1200
		mat_list_by_lv[lv]['weapon'][10][misc_reinforce_1] = 8

		mat_list_by_lv[lv]['weapon'][11][seasonCoin] = 1200
		mat_list_by_lv[lv]['weapon'][11][misc_reinforce_1] = 8

		mat_list_by_lv[lv]['weapon'][12][seasonCoin] = 1200
		mat_list_by_lv[lv]['weapon'][12][misc_reinforce_1] = 8

		mat_list_by_lv[lv]['weapon'][13][seasonCoin] = 1200
		mat_list_by_lv[lv]['weapon'][13][misc_reinforce_1] = 8

		mat_list_by_lv[lv]['weapon'][14][seasonCoin] = 1200
		mat_list_by_lv[lv]['weapon'][14][misc_reinforce_1] = 8

		mat_list_by_lv[lv]['weapon'][15][seasonCoin] = 1200
		mat_list_by_lv[lv]['weapon'][15][misc_reinforce_1] = 8

		mat_list_by_lv[lv]['weapon'][16][seasonCoin] = 1200
		mat_list_by_lv[lv]['weapon'][16][misc_reinforce_1] = 8

		mat_list_by_lv[lv]['weapon'][17][seasonCoin] = 1200
		mat_list_by_lv[lv]['weapon'][17][misc_reinforce_1] = 8

		mat_list_by_lv[lv]['weapon'][18][seasonCoin] = 1523
		mat_list_by_lv[lv]['weapon'][18][misc_reinforce_1] = 8

		mat_list_by_lv[lv]['weapon'][19][seasonCoin] = 1861
		mat_list_by_lv[lv]['weapon'][19][misc_reinforce_1] = 8

		mat_list_by_lv[lv]['weapon'][20][seasonCoin] = 2224
		mat_list_by_lv[lv]['weapon'][20][misc_reinforce_1] = 8

		mat_list_by_lv[lv]['weapon'][21][seasonCoin] = 2586
		mat_list_by_lv[lv]['weapon'][21][misc_reinforce_1] = 10

		mat_list_by_lv[lv]['weapon'][22][seasonCoin] = 2948
		mat_list_by_lv[lv]['weapon'][22][misc_reinforce_1] = 15
		mat_list_by_lv[lv]['weapon'][22][misc_reinforce_2] = 10

		mat_list_by_lv[lv]['weapon'][23][seasonCoin] = 3311
		mat_list_by_lv[lv]['weapon'][23][misc_reinforce_1] = 17
		mat_list_by_lv[lv]['weapon'][23][misc_reinforce_2] = 11

		mat_list_by_lv[lv]['weapon'][24][seasonCoin] = 3673
		mat_list_by_lv[lv]['weapon'][24][misc_reinforce_1] = 19
		mat_list_by_lv[lv]['weapon'][24][misc_reinforce_2] = 11

		mat_list_by_lv[lv]['weapon'][25][seasonCoin] = 4036
		mat_list_by_lv[lv]['weapon'][25][misc_reinforce_1] = 20
		mat_list_by_lv[lv]['weapon'][25][misc_reinforce_2] = 12

		mat_list_by_lv[lv]['weapon'][26][seasonCoin] = 4398
		mat_list_by_lv[lv]['weapon'][26][misc_reinforce_1] = 20
		mat_list_by_lv[lv]['weapon'][26][misc_reinforce_2] = 12

		mat_list_by_lv[lv]['weapon'][27][seasonCoin] = 4760
		mat_list_by_lv[lv]['weapon'][27][misc_reinforce_1] = 20
		mat_list_by_lv[lv]['weapon'][27][misc_reinforce_2] = 13

		mat_list_by_lv[lv]['weapon'][28][seasonCoin] = 5123
		mat_list_by_lv[lv]['weapon'][28][misc_reinforce_1] = 20
		mat_list_by_lv[lv]['weapon'][28][misc_reinforce_2] = 13

		mat_list_by_lv[lv]['weapon'][29][seasonCoin] = 5485
		mat_list_by_lv[lv]['weapon'][29][misc_reinforce_1] = 20
		mat_list_by_lv[lv]['weapon'][29][misc_reinforce_2] = 14

		mat_list_by_lv[lv]['weapon'][30][seasonCoin] = 5848
		mat_list_by_lv[lv]['weapon'][30][misc_reinforce_1] = 20
		mat_list_by_lv[lv]['weapon'][30][misc_reinforce_2] = 14
	elseif lv >= 500 then
		if lv == 500 then
			seasonCoin = "RadaCertificate" -- 다음 세대
			misc_reinforce_1 = "misc_slogutis_fragments_NoTrade" -- 다음 세대 
			misc_BlessedStone = 'misc_BlessedStone_1'
		elseif lv == 520 then
			seasonCoin = "JurateCertificate" 
			misc_reinforce_1 = "misc_boss_DarkNeringa_NoTrade"
			misc_BlessedStone = 'misc_BlessedStone_1'
		elseif lv == 540 then
			seasonCoin = "AustejaCertificate" -- 다음 세대
			misc_reinforce_1 = "misc_boss_202509_weapon_NoTrade" -- 다음 세대 
			misc_BlessedStone = 'misc_BlessedStone_2'
		end

		mat_list_by_lv[lv]['weapon'][6][seasonCoin] = 450
		mat_list_by_lv[lv]['weapon'][6][misc_BlessedStone] = 2
		mat_list_by_lv[lv]['weapon'][6][misc_reinforce_1] = 5

		mat_list_by_lv[lv]['weapon'][7][seasonCoin] = 450
		mat_list_by_lv[lv]['weapon'][7][misc_BlessedStone] = 2
		mat_list_by_lv[lv]['weapon'][7][misc_reinforce_1] = 5

		mat_list_by_lv[lv]['weapon'][8][seasonCoin] = 450
		mat_list_by_lv[lv]['weapon'][8][misc_BlessedStone] = 2
		mat_list_by_lv[lv]['weapon'][8][misc_reinforce_1] = 5

		mat_list_by_lv[lv]['weapon'][9][seasonCoin] = 450
		mat_list_by_lv[lv]['weapon'][9][misc_BlessedStone] = 2
		mat_list_by_lv[lv]['weapon'][9][misc_reinforce_1] = 5

		mat_list_by_lv[lv]['weapon'][10][seasonCoin] = 1200
		mat_list_by_lv[lv]['weapon'][10][misc_BlessedStone] = 4
		mat_list_by_lv[lv]['weapon'][10][misc_reinforce_1] = 8

		mat_list_by_lv[lv]['weapon'][11][seasonCoin] = 1200
		mat_list_by_lv[lv]['weapon'][11][misc_BlessedStone] = 4
		mat_list_by_lv[lv]['weapon'][11][misc_reinforce_1] = 8

		mat_list_by_lv[lv]['weapon'][12][seasonCoin] = 1200
		mat_list_by_lv[lv]['weapon'][12][misc_BlessedStone] = 4
		mat_list_by_lv[lv]['weapon'][12][misc_reinforce_1] = 8

		mat_list_by_lv[lv]['weapon'][13][seasonCoin] = 1200
		mat_list_by_lv[lv]['weapon'][13][misc_BlessedStone] = 4
		mat_list_by_lv[lv]['weapon'][13][misc_reinforce_1] = 8

		mat_list_by_lv[lv]['weapon'][14][seasonCoin] = 1200
		mat_list_by_lv[lv]['weapon'][14][misc_BlessedStone] = 4
		mat_list_by_lv[lv]['weapon'][14][misc_reinforce_1] = 8

		mat_list_by_lv[lv]['weapon'][15][seasonCoin] = 1200
		mat_list_by_lv[lv]['weapon'][15][misc_BlessedStone] = 4
		mat_list_by_lv[lv]['weapon'][15][misc_reinforce_1] = 8

		mat_list_by_lv[lv]['weapon'][16][seasonCoin] = 1200
		mat_list_by_lv[lv]['weapon'][16][misc_BlessedStone] = 4
		mat_list_by_lv[lv]['weapon'][16][misc_reinforce_1] = 8

		mat_list_by_lv[lv]['weapon'][17][seasonCoin] = 1200
		mat_list_by_lv[lv]['weapon'][17][misc_BlessedStone] = 4
		mat_list_by_lv[lv]['weapon'][17][misc_reinforce_1] = 8

		mat_list_by_lv[lv]['weapon'][18][seasonCoin] = 1523
		mat_list_by_lv[lv]['weapon'][18][misc_BlessedStone] = 4
		mat_list_by_lv[lv]['weapon'][18][misc_reinforce_1] = 8

		mat_list_by_lv[lv]['weapon'][19][seasonCoin] = 1861
		mat_list_by_lv[lv]['weapon'][19][misc_BlessedStone] = 4
		mat_list_by_lv[lv]['weapon'][19][misc_reinforce_1] = 8

		mat_list_by_lv[lv]['weapon'][20][seasonCoin] = 2224
		mat_list_by_lv[lv]['weapon'][20][misc_BlessedStone] = 4
		mat_list_by_lv[lv]['weapon'][20][misc_reinforce_1] = 8

		mat_list_by_lv[lv]['weapon'][21][seasonCoin] = 2586
		mat_list_by_lv[lv]['weapon'][21][misc_BlessedStone] = 4
		mat_list_by_lv[lv]['weapon'][21][misc_reinforce_1] = 10

		mat_list_by_lv[lv]['weapon'][22][seasonCoin] = 2948
		mat_list_by_lv[lv]['weapon'][22][misc_BlessedStone] = 4
		mat_list_by_lv[lv]['weapon'][22][misc_reinforce_1] = 15 + 5

		mat_list_by_lv[lv]['weapon'][23][seasonCoin] = 3311
		mat_list_by_lv[lv]['weapon'][23][misc_BlessedStone] = 4
		mat_list_by_lv[lv]['weapon'][23][misc_reinforce_1] = 17 + 5

		mat_list_by_lv[lv]['weapon'][24][seasonCoin] = 3673
		mat_list_by_lv[lv]['weapon'][24][misc_BlessedStone] = 4
		mat_list_by_lv[lv]['weapon'][24][misc_reinforce_1] = 19 + 5

		mat_list_by_lv[lv]['weapon'][25][seasonCoin] = 4036
		mat_list_by_lv[lv]['weapon'][25][misc_BlessedStone] = 4
		mat_list_by_lv[lv]['weapon'][25][misc_reinforce_1] = 20 + 5

		mat_list_by_lv[lv]['weapon'][26][seasonCoin] = 4398
		mat_list_by_lv[lv]['weapon'][26][misc_BlessedStone] = 4
		mat_list_by_lv[lv]['weapon'][26][misc_reinforce_1] = 20 + 5

		mat_list_by_lv[lv]['weapon'][27][seasonCoin] = 4760
		mat_list_by_lv[lv]['weapon'][27][misc_BlessedStone] = 4
		mat_list_by_lv[lv]['weapon'][27][misc_reinforce_1] = 20 + 5

		mat_list_by_lv[lv]['weapon'][28][seasonCoin] = 5123
		mat_list_by_lv[lv]['weapon'][28][misc_BlessedStone] = 4
		mat_list_by_lv[lv]['weapon'][28][misc_reinforce_1] = 20 + 5

		mat_list_by_lv[lv]['weapon'][29][seasonCoin] = 5485
		mat_list_by_lv[lv]['weapon'][29][misc_BlessedStone] = 4
		mat_list_by_lv[lv]['weapon'][29][misc_reinforce_1] = 20 + 5

		mat_list_by_lv[lv]['weapon'][30][seasonCoin] = 5848
		mat_list_by_lv[lv]['weapon'][30][misc_BlessedStone] = 4
		mat_list_by_lv[lv]['weapon'][30][misc_reinforce_1] = 20 + 5
	end	

	-- 강화 확률 item_goddess_reinforce_480.xml
	mat_list_by_lv[lv]['weapon'][1][seasonCoin] = 263
	mat_list_by_lv[lv]['weapon'][1][misc_reinforce_1] = 3

	mat_list_by_lv[lv]['weapon'][2][seasonCoin] = 263
	mat_list_by_lv[lv]['weapon'][2][misc_reinforce_1] = 3

	mat_list_by_lv[lv]['weapon'][3][seasonCoin] = 263
	mat_list_by_lv[lv]['weapon'][3][misc_reinforce_1] = 3
	
	mat_list_by_lv[lv]['weapon'][4][seasonCoin] = 263
	mat_list_by_lv[lv]['weapon'][4][misc_reinforce_1] = 3

	mat_list_by_lv[lv]['weapon'][5][seasonCoin] = 450
	mat_list_by_lv[lv]['weapon'][5][misc_reinforce_1] = 3

	setting_lv_misc_material(mat_list_by_lv, lv, 'weapon')
end

-- 공용 악세 강화재료
function setting_lv_material_acc(mat_list_by_lv, lv)
	local seasonCoin = "GabijaCertificate" -- 주화
	local medusaReinforceMisc = "misc_RevivalPaulius_NoTrade" -- 레이드 재료
	local misc_BlessedStone = 'misc_BlessedStone'

	if lv == 470 then
		seasonCoin = "GabijaCertificate" -- 주화
		medusaReinforceMisc = "misc_RevivalPaulius_NoTrade" -- 레이드 재료
		misc_BlessedStone = 'None'
	elseif lv == 490 then
		seasonCoin = "VakarineCertificate" -- 주화
		medusaReinforceMisc = "misc_ribbonRoze_NoTrade" -- 레이드 재료
		misc_BlessedStone = 'None'
	elseif lv == 510 then
		seasonCoin = "RadaCertificate" -- 주화
		medusaReinforceMisc = "misc_merregina_blackpearl_NoTrade" -- 레이드 재료
		misc_BlessedStone = 'misc_BlessedStone_1'
	elseif lv == 530 then
		seasonCoin = "JurateCertificate" -- 주화
		medusaReinforceMisc = "misc_ep17_acc_NoTrade" -- 레이드 재료
		misc_BlessedStone = 'misc_BlessedStone_1'
	end

	-- 여기서 레벨별 재료를 세팅한다.	
	mat_list_by_lv[lv]['acc'][1][seasonCoin] = 263	
	mat_list_by_lv[lv]['acc'][1][medusaReinforceMisc] = 3

	mat_list_by_lv[lv]['acc'][2][seasonCoin] = 263
	mat_list_by_lv[lv]['acc'][2][medusaReinforceMisc] = 3

	mat_list_by_lv[lv]['acc'][3][seasonCoin] = 263
	mat_list_by_lv[lv]['acc'][3][medusaReinforceMisc] = 3

	mat_list_by_lv[lv]['acc'][4][seasonCoin] = 263
	mat_list_by_lv[lv]['acc'][4][medusaReinforceMisc] = 3

	mat_list_by_lv[lv]['acc'][5][seasonCoin] = 450
	mat_list_by_lv[lv]['acc'][5][medusaReinforceMisc] = 3

	mat_list_by_lv[lv]['acc'][6][seasonCoin] = 450
	mat_list_by_lv[lv]['acc'][6][misc_BlessedStone] = 1
	mat_list_by_lv[lv]['acc'][6][medusaReinforceMisc] = 5

	mat_list_by_lv[lv]['acc'][7][seasonCoin] = 450
	mat_list_by_lv[lv]['acc'][7][misc_BlessedStone] = 1
	mat_list_by_lv[lv]['acc'][7][medusaReinforceMisc] = 5

	mat_list_by_lv[lv]['acc'][8][seasonCoin] = 450
	mat_list_by_lv[lv]['acc'][8][misc_BlessedStone] = 1
	mat_list_by_lv[lv]['acc'][8][medusaReinforceMisc] = 5

	mat_list_by_lv[lv]['acc'][9][seasonCoin] = 450
	mat_list_by_lv[lv]['acc'][9][misc_BlessedStone] = 1
	mat_list_by_lv[lv]['acc'][9][medusaReinforceMisc] = 5

	mat_list_by_lv[lv]['acc'][10][seasonCoin] = 673
	mat_list_by_lv[lv]['acc'][10][misc_BlessedStone] = 1
	mat_list_by_lv[lv]['acc'][10][medusaReinforceMisc] = 5

	mat_list_by_lv[lv]['acc'][11][seasonCoin] = 673
	mat_list_by_lv[lv]['acc'][11][misc_BlessedStone] = 1
	mat_list_by_lv[lv]['acc'][11][medusaReinforceMisc] = 7

	mat_list_by_lv[lv]['acc'][12][seasonCoin] = 673
	mat_list_by_lv[lv]['acc'][12][misc_BlessedStone] = 1
	mat_list_by_lv[lv]['acc'][12][medusaReinforceMisc] = 7

	mat_list_by_lv[lv]['acc'][13][seasonCoin] = 673
	mat_list_by_lv[lv]['acc'][13][misc_BlessedStone] = 1
	mat_list_by_lv[lv]['acc'][13][medusaReinforceMisc] = 7

	mat_list_by_lv[lv]['acc'][14][seasonCoin] = 673
	mat_list_by_lv[lv]['acc'][14][misc_BlessedStone] = 1
	mat_list_by_lv[lv]['acc'][14][medusaReinforceMisc] = 7

	-- 이시다비, 바우드 악세 15강 이후부터 축복받은 조각 2개 -> 1개로 변경.
	local misc_blessed_stone_count = 2;
	if lv == 470 or lv == 490 then
		misc_blessed_stone_count = 1;
	end

	mat_list_by_lv[lv]['acc'][15][seasonCoin] = 927
	mat_list_by_lv[lv]['acc'][15][misc_BlessedStone] = misc_blessed_stone_count
	mat_list_by_lv[lv]['acc'][15][medusaReinforceMisc] = 7

	mat_list_by_lv[lv]['acc'][16][seasonCoin] = 927
	mat_list_by_lv[lv]['acc'][16][misc_BlessedStone] = misc_blessed_stone_count
	mat_list_by_lv[lv]['acc'][16][medusaReinforceMisc] = 8

	mat_list_by_lv[lv]['acc'][17][seasonCoin] = 1212
	mat_list_by_lv[lv]['acc'][17][misc_BlessedStone] = misc_blessed_stone_count
	mat_list_by_lv[lv]['acc'][17][medusaReinforceMisc] = 8

	mat_list_by_lv[lv]['acc'][18][seasonCoin] = 1523
	mat_list_by_lv[lv]['acc'][18][misc_BlessedStone] = misc_blessed_stone_count
	mat_list_by_lv[lv]['acc'][18][medusaReinforceMisc] = 8

	mat_list_by_lv[lv]['acc'][19][seasonCoin] = 1861
	mat_list_by_lv[lv]['acc'][19][misc_BlessedStone] = misc_blessed_stone_count
	mat_list_by_lv[lv]['acc'][19][medusaReinforceMisc] = 8

	mat_list_by_lv[lv]['acc'][20][seasonCoin] = 2224
	mat_list_by_lv[lv]['acc'][20][misc_BlessedStone] = misc_blessed_stone_count
	mat_list_by_lv[lv]['acc'][20][medusaReinforceMisc] = 8

	mat_list_by_lv[lv]['acc'][21][seasonCoin] = 2586
	mat_list_by_lv[lv]['acc'][21][misc_BlessedStone] = misc_blessed_stone_count
	mat_list_by_lv[lv]['acc'][21][medusaReinforceMisc] = 10

	mat_list_by_lv[lv]['acc'][22][seasonCoin] = 2948
	mat_list_by_lv[lv]['acc'][22][misc_BlessedStone] = misc_blessed_stone_count
	mat_list_by_lv[lv]['acc'][22][medusaReinforceMisc] = 11

	mat_list_by_lv[lv]['acc'][23][seasonCoin] = 3311
	mat_list_by_lv[lv]['acc'][23][misc_BlessedStone] = misc_blessed_stone_count
	mat_list_by_lv[lv]['acc'][23][medusaReinforceMisc] = 12

	mat_list_by_lv[lv]['acc'][24][seasonCoin] = 3673
	mat_list_by_lv[lv]['acc'][24][misc_BlessedStone] = misc_blessed_stone_count
	mat_list_by_lv[lv]['acc'][24][medusaReinforceMisc] = 13

	mat_list_by_lv[lv]['acc'][25][seasonCoin] = 4036
	mat_list_by_lv[lv]['acc'][25][misc_BlessedStone] = misc_blessed_stone_count
	mat_list_by_lv[lv]['acc'][25][medusaReinforceMisc] = 14

	mat_list_by_lv[lv]['acc'][26][seasonCoin] = 4398
	mat_list_by_lv[lv]['acc'][26][misc_BlessedStone] = misc_blessed_stone_count
	mat_list_by_lv[lv]['acc'][26][medusaReinforceMisc] = 15

	mat_list_by_lv[lv]['acc'][27][seasonCoin] = 4760
	mat_list_by_lv[lv]['acc'][27][misc_BlessedStone] = misc_blessed_stone_count
	mat_list_by_lv[lv]['acc'][27][medusaReinforceMisc] = 16

	mat_list_by_lv[lv]['acc'][28][seasonCoin] = 5123
	mat_list_by_lv[lv]['acc'][28][misc_BlessedStone] = misc_blessed_stone_count
	mat_list_by_lv[lv]['acc'][28][medusaReinforceMisc] = 17

	mat_list_by_lv[lv]['acc'][29][seasonCoin] = 5485
	mat_list_by_lv[lv]['acc'][29][misc_BlessedStone] = misc_blessed_stone_count
	mat_list_by_lv[lv]['acc'][29][medusaReinforceMisc] = 18

	mat_list_by_lv[lv]['acc'][30][seasonCoin] = 5848
	mat_list_by_lv[lv]['acc'][30][misc_BlessedStone] = misc_blessed_stone_count
	mat_list_by_lv[lv]['acc'][30][medusaReinforceMisc] = 19

	setting_lv_misc_material(mat_list_by_lv, lv, 'acc')
end

-- 기타 소재 세팅
function setting_lv_misc_material(mat_list_by_lv, lv, group)
	if lv < 480 then
		return
	end

	local misc1 = "misc_ore22" -- 다음 세대
	local misc2 = "misc_ore23" -- 다음 세대 	
	-- 여기서 레벨별 재료를 세팅한다.

	if lv == 480 then
		misc1 = "misc_ore22" 
		misc2 = "misc_ore23" 

		mat_list_by_lv[lv][group][1][misc1] = 26
		mat_list_by_lv[lv][group][1][misc2] = 6

		mat_list_by_lv[lv][group][2][misc1] = 26
		mat_list_by_lv[lv][group][2][misc2] = 6

		mat_list_by_lv[lv][group][3][misc1] = 26
		mat_list_by_lv[lv][group][3][misc2] = 6
		
		mat_list_by_lv[lv][group][4][misc1] = 26
		mat_list_by_lv[lv][group][4][misc2] = 6

		mat_list_by_lv[lv][group][5][misc1] = 45
		mat_list_by_lv[lv][group][5][misc2] = 11

		mat_list_by_lv[lv][group][6][misc1] = 45
		mat_list_by_lv[lv][group][6][misc2] = 11

		mat_list_by_lv[lv][group][7][misc1] = 45
		mat_list_by_lv[lv][group][7][misc2] = 11

		mat_list_by_lv[lv][group][8][misc1] = 45
		mat_list_by_lv[lv][group][8][misc2] = 11

		mat_list_by_lv[lv][group][9][misc1] = 45
		mat_list_by_lv[lv][group][9][misc2] = 11

		mat_list_by_lv[lv][group][10][misc1] = 67
		mat_list_by_lv[lv][group][10][misc2] = 16

		mat_list_by_lv[lv][group][11][misc1] = 67
		mat_list_by_lv[lv][group][11][misc2] = 16

		mat_list_by_lv[lv][group][12][misc1] = 67
		mat_list_by_lv[lv][group][12][misc2] = 16

		mat_list_by_lv[lv][group][13][misc1] = 67
		mat_list_by_lv[lv][group][13][misc2] = 16

		mat_list_by_lv[lv][group][14][misc1] = 67
		mat_list_by_lv[lv][group][14][misc2] = 16

		mat_list_by_lv[lv][group][15][misc1] = 92
		mat_list_by_lv[lv][group][15][misc2] = 23

		mat_list_by_lv[lv][group][16][misc1] = 92
		mat_list_by_lv[lv][group][16][misc2] = 23

		mat_list_by_lv[lv][group][17][misc1] = 121
		mat_list_by_lv[lv][group][17][misc2] = 30

		mat_list_by_lv[lv][group][18][misc1] = 152
		mat_list_by_lv[lv][group][18][misc2] = 38

		mat_list_by_lv[lv][group][19][misc1] = 186
		mat_list_by_lv[lv][group][19][misc2] = 46

		mat_list_by_lv[lv][group][20][misc1] = 222
		mat_list_by_lv[lv][group][20][misc2] = 55

		mat_list_by_lv[lv][group][21][misc1] = 258
		mat_list_by_lv[lv][group][21][misc2] = 64

		mat_list_by_lv[lv][group][22][misc1] = 387
		mat_list_by_lv[lv][group][22][misc2] = 129

		mat_list_by_lv[lv][group][23][misc1] = 464
		mat_list_by_lv[lv][group][23][misc2] = 154

		mat_list_by_lv[lv][group][24][misc1] = 464
		mat_list_by_lv[lv][group][24][misc2] = 154

		mat_list_by_lv[lv][group][25][misc1] = 510
		mat_list_by_lv[lv][group][25][misc2] = 170

		mat_list_by_lv[lv][group][26][misc1] = 510
		mat_list_by_lv[lv][group][26][misc2] = 170

		mat_list_by_lv[lv][group][27][misc1] = 561
		mat_list_by_lv[lv][group][27][misc2] = 187

		mat_list_by_lv[lv][group][28][misc1] = 561
		mat_list_by_lv[lv][group][28][misc2] = 187

		mat_list_by_lv[lv][group][29][misc1] = 617
		mat_list_by_lv[lv][group][29][misc2] = 205

		mat_list_by_lv[lv][group][30][misc1] = 617
		mat_list_by_lv[lv][group][30][misc2] = 205
	elseif lv >= 500 then
		if lv == 500 then
			misc1 = "misc_ore28" 
		elseif lv == 510 then
			misc1 = "misc_ore28" 
		elseif lv == 520 then
			misc1 = "misc_ore28" 
		elseif lv == 530 then
			misc1 = "misc_ore28" 
		elseif lv == 540 then
			misc1 = "misc_ore29" 
		end

		mat_list_by_lv[lv][group][1][misc1] = 26
		mat_list_by_lv[lv][group][2][misc1] = 26
		mat_list_by_lv[lv][group][3][misc1] = 26
		mat_list_by_lv[lv][group][4][misc1] = 26
		mat_list_by_lv[lv][group][5][misc1] = 45
		mat_list_by_lv[lv][group][6][misc1] = 45
		mat_list_by_lv[lv][group][7][misc1] = 45
		mat_list_by_lv[lv][group][8][misc1] = 45
		mat_list_by_lv[lv][group][9][misc1] = 45
		mat_list_by_lv[lv][group][10][misc1] = 67
		mat_list_by_lv[lv][group][11][misc1] = 67
		mat_list_by_lv[lv][group][12][misc1] = 67
		mat_list_by_lv[lv][group][13][misc1] = 67
		mat_list_by_lv[lv][group][14][misc1] = 67
		mat_list_by_lv[lv][group][15][misc1] = 92
		mat_list_by_lv[lv][group][16][misc1] = 92
		mat_list_by_lv[lv][group][17][misc1] = 121
		mat_list_by_lv[lv][group][18][misc1] = 152
		mat_list_by_lv[lv][group][19][misc1] = 186
		mat_list_by_lv[lv][group][20][misc1] = 222
		mat_list_by_lv[lv][group][21][misc1] = 258
		mat_list_by_lv[lv][group][22][misc1] = 387
		mat_list_by_lv[lv][group][23][misc1] = 464
		mat_list_by_lv[lv][group][24][misc1] = 464
		mat_list_by_lv[lv][group][25][misc1] = 510
		mat_list_by_lv[lv][group][26][misc1] = 510
		mat_list_by_lv[lv][group][27][misc1] = 561
		mat_list_by_lv[lv][group][28][misc1] = 561
		mat_list_by_lv[lv][group][29][misc1] = 617
		mat_list_by_lv[lv][group][30][misc1] = 617
	end
end

function make_item_goddess_reinforce_material_list()
	if item_goddess_reinforce_material_list ~= nil then
		return
	end

	item_goddess_reinforce_material_list = {}
	local start_lv = 460	
	while start_lv <= equip_end_lv do
		item_goddess_reinforce_material_list[start_lv] = {} -- 차후 더 높은 레벨의 아이템이 추가될시에 추가	
		start_lv = start_lv + 10
	end
	
	local classtype_list = {}
	local group_list = {}
	table.insert(classtype_list, 'Sword')
	table.insert(classtype_list, 'THSword')
	table.insert(classtype_list, 'Staff')
	table.insert(classtype_list, 'THStaff')
	table.insert(classtype_list, 'Bow')
	table.insert(classtype_list, 'THBow')
	table.insert(classtype_list, 'Mace')
	table.insert(classtype_list, 'THMace')
	table.insert(classtype_list, 'Spear')
	table.insert(classtype_list, 'THSpear')	

	table.insert(classtype_list, 'Rapier')
	table.insert(classtype_list, 'Cannon')
	table.insert(classtype_list, 'Musket')
	table.insert(classtype_list, 'Dagger')
	table.insert(classtype_list, 'Pistol')
	table.insert(classtype_list, 'Shield')
	table.insert(classtype_list, 'Trinket')

	for _, v in pairs(classtype_list) do
		group_list[v] = 'weapon'
	end

	table.insert(classtype_list, 'Gloves')
	table.insert(classtype_list, 'Boots')
	table.insert(classtype_list, 'Pants')
	table.insert(classtype_list, 'Shirt')

	group_list['Gloves'] = 'armor'
	group_list['Boots'] = 'armor'
	group_list['Pants'] = 'armor'
	group_list['Shirt'] = 'armor'

	table.insert(classtype_list, 'Ring')
	table.insert(classtype_list, 'Neck')

	group_list['Ring'] = 'acc'
	group_list['Neck'] = 'acc'

	-- 무기 방어구
	for lv, v1 in pairs(item_goddess_reinforce_material_list) do
		for _, class_type in pairs(classtype_list) do
			item_goddess_reinforce_material_list[lv][class_type] = {}
			for i = 1, GET_MAX_REINFORCE_POINT(lv) do
				item_goddess_reinforce_material_list[lv][class_type][i] = {}
			end
		end
	end

	local mat_list_by_lv = {}
	mat_list_by_lv[460] = {}	
	for i = 1, GET_MAX_REINFORCE_POINT(460) do
		mat_list_by_lv[460][i] = {}
	end
	setting_lv460_material(mat_list_by_lv)

	-- item_goddess_reinforce_material_list[item_UseLv][classtype][goal_reinforce_lv] - {재료이름 : 개수} 반환
	for class_type, v in pairs(item_goddess_reinforce_material_list[460]) do		
		for lv, dic in pairs(v) do			
			for i = 1, GET_MAX_REINFORCE_POINT(460) do
				item_goddess_reinforce_material_list[460][class_type][i] = mat_list_by_lv[460][i]
			end
		end
	end

	-- 여기서부터 무기/방어구 - 악세 구분됨
	local start = 470
	while start <= equip_end_lv do
		mat_list_by_lv[start] = {}
		for i = 1, GET_MAX_REINFORCE_POINT(start) do		
			if mat_list_by_lv[start]['armor'] == nil then
				mat_list_by_lv[start]['armor'] = {}
				mat_list_by_lv[start]['weapon'] = {}
				mat_list_by_lv[start]['acc'] = {}			
			end		
	
			mat_list_by_lv[start]['armor'][i] = {}
			mat_list_by_lv[start]['weapon'][i] = {}
			mat_list_by_lv[start]['acc'][i] = {}
		end

		local func_name = 'setting_lv_material_armor'
		local func = _G[func_name]
		if func ~= nil then
			func(mat_list_by_lv, start)		
		end

		func_name = 'setting_lv_material_weapon'
		local func = _G[func_name]
		if func ~= nil then
			func(mat_list_by_lv, start)		
		end

		func_name = 'setting_lv_material_acc'
		func = _G[func_name]
		if func ~= nil then			
			func(mat_list_by_lv, start)		
		end
		
		if item_goddess_reinforce_material_list[start] ~= nil then
			for class_type, v in pairs(item_goddess_reinforce_material_list[start]) do
				local group = group_list[class_type]
				for lv, dic in pairs(v) do			
					for i = 1, GET_MAX_REINFORCE_POINT(start) do
						item_goddess_reinforce_material_list[start][class_type][i] = mat_list_by_lv[start][group][i]
					end
				end
			end
		end

		start = start + 10
	end
end

make_item_goddess_reinforce_material_list()

-- 해당 강화로 가는데 필요한 재료 목록을 가져온다(실버, 주화, 다 포함)
item_goddess_reinforce.get_material_list = function(use_lv, class_type, goal_lv, IsEventItem, IsPopoboostClear)
	if item_goddess_reinforce_material_list[use_lv] == nil then
		return nil
	end
	
	if item_goddess_reinforce_material_list[use_lv][class_type] == nil then
		return nil
	end
	local except_list = {'misc_BlessedStone', 'misc_BlessedStone_1', 'misc_ore22', 'misc_ore23', 'misc_ore28' }
	-- 포포 부스트 이벤트 아이템일 경우 (이벤트 기간중인 아이템) 축조, 뉴클/시에라 없이 강화 가능하게 한다.
	if IS_POPOBOOST_REINFORCE_ITEM(IsEventItem, use_lv, popoboost_item_lv, IsPopoboostClear) then
		local TempPopoboost_Material_List = {}
		for k,v in pairs(item_goddess_reinforce_material_list[use_lv][class_type][goal_lv]) do
			if table.find(except_list, k) == 0 then
				TempPopoboost_Material_List[k] = v;
			end
		end
		return TempPopoboost_Material_List;
	end

	local dic = {}
	for k,v in pairs(item_goddess_reinforce_material_list[use_lv][class_type][goal_lv]) do
		if k ~= 'None' then
			dic[k] = v
		end
	end

	return dic
end

-- 460레벨 이상, 가디스 등급만 가능
item_goddess_reinforce.is_able_to_reinforce = function(target_item)
	if target_item ~= nil and TryGetProp(target_item, 'Reinforce_Type', 'None') == 'goddess' and TryGetProp(target_item, 'ItemGrade', 0) == 6 then
		if TryGetProp(target_item, 'UseLv', 0) >= 460  then
			return 'YES'
		elseif item_goddess_growth.is_goddess_growth_item(target_item) == true then
			return 'YES'
		end
	end

	return 'WebService_38'
end
--- end of 재료 관련 ------------------------------------------------------------

-- 인챈트 --
-- 가디스 장비 인챈트 재료인가
function IS_GODDESS_ENCHANT_MATERIAL(item_obj)
	if item_obj == nil then
		return false
	end

	local str_arg2 = TryGetProp(item_obj, 'StringArg2', 'None')
	if str_arg2 ~= 'Goddess' then
		return false
	end

	local str_arg = TryGetProp(item_obj, 'StringArg', 'None')
	if str_arg ~= 'Enchant' then
		return false
	end

	return true
end

function IS_ENABLE_APPLY_GODDESS_ENCHANT(material, target)	
	if IS_GODDESS_ENCHANT_MATERIAL(material) == false then
		return false
	end
	
	if item_goddess_growth.is_goddess_growth_item(target) == true then
		return false
	end

	if TryGetProp(target, 'ItemGrade', 1) ~= 6 then
		return false
	end

	local num_arg = TryGetProp(material, 'NumberArg1', 0)
	local use_lv = TryGetProp(target, 'UseLv', 1)
	if use_lv > num_arg then
		return false
	end

	return true
end
-- 인챈트 끝 --

-- 초월 --
function GET_MAX_TRANSCEND_POINT()
	local cls_list = GetClassList("ItemTranscend")
	if cls_list == nil then
		return 10
	end
	return GetClassCount("ItemTranscend")
end

item_goddess_transcend = {}

item_goddess_transcend.get_material_name_list = function()
	local name_list = {}

	table.insert(name_list, "Premium_item_transcendence_Stone")

	return name_list
end

local item_goddess_transcend_material_list = nil

function setting_lv460_transcend_material(mat_list_by_lv)
	local transcend_misc = "Premium_item_transcendence_Stone" -- 여신의 축복석
	
	-- 여기서 레벨별 누적 재료를 세팅한다.
	mat_list_by_lv[460][1][transcend_misc] = 1

	mat_list_by_lv[460][2][transcend_misc] = 2

	mat_list_by_lv[460][3][transcend_misc] = 3
	
	mat_list_by_lv[460][4][transcend_misc] = 4

	mat_list_by_lv[460][5][transcend_misc] = 5

	mat_list_by_lv[460][6][transcend_misc] = 6
	
	mat_list_by_lv[460][7][transcend_misc] = 8

	mat_list_by_lv[460][8][transcend_misc] = 11

	mat_list_by_lv[460][9][transcend_misc] = 15
	
	mat_list_by_lv[460][10][transcend_misc] = 20
end

function make_item_goddess_transcend_material_list()
	if item_goddess_transcend_material_list ~= nil then
		return
	end

	item_goddess_transcend_material_list = {}
	item_goddess_transcend_material_list[460] = {} -- 차후 더 높은 레벨의 아이템이 추가될시에 추가
	
	local classtype_list = {}
	table.insert(classtype_list, 'Sword')
	table.insert(classtype_list, 'THSword')
	table.insert(classtype_list, 'Staff')
	table.insert(classtype_list, 'THStaff')
	table.insert(classtype_list, 'Bow')
	table.insert(classtype_list, 'THBow')
	table.insert(classtype_list, 'Mace')
	table.insert(classtype_list, 'THMace')
	table.insert(classtype_list, 'Spear')
	table.insert(classtype_list, 'THSpear')	

	table.insert(classtype_list, 'Rapier')
	table.insert(classtype_list, 'Cannon')
	table.insert(classtype_list, 'Musket')
	table.insert(classtype_list, 'Dagger')
	table.insert(classtype_list, 'Pistol')
	table.insert(classtype_list, 'Shield')
	table.insert(classtype_list, 'Trinket')

	table.insert(classtype_list, 'Gloves')
	table.insert(classtype_list, 'Boots')
	table.insert(classtype_list, 'Pants')
	table.insert(classtype_list, 'Shirt')

	for lv, v1 in pairs(item_goddess_transcend_material_list) do
		for _, class_type in pairs(classtype_list) do
			item_goddess_transcend_material_list[lv][class_type] = {}
			for i = 1, GET_MAX_TRANSCEND_POINT() do
				item_goddess_transcend_material_list[lv][class_type][i] = {}
			end
		end
	end

	local mat_list_by_lv = {}
	mat_list_by_lv[460] = {}
	for i = 1, GET_MAX_TRANSCEND_POINT() do
		mat_list_by_lv[460][i] = {}
	end
	setting_lv460_transcend_material(mat_list_by_lv)
	-- 이후 레벨이 증가할때 추가		

	-- item_goddess_transcend_material_list[item_UseLv][classtype][goal_transcend_lv] - {재료이름 : 개수} 반환
	for class_type, v in pairs(item_goddess_transcend_material_list[460]) do		
		for lv, dic in pairs(v) do
			for i = 1, GET_MAX_TRANSCEND_POINT() do
				item_goddess_transcend_material_list[460][class_type][i] = mat_list_by_lv[460][i]
			end
		end
	end
end

make_item_goddess_transcend_material_list()

-- 해당 초월 단계로 가는데 필요한 재료 목록을 가져온다
item_goddess_transcend.get_material_list = function(use_lv, class_type, cur_lv, goal_lv)
	if item_goddess_transcend_material_list[use_lv] == nil then
		return nil
	end

	if item_goddess_transcend_material_list[use_lv][class_type] == nil then
		return nil
	end

	local mat_name_list = item_goddess_transcend.get_material_name_list()
	local goal_list = item_goddess_transcend_material_list[use_lv][class_type][goal_lv]
	if cur_lv == 0 then
		return goal_list
	elseif cur_lv > 0 then
		local ret_list = {}
		local cur_list = item_goddess_transcend_material_list[use_lv][class_type][cur_lv]
		for _, name in pairs(mat_name_list) do
			ret_list[name] = goal_list[name] - cur_list[name]
		end

		return ret_list
	else
		return nil
	end
end

-- 460레벨 이상, 가디스 등급만 가능
item_goddess_transcend.is_able_to_transcend = function(target_item)
	if target_item ~= nil and TryGetProp(target_item, 'Reinforce_Type', 'None') == 'goddess' and TryGetProp(target_item, 'UseLv', 0) == 460 and TryGetProp(target_item, 'ItemGrade', 0) == 6 then
		return 'YES'
	end

	return 'WebService_38'
end
-- 초월 끝

-- 460레벨 이상, 가디스 등급만 가능
item_goddess_transcend.is_able_to_enchant = function(target_item)
	if CHECK_JEWELL_COMMON_CONSTRAINT(target_item) == false then
		return 'WebService_38'
	end

	return 'YES'
end

item_goddess_transcend.is_able_to_socket = function (target_item)
	if target_item == nil then
		return false;
	end

	if item_goddess_growth.is_goddess_growth_item(target_item) == true then
		return false
	end
	
	local classType = TryGetProp(target_item, 'ClassType');
	local enableClassType = {'Sword', 'THSword', 'Staff', 'THBow', 'Bow', 'Mace', 'THMace', 'Spear', 'THSpear', 'Dagger', 'THStaff', 'Pistol', 'Rapier', 'Cannon', 'Musket', 'Shirt', 'Pants', 'Boots', 'Gloves', 'Shield', 'Trinket'};
	for i = 1, #enableClassType do
		if enableClassType[i] == classType then
			return true;
		end
	end
	return false;
end

item_goddess_transcend.is_able_to_evolve = function(target_item)
	local use_lv = TryGetProp(target_item, 'UseLv', 0)
	local evolved_lv = TryGetProp(target_item, 'EvolvedItemLv', 0)	

	local group = TryGetProp(target_item, 'GroupName', 'None')	
	return use_lv >= 460 and use_lv <= evolved_lv and (string.find(group, 'Weapon') ~= nil)
end

-- 진화
MAX_EVOLVE_MAT_COUNT = 4

function GET_EVOLVE_MAT_LIST(lv)
	local mat_info = GetClass('goddess_evolve', 'Evolve_' .. lv)
	if mat_info == nil then
		return nil
	end

	local list = {}
	for i = 1, MAX_EVOLVE_MAT_COUNT do
		local mat_name = TryGetProp(mat_info, 'MaterialItem_' .. i, 'None')
		local mat_count = TryGetProp(mat_info, 'MaterialItemCnt_' .. i, 0)
		if mat_name == 'None' or mat_count <= 0 then
			break
		end

		list[mat_name] = mat_count
	end

	return list
end

function IS_EVOLVED_ITEM(item)		
	local use_lv = TryGetProp(item, 'UseLv', 0)
	local evolved_lv = TryGetProp(item, 'EvolvedItemLv', 0)	
	if evolved_lv > use_lv then
		return true
	else
		return false
	end
end

-- 진화 끝

-- 강화 스크롤
function IS_ABLE_TO_USE_REINFORCE_SCROLL(item, scroll)
	if TryGetProp(item, 'Reinforce_2', 0) >= TryGetProp(scroll, 'NumberArg2', 0) then
		return false, 'cant_use_more_than_reinforce_point'
	end

	local scroll_lv = TryGetProp(scroll, 'NumberArg1', 0)

	if scroll_lv == TryGetProp(item, 'UseLv', 0) then
		if TryGetProp(item, 'StringArg', 'None') == 'Goddess_Armor_Lv' .. scroll_lv and TryGetProp(scroll, 'StringArg', 'None') == 'armor_reinforce_scroll' then
			return true
		end
	
		if TryGetProp(item, 'StringArg', 'None') == 'Goddess_Weapon_Lv' .. scroll_lv and TryGetProp(scroll, 'StringArg', 'None') == 'weapon_reinforce_scroll' then
			return true
		end
	end

	return false, 'DontUseItem'
end