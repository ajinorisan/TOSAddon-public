-- 아이템 아크 shared_item_ark.lua

function replace(text, to_be_replaced, replace_with)
	local retText = text
	local strFindStart, strFindEnd = string.find(text, to_be_replaced)	
    if strFindStart ~= nil then
		local nStringCnt = string.len(text)		
		retText = string.sub(text, 1, strFindStart-1) .. replace_with ..  string.sub(text, strFindEnd+1, nStringCnt)		
    else
        retText = text
	end
	
    return retText
end


shared_item_ark = {}
max_ark_option_count = 10 -- 옵션이 최대 10개 있다고 가정함
item_ark_grow_ratio = 0.2  -- 아이템 렙업을 위한 재료 요구량 증가 계수
item_ark_grow_ratio_exp_up = 0.1 -- 뉴클 증가 계수

----------------------------------  재료들 --------------------------------------------

shared_item_ark.get_exp_material = function()
    return 'misc_ore22' -- 뉴클 가루
end

-- 축석, 신비한서, 시에라 스톤의 class_name
shared_item_ark.get_require_item_list_for_lv = function()
    return 'Premium_item_transcendence_Stone', 'HiddenAbility_Piece', 'misc_ore23_stone'
end
----------------------------------  재료들 끝 --------------------------------------------



shared_item_ark.get_low_lv_adventage = function(goal_lv, max_lv)
    if max_lv == nil or max_lv == 0 then
        max_lv = 100
    end

    local low_lv_adventage = 1
    local diff = (max_lv - goal_lv) / max_lv
    diff = tonumber(string.format("%.2f", diff))
    low_lv_adventage = 1 - diff
    low_lv_adventage = tonumber(string.format("%.2f", low_lv_adventage))
    return low_lv_adventage
end

-- 축석 개수, 신비한 서 낱장, 시에라 스톤 순으로 반환
shared_item_ark.get_require_count_for_next_lv = function(goal_lv, max_lv, is_character_belong)
    if is_character_belong == nil then
        is_character_belong = false
    end

    local space_name = 'item_ark_material'

    if is_character_belong == true then
        space_name = 'item_ark_material_belong'
    end

    local list, cnt = GetClassList(space_name)
    if list == nil or cnt < 1 then
        return 99999, 99999, 99999
    end

    if goal_lv - 1 > cnt or goal_lv - 1 < 1 then
        return 99999, 99999, 99999
    end

    local cls = GetClassByIndexFromList(list, goal_lv - 1)
    if cls == nil then
        return 99999, 99999, 99999
    end

    local a, b, c = shared_item_ark.get_require_item_list_for_lv()
    return TryGetProp(cls, a, 99999), TryGetProp(cls, b, 99999), TryGetProp(cls, c, 99999)    
end

-- 렙업에 필요한 뉴클 가루 수
shared_item_ark.get_require_count_for_exp_up = function(goal_lv, max_lv, is_character_belong)    
    if is_character_belong == nil then
        is_character_belong = false
    end

    local space_name = 'item_ark_material'
    
    if is_character_belong == true then
        space_name = 'item_ark_material_belong'
    end

    local list, cnt = GetClassList(space_name)
    if list == nil or cnt < 1 then
        return 10000000
    end

    if goal_lv - 1 > cnt or goal_lv - 1 < 1 then
        return 10000000
    end
    local cls = GetClassByIndexFromList(list, goal_lv - 1)

    if cls == nil then
        return 1000000
    end
    
    return TryGetProp(cls, shared_item_ark.get_exp_material(), 800000)   
end

