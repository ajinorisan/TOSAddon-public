local function get_list_and_edit(bg)
	local opt_list = GET_CHILD(bg,"opt_list");
	local opt_edit = GET_CHILD(bg,"opt_edit");
	return {opt_list,opt_edit};
end

local function get_current_enchant_item_grade_and_rank()
	local hairenchant = ui.GetFrame("high_hairenchant");
	if hairenchant == nil  then
		return;
	end

	local enchantGuid = hairenchant:GetUserValue("Enchant");
	local itemIES = hairenchant:GetUserValue("itemIES");

	if enchantGuid == "None" or itemIES == "None" then
		return ;
	end

	local item = session.GetInvItemByGuid(itemIES);
	local enchant_item = session.GetInvItemByGuid(enchantGuid);
	if enchant_item == nil or item == nil then
		return;
	end
	
	enchant_item = GetIES(enchant_item:GetObject())
	item = GetIES(item:GetObject())

	local item_grade = shared_enchant_special_option.get_enchant_item_grade(enchant_item);
	local item_rank = shared_enchant_special_option.get_item_rank(item);
	return item_grade, item_rank;
end

local function INIT_DROPLIST_OPTIONLIST(frame)
	local OptionList, cnt = GetClassList("enchant_special_option")
	if OptionList == nil then
		return;
	end

	local bg = GET_CHILD(frame,"bg")
	local droplistbg = GET_CHILD(bg,"droplistbg");
	local fstbg = GET_CHILD_RECURSIVELY(droplistbg,"fstbg")
	local sndbg = GET_CHILD_RECURSIVELY(droplistbg,"sndbg")
	local trdbg = GET_CHILD_RECURSIVELY(droplistbg,"trdbg")
	local UIList = {get_list_and_edit(fstbg),get_list_and_edit(sndbg),get_list_and_edit(trdbg)}
	
	local item_grade, item_rank = get_current_enchant_item_grade_and_rank()

	if item_grade == nil or item_rank == nil then
		for k,v in pairs(UIList) do
			v[1]:ClearItems();
			v[1]:AddItem(0,ClMsg("IndunRewardItem_Empty"),-1);
			v[2]:SetNumberMode(1)
			v[2]:SetText(0);
		end
		return;
	end

	for k,v in pairs(UIList) do
		v[1]:ClearItems();
		v[1]:AddItem(0,ClMsg("IndunRewardItem_Empty"),-1);
		v[2]:SetNumberMode(1)
		v[2]:SetText(0);
	end

	for i = 0, cnt - 1 do
		local cls = GetClassByIndexFromList(OptionList, i)
		if cls == nil then
			break;
		end

		for j = 1, #UIList do
			local v = UIList[j]
			local RangeTable = shared_enchant_special_option.get_value_range(cls.ClassName, item_grade, item_rank, j);
			if RangeTable[1] ~= 0 and RangeTable[2] ~= 0 then
				local OptionString = string.format("%s %d~%d", ScpArgMsg(cls.ClassName), RangeTable[1], RangeTable[2])
				v[1]:AddItem(i + 1, OptionString, cls.ClassID);	
			end
		end
	end

end

local function INI_REPEAT_COUNT(frame)
	local title = GET_CHILD(frame,"title")
	local repeatCnt =GET_CHILD(title,"repeatCnt")
	if repeatCnt == nil then
		return;
	end
	repeatCnt:SetNumberMode(1);
	repeatCnt:SetText(0);
	repeatCnt:SetMaxNumber(9999);
	repeatCnt:SetMinNumber(0);
end

--- default function start
function HAIRENCHANT_OPTION_ON_INIT(addon, frame)
	INIT_DROPLIST_OPTIONLIST(frame)
end

function HAIRENCHANT_OPTION_OPEN_FRAME()
	local frame = ui.GetFrame("hairenchant_option");
	
	local invframe = ui.GetFrame("inventory");
	local mainFrame = ui.GetFrame("high_hairenchant");
	mainFrame:ShowWindow(1);
	frame:ShowWindow(1);
	frame:SetMargin(0, 40, mainFrame:GetWidth() + invframe:GetWidth(), 0);

	-- frame:SetUserValue("Enchant", invItem:GetIESID());
	-- frame:SetUserValue("EnchantScrollCount", itemHaveCount);
	-- local cnt = enchantFrame:GetChild("scrollCnt");
	-- cnt:SetTextByKey("value", itemHaveCount);

	
	

	INIT_DROPLIST_OPTIONLIST(frame)
	INI_REPEAT_COUNT(frame)




end

function CANCEL_ENCHANT_OPTION()
	ui.SetEscapeScp("");
	ui.CloseFrame("hairenchant_option")
end
--- default function end

