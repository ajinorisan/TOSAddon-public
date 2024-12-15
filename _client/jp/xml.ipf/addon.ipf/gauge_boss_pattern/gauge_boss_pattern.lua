function GAUGE_BOSS_PATTERN_ON_INIT(addon, frame)
    addon:RegisterMsg('OPEN_GAUGE_BOSS_PATTERN', 'GAUGE_BOSS_PATTERN_OPEN');
    addon:RegisterMsg('CLOSE_GAUGE_BOSS_PATTERN', 'GAUGE_BOSS_PATTERN_CLOSE');
    addon:RegisterMsg("OPEN_GAUGE_BOSS_PATTERN_BUFF", "GAUAGE_BOSS_PATTERN_OPEN_BY_BUFF");
    addon:RegisterMsg("CLOSE_GAUGE_BOSS_PATTERN_BUFF", "GAUGE_BOSS_PATTERN_CLOSE_BY_BUFF");
end

-- normal
function GAUGE_BOSS_PATTERN_OPEN(frame)
    local gauge = GET_CHILD_RECURSIVELY(frame, 'charge_gauge')
    gauge:SetPoint(0, 100)
end

function GAUGE_BOSS_PATTERN_CLOSE(frame)
end

function UPDATE_GAUGE_BOSS_PATTERN(switch, currentValue, maxValue)
    if switch == 1 then
        if currentValue > maxValue then
            currentValue = maxValue
        end
        ui.OpenFrame('gauge_boss_pattern')
        local frame = ui.GetFrame('gauge_boss_pattern')
        local gauge = GET_CHILD_RECURSIVELY(frame, 'charge_gauge')
        gauge:SetPoint(currentValue, maxValue)
        gauge:SetSkinName("reinforce_gauge");

        local gauge_timer = GET_CHILD_RECURSIVELY(frame, "charge_gauge_timer");
        gauge_timer:ShowWindow(0);
        local gauge_timer_text = GET_CHILD_RECURSIVELY(frame, "charge_gauge_timer_text");
        gauge_timer_text:ShowWindow(0);
    elseif switch == 0 then
        local frame = ui.GetFrame('gauge_boss_pattern')
        if frame ~= nil and frame:IsVisible() == 1 then
            ui.CloseFrame('gauge_boss_pattern')
        end
        
        local gauge_timer = GET_CHILD_RECURSIVELY(frame, "charge_gauge_timer");
        gauge_timer:ShowWindow(0);
        local gauge_timer_text = GET_CHILD_RECURSIVELY(frame, "charge_gauge_timer_text");
        gauge_timer_text:ShowWindow(0);
    end
end

-- buff
function GAUAGE_BOSS_PATTERN_OPEN_BY_BUFF(frame, msg, arg_str, arg_num)
    if frame == nil then return; end
    if msg == "OPEN_GAUGE_BOSS_PATTERN_BUFF" then
        if arg_str ~= "First" then
            ui.OpenFrame("gauge_boss_pattern");
        end
        local gauge = GET_CHILD_RECURSIVELY(frame, "charge_gauge");
        if gauge ~= nil then
            gauge:SetSkinName("reinforce_gauge_green");
            gauge:SetPoint(0, arg_num);
        end

        local gauge_timer = GET_CHILD_RECURSIVELY(frame, "charge_gauge_timer");
        if gauge_timer ~= nil then
            gauge_timer:SetSkinName("reinforce_gauge_green");
        end
    end
end

function GAUGE_BOSS_PATTERN_CLOSE_BY_BUFF(frame, msg, arg_str, arg_num)
    if frame == nil then return; end
    if msg == "CLOSE_GAUGE_BOSS_PATTERN_BUFF" then
        ui.CloseFrame('gauge_boss_pattern');
    end
end

-- buff & timer
function UPDATE_GAUGE_BOSS_PATTERN_BY_BUFF_STACK_AFTER_TIMER(cur_value, max_value, convert_timer)
    if convert_timer == 0 then 
        -- buff
        if cur_value > max_value then
            cur_value = max_value;
        end

        local frame = ui.GetFrame("gauge_boss_pattern");
        if frame ~= nil then
            if frame:IsVisible() == 0 then
                frame:ShowWindow(1);
            end

            local gauge = GET_CHILD_RECURSIVELY(frame, "charge_gauge");
            if gauge ~= nil then
                gauge:ShowWindow(1);
                gauge:SetPoint(cur_value, max_value);
            end
            
            local gauge_timer = GET_CHILD_RECURSIVELY(frame, "charge_gauge_timer");
            if gauge_timer ~= nil then
                gauge_timer:ShowWindow(0);
            end

            local gauge_timer_text = GET_CHILD_RECURSIVELY(frame, "charge_gauge_timer_text");
            if gauge_timer_text ~= nil then
                gauge_timer_text:ShowWindow(0);
            end
        end
    else 
        -- timer
        local frame = ui.GetFrame("gauge_boss_pattern");
        if frame ~= nil then
            if frame:IsVisible() == 0 then
                frame:ShowWindow(1);
            end
            
            local max_time = max_value;
            local cur_time = cur_value;
            local remain_time = max_value - cur_time;
            if remain_time < 0 then
                return;
            end

            local gauge = GET_CHILD_RECURSIVELY(frame, "charge_gauge");
            if gauge ~= nil then
                gauge:ShowWindow(0);
            end

            local gauge_timer = GET_CHILD_RECURSIVELY(frame, "charge_gauge_timer");
            if gauge_timer ~= nil then
                gauge_timer:ShowWindow(1);
                local gauge_timer_text = GET_CHILD_RECURSIVELY(frame, "charge_gauge_timer_text");
                if gauge_timer_text ~= nil then
                    gauge_timer_text:ShowWindow(1);
                    gauge_timer_text:SetTextByKey("min", math.floor(remain_time / 60));
                    gauge_timer_text:SetTextByKey("sec", remain_time % 60);
                    gauge_timer:SetPoint(remain_time, max_time);
                end
            end
        end
    end
end