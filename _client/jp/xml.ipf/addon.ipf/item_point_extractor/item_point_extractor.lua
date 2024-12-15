
function ITEM_POINT_EXTRACTOR_ON_INIT(addon, frame)
	addon:RegisterMsg("ITEM_POINT_EXTRACTOR_EXECUTE", "ON_ITEM_POINT_EXTRACTOR_EXECUTE");
end

function REQ_ITEM_POINT_EXTRACTOR_OPEN(pointName)
	local frame = ui.GetFrame('item_point_extractor')
	frame:SetUserValue("POINT_NAME",pointName)
	frame:ShowWindow(1)
end

function ITEM_POINT_EXTRACTOR_OPEN(frame)
	local pointName = frame:GetUserValue("POINT_NAME")
	local title = GET_CHILD(frame,"title")
	title:SetTextByKey("title",ClMsg(pointName..'_extract'))
	local question = GET_CHILD(frame,"question")
	question:SetTextTooltip(ClMsg(pointName.."_extract_tooltip"));
	
	UPDATE_ITEM_POINT_EXTRACTOR_UI(frame)
	ITEM_POINT_EXTRACTOR_SET_POINT(frame)
end

function ITEM_POINT_EXTRACTOR_SET_POINT(frame)
	local aObj = GetMyAccountObj()
	local pointName = frame:GetUserValue("POINT_NAME")
	local totalPoint = GET_CHILD_RECURSIVELY(frame,"totalPoint")
	local totalValue = TryGetProp(aObj,pointName);
	totalPoint:SetTextByKey("value",totalValue)

	local addPoint = GET_CHILD_RECURSIVELY(frame,"addPoint")
	local addValue = GET_TOTAL_ADD_POINT(frame)
	addPoint:SetTextByKey("value",addValue)

	local afterPoint = GET_CHILD_RECURSIVELY(frame,"afterPoint")
	afterPoint:SetTextByKey("value",totalValue+addValue)
	SET_MATERIAL_POINT_INFO_LIST(frame)
end

function GET_TOTAL_ADD_POINT(frame)
	local slotSet = GET_CHILD_RECURSIVELY(frame,"slotlist","ui::CSlotSet")
	local addPoint = 0
	for i = 0,slotSet:GetSlotCount()-1 do
		local slot = slotSet:GetSlotByIndex(i);
		local point = tonumber(slot:GetUserValue("ITEM_POINT"))
		if point == nil then
			break
		end
		addPoint = addPoint + point * slot:GetSelectCount()
	end
	return addPoint;
end

function SET_MATERIAL_POINT_INFO_LIST(frame)
	local OFFSET_Y = 10
	local HEIGHT = 65
	local slotSet = GET_CHILD_RECURSIVELY(frame,"slotlist","ui::CSlotSet")
	local gbox = GET_CHILD_RECURSIVELY(frame,"materialInfoGbox")
	gbox:RemoveAllChild()
	for i = 0,slotSet:GetSlotCount()-1 do
		local slot = slotSet:GetSlotByIndex(i);
		local point = tonumber(slot:GetUserValue("ITEM_POINT"))
		if point == nil then
			break
		end
		local cnt = slot:GetSelectCount()
		if cnt > 0 then
			local info = slot:GetIcon():GetInfo()
			local ctrlSet = gbox:CreateOrGetControlSet("item_point_price","PRICE"..info.type..i,10,OFFSET_Y)
			local itemSlot = GET_CHILD(ctrlSet,"itemSlot")
			local itemCount = GET_CHILD(itemSlot,"itemCount")
			local icon = CreateIcon(itemSlot)
			icon:SetImage(info:GetImageName())
			local cntText = string.format("{#ffe400}{ds}{ol}{b}{s18}%d",cnt)
			itemCount:SetText(cntText)

			local itemPrice = GET_CHILD(ctrlSet,"itemPrice")
			local text = string.format("{s18}{ol}{b} X %d ={/} {#ec0000}%d{/}{/}{/}",point,point*cnt)
			itemPrice:SetText(text)
			OFFSET_Y = OFFSET_Y + HEIGHT
		end
	end
end

function ITEM_POINT_EXTRACTOR_CLOSE(frame)
end

