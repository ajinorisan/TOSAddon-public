function TRADESELECTITEM_4_ON_INIT(addon, frame)
end

function CREATE_CABINET_ITEM_LIST(box, y, index, type, item_cls)
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
	
	local itemName = ClMsg(type)
	local itemIcon = item_cls.Icon
	local ctrlSet = box:CreateControlSet('quest_reward_s', "REWARD_" .. index, x, y);
	tolua.cast(ctrlSet, "ui::CControlSet");
	
	ctrlSet:SetSValue(type);

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

function OPEN_TRADE_SELECT_CABINET_ARMOR(invItem)
	local zoneName = GetZoneName()
	local mapCls = GetClass('Map', zoneName)
	if mapCls == nil or TryGetProp(mapCls, 'MapType', 'None') ~= 'City' then
		ui.SysMsg(ClMsg('AllowedInTown1'))
		return
	end

	local frame = ui.GetFrame("tradeselectitem_4")
	frame:SetTitleName('{@st43}{s22}' ..ScpArgMsg('OpenCabinetArmor'))
	local box = frame:GetChild('box');
	tolua.cast(box, "ui::CGroupBox");
	box:DeleteAllControl();
	local y = 5;

	local list = GET_CABINET_ITEM_ARMOR_TYPE_LIST()
	local index = 1
	for k, type in pairs(list) do
		local name = GET_CABINET_ITEM_ARMOR_LIST(type)[1]
		local check = IS_VALID_CABINET_ITEM_ARMOR_OPEN(GetMyAccountObj(), type)		
		if check == 1 or check == 2 then
			y = CREATE_CABINET_ITEM_LIST(box, y, index, type, GetClass('Item', name));	
			y = y + 5
			index = index + 1
		end
	end
	
	if index == 1 then
		ui.SysMsg(ClMsg('CabinetAllOpen'))
		return
	end

	local cancelBtn = frame:GetChild('CancelBtn');
	local useBtn = frame:GetChild('UseBtn');
	useBtn:SetEventScript(ui.LBUTTONUP,'REQUEST_SELECT_CABINET_ARMOR')	

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

function REQUEST_SELECT_CABINET_ARMOR(frame, ctrl, argStr, argNum)    
	local box = frame:GetChild('box');
	tolua.cast(box, "ui::CGroupBox");

	local selectExist = 0;
	local selected = 'None';
	local cnt = box:GetChildCount();
	for i = 0 , cnt - 1 do
		local ctrlSet = box:GetChildByIndex(i);
		local name = ctrlSet:GetName();
		if string.find(name, "REWARD_") ~= nil then
			tolua.cast(ctrlSet, "ui::CControlSet");
			if ctrlSet:IsSelected() == 1 then
				selected = ctrlSet:GetSValue();
			end
			selectExist = 1;
		end
	end

	if selectExist == 1 and selected == 'None' then
		ui.MsgBox(ScpArgMsg("Auto_BoSangeul_SeonTaegHaeJuSeyo."));
		return;
	end

	if selectExist == 1 then		
		local itemGuid = frame:GetUserValue("UseItemGuid")
		local arg_str = string.format('%s', GET_CABINET_ARMOR_INDEX(selected))
		local check = IS_VALID_CABINET_ITEM_ARMOR_OPEN(GetMyAccountObj(), selected)		
		
		if check == 2 then
			local yesScp = string.format("RUN_OPENING_CABINET_ARMOR(%s, %s)", itemGuid, arg_str)
			local msg = ScpArgMsg('{set}ReallyOpenCabinetArmor', 'set', ClMsg(selected))
			ui.MsgBox_NonNested(msg, "RUN_OPENING_CABINET_ARMOR", yesScp, "None");
		elseif check == 1 then
			pc.ReqExecuteTx_Item("OPEN_CABINET_ARMOR", itemGuid, arg_str)		
		end
	end

	frame = frame:GetTopParentFrame();
	frame:ShowWindow(0);
end

