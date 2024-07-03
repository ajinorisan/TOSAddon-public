function TRADESELECTITEM_ON_INIT(addon, frame)
end

function OPEN_TRADE_SELECT_ITEM(invItem)
    local itemobj = GetIES(invItem:GetObject());
    if itemobj.ItemLifeTimeOver == 1 then
		ui.SysMsg(ScpArgMsg('LessThanItemLifeTime'));
		return
	end
	local frame = ui.GetFrame("tradeselectitem")
	local itemobj = GetIES(invItem:GetObject());
	local itemGuid = invItem:GetIESID();

	local box = frame:GetChild('box');
	tolua.cast(box, "ui::CGroupBox");
	box:DeleteAllControl();
	local y = 5;
	local cls = GetClass("TradeSelectItem", itemobj.ClassName)
	frame:SetTitleName("{@st43}{s22}"..ClMsg(cls.TitleClientMsg))    
	frame:SetUserValue("UseItemGuid", itemGuid);
	local index = 1;

	while 1 do
		local itemIndex = TryGetProp(cls, "SelectItemName_"..index)
		if itemIndex ~= nil then
			index = index + 1;
		else
			break;
		end
	end

	for i = 1, index do
		local itemName = TryGetProp(cls, "SelectItemName_"..i);
		local itemCount = TryGetProp(cls, "SelectItemCount_"..i);
		if itemName ~= 'None' and itemName ~= nil and itemCount ~= 0 and itemCount ~= nil then
			y = CREATE_QUEST_REWARE_CTRL(box, y, i, itemName, itemCount, nil, itemobj.ClassName);	
			y = y + 5
		end
	end
	
	frame:SetUserValue("TradeSelectItem", itemobj.ClassName);

	local cancelBtn = frame:GetChild('CancelBtn');
	cancelBtn:SetVisible(1);
	local useBtn = frame:GetChild('UseBtn');
	useBtn:SetEventScript(ui.LBUTTONUP,'REQUEST_TRADE_ITEM')
	local useBtnMargin = useBtn:GetMargin();
	local xmargin = frame:GetUserConfig("USE_BTN_X_MARGIN");
	useBtn:SetMargin(tonumber(xmargin), 0, 0, useBtnMargin.bottom);

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
	frame:ShowWindow(1);
end


function OPEN_TRADE_SELECT_ITEM_DIFF_COUNT(invItem)
    local itemobj = GetIES(invItem:GetObject());
    if itemobj.ItemLifeTimeOver == 1 then
		ui.SysMsg(ScpArgMsg('LessThanItemLifeTime'));
		return
	end
	local frame = ui.GetFrame("tradeselectitem")
	local itemobj = GetIES(invItem:GetObject());
	local itemGuid = invItem:GetIESID();

	local box = frame:GetChild('box');
	tolua.cast(box, "ui::CGroupBox");
	box:DeleteAllControl();
	local y = 5;
	local cls = GetClass("TradeSelectItem", itemobj.ClassName)
	frame:SetTitleName("{@st43}{s22}"..ClMsg(cls.TitleClientMsg))    
	frame:SetUserValue("UseItemGuid", itemGuid);
	local index = 1;

	while 1 do
		local itemIndex = TryGetProp(cls, "SelectItemName_"..index)
		if itemIndex ~= nil then
			index = index + 1;
		else
			break;
		end
	end

	for i = 1, index do
		local itemName = TryGetProp(cls, "SelectItemName_"..i);
		local itemCount = TryGetProp(cls, "SelectItemCount_"..i);
		local NeedItemCount = TryGetProp(cls, "NeedItemCount_"..i);

		if itemName ~= 'None' and itemName ~= nil and itemCount ~= 0 and itemCount ~= nil then
			y = CREATE_QUEST_REWARE_CTRL_DIFF_COUNT(box, y, i, itemName, itemCount, NeedItemCount, nil, itemobj.ClassName);	
			y = y + 5
		end
	end
	
	frame:SetUserValue("TradeSelectItem", itemobj.ClassName);

	local cancelBtn = frame:GetChild('CancelBtn');
	cancelBtn:SetVisible(1);
	local useBtn = frame:GetChild('UseBtn');	
	useBtn:SetEventScript(ui.LBUTTONUP,'REQUEST_TRADE_ITEM_DIFF_COUNT')
	local useBtnMargin = useBtn:GetMargin();
	local xmargin = frame:GetUserConfig("USE_BTN_X_MARGIN");
	useBtn:SetMargin(tonumber(xmargin), 0, 0, useBtnMargin.bottom);

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
	frame:ShowWindow(1);
end


function OPEN_TRADE_ANCIENT_CARD_ITEM(frame, msg, strArg, numArg)
end

function OPEN_TRADE_SELECT_MUTIPLE_ITEM(targetItemNameList, targetItemCostList,targetItemName, rewareItemName)
	local frame = ui.GetFrame("tradeselectitem")
	local useItemCls = GetClass("Item","EVENT_190919_ANCIENT_SCROLL")
	frame:SetTitleName("{@st43}{s22}"..useItemCls.Name)

	local y = 5;
	local box = frame:GetChild('box');
	tolua.cast(box, "ui::CGroupBox");
	box:DeleteAllControl();
	local boxMargin = box:GetMargin()
	box:SetMargin(boxMargin.left,43,boxMargin.right,boxMargin.bottom)
	for i = 1, #targetItemNameList do
		--y = CREATE_ANCIENT_CARD_CTRL(box, y, i, rewareItemName, 1,targetItemName, targetItemNameList[i], targetItemCostList[i]);	
		--y = y + 5
	end

	local cancelBtn = frame:GetChild('CancelBtn');
	cancelBtn:SetVisible(0)
	local useBtn = frame:GetChild('UseBtn');
	useBtn:SetEventScript(ui.LBUTTONUP,'REQUEST_TRADE_ANCIENT_CARD')
	local useBtnMargin = useBtn:GetMargin();
	useBtn:SetMargin(0,0,0,useBtnMargin.bottom)
	box:Resize(box:GetOriginalWidth(), y);

	local screen_height = option.GetClientHeight();
	local maxSizeHeightFrame = box:GetY() + box:GetHeight() + 30;
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
	
	NeedItemName:SetVisible(1)
	NeedItemSlot:SetVisible(1)
	
	tolua.cast(NeedItemSlot, "ui::CSlot");
	local NeedItemCls = GetClass("Item", targetItemName);
	local NeedIcon = GET_ITEM_ICON_IMAGE(NeedItemCls, GETMYPCGENDER())
	SET_SLOT_IMG(NeedItemSlot, NeedIcon);

	local targetItem = session.GetInvItemByName(targetItemName);
	frame:SetUserValue("NEED_ITEM",targetItemName)
	local targetItemCnt = 0;
	if targetItem ~= nil then
		targetItemCnt = targetItem.count;
	end
	NeedItemName:SetTextByKey('total', targetItemCnt);
    NeedItemName:SetTextByKey('select', 0);
	
	frame:ShowWindow(1);
end

