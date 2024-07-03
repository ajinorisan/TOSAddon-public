local cupole_animlist = {"born","run","select_born","select_std","skl1","skl2","std"};

function OPEN_EMOTION_BTN(frame, ctrl, argStr, argNum)
    local cupole_emotion = ui.OpenFrame("cupole_emotion")
    local cupole_item = ui.GetFrame("cupole_item")
    local TopParent = frame:GetTopParentFrame()
    RESET_CUPOLE_SELECT_MODE(TopParent)
end

function OPEN_CUPOLE_EMOTION(frame)
    SET_CUPOLE_EMOTION(frame)
end

function SET_CUPOLE_EMOTION(frame)
    local csetwidth =  ui.GetControlSetAttribute("pose_icon", 'width');
	local csetheight =  ui.GetControlSetAttribute("pose_icon", 'height');
    local x = 20;
    local y = 20;
    local xmargin = 20;
    local ymargin = 20;
    local controlIndex = 0;
    local maxIndex = 3;

    local managerTab = GET_CHILD(frame,"managerTab");
    local mainFrame = ui.GetFrame("cupole_item")
    for k,v in pairs(cupole_animlist) do
        local eachcontrol = managerTab:CreateOrGetControlSet('pose_icon','pose_icon'..v, x, y)

        local each_pose_name = GET_CHILD(eachcontrol, 'pose_name','ui::CRichText');
        local each_pose_slot = GET_CHILD(eachcontrol, 'pose_slot','ui::CSlot');
        -- 임시 
        local selc_cupole = GET_GLOBAL_SELECT_CUPOLE();
        local monName = GET_CUPOLE_NAME_BY_INDEX(selc_cupole)

        each_pose_slot:SetEventScript(ui.LBUTTONDOWN, 'CUPOLE_POSE');
        each_pose_slot:SetEventScriptArgNumber(ui.LBUTTONDOWN, k);
        each_pose_slot:SetEventScriptArgString(ui.LBUTTONDOWN, monName);

        SET_SLOT_IMG(each_pose_slot, "icon_gesture_love");
        each_pose_name:SetTextByKey('posename',v);
        each_pose_slot:SetTextByKey('posename',v);
        local icon = each_pose_slot:GetIcon();
        icon:SetUserValue('POSEID', v);			

        controlIndex = controlIndex + 1;
        x = xmargin + (controlIndex % maxIndex) * csetwidth
        y = ymargin + math.floor(controlIndex / maxIndex) * csetheight

    end


end

function CUPOLE_POSE(monName, animname)  
    local myHandle = session.GetMyHandle();
	local ownerActor = world.GetActor(myHandle);
    local monActor = ownerActor:GetClientMonster():GetClientMonsterByName(monName);
    local monHandle = monActor:GetHandleVal();

    CupoleAnimPlay(monHandle, animname)
end