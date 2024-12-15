function MULTIPLE_TRADESELECTITEM_ON_INIT(addon, frame)
end

local multipe_tradeselectitem_inv_id = '0'

function MULTIPLE_OPEN_TRADE_SELECT_ITEM(invItem)
    local itemobj = GetIES(invItem:GetObject());
    if itemobj.ItemLifeTimeOver == 1 then
		ui.SysMsg(ScpArgMsg('LessThanItemLifeTime'));
		return
	end
	local frame = ui.GetFrame("tradeselectitem_multiple")
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
	useBtn:SetEventScript(ui.LBUTTONUP,'MULTIPLE_REQUEST_TRADE_ITEM')
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

function MULTIPLE_REQUEST_TRADE_ITEM(frame, ctrl, argStr, argNum)
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
		local invItem = session.GetInvItemByGuid(tostring(itemGuid))
		local itemObj = GetIES(invItem:GetObject())
		local argStr = string.format("%s#%d", itemGuid, selected)

		if TryGetProp(itemObj, 'MaxStack', 0) == 1 or invItem.count == 1 then
			frame:SetUserValue("argStr", argStr)
			RUN_CLIENT_MULTIPLE_REQUEST_TRADE_ITEM(1)
		else
			frame:SetUserValue("argStr", argStr)
			local titleText = ScpArgMsg("multiple_trade_select_item", "Auto_1", 1, "Auto_2", invItem.count)
			INPUT_NUMBER_BOX(nil, titleText, "RUN_CLIENT_MULTIPLE_REQUEST_TRADE_ITEM", 1, 1, invItem.count)
		end
	end

	frame = frame:GetTopParentFrame();
	frame:ShowWindow(0);
end

function RUN_CLIENT_MULTIPLE_REQUEST_TRADE_ITEM(count)
	local frame = ui.GetFrame("tradeselectitem_multiple")
	local argStr = frame:GetUserValue("argStr")
	count = ';'..tostring(count)
	pc.ReqExecuteTx("TRADE_SELECT_ITEM_MUL", argStr..count)
end
