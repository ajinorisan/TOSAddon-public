-- inuninfo_category.lua
-- category
function IS_CHANGEABLE_INDUNINFO_CATEGORY(indun_cls)
    if indun_cls == nil then return false; end
    local group_id = TryGetProp(indun_cls, "GroupID", "None");
    if group_id ~= "None" then
        local category_cls = GetClassByStrProp("IndunInfoCategory", "GroupID", group_id);
        if category_cls ~= nil then return true; end
    end
    return false;
end

-- category : type check
function INDUNINFO_DRAW_CATEGORY_DETAIL_LIST_BY_CATEGORY_TYPE(indun_list_box, indun_cls, is_weekly_reset, select_indun)
    if indun_list_box == nil or indun_cls == nil then return; end
    local type = "None";
    local group_id = TryGetProp(indun_cls, "GroupID", "None");
    local category_cls = GetClassByStrProp("IndunInfoCategory", "GroupID", group_id);
    if category_cls ~= nil then type = TryGetProp(category_cls, "CategoryType", "None"); end
    if type == "RaidTypeMerge" then
        indun_list_box:SetUserValue("CATEGORY_TYPE", type);
        INDUNINFO_DRAW_CATEGORY_DETAIL_LIST_BY_CATEGORY_RAIDTYPE_MERGE(indun_list_box, indun_cls, is_weekly_reset, select_indun);
    end
    
    local frame = indun_list_box:GetTopParentFrame();
    if frame ~= nil then
        local map_box = GET_CHILD_RECURSIVELY(frame, "mapBox");
        if map_box ~= nil then
            local notice_text = GET_CHILD_RECURSIVELY(map_box, "noticeText");
            if notice_text ~= nil then notice_text:ShowWindow(0); end
        end
    end
end

-- category : sort
function sort_by_raid_type(a, b)
    if a == nil or b == nil then return false; end
    local a_raid_type = a:GetUserValue("INDUN_RAID_TYPE");
    local b_raid_type = b:GetUserValue("INDUN_RAID_TYPE");
    if a_raid_type == "None" or b_raid_type == "None" then return false; end
    local function substitution_raid_type(raid_type)
        if raid_type == "Solo" then return 1;
        elseif raid_type == "SoloHard" then return 2;
        elseif raid_type == "AutoNormal" then return 3;
        elseif raid_type == "AutoHard" then return 4; 
        elseif raid_type == "PartyNormal" then return 5;
        elseif raid_type == "PartyHard" then return 6;
        elseif raid_type == 'PartyExtreme' then return 7; end
    end
    local difficulty_a = substitution_raid_type(a_raid_type);
    local difficulty_b = substitution_raid_type(b_raid_type);
    return difficulty_a < difficulty_b;
end

function INDUNINFO_DRAW_CATEGORY_DETAIL_LIST_SORT(indun_list_box, category_type)
    if indun_list_box == nil then return; end
    local frame = indun_list_box:GetTopParentFrame();
    local info_box = GET_CHILD_RECURSIVELY(frame, "infoBox");
    if info_box:IsVisible() == 0 then return; end
    if category_type == "RaidTypeMerge" then
        table.sort(g_selected_indun_category_table, sort_by_raid_type);
    end
end

-- category : skin or offset
function INDUNINFO_DRAW_CATEGORY_DETAIL_LIST_SKIN_SET(indun_list_box, category_type)
    if indun_list_box == nil then return; end
    local frame = indun_list_box:GetTopParentFrame();
    local info_box = GET_CHILD_RECURSIVELY(frame, "infoBox");
    if info_box:IsVisible() == 0 then return; end

    local first_indun_user_value_name = "None";
    local ctrl_set_user_value_name = "None";
    if category_type == "RaidTypeMerge" then
        first_indun_user_value_name = "FIRST_INDUN_RAID_TYPE";
        ctrl_set_user_value_name = "INDUN_RAID_TYPE";
    end

    local first_indun_user_value = indun_list_box:GetUserValue(first_indun_user_value_name);
    local start_y = 0;
    local scroll_width = 20;
    local margin = 18;
    local first_child = GET_CHILD_RECURSIVELY(indun_list_box, "DETAIL_CTRL_"..first_indun_user_value, "ui::CControlSet");
    if first_child ~= nil then
        start_y = first_child:GetY();
    end

    for i = 1, #g_selected_indun_category_table do
        local ctrl_set = g_selected_indun_category_table[i];
        if ctrl_set ~= nil then
            ctrl_set:SetOffset(ctrl_set:GetX(), start_y + ctrl_set:GetHeight() * (i - 1));
            INDUNINFO_DETAIL_SET_SKIN(ctrl_set, i);
            local skin_box = GET_CHILD_RECURSIVELY(ctrl_set, "skinBox");
            skin_box:Resize(ctrl_set:GetWidth() - scroll_width - margin, skin_box:GetHeight());
            if i == 1 then
                local value = ctrl_set:GetUserValue(ctrl_set_user_value_name);
                indun_list_box:SetUserValue("FIRST_INDUN_RAID_TYPE", value);
            end
        end
    end

    if frame:GetUserValue("CONTENTS_ALERT") ~= "TRUE" then
        indun_list_box:SetUserValue("FIRST_INDUN_RAID_TYPE", first_indun_user_value);
    end
    frame:SetUserValue("ONTENTS_ALERT", "FALSE");
