-- v0.0.1 作ってみた
-- v0.0.2 フォルダ作るコード入れた。
local addonName = "inventory_icor_search"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "0.0.2"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

local acutil = require("acutil")
local json = require("json")
local os = require("os")

function g.mkdir_new_folder()
    local folder_path = string.format("../addons/%s", addonNameLower)
    local file_path = string.format("../addons/%s/mkdir.txt", addonNameLower)
    local file = io.open(file_path, "r")
    if not file then
        os.execute('mkdir "' .. folder_path .. '"')
        file = io.open(file_path, "w")
        if file then
            file:write("A new file has been created")
            file:close()
        end
    else
        file:close()
    end
end
g.mkdir_new_folder()

g.settings_file_path = string.format("../addons/%s/settings.json", addonNameLower)
-- g.get_buffs_file_path = string.format("../addons/%s/get_buffs.json", addonNameLower)

local base = {}

function g.SetupHook(func, baseFuncName)
    local addonUpper = string.upper(addonName)
    local replacementName = addonUpper .. "_BASE_" .. baseFuncName
    if (_G[replacementName] == nil) then
        _G[replacementName] = _G[baseFuncName]
        _G[baseFuncName] = func
    end
    base[baseFuncName] = _G[replacementName]
end

local invenTitleName = nil
local g_invenTypeStrList = {"All", "Equip", "Consume", "Recipe", "Card", "Etc", "Gem", "Premium", "Housing", "Pharmacy",
                            "Quest"};
local _invenSortTypeOption = {};

function INVENTORY_ICOR_SEARCH_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame
    g.SetupHook(INVENTORY_ICOR_SEARCH_INVENTORY_TOTAL_LIST_GET, 'INVENTORY_TOTAL_LIST_GET')
end

function INVENTORY_ICOR_SEARCH_INVENTORY_TOTAL_LIST_GET(frame, setpos, isIgnorelifticon, invenTypeStr)
    INVENTORY_ICOR_SEARCH_INVENTORY_TOTAL_LIST_GET_(frame, setpos, isIgnorelifticon, invenTypeStr)
end

