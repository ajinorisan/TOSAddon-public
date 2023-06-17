function PILGRIM_TRIBULATION_RANK_SELECT_ON_INIT(addon, frame)
    addon:RegisterMsg("PILGRIM_TRIBULATION_RANK_SELECT_START", "ON_START_PILGRIM_TRIBULATION_RANK_SELECT");
    addon:RegisterMsg("ON_OTHER_PC_INFO_FOR_ACT", "ON_PILGRIM_TRIBULATION_RANK_SELECT_FILL_PILGRIM_LIST_MEMBER");
end

function PILGRIM_TRIBULATION_RANK_SELECT_CLOSE(frame)
    if frame == nil then return; end
    ui.CloseFrame("pilgrim_tribulation_rank_select");
end

function ON_START_PILGRIM_TRIBULATION_RANK_SELECT(frame, msg, arg_str, arg_num)
    if frame == nil then return; end
    frame:ShowWindow(1);
    frame:SetUserValue("mgame_name", arg_str);
    frame:SetUserValue("select_rank", 1); -- init rank
    PILGRIM_TRIBULATION_SELECT_SET_SELECT_PILGRIM(frame);
    PILGRIM_TRIBULATION_RANK_SELECT_SKIN_SET(frame);
    PILGRIM_TRIBULATION_RANK_SELECT_FILL_PILGRIM(frame);
    PILGRIM_TRIBULATION_RANK_SELECT_FILL_TRIBULATION(frame, arg_str);
end

function PILGRIM_TRIBULATION_SELECT_SET_SELECT_PILGRIM(frame)
    if frame ~= nil then
        local mgame_name = frame:GetUserValue("mgame_name");
        local indun_cls = GetClassByStrProp("Indun", "MGame", mgame_name);
        if indun_cls ~= nil then
            local pilgrim_group_index = TryGetProp(indun_cls, "PilgrimGroupIndex");
            frame:SetUserValue("select_pilgrim", pilgrim_group_index);
        end
    end
end

function PILGRIM_TRIBULATION_RANK_SELECT_SKIN_SET(frame)
    if frame == nil then return; end
    local gb_tribulation_category = GET_CHILD_RECURSIVELY(frame, "gb_tribulation_category");
    if gb_tribulation_category ~= nil then
        gb_tribulation_category:SetScrollBarSkinName("tribal_scroll");
        gb_tribulation_category:Invalidate();
    end

    local gb_tribulation_info = GET_CHILD_RECURSIVELY(frame, "gb_tribulation_info");
    if gb_tribulation_info ~= nil then
        gb_tribulation_info:SetScrollBarSkinName("tribal_scroll");
        gb_tribulation_info:Invalidate();
    end
end

function PILGRIM_TRIBULATION_AUTO_FIRST_CATEGORY_SELECT(gb)
    if gb ~= nil then
        local count = gb:GetChildCount();
        if count > 0 then
            for i = 0, count - 1 do
                local child = gb:GetChildByIndex(i);
                if child ~= nil and string.find(child:GetName(), "pic_category_") ~= nil then
                    local parent = GET_CHILD_RECURSIVELY(child, "pic_category");
                    local pic = GET_CHILD_RECURSIVELY(child, "pic_category_icon");
                    if parent ~= nil and pic ~= nil then
                        ON_PILGRIM_TRIBULATION_CATEGORY_SELECT_ICON(parent, pic);
                        break;
                    end
                end
            end
        end
    end
end

function PILGRIM_TRIBULATION_AUTO_FIRST_TRIBULATION_SELECT(gb, selected_index)
    if gb ~= nil then
        local count = gb:GetChildCount();
        if count > 0 then
            for i = 0, count - 1 do
                local child = gb:GetChildByIndex(i);
                if child ~= nil and --[[ child:GetName() ~= "_SCR" and ]] string.find(child:GetName(), "tribulation_info") ~= nil then
                    if selected_index ~= -1 and selected_index == child:GetUserIValue("slot_index") then
                        local btn = GET_CHILD_RECURSIVELY(child, "btn_info");
                        if btn ~= nil then
                            ON_PILGRIM_TRIBULATION_INFO_SELECT(child, btn);
                            break;
                        end
                    else
                        local btn = GET_CHILD_RECURSIVELY(child, "btn_info");
                        if btn ~= nil then
                            ON_PILGRIM_TRIBULATION_INFO_SELECT(child, btn);
                            break;
                        end
                    end
                end
            end
        end
    end
end

-- ** squad ** --
function PILGRIM_TRIBULATION_RANK_SELECT_FILL_PILGRIM(frame)
    -- pilgrim init & request
    PILGRIM_TRIBULATION_SELECT_SET_SELECT_PILGRIM(frame);    
    PILGRIM_TRIBULATION_RANK_SELECT_PILGRIM_LIST_INIT(frame);
    -- pilgrim fill
    PILGRIM_TRIBULATION_RANK_SELECT_FILL_PILGRIM_SELECT(frame);
    PILGRIM_TRIBULATION_RANK_SELECT_FILL_PILGRIM_LIST(frame);
