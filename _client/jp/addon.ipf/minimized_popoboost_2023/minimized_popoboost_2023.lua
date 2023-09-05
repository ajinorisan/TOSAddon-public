function MINIMIZED_POPOBOOST_2023_ON_INIT(addon, frame)
	addon:RegisterMsg('GAME_START', 'MINIMIZED_POPOBOOST_BUTTON_OPEN_CHECK');
	addon:RegisterMsg('GAME_START', 'POPOBOOST_ALRET');
	addon:RegisterMsg('POPOBOOST_ALREST_RESET', 'POPOBOOST_ALRET');
end

function MINIMIZED_POPOBOOST_BUTTON_OPEN_CHECK(frame, msg, argStr, argNum)
    local pc = GetMyPCObject();
    if pc == nil then
        return ; 
    end
    local etc = GetMyEtcObject(pc);
    if etc == nil then
        return ;
    end
    local acc = GetMyAccountObj(pc);
    if acc == nil then
        return;
    end
    local popoProp = TryGetProp(acc,"EVENT_2023_POPOBOOST","None");
    if popoProp == 0 or popoProp == 2 then
        frame:ShowWindow(1);
        return ;
    end
    
    local isParticipate = TryGetProp(etc, "popoboost_2023_participate");
    if isParticipate == 0 then
        frame:ShowWindow(0);
    else
        frame:ShowWindow(1);
    end
end

function MINIMIZED_POPOBOOST_BUTTON_CLICK(parent, ctrl)
	local popoboost = ui.GetFrame('popoboost');
    popoboost:ShowWindow(1);
end

function POPOBOOST_ALRET(frame, msg, argStr, argNum)
    if frame == nil then
	    frame = ui.GetFrame('minimized_popoboost_2023');
    end
    local notice_bg = GET_CHILD(frame,"notice_bg");
    if notice_bg == nil then
        return;
    end
    notice_bg:ShowWindow(0);
    if GET_POPOBOOST_MINIMIZED_HIGHLIGHT() == true then
        notice_bg:ShowWindow(1);
    end
end