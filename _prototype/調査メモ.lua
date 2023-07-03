-- このコードで一旦入れるかどうかをセットする？
function INDUNINFO_MAKE_DETAIL_BOSS_SELECT_BY_RAID_TYPE(frame, indun_list_box, group_id, raid_type)
    if frame == nil or raid_type == nil then
        return;
    end
    local category_cls = GET_INDUNINFO_CATEOGRY_CLASS_BY_RAID_TYPE(group_id, raid_type);
    if category_cls == nil then
        return;
    end
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
            local ctrl_set = indun_pic:CreateOrGetControlSet("indun_pic_boss", indun_class_name, 0,
                                                             start_y + (offset_y * (i - 1) + ((i - 1) * space_y)));
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
