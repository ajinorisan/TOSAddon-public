-- obj interaction cool time
function OBJECT_INTERACTION_COOL_TIME_ON_INIT(addon, frame)
    addon:RegisterMsg("COOL_TIME_START", "OBJECT_INTERACTION_COOL_TIME_ON_MSG");
    addon:RegisterMsg("COOL_TIME_END", "OBJECT_INTERACTION_COOL_TIME_ON_MSG");
end

function OBJECT_INTERACTION_COOL_TIME_ON_MSG(frame, msg, arg_str, arg_num)
    if msg == "COOL_TIME_START" then
        frame:ShowWindow(1);
        local cool_time = arg_str;
        local handle = tonumber(arg_num);
        if handle ~= 0 and cool_time ~= "" and cool_time ~= "0" then
            frame:SetUserValue("SUFFIX", handle);
            OBJECT_INTERACTION_COOL_TIME_CREATE_UI(frame, cool_time, handle);
        end
    elseif msg == "COOL_TIME_END" then
        frame:ShowWindow(0);
        local handle = tonumber(arg_num);
        OBJECT_INTERACTION_COOL_TIME_REMOVE_UI(frame, handle);
    end
end

function OBJECT_INTERACTION_COOL_TIME_CREATE_UI(frame, cool_time, handle)
    local ui_name = "object_cool_time_"..handle;
    local new_frame = ui.GetFrame(ui_name);
    if new_frame == nil then
        new_frame = ui.CreateNewFrame("object_interaction_cool_time", tostring(ui_name));
    end
    new_frame:ShowWindow(1);
    new_frame:SetUserValue("HANDLE", handle);
    new_frame:RunUpdateScript("OBJECT_INTERACTION_COOL_TIME_POS_UPDATE");

    local bg = GET_CHILD_RECURSIVELY(new_frame, "bg");
    if bg == nil then return; end

    local slot = GET_CHILD_RECURSIVELY(new_frame, "cool_time_slot");
    if slot == nil then
        slot = bg:CreateControl("slot", slot_name, bg:GetWidht(), bg:GetHeight(), ui.CENTER_HORZ, ui.TOP, 0, 0, 0, 0);
        if slot ~= nil then
            local icon = CreateIcon(slot);
            if icon ~= nil then
                OBJECT_INTERACTION_COOL_TIME_ICON_SET(icon, cool_time);
            end
        end
    else
        local icon = slot:GetIcon();
        if icon == nil then icon = CreateIcon(slot); end
        OBJECT_INTERACTION_COOL_TIME_ICON_SET(icon, cool_time);
    end
end

function OBJECT_INTERACTION_COOL_TIME_ICON_SET(icon, cool_time)
    if icon ~= nil then
        icon:SetImage("Interaction_SkillCooldown");
        icon:SetColorTone("FFFFFFFF");
        icon:SetUserValue("cool_down_start", imcTime.GetAppTime());
        icon:SetUserValue("cool_down", cool_time / 1000);
        icon:SetOnCoolTimeUpdateScp("OBJECT_INTERACTION_COOL_TIME_ICON_UPDATE");
    end
end

function OBJECT_INTERACTION_COOL_TIME_ICON_UPDATE(icon)
    local cur_time = imcTime.GetAppTime() - icon:GetUserIValue("cool_down_start");
    local total_time = icon:GetUserIValue("cool_down");
    if cur_time > total_time then
        icon:RemoveCoolTimeUpdateScp();
    end
    local cur = total_time - cur_time;
    if cur > total_time then
        cur = total_time - 0.1;
    end
    return cur * 1000, total_time * 1000;
end

function OBJECT_INTERACTION_COOL_TIME_REMOVE_UI(frame, handle)
    local ui_name = "object_cool_time_"..handle;
    local new_frame = ui.GetFrame(ui_name);
    if new_frame ~= nil then
        new_frame:ShowWindow(0);
    end
end

function OBJECT_INTERACTION_COOL_TIME_POS_UPDATE(frame, num)
    frame = tolua.cast(frame, "ui::CFrame");
    local handle = frame:GetUserIValue("HANDLE");
    if tonumber(handle) == 0 then return 0; end
    local point = info.GetPositionInUI(handle, 2);
    local x = point.x - frame:GetWidth() / 2;
    local y = point.y - frame:GetHeight() - 50;
    frame:MoveFrame(x, y);
    return 1;
end