shared_item_ark.is_valid_condition_for_copy = function(item_dest, item_src)
    if TryGetProp(item_src, 'CharacterBelonging', 0) ~= TryGetProp(item_dest, 'CharacterBelonging', 0) then
        -- 같은 귀속 상태여야 함
        return false
    end
    
    local src_max_lv = TryGetProp(item_src, 'MaxArkLv', 10)
    local dest_max_lv = TryGetProp(item_dest, 'MaxArkLv', 10)

    local src_lv = TryGetProp(item_src, 'ArkLevel', 1)
    local dest_lv = TryGetProp(item_dest, 'ArkLevel', 1) 

    if dest_max_lv < src_lv then
        return false
    end

    if dest_lv > src_lv then
        return false
    end

    if dest_lv == src_lv then
        local src_exp = TryGetProp(item_src, 'ArkExp', 0)
        local dest_exp = TryGetProp(item_dest, 'ArkExp', 0)

        if dest_exp >= src_exp then
            return false
        end
    end

    return true
end

-- 최대렙 확인
shared_item_ark.is_max_lv = function(item)    
    if item == nil then
        return "YES"
    end

    local max = TryGetProp(item, 'MaxArkLv', 10)    
    local lv = TryGetProp(item, 'ArkLevel', 1)
    
    if lv >= max then
        return "YES"
    else
        return "NO"
    end
end

-- 다음 레벨에 필요한 경험치
shared_item_ark.get_next_lv_exp = function(item)    
    local is_max_lv = shared_item_ark.is_max_lv(item)    
    if is_max_lv == "YES" then        
        return false, nil
    end

    local max_lv = TryGetProp(item, 'MaxArkLv', 10)    
    local current_lv = TryGetProp(item, 'ArkLevel', 1)

    local is_character_belong = false
    if TryGetProp(item, 'CharacterBelonging', 0) == 1 then
        is_character_belong = true
    end

    local next_exp = shared_item_ark.get_require_count_for_exp_up(current_lv + 1, max_lv, is_character_belong)    
    next_exp = tonumber(next_exp)
    if next_exp <= 0 then
        return false, nil
    end
    
    return true, next_exp
end


shared_item_ark.get_current_lv_exp = function(item)    
    local max_lv = TryGetProp(item, 'MaxArkLv', 10)
    local current_lv = TryGetProp(item, 'ArkLevel', 1)    

    local is_character_belong = false
    if TryGetProp(item, 'CharacterBelonging', 0) == 1 then
        is_character_belong = true
    end

    local next_exp = shared_item_ark.get_require_count_for_exp_up(current_lv, max_lv, is_character_belong)    
    next_exp = tonumber(next_exp)
    if next_exp <= 0 then
        return false, nil
    end
    
    return true, next_exp
end

--------------------------------------- 반환 관련 로직 ---------------------------------------
shared_item_ark.get_return_newcle_count = function(item)
    if TryGetProp(item, 'CharacterBelonging', 0) == 1 then
        return 0
    end

    local ret_count = 0    
    local max_lv = TryGetProp(item, 'MaxArkLv', 10)
    local lv = TryGetProp(item, 'ArkLevel', 1)
    local exp = TryGetProp(item, 'ArkExp', 1)

    for i = 1, lv - 1 do
        local count = shared_item_ark.get_require_count_for_exp_up(i + 1, 10, false)        
        ret_count = ret_count + count        
    end

    ret_count = ret_count + exp
    return ret_count
end

shared_item_ark.get_return_material = function(item)
    if TryGetProp(item, 'CharacterBelonging', 0) == 1 then
        return {}
    end

    local max_lv = TryGetProp(item, 'MaxArkLv', 10)
    local lv = TryGetProp(item, 'ArkLevel', 1)
    local exp = TryGetProp(item, 'ArkExp', 1)

    local a = 0 -- 여축
    local b = 0 -- 낱장
    local c = 0 -- 스톤
    
    for i = 1, lv - 1 do
        local count_1, count_2, count_3 = shared_item_ark.get_require_count_for_next_lv(i + 1, 10, false)
        a = a + count_1
        b = b + count_2
        c = c + count_3        
    end
    
    local ret = {}

    ret['Premium_item_transcendence_Stone'] = a
    ret['HiddenAbility_Piece'] = b
    ret['misc_ore23_stone'] = c

    return ret