function RUN_OPENING_CABINET_ARMOR(itemGuid, arg_str)
	pc.ReqExecuteTx_Item("OPEN_CABINET_ARMOR", itemGuid, arg_str)
end



function OPEN_TRADE_SELECT_CABINET_ACC(invItem)
	local zoneName = GetZoneName()
	local mapCls = GetClass('Map', zoneName)
	if mapCls == nil or TryGetProp(mapCls, 'MapType', 'None') ~= 'City' then
		ui.SysMsg(ClMsg('AllowedInTown1'))
		return
	end

	local frame = ui.GetFrame("tradeselectitem_4")
	frame:SetTitleName('{@st43}{s22}' ..ScpArgMsg('OpenCabinetAcc'))
	local box = frame:GetChild('box');
	tolua.cast(box, "ui::CGroupBox");
	box:DeleteAllControl();
	local y = 5;

	local list = GET_CABINET_ITEM_ACC_TYPE_LIST()
	local index = 1
	for k, type in pairs(list) do
		local name = GET_CABINET_ITEM_ACC_LIST(type)[1]
		if IS_VALID_CABINET_ITEM_ACC_OPEN(GetMyAccountObj(), type) == 1 then
			y = CREATE_CABINET_ITEM_LIST(box, y, index, type, GetClass('Item', name));	
			y = y + 5
			index = index + 1
		end
	end
	
	if index == 1 then
		ui.SysMsg(ClMsg('CabinetAllOpen'))
		return
	end

	local cancelBtn = frame:GetChild('CancelBtn');
	local useBtn = frame:GetChild('UseBtn');
	useBtn:SetEventScript(ui.LBUTTONUP,'REQUEST_SELECT_CABINET_ACC')	

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

function REQUEST_SELECT_CABINET_ACC(frame, ctrl, argStr, argNum)
	local box = frame:GetChild('box');
	tolua.cast(box, "ui::CGroupBox");

	local selectExist = 0;
	local selected = 'None';
	local cnt = box:GetChildCount();
	for i = 0 , cnt - 1 do
		local ctrlSet = box:GetChildByIndex(i);
		local name = ctrlSet:GetName();
		if string.find(name, "REWARD_") ~= nil then
			tolua.cast(ctrlSet, "ui::CControlSet");
			if ctrlSet:IsSelected() == 1 then
				selected = ctrlSet:GetSValue();
			end
			selectExist = 1;
		end
	end

	if selectExist == 1 and selected == 'None' then
		ui.MsgBox(ScpArgMsg("Auto_BoSangeul_SeonTaegHaeJuSeyo."));
		return;
	end

	if selectExist == 1 then		
		local itemGuid = frame:GetUserValue("UseItemGuid")		
		local arg_str = string.format('%d', GET_CABINET_ACC_INDEX(selected))		
		pc.ReqExecuteTx_Item("OPEN_CABINET_ACC", itemGuid, arg_str)		
	end

	frame = frame:GetTopParentFrame();
	frame:ShowWindow(0);
end

function OPEN_TRADE_SELECT_CABINET_ARK(invItem)
	local zoneName = GetZoneName()
	local mapCls = GetClass('Map', zoneName)
	if mapCls == nil or TryGetProp(mapCls, 'MapType', 'None') ~= 'City' then
		ui.SysMsg(ClMsg('AllowedInTown1'))
		return
	end

	local frame = ui.GetFrame("tradeselectitem_4")
	frame:SetTitleName('{@st43}{s22}' ..ScpArgMsg('OpenCabinetArk'))
	local box = frame:GetChild('box');
	tolua.cast(box, "ui::CGroupBox");
	box:DeleteAllControl();
	local y = 5;
	
	local list = GET_CABINET_ITEM_ARK_TYPE_LIST()
	local index = 1
	for k, type in pairs(list) do		
		local name = GET_CABINET_ITEM_ARK_LIST(type)
		if IS_VALID_CABINET_ITEM_ARK_OPEN(GetMyAccountObj(), type) == 1 then
			y = CREATE_CABINET_ITEM_LIST(box, y, index, type, GetClass('Item', name))
			y = y + 5
			index = index + 1
		end
	end
	
	if index == 1 then
		ui.SysMsg(ClMsg('CabinetAllOpen'))
		return
	end

	local cancelBtn = frame:GetChild('CancelBtn');
	local useBtn = frame:GetChild('UseBtn');
	useBtn:SetEventScript(ui.LBUTTONUP,'REQUEST_SELECT_CABINET_ARK')	

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

