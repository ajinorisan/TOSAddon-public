function EVENT_FLEX_BOX_ON_INIT(addon, frame)
    addon:RegisterMsg("EVENT_FLEX_BOX_STATE_INIT", "EVENT_FLEX_BOX_STATE_INIT");    
    addon:RegisterMsg("EVENT_FLEX_BOX_REWARD_UPDATE", "EVENT_FLEX_BOX_REWARD_UPDATE");
    addon:RegisterMsg("EVENT_FLEX_BOX_ACCRUE_REWARD_UPDATE", "EVENT_FLEX_BOX_ACCRUE_REWARD_UPDATE");
    
    addon:RegisterMsg("EVENT_FLEX_BOX_REWARD_GET_SUCCESS", "EVENT_FLEX_BOX_REWARD_GET_SUCCESS");
end

function EVENT_FLEX_BOX_OPEN_REQ()
    if ui.CheckHoldedUI() == true then
        return;
    end
    
    control.CustomCommand("REQ_EVENT_FLEX_BOX_STATE_INIT", 0);
end

function EVENT_FLEX_BOX_CLOSE(frame, ctrl)
    if ui.CheckHoldedUI() == true then
        return;
    end
    
    if frame:IsVisible() == 0 then
        return;
    end

    local listframe = ui.GetFrame("event_flex_box_reward_list");
    if listframe:IsVisible() == 1 then
        listframe:ShowWindow(0);
        listframe:SetUserValue("TYPE", 0);
    end

    frame:SetUserValue("TYPE", 0);
    frame:ShowWindow(0);
end

-- type 1 : 메데이나 flex box
--      2 : 2101 신년맞이
function EVENT_FLEX_BOX_STATE_INIT(frame, msg, argStr, type)
	local aObj = GetMyAccountObj();
    local frame = ui.GetFrame("event_flex_box");
    frame:SetUserValue("TYPE", type);

    local itemClassName = GET_EVENT_FLEX_BOX_CONSUME_CLASSNAME(type);
    local itemCls = GetClass("Item", itemClassName);

    local open_btn = GET_CHILD_RECURSIVELY(frame, "open_btn");
    open_btn:SetTextByKey("value", GET_EVENT_FLEX_BOX_TITLE(type));

    local propName = GET_EVENT_FLEX_BOX_TOTAL_OPEN_COUNT_PROP_NAME(type);
    local open_count_text = GET_CHILD_RECURSIVELY(frame, "open_count_text");
    open_count_text:SetTextByKey("cur", TryGetProp(aObj, propName, 0));
    if GET_EVENT_FLEX_BOX_MAX_OPEN_COUNT(type) ~= nil then
        open_count_text:SetTextByKey("max", "/"..GET_EVENT_FLEX_BOX_MAX_OPEN_COUNT(type));	
    end

    local curCnt = GET_INV_ITEM_COUNT_BY_PROPERTY({{Name = "ClassName", Value = itemClassName}}, false);
    
    local main_text = GET_CHILD_RECURSIVELY(frame, "main_text");
    main_text:SetTextByKey("value", itemCls.Name);

    local tooltipText = ScpArgMsg("event_flex_box_open_btn_tip_text{ITEM}{COUNT}", "ITEM", itemCls.Name, "COUNT", GET_EVENT_FLEX_BOX_CONSUME_COUNT(type));
    open_btn:SetTextTooltip(tooltipText);

    local item_text = GET_CHILD_RECURSIVELY(frame, "item_text");
    item_text:SetTextByKey("value", itemCls.Name);
    item_text:SetTextByKey("count", curCnt);

    -- type에 따라 main UI 변경
    local main_pic = GET_CHILD_RECURSIVELY(frame, "main_pic");
    if type == 1 then
        main_pic:SetMargin(4, -5, 0, 0);
        main_pic:SetImage("flex_box_bg");
    elseif type == 2 then
        main_pic:SetMargin(0, 0, 0, 0);
        main_pic:SetImage("2021_flex_box");
    end

    frame:ShowWindow(1);
    
    local listframe = ui.GetFrame("event_flex_box_reward_list");
    listframe:ShowWindow(1);
