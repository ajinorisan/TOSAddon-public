local addonName = "WAREHOUSE_KEEPER"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "0.0.1"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)

local acutil = require("acutil")
local json = require('json')

local base = {}

function g.SetupHook(func, baseFuncName)
    local addonUpper = string.upper(addonName)
    local replacementName = addonUpper .. "_BASE_" .. baseFuncName
    if (_G[replacementName] == nil) then
        _G[replacementName] = _G[baseFuncName];
        _G[baseFuncName] = func
    end
    base[baseFuncName] = _G[replacementName]
end

local new_add_item = {}
local new_stack_add_item = {}

local current_tab_index = 0
local max_slot_per_tab = account_warehouse.get_max_slot_per_tab()

local function is_new_item(id)
    for k, v in pairs(new_add_item) do
        if v == id then
            return true
        end
    end
    return false
end

local function is_stack_new_item(class_id)
    for k, v in pairs(new_stack_add_item) do
        if v == class_id then
            return true
        end
    end
    return false
end

local function get_tab_index(item_inv_index)
    if item_inv_index < 0 then
        item_inv_index = 0
    end
    local index = math.floor(item_inv_index / max_slot_per_tab)
    return index
end

function warehouse_keeper_save_settings()

    acutil.saveJSON(g.settingsFileLoc, g.settings);

end

function warehouse_keeper_load_settings()

    local settings, err = acutil.loadJSON(g.settingsFileLoc, g.settings)

    if err then
        -- 設定ファイル読み込み失敗時処理
        CHAT_SYSTEM(string.format("[%s] cannot load setting files", addonNameLower))
    end

    local LoginName = session.GetMySession():GetPCApc():GetName()

    if not settings then
        g.settings = {
            silver = 1000000,
            items = {}
            -- warehouse_items = {}
        }
        warehouse_keeper_save_settings()
    else
        g.settings = settings
    end

    if g.settings[g.logincid] == nil then
        g.settings[g.logincid] = {
            use = 1,
            name = LoginName,
            items = {}
        }
        warehouse_keeper_save_settings()
    end

end

function WAREHOUSE_KEEPER_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame
    g.logincid = info.GetCID(session.GetMyHandle())

    local pc = GetMyPCObject();
    local curMap = GetZoneName(pc)

    local mapCls = GetClass("Map", curMap)

    if mapCls.MapType == "City" then
        addon:RegisterMsg('OPEN_DLG_ACCOUNTWAREHOUSE', 'warehouse_keeper_reserve')
        addon:RegisterMsg("GAME_START", "warehouse_keeper_4sec")
        addon:RegisterMsg("GAME_START", "warehouse_keeper_load_settings")
        -- acutil.setupHook(warehouse_keeper_ON_ACCOUNT_WAREHOUSE_ITEM_LIST, "ON_ACCOUNT_WAREHOUSE_ITEM_LIST")
        -- acutil.setupHook(warehouse_keeper_EXEC_PUT_ITEM_TO_ACCOUNT_WAREHOUSE, "EXEC_PUT_ITEM_TO_ACCOUNT_WAREHOUSE")
        -- acutil.setupHook(warehouse_keeper_PUT_ACCOUNT_ITEM_TO_WAREHOUSE_BY_INVITEM,            "PUT_ACCOUNT_ITEM_TO_WAREHOUSE_BY_INVITEM")
        -- acutil.setupHook(warehouse_keeper_PUT_ACCOUNT_ITEM_TO_WAREHOUSE_BY_INVITEM_MSG_YESSCP,            "PUT_ACCOUNT_ITEM_TO_WAREHOUSE_BY_INVITEM_MSG_YESSCP")
        -- acutil.setupHook(warehouse_keeper_EXEC_PUT_ITEM_TO_ACCOUNT_WAREHOUSE, "EXEC_PUT_ITEM_TO_ACCOUNT_WAREHOUSE")
        -- acutil.setupEvent(addon, "ACCOUNT_WAREHOUSE_ON_CHANGE_TAB", "warehouse_keeper_ACCOUNT_WAREHOUSE_ON_CHANGE_TAB");

        local accountObj = GetMyAccountObj();

    end

end

function warehouse_keeper_reserve()

    new_add_item = {}
    new_stack_add_item = {}
    print(tostring(session.loginInfo.IsPremiumState(ITEM_TOKEN)))
    ReserveScript('warehouse_keeper_silver()', 0.5)
    -- ReserveScript('warehouse_keeper_item()', 1.0)
end

function warehouse_keeper_silver()

    local silveritem = session.GetInvItemByName(MONEY_NAME)
    local warehouseFrame = ui.GetFrame('accountwarehouse')
    local handle = warehouseFrame:GetUserIValue('HANDLE')

    local charsilver = 0
    if silveritem ~= nil then
        charsilver = tonumber(silveritem:GetAmountStr())

    end

    local silver = charsilver - tonumber(g.settings.silver)
    -- print(silver)

    -- print(silver)
    if silver == 0 then
        session.ResetItemList()
        session.AddItemIDWithAmount("0", tostring(-silver))
        item.TakeItemFromWarehouse_List(IT_ACCOUNT_WAREHOUSE, session.GetItemIDList(), handle)
    elseif silver > 0 then

        item.PutItemToWarehouse(IT_ACCOUNT_WAREHOUSE, silveritem:GetIESID(), tostring(silver), handle)
    elseif silver < 0 then
        session.ResetItemList()
        session.AddItemIDWithAmount("0", tostring(-silver))
        item.TakeItemFromWarehouse_List(IT_ACCOUNT_WAREHOUSE, session.GetItemIDList(), handle)

    end

end