function REQUEST_TRADE_ITEM(frame, ctrl, argStr, argNum)
	local box = frame:GetChild('box');
	tolua.cast(box, "ui::CGroupBox");

	local selectExist = 0;
	local selected = 0;
	local cnt = box:GetChildCount();
	for i = 0 , cnt - 1 do
		local ctrlSet = box:GetChildByIndex(i);
		local name = ctrlSet:GetName();
		if string.find(name, "REWARD_") ~= nil then
			tolua.cast(ctrlSet, "ui::CControlSet");
			if ctrlSet:IsSelected() == 1 then
				selected = ctrlSet:GetValue();
			end
			selectExist = 1;
		end
	end

	if selectExist == 1 and selected == 0 then
		ui.MsgBox(ScpArgMsg("Auto_BoSangeul_SeonTaegHaeJuSeyo."));
		return;
	end

	if selectExist == 1 then
		local itemGuid = frame:GetUserValue("UseItemGuid");
		local argStr = string.format("%s#%d", itemGuid, selected);
		
        local tradeSelectItem = frame:GetUserValue("TradeSelectItem");
        local cls = GetClass("TradeSelectItem", tradeSelectItem)
		local warningYesNoMsg = TryGetProp(cls, 'WarningYesNoMsg')
        if warningYesNoMsg ~= nil and warningYesNoMsg ~= '' and warningYesNoMsg ~= 'None' then
            local selectItemName = GetClass('Item', TryGetProp(cls, 'SelectItemName_'..selected)).Name
            local yesScp = string.format("REQUEST_TRADE_ITEM_WARNINGYES(\"%s\")",argStr);
        	ui.MsgBox(ScpArgMsg(warningYesNoMsg,'ITEM', selectItemName) , yesScp, 'None');
        else
    		pc.ReqExecuteTx("SCR_TX_TRADE_SELECT_ITEM", argStr);
    	end
	end

	frame = frame:GetTopParentFrame();
	frame:ShowWindow(0);
end

function OPEN_TRADE_SELECT_ITEM_RANDOM_OPTION(invItem)
    local itemobj = GetIES(invItem:GetObject());
    if itemobj.ItemLifeTimeOver == 1 then
		ui.SysMsg(ScpArgMsg('LessThanItemLifeTime'));
		return
	end
	
	local frame = ui.GetFrame("tradeselectitem")
	local itemobj = GetIES(invItem:GetObject());
	local itemGuid = invItem:GetIESID();

	local box = frame:GetChild('box');
	tolua.cast(box, "ui::CGroupBox");
	box:DeleteAllControl();
	local y = 5;
	local cls = GetClass("TradeSelectItem", itemobj.ClassName)
	frame:SetTitleName("{@st43}{s22}"..ClMsg(cls.TitleClientMsg))    
	frame:SetUserValue("UseItemGuid", itemGuid);
	local index = 1;

	while 1 do
		local itemIndex = TryGetProp(cls, "SelectItemName_"..index)
		if itemIndex ~= nil then
			index = index + 1;
		else
			break;
		end
	end

	for i = 1, index do
		local itemName = TryGetProp(cls, "SelectItemName_"..i);
		local itemCount = TryGetProp(cls, "SelectItemCount_"..i);
		if itemName ~= 'None' and itemName ~= nil and itemCount ~= 0 and itemCount ~= nil then
			y = CREATE_QUEST_REWARE_CTRL(box, y, i, itemName, itemCount, nil, itemobj.ClassName);	
			y = y + 5
		end
	end
	
	frame:SetUserValue("TradeSelectItem", itemobj.ClassName);

	local cancelBtn = frame:GetChild('CancelBtn');
	cancelBtn:SetVisible(1);
	local useBtn = frame:GetChild('UseBtn');	
	useBtn:SetEventScript(ui.LBUTTONUP,'REQUEST_TRADE_ITEM_RANDOM_OPT')
	local useBtnMargin = useBtn:GetMargin();
	local xmargin = frame:GetUserConfig("USE_BTN_X_MARGIN");
	useBtn:SetMargin(tonumber(xmargin), 0, 0, useBtnMargin.bottom);

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
	frame:ShowWindow(1);
end

function REQUEST_TRADE_ITEM_RANDOM_OPT(frame, ctrl, argStr, argNum)
	local box = frame:GetChild('box');
	tolua.cast(box, "ui::CGroupBox");

	local selectExist = 0;
	local selected = 0;
	local cnt = box:GetChildCount();
	for i = 0 , cnt - 1 do
		local ctrlSet = box:GetChildByIndex(i);
		local name = ctrlSet:GetName();
		if string.find(name, "REWARD_") ~= nil then
			tolua.cast(ctrlSet, "ui::CControlSet");
			if ctrlSet:IsSelected() == 1 then
				selected = ctrlSet:GetValue();
			end
			selectExist = 1;
		end
	end

	if selectExist == 1 and selected == 0 then
		ui.MsgBox(ScpArgMsg("Auto_BoSangeul_SeonTaegHaeJuSeyo."));
		return;
	end

	if selectExist == 1 then
		local itemGuid = frame:GetUserValue("UseItemGuid");
		local argStr = string.format("%s#%d", itemGuid, selected);
        local tradeSelectItem = frame:GetUserValue("TradeSelectItem");
        local cls = GetClass("TradeSelectItem", tradeSelectItem)
		local warningYesNoMsg = TryGetProp(cls, 'WarningYesNoMsg')
        if warningYesNoMsg ~= nil and warningYesNoMsg ~= '' and warningYesNoMsg ~= 'None' then
            local selectItemName = GetClass('Item', TryGetProp(cls, 'SelectItemName_'..selected)).Name
            local yesScp = string.format('REQUEST_RANOPT_WARNING(\'%s\')', argStr);
        	ui.MsgBox(ScpArgMsg(warningYesNoMsg,'ITEM', selectItemName) , yesScp, 'None');
        else
    		pc.ReqExecuteTx("SCR_TX_TRADE_SELECT_ITEM_RANOPT", argStr);
    	end
	end

	frame = frame:GetTopParentFrame();
	frame:ShowWindow(0);
end

function REQUEST_RANOPT_WARNING(argStr)
    pc.ReqExecuteTx("SCR_TX_TRADE_SELECT_ITEM_RANOPT", argStr);
end

