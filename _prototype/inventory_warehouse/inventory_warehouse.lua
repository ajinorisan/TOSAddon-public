local addonName = "INVENTORY_WAREHOUSE"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.0.0"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)

local acutil = require("acutil")
local json = require("json_imc")

function INVENTORY_WAREHOUSE_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame

    -- addon:RegisterMsg('OPEN_DLG_ACCOUNTWAREHOUSE', 'inventory_warehouse_frame_init')
    -- acutil.setupEvent(addon, "ACCOUNTWAREHOUSE_CLOSE", "inventory_warehouse_frame_close");
end

function inventory_warehouse_frame_init(frame)

    frame:SetOffset(700, 300)
    frame:Resize(700, 610)
    frame:ShowWindow(1)

end

function inventory_warehouse_frame_close(frame)

    frame:ShowWindow(0)

end
function inventory_warehouse_activegbox()
    local frame = ui.GetFrame("yaireplacement")

    for typeNo = 1, #g_invenTypeStrList do
        if not IsBlackListedTabName(g_invenTypeStrList[typeNo]) then
            local tree_box = GET_CHILD_RECURSIVELY(frame, 'treeGbox_' .. g_invenTypeStrList[typeNo], 'ui::CGroupBox');
            if (tree_box:IsVisible() == 1) then

                return tree_box
            end
        end

    end
    return nil
end

