local PreviewItemList = nil;
function PREVIEW_SILVERGACHA_SHOP_OPEN()
    local topFrame = ui.GetFrame("beautyshop");
	if topFrame == nil then
		return
	end
	
	local shopName = ClMsg("PREVIEW_SILVERGACHA");
	BEAUTYSHOP_SET_TITLE(shopName);
	topFrame:ShowWindow(1);
	PREVIEW_SILVERGACHA_SHOP_INIT_FUNCTIONMAP();
	PREVIEW_SILVERGACHA_SHOP_GET_SHOP_ITEM_LIST();
end

function PREVIEW_SILVERGACHA_SHOP_INIT_FUNCTIONMAP()
	beautyShopInfo.functionMap["UPDATE_SUB_ITEMLIST"] = nil
	beautyShopInfo.functionMap["DRAW_ITEM_DETAIL"] = PREVIEW_SILVERGACHA_SHOP_DRAW_ITEM_DETAIL
	beautyShopInfo.functionMap["POST_SELECT_ITEM"] = PREVIEW_SILVERGACHA_SHOP_POST_SELECT_ITEM
	beautyShopInfo.functionMap["SELECT_SUBITEM"]= nil
	beautyShopInfo.functionMap["POST_ITEM_TO_BASKET"] = nil
	beautyShopInfo.functionMap["POST_BASKETSLOT_REMOVE"] = nil
end

function PREVIEW_SILVERGACHA_SHOP_GET_SHOP_ITEM_LIST()
	PREVIEW_SILVERGACHA_SHOP_MAKE_ITEMLIST();
end

function PREVIEW_SILVERGACHA_SHOP_REGISTER_ITEM_CREATE_LIST()
	if PreviewItemList == nil then
		PreviewItemList={}
		
		local clsList, cnt = GetClassList('Beauty_Shop_Preview_SilverGacha');
		for i = 0, cnt - 1 do
			local cls = GetClassByIndexFromList(clsList, i);
			local data = {
				Category 		= cls.Category,
				Gender			= cls.Gender,
				ItemClassName	= cls.ItemClassName,
				EquipType		= cls.EquipType,
				Price			= tonumber(cls.Price),
				PriceRatio		= tonumber(cls.PriceRatio),
				JobOnly			= cls.JobOnly,
				SellStartTime	= cls.SellStartTime,
				SellEndTime		= cls.SellEndTime,
				StampCount		= tonumber(cls.StampCount),
				PackageList		= cls.PackageList,
				IsPremium		= cls.IsPremium,
				TAG				= cls.TAG,
				ItemAddDate		= cls.ItemAddDate,
                IDSpace = 'Beauty_Shop_Preview_SilverGacha',
                ClassName = cls.ClassName,
			}

			table.insert(PreviewItemList, data);
		end
	end

	return PreviewItemList;
end
 
 function PREVIEW_SILVERGACHA_SHOP_MAKE_ITEMLIST(gender)
	local list = PREVIEW_SILVERGACHA_SHOP_REGISTER_ITEM_CREATE_LIST();
	BEAUTYSHOP_UPDATE_ITEM_LIST(list, #list);
end

function PREVIEW_SILVERGACHA_SHOP_GET_ITEM_EQUIPTYPE(ItemClassName)
	local list = PREVIEW_SILVERGACHA_SHOP_REGISTER_ITEM_CREATE_LIST();
    for i = 1, #list do
        local data = list[i];    
        if data.ItemClassName == ItemClassName then
            return data.EquipType;
        end
    end
    
    return nil
end

function PREVIEW_SILVERGACHA_SHOP_POST_SELECT_ITEM(frame, ctrl)
	local ctrlSet = ctrl:GetParent();
	local gender = ctrlSet:GetUserIValue("GENDER");
	local itemClassName = ctrlSet:GetUserValue("ITEM_CLASS_NAME");
	
	local topFrame = ui.GetFrame("beautyshop");
	if topFrame == nil or topFrame:IsVisible() == 0 then
		return;
	end

	local allowGender = BEAUTYSHOP_CHECK_MY_GENDER(gender);
	if allowGender == false then
		return;
	end

	local equipType = PREVIEW_SILVERGACHA_SHOP_GET_ITEM_EQUIPTYPE(itemClassName);
	if equipType == nil then
		return;
	end

	local slot = BEAUTYSHOP_GET_PREIVEW_SLOT(equipType, itemClassName);
	if slot == nil then
		return;
	end

	slot:ClearText();
	slot:ClearIcon();
	slot:SetUserValue("CLASSNAME", "None");
	slot:RemoveChild('HAIR_DYE_PALETTE');

	local itemobj = GetClass("Item", itemClassName);
	if itemobj == nil then
		return;
	end
	
	slot:SetUserValue("TYPE", equipType);
	BEAUTYSHOP_PREVIEWSLOT_EQUIP(topFrame, slot, itemobj);
end

function PREVIEW_SILVERGACHA_SHOP_DRAW_ITEM_DETAIL(obj, itemobj, ctrlset)
	local title = GET_CHILD_RECURSIVELY(ctrlset,"title");
    local slot = GET_CHILD_RECURSIVELY(ctrlset, "icon");
    local picCheck = GET_CHILD_RECURSIVELY(ctrlset, "picCheck");	
	picCheck:SetVisible(0);
	
	local itemclsID = itemobj.ClassID;
	local itemName = itemobj.Name;
 	title:SetText(itemName);

    local beautyShopCls = GetClass(ctrlset:GetUserValue('IDSPACE'), ctrlset:GetUserValue('SHOP_CLASSNAME'));
 	BEAUTYSHOP_DETAIL_PREMIUM(ctrlset, itemobj, beautyShopCls);
    BEAUTYSHOP_DETAIL_TAG(ctrlset, itemobj, beautyShopCls);
    BEAUTYSHOP_DETAIL_SET_PRICE_TEXT(ctrlset, beautyShopCls);
    
	SET_SLOT_IMG(slot, GET_ITEM_ICON_IMAGE(itemobj));
			
	local icon = slot:GetIcon();
	icon:SetTooltipType("wholeitem");
	icon:SetTooltipArg("", itemclsID, 0);
    icon:SetTooltipOverlap(1);

	local lv = GETMYPCLEVEL();
	local job = GETMYPCJOB();
	local gender = GETMYPCGENDER();
	local prop = geItemTable.GetProp(itemclsID);
	local result = prop:CheckEquip(lv, job, gender);

	local desc = GET_CHILD_RECURSIVELY(ctrlset,"desc");
	if result == "OK" then
		desc:SetText(GET_USEJOB_TOOLTIP(itemobj));
	else
		desc:SetText("{#990000}"..GET_USEJOB_TOOLTIP(itemobj).."{/}");
	end

	local tradeable = GET_CHILD_RECURSIVELY(ctrlset,"tradeable");
	local itemProp = geItemTable.GetPropByName(itemobj.ClassName);
	if itemProp:IsEnableUserTrade() == true then
		tradeable:ShowWindow(0);
	else
		tradeable:ShowWindow(1);
	end

	local buyBtn = GET_CHILD_RECURSIVELY(ctrlset, "buyBtn");
	buyBtn:SetVisible(0);
end