end

shared_item_ark.get_final_return_exp = function(item)
    local ret = {}
    ret['misc_ore22'] = 0
    ret['Vis'] = 0
    local silver = 0

    local newcle_count = shared_item_ark.get_return_newcle_count(item)
    ret['misc_ore22'] = ret['misc_ore22'] + newcle_count
    silver = silver + newcle_count
    
    local material_ret = shared_item_ark.get_return_material(item) -- 레벨업 비용 반환
    for k, v in pairs(material_ret) do
        if ret[k] == nil then
            ret[k] = 0
        end

        ret[k] = ret[k] + v
    end

    if silver > 0 then
        ret['Vis'] = silver
    end

    local _ret = {}
    for k, v in pairs(ret) do
        if v > 0 then
            _ret[k] = v
        end
    end

    return _ret
end

shared_item_ark.get_final_return_ark_material_list = function(item)
    local ret = {}
    ret['misc_ore22'] = 0
    local silver = 0

    local newcle_count = shared_item_ark.get_return_newcle_count(item)
    ret['misc_ore22'] = ret['misc_ore22'] + newcle_count
    --silver = silver + newcle_count + 10000000 -- 티에리움꺼(온전한 형태로 반환)
    silver = silver + newcle_count

    local material_ret = shared_item_ark.get_return_material(item) -- 레벨업 비용 반환
    for k, v in pairs(material_ret) do
        if ret[k] == nil then
            ret[k] = 0
        end

        ret[k] = ret[k] + v
    end

    local tierium_ret = shared_item_ark.get_return_ark_material() -- 티에리움1, 아키스톤 파편20 반환 
    for k, v in pairs(tierium_ret) do
        if ret[k] == nil then
            ret[k] = 0
        end

        ret[k] = ret[k] + v
    end

    if silver > 0 then
        ret['Vis'] = silver
    end

    local _ret = {}
    for k, v in pairs(ret) do
        if v > 0 then
            _ret[k] = v
        end
    end

    return _ret
end

-- 티에리움 재료들 + 아키스톤 파편 20개, 실버 10,000,000 지급 필요
shared_item_ark.get_return_ark_material = function()
    -- 낱장 10
    -- 스톤 50
    -- 여축 50
    -- 프락 30
    
    local ret = {}
    ret['misc_thierrynium'] = 1
    -- ret['HiddenAbility_Piece'] = 10  -- 낱장
    -- ret['misc_ore23_stone'] = 50    -- 스톤
    -- ret['Premium_item_transcendence_Stone'] = 50 -- 여축
    -- ret['misc_ore15'] = 30          -- 프락
    ret['Piece_LegendMisc'] = 20    -- 아키스톤 파편 20
    return ret
end
------------------ end of 반환 관련 로직 ---------------------------------------

-- 아크 변환 체크
shared_item_ark.is_able_to_convert = function(ark, scroll)
    if TryGetProp(ark, 'CharacterBelonging', 0) ~= 1 then
        return false, 'OnlyFromCabinetItemUsable'
    end

    if TryGetProp(ark, 'StringArg2', 'None') ~= 'Made_Ark' then        
        return false, 'OnlyCabinetArk'
    end

    if TryGetProp(scroll, 'StringArg', 'None') ~= 'ArkConvertScroll' then
        return false, 'NotValidItem'
    end

    return true, 'None'
end

