function TOSHERO_INFO_BUFF_ON_INIT(addon, frame)
    addon:RegisterMsg('TOSHERO_INFO_GET', 'ON_TOSHERO_INFO_BUFF_GET')
end

-- AddOnMsg
function ON_TOSHERO_INFO_BUFF_GET()
    TOSHERO_INFO_BUFF_SET()
end

-- Open/Close
function TOSHERO_INFO_BUFF_OPEN()
    TOSHERO_INFO_BUFF_SET()
end

function TOSHERO_INFO_BUFF_SET()
    local frame = ui.GetFrame('toshero_info_buff')
    if frame == nil then
        return
    end

    local nowIndex = GetTOSHeroBuffIndex()

    for i = 0, 2 do
        local buffType = GetTOSHeroBuffType(i)
        local buffLevel = GetTOSHeroBuffLevel(i)
        local buffClass = GetClassByType("Buff", buffType + g_toshero_group_index)

        local slot = GET_CHILD_RECURSIVELY(frame, 'slot_'..i + 1)
        local name = GET_CHILD_RECURSIVELY(frame, 'name_'..i + 1)
        local level = GET_CHILD_RECURSIVELY(frame, 'level_'..i + 1)
        local shadow = GET_CHILD_RECURSIVELY(frame, 'level_shadow_'..i + 1)
        local icon = slot:GetIcon();
        if icon == nil then
            icon = CreateIcon(slot);
        end
        if buffClass ~= nil then
            icon:SetImage("icon_"..buffClass.Icon)
            icon:SetTextTooltip(buffClass.ToolTip)
            name:SetTextByKey("name", buffClass.Name)
            level:SetTextByKey("level", buffLevel)
            shadow:SetVisible(1)
            TOSHERO_INFO_BUFF_CD_SET(frame, icon)
        else
            slot:ClearIcon() -- 아이콘 비우기, ClearIcon의 경우 쿨타임 날려버리기 때문에 쓰면 안됨
            name:SetTextByKey("name", frame:GetUserConfig("DEFAULT_NAME"))
            level:SetTextByKey("level", "")
            shadow:SetVisible(0)
        end
        
        local check = GET_CHILD_RECURSIVELY(frame, 'checkbox_'..i + 1)

        if nowIndex == i then
            check:SetImage(frame:GetUserConfig("CHECK_ON_IMAGE"))
        else
            check:SetImage(frame:GetUserConfig("CHECK_OFF_IMAGE"))
        end
    end
end

-- Request
function OPEN_TOSHERO_INFO_BUFF()
    local frame = ui.GetFrame('toshero_info_buff')
    if frame == nil then
        return
    end
    if frame:IsVisible() == 0 then
        ui.OpenFrame('toshero_info_buff')
    else
        ui.CloseFrame('toshero_info_buff')
    end
end

function TOSHERO_INFO_BUFF_SELECT(parent, self, argStr, index)
    if GetTOSHeroBuffIndex() == index then
        toshero.RequestDeSelectBuff()
    else
        local selfSlot = GET_CHILD_RECURSIVELY(parent, "slot_"..(index + 1))
        local selfIcon = selfSlot:GetIcon()
        if selfIcon == nil then
            return
        end

        toshero.RequestSelectBuff(index)
        local frame = parent:GetTopParentFrame()

        for i = 1, 3 do 
            local slot = GET_CHILD_RECURSIVELY(frame, "slot_"..i)
            local icon = slot:GetIcon();
            if icon ~= nil then
                local curTime = imcTime.GetAppTime();	
                local startTime = frame:GetUserIValue("_CUSTOM_CD_START");
                if curTime - startTime > TOSHERO_BUFF_REQUEST_WAIT_TIME + 1 then
                    frame:SetUserValue("_CUSTOM_CD_START", curTime);
                    TOSHERO_INFO_BUFF_CD_SET(frame, icon)
                end
            end
        end
    end
end


function TOSHERO_INFO_BUFF_CD_SET(frame, icon)
    icon:SetUserValue("_CUSTOM_CD_START", frame:GetUserValue("_CUSTOM_CD_START"));
    icon:SetUserValue("_CUSTOM_CD", TOSHERO_BUFF_REQUEST_WAIT_TIME+1);
    icon:SetOnCoolTimeUpdateScp('_ICON_CUSTOM_COOLDOWN');
end