function REQUEST_TRADE_ITEM_DIFF_COUNT(frame, ctrl, argStr, argNum)
	local box = frame:GetChild('box');
	tolua.cast(box, "ui::CGroupBox");

	local selectExist = 0;
	local selected = 0;
	local cnt = box:GetChildCount();
	for i = 0 , cnt - 1 do
		local ctrlSet = box:GetChildByIndex(i);
		local name = ctrlSet:GetName();
		if string.find(name, "REWARD_") ~= nil then
			tolua.cast(ctrlSet, "ui::CControlSet");
			if ctrlSet:IsSelected() == 1 then
				selected = ctrlSet:GetValue();
			end
			selectExist = 1;
		end
	end

	if selectExist == 1 and selected == 0 then
		ui.MsgBox(ScpArgMsg("Auto_BoSangeul_SeonTaegHaeJuSeyo."));
		return;
	end

	if selectExist == 1 then
		local itemGuid = frame:GetUserValue("UseItemGuid");
		local argStr = string.format("%s#%d", itemGuid, selected);
		
        local tradeSelectItem = frame:GetUserValue("TradeSelectItem");
        local cls = GetClass("TradeSelectItem", tradeSelectItem)
		local warningYesNoMsg = TryGetProp(cls, 'WarningYesNoMsg')
        if warningYesNoMsg ~= nil and warningYesNoMsg ~= '' and warningYesNoMsg ~= 'None' then
            local selectItemName = GetClass('Item', TryGetProp(cls, 'SelectItemName_'..selected)).Name
            local yesScp = string.format("REQUEST_TRADE_ITEM_WARNINGYES(\"%s\")",argStr);
        	ui.MsgBox(ScpArgMsg(warningYesNoMsg,'ITEM', selectItemName) , yesScp, 'None');
        else
    		pc.ReqExecuteTx("SCR_TX_TRADE_SELECT_ITEM_2", argStr);
    	end
	end

	frame = frame:GetTopParentFrame();
	frame:ShowWindow(0);
end


function SCR_GET_ANCIENT_CARD_TOTAL_COST(frame, ctrl, argStr, argNum)
	frame = frame:GetTopParentFrame()
	local box = frame:GetChild('box');
	tolua.cast(box, "ui::CGroupBox");

	local totalCost = 0;
	local cnt = box:GetChildCount();
	for i = 0 , cnt - 1 do
		local ctrlSet = box:GetChildByIndex(i);
		local name = ctrlSet:GetName();
		if string.find(name, "REWARD_") ~= nil then
			tolua.cast(ctrlSet, "ui::CControlSet");
			if ctrlSet:IsSelected() == 1 then
				local classID = ctrlSet:GetValue();
				totalCost = totalCost + ctrlSet:GetUserValue("Cost");
			end
		end
	end
	local NeedItemName = GET_CHILD_RECURSIVELY(frame,'NeedItemName')
	frame:SetUserValue("COST",totalCost)
	NeedItemName:SetTextByKey('select', totalCost);
end

function REQUEST_TRADE_ANCIENT_CARD(frame, ctrl, argStr, argNum)
	local box = frame:GetChild('box');
	tolua.cast(box, "ui::CGroupBox");

	local selectExist = 0;
	local selected = "";
	local monClassIDList = frame:GetUserValue("ANCIENT_CARD_LIST")
	monClassIDList = StringSplit(monClassIDList,';')
	local cnt = box:GetChildCount();
	for i = 0 , cnt - 1 do
		local ctrlSet = box:GetChildByIndex(i);
		local name = ctrlSet:GetName();
		if string.find(name, "REWARD_") ~= nil then
			tolua.cast(ctrlSet, "ui::CControlSet");
			if ctrlSet:IsSelected() == 1 then
				if selected ~= "" then
					selected = selected .. ' ';
				end
				selected = selected .. monClassIDList[ctrlSet:GetValue()]
			end
			selectExist = 1;
		end
	end

	local totalCost = tonumber(frame:GetUserValue("COST"))
	local targetItemName = frame:GetUserValue("NEED_ITEM")
	local targetItem = session.GetInvItemByName(targetItemName);
	local itemCount = 0
	if targetItem ~= nil then
		itemCount = targetItem.count
	end
	if totalCost > itemCount then
		addon.BroadMsg("NOTICE_Dm_scroll", ClMsg("NoEnoguhtItemCantOpenCube"), 3);
		return;
	end
	local iesID = frame:GetUserValue("IES_ID")
	if selected == '' then
		local str = ScpArgMsg("AncientScrollSelect")
		local yesScp = string.format("ANCIENT_SCROLL_EMPTY_USE(\"%s\")", iesID);
		ui.MsgBox(str, yesScp, "None");
		return;
	end
	if selectExist == 1 then
		pc.ReqExecuteTx_Item("SCR_TRADE_SELECT_ANCIENT_CARD", iesID,selected);
	end

	frame = frame:GetTopParentFrame();
	frame:ShowWindow(0);
end

function REQUEST_TRADE_ITEM_WARNINGYES(argStr)
    pc.ReqExecuteTx("SCR_TX_TRADE_SELECT_ITEM", argStr);
end

function CANCEL_TRADE_ITEM(frame, ctrl, argStr, argNum)
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

-- JOB ?�택
function OPEN_TRADE_SELECT_JOB(invItem)
	local frame = ui.GetFrame("tradeselectitem")
	frame:SetTitleName('{@st43}{s22}' ..ScpArgMsg('SkillPointPotion'))
	local box = frame:GetChild('box');
	tolua.cast(box, "ui::CGroupBox");
	box:DeleteAllControl();
	local y = 5;

	local jobList = GetMyJobList()

	local lv = TryGetProp(GetMyPCObject(), 'Lv', 1)
	-- 440 ?�벨 ?�상 ?�용 가??--
    if lv < 440 then
		ui.SysMsg(ScpArgMsg('CannotBecauseBaseLevel'));        
        return;
    end

	if #jobList < 4 then
        ui.SysMsg(ScpArgMsg('CannotBecauseLessJobSequence'));
        return
    end

    if GetJobLv(GetMyPCObject()) < 45 then
        ui.SysMsg(ScpArgMsg('CannotChangeJobBecauseJobLevel'));        
        return;
    end

	for i = 1,#jobList do
		local jobCls = GetClassByType("Job",jobList[i])
		if jobCls ~= nil then
			local jobName = jobCls.Name
			y = CREATE_QUEST_REWARE_CTRL_JOB(box, y, i, jobCls);	
			y = y + 5
		end
	end

	local cancelBtn = frame:GetChild('CancelBtn');
	local useBtn = frame:GetChild('UseBtn');
	useBtn:SetEventScript(ui.LBUTTONUP,'REQUEST_TRADE_JOB')

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

function CREATE_QUEST_REWARE_CTRL_JOB(box, y, index, jobCls)
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
	local jobName = jobCls.Name
	local jobIcon = jobCls.Icon
	local ctrlSet = box:CreateControlSet('quest_reward_s', "REWARD_" .. index, x, y);
	tolua.cast(ctrlSet, "ui::CControlSet");
	--?�기 값을 ?�중??받아??처리!!
	ctrlSet:SetValue(jobCls.ClassID);
	
	local slot = ctrlSet:GetChild("slot");
	tolua.cast(slot, "ui::CSlot");
	
	local icon = CreateIcon(slot)
	icon:SetImage(jobIcon)

	local jobText = ctrlSet:GetChild("ItemName");
	jobName = "{@st41b}"..jobName
	jobText:SetText(jobName);
	ctrlSet:SetOverSound("button_cursor_over_3");
	ctrlSet:SetClickSound("button_click_stats");
	ctrlSet:SetEnableSelect(1);
	ctrlSet:SetSelectGroupName("QuestRewardList");
	
	ctrlSet:Resize(box:GetWidth() - 30, ctrlSet:GetHeight());

	y = y + ctrlSet:GetHeight();
	return y;

end

