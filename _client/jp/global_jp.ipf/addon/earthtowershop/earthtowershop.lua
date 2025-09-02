function REQ_EVENT_ITEM_SHOP6_1_OPEN()
	local frame = ui.GetFrame("earthtowershop");
	frame:SetUserValue("SHOP_TYPE", 'EventShop6_1');
	ui.OpenFrame('earthtowershop');
end

function REQ_EVENT_ITEM_SHOP6_2_OPEN()
	local frame = ui.GetFrame("earthtowershop");
	frame:SetUserValue("SHOP_TYPE", 'EventShop6_2');
	ui.OpenFrame('earthtowershop');
end

function REQ_EVENT_ITEM_SHOP6_3_OPEN()
	local frame = ui.GetFrame("earthtowershop");
	frame:SetUserValue("SHOP_TYPE", 'EventShop6_3');
	ui.OpenFrame('earthtowershop');
end

function REQ_EVENT_ITEM_SHOP6_4_OPEN()
	local frame = ui.GetFrame("earthtowershop");
	frame:SetUserValue("SHOP_TYPE", 'EventShop6_4');
	ui.OpenFrame('earthtowershop');
end

function REQ_EVENT_ITEM_SHOP6_5_OPEN()
	local frame = ui.GetFrame("earthtowershop");
	frame:SetUserValue("SHOP_TYPE", 'EventShop6_5');
	ui.OpenFrame('earthtowershop');
end

function REQ_EVENT_ITEM_SHOP7_OPEN()
	local frame = ui.GetFrame("earthtowershop");
	frame:SetUserValue("SHOP_TYPE", 'EventShop7');
	ui.OpenFrame('earthtowershop');
end

function REQ_EVENT_ITEM_SHOP8_OPEN()
	local frame = ui.GetFrame("earthtowershop");
	frame:SetUserValue("SHOP_TYPE", 'EventShop8');
	ui.OpenFrame('earthtowershop');
end