-- 분해 가능한 마신/여신방어구 인가?
-- stringArg, NumberArg1 체크
function ENABLE_DECOMPOSE_EVIL_GODDESS_ITEM(item)    
    if TryGetProp(item, 'GroupName', 'None') == 'Icor' then  -- 아이커인 경우
        local inheritance_name = TryGetProp(item, 'InheritanceItemName', 'None')
        if inheritance_name ~= 'None' then
            local item_obj = GetClass('Item', inheritance_name)
            if item_obj == nil then
                return false
            end
            local string_arg = TryGetProp(item_obj, 'StringArg', 'None')
            if (string_arg == 'evil' or string_arg == 'goddess') and TryGetProp(item_obj, 'NumberArg1', 0) >= 1 then
                return true    
            end
        end
    else
        local string_arg = TryGetProp(item, 'StringArg', 'None')
        if (string_arg == 'evil' or string_arg == 'goddess') and TryGetProp(item, 'NumberArg1', 0) >= 1 then
            return true    
        end
    end

    return false
end

------------------------------------ 아크 툴팁 관련 ----
-- 반환값 : tooptip_type, option, level, value

-------------- 아크 - 힘 ----------------
-- 첫번째 옵션 힘은 1레벨당 16씩 오른다.
function get_tooltip_Ark_str_arg1()    
    return 1, 'STR_BM', 1, 16
end

-- 두번째 옵션 물방은 3레벨당 500씩 오른다.
function get_tooltip_Ark_str_arg2()
    return 1, 'DEF_BM', 3, 500
end

-- 세번째 옵션 민/맥 물공은 5레벨당 500씩 오른다.
function get_tooltip_Ark_str_arg3()
    return 1, 'EQUIP_PATK', 5, 700
end

-------------- 아크 - 지능 ----------------
-- 첫번째 옵션 지능은 1레벨당 16씩 오른다.
function get_tooltip_Ark_int_arg1()
    return 1, 'INT_BM', 1, 16
end

-- 두번째 옵션 마방은 3레벨당 x씩 오른다.
function get_tooltip_Ark_int_arg2()
    return 1, 'MDEF_BM', 3, 500
end

-- 세번째 옵션 민/맥 마공은 5레벨당 x씩 오른다.
function get_tooltip_Ark_int_arg3()
    return 1, 'EQUIP_MATK', 5, 700
end

-------------- 아크 - 민첩 ----------------
-- 첫번째 옵션 민은 1레벨당 16씩 오른다.
function get_tooltip_Ark_dex_arg1()
    return 1, 'DEX_BM', 1, 16
end

-- 두번째 옵션 회피는 3레벨당 x씩 오른다.
function get_tooltip_Ark_dex_arg2()
    return 1, 'DR_BM', 3, 300
end

-- 세번째 옵션 물리 치공은 5레벨당 x씩 오른다.
function get_tooltip_Ark_dex_arg3()
    return 1, 'CRTATK_BM', 5, 1400
end

-------------- 아크 - 정신 ----------------
-- 첫번째 옵션 정신은 1레벨당 16씩 오른다.
function get_tooltip_Ark_mna_arg1()
    return 1, 'MNA_BM', 1, 16
end

-- 두번째 옵션 치유력은 3레벨당 x씩 오른다.
function get_tooltip_Ark_mna_arg2()
    return 2, 'HEAL_PWR_BM', 3, 420, 'SUMMON_ATK'
end

-- 세번째 옵션 마치공 5레벨당 x씩 오른다.
function get_tooltip_Ark_mna_arg3()
    return 1, 'CRTMATK_BM', 5, 1400
end

-------------- 아크 - 질풍 ----------------
-- 첫번째 옵션 힘/민/지능은 1레벨당 20씩 오른다.
function get_tooltip_Ark_wind_arg1()
    return 1, 'STR_DEX_INT_BM', 1, 20
end

-- 두번째 옵션 기본 공격 3레벨당 x씩 오른다. 총 16회, 100 + (20 * 16) = 420%
function get_tooltip_Ark_wind_arg2()
    return 3, 'ARK_BASIC_ATTACK', 3, 20, 100
end

-- 세번째 옵션 질풍은 5레벨당 x씩 확률적으로 발생한다. (정수로 해야 함). 총 10회, 10 + (2 * 10) = 30%
function get_tooltip_Ark_wind_arg3()
    return 3, 'ARK_UNLEASH_WIND', 5, 5, 10
