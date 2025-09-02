-- sharedscript.lua

local json = require('json')

SEASON_COIN_NAME = 'AustejaCertificate'
SEASON_COIN_PREFIX_NAME = 'AustejaCertificateCoin'

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

function is_goddess_moru(item)
    if string.find(TryGetProp(item, 'StringArg', 'None'), 'Certificate') ~= nil and TryGetProp(item, 'NumberArg1', 0) > 0 then
        return true
    end

    return false
end

function shuffle(tbl)
    local ret = {}
    for k, v in pairs(tbl) do
        table.insert(ret, v)
    end

    for i = #ret, 2, -1 do
      local j = math.random(i)
      ret[i], ret[j] = ret[j], ret[i]
    end

    return ret
end

function shuffle2(tbl)
    local ret = {}
    for k, v in pairs(tbl) do
        table.insert(ret, v)
    end

    for i = #ret, 2, -1 do
        local j = math.random(i)
        ret[i], ret[j] = ret[j], ret[i]
    end

    for i = #ret, 2, -1 do
        local j = math.random(i)
        ret[i], ret[j] = ret[j], ret[i]
    end
    
    return ret
end

function starts_with(str, prefix)
    local f = string.find(str, prefix)
    if f == nil then
        return false
    end

    if f == 1 then
        return true
    end

    return false
end

------------ 랜덤 옵션 관련 ----------------------------------------------------------------
-------------------------------------------------------------------------------------------
ITEM_POINT_MULTIPLE = 10
ITEM_ATK_POINT_MULTIPLE = 20

-- 랜덤 옵션 등장 정보 - item_random.xml

g_random_option_range_table = nil  -- 옵션별 min ~ max가 저장된 테이블
g_skip_option = {}  -- 과거 연산식이 적용되는 옵션, 이 옵션이 나오는 경우, 과거 로직을 돌린다.
g_skip_option['RES_FIRE'] = 1
g_skip_option['RES_ICE'] = 1
g_skip_option['RES_POISON'] = 1
g_skip_option['RES_LIGHTNING'] = 1
g_skip_option['RES_EARTH'] = 1
g_skip_option['RES_SOUL'] = 1
g_skip_option['RES_HOLY'] = 1
g_skip_option['RES_DARK'] = 1
g_skip_option['ADD_FIRE'] = 1
g_skip_option['ADD_ICE'] = 1
g_skip_option['ADD_POISON'] = 1
g_skip_option['ADD_LIGHTNING'] = 1
g_skip_option['ADD_EARTH'] = 1
g_skip_option['ADD_HOLY'] = 1
g_skip_option['ADD_DARK'] = 1
g_skip_option['ADD_SOUL'] = 1

-- 비중(weight) 값을 고정하고 변하지 않도록 한다. (새로운 아이템 슬롯이 추가되면 변경될 수도 있다)
total_equip_weight = 0            -- 전체 비중의 합
random_equip_weight = {}
random_equip_weight['RING1'] = 0.4        -- 반지1
random_equip_weight['RING2'] = 0.4        -- 반지2
random_equip_weight['NECK'] = 0.6         -- 목걸이
random_equip_weight['NECK_SET'] = 1.4     -- 장신구 세트
random_equip_weight['SEAL'] = 1           -- 인장
random_equip_weight['ARK'] = 2            -- 아크
random_equip_weight['SHIRT'] = 0.8        -- 상의
random_equip_weight['PANTS'] = 0.8       -- 하의
random_equip_weight['GLOVES'] = 0.8       -- 장갑
random_equip_weight['BOOTS'] = 0.8        -- 신발
random_equip_weight['Weapon'] = 1.5       -- 한손 무기
random_equip_weight['SubWeapon'] = 1.5    -- 보조무기
random_equip_weight['ARMOR_SET'] = 1      -- 방어구 세트

-- 랜덤 옵션 부여가 가능한 parts 리스트
random_option_equip_list = {}
random_option_equip_list['SHIRT'] = 1
random_option_equip_list['PANTS'] = 1
random_option_equip_list['GLOVES'] = 1
random_option_equip_list['BOOTS'] = 1
random_option_equip_list['Weapon'] = 1
random_option_equip_list['SubWeapon'] = 1
random_option_equip_list['Shield'] = 1
random_option_equip_list['Trinket'] = 1
random_option_equip_list['THWeapon'] = 1
-- end of 랜덤 옵션 부여가 가능한 parts 리스트

-- 비중 합 연산식
for k, v in pairs(random_equip_weight) do
    total_equip_weight = total_equip_weight + v    
end

-- 이 3개는 비중 합 연산식 보다 아래에 위치해야 한다!!!!!    --------------
random_equip_weight['Shield'] = 1.5
random_equip_weight['Trinket'] = 0.75
random_equip_weight['THWeapon'] = 2.25
------------------------------------------------------------------------

-- 옵션별 추가 멀티플, 해당 멀티플 수치가 바뀌면, calc_battle_status.lua 에도 동기화 해야 함
-- shared를 못쓰는 이유 : shared의 초기화보다 이 파일이 먼저 실행됨. 서버 시작시에 테이블 세팅이 필요하기에 가장 먼지 실행되어야 함
local random_option_multiple ={}
random_option_multiple[ITEM_POINT_MULTIPLE] = {'CRTHR', 'CRTDR', 'BLK_BREAK', 'BLK', 'ADD_HR', 'ADD_DR', 'RHP'}
random_option_multiple[ITEM_ATK_POINT_MULTIPLE] = { 'MSP',
    'ADD_CLOTH', 'ADD_LEATHER', 'ADD_IRON', 'ADD_SMALLSIZE', 'ADD_MIDDLESIZE',
    'ADD_LARGESIZE', 'ADD_GHOST', 'ADD_FORESTER', 'ADD_WIDLING', 'ADD_VELIAS', 
    'ADD_PARAMUNE', 'ADD_KLAIDA', 'MiddleSize_Def',
    'Cloth_Def', 'Leather_Def', 'Iron_Def'}
random_option_multiple[30] = {'ResAdd_Damage', 'Add_Damage_Atk'}
random_option_multiple[3] = {'LootingChance', 'STR', 'DEX', 'CON', 'INT', 'MNA', 'RSP'}
random_option_multiple[0.7] = {'MSTA'}
-- end of 옵션별 추가 멀티플

local base_lv = 430

-- item_lv, option_name, equip_group의 랜덤옵션 수치(min, max) 테이블을 생성한다.
function init_random_option_range_table_for_lv(item_lv)
    -- item_lv : option_name : equip_group : min/max(range)    
    if g_random_option_range_table[item_lv] == nil then
        g_random_option_range_table[item_lv] = {}
    end

    local once = false
    local log = false

    for multiple, option_list in pairs(random_option_multiple) do
        local total = multiple * (item_lv + (item_lv - base_lv)) -- ratio 조절 부분        
        for _, option_name in pairs(option_list) do            
            local str = option_name
            local str_equip = '\t'
            for equip, _ in pairs(random_option_equip_list) do
                
                if log == true then
                    str_equip = str_equip .. '\t' .. equip
                end
                
                local before_weight = random_equip_weight[equip] * 1000000
                if item_lv >= 460 then
                    if equip == 'Trinket' or equip == 'THWeapon' then
                        before_weight = 1.5 * 1000000
                    end
                end

                local weight = tonumber(string.format('%.8f', ((before_weight/1000000) / total_equip_weight)))
                local max_value = math.ceil(total * weight)
                local min_value = math.ceil(max_value * 0.3)
                if min_value <= 0 then
                    min_value = 1
                end
                
                if g_random_option_range_table[item_lv][option_name] == nil then
                    g_random_option_range_table[item_lv][option_name] = {}
                end
                
                if g_random_option_range_table[item_lv][option_name][equip] == nil then
                    g_random_option_range_table[item_lv][option_name][equip] = {}
                end

                g_random_option_range_table[item_lv][option_name][equip][1] = min_value
                g_random_option_range_table[item_lv][option_name][equip][2] = max_value
                
                if log == true then
                    str = str .. '\t' .. max_value
                end
            end            
            if once == false and log == true then
                print(str_equip)
                once = true
            end

            if log == true then
                print(str)
            end
        end        
    end
end

-- 초기 정보 (min, max) 세팅 함수 ----------------------------------------------
local function init_random_option_range_table()
    if g_random_option_range_table ~= nil then
        return
    end

    g_random_option_range_table = {}

    -- 여기 아래에 레벨별로 추가해 준다.
    init_random_option_range_table_for_lv(430)
    init_random_option_range_table_for_lv(440)
    init_random_option_range_table_for_lv(460)
    init_random_option_range_table_for_lv(470)
    init_random_option_range_table_for_lv(490)
end
-- end of 초기 정보 (min, max) 세팅 함수 ----------------------------------------------

-----------------------------------------------------------------------
-----------------------------------------------------------------------
--  랜덤 옵션 정보 세팅
init_random_option_range_table()
-----------------------------------------------------------------------
-----------------------------------------------------------------------

-- 아이템 등급에 따른 min 비율을 가져온다.
function get_item_grade_ratio(grade)
    local ret = 0.2

    if grade == 3 then  -- 레어 등급은 min은 max의 20%
        ret = 0.2
    elseif grade == 4 then
        ret = 0.8       -- 유니크 등급 min은 max의 80%
    elseif grade == 5 then
        ret = 0.8       -- 레전드 등급 min은 max의 80%
    elseif grade == 6 then
        ret = 0.5       -- 가디스 등급 min은 max의 50%
    end

    if ret > 0.8 then
        ret = 0.8
    end

    return ret
end

-- UseLv >= 430 이상 아이템의 랜덤옵션 값을 가져온다.
function GET_RANDOM_OPTION_VALUE_VER2(item, option_name)
    local equipGroup = TryGetProp(item, 'EquipGroup', 'None');
    local equip_group = equipGroup
    if equip_group == 'None' then
        equip_group = TryGetProp(item, 'ClassType', 'None');  
    end 
    local item_lv = TryGetProp(item, 'UseLv', 1)

    if equip_group == 'SubWeapon' and TryGetProp(item, 'ClassType', 'None') == 'Trinket' then
        equip_group = 'Trinket'
    end

    if g_random_option_range_table[item_lv] == nil then
        return nil, nil
    elseif g_random_option_range_table[item_lv][option_name] == nil then
        return nil, nil
    elseif g_random_option_range_table[item_lv][option_name][equip_group] == nil then
        return nil, nil
    else
        local item_grade = TryGetProp(item, 'ItemGrade', 1)
        local grade_ratio = get_item_grade_ratio(item_grade)  -- 아이템 등급에 따른 min 비율
        local max = g_random_option_range_table[item_lv][option_name][equip_group][2]
        local min = math.ceil(max * grade_ratio)
        return min, max
    end
end

function GET_RANDOM_OPTION_VALUE_BY_LEVEL(item, lv, option_name)
    local equipGroup = TryGetProp(item, 'EquipGroup', 'None');

    if equipGroup == 'Weapon' or equipGroup == 'THWeapon' or equipGroup == 'SubWeapon' then
        equipGroup = 'Weapon'
    elseif equipGroup == 'SHIRT' or equipGroup == 'PANTS' or equipGroup == 'BOOTS' or equipGroup == 'GLOVES' then
        equipGroup = 'SHIRT'
    end

    if g_random_option_range_table[lv] == nil then
        return nil, nil
    elseif g_random_option_range_table[lv][option_name] == nil then
        return nil, nil
    elseif g_random_option_range_table[lv][option_name][equipGroup] == nil then
        return nil, nil
    else
        local item_grade = TryGetProp(item, 'ItemGrade', 1)
        local grade_ratio = get_item_grade_ratio(item_grade)  -- 아이템 등급에 따른 min 비율
        local max = g_random_option_range_table[lv][option_name][equipGroup][2]
        local min = math.ceil(max * grade_ratio)
        return min, max
    end
end

icor_clsType_list = {}
icor_clsType_list['Shirt'] = 'TOP04_157'
icor_clsType_list['Pants'] = 'LEG04_157'
icor_clsType_list['Boots'] = 'FOOT04_157'
icor_clsType_list['Gloves'] = 'HAND04_159'
icor_clsType_list['Sword'] = 'SWD04_125'
icor_clsType_list['THSword'] = 'TSW04_125'
icor_clsType_list['Staff'] = 'STF04_126'
icor_clsType_list['THBow'] = 'TBW04_125'
icor_clsType_list['Bow'] = 'BOW04_125'
icor_clsType_list['Mace'] = 'MAC04_128'
icor_clsType_list['THMace'] = 'TMAC04_117'
icor_clsType_list['Shield'] = 'SHD04_121'
icor_clsType_list['Spear'] = 'SPR04_126'
icor_clsType_list['THSpear'] = 'TSP04_127'
icor_clsType_list['Dagger'] = 'DAG04_122'
icor_clsType_list['THStaff'] = 'TSF04_128'
icor_clsType_list['Pistol'] = 'PST04_121'
icor_clsType_list['Rapier'] = 'RAP04_123'
icor_clsType_list['Cannon'] = 'CAN04_117'
icor_clsType_list['Musket'] = 'MUS04_117'
icor_clsType_list['Trinket'] = 'TRK04_104'

function GET_RANDOM_OPTION_NAME_BY_CLSTYPE(item)
    local itemClsType = TryGetProp(item, 'ClassType', 'None')
    return icor_clsType_list[itemClsType]
end


------------ end of 랜덤 옵션 관련 ---------------------------------------------------------
-------------------------------------------------------------------------------------------

random_item = { }
date_time = { }
account_warehouse = {} 
skill_gem_list = nil
skill_gem_class_name_list = nil
skill_gem_ctrltype_list = nil
skill_gem_list_cube = nil

unpack = unpack or table.unpack

MAX_VIBORA_OPTION_COUNT = 3 

random_item.is_sealed_random_item = function(itemobj)
    if IS_EQUIP(itemobj) == false then
        return false;
    end

    local isRandomOption = TryGetProp(itemobj, 'NeedRandomOption')
    local isAppraisal = TryGetProp(itemobj, 'NeedAppraisal')

    if isRandomOption == 1 then
        return true;
    elseif isAppraisal == 1 then
        return true;
    end
    return false;
end

random_item.set_sealed_random_item_icon_color = function(icon)
    if icon ~= nil then
        icon:SetColorTone("FFFF0000")
    end
end

-- str = yyyy-mm-dd hh:mm:ss
date_time.get_date_time = function(str)
    if str == nil or str == 'None' then
        return nil
    end

    local token = StringSplit(str, ' ')
    if #token ~= 2 then
        return nil
    end

    local date = token[1]
    local time = token[2]

    local date_token = StringSplit(date, '-')
    local time_token = StringSplit(time, ':')
    if #date_token ~= 3 or #time_token ~= 3 then
        return nil
    end

    local year = tonumber(date_token[1])
    local month = tonumber(date_token[2])
    local day = tonumber(date_token[3])

    local hour = tonumber(time_token[1])
    local minute = tonumber(time_token[2])
    local second = tonumber(time_token[3])

    return year, month, day, hour, minute, second
end

-- 문자열 시간으로부터 루아시간을 가져온다.
date_time.get_lua_datetime_from_str = function(str)
    return date_time.get_lua_datetime(date_time.get_date_time(str))
end

date_time.get_lua_datetime = function(_year, _month, _day, _hour, _min, _sec)
    if _year == nil or _month == nil or _day == nil or _hour == nil or _min == nil or _sec == nil then
        return nil
	end
    return os.time { year = _year, month = _month, day = _day, hour = _hour, min = _min, sec = _sec }
end

-- 루아 시간으로 현재시간을 가져온다.
date_time.get_lua_now_datetime = function()
    local now_time = os.date('*t')
    local year = now_time['year']
    local month = now_time['month']
    local day = now_time['day']
    local hour = now_time['hour']
    local min = now_time['min']
    local sec = now_time['sec']
    local now = date_time.get_lua_datetime(year, month, day, hour, min, sec)
    return now
end

-- 루아 타임으로 현재시간을 가져온다.
date_time.get_lua_now_datetime_str = function()
    local ret = date_time.lua_datetime_to_str(date_time.get_lua_now_datetime())

    --2024-12-19 수정 Dev #144340
    --윈도우 시간대 변경 시 용증 부스트 툴팁이 같이 변경되는 현상 해결
    --클라이언트에서는 서버에 접속한 시간을 기준으로 측정.
    if IsServerSection() == 0 then
        return date_time.add_time(geTime.GetConnectServerDateTimeStr(), imcTime.GetAppTime() - geTime.GetConnectServerApptime())
    end
    return ret
end

-- start_datetime, end_datetime = yyyy-mm-dd hh:mm:ss (string)
-- 현재 시간이 start, end 사이에 존재하는가
date_time.is_between_time = function(start_datetime, end_datetime)
    if start_datetime == nil or end_datetime == nil or start_datetime == 'None' or end_datetime == 'None' then
        return false
    end

    local lua_start_datetime = date_time.get_lua_datetime_from_str(start_datetime)
    local lua_end_datetime = date_time.get_lua_datetime_from_str(end_datetime)

    if lua_start_datetime == nil or lua_end_datetime == nil then
        return false
    end

    local now = date_time.get_lua_now_datetime()
    if lua_start_datetime <= now and now <= lua_end_datetime then
        return true
    else
        return false
    end
end

-- start_datetime, end_datetime = yyyy-mm-dd hh:mm:ss (string)
-- 특정 시간(time , string)이 start, end 사이에 존재하는가
date_time.is_this_time_between_time = function(start_datetime, time, end_datetime)
    if start_datetime == nil or end_datetime == nil or start_datetime == 'None' or end_datetime == 'None' then
        return false
    end

    local lua_start_datetime = date_time.get_lua_datetime_from_str(start_datetime)
    local lua_end_datetime = date_time.get_lua_datetime_from_str(end_datetime)

    if lua_start_datetime == nil or lua_end_datetime == nil then
        return false
    end

    local now = date_time.get_lua_datetime_from_str(time)
    if lua_start_datetime <= now and now <= lua_end_datetime then
        return true
    else
        return false
    end
end