function warehouse_keeper_EXEC_PUT_ITEM_TO_ACCOUNT_WAREHOUSE(frame, count, inputframe)
    inputframe:ShowWindow(0);
    local iesid = inputframe:GetUserValue("ArgString");
    local insertItem = GetObjectByGuid(iesid);
    -- print("test3")
    --[[ if warehouse_keeper_CHECK_ACCOUNT_WAREHOUSE_SLOT_COUNT_TO_PUT(insertItem) == false then

        return;
    end]]

    -- godl_index
    local goal_index = warehouse_keeper_get_valid_index()
    local exist, index = warehouse_keeper_get_exist_item_index(insertItem)
    if exist == true and index >= 0 then
        goal_index = index
    end

    -- 아이템 입고 요청
    item.PutItemToWarehouse(IT_ACCOUNT_WAREHOUSE, iesid, tostring(count), frame:GetUserIValue("HANDLE"), goal_index);

    -- new 표시
    new_add_item[#new_add_item + 1] = iesid
    if geItemTable.IsStack(insertItem.ClassID) == 1 then
        new_stack_add_item[#new_stack_add_item + 1] = insertItem.ClassID
    end
end

function warehouse_keeper_PUT_ACCOUNT_ITEM_TO_WAREHOUSE_BY_INVITEM_MSG_YESSCP(guid, count)
    local frame = ui.GetFrame("accountwarehouse");
    local invItem = GET_PC_ITEM_BY_GUID(guid);
    if invItem == nil then
        return;
    end

    local obj = GetIES(invItem:GetObject());
    -- print("test4")
    --[[if warehouse_keeper_CHECK_ACCOUNT_WAREHOUSE_SLOT_COUNT_TO_PUT(obj) == false then

        return;
    end]]

    if CHECK_EMPTYSLOT(frame, obj) == 1 then
        return
    end

    local goal_index = warehouse_keeper_get_valid_index()
    item.PutItemToWarehouse(IT_ACCOUNT_WAREHOUSE, guid, count, frame:GetUserIValue("HANDLE"), goal_index)
end
-- print(ClMsg("ItemIsNotTradable"))
function warehouse_keeper_get_goal_index(frame)

    local tab = GET_CHILD(frame, "accountwarehouse_tab");
    local gbox = GET_CHILD_RECURSIVELY(frame, "gbox")
    local slotset = GET_CHILD_RECURSIVELY(frame, "slotset")
    local tab_index = tab:GetSelectItemIndex()

    local index = 0

    local accountObj = GetMyAccountObj();
    local basic_slot_count = accountObj.BasicAccountWarehouseSlotCount + accountObj.MaxAccountWarehouseCount +
                                 accountObj.AccountWareHouseExtend + accountObj.AccountWareHouseExtendByItem +
                                 ADDITIONAL_SLOT_COUNT_BY_TOKEN

    -- 基本倉庫＝0 SLOT_INDEX＝0開始

    if tab_index == 4 then
        tab:SelectTab(tab_index)
        for j = 1, 70 do
            local slot = GET_CHILD_RECURSIVELY(frame, "slot" .. j)
            local icon = slot:GetIcon()
            if icon == nil then

                index = j + basic_slot_count + 210 - 1
                return index, tab_index
            end
        end

    elseif tab_index == 3 then
        tab:SelectTab(tab_index)
        for j = 1, 70 do
            local slot = GET_CHILD_RECURSIVELY(frame, "slot" .. j)
            local icon = slot:GetIcon()
            if icon == nil then

                index = j + basic_slot_count + 140 - 1
                return index, tab_index
            end
        end
    elseif tab_index == 2 then
        tab:SelectTab(tab_index)
        for j = 1, 70 do
            local slot = GET_CHILD_RECURSIVELY(frame, "slot" .. j)
            local icon = slot:GetIcon()
            if icon == nil then
                index = j + basic_slot_count + 140 - 1
                return index, tab_index
            end
        end
    elseif tab_index == 1 then
        tab:SelectTab(tab_index)
        for j = 1, 70 do
            local slot = GET_CHILD_RECURSIVELY(frame, "slot" .. j)
            local icon = slot:GetIcon()
            if icon == nil then
                index = j + basic_slot_count + 70 - 1
                return index, tab_index
            end
        end
    elseif tab_index == 0 then
        tab:SelectTab(tab_index)
        for j = 1, basic_slot_count do
            local slot = GET_CHILD_RECURSIVELY(frame, "slot" .. j)
            local icon = slot:GetIcon()
            if icon == nil then
                index = j - 1
                return index, tab_index
            end
        end

    end

end

function warehouse_keeper_PUT_ACCOUNT_ITEM_TO_WAREHOUSE_BY_INVITEM(frame, invItem, slot, fromFrame)
    local obj = GetIES(invItem:GetObject())

    if true == invItem.isLockState then
        ui.SysMsg(ClMsg("MaterialItemIsLock"));
        return;
    end

    local itemCls = GetClassByType("Item", invItem.type);
    if itemCls.ItemType == 'Quest' then
        ui.MsgBox(ScpArgMsg("IT_ISNT_REINFORCEABLE_ITEM"));
        return;
    end

    local enableTeamTrade = TryGetProp(itemCls, "TeamTrade");
    if enableTeamTrade ~= nil and enableTeamTrade == "NO" then
        ui.SysMsg(ClMsg("ItemIsNotTradable"));
        return;
    end

    local belongingCount = TryGetProp(obj, 'BelongingCount', 0)
    if belongingCount > 0 and belongingCount >= invItem.count then
        ui.SysMsg(ClMsg("ItemIsNotTradable"));
        return;
    end

    if TryGetProp(obj, 'CharacterBelonging', 0) == 1 then
        ui.SysMsg(ClMsg("ItemIsNotTradable"));
        return;
    end

    if fromFrame:GetName() == "inventory" then
        local maxCnt = invItem.count;
        if belongingCount > 0 then
            maxCnt = invItem.count - obj.BelongingCount;
            if maxCnt <= 0 then
                maxCnt = 0;
            end
        end

        if invItem.count > 1 or geItemTable.IsStack(obj.ClassID) == 1 then
            INPUT_NUMBER_BOX(frame, ScpArgMsg("InputCount"), "warehouse_keeper_EXEC_PUT_ITEM_TO_ACCOUNT_WAREHOUSE",
                maxCnt, 1, maxCnt, nil, tostring(invItem:GetIESID()));
        else
            if maxCnt <= 0 then
                ui.SysMsg(ClMsg("ItemIsNotTradable"));
                return;
            end

            local goal_index, tab_index = warehouse_keeper_get_goal_index(frame)

            -- Check Life Time
            if invItem.hasLifeTime == true then
                local yesscp = string.format(
                    'warehouse_keeper_PUT_ACCOUNT_ITEM_TO_WAREHOUSE_BY_INVITEM_MSG_YESSCP("%s", "%s")',
                    invItem:GetIESID(), tostring(invItem.count));
                ui.MsgBox(ScpArgMsg('PutLifeTimeItemInWareHouse{NAME}', 'NAME', itemCls.Name), yesscp, 'None');
                return;
            end

            -- 아이템 입고 요청

            print("goal_index:" .. goal_index)
            item.PutItemToWarehouse(IT_ACCOUNT_WAREHOUSE, invItem:GetIESID(), tostring(invItem.count),
                frame:GetUserIValue("HANDLE"), goal_index)

            -- new 표시
            new_add_item[#new_add_item + 1] = invItem:GetIESID()
            if geItemTable.IsStack(obj.ClassID) == 1 then
                new_stack_add_item[#new_stack_add_item + 1] = obj.ClassID
            end
            -- local accountwarehouse_tab = GET_CHILD_RECURSIVELY(frame, "accountwarehouse_tab");
            -- local tab_index = accountwarehouse_tab:GetSelectItemIndex()
            print(tostring("tab_index:" .. tab_index))
            warehouse_keeper_ON_ACCOUNT_WAREHOUSE_ITEM_LIST(frame, _, _, goal_index, tab_index);

        end

    else
        if slot ~= nil then
            AUTO_CAST(slot);
            local iconSlot = liftIcon:GetParent();
            AUTO_CAST(iconSlot);
            item.SwapSlotIndex(IT_ACCOUNT_WAREHOUSE, slot:GetSlotIndex(), iconSlot:GetSlotIndex());

        end
    end

end

function warehouse_keeper_ON_ACCOUNT_WAREHOUSE_ITEM_LIST(frame, msg, argStr, argNum, tab_index)
    local tabidx = tab_index
    if tab_index == nil then
        tab_index = current_tab_index
    end

    if msg == 'ACCOUNT_WAREHOUSE_ITEM_ADD' then
        tab_index = get_tab_index(argNum)
        if argNum == 0 and tab_index == 0 then
            tab_index = current_tab_index
        end
    end

    current_tab_index = tab_index

    if frame:IsVisible() == 0 then
        new_add_item = {}
        new_stack_add_item = {}
        return
    end

    local slotset = GET_CHILD_RECURSIVELY(frame, 'slotset');
    local gbox_warehouse = GET_CHILD_RECURSIVELY(frame, "gbox_warehouse");
    if slotset == nil then
        slotset = GET_CHILD_RECURSIVELY(frame, "slotset");
    end
    AUTO_CAST(slotset);
    slotset:ClearIconAll();
    slotset:SetSkinName('accountwarehouse_slot');

    local itemList = session.GetEtcItemList(IT_ACCOUNT_WAREHOUSE);
    local guidList = itemList:GetGuidList();
    local sortedGuidList = itemList:GetSortedGuidList();
    local isShowMap = {};
    local sortedCnt = sortedGuidList:Count();
    local saveMoney = GET_CHILD_RECURSIVELY(frame, "saveMoney");
    saveMoney:SetTextByKey('value', 0);

    local accountObj = GetMyAccountObj();
    local index = accountObj.BasicAccountWarehouseSlotCount + accountObj.MaxAccountWarehouseCount +
                      accountObj.AccountWareHouseExtend + accountObj.AccountWareHouseExtendByItem +
                      ADDITIONAL_SLOT_COUNT_BY_TOKEN
    local start_index = 0
    local last_index = 0
    -- 
    if tabidx == 0 then

        last_index = index - 1

    elseif tabidx == 1 then

        start_index = index
        last_index = (start_index + max_slot_per_tab) - 1
    elseif tabidx == 2 then

        start_index = index + max_slot_per_tab
        last_index = (start_index + max_slot_per_tab) - 1
    elseif tabidx == 3 then

        start_index = index + max_slot_per_tab * 2
        last_index = (start_index + max_slot_per_tab) - 1
    elseif tabidx == 4 then

        start_index = index + max_slot_per_tab * 3
        last_index = (start_index + max_slot_per_tab) - 1
    end

    print(sortedCnt .. "so")
    print(start_index .. "s")
    print(tostring(last_index) .. "a")

    for i = 0, sortedCnt - 1 do
        local guid = sortedGuidList:Get(i);
        local invItem = itemList:GetItemByGuid(guid);

        -- 현재 탭이 몇번이냐에 따라 그려주는 index의 번호를 선택해야 한다.      
        -- 現在のタブが何番目かによって描画するindexの番号を選択する必要があります。   
        if start_index <= invItem.invIndex and invItem.invIndex <= last_index then
            warehouse_keeper_DRAW_ITEM(invItem, slotset, saveMoney)
            isShowMap[guid] = true;
            local tab = GET_CHILD(frame, "accountwarehouse_tab");

        end
    end

    -- 아이템이 없어도 사용가능한 슬롯이면 스킨 변경 アイテムがなくても使用可能なスロットであれば、スキンの変更
    local slotIndx = imcSlot:GetEmptySlotIndex(slotset);

    local is_item_full = false
    if tab_index > 0 then
        local slot_1 = GET_EMPTY_SLOT(slotset, current_tab_index, max_slot_per_tab);
        if slot_1 == nil then
            is_item_full = true
            slotIndx = max_slot_per_tab
        end
    end

    local itemCnt = slotIndx;
    local account = session.barrack.GetMyAccount();
    local slotCount = account:GetAccountWarehouseSlotCount();
    local availableTakeCount = math.max(slotCount, slotIndx);

    if current_tab_index == 0 then
        for i = availableTakeCount, max_slot_per_tab do
            local slot = slotset:GetSlotByIndex(i);
            if slot ~= nil then
                slot:RemoveAllChild();
            end
        end
    end

    -- 추가 슬롯 음영 관련追加スロットシェード関連
    local pc = GetMyPCObject()
    if true == session.loginInfo.IsPremiumState(ITEM_TOKEN) and tab_index >= 1 then
        availableTakeCount = max_slot_per_tab
        slotCount = max_slot_per_tab
    elseif current_tab_index >= 1 then
        for i = slotIndx, availableTakeCount - 1 do
            local slot = slotset:GetSlotByIndex(i);
            if slot ~= nil then
                slot:RemoveAllChild();
            end
        end
        availableTakeCount = 0
        slotCount = 0
    end

    for i = slotIndx, availableTakeCount - 1 do
        local slot = slotset:GetSlotByIndex(i);
        if slot ~= nil then
            slot:SetSkinName('invenslot2');
            slot:RemoveAllChild();
        end
    end

    --[[local itemcnt = GET_CHILD_RECURSIVELY(frame, "itemcnt");
    local currentItemCnt = string.format('%d', itemCnt);
    if itemCnt > slotCount then
        local EXCEED_SLOT_FONT_COLOR = frame:GetUserConfig('EXCEED_SLOT_FONT_COLOR');
        currentItemCnt = '{#' .. EXCEED_SLOT_FONT_COLOR .. '}' .. currentItemCnt .. '{/}';
    end

    itemcnt:SetTextByKey('cnt', currentItemCnt);
    itemcnt:SetTextByKey('slotmax', slotCount);
    print(tostring(gbox_warehouse))
    if gbox_warehouse ~= nil then
        gbox_warehouse:UpdateData();
        gbox_warehouse:SetCurLine(0);
        gbox_warehouse:InvalidateScrollBar();
        frame:Invalidate();
        print("test2")
    end]]

    ACCOUNT_WAREHOUSE_UPDATE_VIS_LOG(frame)
    ReserveScript(string.format("warehouse_keeper_frame_update('%s', %d)", frame, tabidx), 0.1)
end

function warehouse_keeper_frame_update(frame, tabidx)
    print("warehouse_keeper_frame_update(frame, tab_index)")
    local tab = GET_CHILD(frame, "accountwarehouse_tab");
    AUTO_CAST(tab)
    -- tab:SelectTab(1)
    tab:SelectTab(tabidx)
    tab:Invalidate();
end
function warehouse_keeper_DRAW_ITEM(invItem, slotset, saveMoney)
    local obj = GetIES(invItem:GetObject());
    if obj.ClassName == MONEY_NAME then
        saveMoney:SetTextByKey('value', GetCommaedText(invItem.count))
    else
        local slotIndx = imcSlot:GetEmptySlotIndex(slotset);

        local slot = slotset:GetSlotByIndex(slotIndx)

        if slot == nil then
            slot = GET_EMPTY_SLOT(slotset, current_tab_index, max_slot_per_tab);
        end

        -- 아이커 종류 표시	
        SET_SLOT_ICOR_CATEGORY(slot, obj);

        slot:SetSkinName('invenslot2')
        local itemCls = GetIES(invItem:GetObject());
        local iconImg = GET_ITEM_ICON_IMAGE(itemCls);

        if is_new_item(invItem:GetIESID()) == true or is_stack_new_item(obj.ClassID) then
            slot:SetHeaderImage('new_inventory_icon_s')
        else
            slot:SetHeaderImage('None')
        end

        SET_SLOT_IMG(slot, iconImg)
        SET_SLOT_COUNT(slot, invItem.count)
        SET_SLOT_STAR_TEXT(slot, obj)

        SET_SLOT_STYLESET(slot, itemCls)
        SET_SLOT_IESID(slot, invItem:GetIESID())
        SET_SLOT_ITEM_TEXT_USE_INVCOUNT(slot, invItem, obj, nil)
        slot:SetMaxSelectCount(invItem.count);
        local icon = slot:GetIcon();
        icon:SetTooltipArg("accountwarehouse", invItem.type, invItem:GetIESID());
        SET_ITEM_TOOLTIP_TYPE(icon, itemCls.ClassID, itemCls, "accountwarehouse");

        if invItem.hasLifeTime == true or GET_ITEM_EXPIRE_TIME(obj) ~= 'None' then
            ICON_SET_ITEM_REMAIN_LIFETIME(icon, IT_ACCOUNT_WAREHOUSE);
            slot:SetFrontImage('clock_inven');
        else
            CLEAR_ICON_REMAIN_LIFETIME(slot, icon);
        end
    end
    -- frame:Invalidate();
end

--[[function warehouse_keeper_get_goal_index(frame)
    -- print("test1")
    local tab = GET_CHILD(frame, "accountwarehouse_tab");
    local gbox = GET_CHILD_RECURSIVELY(frame, "gbox")
    local slotset = GET_CHILD_RECURSIVELY(frame, "slotset")

    local index = 0
    local left0 = 0
    local right0 = 0
    tab:SelectTab(0)
    local itemcnt = GET_CHILD(gbox, "itemcnt")
    local length = #itemcnt:GetText()
    -- print(itemcnt:GetText())
    local accountObj = GetMyAccountObj();

    right0 = accountObj.BasicAccountWarehouseSlotCount + accountObj.MaxAccountWarehouseCount +
                 accountObj.AccountWareHouseExtend + accountObj.AccountWareHouseExtendByItem +
                 ADDITIONAL_SLOT_COUNT_BY_TOKEN

    for i = 4, 0, -1 do
        -- print("i")
        if i == 4 then
            tab:SelectTab(i)
            itemcnt = GET_CHILD(gbox, "itemcnt")
            length = #itemcnt:GetText()
            local left4 = 0

            if length == 14 then
                left4 = string.sub(itemcnt:GetText(), length - 6, length - 6) * 1 -- 左側の数字を取得
            else
                left4 = string.sub(itemcnt:GetText(), length - 7, length - 6) * 1 -- 左側の数字を取得
            end
            -- local slotIndx = imcSlot:GetEmptySlotIndex(slotset);
            for j = 1, 70 do
                local slot = GET_CHILD_RECURSIVELY(frame, "slot" .. j)

                local icon = slot:GetIcon()

                if icon == nil then
                    print(j .. ":1")
                    index = j + right0 + 210 - 1

                    return index

                end
            end

            --[[if left4 < 70 then
                index = right0 + 280
                return index
            end
        elseif i == 3 then
            tab:SelectTab(i)
            itemcnt = GET_CHILD(gbox, "itemcnt")
            length = #itemcnt:GetText()
            local left3 = 0

            if length == 14 then
                left3 = string.sub(itemcnt:GetText(), length - 6, length - 6) * 1 -- 左側の数字を取得
            else
                left3 = string.sub(itemcnt:GetText(), length - 7, length - 6) * 1 -- 左側の数字を取得
            end

            for j = 1, 70 do
                local slot = GET_CHILD_RECURSIVELY(frame, "slot" .. j)

                local icon = slot:GetIcon()

                if icon == nil then
                    index = j + right0 + 140 - 1
                    -- print(index)
                    return index

                end
            end
        elseif i == 2 then
            tab:SelectTab(i)
            itemcnt = GET_CHILD(gbox, "itemcnt")
            length = #itemcnt:GetText()
            local left2 = 0

            if length == 14 then
                left2 = string.sub(itemcnt:GetText(), length - 6, length - 6) * 1 -- 左側の数字を取得
            else
                left2 = string.sub(itemcnt:GetText(), length - 7, length - 6) * 1 -- 左側の数字を取得
            end

            for j = 1, 70 do
                local slot = GET_CHILD_RECURSIVELY(frame, "slot" .. j)

                local icon = slot:GetIcon()

                if icon == nil then
                    index = j + right0 + 70 - 1
                    -- print(index)
                    return index

                end
            end
        elseif i == 1 then
            tab:SelectTab(i)
            itemcnt = GET_CHILD(gbox, "itemcnt")
            length = #itemcnt:GetText()
            local left1 = 0

            if length == 14 then
                left1 = string.sub(itemcnt:GetText(), length - 6, length - 6) * 1 -- 左側の数字を取得
            else
                left1 = string.sub(itemcnt:GetText(), length - 7, length - 6) * 1 -- 左側の数字を取得
            end

            for j = 1, 70 do
                local slot = GET_CHILD_RECURSIVELY(frame, "slot" .. j)

                local icon = slot:GetIcon()

                if icon == nil then
                    index = j + right0 - 1
                    -- print(index)
                    return index

                end
            end
        elseif i == 0 then
            tab:SelectTab(0)
            local slot = GET_CHILD_RECURSIVELY(frame, "slot" .. j)

            local icon = slot:GetIcon()

            for j = 1, right0 do
                local slot = GET_CHILD_RECURSIVELY(frame, "slot" .. j)

                local icon = slot:GetIcon()

                if icon == nil then
                    index = j - 1
                    -- print(index)
                    return index

                end
            end
        else
            -- print("test888")
            ui.SysMsg(ClMsg('CannotPutBecauseMaxSlot'));
            return
        end
    end

end]]

function warehouse_keeper_get_valid_index()
    -- print("teest")
    local itemList = session.GetEtcItemList(IT_ACCOUNT_WAREHOUSE);
    local guidList = itemList:GetGuidList();
    local sortedGuidList = itemList:GetSortedGuidList();
    local sortedCnt = sortedGuidList:Count();

    -- local start_index = (current_tab_index * max_slot_per_tab)
    -- local last_index = (start_index + max_slot_per_tab) - 1

    local accountObj = GetMyAccountObj();
    local slot_index = accountObj.BasicAccountWarehouseSlotCount + accountObj.MaxAccountWarehouseCount +
                           accountObj.AccountWareHouseExtend + accountObj.AccountWareHouseExtendByItem +
                           ADDITIONAL_SLOT_COUNT_BY_TOKEN
    local start_index = 0
    local last_index = 0
    local warehouseFrame = ui.GetFrame('accountwarehouse')
    local accountwarehouse_tab = GET_CHILD_RECURSIVELY(warehouseFrame, "accountwarehouse_tab");
    local tab_index = accountwarehouse_tab:GetSelectItemIndex()

    if tab_index == 0 then
        -- print(tab_index .. "a")
        last_index = slot_index - 1

    else
        -- print(tab_index .. "b")
        start_index = (((tab_index - 1) * max_slot_per_tab) + slot_index)
        last_index = (start_index + max_slot_per_tab) - 1
    end

    -- print("last_index:" .. last_index)
    local __set = {}
    for i = 0, sortedCnt - 1 do
        local guid = sortedGuidList:Get(i)
        local invItem = itemList:GetItemByGuid(guid)
        local obj = GetIES(invItem:GetObject());
        if obj.ClassName ~= MONEY_NAME then
            if start_index <= invItem.invIndex and invItem.invIndex <= last_index and __set[invItem.invIndex] == nil then

                __set[invItem.invIndex] = 1
            end
        end
    end

    -- print("start_index:" .. start_index)
    local index = start_index
    for k, v in pairs(__set) do
        if __set[index] ~= 1 then
            break
        else
            index = index + 1

        end
    end

    return index
end
-- print(ClMsg('CannotPutBecauseMaxSlot'))
function warehouse_keeper_CHECK_ACCOUNT_WAREHOUSE_SLOT_COUNT_TO_PUT(insertItem)
    local index = warehouse_keeper_get_valid_index()
    -- print("index:" .. tostring(index))
    local account = session.barrack.GetMyAccount();
    -- local slotCount = account:GetAccountWarehouseSlotCount();
    local slotCount = g.max_count
    -- print("slotCount:" .. tostring(slotCount))
    local itemList = session.GetEtcItemList(IT_ACCOUNT_WAREHOUSE);
    local itemCnt = 0;
    local guidList = itemList:GetGuidList();

    local is_exist_stack_item = false

    local cnt = guidList:Count();
    for i = 0, cnt - 1 do
        local guid = guidList:Get(i);
        local invItem = itemList:GetItemByGuid(guid);
        local obj = GetIES(invItem:GetObject());

        if obj.ClassName ~= MONEY_NAME and TryGetProp(obj, 'MaxStack', 1) > 1 and TryGetProp(insertItem, 'ClassID', 0) ==
            TryGetProp(obj, 'ClassID', -1) then
            is_exist_stack_item = true
        end

        if obj.ClassName ~= MONEY_NAME and invItem.invIndex < max_slot_per_tab then
            itemCnt = itemCnt + 1;
        end
    end
    -- print("itemCnt:" .. tostring(itemCnt))
    if is_exist_stack_item == false and (slotCount <= itemCnt and index < max_slot_per_tab) then
        -- print("test1")
        ui.SysMsg(ClMsg('CannotPutBecauseMaxSlot'));
        return false;
    end

    if is_exist_stack_item == false and (slotCount <= index and index < max_slot_per_tab) then
        -- print("test2")
        ui.SysMsg(ClMsg('CannotPutBecauseMaxSlot'));
        return false;
    end
    return true;
end

function warehouse_keeper_get_exist_item_index(insertItem)
    local ret1 = false
    local ret2 = -1

    if geItemTable.IsStack(insertItem.ClassID) == 1 then
        local itemList = session.GetEtcItemList(IT_ACCOUNT_WAREHOUSE);
        local sortedGuidList = itemList:GetSortedGuidList();
        local sortedCnt = sortedGuidList:Count();

        for i = 0, sortedCnt - 1 do
            local guid = sortedGuidList:Get(i);
            local invItem = itemList:GetItemByGuid(guid)
            local invItem_obj = GetIES(invItem:GetObject());
            if insertItem.ClassID == invItem_obj.ClassID then
                ret1 = true
                ret2 = invItem.invIndex
                break
            end
        end
        return ret1, ret2
    else
        return false, -1
    end
end

function warehouse_keeper_EXEC_PUT_ITEM_TO_ACCOUNT_WAREHOUSE(frame, count, inputframe)
    inputframe:ShowWindow(0);
    local iesid = inputframe:GetUserValue("ArgString");
    local insertItem = GetObjectByGuid(iesid);
    -- print("test6")
    --[[if warehouse_keeper_CHECK_ACCOUNT_WAREHOUSE_SLOT_COUNT_TO_PUT(insertItem) == false then
        return;
    end]]

    -- godl_index
    local goal_index = warehouse_keeper_get_valid_index()
    local exist, index = warehouse_keeper_get_exist_item_index(insertItem)
    if exist == true and index >= 0 then
        goal_index = index
    end

    -- 아이템 입고 요청
    item.PutItemToWarehouse(IT_ACCOUNT_WAREHOUSE, iesid, tostring(count), frame:GetUserIValue("HANDLE"), goal_index);

    -- new 표시
    new_add_item[#new_add_item + 1] = iesid
    if geItemTable.IsStack(insertItem.ClassID) == 1 then
        new_stack_add_item[#new_stack_add_item + 1] = insertItem.ClassID
    end
end

function warehouse_keeper_receive_item(frame, ctrl)
    local frame = ui.GetFrame("accountwarehouse");
    -- print(tostring(ctrl:GetName()))
    local icon = ctrl:GetIcon()
    local iconInfo = icon:GetInfo()
    local iesid = iconInfo:GetIESID()
    local invItem = session.GetEtcItemByGuid(IT_ACCOUNT_WAREHOUSE, iesid);
    local count = invItem.count
    session.ResetItemList();

    session.AddItemID(iesid, count);
    -- print("test")
    -- print(tostring(iesid) .. ":" .. tostring(count))
    item.TakeItemFromWarehouse_List(IT_ACCOUNT_WAREHOUSE, session.GetItemIDList(), frame:GetUserIValue("HANDLE"));
end

-- local current_tab_index = 0

function warehouse_keeper_warehouseframe_setting()
    -- print("setting")
    local warehouseFrame = ui.GetFrame('accountwarehouse')
    local deposit = GET_CHILD_RECURSIVELY(warehouseFrame, "Deposit")
    local withdraw = GET_CHILD_RECURSIVELY(warehouseFrame, "Withdraw")
    deposit:SetMargin(0, 0, 130, 0)
    withdraw:SetMargin(0, 0, 30, 0)

    local setting = warehouseFrame:CreateOrGetControl("button", "setting", 630, 775, 25, 25)
    AUTO_CAST(setting)
    setting:SetSkinName("None")
    setting:SetText("{img config_button_normal 25 25}")
    setting:SetEventScript(ui.LBUTTONUP, "warehouse_keeper_frame_init")

end

function warehouse_keeper_get_index()

end

function warehouse_keeper_4sec()

    ReserveScript("warehouse_keeper_warehouseframe_setting()", 4.0)
end

function warehouse_keeper_item()

    local frame = ui.GetFrame("accountwarehouse");
    local fromFrame = ui.GetFrame("inventory");
    local handle = frame:GetUserIValue('HANDLE')

    if frame:IsVisible() == 1 then
        -- print("test")
        local goal_index = warehouse_keeper_get_goal_index(frame)
        -- print(goal_index)
        for key, value in pairs(g.settings.items) do
            -- print("Key:" .. key)
            for k, v in pairs(value) do
                -- print("  " .. k .. ":" .. v)
                local invItemList = session.GetInvItemList()
                local guidList = invItemList:GetGuidList();
                local cnt = guidList:Count();

                for i = 0, cnt - 1 do
                    local guid = guidList:Get(i);
                    local invItem = invItemList:GetItemByGuid(guid)
                    local count = invItem.count
                    if k == "count" and v ~= 0 then
                        -- print(v .. "あ")
                        count = v
                    end
                    local itemobj = GetIES(invItem:GetObject())
                    local iesid = invItem:GetIESID()

                    if tostring(iesid) == tostring(v) then
                        -- print(tostring(invItem.count))
                        -- print(count .. "aaa")
                        item.PutItemToWarehouse(IT_ACCOUNT_WAREHOUSE, iesid, tostring(count), handle, goal_index)
                        session.ResetItemList()
                        ReserveScript("warehouse_keeper_item()", 0.3)
                        -- break
                        return
                    end

                    --[[local insertItem = GetObjectByGuid(iesid);
                    new_add_item[#new_add_item + 1] = invItem:GetIESID()
                    if geItemTable.IsStack(insertItem.ClassID) == 1 then
                        new_stack_add_item[#new_stack_add_item + 1] = insertItem.ClassID
                    end
                    print("test")]]
                    -- 
                end
            end
        end
    end

end

-- Deposit --Withdraw

function warehouse_keeper_close(frame, ctrl, argStr, argNum)
    frame:ShowWindow(0)
end

function warehouse_keeper_frame_drop(frame, ctrl, argStr, argNum)

    local lifticon = ui.GetLiftIcon();
    local fromframe = lifticon:GetTopParentFrame();

    local iconinfo = lifticon:GetInfo();
    local type = iconinfo.type
    local itemcls = GetClassByType("Item", type)

    for key, value in pairs(g.settings.items) do
        -- print("Key:" .. key)
        for k, v in pairs(value) do
            -- print("  " .. k .. ":" .. v .. ":" .. type)
            if tostring(type) == tostring(v) then
                ui.SysMsg("Already registered.")
                return
            end
        end
    end
    local clsid = tostring(itemcls.ClassID)
    local index = string.gsub(ctrl:GetName(), "slot", "") * 1

    local slot_icon = ctrl:GetIcon();

    local guid = iconinfo:GetIESID();
    local item = GET_ITEM_BY_GUID(guid);
    local obj = GetIES(item:GetObject());

    if fromframe:GetName() == "inventory" and slot_icon == nil then
        if true == item.isLockState then
            ui.SysMsg(ClMsg("MaterialItemIsLock"));
            return;
        end

        if itemcls.ItemType == 'Quest' then
            ui.MsgBox(ScpArgMsg("IT_ISNT_REINFORCEABLE_ITEM"));
            return;
        end

        local enableTeamTrade = TryGetProp(itemcls, "TeamTrade");
        if enableTeamTrade ~= nil and enableTeamTrade == "NO" then
            ui.SysMsg(ClMsg("ItemIsNotTradable"));
            return;
        end

        local belongingCount = TryGetProp(obj, 'BelongingCount', 0)
        if belongingCount > 0 and belongingCount >= item.count then
            ui.SysMsg(ClMsg("ItemIsNotTradable"));
            return;
        end

        if TryGetProp(obj, 'CharacterBelonging', 0) == 1 then
            ui.SysMsg(ClMsg("ItemIsNotTradable"));
            return;
        end

        if tonumber(itemcls.MaxStack) > 1 then
            g.iesid = guid

            INPUT_NUMBER_BOX(frame, 'Enter the number to be left in the inventory.', "warehouse_keeper_consume_item", 0,
                0, tonumber(itemcls.MaxStack), type, tostring(index), nil)
        else
            g.iesid = ""

            if g.settings.items[tostring(index)] == nil then
                g.settings.items[tostring(index)] = {
                    clsid = clsid,
                    iesid = guid,
                    count = 0
                }
            end
            SET_SLOT_ITEM_CLS(ctrl, itemcls)
            warehouse_keeper_save_settings()
        end

    else
        return
    end
end

function warehouse_keeper_consume_item(frame, count, inputFrame)
    local type = inputFrame:GetValue()
    local index = inputFrame:GetUserValue("ArgString");
    local itemcls = GetClassByType("Item", type)
    local frame = ui.GetFrame("warehouse_keeper")
    local slot = GET_CHILD_RECURSIVELY(frame, "slot" .. index)

    -- print(tostring(type))
    -- print(tostring(index))

    -- print(count)
    if g.settings.items[tostring(index)] == nil then
        g.settings.items[tostring(index)] = {
            clsid = tostring(type),
            iesid = g.iesid,
            count = tonumber(count)
        }
    end
    warehouse_keeper_save_settings()
    SET_SLOT_ITEM_CLS(slot, itemcls)

    inputFrame:ShowWindow(0)

end

function warehouse_keeper_frame_init(frame, ctrl, argStr, argNum)
    local warehouseFrame = ui.GetFrame('accountwarehouse')
    warehouseFrame:ShowWindow(0)
    local inventoryFrame = ui.GetFrame('inventory')
    inventoryFrame:ShowWindow(1)

    local frame = ui.GetFrame(addonNameLower)
    frame:RemoveAllChild()
    frame:SetPos(665, 70)
    frame:Resize(740, 615)
    frame:SetLayerLevel(96)

    frame:SetTitleName('{ol}{s28}Warehouse Keeper')

    if frame:IsVisible() == 1 then
        frame:ShowWindow(0)
        return
    else
        frame:ShowWindow(1)
    end

    local close = frame:CreateOrGetControl("button", "close", 0, 0, 25, 25)
    AUTO_CAST(close)
    close:SetImage("testclose_button")
    close:SetOffset(670, 30)
    close:SetEventScript(ui.LBUTTONUP, "warehouse_keeper_close")

    local maney_text = frame:CreateOrGetControl("richtext", "maney_text", 50, 0, 0, 0)
    AUTO_CAST(maney_text);
    maney_text:SetText("{ol}automatic deposit and withdrawal")

    local maney_check = frame:CreateOrGetControl('checkbox', 'maney_check', 25, 0, 25, 25)
    AUTO_CAST(maney_check);
    maney_check:SetEventScript(ui.LBUTTONUP, "warehouse_keeper_setting_check")

    local item_text = frame:CreateOrGetControl("richtext", "item_text", 50, 30, 0, 0)
    AUTO_CAST(item_text);
    item_text:SetText("{ol}Automatic item receipt and dispatch")

    local item_check = frame:CreateOrGetControl('checkbox', 'item_check', 25, 30, 25, 25)
    AUTO_CAST(item_check);

    local amount_text = frame:CreateOrGetControl("richtext", "amount_text", 400, 0, 0, 0)
    AUTO_CAST(amount_text);
    amount_text:SetText("{ol}deposit and withdrawal amount")

    local amount_edit = frame:CreateOrGetControl('edit', 'amount_edit', 400, 30, 250, 25)
    AUTO_CAST(amount_edit)
    amount_edit:SetFontName("white_16_ol")
    amount_edit:SetTextAlign("center", "center")
    -- print(tostring(g.settings.silver))
    amount_edit:SetText(GET_COMMAED_STRING(tonumber(g.settings.silver)))

    local team_text = frame:CreateOrGetControl("richtext", "team_text", 25, 70, 0, 0)
    AUTO_CAST(team_text);
    team_text:SetText("{ol}team setting")

    local char_text = frame:CreateOrGetControl("richtext", "char_text", 25, 520, 0, 0)
    AUTO_CAST(char_text);
    char_text:SetText("{ol}character setting")

    local team_gb = frame:CreateOrGetControl("groupbox", "team_gb", 20, 90, frame:GetWidth() - 40, 420)
    team_gb:SetSkinName("test_frame_low")
    AUTO_CAST(team_gb);

    local team_slotset = team_gb:CreateOrGetControl('slotset', 'team_slotset', 10, 10, 0, 0)
    AUTO_CAST(team_slotset);
    team_slotset:SetSlotSize(40, 40) -- スロットの大きさ
    team_slotset:EnablePop(1)
    team_slotset:EnableDrag(1)
    team_slotset:EnableDrop(1)
    -- team_slotset:SetNumberMode(1)
    team_slotset:SetColRow(17, 10) -- スロットの配置と個数
    team_slotset:SetSpc(0, 0)
    team_slotset:SetSkinName('slot')
    team_slotset:SetEventScript(ui.DROP, "warehouse_keeper_frame_drop")
    team_slotset:SetEventScript(ui.RBUTTONUP, "warehouse_keeper_icon_clear")
    team_slotset:CreateSlots()
    local slotcount = team_slotset:GetSlotCount()

    for i = 1, slotcount do
        local slot = GET_CHILD_RECURSIVELY(team_slotset, "slot" .. i)
        local str_index = tostring(i)
        for key, value in pairs(g.settings.items) do
            if key == str_index then
                for k, v in pairs(value) do
                    -- print("  " .. k .. ":" .. v)
                    local itemcls = GetClassByType("Item", v)

                    SET_SLOT_ITEM_CLS(slot, itemcls)

                    if k == "count" and v ~= 0 then
                        -- print(tostring(k) .. ":" .. v .. "あ")
                        SET_SLOT_COUNT_TEXT(slot, v)
                    end
                end

            end
        end
    end

    local char_gb = frame:CreateOrGetControl("groupbox", "char_gb", 20, 540, frame:GetWidth() - 40, 60)
    char_gb:SetSkinName("test_frame_low")
    AUTO_CAST(char_gb);

    local char_slotset = char_gb:CreateOrGetControl('slotset', 'char_slotset', 10, 10, 0, 0)
    AUTO_CAST(char_slotset);
    char_slotset:SetSlotSize(40, 40) -- スロットの大きさ
    char_slotset:EnablePop(1)
    char_slotset:EnableDrag(1)
    char_slotset:EnableDrop(1)
    char_slotset:SetColRow(17, 1) -- スロットの配置と個数
    char_slotset:SetSpc(0, 0)
    char_slotset:SetSkinName('slot')
    char_slotset:CreateSlots()

end
function warehouse_keeper_setting_check(frame, ctrl, argStr, argNum)

end

function warehouse_keeper_icon_clear(frame, ctrl, argStr, argNum)
    local str_index = string.gsub(ctrl:GetName(), "slot", "")
    for key, value in pairs(g.settings.items) do
        if key == str_index then
            ctrl:ClearIcon();
            g.settings.items[str_index] = nil
            warehouse_keeper_save_settings()

        end
    end
end
function warehouse_keeper_ACCOUNT_WAREHOUSE_ON_CHANGE_TAB()
    warehouse_keeper_ACCOUNT_WAREHOUSE_ON_CHANGE_TAB_()
end

function warehouse_keeper_ACCOUNT_WAREHOUSE_ON_CHANGE_TAB_()
    print("test")
    local warehouseFrame = ui.GetFrame('accountwarehouse')
    local accountwarehouse_tab = GET_CHILD_RECURSIVELY(warehouseFrame, "accountwarehouse_tab");

    local gbox = GET_CHILD_RECURSIVELY(warehouseFrame, "gbox")
    local itemcnt = GET_CHILD(gbox, "itemcnt")
    local accountObj = GetMyAccountObj();
    local basic_count = accountObj.BasicAccountWarehouseSlotCount + accountObj.MaxAccountWarehouseCount +
                            accountObj.AccountWareHouseExtend + accountObj.AccountWareHouseExtendByItem +
                            ADDITIONAL_SLOT_COUNT_BY_TOKEN
    local max_count = basic_count + 280

    local slotgbox = GET_CHILD_RECURSIVELY(warehouseFrame, "slotgbox");
    slotgbox:RemoveAllChild()
    local slotset = slotgbox:CreateOrGetControl('slotset', 'slotset', 20, 0, 0, 0)
    AUTO_CAST(slotset);
    slotset:SetSlotSize(60, 60) -- スロットの大きさ
    slotset:EnablePop(0)
    slotset:EnableDrag(0)
    slotset:EnableDrop(1)
    slotset:SetColRow(10, 7) -- スロットの配置と個数
    slotset:SetSpc(1, 1)

    if accountwarehouse_tab:GetSelectItemIndex() == 0 then
        slotset:SetSlotCount(basic_count)
    else
        slotset:SetSlotCount(70)
    end

    slotset:SetSkinName('invenslot2')
    slotset:CreateSlots();

    local itemList = session.GetEtcItemList(IT_ACCOUNT_WAREHOUSE)
    local guidList = itemList:GetGuidList()
    local cnt = guidList:Count()
    local between = max_count - cnt + 1
    print(between)
    local settings = {
        items = {}
    }

    -- 1からの昇順にアイテムを処理
    for i = 0, cnt - 1 do
        local guid = guidList:Get(i)
        local invItem = itemList:GetItemByGuid(guid)
        local obj = GetIES(invItem:GetObject())

        if obj.ClassName == MONEY_NAME then
            settings.silver = invItem.count
            print("Silver" .. i)
        else
            -- MONEY_NAME 以外のアイテムをテーブルに追加
            local itemData = {
                index = i, -- 元のインデックスを追加
                invItem = invItem,
                itemid = obj.ClassID,
                name = obj.ClassName,
                count = invItem.count
            }
            table.insert(settings.items, itemData)
        end
    end
    -- nameで昇順に並び替え
    table.sort(settings.items, function(a, b)
        return a.itemid < b.itemid
    end)

    -- ソート後の順番でindexを再度振り直す
    for i, itemData in ipairs(settings.items) do
        itemData.index = i + between -- インデックスは0ベースなので、1を引く
    end

    -- settings テーブル内の silver キーの値を表示

    print("Silver: " .. (settings.silver or 0))

    print("Other Items:")
    for _, itemData in ipairs(settings.items) do

        print("Index: " .. itemData.index .. ", Name: " .. itemData.name .. ", Count: " .. itemData.count)
    end
    local j = 0
    print(basic_count)
    if accountwarehouse_tab:GetSelectItemIndex() == 0 then

        for i = 1, basic_count do
            for _, itemData in ipairs(settings.items) do
                if itemData.index == i then
                    local itemCls = GetIES(itemData.invItem:GetObject());
                    local obj = GetIES(itemData.invItem:GetObject())
                    local iconImg = GET_ITEM_ICON_IMAGE(itemCls);
                    local slot = GET_CHILD_RECURSIVELY(slotset, "slot" .. i)
                    SET_SLOT_IMG(slot, iconImg)
                    SET_SLOT_COUNT(slot, itemData.count)
                    SET_SLOT_STYLESET(slot, itemCls)
                    SET_SLOT_IESID(slot, itemData.invItem:GetIESID())
                    SET_SLOT_ITEM_TEXT_USE_INVCOUNT(slot, itemData.invItem, obj, nil)
                    slot:SetMaxSelectCount(itemData.invItem.count);
                    local icon = slot:GetIcon();
                    icon:SetTooltipArg("accountwarehouse", itemData.invItem.type, itemData.invItem:GetIESID());
                    SET_ITEM_TOOLTIP_TYPE(icon, itemCls.ClassID, itemCls, "accountwarehouse");
                    if itemData.invItem.hasLifeTime == true or TryGetProp(obj, 'ExpireDateTime', 'None') ~= 'None' then
                        ICON_SET_ITEM_REMAIN_LIFETIME(icon, IT_ACCOUNT_WAREHOUSE);
                        slot:SetFrontImage('clock_inven');
                    else
                        CLEAR_ICON_REMAIN_LIFETIME(slot, icon);
                    end
                    print("Index: " .. itemData.index .. ", Name: " .. itemData.name .. ", Count: " .. itemData.count)
                    -- アイカーの種類表示
                    SET_SLOT_ICOR_CATEGORY(slot, itemCls);
                    local iconInfo = icon:GetInfo()
                    if iconInfo ~= nil then
                        j = j + 1
                    end
                end
            end

        end
    elseif accountwarehouse_tab:GetSelectItemIndex() == 1 then

        for i = basic_count + 1, basic_count + 70 do
            for _, itemData in ipairs(settings.items) do
                if itemData.index == i then
                    local itemCls = GetIES(itemData.invItem:GetObject());
                    local obj = GetIES(itemData.invItem:GetObject())
                    local iconImg = GET_ITEM_ICON_IMAGE(itemCls);
                    local slot = GET_CHILD_RECURSIVELY(slotset, "slot" .. i - basic_count)
                    SET_SLOT_IMG(slot, iconImg)
                    SET_SLOT_COUNT(slot, itemData.count)
                    SET_SLOT_STYLESET(slot, itemCls)
                    SET_SLOT_IESID(slot, itemData.invItem:GetIESID())
                    SET_SLOT_ITEM_TEXT_USE_INVCOUNT(slot, itemData.invItem, obj, nil)
                    slot:SetMaxSelectCount(itemData.invItem.count);
                    local icon = slot:GetIcon();
                    icon:SetTooltipArg("accountwarehouse", itemData.invItem.type, itemData.invItem:GetIESID());
                    SET_ITEM_TOOLTIP_TYPE(icon, itemCls.ClassID, itemCls, "accountwarehouse");
                    if itemData.invItem.hasLifeTime == true or TryGetProp(obj, 'ExpireDateTime', 'None') ~= 'None' then
                        ICON_SET_ITEM_REMAIN_LIFETIME(icon, IT_ACCOUNT_WAREHOUSE);
                        slot:SetFrontImage('clock_inven');
                    else
                        CLEAR_ICON_REMAIN_LIFETIME(slot, icon);
                    end
                    print("Index: " .. itemData.index .. ", Name: " .. itemData.name .. ", Count: " .. itemData.count)
                    -- アイカーの種類表示
                    SET_SLOT_ICOR_CATEGORY(slot, itemCls);
                    local iconInfo = icon:GetInfo()
                    if iconInfo ~= nil then
                        j = j + 1
                    end
                end
            end

        end

    elseif accountwarehouse_tab:GetSelectItemIndex() == 2 then

        for i = basic_count + 1 + 70, basic_count + 70 + 70 do
            for _, itemData in ipairs(settings.items) do
                if itemData.index == i then
                    local itemCls = GetIES(itemData.invItem:GetObject());
                    local obj = GetIES(itemData.invItem:GetObject())
                    local iconImg = GET_ITEM_ICON_IMAGE(itemCls);
                    local slot = GET_CHILD_RECURSIVELY(slotset, "slot" .. i - basic_count - 70)
                    SET_SLOT_IMG(slot, iconImg)
                    SET_SLOT_COUNT(slot, itemData.count)
                    SET_SLOT_STYLESET(slot, itemCls)
                    SET_SLOT_IESID(slot, itemData.invItem:GetIESID())
                    SET_SLOT_ITEM_TEXT_USE_INVCOUNT(slot, itemData.invItem, obj, nil)
                    slot:SetMaxSelectCount(itemData.invItem.count);
                    local icon = slot:GetIcon();
                    icon:SetTooltipArg("accountwarehouse", itemData.invItem.type, itemData.invItem:GetIESID());
                    SET_ITEM_TOOLTIP_TYPE(icon, itemCls.ClassID, itemCls, "accountwarehouse");
                    if itemData.invItem.hasLifeTime == true or TryGetProp(obj, 'ExpireDateTime', 'None') ~= 'None' then
                        ICON_SET_ITEM_REMAIN_LIFETIME(icon, IT_ACCOUNT_WAREHOUSE);
                        slot:SetFrontImage('clock_inven');
                    else
                        CLEAR_ICON_REMAIN_LIFETIME(slot, icon);
                    end
                    print("Index: " .. itemData.index .. ", Name: " .. itemData.name .. ", Count: " .. itemData.count)
                    -- アイカーの種類表示
                    SET_SLOT_ICOR_CATEGORY(slot, itemCls);
                    local iconInfo = icon:GetInfo()
                    if iconInfo ~= nil then
                        j = j + 1
                    end
                end
            end

        end

    elseif accountwarehouse_tab:GetSelectItemIndex() == 3 then

        for i = basic_count + 1 + 140, basic_count + 210 do
            for _, itemData in ipairs(settings.items) do
                if itemData.index == i then
                    local itemCls = GetIES(itemData.invItem:GetObject());
                    local obj = GetIES(itemData.invItem:GetObject())
                    local iconImg = GET_ITEM_ICON_IMAGE(itemCls);
                    local slot = GET_CHILD_RECURSIVELY(slotset, "slot" .. i - basic_count - 140)
                    SET_SLOT_IMG(slot, iconImg)
                    SET_SLOT_COUNT(slot, itemData.count)
                    SET_SLOT_STYLESET(slot, itemCls)
                    SET_SLOT_IESID(slot, itemData.invItem:GetIESID())
                    SET_SLOT_ITEM_TEXT_USE_INVCOUNT(slot, itemData.invItem, obj, nil)
                    slot:SetMaxSelectCount(itemData.invItem.count);
                    local icon = slot:GetIcon();
                    icon:SetTooltipArg("accountwarehouse", itemData.invItem.type, itemData.invItem:GetIESID());
                    SET_ITEM_TOOLTIP_TYPE(icon, itemCls.ClassID, itemCls, "accountwarehouse");
                    if itemData.invItem.hasLifeTime == true or TryGetProp(obj, 'ExpireDateTime', 'None') ~= 'None' then
                        ICON_SET_ITEM_REMAIN_LIFETIME(icon, IT_ACCOUNT_WAREHOUSE);
                        slot:SetFrontImage('clock_inven');
                    else
                        CLEAR_ICON_REMAIN_LIFETIME(slot, icon);
                    end
                    print("Index: " .. itemData.index .. ", Name: " .. itemData.name .. ", Count: " .. itemData.count)
                    -- アイカーの種類表示
                    SET_SLOT_ICOR_CATEGORY(slot, itemCls);
                    local iconInfo = icon:GetInfo()
                    if iconInfo ~= nil then
                        j = j + 1
                    end
                end
            end

        end
    elseif accountwarehouse_tab:GetSelectItemIndex() == 4 then

        for i = basic_count + 1 + 210, basic_count + 280 do
            for _, itemData in ipairs(settings.items) do
                if itemData.index == i then
                    local itemCls = GetIES(itemData.invItem:GetObject());
                    local obj = GetIES(itemData.invItem:GetObject())
                    local iconImg = GET_ITEM_ICON_IMAGE(itemCls);
                    local slot = GET_CHILD_RECURSIVELY(slotset, "slot" .. i - basic_count - 210)
                    SET_SLOT_IMG(slot, iconImg)
                    SET_SLOT_COUNT(slot, itemData.count)
                    SET_SLOT_STYLESET(slot, itemCls)
                    SET_SLOT_IESID(slot, itemData.invItem:GetIESID())
                    SET_SLOT_ITEM_TEXT_USE_INVCOUNT(slot, itemData.invItem, obj, nil)
                    slot:SetMaxSelectCount(itemData.invItem.count);
                    local icon = slot:GetIcon();
                    icon:SetTooltipArg("accountwarehouse", itemData.invItem.type, itemData.invItem:GetIESID());
                    SET_ITEM_TOOLTIP_TYPE(icon, itemCls.ClassID, itemCls, "accountwarehouse");
                    if itemData.invItem.hasLifeTime == true or TryGetProp(obj, 'ExpireDateTime', 'None') ~= 'None' then
                        ICON_SET_ITEM_REMAIN_LIFETIME(icon, IT_ACCOUNT_WAREHOUSE);
                        slot:SetFrontImage('clock_inven');
                    else
                        CLEAR_ICON_REMAIN_LIFETIME(slot, icon);
                    end
                    print("Index: " .. itemData.index .. ", Name: " .. itemData.name .. ", Count: " .. itemData.count)
                    -- アイカーの種類表示
                    SET_SLOT_ICOR_CATEGORY(slot, itemCls);
                    local iconInfo = icon:GetInfo()
                    if iconInfo ~= nil then
                        j = j + 1
                    end
                end
            end

        end

    end

    itemcnt:SetTextByKey('cnt', j);
    if accountwarehouse_tab:GetSelectItemIndex() == 0 then
        itemcnt:SetTextByKey('slotmax', basic_count);
    else
        itemcnt:SetTextByKey('slotmax', 70);
    end
    --[[local k = 0

    for i = 0, cnt - 1 do

        local guid = guidList:Get(i)
        local invItem = itemList:GetItemByGuid(guid)
        local obj = GetIES(invItem:GetObject())
        local itemCls = GetIES(invItem:GetObject());
        local iesid = invItem:GetIESID()
        local itemName = obj.ClassName
        local itemID = obj.ClassID
        local invIndex = invItem.invIndex
        local invCount = invItem.count

        if obj.ClassName ~= MONEY_NAME then

            if accountwarehouse_tab:GetSelectItemIndex() == 1 then

                local count = 139

                local j = 1
                for i = 70, count do

                    local slot = GET_CHILD_RECURSIVELY(slotset, "slot" .. j)

                    if i == invIndex then

                        slot:SetSkinName('invenslot2')

                        local iconImg = GET_ITEM_ICON_IMAGE(itemCls);

                        if is_new_item(invItem:GetIESID()) == true or is_stack_new_item(obj.ClassID) then
                            slot:SetHeaderImage('new_inventory_icon_s')
                        else
                            slot:SetHeaderImage('None')
                        end

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
                        local iconInfo = icon:GetInfo()
                        if iconInfo ~= nil then
                            k = k + 1
                        end
                    end
                    j = j + 1
                end

            elseif accountwarehouse_tab:GetSelectItemIndex() == 2 then

                local count = 209

                local j = 1
                for i = 141, count do

                    local slot = GET_CHILD_RECURSIVELY(slotset, "slot" .. j)

                    if i - 1 == invIndex then

                        slot:SetSkinName('invenslot2')

                        local iconImg = GET_ITEM_ICON_IMAGE(itemCls);

                        if is_new_item(invItem:GetIESID()) == true or is_stack_new_item(obj.ClassID) then
                            slot:SetHeaderImage('new_inventory_icon_s')
                        else
                            slot:SetHeaderImage('None')
                        end

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
                        local iconInfo = icon:GetInfo()
                        if iconInfo ~= nil then
                            k = k + 1
                        end
                    end
                    j = j + 1
                end

            elseif accountwarehouse_tab:GetSelectItemIndex() == 3 then

                local count = 279
                local j = 1
                for i = 211, count do

                    local slot = GET_CHILD_RECURSIVELY(slotset, "slot" .. j)

                    if i - 1 == invIndex then

                        slot:SetSkinName('invenslot2')

                        local iconImg = GET_ITEM_ICON_IMAGE(itemCls);

                        if is_new_item(invItem:GetIESID()) == true or is_stack_new_item(obj.ClassID) then
                            slot:SetHeaderImage('new_inventory_icon_s')
                        else
                            slot:SetHeaderImage('None')
                        end
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
                        local iconInfo = icon:GetInfo()
                        if iconInfo ~= nil then
                            k = k + 1
                        end
                    end
                    j = j + 1
                end

            elseif accountwarehouse_tab:GetSelectItemIndex() == 4 then

                local count = 349

                local j = 1
                for i = 281, count do

                    local slot = GET_CHILD_RECURSIVELY(slotset, "slot" .. j)

                    if i - 1 == invIndex then

                        slot:SetSkinName('invenslot2')

                        local iconImg = GET_ITEM_ICON_IMAGE(itemCls);

                        if is_new_item(invItem:GetIESID()) == true or is_stack_new_item(obj.ClassID) then
                            slot:SetHeaderImage('new_inventory_icon_s')
                        else
                            slot:SetHeaderImage('None')
                        end

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
                        local iconInfo = icon:GetInfo()
                        if iconInfo ~= nil then
                            k = k + 1
                        end
                    end
                    j = j + 1
                end

            end

        end

    end
    itemcnt:SetTextByKey('cnt', k);
    if accountwarehouse_tab:GetSelectItemIndex() == 0 then
        itemcnt:SetTextByKey('slotmax', g.max_count - 280);
    else
        itemcnt:SetTextByKey('slotmax', 70);
    end]]

end