function REQUEST_SELECT_CABINET_ARK(frame, ctrl, argStr, argNum)
	local box = frame:GetChild('box');
	tolua.cast(box, "ui::CGroupBox");

	local selectExist = 0;
	local selected = 'None';
	local cnt = box:GetChildCount();
	for i = 0 , cnt - 1 do
		local ctrlSet = box:GetChildByIndex(i);
		local name = ctrlSet:GetName();
		if string.find(name, "REWARD_") ~= nil then
			tolua.cast(ctrlSet, "ui::CControlSet");
			if ctrlSet:IsSelected() == 1 then
				selected = ctrlSet:GetSValue();
			end
			selectExist = 1;
		end
	end

	if selectExist == 1 and selected == 'None' then
		ui.MsgBox(ScpArgMsg("Auto_BoSangeul_SeonTaegHaeJuSeyo."));
		return;
	end

	if selectExist == 1 then		
		local itemGuid = frame:GetUserValue("UseItemGuid")		
		local arg_str = string.format('%d', GET_CABINET_ARK_INDEX(selected))		
		pc.ReqExecuteTx_Item("OPEN_CABINET_ARK", itemGuid, arg_str)		
	end

	frame = frame:GetTopParentFrame();
	frame:ShowWindow(0);
end

function CANCEL_TRADE4_ITEM(frame, ctrl, argStr, argNum)
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


-- 카랄리엔 생성권
function CREATE_TRADE_SELECT_CABINET_ACC(invItem)
	local zoneName = GetZoneName()
	local mapCls = GetClass('Map', zoneName)
	if mapCls == nil or TryGetProp(mapCls, 'MapType', 'None') ~= 'City' then
		ui.SysMsg(ClMsg('AllowedInTown1'))
		return
	end

	local frame = ui.GetFrame("tradeselectitem_4")
	frame:SetTitleName('{@st43}{s22}' ..ScpArgMsg('CreateCabinetAcc'))
	local box = frame:GetChild('box');
	tolua.cast(box, "ui::CGroupBox");
	box:DeleteAllControl();
	local y = 5;
	local before_y = y
	local list = GET_CABINET_ITEM_ACC_TYPE_LIST()
	local index = 1
	for k, type in pairs(list) do
		local name = GET_CABINET_ITEM_ACC_LIST(type)[1]
		if IS_VALID_CREATE_CABINET_ITEM_ACC_OPEN(GetMyAccountObj(), type) == 1 then
			y = CREATE_CABINET_ITEM_LIST(box, y, index, type, GetClass('Item', name));	
			y = y + 5
			index = index + 1
		end
	end
	
	if before_y == y then
		ui.SysMsg(ClMsg('NotExistOpenedItem'))
		frame:ShowWindow(0)
		return
	end

	local cancelBtn = frame:GetChild('CancelBtn');
	local useBtn = frame:GetChild('UseBtn');
	useBtn:SetEventScript(ui.LBUTTONUP,'REQUEST_CREATE_CABINET_ACC')	

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

