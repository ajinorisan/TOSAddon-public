function MINIMIZED_FRIEND_ON_INIT(addon, frame)
    addon:RegisterMsg('GAME_START', 'MINIMIZED_FRIEND_BUTTON_OPEN_CHECK');
end

function MINIMIZED_FRIEND_BUTTON_OPEN_CHECK(frame, msg, argStr, argNum)
    if is_between_friend_invite_time() then
        frame:ShowWindow(1); 
    else
        frame:ShowWindow(0); 
    end

    frame:ShowWindow(0); 
end

function MINIMIZED_FRIEND_BUTTON_CLICK(parent, ctrl)
    RequestDialogUI(0);
end

