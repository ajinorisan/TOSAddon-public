-- event_progress_check_2009_fullmoon.lua

function EVENT_2009_FULLMOON_CHECK_LEVEL_REWARD(frame, type)
    local desclist = GET_EVENT_PROGRESS_CHECK_DESC(type);
	local nametext = GET_CHILD_RECURSIVELY(frame, "nametext");
	nametext:SetTextByKey('value', ClMsg(desclist[2]));
    
	local tiptext = GET_CHILD(frame, "tiptext");
	local tiptextlist = GET_EVENT_PROGRESS_CHECK_TIP_TEXT(type);
	if tiptextlist[2] ~= "None" then
		tiptext:SetTextByKey("value", ClMsg(tiptextlist[2]));
		tiptext:ShowWindow(1);
    end
    
	local listgb = GET_CHILD_RECURSIVELY(frame, "listgb");
	local table = GET_EVENT_2009_FULLMOON_ACCRUE_REWARD_TABLE();

    for i = 1, #table do
        local tablelist = StringSplit(table[i], ";");

		local rewardText = "";
        local accCount = tablelist[1];
        
		for i = 2, #tablelist do
			local rewradStrlist = StringSplit(tablelist[i], "/");
			local itemClassName = rewradStrlist[1];
			local itemCount = rewradStrlist[2];

			local itemCls = GetClass("Item", itemClassName);
			if itemCls ~= nil then
				local str = string.format("%s", itemCls.Name);
                rewardText = rewardText..str;
			end
		end

		local ctrl = listgb:CreateOrGetControlSet("reward_item_list", "LIST_"..i, 0, 0);
        ctrl:Resize(520, 89)
		
        local listtext = GET_CHILD(ctrl, "listtext");
        listtext:SetTextByKey("value", rewardText);

        local icon = GET_CHILD(ctrl, "icon");
		icon:ShowWindow(0);
		
        local count = GET_CHILD(ctrl, "count");
		count:ShowWindow(0);

        local text = GET_CHILD(ctrl, "text");
        
        if accCount == "Special" then
            text:SetTextByKey("value", ClMsg("SpecialReward"));
        else
            text:SetTextByKey("value", accCount..ClMsg("Step"));
        end

        listtext:SetTextTooltip(ClMsg("EVENT_2009_FULLMOON_REWARD_DESCRIPTION_"..i))
        listtext:EnableHitTest(1)
    end

    GBOX_AUTO_ALIGN(listgb, 0, -5, 0, true, false);
end

function EVENT_2009_FULLMOON_CHECK_BUFF_DESCRIPTION(frame, type)
    local desclist = GET_EVENT_PROGRESS_CHECK_DESC(type);
	local nametext = GET_CHILD_RECURSIVELY(frame, "nametext");
	nametext:SetTextByKey('value', ClMsg(desclist[3]));
    
	local tiptext = GET_CHILD(frame, "tiptext");
	local tiptextlist = GET_EVENT_PROGRESS_CHECK_TIP_TEXT(type);
	if tiptextlist[2] ~= "None" then
		tiptext:SetTextByKey("value", ClMsg(tiptextlist[3]));
		tiptext:ShowWindow(1);
    end

	local listgb = GET_CHILD_RECURSIVELY(frame, "listgb");

    for i = 1, 5 do
		local ctrl = listgb:CreateOrGetControlSet("reward_item_list", "LIST_"..i, 0, 0);
        ctrl:Resize(520, 106)
		
        local listtext = GET_CHILD(ctrl, "listtext");
        listtext:SetTextByKey("value", ClMsg("EVENT_2009_FULLMOON_BUFF_DESCRIPTION_"..i));

        local icon = GET_CHILD(ctrl, "icon");
		icon:ShowWindow(0);
		
        local count = GET_CHILD(ctrl, "count");
		count:ShowWindow(0);

        local text = GET_CHILD(ctrl, "text");
        text:SetTextByKey("value", i..ClMsg("Step"));
    end

    GBOX_AUTO_ALIGN(listgb, 0, -5, 0, true, false);
end