end

function PILGRIM_TRIBULATION_RANK_SELECT_PILGRIM_LIST_INIT(frame)
    local select_pilgrim = frame:GetUserIValue("select_pilgrim"); 
    -- request
    local list = session.SquadSystem.GetSquadMemberList(select_pilgrim);
    if list ~= nil then
        local count = list:Count();
        for i = 0, count - 1 do
            local name = list:Element(i);
            if name ~= "None" then
                party.ReqMemberDetailInfoForAct(name);
            end
        end
    end
end

function PILGRIM_TRIBULATION_RANK_SELECT_FILL_PILGRIM_SELECT(frame)
    if frame == nil then return; end
    local select_pilgrim = frame:GetUserIValue("select_pilgrim");
    local gb_pilgrim_select = GET_CHILD_RECURSIVELY(frame, "gb_pilgrim_select");
    if gb_pilgrim_select ~= nil then
        -- pilgrim title
        local title = session.SquadSystem.GetSquadName(select_pilgrim);
        if title == "None" then
            title = ClMsg("NotExistPilgrimGroup");
        end
        local text_pilgrim_select = GET_CHILD_RECURSIVELY(gb_pilgrim_select, "text_pilgrim_select");
        if text_pilgrim_select ~= nil then
            text_pilgrim_select:SetTextByKey("title", title);
        end
    end
end

function PILGRIM_TRIBULATION_RANK_SELECT_FILL_PILGRIM_LIST(frame)
    if frame == nil then return; end
    local gb = GET_CHILD_RECURSIVELY(frame, "gb_pilgrim_list");
    if gb ~= nil then
        gb:RemoveAllChild();
        local select_pilgrim = frame:GetUserIValue("select_pilgrim");
        if select_pilgrim == -1 then select_pilgrim = 0; end
        -- tribulation_squad_member
        local start_y = 5;
        local space_y = 8;
        local height = 86;
        local member_list = session.SquadSystem.GetSquadMemberList(select_pilgrim);
        if member_list ~= nil then
            local member_count = member_list:Count();
            for i = 0, member_count - 1 do
                local member_name = member_list:Element(i);
                local ctrl_set = gb:CreateOrGetControlSet("tribulation_squad_member", "squad_member_info_"..i, 0, start_y + (i * height) + (i * space_y));
                if ctrl_set ~= nil then
                    -- member name
                    local name_text = GET_CHILD_RECURSIVELY(ctrl_set, "name_text");
                    name_text:SetTextByKey("name", member_name);
                    -- leader img
                    local leader_image = GET_CHILD_RECURSIVELY(ctrl_set, "leader_img");
                    if i ~= 0 then
                        leader_image:ShowWindow(0);
                        name_text:SetOffset(leader_image:GetX(), 9);
                    end
                    -- logout text
                    local logout_text = GET_CHILD_RECURSIVELY(ctrl_set, "logout_text");
                    local member_info = session.otherPC.GetByFamilyName(member_name);
                    if member_info ~= nil then
                        logout_text:ShowWindow(0);
                        local job = {};
                        for j = 0, member_info:GetJobCount() - 1 do
                            local job_info = member_info:GetJobInfoByIndex(j);
                            if job_info ~= nil then
                                table.insert(job, job_info.jobID);
                            end
                        end
                        table.sort(job);
                        local job_index = 1;
                        for j = 2, #job do
                            local job_type = job[j];
                            local job_cls = GetClassByType("Job", job_type);
                            if job_cls ~= nil then
                                local job_portrait = GET_CHILD_RECURSIVELY(ctrl_set, "jobportrait"..job_index);
                                if job_portrait ~= nil then
                                    local job_icon = TryGetProp(job_cls, "Icon", "None");
                                    if job_icon ~= "None" then
                                        job_portrait:SetImage(job_icon);
                                    end
                                    local job_name = TryGetProp(job_cls, "Name", "None");
                                    if job_name ~= "None" then
                                        job_portrait:SetTooltipArg(job_name);
                                    end
                                    job_portrait:SetTooltipType("texthelp");
                                end
                                job_index = job_index + 1;
                            end
                        end
                    else
                        party.ReqMemberDetailInfoForAct(member_name);
                        logout_text:ShowWindow(1);
                    end
                end
            end
        end
    end
end