function REQUEST_TRADE_JOB(frame, ctrl, argStr, argNum)    
	local box = frame:GetChild('box');
	tolua.cast(box, "ui::CGroupBox");

	local selectExist = 0;
	local selected = 0;
	local cnt = box:GetChildCount();
	for i = 0 , cnt - 1 do
		local ctrlSet = box:GetChildByIndex(i);
		local name = ctrlSet:GetName();
		if string.find(name, "REWARD_") ~= nil then
			tolua.cast(ctrlSet, "ui::CControlSet");
			if ctrlSet:IsSelected() == 1 then
				selected = ctrlSet:GetValue();
			end
			selectExist = 1;
		end
	end

	if selectExist == 1 and selected == 0 then
		ui.MsgBox(ScpArgMsg("Auto_BoSangeul_SeonTaegHaeJuSeyo."));
		return;
	end

	if selectExist == 1 then
		--?�택??ClassID		
		local itemGuid = frame:GetUserValue("UseItemGuid");
		local argStr = string.format("%s", selected);
        pc.ReqExecuteTx_Item("SCR_USE_ADD_SKILL_POINT", itemGuid, argStr);
	end

	frame = frame:GetTopParentFrame();
	frame:ShowWindow(0);
end

function TEST_JOB_SELECT_UI(self)
	ExecClientScp(self,"OPEN_TRADE_SELECT_JOB()")
end








local function SORT_BY_JOBNAME(a, b)
	local data1 = TryGetProp(a, "JobName");
	local data2 = TryGetProp(b, "JobName");
	
	local mySession = session.GetMySession();
	local jobhistory = mySession:GetPCJobInfo();
	local priorityA = 0
	local priorityB = 0
	

	for i = 0, jobhistory:GetJobCount()-1 do
		local tempjobinfo = jobhistory:GetJobInfoByIndex(i);
		local jobName = GetClassByType("Job", tempjobinfo.jobID).JobName

		if data1 == jobName then
			priorityA = priorityA + 3
		end

		if data2 == jobName then
			priorityB = priorityB + 3
		end
	end
	
	if data1 == "All" or data1 == "NOJOB" then
		priorityA = priorityA + 2
	end

	if data2 == "All" or data2 == "NOJOB" then
		priorityB = priorityB + 2
	end

	if priorityA == priorityB then
		local clsIdA = TryGetProp(a, "ClassID");
		local clsIdB = TryGetProp(b, "ClassID");
		return clsIdA < clsIdB;
	else
		return priorityA > priorityB
	end
end

function IS_PC_JOB(JobName)
	local mySession = session.GetMySession();
	local jobhistory = mySession:GetPCJobInfo();
	local isPcJob = false
	for i = 0, jobhistory:GetJobCount()-1 do
		local tempjobinfo = jobhistory:GetJobInfoByIndex(i);
		local pcJob = GetClassByType("Job", tempjobinfo.jobID).JobName
		if pcJob == JobName or "All" == JobName or "NOJOB" == JobName then
			isPcJob = true
			break
		end
	end
	return isPcJob
end

function OPEN_TRADE_SELECT_VIBORA(invItem)
    local itemobj = GetIES(invItem:GetObject());
    if itemobj.ItemLifeTimeOver == 1 then
		ui.SysMsg(ScpArgMsg('LessThanItemLifeTime'));
		return
	end
	local frame = ui.GetFrame("tradeselectitem")
	local itemobj = GetIES(invItem:GetObject());
	local itemGuid = invItem:GetIESID();

	local box = frame:GetChild('box');
	tolua.cast(box, "ui::CGroupBox");
	box:DeleteAllControl();
	local y = 5;
	
	frame:SetTitleName("{@st43}{s22}"..ClMsg('Event_Nru2_Guide_2'))
	frame:SetUserValue("UseItemGuid", itemGuid);

	local xmlList, xmlCount = GetClassList("EliteEquipDrop")
	local equipDropList = {}
	for i = 0, xmlCount -1 do
		table.insert(equipDropList, GetClassByIndexFromList(xmlList, i))
	end
	table.sort(equipDropList, SORT_BY_JOBNAME)
	for i = 0, #equipDropList do
		local itemName = TryGetProp(equipDropList[i], "ClassName", 'None')
		local dropable = TryGetProp(equipDropList[i], "Dropable", 'NO')
		if dropable == 'YES' and itemName ~= 'None' and itemName ~= nil then
			y = CREATE_VIBORA_SELECT_CTRL(box, y, i, itemName, 1, nil, itemobj.ClassName)
			y = y + 5
		end
	end

	frame:SetUserValue("TradeSelectItem", itemobj.ClassName)

	local cancelBtn = frame:GetChild('CancelBtn')
	cancelBtn:SetVisible(1);
	local useBtn = frame:GetChild('UseBtn');	
	useBtn:SetEventScript(ui.LBUTTONUP,'REQUEST_TRADE_VIBORA')
	local useBtnMargin = useBtn:GetMargin();
	local xmargin = frame:GetUserConfig("USE_BTN_X_MARGIN");
	useBtn:SetMargin(tonumber(xmargin), 0, 0, useBtnMargin.bottom);

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
	frame:ShowWindow(1);
end


function REQUEST_TRADE_VIBORA(frame, ctrl, argStr, argNum)
	local box = frame:GetChild('box');
	tolua.cast(box, "ui::CGroupBox");

	local selectExist = 0;
	local selected = 0;
	local cnt = box:GetChildCount();
	for i = 0 , cnt -1  do
		local ctrlSet = box:GetChildByIndex(i);
		local name = ctrlSet:GetName();
		if string.find(name, "REWARD_") ~= nil then
			tolua.cast(ctrlSet, "ui::CControlSet");
			if ctrlSet:IsSelected() == 1 then
				local itemName = ctrlSet:GetUserValue("ITEM_NAME")
				local viboraCls = GetClass("EliteEquipDrop", itemName)
				selected = TryGetProp(viboraCls,"ClassID")
			end
			selectExist = 1;
		end
	end

	if selectExist == 1 and selected == 0 then
		ui.MsgBox(ScpArgMsg("Auto_BoSangeul_SeonTaegHaeJuSeyo."));
		return;
	end

	local viboraCls = GetClassByType("EliteEquipDrop", selected)
	local viboraName = TryGetProp(viboraCls, "Name", "None")
	if viboraName == "None" then
		return
	end

	if selectExist == 1 then
		local itemGuid = frame:GetUserValue("UseItemGuid");
		local argStr = string.format("%s#%d", itemGuid, selected);
		
        local tradeSelectItem = frame:GetUserValue("TradeSelectItem");

		local msg = ScpArgMsg("SelectItemTrade{ITEM}", "ITEM", viboraName);
		local JobName = TryGetProp(viboraCls, "JobName")
		local isPcJob = IS_PC_JOB(JobName)

		if isPcJob == false then
			msg = ClMsg("CantUseVibora").."{nl} {nl}"..msg
		end

		local yesscp = string.format('CONFIRM_TRADE_VIBORA("%s")', argStr);
		ui.MsgBox_NonNested(msg, frame:GetName(), yesscp, 'None');
	end

	frame = frame:GetTopParentFrame();
	frame:ShowWindow(0);
end

function CONFIRM_TRADE_VIBORA(argStr)
    pc.ReqExecuteTx("TRADE_SELECT_VIBORA", argStr)