end

-- category : weekend_contents
function INDUNINFO_DRAW_CATEGORY_DETAIL_LIST_WEEKEND_CONTENTS(indun_list_box, indun_id)
    if indun_list_box == nil or indun_id == nil then return; end
    local indun_cls = GetClassByType("Indun", indun_id);
    if indun_cls == nil then return; end
    local name = TryGetProp(indun_cls, "Name", "None");
    local difficulty = TryGetProp(indun_cls, "Difficulty", "None");
    local raid_type = TryGetProp(indun_cls, "RaidType", "None");
    local ctrl_set = indun_list_box:GetControlSet("indun_detail_ctrl", "DETAIL_CTRL_"..raid_type);
    if ctrl_set ~= nil then
        local msg = ClMsg("WeekendEventContents").." / "..name;
        ctrl_set:SetTextTooltip(msg);
        local prefix = "{@st31b}{#00ee00}";
        local name_text = GET_CHILD_RECURSIVELY(ctrl_set, "nameText");
        name_text:SetTextByKey("name", prefix..difficulty);
    end
end

-- category : raid type merge
function INDUNINFO_DRAW_CATEGORY_DETAIL_LIST_BY_CATEGORY_RAIDTYPE_MERGE(indun_list_box, indun_cls, is_weekly_reset, select_indun)
    if indun_list_box == nil or indun_cls == nil then return; end
    local class_id = TryGetProp(indun_cls, "ClassID", 0);
    local class_name = TryGetProp(indun_cls, "ClassName", "None");
    local raid_type = TryGetProp(indun_cls, "RaidType", "None");
    local group_id = TryGetProp(indun_cls, "GroupID", "None");
    local indun_detail_ctrl = indun_list_box:GetControlSet("indun_detail_ctrl", "DETAIL_CTRL_"..raid_type);
    if indun_detail_ctrl == nil then
        indun_detail_ctrl = indun_list_box:CreateOrGetControlSet("indun_detail_ctrl", "DETAIL_CTRL_"..raid_type, 0, 0);
        indun_detail_ctrl = tolua.cast(indun_detail_ctrl, "ui::CControlSet");
        indun_detail_ctrl:SetUserValue("INDUN_RAID_TYPE", raid_type);
        indun_detail_ctrl:SetUserValue("INDUN_GROUP_ID", group_id);
        indun_detail_ctrl:SetEventScript(ui.LBUTTONUP, "INDUNINFO_DETAIL_LBTN_CLICK_BY_RAID_TYPE");
        indun_detail_ctrl:SetEventScriptArgString(ui.LBUTTONUP, "click");
    
        local level = TryGetProp(indun_cls, "Level", 0);
        local name = TryGetProp(indun_cls, "Name", "None");
        local dungeon_type = TryGetProp(indun_cls, "DungeonType", "None");
        local ticketing_type = TryGetProp(indun_cls, "TicketingType", "None");
        local playper_reset_type = TryGetProp(indun_cls, "PlayPerResetType", 0);
    
        -- level
        local info_text = GET_CHILD_RECURSIVELY(indun_detail_ctrl, "infoText");
        info_text:SetTextByKey("level", level);
    
        -- name, count, cycle
        local name_text = GET_CHILD_RECURSIVELY(indun_detail_ctrl, "nameText");
        local count_text = GET_CHILD_RECURSIVELY(indun_detail_ctrl, "countText");
        local cycle_pic = GET_CHILD_RECURSIVELY(indun_detail_ctrl, "cycleCtrlPic");
        if difficulty == "None" then
            name_text:SetTextByKey("name", name);
            count_text:ShowWindow(0);
            cycle_pic:ShowWindow(0);
        else
            local difficulty = TryGetProp(indun_cls, "Difficulty", "None");
            name_text:SetTextByKey("name", difficulty);
            if ticketing_type == "Entrance_Ticket" then
                count_text:SetText(ScpArgMsg("ChallengeMode_HardMode_Count", "Count", GET_CURRENT_ENTERANCE_COUNT(playper_reset_type)));
                cycle_pic:ShowWindow(0);
            else
                count_text:SetTextByKey("current", GET_CURRENT_ENTERANCE_COUNT(playper_reset_type));
                count_text:SetTextByKey("max", GET_INDUN_MAX_ENTERANCE_COUNT(playper_reset_type));
                INDUNINFO_SET_CYCLE_PIC(cycle_pic, indun_cls, "_s");
            end
        end
    
        -- online pic
        local online_pic = GET_CHILD_RECURSIVELY(indun_detail_ctrl, "onlinePic");
        if dungeon_type ~= "Ancient" then online_pic:ShowWindow(0); end
    
        -- select
        if #g_selected_indun_category_table == 0 then
            indun_list_box:SetUserValue("FIRST_INDUN_RAID_TYPE", raid_type);
            INDUNINFO_DETAIL_LBTN_CLICK_BY_RAID_TYPE(indun_list_box, indun_detail_ctrl);
        end
        if dungeon_type == select_indun then
            INDUNINFO_DETAIL_LBTN_CLICK_BY_RAID_TYPE(indun_list_box, indun_detail_ctrl);    
        end
        table.insert(g_selected_indun_category_table, indun_detail_ctrl);
      
        -- weekly enterance text setting
        INDUNINFO_DRAW_CATEGORY_DETAIL_LIST_SET_WEEKLY_ENTERANCE(indun_list_box, indun_cls, dungeon_type, is_weekly_reset);
    end