function ON_PILGRIM_TRIBULATION_RANK_SELECT_FILL_PILGRIM_LIST_MEMBER(frame, msg, arg_str, arg_num)
    if frame == nil then return; end
    local gb = GET_CHILD_RECURSIVELY(frame, "gb_pilgrim_list");
    if gb ~= nil then
        local select_pilgrim = frame:GetUserIValue("select_pilgrim");
        local member_list = session.SquadSystem.GetSquadMemberList(select_pilgrim);
        if member_list ~= nil then
            local member_count = member_list:Count();
            for i = 0, member_count - 1 do
                local member_name = member_list:Element(i);
                if arg_str == member_name then
                    local ctrl_set = GET_CHILD_RECURSIVELY(gb, "squad_member_info_"..i);
                    if ctrl_set ~= nil then
                        -- member name
                        local name_text = GET_CHILD_RECURSIVELY(ctrl_set, "name_text");
                        name_text:SetTextByKey("name", member_name);
                        -- leader img
                        local leader_image = GET_CHILD_RECURSIVELY(ctrl_set, "leader_img");
                        if i ~= 0 then
                            leader_image:ShowWindow(0);
                            name_text:SetOffset(leader_image:GetX(), 9);
                        end
                        -- logout text
                        local logout_text = GET_CHILD_RECURSIVELY(ctrl_set, "logout_text");
                        local member_info = session.otherPC.GetByFamilyName(member_name);
                        if member_info ~= nil then
                            logout_text:ShowWindow(0);
                            local job = {};
                            for j = 0, member_info:GetJobCount() - 1 do
                                local job_info = member_info:GetJobInfoByIndex(j);
                                if job_info ~= nil then
                                    table.insert(job, job_info.jobID);
                                end
                            end
                            table.sort(job);
                            local job_index = 1;
                            for j = 2, #job do
                                local job_type = job[j];
                                local job_cls = GetClassByType("Job", job_type);
                                if job_cls ~= nil then
                                    local job_portrait = GET_CHILD_RECURSIVELY(ctrl_set, "jobportrait"..job_index);
                                    if job_portrait ~= nil then
                                        local job_icon = TryGetProp(job_cls, "Icon", "None");
                                        if job_icon ~= "None" then
                                            job_portrait:SetImage(job_icon);
                                        end
                                        local job_name = TryGetProp(job_cls, "Name", "None");
                                        if job_name ~= "None" then
                                            job_portrait:SetTooltipArg(job_name);
                                        end
                                        job_portrait:SetTooltipType("texthelp");
                                    end
                                    job_index = job_index + 1;
                                end
                            end
                        else
                            logout_text:ShowWindow(1);
                        end
                    end
                    break;
                end
            end
        end
    end
end

-- ** category ** --
function PILGRIM_TRIBULATION_RANK_SELECT_FILL_TRIBULATION(frame, mgame_name)
    PILGRIM_TRIBULATION_RANK_SELECT_FILL_CATEGORY(frame);
end

function PILGRIM_TRIBULATION_RANK_SELECT_FILL_CATEGORY(frame)
    local gb_category = GET_CHILD_RECURSIVELY(frame, "gb_tribulation_category");
    if gb_category ~= nil then
        gb_category:RemoveAllChild();
        PILGRIM_TRIBULATION_RANK_SELECT_CREATE_CATEGORY(gb_category);
        PILGRIM_TRIBULATION_AUTO_FIRST_CATEGORY_SELECT(gb_category);
    end
end

function PILGRIM_TRIBULATION_RANK_SELECT_CREATE_CATEGORY(gb)
    local category_list = { "pc", "mon", "fix_pattern" };
    local count = #category_list;
    for i = 1, count do
        local category = category_list[i];
        local category_name = "pic_category_"..category.."_icon";
        local category_width = 80;
        local category_height = 80;
        local space_x = 5;
        local space_y = 12;
        local offset_x = ((gb:GetWidth() - category_width) * 0.5) - space_x;
        local offset_y = (gb:GetHeight() / count) - ((category_height * 0.5) + space_y * 2);
        offset_y = offset_y + ((i - 1) * category_height) + ((i - 1) * space_y);
        local category_ctrl_set = gb:CreateOrGetControlSet("tribulation_category", category_name, offset_x, offset_y);
        if category_ctrl_set ~= nil then
            -- category 
            local pic_category = GET_CHILD_RECURSIVELY(category_ctrl_set, "pic_category");
            if pic_category ~= nil then
                local category_image_name = "tribal_levelframe_L0"..(count - (i - 1));
                if category == "fix_pattern" then category_image_name = "tribal_levelframe_L00"; end
                pic_category:SetImage(category_image_name);
            end
            -- categroy icon
            local pic_category_icon = GET_CHILD_RECURSIVELY(category_ctrl_set, "pic_category_icon");
            if pic_category_icon ~= nil then
                local icon_name = "tribal_icon_level_00";
                if category == "fix_pattern" then icon_name = "icon_tribulation_PatternCategory"; end
                pic_category_icon:SetImage(icon_name);
            end
        end
    end
end

