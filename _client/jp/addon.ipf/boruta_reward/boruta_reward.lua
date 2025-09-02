function BORUTA_REWARD_ON_INIT(addon, frame)
end

function BORUTAREWARD_OPEN(frame)
    local event_id = BORUTA_RANKING_EVENT_TYPE()
    local retlist = GET_BORUTA_REWARD_LIST(event_id)
    BORUTAREWARD_RANK_REWARD_UPDATE(frame, retlist)
end

function BORUTAREWARD_CLOSE(frame)
end

function BORUTAREWARD_REWARD_CLICK(index)    
    ui.CloseFrame("boruta_reward")
    local frame = ui.GetFrame("boruta_reward")    
    local reward_btn = GET_CHILD_RECURSIVELY(frame, 'btn_reward')

    local week_num = BORUTA_RANKING_WEEKNUM_NUMBER()
    local now_week_num = session.boruta_ranking.GetNowWeekNum()
    local guild_rank = 0
    local guild_info = GET_MY_GUILD_INFO()
    if guild_info ~= nil then
        guild_id = guild_info.info:GetPartyID()   -- 길드 랭킹 정보
        guild_rank = session.boruta_ranking.GetGuildRank(guild_id)    -- 순위
    end

    if week_num < now_week_num and guild_rank > 0 and session.boruta_ranking.RewardAccepted(week_num) == 0 then
        reward_btn:SetEnable(1)
    else
        reward_btn:SetEnable(0)
    end

    ui.OpenFrame('boruta_reward')
end


function GET_BORUTA_REWARD_LIST(event_id)
    local reward_list, maxcount = GET_BORUTA_REWARD(event_id)
    
    local retlist = {};
    local retindex = 1;

    local frame = ui.GetFrame("boruta_reward")

    for i = 1, maxcount do
        local rewardstr = reward_list[i]
        
        local prereward = "";
        if 0 < retindex - 1 then
            prereward = retlist[retindex - 1].rewardstr;
        end

        -- 이전 등수 정보가 없거나 이전 등수와 보상이 다르면 
        if prereward == "" or prereward ~= rewardstr then
            -- 새로운 보상 구간 정보 추가
            local retTable = {};
            retTable['start_rank'] = i;
            retTable['end_rank'] = i
            retTable['rewardstr'] = rewardstr;
            retlist[retindex] = retTable;
            retindex = retindex + 1;
        else
            retlist[retindex - 1].end_rank = i;
        end
    end
    return retlist
end

function BORUTAREWARD_RANK_REWARD_UPDATE(frame, retlist)    
    local rewardgb = GET_CHILD_RECURSIVELY(frame, "rewardgb", "ui::CGroupBox");
    rewardgb:RemoveAllChild();

    local guild_id = -1
    local guild_info = GET_MY_GUILD_INFO()
    local guild_rank = -1
    if guild_info ~= nil then
        guild_id = guild_info.info:GetPartyID()   
        guild_rank = session.boruta_ranking.GetGuildRank(guild_id)
    end

    local week_num = BORUTA_RANKING_WEEKNUM_NUMBER()
    local y = 0;
    local cnt = #retlist -- 랭킹 cnt
    for i = 1, cnt do
        local ctrl = rewardgb:CreateControlSet("content_status_board_reward_attribute", "REWARD_" .. i,  ui.LEFT, ui.TOP, 0, y, 0, 0);
        local attr_value_text = GET_CHILD(ctrl, "attr_value_text", "ui::CRichText");
        attr_value_text:SetFontName("black_16_b");

        local startrank = retlist[i].start_rank;
        local endrank = retlist[i].end_rank;

        if startrank == endrank then
            local RANK_FORMAT = frame:GetUserConfig("RANK_FORMAT_1");

            attr_value_text:SetFormat(RANK_FORMAT);
            attr_value_text:AddParamInfo("value", startrank);
            attr_value_text:UpdateFormat();
                    
            attr_value_text:SetText(""); 

        else
            local RANK_FORMAT = frame:GetUserConfig("RANK_FORMAT_2");
            attr_value_text:SetFormat(RANK_FORMAT);
            attr_value_text:AddParamInfo("min", startrank);
            attr_value_text:AddParamInfo("max", endrank);
            attr_value_text:UpdateFormat();

            attr_value_text:SetText(""); 
        end
        
        BORUTAREWARD_REWARD_LIST_UPDATE(frame, ctrl, retlist[i].rewardstr);

        if session.boruta_ranking.RewardAccepted(week_num) == 1 then
            BORUTAREWARD_ITEM_BUTTON_SET(ctrl,3)
        elseif guild_rank > 0 and guild_rank <= retlist[i].end_rank and guild_rank >= retlist[i].start_rank then
            BORUTAREWARD_ITEM_BUTTON_SET(ctrl,1)
        else
            BORUTAREWARD_ITEM_BUTTON_SET(ctrl,2)
        end
        y = y + ctrl:GetHeight();
    end