end

function OPEN_TRADE_SELECT_ITEM_STIRNG_SPLIT(invItem)
    local itemobj = GetIES(invItem:GetObject());
    if itemobj.ItemLifeTimeOver == 1 then
		ui.SysMsg(ScpArgMsg('LessThanItemLifeTime'));
		return
	end
	local frame = ui.GetFrame("tradeselectitem")
	local itemobj = GetIES(invItem:GetObject());
	local itemGuid = invItem:GetIESID();

	local box = frame:GetChild('box');
	tolua.cast(box, "ui::CGroupBox");
	box:DeleteAllControl();
	local y = 5;
	local cls = GetClass("TradeSelectItem", itemobj.ClassName)
	frame:SetTitleName("{@st43}{s22}"..ClMsg(cls.TitleClientMsg))    
	frame:SetUserValue("UseItemGuid", itemGuid);
	local index = 1;

	while 1 do
		local itemIndex = TryGetProp(cls, "SelectItemClsMsg_"..index)
		if itemIndex ~= nil then
			index = index + 1;
		else
			break;
		end
	end
	
	local select_item_icon_use = TryGetProp(cls, "SelectItemIconUse", 0);
	for i = 1, index do
		local itemName = TryGetProp(cls, "SelectItemClsMsg_"..i)
		local conditionfunction = nil;
		if itemobj.StringArg2 == "popo_special_box" then
			conditionfunction = SET_SELECT_CONDITION_POPOBOOST
		end

		if itemName ~= 'None' and itemName ~= nil then
			local icon_name = itemobj.ClassName
			if TryGetProp(cls, 'ItemIcon', 'None') == 'YES' then
				icon_name = itemName
			end

			local itemClsName = "None";
			if select_item_icon_use == 1 then
				itemClsName = TryGetProp(cls, "SelectItemStirngSplit_"..i, "None");
			end
			y = TRRADE_SELECT_STRING_SPLIT_CTRL(box, y, i, itemName, icon_name , conditionfunction, itemClsName);	
			y = y + 5
		end
	end
	
	frame:SetUserValue("TradeSelectItem", itemobj.ClassName);

	local cancelBtn = frame:GetChild('CancelBtn');
	cancelBtn:SetVisible(1);
	local useBtn = frame:GetChild('UseBtn');	
	useBtn:SetEventScript(ui.LBUTTONUP,'REQUEST_TRADE_SELECT_ITEM_STIRNG_SPLIT')
	local useBtnMargin = useBtn:GetMargin();
	local xmargin = frame:GetUserConfig("USE_BTN_X_MARGIN");
	useBtn:SetMargin(tonumber(xmargin), 0, 0, useBtnMargin.bottom);

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
	frame:ShowWindow(1);
end

function REQUEST_TRADE_SELECT_ITEM_STIRNG_SPLIT(frame, ctrl, argStr, argNum)
	local box = frame:GetChild('box');
	tolua.cast(box, "ui::CGroupBox");

	local selectExist = 0;
	local selected = 0;
	local cnt = box:GetChildCount();
	for i = 0 , cnt - 1 do
		local ctrlSet = box:GetChildByIndex(i);
		local name = ctrlSet:GetName();
		if string.find(name, "REWARD_") ~= nil then
			tolua.cast(ctrlSet, "ui::CControlSet");
			if ctrlSet:IsSelected() == 1 then
				selected = ctrlSet:GetValue();
			end
			selectExist = 1;
		end
	end

	if selectExist == 1 and selected == 0 then
		ui.MsgBox(ScpArgMsg("Auto_BoSangeul_SeonTaegHaeJuSeyo."));
		return;
	end

	if selectExist == 1 then
		local itemGuid = frame:GetUserValue("UseItemGuid");
		local argStr = string.format("%s#%d", itemGuid, selected);
		
        local tradeSelectItem = frame:GetUserValue("TradeSelectItem");
        local cls = GetClass("TradeSelectItem", tradeSelectItem)
		local warningYesNoMsg = TryGetProp(cls, 'WarningYesNoMsg')
        if warningYesNoMsg ~= nil and warningYesNoMsg ~= '' and warningYesNoMsg ~= 'None' then
            local selectItemName = ClMsg(TryGetProp(cls, 'SelectItemClsMsg_'..selected))
            local yesScp = string.format("REQUEST_TRADE_ITEM_STRING_SPLIT_WARNINGYES(\"%s\")",argStr);
        	ui.MsgBox(ScpArgMsg(warningYesNoMsg,'ITEM', selectItemName) , yesScp, 'None');
        else
    		pc.ReqExecuteTx("SCR_TX_TRADE_SELECT_ITEM_3", argStr);
    	end
	end

	frame = frame:GetTopParentFrame();
	frame:ShowWindow(0);
end

function SET_SELECT_CONDITION_POPOBOOST(index)
	local job = info.GetJob(session.GetMyHandle());
    local etc = GetMyEtcObject();
    if etc.RepresentationClassID ~= 'None' then
        local repreJobCls = GetClassByType('Job', etc.RepresentationClassID);
        if repreJobCls ~= nil then
            job = repreJobCls.ClassID;
        end
    end

	local jobList = {'Char1', 'Char2', 'Char3', 'Char4', 'Char5'}

    local gender = info.GetGender(session.GetMyHandle());
    local jobCls = GetClassByType("Job", job);
	local jobClassName = TryGetProp(jobCls, "ClassName");
	if string.find(jobClassName, jobList[index]) ~= nil then
		return false;
	else
		return true;
	end

	return true;
end

function REQUEST_TRADE_ITEM_STRING_SPLIT_WARNINGYES(argStr)
    pc.ReqExecuteTx("SCR_TX_TRADE_SELECT_ITEM_3", argStr);
end










function OPEN_TRADE_SELECT_SKILL_GEM_CTRLTYPE(invItem)

	local frame = ui.GetFrame("tradeselectitem")
	frame:SetTitleName('{@st43}{s22}' ..ScpArgMsg('SklgemSelectCtrlType'))
	local box = frame:GetChild('box');
	tolua.cast(box, "ui::CGroupBox");
	box:DeleteAllControl();
	local y = 5;

	local itemGuid = invItem:GetIESID();
	local itemObj = GetObjectByGuid(itemGuid)

	local jobList = {'Char1_1', 'Char2_1', 'Char3_1', 'Char4_1', 'Char5_1'}

	for i = 1, #jobList do
		local jobCls = GetClass('Job', jobList[i])
		if jobCls ~= nil then
			local jobName = jobCls.Name
			y = CREATE_QUEST_REWARE_CTRL_JOB(box, y, i, jobCls);	
			y = y + 5
		end
	end

	local cancelBtn = frame:GetChild('CancelBtn');
	local useBtn = frame:GetChild('UseBtn');
	useBtn:SetEventScript(ui.LBUTTONUP,'OPEN_TRADE_SELECT_SKILL_GEM_CLASS')

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
		box:SetCurLine(0) 
		
		box:Resize(box:GetOriginalWidth(), y);
		frame:Resize(frame:GetOriginalWidth(), maxSizeHeightFrame);
	end;
	box:SetScrollPos(0);

	local NeedItemSlot = frame:GetChild('NeedItemSlot')
	local NeedItemName = frame:GetChild('NeedItemName')
	NeedItemName:SetVisible(0)
	NeedItemSlot:SetVisible(0)

	frame:SetUserValue("UseItemGuid", itemGuid);
	frame:ShowWindow(1);