function REQUEST_CREATE_CABINET_ACC(frame, ctrl, argStr, argNum)
	local box = frame:GetChild('box');
	tolua.cast(box, "ui::CGroupBox");

	local selectExist = 0;
	local selected = 'None';
	local cnt = box:GetChildCount();
	for i = 0 , cnt - 1 do
		local ctrlSet = box:GetChildByIndex(i);
		local name = ctrlSet:GetName();
		if string.find(name, "REWARD_") ~= nil then
			tolua.cast(ctrlSet, "ui::CControlSet");
			if ctrlSet:IsSelected() == 1 then
				selected = ctrlSet:GetSValue();
			end
			selectExist = 1;
		end
	end

	if selectExist == 1 and selected == 'None' then
		ui.MsgBox(ScpArgMsg("Auto_BoSangeul_SeonTaegHaeJuSeyo."));
		return;
	end

	if selectExist == 1 then		
		local itemGuid = frame:GetUserValue("UseItemGuid")		
		local arg_str = string.format('%d', GET_CABINET_ACC_INDEX(selected))
		local selectItemName = ClMsg(selected)
		local warningYesNoMsg = 'SelectCabinetItem{ITEM}'
		local yesScp = string.format("REQUEST_CREATE_CABINET_ACC_WARNINGYES(\"%s\",\"%s\")", itemGuid, arg_str);
		ui.MsgBox(ScpArgMsg(warningYesNoMsg,'ITEM', selectItemName) , yesScp, 'None');	
	end

	frame = frame:GetTopParentFrame();
	frame:ShowWindow(0);
end

function REQUEST_CREATE_CABINET_ACC_WARNINGYES(itemGuid, arg_str) 
	pc.ReqExecuteTx_Item("CREATE_CABINET_ACC", itemGuid, arg_str)	
end

-- 루시페리 생성권
function CREATE_CABINET_ITEM_LIST2(box, y, index, type, item_cls, title)
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
	
	local itemName = ClMsg(title)
	local itemIcon = item_cls.Icon
	local ctrlSet = box:CreateControlSet('quest_reward_s', "REWARD_" .. index, x, y);
	tolua.cast(ctrlSet, "ui::CControlSet");
	
	ctrlSet:SetSValue(type);

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
function CREATE_TRADE_SELECT_CABINET_ACC2(invItem)	
	local zoneName = GetZoneName()
	local mapCls = GetClass('Map', zoneName)
	if mapCls == nil or TryGetProp(mapCls, 'MapType', 'None') ~= 'City' then
		ui.SysMsg(ClMsg('AllowedInTown1'))
		return
	end

	local frame = ui.GetFrame("tradeselectitem_4")
	frame:SetTitleName('{@st43}{s22}' ..ScpArgMsg('CreateCabinetAcc2'))
	local box = frame:GetChild('box');
	tolua.cast(box, "ui::CGroupBox");
	box:DeleteAllControl();
	local y = 5;
	local before_y = y
	local list = GET_CABINET_ITEM_ACC_TYPE_LIST()
	local index = 1
	for k, type in pairs(list) do
		local name = GET_CABINET_ITEM_ACC_LIST(type)[1]
		if IS_VALID_CREATE_CABINET_ITEM_ACC2_OPEN(GetMyAccountObj(), type) == 1 then
			local acc_cls = GetClass('cabinet_accessory', name)
			name = GET_UPGRADE_CABINET_ACC_ITEM_NAME(acc_cls, 2)
			y = CREATE_CABINET_ITEM_LIST2(box, y, index, type, GetClass('Item', name), type .. '_2')
			y = y + 5
			index = index + 1
		end
	end
	
	if before_y == y then
		ui.SysMsg(ClMsg('NotExistOpenedItem'))
		frame:ShowWindow(0)
		return
	end

	local cancelBtn = frame:GetChild('CancelBtn');
	local useBtn = frame:GetChild('UseBtn');
	useBtn:SetEventScript(ui.LBUTTONUP,'REQUEST_CREATE_CABINET_ACC2')	

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