function INVENTORY_ICOR_SEARCH_INVENTORY_TOTAL_LIST_GET_(frame, setpos, isIgnorelifticon, invenTypeStr)

    local frame = ui.GetFrame("inventory")
    if frame == nil then
        return;
    end

    local liftIcon = ui.GetLiftIcon();
    if nil == isIgnorelifticon then
        isIgnorelifticon = "NO";
    end

    if isIgnorelifticon ~= "NO" and liftIcon ~= nil then
        return;
    end

    local mySession = session.GetMySession();
    local cid = mySession:GetCID();
    local sortType = _invenSortTypeOption[cid];
    session.BuildInvItemSortedList();
    local sortedList = session.GetInvItemSortedList();
    local invItemCount = sortedList:size();

    if sortType == nil then
        sortType = 0;
    end

    local blinkcolor = frame:GetUserConfig("TREE_SEARCH_BLINK_COLOR");
    local group = GET_CHILD_RECURSIVELY(frame, 'inventoryGbox', 'ui::CGroupBox')

    for typeNo = 1, #g_invenTypeStrList do
        if invenTypeStr == nil or invenTypeStr == g_invenTypeStrList[typeNo] or typeNo == 1 then
            local tree_box = GET_CHILD_RECURSIVELY(group, 'treeGbox_' .. g_invenTypeStrList[typeNo], 'ui::CGroupBox')
            local tree = GET_CHILD_RECURSIVELY(tree_box, 'inventree_' .. g_invenTypeStrList[typeNo], 'ui::CTreeControl')

            local groupfontname = frame:GetUserConfig("TREE_GROUP_FONT");
            local tabwidth = frame:GetUserConfig("TREE_TAB_WIDTH");

            tree:Clear();
            tree:EnableDrawFrame(false)
            tree:SetFitToChild(true, 60)
            tree:SetFontName(groupfontname);
            tree:SetTabWidth(tabwidth);

            local slotSetNameListCnt = ui.inventory.GetInvenSlotSetNameCount();
            for i = 1, slotSetNameListCnt do
                local slotSetName = ui.inventory.GetInvenSlotSetNameByIndex(i - 1);
                ui.inventory.RemoveInvenSlotSetName(slotSetName);
            end

            local groupNameListCnt = ui.inventory.GetInvenGroupNameCount();
            for i = 1, groupNameListCnt do
                local groupName = ui.inventory.GetInvenGroupNameByIndex(i - 1);
                ui.inventory.RemoveInvenGroupName(groupName);
            end

            local customFunc = nil;
            local scriptName = frame:GetUserValue("CUSTOM_ICON_SCP");
            local scriptArg = nil;
            if scriptName ~= nil then
                customFunc = _G[scriptName];
                local getArgFunc = _G[frame:GetUserValue("CUSTOM_ICON_ARG_SCP")];
                if getArgFunc ~= nil then
                    scriptArg = getArgFunc();
                end
            end
        end
    end

    local baseidclslist, baseidcnt = GetClassList("inven_baseid");
    local searchGbox = group:GetChild('searchGbox');
    local searchSkin = GET_CHILD_RECURSIVELY(searchGbox, "searchSkin", 'ui::CGroupBox');
    local edit = GET_CHILD_RECURSIVELY(searchSkin, "ItemSearch", "ui::CEditControl");
    local cap = edit:GetText();
    if cap ~= "" then
        local slotSetNameListCnt = ui.inventory.GetInvenSlotSetNameCount();
        for i = 1, slotSetNameListCnt do
            local getSlotSetName = ui.inventory.GetInvenSlotSetNameByIndex(i - 1);
            local slotset = GET_CHILD_RECURSIVELY(tree, getSlotSetName, 'ui::CSlotSet');
            slotset:RemoveAllChild();
            slotset:SetUserValue("SLOT_ITEM_COUNT", 0);
        end
    end

    local invItemList = {}
    local index_count = 1
    for i = 0, invItemCount - 1 do
        local invItem = sortedList:at(i);
        if invItem ~= nil then
            invItemList[index_count] = invItem
            index_count = index_count + 1
        end
    end

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

    if invenTitleName == nil then
        invenTitleName = {}
        for i = 1, baseidcnt do
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

    local cls_inv_index = {}
    local i_cnt = 0
    for i = 1, #invenTitleName do
        local category = invenTitleName[i]
        for j = 1, #invItemList do
            local invItem = invItemList[j];
            if invItem ~= nil then
                local itemCls = GetIES(invItem:GetObject())
                if itemCls.MarketCategory ~= "None" then
                    local baseidcls = nil
                    if cls_inv_index[invItem.invIndex] == nil then
                        baseidcls = GET_BASEID_CLS_BY_INVINDEX(invItem.invIndex)
                        cls_inv_index[invItem.invIndex] = baseidcls
                    else
                        baseidcls = cls_inv_index[invItem.invIndex]
                    end

                    local titleName = baseidcls.ClassName
                    if baseidcls.MergedTreeTitle ~= "NO" then
                        titleName = baseidcls.MergedTreeTitle
                    end

                    if category == titleName then
                        local typeStr = GET_INVENTORY_TREEGROUP(baseidcls)
                        if itemCls ~= nil then
                            local makeSlot = true;
                            if cap ~= "" then
                                -- 인벤토리 안에 있는 아이템을 찾기 위한 로직
                                local itemname = string.lower(dictionary.ReplaceDicIDInCompStr(itemCls.Name));
                                -- 접두어도 포함시켜 검색해야되기 때문에, 접두를 찾아서 있으면 붙여주는 작업
                                local prefixClassName = TryGetProp(itemCls, "LegendPrefix")
                                if prefixClassName ~= nil and prefixClassName ~= "None" then
                                    local prefixCls = GetClass('LegendSetItem', prefixClassName)
                                    local prefixName = string.lower(dictionary.ReplaceDicIDInCompStr(prefixCls.Name));
                                    itemname = prefixName .. " " .. itemname;
                                end

                                local tempcap = string.lower(cap);
                                local a = string.find(itemname, tempcap);

                                if a == nil then
                                    makeSlot = false;

                                    if TryGetProp(itemCls, 'GroupName', 'None') == 'Earring' then
                                        local max_option_count =
                                            shared_item_earring.get_max_special_option_count(TryGetProp(itemCls,
                                                'UseLv', 1))
                                        for ii = 1, max_option_count do
                                            local option_name = 'EarringSpecialOption_' .. ii
                                            local job = TryGetProp(itemCls, option_name, 'None')
                                            if job ~= 'None' then
                                                local job_cls = GetClass('Job', job)
                                                if job_cls ~= nil then
                                                    itemname = string.lower(
                                                        dictionary.ReplaceDicIDInCompStr(job_cls.Name));
                                                    a = string.find(itemname, tempcap);
                                                    if a ~= nil then
                                                        makeSlot = true
                                                        break
                                                    end
                                                end
                                            end
                                        end
                                    elseif TryGetProp(itemCls, 'GroupName', 'None') == 'Icor' then

                                        local max_option = 5
                                        for iii = 1, max_option do
                                            local item = GetIES(invItem:GetObject())
                                            local option_name = 'RandomOption_' .. iii
                                            local option = TryGetProp(item, option_name, 'None')
                                            if option ~= "None" or option ~= nil then
                                                itemname = string.lower(dictionary.ReplaceDicIDInCompStr(ClMsg(option)))
                                            end
                                            a = string.find(itemname, tempcap);
                                            if a ~= nil then
                                                makeSlot = true
                                                break
                                            end
                                        end
                                    end

                                end
                            end

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

                            if makeSlot == true and viewOptionCheck == 1 then
                                if invItem.count > 0 and baseidcls.ClassName ~= 'Unused' then -- Unused로 설정된 것은 안보임
                                    if invenTypeStr == nil or invenTypeStr == typeStr then
                                        local tree_box = GET_CHILD_RECURSIVELY(group, 'treeGbox_' .. typeStr,
                                            'ui::CGroupBox')
                                        local tree = GET_CHILD_RECURSIVELY(tree_box, 'inventree_' .. typeStr,
                                            'ui::CTreeControl')
                                        INSERT_ITEM_TO_TREE(frame, tree, invItem, itemCls, baseidcls);
                                    end
                                    -- Request #95788 / 퀘스트 항목은 모두 보기 탭에서 보이지 않도록 함
                                    if typeStr ~= "Quest" then
                                        local tree_box_all =
                                            GET_CHILD_RECURSIVELY(group, 'treeGbox_All', 'ui::CGroupBox')
                                        local tree_all = GET_CHILD_RECURSIVELY(tree_box_all, 'inventree_All',
                                            'ui::CTreeControl')
                                        INSERT_ITEM_TO_TREE(frame, tree_all, invItem, itemCls, baseidcls);
                                    end
                                end
                            else
                                --[[if customFunc ~= nil then
                                    local slot = slotSet:GetSlotByIndex(i);
                                    if slot ~= nil then
                                        customFunc(slot, scriptArg, invItem, nil);
                                    end
                                end]]

                                -- 인벤토리 옵션 적용 중이면 빈 tree 만들어 "필터링 옵션 적용 중"이라는 문구 표시해주기
                                local isOptionApplied = CHECK_INVENTORY_OPTION_APPLIED(baseidcls);
                                if isOptionApplied == 1 and cap == "" then -- 검색 중에는 조건에 맞는 아이템 없으면 tree 안 만듬
                                    if invenTypeStr == nil or invenTypeStr == typeStr then
                                        local tree_box = GET_CHILD_RECURSIVELY(group, 'treeGbox_' .. typeStr,
                                            'ui::CGroupBox');
                                        local tree = GET_CHILD_RECURSIVELY(tree_box, 'inventree_' .. typeStr,
                                            'ui::CTreeControl');
                                        EMPTY_TREE_INVENTORY_OPTION_TEXT(baseidcls, tree); -- 해당 아이템이 속한 탭
                                    end

                                    -- Request #95788 / 퀘스트 항목은 모두 보기 탭에서 보이지 않도록 함
                                    if typeStr ~= "Quest" then
                                        local tree_box_all =
                                            GET_CHILD_RECURSIVELY(group, 'treeGbox_All', 'ui::CGroupBox');
                                        local tree_all = GET_CHILD_RECURSIVELY(tree_box_all, 'inventree_All',
                                            'ui::CTreeControl');
                                        EMPTY_TREE_INVENTORY_OPTION_TEXT(baseidcls, tree_all); -- ALL 탭 
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    for typeNo = 1, #g_invenTypeStrList do
        local tree_box = GET_CHILD_RECURSIVELY(group, 'treeGbox_' .. g_invenTypeStrList[typeNo], 'ui::CGroupBox');
        local tree = GET_CHILD_RECURSIVELY(tree_box, 'inventree_' .. g_invenTypeStrList[typeNo], 'ui::CTreeControl');

        -- 아이템 없는 빈 슬롯은 숨겨라
        local slotSetNameListCnt = ui.inventory.GetInvenSlotSetNameCount();
        for i = 1, slotSetNameListCnt do
            local getSlotSetName = ui.inventory.GetInvenSlotSetNameByIndex(i - 1);
            local slotset = GET_CHILD_RECURSIVELY(tree, getSlotSetName, 'ui::CSlotSet');
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
            -- slotset = GET_CHILD_RECURSIVELY(tree, getSlotSetName, 'ui::CSlotSet');

            local slotsetnode = tree:FindByValue(getSlotSetName);
            if setpos == 'setpos' then
                local savedPos = frame:GetUserValue("INVENTORY_CUR_SCROLL_POS");
                if savedPos == 'None' then
                    savedPos = 0
                end
                tree_box:SetScrollPos(tonumber(savedPos))
            end
        end
    end

end

