function EXTRACT_VIBORA_ON_INIT(addon, frame)
end

-- type, cabinet_weapon.xml, ClassID
function CREATE_OPENED_VIBORA_ITEM_LIST(box, y, index, type, item_cls)
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
	
	local itemName = TryGetProp(item_cls, 'Name', 'None')
	local itemIcon = item_cls.Icon
	local ctrlSet = box:CreateControlSet('quest_reward_s', "REWARD_" .. index, x, y);
	tolua.cast(ctrlSet, "ui::CControlSet");
	
	ctrlSet:SetValue(type);
	ctrlSet:SetSValue(itemName)

	local slot = ctrlSet:GetChild("slot");
	tolua.cast(slot, "ui::CSlot");
	
	local icon = CreateIcon(slot)
	icon:SetImage(itemIcon)

	local itemText = ctrlSet:GetChild("ItemName");
	itemName = "{@st41b}".. itemName
	itemText:SetText(itemName);

	ctrlSet:SetTooltipType("wholeitem");
	ctrlSet:SetTooltipArg("", item_cls.ClassID, 0);	

	ctrlSet:SetOverSound("button_cursor_over_3");
	ctrlSet:SetClickSound("button_click_stats");
	ctrlSet:SetEnableSelect(1);
	ctrlSet:SetSelectGroupName("QuestRewardList");
	
	ctrlSet:Resize(box:GetWidth() - 30, ctrlSet:GetHeight());

	y = y + ctrlSet:GetHeight();
	return y;

end

-- item_ep12.xml, CT_ClientScp
function OPEN_EXTRACT_SELECT_CABINET_VIBORA(invItem)
	local zoneName = GetZoneName()
	local mapCls = GetClass('Map', zoneName)
	if mapCls == nil or TryGetProp(mapCls, 'MapType', 'None') ~= 'City' then
		ui.SysMsg(ClMsg('AllowedInTown1'))
		return
	end

	local frame = ui.GetFrame("extract_vibora")
	frame:SetTitleName('{@st43}{s22}' ..ScpArgMsg('OpenExtractCabinetVibora'))
	local box = frame:GetChild('box');
	tolua.cast(box, "ui::CGroupBox");
	box:DeleteAllControl();
	local y = 5;

	local richtext_1 = GET_CHILD_RECURSIVELY(frame, 'richtext_1')
	if richtext_1 ~= nil then
		richtext_1:SetText(ClMsg('ExtractViboraRichtext'))
	end

	local index = 1
	local acc = GetMyAccountObj()

	local clsList, cnt = GetClassList('cabinet_weapon');
    for i = 0, cnt - 1 do
		local cls = GetClassByIndexFromList(clsList, i);
		if TryGetProp(cls, 'Upgrade', 0) == 1 then
			local prop = TryGetProp(cls, 'AccountProperty', 'None')			
			if TryGetProp(acc, prop, 0) ~= 0 then
				local upgrade_prop = TryGetProp(cls, 'UpgradeAccountProperty', 'None')
				local item_func_name = TryGetProp(cls, 'GetItemFunc', 'None')
				local get_item_func = _G[item_func_name]
				local item_name = get_item_func(cls, acc)
				y = CREATE_OPENED_VIBORA_ITEM_LIST(box, y, index, TryGetProp(cls, 'ClassID', 0), GetClass('Item', item_name));
				y = y + 5
				index = index + 1
			end
		end
	end

	if index == 1 then
		ui.SysMsg(ClMsg('CabinetAllClose'))
		return
	end

	local cancelBtn = frame:GetChild('CancelBtn');
	local useBtn = frame:GetChild('UseBtn');
	useBtn:SetEventScript(ui.LBUTTONUP,'REQUEST_EXTRACT_VIBORA')	

	box:Resize(box:GetOriginalWidth(), y);	    
	local screen_height = option.GetClientHeight();
	local maxSizeHeightFrame = box:GetY() + box:GetHeight() + 20;
	local maxSizeHeightWnd = ui.GetSceneHeight();
    
    if maxSizeHeightWnd >= 950 then        
        maxSizeHeightWnd = 950
    
        if maxSizeHeightWnd > screen_height then
            maxSizeHeightWnd = screen_height * 0.8
        end
    end
    
    if maxSizeHeightFrame >= maxSizeHeightWnd then
        maxSizeHeightFrame = maxSizeHeightWnd
    end
       
	if maxSizeHeightWnd < (maxSizeHeightFrame + 50) then                 
		local margin = maxSizeHeightWnd/2;
		box:EnableScrollBar(1);

		box:Resize(box:GetOriginalWidth(), margin - useBtn:GetHeight() - 40);
		box:SetScrollBar(0);
		box:InvalidateScrollBar();
		frame:Resize(frame:GetOriginalWidth(), margin + 100);
	else
		box:SetCurLine(0) -- scroll init
		
		box:Resize(box:GetOriginalWidth(), y);
		frame:Resize(frame:GetOriginalWidth(), maxSizeHeightFrame);
	end;
	box:SetScrollPos(0);
	local selectExist = 0;
	local cnt = box:GetChildCount();
	for i = 0 , cnt - 1 do
		local ctrlSet = box:GetChildByIndex(i);
		local name = ctrlSet:GetName();
		if string.find(name, "REWARD_") ~= nil then
			selectExist = 1;
		end 
	end

	local NeedItemSlot = frame:GetChild('NeedItemSlot')
	local NeedItemName = frame:GetChild('NeedItemName')
	NeedItemName:SetVisible(0)
	NeedItemSlot:SetVisible(0)

    local itemGuid = invItem:GetIESID();
	frame:SetUserValue("UseItemGuid", itemGuid);
	frame:ShowWindow(1);
