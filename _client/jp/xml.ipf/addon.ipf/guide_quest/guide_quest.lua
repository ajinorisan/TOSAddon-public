function GUIDE_QUEST_ON_INIT(addon, frame)
	-- 보상 받았을 때
	-- 서브 미션 완료했을 때
	addon:RegisterMsg('GUIDE_QUEST_UPDATE', 'GUIDE_QUEST_LOAD_TAB');
    addon:RegisterMsg('GUIDE_QUEST_UPDATE', 'GUIDE_QUEST_UPDATE_MISSION');
end

function GUIDE_QUEST_OPEN(frame)
	GUIDE_QUEST_INIT(frame)
    pc.ReqExecuteTx('GUIDE_QUEST_OPEN_UI', frame:GetName())
end


function GUIDE_QUEST_INIT(frame)
	GUIDE_QUEST_LOAD_TAB(frame)
end

function GUIDE_QUEST_LOAD_TAB(frame, msg, argString, argNum)
	local tabGb = GET_CHILD_RECURSIVELY(frame, "tab_gb")
	tabGb:RemoveAllChild()
	tabGb:SetScrollBarOffset(2, 1)
	tabGb:SetScrollBarSkinName("worldmap2_scrollbar")

	local aObj = GetMyAccountObj()
	local clsList, cnt = GetClassList('guide_main');
	local toggleNum = cnt 
	for i = 0, cnt - 1 do
		local cls = GetClassByIndexFromList(clsList, i);
		local accProp = TryGetProp(cls, "AccProp", "None")
		local missionGroup = TryGetProp(cls, "Mission_Group", 0)

		local tabCtrl = tabGb:CreateOrGetControlSet('guide_quest_tab', 'TAB_C_'..missionGroup, 0, 50 * i);
		local tabBtn = GET_CHILD(tabCtrl, "tab_btn")
		tabBtn:SetTextByKey("value", missionGroup)
		tabBtn:SetEventScriptArgNumber(ui.LBUTTONUP, missionGroup)
		local questCheck = TryGetProp(aObj, accProp)
		if i ~= 0 and questCheck == "None" then
			tabBtn:SetEnable(0)
		elseif questCheck == "InProgress" then
			toggleNum = i + 1
		end
	end
	GUIDE_QUEST_SELECT_MAIN_MISSION(frame, nil, nil, toggleNum)
end

function GUIDE_QUEST_UPDATE_MISSION(frame, msg, argString, missionGroup)
	if missionGroup == 0 or missionGroup == nil then
		return
	end
	GUIDE_QUEST_LOAD_MAIN_MISSION(frame, missionGroup)
	GUIDE_QUEST_LOAD_SUB_MISSION(frame, missionGroup)
	GUIDE_QUEST_LOAD_REWARD(frame, missionGroup)
end

function GUIDE_QUEST_SELECT_MAIN_MISSION(parent, self, argStr, argNum)
	GUIDE_QUEST_UPDATE_MISSION(parent, nil, nil, argNum)
	GUIDE_QUEST_TOGGLE_TAB(parent, self, nil, argNum)
end


function GUIDE_QUEST_LOAD_MAIN_MISSION(frame, missionGroup)
	local frame = frame:GetTopParentFrame()
	local mainCls = GetClassByNumProp("guide_main", "Mission_Group", missionGroup);
	local description = TryGetProp(mainCls, "Description")

	local questText = GET_CHILD_RECURSIVELY(frame, "quest_text")
	local countText = GET_CHILD_RECURSIVELY(frame, "count_text")
	local descText = GET_CHILD_RECURSIVELY(frame, "desc_text")
	local maxCnt, curCnt = GUIDE_QUEST_GET_MAIN_QUEST_INFO(GetMyAccountObj(), missionGroup)

	questText:SetTextByKey("value", missionGroup)
	countText:SetTextByKey("cur", curCnt)
	countText:SetTextByKey("max", maxCnt)
	descText:SetTextByKey("desc", description)
end

function GUIDE_QUEST_LOAD_SUB_MISSION(frame, missionGroup)
	local frame = frame:GetTopParentFrame()
	local missionGb = GET_CHILD_RECURSIVELY(frame, "mission_gb")
	missionGb:RemoveAllChild()
	missionGb:SetScrollBarOffset(0, 0)
	missionGb:SetScrollBarSkinName("verticalscrollbar4")

	local aObj = GetMyAccountObj()
	local clsList, cnt = GetClassListByProp('guide_submission', 'Mission_Group', missionGroup)
	for i = 1, cnt do
		local cls = clsList[i]
		local clsName = TryGetProp(cls, "ClassName")
		local accProp = TryGetProp(cls, "AccProp")
		local conditionText = TryGetProp(cls, "Condition_Text")
		local conditionValue = TryGetProp(cls, "Condition_Value")
		local helpLink = TryGetProp(cls, "Help_Link", 0)

		local curCnt = TryGetProp(aObj, accProp, 0)

		local missionCtrl = missionGb:CreateOrGetControlSet('guide_quest_mission', 'MISSION_C_'..i, 0, 70 * (i - 1));
		local helpBtn = GET_CHILD(missionCtrl, "help_btn")
		local missionText = GET_CHILD(missionCtrl, "mission_text")
		local countText = GET_CHILD(missionCtrl, "count_text")

		helpBtn:SetEventScriptArgNumber(ui.LBUTTONUP, helpLink)
		missionText:SetTextByKey("text", conditionText)
		countText:SetTextByKey("cur", curCnt)
		countText:SetTextByKey("max", conditionValue)
	end