-- select category
function ON_PILGRIM_TRIBULATION_CATEGORY_SELECT_ICON(parent, pic, arg_str, arg_num)
    if pic ~= nil then
        local frame = parent:GetTopParentFrame();
        local mgame_name = frame:GetUserValue("mgame_name");
        local ctrl_set = parent:GetParent();
        local name = ctrl_set:GetName();
        local image = parent:GetImageName();
        local category = "None";
        if string.find(name, "pc") ~= nil then 
            category = "PC"; 
        elseif string.find(name, "mon") ~= nil then 
            category = "Monster";
        elseif string.find(name, "fix_pattern") ~= nil then
            category = "Pattern";
        end
        frame:SetUserValue("select_category", category);
        -- selected rank load
        local selected_rank_name = category.."_selected_rank";
        local selected_rank = frame:GetUserIValue(selected_rank_name);
        if selected_rank ~= 0 then
            frame:SetUserValue("select_rank", selected_rank);
        else
            frame:SetUserValue("select_rank", 1);
        end
        -- craete info
        PILGRIM_TRIBULATION_RANK_SELECT_FILL_TRIBULATION_INFO_LIST_SELECT_CATEGORY(frame, mgame_name, category);
        PILGRIM_TRIBULATION_RANK_SELECT_FILL_TRIBULATION_INFO_RANK_SELECT_CATEGORY(frame, mgame_name, category, image);
    end
end

-- ** tribulation info ** --
-- tribulation list create none select
function PILGRIM_TRIBULATION_RANK_SELECT_FILL_TRIBULATION_INFO_LIST_NONE_SELECT(gb, category)
    if gb == nil then return; end
    local name = "tribulation_info_"..category.."_".."NoneSelect";
    local ctrl_set = gb:CreateOrGetControlSet("tribulation_info", name, 0, 0);
    if ctrl_set ~= nil then
        -- rank pic
        local pic_rank = GET_CHILD_RECURSIVELY(ctrl_set, "pic_rank");
        if pic_rank ~= nil then
            local rank_image = "tribal_levelframe_S00"; 
            pic_rank:SetImage(rank_image);
        end
        -- title
        local text_title = GET_CHILD_RECURSIVELY(ctrl_set, "title");
        if text_title ~= nil then
            local title = ClMsg("TribulationNoneSelect");
            text_title:SetTextByKey("title", title);
        end
        -- tribulation icon
        local pic_rank_icon = GET_CHILD_RECURSIVELY(ctrl_set, "pic_rank_icon");
        if pic_rank_icon ~= nil then
            local icon = "tribal_icon_level_00";
            pic_rank_icon:SetImage(icon);
        end
        ctrl_set:SetUserValue("slot_index", -1);
    end
end

-- tribulation list create
function PILGRIM_TRIBULATION_RANK_SELECT_FILL_TRIBULATION_INFO_LIST_SELECT_CATEGORY(frame, mgame_name, category)
    if mgame_name == nil or mgame_name == "None" then return; end
    local select_rank = frame:GetUserIValue("select_rank");
    local gb = GET_CHILD_RECURSIVELY(frame, "gb_tribulation_info_list");
    gb:RemoveAllChild();
    if category == "PC" or category == "Monster" then
        PILGRIM_TRIBULATION_RANK_SELECT_FILL_TRIBULATION_INFO_LIST_NONE_SELECT(gb, category);
        local count = session.TribulationSystem.GetTribulationCount(mgame_name, category);
        local index = 1;
        for i = 0, count - 1 do 
            local rank = session.TribulationSystem.GetTribulationRankByIndex(mgame_name, category, i);
            local title = session.TribulationSystem.GetTribulationTitleByIndex(mgame_name, category, i);
            local icon = session.TribulationSystem.GetTribulationIconByIndex(mgame_name, category, i);
            if select_rank == rank then
                local name = "tribulation_info_"..category.."_"..index;
                local ctrl_set = gb:CreateOrGetControlSet("tribulation_info", name, 0, (index * 50) + (index * 3));
                if ctrl_set ~= nil then
                    -- rank
                    local pic_rank = GET_CHILD_RECURSIVELY(ctrl_set, "pic_rank");
                    if pic_rank ~= nil then
                        local rank_image = "tribal_levelframe_S0"..rank;
                        pic_rank:SetImage(rank_image);
                    end
                    -- title
                    local text_title = GET_CHILD_RECURSIVELY(ctrl_set, "title");
                    if text_title ~= nil then
                        text_title:SetTextByKey("title", title);
                    end
                    -- tribulation icon
                    local pic_rank_icon = GET_CHILD_RECURSIVELY(ctrl_set, "pic_rank_icon");
                    if pic_rank_icon ~= nil then
                        pic_rank_icon:SetImage(icon);
                    end
                    ctrl_set:SetUserValue("slot_index", i);
                    index = index + 1;
                end
            end
        end
    elseif category == "Pattern" then
        local index = 0;
        local count = session.TribulationSystem.GetTribulationPatternCount(mgame_name, category);
        for i = 0, count - 1 do
            local name = "tribulation_info_"..category.."_"..i;
            local ctrl_set = gb:CreateOrGetControlSet("tribulation_info", name, 0, (index * 50) + (index * 3));
            if ctrl_set ~= nil then
                -- rank
                local rank = session.TribulationSystem.GetTribulationPatternRankByIndex(mgame_name, category, i);
                local pic_rank = GET_CHILD_RECURSIVELY(ctrl_set, "pic_rank");
                if pic_rank ~= nil then
                    if rank == 0 then rank = 1; end
                    local rank_image = "tribal_levelframe_S00";
                    pic_rank:SetImage(rank_image);
                end
                -- title
                local title = session.TribulationSystem.GetTribulationPatternTitleByIndex(mgame_name, category, i);
                local text_title = GET_CHILD_RECURSIVELY(ctrl_set, "title");
                if text_title ~= nil then
                    text_title:SetTextByKey("title", title);
                end
                -- tribulation icon
                local icon = session.TribulationSystem.GetTribulationPatternIconByIndex(mgame_name, category, i);
                local pic_rank_icon = GET_CHILD_RECURSIVELY(ctrl_set, "pic_rank_icon");
                if pic_rank_icon ~= nil then
                    pic_rank_icon:SetImage(icon);
                end
                ctrl_set:SetUserValue("slot_index", i);
                index = index + 1;
            end
        end
    end
    gb:Invalidate();
