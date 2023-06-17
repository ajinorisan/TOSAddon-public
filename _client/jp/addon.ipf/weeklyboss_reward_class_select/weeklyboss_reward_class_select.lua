function WEEKLYBOSS_REWARD_CLASS_SELECT_ON_INIT(addon, frame)
    addon:RegisterMsg("WEEKLY_BOSS_RECEIVE_CLASS_RANKING_REWARD", "WEEKLYBOSS_REWARD_CLASS_SELECT_RECEIVE_REWARD");
    addon:RegisterMsg("WEEKLY_BOSS_UI_UPDATE", "WEEKLYBOSS_REWARD_CLASS_SELECT_CREATE_LIST");
end

function WEEKLYBOSS_REWARD_CLASS_SELECT_OPEN(frame)
    ui.OpenFrame("weeklyboss_reward_class_select");
    local frame = ui.GetFrame("weeklyboss_reward_class_select");
    if frame ~= nil then
        WEEKLYBOSS_REWARD_CLASS_SELECT_CREATE_LIST(frame);
        frame:SetUserValue("REWARD_TYPE", "ClassRanking");
    end
end

function WEEKLYBOSS_REWARD_CLASS_SELECT_CLOSE(frame)
    ui.CloseFrame("weeklyboss_reward_class_select");
end

function WEEKLYBOSS_REWARD_CLASS_SELECT_JOB_ID(job_id)
    local frame = ui.GetFrame("weeklyboss_reward_class_select");
    if frame ~= nil then
        frame:SetUserValue("job_id", job_id);
    end
end

function WEEKLYBOSS_REWARD_CLASS_SELECT_GET_CLASSRANKING_REWARD_LIST(week_num, job_id, rank)
    local ret_list = {};
    local ret_index = 1;
    local reward_count = session.weeklyboss.GetClassRankingRewardSize(week_num, job_id);
    for i = 1, reward_count do
        local reward_str = session.weeklyboss.GetClassRankingRewardToString(week_num, job_id, i);
        if reward_str == "" then
            break;
        end

        local pre_reward = "";
        if 0 < ret_index - 1 then
            pre_reward = ret_list[ret_index - 1].reward_str;
        end

        if pre_reward == "" or pre_reward ~= reward_str then
            local ret_table = {};
            ret_table["start_rank"] = i;
            ret_table["end_rank"] = i;
            ret_table["reward_str"] = reward_str;
            ret_list[ret_index] = ret_table;
            ret_index = ret_index + 1;
        else
            ret_list[ret_index - 1].end_rank = i;
        end
    end
    return ret_list
end

function WEEKLYBOSS_REWARD_CLASS_SELECT_REMOVE_LIST(gbox)
    local child_count = gbox:GetChildCount();
    for i = 0, child_count - 1 do
        local child = gbox:GetChildByIndex(i);
        if child ~= nil and string.find(child:GetName(), "REWARD_") ~= nil then
            gbox:RemoveChildByIndex(i);
        end
    end
end

