
function FOODTABLE_REGISTER_ON_INIT(addon, frame)
end

function FOODTABLE_UI_CLOSE()

	local frame = ui.GetFrame("foodtable_register")
	if ui ~= nil then
		ui.CloseFrame("foodtable_register");	
	else
		print("UI(foodtable_register) is nil. Check uiframe.name from foodtable_register.xml file")
	end

end

function FOODTABLE_SKILL_INIT(frame, skillName, sklLevel)

	frame:SetUserValue("SKILL_NAME", skillName);
	frame:SetUserValue("SKILL_LEVEL", sklLevel);
	frame:SetUserValue("GROUP_NAME", "FoodTable");

	-- local silver = FOODTABLE_NEED_PRICE(skillName, sklLevel);
	-- local silver_text = GET_CHILD_RECURSIVELY(frame, "silver_text");
	-- silver_text:SetTextByKey("value", GET_MONEY_IMG(20) .. " " .. silver);
	
	local selectBox = GET_CHILD_RECURSIVELY(frame, "selectBox");
	selectBox:RemoveAllChild();

	local myObj = GetMyPCObject();
	local tableSkl = GetSkill(myObj, skillName);
	local clslist, cnt  = GetClassList("FoodTable");
	for i = 0 , cnt - 1 do
		local cls = GetClassByIndexFromList(clslist, i);
		-- 음식 제작의 필요 스킬레벨이 pc의 스킬 레벨 이하일때 출력
		if cls.SkillLevel <= sklLevel then
			local ctrlSet = selectBox:CreateControlSet('table_food_register', "FOOD_" .. cls.ClassName, 5, 0);
			local abilLevel = 0;
			local abilName = TryGetProp(cls, 'Ability', 'None');
			if abilName ~= nil and abilName ~= 'None' then
				local abil = GetAbility(myObj, abilName);
				if abil ~= nil then
					abilLevel = TryGetProp(abil, 'Level', 0);
				end
			end
			SET_FOOD_TABLE_BASE_INFO(ctrlSet, cls, sklLevel, abilLevel);
			SET_FOOD_TABLE_MATAERIAL_INFO(ctrlSet, cls);
		end
	end

	GBOX_AUTO_ALIGN(selectBox, 5, 3, 10, true, false);
end

function FOODTABLE_CHECK_FOR_SELL(ctrlset, ctrl)
	if ctrl:IsChecked() == 1 then
		local pc = GetMyPCObject();
		local type = ctrlset:GetUserIValue("FOOD_TYPE");
		local cls = GetClassByType("FoodTable", type);
		local list = StringSplit(cls.Material, "/");
		for i = 1, #list / 2 do
			local itemName = list[2 * i - 1];
			local itemCount = tonumber(list[2 * i]);
			local invCount = GetInvItemCount(pc, itemName);
			if invCount < itemCount then
				ui.SysMsg(ClMsg('NotEnoughMaterial'));
				ctrl:SetCheck(0);
				return;
			end
		end
	end
end

function FOODTABLE_REG_EXEC(parent, ctrl)
	local frame = parent:GetTopParentFrame();
	local skillName = frame:GetUserValue("SKILL_NAME");
	local sklLevel = frame:GetUserIValue("SKILL_LEVEL");
	local pc = GetMyPCObject();
	-- local silver = FOODTABLE_NEED_PRICE(skillName, sklLevel);
	-- if IsGreaterThanForBigNumber(silver, GET_TOTAL_MONEY_STR()) == 1 then
	-- 	ui.SysMsg(ClMsg('NotEnoughMoney'));
	-- 	return;
	-- end

	local x, y, z = GetPos(pc);
	if 0 == IsFarFromNPC(pc, x, y, z, 70) then
		ui.SysMsg(ClMsg("TooNearFromNPC"));	
		return 0;
	end

	if 1 == CheckDynamicOBB(pc, x, y, z, 15) then
		ui.SysMsg(ClMsg("AbnormalTerrain"));	
		return 0;
	end

	local strScp = "_FOODTABLE_REG_EXEC()";
	ui.MsgBox(ScpArgMsg("REALLY_DO"), strScp, "None");
end

function _FOODTABLE_REG_EXEC()
	local frame = ui.GetFrame("foodtable_register");
	local skillName = frame:GetUserValue("SKILL_NAME");
	local sklLevel = frame:GetUserIValue("SKILL_LEVEL");
	local sklCls = GetClass("Skill", skillName);
    local shared = frame:GetUserIValue("SHARED_VALUE");
	local title = "";
	if shared == 1 then
		local ctrlSet_guild = GET_CHILD_RECURSIVELY(frame, 'check_guild');
		local titleEdit = GET_CHILD_RECURSIVELY(ctrlSet_guild, 'TitleInput');
		title = titleEdit:GetText();
	elseif shared == 2 then
		local ctrlSet_all = GET_CHILD_RECURSIVELY(frame, 'check_all');
		local titleEdit = GET_CHILD_RECURSIVELY(ctrlSet_all, 'TitleInput');
		title = titleEdit:GetText();
	end

	if shared > 0 and (title == nil or TrimString(title) == "") then
		ui.SysMsg(ClMsg("InputTitlePlease"))
		return
	end

	local groupName = frame:GetUserValue("GROUP_NAME");
	session.autoSeller.ClearGroup(groupName);
	local selectBox = GET_CHILD_RECURSIVELY(frame, 'selectBox');
	local childCount = selectBox:GetChildCount();
	local pc = GetMyPCObject();
	local selectCount = 0;
	for i = 0, childCount - 1 do
		local child = selectBox:GetChildByIndex(i);
		if string.find(child:GetName(), 'FOOD_') ~= nil then
			local selectCheck = GET_CHILD(child, 'selectCheck');
			if selectCheck:IsChecked() == 1 then
				local type = child:GetUserIValue("FOOD_TYPE");
				local cls = GetClassByType("FoodTable", type);
				local list = StringSplit(cls.Material, "/");
				for i = 1, #list / 2 do
					local itemName = list[2 * i - 1];
					local itemCount = tonumber(list[2 * i]);
					local invCount = GetInvItemCount(pc, itemName);
					if invCount < itemCount then
						return;
					end
				end
				
				local info = session.autoSeller.CreateToGroup(groupName);
				info.classID = cls.ClassID;
				info.level = sklLevel;
				selectCount = selectCount + 1;
			end
		end
	end

	if selectCount <= 0 then
		return
	end

    session.autoSeller.RequestRegister(groupName, groupName, title, skillName, shared);
