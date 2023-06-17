function CONTENTS_ALERT_REWARD_ON_INIT(addon, frame)
end


function CREATE_REWARD_CTRL(box, y, index, ItemName, itemCnt)
	local isOddCol = 0;
	if math.floor((index - 1) % 2) == 1 then
		isOddCol = 0;
	end

	local x = 5;
	if isOddCol == 1 then
		x = (box:GetWidth() / 2) + 5;
		local ctrlHeight = ui.GetControlSetAttribute('quest_reward_s', 'height');
		y = y - ctrlHeight - 10;
	end
	
	local ctrlSet = box:CreateControlSet('quest_reward_s', "REWARD_" .. index, x, y);
	tolua.cast(ctrlSet, "ui::CControlSet");
	ctrlSet:SetValue(index);

	local itemCls = GetClass("Item", ItemName);

	ctrlSet:SetUserValue('SklGemID', itemCls.ClassID)

	local slot = ctrlSet:GetChild("slot");
	tolua.cast(slot, "ui::CSlot");
	
	local icon = GET_ITEM_ICON_IMAGE(itemCls, GETMYPCGENDER())
	SET_SLOT_IMG(slot, icon);

	local ItemName = ctrlSet:GetChild("ItemName");
	local itemText = string.format("{@st41b}%s x%d", itemCls.Name, itemCnt);
	ItemName:SetText(itemText);

	ctrlSet:SetOverSound("button_cursor_over_3");
	ctrlSet:SetClickSound("button_click_stats");
	
	SET_ITEM_TOOLTIP_BY_TYPE(ctrlSet, itemCls.ClassID);
	
	ctrlSet:Resize(box:GetWidth() - 30, ctrlSet:GetHeight());

	y = y + ctrlSet:GetHeight();
	return y;
end

function OPEN_CONTENTS_ALERT_REWARD(argNum)
	local frame = ui.GetFrame("contents_alert_reward")
	local box = GET_CHILD(frame, "box")
	local itemText = GET_CHILD(frame, "itemText")
	local warning = GET_CHILD(frame, "warning")

	local cls = GetClassByType("contents_alert_table", argNum)
	local multiple = TryGetProp(cls, "SilverMulti")
	local rewardStr = TryGetProp(cls, "Reward")
    local rewardList = StringSplit(rewardStr, ';');

	itemText:SetTextByKey("value", multiple)
	warning:SetTextByKey("value", multiple)

	box:RemoveAllChild()
	local y = 5;
	for i = 1, #rewardList do
		local reward = StringSplit(rewardList[i],'/')
		y = CREATE_REWARD_CTRL(box, y, i, reward[1], reward[2])
		y = y + 5
	end

	frame:ShowWindow(1)
end