end

function get_Ark_wind_option_active_lv()
    return 5
end

-------------- 아크 - 낙뢰 ----------------
-- 첫번째 옵션 힘/지능은 1레벨당 16씩 오른다.
function get_tooltip_Ark_thunderbolt_arg1()
    return 1, 'STR_INT_BM', 1, 20
end

-- 두번째 옵션 낙뢰 발동시 이동속도가 3초간 증가한다.
function get_tooltip_Ark_thunderbolt_arg2()
    return 3, 'ARK_THUNDERBOLT_RATIO', 3, 1, 3, 'ArkOverpowerOptionText{Option}{interval}{addvalue}', ''
end

-- 세번째 옵션 낙뢰 계수는 5레벨당 x씩 오른다. 총 10회, 5250 + (10 * 1050) = 15750%
function get_tooltip_Ark_thunderbolt_arg3()
    return 3, 'ARK_THUNDERBOLT_ATTACK', 5, 840, 4200
end

function get_Ark_thunderbolt_option_active_lv()
    return 3
end

-------------- 아크 - 폭풍 ----------------
-- 첫번째 옵션 힘/지능은 1레벨당 16씩 오른다.
function get_tooltip_Ark_storm_arg1()
    return 1, 'STR_INT_BM', 1, 20
end

-- 두번째 옵션 폭풍 대상 수 3레벨당 1
function get_tooltip_Ark_storm_arg2()
    return 3, 'ARK_STORM_RATIO', 3, 1, 4, 'ArkOverpowerOptionText{Option}{interval}{addvalue}', ''
end

-- 세번째 옵션 폭풍 계수는 5레벨당 x씩 오른다. 총 16회, 2400 + (10 * 490) = 7300%
function get_tooltip_Ark_storm_arg3()
    return 3, 'ARK_STORM_ATTACK', 5, 653, 3200
end

function get_Ark_storm_option_active_lv()
    return 3
end

-------------- 아크 - 분산 ----------------
-- 첫번째 옵션 체력은 1레벨당 20씩 오른다.
function get_tooltip_Ark_dispersion_arg1()
    return 1, 'CON_BM', 1, 20
end

-- 두번째 옵션, 분산 시간 3레벨당 x씩  (정수로 해야 함), 총 10회, 5 + (1 * 10) = 15초
function get_tooltip_Ark_dispersion_arg2()
    return 3, 'ARK_DISPERSION_TIME', 3, 1, 5, 'ArkDispersionOptionText{Option}{interval}{addvalue}', ScpArgMsg('UI_Sec')
end

-- 세번째 옵션, 분산 시킬 피해 비율 5레벨당 5%씩 오른다. 총 6회, 25 + (6 * 5) = 55%, 최대 30레벨로 기획
function get_tooltip_Ark_dispersion_arg3()
    return 3, 'ARK_DISPERSION_RATIO', 5, 5, 25
end

function get_Ark_dispersion_option_active_lv()
    return 3
end

-------------- 아크 - 천벌 ----------------
-- 첫번째 옵션 힘, 지능은 1레벨당 20씩 오른다.
function get_tooltip_Ark_punishment_arg1()
    return 1, 'STR_INT_BM', 1, 20
end

-- 두번째 옵션, 천벌 발동 확률 3레벨당 x씩 (정수로 해야 함), 총 16회, 30 + (2 * 16) = 62%
function get_tooltip_Ark_punishment_arg2()
    return 3, 'ARK_PUNISHMENT_RATIO', 3, 2, 30
end

-- 세번째 옵션, 천벌 계수 5레벨당 5%씩 오른다. 총 10회, 70 + (6 * 5) = 100%
function get_tooltip_Ark_punishment_arg3()
    return 3, 'ARK_PUNISHMENT_ATTACK', 5, 5, 70
end

function get_Ark_punishment_option_active_lv()
    return 3
