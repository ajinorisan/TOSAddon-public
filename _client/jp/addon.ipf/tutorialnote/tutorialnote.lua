function TUTORIALNOTE_ON_INIT(addon, frame)
	addon:RegisterMsg("TUTORIALNOTE_REWARD_GET", "TUTORIALNOTE_REWARD_GET");
end

function OPEN_TUTORIALNOTE_SCP(frame)
	TUTORIALNOTE_GUIDE_EFFECT_UPDATE(frame);
	TUTORIALNOTE_MISSION_EFFECT_UPDATE(frame);

	local tab = GET_CHILD(frame, "label_tab");
	tab:SelectTab(0);

	local group = tab:GetSelectItemName();
	TUTORIALNOTE_PAGE_UPDATE(frame, group);

	local minimizedFrame = ui.GetFrame("minimized_tutorialnote_button");
	local pointPicShow = minimizedFrame:GetUserIValue("POINT_PIC_SHOW");
	if pointPicShow == 1 then
		control.CustomCommand("REQ_TUTORIALNOTE_UI_OPEN_CHECK", 0);
	end
end

function CLOSE_TUTORIALNOTE(frame)
	frame:ShowWindow(0);
end

function TUTORIALNOTE_GUIDE_EFFECT_UPDATE(frame, msg, argStr, argNum)
	local aObj = GetMyAccountObj();
	local guide_point = GET_CHILD_RECURSIVELY(frame, "guide_point");

	local result = TUTORIALNOTE_GROUP_CHECK(aObj, "guide");
	if result == true then
		guide_point:ShowWindow(1);
	else
		guide_point:ShowWindow(0);
	end
end

function TUTORIALNOTE_MISSION_EFFECT_UPDATE(frame, msg, argStr, argNum)
	local aObj = GetMyAccountObj();

	local result1 = TUTORIALNOTE_GROUP_CHECK(aObj, "mission_1");
	local mission_1_point = GET_CHILD_RECURSIVELY(frame, "mission_1_point");
	if result1 == true then
		mission_1_point:ShowWindow(1);
	else
		mission_1_point:ShowWindow(0);
	end

	local result2 = TUTORIALNOTE_GROUP_CHECK(aObj, "mission_2");
	local mission_2_point = GET_CHILD_RECURSIVELY(frame, "mission_2_point");
	if result2 == true then
		mission_2_point:ShowWindow(1);
	else
		mission_2_point:ShowWindow(0);
	end
	
	local result3 = TUTORIALNOTE_GROUP_CHECK(aObj, "mission_3");
	local mission_3_point = GET_CHILD_RECURSIVELY(frame, "mission_3_point");
	if result3 == true then
		mission_3_point:ShowWindow(1);
	else
		mission_3_point:ShowWindow(0);
	end
end

function TUTORIALNOTE_SELECT_TAB(parent, ctrl, argStr, argNum)
	local frame = parent:GetTopParentFrame()
	local group = ctrl:GetSelectItemName();
	TUTORIALNOTE_PAGE_UPDATE(frame, group);
end