end

function EVENT_FLEX_BOX_STATE_UPDATE()
    local aObj = GetMyAccountObj();
    
    local frame = ui.GetFrame("event_flex_box");
    local type = frame:GetUserIValue("TYPE");

    local propName = GET_EVENT_FLEX_BOX_TOTAL_OPEN_COUNT_PROP_NAME(type);
    local open_count_text = GET_CHILD_RECURSIVELY(frame, "open_count_text");
    open_count_text:SetTextByKey("cur", TryGetProp(aObj, propName, 0));
    
    local itemClassName = GET_EVENT_FLEX_BOX_CONSUME_CLASSNAME(type);
    local itemCls = GetClass("Item", itemClassName);
    local curCnt = GET_INV_ITEM_COUNT_BY_PROPERTY({{Name = "ClassName", Value = itemClassName}}, false);

    local item_text = GET_CHILD_RECURSIVELY(frame, "item_text");
    item_text:SetTextByKey("value", itemCls.Name);
    item_text:SetTextByKey("count", curCnt);
end

function EVENT_FLEX_BOX_REWARD_UPDATE(frame, msg, argStr, argNum)
    EVENT_FLEX_BOX_REWARD_LIST_UPDATE(argStr, argNum);
end

function EVENT_FLEX_BOX_ACCRUE_REWARD_UPDATE(frame)
    EVENT_FLEX_BOX_ACCRUE_LIST_UPDATE();
end

function EVENT_FLEX_BOX_REWARD_LIST_OPEN_BTN_CLICK()
    EVENT_FLEX_BOX_REWARD_LIST_TOGGLE();
end

function EVENT_FLEX_BOX_OPEN_BTN_CLICK(parent, ctrl)
    if ui.CheckHoldedUI() == true then
        return;
    end

    local frame = parent:GetTopParentFrame();
    local type = frame:GetUserIValue("TYPE");
    
    local consumClassName = GET_EVENT_FLEX_BOX_CONSUME_CLASSNAME(type);
    local consumCnt = GetInvItemCount(pc, consumClassName);
    local consumCnt = GET_INV_ITEM_COUNT_BY_PROPERTY({{Name = 'ClassName', Value = consumClassName}}, false);
    if consumCnt < GET_EVENT_FLEX_BOX_CONSUME_COUNT(type) then
        ui.SysMsg(ClMsg("NotEnoughMaterial"));
        return;
    end

    if type == 2 then
        local lv = GETMYPCLEVEL();
        local lowLv = GET_EVENT_2101_NEW_YEAR_OPEN_BOX_LOWLEVEL();
        if lv < lowLv then
            ui.SysMsg(ScpArgMsg("CannotBecauseLowLevel{LEVEL}", "LEVEL", lowLv));
            return;
        end    
    end

	ui.SetHoldUI(true);
    ReserveScript("EVENT_FLEX_BOX_UNFREEZE()", 3);
    
    imcSound.PlaySoundEvent(frame:GetUserConfig("BUTTON_CLICK_SOUND"));
    control.CustomCommand("REQ_EVENT_FLEX_BOX_OPEN", type);
end

function EVENT_FLEX_BOX_UNFREEZE()
    ui.SetHoldUI(false);
end

function EVENT_FLEX_BOX_REWARD_GET_SUCCESS(frame, msg, argStr, isPose)
    EVENT_FLEX_BOX_UNFREEZE()

    local strlist = StringSplit(argStr, '/');
    local grade = strlist[1];
    EVENT_FLEX_BOX_REWARD_FULLDARK_UI_OPEN(grade, strlist[2], strlist[3]); -- 아이템 획득 이미지
    EVENT_FLEX_BOX_STATE_UPDATE();

    if isPose == 1 then
        ReserveScript("EVENT_FLEX_BOX_POSE_UNFREEZE()", 4);
    end
end

function EVENT_FLEX_BOX_POSE_UNFREEZE()
    local handle = session.GetMyHandle();
    movie.PlayAnim(handle, "ATKSTAND", 1.0, 1);
    return 0;
end