function MINIMIZED_FRIEND_ON_INIT(addon, frame)
    addon:RegisterMsg('GAME_START', 'MINIMIZED_FRIEND_BUTTON_OPEN_CHECK');
end

function MINIMIZED_FRIEND_BUTTON_OPEN_CHECK(frame, msg, argStr, argNum)
    frame:ShowWindow(0);
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
    if is_between_friend_invite_time() then
        frame:ShowWindow(1); 
    end
end

function MINIMIZED_FRIEND_BUTTON_CLICK(parent, ctrl)
    RequestDialogUI(0);
end