end

-- category : raid type merge -> select first
function INDUNINFO_DEATIL_FIRST_LBTN_CLICK_BY_RAID_TYPE(parent)
    if parent ~= nil then
        if #g_selected_indun_category_table > 0 then
            local ctrl_set = g_selected_indun_category_table[1];
            INDUNINFO_DETAIL_LBTN_CLICK_BY_RAID_TYPE(parent, ctrl_set);
        end
    end
end

-- category : raid type merge -> deatil LBTN click
function INDUNINFO_DETAIL_LBTN_CLICK_BY_RAID_TYPE(parent, ctrl_set, clicked)
    local indun_raid_type = ctrl_set:GetUserValue("INDUN_RAID_TYPE");
    local indun_group_id = ctrl_set:GetUserValue("INDUN_GROUP_ID");
    local pre_select_raid_type = parent:GetUserValue("SELECT_RAID_TYPE");
    if indun_raid_type == pre_select_raid_type then return; end
    if clicked == "click" then
        imcSound.PlaySoundEvent("button_click_7");
    end
    if pre_select_raid_type == "None" then
        pre_select_raid_type = "Solo";
    end
    -- set skin
    local pre_select_ctrl = GET_CHILD_RECURSIVELY(parent, "DETAIL_CTRL_"..pre_select_raid_type);
    if pre_select_ctrl ~= nil then
        local index = 0;
        for i = 1, #g_selected_indun_category_table do
            local child = g_selected_indun_category_table[i];
            if child ~= nil and child:GetUserValue("INDUN_RAID_TYPE") == pre_select_raid_type then
                index = i;
                break;
            end
        end
        INDUNINFO_DETAIL_SET_SKIN(pre_select_ctrl, index);
    end
    local select_box_skin = ctrl_set:GetUserConfig("SELECTED_BOX_SKIN");
    local skin_box = GET_CHILD_RECURSIVELY(ctrl_set, "skinBox");
    skin_box:SetSkinName(select_box_skin);
    -- select raid type
    parent:SetUserValue("SELECT_RAID_TYPE", indun_raid_type);
    local frame = parent:GetTopParentFrame();
    INDUNINFO_MAKE_DETAIL_BOSS_SELECT_BY_RAID_TYPE(frame, parent, indun_group_id, indun_raid_type);
    INDUNINFO_DEATIL_FIRST_BOSS_SELECT_LBTN_CLICK(parent);
end

