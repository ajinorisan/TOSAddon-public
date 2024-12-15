function PILGRIM_CLEAR_ON_INIT(addon, frame)
end

function ON_PILGRIM_CLEAR_FILL(indun_name, pilgrim_name, score, play_time, diff_time)
    ui.OpenFrame("fulldark");
    ui.OpenFrame("pilgrim_clear");
    local frame = ui.GetFrame("pilgrim_clear");
    if frame ~= nil then
        local text_indun_name = GET_CHILD_RECURSIVELY(frame, "text_title_clear_indun_name");
        if text_indun_name ~= nil then
            text_indun_name:SetTextByKey("name", indun_name);
        end

        local text_pilgrim_name = GET_CHILD_RECURSIVELY(frame, "text_pilgrim_name");
        if text_pilgrim_name ~= nil then
            text_pilgrim_name:SetTextByKey("name", pilgrim_name);
        end

        local text_total_score = GET_CHILD_RECURSIVELY(frame, "text_total_score");
        if text_total_score ~= nil then
            text_total_score:SetTextByKey("score", score);
        end

        local text_play_time = GET_CHILD_RECURSIVELY(frame, "text_play_time");
        if text_play_time ~= nil then
            local play_time_hour = math.floor((play_time / (60 * 60 * 1000)) % 24);
            local play_time_min = math.floor((play_time / (60 * 1000)) % 60);
            local play_time_sec = math.floor((play_time / 1000) % 60);
            local play_time_ms = math.fmod(play_time, 1000);
            if play_time_ms < 0 then play_time_ms = 0; end
            
            local play_time_text = "-"
            if play_time_hour > 0 then
                play_time_text = string.format("%d:%02d:%02d.%03d", play_time_hour, play_time_min, play_time_sec, play_time_ms);
            else
                play_time_text = string.format("%02d:%02d.%03d", play_time_min, play_time_sec, play_time_ms);
            end
            text_play_time:SetTextByKey("time", play_time_text);
        end
        
        local text_play_time_prev = GET_CHILD_RECURSIVELY(frame, "text_play_time_prev");
        if text_play_time_prev ~= nil then
            if diff_time == 0 then
                text_play_time_prev:ShowWindow(0);
            else
                text_play_time_prev:ShowWindow(1);
                local diff_time_hour = math.floor((diff_time / (60 * 60 * 1000)) % 24);
                local diff_time_min = math.floor((diff_time / (60 * 1000)) % 60);
                local diff_time_sec = math.floor((diff_time / 1000) % 60);
                local diff_time_ms = math.fmod(diff_time, 1000);
                if diff_time_ms < 0 then diff_time_ms = 0; end
                
                local diff_time_text = "-"
                if diff_time_hour > 0 then
                    diff_time_text = string.format("%d:%02d:%02d.%03d", diff_time_hour, diff_time_min, diff_time_sec, diff_time_ms);
                else
                    diff_time_text = string.format("%02d:%02d.%03d", diff_time_min, diff_time_sec, diff_time_ms);
                end
                text_play_time_prev:SetTextByKey("time", diff_time_text);
            end
        end
    end
end

function CLOSE_PILGRIM_CLEAR()
    ui.CloseFrame("pilgrim_clear");
    ui.CloseFrame("fulldark");
end