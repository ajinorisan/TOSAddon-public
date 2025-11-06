-- itembuffopen.lua

function ITEMBUFFOPEN_ON_INIT(addon, frame)
end

local enable_slot_list = {
	'RH', 'LH', 'RH_SUB', 'LH_SUB', 'SHIRT', 'PANTS', 'GLOVES', 'BOOTS',
}

local function _GET_SOCKET_ADD_VALUE(item, invItem, i)
    if invItem:IsAvailableSocket(i) == false then
        return
	end
	
	local gem = invItem:GetEquipGemID(i)
    if gem == 0 then
        return
    end
    
	local gemExp = invItem:GetEquipGemExp(i)
	local roastingLv = invItem:GetEquipGemRoastingLv(i)
    local props = {}
    local gemclass = GetClassByType("Item", gem)
    local lv = GET_ITEM_LEVEL_EXP(gemclass, gemExp)
    local prop = geItemTable.GetProp(gem)
    local socketProp = prop:GetSocketPropertyByLevel(lv)
    local type = item.ClassID
    local benefitCnt = socketProp:GetPropCountByType(type)
    for i = 0 , benefitCnt - 1 do
        local benefitProp = socketProp:GetPropAddByType(type, i)
        props[#props + 1] = {benefitProp:GetPropName(), benefitProp.value}
    end
    
    local penaltyCnt = socketProp:GetPropPenaltyCountByType(type)
    local penaltyLv = lv - roastingLv
    if 0 > penaltyLv then
        penaltyLv = 0
    end
    local socketPenaltyProp = prop:GetSocketPropertyByLevel(penaltyLv)
    for i = 0 , penaltyCnt - 1 do
        local penaltyProp = socketPenaltyProp:GetPropPenaltyAddByType(type, i)
        local value = penaltyProp.value
        penaltyProp:GetPropName()
        props[#props + 1] = {penaltyProp:GetPropName(), penaltyProp.value}
    end
    return props
end

local function _GET_ITEM_SOCKET_ADD_VALUE(targetPropName, item)
	local invItem, where = GET_INV_ITEM_BY_ITEM_OBJ(item)
	if invItem == nil then
		return 0
	end

    local value = 0
    local sockets = {}
    if item.MaxSocket > 100 then item.MaxSocket = 0 end
    for i=0, item.MaxSocket - 1 do
        sockets[#sockets + 1] = _GET_SOCKET_ADD_VALUE(item, invItem, i)
    end

    for i = 1, #sockets do
        local props = sockets[i]
        for j = 1, #props do
            local prop = props[j]
            if prop[1] == targetPropName or ( (prop[1] == "PATK") and (targetPropName == "ATK")) then                
                value = value + prop[2]
            end
        end
    end
    return value
end

local function SQUIRE_BUFF_ENABLE_ITEM_CHECK(frame, inv_item, item_obj)
	if inv_item == nil or item_obj == nil then
		return false
	end

	if IS_NO_EQUIPITEM(item_obj) == 1 then
		return false
	end

	if TryGetProp(item_obj, 'Dur', 0) <= 0 then
		-- ui.SysMsg(ClMsg("DurUnder0"))
		return false
	end

	local checkItem = _G["ITEMBUFF_CHECK_" .. frame:GetUserValue("SKILLNAME")]
	if 1 ~= checkItem(pc, item_obj) then
		-- ui.SysMsg(ClMsg("WrongDropItem"))
		return false
	end

	return true
end

local function MAKE_SQUIRE_BUFF_CTRL_OPTION(frame, gbox, inv_item, item_obj)
	local pc = GetMyPCObject()
	local checkFunc = _G["ITEMBUFF_NEEDITEM_" .. frame:GetUserValue("SKILLNAME")]
	local name, cnt = checkFunc(pc, item_obj)

	local skillLevel = frame:GetUserIValue("SKILLLEVEL")
	local valueFunc = _G["ITEMBUFF_VALUE_" .. frame:GetUserValue("SKILLNAME")]
	local value, validSec = valueFunc(pc, item_obj, skillLevel)

	local parentbox = gbox:GetParent()
	local time = GET_CHILD_RECURSIVELY(parentbox, 'time')
	time:ShowWindow(1)
	local timestr = GET_CHILD_RECURSIVELY(parentbox, "timestr")
	timestr:ShowWindow(1)
	timestr:SetTextByKey("txt", string.format("{img %s %d %d}", "squaier_buff", 25, 25) .." " .. validSec / 3600 .. ClMsg("QuestReenterTimeH"))

	local nextObj = CloneIES(item_obj)
	nextObj.BuffValue = value
	local refreshScp = nextObj.RefreshScp
	if refreshScp ~= "None" then
		refreshScp = _G[refreshScp]
		refreshScp(nextObj)
	end

    local basicPropList = StringSplit(item_obj.BasicTooltipProp, ';')
    for i = 1 , #basicPropList do
        local basicTooltipProp = basicPropList[i]
        local propertyCtrl = gbox:CreateOrGetControlSet('basic_property_set_narrow', 'BASIC_PROP_' .. i, 5, 0)

	    -- 최대, 최소를 작성하고자 해당 항목의 속성을 가지고 옵니다.
	    local mintextStr = GET_CHILD(propertyCtrl, "minPowerStr")
	    local maxtextStr = GET_CHILD(propertyCtrl, "maxPowerStr")
        local maxtext = GET_CHILD(propertyCtrl, "maxPower")
	    local mintext = GET_CHILD(propertyCtrl, "minPower")
	
	    local prop1, prop2 = GET_ITEM_PROPERT_STR(item_obj, basicTooltipProp)
        if basicTooltipProp ~= "ATK" then
            local temp = prop1
            prop1 = prop2
            prop2 = temp
        end

	    maxtextStr:SetTextByKey("txt", prop1)
	    mintextStr:SetTextByKey("txt", prop2)

	    if item_obj.GroupName == "Weapon" or item_obj.GroupName == "SubWeapon" then
		    if basicTooltipProp == "ATK" then -- 최대, 최소 공격력
				local socketaddvalue =  _GET_ITEM_SOCKET_ADD_VALUE(basicTooltipProp, item_obj)
			    maxtext:SetTextByKey("txt", item_obj.MAXATK + socketaddvalue .." > ".. nextObj.MAXATK + socketaddvalue)
			    mintext:SetTextByKey("txt", item_obj.MINATK + socketaddvalue .." > ".. nextObj.MINATK + socketaddvalue)
			elseif basicTooltipProp == "MATK" then -- 마법공격력
				local socketaddvalue =  _GET_ITEM_SOCKET_ADD_VALUE(basicTooltipProp, item_obj)
			    mintext:SetTextByKey("txt", item_obj.MATK - socketaddvalue .." > ".. nextObj.MATK + socketaddvalue)
			    maxtext:SetTextByKey("txt", "")
                propertyCtrl:Resize(propertyCtrl:GetWidth(), mintext:GetHeight())
		    end
	    else
			if basicTooltipProp == "DEF" then -- 방어
				local socketaddvalue =  _GET_ITEM_SOCKET_ADD_VALUE(basicTooltipProp, item_obj)
			    mintext:SetTextByKey("txt", item_obj.DEF - socketaddvalue  .." > ".. nextObj.DEF + socketaddvalue)
			elseif basicTooltipProp == "MDEF" then -- 악세사리
				local socketaddvalue =  _GET_ITEM_SOCKET_ADD_VALUE(basicTooltipProp, item_obj)
			    mintext:SetTextByKey("txt", item_obj.MDEF - socketaddvalue .." > ".. nextObj.MDEF + socketaddvalue)
		    elseif  basicTooltipProp == "HR" then -- 명중
			    mintext:SetTextByKey("txt", item_obj.HR .." > ".. nextObj.HR)
		    elseif  basicTooltipProp == "DR" then -- 회피
			    mintext:SetTextByKey("txt", item_obj.DR .." > ".. nextObj.DR)
		    elseif  basicTooltipProp == "CRTMATK" then -- 마법관통
			    mintext:SetTextByKey("txt", item_obj.CRTMATK .." > ".. nextObj.CRTMATK)
		    elseif  basicTooltipProp == "ADD_FIRE" then -- 화염
			    mintext:SetTextByKey("txt", item_obj.FIRE .." > ".. nextObj.FIRE)
		    elseif  basicTooltipProp == "ADD_ICE" then -- 빙한
			    mintext:SetTextByKey("txt", item_obj.ICE .." > ".. nextObj.ICE)
		    elseif  basicTooltipProp == "ADD_LIGHTNING" then -- 전격
			    mintext:SetTextByKey("txt", item_obj.LIGHTNING .." > ".. nextObj.LIGHTNING)
			end
			
		    maxtext:SetTextByKey("txt", "")
            propertyCtrl:Resize(propertyCtrl:GetWidth(), mintext:GetHeight())
	    end
	end
	
    GBOX_AUTO_ALIGN(gbox, 5, 2, 0, true, false, true)
	DestroyIES(nextObj)
end

function SQUIRE_BUFF_EQUIP_CTRL(frame)
	local checkall = GET_CHILD_RECURSIVELY(frame, 'checkall')
	checkall:SetCheck(0)

	local ctrlGbox = GET_CHILD_RECURSIVELY(frame, 'ctrlGbox')
	ctrlGbox:RemoveAllChild()

	local index = 0
	for i = 1, #enable_slot_list do
		local slot_name = enable_slot_list[i]
		local inv_item = session.GetEquipItemBySpot(item.GetEquipSpotNum(slot_name))
		if inv_item ~= nil then
			local item_obj = GetIES(inv_item:GetObject())
			if SQUIRE_BUFF_ENABLE_ITEM_CHECK(frame, inv_item, item_obj) == true then
				local ctrl_height = ui.GetControlSetAttribute('itembuff_ctrlset', 'height')
				local ctrlset = ctrlGbox:CreateOrGetControlSet('itembuff_ctrlset', 'ITEMBUFF_CTRL_' .. slot_name, 2, ctrl_height * index)

				if ctrlset ~= nil then
					local slot = GET_CHILD(ctrlset, 'slot')
					SET_SLOT_ITEM(slot, inv_item)
					slot:SetUserValue('ITEM_GUID', inv_item:GetIESID())
					slot:SetUserValue('ITEM_SLOT', slot_name)
	
					local item_name = GET_CHILD(ctrlset, 'item_name')
					item_name:SetTextByKey('name', dic.getTranslatedStr(TryGetProp(item_obj, 'Name', 'NONE')))
	
					local checkbox = GET_CHILD(ctrlset, 'checkbox')
					checkbox:SetCheck(0)

					local time = GET_CHILD_RECURSIVELY(ctrlset, 'time')
					time:ShowWindow(0)
					local timestr = GET_CHILD_RECURSIVELY(ctrlset, 'timestr')
					timestr:ShowWindow(0)
	
					index = index + 1
				end
			end
		end
	end

	SQUIRE_BUFF_COST_UPDATE(frame)
end

function SQUIRE_TARGET_UI_CLOSE()
	ui.CloseFrame("itembuffopen")
end

function SQUIRE_TARGET_BUFF_CANCEL(sellerHandle)
	packet.StopTimeAction(1)
end

function SQUIRE_BUFF_CANCEL_CHECK(frame)
	frame = frame:GetTopParentFrame()
	local handle = frame:GetUserIValue("HANDLE")
	local skillName = frame:GetUserValue("SKILLNAME")

	-- 그럼 이것은 판매자
	if handle == session.GetMyHandle() then
		if "Squire_Repair" == skillName then
			SQUIRE_REPAIR_CANCEL()
			return
		end
	end

	-- 유저
	session.autoSeller.BuyerClose(AUTO_SELL_SQUIRE_BUFF, handle)
end

function SQUIRE_UI_RESET(frame)
	local materialtext = GET_CHILD_RECURSIVELY(frame, "reqitemNeedCount")
	materialtext:SetTextByKey("txt", "")

	local checkall = GET_CHILD_RECURSIVELY(frame, 'checkall')
	checkall:SetCheck(0)
	SQUIRE_BUFF_EQUIP_SELECT_ALL(frame, checkall)
end

function SQUIRE_BUFF_EXCUTE(parent, ctrl)
	local frame = parent:GetTopParentFrame()
	local handle = frame:GetUserValue("HANDLE")
	local skillName = frame:GetUserValue("SKILLNAME")
	
	session.ResetItemList()

	local cnt = 0
	for i = 1, #enable_slot_list do
		local slot_name = enable_slot_list[i]
		local ctrlset = GET_CHILD_RECURSIVELY(frame, 'ITEMBUFF_CTRL_' .. slot_name)
		if ctrlset ~= nil then
			local checkbox = GET_CHILD(ctrlset, 'checkbox')
			if checkbox:IsChecked() == 1 then
				local inv_item = session.GetEquipItemBySpot(item.GetEquipSpotNum(slot_name))
				if inv_item ~= nil then
					session.AddItemID(inv_item:GetIESID())
					cnt = cnt + 1
				end
			end
		end
	end

	if cnt <= 0 then
		ui.MsgBox(ScpArgMsg("SelectBuffItemPlz"))
		return
	end

	session.autoSeller.BuyItems(handle, AUTO_SELL_SQUIRE_BUFF, session.GetItemIDList(), skillName)
end

function SQUIRE_TAB_CHANGE(frame)
	local itembox_tab = GET_CHILD_RECURSIVELY(frame, 'statusTab')
	if nil ~= itembox_tab then
		local curtabIndex = itembox_tab:GetSelectItemIndex()
		if curtabIndex == 0 then
			SQUIRE_BUFF_VIEW(frame)
		elseif curtabIndex == 1 then
			SQUIRE_LOG_VIEW(frame)
		end
	end
end

function SQUIRE_BUFF_VIEW(frame)
	local gboxctrl = GET_CHILD_RECURSIVELY(frame, "repair")
	gboxctrl:ShowWindow(1)
	
	if frame:GetName() == "itembuffopen" then
		SQUIRE_BUFF_EQUIP_CTRL(frame)
	end

	local gboxctrl = GET_CHILD_RECURSIVELY(frame, "log")
	gboxctrl:ShowWindow(0)
end

function SQUIRE_LOG_VIEW(frame)
	local gboxctrl = GET_CHILD_RECURSIVELY(frame, "repair")
	gboxctrl:ShowWindow(0)

	local gboxctrl = GET_CHILD_RECURSIVELY(frame, "log")
	gboxctrl:ShowWindow(1)
end

function SQUIRE_BUFF_CLOSE(frame)
	frame = frame:GetTopParentFrame()
	local groupName = frame:GetUserValue("GroupName")
	local groupInfo = session.autoSeller.GetByIndex(groupName, 0)
	if groupInfo == nil then
		return
	end
	
	session.autoSeller.Close(groupName)
	frame:ShowWindow(0)
end

function SQUIRE_UPDATE_MATERIAL(frame, cnt, guid)
	local reqitemtext = GET_CHILD_RECURSIVELY(frame, "reqitemCount")
	local reqitemName = GET_CHILD_RECURSIVELY(frame, "reqitemNameStr")
	local reqitemImage = GET_CHILD_RECURSIVELY(frame, "reqitemImage")
	local reqitemNeed = GET_CHILD_RECURSIVELY(frame, "reqitemNeedCount")

	local invItemList = session.GetInvItemList()
	local checkFunc = _G["ITEMBUFF_STONECOUNT_" .. frame:GetUserValue("SKILLNAME")]
	local name, cnt2 = checkFunc(invItemList)
	local cls = GetClass("Item", name)
	reqitemImage:SetTextByKey("txt", GET_ITEM_IMG_BY_CLS(cls, 50))
	local txt = cls.Name
	reqitemName:SetTextByKey("txt", txt)
	local text = cnt2 .. " " .. ClMsg("CountOfThings")
	reqitemtext:SetTextByKey("txt", text)
	
	if nil ~= cnt then
		reqitemNeed:SetTextByKey("txt", cnt .. ClMsg("CountOfThings"))
	else
		reqitemNeed:SetTextByKey("txt", "")
	end

	if nil ~= guid then
		reqitemImage:SetTextByKey("guid", guid)
	else
		reqitemImage:SetTextByKey("guid", "")
	end

	local imoney = frame:GetUserIValue("PRICE")
	if session.GetMyHandle() == frame:GetUserIValue("HANDLE") then
		local money = GET_CHILD_RECURSIVELY(frame, "reqitemMoney")
		money:SetTextByKey("txt", 0)
	end
end

function SQUIRE_ITEM_SUCCEED()
	local frame = ui.GetFrame("itembuffopen")
	local handle = frame:GetUserValue("HANDLE")
	SQUIRE_UPDATE_MATERIAL(frame)
	SQUIRE_UI_RESET(frame)
end

function ITEMBUFF_UPDATE_HISTORY(frame)
	local groupName = frame:GetUserValue("GroupName")
	local cnt = session.autoSeller.GetHistoryCount(groupName)

	local log_gbox = GET_CHILD_RECURSIVELY(frame, "log_gbox")
	log_gbox:RemoveAllChild()

	for i = cnt -1 , 0, -1 do
		local info = session.autoSeller.GetHistoryByIndex(groupName, i)
		local ctrlSet = log_gbox:CreateControlSet("squire_history", "CTRLSET_" .. i,  ui.CENTER_HORZ, ui.TOP, 0, 0, 0, 0)
		local sList = StringSplit(info:GetHistoryStr(), "#")
		local itemClsID = sList[2]
		local itemCls = GetClassByType("Item", itemClsID)

		local UserName = ctrlSet:GetChild("userName")
		UserName:SetTextByKey("value", sList[1] .. ClMsg("ItemBuff"))

		local itemname = ctrlSet:GetChild("itemName")
		itemname:SetTextByKey("value", itemCls.Name)
		
	    local propValues = sList[3]
	    local propToken = StringSplit(propValues, "@")
        
		local propStr = ""
        local tokenIndex = 1
        for i = 1, #propToken do
            if i == tokenIndex then
                local propertyClMsg = ""
                local token = propToken[i]
                if token == 'MATK' then
                    propertyClMsg = ClMsg('Magic_Atk')
                else
                    propertyClMsg = ClMsg(token)
                end
			    local strBuf = string.format("%s %s -> %s", propertyClMsg , propToken[i+1], propToken[i+2])
			    if i > 3 then
				    propStr = propStr .. "{nl}"
			    end
			    propStr = propStr .. strBuf
                tokenIndex = tokenIndex + 3
            end
		end
	    local property = ctrlSet:GetChild("Property")
	    property:SetTextByKey("value", propStr)
    end

	GBOX_AUTO_ALIGN(log_gbox, 20, 3, 10, true, false)
end

function SQUIRE_BUFF_COST_UPDATE(frame)
	local pc = GetMyPCObject()
	local cnt = 0
	for i = 1, #enable_slot_list do
		local slot_name = enable_slot_list[i]
		local ctrlset = GET_CHILD_RECURSIVELY(frame, 'ITEMBUFF_CTRL_' .. slot_name)
		if ctrlset ~= nil then
			local checkbox = GET_CHILD(ctrlset, 'checkbox')
			if checkbox:IsChecked() == 1 then
				local inv_item = session.GetEquipItemBySpot(item.GetEquipSpotNum(slot_name))
				local item_obj = GetIES(inv_item:GetObject())
				local checkFunc = _G["ITEMBUFF_NEEDITEM_" .. frame:GetUserValue("SKILLNAME")]
				local _name, _cnt = checkFunc(pc, item_obj)
				cnt = cnt + _cnt
			end
		end
	end

	SQUIRE_UPDATE_MATERIAL(frame, cnt, nil)
	
	local imoney = frame:GetUserIValue("PRICE")
	local money = GET_CHILD_RECURSIVELY(frame, "reqitemMoney")
	if session.GetMyHandle() ~= frame:GetUserIValue("HANDLE") then
		money:SetTextByKey("txt", imoney * cnt)
	else
	    money:SetTextByKey("txt", 0)
	end
end

function SQUIRE_BUFF_EQUIP_SELECT(parent, ctrl, arg_str, arg_num, by_checkall)
	if by_checkall == nil then
		by_checkall = false
	end

	local frame = parent:GetTopParentFrame()
	local gbox = GET_CHILD_RECURSIVELY(parent, 'optionGbox_1')
	gbox:RemoveAllChild()

	if ctrl:IsChecked() == 1 then
		local slot = GET_CHILD(parent, 'slot')
		local slot_name = slot:GetUserValue('ITEM_SLOT')
		local inv_item = session.GetEquipItemBySpot(item.GetEquipSpotNum(slot_name))
		if inv_item == nil then
			ctrl:SetCheck(0)
			return
		end

		local item_obj = GetIES(inv_item:GetObject())
		MAKE_SQUIRE_BUFF_CTRL_OPTION(frame, gbox, inv_item, item_obj)
	else
		local time = GET_CHILD_RECURSIVELY(parent, 'time')
		time:ShowWindow(0)
		local timestr = GET_CHILD_RECURSIVELY(parent, 'timestr')
		timestr:ShowWindow(0)
	end
	
	if by_checkall == false then
		SQUIRE_BUFF_COST_UPDATE(frame)
	end
end

function SQUIRE_BUFF_EQUIP_SELECT_ALL(parent, ctrl)
	local frame = parent:GetTopParentFrame()
	for i = 1, #enable_slot_list do
		local slot_name = enable_slot_list[i]
		local ctrlset = GET_CHILD_RECURSIVELY(frame, 'ITEMBUFF_CTRL_' .. slot_name)
		if ctrlset ~= nil then
			local checkbox = GET_CHILD(ctrlset, 'checkbox')
			checkbox:SetCheck(ctrl:IsChecked())
			SQUIRE_BUFF_EQUIP_SELECT(ctrlset, checkbox, '', 0, true)
		end
	end

	SQUIRE_BUFF_COST_UPDATE(frame)
end