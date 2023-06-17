-- gauge timing straight
function GAUGE_CHARGE_STRAIGHT_ON_INIT(addon, frame)
    addon:RegisterMsg("ESCAPE_PRESSED", "GAUGE_CHARGE_STRAIGHT_CLOSE");
    addon:RegisterMsg("CHARGE_GAUGE_SUCCESS", "GAUGE_CHARGE_STRAIGHT_SUCCESS_EFFECT");
    addon:RegisterMsg("CHARGE_GAUGE_FAIL", "GAUGE_CHARGE_STRAIGHT_FAIL_EFFECT");
    addon:RegisterMsg("CHARGE_GAUGE_FORCE_CANCEL", "GAUGE_CHARGE_STRAIGHT_CLOSE");
end

-- normal
function GAUGE_CHARGE_STRAIGHT_OPEN(frame)
    local gauge = GET_CHILD_RECURSIVELY(frame, "gauge");
    local success_start = gauge:GetSuccessRangeStartPoint();
    local success_end = gauge:GetSuccessRangeEndPoint();
    if success_start ~= 0 and success_end ~= 0 then
        gauge:SetChargeGaugeSuccessRangeSkinName("epicraid_gauge_charging_frame");
        local bg = GET_CHILD_RECURSIVELY(frame, "bg");
        if bg ~= nil then
            local ctrl_set = bg:CreateOrGetControlSet("gauge_help_icon_set", "HELP", 0, 0);
            if ctrl_set ~= nil then
                local gauge_bg = GET_CHILD_RECURSIVELY(frame, "gauge_bg");
                local pivot = (success_start + success_end) * 0.5;
                local offset_x = 15.0;
                local x = ((pivot / 100) * gauge_bg:GetWidth()) + offset_x;
                ctrl_set:SetMargin(x, -10, 0, 0);
                ctrl_set:ShowWindow(1);
            end
        end
    else
        local bg = GET_CHILD_RECURSIVELY(frame, "bg");
        if bg ~= nil then
            local ctrl_set = bg:CreateOrGetControlSet("gauge_help_icon_set", "HELP", 0, 0);
            if ctrl_set ~= nil then
                local gauge_bg = GET_CHILD_RECURSIVELY(frame, "gauge_bg");
                local pivot = (success_start + success_end) * 0.5;
                local x = gauge_bg:GetWidth();
                ctrl_set:SetMargin(x, -10, 0, 0);
                ctrl_set:ShowWindow(1);

                local space_icon = GET_CHILD_RECURSIVELY(ctrl_set, "space_icon");
                if space_icon ~= nil then
                    space_icon:PlayAnimation();
                end
            end
        end
    end
end

function GAUGE_CHARGE_STRAIGHT_CLOSE(frame)
    local bg = GET_CHILD_RECURSIVELY(frame, "bg");
    if bg ~= nil then
        bg:StopUIEffect("charging_gauge_success_effect", true, 0.5);
    end
    local gauge = GET_CHILD_RECURSIVELY(frame, "gauge");
    if gauge ~= nil then
        gauge:ResetGauge();
        gauge:SetColorTone("FFFFFFFF");
        gauge:StopUIEffect("charging_gauge_success_effect", true, 0.5);
    end
    ui.CloseFrame("gauge_timing_straight");
end

function GAUGE_CHARGE_STRAIGHT_SUCCESS_EFFECT(frame, msg, arg_str, arg_num)
    local bg = GET_CHILD_RECURSIVELY(frame, "bg");
    if bg ~= nil then
        bg:PlayUIEffect("UI_success_charge", 7.8, "charging_gauge_success_effect");
    end
end

function GAUGE_CHARGE_STRAIGHT_FAIL_EFFECT(frame, msg, arg_str, arg_num)
    local gauge = GET_CHILD_RECURSIVELY(frame, "gauge");
    if gauge ~= nil then
        gauge:SetColorTone("FFFF0000");
    end
end