function TUTORIALNOTE_PAGE_UPDATE(frame, group)	
	local pc = GetMyPCObject();
	local aObj = GetMyAccountObj();

	local typename_text = GET_CHILD_RECURSIVELY(frame, "typename_text");
	if group == "guide" then
		typename_text:SetTextByKey("value", ClMsg("Guide"));
	else
		typename_text:SetTextByKey("value", ClMsg("Mission"));
	end

	local note_gb = GET_CHILD_RECURSIVELY(frame, "note_gb");
	note_gb:SetScrollPos(0);
	note_gb:RemoveAllChild();
	
	local clslist, cnt  = GetClassList("tutorialnotelist");
	local y = 0;
	for i = 0 , cnt - 1 do
		local isCondition = false;
		local cls = GetClassByIndexFromList(clslist, i);
		local preScp = TryGetProp(cls, "PreCheckScp", "None");
		local IsHide = TryGetProp(cls, "IsHideCheck", "None");

		if IsHide ~= "YES" or IsHide == "None" then
		
			if preScp ~= "None" then
				local ScrPtr = _G[preScp];
				if true == ScrPtr(pc, aObj) then
					isCondition = true;				
				end
			else
				isCondition = true;
			end

			local clsGroup = TryGetProp(cls, "Group", "None");
			if clsGroup == group then
				local className = TryGetProp(cls, "ClassName", "None");
				local ctrlSet = note_gb:CreateOrGetControlSet("tutorialnote_block", className, 0, y);
				ctrlSet:SetGravity(ui.CENTER_HORZ, ui.TOP);

				local main_gb = GET_CHILD(ctrlSet, "main_gb");
				local check_bg = GET_CHILD(ctrlSet, "check_bg");
				local clear_bg = GET_CHILD(ctrlSet, "clear_bg");
				local clear_pic = GET_CHILD(ctrlSet, "clear_pic");
				
				check_bg:ShowWindow(0);
				clear_bg:ShowWindow(0);
				clear_pic:ShowWindow(0);

				local state = GET_TUTORIALNOTE_STATE(aObj, className);
				if group == "guide" then -- 가이드
					if state == "PROGRESS" or state == "POSSIBLE" then
						isCondition = false;
					end
				end

				if isCondition == false then
					main_gb:ShowWindow(0);
					clear_bg:ShowWindow(1);

					local condition_text = GET_CHILD(ctrlSet, "condition_text");
					condition_text:SetTextByKey("value", TryGetProp(cls, "Title").."{nl} {nl} {nl}"..TryGetProp(cls, "ConditionText", "None"));
				else
					TUTORIALNOTE_BLOCK_MAIN_UPDATE(frame, cls, ctrlSet, state);

					if group == "guide" then -- 가이드
						if state == "Reward" or state == "Clear" then							
							local main_pic = GET_CHILD(main_gb, "main_pic");
							main_pic:EnableHitTest(1);					
							main_pic:SetEventScript(ui.LBUTTONUP, "TUTORIALNOTE_GUIDE_CLICK");
							main_pic:SetEventScriptArgString(ui.LBUTTONUP, className);
						end	
					else -- 미션	
						if state == "Reward" then
							check_bg:SetEventScript(ui.LBUTTONUP, "TUTORIALNOTE_MISSION_REWARD_REQUEST");
							check_bg:SetEventScriptArgString(ui.LBUTTONUP, className);	
							check_bg:EnableHitTest(1);
						end
					end
				end

				local question = GET_CHILD(ctrlSet, "question");
				local helpType = TryGetProp(cls, "HelpType", 0);
				if helpType == 0 then
					question:ShowWindow(0);
				else
					question:SetEventScriptArgNumber(ui.LBUTTONUP, helpType);
				end

				y = y + ctrlSet:GetHeight();
			end
		end
	end
end

function TUTORIALNOTE_BLOCK_MAIN_UPDATE(frame, cls, ctrlSet, state)
	local main_gb = GET_CHILD(ctrlSet, "main_gb");
	main_gb:ShowWindow(1);

	local title = GET_CHILD(main_gb, "title");
	title:SetTextByKey("value", TryGetProp(cls, "Title"));

	local descCtrl = GET_CHILD(main_gb, "desc");
	local descStr = TryGetProp(cls, "Desc", "None");
	descCtrl:SetTextByKey("value", descStr);

	local DescTooltipStr = TryGetProp(cls, "DescTooltip", "None");
	if DescTooltipStr ~= "None" then
		descCtrl:SetTextTooltip(DescTooltipStr);
		descCtrl:EnableHitTest(1);
	end

	if state == "Reward" then
		local check_bg = GET_CHILD(ctrlSet, "check_bg");
		check_bg:ShowWindow(1);
	elseif state == "Clear" then
		local group = TryGetProp(cls, "Group", "None");
		TUTORIALNOTE_BLOCK_CLEAR_UPDATE(ctrlSet, group);		
	end

	local reward_gb = GET_CHILD(main_gb, 'reward_gb');
	reward_gb:RemoveAllChild();

	local REWARD_TEXT_FONT = frame:GetUserConfig('REWARD_TEXT_FONT');
	local REWARD_DESC_OFFSET_Y = frame:GetUserConfig('REWARD_DESC_OFFSET_Y');

	local rewardStr = TryGetProp(cls, "Reward", "None");
	local rewardStrlist = StringSplit(rewardStr, '/');
	local rewardcnt = #rewardStrlist;

	local reward_Y = 0;
	for j = 1, rewardcnt - 1, 2 do
		local itemcls = GetClass('Item', rewardStrlist[j]);
		local itemname = TryGetProp(itemcls, 'Name', 'None');

		local rewardtext = reward_gb:CreateOrGetControl('richtext', 'REWARD_TEXT_'..(math.floor(j/2)), 0, reward_Y, 100, 10);
		rewardtext:SetText(itemname.." "..rewardStrlist[j+1]..ClMsg("Piece"));
		rewardtext:SetFontName(REWARD_TEXT_FONT);
		rewardtext:SetGravity(ui.CENTER_HORZ, ui.TOP);

		reward_Y = reward_Y + REWARD_DESC_OFFSET_Y;
	end
	
	local go_btn = GET_CHILD(main_gb, "go_btn");
	local shortCutStr = TryGetProp(cls, "ShortCut", "None");
	if shortCutStr == "None" then
		go_btn:ShowWindow(0);
	elseif shortCutStr ~= "None" and state ~= "Clear" then
		local className = TryGetProp(cls, "ClassName", "None");
		go_btn:SetEventScript(ui.LBUTTONUP, "TUTORIALNOTE_GO_BUTTON_CLICK");
		go_btn:SetEventScriptArgString(ui.LBUTTONUP, className);
		go_btn:ShowWindow(1);

		local buttonTooltipStr = TryGetProp(cls, "ButtonTooltip", "None");
		if buttonTooltipStr ~= "None" then
			go_btn:SetTextTooltip(buttonTooltipStr);
		else
			go_btn:SetTextTooltip("");
		end
	end