end

-- tribulation rank info create
function PILGRIM_TRIBULATION_RANK_SELECT_FILL_TRIBULATION_INFO_RANK_SELECT_CATEGORY(frame, mgame_name, category, image)
    if mgame_name == nil or mgame_name == "None" then return; end
    -- rank info
    local gb = GET_CHILD_RECURSIVELY(frame, "gb_tribulation_info_rank");
    if gb ~= nil then
        -- category icon
        local pic_select_rank = GET_CHILD_RECURSIVELY(gb, "pic_select_rank");
        if pic_select_rank ~= nil and image ~= "None" then
            pic_select_rank:SetImage(image);
        end
        -- category name
        local gb_category_name = GET_CHILD_RECURSIVELY(gb, "gb_tribulation_category_name");
        if gb_category_name ~= nil then
            local text_category_name = GET_CHILD_RECURSIVELY(gb_category_name, "text_tribulation_category_name");
            if text_category_name ~= nil then
                local category_name = "None";
                if category == "PC" then category_name = ClMsg("TribulationCategoryPC");
                elseif category == "Monster" then category_name = ClMsg("TribulationCategoryMonster");
                elseif category == "Pattern" then
                    category_name = ClMsg("TribulationCategoryFixPattern");
                end
                text_category_name:SetTextByKey("category", category_name);
            end
        end
        gb:Invalidate();
    end

    -- rank desc
    local gb_desc = GET_CHILD_RECURSIVELY(frame, "gb_tribulation_info_desc");
    if gb_desc ~= nil then
        local select_rank = frame:GetUserIValue("select_rank");
        -- rank level icon
        local pic_desc_rank_icon = GET_CHILD_RECURSIVELY(gb_desc, "pic_tribulation_desc_rank_icon");
        if pic_desc_rank_icon ~= nil then
            local rank_icon_image = "tribal_icon_level_0"..select_rank;
            if category == "Pattern" then rank_icon_image = "icon_tribulation_PatternCategory"; end
            pic_desc_rank_icon:SetImage(rank_icon_image);
        end
        -- rank level btn & level text
        local up_btn = GET_CHILD_RECURSIVELY(gb_desc, "btn_rank_up");
        local down_btn = GET_CHILD_RECURSIVELY(gb_desc, "btn_rank_down");
        local text_level = GET_CHILD_RECURSIVELY(gb_desc, "text_tribulation_rank_level");
        if category == "Pattern" then
            up_btn:ShowWindow(0);
            down_btn:ShowWindow(0);
            text_level:ShowWindow(0); 
        else
            up_btn:ShowWindow(1);
            down_btn:ShowWindow(1);
            text_level:ShowWindow(1);
            text_level:SetTextByKey("level", select_rank);
        end
        gb_desc:Invalidate();
    end
end

