function NOTICE_RAID_PATTERN_ON_INIT(addon, frame)
    addon:RegisterMsg('NOTICE_Dm_Raid_Pattern_!', 'NOTICE_RAID_PATTERN_ON_MSG');
    addon:RegisterMsg('NOTICE_Dm_levelup_base', 'NOTICE_RAID_PATTERN_ON_MSG');
    addon:RegisterMsg('NOTICE_Dm_GuildQuestSuccess', 'NOTICE_RAID_PATTERN_ON_MSG');
    addon:RegisterMsg('NOTICE_Dm_GuildQuestFail', 'NOTICE_RAID_PATTERN_ON_MSG');
end

function NOTICE_RAID_PATTERN_CLOSE(frame)
    frame:ShowWindow(0); 
    local gbox = GET_CHILD_RECURSIVELY(frame, "gbox");
    if gbox ~= nil then
        gbox:RemoveAllChild();
    end
end

function NOTICE_RAID_PATTERN_ON_MSG(frame, msg, argStr, argNum) 
    if frame == nil then return; end
    frame:ShowWindow(1);
    frame:Invalidate(); 
    
    local duration = frame:GetDuration();
    if duration ~= argNum then
        if duration < 5 then duration = duration + argNum; end
        if duration > 5 then duration = 5; end
    end
    frame:SetDuration(duration + argNum);
    
    local gbox = GET_CHILD_RECURSIVELY(frame, "gbox");
    if gbox == nil then return; end
    gbox:ShowWindow(1);

    local notice_text = argStr;
    if msg == "NOTICE_Dm_Raid_Pattern_!" then
        local text = GET_CHILD_RECURSIVELY(gbox, msg..notice_text);
        if text == nil then
            local text = gbox:CreateControl("richtext", msg..notice_text, gbox:GetWidth(), 30, ui.CENTER_HORZ, ui.TOP, 0, 0, 0, 0);
            if text ~= nil then
                tolua.cast(text, "ui::CRichText");
                text:SetOffset(0, 0);
                text:SetVisible(1);
                text:SetText("{@st41_red}"..notice_text);
            end
        end

        local picture = GET_CHILD_RECURSIVELY(frame, "picture");
        if picture == nil then return; end
        tolua.cast(picture, "ui::CPicture");
        picture:ShowWindow(1);
        picture:SetOffset(0, 0);
        picture:SetImage("NOTICE_Dm_!");
        picture:SetVisible(1);
        NOTICE_RAID_PATTERN_GBOX_AUTO_ALIGN(frame, gbox, picture:GetHeight(), 0, 0, 0, true, true);

        imcSound.PlaySoundEvent("sys_quest_message");
    end

    if msg ~= 'NOTICE_Dm_levelup_base' and msg ~= "NOTICE_Dm_GuildQuestSuccess" and msg ~= "NOTICE_Dm_GuildQuestFail" then
        frame:ShowFrame(0);
    end
end

function NOTICE_RAID_PATTERN_GBOX_AUTO_ALIGN(frame, gbox, start_y, space_y, gbox_add_y, align_by_margin, auto_resize_gbox)
    if gbox == nil then return; end
    local count = gbox:GetChildCount();
    if count == 0 then 
        return; 
    end

    local y = start_y;
    local line_count = 0;
    for i = 0, count - 1 do
        local child = gbox:GetChildByIndex(i);
        if child ~= nil and string.find(child:GetName(), "gbox") == nil then
            line_count = line_count + 1;
            if align_by_margin == true then
                local rect = child:GetMargin();
                child:SetMargin(rect.left, line_count * y, rect.right, rect.bottom);
            else
                child:SetOffset(0, y);
            end
            y = y + child:GetHeight() + space_y;
        end
    end

    if auto_resize_gbox == true then
        gbox:Resize(gbox:GetWidth(), y + gbox_add_y);
        local picture = GET_CHILD_RECURSIVELY(frame, "picture");
        if picture ~= nil then
            frame:Resize(frame:GetWidth(), y + gbox_add_y);        
        end
    end
end