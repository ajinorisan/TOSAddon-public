
function PCBANG_POPUP_PURCHASE_ON_INIT(addon, frame)
end

function PCBANG_POPUP_PURCHASE_OPEN(productClsID)    
    local itemName = nil;
    local infoCnt = session.pcBang.GetSellingListCount();
    local info = nil;
    for i = 0, infoCnt - 1 do 
        local iteminfo = session.pcBang.GetSellingItem(i);
        if iteminfo.productID == productClsID then
            info = iteminfo;
        end
    end
    
    if info == nil then
        return;
    end

    local frame = ui.GetFrame("pcbang_popup_purchase");

    local item_name = GET_CHILD(frame, "item_name");
    local item_pic = GET_CHILD(frame, "item_pic");
    local buycount_text = GET_CHILD(frame, "buycount_text");

    local cls = GetClass("Item", info.itemName);
    if cls == nil then
        frame:ShowWindow(0);
        return;
    end

    local namestr = cls.Name;
    if info.itemCount > 1 then
        local countstr = "("..ScpArgMsg("Count{n}", "n", info.itemCount)..")"
        namestr = namestr .. countstr;
    end
    item_name:SetText(namestr);
    item_name:AdjustFontSizeByWidth(frame:GetWidth());
    item_pic:SetImage(cls.Icon);

    local bought, buylimit = GET_PCBANG_SHOP_POINTSHOP_BUY_LIMIT(info)
    buycount_text:SetTextByKey("bought", bought)
    buycount_text:SetTextByKey("limit", buylimit)
    
    frame:SetUserValue("Product", productClsID);
    frame:SetUserValue("buylimit", buylimit);
    frame:ShowWindow(1);
end

function INPUT_NUMBER_BOX_PCBANG_PURCHASE(cbframe, titleName, strscp, defNumber, minNumber, maxNumber)
	local frame = INPUT_STRING_BOX_CB(cbframe, titleName, strscp, defNumber, nil, nil, nil, true)
	local edit = GET_CHILD(frame, 'input', "ui::CEditControl");	
	edit:SetNumberMode(1);
	edit:SetMaxNumber(maxNumber);
	edit:SetMinNumber(minNumber);
    edit:AcquireFocus();
    
    local f = ui.GetFrame('pcbang_shop')
    if f ~= nil then
        frame:SetLayerLevel(f:GetLayerLevel() + 1)
    end
end

function ON_PCBANG_POPUP_PURCHASE_YES(frame)
    local productClsID = frame:GetUserIValue("Product");
    local buylimit = frame:GetUserIValue("buylimit");

    if buylimit == 1 then
        pcBang.ReqPCBangShopPurchase(productClsID, 1);
    else
        local maxCount = tonumber(buylimit)
        if maxCount > 20 then
            maxCount = 20
        end
        local titleText = ScpArgMsg("INPUT_CNT_D_D", "Auto_1", 1, "Auto_2", maxCount);
        INPUT_NUMBER_BOX_PCBANG_PURCHASE(frame, titleText, "RUN_PCBANG_POPUP_PURCHASE", 1, 1, maxCount);
    end
    
    frame:ShowWindow(0);
end

function ON_PCBANG_POPUP_PURCHASE_NO(frame)
    frame:ShowWindow(0);
end

function RUN_PCBANG_POPUP_PURCHASE(frame, count, input_frame)
    productClsID = frame:GetUserIValue("Product")    
    pcBang.ReqPCBangShopPurchase(productClsID, count);
end