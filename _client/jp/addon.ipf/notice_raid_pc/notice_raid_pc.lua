-- notice_raid_pc
function NOTICE_RAID_PC_ON_INIT(addon, frame)
    addon:RegisterMsg("NOTICE_GLACIER_COLD_BALST", "ON_NOTICE_RAID_TO_UI");
    addon:RegisterMsg("NOTICE_GLACIER_ENCHANTMENT", "ON_NOTICE_RAID_TO_UI");
    addon:RegisterMsg("NOTICE_GLACIER_ENCHANTMENT_LEGEND", "ON_NOTICE_RAID_TO_UI");
    addon:RegisterMsg("NOTICE_GILTINE_DEMONICS_LANCE", "ON_NOTICE_RAID_TO_UI");
    addon:RegisterMsg("NOTICE_GILTINE_DEMONICS_PRANK", "ON_NOTICE_RAID_TO_UI");
    addon:RegisterMsg("NOTICE_GILTINE_FIND_COLOR_RED", "ON_NOTICE_RAID_TO_UI");
    addon:RegisterMsg("NOTICE_GILTINE_FIND_COLOR_YELLOW", "ON_NOTICE_RAID_TO_UI");
    addon:RegisterMsg("NOTICE_GILTINE_DEMONICS_LANCE_REMOVE", "ON_NOTICE_RAID_TO_UI");
    addon:RegisterMsg("NOTICE_GILTINE_DEMONICS_PRANK_REMOVE", "ON_NOTICE_RAID_TO_UI");
    addon:RegisterMsg("NOTICE_GILTINE_FIND_COLOR_RED_REMOVE", "ON_NOTICE_RAID_TO_UI");
    addon:RegisterMsg("NOTICE_GILTINE_FIND_COLOR_YELLOW_REMOVE", "ON_NOTICE_RAID_TO_UI");
    addon:RegisterMsg("NOTICE_SOLO_BUFF_SEELCT_ICON", "ON_NOTICE_RAID_TO_UI");
    addon:RegisterMsg("NOTICE_SOLO_BUFF_SEELCT_ICON_REMOVE", "ON_NOTICE_RAID_TO_UI");
    addon:RegisterMsg("NOTICE_DELMORE_BULLET_ICON", "ON_NOTICE_RAID_TO_UI");
    addon:RegisterMsg("NOTICE_DELMORE_BULLET_ICON_REMOVE", "ON_NOTICE_RAID_TO_UI");
    addon:RegisterMsg("NOTICE_SHOW_WEEKLY_RAID_ICON", "ON_NOTICE_RAID_TO_UI");
    addon:RegisterMsg("NOTICE_SHOW_WEEKLY_RAID_ICON_REMOVE", "ON_NOTICE_RAID_TO_UI");
    addon:RegisterMsg("NOTICE_INCARCERATION_ICON", "ON_NOTICE_RAID_TO_UI");
    addon:RegisterMsg("NOTICE_INCARCERATION_ICON_REMOVE", "ON_NOTICE_RAID_TO_UI");
    addon:RegisterMsg("NOTICE_DAMAGE_LING_ICON", "ON_NOTICE_RAID_TO_UI");
    addon:RegisterMsg("NOTICE_DAMAGE_LING_ICON_REMOVE", "ON_NOTICE_RAID_TO_UI");
    addon:RegisterMsg("NOTICE_ROZE_INCAPACITATE_ROCKFALL_ICON", "ON_NOTICE_RAID_TO_UI");
    addon:RegisterMsg("NOTICE_ROZE_INCAPACITATE_ROCKFALL_ICON_REMOVE", "ON_NOTICE_RAID_TO_UI");
    addon:RegisterMsg("NOTICE_ROZE_STONE_STATUE_ICON", "ON_NOTICE_RAID_TO_UI");
    addon:RegisterMsg("NOTICE_ROZE_STONE_STATUE_ICON_REMOVE", "ON_NOTICE_RAID_TO_UI");    
end

local s_ui_normal_icon_msg_list = { 
    "NOTICE_GILTINE_FIND_COLOR_RED", "NOTICE_GILTINE_FIND_COLOR_YELLOW", "NOTICE_GILTINE_DEMONICS_LANCE", "NOTICE_GILTINE_DEMONICS_PRANK", 
    "NOTICE_SOLO_BUFF_SEELCT_ICON", "NOTICE_DELMORE_BULLET_ICON", 
    "NOTICE_SHOW_WEEKLY_RAID_ICON", "NOTICE_INCARCERATION_ICON",
    "NOTICE_DAMAGE_LING_ICON", "NOTICE_ROZE_INCAPACITATE_ROCKFALL_ICON",
    "NOTICE_ROZE_STONE_STATUE_ICON" 
};

