function PILGRIM_TRIBULATION_INDUNINFO_ON_INIT(addon, frame)
    addon:RegisterMsg("PILGRIM_TRIBULATION_INDUNINFO_START", "ON_PILGRIM_TRIBULATION_INDUNINFO_MSG");
end

function PILGRIM_TRIBULATION_INDUNINFO_CLOSE(frame)
    if frame == nil then return; end
    ui.CloseFrame("pilgrim_tribulation_induninfo");
end

function PILGRIM_TRIBULATION_INDUNINFO_REQ(mgame_name)
    if mgame_name == nil or mgame_name == "None" then return; end
    session.TribulationSystem.SendRequestTribulationInfoByIndunInfo(mgame_name);    
end

-- auto select
function PILGRIM_TRIBULATION_INDUNINFO_AUTO_SELECT_TRIBULATION(frame)
    if frame == nil then return; end
    local gb = GET_CHILD_RECURSIVELY(frame, "gb_tribulation_list");
    if gb ~= nil then
        local count = gb:GetChildCount();
        if count > 0 then
            for i = 0, count - 1 do
                local child = gb:GetChildByIndex(i);
                if child ~= nil and string.find(child:GetName(), "tribulation_info") ~= nil then
                    local btn = GET_CHILD_RECURSIVELY(child, "btn_info");
                    if btn ~= nil then
                        ON_PILGRIM_TRIBULATION_INDUNINFO_TRIBULATION_INFO_SELECT(child, btn); 
                    end
                end
            end
        end
        gb:Invalidate();
    end
end

-- msg
function ON_PILGRIM_TRIBULATION_INDUNINFO_MSG(frame, msg, arg_str, arg_num)
    if msg == "PILGRIM_TRIBULATION_INDUNINFO_START" then
        local frame = ui.GetFrame("pilgrim_tribulation_induninfo");
        if frame ~= nil then                        
            frame:ShowWindow(1);
            PILGRIM_TRIBULATION_INDUNINFO_INIT(frame, arg_str);
            PILGRIM_TRIBULATION_INDUNINFO_FILL_CATEGROY(frame);
            PILGRIM_TRIBULATION_INDUNINFO_FILL_TRIBULATION_INFO(frame);
            PILGRIM_TRIBULATION_INDUNINFO_FILL_BOTTOM(frame);
        end
    end
end

local s_category_list = { "pc", "monster", "pattern_fix" };
function PILGRIM_TRIBULATION_INDUNINFO_INIT(frame, arg_str)
    if frame ~= nil then
        frame:SetUserValue("mgame_name", arg_str);
        frame:SetUserValue("rank", 1);
        frame:SetUserValue("category", "pc");
        frame:SetUserValue("category_index", 1);
    end
end

function PILGRIM_TRIBULATION_INDUNINFO_FILL_CATEGROY(frame)
    if frame == nil then return; end
    local category = frame:GetUserValue("category");
    local gb = GET_CHILD_RECURSIVELY(frame, "gb_category_name");
    if gb ~= nil then
    local text_category = GET_CHILD_RECURSIVELY(gb, "text_category_name");
    if text_category ~= nil then
        local title = "";
        if category == "pc" then
            title = ClMsg("TribulationCategoryPC");
        elseif category == "monster" then
            title = ClMsg("TribulationCategoryMonster");
        elseif category == "pattern_fix" then
            title = ClMsg("TribulationCategoryFixPattern");
        end
        text_category:SetTextByKey("title", title);          
    end
        gb:Invalidate();
    end
end

function ON_PILGRIM_TRIBULATION_INDUNINFO_CATEGORY_PREV(parent, btn)
    if parent ~= nil then
        local frame = parent:GetTopParentFrame();
        local index = frame:GetUserIValue("category_index");
        if index <= 1 then return; end
        index = index - 1;
        frame:SetUserValue("category_index", index);
        local category = s_category_list[index];
        frame:SetUserValue("category", category);
        PILGRIM_TRIBULATION_INDUNINFO_FILL_CATEGROY(frame);
        PILGRIM_TRIBULATION_INDUNINFO_FILL_TRIBULATION_INFO(frame);
        PILGRIM_TRIBULATION_INDUNINFO_FILL_BOTTOM(frame);
        PILGRIM_TRIBULATION_INDUNINFO_AUTO_SELECT_TRIBULATION(frame);
    end