end

function REQUEST_EXTRACT_VIBORA(frame, ctrl, argStr, argNum)    
	local box = frame:GetChild('box');
	tolua.cast(box, "ui::CGroupBox");

	local selectExist = 0;
	local selected = 0;
	local item_name = 'None'
	local cnt = box:GetChildCount();
	for i = 0 , cnt - 1 do
		local ctrlSet = box:GetChildByIndex(i);
		local name = ctrlSet:GetName();
		if string.find(name, "REWARD_") ~= nil then
			tolua.cast(ctrlSet, "ui::CControlSet");
			if ctrlSet:IsSelected() == 1 then
				selected = ctrlSet:GetValue();
				item_name = ctrlSet:GetSValue();
			end
			selectExist = 1;
		end
	end

	if selectExist == 1 and selected == 0 then
		ui.MsgBox(ScpArgMsg("Auto_BoSangeul_SeonTaegHaeJuSeyo."));
		return;
	end

	if selectExist == 1 then		
		local itemGuid = frame:GetUserValue("UseItemGuid")		
		local arg_str = string.format('%d', selected)		
		local yesScp = string.format("RUN_EXTRACT_VIBORA(%s, %s)", itemGuid, arg_str)
		local msg = ScpArgMsg('{set}ReallyExtractCabinetVibora', 'set', item_name)
		ui.MsgBox_NonNested(msg, "RUN_EXTRACT_VIBORA", yesScp, "None");
	end

	frame = frame:GetTopParentFrame();
	frame:ShowWindow(0);
end

function RUN_EXTRACT_VIBORA(itemGuid, arg_str)	
	local frame = ui.GetFrame("extract_vibora")
	local itemGuid = frame:GetUserValue("UseItemGuid")
	pc.ReqExecuteTx_Item("EXTRACT_CABINET_VIBORA", itemGuid, arg_str)
end