function ON_NOTICE_RAID_TO_UI(frame, msg, argStr, argNum)
    if msg == "NOTICE_GLACIER_COLD_BALST" then
        local handle = tonumber(argNum);
        if handle ~= 0 then frame:SetUserValue("SUFFIX", handle); end
        local uiName = "notice_raid_pc"..frame:GetUserValue("SUFFIX");
        local iconName = argStr;
        NOTICE_RAID_PC_UI_CREATE(uiName, msg, iconName, handle, 0, false, true);
    elseif string.find(msg, "NOTICE_GLACIER_ENCHANTMENT") ~= nil then
        local handle = tonumber(argStr);
        local curTime = tonumber(argNum);
        if handle ~= 0 then frame:SetUserValue("SUFFIX", handle); end
        local uiName = "notice_raid_pc"..frame:GetUserValue("SUFFIX");
        NOTICE_RAID_PC_UI_CREATE(uiName, msg, "None", handle, curTime, true, false);
    elseif table.find(s_ui_normal_icon_msg_list, msg) ~= 0 then
        local handle = tonumber(argNum);
        if handle ~= 0 then frame:SetUserValue("SUFFIX", handle); end
        local uiName = "notice_raid_pc"..frame:GetUserValue("SUFFIX");
        local iconName = argStr;
        NOTICE_RAID_PC_UI_CREATE(uiName, msg, iconName, handle, 0, false, true);
    elseif string.find(msg, "_REMOVE") ~= nil then
        local handle = tonumber(argNum);
        local frame = ui.GetFrame("notice_raid_pc"..handle);
        if frame ~= nil then
            local gbox = GET_CHILD_RECURSIVELY(frame, "gbox");
            if gbox ~= nil then
                local msg_len = string.len(msg);
                local ctrlName = string.sub(msg, 1, msg_len - 7);
                local ctrl = GET_CHILD_RECURSIVELY(gbox, ctrlName);
                if ctrl ~= nil then
                    ctrl:SetVisible(0);
                    ctrl:ShowWindow(0);
                    ctrl:Resize(0, 0);
                    gbox:RemoveChild(ctrl:GetName());
                end
            end
        end
    end
end

function NOTICE_RAID_PC_UI_CREATE(uiName, msg, iconName, handle, curTime, isGaugeIcon, isNormalIcon)
    local frame = ui.GetFrame(uiName);
    if frame == nil then
        frame = ui.CreateNewFrame("notice_raid_pc", tostring(uiName));
    end

    local gbox = GET_CHILD_RECURSIVELY(frame, "gbox");
    if gbox == nil then return; end

    frame:SetUserValue("NOTICE_RAID_UI_NAME", uiName);

    if isNormalIcon == true then
        local width = 0;
        local height = 0;
        if msg == "NOTICE_GLACIER_COLD_BALST" then
            width = 55;
            height = 100;
        elseif msg == "NOTICE_GILTINE_FIND_COLOR_RED" or msg == "NOTICE_GILTINE_FIND_COLOR_YELLOW" then
            width = 42;
            height = 44;
        elseif msg == "NOTICE_GILTINE_DEMONICS_LANCE" or msg == "NOTICE_GILTINE_DEMONICS_PRANK" then
            width = 60;
            height = 66;
        elseif msg == "NOTICE_SOLO_BUFF_SEELCT_ICON" or msg == "NOTICE_DELMORE_BULLET_ICON" then
            width = 45;
            height = 45;
        elseif msg == "NOTICE_SHOW_WEEKLY_RAID_ICON" then
            width = 65;
            height = 65;
        elseif table.find(s_ui_normal_icon_msg_list, msg) ~= 0 then
            width = 45;
            height = 45;
        end
        NOTICE_RAID_PC_NORMAL_ICON_CREATE(frame, gbox, msg, iconName, handle, width, height);
    end

    if isGaugeIcon == true then
        local width = 0;
        local height = 0;
        local skinName = "None";
        local isVertical = false;
        if msg == "NOTICE_GLACIER_ENCHANTMENT_LEGEND" or msg == "NOTICE_GLACIER_ENCHANTMENT_LEGEND" then
            width = 55;
            height = 55;
            skinName = "gauge_Glacier_fascination";
            isVertical = true;
        end
        NOTICE_RAID_PC_GAUGE_ICON_CREATE(frame, gbox, msg, handle, skinName, curTime, isVertical, width, height)
    end

    local defaultWidth = tonumber(frame:GetUserConfig("DEFAULT_WIDTH"));
    NOTICE_RAID_PC_CTRL_GBOX_AUTO_ALIGN(gbox, 0, 0, defaultWidth, true, 0, false);
    NOTICE_RAID_PC_GBOX_CHILD_CHECK(frame, gbox);
end