-- category : make boss select
function GET_INDUNINFO_CATEOGRY_CLASS_BY_RAID_TYPE(group_id, raid_type)
    if group_id == nil or raid_type == nil then return; end
    local list, cnt = GetClassList("IndunInfoCategory");
    if list ~= nil and cnt > 0 then
        for i = 0, cnt - 1 do
            local class = GetClassByIndexFromList(list, i);
            if class ~= nil then
                local cls_group_id = TryGetProp(class, "GroupID", "None");
                local cls_raid_type = TryGetProp(class, "RaidType", "None");
                if cls_group_id == group_id and cls_raid_type == raid_type then
                    return class;  
                end
            end
        end
    end
    return nil;
end

function INDUNINFO_MAKE_DETAIL_BOSS_SELECT_BY_RAID_TYPE(frame, indun_list_box, group_id, raid_type)
    if frame == nil or raid_type == nil then return; end
    local category_cls = GET_INDUNINFO_CATEOGRY_CLASS_BY_RAID_TYPE(group_id, raid_type);
    if category_cls == nil then return; end
    -- total count
    local total_count = TryGetProp(category_cls, "TotalCount");
    -- indun_class_name
    local indun_class_names = TryGetProp(category_cls, "IncludeIndunClassName");
    local indun_class_name_list = StringSplit(indun_class_names, '/');
    -- indun_picture
    local indun_pictures = TryGetProp(category_cls, "IncludeIndunPictrue");
    local indun_picture_list = StringSplit(indun_pictures, '/');
    -- visible
    local restrict_skill_box = GET_CHILD_RECURSIVELY(frame, "restrictSkillBox");
    local restrict_item_box = GET_CHILD_RECURSIVELY(frame, "restrictItemBox");
    local restrict_dungeon_box = GET_CHILD_RECURSIVELY(frame, "restrictDungeonBox");
    restrict_skill_box:ShowWindow(0);
    restrict_item_box:ShowWindow(0);
    restrict_dungeon_box:ShowWindow(0);
    -- boss select button
    local indun_pic = GET_CHILD_RECURSIVELY(frame, "indunPic");
    if indun_pic ~= nil then
        indun_pic:RemoveAllChild();
        indun_pic:SetImage("");
        local start_y = 0;
        local space_y = 3;
        local offset_y = math.floor(indun_pic:GetHeight() / total_count);
        for i = 1, total_count do
            local indun_class_name = indun_class_name_list[i];
            local indun_pic_name = indun_picture_list[i];
            local ctrl_set = indun_pic:CreateOrGetControlSet("indun_pic_boss", indun_class_name, 0, start_y + (offset_y * (i - 1) + ((i - 1) * space_y)));;
            if ctrl_set ~= nil then
                -- pic
                local pic_select = GET_CHILD_RECURSIVELY(ctrl_set, "pic_select");
                local pic_lock = GET_CHILD_RECURSIVELY(ctrl_set, "pic_lock");
                local indun_class = GetClass("Indun", indun_class_name);
                if indun_class ~= nil then
                    pic_select:ShowWindow(0);
                    pic_lock:ShowWindow(0);
                else
                    pic_select:ShowWindow(0);
                    pic_lock:ShowWindow(1);
                    pic_lock:Resize(pic_lock:GetWidth(), offset_y);
                end
                -- image
                local btn_boss = GET_CHILD_RECURSIVELY(ctrl_set, "btn_boss", "ui::CButton");
                local pic_boss = GET_CHILD_RECURSIVELY(ctrl_set, "pic_boss");
                if indun_pic_name ~= nil and indun_pic_name ~= "" and indun_pic_name ~= "None" then
                    pic_boss:SetImage(indun_pic_name);
                end
                pic_boss:Resize(pic_boss:GetWidth(), offset_y);
                btn_boss:Resize(btn_boss:GetWidth(), offset_y);
                btn_boss:SetEventScript(ui.LBUTTONUP, "INDUNINFO_DETAIL_BOSS_SELECT_LBTN_CLICK");
                btn_boss:SetEventScriptArgString(ui.LBUTTONUP, "click");
                -- name
                local btn_text = GET_CHILD_RECURSIVELY(ctrl_set, "btn_text");
                if indun_class ~= nil then
                    local boss_list_str = TryGetProp(indun_class, "BossList", "None");
                    local boss_list = StringSplit(boss_list_str, '/');
                    if boss_list ~= nil and #boss_list > 0 then
                        for i = 1, #boss_list do
                            local boss_name = boss_list[i];
                            local mon_cls = GetClass("Monster", boss_name);
                            if mon_cls ~= nil then
                                local name = TryGetProp(mon_cls, "Name");
                                if name ~= "None" then
                                    btn_text:SetTextByKey("name", name);
                                end
                            end
                        end
                    end
                end
                ctrl_set = tolua.cast(ctrl_set, "ui::CControlSet");
                ctrl_set:SetUserValue("GROUP_ID", group_id);
                ctrl_set:SetUserValue("RAID_TYPE", raid_type);
                ctrl_set:Resize(ctrl_set:GetWidth(), offset_y);
            end
        end
    end
