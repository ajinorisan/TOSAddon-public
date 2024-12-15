function OPEN_CUPOLE_FILTER_FRAME(frame)
end

function PRESS_CUPOLE_FILTER_CHECK(parent, ctrl, argStr, argNum)
    local frame = parent:GetTopParentFrame();
    local child_count = parent:GetChildCount();
    local filter_name = ctrl:GetName();
    
    if filter_name == "Owing" then
        if ctrl:IsChecked() == 1 then
            frame:SetUserValue("Owing", 1);
        else
            frame:SetUserValue("Owing", 0);
        end
        CUPOLE_FILTER_SELECT_RESET(frame);
        return;
    end

    if ctrl:IsChecked() == 1 then
        for i = 0, child_count - 2 do
            local check_box = parent:GetChildByIndex(i);
            check_box = AUTO_CAST(check_box)
            if check_box ~= nil then
                local box_Name = check_box:GetName()
                if filter_name ~= box_Name then
                    check_box:SetCheck(0);
                else
                    frame:SetUserValue("Filter",argStr);
                end
            end
        end
    else
        frame:SetUserValue("Filter","Rank");
    end


    CUPOLE_FILTER_SELECT_RESET(frame);
end