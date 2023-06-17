function RAID_TIMER_ON_INIT(addon, frame)
    addon:RegisterMsg('RAID_TIMER_START', 'RAID_TIMER_UI_OPEN');
    addon:RegisterMsg('RAID_TIMER_END', 'RAID_TIMER_END');
    addon:RegisterMsg("RAID_TIMER_TEXT_GAUGE_UPDATE", "RAID_TIMER_UPDATE_TEXT_GAUGE");
    addon:RegisterMsg("RAID_TIMER_DEAD_COUNT_TEXT_UPDATE", "RAID_TIMER_UPDATE_TEXT_DEAD_COUNT");
    addon:RegisterMsg("RAID_TIMER_GIVE_UP_ACTIVE", "RAID_TIMER_UPDATE_GIVE_UP_BTN");
    addon:RegisterMsg("RAID_TIMER_GIVE_UP_UNACTIVE", "RAID_TIMER_UPDATE_GIVE_UP_BTN");
end

function RAID_TIMER_UI_OPEN(frame,msg,strArg,numArg)
    frame:ShowWindow(1);
    RAID_TIMER_INIT(frame,strArg,numArg);
end

function RAID_TIMER_INIT(frame,strArg,appTime)
    frame:SetUserValue("NOW_TIME", appTime);
    frame:SetUserValue("END_TIME", appTime + strArg);
    frame:SetUserValue("SET_TIME", strArg);
end

function RUN_RAID_TIMER_UPDATE(frame, totalTime, elapsedTime)
    local now_time = frame:GetUserValue("NOW_TIME");
    frame:SetUserValue("NOW_TIME",now_time + elapsedTime);
    RAID_TIMER_UPDATE(frame);
    return 1;
end

function RAID_TIMER_UPDATE(set_time, remain_time)
    local frame = ui.GetFrame("raid_timer");
    if frame:IsVisible() == 0 then
        frame:ShowWindow(1);
    end
    
    if remain_time < 0 then
        RAID_TIMER_END(frame);
        return;
    end

    local remaintimeValue = GET_CHILD_RECURSIVELY(frame, "remaintimeValue");
    local remaintimeGauge = GET_CHILD_RECURSIVELY(frame, "remaintimeGauge");
    remaintimeValue:SetTextByKey("min",math.floor(remain_time / 60));
    remaintimeValue:SetTextByKey("sec",remain_time % 60);
    remaintimeGauge:SetPoint(remain_time, set_time);
end

function RAID_TIMER_UPDATE_TEXT_GAUGE(frame, msg, arg_str, arg_num)
    local frame = ui.GetFrame("raid_timer");
    if frame:IsVisible() == 0 then
        frame:ShowWindow(1);
        local deadcountBox = GET_CHILD_RECURSIVELY(frame, "deadcountBox");
        if arg_num <= 0 then
            deadcountBox:ShowWindow(0);
            frame:Resize(frame:GetWidth() - deadcountBox:GetWidth(), frame:GetHeight() - 50);
            frame:Invalidate();
        else
            deadcountBox:ShowWindow(1);
            local deadcountText = GET_CHILD_RECURSIVELY(deadcountBox, "deadcountText");
            deadcountText:SetTextByKey("count", arg_num);
        end
        local giveupBox = GET_CHILD_RECURSIVELY(frame, "giveupBox")
        if giveupBox ~= nil then
            giveupBox:ShowWindow(0);
            local origin_height = tonumber(frame:GetUserConfig("FRAME_ORIGIN_HEIGHT"));
            frame:Resize(frame:GetWidth(), origin_height);
            frame:Invalidate();
        end
    end

    local argument_list = StringSplit(arg_str, ";");
    local ui_msg = argument_list[1];
    local color_str = argument_list[2];

    local remaintimeText = GET_CHILD_RECURSIVELY(frame, "remaintimeText");
    remaintimeText:SetText("{@st42b}{ds}{s14}" .. ClMsg(ui_msg) .. "{/}{/}{/}");

    local remaintimeGauge = GET_CHILD_RECURSIVELY(frame, "remaintimeGauge", "ui::CGauge");
    if color_str == "Yellow" then
        remaintimeGauge:SetSkinName("gauge");
    elseif color_str == "Red" then
        remaintimeGauge:SetSkinName("gauge_red");
    end
end

function RAID_TIMER_UPDATE_TEXT_DEAD_COUNT(frame, msg, arg_str, arg_num)
    if frame == nil then return; end
    if arg_num > 0 then 
        local deadcountBox = GET_CHILD_RECURSIVELY(frame, "deadcountBox");
        local deadcountText = GET_CHILD_RECURSIVELY(deadcountBox, "deadcountText");
        deadcountText:SetTextByKey("count", arg_num);
    end
end

function RAID_TIMER_UPDATE_BY_SERVER(frame,msg,strArg,numArg)
    frame:SetUserValue('NOW_TIME', numArg);
end

function RAID_TIMER_END(frame,msg,argStr,argNum)
    frame:StopUpdateScript("RAID_TIMER_DPS");
    frame:ShowWindow(0);
end

function RAID_TIMER_UPDATE_SERVER()
    local frame = ui.Getframe("raid_timer");
    if frame:IsVisible() == 0 then
        frame:ShowWindow(1);
    end
end

function RAID_TIMER_UPDATE_GIVE_UP_BTN(frame, msg, arg_str, arg_num)
    if frame ~= nil then
        if msg == "RAID_TIMER_GIVE_UP_ACTIVE" then
            local giveupBox = GET_CHILD_RECURSIVELY(frame, "giveupBox")
            if giveupBox ~= nil then
                giveupBox:ShowWindow(1);
                local btn_give_up = GET_CHILD_RECURSIVELY(giveupBox, "btn_give_up");
                if btn_give_up ~= nil then 
                    btn_give_up:SetEnable(1); 
                end
                local add_height = tonumber(frame:GetUserConfig("FRAME_GIVE_UP_BTN_ADD_HEIGHT"));
                frame:Resize(frame:GetWidth(), add_height);
                frame:MoveFrame(frame:GetX() + (btn_give_up:GetWidth() / 2), frame:GetY());
            end
        elseif msg == "RAID_TIMER_GIVE_UP_UNACTIVE" then
            local giveupBox = GET_CHILD_RECURSIVELY(frame, "giveupBox")
            if giveupBox ~= nil then
                local btn_give_up = GET_CHILD_RECURSIVELY(giveupBox, "btn_give_up");
                if btn_give_up ~= nil then
                    btn_give_up:SetEnable(0);
                end
            end
        end
        frame:Invalidate();
    end
end

function RAID_TIMER_GIVE_UP_BTN_SCP(parent, control)
    local cl_msg = ClMsg("WeeklyBoss_GiveUp_MSG");
    local yes_scp = string.format("RAID_TIMER_GIVE_UP_BTN_EXEC()");
    ui.MsgBox(cl_msg, yes_scp, "None");
end

function RAID_TIMER_GIVE_UP_BTN_EXEC()
    geMGame.ReqRaidGiveUp();
end