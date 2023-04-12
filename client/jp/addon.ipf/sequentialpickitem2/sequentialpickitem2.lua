-- sequentialpickitem2.lua

SEQUENTIALPICKITEM2_openCount = 0;
SEQUENTIALPICKITEM2_CNT_MAX = 5;
SEQUENTIALPICKITEM2_OpenItem = {}
SEQUENTIALPICKITEM2_STARTY = 700

function SEQUENTIALPICKITEM2_ON_INIT(addon, frame)
	addon:RegisterMsg('INV_ITEM_IN', 'SEQUENTIALPICKITEM2_MSG');
	addon:RegisterMsg('SEAL_LV_UP_POPUP', 'SEQUENTIALPICKITEM2_SEAL_LV_UP_POPUP');
	addon:RegisterMsg('GET_PROPERTY_POINT', 'SEQUENTIALPICKITEM2_GET_PROPERTY_POINT')
end

function SEQUENTIALPICKITEM2_SEAL_LV_UP_POPUP(frame, msg, guid, count)
	local invitem = session.GetInvItemByGuid(guid);
	local itemObj = GetIES(invitem:GetObject())

	local classID = TryGetProp(itemObj, 'ClassID', 0)
	if classID == 0 then return end
	
	local iconName = GET_ITEM_ICON_IMAGE(itemObj);
	local itemName = GET_FULL_NAME(itemObj, nil, nil, 20);

	SEQUENTIALPICKITEM2_ADD_SEQUENTIAL_PICKITEM(classID, iconName, itemName, count, 'SealLvUp')
end

function SEQUENTIALPICKITEM2_GET_PROPERTY_POINT(frame, msg, propertyName, count)
	if config.GetPickItemMessage() == 1 then
		local chat_msg = ScpArgMsg("PointGet{name}{count}", "name", ClMsg(argStr), "count", count);
		session.ui.GetChatMsg():AddSystemMsg(chat_msg, true, 'System', '', false);
	end

	local cls = GetClass('accountprop_inventory_list', propertyName)
	if cls == nil then return end

	local classID = TryGetProp(cls, 'ClassID', 0)
	if classID == 0 then return end
	
	local iconName = TryGetProp(cls, 'Icon', 'None')
	if iconName == 'None' then return end

	local itemName = TryGetProp(cls, 'ClassName', 'None')
	if itemName == 'None' then return end
	itemName = ClMsg(itemName)

	SEQUENTIALPICKITEM2_ADD_SEQUENTIAL_PICKITEM(classID, iconName, itemName, count, 'AccountProperty')
end

function SEQUENTIALPICKITEM2_MSG(frame, msg, guid, count, class)	
    if IS_IN_EVENT_MAP() == true then return end
	
	local classID = 0
	local iconName = ""
	local itemName = ""

	if msg == 'INV_ITEM_IN' then
		local invitem = session.GetInvItemByGuid(guid);
		if class == nil then
			class = GetClassByType("Item", invitem.prop.type)
		end

		classID = TryGetProp(class, 'ClassID', 0)
		iconName = GET_ITEM_ICON_IMAGE(class);
		itemName = GET_FULL_NAME(class, nil, nil, 20);		
		if config.GetPickItemMessage() == 1 then
			local cls_point = GetClass('accountprop_inventory_list', class.ClassName)
			if cls_point ~= nil then
				local chat_msg = ScpArgMsg("PointGet{name}{count}", "name", ClMsg(TryGetProp(cls_point, 'ClassName', 'None')), "count", count);
				session.ui.GetChatMsg():AddSystemMsg(chat_msg, true, 'System', '', false);
			else			
				local chat_msg = ScpArgMsg("ItemGet{name}{count}", "name", TryGetProp(class, 'Name', 'None'), "count", count);
				session.ui.GetChatMsg():AddSystemMsg(chat_msg, true, 'System', '', false);										
			end
		end
		
		if class.ItemType == 'Unused' then return end
	else
		return
	end

	SEQUENTIALPICKITEM2_ADD_SEQUENTIAL_PICKITEM(classID, iconName, itemName, count, 'NORMAL')
end

function SEQUENTIALPICKITEM2_OPEN(frame)
end

function SEQUENTIALPICKITEM2_CLOSE(frame)	
	local tableKey = frame:GetUserValue("TABLE_KEY")
	if SEQUENTIALPICKITEM2_OpenItem[tableKey] ~= nil then
		SEQUENTIALPICKITEM2_OpenItem[tableKey] = nil
	end

	SEQUENTIALPICKITEM2_SORT_FRAME()
end

function SEQUENTIALPICKITEM2_ADD_SEQUENTIAL_PICKITEM(classID, iconName, itemName, itemCount, type)	
	if config.GetPopupPickItem() ~= 1 then return end

	local frameName = "SEQUENTIAL_PICKITEM2_"..type.."_"..classID	
	local frame = ui.GetFrame(frameName)
	if frame ~= nil then
		SEQUENTIALPICKITEM2_UPDATE_FRAME(frame, iconName, itemName, itemCount)		
	else		
		SEQUENTIALPICKITEM2_CREATE_FRAME(classID, iconName, itemName, itemCount, type)		
	end

	SEQUENTIALPICKITEM2_SORT_FRAME()