end

function ON_PILGRIM_TRIBULATION_INDUNINFO_CATEGORY_NEXT(parent, btn)
    if parent ~= nil then
        local frame = parent:GetTopParentFrame();
        local index = frame:GetUserIValue("category_index");
        if index >= 3 then return; end
        index = index + 1;
        frame:SetUserValue("category_index", index);
        local category = s_category_list[index];
        frame:SetUserValue("category", category);
        PILGRIM_TRIBULATION_INDUNINFO_FILL_CATEGROY(frame);
        PILGRIM_TRIBULATION_INDUNINFO_FILL_TRIBULATION_INFO(frame);
        PILGRIM_TRIBULATION_INDUNINFO_FILL_BOTTOM(frame);
        PILGRIM_TRIBULATION_INDUNINFO_AUTO_SELECT_TRIBULATION(frame);
    end
end

-- tribulation
function GET_CATEGORY_STR(category)
    if category == "pc" then return "PC"; end
    if category == "monster" then return "Monster"; end
    if category == "pattern_fix" then return "Pattern"; end
end

function PILGRIM_TRIBULATION_INDUNINFO_FILL_TRIBULATION_INFO(frame)
    if frame == nil then return; end
    PILGRIM_TRIBULATION_INDUNINFO_FILL_TRIBULATION_LIST(frame);
end

function PILGRIM_TRIBULATION_INDUNINFO_FILL_TRIBULATION_LIST(frame)
    if frame == nil then return; end
    local mgame_name = frame:GetUserValue("mgame_name");
    local category = frame:GetUserValue("category");
    local cate_str = GET_CATEGORY_STR(category);
    local select_rank = frame:GetUserIValue("rank");
    local gb = GET_CHILD_RECURSIVELY(frame, "gb_tribulation_list");
    gb:RemoveAllChild();
    if gb ~= nil then
        if category == "pc" or category == "monster" then
            local index = 0;
            local count = session.TribulationSystem.GetIndunInfoTribulationCount(mgame_name, cate_str);
            for i = 0, count - 1 do
                local rank = session.TribulationSystem.GetIndunInfoTribulationRankByIndex(mgame_name, cate_str, i);
                local title = session.TribulationSystem.GetIndunInfoTribulationTitleByIndex(mgame_name, cate_str, i);
                local icon = session.TribulationSystem.GetIndunInfoTribulationIconByIndex(mgame_name, cate_str, i);
                if select_rank == rank then
                    local name = "tribulation_info.."..category.."_"..i;
                    local ctrl_set = gb:CreateOrGetControlSet("tribulation_item_induninfo", name, 0, (index * 60) + (index * 3));
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
        elseif category == "pattern_fix" then
            local index = 0;
            local count = session.TribulationSystem.GetIndunInfoTribulationPatternCount(mgame_name, cate_str);
            for i = 0, count - 1 do
                local title = session.TribulationSystem.GetIndunInfoTribulationPatternTitleByIndex(mgame_name, cate_str, i);
                local icon = session.TribulationSystem.GetIndunInfoTribulationPatternIconByIndex(mgame_name, cate_str, i);
                local rank = session.TribulationSystem.GetIndunInfoTribulationPatternRankByIndex(mgame_name, cate_str, i);
                if cate_str == "Pattern" then
                    local name = "tribulation_info.."..category.."_"..i;
                    local ctrl_set = gb:CreateOrGetControlSet("tribulation_item_induninfo", name, 0, (index * 60) + (index * 3));
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
        end
        gb:Invalidate();
    end
end

function ON_PILGRIM_TRIBULATION_INDUNINFO_TRIBULATION_INFO_SELECT(parent, btn, arg_str, arg_num)
    if parent ~= nil then
        local frame = parent:GetTopParentFrame();
        local mgame_name = frame:GetUserValue("mgame_name");
        local category = frame:GetUserValue("category");
        local cate_str = GET_CATEGORY_STR(category);
        local slot_index = parent:GetUserIValue("slot_index");
        PILGRIM_TRIBULATION_INDUNINFO_FILL_TRIBULATION_DETAIL(frame, parent);
    end
end