-- rank level
function ON_PILGRIM_TRIBULATION_RANK_DOWN_BTN(parent, btn, arg_str, arg_num)
    if btn ~= nil then
        local frame = parent:GetTopParentFrame();
        local select_rank = frame:GetUserIValue("select_rank");
        if select_rank <= 1 then 
            ui.SysMsg(ClMsg("TribulationHighestLowRankLevel"));
            return; 
        end
        -- rank down
        select_rank = select_rank - 1;
        local gb_desc = GET_CHILD_RECURSIVELY(frame, "gb_tribulation_info_desc");
        if gb_desc ~= nil then
            local pic_desc_rank_icon = GET_CHILD_RECURSIVELY(gb_desc, "pic_tribulation_desc_rank_icon");
            if pic_desc_rank_icon ~= nil then
                local rank_icon_image = "tribal_icon_level_0"..select_rank;
                pic_desc_rank_icon:SetImage(rank_icon_image);
            end
            local text_level = GET_CHILD_RECURSIVELY(gb_desc, "text_tribulation_rank_level");
            if text_level ~= nil then
                text_level:SetTextByKey("level", select_rank);
            end
            gb_desc:Invalidate();
        end
        frame:SetUserValue("select_rank", select_rank);

        -- update list
        local mgame_name = frame:GetUserValue("mgame_name");
        local select_category = frame:GetUserValue("select_category");
        PILGRIM_TRIBULATION_RANK_SELECT_FILL_TRIBULATION_INFO_LIST_SELECT_CATEGORY(frame, mgame_name, select_category);

        -- selected rank
        local selected_rank_name = "";
        if select_category ~= "Pattern" then
            selected_rank_name = select_category.."_selected_rank";
        end
        frame:SetUserValue(selected_rank_name, select_rank);

        -- select first tribulation
        local gb_list = GET_CHILD_RECURSIVELY(frame, "gb_tribulation_info_list");
        if gb_list ~= nil then
            gb_list:Invalidate();
            PILGRIM_TRIBULATION_AUTO_FIRST_TRIBULATION_SELECT(gb_list, -1);
        end
    end
end

function ON_PILGRIM_TRIBULATION_RANK_UP_BTN(parent, btn, arg_str, arg_num)
    if btn ~= nil then
        local frame = parent:GetTopParentFrame();
        local select_rank = frame:GetUserIValue("select_rank");
        if select_rank >= 4 then 
            ui.SysMsgWithoutMessageBox(ClMsg("TribulationHighestRankLevel"))
            return;
        end
        -- rank up
        select_rank = select_rank + 1;
        local gb_desc = GET_CHILD_RECURSIVELY(frame, "gb_tribulation_info_desc");
        if gb_desc ~= nil then
            local pic_desc_rank_icon = GET_CHILD_RECURSIVELY(gb_desc, "pic_tribulation_desc_rank_icon");
            if pic_desc_rank_icon ~= nil then
                local rank_icon_image = "tribal_icon_level_0"..select_rank;
                pic_desc_rank_icon:SetImage(rank_icon_image);
            end
            local text_level = GET_CHILD_RECURSIVELY(gb_desc, "text_tribulation_rank_level");
            if text_level ~= nil then
                text_level:SetTextByKey("level", select_rank);
            end
            gb_desc:Invalidate();
        end
        frame:SetUserValue("select_rank", select_rank);

        -- update list
        local mgame_name = frame:GetUserValue("mgame_name");
        local select_category = frame:GetUserValue("select_category");
        PILGRIM_TRIBULATION_RANK_SELECT_FILL_TRIBULATION_INFO_LIST_SELECT_CATEGORY(frame, mgame_name, select_category);

        -- selected rank
        local selected_rank_name = "";
        if select_category ~= "Pattern" then
            selected_rank_name = select_category.."_selected_rank";
        end
        frame:SetUserValue(selected_rank_name, select_rank);

        -- select first tribulation
        local gb_list = GET_CHILD_RECURSIVELY(frame, "gb_tribulation_info_list");
        if gb_list ~= nil then
            gb_list:Invalidate();
            PILGRIM_TRIBULATION_AUTO_FIRST_TRIBULATION_SELECT(gb_list, -1);
        end
    end
end

-- tribulation item select
function ON_PILGRIM_TRIBULATION_INFO_SELECT(parent, btn, arg_str, arg_num)
    if parent ~= nil then
        local frame = parent:GetTopParentFrame();
        local mgame_name = frame:GetUserValue("mgame_name");
        local select_category = frame:GetUserValue("select_category");
        local select_pilgrim = frame:GetUserIValue("select_pilgrim");
        local slot_index = parent:GetUserIValue("slot_index");
        local selected_index_name = "";
        -- category & rank info
        PILGRIM_TRIBULATION_RANK_SELECT_FILL_SELECT_TRIBULATION_INFO_RANK(frame, mgame_name, select_category, parent);
        PILGRIM_TRIBULATION_RANK_SELECT_FILL_SELECT_TRIBULATION_INFO_CATEGORY(frame, mgame_name, select_category, parent);
        if slot_index ~= -1 then
            -- cost
            PILGRIM_TRIBULATION_RANK_SELECT_STONE_NEED_COUNT_UPDATE(frame, mgame_name, select_category, slot_index);
            -- select
            if select_category == "PC" or select_category == "Monster" then
                local name = session.TribulationSystem.GetTribulationClassNameByIndex(mgame_name, select_category, slot_index);
                session.TribulationSystem.SelectTribulation(select_pilgrim, mgame_name, select_category, name);
            elseif select_category == "Pattern" then
                local name = session.TribulationSystem.GetTribulationPatternClassNameByIndex(mgame_name, select_category, slot_index);
                session.TribulationSystem.SelectTribulation(select_pilgrim, mgame_name, select_category, name);
            end
            selected_index_name = select_category.."_selected_index";
        else
            PILGRIM_TRIBULATION_RANK_SELECT_STONE_NEED_COUNT_UPDATE(frame, mgame_name, select_category, slot_index);
            session.TribulationSystem.DeSelectTribulation(select_pilgrim, select_category);
        end
        -- selected index
        if selected_index_name ~= "" then
            frame:SetUserValue(selected_index_name, slot_index);
        end
        -- total count update
        PILGRIM_TRIBULATION_RANK_SELECT_STONE_TOTAL_COUNT_UPDATE(frame, mgame_name); 
    end
