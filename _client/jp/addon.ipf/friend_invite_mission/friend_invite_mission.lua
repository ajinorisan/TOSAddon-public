function REQ_FRIEND_INVITE_MISSION()
    ui.OpenFrame("friend_invite_mission");
end

function OPEN_FRIEND_INVITE_MISSION(frame)
    local pc = GetMyPCObject();
    if pc == nil then
        return ; 
    end
    local acc = GetMyAccountObj(pc);
    if acc == nil then
        return ;
    end

    MAKE_FREIND_INVITE_CONTROLSET(frame, acc)
    SET_FRIEND_INVITE_TEAMNAME(frame, acc)
end

function MAKE_FREIND_INVITE_CONTROLSET(frame, acc)

    local ItemInfoBox = GET_CHILD_RECURSIVELY_NAME(frame,"MainGB/ItemInfoBox")

    local clsList, cnt = GetClassList("friend_invite")
    local x = 0;
    local y = 0;
    local offset = 100;

    for i = 0, cnt - 1 do
        local ctrl = ItemInfoBox:CreateOrGetControlSet("friend_invite_item_list", "friend_invite_item_list"..i, x, y * offset);
        local Mission = GET_CHILD_RECURSIVELY(ctrl,"Mission");
        local count = GET_CHILD_RECURSIVELY(ctrl,"count");
        local Recv = GET_CHILD_RECURSIVELY(ctrl,"Recv");
        local disable_shadow = GET_CHILD_RECURSIVELY(ctrl,"disable_shadow");

        local cls = GetClassByIndexFromList(clsList, i)
        local RewardInfo = get_make_invite_event_reward(i + 1);
        local ItemClassName = nil;
        local ItemCnt = nil;
        local index = 0;

        for k,v in pairs(RewardInfo) do
            local pic = GET_CHILD_RECURSIVELY(ctrl,"Pic"..(index+1),"ui::CSlot");

            ItemClassName = k;
            ItemCnt = v;
            local itemCls = GetClass("Item", ItemClassName)    
            local fullImage = GET_LEGENDEXPPOTION_ICON_IMAGE_FULL(itemCls);
            local icon = pic:GetIcon()
            if icon ~= nil then
                icon:SetImage(fullImage)
            else
                icon = CreateIcon(pic);
                icon:SetImage(fullImage)
            end       
            count:SetTextByKey("count",ItemCnt);
            SET_BALCK_MARKET_TOOLTIP(icon,itemCls)    
            index = index + 1;
        end
        if index == 1 then
            local pic = GET_CHILD_RECURSIVELY(ctrl,"Pic1","ui::CSlot");
            pic:SetMargin(25,0,0,0);
        end

        local MissionDesc = TryGetProp(cls, "Desc", "None");
        local ClearProp = TryGetProp(cls, "Prop", "None");
        local ClearValue = TryGetProp(acc, ClearProp, 0);

        Mission:SetTextByKey("explain", MissionDesc);
        disable_shadow:ShowWindow(0)

        if Recv ~= nil then
            local Check = GET_CHILD_RECURSIVELY(Recv,"Check")
            if ClearValue == 1 then
                Recv:SetEnable(1);
                Recv:SetEventScript(ui.LBUTTONUP, "REQUEST_GET_INVITE_EVENT_REWARDS")
                Recv:SetEventScriptArgNumber(ui.LBUTTONUP, i+1)
                Check:ShowWindow(0)
            else
                Recv:SetEnable(0);
                Recv:SetEventScript(ui.LBUTTONUP, "")
                Recv:SetEventScriptArgNumber(ui.LBUTTONUP, 0)
                if ClearValue == 2 then
                    Check:ShowWindow(1)
                    disable_shadow:ShowWindow(1)
                else
                    Check:ShowWindow(0)
                end
            end
        end

        y = y + 1;

    end
end

function SET_FRIEND_INVITE_TEAMNAME(frame, acc)
    local Inviter = GET_CHILD_RECURSIVELY_NAME(frame,"MainGB/TeamName/inviterName")
    local TeamNameInvite = GET_CHILD_RECURSIVELY_NAME(frame,"MainGB/TeamNameInvite")
    local Invitee = GET_CHILD_RECURSIVELY_NAME(frame,"MainGB/TeamNameInvite/inviteeName")
    local Name = TryGetProp(acc, "EVENT_2403_FRIEND_EVENT_INVITER_NAME", "None");
    local State = TryGetProp(acc, "FRIEND_INVITE_EVENT_STATE", 0);

    local myHandle = session.GetMyHandle();
    local myName = info.GetFamilyName(myHandle);
    -- 1 - 초대자, 2-- 피 초대자 0 -- 초대 x
    if State == 2 then
        TeamNameInvite:ShowWindow(1);
        Inviter:SetTextByKey("Name", Name)
        Invitee:SetTextByKey("Name", myName);
    else
        TeamNameInvite:ShowWindow(0);
        Inviter:SetTextByKey("Name", myName);
    end

end

function REQUEST_GET_INVITE_EVENT_REWARDS(frame, ctrl, argStr, argNum)
    RequestGetInviteEventReward(argNum)
    local pic = GET_CHILD_RECURSIVELY(ctrl,"Check")
    ctrl:SetEnable(0)
    pic:ShowWindow(1)
end