function PILGRIM_TRIBULATION_INDUNINFO_FILL_TRIBULATION_DETAIL(frame, ctrl_set)
    if frame == nil then return; end
    local mgame_name = frame:GetUserValue("mgame_name");
    local category = frame:GetUserValue("category");
    local cate_str = GET_CATEGORY_STR(category);
    -- desc
    local gb = GET_CHILD_RECURSIVELY(frame, "gb_tribulation_detail");
    if gb ~= nil then
        local pic_tribulation_icon = GET_CHILD_RECURSIVELY(gb, "pic_tribulation_icon");
        if pic_tribulation_icon ~= nil then
            local pic_icon = GET_CHILD_RECURSIVELY(ctrl_set, "pic_rank_icon");
            if pic_icon ~= nil then
                local imgae_name = pic_icon:GetImageName();
                pic_tribulation_icon:SetImage(imgae_name);
            end
        end

        local slot_index = ctrl_set:GetUserIValue("slot_index");
        local text_desc = GET_CHILD_RECURSIVELY(gb, "text_desc");
        if text_desc ~= nil then
            if category == "pc" or category == "monster" then
                local desc = session.TribulationSystem.GetIndunInfoTribulationDescByIndex(mgame_name, cate_str, slot_index);
                text_desc:SetTextByKey("desc", desc);
            elseif category == "pattern_fix" then
                local desc = session.TribulationSystem.GetIndunInfoTribulationPatternDescByIndex(mgame_name, cate_str, slot_index);
                text_desc:SetTextByKey("desc", desc);
            end
        end
        gb:Invalidate();
    end
end

-- rank
function PILGRIM_TRIBULATION_INDUNINFO_FILL_BOTTOM(frame)
    if frame == nil then return; end
    local rank = frame:GetUserIValue("rank");
    local category = frame:GetUserValue("category");
    local gb = GET_CHILD_RECURSIVELY(frame, "gb_bottom");
    if gb ~= nil then
        -- icon
        local pic_rank_icon = GET_CHILD_RECURSIVELY(gb, "pic_rank_icon");
        if pic_rank_icon ~= nil then
            if category == "pc" or category == "monster" then
                local rank_icon_image = "tribal_icon_level_0"..rank;
                pic_rank_icon:SetImage(rank_icon_image);
            else
                pic_rank_icon:SetImage("tribal_icon_level_00");
            end
        end
        -- btn
        local btn_rank_down = GET_CHILD_RECURSIVELY(gb, "btn_rank_down");
        local btn_rank_up = GET_CHILD_RECURSIVELY(gb, "btn_rank_up");
        if category == "pattern_fix" then
            btn_rank_down:ShowWindow(0);
            btn_rank_up:ShowWindow(0);
        else
            btn_rank_down:ShowWindow(1);
            btn_rank_up:ShowWindow(1);
        end
        gb:Invalidate();
    end
end

function ON_PILGRIM_TRIBULATION_INDUNINFO_RANK_DOWN(parent, btn, arg_str, arg_num)
    if parent ~= nil then
        local frame = parent:GetTopParentFrame();
        local rank = frame:GetUserIValue("rank");
        if rank <= 1 then
            ui.SysMsg(ClMsg("TribulationHighestLowRankLevel"));
            return;
        end
        rank = rank - 1;
        frame:SetUserValue("rank", rank);
        PILGRIM_TRIBULATION_INDUNINFO_FILL_TRIBULATION_INFO(frame);
        PILGRIM_TRIBULATION_INDUNINFO_FILL_BOTTOM(frame);
        PILGRIM_TRIBULATION_INDUNINFO_AUTO_SELECT_TRIBULATION(frame);
    end
end

function ON_PILGRIM_TRIBULATION_INDUNINFO_RANK_UP(parent, btn, arg_str, arg_num)
    if parent ~= nil then
        local frame = parent:GetTopParentFrame();
        local rank = frame:GetUserIValue("rank");
        if rank >= 4 then            
            ui.SysMsgWithoutMessageBox(ClMsg("TribulationHighestRankLevel"))
            return;
        end
        rank = rank + 1;
        frame:SetUserValue("rank", rank);
        PILGRIM_TRIBULATION_INDUNINFO_FILL_TRIBULATION_INFO(frame);
        PILGRIM_TRIBULATION_INDUNINFO_FILL_BOTTOM(frame);
        PILGRIM_TRIBULATION_INDUNINFO_AUTO_SELECT_TRIBULATION(frame);
    end
end