end

function GUIDE_QUEST_LOAD_REWARD(frame, missionGroup)
	local frame = frame:GetTopParentFrame()
	local rewardSlotSet = GET_CHILD_RECURSIVELY(frame, "slotset_list_reward")
	local coinRewardGb = GET_CHILD_RECURSIVELY(frame, "coin_reward_gb")

    rewardSlotSet:ClearIconAll();    

	local itemList, coinList = GUIDE_QUEST_GET_REWARD_LIST(missionGroup)
	local rewardCnt = 0
	for k,v in pairs(itemList) do
		local slot = rewardSlotSet:GetSlotByIndex(rewardCnt)
		local icon = CreateIcon(slot)
		local cls = GetClassByStrProp("Item", "ClassName", k)
		
		if cls ~= nil then
			iconName = BEAUTYSHOP_SIMPLELIST_ICONNAME_CHECK(TryGetProp(cls, "Icon", "None"), TryGetProp(cls, "UseGender", "None"))
			icon:SetImage(iconName)

			SET_ITEM_TOOLTIP_BY_NAME(icon, cls.ClassName);
			SET_SLOT_COUNT_TEXT(slot, v)
			icon:SetTooltipOverlap(1);
		end
		rewardCnt = rewardCnt + 1				
	end


	coinRewardGb:RemoveAllChild()
	local startpoint = { 228, 114, 0 }
	local coinCount = 0
	local listCount = 0
	for k,v in pairs(coinList) do listCount = listCount + 1 end

	for k,v in pairs(coinList) do
		local coinCtrl = coinRewardGb:CreateOrGetControlSet('guide_quest_coin', 'COIN_C_'..k, startpoint[listCount] + 228 * coinCount, 0);

		local coinPic = GET_CHILD(coinCtrl, "coin_pic")
		local coinText = GET_CHILD(coinCtrl, "coin_text")

		local coinIcon = "silver_pic"
		if k ~= "Silver" then
			local cls = GetClass("accountprop_inventory_list", "GabijaCertificate")
			coinIcon = TryGetProp(cls, "Icon")
		end
		coinPic:SetImage(coinIcon)
		coinText:SetTextByKey("value", GET_COMMAED_STRING(v))
		coinCount = coinCount + 1
	end

	local aObj = GetMyAccountObj()
	local mainCls = GetClassByNumProp("guide_main", "Mission_Group", missionGroup);
	local accProp = TryGetProp(mainCls, "AccProp", "None")
	local questCheck = TryGetProp(aObj, accProp)
	local rewardBtn = GET_CHILD_RECURSIVELY(frame, "reward_btn")
	if questCheck == "Clear" then
		rewardBtn:SetEnable(0)
		rewardBtn:SetTextByKey("text", ClMsg("ReceiveComplete"))
	else
		rewardBtn:SetEnable(1)
		rewardBtn:SetTextByKey("text", ClMsg("ReceiveReward"))
		rewardBtn:SetEventScriptArgNumber(ui.LBUTTONUP, missionGroup);
	end
end


function GUIDE_QUEST_HELP_CLICK(parent,ctrl,argStr,argNum)
	if argNum == nil or argNum == 0 then
		return
	end
	local piphelp = ui.GetFrame("piphelp");
	PIPHELP_MSG(piphelp, "FORCE_OPEN", argStr, argNum)
end

function GUIDE_QUEST_TOGGLE_TAB(frame, tab, argStr, argNum)
	local frame = frame:GetTopParentFrame()
	if tab == nil then
		local tabNum = 1
		if argNum ~= nil then
			tabNum = argNum
		end
		local tabGb = GET_CHILD_RECURSIVELY(frame, "tab_gb")
		tab = tabGb:GetChildByIndex(tabNum)
		tab = tab:GetChildByIndex(0)
		tolua.cast(tab, tab:GetClassString());
	end

	local prevTabName = frame:GetUserValue("PREV_TAB_NAME")
	local currentTabName = tab:GetParent():GetName()
	if prevTabName ~= "None" and prevTabName ~= currentTabName then
		local prevTabCtrl = GET_CHILD_RECURSIVELY(frame, prevTabName)
		local prevTab = GET_CHILD(prevTabCtrl, "tab_btn")
		prevTab:SetForceClicked(false)
	end

	tab:SetForceClicked(true)
	frame:SetUserValue("PREV_TAB_NAME", currentTabName)
end

function GUIDE_QUEST_GET_REWARD(parent, self, argStr, argNum)
	local aObj = GetMyAccountObj()
	local maxCnt, curCnt = GUIDE_QUEST_GET_MAIN_QUEST_INFO(aObj, argNum)
	if curCnt ~= maxCnt then
		ui.SysMsg(ClMsg("SoloDungeonRewardNotYet"))
		return
	end

    pc.ReqExecuteTx('GUIDE_QUEST_RECEIVE_REWARD', argNum)
end