-- 루아 시간을 yyyy-mm-dd hh:mm:ss 로 변환한다
date_time.lua_datetime_to_str = function(lua_datetime)
    local ret_time = os.date('*t', lua_datetime)
    local year = ret_time['year']
    local month = ret_time['month']
    local day = ret_time['day']
    local hour = ret_time['hour']
    local min = ret_time['min']
    local sec = ret_time['sec']

    local ret_str = string.format('%04d-%02d-%02d %02d:%02d:%02d', year, month, day, hour, min, sec)
    return ret_str
end

-- pivot = yyyy-mm-dd hh:mm:ss (string)
-- pivot 에 sec를 더한 string을 반환
date_time.add_time = function(pivot, sec)
    local ret = date_time.get_lua_datetime_from_str(pivot)
    ret = ret + tonumber(sec)

    local ret_time = os.date('*t', ret)
    local year = ret_time['year']
    local month = ret_time['month']
    local day = ret_time['day']
    local hour = ret_time['hour']
    local min = ret_time['min']
    local sec = ret_time['sec']

    local ret_str = string.format('%04d-%02d-%02d %02d:%02d:%02d', year, month, day, hour, min, sec)
    return ret_str
end

-- a_str가 b_str보다 같거나 크다면 true
date_time.is_later_than = function(a_str, b_str)    
    local a = date_time.get_lua_datetime_from_str(a_str)
    local b = date_time.get_lua_datetime_from_str(b_str)    
    if a >= b then
        return true
    else
        return false
    end
end

-- 문자열로 남은 시간을 계산한다
date_time.get_diff_sec = function(str_end, str_start)
    local end_time = date_time.get_lua_datetime_from_str(str_end)
    local start_time = date_time.get_lua_datetime_from_str(str_start)

    return end_time - start_time
end

-- 레티샤 시작 시간과 종료 시간을 가져온다 yyyy-mm-dd hh:mm:ss 
function get_leticia_start_and_end_time_num()    
	local startTime = TryGetProp(GetClassByType('reward_tp', 1), "StartTime", "None")
    local endTime = TryGetProp(GetClassByType('reward_tp', 1), "EndTime", "None")

    if IsServerSection() == 1 then
        if GetServiceNation() == 'PAPAYA' then
            startTime = TryGetProp(GetClassByType('reward_tp', 10), "StartTime", "None")
            endTime = TryGetProp(GetClassByType('reward_tp', 10), "EndTime", "None")
        end
    else
        if config.GetServiceNation() == 'PAPAYA' then
            startTime = TryGetProp(GetClassByType('reward_tp', 10), "StartTime", "None")
            endTime = TryGetProp(GetClassByType('reward_tp', 10), "EndTime", "None")
        end
    end

	return startTime, endTime
end

-- 추가 팀창고 개수
account_warehouse.get_max_tab = function()
    return 4
end

account_warehouse.get_max_slot_per_tab = function()
    return 70
end

function is_balance_patch_care_period()    
    local eventCls = GetClass("time_check_for_balance_patch", 'time_check_for_balance_patch')
    if eventCls ~= nil and eventCls.Activate == 'YES' then
        local curTime = GetDBTime()
        local cur = date_time.get_lua_datetime(curTime.wYear, curTime.wMonth, curTime.wDay, curTime.wHour, curTime.wMinute, curTime.wDay)
        local start = date_time.get_lua_datetime(date_time.get_date_time(eventCls.Start))
        local endd = date_time.get_lua_datetime(date_time.get_date_time(eventCls.End))

        if cur == nil or start == nil or endd == nil then
            return false
        end

        if start <= cur and cur < endd then
            return true
        else
            return false
        end
    else
        return false
    end
end

function get_balance_patch_care_ratio()
    local eventCls = GetClass("time_check_for_balance_patch", 'time_check_for_balance_patch')
    if eventCls ~= nil and eventCls.Activate == 'YES' then
        local ratio = eventCls.Ratio
        if ratio == nil then
            return 1
        else
            return tonumber(ratio)
        end
    else
        return 1
    end
end

-- 스킬젬 합성
function make_skill_gem_list()
    local idx = 0
    if skill_gem_list == nil then        
        skill_gem_list = {}                
        local clsList, count =  GetClassList("Item")        
        for idx = 0, count - 1 do
            local cls = GetClassByIndexFromList(clsList, idx)            
            if cls ~= nil then                
                if TryGetProp(cls, 'StringArg', 'None') == 'SkillGem' and TryGetProp(cls, 'SkillName', 'None') ~= 'None' and TryGetProp(cls, 'StringArg2', 'None')=='None' then                   

                    local gem_job = TryGetProp(GetClass('Skill', TryGetProp(cls, 'SkillName', 'None')), 'Job', 'None')
                    local gem_ctrlType = TryGetProp(GetClassByStrProp('Job', 'JobName', gem_job), 'CtrlType', "None")
                    
                    if skill_gem_list[gem_ctrlType] == nil then
                        skill_gem_list[gem_ctrlType] = {}
                    end

                    table.insert(skill_gem_list[gem_ctrlType], TryGetProp(cls, 'ClassName', 'None'))

                end
            end
        end
    end
end

make_skill_gem_list()


 -- 스킬젬 큐브
 function make_skill_gem_list_cube()
     local idx = 0
     if skill_gem_list_cube == nil then        
         skill_gem_list_cube = {}                
         local clsList, count =  GetClassList("Item")       
         for idx = 0, count - 1 do
             local cls = GetClassByIndexFromList(clsList, idx)            
             if cls ~= nil then                
                 if TryGetProp(cls, 'StringArg', 'None') == 'SkillGem' and TryGetProp(cls, 'SkillName', 'None') ~= 'None' and TryGetProp(cls, 'StringArg2', 'None')=='None' then                 
                    table.insert(skill_gem_list_cube, TryGetProp(cls, 'ClassName', 'None'))
                end
             end
         end
     end
 end

 make_skill_gem_list_cube()

function GET_SKILL_GEM_LIST_BY_CTRLTYPE(ctrl)
    return skill_gem_list[ctrl]
end

function SCR_QUEST_LINK_FIRST(pc, questname)
    return SCR_QUEST_LINK_FIRST_SUB(pc, { questname }, { }, { })
end

