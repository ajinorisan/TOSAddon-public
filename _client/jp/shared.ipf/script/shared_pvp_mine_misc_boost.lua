-- shared_pvp_mine_misc_boost.lua

-- 용병단 증표 부스트

-- 현재 account obj 에 저장되어 있는 시간에 add_sec한 시간을 가져온다. yyyy-mm-dd hh-mm-ss 형태로 반환함
function GET_TIME_PVP_MINE_MISC_END_TIME(acc, add_sec, pc)	
    if IS_SEASON_SERVER(pc) == 'YES' then
        return '2022-07-31 00:00:00'
    end

	local end_time = TryGetProp(acc, 'PVP_MINE_MISC_BOOST_END_DATETIME', 'None')
	
	if end_time == 'None' then
		local now = date_time.get_lua_now_datetime_str()
		local ret = date_time.add_time(now, add_sec)
		return ret
	else
		local expired = PVP_MINE_MISC_BOOST_EXPIRED(pc)
		if expired == true then
			local now = date_time.get_lua_now_datetime_str()
			local ret = date_time.add_time(now, add_sec)
			return ret
		else			
			local ret = date_time.add_time(end_time, add_sec)			
			return ret
		end
	end
end

-- 부스트 버프 시간이 종료되었는가?
function PVP_MINE_MISC_BOOST_EXPIRED(pc)    
    if IS_SEASON_SERVER(pc) == 'YES' then
        return false
    end

    local acc = nil
    if IsServerSection() == 1 then        
        acc = GetAccountObj(pc)
        if acc == nil then return true end    

        local end_time = TryGetProp(acc, 'PVP_MINE_MISC_BOOST_END_DATETIME', 'None')
        if end_time == 'None' then
            return true
        end

        local now = date_time.get_lua_now_datetime_str()
        local ret = date_time.is_later_than(now, end_time)	
        return ret
    else        
        acc = GetMyAccountObj()
        if acc == nil then return true end
        local end_time = TryGetProp(acc, 'PVP_MINE_MISC_BOOST_END_DATETIME', 'None')
        if end_time == 'None' then
            return true
        end

        local serverTime = geTime.GetServerSystemTime()
        local now = string.format("%04d-%02d-%02d %02d:%02d:%02d", serverTime.wYear, serverTime.wMonth, serverTime.wDay, serverTime.wHour, serverTime.wMinute, serverTime.wSecond)
        local ret = date_time.is_later_than(now, end_time)	        
        return ret
    end
end
-- 주간 획득량 최대치
function GET_PVP_MINE_MISC_BOOST_COUNT(pc)
    if pc == nil then
        return 0
    end

    if PVP_MINE_MISC_BOOST_EXPIRED(pc) == true then
        return 0
    end

    return GET_PVP_MINE_MISC_BOOST_COUNT2(pc) -- 10만개 증가
end
function GET_PVP_MINE_MISC_BOOST_COUNT2(pc)
    if IS_SEASON_SERVER(pc) == 'YES' then
        return 200000
    end

    return 100000 -- 10만개 증가
end
-- 각 콘텐츠별 추가 획득량
function GET_ADDITIONAL_DROP_COUNT_PVP_MINE_MISC_BOOST(pc, name)
    if pc == nil then
        return 0
    end

    if PVP_MINE_MISC_BOOST_EXPIRED(pc) == true then
        return 0
    end

    return GET_ADDITIONAL_DROP_COUNT_PVP_MINE_MISC_BOOST2(pc, name)
end

function GET_ADDITIONAL_DROP_COUNT_PVP_MINE_MISC_BOOST2(pc, name)
    if name == 'uphill' then  -- 업힐    
        return 0
    elseif name == 'rift' then -- 차붕
        return 0
    elseif name == 'solo_dun' then -- 베르니케
        return 20000
    elseif name == 'weekly_boss' then -- 주간 보스
        return 76000    
    end

    return 0
end

-- 필드 획득량 비율
function GET_PVP_MINE_MISC_BOOST_FIELD_RATE(pc)
    if pc == nil then
        return 1
    end

    if PVP_MINE_MISC_BOOST_EXPIRED(pc) == true then
        return 1 
    end

    return GET_PVP_MINE_MISC_BOOST_FIELD_RATE2(pc)
end

function GET_PVP_MINE_MISC_BOOST_FIELD_RATE2(pc)    
    return 2 -- 100%증가, 2배
end