function WEEKLYBOSS_REWARD_CLASS_SELECT_CREATE_LIST(frame)
    VALIDATE_GET_ALL_REWARD_BUTTON(frame, 0);
    local job_id = frame:GetUserIValue("job_id");
    local job_cls = GetClassByType("Job", job_id);
    if job_cls ~= nil then
        local job_name = TryGetProp(job_cls, "Name", "None");
        if job_name ~= "None" then
            local title_text = GET_CHILD_RECURSIVELY(frame, "title_text");
            local title = ScpArgMsg("WeeklyBossClassRankRewardTitle", "JobName", job_name);
            title_text:SetText(title);
        end

        local week_num = WEEKLY_BOSS_RANK_WEEKNUM_NUMBER();
        local my_rank = session.weeklyboss.GetMyRankInfo(week_num);
        local list = WEEKLYBOSS_REWARD_CLASS_SELECT_GET_CLASSRANKING_REWARD_LIST(week_num, job_id, my_rank);
        local gbox = GET_CHILD_RECURSIVELY(frame, "gbox", "ui::CGroupBox");
        WEEKLYBOSS_REWARD_CLASS_SELECT_REMOVE_LIST(gbox);
        
        local empty_text = GET_CHILD_RECURSIVELY(frame, "empty_text");
        if #list == 0 then
            if session.weeklyboss.IsEnableClassRankingSeason() == true then
            local str = ClMsg("WeeklyBossClassRankEmptyTitle");
            empty_text:SetText(str);
            else
                local str = ClMsg("WeeklyBossClassRankDisEnableTitle");
                empty_text:SetText(str);
            end
            empty_text:ShowWindow(1);
            return;
        else
            empty_text:ShowWindow(0);
        end

        local y = 0;
        for i = 1, #list do
            local ctrl_set = gbox:CreateControlSet("content_status_board_reward_attribute", "REWARD_"..i, ui.LEFT, ui.TOP, 0, y, 0, 0);
            if ctrl_set ~= nil then
                local attr_value_text = GET_CHILD(ctrl_set, "attr_value_text", "ui::CRichText");
                attr_value_text:SetFontName("black_16_b");

                local start_rank = list[i].start_rank;
                local end_rank = list[i].end_rank;
                local reward_str = list[i].reward_str;
                if start_rank == end_rank then
                    local RANK_FORMAT = frame:GetUserConfig("RANK_FORMAT_1");
                    attr_value_text:SetFormat(RANK_FORMAT);
                    attr_value_text:AddParamInfo("value", start_rank);
                    attr_value_text:UpdateFormat();
                    attr_value_text:SetText(""); -- 이게 없으면 위에서 설정한 값이 출력이 안됨
                else
                    local RANK_FORMAT = frame:GetUserConfig("RANK_FORMAT_2");
                    attr_value_text:SetFormat(RANK_FORMAT);
                    attr_value_text:AddParamInfo("min", start_rank);
                    attr_value_text:AddParamInfo("max", end_rank);
                    attr_value_text:UpdateFormat();
                    attr_value_text:SetText(""); -- 이게 없으면 위에서 설정한 값이 출력이 안됨
                end
                WEEKLYBOSSREWARD_REWARD_LIST_UPDATE(frame, ctrl_set, reward_str);

                local already_get = session.weeklyboss.CanAcceptClassRankingReward(week_num, job_id) == false;
                if my_rank <= end_rank and my_rank >= start_rank then
                    if already_get == true then
                        WEEKLYBOSSREWARD_ITEM_BUTTON_SET(ctrl_set, 4);
                    elseif week_num < session.weeklyboss.GetNowWeekNum() then
                        WEEKLYBOSSREWARD_ITEM_BUTTON_SET(ctrl_set, 1, my_rank);
                        VALIDATE_GET_ALL_REWARD_BUTTON(frame, 1);
                    else
                        WEEKLYBOSSREWARD_ITEM_BUTTON_SET(ctrl_set, 2);
                    end
                else
                    WEEKLYBOSSREWARD_ITEM_BUTTON_SET(ctrl_set, 3);
                end
                y = y + ctrl_set:GetHeight();
            end
        end
    end
    frame:Invalidate();
end

function WEEKLYBOSS_REWARD_CLASS_SELECT_GET_ALL(frame, ctrl, arg_str, arg_num)
    frame = frame:GetTopParentFrame();
    if frame ~= nil then
        local week_num = WEEKLY_BOSS_RANK_WEEKNUM_NUMBER();
        local my_rank = session.weeklyboss.GetMyRankInfo(week_num);
        local job_id = frame:GetUserIValue("job_id");
        weekly_boss.RequestAccpetClassRankingReward(week_num, job_id, my_rank);
    end
end

function WEEKLYBOSS_REWARD_CLASS_SELECT_RECEIVE_REWARD(frame, msg, arg_str, arg_num)
    if arg_str ~= "ClassRanking" then return; end
    WEEKLYBOSS_REWARD_CLASS_SELECT_CREATE_LIST(frame);
end