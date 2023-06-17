function OPEN_SELECT_VIBORA_ON_INIT(addon, frame)
end

-- type, cabinet_weapon.xml, ClassID
function CREATE_CLOSED_VIBORA_ITEM_LIST(box, y, index, type, item_cls, opened, item_lv)
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
	
	local prefix = ''
	if opened == 1 then
		prefix = '{#EE0000}'
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
	if opened == 0 then		
		icon:SetColorTone("AA666666")
	end

	local itemText = ctrlSet:GetChild("ItemName");
	itemName = "{@st41b}".. prefix .. itemName	
	itemText:SetText(itemName);

	ctrlSet:SetTooltipType("wholeitem");

	
	local tooltip_item_cls = nil
	local item_cls_name = TryGetProp(item_cls, 'ClassName', 'None')
	local trans = ''

	if string.find(item_cls_name, 'Lv3') ~= nil and item_lv > 3 then
		local _token = StringSplit(item_cls_name, '_Lv3');
		trans = _token[1] .. '_Lv' .. tostring(item_lv)
		tooltip_item_cls = GetClassByStrProp('Item', "ClassName", trans)
	elseif string.find(item_cls_name, 'Lv2') ~= nil and item_lv > 2 then
		local _token = StringSplit(item_cls_name, '_Lv2');
		trans = _token[1] .. '_Lv' .. tostring(item_lv)
		tooltip_item_cls = GetClassByStrProp('Item', "ClassName", trans)
	else
		trans = item_cls_name .. '_Lv' .. tostring(item_lv)
		tooltip_item_cls = GetClassByStrProp('Item', "ClassName", trans)
	end

	if tooltip_item_cls == nil then
		tooltip_item_cls = item_cls
	end

	ctrlSet:SetTooltipArg("", tooltip_item_cls.ClassID, 0);	

	ctrlSet:SetOverSound("button_cursor_over_3");
	ctrlSet:SetClickSound("button_click_stats");
	ctrlSet:SetEnableSelect(1);
	ctrlSet:SetSelectGroupName("QuestRewardList");
	
	ctrlSet:Resize(box:GetWidth() - 30, ctrlSet:GetHeight());

	y = y + ctrlSet:GetHeight();
	return y;

end

-- item_ep12.xml, CT_ClientScp
function OPEN_SELECT_CABINET_VIBORA(invItem)
	local zoneName = GetZoneName()
	local mapCls = GetClass('Map', zoneName)
	if mapCls == nil or TryGetProp(mapCls, 'MapType', 'None') ~= 'City' then
		ui.SysMsg(ClMsg('AllowedInTown1'))
		return
	end

	local item_obj = GetIES(invItem:GetObject())
	local frame = ui.GetFrame("open_select_vibora")
	frame:SetTitleName('{@st43}{s22}' ..ScpArgMsg('{lv}OpenSelectCabinetVibora', 'lv', TryGetProp(item_obj, 'NumberArg1', 1)))
	local box = frame:GetChild('box');
	tolua.cast(box, "ui::CGroupBox");
	box:DeleteAllControl();
	local y = 5;

	local richtext_1 = GET_CHILD_RECURSIVELY(frame, 'richtext_1')
	if richtext_1 ~= nil then
		richtext_1:SetText(ClMsg('OpenViboraRichtext'))
	end

	local index = 1
	local acc = GetMyAccountObj()
	local item_obj = GetIES(invItem:GetObject())
	local item_lv = TryGetProp(item_obj, 'NumberArg1', 0)

	local clsList, cnt = GetClassList('cabinet_weapon');
    for i = 0, cnt - 1 do
		local cls = GetClassByIndexFromList(clsList, i);
		if TryGetProp(cls, 'Upgrade', 0) == 1 then
			local prop = TryGetProp(cls, 'AccountProperty', 'None')			
			local upgrade_prop = TryGetProp(cls, 'UpgradeAccountProperty', 'None')			
			if TryGetProp(acc, prop, 0) == 0 or TryGetProp(acc, upgrade_prop, 0) < item_lv then				
				local item_func_name = TryGetProp(cls, 'GetItemFunc', 'None')
				local get_item_func = _G[item_func_name]
				local item_name = get_item_func(cls, acc)
				y = CREATE_CLOSED_VIBORA_ITEM_LIST(box, y, index, TryGetProp(cls, 'ClassID', 0), GetClass('Item', item_name), TryGetProp(acc, prop, 0), item_lv);
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
	useBtn:SetEventScript(ui.LBUTTONUP,'OPEN_CABINET_VIBORA')	

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