--- btn function start

function AUTOOPTION_START_BTN(ctrl, frame, argStr, argNum)
	local hairenchant = ui.GetFrame("high_hairenchant");
	if hairenchant == nil  then
		return;
	end

	local parent = frame:GetTopParentFrame()
	local bg = GET_CHILD(parent,"bg");
	local title = GET_CHILD(parent,"title");
	local droplistbg = GET_CHILD(bg,"droplistbg");
	local fstbg = GET_CHILD_RECURSIVELY(droplistbg,"fstbg")
	local sndbg = GET_CHILD_RECURSIVELY(droplistbg,"sndbg")
	local trdbg = GET_CHILD_RECURSIVELY(droplistbg,"trdbg")

	local repeatCnt = GET_CHILD(title,"repeatCnt");
	
	local UIList = {get_list_and_edit(fstbg),get_list_and_edit(sndbg),get_list_and_edit(trdbg)}

	local options = {};
	for k,v in pairs(UIList) do
		local cls = GetClassByType("enchant_special_option", v[1]:GetSelItemValue());
		local Name = TryGetProp(cls,"ClassName","None");
		local value = v[2]:GetText();
		if Name == "None" then
			table.insert(options,string.format("%s",Name));
		else
			table.insert(options,string.format("%s;%s",Name,value));
		end

	end

	local cnt = tonumber(repeatCnt:GetText());

	AUTO_OPTION_SETTING(hairenchant,options,1);
	--SET_REPEAT_COUNT_TEXT(cnt);
end


function ENCHANT_OPTION_RESET(frame,ctrl,argStr,argNum)
	local parent = frame:GetTopParentFrame()
	INIT_DROPLIST_OPTIONLIST(parent)
	INI_REPEAT_COUNT(parent)

	local hairenchant = ui.GetFrame("high_hairenchant");
	HIGH_ENCHANT_CLEAR_DEST_OPTION_LIST(hairenchant)
end
--- btn function end


---typing function

function ENCAHNT_OPTION_TYPING(frame, ctrl, argStr, argNum)	
	local Value = ctrl:GetText();

	local OptUI = get_list_and_edit(frame)

	local cls = GetClassByType("enchant_special_option", OptUI[1]:GetSelItemValue());
	local Name = TryGetProp(cls,"ClassName","None");
	local item_grade, item_rank = get_current_enchant_item_grade_and_rank();

	if item_grade == nil or item_rank == nil then
		return;
	end

	local line = 1
	if frame:GetName() == 'fstbg' then
		line = 1
	elseif frame:GetName() == 'sndbg' then
		line = 2
	elseif frame:GetName() == 'trdbg' then
		line = 3
	end

	local RangeTable = shared_enchant_special_option.get_value_range(Name, item_grade, item_rank, line);

	-- if  tonumber(Value) < tonumber(RangeTable[1]) then
	-- 	--ctrl:SetText(RangeTable[1]);
	-- end
	
	if tonumber(Value) > tonumber(RangeTable[2]) then
		Value = RangeTable[2];
		frame:SetText(Value);
	end
	OptUI[2]:SetMaxNumber(RangeTable[2])

	local parent = ctrl:GetTopParentFrame();
	AUTOOPTION_START_BTN(ctrl,parent,argStr,argNum)
	-- OptUI[2]:SetMinNumber(0)
end

function ENCAHNT_REAPEAT_TYPING(frame, ctrl, argStr, argNum)
	local count = tonumber(ctrl:GetText());
	if count == nil then
		count = 0;
	end
	if count < 0 then
		count = 0;
	end
	SET_REPEAT_COUNT_TEXT(count);
end

---typing functuion

----- droplist select function start 
function ENCHANT_DROPLIST_SELECT(ctrl, frame, argStr, argNum)
	AUTOOPTION_START_BTN(ctrl,frame,argStr,argNum)
end
----- droplist select function end

--- external function start


function EXT_GET_BTN_ENCAHNT_REPEAT_COUNT()
	local option = ui.GetFrame("hairenchant_option")
	local title = GET_CHILD(option,"title");
	local repeatCnt = GET_CHILD(title,"repeatCnt")
	if repeatCnt == nil then
		return 0;
	end
	return tonumber(repeatCnt:GetText());
end

function EXT_SET_BTN_ENCAHNT_REPEAT_COUNT(count)
	local option = ui.GetFrame("hairenchant_option")
	local title = GET_CHILD(option,"title");
	local repeatCnt =GET_CHILD(title,"repeatCnt")
	if repeatCnt == nil then
		return ;
	end
	if count < 0 then
		count = 0
	end
	repeatCnt:SetText(count);
	SET_REPEAT_COUNT_TEXT(count);
end
--- external function end