end

function PILGRIM_TRIBULATION_RANK_SELECT_FILL_SELECT_TRIBULATION_INFO_RANK(frame, mgame_name, category, ctrl_set)
    if frame == nil then return; end
    -- rank info
    local gb = GET_CHILD_RECURSIVELY(frame, "gb_tribulation_info_rank");
    if gb ~= nil then
        local pic_select_rank = GET_CHILD_RECURSIVELY(gb, "pic_select_rank");
        if pic_select_rank ~= nil then
            local pic_rank = GET_CHILD_RECURSIVELY(ctrl_set, "pic_rank");
            if pic_rank ~= nil then
                local image_name = pic_rank:GetImageName();
                pic_select_rank:SetImage(image_name);
            end
        end

        local pic_rank_icon = GET_CHILD_RECURSIVELY(pic_select_rank, "pic_rank_icon");
        if pic_rank_icon ~= nil then
            local icon = GET_CHILD_RECURSIVELY(ctrl_set, "pic_rank_icon");
            if icon ~= nil then
                local image_name = icon:GetImageName();
                pic_rank_icon:SetImage(image_name);
            end
        end
    end

    local slot_index = ctrl_set:GetUserIValue("slot_index");
    if slot_index ~= -1 then
        -- rank desc
        local gb_desc = GET_CHILD_RECURSIVELY(frame, "gb_tribulation_info_desc");
        if gb_desc ~= nil then
            local text_tribulation_desc = GET_CHILD_RECURSIVELY(gb_desc, "text_tribulation_desc");
            if text_tribulation_desc ~= nil then
                if category == "PC" or category == "Monster" then
                    local desc = session.TribulationSystem.GetTribulationDescByIndex(mgame_name, category, slot_index);
                    text_tribulation_desc:SetTextByKey("desc", desc);
                elseif category == "Pattern" then
                    local desc = session.TribulationSystem.GetTribulationPatternDescByIndex(mgame_name, category, slot_index);
                    text_tribulation_desc:SetTextByKey("desc", desc);
                end
            end
            gb_desc:Invalidate();
        end
    else
        -- rank desc
        local gb_desc = GET_CHILD_RECURSIVELY(frame, "gb_tribulation_info_desc");
        if gb_desc ~= nil then
            local text_tribulation_desc = GET_CHILD_RECURSIVELY(gb_desc, "text_tribulation_desc");
            if text_tribulation_desc ~= nil then
                local clmsg_category = "None";
                if category == "PC" then 
                    clmsg_category = ClMsg("TribulationCategoryPC");
                elseif category == "Monster" then 
                    clmsg_category = ClMsg("TribulationCategoryMonster"); 
                elseif category == "Pattern" then
                    clmsg_category = ClMsg("TribulationCategoryFixPattern"); 
                end
                local desc = ScpArgMsg("TribulationNoneSelectDesc", "category", clmsg_category);
                text_tribulation_desc:SetTextByKey("desc", desc);
            end
            gb_desc:Invalidate();
        end
    end
end

function PILGRIM_TRIBULATION_RANK_SELECT_FILL_SELECT_TRIBULATION_INFO_CATEGORY(frame, mgame_name, category, ctrl_set)
    if frame == nil then return; end
    local gb = GET_CHILD_RECURSIVELY(frame, "gb_tribulation_category");
    if gb ~= nil then
        local group = "None";
        if category == "PC" then group = "pc";
        elseif category == "Monster" then group = "mon";
        elseif category == "Pattern" then group = "fix_pattern"; end
        if group ~= "None" then
            local category_name = "pic_category_"..group.."_icon";
            local category_ctrl_set = GET_CHILD_RECURSIVELY(gb, category_name);
            if category_ctrl_set ~= nil then
                -- rank frame
                local pic_category = GET_CHILD_RECURSIVELY(category_ctrl_set, "pic_category");
                if pic_category ~= nil then
                    local select_rank = frame:GetUserIValue("select_rank");
                    local image_name = "tribal_levelframe_L0"..select_rank;
                    if category == "Pattern" then image_name = "tribal_levelframe_L00"; end
                    pic_category:SetImage(image_name);
                end
                -- rank icon
                local pic_category_icon = GET_CHILD_RECURSIVELY(category_ctrl_set, "pic_category_icon");
                if pic_category_icon ~= nil then
                    local icon = GET_CHILD_RECURSIVELY(ctrl_set, "pic_rank_icon");
                    if icon ~= nil then
                        local image_name = icon:GetImageName();
                        if category == "Pattern" then image_name = "icon_tribulation_PatternCategory"; end
                        pic_category_icon:SetImage(image_name);
                    end
                end
            end
        end
    end
