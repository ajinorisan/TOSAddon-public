-- shared_engrave_slot_extension.lua

-- 각인 슬록 확장권
-- 현재 account obj 에 저장되어 있는 시간에 add_sec한 시간을 가져온다. yyyy-mm-dd hh-mm-ss 형태로 반환함
function GET_TIME_ENGRAVE_SLOT_EXTENSION_END_TIME(acc, add_sec)
	local end_time = TryGetProp(acc, 'ENGRAVE_SLOT_EXTENSION_END_DATETIME', 'None')
	
	if end_time == 'None' then
		local now = date_time.get_lua_now_datetime_str()
		local ret = date_time.add_time(now, add_sec)
		return ret
	else
		local expired = ENGRAVE_SLOT_EXTENSION_EXPIRED(acc)
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

-- 확장 기간이 종료되었는가?
function ENGRAVE_SLOT_EXTENSION_EXPIRED(acc) 
    -- if IS_SEASON_SERVER(pc) == 'YES' then
    --     return false
    -- end
    
    if IsServerSection() == 1 then
        local end_time = TryGetProp(acc, 'ENGRAVE_SLOT_EXTENSION_END_DATETIME', 'None')
        if end_time == 'None' then
            return true
        end

        local now = date_time.get_lua_now_datetime_str()
        local ret = date_time.is_later_than(now, end_time)	
        return ret
    else        
        local end_time = TryGetProp(acc, 'ENGRAVE_SLOT_EXTENSION_END_DATETIME', 'None')
        if end_time == 'None' then
            return true
        end

        local serverTime = geTime.GetServerSystemTime()
        local now = string.format("%04d-%02d-%02d %02d:%02d:%02d", serverTime.wYear, serverTime.wMonth, serverTime.wDay, serverTime.wHour, serverTime.wMinute, serverTime.wSecond)
        local ret = date_time.is_later_than(now, end_time)	        
        return ret
    end
end

-- 종료까지 남은 시간(초)를 가져옴
function GET_REMAIN_SECOND_ENGRAVE_SLOT_EXTENSION_TIME(acc)    
    local serverTime = geTime.GetServerSystemTime()
    local now = string.format("%04d-%02d-%02d %02d:%02d:%02d", serverTime.wYear, serverTime.wMonth, serverTime.wDay, serverTime.wHour, serverTime.wMinute, serverTime.wSecond)
    local end_time = TryGetProp(acc, 'ENGRAVE_SLOT_EXTENSION_END_DATETIME', 'None')

    if IS_SEASON_SERVER() == 'YES' then
        end_time = '2022-07-31 00:00:00'
    end

    if end_time == 'None' then
        return 0
    end

    if date_time.is_later_than(now, end_time) == true then
        return 0
    else
        local diff = date_time.get_diff_sec(end_time, now)
        return diff
    end
end
