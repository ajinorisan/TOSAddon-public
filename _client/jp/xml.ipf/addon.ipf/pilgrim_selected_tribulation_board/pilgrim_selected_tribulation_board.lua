function PILGRIM_SELECTED_TRIBULATION_BOARD_ON_INIT(addon, frame)
    addon:RegisterMsg("PILGRIM_TRIBULATION_BOARD_START", "PILGRIM_SELECTED_TRIBULATION_BOARD_START");
    addon:RegisterMsg("PILGRIM_TRIBULATION_BOARD_DEAD_COUNT_UPDATE", "PILGRIM_SELECTED_TRIBULATION_BOARD_UPDATE_DEAD_COUNT");
end

function PILGRIM_SELECTED_TRIBULATION_BOARD_START(frame, msg, arg_str, arg_num)
    if frame ~= nil then 
        frame:ShowWindow(1);
        frame:SetUserValue("mgame_name", arg_str);
        PILGRIM_SELECTED_TRIBULATION_BOARD_FILL_ICON(frame);
        PILGRIM_SELECTED_TRIBULATION_BOARD_SET_RAID_TIMER(frame);
    end
end

function PILGRIM_SELECTED_TRIBULATION_BOARD_FILL_ICON(frame)
    if frame ~= nil then
        local mgame_name = frame:GetUserValue("mgame_name");
        local gb = GET_CHILD_RECURSIVELY(frame, "gb");
        if gb ~= nil then
            local start_x = 5;
            local space_x = 5;
            local width = 55;
            local count = session.TribulationSystem.GetSelectedTribulationCount(mgame_name);
            for i = 0, count - 1 do
                local icon = session.TribulationSystem.GetSelectedTribulationIcon(mgame_name, i);
                local name = "tribulation_category_mgame_"..i;
                local ctrl_set = gb:CreateOrGetControlSet("tribulation_category_mgame", name, i * width + (i * space_x), 0);
                if ctrl_set ~= nil then
                    local pic_icon = GET_CHILD_RECURSIVELY(ctrl_set, "pic_category_icon");
                    if pic_icon ~= nil then
                        pic_icon:SetImage(icon);
                        pic_icon:SetTooltipType("tribulation_icon");
                        pic_icon:SetTooltipArg(mgame_name, i);
                    end
                end
            end
        end
    end
end

function PILGRIM_SELECTED_TRIBULATION_BOARD_SET_RAID_TIMER(frame)
    if frame ~= nil then
        local raid_timer_frame = ui.GetFrame("raid_timer");
        if raid_timer_frame ~= nil and raid_timer_frame:IsVisible() == 1 then
            local x = raid_timer_frame:GetX();
            local y = frame:GetY() + frame:GetHeight();
            raid_timer_frame:SetOffset(x, y);
        end
    end
end

function PILGRIM_SELECTED_TRIBULATION_BOARD_UPDATE_DEAD_COUNT(frame, msg, arg_str, arg_num)
    if frame ~= nil then
        local daed_count_text = GET_CHILD_RECURSIVELY(frame, "daed_count_text");
        if daed_count_text ~= nil then
            local msg = ScpArgMsg("PilgrimModeDeadCount", "Count", arg_num);
            daed_count_text:SetTextByKey("value", msg);
        end
    end
end