end


function OPEN_TRADE_SELECT_SKILL_GEM_CLASS(frame)
	local box = frame:GetChild('box');
	tolua.cast(box, "ui::CGroupBox");

	local selectExist = 0;
	local selected = 0;
	local cnt = box:GetChildCount();
	for i = 0 , cnt - 1 do
		local ctrlSet = box:GetChildByIndex(i);
		local name = ctrlSet:GetName();
		if string.find(name, "REWARD_") ~= nil then
			tolua.cast(ctrlSet, "ui::CControlSet");
			if ctrlSet:IsSelected() == 1 then
				selected = ctrlSet:GetValue();
			end
			selectExist = 1;
		end
	end

	frame:SetTitleName('{@st43}{s22}' ..ScpArgMsg('SklgemSelectJob'))
	local box = frame:GetChild('box');
	tolua.cast(box, "ui::CGroupBox");
	box:DeleteAllControl();
	local y = 5;

	local itemGuid = frame:GetUserValue("UseItemGuid")
	local itemObj = GetObjectByGuid(itemGuid)

	local job_type = TryGetProp(GetClassByType('Job', selected), 'CtrlType', 'None')

	local jobList = GetClassListByProp('Job', 'CtrlType', job_type)

	for i = 1,#jobList do
		local jobCls = jobList[i]
		if jobCls ~= nil and TryGetProp(jobCls, 'EnableJob', 'NO') == 'YES' then
			local jobName = jobCls.Name
			y = CREATE_QUEST_REWARE_CTRL_JOB(box, y, i, jobCls)
			y = y + 5
		end
	end

	local cancelBtn = frame:GetChild('CancelBtn');
	local useBtn = frame:GetChild('UseBtn');
	useBtn:SetEventScript(ui.LBUTTONUP,'OPEN_TRADE_SELECT_SKILL_GEM')

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
		box:SetCurLine(0) 
		
		box:Resize(box:GetOriginalWidth(), y);
		frame:Resize(frame:GetOriginalWidth(), maxSizeHeightFrame);
	end;
	box:SetScrollPos(0);

	local selectExist = 0;
	local selected = 0;
	local cnt = box:GetChildCount();
	for i = 0 , cnt - 1 do
		local ctrlSet = box:GetChildByIndex(i);
		local name = ctrlSet:GetName();
		if string.find(name, "REWARD_") ~= nil then
			tolua.cast(ctrlSet, "ui::CControlSet");
			if ctrlSet:IsSelected() == 1 then
				selected = ctrlSet:GetValue();
			end
			selectExist = 1;
		end
	end

	local NeedItemSlot = frame:GetChild('NeedItemSlot')
	local NeedItemName = frame:GetChild('NeedItemName')
	NeedItemName:SetVisible(0)
	NeedItemSlot:SetVisible(0)

	frame:SetUserValue("UseItemGuid", itemGuid);
	frame:ShowWindow(1);
end