end

-------------- 아크 - 제압 ----------------
-- 첫번째 옵션 힘 지능은 1레벨당 20씩 오른다.
function get_tooltip_Ark_overpower_arg1()
    return 1, 'STR_INT_BM', 1, 20
end

-- 두번째 옵션, 명중, 블록관통은 3레벨당 50씩 오른다, 16회 200 + (16 * 100) = 1800
function get_tooltip_Ark_overpower_arg2()
    return 3, 'HR_BLK_BREAK_BM', 3, 100, 200, 'ArkOverpowerOptionText{Option}{interval}{addvalue}', ''
end

-- 세번째 옵션, 연체이자 비율은 5레벨당 6%씩 오른다. 총 10회, 10 + (10 * 4) = 50%
function get_tooltip_Ark_overpower_arg3()
    -- tooltip option 4는, 3번째 옵션의 base가 1개인 경우
    -- 적에게 거는 exprop : ARK_OVERPOWER_OVERDUE_PENALTY
    -- 마지막 걸린 시간 : ARK_OVERPOWER_OVERDUE_PENALTY_TIME
    
    return 4, 'ARK_OVERPOWER_OVERDUE', 5, 4, 10, 'Ark_overpower_desc{base1}'
end

function get_Ark_overpower_option_active_lv()
    return 3
end

-------------- 아크 - 치유의 물결 ----------------
-- 첫번째 옵션 정신, 체력은 1레벨당 16씩 오른다.
function get_tooltip_Ark_healingwave_arg1()
    return 1, 'MNA_CON_BM', 1, 20
end

-- 두번째 옵션 치유의 물결 치유계수는 기본 400, 3레벨당 100씩 늘어남, 400 + 100 * 16 = 2000
function get_tooltip_Ark_healingwave_arg2()
    return 3, 'ARK_HEALINGWAVE_HEALPWR', 3, 100, 900, 'ArkHealingwaveOptionText{Option}{interval}{addvalue}', '%'
end

-- 세번째 옵션 치유의 물결의 대상수는 기본5, 5레벨당 1회씩 늘어남
function get_tooltip_Ark_healingwave_arg3()
    return 3, 'ARK_HEALINGWAVE_COUNT', 5, 1, 5, 'ArkHealingwaveOptionText1{Option}{interval}{addvalue}', ScpArgMsg('NumberOfThings')
end

-- 3렙 달성시에 이후 옵션도 활성화 해주기 위해 생성해야하는 함수
function get_Ark_healingwave_option_active_lv()
    return 3
end

-------------------------------------------------------------------------------------------
--------------- 아크(pc방) - 폭풍 -----------------
function get_tooltip_Ark_pc_storm_arg1()
    return 1, 'STR_INT_BM', 1, 20
end

-- 두번째 옵션 폭풍 발동은 3레벨당 x씩 확률적으로 발생한다. (정수로 해야 함)
function get_tooltip_Ark_pc_storm_arg2()
    return 3, 'ARK_STORM_RATIO', 3, 1, 4
end

-- 세번째 옵션 폭풍 계수는 5레벨당 x씩 오른다. 
function get_tooltip_Ark_pc_storm_arg3()
    return 3, 'ARK_STORM_ATTACK', 5, 392, 1920
end


------------------------------ 이벤트 아크 7종 툴팁 ----------------------------

-------------- [이벤트] 아크 - 질풍 ----------------
function get_tooltip_Event_Ark_wind_arg1()
    return 1, 'STR_DEX_INT_BM', 1, 20
end

function get_tooltip_Event_Ark_wind_arg2()
    return 3, 'ARK_BASIC_ATTACK', 3, 20, 100
end

function get_tooltip_Event_Ark_wind_arg3()
    return 3, 'ARK_UNLEASH_WIND', 5, 5, 10
end

function get_Event_Ark_wind_option_active_lv()
    return 5
end