function CANCEL_EXTRACT_VIBORA(frame, ctrl, argStr, argNum)
	local box = frame:GetChild('box');
	tolua.cast(box, "ui::CGroupBox");

	local cnt = box:GetChildCount();
	for i = 0 , cnt - 1 do
		local ctrlSet = box:GetChildByIndex(i);
		local name = ctrlSet:GetName();
		if string.find(name, "REWARD_") ~= nil then
			tolua.cast(ctrlSet, "ui::CControlSet");
			ctrlSet:Deselect();
		end
	end
	control.DialogItemSelect(0);
	frame = frame:GetTopParentFrame();
	frame:ShowWindow(0);
end

------------------------------------------------------------------------------------------
-- item_ep12.xml, CT_ClientScp
function OPEN_EXTRACT_SELECT_CABINET_GODDESS(invItem)
	local zoneName = GetZoneName()
	local mapCls = GetClass('Map', zoneName)
	if mapCls == nil or TryGetProp(mapCls, 'MapType', 'None') ~= 'City' then
		ui.SysMsg(ClMsg('AllowedInTown1'))
		return
	end

	local frame = ui.GetFrame("extract_vibora")
	frame:SetTitleName('{@st43}{s22}' ..ScpArgMsg('OpenExtractCabinetGoddess'))
	local box = frame:GetChild('box');
	tolua.cast(box, "ui::CGroupBox");
	box:DeleteAllControl();
	local y = 5;

	local richtext_1 = GET_CHILD_RECURSIVELY(frame, 'richtext_1')
	if richtext_1 ~= nil then
		richtext_1:SetText(ClMsg('ExtractGoddessRichtext'))
	end

	local index = 1
	local acc = GetMyAccountObj()

	local clsList, cnt = GetClassList('cabinet_armor');
    for i = 0, cnt - 1 do
		local cls = GetClassByIndexFromList(clsList, i);
		if TryGetProp(cls, 'Upgrade', 0) == 1 then
			local prop = TryGetProp(cls, 'AccountProperty', 'None')			
			if TryGetProp(acc, prop, 0) ~= 0 then
				local upgrade_prop = TryGetProp(cls, 'UpgradeAccountProperty', 'None')
				local item_func_name = TryGetProp(cls, 'GetItemFunc', 'None')
				local get_item_func = _G[item_func_name]
				local item_name = get_item_func(cls, acc)
				y = CREATE_OPENED_GODDESS_ITEM_LIST(box, y, index, TryGetProp(cls, 'ClassID', 0), GetClass('Item', item_name));
				y = y + 5
				index = index + 1
			end
		end
	end

	if index == 1 then
		ui.SysMsg(ClMsg('CabinetAllClose'))
		return
	end

	local cancelBtn = frame:GetChild('CancelBtn');
	local useBtn = frame:GetChild('UseBtn');
	useBtn:SetEventScript(ui.LBUTTONUP,'REQUEST_EXTRACT_GODDESS')	

	box:Resize(box:GetOriginalWidth(), y);	    
	local screen_height = option.GetClientHeight();
	local maxSizeHeightFrame = box:GetY() + box:GetHeight() + 20;
	local maxSizeHeightWnd = ui.GetSceneHeight();
    
    if maxSizeHeightWnd >= 950 then        
        maxSizeHeightWnd = 950
    
        if maxSizeHeightWnd > screen_height then
            maxSizeHeightWnd = screen_height * 0.8
        end
    end
    
    if maxSizeHeightFrame >= maxSizeHeightWnd then
        maxSizeHeightFrame = maxSizeHeightWnd
    end
       
	if maxSizeHeightWnd < (maxSizeHeightFrame + 50) then                 
		local margin = maxSizeHeightWnd/2;
		box:EnableScrollBar(1);

		box:Resize(box:GetOriginalWidth(), margin - useBtn:GetHeight() - 40);
		box:SetScrollBar(0);
		box:InvalidateScrollBar();
		frame:Resize(frame:GetOriginalWidth(), margin + 100);
	else
		box:SetCurLine(0) -- scroll init
		
		box:Resize(box:GetOriginalWidth(), y);
		frame:Resize(frame:GetOriginalWidth(), maxSizeHeightFrame);
	end;
	box:SetScrollPos(0);
	local selectExist = 0;
	local cnt = box:GetChildCount();
	for i = 0 , cnt - 1 do
		local ctrlSet = box:GetChildByIndex(i);
		local name = ctrlSet:GetName();
		if string.find(name, "REWARD_") ~= nil then
			selectExist = 1;
		end 
	end

	local NeedItemSlot = frame:GetChild('NeedItemSlot')
	local NeedItemName = frame:GetChild('NeedItemName')
	NeedItemName:SetVisible(0)
	NeedItemSlot:SetVisible(0)

    local itemGuid = invItem:GetIESID();
	frame:SetUserValue("UseItemGuid", itemGuid);
	frame:ShowWindow(1);