end

-- ** tribulation stone ** --
-- total count
function PILGRIM_TRIBULATION_RANK_SELECT_STONE_TOTAL_COUNT_UPDATE(frame, mgame_name)
    if frame == nil then return; end
    local gb_stone_total = GET_CHILD_RECURSIVELY(frame, "gb_tribulation_stone_total");
    if gb_stone_total ~= nil then
        local pic_stone_total = GET_CHILD_RECURSIVELY(frame, "pic_tribulation_stone_total");
        if pic_stone_total ~= nil then
            local cur_count = session.TribulationSystem.GetInvCountTribulationStone();
            local tooltip_text = ClMsg("TribulationInvStoneCuont")..cur_count;
            pic_stone_total:SetTooltipOverlap(1);
            pic_stone_total:SetTextTooltip(tooltip_text);
        end

        local total_count = 0;
        local stone_need_list = { "pc", "monster", "pattern" };
        for i = 1, #stone_need_list do
            local key = stone_need_list[i];
            local need_count = frame:GetUserIValue(key.."_stone_count");
            total_count = total_count + need_count;
        end
        local text_stone_total = GET_CHILD_RECURSIVELY(gb_stone_total, "text_tribulation_stone_total");
        if text_stone_total ~= nil then
            local prefix = "{@stilc}{s16}";
            local is_under_tribulation_cost = session.TribulationSystem.IsTribulationStoneUnderCount(mgame_name);
            if is_under_tribulation_cost == true then
                prefix = "{@st63_red}{s16}";
            end
            local text_count = prefix..total_count;
            text_stone_total:SetTextByKey("count", text_count);
        end
        gb_stone_total:Invalidate();
    end
end

-- need count
function PILGRIM_TRIBULATION_RANK_SELECT_STONE_NEED_COUNT_UPDATE(frame, mgame_name, category, index)
    if frame == nil then return; end
    local gb_stone_need = GET_CHILD_RECURSIVELY(frame, "gb_tribulation_stone_need");
    if gb_stone_need ~= nil then
        -- need count
        local cost = 0;
        if index ~= -1 then
            if category == "PC" or category == "Monster" then
                cost = session.TribulationSystem.GetTribulationCostByIndex(mgame_name, category, index);
            elseif category == "Pattern" then
                cost = session.TribulationSystem.GetTribulationPatternCostByIndex(mgame_name, category, index);
            end
        end
        -- key
        local key = "";
        if category == "PC" then key = "pc";
        elseif category == "Monster" then key = "monster"; end
        key = key.."_stone_count";
        frame:SetUserValue(key, cost);
        -- stone img
        gb_stone_need:RemoveAllChild();
        local start_x = 0;
        local space_x = 4;
        local start_y = 0;
        local width, height = 16, 22;
        for i = 0, cost - 1 do
            local pic_stone = gb_stone_need:CreateOrGetControl("picture", "stone_"..i, start_x + (i * width) + (i * space_x), start_y, width, height);
            if pic_stone ~= nil then
                tolua.cast(pic_stone, "ui::CPicture");
                pic_stone:SetImage("tribal_icon_stone");
            end
        end
        -- total count update
        PILGRIM_TRIBULATION_RANK_SELECT_STONE_TOTAL_COUNT_UPDATE(frame, mgame_name); 
    end
end

function PILGRIM_TRIBULATION_RANK_SELECT_READY(parent, btn)
    if parent ~= nil then
        local frame = parent:GetTopParentFrame();
        if frame ~= nil then
            local select_pilgrim = frame:GetUserValue("select_pilgrim");
            local list = session.SquadSystem.GetSquadMemberList(select_pilgrim);
            if list ~= nil then
                local count = list:Count();
                if count <= 0 then 
                    ui.SysMsg(ClMsg("NotExistPilgrimGroupMsg"));
                    return; 
                end
            end
            local mgame_name = frame:GetUserValue("mgame_name");
            session.TribulationSystem.ReadyPilgrimTrials(mgame_name);
        end
    end
end

function PILGRIM_TRIBULATION_RANK_SELECT_START(arg_str)
    local yes_scp = string.format('EXEC_PILGRIM_TRIBULATION_RANK_SELECT_START(\'%s\')', arg_str);
    ui.MsgBox(ClMsg("ExecStartPilgrimTrials"), yes_scp, "None");
end 

function EXEC_PILGRIM_TRIBULATION_RANK_SELECT_START(arg_str)
    if arg_str ~= nil and arg_str ~= "None" then
        session.TribulationSystem.StartPilgrimTrials(arg_str);
        ui.CloseFrame("pilgrim_tribulation_rank_select");
        ui.CloseFrame("pilgrim_select");
    end
end