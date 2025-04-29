local s_invSlot
function GODDESSSEALTRADE_ON_INIT(addon, frame)
	addon:RegisterMsg('SUCCESS_TRADE_SEAL', 'GODDESSSEALTRADE_CLOSE');
end

function GODDESSSEALTRADE_OPEN(invItem)
    ui.OpenFrame("inventory")
	local frame = ui.GetFrame("goddesssealtrade")
    local pieceGuid = invItem:GetIESID() 
    frame:SetUserValue("CONSUME_PIECE_GUID", pieceGuid)
    frame:SetUserValue("CONSUME_SEAL_GUID", "0")
    
    local invframe = ui.GetFrame("inventory")
	local tab = GET_CHILD_RECURSIVELY(invframe, "inventype_Tab");
	tolua.cast(tab, "ui::CTabControl");
    tab:SelectTab(1);

    GODDESSSEALTRADE_CLEAR_SLOT(frame)
    INVENTORY_SET_CUSTOM_RBTNDOWN("GODDESSSEALTRADE_INV_BTN");
    GODDESSSEALTRADE_MATERIAL(frame, pieceGuid)
    GODDESSSEALTRADE_RESULTSEAL(frame, pieceGuid)
    frame:ShowWindow(1)
end

function GODDESSSEALTRADE_REG_MAT(frame, invSlot)
    local sealguid = frame:GetUserValue("CONSUME_SEAL_GUID")
    local pieceguid = frame:GetUserValue("CONSUME_PIECE_GUID")

	local sealinvItem = session.GetInvItemByGuid(sealguid);
	if sealinvItem == nil then return end
    
    local pieceinvItem = session.GetInvItemByGuid(pieceguid)
    if pieceinvItem == nil then return end

    local sealObj = GetIES(sealinvItem:GetObject())
    local sealCls = GetClassByType('Item', sealObj.ClassID)
    
    local pieceObj = GetIES(pieceinvItem:GetObject())
    local pieceCls = GetClassByType('Item', pieceObj.ClassID)

    local aObj = GetMyAccountObj();
    

    if GetMyPCObject() == nil then
		return;
    end
    

    local ret, clmsg = shared_item_jurate_seal.is_valid_item(sealObj, pieceObj)
	if ret == false then
		ui.SysMsg(ClMsg(clmsg));
		return;
    end

	local invframe = ui.GetFrame("inventory");
    if true == sealinvItem.isLockState or true == IS_TEMP_LOCK(invframe, sealinvItem) then
		ui.SysMsg(ClMsg("MaterialItemIsLock"));
		return;
    end
    
    local slot = GET_CHILD_RECURSIVELY(frame, 'mat_slot');
    SET_SLOT_ITEM(slot, sealinvItem);
    invSlot:SetSelectedImage('socket_slot_check')
    invSlot:Select(1)
    if s_invSlot ~= nil then
        s_invSlot:Select(0)
    end
    s_invSlot = invSlot

    session.ResetItemList()
    session.AddItemID(pieceguid)
    session.AddItemID(sealguid)

    if TryGetProp(sealObj, 'CharacterBelonging', 0) == 1 then
        local resultSlot = GET_CHILD_RECURSIVELY(frame, "result_slot")
        local icon = resultSlot:GetIcon()
        icon:SetTooltipStrArg('char_belonging')
        ui.SysMsg(ClMsg("WarningSealTeamBelonging"));
    elseif TryGetProp(sealObj, 'TeamBelonging', 0) == 1 then
        local resultSlot = GET_CHILD_RECURSIVELY(frame, "result_slot")
        local icon = resultSlot:GetIcon()
        icon:SetTooltipStrArg('team_belonging')
        ui.SysMsg(ClMsg("WarningSealTeamBelonging"));
    else
        local resultSlot = GET_CHILD_RECURSIVELY(frame, "result_slot")
        local icon = resultSlot:GetIcon()
        icon:SetTooltipStrArg('None')
    end    
end

function GODDESSSEALTRADE_INV_BTN(itemObj, slot)
    local frame = ui.GetFrame("goddesssealtrade")
    frame:SetUserValue("CONSUME_SEAL_GUID", GetIESID(itemObj))
    if slot:IsSelected() == 1 then
        slot:Select(0)
        GODDESSSEALTRADE_CLEAR_SLOT(frame)
    else
        GODDESSSEALTRADE_REG_MAT(frame, slot)
    end
end

function GODDESSSEALTRADE_ITEM_DROP(parent, self, argStr, argNum)
    local liftIcon = ui.GetLiftIcon()
    local slot = liftIcon:GetParent()
	local FromFrame = liftIcon:GetTopParentFrame();
    if FromFrame:GetName() == 'inventory' then
        local iconInfo = liftIcon:GetInfo();
        local frame = ui.GetFrame("goddesssealtrade")
        frame:SetUserValue("CONSUME_SEAL_GUID", iconInfo:GetIESID())
		GODDESSSEALTRADE_REG_MAT(frame, slot)
	end
end