function EARTH_TOWER_SHOP_TRADE_ENTER()
    local frame = g_earth_shop_local_parent:GetTopParentFrame();
	if frame:GetName() == 'legend_craft' then
        LEGEND_CRAFT_EXECUTE(g_earth_shop_local_parent, g_earth_shop_local_control);
		return;
	end
    local parentcset = g_earth_shop_local_control:GetParent()
    local frame = g_earth_shop_local_control:GetTopParentFrame(); 
    if frame:GetName() == 'legend_craft' then
       LEGEND_CRAFT_EXECUTE(g_earth_shop_local_parent, g_earth_shop_local_control);
       return;
   end
	
	local cnt = parentcset:GetChildCount();
	for i = 0, cnt - 1 do
		local eachcset = parentcset:GetChildByIndex(i);		
		if string.find(eachcset:GetName(),'EACHMATERIALITEM_') ~= nil then
			local selected = eachcset:GetUserValue("MATERIAL_IS_SELECTED")
			if selected ~= 'selected' then
				ui.AddText("SystemMsgFrame", ScpArgMsg('NotEnoughRecipe'));
				return;
			end
		end
	end

	local resultlist = session.GetItemIDList();
	local someflag = 0
	for i = 0, resultlist:Count() - 1 do
		local tempitem = resultlist:PtrAt(i);

		if IS_VALUEABLE_ITEM(tempitem.ItemID) == 1 then
			someflag = 1
		end
	end

	session.ResetItemList();

    local pc = GetMyPCObject();
    if pc == nil then
        return;
    end

	local recipeCls = GetClass("ItemTradeShop", parentcset:GetName())
	for index=1, 5 do
		local clsName = "Item_"..index.."_1";
		local itemName = recipeCls[clsName];
        local recipeItemCnt, invItemCnt, dragRecipeItem, invItem, recipeItemLv, invItemlist = GET_RECIPE_MATERIAL_INFO(recipeCls, index);

        if dragRecipeItem ~= nil then
            local itemCount = GET_TOTAL_ITEM_CNT(dragRecipeItem.ClassID);
            if itemCount < recipeItemCnt then
                ui.AddText("SystemMsgFrame", ScpArgMsg('NotEnoughRecipe'));
                break;
            end
        end

		local invItem = session.GetInvItemByName(itemName);
		if "None" ~= itemName then
			if nil == invItem then
				ui.AddText("SystemMsgFrame", ClMsg('NotEnoughRecipe'));
				return;
			else
				if true == invItem.isLockState then
					ui.SysMsg(ClMsg("MaterialItemIsLock"));
					return;
				end
				session.AddItemID(invItem:GetIESID(), recipeItemCnt);
			end
		end
	end

	local resultlist = session.GetItemIDList();
	local cntText = string.format("%s %s", recipeCls.ClassID, 1);
	
    local edit_itemcount = GET_CHILD_RECURSIVELY(parentcset, "itemcount");
    if edit_itemcount == nil then 
        return; 
    end

    local itemCountGBox = GET_CHILD_RECURSIVELY(parentcset, "gbox");
    local resultCount = tonumber(edit_itemcount:GetText());
    if itemCountGBox:IsVisible() == 0 then
        resultCount = 1;
    end
    cntText = string.format("%s %s", recipeCls.ClassID, resultCount);
	local shopType = frame:GetUserValue("SHOP_TYPE");
	if shopType == 'EarthTower' then
		item.DialogTransaction("EARTH_TOWER_SHOP_TREAD", resultlist, cntText);
	elseif shopType == 'EarthTower2' then
		item.DialogTransaction("EARTH_TOWER_SHOP_TREAD2", resultlist, cntText);
	elseif shopType == 'EventShop' then
		item.DialogTransaction("EVENT_ITEM_SHOP_TREAD", resultlist, cntText);
	elseif shopType == 'EventShop2' then
		item.DialogTransaction("EVENT_ITEM_SHOP_TREAD2", resultlist, cntText);
	elseif shopType == 'EventShop6_1' then
		item.DialogTransaction("EVENT_ITEM_SHOP_TREAD6_1", resultlist, cntText);
	elseif shopType == 'EventShop6_2' then
		item.DialogTransaction("EVENT_ITEM_SHOP_TREAD6_2", resultlist, cntText);
	elseif shopType == 'EventShop6_3' then
		item.DialogTransaction("EVENT_ITEM_SHOP_TREAD6_3", resultlist, cntText);
	elseif shopType == 'EventShop6_4' then
		item.DialogTransaction("EVENT_ITEM_SHOP_TREAD6_4", resultlist, cntText);
	elseif shopType == 'EventShop6_5' then
		item.DialogTransaction("EVENT_ITEM_SHOP_TREAD6_5", resultlist, cntText);
	elseif shopType == 'EventShop8' then
		item.DialogTransaction("EVENT_ITEM_SHOP_TREAD8", resultlist, cntText);
	elseif shopType == 'KeyQuestShop1' then
		item.DialogTransaction("KEYQUESTSHOP1_SHOP_TREAD", resultlist, cntText);
	elseif shopType == 'KeyQuestShop2' then
		item.DialogTransaction("KEYQUESTSHOP2_SHOP_TREAD", resultlist, cntText);
	elseif shopType == 'HALLOWEEN' then
		item.DialogTransaction("HALLOWEEN_SHOP_TREAD", resultlist, cntText);
	elseif shopType == 'EventShop3' then
		item.DialogTransaction("EVENT_ITEM_SHOP_TREAD3", resultlist, cntText);	
	elseif shopType == 'EventShop4' then
		item.DialogTransaction("EVENT_ITEM_SHOP_TREAD4", resultlist, cntText);
	elseif shopType == 'EventShop7' then
		item.DialogTransaction("EVENT_ITEM_SHOP_TREAD7", resultlist, cntText);
	elseif shopType == 'PVPMine' then
		item.DialogTransaction("PVP_MINE_SHOP", resultlist, cntText);
	elseif shopType == 'MCShop1' then
		item.DialogTransaction("MASSIVE_CONTENTS_SHOP_TREAD1", resultlist, cntText);
	elseif shopType == 'DailyRewardShop' then
		item.DialogTransaction("DAILY_REWARD_SHOP_1_TREAD1", resultlist, cntText);
    elseif shopType == 'Bernice' then
        item.DialogTransaction("SoloDungeon_Bernice_SHOP", resultlist, cntText);
    elseif shopType == 'SproutShop' then
        item.DialogTransaction("SPROUT_SHOP_1_TREAD1", resultlist, cntText);
	elseif shopType == 'VividCity2_Shop' then
        item.DialogTransaction("EVENT_VIVID_CITY2_SHOP_1_TREAD1", resultlist, cntText);
    elseif shopType == 'EventTotalShop1906' then
        item.DialogTransaction("EVENT_1906_TOTAL_SHOP_1_TREAD1", resultlist, cntText);
    end
end