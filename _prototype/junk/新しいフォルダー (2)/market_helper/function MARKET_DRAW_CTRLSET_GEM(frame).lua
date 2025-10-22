function MARKET_DRAW_CTRLSET_GEM(frame)
    local itemlist = GET_CHILD_RECURSIVELY(frame, "itemListGbox");
    itemlist:RemoveAllChild();
    local mySession = session.GetMySession();
    local cid = mySession:GetCID();
    local count = session.market.GetItemCount();

    MARKET_SELECT_SHOW_TITLE(frame, "gemTitle")

    local yPos = 0
    for i = 0, count - 1 do
        local marketItem = session.market.GetItemByIndex(i);
        local itemObj = GetIES(marketItem:GetObject());
        local refreshScp = itemObj.RefreshScp;
        if refreshScp ~= "None" then
            refreshScp = _G[refreshScp];
            refreshScp(itemObj);
        end

        local ctrlSet = itemlist:CreateControlSet("market_item_detail_gem", "ITEM_EQUIP_" .. i, ui.LEFT, ui.TOP, 0, 0,
                                                  0, yPos);
        AUTO_CAST(ctrlSet)
        ctrlSet:SetUserValue("DETAIL_ROW", i);

        MARKET_CTRLSET_SET_ICON(ctrlSet, itemObj, marketItem);

        local name = ctrlSet:GetChild("name");
        name:SetTextByKey("value", GET_FULL_NAME(itemObj));

        local gemLevel = GET_CHILD_RECURSIVELY(ctrlSet, "gemLevel")
        local gemLevelValue = GET_ITEM_LEVEL_EXP(itemObj)
        gemLevel:SetTextByKey("value", gemLevelValue)

        local gemRoastingLevel = TryGetProp(itemObj, 'GemRoastingLv', 0);
        local roastingLevel = GET_CHILD_RECURSIVELY(ctrlSet, "roastingLevel")
        roastingLevel:SetTextByKey("value", gemRoastingLevel)

        if cid == marketItem:GetSellerCID() then
            local buyBtn = GET_CHILD_RECURSIVELY(ctrlSet, "buyBtn");
            buyBtn:ShowWindow(0)
            buyBtn:SetEnable(0);
            local cancelBtn = GET_CHILD_RECURSIVELY(ctrlSet, "cancelBtn");
            cancelBtn:ShowWindow(1)
            cancelBtn:SetEnable(1)

            if USE_MARKET_REPORT == 1 then
                local reportBtn = ctrlSet:GetChild("reportBtn");
                reportBtn:SetEnable(0);
            end

            local totalPrice_num = ctrlSet:GetChild("totalPrice_num");
            totalPrice_num:SetTextByKey("value", 0);
            local totalPrice_text = ctrlSet:GetChild("totalPrice_text");
            totalPrice_text:SetTextByKey("value", 0);
        else
            local buyBtn = GET_CHILD_RECURSIVELY(ctrlSet, "buyBtn");
            buyBtn:ShowWindow(1)
            buyBtn:SetEnable(1);
            local cancelBtn = GET_CHILD_RECURSIVELY(ctrlSet, "cancelBtn");
            cancelBtn:ShowWindow(0)
            cancelBtn:SetEnable(0)
            MARKET_CTRLSET_SET_TOTAL_PRICE(ctrlSet, marketItem);
        end

        local propNameList = GET_ITEM_PROP_NAME_LIST(itemObj)
        for j = 1, #propNameList do
            local title = propNameList[j]["Title"];
            local propName = propNameList[j]["PropName"];
            local propValue = propNameList[j]["PropValue"];
            local useOperator = propNameList[j]["UseOperator"];
            local propOptDesc = propNameList[j]["OptDesc"];
            if title == nil and TryGetProp(itemObj, "StringArg", "None") ~= "SkillGem" then
                local realtext = nil
                if propName == "CoolDown" then
                    propValue = propValue / 1000;
                    realtext = ScpArgMsg("CoolDown : {Sec} Sec", "Sec", propValue);
                elseif propName == "OptDesc" then
                    realtext = propOptDesc;
                else
                    if useOperator ~= nil and propValue > 0 then
                        realtext = ScpArgMsg(propName) .. " : " .. "{img green_up_arrow 16 16}" .. propValue;
                    else
                        realtext = ScpArgMsg(propName) .. " : " .. "{img red_down_arrow 16 16}" .. propValue;
                    end
                end

                if propName == "OptDesc" then
                    realtext = propOptDesc;
                end

                if realtext ~= nil then
                    SET_MARKET_EQUIP_CTRLSET_OPTION_TEXT(ctrlSet, realtext);
                end
            end
        end

        for j = 1, MAX_RANDOM_OPTION_COUNT do
            local propGroupName = "RandomOptionGroup_" .. j;
            local propName = "RandomOption_" .. j;
            local propValue = "RandomOptionValue_" .. j;
            local clientMessage = 'None';
            local propItem = itemObj;
            local group = TryGetProp(propItem, "GroupName", "None");
            if group == "Gem" then
                if propItem[propGroupName] == 'ATK' then
                    clientMessage = 'ItemRandomOptionGroupATK'
                elseif propItem[propGroupName] == 'DEF' then
                    clientMessage = 'ItemRandomOptionGroupDEF'
                elseif propItem[propGroupName] == 'UTIL_WEAPON' then
                    clientMessage = 'ItemRandomOptionGroupUTIL'
                elseif propItem[propGroupName] == 'UTIL_ARMOR' then
                    clientMessage = 'ItemRandomOptionGroupUTIL'
                elseif propItem[propGroupName] == 'UTIL_SHILED' then
                    clientMessage = 'ItemRandomOptionGroupUTIL'
                elseif propItem[propGroupName] == 'STAT' then
                    clientMessage = 'ItemRandomOptionGroupSTAT'
                elseif propItem[propGroupName] == 'SPECIAL' then
                    clientMessage = 'ItemRandomOptionGroupSPECIAL'
                end
                if propItem[propValue] ~= 0 and propItem[propName] ~= "None" then
                    local opName = string.format("%s %s", ClMsg(clientMessage), ScpArgMsg(propItem[propName]));
                    if propItem[propValue] ~= nil then
                        local strInfo = ABILITY_DESC_NO_PLUS(opName, propItem[propValue], 0);
                        SET_MARKET_EQUIP_CTRLSET_OPTION_TEXT(ctrlSet, strInfo);
                    end
                end
            end
        end
        ctrlSet:SetUserValue("sellPrice", marketItem:GetSellPrice());
    end
    local ITEM_CTRLSET_INTERVAL_Y_MARGIN = tonumber(frame:GetUserConfig('ITEM_CTRLSET_INTERVAL_Y_MARGIN'));
    GBOX_AUTO_ALIGN(itemlist, 4, ITEM_CTRLSET_INTERVAL_Y_MARGIN, 0, false, true);
    MARKET_SET_PAGE_CONTROL(frame, "pagecontrol")