function GODDESSSEALTRADE_MATERIAL(frame, guid)
    local invitem = session.GetInvItemByGuid(guid)
    if invitem == nil then return end
    invitem = GetIES(invitem:GetObject())
	local pc = GetMyPCObject()
    local matGbox = GET_CHILD_RECURSIVELY(frame, "mat_gbox")
    local pieceName = TryGetProp(invitem, "ClassName")
    local pieceCnt = tonumber(shared_item_jurate_seal.get_piece_count(invitem))

    local coinList, isValid = shared_item_jurate_seal.get_cost(invitem)
    if isValid == false then
        return
    end

    local matSealText = GET_CHILD_RECURSIVELY(frame, "mat_item_name")
    matSealText:SetTextByKey("name", shared_item_jurate_seal.get_consume_seal_name(invitem))

    coinList[pieceName] = pieceCnt
    matGbox:RemoveAllChild()
	local index = 1;
    for k,v in pairs(coinList) do
		local ctrlSet = matGbox:CreateOrGetControlSet("eachmaterial_in_item_cabinet", "SEALTRADE_MAT"..index, 0, (index - 1) * 40);
		if ctrlSet ~= nil then
			local icon = GET_CHILD_RECURSIVELY(ctrlSet, "material_icon", "ui::CPicture");
			local questionmark = GET_CHILD_RECURSIVELY(ctrlSet, "material_questionmark", "ui::CPicture");
			local name = GET_CHILD_RECURSIVELY(ctrlSet, "material_name", "ui::CRichText");
			local count = GET_CHILD_RECURSIVELY(ctrlSet, "material_count", "ui::CRichText");
			local grade = GET_CHILD_RECURSIVELY(ctrlSet, "grade", "ui::CRichText");
			icon:ShowWindow(1);
			count:ShowWindow(1);
            questionmark:ShowWindow(0);

            local curCount = '0'
            local itemName = "None"
            local iconName = "None"
            local materialCls = GetClass("Item", k);
            if materialCls ~= nil and v > 0 then
                curCount = tostring(GetInvItemCount(pc, k))
                iconName = materialCls.Icon
                itemName = materialCls.Name
            elseif materialCls == nil and v > 0 then
                local aObj = GetMyAccountObj()
                curCount = TryGetProp(aObj, k, '0');
				if curCount == "None" then
					curCount = '0'
                end
				local coinCls = GetClass("accountprop_inventory_list", k);
                iconName = coinCls.Icon
                itemName = ClMsg(k)
            end

            if math.is_larger_than(v, curCount) == 1 then
                count:SetTextByKey("color", "{#EE0000}");
            else
                count:SetTextByKey("color", nil);		
                curCount = v
            end
            count:SetTextByKey("curCount", GET_COMMAED_STRING(curCount));
            count:SetTextByKey("needCount", GET_COMMAED_STRING(v))
            name:SetText(itemName)            
            icon:SetImage(iconName)

            if TryGetProp(materialCls, 'StarIcon', 'None') ~= 'None' then
                local grade = GET_CHILD(ctrlSet, "grade")
                local name = string.format("{img %s 16 16}", TryGetProp(materialCls, 'StarIcon', 'None'))
                grade:SetText(name)
            end

			index = index + 1;
        end
    end
end

function GODDESSSEALTRADE_RESULTSEAL(frame, guid)    
    local invitem = session.GetInvItemByGuid(guid)
    if invitem == nil then return end

    invitem = GetIES(invitem:GetObject())
    local sealCls = shared_item_jurate_seal.get_seal_cls(invitem)
    if sealCls == nil then return end

    local resultSlot = GET_CHILD_RECURSIVELY(frame, "result_slot")
	local icon = CreateIcon(resultSlot);
	icon:SetImage(TryGetProp(sealCls, 'Icon'));
	icon:ClearText()

    icon:SetTooltipNumArg(sealCls.ClassID);
    icon:SetTooltipType('wholeitem');
    icon:SetTooltipStrArg('None')

    local resultSealText = GET_CHILD_RECURSIVELY(frame, "result_item_name")
    resultSealText:SetTextByKey("name", sealCls.Name)
end

function GODDESSSEALTRADE_CLEAR_SLOT(parent)
    local frame = parent:GetTopParentFrame();
    local slot = GET_CHILD_RECURSIVELY(frame, "mat_slot")
    slot:ClearIcon();
    if s_invSlot ~= nil then
        s_invSlot:Select(0)
    end
    session.ResetItemList()
    frame:SetUserValue("CONSUME_SEAL_GUID", '0')
end

function GODDESSSEALTRADE_REQ_TRADE(parent)
    local arglist = NewStringList()     
    local resultlist = session.GetItemIDList()
    item.DialogTransaction('INHERITANCE_SEAL', resultlist, '', arglist)
end

function GODDESSSEALTRADE_CLOSE(frame)
    frame:ShowWindow(0)
    if s_invSlot ~= nil then
        s_invSlot:Select(0)
    end
    INVENTORY_SET_CUSTOM_RBTNDOWN("None");
end