function SCR_QUEST_LINK_FIRST_SUB(pc, t, ext, statet)
    if #t == 0 then
        return t, ext, statet
    end

    local list1 = { }
    local removeList1 = { }
    if #t > 0 then
        for i = 1, #t do
            if table.find(ext, t[i]) == 0 then
                local flag = 0
                for i2 = 1, 4 do
                    local questIES = GetClass('QuestProgressCheck', t[i])
                    local before = TryGetProp(questIES, 'QuestName' .. i2, 'None')
                    if before ~= 'None' then
                        local beforeCount = TryGetProp(questIES, 'QuestCount' .. i2, 0)
                        local state
                        if IsServerSection(pc) == 1 then
                            state = SCR_QUEST_CHECK(pc, before)
                        else
                            state = SCR_QUEST_CHECK_C(pc, before)
                        end
                        if beforeCount == 300 then
                            if state ~= 'COMPLETE' then
                                if table.find(list1, before) == 0 then
                                    list1[#list1 + 1] = before
                                    statet[#statet + 1] = { before, beforeCount, '>=' }
                                end
                                flag = 1
                            end
                        elseif beforeCount == 200 then
                            local terms = TryGetProp(questIES, 'QuestTerms' .. i2, '==')
                            if terms == '>=' then
                                if state ~= 'COMPLETE' and state ~= 'SUCCESS' then
                                    if table.find(list1, before) == 0 then
                                        list1[#list1 + 1] = before
                                        statet[#statet + 1] = { before, beforeCount, terms }
                                    end
                                    flag = 1
                                end
                            else
                                if state ~= 'SUCCESS' then
                                    if table.find(list1, before) == 0 then
                                        list1[#list1 + 1] = before
                                        statet[#statet + 1] = { before, beforeCount, terms }
                                    end
                                    flag = 1
                                end
                            end
                        elseif beforeCount == 1 then
                            local terms = TryGetProp(questIES, 'QuestTerms' .. i2, '==')
                            if terms == '>=' then
                                if state ~= 'COMPLETE' and state ~= 'SUCCESS' and state ~= 'PROGRESS' then
                                    if table.find(list1, before) == 0 then
                                        list1[#list1 + 1] = before
                                        statet[#statet + 1] = { before, beforeCount, terms }
                                    end
                                    flag = 1
                                end
                            else
                                if state ~= 'PROGRESS' then
                                    if table.find(list1, before) == 0 then
                                        list1[#list1 + 1] = before
                                        statet[#statet + 1] = { before, beforeCount, terms }
                                    end
                                    flag = 1
                                end
                            end
                            --                        elseif beforeCount == 0 then
                            --                            local terms = TryGetProp(questIES,'QuestTerms'..i2, '==')
                            --                            if terms == '>=' then
                            --                                if state ~= 'COMPLETE' and state ~= 'SUCCESS' and state ~= 'PROGRESS' and state ~= 'POSSIBLE' then
                            --                                    if table.find(list1, before) == 0 then
                            --                                        list1[#list1 + 1] = before
                            --                                    end
                            --                                    flag = 1
                            --                                end
                            --                            else
                            --                                if state ~= 'POSSIBLE' then
                            --                                    if table.find(list1, before) == 0 then
                            --                                        list1[#list1 + 1] = before
                            --                                    end
                            --                                    flag = 1
                            --                                end
                            --                            end
                        end
                    end
                end
                if flag == 1 then
                    if table.find(removeList1, t[i]) == 0 then
                        removeList1[#removeList1 + 1] = t[i]
                    end
                else
                    if table.find(ext, t[i]) == 0 then
                        ext[#ext + 1] = t[i]
                    end
                end
            end
        end
    end
    if #ext > 0 then
        for i = 1, #ext do
            local index = table.find(list1, ext[i])
            if index > 0 then
                table.remove(list1, index)
            end
        end
    end
    if #removeList1 > 0 then
        for i = 1, #removeList1 do
            local index = table.find(list1, removeList1[i])
            if index > 0 then
                table.remove(list1, index)
            end
        end
    end

    local ret1, ret2, ret3 = SCR_QUEST_LINK_FIRST_SUB(pc, list1, ext, statet)
    if #ret1 == 0 then
        return ret1, ret2, ret3
    end
end

function JOB_CHAPLAIN_PRE_CHECK(pc)
    local jobCircle = 0
    if IsServerSection(pc) == 1 then
        jobCircle = GetJobGradeByName(pc, 'Char4_2');
    else
        local jobIES = GetClass('Job', 'Char4_2')
        jobCircle = session.GetJobGrade(jobIES.ClassID);
    end

    if jobCircle >= 3 then
        return 'YES'
    end

    return 'NO'
end

function IS_KOR_JOB_EXEMPTION_PERIOD(jobClassName)
    local jobList = { 'Char1_19', 'Char2_19', 'Char5_12', 'Char4_19' }
    if GetServerNation() == 'KOR' then
        if table.find(jobList, jobClassName) > 0 then
            return 'YES'
        end
    end
    return 'NO'
end

function IS_KOR_TEST_SERVER()
    if GetServerNation() == 'KOR' and GetServerGroupID() == 9001 then
        return true
    end
    return false
end

function IMC_LOG(code, stringinfo)
    imclog(code, stringinfo);
end

-- new logger
function IMCLOG_FATAL(logger, code, stringinfo)
    ImcScriptLog(logger, "FATAL", code, stringinfo)
end
function IMCLOG_ALERT(logger, code, stringinfo)
    ImcScriptLog(logger, "ALERT", code, stringinfo)
end
function IMCLOG_CRITICAL(logger, code, stringinfo)
    ImcScriptLog(logger, "CRITICAL", code, stringinfo)
end
function IMCLOG_ERROR(logger, code, stringinfo)
    ImcScriptLog(logger, "ERROR", code, stringinfo)
end
function IMCLOG_WARN(logger, code, stringinfo)
    ImcScriptLog(logger, "WARN", code, stringinfo)
end
function IMCLOG_NOTICE(logger, code, stringinfo)
    ImcScriptLog(logger, "NOTICE", code, stringinfo)
end
function IMCLOG_INFO(logger, code, stringinfo)
    ImcScriptLog(logger, "INFO", code, stringinfo)
end
function IMCLOG_DEBUG(logger, code, stringinfo)
    ImcScriptLog(logger, "DEBUG", code, stringinfo)
end

function IMCLOG_CONTENT(tag, ...)
    local logMsg = "";
    for i, v in ipairs { ...} do
        logMsg = logMsg .. tostring(v);
    end

    ImcContentLog(tag, logMsg)
end

function IS_REINFORCEABLE_ITEM(item)

    if item.GroupName == 'Weapon' then
        return 1;
    end
    if item.GroupName == 'Armor' then
        return 1;
    end
    if item.GroupName == 'SubWeapon' and item.BasicTooltipProp ~= 'None' then
        return 1;
    end

    return 0;
end

function GET_LAST_UI_OPEN_POS(etc)

    if etc == nil then
        return nil
    end

    local stringpos = etc["LastUIOpenPos"]

    if stringpos == 'None' then
        return nil

    end

    local x, y, z, mapname, uiname;

    for i = 0, 5 do

        local divStart, divEnd = string.find(stringpos, "/");
        if divStart == nil then
            uiname = stringpos
            break;
        end

        local divstringpos = string.sub(stringpos, 1, divStart - 1);

        if i == 0 then
            mapname = divstringpos
        elseif i == 1 then
            x = divstringpos
        elseif i == 2 then
            y = divstringpos
        elseif i == 3 then
            z = divstringpos
        end

        stringpos = string.sub(stringpos, divEnd + 1, string.len(stringpos));
    end

    return mapname, x, y, z, uiname
end

-- done, 해당 함수 내용은 cpp로 이전되었습니다. 변경 사항이 있다면 반드시 프로그램팀에 알려주시기 바랍니다.
function IS_NO_EQUIPITEM(equipItem)
    -- No_~ 시리즈 아이템인지.

    local clsName = equipItem.ClassName;

    if clsName == 'NoWeapon' or clsName == "NoHat" or clsName == "NoBody" or clsName == "NoOuter" or clsName == 'NoShirt' or clsName == 'NoArmband' or clsName == 'NoHair' then
        return 1;
    elseif clsName == 'NoPants' or clsName == "NoGloves" or clsName == "NoBoots" or clsName == "NoRing" or clsName == 'NoHelmet' or clsName == 'NoNeck' then
        return 1;
    end

    return 0;
end

function GET_MAKE_SOCKET_PRICE(itemlv, grade, curcnt, taxRate)
    local clslist, cnt = GetClassList("socketprice");
    local gradRatio = { 1.2, 1, 0.5, 0.4, 0.3 }
    local itemGradeRatio = 1;
    local secretNumber = 1;
    if curcnt >= 1 then
        secretNumber = 0.8;
        itemGradeRatio = gradRatio[grade]
    end
    for i = 0, cnt - 1 do

        local cls = GetClassByIndexFromList(clslist, i);

        if cls.Lv == itemlv then
            local priceRatio =(curcnt + 1);
            local ret = SyncFloor(cls.NewSocketPrice * secretNumber *(priceRatio ^ 1 / itemGradeRatio));
            if taxRate ~= nil then
                ret = tonumber(CALC_PRICE_WITH_TAX_RATE(ret, taxRate))
            end
            return ret
        end
    end

    return 0;

end

function GET_REMOVE_GEM_PRICE(itemlv, taxRate)

    local clslist, cnt = GetClassList("socketprice");

    for i = 0, cnt - 1 do

        local cls = GetClassByIndexFromList(clslist, i);

        if cls.Lv == itemlv then
            local price = cls.RemoveSocketPrice
            if taxRate ~= nil then
                price = tonumber(CALC_PRICE_WITH_TAX_RATE(price, taxRate))
                -- 젬 추출 세금
            end
            return price
        end
    end

    return 0;

end

function GET_GEM_TYPE_NUMBER(GemType)

    if GemType == 'Circle' then
        return 1;
    elseif GemType == 'Square' then
        return 2;
    elseif GemType == 'Diamond' then
        return 3;
    elseif GemType == 'Star' then
        return 4;
    end

    return -1;
end

-- 특정 존 앵커 중 랜덤으로 1개 IES를 리턴해준다
function SCR_RANDOM_ZONE_ANCHORIES(zoneName)
    local idspace = 'Anchor_' .. zoneName
    local class_count = GetClassCount(idspace)

    if class_count == nil or class_count == 0 then
        return nil, 'zone'
    end

    local rand = IMCRandom(0, class_count)

    local classIES = GetClassByIndex(idspace, rand)

    if classIES ~= nil then
        return classIES
    end

end

-- 테이블에서 특정 컬럼을 검색해서 리턴해준다
function SCR_TABLE_SEARCH_ITEM(list, target)
    local result = 'NO'
    local keyList = { }
    for key, value in pairs(list) do
        if value == target then
            keyList[#keyList + 1] = key
        end
    end

    if #keyList > 0 then
        result = 'YES'
    end

    return result, keyList
end



function SCR_Q_SUCCESS_REWARD_JOB_GENDER_CHECK(pc, list, target1, target2, targetJob)
    local result = 'NO'
    local keyList = { }

    if target2 == 1 then
        target2 = 'M'
    elseif target2 == 2 then
        target2 = 'F'
    else
        return
    end
    for key, value in pairs(list) do
        local listSub1 = SCR_STRING_CUT_COLON(value)
        if listSub1[1] == 'JobChange' then
            if listSub1[2] == 'First' then
                local flag = 0

                if listSub1[3] ~= nil and(listSub1[3] == 'M' or listSub1[3] == 'F') then
                    if listSub1[3] ~= target2 then
                        flag = 1
                    end
                end

                if flag == 0 and targetJob ~= nil and targetJob ~= 'None' then
                    local classIES = GetClass('Job', targetJob)
                    if classIES ~= nil then
                        target1 = classIES.Initial
                        if IsServerSection(pc) == 1 then
                            local circle, changedJobCount = GetJobGradeByName(pc, targetJob);
                            if circle == 0 then
                                keyList[#keyList + 1] = key
                            end
                        else
                            local jobIES = SCR_GET_XML_IES('Job', 'Initial', target1)
                            if #jobIES >= 1 then
                                local ishave = IS_HAD_JOB(jobIES[1].ClassID)
                                if ishave == false then
                                    keyList[#keyList + 1] = key
                                end
                            end
                        end
                    end
                end
            end
        elseif #listSub1 == 1 then
            if listSub1[1] == 'M' or listSub1[1] == 'F' then
                if listSub1[1] == target2 then
                    keyList[#keyList + 1] = key
                end
            else
                if listSub1[1] == target1 then
                    keyList[#keyList + 1] = key
                end
            end
        elseif #listSub1 == 2 then
            if listSub1[1] == target1 then
                if listSub1[2] == target2 then
                    keyList[#keyList + 1] = key
                end
            end
        end
    end

    if #keyList > 0 then
        result = 'YES'
    end

    return result, keyList
end


-- 두개의 IES 리스트를 합쳐준다
function SCR_IES_ADD_IES(IES_list1, IES_list2)
    if IES_list1 == nil and IES_list2 == nil then
        return nil
    elseif IES_list1 == nil then
        IES_list1 = IES_list2
        return IES_list1
    elseif IES_list2 == nil then
        return IES_list1
    end

    if IES_list2 ~= nil then
        if #IES_list2 ~= nil then
            for y = 1, #IES_list2 do
                IES_list1[#IES_list1 + 1] = IES_list2[y]
            end
        end
    end
    return IES_list1
end

-- 특정 퀘스트 세션오브젝트 완료 조건 중 index 번째 조건 만족 확인
function SCR_QUEST_SOBJ_TERMS(pc, sObj_name, index)
    local sObj_quest = GetSessionObject(pc, sObj_name)
    if sObj_quest ~= nil then
        if GetPropType(sObj_quest, 'QuestInfoMaxCount' .. index) == nil or sObj_quest['QuestInfoMaxCount' .. index] == 0 then
            return 'NO_USE'
        elseif sObj_quest['QuestInfoValue' .. index] >= sObj_quest['QuestInfoMaxCount' .. index] then
            return 'YES'
        else
            return 'NO'
        end
    else
        return 'NO_QUEST'
    end
end

-- 특정 존에 있는 오브젝트의 좌표 IES 리스트를 찾아줌
function SCR_GET_MONGEN_ANCHOR(zone_name, column, value)
    local result2 = SCR_GET_XML_IES('GenType_' .. zone_name, column, value)
    if result2 ~= nil and #result2 > 0 then
        local result3 = SCR_GET_XML_IES('Anchor_' .. zone_name, 'GenType', result2[1].GenType)
        if result3 ~= nil and #result3 > 0 then
            return result3
        end
    end
end


-- xml 중 특정 컬럼의 값과 일치/유사 한 IES 리스트를 찾아줌 (option 1이면 유사 값, 아니면 일치)
function SCR_GET_XML_IES(idspace, column_name, target_value, option)
    local return_list = { }
    if idspace == nil then
        return return_list;
    end

    if GetClassByIndex(idspace, 0) == nil then
        return return_list;
    end

    local obj = GetClassByIndex(idspace, 0)
    if column_name == nil then
        return return_list;
    end

    if GetPropType(GetClassByIndex(idspace, 0), column_name) == nil then
        return return_list;
    end

    local class_count = GetClassCount(idspace)

    for y = 0, class_count - 1 do
        local classIES = GetClassByIndex(idspace, y)

        if option ~= 1 then
            if tostring(classIES[column_name]) == tostring(target_value) then
                return_list[#return_list + 1] = classIES
            end
        else
            if string.find(tostring(classIES[column_name]), tostring(target_value)) ~= nil then
                return_list[#return_list + 1] = classIES
            end
        end
    end

    return return_list
end

function SCR_JOBNAME_MATCHING(jobclassname)
    local result = GetClassString('Job', jobclassname, 'Initial')

    if result == nil then
        result = GetClassString('Job', 'Char1_1', 'Initial')
    end

    return result
end


function ZERO()
    return 0;
end

function ONE()
    return 1;
end

function FIVE()
    return 5;
end

function NONECP()
    return -1;
end

function SCR_MAX_SPL()
    return 512;
end

function SCR_DUPLICATION_SOLVE_TABLE(tb)
    local index1, index2, index3 = 0
    local temp_tb = { }

    for index1 = 1, #tb - 1 do
        for index2 = index1 + 1, #tb do
            if tb[index1] ~= 'None' and tb[index1] == tb[index2] then
                tb[index2] = 'None'
            end
        end
    end

    for index3 = 1, #tb do
        if tb[index3] ~= 'None' then
            temp_tb[#temp_tb + 1] = tb[index3]
        end
    end

    return temp_tb
end

function SCR_DUPLICATION_SOLVE(tb)
    local index1, index2, index3 = 0
    local temp_tb = { }

    for index1 = 1, #tb - 1 do
        for index2 = index1 + 1, #tb do
            if tb[index1][1] ~= 'None' and tb[index1][1] == tb[index2][1] then
                tb[index2][1] = 'None'
                if tb[index1][2] == -100 or tb[index2][2] == -100 then
                    tb[index1][2] = -100
                else
                    tb[index1][2] = tb[index1][2] + tb[index2][2]
                end
            end
        end
    end

    for index3 = 1, #tb do
        if tb[index3][1] ~= 'None' then
            temp_tb[#temp_tb + 1] = { }
            temp_tb[#temp_tb][1] = tb[index3][1]
            temp_tb[#temp_tb][2] = tb[index3][2]
        end
    end

    return temp_tb
end

function SCR_DUPLICATION_SOLVE_IES(tb, column)
    local index1, index2, index3 = 0
    local temp_tb = { }
    local temp_tb2 = tb
    local list = { }

    for index1 = 1, #temp_tb2 - 1 do
        for index2 = index1 + 1, #temp_tb2 do
            if temp_tb2[index1][column] == temp_tb2[index2][column] then
                list[#list + 1] = index2
            end
        end
    end

    for index3 = 1, #temp_tb2 do
        local flag = 0
        for i = 1, #list do
            if index3 == list[i] then
                flag = flag + 1
                break
            end
        end

        if flag == 0 then
            temp_tb[#temp_tb + 1] = temp_tb2[index3]
        end

        --        if temp_tb2[index3][column] ~= 'None' then
        --            temp_tb[#temp_tb + 1] = temp_tb2[index3]
        --        end
    end

    return temp_tb
end

function SCR_STRING_CUT_UNDERBAR(a)
    if a == nil then
        return
    end

    local temp_table = { };
    local w;
    local i;
    for w in string.gmatch(a, "[^_]+") do
        if tonumber(w) ~= nil then
            temp_table[#temp_table + 1] = tonumber(w);
        else
            temp_table[#temp_table + 1] = w;
        end
    end
    --    for i = 1, #temp_table do
    --        print(temp_table[i]);
    --    end
    --    print('AAAAA'..#temp_table)
    return temp_table;
end

function SCR_STRING_CUT_SHAP(a)
    if a == nil then
        return
    end

    local temp_table = { };
    local w;
    local i;
    for w in string.gmatch(a, "[^#]+") do
        if tonumber(w) ~= nil then
            temp_table[#temp_table + 1] = tonumber(w);
        else
            temp_table[#temp_table + 1] = w;
        end
    end
    --    for i = 1, #temp_table do
    --        print(temp_table[i]);
    --    end
    --    print('AAAAA'..#temp_table)
    return temp_table;
end

function SCR_STRING_CUT_SEMICOLON(a)
    if a == nil then
        return
    end

    local temp_table = { };
    local w;
    local i;
    for w in string.gmatch(a, "[^;]+") do
        if tonumber(w) ~= nil then
            temp_table[#temp_table + 1] = tonumber(w);
        else
            temp_table[#temp_table + 1] = w;
        end
    end
    --    for i = 1, #temp_table do
    --        print(temp_table[i]);
    --    end
    --    print('AAAAA'..#temp_table)
    return temp_table;
end

function SCR_STRING_CUT_COLON(a)
    if a == nil then
        return
    end
    local temp_table = { };
    local w;
    local i;
    for w in string.gmatch(a, "[^:]+") do
        if tonumber(w) ~= nil then
            temp_table[#temp_table + 1] = tonumber(w);
        else
            temp_table[#temp_table + 1] = w;
        end
    end

    --    for i = 1, #temp_table do
    --        print(temp_table[i]);
    --    end
    --    print('AAAAA'..#temp_table)
    return temp_table;
end

function SCR_STRING_CUT_COMMA(a)
    if a == nil then
        return
    end

    local temp_table = { };
    local w;
    local i;
    for w in string.gmatch(a, "[^,]+") do
        if tonumber(w) ~= nil then
            temp_table[#temp_table + 1] = tonumber(w);
        else
            temp_table[#temp_table + 1] = w;
        end
    end
    --    for i = 1, #temp_table do
    --        print(temp_table[i]);
    --    end
    --    print('AAAAA'..#temp_table)
    return temp_table;
end


function SCR_STRING_CUT_SPACEBAR(a)
    if a == nil then
        return
    end

    local temp_table = { };
    local w;
    local i;

    for w in string.gmatch(a, "[^ ]+") do
        if tonumber(w) ~= nil then
            temp_table[#temp_table + 1] = tonumber(w);
        else
            temp_table[#temp_table + 1] = w;
        end
    end

    --    for i = 1, #temp_table do
    --        print(temp_table[i]);
    --    end
    --    print('AAAAA'..#temp_table)
    return temp_table;
end

function SCR_STRING_CUT_CHAR(a)
    if a == nil then
        return
    end
    local temp_table = { };
    local i;
    for i = 1, string.len(a) do
        if tonumber(string.sub(a, i, i)) ~= nil then
            temp_table[#temp_table + 1] = tonumber(string.sub(a, i, i))
        else
            temp_table[#temp_table + 1] = string.sub(a, i, i)
        end
    end

    return temp_table
end

function SCR_STRING_CUT(a, b)
    if a == nil then
        return
    end
    local temp_table = { };
    local w;

    if type(a) == table then
        for i = 1, #a do
            if b == nil then
                b = '/'
            end
            if string.find(a[i], b) ~= nil then
                for w in string.gmatch(a[i], "[^" .. b .. "]+") do
                    if tonumber(w) ~= nil then
                        temp_table[#temp_table + 1] = tonumber(w);
                    else
                        temp_table[#temp_table + 1] = w;
                    end
                end
            else
                if tonumber(a[i]) ~= nil then
                    temp_table[#temp_table + 1] = tonumber(a[i])
                else
                    temp_table[#temp_table + 1] = a[i]
                end
            end
        end
    else
        if b == nil then
            b = '/'
        end
        for w in string.gmatch(a, "[^" .. b .. "]+") do
            if tonumber(w) ~= nil then
                temp_table[#temp_table + 1] = tonumber(w);
            else
                temp_table[#temp_table + 1] = w;
            end
        end
    end

    return temp_table;
end





function SCR_STRING_CUT_TO_STR(a, b)
    if a == nil then
        return
    end
    local temp_table = { };
    local w;

    if b == nil then
        b = '/'
    end
    for w in string.gmatch(a, "[^" .. b .. "]+") do
        temp_table[#temp_table + 1] = w;
    end

    return temp_table;
end






function SCR_STRING_CONCAT(table, a)
    local concatStr = "";
    if a == nil then
        a = ";";
    end

    for i = 1, #table do
        if type(table[i]) == "string" and string.find(concatStr, table[i]) == nil then
            if i < #table then
                concatStr = concatStr .. table[i] .. a;
            else
                concatStr = concatStr .. table[i];
            end
        end
    end

    return concatStr;
end

function SCR_STRING_TO_TABLE(a)
    if a == nil then
        return a
    end
    local ret = { }
    for i = 1, string.len(a) do
        ret[#ret + 1] = string.sub(a, i, i)
    end

    return ret
end
function SCR_DATE_TO_YHOUR_BASIC_2000_STR(str)
    if str == nil or type(str) ~= 'string' then
        return
    end

    local date = SCR_STRING_CUT(str)
    if #date == 4 then
        return SCR_DATE_TO_YHOUR_BASIC_2000(date[1], date[2], date[3], date[4])
    end
end
function SCR_DATE_TO_YHOUR_BASIC_2000(yy, mm, dd, hh)
    local days, monthdays, leapyears, nonleapyears, nonnonleapyears

    monthdays = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }

    leapyears = math.floor((yy - 2000) / 4);
    nonleapyears = math.floor((yy - 2000) / 100)
    nonnonleapyears = math.floor((yy - 1600) / 400)

    if ((math.fmod(yy, 4) == 0) and mm < 3) then
        leapyears = leapyears - 1
    end

    days = 365 *(yy - 2000) + leapyears - nonleapyears + nonnonleapyears - 1

    local c = 1
    while (c < mm) do
        days = days + monthdays[c]
        c = c + 1
    end

    days = days + dd + 1

    local yhour = days * 24 + hh

    return yhour
end

function SCR_DATE_TO_YMIN_BASIC_2000(yy, mm, dd, hh, min)
    local days, monthdays, leapyears, nonleapyears, nonnonleapyears

    monthdays = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }

    leapyears = math.floor((yy - 2000) / 4);
    nonleapyears = math.floor((yy - 2000) / 100)
    nonnonleapyears = math.floor((yy - 1600) / 400)

    if ((math.fmod(yy, 4) == 0) and mm < 3) then
        leapyears = leapyears - 1
    end

    days = 365 *(yy - 2000) + leapyears - nonleapyears + nonnonleapyears - 1

    local c = 1
    while (c < mm) do
        days = days + monthdays[c]
        c = c + 1
    end

    days = days + dd + 1

    local ymin = days * 1440 + hh * 60 + min

    return ymin
end
function SCR_DATE_TO_YDAY_BASIC_2000_REVERSE(yday)
    local yy, mm, dd
    local startY = 2000
    local monthdays = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }

    while 1 do
        local leapDay = 0
        if startY % 400 == 0 then
            leapDay = 1
        elseif startY % 100 == 0 then
        elseif startY % 4 == 0 then
            leapDay = 1
        end

        leapDay = monthdays[2] + leapDay

        for i = 1, #monthdays do
            local monDay = monthdays[i]
            if i == 2 then
                monDay = leapDay
            end

            if yday < monDay then
                yy = startY
                mm = i
                dd = yday
                return yy, mm, dd
            else
                yday = yday - monDay
            end

        end
        startY = startY + 1
    end


    return yy, mm, dd
end
function SCR_DATE_HOUR_TO_YWEEK_BASIC_2000(yy, mm, dd, hour, firstWday, firstHour)
    local yday2000 = SCR_DATE_TO_YDAY_BASIC_2000(yy, mm, dd)
    if hour < firstHour then
        yday2000 = yday2000 - 1
    end
    local result = math.floor((yday2000 + 6 - firstWday) / 7) + 1
    return result

end
function SCR_DATE_TO_YWEEK_BASIC_2000(yy, mm, dd, firstWday)
    local yday2000 = SCR_DATE_TO_YDAY_BASIC_2000(yy, mm, dd)
    local result = math.floor((yday2000 + 6 - firstWday) / 7) + 1
    return result
end
function SCR_DATE_TO_YDAY_BASIC_2000(yy, mm, dd)
    local days, monthdays, leapyears, nonleapyears, nonnonleapyears

    monthdays = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }

    leapyears = math.floor((yy - 2000) / 4);
    nonleapyears = math.floor((yy - 2000) / 100)
    nonnonleapyears = math.floor((yy - 1600) / 400)

    if ((math.fmod(yy, 4) == 0) and mm < 3) then
        leapyears = leapyears - 1
    end

    days = 365 *(yy - 2000) + leapyears - nonleapyears + nonnonleapyears - 1

    local c = 1
    while (c < mm) do
        days = days + monthdays[c]
        c = c + 1
    end

    days = days + dd + 1

    return days
end

function SCR_DATE_TO_HOUR(year, yday, hour)
    year = tonumber(year)
    yday = tonumber(yday)
    hour = tonumber(hour)
    local ret =(SCR_DATE_TO_YDAY_BASIC_2000(year - 1, 12, 31) * 24) +((yday - 1) * 24) + hour
    return ret
end

function SCR_YEARYDAY_TO_DAY(year, yday)
    year = tonumber(year)
    yday = tonumber(yday)
    local ret = SCR_DATE_TO_YDAY_BASIC_2000(year - 1, 12, 31) + yday
    return ret
end

function SCR_WDAY_TO_HOUR(wday, hour)
    wday = tonumber(wday)
    hour = tonumber(hour)
    local ret =((wday - 1) * 24) + hour
    return ret
end
function SCR_DAY_TO_HOUR(day, hour)
    day = tonumber(day)
    hour = tonumber(hour)
    local ret =((day - 1) * 24) + hour
    return ret
end
function SCR_MONTH_TO_YDAY(year, month, day)
    year = tonumber(year)
    month = tonumber(month)
    day = tonumber(day)

    local leapyears1 = year % 4
    local leapyears2 = year % 100
    local leapyears3 = year % 400

    local monthdays = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }
    local retDay = 0
    if month > 1 then
        for i = 1, month - 1 do
            retDay = retDay + monthdays[i]
        end
    end

    if month >= 3 then
        if leapyears1 == 0 then
            if leapyears2 ~= 0 or(leapyears2 == 0 and leapyears3 == 0) then
                retDay = retDay + 1
            end
        end
    end

    local ret = retDay + day
    return ret
end

function SCR_MONTH_TO_HOUR(year, month, day, hour)
    year = tonumber(year)
    month = tonumber(month)
    day = tonumber(day)
    hour = tonumber(hour)

    local leapyears1 = year % 4
    local leapyears2 = year % 100
    local leapyears3 = year % 400

    local monthdays = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }
    local retDay = 0
    if month > 1 then
        for i = 1, month - 1 do
            retDay = retDay + monthdays[i]
        end
    end

    if month >= 3 then
        if leapyears1 == 0 then
            if leapyears2 ~= 0 or(leapyears2 == 0 and leapyears3 == 0) then
                retDay = retDay + 1
            end
        end
    end

    local ret =((retDay + day - 1) * 24) + hour
    return ret
end


function SCR_NUMTABLE_STRING(t)
    local ret = ''
    local count = #t
    for i = 1, count do
        ret = ret .. tostring(t[i])
    end

    return ret
end

function IS_WARPNPC(zoneClassName, npcFunc)
    local getTypeIdspace = 'GenType_' .. zoneClassName
    local isMap = GetClassCount(getTypeIdspace)
    if isMap ~= nil and isMap > 0 then
        local dialogIESList = SCR_GET_XML_IES(getTypeIdspace, 'Dialog', npcFunc)
        if dialogIESList ~= nil and #dialogIESList > 0 then
            for i = 1, #dialogIESList do
                if 'Warp_arrow' == dialogIESList[i].ClassType then
                    return 'YES'
                end
            end
        end
        local enterIESList = SCR_GET_XML_IES(getTypeIdspace, 'Enter', npcFunc)
        if enterIESList ~= nil and #enterIESList > 0 then
            for i = 1, #enterIESList do
                if 'Warp_arrow' == enterIESList[i].ClassType then
                    return 'YES'
                end
            end
        end
        local leaveIESList = SCR_GET_XML_IES(getTypeIdspace, 'Leave', npcFunc)
        if leaveIESList ~= nil and #leaveIESList > 0 then
            for i = 1, #leaveIESList do
                if 'Warp_arrow' == leaveIESList[i].ClassType then
                    return 'YES'
                end
            end
        end
    end
    return 'NO'
end

function table.find(t, ele)
    if t ~= nil then
        local count = #t
        if count > 0 then
            for i = 1, count do
                if type(t[i]) ~= type(ele) then
                    if type(t[i]) == 'number' then
                        ele = tonumber(ele)
                    elseif type(t[i]) == 'string' then
                        ele = tostring(ele)
                    end
                end
                if t[i] == ele then
                    return i
                end
            end
        end
    end
    return 0
end

function table.count(t, ele)
    local count = #t
    local ret = 0
    if count > 0 then
        for i = 1, count do
            local eleTemp = ele
            if type(t[i]) ~= type(ele) then
                if type(t[i]) == 'number' then
                    eleTemp = tonumber(ele)
                elseif type(t[i]) == 'string' then
                    eleTemp = tostring(ele)
                end
            end
            if t[i] == eleTemp then
                ret = ret + 1
            end
        end
    end

    return ret
end

function ADD_GQUEST_MULTIPLY(cls, propName, mul)
    if cls[propName] == 1 then
        return mul + 0.5;
    end

    return mul;
end

function GET_GQUEST_POINT(cls, arg)

    local cnt = G_TOTAL_MON_CNT(cls);
    local mul = 1.0;
    mul = ADD_GQUEST_MULTIPLY(cls, "CheckSkill", mul);
    mul = ADD_GQUEST_MULTIPLY(cls, "CheckOverKill", mul);
    mul = ADD_GQUEST_MULTIPLY(cls, "OnlyOverKill", mul);
    mul = ADD_GQUEST_MULTIPLY(cls, "FailByDamage", mul);
    mul = ADD_GQUEST_MULTIPLY(cls, "TimeLimit", mul);
    mul = ADD_GQUEST_MULTIPLY(cls, "OnlyOverKill", mul);

    return(cls.Level * 4 + cnt * 2) * mul;

end



function GET_CLS_GROUP(idSpace, groupName)

    local clsList = GetClassList(idSpace);
    local retList = { };
    if clsList == nil then
        return retList;
    end

    local index = 1;

    while 1 do

        local name = groupName .. "_" .. index;
        local cls = GetClassByNameFromList(clsList, name);
        if cls == nil then
            return retList;
        end

        retList[index] = cls;
        index = index + 1;
    end

end


function GET_MAP_ACHI_NAME(mapName)

    local name = ScpArgMsg("Auto_{Auto_1}_TamSaJa", "Auto_1", mapName);
    local desc = ScpArgMsg("Auto_{Auto_1}_Jiyeogeul_MoDu_TamSaHayeossSeupNiDa.", "Auto_1", mapName);
    local desctitle = name
    -- 임시. 나중에 맵 업적 달성시 보상및 칭호에 대한 데이터 세팅 이루어 지면 바꾸자.
    local reward = "None"
    return desc, name, desctitle, reward;

end

-- 경험치 페널티 (인던 제외) --
function GET_EXP_RATIO(myLevel, monLevel, highLv, monster)
    -- hgihLv : 파티원중 가장 높은 레벨, 파티가 아니거나 1인 파티면 0임
    local pcLv = myLevel;
    local monLv = monLevel;
    local value = 1;

    if monster ~= nil then
        if IsBuffApplied(monster, 'SuperExp') == 'YES' then
            value = 500;
        end
    end

    local standardLevel = 30;
    local levelGap = math.abs(pcLv - monLv);


    if levelGap > standardLevel then
        local penaltyRatio = 0.0;
        if pcLv < monLv then
            penaltyRatio = 0.05;
            -- 고레벨 몬스터 사냥 시 페널티
        else
            penaltyRatio = 0.02;
            -- 저레벨 몬스터 사냥 시 페널티
        end

        local lvRatio = 1 -((levelGap - standardLevel) * penaltyRatio);
        value = value * lvRatio;
    end

    if value < 0 then
        value = 0;
    end

    return value;
end

-- 인던 경험치 페널티 --
function GET_EXP_RATIO_INDUN(myLevel, indunLevel, highLv)
    -- hgihLv : 파티원중 가장 높은 레벨, 파티가 아니거나 1인 파티면 0임
    local pcLv = myLevel;
    local indunLv = indunLevel;
    local value = 1;

    local standardLevel = 80;
    local levelGap = math.abs(pcLv - indunLv);


    if levelGap > standardLevel then
        local penaltyRatio = 0.0;
        if pcLv < indunLv then
            penaltyRatio = 0.05;
            -- 고레벨 몬스터 사냥 시 페널티
        else
            penaltyRatio = 0.05;
            -- 저레벨 몬스터 사냥 시 페널티
        end

        local lvRatio = 1 -((levelGap - standardLevel) * penaltyRatio);
        value = value * lvRatio;
    end

    if value < 0 then
        value = 0;
    end

    return value;
end

function GET_ADD_SPRAY_USE(colCnt, obj)

    local curUsed = obj.RemainAmount;
    local addUse = colCnt % MAX_COLSPRAY_PIXEL();

    local remain = MAX_COLSPRAY_PIXEL() - curUsed - addUse;
    if remain < 0 then
        return 0;
    end

    if remain > GET_SPRAY_REMOVE_AMOUNT() then
        return 0;
    end

    return remain;

end

function GET_TOTAL_SPRAY_PIXEL(cnt, obj)

    local curUse = obj.RemainAmount;
    return cnt * MAX_COLSPRAY_PIXEL() - curUse;

end

function GET_SPRAY_REMOVE_AMOUNT()

    return 50;

end



function IS_GUILDQUEST_CHECK_ITEM(sObj)

    for j = 1, GUILDQUEST_MAX_ITEM do

        local ItemID = sObj["Step" .. j + 4];
        if ItemID > 0 then
            return 1;
        end
    end

    return 0;
end

function IS_GULID_QUEST_ITEM(sObj, itemID)

    for j = 1, GUILDQUEST_MAX_ITEM do
        local reqID = sObj["Step" .. j + 4];
        if reqID == itemID then
            return 1;
        else
            return 0;
        end

    end

    return 0;
end

function REGISTER_XML_CONST(propName, propValue)

    _G[propName] = propValue;

end

function GET_MS_TXT(sec)
    local appTime = imcTime.GetAppTime();
    local m, s = GET_MS(sec);
    local colon = ":";
    if math.fmod(math.floor(appTime * 2.0), 2) == 1 then
        colon = " ";
    end

    return string.format("%02d%s%02d", m, colon, s);
end

function GET_MS(sec)
    if sec < 0 then
        sec = 0;
    end

    local min = 0;
    local s = 0;
    if sec >= 60 then
        min = math.floor(sec / 60);
        s = sec % 60;
    else
        s = sec
    end

    return min, s;
end

function GET_DHMS(sec)

    local day = 0;
    local hour = 0;
    local min = 0;
    local s = 0;
    if sec >= 86400 then
        day = math.floor(sec / 86400);
        sec = sec % 86400;
    end

    if sec >= 3600 then
        hour = math.floor(sec / 3600);
        sec = sec % 3600;
    end

    if sec >= 60 then
        min = math.floor(sec / 60);
        s = sec % 60;
    else
        s = sec
    end

    return day, hour, min, s;

end

function GET_DHMS_STRING(sec)

    if sec < 0 then
        sec = 0;
    end

    local d, h, m, s = GET_DHMS(sec);
    local ret = "";
    if d > 0 then
        ret = ret .. string.format("%02d:", d);
    end
    if h > 0 then
        ret = ret .. string.format("%02d:", h);
    end

    ret = ret .. string.format("%02d:", m);
    ret = ret .. string.format("%02d", s);

    return ret;

end

function SCR_GET_MCY_BUY_PRICE(itemIndex, curValue)

    if itemIndex > 5 then
        return 50;
    end

    return 100;
    -- return 600 + 200 * curValue;

end

function GET_ABIL_LEVEL(self, abilName)

    local abil = GetAbility(self, abilName);
    if abil == nil then
        return 0;
    end

    return abil.Level;

end

function GET_SKILL_LEVEL(self, skillName)

    local skl = GetSkill(self, skillName);
    if skl == nil then
        return 0;
    end

    return skl.Level;

end

function SCR_DIALOG_NPC_ANIM(animName)

    -- control.DestTgtPlayDialogAnim(animName);
    local handle = session.GetTargetHandle();
    movie.PlayAnim(handle, animName, 1.0, 1);

end

-- 공용 라이브러리
--------------------------------------------------------------------------------------
-- 특정 문자를 기준으로 문자열을 잘라 테이블로 반환
function StringSplit(str, delimStr)  
    local _tempStr = str;
    local _result = { };
    local _index = 1;

    if dic ~= nil and type(dic) == "table" then
        _tempStr = dic.getTranslatedStr(str);
    end

    local try_count = 1

    for try_count = 1, 1000 do 
        if _tempStr == nil then
            break
        end

        local _temp = string.find(_tempStr, delimStr);
        if _temp == nil then
            _result[_index] = _tempStr;
            break;
        else
            _result[_index] = string.sub(_tempStr, 0, _temp - 1);
        end

        _tempStr = string.sub(_tempStr, string.len(_result[_index]) + string.len(delimStr) + 1, string.len(_tempStr));
        _index = _index + 1;

        if string.len(_tempStr) <= 0 then
            break;
        end
    end

    if try_count >= 1000 then
        local ret = {}
        if str == nil then
            ret[1] = ''
        else
            ret[1] = str
        end
        return ret
    end 

    return _result;
end


function IS_EQUIP(item)
    return item.ItemType == "Equip";
end

function IS_NEED_APPRAISED_ITEM(item)
    if IS_EQUIP(item) == false then
        return false;
    end

    local isAppraised = TryGetProp(item, 'NeedAppraisal')
    if isAppraised == nil then
        return false;
    end

    if isAppraised == 1 then
        return true;
    end
    return false;
end

function IS_NEED_RANDOM_OPTION_ITEM(item)
    if IS_EQUIP(item) == false then

        return false;
    end

    local isRandomOption = TryGetProp(item, 'NeedRandomOption')
    if isRandomOption == nil then
        return false;
    end

    if isRandomOption == 1 then
        return true;
    end
    return false;
end

function INCR_PROP(self, obj, propName, propValue)

    self[propName] = self[propName] + propValue;
    SetExProp(obj, propName, propValue);

end

function RESTORE_PROP(self, obj, propName)

    local value = GetExProp(obj, propName);
    self[propName] = self[propName] - value;

end


function IsEnableEffigy(self, skill)

    if "NO" == IsBuffApplied(self, "Hexing_Buff") then
        return 0;
    end

    -- 거리 체크하는거 추가해야할듯?
    -- 근데 그럼 성능낭비인디???
    return 1;
end


-- 보스 드랍 리스트 교체 바인딩 함수
function CHANGE_BOSSDROPLIST(self, equipDropList)
    ChangeClassValue(self, 'EquipDropType', equipDropList);
end

function GET_RECIPE_REQITEM_CNT(cls, propname,pc)
    local recipeType = TryGetProp(cls, 'RecipeType', 'None')
    if recipeType == 'None' then
        recipeType = 'Drag'
    end
    
    if recipeType == "Anvil" or recipeType == "Grill" then
        return cls[propname .. "_Cnt"], TryGet(cls, propname .. "_Level");
    elseif recipeType == "Drag" or recipeType == "Upgrade" then        
        return TryGetProp(cls, propname .. "_Cnt", 0), TryGetProp(cls, propname .. "_Level", 0);
    end

    return 0, 0;

end

-- 전직가능 조건체크하는 함수. skilltree.lua ui애드온에서 사용하고 서버에서도 조건체크할때 사용.
function CHECK_CHANGE_JOB_CONDITION(cls, haveJobNameList, haveJobGradeList)

    -- 이미 가지고있는 직업이면 바로 true리턴
    for i = 0, #haveJobNameList do
        if haveJobNameList[i] ~= nil then
            if haveJobNameList[i] == cls.ClassName then
                return true;
            end
        end
    end

    -- 아래는 새로운 직업에대한 조건 체크
    local i = 1;

    while 1 do

        -- 조건체크하는 칼럼이 더 필요하면 xml에서 걍 늘리면됨. ㅇㅋ?
        if GetPropType(cls, "ChangeJobCondition" .. i) == nil then
            break;
        end


        -- ChangeJobCondition이 전부 'None'이면 퀘스트를 통해서 전직하는거임. UI에서는 안보여줌.
        if cls["ChangeJobCondition" .. i] == 'None' then
            return false;
        end


        local sList = StringSplit(cls["ChangeJobCondition" .. i], ";");
        local conditionCount = #sList / 2;
        -- 해당직업 전직조건 체크갯수

        local completeCount = 0;
        -- 전직조건에 몇개나 만족하는지
        for j = 1, conditionCount do
            -- 직업가지고있고 요구레벨보다 높은지 체크
            for n = 0, #haveJobNameList do

                if sList[j * 2 - 1] == haveJobNameList[n] and tonumber(sList[j * 2]) <= tonumber(haveJobGradeList[n]) then
                    completeCount = completeCount + 1;
                end
            end
        end

        -- 전직조건에 모두 만족하면 전직가능하다고 셋팅해줌
        if conditionCount == completeCount then
            return true;
        end

        i = i + 1;
    end

    return false;
end


function GET_2D_DIS(x1, y1, x2, y2)

    if x1 == nil or y1 == nil or x2 == nil or y2 == nil then
        return 0
    end

    local x = x1 - x2
    local y = y1 - y2

    return math.sqrt(x * x + y * y);
end

function NUM_KILO_CHANGE(num)
    local str = ""
    if num >= 1000 then
        while 1 do
            local remain = num % 1000
            if remain >= 100 then
                str = tostring(remain) .. "," .. str
            elseif remain >= 10 then
                str = "0" .. tostring(remain) .. "," .. str
            else
                str = "00" .. tostring(remain) .. "," .. str
            end

            num = math.floor(num / 1000)
            if num < 1000 then
                str = tostring(num) .. "," .. str
                break
            end
        end
    else
        str = tostring(num)
    end
    if string.sub(str, -1) == ',' then
        str = string.sub(str, 1, -2)
    end
    return str
end

function STR_KILO_CHANGE(num)
    local padding = 3 - string.len(num) % 3
    if padding == 3 then
        padding = 0
    end
    for i = 1,padding do
        num = '0' .. num
    end
    num = string.gsub(num,"[0-9][0-9][0-9]",function(w) return w..',' end)
    num = string.sub(num,padding+1,string.len(num) - 1)
    return num
end

function SCR_POSSIBLE_UI_OPEN_CHECK(pc, questIES, subQuestZoneList, chType)
    local ret = "HIDE"
    if questIES.PossibleUI_Notify == 'NO' then
        return ret, subQuestZoneList
    end
    local sobjIES = GET_MAIN_SOBJ();
    local abandonCheck = 'None';
    local fun = _G['QUEST_ABANDON_RESTARTLIST_CHECK']
    if nil ~= fun then
        abandonCheck = fun(questIES, sobjIES)
    end
    local result = SCR_QUEST_CHECK_C(pc, questIES.ClassName)

    local checkZoneList = { }
    local subQuestFlag = 0
    local subQuestNowZone = ''
    local maxLv = 10

    if pc.Lv <= 10 then
        maxLv = 2
    elseif pc.Lv <= 20 then
        maxLv = 3
    elseif pc.Lv <= 30 then
        maxLv = 5
    end

    if questIES.Level >= pc.Lv - 5 and questIES.Level <= pc.Lv + maxLv then
        if pc.Lv < 100 and questIES.QStartZone ~= 'None' and sobjIES.QSTARTZONETYPE ~= 'None' and questIES.QStartZone ~= sobjIES.QSTARTZONETYPE then
            subQuestFlag = 4
        else
            if questIES.StartMapListUI ~= 'None' then
                checkZoneList = SCR_STRING_CUT(questIES.StartMapListUI)
            end
            if table.find(checkZoneList, questIES.StartMap) == 0 then
                checkZoneList[#checkZoneList + 1] = questIES.StartMap
            end
            if subQuestZoneList == nil then
            else
                if #checkZoneList > 0 then
                    for i = 1, #checkZoneList do
                        if table.find(subQuestZoneList, checkZoneList[i]) > 0 then
                            subQuestFlag = 1
                            break
                        end
                    end
                else
                    subQuestFlag = 2
                end
            end

            if subQuestFlag == 0 then
                if questIES.StartMap ~= 'None' then
                    subQuestNowZone = questIES.StartMap
                else
                    subQuestNowZone = checkZoneList[1]
                end
            end
        end
    else
        subQuestFlag = 3
    end

    if subQuestZoneList == nil then
        subQuestZoneList = { }
    end

    local zonecheckFun = _G['LINKZONECHECK'];
    if chType == 'Set2' then
        ret = "OPEN"
        return ret, subQuestZoneList
    elseif (chType == 'ZoneMap' or chType == 'NPCMark') and abandonCheck == 'ABANDON/LIST' then
        ret = "OPEN"
        return ret, subQuestZoneList
    elseif questIES.QuestMode ~= "MAIN" and questIES.QuestMode ~= "KEYITEM" and result == 'POSSIBLE' and(subQuestFlag == 0 or subQuestFlag == 1) then
        ret = "OPEN"
        subQuestZoneList[#subQuestZoneList + 1] = subQuestNowZone
        return ret, subQuestZoneList
    elseif questIES.QuestMode ~= "MAIN" and questIES.QuestMode ~= "KEYITEM" and questIES.Check_QuestCount > 0 and zonecheckFun ~= nil and zonecheckFun(GetZoneName(pc), questIES.StartMap) == 'YES' then
        local sObj = GetSessionObject(pc, "ssn_klapeda")
        local result1 = SCR_QUEST_CHECK_MODULE_QUEST(pc, questIES, sObj)
        if result1 == "YES" then
            ret = "OPEN"
            return ret, subQuestZoneList
        end
    elseif questIES.QuestMode == "MAIN" or questIES.QuestMode == "SUB" or questIES.QuestMode == 'REPEAT' or questIES.PossibleUI_Notify == 'UNCOND' then
        ret = "OPEN"
        return ret, subQuestZoneList
    end

    return ret, subQuestZoneList
end

function SCR_GET_ZONE_FACTION_OBJECT(zoneClassName, factionList, monRankList, respawnTime)
    local zoneGentype = 'GenType_' .. zoneClassName
    local classCount = GetClassCount(zoneGentype)
    local factionList = SCR_STRING_CUT(factionList)
    local monRankList = SCR_STRING_CUT(monRankList)
    local i
    local monList = { }
    for i = 0, classCount - 1 do
        local gentypeIES = GetClassByIndex(zoneGentype, i)
        if gentypeIES ~= nil and table.find(factionList, gentypeIES.Faction) > 0 and gentypeIES.MaxPop > 0 then
            if respawnTime == nil or gentypeIES.RespawnTime <= respawnTime then
                local monIES = GetClass('Monster', gentypeIES.ClassType)
                if monIES ~= nil then
                    local rankFlag = 'YES'
                    if #monRankList > 0 and GetPropType(monIES, 'MonRank') ~= nil and table.find(monRankList, monIES.MonRank) == 0 then
                        rankFlag = 'NO'
                    end
                    if rankFlag == 'YES' then
                        local flag = false
                        if #monList > 0 then
                            for j = 1, #monList do
                                if monList[j][1] == gentypeIES.ClassType then
                                    monList[j][2] = monList[j][2] + gentypeIES.MaxPop
                                    flag = true
                                    break
                                end
                            end
                        end
                        if flag == false then
                            monList[#monList + 1] = { }
                            monList[#monList][1] = gentypeIES.ClassType
                            monList[#monList][2] = gentypeIES.MaxPop
                            monList[#monList][3] = monIES.MonRank
                            monList[#monList][4] = monIES.DropItemList
                        end
                    end
                end
            end
        end
    end

    return monList
end

function GET_COMMA_SEPARATED_STRING(num)
    local stringValue = tostring(num);
    local retStr = stringValue;
    local strLen = string.len(stringValue);
    if strLen > 14 then
        print('Can not use more than 14 digits!');
        return num, "FAIL";
        -- 	retStr = GET_COMMA_SEPARATED_STRING_FOR_HIGH_VALUE(num);
        -- 	return retStr;
    end

    local loop = math.floor((strLen - 1) / 3);
    if loop >= 1 then
        retStr = string.sub(stringValue, -3);
        for i = 1, loop do
            local tempStr = string.sub(stringValue, -3 *(i + 1),(-3 * i) -1);

            retStr = tempStr .. ',' .. retStr;
        end
    end

    return retStr, "SUCCESS";
end

function GET_COMMA_SEPARATED_STRING_FOR_HIGH_VALUE(num)
    local retStr = "";
    local numValue = num;

    for i = 1, 1000 do
        -- 무한루프 방지용 --
        local tempValue = numValue % 1000;
        if string.len(tempValue) < 3 then
            for j = 1, 3 - string.len(tempValue) do
                tempValue = tostring(0 .. tempValue);
            end
        end

        numValue = math.floor(numValue / 1000);

        if retStr == "" then
            retStr = tempValue;
        else
            retStr = tempValue .. ',' .. retStr;
        end

        if numValue < 1000 then
            if numValue == 0 then
                break;
            end

            retStr = numValue .. ',' .. retStr;
            break;
        end
    end

    return retStr, "SUCCESS";
end

-- 이 함수는 이제 사용하지 말 것 --
-- 그래도 혹시 어디서 참조할지 몰라서 남겨두긴 함 --
function GET_COMMAED_STRING(num)    
    -- unsigned long 범위내에서 가능하게 수정함
    if num == nil or num == 'None' then
        return "0";
    end
    local retStr = "";
    if tonumber(num) == nil then
        -- 숫자가 아닌경우 그냥 리턴
        return num;
    end
    num = tonumber(num);
    if num >= 0 then
        retStr = GetCommaedString(num);
    else
        retStr = '-' .. GetCommaedString(- num);
    end
    return retStr;
end

function GET_COMMAED_STRING2(num)
    -- unsigned long 범위내에서 가능하게 수정함
    if num == nil then
        return "0";
    end
    local retStr = "";
    num = tonumber(num);
    if num >= 0 then
        retStr = GetCommaedString(num);
    else
        retStr = '-' .. GetCommaedString(- num);
    end
    return retStr;
end



function GET_NOT_COMMAED_NUMBER(commaedString)
    local retStr = "";
    local strLen = string.len(commaedString);
    local tempStr = commaedString;
    local startIndex, endIndex = string.find(tempStr, ',');
    local noInfinite = 0;

    while startIndex ~= nil do
        retStr = retStr .. string.sub(tempStr, 1, startIndex - 1);
        tempStr = string.sub(tempStr, startIndex + 1, string.len(tempStr));
        startIndex, endIndex = string.find(tempStr, ',');
        noInfinite = noInfinite + 1;

        -- 혹시 모를 무한루프 방지
        if noInfinite >= 10000 then
            break;
        end
    end
    retStr = retStr .. tempStr;
    local retNum = tonumber(retStr);
    if retNum == nil then
        retNum = 0;
    end
    return retNum;
end

function IS_ENABLE_EQUIP_GEM(targetItem, gemType, targetItemInvItem)
    if targetItem == nil or gemType == nil then
        return false;
    end

    local maxSocket = TryGetProp(targetItem, 'MaxSocket');
    if maxSocket < VALID_DUP_GEM_CNT then
        return true;
    end

    local curCnt = 0;
    if targetItemInvItem ~= nil then
        for i = 0, maxSocket - 1 do
            if targetItemInvItem:GetEquipGemID(i) == gemType then
                curCnt = curCnt + 1;
            end
        end
    else
        -- server
        for i = 0, maxSocket - 1 do
            if GetItemSocketInfo(targetItem, i) == gemType then
                curCnt = curCnt + 1;
            end
        end
    end

    if curCnt + 1 > VALID_DUP_GEM_CNT then
        return false;
    end

    return true;
end

function IS_ITEM_IN_LIST(list, item)
    if list == nil or item == nil or #list < 1 then
        return false;
    end

    for i = 1, #list do
        if list[i] == item then
            return true;
        end
    end

    return false;
end


function EXIST_ITEM(list, element)
    if list == nil or #list < 1 then
        return false;
    end
    for i = 1, #list do
        if list[i] == element then
            return true;
        end
    end
    return false;
end

function PUSH_BACK_IF_NOT_EXIST(list, element)
    if EXIST_ITEM(list, element) == true then
        return list;
    end

    list[#list + 1] = element;
    return list;
end

function SCR_REINFORCE_COUPON()
    local couponList = { 'Event_Reinforce_100000coupon', 'Event_Reinforce_100000coupon_Event'}
    return couponList
end

function SCR_REINFORCE_COUPON_PRECHECK(pc, price, moruItem, target_item)
    local retCouponList = { };
    local couponList = SCR_REINFORCE_COUPON()
    local couponValueList = { }
    
    if is_goddess_moru(moruItem) == true or TryGetProp(target_item, 'StringArg', 'None') == 'Moru_goddess' then    
        return price, retCouponList
    end

    for i = 1, #couponList do
        local itemIES = GetClass('Item', couponList[i])
        if itemIES ~= nil then
            local value = TryGetProp(itemIES, 'NumberArg1')
            if value ~= nil then
                local itemCount = GetInvItemCount(pc, couponList[i])
                if itemCount > 0 then
                    couponValueList[#couponValueList + 1] = { couponList[i], value, itemCount }
                end
            end
        end
    end

    for i = 1, #couponValueList - 1 do
        for x = i + 1, #couponValueList do
            if couponValueList[i][2] < couponValueList[x][2] then
                local temp = { couponValueList[i][1], couponValueList[i][2], couponValueList[i][3] }
                couponValueList[i] = { couponValueList[x][1], couponValueList[x][2], couponValueList[x][3] }
                couponValueList[x] = temp
            end
        end
    end
    if #couponValueList > 0 then
        for i = 1, #couponValueList do
            for x = 1, couponValueList[i][3] do
                if price >= couponValueList[i][2] then
                    price = price - couponValueList[i][2]
                    if #retCouponList > 0 then
                        local flag = 0
                        for y = 1, #retCouponList do
                            if retCouponList[y][1] == couponValueList[i][1] then
                                retCouponList[y][3] = retCouponList[y][3] + 1
                                flag = 1
                                break
                            end
                        end
                        if flag == 0 then
                            retCouponList[#retCouponList + 1] = { couponValueList[i][1], couponValueList[i][2], 1 }
                        end
                    else
                        retCouponList[#retCouponList + 1] = { couponValueList[i][1], couponValueList[i][2], 1 }
                    end
                end
            end
        end
    end

    return price, retCouponList
end

----EVENT_1804_TRANSCEND_REINFORCE
-- function SCR_EVENT_REINFORCE_DISCOUNT_CHECK(pc)
--    if GetServerNation() ~= "KOR" then
--        return 'NO'
--    end
--
--    local now_time = os.date('*t')
--    local year = now_time['year']
--    local month = now_time['month']
--    local day = now_time['day']
--
--    if IsServerSection(pc) ~= 1 then
--        local serverTime = imcTime.GetCurdateNumber()
--        year = 2000 + tonumber(string.sub(serverTime,1, 2))
--        month = tonumber(string.sub(serverTime,3, 4))
--        day = tonumber(string.sub(serverTime,5, 6))
--    end
--
--    local nowbasicyday = SCR_DATE_TO_YDAY_BASIC_2000(year, month, day)
--
--    if nowbasicyday >= SCR_DATE_TO_YDAY_BASIC_2000(2018, 4, 19) and nowbasicyday <= SCR_DATE_TO_YDAY_BASIC_2000(2018, 5, 3) then
--        return 'YES'
--    end
--
--    return 'NO'
-- end



function SCR_TABLE_TYPE_SEPARATE(inputTable, typeTable)
    local index = 1
    local tempTable = { }
    local inputType
    while 1 do
        if index > #inputTable then
            break
        end
        if table.find(typeTable, inputTable[index]) > 0 then
            tempTable[inputTable[index]] = { }
            inputType = inputTable[index]
        elseif inputType ~= nil then
            tempTable[inputType][#tempTable[inputType] + 1] = inputTable[index]
        end

        index = index + 1
    end
    local retTable = { }
    for i = 1, #typeTable do
        retTable[typeTable[i]] = tempTable[typeTable[i]]
    end

    return retTable
end

function IS_IN_EVENT_MAP(pc)
    if GetZoneName(pc) == 'd_castle_agario' then
        return true;
    end

    return false;
end

-- 일반 파티 경험치 계산
function NORMAL_PARTY_EXP_BOUNS_RATE(partyMemberCount, pc)
    -- 1인 100. 2인 190(95), 3인 270(90), 4인 340(85), 5인 400(80)
    -- 대문자로 선언되어있는 변수는 다 sharedconst_system.xml에 있는 값임.
    local expUpRatio = 1;

    -- 파티인원수에 대한 계산
    if partyMemberCount > 1 then
        expUpRatio = expUpRatio +((1 -(partyMemberCount * PARTY_EXP_BONUS)) *(partyMemberCount - 1));
    end

    return expUpRatio;
end

-- 인던 자동매칭 경험치 계산
function INDUN_AUTO_MATCHING_PARTY_EXP_BOUNS_RATE(partyMemberCount)
    -- 한명당 120프로씩 더 준다. 단! 1명일 땐, 경험치 보너스 없다.
    local expUpRatio = NORMAL_PARTY_EXP_BOUNS_RATE(partyMemberCount);

    if partyMemberCount > 1 then
        expUpRatio = expUpRatio +(partyMemberCount * INDUN_AUTO_FIND_EXP_BONUS);
    end

    return expUpRatio;
end

function GET_INDUN_SILVER_RATIO(myLevel, indunLevel)
    local pcLv = myLevel;
    local dungeonLv = indunLevel;
    local value = 1;

    local standardLevel = 30;
    local levelGap = math.abs(pcLv - dungeonLv);

    if levelGap > standardLevel then
        local penaltyRatio = 0.02;
        -- 저레벨 인던 사냥 시 실버 페널티--
        local lvRatio = 1 -((levelGap - standardLevel) * penaltyRatio);
        value = value * lvRatio;
    end

    if value < 0 then
        value = 0;
    end

    return value;
end

function IMCLOG_CONTENT_SPACING(tag, ...)
    local logMsg = "";
    for i, v in ipairs { ...} do
        logMsg = logMsg .. " " .. tostring(v);
    end

    ImcContentLog(tag, logMsg)
end

function GET_DATE_BY_DATE_STRING(dateString)
    -- yyyy-mm-dd hh:mm:ss
    local tIndex = string.find(dateString, ' ');
    if tIndex == nil then
        return -1;
    end
    local dateStr = string.sub(dateString, 0, tIndex - 1);
    local firstHipenIndex = string.find(dateString, '-');
    local secondHipenIndex = string.find(dateString, '-', firstHipenIndex + 1);
    local year = tonumber(string.sub(dateStr, 0, firstHipenIndex - 1));
    local month = tonumber(string.sub(dateStr, firstHipenIndex + 1, secondHipenIndex - 1));
    local day = tonumber(string.sub(dateStr, secondHipenIndex + 1));

    local hourStr = string.sub(dateString, tIndex + 1);
    local firstColonIndex = string.find(hourStr, ':');
    local secondColonIndex = string.find(hourStr, ':', firstColonIndex + 1);
    local hour = tonumber(string.sub(hourStr, 0, firstColonIndex - 1));
    local minute = tonumber(string.sub(hourStr, firstColonIndex + 1, secondColonIndex - 1));
    local second = tonumber(string.sub(hourStr, secondColonIndex + 1));

    return year, month, day, hour, minute, second;
end

function GET_INTERSECT_TABLE_BY_VALUE(table1, table2)
    local hash2 = { };
    for k2, v2 in pairs(table2) do
        hash2[v2] = 1;
    end

    local ret = { };
    for k1, v1 in pairs(table1) do
        if hash2[v1] == 1 then
            ret[#ret + 1] = v1;
            hash2[v1] = nil;
        end
    end
    return ret;
end

function CALC_CENTER_ALIGN_POSITION(index, count, len, dist, bgLen)
    local bgOffset = bgLen / 2;
    local firstOffset =(len * count / 2) + math.floor(count / 2) * dist;
    return bgOffset - firstOffset +(len + dist) *(index - 1);
end 

function CALC_LIST_LINE_BREAK(lvList, maxCol, breakedMaxCol)
    if maxCol < breakedMaxCol then
        return;
    end
    local breakedList = { }
    breakedList[#breakedList + 1] = { }

    local col = 1
    for i = 1, #lvList do
        local remainCount = #lvList - i;
        if col + remainCount > maxCol and col > breakedMaxCol then
            breakedList[#breakedList + 1] = { }
            col = 1;
        else
            col = col + 1
        end
        local curRow = breakedList[#breakedList]
        curRow[#curRow + 1] = lvList[i];
    end

    return breakedList
end

function SCR_MAIN_QUEST_WARP_CHECK(pc, questState, questIES, questName)
    if questName == nil and questIES == nil then
        return 'NO'
    end
    if questIES == nil then
        questIES = GetClass('QuestProgressCheck', questName)
    end

    if questName == nil then
        questName = questIES.ClassName
    end

    if questState == nil then
        if IsServerSection(pc) == 1 then
            questState = SCR_QUEST_CHECK(pc, questName)
        else
            questState = SCR_QUEST_CHECK_C(pc, questName)
        end
    end

    if questState ~= 'POSSIBLE' then
        return 'NO'
    end

    if GetClass('mainquest_startnpcwarp', questName) == nil then
        return 'NO'
    end

    if IsServerSection(pc) ~= 1 and GET_QUESTINFO_PC_FID() ~= 0 then
        return 'NO'
    end

    local sObj
    if IsServerSection(pc) == 1 then
        sObj = GetSessionObject(pc, 'ssn_klapeda')
    else
        pc = GetMyPCObject()
        sObj = GetSessionObject(pc, 'ssn_klapeda')
    end

    if sObj == nil then
        return 'NO'
    end

    local clsList, cnt = GetClassList("mainquest_startnpcwarp");
    for i = 0, cnt - 1 do
        local tQuest = GetClassByIndexFromList(clsList, i);
        local tQuestState
        local preQuestState = {}
        local preQuestStateCheck = {}
        if IsServerSection(pc) == 1 then
            tQuestState = SCR_QUEST_CHECK(pc, tQuest.ClassName)
            if tQuest.CheckQuestName ~= "None" then
                local sList1 = StringSplit(tQuest.CheckQuestName, ';')
                local sList2 = StringSplit(tQuest.CheckQuestState, ';')
                if #sList1 > 0 then
                    for j = 1, #sList1 do
                        preQuestState[#preQuestState+1] = SCR_QUEST_CHECK(pc, sList1[j])
                        preQuestStateCheck[#preQuestStateCheck+1] = sList2[j]
                    end
                end
            end
        else
            if pc.Lv == nil then
                pc = GetMyPCObject()
            end
            tQuestState = SCR_QUEST_CHECK_C(pc, tQuest.ClassName)
            if tQuest.CheckQuestName ~= "None" then
                local sList1 = StringSplit(tQuest.CheckQuestName, ';')
                local sList2 = StringSplit(tQuest.CheckQuestState, ';')
                if #sList1 > 0 then
                    for j = 1, #sList1 do
                        preQuestState[#preQuestState+1] = SCR_QUEST_CHECK_C(pc, sList1[j])
                        preQuestStateCheck[#preQuestStateCheck+1] = sList2[j]
                    end
                end
            end
        end

        if tQuestState == 'POSSIBLE' then
            local tquestIES = GetClass('QuestProgressCheck', tQuest.ClassName)
                if tquestIES.QStartZone ~= 'None' and sObj.QSTARTZONETYPE ~= 'None' and tquestIES.QStartZone ~= sObj.QSTARTZONETYPE then
                elseif tQuest.ClassName == questName then
                if tQuest.CheckQuestName ~= "None" then
                    if #preQuestState > 1 then
                        local flag = 0
                        for j = 1, #preQuestState do
                            if preQuestState[j] == preQuestStateCheck[j] then
                                flag = flag + 1
                            end
                        end
                        if flag > 0 then
                            return 'YES'
                        else
                            return 'NO'
                        end
                    else
                        if preQuestState[1] == preQuestStateCheck[1] then
                    return 'YES'
                        else
                            return 'NO'
                        end
                    end
                else
                    return 'YES'
                end
                elseif tquestIES.QStartZone ~= 'None' and sObj.QSTARTZONETYPE ~= 'None' and tquestIES.QStartZone == sObj.QSTARTZONETYPE then
                    return 'NO'
                end
        end
        if tQuest.ClassName == questName then
            if tQuest.CheckQuestName ~= "None" then
                if #preQuestState > 1 then
                    local flag = 0
                    for j = 1, #preQuestState do
                        if preQuestState[j] == preQuestStateCheck[j] then
                            flag = flag + 1
                        end
                    end
                    if flag > 0 then
                        return 'YES'
            else
                return 'NO'
            end
                else
                    if preQuestState[1] == preQuestStateCheck[1] then
                        return 'YES'
                    else
                        return 'NO'
                    end
        end
--                if preQuestState == preQuestStateCheck then
--                print(questName, tQuest.ClassName, 'in')
--                    return 'YES'
--                else
--                    return 'NO'
--                end
            else
            return 'YES'
        end
    end
    end
    return 'NO'
end

function IS_KANNUSHI_GENDER_CHANGE_FLAG(pc, targetJobClassName)
    if pc == nil then
        return 'NO'
    end

    local jobclass = 'Char4_18'

    if IsServerSection(pc) == 1 then
        local pcEtc = GetETCObject(pc)
        if targetJobClassName == jobclass then
            return 'YES'
        end
    else
        local myPCetc = GetMyEtcObject();
        if targetJobClassName == jobclass then
            return 'YES'
        end
    end

    return 'NO'
end



function SCR_ZONE_KEYWORD_CHECK(zoneName, keyword)
    if zoneName == nil or keyword == nil then
        return "NO";
    end

    local mapClass = GetClass("Map", zoneName);
    local mapKeyWord = TryGetProp(mapClass, "Keyword", "None");
    if mapKeyWord == "None" or mapKeyWord == "" then
        return "NO";
    end

    local keyWordList = SCR_STRING_CUT(mapKeyWord, ";");
    if keyWordList ~= nil and #keyWordList >= 1 then
        local index = table.find(keyWordList, keyword);
        if index ~= 0 then
            return "YES";
        end
    end

    return 'NO';
end

function SCR_CHECK_MONSTER_KEYWORD(mon, keyword)
    if keyword == nil then
        return "NO"
    end

    local monKeyword = TryGetProp(mon, "Keyword", "None");
    if monKeyword == "None" or monKeyword == "" then
        return "NO";
    end

    local keywordList = SCR_STRING_CUT(monKeyword, ";");
    if keywordList ~= nil and #keywordList >= 1 then
        local index = table.find(keywordList, keyword);
        if index ~= 0 then
            return "YES";
        end
    end

    return "NO";
end

function SCR_GET_MONSTER_KEYWORD(mon)
    local monKeyword = TryGetProp(mon, "Keyword", "None");
    if monKeyword == "None" or monKeyword == "" then
        return nil;
    end

    local keywordList = SCR_STRING_CUT(monKeyword, ";");

    return keywordList;
end


function SCR_DATE_HOUR_TO_YWEEK2_BASIC_2000(yy, mm, dd, hour, firstWday, firstHour, secondWday, secondHour)
    local yday2000 = SCR_DATE_TO_YDAY_BASIC_2000(yy, mm, dd)
    local accDay1 = yday2000
    local accDay2 = yday2000

    if hour < firstHour then
        accDay1 = accDay1 - 1
    end

    if hour < secondHour then
        accDay2 = accDay2 - 1
    end

    local result = 0
    local result1 = math.floor((accDay1 + 6 - firstWday) / 7) + 1
    local result2 = math.floor((accDay2 + 6 - secondWday) / 7) + 1

    if result1 > result2 then
        result = result2 * 2
    elseif result1 == result2 then
        result = result2 * 2 - 1
    end

    return result
end


function JOB_NAKMUAY_PRE_CHECK(pc, jobCount)
    if jobCount == nil then
        jobCount = GetTotalJobCount(pc);
    end
    if jobCount >= 2 then
        local pcEtc
        if IsServerSection() == 0 then
            pcEtc = GetMyEtcObject();
        else
            pcEtc = GetETCObject(pc);
        end

        if pcEtc ~= nil then
            local value = TryGetProp(pcEtc, 'HiddenJob_Char1_20', 0)
            if value == 300 or IS_KOR_TEST_SERVER() == true then
                return 'YES'
            end
        end
    end

    return 'NO'
end

function JOB_LUCHADOR_PRE_CHECK(pc, jobCount)

        local aObj
        if IsServerSection() == 0 then
            aObj = GetMyAccountObj();
        else
            aObj = GetAccountObj(pc);
        end
        
        if aObj ~= nil then
            local value = TryGetProp(aObj, 'UnlockQuest_Char1_23', 0)
            if value == 1 or IS_KOR_TEST_SERVER() == true then
                return 'YES'
            end
        end

    return 'NO'
end

function JOB_HWARANG_PRE_CHECK(pc, jobCount)

    local aObj
    if IsServerSection() == 0 then
        aObj = GetMyAccountObj();
    else
        aObj = GetAccountObj(pc);
    end
    
    if aObj ~= nil then
        local value = TryGetProp(aObj, 'UnlockQuest_Char3_22', 0)
        if value == 1 or IS_KOR_TEST_SERVER() == true then
            return 'YES'
        end
    end

    return 'NO'
end

function JOB_KERAUNOS_PRE_CHECK(pc, jobCount)

    local aObj
    if IsServerSection() == 0 then
        aObj = GetMyAccountObj();
    else
        aObj = GetAccountObj(pc);
    end
    
    if aObj ~= nil then
        local value = TryGetProp(aObj, 'UnlockQuest_Char2_24', 0)
        if value == 1 or IS_KOR_TEST_SERVER() == true then
            return 'YES'
        end
    end

    return 'NO'
end

function JOB_LAMA_PRE_CHECK(pc, jobCount)
    if jobCount == nil then
        jobCount = GetTotalJobCount(pc);
    end
    if jobCount >= 2 then
        local aObj
        if IsServerSection() == 0 then
            aObj = GetMyAccountObj();
        else
            aObj = GetAccountObj(pc);
        end
        
        if aObj ~= nil then
            local value = TryGetProp(aObj, 'UnlockQuest_Char4_22', 0)
            if value == 1 or IS_KOR_TEST_SERVER() == true then
                return 'YES'
            end
        end
    end

    return 'NO'
end

function JOB_Pontifex_PRE_CHECK(pc, jobCount)    
    local aObj = nil
    if IsServerSection() == 0 then
        aObj = GetMyAccountObj();
    else
        aObj = GetAccountObj(pc);
    end
    
    if aObj ~= nil then
        local value = TryGetProp(aObj, 'UnlockQuest_Char4_23', 0)
        if value == 1 then
            return 'YES'
        end
    end

    return 'NO'
end

function JOB_JAGUAR_PRE_CHECK(pc, jobCount)
    if jobCount == nil then
        jobCount = GetTotalJobCount(pc);
    end
    if jobCount >= 2 then
        local aObj
        if IsServerSection() == 0 then
            aObj = GetMyAccountObj();
        else
            aObj = GetAccountObj(pc);
        end
        
        if aObj ~= nil then
            local value = TryGetProp(aObj, 'UnlockQuest_Char5_18', 0)
            if value == 1 or IS_KOR_TEST_SERVER() == true then
                return 'YES'
            end
        end 
    end

    return 'NO'
end

function JOB_DESPERADO_PRE_CHECK(pc, jobCount)
    local aObj = nil
    if IsServerSection() == 0 then
        aObj = GetMyAccountObj();
    else
        aObj = GetAccountObj(pc);
    end
    
    if aObj ~= nil then
        local value = TryGetProp(aObj, 'UnlockQuest_Char5_19', 0)
        if value == 1 then
            return 'YES'
        end
    end

    return 'NO'
end

function JOB_ILLUSIONIST_PRE_CHECK(pc, jobCount)
    local aObj = nil
    if IsServerSection() == 0 then
        aObj = GetMyAccountObj();
    else
        aObj = GetAccountObj(pc);
    end
    
    if aObj ~= nil then
        local value = TryGetProp(aObj, 'UnlockQuest_Char2_25', 0)
        if value == 1 then
            return 'YES'
        end
    end

    return 'NO'
end

function JOB_VULTURE_W_PRE_CHECK(pc, jobCount)
    local aObj = nil
    if IsServerSection() == 0 then
        aObj = GetMyAccountObj();
    else
        aObj = GetAccountObj(pc);
    end
    
    if aObj ~= nil then
        local value = TryGetProp(aObj, 'UnlockQuest_Char2_26', 0)
        if value == 1 then
            return 'YES'
        end
    end

    return 'NO'
end

function JOB_VULTURE_A_PRE_CHECK(pc, jobCount)
    local aObj = nil
    if IsServerSection() == 0 then
        aObj = GetMyAccountObj();
    else
        aObj = GetAccountObj(pc);
    end
    
    if aObj ~= nil then
        local value = TryGetProp(aObj, 'UnlockQuest_Char3_25', 0)
        if value == 1 then
            return 'YES'
        end
    end

    return 'NO'
end

function JOB_VULTURE_T_PRE_CHECK(pc, jobCount)
    local aObj = nil
    if IsServerSection() == 0 then
        aObj = GetMyAccountObj();
    else
        aObj = GetAccountObj(pc);
    end
    
    if aObj ~= nil then
        local value = TryGetProp(aObj, 'UnlockQuest_Char5_20', 0)
        if value == 1 then
            return 'YES'
        end
    end

    return 'NO'
end

function JOB_SLEDGER_C_PRE_CHECK(pc, jobCount)
    local aObj = nil
    if IsServerSection() == 0 then
        aObj = GetMyAccountObj();
    else
        aObj = GetAccountObj(pc);
    end
    
    if aObj ~= nil then
        local value = TryGetProp(aObj, 'UnlockQuest_Char4_24', 0)
        if value == 1 then
            return 'YES'
        end
    end

    return 'NO'
end

function JOB_SLEDGER_S_PRE_CHECK(pc, jobCount)
    local aObj = nil
    if IsServerSection() == 0 then
        aObj = GetMyAccountObj();
    else
        aObj = GetAccountObj(pc);
    end
    
    if aObj ~= nil then
        local value = TryGetProp(aObj, 'UnlockQuest_Char1_27', 0)
        if value == 1 then
            return 'YES'
        end
    end

    return 'NO'
end

function JOB_BONEMANCER_S_PRE_CHECK(pc, jobCount)
    local aObj = nil
    if IsServerSection() == 0 then
        aObj = GetMyAccountObj();
    else
        aObj = GetAccountObj(pc);
    end
    
    if aObj ~= nil then
        local value = TryGetProp(aObj, 'UnlockQuest_Char1_28', 0)
        if value == 1 then
            return 'YES'
        end
    end

    return 'NO'
end

function JOB_BONEMANCER_A_PRE_CHECK(pc, jobCount)
    local aObj = nil
    if IsServerSection() == 0 then
        aObj = GetMyAccountObj();
    else
        aObj = GetAccountObj(pc);
    end
    
    if aObj ~= nil then
        local value = TryGetProp(aObj, 'UnlockQuest_Char3_26', 0)
        if value == 1 then
            return 'YES'
        end
    end

    return 'NO'
end

function JOB_BONEMANCER_C_PRE_CHECK(pc, jobCount)
    local aObj = nil
    if IsServerSection() == 0 then
        aObj = GetMyAccountObj();
    else
        aObj = GetAccountObj(pc);
    end
    
    if aObj ~= nil then
        local value = TryGetProp(aObj, 'UnlockQuest_Char4_25', 0)
        if value == 1 then
            return 'YES'
        end
    end

    return 'NO'
end

function JOB_BONEMANCER_W_PRE_CHECK(pc, jobCount)
    local aObj = nil
    if IsServerSection() == 0 then
        aObj = GetMyAccountObj();
    else
        aObj = GetAccountObj(pc);
    end
    
    if aObj ~= nil then
        local value = TryGetProp(aObj, 'UnlockQuest_Char2_27', 0)
        if value == 1 then
            return 'YES'
        end
    end

    return 'NO'
end

function JOB_BLITZHUNTER_A_PRE_CHECK(pc, jobCount)
    local aObj = nil
    if IsServerSection() == 0 then
        aObj = GetMyAccountObj();
    else
        aObj = GetAccountObj(pc);
    end
    
    if aObj ~= nil then
        local value = TryGetProp(aObj, 'UnlockQuest_Char3_27', 0)
        if value == 1 then
            return 'YES'
        end
    end

    return 'NO'
end

function JOB_BLITZHUNTER_T_PRE_CHECK(pc, jobCount)
    local aObj = nil
    if IsServerSection() == 0 then
        aObj = GetMyAccountObj();
    else
        aObj = GetAccountObj(pc);
    end
    
    if aObj ~= nil then
        local value = TryGetProp(aObj, 'UnlockQuest_Char5_21', 0)
        if value == 1 then
            return 'YES'
        end
    end

    return 'NO'
end

function JOB_AETHERBLADER_C_PRE_CHECK(pc, jobCount)
    local aObj = nil
    if IsServerSection() == 0 then
        aObj = GetMyAccountObj();
    else
        aObj = GetAccountObj(pc);
    end
    
    if aObj ~= nil then
        local value = TryGetProp(aObj, 'UnlockQuest_Char4_26', 0)
        if value == 1 then
            return 'YES'
        end
    end

    return 'NO'
end

function JOB_AETHERBLADER_T_PRE_CHECK(pc, jobCount)
    local aObj = nil
    if IsServerSection() == 0 then
        aObj = GetMyAccountObj();
    else
        aObj = GetAccountObj(pc);
    end
    
    if aObj ~= nil then
        local value = TryGetProp(aObj, 'UnlockQuest_Char5_22', 0)
        if value == 1 then
            return 'YES'
        end
    end

    return 'NO'
end

function JOB_AETHERBLADER_W_PRE_CHECK(pc, jobCount)
    local aObj = nil
    if IsServerSection() == 0 then
        aObj = GetMyAccountObj();
    else
        aObj = GetAccountObj(pc);
    end
    
    if aObj ~= nil then
        local value = TryGetProp(aObj, 'UnlockQuest_Char2_28', 0)
        if value == 1 then
            return 'YES'
        end
    end

    return 'NO'
end

function JOB_HERMIT_W_PRE_CHECK(pc, jobCount)
    local aObj = nil
    if IsServerSection() == 0 then
        aObj = GetMyAccountObj();
    else
        aObj = GetAccountObj(pc);
    end
    
    if aObj ~= nil then
        local value = TryGetProp(aObj, 'UnlockQuest_Char2_29', 0)
        if value == 1 then
            return 'YES'
        end
    end

    return 'NO'
end

function JOB_HERMIT_C_PRE_CHECK(pc, jobCount)
    local aObj = nil
    if IsServerSection() == 0 then
        aObj = GetMyAccountObj();
    else
        aObj = GetAccountObj(pc);
    end
    
    if aObj ~= nil then
        local value = TryGetProp(aObj, 'UnlockQuest_Char4_27', 0)
        if value == 1 then
            return 'YES'
        end
    end

    return 'NO'
end

function JOB_SPEARMASTER_PRE_CHECK(pc, jobCount)
    local aObj
    if IsServerSection() == 0 then
        aObj = GetMyAccountObj();
    else
        aObj = GetAccountObj(pc);
    end
    
    if aObj ~= nil then
        local value = TryGetProp(aObj, 'UnlockQuest_Char1_24', 0)
        if value == 1 or IS_KOR_TEST_SERVER() == true then
            return 'YES'
        end
    end

    return 'NO'
end

function JOB_ENGINEER_PRE_CHECK(pc, jobCount)
    local aObj
    local nation = 'None'
    if IsServerSection() == 0 then
        aObj = GetMyAccountObj();
        nation = config.GetServiceNation()
    else
        aObj = GetAccountObj(pc);
        nation = GetServerNation()
    end
    
    if aObj ~= nil then
        if nation == 'PAPAYA' then
            local start = '2023-07-18 18:00:00'
            local finish = '2023-08-01 18:00:00'
            if date_time.is_between_time(start, finish) == true then
                return 'YES'
            end
        end

        local value = TryGetProp(aObj, 'UnlockQuest_Char3_23', 0)
        if value == 1 or IS_KOR_TEST_SERVER() == true then
            return 'YES'
        end
    end

    return 'NO'
end


function JOB_RUNECASTER_PRE_CHECK(pc, jobCount)
    if jobCount == nil then
        jobCount = GetTotalJobCount(pc);
    end
    if jobCount >= 2 then
        local pcEtc
        if IsServerSection() == 0 then
            pcEtc = GetMyEtcObject();
        else
            pcEtc = GetETCObject(pc);
        end

        if pcEtc ~= nil then
            local value = TryGetProp(pcEtc, 'HiddenJob_Char2_17', 0)
            if value == 300 or IS_KOR_TEST_SERVER() == true then
                return 'YES'
            end
        end
    end

    return 'NO';
end


function JOB_APPRAISER_PRE_CHECK(pc, jobCount)
    if jobCount == nil then
        jobCount = GetTotalJobCount(pc);
    end
    if jobCount >= 2 then
        local pcEtc
        if IsServerSection() == 0 then
            pcEtc = GetMyEtcObject();
        else
            pcEtc = GetETCObject(pc);
        end

        if pcEtc ~= nil then
            local value = TryGetProp(pcEtc, 'HiddenJob_Char3_13', 0)
            if value == 300 or IS_KOR_TEST_SERVER() == true then
                return 'YES'
            end
        end
    end

    return 'NO'
end


function JOB_MIKO_PRE_CHECK(pc, jobCount)
    if jobCount == nil then
        jobCount = GetTotalJobCount(pc);
    end
    if jobCount >= 2 then
        local pcEtc
        if IsServerSection() == 0 then
            pcEtc = GetMyEtcObject();
        else
            pcEtc = GetETCObject(pc);
        end

        if pcEtc ~= nil then
            local value = TryGetProp(pcEtc, 'HiddenJob_Char4_18', 0)
            if value == 300 or IS_KOR_TEST_SERVER() == true then
                return 'YES'
            end
        end
    end

    return 'NO'
end


function JOB_SHINOBI_PRE_CHECK(pc, jobCount)
    if jobCount == nil then
        jobCount = GetTotalJobCount(pc);
    end
    if jobCount >= 2 then
        local pcEtc
        if IsServerSection() == 0 then
            pcEtc = GetMyEtcObject();
        else
            pcEtc = GetETCObject(pc);
        end

        if pcEtc ~= nil then
            local value = TryGetProp(pcEtc, 'HiddenJob_Char5_6', 0)
            if value == 300 or IS_KOR_TEST_SERVER() == true then
                return 'YES'
            end
        end
    end

    return 'NO'
end

function JOB_WingedHussars_PRE_CHECK(pc, jobCount)
    local aObj = nil
    if IsServerSection() == 0 then
        aObj = GetMyAccountObj();
    else
        aObj = GetAccountObj(pc);
    end
    
    if aObj ~= nil then
        local value = TryGetProp(aObj, 'UnlockQuest_Char1_25', 0)
        if value == 1 then
            return 'YES'
        end
    end

    return 'NO'
end

function JOB_Vanquisher_PRE_CHECK(pc, jobCount)
    local aObj = nil
    if IsServerSection() == 0 then
        aObj = GetMyAccountObj();
    else
        aObj = GetAccountObj(pc);
    end
    
    if aObj ~= nil then
        local value = TryGetProp(aObj, 'UnlockQuest_Char1_26', 0)
        if value == 1 then
            return 'YES'
        end
    end

    return 'NO'
end

function JOB_BowMaster_PRE_CHECK(pc, jobCount)
    local aObj = nil
    if IsServerSection() == 0 then
        aObj = GetMyAccountObj();
    else
        aObj = GetAccountObj(pc);
    end
    
    if aObj ~= nil then
        local value = TryGetProp(aObj, 'UnlockQuest_Char3_24', 0)
        if value == 1 then
            return 'YES'
        end
    end

    return 'NO'
end

function GET_ACCOUNT_WAREHOUSE_EXTEND_PRICE(aObj, taxRate)
    local slotDiff = aObj.AccountWareHouseExtend;
    local price = ACCOUNT_WAREHOUSE_EXTEND_PRICE;
    if slotDiff > 0 then
        if slotDiff >= tonumber(ACCOUNT_WAREHOUSE_MAX_EXTEND_COUNT) then
            return;
        end
        if slotDiff < 4 then
            price = price *(math.pow(2, slotDiff))
        else
            -- Form the fifth slot, it will be fixde at 2000000 silver
            price = price * 10
        end
    end

    if taxRate ~= nil then
        price = tonumber(CALC_PRICE_WITH_TAX_RATE(price, taxRate))
    end
    return price
end

function GET_COMPANION_PRICE(petCls, pc, taxRate)
    if petCls.SellPrice == "None" then
        return nil
    end

    local sellPrice = _G[petCls.SellPrice];
    sellPrice = sellPrice(petCls, pc);
    if taxRate ~= nil then
        sellPrice = tonumber(CALC_PRICE_WITH_TAX_RATE(sellPrice, taxRate))
    end
    return sellPrice
end

-- function JOB_CANNONEER_PRE_CHECK(pc, jobCount)
--    if jobCount == nil then
--        jobCount = GetTotalJobCount(pc);
--    end
-- if jobCount >= 2 then
--        return 'YES';
--    end
--
--    return 'NO';
-- end
--
--
-- function JOB_MUSKETEER_PRE_CHECK(pc, jobCount)
--    if jobCount == nil then
--        jobCount = GetTotalJobCount(pc);
--    end
-- if jobCount >= 2 then
--        return 'YES';
--    end
--
--    return 'NO';
-- end


function GET_TIMESTAMP_TO_COUNTDOWN_DATESTR(timestamp, prop)

    if prop == nil then
        prop = { }
    end

    local day = math.floor(timestamp / 86400)
    local remainder =(timestamp % 86400)
    local hour = math.floor(remainder / 3600)
    local remainder =(timestamp % 3600)
    local min = math.floor(remainder / 60)
    local sec =(remainder % 60)

    local countdownStr = ""

    if prop.noDay == nil then
        if day > 0 then
            countdownStr = countdownStr .. day .. ClMsg("UI_Day") .. " ";
        end
    end

    if prop.noHour == nil then
        if hour > 0 then
            countdownStr = countdownStr .. hour .. ClMsg("UI_Hour") .. " ";
        end
    end

    if prop.noMin == nil then
        if min > 0 then
            countdownStr = countdownStr .. min .. ClMsg("UI_Min") .. " ";
        end
    end

    if prop.noSec == nil then
        if sec > 0 then
            countdownStr = countdownStr .. sec .. ClMsg("UI_Sec") .. " ";
        end
    end

    return countdownStr

end

function GET_MODIFIED_PROPERTIES_STRING(item, invitem)
    local str = GetModifiedPropertiesString(item);
    str = str .. '#';
    if IsServerSection() == 1 then
        local additionalStr = GetAdditionalModifiedString(item);
        if additionalStr ~= nil then
            str = str .. additionalStr;
        end
    else
        local itemIdx = GetIESID(item);
        if invitem == nil then
            invitem = GET_PC_ITEM_BY_GUID(itemIdx);
        end
        str = str .. invitem:GetAdditionalModifiedString();
    end
    return str;
end

function IS_ABILRESET_ITEM(itemClsName)
    local itemCls = GetClass('Item', itemClsName)
    if itemCls ~= nil then
        local strArg = TryGetProp(itemCls, 'StringArg', 'None')
        local numArg1 = TryGetProp(itemCls, 'NumberArg1', -1)
        local numArg2 = TryGetProp(itemCls, 'NumberArg2', -1)
        if strArg == 'AbilityPointReset' and numArg1 == 0 and numArg2 == 0 then
            return true
        end
    end

    return false
end

function IS_ARTSRESET_ITEM(itemClsName)
    local itemCls = GetClass('Item', itemClsName)
    if itemCls ~= nil then
        local strArg = TryGetProp(itemCls, 'StringArg', 'None')
        local numArg1 = TryGetProp(itemCls, 'NumberArg1', -1)
        local numArg2 = TryGetProp(itemCls, 'NumberArg2', -1)
        if strArg == 'AbilityPointReset_Arts' then
            return true
        end
    end

    return false
end

function RANDOM_SHUFFLE(tbl)
    for i = #tbl, 2, -1 do
        local j = math.random(1, i);
        tbl[i], tbl[j] = tbl[j], tbl[i];
    end
    return tbl
end

function CLMSG_DIALOG_CONVERT(npc,msg)
	local name = TranslateDicID(npc.Name):gsub("{nl}"," ")
	return string.format("%s*@*%s",name,msg)
end

function GET_ABILITY_POINT_EXTRACTOR_FEE(type)    
    if IS_SEASON_SERVER() == 'YES' then
        return 0
    end

    if type == 2 then
        -- 특성 포인트 추출 수수료 퍼센트
        return 5;
    end

    return 999999999;
end

function GET_ABILITY_POINT_EXTRACTOR_MIN_VALUE(type)
    if type == 2 then
        -- 특성 포인트 추출 스크롤 교환 최소 개 수
        return 1000;
    end

    return 0;    
end

-- 특성 포인트 추출 스크롤 교환 최소 잔여 포인트
function GET_ABILITY_POINT_EXTRACTOR_MIN_REMAIN_POINT(type)
    if type == 1 then
        return 500000
    elseif type == 2 then
        return 1050000
    end

    return 0;    
end

-- 합성 가능한 스킬젬인지 확인
function CAN_COMPOSITION_SKILL_GEM(item)
    if TryGetProp(item, 'StringArg', 'None') ~= 'SkillGem' then
        return false, 0
    end

    local ret = IS_RANDOM_OPTION_SKILL_GEM(item)
    if ret == true then
        return false, 0
    end

    local level = TryGetProp(item, 'NumberArg1', 0)
    local cls = GetClassByType('item_gem_composition', level)
    if cls == nil then
        return false, 0
    end

    return true, TryGetProp(item, 'NumberArg1', 0)
end

-- 연성 가능한 스킬젬인지 확인
function CAN_UPGRADE_SKILL_GEM(item)
    if TryGetProp(item, 'StringArg', 'None') ~= 'SkillGem' then                
        return false, 0
    end

    local level = TryGetProp(item, 'NumberArg1', 0)    
    local cls = GetClassByType('item_gem_upgrade', level)    
    if cls == nil then                        
        return false, 0
    end

    return true, TryGetProp(item, 'NumberArg1', 0)
end

function GET_SKILL_GEM_CLASS_NAME(item)
    local level = TryGetProp(item, 'NumberArg1', 0)    
    local class_name = TryGetProp(item, 'ClassName', 'None')
    if level == 0 then
        return 'None'
    elseif level == 1 then
        local token = StringSplit(class_name, '_')
        local concate = ''
        local i = 2
        for i = 2, #token do
            if i == #token then
                concate = concate .. token[i]
            else
                concate = concate .. token[i] .. '_'
            end
        end
        return concate
    else
        local i = 3
        for i = 3, #token do
            if i == #token then
                concate = concate .. token[i]
            else
                concate = concate .. token[i] .. '_'
            end
        end
        return concate
    end
end

function EXIST_NEXT_LEVEL_SKILL_GEM(item)
    local name = GET_SKILL_GEM_CLASS_NAME(item)
    if name == 'None' then
        return false
    end

    local class_name = 'GEM_Lv' .. tostring(TryGetProp(item, 'NumberArg1', 0) + 1) .. '_' .. name        
    if skill_gem_class_name_list[TryGetProp(item, 'NumberArg1', 0) + 1][class_name] == nil then   
        return false
    else
        return true
    end
end

function GET_NEXT_LEVEL_SKILL_GEM_CLASS_NAME(item)
    local name = GET_SKILL_GEM_CLASS_NAME(item)    
    if name == '' then
        return 'None'
    end

    local class_name = 'GEM_Lv' .. tostring(TryGetProp(item, 'NumberArg1', 0) + 1) .. '_' .. name
    return class_name
end

function ENABLE_GUILD_MEMBER_JOIN_AUTO(aObj)
    if USE_GUILD_MEMBER_JOIN_AUTO == 0 then
        return false;
    end

    local isJoinedGuild = TryGetProp(aObj, "EVENT_IS_JOINED_GUILD", 0);
    local lastguildOutDay = TryGetProp(aObj, "LastGuildOutDay", "None");
    local limit = TryGetProp(aObj, "GUILD_MEMBER_JOIN_AUTO_LIMIT", 0);
    if isJoinedGuild == 0 and lastguildOutDay == "None" and limit == 0 then
        return true;
    end

    return false;
end

function GET_GUILD_MEMBER_JOIN_AUTO_GUILD_IDX()
    local nation = GetServerNation();
    local groupid = GetServerGroupID();
    return GET_AUTO_MEMBER_JOIN_GUILD_IDX(groupid, nation)      
end

function GET_AUTO_MEMBER_JOIN_GUILD_IDX(groupid, nation)
    -- groupid = tonumber(groupid)

    local str = nation .. '_' .. groupid
    local cls = GetClass("growth_support_guild", str)
    if cls ~= nil then
        return TryGetProp(cls, 'IDX', '0')
    end
    
    -- if nation == "KOR" or nation == 'GLOBAL_KOR' then        
    --     if groupid == 1006 then -- qa
    --         return "518402552627671";
    --     elseif groupid == 9001 then -- 테스트
    --         return "125675038049103";
    --     elseif groupid == 8002 then -- 스테이지
    --         return "347819336532015";
    --     elseif groupid == 1001 then -- 아우슈리네
    --         return "1137006692273513";
    --     elseif groupid == 1002 then -- 바이보라
    --         return "1137058231881971";
    --     elseif groupid == 3002 then
    --         return '1325061835325512'
    --     end
    -- elseif nation == 'GLOBAL' then
    --     if groupid == 1201 then --사내 STM
    --         return '103371272880147'
    --     elseif groupid == 1101 then --사내 JPN_LIVE
    --         return '29025388986425'
	-- 	elseif groupid == 1001 then --아래부턴 라이브
    --         return '506544147923578'
	-- 	elseif groupid == 1003 then 
    --         return '377991481786398'
    --     elseif groupid == 1004 then 
    --         return '693014448046952'
    --     elseif groupid == 1005 then
    --         return '578656648822807' 
    --     end    
    -- elseif nation == 'PAPAYA' then
    --     if groupid == 8001 then --베타 서버
    --         return '559458145009985'
    --     elseif groupid == 1002 then 
    --         return '1612240528618621'
    --     end
    -- end
    return "0";
end

function SCR_IS_LEVEL_DUNGEON(pc)
	if IsServerSection() == 1 then
	    local cmd = GetMGameCmd(pc)
		if cmd == nil then
			return 'NO'
		end
	
	    local mGameName = 'None'
	    if cmd ~= nil then
	        mGameName = cmd:GetMGameName()
	    end
	
		local IndunCls = GetClassByStrProp('Indun', 'MGame', mGameName)
		if IndunCls == nil then
			return 'NO'
		end
	
		local DungeonType
		if IndunCls ~= nil then
			DungeonType = TryGetProp(IndunCls, 'DungeonType', 'None')
		end
	
		if DungeonType == 'Indun' or DungeonType == 'MissionIndun' then
			return 'YES'
		end
	else 
	    local mGameName = session.mgame.GetCurrentMGameName()
		if mGameName == nil or mGameName == 'None' then
			return 'NO'
		end

		local IndunCls = GetClassByStrProp('Indun', 'MGame', mGameName)
		if IndunCls == nil then
			return 'NO'
		end
	
		local DungeonType
		if IndunCls ~= nil then
			DungeonType = TryGetProp(IndunCls, 'DungeonType', 'None')
		end
	
		if DungeonType == 'Indun' or DungeonType == 'MissionIndun' then
			return 'YES'
		end
	end

	return 'NO'
end


function IS_TOS_HERO_ZONE(pc)
	local keyword

	if IsServerSection() == 1 then
		local map = GetMapProperty(pc)
		keyword = TryGetProp(map, "Keyword", "None")
	else
		local mapClassName = session.GetMapName()
		if mapClassName ~= nil then
			local clsList = GetClassList("Map")
			if clsList ~= nil then
				local cls = GetClassByNameFromList(clsList, mapClassName)
				keyword = TryGetProp(cls, "Keyword", "None")
			end
		end
	end

	local split = SCR_STRING_CUT(keyword, ';')
	
	for i = 1, #split do
		if split[i] == 'TOSHero' then
			return 'YES'
		end
	end

	return 'NO'
end

function IS_LEFT_SUBFRAME_ACC(item)
    local str = TryGetProp(item, 'StringArg', 'None')
    local ClsName = TryGetProp(item, 'ClassName', 'None')
    local class_type = TryGetProp(item, 'ClassType', 'None')
    if class_type == 'Ring' or class_type == 'Neck' then        
        if TryGetProp(item, 'ItemGrade', 0) >= 6 then
            return true
        end
    end

    if str == 'Half_Acc_EP12' or str == 'Isdavi' or str == 'Acc_EP12' or (str == 'pvp_Mine' and nil ~= string.find(ClsName, 'PVP_EP12')) then
        return true
    else
        return false
    end
end

-- 테섭 상점용(무조건 100실버로 할 것!)
function GET_FIXEDPRICE(shopName)
	local price = 0

	if string.find(shopName, "Test_Kupole_") ~= nil then return 100 end

	return price
end

function GET_EQUIP_GROUP_NAME(item)
    local name = TryGetProp(item, 'EquipGroup', 'None')

    if name == 'Weapon' or name == 'THWeapon' or name == 'SubWeapon' then
        return 'Weapon'
    end

    if name == 'SHIRT' or name == 'PANTS' or name == 'BOOTS' or name == 'GLOVES' then
        return 'Armor'
    end

    if name == 'Seal' then
        return 'Seal'
    end

    if name == 'Ark' then
        return 'Ark'
    end

    if name == 'Relic' then
        return 'Relic'
    end

    if name == 'Earring' then
        return 'Earring'
    end

    if name == 'BELT' then
        return 'BELT'
    end

    if name == 'SHOULDER' then
        return 'SHOULDER'
    end

    name = TryGetProp(item, 'DefaultEqpSlot', 'None')

    if name == 'NECK' or name == 'RING' then
        return 'Acc'
    end

    if name == 'Core' then
        return 'Core'
    end

    return 'None'
end

-- 각종 워프 기능을 이용 가능한 상태인지 검사. 워프 상점, 스크롤, 귀환석, 토큰 이동, 콘텐츠 현황판 이동 등
function ENABLE_WARP_CHECK(pc)
	if IsBuffApplied(pc, 'BountyHunt_BUFF') == 'YES' then
		return false;
	end

    if IsBuffApplied(pc, 'Buff_GoldMolaMola_Battle') == 'YES' then
        return false
    end

    -- DisableWarp KeywordCheck
    local zone_name = "None";
    if IsServerSection() == 0 then zone_name = GetZoneName();
    else zone_name = GetZoneName(pc); end
    if zone_name ~= "None" then
        local map_class = GetClass("Map", zone_name);
        if map_class ~= nil then
            local keyword = TryGetProp(map_class, "Keyword", "None");
            if keyword ~= "" and keyword ~= "None" then
                local keyword_list = StringSplit(keyword, ';');
                if keyword_list ~= nil and #keyword_list >= 1 then
                    local index = table.find(keyword_list, "DisableWarp");
                    if index ~= 0 then
                        return false;
	end
                end
            end
        end
    end
	return true;
end

function TRIM_STRING_WITH_SPACING(str)
	local words = {}
	str = string.gsub(str,"　","")
	
	for word in str:gmatch("[%w\128-\255]+") do table.insert(words, word) end
	str = ""
	for k,v in pairs(words) do
		str = str..v
		if k ~= #words then
			str = str.." "
		end
	end
	return str
end

function GET_CHAR_COUNT(str)
    str = string.gsub(str," ","")
    local function GetAsciiLen(str)
        local chars = {}
        for char in str:gmatch("[%w\0-\128]") do 
            table.insert(chars, char) 
        end
    
        return #chars
    end
    local asciiLen = GetAsciiLen(str)
    local unicodeLen = (string.len(str) - asciiLen)/3

    return asciiLen + unicodeLen
end

function UQ_GET_JOB_SETTING_JOB(JobClassName) -- job_unlockquest.xml에서 cls를 가져온다
    local JobNumLimt = 1000
    local list, cnt = GetClassList("job_unlockquest")
    if cnt == 0 or cnt == nil then return end
    
    local resultJob = nil
    
    if JobClassName == "ALL" then
        local AllList = {}
            for p  = 0, cnt - 1 do
                local cls = GetClassByIndexFromList(list, p);
                local clsID = TryGetProp(cls, "ClassID", 0)
    
                if clsID >= JobNumLimt then
                    break
                end
    
                if clsID < JobNumLimt then
                    AllList[#AllList + 1] = cls                    
                end
            end    

            return AllList
        end        

    for i  = 0, cnt - 1 do
        local cls = GetClassByIndexFromList(list, i);
        local clsID = TryGetProp(cls, "ClassID", 0)
        local TargetJob = TryGetProp(cls, "TargetJob", "None")
        if clsID >= JobNumLimt then
            break
        end
        if TargetJob == JobClassName then
            resultJob = cls
            return resultJob;
        end
    end
    
    if resultJob == nil then
        return nil;
    end
end

_collection_item_list = nil;
_collection_list_by_item = nil
function make_collection_item_list()
	if _collection_item_list == nil then
        _collection_item_list = {};
        _collection_list_by_item = {}
	end

	local list, cnt = GetClassList("Collection");
	for i = 0, cnt - 1 do
		local cls = GetClassByIndexFromList(list, i);
		if cls ~= nil then
			if TryGetProp(cls, "Journal", "FALSE") == "TRUE" then
				for j = 1, 9 do
					local prop_name = "ItemName_"..tostring(j);
					local name = TryGetProp(cls, prop_name, "None");
					local collection_name = TryGetProp(cls, 'Name', 'None')
					if name ~= "None" then
						_collection_item_list[name] = 1;
						if _collection_list_by_item[name] == nil then
							_collection_list_by_item[name] = {}
						end

						_collection_list_by_item[name][collection_name] = 1
					end
				end
			end
		end
	end
end

make_collection_item_list()

function is_collection_item(class_name)
	if _collection_item_list == nil then
		make_collection_item_list();
	end

	if _collection_item_list[class_name] == nil then return false;
	else return true; end
end

function get_collection_name_by_item(item_name)
    if _collection_item_list == nil then
		make_collection_item_list();
    end
    
    return _collection_list_by_item[item_name]
end

function TUTORIAL_CLEAR_CHECK(pc)
    if true then
        return true
    end

    local etc = nil
    if IsServerSection() == 1 then
        etc = GetETCObject(pc)
    else
        etc = GetMyEtcObject()
    end

    if etc == nil then
        return false
    end

    local sObj = GetSessionObject(pc, 'ssn_klapeda')
    if sObj == nil then
        return false;
    end

    local startLog = TryGetProp(sObj, 'QSTARTZONETYPE', "None")

    if startLog ~= "StartLine3" then
        return true;
    end

    local clear_check = TryGetProp(etc, 'StartLine3_Clear', 0)
    if clear_check < 300 then
        return false
    end

    return true
end

-- 기존 시나리오 퀘스트인지 체크
-- false : 기존 퀘스트
-- true : 신규 
function TUTORIAL_QUEST_EXCEPTION(pc, QuestClassID)
    local quest_ies = GetClass("QuestProgressCheck", QuestClassID)
    local isStartLine3 = TryGetProp(quest_ies, "QStartZone", "None")
    if isStartLine3 == "StartLine3" then
        return true;
    end
    
    return false
end


function TUTORIAL_QUEST_EXCEPTION_BY_TYPE(pc, QuestClassID)
    local quest_ies = GetClassByType("QuestProgressCheck", tonumber(QuestClassID))
    local isStartLine3 = TryGetProp(quest_ies, "QStartZone", "None")
    if isStartLine3 == "StartLine3" then
        return true;
    end

    return false
end

function GET_ITEM_EXPIRE_TIME(item)
    local expire_datetime = TryGetProp(item, 'ExpireDateTime', 'None')
    local expire_time = TryGetProp(item, 'ExpireTime', 'None')
    if expire_datetime ~= 'None' then
        return expire_datetime
    elseif expire_time ~= 'None' then
        return expire_time
    else
        return 'None'
    end
end

function IS_BOUNTY_BATTLE_BUFF_APPLIED(pc)
    if IsBuffApplied(pc, 'BountyHunt_Battle_BUFF') == "YES" then
        return 1;
    end

    return 0;
end

function IS_JUMP_MAP_BUFF_APPLIED(pc)
    if IsBuffApplied(pc, 'EVENT_2105_CAMPING_JUMP') == "YES" then
        return 1;
    end

    return 0;
end

function IS_DEFAULT_COSTUME_LOCK(JobID)
    local jobCls = GetClassByType("Job", JobID);
    local defaultCostume = TryGetProp(jobCls, "DefaultCostume", "None")

    local itemList = session.GetInvItemList();
    local guidList = itemList:GetGuidList();

    if defaultCostume ~= "None" then
        for i = 0, guidList:Count() - 1 do
            local guid = guidList:Get(i);
            local invItem = itemList:GetItemByGuid(guid);
            local itemObj = GetIES(invItem:GetObject());
            if itemObj.ClassName == defaultCostume and invItem.isLockState == true then 
                return 1;
            end
        end
    end

    return 0;
end


function save_json(path, tbl)
	file,err = io.open(path, "w")
	if err then return _,err end

	local s = json.encode(tbl);
	file:write(s);
	file:close();
end

function load_json(path, tblMerge, ignoreError)
	local file, err=io.open(path,"r");
	local t = nil;

	if (err) then
		if (ignoreError) then
			t = {};
		else 
			return _,err
		end
	else
		local content = file:read("*all");
		file:close();
		t = json.decode(content);
	end

	if tblMerge then
		t = merge_left(tblMerge, t)
		save_json(path, t);
	end

	return t;
end

function merge_left(t1, t2)
	for k, v in pairs(t2) do
		if (type(v) == "table") and (type(t1[k] or false) == "table") then
			merge_left(t1[k], t2[k])
		else
			t1[k] = v
		end
	end

	return t1
end

function DELETE_ITEM_OPEN_WARNINGBOX_MSG(itemCls)
	if itemCls.MarketCategory == 'Premium_Costume' and itemCls.StringArg == 'SilverGacha' then
		return 1
	end

	if itemCls.MarketCategory == 'Card_CardLeg' or itemCls.MarketCategory == "Gem_High_Color" then
		return 1
    end
    
    return 0
end

function CONTENTS_ALERT_GET_CUTLINE(contentsID)
    local contents_alert = GetClassByType('contents_alert_table', contentsID)
    local indunInfoName = TryGetProp(contents_alert, "ShowIndunInfo")
    local indunName = TryGetProp(contents_alert, "IndunName", "None")
    local indunCls = GetClass("Indun", indunInfoName)
    if indunCls == nil then
        indunCls = GetClass("Indun", indunName)
    end
    
    local gearScore = TryGetProp(indunCls, "GearScore")
    local level = TryGetProp(indunCls, "Level")
    if gearScore == 0 then
        gearScore = TryGetProp(contents_alert, "GearScore")
    end

    return gearScore, level
end

function IS_DESTROYABLE_COSTUME_ITEM(item)
    local name = TryGetProp(item, 'ClassName', 'None')
    local cls = GetClass('recycle_shop', name)
    if IsServerSection() == 1 then
        if GetServerNation() == "PAPAYA" then
            cls = GetClass('recycle_shop_papaya', name)
        end
    else
        if config.GetServiceNation() == 'PAPAYA' then
            cls = GetClass('recycle_shop_papaya', name)
        end
    end

    if cls ~= nil then
        if TryGetProp(item, 'TeamBelonging', 0) ~= 0 or TryGetProp(item, 'CharacterBelonging', 0) ~= 0 then
            return true
        end
    end

    return false
end

-- 통합 서버 & 시즌 서버 컨텐츠 시간 제한
-- 낚시, 콜로니전
function CHECK_FISHING_AND_COLONY_RESTRICT_TIME(self)
    local time = nil;
    if IsServerSection() == 1 then time = GetDBTime();
    else time = geTime.GetServerSystemTime(); end
    if time ~= nil then
        local month = time.wMonth;
        local day = time.wDay;
        local hour = time.wHour;
        if IS_SEASON_SERVER(self) == "YES" then
            if month == 7 then
                if day >= 18 and day < 28 then
                    return true;
                end
                if day == 28 and hour < 12 then 
                    return true;
                end
            end
        else
            if month == 7 then
                if day >= 4 and day < 14 then
                    return true;
                end
                if day == 14 and hour < 12 then 
                    return true;
                end
            end
        end
    end
    return false;
end

-- 트오세 W 통합 제한 - 봉쇄전
function CHECK_TOSW_BLOCKADE_RESTRICT_TIME(event_id)
    local nation = GetServerNation();

    if CHECK_TOS_WEEKLY_CONTENTS_RESTRICT_TIME() == true then
        return true;
    end

    return false;
end

--미사용
-- 트오세 W - 낚시, 콜로니전
function CHECK_TOSW_FISHING_AND_COLONY_RESTRICT_TIME()
    return false;
end

-- 트오세 W - 낚시, 팀배틀리그
function CHECK_TOSW_FISHING_AND_TBL_RESTRICT_TIME()
    local nation = GET_POPOBOOST_SERVER();
    local start = '2023-02-17 00:00:00';
    local finish = '2023-02-18 10:00:00';

    if nation == 3 then
        start = '2025-07-07 00:00:00';
        finish = '2025-07-15 23:59:59'
    end

    if date_time.is_between_time(start, finish) == true then
        return true;
    end
    return false;
end

-- 트오세 주보레, 봉쇄전, 길드미션 막기
function CHECK_TOS_WEEKLY_CONTENTS_RESTRICT_TIME()
    local nation = GET_POPOBOOST_SERVER();

    local start = '2025-07-01 00:00:00';
    local finish = '2025-07-02 10:00:00';
    if nation == 1 then
        start = '2025-03-03 00:00:00';
        finish = '2025-03-05 10:00:00';
    end

    if nation == 2 then
        start = '2025-03-03 00:00:00';
        finish = '2025-03-11 10:00:00';
end

    if nation == 3 then
        start = '2025-07-01 00:00:00';
        finish = '2025-07-02 10:00:00';    
    end

    if date_time.is_between_time(start, finish) == true then
                    return true;
                end
    return false;
end

-- 트오세 W - 이벤트 제한
function CHECK_TOSW_EVENT_RESTRICT_TIME(indun_class_name)
    local time;
    if IsServerSection() == 1 then
        time = GetDBTime();
    elseif IsServerSection() ~= 1 then
        time = geTime.GetServerSystemTime();
    end

    if indun_class_name ~= "Evnet2023_SnigoDungeon" and indun_class_name ~= "Evnet2024_NewYear" then
        return true;
    end
    
    local TimeCheckFunc = function(day, hour, min, EndDay, EndHour, EndMin)
        if day > EndDay then
            return false;
        elseif day == EndDay then
            if hour > EndHour then
                return false;
            elseif hour == EndHour then
                if min >= EndMin then
                    return false;
                end
                return true;
            end
            return true;
        else
            return true;
        end
    end

    if time ~= nil then
        local year = time.wYear;
        local month = time.wMonth;
        if indun_class_name == "Evnet2023_SnigoDungeon" then
            if year == 2024 and month == 1 then
                local day = time.wDay;
                local hour = time.wHour;
                local min = time.wMin;
                local nation = GetServerNation();
                if nation == "GLOBAL" then
                    local TimeBoolean = TimeCheckFunc(day, hour, min, 22, 6, 0);
                    return TimeBoolean;
                elseif nation == "GLOBAL_JP" then
                    local TimeBoolean = TimeCheckFunc(day, hour, min, 22, 6, 0);
                    return TimeBoolean;
                elseif nation == "GLOBAL_KOR" then
                    local TimeBoolean = TimeCheckFunc(day, hour, min, 22, 6, 0);
                    return TimeBoolean;
                elseif nation =="PAPAYA" then
                    local TimeBoolean = TimeCheckFunc(day, hour, min, 23, 17, 30);
                    return TimeBoolean;
                elseif nation == "TWN" then
                    local TimeBoolean = TimeCheckFunc(day, hour, min, 29, 6, 0);
                    return TimeBoolean;
                end
            end
        elseif indun_class_name == "Evnet2024_NewYear" then
            if year == 2024 and month == 2 then
                local day = time.wDay;
                local hour = time.wHour;
                local min = time.wMin;
                local nation = GetServerNation();
                if nation == "GLOBAL" then
                    local TimeBoolean = TimeCheckFunc(day, hour, min, 5, 6, 0);
                    return TimeBoolean;
                elseif nation == "GLOBAL_JP" then
                    local TimeBoolean = TimeCheckFunc(day, hour, min, 5, 6, 0);
                    return TimeBoolean;
                elseif nation == "GLOBAL_KOR" then
                    local TimeBoolean = TimeCheckFunc(day, hour, min, 5, 6, 0);
                    return TimeBoolean;
                elseif nation =="PAPAYA" then
                    --[[ if day >= 23 then
                        if hour == 17 then
                            if min >= 30 then
                                return false;
                            end
                        elseif hour > 17 then
                            return false;
                        end
                        return true;
                    end ]]
                elseif nation == "TWN" then
                    --[[ if day >= 29 then
                        if hour >= 6 then
                            return false;
                        end
                        return true;
                    end ]]
                end
            end
        end
    end
    return true;
end

-- 사용한 tp 값에 따른 아이템 구입 가능 조건 체크
-- ex) 플레이어의 사용 tp가 0일 때만 살 수 있는 아이템을 구입할 때 현재 플레이어의 사용 tp가 0이 맞으면 true 반환
function IS_USED_MEDAL_CHECK(item, usedTP)
	if item.SubCategory == 'TP_FirstBuy' and usedTP == 0 then
		return true;
	end
	return false;
end

function M_NUMBER_FORMAT(num)    
    num = tonumber(num)
    if num >= 1000000 then
        local n = num / 1000000
        local mod = num % 1000000
        if mod >= 0 then
            n = string.format('%.2f', n)
        end
        
        return n .. 'M'
    end

    return GET_COMMAED_STRING(num)
end

function IS_ABLE_TO_JOIN_GUILD_EVENT(pc, cls)
    local limit = TryGetProp(cls, 'PlayerLv', 0);
    if TryGetProp(cls, "BlockMission", "NO") == "YES" then
        limit = PC_MAX_LEVEL;
    end
    if pc.Lv < limit then
        return false
    else
        return true
    end
end


function GET_BLACK_MARKET_COIN_NAME()
    return SEASON_COIN_NAME 
end

function GET_BLACK_MARKET_RETURN_ITEM_ID()
-- CertificateCoin_1000000p
    return 1000000, '11201238'  -- 뒤에서 부터 1번    
end

-- client only
function _GET_SORTED_CONSUME_ITEM_LIST(item_list, need_count)
    local now_count = 0

    local take_item = {}
    local index = 2
    for i = 1, #item_list do
        local name = item_list[i]
        local count = session.GetInvItemByName(name)
        local remain_count = need_count - now_count
        count = math.min(remain_count, count)
        take_item[name] = count
        now_count = now_count + count
        if now_count >= need_count then            
            break
        end

        index = i
    end
    
    if now_count < need_count then
        local cls = nil
        if index == 1 then
            cls = GetClass('Item', item_list[index])
        else
            cls = GetClass('Item', item_list[index - 1])
        end

        return nil
    end

    local check_count = 0
    for k, v in pairs(take_item) do
        check_count = check_count + v
    end

    if check_count ~= need_count then        
        return nil
    end

    return take_item
end 

function GET_BORUTA_REWARD(event_id)
    local reward = {}
    local nation = config.GetServiceNation()
    local list, cnt = GetClassList('boruta_reward')
    local weekNum = session.boruta_ranking.GetNowWeekNum()
    local max_rank = 0
    for i = 0, cnt - 1 do
        local cls = GetClassByIndexFromList(list, i)
        if cls ~= nil and cls.eventID == event_id and cls.Nation == nation then
            local start = TryGetProp(cls, 'start_season', 0)
            local end_season = TryGetProp(cls, 'end_season', 0)
            if start <= weekNum and end_season >= weekNum then
                local rank = TryGetProp(cls, 'rank', 0)
                reward[rank] = ''
                if max_rank < rank then
                    max_rank = rank
                end
                for j = 1, 20 do
                    local item_name = TryGetProp(cls, 'item_' .. j, 'None')                    
                    if item_name ~= 'None' then
                        reward[rank] = item_name .. ';' .. reward[rank]
                    else
                        break
                    end
                end
            end
        end
    end
    
    return reward, max_rank
end