end

-- type, cabinet_weapon.xml, ClassID
function CREATE_OPENED_GODDESS_ITEM_LIST(box, y, index, type, item_cls)
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
	
	local itemName = TryGetProp(item_cls, 'Name', 'None')
	local itemIcon = item_cls.Icon
	local ctrlSet = box:CreateControlSet('quest_reward_s', "REWARD_" .. index, x, y);
	tolua.cast(ctrlSet, "ui::CControlSet");
	
	ctrlSet:SetValue(type);
	ctrlSet:SetSValue(itemName)

	local slot = ctrlSet:GetChild("slot");
	tolua.cast(slot, "ui::CSlot");
	
	local icon = CreateIcon(slot)
	icon:SetImage(itemIcon)

	local itemText = ctrlSet:GetChild("ItemName");
	itemName = "{@st41b}".. itemName
	itemText:SetText(itemName);

	ctrlSet:SetTooltipType("wholeitem");
	ctrlSet:SetTooltipArg("", item_cls.ClassID, 0);	

	ctrlSet:SetOverSound("button_cursor_over_3");
	ctrlSet:SetClickSound("button_click_stats");
	ctrlSet:SetEnableSelect(1);
	ctrlSet:SetSelectGroupName("QuestRewardList");
	
	ctrlSet:Resize(box:GetWidth() - 30, ctrlSet:GetHeight());

	y = y + ctrlSet:GetHeight();
	return y;
end


function REQUEST_EXTRACT_GODDESS(frame, ctrl, argStr, argNum)    
	local box = frame:GetChild('box');
	tolua.cast(box, "ui::CGroupBox");

	local selectExist = 0;
	local selected = 0;
	local item_name = 'None'
	local cnt = box:GetChildCount();
	for i = 0 , cnt - 1 do
		local ctrlSet = box:GetChildByIndex(i);
		local name = ctrlSet:GetName();
		if string.find(name, "REWARD_") ~= nil then
			tolua.cast(ctrlSet, "ui::CControlSet");
			if ctrlSet:IsSelected() == 1 then
				selected = ctrlSet:GetValue();
				item_name = ctrlSet:GetSValue();
			end
			selectExist = 1;
		end
	end

	if selectExist == 1 and selected == 0 then
		ui.MsgBox(ScpArgMsg("Auto_BoSangeul_SeonTaegHaeJuSeyo."));
		return;
	end

	if selectExist == 1 then		
		local itemGuid = frame:GetUserValue("UseItemGuid")
		local arg_str = string.format('%d', selected)
		
		local yesScp = string.format("RUN_EXTRACT_GODDESS(%s, %s)", itemGuid, arg_str)
		local msg = ScpArgMsg('{set}ReallyExtractCabinetVibora', 'set', item_name)
		ui.MsgBox_NonNested(msg, "RUN_EXTRACT_GODDESS", yesScp, "None");
	end

	frame = frame:GetTopParentFrame();
	frame:ShowWindow(0);
end

function RUN_EXTRACT_GODDESS(itemGuid, arg_str)
	local frame = ui.GetFrame("extract_vibora")
	local itemGuid = frame:GetUserValue("UseItemGuid")
	pc.ReqExecuteTx_Item("EXTRACT_CABINET_GODDESS", itemGuid, arg_str)
end
