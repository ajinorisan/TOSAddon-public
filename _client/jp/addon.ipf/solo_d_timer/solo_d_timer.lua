function SOLO_D_TIMER_ON_INIT(addon, frame)
    addon:RegisterMsg('SOLO_D_TIMER_START', 'SOLO_D_TIMER_UI_OPEN');
    addon:RegisterMsg('SOLO_D_TIMER_END', 'SOLO_D_TIMER_END');
    addon:RegisterMsg("SOLO_D_TIMER_TEXT_GAUGE_UPDATE", "SOLO_D_TIMER_UPDATE_TEXT_GAUGE");
end

function SOLO_D_TIMER_UI_OPEN(frame,msg,strArg,numArg)
    frame:ShowWindow(1);
    SOLO_D_TIMER_INIT(frame,strArg,numArg);
end

function SOLO_D_TIMER_INIT(frame,strArg,appTime)
    frame:SetUserValue("NOW_TIME", appTime);
    frame:SetUserValue("END_TIME", appTime + strArg);
    frame:SetUserValue("SET_TIME", strArg);
end

function RUN_SOLO_D_TIMER_UPDATE(frame, totalTime, elapsedTime)
    local now_time = frame:GetUserValue("NOW_TIME");
    frame:SetUserValue("NOW_TIME",now_time + elapsedTime);
    SOLO_D_TIMER_UPDATE(frame);
    return 1;
end

function SOLO_D_TIMER_UPDATE(maxTime, remainTime, waveTime, waveRemainTime, stage)
    local frame = ui.GetFrame("solo_d_timer");
    if frame:IsVisible() == 0 then
        frame:ShowWindow(1);
    end
    
    if remainTime < 0 and waveRemainTime < 0 then
        SOLO_D_TIMER_END(frame);
        return;
    end

    if remainTime > -1 then
        local remaintimeValue = GET_CHILD_RECURSIVELY(frame, "remaintimeValue");
        local remaintimeGauge = GET_CHILD_RECURSIVELY(frame, "remaintimeGauge");
        remaintimeValue:SetTextByKey("min",math.floor(remainTime / 60));
        remaintimeValue:SetTextByKey("sec",remainTime % 60);
        remaintimeGauge:SetPoint(remainTime, maxTime);
    end

    if waveRemainTime > -1 then
        local remaintimeValue2 = GET_CHILD_RECURSIVELY(frame, "remaintimeValue2");
        local remaintimeGauge2 = GET_CHILD_RECURSIVELY(frame, "remaintimeGauge2");
        remaintimeValue2:SetTextByKey("min",math.floor(waveRemainTime / 60));
        remaintimeValue2:SetTextByKey("sec",waveRemainTime % 60);
        remaintimeGauge2:SetPoint(waveRemainTime, waveTime);
    end

    local stageText = GET_CHILD_RECURSIVELY(frame,"stageText")
    stageText:SetTextByKey('stage',stage)
end

function SOLO_D_TIMER_UPDATE_TEXT_GAUGE(frame, msg, argStr)
    local frame = ui.GetFrame("solo_d_timer");
    if frame:IsVisible() == 0 then
        frame:ShowWindow(1);
    end

    local argument_list = StringSplit(argStr, ";");
    local ui_msg = argument_list[1];
    local waveMsg = argument_list[2];
    local current_wave = tonumber(argument_list[3])
    local maxWaveCnt = tonumber(argument_list[4])
    
    local remaintimeText = GET_CHILD_RECURSIVELY(frame, "remaintimeText");
    remaintimeText:SetText(ClMsg(ui_msg));
    
    local remaintimeText2 = GET_CHILD_RECURSIVELY(frame, "remaintimeText2");
    if current_wave > maxWaveCnt then
        remaintimeText2:SetText(ClMsg(waveMsg))
    else
        remaintimeText2:SetText(ScpArgMsg(waveMsg, "wave", current_wave))
    end
end

function SOLO_D_TIMER_UPDATE_BY_SERVER(frame,msg,strArg,numArg)
    frame:SetUserValue('NOW_TIME', numArg);
end

function SOLO_D_TIMER_END(frame,msg,argStr,argNum)
    frame:StopUpdateScript("RAID_TIMER_DPS");
    frame:ShowWindow(0);
end

function SOLO_DD_TIMER_UPDATE_SERVER()
    local frame = ui.Getframe("solo_d_timer");
    if frame:IsVisible() == 0 then
        frame:ShowWindow(1);
    end
end