end

function MARKET_FIND_PAGE(frame, page)
    page = CLAMP_MARKET_PAGE_NUMBER(frame, 'pagecontrol', page);
    local orderByDesc = GET_SEARCH_PRICE_ORDER(frame);
    if orderByDesc < 0 then
        return;
    end
    local searchText = GET_SEARCH_TEXT(frame);
    local category, _category, _subCategory = GET_CATEGORY_STRING(frame);
    if category == '' and searchText == '' then
        return;
    end

    if searchText ~= '' and ui.GetPaperLength(searchText) < 2 then
        ui.SysMsg(ClMsg('InvalidFindItemQueryMin'));
        return;
    end

    local optionKey, optionValue = GET_SEARCH_OPTION(frame);
    local itemCntPerPage = GET_MARKET_SEARCH_ITEM_COUNT(_category);
    MarketSearch(page + 1, orderByDesc, searchText, category, optionKey, optionValue, itemCntPerPage);
    DISABLE_BUTTON_DOUBLECLICK_WITH_CHILD(frame:GetName(), 'commitSet', 'searchBtn', 1);
    MARKET_OPTION_BOX_CLOSE_CLICK(frame);
end

function MARKET_SUB_CATEOGRY_CLICK(parent, subCategoryCtrlset, reqList)
    local frame = parent:GetTopParentFrame();
    local prevSelectedSubCategory = frame:GetUserValue('SELECTED_SUB_CATEGORY');
    local prevSelectedSubCateCtrlset = GET_CHILD_RECURSIVELY(frame, 'SUB_CATE_' .. prevSelectedSubCategory);
    if prevSelectedSubCateCtrlset ~= nil then
        prevSelectedSubCateCtrlset:FillColor(false, nil);
    end

    local parentCategory = subCategoryCtrlset:GetUserValue('PARENT_CATEGORY');
    local category = subCategoryCtrlset:GetUserValue('CATEGORY');
    subCategoryCtrlset:FillColor(true, 'FFDEDE00');
    frame:SetUserValue('SELECTED_SUB_CATEGORY', category);

    if reqList ~= false then
        MARKET_REQ_LIST(frame);
    end
end