-------------- [이벤트] 아크 - 낙뢰 ----------------
function get_tooltip_Event_Ark_thunderbolt_arg1()
    return 1, 'STR_INT_BM', 1, 20
end

function get_tooltip_Event_Ark_thunderbolt_arg2()
    return 3, 'ARK_THUNDERBOLT_RATIO', 3, 1, 3, 'ArkOverpowerOptionText{Option}{interval}{addvalue}', ''
end

function get_tooltip_Event_Ark_thunderbolt_arg3()
    return 3, 'ARK_THUNDERBOLT_ATTACK', 5, 504, 2520
end

function get_Ark_thunderbolt_option_active_lv()
    return 3
end

-------------- [이벤트] 아크 - 폭풍 ----------------
function get_tooltip_Event_Ark_storm_arg1()
    return 1, 'STR_INT_BM', 1, 20
end

function get_tooltip_Event_Ark_storm_arg2()
    return 3, 'ARK_STORM_RATIO', 3, 1, 4, 'ArkOverpowerOptionText{Option}{interval}{addvalue}', ''
end

function get_tooltip_Event_Ark_storm_arg3()
    return 3, 'ARK_STORM_ATTACK', 5, 392, 1920
end

function get_Ark_storm_option_active_lv()
    return 3
end

-------------- [이벤트] 아크 - 분산 ----------------
function get_tooltip_Event_Ark_dispersion_arg1()
    return 1, 'CON_BM', 1, 20
end

function get_tooltip_Event_Ark_dispersion_arg2()
    return 3, 'ARK_DISPERSION_TIME', 3, 1, 5, 'ArkDispersionOptionText{Option}{interval}{addvalue}', ScpArgMsg('UI_Sec')
end

function get_tooltip_Event_Ark_dispersion_arg3()
    return 3, 'ARK_DISPERSION_RATIO', 5, 5, 25
end

function get_Ark_dispersion_option_active_lv()
    return 3
end

-------------- [이벤트] 아크 - 천벌 ----------------
function get_tooltip_Event_Ark_punishment_arg1()
    return 1, 'STR_INT_BM', 1, 20
end

function get_tooltip_Event_Ark_punishment_arg2()
    return 3, 'ARK_PUNISHMENT_RATIO', 3, 2, 30
end

function get_tooltip_Event_Ark_punishment_arg3()
    return 3, 'ARK_PUNISHMENT_ATTACK', 5, 5, 70
end

function get_Ark_punishment_option_active_lv()
    return 3
end

-------------- [이벤트] 아크 - 제압 ----------------
function get_tooltip_Event_Ark_overpower_arg1()
    return 1, 'STR_INT_BM', 1, 20
end

function get_tooltip_Event_Ark_overpower_arg2()
    return 3, 'HR_BLK_BREAK_BM', 3, 100, 200, 'ArkOverpowerOptionText{Option}{interval}{addvalue}', ''
end

function get_tooltip_Event_Ark_overpower_arg3()
    return 4, 'ARK_OVERPOWER_OVERDUE', 5, 4, 10, 'Ark_overpower_desc{base1}'
end

function get_Ark_overpower_option_active_lv()
    return 3
end

-------------- [이벤트] 아크 - 치유의 물결 ----------------
function get_tooltip_Event_Ark_healingwave_arg1()
    return 1, 'MNA_CON_BM', 1, 20
end

function get_tooltip_Event_Ark_healingwave_arg2()
    return 3, 'ARK_HEALINGWAVE_HEALPWR', 3, 100, 900, 'ArkHealingwaveOptionText{Option}{interval}{addvalue}', '%'
end

function get_tooltip_Event_Ark_healingwave_arg3()
    return 3, 'ARK_HEALINGWAVE_COUNT', 5, 1, 5, 'ArkHealingwaveOptionText1{Option}{interval}{addvalue}', ScpArgMsg('NumberOfThings')
end

function get_Ark_healingwave_option_active_lv()
    return 3
end