end

function SEQUENTIALPICKITEM2_UPDATE_FRAME(frame, iconName, itemNameText, itemCountText)
	local PickItemGropBox = GET_CHILD(frame, 'pickitem')
	local PickItemCountObj = PickItemGropBox:CreateOrGetControlSet('pickitemset_Type2', 'pickitemset', 0, 0);
	local PickItemCountCtrl = tolua.cast(PickItemCountObj, "ui::CControlSet");

	-- 아이콘
	local ConSetBySlot 	= PickItemCountCtrl:GetChild('slot');
	local slot = tolua.cast(ConSetBySlot, "ui::CSlot");
	local icon = CreateIcon(slot);
	icon:Set(iconName, 'PICKITEM', itemCountText, 0);
	SET_SLOT_STAR_TEXT_BY_ITEM_NAME(slot, itemNameText);

	-- 이름
	local ItemName = GET_CHILD(PickItemCountCtrl, "ItemName", "ui::CRichText")
	ItemName:SetTextByKey('value', itemNameText)

	-- 갯수
	local ItemCount = GET_CHILD(PickItemCountCtrl, "ItemCount", "ui::CRichText")	
	local oldCount = frame:GetUserIValue('ITEM_COUNT')
	ItemCount:SetTextByKey('value', oldCount + itemCountText)
	frame:SetUserValue("ITEM_COUNT", oldCount + itemCountText)		

	--내용 끝
	frame:ShowWindow(1);	
	frame:SetDuration(2);
	frame:Invalidate();
end

function SEQUENTIALPICKITEM2_CREATE_FRAME(classID, iconName, itemName, itemCount, type)
	local frameName = "SEQUENTIAL_PICKITEM2_"..type.."_"..classID;	
	local frame = ui.CreateNewFrame("sequentialpickitem2", frameName);
	if frame == nil then return end

	SEQUENTIALPICKITEM2_OpenItem[type.."_"..classID] = "AlreadyOpen"	

	frame:SetUserValue("TYPE", type)
	frame:SetUserValue("CLASSID", classID)
	frame:SetUserValue("ITEM_COUNT", 0)
	frame:SetUserValue("LAST_Y", SEQUENTIALPICKITEM2_STARTY)
	frame:SetUserValue("TABLE_KEY", type.."_"..classID)	
	
	SEQUENTIALPICKITEM2_UPDATE_FRAME(frame, iconName, itemName, itemCount)
end

function SEQUENTIALPICKITEM2_SORT_FRAME()
	local framelist = {}
	for k, v in pairs(SEQUENTIALPICKITEM2_OpenItem) do
        local frameTemp = ui.GetFrame("SEQUENTIAL_PICKITEM2_"..k)
        if frameTemp ~= nil and frameTemp:GetDuration() > 0 then
            local frameinfo = {}
            frameinfo["frame"] = frameTemp
			frameinfo["duration"] = frameTemp:GetDuration()
			local type = frameTemp:GetUserValue('TYPE')
			if type == 'NORMAL' then
				local classID = frameTemp:GetUserIValue('CLASSID')
				local cls = GetClassByType('Item', classID)
				frameinfo["grade"] = TryGetProp(cls, 'ItemGrade', 0)
				frameinfo["classID"] = classID
			else
				frameinfo["grade"] = 0
				frameinfo["classID"] = 0
			end
            framelist[#framelist + 1] = frameinfo
        end
	end
	
	table.sort(framelist, function(a, b)		
		if a["classID"] ~= b["classID"] then
			return a["classID"] < b["classID"]
		elseif a["grade"] ~= b["grade"] then
			return a["grade"] < b["grade"]
		end
		return a["duration"] < b["duration"]				
	end)

    for i = 1, #framelist - SEQUENTIALPICKITEM2_CNT_MAX do
        local frame = framelist[i]["frame"]
        ui.CloseFrame(frame:GetName())
    end

    local y = SEQUENTIALPICKITEM2_STARTY
    local moveY = 0
    local startIndex = 1
    if #framelist - SEQUENTIALPICKITEM2_CNT_MAX > 0 then
        startIndex = #framelist - SEQUENTIALPICKITEM2_CNT_MAX + 1
    end
    for i = startIndex, #framelist do
        local frame = framelist[i]["frame"]
        local lastY = frame:GetUserIValue("LAST_Y")
        local isFirstOpen = frame:GetUserValue("FIRST_OPEN")
		moveY = y - lastY
		if isFirstOpen == "NO" then
			if moveY ~= 0 then
				UI_PLAYFORCE_CUSTOM_MOVE(frame, 0, moveY)
			end
        else
            frame:SetUserValue("FIRST_OPEN", "NO")
            frame:SetMargin(0, y, frame:GetMargin().right, 0)
        end
        frame:SetUserValue("LAST_Y", y)
        y = y + frame:GetHeight()
    end
end