function MARKET_DRAW_CTRLSET_DEFAULT(frame, isShowLevel)
    local itemlist = GET_CHILD_RECURSIVELY(frame, "itemListGbox");
    itemlist:RemoveAllChild();
    local mySession = session.GetMySession();
    local cid = mySession:GetCID();
    local count = session.market.GetItemCount();

    MARKET_SELECT_SHOW_TITLE(frame, "defaultTitle")
    local defaultTitle_level = GET_CHILD_RECURSIVELY(frame, "defaultTitle_level")
    if isShowLevel ~= nil and isShowLevel == false then
        defaultTitle_level:ShowWindow(0)
    else
        defaultTitle_level:ShowWindow(1)
    end

    local yPos = 0
    for i = 0, count - 1 do
        local marketItem = session.market.GetItemByIndex(i);
        local itemObj = GetIES(marketItem:GetObject());
        local refreshScp = itemObj.RefreshScp;
        if refreshScp ~= "None" then
            refreshScp = _G[refreshScp];
            refreshScp(itemObj);
        end

        local ctrlSet = itemlist:CreateControlSet("market_item_detail_default", "ITEM_EQUIP_" .. i, ui.LEFT, ui.TOP, 0,
                                                  0, 0, yPos);
        AUTO_CAST(ctrlSet)
        ctrlSet:SetUserValue("DETAIL_ROW", i);

        MARKET_CTRLSET_SET_ICON(ctrlSet, itemObj, marketItem);

        if itemObj.GroupName == "ExpOrb" or itemObj.GroupName == "SubExpOrb" then
            local curExp, maxExp = GET_LEGENDEXPPOTION_EXP(itemObj)
            local expPoint = 0
            if maxExp ~= nil and maxExp ~= 0 then
                expPoint = curExp / maxExp * 100
            else
                expPoint = 0
            end
            local expStr = string.format("%.2f", expPoint)

            MARKET_SET_EXPORB_ICON(ctrlSet, curExp, maxExp, itemObj)
        end

        local name = ctrlSet:GetChild("name");
        local name_text = GET_FULL_NAME(itemObj)
        local grade = shared_item_earring.get_earring_grade(itemObj)
        if grade > 0 then
            name_text = name_text .. '(' .. grade .. ClMsg('Grade') .. ')'
        end

        name:SetTextByKey("value", name_text);

        local level = ctrlSet:GetChild("level");
        local levelValue = ""
        if isShowLevel ~= false then
            if itemObj.GroupName == "Gem" then
                levelValue = GET_ITEM_LEVEL_EXP(itemObj)
            elseif itemObj.GroupName == "Card" then
                levelValue = itemObj.Level
            elseif itemObj.ItemType == "Equip" and TryGetProp(itemObj, 'ClassType2') ~= "Premium" then
                levelValue = itemObj.UseLv
            end
        end
        level:SetTextByKey("value", levelValue);

        MARKET_CTRLSET_SET_PRICE(ctrlSet, marketItem, cid);

        if cid == marketItem:GetSellerCID() then
            local buyBtn = GET_CHILD_RECURSIVELY(ctrlSet, "buyBtn");
            buyBtn:ShowWindow(0)
            buyBtn:SetEnable(0);
            local cancelBtn = GET_CHILD_RECURSIVELY(ctrlSet, "cancelBtn");
            cancelBtn:ShowWindow(1)
            cancelBtn:SetEnable(1)

            if USE_MARKET_REPORT == 1 then
                local reportBtn = ctrlSet:GetChild("reportBtn");
                reportBtn:SetEnable(0);
            end

            local totalPrice_num = ctrlSet:GetChild("totalPrice_num");
            totalPrice_num:SetTextByKey("value", 0);
            local totalPrice_text = ctrlSet:GetChild("totalPrice_text");
            totalPrice_text:SetTextByKey("value", 0);
        else
            local buyBtn = GET_CHILD_RECURSIVELY(ctrlSet, "buyBtn");
            buyBtn:ShowWindow(1)
            buyBtn:SetEnable(1);
            local cancelBtn = GET_CHILD_RECURSIVELY(ctrlSet, "cancelBtn");
            cancelBtn:ShowWindow(0)
            cancelBtn:SetEnable(0)

            local editCount = GET_CHILD_RECURSIVELY(ctrlSet, "count")
            editCount:SetMinNumber(1)
            editCount:SetMaxNumber(marketItem.count)
            editCount:SetText("1")
            editCount:SetNumChangeScp("MARKET_CHANGE_COUNT");
            ctrlSet:SetUserValue("minItemCount", 1)
            ctrlSet:SetUserValue("maxItemCount", marketItem.count)

            MARKET_CTRLSET_SET_TOTAL_PRICE(ctrlSet, marketItem);
        end
    end

    local ITEM_CTRLSET_INTERVAL_Y_MARGIN = tonumber(frame:GetUserConfig('ITEM_CTRLSET_INTERVAL_Y_MARGIN'));
    GBOX_AUTO_ALIGN(itemlist, 4, ITEM_CTRLSET_INTERVAL_Y_MARGIN, 0, false, true);

    MARKET_SET_PAGE_CONTROL(frame, "pagecontrol")
end
