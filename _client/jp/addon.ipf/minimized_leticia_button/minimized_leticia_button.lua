--- 클라에서 레티샤 날짜 가져오기
function C_get_leticia_start_and_end_time()
	local startTime = TryGetProp(GetClassByType('leticia_date', 1), "StartTime", "None")
    local endTime = TryGetProp(GetClassByType('leticia_date', 1), "EndTime", "None")

	return startTime, endTime
end


function MINIMIZED_LETICIA_BUTTON_ON_INIT(addon, frame)
	addon:RegisterMsg('GAME_START', 'MINIMIZED_LETICIA_BUTTON_CHECK')
end

function MINIMIZED_LETICIA_BUTTON_CHECK(frame)
	frame = ui.GetFrame('minimized_leticia_button')
	if frame == nil then return end

	local openLeticiaBtn = GET_CHILD_RECURSIVELY(frame, 'openLeticiaBtn')
	
	if config.GetServiceNation() ~= 'KOR' then
		openLeticiaBtn:SetEnable(0)
		frame:ShowWindow(0)
		return
	end

	local mapprop = session.GetCurrentMapProp()
	local mapCls = GetClassByType("Map", mapprop.type)

    if IS_BEAUTYSHOP_MAP(mapCls) == false then
        frame:ShowWindow(0)
    else
    	frame:ShowWindow(1)
    end

	local time = GET_CHILD_RECURSIVELY(frame, 'time')

	local font = frame:GetUserConfig("TIME_FONT_NOMAL")
	time:SetFormat(font.."%s %s")
	time:ReleaseBlink()

	-- 남은 시간 설정
	MINIMIZED_LETICIA_REMAIN_TIME(frame)
end

function MINIMIZED_LETICIA_REMAIN_TIME(frame)
	local StartTime, EndTime = C_get_leticia_start_and_end_time()

	local getnow = geTime.GetServerSystemTime()
	local nowstr = string.format("%04d-%02d-%02d %02d:%02d:%02d", getnow.wYear, getnow.wMonth, getnow.wDay, getnow.wHour, getnow.wMinute, getnow.wSecond)
	
	local remainsec = date_time.get_diff_sec(EndTime, nowstr)
	local time = GET_CHILD_RECURSIVELY(frame, 'time')

	time:RunUpdateScript("UPDATE_MINIMIZED_LETICIA_REMAIN_TIME", 0.1)

	UPDATE_MINIMIZED_LETICIA_TIME_CTRL(time, remainsec, nowstr, StartTime, EndTime, frame)
end

function UPDATE_MINIMIZED_LETICIA_REMAIN_TIME(ctrl)
	local frame = ui.GetFrame('minimized_leticia_button')
	
	local StartTime, EndTime = C_get_leticia_start_and_end_time()

	local getnow = geTime.GetServerSystemTime()
	local nowstr = string.format("%04d-%02d-%02d %02d:%02d:%02d", getnow.wYear, getnow.wMonth, getnow.wDay, getnow.wHour, getnow.wMinute, getnow.wSecond)


	local remainsec = date_time.get_diff_sec(EndTime, nowstr)
	
	UPDATE_MINIMIZED_LETICIA_TIME_CTRL(ctrl, remainsec, nowstr, StartTime, EndTime, frame)	

	return 1
end