end

function TUTORIALNOTE_GUIDE_CLICK(parent, ctrl, argStr, argNum)
	local className = argStr;
	local cls = GetClass("tutorialnotelist", className);
	pc.ReqExecuteTx("SCR_TUTORIALNOTE_GUIDE_CLICK", className);
end

function TUTORIALNOTE_GO_BUTTON_CLICK(parent, ctrl, argStr, argNum)
	if argStr == nil or argStr == "None" then
		return
	end

	local cls = GetClass("tutorialnotelist", argStr);
	if cls == nil then
		return;
	end

	local zoneName = GetZoneName();
	local mapCls = GetClass("Map", zoneName);
	if mapCls == nil or TryGetProp(mapCls, "MapType", "None") ~= "City" then
		ui.SysMsg(ClMsg("AllowedInTown1"))
		return
	end

	for i = 0, AUTO_SELL_COUNT-1 do
		if session.autoSeller.GetMyAutoSellerShopState(i) == true then
			ui.SysMsg(ClMsg("StateOpenAutoSeller"))
			return
		end
	end

	local ShortCutStr = TryGetProp(cls, "ShortCut");
	local ShortCutStrList = StringSplit(ShortCutStr,'/')
	local type = ShortCutStrList[1];
	if type == 'ui' then
		local frameName = ShortCutStrList[2]
		ui.OpenFrame(frameName)
	elseif type == 'warp' then
		if argStr == "mission_3_15" then
			control.CustomCommand("REQ_TUTORIALNOTE_ICON_MISSION_WARP_DLG", 0);
			return;
		end
		
		local yesScp = string.format("_TUTORIALNOTE_GO_BUTTON_CLICK(\"%s\")", argStr);
		local mapCls = GetClass("Map", ShortCutStrList[2]);
		if mapCls == nil then
			return;
		end

		ui.MsgBox("["..mapCls.Name.."]"..ClMsg('Auto_JiyeogeuLo{nl}_iDongHaSiKessSeupNiKka?'), yesScp, "None");
	elseif type == 'scp' then
		local Script = _G[ShortCutStrList[2]]
		Script()
	end
end

function _TUTORIALNOTE_GO_BUTTON_CLICK(className)
	pc.ReqExecuteTx("SCR_TUTORIALNOTE_SHORTCUT", className);
end

function TUTORIALNOTE_MISSION_REWARD_REQUEST(parent, ctrl, argStr, argNum)
	pc.ReqExecuteTx("SCR_TUTORIALNOTE_MISSION_REWARD", argStr);
end

-- 보상 획득한 level 미션 블럭 UI 변경
function TUTORIALNOTE_REWARD_GET(frame, msg, argStr, argNum)
	if frame:IsVisible() ~= 1 then
		return
	end
	
	local note_gb = GET_CHILD_RECURSIVELY(frame, "note_gb");
	local ctrlSet = GET_CHILD_RECURSIVELY(note_gb, argStr);
	ctrlSet = tolua.cast(ctrlSet, 'ui::CControlSet');

	local cls = GetClass("tutorialnotelist", argStr);
	local group = TryGetProp(cls, "Group", "None");
	TUTORIALNOTE_BLOCK_CLEAR_UPDATE(ctrlSet, group);

	local clear_pic = GET_CHILD_RECURSIVELY(ctrlSet, 'clear_pic');
	UI_PLAYFORCE(clear_pic, "sizeUpAndDown");

	if group == "guide" then
		TUTORIALNOTE_GUIDE_EFFECT_UPDATE(frame);
	else
		TUTORIALNOTE_MISSION_EFFECT_UPDATE(frame);
	end	
end

function TUTORIALNOTE_BLOCK_CLEAR_UPDATE(ctrlSet, group)
	local descCtrl = GET_CHILD_RECURSIVELY(ctrlSet, "desc");
	descCtrl:EnableHitTest(0);
	
	local check_bg = GET_CHILD_RECURSIVELY(ctrlSet, 'check_bg');
	check_bg:ShowWindow(0);
	check_bg:EnableHitTest(0);

	-- 보상 획득
	local clear_bg = GET_CHILD_RECURSIVELY(ctrlSet, 'clear_bg');
	local clear_pic = GET_CHILD_RECURSIVELY(ctrlSet, 'clear_pic');	
	if config.GetServiceNation() ~= 'KOR' then
		clear_pic:SetImage("very_nice_stamp_eng");
	end

	clear_pic:ShowWindow(1);
	clear_bg:ShowWindow(1);

	local go_btn = GET_CHILD_RECURSIVELY(ctrlSet, 'go_btn');
	go_btn:EnableHitTest(0);
end