end

-- category : select show btn
function INDUNINFO_DETAIL_BOSS_SELECT_CHECK_UPDATE(parent, ctrl_set)
    if parent == nil or ctrl_set == nil then return; end
    local count = parent:GetChildCount();
    for i = 0, count - 1 do
        local child = parent:GetChildByIndex(i);
        if child ~= nil then
            local pic_select = GET_CHILD_RECURSIVELY(child, "pic_select");
            if pic_select ~= nil then
                if child:GetName() == ctrl_set:GetName() then
                    pic_select:ShowWindow(1);
                else
                    pic_select:ShowWindow(0);                
                end
            end
        end
    end
end

-- category : is lock state
function IS_INDUNINFO_DETAIL_BOSS_SELECT_LOCK_STATE(ctrl_set)
    if ctrl_set == nil then return false; end
    local pic_lock = GET_CHILD_RECURSIVELY(ctrl_set, "pic_lock");
    if pic_lock ~= nil and pic_lock:IsVisible() == 1 then return true; end
    return false;
end

-- category : boss select LBTN click -> select first
function INDUNINFO_DEATIL_FIRST_BOSS_SELECT_LBTN_CLICK(parent)
    if parent ~= nil then
        local frame = parent:GetTopParentFrame();
        if frame ~= nil then
            local indun_pic = GET_CHILD_RECURSIVELY(frame, "indunPic");
            if indun_pic ~= nil then
                local count = indun_pic:GetChildCount();
                if count > 0 then
                    local ctrl_set = indun_pic:GetChildByIndex(0);
                    if ctrl_set ~= nil then
                        local btn_boss = GET_CHILD_RECURSIVELY(ctrl_set, "btn_boss");
                        if btn_boss ~= nil then
                            INDUNINFO_DETAIL_BOSS_SELECT_LBTN_CLICK(ctrl_set, btn_boss);
                        end
                    end
                end
            end
        end
    end
end

-- category : boss select LBTN click
function INDUNINFO_DETAIL_BOSS_SELECT_LBTN_CLICK(ctrl_set, btn, clicked)
    if ctrl_set == nil or btn == nil then return; end
    local parent = ctrl_set:GetParent();
    if IS_INDUNINFO_DETAIL_BOSS_SELECT_LOCK_STATE(ctrl_set) == true then return; end
    INDUNINFO_DETAIL_BOSS_SELECT_CHECK_UPDATE(parent, ctrl_set);
    if clicked == "click" then
        imcSound.PlaySoundEvent("button_click_7");
    end
    local frame = parent:GetTopParentFrame();
    local indun_cls_name = ctrl_set:GetName();
    local indun_cls = GetClass("Indun", indun_cls_name);
    if indun_cls == nil then return; end
    INDUNFINO_MAKE_DETAIL_COMMON_INFO_BY_CATEGORY_TYPE(frame, indun_cls);
    INDUNFINO_MAKE_DETAIL_DUNGEON_RESTRICT_BY_CATEGORY_TYPE(frame, indun_cls);
    INDUNFINO_MAKE_DETAIL_ITEM_LIST_INFO_SETTING(frame, indun_cls);
end