function OPEN_CABINET_VIBORA(frame, ctrl, argStr, argNum)    
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
		
		local cls = GetClassByType('cabinet_weapon', selected)
		local prop = TryGetProp(cls, 'AccountProperty', 'None')
		local upgrade_prop = TryGetProp(cls, 'UpgradeAccountProperty', 'None')

		local item_scroll = session.GetInvItemByGuid(itemGuid)
		if item_scroll == nil then			
			return
		else
			item_scroll = GetIES(item_scroll:GetObject())
		end
		
		if TryGetProp(GetMyAccountObj(), upgrade_prop, 0) >= TryGetProp(item_scroll, 'NumberArg1', 0) then
			ui.SysMsg(ClMsg("CantOpenCabinetArmor"))
		else
			local yesScp = string.format("RUN_OPEN_VIBORA(%s, %s)", itemGuid, arg_str)
			local msg = ScpArgMsg('{set}ReallyOpenCabinetVibora', 'set', item_name)
			ui.MsgBox_NonNested(msg, "RUN_OPEN_VIBORA", yesScp, "None");
		end
	end

	frame = frame:GetTopParentFrame();
	frame:ShowWindow(0);
end

function RUN_OPEN_VIBORA(itemGuid, arg_str)
	local frame = ui.GetFrame("open_select_vibora")
	local itemGuid = frame:GetUserValue("UseItemGuid")	

	local cls = GetClassByType('cabinet_weapon', arg_str)
	local prop = TryGetProp(cls, 'UpgradeAccountProperty', 'None')
	local item = session.GetInvItemByGuid(itemGuid)	
	local item_obj = GetIES(item:GetObject())	
	local ticket_lv = TryGetProp(item_obj, 'NumberArg1', 0)
	
	if TryGetProp(GetMyAccountObj(), prop, 0) >= ticket_lv then
		ui.MsgBox(ScpArgMsg("YouHaveSameLevelArcane"))		
		return
	end

	pc.ReqExecuteTx_Item("OPEN_CABINET_VIBORA", itemGuid, arg_str)
end

function CANCEL_SELECT_OPEN_VIBORA(frame, ctrl, argStr, argNum)
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


