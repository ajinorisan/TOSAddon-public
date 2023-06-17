-- earring raid board
function EARRING_RAID_BOARD_ON_INIT(addon, frame)
    addon:RegisterMsg("EARRING_RAID_BOARD_TITLE", "ON_EARRING_RAID_BOARD_TITLE");
    addon:RegisterMsg("EARRING_RAID_BOARD_TOTAL_TIME", "ON_EARRING_RAID_BOARD_TOTAL_TIME");
    addon:RegisterMsg("EARRING_RAID_BOARD_WAVE_TIME", "ON_EARRING_RAID_BOARD_WAVE_TIME");
    addon:RegisterMsg("EARRING_RAID_BOARD_PARTY_SKILL", "ON_EARRING_RAID_BOARD_PARTY_SKILL");
    addon:RegisterMsg("EARRING_RAID_BOARD_ITEM", "ON_EARRING_RAID_BOARD_ITEM");
    addon:RegisterMsg("EARRING_RAID_BOARD_PROGRESS", "ON_EARRING_RAID_BOARD_PROGRESS");
    addon:RegisterMsg("EARRING_RAID_BOARD_PARTY_SKILL_ENABLE", "ON_EARRING_RAID_BOARD_PARTY_SKILL_ENABLE");
    addon:RegisterMsg("EARRING_RAID_BOARD_PARTY_SKILL_COOLTIME", "ON_EARRING_RAID_BOARD_PARTY_SKILL_COOLTIME");
    addon:RegisterMsg("EARRING_RAID_BOARD_PARTY_SKILL_COUNT", "ON_EARRING_RAID_BOARD_PARTY_SKILL_COUNT");
    addon:RegisterMsg("EARRING_RAID_BOARD_USE_ITEM_COUNT", "ON_EARRING_RAID_BORAD_USE_ITEM_COUNT");
    addon:RegisterMsg("EARRING_RAID_LUCKY_REWARD", "ON_PLAY_LUCKY_REWARD_EFFECT");
end

function ON_EARRING_RAID_BOARD_TITLE(frame, msg, arg_str, arg_num)
    if frame == nil then return; end
    frame:ShowWindow(1);
    local type = tonumber(arg_num);
    local indun_cls = GetClassByType("Indun", type);
    if indun_cls ~= nil then
        local title_text = GET_CHILD_RECURSIVELY(frame, "title_text");
        if title_text ~= nil then
            local title = ClMsg('LimitationTime')
            title_text:SetTextByKey("title", title);
        end
    end
end

function ON_EARRING_RAID_BOARD_TOTAL_TIME(frame, msg, arg_str, arg_num)
    if frame == nil then return; end
    frame:ShowWindow(1);
    local datas = StringSplit(arg_str, '/');
    if datas ~= nil and #datas > 1 then
        local min = tonumber(datas[1]);
        local sec = tonumber(datas[2]);
        local title_text = GET_CHILD_RECURSIVELY(frame, "title_text");
        if title_text ~= nil then
            title_text:SetTextByKey("min", string.format("%02d", min));
            title_text:SetTextByKey("sec", string.format("%02d", sec));
        end
    end
end

function ON_EARRING_RAID_BOARD_WAVE_TIME(frame, msg, arg_str, arg_num)
    if frame == nil then return; end
    frame:ShowWindow(1);
    local datas = StringSplit(arg_str, '/');
    if datas ~= nil and #datas > 1 then
        local wave = datas[1];
        local min = tonumber(datas[2]);
        local sec = tonumber(datas[3]);
        local wave_time = tonumber(datas[4]);
        local wavetime_text = GET_CHILD_RECURSIVELY(frame, "wavetime_text");
        if wavetime_text ~= nil then
            wavetime_text:SetTextByKey("wave", wave);
        end

        local wavetime_value = GET_CHILD_RECURSIVELY(frame, "wavetime_value");
        if wavetime_value ~= nil then
            wavetime_value:SetTextByKey("min", string.format("%02d", min));
            wavetime_value:SetTextByKey("sec", string.format("%02d", sec));
        end

        local wavetime_gauge = GET_CHILD_RECURSIVELY(frame, "wavetime_gauge");
        if wavetime_gauge ~= nil then
            local time = tonumber(arg_num);
            wavetime_gauge:SetPoint(time, wave_time);
        end
    end