function NOTICE_RAID_PC_NORMAL_ICON_CREATE(frame, gbox, msg, iconName, handle, imageWidth, imageHeight)
    local picture = GET_CHILD_RECURSIVELY(frame, msg);
    if picture == nil then
        picture = gbox:CreateControl("picture", msg, imageWidth, imageHeight, ui.LEFT, ui.BOTTOM, 0, 0, 0, 0);
    end

    if handle == 0 then
        picture:SetVisible(0);
        picture:ShowWindow(0);
        picture:Resize(0, 0);
        gbox:RemoveChild(picture:GetName());
    else
        picture = tolua.cast(picture, "ui::CPicture");
        picture:SetImage(iconName);
        picture:SetVisible(1);
        picture:SetEnableStretch(1);
        picture:Resize(imageWidth, imageHeight);
        picture:Invalidate();
        frame:SetUserValue("HANDLE", handle);
        if msg == "NOTICE_SOLO_BUFF_SEELCT_ICON" then
            local my_session = session.GetMySession();
            local time = my_session:GetBuffSelectSoloByOptionIconTime();
            if time ~= nil then
                frame:SetUserValue("TOTAL_TIME", tonumber(time));
            else
                frame:SetUserValue("TOTAL_TIME", 60);
            end
            frame:SetUserValue("CTRL_NAME", picture:GetName());
            frame:RunUpdateScript("UPDATE_TIME_NOTICE_RAID_ICON_POS", 0.01, time);
        else
            frame:RunUpdateScript("UPDATE_NOTICE_RAID_ICON_POS");
        end
    end
end

function NOTICE_RAID_PC_GAUGE_ICON_CREATE(frame, gbox, msg, handle, skinName, curTime, isVertical, imageWidth, imageHeight)
    local gauge = GET_CHILD_RECURSIVELY(frame, msg);
    if gauge == nil then
        gauge = gbox:CreateControl("gauge", msg, imageWidth, imageHeight, ui.LEFT, ui.BOTTOM, 0, 0, 0, 0);
    end

    local gauageMode = 0;
    if isVertical == true then
        gauageMode = 1;
    end

    if handle == 0 then
        gauge:SetVisible(0);
        gauge:ShowWindow(0);
        gauge:Resize(0, 0);
        gbox:RemoveChild(gauge:GetName());
    else
        gauge = tolua.cast(gauge, "ui::CGauge");
        gauge:SetModeByExport(gauageMode);
        gauge:SetSkinName(skinName);
        gauge:SetVisible(1);
        gauge:Resize(imageWidth, imageHeight);
        gauge:SetMaxPointWithTime(curTime, 5, 1);
        gauge:Invalidate();
        frame:SetUserValue("HANDLE", handle);
        frame:RunUpdateScript("UPDATE_NOTICE_RAID_ICON_POS");
    end
end

function NOTICE_RAID_PC_GBOX_CHILD_CHECK(frame, gbox)
    if gbox ~= nil then
        local count = gbox:GetChildCount();
        if count <= 0 then
            local closeUiName = frame:GetUserValue("NOTICE_RAID_UI_NAME");
            ui.CloseFrame(closeUiName);
        end
    end
end

function UPDATE_NOTICE_RAID_ICON_POS(frame, num)
	frame = tolua.cast(frame, "ui::CFrame");
    local handle = frame:GetUserIValue("HANDLE");
    if tonumber(handle) == 0 then
        return 0;
    end
    
	local point = info.GetPositionInUI(handle, 2);
	local x = point.x - frame:GetWidth() / 2;
	local y = point.y - frame:GetHeight() - 40;
    frame:MoveFrame(x, y);
	return 1;
end

function UPDATE_TIME_NOTICE_RAID_ICON_POS(frame, total_elapsed_time, elapsed_time)
    frame = tolua.cast(frame, "ui::CFrame");
    local handle = frame:GetUserIValue("HANDLE");
    if tonumber(handle) == 0 then
        return 0;
    end

    local point = info.GetPositionInUI(handle, 2);
    local x = point.x - frame:GetWidth() / 2;
    local offset_y = 40;
    local actor = world.GetActor(handle);
    if actor ~= nil and actor:GetVehicleState() == true then offset_y = 60; end
	local y = point.y - frame:GetHeight() - offset_y;
    frame:MoveFrame(x, y);

    local total_time = frame:GetUserIValue("TOTAL_TIME");
    local remain_time = math.max(0, total_time - total_elapsed_time);
	if tonumber(remain_time) <= 2 then
        if frame ~= nil then
            local gbox = GET_CHILD_RECURSIVELY(frame, "gbox");
            if gbox == nil then return; end
            local ctrl_name = frame:GetUserValue("CTRL_NAME");
            local picture = GET_CHILD_RECURSIVELY(gbox, ctrl_name);
            if picture ~= nil then
                picture:SetVisible(0);
                picture:ShowWindow(0);
                picture:Resize(0, 0);
                gbox:RemoveChild(picture:GetName());
            end
            frame:ShowWindow(0);
            ui.CloseFrame(frame:GetName());
		end
		return 2;
	end
    return 1;
end