-- category : common info
function INDUNFINO_MAKE_DETAIL_COMMON_INFO_BY_CATEGORY_TYPE(frame, indun_cls)
    if frame == nil or indun_cls == nil then return; end
    local class_id = TryGetProp(indun_cls, "ClassID", 0);
    local group_id = TryGetProp(indun_cls, "GroupID", "None");
    local reset_group_id = TryGetProp(indun_cls, "PlayPerResetType", 0);
    -- name
    local name = TryGetProp(indun_cls, "Name", "None");
    if name ~= "None" then
        local name_box = GET_CHILD_RECURSIVELY(frame, "nameBox");
        local name_text = name_box:GetChild("nameText");
        name_text:SetTextByKey("name", name);
    end
    -- level
    local level = GET_CHILD_RECURSIVELY(frame, "lvData");
    if level ~= nil then
        local lv = TryGetProp(indun_cls, "Level", 0);
        level:SetText(lv);
    end
    -- position
    local pos_box = GET_CHILD_RECURSIVELY(frame, "posBox");
    DESTROY_CHILD_BYNAME(pos_box, "MAP_CTRL_");
    pos_box:ShowWindow(0);
    -- score
    local score_box = GET_CHILD_RECURSIVELY(frame, "scoreBox");
    score_box:ShowWindow(0);
    -- raid time
    local raid_time_box = GET_CHILD_RECURSIVELY(frame, "raid_time_box");
    if raid_time_box ~= nil then 
        raid_time_box:ShowWindow(0);
    end
    -- map 
    local start_map = TryGetProp(indun_cls, "StartMap", "");
    local map_list = StringSplit(start_map, '/');
    if map_list ~= nil and #map_list > 0 then
        for i = 1, #map_list do
            local map_cls = GetClass("Map", map_list[i]);
            if map_cls ~= nil then
                local map_class_id = TryGetProp(map_cls, "ClassID", 0);
                local map_name = TryGetProp(map_cls, "Name", "None");
                local ctrl_set = pos_box:CreateOrGetControlSet("indun_pos_ctrl", "MAP_CTRL_"..map_class_id, 0, 0);
                if ctrl_set ~= nil then
                    ctrl_set:SetGravity(ui.RIGHT, ui.TOP);
                    ctrl_set:SetOffset(0, 10 + (10 + ctrl_set:GetHeight()) * (i - 1));
                    ctrl_set:SetUserValue("INDUN_CLASS_ID", class_id);
                    ctrl_set:SetUserValue("INDUN_START_MAP_ID", map_class_id);
                    local map_name_text = GET_CHILD_RECURSIVELY(ctrl_set, "mapNameText");
                    if map_name_text ~= nil then
                        map_name_text:SetText(map_name);
                    end
                end
            end
        end
        pos_box:ShowWindow(1);
    end
    INDUNINFO_SET_BUTTONS(frame, indun_cls);
    INDUNINFO_MAKE_PATTERN_BOX(frame, indun_cls);
end

-- category : dungeon restrict
function INDUNFINO_MAKE_DETAIL_DUNGEON_RESTRICT_BY_CATEGORY_TYPE(frame, indun_cls)
    if frame == nil or indun_cls == nil then return; end
    INDUNENTER_MAKE_MONLIST(frame, indun_cls);
    -- tooltip type
    local tooltip_type = "None";
    local class_name = TryGetProp(indun_cls, "ClassName", "None");
    local group_id = TryGetProp(indun_cls, "GroupID", "None");
    local raid_type = TryGetProp(indun_cls, "RaidType", "None");
    local category_cls = GET_INDUNINFO_CATEOGRY_CLASS_BY_RAID_TYPE(group_id, raid_type);
    if category_cls ~= nil then
        tooltip_type = TryGetProp(category_cls, "DungeonRestrictTooltip", "None");
    end
    -- count box unvisible
    local count_box = GET_CHILD_RECURSIVELY(frame, "countBox");
    if count_box ~= nil then
        count_box:ShowWindow(0);
    end
    -- restrict box visible
    local dungeon_restrict_box = GET_CHILD_RECURSIVELY(frame, "gbox_ct_dungeon_restrict");
    if dungeon_restrict_box ~= nil then
        dungeon_restrict_box:ShowWindow(1);
        dungeon_resetric_over = GET_CHILD_RECURSIVELY(dungeon_restrict_box, "pic_ct_dungeon_resetric_over");
        if dungeon_resetric_over ~= nil then
            local tooltip_pos_x = frame:GetUserConfig("TOOLTIP_POSX");
            local tooltip_pos_y = frame:GetUserConfig("TOOLTIP_POSY");
            dungeon_resetric_over:SetPosTooltip(tooltip_pos_x, tooltip_pos_y);
            dungeon_resetric_over:SetTooltipOverlap(1);
            dungeon_resetric_over:SetTooltipType(tooltip_type);
            dungeon_resetric_over:SetTooltipArg(class_name);
        end
    end
end

-- category : item list info setting
function INDUNFINO_MAKE_DETAIL_ITEM_LIST_INFO_SETTING(frame, indun_cls)
    if frame == nil or indun_cls == nil then return; end
    local indun_list_box = GET_CHILD_RECURSIVELY(frame, "INDUN_LIST_BOX");
    if indun_list_box ~= nil then
        local class_id = TryGetProp(indun_cls, "ClassID", 0);
        indun_list_box:SetUserValue("SELECTED_DETAIL", class_id);
    end
end