function UPDATE_MINIMIZED_LETICIA_TIME_CTRL(ctrl, remainsec, now, StartTime, EndTime, frame)
	local openLeticiaBtn = GET_CHILD_RECURSIVELY(frame, 'openLeticiaBtn')

	if config.GetServiceNation() ~= 'KOR' then
		openLeticiaBtn:SetEnable(0)
		frame:ShowWindow(0)
		return 0
	end
	
	if StartTime == nil or EndTime == nil or EndTime == nil then
		return 0
	end

	if date_time.is_later_than(now, StartTime) and date_time.is_later_than(EndTime,now) then
		openLeticiaBtn:SetEnable(1)
	else
		openLeticiaBtn:SetEnable(0)
	end

	local Rtxt = GET_CHILD_RECURSIVELY(frame, 'titletxt')
	local SRtxt = ClMsg('leticia_open_remain_time2')

	--레티샤 진행 중 종료까지 남은시간
	local min = math.floor(remainsec/60)
	local sec = math.floor(remainsec%60)
	local hour = math.floor(remainsec/3600)
	local day =  math.floor(remainsec/86400)

	local txt1 = ClMsg("leticia_time_min")
	local txt2 = ClMsg("leticia_time_sec")

	if hour >= 24 then
		min = day
		sec = ""
		txt1 = ClMsg("leticia_time_day")
		txt2 = ""
	end

	if min >= 60 then
		min = hour
		sec = ""
		txt1 = ClMsg("leticia_time_hour")
		txt2 = ""
	end

	-- 레티샤 시작까지 남은 시간
	if date_time.is_later_than(StartTime, now) then
		local open_ready_time = date_time.get_diff_sec(StartTime, now)
		min = math.floor(open_ready_time/60)
		sec = math.floor(open_ready_time%60)
		hour = math.floor(open_ready_time/3600)
		day =  math.floor(open_ready_time/86400)

		txt1 = ClMsg("leticia_time_min")
		txt2 = ClMsg("leticia_time_sec")

		if hour >= 24 then
			min = day
			sec = ""
			txt1 = ""
			txt2 = ClMsg("leticia_time_day")
		end

		if min >= 60 then
			min = hour
			sec = ""
			txt1 = ClMsg("leticia_time_hour")
			txt2 = ""
		end

		SRtxt = ClMsg('leticia_open_remain_time')
	end

	-- 레티샤 종료 후 다음 시작까지 남은시간, 다음 시작일은 다음달 1일로 고정
	if date_time.is_later_than(now, EndTime) then
		local ori_start_time = TryGetProp(GetClassByType('leticia_date', 1), "StartTime", "None")
		local year = string.sub(ori_start_time, 1,4)
		local month = string.sub(ori_start_time, 6,7)
		local month_num = tonumber(month) + 1
		local goal_month;
		local next_year = nil;
		if month_num < 10 then
			goal_month = "0"..tostring(month_num)
		else 	
			goal_month = tostring(month_num)

			if tonumber(goal_month) > 12 then
				goal_month = "01"
				next_year = tostring(tonumber(year) + 1)
				--ori_start_time = string.gsub(ori_start_time, year, next_year)
			end
		end
		-- string.gsub(ori_start_time, month, goal_month)
		if next_year ~= nil then
			 year = next_year; 
		end
		
		local final_goal_time = year.."-"..goal_month.."-01 00:00:00";
		local open_remain_time = date_time.get_diff_sec(final_goal_time, now)
		
		--- 다음달 1일이 되기 전에 xml 날짜 세팅을 해야함
		if open_remain_time < 1 then
			frame:ShowWindow(0)
			return 0
		end
		-------------

		min = math.floor(open_remain_time/60)
		sec = math.floor(open_remain_time%60)
		hour = math.floor(open_remain_time/3600)
		day =  math.floor(open_remain_time/86400)

		txt1 = ClMsg("leticia_time_min")
		txt2 = ClMsg("leticia_time_sec")

		if hour >= 24 then
			min = day
			sec = ""
			txt1 = ""
			txt2 = ClMsg("leticia_time_day")
		end
	
		if min >= 60 then
			min = hour
			sec = ""
			txt1 = ClMsg("leticia_time_hour")
			txt2 = ""
		end
		
		SRtxt = ClMsg('leticia_open_remain_time')
	end

	Rtxt:SetTextByKey('rtxt', SRtxt)
	ctrl:SetTextByKey('min', min..txt1)
	ctrl:SetTextByKey('sec', sec..txt2)
end

function MINIMIZED_LETICIA_BUTTON_CLICK()
	if config.GetServiceNation() ~= 'KOR' then
		return
	end

	LETICIA_CUBE_OPEN()
end