function UPDATE_ITEM_POINT_EXTRACTOR_UI(frame)
	local slotSet = GET_CHILD_RECURSIVELY(frame,"slotlist","ui::CSlotSet")
	slotSet:ClearIconAll();

	local invItemList = session.GetInvItemList();
	local materialItemList = GET_ITEM_POINT_EXTRACT_ITEM_LIST(frame)
	FOR_EACH_INVENTORY(invItemList, function(invItemList, invItem, slotSet,materialItemList)
		local obj = GetIES(invItem:GetObject());
		local itemName = TryGetProp(obj,"ClassName","None");
		if materialItemList[itemName] ~= nil then
			local slotindex = imcSlot:GetEmptySlotIndex(slotSet);
			if slotindex == 0 and imcSlot:GetFilledSlotCount(slotSet) == slotSet:GetSlotCount() then
				slotSet:ExpandRow()
				slotindex = imcSlot:GetEmptySlotIndex(slotSet);
			end
			local slot = slotSet:GetSlotByIndex(slotindex);
			slot:SetMaxSelectCount(invItem.count);
			slot:SetUserValue("ITEM_POINT",materialItemList[itemName])
			local icon = CreateIcon(slot);			
			icon:Set(obj.Icon, 'Item', invItem.type, slotindex, invItem:GetIESID(), invItem.count);
			local class = GetClassByType('Item', invItem.type);
			SET_SLOT_ITEM_TEXT_USE_INVCOUNT(slot, invItem, obj, invItem.count);
			ICON_SET_INVENTORY_TOOLTIP(icon, invItem, "poisonpot", class);
		end
	end, false, slotSet,materialItemList);

	local cnt = slotSet:GetRow()-tonumber(frame:GetUserConfig("DEFAULT_ROW"))
	for i = 1,cnt do
		local row_num = slotSet:GetRow()
		slotSet:AutoCheckDecreaseRow()
		if row_num == slotSet:GetRow() then
			break
		end
	end
end

function GET_ITEM_POINT_EXTRACT_ITEM_LIST(frame)
	local pointName = frame:GetUserValue("POINT_NAME")
	local clsList,cnt = GetClassList("PointExtractItem")
	local retTable = {}
	for i = 0,cnt-1 do
		local cls = GetClassByIndexFromList(clsList,i)
		if TryGetProp(cls,"PointName","None") == pointName then
			retTable[cls.ItemClassName] = cls.Point;
		end
	end
	return retTable
end

function SCP_LBTDOWN_ITEM_POINT_EXTRACTOR(frame, ctrl)
	ui.EnableSlotMultiSelect(1);
	ITEM_POINT_EXTRACTOR_SET_POINT(frame:GetTopParentFrame())
end

function EXECUTE_ITEM_POINT_EXTRACTOR(frame)
	session.ResetItemList();

	local totalprice = 0;
	local slotSet = GET_CHILD_RECURSIVELY(frame, "slotlist", "ui::CSlotSet")
	if slotSet:GetSelectedSlotCount() < 1 then
		ui.MsgBox(ScpArgMsg("SelectSomeItemPlz"))
		return;
	end

	for i = 0, slotSet:GetSelectedSlotCount() -1 do
		local slot = slotSet:GetSelectedSlot(i)
		local Icon = slot:GetIcon();
		local iconInfo = Icon:GetInfo();
		
		local  cnt = slot:GetSelectCount();
		session.AddItemID(iconInfo:GetIESID(), cnt);
	end

	local msg = ScpArgMsg('GetPointByConsumingItem',"COUNT",GET_TOTAL_ADD_POINT(frame))
	local pointName = frame:GetUserValue("POINT_NAME")
	local yesScp = string.format("EXECUTE_ITEM_POINT_EXTRACTOR_COMMIT('%s')",pointName)
	ui.MsgBox(msg, yesScp, "None");
end

function EXECUTE_ITEM_POINT_EXTRACTOR_COMMIT(pointName)
	local resultlist = session.GetItemIDList();
	local argStrList = NewStringList();
	argStrList:Add(pointName);
	item.DialogTransaction("ITEM_POINT_EXTRACT", resultlist,"",argStrList);
end

function ON_ITEM_POINT_EXTRACTOR_EXECUTE(frame,msg,argStr,argNum)
	UPDATE_ITEM_POINT_EXTRACTOR_UI(frame)
	ITEM_POINT_EXTRACTOR_SET_POINT(frame)
end