end

function BORUTAREWARD_REWARD_LIST_UPDATE(frame, ctrl, rewardstr)    
    local attr_reward_gb = GET_CHILD(ctrl, "attr_reward_gb");
    local attr_btn = GET_CHILD(ctrl, "attr_btn");
    attr_reward_gb:RemoveAllChild();
    
    local OFFSET_SMALL = frame:GetUserConfig("OFFSET_SMALL");
    local OFFSET_MIDDLE = frame:GetUserConfig("OFFSET_MIDDLE");
    local rewardlist = StringSplit(rewardstr, ";")
    local rewardcnt = #rewardlist -- 보상 종류 수
    
    local listy = OFFSET_SMALL + OFFSET_MIDDLE;
    for i = 1, rewardcnt do
        local ctrlSet = attr_reward_gb:CreateControlSet("content_status_board_reward_list_attribute", "REWARD_LIST_" .. i,  ui.LEFT, ui.TOP, 0, listy, 0, 0);
        local attr_pic = GET_CHILD(ctrlSet, "attr_pic");
        local attr_name_text = GET_CHILD(ctrlSet, "attr_name_text");
        local attr_count_text = GET_CHILD(ctrlSet, "attr_count_text");

        local strlist = StringSplit(rewardlist[i], "/");
        local cls = GetClass("Item", strlist[1]);
        if cls == nil then
            return;
        end

        attr_pic:SetImage(GET_ITEM_ICON_IMAGE(cls));
		attr_name_text:SetTextByKey("value", dic.getTranslatedStr(cls.Name));
		ctrlSet:Resize(ctrlSet:GetWidth(),math.max(attr_name_text:GetHeight(),ctrlSet:GetHeight()))
        attr_count_text:SetTextByKey("value", strlist[2]);

        if attr_name_text:GetWidth() < attr_name_text:GetTextWidth() then
            attr_name_text:EnableSlideShow(1)
            attr_name_text:SetCompareTextWidthBySlideShow(true);
        else
            attr_name_text:EnableSlideShow(0)
            attr_name_text:SetCompareTextWidthBySlideShow(false);
        end

        listy = listy + ctrlSet:GetHeight() + OFFSET_MIDDLE;
    end

    attr_btn:Resize(attr_btn:GetWidth(), listy + OFFSET_MIDDLE);
    attr_reward_gb:Resize(attr_reward_gb:GetWidth(), listy + OFFSET_MIDDLE);
    ctrl:Resize(ctrl:GetWidth(), listy + OFFSET_SMALL);
end

--rewardtype : 1-하이라이트, 2-조건미충족, 3-수령완료
function BORUTAREWARD_ITEM_BUTTON_SET(ctrl,rewardtype)
    local attr_btn = GET_CHILD(ctrl, "attr_btn");
    if rewardtype == 1 then
        attr_btn:EnableHitTest(0)
        return
    elseif rewardtype == 2 then
        attr_btn:SetEnable(0)
    elseif rewardtype == 3 then
        attr_btn:SetEnable(0)
        local stampPic = GET_CHILD(ctrl,'stampPic')
        stampPic:SetImage("adventure_stamp")
    end
end
