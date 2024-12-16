local POPOBOOST_DEALY_TIME = 0;
function MINIMIZED_POPOBOOST_2023_ON_INIT(addon, frame)
	addon:RegisterMsg('GAME_START', 'MINIMIZED_POPOBOOST_BUTTON_OPEN_CHECK');
	addon:RegisterMsg('GAME_START', 'POPOBOOST_ALRET');
	addon:RegisterMsg('POPOBOOST_ALREST_RESET', 'POPOBOOST_ALRET');
end


function MINIMIZED_POPOBOOST_BUTTON_OPEN_CHECK(frame, msg, argStr, argNum)
    if IS_POPOBOOST_END() == true then
        frame:ShowWindow(0);
        return;
    end
    local pc = GetMyPCObject();
    if pc == nil then
        frame:ShowWindow(0);
        return ; 
    end

    local etc = GetMyEtcObject(pc);
    if etc == nil then
        frame:ShowWindow(0);
        return ;
    end

    local acc = GetMyAccountObj(pc);
    if acc == nil then
        frame:ShowWindow(0);
        return;
    end

    local AccProp = GET_POPOBOOST_SEASONPROP();
    if AccProp == "None" then
        frame:ShowWindow(0);
        return;
    end

    local popoProp = TryGetProp(acc,AccProp, -1);
    local state = RETURN_POPOBOOST_ACCOUNTPROP_TO_CHAR_BY_INT(popoProp)
    if state == "None" or popoProp == "OnlyPremium" then
        local lv = TryGetProp(pc,"Lv",0);
        if POPOBOOST_CHECK_ELIGIBILITY(lv, nil) == false then
            frame:ShowWindow(0);
        else
            frame:ShowWindow(1);
        end
        return ;
    end
    
    local etcProp = GET_POPOBOOST_ETCPROP();
    local isParticipate = TryGetProp(etc, etcProp, -1);
    if isParticipate <= 0 then
        frame:ShowWindow(0);
    else
        frame:ShowWindow(1);
    end
end

function MINIMIZED_POPOBOOST_BUTTON_CLICK(parent, ctrl)
    if IS_POPOBOOST_END() == true then
        return;
    end
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

