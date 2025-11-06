function OPENINGAMESHOPBTN_ON_INIT(addon, frame)

    addon:RegisterMsg("UPDATE_OPEN_INGAMESHOP_BTN", "OPENINGAMESHOPBTN_ON_UPDATE");
    addon:RegisterMsg('GAME_START', 'OPENINGAMESHOPBTN_ON_START');
end

function OPENINGAMESHOPBTN_ON_START(frame, msg, str, num)    
    if config.GetServiceNation() == 'PAPAYA' then
        local frame = ui.GetFrame('openingameshopbtn')
        frame:ShowWindow(0)
    end
end 

function OPENINGAMESHOPBTN_ON_UPDATE(frame, msg, argStr, itemCnt)
    if itemCnt > 0 and frame:GetUserValue("UPDATE") ~= "DONE" then
        local helpBalloon = MAKE_BALLOON_FRAME(ScpArgMsg('remain_TP'), 0, 0, nil, nil)
        helpBalloon:ShowWindow(1);

        local margin = frame:GetMargin();
        local x = margin.top;
        local y = margin.right;

        helpBalloon:SetGravity(ui.RIGHT, ui.TOP);
        helpBalloon:SetMargin(0, x, y + 80, 0);
        helpBalloon:SetDuration(10);
        helpBalloon:SetLayerLevel(105);

        ui.MsgBox_NonNested(ScpArgMsg("remain_TP_exists"), frame:GetName(), "OPENINGAMESHOPBTN_CLICK", "None");
        frame:SetUserValue("UPDATE", "DONE")
    end
end

function OPENINGAMESHOPBTN_CLICK()    
    local frame = ui.GetFrame('openingameshopbtn')
    if frame ~= nil then
        if config.GetServiceNation() == "GLOBAL_JP" then
            local open_openingameshopbtn = GET_CHILD_RECURSIVELY(frame, 'open_openingameshopbtn')
            if open_openingameshopbtn ~= nil then
                open_openingameshopbtn:SetMargin(0, 0, 0, 0)
            end
        end
    end
    ui.OpenFrame('steamtpinventory')
end