function REQUEST_CREATE_CABINET_ACC2(frame, ctrl, argStr, argNum)
	local box = frame:GetChild('box');
	tolua.cast(box, "ui::CGroupBox");

	local selectExist = 0;
	local selected = 'None';
	local cnt = box:GetChildCount();
	for i = 0 , cnt - 1 do
		local ctrlSet = box:GetChildByIndex(i);
		local name = ctrlSet:GetName();
		if string.find(name, "REWARD_") ~= nil then
			tolua.cast(ctrlSet, "ui::CControlSet");
			if ctrlSet:IsSelected() == 1 then
				selected = ctrlSet:GetSValue();
			end
			selectExist = 1;
		end
	end

	if selectExist == 1 and selected == 'None' then
		ui.MsgBox(ScpArgMsg("Auto_BoSangeul_SeonTaegHaeJuSeyo."));
		return;
	end

	if selectExist == 1 then		
		local itemGuid = frame:GetUserValue("UseItemGuid")		
		local arg_str = string.format('%d', GET_CABINET_ACC_INDEX(selected))
		local selectItemName = ClMsg(selected .. "_2")
		local warningYesNoMsg = 'SelectCabinetItem{ITEM}'
		local yesScp = string.format("REQUEST_CREATE_CABINET_ACC2_WARNINGYES(\"%s\",\"%s\")", itemGuid, arg_str);
		ui.MsgBox(ScpArgMsg(warningYesNoMsg,'ITEM', selectItemName) , yesScp, 'None');	
	end

	frame = frame:GetTopParentFrame();
	frame:ShowWindow(0);
end

function REQUEST_CREATE_CABINET_ACC2_WARNINGYES(itemGuid, arg_str) 	
	pc.ReqExecuteTx_Item("CREATE_CABINET_ACC2", itemGuid, arg_str)		
end

function OPEN_TRADE_SELECT_CABINET_LUCI_ACC(invItem)
	local zoneName = GetZoneName()
	local mapCls = GetClass('Map', zoneName)
	if mapCls == nil or TryGetProp(mapCls, 'MapType', 'None') ~= 'City' then
		ui.SysMsg(ClMsg('AllowedInTown1'))
		return
	end

	local frame = ui.GetFrame("tradeselectitem_4")
	frame:SetTitleName('{@st43}{s22}' ..ScpArgMsg('OpenCabinetAcc'))
	local box = frame:GetChild('box');
	tolua.cast(box, "ui::CGroupBox");
	box:DeleteAllControl();
	local y = 5;

	local list = GET_CABINET_ITEM_ACC_TYPE_LIST()
	local index = 1
	for k, type in pairs(list) do
		local name = GET_CABINET_ITEM_LUCI_ACC_LIST(type)[1]
		if IS_VALID_CABINET_ITEM_LUCI_ACC_OPEN(GetMyAccountObj(), type) == 1 then
			y = CREATE_CABINET_ITEM_LIST(box, y, index, type..'_2', GetClass('Item', name));	
			y = y + 5
			index = index + 1
		end
	end
	
	if index == 1 then
		ui.SysMsg(ClMsg('CabinetAllOpen'))
		return
	end

	local cancelBtn = frame:GetChild('CancelBtn');
	local useBtn = frame:GetChild('UseBtn');
	useBtn:SetEventScript(ui.LBUTTONUP,'REQUEST_SELECT_CABINET_LUCI_ACC')	

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

function REQUEST_SELECT_CABINET_LUCI_ACC(frame, ctrl, argStr, argNum)
	local box = frame:GetChild('box');
	tolua.cast(box, "ui::CGroupBox");

	local selectExist = 0;
	local selected = 'None';
	local cnt = box:GetChildCount();
	for i = 0 , cnt - 1 do
		local ctrlSet = box:GetChildByIndex(i);
		local name = ctrlSet:GetName();
		if string.find(name, "REWARD_") ~= nil then
			tolua.cast(ctrlSet, "ui::CControlSet");
			if ctrlSet:IsSelected() == 1 then
				selected = ctrlSet:GetSValue();
			end
			selectExist = 1;
		end
	end

	if selectExist == 1 and selected == 'None' then
		ui.MsgBox(ScpArgMsg("Auto_BoSangeul_SeonTaegHaeJuSeyo."));
		return;
	end

	if selectExist == 1 then		
		local itemGuid = frame:GetUserValue("UseItemGuid")		
		local arg_str = string.format('%d', GET_CABINET_LUCI_ACC_INDEX(selected))		
		pc.ReqExecuteTx_Item("OPEN_CABINET_ACC", itemGuid, arg_str)		
	end

	frame = frame:GetTopParentFrame();
	frame:ShowWindow(0);
end