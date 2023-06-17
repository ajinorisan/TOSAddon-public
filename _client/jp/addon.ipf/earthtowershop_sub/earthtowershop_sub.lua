
function EARTH_TOWER_SHOP_SUB_ON_INIT(addon, frame)

end

function EARTH_TOWER_SHOP_SUB_OPEN_SCP(frame)
    local shopType = frame:GetUserValue("SHOP_TYPE");
    EARTH_TOWER_SHOP_SUB_INIT(frame, shopType);
end

function EARTH_TOWER_SHOP_SUB_CLOSE_SCP(frame)

end

function EARTH_TOWER_SHOP_SUB_CLOSE(frame)
    frame:ShowWindow(0);
end

function REQ_EARTH_TOWER_SHOP_SUB_COMMON(shopType)
    ui.CloseFrame("earthtowershop_sub");

    local frame = ui.GetFrame("earthtowershop_sub");
    if frame == nil then
        return;
    end

    frame:SetUserValue("SHOP_TYPE", shopType);
    ui.OpenFrame("earthtowershop_sub");
end

function EARTH_TOWER_SHOP_SUB_INIT(frame, shopType)
    local aObj = GetMyAccountObj();
    
    local title = GET_CHILD(frame, "title");
    local question = GET_CHILD(frame, "question");

    local desc_gb = GET_CHILD(frame, "desc_gb");
    local desc_1 = GET_CHILD(desc_gb, "desc_1");
    local desc_2 = GET_CHILD(desc_gb, "desc_2");
    local desc_3 = GET_CHILD(desc_gb, "desc_3");
    local desc_4 = GET_CHILD(desc_gb, "desc_4");

    local tabFontStyle = frame:GetUserConfig("TAB_FONTSTYLE");
	local tab = GET_CHILD(frame, "tab");
	tab:SelectTab(0);
    tab:SetEventScript(ui.LBUTTONUP, "EARTH_TOWER_SHOP_SUB_TAB_CLICK");
    
    if string.find(shopType, "EVENT_2011_5TH_Special_Shop") ~= nil then
        title:SetTextByKey("value", ClMsg("EVENT_2011_5TH_Special_Shop_Sub_title"));
        question:SetTextTooltip(ClMsg("EVENT_2011_5TH_Special_Shop_Item_MSG_5"));

        local point = TryGetProp(aObj, "EVENT_2011_5TH_POINT_COUNT", 0);
        desc_1:SetTextByKey("name", ClMsg("EventLevel").." : ");
        desc_1:SetTextByKey("count", GET_EVENT_2011_5TH_EVENT_LEVEL(point));
        
        desc_2:SetTextByKey("name", ClMsg("EventPoint").." : "  );
        desc_2:SetTextByKey("count", point);

        desc_3:SetTextByKey("name", ClMsg("NextLevelNeedPoint").." : ");
        desc_3:SetTextByKey("count", GET_EVENT_2011_5TH_NEXT_EVENT_LEVEL_NEED_POINT(point));
        
        local useCnt = TryGetProp(aObj, "EVENT_2011_5TH_COIN_USE_COUNT", 0);        
        desc_4:SetTextByKey("name", ScpArgMsg("EVENT_2011_5TH_Special_Shop_Item_MSG_4{CNT}", "CNT", useCnt));

        tab:ChangeCaption(0, tabFontStyle..ClMsg("EventLevelGradeSection"), false);
        tab:ChangeCaption(1, tabFontStyle..ClMsg("ShopGradeRatio", false));
    end

    EARTH_TOWER_SHOP_SUB_TAB_CLICK(frame, tab)
end

function EARTH_TOWER_SHOP_SUB_TAB_CLICK(parent, ctrl)
    local frame = ui.GetFrame("earthtowershop_sub");
    local shopType = frame:GetUserValue("SHOP_TYPE");

    local tab_desc = GET_CHILD_RECURSIVELY(frame, "tab_desc");
	local index = ctrl:GetSelectItemIndex();

    if string.find(shopType, "EVENT_2011_5TH_Special_Shop") ~= nil then
        if index == 0 then
            tab_desc:SetTextByKey("value", ClMsg("EVENT_2011_5TH_MSG_16"));
        elseif index == 1 then
            local aObj = GetMyAccountObj();
            local point = TryGetProp(aObj, "EVENT_2011_5TH_POINT_COUNT", 0);
            local level = GET_EVENT_2011_5TH_EVENT_LEVEL(point);
            tab_desc:SetTextByKey("value", ClMsg("EVENT_2011_5TH_Special_Shop_Grade_text_"..level));
        end
    end


end