end

function ON_EARRING_RAID_BOARD_PARTY_SKILL(frame, msg, arg_str, arg_num)
    if frame == nil then return; end
    frame:ShowWindow(1);
    local size = 53;
    local skill_icon_box = GET_CHILD_RECURSIVELY(frame, "skill_icon_box");
    local datas = StringSplit(arg_str, '/');
    if datas ~= nil and #datas > 0 then
        local row = 0;
        for i = 1, #datas do
            if i % 4 == 0 then row = row + 1; end
            local guid = tonumber(datas[i]);
            if guid ~= nil then
                local cls = GetClassByType("Buff", guid);
                if cls ~= nil then
                    local x = 55 * ((i - 1) % 4) + 7;
                    local y = (55 * row) * math.floor((i - 1) / 4) + 6;
                    local slot = skill_icon_box:CreateOrGetControl("slot", "skill_"..i, x, y, size, size);
                    if slot ~= nil then
                        AUTO_CAST(slot);
                        if slot:GetIcon() ~= nil then
                            break;
                        end
                        local handle = session.GetMyHandle()
                        slot:SetEventScript(ui.LBUTTONUP, "EARRING_RAID_BOARD_SKILL_LBUTTON_UP");
                        slot:SetEventScriptArgNumber(ui.LBUTTONUP, guid);
                        slot:EnableDrag(1)
                        local imageName = TryGetProp(cls, "Icon", "None");
                        local icon = CreateIcon(slot);
                        icon:Set('icon_' .. imageName, 'Buff', guid, 0);
                        icon:SetTooltipType('buff');
                        icon:SetTooltipArg(handle, cls.ClassID, 0)                        
                    end
                end
            end
        end
    end

    local skill_count_text = GET_CHILD_RECURSIVELY(frame, "skill_count_text");
    if skill_count_text ~= nil then
        local count = tonumber(arg_num);
        skill_count_text:SetTextByKey("count", count);
    end

    local height_resize = math.floor((#datas - 1) / 4) * 53;
    skill_icon_box:Resize(skill_icon_box:GetWidth(), skill_icon_box:GetOriginalHeight() + height_resize);

    local skill_box = GET_CHILD_RECURSIVELY(frame, "skill_box");
    skill_box:Resize(skill_box:GetWidth(), skill_box:GetOriginalHeight() + height_resize);

    EARRING_RAID_BOARD_GBOX_ALIGN(frame);
end

function ON_EARRING_RAID_BOARD_PARTY_SKILL_ENABLE(frame, msg, arg_str, arg_num)    
    if frame == nil then return; end
    frame:ShowWindow(1);
    local skill_icon_box = GET_CHILD_RECURSIVELY(frame, "skill_icon_box");
    if skill_icon_box ~= nil then
        local count = skill_icon_box:GetChildCount();
        for i = 0, count - 1 do
            local pic = skill_icon_box:GetChildByIndex(i);
            if pic ~= nil and string.find(pic:GetName(), "skill_") ~= nil then   
                AUTO_CAST(pic);
                if arg_str == "YES" then
                    pic:SetEnable(1);
                    if pic:GetIcon() ~= nil then
                        pic:GetIcon():SetColorTone("FFFFFFFF")
                    end
                elseif arg_str == "NO" then
                    pic:SetEnable(0);
                    if pic:GetIcon() ~= nil then
                        pic:GetIcon():SetColorTone("FFFF0000")
                    end
                end
            end
        end
    end
end

function ON_EARRING_RAID_BOARD_PARTY_SKILL_COOLTIME(frame, msg, arg_str, arg_num)
    if frame == nil then return; end
    frame:ShowWindow(1);
    local percent = math.floor(tonumber(arg_num));
    local skill_cool_time_gauge = GET_CHILD_RECURSIVELY(frame, "skill_cool_time_gauge");
    if skill_cool_time_gauge ~= nil then
        skill_cool_time_gauge:SetPoint(percent, 100);
    end
end

function ON_EARRING_RAID_BOARD_PARTY_SKILL_COUNT(frame, msg, arg_str, arg_num)
    if frame == nil then return; end
    frame:ShowWindow(1);
    local skill_count_text = GET_CHILD_RECURSIVELY(frame, "skill_count_text");
    if skill_count_text ~= nil then
        local count = tonumber(arg_num);
        skill_count_text:SetTextByKey("count", count);
    end
end

function ON_EARRING_RAID_BORAD_USE_ITEM_COUNT(frame, msg, arg_str, arg_num)    
    if frame == nil then return; end
    frame:ShowWindow(1);
    local datas = StringSplit(arg_str, '/');
    if datas ~= nil and #datas > 0 then
        local index = tonumber(datas[1]);
        local count = tonumber(datas[2]);
        local max = tonumber(datas[3]);
        EARRING_RAID_BOARD_ITEM_USE_TEXT_UPDATE(frame, index, count, max);
    end
end

function EARRING_RAID_BOARD_SKILL_LBUTTON_UP(parent, control, arg_str, arg_num)
    if arg_num ~= nil then party.ReqPartySkill(arg_num); end
end

function EARRING_RAID_BOARD_ITEM_LBUTTON_UP(parent, control, arg_str, arg_num)
    if control ~= nil then
        tolua.cast(control, "ui::CSlot");
        local icon = control:GetIcon();
        if icon ~= nil then
            local icon_info = icon:GetInfo();
            if icon_info ~= nil then
                local inv_item_info = session.GetInvItemByGuid(arg_str);
                if inv_item_info == nil then
                    icon:SetColorTone("FFFF0000");
                    icon:SetText("0", "quickiconfont", ui.RIGHT, ui.BOTTOM, -2, 1);
                else
                    if inv_item_info.count == 0 then
                        icon:SetColorTone("FFFF0000");
                        icon:SetText(inv_item_info.count, "quickiconfont", ui.RIGHT, ui.BOTTOM, -2, 1);
                        return;
                    end
                    
                    if icon_info:GetCategory() == "Item" then
                        local item_obj = GetIES(inv_item_info:GetObject());
                        if item_obj ~= nil then
                            local group_name = TryGetProp(item_obj, "GroupName", "None");
                            if group_name == "Drug" then
                                local useable = TryGetProp(item_obj, "Usable", "None");
                                if useable ~= "ITEMTARGET" then
                                    local icon_info_type = icon_info.type;
                                    if inv_item_info.isLockState == true then
                                        ui.SysMsg(ClMsg("MaterialItemIsLock"));
                                        return;
                                    end

                                    if RUN_CLIENT_SCP(inv_item_info) == true then
                                        return;
                                    end
                                    item.UseByGUID(inv_item_info:GetIESID());
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

function ON_EARRING_RAID_BOARD_ITEM(frame, msg, arg_str, arg_num)        
    if frame == nil then return; end
    frame:ShowWindow(1);
    local bg = GET_CHILD_RECURSIVELY(frame, "bg");
    local ctrlset = bg:CreateOrGetControlSet("earring_raid_board_item", "item_control_set", 0, 235);
    if ctrlset ~= nil then
        local datas = StringSplit(arg_str, '/');
        if datas ~= nil and #datas > 0 then
            local is_party_leader = datas[1];
            if is_party_leader == "YES" then                
                local info_data = StringSplit(datas[2], ';');
                if info_data ~= nil and #info_data > 0 then
                    for i = 1, #info_data - 1 do
                        local infos = StringSplit(info_data[i], ':');
                        if infos ~= nil and #infos > 0 then                            
                            local guid = infos[1];                               
                            if guid == "" or guid == '0' then
                                for j = 1, 2 do
                                    EARRING_RAID_BOARD_ITEM_ICON_UPDATE(ctrlset, j, "");
                                    EARRING_RAID_BOARD_ITEM_USE_TEXT_UPDATE(ctrlset, j, 0, info_data[#info_data]);
                                end
                            else
                                local count = tonumber(infos[2]);
                                local index = tonumber(infos[3]);                                
                                EARRING_RAID_BOARD_ITEM_ICON_UPDATE(ctrlset, index, guid);
                                EARRING_RAID_BOARD_ITEM_USE_TEXT_UPDATE(ctrlset, index, count, info_data[#info_data]);
                            end
                        end
                    end
                end
                EARRING_RAID_BOARD_ITEM_BOX_RESIZE(frame, ctrlset, true);
            elseif is_party_leader == "NO" then
                EARRING_RAID_BOARD_ITEM_BOX_RESIZE(frame, ctrlset, false);
            end
            EARRING_RAID_BOARD_GBOX_ALIGN(frame);
        end
    end
end

function EARRING_RAID_BOARD_ITEM_ICON_UPDATE(frame, index, guid)        
    if frame == nil or guid == nil or  guid == "" then return; end
    local slot = GET_CHILD_RECURSIVELY(frame, "item_slot".. index);

    if guid == "" then
        local icon = slot:GetIcon()
        if icon ~= nil then
            icon:SetColorTone("FFFF0000");
            icon:SetText("0", "quickiconfont", ui.RIGHT, ui.BOTTOM, -2, 1);    
        end
        return
    end

    local inv_item_info = session.GetInvItemByGuid(guid);
    if inv_item_info ~= nil then
        local icon = CreateIcon(slot);
        local image_name = "";
        local item_ies = GetIES(inv_item_info:GetObject());
        if item_ies ~= nil then
            image_name = GET_ITEM_ICON_IMAGE(item_ies);
            icon:SetEnableUpdateScp("None");
            if item_ies.MaxStack > 1 then
                icon:SetText(inv_item_info.count, "quickiconfont", ui.RIGHT, ui.BOTTOM, -2, 1);
            end

            if inv_item_info.count > 0 then
                icon:SetColorTone("FFFFFFFF");
            else
                icon:SetColorTone("FFFF0000");
            end
            
            tolua.cast(icon, "ui::CIcon");
            local icon_info = icon:GetInfo();
            icon_info.count = inv_item_info.count;
            if image_name ~= "" then
                icon:SetTooltipType("wholeitem");
                icon:SetTooltipArg("", inv_item_info.type, 0);	
                icon:Set(image_name, "Item", inv_item_info.type, inv_item_info.invIndex, inv_item_info:GetIESID(), inv_item_info.count);
            end
            slot:EnableDrag(0);
            slot:SetEventScript(ui.LBUTTONUP, "EARRING_RAID_BOARD_ITEM_LBUTTON_UP")
            slot:SetEventScriptArgString(ui.LBUTTONUP, guid);
        end
    else
        if guid == '0' then
            local icon = CreateIcon(slot);
            icon:SetColorTone("FFFF0000");
            icon:SetText("0", "quickiconfont", ui.RIGHT, ui.BOTTOM, -2, 1);            
        end
    end
end

function EARRING_RAID_BOARD_ITEM_USE_TEXT_UPDATE(frame, index, count, max)
    if frame == nil or count == nil then return; end
    local count_text = GET_CHILD_RECURSIVELY(frame, "item_count_text"..index);
    count_text:SetTextByKey("count", count);
    count_text:SetTextByKey("max", max);
end

function EARRING_RAID_BOARD_ITEM_BOX_RESIZE(frame, ctrl_set, is_leader)
    if frame == nil then return; end
    local item_box_width = tonumber(frame:GetUserConfig("ITEM_BOX_WIDTH"));
    local item_box_height = tonumber(frame:GetUserConfig("ITEM_BOX_HEIGHT"));
    local bg_height = tonumber(frame:GetUserConfig("BG_BOX_HEIGHT"));
    local bg = GET_CHILD_RECURSIVELY(frame, "bg");
    if is_leader == true then
        ctrl_set:ShowWindow(1);
        ctrl_set:Resize(item_box_width, item_box_height);
        bg:Resize(bg:GetWidth(), bg_height);
    else
        ctrl_set:ShowWindow(0);        
        ctrl_set:Resize(0, 0);
        bg:Resize(bg:GetWidth(), bg_height - (item_box_height + 50));        
    end
    ctrl_set:Invalidate();
    bg:Invalidate();
    frame:Invalidate();
end

function ON_EARRING_RAID_BOARD_PROGRESS(frame, msg, arg_str, arg_num)
    if frame == nil then return; end
    frame:ShowWindow(1);
    local percent = tonumber(arg_str);
    local progress_percent = GET_CHILD_RECURSIVELY(frame, "progress_percent");
    if progress_percent ~= nil then
        progress_percent:SetTextByKey("percent", percent);
    end

    local progress_gauge = GET_CHILD_RECURSIVELY(frame, "progress_gauge");
    if progress_gauge ~= nil then
        progress_gauge:SetPoint(percent, 100);
    end
end

function EARRING_RAID_BOARD_GBOX_ALIGN(frame)
    if frame == nil then return; end
    local y = 10;
    local gbox_addy = 50;
    local spacey = 0;
    local bg = GET_CHILD_RECURSIVELY(frame, "bg");
    local count = bg:GetChildCount();
    for i = 0, count - 1 do
        local child = bg:GetChildByIndex(i);
        if child ~= nil and (child:GetClassString() == "ui::CGroupBox" or child:GetName() == "item_control_set") then
            child:SetOffset(child:GetX(), y);
            y = y + child:GetHeight() + spacey;
        end
    end
    bg:Resize(bg:GetWidth(), y + gbox_addy);
    frame:Resize(frame:GetWidth(), y + gbox_addy);
    bg:Invalidate();
    frame:Invalidate();
end


function ON_PLAY_LUCKY_REWARD_EFFECT(frame, msg, item_name, count)
    if item_name == 'GabijaCertificateCoin_10000p' then
        local earingframe = ui.GetFrame('earring_raid_board')
        earingframe:ShowWindow(0);
    end
    
	ui.OpenFrame('fulldark_itemblacksmith')
	local bg_frame = ui.GetFrame('fulldark_itemblacksmith')

	local resultGbox = GET_CHILD_RECURSIVELY(bg_frame, 'resultGbox')
	local item_cls = GetClass('Item', item_name)
	if item_cls == nil then
		return
	end
	
	local recipe_cls = GetClassByType('goddessrecipe', 1)
	if recipe_cls == nil then
		return
	end
	local bgname = TryGetProp(recipe_cls, 'RecipeBgImg')

	local recipebg = GET_CHILD_RECURSIVELY(bg_frame, 'image')
	recipebg:SetImage(bgname)

	local itemIcon = GET_CHILD_RECURSIVELY(resultGbox, 'itemIcon')
    itemIcon:SetImage(item_cls.Icon)
    itemIcon:SetText(tostring(count), "area_name", ui.RIGHT, ui.BOTTOM, 2, 6);
	local screenWidth = ui.GetSceneWidth()
	local screenHeight = ui.GetSceneHeight()
	movie.PlayUIEffect(bg_frame:GetUserConfig('BLACKSMITH_RESULT_EFFECT'), screenWidth / 2, screenHeight / 2, tonumber(bg_frame:GetUserConfig('BLACKSMITH_RESULT_EFFECT_SCALE')))	
	local duration = 3
	bg_frame:SetDuration(duration)	
end