function OPEN_TRADE_SELECT_SKILL_GEM(frame)

	frame:SetTitleName('{@st43}{s22}' ..ScpArgMsg('SklgemSelectGem'))

	local box = frame:GetChild('box');
	tolua.cast(box, "ui::CGroupBox");

	local selectExist = 0;
	local selected = 0;
	local cnt = box:GetChildCount();
	for i = 0 , cnt - 1 do
		local ctrlSet = box:GetChildByIndex(i);
		local name = ctrlSet:GetName();
		if string.find(name, "REWARD_") ~= nil then
			tolua.cast(ctrlSet, "ui::CControlSet");
			if ctrlSet:IsSelected() == 1 then
				selected = ctrlSet:GetValue();
			end
			selectExist = 1;
		end
	end
	
	if selected == 0 then return end

	box:DeleteAllControl();
	local y = 5;

	local job = TryGetProp(GetClassByType('Job', selected), "JobName", "None")
	local SkillList = {}

	if job == 'FireMage' then
		job = 'Pyromancer' 
	elseif job == 'FrostMage' then
		job = 'Cryomancer'
	elseif job == 'Outlaw' then
		job = 'OutLaw'
	elseif job == 'Templar' then
		job = 'Templer'
	elseif job == 'ShadowMancer' then
		job = 'Shadowmancer'
	elseif job == 'Lancer' then
		job = 'Rancer'
	end

	local cls , cnt = GetClassList('SkillTree')
	for i = 0, cnt -1 do
		local skltcls = GetClassByIndexFromList(cls, i)
		local sklname = TryGetProp(skltcls, "SkillName", "None")

		-- 스킬 이름이 job과 매칭되지 않은 사항 처리
		-- 추가해야 하는 경우는 직접 추가하고, 제거해야 하는 경우는 exceptionCase을 1로 셋팅
		local exceptionCase = 0
		
		if sklname == "Peltasta_ButterFly" then
			if job == "Murmillo" then
				local skillgem_cls = GetClassByStrProp('Item', 'SkillName', sklname)
				SkillList[#SkillList + 1] = skillgem_cls
			end

			if job == "Peltasta" then
				exceptionCase = 1
			end
		end
		
		-----------------------------------------------

		if string.find(sklname, job..'_') ~= nil and exceptionCase == 0 then
			local skillgem_cls = GetClassByStrProp('Item', 'SkillName', sklname)
			if job == 'Hunter' then
				if string.find(sklname, 'TigerHunter_') == nil then
					SkillList[#SkillList + 1] = skillgem_cls
				end
			else
				SkillList[#SkillList + 1] = skillgem_cls
			end
		end
    end

	if SkillList[1] == nil then return end

	for i = 1,#SkillList do
		local sklCls = SkillList[i]
		if sklCls ~= nil then
			local sklName = sklCls.ClassName
			y = CREATE_SKILL_GEM_ITEM_CTRL(box, y, i, sklName, 1)
			y = y + 5
		end
	end

	local cancelBtn = frame:GetChild('CancelBtn');
	local useBtn = frame:GetChild('UseBtn');
	useBtn:SetEventScript(ui.LBUTTONUP,'REQUEST_TRADE_SELECT_SKILL_GEM')

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
		box:SetCurLine(0) 
		
		box:Resize(box:GetOriginalWidth(), y);
		frame:Resize(frame:GetOriginalWidth(), maxSizeHeightFrame);
	end;
	box:SetScrollPos(0);

	local NeedItemSlot = frame:GetChild('NeedItemSlot')
	local NeedItemName = frame:GetChild('NeedItemName')
	NeedItemName:SetVisible(0)
	NeedItemSlot:SetVisible(0)

	frame:ShowWindow(1);
end



function CREATE_SKILL_GEM_ITEM_CTRL(box, y, index, ItemName, itemCnt)
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
	ctrlSet:SetEnableSelect(1);
	ctrlSet:SetSelectGroupName("QuestRewardList");
	
	SET_ITEM_TOOLTIP_BY_TYPE(ctrlSet, itemCls.ClassID);
	
	ctrlSet:Resize(box:GetWidth() - 30, ctrlSet:GetHeight());

	y = y + ctrlSet:GetHeight();
	return y;

end


function REQUEST_TRADE_SELECT_SKILL_GEM(frame)    
	local box = frame:GetChild('box')
	tolua.cast(box, "ui::CGroupBox")

	local selectExist = 0
	local selected = 0
	local selectgem = 0

	local cnt = box:GetChildCount()
	for i = 0 , cnt - 1 do
		local ctrlSet = box:GetChildByIndex(i)
		local name = ctrlSet:GetName()
		if string.find(name, "REWARD_") ~= nil then
			tolua.cast(ctrlSet, "ui::CControlSet")
			if ctrlSet:IsSelected() == 1 then
				selectgem = ctrlSet:GetUserValue('SklGemID')
				selected = ctrlSet:GetValue();
			end
			selectExist = 1
		end
	end
	if selectExist == 1 and selected == 0 then
		ui.MsgBox(ScpArgMsg("Auto_BoSangeul_SeonTaegHaeJuSeyo."))
		return
	end

	if selectExist == 1 and selectgem ~= 0 then
		local itemGuid = frame:GetUserValue("UseItemGuid")
		local yesScp = string.format("REQUEST_TRADE_SELECT_SKILL_GEM_WARNINGYES(\"%s\", \"%s\")", itemGuid, selectgem)
		ui.MsgBox(ScpArgMsg('SelectHairAcc{ITEM}','ITEM', GetClassByType('Item', selectgem).Name) , yesScp, 'None')
	end

	frame = frame:GetTopParentFrame()
	frame:ShowWindow(0)
end


function REQUEST_TRADE_SELECT_SKILL_GEM_WARNINGYES(itemGuid, selectgem)
    pc.ReqExecuteTx_Item("TRADE_SELECT_SKILL_GEM", itemGuid, selectgem)
end

function OPEN_TRADE_SELECT_ITEM_STIRNG_SPLIT_RANDOM_OPTION(invItem)
    local itemobj = GetIES(invItem:GetObject());
    if itemobj.ItemLifeTimeOver == 1 then
		ui.SysMsg(ScpArgMsg('LessThanItemLifeTime'));
		return
	end
	local frame = ui.GetFrame("tradeselectitem")
	local itemobj = GetIES(invItem:GetObject());
	local itemGuid = invItem:GetIESID();

	local box = frame:GetChild('box');
	tolua.cast(box, "ui::CGroupBox");
	box:DeleteAllControl();
	local y = 5;
	local cls = GetClass("TradeSelectItem", itemobj.ClassName)
	frame:SetTitleName("{@st43}{s22}"..ClMsg(cls.TitleClientMsg))    
	frame:SetUserValue("UseItemGuid", itemGuid);
	local index = 1;

	while 1 do
		local itemIndex = TryGetProp(cls, "SelectItemClsMsg_"..index)
		if itemIndex ~= nil then
			index = index + 1;
		else
			break;
		end
	end

	for i = 1, index do
		local itemName = TryGetProp(cls, "SelectItemClsMsg_"..i)

		if itemName ~= 'None' and itemName ~= nil then
			y = TRRADE_SELECT_STRING_SPLIT_CTRL(box, y, i, itemName, itemobj.ClassName);	
			y = y + 5
		end
	end
	
	frame:SetUserValue("TradeSelectItem", itemobj.ClassName);

	local cancelBtn = frame:GetChild('CancelBtn');
	cancelBtn:SetVisible(1);
	local useBtn = frame:GetChild('UseBtn');	
	useBtn:SetEventScript(ui.LBUTTONUP,'REQUEST_TRADE_SELECT_ITEM_STIRNG_SPLIT_RANDOM_OPTION')
	local useBtnMargin = useBtn:GetMargin();
	local xmargin = frame:GetUserConfig("USE_BTN_X_MARGIN");
	useBtn:SetMargin(tonumber(xmargin), 0, 0, useBtnMargin.bottom);

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
	frame:ShowWindow(1);
end

function REQUEST_TRADE_SELECT_ITEM_STIRNG_SPLIT_RANDOM_OPTION(frame, ctrl, argStr, argNum)
	local box = frame:GetChild('box');
	tolua.cast(box, "ui::CGroupBox");

	local selectExist = 0;
	local selected = 0;
	local cnt = box:GetChildCount();
	for i = 0 , cnt - 1 do
		local ctrlSet = box:GetChildByIndex(i);
		local name = ctrlSet:GetName();
		if string.find(name, "REWARD_") ~= nil then
			tolua.cast(ctrlSet, "ui::CControlSet");
			if ctrlSet:IsSelected() == 1 then
				selected = ctrlSet:GetValue();
			end
			selectExist = 1;
		end
	end

	if selectExist == 1 and selected == 0 then
		ui.MsgBox(ScpArgMsg("Auto_BoSangeul_SeonTaegHaeJuSeyo."));
		return;
	end

	if selectExist == 1 then
		local itemGuid = frame:GetUserValue("UseItemGuid");
		local argStr = string.format("%s#%d", itemGuid, selected);
		
        local tradeSelectItem = frame:GetUserValue("TradeSelectItem");
        local cls = GetClass("TradeSelectItem", tradeSelectItem)
		local warningYesNoMsg = TryGetProp(cls, 'WarningYesNoMsg')
        if warningYesNoMsg ~= nil and warningYesNoMsg ~= '' and warningYesNoMsg ~= 'None' then
            local selectItemName = ClMsg(TryGetProp(cls, 'SelectItemClsMsg_'..selected))
            local yesScp = string.format("REQUEST_RANOPT_WARNING(\'%s\')",argStr);
        	ui.MsgBox(ScpArgMsg(warningYesNoMsg,'ITEM', selectItemName) , yesScp, 'None');
        else
    		pc.ReqExecuteTx("SCR_TX_TRADE_SELECT_ITEM_RANOPT", argStr);
    	end
	end

	frame = frame:GetTopParentFrame();
	frame:ShowWindow(0);
end











function OPEN_TRADE_SELECT_JOB_EARRING_CTRLTYPE(invItem)

	local frame = ui.GetFrame("tradeselectitem")
	frame:SetTitleName('{@st43}{s22}' ..ScpArgMsg('EarringSelectCtrlType'))
	local box = frame:GetChild('box');
	tolua.cast(box, "ui::CGroupBox");
	box:DeleteAllControl();
	local y = 5;
	
	local itemGuid = invItem:GetIESID();
	local itemObj = GetObjectByGuid(itemGuid)

	local jobList = {'Char1_1', 'Char2_1', 'Char3_1', 'Char4_1', 'Char5_1'}

	for i = 1, #jobList do
		local jobCls = GetClass('Job', jobList[i])
		if jobCls ~= nil then
			local jobName = jobCls.Name
			y = CREATE_QUEST_REWARE_CTRL_JOB(box, y, i, jobCls);	
			y = y + 5
		end
	end

	local cancelBtn = frame:GetChild('CancelBtn');
	local useBtn = frame:GetChild('UseBtn');
	useBtn:SetEventScript(ui.LBUTTONUP,'OPEN_TRADE_SELECT_JOB_EARRING_CLASS')

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
		box:SetCurLine(0) 
		
		box:Resize(box:GetOriginalWidth(), y);
		frame:Resize(frame:GetOriginalWidth(), maxSizeHeightFrame);
	end;
	box:SetScrollPos(0);

	local NeedItemSlot = frame:GetChild('NeedItemSlot')
	local NeedItemName = frame:GetChild('NeedItemName')
	NeedItemName:SetVisible(0)
	NeedItemSlot:SetVisible(0)

	frame:SetUserValue("UseItemGuid", itemGuid);
	frame:ShowWindow(1);
end


function OPEN_TRADE_SELECT_JOB_EARRING_CLASS(frame)
	local box = frame:GetChild('box');
	tolua.cast(box, "ui::CGroupBox");

	local selectExist = 0;
	local selected = 0;
	local cnt = box:GetChildCount();
	for i = 0 , cnt - 1 do
		local ctrlSet = box:GetChildByIndex(i);
		local name = ctrlSet:GetName();
		if string.find(name, "REWARD_") ~= nil then
			tolua.cast(ctrlSet, "ui::CControlSet");
			if ctrlSet:IsSelected() == 1 then
				selected = ctrlSet:GetValue();
			end
			selectExist = 1;
		end
	end

	frame:SetTitleName('{@st43}{s22}' ..ScpArgMsg('EarringSelectCtrlType'))
	local box = frame:GetChild('box');
	tolua.cast(box, "ui::CGroupBox");
	box:DeleteAllControl();
	local y = 5;

	local itemGuid = frame:GetUserValue("UseItemGuid")
	local itemObj = GetObjectByGuid(itemGuid)
	
	if selected == 0 then
		local invitem = session.GetInvItemByGuid(itemGuid)
		OPEN_TRADE_SELECT_JOB_EARRING_CTRLTYPE(invitem )
		return
	end

	local job_type = TryGetProp(GetClassByType('Job', selected), 'CtrlType', 'None')
	local jobList = GetClassListByProp('Job', 'CtrlType', job_type)

	for i = 1,#jobList do
		local jobCls = jobList[i]
		if jobCls ~= nil and TryGetProp(jobCls, 'EnableJob', 'NO') == 'YES' then
			local jobName = jobCls.Name
			
			local jobList = {'Char1_1', 'Char2_1', 'Char3_1', 'Char4_1', 'Char5_1'}
			if table.find(jobList, jobCls.ClassName) == 0 then
				y = CREATE_QUEST_REWARE_CTRL_JOB2(box, y, i, jobCls)
				y = y + 5
			end
		end
	end

	local cancelBtn = frame:GetChild('CancelBtn');
	local useBtn = frame:GetChild('UseBtn');
	useBtn:SetEventScript(ui.LBUTTONUP,'REQUEST_TRADE_SELECT_JOB_EARRING')

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
		box:SetCurLine(0) 
		
		box:Resize(box:GetOriginalWidth(), y);
		frame:Resize(frame:GetOriginalWidth(), maxSizeHeightFrame);
	end;
	box:SetScrollPos(0);

	local selectExist = 0;
	local selected = 0;
	local cnt = box:GetChildCount();
	for i = 0 , cnt - 1 do
		local ctrlSet = box:GetChildByIndex(i);
		local name = ctrlSet:GetName();
		if string.find(name, "REWARD_") ~= nil then
			tolua.cast(ctrlSet, "ui::CControlSet");
			if ctrlSet:IsSelected() == 1 then
				selected = ctrlSet:GetValue();
			end
			selectExist = 1;
		end
	end

	local NeedItemSlot = frame:GetChild('NeedItemSlot')
	local NeedItemName = frame:GetChild('NeedItemName')
	NeedItemName:SetVisible(0)
	NeedItemSlot:SetVisible(0)

	frame:SetUserValue("UseItemGuid", itemGuid);
	frame:ShowWindow(1);
end


function CREATE_QUEST_REWARE_CTRL_JOB2(box, y, index, jobCls)
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
	local jobName = jobCls.Name
	local jobIcon = jobCls.Icon
	local ctrlSet = box:CreateControlSet('quest_reward_s', "REWARD_" .. index, x, y);
	tolua.cast(ctrlSet, "ui::CControlSet");
	--?�기 값을 ?�중??받아??처리!!
	ctrlSet:SetValue(jobCls.ClassID);
	ctrlSet:SetUserValue('job_id', jobCls.ClassID)
	local slot = ctrlSet:GetChild("slot");
	tolua.cast(slot, "ui::CSlot");
	
	local icon = CreateIcon(slot)
	icon:SetImage(jobIcon)

	local jobText = ctrlSet:GetChild("ItemName");
	jobName = "{@st41b}"..jobName
	jobText:SetText(jobName);
	ctrlSet:SetOverSound("button_cursor_over_3");
	ctrlSet:SetClickSound("button_click_stats");
	ctrlSet:SetEnableSelect(1);
	ctrlSet:SetSelectGroupName("QuestRewardList");
	
	ctrlSet:Resize(box:GetWidth() - 30, ctrlSet:GetHeight());

	y = y + ctrlSet:GetHeight();
	return y;

end


function REQUEST_TRADE_SELECT_JOB_EARRING(frame)    
	local box = frame:GetChild('box')
	tolua.cast(box, "ui::CGroupBox")

	local selectExist = 0
	local selected = 0
	local select_job = 0

	local cnt = box:GetChildCount()
	for i = 0 , cnt - 1 do
		local ctrlSet = box:GetChildByIndex(i)
		local name = ctrlSet:GetName()
		if string.find(name, "REWARD_") ~= nil then
			tolua.cast(ctrlSet, "ui::CControlSet")
			if ctrlSet:IsSelected() == 1 then
				select_job = ctrlSet:GetUserValue('job_id')
				selected = ctrlSet:GetValue();
			end
			selectExist = 1
		end
	end

	if selectExist == 1 and selected == 0 then
		ui.MsgBox(ScpArgMsg("Auto_BoSangeul_SeonTaegHaeJuSeyo."))
		return
	end
	
	if selectExist == 1 and select_job ~= 0 then
		local itemGuid = frame:GetUserValue("UseItemGuid")
		local yesScp = string.format("REQUEST_TRADE_SELECT_JOB_EARRING_WARNINGYES(\"%s\", \"%s\")", itemGuid, select_job)
		ui.MsgBox(ScpArgMsg('SelectJobEarring{ITEM}','ITEM', GetClassByType('Job', select_job).Name) , yesScp, 'None')
	end

	frame = frame:GetTopParentFrame()
	frame:ShowWindow(0)
end


function REQUEST_TRADE_SELECT_JOB_EARRING_WARNINGYES(itemGuid, selectgem)
	local frame = ui.GetFrame("tradeselectitem")
	itemGuid = frame:GetUserValue("UseItemGuid")
    pc.ReqExecuteTx_Item("EARRING_SELECT_JOB", itemGuid, selectgem)
end