--------------------------------------------------------------------------------------------------------------
-- item_ep12.xml, CT_ClientScp
function OPEN_SELECT_CABINET_GODDESS(invItem)
	local zoneName = GetZoneName()
	local mapCls = GetClass('Map', zoneName)
	if mapCls == nil or TryGetProp(mapCls, 'MapType', 'None') ~= 'City' then
		ui.SysMsg(ClMsg('AllowedInTown1'))
		return
	end

	local item_obj = GetIES(invItem:GetObject())
	local frame = ui.GetFrame("open_select_vibora")
	frame:SetTitleName('{@st43}{s22}' ..ScpArgMsg('{lv}OpenSelectCabinetGoddess', 'lv', TryGetProp(item_obj, 'NumberArg1', 1)))
	local box = frame:GetChild('box');
	tolua.cast(box, "ui::CGroupBox");
	box:DeleteAllControl();
	local y = 5;

	local richtext_1 = GET_CHILD_RECURSIVELY(frame, 'richtext_1')
	if richtext_1 ~= nil then
		richtext_1:SetText(ClMsg('OpenGoddessRichtext'))
	end

	local index = 1
	local acc = GetMyAccountObj()
	local item_obj = GetIES(invItem:GetObject())
	local item_lv = TryGetProp(item_obj, 'NumberArg1', 0)

	local clsList, cnt = GetClassList('cabinet_armor');
    for i = 0, cnt - 1 do
		local cls = GetClassByIndexFromList(clsList, i);
		if TryGetProp(cls, 'Upgrade', 0) == 1 then
			local prop = TryGetProp(cls, 'AccountProperty', 'None')			
			local upgrade_prop = TryGetProp(cls, 'UpgradeAccountProperty', 'None')			
			if TryGetProp(acc, prop, 0) == 0 or TryGetProp(acc, upgrade_prop, 0) < item_lv then				
				local item_func_name = TryGetProp(cls, 'GetItemFunc', 'None')
				local get_item_func = _G[item_func_name]
				local item_name = get_item_func(cls, acc)
				y = CREATE_CLOSED_GODDESS_ITEM_LIST(box, y, index, TryGetProp(cls, 'ClassID', 0), GetClass('Item', item_name), TryGetProp(acc, prop, 0), item_lv);
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
	useBtn:SetEventScript(ui.LBUTTONUP,'OPEN_CABINET_GODDESS')	

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
function CREATE_CLOSED_GODDESS_ITEM_LIST(box, y, index, type, item_cls, opened, item_lv)
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
	
	local prefix = ''
	if opened == 1 then
		prefix = '{#EE0000}'
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
	if opened == 0 then		
		icon:SetColorTone("AA666666")
	end

	local itemText = ctrlSet:GetChild("ItemName");
	itemName = "{@st41b}".. prefix .. itemName	
	itemText:SetText(itemName);

	ctrlSet:SetTooltipType("wholeitem");

	
	local tooltip_item_cls = nil
	local item_cls_name = TryGetProp(item_cls, 'ClassName', 'None')
	local trans = ''

	if string.find(item_cls_name, 'Lv2') ~= nil and item_lv > 2 then
		local _token = StringSplit(item_cls_name, '_Lv2');
		trans = _token[1] .. '_Lv' .. tostring(item_lv)
		tooltip_item_cls = GetClassByStrProp('Item', "ClassName", trans)
	else
		trans = item_cls_name .. '_Lv' .. tostring(item_lv)
		tooltip_item_cls = GetClassByStrProp('Item', "ClassName", trans)
	end

	if tooltip_item_cls == nil then
		tooltip_item_cls = item_cls
	end

	ctrlSet:SetTooltipArg("", tooltip_item_cls.ClassID, 0);	

	ctrlSet:SetOverSound("button_cursor_over_3");
	ctrlSet:SetClickSound("button_click_stats");
	ctrlSet:SetEnableSelect(1);
	ctrlSet:SetSelectGroupName("QuestRewardList");
	
	ctrlSet:Resize(box:GetWidth() - 30, ctrlSet:GetHeight());

	y = y + ctrlSet:GetHeight();
	return y;

end

function OPEN_CABINET_GODDESS(frame, ctrl, argStr, argNum)    
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
		
		local cls = GetClassByType('cabinet_armor', selected)
		local prop = TryGetProp(cls, 'AccountProperty', 'None')

		local upgrade_prop = TryGetProp(cls, 'UpgradeAccountProperty', 'None')

		local item_scroll = session.GetInvItemByGuid(itemGuid)
		if item_scroll == nil then			
			return
		else
			item_scroll = GetIES(item_scroll:GetObject())
		end

		if TryGetProp(GetMyAccountObj(), upgrade_prop, 0) >= TryGetProp(item_scroll, 'NumberArg1', 0) then
			ui.SysMsg(ClMsg("CantOpenCabinetArmor"))
		else
			local yesScp = string.format("RUN_OPEN_GODDESS(%s, %s)", itemGuid, arg_str)
			local msg = ScpArgMsg('{set}ReallyOpenCabinetVibora', 'set', item_name)
			ui.MsgBox_NonNested(msg, "RUN_OPEN_GODDESS", yesScp, "None");
		end
	end

	frame = frame:GetTopParentFrame();
	frame:ShowWindow(0);
end

function RUN_OPEN_GODDESS(itemGuid, arg_str)	
	local frame = ui.GetFrame("open_select_vibora")
	local itemGuid = frame:GetUserValue("UseItemGuid")
	
	local cls = GetClassByType('cabinet_armor', arg_str)
	local prop = TryGetProp(cls, 'UpgradeAccountProperty', 'None')
	local item = session.GetInvItemByGuid(itemGuid)	
	local item_obj = GetIES(item:GetObject())	
	local ticket_lv = TryGetProp(item_obj, 'NumberArg1', 0)
	
	if TryGetProp(GetMyAccountObj(), prop, 0) >= ticket_lv then
		ui.MsgBox(ScpArgMsg("YouHaveSameLevelArcane"))	
		return
	end

	pc.ReqExecuteTx_Item("OPEN_CABINET_GODDESS", itemGuid, arg_str)
end