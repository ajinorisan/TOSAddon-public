-- weeklyboss_result.lua

function WEEKLYBOSS_RESULT_ON_INIT(addon, frame)
    addon:RegisterMsg('WEEKLY_BOSS_RESULT_OPEN', 'WEEKLYBOSS_RESULT_OPEN');
end

function WEEKLYBOSS_RESULT_OPEN(frame, damageMeterFrame)
    frame:ShowWindow(1)
    local now_time = tonumber(damageMeterFrame:GetUserValue('NOW_TIME'))
    local end_time = tonumber(damageMeterFrame:GetUserValue('END_TIME'))
    local remain_time = math.floor(end_time - now_time)
    local fight_time = 420 - remain_time;

    local week_num = WEEKLY_BOSS_RANK_WEEKNUM_NUMBER();
    local mydamage = session.weeklyboss.GetMyDamageInfoToString(week_num);                  -- 도전 1회 최고 점수
    local accumulateDamage = session.weeklyboss.GetWeeklyBossAccumulatedDamage(week_num);   -- 누적 대미지
    local totalDamage = damageMeterFrame:GetUserValue("TOTAL_DAMAGE")

    local timeText = GET_CHILD_RECURSIVELY(frame, "timeText")
    local curDamageText = GET_CHILD_RECURSIVELY(frame, "curDamageText")    
    local topDamageText = GET_CHILD_RECURSIVELY(frame, "topDamageText")
    local totalDamageText = GET_CHILD_RECURSIVELY(frame, "totalDamageText")
    local damageBox = GET_CHILD_RECURSIVELY(frame,"damageBox")

    timeText:SetTextByKey("value", GET_TIME_TXT_TWO_FIGURES(fight_time))
    curDamageText:SetTextByKey("value", GET_COMMAED_STRING(totalDamage))
    if mydamage == '0' then
        topDamageText:SetTextByKey("value", ClMsg("NONE"))
    else
        topDamageText:SetTextByKey("value", GET_COMMAED_STRING(mydamage))
    end
    
    local stageGiveUp = GET_CHILD_RECURSIVELY(damageMeterFrame,'stageGiveUp')
    if stageGiveUp:GetEventScript(ui.LBUTTONUP) ~= "DAMAGE_METER_REQ_GIVEUP" then
        totalDamage = "0"
    end
    totalDamageText:SetTextByKey("value", GET_COMMAED_STRING(SumForBigNumberInt64(accumulateDamage, totalDamage)))
    

    local damage_meter_info = GET_WEEKLYBOSS_DPS_TABLE()
    table.sort(damage_meter_info, function(a,b) return IsGreaterThanForBigNumber(a[2],b[2])==1 end)
    WEEKLYBOSS_DAMAGE_METER_GUAGE(frame,damageBox, damage_meter_info)

    local timeLeftText = GET_CHILD_RECURSIVELY(frame, "timeLeftText")
    local endtime = session.weeklyboss.GetWeeklyBossEndTime();
    local systime = geTime.GetServerSystemTime();
    local difsec = imcTime.GetDifSec(endtime, systime);

    if 0 < difsec then
        local textstr = GET_TIME_TXT_TWO_FIGURES(difsec);
        timeLeftText:SetTextByKey("value", textstr);
        timeLeftText:SetUserValue("REMAINSEC", difsec);
        timeLeftText:SetUserValue("STARTSEC", imcTime.GetAppTime());
        timeLeftText:RunUpdateScript("WEEKLY_BOSS_REMAIN_END_TIME");
    elseif difsec < 0 then
        local textstr = ClMsg("Exit_Raid");
        timeLeftText:SetTextByKey("value", textstr);
        timeLeftText:StopUpdateScript("WEEKLY_BOSS_REMAIN_END_TIME");
    end
end

function WEEKLYBOSS_DAMAGE_METER_GUAGE(frame,groupbox, damage_meter_info_total)
    if #damage_meter_info_total == 0 then
        return
    end
    local maxDamage = damage_meter_info_total[1][2]
    local font = "{@st42b}{ds}{s12}"
    local cnt = math.min(10,#damage_meter_info_total)
    for i = 1, cnt do
        local sklID = damage_meter_info_total[i][1]
        local damage = damage_meter_info_total[i][2]
        local skl = GetClassByType("Skill",sklID)

        if skl ~= nil then
            local ctrlSet = groupbox:GetControlSet('gauge_with_two_text', 'GAUGE_'..i)
            if ctrlSet == nil then
                local height = 17
                ctrlSet = groupbox:CreateControlSet('gauge_with_two_text', 'GAUGE_'..i, 0, (i-1)*height);
            end
            local point = MultForBigNumberInt64(damage,"100")
            point = DivForBigNumberInt64(point,maxDamage)
            local skin = 'gauge_damage_meter_0'..math.min(i,4)
            damage = font..STR_KILO_CHANGE(damage)
            DAMAGE_METER_GAUGE_SET(ctrlSet,font..skl.Name,point,font..damage,skin);
        end
    end
end

function WEEKLYBOSS_RESULT_EXIT(frame, self)
    frame:ShowWindow(0)
    restart.ReqReturn()
end