end

function OPEN_FOODTABLE_REGISTER(frame)
	frame:SetUserValue("SHARED_VALUE", 0);

	local optionBox = GET_CHILD_RECURSIVELY(frame, 'optionBox');
	
	local ctrlSet_guild = optionBox:CreateOrGetControlSet('food_check_party', "check_guild", 15, 0);
	local checkBox_guild = GET_CHILD(ctrlSet_guild, "check_party", "ui::CCheckBox");
	local titleBox_guild = ctrlSet_guild:GetChild('gBox');
	
	local ctrlSet_all = optionBox:CreateOrGetControlSet('food_check_party', "check_all", 15, 30);
	local checkBox_all = GET_CHILD(ctrlSet_all, "check_party", "ui::CCheckBox");
	local titleBox_all = ctrlSet_all:GetChild('gBox');

	checkBox_guild:SetText(ClMsg('FreeFoodForGuild'));
	checkBox_guild:SetEventScript(ui.LBUTTONUP, 'FOODTABLE_CHECK_BOX_FOR_GUILD');
	checkBox_guild:SetCheck(0);
	checkBox_guild:ShowWindow(1);
	FOODTABLE_CHECK_BOX_FOR_GUILD(ctrlSet_guild, checkBox_guild);
	
	local guildInfo = session.party.GetPartyInfo(PARTY_GUILD);
	if guildInfo ~= nil then
		checkBox_guild:SetEnable(1)
	else
		checkBox_guild:SetEnable(0)
	end
	
	checkBox_all:SetText(ClMsg('FreeFoodForAll'));
	checkBox_all:SetEventScript(ui.LBUTTONUP, 'FOODTABLE_CHECK_BOX_FOR_ALL');
	checkBox_all:SetCheck(0);
	checkBox_all:ShowWindow(1);
	FOODTABLE_CHECK_BOX_FOR_ALL(ctrlSet_all, checkBox_all);
end

function FOODTABLE_CHECK_BOX(parent, ctrl)
	local frame = parent:GetTopParentFrame();
	local share = ctrl:IsChecked();
	frame:SetUserValue("SHARED_VALUE", share);

	local titleBox = GET_CHILD(parent, "gBox", "ui::CGroupBox");
	titleBox:SetVisible(share);
end

function FOODTABLE_CHECK_BOX_FOR_GUILD(parent, ctrl)
	local topParent = parent:GetTopParentFrame();

	local checked_guild = ctrl:IsChecked();
	local share = 0;
	local isVisible = 0;

	local ctrlSet_all = GET_CHILD_RECURSIVELY(topParent, 'check_all');
	local checkBox_all = GET_CHILD(ctrlSet_all, 'check_party', 'ui::CCheckBox');
	
	local checked_all = checkBox_all:IsChecked();
	if checked_guild == 1 then
		if checked_all == 1 then
			checkBox_all:SetCheck(0);
			local titleBox_all = GET_CHILD(ctrlSet_all, "gBox", "ui::CGroupBox");
			titleBox_all:SetVisible(0);
		end

		ctrlSet_all:SetMargin(15, 80, 0, 0);

		share = 1;
		isVisible = 1;
	else
		ctrlSet_all:SetMargin(15, 30, 0, 0);
	end

	topParent:SetUserValue("SHARED_VALUE", share);

	local titleBox = GET_CHILD(parent, "gBox", "ui::CGroupBox");
	titleBox:SetVisible(isVisible);
end

function FOODTABLE_CHECK_BOX_FOR_ALL(parent, ctrl)
	local topParent = parent:GetTopParentFrame();

	local checked_all = ctrl:IsChecked();
	local share = 0;
	local isVisible = 0;

	local ctrlSet_guild = GET_CHILD_RECURSIVELY(topParent, 'check_guild');
	local checkBox_guild = GET_CHILD(ctrlSet_guild, 'check_party', 'ui::CCheckBox');
	local checked_guild = checkBox_guild:IsChecked();
	if checked_all == 1 then
		if checked_guild == 1 then
			checkBox_guild:SetCheck(0);
			local titleBox_guild = GET_CHILD(ctrlSet_guild, "gBox", "ui::CGroupBox");
			titleBox_guild:SetVisible(0);

			parent:SetMargin(15, 30, 0, 0);
		end

		share = 2;
		isVisible = 1;
	end

	topParent:SetUserValue("SHARED_VALUE", share);

	local titleBox = GET_CHILD(parent, "gBox", "ui::CGroupBox");
	titleBox:SetVisible(isVisible);
end