function inventory_warehouse_update()
    g.tree = {}

    local invenTypeStr = nil
    local overlap = ui.GetFrame("inventory_warehouse")
    local gbox2 = overlap:GetChildRecursively("inventoryitemGbox")
    AUTO_CAST(gbox2)

    local frame = ui.GetFrame("inventory_warehouse")
    local invframe = ui.GetFrame("inventory")
    local awframe = ui.GetFrame("accountwarehouse")
    local blinkcolor = frame:GetUserConfig("TREE_SEARCH_BLINK_COLOR");
    local group = GET_CHILD_RECURSIVELY(frame, 'inventoryGbox', 'ui::CGroupBox')

    local etree_box = inventory_warehouse_activegbox()
    local itemList = session.GetEtcItemList(IT_ACCOUNT_WAREHOUSE);
    local guidList = itemList:GetGuidList();
    local sortedGuidList = itemList:GetSortedGuidList();
    local isShowMap = {};
    local sortedCnt = sortedGuidList:Count();

    local invItemCount = sortedCnt;

    local invItemList = {}
    local index_count = 1
    local cls_inv_index = {}
    local i_cnt = 0

    local curpos = etree_box:GetScrollCurPos();
    frame:SetUserValue("INVENTORY_CUR_SCROLL_POS", curpos);

    for typeNo = 1, #g_invenTypeStrList do
        if not IsBlackListedTabName(g_invenTypeStrList[typeNo]) then
            if (invenTypeStr == nil or invenTypeStr == g_invenTypeStrList[typeNo] or typeNo == 1) then
                local tree_box =
                    GET_CHILD_RECURSIVELY(group, 'treeGbox_' .. g_invenTypeStrList[typeNo], 'ui::CGroupBox')
                local tree = GET_CHILD_RECURSIVELY(tree_box, 'inventree_' .. g_invenTypeStrList[typeNo],
                    'ui::CTreeControl')

                local groupfontname = frame:GetUserConfig("TREE_GROUP_FONT");
                local tabwidth = frame:GetUserConfig("TREE_TAB_WIDTH");

                tree:Clear();
                tree:EnableDrawFrame(false)
                tree:SetFitToChild(true, 60)
                tree:SetFontName(groupfontname);
                tree:SetTabWidth(tabwidth);

            end
        end
    end

    local baseidclslist, baseidcnt = GetClassList("inven_baseid");
    local invenTitleName = nil
    if invenTitleName == nil then
        invenTitleName = {}
        for i = 1, baseidcnt do
            -- local baseid = GetInvenBaseID(itemObj.ClassID)
            local baseidcls = GetClassByIndexFromList(baseidclslist, i - 1)
            local tempTitle = baseidcls.ClassName
            if baseidcls.MergedTreeTitle ~= "NO" then
                tempTitle = baseidcls.MergedTreeTitle
            end

            if table.find(invenTitleName, tempTitle) == 0 then
                invenTitleName[#invenTitleName + 1] = tempTitle
            end
        end
    end

    for i = 0, invItemCount - 1 do
        local invItem = itemList:GetItemByGuid(sortedGuidList:Get(i));
        if invItem ~= nil then
            local pass = true
            local obj = GetIES(invItem:GetObject())
            local class = GetClassByType("Item", obj.ClassID)
            -- local realname = dictionary.ReplaceDicIDInCompStr(class.Name)

            if pass then
                invItem.index = index_count
                invItemList[index_count] = invItem
                index_count = index_count + 1
            end
        end
    end

    local sortType = 3

    -- @TODO ソート処理をここに

    -- 1 등급순 / 2 무게순 / 3 이름순 / 4 소지량순
    if sortType == 1 then
        table.sort(invItemList, INVENTORY_SORT_BY_GRADE)
    elseif sortType == 2 then
        table.sort(invItemList, INVENTORY_SORT_BY_WEIGHT)
    elseif sortType == 3 then
        table.sort(invItemList, INVENTORY_SORT_BY_NAME)
    elseif sortType == 4 then
        table.sort(invItemList, INVENTORY_SORT_BY_COUNT)
    else
        table.sort(invItemList, INVENTORY_SORT_BY_NAME)
    end

    for i = 1, #invenTitleName do
        local category = invenTitleName[i]
        local lim = 30

        for j = 1, #invItemList do
            lim = lim - 1
            if (lim == 0) then

                lim = 30
            end
            local invItem = invItemList[j];
            if invItem ~= nil then
                local itemCls = GetIES(invItem:GetObject())
                if itemCls.MarketCategory ~= "None" then
                    local baseidcls = nil
                    baseidcls = INV_GET_INVEN_BASEIDCLS_BY_ITEMGUID(invItem:GetIESID())
                    cls_inv_index[invItem.invIndex] = baseidcls

                    local titleName = baseidcls.ClassName
                    if baseidcls.MergedTreeTitle ~= "NO" then
                        titleName = baseidcls.MergedTreeTitle
                    end

                    if category == titleName then
                        local typeStr = GET_INVENTORY_TREEGROUP(baseidcls)
                        if itemCls ~= nil then
                            local makeSlot = true;

                            local viewOptionCheck = 1
                            if typeStr == "Equip" then
                                viewOptionCheck = CHECK_INVENTORY_OPTION_EQUIP(itemCls)
                            elseif typeStr == "Card" then
                                viewOptionCheck = CHECK_INVENTORY_OPTION_CARD(itemCls)
                            elseif typeStr == "Etc" then
                                viewOptionCheck = CHECK_INVENTORY_OPTION_ETC(itemCls)
                            elseif typeStr == "Gem" then
                                viewOptionCheck = CHECK_INVENTORY_OPTION_GEM(itemCls)
                            end

                            if invItem.count > 0 and baseidcls.ClassName ~= 'Unused' then -- Unused로 설정된 것은 안보임
                                g.tree[typeStr] = g.tree[typeStr] or {}
                                if invenTypeStr == nil or invenTypeStr == typeStr then
                                    local tree_box = GET_CHILD_RECURSIVELY(group, 'treeGbox_' .. typeStr,
                                        'ui::CGroupBox')
                                    local tree = GET_CHILD_RECURSIVELY(tree_box, 'inventree_' .. typeStr,
                                        'ui::CTreeControl')
                                    inventory_warehouse_insert_item_to_tree(frame, tree, invItem, itemCls, baseidcls,
                                        typeStr);

                                end

                                local tree_box_all = GET_CHILD_RECURSIVELY(group, 'treeGbox_All', 'ui::CGroupBox')
                                local tree_all =
                                    GET_CHILD_RECURSIVELY(tree_box_all, 'inventree_All', 'ui::CTreeControl')
                                inventory_warehouse_insert_item_to_tree(frame, tree_all, invItem, itemCls, baseidcls,
                                    typeStr);

                            end
                        end
                    end
                end
            end

        end

    end

    for typeNo = 1, #g_invenTypeStrList do
        if not IsBlackListedTabName(g_invenTypeStrList[typeNo]) then
            local tree_box = GET_CHILD_RECURSIVELY(group, 'treeGbox_' .. g_invenTypeStrList[typeNo], 'ui::CGroupBox');
            local tree = GET_CHILD_RECURSIVELY(tree_box, 'inventree_' .. g_invenTypeStrList[typeNo], 'ui::CTreeControl');
            tree_box:Resize(g.w - 48, g.h)
        end
    end
    for typeNo = 1, #g_invenTypeStrList do
        if not IsBlackListedTabName(g_invenTypeStrList[typeNo]) then
            local tree_box = GET_CHILD_RECURSIVELY(group, 'treeGbox_' .. g_invenTypeStrList[typeNo], 'ui::CGroupBox');
            local tree = GET_CHILD_RECURSIVELY(tree_box, 'inventree_' .. g_invenTypeStrList[typeNo], 'ui::CTreeControl');
            local slotset

            -- 아이템 없는 빈 슬롯은 숨겨라
            local slotSetNameListCnt = ui.inventory.GetInvenSlotSetNameCount();
            for i = 1, slotSetNameListCnt do
                local getSlotSetName = ui.inventory.GetInvenSlotSetNameByIndex(i - 1);
                slotset = GET_CHILD_RECURSIVELY(tree, getSlotSetName, 'ui::CSlotSet');
                if slotset ~= nil then
                    ui.InventoryHideEmptySlotBySlotSet(slotset);
                end
            end

            ADD_GROUP_BOTTOM_MARGIN(frame, tree)
            tree:OpenNodeAll();
            tree:SetEventScript(ui.LBUTTONDOWN, "INVENTORY_TREE_OPENOPTION_CHANGE");
            INVENTORY_CATEGORY_OPENCHECK(frame, tree);

            -- 검색결과 스크롤 세팅은 여기서 하자. 트리 업데이트 후에 위치가 고정된 다음에.
            for i = 1, slotSetNameListCnt do
                local getSlotSetName = ui.inventory.GetInvenSlotSetNameByIndex(i - 1);
                slotset = GET_CHILD_RECURSIVELY(tree, getSlotSetName, 'ui::CSlotSet');

                local slotsetnode = tree:FindByValue(getSlotSetName);
                -- if setpos == 'setpos' then
                local savedPos = frame:GetUserValue("INVENTORY_CUR_SCROLL_POS");
                if savedPos == 'None' then
                    savedPos = 0
                end

                tree_box:SetScrollPos(tonumber(savedPos))

                -- end
            end
        end

    end
    for typeNo = 1, #g_invenTypeStrList do
        if not IsBlackListedTabName(g_invenTypeStrList[typeNo]) then
            local tree_box = GET_CHILD_RECURSIVELY(group, 'treeGbox_' .. g_invenTypeStrList[typeNo], 'ui::CGroupBox');
            local tree = GET_CHILD_RECURSIVELY(tree_box, 'inventree_' .. g_invenTypeStrList[typeNo], 'ui::CTreeControl');

            AUTO_CAST(tree)
            tree:Resize(g.w - 48, tree:GetHeight())

        end
    end
    -- スロット残数を表示
    inventory_warehouse_status()
end

function inventory_warehouse_count()
    local itemList = session.GetEtcItemList(IT_ACCOUNT_WAREHOUSE);
    local guidlist = itemList:GetSortedGuidList();
    local cnt = itemList:Count();
    local rcnt = 0
    for i = 0, cnt - 1 do
        local guid = guidlist:Get(i);
        local invItem = itemList:GetItemByGuid(guid)
        local invItem_obj = GetIES(invItem:GetObject());
        if invItem_obj.ClassName ~= MONEY_NAME then
            rcnt = rcnt + 1
        end
    end
    return rcnt
end

function inventory_warehouse_status(inc)
    local awframe = ui.GetFrame("accountwarehouse")
    local itemList = session.GetEtcItemList(IT_ACCOUNT_WAREHOUSE);
    local guidList = itemList:GetGuidList();
    local sortedGuidList = itemList:GetSortedGuidList();
    local isShowMap = {};
    local sortedCnt = sortedGuidList:Count();

    local invItemCount = inventory_warehouse_count();
    -- スロット残数を表示
    local itemcntold = GET_CHILD_RECURSIVELY(awframe, "itemcnt");
    itemcntold:ShowWindow(0)
    local extendbtn = GET_CHILD_RECURSIVELY(awframe, "extend");
    extendbtn:ShowWindow(0)
    local richtext_1 = GET_CHILD_RECURSIVELY(awframe, "richtext_1");
    richtext_1:ShowWindow(0)
    local itemcnt
    local gauge
    --[[if (InstalledAWW()) then
        local fillgbox = awframe:CreateOrGetControl("groupbox", "fill", 0, 0, 0, 0);
        AUTO_CAST(fillgbox)
        -- print(tostring(fillgbox:GetName()))
        fillgbox:SetOffset(0, 0)
        fillgbox:Resize(awframe:GetWidth(), 100)
        fillgbox:SetSkinName("bg")
        fillgbox:EnableHittestGroupBox(0)

        local closebtn = fillgbox:CreateOrGetControl("button", "close", 0, 0, 0, 0);
        AUTO_CAST(closebtn)
        -- print(tostring(closebtn:GetName()))
        closebtn:CloneFrom(awframe:GetChildRecursively("close"))
        -- print(tostring("test"))
        closebtn:SetGravity(ui.RIGHT, ui.TOP)
        closebtn:SetOffset(36, 28)
        closebtn:SetEventScript(ui.LBUTTONUP, "YAI_ACCOUNTWAREHOUSE_CLOSE_FROM_YAI")
        itemcnt = fillgbox:CreateOrGetControl("richtext", "itemcnt222", 30, 20, 100, 24);
        gauge = fillgbox:CreateOrGetControl("gauge", "gaugecnt", 30, 46, 560, 8);
    else
        itemcnt = itemcntold:GetParent():CreateOrGetControl("richtext", "itemcnt222", 30, itemcntold:GetY() - 20, 100,
            24);
        gauge = itemcntold:GetParent():CreateOrGetControl("gauge", "gaugecnt", 30, itemcntold:GetY() + 16, 560, 8);
    end

    AUTO_CAST(itemcnt)
    AUTO_CAST(gauge)
    itemcnt:EnableHitTest(1)
    itemcnt:SetTextTooltip(L_("Click here to expand one basic slot."))
    itemcnt:SetEventScript(ui.LBUTTONUP, "ACCOUNT_WAREHOUSE_EXTEND")

    gauge:EnableHitTest(0)
    itemcnt:ShowWindow(1)

    gauge:ShowWindow(1)

    -- if (inc) then
    --     local prevcnt = tonumber(itemcnt:GetTextByKey("cnt"))
    --     prevcnt = prevcnt + inc
    --     --itemcnt:SetTextByKey('cnt', invItemCount);
    -- else
    --     --itemcnt:SetTextByKey('cnt', invItemCount);
    -- end
    local account = session.barrack.GetMyAccount();
    local slotCount = account:GetAccountWarehouseSlotCount();
    local aObj = GetMyAccountObj();
    if nil == aObj then
        return;
    end

    local price = GET_ACCOUNT_WAREHOUSE_EXTEND_PRICE(aObj, GET_COLONY_TAX_RATE_CURRENT_MAP())
    local expandable
    if price == nil then -- 추가 창고 슬롯 맥스
        expandable = "{s16}(" .. L_("Basic Slots") .. ":" .. slotCount .. " *" .. L_("Reached to maximum.") .. ")"

    else
        expandable = "{s16}(" .. L_("Basic Slots") .. ":" .. slotCount .. " " .. L_("Expandable By") ..
                         ":'{img icon_item_silver 24 24} " .. GET_COMMAED_STRING(price) .. ")"

    end

    -- itemcnt:SetTextByKey('slotmax', YAI_SLOT_LIMIT_FIRSTTAB());
    itemcnt:SetText("{@st42}{s24}" .. L_("Item Count") .. " " .. invItemCount .. "/" .. LS.storagesize() .. expandable);
    gauge:SetPoint(invItemCount, LS.storagesize());
    -- itemcnt:UpdateFormat()]]
end

function inventory_warehouse_insert_item_to_tree(frame, tree, invItem, itemCls, baseidcls, typeStr)
    -- 그룹 없으면 만들기
    local treegroupname = baseidcls.TreeGroup

    local treegroup = tree:FindByValue(treegroupname);
    if tree:IsExist(treegroup) == 0 then
        treegroup = tree:Add(baseidcls.TreeGroupCaption, baseidcls.TreeGroup);
        local treeNode = tree:GetNodeByTreeItem(treegroup);
        treeNode:SetUserValue("BASE_CAPTION", baseidcls.TreeGroupCaption);

        -- ui.inventory.AddInvenGroupName(treegroupname);
    end

    -- 슬롯셋 없으면 만들기
    local slotsetname = YAI_GET_SLOTSET_NAME(baseidcls)
    local slotsetnode = tree:FindByValue(treegroup, slotsetname);
    if tree:IsExist(slotsetnode) == 0 then
        local slotsettitle = 'ssettitle_' .. baseidcls.ClassName;
        if baseidcls.MergedTreeTitle ~= "NO" then
            slotsettitle = 'ssettitle_' .. baseidcls.MergedTreeTitle
        end

        local newSlotsname = MAKE_INVEN_SLOTSET_NAME(tree, slotsettitle, baseidcls.TreeSSetTitle)

        g.tree[typeStr] = g.tree[typeStr] or {}
        g.tree[typeStr][#g.tree[typeStr] + 1] = {
            treegroup = treegroupname,
            treegroupcaption = newSlotsname:GetText():gsub("%(.*%)", ""),
            slotsetname = slotsetname
        }

        MAKE_INVEN_SLOTSET_AND_TITLE(tree, treegroup, slotsetname, baseidcls);
        INVENTORY_CATEGORY_OPENOPTION_CHECK(tree:GetName(), baseidcls.ClassName);
    end
    local slotset = GET_CHILD_RECURSIVELY(tree, slotsetname, 'ui::CSlotSet');
    local slotCount = slotset:GetSlotCount();
    local slotindex = slotCount;

    -- 검색 기능
    local slot = nil;

    local cnt = GET_SLOTSET_COUNT(tree, baseidcls);
    -- 저장된 템의 최대 인덱스에 따라 자동으로 늘어나도록. 예를들어 해당 셋이 10000부터 시작하는데 10500 이 오면 500칸은 늘려야됨
    while slotCount <= cnt do
        slotset:ExpandRow()
        slotCount = slotset:GetSlotCount();
    end

    slot = slotset:GetSlotByIndex(cnt);
    cnt = cnt + 1;
    slotset:SetUserValue("SLOT_ITEM_COUNT", cnt)

    slot:ShowWindow(1);
    UPDATE_INVENTORY_SLOT(slot, invItem, itemCls);

    local function _DRAW_ITEM(invItem, slot)
        local obj = GetIES(invItem:GetObject());

        slot:SetSkinName('invenslot2')
        local itemCls = GetIES(invItem:GetObject());
        local iconImg = GET_ITEM_ICON_IMAGE(itemCls);

        slot:SetHeaderImage('None')

        SET_SLOT_IMG(slot, iconImg)
        SET_SLOT_COUNT(slot, invItem.count)

        SET_SLOT_STYLESET(slot, itemCls)
        SET_SLOT_IESID(slot, invItem:GetIESID())
        SET_SLOT_ITEM_TEXT_USE_INVCOUNT(slot, invItem, obj, nil)
        slot:SetMaxSelectCount(invItem.count);
        local icon = slot:GetIcon();
        icon:SetTooltipArg("accountwarehouse", invItem.type, invItem:GetIESID());
        SET_ITEM_TOOLTIP_TYPE(icon, itemCls.ClassID, itemCls, "accountwarehouse");

        if invItem.hasLifeTime == true or TryGetProp(obj, 'ExpireDateTime', 'None') ~= 'None' then
            ICON_SET_ITEM_REMAIN_LIFETIME(icon, IT_ACCOUNT_WAREHOUSE);
            slot:SetFrontImage('clock_inven');
        else
            CLEAR_ICON_REMAIN_LIFETIME(slot, icon);
        end
        -- 아이커 종류 표시
        SET_SLOT_ICOR_CATEGORY(slot, itemCls);

    end
    -- INV_ICON_SETINFO(frame, slot, invItem, nil, nil, nil);
    _DRAW_ITEM(invItem, slot, nil)
    SET_SLOTSETTITLE_COUNT(tree, baseidcls, 1)
    if (g.settings.enabledrag) then
        slot:EnableDrag(1)
    else
        slot:EnableDrag(0)
    end
    slot:SetEventScript(ui.LBUTTONUP, "YAI_ON_LBUTTON")
    slot:SetEventScript(ui.RBUTTONUP, "YAI_ON_RBUTTON")
    slotset:MakeSelectionList();
    -- slotset:EnableSelection(1)
end
